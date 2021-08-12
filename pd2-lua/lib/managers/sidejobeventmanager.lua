SideJobEventManager = SideJobEventManager or class()
SideJobEventManager.save_version = 1
SideJobEventManager.global_table_name = "side_job_event"
SideJobEventManager.save_table_name = "side_job_event"
SideJobEventManager.category = "side_job_event"
SideJobEventManager.category_id = "side_job_event"

function SideJobEventManager:init()
	self._challenges_tweak_data = tweak_data.event_jobs.challenges
	self._collective_stats_tweak_data = tweak_data.event_jobs.collective_stats

	self:_setup()
end

function SideJobEventManager:_setup()
	if not Global[self.global_table_name] then
		Global[self.global_table_name] = {}

		self:_setup_challenges()
	end

	self._global = Global[self.global_table_name]

	for _, challenge in ipairs(self:challenges()) do
		self:_update_challenge_tracking(challenge, "track_id", "pda8_tracking", self.completed_challenge)
		self:_update_challenge_stages(challenge, "stage_id", "pda8_stages", self._global.event_stage, self.completed_challenge)
	end
end

function SideJobEventManager:_setup_challenges()
	if not self._challenges_tweak_data then
		error("Can't setup a SideJobEventManager if challenges tweak data is defined!")

		return
	end

	local challenges = {}

	for idx, challenge in ipairs(self._challenges_tweak_data) do
		table.insert(challenges, deep_clone(challenge))
	end

	Global[self.global_table_name].challenges = challenges
	Global[self.global_table_name].collective_stats = deep_clone(self._collective_stats_tweak_data)
	Global[self.global_table_name].event_stage = 0
end

function SideJobEventManager:reset()
	for idx, challenge in ipairs(self._global.challenges) do
		if challenge.completed then
			local identifier = UpgradesManager.AQUIRE_STRINGS[6] .. tostring(challenge.id)

			for _, reward in pairs(challenge.rewards) do
				if reward.rewarded and reward.type_items == "upgrades" then
					managers.upgrades:unaquire(reward.item_entry, identifier)
				end
			end
		end
	end

	Global[self.global_table_name] = nil
	self._global = nil

	self:_setup()
end

function SideJobEventManager:save(cache)
	local challenges = {}

	for idx, challenge in ipairs(self._global.challenges) do
		local challenge_data = {
			id = challenge.id,
			objectives = {},
			rewards = {},
			completed = challenge.completed
		}

		for _, objective in ipairs(challenge.objectives) do
			local objective_data = {}

			for _, save_value in ipairs(objective.save_values) do
				objective_data[save_value] = objective[save_value]
			end

			table.insert(challenge_data.objectives, objective_data)
		end

		if challenge.rewards then
			for _, reward in ipairs(challenge.rewards) do
				local reward_data = deep_clone(reward)

				table.insert(challenge_data.rewards, reward_data)
			end
		end

		table.insert(challenges, challenge_data)
	end

	local collective_stats = {}

	for id, item in pairs(self._global.collective_stats) do
		if item.found and table.size(item.found) > 0 then
			collective_stats[id] = {
				found = item.found
			}
		end
	end

	local save_data = {
		version = self.save_version,
		challenges = challenges,
		collective_stats = collective_stats
	}
	cache[self.save_table_name] = save_data
end

function SideJobEventManager:load(cache, version)
	local state = cache[self.save_table_name]

	if state and state.version == self.save_version then
		for idx, saved_challenge in ipairs(state.challenges or {}) do
			local challenge = self:get_challenge(saved_challenge.id)

			if challenge then
				local objectives_complete = true

				if not saved_challenge.completed then
					for _, objective in ipairs(challenge.objectives) do
						for _, saved_objective in ipairs(saved_challenge.objectives) do
							if objective.achievement_id ~= nil and objective.achievement_id == saved_objective.achievement_id or objective.progress_id ~= nil and objective.progress_id == saved_objective.progress_id or objective.collective_id ~= nil and objective.collective_id == saved_objective.collective_id then
								for _, save_value in ipairs(objective.save_values) do
									objective[save_value] = saved_objective[save_value] or objective[save_value]
								end

								if not saved_objective.completed then
									objectives_complete = false
								end
							end
						end
					end
				else
					for _, objective in ipairs(challenge.objectives) do
						objective.progress = objective.max_progress
						objective.completed = true
					end
				end

				challenge.completed = objectives_complete
				local all_rewarded = true

				for i, reward in ipairs(saved_challenge.rewards) do
					if not reward.rewarded then
						all_rewarded = false
					end

					if challenge.rewards[i] then
						challenge.rewards[i].rewarded = reward.rewarded
					end
				end

				challenge.rewarded = #saved_challenge.rewards > 0 and all_rewarded or false
			end
		end

		for id, saved_item in pairs(state.collective_stats or {}) do
			for idx, item in pairs(self._global.collective_stats) do
				if id == idx then
					item.found = saved_item.found
				else
					item.found = {}
				end
			end
		end
	end
end

function SideJobEventManager:aquire_claimed_upgrades()
	for idx, challenge in ipairs(self._global.challenges) do
		if challenge.completed then
			local identifier = UpgradesManager.AQUIRE_STRINGS[6] .. tostring(challenge.id)

			for _, reward in pairs(challenge.rewards) do
				if reward.rewarded and reward.type_items == "upgrades" then
					managers.upgrades:aquire(reward.item_entry, true, identifier)
				end
			end
		end
	end
end

function SideJobEventManager:name()
	return "Replace name"
end

function SideJobEventManager:can_progress()
	return true
end

function SideJobEventManager:challenges()
	return self._global.challenges
end

function SideJobEventManager:get_challenge(id)
	for idx, challenge in pairs(self._global.challenges) do
		if challenge.id == id then
			return challenge
		end
	end
end

function SideJobEventManager:get_challenge_from_reward(type_items, item_entry)
	local type_pass, entry_pass = nil

	for _, challenge in ipairs(self:challenges()) do
		for _, reward in ipairs(challenge.rewards) do
			type_pass = reward.type_items == type_items
			entry_pass = false

			if type_pass and reward.type_items == "suit_variations" then
				entry_pass = reward.item_entry[1] == item_entry[1] and reward.item_entry[2] == item_entry[2]
			else
				entry_pass = reward.item_entry == item_entry
			end

			if type_pass and entry_pass then
				return challenge
			end
		end
	end

	return nil
end

function SideJobEventManager:get_stat_from_item_id(id)
	for stat_id, stat in pairs(self._global.collective_stats) do
		if table.contains(stat.all, id) then
			return stat_id
		end
	end

	return false
end

function SideJobEventManager:is_item_found(stat, item_id)
	return self._global.collective_stats[stat] and self._global.collective_stats[stat].found[item_id]
end

function SideJobEventManager:is_mission_complete(challenge_id)
	if not self:can_progress() then
		return false
	end

	for idx, challenge in pairs(self._global.challenges) do
		if challenge.id == challenge_id then
			return challenge.completed
		end
	end

	return false
end

function SideJobEventManager:is_objective_complete(challenge_id, objective_id)
	if not self:can_progress() then
		return false
	end

	for idx, challenge in pairs(self._global.challenges) do
		if challenge.id == challenge_id then
			for i, objective in ipairs(challenge.objectives) do
				if objective.id == objective_id then
					return objective.completed
				end
			end
		end
	end

	return false
end

function SideJobEventManager:award(id)
	if not self:can_progress() then
		return
	end

	print("[SideJobEventManager] start trying to award: ", id)

	local update_stats = {}

	for stat_id, stat in pairs(self._global.collective_stats) do
		for _, item_id in ipairs(stat.all) do
			if id == item_id then
				update_stats[stat_id] = id

				if stat.found and not table.contains(stat.found, item_id) then
					table.insert(stat.found, item_id)
				end
			end
		end
	end

	for stat_id, item_id in pairs(update_stats) do
		for _, challenge in ipairs(self:challenges()) do
			self:_update_challenge_collective(challenge, "collective_id", stat_id, item_id, self.completed_challenge)
			self:_update_challenge_progress(challenge, "progress_id", item_id, 1, self.completed_challenge)
		end
	end
end

function SideJobEventManager:_update_challenge_progress(challenge, key, id, amount, complete_func)
	for obj_idx, objective in ipairs(challenge.objectives) do
		if objective[key] == id then
			if not objective.completed then
				print("[SideJobEventManager][Progress] awarding:", id)

				local pass = true
				objective.progress = math.floor(math.min((objective.progress or 0) + amount, objective.max_progress))
				objective.completed = objective.max_progress <= objective.progress

				for _, objective in ipairs(challenge.objectives) do
					if not objective.completed then
						pass = false

						break
					end
				end

				if pass then
					complete_func(self, challenge)

					if managers.hud then
						managers.hud:post_event("Achievement_challenge")
					end
				end

				break
			else
				print("[SideJobEventManager][Progress] already completed, skipping:", id)
			end
		end
	end
end

function SideJobEventManager:_update_challenge_collective(challenge, key, stat_id, item_id, complete_func)
	for obj_idx, objective in ipairs(challenge.objectives) do
		if objective[key] == stat_id then
			if not objective.completed then
				print("[SideJobEventManager][Collective] awarding:", item_id)

				local pass = true
				objective.progress = math.floor(math.min(table.size(self._global.collective_stats[objective.collective_id].found), objective.max_progress))
				objective.completed = objective.max_progress <= objective.progress

				for _, objective in ipairs(challenge.objectives) do
					if not objective.completed then
						pass = false

						break
					end
				end

				if pass then
					complete_func(self, challenge)

					if managers.hud then
						managers.hud:post_event("Achievement_challenge")
					end
				end

				break
			else
				print("[SideJobEventManager][Collective] already completed, skipping:", item_id)
			end
		end
	end
end

function SideJobEventManager:_update_challenge_tracking(challenge, key, stat_id, complete_func)
	for obj_idx, objective in ipairs(challenge.objectives) do
		if objective[key] == stat_id then
			if not objective.completed then
				print("[SideJobEventManager][Tracking] awarding:", stat_id)

				local pass = true
				objective.progress = math.floor(math.min(callback(self, self, objective.track_func)(), objective.max_progress))
				objective.completed = objective.max_progress <= objective.progress

				for _, objective in ipairs(challenge.objectives) do
					if not objective.completed then
						pass = false

						break
					end
				end

				if pass then
					complete_func(self, challenge)

					if managers.hud then
						managers.hud:post_event("Achievement_challenge")
					end
				end

				break
			else
				print("[SideJobEventManager][Tracking] already completed, skipping:", stat_id)
			end
		end
	end
end

function SideJobEventManager:_update_challenge_stages(challenge, key, stat_id, stage, complete_func)
	for obj_idx, objective in ipairs(challenge.objectives) do
		if objective[key] == stat_id then
			if not objective.completed then
				print("[SideJobEventManager][Stages] awarding:", stat_id, stage)

				local pass = true
				objective.progress = table.contains(objective.stages, stage) and 1 or 0
				objective.completed = objective.max_progress <= objective.progress

				for _, objective in ipairs(challenge.objectives) do
					if not objective.completed then
						pass = false

						break
					end
				end

				if pass then
					complete_func(self, challenge)

					if managers.hud then
						managers.hud:post_event("Achievement_challenge")
					end
				end

				break
			else
				print("[SideJobEventManager][Stages] already completed, skipping:", stat_id)
			end
		end
	end
end

function SideJobEventManager:completed_challenge(challenge_or_id)
	local challenge = type(challenge_or_id) == "table" and challenge_or_id or self:get_challenge(challenge_or_id)

	if challenge and not challenge.completed then
		challenge.completed = true
		self._has_completed_mission = true

		if managers.hud then
			managers.hud:challenge_popup(challenge)
		end
	end
end

function SideJobEventManager:has_already_claimed_reward(challenge_id, reward_id)
	local challenge = self:get_challenge(challenge_id)

	if not challenge then
		Application:error("[SideJobEventManager:claim_reward] Invalid challenge", challenge_id)

		return nil
	end

	if not challenge.completed then
		Application:error("[SideJobEventManager:claim_reward] Trying to claim reward from an uncompleted challenge", challenge_id)

		return nil
	end

	local reward = challenge.rewards and challenge.rewards[reward_id]

	if not reward then
		Application:error("[SideJobEventManager:claim_reward] Invalid reward", challenge_id, reward_id)

		return nil
	end

	if reward.rewarded then
		Application:error("[SideJobEventManager:claim_reward] Trying to claim reward that is already rewarded", challenge_id, reward_id)

		return true
	end

	return false
end

function SideJobEventManager:claim_reward(challenge_id, reward_id)
	if not self:can_progress() then
		return
	end

	local claimed = self:has_already_claimed_reward(challenge_id, reward_id)

	if claimed == nil or claimed == true then
		return
	end

	local challenge = self:get_challenge(challenge_id)
	local reward = challenge.rewards and challenge.rewards[reward_id]

	self:_award_reward(reward, challenge_id)

	reward.rewarded = true
	local all_rewarded = true

	for _, r in ipairs(challenge.rewards) do
		if not r.rewarded then
			all_rewarded = false
		end
	end

	if all_rewarded then
		challenge.rewarded = true

		managers.custom_safehouse:award("sidejob_" .. tostring(challenge_id))
	end
end

function SideJobEventManager:_award_reward(reward, challenge_id)
	if reward.item_entry then
		local add_to_inventory = true

		if reward.type_items == "player_styles" then
			managers.blackmarket:on_aquired_player_style(reward.item_entry)

			add_to_inventory = false
		end

		if reward.type_items == "suit_variations" then
			managers.blackmarket:on_aquired_suit_variation(reward.item_entry[1], reward.item_entry[2])

			add_to_inventory = false
		end

		if reward.type_items == "gloves" then
			managers.blackmarket:on_aquired_glove_id(reward.item_entry)

			add_to_inventory = false
		end

		if reward.type_items == "upgrades" then
			local identifier = UpgradesManager.AQUIRE_STRINGS[6] .. tostring(challenge_id)

			managers.upgrades:aquire(reward.item_entry, false, identifier)

			add_to_inventory = false
		end

		if reward.type_items == "offshore" then
			local value_id = tweak_data.blackmarket.cash[reward.item_entry].value_id

			managers.money:on_loot_drop_offshore(value_id)
		end

		if add_to_inventory then
			local entry = tweak_data:get_raw_value("blackmarket", reward.type_items, reward.item_entry)

			if entry then
				for i = 1, reward.amount or 1 do
					local global_value = reward.global_value or entry.infamous and "infamous" or entry.global_value or entry.dlc or entry.dlcs and entry.dlcs[math.random(#entry.dlcs)] or "normal"

					managers.blackmarket:add_to_inventory(global_value, reward.type_items, reward.item_entry)
				end
			end
		end
	elseif reward[1] == "safehouse_coins" and reward[2] > 0 then
		managers.custom_safehouse:add_coins(reward[2], TelemetryConst.economy_origin.job_reward)
	end
end

function SideJobEventManager:has_completed_and_claimed_rewards(challenge_id)
	local challenge = self:get_challenge(challenge_id)

	if not challenge then
		Application:error("[SideJobEventManager:claim_reward] Invalid challenge", challenge_id)

		return nil
	end

	if not challenge.completed or not challenge.rewards then
		return false
	end

	for id, reward in pairs(challenge.rewards) do
		if not reward.rewarded then
			return false
		end
	end

	return true
end

function SideJobEventManager:any_challenge_completed()
	return self._has_completed_mission
end

function SideJobEventManager:set_event_stage(stage)
	print("SideJobEventManager:set_event_stage", stage)

	self._global.event_stage = stage
	local identifier, is_upgrade_locked, is_upgrade_aquired = nil

	for _, challenge in ipairs(self:challenges()) do
		for _, objective in pairs(challenge.objectives) do
			if objective.stage_id then
				objective.completed = false
				objective.progress = 0
			end
		end

		self:_update_challenge_stages(challenge, "stage_id", "pda8_stages", self._global.event_stage, self.completed_challenge)

		identifier = UpgradesManager.AQUIRE_STRINGS[6] .. tostring(challenge.id)

		if challenge.completed then
			for id, reward in pairs(challenge.rewards) do
				if reward.rewarded and reward.type_items == "upgrades" then
					is_upgrade_locked = managers.upgrades:is_upgrade_locked(reward.item_entry)
					is_upgrade_aquired = managers.upgrades:aquired(reward.item_entry, identifier)

					if is_upgrade_locked and is_upgrade_aquired then
						managers.upgrades:unaquire(reward.item_entry, identifier)
					end
				end
			end
		end
	end
end

function SideJobEventManager:register_award_on_mission_end(id)
	if self:get_stat_from_item_id(id) then
		self._global.award_on_mission_end = self._global.award_on_mission_end or {}

		table.insert(self._global.award_on_mission_end, id)
	end
end

function SideJobEventManager:award_on_mission_end()
	for _, item_id in ipairs(self._global.award_on_mission_end or {}) do
		self:award(item_id)
	end

	self._global.award_on_mission_end = {}
end

function SideJobEventManager:get_event_stage()
	return self._global.event_stage
end

function SideJobEventManager:is_event_active()
	return self._global.event_stage < tweak_data.event_jobs.pda_base + 5
end
