function MenuManager:show_retrieving_servers_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_retrieving_servers_title"),
		text = managers.localization:text("dialog_wait"),
		id = "find_server",
		no_buttons = true
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_get_world_list_dialog(params)
	local dialog_data = {
		title = managers.localization:text("dialog_logging_in"),
		text = managers.localization:text("dialog_wait"),
		id = "get_world_list"
	}
	local cancel_button = {
		text = managers.localization:text("dialog_cancel"),
		callback_func = params.cancel_func
	}
	dialog_data.button_list = {
		cancel_button
	}
	dialog_data.indicator = true

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_game_permission_changed_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_game_permission_changed")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_too_low_level()
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_too_low_level")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_too_low_level_ovk145()
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_too_low_level_ovk145")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_does_not_own_heist()
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_does_not_own_heist")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_does_not_own_heist_info(heist, player)
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_does_not_own_heist_info", {
			HEIST = string.upper(heist),
			PLAYER = string.upper(player)
		})
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_failed_joining_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_err_failed_joining_lobby")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_smartmatch_contract_not_found_dialog()
	local dialog_data = {
		title = managers.localization:text("menu_smm_contract_not_found_title"),
		text = managers.localization:text("menu_smm_contract_not_found_body")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_smartmatch_inexact_match_dialog(params)
	local dialog_data = {
		id = "confirm_inexact_match",
		title = managers.localization:text("menu_smm_contract_inexact_match_title", {
			timeout = params.timeout
		}),
		text = managers.localization:text("menu_smm_contract_inexact_match_body", {
			host = params.host_name,
			job_name = params.job_name,
			difficulty = params.difficulty
		})
	}
	local yes_button = {
		text = managers.localization:text("dialog_inexact_match_yes"),
		callback_func = params.yes_clbk
	}
	local no_button = {
		text = managers.localization:text("dialog_inexact_match_no"),
		callback_func = params.no_clbk
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}
	dialog_data.focus_button = 1
	local count = params.timeout
	dialog_data.counter = {
		1,
		function ()
			count = count - 1

			if count < 0 then
				params.timeout_clbk()
				managers.system_menu:close(dialog_data.id)
			else
				local dlg = managers.system_menu:get_dialog(dialog_data.id)

				if dlg then
					dlg:set_title(utf8.to_upper(managers.localization:text("menu_smm_contract_inexact_match_title", {
						timeout = count
					})))
				end
			end
		end
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_cant_join_from_game_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_err_cant_join_from_game")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_game_started_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_game_started")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_joining_lobby_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_joining_lobby_title"),
		text = managers.localization:text("dialog_wait"),
		id = "join_server",
		no_buttons = true,
		indicator = true
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_searching_match_dialog(params)
	local cancel_button = {
		cancel_button = true,
		text = managers.localization:text("dialog_cancel"),
		callback_func = params.cancel_func
	}
	local dialog_data = {
		title = managers.localization:text("menu_smm_searching_for_contract"),
		text = managers.localization:text("dialog_wait"),
		id = "search_match",
		button_list = {
			cancel_button
		},
		indicator = true
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_fetching_status_dialog(params)
	local dialog_data = {
		title = managers.localization:text("dialog_fetching_status_title"),
		text = managers.localization:text("dialog_wait"),
		id = "fetching_status",
		indicator = true
	}
	local cancel_button = {
		text = managers.localization:text("dialog_cancel"),
		callback_func = params.cancel_func
	}
	dialog_data.button_list = {
		cancel_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_no_connection_to_game_servers_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_no_connection_to_game_servers")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_person_joining(id, nick)
	local dialog_data = {
		title = managers.localization:text("dialog_dropin_title", {
			USER = string.upper(nick)
		}),
		text = managers.localization:text("dialog_wait") .. " 0%",
		id = "user_dropin" .. id,
		no_buttons = true
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_corrupt_dlc()
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_fail_load_dlc_corrupt")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:close_person_joining(id)
	managers.system_menu:close("user_dropin" .. id)
end

function MenuManager:update_person_joining(id, progress_percentage)
	local dlg = managers.system_menu:get_dialog("user_dropin" .. id)

	if dlg then
		dlg:set_text(managers.localization:text("dialog_wait") .. " " .. tostring(progress_percentage) .. "%")
	end
end

function MenuManager:show_kick_peer_dialog()
end

function MenuManager:show_peer_kicked_dialog(params)
	local title = Global.on_remove_peer_message and "dialog_information_title" or "dialog_mp_kicked_out_title"
	local dialog_data = {
		title = managers.localization:text(title),
		text = managers.localization:text(Global.on_remove_peer_message or "dialog_mp_kicked_out_message")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok"),
		callback_func = params and params.ok_func
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)

	Global.on_remove_peer_message = nil
end

function MenuManager:show_peer_banned_dialog(params)
	local title = "dialog_mp_banned_title"
	local dialog_data = {
		title = managers.localization:text(title),
		text = managers.localization:text("dialog_mp_banned_body")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok"),
		callback_func = params and params.ok_func
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)

	Global.on_remove_peer_message = nil
end

function MenuManager:show_mods_disallowed_dialog(params)
	local title = "dialog_mp_mods_disallowed_title"
	local dialog_data = {
		title = managers.localization:text(title),
		text = managers.localization:text("dialog_mp_mods_disallowed_text")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok"),
		callback_func = params and params.ok_func
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)

	Global.on_remove_peer_message = nil
end

function MenuManager:show_default_option_dialog(params)
	local dialog_data = {
		title = managers.localization:text("dialog_default_options_title"),
		text = params.text
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.callback
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_err_not_signed_in_dialog()
	local dialog_data = {
		title = string.upper(managers.localization:text("dialog_error_title")),
		text = managers.localization:text("dialog_err_not_signed_in"),
		no_upper = true
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok"),
		callback_func = function ()
			self._showing_disconnect_message = nil
		end
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_mp_disconnected_internet_dialog(params)
	local dialog_data = {
		title = string.upper(managers.localization:text("dialog_warning_title")),
		text = managers.localization:text("dialog_mp_disconnected_internet"),
		no_upper = true
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok"),
		callback_func = params.ok_func
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_internet_connection_required()
	local dialog_data = {
		title = string.upper(managers.localization:text("dialog_error_title")),
		text = managers.localization:text("dialog_internet_connection_required"),
		no_upper = true
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_err_no_chat_parental_control()
	if SystemInfo:platform() == Idstring("PS4") then
		PSN:show_chat_parental_control()
	else
		local dialog_data = {
			title = string.upper(managers.localization:text("dialog_information_title")),
			text = managers.localization:text("dialog_no_chat_parental_control"),
			no_upper = true
		}
		local ok_button = {
			text = managers.localization:text("dialog_ok")
		}
		dialog_data.button_list = {
			ok_button
		}

		managers.system_menu:show(dialog_data)
	end
end

function MenuManager:show_err_under_age()
	local dialog_data = {
		title = string.upper(managers.localization:text("dialog_information_title")),
		text = managers.localization:text("dialog_age_restriction"),
		no_upper = true
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_err_new_patch()
	local dialog_data = {
		title = string.upper(managers.localization:text("dialog_information_title")),
		text = managers.localization:text("dialog_new_patch"),
		no_upper = true
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_waiting_for_server_response(params)
	local dialog_data = {
		title = managers.localization:text("dialog_waiting_for_server_response_title"),
		text = managers.localization:text("dialog_wait"),
		id = "waiting_for_server_response",
		indicator = true
	}
	local cancel_button = {
		text = managers.localization:text("dialog_cancel"),
		callback_func = params.cancel_func
	}
	dialog_data.button_list = {
		cancel_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_request_timed_out_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_request_timed_out_title"),
		text = managers.localization:text("dialog_request_timed_out_message")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_restart_game_dialog(params)
	local dialog_data = {
		title = managers.localization:text("dialog_warning_title"),
		text = managers.localization:text("dialog_show_restart_game_message")
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_no_invites_message()
	local dialog_data = {
		title = managers.localization:text("dialog_information_title"),
		text = managers.localization:text("dialog_mp_no_invites_message")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_invite_wrong_version_message()
	local dialog_data = {
		title = managers.localization:text("dialog_information_title"),
		text = managers.localization:text("dialog_mp_invite_wrong_version_message")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_invite_wrong_room_message()
	local dialog_data = {
		title = managers.localization:text("dialog_information_title"),
		text = managers.localization:text("dialog_mp_invite_wrong_room_message")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_invite_join_message(params)
	local dialog_data = {
		title = managers.localization:text("dialog_information_title"),
		text = managers.localization:text("dialog_mp_invite_join_message"),
		id = "invite_join_message"
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok"),
		callback_func = params.ok_func
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_pending_invite_message(params)
	local dialog_data = {
		title = string.upper(managers.localization:text("dialog_information_title")),
		text = managers.localization:text("dialog_mp_pending_invite_short_message"),
		no_upper = true
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok"),
		callback_func = params.ok_func
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_game_is_installing()
	local dialog_data = {
		title = string.upper(managers.localization:text("dialog_information_title")),
		text = managers.localization:text("dialog_game_is_installing"),
		no_upper = true
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_game_is_installing_menu()
	local dialog_data = {
		title = string.upper(managers.localization:text("dialog_information_title")),
		text = managers.localization:text("dialog_game_is_installing_menu"),
		no_upper = true
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_NPCommerce_open_fail(params)
	local dialog_data = {
		title = string.upper(managers.localization:text("dialog_error_title")),
		text = managers.localization:text("dialog_npcommerce_fail_open"),
		no_upper = true
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_NPCommerce_checkout_fail(params)
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_npcommerce_checkout_fail")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_waiting_NPCommerce_open(params)
	local dialog_data = {
		title = managers.localization:text("dialog_wait"),
		text = managers.localization:text("dialog_npcommerce_opening"),
		id = "waiting_for_NPCommerce_open",
		no_upper = true,
		no_buttons = true,
		indicator = true
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_NPCommerce_browse_fail()
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_npcommerce_browse_fail"),
		no_upper = true
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_NPCommerce_browse_success()
	local dialog_data = {
		title = managers.localization:text("dialog_transaction_successful"),
		text = managers.localization:text("dialog_npcommerce_need_install")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_dlc_require_restart()
	if not managers.system_menu:is_active() and not self._shown_dlc_require_restart then
		self._shown_dlc_require_restart = true
		local dialog_data = {
			title = managers.localization:text("dialog_dlc_require_restart"),
			text = managers.localization:text("dialog_dlc_require_restart_desc")
		}
		local ok_button = {
			text = managers.localization:text("dialog_ok")
		}
		dialog_data.button_list = {
			ok_button
		}

		managers.system_menu:show(dialog_data)
	end
end

function MenuManager:show_video_message_dialog(params)
	local text_params = params.text_params or {}
	text_params.player = text_params.player or tostring(managers.network.account:username() or managers.blackmarket:get_preferred_character_real_name())
	local dialog_data = {
		title = managers.localization:text(params.title, params.title_params),
		text = managers.localization:text(params.text, text_params)
	}

	if params.button_list then
		dialog_data.button_list = params.button_list
		dialog_data.focus_button = params.focus_button or #dialog_data.button_list
	else
		local ok_button = {
			text = managers.localization:text("dialog_ok")
		}
		dialog_data.button_list = {
			ok_button
		}
	end

	dialog_data.texture = params.texture == nil and "guis/textures/pd2/feature_crimenet_heat" or params.texture
	dialog_data.video = params.video or nil
	dialog_data.video_loop = params.video_loop or nil
	dialog_data.image_blend_mode = params.image_blend_mode or "normal"
	dialog_data.text_blend_mode = params.text_blend_mode or "add"
	dialog_data.use_text_formating = true
	dialog_data.w = 620
	dialog_data.h = 532
	dialog_data.image_w = 620
	dialog_data.image_h = 300
	dialog_data.image_halign = "center"
	dialog_data.image_valign = "top"
	dialog_data.title_font = tweak_data.menu.pd2_medium_font
	dialog_data.title_font_size = tweak_data.menu.pd2_medium_font_size
	dialog_data.font = tweak_data.menu.pd2_small_font
	dialog_data.font_size = tweak_data.menu.pd2_small_font_size
	dialog_data.text_formating_color = params.formating_color or Color.white
	dialog_data.text_formating_color_table = params.color_table

	managers.system_menu:show_new_unlock(dialog_data)
end

function MenuManager:show_new_message_dialog(params)
	local text_params = params.text_params or {}
	text_params.player = text_params.player or tostring(managers.network.account:username() or managers.blackmarket:get_preferred_character_real_name())
	local dialog_data = {
		title = managers.localization:text(params.title, params.title_params),
		text = managers.localization:text(params.text, text_params)
	}

	if params.button_list then
		dialog_data.button_list = params.button_list
		dialog_data.focus_button = params.focus_button or #dialog_data.button_list
	else
		local ok_button = {
			text = managers.localization:text("dialog_ok")
		}
		dialog_data.button_list = {
			ok_button
		}
	end

	dialog_data.texture = params.texture == nil and "guis/textures/pd2/feature_crimenet_heat" or params.texture
	dialog_data.video = params.video or nil
	dialog_data.video_loop = params.video_loop or nil
	dialog_data.image_blend_mode = params.image_blend_mode or "normal"
	dialog_data.text_blend_mode = params.text_blend_mode or "add"
	dialog_data.use_text_formating = true
	dialog_data.w = 620
	dialog_data.h = 532
	dialog_data.image_w = 64
	dialog_data.image_h = 64
	dialog_data.image_valign = "top"
	dialog_data.title_font = tweak_data.menu.pd2_medium_font
	dialog_data.title_font_size = tweak_data.menu.pd2_medium_font_size
	dialog_data.font = tweak_data.menu.pd2_small_font
	dialog_data.font_size = tweak_data.menu.pd2_small_font_size
	dialog_data.text_formating_color = params.formating_color or Color.white
	dialog_data.text_formating_color_table = params.color_table

	managers.system_menu:show_new_unlock(dialog_data)
end

function MenuManager:show_announce_crimenet_heat()
	local dialog_data = {
		title = managers.localization:text("menu_feature_heat_title"),
		text = managers.localization:text("menu_feature_heat_desc", {
			player = tostring(managers.network.account:username() or managers.blackmarket:get_preferred_character_real_name())
		})
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}
	dialog_data.texture = "guis/textures/pd2/feature_crimenet_heat"
	dialog_data.text_blend_mode = "add"
	dialog_data.use_text_formating = true
	dialog_data.w = 620
	dialog_data.h = 532
	dialog_data.image_w = 64
	dialog_data.image_h = 64
	dialog_data.image_valign = "top"
	dialog_data.title_font = tweak_data.menu.pd2_medium_font
	dialog_data.title_font_size = tweak_data.menu.pd2_medium_font_size
	dialog_data.font = tweak_data.menu.pd2_small_font
	dialog_data.font_size = tweak_data.menu.pd2_small_font_size

	managers.system_menu:show_new_unlock(dialog_data)
end

function MenuManager:show_accept_gfx_settings_dialog(func)
	local count = 10
	local dialog_data = {
		title = managers.localization:text("dialog_accept_changes_title"),
		text = managers.localization:text("dialog_accept_changes", {
			TIME = count
		}),
		id = "accept_changes"
	}
	local cancel_button = {
		text = managers.localization:text("dialog_cancel"),
		callback_func = func,
		cancel_button = true
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button,
		cancel_button
	}
	dialog_data.counter = {
		1,
		function ()
			count = count - 1

			if count < 0 then
				func()
				managers.system_menu:close(dialog_data.id)
			else
				local dlg = managers.system_menu:get_dialog(dialog_data.id)

				if dlg then
					dlg:set_text(managers.localization:text("dialog_accept_changes", {
						TIME = count
					}), true)
				end
			end
		end
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_key_binding_collision(params)
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_key_binding_collision", params)
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_key_binding_forbidden(params)
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_key_binding_forbidden", params)
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_preplanning_help()
	local dialog_data = {
		title = managers.localization:text("dialog_information_title"),
		text = managers.localization:text("dialog_preplanning_help") .. (MenuCallbackHandler.is_win32() and managers.localization:text("dialog_preplanning_help_controller") or "")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}
	dialog_data.w = 620
	dialog_data.h = 532

	managers.system_menu:show_new_unlock(dialog_data)
end

function MenuManager:show_new_item_gained(params)
	local dialog_data = {
		title = managers.localization:text("dialog_new_unlock_title"),
		text = managers.localization:text("dialog_new_unlock_" .. params.category, params)
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}
	local texture, render_template, shapes = nil
	local guis_catalog = "guis/"
	local category = params.data[1]
	local id = params.data[2]

	if category == "weapon_mods" then
		local part_id = id
		local bundle_folder = tweak_data.blackmarket.weapon_mods[part_id] and tweak_data.blackmarket.weapon_mods[part_id].texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		texture = guis_catalog .. "textures/pd2/blackmarket/icons/mods/" .. tostring(part_id)
	elseif category == "colors" then
		local color_tweak_data = _G.tweak_data.blackmarket.colors[id]
		local shape_template = {
			texture = "guis/textures/pd2/blackmarket/icons/colors/color_bg",
			h = 128,
			type = "bitmap",
			w = 128,
			y = 0.5,
			x = 0.5,
			layer = 1,
			color = tweak_data.screen_colors.text
		}
		shapes = {}

		table.insert(shapes, shape_template)

		shape_template = deep_clone(shape_template)
		shape_template.layer = 0
		shape_template.color = color_tweak_data.colors[1]
		shape_template.texture = "guis/textures/pd2/blackmarket/icons/colors/color_01"

		table.insert(shapes, shape_template)

		shape_template = deep_clone(shape_template)
		shape_template.color = color_tweak_data.colors[2]
		shape_template.texture = "guis/textures/pd2/blackmarket/icons/colors/color_02"

		table.insert(shapes, shape_template)
	elseif category == "primaries" or category == "secondaries" then
		local weapon_id = managers.weapon_factory:get_weapon_id_by_factory_id(id)

		if weapon_id then
			texture = managers.blackmarket:get_weapon_icon_path(weapon_id, nil)
		end
	elseif category == "textures" then
		texture = _G.tweak_data.blackmarket.textures[id].texture
		render_template = Idstring("VertexColorTexturedPatterns")
	elseif category ~= "announcements" then
		local bundle_folder = tweak_data.blackmarket[category] and tweak_data.blackmarket[category][id] and tweak_data.blackmarket[category][id].texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		texture = guis_catalog .. "textures/pd2/blackmarket/icons/" .. tostring(category) .. "/" .. tostring(id)
	end

	dialog_data.texture = texture
	dialog_data.render_template = render_template
	dialog_data.shapes = shapes
	dialog_data.sound_event = params.sound_event

	managers.system_menu:show_new_unlock(dialog_data)
end

function MenuManager:show_no_safe_for_this_drill(params)
	local dialog_data = {
		title = managers.localization:text("dialog_no_safe_for_this_drill_title"),
		text = managers.localization:text("dialog_no_safe_for_this_drill")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_and_more_tradable_item_received(params)
	local dialog_data = {
		title = managers.localization:text("dialog_and_more_tradable_item_title"),
		text = managers.localization:text("dialog_and_more_tradable_item", {
			amount = tostring(params.amount_more)
		})
	}
	local ok_button = {
		text = managers.localization:text("dialog_new_tradable_item_accept")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_new_tradable_item_received(params)
	local dialog_data = {
		title = managers.localization:text("dialog_new_tradable_item_title"),
		text = managers.localization:to_upper_text("dialog_new_tradable_item", {
			quality = params.quality_name,
			name = params.item_name
		}),
		focus_button = 1
	}
	local accept_button = {
		text = managers.localization:text("dialog_new_tradable_item_accept"),
		cancel_button = true
	}
	local rarity_color, rarity_bg_texture = nil
	local item = params.item
	dialog_data.button_list = {
		accept_button
	}

	if item.category == "safes" then
		dialog_data.text = managers.localization:to_upper_text("dialog_new_tradable_item", {
			quality = "",
			name = params.item_name
		})
		local data = deep_clone(params)
		local open_container_button = {
			text = managers.localization:text("dialog_new_tradable_item_open_container"),
			callback_func = function ()
				managers.system_menu:force_close_all()
				managers.menu:open_node("inventory_tradable_container", {
					data
				})
			end
		}

		table.insert(dialog_data.button_list, open_container_button)
	elseif item.category == "drills" then
		dialog_data.text = managers.localization:to_upper_text("dialog_new_tradable_item", {
			quality = "",
			name = params.item_name
		})
	else
		if item.category == "armor_skins" then
			dialog_data.text = managers.localization:to_upper_text("dialog_new_tradable_item", {
				quality = "",
				name = params.item_name
			})
		end

		local entry_data = (tweak_data.economy[item.category] or tweak_data.blackmarket[item.category])[item.entry]

		if item.bonus and entry_data.bonus then
			local bonus_tweak = tweak_data.economy.bonuses[entry_data.bonus]
			local name_id = bonus_tweak.name_id
			local bonus_value = bonus_tweak.exp_multiplier and bonus_tweak.exp_multiplier * 100 - 100 .. "%" or bonus_tweak.money_multiplier and bonus_tweak.money_multiplier * 100 - 100 .. "%"
			local bonus_text = managers.localization:to_upper_text("dialog_new_tradable_item_bonus", {
				bonus = managers.localization:text(name_id, {
					team_bonus = bonus_value
				})
			})
			dialog_data.text = dialog_data.text .. "\n" .. bonus_text
		end

		rarity_color = entry_data.rarity and tweak_data.economy.rarities[entry_data.rarity].color or Color.white
		rarity_bg_texture = entry_data.rarity and tweak_data.economy.rarities[entry_data.rarity].bg_texture or nil
	end

	if params.amount_more > 1 then
		local accept_all_button = {
			text = managers.localization:text("dialog_new_tradable_item_accept_all", {
				amount = tostring(params.amount_more)
			}),
			callback_func = function ()
				managers.system_menu:force_close_all()
			end
		}

		table.insert(dialog_data.button_list, accept_all_button)
	end

	local texture, render_template, shapes = nil
	local guis_catalog = "guis/"
	local tweak_group = tweak_data.economy[item.category] or tweak_data.blackmarket[item.category]

	if tweak_group then
		local guis_catalog = "guis/"
		local bundle_folder = tweak_group[item.entry].texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		local path = item.category .. "/"
		texture = guis_catalog .. path .. item.entry
	end

	if rarity_bg_texture then
		dialog_data.textures = {
			rarity_bg_texture,
			texture
		}
	else
		dialog_data.textures = {
			texture
		}
	end

	dialog_data.render_template = render_template
	dialog_data.use_text_formating = true
	dialog_data.text_formating_color = rarity_color
	dialog_data.image_w = 256
	dialog_data.sound_event = params.sound_event

	managers.system_menu:show_new_unlock(dialog_data)
end

function MenuManager:show_mask_mods_available(params)
	local dialog_data = {
		title = "",
		text = params.text_block
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}
	dialog_data.text_blend_mode = "add"
	dialog_data.use_text_formating = true
	dialog_data.text_formating_color = Color.white
	dialog_data.text_formating_color_table = params.color_table

	managers.system_menu:show_new_unlock(dialog_data)
end

function MenuManager:show_weapon_mods_available(params)
	local dialog_data = {
		title = managers.localization:text("bm_menu_available_mods"),
		text = params.text_block
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}
	local weapon_id = params.weapon_id
	dialog_data.texture = managers.blackmarket:get_weapon_icon_path(weapon_id, nil)
	dialog_data.text_blend_mode = "add"
	dialog_data.use_text_formating = true
	dialog_data.text_formating_color = Color.white
	dialog_data.text_formating_color_table = params.color_table

	managers.system_menu:show_new_unlock(dialog_data)
end

function MenuManager:show_confirm_skillpoints(params)
	local dialog_data = {
		title = managers.localization:text("dialog_skills_place_title"),
		text = managers.localization:text(params.text_string, {
			skill = params.skill_name_localized,
			points = params.points,
			remaining_points = params.remaining_points,
			cost = managers.experience:cash_string(params.cost)
		}),
		focus_button = 1
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_confirm_respec_skilltree(params)
	local tree_name = managers.localization:text(tweak_data.skilltree.skilltree[params.tree].name_id)
	local dialog_data = {
		title = managers.localization:text("dialog_skills_respec_title"),
		text = managers.localization:text("dialog_respec_skilltree", {
			tree = tree_name
		}),
		focus_button = 2
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}
	dialog_data.no_upper = true

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_confirm_respec_skilltree_all(params)
	local dialog_data = {
		title = managers.localization:text("dialog_skills_respec_title"),
		text = managers.localization:text("dialog_respec_skilltree_all"),
		focus_button = 2
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}
	dialog_data.no_upper = true

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_skilltree_reseted()
	local dialog_data = {
		title = managers.localization:text("dialog_skills_reseted_title"),
		text = managers.localization:text("dialog_skilltree_reseted")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_confirm_infamypoints(params)
	local dialog_data = {
		title = managers.localization:text("dialog_skills_place_title"),
		text = managers.localization:text(params.text_string, {
			item = params.infamy_item,
			points = params.points,
			remaining_points = params.remaining_points
		}),
		focus_button = 1
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_infamytree_reseted()
	local dialog_data = {
		title = managers.localization:text("dialog_infamy_reseted_title"),
		text = managers.localization:text("dialog_infamysystem_reset")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_confirm_infamy_unlock(params)
	local dialog_data = {
		title = managers.localization:text("menu_infamy_confirm_title"),
		text = managers.localization:text("menu_infamy_confirm_description"),
		focus_button = 1
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_enable_steam_overlay()
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_requires_steam_overlay")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_requires_big_picture()
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_requires_big_picture")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_buying_tradable_item_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_tradable_item_store_title"),
		text = managers.localization:text("dialog_checking_out"),
		id = "buy_tradable_item"
	}
	local cancel_button = {
		text = managers.localization:text("dialog_cancel"),
		callback_func = function ()
			MenuCallbackHandler:on_steam_transaction_over(true)
		end
	}
	dialog_data.button_list = {
		cancel_button
	}
	dialog_data.indicator = true

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_canceled_tradable_item_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_tradable_item_store_title"),
		text = managers.localization:text("dialog_tradable_item_canceled")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_success_tradable_item_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_tradable_item_store_title"),
		text = managers.localization:text("dialog_tradable_item_success")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_enable_steam_overlay_tradable_item()
	local dialog_data = {
		title = managers.localization:text("dialog_tradable_item_store_title"),
		text = managers.localization:text("dialog_requires_steam_overlay_tradable_item")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_error_tradable_item_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_tradable_item_store_title"),
		text = managers.localization:text("dialog_tradable_item_error")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_failed_tradable_item_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_tradable_item_store_title"),
		text = managers.localization:text("dialog_tradable_item_failed")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_accept_drills_to_safes(drills_to_convert, drills_counter)
	local string_list = ""
	local drill_tweak = nil
	local converted_list = {}
	local drill_strings = {}

	for drill, data in pairs(drills_counter) do
		drill_tweak = tweak_data.economy.drills[drill]
		drill_strings[drill] = managers.localization:text(drill_tweak.name_id)

		table.insert(converted_list, drill)
	end

	table.sort(converted_list, function (x, y)
		return drill_strings[x] < drill_strings[y]
	end)

	for index, drill in ipairs(converted_list) do
		drill_tweak = tweak_data.economy.drills[drill]
		string_list = string_list .. "   " .. managers.localization:text("dialog_tradable_drill_amount", {
			amount = tostring(drills_counter[drill]),
			item = drill_strings[drill]
		}) .. "\n"
	end

	local dialog_data = {
		drills_to_convert = drills_to_convert,
		title = managers.localization:text("dialog_tradable_item_store_title"),
		text = managers.localization:text("dialog_tradable_drills_converted", {
			list = string_list
		})
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show_drillconvert(dialog_data)
end

function MenuManager:show_confirm_blackmarket_sell_no_slot(params)
	local dialog_data = {
		title = managers.localization:text("dialog_bm_mask_sell_title"),
		text = managers.localization:text("dialog_blackmarket_item", {
			item = params.name
		}) .. "\n\n" .. managers.localization:text("dialog_blackmarket_slot_item_sell", {
			money = params.money
		}),
		focus_button = 2
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_confirm_blackmarket_mask_remove(params)
	local dialog_data = {
		title = managers.localization:text("dialog_bm_crafted_sell_title"),
		text = managers.localization:text("dialog_blackmarket_slot_item", {
			slot = params.slot,
			item = params.name
		}) .. "\n\n" .. managers.localization:text("dialog_blackmarket_slot_mask_remove", {
			suffix = params.skip_money and "" or " " .. managers.localization:text("dialog_blackmarket_slot_mask_remove_suffix", {
				money = params.money
			})
		})
	}

	if params.mods_readded and #params.mods_readded > 0 then
		dialog_data.text = dialog_data.text .. "\n"

		for _, mod_id in ipairs(params.mods_readded) do
			dialog_data.text = dialog_data.text .. "\n" .. managers.localization:text("dialog_blackmarket_mask_sell_mod_readded", {
				mod = mod_id
			})
		end
	end

	dialog_data.focus_button = 2
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_confirm_blackmarket_mask_sell(params)
	local dialog_data = {
		title = managers.localization:text("dialog_bm_crafted_sell_title"),
		text = managers.localization:text("dialog_blackmarket_slot_item", {
			slot = params.slot,
			item = params.name
		}) .. "\n\n" .. managers.localization:text("dialog_blackmarket_slot_item_sell", {
			money = params.money
		})
	}

	if params.mods_readded and #params.mods_readded > 0 then
		dialog_data.text = dialog_data.text .. "\n"

		for _, mod_id in ipairs(params.mods_readded) do
			dialog_data.text = dialog_data.text .. "\n" .. managers.localization:text("dialog_blackmarket_mask_sell_mod_readded", {
				mod = mod_id
			})
		end
	end

	dialog_data.focus_button = 2
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_confirm_blackmarket_sell(params)
	local dialog_data = {
		title = managers.localization:text("dialog_bm_crafted_sell_title"),
		text = managers.localization:text("dialog_blackmarket_slot_item", {
			slot = params.slot,
			item = params.name
		}) .. "\n\n" .. managers.localization:text("dialog_blackmarket_slot_item_sell", {
			money = params.money
		}),
		focus_button = 2
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_confirm_blackmarket_buy_weapon_slot(params)
	local dialog_data = {
		title = managers.localization:text("dialog_bm_weapon_buy_title"),
		text = managers.localization:text("dialog_blackmarket_buy_weapon_slot", {
			money = params.money
		}),
		focus_button = 2
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_confirm_blackmarket_buy_mask_slot(params)
	local dialog_data = {
		title = managers.localization:text("dialog_bm_weapon_buy_title"),
		text = managers.localization:text("dialog_blackmarket_buy_mask_slot", {
			money = params.money
		}),
		focus_button = 2
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_confirm_blackmarket_buy(params)
	local num_in_inventory = ""
	local num_of_same = managers.blackmarket:get_crafted_item_amount(params.category, params.weapon)

	if num_of_same > 0 then
		num_in_inventory = managers.localization:text("dialog_blackmarket_num_in_inventory", {
			item = params.name,
			amount = num_of_same
		})
	end

	local dialog_data = {
		title = managers.localization:text("dialog_bm_weapon_buy_title"),
		text = managers.localization:text("dialog_blackmarket_buy_item", {
			item = params.name,
			money = params.money,
			num_in_inventory = num_in_inventory
		}),
		focus_button = 2
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_confirm_blackmarket_mod(params)
	local l_local = managers.localization
	local dialog_data = {
		focus_button = 2,
		title = l_local:text("dialog_bm_weapon_modify_title"),
		text = l_local:text("dialog_blackmarket_slot_item", {
			slot = params.slot,
			item = params.weapon_name
		}) .. "\n\n" .. l_local:text("dialog_blackmarket_mod_" .. (params.add and "add" or "remove"), {
			mod = params.name
		}) .. "\n"
	}
	local warn_lost_mods = false

	if params.add and params.replaces and #params.replaces > 0 then
		dialog_data.text = dialog_data.text .. l_local:text("dialog_blackmarket_mod_replace", {
			mod = managers.weapon_factory:get_part_name_by_part_id(params.replaces[1])
		}) .. "\n"
		warn_lost_mods = true
	end

	if params.removes and #params.removes > 0 then
		local mods = ""

		for _, mod_name in ipairs(params.removes) do
			if Application:production_build() and managers.weapon_factory:is_part_standard_issue(mod_name) then
				Application:error("[MenuManager:show_confirm_blackmarket_mod] Standard Issuse Part Detected!", inspect(params))
			end

			mods = mods .. "\n" .. managers.weapon_factory:get_part_name_by_part_id(mod_name)
		end

		dialog_data.text = dialog_data.text .. "\n" .. l_local:text("dialog_blackmarket_mod_conflict", {
			mods = mods
		}) .. "\n"
		warn_lost_mods = true
	end

	if not params.ignore_lost_mods and (warn_lost_mods or not params.add) then
		dialog_data.text = dialog_data.text .. "\n" .. l_local:text("dialog_blackmarket_lost_mods_warning")
	end

	if params.add and params.money then
		dialog_data.text = dialog_data.text .. "\n" .. l_local:text("dialog_blackmarket_mod_cost", {
			money = params.money
		})
	end

	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_confirm_weapon_cosmetics(params)
	local l_local = managers.localization
	local dialog_data = {
		type = "weapon_stats",
		focus_button = 2,
		title = l_local:text("dialog_bm_weapon_modify_title"),
		text = l_local:text("dialog_blackmarket_slot_item", {
			slot = params.slot,
			item = params.weapon_name
		}) .. "\n\n" .. l_local:text("dialog_weapon_cosmetics_" .. (params.item_has_cosmetic and "add" or "remove"), {
			cosmetic = params.name
		})
	}

	if params.item_has_cosmetic and params.crafted_has_cosmetic then
		dialog_data.text = dialog_data.text .. "\n" .. l_local:text("dialog_weapon_cosmetics_replace", {
			cosmetic = params.crafted_name
		})
	end

	if params.crafted_has_default_blueprint and not params.item_has_default_blueprint then
		dialog_data.text = dialog_data.text .. "\n\n" .. l_local:text("dialog_weapon_cosmetics_remove_blueprint")
	elseif not params.crafted_has_default_blueprint and params.item_has_default_blueprint then
		dialog_data.text = dialog_data.text .. "\n\n" .. l_local:text("dialog_weapon_cosmetics_set_blueprint")
	end

	if params.customize_locked then
		dialog_data.text = dialog_data.text .. "\n\n" .. l_local:text("dialog_weapon_cosmetics_locked")
	end

	local yes_button = {
		text = managers.localization:text("dialog_apply"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_confirm_blackmarket_assemble(params)
	local num_in_inventory = ""
	local num_of_same = managers.blackmarket:get_crafted_item_amount(params.category, params.weapon)

	if num_of_same > 0 then
		num_in_inventory = managers.localization:text("dialog_blackmarket_num_in_inventory", {
			item = params.name,
			amount = num_of_same
		})
	end

	local dialog_data = {
		title = managers.localization:text("dialog_bm_mask_assemble_title"),
		text = managers.localization:text("dialog_blackmarket_assemble_item", {
			item = params.name,
			num_in_inventory = num_in_inventory
		}),
		focus_button = 2
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_confirm_blackmarket_abort(params)
	local dialog_data = {
		title = managers.localization:text("dialog_bm_mask_custom_abort"),
		text = managers.localization:text("dialog_blackmarket_abort_mask_warning"),
		focus_button = 2
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_confirm_blackmarket_finalize(params)
	local dialog_data = {
		title = managers.localization:text("dialog_bm_mask_custom_final_title"),
		text = managers.localization:text("dialog_blackmarket_finalize_item", {
			money = params.money,
			ITEM = managers.localization:text("dialog_blackmarket_slot_item", {
				item = params.name,
				slot = params.slot
			})
		}),
		focus_button = 2
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_confirm_blackmarket_weapon_mod_purchase(params)
	local dialog_data = {
		title = managers.localization:text("dialog_bm_crafted_sell_title"),
		text = managers.localization:text("dialog_bm_purchase_mod", {
			slot = params.slot,
			item = params.name
		}) .. "\n\n" .. managers.localization:text("dialog_bm_purchase_coins", {
			money = params.money
		}),
		focus_button = 2
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_confirm_mission_asset_buy(params)
	local asset_tweak_data = managers.assets:get_asset_tweak_data_by_id(params.asset_id)
	local dialog_data = {
		title = managers.localization:text("dialog_assets_buy_title"),
		text = managers.localization:text("dialog_mission_asset_buy", {
			asset_desc = managers.localization:text(asset_tweak_data.unlock_desc_id or "menu_asset_unknown_unlock_desc"),
			cost = managers.experience:cash_string(managers.money:get_mission_asset_cost_by_id(params.asset_id))
		}),
		focus_button = 2
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_confirm_preplanning_rebuy(params)
	local dialog_data = {
		title = managers.localization:text("menu_item_preplanning_rebuy"),
		text = "",
		text_formating_color_table = {},
		use_text_formating = true,
		w = 600
	}
	local red = tweak_data.screen_colors.important_1
	local grey = tweak_data.screen_color_grey
	local total_money_cost = 0
	local total_favor_cost = 0

	for _, plan in pairs(params.votes) do
		local category_text = utf8.to_upper(managers.preplanning:get_category_name_by_type(plan.type))
		local location_text = managers.preplanning:get_element_name_by_type_index(plan.type, plan.index)
		local name_text = managers.preplanning:get_type_name(plan.type)
		local cost_text = managers.preplanning:get_type_cost_text(plan.type)
		dialog_data.text = dialog_data.text .. category_text .. "\n"
		dialog_data.text = dialog_data.text .. "  -" .. name_text

		if not string.match(location_text, "ERROR") then
			dialog_data.text = dialog_data.text .. " - " .. location_text
		end

		dialog_data.text = dialog_data.text .. " (" .. cost_text .. ") \n \n"
		total_money_cost = total_money_cost + managers.preplanning:get_type_cost(plan.type)
		total_favor_cost = total_favor_cost + managers.preplanning:get_type_budget_cost(plan.type)
	end

	local category_list = {}

	for _, asset in ipairs(params.rebuy_assets) do
		local cat_name = utf8.to_upper(managers.preplanning:get_category_name_by_type(asset.type))
		local create_new_category = true

		for _, category in ipairs(category_list) do
			if cat_name == category.category then
				table.insert(category.assets, {
					type = asset.type,
					id = asset.id,
					index = asset.index
				})

				create_new_category = false
			end
		end

		if create_new_category then
			table.insert(category_list, {
				category = cat_name,
				assets = {
					{
						type = asset.type,
						id = asset.id,
						index = asset.index
					}
				}
			})
		end
	end

	for _, category in ipairs(category_list) do
		dialog_data.text = dialog_data.text .. category.category .. " \n"

		for _, asset in ipairs(category.assets) do
			local money_cost = managers.preplanning:get_type_cost(asset.type)
			local favor_cost = managers.preplanning:get_type_budget_cost(asset.type)
			local td = managers.preplanning:get_tweak_data_by_type(asset.type)
			local name_text = managers.preplanning:get_type_name(asset.type)
			local cost_text = managers.preplanning:get_type_cost_text(asset.type)
			local location_text = managers.preplanning:get_element_name_by_type_index(asset.type, asset.index)
			local can_unlock = true

			if td.dlc_lock then
				can_unlock = can_unlock and managers.dlc:is_dlc_unlocked(td.dlc_lock)
			end

			if td.upgrade_lock then
				can_unlock = can_unlock and managers.player:has_category_upgrade(td.upgrade_lock.category, td.upgrade_lock.upgrade)
			end

			if not can_unlock then
				table.insert(dialog_data.text_formating_color_table, grey)

				dialog_data.text = dialog_data.text .. "##"
			else
				total_money_cost = total_money_cost + money_cost
				total_favor_cost = total_favor_cost + favor_cost
			end

			dialog_data.text = dialog_data.text .. "   -" .. name_text

			if not string.match("ERROR", location_text) then
				dialog_data.text = dialog_data.text .. " - " .. location_text
			end

			dialog_data.text = dialog_data.text .. " (" .. cost_text .. ")"

			if td.upgrade_lock and not can_unlock then
				dialog_data.text = dialog_data.text .. "##"

				table.insert(dialog_data.text_formating_color_table, red)

				dialog_data.text = dialog_data.text .. " " .. managers.localization:text("menu_asset_buy_all_req_skill")
			elseif td.dlc_lock and not can_unlock then
				dialog_data.text = dialog_data.text .. "##"

				table.insert(dialog_data.text_formating_color_table, red)

				dialog_data.text = dialog_data.text .. " " .. managers.localization:text("menu_asset_buy_all_req_dlc", {
					dlc = managers.localization:text(self:get_dlc_by_id(td.dlc_lock).name_id)
				})
			end

			dialog_data.text = dialog_data.text .. "\n"
		end
	end

	dialog_data.text = dialog_data.text .. "\n"

	if total_money_cost < managers.money:total() then
		dialog_data.text = dialog_data.text .. managers.localization:text("dialog_preplanning_rebuy_assets", {
			price = managers.experience:cash_string(total_money_cost),
			favor = total_favor_cost
		})
		local yes_button = {
			text = managers.localization:text("dialog_yes"),
			callback_func = params.yes_func
		}
		local no_button = {
			cancel_button = true,
			text = managers.localization:text("dialog_no")
		}
		dialog_data.focus_button = 2
		dialog_data.button_list = {
			yes_button,
			no_button
		}
	else
		dialog_data.text = dialog_data.text .. "##" .. managers.localization:text("bm_menu_not_enough_cash") .. "##"

		table.insert(dialog_data.text_formating_color_table, red)

		local ok_button = {
			text = managers.localization:text("dialog_ok"),
			cancel_button = true
		}
		dialog_data.focus_button = 1
		dialog_data.button_list = {
			ok_button
		}
	end

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_confirm_mission_asset_buy_all(params)
	local dialog_data = {
		title = managers.localization:to_upper_text("menu_asset_buy_all"),
		text = "",
		text_formating_color_table = {},
		use_text_formating = true
	}
	local total_cost = 0

	for _, asset_id in ipairs(params.locked_asset_ids) do
		local td = managers.assets:get_asset_tweak_data_by_id(asset_id)
		local cost = managers.money:get_mission_asset_cost_by_id(asset_id)
		local can_unlock = managers.assets:get_asset_can_unlock_by_id(asset_id)

		if not can_unlock then
			dialog_data.text = dialog_data.text .. "##"

			table.insert(dialog_data.text_formating_color_table, tweak_data.screen_colors.achievement_grey)
			table.insert(dialog_data.text_formating_color_table, tweak_data.screen_colors.important_1)
		end

		dialog_data.text = dialog_data.text .. "-" .. managers.localization:text(td.name_id) .. " (" .. managers.experience:cash_string(cost) .. ")"

		if td.upgrade_lock and not can_unlock then
			dialog_data.text = dialog_data.text .. "##  " .. managers.localization:text("menu_asset_buy_all_req_skill") .. "\n"
		elseif td.dlc_lock and not can_unlock then
			dialog_data.text = dialog_data.text .. "##  " .. managers.localization:text("menu_asset_buy_all_req_dlc", {
				dlc = managers.localization:text(self:get_dlc_by_id(td.dlc_lock).name_id)
			}) .. "\n"
		else
			total_cost = total_cost + cost
			dialog_data.text = dialog_data.text .. "\n"
		end
	end

	if total_cost ~= 0 then
		dialog_data.text = dialog_data.text .. "\n" .. managers.localization:text("menu_asset_buy_all_desc", {
			price = managers.experience:cash_string(total_cost)
		})
		local yes_button = {
			text = managers.localization:text("dialog_yes"),
			callback_func = params.yes_func
		}
		local no_button = {
			text = managers.localization:text("dialog_no"),
			callback_func = params.no_func,
			cancel_button = true
		}
		dialog_data.focus_button = 2
		dialog_data.button_list = {
			yes_button,
			no_button
		}
	else
		dialog_data.text = dialog_data.text .. "\n" .. managers.localization:text("menu_asset_buy_all_fail")
		local ok_button = {
			text = managers.localization:text("dialog_ok"),
			callback_func = params.ok_func,
			cancel_button = true
		}
		dialog_data.focus_button = 1
		dialog_data.button_list = {
			ok_button
		}
	end

	managers.system_menu:show(dialog_data)
end

function MenuManager:get_dlc_by_id(dlc_id)
	for _, dlc in ipairs(tweak_data.gui.content_updates.item_list) do
		if dlc.id == dlc_id then
			return dlc
		end
	end

	return "Failed to get DLC"
end

function MenuManager:show_confirm_buy_premium_contract(params)
	local dialog_data = {
		title = managers.localization:text("dialog_premium_buy_title"),
		text = managers.localization:text("menu_cn_premium_buy_fee", {
			contract_fee = params.contract_fee,
			offshore = params.offshore
		}),
		focus_button = 2
	}
	local yes_button = {
		text = managers.localization:text("menu_cn_premium_buy_accept"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_confirm_pay_casino_fee(params)
	local dialog_data = {
		title = managers.localization:text("dialog_casino_pay_title"),
		text = managers.localization:text("menu_cn_casino_pay_fee", {
			contract_fee = params.contract_fee,
			offshore = params.offshore
		}),
		focus_button = 2
	}
	local yes_button = {
		text = managers.localization:text("menu_cn_casino_pay_accept"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_accept_crime_net_job(params)
	local dialog_data = {
		title = params.title,
		text = params.player_text .. "\n\n" .. params.desc,
		focus_button = 1
	}
	local yes_button = {
		text = managers.localization:text("dialog_accept"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_storage_removed_dialog(params)
	local dialog_data = {
		title = managers.localization:text("dialog_warning_title"),
		text = managers.localization:text("dialog_storage_removed_warning_X360"),
		force = true
	}
	local ok_button = {
		text = managers.localization:text("dialog_continue")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show_platform(dialog_data)
end

function MenuManager:show_game_is_full(params)
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_err_room_is_full")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_game_no_longer_exists(params)
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_err_room_no_longer_exists")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_game_is_full(params)
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_err_room_is_full")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_wrong_version_message()
	local dialog_data = {
		title = managers.localization:text("dialog_information_title"),
		text = managers.localization:text("dialog_err_wrong_version_message")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_inactive_user_accepted_invite(params)
	local dialog_data = {
		title = managers.localization:text("dialog_information_title"),
		text = managers.localization:text("dialog_inactive_user_accepted_invite_error"),
		id = "inactive_user_accepted_invite"
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok"),
		callback_func = params.ok_func
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_question_start_tutorial(params)
	local dialog_data = {
		focus_button = 1,
		title = managers.localization:text("dialog_safehouse_title"),
		text = managers.localization:text("dialog_safehouse_text")
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no")
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_question_new_safehouse(params)
	local dialog_data = {
		focus_button = 1,
		title = managers.localization:text("dialog_new_safehouse_title"),
		text = managers.localization:text("dialog_new_safehouse")
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no")
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_question_new_safehouse_new_player(params)
	local dialog_data = {
		focus_button = 1,
		title = "dialog_new_safehouse_title",
		text = "dialog_new_safehouse_new_player",
		texture = false
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no")
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}
	dialog_data.video = "movies/new_safehouse"

	managers.menu:show_video_message_dialog(dialog_data)
end

function MenuManager:show_question_start_short_heist(params)
	local dialog_data = {
		focus_button = 1,
		title = managers.localization:text("dialog_short_heist_title"),
		text = managers.localization:text("dialog_short_heist_text")
	}
	local yes_button = {
		text = managers.localization:text("dialog_short_heist_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_short_heist_no"),
		callback_func = params.no_func
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_leave_safehouse_dialog(params)
	local dialog_data = {
		title = managers.localization:text("dialog_safehouse_title"),
		text = managers.localization:text("dialog_are_you_sure_you_want_to_leave_game")
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no")
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_save_settings_failed(params)
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_save_settings_failed")
	}
	local ok_button = {
		text = managers.localization:text("dialog_continue")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_play_safehouse_question(params)
	local dialog_data = {
		focus_button = 1,
		title = managers.localization:text("dialog_safehouse_title"),
		text = managers.localization:text("dialog_safehouse_goto_text")
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		cancel_button = true,
		text = managers.localization:text("dialog_no")
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_savefile_wrong_version(params)
	local dialog_data = {
		title = managers.localization:text("dialog_information_title"),
		text = managers.localization:text(params.error_msg),
		id = "wrong_version"
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:add_init_show(dialog_data)
end

function MenuManager:show_savefile_wrong_user(params)
	local dialog_data = {
		title = managers.localization:text("dialog_information_title"),
		text = managers.localization:text("dialog_load_wrong_user"),
		id = "wrong_user"
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:add_init_show(dialog_data)
end

function MenuManager:show_account_picker_dialog(params)
	local dialog_data = {
		title = managers.localization:text("dialog_warning_title"),
		text = managers.localization:text("dialog_account_picker")
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_abort_mission_dialog(params)
	local dialog_data = {
		title = managers.localization:text("dialog_warning_title"),
		text = managers.localization:text("dialog_abort_mission_text")
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_safe_error_dialog(params)
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text(params.string_id)
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok"),
		callback_func = params.ok_button
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_confirm_become_infamous(params)
	local dialog_data = {
		title = managers.localization:text("dialog_become_infamous")
	}
	local no_button = {
		callback_func = params.no_func,
		cancel_button = true
	}

	if params.yes_func then
		no_button.text = managers.localization:text("dialog_no")
		local yes_button = {
			text = managers.localization:text("dialog_yes"),
			callback_func = params.yes_func
		}
		dialog_data.text = managers.localization:text(managers.experience:current_rank() < 5 and "menu_dialog_become_infamous_3" or "menu_dialog_become_infamous_3_above_5", {
			level = 100,
			cash = params.cost
		})
		dialog_data.focus_button = 2
		dialog_data.button_list = {
			yes_button,
			no_button
		}
		local got_usable_primary_weapon = managers.blackmarket:check_will_have_free_slot("primaries")
		local got_usable_secondary_weapon = managers.blackmarket:check_will_have_free_slot("secondaries")
		local add_weapon_replace_warning = not got_usable_primary_weapon or not got_usable_secondary_weapon

		if add_weapon_replace_warning then
			local primary_weapon = managers.blackmarket:get_crafted_category_slot("primaries", 1)
			local secondary_weapon = managers.blackmarket:get_crafted_category_slot("secondaries", 1)
			local warning_text_id = "menu_dialog_warning_infamy_replace_pri_sec"

			if got_usable_primary_weapon then
				warning_text_id = "menu_dialog_warning_infamy_replace_secondary"
			elseif got_usable_secondary_weapon then
				warning_text_id = "menu_dialog_warning_infamy_replace_primary"
			end

			local params = {
				primary = primary_weapon and managers.localization:to_upper_text(tweak_data.weapon[primary_weapon.weapon_id].name_id),
				secondary = secondary_weapon and managers.localization:to_upper_text(tweak_data.weapon[secondary_weapon.weapon_id].name_id),
				amcar = managers.localization:to_upper_text(tweak_data.weapon.amcar.name_id),
				glock_17 = managers.localization:to_upper_text(tweak_data.weapon.glock_17.name_id)
			}
			dialog_data.text = dialog_data.text .. "\n\n" .. managers.localization:text(warning_text_id, params)
		end
	else
		no_button.text = managers.localization:text("dialog_ok")
		dialog_data.text = managers.localization:text("menu_dialog_become_infamous_no_cash", {
			cash = params.cost
		})
		dialog_data.focus_button = 1
		dialog_data.button_list = {
			no_button
		}
	end

	dialog_data.w = 620
	dialog_data.h = 500

	managers.system_menu:show_new_unlock(dialog_data)
end

function MenuManager:show_specialization_xp_convert(xp_present, points_present)
	local dialog_data = {
		title = managers.localization:text("dialog_xp_to_specialization"),
		xp_present = xp_present,
		points_present = points_present
	}
	local no_button = {
		cancel_button = true,
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.focus_button = 1
	dialog_data.button_list = {
		no_button
	}

	managers.system_menu:show_specialization_convert(dialog_data)
end

function MenuManager:show_infamous_message(can_become_infamous)
	local dialog_data = {
		title = managers.localization:text("dialog_infamous_info_title")
	}
	local no_button = {
		cancel_button = true,
		text = managers.localization:text("dialog_ok")
	}

	if can_become_infamous then
		dialog_data.text = managers.localization:text("dialog_can_become_infamous_desc", {
			become_infamous_menu_item = managers.localization:to_upper_text("menu_become_infamous")
		})
	else
		local infamous_cost = managers.money:get_infamous_cost(managers.experience:current_rank() + 1)
		dialog_data.text = managers.localization:text("dialog_infamous_info_desc", {
			level = 100,
			cash = managers.experience:cash_string(infamous_cost)
		})
	end

	dialog_data.focus_button = 1
	dialog_data.button_list = {
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:dialog_gage_assignment_completed(params)
	params = {
		player = params.player or tostring(managers.network.account:username() or managers.blackmarket:get_preferred_character_real_name()),
		time = params.time or Application:date("%H:%M"),
		date = params.date or Application:date("%Y-%m-%d"),
		completed = params.completed or ""
	}
	local dialog_data = {
		title = managers.localization:text("dialog_gage_assignment_completed_title"),
		text = managers.localization:text("dialog_gage_assignment_completed", params)
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}
	dialog_data.texture = "guis/textures/pd2/feature_crimenet_heat"
	dialog_data.text_blend_mode = "add"
	dialog_data.use_text_formating = true
	dialog_data.w = 620
	dialog_data.h = 532
	dialog_data.image_w = 64
	dialog_data.image_h = 64
	dialog_data.image_valign = "top"
	dialog_data.title_font = tweak_data.menu.pd2_medium_font
	dialog_data.title_font_size = tweak_data.menu.pd2_medium_font_size
	dialog_data.font = tweak_data.menu.pd2_small_font
	dialog_data.font_size = tweak_data.menu.pd2_small_font_size

	managers.system_menu:show_new_unlock(dialog_data)
end

function MenuManager:show_challenge_warn_choose_reward(params)
	local dialog_data = {
		title = managers.localization:text("dialog_challenge_warn_choose_reward_title"),
		text = managers.localization:text("dialog_challenge_warn_choose_reward", {
			reward = params.reward
		})
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}
	dialog_data.texture = params.image
	dialog_data.image_w = 128
	dialog_data.image_h = 128
	dialog_data.image_valign = "center"

	managers.system_menu:show_new_unlock(dialog_data)
end

function MenuManager:show_challenge_reward(reward)
	local category = reward.type_items
	local id = reward.item_entry
	local td = tweak_data:get_raw_value("blackmarket", category, id)

	if not td then
		return
	end

	local amount = reward.amount or 1
	local name_string = td.name_id and managers.localization:text(td.name_id)
	local params = {}

	if category == "cash" then
		local money = tweak_data:get_value("money_manager", "loot_drop_cash", td.value_id) or 100
		params.cash = managers.experience:cash_string(money * amount)
	elseif category == "xp" then
		local xp = tweak_data:get_value("experience_manager", "loot_drop_value", td.value_id) or 0
		params.xp = managers.experience:experience_string(xp * amount)
	elseif category == "weapon_mods" then
		params.item = name_string
		params.amount = managers.money:add_decimal_marks_to_string(tostring(amount))
		local list_of_weapons = managers.weapon_factory:get_weapons_uses_part(id) or {}

		if table.size(list_of_weapons) <= 4 then
			local s = " ("

			for _, factory_id in pairs(list_of_weapons) do
				s = s .. managers.weapon_factory:get_weapon_name_by_factory_id(factory_id)
				s = s .. ", "
			end

			s = s:sub(1, -3) .. ")"
			params.item = params.item .. s
		end
	else
		params.item = name_string
		params.amount = managers.money:add_decimal_marks_to_string(tostring(amount))
	end

	local dialog_id = category == "cash" and "dialog_challenge_reward_cash" or category == "xp" and "dialog_challenge_reward_xp" or amount > 1 and "dialog_challenge_reward_plural" or "dialog_challenge_reward"
	local dialog_data = {
		title = managers.localization:text("dialog_challenge_reward_title"),
		text = managers.localization:text(dialog_id, params)
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok"),
		callback_func = function ()
			MenuCallbackHandler:refresh_node()
		end
	}
	dialog_data.button_list = {
		ok_button
	}
	local texture_path = "guis/textures/pd2/endscreen/what_is_this"
	local guis_catalog = "guis/"
	local bundle_folder = td.texture_bundle_folder

	if bundle_folder then
		guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
	end

	if category == "textures" then
		texture_path = td.texture
	elseif category == "cash" then
		texture_path = "guis/textures/pd2/blackmarket/cash_drop"
	elseif category == "xp" then
		texture_path = "guis/textures/pd2/blackmarket/xp_drop"
	elseif category ~= "colors" then
		texture_path = guis_catalog .. "textures/pd2/blackmarket/icons/" .. (category == "weapon_mods" and "mods" or category) .. "/" .. id
	end

	dialog_data.texture = texture_path
	dialog_data.text_blend_mode = "add"
	dialog_data.use_text_formating = true
	dialog_data.w = 400
	dialog_data.h = 320
	dialog_data.image_w = 128
	dialog_data.image_h = 128
	dialog_data.image_valign = "center"
	dialog_data.title_font = tweak_data.menu.pd2_medium_font
	dialog_data.title_font_size = tweak_data.menu.pd2_medium_font_size
	dialog_data.font = tweak_data.menu.pd2_small_font
	dialog_data.font_size = tweak_data.menu.pd2_small_font_size

	managers.system_menu:show_new_unlock(dialog_data)

	if managers.challenge:any_challenge_rewarded() then
		managers.menu_component:post_event("sidejob_stinger_long")
	else
		managers.menu_component:post_event("sidejob_stinger_short")
	end

	managers.menu_component:disable_crimenet()
end

function MenuManager:show_inventory_load_fail_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_inventory_load_fail_title"),
		text = managers.localization:text("dialog_inventory_load_fail_text")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_crime_spree_cleared_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_crime_spree_cleared_title"),
		text = managers.localization:text("dialog_crime_spree_cleared_text")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_vr_settings_dialog(params)
	local dialog_data = {
		title = managers.localization:text("dialog_vr_settings_title"),
		text = managers.localization:text("dialog_vr_settings_text"),
		id = "vr_settings"
	}
	local ok_button = {
		text = managers.localization:text("dialog_vr_calibrate"),
		callback_func = params and params.ok_func
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_vr_procedural_animation()
	local dialog_data = {
		title = managers.localization:text("dialog_vr_procedural_animation_title"),
		text = managers.localization:text("dialog_vr_procedural_animation_text")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_heist_is_locked_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_heist_locked_title"),
		text = managers.localization:text("dialog_heist_locked_text")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_crime_spree_locked_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_crime_spree_locked_title"),
		text = managers.localization:text("dialog_crime_spree_locked_text", {
			level_lock = tweak_data.crime_spree.unlock_level
		})
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_movie_theater_unlocked_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_ending_unlocked_title"),
		text = managers.localization:text("dialog_ending_unlocked_text")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_accept_telemetry(params)
	local dialog_data = {
		title = managers.localization:text("dialog_telemetry_title"),
		button_sub_title = managers.localization:text("dialog_telemetry_question"),
		file_name = "telemetry"
	}
	local is_pc_controller = managers.controller:get_default_wrapper_type() == "pc" or managers.controller:get_default_wrapper_type() == "steam" or managers.controller:get_default_wrapper_type() == "vr"
	local yes_legend = is_pc_controller and managers.localization:btn_macro("continue") or managers.localization:get_default_macro("BTN_ACCEPT")
	local no_legend = is_pc_controller and managers.localization:btn_macro("back") or managers.localization:get_default_macro("BTN_CANCEL")
	local yes_button = {
		text = managers.localization:to_upper_text("dialog_telemetry_accept", {
			ACCEPT = yes_legend
		}),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:to_upper_text("dialog_telemetry_decline", {
			DECLINE = no_legend
		}),
		callback_func = params.no_func,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show_document(dialog_data)
end
