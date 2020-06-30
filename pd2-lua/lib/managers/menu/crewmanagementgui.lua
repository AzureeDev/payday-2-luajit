require("lib/managers/menu/WalletGuiObject")

CrewManagementGui = CrewManagementGui or class()
local massive_font = tweak_data.menu.pd2_massive_font
local large_font = tweak_data.menu.pd2_large_font
local medium_font = tweak_data.menu.pd2_medium_font
local small_font = tweak_data.menu.pd2_small_font
local tiny_font = tweak_data.menu.tiny_font
local massive_font_size = tweak_data.menu.pd2_massive_font_size
local large_font_size = tweak_data.menu.pd2_large_font_size
local medium_font_size = tweak_data.menu.pd2_medium_font_size
local small_font_size = tweak_data.menu.pd2_small_font_size
local tiny_font_size = tweak_data.menu.pd2_tiny_font_size
local crew_skills = {
	"crew_healthy",
	"crew_sturdy",
	"crew_evasive",
	"crew_motivated",
	"crew_regen",
	"crew_quiet",
	"crew_generous",
	"crew_eager"
}
local crew_abilities = {
	"crew_interact",
	"crew_inspire",
	"crew_scavenge",
	"crew_ai_ap_ammo"
}

local function make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end

local function fit_texture(bitmap, target_w, target_h)
	local texture_width = bitmap:texture_width()
	local texture_height = bitmap:texture_height()
	local panel_width, panel_height = bitmap:parent():size()
	target_w = target_w or bitmap:parent():w()
	target_h = target_h or bitmap:parent():h()
	local aspect = target_w / target_h
	local sw = math.max(texture_width, texture_height * aspect)
	local sh = math.max(texture_height, texture_width / aspect)
	local dw = texture_width / sw
	local dh = texture_height / sh

	bitmap:set_size(math.round(dw * target_w), math.round(dh * target_h))
end

local function select_anim(object, size, instant)
	local current_width = object:w()
	local current_height = object:h()
	local end_width = size[1]
	local end_height = size[2]
	local cx, cy = object:center()

	if instant then
		object:set_size(end_width, end_height)
		object:set_center(cx, cy)
	else
		over(0.2, function (p)
			object:set_size(math.lerp(current_width, end_width, p), math.lerp(current_height, end_height, p))
			object:set_center(cx, cy)
		end)
	end
end

local function unselect_anim(object, size, instant)
	local current_width = object:w()
	local current_height = object:h()
	local end_width = size[1] * 0.8
	local end_height = size[2] * 0.8
	local cx, cy = object:center()

	if instant then
		object:set_size(end_width, end_height)
		object:set_center(cx, cy)
	else
		over(0.2, function (p)
			object:set_size(math.lerp(current_width, end_width, p), math.lerp(current_height, end_height, p))
			object:set_center(cx, cy)
		end)
	end
end

local function select_anim_text(object, font_size, instant)
	local current_size = object:font_size()
	local end_font_size = font_size
	local cx, cy = object:center()

	if instant then
		object:set_size(end_width, end_height)
		make_fine_text(object)
		object:set_center(cx, cy)
	else
		over(0.2, function (p)
			object:set_font_size(math.lerp(current_size, end_font_size, p))
			make_fine_text(object)
			object:set_center(cx, cy)
		end)
	end
end

local function unselect_anim_text(object, font_size, instant)
	local current_size = object:font_size()
	local end_font_size = font_size * 0.8
	local cx, cy = object:center()

	if instant then
		object:set_font_size(end_font_size)
		make_fine_text(object)
		object:set_center(cx, cy)
	else
		over(0.2, function (p)
			object:set_font_size(math.lerp(current_size, end_font_size, p))
			make_fine_text(object)
			object:set_center(cx, cy)
		end)
	end
end

function MenuCallbackHandler:update_crew_loadout(index)
	managers.menu_scene:set_henchmen_loadout(index)
	managers.menu_scene:_set_character_equipment()
end

local saved_characters = nil

function MenuCallbackHandler:reset_crew_outfit()
	managers.menu_scene:set_henchmen_visible(true)

	for i = 1, 3 do
		managers.menu_scene:set_henchmen_loadout(i, saved_characters and saved_characters[i])
	end
end

function MenuCallbackHandler:reset_henchmen_player_override()
	managers.menu_scene:set_henchmen_player_override(nil)
	managers.menu_scene:set_character(managers.blackmarket:get_preferred_character())
end

function CrewManagementGui:reload()
	local node = self._node

	call_on_next_update(function ()
		managers.menu_component:close_crew_management_gui()

		saved_characters = {
			managers.menu_scene._picked_character_position[1],
			managers.menu_scene._picked_character_position[2],
			managers.menu_scene._picked_character_position[3]
		}

		managers.menu_component:create_crew_management_gui(node)

		saved_characters = nil
	end)
end

function CrewManagementGui:init(ws, fullscreen_ws, node)
	managers.menu_component:close_contract_gui()
	managers.blackmarket:verfify_crew_loadout()
	MenuCallbackHandler:reset_crew_outfit()

	if alive(CrewManagementGui.panel_crash_protection) then
		CrewManagementGui.panel_crash_protection:parent():remove(CrewManagementGui.panel_crash_protection)
	end

	self._node = node
	node:parameters().data = node:parameters().data or {}
	self._panel = ws:panel():panel()
	CrewManagementGui.panel_crash_protection = self._panel
	self._item_w = 128
	self._item_h = 100
	self._image_max_h = 64
	self._item_h = 84
	self._buttons = {}
	self._buttons_no_nav = {}
	local title_text = self._panel:text({
		text = managers.localization:to_upper_text("menu_crew_management"),
		font = large_font,
		font_size = large_font_size
	})

	make_fine_text(title_text)

	local loadout_text = self._panel:text({
		text = managers.localization:text("menu_crew_loadout_order"),
		font = medium_font,
		font_size = medium_font_size,
		y = medium_font_size
	})

	make_fine_text(loadout_text)

	local info_panel = nil

	if managers.menu:is_pc_controller() then
		info_panel = self._panel:panel({
			w = 30,
			h = 24
		})
		local info_icon = info_panel:bitmap({
			texture = "guis/textures/pd2/blackmarket/inv_newdrop"
		})

		info_icon:set_texture_coordinates(Vector3(0, 16, 0), Vector3(16, 16, 0), Vector3(0, 0, 0), Vector3(16, 0, 0))
		info_icon:set_center(info_panel:center())

		local info_button = CrewManagementGuiButton:new(self, callback(self, self, "show_help_dialog"), true)
		info_button._panel = info_panel
		info_button._select_col = Color.white:with_alpha(0.25)
		info_button._normal_col = Color.white

		function info_button:_selected_changed(state)
			info_icon:set_color(state and self._select_col or self._normal_col)
		end
	end

	self._1_panel = self._panel:panel({
		h = 0,
		w = self._item_w,
		y = loadout_text:bottom()
	})
	self._2_panel = self._panel:panel({
		h = 0,
		w = self._item_w,
		y = loadout_text:bottom()
	})
	self._3_panel = self._panel:panel({
		h = 0,
		w = self._item_w,
		y = loadout_text:bottom()
	})
	self._btn_panels = {
		self._1_panel,
		self._2_panel,
		self._3_panel
	}

	self._3_panel:set_right(self._panel:right() - 10)
	self._2_panel:set_right(self._3_panel:left() - 10)
	self._1_panel:set_right(self._2_panel:left() - 10)

	for i, panel in pairs(self._btn_panels) do
		local slot_text = self._panel:text({
			text = managers.localization:text("menu_crew_slot_index", {
				index = i
			}),
			font = small_font,
			font_size = small_font_size
		})

		make_fine_text(slot_text)
		slot_text:set_lefttop(panel:lefttop())
		panel:set_top(slot_text:bottom())
	end

	loadout_text:set_left(self._1_panel:left())

	if info_panel then
		info_panel:set_center_y(loadout_text:center_y())
		info_panel:set_left(loadout_text:right())
	end

	self:create_mask_button(self._1_panel, 1)
	self:create_mask_button(self._2_panel, 2)
	self:create_mask_button(self._3_panel, 3)
	self:new_row()
	self:create_weapon_button(self._1_panel, 1)
	self:create_weapon_button(self._2_panel, 2)
	self:create_weapon_button(self._3_panel, 3)
	self:new_row()
	self:create_ability_button(self._1_panel, 1)
	self:create_ability_button(self._2_panel, 2)
	self:create_ability_button(self._3_panel, 3)
	self:new_row()
	self:create_skill_button(self._1_panel, 1)
	self:create_skill_button(self._2_panel, 2)
	self:create_skill_button(self._3_panel, 3)
	self:new_row()
	self:create_suit_button(self._1_panel, 1)
	self:create_suit_button(self._2_panel, 2)
	self:create_suit_button(self._3_panel, 3)
	self:new_row()

	local char_text = self._panel:text({
		text = managers.localization:text("menu_crew_character_order"),
		font = medium_font,
		font_size = medium_font_size
	})

	make_fine_text(char_text)

	local cc_padding = 20
	cc_padding = 10

	char_text:set_top(self._1_panel:bottom() + cc_padding)
	char_text:set_left(self._1_panel:left())

	local cc_panel = self._panel:panel({
		w = self._3_panel:right() - self._1_panel:left()
	})

	cc_panel:set_left(self._1_panel:left())
	cc_panel:set_top(char_text:bottom())

	local char_height = 70
	char_height = 64
	local char_panel = cc_panel:panel({
		w = 0,
		h = char_height
	})
	local char_images = {}

	for i = 1, CriminalsManager.MAX_NR_TEAM_AI do
		local character = managers.blackmarket:preferred_henchmen(i)
		local texture = character and managers.blackmarket:get_character_icon(character) or "guis/textures/pd2/dice_icon"
		local _, img = self:_add_bitmap_panel_row(char_panel, {
			texture = texture
		}, char_height, 64)

		table.insert(char_images, img)
	end

	char_panel:set_center_x(cc_panel:w() / 2)
	char_panel:set_top(15)
	cc_panel:set_h(char_panel:h() + 30)

	local char_btn = CrewManagementGuiButton:new(self, callback(self, self, "open_character_menu", 1))
	char_btn._panel = cc_panel
	char_btn._select_panel = BoxGuiObject:new(cc_panel, {
		sides = {
			2,
			2,
			2,
			2
		}
	})
	local char_panel_size = {
		char_images[1]:size()
	}

	function char_btn:_selected_changed(state, instant)
		CrewManagementGuiButton._selected_changed(self, state, instant)

		for _, img in pairs(char_images) do
			img:animate(state and select_anim or unselect_anim, char_panel_size, instant)
		end
	end

	char_btn:_selected_changed(false, true)

	local v = cc_panel

	BoxGuiObject:new(v, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	v:bitmap({
		texture = "guis/textures/test_blur_df",
		layer = -1,
		halign = "scale",
		alpha = 1,
		render_template = "VertexColorTexturedBlur3D",
		valign = "scale",
		w = v:w(),
		h = v:h()
	})
	v:rect({
		alpha = 0.4,
		layer = -1,
		color = Color.black
	})

	for _, v in pairs(self._btn_panels) do
		BoxGuiObject:new(v, {
			sides = {
				1,
				1,
				2,
				1
			}
		})
		v:bitmap({
			texture = "guis/textures/test_blur_df",
			layer = -1,
			halign = "scale",
			alpha = 1,
			render_template = "VertexColorTexturedBlur3D",
			valign = "scale",
			w = v:w(),
			h = v:h()
		})
		v:rect({
			alpha = 0.4,
			layer = -1,
			color = Color.black
		})
	end

	WalletGuiObject.set_wallet(self._panel)

	if managers.menu:is_pc_controller() then
		self._legends_panel = self._panel:panel({
			name = "legends_panel",
			w = self._panel:w() * 0.75,
			h = tweak_data.menu.pd2_medium_font_size
		})

		self._legends_panel:set_right(self._panel:w())

		self._legends = {}

		local function new_legend(name, text_string, hud_icon)
			local panel = self._legends_panel:panel({
				visible = false,
				name = name
			})
			local text = panel:text({
				blend_mode = "add",
				text = text_string,
				font = small_font,
				font_size = small_font_size,
				color = tweak_data.screen_colors.text
			})

			make_fine_text(text)

			local text_x = 0
			local center_y = text:center_y()

			if hud_icon then
				local texture, texture_rect = tweak_data.hud_icons:get_icon_data(hud_icon)
				local icon = panel:bitmap({
					name = "icon",
					h = 23,
					blend_mode = "add",
					w = 17,
					texture = texture,
					texture_rect = texture_rect
				})
				text_x = icon:right() + 2
				center_y = math.max(center_y, icon:center_y())

				icon:set_center_y(center_y)
			end

			text:set_left(text_x)
			text:set_center_y(center_y)
			panel:set_w(text:right())

			self._legends[name] = panel
		end

		new_legend("select", managers.localization:to_upper_text("menu_mouse_select"), "mouse_left_click")
		new_legend("switch", managers.localization:to_upper_text("menu_mouse_switch"), "mouse_scroll_wheel")
	end

	local index_x = node:parameters().data.crew_gui_index_x or 1
	local index_y = node:parameters().data.crew_gui_index_y or 1

	self:select_index(index_x, index_y)

	local back_button = self._panel:text({
		vertical = "bottom",
		name = "back_button",
		blend_mode = "add",
		align = "right",
		layer = 40,
		text = managers.localization:text("menu_back"),
		font_size = tweak_data.menu.pd2_large_font_size,
		font = tweak_data.menu.pd2_large_font,
		color = tweak_data.screen_colors.button_stage_3
	})

	make_fine_text(back_button)
	back_button:set_right(self._panel:w())
	back_button:set_bottom(self._panel:h())
	back_button:set_visible(managers.menu:is_pc_controller())

	local back = CrewManagementGuiButton:new(self, function ()
		managers.menu:back(true)
	end, true)
	back._panel = back_button
	back._select_col = tweak_data.screen_colors.button_stage_2
	back._normal_col = tweak_data.screen_colors.button_stage_3
	back._selected_changed = CrewManagementGuiTextButton._selected_changed
end

function CrewManagementGui:_setup()
	if alive(self._panel) then
		self._panel:parent():remove(self._panel)
	end
end

function CrewManagementGui:new_row()
	self._items = self._items or {
		self._current_row
	}
	self._current_row = {}

	table.insert(self._items, self._current_row)
end

function CrewManagementGui:add_item(item, no_navigation)
	if no_navigation then
		table.insert(self._buttons_no_nav, item)

		return
	end

	self._current_row = self._current_row or {}
	self._items = self._items or {
		self._current_row
	}

	table.insert(self._current_row, item)
	table.insert(self._buttons, item)

	return {
		#self._current_row,
		#self._items
	}
end

function CrewManagementGui:_add_bitmap_panel(panel, config, w, h)
	local rtn = panel:panel({
		w = self._item_w,
		h = self._item_h
	})
	local item = nil

	if config and type(config) == "table" then
		item = rtn:bitmap(config)

		fit_texture(item, w, h or self._image_max_h)
		item:set_center(rtn:center())
	else
		item = rtn:text({
			text = config or managers.localization:text("menu_crew_none"),
			font = medium_font,
			font_size = medium_font_size
		})

		make_fine_text(item)
		item:set_center(rtn:center())
	end

	rtn:set_center_x(self._item_w / 2)
	rtn:set_y(panel:h())
	panel:set_h(rtn:bottom())

	return rtn, item
end

function CrewManagementGui:_add_bitmap_panel_row(panel, config, w, h)
	local rtn = panel:panel({
		w = w,
		h = h
	})
	local item = nil
	item = rtn:bitmap(config)

	fit_texture(item, w, h or self._image_max_h)
	item:set_center(rtn:center())
	rtn:set_center_y(panel:h() / 2)
	rtn:set_x(panel:w())
	panel:set_w(rtn:right())

	return rtn, item
end

function CrewManagementGui:create_mask_button(panel, index)
	local loadout = managers.blackmarket:henchman_loadout(index)
	local texture = managers.blackmarket:get_mask_icon(loadout.mask, managers.menu_scene:get_henchmen_character(index) or managers.blackmarket:preferred_henchmen(index))
	local text = managers.blackmarket:get_mask_name_by_category_slot("masks", loadout.mask_slot)
	local cat_text = managers.localization:to_upper_text("bm_menu_masks")

	return CrewManagementGuiLoadoutItem:new(self, panel, texture and {
		texture = texture
	}, text, cat_text, callback(self, self, "open_mask_category_menu", index), callback(self, self, "previous_mask", index), callback(self, self, "next_mask", index))
end

function CrewManagementGui:create_weapon_button(panel, index)
	local loadout = managers.blackmarket:henchman_loadout(index)
	local data = managers.blackmarket:get_crafted_category_slot("primaries", loadout.primary_slot) or {}
	local texture, rarity = managers.blackmarket:get_weapon_icon_path(data.weapon_id, data.cosmetics)
	local text = loadout.primary_slot and managers.blackmarket:get_weapon_name_by_category_slot("primaries", loadout.primary_slot) or ""
	local cat_text = managers.localization:to_upper_text("bm_menu_primaries")
	local item = CrewManagementGuiLoadoutItem:new(self, panel, texture and {
		layer = 1,
		texture = texture
	} or managers.localization:to_upper_text("menu_crew_defualt"), text, cat_text, callback(self, self, "open_weapon_menu", {
		"primaries",
		index
	}), callback(self, self, "previous_weapon_category", index), callback(self, self, "next_weapon_category", index))

	if rarity then
		local rare_item = item._panel:bitmap({
			blend_mode = "add",
			layer = 0,
			texture = rarity
		})

		fit_texture(rare_item, item._panel:size())
		rare_item:set_world_center(item._panel:world_center())
	end

	return item
end

function CrewManagementGui:create_ability_button(panel, index)
	local loadout = managers.blackmarket:henchman_loadout(index)
	local data = tweak_data.upgrades.crew_ability_definitions[loadout.ability]
	local cat_text = managers.localization:to_upper_text("bm_menu_ability")
	local texture, texture_rect, text = nil

	if data then
		texture, texture_rect = tweak_data.hud_icons:get_icon_data(data.icon)
		text = managers.localization:text(data.name_id)
	else
		texture = "guis/textures/pd2/add_icon"
		text = managers.localization:to_upper_text("menu_loadout_empty")
	end

	return CrewManagementGuiLoadoutItem:new(self, panel, texture and {
		texture = texture,
		texture_rect = texture_rect
	}, text, cat_text, callback(self, self, "open_ability_menu", index), callback(self, self, "previous_ability", index), callback(self, self, "next_ability", index))
end

function CrewManagementGui:create_skill_button(panel, index)
	local loadout = managers.blackmarket:henchman_loadout(index)
	local data = tweak_data.upgrades.crew_skill_definitions[loadout.skill]
	local cat_text = managers.localization:to_upper_text("bm_menu_skill")
	local texture, texture_rect, text = nil

	if data then
		texture, texture_rect = tweak_data.hud_icons:get_icon_data(data.icon)
		text = managers.localization:text(data.name_id)
	else
		texture = "guis/textures/pd2/add_icon"
		text = managers.localization:to_upper_text("menu_loadout_empty")
	end

	return CrewManagementGuiLoadoutItem:new(self, panel, texture and {
		texture = texture,
		texture_rect = texture_rect
	}, text, cat_text, callback(self, self, "open_skill_menu", {
		"skill",
		index
	}), callback(self, self, "previous_skill", index), callback(self, self, "next_skill", index))
end

function CrewManagementGui:create_suit_button(panel, index)
	local loadout = managers.blackmarket:henchman_loadout(index)
	local default_player_style = managers.blackmarket:get_default_player_style()
	local player_style = loadout.player_style or default_player_style
	local player_style_data = tweak_data.blackmarket.player_styles[player_style]
	local guis_catalog = "guis/"
	local bundle_folder = player_style_data.texture_bundle_folder

	if bundle_folder then
		guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
	end

	local texture, text = nil

	if player_style ~= default_player_style then
		texture = guis_catalog .. "textures/pd2/blackmarket/icons/player_styles/" .. player_style
		text = managers.localization:text(player_style_data.name_id)
	end

	local cat_text = managers.localization:to_upper_text("bm_menu_player_styles")

	return CrewManagementGuiLoadoutItem:new(self, panel, texture and {
		layer = 1,
		texture = texture
	} or managers.localization:to_upper_text("menu_default"), text, cat_text, callback(self, self, "open_suit_menu", index), callback(self, self, "previous_suit", index), callback(self, self, "next_suit", index))
end

function CrewManagementGui:close()
	if self._panel then
		self._panel:parent():remove(self._panel)

		CrewManagementGui.panel_crash_protection = nil
	end

	WalletGuiObject.close_wallet(self._panel)
	managers.blackmarket:verfify_crew_loadout()
	managers.menu_scene:set_henchmen_visible(false)
end

function CrewManagementGui:create_button(panel, string, func)
	local btn = {
		panel = panel:panel(),
		trigger = func
	}
	local text = btn.panel:text({
		text = string,
		font_size = medium_font_size,
		font = medium_font
	})

	make_fine_text(text)
	btn.panel:set_size(text:size())
	btn.panel:set_y(panel:h())
	panel:set_h(btn.panel:bottom())

	return btn
end

function CrewManagementGui:show_help_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_crew_loadout_help_title"),
		text = managers.localization:text("dialog_crew_loadout_help_text"),
		type = "help_dialog"
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

local function adapt_text_width(text_item, target_w)
	target_w = target_w or text_item:w()

	make_fine_text(text_item)

	if target_w < text_item:w() then
		text_item:set_font_size(text_item:font_size() * target_w / text_item:w())
		make_fine_text(text_item)
	end
end

CrewManagementGuiButton = CrewManagementGuiButton or class()

function CrewManagementGuiButton:init(parent, func, no_navigation)
	self._parent = parent
	self._func = func
	self._no_navigation = not not no_navigation
	self._enabled = true
	self.legends = {
		"select"
	}
	self._pos = parent:add_item(self, no_navigation)
end

function CrewManagementGuiButton:trigger(...)
	managers.menu_component:post_event("menu_enter")

	if self._func then
		self._func(...)
	end
end

function CrewManagementGuiButton:previous_page(...)
end

function CrewManagementGuiButton:next_page(...)
end

function CrewManagementGuiButton:set_selected(state)
	if state and not self._enabled and not self._no_navigation then
		self._parent:select(self._select_instead)

		return
	end

	if self._selected == state then
		return
	end

	self._selected = state
	local _ = self._selected_changed and self:_selected_changed(state)
	local _ = state and managers.menu_component:post_event("highlight")
end

function CrewManagementGuiButton:select_instead(item)
	self._select_instead = item

	if self._selected and self._select_instead then
		self._parent:select(self._select_instead)
	end
end

function CrewManagementGuiButton:inside(x, y)
	if self._no_navigation then
		return self._panel:inside(x, y)
	end

	return self._enabled and self._panel and self._panel:inside(x, y)
end

function CrewManagementGuiButton:set_enabled(state)
	self._enabled = state
	local _ = self._item and self._item:set_color(state and Color.white or Color.black)

	if not state and self._selected then
		self._parent:select(self._select_instead)
	end
end

function CrewManagementGuiButton:_selected_changed(state)
	local _ = self._select_panel and self._select_panel:set_visible(state)
end

CrewManagementGuiLoadoutItem = CrewManagementGuiLoadoutItem or class(CrewManagementGuiButton)

function CrewManagementGuiLoadoutItem:init(parent, panel, texture, select_text, unselect_text, func_trigger, func_up, func_down)
	CrewManagementGuiLoadoutItem.super.init(self, parent, func_trigger)

	self._panel, self._item = parent:_add_bitmap_panel(panel, texture)
	self._func_up = func_up
	self._func_down = func_down

	if func_up and func_down then
		table.insert(self.legends, 1, "switch")
	end

	if type(texture) == "table" then
		self._anim_full_size = {
			self._item:size()
		}
		self._select_anim = select_anim
		self._unselect_anim = unselect_anim
	else
		self._anim_full_size = self._item:font_size()
		self._select_anim = select_anim_text
		self._unselect_anim = unselect_anim_text
	end

	self._category_text = self._panel:text({
		y = 2,
		x = 4,
		text = unselect_text,
		font = small_font,
		font_size = small_font_size,
		color = tweak_data.screen_colors.button_stage_3:with_alpha(0.25)
	})
	self._item_text = self._panel:text({
		y = 2,
		x = 4,
		text = select_text,
		font = small_font,
		font_size = small_font_size
	})

	adapt_text_width(self._item_text, self._panel:w() - 8)
	adapt_text_width(self._category_text, self._panel:w() - 8)

	self._select_panel = BoxGuiObject:new(self._panel, {
		sides = {
			2,
			2,
			2,
			2
		}
	})

	self:_selected_changed(false, true)
end

function CrewManagementGuiLoadoutItem:_selected_changed(state, instant)
	self._item:animate(state and self._select_anim or self._unselect_anim, self._anim_full_size, instant)
	self._category_text:set_visible(not state)
	self._item_text:set_visible(state)
	self._select_panel:set_visible(state)
end

function CrewManagementGuiLoadoutItem:previous_page(...)
	managers.menu_component:post_event("menu_enter")

	if self._func_up then
		self._func_up(...)
	end
end

function CrewManagementGuiLoadoutItem:next_page(...)
	managers.menu_component:post_event("menu_enter")

	if self._func_down then
		self._func_down(...)
	end
end

CrewManagementGuiTextButton = CrewManagementGuiTextButton or class(CrewManagementGuiButton)

function CrewManagementGuiTextButton:init(parent, panel, text, func)
	CrewManagementGuiTextButton.super.init(self, parent, func, true)

	self._select_col = tweak_data.screen_colors.button_stage_2
	self._normal_col = tweak_data.screen_colors.button_stage_3
	self._panel = panel:text({
		text = text,
		font = small_font,
		font_size = small_font_size,
		color = self._normal_col
	})

	make_fine_text(self._panel)
	self._panel:set_left(panel:w())
	panel:set_w(self._panel:right())
end

function CrewManagementGuiTextButton:_selected_changed(state)
	self._panel:set_color(state and self._select_col or self._normal_col)
end

function CrewManagementGui:mouse_pressed(button, x, y)
	if button ~= Idstring("0") then
		return
	end

	for k, v in pairs(self._buttons_no_nav or {}) do
		if v:inside(x, y) then
			v:trigger()

			break
		end
	end

	for k, v in pairs(self._buttons) do
		if v:inside(x, y) then
			v:trigger()

			break
		end
	end
end

function CrewManagementGui:mouse_wheel_up(x, y)
	if self._selected_btn and self._selected_btn:inside(x, y) then
		self._selected_btn:previous_page()
	end
end

function CrewManagementGui:mouse_wheel_down(x, y)
	if self._selected_btn and self._selected_btn:inside(x, y) then
		self._selected_btn:next_page()
	end
end

function CrewManagementGui:next_page()
	if self._selected_btn then
		self._selected_btn:next_page()
	end
end

function CrewManagementGui:previous_page()
	if self._selected_btn then
		self._selected_btn:previous_page()
	end
end

function CrewManagementGui:mouse_moved(o, x, y)
	local hover_icon = nil

	for k, v in pairs(self._buttons_no_nav or {}) do
		local inside = v:inside(x, y)

		v:set_selected(inside)

		hover_icon = hover_icon or inside
	end

	for k, v in pairs(self._buttons) do
		if v:inside(x, y) then
			self:select(v)

			return true, "link"
		end
	end

	if hover_icon then
		return true, "link"
	end
end

function CrewManagementGui:special_btn_pressed(button)
	if Idstring("menu_respec_tree") == button then
		self:show_help_dialog()
	end
end

function CrewManagementGui:move_left()
	self:move_selection(-1, 0)
end

function CrewManagementGui:move_right()
	self:move_selection(1, 0)
end

function CrewManagementGui:move_up()
	self:move_selection(0, -1)
end

function CrewManagementGui:move_down()
	self:move_selection(0, 1)
end

function CrewManagementGui:move_selection(dx, dy)
	if not self._selected_btn then
		self:select_index(1, 1)

		return
	end

	local pos = self._selected_btn._pos

	self:select_index(pos[1] + dx, pos[2] + dy)
end

function CrewManagementGui:confirm_pressed()
	if self._selected_btn then
		self._selected_btn:trigger()
	end
end

function CrewManagementGui:input_focus()
	return alive(self._panel) and self._panel:visible() and 1
end

function CrewManagementGui:select_index(x, y, no_backup)
	y = self._items and math.clamp(y, 1, #self._items)
	local item = self._items[y]
	x = item and math.clamp(x, 1, #item)
	item = item and item[x]
	local _ = item and self:select(item)
end

function CrewManagementGui:select(btn, no_backup)
	if btn and btn._no_navigation then
		print(debug.traceback())
	end

	if btn ~= self._selected_btn then
		local _ = self._selected_btn and self._selected_btn:set_selected(false)
		self._selected_btn = btn
		local _ = btn and btn:set_selected(true)

		if self._selected_btn then
			self._node:parameters().data.crew_gui_index_x = self._selected_btn._pos[1]
			self._node:parameters().data.crew_gui_index_y = self._selected_btn._pos[2]

			if managers.menu:is_pc_controller() then
				for name, panel in pairs(self._legends) do
					panel:set_visible(table.contains(self._selected_btn.legends, name))
				end

				local prev_legend = nil

				for _, legend in ipairs(self._selected_btn.legends) do
					self._legends[legend]:set_right(prev_legend and prev_legend:left() - 10 or self._legends_panel:w())

					prev_legend = self._legends[legend]
				end
			else
				local legends_mutable = self._node:legends()

				table.remove_condition(legends_mutable, function (x)
					return x.string_id == "menu_legend_select"
				end)
				table.remove_condition(legends_mutable, function (x)
					return x.string_id == "menu_legend_switch"
				end)

				for _, legend in ipairs(self._selected_btn.legends) do
					table.insert(legends_mutable, 1, {
						string_id = "menu_legend_" .. legend
					})
				end

				managers.menu:active_menu().renderer:active_node_gui():_create_legends(self._node)
			end
		end

		if not self._selected_btn and not no_backup then
			self:select_index(1, 1, true)
		end
	end
end

function CrewManagementGui:open_weapon_menu(params)
	self:open_weapon_category_menu(unpack(params))
end

function CrewManagementGui:create_pages(new_node_data, params, identifier, selected_slot, rows, columns, max_pages, name_id)
	local category = new_node_data.category
	rows = rows or 3
	columns = columns or 3
	max_pages = max_pages or 8
	local items_per_page = rows * columns
	local item_data = nil
	local selected_tab = 1

	for page = 1, max_pages do
		local index = 1
		local start_i = 1 + items_per_page * (page - 1)
		item_data = {}

		for i = start_i, items_per_page * page do
			item_data[index] = i
			index = index + 1

			if i == selected_slot then
				selected_tab = page
			end
		end

		local name_localized = managers.localization:to_upper_text(name_id or "bm_menu_page", {
			page = tostring(page)
		})

		table.insert(new_node_data, {
			prev_node_data = false,
			allow_preview = true,
			name = category,
			category = category,
			start_i = start_i,
			name_localized = name_localized,
			on_create_func = callback(self, self, "populate_" .. category, params),
			on_create_data = item_data,
			identifier = BlackMarketGui.identifiers[identifier],
			override_slots = {
				columns,
				rows
			}
		})
	end

	return selected_tab
end

function CrewManagementGui:open_custom_menu(params, category, custom_w, custom_h)
	local new_node_data = {
		category = category
	}
	local selected_tab = self:create_pages(new_node_data, params, "custom", nil, custom_w or 4, custom_h or 4, 1)
	new_node_data.can_move_over_tabs = false
	new_node_data.selected_tab = selected_tab
	new_node_data.scroll_tab_anywhere = false
	new_node_data.hide_detection_panel = true
	new_node_data.custom_callback = {
		custom_select = callback(self, self, "select_" .. category, params),
		custom_unselect = callback(self, self, "select_" .. category, params)
	}

	function new_node_data.custom_update_text_info(data, updated_texts, gui)
		updated_texts[1].text = data.name_localized
		updated_texts[2].text = managers.localization:text(data.name_id .. "_desc", tweak_data.upgrades.crew_descs[data.name]) or ""

		if data.unlocked then
			updated_texts[3].text = data.equipped_by and managers.localization:text("menu_data_crew_equipped_by", {
				equipped_by = tostring(data.equipped_by)
			}) or ""
		else
			updated_texts[3].text = data.lock_text
		end
	end

	new_node_data.topic_id = "bm_menu_" .. category
	new_node_data.topic_params = {
		weapon_category = managers.localization:text("bm_menu_" .. category)
	}

	managers.menu:open_node("blackmarket_node", {
		new_node_data
	})
end

function CrewManagementGui:open_ability_menu(henchman_index)
	self:open_custom_menu(henchman_index, "ability")
end

function CrewManagementGui:previous_ability(henchman_index)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	local ability = loadout.ability
	local ability_index = ability and table.get_vector_index(crew_abilities, ability) or #crew_abilities + 1
	local map = self:_create_member_loadout_map("ability")
	local name = nil

	for index = ability_index - 1, 1, -1 do
		name = crew_abilities[index]

		if managers.blackmarket:is_crew_item_unlocked(name) and not map[name] then
			loadout.ability = name

			return self:reload()
		end
	end

	loadout.ability = nil

	return self:reload()
end

function CrewManagementGui:next_ability(henchman_index)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	local ability = loadout.ability
	local ability_index = ability and table.get_vector_index(crew_abilities, ability) or 0
	local map = self:_create_member_loadout_map("ability")
	local name = nil

	for index = ability_index + 1, #crew_abilities do
		name = crew_abilities[index]

		if managers.blackmarket:is_crew_item_unlocked(name) and not map[name] then
			loadout.ability = name

			return self:reload()
		end
	end

	loadout.ability = nil

	return self:reload()
end

function CrewManagementGui:open_skill_menu(params)
	self:open_custom_menu(params, "skill")
end

function CrewManagementGui:previous_skill(henchman_index)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	local skill = loadout.skill
	local skill_index = skill and table.get_vector_index(crew_skills, skill) or #crew_skills + 1
	local map = self:_create_member_loadout_map("skill")
	local name = nil

	for index = skill_index - 1, 1, -1 do
		name = crew_skills[index]

		if managers.blackmarket:is_crew_item_unlocked(name) and not map[name] then
			loadout.skill = name

			return self:reload()
		end
	end

	loadout.skill = nil

	return self:reload()
end

function CrewManagementGui:next_skill(henchman_index)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	local skill = loadout.skill
	local skill_index = skill and table.get_vector_index(crew_skills, skill) or 0
	local map = self:_create_member_loadout_map("skill")
	local name = nil

	for index = skill_index + 1, #crew_skills do
		name = crew_skills[index]

		if managers.blackmarket:is_crew_item_unlocked(name) and not map[name] then
			loadout.skill = name

			return self:reload()
		end
	end

	loadout.skill = nil

	return self:reload()
end

function CrewManagementGui:open_character_menu(henchman_index)
	local category = "characters"
	local new_node_data = {
		category = category
	}
	local selected_tab = self:create_pages(new_node_data, henchman_index, "custom", nil, 3, 6, 1)
	new_node_data.can_move_over_tabs = true
	new_node_data.selected_tab = selected_tab
	new_node_data.scroll_tab_anywhere = false
	new_node_data.hide_detection_panel = true
	new_node_data.custom_callback = {
		custom_select = callback(self, self, "select_characters"),
		custom_unselect = callback(self, self, "select_characters"),
		c_clear_slots = callback(self, self, "clear_character_order")
	}

	function new_node_data.custom_update_text_info(data, updated_texts, gui)
		updated_texts[1].text = data.name_localized
		updated_texts[4].text = managers.localization:text(data.name .. "_desc")

		if not data.unlocked then
			updated_texts[3].text = managers.localization:text(data.dlc_locked)
		end
	end

	new_node_data.topic_id = "bm_menu_crew_characters"
	new_node_data.topic_params = {
		weapon_category = managers.localization:text("bm_menu_" .. category) .. " " .. tostring(henchman_index)
	}

	managers.menu:open_node("blackmarket_node", {
		new_node_data
	})
end

function CrewManagementGui:_create_member_loadout_map(member_name)
	local rtn = {}

	for i = 1, CriminalsManager.MAX_NR_TEAM_AI do
		local loadout = managers.blackmarket:henchman_loadout(i)
		local val = loadout[member_name]

		if val then
			rtn[val] = i
		end
	end

	return rtn
end

function CrewManagementGui:open_weapon_category_menu(category, henchman_index)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	local new_node_data = {
		category = category
	}
	local selected_tab = self:create_pages(new_node_data, henchman_index, "weapon", loadout.primary_slot, tweak_data.gui.WEAPON_ROWS_PER_PAGE, tweak_data.gui.WEAPON_COLUMNS_PER_PAGE, tweak_data.gui.MAX_WEAPON_PAGES)
	new_node_data.can_move_over_tabs = true
	new_node_data.selected_tab = selected_tab
	new_node_data.scroll_tab_anywhere = true
	new_node_data.hide_detection_panel = true
	new_node_data.custom_callback = {
		w_equip = callback(self, self, "select_weapon", henchman_index),
		w_unequip = callback(self, self, "select_weapon", henchman_index),
		ew_buy = callback(self, self, "buy_new_weapon")
	}
	new_node_data.topic_id = "bm_menu_" .. category
	new_node_data.topic_params = {
		weapon_category = managers.localization:text("bm_menu_weapons")
	}

	managers.menu:open_node("blackmarket_node", {
		new_node_data
	})
end

function CrewManagementGui:previous_weapon_category(henchman_index)
	local category = "primaries"
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	local max_slots = tweak_data.gui.MAX_WEAPON_SLOTS or 72
	local equipped_slot = loadout.primary_slot or max_slots + 1
	local crafted = nil

	for slot = equipped_slot - 1, 1, -1 do
		if managers.blackmarket:weapon_unlocked_by_crafted(category, slot) then
			crafted = managers.blackmarket:get_crafted_category_slot(category, slot)

			if managers.blackmarket:is_weapon_category_allowed_for_crew(tweak_data.weapon[crafted.weapon_id].categories[1]) then
				loadout.primary = crafted.factory_id .. "_npc"
				loadout.primary_slot = slot

				return self:reload()
			end
		end
	end

	loadout.primary = nil
	loadout.primary_slot = nil

	return self:reload()
end

function CrewManagementGui:next_weapon_category(henchman_index)
	local category = "primaries"
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	local max_slots = tweak_data.gui.MAX_WEAPON_SLOTS or 72
	local equipped_slot = loadout.primary_slot or 0
	local crafted = nil

	for slot = equipped_slot + 1, max_slots do
		if managers.blackmarket:weapon_unlocked_by_crafted(category, slot) then
			crafted = managers.blackmarket:get_crafted_category_slot(category, slot)

			if managers.blackmarket:is_weapon_category_allowed_for_crew(tweak_data.weapon[crafted.weapon_id].categories[1]) then
				loadout.primary = crafted.factory_id .. "_npc"
				loadout.primary_slot = slot

				return self:reload()
			end
		end
	end

	loadout.primary = nil
	loadout.primary_slot = nil

	return self:reload()
end

function CrewManagementGui:open_mask_category_menu(henchman_index)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	loadout.mask_slot = loadout.mask_slot or 1
	local new_node_data = {
		category = "masks"
	}
	local selected_tab = self:create_pages(new_node_data, henchman_index, "mask", loadout.mask_slot, tweak_data.gui.MASK_ROWS_PER_PAGE, tweak_data.gui.MASK_COLUMNS_PER_PAGE, tweak_data.gui.MAX_MASK_PAGES)
	new_node_data.can_move_over_tabs = true
	new_node_data.selected_tab = selected_tab
	new_node_data.scroll_tab_anywhere = true
	new_node_data.hide_detection_panel = true
	new_node_data.character_id = managers.menu_scene:get_henchmen_character(henchman_index) or managers.blackmarket:preferred_henchmen(henchman_index)
	new_node_data.custom_callback = {
		m_equip = callback(self, self, "select_mask", henchman_index)
	}
	new_node_data.topic_id = "bm_menu_masks"
	new_node_data.topic_params = {
		weapon_category = managers.localization:text("bm_menu_masks")
	}

	managers.menu:open_node("blackmarket_node", {
		new_node_data
	})
end

function CrewManagementGui:previous_mask(henchman_index)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	local equipped_slot = loadout.mask_slot or 1
	local max_slots = tweak_data.gui.MAX_MASK_SLOTS or 72
	local crafted_masks = Global.blackmarket_manager.crafted_items.masks
	local crafted = nil

	for slot = equipped_slot - 1, 1, -1 do
		crafted = crafted_masks[slot]

		if crafted and managers.blackmarket:crafted_mask_unlocked(slot) then
			return self:select_mask(henchman_index, {
				name = crafted.mask_id,
				slot = slot
			}, self)
		end
	end

	for slot = max_slots, equipped_slot + 1, -1 do
		crafted = crafted_masks[slot]

		if crafted and managers.blackmarket:crafted_mask_unlocked(slot) then
			return self:select_mask(henchman_index, {
				name = crafted.mask_id,
				slot = slot
			}, self)
		end
	end
end

function CrewManagementGui:next_mask(henchman_index)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	local equipped_slot = loadout.mask_slot or 1
	local max_slots = tweak_data.gui.MAX_MASK_SLOTS or 72
	local crafted_masks = Global.blackmarket_manager.crafted_items.masks
	local crafted = nil

	for slot = equipped_slot + 1, max_slots do
		crafted = crafted_masks[slot]

		if crafted and managers.blackmarket:crafted_mask_unlocked(slot) then
			loadout.mask = crafted.mask_id
			loadout.mask_slot = slot

			return self:reload()
		end
	end

	for slot = 1, equipped_slot - 1 do
		crafted = crafted_masks[slot]

		if crafted and managers.blackmarket:crafted_mask_unlocked(slot) then
			loadout.mask = crafted.mask_id
			loadout.mask_slot = slot

			return self:reload()
		end
	end
end

function CrewManagementGui:open_suit_menu(henchman_index)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	local new_node_data = {
		category = "suits"
	}

	self:create_pages(new_node_data, henchman_index, "player_style", loadout.player_style, 3, 3, 1, "bm_menu_player_styles")

	new_node_data[1].mannequin_player_style = loadout.player_style

	self:create_pages(new_node_data, henchman_index, "glove", loadout.glove_id, 3, 3, 1, "bm_menu_gloves")

	new_node_data[2].mannequin_glove_id = loadout.glove_id
	new_node_data.hide_detection_panel = true
	new_node_data.character_id = managers.menu_scene:get_henchmen_character(henchman_index) or managers.blackmarket:preferred_henchmen(henchman_index)
	new_node_data.custom_callback = {
		trd_equip = callback(self, self, "select_player_style", henchman_index),
		trd_customize = callback(self, self, "open_suit_customize_menu", henchman_index),
		hnd_equip = callback(self, self, "select_glove", henchman_index)
	}
	new_node_data.skip_blur = true
	new_node_data.use_bgs = true
	new_node_data.panel_grid_w_mul = 0.6

	managers.environment_controller:set_dof_distance(10, false)
	managers.menu_scene:remove_item()

	new_node_data.topic_id = "bm_menu_player_styles"
	new_node_data.topic_params = {
		weapon_category = managers.localization:text("bm_menu_player_styles")
	}
	new_node_data.back_callback = callback(MenuCallbackHandler, MenuCallbackHandler, "reset_henchmen_player_override")

	managers.menu_scene:set_henchmen_player_override(henchman_index)
	managers.menu:open_node("blackmarket_outfit_node", {
		new_node_data
	})
end

function CrewManagementGui:previous_suit(henchman_index)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	local equipped_player_style = loadout.player_style
	local unlocked_player_styles = managers.blackmarket:get_unlocked_player_styles()
	local equipped_index = table.get_vector_index(unlocked_player_styles, equipped_player_style)

	if equipped_index then
		local previous_player_style = unlocked_player_styles[equipped_index == 1 and #unlocked_player_styles or equipped_index - 1]

		if previous_player_style and previous_player_style ~= equipped_player_style then
			loadout.player_style = previous_player_style
			loadout.suit_variation = managers.blackmarket:get_suit_variation(loadout.player_style)

			return self:reload()
		end
	end
end

function CrewManagementGui:next_suit(henchman_index)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	local equipped_player_style = loadout.player_style
	local unlocked_player_styles = managers.blackmarket:get_unlocked_player_styles()
	local equipped_index = table.get_vector_index(unlocked_player_styles, equipped_player_style)

	if equipped_index then
		local next_player_style = unlocked_player_styles[equipped_index % #unlocked_player_styles + 1]

		if next_player_style and next_player_style ~= equipped_player_style then
			loadout.player_style = next_player_style
			loadout.suit_variation = managers.blackmarket:get_suit_variation(loadout.player_style)

			return self:reload()
		end
	end
end

function CrewManagementGui:open_suit_customize_menu(henchman_index, data)
	local function open_node_clbk()
		local loadout = managers.blackmarket:henchman_loadout(henchman_index)
		local new_node_data = {
			category = "suit_variations"
		}
		local selected_tab = self:create_pages(new_node_data, henchman_index, "suit_variation", loadout.suit_variation, 3, 3, 1)
		new_node_data[1].prev_node_data = data
		new_node_data.selected_tab = selected_tab
		new_node_data.hide_detection_panel = true
		new_node_data.character_id = managers.menu_scene:get_henchmen_character(henchman_index) or managers.blackmarket:preferred_henchmen(henchman_index)
		new_node_data.custom_callback = {
			trd_mod_equip = callback(self, self, "select_suit_variation", henchman_index)
		}
		new_node_data.prev_node_data = data
		new_node_data.skip_blur = true
		new_node_data.use_bgs = true
		new_node_data.panel_grid_w_mul = 0.6
		new_node_data.topic_id = "bm_menu_suit_variations"
		new_node_data.topic_params = {
			weapon_category = managers.localization:text("bm_menu_suit_variations")
		}

		managers.menu:open_node("blackmarket_outfit_customize_node", {
			new_node_data
		})
	end

	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	local player_style = loadout.player_style
	local material_variation = loadout.suit_variation

	managers.blackmarket:view_player_style(player_style, material_variation, open_node_clbk)
end

function CrewManagementGui:populate_primaries(henchman_index, data, gui)
	gui:populate_weapon_category_new(data)

	local loadout = managers.blackmarket:henchman_loadout(henchman_index)

	for k, v in ipairs(data) do
		local tweak = tweak_data.weapon[v.name]
		v.equipped = loadout.primary_slot == v.slot

		if tweak and not managers.blackmarket:is_weapon_category_allowed_for_crew(tweak.categories[1]) then
			v.buttons = {}
			v.unlocked = false
			v.lock_texture = "guis/textures/pd2/lock_incompatible"
			v.lock_text = managers.localization:text("menu_data_crew_not_allowed")
		elseif v.equipped then
			v.buttons = {
				"w_unequip"
			}
		elseif not v.empty_slot then
			v.buttons = {
				"w_equip"
			}
		end

		v.comparision_data = nil
		v.mini_icons = nil
	end
end

function CrewManagementGui:populate_buy_weapon(gui, data)
	gui:populate_buy_weapon(data)

	for _, data in ipairs(data) do
		local weapon_data = tweak_data.weapon[data.name]

		if data.name ~= "" and weapon_data and not managers.blackmarket:is_weapon_category_allowed_for_crew(weapon_data.categories[1]) then
			data.buttons = {}
			data.unlocked = false
			data.lock_texture = "guis/textures/pd2/lock_incompatible"
			data.lock_text = managers.localization:text("menu_data_crew_not_allowed")
		end
	end
end

function CrewManagementGui:populate_masks(henchman_index, data, gui)
	gui:populate_masks_new(data)

	local loadout = managers.blackmarket:henchman_loadout(henchman_index)

	for k, v in ipairs(data) do
		v.equipped = loadout.mask_slot == v.slot

		if not v.empty_slot then
			v.buttons = {
				"m_equip"
			}
		end
	end
end

function CrewManagementGui:populate_skill(params, data, gui)
	local category, henchman_index = unpack(params)

	self:populate_custom(category, henchman_index, tweak_data.upgrades.crew_skill_definitions, crew_skills, data, gui)
end

function CrewManagementGui:populate_ability(henchman_index, data, gui)
	self:populate_custom("ability", henchman_index, tweak_data.upgrades.crew_ability_definitions, crew_abilities, data, gui)
end

function CrewManagementGui:populate_custom(category, henchman_index, tweak, list, data, gui)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	local map = self:_create_member_loadout_map(category)
	local new_data = {}

	for i, name in pairs(list) do
		local v = tweak[name]
		new_data = {
			name = name,
			name_id = v.name_id,
			name_localized = managers.localization:text(v.name_id),
			bitmap_texture = {
				tweak_data.hud_icons:get_icon_data(v.icon)
			},
			category = category,
			unlocked = managers.blackmarket:is_crew_item_unlocked(name),
			equipped = loadout[category] == name,
			equipped_by = map[name] ~= henchman_index and map[name] or nil
		}

		if not new_data.unlocked then
			if managers.blackmarket:can_afford_crew_item(name) then
				new_data.lock_texture = "guis/textures/pd2/ccoin"
				new_data.lock_color = Color.white
			else
				new_data.lock_texture = "guis/textures/pd2/lock_ccoin"
			end

			new_data.lock_text = managers.localization:text("menu_data_crew_item_unlock_cost", {
				cost = managers.blackmarket:crew_item_cost(name)
			})
			new_data.buttons = {
				"ci_unlock"
			}
		elseif not new_data.equipped then
			new_data.buttons = {
				"custom_select"
			}
		else
			new_data.buttons = {
				"custom_unselect"
			}
		end

		data[i] = new_data
	end

	local max_slots = data.override_slots[1] * data.override_slots[2]

	for i = 1, max_slots do
		if not data[i] then
			new_data = {
				name = "empty",
				name_localized = "",
				category = category,
				unlocked = true,
				equipped = false
			}
			data[i] = new_data
		end
	end
end

function CrewManagementGui:populate_characters(henchman_index, data, gui)
	gui:populate_characters(data)

	local preferred = managers.blackmarket:preferred_henchmen()

	for k, v in ipairs(data) do
		local equipped_by = table.get_key(preferred, v.name)
		v.equipped = equipped_by
		v.equipped_by = equipped_by
		v.equipped_text = v.equipped_by and tostring(equipped_by) or nil

		if v.unlocked then
			v.buttons = {
				v.equipped and "custom_unselect" or "custom_select",
				"c_clear_slots"
			}
		else
			v.buttons = {}
		end
	end
end

function CrewManagementGui:populate_suits(henchman_index, data, gui)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)

	if data.identifier == Idstring("player_style") then
		data.equipped_player_style = loadout.player_style or managers.blackmarket:get_default_player_style()
		data.customize_equipped_only = true

		gui:populate_player_styles(data)

		data.mannequin_player_style = nil
	elseif data.identifier == Idstring("glove") then
		data.equipped_glove_id = loadout.glove_id or managers.blackmarket:get_default_glove_id()

		gui:populate_gloves(data)

		data.mannequin_glove_id = nil
	end
end

function CrewManagementGui:populate_suit_variations(henchman_index, data, gui)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	data.suit_variation = loadout.suit_variation or "default"

	gui:populate_suit_variations(data)
end

function CrewManagementGui:select_weapon(index, data, gui)
	print("[CrewManagementGui]:select_weapon", index, data, gui)

	local loadout = managers.blackmarket:henchman_loadout(index)

	if data.equipped then
		loadout.primary = nil
		loadout.primary_slot = nil
	else
		local crafted = managers.blackmarket:get_crafted_category_slot(data.category, data.slot)
		loadout.primary = crafted.factory_id .. "_npc"
		loadout.primary_slot = data.slot

		print(loadout.primary_slot)
	end

	gui:reload()
end

function CrewManagementGui:buy_new_weapon(data, gui)
	data.on_create_func = callback(self, self, "populate_buy_weapon", gui)

	gui:open_weapon_buy_menu(data)
end

function CrewManagementGui:select_mask(index, data, gui)
	print("[CrewManagementGui]:select_mask", index, data, gui)

	local loadout = managers.blackmarket:henchman_loadout(index)
	loadout.mask = data.name
	loadout.mask_slot = data.slot

	gui:reload()
end

function CrewManagementGui:select_ability(index, data, gui)
	self:select_skill({
		"ability",
		index
	}, data, gui)
end

function CrewManagementGui:select_skill(params, data, gui)
	local loadout_name, henchman_index = unpack(params)
	local map = self:_create_member_loadout_map(loadout_name)
	local loadout = managers.blackmarket:henchman_loadout(henchman_index)
	loadout[loadout_name] = data.name

	if map[data.name] then
		managers.blackmarket:henchman_loadout(map[data.name])[loadout_name] = nil
	end

	gui:reload()
end

function CrewManagementGui:select_characters(data, gui)
	local preferred = managers.blackmarket:preferred_henchmen()

	if data.equipped_by then
		print("unselect")
		managers.blackmarket:set_preferred_henchmen(data.equipped_by, nil)
	else
		local index = math.min(#preferred + 1, 3)

		print(index, #preferred)
		managers.blackmarket:set_preferred_henchmen(index, data.name)
	end

	gui:reload()
end

function CrewManagementGui:select_player_style(index, data, gui)
	local loadout = managers.blackmarket:henchman_loadout(index)
	loadout.player_style = data.name
	loadout.suit_variation = managers.blackmarket:get_suit_variation(loadout.player_style)

	managers.menu_scene:set_character_player_style(loadout.player_style, loadout.suit_variation)
	gui:reload()
end

function CrewManagementGui:select_suit_variation(index, data, gui)
	local loadout = managers.blackmarket:henchman_loadout(index)
	loadout.suit_variation = data.name

	managers.menu_scene:set_character_player_style(loadout.player_style, loadout.suit_variation)
	gui:reload()
end

function CrewManagementGui:select_glove(index, data, gui)
	local loadout = managers.blackmarket:henchman_loadout(index)
	loadout.glove_id = data.name

	managers.menu_scene:set_character_gloves(loadout.glove_id)
	gui:reload()
end

function CrewManagementGui:clear_character_order(data, gui)
	local preferred = managers.blackmarket:preferred_henchmen()

	for k, v in pairs(preferred) do
		preferred[k] = nil
	end

	gui:reload()
end
