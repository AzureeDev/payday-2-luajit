LootManager = LootManager or class()

function LootManager:init()
	self:_setup()
end

function LootManager:_setup()
	Global.loot_manager = Global.loot_manager or {
		secured = {},
		mandatory_bags = {},
		postponed_small_loot = {}
	}
	self._global = Global.loot_manager
	self._initial_loot = deep_clone(self._global.secured)
	self._distribution_loot = {}
	local level_id = Global.level_data and Global.level_data.level_id
	local level_tweak = tweak_data.levels[level_id]

	if level_tweak and level_tweak.repossess_bags then
		self:_repossess_bags_for_distribution()
	end

	self._triggers = {}
	self._respawns = {}
end

function LootManager:clear()
	Global.loot_manager = nil
end

function LootManager:reset()
	Global.loot_manager = nil

	self:_setup()
end

function LootManager:on_simulation_ended()
	self._respawns = {}
	self._global.mandatory_bags = {}
end

function LootManager:add_trigger(id, type, amount, callback)
	self._triggers[type] = self._triggers[type] or {}
	self._triggers[type][id] = {
		amount = amount,
		callback = callback
	}
end

function LootManager:_check_triggers(type)
	if not self._triggers[type] then
		return
	end

	if type == "amount" then
		local bag_total_value = self:get_real_total_loot_value()

		for id, cb_data in pairs(self._triggers[type]) do
			if type ~= "amount" or cb_data.amount <= bag_total_value then
				cb_data.callback()
			end
		end
	elseif type == "total_amount" then
		local total_value = self:get_real_total_value()

		for id, cb_data in pairs(self._triggers[type]) do
			if cb_data.amount <= total_value then
				cb_data.callback()
			end
		end
	elseif type == "report_only" then
		for id, cb_data in pairs(self._triggers[type]) do
			cb_data.callback()
		end
	end
end

function LootManager:on_retry_job_stage()
	self._global.secured = self._initial_loot
end

function LootManager:get_secured()
	return table.remove(self._global.secured, 1)
end

function LootManager:get_secured_random()
	local entry = math.random(#self._global.secured)

	return table.remove(self._global.secured, entry)
end

function LootManager:get_distribute()
	return table.remove(self._distribution_loot, 1)
end

function LootManager:get_respawn()
	return table.remove(self._respawns, 1)
end

function LootManager:add_to_respawn(carry_id, multiplier)
	table.insert(self._respawns, {
		carry_id = carry_id,
		multiplier = multiplier
	})
end

function LootManager:_repossess_bags_for_distribution()
	local small_loot = {}
	local distribute = self._distribution_loot

	for _, data in ipairs(self._global.secured) do
		local is_small = tweak_data.carry.small_loot[data.carry_id] ~= nil

		table.insert(is_small and small_loot or distribute, data)
	end

	self._global.secured = small_loot
end

function LootManager:on_job_deactivated()
	self:clear()
end

function LootManager:secure(carry_id, multiplier_level, silent, peer_id)
	if Network:is_server() then
		self:server_secure_loot(carry_id, multiplier_level, silent, peer_id)
	else
		managers.network:session():send_to_host("server_secure_loot", carry_id, multiplier_level, peer_id)
	end
end

function LootManager:server_secure_loot(carry_id, multiplier_level, silent, peer_id)
	managers.network:session():send_to_peers_synched("sync_secure_loot", carry_id, multiplier_level, silent, peer_id)
	self:sync_secure_loot(carry_id, multiplier_level, silent, peer_id)
end

function LootManager:sync_secure_loot(carry_id, multiplier_level, silent, peer_id)
	if peer_id == 0 then
		peer_id = nil
	end

	local multiplier = tweak_data.carry.small_loot[carry_id] and managers.player:upgrade_value_by_level("player", "small_loot_multiplier", multiplier_level, 1) or 1

	table.insert(self._global.secured, {
		carry_id = carry_id,
		multiplier = multiplier,
		peer_id = peer_id
	})
	managers.hud:loot_value_updated()
	self:_check_triggers("amount")
	self:_check_triggers("total_amount")

	if not tweak_data.carry.small_loot[carry_id] then
		self:_check_triggers("report_only")

		if not silent then
			self:_present(carry_id, multiplier)
		end
	end

	self:check_achievements(carry_id, multiplier)
end

function LootManager:_count_achievement_secured(achievement, secured_data)
	local amount = 0
	local total_amount = 0
	local value = 0

	for _, data in ipairs(self._global.secured) do
		local found = false
		local carry_id = nil

		if type(secured_data.carry_id) == "table" then
			for _, id in ipairs(secured_data.carry_id) do
				if id == data.carry_id then
					found = true
					carry_id = id

					break
				end
			end
		elseif data.carry_id == secured_data.carry_id then
			found = true
			carry_id = data.carry_id
		end

		if found then
			if not data[achievement] then
				amount = amount + 1
				data[achievement] = true
			end

			total_amount = total_amount + 1
			local is_small_loot = not not tweak_data.carry.small_loot[carry_id]

			if is_small_loot then
				value = value + self:get_real_value(carry_id, data.multiplier)
			else
				value = value + managers.money:get_secured_bonus_bag_value(carry_id, data.multiplier)
			end
		end
	end

	return total_amount, amount, value
end

function LootManager:_check_secured(achievement, secured_data)
	local total_amount, amount, value = self:_count_achievement_secured(achievement, secured_data)

	return secured_data.total_amount and secured_data.total_amount <= total_amount or secured_data.amount and secured_data.amount <= amount or secured_data.value and secured_data.value <= value
end

function LootManager:check_achievements(carry_id, multiplier)
	local real_total_value = self:get_real_total_value()
	local memory, total_memory_value, all_pass, total_value_pass, jobs_pass, levels_pass, difficulties_pass, total_time_pass, no_assets_pass, no_deployable_pass, secured_pass, is_dropin_pass = nil

	for achievement, achievement_data in pairs(tweak_data.achievement.loot_cash_achievements or {}) do
		jobs_pass = not achievement_data.jobs or table.contains(achievement_data.jobs, managers.job:current_real_job_id())
		levels_pass = not achievement_data.levels or table.contains(achievement_data.levels, managers.job:current_level_id())
		difficulties_pass = not achievement_data.difficulties or table.contains(achievement_data.difficulties, Global.game_settings.difficulty)
		total_time_pass = not achievement_data.total_time or managers.game_play_central and managers.game_play_central:get_heist_timer() <= achievement_data.total_time
		no_assets_pass = not achievement_data.no_assets or #managers.assets:get_unlocked_asset_ids(true) == 0
		no_deployable_pass = not achievement_data.no_deployable or not managers.player:has_deployable_been_used()
		is_dropin_pass = achievement_data.is_dropin == nil or achievement_data.is_dropin == managers.statistics:is_dropin()
		secured_pass = not achievement_data.secured

		if achievement_data.secured then
			if achievement_data.secured[1] ~= nil then
				for i, secured_data in ipairs(achievement_data.secured) do
					secured_pass = self:_check_secured(achievement, secured_data)

					if not secured_pass then
						break
					end
				end
			else
				secured_pass = self:_check_secured(achievement, achievement_data.secured)
			end
		end

		if not achievement_data.timer then
			total_value_pass = not achievement_data.total_value or achievement_data.total_value <= real_total_value
		else
			memory = managers.job:get_memory(achievement, achievement_data.is_shortterm)
			local t = Application:time()
			local new_memory = {
				time = t,
				value = self:get_real_value(carry_id, multiplier)
			}

			if memory then
				table.insert(memory, new_memory)

				for i = #memory, 1, -1 do
					if achievement_data.timer <= t - memory[i].time then
						table.remove(memory, i)
					end
				end

				managers.job:set_memory(achievement, memory, achievement_data.is_shortterm)
			else
				memory = {
					new_memory
				}

				managers.job:set_memory(achievement, memory, achievement_data.is_shortterm)
			end

			total_memory_value = 0

			for _, m_data in ipairs(memory) do
				total_memory_value = total_memory_value + m_data.value
			end

			total_value_pass = not achievement_data.total_value or achievement_data.total_value <= total_memory_value
		end

		all_pass = total_value_pass and jobs_pass and levels_pass and difficulties_pass and total_time_pass and no_assets_pass and no_deployable_pass and secured_pass and is_dropin_pass

		if all_pass and not managers.achievment:award_data(achievement_data) then
			Application:debug("[LootManager] loot_cash_achievements:", achievement)
		end
	end
end

function LootManager:secure_small_loot(type, multiplier_level, peer_id)
	self:secure(type, multiplier_level, nil, peer_id)
end

function LootManager:show_small_loot_taken_hint(type, multiplier)
	managers.hint:show_hint("grabbed_small_loot", 2, nil, {
		MONEY = managers.experience:cash_string(self:get_real_value(type, multiplier))
	})
end

function LootManager:set_mandatory_bags_data(carry_id, amount)
	self._global.mandatory_bags.carry_id = carry_id
	self._global.mandatory_bags.amount = amount
end

function LootManager:get_mandatory_bags_data()
	return self._global.mandatory_bags
end

function LootManager:check_secured_mandatory_bags()
	if not self._global.mandatory_bags.amount or self._global.mandatory_bags.amount == 0 then
		return true
	end

	local amount = self:get_secured_mandatory_bags_amount()

	return self._global.mandatory_bags.amount <= amount
end

function LootManager:get_secured_mandatory_bags_amount(is_vehicle)
	local mandatory_bags_amount = self._global.mandatory_bags.amount or 0

	if mandatory_bags_amount == 0 then
		return 0
	end

	local amount = 0

	for _, data in ipairs(self._global.secured) do
		if not tweak_data.carry.small_loot[data.carry_id] and not tweak_data.carry[data.carry_id].is_vehicle == not is_vehicle and mandatory_bags_amount > 0 and (self._global.mandatory_bags.carry_id == "none" or self._global.mandatory_bags.carry_id == data.carry_id) then
			amount = amount + 1
			mandatory_bags_amount = mandatory_bags_amount - 1
		end
	end

	return amount
end

function LootManager:get_secured_bonus_bags_amount(is_vehicle)
	local mandatory_bags_amount = self._global.mandatory_bags.amount or 0
	local secured_mandatory_bags_amount = self:get_secured_mandatory_bags_amount()
	local amount = 0

	for _, data in ipairs(self._global.secured) do
		if not tweak_data.carry.small_loot[data.carry_id] and not tweak_data.carry[data.carry_id].is_vehicle == not is_vehicle then
			if mandatory_bags_amount > 0 and (self._global.mandatory_bags.carry_id == "none" or self._global.mandatory_bags.carry_id == data.carry_id) then
				mandatory_bags_amount = mandatory_bags_amount - 1
			else
				amount = amount + 1
			end
		end
	end

	return amount
end

function LootManager:get_secured_bonus_bags_value(level_id, is_vehicle)
	local mandatory_bags_amount = self._global.mandatory_bags.amount or 0
	local amount_bags = tweak_data.levels[level_id] and tweak_data.levels[level_id].max_bags or 20
	local value = 0

	for _, data in ipairs(self._global.secured) do
		if not tweak_data.carry.small_loot[data.carry_id] and not tweak_data.carry[data.carry_id].is_vehicle == not is_vehicle then
			if mandatory_bags_amount > 0 and (self._global.mandatory_bags.carry_id == "none" or self._global.mandatory_bags.carry_id == data.carry_id) then
				mandatory_bags_amount = mandatory_bags_amount - 1
			elseif amount_bags > 0 then
				value = value + managers.money:get_bag_value(data.carry_id, data.multiplier)
			end

			amount_bags = amount_bags - 1
		end
	end

	return value
end

function LootManager:get_secured_mandatory_bags_value(is_vehicle)
	local mandatory_bags_amount = self._global.mandatory_bags.amount or 0
	local value = 0

	for _, data in ipairs(self._global.secured) do
		if not tweak_data.carry.small_loot[data.carry_id] and not tweak_data.carry[data.carry_id].is_vehicle == not is_vehicle and mandatory_bags_amount > 0 and (self._global.mandatory_bags.carry_id == "none" or self._global.mandatory_bags.carry_id == data.carry_id) then
			mandatory_bags_amount = mandatory_bags_amount - 1
			value = value + managers.money:get_bag_value(data.carry_id, data.multiplier)
		end
	end

	return value
end

function LootManager:is_bonus_bag(carry_id, is_vehicle)
	if self._global.mandatory_bags.carry_id ~= "none" and carry_id and carry_id ~= self._global.mandatory_bags.carry_id then
		return true
	end

	local mandatory_bags_amount = self._global.mandatory_bags.amount or 0

	for _, data in ipairs(self._global.secured) do
		if not tweak_data.carry.small_loot[data.carry_id] and not tweak_data.carry[data.carry_id].is_vehicle == not is_vehicle then
			if mandatory_bags_amount > 0 and (self._global.mandatory_bags.carry_id == "none" or self._global.mandatory_bags.carry_id == data.carry_id) then
				mandatory_bags_amount = mandatory_bags_amount - 1
			elseif mandatory_bags_amount == 0 then
				return true
			end
		end
	end

	return false
end

function LootManager:get_real_value(carry_id, multiplier)
	local mul_value = 1

	if not tweak_data.carry.small_loot[carry_id] then
		local has_active_job = managers.job:has_active_job()
		local job_stars = has_active_job and managers.job:current_job_stars() or 1
		mul_value = tweak_data:get_value("carry", "value_multiplier", job_stars)
		mul_value = mul_value or 1
	end

	return managers.money:get_bag_value(carry_id, multiplier) * mul_value
end

function LootManager:get_real_total_value()
	local value = 0

	for _, data in ipairs(self._global.secured) do
		value = value + self:get_real_value(data.carry_id, data.multiplier)
	end

	return value
end

function LootManager:get_real_total_loot_value()
	local value = 0
	local loot_value = nil

	for _, data in ipairs(self._global.secured) do
		if not tweak_data.carry.small_loot[data.carry_id] then
			loot_value = self:get_real_value(data.carry_id, data.multiplier)

			if value + loot_value < tweak_data:get_value("money_manager", "max_small_loot_value") then
				value = value + loot_value
			else
				value = tweak_data:get_value("money_manager", "max_small_loot_value")

				break
			end
		end
	end

	return value
end

function LootManager:get_real_total_small_loot_value()
	local value = 0
	local loot_value = nil

	for _, data in ipairs(self._global.secured) do
		if tweak_data.carry.small_loot[data.carry_id] then
			loot_value = self:get_real_value(data.carry_id, data.multiplier)

			if value + loot_value < tweak_data:get_value("money_manager", "max_small_loot_value") then
				value = value + loot_value
			else
				value = tweak_data:get_value("money_manager", "max_small_loot_value")

				break
			end
		end
	end

	return value
end

function LootManager:set_postponed_small_loot()
	self._global.postponed_small_loot = {}

	for _, data in ipairs(self._global.secured) do
		if tweak_data.carry.small_loot[data.carry_id] then
			table.insert(self._global.postponed_small_loot, deep_clone(data))
		end
	end
end

function LootManager:get_real_total_postponed_small_loot_value()
	if not self._global.postponed_small_loot then
		return 0
	end

	local value = 0

	for _, data in ipairs(self._global.postponed_small_loot) do
		value = value + self:get_real_value(data.carry_id, data.multiplier)
	end

	return value
end

function LootManager:clear_postponed_small_loot()
	self._global.postponed_small_loot = nil
end

function LootManager:total_value_by_carry_id(carry_id)
	local value = 0

	for _, data in ipairs(self._global.secured) do
		if data.carry_id == carry_id then
			value = value + data.value
		end
	end

	return value
end

function LootManager:total_small_loot_value()
	local value = 0

	for _, data in ipairs(self._global.secured) do
		if tweak_data.carry.small_loot[data.carry_id] then
			value = value + data.value
		end
	end

	return value
end

function LootManager:total_value_by_type(type)
	if not tweak_data.carry.types[type] then
		Application:error("Carry type", type, "doesn't exists!")

		return
	end

	local value = 0

	for _, data in ipairs(self._global.secured) do
		if tweak_data.carry[data.carry_id].type == type then
			value = value + data.value
		end
	end

	return value
end

function LootManager:get_loot_stinger()
	local job_tweak = tweak_data.narrative.jobs[managers.job:current_real_job_id()]

	if job_tweak and job_tweak.objective_stinger then
		return job_tweak.objective_stinger
	end

	return "stinger_objectivecomplete"
end

function LootManager:_present(carry_id, multiplier)
	local real_value = 0
	local is_small_loot = not not tweak_data.carry.small_loot[carry_id]

	if is_small_loot then
		real_value = self:get_real_value(carry_id, multiplier)
	else
		real_value = managers.money:get_secured_bonus_bag_value(carry_id, multiplier)
	end

	local carry_data = tweak_data.carry[carry_id]
	local title = managers.localization:text("hud_loot_secured_title")
	local type_text = carry_data.name_id and managers.localization:text(carry_data.name_id)
	local text = managers.localization:text("hud_loot_secured", {
		CARRY_TYPE = type_text,
		AMOUNT = managers.experience:cash_string(real_value)
	})
	local icon = nil

	managers.hud:present_mid_text({
		time = 4,
		text = text,
		title = title,
		icon = icon,
		event = self:get_loot_stinger()
	})
end

function LootManager:sync_save(data)
	data.LootManager = clone(self._global)
end

function LootManager:sync_load(data)
	self._global = data.LootManager
	Global.loot_manager = self._global

	for _, data in ipairs(self._global.secured) do
		if data.multiplier and data.multiplier > 2 then
			data.multiplier = 2
		end
	end
end
