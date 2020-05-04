require("lib/utils/accelbyte/TelemetryConst")

SideJobGenericDLCManager = SideJobGenericDLCManager or class()
SideJobGenericDLCManager.save_version = 1
SideJobGenericDLCManager.global_table_name = "tango"
SideJobGenericDLCManager.save_table_name = "Tango"
SideJobGenericDLCManager.category = "tango"
SideJobGenericDLCManager.category_id = "tango"

function SideJobGenericDLCManager:init()
	self._challenges_tweak_data = tweak_data.tango.challenges

	self:_setup()
end

function SideJobGenericDLCManager:_setup()
	if not Global[self.global_table_name] then
		Global[self.global_table_name] = {}

		self:_setup_challenges()
	end

	self._global = Global[self.global_table_name]

	managers.generic_side_jobs:register(self)
end

function SideJobGenericDLCManager:_setup_challenges()
	if not self._challenges_tweak_data then
		error("Can't setup a SideJobGenericDLCManager if challenges tweak data is defined!")

		return
	end

	local challenges = {}

	for idx, challenge in ipairs(self._challenges_tweak_data) do
		table.insert(challenges, deep_clone(challenge))
	end

	Global[self.global_table_name].challenges = challenges
end

function SideJobGenericDLCManager:reset()
	Global[self.global_table_name] = nil
	self._global = nil

	self:_setup()
end

function SideJobGenericDLCManager:save(cache)
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

		for _, reward in ipairs(challenge.rewards) do
			local reward_data = deep_clone(reward)

			table.insert(challenge_data.rewards, reward_data)
		end

		table.insert(challenges, challenge_data)
	end

	local save_data = {
		version = self.save_version,
		challenges = challenges
	}
	cache[self.save_table_name] = save_data
end

function SideJobGenericDLCManager:load(cache, version)
	local state = cache[self.save_table_name]

	if state and state.version == self.save_version then
		for idx, saved_challenge in ipairs(state.challenges or {}) do
			local challenge = self:get_challenge(saved_challenge.id)

			if challenge then
				local objectives_complete = true

				if not saved_challenge.completed then
					for _, objective in ipairs(challenge.objectives) do
						for _, saved_objective in ipairs(saved_challenge.objectives) do
							if objective.achievement_id ~= nil and objective.achievement_id == saved_objective.achievement_id or objective.progress_id ~= nil and objective.progress_id == saved_objective.progress_id then
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
	end
end

function SideJobGenericDLCManager:name()
	return "Replace name"
end

function SideJobGenericDLCManager:can_progress()
	return true
end

function SideJobGenericDLCManager:challenges()
	return self._global.challenges
end

function SideJobGenericDLCManager:get_challenge(id)
	for idx, challenge in pairs(self._global.challenges) do
		if challenge.id == id then
			return challenge
		end
	end
end

function SideJobGenericDLCManager:is_mission_complete(challenge_id)
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

function SideJobGenericDLCManager:is_objective_complete(challenge_id, objective_id)
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

function SideJobGenericDLCManager:award(id)
	if not self:can_progress() then
		return
	end

	for _, challenge in ipairs(self:challenges()) do
		self:_update_challenge_progress(challenge, "progress_id", id, 1, self.completed_challenge)
	end
end

function SideJobGenericDLCManager:_update_challenge_progress(challenge, key, id, amount, complete_func)
	for obj_idx, objective in ipairs(challenge.objectives) do
		if objective[key] == id then
			if not objective.completed then
				print("[SideJobGenericDLCManager] awarding:", id)

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
				print("[SideJobGenericDLCManager] already completed, skipping:", id)
			end
		end
	end
end

function SideJobGenericDLCManager:completed_challenge(challenge_or_id)
	local challenge = type(challenge_or_id) == "table" and challenge_or_id or self:get_challenge(challenge_or_id)

	if challenge and not challenge.completed then
		challenge.completed = true
		self._has_completed_mission = true

		if managers.hud then
			managers.hud:challenge_popup(challenge)
		end
	end
end

function SideJobGenericDLCManager:has_already_claimed_reward(challenge_id, reward_id)
	local challenge = self:get_challenge(challenge_id)

	if not challenge then
		Application:error("[SideJobGenericDLCManager:claim_reward] Invalid challenge", challenge_id)

		return nil
	end

	if not challenge.completed then
		Application:error("[SideJobGenericDLCManager:claim_reward] Trying to claim reward from an uncompleted challenge", challenge_id)

		return nil
	end

	local reward = challenge.rewards and challenge.rewards[reward_id]

	if not reward then
		Application:error("[SideJobGenericDLCManager:claim_reward] Invalid reward", challenge_id, reward_id)

		return nil
	end

	if reward.rewarded then
		Application:error("[SideJobGenericDLCManager:claim_reward] Trying to claim reward that is already rewarded", challenge_id, reward_id)

		return true
	end

	return false
end

function SideJobGenericDLCManager:claim_reward(challenge_id, reward_id)
	if not self:can_progress() then
		return
	end

	local claimed = self:has_already_claimed_reward(challenge_id, reward_id)

	if claimed == nil or claimed == true then
		return
	end

	local challenge = self:get_challenge(challenge_id)
	local reward = challenge.rewards and challenge.rewards[reward_id]

	self:_award_reward(reward)

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

function SideJobGenericDLCManager:_award_reward(reward)
	if reward.item_entry then
		local entry = tweak_data:get_raw_value("blackmarket", reward.type_items, reward.item_entry)

		if entry then
			for i = 1, reward.amount or 1 do
				local global_value = reward.global_value or entry.infamous and "infamous" or entry.global_value or entry.dlc or entry.dlcs and entry.dlcs[math.random(#entry.dlcs)] or "normal"

				managers.blackmarket:add_to_inventory(global_value, reward.type_items, reward.item_entry)
			end
		end
	elseif reward[1] == "safehouse_coins" and reward[2] > 0 then
		managers.custom_safehouse:add_coins(reward[2], TelemetryConst.economy_origin.job_reward)
	end
end

function SideJobGenericDLCManager:has_completed_and_claimed_rewards(challenge_id)
	local challenge = self:get_challenge(challenge_id)

	if not challenge then
		Application:error("[SideJobGenericDLCManager:claim_reward] Invalid challenge", challenge_id)

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

function SideJobGenericDLCManager:any_challenge_completed()
	return self._has_completed_mission
end
