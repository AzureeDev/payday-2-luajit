core:import("CoreMenuRenderer")
require("lib/managers/menu/MenuNodeGui")
require("lib/managers/menu/renderers/MenuNodeTableGui")
require("lib/managers/menu/renderers/MenuNodeStatsGui")

MenuLobbyRenderer = MenuLobbyRenderer or class(CoreMenuRenderer.Renderer)

function MenuLobbyRenderer:init(logic, ...)
	MenuLobbyRenderer.super.init(self, logic, ...)

	self._sound_source = SoundDevice:create_source("MenuLobbyRenderer")
end

function MenuLobbyRenderer:show_node(node)
	local gui_class = MenuNodeGui

	if node:parameters().gui_class then
		gui_class = CoreSerialize.string_to_classtable(node:parameters().gui_class)
	end

	local parameters = {
		font = tweak_data.menu.pd2_medium_font,
		background_color = tweak_data.menu.main_menu_background_color:with_alpha(0),
		row_item_color = tweak_data.menu.default_font_row_item_color,
		row_item_hightlight_color = tweak_data.menu.default_hightlight_row_item_color,
		font_size = tweak_data.menu.pd2_medium_font_size,
		node_gui_class = gui_class,
		spacing = node:parameters().spacing
	}

	MenuLobbyRenderer.super.show_node(self, node, parameters)
end

local mugshots = {
	undecided = "mugshot_unassigned",
	russian = 3,
	german = 2,
	random = "mugshot_random",
	spanish = 4,
	american = 1
}
local mugshot_stencil = {
	random = {
		"bg_lobby_fullteam",
		65
	},
	undecided = {
		"bg_lobby_fullteam",
		65
	},
	american = {
		"bg_hoxton",
		80
	},
	german = {
		"bg_wolf",
		55
	},
	russian = {
		"bg_dallas",
		65
	},
	spanish = {
		"bg_chains",
		60
	}
}

function MenuLobbyRenderer:open(...)
	MenuLobbyRenderer.super.open(self, ...)

	local safe_rect_pixels = managers.gui_data:scaled_size()
	local scaled_size = safe_rect_pixels

	MenuRenderer._create_framing(self)
	self._main_panel:hide()

	self._player_slots = {}
	self._menu_bg = self._fullscreen_panel:panel({})

	if _G.IS_VR then
		self._menu_bg:rect({
			halign = "scale",
			valign = "scale",
			visible = true,
			layer = -1000,
			color = Color.black
		})
	end

	local is_server = Network:is_server()
	local server_peer = is_server and managers.network:session():local_peer() or managers.network:session():server_peer()
	local is_single_player = Global.game_settings.single_player
	local is_multiplayer = not is_single_player

	if not server_peer then
		return
	end

	for i = 1, is_single_player and 1 or tweak_data.max_players do
		local t = {
			player = {},
			free = true,
			kit_slots = {},
			params = {}
		}

		for slot = 1, PlayerManager.WEAPON_SLOTS + 3 do
			table.insert(t.kit_slots, slot)
		end

		table.insert(self._player_slots, t)
	end

	if is_server then
		local level = managers.experience:current_level()
		local rank = managers.experience:current_rank()
		local join_stinger_index = managers.infamy:selected_join_stinger_index()

		self:_set_player_slot(1, {
			character = "random",
			name = server_peer:name(),
			peer_id = server_peer:id(),
			level = level,
			rank = rank,
			join_stinger_index = join_stinger_index
		})
	end

	self:_entered_menu()
end

function MenuLobbyRenderer:set_bottom_text(...)
	MenuRenderer.set_bottom_text(self, ...)
end

function MenuLobbyRenderer:_entered_menu()
	managers.network:session():on_entered_lobby()
	self:on_request_lobby_slot_reply()
end

function MenuLobbyRenderer:close(...)
	self:set_choose_character_enabled(true)
	MenuLobbyRenderer.super.close(self, ...)

	if managers.menu_scene then
		managers.menu_scene:hide_all_lobby_characters()
	end
end

function MenuLobbyRenderer:update_level_id(level_id)
	if self._level_id == (level_id or Global.game_settings.level_id) then
		return
	end

	level_id = level_id or Global.game_settings.level_id
	local level_id_index = tweak_data.levels:get_index_from_level_id(level_id)

	managers.network:session():send_to_peers("lobby_sync_update_level_id", level_id_index)
	self:_update_level_id(level_id)
end

function MenuLobbyRenderer:sync_update_level_id(level_id)
	if self._level_id == level_id then
		return
	end

	Global.game_settings.level_id = level_id

	self:_update_level_id(level_id)
end

function MenuLobbyRenderer:_update_level_id(level_id)
	self._level_id = level_id

	Application:debug("_update_level_id", level_id)
end

function MenuLobbyRenderer:update_difficulty()
	local difficulty = Global.game_settings.difficulty

	managers.network:session():send_to_peers_loaded("lobby_sync_update_difficulty", difficulty)
	self:_update_difficulty(difficulty)
end

function MenuLobbyRenderer:sync_update_difficulty(difficulty)
	Global.game_settings.difficulty = difficulty

	self:_update_difficulty(difficulty)
end

function MenuLobbyRenderer:_update_difficulty(difficulty)
	Application:debug("_update_difficulty", difficulty)
end

function MenuLobbyRenderer:_verify_player_slot(slot)
	return self._player_slots and self._player_slots[slot] and true or false
end

function MenuLobbyRenderer:set_slot_joining(peer, peer_id)
	if not self:_verify_player_slot(peer_id) then
		return
	end

	managers.hud:set_slot_joining(peer, peer_id)

	local slot = self._player_slots[peer_id]
	slot.peer_id = peer_id
end

function MenuLobbyRenderer:set_slot_ready(peer, peer_id)
	managers.hud:set_slot_ready(peer, peer_id)
end

function MenuLobbyRenderer:set_dropin_progress(peer_id, progress_percentage, mode)
	managers.hud:set_dropin_progress(peer_id, progress_percentage, mode)
end

function MenuLobbyRenderer:set_slot_not_ready(peer, peer_id)
	managers.hud:set_slot_not_ready(peer, peer_id)
end

function MenuLobbyRenderer:set_player_slots_kit(slot)
	if not self:_verify_player_slot(slot) then
		return
	end

	local peer_id = self._player_slots[slot].peer_id

	Application:debug("set_player_slots_kit", slot)
end

function MenuLobbyRenderer:set_slot_outfit(slot, criminal_name, outfit_string)
	if not self:_verify_player_slot(slot) then
		return
	end

	local outfit = managers.blackmarket:unpack_outfit_from_string(outfit_string)
	self._player_slots[slot].outfit = outfit

	managers.menu_component:set_slot_outfit_mission_briefing_gui(slot, criminal_name, outfit)
	managers.hud:set_slot_outfit(slot, criminal_name, outfit)
end

function MenuLobbyRenderer:set_kit_selection(peer_id, category, id, slot)
	managers.hud:set_kit_selection(peer_id, category, id, slot)
	Application:debug("set_kit_selection", peer_id, category, id, slot)
end

function MenuLobbyRenderer:set_slot_voice(peer, peer_id, active)
	managers.hud:set_slot_voice(peer, peer_id, active)
end

function MenuLobbyRenderer:_set_player_slot(nr, params)
	if not self:_verify_player_slot(nr) then
		return
	end

	local slot = self._player_slots[nr]
	slot.free = false
	slot.peer_id = params.peer_id
	slot.params = params

	managers.hud:set_player_slot(nr, params)
end

function MenuLobbyRenderer:remove_player_slot_by_peer_id(peer, reason)
	if not self._player_slots then
		return
	end

	local peer_id = peer:id()

	for _, slot in ipairs(self._player_slots) do
		if slot.peer_id == peer_id then
			slot.peer_id = nil
			slot.params = nil
			slot.outfit = nil
			slot.free = true
			slot.join_msg_shown = nil

			managers.hud:remove_player_slot_by_peer_id(peer, reason)
			managers.menu_component:set_slot_outfit_mission_briefing_gui(peer_id)

			break
		end
	end
end

function MenuLobbyRenderer:set_character(id, character)
	Application:debug("set_character", id, character)
end

function MenuLobbyRenderer:set_choose_character_enabled(enabled)
	for _, node in ipairs(self._logic._node_stack) do
		for _, item in ipairs(node:items()) do
			if item:parameters().name == "choose_character" then
				item:set_enabled(enabled)

				break
			end
		end
	end
end

function MenuLobbyRenderer:set_server_state(state)
	local s = ""

	if state == "loading" then
		s = string.upper(managers.localization:text("menu_lobby_server_state_loading"))

		self:set_choose_character_enabled(false)
	end

	local msg = managers.localization:text("menu_lobby_messenger_title") .. managers.localization:text("menu_lobby_message_server_is_loading")

	self:sync_chat_message(msg, 1)
end

function MenuLobbyRenderer:on_request_lobby_slot_reply()
	local local_peer = managers.network:session():local_peer()
	local local_peer_id = local_peer:id()
	local level = managers.experience:current_level()
	local rank = managers.experience:current_rank()
	local join_stinger_index = managers.infamy:selected_join_stinger_index()
	local character = local_peer:character()
	local progress = managers.upgrades:progress()
	local mask_set = "remove"

	self:_set_player_slot(local_peer_id, {
		name = local_peer:name(),
		peer_id = local_peer_id,
		level = level,
		rank = rank,
		join_stinger_index = join_stinger_index,
		character = character,
		progress = progress
	})
	managers.network:session():send_to_peers_loaded("lobby_info", level, rank, join_stinger_index, character, mask_set)
	managers.network:session():send_to_peers_loaded("sync_profile", level, rank)
	managers.network:session():check_send_outfit()
end

function MenuLobbyRenderer:get_player_slot_by_peer_id(id)
	for _, slot in ipairs(self._player_slots) do
		if slot.peer_id and slot.peer_id == id then
			return slot
		end
	end

	return self._player_slots[id]
end

function MenuLobbyRenderer:get_player_slot_nr_by_peer_id(id)
	for i, slot in ipairs(self._player_slots) do
		if slot.peer_id and slot.peer_id == id then
			return i
		end
	end

	return nil
end

function MenuLobbyRenderer:sync_chat_message(message, id)
	Application:debug("sync_chat_message", message, id)

	for _, node_gui in ipairs(self._node_gui_stack) do
		local row_item_chat = node_gui:row_item_by_name("chat")

		if row_item_chat then
			node_gui:sync_say(message, row_item_chat, id)

			return true
		end
	end

	return false
end

function MenuLobbyRenderer:update(t, dt)
	MenuLobbyRenderer.super.update(self, t, dt)
end

function MenuLobbyRenderer:highlight_item(item, ...)
	MenuLobbyRenderer.super.highlight_item(self, item, ...)
end

function MenuLobbyRenderer:trigger_item(item)
	MenuRenderer.super.trigger_item(self, item)
	Application:debug("trigger_item", item)

	if item and item:parameters().sound ~= "false" then
		local item_type = item:type()

		if item_type == "" then
			self:post_event("menu_enter")
		elseif item_type == "toggle" then
			if item:value() == "on" then
				self:post_event("box_tick")
			else
				self:post_event("box_untick")
			end
		elseif item_type == "slider" then
			local percentage = item:percentage()

			if percentage > 0 and percentage < 100 then
				-- Nothing
			end
		elseif item_type == "grid" then
			-- Nothing
		elseif item_type == "multi_choice" then
			-- Nothing
		end
	end
end

function MenuLobbyRenderer:post_event(event)
	self._sound_source:post_event(event)
end

function MenuLobbyRenderer:navigate_back()
	MenuLobbyRenderer.super.navigate_back(self)
	self:post_event("menu_exit")
end

function MenuLobbyRenderer:resolution_changed(...)
	MenuLobbyRenderer.super.resolution_changed(self, ...)
end

function MenuLobbyRenderer:_layout_menu_bg()
	local res = RenderSettings.resolution
	local safe_rect_pixels = managers.gui_data:scaled_size()

	self._menu_bg:set_size(self._fullscreen_panel:h() * 2, self._fullscreen_panel:h())
	self._menu_bg:set_position(0, 0)
	self:set_stencil_align(self._menu_stencil_align, self._menu_stencil_align_percent)
end

function MenuLobbyRenderer:_layout_slot_progress_panel(slot, progress)
	print("MenuLobbyRenderer:_layout_slot_progress_panel()", slot, progress)

	local h = 16
	local sh = 4

	if progress[4] then
		h = 17
		sh = 3
	end

	slot.p_panel:set_size(38 * tweak_data.scale.lobby_info_offset_multiplier, h)
	slot.p_bg:set_size(slot.p_panel:size())
	slot.p_ass_bg:set_size(slot.p_panel:w() - 2, sh)
	slot.p_sha_bg:set_size(slot.p_panel:w() - 2, sh)
	slot.p_sup_bg:set_size(slot.p_panel:w() - 2, sh)
	slot.p_tec_bg:set_size(slot.p_panel:w() - 2, sh)

	if progress[4] then
		slot.p_tec:set_visible(true)
		slot.p_tec_bg:set_visible(true)
		slot.p_ass_bg:set_position(1, 1)
		slot.p_sha_bg:set_position(1, 5)
		slot.p_sup_bg:set_position(1, 9)
		slot.p_tec_bg:set_position(1, 13)
	else
		slot.p_tec:set_visible(false)
		slot.p_tec_bg:set_visible(false)
		slot.p_ass_bg:set_position(1, 1)
		slot.p_sha_bg:set_position(1, 6)
		slot.p_sup_bg:set_position(1, 11)
	end

	slot.p_ass:set_shape(slot.p_ass_bg:shape())
	slot.p_sha:set_shape(slot.p_sha_bg:shape())
	slot.p_sup:set_shape(slot.p_sup_bg:shape())
	slot.p_tec:set_shape(slot.p_tec_bg:shape())
	slot.p_ass:set_w(slot.params and slot.p_ass_bg:w() * progress[1] / 49 or slot.p_ass:w())
	slot.p_sha:set_w(slot.params and slot.p_sha_bg:w() * progress[2] / 49 or slot.p_sha:w())
	slot.p_sup:set_w(slot.params and slot.p_sup_bg:w() * progress[3] / 49 or slot.p_sup:w())
	slot.p_tec:set_w(slot.params and slot.p_sup_bg:w() * (progress[4] or 0) / 49 or slot.p_tec:w())
end

function MenuLobbyRenderer:_layout_info_panel()
	local res = RenderSettings.resolution
	local safe_rect = managers.gui_data:scaled_size()
	local is_single_player = Global.game_settings.single_player
	local is_multiplayer = not is_single_player

	self._gui_info_panel:set_shape(self._info_bg_rect:x() + tweak_data.menu.info_padding, self._info_bg_rect:y() + tweak_data.menu.info_padding, self._info_bg_rect:w() - tweak_data.menu.info_padding * 2, self._info_bg_rect:h() - tweak_data.menu.info_padding * 2)

	local font_size = tweak_data.menu.lobby_info_font_size
	local offset = 22 * tweak_data.scale.lobby_info_offset_multiplier

	self._server_title:set_font_size(font_size)
	self._server_text:set_font_size(font_size)

	local x, y, w, h = self._server_title:text_rect()

	self._server_title:set_x(tweak_data.menu.info_padding)
	self._server_title:set_y(tweak_data.menu.info_padding)
	self._server_title:set_w(w)
	self._server_text:set_lefttop(self._server_title:righttop())
	self._server_text:set_w(self._gui_info_panel:w())
	self._server_info_title:set_font_size(font_size)
	self._server_info_text:set_font_size(font_size)

	local x, y, w, h = self._server_info_title:text_rect()

	self._server_info_title:set_x(tweak_data.menu.info_padding)
	self._server_info_title:set_y(tweak_data.menu.info_padding + offset)
	self._server_info_title:set_w(w)
	self._server_info_text:set_lefttop(self._server_info_title:righttop())
	self._server_info_text:set_w(self._gui_info_panel:w())
	self._level_title:set_font_size(font_size)
	self._level_text:set_font_size(font_size)

	local x, y, w, h = self._level_title:text_rect()

	self._level_title:set_x(tweak_data.menu.info_padding)
	self._level_title:set_y(is_multiplayer and tweak_data.menu.info_padding + offset * 2 or tweak_data.menu.info_padding)
	self._level_title:set_w(w)
	self._level_text:set_lefttop(self._level_title:righttop())
	self._level_text:set_w(self._gui_info_panel:w())
	self._difficulty_title:set_font_size(font_size)
	self._difficulty_text:set_font_size(font_size)

	local x, y, w, h = self._difficulty_title:text_rect()

	self._difficulty_title:set_x(tweak_data.menu.info_padding)
	self._difficulty_title:set_y(tweak_data.menu.info_padding + offset * (is_multiplayer and 3 or 1))
	self._difficulty_title:set_w(w)
	self._difficulty_text:set_lefttop(self._difficulty_title:righttop())
	self._difficulty_text:set_w(self._gui_info_panel:w())
end

function MenuLobbyRenderer:_layout_video()
	if self._level_video then
		local w = self._gui_info_panel:w()
		local m = self._level_video:video_width() / self._level_video:video_height()

		self._level_video:set_size(w, w / m)
		self._level_video:set_y(0)
		self._level_video:set_center_x(self._gui_info_panel:w() / 2)
	end
end

function MenuLobbyRenderer:set_bg_visible(visible)
	self._menu_bg:set_visible(visible)
end

function MenuLobbyRenderer:set_bg_area(area)
	if self._menu_bg then
		if area == "full" then
			self._menu_bg:set_size(self._menu_bg:parent():size())
			self._menu_bg:set_position(0, 0)
		elseif area == "half" then
			self._menu_bg:set_size(self._menu_bg:parent():w() * 0.5, self._menu_bg:parent():h())
			self._menu_bg:set_top(0)
			self._menu_bg:set_right(self._menu_bg:parent():w())
		else
			self._menu_bg:set_size(self._menu_bg:parent():size())
			self._menu_bg:set_position(0, 0)
		end
	end
end

function MenuLobbyRenderer:set_stencil_image(image)
	MenuRenderer.set_stencil_image(self, image)
end

function MenuLobbyRenderer:refresh_theme()
	MenuRenderer.refresh_theme(self)
end

function MenuLobbyRenderer:set_stencil_align(align, percent)
	if not self._menu_stencil then
		return
	end

	local d = self._menu_stencil:texture_height()

	if d == 0 then
		return
	end

	self._menu_stencil_align = align
	self._menu_stencil_align_percent = percent
	local res = RenderSettings.resolution
	local safe_rect_pixels = managers.gui_data:scaled_size()
	local y = safe_rect_pixels.height - tweak_data.load_level.upper_saferect_border * 2 + 2
	local m = self._menu_stencil:texture_width() / self._menu_stencil:texture_height()

	self._menu_stencil:set_size(y * m, y)
	self._menu_stencil:set_center_y(res.y / 2)

	local w = self._menu_stencil:texture_width()
	local h = self._menu_stencil:texture_height()

	if align == "right" then
		self._menu_stencil:set_texture_rect(0, 0, w, h)
		self._menu_stencil:set_right(res.x)
	elseif align == "left" then
		self._menu_stencil:set_texture_rect(0, 0, w, h)
		self._menu_stencil:set_left(0)
	elseif align == "center" then
		self._menu_stencil:set_texture_rect(0, 0, w, h)
		self._menu_stencil:set_center_x(res.x / 2)
	elseif align == "center-right" then
		self._menu_stencil:set_texture_rect(0, 0, w, h)
		self._menu_stencil:set_center_x(res.x * 0.66)
	elseif align == "center-left" then
		self._menu_stencil:set_texture_rect(0, 0, w, h)
		self._menu_stencil:set_center_x(res.x * 0.33)
	elseif align == "manual" then
		self._menu_stencil:set_texture_rect(0, 0, w, h)

		percent = percent / 100

		self._menu_stencil:set_left(res.x * percent - y * m * percent)
	end
end

function MenuLobbyRenderer:current_menu_text(topic_id)
	local ids = {}

	for i, node_gui in ipairs(self._node_gui_stack) do
		table.insert(ids, node_gui.node:parameters().topic_id)
	end

	table.insert(ids, topic_id)

	local s = ""

	for i, id in ipairs(ids) do
		s = s .. managers.localization:text(id)
		s = s .. (i < #ids and " > " or "")
	end

	return s
end

function MenuLobbyRenderer:scroll_up(...)
	MenuRenderer.scroll_up(self, ...)
end

function MenuLobbyRenderer:scroll_down(...)
	MenuRenderer.scroll_down(self, ...)
end

function MenuLobbyRenderer:accept_input(...)
	MenuRenderer.accept_input(self, ...)
end

function MenuLobbyRenderer:mouse_pressed(...)
	return MenuRenderer.mouse_pressed(self, ...)
end

function MenuLobbyRenderer:mouse_released(...)
	return MenuRenderer.mouse_released(self, ...)
end

function MenuLobbyRenderer:mouse_moved(...)
	return MenuRenderer.mouse_moved(self, ...)
end

function MenuLobbyRenderer:input_focus(...)
	return MenuRenderer.input_focus(self, ...)
end

function MenuLobbyRenderer:move_up(...)
	return MenuRenderer.move_up(self, ...)
end

function MenuLobbyRenderer:move_down(...)
	return MenuRenderer.move_down(self, ...)
end

function MenuLobbyRenderer:move_left(...)
	return MenuRenderer.move_left(self, ...)
end

function MenuLobbyRenderer:move_right(...)
	return MenuRenderer.move_right(self, ...)
end

function MenuLobbyRenderer:next_page(...)
	return MenuRenderer.next_page(self, ...)
end

function MenuLobbyRenderer:previous_page(...)
	return MenuRenderer.previous_page(self, ...)
end

function MenuLobbyRenderer:confirm_pressed(...)
	return MenuRenderer.confirm_pressed(self, ...)
end

function MenuLobbyRenderer:special_btn_pressed(...)
	return managers.menu_component:special_btn_pressed(...)
end

function MenuLobbyRenderer:special_btn_released(...)
	return managers.menu_component:special_btn_released(...)
end

function MenuLobbyRenderer:back_pressed(...)
	return MenuRenderer.back_pressed(self, ...)
end

function MenuLobbyRenderer:mouse_clicked(...)
	return MenuRenderer.mouse_clicked(self, ...)
end

function MenuLobbyRenderer:mouse_double_click(...)
	return MenuRenderer.mouse_double_click(self, ...)
end
