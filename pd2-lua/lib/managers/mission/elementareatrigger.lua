core:import("CoreElementArea")
core:import("CoreClass")

ElementAreaTrigger = ElementAreaTrigger or class(CoreElementArea.ElementAreaTrigger)

function ElementAreaTrigger:init(...)
	ElementAreaTrigger.super.init(self, ...)
end

function ElementAreaTrigger:project_instigators()
	local instigators = {}

	if Network:is_client() then
		if self._values.instigator == "player" or self._values.instigator == "local_criminals" or self._values.instigator == "persons" then
			table.insert(instigators, managers.player:player_unit())
		elseif self._values.instigator == "player1" or self._values.instigator == "player2" or self._values.instigator == "player3" or self._values.instigator == "player4" then
			local id = tonumber(string.match(self._values.instigator, "%d$"))

			if managers.network:session() and managers.network:session():local_peer():id() == id then
				table.insert(instigators, managers.player:player_unit())
			end
		elseif self._values.instigator == "vr_player" and _G.IS_VR then
			table.insert(instigators, managers.player:player_unit())
		end

		return instigators
	end

	if self._values.instigator == "player" then
		table.insert(instigators, managers.player:player_unit())
	elseif self._values.instigator == "player_not_in_vehicle" then
		table.insert(instigators, managers.player:player_unit())
	elseif self._values.instigator == "vr_player" and _G.IS_VR then
		table.insert(instigators, managers.player:player_unit())
	elseif self._values.instigator == "vehicle" then
		local vehicles = managers.vehicle:get_all_vehicles()

		for _, v in pairs(vehicles) do
			if not v:npc_vehicle_driving() then
				table.insert(instigators, v)
			end
		end
	elseif self._values.instigator == "npc_vehicle" then
		local vehicles = managers.vehicle:get_all_vehicles()

		for _, v in pairs(vehicles) do
			if v:npc_vehicle_driving() then
				table.insert(instigators, v)
			end
		end
	elseif self._values.instigator == "vehicle_with_players" then
		local vehicles = managers.vehicle:get_all_vehicles()

		for _, v in pairs(vehicles) do
			table.insert(instigators, v)
		end
	elseif self._values.instigator == "enemies" then
		local state = managers.groupai:state()

		if state:police_hostage_count() <= 0 and state:get_amount_enemies_converted_to_criminals() <= 0 then
			for _, data in pairs(managers.enemy:all_enemies()) do
				table.insert(instigators, data.unit)
			end
		else
			for _, data in pairs(managers.enemy:all_enemies()) do
				if not data.unit:anim_data().surrender and not data.is_converted then
					table.insert(instigators, data.unit)
				end
			end
		end
	elseif self._values.instigator == "civilians" then
		for _, data in pairs(managers.enemy:all_civilians()) do
			table.insert(instigators, data.unit)
		end
	elseif self._values.instigator == "escorts" then
		for _, data in pairs(managers.enemy:all_civilians()) do
			if tweak_data.character[data.unit:base()._tweak_table].is_escort then
				table.insert(instigators, data.unit)
			end
		end
	elseif self._values.instigator == "hostages" then
		if managers.groupai:state():police_hostage_count() > 0 then
			for _, data in pairs(managers.enemy:all_enemies()) do
				if data.unit:anim_data().surrender then
					table.insert(instigators, data.unit)
				end
			end
		end

		for _, data in pairs(managers.enemy:all_civilians()) do
			if data.unit:anim_data().tied then
				table.insert(instigators, data.unit)
			end
		end
	elseif self._values.instigator == "intimidated_enemies" then
		local state = managers.groupai:state()

		if state:police_hostage_count() > 0 or state:get_amount_enemies_converted_to_criminals() > 0 then
			for _, data in pairs(managers.enemy:all_enemies()) do
				if data.unit:anim_data().surrender or data.is_converted then
					table.insert(instigators, data.unit)
				end
			end
		end
	elseif self._values.instigator == "criminals" then
		for _, data in pairs(managers.groupai:state():all_char_criminals()) do
			table.insert(instigators, data.unit)
		end
	elseif self._values.instigator == "local_criminals" then
		table.insert(instigators, managers.player:player_unit())

		for _, data in pairs(managers.groupai:state():all_AI_criminals()) do
			table.insert(instigators, data.unit)
		end
	elseif self._values.instigator == "persons" then
		table.insert(instigators, managers.player:player_unit())

		for _, data in pairs(managers.groupai:state():all_char_criminals()) do
			table.insert(instigators, data.unit)
		end

		for _, data in pairs(managers.enemy:all_civilians()) do
			table.insert(instigators, data.unit)
		end

		for _, data in pairs(managers.enemy:all_enemies()) do
			table.insert(instigators, data.unit)
		end
	elseif self._values.instigator == "ai_teammates" then
		for _, data in pairs(managers.groupai:state():all_AI_criminals()) do
			table.insert(instigators, data.unit)
		end
	elseif self._values.instigator == "loot" or self._values.instigator == "unique_loot" then
		local all_found = World:find_units_quick("all", 14)
		local filter_func = nil

		if self._values.instigator == "loot" then
			function filter_func(carry_data)
				local carry_id = carry_data:carry_id()
				local carry_list = {
					"gold",
					"money",
					"coke",
					"coke_pure",
					"sandwich",
					"weapon",
					"painting",
					"circuit",
					"diamonds",
					"meth",
					"lance_bag",
					"lance_bag_large",
					"grenades",
					"engine_01",
					"engine_02",
					"engine_03",
					"engine_04",
					"engine_05",
					"engine_06",
					"engine_07",
					"engine_08",
					"engine_09",
					"engine_10",
					"engine_11",
					"engine_12",
					"ammo",
					"cage_bag",
					"turret",
					"artifact_statue",
					"samurai_suit",
					"equipment_bag",
					"cro_loot1",
					"cro_loot2",
					"ladder_bag",
					"hope_diamond",
					"mus_artifact",
					"mus_artifact_paint",
					"winch_part",
					"winch_part_e3",
					"fireworks",
					"evidence_bag",
					"watertank_empty",
					"watertank_full",
					"warhead",
					"paper_roll",
					"counterfeit_money",
					"unknown",
					"safe_wpn",
					"safe_ovk",
					"nail_muriatic_acid",
					"nail_caustic_soda",
					"nail_hydrogen_chloride",
					"nail_euphadrine_pills",
					"safe_secure_dummy",
					"din_pig",
					"meth_half",
					"parachute",
					"equipment_bag_global_event",
					"prototype",
					"master_server",
					"lost_artifact",
					"breaching_charges",
					"masterpiece_painting",
					"drk_bomb_part",
					"goat",
					"present",
					"mad_master_server_value_1",
					"mad_master_server_value_2",
					"mad_master_server_value_3",
					"mad_master_server_value_4",
					"drk_bomb_part",
					"weapon_glock",
					"weapon_scar",
					"bike_part_light",
					"bike_part_heavy",
					"toothbrush",
					"drone_control_helmet",
					"chl_puck",
					"cloaker_gold",
					"cloaker_money",
					"cloaker_cocaine",
					"robot_toy",
					"ordinary_wine",
					"expensive_vine",
					"women_shoes",
					"vr_headset",
					"diamond_necklace",
					"yayo",
					"rubies",
					"red_diamond",
					"diamonds_dah",
					"old_wine",
					"winch_part_2",
					"winch_part_3",
					"box_unknown_tag",
					"battery",
					"box_unknown",
					"black_tablet",
					"uno_gold",
					"roman_armor",
					"faberge_egg",
					"treasure"
				}

				if table.contains(carry_list, carry_id) then
					return true
				end
			end
		else
			function filter_func(carry_data)
				local carry_id = carry_data:carry_id()

				if tweak_data.carry[carry_id].is_unique_loot then
					return true
				end
			end
		end

		for _, unit in ipairs(all_found) do
			local carry_data = unit:carry_data()

			if carry_data and filter_func(carry_data) then
				table.insert(instigators, unit)
			end
		end
	elseif self._values.instigator == "equipment" then
		if self._values.instigator_name ~= nil then
			local all_found = World:find_units_quick("all", 14)

			local function filter_func(unit)
				if unit:base() and unit:base().get_name_id and unit:base():get_name_id() == self._values.instigator_name then
					return true
				end
			end

			for _, unit in ipairs(all_found) do
				if filter_func(unit) then
					table.insert(instigators, unit)
				end
			end
		end
	elseif self._values.instigator == "player1" or self._values.instigator == "player2" or self._values.instigator == "player3" or self._values.instigator == "player4" and not Global.game_host then
		local id = tonumber(string.match(self._values.instigator, "%d$"))

		if managers.network:session() and managers.network:session():local_peer():id() == id then
			table.insert(instigators, managers.player:player_unit())
		end
	end

	return instigators
end

function ElementAreaTrigger:project_amount_all()
	if self._values.instigator == "criminals" or self._values.instigator == "local_criminals" then
		local i = 0

		for _, data in pairs(managers.groupai:state():all_char_criminals()) do
			i = i + 1
		end

		return i
	elseif self._values.instigator == "ai_teammates" then
		local i = 0

		for _, data in pairs(managers.groupai:state():all_AI_criminals()) do
			i = i + 1
		end

		return i
	end

	return managers.network:session() and managers.network:session():amount_of_alive_players() or 0
end

function ElementAreaTrigger:project_amount_inside()
	local counter = #self._inside

	if self._values.instigator == "vehicle_with_players" then
		for _, instigator in pairs(self._inside) do
			local vehicle = instigator:vehicle_driving()

			if vehicle then
				counter = vehicle:num_players_inside()
			end
		end
	elseif self._values.instigator == "player_not_in_vehicle" then
		counter = 0
		local vehicles = managers.vehicle:get_all_vehicles()

		for _, instigator in pairs(self._inside) do
			local in_vehicle = false

			for _, vehicle in pairs(vehicles) do
				in_vehicle = in_vehicle or vehicle:vehicle_driving():find_seat_for_player(instigator)
			end

			if not in_vehicle then
				counter = counter + 1
			end
		end
	end

	return counter
end

function ElementAreaTrigger:is_instigator_valid(unit)
	if self._values.instigator == "vehicle_with_players" and unit then
		local result = false
		local amount = self._values.amount == "all" and self:project_amount_all()
		amount = amount or tonumber(self._values.amount)
		local inside_vehicle = unit:vehicle_driving():num_players_inside()

		if unit:vehicle_driving() and inside_vehicle > 0 and amount <= inside_vehicle then
			result = true
		end

		return result
	elseif self._values.instigator == "player_not_in_vehicle" then
		local vehicles = managers.vehicle:get_all_vehicles()

		for _, instigator in pairs(self._inside) do
			for _, vehicle in pairs(vehicles) do
				if vehicle:vehicle_driving():find_seat_for_player(instigator) then
					return false
				end
			end
		end
	end

	return true
end

CoreClass.override_class(CoreElementArea.ElementAreaTrigger, ElementAreaTrigger)
