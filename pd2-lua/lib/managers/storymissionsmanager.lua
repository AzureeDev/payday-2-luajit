require("lib/utils/accelbyte/TelemetryConst")

StoryMissionsManager = StoryMissionsManager or class()
StoryMissionsManager._version = 2

function StoryMissionsManager:init()
	if not Global.story_mission_manager then
		Global.story_mission_manager = {}
		local gm = Global.story_mission_manager
		gm.missions = {}
		gm.mission_order = {}

		for idx, mission in ipairs(tweak_data.story.missions) do
			local m = deep_clone(mission)
			m.order = idx
			gm.missions[m.id] = m

			table.insert(gm.mission_order, m)

			m.objectives_flat = {}

			for _, t in pairs(m.objectives) do
				for _, o in pairs(t) do
					m.objectives_flat[o.progress_id] = o
					local dlc = nil

					for _, id in pairs(o.levels or {}) do
						local found = tweak_data.narrative.jobs[id].dlc

						if found and dlc and dlc ~= found then
							Application:error("Found multiple DLC's for a single objecitive!", o.progress_id)
						end

						o.dlc = found
					end
				end
			end
		end
	end

	self._global = Global.story_mission_manager
	self._global.current_mission = self._global.mission_order[1]

	call_on_next_update(function ()
		managers.story:_find_next_mission()

		local id = managers.job:current_job_id()

		if id and game_state_machine:current_state_name() ~= "menu_main" then
			local rewards = {
				safehouse = "story_first_safehouse"
			}
			local r = rewards[id]

			if r then
				self:award(r)
			end
		end
	end)
end

function StoryMissionsManager:current_mission()
	return self._global.current_mission
end

function StoryMissionsManager:get_mission(id)
	return self._global.missions[id]
end

function StoryMissionsManager:get_mission_at(i)
	return self._global.mission_order[i]
end

function StoryMissionsManager:missions()
	return self._global.missions
end

function StoryMissionsManager:missions_in_order()
	return self._global.mission_order
end

function StoryMissionsManager:get_mission_levels(id)
	local m = self:_get_or_current(id)

	if not m then
		return
	end

	local levels = {}

	for _, o in pairs(m.objectives_flat) do
		if o.levels then
			table.insert(levels, o.levels)
		end
	end

	return levels
end

function StoryMissionsManager:award(id, steps)
	steps = steps or 1
	local m = self:current_mission() or {}
	local o = m.objectives_flat and m.objectives_flat[id]

	if not o or o.completed then
		return
	end

	o.progress = o.progress + 1

	print("[Story]", "progress", id, o.progress)

	if o.max_progress <= o.progress then
		print("[Story]", "objective complete", id, o.progress, o.max_progress)

		o.completed = true
		o.progress = o.max_progress

		self:_check_complete(m)
	end
end

function StoryMissionsManager:claim_rewards(mission)
	mission = self:_get_or_current(mission)

	if not mission then
		return
	end

	for _, t in pairs(mission.rewards or {}) do
		self:_reward(t)
	end

	mission.rewarded = true

	self:_find_next_mission()
	managers.savefile:save_progress()
end

function StoryMissionsManager:_reward(reward)
	if reward.type_items == "xp" then
		local value_id = tweak_data.blackmarket[reward.type_items][reward.item_entry].value_id

		managers.experience:on_loot_drop_xp(value_id, true)
	elseif reward.item_entry then
		local entry = tweak_data:get_raw_value("blackmarket", reward.type_items, reward.item_entry)

		if entry then
			for i = 1, reward.amount or 1 do
				local global_value = reward.global_value or entry.infamous and "infamous" or entry.global_value or entry.dlc or entry.dlcs and entry.dlcs[math.random(#entry.dlcs)] or "normal"

				managers.blackmarket:add_to_inventory(global_value, reward.type_items, reward.item_entry)
			end
		else
			Application:error("[Story] Failed to give reward", reward.type_items, reward.item_entry)
		end
	elseif reward[1] == "safehouse_coins" and reward[2] > 0 then
		managers.custom_safehouse:add_coins(reward[2], TelemetryConst.economy_origin.mission_reward)
	else
		Application:error("[Story] Failed to give reward")
	end
end

function StoryMissionsManager:_check_complete(mission)
	mission = self:_get_or_current(mission)

	if not mission then
		return
	end

	local complete = true

	for _, list in pairs(mission.objectives) do
		complete = true

		for _, o in pairs(list) do
			if not o.completed then
				complete = false

				break
			end
		end

		if complete then
			mission.completed = true

			break
		end
	end

	if mission.completed and mission == self:current_mission() and mission.rewarded then
		self:_find_next_mission()
	end
end

function StoryMissionsManager:_find_next_mission(dont_set)
	local last = nil

	for _, m in pairs(self._global.mission_order) do
		if not m.completed or not m.rewarded then
			if not dont_set then
				self:_change_current_mission(m)
			end

			return m
		end

		last = last or m.last_mission and m
	end

	if not dont_set then
		self:_change_current_mission(last)
	end

	return last
end

function StoryMissionsManager:_change_current_mission(mission)
	self._global.current_mission = mission

	if mission and mission.custom_check then
		tweak_data.story[mission.custom_check](mission)
		self:_check_complete()
	end
end

function StoryMissionsManager:_get_offset_mission(mission, offset)
	local m = self:_get_or_current(mission)

	if not m then
		return
	end

	return self._global.mission_order[m.order + offset]
end

function StoryMissionsManager:_get_or_current(mission)
	if mission then
		if type(mission) == "string" then
			return self:get_mission(mission)
		end

		return mission
	end

	return self:current_mission()
end

function StoryMissionsManager:save(cache)
	local completed_missions = {}

	for _, mission in ipairs(self._global.mission_order) do
		if not mission.completed then
			break
		end

		completed_missions[mission.id] = {
			id = mission.id,
			objectives = self:_save_objectives(mission),
			rewarded = mission.rewarded
		}
	end

	local current_mission = nil

	if self._global.current_mission then
		local m = self._global.current_mission
		current_mission = {
			id = m.id,
			objectives = self:_save_objectives(m),
			rewarded = m.rewarded
		}
	end

	local state = {
		version = StoryMissionsManager._version,
		completed_missions = completed_missions,
		current_mission = current_mission
	}
	cache.story_missions_manager = state
end

function StoryMissionsManager:_save_objectives(mission)
	local res = {}

	for id, o in pairs(mission.objectives_flat) do
		local state = {}
		res[id] = state
		state.progress_id = o.progress_id
		state.completed = o.completed
		state.progress = o.progress
	end

	return res
end

function StoryMissionsManager:_migrate_save_data(version_from, version_to, state)
	if version_to - version_from > 1 then
		version_from = self:_migrate_save_data(version_from, version_to - 1, state)
	end

	if version_from == 1 then
		for id, saved_mission in pairs(state.completed_missions or {}) do
			local mission = self:get_mission(id)

			if mission then
				saved_mission.objectives = {}

				for _, sub_obj in ipairs(mission.objectives[1] or {}) do
					local objective_data = {
						completed = true,
						progress_id = sub_obj.progress_id,
						progress = sub_obj.max_progress
					}
					saved_mission.objectives[sub_obj.progress_id] = objective_data
				end
			end
		end
	end
end

function StoryMissionsManager:load(cache, version)
	local state = cache.story_missions_manager

	if not state then
		return
	end

	if (state.version or 0) < self._version then
		self:_migrate_save_data(state.version, self._version, state)
	end

	for id, c in pairs(state.completed_missions or {}) do
		local m = self:get_mission(id)

		if m then
			m.completed = true
			m.rewarded = c.rewarded

			for id, o in pairs(c.objectives or {}) do
				local my_o = m.objectives_flat[id]

				if my_o then
					my_o.completed = o.completed
					my_o.progress = o.progress
				end
			end
		end
	end

	local curr = state.current_mission

	if curr then
		local m = self:get_mission(curr.id)
		self._global.current_mission = m

		if m then
			for id, o in pairs(curr.objectives) do
				local my_o = m.objectives_flat[id]

				if my_o then
					my_o.completed = o.completed
					my_o.progress = o.progress
				end
			end
		end
	end

	if not self._global.current_mission or self._global.current_mission.rewarded then
		self:_find_next_mission()
	else
		self:_check_complete()
	end
end

function StoryMissionsManager:start_current(objective_id)
	return self:start_mission(self:current_mission(), objective_id)
end

function StoryMissionsManager:start_mission(mission, objective_id)
	if not self:_get_or_current(mission) then
		local m = {
			objectives_flat = {}
		}
	end

	local o = nil

	if not objective_id then
		local left_to_do = table.filter_list(m.objectives_flat, function (o)
			return not o.completed
		end)
		o = table.random(left_to_do)
	else
		o = objective_id and m.objectives_flat[objective_id]
	end

	print(inspect(o))

	if not o then
		return
	end

	if o.crimespree then
		CrimeSpreeMenuComponent:_open_crime_spree_contract()

		return
	end

	local level = table.random(o.levels or {})
	local difficulty = o.difficulty or "normal"

	if not level then
		return
	end

	if o.basic then
		Global.game_settings.team_ai = true
		Global.game_settings.team_ai_option = 2

		MenuCallbackHandler:play_single_player()
		MenuCallbackHandler:start_single_player_job({
			difficulty = "normal",
			job_id = level
		})

		return
	end

	local job_data = tweak_data.narrative:job_data(level)
	local data = {
		difficulty = difficulty,
		difficulty_id = tweak_data:difficulty_to_index(difficulty),
		job_id = level,
		contract_visuals = job_data and job_data.contract_visuals
	}

	managers.menu:open_node(Global.game_settings.single_player and "crimenet_contract_singleplayer" or "crimenet_contract_host", {
		data
	})
end

function StoryMissionsManager:reset_all()
	local function reset(m)
		if not m then
			return
		end

		m.completed = false
		m.rewarded = nil

		for _, o in pairs(m.objectives_flat) do
			o.completed = false
			o.progress = 0
		end
	end

	for _, m in pairs(self._global.missions) do
		reset(m)
	end

	self:_find_next_mission()
end
