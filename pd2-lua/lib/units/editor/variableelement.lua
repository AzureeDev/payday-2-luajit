VariableElement = VariableElement or class(MissionElement)
VariableElement.SAVE_UNIT_POSITION = false
VariableElement.SAVE_UNIT_ROTATION = false

function VariableElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.elements = {}
	self._hed.variable = ""
	self._hed.activated = true

	table.insert(self._save_values, "variable")
	table.insert(self._save_values, "activated")
end

function VariableElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local text_sizer = EWS:BoxSizer("HORIZONTAL")
	local name = EWS:StaticText(panel, "Variable:", 0, "")

	text_sizer:add(name, 1, 0, "ALIGN_CENTER_VERTICAL,RIGHT,EXPAND")

	local input = EWS:TextCtrl(panel, self._hed.variable, "", "TE_PROCESS_ENTER")

	input:set_tool_tip("Name of the variable to be used.")
	text_sizer:add(input, 3, 0, "RIGHT,EXPAND")
	input:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "variable",
		ctrlr = input
	})
	input:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "variable",
		ctrlr = input
	})
	panel_sizer:add(text_sizer, 0, 0, "EXPAND")
	self:_build_value_checkbox(panel, panel_sizer, "activated", "Set if the variable is active and uncheck if the variable is disabled.")
end
