GroupAIStateStreet = GroupAIStateStreet or class(GroupAIStateBesiege)

function GroupAIStateStreet:_upd_police_activity()
	self._police_upd_task_queued = false

	if self._ai_enabled then
		self:_upd_SO()
		self:_upd_grp_SO()

		if self._enemy_weapons_hot then
			self:_claculate_drama_value()
			self:_upd_regroup_task()
			self:_upd_reenforce_tasks()
			self:_upd_recon_tasks()
			self:_upd_assault_tasks()
			self:_begin_new_tasks()
			self:_upd_group_spawning()
			self:_upd_groups()
		end
	end

	self:_queue_police_upd_task()
end

function GroupAIStateStreet:_begin_new_tasks()
	local all_areas = self._area_data
	local nav_manager = managers.navigation
	local all_nav_segs = nav_manager._nav_segments
	local task_data = self._task_data
	local t = self._t
	local reenforce_candidates = nil
	local dynamic_spawns = {}
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
		assault_candidates = true
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

	local i = 1

	repeat
		local area = to_search_areas[i]
		local force_factor = area.factors.force
		local demand = force_factor and force_factor.force
		local nr_police = table.size(area.police.units)
		local nr_criminals = table.size(area.criminal.units)

		if demand and (nr_criminals == 0 and reenforce_candidates or demand == 0) then
			local area_free = true

			for i_task, reenforce_task_data in ipairs(reenforce_data.tasks) do
				if reenforce_task_data.target_area == area then
					area_free = false

					break
				end
			end

			if area_free then
				if demand == 0 then
					table.insert(dynamic_spawns, area)
				else
					table.insert(reenforce_candidates, area)
				end
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

	if assault_candidates then
		self:_begin_assault()

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
	end

	for _, reenforce_area in ipairs(dynamic_spawns) do
		self:_begin_reenforce_task(reenforce_area)
	end
end

function GroupAIStateStreet:_begin_assault()
	local assault_data = self._task_data.assault
	assault_data.active = true
	assault_data.next_dispatch_t = nil
	assault_data.tasks = {}
	assault_data.phase = "anticipation"
	assault_data.start_t = self._t
	local anticipation_duration = self:_get_anticipation_duration(tweak_data.group_ai.street.assault.anticipation_duration, assault_data.is_first)
	assault_data.is_first = nil
	assault_data.phase_end_t = self._t + anticipation_duration
	assault_data.force = math.ceil(self:_get_difficulty_dependent_value(tweak_data.group_ai.street.assault.force) * self:_get_balancing_multiplier(tweak_data.group_ai.street.assault.force_balance_mul))
	assault_data.use_smoke = true
	assault_data.use_smoke_timer = 0
	assault_data.force_spawned = 0

	if self._hostage_headcount > 0 then
		assault_data.phase_end_t = assault_data.phase_end_t + self:_get_difficulty_dependent_value(tweak_data.group_ai.street.assault.hostage_hesitation_delay)
		assault_data.is_hesitating = true
		assault_data.voice_delay = self._t + (assault_data.phase_end_t - self._t) / 2
	end

	self._downs_during_assault = 0

	if self._hunt_mode then
		assault_data.phase_end_t = 0
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

function GroupAIStateStreet:_upd_assault_task(task_data)
	local assault_data = self._task_data.assault
	local target_area = task_data.target_area
	local target_pos = target_area.pos
	local t = self._t
	local force_multiplier = 1
	local nr_wanted = assault_data.force * force_multiplier - self:_count_police_force("assault")

	if assault_data.phase == "anticipation" then
		nr_wanted = math.ceil(nr_wanted * 0.75)
	end

	if nr_wanted > 0 and assault_data.phase ~= "fade" and not next(self._spawning_groups) then
		local function verif_clbk(test_spawn_group)
			return test_spawn_group.area.id == target_area.id
		end

		local spawn_group, spawn_group_type = self:_find_spawn_group_near_area(target_area, tweak_data.group_ai.street.assault.groups, nil, nil, verif_clbk)

		if spawn_group then
			local grp_objective = {
				attitude = "engage",
				stance = "hos",
				pose = "stand",
				type = "assault_area",
				area = task_data.target_area,
				coarse_path = {
					{
						task_data.target_area.pos_nav_seg,
						task_data.target_area.pos
					}
				}
			}

			self:_spawn_in_group(spawn_group, spawn_group_type, grp_objective, assault_data)
		end
	end

	if assault_data.phase ~= "anticipation" then
		if assault_data.use_smoke_timer < t then
			assault_data.use_smoke = true
		end

		self:detonate_queued_smoke_grenades()
	end
end

function GroupAIStateStreet:_begin_reenforce_task(reenforce_area)
	local new_task = {
		use_spawn_event = true,
		target_area = reenforce_area,
		start_t = self._t
	}

	table.insert(self._task_data.reenforce.tasks, new_task)

	self._task_data.reenforce.active = true
	self._task_data.reenforce.next_dispatch_t = self._t + self:_get_difficulty_dependent_value(tweak_data.group_ai.street.reenforce.interval)
end

function GroupAIStateStreet:_upd_reenforce_tasks()
	local reenforce_tasks = self._task_data.reenforce.tasks
	local t = self._t
	local i = #reenforce_tasks

	while i > 0 do
		local task_data = reenforce_tasks[i]
		local force_settings = task_data.target_area.factors.force
		local force_required = force_settings and force_settings.force

		if force_required == 0 then
			-- Nothing
		elseif force_required and force_required > 0 then
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
						local spawn_group, spawn_group_type = self:_find_spawn_group_near_area(task_data.target_area, tweak_data.group_ai.street.reenforce.groups, nil, nil, nil)

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
					self._task_data.reenforce.next_dispatch_t = t + self:_get_difficulty_dependent_value(tweak_data.group_ai.street.reenforce.interval)
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

function GroupAIStateStreet:_upd_assault_tasks()
	local assault_data = self._task_data.assault

	if not assault_data.active then
		return
	end

	local assault_tasks = assault_data.tasks
	local reenforce_tasks = self._task_data.reenforce.tasks
	local t = self._t

	self:_assign_recon_groups_to_retire()

	local force_pool = self:_get_difficulty_dependent_value(tweak_data.group_ai.street.assault.force_pool) * self:_get_balancing_multiplier(tweak_data.group_ai.street.assault.force_pool_balance_mul)
	local task_spawn_allowance = force_pool - (self._hunt_mode and 0 or assault_data.force_spawned)

	if assault_data.phase == "anticipation" then
		if task_spawn_allowance <= 0 then
			assault_data.phase = "fade"
			assault_data.phase_end_t = t + tweak_data.group_ai.street.assault.fade_duration
		elseif assault_data.phase_end_t < t or self._drama_data.zone == "high" then
			managers.mission:call_global_event("start_assault")
			managers.hud:start_assault()
			self:_set_rescue_state(false)

			assault_data.phase = "build"
			assault_data.phase_end_t = self._t + tweak_data.group_ai.street.assault.build_duration
			assault_data.is_hesitating = nil

			self:set_assault_mode(true)
			managers.trade:set_trade_countdown(false)
		else
			managers.hud:check_anticipation_voice(assault_data.phase_end_t - t)
			managers.hud:check_start_anticipation_music(assault_data.phase_end_t - t)

			if assault_data.is_hesitating and assault_data.voice_delay < self._t then
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
						assault_data.is_hesitating = nil
					end
				else
					assault_data.is_hesitating = nil
				end
			end
		end
	elseif assault_data.phase == "build" then
		if task_spawn_allowance <= 0 then
			assault_data.phase = "fade"
			assault_data.phase_end_t = t + tweak_data.group_ai.street.assault.fade_duration
		elseif assault_data.phase_end_t < t or self._drama_data.zone == "high" then
			assault_data.phase = "sustain"
			assault_data.phase_end_t = t + math.lerp(self:_get_difficulty_dependent_value(tweak_data.group_ai.street.assault.sustain_duration_min), self:_get_difficulty_dependent_value(tweak_data.group_ai.street.assault.sustain_duration_max), math.random()) * self:_get_balancing_multiplier(tweak_data.group_ai.street.assault.sustain_duration_balance_mul)
		end
	elseif assault_data.phase == "sustain" then
		if task_spawn_allowance <= 0 then
			assault_data.phase = "fade"
			assault_data.phase_end_t = t + tweak_data.group_ai.street.assault.fade_duration
		elseif assault_data.phase_end_t < t and not self._hunt_mode then
			assault_data.phase = "fade"
			assault_data.phase_end_t = t + tweak_data.group_ai.street.assault.fade_duration
		end
	else
		local enemies_left = self:_count_police_force("assault")

		if enemies_left < 7 or t > assault_data.phase_end_t + 350 then
			if t > assault_data.phase_end_t - 8 and not assault_data.said_retreat then
				if self._drama_data.amount < tweak_data.drama.assault_fade_end then
					assault_data.said_retreat = true

					self:_police_announce_retreat()
				end
			elseif assault_data.phase_end_t < t and self._drama_data.amount < tweak_data.drama.assault_fade_end and self:_count_criminals_engaged_force(4) <= 3 then
				assault_data.active = nil
				assault_data.phase = nil
				assault_data.said_retreat = nil

				if self._draw_drama then
					self._draw_drama.assault_hist[#self._draw_drama.assault_hist][2] = t
				end

				managers.mission:call_global_event("end_assault")
				self:_begin_regroup_task()

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

	local closest_blockade_tasks = {}

	for u_key, u_data in pairs(self:all_player_criminals()) do
		local closest_dis_sq, closest_task_i = nil

		for i_task, task_data in ipairs(reenforce_tasks) do
			local force_settings = task_data.target_area.factors.force
			local force_required = force_settings and force_settings.force

			if force_required == 0 then
				local my_dis_sq = mvector3.distance_sq(u_data.m_pos, task_data.target_area.pos)
				local assault_task = assault_tasks[task_data.target_area.id]

				if not assault_task then
					my_dis_sq = my_dis_sq + 100
				end

				if not closest_dis_sq or my_dis_sq < closest_dis_sq then
					closest_dis_sq = my_dis_sq
					closest_task_i = i_task
				end
			end
		end

		if closest_dis_sq then
			closest_blockade_tasks[u_key] = closest_task_i
		end
	end

	for criminal_u_key, i_reenforce_task in pairs(closest_blockade_tasks) do
		local reenforce_task = reenforce_tasks[i_reenforce_task]
		local target_area_id = reenforce_task.target_area.id
		local assault_task = assault_tasks[target_area_id]

		if assault_task then
			if not assault_task.target_criminals[criminal_u_key] then
				assault_task.target_criminals[criminal_u_key] = self._criminals[criminal_u_key]
			end
		else
			assault_task = {
				target_area = self._area_data[target_area_id],
				target_criminals = {
					[criminal_u_key] = self._criminals[criminal_u_key]
				},
				start_t = t
			}
			assault_tasks[target_area_id] = assault_task
		end
	end

	local tasks_to_delete = nil

	for area_id, assault_task in pairs(assault_tasks) do
		local criminals_to_delete = nil

		for criminal_u_key, u_data in pairs(assault_task.target_criminals) do
			local delete_criminal = true

			if self._criminals[criminal_u_key] then
				local closest_blockade_i = closest_blockade_tasks[criminal_u_key]

				if closest_blockade_i then
					local reenforce_task = reenforce_tasks[closest_blockade_i]

					if reenforce_task.target_area.id == area_id then
						delete_criminal = false
					end
				end
			end

			if delete_criminal then
				criminals_to_delete = criminals_to_delete or {}

				table.insert(criminals_to_delete, criminal_u_key)
			end
		end

		if criminals_to_delete then
			for _, criminal_u_key in ipairs(criminals_to_delete) do
				assault_task.target_criminals[criminal_u_key] = nil
			end
		end

		if t - assault_task.start_t > 30 and not next(assault_task.target_criminals) then
			tasks_to_delete = tasks_to_delete or {}

			table.insert(tasks_to_delete, area_id)
		end
	end

	if tasks_to_delete then
		for _, area_id in ipairs(tasks_to_delete) do
			assault_tasks[area_id] = nil
		end
	end

	for group_id, group in pairs(self._groups) do
		if group.has_spawned and group.objective.type == "assault_area" and not assault_tasks[group.objective.area.id] then
			self:_assign_group_to_retire(group)
		end
	end

	local tasks_sorted = {}

	if next(self._spawning_groups) then
		for area_id, assault_task in pairs(assault_tasks) do
			local area_population = 0

			for group_id, group in pairs(self._groups) do
				if group.objective.type == "assault_area" and group.objective.area.id == area_id then
					area_population = area_population + group.initial_size - group.casualties
				end
			end

			tasks_sorted[area_population] = assault_task
		end
	else
		for area_id, assault_task in pairs(assault_tasks) do
			table.insert(tasks_sorted, assault_task)
		end
	end

	for population, assault_task in pairs(tasks_sorted) do
		self:_upd_assault_task(assault_task)
	end
end
