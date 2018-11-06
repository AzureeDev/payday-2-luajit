FleePointElement = FleePointElement or class(MissionElement)
FleePointElement.SAVE_UNIT_ROTATION = false

function FleePointElement:init(unit)
	FleePointElement.super.init(self, unit)

	self._hed.functionality = "flee_point"

	table.insert(self._save_values, "functionality")
end

function FleePointElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "functionality", {
		"flee_point",
		"loot_drop"
	}, "Select the functionality of the point")
end
