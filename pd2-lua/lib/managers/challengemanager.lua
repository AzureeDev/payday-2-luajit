ChallengeManager = ChallengeManager or class()
ChallengeManager.PATH = "gamedata/challenges"
ChallengeManager.FILE_EXTENSION = "timeline"

function ChallengeManager:init()
	self:_setup()
end

function ChallengeManager:init_finalize()
end

function ChallengeManager:_setup()
	self._default = {}

	if not Global.challenge_manager then
		Global.challenge_manager = {
			challenges = {},
			active_challenges = {},
			visited_crimenet = false,
			retrieving = false,
			validated = false
		}

		self:_load_challenges_from_xml()
		managers.savefile:add_load_sequence_done_callback_handler(callback(self, self, "_load_done"))
	end

	self._global = Global.challenge_manager
end

function ChallengeManager:visited_crimenet()
	return self._global.visited_crimenet
end

function ChallengeManager:visit_crimenet()
	self._global.visited_crimenet = true
end

function ChallengeManager:get_timestamp()
	local year = tonumber(Application:date("%y"))
	local day = tonumber(Application:date("%j"))
	local hour = tonumber(Application:date("%H"))
	local all_days = year * 365 + year % 4 + 1 + day
	local timestamp = all_days * 24 + hour

	return timestamp
end

function ChallengeManager:clear_challenges()
	self._global.challenges = {}
end

function ChallengeManager:is_retrieving()
	return self._global.retrieving
end

function ChallengeManager:is_validated()
	return self._global.validated
end

function ChallengeManager:fetch_challenges()
	if self._load_done then
		self:_fetch_challenges()
	end
end

function ChallengeManager:_fetch_challenges()
	local done_clbk = callback(self, self, "_fetch_done_clbk")
	self._global.retrieving = true
	self._missionsURL = "http://www.overkillsoftware.com/ovk-media/stats/pd2missions.json"

	if SystemInfo:distribution() == Idstring("STEAM") then
		print("Getting Missions from: ", self._missionsURL)
		Steam:http_request(self._missionsURL, done_clbk, Idstring("ChallengeManager:_fetch_challenges()"):key())
	end
end

function ChallengeManager:_fetch_done_clbk(success, s)
	self._global.retrieving = false
	self._global.validated = false

	if success then
		local all_currently_active_challenges = {}
		local currently_active_challenges = {}

		for category, ids in string.gmatch(s, "\"([^,:\"]+)\":\"([^:\"]+)\"") do
			currently_active_challenges[category] = currently_active_challenges[category] or {}

			for active_id in string.gmatch(ids, "'([^,]+)'") do
				if false then
					-- Nothing
				elseif category == "safehouse_daily" then
					managers.custom_safehouse:set_active_daily(active_id)
				elseif category == "weekly_skirmish" then
					managers.skirmish:activate_weekly_skirmish(active_id)
				else
					table.insert(currently_active_challenges[category], active_id)
					table.insert(all_currently_active_challenges, active_id)
				end
			end
		end

		local inactive_challenges = {}
		local timestamp = self:get_timestamp()
		local is_active = nil

		for key, challenge in pairs(self._global.active_challenges) do
			is_active = table.contains(all_currently_active_challenges, challenge.id)

			if not is_active and (challenge.completed and challenge.rewarded or timestamp > challenge.timestamp + challenge.interval) then
				print("[ChallengeManager] Active challenge is invalid", "Challenge id", challenge.id, "Challenge timestamp", challenge.timestamp, "Challenge interval", challenge.interval, "timestamp", timestamp)
				table.insert(inactive_challenges, key)
			end
		end

		for _, key in ipairs(inactive_challenges) do
			self._global.active_challenges[key] = nil
		end

		for category, ids in pairs(currently_active_challenges) do
			for _, id in ipairs(ids) do
				print("[ChallengeManager]", category, id, inspect(self._global.active_challenges[Idstring(id):key()]))
				self:activate_challenge(id, nil, category)
			end
		end

		self._global.validated = true
	end
end

function ChallengeManager:_load_challenges_from_xml()
	local list = PackageManager:script_data(self.FILE_EXTENSION:id(), self.PATH:id())
	local objectives, rewards = nil

	for _, challenge in ipairs(list) do
		if challenge._meta == "challenge" and challenge.id then
			objectives = {}
			rewards = {}

			for _, data in ipairs(challenge) do
				if data._meta == "objective" then
					table.insert(objectives, {
						completed = false,
						achievement_id = data.achievement_id,
						name_id = data.name_id,
						name_s = data.name_s,
						desc_id = data.desc_id,
						display = data.display,
						desc_s = data.desc_s,
						progress_id = data.progress_id,
						max_progress = data.progress_id and data.max_progress or 1,
						progress = data.progress_id and 0
					})
				elseif data._meta == "reward" then
					table.insert(rewards, {
						rewarded = false,
						name_id = data.name_id,
						name_s = data.name_s,
						desc_id = data.desc_id,
						desc_s = data.desc_s,
						type_items = data.type_items,
						item_entry = data.item_entry,
						amount = data.amount,
						global_value = data.global_value or false,
						choose_weapon_reward = data.choose_weapon_reward
					})
				elseif data._meta == "rewards" then
					local texture_rect = nil

					if data.texture_rect then
						texture_rect = string.split(data.texture_rect, ",")

						for i = 1, #texture_rect do
							texture_rect[i] = tonumber(texture_rect[i])
						end
					end

					local reward_data = {
						rewarded = false,
						name_id = data.name_id,
						name_s = data.name_s,
						texture_path = data.texture_path,
						texture_rect = texture_rect,
						smart_loot = data.smart_loot
					}

					for _, reward in ipairs(data) do
						table.insert(reward_data, {
							name_id = reward.name_id,
							name_s = reward.name_s,
							desc_id = reward.desc_id,
							desc_s = reward.desc_s,
							type_items = reward.type_items,
							item_entry = reward.item_entry,
							amount = reward.amount,
							global_value = reward.global_value or false,
							choose_weapon_reward = reward.choose_weapon_reward
						})
					end

					table.insert(rewards, reward_data)
				end
			end

			Global.challenge_manager.challenges[Idstring(challenge.id):key()] = {
				id = challenge.id,
				name_id = challenge.name_id,
				name_s = challenge.name_s,
				desc_id = challenge.desc_id,
				desc_s = challenge.desc_s,
				objective_id = challenge.objective_id,
				objective_s = challenge.objective_s,
				reward_id = challenge.reward_id,
				reward_s = challenge.reward_s,
				rewards = rewards,
				reward_type = challenge.reward_type or "all",
				interval = challenge.interval or false,
				objectives = objectives
			}
		else
			Application:debug("[ChallengeManager:_load_challenges_from_xml] Unrecognized entry in xml", "meta", challenge._meta, "id", challenge.id)
		end
	end
end

function ChallengeManager:get_all_active_challenges()
	return self._global.active_challenges
end

function ChallengeManager:get_challenge(id, key)
	return self._global.challenges[key or Idstring(id):key()]
end

function ChallengeManager:get_active_challenge(id, key)
	return self._global.active_challenges[key or Idstring(id):key()]
end

function ChallengeManager:has_challenge(id, key)
	return not not self._global.challenges[key or Idstring(id):key()]
end

function ChallengeManager:has_active_challenges(id, key)
	return not not self._global.active_challenges[key or Idstring(id):key()]
end

function ChallengeManager:activate_challenge(id, key, category)
	if self:has_active_challenges(id, key) then
		local active_challenge = self:get_active_challenge(id, key)
		active_challenge.category = category

		return false, "active"
	end

	local challenge = self:get_challenge(id, key)

	if challenge then
		challenge = deep_clone(challenge)
		challenge.timestamp = self:get_timestamp()
		challenge.completed = false
		challenge.rewarded = false
		challenge.category = category
		self._global.active_challenges[key or Idstring(id):key()] = challenge

		return true
	end

	Application:error("[ChallengeManager:activate_challenge] Trying to activate non-existing challenge", id, key)

	return false, "not_found"
end

function ChallengeManager:remove_active_challenge(id, key)
	local active_challenge = self:get_active_challenge(id, key)

	if not active_challenge then
		return false, "not_active"
	end

	self._global.active_challenges[key or Idstring(id):key()] = nil
end

function ChallengeManager:_check_challenge_completed(id, key)
	local active_challenge = self:get_active_challenge(id, key)

	if active_challenge and not active_challenge.completed then
		local completed = true

		for _, objective in pairs(active_challenge.objectives) do
			if not objective.completed then
				completed = false

				break
			end
		end

		if completed then
			self._any_challenge_completed = true
			active_challenge.completed = true

			if managers.hud then
				managers.hud:post_event("Achievement_challenge")
				managers.hud:challenge_popup(active_challenge)
			end

			return true
		end
	end

	return false
end

function ChallengeManager:can_progress_challenges()
	return true
end

function ChallengeManager:award(id)
	if self:can_progress_challenges() then
		self:on_achievement_awarded(id)
	end
end

function ChallengeManager:award_progress(progress_id, amount)
	if self:can_progress_challenges() then
		self:on_achievement_progressed(progress_id, amount)
	end
end

function ChallengeManager:on_achievement_awarded(id)
	if not self._global.validated then
		return
	end

	for key, active_challenge in pairs(self._global.active_challenges) do
		for _, objective in ipairs(active_challenge.objectives) do
			if not objective.completed and objective.achievement_id == id then
				objective.completed = true

				self:_check_challenge_completed(active_challenge.id, key)
				managers.mission:call_global_event(Message.OnSideJobComplete)

				break
			end
		end
	end
end

function ChallengeManager:on_achievement_progressed(progress_id, amount)
	if not self._global.validated then
		return
	end

	for key, active_challenge in pairs(self._global.active_challenges) do
		for _, objective in ipairs(active_challenge.objectives) do
			if not objective.completed and objective.progress_id == progress_id then
				objective.progress = math.floor(math.min(objective.progress + (amount or 1), objective.max_progress))
				objective.completed = objective.progress == objective.max_progress

				self:_check_challenge_completed(active_challenge.id, key)

				break
			end
		end
	end
end

function ChallengeManager:can_give_reward(id, key)
	local active_challenge = self:get_active_challenge(id, key)

	return self._global.validated and active_challenge and active_challenge.completed and not active_challenge.rewarded and true or false
end

function ChallengeManager:is_challenge_rewarded(id, key)
	local active_challenge = self:get_active_challenge(id, key)

	return active_challenge and active_challenge.rewarded and true or false
end

function ChallengeManager:is_challenge_completed(id, key)
	local active_challenge = self:get_active_challenge(id, key)

	return active_challenge and active_challenge.completed and true or false
end

function ChallengeManager:any_challenge_completed()
	if self._any_challenge_completed then
		self._any_challenge_completed = nil

		return true
	end
end

function ChallengeManager:any_challenge_rewarded()
	if self._any_challenge_rewarded then
		self._any_challenge_rewarded = nil

		return true
	end
end

function ChallengeManager:is_choose_weapon_unrewarded(id, key, reward_index)
	if not self._global.validated then
		return
	end

	local active_challenge = self:get_active_challenge(id, key)

	if active_challenge and active_challenge.completed and not active_challenge.rewarded then
		local reward = active_challenge.rewards[reward_index]

		if reward and reward.choose_weapon_reward and not reward.rewarded then
			return true
		end
	end

	return false
end

function ChallengeManager:on_give_reward(id, key, reward_index)
	if not self._global.validated then
		return
	end

	local active_challenge = self:get_active_challenge(id, key)

	if active_challenge and active_challenge.completed and not active_challenge.rewarded then
		local reward = active_challenge.rewards[reward_index]

		if reward and not reward.rewarded then
			reward = self:_give_reward(active_challenge, reward)
			local all_rewarded = true

			for _, reward in ipairs(active_challenge.rewards) do
				if not reward.rewarded then
					all_rewarded = false

					break
				end
			end

			active_challenge.rewarded = all_rewarded

			if all_rewarded then
				self._any_challenge_rewarded = true
			end

			return reward
		end
	end
end

function ChallengeManager:set_as_rewarded(id, key, reward_index)
	if not self._global.validated then
		return
	end

	local active_challenge = self:get_active_challenge(id, key)

	if active_challenge and active_challenge.completed and not active_challenge.rewarded then
		local reward = active_challenge.rewards[reward_index]

		if reward and not reward.rewarded then
			reward.rewarded = true
			local all_rewarded = true

			for _, reward in ipairs(active_challenge.rewards) do
				if not reward.rewarded then
					all_rewarded = false

					break
				end
			end

			active_challenge.rewarded = all_rewarded

			if all_rewarded then
				self._any_challenge_rewarded = true
			end

			return reward
		end
	end
end

function ChallengeManager:on_give_all_rewards(id, key)
	if not self._global.validated then
		return
	end

	local active_challenge = self:get_active_challenge(id, key)

	if active_challenge and active_challenge.completed and not active_challenge.rewarded then
		local rewards = {}

		for _, reward in ipairs(active_challenge.rewards) do
			table.insert(rewards, self:_give_reward(active_challenge, reward))
		end

		active_challenge.rewarded = true
		self._any_challenge_rewarded = true

		return rewards
	end
end

function ChallengeManager:_give_reward(challenge, reward)
	if not challenge or reward.rewarded then
		return reward
	end

	reward.rewarded = true
	local reward = reward

	if #reward > 0 then
		local rewards = reward

		if rewards.smart_loot then
			local amount_in_inventory = nil
			local loot_table = {}
			local limited_loot_table = {}
			local most_limited_loot_table = {}
			local entry, global_value = nil

			for _, reward in ipairs(rewards) do
				entry = tweak_data:get_raw_value("blackmarket", reward.type_items, reward.item_entry)
				global_value = reward.global_value or entry.infamous and "infamous" or entry.global_value or entry.dlc or entry.dlcs and entry.dlcs[math.random(#entry.dlcs)] or "normal"
				amount_in_inventory = managers.blackmarket:get_item_amount(global_value, reward.type_items, reward.item_entry, true)

				table.insert(loot_table, reward)

				if tweak_data.blackmarket.weapon_mods[reward.item_entry] and tweak_data.blackmarket.weapon_mods[reward.item_entry].max_in_inventory and amount_in_inventory < tweak_data.blackmarket.weapon_mods[reward.item_entry].max_in_inventory then
					table.insert(limited_loot_table, reward)
				end

				if amount_in_inventory == 0 then
					table.insert(most_limited_loot_table, reward)
				end
			end

			if #most_limited_loot_table > 0 then
				reward = most_limited_loot_table[math.random(#most_limited_loot_table)]
			elseif #limited_loot_table > 0 then
				reward = limited_loot_table[math.random(#limited_loot_table)]
			elseif #loot_table > 0 then
				reward = loot_table[math.random(#loot_table)]
			else
				reward = rewards[math.random(#rewards)]
			end
		else
			reward = rewards[math.random(#rewards)]
		end
	end

	if reward.choose_weapon_reward then
		-- Nothing
	else
		local entry = tweak_data:get_raw_value("blackmarket", reward.type_items, reward.item_entry)

		if entry then
			for i = 1, reward.amount or 1 do
				local global_value = reward.global_value or entry.infamous and "infamous" or entry.global_value or entry.dlc or entry.dlcs and entry.dlcs[math.random(#entry.dlcs)] or "normal"

				cat_print("jansve", "[ChallengeManager:_give_rewards]", i .. "  give", reward.type_items, reward.item_entry, global_value)
				managers.blackmarket:add_to_inventory(global_value, reward.type_items, reward.item_entry)
			end
		end
	end

	if challenge.reward_type == "single" then
		for _, reward in ipairs(challenge.rewards) do
			reward.rewarded = true
		end
	end

	return reward
end

function ChallengeManager:save(data)
	Application:debug("[ChallengeManager:save]")

	local save_data = {
		active_challenges = deep_clone(self._global.active_challenges),
		visited_crimenet = self._global.visited_crimenet
	}

	if self._global.mission_values then
		save_data.mission_values = deep_clone(self._global.mission_values)
	end

	data.ChallengeManager = save_data
end

function ChallengeManager:load(data, version)
	Application:debug("[ChallengeManager:load]")

	local state = data.ChallengeManager

	if state then
		self._global.visited_crimenet = state.visited_crimenet

		for key, challenge in pairs(state.active_challenges or {}) do
			if self._global.challenges[key] then
				self._global.active_challenges[key] = self._global.challenges[key]
				self._global.active_challenges[key].timestamp = challenge.timestamp
				self._global.active_challenges[key].completed = challenge.completed
				self._global.active_challenges[key].rewarded = challenge.rewarded
				self._global.active_challenges[key].objectives = challenge.objectives or self._global.active_challenges[key].objectives
				self._global.active_challenges[key].rewards = challenge.rewards or self._global.active_challenges[key].rewards
			end
		end

		if state.mission_values then
			self._global.mission_values = deep_clone(state.mission_values)
		end

		self._global.validated = false
	end
end

function ChallengeManager:_load_done()
	self._load_done = true

	self:fetch_challenges()
end

function ChallengeManager:mission_value(variable)
	return self._global.mission_values and self._global.mission_values[variable]
end

function ChallengeManager:mission_set_value(variable, activated)
	self._global.mission_values = self._global.mission_values or {}

	if variable and variable ~= "" then
		self._global.mission_values[variable] = activated or nil
	end
end

function ChallengeManager:check_equipped_outfit(equip_data, outfit, character)
	local pass_armor, pass_deployable, pass_mask, pass_melee_weapon, pass_primary, pass_secondary, pass_primaries, pass_secondaries, pass_primary_unmodded, pass_secondary_unmodded, pass_skills, pass_melee_weapons, pass_primary_category, pass_secondary_category, pass_masks, pass_armors, pass_characters, pass_detection, pass_perk_deck, pass_grenade, pass_single_deployable, pass_weapons = nil
	local ad = equip_data
	local num_skills = nil
	pass_deployable = not ad.deployable or ad.deployable == outfit.deployable
	pass_single_deployable = not ad.single_deployable or not outfit.secondary_deployable or outfit.secondary_deployable == "nil"
	pass_armor = not ad.armor or ad.armor == outfit.armor and ad.armor == outfit.armor_current
	pass_armors = not ad.armors or table.contains(ad.armors, outfit.armor) and table.contains(ad.armors, outfit.armor_current)
	pass_mask = not ad.mask or ad.mask == outfit.mask.mask_id
	pass_masks = not ad.masks or table.contains(ad.masks, outfit.mask.mask_id)
	pass_melee_weapon = not ad.melee_weapon or ad.melee_weapon == outfit.melee_weapon
	pass_melee_weapons = not ad.melee_weapons or table.contains(ad.melee_weapons, outfit.melee_weapon)
	pass_grenade = not ad.grenade or table.contains(ad.grenade, outfit.grenade)
	local primary_categories = tweak_data:get_raw_value("weapon", managers.weapon_factory:get_weapon_id_by_factory_id(outfit.primary.factory_id), "categories")
	local secondary_categories = tweak_data:get_raw_value("weapon", managers.weapon_factory:get_weapon_id_by_factory_id(outfit.secondary.factory_id), "categories")
	pass_primary = not ad.primary or ad.primary == outfit.primary.factory_id
	pass_primaries = not ad.primaries or table.contains(ad.primaries, outfit.primary.factory_id)
	pass_primary_unmodded = not ad.primary_unmodded or managers.weapon_factory:is_weapon_unmodded(outfit.primary.factory_id, outfit.primary.blueprint)
	pass_primary_category = not ad.primary_category or table.contains(primary_categories, ad.primary_category)
	pass_secondary = not ad.secondary or ad.secondary == outfit.secondary.factory_id
	pass_secondaries = not ad.secondaries or table.contains(ad.secondaries, outfit.secondary.factory_id)
	pass_secondary_unmodded = not ad.secondary_unmodded or managers.weapon_factory:is_weapon_unmodded(outfit.secondary.factory_id, outfit.secondary.blueprint)
	pass_secondary_category = not ad.secondary_category or table.contains(secondary_categories, ad.secondary_category)
	pass_weapons = not ad.weapons or table.contains(ad.weapons, outfit.primary.factory_id) or table.contains(ad.weapons, outfit.secondary.factory_id)
	pass_characters = not ad.characters or table.contains(ad.characters, character)
	pass_skills = not ad.num_skills
	pass_perk_deck = not ad.perk_deck or outfit.skills.specializations[1] == tostring(ad.perk_deck)

	if not pass_skills then
		num_skills = 0

		for tree, points in ipairs(outfit.skills.skills or {
			0
		}) do
			num_skills = num_skills + (tonumber(points) or 0)
		end

		pass_skills = num_skills <= ad.num_skills
	end

	if ad.reverse_deployable then
		pass_deployable = not pass_deployable
	end

	if ad.detection then
		local detection = managers.blackmarket:get_suspicion_offset_of_outfit_string(outfit, tweak_data.player.SUSPICION_OFFSET_LERP or 0.75)
		detection = math.round(detection * 100)
		pass_detection = ad.detection.min <= detection and detection <= ad.detection.max
	else
		pass_detection = true
	end

	return pass_armor and pass_armors and pass_deployable and pass_mask and pass_masks and pass_melee_weapon and pass_primary and pass_secondary and pass_primaries and pass_secondaries and pass_primary_unmodded and pass_secondary_unmodded and pass_skills and pass_melee_weapons and pass_characters and pass_primary_category and pass_secondary_category and pass_detection and pass_grenade and pass_perk_deck and pass_single_deployable and pass_weapons
end

function ChallengeManager:check_equipped_team(achievement_data)
	if achievement_data.equipped_team then
		local ad = achievement_data.equipped_team
		local num_skills = nil

		for _, peer in pairs(managers.network:session():all_peers()) do
			if not self:check_equipped_outfit(achievement_data.equipped_team, peer:blackmarket_outfit(), peer:character()) then
				return false
			end
		end
	end

	return true
end

function ChallengeManager:check_equipped(achievement_data)
	if achievement_data.equipped_outfit then
		local peer = managers.network:session():local_peer()

		return self:check_equipped_outfit(achievement_data.equipped_outfit, peer:blackmarket_outfit(), peer:character())
	end

	return true
end
