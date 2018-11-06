CoreGlobalEventTriggerUnitElement = CoreGlobalEventTriggerUnitElement or class(MissionElement)
GlobalEventTriggerUnitElement = GlobalEventTriggerUnitElement or class(CoreGlobalEventTriggerUnitElement)

function GlobalEventTriggerUnitElement:init(...)
	GlobalEventTriggerUnitElement.super.init(self, ...)
end

function CoreGlobalEventTriggerUnitElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.trigger_times = 1
	self._hed.global_event = "none"

	table.insert(self._save_values, "global_event")
end

function CoreGlobalEventTriggerUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "global_event", table.list_add({
		"none"
	}, managers.mission:get_global_event_list()), "Select a global event from the combobox")
end
