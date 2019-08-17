require("lib/units/vehicles/npc/NpcBaseVehicleState")
require("lib/units/vehicles/npc/NpcVehicleStatePursuit")
require("lib/units/vehicles/npc/NpcVehicleStateInactive")
require("lib/units/vehicles/npc/NpcVehicleStatePlayerProximity")
require("lib/units/vehicles/npc/NpcVehicleStateBroken")
require("lib/units/vehicles/npc/NpcVehicleStateManeuver")
require("lib/units/vehicles/npc/NpcVehicleStateManeuverBackLeft")
require("lib/units/vehicles/npc/NpcVehicleStateManeuverBackRight")
require("lib/units/vehicles/npc/NpcVehicleStateManeuverUTurn")

NpcVehicleDrivingExt = NpcVehicleDrivingExt or class()
NpcVehicleDrivingExt.STATE_INACTIVE = "inactive"
NpcVehicleDrivingExt.STATE_PURSUIT = "pursuit"
NpcVehicleDrivingExt.STATE_PLAYER_PROXIMITY = "player_proximity"
NpcVehicleDrivingExt.STATE_BROKEN = "broken"
NpcVehicleDrivingExt.STATE_MANEUVER = "maneuver"
NpcVehicleDrivingExt.STATE_MANEUVER_BACK_LEFT = "maneuver_back_left"
NpcVehicleDrivingExt.STATE_MANEUVER_BACK_RIGHT = "maneuver_back_right"
NpcVehicleDrivingExt.STATE_MANEUVER_U_TURN = "maneuver_u_turn"
NpcVehicleDrivingExt.DRIVE_CONTROLS_GEAR_REVERSE = 0
NpcVehicleDrivingExt.DRIVE_CONTROLS_GEAR_NEUTRAL = 1
NpcVehicleDrivingExt.DRIVE_CONTROLS_GEAR_FIRST = 2
NpcVehicleDrivingExt.DRIVE_CONTROLS_STEER_STRAIGHT = 0
NpcVehicleDrivingExt.DRIVE_CONTROLS_STEER_FULL_LEFT = 1
NpcVehicleDrivingExt.DRIVE_CONTROLS_STEER_FULL_RIGHT = -1

function NpcVehicleDrivingExt:init(unit)
	self._unit = unit

	self._unit:set_extension_update_enabled(Idstring("npc_vehicle_driving"), true)

	self._vehicle = self._unit:vehicle()
	self._last_checkpoint_reached = false
	self._drive_controls = {
		accelerate = {
			acceleration = 1,
			brake = 0,
			handbrake = 0
		},
		brake = {
			acceleration = 0,
			brake = 1,
			handbrake = 0
		},
		handbrake = {
			acceleration = 0,
			brake = 1,
			handbrake = 1
		}
	}
	self._current_drive_controls = "accelerate"
	self._is_chasing = false

	self:_init_states()
	self:_debug_show()

	if self._vehicle == nil then
		Application:debug("[DRIVING] unit doesn't contain a vehicle")
	end

	Application:debug("NpcVehicleDrivingExt:init( unit )")

	if not self._unit:vehicle_driving() then
		Application:error("NpcVehicleDrivingExt must be specified after the VehicleDrivingExt in the unit file")

		return
	end

	self._target_unit = nil

	self._unit:vehicle_driving():set_interaction_allowed(false)
end

function NpcVehicleDrivingExt:activate()
	if self._current_state:name() ~= NpcVehicleDrivingExt.STATE_BROKEN then
		self:set_state(NpcVehicleDrivingExt.STATE_PURSUIT)
		self:start()
	end
end

function NpcVehicleDrivingExt:deactivate()
	self:set_state(NpcVehicleDrivingExt.STATE_INACTIVE)

	self._current_drive_controls = "handbrake"

	self:stop()
end

function NpcVehicleDrivingExt:is_active()
	return self._vehicle:is_active()
end

function NpcVehicleDrivingExt:is_chasing()
	return self._is_chasing
end

function NpcVehicleDrivingExt:on_vehicle_death()
	if self._current_state:name() == NpcVehicleDrivingExt.STATE_BROKEN then
		return
	end

	self:set_state(NpcVehicleDrivingExt.STATE_BROKEN)

	self._current_drive_controls = "handbrake"

	self:stop()

	if self._unit:damage():has_sequence("turret_switch_off") then
		self._unit:damage():run_sequence_simple("turret_switch_off")
	end
end

function NpcVehicleDrivingExt:start()
	self:_start()

	if managers.network:session() and Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_vehicle_driving", "start", self._unit, nil)
	end
end

function NpcVehicleDrivingExt:sync_start()
	self:_start()
end

function NpcVehicleDrivingExt:_start()
	if self._vehicle then
		if not self:is_active() then
			self._unit:damage():run_sequence_simple("driving")
			self._vehicle:set_active(true)
			self:set_input(0, 0, 0, 0, false, true, 2)

			self._drive_controls = {
				accelerate = {
					acceleration = 1,
					brake = 0,
					handbrake = 0
				},
				brake = {
					acceleration = 0,
					brake = 1,
					handbrake = 0
				},
				handbrake = {
					acceleration = 0,
					brake = 1,
					handbrake = 1
				}
			}
			self._current_drive_controls = "accelerate"
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
					distance = 1500,
					relative_angle_min = 30,
					relative_angle_max = 90,
					v_max = 60
				}
			}
			self._last_checkpoint_reached = false

			self:_debug_show()
		end

		self._is_chasing = true
	end
end

function NpcVehicleDrivingExt:stop()
	self:_stop()

	if managers.network:session() and Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_vehicle_driving", "stop", self._unit, nil)
	end
end

function NpcVehicleDrivingExt:sync_stop()
	self:_stop()
end

function NpcVehicleDrivingExt:_stop()
	if self._vehicle and self:is_active() then
		self._is_chasing = false

		self:set_input(0, 0, 0, 0, false, false, 2)
	end
end

function NpcVehicleDrivingExt:update(unit, t, dt)
	if managers.motion_path:npc_vehicle_debug_output_enabled() then
		self:_display_debug_info()
	elseif self._debug and self._debug.ws then
		self._debug.info:set_text("")
	end

	if self._current_state and self._current_state:name() ~= NpcBaseVehicleState.STATE_BROKEN then
		self._current_state:change_state(self)
		self._current_state:handle_stuck_vehicle(self, t, dt)
		self._current_state:update(self, t, dt)
	end
end

function NpcVehicleDrivingExt:_display_debug_info()
	if self._debug and self._debug.ws and self._debug.info then
		local nav_paths = {
			unit_id = "",
			unit_name = "",
			current_state = "",
			cop_path = "",
			cop_target_path = "",
			distance_to_player = 0,
			ai_cost = {
				cost = 0,
				fps = 0
			}
		}

		if self._debug.nav_paths then
			nav_paths.unit_id = self._debug.nav_paths.unit_id or ""
			nav_paths.unit_name = self._debug.nav_paths.unit_name or ""
			nav_paths.cop_path = self._debug.nav_paths.cop_path or ""
			nav_paths.cop_target_path = self._debug.nav_paths.cop_target_path or ""
			nav_paths.distance_to_player = self._debug.nav_paths.distance_to_player or 0
			nav_paths.ai_cost = self._debug.nav_paths.ai_cost or {
				cost = 0,
				fps = 0
			}
		end

		if self._current_state then
			nav_paths.current_state = self._current_state:name() or "n/a"
		end

		local vehicle_state = self._vehicle:get_state()
		local cop_vehicle_speed = vehicle_state:get_speed() * 3.6
		local player_vehicle_speed = self:_get_player_speed()
		player_vehicle_speed = player_vehicle_speed or 0

		self._debug.info:set_text(string.format([[
----------------------
Cop unit:  %s - %s
Cop state:  %s
Player_speed:  %.2f km/h
Cop speed:  %.2f km/h
Drive controls:  %s
Cop on path:  %s
Cop targeting path:  %s
Distance to player:  %.2f m
AI cost:  %.2f ms ( %.2f %% of fps)]], nav_paths.unit_id, nav_paths.unit_name, nav_paths.current_state, player_vehicle_speed, cop_vehicle_speed, self._current_drive_controls, nav_paths.cop_path, nav_paths.cop_target_path, nav_paths.distance_to_player, nav_paths.ai_cost.cost, nav_paths.ai_cost.fps))
	end
end

function NpcVehicleDrivingExt:set_target_unit(unit)
	self._target_unit = unit
end

function NpcVehicleDrivingExt:_get_target_unit()
	local target_unit = managers.vehicle:find_npc_vehicle_target()

	return target_unit
end

function NpcVehicleDrivingExt:_choose_target_path_direction(player_path, target_marker)
	local player_unit = self:_get_target_unit()

	if not player_unit or not player_path then
		return
	end

	local player_position = player_unit:position()
	local player_point_id = nil

	for idx, marker_id in pairs(player_path.marker_checkpoints) do
		if marker_id == target_marker then
			player_point_id = idx
		end
	end

	if not player_point_id then
		return "fwd"
	end

	local player_point_bck_id = #player_path.points - player_point_id + 1
	local point_forward = player_path.points[player_point_id + 1]
	local point_backward = player_path.points_bck[player_point_bck_id + 1]

	if not point_forward then
		return "bck"
	elseif not point_backward then
		return "fwd"
	elseif not point_forward and not point_backward then
		Application:error("Unable to choose path direction.")

		return
	end

	local distance_forward = (player_position - point_forward.point):length()
	local distance_backward = (player_position - point_backward.point):length()
	local retval = nil

	if distance_forward <= distance_backward then
		retval = "fwd"
	else
		retval = "bck"
	end

	return retval
end

function NpcVehicleDrivingExt:drive_to_point(cop_path, unit_and_pos, dt)
	if not self._current_state then
		Application:error("Npc vehicle has no state: ", self._unit:unit_data().unit_id, self._unit:unit_data().name_id)

		return false
	end

	if self._current_state:is_maneuvering() then
		return false
	end

	local profiler_name = "NpcVehicleDrivingExt:drive_to_point" .. unit_and_pos.unit
	local profiler_id = Profiler:start(profiler_name)
	local cop_points = nil

	if not unit_and_pos.direction or unit_and_pos.direction == "fwd" then
		cop_points = cop_path.points
	else
		cop_points = cop_path.points_bck
	end

	local target_path = nil
	local player_unit = self:_get_target_unit()

	if not alive(player_unit) or not alive(self._unit) then
		return false
	end

	local astar_path = managers.motion_path:find_next_path(self._unit:position(), player_unit:position())

	if astar_path then
		target_path = astar_path
	else
		print("Astar path not found.")

		return false
	end

	local debug_unit_name = self._unit:unit_data().name_id

	if self._debug then
		if not self._debug.nav_paths then
			self._debug.nav_paths = {}
		end

		self._debug.nav_paths.unit_name = debug_unit_name
		self._debug.nav_paths.unit_id = unit_and_pos.unit
		self._debug.nav_paths.cop_path = cop_path.id
		self._debug.nav_paths.cop_target_path = target_path.id
	end

	local cop_position_info = self:calc_cop_position_info(cop_points, unit_and_pos)
	local target_steering = self._current_state:calc_steering(cop_position_info.target_spin)
	local distance_threshold = self._current_state:calc_distance_threshold(cop_position_info.angle_to_target)
	local skip_checkpoint = self:_choose_next_checkpoint(cop_path, cop_points, target_path, unit_and_pos, cop_position_info, distance_threshold)

	if not skip_checkpoint then
		self._current_state:handle_hard_turn(self, cop_position_info.angle_to_target)

		local speed_limit = self._current_state:calc_speed_limit(cop_path, unit_and_pos)
		local controls_override = self._current_state:evasion_maneuvers(self, target_steering)

		self:_drive(target_steering, speed_limit, controls_override)
	end

	Profiler:stop(profiler_id)

	local profiler_time = Profiler:counter_time(profiler_name)
	local percentage_of_current_fps = 100 * profiler_time / dt

	if self._debug then
		self._debug.nav_paths.ai_cost = {
			cost = profiler_time * 1000,
			fps = percentage_of_current_fps
		}
	end

	return skip_checkpoint
end

function NpcVehicleDrivingExt:calc_cop_position_info(cop_points, unit_and_pos)
	local target_position = cop_points[unit_and_pos.target_checkpoint].point
	local unit_position = self._unit:position()
	local target_direction = target_position - unit_position
	local target_direction_nrm = target_direction:normalized()
	local target_distance = target_direction:length()
	local vehicle_fwd_vector = self._unit:rotation():y():normalized()
	local angle_to_target = vehicle_fwd_vector:angle(target_direction)
	local target_direction_360 = math.mod(360 + target_direction:to_polar().spin, 360)
	local vehicle_fwd_vector_360 = math.mod(360 + vehicle_fwd_vector:to_polar().spin, 360)
	local target_spin_relative_to_vehicle = math.mod(360 + target_direction_360 - vehicle_fwd_vector_360, 360)

	if managers.motion_path:npc_vehicle_debug_output_enabled() then
		Application:draw_line(unit_position + Vector3(0, 0, 10), target_position + Vector3(0, 0, 10), 1, 0, 0)
		Application:draw_line(unit_position + Vector3(0, 0, 10), unit_position + Vector3(0, 0, 10) + vehicle_fwd_vector * 1000, 0, 0, 1)
	end

	return {
		target_spin = target_spin_relative_to_vehicle,
		angle_to_target = angle_to_target,
		checkpoint_distance = target_distance
	}
end

function NpcVehicleDrivingExt:_choose_next_checkpoint(cop_path, cop_points, target_path, unit_and_pos, cop_position_info, distance_threshold)
	local target_position = cop_points[unit_and_pos.target_checkpoint].point
	local unit_position = self._unit:position()
	local target_direction = target_position - unit_position
	local target_direction_nrm = target_direction:normalized()

	if managers.motion_path:npc_vehicle_debug_output_enabled() then
		Application:draw_line(unit_position + Vector3(0, 0, 20), unit_position + Vector3(0, 0, 20) + target_direction_nrm * distance_threshold, 0, 1, 0)
	end

	local bridge_to_marker = self:_find_bridge(cop_path, target_path, unit_and_pos)

	if cop_position_info.checkpoint_distance < distance_threshold then
		if bridge_to_marker and bridge_to_marker.marker_to then
			unit_and_pos.direction = bridge_to_marker.direction

			managers.motion_path:change_unit_path(cop_path, target_path, bridge_to_marker.marker_to, unit_and_pos)

			return false
		elseif unit_and_pos.target_checkpoint == #cop_points then
			unit_and_pos.target_checkpoint = 1

			if not unit_and_pos.direction or unit_and_pos.direction == "fwd" then
				unit_and_pos.direction = "bck"
			else
				unit_and_pos.direction = "fwd"
			end

			self:set_state(NpcVehicleDrivingExt.STATE_MANEUVER_U_TURN)
		else
			unit_and_pos.target_checkpoint = math.clamp(unit_and_pos.target_checkpoint + 1, 0, #cop_points)

			if unit_and_pos.target_checkpoint == #cop_points then
				return false
			else
				return true
			end
		end
	end

	return false
end

function NpcVehicleDrivingExt:_find_bridge(cop_path, target_path, unit_and_pos)
	if not cop_path or not cop_path.bridges or not target_path then
		return nil
	end

	if cop_path.id == target_path.id then
		return nil
	end

	local player_unit = self:_get_target_unit()

	if not player_unit then
		return nil
	end

	local bridges_to_target = {}

	for idx, bridge in ipairs(cop_path.bridges) do
		if bridge.path_id == target_path.id then
			if not bridges_to_target[bridge.marker_from] then
				bridges_to_target[bridge.marker_from] = {}
			end

			table.insert(bridges_to_target[bridge.marker_from], bridge.marker_to)
		end
	end

	local point_id_in_direction = nil

	if not unit_and_pos.direction or unit_and_pos.direction == "fwd" then
		point_id_in_direction = unit_and_pos.target_checkpoint
	else
		point_id_in_direction = #cop_path.points - unit_and_pos.target_checkpoint + 1
	end

	local player_position = player_unit:position()
	local cop_on_checkpoint = cop_path.marker_checkpoints[point_id_in_direction]
	local min_distance_marker = {
		distance = 2000000
	}

	for marker_from, markers_to in pairs(bridges_to_target) do
		for i, marker_to in ipairs(markers_to) do
			if marker_from == cop_on_checkpoint then
				local path_direction = self:_choose_target_path_direction(target_path, marker_to)
				local marker_to_position = self:_get_marker_position(target_path, marker_to)
				local distance_to_player = (marker_to_position - player_position):length()

				if distance_to_player <= min_distance_marker.distance then
					min_distance_marker.marker_to = marker_to
					min_distance_marker.distance = distance_to_player
					min_distance_marker.direction = path_direction
				end
			end
		end
	end

	return min_distance_marker
end

function NpcVehicleDrivingExt:_get_marker_position(player_path, marker_to)
	local point_id = nil

	for id, marker in pairs(player_path.marker_checkpoints) do
		if marker == marker_to then
			point_id = id

			break
		end
	end

	if point_id then
		return player_path.points[point_id].point
	end
end

function NpcVehicleDrivingExt:_get_player_speed()
	local player_vehicle = self:_get_target_unit()

	if player_vehicle and player_vehicle:vehicle_driving() then
		return player_vehicle:vehicle_driving()._vehicle:get_state():get_speed() * 3.6
	end
end

function NpcVehicleDrivingExt:_drive(steering, speed_limit, controls_override)
	local acceleration = 0
	local brake = 0
	local handbrake = 0

	if self._drive_controls and self._drive_controls[self._current_drive_controls] then
		acceleration = self._drive_controls[self._current_drive_controls].acceleration
		brake = self._drive_controls[self._current_drive_controls].brake
		handbrake = self._drive_controls[self._current_drive_controls].handbrake
	end

	local vehicle_state = self._vehicle:get_state()
	local current_speed = vehicle_state:get_speed() * 3.6

	if speed_limit < current_speed and speed_limit ~= -1 then
		acceleration = 0
	end

	if controls_override then
		acceleration = controls_override.acceleration
		steering = controls_override.steering
		brake = controls_override.brake
		handbrake = controls_override.handbrake
	end

	self:set_input(acceleration, steering, brake, handbrake, false, false, -1)
end

function NpcVehicleDrivingExt:set_input(acceleration, steering, brake, handbrake, geer_up, geer_down, force_gear)
	if Network:is_server() then
		self._unit:vehicle_driving():set_input(acceleration, steering, brake, handbrake, geer_up, geer_down, force_gear)
	end
end

function NpcVehicleDrivingExt:brake()
	self:set_input(0, 1, 1, 1, false, false, -1)
end

function NpcVehicleDrivingExt:_is_last_checkpoint(path, unit_and_pos)
	return #path.points == unit_and_pos.target_checkpoint
end

function NpcVehicleDrivingExt:_debug_show()
	if self._debug and self._debug.ws then
		return
	end

	local debug_output_offset = managers.motion_path._debug_output_offset
	self._debug = {
		ws = Overlay:newgui():create_screen_workspace()
	}
	self._debug.panel = self._debug.ws:panel()
	self._debug.info = self._debug.panel:text({
		text = "",
		name = "debug_info",
		font_size = 14,
		x = 14,
		layer = 2000,
		y = 100 + debug_output_offset,
		font = tweak_data.hud.small_font,
		color = Color.yellow
	})
	managers.motion_path._debug_output_offset = managers.motion_path._debug_output_offset + 170
end

function NpcVehicleDrivingExt:destroy()
	if self._debug then
		Overlay:newgui():destroy_workspace(self._debug.ws)

		self._debug.ws = nil
	end

	self._debug = nil
end

function NpcVehicleDrivingExt:_get_unit(unit_id)
	if Global.running_simulation then
		return managers.editor:unit_with_id(unit_id)
	else
		return managers.worlddefinition:get_unit(unit_id)
	end
end

function NpcVehicleDrivingExt:_init_states()
	local unit = self._unit
	self._states = {
		inactive = NpcVehicleStateInactive:new(unit),
		pursuit = NpcVehicleStatePursuit:new(unit),
		player_proximity = NpcVehicleStatePlayerProximity:new(unit),
		broken = NpcVehicleStateBroken:new(unit),
		maneuver = NpcVehicleStateManeuver:new(unit),
		maneuver_back_left = NpcVehicleStateManeuverBackLeft:new(unit),
		maneuver_back_right = NpcVehicleStateManeuverBackRight:new(unit),
		maneuver_u_turn = NpcVehicleStateManeuverUTurn:new(unit)
	}

	self:_set_state(NpcVehicleDrivingExt.STATE_INACTIVE)
end

function NpcVehicleDrivingExt:_set_state(new_state)
	if self._current_state then
		self._current_state:on_exit(self)
	end

	self._current_state = self._states[new_state]
	self._current_state_name = new_state

	self._current_state:on_enter(self)
end

function NpcVehicleDrivingExt:set_state(new_state)
	self:_set_state(new_state)

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_npc_vehicle_data", self._unit, self._current_state_name, self._target_unit)
	end
end
