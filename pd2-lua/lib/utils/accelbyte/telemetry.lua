require("lib/utils/accelbyte/StatisticsAdaptor")

local json = require("lib/utils/accelbyte/json")
Telemetry = Telemetry or class()
local base_url = Utility:get_telemetry_url()
local telemetry_endpoint = "/game-telemetry/v1/protected/events"
local payload_content_type = "application/json"
local default_event_namespace = Utility:get_telemetry_namespace()
local geolocation_endpoint = "/game-telemetry/v1/protected/location"
local get_playtime_endpoint = "/game-telemetry/v1/protected/steamIds/{steamId}/playtime"
local update_playtime_endpoint = "/game-telemetry/v1/protected/steamIds/{steamId}/playtime/{playtime}"
local send_period = 5
local log_name = "[AccelByte Telemetry]"
local login_retry_limit = 50
local connection_errors = {
	no_conn_error = 1,
	request_timeout = 2,
	unknown_conn_error = 0
}

local function multiline(s)
	if s:sub(-1) ~= "\n" then
		s = s .. "\n"
	end

	return s:gmatch("(.-)\n")
end

local function build_json(event_name, payload, event_namespace)
	event_namespace = event_namespace or default_event_namespace

	if type(payload) ~= "table" then
		error("unexpected payload type, expect \"table\" " .. " got \"" .. type(payload) .. "\"")

		return nil
	end

	local telemetry_body = {
		EventNamespace = event_namespace,
		EventName = event_name,
		Payload = payload or {}
	}
	local telemetry_json = json.encode(telemetry_body)

	return telemetry_json
end

local function build_payload(event_name, payload, event_namespace)
	event_namespace = event_namespace or default_event_namespace

	if type(payload) ~= "table" then
		error("unexpected payload type, expect \"table\" " .. " got \"" .. type(payload) .. "\"")

		return nil
	end

	local telemetry_body = {
		EventNamespace = event_namespace,
		EventName = event_name,
		Payload = payload or {}
	}

	return telemetry_body
end

local function get_platform_name()
	if SystemInfo:platform() == Idstring("X360") then
		return "X360"
	elseif SystemInfo:platform() == Idstring("WIN32") then
		return "WIN32"
	elseif SystemInfo:platform() == Idstring("PS3") then
		return "PS3"
	elseif SystemInfo:platform() == Idstring("XB1") then
		return "XB1"
	elseif SystemInfo:platform() == Idstring("PS4") then
		return "PS4"
	end
end

local function get_distribution()
	if SystemInfo:distribution() == Idstring("STEAM") then
		return "STEAM"
	else
		return "NONE"
	end
end

local function clear_table(t)
	if table.getn(t) == 0 then
		return
	end

	for key, val in pairs(t) do
		t[key] = nil
	end
end

local function telemetry_callback(error_code, status_code, response_body)
	if error_code == connection_errors.no_conn_error then
		if status_code == 204 or status_code == 200 then
			print(log_name, "telemetry sent successfully")
		else
			print(log_name, "problem on telemetry transmission, http status: " .. status_code)
		end
	elseif error_code == connection_errors.request_timeout then
		print(log_name, "problem on telemetry transmission, Request Timed Out")
	else
		print(log_name, "fatal error on transmission, http status: " .. status_code)
	end
end

local function on_total_playtime_retrieved(success, response_body)
	if success then
		local response_json = json.decode(response_body)
		Global.telemetry._total_playtime = response_json.total_playtime

		print(log_name, "Got total playtime")
	else
		Global.telemetry._total_playtime = -1

		print(log_name, "Problem retrieving play time data")
	end

	if Global.telemetry._login_screen_passed == true then
		Telemetry:on_login()
	end
end

local function on_geolocation_retrieved(success, response_body)
	if success then
		Global.telemetry._geolocation = json.decode(response_body)

		print(log_name, "Got gelocation data")
	else
		Global.telemetry._geolocation = "invalid data"

		print(log_name, "Problem retrieving geolocation data")
	end

	if Global.telemetry._login_screen_passed == true then
		Telemetry:on_login()
	end
end

local function on_oldest_achievement_date_retrieved(oldest_achievement_date)
	print(log_name, "Got oldest achievement date")

	Global.telemetry._oldest_achievement_date = oldest_achievement_date

	if Global.telemetry._login_screen_passed == true then
		Telemetry:on_login()
	end
end

local function on_playtime_updated(error_code, status_code, response_body)
	if error_code == connection_errors.no_conn_error then
		if status_code == 200 then
			print(log_name, "playtime updated")
		else
			print(log_name, "problem on playtime update, http status: " .. status_code)
		end
	elseif error_code == connection_errors.request_timeout then
		print(log_name, "problem on playtime update, Request Timed Out")
	else
		print(log_name, "fatal error on playtime update, http status: " .. status_code)
	end
end

local function get_geolocation()
	if get_platform_name() ~= "WIN32" then
		return
	end

	if not Global.telemetry._geolocation then
		local headers = {}
		Global.telemetry._bearer_token = Global.telemetry._bearer_token or Utility:generate_token()
		headers.Authorization = "Bearer " .. Global.telemetry._bearer_token

		Steam:http_request(base_url .. geolocation_endpoint, on_geolocation_retrieved, headers)
	end
end

local function get_total_playtime()
	if get_platform_name() ~= "WIN32" then
		return
	end

	if not Global.telemetry._total_playtime then
		local endpoint = get_playtime_endpoint
		endpoint = endpoint:gsub("%{steamId}", Steam:userid())
		local headers = {}
		Global.telemetry._bearer_token = Global.telemetry._bearer_token or Utility:generate_token()
		headers.Authorization = "Bearer " .. Global.telemetry._bearer_token

		Steam:http_request(base_url .. endpoint, on_total_playtime_retrieved, headers)
	end
end

local function get_oldest_achievement_date()
	if get_platform_name() ~= "WIN32" then
		return
	end

	if not Global.telemetry._oldest_achievement_date then
		managers.achievment:request_oldest_achievement_date(on_oldest_achievement_date_retrieved)
	end
end

local function update_total_playtime(new_playtime)
	local endpoint = update_playtime_endpoint
	endpoint = endpoint:gsub("%{steamId}", Steam:userid())
	endpoint = endpoint:gsub("%{playtime}", tostring(new_playtime))
	local headers = {}
	Global.telemetry._bearer_token = Global.telemetry._bearer_token or Utility:generate_token()
	headers.Authorization = "Bearer " .. Global.telemetry._bearer_token

	Steam:http_request_put(base_url .. endpoint, on_playtime_updated, payload_content_type, "", 0, headers)
end

local function send_telemetry(telemetry_body)
	if get_platform_name() ~= "WIN32" or not Global.telemetry._logged_in then
		return
	end

	if table.getn(telemetry_body) == 0 then
		return
	end

	local telemetry_json = json.encode(telemetry_body)
	local payload_size = string.len(telemetry_json)

	if telemetry_json then
		print(log_name, telemetry_json)

		local headers = {}
		Global.telemetry._bearer_token = Global.telemetry._bearer_token or Utility:generate_token()
		headers.Authorization = "Bearer " .. Global.telemetry._bearer_token

		Steam:http_request_post(base_url .. telemetry_endpoint, telemetry_callback, payload_content_type, telemetry_json, payload_size, headers)
	else
		error("error on JSON encoding, cannot send telemetry")
	end
end

local function gather_player_skill_information()
	if Application:editor() then
		return
	end

	local stats = {}
	local skill_amount = {}
	local skill_data = tweak_data.skilltree.skills
	local tree_data = tweak_data.skilltree.trees

	for tree_index, tree in ipairs(tree_data) do
		if tree.statistics ~= false then
			skill_amount[tree_index] = 0

			for _, tier in ipairs(tree.tiers) do
				for _, skill in ipairs(tier) do
					if skill_data[skill].statistics ~= false then
						local skill_points = managers.skilltree:next_skill_step(skill)
						local skill_bought = skill_points > 1 and 1 or 0
						local skill_aced = skill_points > 2 and 1 or 0
						stats["skill_" .. tree.skill .. "_" .. skill] = skill_bought
						stats["skill_" .. tree.skill .. "_" .. skill .. "_ace"] = skill_aced
						skill_amount[tree_index] = skill_amount[tree_index] + skill_bought + skill_aced
					end
				end
			end
		end
	end

	for tree_index, tree in ipairs(tree_data) do
		if tree.statistics ~= false then
			stats["skill_" .. tree.skill] = skill_amount[tree_index]
		end
	end

	local current_specialization_idx = managers.skilltree:get_specialization_value("current_specialization")
	stats.player_specialization_active = tweak_data.skilltree.specializations[current_specialization_idx].name_id
	stats.player_specialization_tier = managers.skilltree:current_specialization_tier()
	stats.player_specialization_points = managers.skilltree:specialization_points()

	return stats
end

local function gather_or_convert_loadout_data(loadout)
	local _, _, mask_list, weapon_list, melee_list, grenade_list, _, armor_list, character_list, deployable_list, suit_list, _ = tweak_data.statistics:statistics_table()
	local loadout_data = loadout
	loadout_data = loadout_data or managers.statistics:gather_equipment_data()

	if not loadout_data then
		return
	end

	local converted_loadout = StatisticsAdaptor:run(loadout_data)
	converted_loadout.equipped_character = character_list[converted_loadout.equipped_character]
	converted_loadout.equipped_mask = mask_list[converted_loadout.equipped_mask]
	converted_loadout.equipped_grenade = grenade_list[converted_loadout.equipped_grenade]
	converted_loadout.equipped_secondary = weapon_list[converted_loadout.equipped_secondary]
	converted_loadout.equipped_primary = weapon_list[converted_loadout.equipped_primary]
	converted_loadout.equipped_melee = melee_list[converted_loadout.equipped_melee]
	converted_loadout.equipped_suit = suit_list[converted_loadout.equipped_suit]
	converted_loadout.equipped_armor = armor_list[converted_loadout.equipped_armor]
	converted_loadout.equipped_deployable = deployable_list[converted_loadout.equipped_deployable]

	return converted_loadout
end

function Telemetry:init()
	if get_platform_name() ~= "WIN32" then
		return
	end

	if not Global.telemetry then
		Steam:init()

		Global.telemetry = {
			_geolocation = nil,
			_telemetries_to_send_arr = {},
			_session_uuid = nil,
			_enabled = false,
			_start_time = os.time(),
			_mission_payout = 0,
			_last_quickplay_room_id = 0,
			_logged_in = false,
			_total_playtime = nil,
			_login_screen_passed = false,
			_bearer_token = nil,
			_login_inprogress = false,
			_login_retries = 0,
			_oldest_achievement_date = nil
		}

		print(log_name, "Telemetry initiated")
	end

	self._global = Global.telemetry
	self._dt = 0
end

function Telemetry:update(t, dt)
	if get_platform_name() ~= "WIN32" or not self._global._enabled then
		return
	end

	self._dt = self._dt + dt

	if Global.telemetry._login_screen_passed and not self._global._logged_in and send_period < self._dt then
		self._dt = 0

		if not Global.telemetry._login_inprogress and managers.menu:is_open("menu_main") then
			self:on_login()
		end

		if login_retry_limit <= Global.telemetry._login_retries then
			self:enable(false)
		end

		return
	end

	if self._global._logged_in and send_period < self._dt then
		send_telemetry(self._global._telemetries_to_send_arr)
		clear_table(self._global._telemetries_to_send_arr)

		self._dt = 0
	end
end

function Telemetry:enable(is_enable)
	if get_platform_name() ~= "WIN32" then
		return
	end

	self:init()

	self._global._enabled = is_enable

	if is_enable then
		get_geolocation()
		get_total_playtime()
		get_oldest_achievement_date()
	end
end

function Telemetry:set_mission_payout(payout)
	if get_platform_name() ~= "WIN32" or not self._global._logged_in then
		return
	end

	Global.telemetry._mission_payout = payout
end

function Telemetry:last_quickplay_room_id(room_id)
	if get_platform_name() ~= "WIN32" or not self._global._logged_in then
		return
	end

	Global.telemetry._last_quickplay_room_id = room_id
end

function Telemetry:on_login_screen_passed()
	if get_platform_name() ~= "WIN32" then
		return
	end

	Global.telemetry._login_screen_passed = true
end

function Telemetry:send(event_name, payload, event_namespace)
	if get_platform_name() ~= "WIN32" or not self._global._logged_in then
		return
	end

	self:init()

	payload.clientTimestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
	payload.EntityID = Steam:userid()
	local telemetry_body = build_payload(event_name, payload, event_namespace)

	table.insert(self._global._telemetries_to_send_arr, telemetry_body)
end

function Telemetry:send_telemetry_immediately(event_name, payload, event_namespace, callback)
	if get_platform_name() ~= "WIN32" or not self._global._enabled then
		return
	end

	callback = callback or telemetry_callback

	self:init()

	payload.clientTimestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
	payload.EntityID = Steam:userid()
	local telemetry_body = build_payload(event_name, payload, event_namespace)
	local telemetry_json = json.encode(telemetry_body)
	local payload_size = string.len(telemetry_json)

	if telemetry_json then
		print(log_name, telemetry_json)

		local headers = {}
		Global.telemetry._bearer_token = Global.telemetry._bearer_token or Utility:generate_token()
		headers.Authorization = "Bearer " .. Global.telemetry._bearer_token

		Steam:http_request_post(base_url .. telemetry_endpoint, callback, payload_content_type, telemetry_json, payload_size, headers)
	else
		error("error on JSON encoding, cannot send telemetry")
	end
end

function Telemetry:send_batch_immediately()
	if get_platform_name() ~= "WIN32" or not self._global._logged_in then
		return
	end

	send_telemetry(self._global._telemetries_to_send_arr)
	clear_table(self._global._telemetries_to_send_arr)
end

function Telemetry:on_login()
	if get_platform_name() ~= "WIN32" or not self._global._enabled then
		return
	end

	if not Global.telemetry._logged_in and Global.telemetry._geolocation and Global.telemetry._total_playtime ~= nil and Global.telemetry._oldest_achievement_date ~= nil and Global.telemetry._login_retries < login_retry_limit then
		self:send_on_player_logged_in()
	end
end

function Telemetry:send_on_player_logged_in()
	if get_platform_name() ~= "WIN32" or not self._global._enabled then
		return
	end

	self._global._session_uuid = self._global._session_uuid or Utility:generate_uuid()
	local rev = Application:version()

	if Global.revision and Global.revision ~= "" then
		rev = Global.revision
	end

	local total_playtime_hours = nil

	if Global.telemetry._total_playtime ~= -1 then
		total_playtime_hours = math.floor(Global.telemetry._total_playtime / 60)
	end

	local telemetry_payload = {
		Platform = get_distribution(),
		PlatformUserID = Steam:userid(),
		SourceType = "",
		Revision = rev,
		GameSessionGUID = self._global._session_uuid,
		TotalHeistTime = managers.statistics:get_play_time(),
		TotalPlayTime = total_playtime_hours,
		TitleID = Global.dlc_manager.all_dlc_data.full_game.app_id,
		Location = self._global._geolocation,
		OldestAchievement = self._global._oldest_achievement_date,
		PlayerLevel = managers.experience:current_level(),
		InfamyLevel = managers.experience:current_rank()
	}
	local installed_dlc_list = {}

	for _, dlc_data in pairs(Global.dlc_manager.all_dlc_data) do
		if dlc_data.verified and dlc_data.verified == true then
			if dlc_data.app_id and dlc_data.app_id ~= Global.dlc_manager.all_dlc_data.full_game.app_id then
				table.insert(installed_dlc_list, dlc_data.app_id)
			elseif dlc_data.source_id then
				table.insert(installed_dlc_list, dlc_data.source_id)
			end
		end
	end

	telemetry_payload.InstalledDLCs = installed_dlc_list

	local function login_callback(error_code, status_code, response_body)
		if error_code == connection_errors.no_conn_error then
			if status_code == 204 or status_code == 200 then
				print(log_name, "successfully logged in")

				Global.telemetry._logged_in = true
			else
				print(log_name, "problem on login, http status: " .. status_code)
			end
		elseif error_code == connection_errors.request_timeout then
			print(log_name, "problem on login, Request Timed Out")
		else
			print(log_name, "fatal error on login, http status: " .. status_code)
		end

		Global.telemetry._login_inprogress = false
	end

	Global.telemetry._login_inprogress = true
	Global.telemetry._login_retries = Global.telemetry._login_retries + 1

	self:send_telemetry_immediately("player_logged_in", telemetry_payload, nil, login_callback)
end

function Telemetry:send_on_player_economy_event(event_origin, currency, amount, transaction_type)
	if get_platform_name() ~= "WIN32" or not self._global._logged_in then
		return
	end

	local telemetry_payload = {
		Origin = event_origin,
		Currency = currency,
		Amount = amount,
		TransactionType = transaction_type
	}

	self:send("player_economy", telemetry_payload)
end

function Telemetry:send_on_player_logged_out()
	if get_platform_name() ~= "WIN32" or not self._global._logged_in then
		return
	end

	local telemetry_payload = {}
	local play_duration = os.time() - Global.telemetry._start_time
	telemetry_payload.GameSessionGUID = self._global._session_uuid
	telemetry_payload.TimePlayed = play_duration

	if Global.telemetry._total_playtime ~= -1 then
		local total_playtime_minutes = math.floor(Global.telemetry._total_playtime + math.floor(play_duration / 60))

		update_total_playtime(total_playtime_minutes)
	end

	self:send("player_logged_out", telemetry_payload)
end

function Telemetry:on_start_heist()
	if get_platform_name() ~= "WIN32" or not self._global._logged_in then
		return
	end

	if managers.network.matchmake.lobby_handler then
		self._heist_id = managers.network.matchmake.lobby_handler:id()
	else
		self._heist_id = Utility:generate_uuid()
	end

	self._heist_name = "invalid heist name"
	self._map_name = "invalid map name"

	if managers.job:current_level_data() then
		self._heist_name = managers.job:current_job_variant() or managers.job:current_level_data().name_id
		self._map_name = managers.job:current_level_data().world_name
	end

	self._heist_type = "invalid heist type"

	if managers.job:current_stage_data() then
		self._heist_type = managers.job:current_stage_data().type_id
	end

	self:send_on_heist_start()
	self:send_on_player_heist_start()
	self:send_on_player_lobby_setting()
	self:send_batch_immediately()
end

function Telemetry:on_end_heist(end_reason, total_exp_earned)
	if get_platform_name() ~= "WIN32" or not self._global._logged_in then
		return
	end

	if not self._heist_id then
		return
	end

	if game_state_machine:current_state_name() == "kicked" then
		end_reason = "kicked"
	elseif game_state_machine:current_state_name() == "server_left" then
		end_reason = "server_left"
	end

	self._end_reason = end_reason
	self._total_exp_earned = total_exp_earned
	self._heist_duration = select(2, managers.statistics:session_time_played())

	self:send_on_heist_end()
	self:send_on_player_heist_end()
	self:send_batch_immediately()

	self._heist_id = nil
end

function Telemetry:send_on_player_heist_start()
	if get_platform_name() ~= "WIN32" or not self._global._logged_in then
		return
	end

	local job_plan = "any"

	if Global.game_settings.job_plan == 1 then
		job_plan = "loud"
	elseif Global.game_settings.job_plan == 2 then
		job_plan = "stealth"
	end

	local weapon_mods = {}
	local weapon_mods_category = {
		"primary_weapon",
		"secondary_weapon"
	}
	local weapon_categories = {
		"primaries",
		"secondaries"
	}

	for idx, category in pairs(weapon_categories) do
		local slot = BlackMarketManager:equipped_weapon_slot(category)
		local blueprint = managers.blackmarket:get_weapon_blueprint(category, slot)
		local cosmetics = managers.blackmarket:get_weapon_cosmetics(category, slot)
		weapon_mods[weapon_mods_category[idx]] = {}

		for _, mod_name in pairs(blueprint) do
			local mod = tweak_data.weapon.factory.parts[mod_name]

			if mod then
				weapon_mods[weapon_mods_category[idx]][mod.type] = mod_name
			end
		end

		if cosmetics then
			weapon_mods[weapon_mods_category[idx]].cosmetics = cosmetics.id
		end
	end

	if next(weapon_mods) == nil then
		weapon_mods = nil
	end

	local is_quickplay = false

	if managers.network.matchmake.lobby_handler then
		is_quickplay = Global.telemetry._last_quickplay_room_id == managers.network.matchmake.lobby_handler:id()
	end

	local telemetry_payload = {
		MapName = self._map_name,
		HeistName = self._heist_name,
		HeistID = self._heist_id,
		HeistType = self._heist_type,
		ContractorName = managers.job:current_contact_id(),
		QuickPlay = is_quickplay,
		Difficulty = managers.job:current_difficulty_stars(),
		Tactic = job_plan,
		Mods = weapon_mods,
		Loadout = gather_or_convert_loadout_data(),
		Skills = gather_player_skill_information()
	}

	self:send("player_heist_start", telemetry_payload)
end

function Telemetry:send_on_player_heist_end()
	if get_platform_name() ~= "WIN32" or not self._global._logged_in then
		return
	end

	local job_plan = "any"

	if managers.groupai then
		if managers.groupai:state():whisper_mode() then
			job_plan = "stealth"
		else
			job_plan = "loud"
		end
	end

	local telemetry_payload = {
		MapName = self._map_name,
		HeistName = self._heist_name,
		HeistID = self._heist_id,
		HeistEndReason = self._end_reason,
		HeistDuration = self._heist_duration,
		Tactic = job_plan,
		TotalCashEarned = Global.telemetry._mission_payout,
		TotalExpEarned = self._total_exp_earned
	}

	self:send("player_heist_end", telemetry_payload)
end

function Telemetry:send_on_heist_start()
	if get_platform_name() ~= "WIN32" or not self._global._logged_in then
		return
	end

	if not CrimeSpreeManager:_is_host() then
		return
	end

	local player_count = 0

	if managers.network:session() then
		player_count = table.size(managers.network:session():all_peers())
	end

	local telemetry_payload = {
		HeistName = self._heist_name,
		HeistID = self._heist_id,
		HeistType = self._heist_type,
		PlayerCount = player_count
	}

	self:send("heist_start", telemetry_payload)
end

function Telemetry:send_on_heist_end(end_reason)
	if get_platform_name() ~= "WIN32" or not self._global._logged_in then
		return
	end

	if not CrimeSpreeManager:_is_host() then
		return
	end

	local player_count = 0

	if managers.network:session() then
		player_count = table.size(managers.network:session():all_peers())
	end

	local telemetry_payload = {
		HeistName = self._heist_name,
		HeistID = self._heist_id,
		HeistType = self._heist_type,
		EndReason = self._end_reason,
		PlayerCount = player_count,
		HeistDuration = self._heist_duration
	}

	self:send("heist_end", telemetry_payload)
end

function Telemetry:send_on_player_heartbeat()
	if get_platform_name() ~= "WIN32" or not self._global._logged_in then
		return
	end

	local map_name = "invalid map name"

	if managers.menu:active_menu() then
		map_name = managers.menu:active_menu().id
	elseif managers.job:current_level_data() then
		map_name = managers.job:current_level_data().name_id
	end

	local game_mode = Global.game_settings.gamemode

	if managers.skirmish:is_skirmish() then
		game_mode = managers.job:current_level_data().group_ai_state
	end

	local telemetry_payload = {
		MapName = map_name,
		GameMode = game_mode,
		GameState = game_state_machine:current_state_name(),
		GameSessionGUID = self._global._session_uuid,
		PlayerState = managers.player:current_state(),
		PlayerLevel = managers.experience:current_level(),
		InfamyLevel = managers.experience:current_rank()
	}

	self:send("player_heartbeat", telemetry_payload)
end

function Telemetry:send_on_player_tutorial(id)
	if get_platform_name() ~= "WIN32" or not self._global._logged_in then
		return
	end

	local tutorial_name = ""

	if managers.job:current_job_id() then
		if managers.job:current_job_id() ~= "short1" and managers.job:current_job_id() ~= "short2" then
			return
		end

		if managers.job:current_job_id() == "short1" then
			tutorial_name = "FlashDrive"
		elseif managers.job:current_job_id() == "short2" then
			tutorial_name = "GetTheCoke"
		end
	else
		return
	end

	local step = ""

	if managers.job:current_level_id() then
		step = string.sub(managers.job:current_level_id(), 8)
	else
		return
	end

	local telemetry_payload = {
		TutorialName = tutorial_name,
		TutorialStep = step,
		TutorialObjective = id
	}

	self:send("player_tutorial", telemetry_payload)
	self:send_batch_immediately()
end

function Telemetry:send_on_player_lobby_setting()
	if get_platform_name() ~= "WIN32" or not self._global._logged_in then
		return
	end

	local status = ""

	if managers.network.matchmake:get_lobby_data() then
		status = managers.network.matchmake:get_lobby_data().lobby_type
	else
		return
	end

	local telemetry_payload = {
		Status = status
	}

	self:send("player_lobby_setting", telemetry_payload)
end

function Telemetry:send_on_player_change_loadout(loadout)
	if get_platform_name() ~= "WIN32" or not self._global._logged_in then
		return
	end

	local telemetry_payload = {
		Loadout = gather_or_convert_loadout_data(),
		Skills = gather_player_skill_information()
	}

	self:send("player_loadout", telemetry_payload)
end
