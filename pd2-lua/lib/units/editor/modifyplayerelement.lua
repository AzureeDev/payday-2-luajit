ModifyPlayerElement = ModifyPlayerElement or class(MissionElement)

function ModifyPlayerElement:init(unit)
	ModifyPlayerElement.super.init(self, unit)

	self._hed.damage_fall_disabled = false
	self._hed.invulnerable = nil

	table.insert(self._save_values, "damage_fall_disabled")
	table.insert(self._save_values, "invulnerable")
end

function ModifyPlayerElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_checkbox(panel, panel_sizer, "damage_fall_disabled", "Set player damage fall disabled", "Set player damage fall disabled")
	self:_build_value_checkbox(panel, panel_sizer, "invulnerable", "Player cannot be hurt", "Invulnerable")
	self:_add_help_text("Modifies player properties. The changes are only applied to a player as instigator and cannot be used as a global state")
end
