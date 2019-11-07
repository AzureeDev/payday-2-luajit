SkillTreeManager = SkillTreeManager or class()
SkillTreeManager.VERSION = 9

local function get_skill_costs()
	local t = {
		{
			1,
			3
		},
		{
			2,
			4
		},
		{
			3,
			6
		},
		{
			4,
			8
		}
	}

	return t
end

function SkillTreeManager:init()
	self:_setup()

	local skilltrees_tweak = tweak_data.skilltree.trees
	local pages = {}

	for tree, tree_data in ipairs(skilltrees_tweak) do
		pages[tree_data.skill] = pages[tree_data.skill] or {}

		table.insert(pages[tree_data.skill], tree)
	end

	self._pages = pages
end

function SkillTreeManager:skill_cost(tier, skill_level, skill_cost)
	local t = skill_cost or get_skill_costs()

	return t[tier][skill_level]
end

function SkillTreeManager:_setup(reset)
	if not Global.skilltree_manager or reset then
		Global.skilltree_manager = {
			VERSION = SkillTreeManager.VERSION,
			reset_message = false,
			times_respeced = 1
		}
		self._global = Global.skilltree_manager

		self:_setup_skill_switches()

		self._global.selected_skill_switch = 1
		local data = self._global.skill_switches[self._global.selected_skill_switch]
		self._global.points = data.points
		self._global.trees = data.trees
		self._global.skills = data.skills

		self:_setup_specialization()
	end

	self._global = Global.skilltree_manager
end

function SkillTreeManager:_setup_skill_switches()
	if not self._global.skill_switches then
		self._global.skill_switches = {}
		local switch_data = nil

		for i = 1, #tweak_data.skilltree.skill_switches, 1 do
			self._global.skill_switches[i] = {
				specialization = false,
				unlocked = i == 1,
				points = Application:digest_value(0, true)
			}
			switch_data = self._global.skill_switches[i]
			switch_data.trees = {}

			for tree, data in pairs(tweak_data.skilltree.trees) do
				switch_data.trees[tree] = {
					unlocked = true,
					points_spent = Application:digest_value(0, true)
				}
			end

			switch_data.skills = {}

			for skill_id, data in pairs(tweak_data.skilltree.skills) do
				switch_data.skills[skill_id] = {
					unlocked = 0,
					total = #data
				}
			end
		end
	else
		local switch_data = nil

		for i = 1, #tweak_data.skilltree.skill_switches, 1 do
			switch_data = self._global.skill_switches[i]
			switch_data.trees = {}

			for tree, data in pairs(tweak_data.skilltree.trees) do
				switch_data.trees[tree] = {
					unlocked = true,
					points_spent = Application:digest_value(0, true)
				}
			end

			switch_data.skills = {}

			for skill_id, data in pairs(tweak_data.skilltree.skills) do
				switch_data.skills[skill_id] = {
					unlocked = 0,
					total = #data
				}
			end
		end
	end
end

function SkillTreeManager:_setup_specialization()
	self._global.specializations = {
		points_present = self:digest_value(0, true),
		points = self:digest_value(0, true),
		total_points = self:digest_value(0, true),
		xp_present = self:digest_value(0, true),
		xp_leftover = self:digest_value(0, true),
		current_specialization = self:digest_value(1, true)
	}
	local max_specialization_points = 0

	for tree, data in ipairs(tweak_data.skilltree.specializations or {}) do
		self._global.specializations[tree] = {
			points_spent = self:digest_value(0, true),
			tiers = {
				current_tier = self:digest_value(0, true),
				max_tier = self:digest_value(#data, true),
				next_tier_data = {
					current_points = self:digest_value(0, true),
					points = self:digest_value(data[1].cost, true)
				}
			}
		}

		for _, tier in ipairs(data) do
			max_specialization_points = max_specialization_points + tier.cost
		end
	end

	self._global.specializations.max_points = self:digest_value(max_specialization_points, true)
end

function SkillTreeManager:all_skilltree_ids()
	local t = {}

	for tree, data in ipairs(tweak_data.skilltree.trees) do
		table.insert(t, data.skill)
	end

	return t
end

function SkillTreeManager:_create_tree_data(tree_id)
	self._global.trees[tree_id] = {
		unlocked = true,
		points_spent = Application:digest_value(0, true)
	}
end

function SkillTreeManager:get_skill_points(skill, index)
	local tier = tweak_data.skilltree:get_tier_position_from_skill_name(skill)
	local cost = tweak_data.skilltree.tier_cost[tier][index]
	local points = cost
	local total_points = cost

	return total_points, points
end

function SkillTreeManager:unlock_tree(tree)
	if self._global.trees[tree].unlocked then
		Application:error("Tree", tree, "allready unlocked")

		return
	end

	if not skill or not skill.cost then
		print("[SkillTreeManager:unlock_tree] skill tree: \"" .. tostring(skill_id) .. "\" is missing cost!")
	end

	self._global.trees[tree].unlocked = true
end

function SkillTreeManager:spend_points(points)
	local p = self:points() - points

	self:_set_points(p)
	MenuCallbackHandler:_update_outfit_information()

	return p
end

function SkillTreeManager:refund_points(points)
	local p = self:points() + points

	self:_set_points(p)
	MenuCallbackHandler:_update_outfit_information()

	return p
end

function SkillTreeManager:_spend_points(tree, tier, points, points_tier, skill_id)
	local pre_unlocked_tier = self:current_max_tier(tree)

	managers.money:on_skillpoint_spent(tree, tier, points)
	self:_set_points(self:points() - points)
	self:_set_points_spent(tree, self:points_spent(tree) + points_tier)

	local post_unlocked_tier = self:current_max_tier(tree)

	if not tier or pre_unlocked_tier < post_unlocked_tier then
		managers.menu_component:on_tier_unlocked(tree, tier)
	end

	self:_on_points_spent(tree, points)
end

function SkillTreeManager:points(switch_data)
	return Application:digest_value((switch_data or self._global).points, false)
end

function SkillTreeManager:_set_points(value)
	self._global.points = Application:digest_value(value, true)

	if self._global.skill_switches[self._global.selected_skill_switch] then
		self._global.skill_switches[self._global.selected_skill_switch].points = self._global.points
	end
end

function SkillTreeManager:points_spent(tree, switch_data)
	return Application:digest_value((switch_data or self._global).trees[tree].points_spent, false)
end

function SkillTreeManager:points_spent_in_skilltree(tree_name, switch_data)
	local points = 0

	for tree, data in pairs(tweak_data.skilltree.trees) do
		if data.skill == tree_name then
			points = points + self:points_spent(tree, switch_data)
		end
	end

	return points
end

function SkillTreeManager:total_points_spent(switch_data)
	local points = 0

	for tree, data in pairs(tweak_data.skilltree.trees) do
		points = points + self:points_spent(tree, switch_data)
	end

	return points
end

function SkillTreeManager:_set_points_spent(tree, value)
	self._global.trees[tree].points_spent = Application:digest_value(value, true)

	self:_check_achievements()
end

function SkillTreeManager:tier_cost(tree, tier)
	local points = Application:digest_value(tweak_data.skilltree.tier_unlocks[tier], false)

	if managers.experience:current_rank() > 0 then
		local tree_name = tweak_data.skilltree.trees[tree].skill

		for infamy, item in pairs(tweak_data.infamy.items) do
			if managers.infamy:owned(infamy) then
				local skilltree = item.upgrades and item.upgrades.skilltree

				if skilltree then
					local tree = skilltree.tree
					local trees = skilltree.trees

					if tree and tree == tree_name or trees and table.contains(trees, tree_name) then
						points = math.round(points * item.upgrades.skilltree.multiplier or 1)

						break
					end
				end
			end
		end
	end

	return points
end

function SkillTreeManager:current_max_tier(tree)
	for tier, point in ipairs(tweak_data.skilltree.tier_unlocks) do
		if self:points_spent(tree) < self:tier_cost(tree, tier) then
			return tier - 1
		end
	end

	return #tweak_data.skilltree.tier_unlocks
end

function SkillTreeManager:skill_completed(skill_id, switch_data)
	return (switch_data or self._global).skills[skill_id].unlocked == (switch_data or self._global).skills[skill_id].total
end

function SkillTreeManager:skill_step(skill_id)
	return self._global.skills[skill_id].unlocked
end

function SkillTreeManager:next_skill_step(skill_id, switch_data)
	return (switch_data or self._global).skills[skill_id].unlocked + 1
end

function SkillTreeManager:next_skill_step_data(skill_id)
	return tweak_data.skilltree.skills[skill_id][self._global.skills[skill_id].unlocked]
end

function SkillTreeManager:skill_unlocked(tree, skill_id, switch_data)
	if not tree then
		for tree_id, _ in pairs(tweak_data.skilltree.trees) do
			if self:skill_unlocked(tree_id, skill_id, switch_data) then
				return true
			end
		end

		return false
	end

	for tier, data in pairs(tweak_data.skilltree.trees[tree].tiers) do
		for _, skill in ipairs(data) do
			if skill == skill_id then
				return self:tier_unlocked(tree, tier, switch_data)
			end
		end
	end
end

function SkillTreeManager:_points_spent_skill(tier, skill_id)
	local points = 0
	local skill_costs = get_skill_costs()
	local skill_level = self._global.skills[skill_id].unlocked

	if skill_level and skill_level >= 1 then
		for j = skill_level, 1, -1 do
			points = points + self:skill_cost(tier, j, skill_costs)
		end
	end

	return points
end

function SkillTreeManager:skill_can_be_removed(tree, tier, skill_id)
	local skill_step = self:skill_step(skill_id)

	if skill_step == 0 then
		return false
	end

	local tiers = tweak_data.skilltree:get_tiers(tree)
	local points_to_remove = self:skill_cost(tier, skill_step)
	local points_left, points_spent_until_tier, tier_index, tier_data = nil

	if not points_to_remove then
		return false
	end

	if points_to_remove == 0 then
		return true
	end

	for tier_index = #tiers, 1, -1 do
		if tier < tier_index then
			points_spent_until_tier = self:get_points_spent_until_tier(tiers, tier_index - 1)
			points_left = points_spent_until_tier - points_to_remove
		else
			return true
		end

		tier_data = tiers[tier_index]

		for _, skill in pairs(tier_data) do
			local level = self._global.skills[skill].unlocked

			if level and level >= 1 and points_left < self:tier_cost(tree, tier_index) then
				return false
			end
		end
	end

	return true
end

function SkillTreeManager:unlock(skill_id)
	if self._global.skills[skill_id].total <= self._global.skills[skill_id].unlocked then
		Application:error("No more steps to unlock in skill", skill_id)

		return false
	end

	local talent = tweak_data.skilltree.skills[skill_id]
	local to_unlock = self:next_skill_step(skill_id)
	local skill = talent[to_unlock]
	self._global.skills[skill_id].unlocked = to_unlock
	local skill = tweak_data.skilltree.skills[skill_id][to_unlock]

	self:_aquire_skill(skill, skill_id, false)

	if SystemInfo:distribution() == Idstring("STEAM") then
		managers.statistics:publish_skills_to_steam()
	end

	return true
end

function SkillTreeManager:_get_heighst_tier_points(current_tier, tiers)
	local prev_next_tier = current_tier + 1
	local prev_num_unlocked_skills_above = self:get_num_unlocked_skills(tiers[prev_next_tier])
	local next_tier = prev_next_tier
	local num_unlocked_skills_above = prev_num_unlocked_skills_above

	while num_unlocked_skills_above > 0 and next_tier < #tiers do
		next_tier = next_tier + 1
		num_unlocked_skills_above = self:get_num_unlocked_skills(tiers[next_tier])

		if num_unlocked_skills_above == 0 then
			return prev_next_tier, prev_num_unlocked_skills_above
		end

		prev_next_tier = next_tier
		prev_num_unlocked_skills_above = num_unlocked_skills_above
	end

	return prev_next_tier, prev_num_unlocked_skills_above
end

function SkillTreeManager:does_tier_have_ace_skill(tier)
	local skills = self._global.skills

	for i = 1, #tier, 1 do
		local skill_level = skills[tier[i]].unlocked

		if skill_level and skill_level >= 2 then
			return true
		end
	end

	return false
end

function SkillTreeManager:get_num_ace_skills(tier)
	local skills = self._global.skills
	local num = 0

	for i = 1, #tier, 1 do
		local skill_level = skills[tier[i]].unlocked

		if skill_level and skill_level >= 2 then
			num = num + 1
		end
	end

	return num
end

function SkillTreeManager:get_num_unlocked_skills(tier)
	local skills = self._global.skills
	local num = 0

	for i = 1, #tier, 1 do
		local skill_level = skills[tier[i]].unlocked

		if skill_level and skill_level >= 1 then
			num = num + skill_level
		end
	end

	return num
end

function SkillTreeManager:get_points_spent_in_tier(tier, tier_idx)
	local skills = self._global.skills
	local skill_costs = get_skill_costs()
	local points = 0

	for i = 1, #tier, 1 do
		local skill_level = skills[tier[i]].unlocked

		if skill_level and skill_level >= 1 then
			for j = skill_level, 1, -1 do
				points = points + self:skill_cost(tier_idx, j, skill_costs)
			end
		end
	end

	return points
end

function SkillTreeManager:get_points_spent_until_tier(tiers, target_tier_idx)
	local skills = self._global.skills
	local skill_costs = get_skill_costs()
	local points = 0

	for i = 1, target_tier_idx, 1 do
		for j = 1, #tiers[i], 1 do
			local skill_level = skills[tiers[i][j]].unlocked

			if skill_level and skill_level >= 1 then
				for k = skill_level, 1, -1 do
					points = points + self:skill_cost(i, k, skill_costs)
				end
			end
		end
	end

	return points
end

function SkillTreeManager:has_enough_skill_points(skill_id)
	local talent = tweak_data.skilltree.skills[skill_id]
	local to_unlock = managers.skilltree:next_skill_step(skill_id)
	local skill = talent[to_unlock]
	local total_points, points = self:get_skill_points(skill_id, to_unlock)

	if total_points <= self:points() then
		return true
	end

	return false
end

function SkillTreeManager:refund_skill(tree, tier, skill_id)
	if not self:skill_can_be_removed(tree, tier, skill_id) then
		return
	end

	local skills = self._global.skills
	local skill = skills[skill_id]

	if skill and skill.unlocked > 0 and self:unaquire_one_skill_level(skill_id) then
		skill.unlocked = skill.unlocked - 1

		return true
	end

	return false
end

function SkillTreeManager:_on_skill_unlocked(tree, skill_id)
end

function SkillTreeManager:_on_points_spent(tree, points)
	self:_check_achievements()
	managers.menu_component:on_points_spent(tree, points)
	MenuCallbackHandler:_update_outfit_information()
end

function SkillTreeManager:_check_achievements()
	if tweak_data.story.sm_2_skillpoints <= self:total_points_spent() then
		managers.story:award("story_inv_skillpoints")
	end

	if self:current_specialization_tier() > 0 then
		managers.story:award("story_inv_perkdeck")
	end

	for tree, data in pairs(tweak_data.skilltree.skilltree) do
		if self:points_spent_in_skilltree(tree) < tweak_data.achievement.im_a_healer_tank_damage_dealer then
			return
		end
	end

	managers.achievment:award("im_a_healer_tank_damage_dealer")
end

function SkillTreeManager:level_up()
	self:_aquire_points(1)
end

function SkillTreeManager:rep_upgrade(upgrade, id)
	self:_aquire_points(upgrade and upgrade.value or 2)
end

function SkillTreeManager:_aquire_points(points, selected_only)
	if selected_only then
		self._global.points = Application:digest_value(self:points() + points, true)

		if self._global.skill_switches[self._global.selected_skill_switch] then
			self._global.skill_switches[self._global.selected_skill_switch].points = self._global.points
		end
	else
		for skill_switch, data in ipairs(self._global.skill_switches) do
			data.points = Application:digest_value(self:points(data) + points, true)
		end

		if self._global.skill_switches[self._global.selected_skill_switch] then
			self._global.points = self._global.skill_switches[self._global.selected_skill_switch].points
		end
	end
end

function SkillTreeManager:tier_unlocked(tree, tier, switch_data)
	if not self:tree_unlocked(tree, switch_data) then
		return false
	end

	local required_points = managers.skilltree:tier_cost(tree, tier)

	return required_points <= self:points_spent(tree, switch_data)
end

function SkillTreeManager:tree_unlocked(tree, switch_data)
	return (switch_data or self._global).trees[tree].unlocked
end

function SkillTreeManager:trees_unlocked(switch_trees)
	local amount = 0

	for _, tree in pairs(switch_trees or self._global.trees) do
		if tree.unlocked then
			amount = amount + 1
		end
	end

	return amount
end

function SkillTreeManager:_aquire_skill(skill, skill_id, loading)
	local upgrade_manager = managers.upgrades

	if skill and skill.upgrades then
		for _, upgrade in ipairs(skill.upgrades) do
			upgrade_manager:aquire(upgrade, loading, UpgradesManager.AQUIRE_STRINGS[2] .. "_" .. tostring(skill_id))
		end

		return true
	end

	return false
end

function SkillTreeManager:unaquire_one_skill_level(skill_id)
	local skills = self._global.skills
	local skill = skills[skill_id]
	local skill_data = tweak_data.skilltree.skills[skill_id]

	if skill_data and skill and skill.unlocked > 0 then
		local upgrades = skill_data[skill.unlocked].upgrades
		local upgrade_manager = managers.upgrades

		for i = #upgrades, 1, -1 do
			local upgrade = upgrades[i]

			upgrade_manager:unaquire(upgrade, UpgradesManager.AQUIRE_STRINGS[2] .. "_" .. tostring(skill_id))
		end

		return true
	end

	return false
end

function SkillTreeManager:_unaquire_skill(skill_id)
	local progress_data = self._global.skills[skill_id]
	local skill_data = tweak_data.skilltree.skills[skill_id]

	for i = progress_data.unlocked, 1, -1 do
		local step_data = skill_data[i]
		local upgrades = step_data.upgrades

		if upgrades then
			for i = #upgrades, 1, -1 do
				local upgrade = upgrades[i]

				managers.upgrades:unaquire(upgrade, UpgradesManager.AQUIRE_STRINGS[2] .. "_" .. tostring(skill_id))
			end
		end
	end

	progress_data.unlocked = 0
end

function SkillTreeManager:on_respec_tree(tree, forced_respec_multiplier)
	if SkillTreeManager.VERSION < 5 then
		self:_respec_tree_version4(tree, forced_respec_multiplier)
	elseif SkillTreeManager.VERSION == 5 then
		self:_respec_tree_version5(tree, forced_respec_multiplier)
	else
		self:_respec_tree_version6(tree, forced_respec_multiplier)
	end

	MenuCallbackHandler:_update_outfit_information()

	if SystemInfo:distribution() == Idstring("STEAM") then
		managers.statistics:publish_skills_to_steam()
	end
end

function SkillTreeManager:_respec_tree_version7(tree, forced_respec_multiplier)
	local points_spent = self:points_spent(tree)
	local unlocked = self:trees_unlocked()

	if unlocked > 0 then
		points_spent = points_spent + Application:digest_value(tweak_data.skilltree.unlock_tree_cost[unlocked], false)
	end

	self:_reset_skilltree7(tree, forced_respec_multiplier)
	self:_aquire_points(points_spent, true)
end

function SkillTreeManager:_respec_tree_version5(tree, forced_respec_multiplier)
	local points_spent = self:points_spent(tree)
	local unlocked = self:trees_unlocked()

	if unlocked > 0 then
		points_spent = points_spent + Application:digest_value(tweak_data.skilltree.unlock_tree_cost[unlocked], false)
	end

	self:_reset_skilltree(tree, forced_respec_multiplier)
	self:_aquire_points(points_spent, true)
end

function SkillTreeManager:_respec_tree_version6(tree, forced_respec_multiplier)
	local points_spent = self:points_spent(tree)

	self:_reset_skilltree(tree, forced_respec_multiplier)
	self:_aquire_points(points_spent, true)
end

function SkillTreeManager:_respec_tree_version4(tree, forced_respec_multiplier)
	local points_spent = self:points_spent(tree)

	self:_reset_skilltree(tree, forced_respec_multiplier)
	self:_aquire_points(points_spent, true)
end

function SkillTreeManager:_reset_skilltree(tree, forced_respec_multiplier)
	self:_set_points_spent(tree, 0)

	local tree_data = tweak_data.skilltree.trees[tree]

	for i = #tree_data.tiers, 1, -1 do
		local tier = tree_data.tiers[i]

		for _, skill in ipairs(tier) do
			self:_unaquire_skill(skill)
		end
	end
end

function SkillTreeManager:_reset_skilltree7(tree, forced_respec_multiplier)
	self:_set_points_spent(tree, 0)

	self._global.trees[tree].unlocked = false
	local tree_data = tweak_data.skilltree.trees[tree]

	for i = #tree_data.tiers, 1, -1 do
		local tier = tree_data.tiers[i]

		for _, skill in ipairs(tier) do
			self:_unaquire_skill(skill)
		end
	end

	self:_unaquire_skill(tree_data.skill)
end

function SkillTreeManager:can_unlock_skill_switch(selected_skill_switch)
	if not self._global.skill_switches[selected_skill_switch] then
		return false, {
			"error"
		}
	end

	if self._global.skill_switches[selected_skill_switch].unlocked then
		return false, {
			"unlocked"
		}
	end

	local skill_switch_data = tweak_data.skilltree.skill_switches[selected_skill_switch]

	if not skill_switch_data then
		return false, {
			"error"
		}
	end

	local locks = skill_switch_data.locks

	if locks then
		local player_level = managers.experience:current_level()
		local money = managers.money:total()
		local offshore_money = managers.money:offshore()
		local fail_reasons = {}

		if not managers.money:can_afford_unlock_skill_switch(selected_skill_switch) then
			table.insert(fail_reasons, "money")
		end

		if locks.level and player_level < locks.level then
			table.insert(fail_reasons, "level")
		end

		if locks.achievement and not (managers.achievment:get_info(locks.achievement) or {}).awarded then
			table.insert(fail_reasons, "achievement")
		end

		if #fail_reasons ~= 0 then
			return false, fail_reasons
		end
	end

	return true, {
		"success"
	}
end

function SkillTreeManager:on_skill_switch_unlocked(selected_skill_switch)
	local can_unlock, reason = self:can_unlock_skill_switch(selected_skill_switch)

	if not can_unlock then
		print("[SkillTreeManager:on_skill_switch_unlocked] Cannot unlock skill switch", "selected_skill_switch", selected_skill_switch, "reason", reason)

		return
	end

	managers.money:on_unlock_skill_switch(selected_skill_switch)

	self._global.skill_switches[selected_skill_switch].unlocked = true
	self._global.skill_switches[selected_skill_switch].specialization = self._global.specializations.current_specialization
end

function SkillTreeManager:get_selected_skill_switch()
	return self._global.selected_skill_switch
end

function SkillTreeManager:has_skill_switch_name(skill_switch)
	local data = self._global.skill_switches[skill_switch]

	return data and data.name and true or false
end

function SkillTreeManager:get_skill_switch_name(skill_switch, add_quotation)
	local data = self._global.skill_switches[skill_switch]
	local name = data and data.name

	if name and name ~= "" then
		if add_quotation then
			return "\"" .. name .. "\""
		end

		return name
	end

	return self:get_default_skill_switch_name(skill_switch)
end

function SkillTreeManager:get_default_skill_switch_name(skill_switch)
	return managers.localization:text(tweak_data.skilltree.skill_switches[skill_switch] and tweak_data.skilltree.skill_switches[skill_switch].name_id or tostring(skill_switch))
end

function SkillTreeManager:set_skill_switch_name(skill_switch, name)
	if not self._global.skill_switches[skill_switch] then
		return
	end

	if not name or name == "" then
		self._global.skill_switches[skill_switch].name = nil
	else
		self._global.skill_switches[skill_switch].name = name
	end
end

function SkillTreeManager:switch_skills(selected_skill_switch)
	if selected_skill_switch == self._global.selected_skill_switch then
		return
	end

	if not self._global.skill_switches[selected_skill_switch] then
		return
	end

	if not self._global.skill_switches[selected_skill_switch].unlocked then
		return
	end

	local function unaquire_skill(skill_id)
		local progress_data = self._global.skills[skill_id]
		local skill_data = tweak_data.skilltree.skills[skill_id]

		for i = progress_data.unlocked, 1, -1 do
			local step_data = skill_data[i]
			local upgrades = step_data.upgrades

			if upgrades then
				for i = #upgrades, 1, -1 do
					local upgrade = upgrades[i]

					managers.upgrades:unaquire(upgrade, UpgradesManager.AQUIRE_STRINGS[2] .. "_" .. tostring(skill_id))
				end
			end
		end
	end

	for tree, data in pairs(tweak_data.skilltree.trees) do
		local tree_data = tweak_data.skilltree.trees[tree]

		for i = #tree_data.tiers, 1, -1 do
			local tier = tree_data.tiers[i]

			for _, skill in ipairs(tier) do
				unaquire_skill(skill)
			end
		end
	end

	self._global.selected_skill_switch = selected_skill_switch
	local data = self._global.skill_switches[self._global.selected_skill_switch]
	self._global.points = data.points
	self._global.trees = data.trees
	self._global.skills = data.skills

	for tree_id, tree_data in pairs(self._global.trees) do
		if tree_data.unlocked and not tweak_data.skilltree.trees[tree_id].dlc then
			for tier, skills in pairs(tweak_data.skilltree.trees[tree_id].tiers) do
				for _, skill_id in ipairs(skills) do
					local skill = tweak_data.skilltree.skills[skill_id]
					local skill_data = self._global.skills[skill_id]

					for i = 1, skill_data.unlocked, 1 do
						self:_aquire_skill(skill[i], skill_id, true)
					end
				end
			end
		end
	end

	self:set_current_specialization(self:digest_value(data.specialization, false), 1)
	MenuCallbackHandler:_update_outfit_information()

	return true
end

function SkillTreeManager:get_pages()
	return self._pages
end

function SkillTreeManager:analyze_page(page)
	local data = {
		aced = 0,
		owned = 0,
		points = 0
	}
	local spent = nil

	for _, tree in ipairs(self._pages[page]) do
		for tier, tier_data in ipairs(tweak_data.skilltree.trees[tree].tiers) do
			data.aced = data.aced + self:get_num_ace_skills(tier_data)

			for _, skill_id in ipairs(tier_data) do
				data.points = data.points + self:_points_spent_skill(tier, skill_id)
				data.owned = data.owned + (self:next_skill_step(skill_id) > 1 and 1 or 0)
			end
		end
	end

	return data
end

function SkillTreeManager:analyze()
end

function SkillTreeManager:tree_stats()
end

function SkillTreeManager:switch_skills_to_next()
	local selected_skill_switch = self._global.selected_skill_switch
	local max_switches = #self._global.skill_switches
	local switch_data = nil

	for skill_switch = selected_skill_switch + 1, max_switches, 1 do
		switch_data = self._global.skill_switches[selected_skill_switch]

		if switch_data and switch_data.unlocked then
			return self:switch_skills(skill_switch)
		end
	end

	for skill_switch = 1, selected_skill_switch - 1, 1 do
		switch_data = self._global.skill_switches[selected_skill_switch]

		if switch_data and switch_data.unlocked then
			return self:switch_skills(skill_switch)
		end
	end
end

function SkillTreeManager:switch_skills_to_previous()
	local selected_skill_switch = self._global.selected_skill_switch
	local max_switches = #self._global.skill_switches
	local switch_data = nil

	for skill_switch = selected_skill_switch - 1, 1, -1 do
		switch_data = self._global.skill_switches[selected_skill_switch]

		if switch_data and switch_data.unlocked then
			return self:switch_skills(skill_switch)
		end
	end

	for skill_switch = max_switches, selected_skill_switch + 1, -1 do
		switch_data = self._global.skill_switches[selected_skill_switch]

		if switch_data and switch_data.unlocked then
			return self:switch_skills(skill_switch)
		end
	end
end

function SkillTreeManager:next_specialization()
	local current_specialization = managers.skilltree:get_specialization_value("current_specialization")
	local max_specializations = #tweak_data.skilltree.specializations
	local specialization_data = nil

	for tree = current_specialization + 1, max_specializations, 1 do
		specialization_data = tweak_data.skilltree.specializations[tree]

		if specialization_data and (not specialization_data.dlc or managers.dlc:is_dlc_unlocked(specialization_data.dlc)) then
			return self:set_current_specialization(tree)
		end
	end

	for tree = 1, current_specialization - 1, 1 do
		specialization_data = tweak_data.skilltree.specializations[tree]

		if specialization_data and (not specialization_data.dlc or managers.dlc:is_dlc_unlocked(specialization_data.dlc)) then
			return self:set_current_specialization(tree)
		end
	end
end

function SkillTreeManager:previous_specialization()
	local current_specialization = managers.skilltree:get_specialization_value("current_specialization")
	local max_specializations = #tweak_data.skilltree.specializations
	local specialization_data = nil

	for tree = current_specialization - 1, 1, -1 do
		specialization_data = tweak_data.skilltree.specializations[tree]

		if specialization_data and (not specialization_data.dlc or managers.dlc:is_dlc_unlocked(specialization_data.dlc)) then
			return self:set_current_specialization(tree)
		end
	end

	for tree = max_specializations, current_specialization + 1, -1 do
		specialization_data = tweak_data.skilltree.specializations[tree]

		if specialization_data and (not specialization_data.dlc or managers.dlc:is_dlc_unlocked(specialization_data.dlc)) then
			return self:set_current_specialization(tree)
		end
	end
end

function SkillTreeManager:increase_times_respeced(increase)
	self._global.times_respeced = math.clamp(self._global.times_respeced + increase, 1, #tweak_data.money_manager.skilltree.respec.profile_cost_increaser_multiplier)
end

function SkillTreeManager:get_times_respeced()
	return self._global.times_respeced
end

function SkillTreeManager:version_reset_skilltrees(points_aquired_during_load)
	self:reset_skilltrees()
	self:_verify_loaded_data(points_aquired_during_load)

	self._global.VERSION = SkillTreeManager.VERSION
	self._global.reset_message = true
	self._global.times_respeced = 1

	if SystemInfo:distribution() == Idstring("STEAM") then
		managers.statistics:publish_skills_to_steam()
	end
end

function SkillTreeManager:reset_specializations()
	local current_specialization = self:digest_value(self._global.specializations.current_specialization, false, 1)
	local tree_data = self._global.specializations[current_specialization]

	if tree_data then
		local tier_data = tree_data.tiers

		if tier_data then
			local current_tier = self:digest_value(tier_data.current_tier, false)
			local specialization_tweak = tweak_data.skilltree.specializations[current_specialization]

			for i = 1, current_tier, 1 do
				for _, upgrade in ipairs(specialization_tweak[i].upgrades) do
					managers.upgrades:unaquire(upgrade, UpgradesManager.AQUIRE_STRINGS[3] .. tostring(current_specialization))
				end
			end
		end
	end

	local max_points = self:digest_value(self._global.specializations.max_points, false)
	local total_points = self:digest_value(self._global.specializations.total_points, false)
	local points_to_retain = math.min(max_points, total_points)

	self:_setup_specialization()

	self._global.specializations.total_points = self:digest_value(points_to_retain, true)
	self._global.specializations.points = self:digest_value(points_to_retain, true)
end

function SkillTreeManager:reset_skilltrees()
	if self._global.VERSION < 5 then
		for tree_id, tree_data in pairs(self._global.trees) do
			self:_respec_tree_version4(tree_id, 1)
		end
	elseif self._global.VERSION == 5 then
		for tree_id, tree_data in pairs(self._global.trees) do
			self:_respec_tree_version5(tree_id, 1)
		end
	else
		for tree_id, tree_data in pairs(self._global.trees) do
			self:_respec_tree_version6(tree_id, 1)
		end
	end

	self:_setup_skill_switches()

	self._global.selected_skill_switch = 1
	local data = self._global.skill_switches[self._global.selected_skill_switch]
	self._global.points = data.points
	self._global.trees = data.trees
	self._global.skills = data.skills

	MenuCallbackHandler:_update_outfit_information()
end

function SkillTreeManager:infamy_reset()
	local skill_switches_unlocks, skill_switches_specializations = nil

	if self._global.skill_switches then
		skill_switches_unlocks = {}
		skill_switches_specializations = {}

		for i, data in ipairs(self._global.skill_switches) do
			skill_switches_unlocks[i] = data.unlocked
			skill_switches_specializations[i] = data.specialization
		end
	end

	local saved_specialization = self._global.specializations
	local saved_selected_skill_switch = self._global.selected_skill_switch
	Global.skilltree_manager = nil

	self:_setup()

	self._global.specializations = saved_specialization

	if self._global.skill_switches then
		for i = 1, #self._global.skill_switches, 1 do
			self._global.skill_switches[i].unlocked = skill_switches_unlocks[i]
			self._global.skill_switches[i].specialization = skill_switches_specializations[i] or 1
		end
	end

	self:switch_skills(saved_selected_skill_switch)

	local current_specialization = self:digest_value(self._global.specializations.current_specialization, false, 1)
	local tree_data = self._global.specializations[current_specialization]

	if not tree_data then
		return
	end

	local tier_data = tree_data.tiers

	if not tier_data then
		return
	end

	local current_tier = self:digest_value(tier_data.current_tier, false)
	local specialization_tweak = tweak_data.skilltree.specializations[current_specialization]

	for i = 1, current_tier, 1 do
		for _, upgrade in ipairs(specialization_tweak[i].upgrades) do
			managers.upgrades:aquire(upgrade, false, UpgradesManager.AQUIRE_STRINGS[3] .. tostring(current_specialization))
		end
	end

	if SystemInfo:distribution() == Idstring("STEAM") then
		managers.statistics:publish_skills_to_steam()
	end
end

function SkillTreeManager:check_reset_message()
	local show_reset_message = self._global.reset_message and true or false

	if show_reset_message then
		managers.menu:show_skilltree_reseted()

		self._global.reset_message = false

		MenuCallbackHandler:save_progress()
	end
end

function SkillTreeManager:get_tree_progress_2(tree_name)
	local switch_data = self._global.skill_switches[self:get_selected_skill_switch()]
	local num_skills = 0
	local skill_points = 0
	local tree = tweak_data.skilltree:get_tree(tree_name)

	for i = 1, #tree, 1 do
		for j = 1, #tree[i].tiers, 1 do
			for k = 1, #tree[i].tiers[j], 1 do
				skill_points = skill_points + self:_points_spent_skill(j, tree[i].tiers[j][k])
			end
		end
	end

	return skill_points, skill_points
end

function SkillTreeManager:get_tree_progress_new(tree, switch_data)
	if type(tree) ~= "number" then
		local string_to_number = {
			hoxton = 5,
			enforcer = 2,
			technician = 3,
			mastermind = 1,
			ghost = 4
		}
		tree = string_to_number[tree]
	end

	local td = tweak_data.skilltree.trees[tree]
	local step, unlocked, completed = nil
	local owned = 0
	local aced = 0

	if owned > 0 then
		for _, tier in ipairs(td.tiers) do
			for _, skill_id in ipairs(tier) do
				step = managers.skilltree:next_skill_step(skill_id, switch_data)
				unlocked = managers.skilltree:skill_unlocked(nil, skill_id, switch_data)
				completed = managers.skilltree:skill_completed(skill_id, switch_data)
				aced = aced + (completed and 1 or 0)
				owned = owned + (step > 1 and 1 or 0)
			end
		end
	end

	return self:points_spent(tree, switch_data), owned, aced
end

function SkillTreeManager:get_page_progress_new(page)
	local points = 0

	for tree, data in pairs(tweak_data.skilltree.trees) do
		if data.skill == page then
			points = points + self:get_tree_progress_new(tree)
		end
	end

	return points
end

function SkillTreeManager:get_tree_progress(tree, switch_data)
	if type(tree) ~= "number" then
		local string_to_number = {
			hoxton = 5,
			enforcer = 2,
			technician = 3,
			mastermind = 1,
			ghost = 4
		}
		tree = string_to_number[tree]
	end

	local td = tweak_data.skilltree.trees[tree]
	local step, unlocked, completed = nil
	local progress = 0
	local num_skills = 0

	if progress > 0 then
		for _, tier in ipairs(td.tiers) do
			for _, skill_id in ipairs(tier) do
				step = managers.skilltree:next_skill_step(skill_id, switch_data)
				unlocked = managers.skilltree:skill_unlocked(nil, skill_id, switch_data)
				completed = managers.skilltree:skill_completed(skill_id, switch_data)
				num_skills = num_skills + 2
				progress = progress + (step > 1 and 1 or 0) + (completed and 1 or 0)
			end
		end
	end

	return progress, num_skills
end

function SkillTreeManager:get_most_progressed_tree()
	local max_tree = 1
	local max_points = 0

	for tree, _ in ipairs(tweak_data.skilltree.trees) do
		local points, num_skills = self:get_tree_progress(tree)

		if max_points < points then
			max_tree = tree
			max_points = points
		end
	end

	return max_tree
end

function SkillTreeManager:pack_to_string()
	local packed_string = ""

	for tree, data in ipairs(tweak_data.skilltree.trees) do
		local points, num_skills = managers.skilltree:get_tree_progress_new(tree)
		packed_string = packed_string .. tostring(points)

		if tree ~= #tweak_data.skilltree.trees then
			packed_string = packed_string .. "_"
		end
	end

	local current_specialization = self:digest_value(self._global.specializations.current_specialization, false, 1)
	local tree_data = self._global.specializations[current_specialization]

	if tree_data then
		local tier_data = tree_data.tiers

		if tier_data then
			local current_tier = self:digest_value(tier_data.current_tier, false)
			packed_string = packed_string .. "-" .. tostring(current_specialization) .. "_" .. tostring(current_tier)
		end
	end

	return packed_string
end

function SkillTreeManager:pack_to_string_from_list(list)
	local packed_string = ""

	for tree, data in pairs(list.skills) do
		packed_string = packed_string .. tostring(data)

		if tree ~= #tweak_data.skilltree.trees then
			packed_string = packed_string .. "_"
		end
	end

	if table.size(list.specializations) == 2 then
		packed_string = packed_string .. "-" .. tostring(list.specializations[1]) .. "_" .. tostring(list.specializations[2])
	end

	return packed_string
end

function SkillTreeManager:unpack_from_string(packed_string)
	local t = string.split(packed_string or "", "-") or {}

	return {
		skills = string.split(tostring(t[1] or ""), "_"),
		specializations = string.split(tostring(t[2] or ""), "_")
	}
end

function SkillTreeManager:save(data)
	local state = {
		points = self._global.points,
		trees = self._global.trees,
		skills = self._global.skills,
		skill_switches = self._global.skill_switches,
		selected_skill_switch = self._global.selected_skill_switch,
		specializations = self._global.specializations,
		VERSION = self._global.VERSION or 0,
		reset_message = self._global.reset_message,
		times_respeced = self._global.times_respeced or 1
	}
	data.SkillTreeManager = state
end

function SkillTreeManager:load(data, version)
	local state = data.SkillTreeManager
	local points_aquired_during_load = self:points()

	if state then
		if state.specializations then
			self._global.specializations.total_points = state.specializations.total_points or self._global.specializations.total_points
			self._global.specializations.points = state.specializations.points or self._global.specializations.points
			self._global.specializations.points_present = state.specializations.points_present or self._global.specializations.points_present
			self._global.specializations.xp_present = state.specializations.xp_present or self._global.specializations.xp_present
			self._global.specializations.xp_leftover = state.specializations.xp_leftover or self._global.specializations.xp_leftover
			self._global.specializations.current_specialization = state.specializations.current_specialization or self._global.specializations.current_specialization

			for tree, data in ipairs(state.specializations) do
				if self._global.specializations[tree] then
					self._global.specializations[tree].points_spent = data.points_spent or self._global.specializations[tree].points_spent
				end
			end
		end

		if state.skill_switches then
			self._global.selected_skill_switch = state.selected_skill_switch or 1

			for i, data in pairs(state.skill_switches) do
				if self._global.skill_switches[i] then
					self._global.skill_switches[i].unlocked = data.unlocked
					self._global.skill_switches[i].name = data.name or self._global.skill_switches[i].name
					self._global.skill_switches[i].points = data.points or self._global.skill_switches[i].points
					self._global.skill_switches[i].specialization = data.unlocked and (data.specialization or self._global.specializations.current_specialization) or false

					for tree_id, tree_data in pairs(data.trees) do
						self._global.skill_switches[i].trees[tree_id] = tree_data
					end

					for skill_id, skill_data in pairs(data.skills) do
						if self._global.skill_switches[i].skills[skill_id] then
							self._global.skill_switches[i].skills[skill_id].unlocked = skill_data.unlocked
						end
					end
				end
			end
		else
			self._global.selected_skill_switch = 1
			self._global.skill_switches[1].points = state.points
			self._global.skill_switches[1].specialization = data.unlocked and self._global.specializations.current_specialization or false

			for tree_id, tree_data in pairs(state.trees) do
				self._global.skill_switches[1].trees[tree_id] = tree_data
			end

			for skill_id, skill_data in pairs(state.skills) do
				if self._global.skill_switches[1].skills[skill_id] then
					self._global.skill_switches[1].skills[skill_id].unlocked = skill_data.unlocked
				end
			end
		end

		self:_verify_loaded_data(points_aquired_during_load)

		self._global.VERSION = state.VERSION
		self._global.reset_message = state.reset_message
		self._global.times_respeced = state.times_respeced

		if not self._global.VERSION or self._global.VERSION ~= SkillTreeManager.VERSION then
			managers.savefile:add_load_done_callback(callback(self, self, "version_reset_skilltrees", points_aquired_during_load))
		end
	end
end

function SkillTreeManager:_verify_loaded_data(points_aquired_during_load)
	local level_points = managers.experience:current_level()
	local assumed_points = level_points + points_aquired_during_load

	for i, switch_data in ipairs(self._global.skill_switches) do
		local points = assumed_points

		for skill_id, data in pairs(clone(switch_data.skills)) do
			if not tweak_data.skilltree.skills[skill_id] then
				print("[SkillTreeManager:_verify_loaded_data] Skill doesn't exists", skill_id, ", removing loaded data.", "skill_switch", i)

				switch_data.skills[skill_id] = nil
			end
		end

		for tree_id, data in pairs(clone(switch_data.trees)) do
			if not tweak_data.skilltree.trees[tree_id] then
				print("[SkillTreeManager:_verify_loaded_data] Tree doesn't exists", tree_id, ", removing loaded data.", "skill switch", i)

				switch_data.trees[tree_id] = nil
			end
		end

		for tree_id, data in pairs(clone(switch_data.trees)) do
			local points_spent = math.max(Application:digest_value(data.points_spent, false), 0)
			data.points_spent = Application:digest_value(points_spent, true)
			points = points - points_spent
		end

		local unlocked = self:trees_unlocked(switch_data.trees)

		while unlocked > 0 do
			unlocked = unlocked - 1
		end

		switch_data.points = Application:digest_value(points, true)
	end

	for i = 1, #self._global.skill_switches, 1 do
		if self._global.skill_switches[i] and Application:digest_value(self._global.skill_switches[i].points or 0, false) < 0 then
			local switch_data = self._global.skill_switches[i]
			switch_data.points = Application:digest_value(assumed_points, true)
			switch_data.trees = {}

			for tree, data in pairs(tweak_data.skilltree.trees) do
				switch_data.trees[tree] = {
					unlocked = true,
					points_spent = Application:digest_value(0, true)
				}
			end

			switch_data.skills = {}

			for skill_id, data in pairs(tweak_data.skilltree.skills) do
				switch_data.skills[skill_id] = {
					unlocked = 0,
					total = #data
				}
			end
		end
	end

	if not self._global.skill_switches[self._global.selected_skill_switch] then
		self._global.selected_skill_switch = 1
	end

	local data = self._global.skill_switches[self._global.selected_skill_switch]
	self._global.points = data.points
	self._global.trees = data.trees
	self._global.skills = data.skills

	for tree_id, tree_data in pairs(self._global.trees) do
		if tree_data.unlocked and not tweak_data.skilltree.trees[tree_id].dlc then
			for tier, skills in pairs(tweak_data.skilltree.trees[tree_id].tiers) do
				for _, skill_id in ipairs(skills) do
					local skill = tweak_data.skilltree.skills[skill_id]
					local skill_data = self._global.skills[skill_id]

					for i = 1, skill_data.unlocked, 1 do
						self:_aquire_skill(skill[i], skill_id, true)
					end
				end
			end
		end
	end

	local specialization_tweak = tweak_data.skilltree.specializations
	local points, points_left, data = nil
	local total_points_spent = 0
	local current_specialization = self:digest_value(self._global.specializations.current_specialization, false, 1)
	local spec_data = specialization_tweak[current_specialization]

	if not spec_data or spec_data.dlc and not managers.dlc:is_dlc_unlocked(spec_data.dlc) then
		local old_specialization = self._global.specializations.current_specialization
		current_specialization = 1
		self._global.specializations.current_specialization = self:digest_value(current_specialization, true, 1)

		for i, switch_data in ipairs(self._global.skill_switches) do
			if switch_data.specialization == old_specialization then
				switch_data.specialization = self._global.specializations.current_specialization
			end
		end
	end

	for tree, data in ipairs(self._global.specializations) do
		if specialization_tweak[tree] then
			points = self:digest_value(data.points_spent, false)
			points_left = points

			for tier, spec_data in ipairs(specialization_tweak[tree]) do
				if spec_data.cost <= points_left then
					points_left = points_left - spec_data.cost

					if tree == current_specialization then
						for _, upgrade in ipairs(spec_data.upgrades) do
							managers.upgrades:aquire(upgrade, true, UpgradesManager.AQUIRE_STRINGS[3] .. tostring(current_specialization))
						end
					end

					if tier == #specialization_tweak[tree] then
						data.tiers.current_tier = self:digest_value(tier, true)
						data.tiers.max_tier = self:digest_value(#specialization_tweak[tree], true)
						data.tiers.next_tier_data = false
					end
				else
					data.tiers.current_tier = self:digest_value(tier - 1, true)
					data.tiers.max_tier = self:digest_value(#specialization_tweak[tree], true)
					data.tiers.next_tier_data = {
						current_points = self:digest_value(points_left, true),
						points = self:digest_value(spec_data.cost, true)
					}
					points_left = 0

					break
				end
			end

			data.points_spent = self:digest_value(points - points_left, true)
			total_points_spent = total_points_spent + points - points_left
		end
	end

	total_points_spent = total_points_spent + self:digest_value(self._global.specializations.points, false)

	if self:digest_value(self._global.specializations.total_points, false) ~= total_points_spent then
		Application:error("[SkillTreeManager] Specialization points do not match up, reseting everything!!!")
		self:reset_specializations()
	else
		local max_points = self:digest_value(self._global.specializations.max_points, false)
		local points = self:digest_value(self._global.specializations.points, false)

		if max_points < total_points_spent or max_points < points then
			self._global.specializations.total_points = self:digest_value(max_points, true)
			self._global.specializations.points = self:digest_value(math.max(total_points_spent - max_points, 0), true)
			self._global.specializations.points_present = self:digest_value(0, true)
			self._global.specializations.xp_present = self:digest_value(0, true)
			self._global.specializations.xp_leftover = self:digest_value(0, true)
		end
	end
end

function SkillTreeManager:digest_value(value, digest, default)
	if value == nil then
		return default or 0
	end

	if type(value) == "boolean" then
		return default or 0
	end

	if digest then
		if type(value) == "string" then
			return value
		else
			return Application:digest_value(value, true)
		end
	elseif type(value) == "number" then
		return value
	else
		return Application:digest_value(value, false)
	end

	return Application:digest_value(value, digest)
end

function SkillTreeManager:get_specialization_value(...)
	local value = self._global.specializations

	for _, index in ipairs({
		...
	}) do
		value = value[index]
	end

	if type(value) == "table" then
		return value
	end

	return self:digest_value(value, false) or 0
end

function SkillTreeManager:current_specialization_tier()
	local idx = self:digest_value(self._global.specializations.current_specialization, false)
	local current = idx and self._global.specializations[idx]

	if not current or not current.tiers then
		return 0
	end

	return self:digest_value(current.tiers.current_tier)
end

function SkillTreeManager:specialization_points()
	return self._global.specializations.points and self:digest_value(self._global.specializations.points, false) or 0
end

function SkillTreeManager:debug_specialization()
	for i, d in pairs(self._global.specializations) do
		if type(d) == "string" then
			print(i, self:digest_value(d, false))
		end
	end
end

function SkillTreeManager:get_specialization_present()
	local points_present = self:digest_value(self._global.specializations.points_present, false)
	local xp_present = self:digest_value(self._global.specializations.xp_present, false)
	local xp_leftover = self:digest_value(self._global.specializations.xp_leftover, false)

	if points_present ~= 0 and xp_present - xp_leftover ~= 0 then
		self._global.specializations.points_present = self:digest_value(0, true)
		self._global.specializations.xp_present = self:digest_value(xp_leftover, true)

		return xp_present - xp_leftover, points_present
	end

	return false, false
end

function SkillTreeManager:give_specialization_points(xp)
	local total_points = self:digest_value(self._global.specializations.total_points, false)
	local max_points = self:digest_value(self._global.specializations.max_points, false)
	local points = self:digest_value(self._global.specializations.points, false)
	local xp_leftover = self:digest_value(self._global.specializations.xp_leftover, false)
	local points_present = self:digest_value(self._global.specializations.points_present, false)
	local xp_present = self:digest_value(self._global.specializations.xp_present, false)
	local pstar = managers.experience:level_to_stars()
	local static_conversion = tweak_data.skilltree.specialization_convertion_rate[pstar] or 1000
	local points_gained = math.floor((xp + xp_leftover) / static_conversion)
	local xp_remainder = (xp + xp_leftover) % static_conversion

	if max_points < total_points + points_gained then
		points_gained = math.max(0, max_points - total_points)
		xp_remainder = 0
		xp = 0
	end

	total_points = total_points + points_gained
	points = points + points_gained
	points_present = points_present + points_gained
	xp_present = xp_present + xp
	xp_leftover = xp_remainder
	self._global.specializations.total_points = self:digest_value(total_points, true)
	self._global.specializations.points = self:digest_value(points, true)
	self._global.specializations.xp_leftover = self:digest_value(xp_leftover, true)
	self._global.specializations.points_present = self:digest_value(points_present, true)
	self._global.specializations.xp_present = self:digest_value(xp_present, true)
end

function SkillTreeManager:refund_specialization_points(points_to_refund, tree)
	points_to_refund = math.round(points_to_refund)
	local tree_data = self._global.specializations[tree]

	if not tree_data then
		return
	end

	local tier_data = tree_data.tiers

	if not tier_data then
		return
	end

	local next_tier_data = tier_data.next_tier_data

	if not next_tier_data then
		return
	end

	local dlc = tweak_data:get_raw_value("skilltree", "specializations", tree, "dlc")

	if dlc and not managers.dlc:is_dlc_unlocked(dlc) then
		return
	end

	local points = self:digest_value(self._global.specializations.points, false)
	local current_points = self:digest_value(next_tier_data.current_points, false)
	points_to_refund = math.min(points_to_refund, current_points)
	next_tier_data.current_points = self:digest_value(current_points - points_to_refund, true)
	tree_data.points_spent = self:digest_value(self:digest_value(tree_data.points_spent, false) - points_to_refund, true)
	self._global.specializations.points = self:digest_value(points + points_to_refund, true)
end

function SkillTreeManager:spend_specialization_points(points_to_spend, tree)
	points_to_spend = math.round(points_to_spend)

	if points_to_spend < 0 then
		return
	end

	local points = self:digest_value(self._global.specializations.points, false)

	if points < points_to_spend then
		return
	end

	local tree_data = self._global.specializations[tree]

	if not tree_data then
		return
	end

	local tier_data = tree_data.tiers

	if not tier_data then
		return
	end

	local dlc = tweak_data:get_raw_value("skilltree", "specializations", tree, "dlc")

	if dlc and not managers.dlc:is_dlc_unlocked(dlc) then
		return
	end

	local next_tier_data = tier_data.next_tier_data

	if not next_tier_data then
		return
	end

	local current_points = self:digest_value(next_tier_data.current_points, false)
	local tier_points = self:digest_value(next_tier_data.points, false)
	local next_level_points = tier_points - current_points
	local points_spent = 0

	while next_level_points <= points_to_spend do
		points_to_spend = points_to_spend - next_level_points
		points_spent = points_spent + next_level_points

		if not self:_increase_specialization_tier(tree) then
			break
		end

		next_tier_data = tier_data.next_tier_data

		if not next_tier_data then
			break
		end

		current_points = self:digest_value(next_tier_data.current_points, false)
		tier_points = self:digest_value(next_tier_data.points, false)
		next_level_points = tier_points - current_points
	end

	next_tier_data = tier_data.next_tier_data

	if points_to_spend > 0 and next_tier_data then
		points_spent = points_spent + points_to_spend
		current_points = self:digest_value(next_tier_data.current_points, false)
		next_tier_data.current_points = self:digest_value(current_points + points_to_spend, true)
		points_to_spend = 0
	end

	tree_data.points_spent = self:digest_value(self:digest_value(tree_data.points_spent, false) + points_spent, true)
	self._global.specializations.points = self:digest_value(self:digest_value(self._global.specializations.points, false) - points_spent, true)
end

function SkillTreeManager:_increase_specialization_tier(tree)
	local tree_data = self._global.specializations[tree]

	if not tree_data then
		return
	end

	local tier_data = tree_data.tiers

	if not tier_data then
		return
	end

	local current_tier = self:digest_value(tier_data.current_tier, false)
	local max_tier = self:digest_value(tier_data.max_tier, false)

	if max_tier <= current_tier then
		return
	end

	current_tier = current_tier + 1
	local specialization_tweak = tweak_data.skilltree.specializations[tree]

	if not specialization_tweak then
		return
	end

	if self:digest_value(self._global.specializations.current_specialization, false, 1) == tree then
		local spec_data = specialization_tweak[current_tier]

		if not spec_data then
			return
		end

		for _, upgrade in ipairs(spec_data.upgrades) do
			managers.upgrades:aquire(upgrade, false, UpgradesManager.AQUIRE_STRINGS[3] .. tostring(tree))
		end
	end

	tier_data.current_tier = self:digest_value(current_tier, true)

	if current_tier == max_tier then
		tier_data.next_tier_data = false
	else
		local spec_data = specialization_tweak[current_tier + 1]
		tier_data.next_tier_data = {
			current_points = self:digest_value(0, true),
			points = self:digest_value(spec_data.cost, true)
		}
	end

	self:_check_achievements()
	MenuCallbackHandler:_update_outfit_information()

	return true
end

function SkillTreeManager:set_current_specialization(tree)
	local current_specialization = self:digest_value(self._global.specializations.current_specialization, false, 1)

	if current_specialization == tree then
		return
	end

	local dlc = tweak_data:get_raw_value("skilltree", "specializations", tree, "dlc")

	if dlc and not managers.dlc:is_dlc_unlocked(dlc) then
		return
	end

	local tree_data = self._global.specializations[current_specialization]

	if tree_data then
		local tier_data = tree_data.tiers

		if tier_data then
			local current_tier = self:digest_value(tier_data.current_tier, false)
			local specialization_tweak = tweak_data.skilltree.specializations[current_specialization]

			for i = 1, current_tier, 1 do
				for _, upgrade in ipairs(specialization_tweak[i].upgrades) do
					managers.upgrades:unaquire(upgrade, UpgradesManager.AQUIRE_STRINGS[3] .. tostring(current_specialization))
				end
			end
		end
	end

	local tree_data = self._global.specializations[tree]

	if not tree_data then
		return
	end

	local tier_data = tree_data.tiers

	if not tier_data then
		return
	end

	self._global.specializations.current_specialization = self:digest_value(tree, true)
	local current_tier = self:digest_value(tier_data.current_tier, false)
	local specialization_tweak = tweak_data.skilltree.specializations[tree]

	for i = 1, current_tier, 1 do
		for _, upgrade in ipairs(specialization_tweak[i].upgrades) do
			managers.upgrades:aquire(upgrade, false, UpgradesManager.AQUIRE_STRINGS[3] .. tostring(tree))
		end
	end

	if self._global.skill_switches[self._global.selected_skill_switch] then
		self._global.skill_switches[self._global.selected_skill_switch].specialization = self._global.specializations.current_specialization
	end

	self:_check_achievements()
	MenuCallbackHandler:_update_outfit_information()

	if SystemInfo:distribution() == Idstring("STEAM") then
		managers.statistics:publish_skills_to_steam()
	end

	return true
end

function SkillTreeManager:debug_print_specialization_data(data, times)
	data = data or self._global.specializations
	times = times or 0

	for i, d in pairs(data) do
		if type(d) == "string" then
			print(i, self:digest_value(d, false))
		end
	end

	for i, d in ipairs(data) do
		print(i, self:digest_value(d.tiers.current_tier, false))
	end
end

function SkillTreeManager:debug()
	managers.debug:set_enabled(true)
	managers.debug:set_systems_enabled(true, {
		"gui"
	})

	local gui = managers.debug._system_list.gui

	gui:clear()

	local j = 1

	local function add_func(skill_id)
		local skill = tweak_data.skilltree.skills[skill_id]
		local skill_data = self._global.skills[skill_id]

		for i = 1, skill_data.unlocked, 1 do
			local sub_skill = skill[i]
			local type = i == 1 and "STD" or "PRO"

			if sub_skill.upgrades then
				for _, upgrade in ipairs(sub_skill.upgrades) do
					local value = managers.upgrades:get_value(upgrade)

					if value then
						if managers.upgrades:get_category(upgrade) == "temporary" then
							local u = managers.upgrades:get_upgrade_upgrade(upgrade)
							local index = j

							gui:set_func(j, function ()
								if managers.player:has_activate_temporary_upgrade(u.category, u.upgrade) then
									gui:set_color(index, 0, 1, 0)
								elseif math.mod(index, 2) == 0 then
									gui:set_color(index, 0.75, 0.75, 0.75, 0.5)
								else
									gui:set_color(index, 1, 1, 1, 0.5)
								end

								return skill_id .. " " .. type .. " - " .. upgrade .. ":    " .. tostring(value)
							end)
						else
							gui:set_func(j, function ()
								return skill_id .. " " .. type .. " - " .. upgrade .. ":    " .. tostring(value)
							end)

							if math.mod(j, 2) == 0 then
								gui:set_color(j, 0.75, 0.75, 0.75)
							else
								gui:set_color(j, 1, 1, 1)
							end
						end

						j = j + 1
					end
				end
			else
				gui:set_func(j, function ()
					return skill_id .. " " .. type .. ""
				end)

				j = j + 1
			end
		end
	end

	for tree_id, tree_data in pairs(self._global.trees) do
		if tree_data.unlocked and not tweak_data.skilltree.trees[tree_id].dlc then
			local skill_id = tweak_data.skilltree.trees[tree_id].skill

			add_func(skill_id)

			for tier, skills in pairs(tweak_data.skilltree.trees[tree_id].tiers) do
				for _, skill_id in ipairs(skills) do
					add_func(skill_id)
				end
			end
		end
	end
end

function SkillTreeManager:reset()
	Global.skilltree_manager = nil

	self:_setup()

	if SystemInfo:distribution() == Idstring("STEAM") then
		managers.statistics:publish_skills_to_steam()
	end
end
