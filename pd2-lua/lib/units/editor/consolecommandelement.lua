ConsoleCommandUnitElement = ConsoleCommandUnitElement or class(MissionElement)

function ConsoleCommandUnitElement:init(unit)
	ConsoleCommandUnitElement.super.init(self, unit)

	self._hed.cmd = ""

	table.insert(self._save_values, "cmd")
end

function ConsoleCommandUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local text = EWS:TextCtrl(panel, self._hed.cmd, "", "TE_MULTILINE,TE_PROCESS_ENTER")

	text:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "cmd",
		ctrlr = text
	})
	text:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "cmd",
		ctrlr = text
	})
	panel_sizer:add(text, 1, 0, "EXPAND")
end
