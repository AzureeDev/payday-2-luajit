local function debug_assert(chk, ...)
	if not chk then
		local s = ""

		for i, text in ipairs({
			...
		}) do
			s = s .. "  " .. text
		end

		assert(chk, s)
	end
end

local default_category = "default"
local server_master_planner = true
PrePlanningManager = PrePlanningManager or class()
PrePlanningManager.server_master_planner = server_master_planner

function PrePlanningManager:init()
	self._mission_elements_by_type = {}
	self._reserved_mission_elements = {}
	self._delayed_mission_elements = {}
	self._active_location_groups = {}
	self._players_votes = {}
	self._finished_preplan = nil
	self._disabled_types = {}
end

function PrePlanningManager:post_init()
end

function PrePlanningManager:register_element(element)
	for _, type in ipairs(element:value("allowed_types")) do
		self._mission_elements_by_type[type] = self._mission_elements_by_type[type] or {}

		table.insert(self._mission_elements_by_type[type], element)
	end
end

function PrePlanningManager:unregister_element(element)
	for _, type in ipairs(element:value("allowed_types")) do
		table.delete(self._mission_elements_by_type[type], element)

		if not next(self._mission_elements_by_type[type]) then
			self._mission_elements_by_type[type] = nil
		end
	end
end

function PrePlanningManager:is_type_disabled(type)
	return not not self._disabled_types[type]
end

function PrePlanningManager:_change_disabled_type(type, change)
	self._disabled_types[type] = self._disabled_types[type] or 0
	self._disabled_types[type] = self._disabled_types[type] + change

	if self._disabled_types[type] <= 0 then
		self._disabled_types[type] = nil
	end
end

function PrePlanningManager:activate_location_groups(location_groups)
	for _, location_group in ipairs(location_groups) do
		self._active_location_groups[location_group] = true
	end

	local element, type = nil

	table.remove_condition(self._delayed_mission_elements, function (data)
		type = data.type
		element = data.element

		if element and self._active_location_groups[element:value("location_group")] then
			self:execute(type, element)

			return true
		end

		return false
	end)
end

function PrePlanningManager:is_location_group_active(location_group)
	return not next(self._active_location_groups) or self._active_location_groups[location_group]
end

function PrePlanningManager:can_vote_on_plan(type, peer_id)
	local current_budget, total_budget = self:get_current_budget()
	local cost_mod = 0
	local current_plan = tweak_data:get_raw_value("preplanning", "types", type, "plan")

	if current_plan then
		local current_majority_votes = self:get_current_majority_votes()

		if current_majority_votes and current_majority_votes[current_plan] then
			cost_mod = -self:get_type_budget_cost(current_majority_votes[current_plan][1])
		end
	end

	if total_budget < current_budget + self:get_type_budget_cost(type, 0) + cost_mod then
		return false
	end

	if self:is_type_disabled(type) then
		return
	end

	return true
end

function PrePlanningManager:vote_on_plan(type, id)
	local peer_id = managers.network:session():local_peer():id()

	if Network:is_server() then
		self:_server_vote_on_plan(type, id, peer_id)
	elseif self:can_vote_on_plan(type, peer_id) then
		print("[SEND] vote_on_plan", type, id)
		managers.network:session():send_to_host("reserve_preplanning", type, id, 2)
	end
end

function PrePlanningManager:client_vote_on_plan(type, id, peer_id)
	local index = self:get_mission_element_index(id, type)
	local plan = tweak_data:get_raw_value("preplanning", "types", type, "plan")

	if tweak_data:get_raw_value("preplanning", "plans", plan) then
		self._players_votes[peer_id] = self._players_votes[peer_id] or {}
		self._players_votes[peer_id][plan] = {
			type,
			index
		}

		print("[VOTED]", "plan", plan, "type", type, "peer_id", peer_id)

		self._saved_majority_votes = nil
		self._saved_vote_council = nil

		managers.menu_component:update_preplanning_element(nil, nil)
	end
end

function PrePlanningManager:server_vote_on_plan(type, id, peer_id)
	self:_server_vote_on_plan(type, id, peer_id)
end

function PrePlanningManager:_server_vote_on_plan(type, id, peer_id)
	local index = self:get_mission_element_index(id, type)
	local plan = tweak_data:get_raw_value("preplanning", "types", type, "plan")

	if tweak_data:get_raw_value("preplanning", "plans", plan) and self:can_vote_on_plan(type, peer_id) then
		self._players_votes[peer_id] = self._players_votes[peer_id] or {}
		self._players_votes[peer_id][plan] = {
			type,
			index
		}

		managers.network:session():send_to_peers_loaded("preplanning_reserved", type, id, peer_id, 2)
		print("[VOTED]", "plan", plan, "type", type, "peer_id", peer_id)

		self._saved_majority_votes = nil
		self._saved_vote_council = nil

		managers.menu_component:update_preplanning_element(nil, nil)
	end
end

function PrePlanningManager:get_player_votes(peer_id)
	return self._players_votes[peer_id]
end

function PrePlanningManager:get_votes_on_element(plan, type, index)
	local vote_council = self:get_vote_council()
	local _plan = nil
	local t = {
		votes = 0,
		players = {
			false,
			false,
			false,
			false
		}
	}

	for peer_id, data in pairs(vote_council) do
		_plan = data[plan]

		if _plan and _plan[1] == type and _plan[2] == index then
			t.votes = t.votes + 1
			t.players[peer_id] = true
		end
	end

	return t
end

function PrePlanningManager:unreserve_mission_element(id)
	if not managers.network:session() then
		return
	end

	local peer_id = managers.network:session():local_peer():id()

	if Network:is_server() then
		self:_server_unreserve_mission_element(id, peer_id)
	elseif self._reserved_mission_elements[id] and self._reserved_mission_elements[id].peer_id == peer_id then
		managers.network:session():send_to_host("reserve_preplanning", "", id, 1)
	end
end

function PrePlanningManager:server_unreserve_mission_element(id, peer_id)
	self:_server_unreserve_mission_element(id, peer_id)
end

function PrePlanningManager:_server_unreserve_mission_element(id, peer_id)
	local server_override = false

	if server_master_planner and Network:is_server() then
		server_override = peer_id == managers.network:session():local_peer():id()
	end

	if self._reserved_mission_elements[id] and (server_override or self._reserved_mission_elements[id].peer_id == peer_id) then
		local type, index = unpack(self._reserved_mission_elements[id].pack)
		local mission_element = self._mission_elements_by_type[type][index]

		if mission_element then
			local disables_types = mission_element:value("disables_types") or {}

			for _, type in ipairs(disables_types) do
				self:_change_disabled_type(type, -1)
			end
		end

		self._reserved_mission_elements[id] = nil
		local peer = managers.network:session() and managers.network:session():peer(peer_id)

		if peer then
			managers.chat:feed_system_message(ChatManager.GAME, managers.localization:text("menu_chat_preplanning_unreserved", {
				name = peer:name(),
				type = self:get_type_name(type)
			}))
		end

		managers.network:session():send_to_peers_loaded("preplanning_reserved", "", id, peer_id, 1)
		print("[UNRESERVED]", "type", type, "id", id, "peer_id", peer_id)
		managers.menu_component:update_preplanning_element(type, id)
	end
end

function PrePlanningManager:client_unreserve_mission_element(id, peer_id)
	if self._reserved_mission_elements[id] then
		local type, index = unpack(self._reserved_mission_elements[id].pack)
		local mission_element = self._mission_elements_by_type[type][index]

		if mission_element then
			local disables_types = mission_element:value("disables_types") or {}

			for _, type in ipairs(disables_types) do
				self:_change_disabled_type(type, -1)
			end
		end

		local peer = managers.network:session() and managers.network:session():peer(peer_id or self._reserved_mission_elements[id].peer_id or 1)

		if peer then
			managers.chat:feed_system_message(ChatManager.GAME, managers.localization:text("menu_chat_preplanning_unreserved", {
				name = peer:name(),
				type = self:get_type_name(type)
			}))
		end

		self._reserved_mission_elements[id] = nil

		managers.menu_component:update_preplanning_element(type, id)
	end
end

function PrePlanningManager:on_peer_added(peer_id)
	self._saved_majority_votes = nil
	self._saved_vote_council = nil

	managers.menu_component:update_preplanning_element(nil, nil)
end

function PrePlanningManager:on_peer_removed(peer_id)
	local owned_by_peer = {}

	for id, reserved_mission_element in pairs(self._reserved_mission_elements) do
		if reserved_mission_element.peer_id == peer_id then
			table.insert(owned_by_peer, id)
		end
	end

	for i, id in ipairs(owned_by_peer) do
		local type, index = unpack(self._reserved_mission_elements[id].pack)
		local mission_element = self._mission_elements_by_type[type][index]

		if mission_element then
			local disables_types = mission_element:value("disables_types") or {}

			for _, type in ipairs(disables_types) do
				self:_change_disabled_type(type, -1)
			end
		end

		self._reserved_mission_elements[id] = nil
	end

	self._players_votes[peer_id] = nil
	self._saved_majority_votes = nil
	self._saved_vote_council = nil

	managers.menu_component:clear_preplanning_draws(peer_id)
	managers.menu_component:update_preplanning_element(nil, nil)
end

function PrePlanningManager:count_reserved_for_type(type, category, peer_id)
	local type_player_count = 0
	local type_total_count = 0
	local category_player_count = 0
	local category_total_count = 0
	local _type, _index, _category, _peer_id, type_data, category_data = nil

	for id, data in pairs(self._reserved_mission_elements) do
		_type, _index = unpack(data.pack)
		_peer_id = data.peer_id
		_category = tweak_data:get_raw_value("preplanning", "types", _type, "category") or default_category

		if _type == type then
			type_total_count = type_total_count + 1

			if _peer_id == peer_id then
				type_player_count = type_player_count + 1
			end
		end

		if _category == category then
			category_total_count = category_total_count + 1

			if _peer_id == peer_id then
				category_player_count = category_player_count + 1
			end
		end
	end

	return type_player_count, type_total_count, category_player_count, category_total_count
end

function PrePlanningManager:can_reserve_mission_element(type, peer_id)
	local current_budget, total_budget = self:get_current_budget()

	if total_budget < current_budget + self:get_type_budget_cost(type) then
		return false, 2
	end

	if peer_id == managers.network:session():local_peer():id() and not managers.money:can_afford_preplanning_type(type) then
		return false, 1
	end

	if self:is_type_disabled(type) then
		return false, 3
	end

	local type_data = tweak_data:get_raw_value("preplanning", "types", type)
	local category = type_data and type_data.category or default_category
	local category_data = tweak_data:get_raw_value("preplanning", "categories", category)
	local type_max_per_player = type_data and type_data.max_per_player
	local type_total = type_data and type_data.total
	local category_max_per_player = category_data and category_data.max_per_player
	local category_total = category_data and category_data.total
	local type_player_count, type_total_count, category_player_count, category_total_count = self:count_reserved_for_type(type, category, peer_id)
	local type_player_pass = not type_max_per_player or type_player_count < type_max_per_player
	local type_total_pass = not type_total or type_total_count < type_total
	local category_player_pass = not category_max_per_player or category_player_count < category_max_per_player
	local category_total_pass = not category_total or category_total_count < category_total

	return type_player_pass and type_total_pass and category_player_pass and category_total_pass, 4
end

function PrePlanningManager:reserve_mission_element(type, id)
	local peer_id = managers.network:session():local_peer():id()

	if Network:is_server() then
		self:_server_reserve_mission_element(type, id, peer_id)
	elseif not self._reserved_mission_elements[id] and self:can_reserve_mission_element(type, peer_id) then
		print("[SEND] reserve_mission_element", type, id)
		managers.network:session():send_to_host("reserve_preplanning", type, id, 0)
	end
end

function PrePlanningManager:server_reserve_mission_element(type, id, peer_id)
	self:_server_reserve_mission_element(type, id, peer_id)
end

function PrePlanningManager:_server_reserve_mission_element(type, id, peer_id)
	local index = self:get_mission_element_index(id, type)

	if index and not self._reserved_mission_elements[id] and self:can_reserve_mission_element(type, peer_id) then
		self._reserved_mission_elements[id] = {
			pack = {
				type,
				index
			},
			peer_id = peer_id
		}
		local disables_types = self._mission_elements_by_type[type][index]:value("disables_types") or {}

		for _, type in ipairs(disables_types) do
			self:_change_disabled_type(type, 1)
		end

		local peer = managers.network:session() and managers.network:session():peer(peer_id)

		if peer then
			managers.chat:feed_system_message(ChatManager.GAME, managers.localization:text("menu_chat_preplanning_reserved", {
				name = peer:name(),
				type = self:get_type_name(type)
			}))
		end

		managers.network:session():send_to_peers_loaded("preplanning_reserved", type, id, peer_id, 0)
		print("[RESERVED]", "type", type, "id", id, "peer_id", peer_id)
		managers.menu_component:update_preplanning_element(type, id)
	end
end

function PrePlanningManager:client_reserve_mission_element(type, id, peer_id)
	local index = self:get_mission_element_index(id, type)

	if index then
		if self._reserved_mission_elements[id] then
			Application:error("[PrePlanningManager:client_reserve_mission_element] Point already reserved!", "type", type, "id", id, "peer_id", peer_id, "point", inspect(self._reserved_mission_elements[id]))

			local old_type = self._reserved_mission_elements[id].pack[1]
			local old_index = self._reserved_mission_elements[id].pack[2]
			local mission_element = self._mission_elements_by_type[old_type][old_index]

			if mission_element then
				local disables_types = mission_element:value("disables_types") or {}

				for _, type in ipairs(disables_types) do
					self:_change_disabled_type(type, -1)
				end
			end

			self._reserved_mission_elements[id] = nil
		end

		local peer = managers.network:session() and managers.network:session():peer(peer_id)

		if peer then
			managers.chat:feed_system_message(ChatManager.GAME, managers.localization:text("menu_chat_preplanning_reserved", {
				name = peer:name(),
				type = self:get_type_name(type)
			}))
		end

		self._reserved_mission_elements[id] = {
			pack = {
				type,
				index
			},
			peer_id = peer_id
		}
		local disables_types = self._mission_elements_by_type[type][index]:value("disables_types") or {}

		for _, type in ipairs(disables_types) do
			self:_change_disabled_type(type, 1)
		end

		managers.menu_component:update_preplanning_element(type, id)
	end
end

function PrePlanningManager:get_reserved_mission_element(id)
	return self._reserved_mission_elements[id]
end

function PrePlanningManager:get_reserved_mission_element_data(id)
	return self._reserved_mission_elements[id] and self._reserved_mission_elements[id].pack
end

function PrePlanningManager:_get_type_cost(type)
	return managers.money:get_preplanning_type_cost(type)
end

function PrePlanningManager:get_reserved_local_cost()
	local total_cost = 0
	local peer_id = managers.network:session():local_peer():id()

	for id, data in pairs(self._reserved_mission_elements) do
		if data.peer_id == peer_id then
			total_cost = total_cost + self:_get_type_cost(data.pack[1])
		end
	end

	return total_cost
end

function PrePlanningManager:get_type_budget_cost(type, default)
	return tweak_data:get_raw_value("preplanning", "types", type, "budget_cost") or default or 1
end

function PrePlanningManager:get_current_budget()
	local location_data = self:_current_location_data()

	debug_assert(location_data, "[PrePlanningManager:get_current_budget] Missing location data for level", "level_id", managers.job:current_level_id())

	local total_cost = 0
	local peer_id = managers.network:session():local_peer():id()

	for id, data in pairs(self._reserved_mission_elements) do
		total_cost = total_cost + self:get_type_budget_cost(data.pack[1])
	end

	local current_majority_votes = self:get_current_majority_votes()

	if current_majority_votes then
		for plan, data in pairs(current_majority_votes) do
			total_cost = total_cost + self:get_type_budget_cost(data[1])
		end
	end

	return total_cost, location_data.total_budget or 1
end

function PrePlanningManager:on_execute_preplanning()
	if self:has_current_level_preplanning() then
		managers.money:on_buy_preplanning_types()
		managers.money:on_buy_preplanning_votes()

		local current_budget, total_budget = self:get_current_budget()

		if current_budget == total_budget and managers.job:current_level_id() == "big" then
			managers.achievment:award("bigbank_8")
		end

		local local_peer_id = managers.network:session():local_peer():id()
		local award_achievement, progress_stat, type_data = nil

		for id, data in pairs(self._reserved_mission_elements) do
			if data.peer_id == local_peer_id then
				type_data = tweak_data.preplanning.types[data.pack[1]]

				if type_data then
					award_achievement = type_data.award_achievement

					if award_achievement then
						managers.achievment:award(award_achievement)
					end

					progress_stat = type_data.progress_stat

					if progress_stat then
						managers.achievment:award_progress(progress_stat)
					end
				end
			end
		end
	end

	self._reserved_mission_elements = {}
	self._players_votes = {}
	self._executed_reserved_mission_elements = nil
end

function PrePlanningManager:execute_reserved_mission_elements()
	if Network:is_server() and not self._executed_reserved_mission_elements then
		self._active_location_groups = {}
		local location_data = self:_current_location_data()

		if location_data.active_location_groups then
			for _, location_group in ipairs(location_data.active_location_groups) do
				self._active_location_groups[location_group] = true
			end
		end

		local type, index = nil
		local current_budget, total_budget = self:get_current_budget()
		current_budget = 0
		local location_group_converter = self:_get_location_groups_converter()
		local location_group, location_index, element = nil

		local function execute_func(type, index, finished_table)
			if not self:is_type_disabled(type) then
				current_budget = current_budget + self:get_type_budget_cost(type)

				if current_budget <= total_budget then
					element = self._mission_elements_by_type[type] and self._mission_elements_by_type[type][index]

					if element then
						location_group = element:value("location_group")

						if self:is_location_group_active(location_group) then
							self:execute(type, element)
						else
							table.insert(self._delayed_mission_elements, {
								type = type,
								index = index,
								element = element
							})
						end

						if finished_table then
							location_index = location_group_converter[location_group]
							finished_table[location_index] = finished_table[location_index] or {}
							finished_table[location_index][element:id()] = type
						end
					end
				else
					Application:error("[PrePlanningManager:execute_reserved_mission_elements] out of budget!", "type", type, "current_budget", current_budget, "total_budget", total_budget)
				end
			else
				Application:error("[PrePlanningManager:execute_reserved_mission_elements] type is disabled", type)
			end
		end

		local finished_votes = {
			name_id = "menu_pp_sub_voting"
		}
		local winners = self:get_current_majority_votes()

		for plan, data in pairs(winners) do
			type, index = unpack(data)

			execute_func(type, index, finished_votes)
		end

		local finished_types = {
			name_id = "menu_pp_sub_place"
		}

		for id, data in pairs(self._reserved_mission_elements) do
			type, index = unpack(data.pack)

			execute_func(type, index, finished_types)
		end

		self._finished_preplan = {
			finished_votes,
			finished_types
		}
		self._executed_reserved_mission_elements = true
	end
end

function PrePlanningManager:get_current_preplan()
	local type, index = nil
	local current_budget, total_budget = self:get_current_budget()
	current_budget = 0
	local location_group_converter = self:_get_location_groups_converter()
	local location_group, category, element = nil

	local function set_func(type, index, peer_id, current_table)
		if not self:is_type_disabled(type) then
			current_budget = current_budget + self:get_type_budget_cost(type)

			if current_budget <= total_budget and current_table then
				element = self._mission_elements_by_type[type] and self._mission_elements_by_type[type][index]

				if element then
					category = self:get_category_by_type(type) or "default"

					table.insert(current_table, {
						category = category,
						type = type,
						peer_id = peer_id
					})
				end
			end
		end
	end

	local current_votes = {
		name_id = "menu_pp_sub_voting"
	}
	local leaders = self:get_current_majority_votes()

	for plan, data in pairs(leaders) do
		type, index = unpack(data)

		set_func(type, index, nil, current_votes)
	end

	local current_types = {
		name_id = "menu_pp_sub_place"
	}

	for id, data in pairs(self._reserved_mission_elements) do
		type, index = unpack(data.pack)

		set_func(type, index, data.peer_id, current_types)
	end

	return current_votes, current_types
end

function PrePlanningManager:_update_majority_votes()
	local local_peer_id = managers.network:session():local_peer():id()
	local vote_council = self:get_vote_council()
	local entry = nil
	local t = {}

	for peer_id, plan_data in pairs(vote_council) do
		for plan, data in pairs(plan_data) do
			entry = tostring(data[1]) .. " " .. tostring(data[2])
			t[plan] = t[plan] or {}
			t[plan][entry] = (t[plan][entry] or 0) + (peer_id == 1 and 1.5 or 1)
		end
	end

	local winners = {}

	for plan, vote_data in pairs(t) do
		local max_votes, winner = nil

		for entry, votes in pairs(vote_data) do
			if not max_votes or max_votes < votes then
				max_votes = votes
				winner = entry
			end
		end

		if winner then
			local type, index = unpack(string.split(winner, " "))

			if type and index then
				winners[plan] = {
					type,
					tonumber(index)
				}
			end
		end
	end

	self._saved_majority_votes = winners

	return self._saved_majority_votes
end

function PrePlanningManager:get_current_majority_votes()
	return self._saved_majority_votes or self:_update_majority_votes()
end

function PrePlanningManager:_update_vote_council()
	local location_data = self:_current_location_data()

	debug_assert(location_data, "[PrePlanningManager:get_majority_voted_elements] Missing location data for level", "level_id", managers.job:current_level_id())

	if not managers.network:session() then
		return
	end

	local local_peer_id = managers.network:session():local_peer():id()
	local peers = {
		local_peer_id
	}

	for peer_id, _ in pairs(managers.network:session():peers()) do
		table.insert(peers, peer_id)
	end

	local vote_council = {}
	local mission_element = nil

	for i, peer_id in ipairs(peers) do
		for plan, type in pairs(location_data.default_plans) do
			mission_element = self:get_default_plan_mission_element(type)

			if mission_element then
				vote_council[peer_id] = vote_council[peer_id] or {}
				vote_council[peer_id][plan] = {
					type,
					1
				}
			end
		end
	end

	for peer_id, data in pairs(self._players_votes) do
		for plan, data in pairs(self._players_votes[peer_id]) do
			vote_council[peer_id] = vote_council[peer_id] or {}
			vote_council[peer_id][plan] = data
		end
	end

	self._saved_vote_council = vote_council

	return self._saved_vote_council
end

function PrePlanningManager:get_vote_council()
	return self._saved_vote_council or self:_update_vote_council()
end

function PrePlanningManager:execute(type, element)
	self:_check_spawn_deployable(type, element)
	self:_check_spawn_unit(type, element)
	element:on_executed(nil, "any")
	element:on_executed(nil, type)
end

function PrePlanningManager:_check_spawn_deployable(type, element)
	local type_data = tweak_data.preplanning.types[type]
	local deployable_id = type_data.deployable_id

	if not deployable_id then
		return
	end

	local pos, rot = element:get_orientation()

	if deployable_id == "doctor_bag" then
		DoctorBagBase.spawn(pos, rot, 0)
	elseif deployable_id == "ammo_bag" then
		AmmoBagBase.spawn(pos, rot, 0)
	elseif deployable_id == "grenade_crate" then
		GrenadeCrateBase.spawn(pos, rot, 0)
	elseif deployable_id == "bodybags_bag" then
		BodyBagsBagBase.spawn(pos, rot, 0)
	end
end

local mvec = Vector3()
local mrot = Rotation()

function PrePlanningManager:_check_spawn_unit(type, element)
	local type_data = tweak_data.preplanning.types[type]
	local unit_name = type_data.spawn_unit

	if not unit_name then
		return
	end

	local params = type_data.spawn_unit_params
	local pos, rot = element:get_orientation()

	mvector3.set(mvec, pos)
	mrotation.set_zero(mrot)
	mrotation.multiply(mrot, rot)

	if params then
		if params.position then
			mvector3.add(mvec, params.position)
		end

		if params.rotation then
			mrotation.multiply(mrot, params.rotation)
		end
	end

	local unit = World:spawn_unit(Idstring(unit_name), mvec, mrot)
end

function PrePlanningManager:can_edit_preplan()
	return not self._finished_preplan
end

function PrePlanningManager:get_finished_preplan()
	return self._finished_preplan
end

function PrePlanningManager:on_simulation_started()
end

function PrePlanningManager:on_simulation_ended()
	self._mission_elements_by_type = {}
	self._reserved_mission_elements = {}
	self._delayed_mission_elements = {}
	self._active_location_groups = {}
	self._players_votes = {}
	self._finished_preplan = nil
	self._saved_majority_votes = nil
	self._saved_vote_council = nil
	self._disabled_types = {}
end

function PrePlanningManager:get_element_types(mission_element)
	local allowed_types = mission_element:value("allowed_types")
end

function PrePlanningManager:get_mission_element_index(id, type)
	if not self._mission_elements_by_type[type] then
		Application:error("[PrePlanningManager:get_mission_element_index] Mission element type do not exist", "type", type, inspect(self._mission_elements_by_type))

		return
	end

	for index, element in ipairs(self._mission_elements_by_type[type]) do
		if element:id() == id then
			return index
		end
	end
end

function PrePlanningManager:get_mission_element_id(type, index)
	return self._mission_elements_by_type[type] and self._mission_elements_by_type[type][index] and self._mission_elements_by_type[type][index]:id()
end

function PrePlanningManager:get_default_plan_mission_element(type)
	if not self._mission_elements_by_type[type] then
		Application:error("[PrePlanningManager:get_default_plan_mission_element] Mission element type do not exist", "type", type, inspect(self._mission_elements_by_type))

		return
	end

	return self._mission_elements_by_type[type][1]
end

function PrePlanningManager:get_element_name(element)
	return managers.localization:text("menu_" .. tostring(element:editor_name()))
end

function PrePlanningManager:get_type_name(type)
	local type_data = tweak_data:get_raw_value("preplanning", "types", type)

	debug_assert(type_data, "[PrePlanningManager:get_type_name] Type do not exist in tweak data!", "type", type)

	local name_id = type_data.name_id

	return name_id and managers.localization:text(name_id) or "MISSING NAME_ID: " .. type
end

function PrePlanningManager:get_type_desc(type)
	local type_data = tweak_data:get_raw_value("preplanning", "types", type)

	debug_assert(type_data, "[PrePlanningManager:get_type_desc] Type do not exist in tweak data!", "type", type)

	local desc_id = type_data.desc_id
	local text_string = desc_id and managers.localization:text(desc_id) or "MISSING NAME_ID: " .. type
	local cost_money = managers.money:get_preplanning_type_cost(type)
	local cost_budget = self:get_type_budget_cost(type)
	text_string = text_string .. "\n"

	if cost_money == 0 and cost_budget == 0 then
		text_string = text_string .. managers.localization:text("menu_pp_free_of_charge")
	else
		text_string = text_string .. managers.localization:text("menu_pp_tooltip_costs", {
			money = managers.experience:cash_string(cost_money),
			budget = cost_budget
		})
	end

	return text_string
end

function PrePlanningManager:get_category_name_by_type(type)
	return self:get_category_name(tweak_data:get_raw_value("preplanning", "types", type, "category"))
end

function PrePlanningManager:get_category_by_type(type)
	return tweak_data:get_raw_value("preplanning", "types", type, "category")
end

function PrePlanningManager:get_category_name(category)
	local category_data = tweak_data:get_raw_value("preplanning", "categories", category)

	debug_assert(category_data, "[PrePlanningManager:get_category_name] Category do not exist in tweak data!", "category", category)

	local name_id = category_data.name_id

	return name_id and managers.localization:text(name_id) or "MISSING NAME_ID: " .. category
end

function PrePlanningManager:get_category_desc(category)
	local category_data = tweak_data:get_raw_value("preplanning", "categories", category)

	debug_assert(category_data, "[PrePlanningManager:get_category_desc] Category do not exist in tweak data!", "category", category)

	local desc_id = category_data.desc_id

	return desc_id and managers.localization:text(desc_id) or "MISSING NAME_ID: " .. tostring(category)
end

function PrePlanningManager:get_location_map_data_by_index(index)
	local location_data = self:_get_location_by_index(index)
	local texture = location_data.texture
	local x = location_data.map_x
	local y = location_data.map_y
	local size = location_data.map_size

	return texture, x, y, size
end

function PrePlanningManager:get_location_shape_by_index(index)
	local location_data = self:_get_location_by_index(index)
	local x1 = location_data.x1
	local x2 = location_data.x2
	local y1 = location_data.y1
	local y2 = location_data.y2

	debug_assert(x1 and x2 and y1 and y2, "[PrePlanningManager:get_location_shape_by_index] Missing GUI data!", "x1", x1, "x2", x2, "y1", y1, "y2", y2, "location_data", inspect(location_data))

	return x1, y1, math.abs(x2 - x1), math.abs(y2 - y1)
end

function PrePlanningManager:get_location_shape_by_group(group)
	for index, location_group in ipairs(tweak_data.preplanning.location_groups) do
		if location_group == group then
			return self:get_location_shape_by_index(index)
		end
	end
end

function PrePlanningManager:num_active_locations()
	local location_data = self:_current_location_data()

	debug_assert(location_data, "[PrePlanningManager:num_active_locations] Missing location data for level", "level_id", managers.job:current_level_id())

	return #location_data
end

function PrePlanningManager:first_location_group()
	return tweak_data.preplanning.location_groups[1]
end

function PrePlanningManager:has_current_level_preplanning()
	return not not self:_current_location_data()
end

function PrePlanningManager:_current_location_data()
	local level_id = managers.job:current_level_id()

	return tweak_data.preplanning.locations[level_id]
end

function PrePlanningManager:current_location_data()
	return self:_current_location_data()
end

function PrePlanningManager:get_location_by_index(index)
	return self:_get_location_by_index(index)
end

function PrePlanningManager:_get_location_by_index(index)
	local current_data = self:_current_location_data()

	debug_assert(current_data, "[PrePlanningManager:_get_location_by_index] No tweak_data for level!", "level_id", managers.job:current_level_id())

	local location_data = current_data[index]

	debug_assert(location_data, "[PrePlanningManager:_get_location_by_index] No location data for level!", "index", index, "level_id", managers.job:current_level_id())

	return location_data
end

function PrePlanningManager:get_location_group_by_index(index)
	local location_data = self:_get_location_by_index(index)
	local location_group = location_data.group

	debug_assert(location_group, "[PrePlanningManager:get_location_group_by_index] No group for location!", "index", index, "level_id", managers.job:current_level_id())

	return location_group
end

function PrePlanningManager:get_location_rotation_by_index(index)
	local location_data = self:_get_location_by_index(index)
	local location_group = location_data.rotation

	return location_group
end

function PrePlanningManager:get_location_name_by_index(index)
	local location_data = self:_get_location_by_index(index)
	local name_id = location_data.name_id

	debug_assert(name_id, "[PrePlanningManager:get_location_name_by_index] No name_id for location!", "index", index, "level_id", managers.job:current_level_id())

	return managers.localization:text(name_id)
end

function PrePlanningManager:has_current_custom_points()
	local current_data = self:_current_location_data()

	debug_assert(current_data, "[PrePlanningManager:get_current_custom_points] No tweak_data for level!", "level_id", managers.job:current_level_id())

	local t = {}

	for i, location in ipairs(current_data) do
		if location.custom_points and table.size(location.custom_points) > 0 then
			return true
		end
	end

	return false
end

function PrePlanningManager:get_current_custom_points()
	local current_data = self:_current_location_data()

	debug_assert(current_data, "[PrePlanningManager:get_current_custom_points] No tweak_data for level!", "level_id", managers.job:current_level_id())

	local t = {}

	for i, location in ipairs(current_data) do
		if location.custom_points then
			t[i] = location.custom_points
		end
	end

	return t
end

function PrePlanningManager:_create_empty_locations_table()
	local locations = {}

	for i = 1, #tweak_data.preplanning.location_groups, 1 do
		table.insert(locations, {})
	end

	return locations
end

function PrePlanningManager:_get_location_groups_converter()
	local location_groups_converter = {}

	for location, group in ipairs(tweak_data.preplanning.location_groups) do
		location_groups_converter[group] = location
	end

	return location_groups_converter
end

function PrePlanningManager:convert_location_group_to_index(group)
	for index, location_group in ipairs(tweak_data.preplanning.location_groups) do
		if location_group == group then
			return index
		end
	end
end

function PrePlanningManager:convert_location_index_to_group(index)
	return tweak_data.preplanning.location_groups[index]
end

function PrePlanningManager:sort_mission_elements_into_locations(mission_elements)
	local location_groups_converter = self:_get_location_groups_converter()
	local locations = {}
	local group, index = nil

	for element_index, element in ipairs(mission_elements) do
		group = element:value("location_group")
		index = location_groups_converter[group]
		locations[index] = locations[index] or {}

		table.insert(locations[index], {
			index = element_index,
			element = element
		})
	end

	return locations
end

function PrePlanningManager:is_type_position_important(type)
	debug_assert(tweak_data.preplanning.types[type], "[PrePlanningManager:is_type_position_important] type do not exist in tweak data!", type)

	return not tweak_data.preplanning.types[type].pos_not_important
end

function PrePlanningManager:get_mission_elements_by_type(type)
	return self._mission_elements_by_type[type]
end

function PrePlanningManager:get_first_type_in_category(category)
	local first_type, first_prio = nil

	for type, _ in pairs(self._mission_elements_by_type) do
		if tweak_data.preplanning.types[type] and tweak_data.preplanning.types[type].category == category and (not first_type or first_prio < (tweak_data.preplanning.types[type].prio or 0) or first_type < type) then
			first_type = type
			first_prio = tweak_data.preplanning.types[type].prio or 0
		end
	end

	return first_type
end

function PrePlanningManager:types_with_mission_elements(optional_category, no_sort)
	local t = {}

	for type, _ in pairs(self._mission_elements_by_type) do
		if not optional_category or (tweak_data.preplanning.types[type].category or default_category) == optional_category then
			table.insert(t, type)
		end
	end

	if not no_sort then
		local location_data = self:_current_location_data()
		local default_plan = optional_category and location_data and location_data.default_plans and location_data.default_plans[optional_category] or false
		local td = tweak_data.preplanning.types
		local x_prio, y_prio = nil

		table.sort(t, function (x, y)
			x_prio = nil
			y_prio = nil

			if default_plan then
				x_prio = default_plan == x and 100
				y_prio = default_plan == y and 100
			end

			x_prio = x_prio or td[x] and td[x].prio or 0
			y_prio = y_prio or td[y] and td[y].prio or 0

			if x_prio ~= y_prio then
				return y_prio < x_prio
			end

			return y < x
		end)
	end

	return t
end

function PrePlanningManager:get_mission_element_subgroups()
	local t = {}
	local plans = {}
	local other = {}
	local category = nil
	local td = tweak_data.preplanning.categories

	for _, type in ipairs(self:types_with_mission_elements(nil, true)) do
		category = tweak_data.preplanning.types[type].category or default_category

		if td[category] and td[category].plan then
			plans[category] = true
		else
			other[category] = true
		end
	end

	local sorted_plans = {}

	for value, _ in pairs(plans) do
		table.insert(sorted_plans, value)
	end

	local x_prio, y_prio = nil

	table.sort(sorted_plans, function (x, y)
		x_prio = td[x] and td[x].prio or 0
		y_prio = td[y] and td[y].prio or 0

		if x_prio ~= y_prio then
			return y_prio < x_prio
		end

		return y < x
	end)

	local sorted_other = {}

	for value, _ in pairs(other) do
		table.insert(sorted_other, value)
	end

	table.sort(sorted_other, function (x, y)
		x_prio = td[x] and td[x].prio or 0
		y_prio = td[y] and td[y].prio or 0

		if x_prio ~= y_prio then
			return y_prio < x_prio
		end

		return y < x
	end)

	return {
		{
			name_id = "menu_pp_sub_voting",
			callback = "open_preplanning_plan_item",
			subgroup = sorted_plans
		},
		{
			name_id = "menu_pp_sub_place",
			callback = "open_preplanning_category_item",
			subgroup = sorted_other
		}
	}
end

function PrePlanningManager:types()
	local t = {}

	for type, _ in pairs(tweak_data.preplanning.types) do
		table.insert(t, type)
	end

	table.sort(t)

	return t
end

function PrePlanningManager:sync_save(data)
	local save_data = {}

	if self._finished_preplan then
		save_data.finished_preplan = self._finished_preplan
	else
		save_data.reserved_mission_elements = self._reserved_mission_elements
		save_data.players_votes = self._players_votes
	end

	managers.menu_component:preplanning_sync_save(save_data)

	data.PrePlanningManager = save_data
end

function PrePlanningManager:sync_load(data)
	if data.PrePlanningManager then
		if data.PrePlanningManager.finished_preplan then
			self._finished_preplan = data.PrePlanningManager.finished_preplan
		else
			self._reserved_mission_elements = data.PrePlanningManager.reserved_mission_elements or {}
			self._players_votes = data.PrePlanningManager.players_votes or {}

			for id, element_data in pairs(self._reserved_mission_elements) do
				local type, index = unpack(element_data.pack)
				local mission_element = self._mission_elements_by_type[type] and self._mission_elements_by_type[type][index]

				if mission_element then
					local disables_types = mission_element:value("disables_types") or {}

					for _, type in ipairs(disables_types) do
						self:_change_disabled_type(type, 1)
					end
				end
			end
		end

		managers.menu_component:preplanning_sync_load(data.PrePlanningManager)
		managers.menu_component:update_preplanning_element(nil, nil)
	end
end
