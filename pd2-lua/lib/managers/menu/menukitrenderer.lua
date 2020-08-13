core:import("CoreMenuNodeGui")
require("lib/managers/menu/MenuNodeKitGui")

MenuKitRenderer = MenuKitRenderer or class(MenuLobbyRenderer)

function MenuKitRenderer:init(logic)
	local parameters = {
		layer = 200
	}

	MenuRenderer.init(self, logic, parameters)
end

function MenuKitRenderer:_setup_bg()
end

function MenuKitRenderer:show_node(node)
	local gui_class = MenuNodeKitGui

	if node:parameters().gui_class then
		gui_class = CoreSerialize.string_to_classtable(node:parameters().gui_class)
	end

	local parameters = {
		marker_alpha = 0.6,
		align = "right",
		row_item_blend_mode = "add",
		to_upper = true,
		row_item_color = tweak_data.screen_colors.button_stage_3,
		row_item_hightlight_color = tweak_data.screen_colors.button_stage_2,
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		node_gui_class = gui_class,
		spacing = node:parameters().spacing,
		marker_color = tweak_data.screen_colors.button_stage_3:with_alpha(0.2)
	}

	MenuKitRenderer.super.super.show_node(self, node, parameters)
	self:_update_slots_info()
end

function MenuKitRenderer:open(...)
	self._all_items_enabled = true
	self._no_stencil = true
	self._server_state_string_id = "menu_lobby_server_state_in_game"

	MenuKitRenderer.super.open(self, ...)

	if self._player_slots then
		for _, slot in ipairs(self._player_slots) do
			-- Nothing
		end
	end
end

function MenuKitRenderer:_update_slots_info()
	print("MenuKitRenderer:_update_slots_info")

	local kit_menu = managers.menu:get_menu("kit_menu")

	if kit_menu then
		local id = managers.network:session():local_peer():id()
		local criminal_name = managers.network:session():local_peer():character()

		kit_menu.renderer:set_slot_outfit(id, criminal_name, managers.blackmarket:outfit_string())
	end

	for peer_id, peer in pairs(managers.network:session():peers()) do
		if not peer:loading() and peer:is_streaming_complete() then
			if peer:waiting_for_player_ready() then
				self:set_slot_ready(peer, peer_id)
			else
				self:set_slot_not_ready(peer, peer_id)
			end
		else
			self:set_slot_joining(peer, peer_id)
		end
	end
end

function MenuKitRenderer:_entered_menu()
	self:on_request_lobby_slot_reply()

	local kit_menu = managers.menu:get_menu("kit_menu")

	if kit_menu then
		local id = managers.network:session():local_peer():id()
		local criminal_name = managers.network:session():local_peer():character()

		kit_menu.renderer:set_slot_outfit(id, criminal_name, managers.blackmarket:outfit_string())
	end

	for peer_id, peer in pairs(managers.network:session():peers()) do
		self:set_slot_joining(peer, peer_id)
	end
end

function MenuKitRenderer:_set_player_slot(nr, params)
	local peer = managers.network:session():peer(nr)
	local ready = peer:waiting_for_player_ready()
	params.status = string.upper(managers.localization:text(ready and "menu_waiting_is_ready" or "menu_waiting_is_not_ready"))
	params.kit_panel_visible = true

	MenuKitRenderer.super._set_player_slot(self, nr, params)
end

function MenuKitRenderer:highlight_item(item, ...)
	MenuKitRenderer.super.highlight_item(self, item, ...)
	self:post_event("highlight")
end

function MenuKitRenderer:trigger_item(item)
	MenuKitRenderer.super.trigger_item(self, item)

	local node_gui = self:active_node_gui()

	if node_gui and node_gui.trigger_item then
		node_gui:trigger_item(item)
	end
end

function MenuKitRenderer:sync_chat_message(message, id)
	for _, node_gui in ipairs(self._node_gui_stack) do
		local row_item_chat = node_gui:row_item_by_name("chat")

		if row_item_chat then
			node_gui:sync_say(message, row_item_chat, id)

			return true
		end
	end

	return false
end

function MenuKitRenderer:set_all_items_enabled(enabled)
	self._all_items_enabled = enabled

	for _, node in ipairs(self._logic._node_stack) do
		for _, item in ipairs(node:items()) do
			if item:type() == "kitslot" or item:type() == "toggle" then
				item:set_enabled(enabled)
			end
		end
	end
end

function MenuKitRenderer:set_ready_items_enabled(enabled)
	if not self._all_items_enabled then
		return
	end

	for _, node in ipairs(self._logic._node_stack) do
		for _, item in ipairs(node:items()) do
			if item:type() == "kitslot" then
				item:set_enabled(enabled)
			end
		end
	end
end

function MenuKitRenderer:set_bg_visible(visible)
	if self._menu_bg then
		self._menu_bg:set_visible(visible)
	end
end

function MenuKitRenderer:set_bg_area(area)
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

function MenuKitRenderer:set_slot_joining(peer, peer_id)
	MenuKitRenderer.super.set_slot_joining(self, peer, peer_id)
	managers.preplanning:on_peer_added(peer_id)
end

function MenuKitRenderer:remove_player_slot_by_peer_id(peer, reason)
	MenuKitRenderer.super.remove_player_slot_by_peer_id(self, peer, reason)

	local peer_id = peer:id()

	managers.preplanning:on_peer_removed(peer_id)
	managers.assets:on_peer_removed(peer_id)
end

function MenuKitRenderer:close(...)
	MenuKitRenderer.super.close(self, ...)
end
