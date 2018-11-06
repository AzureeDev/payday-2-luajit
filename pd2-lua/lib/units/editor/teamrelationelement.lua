TeamRelationElement = TeamRelationElement or class(MissionElement)
TeamRelationElement.SAVE_UNIT_POSITION = false
TeamRelationElement.SAVE_UNIT_ROTATION = false

function TeamRelationElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.team1 = ""
	self._hed.team2 = ""
	self._hed.relation = "friend"
	self._hed.mutual = true

	table.insert(self._save_values, "team1")
	table.insert(self._save_values, "team2")
	table.insert(self._save_values, "relation")
	table.insert(self._save_values, "mutual")
end

function TeamRelationElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_checkbox(panel, panel_sizer, "mutual")
	self:_build_value_combobox(panel, panel_sizer, "team1", table.list_add({
		""
	}, tweak_data.levels:get_team_names_indexed()), "Select the team that will change attitude.")
	self:_build_value_combobox(panel, panel_sizer, "team2", table.list_add({
		""
	}, tweak_data.levels:get_team_names_indexed()), "Select the team that will change attitude.")
	self:_build_value_combobox(panel, panel_sizer, "relation", {
		"friend",
		"foe",
		"neutral"
	}, "Select the new relation.")
end
