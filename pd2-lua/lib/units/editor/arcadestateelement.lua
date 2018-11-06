ArcadeStateUnitElement = ArcadeStateUnitElement or class(MissionElement)

function ArcadeStateUnitElement:init(unit)
	ArcadeStateUnitElement.super.init(self, unit)
	table.insert(self._save_values, "state")
end

function ArcadeStateUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "state", JobManager.arcade_states, "Select a state from the combobox")
end
