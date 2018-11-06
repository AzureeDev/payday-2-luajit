NpcVehicleStateManeuver = NpcVehicleStateManeuver or class(NpcBaseVehicleState)

function NpcVehicleStateManeuver:init(unit)
	NpcBaseVehicleState.init(self, unit)
end

function NpcVehicleStateManeuver:on_enter(npc_driving_ext)
	local unit_id = npc_driving_ext._unit:unit_data().unit_id

	managers.motion_path:remove_ground_unit_from_path(unit_id)
end

function NpcVehicleStateManeuver:on_exit(npc_driving_ext)
	local unit_id = npc_driving_ext._unit:unit_data().unit_id
	local path_info = managers.motion_path:find_nearest_ground_path(unit_id)

	if path_info then
		path_info.unit_id = unit_id

		managers.motion_path:put_unit_on_path(path_info)
	end
end

function NpcVehicleStateManeuver:update(npc_driving_ext, t, dt)
end

function NpcVehicleStateManeuver:name()
	return NpcVehicleDrivingExt.STATE_MANEUVER
end

function NpcVehicleStateManeuver:change_state(npc_driving_ext)
end

function NpcVehicleStateManeuver:is_maneuvering()
	return true
end
