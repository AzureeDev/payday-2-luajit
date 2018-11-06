core:module("PlatformManager")
core:import("CoreEvent")

local empty_vector = Vector3()
local tmp_vector = Vector3()
PlatformManager = PlatformManager or class()
PlatformManager.PLATFORM_CLASS_MAP = {}

function PlatformManager:new(...)
	local platform = SystemInfo:platform()

	return self.PLATFORM_CLASS_MAP[platform:key()] or GenericPlatformManager:new(...)
end

GenericPlatformManager = GenericPlatformManager or class()

function GenericPlatformManager:init()
	self._event_queue_list = {}
	self._event_callback_handler_map = {}
	self._current_presence = "Idle"
	self._current_rich_presence = "Idle"
end

function GenericPlatformManager:event(event_type, ...)
	table.insert(self._event_queue_list, {
		event_type = event_type,
		param_list = {
			...
		}
	})
end

function GenericPlatformManager:destroy_context()
end

function GenericPlatformManager:add_event_callback(event_type, callback_func)
	self._event_callback_handler_map[event_type] = self._event_callback_handler_map[event_type] or CoreEvent.CallbackEventHandler:new()

	self._event_callback_handler_map[event_type]:add(callback_func)
end

function GenericPlatformManager:remove_event_callback(event_type, callback_func)
	assert(event_type and self._event_callback_handler_map[event_type], "Tried to remove non-existing callback on event type \"" .. tostring(event_type) .. "\".")
	self._event_callback_handler_map[event_type]:remove(callback_func)

	if not next(self._event_callback_handler_map[event_type]) then
		self._event_callback_handler_map[event_type] = nil
	end
end

function GenericPlatformManager:update(t, dt)
	if next(self._event_queue_list) then
		for _, event in ipairs(self._event_queue_list) do
			local callback_handler = self._event_callback_handler_map[event.event_type]

			if callback_handler then
				callback_handler:dispatch(unpack(event.param_list))
			end
		end

		self._event_queue_list = {}
	end
end

function GenericPlatformManager:paused_update(t, dt)
	self:update(t, dt)
end

function GenericPlatformManager:set_presence(name)
	self._current_presence = name
end

function GenericPlatformManager:presence()
	return self._current_presence
end

function GenericPlatformManager:set_rich_presence(name)
	self._current_rich_presence = name
end

function GenericPlatformManager:rich_presence()
	return self._current_rich_presence
end

function GenericPlatformManager:translate_path(path)
	return string.gsub(path, "/+([~/]*)", "\\%1")
end

function GenericPlatformManager:set_playing(is_playing)
	Global.game_settings.is_playing = is_playing
end

function GenericPlatformManager:set_progress(progress)
end

function GenericPlatformManager:set_feedback_color(color)
end

Xbox360PlatformManager = Xbox360PlatformManager or class(GenericPlatformManager)
PlatformManager.PLATFORM_CLASS_MAP[_G.Idstring("X360"):key()] = Xbox360PlatformManager

function Xbox360PlatformManager:init()
	GenericPlatformManager.init(self)
	XboxLive:set_callback(callback(self, self, "event"))
end

function Xbox360PlatformManager:destroy_context()
	GenericPlatformManager.destroy_context(self)
	XboxLive:set_callback(nil)
end

function Xbox360PlatformManager:set_rich_presence(name, callback)
	print("Xbox360PlatformManager:set_rich_presence", name)
	GenericPlatformManager.set_rich_presence(self, name)

	if callback then
		XboxLive:set_context("presence", name, callback)
	else
		XboxLive:set_context("presence", name, function ()
		end)
	end
end

function Xbox360PlatformManager:set_presence(name, callback)
	GenericPlatformManager.set_presence(self, name)
end

XB1PlatformManager = XB1PlatformManager or class(GenericPlatformManager)
PlatformManager.PLATFORM_CLASS_MAP[_G.Idstring("XB1"):key()] = XB1PlatformManager

function XB1PlatformManager:init()
	GenericPlatformManager.init(self)
	XboxLive:set_callback(callback(self, self, "event"))
end

function XB1PlatformManager:destroy_context()
	GenericPlatformManager.destroy_context(self)
	XboxLive:set_callback(nil)
end

function XB1PlatformManager:set_rich_presence(name, callback)
	print("XB1PlatformManager:set_rich_presence", name)
	GenericPlatformManager.set_rich_presence(self, name)

	if callback then
		XboxLive:set_context("presence", name, callback)
	else
		XboxLive:set_context("presence", name, function ()
		end)
	end
end

function XB1PlatformManager:set_presence(name, callback)
	GenericPlatformManager.set_presence(self, name)
end

function XB1PlatformManager:set_playing(is_playing)
	if not Global.game_settings.is_playing ~= not is_playing then
		if not Global.game_settings.single_player then
			if managers.network.matchmake._session and is_playing then
				XboxLive:set_mp_begin(managers.network.matchmake._session)
			end

			if not is_playing then
				XboxLive:set_mp_end()
			end
		end

		XB1PlatformManager.super.set_playing(self, is_playing)
	end
end

function XB1PlatformManager:set_progress(progress)
	XboxLive:write_game_progress(progress * 100)
end

PS3PlatformManager = PS3PlatformManager or class(GenericPlatformManager)
PlatformManager.PLATFORM_CLASS_MAP[_G.Idstring("PS3"):key()] = PS3PlatformManager

function PS3PlatformManager:init(...)
	PS3PlatformManager.super.init(self, ...)

	self._current_psn_presence = ""
	self._psn_set_presence_time = 0
end

function PS3PlatformManager:translate_path(path)
	return string.gsub(path, "\\+([~\\]*)", "/%1")
end

function PS3PlatformManager:update(t, dt)
	PS3PlatformManager.super.update(self, t, dt)

	if self._current_psn_presence ~= self:presence() and self._psn_set_presence_time <= t then
		self._psn_set_presence_time = t + 10
		self._current_psn_presence = self:presence()

		print("SET PRESENCE", self._current_psn_presence)
		PSN:set_presence_info(self._current_psn_presence)
	end
end

function PS3PlatformManager:set_presence(name)
	GenericPlatformManager.set_presence(self, name)
end

PS4PlatformManager = PS4PlatformManager or class(GenericPlatformManager)
PlatformManager.PLATFORM_CLASS_MAP[_G.Idstring("PS4"):key()] = PS4PlatformManager

function PS4PlatformManager:init(...)
	PS4PlatformManager.super.init(self, ...)

	self._current_psn_presence = ""
	self._psn_set_presence_time = 0
end

function PS4PlatformManager:destroy_context()
	GenericPlatformManager.destroy_context(self)
	PSN:set_online_callback(nil)
	self:set_feedback_color(nil)
end

function PS4PlatformManager:translate_path(path)
	return string.gsub(path, "\\+([~\\]*)", "/%1")
end

function PS4PlatformManager:update(t, dt)
	PS4PlatformManager.super.update(self, t, dt)

	if self._current_psn_presence ~= self:presence() and self._psn_set_presence_time <= t then
		self._psn_set_presence_time = t + 10
		self._current_psn_presence = self:presence()

		print("SET PRESENCE", self._current_psn_presence)
	end
end

function PS4PlatformManager:set_playing(is_playing)
	if not Global.game_settings.is_playing ~= not is_playing then
		if not Global.game_settings.single_player then
			PSN:set_mp_round(is_playing)
		end

		if not is_playing then
			self:set_feedback_color(nil)
		end

		PS4PlatformManager.super.set_playing(self, is_playing)
	end
end

function PS4PlatformManager:set_presence(name)
	GenericPlatformManager.set_presence(self, name)
end

function PS4PlatformManager:set_rich_presence(name)
	print("PS4PlatformManager:set_rich_presence", name)
	GenericPlatformManager.set_rich_presence(self, name)
	PSN:set_presence_info(managers.localization:text("ps4_presence_" .. name))
end

function PS4PlatformManager:set_feedback_color(color)
	local wrapper_index = managers.controller:get_default_wrapper_index()

	if not wrapper_index then
		return
	end

	local controller_index_list = managers.controller:get_controller_index_list(wrapper_index)

	if not controller_index_list then
		return
	end

	for _, controller_index in ipairs(controller_index_list) do
		local controller = Input:controller(controller_index)

		if controller.type_name == "PS4Controller" then
			if Global.game_settings.is_playing and color and not rawget(_G, "setup"):has_queued_exec() then
				local min_value = 2
				local red = math.max(min_value, 255 * color.red * color.alpha)
				local green = math.max(min_value, 255 * color.green * color.alpha)
				local blue = math.max(min_value, 255 * color.blue * color.alpha)

				mvector3.set_static(tmp_vector, red, green, blue)
				controller:set_color(tmp_vector)
			else
				controller:set_color(empty_vector)
			end
		end
	end
end

WinPlatformManager = WinPlatformManager or class(GenericPlatformManager)
PlatformManager.PLATFORM_CLASS_MAP[_G.Idstring("WIN32"):key()] = WinPlatformManager

function WinPlatformManager:set_rich_presence(name)
	self._current_rich_presence = name

	if SystemInfo:distribution() == Idstring("STEAM") and not Global.game_settings.single_player then
		local presence = ""

		if name == "Idle" then
			Steam:set_rich_presence("status", "")
			Steam:set_rich_presence("steam_display", "")
		else
			if Global.game_settings.permission == "private" then
				Steam:set_rich_presence("status", "")
				Steam:set_rich_presence("steam_display", "")

				return
			end

			local in_lobby = _G.game_state_machine and (_G.game_state_machine:current_state_name() == "ingame_lobby_menu" or _G.game_state_machine:current_state_name() == "menu_main")
			local job_data = managers.job:current_job_data()
			local job_name = job_data and managers.localization:text(job_data.name_id) or "no heist"

			if managers.crime_spree and managers.crime_spree:is_active() then
				local level_id = Global.game_settings.level_id
				local name_id = level_id and _G.tweak_data.levels[level_id] and _G.tweak_data.levels[level_id].name_id

				if name_id then
					job_name = managers.localization:text(name_id) or job_name
				end
			end

			if in_lobby then
				if job_data then
					presence = presence .. managers.localization:text("steam_rp_in_lobby_heist", {
						heist = job_name
					})
				else
					presence = presence .. managers.localization:text("steam_rp_in_lobby")
				end
			elseif job_data then
				if #(managers.job:current_job_chain_data() or {}) > 1 then
					presence = presence .. managers.localization:text("steam_rp_current_heist_multi_day", {
						heist = job_name,
						day = tostring(managers.job:current_stage())
					})
				else
					presence = presence .. managers.localization:text("steam_rp_current_heist_one_day", {
						heist = job_name
					})
				end
			end

			presence = presence .. "\n" .. managers.localization:text("steam_rp_current_players", {
				current = tostring(#managers.network:session():all_peers()),
				max = tostring(_G.tweak_data.max_players)
			})

			if managers.crime_spree and managers.crime_spree:is_active() then
				presence = presence .. "\n" .. managers.localization:text("steam_rp_current_spree", {
					level = managers.experience:cash_string(managers.crime_spree:spree_level(), "")
				})
			elseif managers.job:has_active_job() then
				local difficulty_stars = managers.job:current_difficulty_stars()
				local difficulty = _G.tweak_data.difficulties[managers.job:current_difficulty_stars() + 2] or 1
				presence = presence .. "\n" .. managers.localization:text("steam_rp_current_difficulty", {
					difficulty = managers.localization:to_upper_text(_G.tweak_data.difficulty_name_ids[difficulty])
				})
			end

			Steam:set_rich_presence("status", presence)
			Steam:set_rich_presence("steam_display", "#raw_status")
		end
	end

	self:set_rich_presence_discord(name)
end

function WinPlatformManager:update_discord_party_size()
	if Global.game_settings.permission == "private" then
		return
	end

	local name = self._current_rich_presence

	if name == "MPLobby" or name == "MPPlaying" then
		Discord:set_party_size(managers.network:session():amount_of_players(), 4)
		print("[Discord] update_discord_party_size", managers.network:session():amount_of_players())
	else
		Discord:set_party_size(0, 0)
	end
end

function WinPlatformManager:update_discord_character()
	if Global.game_settings.permission == "private" then
		return
	end

	local character = _G.CriminalsManager.convert_old_to_new_character_workname(managers.blackmarket:get_preferred_character())
	local character_name = managers.localization:text("menu_" .. managers.blackmarket:get_preferred_character())
	local small_image = "c_" .. character

	Discord:set_small_image(small_image, character_name)
	print("[Discord] update_discord_character", small_image, character_name)
end

function WinPlatformManager:update_discord_heist()
	if Global.game_settings.permission == "private" then
		return
	end

	local name = self._current_rich_presence

	if name == "MPLobby" then
		local job_data = managers.job:current_job_data()
		local job_name = job_data and managers.localization:text(job_data.name_id) or "No Heist selected"
		local job_id = job_data and job_data.name_id or "no_briefheist"
		local job_difficulty = _G.tweak_data.difficulties[managers.job:current_difficulty_stars() + 2] or 1
		local job_difficulty_text = managers.localization:to_upper_text(_G.tweak_data.difficulty_name_ids[job_difficulty])

		if job_name == "No Heist selected" then
			job_difficulty_text = "-"
		end

		local day_string = ""

		if #(managers.job:current_job_chain_data() or {}) > 1 then
			day_string = managers.localization:text("discord_rp_day_string", {
				day = tostring(managers.job:current_stage())
			})
		end

		if managers.crime_spree and managers.crime_spree:is_active() then
			local level_id = Global.game_settings.level_id
			local name_id = level_id and _G.tweak_data.levels[level_id] and _G.tweak_data.levels[level_id].name_id

			if name_id then
				job_name = managers.localization:text(name_id) or job_name
			end
		end

		local large_image = job_id

		print("[Discord] update_discord_heist", job_name, large_image)
		Discord:set_status(managers.localization:text("discord_rp_lobby"), managers.localization:text("discord_rp_lobby_details", {
			heist = job_name,
			difficulty = job_difficulty_text,
			day = day_string
		}))
		Discord:set_large_image(large_image, job_name)
	end
end

function WinPlatformManager:set_rich_presence_discord(name)
	Discord:set_status("", "")
	Discord:set_start_time(0)
	Discord:set_large_image("cover", "PAYDAY 2")
	Discord:set_small_image("", "")
	Discord:set_party_size(0, 0)

	if Global.game_settings.permission == "private" then
		return
	end

	local character = _G.CriminalsManager.convert_old_to_new_character_workname(managers.blackmarket:get_preferred_character())
	local character_name = managers.localization:text("menu_" .. managers.blackmarket:get_preferred_character())
	local small_image = "c_" .. character

	Discord:set_small_image(small_image, character_name)

	local in_lobby = _G.game_state_machine and (_G.game_state_machine:current_state_name() == "ingame_lobby_menu" or _G.game_state_machine:current_state_name() == "menu_main")
	local job_data = managers.job:current_job_data()
	local job_name = job_data and managers.localization:text(job_data.name_id) or "No Heist selected"
	local job_id = job_data and job_data.name_id or "no_briefheist"
	local playing = self._current_presence == "Playing" or false
	local job_difficulty = _G.tweak_data.difficulties[managers.job:current_difficulty_stars() + 2] or 1
	local job_difficulty_text = managers.localization:to_upper_text(_G.tweak_data.difficulty_name_ids[job_difficulty])

	if job_name == "No Heist selected" then
		job_difficulty_text = "-"
	end

	local day_string = ""

	if #(managers.job:current_job_chain_data() or {}) > 1 then
		day_string = managers.localization:text("discord_rp_day_string", {
			day = tostring(managers.job:current_stage())
		})
	end

	if managers.crime_spree and managers.crime_spree:is_active() then
		local level_id = Global.game_settings.level_id
		local name_id = level_id and _G.tweak_data.levels[level_id] and _G.tweak_data.levels[level_id].name_id

		if name_id then
			job_name = managers.localization:text(name_id) or job_name
		end
	end

	local large_image = job_id

	print("[Discord] set_rich_presence", name, Application:time())
	print("[Discord] RP data 1/2", self._current_presence, in_lobby, job_name, job_id, day_string)
	print("[Discord] RP data 2/2", large_image, character, character_name, small_image)

	if name == "MPLobby" then
		Discord:set_status(managers.localization:text("discord_rp_lobby"), managers.localization:text("discord_rp_lobby_details", {
			heist = job_name,
			difficulty = job_difficulty_text,
			day = day_string
		}))
		Discord:set_party_size(managers.network:session():amount_of_players(), 4)
		Discord:set_start_time(0)
		Discord:set_large_image(large_image, job_name)
		Discord:set_small_image(small_image, character_name)
	elseif name == "SafeHousePlaying" then
		Discord:set_status(managers.localization:text("discord_rp_safehouse"), managers.localization:text("discord_rp_safehouse_details", {
			heist = job_name
		}))

		if playing then
			Discord:set_start_time_relative(0)
		end
	elseif name == "SPPlaying" then
		Discord:set_status(managers.localization:text("discord_rp_single_heist"), managers.localization:text("discord_rp_single_heist_details", {
			heist = job_name,
			difficulty = job_difficulty_text,
			day = day_string
		}))

		if playing then
			Discord:set_start_time_relative(0)
		end

		Discord:set_large_image(large_image, job_name)
		Discord:set_small_image(small_image, character_name)
	elseif name == "MPPlaying" then
		Discord:set_status(managers.localization:text("discord_rp_mp_heist"), managers.localization:text("discord_rp_mp_heist_details", {
			heist = job_name,
			difficulty = job_difficulty_text,
			day = day_string
		}))
		Discord:set_party_size(managers.network:session():amount_of_players(), 4)

		if playing then
			Discord:set_start_time_relative(0)
		end

		Discord:set_large_image(large_image, job_name)
		Discord:set_small_image(small_image, character_name)
	elseif name == "SPEnd" then
		Discord:set_status(managers.localization:text("discord_rp_single_end"), managers.localization:text("discord_rp_single_end_details", {
			heist = job_name,
			day = day_string
		}))
		Discord:set_start_time(0)
		Discord:set_large_image(large_image, job_name)
		Discord:set_small_image(small_image, character_name)
	elseif name == "MPEnd" then
		Discord:set_status(managers.localization:text("discord_rp_mp_end"), managers.localization:text("discord_rp_mp_end_details", {
			heist = job_name,
			day = day_string
		}))
		Discord:set_start_time(0)
		Discord:set_large_image(large_image, job_name)
		Discord:set_small_image(small_image, character_name)
	end
end
