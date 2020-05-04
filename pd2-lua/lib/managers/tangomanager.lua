TangoManager = TangoManager or class()
TangoManager.SAVE_DATA_VERSION = 2

function TangoManager:init()
	self:_setup()
end

function TangoManager:_setup()
	if not Global.tango then
		Global.tango = {}

		self:_setup_challenges()
	end

	self._global = Global.tango
end

function TangoManager:_setup_challenges()
	Global.tango.challenges = {}

	for idx, challenge in ipairs(tweak_data.tango.challenges) do
		table.insert(Global.tango.challenges, deep_clone(challenge))
	end
end

function TangoManager:save(cache)
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
		version = TangoManager.SAVE_DATA_VERSION,
		challenges = challenges
	}
	cache.Tango = save_data
end

function TangoManager:load(cache, version)
	local state = cache.Tango

	if state and state.version == TangoManager.SAVE_DATA_VERSION then
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

					challenge.rewards[i].rewarded = reward.rewarded
				end

				challenge.rewarded = all_rewarded
			end
		end
	end
end

function TangoManager:reset()
	Global.tango = nil

	self:_reset_feature()

	self._global = nil

	self:_setup()
end

function TangoManager:_reset_feature()
	managers.features._global.announcements.tango_weapon_unlocked = 1
	managers.features._global.announced.tango_weapon_unlocked = false
end

function TangoManager:challenges()
	return self._global.challenges
end

function TangoManager:get_challenge(id)
	for idx, challenge in pairs(self._global.challenges) do
		if challenge.id == id then
			return challenge
		end
	end
end

function TangoManager:can_progress()
	return managers.dlc:has_tango()
end

function TangoManager:is_mission_complete(challenge_id)
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

function TangoManager:is_objective_complete(challenge_id, objective_id)
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

function TangoManager:has_unlocked_arbiter()
	if not self:can_progress() then
		return nil
	end

	for _, challenge in ipairs(self:challenges()) do
		if not challenge.completed or not challenge.rewarded then
			return false, "bm_menu_tango_locked", "guis/dlcs/tng/textures/pd2/blackmarket/icons/menu_icons/lock_gage"
		end
	end

	return true
end

function TangoManager:award(id)
	if not self:can_progress() then
		return
	end

	print("[TangoManager] awarding:", id)

	for _, challenge in ipairs(self:challenges()) do
		self:_update_challenge_progress(challenge, "progress_id", id, 1, self.completed_challenge)
	end
end

function TangoManager:_update_challenge_progress(challenge, key, id, amount, complete_func)
	for obj_idx, objective in ipairs(challenge.objectives) do
		if not objective.completed and objective[key] == id then
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
		end
	end
end

function TangoManager:completed_challenge(challenge_or_id)
	local challenge = type(challenge_or_id) == "table" and challenge_or_id or self:get_challenge(challenge_or_id)

	if challenge and not challenge.completed then
		challenge.completed = true
		self._has_completed_mission = true

		if managers.hud then
			managers.hud:challenge_popup(challenge)
		end
	end
end

function TangoManager:has_already_claimed_reward(challenge_id, reward_id)
	local challenge = self:get_challenge(challenge_id)

	if not challenge then
		Application:error("[TangoManager:claim_reward] Invalid challenge", challenge_id)

		return nil
	end

	if not challenge.completed then
		Application:error("[TangoManager:claim_reward] Trying to claim reward from an uncompleted challenge", challenge_id)

		return nil
	end

	local reward = challenge.rewards and challenge.rewards[reward_id]

	if not reward then
		Application:error("[TangoManager:claim_reward] Invalid reward", challenge_id, reward_id)

		return nil
	end

	if reward.rewarded then
		Application:error("[TangoManager:claim_reward] Trying to claim reward that is already rewarded", challenge_id, reward_id)

		return true
	end

	return false
end

function TangoManager:claim_reward(challenge_id, reward_id)
	if not self:can_progress() then
		return
	end

	local claimed = self:has_already_claimed_reward(challenge_id, reward_id)

	if claimed == nil or claimed == true then
		return
	end

	local challenge = self:get_challenge(challenge_id)
	local reward = challenge.rewards and challenge.rewards[reward_id]

	if reward.tango_mask then
		managers.blackmarket:add_to_inventory("tango", "masks", reward.tango_mask)
	elseif reward.tango_weapon_part then
		-- Nothing
	elseif reward.item_entry then
		local entry = tweak_data:get_raw_value("blackmarket", reward.type_items, reward.item_entry)

		if entry then
			for i = 1, reward.amount or 1 do
				local global_value = reward.global_value or entry.infamous and "infamous" or entry.global_value or entry.dlc or entry.dlcs and entry.dlcs[math.random(#entry.dlcs)] or "normal"

				managers.blackmarket:add_to_inventory(global_value, reward.type_items, reward.item_entry)
			end
		end
	end

	reward.rewarded = true
	local all_rewarded = true

	for _, r in ipairs(challenge.rewards) do
		if not r.rewarded then
			all_rewarded = false
		end
	end

	if all_rewarded then
		challenge.rewarded = true
	end

	if self:has_unlocked_arbiter() then
		managers.blackmarket:on_aquired_weapon_platform(tweak_data.tango.arbiter_data, tweak_data.tango.arbiter_data.weapon_id)
		self:attempt_announce_tango_weapon()
	end
end

function TangoManager:attempt_announce_tango_weapon()
	if game_state_machine:current_state_name() == "menu_main" and managers.features:can_announce("tango_weapon_unlocked") and self:has_unlocked_arbiter() then
		managers.features:announce_feature("tango_weapon_unlocked")
	end
end

function TangoManager:announce_tango_weapon()
	local weapon_id = tweak_data.tango.arbiter_data.weapon_id
	local weapon_tweak = tweak_data.weapon[weapon_id]
	local category = weapon_tweak.selection_index == 2 and "secondaries" or "primaries"
	local dialog_data = {
		title = managers.localization:text("dialog_new_unlock_title"),
		text = managers.localization:text("dialog_tango_complete_desc", {
			weapon = managers.localization:text(weapon_tweak.name_id)
		})
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}
	local weapon_id = managers.weapon_factory:get_weapon_id_by_factory_id(tweak_data.tango.arbiter_data.factory_id)

	if weapon_id then
		dialog_data.texture = managers.blackmarket:get_weapon_icon_path(weapon_id, nil)
	end

	managers.system_menu:show_new_unlock(dialog_data)
end

function TangoManager:any_challenge_completed()
	return self._has_completed_mission
end
