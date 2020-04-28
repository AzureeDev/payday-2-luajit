ModifierEnemyHealthAndDamageByWave = ModifierEnemyHealthAndDamageByWave or class(BaseModifier)
ModifierEnemyHealthAndDamageByWave._type = "ModifierEnemyHealthAndDamageByWave"

function ModifierEnemyHealthAndDamageByWave:init(data)
	ModifierEnemyHealthAndDamageByWave.super.init(self, data)

	self._waves = data.waves
	self._damage_exclude_list = data.excluded_enemies and data.excluded_enemies.damage
	self._health_exclude_list = data.excluded_enemies and data.excluded_enemies.health
end

function ModifierEnemyHealthAndDamageByWave:get_health_multiplier()
	local current_wave = managers.skirmish:current_wave_number()

	return self._waves[current_wave].health
end

function ModifierEnemyHealthAndDamageByWave:get_damage_multiplier()
	local current_wave = managers.skirmish:current_wave_number()

	return self._waves[current_wave].damage
end

function ModifierEnemyHealthAndDamageByWave:modify_value(id, value, ...)
	if id == "PlayerDamage:TakeDamageBullet" then
		local tweak_name = select(1, ...)
		local is_included = not self._damage_exclude_list or not table.contains(self._damage_exclude_list, tweak_name)

		if is_included then
			return value * self:get_damage_multiplier()
		end
	end

	if id == "CopDamage:InitialHealth" then
		local tweak_name = select(1, ...)
		local is_included = not self._health_exclude_list or not table.contains(self._health_exclude_list, tweak_name)
		local is_enemy = table.index_of(tweak_data.character:enemy_list(), tweak_name) ~= -1

		if is_included and is_enemy then
			return value * self:get_health_multiplier()
		end
	end

	return value
end
