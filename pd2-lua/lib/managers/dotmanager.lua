DOTManager = DOTManager or class()
local tmp_vec3 = Vector3()

function DOTManager:init()
	self._doted_enemies = {}
	self._dot_grace_period = 0.25
end

function DOTManager:update(t, dt)
	for index = #self._doted_enemies, 1, -1 do
		local dot_info = self._doted_enemies[index]

		if t > dot_info.dot_damage_received_time + self._dot_grace_period and dot_info.dot_counter >= 0.5 then
			self:_damage_dot(dot_info)

			dot_info.dot_counter = 0
		end

		if t > dot_info.dot_damage_received_time + dot_info.dot_length then
			table.remove(self._doted_enemies, index)
		else
			dot_info.dot_counter = dot_info.dot_counter + dt
		end
	end
end

function DOTManager:add_doted_enemy(enemy_unit, dot_damage_received_time, weapon_unit, dot_length, dot_damage, hurt_animation, variant, weapon_id)
	local dot_info = self:_add_doted_enemy(enemy_unit, dot_damage_received_time, weapon_unit, dot_length, dot_damage, hurt_animation, variant, weapon_id)
end

function DOTManager:sync_add_dot_damage(enemy_unit, dot_damage_received_time, weapon_unit, dot_length, dot_damage)
	if enemy_unit then
		local t = TimerManager:game():time()

		self:_add_doted_enemy(enemy_unit, t, weapon_unit, dot_length, dot_damage)
	end
end

function DOTManager:_add_doted_enemy(enemy_unit, dot_damage_received_time, weapon_unit, dot_length, dot_damage, hurt_animation, variant, weapon_id)
	local contains = false

	if self._doted_enemies then
		for _, dot_info in ipairs(self._doted_enemies) do
			if dot_info.enemy_unit == enemy_unit then
				if dot_info.dot_damage_received_time + dot_info.dot_length < dot_damage_received_time + dot_length then
					dot_info.dot_damage_received_time = dot_damage_received_time
					dot_info.dot_length = dot_length
				end

				dot_info.hurt_animation = dot_info.hurt_animation or hurt_animation
				contains = true
			end
		end

		if not contains then
			local dot_info = {
				dot_counter = 0,
				enemy_unit = enemy_unit,
				dot_damage_received_time = dot_damage_received_time,
				weapon_unit = weapon_unit,
				dot_length = dot_length,
				dot_damage = dot_damage,
				hurt_animation = hurt_animation,
				variant = variant,
				weapon_id = weapon_id
			}

			table.insert(self._doted_enemies, dot_info)
			self:check_achievemnts(enemy_unit, dot_damage_received_time)
		end
	end
end

function DOTManager:check_achievemnts(unit, t)
	if not unit and not alive(unit) then
		return
	end

	if not unit:base() or not unit:base()._tweak_table then
		return
	end

	if CopDamage.is_civilian(unit:base()._tweak_table) then
		return
	end

	local dotted_enemies_by_variant = {}

	for _, data in ipairs(self._doted_enemies) do
		dotted_enemies_by_variant[data.variant] = dotted_enemies_by_variant[data.variant] or {}

		table.insert(dotted_enemies_by_variant[data.variant], data)
	end

	local variant_count_pass, all_pass = nil

	for achievement, achievement_data in pairs(tweak_data.achievement.dot_achievements) do
		variant_count_pass = not achievement_data.count or achievement_data.variant and dotted_enemies_by_variant[achievement_data.variant] and achievement_data.count <= #dotted_enemies_by_variant[achievement_data.variant]
		all_pass = variant_count_pass

		if all_pass and not managers.achievment:award_data(achievement_data) then
			Application:debug("[DOTManager] dot_achievements:", achievement)
		end
	end
end

function DOTManager:_damage_dot(dot_info)
	local attacker_unit = managers.player:player_unit()
	local col_ray = {
		unit = dot_info.enemy_unit
	}
	local damage = dot_info.dot_damage
	local ignite_character = false
	local weapon_unit = dot_info.weapon_unit
	local weapon_id = dot_info.weapon_id

	if dot_info.variant and dot_info.variant == "poison" then
		PoisonBulletBase:give_damage_dot(col_ray, weapon_unit, attacker_unit, damage, dot_info.hurt_animation, weapon_id)
	end
end

function DOTManager:create_dot_data(type, custom_data)
	local dot_data = deep_clone(tweak_data:get_dot_type_data(type))

	if custom_data then
		dot_data.dot_length = custom_data.dot_length or dot_data.dot_length
		dot_data.hurt_animation_chance = custom_data.hurt_animation_chance or dot_data.hurt_animation_chance
	end

	return dot_data
end

function DOTManager:on_simulation_ended()
	self._doted_enemies = {}
end
