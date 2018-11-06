AwardAchievmentElement = AwardAchievmentElement or class(MissionElement)

function AwardAchievmentElement:init(unit)
	AwardAchievmentElement.super.init(self, unit)

	self._hed.achievment = nil
	self._hed.award_instigator = false
	self._hed.players_from_start = nil

	table.insert(self._save_values, "achievment")
	table.insert(self._save_values, "award_instigator")
	table.insert(self._save_values, "players_from_start")
end

function AwardAchievmentElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "achievment", table.list_add({
		"none"
	}, table.map_keys(managers.achievment.achievments)))
	self:_build_value_checkbox(panel, panel_sizer, "award_instigator", "Award only the instigator (Player or driver in vehicle)?")
	self:_build_value_checkbox(panel, panel_sizer, "players_from_start", "Only award to players that joined from start.")

	local help = {
		text = "Awards a PSN Trophy or Steam Achievment",
		panel = panel,
		sizer = panel_sizer
	}

	self:add_help_text(help)
end
