FilterProfileUnitElement = FilterProfileUnitElement or class(MissionElement)

function FilterProfileUnitElement:init(unit)
	FilterProfileUnitElement.super.init(self, unit)

	self._hed.player_lvl = 0
	self._hed.money_earned = 0
	self._hed.money_offshore = 0
	self._hed.achievement = "none"

	table.insert(self._save_values, "player_lvl")
	table.insert(self._save_values, "money_earned")
	table.insert(self._save_values, "money_offshore")
	table.insert(self._save_values, "achievement")
end

function FilterProfileUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_number(panel, panel_sizer, "player_lvl", {
		min = 0,
		floats = 0,
		max = 100
	}, "Set player level filter")
	self:_build_value_number(panel, panel_sizer, "money_earned", {
		min = 0,
		floats = 0,
		max = 1000000
	}, "Set player level filter")
	self:_build_value_number(panel, panel_sizer, "money_offshore", {
		min = 0,
		floats = 0,
		max = 1000000
	}, "Set money offshore filter, in thousands.")
	self:_build_value_combobox(panel, panel_sizer, "achievement", table.list_add({
		"none"
	}, table.map_keys(managers.achievment.achievments)), "Select an achievement to filter on")
end
