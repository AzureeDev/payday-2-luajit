require("lib/utils/ConstraintHelper")
require("lib/utils/Array")

ArmSimulator = ArmSimulator or class()
ArmSimulator.UPDATE_INTERVAL = 1 / tweak_data.vr.arm_simulator.rate
ArmSimulator.SPRING_AMOUNT = 90
ArmSimulator.SPRING_DAMPING = 15
ArmSimulator.SPRING_SPEED = 100
NeutralArmModifier = NeutralArmModifier or class()

function NeutralArmModifier:init(hand)
	self._neutral_state = false
	self._t = 1
	self._speed = 0
	self._assist_state = false
	self._update = false
end

function NeutralArmModifier:update(neutral_state, body_config, hmd_position, orientation, facing, hand, dt)
	if self._neutral_state ~= neutral_state then
		self._neutral_state = neutral_state
		self._t = 1 - self._t
		self._speed = 0
		self._update = true
	end

	if not self._update then
		return
	end

	local rot = Rotation:look_at(-math.UP, facing)
	local p = {
		orientation[1],
		hmd_position:with_z(hmd_position.z - body_config.arm_length - body_config.head_to_shoulder) + rot:x() * (hand == 1 and 0.4 * body_config.arm_length or -0.4 * body_config.arm_length)
	}
	local r = {
		orientation[2],
		rot
	}
	self._t = math.clamp(self._t + self._speed * dt, 0, 1)
	self._speed = math.min(self._speed + dt * 18, 50)

	mvector3.lerp(orientation[1], p[self._neutral_state and 1 or 2], p[self._neutral_state and 2 or 1], self._t)
	mrotation.slerp(orientation[2], r[self._neutral_state and 1 or 2], r[self._neutral_state and 2 or 1], self._t)

	self._update = self._neutral_state or self._t < 1
end

function ArmSimulator:init(neural_network, controller)
	self._controller = controller
	self._next_sync_t = 0
	self._arm_length = tweak_data.vr.default_body_metrics.arm_length
	self._head_to_shoulder = tweak_data.vr.default_body_metrics.head_to_shoulder
	self._shoulder_width = tweak_data.vr.default_body_metrics.shoulder_width
	self._body_config = NNetHelper.create_body_config(self._arm_length, self._head_to_shoulder, self._shoulder_width)
	self._enabled = false
	self._facing = Vector3(0, 1, 0)
	self._prev_facing = Vector3(0, 1, 0)

	self:load_neural_net(neural_network)
	self:_add_setting_callback("arm_length", "_arm_length_changed")
	self:_add_setting_callback("head_to_shoulder", "_head_to_shoulder_changed")
	self:_add_setting_callback("shoulder_width", "_shoulder_width_changed")
	self:_add_setting_callback("arm_animation", "_arm_animation_enabled_changed")

	self._neutral_arm_modifier = {
		NeutralArmModifier:new(),
		NeutralArmModifier:new()
	}
	self._velocity = Vector3()
end

function ArmSimulator:load_neural_net(neural_network)
	local node = PackageManager:xml_data(Idstring("neural_net"), Idstring(neural_network))
	self._neural_network = {
		weights = {},
		bias = {}
	}

	for n, _ in node:children() do
		local array = Array.from_node(n):transpose()
		local name = array:name()

		if not name or name == "weight" then
			table.insert(self._neural_network.weights, array)
		elseif name == "bias" then
			table.insert(self._neural_network.bias, array)
		end
	end
end

function ArmSimulator:enabled()
	return self._enabled
end

function ArmSimulator:refresh_settings()
	for _, setting in ipairs(self._settings) do
		setting.clbk(setting.name, nil, managers.vr:get_setting(setting.name))
	end
end

function ArmSimulator:_add_setting_callback(setting_name, method)
	local clbk = callback(self, self, method)

	managers.vr:add_setting_changed_callback(setting_name, clbk)
	clbk(setting_name, nil, managers.vr:get_setting(setting_name))

	self._settings = self._settings or {}

	table.insert(self._settings, {
		name = setting_name,
		clbk = clbk
	})
end

function ArmSimulator:_arm_length_changed(setting, old, new)
	self._arm_length = new
	self._body_config = NNetHelper.create_body_config(self._arm_length, self._head_to_shoulder, self._shoulder_width)
end

function ArmSimulator:_head_to_shoulder_changed(setting, old, new)
	self._head_to_shoulder = new
	self._body_config = NNetHelper.create_body_config(self._arm_length, self._head_to_shoulder, self._shoulder_width)
end

function ArmSimulator:_shoulder_width_changed(setting, old, new)
	self._shoulder_width = new
	self._body_config = NNetHelper.create_body_config(self._arm_length, self._head_to_shoulder, self._shoulder_width)
end

function ArmSimulator:_arm_animation_enabled_changed(setting, old, new)
	self._enabled = new
end

function ArmSimulator:pose()
	return self._pose
end

local function slerp_pose(cur_pose, target_pose, t)
	mrotation.slerp(cur_pose.shoulder[1], cur_pose.shoulder[1], target_pose.shoulder[1], t)
	mrotation.slerp(cur_pose.shoulder[2], cur_pose.shoulder[2], target_pose.shoulder[2], t)
	mrotation.slerp(cur_pose.arm[1], cur_pose.arm[1], target_pose.arm[1], t)
	mrotation.slerp(cur_pose.arm[2], cur_pose.arm[2], target_pose.arm[2], t)
	mrotation.slerp(cur_pose.fore_arm[1], cur_pose.fore_arm[1], target_pose.fore_arm[1], t)
	mrotation.slerp(cur_pose.fore_arm[2], cur_pose.fore_arm[2], target_pose.fore_arm[2], t)
	mrotation.slerp(cur_pose.hand[1], cur_pose.hand[1], target_pose.hand[1], t)
	mrotation.slerp(cur_pose.hand[2], cur_pose.hand[2], target_pose.hand[2], t)
end

function springdamp(src, dst, velocity, spring, dampening, max_speed, dt)
	local offset = dst - src
	local accel = offset * spring - velocity * dampening

	mvector3.set(velocity, velocity + accel * dt + velocity * dt + 0.5 * accel * dt * dt)

	local speed = mvector3.normalize(velocity)

	if max_speed < speed then
		speed = math.min(speed, max_speed)
	end

	mvector3.multiply(velocity, speed)

	return src + velocity * dt
end

function ArmSimulator:_update_assist_arm(input_sample, dt)
	local assist_r = managers.player:player_unit():hand():current_hand_state(1):name() == "weapon_assist"
	local assist_l = managers.player:player_unit():hand():current_hand_state(2):name() == "weapon_assist"

	self._neutral_arm_modifier[1]:update(assist_r, input_sample.body_config, input_sample.hmd[1], input_sample.right_controller, self._facing, 1, dt)
	self._neutral_arm_modifier[2]:update(assist_l, input_sample.body_config, input_sample.hmd[1], input_sample.left_controller, self._facing, 2, dt)
end

function ArmSimulator:update(t, dt, base_rotation, target, moving, dir)
	if not self._enabled then
		return false
	end

	local input_sample = NNetHelper.preprocess_input_sample(NNetHelper.sample_input(self._controller, self._body_config))
	local forward = Rotation(input_sample.hmd[2]:yaw(), 0, 0)
	local use_move_dir = moving and dir

	if use_move_dir then
		local y = forward:y()
		local x = forward:x()
		dir = dir:rotate_with(base_rotation:inverse())
		dir = y * math.abs(mvector3.dot(dir, y)) + x * mvector3.dot(dir, x)

		mvector3.normalize(dir)
	end

	local max_look_angle = 70
	local cos_max_look_angle = 0.342
	local use_look_dir = mvector3.dot(self._facing, forward:y()) < cos_max_look_angle
	local s1 = self._facing:to_polar().spin

	if not use_look_dir then
		local v = use_move_dir and dir or self._prev_facing
		local angle = mvector3.angle(forward:y(), self._facing)
		local s2 = v:to_polar().spin
		local rel_a = ConstraintHelper.normalize_angle(s2 - s1)
		local speed = use_move_dir and 1 or math.clamp((angle - 50) / (max_look_angle - 50), 0, 1)
		speed = speed * speed
		local step = math.sign(rel_a) * math.min(math.abs(rel_a), 360 * dt) * speed
		self._facing = Polar(1, 0, s1 + step):to_vector()
	else
		local s2 = forward:y():to_polar().spin
		local rel_a = ConstraintHelper.normalize_angle(s2 - s1)
		local s = (math.abs(rel_a) - max_look_angle) * math.sign(rel_a)
		self._facing = Polar(1, 0, s1 + s):to_vector()
	end

	self:_update_assist_arm(input_sample, dt)

	local input = Array:new({
		NNetHelper.transform_input_sample(input_sample, self._facing)
	})
	local layer0 = input
	self._layer1 = layer0:dot_transpose(self._neural_network.weights[1], self._layer1)

	array_sigmoid(self._layer1, self._layer1)

	self._layer2 = self._layer1:dot_transpose(self._neural_network.weights[2], self._layer2)

	array_sigmoid(self._layer2, self._layer2)

	self._layer3 = self._layer2:dot_transpose(self._neural_network.weights[3], self._layer3)

	array_sigmoid(self._layer3, self._layer3)

	local output_sample = NNetHelper.inv_transform_output_sample(input_sample, self._layer3:data())
	self._prev_facing = output_sample.facing:rotate_with(forward)
	forward = forward * base_rotation
	local rot = Rotation(forward:yaw(), 0, 0)
	self._pose = NNetHelper.build_pose(output_sample, rot, target, self._pose)
end
