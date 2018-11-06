GrenadeBase = GrenadeBase or class(ProjectileBase)
GrenadeBase.EVENT_IDS = {
	detonate = 1
}
local mvec1 = Vector3()
local mvec2 = Vector3()

function GrenadeBase:init(unit)
	GrenadeBase.super.init(self, unit)

	self._variant = "explosion"
end

function GrenadeBase:_setup_server_data()
	self._slot_mask = managers.slot:get_mask("trip_mine_targets")

	if self._init_timer then
		self._timer = self._init_timer
	end
end

function GrenadeBase:update(unit, t, dt)
	if self._timer then
		self._timer = self._timer - dt

		if self._timer <= 0 then
			self._timer = nil

			self:_detonate()

			return
		end
	end

	GrenadeBase.super.update(self, unit, t, dt)
end

function GrenadeBase:clbk_impact(...)
	self:_detonate()
end

function GrenadeBase:_on_collision(col_ray)
	self:_detonate()
end

function GrenadeBase:_detonate()
	print("no _detonate function for grenade base")
end

function GrenadeBase:_detonate_on_client()
	print("no _detonate_on_client function for grenade base")
end

function GrenadeBase:sync_net_event(event_id)
	if event_id == GrenadeBase.EVENT_IDS.detonate then
		self:_detonate_on_client()
	end
end

function GrenadeBase:add_damage_result(unit, is_dead, damage_percent)
	if not alive(self._thrower_unit) or self._thrower_unit ~= managers.player:player_unit() then
		return
	end

	local unit_type = unit:base()._tweak_table
	local is_civlian = unit:character_damage().is_civilian(unit_type)
	local is_gangster = unit:character_damage().is_gangster(unit_type)
	local is_cop = unit:character_damage().is_cop(unit_type)

	if is_civlian then
		return
	end

	local weapon_id = tweak_data.blackmarket.projectiles[self:projectile_entry()].weapon_id

	if weapon_id then
		managers.statistics:shot_fired({
			skip_bullet_count = true,
			hit = true,
			name_id = weapon_id
		})
	end

	table.insert(self._damage_results, is_dead)

	local hit_count = #self._damage_results
	local kill_count = 0

	for i, death in ipairs(self._damage_results) do
		kill_count = kill_count + (death and 1 or 0)
	end

	self:_check_achievements(unit, is_dead, damage_percent, hit_count, kill_count)
end

function GrenadeBase:_check_achievements(unit, is_dead, damage_percent, hit_count, kill_count)
	local enemy_base = unit:base()
	local unit_type = enemy_base._tweak_table
	local is_gangster = unit:character_damage().is_gangster(unit_type)
	local is_cop = unit:character_damage().is_cop(unit_type)
	local is_civilian = unit:character_damage().is_civilian(unit_type)
	local is_crouching = alive(managers.player:player_unit()) and managers.player:player_unit():movement() and managers.player:player_unit():movement():crouching()
	local count_pass, grenade_type_pass, kill_pass, distance_pass, enemy_pass, enemies_pass, flying_strike_pass, timer_pass, difficulty_pass, job_pass, crouching_pass, session_kill_pass, is_civilian_pass, explosive_pass, tags_all_pass, tags_any_pass, player_state_pass, all_pass, memory = nil

	for achievement, achievement_data in pairs(tweak_data.achievement.grenade_achievements) do
		count_pass = not achievement_data.count or achievement_data.count <= (achievement_data.kill and kill_count or hit_count)
		grenade_type_pass = not achievement_data.grenade_type or achievement_data.grenade_type == self:projectile_entry()
		kill_pass = not achievement_data.kill or is_dead
		enemy_pass = not achievement_data.enemy or unit_type == achievement_data.enemy
		enemies_pass = not achievement_data.enemies or table.contains(achievement_data.enemies, unit_type)
		difficulty_pass = not achievement_data.difficulties or table.contains(achievement_data.difficulties, Global.game_settings.difficulty)
		job_pass = not achievement_data.job or managers.job:current_real_job_id() == achievement_data.job
		crouching_pass = not achievement_data.crouching or is_crouching
		session_kill_pass = not achievement_data.session_kills or achievement_data.session_kills <= managers.statistics:session_killed_by_projectile(achievement_data.grenade_type)
		is_civilian_pass = achievement_data.is_civilian == nil and true or achievement_data.is_civilian == is_civilian
		tags_all_pass = not achievement_data.enemy_tags_all or enemy_base:has_all_tags(achievement_data.enemy_tags_all)
		tags_any_pass = not achievement_data.enemy_tags_any or enemy_base:has_any_tag(achievement_data.enemy_tags_any)
		player_state_pass = not achievement_data.player_state or achievement_data.player_state == managers.player:current_state()
		flying_strike_pass = not achievement_data.flying_strike

		if unit_type == "spooc" then
			local spooc_action = unit:movement()._active_actions[1]

			if spooc_action and spooc_action:type() == "spooc" then
				flying_strike_pass = flying_strike_pass or spooc_action:is_flying_strike()
			end
		end

		distance_pass = not achievement_data.distance

		if not distance_pass then
			mvector3.set(mvec1, self._spawn_position)
			mvector3.set(mvec2, unit:position())

			local distance = mvector3.distance_sq(mvec1, mvec2)
			distance_pass = distance >= achievement_data.distance * achievement_data.distance
		end

		timer_pass = not achievement_data.timer

		if achievement_data.timer and is_dead then
			local memory_name = "gre_ach_" .. achievement
			memory = managers.job:get_memory(memory_name, true)
			local t = Application:time()

			if memory then
				table.insert(memory, t)

				for i = #memory, 1, -1 do
					if achievement_data.timer <= t - memory[i] then
						table.remove(memory, i)
					end
				end

				timer_pass = achievement_data.kill_count <= #memory

				managers.job:set_memory(memory_name, memory, true)
			else
				managers.job:set_memory(memory_name, {
					t
				}, true)
			end
		end

		explosive_pass = achievement_data.explosive == nil

		if achievement_data.explosive ~= nil then
			explosive_pass = tweak_data.blackmarket.projectiles[self:projectile_entry()].is_explosive == achievement_data.explosive
		end

		all_pass = count_pass and grenade_type_pass and kill_pass and distance_pass and enemy_pass and enemies_pass and flying_strike_pass and timer_pass and difficulty_pass and job_pass and crouching_pass and session_kill_pass and is_civilian_pass and explosive_pass and tags_all_pass and tags_any_pass and player_state_pass

		if all_pass then
			if achievement_data.success then
				if achievement_data.stat then
					managers.achievment:add_heist_success_award_progress(achievement_data.stat)
				elseif achievement_data.award then
					managers.achievment:add_heist_success_award(achievement_data.award)
				end
			elseif achievement_data.stat then
				managers.achievment:award_progress(achievement_data.stat)
			elseif achievement_data.award then
				managers.achievment:award(achievement_data.award)
			elseif achievement_data.challenge_stat then
				managers.challenge:award_progress(achievement_data.challenge_stat)
			elseif achievement_data.trophy_stat then
				managers.custom_safehouse:award(achievement_data.trophy_stat)
			elseif achievement_data.challenge_award then
				managers.challenge:award(achievement_data.challenge_award)
			end
		end
	end
end

function GrenadeBase:clbk_impact(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	self:_detonate(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
end

function GrenadeBase:save(data)
	local state = {
		timer = self._timer
	}
	data.GrenadeBase = state
end

function GrenadeBase:load(data)
	local state = data.GrenadeBase
	self._timer = state.timer
end
