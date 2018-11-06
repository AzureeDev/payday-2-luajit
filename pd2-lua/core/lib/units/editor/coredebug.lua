CoreDebugUnitElement = CoreDebugUnitElement or class(MissionElement)
DebugUnitElement = DebugUnitElement or class(CoreDebugUnitElement)
DebugUnitElement.SAVE_UNIT_POSITION = false
DebugUnitElement.SAVE_UNIT_ROTATION = false

function DebugUnitElement:init(...)
	CoreDebugUnitElement.init(self, ...)
end

function CoreDebugUnitElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.debug_string = "none"
	self._hed.as_subtitle = false
	self._hed.show_instigator = false
	self._hed.color = nil

	table.insert(self._save_values, "debug_string")
	table.insert(self._save_values, "as_subtitle")
	table.insert(self._save_values, "show_instigator")
	table.insert(self._save_values, "color")
end

function CoreDebugUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local debug = EWS:TextCtrl(panel, self._hed.debug_string, "", "TE_PROCESS_ENTER")

	panel_sizer:add(debug, 0, 0, "EXPAND")
	debug:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "debug_string",
		ctrlr = debug
	})
	debug:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "debug_string",
		ctrlr = debug
	})
	self:_build_value_checkbox(panel, panel_sizer, "as_subtitle", "Show as subtitle")
	self:_build_value_checkbox(panel, panel_sizer, "show_instigator", "Show instigator")
end
