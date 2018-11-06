PlayerStateUnitElement = PlayerStateUnitElement or class(MissionElement)

function PlayerStateUnitElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.state = managers.player:default_player_state()
	self._hed.use_instigator = false

	table.insert(self._save_values, "state")
	table.insert(self._save_values, "use_instigator")
end

function PlayerStateUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "state", mixin_add(managers.player:player_states(), {
		"electrocution"
	}), "Select a state from the combobox")
	self:_build_value_checkbox(panel, panel_sizer, "use_instigator", "On instigator")

	local help = {
		panel = panel,
		sizer = panel_sizer,
		text = "Set the state the players should change to."
	}

	self:add_help_text(help)
end
