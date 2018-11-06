ExperienceUnitElement = ExperienceUnitElement or class(MissionElement)
ExperienceUnitElement.SAVE_UNIT_POSITION = false
ExperienceUnitElement.SAVE_UNIT_ROTATION = false

function ExperienceUnitElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.elements = {}
	self._hed.amount = 0

	table.insert(self._save_values, "amount")
end

function ExperienceUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_number(panel, panel_sizer, "amount", {
		floats = 0,
		min = 0
	}, "Specify the amount of experience given.")
end
