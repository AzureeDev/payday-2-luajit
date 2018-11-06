BlackscreenVariantElement = BlackscreenVariantElement or class(MissionElement)

function BlackscreenVariantElement:init(unit)
	BlackscreenVariantElement.super.init(self, unit)

	self._hed.variant = "0"

	table.insert(self._save_values, "variant")
end

function BlackscreenVariantElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local bscreen_params = self:_get_params(panel, panel_sizer)
	local bscreen = CoreEWS.combobox(bscreen_params)

	bscreen:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "set_element_data"), {
		value = "variant",
		ctrlr = bscreen
	})

	local help = {
		text = "Set blackscreen variant.",
		panel = panel,
		sizer = panel_sizer
	}

	self:add_help_text(help)
end

function BlackscreenVariantElement:_get_params(panel, panel_sizer)
	local bscreen_params = {
		default = "0",
		name = "Blackscreen variant:",
		ctrlr_proportions = 2,
		name_proportions = 1,
		tooltip = "Select variant, from level_tweak_data.level.intro_event",
		sorted = false,
		panel = panel,
		sizer = panel_sizer,
		options = {
			"1",
			"2",
			"3",
			"4",
			"5",
			"6",
			"7",
			"8",
			"9",
			"10",
			"11",
			"12",
			"13",
			"14",
			"15",
			"16",
			"17",
			"18",
			"19",
			"20",
			"21",
			"22",
			"23",
			"24",
			"25",
			"26",
			"27",
			"28",
			"29",
			"30"
		},
		value = self._hed.variant
	}

	return bscreen_params
end

EndscreenVariantElement = EndscreenVariantElement or class(BlackscreenVariantElement)

function EndscreenVariantElement:init(unit)
	EndscreenVariantElement.super.init(self, unit)
end

function EndscreenVariantElement:_get_params(panel, panel_sizer)
	local bscreen_params = {
		default = "0",
		name = "Endscreen variant:",
		ctrlr_proportions = 2,
		name_proportions = 1,
		tooltip = "Select variant, from level_tweak_data.level.outro_event",
		sorted = false,
		panel = panel,
		sizer = panel_sizer,
		options = {
			"1",
			"2",
			"3",
			"4",
			"5",
			"6",
			"7",
			"8",
			"9",
			"10",
			"11",
			"12",
			"13",
			"14",
			"15",
			"16",
			"17",
			"18",
			"19",
			"20",
			"21",
			"22",
			"23",
			"24",
			"25",
			"26",
			"27",
			"28",
			"29",
			"30"
		},
		value = self._hed.variant
	}

	return bscreen_params
end
