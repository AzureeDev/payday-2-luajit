MandatoryBagsUnitElement = MandatoryBagsUnitElement or class(MissionElement)
MandatoryBagsUnitElement.SAVE_UNIT_POSITION = false
MandatoryBagsUnitElement.SAVE_UNIT_ROTATION = false

function MandatoryBagsUnitElement:init(unit)
	MandatoryBagsUnitElement.super.init(self, unit)

	self._hed.carry_id = "none"
	self._hed.amount = 0

	table.insert(self._save_values, "carry_id")
	table.insert(self._save_values, "amount")
end

function MandatoryBagsUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "carry_id", table.list_add({
		"none"
	}, tweak_data.carry:get_carry_ids()))
	self:_build_value_number(panel, panel_sizer, "amount", {
		min = 0,
		floats = 0,
		max = 100
	}, "Amount of mandatory bags.")
end
