NpcBaseVehicleState = NpcBaseVehicleState or class()

function NpcBaseVehicleState:init(unit)
	self._unit = unit
end

function NpcBaseVehicleState:on_enter(npc_driving_ext)
end

function NpcBaseVehicleState:on_exit(npc_driving_ext)
end

function NpcBaseVehicleState:update(t, dt)
end

function NpcBaseVehicleState:name()
	return NpcVehicleDrivingExt.STATE_BASE
end

function NpcBaseVehicleState:calc_steering(angle)
	return 0
end

function NpcBaseVehicleState:calc_distance_threshold(angle)
	return 501
end

function NpcBaseVehicleState:calc_speed_limit(path, unit_and_pos)
	return 0
end

function NpcBaseVehicleState:handle_hard_turn(npc_driving_ext, angle_to_target)
end

function NpcBaseVehicleState:handle_end_of_the_road(is_last_checkpoint, unit_and_pos)
end

function NpcBaseVehicleState:evasion_maneuvers(npc_driving_ext, target_steering)
end

function NpcBaseVehicleState:change_state(npc_driving_ext)
end

function NpcBaseVehicleState:handle_stuck_vehicle(npc_driving_ext)
end

function NpcBaseVehicleState:is_maneuvering()
	return false
end
