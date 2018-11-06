LootSecuredTriggerUnitElement = LootSecuredTriggerUnitElement or class(MissionElement)
LootSecuredTriggerUnitElement.SAVE_UNIT_POSITION = false
LootSecuredTriggerUnitElement.SAVE_UNIT_ROTATION = false

function LootSecuredTriggerUnitElement:init(unit)
	LootSecuredTriggerUnitElement.super.init(self, unit)

	self._hed.trigger_times = 1
	self._hed.amount = 0
	self._hed.include_instant_cash = false
	self._hed.report_only = false

	table.insert(self._save_values, "amount")
	table.insert(self._save_values, "include_instant_cash")
	table.insert(self._save_values, "report_only")
end

function LootSecuredTriggerUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_number(panel, panel_sizer, "amount", {
		floats = 0,
		min = 0
	}, "Minimum amount of loot required to trigger")
	self:_build_value_checkbox(panel, panel_sizer, "include_instant_cash")
	self:_build_value_checkbox(panel, panel_sizer, "report_only")
end
