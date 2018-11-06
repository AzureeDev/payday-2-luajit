BainStateElement = BainStateElement or class(MissionElement)

function BainStateElement:init(unit)
	BainStateElement.super.init(self, unit)

	self._hed.state = true

	table.insert(self._save_values, "state")
end

function BainStateElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local state = EWS:CheckBox(panel, "Bain state", "")

	state:set_value(self._hed.state)
	state:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "state",
		ctrlr = state
	})
	panel_sizer:add(state, 0, 0, "EXPAND")

	local help = {
		text = "Sets if bain should speak or not.",
		panel = panel,
		sizer = panel_sizer
	}

	self:add_help_text(help)
end
