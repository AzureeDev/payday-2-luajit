ModifierEnemyHealth = ModifierEnemyHealth or class(BaseModifier)
ModifierEnemyHealth._type = "ModifierEnemyHealth"
ModifierEnemyHealth.name_id = "none"
ModifierEnemyHealth.desc_id = "menu_cs_modifier_enemy_health"
ModifierEnemyHealth.default_value = "health"
ModifierEnemyHealth.total_localization = "menu_cs_modifier_total_generic_percent"

function ModifierEnemyHealth:init(data)
	ModifierEnemyHealth.super.init(self, data)
	MutatorEnemyHealth:modify_character_tweak_data(tweak_data.character, self:get_health_multiplier())
end

function ModifierEnemyHealth:get_health_multiplier()
	return 1 + self:value() / 100
end

