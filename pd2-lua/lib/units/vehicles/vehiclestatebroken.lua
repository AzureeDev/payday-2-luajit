VehicleStateBroken = VehicleStateBroken or class(BaseVehicleState)

function VehicleStateBroken:init(unit)
	BaseVehicleState.init(self, unit)
end

function VehicleStateBroken:enter(state_data, enter_data)
	self._unit:vehicle_driving():_stop_engine_sound()
	self._unit:vehicle_driving():_start_broken_engine_sound()
	self:adjust_interactions()
	self._unit:vehicle_driving():set_input(0, 0, 1, 1, false, false, 2)

	local player_vehicle = managers.player:get_vehicle()

	if player_vehicle and player_vehicle.vehicle_unit == self._unit then
		managers.hud:show_hint({
			time = 3,
			text = managers.localization:text("hud_vehicle_broken")
		})
	end

	if self._unit:damage():has_sequence(VehicleDrivingExt.SEQUENCE_FULL_DAMAGED) then
		self._unit:damage():run_sequence_simple(VehicleDrivingExt.SEQUENCE_FULL_DAMAGED)
	end

	self._unit:interaction():set_contour("standard_color", 1)
end

function VehicleStateBroken:adjust_interactions()
	VehicleStateBroken.super.adjust_interactions(self)

	if self._unit:vehicle_driving():is_interaction_allowed() and self._unit:damage() and self._unit:damage():has_sequence(VehicleDrivingExt.INTERACT_ENTRY_ENABLED) then
		self._unit:damage():run_sequence_simple(VehicleDrivingExt.INTERACT_INTERACTION_ENABLED)
		self._unit:damage():run_sequence_simple(VehicleDrivingExt.INTERACT_ENTRY_DISABLED)
		self._unit:damage():run_sequence_simple(VehicleDrivingExt.INTERACT_LOOT_ENABLED)
		self._unit:damage():run_sequence_simple(VehicleDrivingExt.INTERACT_REPAIR_ENABLED)

		self._unit:vehicle_driving()._interaction_enter_vehicle = false

		if self._unit:vehicle_driving()._has_trunk then
			self._unit:vehicle_driving()._interaction_trunk = true
		else
			self._unit:vehicle_driving()._interaction_loot = true
		end

		self._unit:vehicle_driving()._interaction_repair = true
	end
end

function VehicleStateBroken:get_action_for_interaction(pos, locator, tweak_data)
	local action = VehicleDrivingExt.INTERACT_INVALID
	local seat, seat_distance = self._unit:vehicle_driving():get_available_seat(pos)
	local loot_point, loot_point_distance = self._unit:vehicle_driving():get_nearest_loot_point(pos)

	if seat and loot_point and loot_point_distance <= seat_distance and not managers.player:is_carrying() then
		action = VehicleDrivingExt.INTERACT_LOOT

		self._unit:interaction():set_override_timer_value(VehicleDrivingExt.TIME_ENTER)
	else
		action = VehicleDrivingExt.INTERACT_REPAIR

		self._unit:interaction():set_override_timer_value(VehicleDrivingExt.TIME_REPAIR)
	end

	return action
end

function VehicleStateBroken:stop_vehicle()
	return true
end

function VehicleStateBroken:exit(state_data)
	self._unit:vehicle_driving():_stop_engine_sound()
end
