TeleportPlayerUnitElement = TeleportPlayerUnitElement or class(MissionElement)

function TeleportPlayerUnitElement:init(unit)
	TeleportPlayerUnitElement.super.init(self, unit)

	self._hed.state = managers.player:default_player_state()
	self._hed.refill = false
	self._hed.keep_carry = false
	self._hed.equip_selection = "none"
	self._hed.fade_in = 0
	self._hed.sustain = 0
	self._hed.fade_out = 0

	table.insert(self._save_values, "state")
	table.insert(self._save_values, "refill")
	table.insert(self._save_values, "keep_carry")
	table.insert(self._save_values, "equip_selection")
	table.insert(self._save_values, "fade_in")
	table.insert(self._save_values, "sustain")
	table.insert(self._save_values, "fade_out")
end

function TeleportPlayerUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "state", managers.player:player_states(), "Select a state from the combobox")
	self:_build_value_combobox(panel, panel_sizer, "equip_selection", {
		"none",
		"primary",
		"secondary"
	}, "Equips the given selection or keeps the current if none")
	self:_build_value_number(panel, panel_sizer, "fade_in", {
		floats = 2,
		min = 0
	})
	self:_build_value_number(panel, panel_sizer, "sustain", {
		floats = 2,
		min = 0
	})
	self:_build_value_number(panel, panel_sizer, "fade_out", {
		floats = 2,
		min = 0
	})
	self:_build_value_checkbox(panel, panel_sizer, "refill", "Refills the player's ammo and health after teleport")
	self:_build_value_checkbox(panel, panel_sizer, "keep_carry", "Should the player keep what they are carrying while teleporting")
end
