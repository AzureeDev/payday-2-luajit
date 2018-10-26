VehicleStateInactive = VehicleStateInactive or class(BaseVehicleState)

function VehicleStateInactive:init(unit)
	BaseVehicleState.init(self, unit)
end

function VehicleStateInactive:update(t, dt)
end

function VehicleStateInactive:enter(state_data, enter_data)
	self._unit:vehicle_driving():_stop_engine_sound()

	if self._unit.interaction and self._unit:interaction() and self._unit:interaction().set_override_timer_value then
		self._unit:interaction():set_override_timer_value(VehicleDrivingExt.TIME_ENTER)
	end

	self:adjust_interactions()
end

function VehicleStateInactive:adjust_interactions()
	VehicleStateInactive.super.adjust_interactions(self)

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

function VehicleStateInactive:is_vulnerable()
	return true
end

function VehicleStateInactive:exit()
	if self._unit:unit_data().name_label_id == nil then
		local id = managers.hud:add_vehicle_name_label({
			name = self._unit:vehicle_driving()._tweak_data.name,
			unit = self._unit
		})
		self._unit:unit_data().name_label_id = id
	end
end

