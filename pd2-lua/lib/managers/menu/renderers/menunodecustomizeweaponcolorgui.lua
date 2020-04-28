core:import("CoreMenuItemOption")
require("lib/managers/menu/MenuInitiatorBase")
require("lib/managers/menu/renderers/MenuNodeBaseGui")

local massive_font = tweak_data.menu.pd2_massive_font
local large_font = tweak_data.menu.pd2_large_font
local medium_font = tweak_data.menu.pd2_medium_font
local small_font = tweak_data.menu.pd2_small_font
local tiny_font = tweak_data.menu.pd2_tiny_font
local massive_font_size = tweak_data.menu.pd2_massive_font_size
local large_font_size = tweak_data.menu.pd2_large_font_size
local medium_font_size = tweak_data.menu.pd2_medium_font_size
local small_font_size = tweak_data.menu.pd2_small_font_size
local tiny_font_size = tweak_data.menu.pd2_tiny_font_size
MenuCustomizeWeaponColorInitiator = MenuCustomizeWeaponColorInitiator or class(MenuInitiatorBase)

function MenuCustomizeWeaponColorInitiator:modify_node(original_node, node_data)
	local node = original_node

	return self:setup_node(node, node_data)
end

function MenuCustomizeWeaponColorInitiator:setup_node(node, node_data)
	node:clean_items()

	node.topic_id = node_data.topic_id
	node.topic_params = node_data.topic_params
	local weapon_color_data = {}
	node.weapon_color_data = weapon_color_data
	local crafted = managers.blackmarket:get_crafted_category_slot(node_data.category, node_data.slot)

	if not crafted or not crafted.cosmetics then
		return node
	end

	local weapon_color_id = crafted.cosmetics.id or node_data.name
	local weapon_color_quality = crafted.cosmetics.quality or node_data.cosmetic_quality
	local weapon_color_index = crafted.cosmetics.color_index or node_data.cosmetic_index
	weapon_color_data.category = node_data.category
	weapon_color_data.slot = node_data.slot
	weapon_color_data.cosmetic_data = clone(crafted.cosmetics)
	local weapon_color_tweak_data = tweak_data.blackmarket.weapon_skins[weapon_color_id]
	local weapon_color_variation_template = tweak_data.blackmarket.weapon_color_templates.color_variation
	local color_group_data = {}
	node.color_group_data = color_group_data
	color_group_data.options = {}
	color_group_data.selected = 1
	color_group_data.highlighted = nil

	table.insert(color_group_data.options, {
		value = "all",
		text_id = "menu_weapon_color_group_all"
	})

	local global_value_data = nil

	for index, id in ipairs(tweak_data.blackmarket.weapon_color_groups) do
		global_value_data = tweak_data.lootdrop.global_value_category[id] or tweak_data.lootdrop.global_values[id] or tweak_data.lootdrop.global_value_category.normal

		if global_value_data then
			table.insert(color_group_data.options, {
				value = id,
				text_id = global_value_data.name_id
			})
		end
	end

	if not node:item("divider_end") then
		local guis_catalog, bundle_folder, color_tweak, unlocked, have_color, dlc, global_value = nil
		local colors_data = {}

		for index, id in ipairs(tweak_data.blackmarket.weapon_colors) do
			color_tweak = tweak_data.blackmarket.weapon_skins[id]
			guis_catalog = "guis/"
			bundle_folder = color_tweak.texture_bundle_folder

			if bundle_folder then
				guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
			end

			dlc = color_tweak.dlc or managers.dlc:global_value_to_dlc(color_tweak.global_value)
			global_value = color_tweak.global_value or managers.dlc:dlc_to_global_value(dlc)
			unlocked = not dlc or managers.dlc:is_dlc_unlocked(dlc)
			have_color = managers.blackmarket:has_item(global_value, "weapon_skins", id)

			table.insert(colors_data, {
				visible_callback = "is_weapon_color_option_visible",
				_meta = "option",
				disabled_icon_callback = "get_weapon_color_disabled_icon",
				enabled_callback = "is_weapon_color_option_unlocked",
				value = id,
				color = color_tweak.color,
				text_id = "bm_wskn_" .. id,
				unlocked = unlocked,
				have_color = have_color,
				texture = guis_catalog .. "textures/pd2/blackmarket/icons/weapon_color/" .. id
			})
		end

		local color_item = self:create_grid(node, colors_data, {
			callback = "refresh_node",
			name = "cosmetic_color",
			height_aspect = 0.85,
			text_id = "menu_weapon_color_title",
			align_line_proportions = 0,
			rows = 2.5,
			sort_callback = "sort_weapon_colors",
			columns = 20
		})

		color_item:set_value(weapon_color_id)
		self:create_divider(node, "padding", nil, 10)

		local variations_data = {}

		for index = 1, #weapon_color_variation_template, 1 do
			table.insert(variations_data, {
				_meta = "option",
				value = index,
				text_id = tweak_data.blackmarket:get_weapon_color_index_string(index)
			})
		end

		local variation_item = self:create_multichoice(node, variations_data, {
			callback = "refresh_node",
			name = "cosmetic_variation",
			text_id = "menu_weapon_color_index_title"
		})

		variation_item:set_value(weapon_color_index)

		local qualities = {}

		for id, data in pairs(tweak_data.economy.qualities) do
			table.insert(qualities, {
				localize = true,
				_meta = "option",
				value = id,
				text_id = data.name_id,
				index = data.index
			})
		end

		table.sort(qualities, function (x, y)
			return y.index < x.index
		end)

		local quality_item = self:create_multichoice(node, qualities, {
			callback = "refresh_node",
			name = "quality",
			text_id = "menu_weapon_color_quality"
		})

		quality_item:set_value(weapon_color_quality)
	end

	self:create_divider(node, "end", nil, 8)

	local new_item = nil
	local apply_params = {
		visible_callback = "should_show_weapon_color_apply",
		name = "apply",
		callback = "apply_weapon_color",
		text_id = "dialog_apply",
		align = "right"
	}
	new_item = node:create_item({}, apply_params)

	new_item:set_enabled(false)
	node:add_item(new_item)

	local buy_dlc_params = {
		visible_callback = "should_show_weapon_color_buy",
		name = "buy_dlc",
		callback = "buy_weapon_color_dlc",
		text_id = "menu_dlc_buy",
		align = "right"
	}
	new_item = node:create_item({}, buy_dlc_params)

	node:add_item(new_item)

	local back_params = {
		last_item = "true",
		name = "back",
		text_id = "menu_back",
		align = "right",
		previous_node = "true"
	}
	new_item = node:create_item({}, back_params)

	node:add_item(new_item)
	node:set_default_item_name("cosmetic_color")
	managers.blackmarket:view_weapon_with_cosmetics(weapon_color_data.category, weapon_color_data.slot, weapon_color_data.cosmetic_data, nil, nil, BlackMarketGui.get_crafting_custom_data())

	node.randomseed = os.time()

	math.randomseed(node.randomseed)

	return node
end

function MenuCustomizeWeaponColorInitiator:refresh_node(node)
	local cosmetic_color_item = node:item("cosmetic_color")

	cosmetic_color_item:visible()

	local weapon_color_data = node.weapon_color_data
	local cosmetic_data = weapon_color_data.cosmetic_data
	local cosmetic_color_item = node:item("cosmetic_color")
	local cosmetic_variation_item = node:item("cosmetic_variation")
	local quality_item = node:item("quality")
	local apply_item = node:item("apply")
	local color_id = cosmetic_color_item:value()
	local color_index = cosmetic_variation_item:value()
	local color_quality = quality_item:value()
	local color_tweak_data = tweak_data.blackmarket.weapon_skins[color_id]
	cosmetic_data.id = color_id
	cosmetic_data.color_index = color_index
	cosmetic_data.quality = color_quality
	local weapon_unit_data = managers.menu_scene and managers.menu_scene:get_item_unit_data()
	local weapon_unit = weapon_unit_data and weapon_unit_data.unit

	if alive(weapon_unit) then
		weapon_unit:base():change_cosmetics(cosmetic_data)
	end

	local second_unit = weapon_unit_data and weapon_unit_data.second_unit

	if alive(second_unit) then
		second_unit:base():change_cosmetics(cosmetic_data)
	end

	node.color_group_data.highlighted = nil
	local can_apply = MenuCallbackHandler:can_apply_weapon_color(node)

	apply_item:set_enabled(can_apply)
	math.randomseed(node.randomseed)

	return node
end

MenuNodeCustomizeWeaponColorGui = MenuNodeCustomizeWeaponColorGui or class(MenuNodeBaseGui)
MenuNodeCustomizeWeaponColorGui.CUSTOM_MOUSE_INPUT = true

function MenuNodeCustomizeWeaponColorGui:init(node, layer, parameters)
	parameters.font = tweak_data.menu.pd2_small_font
	parameters.font_size = tweak_data.menu.pd2_small_font_size
	parameters.align = "left"
	parameters.row_item_blend_mode = "add"
	parameters.row_item_color = tweak_data.screen_colors.button_stage_3
	parameters.row_item_hightlight_color = tweak_data.screen_colors.button_stage_2
	parameters.marker_alpha = 1
	parameters.to_upper = true

	MenuNodeCustomizeWeaponColorGui.super.init(self, node, layer, parameters)
end

function MenuNodeCustomizeWeaponColorGui:_setup_item_panel_parent(safe_rect, shape)
	shape = shape or {}
	shape.x = shape.x or safe_rect.x
	shape.y = shape.y or safe_rect.y + 0
	shape.w = shape.w or safe_rect.width
	shape.h = shape.h or safe_rect.height - 0

	MenuNodeCustomizeWeaponColorGui.super._setup_item_panel_parent(self, safe_rect, shape)
end

function MenuNodeCustomizeWeaponColorGui:setup(node)
	MenuNodeCustomizeWeaponColorGui.super.setup(self, node)
	self:update_color_info()
end

function MenuNodeCustomizeWeaponColorGui:_setup_item_panel(safe_rect, res)
	MenuNodeCustomizeWeaponColorGui.super._setup_item_panel(self, safe_rect, res)

	local align_padding = self._align_line_padding or 10
	local color_grid_row_item = self:row_item_by_name("cosmetic_color")
	local item_width = safe_rect.width * (1 - self._align_line_proportions)
	local color_grid_width = color_grid_row_item.gui_panel:width()

	self.item_panel:set_w(color_grid_width)
	self.item_panel:set_center_x(safe_rect.width / 2 + 4)
	self.item_panel:set_bottom(safe_rect.height - align_padding * 2 - (alive(self._legends_panel) and self._legends_panel:h() + align_padding or 0))

	local title_string = managers.localization:to_upper_text(self.node.topic_id, self.node.topic_params)
	self._text_panel = self._item_panel_parent:panel({
		name = "title_panel",
		layer = self.layers.background
	})

	self._text_panel:text({
		name = "title_text",
		layer = 1,
		text = title_string,
		font_size = tweak_data.menu.pd2_large_font_size,
		font = tweak_data.menu.pd2_large_font,
		color = tweak_data.screen_colors.text
	})
	self._text_panel:text({
		rotation = 360,
		name = "title_bg_text",
		alpha = 0.4,
		y = -13,
		x = -13,
		text = title_string,
		font_size = tweak_data.menu.pd2_massive_font_size,
		font = tweak_data.menu.pd2_massive_font,
		color = tweak_data.screen_colors.button_stage_3
	})

	self._tab_panel = self._item_panel_parent:panel({
		name = "tab_panel",
		layer = self.layers.items
	})
	self._tabs = {}
	local _, tw, th, tab_panel, tab_text, tab_select_rect = nil
	local color_group_data = self.node.color_group_data

	for index, option in ipairs(color_group_data.options) do
		tab_panel = self._tab_panel:panel()
		tab_select_rect = tab_panel:bitmap({
			texture = "guis/textures/pd2/shared_tab_box",
			halign = "grow",
			valign = "grow",
			w = tab_panel:w(),
			h = tab_panel:h()
		})
		tab_text = tab_panel:text({
			vertical = "center",
			halign = "grow",
			align = "center",
			layer = 1,
			valign = "grow",
			text = managers.localization:to_upper_text(option.text_id),
			font = medium_font,
			font_size = medium_font_size
		})
		_, _, tw, th = tab_text:text_rect()

		tab_panel:set_size(tw + 15, th + 10)
		tab_panel:set_leftbottom(#self._tabs > 0 and self._tabs[#self._tabs].panel:right() or self.item_panel:left(), self.item_panel:top() + 2 - align_padding)
		table.insert(self._tabs, {
			panel = tab_panel,
			text = tab_text,
			select_rect = tab_select_rect
		})
		self:_update_tab(index)
	end

	self:update_color_info()

	if alive(self.box_panel) then
		self._item_panel_parent:remove(self.box_panel)

		self.box_panel = nil
	end

	self.box_panel = self._item_panel_parent:panel({
		name = "box_panel",
		layer = self.layers.background
	})

	self.box_panel:set_shape(self.item_panel:shape())
	self.box_panel:grow(align_padding * 1, align_padding * 2)
	self.box_panel:move(-align_padding, -align_padding)

	self.boxgui = BoxGuiObject:new(self.box_panel, {
		layer = 1,
		sides = {
			1,
			1,
			2,
			1
		}
	})

	self.boxgui:set_clipping(false)
	self.box_panel:rect({
		alpha = 0.6,
		rotation = 360,
		layer = 0,
		color = Color.black
	})

	self.blur = self.box_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		render_template = "VertexColorTexturedBlur3D",
		w = self.box_panel:w(),
		h = self.box_panel:h()
	})
	local start_blur = self.start_blur or 0

	local function func(o)
		local blur = start_blur

		over(0.6, function (p)
			o:set_alpha(math.lerp(blur, 1, p))
		end)
	end

	self.blur:animate(func)
	self._align_data.panel:set_left(self.box_panel:left())
	self:_set_topic_position()
end

function MenuNodeCustomizeWeaponColorGui:_update_tab(index)
	local color_group_data = self.node.color_group_data
	local tab = self._tabs[index]

	if color_group_data.selected == index then
		tab.text:set_color(tweak_data.screen_colors.button_stage_1)
		tab.text:set_blend_mode("normal")
		tab.select_rect:show()
	elseif color_group_data.highlighted == index then
		tab.text:set_color(tweak_data.screen_colors.button_stage_2)
		tab.text:set_blend_mode("add")
		tab.select_rect:hide()
	else
		tab.text:set_color(tweak_data.screen_colors.button_stage_3)
		tab.text:set_blend_mode("add")
		tab.select_rect:hide()
	end
end

function MenuNodeCustomizeWeaponColorGui:_set_color_group_index(index)
	local color_group_data = self.node.color_group_data
	local new_index = math.clamp(index, 1, #color_group_data.options)

	if new_index ~= color_group_data.selected then
		color_group_data.selected = new_index

		managers.menu:active_menu().logic:refresh_node()
	end
end

function MenuNodeCustomizeWeaponColorGui:input_focus()
	if self._mouse_over_row_item then
		local current_item = managers.menu:active_menu().logic:selected_item()
		local mouse_over_item = self._mouse_over_row_item.item

		if current_item == mouse_over_item and mouse_over_item.TYPE == "grid" then
			return 1
		end
	end
end

function MenuNodeCustomizeWeaponColorGui:mouse_moved(o, x, y)
	local used = false
	local icon = "arrow"

	if managers.menu_scene:input_focus() then
		self._mouse_over_row_item = nil

		return used, icon
	end

	local current_item = managers.menu:active_menu().logic:selected_item()
	local current_row_item = current_item and self:row_item(current_item)
	local selected_row_item = nil

	if current_row_item and current_row_item.gui_panel and current_row_item.gui_panel:inside(x, y) then
		selected_row_item = current_row_item
	else
		local inside_item_panel_parent = self:item_panel_parent():inside(x, y)
		local item, is_inside = nil

		for _, row_item in pairs(self.row_items) do
			item = row_item.item
			is_inside = false

			if item and not item.no_mouse_select then
				is_inside = item.TYPE == "grid" and item:scroll_bar_grabbed(row_item) and true or inside_item_panel_parent and row_item.gui_panel:inside(x, y)
			end

			if is_inside then
				selected_row_item = row_item

				break
			end
		end
	end

	if selected_row_item then
		local selected_name = selected_row_item.name
		used = true
		icon = "link"

		if not current_item or selected_name ~= current_item:name() then
			managers.menu:active_menu().logic:mouse_over_select_item(selected_name, false)

			current_row_item = selected_row_item
			current_item = selected_row_item.item
		end

		if current_item then
			self._mouse_over_row_item = current_row_item

			if current_item.TYPE == "grid" then
				icon = current_item:mouse_moved(x, y, current_row_item)
			elseif current_item.TYPE == "multi_choice" then
				local inside_arrow_left = current_row_item.arrow_left:visible() and current_row_item.arrow_left:inside(x, y)
				local inside_arrow_right = current_row_item.arrow_right:visible() and current_row_item.arrow_right:inside(x, y)
				local inside_gui_text = current_row_item.arrow_left:visible() and current_row_item.arrow_right:visible() and current_row_item.gui_text:inside(x, y)
				local inside_choice_panel = current_row_item.choice_panel:visible() and current_row_item.choice_panel:inside(x, y)

				if inside_arrow_left or inside_arrow_right or inside_gui_text or inside_choice_panel then
					icon = "link"
				else
					icon = "arrow"
				end
			end
		end
	else
		self._mouse_over_row_item = nil
	end

	local color_group_data = self.node.color_group_data

	if color_group_data.highlighted then
		local highlighted_tab = self._tabs[color_group_data.highlighted]

		if highlighted_tab.panel:inside(x, y) then
			return true, color_group_data.highlighted == color_group_data.selected and "arrow" or "link"
		end

		local prev_highlighted = color_group_data.highlighted
		color_group_data.highlighted = nil

		self:_update_tab(prev_highlighted)
	end

	for index, tab in ipairs(self._tabs) do
		if tab.panel:inside(x, y) then
			color_group_data.highlighted = index

			self:_update_tab(index)

			used = true
			icon = "link"

			if color_group_data.selected ~= index then
				icon = "arrow"

				managers.menu_component:post_event("highlight")
			end
		end
	end

	return used, icon
end

function MenuNodeCustomizeWeaponColorGui:mouse_pressed(button, x, y)
	local active_menu = managers.menu:active_menu()

	if not managers.menu:active_menu() then
		return
	end

	local logic = active_menu.logic
	local input = active_menu.input

	if self._mouse_over_row_item then
		local mouse_over_item = self._mouse_over_row_item.item

		if button == Idstring("mouse wheel down") then
			if mouse_over_item.TYPE == "grid" then
				return mouse_over_item:wheel_scroll_start(-1, self._mouse_over_row_item)
			end
		elseif button == Idstring("mouse wheel up") and mouse_over_item.TYPE == "grid" then
			return mouse_over_item:wheel_scroll_start(1, self._mouse_over_row_item)
		end

		if button == Idstring("0") then
			if mouse_over_item.TYPE == "grid" then
				mouse_over_item:mouse_pressed(button, x, y, self._mouse_over_row_item)
			elseif mouse_over_item.TYPE == "multi_choice" then
				if self._mouse_over_row_item.arrow_right:inside(x, y) then
					if mouse_over_item:next() then
						input:post_event("selection_next")
						logic:trigger_item(true, mouse_over_item)
					end
				elseif self._mouse_over_row_item.arrow_left:inside(x, y) then
					if mouse_over_item:previous() then
						input:post_event("selection_previous")
						logic:trigger_item(true, mouse_over_item)
					end
				elseif self._mouse_over_row_item.gui_text:inside(x, y) then
					if self._mouse_over_row_item.align == "left" then
						if mouse_over_item:previous() then
							input:post_event("selection_previous")
							logic:trigger_item(true, mouse_over_item)
						end
					elseif mouse_over_item:next() then
						input:post_event("selection_next")
						logic:trigger_item(true, mouse_over_item)
					end
				elseif self._mouse_over_row_item.choice_panel:inside(x, y) and mouse_over_item:enabled() then
					mouse_over_item:popup_choice(self._mouse_over_row_item)
					input:post_event("selection_next")
					logic:trigger_item(true, mouse_over_item)
				end
			elseif mouse_over_item.TYPE == "divider" then
				-- Nothing
			else
				local item = logic:selected_item()

				if item then
					input._item_input_action_map[item.TYPE](item, input._controller, true)
				end
			end

			return true
		end
	end

	if button == Idstring("0") then
		local color_group_data = self.node.color_group_data
		local highlighted_tab = self._tabs[color_group_data.highlighted]

		if highlighted_tab and highlighted_tab.panel:inside(x, y) then
			self:_set_color_group_index(color_group_data.highlighted)

			return true
		end
	end
end

function MenuNodeCustomizeWeaponColorGui:mouse_released(button, x, y)
	local item = nil

	for _, row_item in pairs(self.row_items) do
		item = row_item.item

		if item.TYPE == "grid" then
			row_item.item:mouse_released(button, x, y, row_item)
		end
	end
end

function MenuNodeCustomizeWeaponColorGui:previous_page()
	local color_group_data = self.node.color_group_data

	self:_set_color_group_index(color_group_data.selected - 1)
end

function MenuNodeCustomizeWeaponColorGui:next_page()
	local color_group_data = self.node.color_group_data

	self:_set_color_group_index(color_group_data.selected + 1)
end

function MenuNodeCustomizeWeaponColorGui:_set_info_shape()
	local top_align_row_item = self:row_item_by_name("cosmetic_variation")
	local left = self.item_panel:world_left()
	local top = top_align_row_item.gui_panel:world_top()
	local width = self.item_panel:width() - top_align_row_item.gui_panel:width() - self._align_line_padding * 2
	local height = self.item_panel:height() - top_align_row_item.gui_panel:top() + self._align_line_padding * 0

	self._info_bg_rect:set_world_position(left, top)
	self._info_bg_rect:set_size(width, height)

	local mini_info = self._mini_info_text:parent()
	local mini_text = self._mini_info_text

	mini_info:set_shape(self._info_bg_rect:shape())
	mini_text:set_shape(self._align_line_padding, self._align_line_padding, mini_info:w() - self._align_line_padding * 2, mini_info:h() - self._align_line_padding * 2)

	if self.info_box_gui then
		self.info_box_gui:close()

		self.info_box_gui = nil
	end

	self.info_box_gui = BoxGuiObject:new(mini_info, {
		sides = {
			1,
			1,
			1,
			1
		},
		layer = self.layers.background + 1
	})

	if self.item_box_gui then
		self.item_box_gui:close()

		self.item_box_gui = nil
	end

	if self.item_box_panel then
		self.item_box_panel:parent():remove(self.item_box_panel)
	end

	self.item_box_panel = self.safe_rect_panel:panel({
		x = mini_info:right() + self._align_line_padding,
		y = mini_info:top(),
		w = top_align_row_item.gui_panel:width() + self._align_line_padding * 2,
		h = mini_info:h()
	})
	self.item_box_gui = BoxGuiObject:new(self.item_box_panel, {
		sides = {
			0,
			0,
			0,
			0
		},
		layer = self.layers.background + 1
	})

	MenuNodeBaseGui.rec_round_object(mini_text)
end

function MenuNodeCustomizeWeaponColorGui:_set_item_positions()
	MenuNodeCustomizeWeaponColorGui.super._set_item_positions(self)
	self:_set_info_shape()
end

function MenuNodeCustomizeWeaponColorGui:resolution_changed()
	MenuNodeCustomizeWeaponColorGui.super.resolution_changed(self)
	self:_set_info_shape()
end

function MenuNodeCustomizeWeaponColorGui:update_color_info(node)
	node = node or self.node

	if not node then
		return
	end

	local data = node.weapon_color_data

	if not data or not data.cosmetic_data then
		return
	end

	local info_string = ""
	local color_range = {}

	local function _add_string(new_string, color, separator)
		separator = separator or ""
		local s = utf8.len(info_string) + 1
		info_string = info_string .. separator .. new_string

		if color then
			local e = utf8.len(info_string)

			table.insert(color_range, {
				s,
				e,
				color
			})
		end
	end

	local color_id = data.cosmetic_data.id
	local color_tweak = tweak_data.blackmarket.weapon_skins[color_id]
	local name_id = color_tweak.name_id
	local desc_id = color_tweak.desc_id
	local unlock_id = nil
	local dlc = color_tweak.dlc or managers.dlc:global_value_to_dlc(color_tweak.global_value)
	local global_value = color_tweak.global_value or managers.dlc:dlc_to_global_value(dlc)
	local gvalue_tweak = tweak_data.lootdrop.global_values[global_value]
	local cosmetic_color_item = node:item("cosmetic_color")
	local color_item_option = cosmetic_color_item:get_option(color_id)
	local unlocked = color_item_option:get_parameter("unlocked")
	local have_color = color_item_option:get_parameter("have_color")

	if not unlocked then
		unlock_id = gvalue_tweak and gvalue_tweak.unlock_id or "bm_menu_dlc_locked"
	elseif not have_color then
		local achievement_locked_content = managers.dlc:weapon_color_achievement_locked_content(color_id)
		local dlc_tweak = tweak_data.dlc[achievement_locked_content]
		local achievement = dlc_tweak and dlc_tweak.achievement_id

		if achievement and managers.achievment:get_info(achievement) then
			local achievement_visual = tweak_data.achievement.visual[achievement]
			unlock_id = achievement_visual and achievement_visual.desc_id or "achievement_" .. tostring(achievement) .. "_desc" or "bm_menu_dlc_locked"
		elseif managers.dlc:is_content_skirmish_locked("weapon_skins", color_id) then
			unlock_id = "bm_menu_skirmish_content_reward"
		else
			unlock_id = "bm_menu_dlc_locked"
		end
	end

	if name_id then
		_add_string(managers.localization:to_upper_text(name_id), nil, "")
	end

	if gvalue_tweak and gvalue_tweak.desc_id then
		_add_string(managers.localization:to_upper_text(gvalue_tweak.desc_id), gvalue_tweak.color, "\n")
	end

	if unlock_id then
		_add_string(managers.localization:to_upper_text(unlock_id), tweak_data.screen_colors.important_1, "\n")
	end

	self:set_mini_info_with_color_range(info_string, color_range)
end

function MenuNodeGui:set_mini_info_with_color_range(text, color_range)
	self._mini_info_text:set_text(text)
	self._mini_info_text:clear_range_color(0, utf8.len(self._mini_info_text:text()))

	for _, data in ipairs(color_range) do
		self._mini_info_text:set_range_color(unpack(data))
	end
end

function MenuNodeCustomizeWeaponColorGui:_clear_gui()
	if alive(self.blur) then
		self.start_blur = self.blur:alpha()
	end

	MenuNodeCustomizeWeaponColorGui.super._clear_gui(self)

	self._mouse_over_row_item = nil

	self._item_panel_parent:remove(self._text_panel)

	self._text_panel = nil

	self._item_panel_parent:remove(self._tab_panel)

	self._tab_panel = nil
end

function MenuNodeCustomizeWeaponColorGui:_setup_item_rows(node)
	MenuNodeCustomizeWeaponColorGui.super._setup_item_rows(self, node)
end

function MenuNodeCustomizeWeaponColorGui:reload_item(item)
	MenuNodeCustomizeWeaponColorGui.super.reload_item(self, item)

	local row_item = self:row_item(item)

	if row_item and alive(row_item.gui_panel) and (not item.align_panel or not item:align_panel(row_item, self.item_panel)) then
		row_item.gui_panel:set_halign("right")
		row_item.gui_panel:set_right(self.item_panel:w() - self._align_line_padding)
	end
end

function MenuNodeCustomizeWeaponColorGui:_align_marker(row_item)
	MenuNodeCustomizeWeaponColorGui.super._align_marker(self, row_item)
	self._marker_data.marker:set_world_right(self.item_panel:world_right() - self._align_line_padding)
end

function MenuNodeCustomizeWeaponColorGui:close()
	for _, row_item in ipairs(self.row_items) do
		if row_item.item and type(row_item.item.close) == "function" then
			row_item.item:close(row_item)
		end
	end

	math.randomseed(os.time())
	MenuNodeCustomizeWeaponColorGui.super.close(self)
end
