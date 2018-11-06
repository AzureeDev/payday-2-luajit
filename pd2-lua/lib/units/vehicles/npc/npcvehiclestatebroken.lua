NpcVehicleStateBroken = NpcVehicleStateBroken or class(NpcBaseVehicleState)

function NpcVehicleStateBroken:init(unit)
	NpcBaseVehicleState.init(self, unit)
end

function NpcVehicleStateBroken:update(t, dt)
end

function NpcVehicleStateBroken:name()
	return NpcVehicleDrivingExt.STATE_BROKEN
end

function NpcVehicleStateBroken:on_enter()
	print("NpcVehicleStateBroken:on_enter()")

	if self._unit:damage():has_sequence(VehicleDrivingExt.SEQUENCE_FULL_DAMAGED) then
		self._unit:damage():run_sequence_simple(VehicleDrivingExt.SEQUENCE_FULL_DAMAGED)
	end
end
