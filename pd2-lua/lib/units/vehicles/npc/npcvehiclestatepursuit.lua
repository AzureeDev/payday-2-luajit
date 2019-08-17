NpcVehicleStatePursuit = NpcVehicleStatePursuit or class(NpcBaseVehicleState)

function NpcVehicleStatePursuit:init(unit)
	NpcBaseVehicleState.init(self, unit)

	self._vehicle = self._unit:vehicle()
	self._next_checkpoint_distance = {
		{
			v_min = 30,
			distance = 1200,
			relative_angle_min = 30,
			relative_angle_max = 60,
			v_max = 40
		},
		{
			v_min = 40,
			distance = 1400,
			relative_angle_min = 30,
			relative_angle_max = 90,
			v_max = 60
		},
		{
			v_min = 60,
			distance = 2000,
			relative_angle_min = 30,
			relative_angle_max = 90,
			v_max = 90
		}
	}
	local cop_position = self._unit:position()
	local delayed_tick = Application:time() + 5
	self._tachograph = {
		distance = 0,
		timeframe = 1,
		tick_at = delayed_tick,
		last_pos = cop_position
	}
end

function NpcVehicleStatePursuit:on_enter(npc_driving_ext)
	print("Npc state change: ", self:name())

	local cop_position = self._unit:position()
	local delayed_tick = Application:time() + 5
	self._tachograph = {
		distance = 0,
		timeframe = 1,
		tick_at = delayed_tick,
		last_pos = cop_position
	}
	self._next_state = nil
	self._desired_direction = 0
end

function NpcVehicleStatePursuit:update(t, dt)
end

function NpcVehicleStatePursuit:name()
	return NpcVehicleDrivingExt.STATE_PURSUIT
end

function NpcVehicleStatePursuit:calc_steering(angle)
	self._desired_direction = angle
	local direction = 0
	local normalized_steer = 0
	local scale_steering = 1
	local final_steer = 0
	local FULL_TURN_ANGLE_THRESHOLD = 20

	if angle >= 0 and angle < 90 then
		direction = 1
		normalized_steer = math.clamp(angle / FULL_TURN_ANGLE_THRESHOLD, 0, 1)
		final_steer = normalized_steer * direction
	elseif angle >= 90 and angle < 180 then
		direction = 1
		final_steer = direction
	elseif angle >= 180 and angle < 270 then
		direction = -1
		final_steer = direction
	elseif angle >= 270 then
		direction = -1
		normalized_steer = math.clamp((90 - (angle - 270)) / FULL_TURN_ANGLE_THRESHOLD, 0, 1)
		final_steer = normalized_steer * direction
	end

	return final_steer
end

function NpcVehicleStatePursuit:calc_distance_threshold(angle)
	local vehicle_state = self._vehicle:get_state()
	local current_speed = vehicle_state:get_speed() * 3.6
	local threshold = 1000

	for _, data in ipairs(self._next_checkpoint_distance) do
		if data.v_min < current_speed and current_speed <= data.v_max and data.relative_angle_min < angle and angle <= data.relative_angle_max then
			threshold = data.distance
		end
	end

	return threshold
end

function NpcVehicleStatePursuit:calc_speed_limit(path, unit_and_pos)
	local default_speed_limit = path.default_speed_limit or -1
	local retval = default_speed_limit
	local points_in_direction = nil

	if not unit_and_pos.direction or unit_and_pos.direction == "fwd" then
		points_in_direction = path.points
	else
		points_in_direction = path.points_bck
	end

	local target_speed = points_in_direction[unit_and_pos.target_checkpoint].speed

	if target_speed ~= -1 then
		retval = target_speed / 27.77
	end

	return retval
end

function NpcVehicleStatePursuit:handle_hard_turn(npc_driving_ext, angle_to_target)
	local vehicle_state = self._vehicle:get_state()
	local current_speed = vehicle_state:get_speed() * 3.6

	if angle_to_target > 90 and current_speed > 20 then
		npc_driving_ext._current_drive_controls = "handbrake"
	elseif not self._last_checkpoint_reached then
		npc_driving_ext._current_drive_controls = "accelerate"
	end
end

function NpcVehicleStatePursuit:evasion_maneuvers(npc_driving_ext, target_steering)
	return self:_loco_unit_proximity(npc_driving_ext, target_steering)
end

function NpcVehicleStatePursuit:_loco_unit_proximity(npc_driving_ext, target_steering)
	local retval = nil
	local player_unit = npc_driving_ext:_get_target_unit()

	if not player_unit then
		return retval
	end

	local player_position = player_unit:position()
	local cop_position = self._unit:position()
	local distance_to_player = math.abs((player_position - cop_position):length()) / 100
	local acceleration = 0
	local brake = 0
	local handbrake = 0

	if npc_driving_ext._drive_mode and npc_driving_ext._drive_mode[npc_driving_ext._current_drive_mode] then
		acceleration = npc_driving_ext._drive_mode[npc_driving_ext._current_drive_mode].acceleration
		brake = npc_driving_ext._drive_mode[npc_driving_ext._current_drive_mode].brake
		handbrake = npc_driving_ext._drive_mode[npc_driving_ext._current_drive_mode].handbrake
	end

	if npc_driving_ext._debug.nav_paths then
		npc_driving_ext._debug.nav_paths.distance_to_player = distance_to_player
	end

	local current_player_proximity_distance = managers.motion_path:get_player_proximity_distance()

	if distance_to_player < current_player_proximity_distance then
		local unit_id = self._unit:unit_data().unit_id

		managers.motion_path:set_player_proximity_distance_for_unit(unit_id, current_player_proximity_distance)
		managers.motion_path:increase_player_proximity_distance()
		npc_driving_ext:set_state(NpcVehicleDrivingExt.STATE_PLAYER_PROXIMITY)

		retval = {
			acceleration = 0,
			handbrake = 1,
			brake = 1,
			steering = target_steering
		}
	end

	return retval
end

function NpcVehicleStatePursuit:change_state(npc_driving_ext)
	if self._next_state then
		npc_driving_ext:set_state(self._next_state)
	end
end

function NpcVehicleStatePursuit:is_maneuvering()
	return false
end

function NpcVehicleStatePursuit:handle_stuck_vehicle(npc_driving_ext, t, dt)
	if not self._tachograph then
		return
	end

	if self._tachograph.tick_at < t then
		local cop_position = self._unit:position()
		self._tachograph.tick_at = t + self._tachograph.timeframe
		self._tachograph.distance = (cop_position - self._tachograph.last_pos):length() / 100
		self._tachograph.last_pos = cop_position

		if self._tachograph.distance <= 1 then
			self._next_state = self:_choose_recovery_maneuver()
		end
	end
end

function NpcVehicleStatePursuit:_choose_recovery_maneuver()
	local recovery_maneuver = nil

	if self._desired_direction >= 0 and self._desired_direction < 90 then
		recovery_maneuver = NpcVehicleDrivingExt.STATE_MANEUVER_BACK_LEFT
	elseif self._desired_direction >= 90 and self._desired_direction < 180 then
		recovery_maneuver = NpcVehicleDrivingExt.STATE_MANEUVER_BACK_LEFT
	elseif self._desired_direction >= 180 and self._desired_direction < 270 then
		recovery_maneuver = NpcVehicleDrivingExt.STATE_MANEUVER_BACK_RIGHT
	elseif self._desired_direction >= 270 then
		recovery_maneuver = NpcVehicleDrivingExt.STATE_MANEUVER_BACK_RIGHT
	end

	return recovery_maneuver
end
