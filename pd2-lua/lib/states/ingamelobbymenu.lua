core:import("CoreUnit")
require("lib/states/GameState")

IngameLobbyMenuState = IngameLobbyMenuState or class(GameState)
IngameLobbyMenuState.GUI_LOOTSCREEN = Idstring("guis/lootscreen/lootscreen_fullscreen")
IngameLobbyMenuState.GUI_LOOTSCREEN_SKIRMISH = Idstring("guis/dlcs/shl/lootscreen/lootscreen_fullscreen")

function IngameLobbyMenuState:init(game_state_machine)
	GameState.init(self, "ingame_lobby_menu", game_state_machine)

	if managers.hud then
		self._setup = true

		managers.hud:load_hud_menu(self.GUI_LOOTSCREEN, false, true, false, {}, nil, nil, true)
		managers.hud:hide(self.GUI_LOOTSCREEN)
	end

	self._continue_cb = callback(self, self, "_continue")
end

function IngameLobbyMenuState:setup_controller()
	if not self._controller then
		self._controller = managers.controller:create_controller("ingame_lobby_menu", managers.controller:get_default_wrapper_index(), false)

		if Network:is_server() or managers.dlc:is_trial() then
			self._controller:add_trigger("continue", self._continue_cb)
		end

		self._controller:set_enabled(true)
	end
end

function IngameLobbyMenuState:_clear_controller()
	if not self._controller then
		return
	end

	if Network:is_server() or managers.dlc:is_trial() then
		self._controller:remove_trigger("continue", self._continue_cb)
	end

	self._controller:set_enabled(false)
	self._controller:destroy()

	self._controller = nil
end

function IngameLobbyMenuState:_continue()
	self:continue()
end

function IngameLobbyMenuState:continue()
	if self:_continue_blocked() then
		return
	end

	if managers.network:session() and Network:is_server() then
		managers.network.matchmake:set_server_joinable(true)
	end

	if Global.game_settings.single_player then
		MenuCallbackHandler:_dialog_end_game_yes()
	elseif Network:is_server() or managers.dlc:is_trial() then
		MenuCallbackHandler:load_start_menu_lobby()
	else
		setup:load_start_menu()
	end
end

function IngameLobbyMenuState:_continue_blocked()
	local in_focus = managers.menu:active_menu() == self._loot_menu

	if not in_focus then
		return true
	end

	if managers.hud:showing_stats_screen() then
		return true
	end

	if managers.system_menu:is_active() then
		return true
	end

	if managers.menu_component:input_focus() == 1 then
		return true
	end

	if Application:time() < self._continue_block_timer then
		return true
	end

	return false
end

function IngameLobbyMenuState:set_controller_enabled(enabled)
	if self._controller then
		-- Nothing
	end
end

function IngameLobbyMenuState:update(t, dt)
	if self._is_generating_skirmish_lootdrop and managers.skirmish:has_finished_generating_additional_rewards() then
		self._is_generating_skirmish_lootdrop = nil
		local lootdrops = managers.skirmish:get_generated_lootdrops()
		local lootdrop_data = {
			peer = managers.network:session() and managers.network:session():local_peer(),
			items = lootdrops.items or {},
			coins = lootdrops.coins or 0
		}

		if self._inventory_reward then
			table.insert(lootdrop_data.items, 1, self._inventory_reward)

			self._inventory_reward = nil
		end

		managers.hud:make_lootdrop_hud(lootdrop_data)

		if not Global.game_settings.single_player and managers.network:session() then
			local lootdrop_string = ""
			lootdrop_string = lootdrop_string .. tostring(lootdrops.coins or 0)
			local global_index = nil
			local global_values = tweak_data.lootdrop.global_value_list_map

			for _, item in ipairs(lootdrops.items or {}) do
				global_index = global_values[item.global_value] or 1
				lootdrop_string = lootdrop_string .. " " .. tostring(global_index) .. "-" .. tostring(item.type_items) .. "-" .. tostring(item.item_entry)
			end

			managers.network:session():send_to_peers("feed_lootdrop_skirmish", lootdrop_string)
		end
	end
end

function IngameLobbyMenuState:at_enter()
	managers.music:stop()
	managers.platform:set_presence("Mission_end")
	managers.platform:set_rich_presence(Global.game_settings.single_player and "SPEnd" or "MPEnd")
	managers.hud:remove_updator("point_of_no_return")
	print("[IngameLobbyMenuState:at_enter()]")

	if managers.network:session() and Network:is_server() then
		managers.network.matchmake:set_server_state("in_lobby")
		managers.network:session():set_state("in_lobby")
	end

	managers.mission:pre_destroy()

	self._continue_block_timer = Application:time() + 0.5

	managers.menu:close_menu("pause_menu")

	if managers.job:stage_success() then
		managers.job:next_stage()
	end

	if managers.job:is_job_finished() then
		self:load_loothud(true)
		self:open_lootscreen()
		self:make_lootdrop()
	elseif Network:is_client() then
		self:load_loothud(false)
		self:open_lootscreen()
	end

	if (Network:is_server() or managers.dlc:is_trial()) and not managers.job:is_job_finished() then
		if managers.network:session() and Network:is_server() then
			managers.network.matchmake:set_server_joinable(true)
		end

		if not managers.job:stage_success() then
			if managers.job:is_current_job_professional() then
				MenuCallbackHandler:load_start_menu_lobby()
			else
				managers.game_play_central:restart_the_game()
			end
		else
			MenuCallbackHandler:on_stage_success()
			MenuCallbackHandler:start_the_game()
		end
	end
end

function IngameLobbyMenuState:load_loothud_skirmish(should_show)
	if not self._setup then
		self._setup = true

		managers.hud:load_hud(self.GUI_LOOTSCREEN_SKIRMISH, false, true, false, {}, nil, nil, true)
	end

	if should_show then
		managers.hud:show(self.GUI_LOOTSCREEN_SKIRMISH)
	else
		managers.hud:hide(self.GUI_LOOTSCREEN_SKIRMISH)
	end
end

function IngameLobbyMenuState:load_loothud(should_show)
	local gui_lootscreen = self.GUI_LOOTSCREEN

	if managers.skirmish:is_skirmish() then
		gui_lootscreen = self.GUI_LOOTSCREEN_SKIRMISH
	end

	if not self._setup then
		self._setup = true

		managers.hud:load_hud(gui_lootscreen, false, true, false, {}, nil, nil, true)
	end

	if should_show then
		managers.hud:show(gui_lootscreen)
	else
		managers.hud:hide(gui_lootscreen)
	end
end

function IngameLobbyMenuState:open_lootscreen()
	managers.menu:open_menu("loot_menu")

	self._loot_menu = managers.menu:get_menu("loot_menu")

	managers.menu_component:set_max_lines_game_chat(6)
	managers.menu_component:pre_set_game_chat_leftbottom(0, 0)
end

function IngameLobbyMenuState:make_lootdrop()
	if managers.skirmish:is_skirmish() then
		local amount_cards = managers.skirmish:get_amount_rewards()

		managers.hud:make_skirmish_cards_hud(managers.network:session() and managers.network:session():local_peer(), amount_cards)

		if not Global.game_settings.single_player and managers.network:session() then
			managers.network:session():send_to_peers("make_lootdrop_skirmish", amount_cards)
		end
	else
		local max_pc = managers.experience:level_to_stars()
		local disable_weapon_mods = not managers.lootdrop:can_drop_weapon_mods() and true or nil
		local card_left_pc = managers.lootdrop:new_fake_loot_pc(nil, {
			weapon_mods = disable_weapon_mods
		})
		local card_right_pc = managers.lootdrop:new_fake_loot_pc(nil, {
			weapon_mods = disable_weapon_mods
		})

		managers.hud:make_cards_hud(managers.network:session() and managers.network:session():local_peer(), max_pc, card_left_pc, card_right_pc)

		if not Global.game_settings.single_player and managers.network:session() then
			managers.network:session():send_to_peers("feed_lootdrop", 1, "", "", max_pc, 0, card_left_pc, card_right_pc)
		end
	end

	self:_set_lootdrop()
end

function IngameLobbyMenuState:_set_lootdrop()
	if not managers.network.account:inventory_reward(callback(self, self, "_clbk_inventory_reward")) then
		self:set_lootdrop()
	end
end

function IngameLobbyMenuState:_clbk_inventory_reward(error, tradable_list)
	if error then
		Application:error("[IngameLobbyMenuState:_clbk_inventory_reward] Failed to reward tradable item (" .. tostring(error) .. ")")
	end

	local drop_category, drop_entry = nil

	managers.network.account:inventory_repair_list(tradable_list)

	if tradable_list and table.size(tradable_list) > 0 then
		print("[IngameLobbyMenuState:_clbk_inventory_reward]", tradable_list[1].category, tradable_list[1].entry, tradable_list[1].instance_id, tradable_list[1].amount, table.size(tradable_list))

		drop_category = tradable_list[1].category
		drop_entry = tradable_list[1].entry
	end

	self:set_lootdrop(drop_category, drop_entry)
end

function IngameLobbyMenuState:set_lootdrop_skirmish(drop_category, drop_item_id)
	local got_inventory_reward = drop_item_id ~= nil

	if got_inventory_reward then
		self._inventory_reward = {
			global_value = managers.blackmarket:get_global_value(drop_category, drop_item_id),
			type_items = drop_category,
			item_entry = drop_item_id
		}
	end

	managers.skirmish:make_lootdrops(got_inventory_reward)

	self._is_generating_skirmish_lootdrop = true
end

function IngameLobbyMenuState:set_lootdrop(drop_category, drop_item_id)
	if managers.skirmish:is_skirmish() then
		self:set_lootdrop_skirmish(drop_category, drop_item_id)

		return
	end

	local global_value, item_category, item_id, max_pc, item_pc = nil
	local allow_loot_drop = true
	allow_loot_drop = not managers.crime_spree:is_active()

	if drop_item_id and drop_category then
		global_value = managers.blackmarket:get_global_value(drop_category, drop_item_id)
		item_category = drop_category
		item_id = drop_item_id
		max_pc = math.max(math.ceil(managers.experience:current_level() / 10), 1)
		item_pc = math.ceil(4)
	elseif allow_loot_drop then
		self._lootdrop_data = {}

		managers.lootdrop:new_make_drop(self._lootdrop_data)

		global_value = self._lootdrop_data.global_value or "normal"
		item_category = self._lootdrop_data.type_items
		item_id = self._lootdrop_data.item_entry
		max_pc = self._lootdrop_data.total_stars
		item_pc = self._lootdrop_data.joker and 0 or math.ceil(self._lootdrop_data.item_payclass / 10)
	end

	local peer = managers.network:session() and managers.network:session():local_peer() or false
	local disable_weapon_mods = not managers.lootdrop:can_drop_weapon_mods() and true or nil
	local card_left_pc = managers.lootdrop:new_fake_loot_pc(nil, {
		weapon_mods = disable_weapon_mods
	})
	local card_right_pc = managers.lootdrop:new_fake_loot_pc(nil, {
		weapon_mods = disable_weapon_mods
	})
	local lootdrop_data = {
		peer,
		global_value,
		item_category,
		item_id,
		max_pc,
		item_pc,
		card_left_pc,
		card_right_pc
	}

	managers.hud:make_lootdrop_hud(lootdrop_data)

	if not Global.game_settings.single_player and managers.network:session() then
		local global_values = tweak_data.lootdrop.global_value_list_map
		local global_index = global_values[global_value] or 1

		managers.network:session():send_to_peers("feed_lootdrop", global_index, item_category, item_id, max_pc, item_pc, card_left_pc, card_right_pc)
	end
end

function IngameLobbyMenuState:at_exit()
	print("[IngameLobbyMenuState:at_exit()]")

	if managers.job:is_job_finished() then
		managers.menu:close_menu("loot_menu")
		managers.hud:hide(self.GUI_LOOTSCREEN)
	end

	managers.menu_component:hide_game_chat_gui()
end

function IngameLobbyMenuState:on_server_left()
	Application:debug("IngameLobbyMenuState:on_server_left()")
	managers.menu_component:set_lootdrop_state("on_server_left")
end

function IngameLobbyMenuState:on_kicked()
	Application:debug("IngameLobbyMenuState:on_kicked()")
	managers.menu_component:set_lootdrop_state("on_kicked")
end

function IngameLobbyMenuState:on_disconnected()
	Application:debug("IngameLobbyMenuState:on_disconnected()")
	managers.menu_component:set_lootdrop_state("on_disconnected")
end
