core:import("CoreMenuItemOption")
require("lib/managers/menu/renderers/MenuNodeBaseGui")
require("lib/managers/menu/MenuInitiatorBase")
require("lib/managers/menu/ExtendedUiElemets")
require("lib/managers/menu/WalletGuiObject")
require("lib/managers/menu/SearchBoxGuiObject")

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
MenuHintArchiveInitiator = MenuHintArchiveInitiator or class(MenuInitiatorBase)

function MenuHintArchiveInitiator:modify_node(original_node, node_data)
	return original_node
end

function MenuHintArchiveInitiator:refresh_node(original_node)
	return original_node
end

HintListItem = HintListItem or class(ListItem)
HintListItem.HEIGHT = 70
HintListItem.ND_COLOR = Color(255, 95, 95, 95) / 255
HintListItem.NT_SD_COLOR = tweak_data.screen_colors.achievement_grey
HintListItem.ST_COLOR = Color.white

function HintListItem:init(parent, data)
	HintListItem.super.init(self, parent, {
		input = false,
		h = self.HEIGHT,
		w = parent:row_w()
	})

	self.my_data = data
	self._select_panel = self._panel:panel({
		layer = self:layer() - 1
	})

	BoxGuiObject:new(self._select_panel, {
		sides = {
			2,
			2,
			2,
			2
		}
	})

	self._backlight = self._panel:rect({
		color = Color(125, 0, 0, 0) / 255,
		layer = self:layer() - 1,
		visible = data.backlight
	})
	self._highlight = self._panel:rect({
		visible = false,
		color = Color(40, 30, 105, 150) / 255,
		layer = self:layer() - 1
	})
	self._requested_textures = {}
	local icon_texture = "guis/textures/loading/hints/" .. data.image
	local texture_count = managers.menu_component:request_texture(icon_texture, callback(self, self, "_texture_done_clbk", {
		blend_mode = "add",
		panel = self._panel
	}))

	table.insert(self._requested_textures, {
		texture_count = texture_count,
		texture = icon_texture
	})

	local left = self:w() - 32 - 16
	left = left - 6
	self._click = self:panel()

	self._click:set_w(left - 10)

	local title_str = tostring(data.index) .. "/" .. tostring(data.total_tips_amount)
	self._title = self:fine_text({
		y = 5,
		text = title_str,
		font = medium_font,
		font_size = medium_font_size,
		color = self.NT_SD_COLOR,
		x = self.HEIGHT
	})
	local desc_str = managers.localization:text(data.text_id)
	self._desc = self:text({
		wrap = true,
		word_wrap = true,
		text = desc_str,
		font = tiny_font,
		font_size = tiny_font_size,
		color = self.ND_COLOR,
		x = self._title:x(),
		y = self._title:bottom() + 2,
		w = left - 170
	})

	self:_selected_changed(false)
end

function HintListItem:_selected_changed(state)
	self._title:set_color(state and self.ST_COLOR or self.NT_SD_COLOR)
	self._desc:set_color(state and self.NT_SD_COLOR or self.ND_COLOR)
	self._highlight:set_visible(state)
	self._select_panel:set_visible(state)
end

function HintListItem:is_inside(x, y)
	return self._highlight:inside(x, y)
end

function HintListItem:mouse_moved(o, x, y)
	local is_inside = self:is_inside(x, y)

	self._highlight:set_visible(is_inside)

	if is_inside then
		return true
	end

	HintListItem.super.mouse_moved(self, o, x, y)
end

function HintListItem:_texture_done_clbk(params, texture_ids)
	if alive(params.panel) then
		local bitmap = params.panel:bitmap({
			w = 50,
			h = 50,
			texture = texture_ids,
			blend_mode = params.blend_mode
		})

		bitmap:set_center(self.HEIGHT / 2, self.HEIGHT / 2)
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

MenuNodeHintArchiveGui = MenuNodeHintArchiveGui or class(MenuNodeBaseGui)

function MenuNodeHintArchiveGui:init(node, layer, parameters)
	parameters.font = small_font
	parameters.font_size = small_font_size
	parameters.align = "left"
	parameters.halign = "center"
	parameters.row_item_blend_mode = "add"
	parameters.row_item_color = tweak_data.screen_colors.button_stage_3
	parameters.row_item_hightlight_color = tweak_data.screen_colors.button_stage_2
	parameters.marker_alpha = 1
	parameters.to_upper = true

	MenuNodeHintArchiveGui.super.init(self, node, layer, parameters)
end

function MenuNodeHintArchiveGui:_setup_item_panel_parent(safe_rect, shape)
	shape = shape or {}
	shape.x = shape.x or safe_rect.x
	shape.y = shape.y or safe_rect.y + 0
	shape.w = shape.w or safe_rect.width
	shape.h = shape.h or safe_rect.height - 0

	MenuNodeHintArchiveGui.super._setup_item_panel_parent(self, safe_rect, shape)
end

function MenuNodeHintArchiveGui:_setup_item_panel(safe_rect, res)
	MenuNodeHintArchiveGui.super._setup_item_panel(self, safe_rect, res)
	WalletGuiObject.set_wallet(self._item_panel_parent)

	self._text_panel = self._item_panel_parent:panel({
		name = "title_panel",
		layer = self.layers.background
	})

	self._text_panel:text({
		name = "title_text",
		layer = 1,
		text = managers.localization:to_upper_text("menu_hintarchive_title"),
		font_size = large_font_size,
		font = large_font,
		color = tweak_data.screen_colors.text
	})
	self._text_panel:text({
		rotation = 360,
		name = "title_bg_text",
		alpha = 0.4,
		y = -13,
		x = -13,
		text = managers.localization:to_upper_text("menu_hintarchive_title"),
		font_size = massive_font_size,
		font = massive_font,
		color = tweak_data.screen_colors.button_stage_3
	})

	local t_y = 50
	self._scroll = ScrollItemList:new(self._item_panel_parent, {
		scrollbar_padding = 0,
		w = 840,
		bar_minimum_size = 16,
		padding = 0,
		y = t_y,
		h = self.safe_rect_panel:h() - t_y - 50
	}, {
		padding = 0
	})

	self._scroll:add_lines_and_static_down_indicator()

	self._tips_data = {}
	local all_tips = tweak_data.tips:get_all_tips()

	for i, tip in ipairs(all_tips) do
		local data = {
			index = i,
			total_tips_amount = #all_tips,
			backlight = i % 2 == 0,
			image = tip.image,
			title_id = tip.title_id,
			text_id = tip.text_id
		}
		local item = HintListItem:new(self._scroll:canvas(), data)

		self._scroll:add_item(item)
		table.insert(self._tips_data, data)
	end

	self._detail_panel = self._item_panel_parent:panel({
		x = self._scroll:right(),
		y = self._scroll:top(),
		w = self.safe_rect_panel:w() - self._scroll:w(),
		h = self._scroll:h()
	})

	self._detail_panel:rect({
		visible = true,
		layer = self.layer,
		color = Color.black:with_alpha(0.8)
	})
	BoxGuiObject:new(self._detail_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	self._item_panel_parent:text({
		name = "title_text",
		layer = 1,
		text = managers.localization:to_upper_text("menu_hintarchive_item_panel_title"),
		x = self._detail_panel:left(),
		y = self._detail_panel:top() - medium_font_size,
		font_size = medium_font_size,
		font = medium_font,
		color = tweak_data.screen_colors.text
	})

	self._detail_panel_content = self._detail_panel:panel()

	self:_setup_detail_box_info(self._tips_data[1])

	if managers.menu:is_pc_controller() then
		self._searchbox = SearchBoxGuiObject:new(self._item_panel_parent, self.ws)

		self._searchbox.panel:set_right(self._scroll:right() - 25)
		self._searchbox.panel:set_top(self._scroll:bottom() + 10)

		local string_table = {}

		for _, tip in ipairs(self._tips_data) do
			table.insert(string_table, {
				tip.title_id,
				tip.text_id
			})
		end

		self._searchbox:register_list(string_table)
		self._searchbox:register_callback(callback(self, self, "search_callback"))

		local back_button = self._item_panel_parent:text({
			name = "back_button",
			blend_mode = "add",
			text = managers.localization:to_upper_text("menu_back"),
			font = large_font,
			font_size = large_font_size,
			color = tweak_data.screen_colors.button_stage_3
		})

		self.make_fine_text(back_button)
		back_button:set_right(self._item_panel_parent:w())
		back_button:set_bottom(self._item_panel_parent:h())

		local bg_back = self._item_panel_parent:text({
			name = "TitleTextBg",
			vertical = "top",
			h = 90,
			alpha = 0.4,
			align = "right",
			blend_mode = "add",
			layer = 1,
			text = back_button:text(),
			font = massive_font,
			font_size = massive_font_size,
			color = tweak_data.screen_colors.button_stage_3
		})
		local x, y = managers.gui_data:safe_to_full_16_9(back_button:world_right(), back_button:world_center_y())

		bg_back:set_world_right(x)
		bg_back:set_world_center_y(y)
		bg_back:move(13, 0)
		MenuBackdropGUI.animate_bg_text(self, bg_back)
	end
end

function MenuNodeHintArchiveGui:setup(node)
	MenuNodeHintArchiveGui.super.setup(self, node)
	self._scroll:set_input_focus(true)
	self._scroll:select_index(1)
end

function MenuNodeHintArchiveGui:search_callback(list_with_indices)
	self._scroll:filter_items(function (item)
		local value, index = table.find_value(self._scroll:all_items(), function (v)
			return v == item
		end)

		if index and table.contains(list_with_indices, index) then
			return true
		end

		return false
	end, nil, true)
end

function MenuNodeHintArchiveGui:input_focus()
	return self._searchbox and self._searchbox:input_focus() or 1
end

function MenuNodeHintArchiveGui:_setup_item_rows(node)
	MenuNodeHintArchiveGui.super._setup_item_rows(self, node)
end

function MenuNodeHintArchiveGui:reload_item(item)
	MenuNodeHintArchiveGui.super.reload_item(self, item)

	local row_item = self:row_item(item)

	if row_item and alive(row_item.gui_panel) and (not item.align_panel or not item:align_panel(row_item, self.item_panel)) then
		row_item.gui_panel:set_halign("right")
		row_item.gui_panel:set_right(self.item_panel:w() - self._align_line_padding)
	end
end

function MenuNodeHintArchiveGui:_align_marker(row_item)
	MenuNodeHintArchiveGui.super._align_marker(self, row_item)
	self._marker_data.marker:set_world_right(self.item_panel:world_right() - self._align_line_padding)
end

function MenuNodeHintArchiveGui:_create_marker(node)
	self._marker_data = {}
	local width, _ = managers.gui_data:get_base_res()
	local height = 10
	self._marker_data.marker = self.item_panel:panel({
		y = 0,
		x = 0,
		w = width,
		h = height,
		layer = self.layers.marker
	})
	self._marker_data.gradient = self._marker_data.marker:bitmap({
		texture = "guis/textures/menu_selected",
		blend_mode = "add",
		y = 0,
		x = 0,
		layer = 0,
		alpha = self.marker_alpha or 0.6
	})

	if self.marker_color then
		self._marker_data.gradient:set_color(self.marker_color)
	end
end

function MenuNodeHintArchiveGui:_highlight_row_item(row_item, mouse_over)
	MenuNodeHintArchiveGui.super._highlight_row_item(self, row_item, mouse_over)
end

function MenuNodeHintArchiveGui:move_up()
	self._scroll:move_up()
end

function MenuNodeHintArchiveGui:move_down()
	self._scroll:move_down()
end

function MenuNodeHintArchiveGui:mouse_moved(o, x, y)
	local used = false
	local pointer = "arrow"

	if managers.menu:is_pc_controller() then
		local back_button = self._item_panel_parent:child("back_button")

		if not used and back_button:inside(x, y) then
			used = true
			pointer = "link"

			if not self._back_highlight then
				self._back_highlight = true

				back_button:set_color(tweak_data.screen_colors.button_stage_2)
				managers.menu_component:post_event("highlight")
			end
		elseif self._back_highlight then
			self._back_highlight = false

			back_button:set_color(tweak_data.screen_colors.button_stage_3)
		end
	end

	if not used and self._scroll:inside(x, y) then
		used, pointer = self._scroll:mouse_moved("", x, y)
	end

	return used, pointer
end

function MenuNodeHintArchiveGui:mouse_pressed(button, x, y)
	self._searchbox:mouse_pressed(button, x, y)
	self._scroll:mouse_pressed(button, x, y)

	if button == Idstring("0") and self._scroll:inside(x, y) then
		for index, item in ipairs(self._scroll:items()) do
			if item:is_inside(x, y) then
				self:_setup_detail_box_info(item.my_data)

				return
			end
		end
	end

	if button == Idstring("mouse wheel down") then
		self._scroll:perform_scroll(-60)
	elseif button == Idstring("mouse wheel up") then
		self._scroll:perform_scroll(60)
	end
end

function MenuNodeHintArchiveGui:mouse_released(button, x, y)
	self._scroll:mouse_released(button, x, y)
end

function MenuNodeHintArchiveGui:confirm_pressed()
	if managers.menu:is_pc_controller() and self._searchbox:input_focus() then
		self._searchbox:disconnect_search_input()

		return
	end

	local selected_item = self._scroll:selected_item()

	if selected_item then
		self:_setup_detail_box_info(selected_item.my_data)
	end
end

function MenuNodeHintArchiveGui:_setup_detail_box_info(tip)
	self._detail_panel_content:clear()

	local image_size = 200
	self._test_image_1 = self._detail_panel_content:bitmap({
		y = 25,
		layer = 2,
		texture = "guis/textures/loading/hints/" .. tip.image,
		w = image_size,
		h = image_size,
		x = self._detail_panel_content:w() / 2 - image_size / 2
	})
	self._text_title = self._detail_panel_content:text({
		name = "detail_panel_title",
		x = 25,
		layer = 1,
		text = managers.localization:text(tip.title_id),
		y = self._test_image_1:bottom() + medium_font_size,
		w = self._detail_panel_content:w() - 50,
		font_size = medium_font_size,
		font = medium_font,
		color = tweak_data.screen_colors.text
	})
	self._text_description = self._detail_panel_content:text({
		name = "detail_panel_description",
		wrap = true,
		x = 25,
		layer = 1,
		text = managers.localization:text(tip.text_id),
		y = self._test_image_1:bottom() + small_font_size + medium_font_size + 5,
		w = self._detail_panel_content:w() - 50,
		font_size = small_font_size,
		font = small_font,
		color = tweak_data.screen_colors.text
	})
end
