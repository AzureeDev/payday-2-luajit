ModifierLessConcealment = ModifierLessConcealment or class(BaseModifier)
ModifierLessConcealment._type = "ModifierLessConcealment"
ModifierLessConcealment.name_id = "none"
ModifierLessConcealment.desc_id = "menu_cs_modifier_concealment"
ModifierLessConcealment.default_value = "conceal"
ModifierLessConcealment.total_localization = "menu_cs_modifier_total_generic_value"
ModifierLessConcealment.stealth = true

function ModifierLessConcealment:modify_value(id, value)
	if id == "BlackMarketManager:GetConcealment" then
		return value + self:value()
	end

	return value
end
