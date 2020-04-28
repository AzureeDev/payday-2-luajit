require("lib/utils/accelbyte/TelemetryConst")

function MenuCallbackHandler:crime_spree_is_active()
	return managers.crime_spree:is_active()
end

function MenuCallbackHandler:crime_spree_not_is_active()
	return not managers.crime_spree:is_active()
end

function MenuCallbackHandler:crime_spree_in_progress()
	return managers.crime_spree:in_progress()
end

function MenuCallbackHandler:crime_spree_not_in_progress()
	return not managers.crime_spree:in_progress()
end

function MenuCallbackHandler:crime_spree_not_failed()
	return not managers.crime_spree:has_failed()
end

function MenuCallbackHandler:crime_spree_failed()
	return managers.crime_spree:has_failed()
end

function MenuCallbackHandler:show_crime_spree_start()
	return not self:show_crime_spree_select_modifier()
end

function MenuCallbackHandler:show_crime_spree_reroll()
	return self:show_crime_spree_start()
end

function MenuCallbackHandler:is_playing()
	return Global.game_settings.is_playing
end

function MenuCallbackHandler:is_not_playing()
	return not Global.game_settings.is_playing
end

function MenuCallbackHandler:show_crime_spree_select_modifier()
	local loud = managers.crime_spree:modifiers_to_select("loud")
	local stealth = managers.crime_spree:modifiers_to_select("stealth")

	return loud > 0 or stealth > 0
end

function MenuCallbackHandler:show_crime_spree_claim_rewards()
	return managers.crime_spree:reward_level() > 0
end

function MenuCallbackHandler:not_show_crime_spree_claim_rewards()
	return managers.crime_spree:reward_level() <= 0
end

function MenuCallbackHandler:return_to_crime_spree_lobby_visible()
	local state = game_state_machine:current_state_name()

	return state == "victoryscreen" or state == "gameoverscreen"
end

function MenuCallbackHandler:accept_crime_spree_contract(item, node)
	if Global.game_settings.single_player then
		self:_accept_crime_spree_contract_sp(item, node)
	else
		self:_accept_crime_spree_contract_mp(item, node)
	end
end

function MenuCallbackHandler:_accept_crime_spree_contract_sp(item, node)
	if not managers.crime_spree:in_progress() and managers.crime_spree:starting_level() >= 0 then
		if not managers.crime_spree:can_start_spree(managers.crime_spree:starting_level() or 0) then
			return
		end

		managers.crime_spree:start_crime_spree(managers.crime_spree:starting_level())
	end

	managers.crime_spree:enable_crime_spree_gamemode()
	MenuCallbackHandler:save_progress()
	managers.menu:active_menu().logic:select_node("crime_spree_lobby", true, {})
end

function MenuCallbackHandler:_accept_crime_spree_contract_mp(item, node)
	if not managers.crime_spree:in_progress() and managers.crime_spree:starting_level() >= 0 then
		if not managers.crime_spree:can_start_spree(managers.crime_spree:starting_level() or 0) then
			return
		end

		managers.crime_spree:start_crime_spree(managers.crime_spree:starting_level())
	end

	local matchmake_attributes = self:get_matchmake_attributes()

	managers.crime_spree:enable_crime_spree_gamemode()

	if Network:is_server() then
		managers.network.matchmake:set_server_attributes(matchmake_attributes)
	else
		managers.network.matchmake:create_lobby(matchmake_attributes)
	end

	managers.menu_component:set_max_lines_game_chat(tweak_data.crime_spree.gui.max_chat_lines.lobby)
	MenuCallbackHandler:save_progress()
end

function MenuCallbackHandler:accept_crimenet_contract_crime_spree(item, node)
	if not managers.crime_spree:in_progress() and managers.crime_spree:starting_level() >= 0 then
		managers.crime_spree:start_crime_spree(managers.crime_spree:starting_level())
	end

	self:accept_crimenet_contract(item, node)
end

function MenuCallbackHandler:claim_crime_spree_rewards(item, node)
	if managers.crime_spree:reward_level() > 0 then
		local dialog_data = {
			title = managers.localization:text("dialog_cs_claim_rewards"),
			text = managers.localization:text("dialog_cs_claim_rewards_text"),
			id = "crime_spree_rewards"
		}
		local yes_button = {
			text = managers.localization:text("dialog_yes"),
			callback_func = callback(self, self, "_dialog_crime_spree_claim_rewards_yes")
		}
		local no_button = {
			text = managers.localization:text("dialog_no"),
			callback_func = callback(self, self, "_dialog_crime_spree_claim_rewards_no"),
			cancel_button = true
		}
		dialog_data.button_list = {
			yes_button,
			no_button
		}

		managers.system_menu:show(dialog_data)
	else
		local dialog_data = {
			title = managers.localization:text("dialog_cs_claim_rewards"),
			text = managers.localization:text("dialog_cs_cant_claim_rewards_text"),
			id = "crime_spree_rewards"
		}
		local no_button = {
			text = managers.localization:text("dialog_ok"),
			callback_func = callback(self, self, "_dialog_crime_spree_claim_rewards_no"),
			cancel_button = true
		}
		dialog_data.button_list = {
			no_button
		}

		managers.system_menu:show(dialog_data)
	end
end

function MenuCallbackHandler:_dialog_crime_spree_claim_rewards_yes()
	self:_dialog_leave_lobby_yes()
	managers.menu:open_node("crime_spree_claim_rewards", {})
end

function MenuCallbackHandler:_dialog_crime_spree_claim_rewards_no()
end

function MenuCallbackHandler:show_crime_spree_crash_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_cs_crash_fail"),
		text = managers.localization:text("dialog_cs_crash_fail_text"),
		id = "crime_spree_fail"
	}
	local no_button = {
		text = managers.localization:text("dialog_ok"),
		cancel_button = true
	}
	dialog_data.button_list = {
		no_button
	}

	managers.system_menu:show(dialog_data)

	return true
end

function MenuCallbackHandler:end_crime_spree(item, node)
	local dialog_data = {
		title = managers.localization:text("dialog_warning_title")
	}

	if managers.crime_spree:can_refund_entry_fee() then
		local cost = managers.crime_spree:get_start_cost(managers.crime_spree:spree_level())
		dialog_data.text = managers.localization:text("dialog_are_you_sure_you_want_stop_cs_refund", {
			coins = cost
		})
	else
		dialog_data.text = managers.localization:text("dialog_are_you_sure_you_want_stop_cs")
	end

	dialog_data.id = "stop_crime_spree"
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = callback(self, self, "_dialog_end_crime_spree_yes")
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = callback(self, self, "_dialog_end_crime_spree_no"),
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuCallbackHandler:_dialog_end_crime_spree_yes()
	if managers.crime_spree:can_refund_entry_fee() then
		local cost = managers.crime_spree:get_start_cost(managers.crime_spree:spree_level())

		managers.custom_safehouse:add_coins(cost, TelemetryConst.economy_origin.refund_crime_spree)
	end

	managers.crime_spree:reset_crime_spree()
	self:_dialog_leave_lobby_yes()
	MenuCallbackHandler:save_progress()
end

function MenuCallbackHandler:_dialog_end_crime_spree_no()
end

function MenuCallbackHandler:return_to_crime_spree_lobby()
	if game_state_machine:current_state_name() == "disconnected" then
		return
	end

	local dialog_data = {
		title = managers.localization:text("dialog_warning_title"),
		text = managers.localization:text("dialog_return_to_cs_lobby")
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = function ()
			if game_state_machine:current_state_name() ~= "disconnected" then
				self:load_start_menu_lobby()
			end
		end
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

function MenuCallbackHandler:leave_crime_spree_lobby()
	if game_state_machine:current_state_name() == "ingame_lobby_menu" then
		self:end_game()

		return
	end

	local dialog_data = {
		title = managers.localization:text("dialog_warning_title"),
		text = managers.localization:text("dialog_are_you_sure_you_want_leave_cs"),
		id = "leave_lobby"
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = callback(self, self, "_dialog_leave_lobby_yes")
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = callback(self, self, "_dialog_leave_lobby_no"),
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)

	return true
end

function MenuCallbackHandler:end_game_crime_spree()
	local fail_on_quit = true

	if not Global.game_settings.is_playing then
		fail_on_quit = false
	end

	local dialog_data = {
		title = managers.localization:text("dialog_warning_title")
	}

	if Global.game_settings.is_playing then
		if managers.crime_spree:has_failed() then
			dialog_data.text = managers.localization:text("dialog_are_you_sure_you_want_to_leave_game")
		else
			dialog_data.text = managers.localization:text("dialog_are_you_sure_you_want_to_leave_game_crime_spree")
		end
	else
		dialog_data.text = managers.localization:text("dialog_are_you_sure_you_want_leave_cs")
	end

	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = callback(self, self, "_dialog_end_game_crime_spree_yes", fail_on_quit)
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = callback(self, self, "_dialog_end_game_crime_spree_no"),
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuCallbackHandler:_dialog_end_game_crime_spree_no()
end

function MenuCallbackHandler:_dialog_end_game_crime_spree_yes(failed)
	managers.platform:set_playing(false)
	managers.job:clear_saved_ghost_bonus()
	managers.statistics:stop_session({
		quit = true
	})
	managers.savefile:save_progress()
	managers.job:deactivate_current_job()
	managers.gage_assignment:deactivate_assignments()
	managers.custom_safehouse:flush_completed_trophies()

	if failed == nil or failed then
		managers.crime_spree:on_mission_failed(managers.crime_spree:current_mission())
	end

	managers.crime_spree:on_left_lobby()

	if Network:multiplayer() then
		Network:set_multiplayer(false)
		managers.network:session():send_to_peers("set_peer_left")
		managers.network:queue_stop_network()
	end

	managers.network.matchmake:destroy_game()
	managers.network.voice_chat:destroy_voice()

	if managers.groupai then
		managers.groupai:state():set_AI_enabled(false)
	end

	managers.menu:post_event("menu_exit")
	managers.menu:close_menu("menu_pause")
	setup:load_start_menu()
end

function MenuCallbackHandler:crime_spree_continue()
	local cost = managers.crime_spree:get_continue_cost(managers.crime_spree:spree_level())
	local params = {
		level = managers.crime_spree:spree_level(),
		cost = cost
	}
	local coins = 0
	coins = managers.custom_safehouse:coins()

	if coins < cost then
		local dialog_data = {
			title = managers.localization:text("dialog_cant_continue_cs_title"),
			text = managers.localization:text("dialog_cant_continue_cs_text", params),
			id = "continue_crime_spree"
		}
		local no_button = {
			text = managers.localization:text("dialog_ok"),
			callback_func = callback(self, self, "_dialog_crime_spree_continue_no"),
			cancel_button = true
		}
		dialog_data.button_list = {
			no_button
		}

		managers.system_menu:show(dialog_data)
	else
		local dialog_data = {
			title = managers.localization:text("dialog_continue_cs_title"),
			text = managers.localization:text("dialog_continue_cs_text", params),
			id = "continue_crime_spree"
		}
		local yes_button = {
			text = managers.localization:text("dialog_yes"),
			callback_func = callback(self, self, "_dialog_crime_spree_continue_yes")
		}
		local no_button = {
			text = managers.localization:text("dialog_no"),
			callback_func = callback(self, self, "_dialog_crime_spree_continue_no"),
			cancel_button = true
		}
		dialog_data.button_list = {
			yes_button,
			no_button
		}

		managers.system_menu:show(dialog_data)
	end

	return true
end

function MenuCallbackHandler:_dialog_crime_spree_continue_yes()
	print("[MenuCallbackHandler:_dialog_crime_spree_continue_yes]")
	managers.crime_spree:continue_crime_spree()
	managers.menu:active_menu().logic:refresh_node("main")

	if managers.menu_component:crime_spree_mission_end_gui() then
		local node = managers.menu_component:crime_spree_mission_end_gui()._node

		managers.menu_component:close_crime_spree_mission_end_gui(node)
		managers.menu_component:create_crime_spree_mission_end_gui(node)
	end

	managers.menu_component:create_crime_spree_missions_gui(managers.menu:active_menu().logic:selected_node())
	managers.menu_component:refresh_crime_spree_details_gui()
	WalletGuiObject.refresh()

	if managers.menu:active_menu() then
		managers.menu:active_menu().logic:select_item("spree_start", true)
	end
end

function MenuCallbackHandler:_dialog_crime_spree_continue_no()
end

function MenuCallbackHandler:create_server_left_crime_spree_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_warning_title")
	}

	if Global.on_server_left_message then
		dialog_data.text = managers.localization:text("dialog_on_server_left_message_cs", {
			message = managers.localization:text(Global.on_server_left_message)
		})
		Global.on_server_left_message = nil
	else
		dialog_data.text = managers.localization:text("dialog_the_host_has_left_the_game_cs")
	end

	dialog_data.id = "server_left_dialog"
	local ok_button = {
		text = managers.localization:text("dialog_ok"),
		callback_func = callback(self, self, "_on_server_left_ok_pressed")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuCallbackHandler:_on_server_left_ok_pressed()
	self:_dialog_end_game_crime_spree_yes(false)
end

function MenuCallbackHandler:show_peer_kicked_crime_spree_dialog(params)
	local dialog_data = {
		title = managers.localization:text(Global.on_remove_peer_message and "dialog_information_title" or "dialog_mp_kicked_out_title")
	}

	if Global.on_remove_peer_message then
		dialog_data.text = managers.localization:text("dialog_on_server_left_message_cs", {
			message = managers.localization:text(Global.on_remove_peer_message)
		})
	else
		dialog_data.text = managers.localization:text("dialog_on_server_left_message_cs", {
			message = managers.localization:text("dialog_mp_kicked_out_message")
		})
	end

	local ok_button = {
		text = managers.localization:text("dialog_ok"),
		callback_func = callback(self, self, "_on_server_left_ok_pressed")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)

	Global.on_remove_peer_message = nil
end

function MenuCallbackHandler:crime_spree_reroll()
	local mission_gui = managers.menu_component:crime_spree_missions_gui()

	if mission_gui and mission_gui:is_randomizing() then
		managers.menu:post_event("menu_error")

		return
	end

	local can_afford = false
	can_afford = managers.crime_spree:randomization_cost() <= managers.custom_safehouse:coins()
	local dialog_data = {
		title = managers.localization:text("menu_cs_reroll_title"),
		id = "reroll_crime_spree"
	}

	if can_afford then
		dialog_data.text = managers.localization:text("menu_cs_reroll_text", {
			cost = managers.crime_spree:randomization_cost()
		})
		local yes_button = {
			text = managers.localization:text("dialog_yes"),
			callback_func = callback(self, self, "_dialog_crime_spree_reroll_yes")
		}
		local no_button = {
			text = managers.localization:text("dialog_no"),
			callback_func = callback(self, self, "_dialog_crime_spree_reroll_no"),
			cancel_button = true
		}
		dialog_data.button_list = {
			yes_button,
			no_button
		}
	else
		dialog_data.text = managers.localization:text("menu_cs_reroll_text_cant_afford", {
			cost = managers.crime_spree:randomization_cost()
		})
		local no_button = {
			text = managers.localization:text("dialog_ok"),
			callback_func = callback(self, self, "_dialog_crime_spree_reroll_no"),
			cancel_button = true
		}
		dialog_data.button_list = {
			no_button
		}
	end

	managers.system_menu:show(dialog_data)
end

function MenuCallbackHandler:_dialog_crime_spree_reroll_yes()
	managers.custom_safehouse:deduct_coins(managers.crime_spree:randomization_cost(), TelemetryConst.economy_origin.crime_spree_reroll)
	managers.crime_spree:randomize_mission_set()

	if managers.menu_component:crime_spree_missions_gui() then
		managers.menu_component:crime_spree_missions_gui():randomize_crimespree()
	end

	WalletGuiObject.refresh()
	MenuCallbackHandler:save_progress()
end

function MenuCallbackHandler:_dialog_crime_spree_reroll_no()
end

function MenuCallbackHandler:crime_spree_select_modifier()
	if self:show_crime_spree_select_modifier() then
		managers.menu:open_node("crime_spree_select_modifiers", {})
	end
end

function MenuCallbackHandler:crime_spree_start_game()
	if managers.crime_spree:current_mission() == nil then
		managers.menu:post_event("menu_error")
	else
		self:start_the_game()
	end
end

function MenuManager:show_confirm_mission_gage_asset_buy(params)
	local asset_tweak_data = tweak_data.crime_spree.assets[params.asset_id]
	local dialog_data = {
		title = managers.localization:text("dialog_assets_buy_title"),
		text = managers.localization:text("dialog_mission_asset_buy", {
			asset_desc = managers.localization:text(asset_tweak_data.unlock_desc_id or "menu_asset_unknown_unlock_desc", asset_tweak_data.data),
			cost = managers.localization:text("bm_cs_continental_coin_cost", {
				cost = managers.experience:cash_string(asset_tweak_data.cost, "")
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

function MenuManager:show_gage_assets_unlock_prevented(params)
	local asset_tweak_data = tweak_data.crime_spree.assets[params.asset_id]
	local dialog_data = {}

	if managers.crime_spree:can_unlock_asset_is_in_game() then
		dialog_data.title = managers.localization:text("dialog_cs_ga_in_progress")
		dialog_data.text = managers.localization:text("dialog_cs_ga_in_progress_text")
	else
		dialog_data.title = managers.localization:text("dialog_cs_ga_already_purchased")
		dialog_data.text = managers.localization:text("dialog_cs_ga_already_purchased_text")
	end

	dialog_data.focus_button = 1
	local no_button = {
		text = managers.localization:text("dialog_ok"),
		cancel_button = true
	}
	dialog_data.button_list = {
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_gage_asset_desc(params)
	local asset_tweak_data = tweak_data.crime_spree.assets[params.asset_id]
	local dialog_data = {
		title = managers.localization:text(asset_tweak_data.name_id),
		text = managers.localization:text(asset_tweak_data.unlock_desc_id or "menu_asset_unknown_unlock_desc", asset_tweak_data.data),
		focus_button = 1
	}
	local no_button = {
		text = managers.localization:text("dialog_ok"),
		cancel_button = true
	}
	dialog_data.button_list = {
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuCallbackHandler:choice_spree_difference_filter(item)
	Global.game_settings.crime_spree_max_lobby_diff = item:value()

	managers.user:set_setting("crime_spree_lobby_diff", item:value())
	managers.network.matchmake:search_lobby(managers.network.matchmake:search_friends_only())
end

function MenuCallbackHandler:debug_crime_spree_reset()
	managers.crime_spree:reset_crime_spree()
	MenuCallbackHandler:save_progress()
end

function MenuCallbackHandler:clear_crime_spree_record()
	local dialog_data = {
		title = managers.localization:text("dialog_warning_title"),
		text = managers.localization:text("dialog_clear_crime_spree_record_confirmation_text")
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = callback(self, self, "_dialog_clear_crime_spree_record_yes")
	}
	local no_button = {
		cancel_button = true,
		text = managers.localization:text("dialog_no"),
		callback_func = callback(self, self, "_dialog_clear_crime_spree_record_no")
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuCallbackHandler:_dialog_clear_crime_spree_record_yes()
	Global.crime_spree.highest_level = nil

	managers.savefile:save_progress()
end

function MenuCallbackHandler:_dialog_clear_crime_spree_record_no()
end
