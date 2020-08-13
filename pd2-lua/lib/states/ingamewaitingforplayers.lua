core:import("CoreUnit")
require("lib/utils/accelbyte/Telemetry")
require("lib/states/GameState")

IngameWaitingForPlayersState = IngameWaitingForPlayersState or class(GameState)
IngameWaitingForPlayersState.GUI_SAFERECT = Idstring("guis/waiting_saferect")
IngameWaitingForPlayersState.GUI_FULLSCREEN = Idstring("guis/waiting_fullscreen")
IngameWaitingForPlayersState.PLAYER_HUD = Idstring("guis/player_hud")
IngameWaitingForPlayersState.PLAYER_DOWNED_HUD = Idstring("guis/player_downed_hud")
IngameWaitingForPlayersState.LEVEL_INTRO_GUI = Idstring("guis/level_intro")

function IngameWaitingForPlayersState:init(game_state_machine)
	GameState.init(self, "ingame_waiting_for_players", game_state_machine)

	self._intro_source = SoundDevice:create_source("intro_source")
	self._start_cb = callback(self, self, "_start")
	self._skip_cb = callback(self, self, "_skip")
	self._controller = nil
end

function IngameWaitingForPlayersState:setup_controller()
	if not self._controller then
		self._controller = managers.controller:create_controller("waiting_for_players", managers.controller:get_default_wrapper_index(), false)
	end

	self._controller:set_enabled(true)
end

function IngameWaitingForPlayersState:set_controller_enabled(enabled)
	if self._controller then
		-- Nothing
	end
end

function IngameWaitingForPlayersState:_skip()
	if not Network:is_server() then
		return
	end

	if not self._audio_started then
		return
	end

	if self._skipped then
		return
	end

	self:sync_skip()
	managers.network:session():send_to_peers_synched("sync_waiting_for_player_skip")
end

function IngameWaitingForPlayersState:sync_skip()
	self:_create_blackscreen_loading_icon()

	self._skipped = true

	managers.briefing:stop_event(true)
	self:_start_delay()
end

function IngameWaitingForPlayersState:_start()
	if not Network:is_server() then
		return
	end

	if managers.preplanning:has_current_level_preplanning() then
		managers.preplanning:execute_reserved_mission_elements()
	end

	managers.assets:check_triggers("asset")

	local variant = managers.groupai:state():blackscreen_variant() or 0

	self:sync_start(variant)
	managers.network:session():send_to_peers_synched("sync_waiting_for_player_start", variant, Global.music_manager.current_track, Global.music_manager.current_music_ext or "")
end

function IngameWaitingForPlayersState:sync_start(variant, soundtrack, music_ext)
	managers.menu_component:disable_mission_briefing_gui()
	self._kit_menu.renderer:set_all_items_enabled(false)

	self._briefing_start_t = nil

	managers.briefing:stop_event()

	Global.music_manager.synced_track = soundtrack

	managers.music:check_music_switch()
	managers.music:post_event(tweak_data.levels:get_music_event("intro"))

	Global.music_manager.synced_music_ext = music_ext ~= "" and music_ext or nil

	managers.music:check_music_ext_ghost()

	if not _G.IS_VR then
		self._fade_out_id = managers.overlay_effect:play_effect(tweak_data.overlay_effects.fade_out_permanent)
	end

	local level_data = Global.level_data.level_id and tweak_data.levels[Global.level_data.level_id]
	self._intro_text_id = level_data and level_data.intro_text_id
	self._intro_event = level_data and (variant == 0 and level_data.intro_event or level_data.intro_event[variant])
	self._blackscreen_started = true

	managers.menu_component:close_asset_mission_briefing_gui()
	managers.preplanning:on_execute_preplanning()
	managers.dyn_resource:set_file_streaming_chunk_size_mul(1, 1)

	if self._intro_event then
		self._delay_audio_t = Application:time() + 1
	else
		self:_start_delay()
	end
end

function IngameWaitingForPlayersState:blackscreen_started()
	return self._blackscreen_started or false
end

function IngameWaitingForPlayersState:_start_audio()
	managers.hud:show(self.LEVEL_INTRO_GUI)
	managers.hud:set_blackscreen_mid_text(self._intro_text_id and managers.localization:text(self._intro_text_id) or "")
	managers.hud:set_blackscreen_job_data()
	managers.hud:blackscreen_fade_in_mid_text()

	self._intro_cue_index = 1
	self._audio_started = true

	managers.menu:close_menu("kit_menu")

	if _G.IS_VR then
		managers.hud:hide(self.GUI_SAFERECT)
		managers.hud:hide(self.GUI_FULLSCREEN)
		managers.menu_component:hide_game_chat_gui()
		managers.menu_component:close_mission_briefing_gui()
		managers.menu_component:kill_preplanning_map_gui()
	end

	local event_started = nil
	local job_data = managers.job:current_job_data()

	if job_data and managers.job:current_job_id() == "safehouse" and Global.mission_manager.saved_job_values.playedSafeHouseBefore then
		-- Nothing
	elseif self._intro_event ~= "---" then
		event_started = managers.briefing:post_event(self._intro_event, {
			show_subtitle = true,
			listener = {
				end_of_event = true,
				clbk = callback(self, self, "_audio_done")
			}
		})
	end

	if not event_started then
		print("failed to start audio, or played safehouse before")
		self:_create_blackscreen_loading_icon()

		if Network:is_server() then
			self:_start_delay()
		end
	end
end

function IngameWaitingForPlayersState:_create_blackscreen_loading_icon()
	if self._fadeout_loading_icon then
		return
	end

	local settings = {
		show_loading_icon = true,
		fade_out = tweak_data.overlay_effects.level_fade_in.fade_out,
		color = tweak_data.overlay_effects.level_fade_in.color
	}
	self._fadeout_loading_icon = FadeoutGuiObject:new(settings)
end

function IngameWaitingForPlayersState:_start_delay()
	if self._delay_start_t then
		return
	end

	self._delay_start_t = Application:time() + 1
end

function IngameWaitingForPlayersState:_audio_done(event_type, label, cookie)
	self:_create_blackscreen_loading_icon()

	if Network:is_server() then
		self:_start_delay()
	end
end

function IngameWaitingForPlayersState:_briefing_callback(event_type, label, cookie)
	print("[IngameWaitingForPlayersState]", "event_type", event_type, "label", label, "cookie", cookie)
	managers.menu_component:set_mission_briefing_description(label)
end

function IngameWaitingForPlayersState:update(t, dt)
	if not managers.network:session() then
		return
	end

	if self._camera_data.next_t < t then
		self:_next_camera()
	end

	if self._briefing_start_t and self._briefing_start_t < t then
		self._briefing_start_t = nil

		if managers.job:has_active_job() then
			local stage_data = managers.job:current_stage_data()
			local level_data = managers.job:current_level_data()
			local briefing_dialog = managers.job:current_briefing_dialog()

			if type(briefing_dialog) == "table" then
				briefing_dialog = briefing_dialog[math.random(#briefing_dialog)]
			end

			local job_data = managers.job:current_job_data()

			if job_data and managers.job:current_job_id() == "safehouse" and Global.mission_manager.saved_job_values.playedSafeHouseBefore then
				-- Nothing
			elseif not managers.menu_component:is_preplanning_enabled() and briefing_dialog ~= "---" then
				managers.briefing:post_event(briefing_dialog, {
					show_subtitle = false,
					listener = {
						marker = false,
						clbk = callback(self, self, "_briefing_callback")
					}
				})
			end
		end
	end

	if self._delay_audio_t and self._delay_audio_t < t then
		self._delay_audio_t = nil

		self:_start_audio()
	end

	if self._delay_start_t then
		if self._file_streamer_max_workload or Network:is_server() and not managers.network:session():are_peers_done_streaming() or not managers.network:session():are_all_peer_assets_loaded() then
			self._delay_start_t = Application:time() + 1
		elseif self._delay_start_t < t then
			self._delay_start_t = nil

			managers.hud:blackscreen_fade_out_mid_text()

			if Network:is_server() then
				self._delay_spawn_t = Application:time() + 1
			end
		end
	end

	if self._delay_spawn_t and self._delay_spawn_t < t then
		self._delay_spawn_t = nil

		managers.network:session():spawn_players()
	end

	local in_foucs = managers.menu:active_menu() == self._kit_menu

	self:_chk_show_skip_prompt()

	if self._skip_promt_shown and Network:is_server() then
		if Global.exe_argument_auto_enter_level then
			managers.hud:blackscreen_skip_circle_done()
			self:_skip()
		elseif self._audio_started and not self._skipped then
			if self._controller then
				local btn_skip_press = self._controller:get_input_bool("confirm")

				if _G.IS_VR then
					btn_skip_press = btn_skip_press or self._controller:get_input_bool("laser_primary")
				end

				if btn_skip_press and not self._skip_data then
					self._skip_data = {
						total = 1,
						current = 0
					}
				elseif not btn_skip_press and self._skip_data then
					self._skip_data = nil

					managers.hud:set_blackscreen_skip_circle(0, 1)
				end
			end

			if self._skip_data then
				self._skip_data.current = self._skip_data.current + dt

				managers.hud:set_blackscreen_skip_circle(self._skip_data.current, self._skip_data.total)

				if self._skip_data.total < self._skip_data.current then
					managers.hud:blackscreen_skip_circle_done()
					self:_skip()
				end
			end
		end
	elseif self._skip_data then
		self._skip_data = nil

		managers.hud:set_blackscreen_skip_circle(0, 1)
	end
end

function IngameWaitingForPlayersState:at_enter()
	if _G.IS_VR then
		managers.menu:open_menu("waiting_for_players")
		managers.overlay_effect:set_hmd_tracking(false)
	end

	self._started_from_beginning = true

	if Global.job_manager.current_job and Global.job_manager.current_job.current_stage == 1 then
		Global.statistics_manager.playing_from_start = true
	end

	self:setup_controller()

	self._sound_listener = SoundDevice:create_listener("lobby_menu")

	self._sound_listener:set_position(Vector3(0, -50000, 0))
	self._sound_listener:activate(true)
	managers.crime_spree:on_mission_started(managers.crime_spree:current_mission())
	managers.crimenet:set_job_played_today(managers.job:current_job_id())
	managers.hud:load_hud_menu(self.GUI_SAFERECT, false, true, true, {})
	managers.hud:show(self.GUI_SAFERECT)
	managers.hud:load_hud_menu(self.GUI_FULLSCREEN, false, true, false, {}, nil, nil, true)
	managers.hud:show(self.GUI_FULLSCREEN)
	managers.hud._hud_mission_briefing:reload()
	managers.hud._hud_mission_briefing:show()

	if not managers.hud:exists(self.PLAYER_HUD) then
		managers.hud:load_hud(self.PLAYER_HUD, false, false, true, {})
	end

	if not managers.hud:exists(self.PLAYER_DOWNED_HUD) then
		managers.hud:load_hud(self.PLAYER_DOWNED_HUD, false, false, true, {})
	end

	if not managers.hud:exists(self.LEVEL_INTRO_GUI) then
		managers.hud:load_hud_menu(self.LEVEL_INTRO_GUI, false, false, true, {})
	end

	managers.menu:close_menu("pause_menu")
	managers.menu:open_menu("kit_menu")

	self._kit_menu = managers.menu:get_menu("kit_menu")

	self:_get_cameras()

	self._cam_unit = CoreUnit.safe_spawn_unit("units/gui/background_camera_01/waiting_camera_01", Vector3(), Rotation())
	self._camera_data = {
		index = 0
	}

	self:_next_camera()

	self._briefing_start_t = Application:time() + 2

	if managers.network:session():is_client() and managers.network:session():server_peer() then
		local local_peer = managers.network:session():local_peer()

		local_peer:sync_lobby_data(managers.network:session():server_peer())
		local_peer:sync_data(managers.network:session():server_peer())
	end

	if managers.job:interupt_stage() and not tweak_data.levels[managers.job:interupt_stage()].bonus_escape then
		managers.menu_component:post_event("escape_menu")
	end

	managers.music:check_music_switch()
	managers.music:post_event(managers.music:jukebox_menu_track("loadout"))
	managers.dyn_resource:set_file_streaming_chunk_size_mul(1, 2)

	local textures_loaded = true

	if TextureCache.check_textures_loaded then
		textures_loaded = TextureCache:check_textures_loaded()
	end

	if managers.dyn_resource:is_file_streamer_idle() and textures_loaded then
		managers.network:session():send_to_peers_loaded("set_member_ready", managers.network:session():local_peer():id(), 100, 2, "")
	else
		self._last_sent_streaming_status = 0
		self._file_streamer_max_workload = 0

		managers.hud:set_blackscreen_loading_text_status(0)
		managers.network:session():send_to_peers_loaded("set_member_ready", managers.network:session():local_peer():id(), 0, 2, "")
		managers.dyn_resource:add_listener(self, {
			DynamicResourceManager.listener_events.file_streamer_workload
		}, callback(self, self, "clbk_file_streamer_status"))
	end

	if Global.game_settings.single_player then
		local is_safe_house = managers.job:current_job_data() and managers.job:current_job_id() == "safehouse"
		local rich_presence = is_safe_house and "SafeHousePlaying" or "SPPlaying"

		managers.platform:set_rich_presence(rich_presence)
	else
		managers.platform:set_rich_presence("MPPlaying")
	end

	if Global.exe_argument_auto_enter_level then
		game_state_machine:current_state():start_game_intro()
	end

	TestAPIHelper.on_event("start_job_loadout")
end

function IngameWaitingForPlayersState:clbk_file_streamer_status(workload)
	if not managers.network:session() then
		self._file_streamer_max_workload = nil

		managers.dyn_resource:remove_listener(self)

		return
	end

	self._file_streamer_max_workload = math.max(self._file_streamer_max_workload, workload)
	local progress = self._file_streamer_max_workload > 0 and 1 - workload / self._file_streamer_max_workload or 1
	progress = math.ceil(progress * 100)

	if progress > 99 and (workload ~= 0 or TextureCache.check_textures_loaded and not TextureCache:check_textures_loaded()) then
		progress = 99
		workload = math.max(workload, 1)
	end

	local local_peer = managers.network:session():local_peer()

	local_peer:set_streaming_status(progress)
	managers.network:session():on_streaming_progress_received(local_peer, progress)
	managers.hud:set_blackscreen_loading_text_status(progress)

	if self._last_sent_streaming_status ~= progress then
		managers.network:session():send_to_peers_loaded("set_member_ready", managers.network:session():local_peer():id(), progress, 2, "")

		self._last_sent_streaming_status = progress
	end

	if workload == 0 then
		self._file_streamer_max_workload = nil

		managers.dyn_resource:remove_listener(self)
	end
end

function IngameWaitingForPlayersState:_chk_show_skip_prompt()
	if not self._skip_promt_shown and not self._file_streamer_max_workload and (not managers.menu:active_menu() or managers.menu:active_menu().name == "waiting_for_players") and managers.network:session() then
		if managers.network:session():are_peers_done_streaming() then
			self._skip_promt_shown = true

			if Network:is_server() then
				managers.hud:set_blackscreen_loading_text_status("allow_skip")
			else
				managers.hud:set_blackscreen_loading_text_status(false)
			end
		else
			managers.hud:set_blackscreen_loading_text_status("wait_for_peers")
		end
	end
end

function IngameWaitingForPlayersState:start_game_intro()
	if self._starting_game_intro then
		return
	end

	self._starting_game_intro = true

	self:_start()
end

function IngameWaitingForPlayersState:set_dropin(char_name)
	self._started_from_beginning = false
end

function IngameWaitingForPlayersState:check_is_dropin()
	return not self._started_from_beginning
end

function IngameWaitingForPlayersState:at_exit(next_state)
	if _G.IS_VR then
		managers.menu:close_menu("waiting_for_players")
	end

	managers.dyn_resource:set_file_streaming_chunk_size_mul(0.25, 5)

	if self._file_streamer_max_workload then
		self._file_streamer_max_workload = nil

		managers.dyn_resource:remove_listener(self)
	end

	managers.briefing:stop_event(true)
	managers.assets:clear_asset_textures()
	managers.menu:close_menu("kit_menu")
	managers.statistics:start_session({
		from_beginning = self._started_from_beginning,
		drop_in = not self._started_from_beginning
	})

	for _, peer in pairs(managers.network:session():all_peers()) do
		peer:set_is_dropin(false)
	end

	managers.hud:hide(self.GUI_SAFERECT)
	managers.hud:hide(self.GUI_FULLSCREEN)
	World:delete_unit(self._cam_unit)
	managers.menu_component:hide_game_chat_gui()
	managers.menu_component:close_mission_briefing_gui()
	managers.menu_component:kill_preplanning_map_gui()
	managers.overlay_effect:play_effect(tweak_data.overlay_effects.level_fade_in)

	if self._fade_out_id then
		managers.overlay_effect:stop_effect(self._fade_out_id)
	end

	if self._sound_listener then
		self._sound_listener:delete()

		self._sound_listener = nil
	end

	managers.hud:hide(self.LEVEL_INTRO_GUI)

	if self._started_from_beginning then
		managers.music:post_event(tweak_data.levels:get_music_event("intro"))
	else
		managers.music:check_music_switch()
		managers.music:check_music_ext_ghost()
	end

	local is_safe_house = managers.job:current_job_data() and managers.job:current_job_id() == "safehouse"
	local rich_presence = nil

	if not game_state_machine:verify_game_state(GameStateFilters.any_ingame, next_state:name()) then
		rich_presence = "Idle"
	elseif is_safe_house then
		rich_presence = "SafeHousePlaying"
	elseif Global.game_settings.single_player then
		rich_presence = "SPPlaying"
	else
		rich_presence = "MPPlaying"
	end

	managers.game_play_central:start_heist_timer()
	managers.platform:set_presence("Playing")
	managers.platform:set_rich_presence(rich_presence)
	managers.platform:set_playing(true)

	if not Network:is_server() and managers.network:session() and managers.network:session():server_peer() then
		managers.network:session():server_peer():verify_job(managers.job:current_job_id())
		managers.network:session():server_peer():verify_character()
	end

	if self._fadeout_loading_icon then
		self._fadeout_loading_icon:fade_out(tweak_data.overlay_effects.level_fade_in.fade_out)

		self._fadeout_loading_icon = nil
	end

	TestAPIHelper.on_event("start_job")
	Telemetry:on_start_heist()
end

function IngameWaitingForPlayersState:_get_cameras()
	self._cameras = {}

	for _, unit in ipairs(managers.helper_unit:get_units_by_type("waiting_camera")) do
		table.insert(self._cameras, {
			pos = unit:position(),
			rot = unit:rotation(),
			nr = math.random(20)
		})
	end

	if #self._cameras == 0 then
		table.insert(self._cameras, {
			pos = Vector3(-196, -496, 851),
			rot = Rotation(90, 0, -0),
			nr = math.random(20)
		})
		table.insert(self._cameras, {
			pos = Vector3(-1897, -349, 365),
			rot = Rotation(0, 0, -0),
			nr = math.random(20)
		})
		table.insert(self._cameras, {
			pos = Vector3(-2593, 552, 386),
			rot = Rotation(-90, 0, 0),
			nr = math.random(20)
		})
	end
end

function IngameWaitingForPlayersState:_next_camera()
	self._camera_data.next_t = Application:time() + 8 + math.rand(4)
	self._camera_data.index = self._camera_data.index + 1

	if self._camera_data.index > #self._cameras then
		self._camera_data.index = 1
	end

	self._cam_unit:set_position(self._cameras[self._camera_data.index].pos)
	self._cam_unit:set_rotation(self._cameras[self._camera_data.index].rot)
	self._cam_unit:camera():start(math.rand(30))
end

function IngameWaitingForPlayersState:on_server_left()
	IngameCleanState.on_server_left(self)
end

function IngameWaitingForPlayersState:on_kicked()
	IngameCleanState.on_kicked(self)
end

function IngameWaitingForPlayersState:on_disconnected()
	IngameCleanState.on_disconnected(self)
end
