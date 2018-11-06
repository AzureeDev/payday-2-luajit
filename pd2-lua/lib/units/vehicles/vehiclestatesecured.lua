VehicleStateSecured = VehicleStateSecured or class(BaseVehicleState)

function VehicleStateSecured:init(unit)
	BaseVehicleState.init(self, unit)
end

function VehicleStateSecured:enter(state_data, enter_data)
	self._unit:vehicle_driving():_stop_engine_sound()
	self._unit:interaction():set_override_timer_value(VehicleDrivingExt.TIME_ENTER)
	self:adjust_interactions()
	self._unit:vehicle_driving():set_input(0, 0, 1, 1, false, false, 2)
end

function VehicleStateSecured:adjust_interactions()
	VehicleStateSecured.super.adjust_interactions(self)

	if self._unit:vehicle_driving():is_interaction_allowed() then
		if self._unit:damage() and self._unit:damage():has_sequence(VehicleDrivingExt.INTERACT_ENTRY_ENABLED) then
			self._unit:vehicle_driving()._unit:damage():run_sequence_simple(VehicleDrivingExt.INTERACT_ENTRY_DISABLED)
			self._unit:vehicle_driving()._unit:damage():run_sequence_simple(VehicleDrivingExt.INTERACT_LOOT_DISABLED)
			self._unit:vehicle_driving()._unit:damage():run_sequence_simple(VehicleDrivingExt.INTERACT_REPAIR_DISABLED)
			self._unit:vehicle_driving()._unit:damage():run_sequence_simple(VehicleDrivingExt.INTERACT_INTERACTION_DISABLED)
		end

		self._interaction_enter_vehicle = false
		self._interaction_loot = false

		if self._unit:vehicle_driving()._has_trunk then
			self._unit:vehicle_driving()._interaction_trunk = true
		else
			self._unit:vehicle_driving()._interaction_loot = true
		end

		self._interaction_repair = false
	end
end

function VehicleStateSecured:stop_vehicle()
	return true
end
