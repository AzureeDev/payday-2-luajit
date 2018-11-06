VehicleStateParked = VehicleStateParked or class(BaseVehicleState)

function VehicleStateParked:init(unit)
	BaseVehicleState.init(self, unit)
end

function VehicleStateParked:enter(state_data, enter_data)
	if not self._unit:vehicle():is_active() then
		self._unit:vehicle_driving():activate_vehicle()
		self._unit:vehicle_driving():_start_engine_sound()
	end

	self._unit:interaction():set_override_timer_value(VehicleDrivingExt.TIME_ENTER)
	self:adjust_interactions()
	self._unit:vehicle_driving():set_input(0, 0, 1, 1, false, false, 2)
end

function VehicleStateParked:adjust_interactions()
	VehicleStateParked.super.adjust_interactions(self)

	if self._unit:vehicle_driving():is_interaction_allowed() then
		if self._unit:damage() and self._unit:damage():has_sequence(VehicleDrivingExt.INTERACT_ENTRY_ENABLED) then
			self._unit:damage():run_sequence_simple(VehicleDrivingExt.INTERACT_INTERACTION_ENABLED)
			self._unit:damage():run_sequence_simple(VehicleDrivingExt.INTERACT_ENTRY_ENABLED)
			self._unit:damage():run_sequence_simple(VehicleDrivingExt.INTERACT_LOOT_ENABLED)
			self._unit:damage():run_sequence_simple(VehicleDrivingExt.INTERACT_REPAIR_DISABLED)
		end

		self._unit:vehicle_driving()._interaction_enter_vehicle = true

		if self._unit:vehicle_driving()._has_trunk then
			self._unit:vehicle_driving()._interaction_trunk = true
		else
			self._unit:vehicle_driving()._interaction_loot = true
		end

		self._unit:vehicle_driving()._interaction_repair = false
	end
end

function VehicleStateParked:is_vulnerable()
	return true
end

function VehicleStateParked:stop_vehicle()
	return true
end
