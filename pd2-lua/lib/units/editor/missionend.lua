MissionEndUnitElement = MissionEndUnitElement or class(MissionElement)

function MissionEndUnitElement:init(unit)
	MissionEndUnitElement.super.init(self, unit)

	self._hed.state = "none"

	table.insert(self._save_values, "state")
end

function MissionEndUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "state", {
		"none",
		"success",
		"failed",
		"leave",
		"leave_safehouse"
	})
end
