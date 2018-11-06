GageModifierLifeSteal = GageModifierLifeSteal or class(GageModifier)
GageModifierLifeSteal._type = "GageModifierLifeSteal"
GageModifierLifeSteal.default_value = "cooldown"

function GageModifierLifeSteal:OnPlayerManagerKillshot(player_unit, unit_tweak, variant)
	local can_steal = not self._last_killshot_t or self._last_killshot_t + self:value("cooldown") < TimerManager:game():time()

	if can_steal then
		local armor = self:value("armor_restored")

		if armor and armor > 0 then
			player_unit:character_damage():restore_armor(armor)
		end

		local health = self:value("health_restored")

		if health and health > 0 then
			player_unit:character_damage():restore_health(health)
		end

		self._last_killshot_t = TimerManager:game():time()
	end
end
