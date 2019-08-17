require("lib/utils/ConstraintHelper")

ArmAnimator = ArmAnimator or class()
ArmAnimator._arm_modifier_names = {
	shoulder = {
		Idstring("RightShoulder"),
		Idstring("LeftShoulder")
	},
	arm = {
		Idstring("RightArm"),
		Idstring("LeftArm")
	},
	fore_arm = {
		Idstring("RightForeArm"),
		Idstring("LeftForeArm")
	},
	fore_arm_roll = {
		Idstring("RightForeArmRoll"),
		Idstring("LeftForeArmRoll")
	},
	hand = {
		Idstring("RightHand"),
		Idstring("LeftHand")
	}
}
ArmAnimator.SIMULATION_RATE = tweak_data.vr.arm_simulator.rate
ArmAnimator.MOMENTUM_ENABLED = true
ArmAnimator.MOMENTUM = tweak_data.vr.arm_simulator.momentum
ArmAnimator.MOMENTUM_DECAY = tweak_data.vr.arm_simulator.momentum_decay
ArmAnimator.PAUSE = false
ArmAnimator.DISALLOW_MIRROR_STATES = {
	bow = true,
	arrested = true,
	driving = true
}
ArmAnimator.DISALLOW_HEAD_LOOK_STATES = {
	bow = true,
	fatal = true,
	tased = true,
	arrested = true,
	bleed_out = true,
	driving = true
}
ArmAnimator.DISALLOW_FACING_DIR = {
	bow = true
}
local look_head_ids = Idstring("look_head_vr")

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

local function calculate_momentum(momentum, cur, next, t)
	mrotation.rotation_difference(momentum.shoulder[1], cur.shoulder[1], next.shoulder[1])
	mrotation.rotation_difference(momentum.shoulder[2], cur.shoulder[2], next.shoulder[2])
	mrotation.rotation_difference(momentum.arm[1], cur.arm[1], next.arm[1])
	mrotation.rotation_difference(momentum.arm[2], cur.arm[2], next.arm[2])
	mrotation.rotation_difference(momentum.fore_arm[1], cur.fore_arm[1], next.fore_arm[1])
	mrotation.rotation_difference(momentum.fore_arm[2], cur.fore_arm[2], next.fore_arm[2])
	mrotation.rotation_difference(momentum.hand[1], cur.hand[1], next.hand[1])
	mrotation.rotation_difference(momentum.hand[2], cur.hand[2], next.hand[2])
end

local zero_rot = Rotation()

local function add_momentum(cur, momentum, momentum_scale, momentum_decay)
	mrotation.slerp(cur.shoulder[1], cur.shoulder[1], momentum.shoulder[1] * cur.shoulder[1], momentum_scale)
	mrotation.slerp(cur.shoulder[2], cur.shoulder[2], momentum.shoulder[2] * cur.shoulder[2], momentum_scale)
	mrotation.slerp(cur.arm[1], cur.arm[1], momentum.arm[1] * cur.arm[1], momentum_scale)
	mrotation.slerp(cur.arm[2], cur.arm[2], momentum.arm[2] * cur.arm[2], momentum_scale)
	mrotation.slerp(cur.fore_arm[1], cur.fore_arm[1], momentum.fore_arm[1] * cur.fore_arm[1], momentum_scale)
	mrotation.slerp(cur.fore_arm[2], cur.fore_arm[2], momentum.fore_arm[2] * cur.fore_arm[2], momentum_scale)
	mrotation.slerp(cur.hand[1], cur.hand[1], momentum.hand[1] * cur.hand[1], momentum_scale)
	mrotation.slerp(cur.hand[2], cur.hand[2], momentum.hand[2] * cur.hand[2], momentum_scale)
	mrotation.slerp(momentum.shoulder[1], momentum.shoulder[1], zero_rot, momentum_decay)
	mrotation.slerp(momentum.shoulder[2], momentum.shoulder[2], zero_rot, momentum_decay)
	mrotation.slerp(momentum.arm[1], momentum.arm[1], zero_rot, momentum_decay)
	mrotation.slerp(momentum.arm[2], momentum.arm[2], zero_rot, momentum_decay)
	mrotation.slerp(momentum.fore_arm[1], momentum.fore_arm[1], zero_rot, momentum_decay)
	mrotation.slerp(momentum.fore_arm[2], momentum.fore_arm[2], zero_rot, momentum_decay)
	mrotation.slerp(momentum.hand[1], momentum.hand[1], zero_rot, momentum_decay)
	mrotation.slerp(momentum.hand[2], momentum.hand[2], zero_rot, momentum_decay)
end

function ArmAnimator:init(state_machine, clbk)
	self._machine = state_machine
	self._current_pose = {
		shoulder = {
			Rotation(),
			Rotation()
		},
		arm = {
			Rotation(),
			Rotation()
		},
		fore_arm = {
			Rotation(),
			Rotation()
		},
		hand = {
			Rotation(),
			Rotation()
		}
	}
	self._current_pose.fore_arm_roll = self._current_pose.fore_arm
	self._momentum = {
		shoulder = {
			Rotation(),
			Rotation()
		},
		arm = {
			Rotation(),
			Rotation()
		},
		fore_arm = {
			Rotation(),
			Rotation()
		},
		hand = {
			Rotation(),
			Rotation()
		}
	}
	self._arm_modifiers = {}

	for name, ids in pairs(self._arm_modifier_names) do
		self._arm_modifiers[name] = {
			self._machine:get_modifier(ids[1]),
			self._machine:get_modifier(ids[2])
		}
	end

	self._enabled = false
	self._frame_index = 0
	self._anim_t = 0
	self._prev_frame = nil
	self._current_frame = nil
	self._frame_queue = {}
	self._frame_counter = 0
	self._primary_hand = 0
	self._facing = Vector3(0, 1, 0)
	self._look_head_modifier = self._machine:get_modifier(look_head_ids)
	self._blocked_states = {}
	self._global_variables = {
		vr = {
			value = 0,
			default = 0
		}
	}
	self._target_look_yaw = 0
	self._look_yaw = 0
	self._look_pitch = 0
	self._enabled_state_changed_clbk = clbk
end

function ArmAnimator:_update_global_variables()
	local blocked = self:is_blocked()
	self._global_variables.vr.value = self._enabled and not blocked and 1 or 0

	for var, entry in pairs(self._global_variables) do
		self._machine:set_global(var, entry.value or entry.default)
	end
end

local mirror_arm_ids = Idstring("mirror_arm")
local blend_in = 0.5
local blend_out = 0.6

function ArmAnimator:_update_modifiers()
	local blocked = self:is_blocked()
	local allow_mirror = self:is_mirror_allowed()
	local allow_look = self:is_look_allowed()

	if self._enabled and allow_mirror then
		if self._primary_hand == 0 then
			self._machine:forbid_modifier(mirror_arm_ids)
		else
			self._machine:force_modifier(mirror_arm_ids)
		end
	else
		self._machine:forbid_modifier(mirror_arm_ids)
	end

	if self._enabled and allow_look then
		print("Enable look")
		self._machine:force_modifier(look_head_ids)
	else
		print("Disable look")
		self._machine:forbid_modifier(look_head_ids)
	end

	if self._enabled and not blocked then
		print("Enable")

		for _, ids in pairs(self._arm_modifier_names) do
			self._machine:force_modifier(ids[1])
			self._machine:force_modifier(ids[2])
		end
	else
		print("Disable")

		for _, ids in pairs(self._arm_modifier_names) do
			self._machine:forbid_modifier(ids[1])
			self._machine:forbid_modifier(ids[2])
		end
	end

	if self._enabled_state_changed_clbk and (self._prev_blocked ~= blocked or self._prev_enabled ~= self._enabled) then
		self._enabled_state_changed_clbk(self._enabled and not blocked)

		self._prev_enabled = self._enabled
		self._prev_blocked = blocked
	end
end

function ArmAnimator:clear_blocked()
	self._blocked_states = {}
end

function ArmAnimator:is_look_allowed()
	local allowed = true

	for state, value in pairs(self._blocked_states) do
		allowed = allowed and (not value or not ArmAnimator.DISALLOW_HEAD_LOOK_STATES[state])
	end

	return allowed
end

function ArmAnimator:is_mirror_allowed()
	local allowed = true

	for state, value in pairs(self._blocked_states) do
		allowed = allowed and (not value or not ArmAnimator.DISALLOW_MIRROR_STATES[state])
	end

	return allowed
end

function ArmAnimator:is_facing_allowed()
	local allowed = true

	for state, value in pairs(self._blocked_states) do
		allowed = allowed and (not value or not ArmAnimator.DISALLOW_FACING_DIR[state])
	end

	return allowed
end

function ArmAnimator:is_blocked()
	local blocked = false

	for state, value in pairs(self._blocked_states) do
		blocked = blocked or value
	end

	return blocked
end

function ArmAnimator:is_state_blocked(state)
	return self._blocked_states[state] or false
end

function ArmAnimator:clear_state_blocked()
	self._blocked_states = {}

	self:_update_global_variables()
	self:_update_modifiers()
end

function ArmAnimator:set_state_blocked(state, blocked)
	if self._blocked_states[state] == blocked then
		return
	end

	self._blocked_states[state] = blocked

	if self._enabled then
		self:_update_global_variables()
		self:_update_modifiers()
	end
end

function ArmAnimator:set_enabled(enabled)
	if self._enabled == enabled then
		return
	end

	self._enabled = enabled

	self:_update_global_variables()
	self:_update_modifiers()
end

function ArmAnimator:enabled()
	return self._enabled
end

function ArmAnimator:set_primary_hand(hand)
	if self._primary_hand == hand then
		return
	end

	self._primary_hand = hand

	self:_update_modifiers()
end

function ArmAnimator:facing_dir()
	return self._facing
end

function ArmAnimator:_set_pose(pose)
	for name, rotations in pairs(pose) do
		local mod = self._arm_modifiers[name]

		if mod then
			mod[1]:set_target_rotation(rotations[1])
			mod[2]:set_target_rotation(rotations[2])
		end
	end

	self._facing = (pose.shoulder[1]:x() + pose.shoulder[2]:x()):with_z(0)

	mvector3.cross(self._facing, self._facing, math.UP)
	mvector3.normalize(self._facing)
end

function ArmAnimator:record_keyframe(frame_index, pose, r_correction, l_correction)
	if ArmAnimator.PAUSE then
		return
	end

	local distance = 0

	if frame_index < self._frame_index then
		distance = 256 - self._frame_index + frame_index
	else
		distance = frame_index - self._frame_index
	end

	if distance > 220 then
		return
	end

	self._frame_index = frame_index
	local next_time = self._anim_t + 1

	if r_correction then
		mrotation.multiply(pose.hand[1], Rotation(-r_correction:y(), -r_correction:x(), -r_correction:z()):inverse())
	end

	if l_correction then
		mrotation.multiply(pose.hand[2], Rotation(l_correction:y(), -l_correction:x(), l_correction:z()):inverse())
	end

	local new_frame = {
		t = next_time,
		pose = pose
	}
	self._frame_queue[1] = new_frame
end

function ArmAnimator:update_animation(t, dt)
	if not self._current_frame and #self._frame_queue == 0 then
		return
	end

	local nr_queued_frames = #self._frame_queue

	if nr_queued_frames > 0 then
		self._current_frame = self._frame_queue[nr_queued_frames]

		calculate_momentum(self._momentum, self._prev_frame and self._prev_frame.pose or self._current_pose, self._current_frame.pose)

		self._prev_frame = self._frame_queue[1]
		self._frame_queue[1] = nil
	end

	self._anim_t = self._anim_t + ArmAnimator.SIMULATION_RATE * dt
	local duration = 1 - (self._current_frame.t - self._anim_t)

	if duration <= 1 then
		slerp_pose(self._current_pose, self._current_frame.pose, math.clamp(duration, 0, 1))
	elseif ArmAnimator.MOMENTUM_ENABLED then
		add_momentum(self._current_pose, self._momentum, ArmAnimator.MOMENTUM * dt, ArmAnimator.MOMENTUM_DECAY * dt)
	end

	self:_set_pose(self._current_pose)

	return true
end

function ArmAnimator:set_look_dir(yaw, pitch)
	self._target_look_yaw = yaw
	self._look_pitch = pitch
end

function ArmAnimator:update(t, dt)
	if not self._enabled then
		return
	end

	if not self:update_animation(t, dt) then
		return
	end

	local rel_yaw = ConstraintHelper.normalize_angle(self._target_look_yaw - self._look_yaw)
	local dy = math.sign(rel_yaw) * math.min(math.abs(rel_yaw), 360 * dt)
	self._look_yaw = (self._look_yaw + dy) % 360
	local yaw = self._look_yaw
	local pitch = self._look_pitch
	local facing_yaw = Rotation:look_at(self._facing, math.UP):yaw()
	yaw = facing_yaw + ConstraintHelper.clamp_angle(yaw - facing_yaw, -90, 90)

	self._look_head_modifier:set_target_rotation(Rotation(yaw + 180, -pitch + 90, 0))
end
