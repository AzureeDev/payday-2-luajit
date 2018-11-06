GageModifierMeleeInvincibility = GageModifierMeleeInvincibility or class(GageModifier)
GageModifierMeleeInvincibility._type = "GageModifierMeleeInvincibility"
GageModifierMeleeInvincibility.default_value = "time"

function GageModifierMeleeInvincibility:OnPlayerManagerKillshot(player_unit, unit_tweak, variant)
	if variant == "melee" and table.contains(StatisticsManager.special_unit_ids, unit_tweak) then
		self._special_kill_t = TimerManager:game():time()
	end
end

function GageModifierMeleeInvincibility:modify_value(id, value)
	if self._special_kill_t and id == "PlayerDamage:CheckCanTakeDamage" and TimerManager:game():time() <= self._special_kill_t + self:value() then
		return false
	end

	return value
end
