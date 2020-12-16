FPCameraPlayerBase = FPCameraPlayerBase or class(UnitBase)
FPCameraPlayerBase.IDS_EMPTY = Idstring("empty")
FPCameraPlayerBase.IDS_NOSTRING = Idstring("")
FPCameraPlayerBase.bipod_location = nil
FPCameraPlayerBase.camera_last_pos = nil

require("lib/utils/VRFadeout")

function FPCameraPlayerBase:init(unit)
	UnitBase.init(self, unit, true)

	self._unit = unit

	unit:set_timer(managers.player:player_timer())
	unit:set_animation_timer(managers.player:player_timer())
	unit:set_approximate_orientation(false)

	self._anims_enabled = true
	self._obj_eye = self._unit:orientation_object()
	self._weap_align = self._unit:get_object(Idstring("right_weapon_align"))
	self._camera_properties = {
		pitch = 0.5,
		spin = 0
	}
	self._output_data = {
		position = unit:position(),
		rotation = unit:rotation()
	}
	self._head_stance = {
		translation = Vector3(),
		rotation = Rotation()
	}
	self._shoulder_stance = {
		translation = Vector3(),
		rotation = Rotation()
	}
	self._vel_overshot = {
		translation = Vector3(),
		rotation = Rotation(),
		last_yaw = 0,
		last_pitch = 0,
		target_yaw = 0,
		target_pitch = 0
	}
	self._aim_assist = {
		direction = Vector3(),
		distance = 0,
		mrotation = Rotation(),
		distance_to_aim_line = 0
	}
	self._aim_assist_sticky = {
		direction = Vector3(),
		distance = 0,
		mrotation = Rotation(),
		distance_to_aim_line = 0,
		is_sticky = true
	}
	self._fov = {
		fov = 75
	}
	self._input = {}
	self._tweak_data = tweak_data.input.gamepad
	self._camera_properties.look_speed_current = self._tweak_data.look_speed_standard
	self._camera_properties.look_speed_transition_timer = 0
	self._camera_properties.target_tilt = 0
	self._camera_properties.current_tilt = 0
	self._recoil_kick = {
		h = {}
	}
	self._episilon = 1e-05

	self:check_flashlight_enabled()
	self:load_fps_mask_units()

	if _G.IS_VR then
		self._hmd_tracking = true
		local rot = VRManager:hmd_rotation()
		self._base_rotation = self._output_data.rotation
		self._fadeout = VRFadeout:new()
	end
end

function FPCameraPlayerBase:set_parent_unit(parent_unit)
	self._parent_unit = parent_unit
	self._parent_movement_ext = self._parent_unit:movement()

	parent_unit:base():add_destroy_listener("FPCameraPlayerBase", callback(self, self, "parent_destroyed_clbk"))

	local controller_type = self._parent_unit:base():controller():get_default_controller_id()

	if controller_type == "keyboard" then
		self._look_function = callback(self, self, "_pc_look_function")
		self._tweak_data.uses_keyboard = true
	elseif controller_type == "steampad" then
		self._look_function = callback(self, self, "_steampad_look_function")
		self._tweak_data.uses_keyboard = true
	else
		self._look_function = callback(self, self, "_gamepad_look_function_ctl")
		self._tweak_data.uses_keyboard = false
	end

	if _G.IS_VR then
		self._fadeout:play()
	end
end

function FPCameraPlayerBase:parent_destroyed_clbk(parent_unit)
	self._unit:set_extension_update_enabled(Idstring("base"), false)
	self:set_slot(self._unit, 0)

	self._parent_unit = nil
end

function FPCameraPlayerBase:reset_properties()
	self._camera_properties.spin = self._parent_unit:rotation():y():to_polar().spin
end

function FPCameraPlayerBase:update(unit, t, dt)
	if self._tweak_data.aim_assist_use_sticky_aim then
		self:_update_aim_assist_sticky(t, dt)
	end

	if _G.IS_VR and self._hmd_tracking and not self._block_input then
		self._output_data.rotation = self._base_rotation * VRManager:hmd_rotation()
	end

	if not _G.IS_VR then
		self._parent_unit:base():controller():get_input_axis_clbk("look", callback(self, self, "_update_rot"))
	end

	self:_update_stance(t, dt)
	self:_update_movement(t, dt)

	if managers.player:current_state() ~= "driving" then
		self._parent_unit:camera():set_position(self._output_data.position)
		self._parent_unit:camera():set_rotation(self._output_data.rotation)
	else
		self:_set_camera_position_in_vehicle()
	end

	if _G.IS_VR then
		self:_update_fadeout(self._output_data.mover_position, self._output_data.position, self._output_data.rotation, t, dt)
		self._parent_unit:camera():update_transform()
	end

	if self._fov.dirty then
		self._parent_unit:camera():set_FOV(self._fov.fov)

		self._fov.dirty = nil
	end

	if alive(self._light) then
		local weapon = self._parent_unit:inventory():equipped_unit()

		if weapon then
			local object = weapon:get_object(Idstring("fire"))
			local pos = object:position() + object:rotation():y() * 10 + object:rotation():x() * 0 + object:rotation():z() * -2

			self._light:set_position(pos)
			self._light:set_rotation(Rotation(object:rotation():z(), object:rotation():x(), object:rotation():y()))
			World:effect_manager():move_rotate(self._light_effect, pos, Rotation(object:rotation():x(), -object:rotation():y(), -object:rotation():z()))
		end
	end
end

function FPCameraPlayerBase:check_flashlight_enabled()
	if managers.game_play_central:flashlights_on_player_on() then
		if not alive(self._light) then
			self._light = World:create_light("spot|specular")

			self._light:set_spot_angle_end(45)
			self._light:set_far_range(1000)
		end

		if not self._light_effect then
			self._light_effect = World:effect_manager():spawn({
				effect = Idstring("effects/particles/weapons/flashlight/fp_flashlight"),
				position = self._unit:position(),
				rotation = Rotation()
			})
		end

		self._light:set_enable(true)
		World:effect_manager():set_hidden(self._light_effect, false)
	elseif alive(self._light) then
		self._light:set_enable(false)
		World:effect_manager():set_hidden(self._light_effect, true)
	end
end

function FPCameraPlayerBase:start_shooting()
	self._recoil_kick.accumulated = self._recoil_kick.to_reduce or 0
	self._recoil_kick.to_reduce = nil
	self._recoil_kick.current = self._recoil_kick.current and self._recoil_kick.current or self._recoil_kick.accumulated or 0
	self._recoil_kick.h.accumulated = self._recoil_kick.h.to_reduce or 0
	self._recoil_kick.h.to_reduce = nil
	self._recoil_kick.h.current = self._recoil_kick.h.current and self._recoil_kick.h.current or self._recoil_kick.h.accumulated or 0
end

function FPCameraPlayerBase:stop_shooting(wait)
	self._recoil_kick.to_reduce = self._recoil_kick.accumulated
	self._recoil_kick.h.to_reduce = self._recoil_kick.h.accumulated
	self._recoil_wait = wait or 0
end

function FPCameraPlayerBase:break_recoil()
	self._recoil_kick.current = 0
	self._recoil_kick.h.current = 0
	self._recoil_kick.accumulated = 0
	self._recoil_kick.h.accumulated = 0

	self:stop_shooting()
end

function FPCameraPlayerBase:recoil_kick(up, down, left, right)
	if math.abs(self._recoil_kick.accumulated) < 20 then
		local v = math.lerp(up, down, math.random())
		self._recoil_kick.accumulated = (self._recoil_kick.accumulated or 0) + v
	end

	local h = math.lerp(left, right, math.random())
	self._recoil_kick.h.accumulated = (self._recoil_kick.h.accumulated or 0) + h
end

local bezier_values = {
	0,
	0,
	1,
	1
}

function FPCameraPlayerBase:_update_stance(t, dt)
	if self._shoulder_stance.transition then
		local trans_data = self._shoulder_stance.transition
		local elapsed_t = t - trans_data.start_t

		if trans_data.duration < elapsed_t then
			mvector3.set(self._shoulder_stance.translation, trans_data.end_translation)

			self._shoulder_stance.rotation = trans_data.end_rotation
			self._shoulder_stance.transition = nil
		else
			local progress = elapsed_t / trans_data.duration
			local progress_smooth = math.bezier(bezier_values, progress)

			mvector3.lerp(self._shoulder_stance.translation, trans_data.start_translation, trans_data.end_translation, progress_smooth)

			self._shoulder_stance.rotation = trans_data.start_rotation:slerp(trans_data.end_rotation, progress_smooth)
		end
	end

	if self._head_stance.transition then
		local trans_data = self._head_stance.transition
		local elapsed_t = t - trans_data.start_t

		if trans_data.duration < elapsed_t then
			mvector3.set(self._head_stance.translation, trans_data.end_translation)

			self._head_stance.transition = nil
		else
			local progress = elapsed_t / trans_data.duration
			local progress_smooth = math.bezier(bezier_values, progress)

			mvector3.lerp(self._head_stance.translation, trans_data.start_translation, trans_data.end_translation, progress_smooth)
		end
	end

	if self._vel_overshot.transition then
		local trans_data = self._vel_overshot.transition
		local elapsed_t = t - trans_data.start_t

		if trans_data.duration < elapsed_t then
			self._vel_overshot.yaw_neg = trans_data.end_yaw_neg
			self._vel_overshot.yaw_pos = trans_data.end_yaw_pos
			self._vel_overshot.pitch_neg = trans_data.end_pitch_neg
			self._vel_overshot.pitch_pos = trans_data.end_pitch_pos

			mvector3.set(self._vel_overshot.pivot, trans_data.end_pivot)

			self._vel_overshot.transition = nil
		else
			local progress = elapsed_t / trans_data.duration
			local progress_smooth = math.bezier(bezier_values, progress)
			self._vel_overshot.yaw_neg = math.lerp(trans_data.start_yaw_neg, trans_data.end_yaw_neg, progress_smooth)
			self._vel_overshot.yaw_pos = math.lerp(trans_data.start_yaw_pos, trans_data.end_yaw_pos, progress_smooth)
			self._vel_overshot.pitch_neg = math.lerp(trans_data.start_pitch_neg, trans_data.end_pitch_neg, progress_smooth)
			self._vel_overshot.pitch_pos = math.lerp(trans_data.start_pitch_pos, trans_data.end_pitch_pos, progress_smooth)

			mvector3.lerp(self._vel_overshot.pivot, trans_data.start_pivot, trans_data.end_pivot, progress_smooth)
		end
	end

	self:_calculate_soft_velocity_overshot(dt)

	if self._fov.transition then
		local trans_data = self._fov.transition
		local elapsed_t = t - trans_data.start_t

		if trans_data.duration < elapsed_t then
			self._fov.fov = trans_data.end_fov
			self._fov.transition = nil
		else
			local progress = elapsed_t / trans_data.duration
			local progress_smooth = math.max(math.min(math.bezier(bezier_values, progress), 1), 0)
			self._fov.fov = math.lerp(trans_data.start_fov, trans_data.end_fov, progress_smooth)
		end

		self._fov.dirty = true
	end
end

local mrot1 = Rotation()
local mrot2 = Rotation()
local mrot3 = Rotation()
local mrot4 = Rotation()
local mvec1 = Vector3()
local mvec2 = Vector3()
local mvec3 = Vector3()
local mvec4 = Vector3()

function FPCameraPlayerBase:_update_movement(t, dt)
	local data = self._camera_properties
	local new_head_pos = mvec2
	local new_shoulder_pos = mvec1
	local new_shoulder_rot = mrot1
	local new_head_rot = mrot2

	self._parent_unit:m_position(new_head_pos)

	if _G.IS_VR then
		local hmd_position = mvec1
		local mover_position = mvec3

		mvector3.set(mover_position, new_head_pos)
		mvector3.set(hmd_position, self._parent_movement_ext:hmd_position())
		mvector3.set(new_head_pos, self._parent_movement_ext:ghost_position())
		mvector3.set_x(hmd_position, 0)
		mvector3.set_y(hmd_position, 0)
		mvector3.add(new_head_pos, hmd_position)

		local mover_top = math.max(self._parent_unit:get_active_mover_offset() * 2, 45)

		mvector3.set_z(mover_position, mover_position.z + mover_top)

		self._output_data.mover_position = mvector3.copy(mover_position)

		self:_horizonatal_recoil_kick(t, dt)
		self:_vertical_recoil_kick(t, dt)
	else
		mvector3.add(new_head_pos, self._head_stance.translation)

		local stick_input_x = 0
		local stick_input_y = 0
		local aim_assist_x, aim_assist_y = self:_get_aim_assist(t, dt, self._tweak_data.aim_assist_snap_speed, self._aim_assist)
		stick_input_x = stick_input_x + self:_horizonatal_recoil_kick(t, dt) + aim_assist_x
		stick_input_y = stick_input_y + self:_vertical_recoil_kick(t, dt) + aim_assist_y
		local look_polar_spin = data.spin - stick_input_x
		local look_polar_pitch = math.clamp(data.pitch + stick_input_y, -85, 85)

		if not self._limits or not self._limits.spin then
			look_polar_spin = look_polar_spin % 360
		end

		local look_polar = Polar(1, look_polar_pitch, look_polar_spin)
		local look_vec = look_polar:to_vector()
		local cam_offset_rot = mrot3

		mrotation.set_look_at(cam_offset_rot, look_vec, math.UP)
		mrotation.set_zero(new_head_rot)
		mrotation.multiply(new_head_rot, self._head_stance.rotation)
		mrotation.multiply(new_head_rot, cam_offset_rot)

		data.pitch = look_polar_pitch
		data.spin = look_polar_spin
		self._output_data.rotation = new_head_rot or self._output_data.rotation

		if self._camera_properties.current_tilt ~= self._camera_properties.target_tilt then
			self._camera_properties.current_tilt = math.step(self._camera_properties.current_tilt, self._camera_properties.target_tilt, 150 * dt)
		end

		if self._camera_properties.current_tilt ~= 0 then
			self._output_data.rotation = Rotation(self._output_data.rotation:yaw(), self._output_data.rotation:pitch(), self._output_data.rotation:roll() + self._camera_properties.current_tilt)
		end
	end

	self._output_data.position = new_head_pos

	mvector3.set(new_shoulder_pos, self._shoulder_stance.translation)
	mvector3.add(new_shoulder_pos, self._vel_overshot.translation)
	mvector3.rotate_with(new_shoulder_pos, self._output_data.rotation)
	mvector3.add(new_shoulder_pos, new_head_pos)
	mrotation.set_zero(new_shoulder_rot)
	mrotation.multiply(new_shoulder_rot, self._output_data.rotation)
	mrotation.multiply(new_shoulder_rot, self._shoulder_stance.rotation)
	mrotation.multiply(new_shoulder_rot, self._vel_overshot.rotation)
	self:set_position(new_shoulder_pos)
	self:set_rotation(new_shoulder_rot)
end

local mvec1 = Vector3()

function FPCameraPlayerBase:_update_rot(axis, unscaled_axis)
	if self._animate_pitch then
		self:animate_pitch_upd()
	end

	local t = managers.player:player_timer():time()
	local dt = t - (self._last_rot_t or t)
	self._last_rot_t = t
	local data = self._camera_properties
	local new_head_pos = mvec2
	local new_shoulder_pos = mvec1
	local new_shoulder_rot = mrot1
	local new_head_rot = mrot2

	self._parent_unit:m_position(new_head_pos)
	mvector3.add(new_head_pos, self._head_stance.translation)

	self._input.look = axis
	self._input.look_multiplier = self._parent_unit:base():controller():get_setup():get_connection("look"):get_multiplier()
	local stick_input_x, stick_input_y = self._look_function(axis, self._input.look_multiplier, dt, unscaled_axis)
	local look_polar_spin = data.spin - stick_input_x
	local look_polar_pitch = math.clamp(data.pitch + stick_input_y, -85, 85)
	local player_state = managers.player:current_state()

	if self._limits then
		if self._limits.spin then
			local d = (look_polar_spin - self._limits.spin.mid) / self._limits.spin.offset
			d = math.clamp(d, -1, 1)
			look_polar_spin = data.spin - math.lerp(stick_input_x, 0, math.abs(d))
		end

		if self._limits.pitch then
			local d = math.abs((look_polar_pitch - self._limits.pitch.mid) / self._limits.pitch.offset)
			d = math.clamp(d, -1, 1)
			look_polar_pitch = data.pitch + math.lerp(stick_input_y, 0, math.abs(d))
			look_polar_pitch = math.clamp(look_polar_pitch, -85, 85)
		end
	end

	if not self._limits or not self._limits.spin then
		look_polar_spin = look_polar_spin % 360
	end

	local look_polar = Polar(1, look_polar_pitch, look_polar_spin)
	local look_vec = look_polar:to_vector()
	local cam_offset_rot = mrot3

	mrotation.set_look_at(cam_offset_rot, look_vec, math.UP)

	if self._animate_pitch == nil then
		mrotation.set_zero(new_head_rot)
		mrotation.multiply(new_head_rot, self._head_stance.rotation)
		mrotation.multiply(new_head_rot, cam_offset_rot)

		data.pitch = look_polar_pitch
		data.spin = look_polar_spin
	end

	self._output_data.position = new_head_pos

	if self._p_exit then
		self._p_exit = false
		self._output_data.rotation = self._parent_unit:movement().fall_rotation

		mrotation.multiply(self._output_data.rotation, self._parent_unit:camera():rotation())

		data.spin = self._output_data.rotation:y():to_polar().spin
	else
		self._output_data.rotation = new_head_rot or self._output_data.rotation
	end

	if self._camera_properties.current_tilt ~= self._camera_properties.target_tilt then
		self._camera_properties.current_tilt = math.step(self._camera_properties.current_tilt, self._camera_properties.target_tilt, 150 * dt)
	end

	if self._camera_properties.current_tilt ~= 0 then
		self._output_data.rotation = Rotation(self._output_data.rotation:yaw(), self._output_data.rotation:pitch(), self._output_data.rotation:roll() + self._camera_properties.current_tilt)
	end

	local equipped_weapon = self._parent_unit:inventory():equipped_unit()
	local bipod_weapon_translation = Vector3(0, 0, 0)

	if equipped_weapon and equipped_weapon:base() then
		local weapon_tweak_data = equipped_weapon:base():weapon_tweak_data()

		if weapon_tweak_data and weapon_tweak_data.bipod_weapon_translation then
			bipod_weapon_translation = weapon_tweak_data.bipod_weapon_translation
		end
	end

	local bipod_pos = Vector3(0, 0, 0)
	local bipod_rot = new_shoulder_rot

	mvector3.set(bipod_pos, bipod_weapon_translation)
	mvector3.rotate_with(bipod_pos, self._output_data.rotation)
	mvector3.add(bipod_pos, new_head_pos)
	mvector3.set(new_shoulder_pos, self._shoulder_stance.translation)
	mvector3.add(new_shoulder_pos, self._vel_overshot.translation)
	mvector3.rotate_with(new_shoulder_pos, self._output_data.rotation)
	mvector3.add(new_shoulder_pos, new_head_pos)
	mrotation.set_zero(new_shoulder_rot)
	mrotation.multiply(new_shoulder_rot, self._output_data.rotation)
	mrotation.multiply(new_shoulder_rot, self._shoulder_stance.rotation)
	mrotation.multiply(new_shoulder_rot, self._vel_overshot.rotation)

	if player_state == "driving" then
		self:_set_camera_position_in_vehicle()
	elseif player_state == "jerry1" or player_state == "jerry2" then
		mrotation.set_zero(cam_offset_rot)
		mrotation.multiply(cam_offset_rot, self._parent_unit:movement().fall_rotation)
		mrotation.multiply(cam_offset_rot, self._output_data.rotation)

		local shoulder_pos = mvec3
		local shoulder_rot = mrot4

		mrotation.set_zero(shoulder_rot)
		mrotation.multiply(shoulder_rot, cam_offset_rot)
		mrotation.multiply(shoulder_rot, self._shoulder_stance.rotation)
		mrotation.multiply(shoulder_rot, self._vel_overshot.rotation)
		mvector3.set(shoulder_pos, self._shoulder_stance.translation)
		mvector3.add(shoulder_pos, self._vel_overshot.translation)
		mvector3.rotate_with(shoulder_pos, cam_offset_rot)
		mvector3.add(shoulder_pos, self._parent_unit:position())
		self:set_position(shoulder_pos)
		self:set_rotation(shoulder_rot)
		self._parent_unit:camera():set_position(self._parent_unit:position())
		self._parent_unit:camera():set_rotation(cam_offset_rot)
	else
		self:set_position(new_shoulder_pos)
		self:set_rotation(new_shoulder_rot)
		self._parent_unit:camera():set_position(self._output_data.position)
		self._parent_unit:camera():set_rotation(self._output_data.rotation)
	end

	if player_state == "bipod" and not self._parent_unit:movement()._current_state:in_steelsight() then
		self:set_position(PlayerBipod._shoulder_pos or new_shoulder_pos)
		self:set_rotation(bipod_rot)
		self._parent_unit:camera():set_position(PlayerBipod._camera_pos or self._output_data.position)
	elseif not self._parent_unit:movement()._current_state:in_steelsight() then
		PlayerBipod:set_camera_positions(bipod_pos, self._output_data.position)
	end
end

function FPCameraPlayerBase:_set_camera_position_in_vehicle()
	local vehicle_data = managers.player:get_vehicle()

	if not vehicle_data then
		return
	end

	local vehicle_unit = vehicle_data.vehicle_unit
	local vehicle = vehicle_unit:vehicle()
	local vehicle_ext = vehicle_unit:vehicle_driving()
	local seat = vehicle_ext:find_seat_for_player(managers.player:player_unit())
	local obj_pos, obj_rot = vehicle_ext:get_object_placement(managers.player:local_player())

	if obj_pos == nil or obj_rot == nil then
		return
	end

	mvector3.set(mvec1, obj_pos)

	local stance = managers.player:local_player():movement():current_state():stance()

	if stance == PlayerDriving.STANCE_SHOOTING then
		mvector3.add(obj_pos, seat.shooting_pos:rotate_with(obj_rot))
	end

	local camera_rot = mrot3

	mrotation.set_zero(camera_rot)
	mrotation.multiply(camera_rot, obj_rot)
	mrotation.multiply(camera_rot, self._output_data.rotation)

	local hands_rot = mrot4

	mrotation.set_zero(hands_rot)
	mrotation.multiply(hands_rot, obj_rot)

	local target = Vector3(0, 0, 145)
	local target_camera = Vector3(0, 0, 145)

	if vehicle_ext._tweak_data.driver_camera_offset then
		target_camera = target_camera + vehicle_ext._tweak_data.driver_camera_offset
	end

	mvector3.rotate_with(target, obj_rot)
	mvector3.rotate_with(target_camera, obj_rot)

	local pos = obj_pos + target
	local camera_pos = obj_pos + target_camera

	if _G.IS_VR then
		local rot = obj_rot * self:base_rotation():inverse() * Rotation(self._initial_hmd_rotation:yaw()):inverse()

		mvector3.set(camera_pos, self._parent_movement_ext:ghost_position())
		mvector3.add(camera_pos, Vector3(0, 0, self._parent_movement_ext:hmd_position().z):rotate_with(rot))
		mrotation.set_zero(camera_rot)
		mrotation.multiply(camera_rot, rot)
		mrotation.multiply(camera_rot, self._output_data.rotation)
		mvector3.set(self._output_data.mover_position, mvec1 + target)
		self._unit:parent():set_position(seat.object:position())

		local new_head_pos = mvec1
		local hmd_position = mvec2

		self._parent_unit:m_position(new_head_pos)
		mvector3.set(hmd_position, self._parent_movement_ext:hmd_position())
		mvector3.set_x(hmd_position, 0)
		mvector3.set_y(hmd_position, 0)
		mvector3.rotate_with(hmd_position, obj_rot)
		mvector3.add(new_head_pos, hmd_position)
		mvector3.set(self._output_data.position, new_head_pos)
	end

	if _G.IS_VR or seat.driving then
		if vehicle_unit:camera() then
			vehicle_unit:camera():update_camera()
		end

		self:set_position(pos)
		self:set_rotation(hands_rot)
		self._parent_unit:camera():set_position(camera_pos)
		self._parent_unit:camera():set_rotation(camera_rot)
	else
		local shoulder_pos = mvec3
		local shoulder_rot = mrot4

		mrotation.set_zero(shoulder_rot)
		mrotation.multiply(shoulder_rot, camera_rot)
		mrotation.multiply(shoulder_rot, self._shoulder_stance.rotation)
		mrotation.multiply(shoulder_rot, self._vel_overshot.rotation)
		mvector3.set(shoulder_pos, self._shoulder_stance.translation)
		mvector3.add(shoulder_pos, self._vel_overshot.translation)
		mvector3.rotate_with(shoulder_pos, camera_rot)
		mvector3.add(shoulder_pos, pos)
		self:set_position(shoulder_pos)
		self:set_rotation(shoulder_rot)
		self._parent_unit:camera():set_position(pos)
		self._parent_unit:camera():set_rotation(camera_rot)
	end
end

function FPCameraPlayerBase:_get_aim_assist(t, dt, speed, aim_data)
	if aim_data.distance == 0 then
		return 0, 0
	end

	local s_value = math.step(0, aim_data.distance, speed * dt)
	local r_value_x = mvector3.x(aim_data.direction) * s_value
	local r_value_y = mvector3.y(aim_data.direction) * s_value

	if aim_data.is_sticky and self._tweak_data.aim_assist_use_sticky_aim then
		local strength = 1 - math.min(1, (aim_data.distance_to_aim_line or 0) / 100)
		local mx = 1 - self._tweak_data.aim_assist_gradient_max
		local mn = 1 - self._tweak_data.aim_assist_gradient_min
		local min_strength = math.lerp(mn, mx, math.min(1, (aim_data.target_distance or 0) / self._tweak_data.aim_assist_gradient_max_distance))
		strength = math.max(0, strength - min_strength) / (1 - min_strength)
		r_value_x = r_value_x * strength
		r_value_y = r_value_y * strength
	end

	aim_data.distance = aim_data.distance - s_value

	if aim_data.distance <= 0 then
		self:_stop_aim_assist(aim_data)
	end

	return r_value_x, r_value_y
end

function FPCameraPlayerBase:_vertical_recoil_kick(t, dt)
	local player_state = managers.player:current_state()

	if player_state == "bipod" then
		self:break_recoil()

		return 0
	end

	local r_value = 0

	if self._recoil_kick.current and self._episilon < self._recoil_kick.accumulated - self._recoil_kick.current then
		local n = math.step(self._recoil_kick.current, self._recoil_kick.accumulated, 40 * dt)
		r_value = n - self._recoil_kick.current
		self._recoil_kick.current = n
	elseif self._recoil_wait then
		self._recoil_wait = self._recoil_wait - dt

		if self._recoil_wait < 0 then
			self._recoil_wait = nil
		end
	elseif self._recoil_kick.to_reduce then
		self._recoil_kick.current = nil
		local n = math.lerp(self._recoil_kick.to_reduce, 0, 9 * dt)
		r_value = -(self._recoil_kick.to_reduce - n)
		self._recoil_kick.to_reduce = n

		if self._recoil_kick.to_reduce == 0 then
			self._recoil_kick.to_reduce = nil
		end
	end

	return r_value
end

function FPCameraPlayerBase:_horizonatal_recoil_kick(t, dt)
	local player_state = managers.player:current_state()

	if player_state == "bipod" then
		return 0
	end

	local r_value = 0

	if self._recoil_kick.h.current and self._episilon < math.abs(self._recoil_kick.h.accumulated - self._recoil_kick.h.current) then
		local n = math.step(self._recoil_kick.h.current, self._recoil_kick.h.accumulated, 40 * dt)
		r_value = n - self._recoil_kick.h.current
		self._recoil_kick.h.current = n
	elseif self._recoil_wait then
		self._recoil_wait = self._recoil_wait - dt

		if self._recoil_wait < 0 then
			self._recoil_wait = nil
		end
	elseif self._recoil_kick.h.to_reduce then
		self._recoil_kick.h.current = nil
		local n = math.lerp(self._recoil_kick.h.to_reduce, 0, 5 * dt)
		r_value = -(self._recoil_kick.h.to_reduce - n)
		self._recoil_kick.h.to_reduce = n

		if self._recoil_kick.h.to_reduce == 0 then
			self._recoil_kick.h.to_reduce = nil
		end
	end

	return r_value
end

function FPCameraPlayerBase:_pc_look_function(stick_input, stick_input_multiplier, dt)
	return stick_input.x, stick_input.y
end

function FPCameraPlayerBase:_gamepad_look_function(stick_input, stick_input_multiplier, dt)
	if mvector3.length(stick_input) > self._tweak_data.look_speed_dead_zone * stick_input_multiplier.x then
		local x = stick_input.x
		local y = stick_input.y
		stick_input = Vector3(x / (1.3 - 0.3 * (1 - math.abs(y))), y / (1.3 - 0.3 * (1 - math.abs(x))), 0)
		local look_speed = self:_get_look_speed(stick_input, stick_input_multiplier, dt)
		local stick_input_x = stick_input.x * dt * look_speed
		local stick_input_y = stick_input.y * dt * look_speed

		return stick_input_x, stick_input_y
	end

	return 0, 0
end

local multiplier = Vector3()

function FPCameraPlayerBase:_gamepad_look_function_ctl(stick_input, stick_input_multiplier, dt, unscaled_stick_input)
	local aim_assist_x = 0
	local aim_assist_y = 0
	local cs = managers.player:current_state()
	local aim_assist = false

	if (cs == "standard" or cs == "carry" or cs == "bipod") and managers.controller:get_default_wrapper_type() ~= "pc" and managers.user:get_setting("sticky_aim") then
		aim_assist = true
	end

	local dz = self._tweak_data.look_speed_dead_zone
	local length = mvector3.length(unscaled_stick_input)

	if dz < length then
		mvector3.set(multiplier, stick_input_multiplier)

		if multiplier.x - 1 > 0.001 then
			mvector3.set_x(multiplier, 1 + 1.6 * (multiplier.x - 1) / ((tweak_data.player.camera.MAX_SENSITIVITY - tweak_data.player.camera.MIN_SENSITIVITY) * 0.5))
		end

		if multiplier.y - 1 > 0.001 then
			mvector3.set_y(multiplier, 1 + 1.6 * (multiplier.y - 1) / ((tweak_data.player.camera.MAX_SENSITIVITY - tweak_data.player.camera.MIN_SENSITIVITY) * 0.5))
		end

		if aim_assist then
			aim_assist_x, aim_assist_y = self:_get_aim_assist(0, dt, self._tweak_data.aim_assist_look_speed, self._aim_assist_sticky)
		end

		local x = unscaled_stick_input.x
		local y = unscaled_stick_input.y
		x = x / length
		y = y / length
		length = math.min(length, 1)
		local scale = (length - dz) / (1 - dz)
		x = x * scale
		y = y * scale
		unscaled_stick_input = Vector3(x, y, 0)
		local look_speed_x, look_speed_y = self:_get_look_speed_ctl(unscaled_stick_input, multiplier, dt)
		look_speed_y = look_speed_x
		look_speed_x = look_speed_x * multiplier.x
		look_speed_y = look_speed_y * multiplier.y
		local stick_input_x = unscaled_stick_input.x * dt * look_speed_x
		local stick_input_y = unscaled_stick_input.y * dt * look_speed_y
		local look = Vector3(stick_input_x, stick_input_y, 0)

		if aim_assist then
			local len = mvector3.length(look)
			look = Vector3(look.x + aim_assist_x, look.y, 0)

			if length < 0.08 then
				mvector3.normalize(look)

				look = look * len
			end
		end

		return look.x, look.y
	end

	if aim_assist then
		aim_assist_x, aim_assist_y = self:_get_aim_assist(0, dt, self._tweak_data.aim_assist_move_speed, self._aim_assist_sticky)
		local move = math.abs(self._parent_unit:movement()._current_state._stick_move.x)

		if self._tweak_data.aim_assist_move_th_min <= move and move <= self._tweak_data.aim_assist_move_th_max then
			return aim_assist_x, 0
		end
	end

	return 0, 0
end

function FPCameraPlayerBase:_steampad_look_function(stick_input, stick_input_multiplier, dt)
	if mvector3.length(stick_input) > self._tweak_data.look_speed_dead_zone * stick_input_multiplier.x then
		local x = stick_input.x
		local y = stick_input.y
		local look_speed = self._tweak_data.look_speed_standard * (alive(self._parent_unit) and self._parent_unit:base():controller():get_input_bool("change_sensitivity") and 1 or 0.5)
		local stick_input_x = x * dt * look_speed
		local stick_input_y = y * dt * look_speed

		return stick_input_x, stick_input_y
	end

	return 0, 0
end

function FPCameraPlayerBase:_get_look_speed(stick_input, stick_input_multiplier, dt)
	if self._parent_unit:movement()._current_state:in_steelsight() then
		return self._tweak_data.look_speed_steel_sight
	end

	if mvector3.length(stick_input) <= self._tweak_data.look_speed_transition_occluder * stick_input_multiplier.x or math.abs(stick_input.x) <= self._tweak_data.look_speed_transition_zone * stick_input_multiplier.x then
		self._camera_properties.look_speed_transition_timer = 0

		return self._tweak_data.look_speed_standard
	end

	if self._camera_properties.look_speed_transition_timer >= 1 then
		return self._tweak_data.look_speed_fast
	end

	local p1 = self._tweak_data.look_speed_standard
	local p2 = self._tweak_data.look_speed_standard
	local p3 = self._tweak_data.look_speed_standard + (self._tweak_data.look_speed_fast - self._tweak_data.look_speed_standard) / 3 * 2
	local p4 = self._tweak_data.look_speed_fast
	self._camera_properties.look_speed_transition_timer = self._camera_properties.look_speed_transition_timer + dt / self._tweak_data.look_speed_transition_to_fast

	return math.bezier({
		p1,
		p2,
		p3,
		p4
	}, self._camera_properties.look_speed_transition_timer)
end

local function get_look_setting(a, b, c, t)
	if t < 0.5 then
		return math.lerp(a, b, t / 0.5)
	end

	return math.lerp(b, c, (t - 0.5) / 0.5)
end

local function get_look_setting_x_y(a, b, c, x, y)
	return get_look_setting(a, b, c, x), get_look_setting(a, b, c, y)
end

function FPCameraPlayerBase:_get_look_speed_ctl(stick_input, stick_input_multiplier, dt)
	if self._parent_unit:movement()._current_state:in_steelsight() then
		return self._tweak_data.look_speed_steel_sight
	end

	if self._tweak_data.look_speed_transition_occluder >= mvector3.length(stick_input) or self._tweak_data.look_speed_transition_zone >= math.abs(stick_input.x) then
		self._camera_properties.look_speed_transition_timer = 0

		return self._tweak_data.look_speed_standard
	end

	if self._camera_properties.look_speed_transition_timer >= 1 then
		return self._tweak_data.look_speed_fast
	end

	local p1 = self._tweak_data.look_speed_standard
	local p2 = self._tweak_data.look_speed_standard
	local p3 = self._tweak_data.look_speed_standard + (self._tweak_data.look_speed_fast - self._tweak_data.look_speed_standard) / 3 * 2
	local p4 = self._tweak_data.look_speed_fast
	self._camera_properties.look_speed_transition_timer = self._camera_properties.look_speed_transition_timer + dt / self._tweak_data.look_speed_transition_to_fast

	return math.bezier({
		p1,
		p2,
		p3,
		p4
	}, self._camera_properties.look_speed_transition_timer)
end

function FPCameraPlayerBase:_calculate_soft_velocity_overshot(dt)
	local stick_input = self._input.look
	local vel_overshot = self._vel_overshot

	if not stick_input then
		return
	end

	local input_yaw, input_pitch, input_x, input_z = nil
	local mul = self._tweak_data.uses_keyboard and 0.002 / dt or 0.4

	if stick_input.x >= 0 then
		local stick_input_x = math.pow(math.abs(math.clamp(mul * stick_input.x, 0, 1)), 1.5) * math.sign(stick_input.x)
		input_yaw = stick_input_x * vel_overshot.yaw_pos
	else
		local stick_input_x = math.pow(math.abs(math.clamp(mul * stick_input.x, -1, 0)), 1.5)
		input_yaw = stick_input_x * vel_overshot.yaw_neg
	end

	local last_yaw = vel_overshot.last_yaw
	local sign_in_yaw = math.sign(input_yaw)
	local abs_in_yaw = math.abs(input_yaw)
	local sign_last_yaw = math.sign(last_yaw)
	local abs_last_yaw = math.abs(last_yaw)
	local step_v = self._tweak_data.uses_keyboard and 120 * dt or 2
	vel_overshot.target_yaw = math.step(vel_overshot.target_yaw, input_yaw, step_v)
	local final_yaw = nil
	local diff = math.abs(vel_overshot.target_yaw - last_yaw)
	local diff_clamp = 40
	local diff_ratio = math.pow(diff / diff_clamp, 1)
	local diff_ratio_clamped = math.clamp(diff_ratio, 0, 1)
	local step_amount = math.lerp(3, 180, diff_ratio_clamped) * dt
	final_yaw = math.step(last_yaw, vel_overshot.target_yaw, step_amount)
	vel_overshot.last_yaw = final_yaw
	local mul = self._tweak_data.uses_keyboard and 0.002 / dt or 0.4

	if stick_input.y >= 0 then
		local stick_input_y = math.pow(math.abs(math.clamp(mul * stick_input.y, 0, 1)), 1.5) * math.sign(stick_input.y)
		input_pitch = stick_input_y * vel_overshot.pitch_pos
	else
		local stick_input_y = math.pow(math.abs(math.clamp(mul * stick_input.y, -1, 0)), 1.5)
		input_pitch = stick_input_y * vel_overshot.pitch_neg
	end

	local last_pitch = vel_overshot.last_pitch
	local sign_in_pitch = math.sign(input_pitch)
	local abs_in_pitch = math.abs(input_pitch)
	local sign_last_pitch = math.sign(last_pitch)
	local abs_last_pitch = math.abs(last_pitch)
	local step_v = self._tweak_data.uses_keyboard and 120 * dt or 2
	vel_overshot.target_pitch = math.step(vel_overshot.target_pitch, input_pitch, step_v)
	local final_pitch = nil
	local diff = math.abs(vel_overshot.target_pitch - last_pitch)
	local diff_clamp = 40
	local diff_ratio = math.pow(diff / diff_clamp, 1)
	local diff_ratio_clamped = math.clamp(diff_ratio, 0, 1)
	local step_amount = math.lerp(3, 180, diff_ratio_clamped) * dt
	final_pitch = math.step(last_pitch, vel_overshot.target_pitch, step_amount)
	vel_overshot.last_pitch = final_pitch

	mrotation.set_yaw_pitch_roll(vel_overshot.rotation, final_yaw, final_pitch, -final_yaw)

	local pivot = vel_overshot.pivot
	local new_root = mvec3

	mvector3.set(new_root, pivot)
	mvector3.negate(new_root)
	mvector3.rotate_with(new_root, vel_overshot.rotation)
	mvector3.add(new_root, pivot)
	mvector3.set(vel_overshot.translation, new_root)
end

function FPCameraPlayerBase:set_position(pos)
	self._unit:set_position(pos)
end

function FPCameraPlayerBase:set_rotation(rot)
	self._unit:set_rotation(rot)
end

function FPCameraPlayerBase:eye_position()
	return self._obj_eye:position()
end

function FPCameraPlayerBase:eye_rotation()
	return self._obj_eye:rotation()
end

function FPCameraPlayerBase:play_redirect(redirect_name, speed, offset_time)
	self:set_anims_enabled(true)

	self._anim_empty_state_wanted = false
	local result = self._unit:play_redirect(redirect_name, offset_time)

	if result == self.IDS_NOSTRING then
		return false
	end

	if speed then
		self._unit:anim_state_machine():set_speed(result, speed)
	end

	return result
end

function FPCameraPlayerBase:play_redirect_timeblend(state, redirect_name, offset_time, t)
	self:set_anims_enabled(true)

	self._anim_empty_state_wanted = false

	self._unit:anim_state_machine():set_parameter(state, "t", t)

	local result = self._unit:play_redirect(redirect_name, offset_time)

	if result == self.IDS_NOSTRING then
		return false
	end

	return result
end

function FPCameraPlayerBase:play_raw(name, params)
	self:set_anims_enabled(true)

	self._anim_empty_state_wanted = false
	local asm = self._unit:anim_state_machine()
	local result = asm:play_raw(name, params)

	return result ~= self.IDS_NOSTRING and result
end

function FPCameraPlayerBase:set_steelsight_anim_enabled(enabled)
	self._steelsight_anims_enabled = enabled

	self:_check_play_empty_state()
end

function FPCameraPlayerBase:play_state(state_name)
	self:set_anims_enabled(true)

	self._anim_empty_state_wanted = false
	local result = self._unit:play_state(Idstring(state_name))

	return result ~= self.IDS_NOSTRING and result
end

function FPCameraPlayerBase:set_target_tilt(tilt)
	self._camera_properties.target_tilt = tilt
end

function FPCameraPlayerBase:set_lean_values(lean_position, lean_rotation)
	self._camera_properties.lean_position = lean_position
	self._camera_properties.lean_rotation = lean_rotation
end

function FPCameraPlayerBase:set_camera_offset(camera_offset)
	self._camera_properties.camera_offset = camera_offset
end

function FPCameraPlayerBase:set_stance_instant(stance_name)
	local new_stance = tweak_data.player.stances.default[stance_name].shoulders

	if new_stance then
		self._shoulder_stance.transition = nil
		self._shoulder_stance.translation = mvector3.copy(new_stance.translation)
		self._shoulder_stance.rotation = new_stance.rotation
	end

	local new_stance = tweak_data.player.stances.default[stance_name].head

	if new_stance then
		self._head_stance.transition = nil
		self._head_stance.translation = mvector3.copy(new_stance.translation)
		self._head_stance.rotation = new_stance.rotation
	end

	local new_overshot = tweak_data.player.stances.default[stance_name].vel_overshot

	if new_overshot then
		self._vel_overshot.transition = nil
		self._vel_overshot.yaw_neg = new_overshot.yaw_neg
		self._vel_overshot.yaw_pos = new_overshot.yaw_pos
		self._vel_overshot.pitch_neg = new_overshot.pitch_neg
		self._vel_overshot.pitch_pos = new_overshot.pitch_pos
		self._vel_overshot.pivot = mvector3.copy(new_overshot.pivot)
	end

	self:set_stance_fov_instant(stance_name)
end

function FPCameraPlayerBase:is_stance_done()
	return not self._shoulder_stance.transition and not self._head_stance.transition and not self._vel_overshot.transition
end

function FPCameraPlayerBase:set_fov_instant(new_fov)
	if new_fov then
		self._fov.transition = nil
		self._fov.fov = new_fov
		self._fov.dirty = true

		if Application:paused() then
			self._parent_unit:camera():set_FOV(self._fov.fov)
		end
	end
end

function FPCameraPlayerBase:set_stance_fov_instant(stance_name)
	local new_fov = tweak_data.player.stances.default[stance_name].zoom_fov and managers.user:get_setting("fov_zoom") or managers.user:get_setting("fov_standard")

	if new_fov then
		self._fov.transition = nil
		self._fov.fov = new_fov
		self._fov.dirty = true

		if Application:paused() then
			self._parent_unit:camera():set_FOV(self._fov.fov)
		end
	end
end

function FPCameraPlayerBase:clbk_stance_entered(new_shoulder_stance, new_head_stance, new_vel_overshot, new_fov, new_shakers, stance_mod, duration_multiplier, duration)
	local t = managers.player:player_timer():time()

	if new_shoulder_stance then
		local transition = {}
		self._shoulder_stance.transition = transition
		transition.end_translation = new_shoulder_stance.translation + (stance_mod.translation or Vector3())
		transition.end_rotation = new_shoulder_stance.rotation * (stance_mod.rotation or Rotation())
		transition.start_translation = mvector3.copy(self._shoulder_stance.translation)
		transition.start_rotation = self._shoulder_stance.rotation
		transition.start_t = t
		transition.duration = duration * duration_multiplier
	end

	if new_head_stance then
		local transition = {}
		self._head_stance.transition = transition
		transition.end_translation = new_head_stance.translation
		transition.end_rotation = new_head_stance.rotation
		transition.start_translation = mvector3.copy(self._head_stance.translation)
		transition.start_rotation = self._head_stance.rotation
		transition.start_t = t
		transition.duration = duration * duration_multiplier
	end

	if new_vel_overshot then
		local transition = {}
		self._vel_overshot.transition = transition
		transition.end_pivot = new_vel_overshot.pivot
		transition.end_yaw_neg = new_vel_overshot.yaw_neg
		transition.end_yaw_pos = new_vel_overshot.yaw_pos
		transition.end_pitch_neg = new_vel_overshot.pitch_neg
		transition.end_pitch_pos = new_vel_overshot.pitch_pos
		transition.start_pivot = mvector3.copy(self._vel_overshot.pivot)
		transition.start_yaw_neg = self._vel_overshot.yaw_neg
		transition.start_yaw_pos = self._vel_overshot.yaw_pos
		transition.start_pitch_neg = self._vel_overshot.pitch_neg
		transition.start_pitch_pos = self._vel_overshot.pitch_pos
		transition.start_t = t
		transition.duration = duration * duration_multiplier
	end

	if new_fov then
		if new_fov == self._fov.fov then
			self._fov.transition = nil
		else
			local transition = {}
			self._fov.transition = transition
			transition.end_fov = new_fov
			transition.start_fov = self._fov.fov
			transition.start_t = t
			transition.duration = duration * duration_multiplier
		end
	end

	if new_shakers then
		for effect, values in pairs(new_shakers) do
			for parameter, value in pairs(values) do
				self._parent_unit:camera():set_shaker_parameter(effect, parameter, value)
			end
		end
	end
end

function FPCameraPlayerBase:_start_aim_assist(col_ray, aim_data)
	if col_ray then
		local ray = col_ray.ray
		local r1 = self._parent_unit:camera():rotation()
		local r2 = aim_data.mrotation or Rotation()

		mrotation.set_look_at(r2, ray, r1:z())

		local yaw = mrotation.yaw(r1) - mrotation.yaw(r2)
		local pitch = mrotation.pitch(r1) - mrotation.pitch(r2)

		if yaw > 180 then
			yaw = 360 - yaw
		elseif yaw < -180 then
			yaw = 360 + yaw
		end

		if pitch > 180 then
			pitch = 360 - pitch
		elseif pitch < -180 then
			pitch = 360 + pitch
		end

		mvector3.set_static(aim_data.direction, yaw, -pitch, 0)

		aim_data.distance = mvector3.normalize(aim_data.direction)
		aim_data.target_distance = col_ray.distance
		aim_data.distance_to_aim_line = col_ray.distance_to_aim_line
	end
end

function FPCameraPlayerBase:_stop_aim_assist(aim_data)
	mvector3.set_static(aim_data.direction, 0, 0, 0)

	aim_data.distance = 0
	aim_data.target_distance = 0
	aim_data.distance_to_aim_line = 0
end

function FPCameraPlayerBase:_update_aim_assist_sticky(t, dt)
	if managers.controller:get_default_wrapper_type() ~= "pc" and managers.user:get_setting("sticky_aim") then
		local weapon = self._parent_unit:inventory():equipped_unit()
		local player_state = self._parent_unit:movement():current_state()

		if weapon then
			local closest_ray = weapon:base():get_aim_assist(player_state:get_fire_weapon_position(), player_state:get_fire_weapon_direction(), nil, true)

			self:_start_aim_assist(closest_ray, self._aim_assist_sticky)
		else
			self:_stop_aim_assist(self._aim_assist_sticky)
		end
	end
end

function FPCameraPlayerBase:clbk_aim_assist(col_ray)
	self:_start_aim_assist(col_ray, self._aim_assist)
end

function FPCameraPlayerBase:clbk_stop_aim_assist()
	self:_stop_aim_assist(self._aim_assist)
end

function FPCameraPlayerBase:animate_fov(new_fov, duration_multiplier)
	if new_fov == self._fov.fov then
		self._fov.transition = nil
	else
		local transition = {}
		self._fov.transition = transition
		transition.end_fov = new_fov
		transition.start_fov = self._fov.fov
		transition.start_t = managers.player:player_timer():time()
		transition.duration = 0.23 * (duration_multiplier or 1)
	end
end

function FPCameraPlayerBase:anim_clbk_idle_full_blend()
	self._anim_empty_state_wanted = true

	self:_check_play_empty_state()
end

function FPCameraPlayerBase:_check_play_empty_state()
	if not self._anim_empty_state_wanted then
		return
	end

	if self._steelsight_anims_enabled then
		return
	end

	self:play_redirect(self.IDS_EMPTY)
end

function FPCameraPlayerBase:anim_clbk_idle_exit()
end

function FPCameraPlayerBase:anim_clbk_empty_enter()
	self._playing_empty_state = true
end

function FPCameraPlayerBase:anim_clbk_empty_exit()
	self._playing_empty_state = false
end

function FPCameraPlayerBase:playing_empty_state()
	return self._playing_empty_state
end

function FPCameraPlayerBase:anim_clbk_empty_full_blend()
	self._playing_empty_state = false

	self:set_anims_enabled(false)
end

function FPCameraPlayerBase:set_handcuff_units(units)
	self._handcuff_units = units
end

function FPCameraPlayerBase:anim_clbk_spawn_handcuffs()
	if not self._handcuff_units then
		local align_obj_l_name = Idstring("a_weapon_left")
		local align_obj_r_name = Idstring("a_weapon_right")
		local align_obj_l = self._unit:get_object(align_obj_l_name)
		local align_obj_r = self._unit:get_object(align_obj_r_name)
		local handcuff_unit_name = Idstring("units/equipment/handcuffs_first_person/handcuffs_first_person")
		local handcuff_unit_l = World:spawn_unit(handcuff_unit_name, align_obj_l:position(), align_obj_l:rotation())
		local handcuff_unit_r = World:spawn_unit(handcuff_unit_name, align_obj_r:position(), align_obj_r:rotation())

		self._unit:link(align_obj_l_name, handcuff_unit_l, handcuff_unit_l:orientation_object():name())
		self._unit:link(align_obj_r_name, handcuff_unit_r, handcuff_unit_r:orientation_object():name())

		local handcuff_units = {
			handcuff_unit_l,
			handcuff_unit_r
		}

		self:set_handcuff_units(handcuff_units)
	end
end

function FPCameraPlayerBase:anim_clbk_unspawn_handcuffs()
	if self._handcuff_units then
		for _, handcuff_unit in pairs(self._handcuff_units) do
			if alive(handcuff_unit) then
				handcuff_unit:set_visible(false)
				handcuff_unit:set_slot(0)
			end
		end
	end

	self:set_handcuff_units(nil)
end

function FPCameraPlayerBase:get_weapon_offsets()
	local weapon = self._parent_unit:inventory():equipped_unit()
	local object = weapon:get_object(Idstring("a_sight"))

	print((object:position() - self._unit:position()):rotate_HP(self._unit:rotation():inverse()))
	print(self._unit:rotation():inverse() * object:rotation())
end

function FPCameraPlayerBase:set_anims_enabled(state)
	if state ~= self._anims_enabled then
		self._unit:set_animations_enabled(state)

		self._anims_enabled = state
	end
end

function FPCameraPlayerBase:anims_enabled()
	return self._anims_enabled
end

function FPCameraPlayerBase:play_sound(unit, event)
	if alive(self._parent_unit) then
		self._parent_unit:sound():play(event)
	end
end

function FPCameraPlayerBase:play_melee_sound(unit, sound_id)
	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local tweak_data = tweak_data.blackmarket.melee_weapons[melee_entry]

	if not tweak_data.sounds or not tweak_data.sounds[sound_id] then
		return
	end

	if alive(self._parent_unit) then
		self._parent_unit:sound():play(tweak_data.sounds[sound_id], nil, false)
	end
end

function FPCameraPlayerBase:set_limits(spin, pitch)
	self._limits = {}

	if spin then
		self._limits.spin = {
			mid = self._camera_properties.spin,
			offset = spin
		}
	end

	if pitch then
		self._limits.pitch = {
			mid = self._camera_properties.pitch,
			offset = pitch
		}
	end
end

function FPCameraPlayerBase:remove_limits()
	self._limits = nil
end

function FPCameraPlayerBase:throw_projectile(unit)
	self:unspawn_grenade()

	if alive(self._parent_unit) then
		self._parent_unit:equipment():throw_projectile()
	end
end

function FPCameraPlayerBase:throw_grenade(unit)
	self:unspawn_grenade()

	if alive(self._parent_unit) then
		self._parent_unit:equipment():throw_grenade()
	end
end

function FPCameraPlayerBase:spawn_grenade()
	if alive(self._grenade_unit) then
		return
	end

	local align_obj_l_name = Idstring("a_weapon_left")
	local align_obj_r_name = Idstring("a_weapon_right")
	local align_obj_l = self._unit:get_object(align_obj_l_name)
	local align_obj_r = self._unit:get_object(align_obj_r_name)
	local grenade_entry = managers.blackmarket:equipped_grenade()
	self._grenade_unit = World:spawn_unit(Idstring(tweak_data.blackmarket.projectiles[grenade_entry].unit_dummy), align_obj_r:position(), align_obj_r:rotation())

	self._unit:link(align_obj_r:name(), self._grenade_unit, self._grenade_unit:orientation_object():name())
end

function FPCameraPlayerBase:unspawn_grenade()
	if alive(self._grenade_unit) then
		self._grenade_unit:unlink()
		World:delete_unit(self._grenade_unit)

		self._grenade_unit = nil
	end
end

function FPCameraPlayerBase:play_anim_melee_item(tweak_name)
	if not self._melee_item_units then
		return
	end

	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local anims = tweak_data.blackmarket.melee_weapons[melee_entry].anims
	local anim_data = anims and anims[tweak_name]

	if not anim_data then
		return
	end

	if self._melee_item_anim then
		for _, unit in ipairs(self._melee_item_units) do
			unit:anim_stop(self._melee_item_anim)
		end

		self._melee_item_anim = nil
	end

	local ids = anim_data.anim and Idstring(anim_data.anim)

	if ids then
		for _, unit in ipairs(self._melee_item_units) do
			local length = unit:anim_length(ids)

			if anim_data.loop then
				unit:anim_play_loop(ids, 0, length, 1)
			else
				unit:anim_play_to(ids, length, 1)
			end
		end

		self._melee_item_anim = ids
	end
end

function FPCameraPlayerBase:spawn_melee_item()
	if self._melee_item_units then
		return
	end

	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local unit_name = tweak_data.blackmarket.melee_weapons[melee_entry].unit

	if unit_name then
		local aligns = tweak_data.blackmarket.melee_weapons[melee_entry].align_objects or {
			"a_weapon_left"
		}
		local graphic_objects = tweak_data.blackmarket.melee_weapons[melee_entry].graphic_objects or {}
		self._melee_item_units = {}

		for _, align in ipairs(aligns) do
			local align_obj_name = Idstring(align)
			local align_obj = self._unit:get_object(align_obj_name)
			local unit = World:spawn_unit(Idstring(unit_name), align_obj:position(), align_obj:rotation())

			unit:anim_stop()
			self._unit:link(align_obj:name(), unit, unit:orientation_object():name())

			for a_object, g_object in pairs(graphic_objects) do
				local graphic_obj_name = Idstring(g_object)
				local graphic_obj = unit:get_object(graphic_obj_name)

				graphic_obj:set_visibility(Idstring(a_object) == align_obj_name)
			end

			if alive(unit) and unit:damage() and unit:damage():has_sequence("game") then
				unit:damage():run_sequence_simple("game")
			end

			table.insert(self._melee_item_units, unit)
		end

		self:play_anim_melee_item("charge")
	end
end

function FPCameraPlayerBase:unspawn_melee_item()
	if not self._melee_item_units then
		return
	end

	for _, unit in ipairs(self._melee_item_units) do
		if alive(unit) then
			unit:unlink()
			World:delete_unit(unit)
		end
	end

	self._melee_item_units = nil
	self._melee_item_anim = nil
end

function FPCameraPlayerBase:hide_weapon()
	if alive(self._parent_unit) then
		self._parent_unit:inventory():hide_equipped_unit()
	end
end

function FPCameraPlayerBase:show_weapon()
	if alive(self._parent_unit) then
		self._parent_unit:inventory():show_equipped_unit()
	end
end

function FPCameraPlayerBase:enter_shotgun_reload_loop(unit, state, ...)
	if alive(self._parent_unit) then
		local speed_multiplier = self._parent_unit:inventory():equipped_unit():base():reload_speed_multiplier()

		self._unit:anim_state_machine():set_speed(Idstring(state), speed_multiplier)
	end
end

function FPCameraPlayerBase:spawn_mask()
	if not self._mask_unit then
		local align_obj_l_name = Idstring("a_weapon_left")
		local align_obj_r_name = Idstring("a_weapon_right")
		local align_obj_l = self._unit:get_object(align_obj_l_name)
		local align_obj_r = self._unit:get_object(align_obj_r_name)
		local mask_unit_name = "units/payday2/masks/fps_temp_dallas/temp_mask_dallas"
		local equipped_mask = managers.blackmarket:equipped_mask()
		local peer_id = managers.network:session():local_peer():id()
		local blueprint = nil
		local mask_id = equipped_mask.mask_id and managers.blackmarket:get_real_mask_id(equipped_mask.mask_id, peer_id)

		if mask_id then
			mask_unit_name = managers.blackmarket:mask_unit_name_by_mask_id(mask_id, peer_id)
			blueprint = equipped_mask.blueprint
		else
			mask_unit_name = tweak_data.blackmarket.masks[equipped_mask].unit
		end

		self._mask_unit = World:spawn_unit(Idstring(mask_unit_name), align_obj_r:position(), align_obj_r:rotation())
		local glass_id_string = Idstring("glass")
		local mtr_hair_solid_id_string = Idstring("mtr_hair_solid")
		local mtr_hair_effect_id_string = Idstring("mtr_hair_effect")
		local mtr_bloom_glow_id_string = Idstring("mtr_bloom_glow")
		local mtr_opacity = Idstring("mtr_opacity")
		local mtr_feathers = Idstring("mtr_feathers")
		local glow_id_strings = {}

		for i = 1, 5 do
			glow_id_strings[Idstring("glow" .. tostring(i)):key()] = true
		end

		local sweep_id_strings = {}

		for i = 1, 5 do
			sweep_id_strings[Idstring("sweep" .. tostring(i)):key()] = true
		end

		for _, material in ipairs(self._mask_unit:get_objects_by_type(Idstring("material"))) do
			if material:name() == glass_id_string then
				material:set_render_template(Idstring("opacity:CUBE_ENVIRONMENT_MAPPING:CUBE_FRESNEL:DIFFUSE_TEXTURE:FPS"))
			elseif material:name() == mtr_hair_solid_id_string then
				-- Nothing
			elseif material:name() == mtr_opacity then
				-- Nothing
			elseif material:name() == mtr_feathers then
				-- Nothing
			elseif material:name() == mtr_hair_effect_id_string then
				-- Nothing
			elseif material:name() == mtr_bloom_glow_id_string then
				material:set_render_template(Idstring("generic:DEPTH_SCALING:DIFFUSE_TEXTURE:SELF_ILLUMINATION:SELF_ILLUMINATION_BLOOM"))
			elseif glow_id_strings[material:name():key()] then
				material:set_render_template(Idstring("effect:BLEND_ADD:DIFFUSE0_TEXTURE"))
			elseif sweep_id_strings[material:name():key()] then
				material:set_render_template(Idstring("effect:BLEND_ADD:DIFFUSE0_TEXTURE:DIFFUSE0_THRESHOLD_SWEEP"))
			else
				material:set_render_template(Idstring("solid_mask:DEPTH_SCALING"))
			end
		end

		if blueprint then
			print("FPCameraPlayerBase:spawn_mask", inspect(blueprint))
			self._mask_unit:base():apply_blueprint(blueprint)
		end

		print(inspect(self._mask_unit:get_objects_by_type(Idstring("material"))))
		self._mask_unit:set_timer(managers.player:player_timer())
		self._mask_unit:set_animation_timer(managers.player:player_timer())
		self._mask_unit:anim_stop()

		if not tweak_data.blackmarket.masks[mask_id].type then
			local backside = World:spawn_unit(Idstring("units/payday2/masks/msk_fps_back_straps/msk_fps_back_straps"), align_obj_r:position(), align_obj_r:rotation())

			for _, material in ipairs(backside:get_objects_by_type(Idstring("material"))) do
				material:set_render_template(Idstring("generic:DEPTH_SCALING:DIFFUSE_TEXTURE:NORMALMAP:SKINNED_3WEIGHTS"))
			end

			backside:set_timer(managers.player:player_timer())
			backside:set_animation_timer(managers.player:player_timer())
			backside:anim_play(Idstring("mask_on"))
			self._mask_unit:link(self._mask_unit:orientation_object():name(), backside, backside:orientation_object():name())
		end

		self._unit:link(align_obj_l:name(), self._mask_unit, self._mask_unit:orientation_object():name())
	end
end

function FPCameraPlayerBase:relink_mask()
end

function FPCameraPlayerBase:unspawn_mask()
	if alive(self._mask_unit) then
		for _, linked_unit in ipairs(self._mask_unit:children()) do
			linked_unit:unlink()
			World:delete_unit(linked_unit)
		end

		self._mask_unit:unlink()

		local name = self._mask_unit:name()

		World:delete_unit(self._mask_unit)

		self._mask_unit = nil
	end
end

function FPCameraPlayerBase:counter_taser()
	local current_state = self._parent_movement_ext._current_state

	if current_state and current_state.give_shock_to_taser then
		current_state:give_shock_to_taser()

		if alive(self._taser_hooks_unit) then
			local align_obj = self._unit:get_object(Idstring("a_weapon_right"))

			World:effect_manager():spawn({
				effect = Idstring("effects/payday2/particles/character/taser_stop"),
				position = align_obj:position(),
				normal = align_obj:rotation():y()
			})
		end
	end
end

function FPCameraPlayerBase:spawn_taser_hooks()
	if not alive(self._taser_hooks_unit) and alive(self._parent_unit) then
		local hooks_align = self._unit:get_object(Idstring("a_weapon_right"))
		local taser_hooks_unit_name = "units/payday2/weapons/wpn_fps_taser_hooks/wpn_fps_taser_hooks"

		managers.dyn_resource:load(Idstring("unit"), Idstring(taser_hooks_unit_name), DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)

		self._taser_hooks_unit = World:spawn_unit(Idstring(taser_hooks_unit_name), hooks_align:position(), hooks_align:rotation())

		self._taser_hooks_unit:set_timer(managers.player:player_timer())
		self._taser_hooks_unit:set_animation_timer(managers.player:player_timer())
		self._taser_hooks_unit:anim_play(Idstring("taser_hooks"))
		self._unit:link(hooks_align:name(), self._taser_hooks_unit, self._taser_hooks_unit:orientation_object():name())
	end
end

function FPCameraPlayerBase:unspawn_taser_hooks()
	if alive(self._taser_hooks_unit) then
		self._taser_hooks_unit:unlink()

		local name = self._taser_hooks_unit:name()

		World:delete_unit(self._taser_hooks_unit)
		managers.dyn_resource:unload(Idstring("unit"), name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)

		self._taser_hooks_unit = nil
	end
end

function FPCameraPlayerBase:end_tase()
	local current_state = self._parent_movement_ext._current_state

	if current_state and current_state.clbk_exit_to_std then
		current_state:clbk_exit_to_std()
	end
end

function FPCameraPlayerBase:anim_clbk_check_bullet_object()
	if alive(self._parent_unit) then
		local weapon = self._parent_unit:inventory():equipped_unit()

		if alive(weapon) then
			weapon:base():predict_bullet_objects()
		end
	end
end

function FPCameraPlayerBase:anim_clbk_stop_weapon_reload()
	if alive(self._parent_unit) then
		local weapon = self._parent_unit:inventory():equipped_unit()

		if alive(weapon) then
			weapon:base():tweak_data_anim_stop("reload")
			weapon:base():tweak_data_anim_stop("reload_not_empty")
		end
	end
end

function FPCameraPlayerBase:anim_clbk_play_weapon_anim(unit, anim, speed)
	if alive(self._parent_unit) then
		local weapon = self._parent_unit:inventory():equipped_unit()

		if alive(weapon) then
			weapon:base():tweak_data_anim_play(anim, speed)
		end
	end
end

function FPCameraPlayerBase:anim_clbk_stop_weapon_anim(unit, anim)
	if alive(self._parent_unit) then
		local weapon = self._parent_unit:inventory():equipped_unit()

		if alive(weapon) then
			weapon:base():tweak_data_anim_stop(anim)
		end
	end
end

function FPCameraPlayerBase:anim_clbk_stop_weapon_reload_all()
	if alive(self._parent_unit) then
		local weapon = self._parent_unit:inventory():equipped_unit()

		if alive(weapon) then
			weapon:base():tweak_data_anim_stop("reload_enter")
			weapon:base():tweak_data_anim_stop("reload_exit")
		end
	end
end

function FPCameraPlayerBase:anim_clbk_spawn_shotgun_shell()
	if alive(self._parent_unit) then
		local weapon = self._parent_unit:inventory():equipped_unit()

		if alive(weapon) and weapon:base().shotgun_shell_data then
			local shotgun_shell_data = weapon:base():shotgun_shell_data()

			if not shotgun_shell_data then
				return
			end

			local align_obj_l_name = Idstring("a_weapon_left")
			local align_obj_r_name = Idstring("a_weapon_right")
			local align_obj_l = self._unit:get_object(align_obj_l_name)
			local align_obj_r = self._unit:get_object(align_obj_r_name)
			local align_obj = align_obj_l

			if shotgun_shell_data.align and shotgun_shell_data.align == "right" then
				align_obj = align_obj_r
			end

			self:_unspawn_shotgun_shell()

			self._shell = World:spawn_unit(Idstring(shotgun_shell_data.unit_name), align_obj:position(), align_obj:rotation())

			self._unit:link(align_obj:name(), self._shell, self._shell:orientation_object():name())
		end
	end
end

function FPCameraPlayerBase:anim_clbk_unspawn_shotgun_shell()
	self:_unspawn_shotgun_shell()
end

function FPCameraPlayerBase:_unspawn_shotgun_shell()
	if not alive(self._shell) then
		return
	end

	self._shell:unlink()
	World:delete_unit(self._shell)

	self._shell = nil
end

function FPCameraPlayerBase:anim_clbk_stop_weapon_magazine_empty()
	if alive(self._parent_unit) then
		local weapon = self._parent_unit:inventory():equipped_unit()

		if alive(weapon) then
			weapon:base():tweak_data_anim_stop("magazine_empty")
		end
	end
end

function FPCameraPlayerBase:load_fps_mask_units()
	if not self._mask_backface_loaded then
		self._mask_backface_loaded = true
	end
end

function FPCameraPlayerBase:destroy()
	if self._parent_unit then
		self._parent_unit:base():remove_destroy_listener("FPCameraPlayerBase")
	end

	if self._light then
		World:delete_light(self._light)
	end

	if self._light_effect then
		World:effect_manager():kill(self._light_effect)

		self._light_effect = nil
	end

	self:anim_clbk_unspawn_handcuffs()
	self:unspawn_mask()
	self:unspawn_grenade()
	self:unspawn_melee_item()
	self:_unspawn_shotgun_shell()

	if self._mask_backface_loaded then
		self._mask_backface_loaded = nil
	end
end

function FPCameraPlayerBase:set_spin(_spin)
	self._camera_properties.spin = _spin
end

function FPCameraPlayerBase:set_pitch(_pitch)
	self._camera_properties.pitch = _pitch
end

function FPCameraPlayerBase:current_tilt()
	return self._camera_properties.current_tilt
end

function FPCameraPlayerBase:animate_pitch(start_t, start_pitch, end_pitch, total_duration)
	self._animate_pitch = {
		start_t = start_t,
		start_pitch = start_pitch or self._camera_properties.pitch,
		end_pitch = end_pitch,
		duration = total_duration
	}
end

function FPCameraPlayerBase:animate_pitch_upd()
	local t = Application:time()
	local elapsed_t = t - self._animate_pitch.start_t
	local step = elapsed_t / self._animate_pitch.duration

	if step > 1 then
		self._animate_pitch = nil
	else
		step = self:catmullrom(step, -10, 0, 1, 0.7)
		self._camera_properties.pitch = math.lerp(self._animate_pitch.start_pitch, self._animate_pitch.end_pitch, step)
	end
end

function FPCameraPlayerBase:update_tilt_smooth(direction, max_tilt, tilt_speed, dt)
	self._tilt_dt = self._tilt_dt or 0

	if direction < 0 and self._camera_properties.current_tilt <= 0 then
		self:set_target_tilt(-1 * self:smoothstep(0, max_tilt, self._tilt_dt, tilt_speed))

		if self._tilt_dt < tilt_speed then
			self._tilt_dt = self._tilt_dt + dt
		end
	elseif direction > 0 and self._camera_properties.current_tilt >= 0 then
		self:set_target_tilt(self:smoothstep(0, max_tilt, self._tilt_dt, tilt_speed))

		if self._tilt_dt < tilt_speed then
			self._tilt_dt = self._tilt_dt + dt
		end
	else
		self:set_target_tilt(math.sign(self._camera_properties.current_tilt) * self:smoothstep(0, max_tilt, self._tilt_dt, tilt_speed))

		if self._tilt_dt > 0 then
			self._tilt_dt = self._tilt_dt - 2 * dt

			if self._tilt_dt < 0 then
				self._tilt_dt = 0
			end
		end
	end
end

function FPCameraPlayerBase:catmullrom(t, p0, p1, p2, p3)
	return 0.5 * (2 * p1 + (-p0 + p2) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t * t + (-p0 + 3 * p1 - 3 * p2 + p3) * t * t * t)
end

function FPCameraPlayerBase:smoothstep(a, b, step, n)
	local v = step / n
	v = 1 - (1 - v) * (1 - v)
	local x = a * (1 - v) + b * v

	return x
end

function FPCameraPlayerBase:_update_fadeout(mover_position, head_position, rotation, t, dt)
	local ignore_head_collision = FPCameraPlayerBase.NO_FADEOUT or self._parent_movement_ext:warping() or self._parent_movement_ext:current_state_name() == "driving" or self._parent_movement_ext:on_zipline()
	local ignore_ghost_distance = FPCameraPlayerBase.NO_FADEOUT or self._parent_movement_ext:warping() or self._parent_movement_ext:on_zipline()

	if self._fadeout:update(mover_position, head_position, rotation, t, dt, ignore_head_collision, ignore_ghost_distance) then
		self._parent_movement_ext:reset_ghost_position()
	end
end

function FPCameraPlayerBase:set_hmd_tracking(enabled)
	self._hmd_tracking = enabled
end

function FPCameraPlayerBase:set_block_input(block)
	self._block_input = block
end

function FPCameraPlayerBase:reset_base_rotation(rot)
	self._base_rotation = Rotation(self._output_data.rotation:yaw(), 0, 0) * rot
end

function FPCameraPlayerBase:rotate_base(rot)
	self._base_rotation = self._base_rotation * rot
end

function FPCameraPlayerBase:set_base_rotation(rot)
	self._base_rotation = Rotation(self._base_rotation:yaw() - self._output_data.rotation:yaw(), 0, 0) * rot
end

function FPCameraPlayerBase:base_rotation()
	return self._base_rotation
end

function FPCameraPlayerBase:enter_vehicle()
	self._initial_hmd_rotation = VRManager:hmd_rotation()
end
