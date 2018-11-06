TeamAICommandsElement = TeamAICommandsElement or class(MissionElement)
TeamAICommandsElement.SAVE_UNIT_POSITION = false
TeamAICommandsElement.SAVE_UNIT_ROTATION = false

function TeamAICommandsElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.elements = {}
	self._hed.command = "none"

	table.insert(self._save_values, "command")
end

function TeamAICommandsElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "command", {
		"none",
		"enter_bleedout",
		"enter_custody",
		"ignore_player"
	}, "Select an team AI command")
end
