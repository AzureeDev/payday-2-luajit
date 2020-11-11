require("lib/managers/menu/ExtendedUiElemets")
require("lib/managers/menu/WalletGuiObject")

local FONT = tweak_data.menu.pd2_small_font
local FONT_SIZE = tweak_data.menu.pd2_small_font_size
local FONT_LARGE = tweak_data.menu.pd2_large_font
local FONT_SIZE_LARGE = tweak_data.menu.pd2_large_font_size
local TEXT_COLOR = tweak_data.screen_colors.text
local BG_COLOR = tweak_data.screen_colors.dark_bg
local MOUSEOVER_COLOR = tweak_data.screen_colors.button_stage_2
local BUTTON_COLOR = tweak_data.screen_colors.button_stage_3
InfamyTreeItem = InfamyTreeItem or class(ListItem)

function InfamyTreeItem:init(parent, data)
	InfamyTreeItem.super.init(self, parent, {
		w = 152,
		input = false,
		h = parent:h()
	})

	self.data = data
	self._content_panel = self._panel:panel()

	self:setup_panel()
end

function InfamyTreeItem:setup_panel()
	self._select_panel = self._panel:panel({
		layer = 5,
		visible = false
	})

	BoxGuiObject:new(self._select_panel, {
		sides = {
			2,
			2,
			2,
			2
		}
	})
	self:setup_content_panel()
end

function InfamyTreeItem:setup_content_panel()
	self._content_panel:stop()
	self._content_panel:clear()

	local margin = 10
	self.locked = not managers.infamy:owned(self.data.tier_id) and managers.experience:current_rank() < self.data.rank_requirement
	self.can_unlock = not managers.infamy:owned(self.data.tier_id) and self.data.rank_requirement <= managers.experience:current_rank()

	if self.locked and not self.can_unlock then
		self.name_id = "menu_infamy_box_title"
		self.desc_id = "menu_infamy_box_description"
	elseif not self.locked and self.can_unlock then
		self.name_id = "menu_infamy_box_title"
		self.desc_id = "menu_infamy_box_description"
	else
		self.name_id = self.data.tier_data.name_id
		self.desc_id = self.data.tier_data.desc_id
	end

	local main_image_texture, main_image_texture_rect, blend_mode = self:get_item_texture_and_rect()
	local main_image_panel = self._content_panel:panel({
		name = "image",
		w = self._content_panel:w() - 50,
		h = self._content_panel:h() - 50
	})

	main_image_panel:set_center_x(self._content_panel:w() / 2)
	main_image_panel:set_center_y(self._content_panel:w() / 2 - 20)

	if DB:has(Idstring("texture"), main_image_texture) then
		local main_image = main_image_panel:bitmap({
			layer = 7,
			texture = main_image_texture,
			texture_rect = main_image_texture_rect,
			blend_mode = blend_mode
		})
		local proportion = main_image:w() / main_image:h()

		main_image:set_size(main_image_panel:w() * proportion, main_image_panel:h())
		main_image:set_center(main_image_panel:w() / 2, main_image_panel:h() / 2)
	end

	local number_text = self._content_panel:text({
		layer = 5,
		text = tostring(self.data.rank_requirement),
		font_size = FONT_SIZE,
		font = FONT,
		color = self.can_unlock and MOUSEOVER_COLOR or TEXT_COLOR
	})

	self.make_fine_text(number_text)
	number_text:set_center_x(self._content_panel:w() / 2)
	number_text:set_bottom(self._content_panel:bottom() - margin)

	if self.data.rank_requirement <= managers.experience:current_rank() then
		local at_level = self:is_current_unlockable() and 0.5 or 1
		local item_height = 16
		local line_panel = self._content_panel:panel()
		local line_image = line_panel:bitmap({
			blend_mode = "add",
			texture = "guis/dlcs/infamous/textures/pd2/infamous_tree/connector_df",
			layer = 4,
			wrap_mode = "wrap",
			h = item_height,
			w = line_panel:w() * at_level
		})

		line_image:set_center_y(number_text:center_y())

		local glow_size = math.min(self._content_panel:h(), self._content_panel:w())
		local glow_panel = self._content_panel:panel({
			w = glow_size,
			h = glow_size,
			visible = not self.locked and self.can_unlock
		})

		glow_panel:set_center(main_image_panel:center())

		local glow1 = glow_panel:bitmap({
			texture = "guis/dlcs/infamous/textures/pd2/infamous_tree/spinner_01_df",
			name = "glow1",
			layer = 5,
			blend_mode = "add",
			halign = "scale",
			rotation = 360,
			valign = "scale",
			w = glow_size,
			h = glow_size,
			color = tweak_data.screen_colors.text
		})
		local glow2 = glow_panel:bitmap({
			texture = "guis/dlcs/infamous/textures/pd2/infamous_tree/spinner_02_df",
			name = "glow2",
			layer = 5,
			blend_mode = "add",
			halign = "scale",
			rotation = 360,
			valign = "scale",
			w = glow_size,
			h = glow_size,
			color = tweak_data.screen_colors.text
		})

		self._content_panel:animate(function ()
			local t = 0
			local old_t = 0
			local dt = 0
			local speed = math.random() * 0.1 + 0.4
			local movement = 0
			local r1 = (0.5 + math.rand(0.3)) * 95
			local r2 = -(0.5 + math.rand(0.3)) * 95
			local scroll_right = self.data.scroll_right - self._panel:w()
			local cx, cy, s, gs = nil

			while true do
				dt = coroutine.yield()
				t = (t + dt * speed) % 1
				gs = math.min(math.clamp(math.inverse_lerp(-self._panel:w() / 2, 0, self._panel:world_x()), 0.01, 1), math.clamp(math.inverse_lerp(scroll_right + self._panel:w() / 2, scroll_right, self._panel:world_x()), 0.01, 1))

				glow1:rotate(dt * r1)
				glow2:rotate(dt * r2)

				cx, cy = glow_panel:center()
				s = (math.sin(t * 180) * 0.1 + 0.9) * glow_size * 1.05 * gs

				glow_panel:set_size(s, s)
				glow_panel:set_center(cx, cy)

				movement = (movement + dt * 10 * 0.5) % line_image:texture_width()

				line_image:set_texture_coordinates(Vector3(-movement, 0, 0), Vector3(line_image:w() - movement, 0, 0), Vector3(-movement, item_height, 0), Vector3(line_image:w() - movement, item_height, 0))

				if t < old_t then
					speed = math.random() * 0.1 + 0.4
				end

				old_t = t
			end
		end)
	end
end

function InfamyTreeItem:set_backlight(state)
	if self._backlight then
		self._panel:remove(self._backlight)
	end

	if state then
		self._backlight = self._panel:rect({
			name = "backlight",
			layer = 1,
			color = Color(125, 0, 0, 0) / 255
		})
	else
		self._backlight = self._panel:rect({
			name = "backlight",
			layer = 1,
			color = Color(175, 0, 0, 0) / 255
		})
	end
end

function InfamyTreeItem:get_item_texture_and_rect()
	local texture_id, texture_rect = nil
	local blend_mode = "normal"

	if self:is_open() and self:is_previewable() then
		local item_id = self:get_previewable_id()
		local category_id = self:get_preview_category()
		local td = tweak_data.blackmarket[category_id][item_id]
		texture_id = "guis/"
		local bundle_folder = td.texture_bundle_folder

		if bundle_folder then
			texture_id = texture_id .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		if category_id == "weapon_skins" then
			category_id = "weapon_color"
		end

		texture_id = texture_id .. "textures/pd2/blackmarket/icons/" .. category_id .. "/" .. item_id
	else
		local xy = (self.locked or self.can_unlock) and {
			2,
			2
		} or self.data.tier_data.icon_xy
		local texture_rect_x = xy and xy[1] or 2
		local texture_rect_y = xy and xy[2] or 2
		texture_id = "guis/dlcs/infamous/textures/pd2/infamous_tree/infamous_tree_atlas"
		texture_rect = {
			texture_rect_x * 128,
			texture_rect_y * 128,
			128,
			128
		}
		blend_mode = "add"
	end

	if not DB:has(Idstring("texture"), texture_id) then
		texture_id = "guis/textures/pd2/endscreen/what_is_this"
		texture_rect = nil
	end

	return texture_id, texture_rect, blend_mode
end

function InfamyTreeItem:get_child(name)
	return self._content_panel:child(name)
end

function InfamyTreeItem:is_current_unlockable()
	local list = tweak_data.infamy.tree

	for i = managers.experience:current_rank(), 0, -1 do
		if list[i] then
			if list[i] == self.data.tier_id then
				return true
			end

			break
		end
	end

	return false
end

function InfamyTreeItem:is_open()
	return not self.locked and not self.can_unlock
end

function InfamyTreeItem:get_infamy_item()
	return tweak_data.infamy.items[self.data.tier_id]
end

function InfamyTreeItem:get_infamy_upgrades()
	return self:get_infamy_item().upgrades
end

function InfamyTreeItem:is_previewable()
	local tdu = self:get_infamy_upgrades()

	return tdu and tdu[1] and tdu[1][2] and (tdu[1][2] == "masks" or tdu[1][2] == "weapon_skins" or tdu[1][2] == "gloves" or tdu[1][2] == "player_styles")
end

function InfamyTreeItem:get_previewable_id()
	return self:is_previewable() and self:get_infamy_upgrades()[1][3]
end

function InfamyTreeItem:get_preview_category()
	return self:is_previewable() and self:get_infamy_upgrades()[1][2]
end

function InfamyTreeItem:spawn_preview()
	if self:is_previewable() then
		if self:get_preview_category() == "masks" then
			managers.menu_scene:spawn_mask(self:get_previewable_id(), nil, Vector3(-50, 0, 10))
		elseif self:get_preview_category() == "player_styles" then
			managers.menu_scene:spawn_infamy_outfit_preview(self:get_previewable_id(), self:get_infamy_upgrades()[1][4] or nil)
		elseif self:get_preview_category() == "gloves" then
			managers.menu_scene:spawn_infamy_gloves_preview(self:get_previewable_id())
		elseif self:get_preview_category() == "weapon_skins" then
			managers.menu_scene:spawn_infamy_weapon_preview(self:get_previewable_id())
		end
	elseif self:is_open() then
		if self:get_infamy_upgrades().join_stingers then
			managers.menu_scene:spawn_infamy_card_preview("enable_card_sound", true)
		elseif self:get_infamy_upgrades().infamous_xp then
			managers.menu_scene:spawn_infamy_card_preview("enable_card_exp", true)
		end
	end
end

function InfamyTreeItem:_selected_changed(state)
	InfamyTreeItem.super._selected_changed(self, state)

	if not _G.IS_VR then
		if self:is_open() then
			if state then
				self:spawn_preview()
			elseif self:get_preview_category() == "masks" then
				managers.menu_scene:remove_item()
			elseif self:get_preview_category() == "player_styles" then
				managers.menu_scene:remove_outfit()
			elseif self:get_preview_category() == "gloves" then
				managers.menu_scene:remove_gloves()
			else
				managers.menu_scene:remove_item()
			end
		elseif state then
			managers.menu_scene:spawn_infamy_card_preview()
		else
			managers.menu_scene:remove_item()
		end
	end
end

ComingSoonItem = ComingSoonItem or class(ListItem)

function ComingSoonItem:init(parent)
	ComingSoonItem.super.init(self, parent, {
		w = 152,
		input = false,
		h = parent:h()
	})

	self.item_locked = false
	self.name_id = "menu_infamy_coming_soon_title"
	self.desc_id = "menu_infamy_coming_soon_desc"
	self.data = {
		tier_data = {
			desc_params = {}
		}
	}

	self._panel:text({
		wrap = true,
		align = "center",
		vertical = "center",
		text = managers.localization:text("menu_infamy_coming_soon"),
		font_size = FONT_SIZE,
		font = FONT,
		color = TEXT_COLOR
	})

	self._select_panel = self._panel:panel({
		layer = 5,
		visible = false
	})

	BoxGuiObject:new(self._select_panel, {
		sides = {
			2,
			2,
			2,
			2
		}
	})
end

function ComingSoonItem:is_previewable()
	return false
end

function ComingSoonItem:is_open()
	return false
end

local is_win_32 = SystemInfo:platform() == Idstring("WIN32")
local WIDTH_MULTIPLIER = is_win_32 and 0.65 or 0.5
InfamyTreeGui = InfamyTreeGui or class(ExtendedPanel)

function InfamyTreeGui:init(ws, fullscreen_ws, node)
	if InfamyTreeGui.panel_crash_protection then
		InfamyTreeGui.panel_crash_protection:remove_self()
	end

	InfamyTreeGui.super.init(self, ws:panel())

	InfamyTreeGui.panel_crash_protection = self

	managers.menu:active_menu().renderer.ws:hide()

	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._init_layer = self._ws:panel():layer()
	self._fullscreen_panel = self._fullscreen_ws:panel():panel()

	WalletGuiObject.set_wallet(self)
	managers.menu_scene:setup_infamy_menu()
	self:_setup()

	local player_rank = managers.experience:current_rank()
	local closest_difference = 1000
	local closest_rank = self.scroll:items()[1]

	for index, item in ipairs(self.scroll:items()) do
		if getmetatable(item) == InfamyTreeItem then
			local difference = math.abs(item.data.rank_requirement - player_rank)

			if difference < closest_difference then
				closest_difference = difference
				closest_rank = item
			end
		end
	end

	self.scroll:select_item(closest_rank)
	self.scroll:scroll_to_show_item_at_world(self.scroll:selected_item(), self.scroll:world_center_x())
end

function InfamyTreeGui:_setup()
	if alive(self._panel) then
		self._ws:panel():remove(self._panel)
	end

	managers.menu_scene:setup_infamy_menu()

	self._requested_textures = {}
	self._panel = self._ws:panel():panel({
		valign = "center",
		input = true,
		visible = true,
		layer = self._init_layer
	})
	local title_text = self._panel:text({
		vertical = "top",
		name = "infamytree_text",
		align = "left",
		text = utf8.to_upper(managers.localization:text("menu_infamytree")),
		h = tweak_data.menu.pd2_large_font_size,
		font_size = tweak_data.menu.pd2_large_font_size,
		font = tweak_data.menu.pd2_large_font,
		color = tweak_data.screen_colors.text
	})
	local title_bg_text = self._fullscreen_panel:text({
		name = "infamytree_text",
		vertical = "top",
		h = 90,
		alpha = 0.4,
		align = "left",
		blend_mode = "add",
		layer = 1,
		text = utf8.to_upper(managers.localization:text("menu_infamytree")),
		font_size = tweak_data.menu.pd2_massive_font_size,
		font = tweak_data.menu.pd2_massive_font,
		color = BUTTON_COLOR
	})
	local x, y = managers.gui_data:safe_to_full_16_9(title_text:world_x(), title_text:world_center_y())
	local td = tweak_data.infamy

	title_bg_text:set_world_left(x)
	title_bg_text:set_world_center_y(y)
	title_bg_text:move(-13, 9)
	MenuBackdropGUI.animate_bg_text(self, title_bg_text)

	self.main_display_panel = self._panel:panel({
		w = 400,
		h = 300
	})

	self.main_display_panel:set_world_center_x(self._panel:world_center_x())
	self.main_display_panel:set_world_center_y(self._panel:world_center_y() - 75)

	self.scroll_panel = self._panel:panel({
		h = 175,
		x = 0,
		y = self._panel:h() - 225,
		w = self._panel:w()
	})
	self.scroll = HorizontalScrollItemList:new(self.scroll_panel, {
		horizontal = true,
		scrollbar_padding = 10,
		padding = 0
	}, {})

	self.scroll:add_lines_and_static_down_indicator()
	self.scroll:set_selected_callback(callback(self, self, "update_detail_panels"))

	for i, item_id in pairs(td.tree) do
		local data = td.items[item_id]

		self:check_infamous_drop_parameter(data)
		self.scroll:add_item(InfamyTreeItem:new(self.scroll:canvas(), {
			tier_id = item_id,
			tier_data = data,
			rank_requirement = i,
			scroll_right = self.scroll_panel:w()
		}))
	end

	self.scroll:sort_items(function (lhs, rhs)
		return lhs.data.rank_requirement < rhs.data.rank_requirement
	end, nil, true)

	for i, item in ipairs(self.scroll:items()) do
		item:set_backlight(i % 2 == 0)
	end

	self.scroll:add_item(ComingSoonItem:new(self.scroll:canvas()))
	self.scroll:set_input_focus(true)

	self.detail_panel = self._panel:panel({
		w = 325,
		y = title_text:bottom() + 10,
		h = self.scroll:world_y() - (title_text:bottom() + 10) - 5
	})

	self.detail_panel:set_bottom(self.scroll_panel:top() - 5)
	self.detail_panel:set_right(self.scroll_panel:right())
	self.detail_panel:rect({
		color = BG_COLOR
	})
	BoxGuiObject:new(self.detail_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	self.detail_panel_content = self.detail_panel:panel()
	self.infamous_panel = self._panel:panel({
		w = 350,
		x = title_text:left(),
		y = title_text:bottom() + 10,
		h = self.scroll_panel:top() - 10 - (title_text:bottom() + 10)
	})

	self.infamous_panel:rect({
		color = BG_COLOR
	})
	BoxGuiObject:new(self.infamous_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	self.infamous_panel:text({
		y = 5,
		x = 15,
		layer = 3,
		text = managers.localization:text("menu_infamy_infamy_panel_infamy_level", {
			infamy = managers.experience:current_rank()
		}),
		h = FONT_SIZE,
		font = FONT,
		font_size = FONT_SIZE,
		color = TEXT_COLOR
	})
	self.infamous_panel:text({
		y = 50,
		align = "center",
		layer = 3,
		text = managers.localization:text("menu_infamy_infamy_panel_reputation_level", {
			reputation = managers.experience:current_level()
		}),
		h = FONT_SIZE,
		font = FONT,
		font_size = FONT_SIZE,
		color = TEXT_COLOR
	})

	local progress_bar_panel = self.infamous_panel:panel({
		y = 70,
		h = FONT_SIZE
	})
	local progress_y_pos = progress_bar_panel:h() / 2 - FONT_SIZE / 2
	local progress_margin = 40
	local max_width = progress_bar_panel:w() - progress_margin * 2

	progress_bar_panel:rect({
		x = progress_margin,
		y = progress_y_pos + FONT_SIZE / 4,
		w = max_width,
		h = FONT_SIZE / 2,
		color = tweak_data.screen_color_grey
	})
	progress_bar_panel:rect({
		x = progress_margin,
		y = progress_y_pos + FONT_SIZE / 4,
		w = math.lerp(0, max_width, managers.experience:current_level() / 100),
		h = FONT_SIZE / 2,
		color = tweak_data.screen_color_light_grey
	})
	progress_bar_panel:text({
		vertical = "center",
		text = "1",
		layer = 3,
		x = progress_margin - 15,
		y = progress_y_pos,
		h = FONT_SIZE,
		font = FONT,
		font_size = FONT_SIZE,
		color = TEXT_COLOR
	})
	progress_bar_panel:text({
		vertical = "center",
		text = "100",
		layer = 3,
		x = progress_margin + max_width + 5,
		y = progress_y_pos,
		h = FONT_SIZE,
		font = FONT,
		font_size = FONT_SIZE,
		color = TEXT_COLOR
	})

	local card_id, card_rect = managers.infamy:get_infamy_card_id_and_rect()
	local card_proportion = card_rect[3] / card_rect[4]
	local card_panel = self.infamous_panel:panel({
		h = 150,
		y = progress_bar_panel:bottom() + 10,
		w = 150 * card_proportion
	})

	card_panel:set_center_x(self.infamous_panel:w() / 2)

	local card_bitmap = card_panel:bitmap({
		layer = 2,
		w = card_panel:w(),
		h = card_panel:h(),
		texture = card_id,
		texture_rect = card_rect
	})

	card_panel:text({
		vertical = "center",
		align = "center",
		layer = 3,
		text = tostring(managers.experience:current_rank()),
		font = FONT_LARGE,
		font_size = FONT_SIZE_LARGE,
		color = Color.black
	})

	local error_string = nil

	if managers.experience:current_level() < 100 then
		self._can_go_infamous = false
		error_string = managers.localization:text("menu_infamy_go_infamous_error_level")
	elseif managers.crime_spree:in_progress() then
		self._can_go_infamous = false
		error_string = managers.localization:text("menu_infamy_go_infamous_error_crime_spree")
	elseif managers.money:offshore() < managers.money:get_infamous_cost(managers.experience:current_rank() + 1) then
		self._can_go_infamous = false
		error_string = managers.localization:text("menu_infamy_go_infamous_error_money")
	else
		self._can_go_infamous = true
	end

	local go_inf_button = self.infamous_panel:panel({
		name = "go_infamous_button",
		h = 50,
		y = card_panel:bottom() + 20
	})
	local go_inf_text = go_inf_button:text({
		name = "go_infamous_text",
		align = "center",
		layer = 3,
		text = utf8.to_upper(managers.localization:text("menu_infamy_button_go_infamous")),
		h = FONT_LARGE,
		font = FONT_LARGE,
		font_size = FONT_SIZE_LARGE,
		color = self._can_go_infamous and BUTTON_COLOR or tweak_data.screen_colors.item_stage_3
	})
	local error_text = self._can_go_infamous or self.infamous_panel:text({
		wrap = true,
		align = "center",
		x = 40,
		layer = 3,
		text = error_string,
		y = go_inf_button:bottom(),
		w = self.infamous_panel:w() - 80,
		font = FONT,
		font_size = FONT_SIZE,
		color = Color.red
	})

	if managers.menu:is_pc_controller() then
		local back_button = self._panel:text({
			vertical = "bottom",
			name = "back_button",
			align = "right",
			blend_mode = "add",
			text = utf8.to_upper(managers.localization:text("menu_back")),
			h = tweak_data.menu.pd2_large_font_size,
			font_size = tweak_data.menu.pd2_large_font_size,
			font = tweak_data.menu.pd2_large_font,
			color = BUTTON_COLOR
		})
		local _, _, w, h = back_button:text_rect()

		back_button:set_size(w, h)
		back_button:set_position(math.round(back_button:x()), math.round(back_button:y()))
		back_button:set_right(self._panel:w())
		back_button:set_bottom(self._panel:h())

		local bg_back = self._fullscreen_panel:text({
			name = "TitleTextBg",
			vertical = "bottom",
			h = 90,
			align = "right",
			alpha = 0.4,
			blend_mode = "add",
			layer = 1,
			text = back_button:text(),
			font_size = tweak_data.menu.pd2_massive_font_size,
			font = tweak_data.menu.pd2_massive_font,
			color = BUTTON_COLOR
		})
		local x, y = managers.gui_data:safe_to_full_16_9(back_button:world_right(), back_button:world_center_y())

		bg_back:set_world_right(x)
		bg_back:set_world_center_y(y)
		bg_back:move(13, -9)
		MenuBackdropGUI.animate_bg_text(self, bg_back)
	end
end

function InfamyTreeGui:close()
	if self._panel then
		self:remove_self()

		self._panel = nil
		InfamyTreeGui.panel_crash_protection = nil
	end

	self._fullscreen_ws:panel():remove(self._fullscreen_panel)
	managers.menu:active_menu().renderer.ws:show()
	WalletGuiObject.close_wallet(self)

	if alive(self._blur_ws) then
		self._blur:parent():remove(self._blur)
		managers.gui_data:destroy_workspace(self._blur_ws)

		self._blur_ws = nil
	end
end

function InfamyTreeGui:update_detail_panels()
	local item = self.scroll:selected_item()

	self.main_display_panel:clear()
	self.detail_panel_content:clear()

	if item.data.rank_requirement and managers.experience:current_rank() < item.data.rank_requirement then
		local overlap_panel = self.main_display_panel:panel({
			layer = 2,
			h = self.main_display_panel:h() / 6
		})

		overlap_panel:set_center_y(self.main_display_panel:h() / 2)
		overlap_panel:rect({
			color = Color(200, 0, 0, 0) / 255
		})

		local reason_text = item.locked and "menu_infamy_banner_unlock" or "menu_infamy_banner_already_unlocked"
		local overlap_text = overlap_panel:text({
			align = "center",
			layer = 3,
			text = managers.localization:text(reason_text, {
				rank = item.data.rank_requirement
			}),
			font_size = FONT_SIZE,
			font = FONT,
			color = TEXT_COLOR
		})

		ExtendedPanel.make_fine_text(overlap_text)
		overlap_text:set_center_y(overlap_panel:h() / 2)
		overlap_text:set_center_x(overlap_panel:w() / 2)
	end

	local margin = 10
	local detail_title = self.detail_panel_content:text({
		layer = 5,
		text = utf8.to_upper(managers.localization:text(item.name_id)),
		font_size = FONT_SIZE,
		font = FONT,
		color = TEXT_COLOR
	})

	ExtendedPanel.make_fine_text(detail_title)
	detail_title:set_top(margin)
	detail_title:set_left(margin)

	local detail_desc = self.detail_panel_content:text({
		wrap = true,
		word_wrap = true,
		layer = 5,
		text = managers.localization:text(item.desc_id, item.data.tier_data.desc_params),
		font_size = FONT_SIZE,
		font = FONT,
		color = TEXT_COLOR
	})

	detail_desc:set_w(self.detail_panel_content:w() - margin * 2)
	detail_desc:set_top(detail_title:bottom())
	detail_desc:set_left(margin)
	self.make_fine_text(detail_desc)
	detail_desc:set_align("justified")
	managers.menu_component:add_colors_to_text_object(detail_desc, tweak_data.screen_colors.resource)

	if item:is_open() then
		local desc_upgrade = self.detail_panel_content:panel({
			name = "description_upgrade",
			x = 5,
			h = 200,
			w = self.detail_panel_content:w() - 10
		})

		desc_upgrade:set_bottom(self.detail_panel_content:bottom() - 5)

		local infamy_tweak = item:get_infamy_item()
		local item_amount = 0

		for _, upgrade in ipairs(infamy_tweak.upgrades) do
			local category = upgrade[2]

			if category == "colors" or category == "textures" or category == "materials" or category == "masks" or category == "weapon_skins" or category == "gloves" or category == "player_styles" then
				item_amount = item_amount + 1
			end
		end

		local x_pos_increment = (desc_upgrade:w() + 100) / (item_amount + 1)
		local x = x_pos_increment - 50
		local icon_size = 64
		local y_pos = desc_upgrade:h() - icon_size - 10

		for bonus, item in ipairs(infamy_tweak.upgrades) do
			local global_value = item[1]
			local category = item[2]
			local item_id = item[3]

			if category == "join_stingers" == false then
				local item_tweak_data = tweak_data.blackmarket[category][item_id]

				if category == "player_styles" then
					local material_variation = tweak_data.blackmarket[category][item_id].material_variations
					item_tweak_data = material_variation and material_variation[item[4]] or tweak_data.blackmarket[category][item_id]
				end

				local guis_catalog = "guis/"
				local bundle_folder = item_tweak_data and item_tweak_data.texture_bundle_folder

				if bundle_folder then
					guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
				end

				if category == "colors" then
					local colors_panel = desc_upgrade:panel({
						name = item_id .. "_color_panel",
						x = x - icon_size / 2,
						y = y_pos,
						w = icon_size,
						h = icon_size
					})

					colors_panel:bitmap({
						texture = "guis/textures/pd2/blackmarket/icons/colors/color_bg",
						layer = 2,
						name = item_id .. "_color_bg"
					})
					colors_panel:bitmap({
						texture = "guis/textures/pd2/blackmarket/icons/colors/color_02",
						layer = 1,
						name = item_id .. "_color_1",
						color = tweak_data.blackmarket.colors[item_id].colors[1]
					})
					colors_panel:bitmap({
						texture = "guis/textures/pd2/blackmarket/icons/colors/color_01",
						layer = 1,
						name = item_id .. "_color_2",
						color = tweak_data.blackmarket.colors[item_id].colors[2]
					})
				elseif category == "textures" then
					local icon_texture = tweak_data.blackmarket.textures[item_id].texture

					if DB:has(Idstring("texture"), icon_texture) then
						local panel = desc_upgrade:panel({
							layer = 1,
							name = item_id .. "_image",
							x = x - icon_size / 2,
							y = y_pos,
							w = icon_size,
							h = icon_size
						})
						local texture_count = managers.menu_component:request_texture(icon_texture, callback(self, self, "_texture_done_clbk", {
							render_template = "VertexColorTexturedPatterns",
							panel = panel
						}))

						self:add_loading_animation(panel)
						table.insert(self._requested_textures, {
							texture_count = texture_count,
							texture = icon_texture
						})
					end
				elseif category == "weapon_skins" then
					local icon_texture = guis_catalog .. "textures/pd2/blackmarket/icons/weapon_color/" .. item_id

					if DB:has(Idstring("texture"), icon_texture) then
						desc_upgrade:bitmap({
							layer = 1,
							name = item_id .. "_image",
							x = x - icon_size / 2,
							y = y_pos,
							w = icon_size,
							h = icon_size,
							texture = icon_texture,
							texture_rect = {
								62,
								10,
								132,
								108
							}
						})
					end
				else
					local icon_texture = guis_catalog .. "textures/pd2/blackmarket/icons/" .. category .. "/" .. item_id

					if DB:has(Idstring("texture"), icon_texture) then
						if category == "materials" then
							local panel = desc_upgrade:panel({
								layer = 1,
								name = item_id .. "_image",
								x = x - icon_size / 2,
								y = y_pos,
								w = icon_size,
								h = icon_size
							})
							local texture_count = managers.menu_component:request_texture(icon_texture, callback(self, self, "_texture_done_clbk", {
								panel = panel
							}))

							self:add_loading_animation(panel)
							table.insert(self._requested_textures, {
								texture_count = texture_count,
								texture = icon_texture
							})
						else
							local bm = desc_upgrade:bitmap({
								layer = 1,
								name = item_id .. "_image",
								texture = icon_texture
							})
							local proportion = bm:w() / bm:h()

							bm:set_size(icon_size * proportion, icon_size)
							bm:set_position(x - bm:w() / 2, y_pos)
						end
					end
				end

				local icon_text = desc_upgrade:text({
					wrap = true,
					word_wrap = true,
					align = "center",
					layer = 1,
					name = item_id .. "_text",
					text = managers.localization:text(item_tweak_data.name_id),
					h = icon_size,
					w = desc_upgrade:w() / 3 - 5,
					font = tweak_data.menu.pd2_medium_font,
					font_size = tweak_data.menu.pd2_medium_font_size
				})

				self.make_fine_text(icon_text)
				icon_text:set_center_x(x)
				icon_text:set_center_y(y_pos - 30)

				x = x + x_pos_increment
			end
		end
	end
end

function InfamyTreeGui:item_clicked(item)
	if item.can_unlock and not managers.infamy:owned(item.data.tier_id) then
		local params = {
			yes_func = callback(self, self, "unlock_infamy_item", item)
		}

		managers.menu:show_confirm_infamy_unlock(params)

		return
	end
end

function InfamyTreeGui:unlock_infamy_item(item)
	if item.can_unlock and not managers.infamy:owned(item.data.tier_id) then
		if item:get_preview_category() == "player_styles" then
			local suit_variation = item:get_infamy_upgrades()[1][4]

			if suit_variation then
				managers.infamy:reward_suit_variations(nil, nil, item:get_previewable_id(), suit_variation)
			else
				managers.infamy:reward_player_styles(nil, nil, item:get_previewable_id())
			end
		end

		managers.infamy:unlock_item(item.data.tier_id)
		item:setup_content_panel()

		if item:get_infamy_upgrades().join_stingers then
			managers.menu:play_join_stinger_by_index(item:get_infamy_upgrades().join_stingers[1])
		else
			managers.menu_component:post_event("menu_skill_investment")
		end

		SimpleGUIEffectSpewer.infamous_up(item:get_child("image"):center_x(), item:get_child("image"):center_y(), item._panel)
		self:update_detail_panels()

		if not _G.IS_VR then
			managers.menu_scene:remove_item()
			item:spawn_preview()
		end
	end
end

function InfamyTreeGui:check_infamous_drop_parameter(data)
	if data.upgrades and data.upgrades.infamous_lootdrop then
		local stars = managers.experience:level_to_stars()
		local item_pc = tweak_data.lootdrop.STARS[stars].pcs[1]
		local skip_types = {
			xp = true,
			cash = true
		}
		local droppable_items = managers.lootdrop:droppable_items(item_pc, true, skip_types)
		local items_total = 0
		local items_infamous = 0

		for type, items in pairs(droppable_items) do
			items_total = items_total + #items

			for _, item in pairs(items) do
				if item.global_value == "infamous" then
					items_infamous = items_infamous + 1
				end
			end
		end

		local _, infamous_base_chance, infamous_mod = managers.lootdrop:infamous_chance({
			disable_difficulty = true
		})
		local infamous_chance = items_total > 0 and infamous_base_chance * items_infamous / items_total or 0
		local mult = 10
		local base_text = math.floor(infamous_chance * 100 * mult + 0.5) / mult
		local buffed_text = base_text * data.upgrades.infamous_lootdrop
		data.desc_params.base_chance = string.format("%.1f", base_text) .. "%"
		data.desc_params.buffed_chance = string.format("%.1f", buffed_text) .. "%"
	end
end

function InfamyTreeGui:input_focus()
	if managers.menu_scene and managers.menu_scene:input_focus() then
		return false
	end

	return 2
end

function InfamyTreeGui:mouse_moved(o, x, y)
	if managers.menu_scene and managers.menu_scene:input_focus() then
		return false
	end

	local used = false
	local pointer = "arrow"

	if self._can_go_infamous then
		local inf_button = self.infamous_panel:child("go_infamous_button")

		if not self._infamous_highlight and inf_button:inside(x, y) then
			used = true
			pointer = "link"
			self._infamous_highlight = true

			inf_button:child("go_infamous_text"):set_color(MOUSEOVER_COLOR)
			managers.menu_component:post_event("highlight")
		elseif self._infamous_highlight and not inf_button:inside(x, y) then
			self._infamous_highlight = false

			inf_button:child("go_infamous_text"):set_color(BUTTON_COLOR)
		end
	end

	local back_button = self._panel:child("back_button")

	if not used and back_button:inside(x, y) then
		used = true
		pointer = "link"

		if not self._back_highlight then
			self._back_highlight = true

			back_button:set_color(MOUSEOVER_COLOR)
			managers.menu_component:post_event("highlight")
		end
	elseif self._back_highlight then
		self._back_highlight = false

		back_button:set_color(BUTTON_COLOR)
	end

	if not used and self.scroll:inside(x, y) and self.scroll:input_focus() then
		used, pointer = self.scroll:mouse_moved("", x, y)
	end

	return used, pointer
end

function InfamyTreeGui:mouse_pressed(button, x, y)
	self.scroll:mouse_pressed(button, x, y)

	if button == Idstring("0") then
		if self._panel:child("back_button"):inside(x, y) then
			managers.menu:back()

			return
		end

		if self._can_go_infamous and self.infamous_panel:child("go_infamous_button"):inside(x, y) and MenuCallbackHandler:can_become_infamous() and managers.money:get_infamous_cost(managers.experience:current_rank() + 1) <= managers.money:offshore() then
			self.scroll:set_input_focus(false)
			MenuCallbackHandler:become_infamous()

			return
		end

		if self.scroll:inside(x, y) then
			for index, item in ipairs(self.scroll:items()) do
				if item:inside(x, y) then
					self:unlock_infamy_item(item)

					return
				end
			end
		end
	end

	if button == Idstring("mouse wheel down") and self.scroll:inside(x, y) then
		self.scroll:perform_scroll(-60)
	elseif button == Idstring("mouse wheel up") and self.scroll:inside(x, y) then
		self.scroll:perform_scroll(60)
	end
end

function InfamyTreeGui:mouse_released(o, button, x, y)
	self.scroll:mouse_released(button, x, y)
end

function InfamyTreeGui:move_left()
	self.scroll:move_up()
end

function InfamyTreeGui:move_right()
	self.scroll:move_down()
end

function InfamyTreeGui:special_btn_pressed(button)
	if self._can_go_infamous and button == Idstring("menu_go_infamous") then
		MenuCallbackHandler:become_infamous()
	end

	return false
end

function InfamyTreeGui:confirm_pressed()
	local selected_item = self.scroll:selected_item()

	if selected_item then
		self:unlock_infamy_item(selected_item)
	end
end

function InfamyTreeGui:add_loading_animation(panel)
	local function animate_loading_texture(o)
		o:set_color(Color(0, 0, 1, 1))

		local time = coroutine.yield()
		local tw = o:texture_width()
		local th = o:texture_height()
		local old_alpha = 0
		local flip = false
		local delta, alpha = nil

		o:set_color(Color(1, 0, 1, 1))

		while true do
			delta = time % 2
			alpha = math.sin(delta * 90)

			o:set_color(Color(1, alpha, 1, 1))

			if flip and old_alpha < alpha then
				o:set_texture_rect(0, 0, tw, th)

				flip = false
			elseif not flip and alpha < old_alpha then
				o:set_texture_rect(tw, 0, -tw, th)

				flip = true
			end

			old_alpha = alpha
			time = time + coroutine.yield() * 2
		end
	end

	local bitmap = panel:bitmap({
		texture = "guis/textures/pd2/endscreen/exp_ring",
		name = "loading",
		h = 32,
		halign = "scale",
		w = 32,
		render_template = "VertexColorTexturedRadial",
		valign = "scale",
		color = Color(0.2, 1, 1)
	})

	bitmap:set_center(panel:w() / 2, panel:h() / 2)
	bitmap:animate(animate_loading_texture)
end

function InfamyTreeGui:_texture_done_clbk(params, texture_ids)
	if alive(params.panel) then
		params.panel:clear()
		params.panel:bitmap({
			texture = texture_ids,
			w = params.panel:w(),
			h = params.panel:h(),
			render_template = params.render_template
		})
	end

	repeat
		local found = nil

		for i, data in pairs(self._requested_textures) do
			if Idstring(data.texture) == texture_ids then
				managers.menu_component:unretrieve_texture(data.texture, data.texture_count)
				table.remove(self._requested_textures, i)

				found = true

				break
			end
		end
	until not found
end

function InfamyTreeGui:_flash_item(item)
	local text = item.panel:child("text")
	local image = item.panel:child("image")
	local border = item.border

	local function flash_anim()
		local color = tweak_data.screen_colors.item_stage_1
		local lerp_color = nil

		over(0.5, function (t)
			lerp_color = math.lerp(color, tweak_data.screen_colors.important_1, math.min(1, math.sin(t * 180) * 2))

			text:set_color(lerp_color)
			image:set_color(lerp_color)
			border:set_color(lerp_color)
		end)
		text:set_color(color)
		image:set_color(color)
		border:set_color(color)
	end

	managers.menu_component:post_event("menu_error")
	item.panel:stop()
	item.panel:animate(flash_anim)
end

function InfamyTreeGui:_update_description(name, unlocked)
	local desc_title = self._description_panel:child("description_title")
	local desc_text = self._description_panel:child("description_text")
	local desc_warning = self._description_panel:child("description_warning")
	local desc_upgrade = self._description_panel:child("description_upgrade")

	if desc_upgrade then
		for i, data in pairs(self._requested_textures) do
			managers.menu_component:unretrieve_texture(data.texture, data.texture_count)
		end

		self._requested_textures = {}

		self._description_panel:remove(desc_upgrade)
	end

	if name then
		local infamy_tweak = tweak_data.infamy.items[name]
		local params = deep_clone(infamy_tweak.desc_params)

		if infamy_tweak.upgrades and infamy_tweak.upgrades.infamous_lootdrop then
			local stars = managers.experience:level_to_stars()
			local item_pc = tweak_data.lootdrop.STARS[stars].pcs[1]
			local skip_types = {
				xp = true,
				cash = true
			}
			local droppable_items = managers.lootdrop:droppable_items(item_pc, true, skip_types)
			local items_total = 0
			local items_infamous = 0

			for type, items in pairs(droppable_items) do
				items_total = items_total + #items

				for _, item in pairs(items) do
					if item.global_value == "infamous" then
						items_infamous = items_infamous + 1
					end
				end
			end

			local _, infamous_base_chance, infamous_mod = managers.lootdrop:infamous_chance({
				disable_difficulty = true
			})
			local infamous_chance = items_total > 0 and infamous_base_chance * items_infamous / items_total or 0
			local mult = 10
			local base_text = math.floor(infamous_chance * 100 * mult + 0.5) / mult
			local buffed_text = base_text * infamy_tweak.upgrades.infamous_lootdrop
			params.base_chance = string.format("%.1f", base_text) .. "%"
			params.buffed_chance = string.format("%.1f", buffed_text) .. "%"
		end

		local title_text = utf8.to_upper(managers.localization:text(infamy_tweak.name_id))

		if infamy_tweak.add_tier then
			local index = table.get_key(tweak_data.infamy.tree, name) or 0

			if index > 0 then
				local tier = math.floor((index + 2) / InfamyTreeGui.tree_cols)
				title_text = managers.localization:to_upper_text("st_menu_tier", {
					tier = string.format("%02d", tier)
				}) .. ": " .. title_text
			end
		end

		desc_title:set_text(title_text)
		desc_warning:set_text(unlocked and "" or utf8.to_upper(managers.localization:text("menu_infamy_unlock_prev_tier")))
		desc_text:set_text(managers.localization:text(infamy_tweak.desc_id, params))
		managers.menu_component:add_colors_to_text_object(desc_text, tweak_data.screen_colors.resource)
	else
		desc_title:set_text(utf8.to_upper(managers.localization:text("st_menu_infamy_secret")))
		desc_warning:set_text("")
		desc_text:set_text(managers.localization:text("st_menu_infamy_secret_desc"))
	end

	local _, _, _, h = desc_title:text_rect()

	desc_title:set_size(self._description_panel:w() - 20, h)

	local _, _, _, h = desc_warning:text_rect()

	desc_warning:set_size(self._description_panel:w() - 20, h)
	desc_warning:set_top(desc_title:bottom() + (is_win_32 and 10 or 0))

	local _, _, _, h = desc_text:text_rect()

	desc_text:set_size(self._description_panel:w() - 20, h)
	desc_text:set_top(desc_warning:bottom() + (is_win_32 and 5 or 0))

	if name then
		desc_upgrade = self._description_panel:panel({
			name = "description_upgrade"
		})
		local infamy_tweak = tweak_data.infamy.items[name]
		local category_list = {
			texture = "textures",
			color = "colors",
			material = "materials",
			mask = "masks"
		}
		local icon_size = 64
		local y = desc_text:bottom() + (is_win_32 and 10 or 0)

		for bonus, item in ipairs(infamy_tweak.upgrades) do
			local global_value = item[1]
			local category = item[2]
			local item_id = item[3]
			local item_tweak_data = tweak_data.blackmarket[category][item_id]
			local guis_catalog = "guis/"
			local bundle_folder = item_tweak_data and item_tweak_data.texture_bundle_folder

			if bundle_folder then
				guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
			end

			if category == "colors" then
				desc_upgrade:bitmap({
					texture = "guis/textures/pd2/blackmarket/icons/colors/color_bg",
					x = 10,
					layer = 2,
					name = item_id .. "_color_bg",
					y = y,
					w = icon_size,
					h = icon_size
				})
				desc_upgrade:bitmap({
					texture = "guis/textures/pd2/blackmarket/icons/colors/color_02",
					x = 10,
					layer = 1,
					name = item_id .. "_color_1",
					y = y,
					w = icon_size,
					h = icon_size,
					color = tweak_data.blackmarket.colors[item_id].colors[1]
				})
				desc_upgrade:bitmap({
					texture = "guis/textures/pd2/blackmarket/icons/colors/color_01",
					x = 10,
					layer = 1,
					name = item_id .. "_color_2",
					y = y,
					w = icon_size,
					h = icon_size,
					color = tweak_data.blackmarket.colors[item_id].colors[2]
				})
			elseif category == "textures" then
				local icon_texture = tweak_data.blackmarket.textures[item_id].texture

				if DB:has(Idstring("texture"), icon_texture) then
					desc_upgrade:bitmap({
						stream = true,
						render_template = "VertexColorTexturedPatterns",
						x = 10,
						layer = 1,
						name = item_id .. "_image",
						y = y,
						w = icon_size,
						h = icon_size,
						texture = icon_texture
					})

					local panel = desc_upgrade:panel({
						x = 10,
						layer = 1,
						name = item_id .. "_image",
						y = y,
						w = icon_size,
						h = icon_size
					})
					local texture_count = managers.menu_component:request_texture(icon_texture, callback(self, self, "_texture_done_clbk", {
						render_template = "VertexColorTexturedPatterns",
						panel = panel
					}))

					table.insert(self._requested_textures, {
						texture_count = texture_count,
						texture = icon_texture
					})
				end
			else
				local icon_texture = guis_catalog .. "textures/pd2/blackmarket/icons/" .. category .. "/" .. item_id

				if DB:has(Idstring("texture"), icon_texture) then
					if category == "materials" then
						local panel = desc_upgrade:panel({
							x = 10,
							layer = 1,
							name = item_id .. "_image",
							y = y,
							w = icon_size,
							h = icon_size
						})
						local texture_count = managers.menu_component:request_texture(icon_texture, callback(self, self, "_texture_done_clbk", {
							panel = panel
						}))

						table.insert(self._requested_textures, {
							texture_count = texture_count,
							texture = icon_texture
						})
					else
						desc_upgrade:bitmap({
							x = 10,
							layer = 1,
							name = item_id .. "_image",
							y = y,
							w = icon_size,
							h = icon_size,
							texture = icon_texture
						})
					end
				end
			end

			local icon_text = desc_upgrade:text({
				wrap = false,
				word_wrap = false,
				vertical = "center",
				layer = 1,
				name = item_id .. "_text",
				x = icon_size + 20,
				y = y,
				h = icon_size,
				font = tweak_data.menu.pd2_medium_font,
				font_size = tweak_data.menu.pd2_medium_font_size
			})

			icon_text:set_text(managers.localization:text(item_tweak_data.name_id))

			y = y + icon_size
		end
	end
end

function InfamyTreeGui:_unlock_item(index)
	if not self._tree_items[index] then
		return
	end

	if not self._tree_items[index].unlocked then
		self:_flash_item(self._tree_items[index])

		return
	end

	if self._tree_items[index].owned then
		return
	end

	local infamy_name = tweak_data.infamy.tree[index]

	if managers.infamy:required_points(infamy_name) then
		local params = {
			text_string = "dialog_unlock_infamyitem",
			infamy_item = managers.localization:to_upper_text(tweak_data.infamy.items[infamy_name].name_id),
			points = Application:digest_value(tweak_data.infamy.items[infamy_name].cost, false),
			remaining_points = managers.infamy:points(),
			yes_func = callback(self, self, "_dialog_confirm_yes", index)
		}

		managers.menu:show_confirm_infamypoints(params)
	else
		self:_flash_item(self._tree_items[index])
	end
end

function InfamyTreeGui:_select_item(index)
	if type(index) == "string" then
		for i, name in ipairs(tweak_data.infamy.tree) do
			if name == index then
				index = i

				break
			end
		end
	end

	if self._selected_item ~= index then
		if self._selected_item then
			local selected_item = self._tree_items[self._selected_item]

			selected_item.panel:stop()
			selected_item.border:create_sides(selected_item.panel, {
				sides = {
					0,
					0,
					0,
					0
				}
			})
			selected_item.panel:child("image"):set_color(self._tree_items[self._selected_item].owned and tweak_data.screen_colors.item_stage_1 or self._tree_items[self._selected_item].unlocked and tweak_data.screen_colors.item_stage_2 or tweak_data.screen_colors.item_stage_3)
			selected_item.panel:child("text"):set_text("")
			selected_item.panel:child("text"):set_alpha(0)
		end

		self._selected_item = index
		local infamy_name = tweak_data.infamy.tree[index]
		local item = self._tree_items[index]
		local text = infamy_name and (item.owned and "st_menu_skill_owned" or item.unlocked and "st_menu_point" or "st_menu_skill_locked") or "st_menu_infamy_secret"

		item.panel:child("text"):set_text(utf8.to_upper(managers.localization:text(text, {
			points = infamy_name and Application:digest_value(tweak_data.infamy.items[infamy_name].cost, false) or 0
		})))
		item.panel:child("text"):set_color(tweak_data.screen_colors.text)
		item.panel:child("text"):set_alpha(0)
		item.panel:child("image"):set_color(tweak_data.screen_colors.item_stage_1)
		item.border:create_sides(item.panel, {
			sides = {
				0,
				0,
				0,
				0
			}
		})
		self:_update_description(infamy_name, item.unlocked)
	end
end

function InfamyTreeGui:_dialog_confirm_yes(index)
	local infamy_item = self._tree_items[index]
	local infamy_name = tweak_data.infamy.tree[index]

	managers.infamy:unlock_item(infamy_name)

	infamy_item.owned = true

	infamy_item.panel:child("image"):set_color(tweak_data.screen_colors.item_stage_1)
	managers.menu_component:post_event("menu_skill_investment")
	SimpleGUIEffectSpewer.infamous_up(infamy_item.panel:child("image"):center_x(), infamy_item.panel:child("image"):center_y(), infamy_item.panel)
	self._panel:child("points"):set_text(utf8.to_upper(managers.localization:text("st_menu_infamy_available_points", {
		points = managers.infamy:points()
	})))

	if self._selected_item == index then
		infamy_item.panel:child("text"):set_text(utf8.to_upper(managers.localization:text("st_menu_skill_owned")))
	end

	self:reload()
end

function InfamyTreeGui:reload()
	local tree_rows = tweak_data.infamy.tree_rows or 3
	local tree_cols = tweak_data.infamy.tree_cols or 3
	local neighbour_non_alpha = 0.55

	for index, item in pairs(self._tree_items) do
		item.unlocked = managers.infamy:available(tweak_data.infamy.tree[index])

		item.panel:child("image"):set_color(item.owned and tweak_data.screen_colors.item_stage_1 or item.unlocked and tweak_data.screen_colors.item_stage_2 or tweak_data.screen_colors.item_stage_3)

		item.select_size = item.owned and self._owned_selected_size or item.unlocked and self._unlocked_selected_size or self._locked_selected_size
		item.unselect_size = item.owned and self._owned_unselected_size or item.unlocked and self._unlocked_unselected_size or self._locked_unselected_size

		if item.neighbour_left then
			local neighbour_left = index - 1

			if self._tree_items[neighbour_left] then
				item.neighbour_left[1]:set_image(item.owned and "guis/dlcs/infamous/textures/pd2/infamous_tree/connector_df" or "guis/dlcs/infamous/textures/pd2/infamous_tree/connector_2_df")
				item.neighbour_left[2]:set_image(self._tree_items[neighbour_left].owned and "guis/dlcs/infamous/textures/pd2/infamous_tree/connector_df" or "guis/dlcs/infamous/textures/pd2/infamous_tree/connector_2_df")
				item.neighbour_left[1]:set_texture_coordinates(Vector3(0 + item.fw, 0, 0), Vector3(item.panel:width() + item.fw, 0, 0), Vector3(0 + item.fw, 16, 0), Vector3(item.panel:width() + item.fw, 16, 0))
				item.neighbour_left[2]:set_texture_coordinates(Vector3(0 - item.fw, 0, 0), Vector3(item.panel:width() - item.fw, 0, 0), Vector3(0 - item.fw, 16, 0), Vector3(item.panel:width() - item.fw, 16, 0))
				item.neighbour_left[1]:set_alpha((item.owned and 1 or item.unlocked and 0.7 or 0.1) * (self._tree_items[neighbour_left].owned and 1 or 0.5))
				item.neighbour_left[2]:set_alpha((self._tree_items[neighbour_left].owned and 1 or self._tree_items[neighbour_left].unlocked and 0.7 or 0.1) * (item.owned and 1 or 0.5))
			end
		end

		if item.neighbour_top then
			local neighbour_top = index - tree_cols

			if self._tree_items[neighbour_top] then
				item.neighbour_top[1]:set_image(item.owned and "guis/dlcs/infamous/textures/pd2/infamous_tree/connector_df" or "guis/dlcs/infamous/textures/pd2/infamous_tree/connector_2_df")
				item.neighbour_top[2]:set_image(self._tree_items[neighbour_top].owned and "guis/dlcs/infamous/textures/pd2/infamous_tree/connector_df" or "guis/dlcs/infamous/textures/pd2/infamous_tree/connector_2_df")
				item.neighbour_top[1]:set_texture_coordinates(Vector3(0 + item.fh, 16, 0), Vector3(0 + item.fh, 0, 0), Vector3(item.panel:height() + item.fh, 16, 0), Vector3(item.panel:height() + item.fh, 0, 0))
				item.neighbour_top[2]:set_texture_coordinates(Vector3(0 - item.fh, 16, 0), Vector3(0 - item.fh, 0, 0), Vector3(item.panel:height() - item.fh, 16, 0), Vector3(item.panel:height() - item.fh, 0, 0))
				item.neighbour_top[1]:set_alpha((item.owned and 1 or item.unlocked and 0.7 or 0.1) * (self._tree_items[neighbour_top].owned and 1 or 0.6))
				item.neighbour_top[2]:set_alpha((self._tree_items[neighbour_top].owned and 1 or self._tree_items[neighbour_top].unlocked and 0.7 or 0.1) * (item.owned and 1 or 0.6))
			end
		end

		if alive(item.panel:child("unlock_glow")) then
			item.panel:child("unlock_glow"):set_visible(item.owned)

			item.glow_alpha = item.owned and 1 or item.unlocked and 0.25 or 0.25
		end
	end

	local selected_item = self._tree_items[self._selected_item]

	if selected_item then
		local infamy_name = tweak_data.infamy.tree[self._selected_item]

		self:_update_description(infamy_name, selected_item.unlocked)
	end
end

function InfamyTreeGui:set_layer(layer)
	self._panel:set_layer(self._init_layer + layer)
end
