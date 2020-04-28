LootDropScreenGui = LootDropScreenGui or class()

function LootDropScreenGui:init(saferect_ws, fullrect_ws, lootscreen_hud, saved_state)
	self._safe_workspace = saferect_ws
	self._full_workspace = fullrect_ws
	self._lootscreen_hud = lootscreen_hud

	self._lootscreen_hud:add_callback("on_peer_ready", callback(self, self, "check_all_ready"))

	self._fullscreen_panel = self._full_workspace:panel():panel()
	self._panel = self._safe_workspace:panel():panel()
	self._no_loot_for_me = not managers.job:is_job_finished()

	if not self._lootscreen_hud:is_active() then
		self._panel:hide()
		self._fullscreen_panel:hide()
	end

	local is_skirmish = managers.skirmish:is_skirmish()
	local waiting_text_string = managers.localization:to_upper_text(is_skirmish and "menu_l_waiting_for_cards" or "menu_l_waiting_for_all")
	self._continue_button = self._panel:text({
		name = "ready_button",
		vertical = "center",
		h = 32,
		align = "right",
		layer = 2,
		text = waiting_text_string,
		font_size = tweak_data.menu.pd2_large_font_size,
		font = tweak_data.menu.pd2_large_font,
		color = tweak_data.screen_colors.button_stage_3
	})
	local _, _, w, h = self._continue_button:text_rect()

	self._continue_button:set_size(w, h)
	self._continue_button:set_bottom(self._panel:h())
	self._continue_button:set_right(self._panel:w())

	self._button_not_clickable = true

	self._continue_button:set_color(tweak_data.screen_colors.item_stage_1)

	local big_text = self._fullscreen_panel:text({
		name = "continue_big_text",
		vertical = "bottom",
		h = 90,
		alpha = 0.4,
		align = "right",
		layer = 1,
		text = waiting_text_string,
		font_size = tweak_data.menu.pd2_massive_font_size,
		font = tweak_data.menu.pd2_massive_font,
		color = tweak_data.screen_colors.button_stage_3
	})
	local x, y = managers.gui_data:safe_to_full_16_9(self._continue_button:world_right(), self._continue_button:world_center_y())

	big_text:set_world_right(x)
	big_text:set_world_center_y(y)
	big_text:move(13, -9)

	if MenuBackdropGUI then
		MenuBackdropGUI.animate_bg_text(self, big_text)
	end

	self._time_left_text = self._panel:text({
		text = "30",
		vertical = "bottom",
		name = "time_left",
		align = "right",
		layer = 1,
		font_size = tweak_data.menu.pd2_small_font_size,
		font = tweak_data.menu.pd2_small_font,
		color = tweak_data.screen_colors.text
	})

	self._time_left_text:set_right(self._continue_button:right())
	self._time_left_text:set_bottom(self._continue_button:top())
	self._time_left_text:set_alpha(0)

	self._fade_time_left = 10
	self._time_left = 30
	self._is_alone = false
	self._selected = 0
	self._id = managers.network:session() and managers.network:session():local_peer():id() or 1
	self._card_chosen = false

	if saved_state then
		self:set_state(saved_state)
	end

	if self._no_loot_for_me then
		return
	end

	if is_skirmish then
		self._card_chosen = true

		return
	end

	self:_set_selected_and_sync(2)
end

function LootDropScreenGui:set_state(state)
	local id_state = Idstring(state)

	if id_state == Idstring("on_server_left") then
		self._lootscreen_hud:clear_other_peers(self._id)

		self._is_alone = true

		self:close_network()
		MenuMainState._create_server_left_dialog(self)
	elseif id_state == Idstring("on_kicked") then
		self._lootscreen_hud:clear_other_peers(self._id)

		self._is_alone = true

		self:close_network()
		managers.menu:show_peer_kicked_dialog({
			ok_func = callback(self, self, "on_server_left_ok_pressed")
		})
	elseif id_state == Idstring("on_disconnected") then
		self._lootscreen_hud:clear_other_peers(self._id)

		self._is_alone = true

		self:close_network()
		managers.menu:show_mp_disconnected_internet_dialog({
			ok_func = callback(self, self, "on_server_left_ok_pressed")
		})
	else
		Application:error("LootDropScreenGui:set_state: unrecognizable state", state)
	end

	self._panel:show()
	self._fullscreen_panel:show()
	managers.menu_component:post_event("menu_exit")
end

function LootDropScreenGui:on_server_left_ok_pressed()
	self:check_all_ready()
end

function LootDropScreenGui:close_network()
	if Network:multiplayer() then
		Network:set_multiplayer(false)
		managers.network:queue_stop_network()
		managers.network.matchmake:destroy_game()
		managers.network.voice_chat:destroy_voice()
		managers.menu_component:remove_game_chat()
		managers.menu_component:close_chat_gui()
		managers.job:deactivate_current_job()
		managers.gage_assignment:deactivate_assignments()
	end
end

function LootDropScreenGui:choose_card(id, selected)
	self._lootscreen_hud:begin_choose_card(id, selected or 2)
end

function LootDropScreenGui:hide()
	self._enabled = false

	self._panel:set_alpha(0.5)
	self._fullscreen_panel:set_alpha(0.5)
end

function LootDropScreenGui:show()
	self._enabled = true

	self._panel:set_alpha(1)
	self._fullscreen_panel:set_alpha(1)
end

function LootDropScreenGui:check_all_ready()
	if not alive(self._panel) or not alive(self._fullscreen_panel) then
		Application:error("[LootDropScreenGui:check_all_ready] GUI panel is dead!", self._panel, self._fullscreen_panel)

		return
	end

	if self._lootscreen_hud:check_all_ready() then
		local text_id = "victory_client_waiting_for_server"

		if Global.game_settings.single_player or self._is_alone or not managers.network:session() then
			self._button_not_clickable = false
			text_id = "failed_disconnected_continue"

			if managers.menu:is_pc_controller() then
				self._continue_button:set_color(tweak_data.screen_colors.button_stage_3)
			end
		elseif Network:is_server() then
			self._button_not_clickable = false
			text_id = "debug_mission_end_continue"

			if managers.menu:is_pc_controller() then
				self._continue_button:set_color(tweak_data.screen_colors.button_stage_3)
			end
		end

		local continue_button = managers.menu:is_pc_controller() and "[ENTER]" or nil
		local text = managers.localization:to_upper_text(text_id, {
			CONTINUE = continue_button
		})

		self._continue_button:set_text(text)

		local _, _, w, h = self._continue_button:text_rect()

		self._continue_button:set_size(w, h)
		self._continue_button:set_bottom(self._panel:h())
		self._continue_button:set_right(self._panel:w())

		local big_text = self._fullscreen_panel:child("continue_big_text")

		big_text:set_text(text)

		local x, y = managers.gui_data:safe_to_full_16_9(self._continue_button:world_right(), self._continue_button:world_center_y())

		big_text:set_world_right(x)
		big_text:set_world_center_y(y)
		big_text:move(13, -9)
		managers.menu_component:post_event("prompt_enter")
	end
end

function LootDropScreenGui:on_peer_removed(peer, reason)
	if peer then
		self._lootscreen_hud:remove_peer(peer:id(), reason)
	end

	self:check_all_ready()
end

function LootDropScreenGui:update(t, dt)
	self._lootscreen_hud:update(t, dt)

	if self._no_loot_for_me then
		return
	end

	if not self._is_alone then
		if self._fade_time_left then
			self._fade_time_left = self._fade_time_left - dt

			if self._fade_time_left <= 0 then
				self._time_left_text:set_alpha(not self._card_chosen and 1 or 0)

				self._fade_time_left = nil
			end
		elseif self._time_left then
			self._time_left = math.max(self._time_left - dt, 0)

			if self._card_chosen then
				self._time_left = 0
			end

			if self._time_left > 10 then
				self._time_left_text:set_text(string.format("%1d", self._time_left))
			else
				if self._time_left_text:font_size() == tweak_data.menu.pd2_small_font_size then
					self._time_left_text:set_font(tweak_data.menu.pd2_medium_font_id)
					self._time_left_text:set_font_size(tweak_data.menu.pd2_medium_font_size)
				end

				self._time_left_text:set_text(string.format("%0.2f", self._time_left))
			end

			if self._time_left <= 0 then
				self._time_left_text:set_text("")
				self._time_left_text:set_alpha(0)

				if not self._card_chosen then
					self._card_chosen = true

					self:choose_card(self._id, self._selected)

					if not Global.game_settings.single_player and managers.network:session() then
						managers.network:session():send_to_peers("choose_lootcard", self._selected or 2)
					end
				end
			end
		end
	end
end

function LootDropScreenGui:continue_to_lobby()
	if game_state_machine:current_state()._continue_cb then
		managers.menu_component:post_event("menu_enter")
		game_state_machine:current_state()._continue_cb()
	end
end

function LootDropScreenGui:mouse_pressed(button, x, y)
	if self._no_loot_for_me then
		return
	end

	if not alive(self._panel) or not alive(self._fullscreen_panel) or not self._enabled then
		return
	end

	if button ~= Idstring("0") then
		return
	end

	if self._card_chosen and not self._button_not_clickable and self._continue_button:inside(x, y) then
		self:continue_to_lobby()

		return true
	end

	if self._card_chosen then
		return
	end

	local inside = self._lootscreen_hud:check_inside_local_peer(x, y)

	if inside == self._selected then
		self._card_chosen = true

		managers.menu_component:post_event("menu_enter")
		self:choose_card(self._id, self._selected)

		if not Global.game_settings.single_player and managers.network:session() then
			managers.network:session():send_to_peers("choose_lootcard", self._selected)
		end
	end
end

function LootDropScreenGui:mouse_moved(x, y)
	if self._no_loot_for_me then
		return false
	end

	if not alive(self._panel) or not alive(self._fullscreen_panel) or not self._enabled then
		return false
	end

	if self._button_not_clickable then
		self._continue_button:set_color(tweak_data.screen_colors.item_stage_1)
	elseif self._continue_button:inside(x, y) then
		if not self._continue_button_highlighted then
			self._continue_button_highlighted = true

			self._continue_button:set_color(tweak_data.screen_colors.button_stage_2)
			managers.menu_component:post_event("highlight")
		end

		return true, "link"
	elseif self._continue_button_highlighted then
		self._continue_button_highlighted = false

		self._continue_button:set_color(tweak_data.screen_colors.button_stage_3)
	end

	if self._card_chosen then
		return false
	end

	if self._lootscreen_hud then
		local inside = self._lootscreen_hud:check_inside_local_peer(x, y)

		if inside then
			self:_set_selected_and_sync(inside)
		end

		return inside, "link"
	end
end

function LootDropScreenGui:input_focus()
	return self._enabled
end

function LootDropScreenGui:scroll_up()
	if self._no_loot_for_me then
		return
	end

	if self._card_chosen then
		return
	end

	if not alive(self._panel) or not alive(self._fullscreen_panel) or not self._enabled then
		return
	end

	self:_set_selected_and_sync(self._selected - 1)
end

function LootDropScreenGui:scroll_down()
	if self._no_loot_for_me then
		return
	end

	if self._card_chosen then
		return
	end

	if not alive(self._panel) or not alive(self._fullscreen_panel) or not self._enabled then
		return
	end

	self:_set_selected_and_sync(self._selected + 1)
end

function LootDropScreenGui:move_up()
end

function LootDropScreenGui:move_down()
end

function LootDropScreenGui:set_selected(selected)
	local new_selected = math.clamp(selected, 1, 3)

	if new_selected ~= self._selected then
		self._selected = new_selected

		self._lootscreen_hud:set_selected(self._id, self._selected)
		managers.menu_component:post_event("highlight")

		return true
	end

	return false
end

function LootDropScreenGui:_set_selected_and_sync(selected)
	if self:set_selected(selected) and not Global.game_settings.single_player and managers.network:session() then
		managers.network:session():send_to_peers("set_selected_lootcard", self._selected)
	end
end

function LootDropScreenGui:move_left()
	if self._no_loot_for_me then
		return
	end

	if self._card_chosen then
		return
	end

	if not alive(self._panel) or not alive(self._fullscreen_panel) or not self._enabled then
		return
	end

	self:_set_selected_and_sync(self._selected - 1)
end

function LootDropScreenGui:move_right()
	if self._no_loot_for_me then
		return
	end

	if self._card_chosen then
		return
	end

	if not alive(self._panel) or not alive(self._fullscreen_panel) or not self._enabled then
		return
	end

	self:_set_selected_and_sync(self._selected + 1)
end

function LootDropScreenGui:next_tab()
	self:_set_selected_and_sync(self._selected + 1)
end

function LootDropScreenGui:prev_tab()
	self:_set_selected_and_sync(self._selected - 1)
end

function LootDropScreenGui:confirm_pressed()
	if self._no_loot_for_me then
		return
	end

	if not alive(self._panel) or not alive(self._fullscreen_panel) or not self._enabled then
		return
	end

	if self._card_chosen and not self._button_not_clickable then
		self:continue_to_lobby()

		return false
	end

	if self._card_chosen then
		return false
	end

	self._card_chosen = true

	managers.menu_component:post_event("menu_enter")
	self:choose_card(self._id, self._selected)

	if not Global.game_settings.single_player and managers.network:session() then
		managers.network:session():send_to_peers("choose_lootcard", self._selected)
	end

	return true
end

function LootDropScreenGui:back_pressed()
	if self._no_loot_for_me then
		return
	end

	if not alive(self._panel) or not alive(self._fullscreen_panel) or not self._enabled then
		return false
	end
end

function LootDropScreenGui:next_page()
	if self._no_loot_for_me then
		return
	end

	if self._card_chosen then
		return
	end

	if not self._enabled then
		return
	end

	self:next_tab()
end

function LootDropScreenGui:previous_page()
	if self._no_loot_for_me then
		return
	end

	if self._card_chosen then
		return
	end

	if not self._enabled then
		return
	end

	self:prev_tab()
end

function LootDropScreenGui:special_btn_pressed(button)
	if self._no_loot_for_me then
		return
	end

	if self._card_chosen then
		return false
	end
end

function LootDropScreenGui:close()
	if self._panel and alive(self._panel) then
		self._panel:parent():remove(self._panel)
	end

	if self._fullscreen_panel and alive(self._fullscreen_panel) then
		self._fullscreen_panel:parent():remove(self._fullscreen_panel)
	end
end

function LootDropScreenGui:reload()
	self:close()
	LootDropScreenGui.init(self, self._safe_workspace, self._full_workspace, self._lootscreen_hud)
end

CasinoLootDropScreenGui = CasinoLootDropScreenGui or class(LootDropScreenGui)

function CasinoLootDropScreenGui:init(saferect_ws, fullrect_ws, lootscreen_hud, saved_state)
	CasinoLootDropScreenGui.super.init(self, saferect_ws, fullrect_ws, lootscreen_hud, saved_state)

	self._no_loot_for_me = false

	self:set_selected(2)
	self._panel:show()
	self._fullscreen_panel:show()
	managers.music:stop()
end

function CasinoLootDropScreenGui:continue_to_lobby()
	managers.menu:active_menu().logic:navigate_back(true)
	managers.music:post_event(managers.music:jukebox_menu_track("mainmenu"))
end

function CasinoLootDropScreenGui:card_chosen()
	return not self._button_not_clickable
end

function CasinoLootDropScreenGui:choose_card(id, selected)
	CasinoLootDropScreenGui.super.choose_card(self, id, selected)
	managers.savefile:save_progress()
end

function CasinoLootDropScreenGui:set_layer(layer)
	self._fullscreen_panel:set_layer(layer)
	self._panel:set_layer(layer)
end
