FadeToBlackElement = FadeToBlackElement or class(MissionElement)

function FadeToBlackElement:init(unit)
	FadeToBlackElement.super.init(self, unit)

	self._hed.state = false
	self._hed.fade_in = "element_fade_in"
	self._hed.fade_out = "element_fade_out"

	table.insert(self._save_values, "state")
	table.insert(self._save_values, "fade_in")
	table.insert(self._save_values, "fade_out")
end

function FadeToBlackElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local state = EWS:CheckBox(panel, "Fade in/out", "")

	state:set_value(self._hed.state)
	state:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "state",
		ctrlr = state
	})
	panel_sizer:add(state, 0, 0, "EXPAND")

	local overlay_effects = table.map_keys(tweak_data.overlay_effects, function (x, y)
		return x < y
	end)

	self:_build_value_combobox(panel, panel_sizer, "fade_in", overlay_effects, "Fade in overlay effect.")
	self:_build_value_combobox(panel, panel_sizer, "fade_out", overlay_effects, "Fade out overlay effect.")

	local help = {
		text = "Fade in or out, takes 3 seconds. Hardcore.\nCustom fade in/out can be added in TweakData.lua -> self.overlay_effects",
		panel = panel,
		sizer = panel_sizer
	}

	self:add_help_text(help)
end
