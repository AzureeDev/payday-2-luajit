require("lib/managers/menu/MenuBackdropGUI")
require("lib/managers/menu/ExtendedUiElemets")

local massive_font = tweak_data.menu.pd2_massive_font
local large_font = tweak_data.menu.pd2_large_font
local medium_font = tweak_data.menu.pd2_medium_font
local small_font = tweak_data.menu.pd2_small_font
local massive_font_size = tweak_data.menu.pd2_massive_font_size
local large_font_size = tweak_data.menu.pd2_large_font_size
local medium_font_size = tweak_data.menu.pd2_medium_font_size
local small_font_size = tweak_data.menu.pd2_small_font_size
local PADDING = 10
local SMALL_PADDING = PADDING / 2
local PANEL_Y = 40
local PANEL_HEIGHT_SUB = 150 + PANEL_Y
local CARDS_PER_ROW = 3
local NUM_OF_ROWS = 4
local FLIP_START_TIME = 3
local FLIP_DELAY = 0.1
local REWARD_LIST_WAIT_TIME = 3.5
local REWARD_FADE_IN_TIME = 0.5
local CARD_TYPES = {
	weapon_mods = "upcard_weapon",
	xp = "upcard_xp",
	materials = "upcard_material",
	safes = "upcard_safe",
	weapon_color_skins = "upcard_cosmetic",
	masks = "upcard_mask",
	cash = "upcard_cash",
	armor_skins = "upcard_cosmetic",
	coins = "upcard_coins",
	colors = "upcard_color",
	textures = "upcard_pattern",
	weapon_skins = "upcard_cosmetic",
	drills = "upcard_drill",
	weapon_bonus = "upcard_weapon_bonus"
}

local function add_reward_text(panel, text, color)
	return panel:placer():add_row(FineText:new(panel, {
		alpha = 1,
		wrap = true,
		word_wrap = true,
		layer = 1,
		w = panel:w(),
		text = text,
		font = small_font,
		font_size = small_font_size,
		color = color or tweak_data.screen_colors.text
	}))
end

local function flip_card_animation(panel, item_type)
	local card = panel:child("card_icon")
	local item_panel = panel:child("item_panel")
	local start_rot = card:rotation()
	local start_w = card:w()
	local cx, cy = card:center()
	local start_rotation = card:rotation()
	local end_rotation = start_rotation * -1
	local diff = end_rotation - start_rotation

	managers.menu_component:post_event("loot_flip_card")
	over(0.25, function (p)
		card:set_rotation(start_rotation + math.sin(p * 45) * diff)

		if card:rotation() == 0 then
			card:set_rotation(360)
		end

		card:set_w(start_w * math.cos(p * 90))
		card:set_center(cx, cy)
	end)

	local texture, rect = tweak_data.hud_icons:get_icon_data(item_type or "downcard_overkill_deck")

	card:set_image(texture)
	card:set_texture_rect(unpack(rect))
	over(0.25, function (p)
		card:set_rotation(start_rotation + math.sin(p * 45 + 45) * diff)

		if card:rotation() == 0 then
			card:set_rotation(360)
		end

		card:set_w(start_w * math.sin(p * 90))
		card:set_center(cx, cy)
	end)
	wait(2)
	item_panel:set_visible(true)
	item_panel:set_alpha(0)
	over(0.25, function (p)
		card:set_alpha(1 - p)
		item_panel:set_alpha(p)
	end)
	card:set_visible(false)
end

local function get_local_peer_id()
	return Global.game_settings.single_player and 1 or managers.network:session() and managers.network:session():local_peer():id() or 1
end

HUDLootScreenSkirmish = HUDLootScreenSkirmish or class()

function HUDLootScreenSkirmish:init(hud, workspace, saved_lootdrop, saved_setup)
	self._backdrop = MenuBackdropGUI:new(workspace)

	if not _G.IS_VR then
		self._backdrop:create_black_borders()
	end

	self._active = false
	self._hud = hud
	self._workspace = workspace
	self._background_layer_safe = self._backdrop:get_new_background_layer()
	self._background_layer_full = self._backdrop:get_new_background_layer()
	self._foreground_layer_safe = self._backdrop:get_new_foreground_layer()
	self._foreground_layer_full = self._backdrop:get_new_foreground_layer()
	self._baselayer_two = self._backdrop:get_new_base_layer()

	self._backdrop:set_panel_to_saferect(self._background_layer_safe)
	self._backdrop:set_panel_to_saferect(self._foreground_layer_safe)

	self._callback_handler = self._callback_handler or {}
	local title_text = FineText:new(self._foreground_layer_safe, {
		name = "title_text",
		align = "left",
		vertical = "top",
		text = managers.localization:to_upper_text("menu_l_lootscreen"),
		font_size = large_font_size,
		font = large_font,
		color = tweak_data.screen_colors.text
	})
	local title_bg = FineText:new(self._background_layer_full, {
		name = "title_bg",
		alpha = 0.4,
		text = title_text:text(),
		color = tweak_data.screen_colors.button_stage_3,
		font_size = massive_font_size,
		font = massive_font,
		color = tweak_data.screen_colors.button_stage_3
	})
	local x, y = managers.gui_data:safe_to_full_16_9(title_text:world_x(), title_text:world_center_y())

	title_bg:set_world_left(title_text:world_x())
	title_bg:set_world_center_y(title_text:world_center_y())
	title_bg:move(-13, 9)

	local icon_path, texture_rect = tweak_data.hud_icons:get_icon_data("downcard_overkill_deck")
	self._downcard_icon_path = icon_path
	self._downcard_texture_rect = texture_rect
	self._panel = ExtendedPanel:new(self._foreground_layer_safe)

	self:create_peers()
	self:set_num_visible(get_local_peer_id())

	self._setup = {}

	if saved_setup then
		for _, setup in ipairs(saved_setup) do
			self:make_cards(setup.peer, setup.amount_cards)
		end
	end

	self._lootdrops = {}

	if saved_lootdrop then
		for _, lootdrop in ipairs(saved_lootdrop) do
			self:make_lootdrop(lootdrop)
		end
	end

	self._next_flip_index = 1
	self._wait_t = FLIP_START_TIME
	self._update_t = 0

	self:set_update("_update_flip_cards")
end

function HUDLootScreenSkirmish:create_peers()
	local max_peers = tweak_data.max_players
	local peer_panel_width = (self._panel:w() - PADDING * (max_peers - 1)) / max_peers
	local peer_panel_height = self._panel:h() - PANEL_HEIGHT_SUB
	self._peer_data = {}
	local peer_panel, peer_color, player_infamy, player_text, cards_panel, card_panel, cards, card_w, card_h, reward_list, placer = nil
	self._peers_panel = ExtendedPanel:new(self._panel)
	self._peer_width = peer_panel_width

	for peer_id = 1, max_peers do
		peer_color = tweak_data.chat_colors[peer_id] or tweak_data.chat_colors[#tweak_data.chat_colors]
		placer = UiPlacer:new(SMALL_PADDING, SMALL_PADDING, SMALL_PADDING, PADDING)
		peer_panel = ExtendedPanel:new(self._peers_panel, {
			visible = false,
			x = (peer_id - 1) * (peer_panel_width + PADDING),
			y = PANEL_Y,
			w = peer_panel_width,
			h = peer_panel_height
		})

		peer_panel:rect({
			alpha = 0.1,
			layer = -1,
			color = Color.black
		})

		player_text = placer:add_row(FineText:new(peer_panel, {
			text = " ",
			blend_mode = "add",
			w = peer_panel_width - PADDING,
			font = medium_font,
			font_size = medium_font_size,
			color = peer_color
		}))
		player_infamy = peer_panel:bitmap({
			visible = false,
			h = 16,
			w = 16,
			x = player_text:x(),
			y = player_text:y() + 4,
			color = peer_color
		})
		cards_panel = placer:add_row(GrowPanel:new(peer_panel, {
			border = 0,
			w = peer_panel_width - PADDING,
			h = peer_panel_height - placer:current_bottom() - PADDING - SMALL_PADDING,
			padding = PADDING
		}))
		reward_list = GrowPanel:new(peer_panel, {
			border = 0,
			alpha = 0,
			x = cards_panel:x(),
			y = cards_panel:y(),
			w = cards_panel:w(),
			h = cards_panel:h(),
			padding = SMALL_PADDING
		})
		cards = {}

		for i = 1, CARDS_PER_ROW * NUM_OF_ROWS do
			if i % CARDS_PER_ROW == 1 then
				cards_panel:placer():new_row()
			end

			card_w = (cards_panel:w() - PADDING * (CARDS_PER_ROW - 1)) / CARDS_PER_ROW
			card_h = (cards_panel:h() - PADDING * (NUM_OF_ROWS - 1)) / NUM_OF_ROWS
			card_panel = cards_panel:placer():add_right(cards_panel:panel({
				w = card_w,
				h = card_h
			}))

			table.insert(cards, {
				flipped = false,
				type = false,
				panel = card_panel
			})
		end

		self._peer_data[peer_id] = {
			state = "init",
			active = false,
			panel = peer_panel,
			player_infamy = player_infamy,
			player_text = player_text,
			reward_list = reward_list,
			cards_panel = cards_panel,
			cards = cards,
			patterns = {},
			lootdrops = {
				coins = 0,
				items = {}
			}
		}
	end
end

function HUDLootScreenSkirmish:set_num_visible(num)
	if not alive(self._peers_panel) then
		return
	end

	self._num_visible = num

	for peer_id = 1, tweak_data.max_players do
		self._peer_data[peer_id].panel:set_visible(peer_id <= num)
	end

	self._peers_panel:set_center_x((self._panel:w() - (num - tweak_data.max_players) * (self._peer_width + PADDING)) / 2)
end

function HUDLootScreenSkirmish:make_cards(peer, amount)
	amount = math.min(amount, CARDS_PER_ROW * NUM_OF_ROWS)
	local peer_id = peer and peer:id()
	local data = self._peer_data[peer_id]

	if not data then
		return
	end

	local is_local_peer = get_local_peer_id() == peer_id
	local peer_name_string = is_local_peer and tostring(managers.network.account:username() or managers.blackmarket:get_preferred_character_real_name()) or peer and peer:name() or ""
	local player_level = is_local_peer and managers.experience:current_level() or peer and peer:level()
	local player_rank = is_local_peer and managers.experience:current_rank() or peer and peer:rank() or 0

	if player_level then
		local color_range_offset = utf8.len(peer_name_string) + 2
		local rank_string, color_ranges = managers.experience:gui_string(player_level, player_rank, color_range_offset)

		data.player_text:set_text(peer_name_string .. " (" .. rank_string .. ")")

		for _, color_range in ipairs(color_ranges or {}) do
			data.player_text:set_range_color(color_range.start, color_range.stop, color_range.color)
		end

		local infamy_texture, infamy_texture_rect = managers.experience:rank_icon_data(player_rank)

		if infamy_texture then
			local x, y, w, h = unpack(infamy_texture_rect)

			data.player_infamy:set_image(infamy_texture, x, y, w, h)
		end

		data.player_infamy:set_visible(player_rank > 0)
		data.player_text:set_x(player_rank > 0 and data.player_infamy:right() or data.player_infamy:left())
	else
		data.player_text:set_text(peer_name_string)
		data.player_infamy:set_visible(false)
		data.player_text:set_x(data.player_infamy:left())
	end

	local card, card_icon = nil
	local texture, texture_rect = tweak_data.hud_icons:get_icon_data("downcard_overkill_deck")

	for _, card in ipairs(data.cards) do
		card.panel:clear()

		card.item_panel = nil
		card.icon = nil
		card.flipped = false
	end

	for i = 1, amount do
		card = data.cards[i]
		card.icon = card.panel:bitmap({
			name = "card_icon",
			texture = texture,
			texture_rect = texture_rect,
			rotation = math.random(4) - 2
		})
		card.item_panel = card.panel:panel({
			alpha = 0,
			name = "item_panel",
			visible = false
		})

		ExtendedPanel.make_bitmap_fit(card.icon, card.panel:w(), card.panel:h())
		card.icon:set_center(card.panel:w() / 2, card.panel:h() / 2)
	end

	table.insert(self._setup, {
		peer = peer,
		amount_cards = amount
	})
end

function HUDLootScreenSkirmish:make_lootdrop(lootdrop_data)
	local peer = lootdrop_data.peer
	local peer_id = peer and peer:id()
	local data = self._peer_data[peer_id]

	if not data then
		return
	end

	data.active = true
	local reward_list = data.reward_list
	local lootdrops = {}
	local cash = 0
	local xp = 0
	local card_index = 1
	local item_panel = nil
	local coins = lootdrop_data.coins or 0

	if coins > 0 then
		item_panel = data.cards[card_index].item_panel
		data.cards[card_index].type = CARD_TYPES.coins

		self:_add_item_textures({
			type_items = "coins",
			item_entry = coins
		}, item_panel)

		card_index = card_index + 1
	end

	local td, gv, td_cat, text, color, value_id = nil
	local item_id = lootdrop_data.item_entry
	local category = lootdrop_data.type_items

	for _, lootdrop_data in ipairs(lootdrop_data.items) do
		item_id = lootdrop_data.item_entry
		category = lootdrop_data.type_items

		if category == "weapon_skins" and tweak_data.blackmarket.weapon_skins[item_id].is_a_color_skin then
			category = "weapon_color_skins"
		end

		item_panel = data.cards[card_index].item_panel
		data.cards[card_index].type = CARD_TYPES[category]

		self:_add_item_textures(lootdrop_data, item_panel)

		td = nil

		if category == "cash" then
			text = false
			value_id = tweak_data.blackmarket.cash[item_id].value_id
			cash = cash + (managers.money:get_loot_drop_cash_value(value_id) or 0)
		elseif category == "xp" then
			text = false
			value_id = tweak_data.blackmarket.xp[item_id].value_id
			xp = xp + (tweak_data:get_value("experience_manager", "loot_drop_value", value_id) or 0)
		elseif category == "safes" then
			td = tweak_data.economy.safes[item_id]
		elseif category == "drills" then
			td = tweak_data.economy.drills[item_id]
		elseif category == "armor_skins" then
			td = tweak_data.economy.armor_skins[item_id]
		else
			if category == "weapon_mods" or category == "weapon_bonus" then
				category = "mods"
			end

			td_cat = category

			if td_cat == "mods" then
				td_cat = "weapon_mods"
			elseif td_cat == "weapon_color_skins" then
				td_cat = "weapon_skins"
			end

			td = tweak_data.blackmarket[td_cat][item_id]
		end

		if category == "textures" then
			table.insert(data.patterns, item_panel)
		end

		if td then
			if td.name_id then
				gv = lootdrop_data.global_value
				text = managers.localization:text("bm_menu_" .. tostring(category)) .. ": " .. managers.localization:text(td.name_id)
				color = tweak_data.lootdrop.global_values[gv] and tweak_data.lootdrop.global_values[gv].color or tweak_data.screen_colors.text
			else
				text = tostring(item_id) .. " - " .. tostring(category)
			end

			table.insert(lootdrops, {
				text = text,
				color = color
			})
		end

		card_index = card_index + 1
	end

	if xp > 0 then
		add_reward_text(data.reward_list, managers.localization:to_upper_text("menu_experience") .. " " .. managers.experience:experience_string(xp))
	end

	if cash > 0 then
		add_reward_text(data.reward_list, managers.localization:to_upper_text("menu_cash_spending") .. " " .. managers.experience:cash_string(cash))
	end

	if coins > 0 then
		add_reward_text(data.reward_list, managers.localization:to_upper_text("menu_cs_coins") .. " " .. managers.experience:cash_string(coins, ""))
	end

	for _, ld in ipairs(lootdrops) do
		add_reward_text(data.reward_list, ld.text, ld.color)
	end

	table.insert(self._lootdrops, lootdrop_data)
	self:set_num_visible(math.max(self._num_visible, peer_id))
end

function HUDLootScreenSkirmish:add_callback(key, clbk)
	self._callback_handler[key] = clbk
end

function HUDLootScreenSkirmish:check_all_ready()
	return not self:is_updating()
end

function HUDLootScreenSkirmish:clear_other_peers(peer_id)
	peer_id = peer_id or self:get_local_peer_id()

	for i = 1, tweak_data.max_players do
		if i ~= peer_id then
			self:remove_peer(i)
		end
	end
end

function HUDLootScreenSkirmish:remove_peer(peer_id, reason)
	local data = self._peer_data[peer_id]

	if not data then
		return
	end

	data.active = false

	data.panel:hide()
end

function HUDLootScreenSkirmish:is_updating()
	return self._update_func ~= nil
end

function HUDLootScreenSkirmish:set_update(func_name)
	self._update_func = func_name and callback(self, self, func_name) or nil
	self._update_t = 0
end

function HUDLootScreenSkirmish:update(t, dt)
	if self._wait_t > 0 then
		self._wait_t = self._wait_t - dt

		return
	end

	if self._update_func then
		self._update_t = self._update_t + dt

		self._update_func(t, dt)
	end
end

function HUDLootScreenSkirmish:_update_flip_cards(t, dt)
	local data, card = nil
	local card_index = 1

	for peer_id = 1, tweak_data.max_players do
		data = self._peer_data[peer_id]

		for y = 1, NUM_OF_ROWS do
			for x = 1, CARDS_PER_ROW do
				if data.active then
					card = data.cards[(y - 1) * CARDS_PER_ROW + x]

					if card and card.icon and not card.flipped then
						card.panel:animate(flip_card_animation, card.type)

						card.flipped = true
						self._wait_t = FLIP_DELAY
					end
				end

				if card_index == self._next_flip_index then
					self._next_flip_index = self._next_flip_index + 1

					return
				end

				card_index = card_index + 1
			end
		end
	end

	self._wait_t = REWARD_LIST_WAIT_TIME

	self:set_update("_update_show_reward_list")
end

function HUDLootScreenSkirmish:_update_show_reward_list(t, dt)
	local alpha = self._update_t / 0.5

	for peer_id, data in pairs(self._peer_data) do
		data.cards_panel:set_alpha(math.lerp(1, 0, alpha))
		data.reward_list:set_alpha(math.lerp(0, 1, alpha))

		for _, pattern_panel in ipairs(data.patterns) do
			pattern_panel:set_visible(alpha < 0.25)
		end
	end

	if REWARD_FADE_IN_TIME < self._update_t then
		self:set_update(nil)

		local clbk = self._callback_handler.on_peer_ready

		if clbk then
			clbk()
		end
	end
end

function HUDLootScreenSkirmish:is_active()
	return self._active
end

function HUDLootScreenSkirmish:update_layout()
	self._backdrop:_set_black_borders()
end

function HUDLootScreenSkirmish:set_layer(layer)
	self._backdrop:set_layer(layer)
end

function HUDLootScreenSkirmish:hide()
	if self._active then
		return
	end

	self._backdrop:hide()

	if self._video then
		managers.video:remove_video(self._video)
		self._video:parent():remove(self._video)

		self._video = nil
	end

	if self._sound_listener then
		self._sound_listener:delete()

		self._sound_listener = nil
	end

	if self._sound_source then
		self._sound_source:stop()
		self._sound_source:delete()

		self._sound_source = nil
	end
end

function HUDLootScreenSkirmish:show()
	self._backdrop:show()

	self._active = true

	if not self._video and SystemInfo:platform() ~= Idstring("X360") then
		local variant = nil

		if managers.dlc:is_installing() then
			variant = 1
		else
			variant = math.random(8)
		end

		self._video = self._baselayer_two:video({
			blend_mode = "add",
			speed = 1,
			loop = false,
			alpha = 0.2,
			video = "movies/lootdrop" .. tostring(variant)
		})

		managers.video:add_video(self._video)
	end

	if not self._sound_listener then
		self._sound_listener = SoundDevice:create_listener("lobby_menu")

		self._sound_listener:set_position(Vector3(0, -50000, 0))
		self._sound_listener:activate(true)
	end

	if not self._sound_source then
		self._sound_source = SoundDevice:create_source("HUDLootScreen")

		self._sound_source:post_event(managers.music:jukebox_menu_track("heistfinish"))
	end

	local fade_rect = self._foreground_layer_full:rect({
		layer = 10000,
		color = Color.black
	})

	local function fade_out_anim(o)
		over(0.5, function (p)
			o:set_alpha(1 - p)
		end)
		fade_rect:parent():remove(fade_rect)
	end

	fade_rect:animate(fade_out_anim)
	managers.menu_component:lootdrop_is_now_active()
end

function HUDLootScreenSkirmish:reload()
	self:close()
	HUDLootScreenSkirmish.init(self, self._hud, self._workspace, self._lootdrops, self._setup)
	self:show()
end

function HUDLootScreenSkirmish:close()
	self._active = false

	self:hide()
	self._backdrop:close()

	self._backdrop = nil
end

function HUDLootScreenSkirmish:_add_item_textures(lootdrop_data, panel)
	local category = lootdrop_data.type_items
	local item_id = lootdrop_data.item_entry
	local center_x = panel:w() / 2
	local center_y = panel:h() / 2

	if category == "coins" then
		local coins = item_id
		local coin_icon = panel:bitmap({
			texture = "guis/dlcs/chill/textures/pd2/safehouse/continental_coins_drop",
			blend_mode = "normal"
		})
		local coin_text = FineText:new(panel, {
			blend_mode = "normal",
			layer = 1,
			text = managers.experience:cash_string(coins, ""),
			font = medium_font,
			font_size = medium_font_size,
			color = tweak_data.screen_colors.text
		})

		ExtendedPanel.make_bitmap_fit(coin_icon, panel:w(), panel:h())
		coin_icon:set_center(center_x, center_y)
		coin_text:set_center_x(center_x)
		coin_text:set_bottom(panel:h())

		return
	end

	if category == "colors" then
		local colors = tweak_data.blackmarket.colors[item_id].colors
		local bg = panel:bitmap({
			texture = "guis/textures/pd2/blackmarket/icons/colors/color_bg",
			layer = 1
		})
		local c1 = panel:bitmap({
			texture = "guis/textures/pd2/blackmarket/icons/colors/color_01",
			layer = 0,
			color = colors[1]
		})
		local c2 = panel:bitmap({
			texture = "guis/textures/pd2/blackmarket/icons/colors/color_02",
			layer = 0,
			color = colors[2]
		})

		ExtendedPanel.make_bitmap_fit(bg, panel:w(), panel:h())
		bg:set_center(center_x, center_y)
		ExtendedPanel.make_bitmap_fit(c1, panel:w(), panel:h())
		c1:set_center(center_x, center_y)
		ExtendedPanel.make_bitmap_fit(c2, panel:w(), panel:h())
		c2:set_center(center_x, center_y)

		return
	end

	if category == "weapon_mods" or category == "weapon_bonus" then
		category = "mods"
	elseif category == "weapon_skins" and tweak_data.blackmarket.weapon_skins[item_id].is_a_color_skin then
		category = "weapon_color_skins"
	end

	local texture_loaded_clbk = callback(self, self, "_texture_loaded_clbk", {
		panel = panel,
		is_pattern = category == "textures" and true or false
	})
	local texture_path, rarity_path = nil

	if category == "textures" then
		texture_path = tweak_data.blackmarket.textures[item_id].texture
	elseif category == "cash" then
		texture_path = "guis/textures/pd2/blackmarket/cash_drop"
		local value_id = tweak_data.blackmarket.cash[item_id].value_id
		local cash_value = managers.money:get_loot_drop_cash_value(value_id) or 0
		local cash_string = managers.experience:cash_string(cash_value)
		local cash_text = FineText:new(panel, {
			blend_mode = "normal",
			layer = 1,
			text = cash_string,
			font = medium_font,
			font_size = medium_font_size,
			color = tweak_data.screen_colors.text
		})

		cash_text:set_center_x(center_x)
		cash_text:set_bottom(panel:h())
	elseif category == "xp" then
		texture_path = "guis/textures/pd2/blackmarket/xp_drop"
		local value_id = tweak_data.blackmarket.xp[item_id].value_id
		local xp_amount = tweak_data:get_value("experience_manager", "loot_drop_value", value_id) or 0
		local xp_string = managers.experience:experience_string(xp_amount)
		local xp_text = FineText:new(panel, {
			blend_mode = "normal",
			layer = 1,
			text = xp_string,
			font = medium_font,
			font_size = medium_font_size,
			color = tweak_data.screen_colors.text
		})

		xp_text:set_center_x(center_x)
		xp_text:set_bottom(panel:h())
	elseif category == "safes" then
		local td = tweak_data.economy[category] and tweak_data.economy[category][item_id]

		if td then
			local guis_catalog = "guis/"
			local bundle_folder = td.texture_bundle_folder

			if bundle_folder then
				guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
			end

			local path = category .. "/"
			texture_path = guis_catalog .. path .. item_id
		else
			texture_path = "guis/dlcs/cash/safes/default/safes/default_01"
		end
	elseif category == "drills" then
		local td = tweak_data.economy[category] and tweak_data.economy[category][item_id]

		if td then
			local guis_catalog = "guis/"
			local bundle_folder = td.texture_bundle_folder

			if bundle_folder then
				guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
			end

			local path = category .. "/"
			texture_path = guis_catalog .. path .. item_id
		else
			texture_path = "guis/dlcs/cash/safes/default/drills/default_01"
		end
	elseif category == "weapon_skins" then
		local weapon_id = managers.blackmarket:get_weapon_id_by_cosmetic_id(item_id)
		texture_path, rarity_path = managers.blackmarket:get_weapon_icon_path(weapon_id, {
			id = item_id
		})
	elseif category == "armor_skins" then
		local skin_tweak = tweak_data.economy.armor_skins[item_id]
		local guis_catalog = "guis/"
		local bundle_folder = skin_tweak.texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		texture_path = guis_catalog .. "armor_skins/" .. item_id
		rarity_path = managers.blackmarket:get_cosmetic_rarity_bg(skin_tweak.rarity or "common")
	elseif category == "weapon_color_skins" then
		local color_tweak = tweak_data.blackmarket.weapon_skins[item_id]
		local guis_catalog = "guis/"
		local bundle_folder = color_tweak.texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		texture_path = guis_catalog .. "textures/pd2/blackmarket/icons/weapon_color/" .. item_id
		rarity_path = "guis/dlcs/wcs/textures/pd2/blackmarket/icons/rarity_color"
	else
		local guis_catalog = "guis/"
		local tweak_data_category = category == "mods" and "weapon_mods" or category
		local guis_id = item_id

		if tweak_data.blackmarket[tweak_data_category] and tweak_data.blackmarket[tweak_data_category][item_id] and tweak_data.blackmarket[tweak_data_category][item_id].guis_id then
			guis_id = tweak_data.blackmarket[tweak_data_category][item_id].guis_id
		end

		local bundle_folder = tweak_data.blackmarket[tweak_data_category] and tweak_data.blackmarket[tweak_data_category][guis_id] and tweak_data.blackmarket[tweak_data_category][guis_id].texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		texture_path = guis_catalog .. "textures/pd2/blackmarket/icons/" .. tostring(category) .. "/" .. tostring(guis_id)
	end

	if rarity_path then
		local rarity_bitmap = panel:bitmap({
			blend_mode = "add",
			texture = rarity_path
		})

		ExtendedPanel.make_bitmap_fit(rarity_bitmap, panel:w() * 1.5, panel:h() * 1.5)
		rarity_bitmap:set_center(center_x, center_y)
	end

	if DB:has(Idstring("texture"), texture_path) then
		TextureCache:request(texture_path, "NORMAL", texture_loaded_clbk, 100)
	end
end

function HUDLootScreenSkirmish:_texture_loaded_clbk(params, texture_idstring)
	local is_pattern = params.is_pattern
	local panel = params.panel

	if not alive(panel) then
		TextureCache:unretrieve(texture_idstring)

		return
	end

	local item = panel:bitmap({
		blend_mode = "normal",
		layer = 1,
		texture = texture_idstring
	})

	TextureCache:unretrieve(texture_idstring)

	if is_pattern then
		item:set_render_template(Idstring("VertexColorTexturedPatterns"))
		item:set_blend_mode("normal")
	end

	ExtendedPanel.make_bitmap_fit(item, panel:w(), panel:h())
	item:set_center(panel:w() / 2, panel:h() / 2)
end
