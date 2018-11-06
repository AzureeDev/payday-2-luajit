InventoryDummyUnitElement = InventoryDummyUnitElement or class(MissionElement)

function InventoryDummyUnitElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.category = "none"
	self._hed.slot = 1

	table.insert(self._save_values, "category")
	table.insert(self._save_values, "slot")
end

function InventoryDummyUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "category", {
		"none",
		"secondaries",
		"primaries",
		"masks"
	}, "Select a crafted category.")
	self:_build_value_number(panel, panel_sizer, "slot", {
		min = 1,
		floats = 0,
		max = 9
	}, "Set inventory slot to spawn")
end
