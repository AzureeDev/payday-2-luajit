ActionMessageUnitElement = ActionMessageUnitElement or class(MissionElement)

function ActionMessageUnitElement:init(unit)
	ActionMessageUnitElement.super.init(self, unit)

	self._hed.message_id = "none"

	table.insert(self._save_values, "message_id")
end

function ActionMessageUnitElement:set_text()
	local message = managers.action_messaging:message(self._hed.message_id)

	self._text:set_value(message and managers.localization:text(message.text_id) or "none")
end

function ActionMessageUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local selection_params = {
		default = "none",
		name = "Message id:",
		ctrlr_proportions = 2,
		name_proportions = 1,
		tooltip = "Select a text id from the combobox",
		sorted = true,
		panel = panel,
		sizer = panel_sizer,
		options = managers.action_messaging:ids(),
		value = self._hed.message_id
	}
	local selection = CoreEWS.combobox(selection_params)

	selection:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "set_element_data"), {
		value = "message_id",
		ctrlr = selection
	})
	selection:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "set_text"), nil)

	local text_sizer = EWS:BoxSizer("HORIZONTAL")

	text_sizer:add(EWS:StaticText(panel, "Text: ", "", ""), 1, 2, "ALIGN_CENTER_VERTICAL,RIGHT,EXPAND")

	self._text = EWS:StaticText(panel, managers.localization:text(self._hed.message_id), "", "")

	self:set_text()
	text_sizer:add(self._text, 2, 2, "RIGHT,TOP,EXPAND")
	panel_sizer:add(text_sizer, 1, 0, "EXPAND")
end
