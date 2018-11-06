HintUnitElement = HintUnitElement or class(MissionElement)

function HintUnitElement:init(unit)
	HintUnitElement.super.init(self, unit)

	self._hed.hint_id = "none"
	self._hed.instigator_only = false

	table.insert(self._save_values, "hint_id")
	table.insert(self._save_values, "instigator_only")
end

function HintUnitElement:_set_text()
	local hint = managers.hint:hint(self._hed.hint_id)

	self._text:set_value(hint and managers.localization:text(hint.text_id) or "none")
end

function HintUnitElement:set_element_data(params, ...)
	HintUnitElement.super.set_element_data(self, params, ...)

	if params.value == "hint_id" then
		self:_set_text()
	end
end

function HintUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_checkbox(panel, panel_sizer, "instigator_only", "Only show the hint on the instigator unit")
	self:_build_value_combobox(panel, panel_sizer, "hint_id", table.list_add({
		"none"
	}, managers.hint:ids()), "Select a text id from the combobox")

	local text_sizer = EWS:BoxSizer("HORIZONTAL")

	text_sizer:add(EWS:StaticText(panel, "Text: ", "", ""), 1, 2, "ALIGN_CENTER_VERTICAL,RIGHT,EXPAND")

	self._text = EWS:StaticText(panel, "", "", "")

	text_sizer:add(self._text, 2, 2, "RIGHT,TOP,EXPAND")
	self:_set_text()
	panel_sizer:add(text_sizer, 1, 0, "EXPAND")
end
