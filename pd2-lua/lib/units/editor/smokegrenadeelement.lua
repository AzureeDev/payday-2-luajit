SmokeGrenadeElement = SmokeGrenadeElement or class(MissionElement)

function SmokeGrenadeElement:init(unit)
	SmokeGrenadeElement.super.init(self, unit)

	self._hed.duration = 15
	self._hed.immediate = false
	self._hed.ignore_control = false
	self._hed.effect_type = "smoke"

	table.insert(self._save_values, "duration")
	table.insert(self._save_values, "immediate")
	table.insert(self._save_values, "ignore_control")
	table.insert(self._save_values, "effect_type")
end

function SmokeGrenadeElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local _, params = self:_build_value_number(panel, panel_sizer, "duration", {
		floats = 0,
		min = 1
	}, "Set the duration of the smoke grenade")

	params.name_ctrlr:set_label("Duration (sec):")
	self:_build_value_checkbox(panel, panel_sizer, "immediate", "Explode immediately", "Explode immediately")
	self:_build_value_checkbox(panel, panel_sizer, "ignore_control", "Ignore control/assault mode", "Ignore control/assault mode")
	self:_build_value_combobox(panel, panel_sizer, "effect_type", {
		"smoke",
		"flash"
	}, "Select what type of effect will be spawned.")
	self:_add_help_text("Spawns a smoke grenade.")
end
