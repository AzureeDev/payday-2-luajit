ModifierCivilianAlarm = ModifierCivilianAlarm or class(BaseModifier)
ModifierCivilianAlarm._type = "ModifierCivilianAlarm"
ModifierCivilianAlarm.name_id = "none"
ModifierCivilianAlarm.desc_id = "menu_cs_modifier_civs"
ModifierCivilianAlarm.default_value = "count"
ModifierCivilianAlarm.stealth = true

function ModifierCivilianAlarm:OnCivilianKilled()
	self._body_count = (self._body_count or 0) + 1

	if self:value() < self._body_count and not self._alarmed then
		managers.groupai:state():on_police_called("civ_too_many_killed")

		self._alarmed = true
	end
end
