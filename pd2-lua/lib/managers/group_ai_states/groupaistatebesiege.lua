GroupAIStateBesiege = GroupAIStateBesiege or class(GroupAIStateBase)
GroupAIStateBesiege._MAX_SIMULTANEOUS_SPAWNS = 3

function GroupAIStateBesiege:init(group_ai_state)
	GroupAIStateBesiege.super.init(self)

	if Network:is_server() and managers.navigation:is_data_ready() then
		self:_queue_police_upd_task()
	end

	self._tweak_data = tweak_data.group_ai[group_ai_state]
	self._spawn_group_timers = {}
	self._graph_distance_cache = {}
end

function GroupAIStateBesiege:_init_misc_data()
	GroupAIStateBesiege.super._init_misc_data(self)

	if managers.navigation:is_data_ready() then
		self._nr_dynamic_waves = 0
		self._nr_waves = 0

		self:_create_area_data()

		self._task_data = {
			reenforce = {
				next_dispatch_t = 0,
				tasks = {}
			},
			recon = {
				next_dispatch_t = 0,
				tasks = {}
			},
			assault = {
				is_first = true,
				disabled = true
			},
			regroup = {}
		}
		local all_areas = self._area_data

		for u_key, u_data in pairs(self._police) do
			if not u_data.assigned_area then
				local nav_seg = u_data.unit:movement():nav_tracker():nav_segment()

				self:set_enemy_assigned(self:get_area_from_nav_seg_id(nav_seg), u_key)
			end
		end
	end
end

function GroupAIStateBesiege:update(t, dt)
	GroupAIStateBesiege.super.update(self, t, dt)

	if Network:is_server() then
		self:_queue_police_upd_task()

		if managers.navigation:is_data_ready() and self._draw_enabled then
			self:_draw_enemy_activity(t)
			self:_draw_spawn_points()
		end
	end
end

function GroupAIStateBesiege:paused_update(t, dt)
	GroupAIStateBesiege.super.paused_update(self, t, dt)

	if Network:is_server() and managers.navigation:is_data_ready() and self._draw_enabled then
		self:_draw_enemy_activity(t)
		self:_draw_spawn_points()
	end
end

function GroupAIStateBesiege:_queue_police_upd_task()
	if not self._police_upd_task_queued then
		self._police_upd_task_queued = true

		managers.enemy:queue_task("GroupAIStateBesiege._upd_police_activity", self._upd_police_activity, self, self._t + (next(self._spawning_groups) and 0.4 or 2))
	end
end

function GroupAIStateBesiege:assign_enemy_to_group_ai(unit, team_id)
	local u_tracker = unit:movement():nav_tracker()
	local seg = u_tracker:nav_segment()
	local area = self:get_area_from_nav_seg_id(seg)
	local current_unit_type = tweak_data.levels:get_ai_group_type()
	local u_name = unit:name()
	local u_category = nil

	for cat_name, category in pairs(tweak_data.group_ai.unit_categories) do
		local units = category.unit_types[current_unit_type]

		for _, test_u_name in ipairs(units) do
			if u_name == test_u_name then
				u_category = cat_name

				break
			end
		end
	end

	local group_desc = {
		size = 1,
		type = u_category or "custom"
	}
	local group = self:_create_group(group_desc)
	group.team = self._teams[team_id]
	local grp_objective = nil
	local objective = unit:brain():objective()
	local grp_obj_type = self._task_data.assault.active and "assault_area" or "recon_area"

	if objective then
		grp_objective = {
			type = grp_obj_type,
			area = objective.area or objective.nav_seg and self:get_area_from_nav_seg_id(objective.nav_seg) or area
		}
		objective.grp_objective = grp_objective
	else
		grp_objective = {
			type = grp_obj_type,
			area = area
		}
	end

	grp_objective.moving_out = false
	group.objective = grp_objective
	group.has_spawned = true

	self:_add_group_member(group, unit:key())
	self:set_enemy_assigned(area, unit:key())
end

function GroupAIStateBesiege:assign_enemy_to_existing_group(unit, group)
	self:_add_group_member(group, unit:key())
	self:set_enemy_assigned(group.objective.area, unit:key())
end

function GroupAIStateBesiege:on_enemy_unregistered(unit)
	GroupAIStateBesiege.super.on_enemy_unregistered(self, unit)

	if self._is_server then
		self:set_enemy_assigned(nil, unit:key())

		local objective = unit:brain():objective()

		if objective and objective.fail_clbk then
			local fail_clbk = objective.fail_clbk
			objective.fail_clbk = nil

			fail_clbk(unit)
		end
	end
end

function GroupAIStateBesiege:_upd_police_activity()
	self._police_upd_task_queued = false

	if self._police_activity_blocked then
		return
	end

	if self._ai_enabled then
		self:_upd_SO()
		self:_upd_grp_SO()
		self:_check_spawn_phalanx()
		self:_check_phalanx_group_has_spawned()
		self:_check_phalanx_damage_reduction_increase()

		if self._enemy_weapons_hot then
			self:_claculate_drama_value()
			self:_upd_regroup_task()
			self:_upd_reenforce_tasks()
			self:_upd_recon_tasks()
			self:_upd_assault_task()
			self:_begin_new_tasks()
			self:_upd_group_spawning()
			self:_upd_groups()
		end
	end

	self:_queue_police_upd_task()
end

function GroupAIStateBesiege:_upd_SO()
	local t = self._t
	local trash = nil

	for id, so in pairs(self._special_objectives) do
		if so.delay_t < t then
			if so.data.interval then
				so.delay_t = t + so.data.interval
			end

			if math.random() <= so.chance then
				local so_data = so.data
				so.chance = so_data.base_chance

				if so_data.objective.follow_unit and not alive(so_data.objective.follow_unit) then
					trash = trash or {}

					table.insert(trash, id)
				else
					local closest_u_data = GroupAIStateBase._execute_so(self, so_data, so.rooms, so.administered)

					if closest_u_data then
						if so.remaining_usage then
							if so.remaining_usage == 1 then
								trash = trash or {}

								table.insert(trash, id)
							else
								so.remaining_usage = so.remaining_usage - 1
							end
						end

						if so.non_repeatable then
							so.administered[closest_u_data.unit:key()] = true
						end
					end
				end
			else
				so.chance = so.chance + so.data.chance_inc
			end

			if not so.data.interval then
				trash = trash or {}

				table.insert(trash, id)
			end
		end
	end

	if trash then
		for _, so_id in ipairs(trash) do
			self:remove_special_objective(so_id)
		end
	end
end

function GroupAIStateBesiege:_begin_new_tasks()
	local all_areas = self._area_data
	local nav_manager = managers.navigation
	local all_nav_segs = nav_manager._nav_segments
	local task_data = self._task_data
	local t = self._t
	local reenforce_candidates = nil
	local reenforce_data = task_data.reenforce

	if reenforce_data.next_dispatch_t and reenforce_data.next_dispatch_t < t then
		reenforce_candidates = {}
	end

	local recon_candidates, are_recon_candidates_safe = nil
	local recon_data = task_data.recon

	if recon_data.next_dispatch_t and recon_data.next_dispatch_t < t and not task_data.assault.active and not task_data.regroup.active then
		recon_candidates = {}
	end

	local assault_candidates = nil
	local assault_data = task_data.assault

	if self._difficulty_value > 0 and assault_data.next_dispatch_t and assault_data.next_dispatch_t < t and not task_data.regroup.active then
		assault_candidates = {}
	end

	if not reenforce_candidates and not recon_candidates and not assault_candidates then
		return
	end

	local found_areas = {}
	local to_search_areas = {}

	for area_id, area in pairs(all_areas) do
		if area.spawn_points then
			for _, sp_data in pairs(area.spawn_points) do
				if sp_data.delay_t <= t and not all_nav_segs[sp_data.nav_seg].disabled then
					table.insert(to_search_areas, area)

					found_areas[area_id] = true

					break
				end
			end
		end

		if not found_areas[area_id] and area.spawn_groups then
			for _, sp_data in pairs(area.spawn_groups) do
				if sp_data.delay_t <= t and not all_nav_segs[sp_data.nav_seg].disabled then
					table.insert(to_search_areas, area)

					found_areas[area_id] = true

					break
				end
			end
		end
	end

	if #to_search_areas == 0 then
		return
	end

	if assault_candidates and self._hunt_mode then
		for criminal_key, criminal_data in pairs(self._char_criminals) do
			if not criminal_data.status then
				local nav_seg = criminal_data.tracker:nav_segment()
				local area = self:get_area_from_nav_seg_id(nav_seg)
				found_areas[area] = true

				table.insert(assault_candidates, area)
			end
		end
	end

	local i = 1

	repeat
		local area = to_search_areas[i]
		local force_factor = area.factors.force
		local demand = force_factor and force_factor.force
		local nr_police = table.size(area.police.units)
		local nr_criminals = table.size(area.criminal.units)

		if reenforce_candidates and demand and demand > 0 and nr_criminals == 0 then
			local area_free = true

			for i_task, reenforce_task_data in ipairs(reenforce_data.tasks) do
				if reenforce_task_data.target_area == area then
					area_free = false

					break
				end
			end

			if area_free then
				table.insert(reenforce_candidates, area)
			end
		end

		if recon_candidates and (area.loot or area.hostages) then
			local occupied = nil

			for group_id, group in pairs(self._groups) do
				if group.objective.target_area == area or group.objective.area == area then
					occupied = true

					break
				end
			end

			if not occupied then
				local is_area_safe = nr_criminals == 0

				if is_area_safe then
					if are_recon_candidates_safe then
						table.insert(recon_candidates, area)
					else
						are_recon_candidates_safe = true
						recon_candidates = {
							area
						}
					end
				elseif not are_recon_candidates_safe then
					table.insert(recon_candidates, area)
				end
			end
		end

		if assault_candidates then
			for criminal_key, _ in pairs(area.criminal.units) do
				if not self._criminals[criminal_key].status and not self._criminals[criminal_key].is_deployable then
					table.insert(assault_candidates, area)

					break
				end
			end
		end

		if nr_criminals == 0 then
			for neighbour_area_id, neighbour_area in pairs(area.neighbours) do
				if not found_areas[neighbour_area_id] then
					table.insert(to_search_areas, neighbour_area)

					found_areas[neighbour_area_id] = true
				end
			end
		end

		i = i + 1
	until i > #to_search_areas

	if assault_candidates and #assault_candidates > 0 then
		self:_begin_assault_task(assault_candidates)

		recon_candidates = nil
	end

	if recon_candidates and #recon_candidates > 0 then
		local recon_area = recon_candidates[math.random(#recon_candidates)]

		self:_begin_recon_task(recon_area)
	end

	if reenforce_candidates and #reenforce_candidates > 0 then
		local lucky_i_candidate = math.random(#reenforce_candidates)
		local reenforce_area = reenforce_candidates[lucky_i_candidate]

		self:_begin_reenforce_task(reenforce_area)

		recon_candidates = nil
	end
end

function GroupAIStateBesiege:_begin_assault_task(assault_areas)
	local assault_task = self._task_data.assault
	assault_task.active = true
	assault_task.next_dispatch_t = nil
	assault_task.target_areas = assault_areas
	assault_task.phase = "anticipation"
	assault_task.start_t = self._t
	local anticipation_duration = self:_get_anticipation_duration(self._tweak_data.assault.anticipation_duration, assault_task.is_first)
	assault_task.is_first = nil
	assault_task.phase_end_t = self._t + anticipation_duration
	assault_task.force = math.ceil(self:_get_difficulty_dependent_value(self._tweak_data.assault.force) * self:_get_balancing_multiplier(self._tweak_data.assault.force_balance_mul))
	assault_task.use_smoke = true
	assault_task.use_smoke_timer = 0
	assault_task.use_spawn_event = true
	assault_task.force_spawned = 0

	if self._hostage_headcount > 0 then
		assault_task.phase_end_t = assault_task.phase_end_t + self:_get_difficulty_dependent_value(self._tweak_data.assault.hostage_hesitation_delay)
		assault_task.is_hesitating = true
		assault_task.voice_delay = self._t + (assault_task.phase_end_t - self._t) / 2
	end

	self._downs_during_assault = 0

	if self._hunt_mode then
		assault_task.phase_end_t = 0
	else
		managers.hud:setup_anticipation(anticipation_duration)
		managers.hud:start_anticipation()
	end

	if self._draw_drama then
		table.insert(self._draw_drama.assault_hist, {
			self._t
		})
	end

	self._task_data.recon.tasks = {}
end

function GroupAIStateBesiege:assault_phase_end_time()
	local task_data = self._task_data.assault
	local end_t = task_data and task_data.phase_end_t

	if end_t and task_data.phase == "sustain" then
		end_t = managers.modifiers:modify_value("GroupAIStateBesiege:SustainEndTime", end_t)
	end

	return end_t
end

function GroupAIStateBesiege:_upd_assault_task()
	local task_data = self._task_data.assault

	if not task_data.active then
		return
	end

	local t = self._t

	self:_assign_recon_groups_to_retire()

	local force_pool = self:_get_difficulty_dependent_value(self._tweak_data.assault.force_pool) * self:_get_balancing_multiplier(self._tweak_data.assault.force_pool_balance_mul)
	local task_spawn_allowance = force_pool - (self._hunt_mode and 0 or task_data.force_spawned)

	if task_data.phase == "anticipation" then
		if task_spawn_allowance <= 0 then
			print("spawn_pool empty: -----------FADE-------------")

			task_data.phase = "fade"
			task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
		elseif task_data.phase_end_t < t or self._drama_data.zone == "high" then
			self._assault_number = self._assault_number + 1

			managers.mission:call_global_event("start_assault")
			managers.hud:start_assault(self._assault_number)
			managers.groupai:dispatch_event("start_assault", self._assault_number)
			self:_set_rescue_state(false)

			task_data.phase = "build"
			task_data.phase_end_t = self._t + self._tweak_data.assault.build_duration
			task_data.is_hesitating = nil

			self:set_assault_mode(true)
			managers.trade:set_trade_countdown(false)
		else
			managers.hud:check_anticipation_voice(task_data.phase_end_t - t)
			managers.hud:check_start_anticipation_music(task_data.phase_end_t - t)

			if task_data.is_hesitating and task_data.voice_delay < self._t then
				if self._hostage_headcount > 0 then
					local best_group = nil

					for _, group in pairs(self._groups) do
						if not best_group or group.objective.type == "reenforce_area" then
							best_group = group
						elseif best_group.objective.type ~= "reenforce_area" and group.objective.type ~= "retire" then
							best_group = group
						end
					end

					if best_group and self:_voice_delay_assault(best_group) then
						task_data.is_hesitating = nil
					end
				else
					task_data.is_hesitating = nil
				end
			end
		end
	elseif task_data.phase == "build" then
		if task_spawn_allowance <= 0 then
			task_data.phase = "fade"
			task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
		elseif task_data.phase_end_t < t or self._drama_data.zone == "high" then
			local sustain_duration = math.lerp(self:_get_difficulty_dependent_value(self._tweak_data.assault.sustain_duration_min), self:_get_difficulty_dependent_value(self._tweak_data.assault.sustain_duration_max), math.random()) * self:_get_balancing_multiplier(self._tweak_data.assault.sustain_duration_balance_mul)

			managers.modifiers:run_func("OnEnterSustainPhase", sustain_duration)

			task_data.phase = "sustain"
			task_data.phase_end_t = t + sustain_duration
		end
	elseif task_data.phase == "sustain" then
		local end_t = self:assault_phase_end_time()
		task_spawn_allowance = managers.modifiers:modify_value("GroupAIStateBesiege:SustainSpawnAllowance", task_spawn_allowance, force_pool)

		if task_spawn_allowance <= 0 then
			task_data.phase = "fade"
			task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
		elseif end_t < t and not self._hunt_mode then
			task_data.phase = "fade"
			task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
		end
	else
		local end_assault = false
		local enemies_left = self:_count_police_force("assault")

		if not self._hunt_mode then
			local enemies_defeated_time_limit = 30
			local drama_engagement_time_limit = 60

			if managers.skirmish:is_skirmish() then
				enemies_defeated_time_limit = 0
				drama_engagement_time_limit = 0
			end

			local min_enemies_left = 50
			local enemies_defeated = enemies_left < min_enemies_left
			local taking_too_long = t > task_data.phase_end_t + enemies_defeated_time_limit

			if enemies_defeated or taking_too_long then
				if not task_data.said_retreat then
					task_data.said_retreat = true

					self:_police_announce_retreat()
				elseif task_data.phase_end_t < t then
					local drama_pass = self._drama_data.amount < tweak_data.drama.assault_fade_end
					local engagement_pass = self:_count_criminals_engaged_force(11) <= 10
					local taking_too_long = t > task_data.phase_end_t + drama_engagement_time_limit

					if drama_pass and engagement_pass or taking_too_long then
						end_assault = true
					end
				end
			end

			if task_data.force_end or end_assault then
				print("assault task clear")

				task_data.active = nil
				task_data.phase = nil
				task_data.said_retreat = nil
				task_data.force_end = nil
				local force_regroup = task_data.force_regroup
				task_data.force_regroup = nil

				if self._draw_drama then
					self._draw_drama.assault_hist[#self._draw_drama.assault_hist][2] = t
				end

				managers.mission:call_global_event("end_assault")
				self:_begin_regroup_task(force_regroup)

				return
			end
		end
	end

	if self._drama_data.amount <= tweak_data.drama.low then
		for criminal_key, criminal_data in pairs(self._player_criminals) do
			self:criminal_spotted(criminal_data.unit)

			for group_id, group in pairs(self._groups) do
				if group.objective.charge then
					for u_key, u_data in pairs(group.units) do
						u_data.unit:brain():clbk_group_member_attention_identified(nil, criminal_key)
					end
				end
			end
		end
	end

	local primary_target_area = task_data.target_areas[1]

	if self:is_area_safe_assault(primary_target_area) then
		local target_pos = primary_target_area.pos
		local nearest_area, nearest_dis = nil

		for criminal_key, criminal_data in pairs(self._player_criminals) do
			if not criminal_data.status then
				local dis = mvector3.distance_sq(target_pos, criminal_data.m_pos)

				if not nearest_dis or dis < nearest_dis then
					nearest_dis = dis
					nearest_area = self:get_area_from_nav_seg_id(criminal_data.tracker:nav_segment())
				end
			end
		end

		if nearest_area then
			primary_target_area = nearest_area
			task_data.target_areas[1] = nearest_area
		end
	end

	local nr_wanted = task_data.force - self:_count_police_force("assault")

	if task_data.phase == "anticipation" then
		nr_wanted = nr_wanted - 5
	end

	if nr_wanted > 0 and task_data.phase ~= "fade" then
		local used_event = nil

		if task_data.use_spawn_event and task_data.phase ~= "anticipation" then
			task_data.use_spawn_event = false

			if self:_try_use_task_spawn_event(t, primary_target_area, "assault") then
				used_event = true
			end
		end

		if not used_event then
			if next(self._spawning_groups) then
				-- Nothing
			else
				local spawn_group, spawn_group_type = self:_find_spawn_group_near_area(primary_target_area, self._tweak_data.assault.groups, nil, nil, nil)

				if spawn_group then
					local grp_objective = {
						attitude = "avoid",
						stance = "hos",
						pose = "crouch",
						type = "assault_area",
						area = spawn_group.area,
						coarse_path = {
							{
								spawn_group.area.pos_nav_seg,
								spawn_group.area.pos
							}
						}
					}

					self:_spawn_in_group(spawn_group, spawn_group_type, grp_objective, task_data)
				end
			end
		end
	end

	if task_data.phase ~= "anticipation" then
		if task_data.use_smoke_timer < t then
			task_data.use_smoke = true
		end

		self:detonate_queued_smoke_grenades()
	end

	self:_assign_enemy_groups_to_assault(task_data.phase)
end

function GroupAIStateBesiege:_verify_anticipation_spawn_point(sp_data)
	local sp_nav_seg = sp_data.nav_seg
	local area = self:get_area_from_nav_seg_id(sp_nav_seg)

	if area.is_safe then
		return true
	else
		for criminal_key, c_data in pairs(self._criminals) do
			if not c_data.status and not c_data.is_deployable and mvector3.distance(sp_data.pos, c_data.m_pos) < 2500 and math.abs(sp_data.pos.z - c_data.m_pos.z) < 300 then
				return
			end
		end
	end

	return true
end

function GroupAIStateBesiege:is_smoke_grenade_active()
	return self._smoke_end_t and Application:time() < self._smoke_end_t
end

function GroupAIStateBesiege:is_cs_grenade_active()
	return self._cs_end_t and Application:time() < self._cs_end_t
end

function GroupAIStateBesiege:_begin_reenforce_task(reenforce_area)
	local new_task = {
		use_spawn_event = true,
		target_area = reenforce_area,
		start_t = self._t
	}

	table.insert(self._task_data.reenforce.tasks, new_task)

	self._task_data.reenforce.active = true
	self._task_data.reenforce.next_dispatch_t = self._t + self:_get_difficulty_dependent_value(self._tweak_data.reenforce.interval)
end

function GroupAIStateBesiege:_begin_recon_task(recon_area)
	local new_task = {
		use_smoke = true,
		use_spawn_event = true,
		target_area = recon_area,
		start_t = self._t
	}

	table.insert(self._task_data.recon.tasks, new_task)

	self._task_data.recon.next_dispatch_t = nil
end

function GroupAIStateBesiege:_begin_regroup_task(force_regroup)
	self._task_data.regroup.start_t = self._t
	self._task_data.regroup.end_t = self._t + (force_regroup and 0.1 or self:_get_difficulty_dependent_value(self._tweak_data.regroup.duration))
	self._task_data.regroup.active = true

	if self._draw_drama then
		table.insert(self._draw_drama.regroup_hist, {
			self._t
		})
	end

	self:_assign_assault_groups_to_retire()
end

function GroupAIStateBesiege:_end_regroup_task()
	if self._task_data.regroup.active then
		self._task_data.regroup.active = nil

		managers.trade:set_trade_countdown(true)
		self:set_assault_mode(false)

		if not self._smoke_grenade_ignore_control then
			managers.network:session():send_to_peers_synched("sync_smoke_grenade_kill")
			self:sync_smoke_grenade_kill()
		end

		local dmg = self._downs_during_assault
		local limits = tweak_data.group_ai.bain_assault_praise_limits
		local result = dmg < limits[1] and 0 or dmg < limits[2] and 1 or 2

		managers.mission:call_global_event("end_assault_late")
		managers.groupai:dispatch_event("end_assault_late", self._assault_number)
		managers.hud:end_assault(result)
		self:_mark_hostage_areas_as_unsafe()
		self:_set_rescue_state(true)

		if not self._task_data.assault.next_dispatch_t then
			local assault_delay = self._tweak_data.assault.delay
			self._task_data.assault.next_dispatch_t = self._t + self:_get_difficulty_dependent_value(assault_delay)
		end

		if self._draw_drama then
			self._draw_drama.regroup_hist[#self._draw_drama.regroup_hist][2] = self._t
		end

		self._task_data.recon.next_dispatch_t = self._t
	end
end

function GroupAIStateBesiege:_upd_regroup_task()
	local regroup_task = self._task_data.regroup

	if regroup_task.active then
		self:_assign_assault_groups_to_retire()

		if regroup_task.end_t < self._t or self._drama_data.zone == "low" then
			self:_end_regroup_task()
		end
	end
end

function GroupAIStateBesiege:_find_nearest_safe_area(start_area, start_pos)
	local to_search_areas = {
		group.objective.area
	}
	local found_areas = {
		[group.objective.area] = "init"
	}

	repeat
		local search_area = table.remove(to_search_areas, 1)

		if next(search_area.criminal.units) then
			assault_area = search_area

			break
		else
			for other_area_id, other_area in pairs(search_area.neighbours) do
				if not found_areas[other_area] then
					table.insert(to_search_areas, other_area)

					found_areas[other_area] = search_area
				end
			end
		end
	until #to_search_areas == 0

	local mvec3_dis_sq = mvector3.distance_sq
	local all_areas = self._area_data
	local all_nav_segs = managers.navigation._nav_segments
	local all_doors = managers.navigation._room_doors
	local my_enemy_pos, my_enemy_dis_sq = nil

	for c_key, c_data in pairs(self._criminals) do
		local my_dis = mvec3_dis_sq(start_pos, c_data.m_pos)

		if (not my_enemy_pos or my_enemy_dis_sq < my_dis) and math.abs(mvector3.z(c_data.m_pos) - mvector3.z(start_pos)) < 300 then
			my_enemy_pos = c_data.m_pos
			my_enemy_dis_sq = my_dis
		end
	end

	if not my_enemy_pos or my_enemy_dis_sq > 9000000 then
		return
	end

	local closest_dis, closest_safe_nav_seg_id, closest_area = nil
	local start_neighbours = all_nav_segs[nav_seg_id].neighbours

	for neighbour_seg_id, door_list in pairs(start_neighbours) do
		local neighbour_area = self:get_area_from_nav_seg_id(neighbour_seg_id)

		if not next(neighbour_area.criminal.units) then
			local neighbour_nav_seg = all_nav_segs[neighbour_seg_id]

			if not neighbour_nav_seg.disabled and my_enemy_dis_sq < mvec3_dis_sq(my_enemy_pos, neighbour_nav_seg.pos) then
				for _, i_door in ipairs(door_list) do
					if type(i_door) == "number" then
						local door = all_doors[i_door]
						local my_dis = mvec3_dis_sq(door.center, start_pos)

						if not closest_dis or my_dis < closest_dis then
							closest_dis = my_dis
							closest_safe_nav_seg_id = neighbour_seg_id
							closest_area = neighbour_area
						end
					end
				end
			end
		end
	end

	return closest_area, closest_safe_nav_seg_id
end

function GroupAIStateBesiege:_upd_recon_tasks()
	local task_data = self._task_data.recon.tasks[1]

	self:_assign_enemy_groups_to_recon()

	if not task_data then
		return
	end

	local t = self._t

	self:_assign_assault_groups_to_retire()

	local target_pos = task_data.target_area.pos
	local nr_wanted = self:_get_difficulty_dependent_value(self._tweak_data.recon.force) - self:_count_police_force("recon")

	if nr_wanted <= 0 then
		return
	end

	local used_event, used_spawn_points, reassigned = nil

	if task_data.use_spawn_event then
		task_data.use_spawn_event = false

		if self:_try_use_task_spawn_event(t, task_data.target_area, "recon") then
			used_event = true
		end
	end

	if not used_event then
		local used_group = nil

		if next(self._spawning_groups) then
			used_group = true
		else
			local spawn_group, spawn_group_type = self:_find_spawn_group_near_area(task_data.target_area, self._tweak_data.recon.groups, nil, nil, callback(self, self, "_verify_anticipation_spawn_point"))

			if spawn_group then
				local grp_objective = {
					attitude = "avoid",
					scan = true,
					stance = "hos",
					type = "recon_area",
					area = spawn_group.area,
					target_area = task_data.target_area
				}

				self:_spawn_in_group(spawn_group, spawn_group_type, grp_objective)

				used_group = true
			end
		end
	end

	if used_event or used_spawn_points or reassigned then
		table.remove(self._task_data.recon.tasks, 1)

		self._task_data.recon.next_dispatch_t = t + math.ceil(self:_get_difficulty_dependent_value(self._tweak_data.recon.interval)) + math.random() * self._tweak_data.recon.interval_variation
	end
end

function GroupAIStateBesiege:_find_spawn_points_near_area(target_area, nr_wanted, target_pos, max_dis, verify_clbk)
	local all_areas = self._area_data
	local all_nav_segs = managers.navigation._nav_segments
	local mvec3_dis = mvector3.distance
	local t = self._t
	local distances = {}
	local s_points = {}
	target_pos = target_pos or target_area.pos
	local to_search_areas = {
		target_area
	}
	local found_areas = {
		[target_area.id] = true
	}

	repeat
		local search_area = table.remove(to_search_areas, 1)
		local spawn_points = search_area.spawn_points

		if spawn_points then
			for _, sp_data in ipairs(spawn_points) do
				if sp_data.delay_t <= t and (not verify_clbk or verify_clbk(sp_data)) then
					local my_dis = mvec3_dis(target_pos, sp_data.pos)

					if not max_dis or my_dis < max_dis then
						local i = #distances

						while i > 0 do
							if distances[i] < my_dis then
								break
							end

							i = i - 1
						end

						if i < #distances then
							if #distances == nr_wanted then
								distances[nr_wanted] = my_dis
								s_points[nr_wanted] = sp_data
							else
								table.remove(distances)
								table.remove(s_points)
								table.insert(distances, i + 1, my_dis)
								table.insert(s_points, i + 1, sp_data)
							end
						elseif i < nr_wanted then
							table.insert(distances, my_dis)
							table.insert(s_points, sp_data)
						end
					end
				end
			end
		end

		if #s_points == nr_wanted then
			break
		end

		for other_area_id, other_area in pairs(all_areas) do
			if not found_areas[other_area_id] and other_area.neighbours[search_area.id] then
				table.insert(to_search_areas, other_area)

				found_areas[other_area_id] = true
			end
		end
	until #to_search_areas == 0

	return #s_points > 0 and s_points
end

local function make_dis_id(from, to)
	local f = from < to and from or to
	local t = to < from and from or to

	return tostring(f) .. "-" .. tostring(t)
end

local function spawn_group_id(spawn_group)
	return spawn_group.mission_element:id()
end

function GroupAIStateBesiege:_find_spawn_group_near_area(target_area, allowed_groups, target_pos, max_dis, verify_clbk)
	local all_areas = self._area_data
	local mvec3_dis = mvector3.distance_sq
	max_dis = max_dis and max_dis * max_dis
	local t = self._t
	local valid_spawn_groups = {}
	local valid_spawn_group_distances = {}
	local total_dis = 0
	target_pos = target_pos or target_area.pos
	local to_search_areas = {
		target_area
	}
	local found_areas = {
		[target_area.id] = true
	}

	repeat
		local search_area = table.remove(to_search_areas, 1)
		local spawn_groups = search_area.spawn_groups

		if spawn_groups then
			for _, spawn_group in ipairs(spawn_groups) do
				if spawn_group.delay_t <= t and (not verify_clbk or verify_clbk(spawn_group)) then
					local dis_id = make_dis_id(spawn_group.nav_seg, target_area.pos_nav_seg)

					if not self._graph_distance_cache[dis_id] then
						local coarse_params = {
							access_pos = "swat",
							from_seg = spawn_group.nav_seg,
							to_seg = target_area.pos_nav_seg,
							id = dis_id
						}
						local path = managers.navigation:search_coarse(coarse_params)

						if path and #path >= 2 then
							local dis = 0
							local current = spawn_group.pos

							for i = 2, #path, 1 do
								local nxt = path[i][2]

								if current and nxt then
									dis = dis + mvector3.distance(current, nxt)
								end

								current = nxt
							end

							self._graph_distance_cache[dis_id] = dis
						end
					end

					if self._graph_distance_cache[dis_id] then
						local my_dis = self._graph_distance_cache[dis_id]

						if not max_dis or my_dis < max_dis then
							total_dis = total_dis + my_dis
							valid_spawn_groups[spawn_group_id(spawn_group)] = spawn_group
							valid_spawn_group_distances[spawn_group_id(spawn_group)] = my_dis
						end
					end
				end
			end
		end

		for other_area_id, other_area in pairs(all_areas) do
			if not found_areas[other_area_id] and other_area.neighbours[search_area.id] then
				table.insert(to_search_areas, other_area)

				found_areas[other_area_id] = true
			end
		end
	until #to_search_areas == 0

	if not next(valid_spawn_group_distances) then
		return
	end

	local time = TimerManager:game():time()
	local timer_can_spawn = false

	for id in pairs(valid_spawn_groups) do
		if not self._spawn_group_timers[id] or self._spawn_group_timers[id] <= time then
			timer_can_spawn = true

			break
		end
	end

	if not timer_can_spawn then
		self._spawn_group_timers = {}
	end

	for id in pairs(valid_spawn_groups) do
		if self._spawn_group_timers[id] and time < self._spawn_group_timers[id] then
			valid_spawn_groups[id] = nil
			valid_spawn_group_distances[id] = nil
		end
	end

	if total_dis == 0 then
		total_dis = 1
	end

	local total_weight = 0
	local candidate_groups = {}
	self._debug_weights = {}
	local dis_limit = 5000

	for i, dis in pairs(valid_spawn_group_distances) do
		local my_wgt = math.lerp(1, 0.2, math.min(1, dis / dis_limit)) * 5
		local my_spawn_group = valid_spawn_groups[i]
		local my_group_types = my_spawn_group.mission_element:spawn_groups()
		my_spawn_group.distance = dis
		total_weight = total_weight + self:_choose_best_groups(candidate_groups, my_spawn_group, my_group_types, allowed_groups, my_wgt)
	end

	if total_weight == 0 then
		return
	end

	for _, group in ipairs(candidate_groups) do
		table.insert(self._debug_weights, clone(group))
	end

	return self:_choose_best_group(candidate_groups, total_weight)
end

function GroupAIStateBesiege:_choose_best_groups(best_groups, group, group_types, allowed_groups, weight)
	local total_weight = 0

	for _, group_type in ipairs(group_types) do
		if tweak_data.group_ai.enemy_spawn_groups[group_type] then
			local cat_weights = allowed_groups[group_type]

			if cat_weights then
				local cat_weight = self:_get_difficulty_dependent_value(cat_weights)
				local mod_weight = weight * cat_weight

				table.insert(best_groups, {
					group = group,
					group_type = group_type,
					wght = mod_weight,
					cat_weight = cat_weight,
					dis_weight = weight
				})

				total_weight = total_weight + mod_weight
			end
		else
			debug_pause("[GroupAIStateBesiege:_choose_best_groups] inexistent spawn_group:", group_type, ". element id:", group.mission_element._id)
		end
	end

	return total_weight
end

function GroupAIStateBesiege:_choose_best_group(best_groups, total_weight)
	local rand_wgt = total_weight * math.random()
	local best_grp, best_grp_type = nil

	for i, candidate in ipairs(best_groups) do
		rand_wgt = rand_wgt - candidate.wght

		if rand_wgt <= 0 then
			self._spawn_group_timers[spawn_group_id(candidate.group)] = TimerManager:game():time() + math.random(15, 20)
			best_grp = candidate.group
			best_grp_type = candidate.group_type
			best_grp.delay_t = self._t + best_grp.interval

			break
		end
	end

	return best_grp, best_grp_type
end

function GroupAIStateBesiege:force_spawn_group(group, group_types, guarantee)
	local best_groups = {}
	local total_weight = self:_choose_best_groups(best_groups, group, group_types, self._tweak_data[self._task_data.assault.active and "assault" or "recon"].groups, 1)

	if total_weight > 0 or guarantee then
		local spawn_group, spawn_group_type = self:_choose_best_group(best_groups, total_weight or 1)

		if spawn_group then
			local grp_objective = {
				attitude = "avoid",
				stance = "hos",
				pose = "crouch",
				type = "assault_area",
				area = spawn_group.area,
				coarse_path = {
					{
						spawn_group.area.pos_nav_seg,
						spawn_group.area.pos
					}
				}
			}

			self:_spawn_in_group(spawn_group, spawn_group_type, grp_objective)
			self:_upd_group_spawning(true)
		end
	end
end

function GroupAIStateBesiege:get_force_spawn_group(group, group_types)
	local best_groups = {}
	local total_weight = self:_choose_best_groups(best_groups, group, group_types, self._tweak_data[self._task_data.assault.active and "assault" or "recon"].groups, 1)

	if total_weight > 0 then
		local spawn_group, spawn_group_type = self:_choose_best_group(best_groups, total_weight)

		if spawn_group then
			return spawn_group, spawn_group_type
		end
	end

	return nil
end

function GroupAIStateBesiege:_spawn_in_individual_groups(grp_objective, spawn_points, task)
	for i_sp, spawn_point in ipairs(spawn_points) do
		local group_desc = {
			size = 1,
			type = "custom"
		}
		local grp_objective_cpy = clone(grp_objective)

		if not grp_objective_cpy.area then
			grp_objective_cpy.area = spawn_point.area
		end

		local group = self:_create_group(group_desc)
		group.objective = grp_objective_cpy
		group.objective.moving_out = true
		local spawn_task = {
			objective = self._create_objective_from_group_objective(grp_objective_cpy),
			spawn_point = spawn_point,
			group = group,
			task = task
		}

		table.insert(self._spawning_groups, spawn_task)
	end
end

function GroupAIStateBesiege._extract_group_desc_structure(spawn_entry_outer, valid_unit_entries)
	for spawn_entry_key, spawn_entry in ipairs(spawn_entry_outer) do
		if spawn_entry.unit then
			table.insert(valid_unit_entries, clone(spawn_entry))
		else
			GroupAIStateBesiege._extract_group_desc_structure(spawn_entry, valid_unit_entries)
		end
	end

	for spawn_entry_key, spawn_entry in pairs(spawn_entry_outer) do
		if (type(spawn_entry_key) ~= "number" or spawn_entry_key > #spawn_entry_outer) and #spawn_entry ~= 0 then
			local i_rand = math.random(#spawn_entry)
			local rand_branch = spawn_entry[i_rand]

			if rand_branch.unit then
				table.insert(valid_unit_entries, clone(rand_branch))
			else
				GroupAIStateBesiege._extract_group_desc_structure(rand_branch, valid_unit_entries)
			end
		end
	end
end

function GroupAIStateBesiege:_get_special_unit_type_count(special_type)
	if not self._special_units[special_type] then
		return 0
	end

	return table.size(self._special_units[special_type])
end

function GroupAIStateBesiege:_spawn_in_group(spawn_group, spawn_group_type, grp_objective, ai_task)
	local spawn_group_desc = tweak_data.group_ai.enemy_spawn_groups[spawn_group_type]
	local wanted_nr_units = nil

	if type(spawn_group_desc.amount) == "number" then
		wanted_nr_units = spawn_group_desc.amount
	else
		wanted_nr_units = math.random(spawn_group_desc.amount[1], spawn_group_desc.amount[2])
	end

	local valid_unit_types = {}

	self._extract_group_desc_structure(spawn_group_desc.spawn, valid_unit_types)

	local unit_categories = tweak_data.group_ai.unit_categories
	local total_wgt = 0
	local i = 1

	while i <= #valid_unit_types do
		local spawn_entry = valid_unit_types[i]
		local cat_data = unit_categories[spawn_entry.unit]

		if not cat_data then
			debug_pause("[GroupAIStateBesiege:_spawn_in_group] unit category doesn't exist:", spawn_entry.unit)

			return
		end

		local spawn_limit = managers.job:current_spawn_limit(cat_data.special_type)

		if cat_data.special_type and not cat_data.is_captain and spawn_limit < self:_get_special_unit_type_count(cat_data.special_type) + (spawn_entry.amount_min or 0) then
			spawn_group.delay_t = self._t + 10

			return
		else
			total_wgt = total_wgt + spawn_entry.freq
			i = i + 1
		end
	end

	for _, sp_data in ipairs(spawn_group.spawn_pts) do
		sp_data.delay_t = self._t + math.rand(0.5)
	end

	local spawn_task = {
		objective = not grp_objective.element and self._create_objective_from_group_objective(grp_objective),
		units_remaining = {},
		spawn_group = spawn_group,
		spawn_group_type = spawn_group_type,
		ai_task = ai_task
	}

	table.insert(self._spawning_groups, spawn_task)

	local function _add_unit_type_to_spawn_task(i, spawn_entry)
		local spawn_amount_mine = 1 + (spawn_task.units_remaining[spawn_entry.unit] and spawn_task.units_remaining[spawn_entry.unit].amount or 0)
		spawn_task.units_remaining[spawn_entry.unit] = {
			amount = spawn_amount_mine,
			spawn_entry = spawn_entry
		}
		wanted_nr_units = wanted_nr_units - 1

		if spawn_entry.amount_min then
			spawn_entry.amount_min = spawn_entry.amount_min - 1
		end

		if spawn_entry.amount_max then
			spawn_entry.amount_max = spawn_entry.amount_max - 1

			if spawn_entry.amount_max == 0 then
				table.remove(valid_unit_types, i)

				total_wgt = total_wgt - spawn_entry.freq

				return true
			end
		end
	end

	local i = 1

	while i <= #valid_unit_types do
		local spawn_entry = valid_unit_types[i]

		if i <= #valid_unit_types and wanted_nr_units > 0 and spawn_entry.amount_min and spawn_entry.amount_min > 0 and (not spawn_entry.amount_max or spawn_entry.amount_max > 0) then
			if not _add_unit_type_to_spawn_task(i, spawn_entry) then
				i = i + 1
			end
		else
			i = i + 1
		end
	end

	while wanted_nr_units > 0 and #valid_unit_types ~= 0 do
		local rand_wght = math.random() * total_wgt
		local rand_i = 1
		local rand_entry = nil

		repeat
			rand_entry = valid_unit_types[rand_i]
			rand_wght = rand_wght - rand_entry.freq

			if rand_wght <= 0 then
				break
			else
				rand_i = rand_i + 1
			end
		until false

		local cat_data = unit_categories[rand_entry.unit]
		local spawn_limit = managers.job:current_spawn_limit(cat_data.special_type)

		if cat_data.special_type and not cat_data.is_captain and spawn_limit <= self:_get_special_unit_type_count(cat_data.special_type) then
			table.remove(valid_unit_types, rand_i)

			total_wgt = total_wgt - rand_entry.freq
		else
			_add_unit_type_to_spawn_task(rand_i, rand_entry)
		end
	end

	local group_desc = {
		size = 0,
		type = spawn_group_type
	}

	for u_name, spawn_info in pairs(spawn_task.units_remaining) do
		group_desc.size = group_desc.size + spawn_info.amount
	end

	local group = self:_create_group(group_desc)
	group.objective = grp_objective
	group.objective.moving_out = true
	group.team = self._teams[spawn_group.team_id or tweak_data.levels:get_default_team_ID("combatant")]
	spawn_task.group = group

	return group
end

function GroupAIStateBesiege:_upd_group_spawning(use_last)
	local spawn_task = self._spawning_groups[use_last and #self._spawning_groups or 1]

	if not spawn_task then
		return
	end

	self:_perform_group_spawning(spawn_task, nil, use_last)
end

function GroupAIStateBesiege:_perform_group_spawning(spawn_task, force, use_last)
	local nr_units_spawned = 0
	local produce_data = {
		name = true,
		spawn_ai = {}
	}
	local group_ai_tweak = tweak_data.group_ai
	local spawn_points = spawn_task.spawn_group.spawn_pts

	local function _try_spawn_unit(u_type_name, spawn_entry)
		if GroupAIStateBesiege._MAX_SIMULTANEOUS_SPAWNS <= nr_units_spawned and not force then
			return
		end

		local hopeless = true
		local current_unit_type = tweak_data.levels:get_ai_group_type()

		for _, sp_data in ipairs(spawn_points) do
			local category = group_ai_tweak.unit_categories[u_type_name]

			if (sp_data.accessibility == "any" or category.access[sp_data.accessibility]) and (not sp_data.amount or sp_data.amount > 0) and sp_data.mission_element:enabled() then
				hopeless = false

				if sp_data.delay_t < self._t then
					local units = category.unit_types[current_unit_type]
					produce_data.name = units[math.random(#units)]
					produce_data.name = managers.modifiers:modify_value("GroupAIStateBesiege:SpawningUnit", produce_data.name)
					local spawned_unit = sp_data.mission_element:produce(produce_data)
					local u_key = spawned_unit:key()
					local objective = nil

					if spawn_task.objective then
						objective = self.clone_objective(spawn_task.objective)
					else
						objective = spawn_task.group.objective.element:get_random_SO(spawned_unit)

						if not objective then
							spawned_unit:set_slot(0)

							return true
						end

						objective.grp_objective = spawn_task.group.objective
					end

					local u_data = self._police[u_key]

					self:set_enemy_assigned(objective.area, u_key)

					if spawn_entry.tactics then
						u_data.tactics = spawn_entry.tactics
						u_data.tactics_map = {}

						for _, tactic_name in ipairs(u_data.tactics) do
							u_data.tactics_map[tactic_name] = true
						end
					end

					spawned_unit:brain():set_spawn_entry(spawn_entry, u_data.tactics_map)

					u_data.rank = spawn_entry.rank

					self:_add_group_member(spawn_task.group, u_key)

					if spawned_unit:brain():is_available_for_assignment(objective) then
						if objective.element then
							objective.element:clbk_objective_administered(spawned_unit)
						end

						spawned_unit:brain():set_objective(objective)
					else
						spawned_unit:brain():set_followup_objective(objective)
					end

					nr_units_spawned = nr_units_spawned + 1

					if spawn_task.ai_task then
						spawn_task.ai_task.force_spawned = spawn_task.ai_task.force_spawned + 1
						spawned_unit:brain()._logic_data.spawned_in_phase = spawn_task.ai_task.phase
					end

					sp_data.delay_t = self._t + sp_data.interval

					if sp_data.amount then
						sp_data.amount = sp_data.amount - 1
					end

					return true
				end
			end
		end

		if hopeless then
			debug_pause("[GroupAIStateBesiege:_upd_group_spawning] spawn group", spawn_task.spawn_group.id, "failed to spawn unit", u_type_name)

			return true
		end
	end

	for u_type_name, spawn_info in pairs(spawn_task.units_remaining) do
		if not group_ai_tweak.unit_categories[u_type_name].access.acrobatic then
			for i = spawn_info.amount, 1, -1 do
				local success = _try_spawn_unit(u_type_name, spawn_info.spawn_entry)

				if success then
					spawn_info.amount = spawn_info.amount - 1
				end

				break
			end
		end
	end

	for u_type_name, spawn_info in pairs(spawn_task.units_remaining) do
		for i = spawn_info.amount, 1, -1 do
			local success = _try_spawn_unit(u_type_name, spawn_info.spawn_entry)

			if success then
				spawn_info.amount = spawn_info.amount - 1
			end

			break
		end
	end

	local complete = true

	for u_type_name, spawn_info in pairs(spawn_task.units_remaining) do
		if spawn_info.amount > 0 then
			complete = false

			break
		end
	end

	if complete then
		spawn_task.group.has_spawned = true

		table.remove(self._spawning_groups, use_last and #self._spawning_groups or 1)

		if spawn_task.group.size <= 0 then
			self._groups[spawn_task.group.id] = nil
		end
	end
end

function GroupAIStateBesiege:_upd_reenforce_tasks()
	local reenforce_tasks = self._task_data.reenforce.tasks
	local t = self._t
	local i = #reenforce_tasks

	while i > 0 do
		local task_data = reenforce_tasks[i]
		local force_settings = task_data.target_area.factors.force
		local force_required = force_settings and force_settings.force

		if force_required then
			local force_occupied = 0

			for group_id, group in pairs(self._groups) do
				if (group.objective.target_area or group.objective.area) == task_data.target_area and group.objective.type == "reenforce_area" then
					force_occupied = force_occupied + (group.has_spawned and group.size or group.initial_size)
				end
			end

			local undershot = force_required - force_occupied

			if undershot > 0 and not self._task_data.regroup.active and self._task_data.assault.phase ~= "fade" and self._task_data.reenforce.next_dispatch_t < t and self:is_area_safe(task_data.target_area) then
				local used_event = nil

				if task_data.use_spawn_event then
					task_data.use_spawn_event = false

					if self:_try_use_task_spawn_event(t, task_data.target_area, "reenforce") then
						used_event = true
					end
				end

				local used_group, spawning_groups = nil

				if not used_event then
					if next(self._spawning_groups) then
						spawning_groups = true
					else
						local spawn_group, spawn_group_type = self:_find_spawn_group_near_area(task_data.target_area, self._tweak_data.reenforce.groups, nil, nil, nil)

						if spawn_group then
							local grp_objective = {
								attitude = "avoid",
								scan = true,
								pose = "stand",
								type = "reenforce_area",
								stance = "hos",
								area = spawn_group.area,
								target_area = task_data.target_area
							}

							self:_spawn_in_group(spawn_group, spawn_group_type, grp_objective)

							used_group = true
						end
					end
				end

				if used_event or used_group then
					self._task_data.reenforce.next_dispatch_t = t + self:_get_difficulty_dependent_value(self._tweak_data.reenforce.interval)
				end
			elseif undershot < 0 then
				local force_defending = 0

				for group_id, group in pairs(self._groups) do
					if group.objective.area == task_data.target_area and group.objective.type == "reenforce_area" then
						force_defending = force_defending + (group.has_spawned and group.size or group.initial_size)
					end
				end

				local overshot = force_defending - force_required

				if overshot > 0 then
					local closest_group, closest_group_size = nil

					for group_id, group in pairs(self._groups) do
						if group.has_spawned and (group.objective.target_area or group.objective.area) == task_data.target_area and group.objective.type == "reenforce_area" and (not closest_group_size or closest_group_size < group.size) and group.size <= overshot then
							closest_group = group
							closest_group_size = group.size
						end
					end

					if closest_group then
						self:_assign_group_to_retire(closest_group)
					end
				end
			end
		else
			for group_id, group in pairs(self._groups) do
				if group.has_spawned and (group.objective.target_area or group.objective.area) == task_data.target_area and group.objective.type == "reenforce_area" then
					self:_assign_group_to_retire(group)
				end
			end

			reenforce_tasks[i] = reenforce_tasks[#reenforce_tasks]

			table.remove(reenforce_tasks)
		end

		i = i - 1
	end

	self:_assign_enemy_groups_to_reenforce()
end

function GroupAIStateBesiege:register_criminal(unit)
	GroupAIStateBesiege.super.register_criminal(self, unit)

	if not Network:is_server() then
		return
	end

	local u_key = unit:key()
	local record = self._criminals[u_key]
	local area_data = self:get_area_from_nav_seg_id(record.seg)
	area_data.criminal.units[u_key] = record
end

function GroupAIStateBesiege:unregister_criminal(unit)
	if Network:is_server() then
		local u_key = unit:key()
		local record = self._criminals[u_key]

		for area_id, area in pairs(self._area_data) do
			if area.nav_segs[record.seg] then
				area.criminal.units[u_key] = nil
			end
		end
	end

	GroupAIStateBesiege.super.unregister_criminal(self, unit)
end

function GroupAIStateBesiege:on_objective_complete(unit, objective)
	local new_objective, so_element = nil

	if objective.followup_objective then
		if not objective.followup_objective.trigger_on then
			new_objective = objective.followup_objective
		else
			new_objective = {
				type = "free",
				followup_objective = objective.followup_objective,
				interrupt_dis = objective.interrupt_dis,
				interrupt_health = objective.interrupt_health
			}
		end
	elseif objective.followup_SO then
		local current_SO_element = objective.followup_SO
		so_element = current_SO_element:choose_followup_SO(unit)
		new_objective = so_element and so_element:get_objective(unit)
	end

	if new_objective then
		if new_objective.nav_seg then
			local u_key = unit:key()
			local u_data = self._police[u_key]

			if u_data and u_data.assigned_area then
				self:set_enemy_assigned(self._area_data[new_objective.nav_seg], u_key)
			end
		end
	else
		local seg = unit:movement():nav_tracker():nav_segment()
		local area_data = self:get_area_from_nav_seg_id(seg)

		if self:rescue_state() and tweak_data.character[unit:base()._tweak_table].rescue_hostages then
			for u_key, u_data in pairs(managers.enemy:all_civilians()) do
				if seg == u_data.tracker:nav_segment() then
					local so_id = u_data.unit:brain():wants_rescue()

					if so_id then
						local so = self._special_objectives[so_id]
						local so_data = so.data
						local so_objective = so_data.objective
						new_objective = self.clone_objective(so_objective)

						if so_data.admin_clbk then
							so_data.admin_clbk(unit)
						end

						self:remove_special_objective(so_id)

						break
					end
				end
			end
		end

		if not new_objective and objective.type == "free" then
			new_objective = {
				is_default = true,
				type = "free",
				attitude = objective.attitude
			}
		end

		if not area_data.is_safe then
			area_data.is_safe = true

			self:_on_nav_seg_safety_status(seg, {
				reason = "guard",
				unit = unit
			})
		end
	end

	objective.fail_clbk = nil

	unit:brain():set_objective(new_objective)

	if objective.complete_clbk then
		objective.complete_clbk(unit)
	end

	if so_element then
		so_element:clbk_objective_administered(unit)
	end
end

function GroupAIStateBesiege:on_defend_travel_end(unit, objective)
	local seg = objective.nav_seg
	local area = self:get_area_from_nav_seg_id(seg)

	if not area.is_safe then
		area.is_safe = true

		self:_on_area_safety_status(area, {
			reason = "guard",
			unit = unit
		})
	end
end

function GroupAIStateBesiege:on_cop_jobless(unit)
	local u_key = unit:key()

	if not self._police[u_key].assigned_area then
		return
	end

	local nav_seg = unit:movement():nav_tracker():nav_segment()
	local new_occupation = self:find_occupation_in_area(nav_seg)
	local area = self:get_area_from_nav_seg_id(nav_seg)
	local force_factor = area.factors.force
	local demand = force_factor and force_factor.force
	local nr_police = table.size(area.police.units)
	local undershot = demand and demand - nr_police

	if undershot and undershot > 0 then
		local new_objective = {
			type = "defend_area",
			interrupt_health = 0.75,
			is_default = true,
			stance = "hos",
			in_place = true,
			scan = true,
			interrupt_dis = 700,
			attitude = "avoid",
			nav_seg = nav_seg
		}

		self:set_enemy_assigned(self._area_data[nav_seg], u_key)
		unit:brain():set_objective(new_objective)

		return true
	end

	if not area.is_safe then
		local new_objective = {
			stance = "hos",
			scan = true,
			in_place = true,
			type = "free",
			is_default = true,
			attitude = "avoid",
			nav_seg = nav_seg
		}

		self:set_enemy_assigned(self._area_data[nav_seg], u_key)
		unit:brain():set_objective(new_objective)

		return true
	end
end

function GroupAIStateBesiege:_draw_enemy_activity(t)
	local draw_data = self._AI_draw_data
	local brush_area = draw_data.brush_area
	local area_normal = -math.UP
	local logic_name_texts = draw_data.logic_name_texts
	local group_id_texts = draw_data.group_id_texts
	local panel = draw_data.panel
	local camera = managers.viewport:get_current_camera()

	if not camera then
		return
	end

	local ws = draw_data.workspace
	local mid_pos1 = Vector3()
	local mid_pos2 = Vector3()
	local focus_enemy_pen = draw_data.pen_focus_enemy
	local focus_player_brush = draw_data.brush_focus_player
	local suppr_period = 0.4
	local suppr_t = t % suppr_period

	if suppr_t > suppr_period * 0.5 then
		suppr_t = suppr_period - suppr_t
	end

	draw_data.brush_suppressed:set_color(Color(math.lerp(0.2, 0.5, suppr_t), 0.85, 0.9, 0.2))

	for area_id, area in pairs(self._area_data) do
		if table.size(area.police.units) > 0 then
			brush_area:half_sphere(area.pos, 22, area_normal)
		end
	end

	local function _f_draw_logic_name(u_key, l_data, draw_color)
		local logic_name_text = logic_name_texts[u_key]
		local text_str = l_data.name

		if l_data.objective then
			text_str = text_str .. ":" .. l_data.objective.type
		end

		if not l_data.group and l_data.team then
			text_str = l_data.team.id .. ":" .. text_str
		end

		if l_data.spawned_in_phase then
			text_str = text_str .. ":" .. l_data.spawned_in_phase
		end

		if logic_name_text then
			logic_name_text:set_text(text_str)
		else
			logic_name_text = panel:text({
				name = "text",
				font_size = 20,
				layer = 1,
				text = text_str,
				font = tweak_data.hud.medium_font,
				color = draw_color
			})
			logic_name_texts[u_key] = logic_name_text
		end

		local my_head_pos = mid_pos1

		mvector3.set(my_head_pos, l_data.unit:movement():m_head_pos())
		mvector3.set_z(my_head_pos, my_head_pos.z + 30)

		local my_head_pos_screen = camera:world_to_screen(my_head_pos)

		if my_head_pos_screen.z > 0 then
			local screen_x = (my_head_pos_screen.x + 1) * 0.5 * RenderSettings.resolution.x
			local screen_y = (my_head_pos_screen.y + 1) * 0.5 * RenderSettings.resolution.y

			logic_name_text:set_x(screen_x)
			logic_name_text:set_y(screen_y)

			if not logic_name_text:visible() then
				logic_name_text:show()
			end
		elseif logic_name_text:visible() then
			logic_name_text:hide()
		end
	end

	local function _f_draw_obj_pos(unit)
		local brush = nil
		local objective = unit:brain():objective()
		local objective_type = objective and objective.type

		if objective_type == "guard" then
			brush = draw_data.brush_guard
		elseif objective_type == "defend_area" then
			brush = draw_data.brush_defend
		elseif objective_type == "free" or objective_type == "follow" or objective_type == "surrender" then
			brush = draw_data.brush_free
		elseif objective_type == "act" then
			brush = draw_data.brush_act
		else
			brush = draw_data.brush_misc
		end

		local obj_pos = nil

		if objective then
			if objective.pos then
				obj_pos = objective.pos
			elseif objective.follow_unit then
				obj_pos = objective.follow_unit:movement():m_head_pos()

				if objective.follow_unit:base().is_local_player then
					obj_pos = obj_pos + math.UP * -30
				end
			elseif objective.nav_seg then
				obj_pos = managers.navigation._nav_segments[objective.nav_seg].pos
			elseif objective.area then
				obj_pos = objective.area.pos
			end
		end

		if obj_pos then
			local u_pos = unit:movement():m_com()

			brush:cylinder(u_pos, obj_pos, 4, 3)
			brush:sphere(u_pos, 24)
		end

		if unit:brain()._logic_data.is_suppressed then
			mvector3.set(mid_pos1, unit:movement():m_pos())
			mvector3.set_z(mid_pos1, mid_pos1.z + 220)
			draw_data.brush_suppressed:cylinder(unit:movement():m_pos(), mid_pos1, 35)
		end
	end

	local group_center = Vector3()

	for group_id, group in pairs(self._groups) do
		local nr_units = 0

		for u_key, u_data in pairs(group.units) do
			nr_units = nr_units + 1

			mvector3.add(group_center, u_data.unit:movement():m_com())
		end

		if nr_units > 0 then
			mvector3.divide(group_center, nr_units)

			local gui_text = group_id_texts[group_id]
			local group_pos_screen = camera:world_to_screen(group_center)

			if group_pos_screen.z > 0 then
				if not gui_text then
					gui_text = panel:text({
						name = "text",
						font_size = 24,
						layer = 2,
						text = group.team.id .. ":" .. group_id .. ":" .. group.objective.type,
						font = tweak_data.hud.medium_font,
						color = draw_data.group_id_color
					})
					group_id_texts[group_id] = gui_text
				end

				local screen_x = (group_pos_screen.x + 1) * 0.5 * RenderSettings.resolution.x
				local screen_y = (group_pos_screen.y + 1) * 0.5 * RenderSettings.resolution.y

				gui_text:set_x(screen_x)
				gui_text:set_y(screen_y)

				if not gui_text:visible() then
					gui_text:show()
				end
			elseif gui_text and gui_text:visible() then
				gui_text:hide()
			end

			for u_key, u_data in pairs(group.units) do
				draw_data.pen_group:line(group_center, u_data.unit:movement():m_com())
			end
		end

		mvector3.set_zero(group_center)
	end

	local function _f_draw_attention_on_player(l_data)
		if l_data.attention_obj then
			local my_head_pos = l_data.unit:movement():m_head_pos()
			local e_pos = l_data.attention_obj.m_head_pos
			local dis = mvector3.distance(my_head_pos, e_pos)

			mvector3.step(mid_pos2, my_head_pos, e_pos, 300)
			mvector3.lerp(mid_pos1, my_head_pos, mid_pos2, t % 0.5)
			mvector3.step(mid_pos2, mid_pos1, e_pos, 50)
			focus_enemy_pen:line(mid_pos1, mid_pos2)

			if l_data.attention_obj.unit:base() and l_data.attention_obj.unit:base().is_local_player then
				focus_player_brush:sphere(my_head_pos, 20)
			end
		end
	end

	local groups = {
		{
			group = self._police,
			color = Color(1, 1, 0, 0)
		},
		{
			group = managers.enemy:all_civilians(),
			color = Color(1, 0.75, 0.75, 0.75)
		},
		{
			group = self._ai_criminals,
			color = Color(1, 0, 1, 0)
		}
	}

	for _, group_data in ipairs(groups) do
		for u_key, u_data in pairs(group_data.group) do
			_f_draw_obj_pos(u_data.unit)

			if camera then
				local l_data = u_data.unit:brain()._logic_data

				_f_draw_logic_name(u_key, l_data, group_data.color)
				_f_draw_attention_on_player(l_data)
			end
		end
	end

	for u_key, gui_text in pairs(logic_name_texts) do
		local keep = nil

		for _, group_data in ipairs(groups) do
			if group_data.group[u_key] then
				keep = true

				break
			end
		end

		if not keep then
			panel:remove(gui_text)

			logic_name_texts[u_key] = nil
		end
	end

	for group_id, gui_text in pairs(group_id_texts) do
		if not self._groups[group_id] then
			panel:remove(gui_text)

			group_id_texts[group_id] = nil
		end
	end
end

function GroupAIStateBesiege:find_occupation_in_area(nav_seg)
	local doors = managers.navigation:find_segment_doors(nav_seg, callback(self, self, "filter_nav_seg_unsafe"))

	if not next(doors) then
		return
	end

	for other_seg, door_list in ipairs(doors) do
		for i_door, door_data in ipairs(door_list) do
			door_data.weight = 0
		end
	end

	local tmp_vec1 = Vector3()
	local tmp_vec2 = Vector3()
	local math_max = math.max
	local mvec3_lerp = mvector3.lerp
	local mvec3_dis_sq = mvector3.distance_sq
	local nav_manager = managers.navigation
	local area_data = self:get_area_from_nav_seg_id(nav_seg)
	local area_police = area_data.police.units
	local unit_data = self._police
	local guarded_doors = {}

	for u_key, _ in pairs(area_police) do
		local objective = unit_data[u_key].unit:brain():objective()

		if objective and objective.guard_obj then
			local door_list = doors[objective.from_seg]

			if door_list then
				mvec3_lerp(tmp_vec1, objective.guard_obj.door.low_pos, objective.guard_obj.door.high_pos, 0.5)

				for i_door, door_data in ipairs(door_list) do
					mvec3_lerp(tmp_vec2, door_data.low_pos, door_dataoor.high_pos, 0.5)

					local weight = 1 / math_max(1, mvec3_dis_sq(tmp_vec1, tmp_vec2))
					door_data.weight = door_data.weight + weight
				end
			end
		end
	end

	local best_door, best_door_weight, best_door_nav_seg = nil

	for other_seg, door_list in ipairs(doors) do
		for i_door, door_data in ipairs(door_list) do
			if not best_door or door_data.weight < best_door_weight then
				best_door = door_data.center
				best_door_weight = door_data.weight
				best_door_nav_seg = other_seg
			end
		end
	end

	for other_seg, door_list in ipairs(doors) do
		for i_door, door_data in ipairs(door_list) do
			door_data.weight = nil
		end
	end

	if best_door then
		local center = mvector3.copy(best_door.low_pos)

		mvec3_lerp(center, center, best_door.heigh_pos, 0.5)

		best_door.center = center

		return {
			type = "guard",
			door = best_door,
			from_seg = best_door_nav_seg
		}
	end
end

function GroupAIStateBesiege:verify_occupation_in_area(objective)
	local nav_seg = objective.nav_seg

	return self:find_occupation_in_area(nav_seg)
end

function GroupAIStateBesiege:filter_nav_seg_unsafe(nav_seg)
	return not self:is_nav_seg_safe(nav_seg)
end

function GroupAIStateBesiege:_on_nav_seg_safety_status(seg, event)
	local area = self:get_area_from_nav_seg_id(seg)

	self:_on_area_safety_status(area, event)
end

function GroupAIStateBesiege:add_flee_point(id, pos)
	local nav_seg = managers.navigation:get_nav_seg_from_pos(pos, true)
	local area = self:get_area_from_nav_seg_id(nav_seg)
	local flee_point = {
		pos = pos,
		nav_seg = nav_seg,
		area = area
	}
	self._flee_points[id] = flee_point
	area.flee_points = area.flee_points or {}
	area.flee_points[id] = flee_point
end

function GroupAIStateBesiege:remove_flee_point(id)
	local flee_point = self._flee_points[id]

	if not flee_point then
		return
	end

	self._flee_points[id] = nil
	local area = flee_point.area
	area.flee_points[id] = nil

	if not next(area.flee_points) then
		area.flee_points = nil
	end
end

function GroupAIStateBesiege:flee_point(start_nav_seg, ignore_segs)
	local start_area = self:get_area_from_nav_seg_id(start_nav_seg)
	local to_search_areas = {
		start_area
	}
	local found_areas = {
		[start_area] = true
	}

	repeat
		local search_area = table.remove(to_search_areas, 1)

		if search_area.flee_points and next(search_area.flee_points) then
			local flee_point_id, flee_point = next(search_area.flee_points)

			if not ignore_segs or not table.contains(ignore_segs, flee_point.nav_seg) then
				return flee_point.pos
			end
		else
			for other_area_id, other_area in pairs(search_area.neighbours) do
				if not found_areas[other_area] then
					table.insert(to_search_areas, other_area)

					found_areas[other_area] = true
				end
			end
		end
	until #to_search_areas == 0
end

function GroupAIStateBesiege:safe_flee_point(start_nav_seg, ignore_segs)
	local start_area = self:get_area_from_nav_seg_id(start_nav_seg)

	if next(start_area.criminal.units) then
		return
	end

	local to_search_areas = {
		start_area
	}
	local found_areas = {
		[start_area] = true
	}

	repeat
		local search_area = table.remove(to_search_areas, 1)

		if search_area.flee_points and next(search_area.flee_points) then
			local flee_point_id, flee_point = next(search_area.flee_points)

			if not ignore_segs or not table.contains(ignore_segs, flee_point.nav_seg) then
				return flee_point
			end
		end

		for other_area_id, other_area in pairs(search_area.neighbours) do
			if not found_areas[other_area] and not next(other_area.criminal.units) then
				table.insert(to_search_areas, other_area)

				found_areas[other_area] = true
			end
		end
	until #to_search_areas == 0
end

function GroupAIStateBesiege:add_enemy_loot_drop_point(id, pos)
	local nav_seg = managers.navigation:get_nav_seg_from_pos(pos, true)
	local area = self:get_area_from_nav_seg_id(nav_seg)
	local drop_point = {
		pos = pos,
		nav_seg = nav_seg,
		area = area
	}
	self._enemy_loot_drop_points[id] = drop_point
	area.enemy_loot_drop_points = area.enemy_loot_drop_points or {}
	area.enemy_loot_drop_points[id] = drop_point
end

function GroupAIStateBesiege:remove_enemy_loot_drop_point(id)
	local drop_point = self._enemy_loot_drop_points[id]

	if not drop_point then
		return
	end

	self._enemy_loot_drop_points[id] = nil
	local area = drop_point.area
	area.enemy_loot_drop_points[id] = nil

	if not next(area.enemy_loot_drop_points) then
		area.enemy_loot_drop_points = nil
	end
end

function GroupAIStateBesiege:get_safe_enemy_loot_drop_point(start_nav_seg)
	local start_area = self:get_area_from_nav_seg_id(start_nav_seg)

	if next(start_area.criminal.units) then
		return
	end

	local to_search_areas = {
		start_area
	}
	local found_areas = {
		[start_area] = true
	}

	repeat
		local search_area = table.remove(to_search_areas, 1)

		if search_area.enemy_loot_drop_points and next(search_area.enemy_loot_drop_points) then
			local nr_drop_points = table.size(search_area.enemy_loot_drop_points)
			local lucky_drop_point = math.random(nr_drop_points)

			for drop_point_id, drop_point in pairs(search_area.enemy_loot_drop_points) do
				lucky_drop_point = lucky_drop_point - 1

				if lucky_drop_point == 0 then
					return drop_point
				end
			end
		else
			for other_area_id, other_area in pairs(search_area.neighbours) do
				if not found_areas[other_area] and not next(other_area.criminal.units) then
					table.insert(to_search_areas, other_area)

					found_areas[other_area] = true
				end
			end
		end
	until #to_search_areas == 0
end

function GroupAIStateBesiege:_draw_spawn_points()
	local all_areas = self._area_data
	local tmp_vec3 = Vector3()

	for area_id, area_data in pairs(all_areas) do
		local area_spawn_points = area_data.spawn_points

		if area_spawn_points then
			for _, sp_data in ipairs(area_spawn_points) do
				Application:draw_sphere(sp_data.pos, 220, 0.1, 0.4, 0.6)
			end
		end

		local area_spawn_groups = area_data.spawn_groups

		if area_spawn_groups then
			for _, spawn_group in ipairs(area_spawn_groups) do
				mvector3.set(tmp_vec3, math.UP)
				mvector3.multiply(tmp_vec3, 2500)
				mvector3.add(tmp_vec3, spawn_group.pos)
				Application:draw_cylinder(spawn_group.pos, tmp_vec3, 220, 0.2, 0.1, 0.75)

				for _, sp_data in ipairs(spawn_group.spawn_pts) do
					mvector3.set(tmp_vec3, math.UP)
					mvector3.multiply(tmp_vec3, 200)
					mvector3.add(tmp_vec3, sp_data.pos)
					Application:draw_cylinder(sp_data.pos, tmp_vec3, 63, 0.1, 0.4, 0.6)
					Application:draw_cylinder(spawn_group.pos, sp_data.pos, 20, 0.2, 0.1, 0.75)
				end
			end
		end
	end

	if self._debug_weights then
		local camera = managers.viewport:get_current_camera()
		local offsets = {}

		if camera then
			for _, data in ipairs(self._debug_weights) do
				mvector3.set(tmp_vec3, math.UP)
				mvector3.multiply(tmp_vec3, 2500)
				mvector3.add(tmp_vec3, data.group.pos)

				local text = ""
				offsets[data.group.id] = offsets[data.group.id] or 0
				local pos = tmp_vec3 + Vector3(0, 0, offsets[data.group.id])
				text = text .. data.group_type
				text = text .. " weight:" .. string.format("%.3f", data.wght)
				text = text .. " snubb:" .. string.format("%.3f", data.cat_weight)
				text = text .. " dis weight:" .. string.format("%.3f", data.dis_weight)
				text = text .. " distance:" .. string.format("%.3f", (data.group.distance or 0) / 100)

				self._AI_draw_data.brush_misc:set_font(Idstring("fonts/font_medium"), 16)
				self._AI_draw_data.brush_misc:center_text(pos, text)

				offsets[data.group.id] = offsets[data.group.id] + 30
			end
		end
	end
end

function GroupAIStateBesiege:on_hostage_fleeing(unit)
	self._hostage_fleeing = unit
end

function GroupAIStateBesiege:on_hostage_flee_end()
	self._hostage_fleeing = nil
end

function GroupAIStateBesiege:can_hostage_flee()
	return not self._hostage_fleeing
end

function GroupAIStateBesiege:add_to_surrendered(unit, update)
	local hos_data = self._hostage_data
	local nr_entries = #hos_data
	local entry = {
		u_key = unit:key(),
		clbk = update
	}

	if not self._hostage_upd_key then
		self._hostage_upd_key = "GroupAIStateBesiege:_upd_hostage_task"

		managers.enemy:queue_task(self._hostage_upd_key, self._upd_hostage_task, self, self._t + 1)
	end

	table.insert(hos_data, entry)
end

function GroupAIStateBesiege:remove_from_surrendered(unit)
	local hos_data = self._hostage_data
	local u_key = unit:key()

	for i, entry in ipairs(hos_data) do
		if u_key == entry.u_key then
			table.remove(hos_data, i)

			break
		end
	end

	if #hos_data == 0 then
		managers.enemy:unqueue_task(self._hostage_upd_key)

		self._hostage_upd_key = nil
	end
end

function GroupAIStateBesiege:_upd_hostage_task()
	self._hostage_upd_key = nil
	local hos_data = self._hostage_data
	local first_entry = hos_data[1]

	table.remove(hos_data, 1)
	first_entry.clbk()

	if not self._hostage_upd_key and #hos_data > 0 then
		self._hostage_upd_key = "GroupAIStateBesiege:_upd_hostage_task"

		managers.enemy:queue_task(self._hostage_upd_key, self._upd_hostage_task, self, self._t + 1)
	end
end

function GroupAIStateBesiege:set_area_min_police_force(id, force, pos)
	if force then
		local nav_seg_id = managers.navigation:get_nav_seg_from_pos(pos, true)
		local area = self:get_area_from_nav_seg_id(nav_seg_id)
		local factors = area.factors
		factors.force = {
			id = id,
			force = force
		}
	else
		for area_id, area in pairs(self._area_data) do
			local force_factor = area.factors.force

			if force_factor and force_factor.id == id then
				area.factors.force = nil

				return
			end
		end
	end
end

function GroupAIStateBesiege:set_wave_mode(flag)
	local old_wave_mode = self._wave_mode
	self._wave_mode = flag
	self._hunt_mode = nil

	if flag == "hunt" then
		self._hunt_mode = true
		self._wave_mode = "besiege"

		managers.hud:start_assault(self._assault_number)
		self:_set_rescue_state(false)
		self:set_assault_mode(true)
		managers.trade:set_trade_countdown(false)
		self:_end_regroup_task()

		if self._task_data.assault.active then
			self._task_data.assault.phase = "sustain"
			self._task_data.use_smoke = true
			self._task_data.use_smoke_timer = 0
		else
			self._task_data.assault.next_dispatch_t = self._t
		end
	elseif flag == "besiege" then
		if self._task_data.regroup.active then
			self._task_data.assault.next_dispatch_t = self._task_data.regroup.end_t
		elseif not self._task_data.assault.active then
			self._task_data.assault.next_dispatch_t = self._t
		end
	elseif flag == "quiet" then
		self._hunt_mode = nil
	else
		self._wave_mode = old_wave_mode

		debug_pause("[GroupAIStateBesiege:set_wave_mode] flag", flag, " does not apply to the current Group AI state.")
	end
end

function GroupAIStateBesiege:on_simulation_ended()
	GroupAIStateBesiege.super.on_simulation_ended(self)

	if managers.navigation:is_data_ready() then
		self:_create_area_data()

		self._task_data = {
			reenforce = {
				next_dispatch_t = 0,
				tasks = {}
			},
			recon = {
				next_dispatch_t = 0,
				tasks = {}
			},
			assault = {
				is_first = true,
				disabled = true
			},
			regroup = {}
		}
	end

	if self._police_upd_task_queued then
		self._police_upd_task_queued = nil

		managers.enemy:unqueue_task("GroupAIStateBesiege._upd_police_activity")
	end
end

function GroupAIStateBesiege:on_simulation_started()
	GroupAIStateBesiege.super.on_simulation_started(self)

	if managers.navigation:is_data_ready() then
		self:_create_area_data()

		self._task_data = {
			reenforce = {
				next_dispatch_t = 0,
				tasks = {}
			},
			recon = {
				next_dispatch_t = 0,
				tasks = {}
			},
			assault = {
				is_first = true,
				disabled = true
			},
			regroup = {}
		}
	end

	self:_queue_police_upd_task()
end

function GroupAIStateBesiege:on_enemy_weapons_hot(is_delayed_callback)
	if not self._ai_enabled then
		return
	end

	if not self._enemy_weapons_hot then
		self._task_data.assault.disabled = nil
		self._task_data.assault.next_dispatch_t = self._t
	end

	GroupAIStateBesiege.super.on_enemy_weapons_hot(self, is_delayed_callback)
end

function GroupAIStateBesiege:is_detection_persistent()
	return self._task_data.assault.active
end

function GroupAIStateBesiege:_assign_enemy_groups_to_assault(phase)
	for group_id, group in pairs(self._groups) do
		if group.has_spawned and group.objective.type == "assault_area" then
			if group.objective.moving_out then
				local done_moving = nil

				for u_key, u_data in pairs(group.units) do
					local objective = u_data.unit:brain():objective()

					if objective then
						if objective.grp_objective ~= group.objective then
							-- Nothing
						elseif not objective.in_place then
							done_moving = false
						elseif done_moving == nil then
							done_moving = true
						end
					end
				end

				if done_moving == true then
					group.objective.moving_out = nil
					group.in_place_t = self._t
					group.objective.moving_in = nil

					self:_voice_move_complete(group)
				end
			end

			if not group.objective.moving_in then
				self:_set_assault_objective_to_group(group, phase)
			end
		end
	end
end

function GroupAIStateBesiege:_assign_enemy_groups_to_recon()
	for group_id, group in pairs(self._groups) do
		if group.has_spawned and group.objective.type == "recon_area" then
			if group.objective.moving_out then
				local done_moving = nil

				for u_key, u_data in pairs(group.units) do
					local objective = u_data.unit:brain():objective()

					if objective then
						if objective.grp_objective ~= group.objective then
							-- Nothing
						elseif not objective.in_place then
							done_moving = false
						elseif done_moving == nil then
							done_moving = true
						end
					end
				end

				if done_moving == true then
					if group.objective.moved_in then
						group.visited_areas = group.visited_areas or {}
						group.visited_areas[group.objective.area] = true
					end

					group.objective.moving_out = nil
					group.in_place_t = self._t
					group.objective.moving_in = nil

					self:_voice_move_complete(group)
				end
			end

			if not group.objective.moving_in then
				self:_set_recon_objective_to_group(group)
			end
		end
	end
end

function GroupAIStateBesiege:_set_recon_objective_to_group(group)
	local current_objective = group.objective
	local target_area = current_objective.target_area or current_objective.area

	if not target_area.loot and not target_area.hostages or not current_objective.moving_out and current_objective.moved_in and group.in_place_t and self._t - group.in_place_t > 15 then
		local recon_area = nil
		local to_search_areas = {
			current_objective.area
		}
		local found_areas = {
			[current_objective.area] = "init"
		}

		repeat
			local search_area = table.remove(to_search_areas, 1)

			if search_area.loot or search_area.hostages then
				local occupied = nil

				for test_group_id, test_group in pairs(self._groups) do
					if test_group ~= group and (test_group.objective.target_area == search_area or test_group.objective.area == search_area) then
						occupied = true

						break
					end
				end

				if not occupied and group.visited_areas and group.visited_areas[search_area] then
					occupied = true
				end

				if not occupied then
					local is_area_safe = not next(search_area.criminal.units)

					if is_area_safe then
						recon_area = search_area

						break
					else
						recon_area = recon_area or search_area
					end
				end
			end

			if not next(search_area.criminal.units) then
				for other_area_id, other_area in pairs(search_area.neighbours) do
					if not found_areas[other_area] then
						table.insert(to_search_areas, other_area)

						found_areas[other_area] = search_area
					end
				end
			end
		until #to_search_areas == 0

		if recon_area then
			local coarse_path = {
				{
					recon_area.pos_nav_seg,
					recon_area.pos
				}
			}
			local last_added_area = recon_area

			while found_areas[last_added_area] ~= "init" do
				last_added_area = found_areas[last_added_area]

				table.insert(coarse_path, 1, {
					last_added_area.pos_nav_seg,
					last_added_area.pos
				})
			end

			local grp_objective = {
				scan = true,
				pose = "stand",
				type = "recon_area",
				stance = "hos",
				attitude = "avoid",
				area = current_objective.area,
				target_area = recon_area,
				coarse_path = coarse_path
			}

			self:_set_objective_to_enemy_group(group, grp_objective)

			current_objective = group.objective
		end
	end

	if current_objective.target_area then
		if current_objective.moving_out and not current_objective.moving_in and current_objective.coarse_path then
			local forwardmost_i_nav_point = self:_get_group_forwardmost_coarse_path_index(group)

			if forwardmost_i_nav_point and forwardmost_i_nav_point > 1 then
				for i = forwardmost_i_nav_point + 1, #current_objective.coarse_path, 1 do
					local nav_point = current_objective.coarse_path[forwardmost_i_nav_point]

					if not self:is_nav_seg_safe(nav_point[1]) then
						for i = 0, #current_objective.coarse_path - forwardmost_i_nav_point, 1 do
							table.remove(current_objective.coarse_path)
						end

						local grp_objective = {
							attitude = "avoid",
							scan = true,
							pose = "stand",
							type = "recon_area",
							stance = "hos",
							area = self:get_area_from_nav_seg_id(current_objective.coarse_path[#current_objective.coarse_path][1]),
							target_area = current_objective.target_area
						}

						self:_set_objective_to_enemy_group(group, grp_objective)

						return
					end
				end
			end
		end

		if not current_objective.moving_out and not current_objective.area.neighbours[current_objective.target_area.id] then
			local search_params = {
				id = "GroupAI_recon",
				from_seg = current_objective.area.pos_nav_seg,
				to_seg = current_objective.target_area.pos_nav_seg,
				access_pos = self._get_group_acces_mask(group),
				verify_clbk = callback(self, self, "is_nav_seg_safe")
			}
			local coarse_path = managers.navigation:search_coarse(search_params)

			if coarse_path then
				self:_merge_coarse_path_by_area(coarse_path)
				table.remove(coarse_path)

				local grp_objective = {
					scan = true,
					pose = "stand",
					type = "recon_area",
					stance = "hos",
					attitude = "avoid",
					area = self:get_area_from_nav_seg_id(coarse_path[#coarse_path][1]),
					target_area = current_objective.target_area,
					coarse_path = coarse_path
				}

				self:_set_objective_to_enemy_group(group, grp_objective)
			end
		end

		if not current_objective.moving_out and current_objective.area.neighbours[current_objective.target_area.id] then
			local grp_objective = {
				stance = "hos",
				scan = true,
				pose = "crouch",
				type = "recon_area",
				attitude = "avoid",
				area = current_objective.target_area
			}

			self:_set_objective_to_enemy_group(group, grp_objective)

			group.objective.moving_in = true
			group.objective.moved_in = true

			if next(current_objective.target_area.criminal.units) then
				self:_chk_group_use_smoke_grenade(group, {
					use_smoke = true,
					target_areas = {
						grp_objective.area
					}
				})
			end
		end
	end
end

function GroupAIStateBesiege:_set_objective_to_enemy_group(group, grp_objective)
	group.objective = grp_objective

	if grp_objective.area then
		grp_objective.moving_out = true

		if not grp_objective.nav_seg and grp_objective.coarse_path then
			grp_objective.nav_seg = grp_objective.coarse_path[#grp_objective.coarse_path][1]
		end
	end

	grp_objective.assigned_t = self._t

	if self._AI_draw_data and self._AI_draw_data.group_id_texts[group.id] then
		self._AI_draw_data.panel:remove(self._AI_draw_data.group_id_texts[group.id])

		self._AI_draw_data.group_id_texts[group.id] = nil
	end
end

function GroupAIStateBesiege:_upd_groups()
	for group_id, group in pairs(self._groups) do
		self:_verify_group_objective(group)

		for u_key, u_data in pairs(group.units) do
			local brain = u_data.unit:brain()
			local current_objective = brain:objective()

			if (not current_objective or current_objective.is_default or current_objective.grp_objective and current_objective.grp_objective ~= group.objective and not current_objective.grp_objective.no_retry) and (not group.objective.follow_unit or alive(group.objective.follow_unit)) then
				local objective = self._create_objective_from_group_objective(group.objective, u_data.unit)

				if objective and brain:is_available_for_assignment(objective) then
					self:set_enemy_assigned(objective.area or group.objective.area, u_key)

					if objective.element then
						objective.element:clbk_objective_administered(u_data.unit)
					end

					u_data.unit:brain():set_objective(objective)
				end
			end
		end
	end
end

function GroupAIStateBesiege:_set_assault_objective_to_group(group, phase)
	if not group.has_spawned then
		return
	end

	local phase_is_anticipation = phase == "anticipation"
	local current_objective = group.objective
	local approach, open_fire, push, pull_back, charge = nil
	local obstructed_area = self:_chk_group_areas_tresspassed(group)
	local group_leader_u_key, group_leader_u_data = self._determine_group_leader(group.units)
	local tactics_map = nil

	if group_leader_u_data and group_leader_u_data.tactics then
		tactics_map = {}

		for _, tactic_name in ipairs(group_leader_u_data.tactics) do
			tactics_map[tactic_name] = true
		end

		if current_objective.tactic and not tactics_map[current_objective.tactic] then
			current_objective.tactic = nil
		end

		for i_tactic, tactic_name in ipairs(group_leader_u_data.tactics) do
			if tactic_name == "deathguard" and not phase_is_anticipation then
				if current_objective.tactic == tactic_name then
					for u_key, u_data in pairs(self._char_criminals) do
						if u_data.status and current_objective.follow_unit == u_data.unit then
							local crim_nav_seg = u_data.tracker:nav_segment()

							if current_objective.area.nav_segs[crim_nav_seg] then
								return
							end
						end
					end
				end

				local closest_crim_u_data, closest_crim_dis_sq = nil

				for u_key, u_data in pairs(self._char_criminals) do
					if u_data.status then
						local closest_u_id, closest_u_data, closest_u_dis_sq = self._get_closest_group_unit_to_pos(u_data.m_pos, group.units)

						if closest_u_dis_sq and (not closest_crim_dis_sq or closest_u_dis_sq < closest_crim_dis_sq) then
							closest_crim_u_data = u_data
							closest_crim_dis_sq = closest_u_dis_sq
						end
					end
				end

				if closest_crim_u_data then
					local search_params = {
						id = "GroupAI_deathguard",
						from_tracker = group_leader_u_data.unit:movement():nav_tracker(),
						to_tracker = closest_crim_u_data.tracker,
						access_pos = self._get_group_acces_mask(group)
					}
					local coarse_path = managers.navigation:search_coarse(search_params)

					if coarse_path then
						local grp_objective = {
							distance = 800,
							type = "assault_area",
							attitude = "engage",
							tactic = "deathguard",
							moving_in = true,
							follow_unit = closest_crim_u_data.unit,
							area = self:get_area_from_nav_seg_id(coarse_path[#coarse_path][1]),
							coarse_path = coarse_path
						}
						group.is_chasing = true

						self:_set_objective_to_enemy_group(group, grp_objective)
						self:_voice_deathguard_start(group)

						return
					end
				end
			elseif tactic_name == "charge" and not current_objective.moving_out and group.in_place_t and (self._t - group.in_place_t > 15 or self._t - group.in_place_t > 4 and self._drama_data.amount <= tweak_data.drama.low) and next(current_objective.area.criminal.units) and group.is_chasing and not current_objective.charge then
				charge = true
			end
		end
	end

	local objective_area = nil

	if obstructed_area then
		if current_objective.moving_out then
			if not current_objective.open_fire then
				open_fire = true
			end
		elseif not current_objective.pushed or charge and not current_objective.charge then
			push = true
		end
	else
		local obstructed_path_index = self:_chk_coarse_path_obstructed(group)

		if obstructed_path_index then
			print("obstructed_path_index", obstructed_path_index)

			objective_area = self:get_area_from_nav_seg_id(group.coarse_path[math.max(obstructed_path_index - 1, 1)][1])
			pull_back = true
		elseif not current_objective.moving_out then
			local has_criminals_close = nil

			if not current_objective.moving_out then
				for area_id, neighbour_area in pairs(current_objective.area.neighbours) do
					if next(neighbour_area.criminal.units) then
						has_criminals_close = true

						break
					end
				end
			end

			if charge then
				push = true
			elseif not has_criminals_close or not group.in_place_t then
				approach = true
			elseif not phase_is_anticipation and not current_objective.open_fire then
				open_fire = true
			elseif not phase_is_anticipation and group.in_place_t and (group.is_chasing or not tactics_map or not tactics_map.ranged_fire or self._t - group.in_place_t > 15) then
				push = true
			elseif phase_is_anticipation and current_objective.open_fire then
				pull_back = true
			end
		end
	end

	objective_area = objective_area or current_objective.area

	if open_fire then
		local grp_objective = {
			attitude = "engage",
			pose = "stand",
			type = "assault_area",
			stance = "hos",
			open_fire = true,
			tactic = current_objective.tactic,
			area = obstructed_area or current_objective.area,
			coarse_path = {
				{
					objective_area.pos_nav_seg,
					mvector3.copy(current_objective.area.pos)
				}
			}
		}

		self:_set_objective_to_enemy_group(group, grp_objective)
		self:_voice_open_fire_start(group)
	elseif approach or push then
		local assault_area, alternate_assault_area, alternate_assault_area_from, assault_path, alternate_assault_path = nil
		local to_search_areas = {
			objective_area
		}
		local found_areas = {
			[objective_area] = "init"
		}

		repeat
			local search_area = table.remove(to_search_areas, 1)

			if next(search_area.criminal.units) then
				local assault_from_here = true

				if not push and tactics_map and tactics_map.flank then
					local assault_from_area = found_areas[search_area]

					if assault_from_area ~= "init" then
						local cop_units = assault_from_area.police.units

						for u_key, u_data in pairs(cop_units) do
							if u_data.group and u_data.group ~= group and u_data.group.objective.type == "assault_area" then
								assault_from_here = false

								if not alternate_assault_area or math.random() < 0.5 then
									local search_params = {
										id = "GroupAI_assault",
										from_seg = current_objective.area.pos_nav_seg,
										to_seg = search_area.pos_nav_seg,
										access_pos = self._get_group_acces_mask(group),
										verify_clbk = callback(self, self, "is_nav_seg_safe")
									}
									alternate_assault_path = managers.navigation:search_coarse(search_params)

									if alternate_assault_path then
										self:_merge_coarse_path_by_area(alternate_assault_path)

										alternate_assault_area = search_area
										alternate_assault_area_from = assault_from_area
									end
								end

								found_areas[search_area] = nil

								break
							end
						end
					end
				end

				if assault_from_here then
					local search_params = {
						id = "GroupAI_assault",
						from_seg = current_objective.area.pos_nav_seg,
						to_seg = search_area.pos_nav_seg,
						access_pos = self._get_group_acces_mask(group),
						verify_clbk = callback(self, self, "is_nav_seg_safe")
					}
					assault_path = managers.navigation:search_coarse(search_params)

					if assault_path then
						self:_merge_coarse_path_by_area(assault_path)

						assault_area = search_area

						break
					end
				end
			else
				for other_area_id, other_area in pairs(search_area.neighbours) do
					if not found_areas[other_area] then
						table.insert(to_search_areas, other_area)

						found_areas[other_area] = search_area
					end
				end
			end
		until #to_search_areas == 0

		if not assault_area and alternate_assault_area then
			assault_area = alternate_assault_area
			found_areas[assault_area] = alternate_assault_area_from
			assault_path = alternate_assault_path
		end

		if assault_area and assault_path then
			local assault_area = push and assault_area or found_areas[assault_area] == "init" and objective_area or found_areas[assault_area]

			if #assault_path > 2 and assault_area.nav_segs[assault_path[#assault_path - 1][1]] then
				table.remove(assault_path)
			end

			local used_grenade = nil

			if push then
				local detonate_pos = nil

				if charge then
					for c_key, c_data in pairs(assault_area.criminal.units) do
						detonate_pos = c_data.unit:movement():m_pos()

						break
					end
				end

				local first_chk = math.random() < 0.5 and self._chk_group_use_flash_grenade or self._chk_group_use_smoke_grenade
				local second_chk = first_chk == self._chk_group_use_flash_grenade and self._chk_group_use_smoke_grenade or self._chk_group_use_flash_grenade
				used_grenade = first_chk(self, group, self._task_data.assault, detonate_pos)
				used_grenade = used_grenade or second_chk(self, group, self._task_data.assault, detonate_pos)

				self:_voice_move_in_start(group)
			end

			if not push or used_grenade then
				local grp_objective = {
					type = "assault_area",
					stance = "hos",
					area = assault_area,
					coarse_path = assault_path,
					pose = push and "crouch" or "stand",
					attitude = push and "engage" or "avoid",
					moving_in = push and true or nil,
					open_fire = push or nil,
					pushed = push or nil,
					charge = charge,
					interrupt_dis = charge and 0 or nil
				}
				group.is_chasing = group.is_chasing or push

				self:_set_objective_to_enemy_group(group, grp_objective)
			end
		end
	elseif pull_back then
		local retreat_area, do_not_retreat = nil

		for u_key, u_data in pairs(group.units) do
			local nav_seg_id = u_data.tracker:nav_segment()

			if current_objective.area.nav_segs[nav_seg_id] then
				retreat_area = current_objective.area

				break
			end

			if self:is_nav_seg_safe(nav_seg_id) then
				retreat_area = self:get_area_from_nav_seg_id(nav_seg_id)

				break
			end
		end

		if not retreat_area and not do_not_retreat and current_objective.coarse_path then
			local forwardmost_i_nav_point = self:_get_group_forwardmost_coarse_path_index(group)

			if forwardmost_i_nav_point then
				local nearest_safe_nav_seg_id = current_objective.coarse_path(forwardmost_i_nav_point)
				retreat_area = self:get_area_from_nav_seg_id(nearest_safe_nav_seg_id)
			end
		end

		if retreat_area then
			local new_grp_objective = {
				attitude = "avoid",
				stance = "hos",
				pose = "crouch",
				type = "assault_area",
				area = retreat_area,
				coarse_path = {
					{
						retreat_area.pos_nav_seg,
						mvector3.copy(retreat_area.pos)
					}
				}
			}
			group.is_chasing = nil

			self:_set_objective_to_enemy_group(group, new_grp_objective)

			return
		end
	end
end

function GroupAIStateBesiege._create_objective_from_group_objective(grp_objective, receiving_unit)
	local objective = {
		grp_objective = grp_objective
	}

	if grp_objective.element then
		objective = grp_objective.element:get_random_SO(receiving_unit)

		if not objective then
			return
		end

		objective.grp_objective = grp_objective

		return
	elseif grp_objective.type == "defend_area" or grp_objective.type == "recon_area" or grp_objective.type == "reenforce_area" then
		objective.type = "defend_area"
		objective.stance = "hos"
		objective.pose = "crouch"
		objective.scan = true
		objective.interrupt_dis = 200
		objective.interrupt_suppression = true
	elseif grp_objective.type == "retire" then
		objective.type = "defend_area"
		objective.stance = "hos"
		objective.pose = "stand"
		objective.scan = true
		objective.interrupt_dis = 200
	elseif grp_objective.type == "assault_area" then
		objective.type = "defend_area"

		if grp_objective.follow_unit then
			objective.follow_unit = grp_objective.follow_unit
			objective.distance = grp_objective.distance
		end

		objective.stance = "hos"
		objective.pose = "stand"
		objective.scan = true
		objective.interrupt_dis = 200
		objective.interrupt_suppression = true
	elseif grp_objective.type == "create_phalanx" then
		objective.type = "phalanx"
		objective.stance = "hos"
		objective.interrupt_dis = nil
		objective.interrupt_health = nil
		objective.interrupt_suppression = nil
		objective.attitude = "avoid"
		objective.path_ahead = true
	elseif grp_objective.type == "hunt" then
		objective.type = "hunt"
		objective.stance = "hos"
		objective.scan = true
		objective.interrupt_dis = 200
	end

	objective.stance = grp_objective.stance or objective.stance
	objective.pose = grp_objective.pose or objective.pose
	objective.area = grp_objective.area
	objective.nav_seg = grp_objective.nav_seg or objective.area.pos_nav_seg
	objective.attitude = grp_objective.attitude or objective.attitude
	objective.interrupt_dis = grp_objective.interrupt_dis or objective.interrupt_dis
	objective.interrupt_health = grp_objective.interrupt_health or objective.interrupt_health
	objective.interrupt_suppression = grp_objective.interrupt_suppression or objective.interrupt_suppression
	objective.pos = grp_objective.pos

	if grp_objective.scan ~= nil then
		objective.scan = grp_objective.scan
	end

	if grp_objective.coarse_path then
		objective.path_style = "coarse_complete"
		objective.path_data = grp_objective.coarse_path
	end

	return objective
end

function GroupAIStateBesiege:_assign_groups_to_retire(allowed_groups, suitable_grp_func)
	for group_id, group in pairs(self._groups) do
		if not allowed_groups[group.type] and group.objective.type ~= "reenforce_area" and group.objective.type ~= "retire" then
			self:_assign_group_to_retire(group)
		elseif suitable_grp_func and allowed_groups[group.type] then
			suitable_grp_func(group)
		end
	end
end

function GroupAIStateBesiege:_assign_group_to_retire(group)
	local retire_area, retire_pos = nil
	local to_search_areas = {
		group.objective.area
	}
	local found_areas = {
		[group.objective.area] = true
	}

	repeat
		local search_area = table.remove(to_search_areas, 1)

		if search_area.flee_points and next(search_area.flee_points) then
			retire_area = search_area
			local flee_point_id, flee_point = next(search_area.flee_points)
			retire_pos = flee_point.pos

			break
		else
			for other_area_id, other_area in pairs(search_area.neighbours) do
				if not found_areas[other_area] then
					table.insert(to_search_areas, other_area)

					found_areas[other_area] = true
				end
			end
		end
	until #to_search_areas == 0

	if not retire_area then
		Application:error("[GroupAIStateBesiege:_assign_group_to_retire] flee point not found. from area:", inspect(group.objective.area), "group ID:", group.id)

		return
	end

	local grp_objective = {
		type = "retire",
		area = retire_area or group.objective.area,
		coarse_path = {
			{
				retire_area.pos_nav_seg,
				retire_area.pos
			}
		},
		pos = retire_pos
	}

	self:_set_objective_to_enemy_group(group, grp_objective)
end

function GroupAIStateBesiege._determine_group_leader(units)
	local highest_rank, highest_ranking_u_key, highest_ranking_u_data = nil

	for u_key, u_data in pairs(units) do
		if u_data.rank and (not highest_rank or highest_rank < u_data.rank) then
			highest_rank = u_data.rank
			highest_ranking_u_key = u_key
			highest_ranking_u_data = u_data
		end
	end

	return highest_ranking_u_key, highest_ranking_u_data
end

function GroupAIStateBesiege._get_closest_group_unit_to_pos(pos, units)
	local closest_dis_sq, closest_u_key, closest_u_data = nil

	for u_key, u_data in pairs(units) do
		local my_dis = mvector3.distance_sq(pos, u_data.m_pos)

		if not closest_dis_sq or my_dis < closest_dis_sq then
			closest_dis_sq = my_dis
			closest_u_key = u_key
			closest_u_data = u_data
		end
	end

	return closest_u_key, closest_u_data, closest_dis_sq
end

function GroupAIStateBesiege:_chk_group_use_smoke_grenade(group, task_data, detonate_pos)
	if task_data.use_smoke and not self:is_smoke_grenade_active() then
		local shooter_pos, shooter_u_data = nil
		local duration = tweak_data.group_ai.smoke_grenade_lifetime

		for u_key, u_data in pairs(group.units) do
			if u_data.tactics_map and u_data.tactics_map.smoke_grenade then
				if not detonate_pos then
					local nav_seg_id = u_data.tracker:nav_segment()
					local nav_seg = managers.navigation._nav_segments[nav_seg_id]

					for neighbour_nav_seg_id, door_list in pairs(nav_seg.neighbours) do
						local area = self:get_area_from_nav_seg_id(neighbour_nav_seg_id)

						if task_data.target_areas[1].nav_segs[neighbour_nav_seg_id] or next(area.criminal.units) then
							local random_door_id = door_list[math.random(#door_list)]

							if type(random_door_id) == "number" then
								detonate_pos = managers.navigation._room_doors[random_door_id].center
							else
								detonate_pos = random_door_id:script_data().element:nav_link_end_pos()
							end

							shooter_pos = mvector3.copy(u_data.m_pos)
							shooter_u_data = u_data

							break
						end
					end
				end

				if detonate_pos and shooter_u_data then
					self:detonate_smoke_grenade(detonate_pos, shooter_pos, duration, false)

					task_data.use_smoke_timer = self._t + math.lerp(tweak_data.group_ai.smoke_and_flash_grenade_timeout[1], tweak_data.group_ai.smoke_and_flash_grenade_timeout[2], math.rand(0, 1)^0.5)
					task_data.use_smoke = false

					if shooter_u_data.char_tweak.chatter.smoke and not shooter_u_data.unit:sound():speaking(self._t) then
						self:chk_say_enemy_chatter(shooter_u_data.unit, shooter_u_data.m_pos, "smoke")
					end

					return true
				end
			end
		end
	end
end

function GroupAIStateBesiege:_chk_group_use_flash_grenade(group, task_data, detonate_pos)
	if task_data.use_smoke and not self:is_smoke_grenade_active() then
		local shooter_pos, shooter_u_data = nil
		local duration = tweak_data.group_ai.flash_grenade_lifetime

		for u_key, u_data in pairs(group.units) do
			if u_data.tactics_map and u_data.tactics_map.flash_grenade then
				if not detonate_pos then
					local nav_seg_id = u_data.tracker:nav_segment()
					local nav_seg = managers.navigation._nav_segments[nav_seg_id]

					for neighbour_nav_seg_id, door_list in pairs(nav_seg.neighbours) do
						if task_data.target_areas[1].nav_segs[neighbour_nav_seg_id] then
							local random_door_id = door_list[math.random(#door_list)]

							if type(random_door_id) == "number" then
								detonate_pos = managers.navigation._room_doors[random_door_id].center
							else
								detonate_pos = random_door_id:script_data().element:nav_link_end_pos()
							end

							shooter_pos = mvector3.copy(u_data.m_pos)
							shooter_u_data = u_data

							break
						end
					end
				end

				if detonate_pos and shooter_u_data then
					self:detonate_smoke_grenade(detonate_pos, shooter_pos, duration, true)

					task_data.use_smoke_timer = self._t + math.lerp(tweak_data.group_ai.smoke_and_flash_grenade_timeout[1], tweak_data.group_ai.smoke_and_flash_grenade_timeout[2], math.random()^0.5)
					task_data.use_smoke = false

					if shooter_u_data.char_tweak.chatter.flash_grenade and not shooter_u_data.unit:sound():speaking(self._t) then
						self:chk_say_enemy_chatter(shooter_u_data.unit, shooter_u_data.m_pos, "flash_grenade")
					end

					return true
				end
			end
		end
	end
end

function GroupAIStateBesiege:detonate_smoke_grenade(detonate_pos, shooter_pos, duration, flashbang)
	managers.network:session():send_to_peers_synched("sync_smoke_grenade", detonate_pos, shooter_pos, duration, flashbang and true or false)
	self:sync_smoke_grenade(detonate_pos, shooter_pos, duration, flashbang)
end

function GroupAIStateBesiege:detonate_cs_grenade(detonate_pos, shooter_pos, duration)
	managers.network:session():send_to_peers_synched("sync_cs_grenade", detonate_pos, shooter_pos, duration)
	self:sync_cs_grenade(detonate_pos, shooter_pos, duration)
end

function GroupAIStateBesiege:_assign_assault_groups_to_retire()
	local function suitable_grp_func(group)
		if group.objective.type == "assault_area" then
			local regroup_area = nil

			if next(group.objective.area.criminal.units) then
				for other_area_id, other_area in pairs(group.objective.area.neighbours) do
					if not next(other_area.criminal.units) then
						regroup_area = other_area

						break
					end
				end
			end

			regroup_area = regroup_area or group.objective.area
			local grp_objective = {
				stance = "hos",
				attitude = "avoid",
				pose = "crouch",
				type = "recon_area",
				area = regroup_area
			}

			self:_set_objective_to_enemy_group(group, grp_objective)
		end
	end

	self:_assign_groups_to_retire(self._tweak_data.recon.groups, suitable_grp_func)
end

function GroupAIStateBesiege:_assign_recon_groups_to_retire()
	local function suitable_grp_func(group)
		if group.objective.type == "recon_area" then
			local grp_objective = {
				stance = "hos",
				attitude = "avoid",
				pose = "crouch",
				type = "assault_area",
				area = group.objective.area
			}

			self:_set_objective_to_enemy_group(group, grp_objective)
		end
	end

	self:_assign_groups_to_retire(self._tweak_data.assault.groups, suitable_grp_func)
end

function GroupAIStateBesiege:_assign_enemy_groups_to_reenforce()
	for group_id, group in pairs(self._groups) do
		if group.has_spawned and group.objective.type == "reenforce_area" then
			local locked_up_in_area = nil

			if group.objective.moving_out then
				local done_moving = true

				for u_key, u_data in pairs(group.units) do
					local objective = u_data.unit:brain():objective()

					if not objective or objective.is_default or objective.grp_objective and objective.grp_objective ~= group.objective then
						if objective then
							if objective.area then
								locked_up_in_area = objective.area
							elseif objective.nav_seg then
								locked_up_in_area = self:get_area_from_nav_seg_id(objective.nav_seg)
							else
								locked_up_in_area = self:get_area_from_nav_seg_id(u_data.tracker:nav_segment())
							end
						else
							locked_up_in_area = self:get_area_from_nav_seg_id(u_data.tracker:nav_segment())
						end
					elseif not objective.in_place then
						done_moving = false
					end
				end

				if done_moving then
					group.objective.moving_out = nil
					group.in_place_t = self._t
					group.objective.moving_in = nil

					self:_voice_move_complete(group)
				end
			end

			if not group.objective.moving_in then
				if locked_up_in_area and locked_up_in_area ~= group.objective.area then
					-- Nothing
				elseif not group.objective.moving_out then
					self:_set_reenforce_objective_to_group(group)
				end
			end
		end
	end
end

function GroupAIStateBesiege:_set_reenforce_objective_to_group(group)
	if not group.has_spawned then
		return
	end

	local current_objective = group.objective

	if current_objective.target_area then
		if current_objective.moving_out and not current_objective.moving_in then
			local forwardmost_i_nav_point = self:_get_group_forwardmost_coarse_path_index(group)

			if forwardmost_i_nav_point then
				for i = forwardmost_i_nav_point + 1, #current_objective.coarse_path, 1 do
					local nav_point = current_objective.coarse_path[forwardmost_i_nav_point]

					if not self:is_nav_seg_safe(nav_point[1]) then
						for i = 0, #current_objective.coarse_path - forwardmost_i_nav_point, 1 do
							table.remove(current_objective.coarse_path)
						end

						local grp_objective = {
							attitude = "avoid",
							scan = true,
							pose = "stand",
							type = "reenforce_area",
							stance = "hos",
							area = self:get_area_from_nav_seg_id(current_objective.coarse_path[#current_objective.coarse_path][1]),
							target_area = current_objective.target_area
						}

						self:_set_objective_to_enemy_group(group, grp_objective)

						return
					end
				end
			end
		end

		if not current_objective.moving_out and not current_objective.area.neighbours[current_objective.target_area.id] then
			local search_params = {
				id = "GroupAI_reenforce",
				from_seg = current_objective.area.pos_nav_seg,
				to_seg = current_objective.target_area.pos_nav_seg,
				access_pos = self._get_group_acces_mask(group),
				verify_clbk = callback(self, self, "is_nav_seg_safe")
			}
			local coarse_path = managers.navigation:search_coarse(search_params)

			if coarse_path then
				self:_merge_coarse_path_by_area(coarse_path)
				table.remove(coarse_path)

				local grp_objective = {
					scan = true,
					pose = "stand",
					type = "reenforce_area",
					stance = "hos",
					attitude = "avoid",
					area = self:get_area_from_nav_seg_id(coarse_path[#coarse_path][1]),
					target_area = current_objective.target_area,
					coarse_path = coarse_path
				}

				self:_set_objective_to_enemy_group(group, grp_objective)
			end
		end

		if not current_objective.moving_out and current_objective.area.neighbours[current_objective.target_area.id] and not next(current_objective.target_area.criminal.units) then
			local grp_objective = {
				stance = "hos",
				scan = true,
				pose = "crouch",
				type = "reenforce_area",
				attitude = "engage",
				area = current_objective.target_area
			}

			self:_set_objective_to_enemy_group(group, grp_objective)

			group.objective.moving_in = true
		end
	end
end

function GroupAIStateBesiege:_get_group_forwardmost_coarse_path_index(group)
	local coarse_path = group.objective.coarse_path
	local forwardmost_i_nav_point = #coarse_path

	while forwardmost_i_nav_point > 0 do
		local nav_seg = coarse_path[forwardmost_i_nav_point][1]
		local area = self:get_area_from_nav_seg_id(nav_seg)

		for u_key, u_data in pairs(group.units) do
			if area.nav_segs[u_data.unit:movement():nav_tracker():nav_segment()] then
				return forwardmost_i_nav_point
			end
		end

		forwardmost_i_nav_point = forwardmost_i_nav_point - 1
	end
end

function GroupAIStateBesiege:_voice_deathguard_start(group)
	local time = self._t

	for u_key, unit_data in pairs(group.units) do
		if unit_data.char_tweak.chatter.go_go and self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "go_go") then
			break
		end
	end
end

function GroupAIStateBesiege:_voice_open_fire_start(group)
	for u_key, unit_data in pairs(group.units) do
		if unit_data.char_tweak.chatter.aggressive and self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "aggressive") then
			break
		end
	end
end

function GroupAIStateBesiege:_voice_move_in_start(group)
	for u_key, unit_data in pairs(group.units) do
		if unit_data.char_tweak.chatter.go_go and self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "go_go") then
			break
		end
	end
end

function GroupAIStateBesiege:_voice_move_complete(group)
	for u_key, unit_data in pairs(group.units) do
		if unit_data.char_tweak.chatter.ready and self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "ready") then
			break
		end
	end
end

function GroupAIStateBesiege:_voice_delay_assault(group)
	local time = self._t

	for u_key, unit_data in pairs(group.units) do
		if not unit_data.unit:sound():speaking(time) then
			unit_data.unit:sound():say("p01", true, nil)

			return true
		end
	end

	return false
end

function GroupAIStateBesiege:_chk_group_areas_tresspassed(group)
	local objective = group.objective
	local occupied_areas = {}

	for u_key, u_data in pairs(group.units) do
		local nav_seg = u_data.tracker:nav_segment()

		for area_id, area in pairs(self._area_data) do
			if area.nav_segs[nav_seg] then
				occupied_areas[area_id] = area
			end
		end
	end

	for area_id, area in pairs(occupied_areas) do
		if not self:is_area_safe(area) then
			return area
		end
	end
end

function GroupAIStateBesiege:_chk_coarse_path_obstructed(group)
	local current_objective = group.objective

	if not current_objective.coarse_path then
		return
	end

	local forwardmost_i_nav_point = self:_get_group_forwardmost_coarse_path_index(group)

	if forwardmost_i_nav_point then
		for i = forwardmost_i_nav_point + 1, #current_objective.coarse_path, 1 do
			local nav_point = current_objective.coarse_path[forwardmost_i_nav_point]

			if not self:is_nav_seg_safe(nav_point[1]) then
				return i
			end
		end
	end
end

function GroupAIStateBesiege:_count_criminals_engaged_force(max_count)
	local count = 0
	local all_enemies = self._police

	for c_key, c_data in pairs(self._char_criminals) do
		local c_area = self:get_area_from_nav_seg_id(c_data.tracker:nav_segment())

		for e_key, e_data_prev in pairs(c_data.engaged) do
			local e_data = all_enemies[e_key]

			if e_data then
				local e_group = e_data.group

				if e_group and e_group.objective.type == "assault_area" then
					local e_area = self:get_area_from_nav_seg_id(e_data.tracker:nav_segment())

					if e_area == c_area or e_area.neighbours[c_area] then
						count = count + 1

						if max_count and count == max_count then
							return count
						end
					end
				end
			else
				debug_pause_unit(e_data_prev.unit, "non-enemy engaging player", e_key, inspect(e_data_prev), e_data_prev.unit)

				if managers.enemy:all_civilians()[e_key] then
					print("he is civilian")
				elseif self._criminals[e_key] then
					print("he is criminal")
				else
					print("unknown unit type")
				end
			end
		end
	end

	return count
end

function GroupAIStateBesiege:_verify_group_objective(group)
	local is_objective_broken = nil
	local grp_objective = group.objective
	local coarse_path = grp_objective.coarse_path
	local nav_segments = managers.navigation._nav_segments

	if coarse_path then
		for i_node, node in ipairs(coarse_path) do
			local nav_seg_id = node[1]

			if nav_segments[nav_seg_id].disabled then
				is_objective_broken = true

				break
			end
		end
	end

	if not is_objective_broken then
		return
	end

	local new_area = nil
	local tested_nav_seg_ids = {}

	for u_key, u_data in pairs(group.units) do
		u_data.tracker:move(u_data.m_pos)

		local nav_seg_id = u_data.tracker:nav_segment()

		if not tested_nav_seg_ids[nav_seg_id] then
			tested_nav_seg_ids[nav_seg_id] = true
			local areas = self:get_areas_from_nav_seg_id(nav_seg_id)

			for _, test_area in pairs(areas) do
				for test_nav_seg, _ in pairs(test_area.nav_segs) do
					if not nav_segments[test_nav_seg].disabled then
						new_area = test_area

						break
					end
				end

				if new_area then
					break
				end
			end
		end

		if new_area then
			break
		end
	end

	if not new_area then
		print("[GroupAIStateBesiege:_verify_group_objective] could not find replacement area to", grp_objective.area)

		return
	end

	group.objective = {
		moving_out = false,
		type = grp_objective.type,
		area = new_area
	}
end

function GroupAIStateBesiege:team_data(team_id)
	return self._teams[team_id]
end

function GroupAIStateBesiege:set_char_team(unit, team_id)
	local u_key = unit:key()
	local team = self._teams[team_id]
	local u_data = self._police[u_key]

	if u_data and u_data.group then
		u_data.group.team = team

		for _, other_u_data in pairs(u_data.group.units) do
			other_u_data.unit:movement():set_team(team)
		end

		return
	end

	unit:movement():set_team(team)
end

function GroupAIStateBesiege:set_team_relation(team1_id, team2_id, relation, mutual)
	if mutual then
		self:set_team_relation(team1_id, team2_id, relation, nil)
		self:set_team_relation(team2_id, team1_id, relation, nil)

		return
	end

	if relation == "foe" then
		self._teams[team1_id].foes[team2_id] = true
	elseif relation == "friend" or relation == "neutral" then
		self._teams[team1_id].foes[team2_id] = nil
	end

	if Network:is_server() then
		local team1_index = tweak_data.levels:get_team_index(team1_id)
		local team2_index = tweak_data.levels:get_team_index(team2_id)
		local relation_code = relation == "neutral" and 1 or relation == "friend" and 2 or 3

		managers.network:session():send_to_peers_synched("sync_team_relation", team1_index, team2_index, relation_code)
	end
end

function GroupAIStateBesiege:_check_spawn_phalanx()
	if not Global.game_settings.single_player and self._phalanx_center_pos and self._task_data and self._task_data.assault.active and not self._phalanx_spawn_group and (self._task_data.assault.phase == "build" or self._task_data.assault.phase == "sustain") then
		local now = TimerManager:game():time()
		local respawn_delay = tweak_data.group_ai.phalanx.spawn_chance.respawn_delay

		if not self._phalanx_despawn_time or now >= self._phalanx_despawn_time + respawn_delay then
			local spawn_chance_start = tweak_data.group_ai.phalanx.spawn_chance.start
			self._phalanx_current_spawn_chance = self._phalanx_current_spawn_chance or spawn_chance_start
			self._phalanx_last_spawn_check = self._phalanx_last_spawn_check or now
			self._phalanx_last_chance_increase = self._phalanx_last_chance_increase or now
			local spawn_chance_increase = tweak_data.group_ai.phalanx.spawn_chance.increase
			local spawn_chance_max = tweak_data.group_ai.phalanx.spawn_chance.max

			if self._phalanx_current_spawn_chance < spawn_chance_max and spawn_chance_increase > 0 then
				local chance_increase_intervall = tweak_data.group_ai.phalanx.chance_increase_intervall

				if now >= self._phalanx_last_chance_increase + chance_increase_intervall then
					self._phalanx_last_chance_increase = now
					self._phalanx_current_spawn_chance = math.min(spawn_chance_max, self._phalanx_current_spawn_chance + spawn_chance_increase)
				end
			end

			if self._phalanx_current_spawn_chance > 0 then
				local check_spawn_intervall = tweak_data.group_ai.phalanx.check_spawn_intervall

				if now >= self._phalanx_last_spawn_check + check_spawn_intervall then
					self._phalanx_last_spawn_check = now

					if math.random() <= self._phalanx_current_spawn_chance then
						self:_spawn_phalanx()
					end
				end
			end
		end
	end
end

function GroupAIStateBesiege:_spawn_phalanx()
	if not self._phalanx_center_pos then
		Application:error("self._phalanx_center_pos NOT SET!!!")

		return
	end

	local phalanx_center_pos = self._phalanx_center_pos
	local phalanx_center_nav_seg = managers.navigation:get_nav_seg_from_pos(phalanx_center_pos)
	local phalanx_area = self:get_area_from_nav_seg_id(phalanx_center_nav_seg)
	local phalanx_group = {
		Phalanx = {
			1,
			1,
			1
		}
	}

	if not phalanx_area then
		Application:error("Could not get area from phalanx_center_nav_seg!")

		return
	end

	local spawn_group, spawn_group_type = self:_find_spawn_group_near_area(phalanx_area, phalanx_group, nil, nil, nil)

	if not spawn_group then
		Application:error("Could not get spawn_group from phalanx_area!")

		return
	end

	if spawn_group.spawn_pts[1] and spawn_group.spawn_pts[1].pos then
		local spawn_pos = spawn_group.spawn_pts[1].pos
		local spawn_nav_seg = managers.navigation:get_nav_seg_from_pos(spawn_pos)
		local spawn_area = self:get_area_from_nav_seg_id(spawn_nav_seg)

		if spawn_group then
			local grp_objective = {
				type = "defend_area",
				area = spawn_area,
				nav_seg = spawn_nav_seg
			}

			print("Phalanx spawn started!")

			self._phalanx_spawn_group = self:_spawn_in_group(spawn_group, spawn_group_type, grp_objective, nil)

			self:set_assault_endless(true)
			managers.game_play_central:announcer_say("cpa_a02_01")
			managers.network:session():send_to_peers_synched("group_ai_event", self:get_sync_event_id("phalanx_spawned"), 0)
		end
	end
end

function GroupAIStateBesiege:_check_phalanx_group_has_spawned()
	if self._phalanx_spawn_group then
		if self._phalanx_spawn_group.has_spawned then
			if not self._phalanx_spawn_group.set_to_phalanx_group_obj then
				local pos = self._phalanx_center_pos
				local nav_seg = managers.navigation:get_nav_seg_from_pos(pos)
				local area = self:get_area_from_nav_seg_id(nav_seg)
				local grp_objective = {
					type = "create_phalanx",
					area = area,
					nav_seg = nav_seg,
					pos = pos
				}

				print("Phalanx spawn finished, setting phalanx objective!")
				self:_set_objective_to_enemy_group(self._phalanx_spawn_group, grp_objective)

				self._phalanx_spawn_group.set_to_phalanx_group_obj = true

				for i, group_unit in pairs(self._phalanx_spawn_group.units) do
					group_unit.unit:base().is_phalanx = true
				end
			end
		else
			print("Phalanx group has not yet spawned completely!")
		end
	end
end

function GroupAIStateBesiege:phalanx_damage_reduction_enable()
	local law1team = self:_get_law1_team()

	self:set_phalanx_damage_reduction_buff(law1team.damage_reduction or tweak_data.group_ai.phalanx.vip.damage_reduction.start)

	self._phalanx_damage_reduction_last_increase = self._phalanx_damage_reduction_last_increase or TimerManager:game():time()
end

function GroupAIStateBesiege:phalanx_damage_reduction_disable()
	self:set_phalanx_damage_reduction_buff(-1)

	self._phalanx_damage_reduction_last_increase = nil
end

function GroupAIStateBesiege:_get_law1_team()
	local team_id = tweak_data.levels:get_default_team_ID("combatant")

	return self:team_data(team_id)
end

function GroupAIStateBesiege:_check_phalanx_damage_reduction_increase()
	local law1team = self:_get_law1_team()
	local damage_reduction_max = tweak_data.group_ai.phalanx.vip.damage_reduction.max

	if law1team.damage_reduction and law1team.damage_reduction < damage_reduction_max then
		local now = TimerManager:game():time()
		local increase_intervall = tweak_data.group_ai.phalanx.vip.damage_reduction.increase_intervall
		local last_increase = self._phalanx_damage_reduction_last_increase

		if now > last_increase + increase_intervall then
			last_increase = now
			local damage_reduction = math.min(damage_reduction_max, law1team.damage_reduction + tweak_data.group_ai.phalanx.vip.damage_reduction.increase)

			self:set_phalanx_damage_reduction_buff(damage_reduction)

			self._phalanx_damage_reduction_last_increase = last_increase

			print("Phalanx damage reduction buff has been increased to ", law1team.damage_reduction, "%!")

			if alive(self:phalanx_vip()) then
				self:phalanx_vip():sound():say("cpw_a05", true, true)
			end
		end
	end
end

function GroupAIStateBesiege:set_phalanx_damage_reduction_buff(damage_reduction)
	local law1team = self:_get_law1_team()
	damage_reduction = damage_reduction or -1

	if law1team then
		if damage_reduction > 0 then
			law1team.damage_reduction = damage_reduction
		else
			law1team.damage_reduction = nil
		end

		self:set_damage_reduction_buff_hud()
	end

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_damage_reduction_buff", damage_reduction)
	end
end

function GroupAIStateBesiege:set_damage_reduction_buff_hud()
	local law1team = self:_get_law1_team()

	if law1team then
		if law1team.damage_reduction then
			print("Setting damage reduction buff icon to ENABLED!")
			managers.hud:set_buff_enabled("vip", true)
		else
			print("Setting damage reduction buff icon to DISABLED!")
			managers.hud:set_buff_enabled("vip", false)
		end
	else
		debug_pause("LAW 1 TEAM NOT FOUND!!!!")
	end
end

function GroupAIStateBesiege:set_assault_endless(enabled)
	self._hunt_mode = enabled

	if enabled then
		managers.hud:sync_set_assault_mode("phalanx")
	else
		managers.hud:sync_set_assault_mode("normal")
	end

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_assault_endless", enabled)
	end
end

function GroupAIStateBesiege:phalanx_despawned()
	self._phalanx_despawn_time = TimerManager:game():time()
	self._phalanx_spawn_group = nil
	local spawn_chance_decrease = tweak_data.group_ai.phalanx.spawn_chance.decrease
	self._phalanx_current_spawn_chance = math.max(0, self._phalanx_current_spawn_chance or tweak_data.group_ai.phalanx.spawn_chance.start - spawn_chance_decrease)
end

function GroupAIStateBesiege:phalanx_spawn_group()
	return self._phalanx_spawn_group
end

function GroupAIStateBesiege:force_end_assault_phase(force_regroup)
	local task_data = self._task_data.assault

	if task_data.active then
		print("GroupAIStateBesiege:force_end_assault_phase()")

		task_data.phase = "fade"
		task_data.force_end = true

		if force_regroup then
			task_data.force_regroup = true

			managers.enemy:update_queue_task("GroupAIStateBesiege._upd_police_activity", nil, nil, self._t + 0.1, nil, nil)
		end
	end

	self:set_assault_endless(false)
end

function GroupAIStateBesiege:get_assault_number()
	return self._assault_number
end

function GroupAIStateBesiege:terminate_assaults()
	self._police_activity_blocked = true
end
