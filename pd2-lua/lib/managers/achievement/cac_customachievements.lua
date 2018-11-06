local function init_cac_2()
	local state_changed_key = {}
	local enemy_killed_key = {}
	local kill_count = 0
	local target_count = 20

	local function on_enemy_killed(...)
		kill_count = kill_count + 1

		if kill_count == target_count then
			managers.achievment:award("cac_2")
		end
	end

	local function on_player_state_changed(state_name)
		kill_count = 0

		if state_name == "bipod" then
			managers.player:register_message(Message.OnEnemyKilled, enemy_killed_key, on_enemy_killed)
		else
			managers.player:unregister_message(Message.OnEnemyKilled, enemy_killed_key)
		end
	end

	managers.player:register_message("player_state_changed", state_changed_key, on_player_state_changed)

	local progress_tweak = tweak_data.achievement.visual.cac_2.progress

	function progress_tweak.get()
		return kill_count
	end

	progress_tweak.max = target_count
end

local function init_cac_3()
	local listener_key = {}

	local function on_flash_grenade_destroyed(attacker_unit)
		local local_player = managers.player:player_unit()

		if local_player and attacker_unit == local_player then
			managers.achievment:award_progress("cac_3_stats")
		end
	end

	managers.player:register_message("flash_grenade_destroyed", listener_key, on_flash_grenade_destroyed)
end

local function init_cac_7()
	local listener_key = {}

	local function on_casino_fee_paid(amount)
		managers.achievment:award_progress("cac_7_stats", amount)
	end

	managers.money:add_event_listener(listener_key, "casino_fee_paid", on_casino_fee_paid)
end

local function init_cac_11_34()
	local listener_key = {}

	local function on_cop_converted(converted_unit, converting_unit)
		if not alive(converting_unit) then
			return
		end

		managers.achievment:award_progress("cac_34_stats")

		if converting_unit ~= managers.player:player_unit() then
			return
		end

		local cashier_units = {
			Idstring("units/pd2_dlc_rvd/characters/ene_female_civ_undercover/ene_female_civ_undercover"),
			Idstring("units/pd2_dlc_rvd/characters/ene_female_civ_undercover/ene_female_civ_undercover_husk")
		}
		local is_rvd = managers.job:current_job_id() == "rvd"
		local is_cashier = table.contains(cashier_units, converted_unit:name())

		if is_rvd and is_cashier then
			managers.achievment:award("cac_11")
		end
	end

	managers.player:register_message("cop_converted", listener_key, on_cop_converted)
end

local function init_cac_15()
	local trip_mine_count = 0
	local target_count = 40
	local listener_key = {}

	local function on_trip_mine_placed()
		if not Global.statistics_manager.playing_from_start then
			return
		end

		trip_mine_count = trip_mine_count + 1

		if trip_mine_count == target_count then
			managers.achievment:award("cac_15")
		end
	end

	managers.player:register_message("trip_mine_placed", listener_key, on_trip_mine_placed)
end

local function init_cac_20()
	local masks = {
		"sds_01",
		"sds_02",
		"sds_03",
		"sds_04",
		"sds_05",
		"sds_06",
		"sds_07"
	}

	local function attempt_award()
		for _, mask_id in ipairs(masks) do
			local has_in_inventory = managers.blackmarket:has_item("halloween", "masks", mask_id)
			local has_crafted = managers.blackmarket:get_crafted_item_amount("masks", mask_id) > 0

			if not has_in_inventory and not has_crafted then
				return
			end
		end

		managers.achievment:award("cac_20")
	end

	local listener_key = {}

	local function on_item_added_to_inventory(id)
		if table.contains(masks, id) then
			attempt_award()
		end
	end

	managers.blackmarket:add_event_listener(listener_key, "added_to_inventory", on_item_added_to_inventory)
	managers.savefile:add_load_sequence_done_callback_handler(attempt_award)
end

local function init_cac_28()
	local lobby_listener_key = {}
	local sync_listener_key = {}

	local function attempt_infection(peer)
		local is_infected = managers.achievment.achievments.cac_28.awarded

		if is_infected then
			peer:send_after_load("get_virus_achievement")
		end
	end

	local function on_peer_entered_lobby(peer)
		local local_peer = managers.network:session():local_peer()

		if peer ~= local_peer then
			attempt_infection(peer)
		end
	end

	local function on_peer_added(peer)
		local local_peer = managers.network:session():local_peer()
		local in_lobby = game_state_machine:verify_game_state(GameStateFilters.lobby) and local_peer:in_lobby()

		if peer ~= local_peer and in_lobby then
			attempt_infection(peer)
		end
	end

	local function on_peer_sync_complete(peer)
		local local_peer = managers.network:session():local_peer()

		if peer ~= local_peer then
			attempt_infection(peer)
		end
	end

	managers.network:add_event_listener(lobby_listener_key, "session_peer_entered_lobby", on_peer_entered_lobby)
	managers.network:add_event_listener({}, "session_peer_added", on_peer_added)
	managers.network:add_event_listener(sync_listener_key, "session_peer_sync_complete", on_peer_sync_complete)
end

function AchievmentManager:init_cac_custom_achievements()
	init_cac_2()
	init_cac_3()
	init_cac_7()
	init_cac_11_34()
	init_cac_15()
	init_cac_20()
	init_cac_28()
end
