GameEventElement = GameEventElement or class(MissionElement)
GameEventElement.SAVE_UNIT_POSITION = false
GameEventElement.SAVE_UNIT_ROTATION = false

function GameEventElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.elements = {}
	self._hed.category = ""
	self._hed.event = ""

	table.insert(self._save_values, "category")
	table.insert(self._save_values, "event")
end

function GameEventElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local text_sizer_category = EWS:BoxSizer("HORIZONTAL")
	local text_sizer_event = EWS:BoxSizer("HORIZONTAL")
	local name_category = EWS:StaticText(panel, "Category:", 0, "")

	text_sizer_category:add(name_category, 1, 0, "ALIGN_CENTER_VERTICAL,RIGHT,EXPAND")

	local name_event = EWS:StaticText(panel, "Event:", 0, "")

	text_sizer_event:add(name_event, 1, 0, "ALIGN_CENTER_VERTICAL,RIGHT,EXPAND")

	local input_category = EWS:TextCtrl(panel, self._hed.category, "", "TE_PROCESS_ENTER")
	local input_event = EWS:TextCtrl(panel, self._hed.event, "", "TE_PROCESS_ENTER")

	input_category:set_tool_tip("Name of the variable to be used.")
	input_event:set_tool_tip("Name of the variable to be used.")
	text_sizer_category:add(input_category, 3, 0, "RIGHT,EXPAND")
	text_sizer_event:add(input_event, 3, 0, "RIGHT,EXPAND")
	input_category:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "category",
		ctrlr = input_category
	})
	input_category:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "category",
		ctrlr = input_category
	})
	input_event:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "event",
		ctrlr = input_event
	})
	input_event:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "event",
		ctrlr = input_event
	})
	panel_sizer:add(text_sizer_category, 0, 0, "EXPAND")
	panel_sizer:add(text_sizer_event, 0, 0, "EXPAND")
end
