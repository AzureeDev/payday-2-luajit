EquipmentUnitElement = EquipmentUnitElement or class(MissionElement)

function EquipmentUnitElement:init(unit)
	EquipmentUnitElement.super.init(self, unit)

	self._hed.equipment = "none"
	self._hed.amount = 1

	table.insert(self._save_values, "equipment")
	table.insert(self._save_values, "amount")
end

function EquipmentUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "equipment", table.list_add({
		"none"
	}, table.map_keys(tweak_data.equipments.specials)))
	self:_build_value_number(panel, panel_sizer, "amount", {
		floats = 0,
		min = 1
	}, "Specifies how many of this equipment to recieve (only work on those who has a max_amount set in their tweak data).")
end
