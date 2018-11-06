ModifierExplosionImmunity = ModifierExplosionImmunity or class(BaseModifier)
ModifierExplosionImmunity._type = "ModifierExplosionImmunity"
ModifierExplosionImmunity.name_id = "none"
ModifierExplosionImmunity.desc_id = "menu_cs_modifier_dozer_immune"

function ModifierExplosionImmunity:modify_value(id, value, unit_tweak)
	if id == "CopDamage:DamageExplosion" and unit_tweak == "tank" then
		return 0
	end

	return value
end
