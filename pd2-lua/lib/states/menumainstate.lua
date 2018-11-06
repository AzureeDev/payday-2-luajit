require("lib/states/GameState")

MenuMainState = MenuMainState or class(GameState)

function MenuMainState:init(game_state_machine)
	GameState.init(self, "menu_main", game_state_machine)
end

function MenuMainState:at_enter(old_state)
	managers.platform:set_playing(false)
	managers.platform:set_rich_presence("Idle")

	if old_state:name() ~= "freeflight" or not managers.menu:is_active() then
		managers.menu_scene:setup_camera()
		managers.menu_scene:set_scene_template("standard")

		self._sound_listener = SoundDevice:create_listener("main_menu")

		self._sound_listener:activate(true)
		managers.menu:open_menu("menu_main")
		managers.music:post_event(managers.music:jukebox_menu_track("mainmenu"))
		managers.menu_scene:post_ambience_event("menu_main_ambience")

		if Global.load_start_menu_lobby then
			if managers.network:session() and (Network:is_server() or managers.network:session():server_peer()) then
				managers.overlay_effect:play_effect({
					sustain = 0.5,
					fade_in = 0,
					blend_mode = "normal",
					fade_out = 0.5,
					color = Color.black
				})
				managers.menu:external_enter_online_menus()
				managers.menu:on_enter_lobby()
			else
				self:on_server_left()
			end
		elseif Global.load_crime_net then
			managers.overlay_effect:play_effect({
				sustain = 0.5,
				fade_in = 0,
				blend_mode = "normal",
				fade_out = 0.5,
				color = Color.black
			})
			managers.menu:open_node("crimenet")

			Global.load_crime_net = false
		elseif Global.load_start_menu then
			managers.overlay_effect:play_effect({
				sustain = 0.25,
				fade_in = 0,
				blend_mode = "normal",
				fade_out = 0.25,
				color = Color.black
			})
		end

		if _G.IS_VR then
			managers.menu:initialize_customization_gui()
		end

		managers.menu:check_vr_dlc()
	end

	local has_invite = false

	if SystemInfo:platform() == Idstring("PS3") or SystemInfo:platform() == Idstring("PS4") then
		local is_boot = not Global.psn_boot_invite_checked and Application:is_booted_from_invitation()

		if not is_boot then
			Global.boot_invite = Global.boot_invite or nil
		else
			Global.boot_invite = {}
		end

		if is_boot or Global.boot_invite and not Global.boot_invite.used then
			has_invite = true
			Global.boot_invite.used = false
			Global.boot_invite.pending = true

			managers.menu:open_sign_in_menu(function (success)
				if success then
					Global.boot_invite = is_boot and PSN:get_boot_invitation() or Global.boot_invite
					Global.boot_invite.used = false
					Global.boot_invite.pending = true

					managers.network.matchmake:join_boot_invite()
				end
			end)
		end

		Global.psn_boot_invite_checked = true
	elseif SystemInfo:platform() == Idstring("WIN32") then
		if SystemInfo:distribution() == Idstring("STEAM") and Global.boot_invite then
			has_invite = true
			local lobby = Global.boot_invite
			Global.boot_invite = nil

			managers.network.matchmake:join_server_with_check(lobby)
		end
	elseif SystemInfo:platform() == Idstring("X360") or SystemInfo:platform() == Idstring("XB1") then
		if XboxLive:has_boot_invite() then
			has_invite = true
		end

		if Global.boot_invite and next(Global.boot_invite) then
			has_invite = true

			managers.network.matchmake:join_boot_invite()
		end
	end

	if Global.open_trial_buy then
		Global.open_trial_buy = nil

		managers.menu:open_node("trial_info")
	elseif not has_invite and not managers.network:session() then
		if managers.statistics:get_play_time() < 300 then
			managers.features:announce_feature("short_heist")
		end

		if not managers.custom_safehouse:unlocked() then
			if not Global.mission_manager.has_played_tutorial and not Global.skip_menu_dialogs then
				local function yes_func()
					MenuCallbackHandler:play_safehouse({
						skip_question = true
					})
				end

				managers.menu:show_question_start_tutorial({
					yes_func = yes_func
				})
			end
		elseif not managers.custom_safehouse:has_entered_safehouse() and not Global.skip_menu_dialogs then
			local function yes_func()
				MenuCallbackHandler:play_single_player()
				MenuCallbackHandler:start_single_player_job({
					difficulty = "normal",
					job_id = "chill"
				})
			end

			if managers.custom_safehouse:is_new_player() then
				managers.menu:show_question_new_safehouse_new_player({
					yes_func = yes_func
				})
			else
				managers.menu:show_question_new_safehouse({
					yes_func = yes_func
				})
			end
		end

		managers.tango:attempt_announce_tango_weapon()

		if managers.crime_spree:was_cleared() then
			managers.crime_spree:show_cleared_dialog()
		end

		managers.promo_unlocks:check_unlocks()
	end

	if Global.savefile_manager.backup_save_enabled then
		managers.savefile:save_progress("local_hdd")
	end

	managers.dyn_resource:set_file_streaming_chunk_size_mul(0.5, 3)
	managers.achievment:check_autounlock_achievements()

	if Global.exe_argument_level then
		MenuCallbackHandler:start_job({
			job_id = Global.exe_argument_level,
			difficulty = Global.exe_argument_difficulty
		})
	end

	managers.statistics:check_stats()
end

function MenuMainState:at_exit(new_state)
	if new_state:name() ~= "freeflight" then
		managers.menu:close_menu("menu_main")
	end

	if self._sound_listener then
		self._sound_listener:delete()

		self._sound_listener = nil
	end
end

function MenuMainState:update(t, dt)
end

function MenuMainState:on_server_left()
	if managers.network:session() and (managers.network:session():has_recieved_ok_to_load_level() or managers.network:session():closing()) then
		return
	end

	self:_create_server_left_dialog()
end

function MenuMainState:_create_server_left_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_warning_title"),
		text = Global.on_server_left_message and managers.localization:text(Global.on_server_left_message) or managers.localization:text("dialog_the_host_has_left_the_game")
	}
	Global.on_server_left_message = nil
	dialog_data.id = "server_left_dialog"
	local ok_button = {
		text = managers.localization:text("dialog_ok"),
		callback_func = callback(self, self, "on_server_left_ok_pressed")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuMainState:on_server_left_ok_pressed()
	print("[MenuMainState:on_server_left_ok_pressed]")
	managers.menu:on_leave_lobby()
end

function MenuMainState:_create_disconnected_dialog()
	managers.system_menu:close("server_left_dialog")
	managers.menu:show_mp_disconnected_internet_dialog({
		ok_func = callback(self, self, "on_server_left_ok_pressed")
	})
end

function MenuMainState:on_disconnected()
end
