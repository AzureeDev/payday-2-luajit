JobStageAlternativeUnitElement = JobStageAlternativeUnitElement or class(MissionElement)
JobStageAlternativeUnitElement.SAVE_UNIT_POSITION = false
JobStageAlternativeUnitElement.SAVE_UNIT_ROTATION = false

function JobStageAlternativeUnitElement:init(unit)
	JobStageAlternativeUnitElement.super.init(self, unit)

	self._hed.alternative = 1
	self._hed.interupt = "none"

	table.insert(self._save_values, "alternative")
	table.insert(self._save_values, "interupt")
end

function JobStageAlternativeUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_number(panel, panel_sizer, "alternative", {
		floats = 0,
		min = 1
	}, "Sets the next job stage alternative")
	self:_build_value_combobox(panel, panel_sizer, "interupt", table.list_add({
		"none"
	}, tweak_data.levels.escape_levels), "Select an escape level to be loaded between stages")
end
