SlowMotionElement = SlowMotionElement or class(MissionElement)
SlowMotionElement.SAVE_UNIT_POSITION = false
SlowMotionElement.SAVE_UNIT_ROTATION = false

function SlowMotionElement:init(unit)
	SlowMotionElement.super.init(self, unit)

	self._hed.eff_name = ""

	table.insert(self._save_values, "eff_name")
end

function SlowMotionElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "eff_name", table.map_keys(tweak_data.timespeed.mission_effects), "Choose effect. Descriptions in lib/TimeSpeedEffectTweakData.lua")

	local help = {
		panel = panel,
		sizer = panel_sizer,
		text = "Choose effect. Descriptions in lib/TimeSpeedEffectTweakData.lua."
	}

	self:add_help_text(help)
end
