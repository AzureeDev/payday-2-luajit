HuskCivilianDamage = HuskCivilianDamage or class(HuskCopDamage)
HuskCivilianDamage._HEALTH_INIT = CivilianDamage._HEALTH_INIT
HuskCivilianDamage.damage_bullet = CivilianDamage.damage_bullet
HuskCivilianDamage.damage_melee = CivilianDamage.damage_melee
HuskCivilianDamage.no_intimidation_by_dmg = CivilianDamage.no_intimidation_by_dmg

function HuskCivilianDamage:_on_damage_received(damage_info)
	CivilianDamage._on_damage_received(self, damage_info)
end

function HuskCivilianDamage:_unregister_from_enemy_manager(damage_info)
	CivilianDamage._unregister_from_enemy_manager(self, damage_info)
end

function HuskCivilianDamage:damage_explosion(attack_data)
	if attack_data.variant == "explosion" then
		attack_data.damage = 10
	end

	return CopDamage.damage_explosion(self, attack_data)
end

function HuskCivilianDamage:damage_fire(attack_data)
	if attack_data.variant == "fire" then
		attack_data.damage = 10
	end

	return CopDamage.damage_fire(self, attack_data)
end

