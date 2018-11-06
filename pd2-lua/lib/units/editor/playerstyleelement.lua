PlayerStyleElement = PlayerStyleElement or class(MissionElement)

function PlayerStyleElement:init(unit)
	PlayerStyleElement.super.init(self, unit)

	self._hed.style = ""

	table.insert(self._save_values, "style")
end

function PlayerStyleElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local style_sizer = EWS:BoxSizer("HORIZONTAL")

	panel_sizer:add(style_sizer, 0, 1, "EXPAND,LEFT")

	self._style_params = {
		default = "",
		name = "Style:",
		ctrlr_proportions = 2,
		name_proportions = 1,
		sizer_proportions = 1,
		tooltip = "Select a style from the combobox",
		sorted = true,
		panel = panel,
		sizer = style_sizer,
		options = {
			"scrub",
			"none"
		},
		value = self._hed.style
	}
	local style = CoreEWS.combobox(self._style_params)

	style:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "set_element_data"), {
		value = "style",
		ctrlr = style
	})

	local help = {
		text = "Change player style.",
		panel = panel,
		sizer = panel_sizer
	}

	self:add_help_text(help)
end
