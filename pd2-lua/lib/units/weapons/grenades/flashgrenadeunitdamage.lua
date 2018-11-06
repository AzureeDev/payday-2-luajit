FlashGrenadeUnitDamage = FlashGrenadeUnitDamage or class(UnitDamage)

function FlashGrenadeUnitDamage:add_damage(endurance_type, attack_unit, dest_body, normal, position, direction, damage, velocity)
	local already_destroyed = self:get_damage() > 0
	local destroyed, damage = UnitDamage.add_damage(self, endurance_type, attack_unit, dest_body, normal, position, direction, damage, velocity)

	if destroyed and not already_destroyed then
		managers.player:send_message("flash_grenade_destroyed", nil, attack_unit)
	end

	return destroyed, damage
end
