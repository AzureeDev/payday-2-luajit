VehicleTriggerUnitElement = VehicleTriggerUnitElement or class(MissionElement)
VehicleTriggerUnitElement.ON_ENTER = "on_enter"
VehicleTriggerUnitElement.ON_EXIT = "on_exit"
VehicleTriggerUnitElement.ON_ALL_INSIDE = "on_all_inside"
VehicleTriggerUnitElement.events = {
	VehicleTriggerUnitElement.ON_ENTER,
	VehicleTriggerUnitElement.ON_EXIT,
	VehicleTriggerUnitElement.ON_ALL_INSIDE
}

function VehicleTriggerUnitElement:init(unit)
	Application:debug("VehicleTriggerUnitElement:init")
	VehicleTriggerUnitElement.super.init(self, unit)

	self._hed.trigger_times = 1
	self._hed.event = VehicleTriggerUnitElement.ON_ENTER

	table.insert(self._save_values, "event")
end

function VehicleTriggerUnitElement:_build_panel(panel, panel_sizer)
	Application:debug("VehicleTriggerUnitElement:_build_panel")
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "event", VehicleTriggerUnitElement.events, "Select an event from the combobox")
	self:_add_help_text("Set the vehicle event the element should trigger on.")
end
