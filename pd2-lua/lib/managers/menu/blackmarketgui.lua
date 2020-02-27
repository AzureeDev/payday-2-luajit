require("lib/managers/menu/WalletGuiObject")
require("lib/utils/InventoryDescription")

local is_win32 = SystemInfo:platform() == Idstring("WIN32")
local NOT_WIN_32 = not is_win32
local WIDTH_MULTIPLIER = NOT_WIN_32 and 0.68 or 0.71
local BOX_GAP = 13.5
local GRID_H_MUL = (NOT_WIN_32 and 6.9 or 6.95) / 8
local ITEMS_PER_ROW = 3
local ITEMS_PER_COLUMN = 3
local BUY_MASK_SLOTS = {
	6,
	3
}
local WEAPON_MODS_SLOTS = {
	6,
	1
}
local WEAPON_MODS_GRID_H_MUL = 0.126
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

local function format_round(num, round_value)
	return round_value and tostring(math.round(num)) or string.format("%.1f", num):gsub("%.?0+$", "")
end

BlackMarketGuiItem = BlackMarketGuiItem or class()

function BlackMarketGuiItem:init(main_panel, data, x, y, w, h)
	self._main_panel = main_panel
	self._panel = main_panel:panel({
		name = tostring(data.name),
		x = x,
		y = y,
		w = w,
		h = h
	})
	self._data = data or {}
	self._name = data.name
	self._child_panel = nil
	self._alpha = 1
end

function BlackMarketGuiItem:inside(x, y)
	return self._panel:inside(x, y)
end

function BlackMarketGuiItem:select(instant, no_sound)
	if not self._selected then
		self._selected = true

		self:refresh()

		if not instant and not no_sound then
			managers.menu_component:post_event("highlight")
		end
	end
end

function BlackMarketGuiItem:deselect(instant)
	if self._selected then
		self._selected = false
	end

	self:refresh()
end

function BlackMarketGuiItem:set_highlight(highlight, no_sound)
	if self._highlighted ~= highlight then
		self._highlighted = highlight

		self:refresh()

		if highlight and not no_sound then
			managers.menu_component:post_event("highlight")
		end
	end
end

function BlackMarketGuiItem:refresh()
	self._alpha = self._selected and 1 or self._highlighted and 0.85 or 0.7

	if self._child_panel and alive(self._child_panel) then
		self._child_panel:set_visible(self._selected)
	end
end

function BlackMarketGuiItem:mouse_pressed(button, x, y)
	return self._panel:inside(x, y)
end

function BlackMarketGuiItem:mouse_moved(x, y)
	return false, "arrow"
end

function BlackMarketGuiItem:mouse_released(button, x, y)
end

function BlackMarketGuiItem:destroy()
end

function BlackMarketGuiItem:is_inside_scrollbar(x, y)
	return false
end

BlackMarketGuiTabItem = BlackMarketGuiTabItem or class(BlackMarketGuiItem)

function BlackMarketGuiTabItem:init(main_panel, data, node, size_data, hide_select_rect, scroll_tab_table, parent)
	BlackMarketGuiTabItem.super.init(self, main_panel, data, 0, 0, main_panel:w(), main_panel:h())

	local grid_panel_w = size_data.grid_w
	local grid_panel_h = size_data.grid_h
	local square_w = size_data.square_w
	local square_h = size_data.square_h
	local padding_w = size_data.padding_w
	local padding_h = size_data.padding_h
	local left_padding = size_data.left_padding
	local top_padding = size_data.top_padding
	self._size_data = size_data
	self._node = node

	self._data.on_create_func(self._data, parent)

	if not data.override_slots then
		local slots = {
			size_data.items_per_row,
			size_data.items_per_column
		}
	end

	slots[1] = math.max(1, slots[1])
	slots[2] = math.max(1, slots[2])
	self.my_slots_dimensions = slots
	square_w = square_w * size_data.items_per_row / slots[1]
	square_h = square_h * size_data.items_per_column / slots[2]

	if slots[2] == 1 then
		square_h = grid_panel_h
	end

	self._square_w = square_w
	self._square_h = square_h
	self._tab_panel = scroll_tab_table.panel:panel({
		name = "tab_panel"
	})
	self._tab_text_string = utf8.to_upper(data.name_localized or managers.localization:text(data.name))
	local text = self._tab_panel:text({
		vertical = "center",
		name = "tab_text",
		align = "center",
		blend_mode = "add",
		layer = 1,
		text = self._tab_text_string,
		font_size = medium_font_size,
		font = medium_font,
		color = tweak_data.screen_colors.button_stage_3,
		visible = not hide_select_rect
	})

	BlackMarketGui.make_fine_text(self, text)

	local _, _, tw, th = text:text_rect()

	self._tab_panel:set_size(tw + 15, th + 10)
	self._tab_panel:child("tab_text"):set_size(self._tab_panel:size())
	self._tab_panel:set_center_x(self._panel:w() / 2)
	self._tab_panel:set_y(0)
	self._tab_panel:bitmap({
		texture = "guis/textures/pd2/shared_tab_box",
		name = "tab_select_rect",
		visible = false,
		layer = 0,
		w = self._tab_panel:w(),
		h = self._tab_panel:h(),
		color = tweak_data.screen_colors.text:with_alpha(hide_select_rect and 0 or 1)
	})
	table.insert(scroll_tab_table, self._tab_panel)

	self._child_panel = self._panel:panel()
	self._grid_panel = self._child_panel:panel({
		name = "grid_panel",
		layer = 1,
		w = grid_panel_w,
		h = grid_panel_h
	})

	self._grid_panel:set_left(0)
	self._grid_panel:set_top(self._tab_panel:bottom() - 2 + top_padding)
	self._grid_panel:rect({
		layer = -10,
		color = Color.white:with_alpha(0)
	})

	self._grid_scroll_panel = self._grid_panel:panel({
		halign = "grow",
		name = "grid_scroll_panel"
	})
	self._node:parameters().menu_component_tabs = self._node:parameters().menu_component_tabs or {}
	self._node:parameters().menu_component_tabs[data.name] = self._node:parameters().menu_component_tabs[data.name] or {}
	self._my_node_data = self._node:parameters().menu_component_tabs[data.name]

	if slots[2] ~= 1 then
		self._grid_scroll_panel:set_h(grid_panel_h / slots[2] * #self._data / slots[1])
	else
		self._grid_scroll_panel:set_w(grid_panel_w * math.ceil(#self._data / slots[1]))
	end

	local y_scrolling = slots[2] ~= 1 and self._grid_panel:h() < self._grid_scroll_panel:h()

	if y_scrolling then
		-- Nothing
	end

	local x_scrolling = slots[2] == 1 and self._grid_panel:w() < self._grid_scroll_panel:w()

	if x_scrolling then
		self._tab_pages_panel = self._panel:panel({
			w = self._grid_panel:w(),
			h = medium_font_size
		})

		self._tab_pages_panel:set_top(self._grid_panel:bottom() + 2)

		local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")
		local tab_pages = math.ceil(#self._data / slots[1])
		local previous_page = self._tab_pages_panel:bitmap({
			name = "previous_page",
			blend_mode = "add",
			layer = 1,
			rotation = -90,
			texture = texture,
			texture_rect = rect,
			color = tweak_data.screen_colors.button_stage_3
		})

		previous_page:set_center_y(self._tab_pages_panel:h() / 2)

		local prev_item = previous_page
		local tab_string, tab_text = nil
		local tab_page_strings = self._data.tab_page_strings or {}

		for i = 1, tab_pages, 1 do
			tab_string = tab_page_strings[i] or tostring(i)
			tab_text = self._tab_pages_panel:text({
				blend_mode = "add",
				layer = 1,
				name = tostring(i),
				text = tab_string,
				font_size = medium_font_size,
				font = medium_font,
				color = tweak_data.screen_colors.button_stage_3
			})

			BlackMarketGui.make_fine_text(self, tab_text)
			tab_text:set_left(prev_item:right() + 6)

			prev_item = tab_text
		end

		local next_page = self._tab_pages_panel:bitmap({
			name = "next_page",
			blend_mode = "add",
			layer = 1,
			rotation = 90,
			texture = texture,
			texture_rect = rect,
			color = tweak_data.screen_colors.button_stage_3
		})

		next_page:set_center_y(self._tab_pages_panel:h() / 2)
		next_page:set_left(prev_item:right() + 6)
		self._tab_pages_panel:set_w(next_page:right())
		self._tab_pages_panel:set_right(self._grid_panel:right())
	end

	self._slots = {}
	local slot_equipped = 1

	for index, data in ipairs(self._data) do
		local new_slot_class = BlackMarketGuiSlotItem

		if data.unique_slot_class then
			new_slot_class = _G[data.unique_slot_class]
		end

		local x_index = slots[2] == 1 and index - 1 or (index - 1) % slots[1]
		local y_index = slots[2] == 1 and 0 or math.floor((index - 1) / slots[1])
		local x = math.floor(padding_w + x_index * (square_w + padding_w))
		local y = math.floor(padding_h + y_index * (square_h + padding_h))
		local new_slot = new_slot_class:new(self._grid_scroll_panel, data, x, y, square_w, square_h)

		new_slot.rect_bg:set_alpha(y_scrolling and y_index % 2 == 1 and 0.1 or 0)
		table.insert(self._slots, new_slot)

		if data.equipped then
			slot_equipped = index
		end

		if self._init_slot then
			self:_init_slot(data, new_slot)
		end
	end

	self._max_y_index = slots[2] == 1 and 0 or math.ceil(#self._data / slots[1])
	self.my_scroll_slots_y = slots[2] == 1 and 1 or math.max(self.my_slots_dimensions[2], math.ceil(#self._data / self.my_slots_dimensions[1]))
	self._my_node_data.scroll_y_index = self._my_node_data.scroll_y_index or 1

	self:check_new_drop()

	self._scroll_bar_panel = self._child_panel:panel({
		name = "scroll_bar_panel",
		w = BOX_GAP + 0,
		h = self._grid_panel:h()
	})

	self._scroll_bar_panel:set_left(self._grid_panel:right())
	self._scroll_bar_panel:set_top(self._grid_panel:top())

	self._scroll_indicator_box_class = BoxGuiObject:new(self._grid_panel, {
		sides = {
			0,
			0,
			0,
			0
		}
	})
	local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")
	local scroll_up_indicator_arrow = self._scroll_bar_panel:bitmap({
		name = "scroll_up_indicator_arrow",
		layer = 2,
		texture = texture,
		texture_rect = rect,
		color = Color.white
	})

	scroll_up_indicator_arrow:set_center_x(self._scroll_bar_panel:w() / 2)

	local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")
	local scroll_down_indicator_arrow = self._scroll_bar_panel:bitmap({
		name = "scroll_down_indicator_arrow",
		layer = 2,
		rotation = 180,
		texture = texture,
		texture_rect = rect,
		color = Color.white
	})

	scroll_down_indicator_arrow:set_bottom(self._scroll_bar_panel:h())
	scroll_down_indicator_arrow:set_center_x(self._scroll_bar_panel:w() / 2)

	local bar_h = scroll_down_indicator_arrow:top() - scroll_up_indicator_arrow:bottom()

	self._scroll_bar_panel:rect({
		alpha = 0.05,
		w = 4,
		x = 4,
		color = Color.black,
		y = scroll_up_indicator_arrow:bottom(),
		h = bar_h
	})

	bar_h = scroll_down_indicator_arrow:bottom() - scroll_up_indicator_arrow:top()
	local scroll_bar = self._scroll_bar_panel:panel({
		name = "scroll_bar",
		layer = 2,
		h = bar_h,
		w = self._scroll_bar_panel:w()
	})
	local scroll_bar_box_panel = scroll_bar:panel({
		w = 4,
		name = "scroll_bar_box_panel",
		valign = "scale",
		halign = "scale"
	})

	scroll_bar_box_panel:set_center_x(scroll_bar:w() / 2)

	self._scroll_bar_box_class = BoxGuiObject:new(scroll_bar_box_panel, {
		sides = {
			2,
			2,
			0,
			0
		}
	})

	self._scroll_bar_box_class:set_aligns("scale", "scale")
	scroll_bar:set_top(scroll_up_indicator_arrow:bottom())
	scroll_bar:set_center_x(scroll_up_indicator_arrow:center_x())
	scroll_bar_box_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		layer = -1,
		halign = "scale",
		render_template = "VertexColorTexturedBlur3D",
		valign = "scale",
		w = scroll_bar_box_panel:w(),
		h = scroll_bar_box_panel:h()
	})

	self._slot_selected = #self._slots > 0 and (self._my_node_data.selected or slot_equipped)
	self._slot_highlighted = nil

	self:set_scroll_y(self._slot_selected)
	self:deselect(true)
	self:set_highlight(false)
end

function BlackMarketGuiTabItem:has_scroll_bar(button)
	if alive(self._scroll_bar_panel) and self._scroll_bar_panel:visible() then
		return true
	end

	if alive(self._tab_pages_panel) and self._tab_pages_panel:visible() then
		local num_per_page = self.my_slots_dimensions and self.my_slots_dimensions[1] or 6
		local slot_selected = self._slot_selected or 1
		local i = math.ceil(slot_selected / num_per_page)
		local pages = math.ceil(#self._slots / num_per_page)

		if button == Idstring("mouse wheel down") then
			return i ~= pages
		elseif button == Idstring("mouse wheel up") then
			return i ~= 1
		end

		return true
	end

	return false
end

function BlackMarketGuiTabItem:is_inside_scrollbar(x, y)
	if self._scroll_bar_panel:visible() and self._scroll_bar_panel:inside(x, y) then
		return true
	end

	return false
end

function BlackMarketGuiTabItem:destroy()
	for i, slot in ipairs(self._slots) do
		slot:destroy()
	end
end

function BlackMarketGuiTabItem:deselect(instant)
	self:release_scroll_bar()
	BlackMarketGuiTabItem.super.deselect(self, instant)
end

function BlackMarketGuiTabItem:set_tab_text(new_text)
	local text = self._tab_panel:child("tab_text")

	text:set_text(new_text)
	BlackMarketGui.make_fine_text(self, text)

	local _, _, tw, th = text:text_rect()

	self._tab_panel:set_size(tw + 15, th + 10)
	text:set_size(self._tab_panel:size())
	self._tab_panel:child("tab_select_rect"):set_size(self._tab_panel:size())
end

function BlackMarketGuiTabItem:check_new_drop(first_time)
	local got_new_drop = false

	for _, slot in pairs(self._slots) do
		if slot._data.new_drop_data and slot._data.new_drop_data.icon then
			got_new_drop = true

			break
		end
	end

	local tab_text_string = self._tab_text_string

	if got_new_drop then
		tab_text_string = tab_text_string .. "" .. managers.localization:get_default_macro("BTN_INV_NEW")
	end

	self:set_tab_text(tab_text_string)
end

function BlackMarketGuiTabItem:refresh()
	self._alpha = 1

	if self._selected then
		self._tab_panel:child("tab_text"):set_color(tweak_data.screen_colors.button_stage_1)
		self._tab_panel:child("tab_text"):set_blend_mode("normal")
		self._tab_panel:child("tab_select_rect"):show()
	elseif self._highlighted then
		self._tab_panel:child("tab_text"):set_color(tweak_data.screen_colors.button_stage_2)
		self._tab_panel:child("tab_text"):set_blend_mode("add")
		self._tab_panel:child("tab_select_rect"):hide()
	else
		self._tab_panel:child("tab_text"):set_color(tweak_data.screen_colors.button_stage_3)
		self._tab_panel:child("tab_text"):set_blend_mode("add")
		self._tab_panel:child("tab_select_rect"):hide()
	end

	if self._child_panel and alive(self._child_panel) then
		self._child_panel:set_visible(self._selected)
	end

	if alive(self._tab_pages_panel) then
		self._tab_pages_panel:set_visible(self._selected)
	end
end

function BlackMarketGuiTabItem:set_tab_position(x)
	self._tab_panel:set_x(x)

	local _, _, tw, th = self._tab_panel:child("tab_text"):text_rect()

	self._tab_panel:set_size(tw + 15, th + 10)
	self._tab_panel:child("tab_text"):set_size(self._tab_panel:size())

	if self._new_drop_icon then
		self._new_drop_icon:set_leftbottom(0, 0)
	end

	return math.round(x + tw + 15 + 5)
end

function BlackMarketGuiTabItem:get_slot_by_mouse_position(x, y)
	if not self._selected then
		return
	end

	if not self._grid_panel:inside(x, y) then
		return
	end

	for i, slot in ipairs(self._slots) do
		if slot._name ~= "empty" and slot:inside(x, y) then
			return i
		end
	end
end

function BlackMarketGuiTabItem:inside_tab(x, y)
	return self._tab_panel:inside(x, y)
end

function BlackMarketGuiTabItem:inside(x, y)
	if self._tab_panel:inside(x, y) then
		return true
	end

	if not self._selected then
		return
	end

	if alive(self._tab_pages_panel) and self._tab_pages_panel:inside(x, y) then
		for _, child in ipairs(self._tab_pages_panel:children()) do
			if child:inside(x, y) then
				return 1
			end
		end
	end

	if not self._grid_panel:inside(x, y) then
		return
	end

	local update_select = false
	local result = not self._is_empty_slot_highlighted and 1 or false

	if not self._slot_highlighted then
		update_select = true
		result = false
	elseif self._slots[self._slot_highlighted] and not self._slots[self._slot_highlighted]:inside(x, y) then
		self._slots[self._slot_highlighted]:set_highlight(false)

		self._slot_highlighted = nil
		update_select = true
		result = false
	end

	if update_select then
		for i, slot in ipairs(self._slots) do
			if slot:inside(x, y) then
				self._slot_highlighted = i

				self._slots[self._slot_highlighted]:set_highlight(true)

				self._is_empty_slot_highlighted = self._slots[self._slot_highlighted]._name == "empty"

				return not self._is_empty_slot_highlighted and 1 or false
			end
		end
	end

	return result
end

function BlackMarketGuiTabItem:mouse_pressed(button, x, y)
	if alive(self._scroll_bar_panel) and self._scroll_bar_panel:visible() then
		if button == Idstring("mouse wheel down") then
			local max_view_y = (self.my_slots_dimensions[2] or ITEMS_PER_COLUMN) - 1

			if self._max_y_index <= self._my_node_data.scroll_y_index + max_view_y then
				self._my_node_data.scroll_y_index = self._max_y_index - max_view_y
			else
				self._my_node_data.scroll_y_index = self._my_node_data.scroll_y_index + 1
			end

			self:set_scroll_y()

			return self._slots[self._slot_selected]
		elseif button == Idstring("mouse wheel up") then
			local max_view_y = self.my_slots_dimensions[2] or ITEMS_PER_COLUMN

			if self._my_node_data.scroll_y_index <= 1 then
				self._my_node_data.scroll_y_index = 1
			else
				self._my_node_data.scroll_y_index = self._my_node_data.scroll_y_index - 1
			end

			self:set_scroll_y()

			return self._slots[self._slot_selected]
		end
	end

	if self:check_grab_scroll_bar(x, y) then
		return self._slots[self._slot_selected]
	end

	if alive(self._tab_pages_panel) then
		local num_per_page = self.my_slots_dimensions and self.my_slots_dimensions[1] or 6
		local slot_selected = self._slot_selected

		if button == Idstring("mouse wheel down") then
			slot_selected = math.min(slot_selected + num_per_page, #self._slots)

			return self:select_slot(slot_selected)
		elseif button == Idstring("mouse wheel up") then
			slot_selected = math.max(slot_selected - num_per_page, 1)

			return self:select_slot(slot_selected)
		elseif button == Idstring("0") then
			local child_name = nil

			for _, child in ipairs(self._tab_pages_panel:children()) do
				if child:inside(x, y) then
					child_name = child:name()

					if child_name == "previous_page" then
						slot_selected = math.max(slot_selected - num_per_page, 1)

						return self:select_slot(slot_selected)
					elseif child_name == "next_page" then
						slot_selected = math.min(slot_selected + num_per_page, #self._slots)

						return self:select_slot(slot_selected)
					else
						local current_page = math.ceil(slot_selected / num_per_page)
						local wanted_page = tonumber(child_name)

						if current_page ~= wanted_page then
							local diff_page = wanted_page - current_page
							slot_selected = math.clamp(slot_selected + diff_page * num_per_page, 1, #self._slots)

							return self:select_slot(slot_selected)
						end
					end
				end
			end
		end
	end

	if button ~= Idstring("0") or button == Idstring("1") then
		return
	end

	if not self._slots[self._slot_highlighted] then
		return
	end

	if self._slots[self._slot_selected] == self._slots[self._slot_highlighted] then
		return
	end

	if self._slots[self._slot_highlighted] and self._slots[self._slot_highlighted]:inside(x, y) then
		if self._slots[self._slot_selected] then
			self._slots[self._slot_selected]:deselect(false)
		end

		return self:select_slot(self._slot_highlighted)
	end
end

function BlackMarketGuiTabItem:mouse_moved(x, y)
	if alive(self._tab_pages_panel) then
		self._tab_pages_highlighted = self._tab_pages_highlighted or {}
		local num_per_page = self.my_slots_dimensions and self.my_slots_dimensions[1] or 6
		local used = false
		local pointer = "arrow"

		for _, child in ipairs(self._tab_pages_panel:children()) do
			if tonumber(child:name()) == math.ceil(self._slot_selected / num_per_page) then
				child:set_color(tweak_data.screen_colors.button_stage_2)
			elseif child:inside(x, y) then
				if not self._tab_pages_highlighted[_] then
					self._tab_pages_highlighted[_] = true

					child:set_color(tweak_data.screen_colors.button_stage_2)
					managers.menu_component:post_event("highlight")
				end

				if not used then
					used = true
					pointer = "link"
				end
			elseif self._tab_pages_highlighted[_] then
				self._tab_pages_highlighted[_] = false

				child:set_color(tweak_data.screen_colors.button_stage_3)
			end
		end

		if used then
			return used, pointer
		end
	end

	return self:moved_scroll_bar(x, y)
end

function BlackMarketGuiTabItem:mouse_released(button, x, y)
	self:release_scroll_bar()
end

function BlackMarketGuiTabItem:check_grab_scroll_bar(x, y)
	local scroll_bar = self._scroll_bar_panel:child("scroll_bar")

	if self._scroll_bar_panel:visible() and scroll_bar:inside(x, y) then
		self._grabbed_scroll_bar = true
		self._current_scroll_bar_y = y

		return true
	end

	local height = self._square_h + self._size_data.padding_h

	if self._scroll_bar_panel:child("scroll_up_indicator_arrow"):visible() and self._scroll_bar_panel:child("scroll_up_indicator_arrow"):inside(x, y) then
		self._my_node_data.scroll_y_index = math.max(self._my_node_data.scroll_y_index - 1, 1)
		self._pressing_arrow_up = true

		self:set_scroll_y()

		return true
	end

	if self._scroll_bar_panel:child("scroll_down_indicator_arrow"):visible() and self._scroll_bar_panel:child("scroll_down_indicator_arrow"):inside(x, y) then
		self._my_node_data.scroll_y_index = math.min(self._my_node_data.scroll_y_index + 1, self._max_y_index)
		self._pressing_arrow_down = true

		self:set_scroll_y()

		return true
	end

	return false
end

function BlackMarketGuiTabItem:release_scroll_bar()
	self._pressing_arrow_up = nil
	self._pressing_arrow_down = nil

	if self._grabbed_scroll_bar then
		self._grabbed_scroll_bar = nil

		return true
	end

	return false
end

function BlackMarketGuiTabItem:moved_scroll_bar(x, y)
	local scroll_bar = self._scroll_bar_panel:child("scroll_bar")

	if self._grabbed_scroll_bar then
		self._current_scroll_bar_y = self:scroll_with_bar(y, self._current_scroll_bar_y or 0)

		return true, "grab"
	elseif self._scroll_bar_panel:visible() and scroll_bar:inside(x, y) then
		return true, "hand"
	elseif self._scroll_bar_panel:child("scroll_up_indicator_arrow"):visible() and self._scroll_bar_panel:child("scroll_up_indicator_arrow"):inside(x, y) then
		return true, "link"
	elseif self._scroll_bar_panel:child("scroll_down_indicator_arrow"):visible() and self._scroll_bar_panel:child("scroll_down_indicator_arrow"):inside(x, y) then
		return true, "link"
	end

	return false, "arrow"
end

function BlackMarketGuiTabItem:scroll_with_bar(target_y, current_y)
	local scroll_up_indicator_arrow = self._scroll_bar_panel:child("scroll_up_indicator_arrow")
	local scroll_down_indicator_arrow = self._scroll_bar_panel:child("scroll_down_indicator_arrow")
	local scroll_bar = self._scroll_bar_panel:child("scroll_bar")
	local grid_panel = self._grid_panel
	local grid_scroll_panel = self._grid_scroll_panel
	local mul = grid_scroll_panel:h() / grid_panel:h()
	local height = self._square_h + self._size_data.padding_h
	local diff = current_y - target_y

	if diff == 0 then
		return current_y
	end

	local grid_panel = self._grid_panel
	local grid_scroll_panel = self._grid_scroll_panel
	local max_view_y = (self.my_slots_dimensions[2] or ITEMS_PER_COLUMN) - 1
	local dir = diff / math.abs(diff)

	while math.abs(current_y - target_y) >= height / mul do
		if dir > 0 and self._my_node_data.scroll_y_index <= 1 then
			self._my_node_data.scroll_y_index = 1

			break
		elseif dir < 0 and self._max_y_index <= self._my_node_data.scroll_y_index + max_view_y then
			self._my_node_data.scroll_y_index = self._max_y_index - max_view_y

			break
		end

		current_y = current_y - height / mul * dir
		self._my_node_data.scroll_y_index = self._my_node_data.scroll_y_index - 1 * dir
	end

	self:set_scroll_y()

	return current_y
end

function BlackMarketGuiTabItem:set_scroll_indicators()
	local new_y_index = self._my_node_data.scroll_y_index
	local max_view_y = (self.my_slots_dimensions[2] or ITEMS_PER_COLUMN) - 1
	local scroll_up_indicator_arrow = self._scroll_bar_panel:child("scroll_up_indicator_arrow")
	local scroll_down_indicator_arrow = self._scroll_bar_panel:child("scroll_down_indicator_arrow")
	local scroll_bar = self._scroll_bar_panel:child("scroll_bar")
	local grid_panel = self._grid_panel
	local grid_scroll_panel = self._grid_scroll_panel

	if grid_scroll_panel:h() == 0 then
		Application:error("[BlackMarketGuiTabItem:set_scroll_indicators] Dodging division by zero.", "grid_scroll_panel", inspect(self._data), inspect(self))

		return
	end

	local bar_h = scroll_down_indicator_arrow:bottom() - scroll_up_indicator_arrow:top()
	local scroll_diff = grid_panel:h() / grid_scroll_panel:h()

	if scroll_diff ~= 1 then
		local old_h = scroll_bar:h()

		scroll_bar:set_h(bar_h * scroll_diff)

		if old_h ~= scroll_bar:h() then
			-- Nothing
		end
	end

	local sh = grid_scroll_panel:h()

	scroll_bar:set_y(-grid_scroll_panel:y() * grid_panel:h() / sh)
	scroll_bar:set_center_x(scroll_up_indicator_arrow:center_x())
	scroll_bar:set_x(math.round(scroll_bar:x()) - 1)

	local visible = grid_panel:h() < grid_scroll_panel:h()
	local scroll_up_visible = new_y_index > 1
	local scroll_dn_visible = new_y_index + max_view_y < self._max_y_index

	scroll_up_indicator_arrow:set_visible(scroll_up_visible)
	scroll_down_indicator_arrow:set_visible(scroll_dn_visible)

	if self._scroll_up_visible ~= scroll_up_visible or self._scroll_dn_visible ~= scroll_dn_visible then
		self._scroll_up_visible = scroll_up_visible
		self._scroll_dn_visible = scroll_dn_visible

		self._scroll_indicator_box_class:create_sides(self._grid_panel, {
			sides = {
				0,
				0,
				scroll_up_visible and 2 or 0,
				scroll_dn_visible and 2 or 0
			}
		})
	end

	self._scroll_bar_panel:set_visible(visible)
end

function BlackMarketGuiTabItem:selected_slot_center()
	if not self._slots[self._slot_selected] then
		return 0, 0
	end

	local x = self._slots[self._slot_selected]._panel:world_center_x()
	local y = self._slots[self._slot_selected]._panel:world_center_y()

	return x, y
end

function BlackMarketGuiTabItem:set_scroll_y(slot)
	if self.my_slots_dimensions[2] == 1 then
		self._scroll_bar_panel:set_visible(false)

		return
	end

	local max_view_x = self.my_slots_dimensions[1] or self._size_data.items_per_row
	local max_view_y = self.my_slots_dimensions[2] or self._size_data.items_per_column
	local y_index = slot and math.ceil(slot / max_view_x)
	local top = self._my_node_data.scroll_y_index or 1
	local bottom = top + max_view_y - 1
	local height = self._square_h + self._size_data.padding_h
	local new_y_index = self._my_node_data.scroll_y_index

	if y_index and y_index < top then
		new_y_index = y_index
	end

	if y_index and bottom < y_index then
		new_y_index = y_index - max_view_y + 1
	end

	self._grid_scroll_panel:set_y(-(new_y_index - 1) * height)

	self._my_node_data.scroll_y_index = new_y_index

	self:set_scroll_indicators()
end

function BlackMarketGuiTabItem:select_slot(slot, instant)
	slot = not slot and self._slot_selected or self._slots[slot] and slot

	if not slot then
		slot = self._slot_selected or 1

		for i, d in pairs(self._slots) do
			if d._data and d._data.equipped then
				slot = i
			end
		end
	end

	local no_sound = false

	if slot ~= 1 and self._slots[self._slot_selected] and self._slots[self._slot_selected]._name == "empty" then
		return self:select_slot(1, instant)
	end

	if self._slots[slot] and self._slots[slot]._name == "empty" then
		if self._slot_selected < slot then
			return self:select_slot(slot - 1, instant)
		end

		slot = self._slot_selected
		no_sound = true
	end

	if self._slots[self._slot_selected] then
		self._slots[self._slot_selected]:deselect(instant)
	end

	local old_slot = self._slot_selected
	self._slot_selected = slot
	self._my_node_data.selected = self._slot_selected

	if old_slot ~= slot then
		self:set_scroll_y(slot)
	end

	local selected_slot = self._slots[self._slot_selected]:select(instant, no_sound)

	self:check_new_drop()
	managers.menu_component:set_blackmarket_tab_positions()

	if alive(self._tab_pages_panel) then
		local child = nil
		local num_per_page = self.my_slots_dimensions and self.my_slots_dimensions[1] or 6
		local page_selected = math.ceil(self._slot_selected / num_per_page)
		local offset = 0

		self._grid_scroll_panel:set_left(-(self._grid_panel:w() - offset) * (page_selected - 1))

		self._tab_pages_highlighted = self._tab_pages_highlighted or {}
		local page_num = nil

		for _, child in ipairs(self._tab_pages_panel:children()) do
			page_num = tonumber(child:name())

			if type(page_num) == "number" then
				if page_num == page_selected then
					child:set_color(tweak_data.screen_colors.button_stage_2)
				elseif self._tab_pages_highlighted[_] then
					child:set_color(tweak_data.screen_colors.button_stage_2)
				else
					child:set_color(tweak_data.screen_colors.button_stage_3)
				end
			end
		end

		for idx, slot in ipairs(self._slots) do
			slot:set_visible(math.ceil(idx / num_per_page) == math.ceil(self._slot_selected / num_per_page))
		end
	end

	return selected_slot
end

function BlackMarketGuiTabItem:slots()
	return self._slots
end

BlackMarketGuiSlotItem = BlackMarketGuiSlotItem or class(BlackMarketGuiItem)

function BlackMarketGuiSlotItem:init(main_panel, data, x, y, w, h)
	BlackMarketGuiSlotItem.super.init(self, main_panel, data, x, y, w, h)

	self.rect_bg = self._panel:rect({
		alpha = 0,
		color = Color.black
	})

	if data.holding then
		self._post_load_alpha = 0.2
		data.equipped_text = managers.localization:to_upper_text("bm_menu_holding_item")
	end

	if data.custom_name_text then
		local custom_name_text = self._panel:text({
			vertical = "top",
			name = "custom_name_text",
			align = "right",
			layer = 2,
			text = data.custom_name_text,
			font_size = small_font_size,
			font = small_font,
			color = tweak_data.screen_colors.text
		})

		custom_name_text:move((data.custom_name_text_right or 0) - 5, 5)

		local right = custom_name_text:right()

		custom_name_text:grow(-(custom_name_text:w() * (data.custom_name_text_width or 0.5)), 0)

		local _, _, w, h = custom_name_text:text_rect()

		if custom_name_text:w() < w then
			custom_name_text:set_font_scale(custom_name_text:font_scale() * custom_name_text:w() / w)
		end

		custom_name_text:set_right(right)
	end

	if data.hide_bg then
		-- Nothing
	end

	if data.mid_text and type(data.mid_text) == "table" then
		local text = self._panel:text({
			name = "text",
			wrap = true,
			word_wrap = true,
			layer = 2,
			text = data.mid_text.no_upper and data.mid_text.noselected_text or utf8.to_upper(data.mid_text.noselected_text),
			align = data.mid_text.align or "center",
			vertical = data.mid_text.vertical or "center",
			font_size = data.mid_text.font_size or medium_font_size,
			font = data.mid_text.font or medium_font,
			color = data.mid_text.noselected_color,
			blend_mode = data.mid_text.blend_mode or "add"
		})

		text:grow(-10, -10)
		text:move(5, 5)
		text:move(0, text:h() / 2 - text:font_size() / 2)
		text:set_vertical("top")

		self._text_in_mid = true
	elseif data.corner_text and type(data.corner_text) == "table" then
		self._panel:text({
			name = "corner_text",
			wrap = true,
			word_wrap = true,
			layer = 2,
			text = data.corner_text.no_upper and data.corner_text.noselected_text or utf8.to_upper(data.corner_text.noselected_text),
			align = data.corner_text.align or "center",
			vertical = data.corner_text.vertical or "bottom",
			font_size = data.corner_text.font_size or tiny_font_size,
			font = data.corner_text.font or small_font,
			color = data.corner_text.noselected_color or Color.red,
			blend_mode = data.corner_text.blend_mode or "add"
		})
	end

	local function animate_loading_texture(o)
		o:set_render_template(Idstring("VertexColorTexturedRadial"))
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

	self._mini_panel = self._panel:panel()
	self._extra_textures = {}

	if data.extra_bitmaps then
		local color, shape = nil

		for i, bitmap in ipairs(data.extra_bitmaps) do
			if DB:has(Idstring("texture"), bitmap) then
				color = data.extra_bitmaps_colors and data.extra_bitmaps_colors[i] or Color.white
				shape = data.extra_bitmaps_shape and data.extra_bitmaps_shape[i] or {
					x = 0,
					y = 0
				}

				table.insert(self._extra_textures, self._panel:bitmap({
					h = 32,
					w = 32,
					layer = 0,
					texture = bitmap,
					color = color,
					x = self._panel:w() * shape.x,
					y = self._panel:h() * shape.y
				}))
			else
				Application:error("[BlackMarketGuiSlotItem] Texture not found in DB: ", tostring(bitmap))
			end
		end
	end

	local texture_loaded_clbk = callback(self, self, "texture_loaded_clbk")

	if data.mini_icons then
		local padding = data.mini_icons.borders and 14 or 5

		for k, icon_data in ipairs(data.mini_icons) do
			icon_data.padding = padding

			if not icon_data.texture then
				local new_icon = nil

				if icon_data.text then
					new_icon = self._mini_panel:text({
						font = tweak_data.menu.pd2_small_font,
						font_size = tweak_data.menu.pd2_font_size,
						text = icon_data.text,
						color = icon_data.color or Color.white,
						w = icon_data.w or 32,
						h = icon_data.h or 32,
						layer = icon_data.layer or 1,
						blend_mode = icon_data.blend_mode
					})
				else
					new_icon = self._mini_panel:rect({
						color = icon_data.color or Color.white,
						w = icon_data.w or 32,
						h = icon_data.h or 32,
						layer = icon_data.layer or 1,
						blend_mode = icon_data.blend_mode,
						alpha = icon_data.alpha
					})
				end

				if icon_data.visible == false then
					new_icon:set_visible(false)
				end

				if icon_data.left then
					new_icon:set_left(padding + icon_data.left)
				elseif icon_data.right then
					new_icon:set_right(self._mini_panel:w() - padding - icon_data.right)
				else
					new_icon:set_center_x(self._mini_panel:w() / 2)
				end

				if icon_data.top then
					new_icon:set_top(padding + icon_data.top)
				elseif icon_data.bottom then
					new_icon:set_bottom(self._mini_panel:h() - padding - icon_data.bottom)
				else
					new_icon:set_center_y(self._mini_panel:h() / 2)
				end

				if icon_data.name == "new_drop" and data.new_drop_data then
					data.new_drop_data.icon = new_icon
				end
			elseif icon_data.stream then
				if DB:has(Idstring("texture"), icon_data.texture) then
					icon_data.request_index = managers.menu_component:request_texture(icon_data.texture, callback(self, self, "icon_loaded_clbk", icon_data)) or false
				end
			else
				local new_icon = self._mini_panel:bitmap({
					texture = icon_data.texture,
					color = icon_data.color or Color.white,
					w = icon_data.w or 32,
					h = icon_data.h or 32,
					layer = icon_data.layer or 1,
					alpha = icon_data.alpha,
					blend_mode = icon_data.blend_mode
				})

				if icon_data.render_template then
					new_icon:set_render_template(icon_data.render_template)
				end

				if icon_data.visible == false then
					new_icon:set_visible(false)
				end

				if icon_data.left then
					new_icon:set_left(padding + icon_data.left)
				elseif icon_data.right then
					new_icon:set_right(self._mini_panel:w() - padding - icon_data.right)
				else
					new_icon:set_center_x(self._mini_panel:w() / 2)
				end

				if icon_data.top then
					new_icon:set_top(padding + icon_data.top)
				elseif icon_data.bottom then
					new_icon:set_bottom(self._mini_panel:h() - padding - icon_data.bottom)
				else
					new_icon:set_center_y(self._mini_panel:h() / 2)
				end

				if icon_data.name == "new_drop" and data.new_drop_data then
					data.new_drop_data.icon = new_icon
				end

				if icon_data.spin then
					local function spin_animation(o)
						local dt = nil

						while true do
							dt = coroutine.yield()

							o:rotate(dt * 180)
						end
					end

					new_icon:animate(spin_animation)

					self._loading_icon = new_icon
				end
			end

			if icon_data.borders then
				local icon_border_panel = self._mini_panel:panel({
					w = icon_data.w or 32,
					h = icon_data.h or 32,
					layer = icon_data.layer or 1
				})

				if icon_data.visible == false then
					icon_border_panel:set_visible(false)
				end

				if icon_data.left then
					icon_border_panel:set_left(padding + icon_data.left)
				elseif icon_data.right then
					icon_border_panel:set_right(self._mini_panel:w() - padding - icon_data.right)
				end

				if icon_data.top then
					icon_border_panel:set_top(padding + icon_data.top)
				elseif icon_data.bottom then
					icon_border_panel:set_bottom(self._mini_panel:h() - padding - icon_data.bottom)
				end

				BoxGuiObject:new(icon_border_panel, {
					sides = {
						1,
						1,
						1,
						1
					}
				})
			end
		end

		if data.mini_icons.borders then
			local tl_side = self._mini_panel:rect({
				blend_mode = "add",
				w = 10,
				h = 2,
				alpha = 0.4,
				color = Color.white
			})
			local tl_down = self._mini_panel:rect({
				blend_mode = "add",
				w = 2,
				h = 10,
				alpha = 0.4,
				color = Color.white
			})
			local tr_side = self._mini_panel:rect({
				blend_mode = "add",
				w = 10,
				h = 2,
				alpha = 0.4,
				color = Color.white
			})
			local tr_down = self._mini_panel:rect({
				blend_mode = "add",
				w = 2,
				h = 10,
				alpha = 0.4,
				color = Color.white
			})
			local bl_side = self._mini_panel:rect({
				blend_mode = "add",
				w = 10,
				h = 2,
				alpha = 0.4,
				color = Color.white
			})
			local bl_down = self._mini_panel:rect({
				blend_mode = "add",
				w = 2,
				h = 10,
				alpha = 0.4,
				color = Color.white
			})
			local br_side = self._mini_panel:rect({
				blend_mode = "add",
				w = 10,
				h = 2,
				alpha = 0.4,
				color = Color.white
			})
			local br_down = self._mini_panel:rect({
				blend_mode = "add",
				w = 2,
				h = 10,
				alpha = 0.4,
				color = Color.white
			})

			tl_side:set_lefttop(self._mini_panel:w() - 54, 8)
			tl_down:set_lefttop(self._mini_panel:w() - 54, 8)
			tr_side:set_righttop(self._mini_panel:w() - 8, 8)
			tr_down:set_righttop(self._mini_panel:w() - 8, 8)
			bl_side:set_leftbottom(self._mini_panel:w() - 54, self._mini_panel:h() - 8)
			bl_down:set_leftbottom(self._mini_panel:w() - 54, self._mini_panel:h() - 8)
			br_side:set_rightbottom(self._mini_panel:w() - 8, self._mini_panel:h() - 8)
			br_down:set_rightbottom(self._mini_panel:w() - 8, self._mini_panel:h() - 8)
		end
	end

	if data.mini_colors then
		local panel_size = 32
		local padding = data.mini_icons and data.mini_icons.borders and 14 or 5
		local color_panel = self._mini_panel:panel({
			layer = 1,
			w = panel_size,
			h = panel_size
		})

		color_panel:set_right(self._mini_panel:w() - padding)
		color_panel:set_bottom(self._mini_panel:h() - padding)
		BoxGuiObject:new(color_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})

		if #data.mini_colors == 1 then
			color_panel:rect({
				color = data.mini_colors[1].color or Color.red,
				alpha = data.mini_colors[1].alpha or 1,
				blend_mode = data.mini_colors[1].blend
			})
		elseif #data.mini_colors == 2 then
			color_panel:polygon({
				triangles = {
					Vector3(0, 0, 0),
					Vector3(0, panel_size, 0),
					Vector3(panel_size, 0, 0)
				},
				color = data.mini_colors[1].color or Color.red,
				alpha = data.mini_colors[1].alpha or 1,
				blend_mode = data.mini_colors[1].blend,
				w = panel_size,
				h = panel_size
			})
			color_panel:polygon({
				triangles = {
					Vector3(0, panel_size, 0),
					Vector3(panel_size, 0, 0),
					Vector3(panel_size, panel_size, 0)
				},
				color = data.mini_colors[2].color or Color.red,
				alpha = data.mini_colors[2].alpha or 1,
				blend_mode = data.mini_colors[2].blend,
				w = panel_size,
				h = panel_size
			})
		end
	end

	if data.bitmap_texture then
		local texture = data.bitmap_texture[1] or data.bitmap_texture
		self._bitmap_panel = self._panel:panel()
		local text_callback = callback(self, self, "texture_loaded_clbk", data.bitmap_texture)

		if DB:has(Idstring("texture"), texture) then
			self._loading_texture = true

			if data.stream then
				self._requested_texture = texture
				self._request_index = managers.menu_component:request_texture(self._requested_texture, text_callback)
			else
				text_callback(data.bitmap_texture, Idstring(texture))
			end
		end

		if not self._bitmap then
			local min = math.min(self._bitmap_panel:w(), self._bitmap_panel:h())

			self._bitmap_panel:set_size(min, min)
			self._bitmap_panel:set_center(self._panel:w() / 2, self._panel:h() / 2)

			self._bitmap = self._bitmap_panel:bitmap({
				texture = "guis/textures/pd2/endscreen/exp_ring",
				name = "item_texture",
				h = 32,
				valign = "scale",
				w = 32,
				halign = "scale",
				render_template = "VertexColorTexturedRadial",
				color = Color(0.2, 1, 1),
				layer = #self._extra_textures + 1
			})

			self._bitmap:set_center(self._bitmap_panel:w() / 2, self._bitmap_panel:h() / 2)
			self._bitmap:animate(animate_loading_texture)
		end
	end

	local bg_image = data.button_text and self._panel:text({
		vertical = "center",
		wrap = true,
		align = "center",
		wrap_word = true,
		valign = "center",
		text = data.button_text,
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		color = tweak_data.screen_colors.text
	})

	if data.bg_texture and DB:has(Idstring("texture"), data.bg_texture) then
		local bg_image = self._panel:bitmap({
			name = "bg_texture",
			halign = "scale",
			valign = "scale",
			layer = 0,
			texture = data.bg_texture,
			color = data.bg_texture_color or Color.white,
			blend_mode = data.bg_texture_blend_mode or "add",
			alpha = data.bg_alpha ~= nil and data.bg_alpha or 1
		})
		local texture_width = bg_image:texture_width()
		local texture_height = bg_image:texture_height()
		local panel_width = self._panel:w()
		local panel_height = self._panel:h()
		local tw = texture_width
		local th = texture_height
		local pw = panel_width
		local ph = panel_height

		if tw == 0 or th == 0 then
			Application:error("[BlackMarketGuiSlotItem] BG Texture size error!:", "width", tw, "height", th)

			tw = 1
			th = 1
		end

		local sw = math.min(pw, ph * tw / th)
		local sh = math.min(ph, pw / (tw / th))

		bg_image:set_size(math.round(sw), math.round(sh))
		bg_image:set_center(self._panel:w() * 0.5, self._panel:h() * 0.5)
	end

	local equipped_text = self._panel:text({
		text = "",
		vertical = "top",
		name = "equipped_text",
		align = "left",
		layer = 2,
		font_size = small_font_size,
		font = small_font,
		color = tweak_data.screen_colors.text
	})

	equipped_text:move(5, 5)

	if data.equipped then
		local equipped_string = data.equipped_text or managers.localization:text("bm_menu_equipped")

		equipped_text:set_text(utf8.to_upper(equipped_string))

		self._equipped_box = BoxGuiObject:new(self._panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
	end

	local red_box = false
	local number_text = false
	self._conflict = data.conflict
	self._level_req = data.level

	if data.lock_texture then
		red_box = true
	end

	if type(data.unlocked) == "number" then
		number_text = math.abs(data.unlocked)

		if data.unlocked < 0 then
			red_box = true
			self._item_req = true
		end
	end

	if data.mid_text and not data.mid_text_no_change_alpha then
		if self._bitmap then
			self._bitmap:set_color(self._bitmap:color():with_alpha(0.6))

			if self._akimbo_bitmap then
				self._akimbo_bitmap:set_color(self._bitmap:color())
			end
		end

		if self._loading_texture then
			self._post_load_alpha = 0.4
		end
	end

	if red_box then
		if self._bitmap then
			self._bitmap:set_color(Color.white:with_alpha(data.bitmap_locked_alpha or 0.6))

			for _, bitmap in pairs(self._extra_textures) do
				bitmap:set_color(bitmap:color():with_alpha(0.6))
			end

			self._bitmap:set_blend_mode(data.bitmap_locked_blend_mode or "sub")

			if self._akimbo_bitmap then
				self._akimbo_bitmap:set_color(self._bitmap:color())
				self._akimbo_bitmap:set_blend_mode(data.bitmap_locked_blend_mode or "sub")
			end
		end

		if self._loading_texture then
			self._post_load_alpha = data.bitmap_locked_alpha or 0.6
			self._post_load_blend_mode = data.bitmap_locked_blend_mode or "sub"
		end

		if (not data.unlocked or data.can_afford ~= false) and data.lock_texture ~= true then
			self._lock_bitmap = self._panel:bitmap({
				name = "lock",
				h = 32,
				w = 32,
				texture = data.lock_texture or "guis/textures/pd2/skilltree/padlock",
				texture_rect = data.lock_rect or nil,
				color = data.lock_color or tweak_data.screen_colors.important_1,
				layer = #self._extra_textures + 2
			})

			if data.lock_shape then
				local w = data.lock_shape.w or 32
				local h = data.lock_shape.h or 32

				self._lock_bitmap:set_size(w, h)
			end

			self._lock_bitmap:set_center(self._panel:w() / 2, self._panel:h() / 2)

			if data.lock_shape then
				local x = data.lock_shape.x or 0
				local y = data.lock_shape.y or 0

				self._lock_bitmap:move(x, y)
			end
		end
	end

	if number_text then
		-- Nothing
	end

	self:deselect(true)
	self:set_highlight(false, true)
end

function BlackMarketGuiSlotItem:get_texure_size(debug)
	if self._bitmap then
		local texture_width = self._bitmap:texture_width()
		local texture_height = self._bitmap:texture_height()
		local panel_width, panel_height = self._panel:size()

		if texture_width == 0 or texture_height == 0 or panel_width == 0 or panel_height == 0 then
			return 0, 0
		end

		local aspect = panel_width / panel_height
		local sw = math.max(texture_width, texture_height * aspect)
		local sh = math.max(texture_height, texture_width / aspect)
		local dw = texture_width / sw
		local dh = texture_height / sh

		return math.round(dw * panel_width), math.round(dh * panel_height)
	end

	return 0, 0
end

function BlackMarketGuiSlotItem:rescale_texture_aspect(bitmap, width, height)
	if not alive(bitmap) then
		return
	end

	width = width or bitmap:width()
	height = height or bitmap:height()
	local texture_width = bitmap:texture_width()
	local texture_height = bitmap:texture_height()
	local aspect = width / height
	local sw = math.max(texture_width, texture_height * aspect)
	local sh = math.max(texture_height, texture_width / aspect)
	local dw = texture_width / sw
	local dh = texture_height / sh

	bitmap:set_size(math.round(dw * width), math.round(dh * height))
end

function BlackMarketGuiSlotItem:icon_loaded_clbk(icon_data, texture_idstring, ...)
	if not alive(self._mini_panel) then
		Application:error("[BlackMarketGuiSlotItem] icon_loaded_clbk(): This code should no longer occur!!")

		return
	end

	local padding = icon_data.padding or 5
	local new_icon = self._mini_panel:bitmap({
		texture = texture_idstring,
		color = icon_data.color or Color.white,
		w = icon_data.w or 32,
		h = icon_data.h or 32,
		layer = icon_data.layer or 1,
		alpha = icon_data.alpha,
		blend_mode = icon_data.blend_mode
	})

	if icon_data.render_template then
		new_icon:set_render_template(icon_data.render_template)
	end

	if icon_data.visible == false then
		new_icon:set_visible(false)
	end

	if icon_data.left then
		new_icon:set_left(padding + icon_data.left)
	elseif icon_data.right then
		new_icon:set_right(self._mini_panel:w() - padding - icon_data.right)
	else
		new_icon:set_center_x(self._mini_panel:w() / 2)
	end

	if icon_data.top then
		new_icon:set_top(padding + icon_data.top)
	elseif icon_data.bottom then
		new_icon:set_bottom(self._mini_panel:h() - padding - icon_data.bottom)
	else
		new_icon:set_center_y(self._mini_panel:h() / 2)
	end

	if icon_data.name == "new_drop" and self._data.new_drop_data then
		self._data.new_drop_data.icon = new_icon
	end
end

function BlackMarketGuiSlotItem:destroy()
	if self._data and self._data.mini_icons then
		for i, icon_data in ipairs(self._data.mini_icons) do
			if icon_data.stream then
				managers.menu_component:unretrieve_texture(icon_data.texture, icon_data.request_index)
			end
		end
	end

	if self._requested_texture then
		managers.menu_component:unretrieve_texture(self._requested_texture, self._request_index)
	end
end

function BlackMarketGuiSlotItem:texture_loaded_clbk(texture_data)
	local texture = texture_data[1] or texture_data
	local text_rect = texture_data[2]

	if not alive(self._bitmap_panel) then
		Application:error("[BlackMarketGuiSlotItem] texture_loaded_clbk(): This code should no longer occur!!")

		return
	end

	local bitmap_color = (self._data.bitmap_color or Color.white):with_alpha(self._post_load_alpha or self._data.bitmap_alpha or 1)
	local bitmap_blend_mode = self._post_load_alpha and self._post_load_blend_mode or self._data.bitmap_blend_mode or "normal"

	if self._bitmap then
		self._bitmap:stop()
		self._bitmap:set_rotation(0)
		self._bitmap:set_color(bitmap_color)

		local _ = text_rect and self._bitmap:set_image(texture, unpack(text_rect)) or self._bitmap:set_image(texture)

		self._bitmap:set_render_template(self._data.render_template or Idstring("VertexColorTextured"))
		self._bitmap:set_blend_mode(bitmap_blend_mode)

		for _, bitmap in pairs(self._extra_textures) do
			bitmap:set_color(bitmap_color)
			bitmap:set_blend_mode(bitmap_blend_mode)
		end
	else
		self._bitmap = self._bitmap_panel:bitmap({
			name = "item_texture",
			texture = texture,
			texture_rect = text_rect,
			blend_mode = bitmap_blend_mode,
			layer = #self._extra_textures + 1,
			color = bitmap_color
		})

		self._bitmap:set_render_template(self._data.render_template or Idstring("VertexColorTextured"))
	end

	self._bitmap:set_valign("scale")
	self._bitmap:set_halign("scale")

	local size_w, size_h = self:get_texure_size(true)

	self._bitmap_panel:set_size(size_w, size_h)
	self._bitmap_panel:set_center(self._panel:w() * 0.5, self._panel:h() * 0.5)

	if self._data.akimbo_gui_data then
		self._akimbo_bitmap = self._bitmap_panel:bitmap({
			name = "akimbo_texture",
			texture = texture,
			texture_rect = text_rect,
			blend_mode = bitmap_blend_mode,
			color = bitmap_color,
			layer = #self._extra_textures + 1
		})

		self._akimbo_bitmap:set_render_template(self._data.render_template or Idstring("VertexColorTextured"))
		self._akimbo_bitmap:set_valign("scale")
		self._akimbo_bitmap:set_halign("scale")

		local scale = self._data.akimbo_gui_data.scale or 0.75
		local offset = self._data.akimbo_gui_data.offset or 0.1

		self._bitmap:set_size(size_w * scale, size_h * scale)
		self._akimbo_bitmap:set_size(size_w * scale, size_h * scale)
		self._bitmap:set_center(self._bitmap_panel:w() * (0.5 - offset), self._bitmap_panel:h() * 0.5)
		self._akimbo_bitmap:set_center(self._bitmap_panel:w() * (0.5 + offset), self._bitmap_panel:h() * 0.5)
	else
		self._bitmap:set_size(size_w, size_h)
		self._bitmap:set_center(self._bitmap_panel:w() * 0.5, self._bitmap_panel:h() * 0.5)
	end

	local shape = nil

	for i, bitmap in ipairs(self._extra_textures) do
		shape = self._data.extra_bitmaps_shape and self._data.extra_bitmaps_shape[i] or {
			w = 1,
			h = 1,
			x = 0,
			y = 0
		}

		bitmap:set_size(self._bitmap_panel:size())
		bitmap:grow(bitmap:w() * shape.w, bitmap:h() * shape.h)
		bitmap:set_center(self._bitmap_panel:center())
		bitmap:move(self._bitmap_panel:w() * shape.x, self._bitmap_panel:h() * shape.y)
	end

	if self._data.akimbo_gui_data then
		local rotation = self._data.akimbo_gui_data.rotation or 45

		self._bitmap:rotate(rotation)
		self._akimbo_bitmap:rotate(rotation)
	end

	self._post_load_alpha = nil
	self._post_load_blend_mode = nil
	self._loading_texture = nil

	self:set_highlight(self._highlighted, true)

	if self._selected then
		self:select(true)
	else
		self:deselect(true)
	end

	self:refresh()
end

function BlackMarketGuiSlotItem:set_btn_text(text)
end

function BlackMarketGuiSlotItem:set_highlight(highlight, instant)
	if self._bitmap and not self._loading_texture then
		if highlight then
			local function animate_select(o, panel, instant, width, height)
				local w = o:w()
				local h = o:h()
				local end_w = width * 0.85
				local end_h = height * 0.85
				local center_x, center_y = o:center()

				if w == end_w or instant then
					o:set_size(end_w, end_h)
					o:set_center(center_x, center_y)

					return
				end

				over(math.abs(end_w - w) / end_w, function (p)
					o:set_size(math.lerp(w, end_w, p), math.lerp(h, end_h, p))
					o:set_center(center_x, center_y)
				end)
			end

			local w, h = self:get_texure_size()

			self._bitmap_panel:stop()
			self._bitmap_panel:animate(animate_select, self._panel, instant, w, h)

			local shape = nil

			for i, bitmap in pairs(self._extra_textures) do
				shape = self._data.extra_bitmaps_shape and self._data.extra_bitmaps_shape[i] or {
					w = 1,
					h = 1,
					x = 0,
					y = 0
				}

				bitmap:stop()
				bitmap:animate(animate_select, self._panel, instant, w * shape.w, h * shape.h)
			end
		else
			local function animate_deselect(o, panel, instant, width, height)
				local w = o:w()
				local h = o:h()
				local end_w = width * 0.65
				local end_h = height * 0.65
				local center_x, center_y = o:center()

				if w == end_w or instant then
					o:set_size(end_w, end_h)
					o:set_center(center_x, center_y)

					return
				end

				over(math.abs(end_w - w) / end_w, function (p)
					o:set_size(math.lerp(w, end_w, p), math.lerp(h, end_h, p))
					o:set_center(center_x, center_y)
				end)
			end

			local w, h = self:get_texure_size()

			self._bitmap_panel:stop()
			self._bitmap_panel:animate(animate_deselect, self._panel, instant, w, h)

			local shape = nil

			for i, bitmap in pairs(self._extra_textures) do
				shape = self._data.extra_bitmaps_shape and self._data.extra_bitmaps_shape[i] or {
					w = 1,
					h = 1,
					x = 0,
					y = 0
				}

				bitmap:stop()
				bitmap:animate(animate_deselect, self._panel, instant, w * shape.w, h * shape.h)
			end
		end
	end
end

function BlackMarketGuiSlotItem:select(instant, no_sound)
	BlackMarketGuiSlotItem.super.select(self, instant, no_sound)

	if not managers.menu:is_pc_controller() then
		self:set_highlight(true, instant)
	end

	if self._text_in_mid and alive(self._panel:child("text")) then
		self._panel:child("text"):set_color(self._data.mid_text.selected_color or Color.white)
		self._panel:child("text"):set_text(self._data.mid_text.no_upper and self._data.mid_text.selected_text or utf8.to_upper(self._data.mid_text.selected_text or ""))

		if alive(self._lock_bitmap) and self._data.mid_text.is_lock_same_color then
			self._lock_bitmap:set_color(self._panel:child("text"):color())
		end
	end

	if self._data.new_drop_data then
		local newdrop = self._data.new_drop_data

		if newdrop[1] and newdrop[2] and newdrop[3] then
			managers.blackmarket:remove_new_drop(newdrop[1], newdrop[2], newdrop[3])

			if newdrop.icon then
				newdrop.icon:parent():remove(newdrop.icon)
			end

			self._data.new_drop_data = nil
		end
	end

	if self._panel:child("equipped_text") and self._data.selected_text and not self._data.equipped then
		self._panel:child("equipped_text"):set_text(self._data.selected_text)
	end

	if self._mini_panel and self._data.hide_unselected_mini_icons then
		self._mini_panel:show()
	end

	return self
end

function BlackMarketGuiSlotItem:deselect(instant)
	BlackMarketGuiSlotItem.super.deselect(self, instant)

	if not managers.menu:is_pc_controller() then
		self:set_highlight(false, instant)
	end

	if self._text_in_mid and alive(self._panel:child("text")) then
		self._panel:child("text"):set_color(self._data.mid_text.noselected_color or Color.white)
		self._panel:child("text"):set_text(self._data.mid_text.no_upper and self._data.mid_text.noselected_text or utf8.to_upper(self._data.mid_text.noselected_text or ""))

		if alive(self._lock_bitmap) and self._data.mid_text.is_lock_same_color then
			self._lock_bitmap:set_color(self._panel:child("text"):color())
		end
	end

	if self._panel:child("equipped_text") and self._data.selected_text and not self._data.equipped then
		self._panel:child("equipped_text"):set_text("")
	end

	if self._mini_panel and self._data.hide_unselected_mini_icons then
		self._mini_panel:hide()
	end
end

function BlackMarketGuiSlotItem:refresh()
	BlackMarketGuiSlotItem.super.refresh(self)

	if self._bitmap then
		self._bitmap:set_alpha(1)

		if self._akimbo_bitmap then
			self._akimbo_bitmap:set_alpha(1)
		end

		for _, bitmap in pairs(self._extra_textures) do
			bitmap:set_alpha(1)
		end
	end
end

function BlackMarketGuiSlotItem:set_visible(visible)
	self._panel:set_visible(visible)
end

BlackMarketGuiMaskSlotItem = BlackMarketGuiMaskSlotItem or class(BlackMarketGuiSlotItem)

function BlackMarketGuiMaskSlotItem:init(main_panel, data, x, y, w, h)
	BlackMarketGuiMaskSlotItem.super.init(self, main_panel, data, x, y, w, h)

	local cx = self._panel:w() / 2
	local cy = self._panel:h() / 2
	self._box_panel = self._panel:panel({
		w = self._panel:w() * 0.5,
		h = self._panel:w() * 0.5
	})

	self._box_panel:set_center(cx, cy)

	if not data.my_part_data.is_good then
		BoxGuiObject:new(self._box_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
	end

	self._mask_text = self._panel:text({
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size
	})

	self._mask_text:set_position(self._box_panel:left(), self._box_panel:bottom() + 10)
	self._mask_text:set_text(utf8.to_upper(data.name_localized .. ": "))
	BlackMarketGui.make_fine_text(self, self._mask_text)

	self._mask_name_text = self._panel:text({
		word_wrap = true,
		wrap = true,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size
	})

	self._mask_name_text:set_position(self._mask_text:right(), self._mask_text:top())
	self._mask_name_text:set_text(data.my_part_data.is_good and managers.localization:text(data.my_part_data.text) or "NOT SELECTED")
	self._mask_name_text:set_blend_mode(data.my_part_data.is_good and "normal" or "add")
	self._mask_name_text:set_color(data.my_part_data.is_good and tweak_data.screen_colors.text or tweak_data.screen_colors.important_1)
	self._mask_name_text:grow(-self._mask_name_text:x() - 5, 0)

	local _, _, _, texth = self._mask_name_text:text_rect()

	if data.my_part_data.override then
		self._mask_error_text = self._panel:text({
			blend_mode = "add",
			wrap = true,
			word_wrap = true,
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.important_1
		})

		self._mask_error_text:set_position(self._mask_text:left(), self._mask_text:top() + texth)
		self._mask_error_text:set_text(managers.localization:to_upper_text("menu_bm_overwrite", {
			category = managers.localization:text("bm_menu_" .. data.my_part_data.override)
		}))
	end

	local current_match_with_true = true

	if data.my_part_data.is_good and data.my_true_part_data then
		current_match_with_true = data.my_part_data.id == data.my_true_part_data.id
	end

	if not current_match_with_true then
		if self._bitmap then
			self._bitmap:set_color(Color.white:with_alpha(0.3))

			if self._akimbo_bitmap then
				self._akimbo_bitmap:set_color(self._bitmap:color())
			end

			for _, bitmap in pairs(self._extra_textures) do
				bitmap:set_color(bitmap:color():with_alpha(0.3))
			end
		end

		if self._loading_texture then
			self._post_load_alpha = 0.3
		end

		self._mask_text:set_color(self._mask_text:color():with_alpha(0.5))
		self._mask_name_text:set_color(self._mask_name_text:color():with_alpha(0.5))

		if self._mask_error_text then
			self._mask_error_text:set_color(self._mask_error_text:color():with_alpha(0.5))
		end
	end

	self:deselect(true)
	self:set_highlight(false, true)
end

function BlackMarketGuiMaskSlotItem:set_highlight(highlight, instant)
	if self._bitmap and not self._loading_texture then
		if highlight then
			local function animate_select(o, panel, instant, width, height)
				local w = o:w()
				local h = o:h()
				local end_w = width * 0.55
				local end_h = height * 0.55
				local center_x, center_y = o:center()

				if w == end_w or instant then
					o:set_size(end_w, end_h)
					o:set_center(center_x, center_y)

					return
				end

				over(math.abs(end_w - w) / end_w, function (p)
					o:set_size(math.lerp(w, end_w, p), math.lerp(h, end_h, p))
					o:set_center(center_x, center_y)
				end)
			end

			local w, h = self:get_texure_size()

			self._bitmap_panel:stop()
			self._bitmap_panel:animate(animate_select, self._panel, instant, w, h)

			for _, bitmap in pairs(self._extra_textures) do
				bitmap:stop()
				bitmap:animate(animate_select, self._panel, instant, w, h)
			end
		else
			local function animate_deselect(o, panel, instant, width, height)
				local w = o:w()
				local h = o:h()
				local end_w = width * 0.45
				local end_h = height * 0.45
				local center_x, center_y = o:center()

				if w == end_w or instant then
					o:set_size(end_w, end_h)
					o:set_center(center_x, center_y)

					return
				end

				over(math.abs(end_w - w) / end_w, function (p)
					o:set_size(math.lerp(w, end_w, p), math.lerp(h, end_h, p))
					o:set_center(center_x, center_y)
				end)
			end

			local w, h = self:get_texure_size()

			self._bitmap_panel:stop()
			self._bitmap_panel:animate(animate_deselect, self._panel, instant, w, h)

			for _, bitmap in pairs(self._extra_textures) do
				bitmap:stop()
				bitmap:animate(animate_deselect, self._panel, instant, w, h)
			end
		end
	end
end

BlackMarketGuiButtonItem = BlackMarketGuiButtonItem or class(BlackMarketGuiItem)

function BlackMarketGuiButtonItem:init(main_panel, data, x)
	BlackMarketGuiButtonItem.super.init(self, main_panel, data, 0, 0, 10, 10)

	local up_font_size = NOT_WIN_32 and RenderSettings.resolution.y < 720 and self._data.btn == "BTN_STICK_R" and 2 or 0
	self._btn_text = self._panel:text({
		text = "",
		name = "text",
		align = "left",
		blend_mode = "add",
		x = 10,
		layer = 1,
		font_size = small_font_size + up_font_size,
		font = small_font,
		color = tweak_data.screen_colors.button_stage_3
	})
	self._btn_text_id = data.name
	self._btn_text_legends = data.legends
	self._pc_btn = data.pc_btn

	BlackMarketGui.make_fine_text(self, self._btn_text)
	self._panel:set_size(main_panel:w() - x * 2, medium_font_size)
	self._panel:rect({
		blend_mode = "add",
		name = "select_rect",
		halign = "scale",
		alpha = 0.3,
		valign = "scale",
		color = tweak_data.screen_colors.button_stage_3
	})

	if not managers.menu:is_pc_controller() then
		self._btn_text:set_color(tweak_data.screen_colors.text)
	end

	self._panel:set_left(x)
	self._panel:hide()
	self:set_order(data.prio)
	self._btn_text:set_right(self._panel:w())
	self:deselect(true)
	self:set_highlight(false)
end

function BlackMarketGuiButtonItem:hide()
	self._panel:hide()
end

function BlackMarketGuiButtonItem:show()
	self._panel:show()
end

function BlackMarketGuiButtonItem:refresh()
	if managers.menu:is_pc_controller() then
		self._btn_text:set_color(self._highlighted and tweak_data.screen_colors.button_stage_2 or tweak_data.screen_colors.button_stage_3)
	end

	self._panel:child("select_rect"):set_visible(self._highlighted)
end

function BlackMarketGuiButtonItem:visible()
	return self._panel:visible()
end

function BlackMarketGuiButtonItem:set_order(prio)
	self._panel:set_y((prio - 1) * small_font_size)
end

function BlackMarketGuiButtonItem:set_text_btn_prefix(prefix)
	self._btn_prefix = prefix
end

function BlackMarketGuiButtonItem:set_text_params(params)
	local prefix = self._btn_prefix and managers.localization:get_default_macro(self._btn_prefix) or ""
	local btn_text = prefix

	if managers.menu:is_steam_controller() then
		prefix = self._pc_btn or "skip_cutscene"
		btn_text = managers.localization:btn_macro(prefix)
	end

	if self._btn_text_id then
		btn_text = btn_text .. utf8.to_upper(managers.localization:text(self._btn_text_id, params))
	end

	if self._btn_text_legends then
		local legend_string = ""

		for i, legend in ipairs(self._btn_text_legends) do
			if i > 1 then
				legend_string = legend_string .. " | "
			end

			legend_string = legend_string .. managers.localization:text(legend)
		end

		btn_text = btn_text .. utf8.to_upper(legend_string)
	end

	self._btn_text:set_text(btn_text)
	BlackMarketGui.make_fine_text(self, self._btn_text)

	local _, _, w, h = self._btn_text:text_rect()

	self._panel:set_h(h)
	self._btn_text:set_size(w, h)
	self._btn_text:set_right(self._panel:w())
end

function BlackMarketGuiButtonItem:btn_text()
	return self._btn_text:text()
end

BlackMarketGui = BlackMarketGui or class()
BlackMarketGui.identifiers = {
	weapon = Idstring("weapon"),
	armor = Idstring("armor"),
	melee_weapon = Idstring("melee_weapon"),
	grenade = Idstring("grenade"),
	mask = Idstring("mask"),
	weapon_mod = Idstring("weapon_mod"),
	mask_mod = Idstring("mask_mod"),
	deployable = Idstring("deployable"),
	character = Idstring("character"),
	weapon_cosmetic = Idstring("weapon_cosmetic"),
	inventory_tradable = Idstring("inventory_tradable"),
	armor_skins = Idstring("armor_skins"),
	player_style = Idstring("player_style"),
	suit_variation = Idstring("suit_variation")
}

function BlackMarketGui:init(ws, fullscreen_ws, node)
	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._init_layer = self._ws:panel():layer()
	self._preloading_list = {}
	self._preloading_index = 0
	self._node = node
	local component_data = self._node:parameters().menu_component_data
	local do_animation = not component_data and not self._data
	local is_start_page = not component_data and true or false

	self:_setup(is_start_page, component_data)

	if do_animation then
		local function fade_me_in_scotty(o)
			over(0.1, function (p)
				o:set_alpha(p)
			end)
		end

		self._panel:animate(fade_me_in_scotty)
		self._fullscreen_panel:animate(fade_me_in_scotty)
	end

	self:set_enabled(true)
end

function BlackMarketGui:set_layer(layer)
	self._panel:set_layer(self._init_layer + layer)
end

function BlackMarketGui:set_enabled(enabled)
	self._enabled = enabled

	if not self._enabled then
		local blur = self._disabled_panel:bitmap({
			texture = "guis/textures/test_blur_df",
			render_template = "VertexColorTexturedBlur3D",
			w = self._disabled_panel:panel():w(),
			h = self._disabled_panel:panel():h()
		})

		local function func(o)
			local start_blur = 0

			over(0.6, function (p)
				o:set_alpha(math.lerp(start_blur, 1, p))
			end)
		end

		blur:animate(func)
	else
		self._disabled_panel:clear()
	end
end

function BlackMarketGui:make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end

function BlackMarketGui:calc_max_items(items, override_slots)
	local items_per_row = override_slots and override_slots[1] or ITEMS_PER_ROW
	local max_rows_on_screen = override_slots and override_slots[2] or ITEMS_PER_COLUMN

	return math.max(math.ceil(items / items_per_row), max_rows_on_screen) * items_per_row
end

function BlackMarketGui:in_setup()
	return not not self._in_setup
end

function BlackMarketGui:_setup(is_start_page, component_data)
	self._in_setup = true

	if alive(self._panel) then
		self._ws:panel():remove(self._panel)
	end

	MenuCallbackHandler:chk_dlc_content_updated()

	self._item_bought = nil
	self._panel = self._ws:panel():panel({})
	self._fullscreen_panel = self._fullscreen_ws:panel():panel({
		layer = 40
	})

	self:set_layer(45)

	self._disabled_panel = self._fullscreen_panel:panel({
		layer = 100
	})

	WalletGuiObject.set_wallet(self._panel)

	self._data = component_data or self:_start_page_data()
	self._node:parameters().menu_component_data = self._data
	self._requested_textures = {}

	if self._data.init_callback_name then
		local clbk_func = callback(self, self, self._data.init_callback_name, self._data.init_callback_params)

		if clbk_func then
			clbk_func()
		end

		if self._data.init_callback_params and self._data.init_callback_params.run_once then
			self._data.init_callback_name = nil
			self._data.init_callback_params = nil
		end
	end

	if not self._data.skip_blur then
		self._data.blur_fade = self._data.blur_fade or 0
		local blur = self._fullscreen_panel:bitmap({
			texture = "guis/textures/test_blur_df",
			render_template = "VertexColorTexturedBlur3D",
			layer = -1,
			w = self._fullscreen_ws:panel():w(),
			h = self._fullscreen_ws:panel():h()
		})

		local function func(o, component_data)
			local start_blur = component_data.blur_fade

			over(0.6 - 0.6 * component_data.blur_fade, function (p)
				component_data.blur_fade = math.lerp(start_blur, 1, p)

				o:set_alpha(component_data.blur_fade)
			end)
		end

		blur:animate(func, self._data)
	end

	self._panel:text({
		vertical = "bottom",
		name = "back_button",
		align = "right",
		text = utf8.to_upper(managers.localization:text("menu_back")),
		font_size = large_font_size,
		font = large_font,
		color = tweak_data.screen_colors.button_stage_3
	})
	self:make_fine_text(self._panel:child("back_button"))
	self._panel:child("back_button"):set_right(self._panel:w())
	self._panel:child("back_button"):set_bottom(self._panel:h())
	self._panel:child("back_button"):set_visible(managers.menu:is_pc_controller())

	self._pages = #self._data > 1 or self._data.show_tabs
	local grid_size = self._panel:h() - 70
	local grid_h_mul = self._data.panel_grid_h_mul or GRID_H_MUL
	local grid_panel_w = self._panel:w() * WIDTH_MULTIPLIER * (self._data.panel_grid_w_mul or 1)
	local grid_panel_h = grid_size * grid_h_mul
	local items_per_row = self._data[1] and self._data[1].override_slots and self._data[1].override_slots[1] or ITEMS_PER_ROW
	local items_per_column = self._data[1] and self._data[1].override_slots and self._data[1].override_slots[2] or ITEMS_PER_COLUMN
	grid_panel_w = math.ceil(grid_panel_w / items_per_row) * items_per_row
	grid_panel_h = math.ceil(grid_panel_h / items_per_column) * items_per_column
	local square_w = grid_panel_w / items_per_row
	local square_h = grid_panel_h / items_per_column
	local padding_w = 0
	local padding_h = 0
	local left_padding = 0
	local top_padding = 55 + (GRID_H_MUL - grid_h_mul) * grid_size
	local size_data = {
		grid_w = math.floor(grid_panel_w),
		grid_h = math.floor(grid_panel_h),
		items_per_row = items_per_row,
		items_per_column = items_per_column,
		square_w = math.floor(square_w),
		square_h = math.floor(square_h),
		padding_w = math.floor(padding_w),
		padding_h = math.floor(padding_h),
		left_padding = math.floor(left_padding),
		top_padding = math.floor(top_padding)
	}

	if grid_h_mul ~= GRID_H_MUL then
		self._no_input_panel = self._panel:panel({
			y = 60,
			w = grid_panel_w,
			h = top_padding - 60
		})
	end

	if self._data.use_bgs then
		local blur_panel = self._panel:panel({
			layer = -1,
			x = size_data.left_padding,
			y = size_data.top_padding + 33,
			w = size_data.grid_w,
			h = size_data.grid_h - 1
		})

		BlackMarketGui.blur_panel(blur_panel)
	end

	self._inception_node_name = self._node:parameters().menu_component_next_node_name or "blackmarket_node"
	self._preview_node_name = self._node:parameters().menu_component_preview_node_name or "blackmarket_preview_node"
	self._crafting_node_name = self._node:parameters().menu_component_crafting_node_name or "blackmarket_crafting_node"
	self._tabs = {}
	self._btns = {}
	self._title_text = self._panel:text({
		name = "title_text",
		text = managers.localization:to_upper_text(self._data.topic_id, self._data.topic_params),
		font_size = large_font_size,
		font = large_font,
		color = tweak_data.screen_colors.text
	})

	self:make_fine_text(self._title_text)

	if self._data.topic_colors then
		managers.menu_component:add_colors_to_text_object(self._title_text, self._data.topic_colors)
	elseif self._data.topic_color then
		managers.menu_component:make_color_text(self._title_text, self._data.topic_color)
	end

	self._tab_scroll_panel = self._panel:panel({
		w = grid_panel_w,
		y = top_padding + 1
	})
	self._tab_area_panel = self._panel:panel({
		w = grid_panel_w,
		y = top_padding + 1
	})
	self._tab_scroll_table = {
		panel = self._tab_scroll_panel
	}

	for i, data in ipairs(self._data) do
		if data.on_create_func_name then
			data.on_create_func = callback(self, self, data.on_create_func_name)
		end

		local new_tab_class = BlackMarketGuiTabItem

		if data.unique_tab_class then
			new_tab_class = _G[data.unique_tab_class]
		end

		local new_tab = new_tab_class:new(self._panel, data, self._node, size_data, not self._pages, self._tab_scroll_table, self)

		table.insert(self._tabs, new_tab)
	end

	if self._data.open_callback_name then
		local clbk_func = callback(self, self, self._data.open_callback_name, self._data.open_callback_params)

		if clbk_func then
			clbk_func()
		end
	end

	if #self._tabs > 0 then
		self._tab_area_panel:set_h(self._tabs[#self._tabs]._tab_panel:h())
	end

	self._selected = self._data.selected_tab or self._node:parameters().menu_component_selected or 1
	self._node:parameters().menu_component_selected = self._selected
	self._data.selected_tab = nil
	self._select_rect = self._panel:panel({
		name = "select_rect",
		layer = 8,
		w = square_w,
		h = square_h
	})

	if self._tabs[self._selected] then
		self._tabs[self._selected]:select(true)

		local slot_dim_x = self._tabs[self._selected].my_slots_dimensions[1]
		local slot_dim_y = self._tabs[self._selected].my_slots_dimensions[2]
		local _, any_slot = next(self._tabs[self._selected]._slots)

		if any_slot then
			self._select_rect:set_size(any_slot._panel:size())
		end

		self._select_rect_box = BoxGuiObject:new(self._select_rect, {
			sides = {
				2,
				2,
				2,
				2
			}
		})

		self._select_rect_box:set_clipping(false)

		self._box_panel = self._panel:panel()

		self._box_panel:set_shape(self._tabs[self._selected]._grid_panel:shape())

		self._box = BoxGuiObject:new(self._box_panel, {
			sides = {
				1,
				1,
				1 + (#self._tabs > 1 and 1 or 0),
				1
			}
		})
		local info_box_top = 88
		local info_box_size = self._panel:h() - 70
		local info_box_w = math.floor(self._panel:w() * (1 - WIDTH_MULTIPLIER) - BOX_GAP)
		local info_box_h = grid_panel_h

		if self._data.panel_grid_h_mul then
			info_box_h = math.floor(info_box_size * GRID_H_MUL)
		end

		self._extra_options_data = self._data.extra_options_data

		if self._data.extra_options_panel then
			self._extra_options_panel = self._panel:panel({
				name = "extra_options_panel"
			})

			self._extra_options_panel:set_size(info_box_w, self._data.extra_options_panel.height or self._data.extra_options_panel.h or 50)
			self._extra_options_panel:set_right(self._panel:w())
			self._extra_options_panel:set_top(info_box_top)

			local panel = self._extra_options_panel:panel()

			if self._data.extra_options_panel.on_create_func_name then
				if self._extra_options_data then
					self._extra_options_data.selected = math.min(self._extra_options_data.selected or 1, managers.blackmarket:num_preferred_characters() + 1, CriminalsManager.get_num_characters())
				end

				local selected = math.min(self._extra_options_data and self._extra_options_data.selected or 1, managers.blackmarket:num_preferred_characters() + 1, CriminalsManager.get_num_characters())
				self._extra_options_data = callback(self, self, self._data.extra_options_panel.on_create_func_name)(panel)
				self._extra_options_data.selected = selected
				local num_panels = 0

				for i = 1, #self._extra_options_data, 1 do
					if self._extra_options_data[i].panel then
						num_panels = num_panels + 1
					end
				end

				self._extra_options_data.num_panels = num_panels
			end

			self._extra_options_box = BoxGuiObject:new(self._extra_options_panel, {
				sides = {
					1,
					1,
					1,
					1
				}
			})
			local h = self._extra_options_panel:h() + 5
			info_box_top = info_box_top + h
			info_box_h = info_box_h - h
			self._data.extra_options_data = self._extra_options_data

			if is_win32 then
				self._ws:connect_keyboard(Input:keyboard())
				self._panel:key_press(callback(self, self, "extra_option_key_press"))

				self._keyboard_connected = true
			end
		end

		if self._data.add_market_panel then
			self._market_panel = self._panel:panel({
				visible = true,
				name = "market_panel",
				h = 140,
				layer = 1,
				y = info_box_top,
				w = info_box_w
			})

			self._market_panel:set_right(self._panel:w())
			self._market_panel:rect({
				alpha = 0.25,
				layer = -1,
				color = Color.black
			})

			self._market_border = BoxGuiObject:new(self._market_panel, {
				sides = {
					1,
					1,
					1,
					1
				}
			})
			local h = self._market_panel:h() + 5
			local market_bundles = {}

			for entry, safe in pairs(tweak_data.economy.safes) do
				if not safe.promo then
					table.insert(market_bundles, {
						content = safe.content or "NONE",
						safe = entry,
						drill = safe.drill,
						prio = safe.prio or 0
					})
				end
			end

			local loc_sort = {}

			table.sort(market_bundles, function (x, y)
				if x.prio ~= y.prio then
					return (x.prio or 0) < (y.prio or 0)
				end

				if not loc_sort[x.safe] then
					loc_sort[x.safe] = managers.localization:text(tweak_data.economy.safes[x.safe].name_id)
				end

				if not loc_sort[y.safe] then
					loc_sort[y.safe] = managers.localization:text(tweak_data.economy.safes[y.safe].name_id)
				end

				return loc_sort[x.safe] < loc_sort[y.safe]
			end)

			local num_market_bundles = #market_bundles

			if managers.menu:is_pc_controller() and num_market_bundles > 0 then
				info_box_top = info_box_top + h
				info_box_h = info_box_h - h
				local title_text = self._panel:text({
					text = managers.localization:to_upper_text("menu_steam_market_inspect_title"),
					font = small_font,
					font_size = small_font_size,
					color = tweak_data.screen_colors.text
				})

				self:make_fine_text(title_text)
				title_text:set_left(self._market_panel:left())
				title_text:set_bottom(self._market_panel:top())

				local padding = 10
				local w = self._market_panel:w() - 2 * padding
				local h = self._market_panel:h() - 2 * padding
				local size = math.min(w / 2, h - 2 * small_font_size - padding * 0.5)
				local panel, safe_panel, drill_panel, safe_text, drill_text, safe_market_panel, drill_market_panel, title_text = nil
				self._market_bundles = {}
				self._data.active_market_bundle = self._data.active_market_bundle or 1
				local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")
				local select_bg = self._market_panel:rect({
					blend_mode = "add",
					layer = -2,
					color = tweak_data.screen_colors.button_stage_3:with_alpha(0.2)
				})
				local arrow_left = self._market_panel:bitmap({
					blend_mode = "add",
					texture = "guis/textures/menu_arrows",
					texture_rect = {
						24,
						0,
						24,
						24
					},
					color = tweak_data.screen_colors.button_stage_3,
					y = padding
				})
				local arrow_right = self._market_panel:bitmap({
					texture = "guis/textures/menu_arrows",
					blend_mode = "add",
					rotation = 180,
					texture_rect = {
						24,
						0,
						24,
						24
					},
					color = tweak_data.screen_colors.button_stage_3,
					y = padding
				})

				arrow_left:set_world_y(math.round(arrow_left:world_y()))
				arrow_right:set_world_y(math.round(arrow_right:world_y()) + 1)
				arrow_right:set_right(self._market_panel:w() - padding)
				arrow_left:set_left(padding)
				select_bg:set_shape(arrow_left:left(), arrow_left:top(), arrow_right:right() - arrow_left:left(), arrow_left:h())

				self._market_bundles.arrow_left = arrow_left
				self._market_bundles.arrow_right = arrow_right
				self._market_bundles.num_bundles = num_market_bundles
				self._market_bundles.market_bundles = market_bundles

				for i, bundle in ipairs(market_bundles) do
					panel = self._market_panel:panel({
						name = tostring(i),
						x = padding,
						y = padding,
						w = w,
						h = h,
						visible = i == self._data.active_market_bundle
					})
					title_text = panel:text({
						vertical = "center",
						h = 24,
						align = "center",
						halign = "center",
						valign = "center",
						text = managers.localization:to_upper_text("menu_steam_market_content_" .. bundle.content),
						font = small_font,
						font_size = small_font_size,
						color = tweak_data.screen_colors.button_stage_2
					})

					self:make_fine_text(title_text)
					title_text:set_center(panel:w() / 2, 12)

					local guis_catalog = "guis/"
					local bundle_folder = tweak_data.economy.safes[bundle.safe].texture_bundle_folder

					if bundle_folder then
						guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
					end

					local path = "safes/"
					local texture_path = guis_catalog .. path .. bundle.safe
					safe_panel = panel:panel({
						alpha = 0.9,
						name = "safe",
						y = small_font_size + padding * 0.5,
						w = size,
						h = size
					})

					safe_panel:set_center_x(w * 0.5)
					self:request_texture(texture_path, safe_panel, true, "normal")

					safe_text = panel:text({
						blend_mode = "add",
						text = managers.localization:to_upper_text("menu_steam_market_show_content"),
						font = small_font,
						font_size = small_font_size,
						x = safe_panel:x(),
						y = safe_panel:bottom() + 1,
						color = tweak_data.screen_colors.button_stage_3
					})

					self:make_fine_text(safe_text)
					safe_text:set_center_x(safe_panel:center_x())

					safe_market_panel = panel:panel({
						x = safe_panel:x(),
						y = safe_panel:y(),
						w = safe_panel:w(),
						h = safe_panel:h() + small_font_size
					})
					local guis_catalog = "guis/"
					local bundle_folder = tweak_data.economy.drills[bundle.drill].texture_bundle_folder

					if bundle_folder then
						guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
					end

					if not tweak_data.economy.safes[bundle.safe].free then
						local path = "drills/"
						local texture_path = guis_catalog .. path .. bundle.drill
						drill_panel = panel:panel({
							alpha = 0.9,
							name = "drill",
							y = small_font_size + padding * 0.5,
							w = size,
							h = size
						})

						drill_panel:set_center_x(w * 0.75)
						self:request_texture(texture_path, drill_panel, true, "normal")

						drill_text = panel:text({
							text = managers.localization:to_upper_text("menu_steam_market_buy_drill"),
							font = small_font,
							font_size = small_font_size,
							x = drill_panel:x(),
							y = drill_panel:bottom() + 1,
							color = tweak_data.screen_colors.button_stage_3
						})

						self:make_fine_text(drill_text)
						drill_text:set_center_x(drill_panel:center_x())
						drill_text:set_x(math.round(drill_text:x()))

						drill_market_panel = panel:panel({
							x = drill_panel:x(),
							y = drill_panel:y(),
							w = drill_panel:w(),
							h = drill_panel:h() + small_font_size
						})
					else
						drill_text = nil
						drill_panel = nil
						drill_market_panel = nil
					end

					self._market_bundles[i] = {
						panel = panel,
						safe = {
							entry = bundle.safe,
							image = safe_panel,
							text = safe_text,
							select = safe_market_panel
						},
						drill = {
							entry = bundle.drill,
							image = drill_panel,
							text = drill_text,
							select = drill_market_panel
						}
					}
				end
			else
				self._market_panel:hide()
				self._market_panel:set_h(0)
			end
		end

		local info_box_panel = self._panel:panel({
			name = "info_box_panel"
		})

		info_box_panel:set_size(info_box_w, info_box_h)
		info_box_panel:set_right(self._panel:w())
		info_box_panel:set_top(info_box_top)

		self._selected_slot = self._tabs[self._selected]:select_slot(nil, true)
		self._slot_data = self._selected_slot._data
		local x, y = self._tabs[self._selected]:selected_slot_center()

		self._select_rect:set_world_center(x, y)

		local BTNS = {
			w_move = {
				btn = "BTN_A",
				name = "bm_menu_btn_move_weapon",
				prio = managers.menu:is_pc_controller() and 5 or 1,
				callback = callback(self, self, "pickup_crafted_item_callback")
			},
			w_place = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_place_weapon",
				callback = callback(self, self, "place_crafted_item_callback")
			},
			w_swap = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_swap_weapon",
				callback = callback(self, self, "place_crafted_item_callback")
			},
			m_move = {
				btn = "BTN_A",
				prio = 5,
				name = "bm_menu_btn_move_mask",
				callback = callback(self, self, "pickup_crafted_item_callback")
			},
			m_place = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_place_mask",
				callback = callback(self, self, "place_crafted_item_callback")
			},
			m_swap = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_swap_mask",
				callback = callback(self, self, "place_crafted_item_callback")
			},
			i_stop_move = {
				btn = "BTN_X",
				name = "bm_menu_btn_stop_move",
				prio = 2,
				pc_btn = "menu_remove_item",
				callback = callback(self, self, "drop_hold_crafted_item_callback")
			},
			i_rename = {
				btn = "BTN_BACK",
				name = "bm_menu_btn_rename_item",
				prio = 2,
				pc_btn = "toggle_chat",
				callback = callback(self, self, "rename_item_with_gamepad_callback")
			},
			w_mod = {
				btn = "BTN_Y",
				name = "bm_menu_btn_mod",
				prio = 2,
				pc_btn = "menu_modify_item",
				callback = callback(self, self, "choose_weapon_mods_callback")
			},
			w_equip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_equip_weapon",
				callback = callback(self, self, "equip_weapon_callback")
			},
			w_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview",
				prio = 3,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_weapon_callback")
			},
			w_sell = {
				btn = "BTN_X",
				name = "bm_menu_btn_sell",
				prio = 4,
				pc_btn = "menu_remove_item",
				callback = callback(self, self, "sell_item_callback")
			},
			w_skin = {
				btn = "BTN_STICK_L",
				name = "bm_menu_btn_skin",
				prio = 5,
				pc_btn = "menu_edit_skin",
				callback = callback(self, self, "edit_weapon_skin_callback")
			},
			w_unequip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_unequip_weapon",
				callback = function ()
				end
			},
			ew_unlock = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_buy_weapon_slot",
				callback = callback(self, self, "choose_weapon_slot_unlock_callback")
			},
			ew_buy = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_buy_new_weapon",
				callback = callback(self, self, "choose_weapon_buy_callback")
			},
			bw_buy = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_buy_selected_weapon",
				callback = callback(self, self, "buy_weapon_callback")
			},
			bw_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview",
				prio = 3,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_buy_weapon_callback")
			},
			bw_available_mods = {
				btn = "BTN_Y",
				name = "bm_menu_available_mods",
				prio = 2,
				pc_btn = "menu_preview_item_alt",
				callback = callback(self, self, "show_available_mods_callback")
			},
			bw_buy_dlc = {
				btn = "BTN_X",
				name = "bm_menu_buy_dlc",
				prio = 4,
				pc_btn = "menu_remove_item",
				callback = callback(self, self, "show_buy_dlc_callback")
			},
			bw_preview_mods = {
				btn = "BTN_Y",
				name = "bm_menu_preview_mods",
				prio = 2,
				pc_btn = "menu_preview_item_alt",
				callback = callback(self, self, "preview_weapon_mods_callback")
			},
			mt_choose = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_choose",
				callback = callback(self, self, "choose_mod_callback")
			},
			wm_buy = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_craft_mod",
				callback = callback(self, self, "buy_mod_callback")
			},
			wm_preview = {
				btn = "BTN_Y",
				name = "bm_menu_btn_preview",
				prio = 3,
				pc_btn = "menu_preview_item_alt",
				callback = callback(self, self, "preview_weapon_mod_callback")
			},
			wm_preview_mod = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_with_mod",
				prio = 4,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_weapon_with_mod_callback")
			},
			wm_remove_buy = {
				btn = "BTN_X",
				name = "bm_menu_btn_remove_mod",
				prio = 2,
				pc_btn = "menu_remove_item",
				callback = callback(self, self, "remove_mod_callback")
			},
			wm_remove_preview_mod = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_with_mod",
				prio = 4,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_weapon_mod_callback")
			},
			wm_remove_preview = {
				btn = "BTN_Y",
				name = "bm_menu_btn_preview_no_mod",
				prio = 3,
				pc_btn = "menu_preview_item_alt",
				callback = callback(self, self, "preview_weapon_without_mod_callback")
			},
			wm_sell = {
				btn = "BTN_X",
				name = "bm_menu_btn_sell",
				prio = 2,
				pc_btn = "menu_remove_item",
				callback = callback(self, self, "sell_weapon_mods_callback")
			},
			wm_reticle_switch_menu = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_switch_reticle",
				callback = callback(self, self, "open_reticle_switch_menu")
			},
			wm_buy_mod = {
				btn = "BTN_BACK",
				name = "bm_menu_btn_buy_mod",
				prio = 4,
				pc_btn = "toggle_chat",
				callback = callback(self, self, "purchase_weapon_mod_callback")
			},
			wm_clear_mod_preview = {
				btn = "BTN_Y",
				name = "bm_menu_btn_clear_mod_preview",
				prio = 3,
				pc_btn = "menu_preview_item_alt",
				callback = callback(self, self, "clear_weapon_mod_preview_callback")
			},
			wm_customize_gadget = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_customize_gadget",
				callback = callback(self, self, "open_customize_gadget_menu")
			},
			wcs_equip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_equip_weapon_cosmetic",
				callback = callback(self, self, "equip_weapon_color_callback")
			},
			wcs_customize_color = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_customize_weapon_color",
				callback = callback(self, self, "open_customize_weapon_color_menu")
			},
			wcc_equip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_equip_weapon_cosmetic",
				callback = callback(self, self, "equip_weapon_cosmetics_callback")
			},
			wcc_choose = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_choose_weapon_cosmetic",
				callback = callback(self, self, "choose_weapon_cosmetics_callback")
			},
			wcc_remove = {
				btn = "BTN_X",
				name = "bm_menu_btn_remove_weapon_cosmetic",
				prio = 1,
				pc_btn = "menu_remove_item",
				callback = callback(self, self, "remove_weapon_cosmetics_callback")
			},
			wcc_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_weapon_cosmetic",
				prio = 3,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_cosmetic_on_weapon_callback")
			},
			wcc_buy_equip_weapon = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_buy_new_weapon",
				callback = callback(self, self, "buy_equip_weapon_cosmetics_callback")
			},
			wcc_cancel_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_stop_preview_weapon_cosmetic",
				prio = 4,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "cancel_preview_cosmetic_on_weapon_callback")
			},
			wcc_market = {
				btn = "BTN_X",
				name = "bm_menu_btn_buy_tradable",
				prio = 5,
				pc_btn = "menu_remove_item",
				callback = callback(self, self, "purchase_market_cosmetic_on_weapon_callback")
			},
			it_wcc_choose_equip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_equip_weapon_cosmetic",
				callback = callback(self, self, "choose_equip_weapon_cosmetics_callback")
			},
			it_wcc_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_weapon_cosmetic",
				prio = 3,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_weapon_cosmetics_callback")
			},
			it_copen = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_open_container",
				callback = callback(self, self, "start_open_tradable_container_callback")
			},
			it_sell = {
				btn = "BTN_X",
				name = "bm_menu_btn_sell_tradable",
				prio = 4,
				pc_btn = "menu_remove_item",
				callback = callback(self, self, "sell_tradable_item")
			},
			it_wcc_armor_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_armor_skin",
				prio = 3,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_armor_skin_callback")
			},
			a_equip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_equip_armor",
				callback = callback(self, self, "equip_armor_callback")
			},
			a_mod = {
				btn = "BTN_Y",
				name = "bm_menu_btn_customize_armor",
				prio = 2,
				pc_btn = "menu_modify_item",
				callback = callback(self, self, "open_armor_skins_menu_callback")
			},
			as_equip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_equip_armor_skin",
				callback = callback(self, self, "equip_armor_skin_callback")
			},
			as_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_armor_skin",
				prio = 1,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_armor_skin_callback")
			},
			as_workshop = {
				btn = "BTN_STICK_L",
				name = "bm_menu_btn_skin",
				prio = 5,
				pc_btn = "menu_edit_skin",
				callback = callback(self, self, "edit_armor_skin_callback")
			},
			trd_equip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_equip_player_style",
				callback = callback(self, self, "equip_player_style_callback")
			},
			trd_customize = {
				btn = "BTN_Y",
				name = "bm_menu_btn_customize_player_style",
				prio = 2,
				pc_btn = "menu_modify_item",
				callback = callback(self, self, "customize_player_style_callback")
			},
			trd_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_player_style",
				prio = 3,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_player_style_callback")
			},
			trd_mod_equip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_equip_suit_variation",
				callback = callback(self, self, "equip_suit_variation_callback")
			},
			trd_mod_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_suit_variation",
				prio = 2,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_suit_variation_callback")
			},
			m_equip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_equip_mask",
				callback = callback(self, self, "equip_mask_callback")
			},
			m_mod = {
				btn = "BTN_Y",
				name = "bm_menu_btn_mod_mask",
				prio = 2,
				pc_btn = "menu_modify_item",
				callback = callback(self, self, "mask_mods_callback")
			},
			m_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_mask",
				prio = 3,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_mask_callback")
			},
			m_sell = {
				btn = "BTN_X",
				name = "bm_menu_btn_sell_mask",
				prio = 4,
				pc_btn = "menu_remove_item",
				callback = callback(self, self, "sell_mask_callback")
			},
			m_remove = {
				btn = "BTN_X",
				name = "bm_menu_btn_remove_mask",
				prio = 4,
				pc_btn = "menu_remove_item",
				callback = callback(self, self, "remove_mask_callback")
			},
			em_gv = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_buy_new_mask",
				callback = callback(self, self, "choose_mask_global_value_callback")
			},
			em_buy = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_buy_new_mask",
				callback = callback(self, self, "choose_mask_buy_callback")
			},
			em_unlock = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_buy_mask_slot",
				callback = callback(self, self, "choose_mask_slot_unlock_callback")
			},
			em_available_mods = {
				btn = "BTN_Y",
				name = "bm_menu_buy_mask_title",
				prio = 3,
				pc_btn = "menu_preview_item_alt",
				callback = callback(self, self, "show_available_mask_mods_callback")
			},
			mm_choose_textures = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_choose_pattern",
				callback = callback(self, self, "choose_mask_mod_callback", "textures")
			},
			mm_choose_materials = {
				btn = "BTN_A",
				prio = 2,
				name = "bm_menu_choose_material",
				callback = callback(self, self, "choose_mask_mod_callback", "materials")
			},
			mm_choose_colors = {
				btn = "BTN_A",
				prio = 3,
				name = "bm_menu_choose_color",
				callback = callback(self, self, "choose_mask_mod_callback", "colors")
			},
			mm_choose = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_choose_mask_mod",
				callback = callback(self, self, "choose_mask_type_callback")
			},
			mm_buy = {
				btn = "BTN_Y",
				name = "bm_menu_btn_customize_mask",
				prio = 5,
				pc_btn = "menu_modify_item",
				callback = callback(self, self, "buy_customized_mask_callback")
			},
			mm_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_mask",
				prio = 4,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_customized_mask_callback")
			},
			mp_choose = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_choose_mask_mod",
				callback = callback(self, self, "choose_mask_part_callback")
			},
			mp_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_mask",
				prio = 2,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_customized_mask_callback")
			},
			mp_preview_mod = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_mask",
				prio = 2,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_customized_mask_with_mod_callback")
			},
			bm_buy = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_buy_selected_mask",
				callback = callback(self, self, "buy_mask_callback")
			},
			bm_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_mask",
				prio = 2,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_buy_mask_callback")
			},
			bm_sell = {
				btn = "BTN_X",
				name = "bm_menu_btn_sell_mask",
				prio = 4,
				pc_btn = "menu_remove_item",
				callback = callback(self, self, "sell_stashed_mask_callback")
			},
			c_equip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_set_preferred",
				callback = callback(self, self, "set_preferred_character_callback")
			},
			c_swap_slots = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_swap_preferred_slots",
				callback = callback(self, self, "swap_preferred_character_to_slot_callback")
			},
			c_equip_to_slot = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_set_preferred_to_slot",
				callback = callback(self, self, "set_preferred_character_to_slot_callback")
			},
			c_clear_slots = {
				btn = "BTN_X",
				name = "bm_menu_btn_clear_preferred",
				prio = 2,
				pc_btn = "menu_remove_item",
				callback = callback(self, self, "clear_preferred_characters_callback")
			},
			lo_w_equip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_equip_weapon",
				callback = callback(self, self, "equip_weapon_callback")
			},
			lo_d_equip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_equip_deployable",
				callback = callback(self, self, "lo_equip_deployable_callback")
			},
			lo_d_equip_primary = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_equip_primary_deployable",
				callback = callback(self, self, "lo_equip_deployable_callback")
			},
			lo_d_equip_secondary = {
				btn = "BTN_X",
				name = "bm_menu_btn_equip_secondary_deployable",
				prio = 2,
				pc_btn = "menu_remove_item",
				callback = callback(self, self, "lo_equip_deployable_callback_secondary")
			},
			lo_d_unequip = {
				btn = "BTN_X",
				name = "bm_menu_btn_unequip_deployable",
				prio = 1,
				pc_btn = "menu_remove_item",
				callback = callback(self, self, "lo_unequip_deployable_callback")
			},
			lo_mw_equip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_equip_melee_weapon",
				callback = callback(self, self, "lo_equip_melee_weapon_callback")
			},
			lo_mw_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_melee_weapon",
				prio = 2,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_melee_weapon_callback")
			},
			lo_mw_add_favorite = {
				btn = "BTN_Y",
				name = "bm_menu_btn_add_favorite",
				prio = 3,
				pc_btn = "menu_modify_item",
				callback = callback(self, self, "add_melee_weapon_favorite")
			},
			lo_mw_remove_favorite = {
				btn = "BTN_Y",
				name = "bm_menu_btn_remove_favorite",
				prio = 3,
				pc_btn = "menu_modify_item",
				callback = callback(self, self, "remove_melee_weapon_favorite")
			},
			lo_g_equip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_equip_grenade",
				callback = callback(self, self, "lo_equip_grenade_callback")
			},
			lo_g_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_grenade",
				prio = 2,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_grenade_callback")
			},
			custom_select = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_select",
				callback = function ()
				end
			},
			custom_unselect = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_unselect",
				callback = function ()
				end
			},
			ci_unlock = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_unlock_crew_item",
				callback = callback(self, self, "buy_crew_item_callback")
			}
		}

		for btn, data in pairs(BTNS) do
			data.callback = callback(self, self, "overridable_callback", {
				button = btn,
				callback = data.callback
			})
		end

		local get_real_font_sizes = false
		local real_small_font_size = small_font_size

		if get_real_font_sizes then
			local test_text = self._panel:text({
				visible = false,
				font = small_font,
				font_size = small_font_size,
				text = "TeWqjI-" .. managers.localization:get_default_macro("BTN_BOTTOM_L")
			})
			local x, y, w, h = test_text:text_rect()
			real_small_font_size = h

			self._panel:remove(test_text)

			test_text = nil
		end

		self._real_small_font_size = real_small_font_size
		local real_medium_font_size = medium_font_size

		if get_real_font_sizes then
			local test_text = self._panel:text({
				visible = false,
				font = medium_font,
				font_size = medium_font_size,
				text = "TeWqjI-" .. managers.localization:get_default_macro("BTN_BOTTOM_L")
			})
			local x, y, w, h = test_text:text_rect()
			real_medium_font_size = h
			Global.test_text = test_text
		end

		self._real_medium_font_size = real_medium_font_size
		self._info_box_panel_y = info_box_panel:y()
		self._weapon_info_panel = self._panel:panel({
			x = info_box_panel:x(),
			y = info_box_panel:y(),
			w = info_box_panel:w()
		})
		self._detection_panel = self._panel:panel({
			name = "suspicion_panel",
			h = 64,
			layer = 1,
			x = info_box_panel:x(),
			y = info_box_panel:y() + 250,
			w = info_box_panel:w()
		})
		self._btn_panel = self._panel:panel({
			name = "btn_panel",
			h = 136,
			x = info_box_panel:x(),
			w = info_box_panel:w()
		})

		self._weapon_info_panel:set_h(info_box_panel:h() - self._btn_panel:h() - 8 - self._detection_panel:h() - 8)
		self._detection_panel:set_top(self._weapon_info_panel:bottom() + 8)
		self._btn_panel:set_top(self._detection_panel:bottom() + 8)

		self._weapon_info_border = BoxGuiObject:new(self._weapon_info_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
		self._detection_border = BoxGuiObject:new(self._detection_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
		self._button_border = BoxGuiObject:new(self._btn_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})

		if self._data.use_bgs then
			BlackMarketGui.blur_panel(self._weapon_info_panel)
			BlackMarketGui.blur_panel(self._detection_panel)
			BlackMarketGui.blur_panel(self._btn_panel)
		end

		local scale = 0.75
		local detection_ring_left_bg = self._detection_panel:bitmap({
			blend_mode = "add",
			name = "detection_left_bg",
			h = 64,
			w = 64,
			alpha = 0.2,
			texture = "guis/textures/pd2/blackmarket/inv_detection_meter",
			x = 8,
			layer = 1
		})
		local detection_ring_right_bg = self._detection_panel:bitmap({
			blend_mode = "add",
			name = "detection_right_bg",
			h = 64,
			w = 64,
			alpha = 0.2,
			texture = "guis/textures/pd2/blackmarket/inv_detection_meter",
			x = 8,
			layer = 1
		})

		detection_ring_left_bg:set_size(detection_ring_left_bg:w() * scale, detection_ring_left_bg:h() * scale)
		detection_ring_right_bg:set_size(detection_ring_right_bg:w() * scale, detection_ring_right_bg:h() * scale)
		detection_ring_right_bg:set_texture_rect(64, 0, -64, 64)
		detection_ring_left_bg:set_center_y(self._detection_panel:h() / 2)
		detection_ring_right_bg:set_center_y(self._detection_panel:h() / 2)

		local detection_ring_left = self._detection_panel:bitmap({
			blend_mode = "add",
			name = "detection_left",
			h = 64,
			x = 8,
			w = 64,
			texture = "guis/textures/pd2/blackmarket/inv_detection_meter",
			render_template = "VertexColorTexturedRadial",
			layer = 1
		})
		local detection_ring_right = self._detection_panel:bitmap({
			blend_mode = "add",
			name = "detection_right",
			h = 64,
			x = 8,
			w = 64,
			texture = "guis/textures/pd2/blackmarket/inv_detection_meter",
			render_template = "VertexColorTexturedRadial",
			layer = 1
		})

		detection_ring_left:set_size(detection_ring_left:w() * scale, detection_ring_left:h() * scale)
		detection_ring_right:set_size(detection_ring_right:w() * scale, detection_ring_right:h() * scale)
		detection_ring_right:set_texture_rect(64, 0, -64, 64)
		detection_ring_left:set_center_y(self._detection_panel:h() / 2)
		detection_ring_right:set_center_y(self._detection_panel:h() / 2)

		local detection_value = self._detection_panel:text({
			blend_mode = "add",
			name = "detection_value",
			layer = 1,
			font_size = medium_font_size,
			font = medium_font,
			color = tweak_data.screen_colors.text
		})

		detection_value:set_x(detection_ring_left_bg:x() + detection_ring_left_bg:w() / 2 - medium_font_size / 2 + 2)
		detection_value:set_y(detection_ring_left_bg:y() + detection_ring_left_bg:h() / 2 - medium_font_size / 2 + 2)

		local detection_text = self._detection_panel:text({
			blend_mode = "add",
			name = "detection_text",
			layer = 1,
			font_size = small_font_size,
			font = small_font,
			color = tweak_data.screen_colors.text,
			text = utf8.to_upper(managers.localization:text("bm_menu_stats_detection"))
		})

		detection_text:set_left(detection_ring_left:right() + 8)
		detection_text:set_y(detection_ring_left:y() + detection_ring_left_bg:h() / 2 - medium_font_size / 2 + 2)

		self._buttons = self._btn_panel:panel({
			y = 8
		})
		local btn_x = 10

		for btn, btn_data in pairs(BTNS) do
			local new_btn = BlackMarketGuiButtonItem:new(self._buttons, btn_data, btn_x)
			self._btns[btn] = new_btn
		end

		self._armor_info_panel = self._weapon_info_panel:panel({
			layer = 10,
			w = self._weapon_info_panel:w(),
			h = self._weapon_info_panel:h()
		})
		local armor_info_panel = self._armor_info_panel
		local armor_image = armor_info_panel:bitmap({
			texture = "guis/textures/pd2/endscreen/exp_ring",
			name = "armor_image",
			h = 96,
			y = 10,
			w = 96,
			blend_mode = "normal",
			x = 10
		})
		local armor_name = armor_info_panel:text({
			name = "armor_name_text",
			wrap = true,
			word_wrap = true,
			text = "Improved Combined Tactical Vest",
			y = 10,
			layer = 1,
			font_size = medium_font_size,
			font = medium_font,
			color = tweak_data.screen_colors.text,
			x = armor_image:right() + 10,
			w = armor_info_panel:w() - armor_image:right() - 20,
			h = medium_font_size * 2
		})
		local equip_text = armor_info_panel:text({
			name = "armor_equipped",
			layer = 1,
			font_size = small_font_size * 0.9,
			font = small_font,
			color = tweak_data.screen_colors.text,
			text = managers.localization:to_upper_text("bm_menu_equipped"),
			x = armor_image:right() + 10,
			y = armor_name:bottom(),
			w = armor_info_panel:w() - armor_image:right() - 20,
			h = small_font_size
		})
		self._info_texts = {}
		self._info_texts_panel = self._weapon_info_panel:panel({
			x = 10,
			y = 10,
			w = self._weapon_info_panel:w() - 20,
			h = self._weapon_info_panel:h() - 20 - real_small_font_size * 3
		})

		table.insert(self._info_texts, self._info_texts_panel:text({
			text = "",
			name = "info_text_1",
			layer = 1,
			font_size = medium_font_size,
			font = medium_font,
			color = tweak_data.screen_colors.text
		}))
		table.insert(self._info_texts, self._info_texts_panel:text({
			text = "",
			wrap = true,
			name = "info_text_2",
			word_wrap = true,
			layer = 1,
			font_size = small_font_size,
			font = small_font,
			color = tweak_data.screen_colors.text
		}))
		table.insert(self._info_texts, self._info_texts_panel:text({
			name = "info_text_3",
			blend_mode = "add",
			wrap = true,
			word_wrap = true,
			text = "",
			layer = 1,
			font_size = small_font_size,
			font = small_font,
			color = tweak_data.screen_colors.important_1
		}))
		table.insert(self._info_texts, self._info_texts_panel:text({
			text = "",
			wrap = true,
			name = "info_text_4",
			word_wrap = true,
			layer = 1,
			font_size = small_font_size,
			font = small_font,
			color = tweak_data.screen_colors.text
		}))
		table.insert(self._info_texts, self._info_texts_panel:text({
			text = "",
			wrap = true,
			name = "info_text_5",
			word_wrap = true,
			layer = 1,
			font_size = small_font_size,
			font = small_font,
			color = tweak_data.screen_colors.important_1
		}))

		self._info_texts_color = {}
		self._info_texts_bg = {}

		for i, info_text in ipairs(self._info_texts) do
			self._info_texts_color[i] = info_text:color()
			self._info_texts_bg[i] = self._info_texts_panel:rect({
				alpha = 0.2,
				visible = false,
				layer = 0,
				color = Color.black
			})

			self._info_texts_bg[i]:set_shape(info_text:shape())
		end

		local h = real_small_font_size
		local longest_text_w = 0

		if self._data.info_callback then
			self._info_panel = self._panel:panel({
				name = "info_panel",
				layer = 1,
				w = self._btn_panel:w()
			})
			local info_table = self._data.info_callback()

			for i, info in ipairs(info_table) do
				local info_name = info.name or ""
				local info_string = info.text or ""
				local info_color = info.color or tweak_data.screen_colors.text
				local category_text = self._info_panel:text({
					w = 0,
					layer = 1,
					name = "category_" .. tostring(i),
					y = (i - 1) * h,
					h = h,
					font_size = h,
					font = small_font,
					color = tweak_data.screen_colors.text,
					text = utf8.to_upper(managers.localization:text("bm_menu_" .. tostring(info_name)))
				})
				local status_text = self._info_panel:text({
					w = 0,
					layer = 1,
					name = "status_" .. tostring(i),
					y = (i - 1) * h,
					h = h,
					font_size = h,
					font = small_font,
					color = info_color,
					text = utf8.to_upper(managers.localization:text(info_string))
				})

				if info_string == "" then
					category_text:set_color(info_color)
				end

				local _, _, w, _ = category_text:text_rect()

				if longest_text_w < w then
					longest_text_w = w + 10
				end
			end

			for name, text in ipairs(self._info_panel:children()) do
				if string.split(text:name(), "_")[1] == "category" then
					text:set_w(longest_text_w)
					text:set_x(0)
				else
					local _, _, w, _ = text:text_rect()

					text:set_w(w)
					text:set_x(math.round(longest_text_w + 5))
				end
			end
		else
			self._stats_shown = {
				{
					round_value = true,
					name = "magazine",
					stat_name = "extra_ammo"
				},
				{
					round_value = true,
					name = "totalammo",
					stat_name = "total_ammo_mod"
				},
				{
					round_value = true,
					name = "fire_rate"
				},
				{
					name = "damage"
				},
				{
					percent = true,
					name = "spread",
					offset = true,
					revert = true
				},
				{
					percent = true,
					name = "recoil",
					offset = true,
					revert = true
				},
				{
					index = true,
					name = "concealment"
				},
				{
					percent = false,
					name = "suppression",
					offset = true
				}
			}

			table.insert(self._stats_shown, {
				inverted = true,
				name = "reload"
			})

			self._stats_panel = self._weapon_info_panel:panel({
				y = 58,
				x = 10,
				layer = 1,
				w = self._weapon_info_panel:w() - 20,
				h = self._weapon_info_panel:h() - 84
			})
			local panel = self._stats_panel:panel({
				h = 20,
				layer = 1,
				w = self._stats_panel:w()
			})

			panel:rect({
				color = Color.black:with_alpha(0.5)
			})

			self._stats_titles = {
				equip = self._stats_panel:text({
					x = 120,
					layer = 2,
					font_size = small_font_size,
					font = small_font,
					color = tweak_data.screen_colors.text
				}),
				base = self._stats_panel:text({
					alpha = 0.75,
					x = 170,
					layer = 2,
					font_size = small_font_size,
					font = small_font,
					color = tweak_data.screen_colors.text,
					text = utf8.to_upper(managers.localization:text("bm_menu_stats_base"))
				}),
				mod = self._stats_panel:text({
					alpha = 0.75,
					x = 215,
					layer = 2,
					font_size = small_font_size,
					font = small_font,
					color = tweak_data.screen_colors.stats_mods,
					text = utf8.to_upper(managers.localization:text("bm_menu_stats_mod"))
				}),
				skill = self._stats_panel:text({
					alpha = 0.75,
					x = 260,
					layer = 2,
					font_size = small_font_size,
					font = small_font,
					color = tweak_data.screen_colors.resource,
					text = utf8.to_upper(managers.localization:text("bm_menu_stats_skill"))
				}),
				total = self._stats_panel:text({
					x = 200,
					layer = 2,
					font_size = small_font_size,
					font = small_font,
					color = tweak_data.screen_colors.text,
					text = utf8.to_upper(managers.localization:text("bm_menu_chosen"))
				})
			}
			local x = 0
			local y = 20
			local text_panel = nil
			local text_columns = {
				{
					size = 100,
					name = "name"
				},
				{
					align = "right",
					name = "equip",
					blend = "add",
					alpha = 0.75,
					size = 45
				},
				{
					align = "right",
					name = "base",
					blend = "add",
					alpha = 0.75,
					size = 45
				},
				{
					align = "right",
					name = "mods",
					blend = "add",
					alpha = 0.75,
					size = 45,
					color = tweak_data.screen_colors.stats_mods
				},
				{
					size = 45,
					name = "removed",
					blend = "add",
					alpha = 0.75,
					align = "right",
					offset = -40,
					color = tweak_data.screen_colors.important_1,
					font_size = tiny_font_size
				},
				{
					align = "right",
					name = "skill",
					blend = "add",
					alpha = 0.75,
					size = 45,
					color = tweak_data.screen_colors.resource
				},
				{
					size = 45,
					name = "total",
					align = "right"
				}
			}
			self._stats_texts = {}
			self._rweapon_stats_panel = self._stats_panel:panel()

			for i, stat in ipairs(self._stats_shown) do
				panel = self._rweapon_stats_panel:panel({
					name = "weapon_stats",
					h = 20,
					x = 0,
					layer = 1,
					y = y,
					w = self._rweapon_stats_panel:w()
				})

				if math.mod(i, 2) == 0 and not panel:child(tostring(i)) then
					panel:rect({
						name = tostring(i),
						color = Color.black:with_alpha(0.3)
					})
				end

				x = 2
				y = y + 20
				self._stats_texts[stat.name] = {}

				for _, column in ipairs(text_columns) do
					text_panel = panel:panel({
						layer = 0,
						x = x + (column.offset or 0),
						w = column.size,
						h = panel:h()
					})
					self._stats_texts[stat.name][column.name] = text_panel:text({
						layer = 1,
						font_size = column.font_size or small_font_size,
						font = column.font or small_font,
						align = column.align,
						alpha = column.alpha,
						blend_mode = column.blend,
						color = column.color or tweak_data.screen_colors.text,
						y = panel:h() - (column.font_size or small_font_size)
					})
					x = x + column.size + (column.offset or 0)

					if column.name == "total" then
						text_panel:set_x(190)
					end
				end
			end

			self._armor_stats_shown = {
				{
					name = "armor"
				},
				{
					name = "health"
				},
				{
					index = true,
					name = "concealment"
				},
				{
					name = "movement"
				},
				{
					revert = true,
					name = "dodge"
				},
				{
					name = "damage_shake"
				},
				{
					name = "stamina"
				}
			}
			local x = 0
			local y = 20
			local text_panel = nil
			self._armor_stats_texts = {}
			local text_columns = {
				{
					size = 100,
					name = "name"
				},
				{
					align = "right",
					name = "equip",
					blend = "add",
					alpha = 0.75,
					size = 45
				},
				{
					align = "right",
					name = "base",
					blend = "add",
					alpha = 0.75,
					size = 60
				},
				{
					align = "right",
					name = "skill",
					blend = "add",
					alpha = 0.75,
					size = 60,
					color = tweak_data.screen_colors.resource
				},
				{
					size = 45,
					name = "total",
					align = "right"
				}
			}
			self._armor_stats_panel = self._stats_panel:panel()

			for i, stat in ipairs(self._armor_stats_shown) do
				panel = self._armor_stats_panel:panel({
					h = 20,
					x = 0,
					layer = 1,
					y = y,
					w = self._armor_stats_panel:w()
				})

				if math.mod(i, 2) == 0 and not panel:child(tostring(i)) then
					panel:rect({
						name = tostring(i),
						color = Color.black:with_alpha(0.3)
					})
				end

				x = 2
				y = y + 20
				self._armor_stats_texts[stat.name] = {}

				for _, column in ipairs(text_columns) do
					text_panel = panel:panel({
						layer = 0,
						x = x,
						w = column.size,
						h = panel:h()
					})
					self._armor_stats_texts[stat.name][column.name] = text_panel:text({
						layer = 1,
						font_size = small_font_size,
						font = small_font,
						align = column.align,
						alpha = column.alpha,
						blend_mode = column.blend,
						color = column.color or tweak_data.screen_colors.text
					})
					x = x + column.size

					if column.name == "total" then
						text_panel:set_x(190)
					end
				end
			end

			self._mweapon_stats_shown = {
				{
					range = true,
					name = "damage"
				},
				{
					range = true,
					name = "damage_effect",
					multiple_of = "damage"
				},
				{
					inverse = true,
					name = "charge_time",
					num_decimals = 1,
					suffix = managers.localization:text("menu_seconds_suffix_short")
				},
				{
					range = true,
					name = "range"
				},
				{
					index = true,
					name = "concealment"
				}
			}
			local x = 0
			local y = 20
			local text_panel = nil
			self._mweapon_stats_texts = {}
			local text_columns = {
				{
					size = 100,
					name = "name"
				},
				{
					align = "right",
					name = "equip",
					blend = "add",
					alpha = 0.75,
					size = 55
				},
				{
					align = "right",
					name = "base",
					blend = "add",
					alpha = 0.75,
					size = 60
				},
				{
					align = "right",
					name = "skill",
					blend = "add",
					alpha = 0.75,
					size = 65,
					color = tweak_data.screen_colors.resource
				},
				{
					size = 55,
					name = "total",
					align = "right"
				}
			}
			self._mweapon_stats_panel = self._stats_panel:panel()

			for i, stat in ipairs(self._mweapon_stats_shown) do
				panel = self._mweapon_stats_panel:panel({
					h = 20,
					x = 0,
					layer = 1,
					y = y,
					w = self._mweapon_stats_panel:w()
				})

				if math.mod(i, 2) == 0 and not panel:child(tostring(i)) then
					panel:rect({
						name = tostring(i),
						color = Color.black:with_alpha(0.3)
					})
				end

				x = 2
				y = y + 20
				self._mweapon_stats_texts[stat.name] = {}

				for _, column in ipairs(text_columns) do
					text_panel = panel:panel({
						layer = 0,
						x = x,
						w = column.size,
						h = panel:h()
					})
					self._mweapon_stats_texts[stat.name][column.name] = text_panel:text({
						layer = 1,
						font_size = small_font_size,
						font = small_font,
						align = column.align,
						alpha = column.alpha,
						blend_mode = column.blend,
						color = column.color or tweak_data.screen_colors.text
					})
					x = x + column.size

					if column.name == "total" then
						text_panel:set_x(190)
					end
				end
			end

			panel = self._stats_panel:panel({
				name = "modslist_panel",
				layer = 0,
				y = y + 20,
				w = self._stats_panel:w(),
				h = self._stats_panel:h()
			})
			self._stats_text_modslist = panel:text({
				word_wrap = true,
				wrap = true,
				layer = 1,
				font_size = small_font_size,
				font = small_font,
				color = tweak_data.screen_colors.text
			})
		end

		if self._info_panel then
			self._info_panel:set_size(info_box_panel:w() - 20, self._info_panel:num_children() / 2 * h)
			self._info_panel:set_rightbottom(self._panel:w() - 10, self._btn_panel:top() - 10)
		end

		local tab_x = 0

		if (not managers.menu:is_pc_controller() or managers.menu:is_steam_controller()) and #self._tabs > 1 then
			local button = managers.menu:is_steam_controller() and managers.localization:steam_btn("bumper_l") or managers.localization:get_default_macro("BTN_BOTTOM_L")
			local prev_page = self._panel:text({
				y = 0,
				name = "prev_page",
				layer = 2,
				font_size = medium_font_size,
				font = medium_font,
				color = tweak_data.screen_colors.text,
				text = button
			})
			local _, _, w, h = prev_page:text_rect()

			prev_page:set_size(w, h)
			prev_page:set_top(top_padding)
			prev_page:set_left(tab_x)
			prev_page:set_visible(self._selected > 1)
			self._tab_scroll_panel:move(w + 15, 0)
			self._tab_scroll_panel:grow(-(w + 15), 0)
		end

		for _, tab in ipairs(self._tabs) do
			tab_x = tab:set_tab_position(tab_x)
		end

		if (not managers.menu:is_pc_controller() or managers.menu:is_steam_controller()) and #self._tabs > 1 then
			local button = managers.menu:is_steam_controller() and managers.localization:steam_btn("bumper_r") or managers.localization:get_default_macro("BTN_BOTTOM_R")
			local next_page = self._panel:text({
				y = 0,
				name = "next_page",
				layer = 2,
				font_size = medium_font_size,
				font = medium_font,
				color = tweak_data.screen_colors.text,
				text = button
			})
			local _, _, w, h = next_page:text_rect()

			next_page:set_size(w, h)
			next_page:set_top(top_padding)
			next_page:set_right(grid_panel_w)
			next_page:set_visible(self._selected < #self._tabs)
			self._tab_scroll_panel:grow(-(w + 15), 0)
		end

		if managers.menu:is_pc_controller() and not managers.menu:is_steam_controller() and self._tab_scroll_table.panel:w() < self._tab_scroll_table[#self._tab_scroll_table]:right() then
			local prev_page = self._panel:text({
				name = "prev_page",
				w = 0,
				align = "center",
				text = "<",
				y = 0,
				layer = 2,
				font_size = medium_font_size,
				font = medium_font,
				color = tweak_data.screen_colors.button_stage_3
			})
			local _, _, w, h = prev_page:text_rect()

			prev_page:set_size(w, h)
			prev_page:set_top(top_padding)
			prev_page:set_left(0)
			prev_page:set_text(" ")
			self._tab_scroll_panel:move(w + 15, 0)
			self._tab_scroll_panel:grow(-(w + 15), 0)

			local next_page = self._panel:text({
				name = "next_page",
				w = 0,
				align = "center",
				text = ">",
				y = 0,
				layer = 2,
				font_size = medium_font_size,
				font = medium_font,
				color = tweak_data.screen_colors.button_stage_3
			})
			local _, _, w, h = next_page:text_rect()

			next_page:set_size(w, h)
			next_page:set_top(top_padding)
			next_page:set_right(grid_panel_w)

			self._tab_scroll_table.left = prev_page
			self._tab_scroll_table.right = next_page
			self._tab_scroll_table.left_klick = false
			self._tab_scroll_table.right_klick = true

			if self._selected > 1 then
				self._tab_scroll_table.left_klick = true

				self._tab_scroll_table.left:set_text("<")
			else
				self._tab_scroll_table.left_klick = false

				self._tab_scroll_table.left:set_text(" ")
			end

			if self._selected < #self._tab_scroll_table then
				self._tab_scroll_table.right_klick = true

				self._tab_scroll_table.right:set_text(">")
			else
				self._tab_scroll_table.right_klick = false

				self._tab_scroll_table.right:set_text(" ")
			end

			self._tab_scroll_panel:grow(-(w + 15), 0)
		end
	else
		self._select_rect:hide()
	end

	if MenuBackdropGUI then
		local bg_text = self._fullscreen_panel:text({
			vertical = "top",
			h = 90,
			align = "left",
			alpha = 0.4,
			text = self._title_text:text(),
			font_size = massive_font_size,
			font = massive_font,
			color = tweak_data.screen_colors.button_stage_3
		})
		local x, y = managers.gui_data:safe_to_full_16_9(self._title_text:world_x(), self._title_text:world_center_y())

		bg_text:set_world_left(x)
		bg_text:set_world_center_y(y)
		bg_text:move(-13, 9)
		MenuBackdropGUI.animate_bg_text(self, bg_text)

		if managers.menu:is_pc_controller() then
			local bg_back = self._fullscreen_panel:text({
				name = "back_button",
				vertical = "bottom",
				h = 90,
				alpha = 0.4,
				align = "right",
				layer = 0,
				text = utf8.to_upper(managers.localization:text("menu_back")),
				font_size = massive_font_size,
				font = massive_font,
				color = tweak_data.screen_colors.button_stage_3
			})
			local x, y = managers.gui_data:safe_to_full_16_9(self._panel:child("back_button"):world_right(), self._panel:child("back_button"):world_center_y())

			bg_back:set_world_right(x)
			bg_back:set_world_center_y(y)
			bg_back:move(13, -9)
			MenuBackdropGUI.animate_bg_text(self, bg_back)
		end
	end

	if self._selected_slot then
		self:on_slot_selected(self._selected_slot)
	end

	local black_rect = self._data.skip_blur or self._fullscreen_panel:rect({
		layer = 1,
		color = Color(0.4, 0, 0, 0)
	})

	if is_start_page then
		-- Nothing
	end

	if self._data.create_steam_inventory_extra then
		self._indicator_alpha = self._indicator_alpha or managers.network.account:inventory_is_loading() and 1 or 0
		self._indicator = self._panel:bitmap({
			texture = "guis/textures/icon_loading",
			name = "indicator",
			layer = 1,
			alpha = self._indicator_alpha
		})

		self._indicator:set_left(self._title_text:right() + 10)
		self._indicator:set_center_y(self._title_text:center_y())
		self._indicator:animate(function (o)
			local dt = nil

			while true do
				dt = coroutine.yield()

				self._indicator:rotate(180 * dt)

				self._indicator_alpha = math.lerp(self._indicator_alpha, managers.network.account:inventory_is_loading() and 1 or 0, 15 * dt)

				self._indicator:set_alpha(self._indicator_alpha)
			end
		end)

		local info_box_panel = self._panel:child("info_box_panel")
		self._steam_inventory_extra_panel = self._panel:panel({
			h = top_padding
		})

		self._steam_inventory_extra_panel:set_width(info_box_panel:width())
		self._steam_inventory_extra_panel:set_top(info_box_panel:bottom() + 5)
		self._steam_inventory_extra_panel:set_world_right(self._tabs[self._selected]._grid_panel:world_right())

		self._steam_inventory_extra_data = {}
		local extra_data = self._steam_inventory_extra_data
		extra_data.choices = {}

		for _, name in ipairs(tweak_data.gui.tradable_inventory_sort_list) do
			table.insert(extra_data.choices, managers.localization:to_upper_text("bm_menu_ti_sort_option", {
				sort = managers.localization:text("bm_menu_ti_" .. name)
			}))
		end

		local gui_panel = self._steam_inventory_extra_panel:panel({
			h = medium_font_size + 5
		})
		extra_data.bg = gui_panel:rect({
			alpha = 0.5,
			color = Color.black:with_alpha(0.5)
		})

		BoxGuiObject:new(gui_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})

		local choice_panel = gui_panel:panel({
			layer = 1
		})
		local choice_text = choice_panel:text({
			halign = "center",
			vertical = "center",
			layer = 1,
			align = "center",
			blend_mode = "add",
			y = 0,
			x = 0,
			valign = "center",
			font_size = small_font_size,
			font = small_font,
			color = tweak_data.screen_colors.button_stage_2,
			text = extra_data.choices[Global.blackmarket_manager.tradable_inventory_sort or 1],
			render_template = Idstring("VertexColorTextured")
		})
		local arrow_left, arrow_right = nil

		if managers.menu:is_pc_controller() and not managers.menu:is_steam_controller() then
			local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")
			arrow_left = gui_panel:bitmap({
				texture = "guis/textures/menu_arrows",
				layer = 1,
				blend_mode = "add",
				visible = true,
				texture_rect = {
					24,
					0,
					24,
					24
				},
				color = tweak_data.screen_colors.button_stage_3
			})
			arrow_right = gui_panel:bitmap({
				texture = "guis/textures/menu_arrows",
				layer = 1,
				blend_mode = "add",
				visible = true,
				rotation = 180,
				texture_rect = {
					24,
					0,
					24,
					24
				},
				color = tweak_data.screen_colors.button_stage_3
			})
		else
			local BTN_TOP_L = managers.menu:is_steam_controller() and managers.localization:steam_btn("trigger_l") or managers.localization:get_default_macro("BTN_TOP_L")
			local BTN_TOP_R = managers.menu:is_steam_controller() and managers.localization:steam_btn("trigger_r") or managers.localization:get_default_macro("BTN_TOP_R")
			arrow_left = gui_panel:text({
				blend_mode = "add",
				layer = 1,
				text = BTN_TOP_L,
				color = managers.menu:is_steam_controller() and tweak_data.screen_colors.button_stage_3,
				font = small_font,
				font_size = small_font_size
			})
			arrow_right = gui_panel:text({
				blend_mode = "add",
				layer = 1,
				text = BTN_TOP_R,
				color = managers.menu:is_steam_controller() and tweak_data.screen_colors.button_stage_3,
				font = small_font,
				font_size = small_font_size
			})

			self:make_fine_text(arrow_left)
			self:make_fine_text(arrow_right)
		end

		arrow_left:set_left(5)
		arrow_left:set_center_y(gui_panel:h() / 2)
		arrow_right:set_right(gui_panel:w() - 5)
		arrow_right:set_center_y(gui_panel:h() / 2)

		extra_data.gui_panel = gui_panel
		extra_data.arrow_left = arrow_left
		extra_data.arrow_right = arrow_right
		extra_data.choice_text = choice_text
		extra_data.arrow_left_highlighted = false
		extra_data.arrow_right_highlighted = false
	end

	self:set_tab_positions()
	self:_round_everything()

	self._in_setup = nil
end

function BlackMarketGui:_update_borders()
	local wh = self._weapon_info_panel:h()
	local dy = self._detection_panel:visible() and self._detection_panel:y()
	local dh = self._detection_panel:visible() and self._detection_panel:h()
	local by = self._btn_panel:y()
	local bh = self._btn_panel:h()

	self._btn_panel:set_visible(self._button_count > 0 and true or false)
	self._btn_panel:set_h(20 * self._button_count + 16)

	local info_box_panel = self._panel:child("info_box_panel")
	local weapon_info_height = info_box_panel:h() - (self._button_count > 0 and self._btn_panel:h() + 8 or 0) - (self._detection_panel:visible() and self._detection_panel:h() + 8 or 0)

	if self._node:parameters() and self._node:parameters().scene_state == "blackmarket_crafting" then
		weapon_info_height = weapon_info_height + self._info_box_panel_y

		self._weapon_info_panel:set_y(0)
	else
		self._weapon_info_panel:set_y(self._info_box_panel_y)
	end

	self._weapon_info_panel:set_h(weapon_info_height)
	self._info_texts_panel:set_h(weapon_info_height - 20)

	if self._detection_panel:visible() then
		self._detection_panel:set_top(self._weapon_info_panel:bottom() + 8)

		if dh ~= self._detection_panel:h() or dy ~= self._detection_panel:y() then
			self._detection_border:create_sides(self._detection_panel, {
				sides = {
					1,
					1,
					1,
					1
				}
			})
		end
	end

	self._btn_panel:set_top((self._detection_panel:visible() and self._detection_panel:bottom() or self._weapon_info_panel:bottom()) + 8)

	if wh ~= self._weapon_info_panel:h() then
		self._weapon_info_border:create_sides(self._weapon_info_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
	end

	if bh ~= self._btn_panel:h() or by ~= self._btn_panel:y() then
		self._button_border:create_sides(self._btn_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
	end
end

function BlackMarketGui:_set_detection(value, maxed_reached, min_reached)
	local detection_value = self._detection_panel:child("detection_value")

	detection_value:set_text(math.round(value * 100))

	local detection_ring_left_bg = self._detection_panel:child("detection_left_bg")
	local _, _, w, _ = detection_value:text_rect()

	detection_value:set_x(detection_ring_left_bg:x() + detection_ring_left_bg:w() / 2 - w / 2)
	self._detection_panel:child("detection_left"):set_color(Color(0.5 + value * 0.5, 1, 1))
	self._detection_panel:child("detection_right"):set_color(Color(0.5 + value * 0.5, 1, 1))

	local detection_text = self._detection_panel:child("detection_text")

	if maxed_reached then
		detection_text:set_text(utf8.to_upper(managers.localization:text("bm_menu_stats_max_detection")))
		detection_text:set_color(Color(255, 255, 42, 0) / 255)
		detection_value:set_color(Color(255, 255, 42, 0) / 255)
	elseif min_reached then
		detection_text:set_text(utf8.to_upper(managers.localization:text("bm_menu_stats_min_detection")))
		detection_text:set_color(tweak_data.screen_colors.ghost_color)
		detection_value:set_color(tweak_data.screen_colors.text)
	else
		detection_text:set_text(utf8.to_upper(managers.localization:text("bm_menu_stats_detection")))
		detection_text:set_color(tweak_data.screen_colors.text)
		detection_value:set_color(tweak_data.screen_colors.text)
	end
end

function BlackMarketGui:_get_melee_weapon_stats(name)
	local base_stats = {}
	local mods_stats = {}
	local skill_stats = {}
	local stats_data = managers.blackmarket:get_melee_weapon_stats(name)
	local multiple_of = {}
	local has_non_special = managers.player:has_category_upgrade("player", "non_special_melee_multiplier")
	local has_special = managers.player:has_category_upgrade("player", "melee_damage_multiplier")
	local non_special = managers.player:upgrade_value("player", "non_special_melee_multiplier", 1) - 1
	local special = managers.player:upgrade_value("player", "melee_damage_multiplier", 1) - 1

	for i, stat in ipairs(self._mweapon_stats_shown) do
		local skip_rounding = stat.num_decimals
		base_stats[stat.name] = {
			value = 0,
			max_value = 0,
			min_value = 0
		}
		mods_stats[stat.name] = {
			value = 0,
			max_value = 0,
			min_value = 0
		}
		skill_stats[stat.name] = {
			value = 0,
			max_value = 0,
			min_value = 0
		}

		if stat.name == "damage" then
			local base_min = stats_data.min_damage * tweak_data.gui.stats_present_multiplier
			local base_max = stats_data.max_damage * tweak_data.gui.stats_present_multiplier
			local dmg_mul = managers.player:upgrade_value("player", "melee_" .. tostring(tweak_data.blackmarket.melee_weapons[name].stats.weapon_type) .. "_damage_multiplier", 1)
			local skill_mul = dmg_mul * ((has_non_special and has_special and math.max(non_special, special) or 0) + 1) - 1
			local skill_min = skill_mul
			local skill_max = skill_mul
			base_stats[stat.name] = {
				min_value = base_min,
				max_value = base_max,
				value = (base_min + base_max) / 2
			}
			skill_stats[stat.name] = {
				min_value = skill_min,
				max_value = skill_max,
				value = (skill_min + skill_max) / 2,
				skill_in_effect = skill_min > 0 or skill_max > 0
			}
		elseif stat.name == "damage_effect" then
			local base_min = stats_data.min_damage_effect
			local base_max = stats_data.max_damage_effect
			base_stats[stat.name] = {
				min_value = base_min,
				max_value = base_max,
				value = (base_min + base_max) / 2
			}
			local dmg_mul = managers.player:upgrade_value("player", "melee_" .. tostring(tweak_data.blackmarket.melee_weapons[name].stats.weapon_type) .. "_damage_multiplier", 1) - 1
			local gst_skill = managers.player:upgrade_value("player", "melee_knockdown_mul", 1) - 1
			local skill_mul = (1 + dmg_mul) * (1 + gst_skill) - 1
			local skill_min = skill_mul
			local skill_max = skill_mul
			skill_stats[stat.name] = {
				skill_min = skill_min,
				skill_max = skill_max,
				min_value = skill_min,
				max_value = skill_max,
				value = (skill_min + skill_max) / 2,
				skill_in_effect = skill_min > 0 or skill_max > 0
			}
		elseif stat.name == "charge_time" then
			local base = stats_data.charge_time
			base_stats[stat.name] = {
				value = base,
				min_value = base,
				max_value = base
			}
		elseif stat.name == "range" then
			local base_min = stats_data.range
			local base_max = stats_data.range
			base_stats[stat.name] = {
				min_value = base_min,
				max_value = base_max,
				value = (base_min + base_max) / 2
			}
		elseif stat.name == "concealment" then
			local base = managers.blackmarket:_calculate_melee_weapon_concealment(name)
			local skill = managers.blackmarket:concealment_modifier("melee_weapons")
			base_stats[stat.name] = {
				min_value = base,
				max_value = base,
				value = base
			}
			skill_stats[stat.name] = {
				min_value = skill,
				max_value = skill,
				value = skill,
				skill_in_effect = skill > 0
			}
		end

		if stat.multiple_of then
			table.insert(multiple_of, {
				stat.name,
				stat.multiple_of
			})
		end

		base_stats[stat.name].real_value = base_stats[stat.name].value
		mods_stats[stat.name].real_value = mods_stats[stat.name].value
		skill_stats[stat.name].real_value = skill_stats[stat.name].value
		base_stats[stat.name].real_min_value = base_stats[stat.name].min_value
		mods_stats[stat.name].real_min_value = mods_stats[stat.name].min_value
		skill_stats[stat.name].real_min_value = skill_stats[stat.name].min_value
		base_stats[stat.name].real_max_value = base_stats[stat.name].max_value
		mods_stats[stat.name].real_max_value = mods_stats[stat.name].max_value
		skill_stats[stat.name].real_max_value = skill_stats[stat.name].max_value
	end

	for i, data in ipairs(multiple_of) do
		local multiplier = data[1]
		local stat = data[2]
		base_stats[multiplier].min_value = base_stats[stat].real_min_value * base_stats[multiplier].real_min_value
		base_stats[multiplier].max_value = base_stats[stat].real_max_value * base_stats[multiplier].real_max_value
		base_stats[multiplier].value = (base_stats[multiplier].min_value + base_stats[multiplier].max_value) / 2
	end

	for i, stat in ipairs(self._mweapon_stats_shown) do
		if not stat.index then
			if skill_stats[stat.name].value and base_stats[stat.name].value then
				skill_stats[stat.name].value = base_stats[stat.name].value * skill_stats[stat.name].value
				base_stats[stat.name].value = base_stats[stat.name].value
			end

			if skill_stats[stat.name].min_value and base_stats[stat.name].min_value then
				skill_stats[stat.name].min_value = base_stats[stat.name].min_value * skill_stats[stat.name].min_value
				base_stats[stat.name].min_value = base_stats[stat.name].min_value
			end

			if skill_stats[stat.name].max_value and base_stats[stat.name].max_value then
				skill_stats[stat.name].max_value = base_stats[stat.name].max_value * skill_stats[stat.name].max_value
				base_stats[stat.name].max_value = base_stats[stat.name].max_value
			end
		end
	end

	return base_stats, mods_stats, skill_stats
end

function BlackMarketGui:_get_armor_stats(name)
	local base_stats = {}
	local mods_stats = {}
	local skill_stats = {}
	local detection_risk = managers.blackmarket:get_suspicion_offset_from_custom_data({
		armors = name
	}, tweak_data.player.SUSPICION_OFFSET_LERP or 0.75)
	detection_risk = math.round(detection_risk * 100)
	local bm_armor_tweak = tweak_data.blackmarket.armors[name]
	local upgrade_level = bm_armor_tweak.upgrade_level

	for i, stat in ipairs(self._armor_stats_shown) do
		base_stats[stat.name] = {
			value = 0
		}
		mods_stats[stat.name] = {
			value = 0
		}
		skill_stats[stat.name] = {
			value = 0
		}

		if stat.name == "armor" then
			local base = tweak_data.player.damage.ARMOR_INIT
			local mod = managers.player:body_armor_value("armor", upgrade_level)
			base_stats[stat.name] = {
				value = (base + mod) * tweak_data.gui.stats_present_multiplier
			}
			skill_stats[stat.name] = {
				value = (base_stats[stat.name].value + managers.player:body_armor_skill_addend(name) * tweak_data.gui.stats_present_multiplier) * managers.player:body_armor_skill_multiplier(name) - base_stats[stat.name].value
			}
		elseif stat.name == "health" then
			local base = tweak_data.player.damage.HEALTH_INIT
			local mod = managers.player:health_skill_addend()
			base_stats[stat.name] = {
				value = (base + mod) * tweak_data.gui.stats_present_multiplier
			}
			skill_stats[stat.name] = {
				value = base_stats[stat.name].value * managers.player:health_skill_multiplier() - base_stats[stat.name].value
			}
		elseif stat.name == "concealment" then
			base_stats[stat.name] = {
				value = managers.player:body_armor_value("concealment", upgrade_level)
			}
			skill_stats[stat.name] = {
				value = managers.blackmarket:concealment_modifier("armors", upgrade_level)
			}
		elseif stat.name == "movement" then
			local base = tweak_data.player.movement_state.standard.movement.speed.STANDARD_MAX / 100 * tweak_data.gui.stats_present_multiplier
			local movement_penalty = managers.player:body_armor_value("movement", upgrade_level)
			local base_value = movement_penalty * base
			base_stats[stat.name] = {
				value = base_value
			}
			local skill_mod = managers.player:movement_speed_multiplier(false, false, upgrade_level, 1)
			local skill_value = skill_mod * base - base_value
			skill_stats[stat.name] = {
				value = skill_value,
				skill_in_effect = skill_value > 0
			}
		elseif stat.name == "dodge" then
			local base = 0
			local mod = managers.player:body_armor_value("dodge", upgrade_level)
			base_stats[stat.name] = {
				value = (base + mod) * 100
			}
			skill_stats[stat.name] = {
				value = managers.player:skill_dodge_chance(false, false, false, name, detection_risk) * 100
			}
		elseif stat.name == "damage_shake" then
			local base = tweak_data.gui.armor_damage_shake_base
			local mod = math.max(managers.player:body_armor_value("damage_shake", upgrade_level, nil, 1), 0.01)
			local skill = math.max(managers.player:upgrade_value("player", "damage_shake_multiplier", 1), 0.01)
			local base_value = base
			local mod_value = base / mod - base_value
			local skill_value = base / mod / skill - base_value - mod_value + managers.player:upgrade_value("player", "damage_shake_addend", 0)
			base_stats[stat.name] = {
				value = (base_value + mod_value) * tweak_data.gui.stats_present_multiplier
			}
			skill_stats[stat.name] = {
				value = skill_value * tweak_data.gui.stats_present_multiplier
			}
		elseif stat.name == "stamina" then
			local stamina_data = tweak_data.player.movement_state.stamina
			local base = stamina_data.STAMINA_INIT
			local mod = managers.player:body_armor_value("stamina", upgrade_level)
			local skill = managers.player:stamina_multiplier()
			local base_value = base
			local mod_value = base * mod - base_value
			local skill_value = base * mod * skill - base_value - mod_value
			base_stats[stat.name] = {
				value = base_value + mod_value
			}
			skill_stats[stat.name] = {
				value = skill_value
			}
		end

		skill_stats[stat.name].skill_in_effect = skill_stats[stat.name].skill_in_effect or skill_stats[stat.name].value ~= 0
	end

	if managers.player:has_category_upgrade("player", "armor_to_health_conversion") then
		local conversion_ratio = managers.player:upgrade_value("player", "armor_to_health_conversion") * 0.01
		local converted_armor = (base_stats.armor.value + skill_stats.armor.value) * conversion_ratio
		local skill_in_effect = converted_armor ~= 0
		skill_stats.armor.value = skill_stats.armor.value - converted_armor
		skill_stats.health.value = skill_stats.health.value + converted_armor
		skill_stats.armor.skill_in_effect = skill_in_effect
		skill_stats.health.skill_in_effect = skill_in_effect
	end

	return base_stats, mods_stats, skill_stats
end

function BlackMarketGui:hide_melee_weapon_stats()
	for _, stat in ipairs(self._mweapon_stats_shown) do
		self._mweapon_stats_texts[stat.name].name:set_text("")
		self._mweapon_stats_texts[stat.name].equip:set_text("")
		self._mweapon_stats_texts[stat.name].base:set_text("")
		self._mweapon_stats_texts[stat.name].skill:set_text("")
		self._mweapon_stats_texts[stat.name].total:set_text("")
	end
end

function BlackMarketGui:hide_armor_stats()
	for _, stat in ipairs(self._armor_stats_shown) do
		self._armor_stats_texts[stat.name].name:set_text("")
		self._armor_stats_texts[stat.name].equip:set_text("")
		self._armor_stats_texts[stat.name].base:set_text("")
		self._armor_stats_texts[stat.name].skill:set_text("")
		self._armor_stats_texts[stat.name].total:set_text("")
	end
end

function BlackMarketGui:hide_weapon_stats()
	for _, stat in ipairs(self._stats_shown) do
		self._stats_texts[stat.name].name:set_text("")
		self._stats_texts[stat.name].equip:set_text("")
		self._stats_texts[stat.name].base:set_text("")
		self._stats_texts[stat.name].mods:set_text("")
		self._stats_texts[stat.name].skill:set_text("")
		self._stats_texts[stat.name].total:set_text("")
		self._stats_texts[stat.name].removed:set_text("")
	end
end

function BlackMarketGui:set_stats_titles(...)
	local stat_title_changes = {
		...
	}

	for i, stat_title in ipairs(stat_title_changes) do
		local name = stat_title.name
		local text = stat_title.text or stat_title.text_id and managers.localization:to_upper_text(stat_title.text_id) or false
		local color = stat_title.color or false
		local alpha = stat_title.alpha or false
		local visible = stat_title.show or stat_title.visible or not stat_title.hide or false
		local x = stat_title.x or false
		local y = stat_title.y or false

		if self._stats_titles[name] then
			if text then
				self._stats_titles[name]:set_text(text)
			end

			if color then
				self._stats_titles[name]:set_color(color)
			end

			if alpha then
				self._stats_titles[name]:set_alpha(alpha)
			end

			if x then
				self._stats_titles[name]:set_x(x)
			end

			if y then
				self._stats_titles[name]:set_y(y)
			end

			self._stats_titles[name]:set_visible(visible)
		end
	end
end

function BlackMarketGui:set_weapons_stats_columns()
	local x = 0
	local text_panel = nil
	local text_columns = {
		{
			size = 100,
			name = "name"
		},
		{
			align = "right",
			name = "equip",
			blend = "add",
			alpha = 0.75,
			size = 45
		},
		{
			align = "right",
			name = "base",
			blend = "add",
			alpha = 0.75,
			size = 45
		},
		{
			align = "right",
			name = "mods",
			blend = "add",
			alpha = 0.75,
			size = 45,
			color = tweak_data.screen_colors.stats_mods
		},
		{
			align = "right",
			name = "skill",
			blend = "add",
			alpha = 0.75,
			size = 45,
			color = tweak_data.screen_colors.resource
		},
		{
			size = 45,
			name = "total",
			align = "right"
		}
	}

	for i, stat in ipairs(self._stats_shown) do
		x = 2

		for _, column in ipairs(text_columns) do
			text_panel = self._stats_texts[stat.name][column.name]:parent()

			text_panel:set_width(column.size)
			text_panel:set_x(x)

			x = x + column.size

			if column.name == "total" then
				text_panel:set_x(190)
			end
		end
	end
end

function BlackMarketGui:set_weapon_mods_stats_columns()
	local x = 0
	local text_panel = nil
	local text_columns = {
		{
			size = 100,
			name = "name"
		},
		{
			align = "right",
			name = "equip",
			blend = "add",
			alpha = 0.75,
			size = 65
		},
		{
			align = "right",
			name = "base",
			blend = "add",
			alpha = 0.75,
			size = 45
		},
		{
			align = "right",
			name = "mods",
			blend = "add",
			alpha = 0.75,
			size = 25,
			color = tweak_data.screen_colors.stats_mods
		},
		{
			align = "right",
			name = "skill",
			blend = "add",
			alpha = 0.75,
			size = 45,
			color = tweak_data.screen_colors.resource
		},
		{
			size = 45,
			name = "total",
			align = "right"
		}
	}

	for i, stat in ipairs(self._stats_shown) do
		x = 2

		for _, column in ipairs(text_columns) do
			text_panel = self._stats_texts[stat.name][column.name]:parent()

			text_panel:set_width(column.size)
			text_panel:set_x(x)

			x = x + column.size

			if column.name == "total" then
				text_panel:set_x(190)
			end
		end
	end
end

function BlackMarketGui:show_stats()
	if not self._stats_panel or not self._rweapon_stats_panel or not self._armor_stats_panel or not self._mweapon_stats_panel then
		return
	end

	self._stats_panel:hide()
	self._rweapon_stats_panel:hide()
	self._armor_stats_panel:hide()
	self._mweapon_stats_panel:hide()

	if not self._slot_data then
		return
	end

	if not self._slot_data.comparision_data then
		return
	end

	local weapon = managers.blackmarket:get_crafted_category_slot(self._slot_data.category, self._slot_data.slot)
	local name = weapon and weapon.weapon_id or self._slot_data.name
	local category = self._slot_data.category
	local slot = self._slot_data.slot
	local hide_stats = false
	local value = 0
	local tweak_stats = tweak_data.weapon.stats
	local modifier_stats = tweak_data.weapon[name] and tweak_data.weapon[name].stats_modifiers

	if self._slot_data.dont_compare_stats then
		local selection_index = tweak_data:get_raw_value("weapon", self._slot_data.weapon_id, "use_data", "selection_index") or 1
		local category = selection_index == 1 and "secondaries" or "primaries"
		modifier_stats = tweak_data.weapon[self._slot_data.weapon_id] and tweak_data.weapon[self._slot_data.weapon_id].stats_modifiers
		local base_stats, mods_stats, skill_stats = WeaponDescription._get_stats(self._slot_data.weapon_id, nil, nil, self._slot_data.default_blueprint)

		self:set_weapons_stats_columns()
		self._rweapon_stats_panel:show()
		self:hide_armor_stats()
		self:hide_melee_weapon_stats()
		self:set_stats_titles({
			x = 170,
			name = "base"
		}, {
			name = "mod",
			x = 215,
			text_id = "bm_menu_stats_mod",
			color = tweak_data.screen_colors.stats_mods
		}, {
			alpha = 0.75,
			name = "skill"
		})

		for _, title in pairs(self._stats_titles) do
			title:show()
		end

		self:set_stats_titles({
			hide = true,
			name = "total"
		}, {
			alpha = 1,
			name = "equip",
			x = 120,
			text_id = "bm_menu_stats_total"
		})

		for _, stat in ipairs(self._stats_shown) do
			self._stats_texts[stat.name].name:set_text(utf8.to_upper(managers.localization:text("bm_menu_" .. stat.name)))

			value = math.max(base_stats[stat.name].value + mods_stats[stat.name].value + skill_stats[stat.name].value, 0)
			local base = base_stats[stat.name].value

			self._stats_texts[stat.name].equip:set_alpha(1)
			self._stats_texts[stat.name].equip:set_text(format_round(value, stat.round_value))
			self._stats_texts[stat.name].base:set_text(format_round(base, stat.round_value))
			self._stats_texts[stat.name].mods:set_text(mods_stats[stat.name].value == 0 and "" or (mods_stats[stat.name].value > 0 and "+" or "") .. format_round(mods_stats[stat.name].value, stat.round_value))
			self._stats_texts[stat.name].skill:set_text(skill_stats[stat.name].skill_in_effect and (skill_stats[stat.name].value > 0 and "+" or "") .. format_round(skill_stats[stat.name].value, stat.round_value) or "")
			self._stats_texts[stat.name].total:set_text("")
			self._stats_texts[stat.name].base:set_alpha(0.75)
			self._stats_texts[stat.name].mods:set_alpha(0.75)
			self._stats_texts[stat.name].skill:set_alpha(0.75)

			if base < value then
				self._stats_texts[stat.name].equip:set_color(stat.inverted and tweak_data.screen_colors.stats_negative or tweak_data.screen_colors.stats_positive)
			elseif value < base then
				self._stats_texts[stat.name].equip:set_color(stat.inverted and tweak_data.screen_colors.stats_positive or tweak_data.screen_colors.stats_negative)
			else
				self._stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.text)
			end

			self._stats_texts[stat.name].skill:set_color(tweak_data.screen_colors.resource)
			self._stats_texts[stat.name].total:set_color(tweak_data.screen_colors.text)

			if stat.percent then
				if math.round(value) >= 100 then
					self._stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.stat_maxed)
				end
			elseif stat.index then
				-- Nothing
			elseif tweak_stats[stat.name] then
				local without_skill = math.round(base_stats[stat.name].value + mods_stats[stat.name].value)
				local max_stat = math.max(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier * (modifier_stats and modifier_stats[stat.name] or 1)

				if stat.offset then
					local offset = math.min(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier * (modifier_stats and modifier_stats[stat.name] or 1)
					max_stat = max_stat - offset
				end

				if without_skill >= max_stat then
					self._stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.stat_maxed)
				end
			end
		end
	elseif tweak_data.weapon[self._slot_data.name] or self._slot_data.default_blueprint then
		self:set_weapons_stats_columns()

		local equipped_item = managers.blackmarket:equipped_item(category)
		local equipped_slot = self._slot_data.equipped_slot or managers.blackmarket:equipped_weapon_slot(category)
		local equipped_name = self._slot_data.equipped_name or equipped_item.weapon_id

		if self._slot_data.default_blueprint then
			equipped_slot = slot
			equipped_name = name
		end

		local equip_base_stats, equip_mods_stats, equip_skill_stats = WeaponDescription._get_stats(equipped_name, category, equipped_slot)
		local base_stats, mods_stats, skill_stats = WeaponDescription._get_stats(name, category, slot, self._slot_data.default_blueprint)

		self._rweapon_stats_panel:show()
		self:hide_armor_stats()
		self:hide_melee_weapon_stats()
		self:set_stats_titles({
			x = 170,
			name = "base"
		}, {
			alpha = 0.75,
			name = "mod",
			text_id = "bm_menu_stats_mod",
			x = 215,
			color = tweak_data.screen_colors.stats_mods
		}, {
			alpha = 0.75,
			name = "skill"
		})

		if slot ~= equipped_slot then
			for _, title in pairs(self._stats_titles) do
				title:hide()
			end

			self:set_stats_titles({
				show = true,
				name = "total"
			}, {
				name = "equip",
				text_id = "bm_menu_equipped",
				alpha = 0.75,
				x = 105,
				show = true
			})
		else
			for _, title in pairs(self._stats_titles) do
				title:show()
			end

			self:set_stats_titles({
				hide = true,
				name = "total"
			}, {
				alpha = 1,
				name = "equip",
				x = 120,
				text_id = "bm_menu_stats_total"
			})
		end

		for _, stat in ipairs(self._stats_shown) do
			self._stats_texts[stat.name].name:set_text(utf8.to_upper(managers.localization:text("bm_menu_" .. stat.name)))

			value = math.max(base_stats[stat.name].value + mods_stats[stat.name].value + skill_stats[stat.name].value, 0)

			if slot == equipped_slot then
				local base = base_stats[stat.name].value

				self._stats_texts[stat.name].equip:set_alpha(1)
				self._stats_texts[stat.name].equip:set_text(format_round(value, stat.round_value))
				self._stats_texts[stat.name].base:set_text(format_round(base, stat.round_value))
				self._stats_texts[stat.name].mods:set_text(mods_stats[stat.name].value == 0 and "" or (mods_stats[stat.name].value > 0 and "+" or "") .. format_round(mods_stats[stat.name].value, stat.round_value))
				self._stats_texts[stat.name].skill:set_text(skill_stats[stat.name].skill_in_effect and (skill_stats[stat.name].value > 0 and "+" or "") .. format_round(skill_stats[stat.name].value, stat.round_value) or "")
				self._stats_texts[stat.name].total:set_text("")
				self._stats_texts[stat.name].removed:set_text("")
				self._stats_texts[stat.name].base:set_alpha(0.75)
				self._stats_texts[stat.name].mods:set_alpha(0.75)
				self._stats_texts[stat.name].skill:set_alpha(0.75)

				if base < value then
					self._stats_texts[stat.name].equip:set_color(stat.inverted and tweak_data.screen_colors.stats_negative or tweak_data.screen_colors.stats_positive)
				elseif value < base then
					self._stats_texts[stat.name].equip:set_color(stat.inverted and tweak_data.screen_colors.stats_positive or tweak_data.screen_colors.stats_negative)
				else
					self._stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.text)
				end

				self._stats_texts[stat.name].skill:set_color(tweak_data.screen_colors.resource)
				self._stats_texts[stat.name].total:set_color(tweak_data.screen_colors.text)

				if stat.percent then
					if math.round(value) >= 100 then
						self._stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.stat_maxed)
					end
				elseif stat.index then
					-- Nothing
				elseif tweak_stats[stat.name] then
					local without_skill = math.round(base_stats[stat.name].value + mods_stats[stat.name].value)
					local max_stat = math.max(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier * (modifier_stats and modifier_stats[stat.name] or 1)

					if stat.offset then
						local offset = math.min(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier * (modifier_stats and modifier_stats[stat.name] or 1)
						max_stat = max_stat - offset
					end

					if without_skill >= max_stat then
						self._stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.stat_maxed)
					end
				end
			else
				local equip = math.max(equip_base_stats[stat.name].value + equip_mods_stats[stat.name].value + equip_skill_stats[stat.name].value, 0)

				self._stats_texts[stat.name].equip:set_alpha(0.75)
				self._stats_texts[stat.name].equip:set_text(format_round(equip, stat.round_value))
				self._stats_texts[stat.name].base:set_text("")
				self._stats_texts[stat.name].mods:set_text("")
				self._stats_texts[stat.name].skill:set_text("")
				self._stats_texts[stat.name].removed:set_text("")
				self._stats_texts[stat.name].total:set_text(format_round(value, stat.round_value))

				if equip < value then
					self._stats_texts[stat.name].total:set_color(stat.inverted and tweak_data.screen_colors.stats_negative or tweak_data.screen_colors.stats_positive)
				elseif value < equip then
					self._stats_texts[stat.name].total:set_color(stat.inverted and tweak_data.screen_colors.stats_positive or tweak_data.screen_colors.stats_negative)
				else
					self._stats_texts[stat.name].total:set_color(tweak_data.screen_colors.text)
				end

				self._stats_texts[stat.name].skill:set_color(tweak_data.screen_colors.resource)
				self._stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.text)

				if stat.percent then
					if math.round(value) >= 100 then
						self._stats_texts[stat.name].total:set_color(tweak_data.screen_colors.stat_maxed)
					end
				elseif stat.index then
					-- Nothing
				elseif tweak_stats[stat.name] then
					local without_skill = math.round(base_stats[stat.name].value + mods_stats[stat.name].value)
					local max_stat = math.max(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier * (modifier_stats and modifier_stats[stat.name] or 1)

					if stat.offset then
						local offset = math.min(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier * (modifier_stats and modifier_stats[stat.name] or 1)
						max_stat = max_stat - offset
					end

					if without_skill >= max_stat then
						self._stats_texts[stat.name].total:set_color(tweak_data.screen_colors.stat_maxed)
					end
				end
			end
		end
	elseif tweak_data.blackmarket.armors[self._slot_data.name] then
		local equipped_item = managers.blackmarket:equipped_item(category)
		local equipped_slot = managers.blackmarket:equipped_armor_slot()
		local equip_base_stats, equip_mods_stats, equip_skill_stats = self:_get_armor_stats(equipped_item)
		local base_stats, mods_stats, skill_stats = self:_get_armor_stats(self._slot_data.name)

		self._armor_stats_panel:show()
		self:hide_weapon_stats()
		self:hide_melee_weapon_stats()
		self:set_stats_titles({
			x = 185,
			name = "base"
		}, {
			name = "mod",
			x = 245,
			text_id = "bm_menu_stats_skill",
			color = tweak_data.screen_colors.resource
		}, {
			alpha = 0,
			name = "skill"
		})

		if self._slot_data.name ~= equipped_slot then
			for _, title in pairs(self._stats_titles) do
				title:hide()
			end

			self:set_stats_titles({
				show = true,
				name = "total"
			}, {
				name = "equip",
				text_id = "bm_menu_equipped",
				alpha = 0.75,
				x = 105,
				show = true
			})
		else
			for title_name, title in pairs(self._stats_titles) do
				title:show()
			end

			self:set_stats_titles({
				hide = true,
				name = "total"
			}, {
				alpha = 1,
				name = "equip",
				x = 120,
				text_id = "bm_menu_stats_total"
			})
		end

		for _, stat in ipairs(self._armor_stats_shown) do
			self._armor_stats_texts[stat.name].name:set_text(utf8.to_upper(managers.localization:text("bm_menu_" .. stat.name)))

			value = math.max(base_stats[stat.name].value + mods_stats[stat.name].value + skill_stats[stat.name].value, 0)

			if self._slot_data.name == equipped_slot then
				local base = base_stats[stat.name].value

				self._armor_stats_texts[stat.name].equip:set_alpha(1)
				self._armor_stats_texts[stat.name].equip:set_text(format_round(value, stat.round_value))
				self._armor_stats_texts[stat.name].base:set_text(format_round(base, stat.round_value))
				self._armor_stats_texts[stat.name].skill:set_text(skill_stats[stat.name].skill_in_effect and (skill_stats[stat.name].value > 0 and "+" or "") .. format_round(skill_stats[stat.name].value, stat.round_value) or "")
				self._armor_stats_texts[stat.name].total:set_text("")
				self._armor_stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.text)

				if value ~= 0 and base < value then
					self._armor_stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.stats_positive)
				elseif value ~= 0 and value < base then
					self._armor_stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.stats_negative)
				else
					self._armor_stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.text)
				end

				self._armor_stats_texts[stat.name].total:set_color(tweak_data.screen_colors.text)
			else
				local equip = math.max(equip_base_stats[stat.name].value + equip_mods_stats[stat.name].value + equip_skill_stats[stat.name].value, 0)

				self._armor_stats_texts[stat.name].equip:set_alpha(0.75)
				self._armor_stats_texts[stat.name].equip:set_text(format_round(equip, stat.round_value))
				self._armor_stats_texts[stat.name].base:set_text("")
				self._armor_stats_texts[stat.name].skill:set_text("")
				self._armor_stats_texts[stat.name].total:set_text(format_round(value, stat.round_value))

				if equip < value then
					self._armor_stats_texts[stat.name].total:set_color(tweak_data.screen_colors.stats_positive)
				elseif value < equip then
					self._armor_stats_texts[stat.name].total:set_color(tweak_data.screen_colors.stats_negative)
				else
					self._armor_stats_texts[stat.name].total:set_color(tweak_data.screen_colors.text)
				end

				self._armor_stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.text)
			end
		end
	elseif tweak_data.economy.armor_skins[self._slot_data.name] then
		self:hide_melee_weapon_stats()
		self:hide_armor_stats()
		self:hide_weapon_stats()

		for _, title in pairs(self._stats_titles) do
			title:hide()
		end

		hide_stats = true
	elseif tweak_data.blackmarket.melee_weapons[self._slot_data.name] then
		self:hide_armor_stats()
		self:hide_weapon_stats()
		self._mweapon_stats_panel:show()
		self:set_stats_titles({
			x = 185,
			name = "base"
		}, {
			name = "mod",
			x = 245,
			text_id = "bm_menu_stats_skill",
			color = tweak_data.screen_colors.resource
		}, {
			alpha = 0,
			name = "skill"
		})

		local equipped_item = managers.blackmarket:equipped_item(category)
		local equip_base_stats, equip_mods_stats, equip_skill_stats = self:_get_melee_weapon_stats(equipped_item)
		local base_stats, mods_stats, skill_stats = self:_get_melee_weapon_stats(self._slot_data.name)

		if self._slot_data.name ~= equipped_item then
			for _, title in pairs(self._stats_titles) do
				title:hide()
			end

			self:set_stats_titles({
				show = true,
				name = "total"
			}, {
				name = "equip",
				text_id = "bm_menu_equipped",
				alpha = 0.75,
				x = 105,
				show = true
			})
		else
			for title_name, title in pairs(self._stats_titles) do
				title:show()
			end

			self:set_stats_titles({
				hide = true,
				name = "total"
			}, {
				alpha = 1,
				name = "equip",
				x = 120,
				text_id = "bm_menu_stats_total"
			})
		end

		local value_min, value_max, skill_value_min, skill_value_max, skill_value = nil

		for _, stat in ipairs(self._mweapon_stats_shown) do
			self._mweapon_stats_texts[stat.name].name:set_text(utf8.to_upper(managers.localization:text("bm_menu_" .. stat.name)))

			if stat.range then
				value_min = math.max(base_stats[stat.name].min_value + mods_stats[stat.name].min_value + skill_stats[stat.name].min_value, 0)
				value_max = math.max(base_stats[stat.name].max_value + mods_stats[stat.name].max_value + skill_stats[stat.name].max_value, 0)
			end

			value = math.max(base_stats[stat.name].value + mods_stats[stat.name].value + skill_stats[stat.name].value, 0)

			if self._slot_data.name == equipped_item then
				local base, base_min, base_max, skill, skill_min, skill_max = nil

				if stat.range then
					base_min = base_stats[stat.name].min_value
					base_max = base_stats[stat.name].max_value
					skill_min = skill_stats[stat.name].min_value
					skill_max = skill_stats[stat.name].max_value
				end

				base = base_stats[stat.name].value
				skill = skill_stats[stat.name].value
				local format_string = "%0." .. tostring(stat.num_decimals or 0) .. "f"
				local equip_text = value and format_round(value, stat.round_value)
				local base_text = base and format_round(base, stat.round_value)
				local skill_text = skill_stats[stat.name].value and format_round(skill_stats[stat.name].value, stat.round_value)
				local base_min_text = base_min and format_round(base_min, true)
				local base_max_text = base_max and format_round(base_max, true)
				local value_min_text = value_min and format_round(value_min, true)
				local value_max_text = value_max and format_round(value_max, true)
				local skill_min_text = skill_min and format_round(skill_min, true)
				local skill_max_text = skill_max and format_round(skill_max, true)

				if stat.range then
					if base_min ~= base_max then
						base_text = base_min_text .. " (" .. base_max_text .. ")"
					end

					if value_min ~= value_max then
						equip_text = value_min_text .. " (" .. value_max_text .. ")"
					end

					if skill_min ~= skill_max then
						skill_text = skill_min_text .. " (" .. skill_max_text .. ")"
					end
				end

				if stat.suffix then
					base_text = base_text .. tostring(stat.suffix)
					equip_text = equip_text .. tostring(stat.suffix)
					skill_text = skill_text .. tostring(stat.suffix)
				end

				if stat.prefix then
					base_text = tostring(stat.prefix) .. base_text
					equip_text = tostring(stat.prefix) .. equip_text
					skill_text = tostring(stat.prefix) .. skill_text
				end

				self._mweapon_stats_texts[stat.name].equip:set_alpha(1)
				self._mweapon_stats_texts[stat.name].equip:set_text(equip_text)
				self._mweapon_stats_texts[stat.name].base:set_text(base_text)
				self._mweapon_stats_texts[stat.name].skill:set_text(skill_stats[stat.name].skill_in_effect and (skill_stats[stat.name].value > 0 and "+" or "") .. skill_text or "")
				self._mweapon_stats_texts[stat.name].total:set_text("")
				self._mweapon_stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.text)

				local positive = value ~= 0 and base < value
				local negative = value ~= 0 and value < base

				if stat.inverse then
					local temp = positive
					positive = negative
					negative = temp
				end

				if stat.range then
					if positive then
						self._mweapon_stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.stats_positive)
					elseif negative then
						self._mweapon_stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.stats_negative)
					end
				elseif positive then
					self._mweapon_stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.stats_positive)
				elseif negative then
					self._mweapon_stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.stats_negative)
				else
					self._mweapon_stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.text)
				end

				self._mweapon_stats_texts[stat.name].total:set_color(tweak_data.screen_colors.text)
			else
				local equip, equip_min, equip_max = nil

				if stat.range then
					equip_min = math.max(equip_base_stats[stat.name].min_value + equip_mods_stats[stat.name].min_value + equip_skill_stats[stat.name].min_value, 0)
					equip_max = math.max(equip_base_stats[stat.name].max_value + equip_mods_stats[stat.name].max_value + equip_skill_stats[stat.name].max_value, 0)
				end

				equip = math.max(equip_base_stats[stat.name].value + equip_mods_stats[stat.name].value + equip_skill_stats[stat.name].value, 0)
				local format_string = "%0." .. tostring(stat.num_decimals or 0) .. "f"
				local equip_text = equip and format_round(equip, stat.round_value)
				local total_text = value and format_round(value, stat.round_value)
				local equip_min_text = equip_min and format_round(equip_min, true)
				local equip_max_text = equip_max and format_round(equip_max, true)
				local total_min_text = value_min and format_round(value_min, true)
				local total_max_text = value_max and format_round(value_max, true)
				local color_ranges = {}

				if stat.range then
					if equip_min ~= equip_max then
						equip_text = equip_min_text .. " (" .. equip_max_text .. ")"
					end

					if value_min ~= value_max then
						total_text = total_min_text .. " (" .. total_max_text .. ")"
					end
				end

				if stat.suffix then
					equip_text = equip_text .. tostring(stat.suffix)
					total_text = total_text .. tostring(stat.suffix)
				end

				if stat.prefix then
					equip_text = tostring(stat.prefix) .. equip_text
					total_text = tostring(stat.prefix) .. total_text
				end

				self._mweapon_stats_texts[stat.name].equip:set_alpha(0.75)
				self._mweapon_stats_texts[stat.name].equip:set_text(equip_text)
				self._mweapon_stats_texts[stat.name].base:set_text("")
				self._mweapon_stats_texts[stat.name].skill:set_text("")
				self._mweapon_stats_texts[stat.name].total:set_text(total_text)

				if stat.range then
					local positive = equip_min < value_min
					local negative = value_min < equip_min

					if stat.inverse then
						local temp = positive
						positive = negative
						negative = temp
					end

					local color_range_min = {
						start = 0,
						stop = utf8.len(total_min_text)
					}

					if positive then
						color_range_min.color = tweak_data.screen_colors.stats_positive
					elseif negative then
						color_range_min.color = tweak_data.screen_colors.stats_negative
					else
						color_range_min.color = tweak_data.screen_colors.text
					end

					table.insert(color_ranges, color_range_min)

					positive = equip_max < value_max
					negative = value_max < equip_max

					if stat.inverse then
						local temp = positive
						positive = negative
						negative = temp
					end

					local color_range_max = {
						start = color_range_min.stop + 1
					}
					color_range_max.stop = color_range_max.start + 3 + utf8.len(total_max_text)

					if positive then
						color_range_max.color = tweak_data.screen_colors.stats_positive
					elseif negative then
						color_range_max.color = tweak_data.screen_colors.stats_negative
					else
						color_range_max.color = tweak_data.screen_colors.text
					end

					table.insert(color_ranges, color_range_max)
				else
					local positive = equip < value
					local negative = value < equip

					if stat.inverse then
						local temp = positive
						positive = negative
						negative = temp
					end

					local color_range = {
						start = 0,
						stop = utf8.len(total_text)
					}

					if positive then
						color_range.color = tweak_data.screen_colors.stats_positive
					elseif negative then
						color_range.color = tweak_data.screen_colors.stats_negative
					else
						color_range.color = tweak_data.screen_colors.text
					end

					table.insert(color_ranges, color_range)
				end

				self._mweapon_stats_texts[stat.name].total:set_color(tweak_data.screen_colors.text)
				self._mweapon_stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.text)

				for _, color_range in ipairs(color_ranges) do
					self._mweapon_stats_texts[stat.name].total:set_range_color(color_range.start, color_range.stop, color_range.color)
				end
			end
		end
	else
		local equip, stat_changed = nil
		local tweak_parts = tweak_data.weapon.factory.parts[self._slot_data.name]
		local blueprint = clone(managers.blackmarket:get_weapon_blueprint(category, slot))
		local unaltered_total_base_stats, unaltered_total_mods_stats, unaltered_total_skill_stats = WeaponDescription._get_stats(name, category, slot, blueprint)

		managers.weapon_factory:change_part_blueprint_only(weapon.factory_id, self._slot_data.name, blueprint, false)

		local total_base_stats, total_mods_stats, total_skill_stats = WeaponDescription._get_stats(name, category, slot, blueprint)
		local mod_stats = WeaponDescription.get_stats_for_mod(self._slot_data.name, name, category, slot)
		local hide_equip = mod_stats.equip.name == mod_stats.chosen.name
		local remove_stats = {}

		if self._slot_data.removes then
			for _, part_id in ipairs(self._slot_data.removes) do
				local part_stats = WeaponDescription.get_stats_for_mod(part_id, name, category, slot)

				for category, value in pairs(part_stats.chosen or {}) do
					if type(value) == "number" then
						remove_stats[category] = (remove_stats[category] or 0) + value
					end
				end
			end
		end

		self._rweapon_stats_panel:show()
		self:hide_armor_stats()
		self:hide_melee_weapon_stats()
		self:set_weapon_mods_stats_columns()

		for _, title in pairs(self._stats_titles) do
			title:hide()
		end

		self:set_stats_titles({
			alpha = 1,
			name = "total",
			text_id = "bm_menu_stats_total",
			x = 120,
			show = true,
			color = tweak_data.screen_colors.text
		}, {
			alpha = 0.75,
			name = "equip",
			text_id = "bm_menu_equipped",
			x = 170,
			show = not not mod_stats.equip.name,
			color = tweak_data.screen_colors.text
		}, {
			name = "removed",
			alpha = 0.75,
			x = 200,
			show = true,
			color = tweak_data.screen_colors.text
		}, {
			alpha = 1,
			name = "mod",
			text_id = "bm_menu_chosen",
			x = 245,
			show = true,
			color = tweak_data.screen_colors.text
		})

		local total_value, total_index, unaltered_total_value = nil

		for _, stat in ipairs(self._stats_shown) do
			self._stats_texts[stat.name].name:set_text(utf8.to_upper(managers.localization:text("bm_menu_" .. stat.name)))

			value = mod_stats.chosen[stat.name]
			equip = mod_stats.equip[stat.name]
			total_value = math.max(total_base_stats[stat.name].value + total_mods_stats[stat.name].value + total_skill_stats[stat.name].value, 0)
			unaltered_total_value = math.max(unaltered_total_base_stats[stat.name].value + unaltered_total_mods_stats[stat.name].value + unaltered_total_skill_stats[stat.name].value, 0)
			stat_changed = tweak_parts and tweak_parts.stats and tweak_parts.stats[stat.stat_name or stat.name] and value ~= 0
			stat_changed = stat_changed or remove_stats[stat.name] and remove_stats[stat.name] ~= 0

			for stat_name, stat_text in pairs(self._stats_texts[stat.name]) do
				if stat_name ~= "name" then
					stat_text:set_text("")
				end
			end

			for name, column in pairs(self._stats_texts[stat.name]) do
				column:set_alpha(stat_changed and 1 or 0.5)
			end

			local equip_text = equip == 0 and "" or (equip > 0 and "+" or "") .. format_round(equip, stat.round_value)

			self._stats_texts[stat.name].base:set_text(equip_text)
			self._stats_texts[stat.name].base:set_alpha(0.75)
			self._stats_texts[stat.name].equip:set_alpha(1)
			self._stats_texts[stat.name].equip:set_text(format_round(total_value, stat.round_value))
			self._stats_texts[stat.name].skill:set_alpha(1)
			self._stats_texts[stat.name].skill:set_text(value == 0 and "" or (value > 0 and "+" or "") .. format_round(value, stat.round_value))

			if remove_stats[stat.name] and remove_stats[stat.name] ~= 0 then
				local stat_str = remove_stats[stat.name] == 0 and "" or (remove_stats[stat.name] > 0 and "+" or "") .. format_round(remove_stats[stat.name], stat.round_value)

				self._stats_texts[stat.name].removed:set_text("(" .. tostring(stat_str) .. ")")
			else
				self._stats_texts[stat.name].removed:set_text("")
			end

			equip = equip + math.round(remove_stats[stat.name] or 0)

			if unaltered_total_value < total_value then
				self._stats_texts[stat.name].skill:set_color(stat.inverted and tweak_data.screen_colors.stats_negative or tweak_data.screen_colors.stats_positive)
				self._stats_texts[stat.name].equip:set_color(stat.inverted and tweak_data.screen_colors.stats_negative or tweak_data.screen_colors.stats_positive)
			elseif total_value < unaltered_total_value then
				self._stats_texts[stat.name].skill:set_color(stat.inverted and tweak_data.screen_colors.stats_positive or tweak_data.screen_colors.stats_negative)
				self._stats_texts[stat.name].equip:set_color(stat.inverted and tweak_data.screen_colors.stats_positive or tweak_data.screen_colors.stats_negative)
			else
				self._stats_texts[stat.name].skill:set_color(tweak_data.screen_colors.text)
				self._stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.text)
			end

			if stat.percent then
				if math.round(total_value) >= 100 then
					self._stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.stat_maxed)
				end
			elseif stat.index then
				-- Nothing
			elseif tweak_stats[stat.name] then
				local without_skill = math.round(total_base_stats[stat.name].value + total_mods_stats[stat.name].value)
				local max_stat = math.max(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier * (modifier_stats and modifier_stats[stat.name] or 1)

				if stat.offset then
					local offset = math.min(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier * (modifier_stats and modifier_stats[stat.name] or 1)
					max_stat = max_stat - offset
				end

				if without_skill >= max_stat then
					self._stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.stat_maxed)
				end
			end

			self._stats_texts[stat.name].base:set_color(tweak_data.screen_colors.text)
		end
	end

	local modslist_panel = self._stats_panel:child("modslist_panel")
	local y = 0

	if self._rweapon_stats_panel:visible() then
		for i, child in ipairs(self._rweapon_stats_panel:children()) do
			y = math.max(y, child:bottom())
		end
	elseif self._armor_stats_panel:visible() then
		for i, child in ipairs(self._armor_stats_panel:children()) do
			y = math.max(y, child:bottom())
		end
	elseif self._mweapon_stats_panel:visible() then
		for i, child in ipairs(self._mweapon_stats_panel:children()) do
			y = math.max(y, child:bottom())
		end
	end

	modslist_panel:set_top(y + 10)

	if not hide_stats then
		self._stats_panel:show()
	end
end

function BlackMarketGui:_start_rename_item(category, slot)
	if not self._renaming_item then
		local custom_name = managers.blackmarket:get_crafted_custom_name(category, slot) or ""
		self._renaming_item = {
			category = category,
			slot = slot,
			custom_name = custom_name
		}

		self._ws:connect_keyboard(Input:keyboard())

		if _G.IS_VR then
			Input:keyboard():show_with_text(custom_name)
		end

		self._panel:enter_text(callback(self, self, "enter_text"))
		self._panel:key_press(callback(self, self, "key_press"))
		self._panel:key_release(callback(self, self, "key_release"))

		self._rename_caret = self._panel:rect({
			name = "caret",
			h = 0,
			y = 0,
			w = 0,
			x = 0,
			layer = 2,
			color = Color(0.05, 1, 1, 1)
		})

		self._rename_caret:animate(self.blink)

		self._caret_connected = true

		self:update_info_text()
	end
end

function BlackMarketGui:_stop_rename_item()
	if alive(self._panel) and self._renaming_item then
		managers.blackmarket:set_crafted_custom_name(self._renaming_item.category, self._renaming_item.slot, self._renaming_item.custom_name)

		self._renaming_item = nil
		self._rename_info_text = nil

		if self._caret_connected then
			self._ws:disconnect_keyboard()
			self._panel:enter_text(nil)
			self._panel:key_press(nil)
			self._panel:key_release(nil)
			self._panel:remove(self._rename_caret)

			self._rename_caret = nil
			self._caret_connected = nil
		end

		managers.menu_component:post_event("menu_enter")

		self._rename_highlight = false

		self:reload()
	end
end

function BlackMarketGui:_cancel_rename_item()
	if self._renaming_item then
		self._renaming_item = nil
		self._rename_info_text = nil

		if self._caret_connected then
			self._ws:disconnect_keyboard()
			self._panel:enter_text(nil)
			self._panel:key_press(nil)
			self._panel:key_release(nil)
			self._panel:remove(self._rename_caret)

			self._rename_caret = nil
			self._caret_connected = nil
		end

		self._rename_highlight = false
		self._one_frame_input_delay = true

		self:update_info_text()
	end
end

function BlackMarketGui:_set_rename_info_text(info_text)
	self._rename_info_text = info_text
end

function BlackMarketGui:_shift()
	local k = Input:keyboard()

	return k:down("left shift") or k:down("right shift") or k:has_button("shift") and k:down("shift")
end

function BlackMarketGui.blink(o)
	while true do
		o:set_color(Color(0, 1, 1, 1))
		wait(0.3)
		o:set_color(Color.white)
		wait(0.3)
	end
end

function BlackMarketGui:enter_text(o, s)
	if self._renaming_item then
		local m = tweak_data:get_raw_value("gui", "rename_max_letters") or 20

		if _G.IS_VR then
			s = utf8.sub(s, 1, m)
			self._renaming_item.custom_name = tostring(s)
		else
			local n = utf8.len(self._renaming_item.custom_name)
			s = utf8.sub(s, 1, m - n)
			self._renaming_item.custom_name = self._renaming_item.custom_name .. tostring(s)
		end

		self:update_info_text()
	end
end

function BlackMarketGui:update_key_down(o, k)
	wait(0.6)

	while self._key_pressed == k do
		if not self._renaming_item then
			return
		end

		local text = self._renaming_item.custom_name
		local n = utf8.len(text)

		if self._key_pressed == Idstring("backspace") then
			text = utf8.sub(text, 0, math.max(n - 1, 0))
		elseif self._key_pressed == Idstring("delete") then
			-- Nothing
		elseif self._key_pressed == Idstring("left") then
			-- Nothing
		elseif self._key_pressed == Idstring("right") then
			self._key_pressed = false
		elseif self._key_ctrl_pressed == true and k == Idstring("v") then
			return
		end

		if text ~= self._renaming_item.custom_name then
			self._renaming_item.custom_name = text

			self:update_info_text()
		end

		wait(0.03)
	end
end

function BlackMarketGui:key_release(o, k)
	if self._key_pressed == k then
		self._key_pressed = false
	end

	if k == Idstring("left ctrl") or k == Idstring("right ctrl") then
		self._key_ctrl_pressed = false
	end
end

function BlackMarketGui:key_press(o, k)
	local text = self._renaming_item.custom_name
	local n = utf8.len(text)
	self._key_pressed = k

	self._panel:stop()
	self._panel:animate(callback(self, self, "update_key_down"), k)

	if k == Idstring("backspace") then
		text = utf8.sub(text, 0, math.max(n - 1, 0))
	elseif k == Idstring("delete") then
		-- Nothing
	elseif k == Idstring("left") then
		-- Nothing
	elseif k == Idstring("right") then
		-- Nothing
	elseif self._key_pressed == Idstring("end") then
		-- Nothing
	elseif self._key_pressed == Idstring("home") then
		-- Nothing
	elseif k == Idstring("enter") then
		if _G.IS_VR then
			self:_stop_rename_item()

			return
		end
	elseif k == Idstring("esc") then
		self:_cancel_rename_item()

		return
	elseif k == Idstring("left ctrl") or k == Idstring("right ctrl") then
		self._key_ctrl_pressed = true
	elseif self._key_ctrl_pressed == true and k == Idstring("v") then
		return
	end

	if text ~= self._renaming_item.custom_name then
		self._renaming_item.custom_name = text

		self:update_info_text()
	end
end

function BlackMarketGui:update_info_text()
	local slot_data = self._slot_data
	local tab_data = self._tabs[self._selected]._data
	local prev_data = tab_data.prev_node_data
	local ids_category = Idstring(slot_data.category)
	local identifier = tab_data.identifier
	local updated_texts = {
		{
			text = ""
		},
		{
			text = ""
		},
		{
			text = ""
		},
		{
			text = ""
		},
		{
			text = ""
		}
	}
	local ignore_lock = false

	self._stats_text_modslist:set_text("")

	local suspicion, max_reached, min_reached = managers.blackmarket:get_suspicion_offset_of_local(tweak_data.player.SUSPICION_OFFSET_LERP or 0.75)

	self:_set_detection(suspicion, max_reached, min_reached)
	self:_set_rename_info_text(nil)

	local is_renaming_this = self._renaming_item and not self._data.is_loadout and self._renaming_item.category == slot_data.category and self._renaming_item.slot == slot_data.slot

	self._armor_info_panel:set_visible(identifier == self.identifiers.armor)

	if identifier == self.identifiers.weapon then
		local price = slot_data.price or 0

		if slot_data.ignore_slot then
			-- Nothing
		elseif not slot_data.empty_slot then
			updated_texts[1].text = slot_data.name_localized

			if slot_data.name_color then
				updated_texts[1].text = "##" .. updated_texts[1].text .. "##"
				updated_texts[1].resource_color = {
					slot_data.name_color
				}
			end

			local resource_color = {}
			updated_texts[2].resource_color = resource_color

			if price > 0 then
				updated_texts[2].text = "##" .. managers.localization:to_upper_text(slot_data.not_moddable and "st_menu_cost" or "st_menu_value") .. " " .. managers.experience:cash_string(price) .. "##"

				table.insert(resource_color, slot_data.can_afford and tweak_data.screen_colors.text or tweak_data.screen_colors.important_1)
			end

			if not slot_data.not_moddable and not self._data.is_loadout then
				self:_set_rename_info_text(1)
			end

			if not slot_data.unlocked then
				if slot_data.lock_text then
					updated_texts[3].text = slot_data.lock_text
					updated_texts[3].below_stats = true
				else
					local skill_based = slot_data.skill_based
					local func_based = slot_data.func_based
					local level_based = slot_data.level and slot_data.level > 0
					local dlc_based = tweak_data.lootdrop.global_values[slot_data.global_value] and tweak_data.lootdrop.global_values[slot_data.global_value].dlc and not managers.dlc:is_dlc_unlocked(slot_data.global_value)
					local part_dlc_locked = slot_data.part_dlc_lock
					local skill_text_id = skill_based and (slot_data.skill_name or "bm_menu_skilltree_locked") or false
					local level_text_id = level_based and "bm_menu_level_req" or false
					local dlc_text_id = dlc_based and slot_data.dlc_locked or false
					local part_dlc_text_id = part_dlc_locked and "bm_menu_part_dlc_locked"
					local funclock_text_id = false

					if func_based then
						local unlocked, text_id = BlackMarketGui.get_func_based(func_based)

						if not unlocked then
							funclock_text_id = text_id
						end
					end

					local vr_lock_text = slot_data.vr_locked and "bm_menu_vr_locked"
					local text = ""

					if slot_data.install_lock then
						text = text .. managers.localization:to_upper_text(slot_data.install_lock, {}) .. "\n"
					elseif vr_lock_text then
						text = text .. managers.localization:to_upper_text(vr_lock_text) .. "\n"
					elseif dlc_text_id then
						text = text .. managers.localization:to_upper_text(dlc_text_id, {}) .. "\n"
					elseif part_dlc_text_id then
						text = text .. managers.localization:to_upper_text(part_dlc_text_id, {}) .. "\n"
					elseif funclock_text_id then
						text = text .. managers.localization:to_upper_text(funclock_text_id, {
							slot_data.name_localized
						}) .. "\n"
					elseif skill_text_id then
						text = text .. managers.localization:to_upper_text(skill_text_id, {
							slot_data.name_localized
						}) .. "\n"
					elseif level_text_id then
						text = text .. managers.localization:to_upper_text(level_text_id, {
							level = slot_data.level
						}) .. "\n"
					end

					updated_texts[3].text = text
					updated_texts[3].below_stats = true
				end
			elseif self._slot_data.can_afford == false then
				-- Nothing
			end

			if slot_data.last_weapon then
				updated_texts[5].text = updated_texts[5].text .. managers.localization:to_upper_text("bm_menu_last_weapon_warning") .. "\n"
			end

			if slot_data.global_value and slot_data.global_value ~= "normal" then
				updated_texts[4].text = updated_texts[4].text .. "##" .. managers.localization:to_upper_text(tweak_data.lootdrop.global_values[slot_data.global_value].desc_id) .. "##"
				updated_texts[4].resource_color = tweak_data.lootdrop.global_values[slot_data.global_value].color
				updated_texts[4].below_stats = true
			end

			if slot_data.not_moddable then
				local weapon_id = slot_data.name
				local weapon_tweak = weapon_id and tweak_data.weapon[weapon_id]
				local movement_penalty = weapon_tweak and tweak_data.upgrades.weapon_movement_penalty[weapon_tweak.categories[1]] or 1

				if movement_penalty < 1 then
					local penalty_as_string = string.format("%d%%", math.round((1 - movement_penalty) * 100))
					updated_texts[5].text = updated_texts[5].text .. managers.localization:to_upper_text("bm_menu_weapon_movement_penalty_info", {
						penalty = penalty_as_string
					})
				end

				if weapon_tweak.has_description then
					updated_texts[4].text = updated_texts[4].text .. "\n\n" .. managers.localization:to_upper_text(tweak_data.weapon[slot_data.name].desc_id)
					updated_texts[4].below_stats = true
				end
			end

			updated_texts[5].below_stats = true
		elseif slot_data.locked_slot then
			ignore_lock = true
			updated_texts[1].text = managers.localization:to_upper_text("bm_menu_locked_weapon_slot")

			if slot_data.cannot_buy then
				updated_texts[3].text = slot_data.dlc_locked
			else
				updated_texts[2].text = slot_data.dlc_locked
			end

			updated_texts[4].text = managers.localization:text("bm_menu_locked_weapon_slot_desc")
		elseif not slot_data.is_loadout then
			local prefix = ""

			if not managers.menu:is_pc_controller() then
				prefix = managers.localization:get_default_macro("BTN_A")
			end

			updated_texts[1].text = prefix .. managers.localization:to_upper_text("bm_menu_btn_buy_new_weapon")
			updated_texts[4].text = managers.localization:text("bm_menu_empty_weapon_slot_buy_info")
		end
	elseif identifier == self.identifiers.melee_weapon then
		updated_texts[1].text = self._slot_data.name_localized

		if tweak_data.blackmarket.melee_weapons[slot_data.name].info_id then
			updated_texts[2].text = managers.localization:text(tweak_data.blackmarket.melee_weapons[slot_data.name].info_id)
			updated_texts[2].below_stats = true
		end

		if not slot_data.unlocked then
			local skill_based = slot_data.skill_based
			local level_based = slot_data.level and slot_data.level > 0
			local dlc_based = slot_data.dlc_based or tweak_data.lootdrop.global_values[slot_data.global_value] and tweak_data.lootdrop.global_values[slot_data.global_value].dlc and not managers.dlc:is_dlc_unlocked(slot_data.global_value)
			local skill_text_id = skill_based and (slot_data.skill_name or "bm_menu_skilltree_locked") or false
			local level_text_id = level_based and "bm_menu_level_req" or false
			local dlc_text_id = dlc_based and slot_data.dlc_locked or false
			local text = ""
			local vr_lock_text = slot_data.vr_locked and "bm_menu_vr_locked"

			if slot_data.install_lock then
				text = text .. managers.localization:to_upper_text(slot_data.install_lock, {}) .. "\n"
			elseif vr_lock_text then
				text = text .. managers.localization:to_upper_text(vr_lock_text) .. "\n"
			elseif skill_text_id then
				text = text .. managers.localization:to_upper_text(skill_text_id, {
					slot_data.name_localized
				}) .. "\n"
			elseif dlc_text_id then
				text = text .. managers.localization:to_upper_text(dlc_text_id, {}) .. "\n"
			elseif level_text_id then
				text = text .. managers.localization:to_upper_text(level_text_id, {
					level = slot_data.level
				}) .. "\n"
			end

			updated_texts[3].text = text
			updated_texts[3].below_stats = true
		end

		updated_texts[4].resource_color = {}
		local desc_text = managers.localization:text(tweak_data.blackmarket.melee_weapons[slot_data.name].desc_id)

		if slot_data.global_value and slot_data.global_value ~= "normal" then
			updated_texts[4].text = updated_texts[4].text .. "##" .. managers.localization:to_upper_text(tweak_data.lootdrop.global_values[slot_data.global_value].desc_id) .. "##"

			table.insert(updated_texts[4].resource_color, tweak_data.lootdrop.global_values[slot_data.global_value].color)
		end

		updated_texts[4].below_stats = true
	elseif identifier == self.identifiers.grenade then
		updated_texts[1].text = self._slot_data.name_localized

		if not slot_data.unlocked then
			local skill_based = slot_data.skill_based
			local level_based = slot_data.level and slot_data.level > 0
			local dlc_based = slot_data.dlc_based or tweak_data.lootdrop.global_values[slot_data.global_value] and tweak_data.lootdrop.global_values[slot_data.global_value].dlc and not managers.dlc:is_dlc_unlocked(slot_data.global_value)
			local skill_text_id = skill_based and (slot_data.skill_name or "bm_menu_skilltree_locked") or false
			local level_text_id = level_based and "bm_menu_level_req" or false
			local dlc_text_id = dlc_based and slot_data.dlc_locked or false
			local text = ""

			if slot_data.install_lock then
				text = text .. managers.localization:to_upper_text(slot_data.install_lock, {}) .. "\n"
			elseif skill_text_id then
				text = text .. managers.localization:to_upper_text(skill_text_id, {
					slot_data.name_localized
				}) .. "\n"
			elseif dlc_text_id then
				text = text .. managers.localization:to_upper_text(dlc_text_id, {}) .. "\n"
			elseif level_text_id then
				text = text .. managers.localization:to_upper_text(level_text_id, {
					level = slot_data.level
				}) .. "\n"
			end

			updated_texts[3].text = text
		end

		updated_texts[4].resource_color = {}
		local desc_text = managers.localization:text(tweak_data.blackmarket.projectiles[slot_data.name].desc_id)
		updated_texts[4].text = desc_text .. "\n"

		if slot_data.global_value and slot_data.global_value ~= "normal" then
			updated_texts[4].text = updated_texts[4].text .. "##" .. managers.localization:to_upper_text(tweak_data.lootdrop.global_values[slot_data.global_value].desc_id) .. "##"

			table.insert(updated_texts[4].resource_color, tweak_data.lootdrop.global_values[slot_data.global_value].color)
		end

		updated_texts[4].below_stats = true
	elseif identifier == self.identifiers.armor then
		local armor_name_text = self._armor_info_panel:child("armor_name_text")
		local armor_image = self._armor_info_panel:child("armor_image")
		local armor_equipped = self._armor_info_panel:child("armor_equipped")

		armor_name_text:set_text(self._slot_data.name_localized)
		armor_name_text:set_w(self._armor_info_panel:w() - armor_image:right() - 20)
		self:make_fine_text(armor_name_text)
		armor_name_text:grow(2, 0)
		armor_equipped:set_visible(self._slot_data.equipped)
		armor_equipped:set_top(armor_name_text:bottom())
		armor_image:set_image(self._slot_data.bitmap_texture)
		self._armor_info_panel:set_h(armor_image:bottom())

		if not self._slot_data.unlocked then
			updated_texts[3].text = utf8.to_upper(managers.localization:text(slot_data.level == 0 and (slot_data.skill_name or "bm_menu_skilltree_locked") or "bm_menu_level_req", {
				level = slot_data.level,
				SKILL = slot_data.name
			}))
			updated_texts[3].below_stats = true
		elseif managers.player:has_category_upgrade("player", "damage_to_hot") and not table.contains(tweak_data:get_raw_value("upgrades", "damage_to_hot_data", "armors_allowed") or {}, self._slot_data.name) then
			updated_texts[3].text = managers.localization:to_upper_text("bm_menu_disables_damage_to_hot")
			updated_texts[3].below_stats = true
		elseif managers.player:has_category_upgrade("player", "armor_health_store_amount") then
			local bm_armor_tweak = tweak_data.blackmarket.armors[slot_data.name]
			local upgrade_level = bm_armor_tweak.upgrade_level
			local amount = managers.player:body_armor_value("skill_max_health_store", upgrade_level, 1)
			local multiplier = managers.player:upgrade_value("player", "armor_max_health_store_multiplier", 1)
			updated_texts[2].text = managers.localization:to_upper_text("bm_menu_armor_max_health_store", {
				amount = format_round(amount * multiplier * tweak_data.gui.stats_present_multiplier)
			})
			updated_texts[2].below_stats = true
		end
	elseif identifier == self.identifiers.armor_skins then
		local skin_tweak = tweak_data.economy.armor_skins[self._slot_data.name]
		updated_texts[1].text = self._slot_data.name_localized
		local desc = ""
		local desc_colors = {}

		if self._slot_data.equipped then
			updated_texts[2].text = "##" .. managers.localization:to_upper_text("bm_menu_equipped") .. "##"
			updated_texts[2].resource_color = tweak_data.screen_colors.text
		elseif not self._slot_data.cosmetic_unlocked then
			if slot_data.dlc_locked then
				updated_texts[3].text = managers.localization:to_upper_text(slot_data.dlc_locked)
			else
				updated_texts[2].text = "##" .. managers.localization:to_upper_text("bm_menu_item_locked") .. "##"
				updated_texts[2].resource_color = tweak_data.screen_colors.important_1
			end
		end

		if self._slot_data.cosmetic_rarity then
			local rarity_color = tweak_data.economy.rarities[self._slot_data.cosmetic_rarity].color or tweak_data.screen_colors.text
			updated_texts[1].text = "##" .. self._slot_data.name_localized .. "##"
			updated_texts[1].resource_color = rarity_color
			local rarity = managers.localization:to_upper_text("bm_menu_steam_item_rarity", {
				rarity = managers.localization:text(tweak_data.economy.rarities[self._slot_data.cosmetic_rarity].name_id)
			})
			desc = desc .. rarity .. "\n\n"

			table.insert(desc_colors, rarity_color)
		end

		if skin_tweak.desc_id then
			local desc_text = managers.localization:text(skin_tweak.desc_id)

			if desc_text ~= " " then
				desc = desc .. desc_text
				desc = desc .. "\n\n"
			end
		end

		if skin_tweak.challenge_id then
			desc = desc .. "##" .. managers.localization:to_upper_text("menu_unlock_condition") .. "##\n"

			table.insert(desc_colors, tweak_data.screen_colors.challenge_title)

			desc = desc .. managers.localization:text(skin_tweak.challenge_id)
		elseif not skin_tweak.free then
			if skin_tweak.unlock_id then
				desc = desc .. managers.localization:text(skin_tweak.unlock_id) .. "\n"

				table.insert(desc_colors, tweak_data.screen_colors.challenge_title)
			else
				local safe = self:get_safe_for_economy_item(slot_data.name)
				safe = safe and safe.name_id and managers.localization:text(safe.name_id) or "invalid skin"
				desc = desc .. managers.localization:text("bm_menu_purchase_steam", {
					safe = safe
				}) .. "\n"

				table.insert(desc_colors, tweak_data.screen_colors.challenge_title)
			end
		end

		updated_texts[4].text = desc
		updated_texts[4].resource_color = desc_colors
		updated_texts[4].below_stats = true

		if slot_data.global_value and slot_data.global_value ~= "normal" then
			updated_texts[4].text = updated_texts[4].text .. "##" .. managers.localization:to_upper_text(tweak_data.lootdrop.global_values[slot_data.global_value].desc_id) .. "##"

			table.insert(updated_texts[4].resource_color, tweak_data.lootdrop.global_values[slot_data.global_value].color)
		end
	elseif identifier == self.identifiers.player_style then
		local player_style = slot_data.name
		local player_style_tweak = tweak_data.blackmarket.player_styles[player_style]
		updated_texts[1].text = slot_data.name_localized

		if not slot_data.unlocked then
			updated_texts[2].text = "##" .. managers.localization:to_upper_text("bm_menu_item_locked") .. "##"
			updated_texts[2].resource_color = tweak_data.screen_colors.important_1
			updated_texts[3].text = slot_data.dlc_locked and managers.localization:to_upper_text(slot_data.dlc_locked) or managers.localization:to_upper_text("bm_menu_dlc_locked")
		end

		local desc_id = player_style_tweak.desc_id
		local desc_colors = {}
		updated_texts[4].text = desc_id and managers.localization:text(desc_id) or ""

		if slot_data.global_value and slot_data.global_value ~= "normal" then
			local gvalue_tweak = tweak_data.lootdrop.global_values[slot_data.global_value]

			if gvalue_tweak.desc_id then
				updated_texts[4].text = updated_texts[4].text .. "\n##" .. managers.localization:to_upper_text(gvalue_tweak.desc_id) .. "##"

				table.insert(desc_colors, gvalue_tweak.color)
			end
		end

		if #desc_colors == 1 then
			updated_texts[4].resource_color = desc_colors[1]
		else
			updated_texts[4].resource_color = desc_colors
		end
	elseif identifier == self.identifiers.suit_variation then
		local player_style = self._data.prev_node_data.name
		local player_style_tweak = tweak_data.blackmarket.player_styles[player_style]
		local suit_variation = slot_data.name
		local suit_variation_tweak = player_style_tweak.material_variations[suit_variation]
		updated_texts[1].text = slot_data.name_localized

		if not slot_data.unlocked then
			updated_texts[2].text = "##" .. managers.localization:to_upper_text("bm_menu_item_locked") .. "##"
			updated_texts[2].resource_color = tweak_data.screen_colors.important_1
			updated_texts[3].text = slot_data.dlc_locked and managers.localization:to_upper_text(slot_data.dlc_locked) or managers.localization:to_upper_text("bm_menu_dlc_locked")
		end

		local desc_id = suit_variation_tweak and suit_variation_tweak.desc_id or "menu_default"
		local desc_colors = {}
		updated_texts[4].text = desc_id and managers.localization:text(desc_id) or ""

		if slot_data.global_value and slot_data.global_value ~= "normal" then
			local gvalue_tweak = tweak_data.lootdrop.global_values[slot_data.global_value]

			if gvalue_tweak.desc_id then
				updated_texts[4].text = updated_texts[4].text .. "\n##" .. managers.localization:to_upper_text(gvalue_tweak.desc_id) .. "##"

				table.insert(desc_colors, gvalue_tweak.color)
			end
		end

		if #desc_colors == 1 then
			updated_texts[4].resource_color = desc_colors[1]
		else
			updated_texts[4].resource_color = desc_colors
		end
	elseif identifier == self.identifiers.mask then
		local price = slot_data.price
		price = price or (type(slot_data.unlocked) == "number" or managers.money:get_mask_slot_sell_value(slot_data.slot)) and managers.money:get_mask_sell_value(slot_data.name, slot_data.global_value)

		if not slot_data.empty_slot then
			updated_texts[1].text = slot_data.name_localized

			if not self._data.is_loadout and slot_data.slot ~= 1 and slot_data.unlocked == true then
				self:_set_rename_info_text(1)
			end

			local resource_colors = {}

			if price > 0 and slot_data.slot ~= 1 then
				updated_texts[2].text = "##" .. managers.localization:to_upper_text("st_menu_value") .. " " .. managers.experience:cash_string(price) .. "##" .. "   "

				table.insert(resource_colors, slot_data.can_afford ~= false and tweak_data.screen_colors.text or tweak_data.screen_colors.important_1)
			end

			if slot_data.num_backs then
				updated_texts[2].text = updated_texts[2].text .. "##" .. managers.localization:to_upper_text("bm_menu_item_amount", {
					amount = math.abs(slot_data.unlocked)
				}) .. "##"

				table.insert(resource_colors, tweak_data.screen_colors.text)
			end

			if #resource_colors == 1 then
				updated_texts[2].resource_color = resource_colors[1]
			else
				updated_texts[2].resource_color = resource_colors
			end

			local achievement_tracker = tweak_data.achievement.mask_tracker
			local mask_id = slot_data.name

			if slot_data.dlc_locked then
				updated_texts[3].text = managers.localization:to_upper_text(slot_data.dlc_locked)
			elseif slot_data.infamy_lock then
				updated_texts[3].text = managers.localization:to_upper_text("menu_infamy_lock_info")
			elseif mask_id and achievement_tracker[mask_id] and (type(slot_data.unlocked) ~= "number" and not slot_data.unlocked or slot_data.unlocked == 0) then
				local achievement_data = achievement_tracker[mask_id]
				local max_progress = achievement_data.max_progress
				local text_id = achievement_data.text_id
				local award = achievement_data.award
				local stat = achievement_data.stat

				if stat and max_progress > 0 then
					local progress_left = max_progress - (managers.achievment:get_stat(stat) or 0)

					if progress_left > 0 then
						local progress = tostring(progress_left)
						updated_texts[3].text = "##" .. managers.localization:text(achievement_data.text_id, {
							progress = progress
						}) .. "##"
						updated_texts[3].resource_color = tweak_data.screen_colors.button_stage_2
					end
				elseif award and not managers.achievment:get_info(award).awarded then
					updated_texts[3].text = "##" .. managers.localization:text(achievement_data.text_id) .. "##"
					updated_texts[3].resource_color = tweak_data.screen_colors.button_stage_2
				end
			end

			if mask_id then
				local desc_id = tweak_data.blackmarket.masks[mask_id].desc_id
				updated_texts[4].text = desc_id and managers.localization:text(desc_id) or Application:production_build() and "Add ##desc_id## to ##" .. mask_id .. "## in tweak_data.blackmarket.masks" or ""

				if managers.dlc:is_mask_achievement_locked(mask_id) and (not tweak_data.blackmarket.masks[mask_id].pcs or #tweak_data.blackmarket.masks[mask_id].pcs <= 0) then
					updated_texts[4].text = updated_texts[4].text .. managers.localization:text("bm_msk_achievement_postfix")
				end

				if managers.dlc:is_mask_achievement_milestone_locked(mask_id) and (not tweak_data.blackmarket.masks[mask_id].pcs or #tweak_data.blackmarket.masks[mask_id].pcs <= 0) then
					updated_texts[4].text = updated_texts[4].text .. managers.localization:text("bm_msk_achievement_milestone_postfix")
				end

				if slot_data.global_value and slot_data.global_value ~= "normal" then
					local gvalue_tweak = tweak_data.lootdrop.global_values[slot_data.global_value]

					if gvalue_tweak.desc_id then
						updated_texts[4].text = updated_texts[4].text .. "\n##" .. managers.localization:to_upper_text(gvalue_tweak.desc_id) .. "##"
						updated_texts[4].resource_color = gvalue_tweak.color
					end
				end
			end
		elseif slot_data.locked_slot then
			ignore_lock = true
			updated_texts[1].text = managers.localization:to_upper_text("bm_menu_locked_mask_slot")

			if slot_data.cannot_buy then
				updated_texts[3].text = slot_data.dlc_locked
			else
				updated_texts[2].text = slot_data.dlc_locked
			end

			updated_texts[4].text = managers.localization:text("bm_menu_locked_mask_slot_desc")
		else
			if slot_data.cannot_buy then
				updated_texts[2].text = managers.localization:to_upper_text("bm_menu_empty_mask_slot")
				updated_texts[3].text = managers.localization:to_upper_text("bm_menu_no_masks_in_stash_varning")
			else
				local prefix = ""

				if not managers.menu:is_pc_controller() then
					prefix = managers.localization:get_default_macro("BTN_A")
				end

				updated_texts[1].text = prefix .. managers.localization:to_upper_text("bm_menu_btn_buy_new_mask")
			end

			updated_texts[4].text = managers.localization:text("bm_menu_empty_mask_slot_buy_info")
		end
	elseif identifier == self.identifiers.weapon_mod then
		local price = slot_data.price or managers.money:get_weapon_modify_price(prev_data.name, slot_data.name, slot_data.global_value)
		updated_texts[1].text = slot_data.name_localized
		local resource_colors = {}

		if price > 0 then
			updated_texts[2].text = "##" .. managers.localization:to_upper_text("st_menu_cost") .. " " .. managers.experience:cash_string(price) .. "##"

			table.insert(resource_colors, slot_data.can_afford and tweak_data.screen_colors.text or tweak_data.screen_colors.important_1)
		end

		local unlocked = slot_data.unlocked and slot_data.unlocked ~= true and slot_data.unlocked or 0
		updated_texts[2].text = updated_texts[2].text .. (price > 0 and "   " or "")

		if slot_data.previewing then
			updated_texts[2].text = updated_texts[2].text .. managers.localization:to_upper_text("bm_menu_mod_preview")
		elseif slot_data.free_of_charge then
			updated_texts[2].text = updated_texts[2].text .. (unlocked > 0 and managers.localization:to_upper_text("bm_menu_item_unlocked") or managers.localization:to_upper_text("bm_menu_item_locked"))
		else
			updated_texts[2].text = updated_texts[2].text .. "##" .. managers.localization:to_upper_text("bm_menu_item_amount", {
				amount = tostring(math.abs(unlocked))
			}) .. "##"

			table.insert(resource_colors, math.abs(unlocked) > 0 and tweak_data.screen_colors.text or tweak_data.screen_colors.important_1)
		end

		if #resource_colors == 1 then
			updated_texts[2].resource_color = resource_colors[1]
		else
			updated_texts[2].resource_color = resource_colors
		end

		local can_not_afford = slot_data.can_afford == false
		local conflicted = slot_data.conflict
		local out_of_item = slot_data.unlocked and slot_data.unlocked ~= true and slot_data.unlocked == 0

		if slot_data.install_lock then
			updated_texts[3].text = managers.localization:to_upper_text(slot_data.install_lock)
			updated_texts[3].below_stats = true
		elseif slot_data.dlc_locked then
			updated_texts[3].text = managers.localization:to_upper_text(slot_data.dlc_locked)
		elseif conflicted then
			updated_texts[3].text = managers.localization:to_upper_text("bm_menu_conflict", {
				conflict = slot_data.conflict
			})
		end

		local part_id = slot_data.name
		local part_data = part_id and tweak_data.weapon.factory.parts[part_id]
		local perks = part_data and part_data.perks
		local is_gadget = part_data and part_data.type == "gadget" or perks and table.contains(perks, "gadget")
		local is_ammo = part_data and part_data.type == "ammo" or perks and table.contains(perks, "ammo")
		local is_bayonet = part_data and part_data.type == "bayonet" or perks and table.contains(perks, "bayonet")
		local is_bipod = part_data and part_data.type == "bipod" or perks and table.contains(perks, "bipod")
		local has_desc = part_data and part_data.has_description == true
		updated_texts[4].resource_color = {}

		if is_gadget or is_ammo or is_bayonet or is_bipod or has_desc then
			local crafted = managers.blackmarket:get_crafted_category_slot(prev_data.category, prev_data.slot)
			updated_texts[4].text = managers.weapon_factory:get_part_desc_by_part_id_from_weapon(part_id, crafted.factory_id, crafted.blueprint)
		end

		if slot_data.global_value and slot_data.global_value ~= "normal" then
			if is_gadget or is_ammo or is_bayonet or has_desc then
				updated_texts[4].text = updated_texts[4].text .. "\n##" .. managers.localization:to_upper_text(tweak_data.lootdrop.global_values[slot_data.global_value].desc_id) .. "##"
			else
				updated_texts[4].text = "##" .. managers.localization:to_upper_text(tweak_data.lootdrop.global_values[slot_data.global_value].desc_id) .. "##"
			end

			table.insert(updated_texts[4].resource_color, tweak_data.lootdrop.global_values[slot_data.global_value].color)
		end

		if perks and table.contains(perks, "bonus") then
			updated_texts[4].text = updated_texts[4].text .. "\n##" .. managers.localization:to_upper_text("bm_menu_disables_cosmetic_bonus") .. "##"

			table.insert(updated_texts[4].resource_color, tweak_data.screen_colors.text)
		end

		updated_texts[4].below_stats = true
		local weapon_id = managers.weapon_factory:get_factory_id_by_weapon_id(prev_data.name)

		local function get_forbids(weapon_id, part_id)
			local weapon_data = tweak_data.weapon.factory[weapon_id]

			if not weapon_data then
				return {}
			end

			local default_parts = {}

			for _, part in ipairs(weapon_data.default_blueprint) do
				table.insert(default_parts, part)

				local part_data = tweak_data.weapon.factory.parts[part]

				if part_data and part_data.adds then
					for _, part in ipairs(part_data.adds) do
						table.insert(default_parts, part)
					end
				end
			end

			local weapon_mods = {}

			for _, part in ipairs(weapon_data.uses_parts) do
				if not table.contains(default_parts, part) then
					local part_data = tweak_data.weapon.factory.parts[part]

					if part_data and not part_data.unatainable then
						weapon_mods[part] = {}
					end
				end
			end

			for part, _ in pairs(weapon_mods) do
				local part_data = tweak_data.weapon.factory.parts[part]

				if part_data.forbids then
					for other_part, _ in pairs(weapon_mods) do
						local other_part_data = tweak_data.weapon.factory.parts[part]

						if table.contains(part_data.forbids, other_part) then
							table.insert(weapon_mods[part], other_part)
							table.insert(weapon_mods[other_part], part)
						end
					end
				end
			end

			return weapon_mods[part_id]
		end

		local forbidden_parts = get_forbids(weapon_id, part_id)
		local droppable_mods = managers.blackmarket:get_dropable_mods_by_weapon_id(prev_data.name)

		if slot_data.removes and #slot_data.removes > 0 then
			local removed_mods = ""

			for i, name in ipairs(slot_data.removes) do
				local mod_data = tweak_data.weapon.factory.parts[name]

				if droppable_mods[mod_data.type] then
					local mod_name = mod_data and mod_data.name_id or name
					mod_name = managers.localization:text(mod_name)
					removed_mods = string.format("%s%s%s", removed_mods, i > 1 and ", " or "", mod_name)
				end
			end

			if #removed_mods > 0 then
				updated_texts[5].text = managers.localization:to_upper_text("bm_mod_equip_remove", {
					mod = removed_mods
				})
			end
		elseif forbidden_parts and #forbidden_parts > 0 then
			local forbids = {}

			for i, forbidden_part in ipairs(forbidden_parts) do
				local data = tweak_data.weapon.factory.parts[forbidden_part]

				if data then
					forbids[data.type] = (forbids[data.type] or 0) + 1
				end
			end

			local text = ""

			for category, amount in pairs(forbids) do
				if droppable_mods[category] then
					if text ~= "" then
						text = text .. "\n"
					end

					local category_count = 0
					local weapon_data = tweak_data.weapon.factory[weapon_id]

					for _, part_name in ipairs(weapon_data.uses_parts) do
						local part_data = tweak_data.weapon.factory.parts[part_name]

						if part_data and not part_data.unatainable and part_data.type == category and not table.contains(weapon_data.default_blueprint, part_name) then
							category_count = category_count + 1
						end
					end

					local percent_forbidden = amount / category_count
					local category = managers.localization:text("bm_menu_" .. tostring(category) .. "_plural")
					local quantifier = percent_forbidden == 1 and "all" or percent_forbidden > 0.66 and "most" or "some"
					quantifier = managers.localization:text("bm_mod_incompatibility_" .. tostring(quantifier))
					text = managers.localization:to_upper_text("bm_mod_incompatibilities", {
						quantifier = quantifier,
						category = category
					})
				end
			end

			updated_texts[5].text = text
		end
	elseif identifier == self.identifiers.mask_mod then
		if not managers.blackmarket:currently_customizing_mask() then
			return
		end

		local mask_mod_info = managers.blackmarket:info_customize_mask()
		updated_texts[2].text = managers.localization:to_upper_text("bm_menu_mask_customization") .. "\n"
		local resource_color = {}
		local material_text = managers.localization:to_upper_text("bm_menu_materials")
		local pattern_text = managers.localization:to_upper_text("bm_menu_textures")
		local colors_text = managers.localization:to_upper_text("bm_menu_colors")

		if mask_mod_info[1].overwritten then
			updated_texts[2].text = updated_texts[2].text .. material_text .. ": " .. "##" .. managers.localization:to_upper_text("menu_bm_overwritten") .. "##" .. "\n"

			table.insert(resource_color, tweak_data.screen_colors.risk)
		elseif mask_mod_info[1].is_good then
			updated_texts[2].text = updated_texts[2].text .. material_text .. ": " .. managers.localization:text(mask_mod_info[1].text)

			if mask_mod_info[1].price and mask_mod_info[1].price > 0 then
				updated_texts[2].text = updated_texts[2].text .. " " .. managers.experience:cash_string(mask_mod_info[1].price)
			end

			updated_texts[2].text = updated_texts[2].text .. "\n"
		else
			updated_texts[2].text = updated_texts[2].text .. material_text .. ": " .. "##" .. managers.localization:to_upper_text("menu_bm_not_selected") .. "##" .. "\n"

			table.insert(resource_color, tweak_data.screen_colors.important_1)
		end

		if mask_mod_info[2].overwritten then
			updated_texts[2].text = updated_texts[2].text .. pattern_text .. ": " .. "##" .. managers.localization:to_upper_text("menu_bm_overwritten") .. "##" .. "\n"

			table.insert(resource_color, tweak_data.screen_colors.risk)
		elseif mask_mod_info[2].is_good then
			updated_texts[2].text = updated_texts[2].text .. pattern_text .. ": " .. managers.localization:text(mask_mod_info[2].text)

			if mask_mod_info[2].price and mask_mod_info[2].price > 0 then
				updated_texts[2].text = updated_texts[2].text .. " " .. managers.experience:cash_string(mask_mod_info[2].price)
			end

			updated_texts[2].text = updated_texts[2].text .. "\n"
		else
			updated_texts[2].text = updated_texts[2].text .. pattern_text .. ": " .. "##" .. managers.localization:to_upper_text("menu_bm_not_selected") .. "##" .. "\n"

			table.insert(resource_color, tweak_data.screen_colors.important_1)
		end

		if mask_mod_info[3].overwritten then
			updated_texts[2].text = updated_texts[2].text .. colors_text .. ": " .. "##" .. managers.localization:to_upper_text("menu_bm_overwritten") .. "##" .. "\n"

			table.insert(resource_color, tweak_data.screen_colors.risk)
		elseif mask_mod_info[3].is_good then
			updated_texts[2].text = updated_texts[2].text .. colors_text .. ": " .. managers.localization:text(mask_mod_info[3].text)

			if mask_mod_info[3].price and mask_mod_info[3].price > 0 then
				updated_texts[2].text = updated_texts[2].text .. " " .. managers.experience:cash_string(mask_mod_info[3].price)
			end

			updated_texts[2].text = updated_texts[2].text .. "\n"
		else
			updated_texts[2].text = updated_texts[2].text .. colors_text .. ": " .. "##" .. managers.localization:to_upper_text("menu_bm_not_selected") .. "##" .. "\n"

			table.insert(resource_color, tweak_data.screen_colors.important_1)
		end

		updated_texts[2].text = updated_texts[2].text .. "\n"
		local price, can_afford = managers.blackmarket:get_customize_mask_value()

		if slot_data.global_value then
			local mask = managers.blackmarket:get_crafted_category("masks")[slot_data.prev_slot] or {}
			updated_texts[4].text = "\n\n" .. managers.localization:to_upper_text("menu_bm_highlighted") .. "\n" .. slot_data.name_localized
			local mod_price = managers.money:get_mask_part_price_modified(slot_data.category, slot_data.name, slot_data.global_value, mask.mask_id) or 0

			if mod_price > 0 then
				updated_texts[4].text = updated_texts[4].text .. " " .. managers.experience:cash_string(mod_price)
			else
				updated_texts[4].text = updated_texts[4].text
			end

			if slot_data.unlocked and slot_data.unlocked ~= true and slot_data.unlocked ~= 0 then
				updated_texts[4].text = updated_texts[4].text .. "\n" .. managers.localization:to_upper_text("bm_menu_item_amount", {
					amount = math.abs(slot_data.unlocked)
				})
			end

			updated_texts[4].resource_color = {}

			if slot_data.global_value and slot_data.global_value ~= "normal" then
				updated_texts[4].text = updated_texts[4].text .. "\n##" .. managers.localization:to_upper_text(tweak_data.lootdrop.global_values[slot_data.global_value].desc_id) .. "##"

				table.insert(updated_texts[4].resource_color, tweak_data.lootdrop.global_values[slot_data.global_value].color)
			end

			if slot_data.dlc_locked then
				updated_texts[3].text = managers.localization:to_upper_text(slot_data.dlc_locked)
			end

			local customize_mask_blueprint = managers.blackmarket:get_customize_mask_blueprint()
			local index = {
				colors = 3,
				materials = 1,
				textures = 2
			}
			index = index[slot_data.category]

			if index == 1 then
				customize_mask_blueprint.material = {
					global_value = slot_data.global_value,
					id = slot_data.name
				}
			elseif index == 2 then
				customize_mask_blueprint.pattern = {
					global_value = slot_data.global_value,
					id = slot_data.name
				}
			elseif index == 3 then
				customize_mask_blueprint.color = {
					global_value = slot_data.global_value,
					id = slot_data.name
				}
			end

			local part_info = managers.blackmarket:get_info_from_mask_blueprint(customize_mask_blueprint, mask.mask_id)
			part_info = part_info[index]

			if part_info.override then
				updated_texts[4].text = updated_texts[4].text .. "\n##" .. managers.localization:to_upper_text("menu_bm_overwrite", {
					category = managers.localization:text("bm_menu_" .. part_info.override)
				}) .. "##"

				table.insert(updated_texts[4].resource_color, tweak_data.screen_colors.risk)
			end
		end

		if price and price > 0 then
			updated_texts[2].text = updated_texts[2].text .. managers.localization:to_upper_text("menu_bm_total_cost", {
				cost = (not can_afford and "##" or "") .. managers.experience:cash_string(price) .. (not can_afford and "##" or "")
			})

			if not can_afford then
				table.insert(resource_color, tweak_data.screen_colors.important_1)
			end
		end

		if #resource_color == 1 then
			updated_texts[2].resource_color = resource_color[1]
		else
			updated_texts[2].resource_color = resource_color
		end

		if not managers.blackmarket:can_finish_customize_mask() then
			local list_of_mods = ""
			local missed_mods = {}

			for _, data in ipairs(mask_mod_info) do
				if not data.is_good and not data.overwritten then
					table.insert(missed_mods, managers.localization:text(data.text))
				end
			end

			if #missed_mods > 1 then
				for i = 1, #missed_mods, 1 do
					list_of_mods = list_of_mods .. missed_mods[i]

					if i < #missed_mods - 1 then
						list_of_mods = list_of_mods .. ", "
					elseif i == #missed_mods - 1 then
						list_of_mods = list_of_mods .. ", "
					end
				end
			elseif #missed_mods == 1 then
				list_of_mods = missed_mods[1]
			end

			if slot_data.dlc_locked then
				updated_texts[3].text = updated_texts[3].text .. "\n" .. managers.localization:to_upper_text("bm_menu_missing_to_finalize_mask", {
					missed_mods = list_of_mods
				}) .. "\n"
			else
				updated_texts[3].text = managers.localization:to_upper_text("bm_menu_missing_to_finalize_mask", {
					missed_mods = list_of_mods
				}) .. "\n"
			end
		elseif price and managers.money:total() < price then
			if slot_data.dlc_locked then
				updated_texts[3].text = updated_texts[3].text .. "\n" .. managers.localization:to_upper_text("bm_menu_not_enough_cash") .. "\n"
			else
				updated_texts[3].text = managers.localization:to_upper_text("bm_menu_not_enough_cash") .. "\n"
			end
		end
	elseif identifier == self.identifiers.deployable then
		updated_texts[1].text = slot_data.name_localized

		if not self._slot_data.unlocked then
			updated_texts[3].text = managers.localization:to_upper_text(slot_data.level == 0 and (slot_data.skill_name or "bm_menu_skilltree_locked") or "bm_menu_level_req", {
				level = slot_data.level,
				SKILL = slot_data.name
			})
			updated_texts[3].text = updated_texts[3].text .. "\n"
		end

		updated_texts[4].text = managers.localization:text(tweak_data.blackmarket.deployables[slot_data.name].desc_id, {
			BTN_INTERACT = managers.localization:btn_macro("interact", true),
			BTN_USE_ITEM = managers.localization:btn_macro("use_item", true)
		})
	elseif identifier == self.identifiers.character then
		updated_texts[1].text = slot_data.name_localized

		if not slot_data.unlocked then
			local dlc_text_id = slot_data.dlc_locked or "ERR"
			local text = managers.localization:to_upper_text(dlc_text_id, {}) .. "\n"
			updated_texts[3].text = text
		end

		updated_texts[4].text = managers.localization:text(slot_data.name .. "_desc")
	elseif identifier == self.identifiers.weapon_cosmetic then
		updated_texts[1].text = managers.localization:to_upper_text("bm_menu_steam_item_name", {
			type = managers.localization:text("bm_menu_" .. slot_data.category),
			name = slot_data.name_localized
		})
		updated_texts[1].resource_color = tweak_data.screen_colors.text

		if slot_data.weapon_id then
			updated_texts[2].text = managers.weapon_factory:get_weapon_name_by_weapon_id(slot_data.weapon_id)
		end

		updated_texts[4].resource_color = {}
		local cosmetic_rarity = slot_data.cosmetic_rarity
		local cosmetic_quality = slot_data.cosmetic_quality
		local cosmetic_bonus = slot_data.cosmetic_bonus

		if slot_data.is_a_color_skin then
			if slot_data.equipped then
				local color_id = slot_data.name
				local color_tweak = tweak_data.blackmarket.weapon_skins[color_id]

				if not slot_data.unlocked then
					local global_value = slot_data.global_value
					local gvalue_tweak = tweak_data.lootdrop.global_values[global_value]
					local dlc = color_tweak.dlc or managers.dlc:global_value_to_dlc(global_value)
					local unlocked = not dlc or managers.dlc:is_dlc_unlocked(dlc)
					local have_color = managers.blackmarket:has_item(global_value, "weapon_skins", color_id)

					if not unlocked then
						updated_texts[5].text = managers.localization:text(gvalue_tweak and gvalue_tweak.unlock_id or "bm_menu_dlc_locked")
					elseif not have_color then
						local achievement_locked_content = managers.dlc:weapon_color_achievement_locked_content(color_id)
						local dlc_tweak = tweak_data.dlc[achievement_locked_content]
						local achievement = dlc_tweak and dlc_tweak.achievement_id

						if achievement and managers.achievment:get_info(achievement) then
							local achievement_visual = tweak_data.achievement.visual[achievement]
							updated_texts[5].text = managers.localization:text(achievement_visual and achievement_visual.desc_id or "achievement_" .. tostring(achievement) .. "_desc" or "bm_menu_dlc_locked")
						else
							updated_texts[5].text = managers.localization:text("bm_menu_dlc_locked")
						end
					end
				end

				local name_string = managers.localization:to_upper_text(color_tweak.name_id)
				local color_index_string = managers.localization:to_upper_text("bm_menu_weapon_color_index", {
					variation = managers.localization:text(tweak_data.blackmarket:get_weapon_color_index_string(slot_data.cosmetic_color_index))
				})
				local quality_string = managers.localization:to_upper_text("bm_menu_weapon_color_quality", {
					quality = managers.localization:text(tweak_data.economy.qualities[cosmetic_quality].name_id)
				})
				updated_texts[4].text = updated_texts[4].text .. name_string .. "\n" .. color_index_string .. "\n" .. quality_string

				table.insert(updated_texts[4].resource_color, tweak_data.screen_colors.text)
				table.insert(updated_texts[4].resource_color, tweak_data.economy.qualities[cosmetic_quality].color or tweak_data.screen_colors.text)
			else
				updated_texts[4].text = updated_texts[4].text .. managers.localization:text("bm_menu_customizable_weapon_color_desc")
			end
		else
			if not slot_data.unlocked then
				local safe = self:get_safe_for_economy_item(slot_data.name)
				safe = safe and safe.name_id or "invalid skin"
				local macros = {
					safe = managers.localization:text(safe)
				}
				local lock_text_id = slot_data.lock_text_id or "bm_menu_wcc_not_owned"
				updated_texts[5].text = (slot_data.default_blueprint and "" or "\n") .. managers.localization:text(lock_text_id, macros)
			end

			if cosmetic_rarity then
				updated_texts[4].text = updated_texts[4].text .. managers.localization:to_upper_text("bm_menu_steam_item_rarity", {
					rarity = managers.localization:text(tweak_data.economy.rarities[cosmetic_rarity].name_id)
				})

				table.insert(updated_texts[4].resource_color, tweak_data.economy.rarities[cosmetic_rarity].color or tweak_data.screen_colors.text)
			end

			if cosmetic_quality then
				updated_texts[4].text = updated_texts[4].text .. (cosmetic_rarity and "\n" or "") .. managers.localization:to_upper_text("bm_menu_steam_item_quality", {
					quality = managers.localization:text(tweak_data.economy.qualities[cosmetic_quality].name_id)
				})

				table.insert(updated_texts[4].resource_color, tweak_data.economy.qualities[cosmetic_quality].color or tweak_data.screen_colors.text)
			end

			if cosmetic_bonus then
				local bonus = tweak_data.blackmarket.weapon_skins[slot_data.cosmetic_id] and tweak_data.blackmarket.weapon_skins[slot_data.cosmetic_id].bonus

				if bonus then
					local bonus_tweak = tweak_data.economy.bonuses[bonus]
					local bonus_value = bonus_tweak.exp_multiplier and bonus_tweak.exp_multiplier * 100 - 100 .. "%" or bonus_tweak.money_multiplier and bonus_tweak.money_multiplier * 100 - 100 .. "%"
					updated_texts[4].text = updated_texts[4].text .. ((cosmetic_quality or cosmetic_rarity) and "\n" or "") .. managers.localization:text("dialog_new_tradable_item_bonus", {
						bonus = managers.localization:text(bonus_tweak.name_id, {
							team_bonus = bonus_value
						})
					})
				end
			end
		end

		if slot_data.desc_id and slot_data.unlocked then
			updated_texts[4].text = updated_texts[4].text .. "\n" .. managers.localization:text(slot_data.desc_id)
		end

		if slot_data.global_value and slot_data.global_value ~= "normal" then
			updated_texts[4].text = updated_texts[4].text .. "\n##" .. managers.localization:to_upper_text(tweak_data.lootdrop.global_values[slot_data.global_value].desc_id) .. "##"

			table.insert(updated_texts[4].resource_color, tweak_data.lootdrop.global_values[slot_data.global_value].color)
		end

		updated_texts[4].below_stats = true
	elseif identifier == self.identifiers.inventory_tradable then
		if slot_data.name ~= "empty" then
			updated_texts[1].text = managers.localization:to_upper_text("bm_menu_steam_item_name", {
				type = managers.localization:text("bm_menu_" .. slot_data.category),
				name = slot_data.name_localized
			})
			updated_texts[1].resource_color = tweak_data.screen_colors.text

			if slot_data.category == "weapon_skins" then
				updated_texts[1].text = ""
				local name_string = ""

				if slot_data.weapon_id then
					name_string = utf8.to_upper(managers.weapon_factory:get_weapon_name_by_weapon_id(slot_data.weapon_id)) .. " | "
				end

				name_string = name_string .. slot_data.name_localized
				local stat_bonus, team_bonus = nil

				if slot_data.cosmetic_quality then
					name_string = name_string .. ", " .. managers.localization:text(tweak_data.economy.qualities[slot_data.cosmetic_quality].name_id)
				end

				if slot_data.cosmetic_bonus then
					local bonus = tweak_data.blackmarket.weapon_skins[slot_data.cosmetic_id] and tweak_data.blackmarket.weapon_skins[slot_data.cosmetic_id].bonus

					if bonus then
						name_string = name_string .. ", " .. managers.localization:text("menu_bm_inventory_bonus")
					end
				end

				updated_texts[2].text = "##" .. name_string .. "##"

				if slot_data.cosmetic_rarity then
					updated_texts[2].resource_color = tweak_data.economy.rarities[slot_data.cosmetic_rarity].color or tweak_data.screen_colors.text
				end

				updated_texts[4].text, updated_texts[4].resource_color = InventoryDescription.create_description_item({
					category = "weapon_skins",
					instance_id = 0,
					entry = slot_data.name,
					quality = slot_data.cosmetic_quality,
					bonus = slot_data.cosmetic_bonus
				}, tweak_data.blackmarket.weapon_skins[slot_data.name], {
					default = tweak_data.screen_colors.text,
					mods = tweak_data.screen_colors.text
				}, true)
				updated_texts[4].below_stats = true
			elseif slot_data.category == "armor_skins" then
				updated_texts[1].text = "##" .. updated_texts[1].text .. "##"

				if slot_data.cosmetic_rarity then
					updated_texts[1].resource_color = tweak_data.economy.rarities[slot_data.cosmetic_rarity].color or tweak_data.screen_colors.text
				end

				updated_texts[2].text = managers.localization:text(slot_data.desc_id)
			elseif slot_data.safe_entry then
				local content_text, color_ranges = InventoryDescription.create_description_safe(slot_data.safe_entry, {}, true)
				updated_texts[2].text = content_text
				updated_texts[2].resource_color = color_ranges
			elseif slot_data.desc_id then
				updated_texts[2].text = managers.localization:text(slot_data.desc_id)
			end
		end
	elseif identifier == self.identifiers.custom then
		if self._data.custom_update_text_info then
			self._data.custom_update_text_info(slot_data, updated_texts, self)
		end
	elseif Application:production_build() then
		updated_texts[1].text = identifier:s()
	end

	if identifier == self.identifiers.armor then
		self._stats_panel:set_top(self._armor_info_panel:bottom() + 10)
	end

	if self._desc_mini_icons then
		for _, gui_object in pairs(self._desc_mini_icons) do
			self._panel:remove(gui_object[1])
		end
	end

	self._desc_mini_icons = {}
	local desc_mini_icons = self._slot_data.desc_mini_icons
	local info_box_panel = self._panel:child("info_box_panel")

	if desc_mini_icons and table.size(desc_mini_icons) > 0 then
		for _, mini_icon in pairs(desc_mini_icons) do
			local new_icon = self._panel:bitmap({
				layer = 1,
				texture = mini_icon.texture,
				x = info_box_panel:left() + 10 + mini_icon.right,
				w = mini_icon.w or 32,
				h = mini_icon.h or 32
			})

			table.insert(self._desc_mini_icons, {
				new_icon,
				2
			})
		end

		updated_texts[2].text = string.rep("     ", table.size(desc_mini_icons)) .. updated_texts[2].text
	end

	if not ignore_lock and slot_data.lock_texture and slot_data.lock_texture ~= true then
		local new_icon = self._panel:bitmap({
			h = 20,
			blend_mode = "add",
			w = 20,
			layer = 1,
			texture = slot_data.lock_texture,
			texture_rect = slot_data.lock_rect or nil,
			x = info_box_panel:left() + 10,
			color = self._info_texts[3]:color()
		})
		updated_texts[3].text = "     " .. updated_texts[3].text

		table.insert(self._desc_mini_icons, {
			new_icon,
			3
		})
	end

	if is_renaming_this and self._rename_info_text then
		local text = self._renaming_item.custom_name ~= "" and self._renaming_item.custom_name or "##" .. tostring(slot_data.raw_name_localized) .. "##"
		updated_texts[self._rename_info_text].text = text
		updated_texts[self._rename_info_text].resource_color = tweak_data.screen_colors.text:with_alpha(0.35)
	end

	for id, _ in ipairs(self._info_texts) do
		self:set_info_text(id, updated_texts[id].text, updated_texts[id].resource_color)
	end

	local _, _, _, th = self._info_texts[1]:text_rect()

	self._info_texts[1]:set_h(th)

	local y = self._info_texts[1]:bottom()
	local title_offset = y
	local bg = self._info_texts_bg[1]

	if alive(bg) then
		bg:set_shape(self._info_texts[1]:shape())
	end

	local below_y = nil

	for i = 2, #self._info_texts, 1 do
		local info_text = self._info_texts[i]

		info_text:set_font_size(small_font_size)
		info_text:set_w(self._info_texts_panel:w())

		_, _, _, th = info_text:text_rect()

		info_text:set_y(y)
		info_text:set_h(th)

		if updated_texts[i].below_stats then
			if slot_data.comparision_data and alive(self._stats_text_modslist) then
				info_text:set_world_y(below_y or self._stats_text_modslist:world_top())

				below_y = (below_y or info_text:world_y()) + th
			else
				info_text:set_top((below_y or info_text:top()) + 20)

				below_y = (below_y or info_text:top()) + th
			end
		end

		local scale = 1
		local attempts = 5
		local max_h = self._info_texts_panel:h() - info_text:top()

		if not updated_texts[i].below_stats and slot_data.comparision_data and alive(self._stats_panel) then
			max_h = self._stats_panel:world_top() - info_text:world_top()
		end

		if info_text:h() ~= 0 and max_h > 0 and max_h < info_text:h() then
			local font_size = info_text:font_size()
			local wanted_h = max_h

			while info_text:h() ~= 0 and not math.within(math.ceil(info_text:h()), wanted_h - 10, wanted_h) and attempts > 0 do
				scale = wanted_h / info_text:h()
				font_size = math.clamp(font_size * scale, 0, small_font_size)

				info_text:set_font_size(font_size)

				_, _, _, th = info_text:text_rect()

				info_text:set_h(th)

				attempts = attempts - 1
			end

			if info_text:h() ~= 0 and info_text:h() > self._info_texts_panel:h() - info_text:top() then
				print("[BlackMarketGui] Info text dynamic font sizer failed")

				scale = (self._info_texts_panel:h() - info_text:top()) / info_text:h()

				info_text:set_font_size(font_size * scale)

				_, _, _, th = info_text:text_rect()

				info_text:set_h(th)
			end
		end

		local bg = self._info_texts_bg[i]

		if alive(bg) then
			bg:set_shape(info_text:shape())
		end

		y = info_text:bottom()
	end

	for _, desc_mini_icon in ipairs(self._desc_mini_icons) do
		desc_mini_icon[1]:set_y(title_offset)
		desc_mini_icon[1]:set_world_top(self._info_texts[desc_mini_icon[2]]:world_top() + 1)
	end

	if is_renaming_this and self._rename_info_text and self._rename_caret then
		local info_text = self._info_texts[self._rename_info_text]
		local x, y, w, h = info_text:text_rect()

		if self._renaming_item.custom_name == "" then
			w = 0
		end

		self._rename_caret:set_w(2)
		self._rename_caret:set_h(h)
		self._rename_caret:set_world_position(x + w, y)
	end
end

function BlackMarketGui.create_safe_content_text(safe_entry)
	local safe_td = tweak_data.economy.safes[safe_entry]

	if not safe_td then
		return "", {}
	end

	local content_td = tweak_data.economy.contents[safe_td.content]

	if not content_td then
		return "", {}
	end

	local text = ""
	local color_ranges = {}
	local items_list = {}

	for category, items in pairs(content_td.contains) do
		for _, item in ipairs(items) do
			items_list[#items_list + 1] = {
				category = category,
				entry = item
			}
		end
	end

	local x_td, y_td, xr_td, yr_td = nil

	local function sort_func(x, y)
		x_td = (tweak_data.economy[x.category] or tweak_data.blackmarket[x.category])[x.entry]
		y_td = (tweak_data.economy[y.category] or tweak_data.blackmarket[y.category])[y.entry]
		xr_td = tweak_data.economy.rarities[x_td.rarity or "common"]
		yr_td = tweak_data.economy.rarities[y_td.rarity or "common"]

		if xr_td.index ~= yr_td.index then
			return xr_td.index < yr_td.index
		end

		return x.entry < y.entry
	end

	table.sort(items_list, sort_func)

	local td = nil

	for _, item in ipairs(items_list) do
		td = (tweak_data.economy[item.category] or tweak_data.blackmarket[item.category])[item.entry]

		if item.category == "contents" and td.rarity == "legendary" then
			text = text .. "##" .. managers.localization:text("bm_menu_rarity_legendary_item_long") .. "##"
		else
			text = text .. "##" .. (td.weapon_id and utf8.to_upper(managers.weapon_factory:get_weapon_name_by_weapon_id(td.weapon_id)) .. " | " or "") .. managers.localization:text(td.name_id or "NONAME") .. "##"
		end

		table.insert(color_ranges, tweak_data.economy.rarities[td.rarity or "common"].color)

		if _ ~= #items_list then
			text = text .. "\n"
		end
	end

	return text, color_ranges
end

function BlackMarketGui:animate_text_bounce(bounce_panel)
	local dt = 0
	local bounce_dir_up = true
	local top = bounce_panel:top()
	local move = 0

	while true do
		dt = coroutine.yield()

		bounce_panel:move(0, move)

		if move == 0 then
			bounce_dir_up = not bounce_dir_up
		end
	end
end

function BlackMarketGui:set_info_text(id, new_string, resource_color)
	local info_text = self._info_texts[id]
	local text = new_string

	self._info_texts_bg[id]:set_visible(false)
	info_text:set_blend_mode("add")
	info_text:set_color(self._info_texts_color[id] or Color.white)
	info_text:clear_range_color(0, utf8.len(info_text:text()))

	local start_ci, end_ci, first_ci = nil

	if resource_color then
		local text_dissected = utf8.characters(text)
		local idsp = Idstring("#")
		start_ci = {}
		end_ci = {}
		first_ci = true

		for i, c in ipairs(text_dissected) do
			if Idstring(c) == idsp then
				local next_c = text_dissected[i + 1]

				if next_c and Idstring(next_c) == idsp then
					if first_ci then
						table.insert(start_ci, i)
					else
						table.insert(end_ci, i)
					end

					first_ci = not first_ci
				end
			end
		end

		if #start_ci == #end_ci then
			for i = 1, #start_ci, 1 do
				start_ci[i] = start_ci[i] - ((i - 1) * 4 + 1)
				end_ci[i] = end_ci[i] - (i * 4 - 1)
			end
		end

		text = string.gsub(text, "##", "")
	end

	info_text:set_text(text)
	info_text:set_alpha(1)

	if resource_color then
		info_text:clear_range_color(1, utf8.len(text))

		if #start_ci ~= #end_ci then
			Application:error("BlackMarketGui: Missing ##'s in :set_info_text() string!", id, new_string, #start_ci, #end_ci)
		else
			for i = 1, #start_ci, 1 do
				info_text:set_range_color(start_ci[i], end_ci[i], type(resource_color) == "table" and resource_color[i] or resource_color)
			end
		end
	end
end

function BlackMarketGui:_round_everything()
	if alive(self._panel) then
		for i, d in ipairs(self._panel:children()) do
			self:_rec_round_object(d)
		end
	end

	if alive(self._fullscreen_panel) then
		for i, d in ipairs(self._fullscreen_panel:children()) do
			self:_rec_round_object(d)
		end
	end
end

function BlackMarketGui:_rec_round_object(object)
	local x, y, w, h = object:shape()

	object:set_shape(math.round(x), math.round(y), math.round(w), math.round(h))

	if object.children then
		for i, d in ipairs(object:children()) do
			self:_rec_round_object(d)
		end
	end
end

function BlackMarketGui:mouse_moved(o, x, y)
	if managers.menu_scene and managers.menu_scene:input_focus() then
		return false
	end

	if not self._enabled then
		return
	end

	if self._renaming_item then
		return true, "link"
	end

	if alive(self._no_input_panel) then
		self._no_input = self._no_input_panel:inside(x, y) and self:input_focus() ~= true

		if self._no_input then
			return false, "arrow"
		end
	end

	if self._extra_options_data then
		local used = false
		local pointer = "arrow"
		self._extra_options_data.selected = self._extra_options_data.selected or 1
		local selected_slot = nil

		for i = 1, self._extra_options_data.num_panels, 1 do
			local option = self._extra_options_data[i]
			local panel = option.panel
			local image = option.image

			if alive(panel) and panel:inside(x, y) then
				if not option.highlighted then
					option.highlighted = true
				end

				used = true
				pointer = "link"
			elseif option.highlighted then
				option.highlighted = false
			end

			if alive(image) then
				image:set_alpha((option.selected and 1 or 0.9) * (option.highlighted and 1 or 0.9))
			end
		end

		if used then
			return used, pointer
		end
	elseif self._steam_inventory_extra_data and alive(self._steam_inventory_extra_data.gui_panel) then
		local used = false
		local pointer = "arrow"
		local extra_data = self._steam_inventory_extra_data

		if extra_data.arrow_left:inside(x, y) then
			if not extra_data.arrow_left_highlighted then
				extra_data.arrow_left_highlighted = true

				extra_data.arrow_left:set_color(tweak_data.screen_colors.button_stage_2)
				managers.menu_component:post_event("highlight")
			end

			used = true
			pointer = "link"
		elseif extra_data.arrow_left_highlighted then
			extra_data.arrow_left_highlighted = false

			extra_data.arrow_left:set_color(tweak_data.screen_colors.button_stage_3)
		end

		if extra_data.arrow_right:inside(x, y) then
			if not extra_data.arrow_right_highlighted then
				extra_data.arrow_right_highlighted = true

				extra_data.arrow_right:set_color(tweak_data.screen_colors.button_stage_2)
				managers.menu_component:post_event("highlight")
			end

			used = true
			pointer = "link"
		elseif extra_data.arrow_right_highlighted then
			extra_data.arrow_right_highlighted = false

			extra_data.arrow_right:set_color(tweak_data.screen_colors.button_stage_3)
		end

		if used then
			if alive(extra_data.bg) then
				extra_data.bg:set_color(tweak_data.screen_colors.button_stage_2:with_alpha(0.2))
				extra_data.bg:set_alpha(1)
			end

			return used, pointer
		elseif alive(extra_data.bg) then
			extra_data.bg:set_color(Color.black:with_alpha(0.5))
		end
	end

	local inside_tab_area = self._tab_area_panel:inside(x, y)
	local used = true
	local pointer = inside_tab_area and self._highlighted == self._selected and "arrow" or "link"
	local inside_tab_scroll = self._tab_scroll_panel:inside(x, y)
	local update_select = false

	if not self._highlighted then
		update_select = true
		used = false
		pointer = "arrow"
	elseif not inside_tab_scroll or self._tabs[self._highlighted] and not self._tabs[self._highlighted]:inside(x, y) then
		self._tabs[self._highlighted]:set_highlight(not self._pages, not self._pages)

		self._highlighted = nil
		update_select = true
		used = false
		pointer = "arrow"
	end

	if update_select then
		for i, tab in ipairs(self._tabs) do
			update_select = inside_tab_scroll and tab:inside(x, y)

			if update_select then
				self._highlighted = i

				self._tabs[self._highlighted]:set_highlight(self._selected ~= self._highlighted)

				used = true
				pointer = self._highlighted == self._selected and "arrow" or "link"
			end
		end
	end

	if self._tabs[self._selected] then
		local tab_used, tab_pointer = self._tabs[self._selected]:mouse_moved(x, y)

		if tab_used then
			local x, y = self._tabs[self._selected]:selected_slot_center()

			self._select_rect:set_world_center(x, y)
			self._select_rect:stop()
			self._select_rect_box:set_color(Color.white)
			self._select_rect:set_visible(self._tabs[self._selected]._grid_panel:top() < y and y < self._tabs[self._selected]._grid_panel:bottom() and self._selected_slot and self._selected_slot._name ~= "empty")

			used = tab_used
			pointer = tab_pointer
		end
	end

	if self._market_bundles then
		local active_bundle = self._market_bundles[self._data.active_market_bundle]

		if active_bundle then
			for key, data in pairs(active_bundle) do
				if key ~= "panel" and (alive(data.text) and data.text:inside(x, y) or alive(data.image) and data.image:inside(x, y)) then
					if not data.highlighted then
						data.highlighted = true

						if alive(data.image) then
							data.image:set_alpha(1)
						end

						if alive(data.text) then
							data.text:set_color(tweak_data.screen_colors.button_stage_2)
						end

						managers.menu_component:post_event("highlight")
					end

					if not used then
						used = true
						pointer = "link"
					end
				elseif data.highlighted then
					data.highlighted = false

					if alive(data.image) then
						data.image:set_alpha(0.9)
					end

					if alive(data.text) then
						data.text:set_color(tweak_data.screen_colors.button_stage_3)
					end
				end
			end
		end

		if self._market_bundles.arrow_left then
			if self._market_bundles.arrow_left:inside(x, y) then
				if not self._market_bundles.arrow_left_highlighted then
					self._market_bundles.arrow_left_highlighted = true

					managers.menu_component:post_event("highlight")
					self._market_bundles.arrow_left:set_color(tweak_data.screen_colors.button_stage_2)
				end

				if not used then
					used = true
					pointer = "link"
				end
			elseif self._market_bundles.arrow_left_highlighted then
				self._market_bundles.arrow_left_highlighted = false

				self._market_bundles.arrow_left:set_color(tweak_data.screen_colors.button_stage_3)
			end
		end

		if self._market_bundles.arrow_right then
			if self._market_bundles.arrow_right:inside(x, y) then
				if not self._market_bundles.arrow_right_highlighted then
					self._market_bundles.arrow_right_highlighted = true

					managers.menu_component:post_event("highlight")
					self._market_bundles.arrow_right:set_color(tweak_data.screen_colors.button_stage_2)
				end

				if not used then
					used = true
					pointer = "link"
				end
			elseif self._market_bundles.arrow_right_highlighted then
				self._market_bundles.arrow_right_highlighted = false

				self._market_bundles.arrow_right:set_color(tweak_data.screen_colors.button_stage_3)
			end
		end
	end

	if self._panel:child("back_button"):inside(x, y) then
		used = true
		pointer = "link"

		if not self._back_button_highlighted then
			self._back_button_highlighted = true

			self._panel:child("back_button"):set_color(tweak_data.screen_colors.button_stage_2)
			managers.menu_component:post_event("highlight")

			return used, pointer
		end
	elseif self._back_button_highlighted then
		self._back_button_highlighted = false

		self._panel:child("back_button"):set_color(tweak_data.screen_colors.button_stage_3)
	end

	update_select = false

	if not self._button_highlighted then
		update_select = true
	elseif self._btns[self._button_highlighted] and not self._btns[self._button_highlighted]:inside(x, y) then
		self._btns[self._button_highlighted]:set_highlight(false)

		self._button_highlighted = nil
		update_select = true
	end

	if update_select then
		for i, btn in pairs(self._btns) do
			if not self._button_highlighted and btn:visible() and btn:inside(x, y) then
				self._button_highlighted = i

				btn:set_highlight(true)
			else
				btn:set_highlight(false)
			end
		end
	end

	if self._button_highlighted then
		used = true
		pointer = "link"
	end

	if self._tab_scroll_table.left and self._tab_scroll_table.left_klick then
		local color = nil

		if self._tab_scroll_table.left:inside(x, y) then
			color = tweak_data.screen_colors.button_stage_2
			used = true
			pointer = "link"
		else
			color = tweak_data.screen_colors.button_stage_3
		end

		self._tab_scroll_table.left:set_color(color)
	end

	if self._tab_scroll_table.right and self._tab_scroll_table.right_klick then
		local color = nil

		if self._tab_scroll_table.right:inside(x, y) then
			color = tweak_data.screen_colors.button_stage_2
			used = true
			pointer = "link"
		else
			color = tweak_data.screen_colors.button_stage_3
		end

		self._tab_scroll_table.right:set_color(color)
	end

	if self._rename_info_text then
		local text_button = self._info_texts and self._info_texts[self._rename_info_text]

		if text_button then
			if self._slot_data and not self._slot_data.locked_name and text_button:inside(x, y) then
				if not self._rename_highlight then
					self._rename_highlight = true

					text_button:set_blend_mode("add")
					text_button:set_color(tweak_data.screen_colors.button_stage_2)

					local bg = self._info_texts_bg[self._rename_info_text]

					if alive(bg) then
						bg:set_visible(true)
						bg:set_color(tweak_data.screen_colors.button_stage_3)
					end

					managers.menu_component:post_event("highlight")
				end

				used = true
				pointer = "link"
			elseif self._rename_highlight then
				self._rename_highlight = false

				text_button:set_blend_mode("normal")
				text_button:set_color(tweak_data.screen_colors.text)

				local bg = self._info_texts_bg[self._rename_info_text]

				if alive(bg) then
					bg:set_visible(false)
					bg:set_color(Color.black)
				end
			end
		end
	end

	return used, pointer
end

function BlackMarketGui:mouse_pressed(button, x, y)
	if button == Idstring("1") and managers.player:has_category_upgrade("player", "second_deployable") and self._data[1].category == "deployables" then
		self:mouse_pressed(Idstring("0"), x, y)
	end

	if managers.menu_scene and managers.menu_scene:input_focus() then
		return false
	end

	if not self._enabled then
		return
	end

	if self._renaming_item then
		self:_stop_rename_item()

		return
	end

	if self._no_input then
		return
	end

	if self._extra_options_data then
		local selected_slot = nil

		if button == Idstring("0") or button == Idstring("1") then
			self._extra_options_data.selected = self._extra_options_data.selected or 1

			for i = 1, self._extra_options_data.num_panels, 1 do
				local option = self._extra_options_data[i]
				local panel = option.panel

				if alive(panel) and panel:inside(x, y) then
					selected_slot = i

					break
				end
			end
		end

		if selected_slot then
			self._extra_options_data.selected = selected_slot

			for i = 1, self._extra_options_data.num_panels, 1 do
				local option = self._extra_options_data[i]
				local box = option.box
				local image = option.image
				local selected = i == selected_slot

				if alive(box) then
					if selected and not option.selected then
						option.selected = true

						self:show_btns(self._selected_slot)
						self:_update_borders()
						self:update_info_text()
						managers.menu_component:post_event("highlight")
					elseif not selected then
						option.selected = false
					end

					box:set_visible(selected)
				end

				if alive(image) then
					image:set_alpha((option.selected and 1 or 0.9) * (option.highlighted and 1 or 0.9))
				end
			end

			return
		end
	elseif self._steam_inventory_extra_data and button == Idstring("0") and alive(self._steam_inventory_extra_data.gui_panel) and not self._input_wait_t then
		local extra_data = self._steam_inventory_extra_data

		if Global.blackmarket_manager.tradable_inventory_sort > 1 and extra_data.arrow_left:inside(x, y) then
			Global.blackmarket_manager.tradable_inventory_sort = math.max(Global.blackmarket_manager.tradable_inventory_sort - 1, 1)

			extra_data.choice_text:set_text(extra_data.choices[Global.blackmarket_manager.tradable_inventory_sort or 1])

			self._reload_in_t = 0.8
			self._input_wait_t = 0.2

			managers.menu:active_menu().renderer:disable_input(0.2)
			managers.menu_component:post_event("menu_enter")

			return
		end

		if Global.blackmarket_manager.tradable_inventory_sort < #tweak_data.gui.tradable_inventory_sort_list and extra_data.arrow_right:inside(x, y) then
			Global.blackmarket_manager.tradable_inventory_sort = math.min(Global.blackmarket_manager.tradable_inventory_sort + 1, #tweak_data.gui.tradable_inventory_sort_list)

			extra_data.choice_text:set_text(extra_data.choices[Global.blackmarket_manager.tradable_inventory_sort or 1])

			self._reload_in_t = 0.8
			self._input_wait_t = 0.2

			managers.menu:active_menu().renderer:disable_input(0.2)
			managers.menu_component:post_event("menu_enter")

			return
		end
	end

	local holding_shift = false
	local scroll_button_pressed = button == Idstring("mouse wheel up") or button == Idstring("mouse wheel down")
	local inside_tab_area = self._tab_area_panel:inside(x, y) or self._data.scroll_tab_anywhere

	if inside_tab_area then
		if button == Idstring("mouse wheel down") then
			self:next_page(true)

			return
		elseif button == Idstring("mouse wheel up") then
			self:previous_page(true)

			return
		end
	elseif self._tabs[self._selected] and scroll_button_pressed then
		local selected_slot = self._tabs[self._selected]:mouse_pressed(button, x, y)

		self:on_slot_selected(selected_slot)

		if selected_slot then
			return
		end
	end

	if button ~= Idstring("0") or button == Idstring("1") then
		return
	end

	if self._panel:child("back_button"):inside(x, y) then
		managers.menu:back(true)

		return
	end

	if self._tab_scroll_table.left_klick and self._tab_scroll_table.left:inside(x, y) then
		self:previous_page()

		return
	end

	if self._tab_scroll_table.right_klick and self._tab_scroll_table.right:inside(x, y) then
		self:next_page()

		return
	end

	if self._market_bundles then
		local active_bundle = self._market_bundles[self._data.active_market_bundle]

		if active_bundle then
			if active_bundle.safe.text:inside(x, y) or active_bundle.safe.image:inside(x, y) then
				managers.menu:open_node("inventory_tradable_container_show", {
					{
						container = {
							show_only = true,
							content = active_bundle.safe.entry,
							drill = active_bundle.drill.entry,
							safe = active_bundle.safe.entry,
							num_bundles = self._market_bundles.num_bundles,
							active_market_bundle = self._data.active_market_bundle,
							market_bundles = self._market_bundles.market_bundles
						}
					}
				})
				managers.menu_component:post_event("menu_enter")

				return
			end

			if active_bundle.drill.text and active_bundle.drill.text:inside(x, y) or active_bundle.drill.image and active_bundle.drill.image:inside(x, y) then
				MenuCallbackHandler:steam_buy_drill(nil, {
					drill = active_bundle.drill.entry
				})
				managers.menu_component:post_event("menu_enter")

				return
			end
		end

		if self._market_bundles.arrow_left and self._market_bundles.arrow_left:inside(x, y) then
			local active_bundle = self._market_bundles[self._data.active_market_bundle]

			active_bundle.panel:hide()

			self._data.active_market_bundle = self._data.active_market_bundle - 1

			if self._data.active_market_bundle == 0 then
				self._data.active_market_bundle = self._market_bundles.num_bundles
			end

			active_bundle = self._market_bundles[self._data.active_market_bundle]

			active_bundle.panel:show()
			managers.menu_component:post_event("menu_enter")

			return
		end

		if self._market_bundles.arrow_right and self._market_bundles.arrow_right:inside(x, y) then
			local active_bundle = self._market_bundles[self._data.active_market_bundle]

			active_bundle.panel:hide()

			self._data.active_market_bundle = self._data.active_market_bundle % self._market_bundles.num_bundles + 1
			active_bundle = self._market_bundles[self._data.active_market_bundle]

			active_bundle.panel:show()
			managers.menu_component:post_event("menu_enter")

			return
		end
	end

	if self._selected_slot and self._selected_slot._equipped_rect then
		self._selected_slot._equipped_rect:set_alpha(1)
	end

	if self._tab_scroll_panel:inside(x, y) and self._tabs[self._highlighted] and self._tabs[self._highlighted]:inside(x, y) ~= 1 then
		if self._selected ~= self._highlighted then
			self:set_selected_tab(self._highlighted)
		end

		return
	elseif self._tabs[self._selected] then
		local selected_slot = self._tabs[self._selected]:mouse_pressed(button, x, y)

		self:on_slot_selected(selected_slot)

		if selected_slot then
			return
		end
	end

	if self._rename_info_text then
		local text_button = self._info_texts and self._info_texts[self._rename_info_text]

		if self._slot_data and not self._slot_data.locked_name and text_button and text_button:inside(x, y) then
			if managers.menu:is_steam_controller() then
				self:rename_item_with_gamepad_callback(self._slot_data)
			else
				local category = self._slot_data.category
				local slot = self._slot_data.slot

				self:_start_rename_item(category, slot)
			end

			return
		end
	end

	if self._btns[self._button_highlighted] and self._btns[self._button_highlighted]:inside(x, y) then
		local data = self._btns[self._button_highlighted]._data

		if data.callback and (not self._button_press_delay or self._button_press_delay < TimerManager:main():time()) then
			managers.menu_component:post_event("menu_enter")
			data.callback(self._slot_data, self._data.topic_params)

			self._button_press_delay = TimerManager:main():time() + 0.2
		end
	end

	if self._selected_slot and self._selected_slot._equipped_rect then
		self._selected_slot._equipped_rect:set_alpha(0.6)
	end

	if _G.IS_VR and button == Idstring("0") and self._selected_slot._panel:inside(x, y) then
		self:press_first_btn(button)
	end
end

function BlackMarketGui:mouse_released(button, x, y)
	if not self._enabled then
		return
	end

	if self._tabs[self._selected] then
		self._tabs[self._selected]:mouse_released(button, x, y)
	end
end

function BlackMarketGui:mouse_clicked(o, button, x, y)
	if not self._enabled then
		return
	end

	self._mouse_click_index = ((self._mouse_click_index or 0) + 1) % 2
	self._mouse_click = self._mouse_click or {}
	self._mouse_click[self._mouse_click_index] = {
		button = button,
		x = x,
		y = y,
		selected_slot = self._selected_slot
	}
end

function BlackMarketGui:mouse_double_click(o, button, x, y)
	if not self._enabled then
		return
	end

	if not self._mouse_click or not self._mouse_click[0] or not self._mouse_click[1] then
		return
	end

	if not self._slot_data or self._mouse_click[0].selected_slot ~= self._mouse_click[1].selected_slot then
		return
	end

	if button == Idstring("0") then
		if not self._selected_slot._panel:inside(x, y) then
			return
		end

		if managers.system_menu and managers.system_menu:is_active() and not managers.system_menu:is_closing() then
			return
		end

		self:press_first_btn(button)
	elseif button == Idstring("1") then
		if not self._selected_slot._panel:inside(x, y) then
			return
		end

		if managers.system_menu and managers.system_menu:is_active() and not managers.system_menu:is_closing() then
			return
		end

		self:press_second_btn(Idstring("0"))
	end
end

function BlackMarketGui:update(t, dt)
	if self._input_wait_t then
		self._input_wait_t = self._input_wait_t - dt

		if self._input_wait_t <= 0 then
			self._input_wait_t = nil
		end
	end

	if self._reload_in_t then
		self._reload_in_t = self._reload_in_t - dt

		if self._reload_in_t <= 0 then
			self._reload_in_t = nil

			self:reload()
		end
	end

	if self._preloading_list and #self._preloading_list > 0 then
		if not self._preload_ws then
			self:create_preload_ws()

			self._streaming_preload = nil
		elseif not self._streaming_preload then
			self._preloading_index = self._preloading_index + 1

			if self._preloading_index > #self._preloading_list then
				self._preloading_list = {}
				self._preloading_index = 0

				if self._preload_ws then
					managers.gui_data:destroy_workspace(self._preload_ws)

					self._preload_ws = nil
				end
			elseif self._preload_ws then
				self._preload_ws:panel():script().set_progress(self._preloading_index)
			end
		end
	end
end

function BlackMarketGui:press_first_btn(button)
	local first_btn_callback = nil
	local first_btn_prio = 999
	local first_btn_visible = false

	if button == Idstring("0") then
		if self._slot_data.invalid_double_click then
			self:flash()
			managers.menu_component:post_event("menu_error")

			return true
		end

		if self._slot_data.double_click_btn then
			local btn = self._btns[self._slot_data.double_click_btn]

			if btn then
				first_btn_prio = btn._data.prio
				first_btn_callback = btn._data.callback
				first_btn_visible = btn:visible()
			end
		else
			for _, btn in pairs(self._btns) do
				if btn:visible() and btn._data.prio < first_btn_prio then
					first_btn_prio = btn._data.prio
					first_btn_callback = btn._data.callback
					first_btn_visible = btn:visible()
				end

				if btn:visible() and btn._data.prio == first_btn_prio then
					first_btn_prio = btn._data.prio
					first_btn_callback = btn._data.callback
					first_btn_visible = btn:visible()
				end
			end
		end

		if first_btn_visible and first_btn_callback then
			managers.menu_component:post_event("menu_enter")
			first_btn_callback(self._slot_data, self._data.topic_params)

			return true
		else
			self:flash()
		end
	elseif button == Idstring("1") then
		-- Nothing
	end

	return false
end

function BlackMarketGui:press_second_btn(button)
	local second_btn_callback = nil
	local second_btn_prio = 999
	local second_btn_visible = false
	local first_btn_callback = nil
	local first_btn_prio = 999
	local first_btn_visible = false

	if button == Idstring("0") then
		if self._slot_data.double_click_btn then
			local btn = self._btns[self._slot_data.double_click_btn]

			if btn then
				second_btn_prio = btn._data.prio
				second_btn_callback = btn._data.callback
				second_btn_visible = btn:visible()
			end
		else
			for _, btn in pairs(self._btns) do
				if btn:visible() and btn._data.prio <= first_btn_prio then
					second_btn_prio = first_btn_prio
					second_btn_callback = first_btn_callback
					second_btn_visible = first_btn_visible
					first_btn_prio = btn._data.prio
					first_btn_callback = btn._data.callback
					first_btn_visible = btn:visible()
				elseif btn:visible() and btn._data.prio <= second_btn_prio and first_btn_prio < btn._data.prio then
					second_btn_prio = btn._data.prio
					second_btn_callback = btn._data.callback
					second_btn_visible = btn:visible()
				end
			end
		end

		if second_btn_visible and second_btn_callback then
			managers.menu_component:post_event("menu_enter")
			second_btn_callback(self._slot_data, self._data.topic_params)

			return true
		else
			self:flash()
		end
	elseif button == Idstring("1") then
		-- Nothing
	end

	return false
end

function BlackMarketGui:set_selected_tab(tab, no_sound)
	local selected_slot = nil

	if self._tabs[self._selected] then
		selected_slot = self._tabs[self._selected]._slot_selected

		self._tabs[self._selected]:deselect(false)
	end

	if self._selected_slot then
		self._selected_slot:set_btn_text()
	end

	self._selected = tab
	self._node:parameters().menu_component_selected = self._selected

	self._tabs[self._selected]:select(false, no_sound)

	self._selected_slot = self._tabs[self._selected]:select_slot(selected_slot, true)
	self._slot_data = self._selected_slot._data
	local x, y = self._tabs[self._selected]:selected_slot_center()
	local grid_panel_w = self._panel:w() * WIDTH_MULTIPLIER
	local grid_panel_h = (self._panel:h() - (self._real_medium_font_size + 10) - 60) * GRID_H_MUL
	local square_w = self._tabs[self._selected]._size_data.square_w or grid_panel_w / self._tabs[self._selected]._size_data.items_per_row
	local square_h = self._tabs[self._selected]._size_data.square_h or grid_panel_h / self._tabs[self._selected]._size_data.items_per_column
	local slot_dim_x = self._tabs[self._selected].my_slots_dimensions[1]
	local slot_dim_y = self._tabs[self._selected].my_slots_dimensions[2]
	local _, any_slot = next(self._tabs[self._selected]._slots)

	if any_slot then
		self._select_rect:set_size(any_slot._panel:size())
	end

	self._select_rect_box:create_sides(self._select_rect, {
		sides = {
			2,
			2,
			2,
			2
		}
	})
	self._select_rect_box:set_clipping(false)
	self._select_rect:set_world_center(x, y)
	self._select_rect:stop()
	self._select_rect_box:set_color(Color.white)
	self._select_rect:set_visible(self._tabs[self._selected]._grid_panel:top() < y and y < self._tabs[self._selected]._grid_panel:bottom() and self._selected_slot and self._selected_slot._name ~= "empty")
	self:show_btns(self._selected_slot)
	self:set_tab_positions()

	local visibility_visible = false

	if self._selected_slot then
		if self._selected_slot._equipped_rect then
			self._selected_slot._equipped_rect:set_alpha(0.6)
		end

		local slot_category = self._selected_slot._data.category
		visibility_visible = (slot_category == "primaries" or slot_category == "secondaries" or slot_category == "armors" or slot_category == "melee_weapons") and not self._data.buying_weapon

		if self._data.hide_detection_panel then
			visibility_visible = false
		end
	end

	self._detection_panel:set_visible(visibility_visible)
	self:_update_borders()
	self:show_stats()
	self:update_info_text()

	if alive(self._steam_inventory_extra_panel) then
		self._steam_inventory_extra_panel:set_world_right(self._tabs[self._selected]._grid_panel:world_right())
	end

	self._box_panel:set_shape(self._tabs[self._selected]._grid_panel:shape())
	self._box:create_sides(self._box_panel, {
		sides = {
			1,
			1,
			1 + (#self._tabs > 1 and 1 or 0),
			1
		}
	})

	if not self._data.can_move_over_tabs and managers.blackmarket:get_hold_crafted_item() then
		self:drop_hold_crafted_item_callback()
	end
end

function BlackMarketGui:set_tab_positions()
	local first_x = self._tab_scroll_table[1]:left()
	local diff_x = self._tab_scroll_table[self._selected]:left()

	if diff_x < 0 then
		local tab_x = first_x - diff_x

		for _, tab in ipairs(self._tabs) do
			tab_x = tab:set_tab_position(tab_x)
		end
	end

	diff_x = self._tab_scroll_table[self._selected]:right() - self._tab_scroll_table.panel:w()

	if diff_x > 0 then
		local tab_x = -(diff_x - first_x)

		for _, tab in ipairs(self._tabs) do
			tab_x = tab:set_tab_position(tab_x)
		end
	end

	if managers.menu:is_pc_controller() and not managers.menu:is_steam_controller() then
		if self._tab_scroll_table.left then
			if self._selected > 1 then
				self._tab_scroll_table.left_klick = true

				self._tab_scroll_table.left:set_text("<")
			else
				self._tab_scroll_table.left_klick = false

				self._tab_scroll_table.left:set_text(" ")
			end
		end

		if self._tab_scroll_table.right then
			if self._selected < #self._tab_scroll_table then
				self._tab_scroll_table.right_klick = true

				self._tab_scroll_table.right:set_text(">")
			else
				self._tab_scroll_table.right_klick = false

				self._tab_scroll_table.right:set_text(" ")
			end
		end
	else
		if alive(self._panel:child("prev_page")) then
			self._panel:child("prev_page"):set_visible(self._selected > 1)
		end

		if alive(self._panel:child("next_page")) then
			self._panel:child("next_page"):set_visible(self._selected < #self._tabs)
		end
	end
end

function BlackMarketGui:on_slot_selected(selected_slot)
	if selected_slot then
		local x, y = self._tabs[self._selected]:selected_slot_center()

		self._select_rect:set_world_center(x, y)
		self._select_rect:stop()
		self._select_rect_box:set_color(Color.white)
		self._select_rect:set_visible(self._tabs[self._selected]._grid_panel:top() < y and y < self._tabs[self._selected]._grid_panel:bottom() and selected_slot and selected_slot._name ~= "empty")

		if self._selected_slot then
			self._selected_slot:set_btn_text()
		end

		self._selected_slot = selected_slot
		self._slot_data = self._selected_slot._data

		self:show_btns(self._selected_slot)

		local visibility_visible = false

		if self._selected_slot then
			if self._selected_slot._equipped_rect then
				self._selected_slot._equipped_rect:set_alpha(0.6)
			end

			local slot_category = self._selected_slot._data.category
			visibility_visible = (slot_category == "primaries" or slot_category == "secondaries" or slot_category == "armors" or slot_category == "melee_weapons") and not self._data.buying_weapon

			if self._data.hide_detection_panel then
				visibility_visible = false
			end
		end

		self._detection_panel:set_visible(visibility_visible)
		self:_update_borders()
		self:show_stats()
		self:update_info_text()
	end
end

function BlackMarketGui:move(mx, my)
	if not self._tabs[self._selected] then
		return
	end

	local slot = self._tabs[self._selected]._slot_selected

	if not slot then
		return
	end

	local dim_x = self._tabs[self._selected].my_slots_dimensions[1]
	local dim_y = self._tabs[self._selected].my_slots_dimensions[2]
	local scroll_y = self._tabs[self._selected].my_scroll_slots_y

	if dim_y == 1 then
		local new_selected = math.clamp(slot + mx, 1, #self._tabs[self._selected]:slots())
		local slot = self._tabs[self._selected]:select_slot(new_selected, new_selected == slot)

		self:on_slot_selected(slot)
	else
		local x = (slot - 1) % dim_x + 1
		local y = math.ceil(slot / dim_x)
		x = math.clamp(x + mx, 1, dim_x)
		y = math.clamp(y + my, 1, scroll_y)
		local new_selected = x + (y - 1) * dim_x
		local slot = self._tabs[self._selected]:select_slot(new_selected, new_selected == slot)

		self:on_slot_selected(slot)
	end
end

function BlackMarketGui:move_up()
	if not self._enabled then
		return
	end

	if self._renaming_item then
		return
	end

	self:move(0, -1)
end

function BlackMarketGui:move_down()
	if not self._enabled then
		return
	end

	if self._renaming_item then
		return
	end

	self:move(0, 1)
end

function BlackMarketGui:move_left()
	if not self._enabled then
		return
	end

	if self._renaming_item then
		return
	end

	self:move(-1, 0)
end

function BlackMarketGui:move_right()
	if not self._enabled then
		return
	end

	if self._renaming_item then
		return
	end

	self:move(1, 0)
end

function BlackMarketGui:next_page(no_sound)
	if not self._enabled then
		return
	end

	if self._renaming_item then
		return
	end

	if self._pages then
		local old_selected = self._selected
		local s = math.min(self._selected + 1, #self._tabs)

		if old_selected == s then
			return
		end

		self:set_selected_tab(s, no_sound)
	end
end

function BlackMarketGui:previous_page(no_sound)
	if not self._enabled then
		return
	end

	if self._renaming_item then
		return
	end

	if self._pages then
		local old_selected = self._selected
		local s = math.max(self._selected - 1, 1)

		if old_selected == s then
			return
		end

		self:set_selected_tab(s, no_sound)
	end
end

function BlackMarketGui:press_pc_button(button)
	if not self._enabled then
		return
	end

	local btn = self._controllers_pc_mapping and self._controllers_pc_mapping[button:key()]

	if btn and btn._data and btn._data.callback and (not self._button_press_delay or self._button_press_delay < TimerManager:main():time()) then
		managers.menu_component:post_event("menu_enter")
		btn._data.callback(self._slot_data, self._data.topic_params)

		self._button_press_delay = TimerManager:main():time() + 0.2

		return true
	end

	return false
end

function BlackMarketGui:press_button(button)
	if not self._enabled then
		return
	end

	if self._renaming_item then
		return
	end

	local btn = self._controllers_mapping and self._controllers_mapping[button:key()]

	if btn and btn._data and btn._data.callback then
		if not self._button_press_delay or self._button_press_delay < TimerManager:main():time() then
			managers.menu_component:post_event("menu_enter")
			btn._data.callback(self._slot_data, self._data.topic_params)

			self._button_press_delay = TimerManager:main():time() + 0.2

			return true
		end
	elseif self._select_rect_box then
		self:flash()
	end

	return false
end

function BlackMarketGui:flash()
	local box = self._select_rect_box

	local function flash_anim(panel)
		local b_color = Color.white
		local s = 0

		over(0.5, function (t)
			s = math.min(1, math.sin(t * 180) * 2)

			box:set_color(math.lerp(b_color, tweak_data.screen_colors.important_1, s))
		end)
		box:set_color(b_color)
	end

	managers.menu_component:post_event("selection_next", true)
	self._select_rect:animate(flash_anim)
end

function BlackMarketGui:confirm_pressed()
	if not self._enabled then
		return
	end

	if self._renaming_item then
		self:_stop_rename_item()

		return
	end

	if managers.menu:is_pc_controller() and not managers.menu:is_steam_controller() then
		return self:press_first_btn(Idstring("0"))
	else
		return self:press_button("BTN_A")
	end
end

function BlackMarketGui:special_btn_pressed(button)
	if not self._enabled then
		return
	end

	if self._renaming_item then
		return
	end

	if self._extra_options_data then
		self._extra_options_data.selected = self._extra_options_data.selected or 1

		if button == Idstring("trigger_left") then
			self._extra_options_data.selected = math.max(self._extra_options_data.selected - 1, 1)
		elseif button == Idstring("trigger_right") then
			self._extra_options_data.selected = math.min(self._extra_options_data.selected + 1, self._extra_options_data.num_panels)
		end

		for i = 1, self._extra_options_data.num_panels, 1 do
			local option = self._extra_options_data[i]
			local box = option.box
			local image = option.image
			local selected = i == self._extra_options_data.selected

			if alive(box) then
				if selected and not option.selected then
					option.selected = true

					self:show_btns(self._selected_slot)
					self:_update_borders()
					self:update_info_text()
					managers.menu_component:post_event("highlight")
				elseif not selected then
					option.selected = false
				end

				box:set_visible(selected)
			end

			if alive(image) then
				image:set_alpha((option.selected and 1 or 0.9) * (option.highlighted and 1 or 0.9))
			end
		end
	elseif self._steam_inventory_extra_data and not self._input_wait_t and alive(self._steam_inventory_extra_data.gui_panel) then
		local extra_data = self._steam_inventory_extra_data

		if Global.blackmarket_manager.tradable_inventory_sort > 1 and button == Idstring("trigger_left") then
			Global.blackmarket_manager.tradable_inventory_sort = math.max(Global.blackmarket_manager.tradable_inventory_sort - 1, 1)

			extra_data.choice_text:set_text(extra_data.choices[Global.blackmarket_manager.tradable_inventory_sort or 1])

			self._reload_in_t = 0.8
			self._input_wait_t = 0.2

			managers.menu:active_menu().renderer:disable_input(0.2)
			managers.menu_component:post_event("menu_enter")

			return
		elseif Global.blackmarket_manager.tradable_inventory_sort < #tweak_data.gui.tradable_inventory_sort_list and button == Idstring("trigger_right") then
			Global.blackmarket_manager.tradable_inventory_sort = math.min(Global.blackmarket_manager.tradable_inventory_sort + 1, #tweak_data.gui.tradable_inventory_sort_list)

			extra_data.choice_text:set_text(extra_data.choices[Global.blackmarket_manager.tradable_inventory_sort or 1])

			self._reload_in_t = 0.8
			self._input_wait_t = 0.2

			managers.menu:active_menu().renderer:disable_input(0.2)
			managers.menu_component:post_event("menu_enter")

			return
		end
	end

	return self:press_pc_button(button)
end

function BlackMarketGui:input_focus()
	if self._one_frame_input_delay then
		self._one_frame_input_delay = nil

		return true
	end

	if not self._enabled then
		return
	end

	if managers.menu:is_pc_controller() and (managers.menu:active_menu().renderer:active_node_gui().name == "blackmarket_outfit_node" or managers.menu:active_menu().renderer:active_node_gui().name == "blackmarket_outfit_customize_node") then
		if managers.menu_scene and managers.menu_scene:input_focus() then
			return false
		end

		local disallow = true
		local panels = {
			self._tab_scroll_panel,
			self._tab_area_panel,
			self._weapon_info_panel,
			self._detection_panel,
			self._btn_panel,
			self._market_panel,
			self._steam_inventory_extra_panel,
			self._info_panel,
			self._grid_panel
		}

		if self._tabs[self._selected] then
			local scroll_bar = self._tabs[self._selected]._scroll_bar_panel:child("scroll_bar")

			table.insert(panels, scroll_bar)
		end

		local x, y = managers.mouse_pointer:modified_mouse_pos()

		for _, panel in ipairs(panels) do
			if alive(panel) and panel:inside(x, y) then
				disallow = false

				break
			end
		end

		if disallow then
			return
		end
	end

	return self._renaming_item and true or not self._no_input and self._enabled and (#self._data > -1 and 1 or true) or 2
end

function BlackMarketGui:visible()
	return self._visible
end

function BlackMarketGui:show_btns(slot)
	local data = slot._data
	local btn_show_funcs = data.btn_show_funcs or {}

	for _, btn in pairs(self._btns) do
		btn:hide()
	end

	local btns = {}
	local btn_show_func_name, btn_show_func = nil

	for i, btn in ipairs(data.buttons or data) do
		btn_show_func_name = btn_show_funcs[btn]
		btn_show_func = btn_show_func_name and callback(self, self, btn_show_func_name)

		if self._btns[btn] and (not btn_show_func or btn_show_func(data)) then
			self._btns[btn]:show()
			table.insert(btns, self._btns[btn])
		end
	end

	if not managers.menu:is_pc_controller() then
		local back_btn = self._btns.back_btn

		if back_btn then
			back_btn:show()
			table.insert(btns, back_btn)
		end
	end

	self._button_count = #btns

	table.sort(btns, function (x, y)
		return x._data.prio < y._data.prio
	end)

	self._controllers_mapping = {}
	self._controllers_pc_mapping = {}

	for i, btn in ipairs(btns) do
		if (not managers.menu:is_pc_controller() or managers.menu:is_steam_controller()) and not btn._data.no_btn then
			btn:set_text_btn_prefix(btn._data.btn)
		end

		if btn._data.pc_btn then
			self._controllers_pc_mapping[Idstring(btn._data.pc_btn):key()] = btn
		end

		self._controllers_mapping[btn._data.btn:key()] = btn

		btn:set_text_params(data.btn_text_params)
		btn:set_order(i)
	end

	local num_btns = #btns
	local h = self._real_small_font_size or small_font_size
	local info_box_panel = self._panel:child("info_box_panel")

	if self._info_panel then
		self._info_panel:set_size(info_box_panel:w() - 20, self._info_panel:num_children() / 2 * h)
		self._info_panel:set_rightbottom(self._panel:w() - 10, self._btn_panel:top() - 10)
	end

	if managers.menu:is_pc_controller() and #btns > 0 then
		slot:set_btn_text(btns[1]:btn_text())
	else
		slot:set_btn_text("")
	end

	self._visible_btns = btns

	self:_update_borders()
end

function BlackMarketGui:get_lock_icon(data, default)
	local category = data.category
	local global_value = data.global_value
	local name = data.name
	local unlocked = data.unlocked
	local level = data.level
	local skill_based = data.skill_based
	local func_based = data.func_based

	if _G.IS_VR and data.vr_locked then
		return "units/pd2_dlc_vr/player/lock_vr"
	end

	if unlocked and (type(unlocked) ~= "number" or unlocked > 0) then
		return nil
	end

	local gv_tweak = tweak_data.lootdrop.global_values[global_value]

	if gv_tweak and gv_tweak.dlc and not managers.dlc:is_dlc_unlocked(global_value) then
		return gv_tweak.unique_lock_icon or "guis/textures/pd2/lock_dlc"
	end

	if skill_based then
		return "guis/textures/pd2/lock_skill"
	end

	if func_based then
		local _, _, icon = BlackMarketGui.get_func_based(func_based)

		return icon or "guis/textures/pd2/lock_skill"
	end

	return default or "guis/textures/pd2/lock_level"
end

function BlackMarketGui.get_func_based(func_based)
	return managers.blackmarket[func_based](managers.blackmarket)
end

function BlackMarketGui:populate_weapon_category(category, data)
	managers.blackmarket:clear_temporary()
	managers.blackmarket:clear_preview_blueprint()

	local crafted_category = managers.blackmarket:get_crafted_category(category) or {}
	local last_weapon = table.size(crafted_category) == 1
	local last_unlocked_weapon = nil

	if not last_weapon then
		local category_size = table.size(crafted_category)

		for i, crafted in pairs(crafted_category) do
			if not managers.blackmarket:weapon_unlocked(crafted.weapon_id) then
				category_size = category_size - 1
			end
		end

		last_unlocked_weapon = category_size == 1
	end

	local hold_crafted_item = managers.blackmarket:get_hold_crafted_item()
	local currently_holding = hold_crafted_item and hold_crafted_item.category == category
	local max_items = data.override_slots and data.override_slots[1] * data.override_slots[2] or 9
	local max_rows = tweak_data.gui.MAX_WEAPON_ROWS or 3
	max_items = max_rows * (data.override_slots and data.override_slots[2] or 3)

	for i = 1, max_items, 1 do
		data[i] = nil
	end

	local guis_catalog = "guis/"
	local weapon_data = Global.blackmarket_manager.weapons
	local new_data = {}
	local index = 0

	for i, crafted in pairs(crafted_category) do
		guis_catalog = "guis/"
		local bundle_folder = tweak_data.weapon[crafted.weapon_id] and tweak_data.weapon[crafted.weapon_id].texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		new_data = {
			name = crafted.weapon_id,
			name_localized = managers.blackmarket:get_weapon_name_by_category_slot(category, i),
			raw_name_localized = managers.weapon_factory:get_weapon_name_by_factory_id(crafted.factory_id),
			custom_name_text = managers.blackmarket:get_crafted_custom_name(category, i, true),
			category = category,
			slot = i,
			unlocked = managers.blackmarket:weapon_unlocked(crafted.weapon_id),
			level = managers.blackmarket:weapon_level(crafted.weapon_id),
			can_afford = true,
			equipped = crafted.equipped,
			skill_based = weapon_data[crafted.weapon_id].skill_based
		}
		new_data.skill_name = new_data.skill_based and "bm_menu_skill_locked_" .. new_data.name
		new_data.func_based = weapon_data[crafted.weapon_id].func_based
		new_data.price = managers.money:get_weapon_slot_sell_value(category, i)
		local bitmap_texture, bg_texture = managers.blackmarket:get_weapon_icon_path(crafted.weapon_id, crafted.cosmetics)
		new_data.bitmap_texture = bitmap_texture
		new_data.bg_texture = bg_texture
		new_data.comparision_data = managers.blackmarket:get_weapon_stats(category, i)
		new_data.global_value = tweak_data.weapon[new_data.name] and tweak_data.weapon[new_data.name].global_value or "normal"
		new_data.dlc_locked = tweak_data.lootdrop.global_values[new_data.global_value].unlock_id or nil
		new_data.lock_texture = self:get_lock_icon(new_data)
		new_data.holding = currently_holding and hold_crafted_item.slot == i
		local icon_list = managers.menu_component:create_weapon_mod_icon_list(crafted.weapon_id, category, crafted.factory_id, i)
		local icon_index = 1
		local new_parts = {}

		for _, part in pairs(managers.blackmarket:get_weapon_new_part_drops(crafted.factory_id) or {}) do
			local type = tweak_data.weapon.factory.parts[part].type
			new_parts[type] = true
		end

		if table.size(new_parts) > 0 then
			new_data.new_drop_data = {}
		end

		new_data.mini_icons = {}

		for _, icon in pairs(icon_list) do
			table.insert(new_data.mini_icons, {
				layer = 1,
				h = 16,
				stream = false,
				w = 16,
				bottom = 0,
				texture = icon.texture,
				right = (icon_index - 1) * 18,
				alpha = icon.equipped and 1 or 0.25
			})

			if new_parts[icon.type] then
				table.insert(new_data.mini_icons, {
					texture = "guis/textures/pd2/blackmarket/inv_mod_new",
					layer = 1,
					h = 8,
					stream = false,
					w = 16,
					alpha = 1,
					bottom = 16,
					right = (icon_index - 1) * 18
				})
			end

			icon_index = icon_index + 1
		end

		if not new_data.unlocked then
			new_data.last_weapon = last_weapon
		else
			new_data.last_weapon = last_weapon or last_unlocked_weapon
		end

		if new_data.equipped then
			self._equipped_comparision_data = self._equipped_comparision_data or {}
			self._equipped_comparision_data[category] = new_data.comparision_data
		end

		if currently_holding then
			new_data.selected_text = managers.localization:to_upper_text("bm_menu_btn_swap_weapon")

			if new_data.slot ~= hold_crafted_item.slot then
				table.insert(new_data, "w_swap")
			end

			table.insert(new_data, "i_stop_move")
		else
			local has_mods = managers.weapon_factory:has_weapon_more_than_default_parts(crafted.factory_id)
			local can_mod = true

			if can_mod and has_mods and new_data.unlocked then
				table.insert(new_data, "w_mod")
			end

			if has_mods and new_data.unlocked and managers.workshop and managers.workshop:enabled() and not table.contains(managers.blackmarket:skin_editor():get_excluded_weapons(), new_data.name) then
				table.insert(new_data, "w_skin")
			end

			if not new_data.last_weapon then
				table.insert(new_data, "w_sell")
			end

			if not new_data.equipped and new_data.unlocked then
				table.insert(new_data, "w_equip")
			end

			if new_data.equipped and new_data.unlocked then
				table.insert(new_data, "w_move")
			end

			table.insert(new_data, "w_preview")
		end

		data[i] = new_data
		index = i
	end

	for i = 1, max_items, 1 do
		if not data[i] then
			local can_buy_weapon = managers.blackmarket:is_weapon_slot_unlocked(category, i)
			new_data = {}

			if can_buy_weapon then
				new_data.name = "bm_menu_btn_buy_new_weapon"
				new_data.name_localized = managers.localization:text("bm_menu_empty_weapon_slot")
				new_data.mid_text = {
					noselected_text = new_data.name_localized,
					noselected_color = tweak_data.screen_colors.button_stage_3
				}
				new_data.mid_text.selected_text = currently_holding and new_data.mid_text.noselected_text or managers.localization:text("bm_menu_btn_buy_new_weapon")
				new_data.mid_text.selected_color = currently_holding and new_data.mid_text.noselected_color or tweak_data.screen_colors.button_stage_2
				new_data.empty_slot = true
				new_data.category = category
				new_data.slot = i
				new_data.unlocked = true
				new_data.can_afford = true
				new_data.equipped = false

				if currently_holding then
					new_data.selected_text = managers.localization:to_upper_text("bm_menu_btn_place_weapon")

					table.insert(new_data, "w_place")
					table.insert(new_data, "i_stop_move")
				else
					table.insert(new_data, "ew_buy")
				end

				if managers.blackmarket:got_new_drop(new_data.category, "weapon_buy_empty", nil) then
					new_data.mini_icons = new_data.mini_icons or {}

					table.insert(new_data.mini_icons, {
						stream = false,
						name = "new_drop",
						h = 16,
						layer = 1,
						w = 16,
						texture = "guis/textures/pd2/blackmarket/inv_newdrop",
						visible = false,
						top = 0,
						right = 0
					})

					new_data.new_drop_data = {}
				end
			else
				new_data.name = "bm_menu_btn_buy_weapon_slot"
				new_data.name_localized = managers.localization:text("bm_menu_locked_weapon_slot")
				new_data.empty_slot = true
				new_data.category = category
				new_data.slot = i
				new_data.unlocked = true
				new_data.equipped = false
				new_data.lock_texture = "guis/textures/pd2/blackmarket/money_lock"
				new_data.lock_color = tweak_data.screen_colors.button_stage_3
				new_data.lock_shape = {
					w = 32,
					x = 0,
					h = 32,
					y = -32
				}
				new_data.locked_slot = true
				new_data.dlc_locked = managers.experience:cash_string(managers.money:get_buy_weapon_slot_price())
				new_data.mid_text = {
					noselected_text = new_data.name_localized,
					noselected_color = tweak_data.screen_colors.button_stage_3,
					is_lock_same_color = true
				}

				if currently_holding then
					new_data.mid_text.selected_text = new_data.mid_text.noselected_text
					new_data.mid_text.selected_color = new_data.mid_text.noselected_color

					table.insert(new_data, "i_stop_move")
				elseif managers.money:can_afford_buy_weapon_slot() then
					new_data.mid_text.selected_text = managers.localization:text("bm_menu_btn_buy_weapon_slot")
					new_data.mid_text.selected_color = tweak_data.screen_colors.button_stage_2

					table.insert(new_data, "ew_unlock")
				else
					new_data.mid_text.selected_text = managers.localization:text("bm_menu_cannot_buy_weapon_slot")
					new_data.mid_text.selected_color = tweak_data.screen_colors.important_1
					new_data.dlc_locked = new_data.dlc_locked .. "  " .. managers.localization:to_upper_text("bm_menu_cannot_buy_weapon_slot")
					new_data.mid_text.lock_noselected_color = tweak_data.screen_colors.important_1
					new_data.cannot_buy = true
				end
			end

			data[i] = new_data
		end
	end
end

function BlackMarketGui:populate_primaries(data)
	self:populate_weapon_category("primaries", data)
end

function BlackMarketGui:populate_secondaries(data)
	self:populate_weapon_category("secondaries", data)
end

function BlackMarketGui:populate_characters(data)
	local new_data = {}
	local max_items = math.ceil(CriminalsManager.get_num_characters() / (data.override_slots[1] or 3)) * (data.override_slots[1] or 3)

	for i = 1, max_items, 1 do
		data[i] = nil
	end

	local index = nil

	for i = 1, CriminalsManager.get_num_characters(), 1 do
		local character = CriminalsManager.character_names()[i]
		local character_name = CriminalsManager.convert_old_to_new_character_workname(character)
		local character_table = tweak_data.blackmarket.characters[character] or tweak_data.blackmarket.characters.locked[character_name]
		index = nil

		for _, preferred_character in ipairs(managers.blackmarket:get_preferred_characters_list()) do
			if preferred_character == character then
				index = _

				break
			end
		end

		new_data = {
			name = character
		}
		new_data.name_localized = managers.localization:text("menu_" .. new_data.name)
		new_data.category = "characters"
		new_data.slot = i
		new_data.unlocked = not character_table or not character_table.dlc or managers.dlc:is_dlc_unlocked(character_table.dlc)
		new_data.equipped = not not index
		new_data.equipped_text = index and tostring(index) or managers.localization:text("bm_menu_preferred")
		new_data.bitmap_texture = managers.blackmarket:get_character_icon(character_name)
		new_data.stream = false
		new_data.global_value = character_table.dlc
		new_data.lock_texture = self:get_lock_icon(new_data, "guis/textures/pd2/lock_community")

		if character_table and character_table.locks then
			local dlc = character_table.locks.dlc
			local achievement = character_table.locks.achievement
			local saved_job_value = character_table.locks.saved_job_value
			local level = character_table.locks.level

			if achievement and managers.achievment:get_info(achievement) and not managers.achievment:get_info(achievement).awarded then
				new_data.dlc_locked = "menu_bm_achievement_locked_" .. tostring(achievement)
			elseif dlc and not managers.dlc:is_dlc_unlocked(dlc) then
				new_data.dlc_locked = tweak_data.lootdrop.global_values[dlc] and tweak_data.lootdrop.global_values[dlc].unlock_id or "bm_menu_dlc_locked"
			end
		else
			new_data.dlc_locked = character_table and character_table.dlc and tweak_data.lootdrop.global_values[character_table.dlc] and tweak_data.lootdrop.global_values[character_table.dlc].unlock_id or "bm_menu_dlc_locked"
		end

		local active = true
		local btn_show_funcs = {}

		if new_data.unlocked then
			if active then
				if new_data.equipped then
					table.insert(new_data, "c_swap_slots")

					btn_show_funcs.c_swap_slots = "can_swap_character"
				else
					table.insert(new_data, "c_equip_to_slot")
				end
			end

			table.insert(new_data, "c_clear_slots")
		end

		new_data.btn_show_funcs = btn_show_funcs
		data[i] = new_data
	end

	for i = 1, max_items, 1 do
		if not data[i] then
			new_data = {
				name = "empty",
				name_localized = "",
				category = "characters",
				slot = i,
				unlocked = true,
				equipped = false
			}
			data[i] = new_data
		end
	end
end

function BlackMarketGui:populate_preferred_character_options(panel)
	local list = managers.blackmarket:get_preferred_characters_list()
	local data = {}
	local new_data = nil
	local desc_text = self._panel:text({
		blend_mode = "add",
		wrap = true,
		wrap_mode = true,
		vertical = "bottom",
		layer = 1,
		text = managers.localization:to_upper_text("menu_preferred_character_title"),
		font = small_font,
		font_size = small_font_size
	})

	desc_text:set_w(panel:w())
	desc_text:set_world_bottom(panel:world_top() - 10)
	desc_text:set_world_left(panel:world_left())

	local added_random = false

	for i = 1, CriminalsManager.MAX_NR_CRIMINALS, 1 do
		local character = list[i]
		local char_panel = panel:panel({
			w = 1 / CriminalsManager.MAX_NR_CRIMINALS * panel:w()
		})

		char_panel:set_right(i / CriminalsManager.MAX_NR_CRIMINALS * panel:w())

		new_data = {}

		if character then
			local character_name = CriminalsManager.convert_old_to_new_character_workname(character)
			local guis_catalog = "guis/"
			local character_table = tweak_data.blackmarket.characters[character] or tweak_data.blackmarket.characters.locked[character_name]
			local bundle_folder = character_table and character_table.texture_bundle_folder

			if bundle_folder then
				guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
			end

			local bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/characters/" .. character_name
			local image = char_panel:bitmap({
				name = "image",
				blend_mode = "add",
				texture = bitmap_texture
			})
			local text = char_panel:text({
				blend_mode = "add",
				y = 3,
				x = 5,
				layer = 1,
				text = tostring(i),
				font = small_font,
				font_size = small_font_size
			})
			local texture_width = image:texture_width()
			local texture_height = image:texture_height()
			local panel_width = char_panel:w()
			local panel_height = char_panel:h()
			local tw = texture_width
			local th = texture_height
			local pw = panel_width
			local ph = panel_height

			if tw == 0 or th == 0 then
				Application:error("[BlackMarketGui:populate_preferred_character_options] Texture size error!:", "width", tw, "height", th)

				tw = 1
				th = 1
			end

			local sw = math.min(pw, ph * tw / th)
			local sh = math.min(ph, pw / (tw / th))

			image:set_size(math.round(sw), math.round(sh))
			image:set_center(char_panel:w() * 0.5, char_panel:h() * 0.5)

			local box_gui = BoxGuiObject:new(char_panel, {
				sides = {
					2,
					2,
					2,
					2
				}
			})
			new_data.panel = char_panel
			new_data.box = box_gui
			new_data.image = image
			new_data.selected = i == (self._extra_options_data and self._extra_options_data.selected or 1)
			new_data.highlighted = false

			image:set_alpha((new_data.selected and 1 or 0.9) * (new_data.highlighted and 1 or 0.9))
			box_gui:set_visible(new_data.selected)
		else
			local bitmap_texture = "guis/dlcs/favorite/textures/pd2/blackmarket/icons/characters/random"
			local image = char_panel:bitmap({
				name = "image",
				blend_mode = "add",
				texture = bitmap_texture
			})
			local texture_width = image:texture_width()
			local texture_height = image:texture_height()
			local panel_width = char_panel:w()
			local panel_height = char_panel:h()
			local tw = texture_width
			local th = texture_height
			local pw = panel_width
			local ph = panel_height

			if tw == 0 or th == 0 then
				Application:error("[BlackMarketGui:populate_preferred_character_options] Texture size error!:", "width", tw, "height", th)

				tw = 1
				th = 1
			end

			local sw = math.min(pw, ph * tw / th)
			local sh = math.min(ph, pw / (tw / th))

			image:set_size(math.round(sw), math.round(sh))
			image:set_center(char_panel:w() * 0.5, char_panel:h() * 0.5)

			if not added_random then
				added_random = true
				local text = char_panel:text({
					blend_mode = "add",
					y = 3,
					x = 5,
					layer = 1,
					text = tostring(i),
					font = small_font,
					font_size = small_font_size
				})
				local box_gui = BoxGuiObject:new(char_panel, {
					sides = {
						2,
						2,
						2,
						2
					}
				})
				new_data.panel = char_panel
				new_data.box = box_gui
				new_data.image = image
				new_data.selected = i == (self._extra_options_data and self._extra_options_data.selected or 1)
				new_data.highlighted = false

				image:set_alpha((new_data.selected and 1 or 0.9) * (new_data.highlighted and 1 or 0.9))
				box_gui:set_visible(new_data.selected)
			else
				image:set_alpha(0.15)
			end
		end

		data[i] = new_data
	end

	if not managers.menu:is_pc_controller() then
		local arrow_left = self._panel:text({
			blend_mode = "add",
			layer = 1,
			text = managers.localization:get_default_macro("BTN_TOP_L"),
			font = small_font,
			font_size = small_font_size
		})
		local arrow_right = self._panel:text({
			blend_mode = "add",
			layer = 1,
			text = managers.localization:get_default_macro("BTN_TOP_R"),
			font = small_font,
			font_size = small_font_size
		})

		self:make_fine_text(arrow_left)
		self:make_fine_text(arrow_right)
		arrow_left:set_bottom(self._extra_options_panel:top())
		arrow_right:set_bottom(self._extra_options_panel:top())
		arrow_left:set_left(self._extra_options_panel:left())
		arrow_right:set_right(self._extra_options_panel:right())
		desc_text:set_bottom(arrow_left:top() - 5)
	end

	return data
end

function BlackMarketGui:populate_grenades(data)
	local new_data = {}
	local sort_data = managers.blackmarket:get_sorted_grenades()
	local max_items = self:calc_max_items(#sort_data, data.override_slots)

	for i = 1, max_items, 1 do
		data[i] = nil
	end

	local index = 0
	local guis_catalog, m_tweak_data, grenade_id = nil

	for i, grenades_data in ipairs(sort_data) do
		grenade_id = grenades_data[1]
		m_tweak_data = tweak_data.blackmarket.projectiles[grenades_data[1]] or {}
		guis_catalog = "guis/"
		local bundle_folder = m_tweak_data.texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		new_data = {
			name = grenade_id
		}
		new_data.name_localized = managers.localization:text(tweak_data.blackmarket.projectiles[new_data.name].name_id)
		new_data.category = "grenades"
		new_data.slot = i
		new_data.unlocked = grenades_data[2].unlocked
		new_data.equipped = grenades_data[2].equipped
		new_data.level = grenades_data[2].level
		new_data.stream = true
		new_data.global_value = tweak_data.lootdrop.global_values[m_tweak_data.dlc] and m_tweak_data.dlc or "normal"
		new_data.skill_based = grenades_data[2].skill_based
		new_data.skill_name = "bm_menu_skill_locked_" .. new_data.name
		new_data.equipped_text = not new_data.unlocked and new_data.equipped and " "

		if m_tweak_data and m_tweak_data.locks then
			local dlc = m_tweak_data.locks.dlc
			local achievement = m_tweak_data.locks.achievement
			local saved_job_value = m_tweak_data.locks.saved_job_value
			local level = m_tweak_data.locks.level
			new_data.dlc_based = true
			new_data.lock_texture = self:get_lock_icon(new_data, "guis/textures/pd2/lock_community")

			if achievement and managers.achievment:get_info(achievement) and not managers.achievment:get_info(achievement).awarded then
				new_data.dlc_locked = "menu_bm_achievement_locked_" .. tostring(achievement)
			elseif dlc and not managers.dlc:is_dlc_unlocked(dlc) then
				new_data.dlc_locked = tweak_data.lootdrop.global_values[dlc] and tweak_data.lootdrop.global_values[dlc].unlock_id or "bm_menu_dlc_locked"
			else
				new_data.dlc_locked = tweak_data.lootdrop.global_values[new_data.global_value].unlock_id or "bm_menu_dlc_locked"
			end
		else
			new_data.lock_texture = self:get_lock_icon(new_data)
			new_data.dlc_locked = tweak_data.lootdrop.global_values[new_data.global_value].unlock_id or "bm_menu_dlc_locked"
		end

		new_data.bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/grenades/" .. tostring(new_data.name)

		if managers.blackmarket:got_new_drop("normal", "grenades", grenade_id) then
			new_data.mini_icons = new_data.mini_icons or {}

			table.insert(new_data.mini_icons, {
				texture = "guis/textures/pd2/blackmarket/inv_newdrop",
				name = "new_drop",
				h = 16,
				w = 16,
				top = 0,
				layer = 1,
				stream = false,
				right = 0
			})

			new_data.new_drop_data = {
				"normal",
				"grenades",
				grenade_id
			}
		end

		local active = true

		if active then
			if new_data.unlocked and not new_data.equipped then
				table.insert(new_data, "lo_g_equip")
			end

			if new_data.unlocked and data.allow_preview and m_tweak_data.unit then
				table.insert(new_data, "lo_g_preview")
			end
		end

		data[i] = new_data
		index = i
	end

	for i = 1, max_items, 1 do
		if not data[i] then
			new_data = {
				name = "empty",
				name_localized = "",
				category = "grenades",
				slot = i,
				unlocked = true,
				equipped = false
			}
			data[i] = new_data
		end
	end
end

function BlackMarketGui:populate_melee_weapons(data)
	local new_data = {}
	local sort_data = {}
	local xd, yd, x_td, y_td, x_sn, y_sn, x_gv, y_gv = nil
	local m_tweak_data = tweak_data.blackmarket.melee_weapons
	local l_tweak_data = tweak_data.lootdrop.global_values
	local global_value = nil

	for id, d in pairs(Global.blackmarket_manager.melee_weapons) do
		global_value = tweak_data.blackmarket.melee_weapons[id].dlc or tweak_data.blackmarket.melee_weapons[id].global_value or "normal"

		if d.unlocked or d.equipped or tweak_data:get_raw_value("lootdrop", "global_values", global_value, "hide_unavailable") and not managers.dlc:is_dlc_unlocked(global_value) then
			table.insert(sort_data, {
				id,
				d
			})
		end
	end

	table.sort(sort_data, function (x, y)
		xd = x[2]
		yd = y[2]
		x_td = m_tweak_data[x[1]]
		y_td = m_tweak_data[y[1]]

		if xd.unlocked ~= yd.unlocked then
			return xd.unlocked
		end

		if x_td.instant ~= y_td.instant then
			return x_td.instant
		end

		if xd.skill_based ~= yd.skill_based then
			return xd.skill_based
		end

		if x_td.free ~= y_td.free then
			return x_td.free
		end

		x_gv = x_td.global_value or x_td.dlc or "normal"
		y_gv = y_td.global_value or y_td.dlc or "normal"
		x_sn = l_tweak_data[x_gv]
		y_sn = l_tweak_data[y_gv]
		x_sn = x_sn and x_sn.sort_number or 1
		y_sn = y_sn and y_sn.sort_number or 1

		if x_sn ~= y_sn then
			return x_sn < y_sn
		end

		if xd.level ~= yd.level then
			return xd.level < yd.level
		end

		return x[1] < y[1]
	end)

	local max_items = math.ceil(#sort_data / (data.override_slots[1] or 3)) * (data.override_slots[1] or 3)

	for i = 1, max_items, 1 do
		data[i] = nil
	end

	local index = 0
	local guis_catalog, m_tweak_data, melee_weapon_id = nil

	for i, melee_weapon_data in ipairs(sort_data) do
		melee_weapon_id = melee_weapon_data[1]
		m_tweak_data = tweak_data.blackmarket.melee_weapons[melee_weapon_data[1]] or {}
		guis_catalog = "guis/"
		local bundle_folder = m_tweak_data.texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		new_data = {
			name = melee_weapon_id
		}
		new_data.name_localized = managers.localization:text(tweak_data.blackmarket.melee_weapons[new_data.name].name_id)
		new_data.category = "melee_weapons"
		new_data.slot = i
		new_data.unlocked = melee_weapon_data[2].unlocked
		new_data.equipped = melee_weapon_data[2].equipped
		new_data.level = melee_weapon_data[2].level
		new_data.stream = true
		new_data.global_value = tweak_data.lootdrop.global_values[m_tweak_data.dlc] and m_tweak_data.dlc or "normal"
		new_data.skill_based = melee_weapon_data[2].skill_based
		new_data.skill_name = "bm_menu_skill_locked_" .. new_data.name
		new_data.func_based = melee_weapon_data[2].func_based

		if m_tweak_data and m_tweak_data.locks then
			local dlc = m_tweak_data.locks.dlc
			local achievement = m_tweak_data.locks.achievement
			local saved_job_value = m_tweak_data.locks.saved_job_value
			local level = m_tweak_data.locks.level
			local func = m_tweak_data.locks.func
			new_data.dlc_based = true
			new_data.lock_texture = self:get_lock_icon(new_data, "guis/textures/pd2/lock_community")

			if func and not BlackMarketGui.get_func_based(func) then
				local _, name, icon = BlackMarketGui.get_func_based(func)
				new_data.lock_texture = icon or new_data.lock_texture
				new_data.dlc_locked = name
			elseif achievement and managers.achievment:get_info(achievement) and not managers.achievment:get_info(achievement).awarded then
				new_data.dlc_locked = "menu_bm_achievement_locked_" .. tostring(achievement)
			elseif dlc and not managers.dlc:is_dlc_unlocked(dlc) then
				new_data.dlc_locked = tweak_data.lootdrop.global_values[dlc] and tweak_data.lootdrop.global_values[dlc].unlock_id or "bm_menu_dlc_locked"
			else
				new_data.dlc_locked = tweak_data.lootdrop.global_values[new_data.global_value].unlock_id or "bm_menu_dlc_locked"
			end
		else
			new_data.lock_texture = self:get_lock_icon(new_data)
			new_data.dlc_locked = tweak_data.lootdrop.global_values[new_data.global_value].unlock_id or "bm_menu_dlc_locked"
		end

		new_data.bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/melee_weapons/" .. tostring(new_data.name)

		if managers.blackmarket:got_new_drop("normal", "melee_weapons", melee_weapon_id) then
			new_data.mini_icons = new_data.mini_icons or {}

			table.insert(new_data.mini_icons, {
				texture = "guis/textures/pd2/blackmarket/inv_newdrop",
				name = "new_drop",
				h = 16,
				w = 16,
				top = 0,
				layer = 1,
				stream = false,
				right = 0
			})

			new_data.new_drop_data = {
				"normal",
				"melee_weapons",
				melee_weapon_id
			}
		end

		new_data.comparision_data = managers.blackmarket:get_melee_weapon_stats(melee_weapon_id)

		if new_data.unlocked and not new_data.equipped then
			table.insert(new_data, "lo_mw_equip")
		end

		if data.allow_preview and m_tweak_data.unit and not m_tweak_data.no_inventory_preview then
			table.insert(new_data, "lo_mw_preview")
		end

		data[i] = new_data
		index = i
	end

	for i = 1, max_items, 1 do
		if not data[i] then
			new_data = {
				name = "empty",
				name_localized = "",
				category = "melee_weapons",
				slot = i,
				unlocked = true,
				equipped = false
			}
			data[i] = new_data
		end
	end
end

function BlackMarketGui:populate_deployables(data)
	local new_data = {}
	local sort_data = managers.blackmarket:get_sorted_deployables()
	local max_items = math.ceil(#sort_data / (data.override_slots[1] or 3)) * (data.override_slots[1] or 3)

	for i = 1, max_items, 1 do
		data[i] = nil
	end

	local guis_catalog = "guis/"
	local index = 0
	local second_deployable = managers.player:has_category_upgrade("player", "second_deployable")

	for i, deployable_data in ipairs(sort_data) do
		guis_catalog = "guis/"
		local bundle_folder = tweak_data.blackmarket.deployables[deployable_data[1]] and tweak_data.blackmarket.deployables[deployable_data[1]].texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		new_data = {
			name = deployable_data[1]
		}
		new_data.name_localized = managers.localization:text(tweak_data.blackmarket.deployables[new_data.name].name_id)
		new_data.category = "deployables"
		new_data.bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/deployables/" .. tostring(new_data.name)
		new_data.slot = i
		new_data.unlocked = table.contains(managers.player:availible_equipment(1), new_data.name)
		new_data.level = 0
		new_data.equipped = managers.blackmarket:equipped_deployable() == new_data.name
		local slot = 0
		local count = 1

		if second_deployable then
			count = 2
		end

		for i = 1, count, 1 do
			if managers.player:equipment_in_slot(i) == new_data.name then
				slot = i

				break
			end
		end

		new_data.slot = slot
		new_data.equipped = slot ~= 0

		if new_data.equipped and second_deployable and new_data.unlocked then
			if slot == 1 then
				new_data.equipped_text = managers.localization:to_upper_text("bm_menu_primaries")
			end

			if slot == 2 then
				new_data.equipped_text = managers.localization:to_upper_text("bm_menu_secondaries")
			end
		end

		if not new_data.unlocked then
			new_data.equipped_text = ""
		end

		new_data.stream = false
		new_data.skill_based = new_data.level == 0
		new_data.skill_name = "bm_menu_skill_locked_" .. new_data.name
		new_data.lock_texture = self:get_lock_icon(new_data)

		if new_data.unlocked and not new_data.equipped and not second_deployable then
			table.insert(new_data, "lo_d_equip")
		end

		if new_data.unlocked and not new_data.equipped and second_deployable then
			table.insert(new_data, "lo_d_equip_primary")
		end

		if second_deployable and managers.blackmarket:equipped_deployable(1) and new_data.unlocked and not new_data.equipped then
			table.insert(new_data, "lo_d_equip_secondary")
		end

		if new_data.equipped then
			table.insert(new_data, "lo_d_unequip")
		end

		data[i] = new_data
		index = i
	end

	for i = 1, max_items, 1 do
		if not data[i] then
			new_data = {
				name = "empty",
				name_localized = "",
				category = "deployables",
				slot = i,
				unlocked = true,
				equipped = false
			}
			data[i] = new_data
		end
	end
end

function BlackMarketGui:populate_masks(data)
	local new_data = {}
	local crafted_category = managers.blackmarket:get_crafted_category("masks") or {}
	local mini_icon_helper = math.round((self._panel:h() - (tweak_data.menu.pd2_medium_font_size + 10) - 60) * GRID_H_MUL / ITEMS_PER_COLUMN) - 16
	local max_items = data.override_slots and data.override_slots[1] * data.override_slots[2] or 9
	local start_crafted_item = data.start_crafted_item or 1
	local hold_crafted_item = managers.blackmarket:get_hold_crafted_item()
	local currently_holding = hold_crafted_item and hold_crafted_item.category == "masks"
	local max_rows = tweak_data.gui.MAX_MASK_ROWS or 3
	max_items = max_rows * (data.override_slots and data.override_slots[2] or 3)

	for i = 1, max_items, 1 do
		data[i] = nil
	end

	local index = 0

	for i, crafted in pairs(crafted_category) do
		index = i - start_crafted_item + 1
		local guis_mask_id = crafted.mask_id

		if tweak_data.blackmarket.masks[guis_mask_id].guis_id then
			guis_mask_id = tweak_data.blackmarket.masks[guis_mask_id].guis_id
		end

		new_data = {
			name = crafted.mask_id,
			name_localized = managers.blackmarket:get_mask_name_by_category_slot("masks", i)
		}
		new_data.raw_name_localized = managers.localization:text(tweak_data.blackmarket.masks[new_data.name].name_id)
		new_data.custom_name_text = managers.blackmarket:get_crafted_custom_name("masks", i, true)
		new_data.custom_name_text_right = crafted.modded and -55 or -20
		new_data.custom_name_text_width = crafted.modded and 0.6
		new_data.category = "masks"
		new_data.global_value = crafted.global_value
		new_data.slot = i
		new_data.unlocked = true
		new_data.equipped = crafted.equipped
		new_data.bitmap_texture = managers.blackmarket:get_mask_icon(guis_mask_id)
		new_data.stream = true
		new_data.holding = currently_holding and hold_crafted_item.slot == i
		new_data.item_id = crafted.item_id
		local is_locked = tweak_data.lootdrop.global_values[new_data.global_value] and tweak_data.lootdrop.global_values[new_data.global_value].dlc and not managers.dlc:is_dlc_unlocked(new_data.global_value)
		local locked_parts = {}
		local mask_is_locked = is_locked
		local locked_global_value = nil

		if not is_locked then
			local name_converter = {
				pattern = "textures",
				color = "colors",
				material = "materials"
			}
			local default_blueprint = tweak_data.blackmarket.masks[crafted.mask_id] and tweak_data.blackmarket.masks[crafted.mask_id].default_blueprint or {}

			for type, part in pairs(crafted.blueprint) do
				if default_blueprint[type] ~= part.id and default_blueprint[name_converter[type]] ~= part.id and tweak_data.lootdrop.global_values[part.global_value] and tweak_data.lootdrop.global_values[part.global_value].dlc and not managers.dlc:is_dlc_unlocked(part.global_value) then
					locked_parts[type] = part.global_value
					is_locked = true
					locked_global_value = part.global_value or locked_global_value
				end
			end
		else
			locked_global_value = new_data.global_value
		end

		if is_locked then
			new_data.unlocked = false

			if mask_is_locked then
				new_data.lock_texture = self:get_lock_icon(new_data, "guis/textures/pd2/lock_incompatible")
				new_data.dlc_locked = tweak_data.lootdrop.global_values[new_data.global_value] and tweak_data.lootdrop.global_values[new_data.global_value].unlock_id or "bm_menu_dlc_locked"
			elseif table.size(locked_parts) > 0 then
				local t, gv = next(locked_parts)

				if gv then
					new_data.lock_texture = self:get_lock_icon(new_data, "guis/textures/pd2/lock_incompatible")
					new_data.dlc_locked = tweak_data.lootdrop.global_values[gv] and tweak_data.lootdrop.global_values[gv].unlock_id or "bm_menu_dlc_locked"
				end
			end
		end

		if currently_holding then
			if i ~= 1 then
				new_data.selected_text = managers.localization:to_upper_text("bm_menu_btn_swap_mask")
			end

			if i ~= 1 and new_data.slot ~= hold_crafted_item.slot then
				table.insert(new_data, "m_swap")
			end

			table.insert(new_data, "i_stop_move")
		else
			if new_data.unlocked then
				if not new_data.equipped then
					table.insert(new_data, "m_equip")
				end

				if i ~= 1 and new_data.equipped then
					table.insert(new_data, "m_move")
				end

				local can_mod_mask = true

				if can_mod_mask and not crafted.modded and managers.blackmarket:can_modify_mask(i) and i ~= 1 then
					table.insert(new_data, "m_mod")
				end

				table.insert(new_data, "m_preview")
			else
				if i ~= 1 and new_data.equipped then
					table.insert(new_data, "m_move")
				end

				table.insert(new_data, "m_preview")
			end

			if i ~= 1 then
				if managers.money:get_mask_sell_value(new_data.name, new_data.global_value) > 0 then
					table.insert(new_data, "m_sell")
				else
					table.insert(new_data, "m_remove")
				end
			end
		end

		if crafted.modded then
			new_data.mini_icons = {}
			local color_1 = tweak_data.blackmarket.colors[crafted.blueprint.color.id].colors[1]
			local color_2 = tweak_data.blackmarket.colors[crafted.blueprint.color.id].colors[2]

			table.insert(new_data.mini_icons, {
				texture = false,
				layer = 1,
				h = 16,
				w = 16,
				bottom = 0,
				right = 0,
				color = color_2
			})
			table.insert(new_data.mini_icons, {
				texture = false,
				layer = 1,
				h = 16,
				w = 16,
				bottom = 0,
				right = 18,
				color = color_1
			})

			if locked_parts.color then
				local texture = self:get_lock_icon({
					global_value = locked_parts.color
				})

				table.insert(new_data.mini_icons, {
					layer = 2,
					h = 32,
					w = 32,
					bottom = -5,
					right = 2,
					texture = texture,
					color = tweak_data.screen_colors.important_1
				})
			end

			local pattern = crafted.blueprint.pattern.id

			if pattern ~= "solidfirst" then
				if pattern ~= "solidsecond" then
					local material_id = crafted.blueprint.material.id
					guis_catalog = "guis/"
					local bundle_folder = tweak_data.blackmarket.materials[material_id] and tweak_data.blackmarket.materials[material_id].texture_bundle_folder

					if bundle_folder then
						guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
					end

					local right = -3
					local bottom = 38 - (NOT_WIN_32 and 10 or 10)
					local w = 42
					local h = 42

					table.insert(new_data.mini_icons, {
						layer = 1,
						stream = true,
						texture = guis_catalog .. "textures/pd2/blackmarket/icons/materials/" .. material_id,
						right = right,
						bottom = bottom,
						w = w,
						h = h
					})

					if locked_parts.material then
						local texture = self:get_lock_icon({
							global_value = locked_parts.material
						})

						table.insert(new_data.mini_icons, {
							layer = 2,
							h = 32,
							w = 32,
							texture = texture,
							right = right + (w - 32) / 2,
							bottom = bottom + (h - 32) / 2,
							color = tweak_data.screen_colors.important_1
						})
					end
				end
			end

			local right = -3
			local bottom = math.round(mini_icon_helper - 6 - 6 - 42)
			local w = 42
			local h = 42

			table.insert(new_data.mini_icons, {
				layer = 1,
				stream = true,
				texture = tweak_data.blackmarket.textures[pattern].texture,
				right = right,
				bottom = bottom,
				w = h,
				h = w,
				render_template = Idstring("VertexColorTexturedPatterns")
			})

			if locked_parts.pattern then
				local texture = self:get_lock_icon({
					global_value = locked_parts.pattern
				})

				table.insert(new_data.mini_icons, {
					layer = 2,
					h = 32,
					w = 32,
					texture = texture,
					right = right + (w - 32) / 2,
					bottom = bottom + (h - 32) / 2,
					color = tweak_data.screen_colors.important_1
				})
			end

			new_data.mini_icons.borders = true
		elseif i ~= 1 and managers.blackmarket:can_modify_mask(i) and managers.blackmarket:got_new_drop("normal", "mask_mods", crafted.mask_id) then
			new_data.mini_icons = new_data.mini_icons or {}

			table.insert(new_data.mini_icons, {
				stream = false,
				name = "new_drop",
				h = 16,
				layer = 1,
				w = 16,
				texture = "guis/textures/pd2/blackmarket/inv_newdrop",
				visible = true,
				top = 0,
				right = 0
			})

			new_data.new_drop_data = {}
		end

		data[index] = new_data
	end

	local can_buy_masks = true

	for i = 1, max_items, 1 do
		if not data[i] then
			index = i + start_crafted_item - 1
			can_buy_masks = managers.blackmarket:is_mask_slot_unlocked(i)
			new_data = {}

			if can_buy_masks then
				new_data.name = "bm_menu_btn_buy_new_mask"
				new_data.name_localized = managers.localization:text("bm_menu_empty_mask_slot")
				new_data.mid_text = {
					noselected_text = new_data.name_localized,
					noselected_color = tweak_data.screen_colors.button_stage_3
				}
				new_data.mid_text.selected_text = currently_holding and new_data.mid_text.noselected_text or managers.localization:text("bm_menu_btn_buy_new_mask")
				new_data.mid_text.selected_color = currently_holding and new_data.mid_text.noselected_color or tweak_data.screen_colors.button_stage_2
				new_data.empty_slot = true
				new_data.category = "masks"
				new_data.slot = index
				new_data.unlocked = true
				new_data.equipped = false
				new_data.num_backs = 0
				new_data.cannot_buy = not can_buy_masks

				if currently_holding then
					if i ~= 1 then
						new_data.selected_text = managers.localization:to_upper_text("bm_menu_btn_place_mask")
					end

					if i ~= 1 then
						table.insert(new_data, "m_place")
					end

					table.insert(new_data, "i_stop_move")
				else
					table.insert(new_data, "em_buy")
				end

				if index ~= 1 and managers.blackmarket:got_new_drop(nil, "mask_buy", nil) then
					new_data.mini_icons = new_data.mini_icons or {}

					table.insert(new_data.mini_icons, {
						stream = false,
						name = "new_drop",
						h = 16,
						layer = 1,
						w = 16,
						texture = "guis/textures/pd2/blackmarket/inv_newdrop",
						visible = false,
						top = 0,
						right = 0
					})

					new_data.new_drop_data = {}
				end
			else
				new_data.name = "bm_menu_btn_buy_mask_slot"
				new_data.name_localized = managers.localization:text("bm_menu_locked_mask_slot")
				new_data.empty_slot = true
				new_data.category = "masks"
				new_data.slot = index
				new_data.unlocked = true
				new_data.equipped = false
				new_data.num_backs = 0
				new_data.lock_texture = "guis/textures/pd2/blackmarket/money_lock"
				new_data.lock_color = tweak_data.screen_colors.button_stage_3
				new_data.lock_shape = {
					w = 32,
					x = 0,
					h = 32,
					y = -32
				}
				new_data.locked_slot = true
				new_data.dlc_locked = managers.experience:cash_string(managers.money:get_buy_mask_slot_price())
				new_data.mid_text = {
					noselected_text = new_data.name_localized,
					noselected_color = tweak_data.screen_colors.button_stage_3,
					is_lock_same_color = true
				}

				if currently_holding then
					new_data.mid_text.selected_text = new_data.mid_text.noselected_text
					new_data.mid_text.selected_color = new_data.mid_text.noselected_color

					table.insert(new_data, "i_stop_move")
				elseif managers.money:can_afford_buy_mask_slot() then
					new_data.mid_text.selected_text = managers.localization:text("bm_menu_btn_buy_mask_slot")
					new_data.mid_text.selected_color = tweak_data.screen_colors.button_stage_2

					table.insert(new_data, "em_unlock")
				else
					new_data.mid_text.selected_text = managers.localization:text("bm_menu_cannot_buy_mask_slot")
					new_data.mid_text.selected_color = tweak_data.screen_colors.important_1
					new_data.dlc_locked = new_data.dlc_locked .. "  " .. managers.localization:to_upper_text("bm_menu_cannot_buy_mask_slot")
					new_data.mid_text.lock_noselected_color = tweak_data.screen_colors.important_1
					new_data.cannot_buy = true
				end
			end

			data[i] = new_data
		end
	end
end

function BlackMarketGui:populate_armors(data)
	local new_data = {}
	local sort_data, armor_level_data = managers.blackmarket:get_sorted_armors()
	local guis_catalog = "guis/"
	local index = 0

	for i, armor_id in ipairs(sort_data) do
		local name_id = tweak_data.blackmarket.armors[armor_id] and tweak_data.blackmarket.armors[armor_id].name_id or ""
		local bm_data = Global.blackmarket_manager.armors[armor_id]
		guis_catalog = "guis/"
		local bundle_folder = tweak_data.blackmarket.armors[armor_id] and tweak_data.blackmarket.armors[armor_id].texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		index = index + 1
		new_data = {
			name = armor_id,
			name_localized = managers.localization:text(name_id),
			category = "armors",
			slot = index,
			unlocked = bm_data.unlocked,
			level = armor_level_data[armor_id] or 0
		}
		new_data.skill_based = new_data.level == 0
		new_data.equipped = bm_data.equipped
		new_data.skill_name = new_data.level == 0 and "bm_menu_skill_locked_" .. new_data.name
		new_data.bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/armors/" .. new_data.name
		new_data.comparision_data = {}
		new_data.lock_texture = self:get_lock_icon(new_data)

		if i ~= 1 and managers.blackmarket:got_new_drop("normal", "armors", armor_id) then
			new_data.mini_icons = new_data.mini_icons or {}

			table.insert(new_data.mini_icons, {
				texture = "guis/textures/pd2/blackmarket/inv_newdrop",
				name = "new_drop",
				h = 16,
				w = 16,
				top = 0,
				layer = 1,
				stream = false,
				right = 0
			})

			new_data.new_drop_data = {
				"normal",
				"armors",
				armor_id
			}
		end

		if new_data.unlocked and not new_data.equipped then
			table.insert(new_data, "a_equip")
		end

		if i ~= 1 and (game_state_machine and game_state_machine:current_state_name()) ~= "ingame_waiting_for_players" then
			table.insert(new_data, "a_mod")
		end

		data[index] = new_data
	end

	local max_armors = data.override_slots[1] * data.override_slots[2]

	for i = 1, max_armors, 1 do
		if not data[i] then
			new_data = {
				name = "empty",
				name_localized = "",
				category = "armors",
				slot = i,
				unlocked = true,
				equipped = false
			}
			data[i] = new_data
		end
	end
end

function BlackMarketGui:populate_armor_skins(data)
	local new_data = {}
	local sort_data = {}
	local inventory_tradable = managers.blackmarket:get_inventory_tradable()

	for skin_id, skin_data in pairs(tweak_data.economy.armor_skins) do
		if skin_data.sorted == nil or skin_data.sorted then
			table.insert(sort_data, skin_id)
		end
	end

	table.sort(sort_data, function (a, b)
		local ad = tweak_data.economy.armor_skins[a]
		local bd = tweak_data.economy.armor_skins[b]
		local ar = tweak_data.economy.rarities[ad and ad.rarity or "common"].index
		local br = tweak_data.economy.rarities[bd and bd.rarity or "common"].index

		if ar ~= br then
			return br < ar
		elseif ad.sorting_idx or bd.sorting_idx then
			local as = ad.sorting_idx or -1
			local bs = bd.sorting_idx or -1

			if as ~= bs then
				return bs < as
			end
		end

		return managers.localization:text(ad and ad.name_id or "error") < managers.localization:text(bd and bd.name_id or "error")
	end)
	table.insert(sort_data, 1, "none")

	local guis_catalog = "guis/"
	local index = 0

	for i, skin_id in ipairs(sort_data) do
		local td = tweak_data.economy.armor_skins[skin_id]
		local name_id = td.name_id or ""
		local unlocked = managers.blackmarket:armor_skin_unlocked(skin_id)

		if not unlocked then
			for _, data in pairs(inventory_tradable) do
				if data.entry == skin_id then
					unlocked = true

					break
				end
			end
		end

		guis_catalog = "guis/"
		local bundle_folder = td.texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		index = index + 1
		new_data = {
			name = skin_id,
			name_localized = managers.localization:text(name_id),
			global_value = td.global_value or nil,
			category = "armor_skins",
			slot = index,
			unlocked = true,
			level = 0
		}
		local is_locked = tweak_data.lootdrop.global_values[new_data.global_value] and tweak_data.lootdrop.global_values[new_data.global_value].dlc and not managers.dlc:is_dlc_unlocked(new_data.global_value)

		if is_locked then
			new_data.unlocked = false
			new_data.lock_texture = self:get_lock_icon(new_data, "guis/textures/pd2/lock_incompatible")
			new_data.dlc_locked = tweak_data.lootdrop.global_values[new_data.global_value] and tweak_data.lootdrop.global_values[new_data.global_value].unlock_id or "bm_menu_dlc_locked"
		end

		new_data.equipped = skin_id == managers.blackmarket:equipped_armor_skin()

		if i ~= 1 then
			new_data.bitmap_texture = guis_catalog .. "armor_skins/" .. skin_id
			new_data.bg_texture = managers.blackmarket:get_cosmetic_rarity_bg(td.rarity or "common")
		else
			new_data.button_text = managers.localization:to_upper_text("menu_casino_option_prefer_none")
		end

		new_data.comparision_data = {}
		new_data.cosmetic_unlocked = new_data.unlocked and unlocked or false
		new_data.cosmetic_rarity = td.rarity

		if not new_data.cosmetic_unlocked then
			new_data.lock_texture = new_data.lock_texture or true
			new_data.bitmap_locked_blend_mode = "normal"
			new_data.bitmap_locked_alpha = 0.4
			new_data.bg_alpha = 0.4
		end

		if new_data.cosmetic_unlocked and not new_data.equipped then
			table.insert(new_data, "as_equip")
		end

		table.insert(new_data, "as_preview")
		table.insert(new_data, "as_workshop")

		data[index] = new_data
	end

	local max_armors = self:calc_max_items(#sort_data, data.override_slots)

	for i = 1, max_armors, 1 do
		if not data[i] then
			new_data = {
				name = "empty",
				name_localized = "",
				category = "armors",
				slot = #data,
				unlocked = true,
				equipped = false
			}

			table.insert(data, new_data)
		end
	end
end

function BlackMarketGui:populate_player_styles(data)
	for i = 1, #data, 1 do
		data[i] = nil
	end

	local sort_data = {}

	for i, player_style in ipairs(tweak_data.blackmarket.player_style_list) do
		if Global.blackmarket_manager.player_styles[player_style] then
			table.insert(sort_data, player_style)
		end
	end

	local have_suit_variations = nil
	local mannequin_player_style = data.mannequin_player_style or managers.menu_scene and managers.menu_scene:get_player_style() or "none"
	local default_player_style = managers.blackmarket:get_default_player_style()
	local new_data, allow_preview, allow_customize, player_style, player_style_data, guis_catalog, bundle_folder, customize_alpha = nil
	local equipped_player_style = data.equipped_player_style or managers.blackmarket:equipped_player_style()
	local max_items = self:calc_max_items(#sort_data, data.override_slots)

	for i = 1, max_items, 1 do
		new_data = {
			comparision_data = nil,
			category = "player_styles",
			slot = i
		}
		player_style = sort_data[i]

		if player_style then
			allow_preview = true
			player_style_data = tweak_data.blackmarket.player_styles[player_style]
			guis_catalog = "guis/"
			bundle_folder = player_style_data.texture_bundle_folder

			if bundle_folder then
				guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
			end

			new_data.name = player_style
			new_data.name_localized = managers.localization:text(player_style_data.name_id)
			new_data.global_value = player_style_data.global_value or "normal"
			new_data.unlocked = managers.blackmarket:player_style_unlocked(player_style)
			new_data.equipped = equipped_player_style == player_style
			allow_customize = not data.customize_equipped_only or new_data.equipped

			if player_style ~= default_player_style then
				new_data.bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/player_styles/" .. player_style
			else
				new_data.button_text = managers.localization:to_upper_text("menu_default")
			end

			local is_dlc_locked = tweak_data.lootdrop.global_values[new_data.global_value] and tweak_data.lootdrop.global_values[new_data.global_value].dlc and not managers.dlc:is_dlc_unlocked(new_data.global_value)

			if is_dlc_locked then
				new_data.unlocked = false
				new_data.lock_texture = self:get_lock_icon(new_data, "guis/textures/pd2/lock_dlc")
				new_data.dlc_locked = tweak_data.lootdrop.global_values[new_data.global_value] and tweak_data.lootdrop.global_values[new_data.global_value].unlock_id or "bm_menu_dlc_locked"
			elseif not new_data.unlocked then
				local achievement = player_style_data.locks and player_style_data.locks.achievement

				if achievement and managers.achievment:get_info(achievement) and not managers.achievment:get_info(achievement).awarded then
					local achievement_visual = tweak_data.achievement.visual[achievement]
					new_data.lock_texture = "guis/textures/pd2/lock_achievement"
					new_data.dlc_locked = achievement_visual and achievement_visual.desc_id or "achievement_" .. tostring(achievement) .. "_desc"
				else
					new_data.lock_texture = "guis/textures/pd2/skilltree/padlock"
				end
			end

			have_suit_variations = tweak_data.blackmarket:have_suit_variations(player_style)

			if have_suit_variations then
				if allow_customize then
					table.insert(new_data, "trd_customize")
				end

				if allow_customize then
					customize_alpha = 0.8
				else
					customize_alpha = 0.4
				end

				new_data.mini_icons = {}

				table.insert(new_data.mini_icons, {
					texture = "guis/dlcs/trd/textures/pd2/blackmarket/paintbrush_icon",
					top = 5,
					h = 16,
					layer = 1,
					w = 16,
					blend_mode = "add",
					right = 5,
					alpha = customize_alpha
				})
			end

			if new_data.unlocked and not new_data.equipped then
				table.insert(new_data, "trd_equip")
			end

			if allow_preview and mannequin_player_style ~= player_style then
				table.insert(new_data, "trd_preview")
			end
		else
			new_data.name = "empty"
			new_data.name_localized = ""
			new_data.unlocked = true
			new_data.equipped = false
		end

		table.insert(data, new_data)
	end
end

function BlackMarketGui:populate_suit_variations(data)
	for i = 1, #data, 1 do
		data[i] = nil
	end

	local player_style = data.prev_node_data.name
	local player_style_data = tweak_data.blackmarket.player_styles[player_style]
	local material_variations = player_style_data and player_style_data.material_variations or {}
	local mannequin_suit_variation = managers.menu_scene and managers.menu_scene:get_suit_variation() or "default"
	local equipped_suit_variation = data.suit_variation or managers.blackmarket:get_suit_variation(player_style)
	local new_data, allow_preview, guis_catalog, bundle_folder, texture_path, suit_variation, suit_variation_data = nil
	local sort_data = managers.blackmarket:get_all_suit_variations(player_style)
	local max_items = self:calc_max_items(#sort_data, data.override_slots)

	for i = 1, max_items, 1 do
		new_data = {
			comparision_data = nil,
			category = "suit_variation",
			slot = i
		}
		suit_variation = sort_data[i]

		if suit_variation then
			allow_preview = true
			suit_variation_data = material_variations[suit_variation]
			guis_catalog = "guis/"
			bundle_folder = suit_variation_data and suit_variation_data.texture_bundle_folder or player_style_data.texture_bundle_folder

			if bundle_folder then
				guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
			end

			new_data.name = suit_variation
			new_data.name_localized = suit_variation_data and managers.localization:text(suit_variation_data.name_id) or managers.localization:text("menu_default")
			new_data.global_value = suit_variation_data and suit_variation_data.global_value or "normal"
			new_data.unlocked = managers.blackmarket:suit_variation_unlocked(player_style, suit_variation)
			new_data.equipped = equipped_suit_variation == suit_variation
			texture_path = guis_catalog .. "textures/pd2/blackmarket/icons/player_styles/" .. player_style

			if suit_variation_data then
				texture_path = texture_path .. "_" .. suit_variation or texture_path
			end

			new_data.bitmap_texture = texture_path
			local is_dlc_locked = tweak_data.lootdrop.global_values[new_data.global_value] and tweak_data.lootdrop.global_values[new_data.global_value].dlc and not managers.dlc:is_dlc_unlocked(new_data.global_value)

			if is_dlc_locked then
				new_data.unlocked = false
				new_data.lock_texture = self:get_lock_icon(new_data, "guis/textures/pd2/lock_dlc")
				new_data.dlc_locked = tweak_data.lootdrop.global_values[new_data.global_value] and tweak_data.lootdrop.global_values[new_data.global_value].unlock_id or "bm_menu_dlc_locked"
			elseif not new_data.unlocked then
				local achievement = suit_variation_data and suit_variation_data.locks and suit_variation_data.locks.achievement

				if suit_variation == "default" then
					achievement = achievement or player_style_data and player_style_data.locks and player_style_data.locks.achievement
				end

				if achievement and managers.achievment:get_info(achievement) and not managers.achievment:get_info(achievement).awarded then
					local achievement_visual = tweak_data.achievement.visual[achievement]
					new_data.lock_texture = "guis/textures/pd2/lock_achievement"
					new_data.dlc_locked = achievement_visual and achievement_visual.desc_id or "achievement_" .. tostring(achievement) .. "_desc"
				else
					new_data.lock_texture = "guis/textures/pd2/skilltree/padlock"
				end
			end

			if new_data.unlocked then
				if not new_data.equipped then
					table.insert(new_data, "trd_mod_equip")
				end
			else
				new_data.bitmap_locked_blend_mode = "normal"
				new_data.bitmap_locked_alpha = 0.4
			end

			if allow_preview and mannequin_suit_variation ~= suit_variation then
				table.insert(new_data, "trd_mod_preview")
			end
		else
			new_data.name = "empty"
			new_data.name_localized = ""
			new_data.unlocked = true
			new_data.equipped = false
		end

		table.insert(data, new_data)
	end
end

function BlackMarketGui:equip_player_style_callback(data)
	managers.blackmarket:set_equipped_player_style(data.name)
	managers.blackmarket:release_preloaded_category("player_style")
	self:reload()
end

function BlackMarketGui:equip_suit_variation_callback(data)
	local player_style = self._data.prev_node_data.name
	local material_variation = data.name

	managers.blackmarket:set_suit_variation(player_style, material_variation)
	self:reload()
end

function BlackMarketGui:customize_player_style_callback(data)
	local function open_node_clbk()
		local new_node_data = {}

		table.insert(new_node_data, {
			name = "bm_menu_suit_variations",
			on_create_func_name = "populate_suit_variations",
			category = "suit_variations",
			override_slots = {
				3,
				3
			},
			identifier = BlackMarketGui.identifiers.suit_variation,
			prev_node_data = data
		})

		new_node_data.topic_id = "bm_menu_suit_variations"
		new_node_data.panel_grid_w_mul = 0.6
		new_node_data.skip_blur = true
		new_node_data.use_bgs = true
		new_node_data.hide_detection_panel = true
		new_node_data.prev_node_data = data

		managers.menu:open_node("blackmarket_outfit_customize_node", {
			new_node_data
		})
	end

	local player_style = data.name
	local material_variation = managers.blackmarket:get_suit_variation(player_style)

	self:_preview_player_style(player_style, material_variation, open_node_clbk)
end

function BlackMarketGui:_preview_player_style(player_style, material_variation, done_clbk)
	managers.blackmarket:view_player_style(player_style, material_variation, done_clbk)
end

function BlackMarketGui:preview_player_style_callback(data)
	local player_style = data.name
	local material_variation = managers.blackmarket:get_suit_variation(player_style)

	self:_preview_player_style(player_style, material_variation, callback(self, self, "reload"))
end

function BlackMarketGui:preview_suit_variation_callback(data)
	local player_style = self._data.prev_node_data.name
	local material_variation = data.name

	self:_preview_player_style(player_style, material_variation, callback(self, self, "reload"))
end

function BlackMarketGui:populate_masks_new(data)
	local new_data = {}
	local crafted_category = managers.blackmarket:get_crafted_category("masks") or {}
	local mini_icon_helper = math.round((self._panel:h() - (tweak_data.menu.pd2_small_font_size + 10) - 60) * GRID_H_MUL / ITEMS_PER_COLUMN) - 16
	local hold_crafted_item = managers.blackmarket:get_hold_crafted_item()
	local currently_holding = hold_crafted_item and hold_crafted_item.category == "masks"
	local max_items = data.override_slots and data.override_slots[1] * data.override_slots[2] or 9
	local max_rows = tweak_data.gui.MASK_ROWS_PER_PAGE or 3
	max_items = max_rows * (data.override_slots and data.override_slots[1] or 3)

	for i = 1, max_items, 1 do
		data[i] = nil
	end

	local guis_catalog = "guis/"
	local crafted = nil

	for i, index in pairs(data.on_create_data) do
		crafted = crafted_category[index]

		if crafted then
			local guis_mask_id = crafted.mask_id

			if tweak_data.blackmarket.masks[guis_mask_id].guis_id then
				guis_mask_id = tweak_data.blackmarket.masks[guis_mask_id].guis_id
			end

			new_data = {
				name = crafted.mask_id,
				name_localized = managers.blackmarket:get_mask_name_by_category_slot("masks", index)
			}
			new_data.raw_name_localized = managers.localization:text(tweak_data.blackmarket.masks[new_data.name].name_id)
			new_data.custom_name_text = managers.blackmarket:get_crafted_custom_name("masks", index, true)
			new_data.custom_name_text_right = crafted.modded and -55 or -20
			new_data.custom_name_text_width = crafted.modded and 0.6
			new_data.category = "masks"
			new_data.global_value = crafted.global_value
			new_data.slot = index
			new_data.unlocked = true
			new_data.equipped = crafted.equipped
			new_data.bitmap_texture = managers.blackmarket:get_mask_icon(guis_mask_id, self._data.character_id)
			new_data.stream = false
			new_data.holding = currently_holding and hold_crafted_item.slot == index
			new_data.item_id = crafted.item_id
			local is_locked = tweak_data.lootdrop.global_values[new_data.global_value] and tweak_data.lootdrop.global_values[new_data.global_value].dlc and not managers.dlc:is_dlc_unlocked(new_data.global_value)
			local locked_parts = {}
			local mask_is_locked = is_locked
			local locked_global_value = nil

			if not is_locked then
				local name_converter = {
					pattern = "textures",
					color = "colors",
					material = "materials"
				}
				local default_blueprint = tweak_data.blackmarket.masks[crafted.mask_id] and tweak_data.blackmarket.masks[crafted.mask_id].default_blueprint or {}

				for type, part in pairs(crafted.blueprint) do
					if default_blueprint[type] ~= part.id and default_blueprint[name_converter[type]] ~= part.id and tweak_data.lootdrop.global_values[part.global_value] and tweak_data.lootdrop.global_values[part.global_value].dlc and not managers.dlc:is_dlc_unlocked(part.global_value) then
						locked_parts[type] = part.global_value
						is_locked = true
						locked_global_value = part.global_value or locked_global_value
					end
				end
			else
				locked_global_value = new_data.global_value
			end

			if is_locked then
				new_data.unlocked = false

				if mask_is_locked then
					new_data.lock_texture = self:get_lock_icon(new_data, "guis/textures/pd2/lock_incompatible")
					new_data.dlc_locked = tweak_data.lootdrop.global_values[new_data.global_value] and tweak_data.lootdrop.global_values[new_data.global_value].unlock_id or "bm_menu_dlc_locked"
				elseif table.size(locked_parts) > 0 then
					local t, gv = next(locked_parts)

					if gv then
						new_data.lock_texture = self:get_lock_icon(new_data, "guis/textures/pd2/lock_incompatible")
						new_data.dlc_locked = tweak_data.lootdrop.global_values[gv] and tweak_data.lootdrop.global_values[gv].unlock_id or "bm_menu_dlc_locked"
					end
				end
			end

			new_data.active = true

			if currently_holding then
				if index ~= 1 then
					new_data.selected_text = managers.localization:to_upper_text("bm_menu_btn_swap_mask")
				end

				if index ~= 1 and new_data.slot ~= hold_crafted_item.slot then
					table.insert(new_data, "m_swap")
				end

				table.insert(new_data, "i_stop_move")
			else
				if new_data.unlocked and new_data.active then
					if not new_data.equipped then
						table.insert(new_data, "m_equip")
					end

					if index ~= 1 and new_data.equipped then
						table.insert(new_data, "m_move")
					end

					local can_mod_mask = true

					if can_mod_mask and not crafted.modded and managers.blackmarket:can_modify_mask(index) and index ~= 1 then
						table.insert(new_data, "m_mod")
					end

					table.insert(new_data, "m_preview")
				else
					if index ~= 1 and new_data.equipped then
						table.insert(new_data, "m_move")
					end

					if new_data.active then
						table.insert(new_data, "m_preview")
					end
				end

				if index ~= 1 then
					if managers.money:get_mask_sell_value(new_data.name, new_data.global_value) > 0 then
						table.insert(new_data, "m_sell")
					else
						table.insert(new_data, "m_remove")
					end

					if is_win32 and not managers.menu:is_pc_controller() then
						-- Nothing
					end
				end
			end

			if crafted.modded then
				new_data.mini_icons = {}
				local color_1 = tweak_data.blackmarket.colors[crafted.blueprint.color.id].colors[1]
				local color_2 = tweak_data.blackmarket.colors[crafted.blueprint.color.id].colors[2]

				table.insert(new_data.mini_icons, {
					texture = false,
					layer = 1,
					h = 16,
					w = 16,
					bottom = 0,
					right = 0,
					color = color_2
				})
				table.insert(new_data.mini_icons, {
					texture = false,
					layer = 1,
					h = 16,
					w = 16,
					bottom = 0,
					right = 18,
					color = color_1
				})

				if locked_parts.color then
					local texture = self:get_lock_icon({
						global_value = locked_parts.color
					})

					table.insert(new_data.mini_icons, {
						layer = 2,
						h = 32,
						w = 32,
						bottom = -5,
						right = 2,
						texture = texture,
						color = tweak_data.screen_colors.important_1
					})
				end

				local pattern = crafted.blueprint.pattern.id

				if pattern ~= "solidfirst" then
					if pattern ~= "solidsecond" then
						local material_id = crafted.blueprint.material.id
						guis_catalog = "guis/"
						local bundle_folder = tweak_data.blackmarket.materials[material_id] and tweak_data.blackmarket.materials[material_id].texture_bundle_folder

						if bundle_folder then
							guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
						end

						local right = 2
						local bottom = 38 - (NOT_WIN_32 and 10 or 10)
						local w = 32
						local h = 32

						table.insert(new_data.mini_icons, {
							layer = 1,
							stream = true,
							texture = guis_catalog .. "textures/pd2/blackmarket/icons/materials/" .. material_id,
							right = right,
							bottom = bottom,
							w = w,
							h = h
						})

						if locked_parts.material then
							local texture = self:get_lock_icon({
								global_value = locked_parts.material
							})

							table.insert(new_data.mini_icons, {
								layer = 2,
								h = 24,
								w = 24,
								texture = texture,
								right = right + (w - 32) / 2,
								bottom = bottom + (h - 24) / 2,
								color = tweak_data.screen_colors.important_1
							})
						end
					end
				end

				local right = 2
				local bottom = math.round(mini_icon_helper - 6 - 6 - 60 - 12)
				local w = 32
				local h = 32

				table.insert(new_data.mini_icons, {
					layer = 1,
					stream = true,
					texture = tweak_data.blackmarket.textures[pattern].texture,
					right = right,
					bottom = bottom,
					w = h,
					h = w,
					render_template = Idstring("VertexColorTexturedPatterns")
				})

				if locked_parts.pattern then
					local texture = self:get_lock_icon({
						global_value = locked_parts.pattern
					})

					table.insert(new_data.mini_icons, {
						layer = 2,
						h = 24,
						w = 24,
						texture = texture,
						right = right + (w - 32) / 2,
						bottom = bottom + (h - 32) / 2,
						color = tweak_data.screen_colors.important_1
					})
				end

				new_data.mini_icons.borders = true
			elseif index ~= 1 and managers.blackmarket:can_modify_mask(i) and managers.blackmarket:got_new_drop("normal", "mask_mods", crafted.mask_id) then
				new_data.mini_icons = new_data.mini_icons or {}

				table.insert(new_data.mini_icons, {
					stream = false,
					name = "new_drop",
					h = 16,
					layer = 1,
					w = 16,
					texture = "guis/textures/pd2/blackmarket/inv_newdrop",
					visible = true,
					top = 0,
					right = 0
				})

				new_data.new_drop_data = {}
			end

			if self._populate_masks_debug then
				self:_populate_masks_debug(crafted, new_data)
			end

			data[i] = new_data
		end
	end

	local can_buy_masks = true

	for i = 1, max_items, 1 do
		if not data[i] then
			can_buy_masks = managers.blackmarket:is_mask_slot_unlocked(data.on_create_data[i])
			new_data = {}

			if can_buy_masks then
				new_data.name = "bm_menu_btn_buy_new_mask"
				new_data.name_localized = managers.localization:text("bm_menu_empty_mask_slot")
				new_data.mid_text = {
					noselected_text = new_data.name_localized,
					noselected_color = tweak_data.screen_colors.button_stage_3
				}
				new_data.mid_text.selected_text = currently_holding and new_data.mid_text.noselected_text or managers.localization:text("bm_menu_btn_buy_new_mask")
				new_data.mid_text.selected_color = currently_holding and new_data.mid_text.noselected_color or tweak_data.screen_colors.button_stage_2
				new_data.empty_slot = true
				new_data.category = "masks"
				new_data.slot = data.on_create_data[i]
				new_data.unlocked = true
				new_data.equipped = false
				new_data.num_backs = 0
				new_data.cannot_buy = not can_buy_masks

				if currently_holding then
					if data.on_create_data[i] ~= 1 then
						new_data.selected_text = managers.localization:to_upper_text("bm_menu_btn_place_mask")
					end

					if data.on_create_data[i] ~= 1 then
						table.insert(new_data, "m_place")
					end

					table.insert(new_data, "i_stop_move")
				else
					table.insert(new_data, "em_buy")
				end

				if data.on_create_data[i] ~= 1 and managers.blackmarket:got_new_drop(nil, "mask_buy", nil) then
					new_data.mini_icons = new_data.mini_icons or {}

					table.insert(new_data.mini_icons, {
						stream = false,
						name = "new_drop",
						h = 16,
						layer = 1,
						w = 16,
						texture = "guis/textures/pd2/blackmarket/inv_newdrop",
						visible = false,
						top = 0,
						right = 0
					})

					new_data.new_drop_data = {}
				end
			else
				new_data.name = "bm_menu_btn_buy_mask_slot"
				new_data.name_localized = managers.localization:text("bm_menu_locked_mask_slot")
				new_data.empty_slot = true
				new_data.category = "masks"
				new_data.slot = data.on_create_data[i]
				new_data.unlocked = true
				new_data.equipped = false
				new_data.num_backs = 0
				new_data.lock_texture = "guis/textures/pd2/blackmarket/money_lock"
				new_data.lock_color = tweak_data.screen_colors.button_stage_3
				new_data.lock_shape = {
					w = 32,
					x = 0,
					h = 32,
					y = -32
				}
				new_data.locked_slot = true
				new_data.dlc_locked = managers.experience:cash_string(managers.money:get_buy_mask_slot_price())
				new_data.mid_text = {
					noselected_text = new_data.name_localized,
					noselected_color = tweak_data.screen_colors.button_stage_3,
					is_lock_same_color = true
				}

				if currently_holding then
					new_data.mid_text.selected_text = new_data.mid_text.noselected_text
					new_data.mid_text.selected_color = new_data.mid_text.noselected_color

					table.insert(new_data, "i_stop_move")
				elseif managers.money:can_afford_buy_mask_slot() then
					new_data.mid_text.selected_text = managers.localization:text("bm_menu_btn_buy_mask_slot")
					new_data.mid_text.selected_color = tweak_data.screen_colors.button_stage_2

					table.insert(new_data, "em_unlock")
				else
					new_data.mid_text.selected_text = managers.localization:text("bm_menu_cannot_buy_mask_slot")
					new_data.mid_text.selected_color = tweak_data.screen_colors.important_1
					new_data.dlc_locked = new_data.dlc_locked .. "  " .. managers.localization:to_upper_text("bm_menu_cannot_buy_mask_slot")
					new_data.mid_text.lock_noselected_color = tweak_data.screen_colors.important_1
					new_data.cannot_buy = true
				end
			end

			data[i] = new_data
		end
	end
end

function BlackMarketGui:populate_weapon_category_new(data)
	managers.blackmarket:clear_temporary()
	managers.blackmarket:clear_preview_blueprint()

	local category = data.category
	local crafted_category = managers.blackmarket:get_crafted_category(category) or {}
	local last_weapon = table.size(crafted_category) == 1
	local last_unlocked_weapon = nil

	if not last_weapon then
		local category_size = table.size(crafted_category)

		for i, crafted in pairs(crafted_category) do
			if not managers.blackmarket:weapon_unlocked(crafted.weapon_id) then
				category_size = category_size - 1
			end
		end

		last_unlocked_weapon = category_size == 1
	end

	local hold_crafted_item = managers.blackmarket:get_hold_crafted_item()
	local currently_holding = hold_crafted_item and hold_crafted_item.category == category
	local max_items = data.override_slots and data.override_slots[1] * data.override_slots[2] or 9
	local max_rows = tweak_data.gui.WEAPON_ROWS_PER_PAGE or 3
	max_items = max_rows * (data.override_slots and data.override_slots[1] or 3)

	for i = 1, max_items, 1 do
		data[i] = nil
	end

	local guis_catalog = "guis/"
	local bundle_folder = nil
	local weapon_data = Global.blackmarket_manager.weapons
	local new_data = {}
	local start_i = data.start_i
	local crafted, unlocked, part_dlc_lock, color_tweak = nil

	for i, index in pairs(data.on_create_data) do
		crafted = crafted_category[index]

		if crafted then
			new_data = {
				ignore_slot = data.equip_weapon_cosmetics and data.equip_weapon_cosmetics.weapon_id ~= crafted.weapon_id,
				name = crafted.weapon_id,
				name_localized = managers.blackmarket:get_weapon_name_by_category_slot(category, index),
				raw_name_localized = managers.weapon_factory:get_weapon_name_by_factory_id(crafted.factory_id)
			}
			new_data.custom_name_text = not new_data.ignore_slot and managers.blackmarket:get_crafted_custom_name(category, index, true)
			new_data.category = category
			new_data.slot = index
			unlocked, part_dlc_lock = managers.blackmarket:weapon_unlocked_by_crafted(new_data.category, new_data.slot)
			new_data.unlocked = unlocked
			new_data.level = managers.blackmarket:weapon_level(crafted.weapon_id)
			new_data.can_afford = true
			new_data.equipped = crafted.equipped
			new_data.skill_based = weapon_data[crafted.weapon_id].skill_based
			new_data.skill_name = new_data.skill_based and "bm_menu_skill_locked_" .. new_data.name
			new_data.func_based = weapon_data[crafted.weapon_id].func_based
			new_data.price = managers.money:get_weapon_slot_sell_value(category, index)
			local bitmap_texture, bg_texture = managers.blackmarket:get_weapon_icon_path(crafted.weapon_id, crafted.cosmetics)
			new_data.bitmap_texture = bitmap_texture
			new_data.bg_texture = not new_data.ignore_slot and bg_texture
			new_data.customize_locked = crafted.customize_locked
			new_data.locked_name = crafted.locked_name
			new_data.name_color = new_data.locked_name and crafted.cosmetics and tweak_data.economy.rarities[tweak_data.blackmarket.weapon_skins[crafted.cosmetics.id].rarity or "common"].color
			new_data.stream = true
			new_data.akimbo_gui_data = tweak_data.weapon[crafted.weapon_id] and tweak_data.weapon[crafted.weapon_id].akimbo_gui_data
			new_data.comparision_data = not new_data.ignore_slot and managers.blackmarket:get_weapon_stats(category, index)
			new_data.global_value = part_dlc_lock or tweak_data.weapon[new_data.name] and tweak_data.weapon[new_data.name].global_value or "normal"

			if _G.IS_VR then
				new_data.vr_locked = tweak_data.vr:is_locked("weapons", crafted.weapon_id)
				new_data.unlocked = new_data.unlocked and not tweak_data.vr:is_locked("weapons", crafted.weapon_id)
			end

			new_data.dlc_locked = tweak_data.lootdrop.global_values[new_data.global_value].unlock_id or nil
			new_data.lock_texture = new_data.ignore_slot or self:get_lock_icon(new_data)
			new_data.holding = currently_holding and hold_crafted_item.slot == index
			new_data.part_dlc_lock = part_dlc_lock
			new_data.global_value = tweak_data.weapon[new_data.name] and tweak_data.weapon[new_data.name].global_value or "normal"

			if data.equip_weapon_cosmetics then
				new_data.equipped_slot = new_data.slot
				new_data.equipped_name = new_data.name
			end

			local icon_list = managers.menu_component:create_weapon_mod_icon_list(crafted.weapon_id, category, crafted.factory_id, index)
			local icon_index = 1
			local new_parts = {}

			for _, part in pairs(managers.blackmarket:get_weapon_new_part_drops(crafted.factory_id) or {}) do
				local type = tweak_data.weapon.factory.parts[part].type
				new_parts[type] = true
			end

			if table.size(new_parts) > 0 then
				new_data.new_drop_data = {}
			end

			new_data.mini_icons = {}

			if not new_data.ignore_slot then
				for _, icon in ipairs(icon_list) do
					table.insert(new_data.mini_icons, {
						layer = 1,
						h = 16,
						stream = false,
						w = 16,
						texture = icon.texture,
						right = (icon_index - 1) % 11 * 18,
						bottom = math.floor((icon_index - 1) / 11) * 25,
						alpha = icon.equipped and 1 or 0.25
					})

					if new_parts[icon.type] then
						table.insert(new_data.mini_icons, {
							texture = "guis/textures/pd2/blackmarket/inv_mod_new",
							layer = 1,
							h = 8,
							stream = false,
							w = 16,
							alpha = 1,
							right = (icon_index - 1) % 11 * 18,
							bottom = math.floor((icon_index - 1) / 11) * 25 + 16
						})
					end

					icon_index = icon_index + 1
				end
			end

			new_data.hide_unselected_mini_icons = true
			color_tweak = crafted.cosmetics and tweak_data.blackmarket.weapon_skins[crafted.cosmetics.id]

			if color_tweak and color_tweak.is_a_color_skin then
				guis_catalog = "guis/"
				bundle_folder = color_tweak.texture_bundle_folder

				if bundle_folder then
					guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
				end

				table.insert(new_data.mini_icons, {
					stream = true,
					h = 32,
					layer = 0,
					w = 64,
					right = -16,
					texture = guis_catalog .. "textures/pd2/blackmarket/icons/weapon_color/" .. crafted.cosmetics.id,
					bottom = math.floor((#icon_list - 1) / 11) * 25 + 24
				})
			end

			if not new_data.unlocked then
				new_data.last_weapon = last_weapon
			else
				new_data.last_weapon = last_weapon or last_unlocked_weapon
			end

			if new_data.equipped then
				self._equipped_comparision_data = self._equipped_comparision_data or {}
				self._equipped_comparision_data[category] = new_data.comparision_data
			end

			local active = true

			if not new_data.ignore_slot then
				if data.equip_weapon_cosmetics and data.equip_weapon_cosmetics.weapon_id == crafted.weapon_id then
					if active then
						table.insert(new_data, "wcc_equip")
					end

					new_data.equip_weapon_cosmetics = data.equip_weapon_cosmetics
				elseif currently_holding then
					new_data.selected_text = managers.localization:to_upper_text("bm_menu_btn_swap_weapon")

					if new_data.slot ~= hold_crafted_item.slot then
						table.insert(new_data, "w_swap")
					end

					table.insert(new_data, "i_stop_move")
				else
					local has_mods = managers.weapon_factory:has_weapon_more_than_default_parts(crafted.factory_id)
					local can_mod = true

					if can_mod and data.allow_modify ~= false and has_mods and active then
						table.insert(new_data, "w_mod")
					end

					if data.allow_skinning ~= false and has_mods and active and managers.workshop and managers.workshop:enabled() and not table.contains(managers.blackmarket:skin_editor():get_excluded_weapons(), new_data.name) then
						table.insert(new_data, "w_skin")
					end

					if data.allow_sell ~= false and not new_data.last_weapon then
						table.insert(new_data, "w_sell")
					end

					if active and not new_data.equipped and new_data.unlocked then
						table.insert(new_data, "w_equip")
					end

					if new_data.equipped and new_data.unlocked then
						table.insert(new_data, "w_move")
					end

					if data.allow_preview ~= false and active then
						table.insert(new_data, "w_preview")
					end
				end
			end

			data[i] = new_data
		end
	end

	for i = 1, max_items, 1 do
		if not data[i] then
			new_data = {}

			if data.allow_buy ~= false then
				local can_buy_weapon = managers.blackmarket:is_weapon_slot_unlocked(category, data.on_create_data[i])

				if can_buy_weapon then
					new_data.name = "bm_menu_btn_buy_new_weapon"
					new_data.name_localized = managers.localization:text("bm_menu_empty_weapon_slot")
					new_data.mid_text = {
						noselected_text = new_data.name_localized,
						noselected_color = tweak_data.screen_colors.button_stage_3
					}
					new_data.mid_text.selected_text = currently_holding and new_data.mid_text.noselected_text or managers.localization:text("bm_menu_btn_buy_new_weapon")
					new_data.mid_text.selected_color = currently_holding and new_data.mid_text.noselected_color or tweak_data.screen_colors.button_stage_2
					new_data.empty_slot = true
					new_data.category = category
					new_data.slot = data.on_create_data[i]
					new_data.unlocked = true
					new_data.equipped = false

					if data.equip_weapon_cosmetics then
						if managers.money:can_afford_weapon(data.equip_weapon_cosmetics.weapon_id) then
							table.insert(new_data, "wcc_buy_equip_weapon")

							new_data.equip_weapon_cosmetics = data.equip_weapon_cosmetics
						else
							new_data.mid_text.selected_text = managers.localization:text("bm_menu_cannot_buy_weapon_slot")
							new_data.mid_text.selected_color = tweak_data.screen_colors.important_1
							new_data.dlc_locked = managers.localization:to_upper_text("bm_menu_cannot_buy_weapon_slot")
							new_data.mid_text.lock_noselected_color = tweak_data.screen_colors.important_1
							new_data.cannot_buy = true
						end
					else
						if currently_holding then
							new_data.selected_text = managers.localization:to_upper_text("bm_menu_btn_place_weapon")

							table.insert(new_data, "w_place")
							table.insert(new_data, "i_stop_move")
						else
							table.insert(new_data, "ew_buy")
						end

						if managers.blackmarket:got_new_drop(new_data.category, "weapon_buy_empty", nil) then
							new_data.mini_icons = new_data.mini_icons or {}

							table.insert(new_data.mini_icons, {
								stream = false,
								name = "new_drop",
								h = 16,
								layer = 1,
								w = 16,
								texture = "guis/textures/pd2/blackmarket/inv_newdrop",
								visible = false,
								top = 0,
								right = 0
							})

							new_data.new_drop_data = {}
						end
					end
				else
					new_data.name = "bm_menu_btn_buy_weapon_slot"
					new_data.name_localized = managers.localization:text("bm_menu_locked_weapon_slot")
					new_data.empty_slot = true
					new_data.category = category
					new_data.slot = data.on_create_data[i]
					new_data.unlocked = true
					new_data.equipped = false
					new_data.lock_texture = "guis/textures/pd2/blackmarket/money_lock"
					new_data.lock_color = tweak_data.screen_colors.button_stage_3
					new_data.lock_shape = {
						w = 32,
						x = 0,
						h = 32,
						y = -32
					}
					new_data.locked_slot = true
					new_data.dlc_locked = managers.experience:cash_string(managers.money:get_buy_weapon_slot_price())
					new_data.mid_text = {
						noselected_text = new_data.name_localized,
						noselected_color = tweak_data.screen_colors.button_stage_3,
						is_lock_same_color = true
					}

					if currently_holding then
						new_data.mid_text.selected_text = new_data.mid_text.noselected_text
						new_data.mid_text.selected_color = new_data.mid_text.noselected_color

						table.insert(new_data, "i_stop_move")
					elseif managers.money:can_afford_buy_weapon_slot() then
						new_data.mid_text.selected_text = managers.localization:text("bm_menu_btn_buy_weapon_slot")
						new_data.mid_text.selected_color = tweak_data.screen_colors.button_stage_2

						table.insert(new_data, "ew_unlock")
					else
						new_data.mid_text.selected_text = managers.localization:text("bm_menu_cannot_buy_weapon_slot")
						new_data.mid_text.selected_color = tweak_data.screen_colors.important_1
						new_data.dlc_locked = new_data.dlc_locked .. "  " .. managers.localization:to_upper_text("bm_menu_cannot_buy_weapon_slot")
						new_data.mid_text.lock_noselected_color = tweak_data.screen_colors.important_1
						new_data.cannot_buy = true
					end
				end
			else
				new_data.name = "bm_menu_btn_unavailable"
				new_data.name_localized = managers.localization:text("bm_menu_btn_unavailable")
				new_data.mid_text = {
					noselected_text = new_data.name_localized,
					noselected_color = tweak_data.screen_colors.button_stage_3
				}
				new_data.mid_text.selected_text = currently_holding and new_data.mid_text.noselected_text or managers.localization:text("bm_menu_btn_unavailable")
				new_data.mid_text.selected_color = currently_holding and new_data.mid_text.noselected_color or tweak_data.screen_colors.button_stage_2
				new_data.empty_slot = true
				new_data.is_loadout = true
				new_data.category = category
				new_data.slot = data.on_create_data[i]
				new_data.unlocked = true
				new_data.equipped = false
			end

			data[i] = new_data
		end
	end
end

function BlackMarketGui:populate_melee_weapons_new(data)
	local max_items = math.ceil(#data.on_create_data / (data.override_slots[1] or 3)) * (data.override_slots[1] or 3)
	local new_data = {}

	for i = 1, max_items, 1 do
		data[i] = nil
	end

	local index = 0
	local guis_catalog, m_tweak_data, melee_weapon_id = nil

	for i, melee_weapon_data in ipairs(data.on_create_data) do
		melee_weapon_id = melee_weapon_data[1]
		m_tweak_data = tweak_data.blackmarket.melee_weapons[melee_weapon_data[1]] or {}
		guis_catalog = "guis/"
		local bundle_folder = m_tweak_data.texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		new_data = {
			name = melee_weapon_id
		}
		new_data.name_localized = managers.localization:text(tweak_data.blackmarket.melee_weapons[new_data.name].name_id)
		new_data.category = "melee_weapons"
		new_data.slot = i
		new_data.unlocked = melee_weapon_data[2].unlocked
		new_data.equipped = melee_weapon_data[2].equipped
		new_data.level = melee_weapon_data[2].level
		new_data.stream = true
		new_data.global_value = tweak_data.lootdrop.global_values[m_tweak_data.dlc] and m_tweak_data.dlc or "normal"
		new_data.skill_based = melee_weapon_data[2].skill_based
		new_data.skill_name = "bm_menu_skill_locked_" .. new_data.name
		new_data.func_based = melee_weapon_data[2].func_based

		if _G.IS_VR then
			new_data.vr_locked = melee_weapon_data[2].vr_locked
		end

		if not new_data.unlocked then
			local gv_dlc = managers.dlc:global_value_to_dlc(new_data.global_value)

			if gv_dlc and not managers.dlc:is_dlc_unlocked(gv_dlc) then
				new_data.dlc_based = true
				new_data.dlc_locked = tweak_data.lootdrop.global_values[new_data.global_value].unlock_id or "bm_menu_dlc_locked"
				new_data.lock_texture = self:get_lock_icon(new_data, "guis/textures/pd2/lock_community")
			elseif new_data.level > 0 then
				new_data.lock_texture = "guis/textures/pd2/lock_level"
			end

			if m_tweak_data and m_tweak_data.locks then
				local func = m_tweak_data.locks.func
				local achievement = m_tweak_data.locks.achievement
				local dlc = m_tweak_data.locks.dlc
				new_data.dlc_based = true

				if func and not BlackMarketGui.get_func_based(func) then
					local _, name, icon = BlackMarketGui.get_func_based(func)
					new_data.dlc_locked = name
					new_data.lock_texture = icon or "guis/textures/pd2/skilltree/padlock"
				elseif achievement and managers.achievment:get_info(achievement) and not managers.achievment:get_info(achievement).awarded then
					local achievement_lock_id = m_tweak_data.locks.achievement_lock_id
					new_data.dlc_locked = achievement_lock_id or "menu_bm_achievement_locked_" .. tostring(achievement)
					new_data.lock_texture = "guis/textures/pd2/lock_achievement"
				elseif dlc and not managers.dlc:is_dlc_unlocked(dlc) then
					new_data.dlc_locked = tweak_data.lootdrop.global_values[dlc] and tweak_data.lootdrop.global_values[dlc].unlock_id or "bm_menu_dlc_locked"
					new_data.lock_texture = "guis/textures/pd2/lock_dlc"
				else
					new_data.dlc_based = false
				end
			end
		end

		new_data.bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/melee_weapons/" .. tostring(new_data.name)

		if managers.blackmarket:got_new_drop("normal", "melee_weapons", melee_weapon_id) then
			new_data.mini_icons = new_data.mini_icons or {}

			table.insert(new_data.mini_icons, {
				texture = "guis/textures/pd2/blackmarket/inv_newdrop",
				name = "new_drop",
				h = 16,
				w = 16,
				top = 0,
				layer = 1,
				stream = false,
				right = 0
			})

			new_data.new_drop_data = {
				"normal",
				"melee_weapons",
				melee_weapon_id
			}
		end

		local active = true
		new_data.comparision_data = managers.blackmarket:get_melee_weapon_stats(melee_weapon_id)

		if active then
			if new_data.unlocked and not new_data.equipped then
				table.insert(new_data, "lo_mw_equip")
			end

			if data.allow_preview and m_tweak_data.unit and not m_tweak_data.no_inventory_preview then
				table.insert(new_data, "lo_mw_preview")
			end
		end

		data[i] = new_data
		index = i
	end

	for i = 1, max_items, 1 do
		if not data[i] then
			new_data = {
				name = "empty",
				name_localized = "",
				category = "melee_weapons",
				slot = i,
				unlocked = true,
				equipped = false
			}
			data[i] = new_data
		end
	end
end

function BlackMarketGui:populate_mod_types(data)
	local new_data = {}
	local index = 1
	local guis_catalog = "guis/"

	for type, mods in pairs(data.on_create_data) do
		new_data = {
			name = type,
			name_localized = managers.localization:text("bm_menu_" .. tostring(type))
		}
		new_data.bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/mods/" .. new_data.name
		new_data.category = data.category
		new_data.slot = data.prev_node_data and data.prev_node_data.slot or 1
		new_data.unlocked = true
		new_data.equipped = false
		new_data.mods = mods

		table.insert(new_data, "mt_choose")

		data[index] = new_data
		index = index + 1
	end

	for i = 1, 9, 1 do
		if not data[i] then
			new_data = {
				name = "empty",
				name_localized = "",
				category = data.category,
				slot = i,
				unlocked = true,
				equipped = false
			}
			data[i] = new_data
		end
	end
end

local function make_cosmetic_data(data, cosmetic_id, unlocked, quality, bonus, equipped)
	local crafted = managers.blackmarket:get_crafted_category(data.category)[data.prev_node_data and data.prev_node_data.slot]
	local my_cd = tweak_data.blackmarket.weapon_skins[cosmetic_id]
	local new_data = {
		name = cosmetic_id,
		name_localized = my_cd and my_cd.name_id and managers.localization:text(my_cd.name_id) or managers.localization:text("bm_menu_no_mod"),
		desc_id = my_cd and my_cd.desc_id,
		lock_text_id = my_cd and my_cd.lock_id,
		category = data.category or data.prev_node_data and data.prev_node_data.category,
		default_blueprint = my_cd and my_cd.default_blueprint,
		locked_cosmetics = my_cd and my_cd.locked
	}
	local bitmap_texture, bg_texture = managers.blackmarket:get_weapon_icon_path(data.prev_node_data.name, {
		id = cosmetic_id
	})
	new_data.bitmap_texture = bitmap_texture
	new_data.bg_texture = bg_texture

	if not unlocked then
		new_data.bitmap_locked_blend_mode = "normal"
		new_data.bitmap_locked_alpha = 0.6
		new_data.bg_alpha = 0.4
	end

	new_data.slot = data.slot or data.prev_node_data and data.prev_node_data.slot
	new_data.global_value = my_cd and my_cd.global_value or "normal"
	new_data.akimbo_gui_data = tweak_data.weapon[crafted.weapon_id] and tweak_data.weapon[crafted.weapon_id].akimbo_gui_data
	new_data.cosmetic_id = cosmetic_id
	new_data.cosmetic_quality = quality
	new_data.cosmetic_rarity = my_cd and my_cd.rarity or "common"
	new_data.cosmetic_bonus = bonus
	new_data.unlocked = unlocked
	new_data.equipped = equipped
	new_data.stream = true
	new_data.lock_texture = not new_data.unlocked

	if new_data.default_blueprint then
		new_data.comparision_data = managers.blackmarket:get_weapon_stats(new_data.category, new_data.slot, new_data.default_blueprint)
	end

	if new_data.unlocked then
		if managers.blackmarket:last_previewed_cosmetic() == cosmetic_id then
			table.insert(new_data, "wcc_cancel_preview")
		else
			table.insert(new_data, "wcc_preview")
		end
	end

	if new_data.equipped then
		table.insert(new_data, "wcc_remove")
	end

	if new_data.unlocked then
		if not crafted.previewing and not new_data.equipped then
			table.insert(new_data, "wcc_equip")
		end

		if managers.blackmarket:is_previewing_any_mod() then
			table.insert(new_data, "wm_clear_mod_preview")
		end
	else
		if managers.blackmarket:last_previewed_cosmetic() == cosmetic_id then
			table.insert(new_data, "wcc_cancel_preview")
		else
			table.insert(new_data, "wcc_preview")
		end

		if not crafted.previewing and not my_cd.is_a_unlockable and managers.menu:is_pc_controller() then
			table.insert(new_data, "wcc_market")
		end

		if managers.blackmarket:is_previewing_any_mod() then
			table.insert(new_data, "wm_clear_mod_preview")
		end

		new_data.mini_icons = new_data.mini_icons or {}

		table.insert(new_data.mini_icons, {
			stream = true,
			layer = 2,
			h = 30,
			w = 30,
			blend_mode = "normal",
			bottom = 1,
			right = 1,
			texture = my_cd.is_a_unlockable and "guis/textures/pd2/skilltree/padlock" or "guis/textures/pd2/lock_dlc",
			color = tweak_data.screen_colors.important_1
		})
	end

	return new_data
end

function BlackMarketGui:populate_weapon_cosmetics(data)
	local crafted = managers.blackmarket:get_crafted_category(data.category)[data.prev_node_data and data.prev_node_data.slot]
	local cosmetics_data = tweak_data.blackmarket.weapon_skins
	local my_cd, new_data, bitmap_texture, bg_texture = nil
	local inventory_tradable = managers.blackmarket:get_inventory_tradable()
	local cosmetics_instances = data.on_create_data.instances or {}
	local all_cosmetics = data.on_create_data.cosmetics or {}
	local cosmetic_data, cosmetic_id = nil
	local index_i = 1
	cosmetic_id = tweak_data.blackmarket.weapon_color_default
	cosmetic_data = cosmetics_data[cosmetic_id]
	local unlocked = true
	local equipped = false
	local quality = "good"
	local color_index = 1
	local color_texture = nil
	local equipped_cosmetic_id = crafted and crafted.cosmetics and crafted.cosmetics.id
	local equipped_tweak = cosmetics_data[equipped_cosmetic_id]

	if equipped_tweak and equipped_tweak.is_a_color_skin then
		cosmetic_id = equipped_cosmetic_id
		cosmetic_data = equipped_tweak
		quality = crafted.cosmetics.quality
		color_index = crafted.cosmetics.color_index
		equipped = true
		local dlc = cosmetic_data.dlc or managers.dlc:global_value_to_dlc(cosmetic_data.global_value)
		local global_value = cosmetic_data.global_value or managers.dlc:dlc_to_global_value(dlc)
		local dlc_unlocked = not dlc or managers.dlc:is_dlc_unlocked(dlc)
		local have_color = managers.blackmarket:has_item(global_value, "weapon_skins", equipped_cosmetic_id)
		unlocked = dlc_unlocked and have_color
		local guis_catalog = "guis/"
		local bundle_folder = equipped_tweak.texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		color_texture = guis_catalog .. "textures/pd2/blackmarket/icons/weapon_color/" .. cosmetic_id
	end

	local global_value = cosmetic_data.global_value or "normal"
	new_data = make_cosmetic_data(data, cosmetic_id, unlocked, quality, nil, equipped)
	new_data.name_localized = managers.localization:text("bm_menu_customizable_weapon_color")
	new_data.is_a_color_skin = true
	new_data.bitmap_texture = color_texture
	new_data.cosmetic_color_index = color_index
	new_data.mid_text_no_change_alpha = true
	new_data.mid_text = {
		selected_text = new_data.name_localized,
		selected_color = tweak_data.screen_colors.text
	}
	new_data.mid_text.noselected_text = new_data.mid_text.selected_text
	new_data.mid_text.noselected_color = tweak_data.screen_colors.text
	new_data.mid_text.font = small_font
	new_data.mid_text.font_size = small_font_size
	new_data.mid_text.vertical = "center"

	if equipped then
		table.insert(new_data, "wcs_customize_color")
	end

	local equip_index = table.get_vector_index(new_data, "wcc_equip")

	if equip_index then
		new_data[equip_index] = "wcs_equip"
	end

	data[index_i] = new_data
	index_i = index_i + 1

	for _, instance_id in ipairs(cosmetics_instances) do
		cosmetic_id = inventory_tradable[instance_id].entry
		my_cd = cosmetics_data[cosmetic_id]
		local quality = inventory_tradable[instance_id].quality
		local bonus = inventory_tradable[instance_id].bonus
		local equipped = crafted and crafted.cosmetics and crafted.cosmetics.instance_id == instance_id
		new_data = make_cosmetic_data(data, cosmetic_id, true, quality, bonus, equipped)
		new_data.name = instance_id

		if new_data.cosmetic_bonus then
			local bonuses = tweak_data.economy:get_bonus_icons(my_cd.bonus)
			local x = 0

			for _, texture_path in ipairs(bonuses) do
				new_data.mini_icons = new_data.mini_icons or {}

				table.insert(new_data.mini_icons, {
					name = "has_bonus",
					h = 16,
					layer = 1,
					w = 16,
					stream = false,
					bottom = 0,
					texture = texture_path,
					right = x
				})

				x = x + 17
			end
		end

		data[index_i] = new_data
		index_i = index_i + 1
	end

	for _, cosm_data in ipairs(all_cosmetics) do
		cosmetic_id = cosm_data.id
		cosmetic_data = cosm_data.data
		my_cd = cosmetics_data[cosmetic_id]

		if not my_cd.is_template then
			local global_value = my_cd and my_cd.global_value or "normal"
			local unlocked = managers.blackmarket:get_item_amount(global_value, "weapon_skins", cosmetic_id, true) > 0
			local equipped = crafted and crafted.cosmetics and crafted.cosmetics.instance_id == cosmetic_id
			new_data = make_cosmetic_data(data, cosmetic_id, unlocked, "mint", nil, equipped)
			data[index_i] = new_data
			index_i = index_i + 1
		end
	end

	local total_cosmetics = #cosmetics_instances + #all_cosmetics
	total_cosmetics = total_cosmetics + 1
	local new_data = nil
	local max_items = self:calc_max_items(total_cosmetics, data.override_slots or WEAPON_MODS_SLOTS)

	for i = 1, max_items, 1 do
		if not data[i] then
			new_data = {
				name = "empty",
				name_localized = "",
				category = data.category,
				slot = i,
				unlocked = true,
				equipped = false
			}
			data[i] = new_data
		end
	end
end

function BlackMarketGui:populate_mods(data)
	local new_data = {}
	local default_mod = data.on_create_data.default_mod
	local crafted = managers.blackmarket:get_crafted_category(data.prev_node_data.category)[data.prev_node_data.slot]
	local global_values = crafted.global_values or {}
	local ids_id = Idstring(data.name)
	local cosmetic_kit_mod = nil
	local cosmetics_blueprint = crafted.cosmetics and crafted.cosmetics.id and tweak_data.blackmarket.weapon_skins[crafted.cosmetics.id] and tweak_data.blackmarket.weapon_skins[crafted.cosmetics.id].default_blueprint or {}

	for i, c_mod in ipairs(cosmetics_blueprint) do
		if Idstring(tweak_data.weapon.factory.parts[c_mod].type) == ids_id then
			cosmetic_kit_mod = c_mod

			break
		end
	end

	local gvs = {}
	local mod_t = {}
	local num_steps = #data.on_create_data
	local achievement_tracker = tweak_data.achievement.weapon_part_tracker
	local part_is_from_cosmetic = nil
	local guis_catalog = "guis/"

	for index, mod_t in ipairs(data.on_create_data) do
		local mod_name = mod_t[1]
		local mod_default = mod_t[2]
		local mod_global_value = mod_t[3] or "normal"
		part_is_from_cosmetic = cosmetic_kit_mod == mod_name
		guis_catalog = "guis/"
		local bundle_folder = tweak_data.blackmarket.weapon_mods[mod_name] and tweak_data.blackmarket.weapon_mods[mod_name].texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		new_data = {
			name = mod_name or data.prev_node_data.name,
			name_localized = mod_name and managers.weapon_factory:get_part_name_by_part_id(mod_name) or managers.localization:text("bm_menu_no_mod"),
			category = data.category or data.prev_node_data and data.prev_node_data.category
		}
		new_data.bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/mods/" .. new_data.name
		new_data.slot = data.slot or data.prev_node_data and data.prev_node_data.slot
		new_data.global_value = mod_global_value
		new_data.unlocked = not crafted.customize_locked and part_is_from_cosmetic and 1 or mod_default or managers.blackmarket:get_item_amount(new_data.global_value, "weapon_mods", new_data.name, true)
		new_data.equipped = false
		new_data.stream = true
		new_data.default_mod = default_mod
		new_data.cosmetic_kit_mod = cosmetic_kit_mod
		new_data.is_internal = tweak_data.weapon.factory:is_part_internal(new_data.name)
		new_data.free_of_charge = part_is_from_cosmetic or tweak_data.blackmarket.weapon_mods[mod_name] and tweak_data.blackmarket.weapon_mods[mod_name].is_a_unlockable
		new_data.unlock_tracker = achievement_tracker[new_data.name] or false

		if crafted.customize_locked then
			new_data.unlocked = type(new_data.unlocked) == "number" and -math.abs(new_data.unlocked) or new_data.unlocked
			new_data.unlocked = new_data.unlocked ~= 0 and new_data.unlocked or false
			new_data.lock_texture = "guis/textures/pd2/lock_incompatible"
			new_data.dlc_locked = "bm_menu_cosmetic_locked_weapon"
		elseif not part_is_from_cosmetic and tweak_data.lootdrop.global_values[mod_global_value] and tweak_data.lootdrop.global_values[mod_global_value].dlc and not managers.dlc:is_dlc_unlocked(mod_global_value) then
			new_data.unlocked = -math.abs(new_data.unlocked)
			new_data.unlocked = new_data.unlocked ~= 0 and new_data.unlocked or false
			new_data.lock_texture = self:get_lock_icon(new_data)
			new_data.dlc_locked = tweak_data.lootdrop.global_values[new_data.global_value].unlock_id or "bm_menu_dlc_locked"
		end

		local weapon_id = managers.blackmarket:get_crafted_category(new_data.category)[new_data.slot].weapon_id
		new_data.price = part_is_from_cosmetic and 0 or managers.money:get_weapon_modify_price(weapon_id, new_data.name, new_data.global_value)
		new_data.can_afford = part_is_from_cosmetic or managers.money:can_afford_weapon_modification(weapon_id, new_data.name, new_data.global_value)
		local font, font_size = nil
		local no_upper = false

		if crafted.previewing then
			new_data.previewing = true
			new_data.corner_text = {
				selected_text = managers.localization:text("bm_menu_mod_preview")
			}
			new_data.corner_text.noselected_text = new_data.corner_text.selected_text
			new_data.corner_text.noselected_color = Color.white
		elseif not new_data.lock_texture and (not new_data.unlocked or new_data.unlocked == 0) then
			local selected_text, noselected_text = nil

			if not new_data.dlc_locked and new_data.unlock_tracker then
				local text_id = "bm_menu_no_items"
				local progress = ""
				local stat = new_data.unlock_tracker.stat or false
				local max_progress = new_data.unlock_tracker.max_progress or 0
				local award = new_data.unlock_tracker.award or false

				if false and new_data.unlock_tracker.text_id then
					if max_progress > 0 and stat then
						local progress_left = max_progress - (managers.achievment:get_stat(stat) or 0)

						if progress_left > 0 then
							progress = tostring(progress_left)
							text_id = new_data.unlock_tracker.text_id
							font = small_font
							font_size = small_font_size
							no_upper = true
						end
					elseif award then
						local achievement = managers.achievment:get_info(award)
						text_id = new_data.unlock_tracker.text_id
						font = small_font
						font_size = small_font_size
						no_upper = true
					end

					selected_text = managers.localization:text(text_id, {
						progress = progress
					})
				end
			end

			selected_text = selected_text or managers.localization:text("bm_menu_no_items")
			noselected_text = selected_text
			new_data.corner_text = {
				selected_text = selected_text,
				noselected_text = selected_text
			}
		elseif new_data.unlocked and not new_data.can_afford then
			new_data.corner_text = {
				selected_text = managers.localization:text("bm_menu_not_enough_cash")
			}
			new_data.corner_text.noselected_text = new_data.corner_text.selected_text
		end

		local forbid = nil

		if mod_name then
			forbid = managers.blackmarket:can_modify_weapon(new_data.category, new_data.slot, new_data.name)

			if forbid then
				if type(new_data.unlocked) == "number" then
					new_data.unlocked = -math.abs(new_data.unlocked)
				else
					new_data.unlocked = false
				end

				new_data.lock_texture = self:get_lock_icon(new_data, "guis/textures/pd2/lock_incompatible")
				new_data.mid_text = nil
				new_data.conflict = managers.localization:text("bm_menu_" .. tostring(tweak_data.weapon.factory.parts[forbid] and tweak_data.weapon.factory.parts[forbid].type or forbid))
			end

			local replaces, removes = managers.blackmarket:get_modify_weapon_consequence(new_data.category, new_data.slot, new_data.name)
			new_data.removes = removes or {}
			local weapon = managers.blackmarket:get_crafted_category_slot(data.prev_node_data.category, data.prev_node_data.slot) or {}
			local gadget = nil
			local mod_td = tweak_data.weapon.factory.parts[new_data.name]
			local mod_type = mod_td.type
			local sub_type = mod_td.sub_type
			local is_auto = weapon and tweak_data.weapon[weapon.weapon_id] and tweak_data.weapon[weapon.weapon_id].FIRE_MODE == "auto"

			if mod_type == "gadget" then
				gadget = sub_type
			end

			local silencer = sub_type == "silencer" and true
			local texture = managers.menu_component:get_texture_from_mod_type(mod_type, sub_type, gadget, silencer, is_auto)
			new_data.desc_mini_icons = {}

			if DB:has(Idstring("texture"), texture) then
				table.insert(new_data.desc_mini_icons, {
					h = 16,
					w = 16,
					bottom = 0,
					right = 0,
					texture = texture
				})
			end

			local is_gadget = false

			if not new_data.conflict and new_data.unlocked and not is_gadget and not new_data.dlc_locked then
				new_data.comparision_data = managers.blackmarket:get_weapon_stats_with_mod(new_data.category, new_data.slot, mod_name)
			end

			if managers.blackmarket:got_new_drop(mod_global_value, "weapon_mods", mod_name) then
				new_data.mini_icons = new_data.mini_icons or {}

				table.insert(new_data.mini_icons, {
					texture = "guis/textures/pd2/blackmarket/inv_newdrop",
					name = "new_drop",
					h = 16,
					w = 16,
					top = 0,
					layer = 1,
					stream = false,
					right = 0
				})

				new_data.new_drop_data = {
					new_data.global_value or "normal",
					"weapon_mods",
					mod_name
				}
			end
		end

		local active = true
		local can_apply = not crafted.previewing
		local preview_forbidden = managers.blackmarket:is_previewing_legendary_skin() or managers.blackmarket:preview_mod_forbidden(new_data.category, new_data.slot, new_data.name)

		if mod_name and not crafted.customize_locked and active then
			if new_data.unlocked and (type(new_data.unlocked) ~= "number" or new_data.unlocked > 0) and can_apply then
				if new_data.can_afford then
					table.insert(new_data, "wm_buy")
				end

				if managers.blackmarket:is_previewing_any_mod() then
					table.insert(new_data, "wm_clear_mod_preview")
				end

				if not new_data.is_internal and not preview_forbidden then
					if managers.blackmarket:is_previewing_mod(new_data.name) then
						table.insert(new_data, "wm_remove_preview")
					else
						table.insert(new_data, "wm_preview_mod")
					end
				end
			else
				if managers.blackmarket:is_previewing_any_mod() then
					table.insert(new_data, "wm_clear_mod_preview")
				end

				if not new_data.is_internal and not preview_forbidden then
					if managers.blackmarket:is_previewing_mod(new_data.name) then
						table.insert(new_data, "wm_remove_preview")
					else
						table.insert(new_data, "wm_preview_mod")
					end
				end
			end

			if managers.workshop and managers.workshop:enabled() and not table.contains(managers.blackmarket:skin_editor():get_excluded_weapons(), weapon_id) then
				table.insert(new_data, "w_skin")
			end

			if new_data.unlocked and not new_data.dlc_locked then
				local weapon_mod_tweak = tweak_data.weapon.factory.parts[mod_name]

				if weapon_mod_tweak and weapon_mod_tweak.type ~= "bonus" and weapon_mod_tweak.is_a_unlockable ~= true and can_apply and managers.custom_safehouse:unlocked() then
					table.insert(new_data, "wm_buy_mod")
				end
			end
		end

		data[index] = new_data
	end

	for i = 1, math.max(math.ceil(num_steps / WEAPON_MODS_SLOTS[1]), WEAPON_MODS_SLOTS[2]) * WEAPON_MODS_SLOTS[1], 1 do
		if not data[i] then
			new_data = {
				name = "empty",
				name_localized = "",
				category = data.category,
				slot = i,
				unlocked = true,
				equipped = false
			}
			data[i] = new_data
		end
	end

	local weapon_blueprint = managers.blackmarket:get_weapon_blueprint(data.prev_node_data.category, data.prev_node_data.slot) or {}
	local equipped = nil

	local function update_equipped()
		if equipped then
			data[equipped].equipped = true
			data[equipped].unlocked = not crafted.customize_locked and (data[equipped].unlocked or true)
			data[equipped].mid_text = crafted.customize_locked and data[equipped].mid_text or nil
			data[equipped].lock_texture = crafted.customize_locked and data[equipped].lock_texture or nil
			data[equipped].corner_text = crafted.customize_locked and data[equipped].corner_text or nil

			for i = 1, #data[equipped], 1 do
				table.remove(data[equipped], 1)
			end

			data[equipped].price = 0
			data[equipped].can_afford = true

			if not crafted.customize_locked then
				table.insert(data[equipped], "wm_remove_buy")

				if not data[equipped].is_internal then
					local preview_forbidden = managers.blackmarket:is_previewing_legendary_skin() or managers.blackmarket:preview_mod_forbidden(data[equipped].category, data[equipped].slot, data[equipped].name)

					if managers.blackmarket:is_previewing_any_mod() then
						table.insert(data[equipped], "wm_clear_mod_preview")
					end

					if managers.blackmarket:is_previewing_mod(data[equipped].name) then
						table.insert(data[equipped], "wm_remove_preview")
					elseif not preview_forbidden then
						table.insert(data[equipped], "wm_preview_mod")
					end
				else
					table.insert(data[equipped], "wm_preview")
				end

				if managers.workshop and managers.workshop:enabled() and data.prev_node_data and not table.contains(managers.blackmarket:skin_editor():get_excluded_weapons(), data.prev_node_data.name) then
					table.insert(data[equipped], "w_skin")
				end

				local weapon_mod_tweak = tweak_data.weapon.factory.parts[data[equipped].name]

				if weapon_mod_tweak and weapon_mod_tweak.type ~= "bonus" and weapon_mod_tweak.is_a_unlockable ~= true and managers.custom_safehouse:unlocked() then
					table.insert(data[equipped], "wm_buy_mod")
				end
			end

			local factory = tweak_data.weapon.factory.parts[data[equipped].name]

			if (data.name == "sight" or data.name == "gadget") and factory and factory.texture_switch then
				if not crafted.customize_locked then
					table.insert(data[equipped], "wm_reticle_switch_menu")
				end

				local reticle_texture = managers.blackmarket:get_part_texture_switch(data[equipped].category, data[equipped].slot, data[equipped].name)

				if reticle_texture and reticle_texture ~= "" then
					data[equipped].mini_icons = data[equipped].mini_icons or {}

					table.insert(data[equipped].mini_icons, {
						layer = 2,
						h = 30,
						stream = true,
						w = 30,
						blend_mode = "add",
						bottom = 1,
						right = 1,
						texture = reticle_texture
					})
				end
			end

			local mod_td = tweak_data.weapon.factory.parts[data[equipped].name]

			if (data.name == "gadget" or table.contains(mod_td.perks or {}, "gadget")) and (mod_td.sub_type == "laser" or mod_td.sub_type == "flashlight") then
				if not crafted.customize_locked then
					table.insert(data[equipped], "wm_customize_gadget")
				end

				local secondary_sub_type = false

				if mod_td.adds then
					for _, part_id in ipairs(mod_td.adds) do
						local sub_type = tweak_data.weapon.factory.parts[part_id].sub_type

						if sub_type == "laser" or sub_type == "flashlight" then
							secondary_sub_type = sub_type

							break
						end
					end
				end

				local colors = managers.blackmarket:get_part_custom_colors(data[equipped].category, data[equipped].slot, data[equipped].name)

				if colors then
					data[equipped].mini_colors = {}

					table.insert(data[equipped].mini_colors, {
						alpha = 0.8,
						blend = "add",
						color = colors[mod_td.sub_type] or Color(1, 0, 1)
					})

					if secondary_sub_type then
						table.insert(data[equipped].mini_colors, {
							alpha = 0.8,
							blend = "add",
							color = colors[secondary_sub_type] or Color(1, 0, 1)
						})
					end
				end
			end

			if not data[equipped].conflict then
				if false then
					if data[equipped].default_mod then
						data[equipped].comparision_data = managers.blackmarket:get_weapon_stats_with_mod(data[equipped].category, data[equipped].slot, data[equipped].default_mod)
					else
						data[equipped].comparision_data = managers.blackmarket:get_weapon_stats_without_mod(data[equipped].category, data[equipped].slot, data[equipped].name)
					end
				end
			end
		end
	end

	for i, mod in ipairs(data) do
		for _, weapon_mod in ipairs(weapon_blueprint) do
			if mod.name == weapon_mod and (not global_values[weapon_mod] or global_values[weapon_mod] == data[i].global_value) then
				equipped = i

				break
			end
		end
	end

	update_equipped()
end

function BlackMarketGui:set_equipped_comparision(data)
	local category = data.category
	local slot = data.slot
	self._equipped_comparision_data = {
		[category] = managers.blackmarket:get_weapon_stats(category, slot) or {}
	}
end

function BlackMarketGui:populate_buy_weapon(data)
	managers.blackmarket:clear_temporary()
	managers.blackmarket:clear_preview_blueprint()

	local new_data = {}
	local guis_catalog = "guis/"

	for i = 1, #data.on_create_data, 1 do
		local weapon_data = data.on_create_data[i]
		new_data = {
			name = weapon_data.weapon_id,
			name_localized = managers.weapon_factory:get_weapon_name_by_factory_id(weapon_data.factory_id),
			category = data.category,
			slot = data.prev_node_data and data.prev_node_data.slot
		}
		new_data.level = not new_data.unlocked and weapon_data.level
		new_data.skill_based = weapon_data.skill_based
		new_data.func_based = weapon_data.func_based
		new_data.unlocked = weapon_data.unlocked

		if _G.IS_VR then
			new_data.vr_locked = weapon_data.vr_locked
			new_data.unlocked = new_data.unlocked and not new_data.vr_locked
		end

		if weapon_data.func_based and not BlackMarketGui.get_func_based(weapon_data.func_based) then
			new_data.unlocked = false
		end

		new_data.equipped = false
		local texture_name = tweak_data.weapon[new_data.name].texture_name or tostring(new_data.name)
		local bitmap_texture, bg_texture = managers.blackmarket:get_weapon_icon_path(weapon_data.weapon_id, nil)
		new_data.bitmap_texture = bitmap_texture
		new_data.comparision_data = deep_clone(tweak_data.weapon[new_data.name].stats)
		new_data.skill_name = weapon_data.skill_based and "bm_menu_skill_locked_" .. new_data.name
		new_data.can_afford = managers.money:can_afford_weapon(new_data.name)
		new_data.price = managers.money:get_weapon_price_modified(new_data.name)
		new_data.not_moddable = true
		new_data.global_value = tweak_data.weapon[new_data.name] and tweak_data.weapon[new_data.name].global_value or "normal"
		new_data.dlc_locked = tweak_data.lootdrop.global_values[new_data.global_value].unlock_id or nil
		new_data.lock_texture = self:get_lock_icon(new_data)

		if new_data.unlocked and not new_data.can_afford then
			new_data.mid_text = {
				selected_text = managers.localization:text("bm_menu_not_enough_cash"),
				selected_color = tweak_data.screen_colors.text
			}
			new_data.mid_text.noselected_text = new_data.mid_text.selected_text
			new_data.mid_text.noselected_color = tweak_data.screen_colors.text
			new_data.mid_text.vertical = "center"
		end

		local active = true

		if new_data.unlocked then
			if new_data.can_afford and active then
				table.insert(new_data, "bw_buy")
			end
		elseif Global.dlc_manager.all_dlc_data[new_data.global_value] and Global.dlc_manager.all_dlc_data[new_data.global_value].app_id and not Global.dlc_manager.all_dlc_data[new_data.global_value].external and not managers.dlc:is_dlc_unlocked(new_data.global_value) then
			table.insert(new_data, "bw_buy_dlc")
		end

		if active then
			table.insert(new_data, "bw_preview")
		end

		table.insert(new_data, "bw_preview_mods")

		local new_weapon = managers.blackmarket:got_new_drop(data.category, "weapon_buy", new_data.name)
		local got_mods = managers.blackmarket:got_new_drop("normal", new_data.category, data.on_create_data[i].factory_id)

		if new_weapon or got_mods then
			new_data.mini_icons = new_data.mini_icons or {}

			table.insert(new_data.mini_icons, {
				texture = "guis/textures/pd2/blackmarket/inv_newdrop",
				name = "new_drop",
				h = 16,
				w = 16,
				top = 0,
				layer = 1,
				stream = false,
				right = 0
			})

			new_data.new_drop_data = {
				"normal",
				data.category,
				new_data.name
			}

			if got_mods then
				new_data.new_drop_data = {}
			end
		end

		data[i] = new_data
	end

	local max_items = self:calc_max_items(#data, data.override_slots)

	for i = 1, max_items, 1 do
		if not data[i] then
			new_data = {
				name = "empty",
				name_localized = "",
				category = data.category,
				slot = i,
				unlocked = true,
				equipped = false
			}
			data[i] = new_data
		end
	end
end

function BlackMarketGui:populate_mask_global_value(data)
	local new_data = {}

	if not managers.blackmarket:currently_customizing_mask() then
		return
	end

	local guis_catalog = "guis/"

	for i = 1, #data.on_create_data, 1 do
		new_data = {
			name = data.on_create_data[i],
			name_localized = data.on_create_data[i],
			category = data.category,
			slot = data.prev_node_data and data.prev_node_data.slot,
			unlocked = true,
			equipped = false,
			num_backs = data.prev_node_data.num_backs + 1
		}
		new_data.bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/global_value/" .. new_data.name
		new_data.stream = true

		if new_data.unlocked and #managers.blackmarket:get_inventory_masks() > 0 then
			table.insert(new_data, "em_buy")
		end

		data[i] = new_data
	end

	for i = 1, 9, 1 do
		if not data[i] then
			new_data = {
				name = "empty",
				name_localized = "",
				category = data.category,
				slot = i,
				unlocked = true,
				equipped = false
			}
			data[i] = new_data
		end
	end
end

function BlackMarketGui:populate_buy_mask(data)
	local new_data = {}
	local guis_catalog = "guis/"
	local max_masks = #data.on_create_data

	for i = 1, max_masks, 1 do
		data[i] = nil
	end

	for i = 1, #data.on_create_data, 1 do
		local guis_mask_id = data.on_create_data[i].mask_id

		if tweak_data.blackmarket.masks[guis_mask_id].guis_id then
			guis_mask_id = tweak_data.blackmarket.masks[guis_mask_id].guis_id
		end

		guis_catalog = "guis/"
		local bundle_folder = tweak_data.blackmarket.masks[guis_mask_id] and tweak_data.blackmarket.masks[guis_mask_id].texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		new_data = {
			name = data.on_create_data[i].mask_id
		}
		new_data.name_localized = managers.localization:text(tweak_data.blackmarket.masks[new_data.name].name_id)
		new_data.category = data.category
		new_data.slot = data.prev_node_data and data.prev_node_data.slot
		new_data.global_value = data.on_create_data[i].global_value
		new_data.global_value_category = data.name
		new_data.unlocked = managers.blackmarket:get_item_amount(new_data.global_value, "masks", new_data.name, true) or 0
		new_data.equipped = false
		new_data.num_backs = data.prev_node_data.num_backs + 1
		new_data.bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/masks/" .. guis_mask_id
		new_data.stream = true

		if not new_data.global_value then
			Application:debug("BlackMarketGui:populate_buy_mask( data ) Missing global value on mask", new_data.name)
		end

		if tweak_data.lootdrop.global_values[new_data.global_value] and tweak_data.lootdrop.global_values[new_data.global_value].dlc and not managers.dlc:is_dlc_unlocked(new_data.global_value) then
			new_data.unlocked = -math.abs(new_data.unlocked)
			new_data.lock_texture = self:get_lock_icon(new_data)
			new_data.dlc_locked = tweak_data.lootdrop.global_values[new_data.global_value].unlock_id or "bm_menu_dlc_locked"
		end

		if tweak_data.blackmarket.masks[new_data.name].infamy_lock then
			local infamy_lock = tweak_data.blackmarket.masks[new_data.name].infamy_lock
			local is_unlocked = managers.infamy:owned(infamy_lock)

			if not is_unlocked then
				new_data.unlocked = -math.abs(new_data.unlocked)
				new_data.lock_texture = "guis/textures/pd2/lock_infamy"
				new_data.infamy_lock = infamy_lock
			end
		end

		new_data.active = true

		if new_data.unlocked and new_data.unlocked > 0 then
			if new_data.active then
				table.insert(new_data, "bm_buy")
				table.insert(new_data, "bm_preview")
			end

			if managers.money:get_mask_sell_value(new_data.name, new_data.global_value) > 0 then
				table.insert(new_data, "bm_sell")
			end
		else
			if new_data.active then
				table.insert(new_data, "bm_preview")
			end

			new_data.mid_text = ""
			new_data.lock_texture = new_data.lock_texture or true
		end

		if managers.blackmarket:got_new_drop(new_data.global_value or "normal", "masks", new_data.name) then
			new_data.mini_icons = new_data.mini_icons or {}

			table.insert(new_data.mini_icons, {
				texture = "guis/textures/pd2/blackmarket/inv_newdrop",
				name = "new_drop",
				h = 16,
				w = 16,
				top = 0,
				layer = 1,
				stream = false,
				right = 0
			})

			new_data.new_drop_data = {
				new_data.global_value or "normal",
				"masks",
				new_data.name
			}
		end

		data[i] = new_data
	end

	local max_items = self:calc_max_items(max_masks, data.override_slots)

	for i = 1, max_items, 1 do
		if not data[i] then
			new_data = {
				name = "empty",
				name_localized = "",
				category = data.category,
				slot = i,
				unlocked = true,
				equipped = false
			}
			data[i] = new_data
		end
	end
end

function BlackMarketGui:populate_mask_mod_types(data)
	local new_data = {}
	local max_page = data.override_slots[1] * data.override_slots[2]

	for i = 1, max_page, 1 do
		data[i] = nil
	end

	local all_mods_by_type = {}
	local full_customization = true

	for type, mods in pairs(data.on_create_data) do
		all_mods_by_type[type] = mods
		full_customization = full_customization and (type == "materials" or mods and #mods > 0)
	end

	local mask_blueprint = managers.blackmarket:info_customize_mask()
	local mask_true_blueprint = managers.blackmarket:get_customized_mask_blueprint()
	local name_converter = {
		colors = "color",
		materials = "material",
		textures = "pattern"
	}
	local guis_catalog = "guis/"
	local index = 1

	for type, mods in pairs(data.on_create_data) do
		new_data = {
			name = type,
			name_localized = managers.localization:text("bm_menu_" .. tostring(type)),
			category = type,
			slot = data.prev_node_data and data.prev_node_data.slot,
			unlocked = type == "materials" or type == "textures" or #mods > 0,
			equipped = false,
			mods = mods,
			equipped_text = managers.localization:text("bm_menu_chosen"),
			all_mods_by_type = all_mods_by_type,
			my_part_data = nil,
			my_true_part_data = mask_true_blueprint[name_converter[type]]
		}

		for i, data in ipairs(mask_blueprint) do
			if data.name == type then
				new_data.my_part_data = data

				break
			end
		end

		new_data.stream = type ~= "colors"

		if not new_data.my_part_data.is_good then
			table.insert(new_data, "mm_preview")
		elseif type == "colors" then
			new_data.bitmap_texture = "guis/textures/pd2/blackmarket/icons/colors/color_bg"
			new_data.extra_bitmaps = {}

			table.insert(new_data.extra_bitmaps, "guis/textures/pd2/blackmarket/icons/colors/color_02")
			table.insert(new_data.extra_bitmaps, "guis/textures/pd2/blackmarket/icons/colors/color_01")

			new_data.extra_bitmaps_colors = {}

			table.insert(new_data.extra_bitmaps_colors, tweak_data.blackmarket.colors[new_data.my_part_data.id].colors[2])
			table.insert(new_data.extra_bitmaps_colors, tweak_data.blackmarket.colors[new_data.my_part_data.id].colors[1])
		elseif type == "textures" then
			new_data.bitmap_texture = tweak_data.blackmarket.textures[new_data.my_part_data.id].texture
			new_data.render_template = Idstring("VertexColorTexturedPatterns")
		else
			new_data.bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/materials/" .. new_data.my_part_data.id
		end

		new_data.unique_slot_class = "BlackMarketGuiMaskSlotItem"
		new_data.btn_text_params = {
			type = managers.localization:text("bm_menu_" .. tostring(type))
		}

		if managers.menu:is_pc_controller() then
			table.insert(new_data, "mm_choose_materials")
			table.insert(new_data, "mm_choose_textures")

			if data.on_create_data.colors and #data.on_create_data.colors > 0 then
				table.insert(new_data, "mm_choose_colors")
			end
		elseif new_data.unlocked then
			table.insert(new_data, "mm_choose_" .. tostring(type))
		end

		if not new_data.unlocked or new_data.unlocked == 0 then
			new_data.mid_text = {
				selected_text = managers.localization:text("bm_menu_no_items"),
				selected_color = tweak_data.screen_colors.text
			}
			new_data.mid_text.noselected_text = new_data.mid_text.selected_text
			new_data.mid_text.noselected_color = tweak_data.screen_colors.text
			new_data.mid_text.vertical = "center"
		end

		if managers.menu:is_pc_controller() then
			new_data.double_click_btn = "mm_choose_" .. tostring(type)
		end

		table.insert(new_data, "mm_preview")

		if managers.blackmarket:can_finish_customize_mask() and managers.blackmarket:can_afford_customize_mask() then
			table.insert(new_data, "mm_buy")
		end

		if managers.blackmarket:got_new_drop(nil, new_data.category, nil) then
			new_data.mini_icons = new_data.mini_icons or {}

			table.insert(new_data.mini_icons, {
				texture = "guis/textures/pd2/blackmarket/inv_newdrop",
				name = "new_drop",
				h = 16,
				w = 16,
				top = 0,
				layer = 1,
				stream = false,
				right = 0
			})

			new_data.new_drop_data = {}
		end

		data[index] = new_data
		index = index + 1
	end

	local name_values = {
		colors = 3,
		materials = 1,
		textures = 2
	}

	table.sort(data, function (x, y)
		return name_values[x.name] < name_values[y.name]
	end)

	for i = 1, max_page, 1 do
		if not data[i] then
			new_data = {
				name = "empty",
				name_localized = "",
				category = data.category,
				slot = i,
				unlocked = true,
				equipped = false
			}
			data[i] = new_data
		end
	end
end

function BlackMarketGui:populate_choose_mask_mod(data)
	local new_data = {}
	local index = 1
	local equipped_mod = managers.blackmarket:customize_mask_category_id(data.category)
	local num_data = #data

	for i = 1, num_data, 1 do
		data[i] = nil
	end

	local type_func = type
	local guis_catalog = "guis/"

	for type, mods in pairs(data.on_create_data) do
		guis_catalog = "guis/"
		local bundle_folder = tweak_data.blackmarket[data.category][mods.id] and tweak_data.blackmarket[data.category][mods.id].texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		new_data = {
			name = mods.id
		}
		new_data.name_localized = managers.localization:text(tweak_data.blackmarket[data.category][new_data.name].name_id)
		new_data.category = data.category
		new_data.slot = index
		new_data.prev_slot = data.prev_node_data and data.prev_node_data.slot
		new_data.unlocked = mods.default or mods.amount
		new_data.equipped = equipped_mod == mods.id
		new_data.equipped_text = managers.localization:text("bm_menu_chosen")
		new_data.mods = mods
		new_data.stream = data.category ~= "colors"
		new_data.global_value = mods.global_value
		local is_locked = false

		if new_data.unlocked and type_func(new_data.unlocked) == "number" and tweak_data.lootdrop.global_values[new_data.global_value] and tweak_data.lootdrop.global_values[new_data.global_value].dlc and not managers.dlc:is_dlc_unlocked(new_data.global_value) then
			new_data.unlocked = -math.abs(new_data.unlocked)
			new_data.lock_texture = self:get_lock_icon(new_data)
			new_data.dlc_locked = tweak_data.lootdrop.global_values[new_data.global_value].unlock_id or "bm_menu_dlc_locked"
			is_locked = true
		end

		local active = true

		if data.category == "colors" then
			new_data.bitmap_texture = "guis/textures/pd2/blackmarket/icons/colors/color_bg"
			new_data.extra_bitmaps = {}

			table.insert(new_data.extra_bitmaps, "guis/textures/pd2/blackmarket/icons/colors/color_02")
			table.insert(new_data.extra_bitmaps, "guis/textures/pd2/blackmarket/icons/colors/color_01")

			new_data.extra_bitmaps_colors = {}

			table.insert(new_data.extra_bitmaps_colors, tweak_data.blackmarket.colors[new_data.name].colors[2])
			table.insert(new_data.extra_bitmaps_colors, tweak_data.blackmarket.colors[new_data.name].colors[1])
		elseif data.category == "textures" then
			new_data.bitmap_texture = tweak_data.blackmarket[data.category][mods.id].texture
			new_data.render_template = Idstring("VertexColorTexturedPatterns")
		else
			new_data.bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/" .. tostring(data.category) .. "/" .. new_data.name
		end

		if managers.blackmarket:got_new_drop(new_data.global_value or "normal", new_data.category, new_data.name) then
			new_data.mini_icons = new_data.mini_icons or {}

			table.insert(new_data.mini_icons, {
				texture = "guis/textures/pd2/blackmarket/inv_newdrop",
				name = "new_drop",
				h = 16,
				w = 16,
				top = 0,
				layer = 1,
				stream = false,
				right = 0
			})

			new_data.new_drop_data = {
				new_data.global_value or "normal",
				new_data.category,
				new_data.name
			}
		end

		new_data.btn_text_params = {
			type = managers.localization:text("bm_menu_" .. data.category)
		}

		if not is_locked and active then
			table.insert(new_data, "mp_choose")
			table.insert(new_data, "mp_preview")
		end

		if managers.blackmarket:can_finish_customize_mask() and managers.blackmarket:can_afford_customize_mask() then
			table.insert(new_data, "mm_buy")
		end

		data[index] = new_data
		index = index + 1
	end

	if #data == 0 then
		new_data = {
			name = "bm_menu_nothing",
			empty_slot = true,
			category = data.category,
			slot = 1,
			unlocked = true,
			can_afford = true,
			equipped = false
		}

		table.insert(new_data, "mm_preview")

		data[1] = new_data
	end

	local max_mask_mods = #data.on_create_data

	for i = 1, math.ceil(max_mask_mods / data.override_slots[1]) * data.override_slots[1], 1 do
		if not data[i] then
			new_data = {
				name = "empty",
				name_localized = "",
				category = data.category,
				slot = i,
				unlocked = true,
				equipped = false
			}
			data[i] = new_data
		end
	end
end

function BlackMarketGui:_cleanup_blackmarket()
	local blackmarket_tweak_data = tweak_data.blackmarket
	local blackmarket_inventory = Global.blackmarket_manager.inventory

	for global_value, gv_table in pairs(blackmarket_inventory) do
		for type_id, type_table in pairs(gv_table) do
			if type_id ~= "weapon_mods" then
				local item_data = blackmarket_tweak_data[type_id]

				if item_data then
					for item_id, item_amount in pairs(type_table) do
						if not item_data[item_id] then
							print("BlackMarketGui:_cleanup_blackmarket: Missing '" .. item_id .. "' in BlackMarketTweakData. Removing it from stash!")

							type_table[item_id] = nil
						end
					end
				end
			end
		end
	end
end

function BlackMarketGui:create_steam_inventory(data)
	local inventory_categories = managers.blackmarket:get_inventory_tradable_by_category()
	local sort_categories = {}

	for category, instance_ids in pairs(inventory_categories) do
		table.insert(sort_categories, category)
	end

	table.sort(sort_categories)

	for i = #data, 1, -1 do
		data[i] = nil
	end

	table.insert(data, {
		name = "bm_menu_inventory_tradable_all",
		on_create_func_name = "populate_inventory_tradable",
		category = "all",
		override_slots = {
			5,
			3
		},
		identifier = self.identifiers.inventory_tradable
	})

	for _, category in ipairs(sort_categories) do
		table.insert(data, {
			on_create_func_name = "populate_inventory_tradable",
			name = "bm_menu_inventory_tradable_" .. category,
			category = category,
			override_slots = {
				5,
				3
			},
			identifier = self.identifiers.inventory_tradable
		})
	end

	local node_parameters = self._node and self._node:parameters()

	if node_parameters and node_parameters.menu_component_selected and node_parameters.menu_component_selected > #data then
		node_parameters.menu_component_selected = #data
	end

	if managers.menu_component:blackmarket_fetching_disable() then
		return
	end

	local new_givens = managers.blackmarket:fetch_new_tradable_items() or {}
	local params = {
		sound_event = "stinger_new_weapon"
	}
	local ti_td = nil
	local max_items_to_show = 10
	local inventory_tradable = managers.blackmarket:get_inventory_tradable()
	local index = 0

	for i, instance_id in ipairs(new_givens) do
		if max_items_to_show <= index and index < #new_givens then
			params.amount_more = #new_givens - (index - 1)

			managers.menu:show_and_more_tradable_item_received(params)

			break
		elseif inventory_tradable[instance_id] then
			index = index + 1
			params.instance_id = instance_id
			params.item = inventory_tradable[instance_id]
			params.amount_more = #new_givens - (index - 1)

			if params.item.category == "weapon_skins" then
				ti_td = tweak_data:get_raw_value("blackmarket", params.item.category, params.item.entry)
			else
				ti_td = tweak_data:get_raw_value("economy", params.item.category, params.item.entry)
			end

			if ti_td then
				params.item_name = managers.localization:text(ti_td.name_id)
				params.rarity_name = managers.localization:text(tweak_data.economy.rarities[ti_td.rarity or "common"] and tweak_data.economy.rarities[ti_td.rarity or "common"].name_id or "nil")
				params.quality_name = managers.localization:text(tweak_data.economy.qualities[params.item.quality or "poor"] and tweak_data.economy.qualities[params.item.quality or "poor"].name_id or "nil")
				params.container = params.item.category == "safes" and {
					content = tweak_data.economy.safes[params.item.entry] and tweak_data.economy.safes[params.item.entry].content,
					drill = ti_td.drill,
					safe = params.item.entry,
					safe_id = params.item.instance_id
				}

				managers.menu:show_new_tradable_item_received(params)
			end
		end
	end
end

function BlackMarketGui:_start_page_data()
	local data = {
		topic_id = "menu_steam_inventory",
		init_callback_name = "create_steam_inventory",
		init_callback_params = data,
		allow_tradable_reload = true,
		create_steam_inventory_extra = true,
		add_market_panel = true
	}
	managers.network.account.do_convert_drills = true

	managers.network.account:inventory_load()

	return data
end

function BlackMarketGui:populate_inventory_tradable(data)
	local inventory_tradable = managers.blackmarket:get_inventory_tradable()
	local sort_func = tweak_data.gui:tradable_inventory_sort_func(Global.blackmarket_manager.tradable_inventory_sort)
	local instance_data = nil
	local inventory_categories = managers.blackmarket:get_inventory_tradable_by_category() or {}
	data.on_create_data = {}

	if data.category == "all" then
		for category, instance_ids in pairs(inventory_categories or {}) do
			for _, instance_id in ipairs(instance_ids) do
				instance_data = inventory_tradable[instance_id]
				local item_tweak = tweak_data.economy[instance_data.category] or tweak_data.blackmarket[instance_data.category]

				if item_tweak and item_tweak[instance_data.entry] then
					table.insert(data.on_create_data, instance_id)
				end
			end
		end
	else
		for _, instance_id in ipairs(inventory_categories[data.category]) do
			instance_data = inventory_tradable[instance_id]
			local item_tweak = tweak_data.economy[instance_data.category] or tweak_data.blackmarket[instance_data.category]

			if item_tweak and item_tweak[instance_data.entry] then
				table.insert(data.on_create_data, instance_id)
			end
		end
	end

	if sort_func then
		table.sort(data.on_create_data, sort_func)
	end

	local num_items = #data

	for i = 1, num_items, 1 do
		data[i] = nil
	end

	local bitmap_texture, bg_texture, new_data, td = nil

	for index, instance_id in ipairs(data.on_create_data) do
		instance_data = inventory_tradable[instance_id]

		if instance_data then
			new_data = {
				name = instance_data.entry,
				category = instance_data.category,
				amount = instance_data.amount,
				instance_id = instance_id
			}

			if new_data.amount and new_data.amount > 1 then
				new_data.corner_text = {
					selected_text = "x" .. tostring(new_data.amount),
					selected_color = tweak_data.screen_colors.text,
					noselected_text = "x" .. tostring(new_data.amount),
					noselected_color = tweak_data.screen_colors.text,
					font = small_font,
					font_size = small_font_size
				}
			end

			if instance_data.category == "weapon_skins" then
				td = tweak_data.blackmarket.weapon_skins[instance_data.entry]

				if td then
					new_data.weapon_id = managers.blackmarket:get_weapon_id_by_cosmetic_id(instance_data.entry)
					new_data.name_localized = managers.localization:text(td.name_id)
					new_data.desc_id = td.desc_id
					bitmap_texture, bg_texture = managers.blackmarket:get_weapon_icon_path(new_data.weapon_id, {
						id = instance_data.entry
					})
					new_data.bitmap_texture = bitmap_texture
					new_data.bg_texture = bg_texture
					new_data.cosmetic_id = new_data.name
					new_data.cosmetic_quality = instance_data.quality
					new_data.cosmetic_rarity = td.rarity or "common"
					new_data.cosmetic_bonus = instance_data.bonus
					new_data.default_blueprint = td.default_blueprint

					if not td.promo then
						table.insert(new_data, "it_sell")
					end

					table.insert(new_data, "it_wcc_preview")

					if new_data.cosmetic_bonus then
						local bonuses = tweak_data.economy:get_bonus_icons(td.bonus)
						local x = 0

						for _, texture_path in ipairs(bonuses) do
							new_data.mini_icons = new_data.mini_icons or {}

							table.insert(new_data.mini_icons, {
								name = "has_bonus",
								h = 16,
								layer = 1,
								w = 16,
								stream = false,
								bottom = 0,
								texture = texture_path,
								right = x
							})

							x = x + 17
						end
					end
				end
			else
				td = tweak_data.economy[instance_data.category] and tweak_data.economy[instance_data.category][instance_data.entry]

				if td then
					local guis_catalog = "guis/"
					local bundle_folder = td.texture_bundle_folder

					if bundle_folder then
						guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
					end

					local path = instance_data.category .. "/"
					new_data.bitmap_texture = guis_catalog .. path .. instance_data.entry
					new_data.name_localized = managers.localization:text(td.name_id)
					new_data.desc_id = td.desc_id
					new_data.safe_entry = new_data.category == "safes" and instance_data.entry

					if td.content or td.safe then
						new_data.container = {
							content = td.content or tweak_data.economy.safes[td.safe] and tweak_data.economy.safes[td.safe].content,
							drill = td.drill or instance_data.entry,
							safe = td.safe or instance_data.entry,
							safe_id = td.drill and instance_id,
							drill_id = td.safe and instance_id
						}

						table.insert(new_data, "it_copen")
					else
						new_data.cosmetic_rarity = td.rarity or "common"
						new_data.bg_texture = managers.blackmarket:get_cosmetic_rarity_bg(td.rarity or "common")

						if not td.promo then
							-- Nothing
						end
					end
				end
			end

			new_data.slot = index
			new_data.unlocked = true
			new_data.equipped = false
			new_data.stream = true
			data[index] = new_data
		end
	end

	local new_data = nil

	for i = 1, math.ceil(math.max(#data.on_create_data / 5, 3)) * 5, 1 do
		if not data[i] then
			new_data = {
				name = "empty",
				name_localized = "",
				category = data.category,
				slot = i,
				unlocked = true,
				equipped = false
			}
			data[i] = new_data
		end
	end
end

function BlackMarketGui:preview_weapon_mods_callback(data)
	managers.blackmarket:craft_temporary(data.category, data.name, data.slot)
	self:choose_weapon_mods_callback(data)
end

function BlackMarketGui:choose_weapon_mods_callback(data)
	local dropable_mods = managers.blackmarket:get_dropable_mods_by_weapon_id(data.name, {
		category = data.category,
		slot = data.slot
	})
	local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(data.name)
	local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)
	local new_node_data = {}
	local cosmetic_instances = managers.blackmarket:get_cosmetics_instances_by_weapon_id(data.name)
	local all_cosmetics = managers.blackmarket:get_cosmetics_by_weapon_id(data.name)

	if table.size(all_cosmetics) > 0 then
		local inventory_tradable = managers.blackmarket:get_inventory_tradable()
		local td = tweak_data.blackmarket.weapon_skins
		local rtd = tweak_data.economy.rarities
		local x_td, y_td, x_rar, y_rar, x_quality, y_quality, weapon_skin_id = nil

		local function sort_func_instances(x, y)
			x_td = td[inventory_tradable[x].entry]
			y_td = td[inventory_tradable[y].entry]
			x_rar = rtd[x_td.rarity]
			y_rar = rtd[y_td.rarity]

			if x_rar.index ~= y_rar.index then
				return x_rar.index < y_rar.index
			end

			if inventory_tradable[x].entry ~= inventory_tradable[y].entry then
				return inventory_tradable[y].entry < inventory_tradable[x].entry
			end

			x_quality = tweak_data.economy.qualities[inventory_tradable[x].quality]
			y_quality = tweak_data.economy.qualities[inventory_tradable[y].quality]

			if x_quality.index ~= y_quality.index then
				return y_quality.index < x_quality.index
			end

			return y < x
		end

		local function sort_func_cosmetics(x, y)
			x_td = td[x.id]
			x_rar = rtd[x_td.rarity or "common"]
			y_td = td[y.id]
			y_rar = rtd[y_td.rarity or "common"]

			if x_rar.index ~= y_rar.index then
				return y_rar.index < x_rar.index
			end

			return y.id < x.id
		end

		table.sort(cosmetic_instances, sort_func_instances)

		for _, instance_id in ipairs(cosmetic_instances) do
			weapon_skin_id = inventory_tradable[instance_id].entry
			all_cosmetics[weapon_skin_id] = nil
		end

		local all_cosmetics_sorted = {}

		for id, data in pairs(all_cosmetics) do
			if not data.is_a_color_skin then
				table.insert(all_cosmetics_sorted, {
					id = id,
					data = data
				})
			end
		end

		table.sort(all_cosmetics_sorted, sort_func_cosmetics)
		table.insert(new_node_data, {
			name = "weapon_cosmetics",
			on_create_func_name = "populate_weapon_cosmetics",
			name_localized = managers.localization:text("bm_menu_weapon_cosmetics"),
			category = data.category,
			prev_node_data = data,
			on_create_data = {
				instances = cosmetic_instances,
				cosmetics = all_cosmetics_sorted
			},
			override_slots = WEAPON_MODS_SLOTS,
			identifier = BlackMarketGui.identifiers.weapon_cosmetic
		})
	end

	local mods = {}

	for i, d in pairs(dropable_mods) do
		mods[i] = d
	end

	local sort_mods = {}

	for id, _ in pairs(mods) do
		table.insert(sort_mods, id)
	end

	table.sort(sort_mods, function (x, y)
		return x < y
	end)

	for i, id in ipairs(sort_mods) do
		local my_mods = deep_clone(mods[id])
		local crafted = managers.blackmarket:get_crafted_category(data.category)[data.slot]
		local factory_id = crafted.factory_id
		local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)
		local default_mod = nil
		local ids_id = Idstring(id)

		for i, d_mod in ipairs(default_blueprint) do
			if Idstring(tweak_data.weapon.factory.parts[d_mod].type) == ids_id then
				default_mod = d_mod

				break
			end
		end

		local sort_td = tweak_data.blackmarket.weapon_mods
		local x_td, y_td, x_pc, y_pc = nil

		table.sort(my_mods, function (x, y)
			x_td = sort_td[x[1]]
			y_td = sort_td[y[1]]
			x_pc = x_td.value or x_td.pc or x_td.pcs and x_td.pcs[1] or 10
			y_pc = y_td.value or y_td.pc or y_td.pcs and y_td.pcs[1] or 10
			x_pc = x_pc + (x[2] and tweak_data.lootdrop.global_values[x[2]].sort_number or 0)
			y_pc = y_pc + (y[2] and tweak_data.lootdrop.global_values[y[2]].sort_number or 0)

			return x_pc < y_pc or x_pc == y_pc and x[1] < y[1]
		end)

		local mod_data = {}

		for a = 1, #my_mods, 1 do
			table.insert(mod_data, {
				my_mods[a][1],
				false,
				my_mods[a][2]
			})
		end

		mod_data.default_mod = default_mod

		table.insert(new_node_data, {
			on_create_func_name = "populate_mods",
			name = id,
			category = data.category,
			prev_node_data = data,
			name_localized = managers.localization:text("bm_menu_" .. id),
			on_create_data = mod_data,
			override_slots = WEAPON_MODS_SLOTS,
			identifier = BlackMarketGui.identifiers.weapon_mod
		})
	end

	new_node_data.topic_id = "bm_menu_blackmarket_title"
	new_node_data.topic_params = {
		item = data.name_localized
	}
	new_node_data.selected_tab = data.selected_tab
	new_node_data.prev_node_data = data
	new_node_data.show_tabs = true
	new_node_data.panel_grid_h_mul = WEAPON_MODS_GRID_H_MUL
	new_node_data.panel_grid_top_padding = 1 - new_node_data.panel_grid_h_mul
	new_node_data.skip_blur = true
	new_node_data.use_bgs = true

	if type(new_node_data.selected_tab) == "string" then
		for i, data in ipairs(new_node_data) do
			if data.name == new_node_data.selected_tab then
				new_node_data.selected_tab = i

				break
			end
		end
	end

	new_node_data.open_callback_name = "set_equipped_comparision"
	new_node_data.open_callback_params = {
		category = data.category,
		slot = data.slot
	}
	new_node_data.blur_fade = self._data and self._data.blur_fade
	local open_node = data.open_node or self._inception_node_name or "blackmarket_node"

	self:_start_crafting_weapon(data, new_node_data)
end

function BlackMarketGui:edit_weapon_skin_callback(data)
	local function cb()
		managers.menu:open_node("skin_editor", {
			data
		})
	end

	managers.workshop:_init_items()
	managers.blackmarket:skin_editor():init_items()
	managers.blackmarket:view_weapon(data.category, data.slot, cb, true, BlackMarketGui.get_crafting_custom_data())
end

function BlackMarketGui:choose_mod_type_callback(data)
	local mods = managers.blackmarket:get_dropable_mods_by_weapon_id(data.name)
	local new_node_data = {}
	local mods_list = {}

	for id, data in pairs(mods) do
		table.insert(mods_list, id)
	end

	local mod_data = {}

	for i = 1, math.max(1, math.ceil(#mods_list / 9)), 1 do
		mod_data = {}

		for id = (i - 1) * 9 + 1, math.min(i * 9, #mods_list), 1 do
			mod_data[mods_list[id]] = mods[mods_list[id]]
		end

		table.insert(new_node_data, {
			on_create_func_name = "populate_mod_types",
			name = tostring(i),
			category = data.category,
			prev_node_data = data,
			name_localized = tostring(i),
			on_create_data = mod_data,
			identifier = self.identifiers.weapon_mod
		})
	end

	new_node_data.topic_id = "bm_menu_blackmarket_title"
	new_node_data.topic_params = {
		item = data.name_localized
	}
	new_node_data.blur_fade = self._data.blur_fade

	managers.menu:open_node(self._inception_node_name, {
		new_node_data
	})
end

function BlackMarketGui:set_preferred_character_callback(data)
	managers.blackmarket:set_preferred_character(data.name)
	self:reload()
end

function BlackMarketGui:extra_option_key_press(panel, s)
	if not self._extra_options_data then
		return
	end

	local slot = nil

	if s == Idstring("1") then
		slot = 1
	elseif s == Idstring("2") then
		slot = 2
	elseif s == Idstring("3") then
		slot = 3
	elseif s == Idstring("4") then
		slot = 4
	end

	if slot and self._slot_data and slot <= (self._extra_options_data.num_panels or 0) then
		local character = self._slot_data.name
		local index = nil

		for _, preferred_character in ipairs(managers.blackmarket:get_preferred_characters_list()) do
			if preferred_character == character then
				index = _

				break
			end
		end

		local reload = false

		if index then
			if index ~= slot and slot ~= self._extra_options_data.num_panels then
				managers.blackmarket:swap_preferred_character(index, slot)

				reload = true
			end
		else
			managers.blackmarket:set_preferred_character(character, slot)

			reload = true
		end

		if reload then
			self:reload()
		end
	end
end

function BlackMarketGui:can_swap_character(data)
	local index = nil
	local preferred_characters = managers.blackmarket:get_preferred_characters_list()

	for _, preferred_character in ipairs(preferred_characters) do
		if preferred_character == data.name then
			index = _

			break
		end
	end

	local selected = self._extra_options_data and self._extra_options_data.selected or 1

	return index and self._extra_options_data and (#preferred_characters == CriminalsManager.MAX_NR_CRIMINALS or selected ~= self._extra_options_data.num_panels)
end

function BlackMarketGui:swap_preferred_character_to_slot_callback(data)
	local index = nil
	local preferred_characters = managers.blackmarket:get_preferred_characters_list()

	for _, preferred_character in ipairs(preferred_characters) do
		if preferred_character == data.name then
			index = _

			break
		end
	end

	local selected = self._extra_options_data.selected or 1

	if index and self._extra_options_data and index ~= selected and (#preferred_characters == CriminalsManager.MAX_NR_CRIMINALS or selected ~= self._extra_options_data.num_panels) then
		managers.blackmarket:swap_preferred_character(index, selected)
		self:reload()
	end
end

function BlackMarketGui:set_preferred_character_to_slot_callback(data)
	managers.blackmarket:set_preferred_character(data.name, self._extra_options_data and self._extra_options_data.selected or 1)
	self:reload()
end

function BlackMarketGui:clear_preferred_characters_callback(data)
	managers.blackmarket:clear_preferred_characters()
	self:reload()
end

function BlackMarketGui.get_crafting_custom_data()
	return managers.menu_scene:get_crafting_custom_data()
end

function BlackMarketGui.get_screenshot_custom_data()
	return managers.menu_scene:get_screenshot_custom_data()
end

function BlackMarketGui:pickup_crafted_item_callback(data)
	managers.blackmarket:pickup_crafted_item(data.category, data.slot)
	self:reload()
end

function BlackMarketGui:place_crafted_item_callback(data)
	managers.blackmarket:place_crafted_item(data.category, data.slot)
	self:reload()
end

function BlackMarketGui:drop_hold_crafted_item_callback(data)
	managers.blackmarket:drop_hold_crafted_item()
	self:reload()
end

function BlackMarketGui:rename_item_with_gamepad_callback(data)
	print("[BlackMarketGui:rename_item_with_gamepad_callback]", inspect(data))

	if is_win32 then
		local desc = managers.localization:text("menu_bm_rename_text_input_desc", {
			item = utf8.to_upper(data.name_localized),
			slot = data.slot,
			category = managers.localization:to_upper_text("bm_menu_" .. data.category)
		})
		local custom_name = managers.blackmarket:get_crafted_custom_name(data.category, data.slot) or ""
		local id = Idstring("BlackMarketGui:rename_item_with_gamepad_callback")
		local key = id:key()
		local params = {
			[3] = desc,
			[4] = tweak_data:get_raw_value("gui", "rename_max_letters") or 20,
			[5] = custom_name
		}

		if managers.network.account:show_gamepad_text_input(key, callback(self, self, "_rename_gamepad_callback"), params) then
			self._renaming_item = {
				category = data.category,
				slot = data.slot,
				custom_name = custom_name
			}
			self._rename_clbk_id = key
		elseif MenuCallbackHandler:is_overlay_enabled() then
			managers.menu:show_requires_big_picture()
		else
			managers.menu:show_enable_steam_overlay()
		end
	end
end

function BlackMarketGui:_rename_gamepad_callback(submitted, submitted_text)
	print("BlackMarketGui:_rename_gamepad_callback", "submitted", submitted, "submitted_text", submitted_text)

	self._rename_clbk_id = nil

	if not submitted then
		self:_cancel_rename_item()
	elseif self._renaming_item then
		self._renaming_item.custom_name = submitted_text

		self:_stop_rename_item()
	end
end

function BlackMarketGui:equip_weapon_callback(data)
	if managers.job and managers.job:current_real_job_id() == "chill" and (not managers.menu:active_menu() or managers.menu:active_menu().id ~= "kit_menu") then
		managers.custom_safehouse:register_equipped_weapon(data)
		managers.blackmarket:equip_weapon(data.category, data.slot, true)
		self:reload()
	else
		managers.blackmarket:equip_weapon(data.category, data.slot)
		self:reload()
	end
end

function BlackMarketGui:overridable_callback(original, data)
	local func = self._data.custom_callback and self._data.custom_callback[original.button] or data.custom_callback and data.custom_callback[original.button]

	if func then
		func(data, self)
	else
		original.callback(data)
	end
end

function BlackMarketGui:equip_armor_callback(data)
	managers.blackmarket:equip_armor(data.name)
	managers.blackmarket:release_preloaded_category("armor_skin")
	self:reload()
end

function BlackMarketGui:open_armor_skins_menu_callback(data)
	local new_node_data = {}

	table.insert(new_node_data, {
		name = "bm_menu_armor_skins",
		on_create_func_name = "populate_armor_skins",
		category = "armor_skins",
		override_slots = {
			3,
			3
		},
		identifier = BlackMarketGui.identifiers.armor_skins
	})

	new_node_data.topic_id = "bm_menu_armor_skins"
	new_node_data.panel_grid_w_mul = 0.6
	new_node_data.skip_blur = true
	new_node_data.use_bgs = true
	new_node_data.hide_detection_panel = true

	managers.menu:open_node("blackmarket_outfit_customize_node", {
		new_node_data
	})
	self:_preview_player_style("none", "default")
	managers.blackmarket:release_preloaded_category("player_style")
end

function BlackMarketGui:equip_armor_skin_callback(data)
	managers.blackmarket:set_equipped_armor_skin(data.name)
	self:reload()
end

function BlackMarketGui:preview_armor_skin_callback(data)
	local skin = tweak_data.economy:get_armor_skin_id(data.name)

	managers.blackmarket:view_armor_skin(skin, callback(self, self, "reload"))
end

function BlackMarketGui:edit_armor_skin_callback(data)
	managers.workshop:_init_items()
	managers.blackmarket:armor_skin_editor():init_items()
	managers.menu:open_node(ArmorSkinEditor.menu_node_name, {
		data
	})
end

function BlackMarketGui:_character_preview_textures_retrieved(assets)
	self._preloading_list = {}
	assets = assets or {}
	local num_units = table.size(assets.unit)
	local num_textures = table.size(assets.texture)

	for i = 1, num_units + num_textures, 1 do
		table.insert(self._preloading_list, i)
	end
end

function BlackMarketGui:_character_preview_texture_loaded(asset_type, asset_name)
	table.remove(self._preloading_list, 1)
end

function MenuCallbackHandler:_reset_character_armor_skin()
	local henchmen_player_override = managers.menu_scene:henchmen_player_override()

	if henchmen_player_override then
		managers.menu_scene:set_character_armor("level_1")
		managers.menu_scene:set_character_armor_skin(nil)

		return
	end

	managers.menu_scene:set_character_armor(managers.blackmarket:equipped_armor())
	managers.menu_scene:set_character_armor_skin(managers.blackmarket:equipped_armor_skin())
end

function MenuCallbackHandler:reset_character_outfit()
	local henchmen_player_override = managers.menu_scene:henchmen_player_override()

	if henchmen_player_override then
		local loadout = managers.blackmarket:henchman_loadout(henchmen_player_override)

		managers.menu_scene:set_character_armor("level_1")
		managers.menu_scene:set_character_armor_skin(nil)
		managers.blackmarket:release_preloaded_category("armor_skin")
		managers.menu_scene:set_character_player_style(loadout.player_style, loadout.suit_variation)
		managers.blackmarket:release_preloaded_category("player_style")

		return
	end

	managers.menu_scene:set_character_armor(managers.blackmarket:equipped_armor())
	managers.menu_scene:set_character_armor_skin(managers.blackmarket:equipped_armor_skin())
	managers.blackmarket:release_preloaded_category("armor_skin")
	managers.menu_scene:set_character_player_style(managers.blackmarket:equipped_player_style(), managers.blackmarket:get_suit_variation())
	managers.blackmarket:release_preloaded_category("player_style")
end

function BlackMarketGui:equip_mask_callback(data)
	managers.blackmarket:equip_mask(data.slot)
	self:reload()
end

function BlackMarketGui:open_inventory_list_node()
	managers.menu:open_node("inventory_list_node", {})
end

function BlackMarketGui:_open_preview_node()
	managers.menu:open_node(self._preview_node_name, {})
end

function BlackMarketGui:_open_crafting_node(data)
	managers.menu:open_node(self._crafting_node_name, data)
end

function BlackMarketGui:_open_preview_weapon_cosmetics_node()
	managers.menu:open_node("inventory_tradable_container_preview_node", {
		{
			id = self._slot_data.cosmetic_id,
			quality = self._slot_data.cosmetic_quality,
			bonus = self._slot_data.cosmetic_bonus,
			color_index = self._slot_data.cosmetic_color_index
		}
	})
	managers.menu_component:hide_blackmarket_gui()
end

function BlackMarketGui:_update_crafting_node(data)
end

function BlackMarketGui:_preview_weapon(data)
	managers.blackmarket:view_weapon(data.category, data.slot, callback(self, self, "_open_preview_node"))
end

function BlackMarketGui:_start_crafting_weapon(data, new_node_data)
	self:set_enabled(false)
	managers.blackmarket:view_weapon(data.category, data.slot, callback(self, self, "_open_crafting_node", {
		new_node_data
	}), true, BlackMarketGui.get_crafting_custom_data())
end

function BlackMarketGui:preview_weapon_callback(data)
	self:_preview_weapon(data)
end

function BlackMarketGui:preview_weapon_mod_callback(data)
	managers.blackmarket:view_weapon(data.category, data.slot, callback(self, self, "_update_crafting_node"), nil, BlackMarketGui.get_crafting_custom_data())
end

function BlackMarketGui:clear_weapon_mod_preview_callback(data)
	managers.blackmarket:view_weapon(data.category, data.slot, callback(self, self, "_update_crafting_node"), nil, BlackMarketGui.get_crafting_custom_data())
	managers.blackmarket:clear_preview_blueprint()
	self:reload()
end

function BlackMarketGui:start_open_tradable_container_callback(data)
	if data.category == "drills" and not managers.blackmarket:have_inventory_tradable_item("safes", data.container.safe) then
		managers.menu:show_no_safe_for_this_drill(data)
	else
		managers.menu:open_node("inventory_tradable_container", {
			data
		})
	end
end

function BlackMarketGui:choose_equip_weapon_cosmetics_callback(data)
	local weapon_id = data.weapon_id

	if not weapon_id then
		return
	end

	local selection_index = tweak_data:get_raw_value("weapon", weapon_id, "use_data", "selection_index") or 1
	local category = selection_index == 1 and "secondaries" or "primaries"

	if not category then
		return
	end

	local crafted_category = managers.blackmarket:get_crafted_category(category) or {}
	local new_node_data = {
		category = category,
		equip_weapon_cosmetics = {
			weapon_id = weapon_id,
			instance_id = data.instance_id,
			entry = data.cosmetic_id,
			category = data.category,
			bonus = data.cosmetic_bonus,
			quality = data.cosmetic_quality,
			amount = data.amount,
			color_index = data.cosmetic_color_index
		}
	}
	local rows = tweak_data.gui.WEAPON_ROWS_PER_PAGE or 3
	local columns = tweak_data.gui.WEAPON_COLUMNS_PER_PAGE or 3
	local max_pages = tweak_data.gui.MAX_WEAPON_PAGES or 8
	local items_per_page = rows * columns
	local item_data, selected_tab = nil

	for page = 1, max_pages, 1 do
		local index = 1
		local start_i = 1 + items_per_page * (page - 1)
		item_data = {}

		for i = start_i, items_per_page * page, 1 do
			item_data[index] = i
			index = index + 1

			if crafted_category[i] and crafted_category[i].equipped then
				selected_tab = page
			end
		end

		local name_id = managers.localization:to_upper_text("bm_menu_page", {
			page = tostring(page)
		})

		table.insert(new_node_data, {
			prev_node_data = false,
			on_create_func_name = "populate_weapon_category_new",
			name = category,
			category = category,
			start_i = start_i,
			equip_weapon_cosmetics = new_node_data.equip_weapon_cosmetics,
			name_localized = name_id,
			on_create_data = item_data,
			identifier = BlackMarketGui.identifiers.weapon,
			override_slots = {
				columns,
				rows
			}
		})
	end

	new_node_data.can_move_over_tabs = true
	new_node_data.selected_tab = selected_tab
	new_node_data.scroll_tab_anywhere = true
	local c_td = tweak_data.blackmarket.weapon_skins[data.cosmetic_id] or {}
	local quality = managers.localization:text(tweak_data.economy.qualities[data.cosmetic_quality].name_id)
	local name = managers.localization:text(c_td.name_id)
	new_node_data.topic_id = "bm_menu_equip_weapon_cosmetics_title"
	new_node_data.topic_params = {
		cosmetics = managers.localization:text("menu_cash_safe_result", {
			quality = quality,
			name = name
		})
	}
	new_node_data.topic_color = tweak_data.economy.rarities[c_td.rarity].color

	managers.menu:open_node("blackmarket_node", {
		new_node_data
	})
end

function BlackMarketGui:sell_tradable_item(data)
	MenuCallbackHandler:steam_sell_item(data)
end

function BlackMarketGui:preview_weapon_cosmetics_callback(data)
	managers.blackmarket:view_weapon_platform_with_cosmetics(data.weapon_id, {
		id = data.cosmetic_id,
		quality = data.cosmetic_quality,
		color_index = data.cosmetic_color_index
	}, callback(self, self, "_open_preview_weapon_cosmetics_node"))
end

function BlackMarketGui:preview_cosmetic_on_weapon_callback(data)
	managers.blackmarket:view_weapon_with_cosmetics(data.category, data.slot, {
		id = data.cosmetic_id,
		quality = data.cosmetic_quality,
		color_index = data.cosmetic_color_index
	}, callback(self, self, "_update_crafting_node"), nil, BlackMarketGui.get_crafting_custom_data())
	self:reload()
end

function BlackMarketGui:cancel_preview_cosmetic_on_weapon_callback(data)
	managers.blackmarket:view_weapon(data.category, data.slot, function ()
	end, nil, BlackMarketGui.get_crafting_custom_data())
	self:reload()
end

function BlackMarketGui:purchase_market_cosmetic_on_weapon_callback(data)
	if not MenuCallbackHandler:is_overlay_enabled() then
		managers.menu:show_enable_steam_overlay_tradable_item()
	else
		local weapon = managers.blackmarket:get_crafted_category_slot(data.category, data.slot)

		Steam:overlay_activate("url", tweak_data.economy:create_weapon_skin_market_search_url(weapon.weapon_id, data.cosmetic_id))
	end
end

function BlackMarketGui:choose_weapon_cosmetics_callback(data)
	managers.menu:open_node("choose_weapon_cosmetic", {
		data
	})
end

function BlackMarketGui:remove_weapon_cosmetics_callback(data)
	if self._item_bought then
		return
	end

	self:_weapon_cosmetics_callback(data, false, callback(self, self, "_remove_weapon_cosmetics_callback", data))
end

function BlackMarketGui:buy_equip_weapon_cosmetics_callback(data)
	if self._item_bought then
		return
	end

	local params = {
		name = managers.weapon_factory:get_weapon_name_by_weapon_id(data.equip_weapon_cosmetics.weapon_id),
		category = data.category,
		slot = data.slot,
		weapon = self._data.equip_weapon_cosmetics.weapon_id,
		money = managers.experience:cash_string(managers.money:get_weapon_price_modified(data.equip_weapon_cosmetics.weapon_id)),
		yes_func = callback(self, self, "_dialog_yes", callback(self, self, "_buy_equip_weapon_cosmetics_callback", data)),
		no_func = callback(self, self, "_dialog_no")
	}

	managers.menu:show_confirm_blackmarket_buy(params)
end

function BlackMarketGui:_buy_equip_weapon_cosmetics_callback(data)
	managers.blackmarket:on_buy_weapon_platform(data.category, data.equip_weapon_cosmetics.weapon_id, data.slot)
	self:_equip_weapon_cosmetics_callback(data)
end

function BlackMarketGui:equip_weapon_cosmetics_callback(data)
	if self._item_bought then
		return
	end

	self:_weapon_cosmetics_callback(data, true, callback(self, self, "_equip_weapon_cosmetics_callback", data))
end

function BlackMarketGui:equip_weapon_color_callback(data)
	if self._item_bought then
		return
	end

	self:_weapon_cosmetics_callback(data, true, callback(self, self, "_equip_weapon_color_callback", data))
end

function BlackMarketGui:_equip_weapon_color_callback(data)
	self._item_bought = true
	local instance_id = data.name

	if data.equip_weapon_cosmetics then
		instance_id = data.equip_weapon_cosmetics.instance_id
	end

	managers.menu_component:post_event("item_buy")
	managers.blackmarket:on_equip_weapon_color(data.category, data.slot, instance_id, data.cosmetic_color_index, data.cosmetic_quality or "mint", true)
	self:reload()
end

function BlackMarketGui:_weapon_cosmetics_callback(data, add, yes_clbk)
	local cosmetic_id = data.equip_weapon_cosmetics and data.equip_weapon_cosmetics.entry
	local cosmetic_name_id = cosmetic_id and tweak_data.blackmarket.weapon_skins[cosmetic_id].name_id
	local name_localized = cosmetic_name_id and managers.localization:text(cosmetic_name_id) or data.name_localized or data.name
	local crafted = managers.blackmarket:get_crafted_category(data.category)[data.slot]
	local crafted_cosmetic_id = crafted.cosmetics and crafted.cosmetics.id
	local crafted_default_blueprint = crafted.default_blueprint
	local crafted_has_cosmetic = not not crafted_cosmetic_id
	local crafted_has_default_blueprint = crafted_cosmetic_id and tweak_data.blackmarket.weapon_skins[crafted_cosmetic_id] and not not tweak_data.blackmarket.weapon_skins[crafted_cosmetic_id].default_blueprint
	local item_has_cosmetic = add
	local item_has_default_blueprint = add and tweak_data.blackmarket.weapon_skins[cosmetic_id or data.cosmetic_id] and tweak_data.blackmarket.weapon_skins[cosmetic_id or data.cosmetic_id].default_blueprint and true or false
	local params = {
		name = name_localized,
		category = data.category,
		slot = data.slot,
		weapon_name = managers.weapon_factory:get_weapon_name_by_factory_id(crafted.factory_id),
		customize_locked = add and data.locked_cosmetics and true or false,
		crafted_name = crafted_cosmetic_id and tweak_data.blackmarket.weapon_skins[crafted_cosmetic_id] and tweak_data.blackmarket.weapon_skins[crafted_cosmetic_id].name_id and managers.localization:text(tweak_data.blackmarket.weapon_skins[crafted_cosmetic_id].name_id) or managers.localization:text("bm_menu_no_mod"),
		crafted_has_cosmetic = crafted_has_cosmetic,
		crafted_has_default_blueprint = crafted_has_default_blueprint,
		item_has_cosmetic = item_has_cosmetic,
		item_has_default_blueprint = item_has_default_blueprint,
		yes_func = callback(self, self, "_dialog_yes", yes_clbk),
		no_func = callback(self, self, "_dialog_no")
	}

	managers.menu:show_confirm_weapon_cosmetics(params)
end

function BlackMarketGui:_remove_weapon_cosmetics_callback(data)
	self._item_bought = true

	managers.menu_component:post_event("item_buy")
	managers.blackmarket:on_remove_weapon_cosmetics(data.category, data.slot)
	self:reload()
end

function BlackMarketGui:_equip_weapon_cosmetics_callback(data)
	self._item_bought = true
	local instance_id = data.name

	if data.equip_weapon_cosmetics then
		instance_id = data.equip_weapon_cosmetics.instance_id
	end

	managers.menu_component:post_event("item_buy")
	managers.blackmarket:on_equip_weapon_cosmetics(data.category, data.slot, instance_id)
	self:reload()
end

function BlackMarketGui:_preview_character_mask(data)
	local mask_id = tweak_data:get_raw_value("blackmarket", "masks", "character_locked", CriminalsManager.convert_old_to_new_character_workname(data.name))

	if mask_id then
		managers.blackmarket:view_mask_with_mask_id(mask_id)
		managers.menu:open_node("blackmarket_preview_mask_node", {})
	end
end

function BlackMarketGui:preview_character_mask_callback(data)
	self:_preview_character_mask(data)
end

function BlackMarketGui:_preview_mask(data)
	managers.blackmarket:view_mask(data.slot)
	managers.menu:open_node("blackmarket_preview_mask_node", {})
end

function BlackMarketGui:preview_mask_callback(data)
	self:_preview_mask(data)
end

function BlackMarketGui:sell_item_callback(data)
	print("sell_item_callback", inspect(data))

	local params = {
		name = data.name_localized or data.name,
		category = data.category,
		slot = data.slot
	}
	params.money = managers.experience:cash_string(managers.money:get_weapon_slot_sell_value(params.category, params.slot))
	params.yes_func = callback(self, self, "_dialog_yes", callback(self, self, "_sell_weapon_callback", data))
	params.no_func = callback(self, self, "_dialog_no")

	managers.menu:show_confirm_blackmarket_sell(params)
end

function BlackMarketGui:sell_stashed_mask_callback(data)
	local blueprint = {
		color = {
			id = "nothing",
			global_value = "normal"
		},
		pattern = {
			id = "no_color_no_material",
			global_value = "normal"
		},
		material = {
			id = "plastic",
			global_value = "normal"
		}
	}
	local params = {
		name = data.name_localized or data.name,
		global_value = data.global_value,
		money = managers.experience:cash_string(managers.money:get_mask_sell_value(data.name, data.global_value, blueprint)),
		yes_func = callback(self, self, "_dialog_yes", callback(self, self, "_sell_inventory_mask_callback", data)),
		no_func = callback(self, self, "_dialog_no")
	}

	managers.menu:show_confirm_blackmarket_sell_no_slot(params)
end

function BlackMarketGui:_sell_inventory_mask_callback(data)
	managers.menu_component:post_event("item_sell")
	managers.blackmarket:on_sell_inventory_mask(data.name, data.global_value)

	local x, y = self._selected_slot._bitmap:world_center()

	self:reload()
end

function BlackMarketGui:remove_mask_callback(data)
	local value = managers.money:get_mask_slot_sell_value(data.slot)
	local crafted = managers.blackmarket:get_crafted_category_slot("masks", data.slot)
	local blueprint = crafted and crafted.blueprint or {}
	local params = {
		name = data.name_localized or data.name,
		category = data.category,
		slot = data.slot,
		money = managers.experience:cash_string(value),
		skip_money = value == 0,
		mods_readded = {}
	}

	for category, part in pairs(blueprint) do
		local converted_category = category == "color" and "colors" or category == "material" and "materials" or category == "pattern" and "textures" or category
		local default = managers.blackmarket:customize_mask_category_default(converted_category, true) or {}

		if default.id ~= part.id and part.id ~= "no_color_no_material" and managers.money:get_mask_part_price(converted_category, part.id, part.global_value) == 0 then
			local category_tweak = tweak_data.blackmarket[converted_category]
			local part_tweak = category_tweak and category_tweak[part.id]

			if part_tweak then
				table.insert(params.mods_readded, managers.localization:to_upper_text(part_tweak.name_id))
			end
		end
	end

	params.yes_func = callback(self, self, "_dialog_yes", callback(self, self, "_remove_mask_callback", data))
	params.no_func = callback(self, self, "_dialog_no")

	managers.menu:show_confirm_blackmarket_mask_remove(params)
end

function BlackMarketGui:sell_mask_callback(data)
	local value = managers.money:get_mask_slot_sell_value(data.slot)
	local crafted = managers.blackmarket:get_crafted_category_slot("masks", data.slot)
	local blueprint = crafted and crafted.blueprint or {}
	local params = {
		name = data.name_localized or data.name,
		category = data.category,
		slot = data.slot,
		money = managers.experience:cash_string(value),
		skip_money = value == 0,
		mods_readded = {}
	}

	for category, part in pairs(blueprint) do
		local converted_category = category == "color" and "colors" or category == "material" and "materials" or category == "pattern" and "textures" or category
		local default = managers.blackmarket:customize_mask_category_default(converted_category, true) or {}

		if default.id ~= part.id and part.id ~= "no_color_no_material" and managers.money:get_mask_part_price(converted_category, part.id, part.global_value) == 0 then
			local category_tweak = tweak_data.blackmarket[converted_category]
			local part_tweak = category_tweak and category_tweak[part.id]

			if part_tweak then
				table.insert(params.mods_readded, managers.localization:to_upper_text(part_tweak.name_id))
			end
		end
	end

	params.yes_func = callback(self, self, "_dialog_yes", callback(self, self, "_sell_mask_callback", data))
	params.no_func = callback(self, self, "_dialog_no")

	managers.menu:show_confirm_blackmarket_mask_sell(params)
end

function BlackMarketGui:_sell_weapon_callback(data)
	managers.menu_component:post_event("item_sell")
	managers.blackmarket:on_sell_weapon(data.category, data.slot)
	self:reload()
end

function BlackMarketGui:_remove_mask_callback(data)
	managers.menu_component:post_event("item_sell")
	managers.blackmarket:on_sell_mask(data.slot)
	self:reload()
end

function BlackMarketGui:_sell_mask_callback(data)
	managers.menu_component:post_event("item_sell")
	managers.blackmarket:on_sell_mask(data.slot)
	self:reload()
end

function BlackMarketGui:open_reticle_switch_menu(data)
	managers.menu:open_node("blackmarket_reticle_switch", {
		data
	})
end

function BlackMarketGui:open_customize_gadget_menu(data)
	managers.menu:open_node("blackmarket_customize_gadget", {
		data
	})
end

function BlackMarketGui:open_customize_weapon_color_menu(data)
	local new_node_data = {
		name = data.name,
		category = data.category,
		slot = data.slot,
		cosmetic_quality = data.cosmetic_quality,
		topic_id = "bm_menu_blackmarket_title",
		topic_params = {
			item = self._data.prev_node_data.name_localized
		}
	}

	managers.menu:open_node("blackmarket_customize_weapon_color", {
		new_node_data
	})
end

function BlackMarketGui:sell_weapon_mods_callback(data)
	local params = {
		name = data.name_localized or data.name,
		category = data.category,
		slot = data.slot,
		money = managers.experience:cash_string(managers.money:get_weapon_part_sell_value(data.name, data.global_value)),
		yes_func = callback(self, self, "_dialog_yes", callback(self, self, "_sell_weapon_mod_callback", data)),
		no_func = callback(self, self, "_dialog_no")
	}

	managers.menu:show_confirm_blackmarket_sell(params)
end

function BlackMarketGui:_sell_weapon_mod_callback(data)
	managers.menu_component:post_event("item_sell")
	managers.blackmarket:on_sell_weapon_part(data.name, data.global_value)
	self:reload()
end

function BlackMarketGui:get_weapon_mod_coin_cost(mod_id)
	local weapon_mod_tweak = tweak_data.weapon.factory.parts[mod_id]

	if weapon_mod_tweak and weapon_mod_tweak.is_event_mod then
		return tweak_data.safehouse.prices.event_weapon_mod
	end

	return tweak_data.safehouse.prices.weapon_mod
end

function BlackMarketGui:purchase_weapon_mod_callback(data)
	data.cc_cost = self:get_weapon_mod_coin_cost(data.name)
	local params = {
		name = data.name_localized or data.name,
		category = data.category,
		slot = data.slot,
		money = managers.experience:cash_string(data.cc_cost, "")
	}
	local weapon_mod_tweak = tweak_data.weapon.factory.parts[data.name]

	if weapon_mod_tweak and weapon_mod_tweak.is_event_mod and (not data.unlocked or data.unlocked < 1) then
		params.unlock_text = managers.localization:text(weapon_mod_tweak.is_event_mod)
		local dialog_data = {
			title = managers.localization:text("dialog_bm_purchase_mod_locked_title"),
			text = managers.localization:text("dialog_bm_purchase_mod_locked", params)
		}
		local ok_button = {
			text = managers.localization:text("dialog_ok")
		}
		dialog_data.button_list = {
			ok_button
		}

		managers.system_menu:show(dialog_data)

		return
	end

	local coins = 0
	coins = managers.custom_safehouse:coins()

	if coins < data.cc_cost then
		local dialog_data = {
			title = managers.localization:text("dialog_bm_purchase_mod_cant_afford_title"),
			text = managers.localization:text("dialog_bm_purchase_mod_cant_afford", params)
		}
		local ok_button = {
			text = managers.localization:text("dialog_ok")
		}
		dialog_data.button_list = {
			ok_button
		}

		managers.system_menu:show(dialog_data)

		return
	end

	params.yes_func = callback(self, self, "_dialog_yes", callback(self, self, "_confirm_purchase_weapon_mod_callback", data))
	params.no_func = callback(self, self, "_dialog_no")

	managers.menu:show_confirm_blackmarket_weapon_mod_purchase(params)
end

function BlackMarketGui:_confirm_purchase_weapon_mod_callback(data)
	managers.menu_component:post_event("item_sell")
	managers.blackmarket:add_to_inventory(data.global_value, "weapon_mods", data.name, true)
	managers.custom_safehouse:deduct_coins(data.cc_cost or tweak_data.safehouse.prices.weapon_mod)
	self:reload()
end

function BlackMarketGui:choose_weapon_buy_callback(data)
	self:open_weapon_buy_menu(data)
end

function BlackMarketGui:open_weapon_buy_menu(data, check_allowed_item_func)
	local blackmarket_items = managers.blackmarket:get_weapon_category(data.category) or {}
	local new_node_data = {}
	local weapon_tweak = tweak_data.weapon
	local x_id, y_id, x_level, y_level, x_unlocked, y_unlocked, x_skill, y_skill, x_gv, y_gv, x_sn, y_sn = nil
	local item_categories = {}
	local sorted_categories = {}
	local gui_categories = tweak_data.gui.buy_weapon_categories[data.category]

	for i = 1, #gui_categories, 1 do
		table.insert(item_categories, {})
	end

	local function test_weapon_categories(weapon_categories, gui_weapon_categories)
		for i, weapon_category in ipairs(gui_weapon_categories) do
			if weapon_category ~= (tweak_data.gui.buy_weapon_category_aliases[weapon_categories[i]] or weapon_categories[i]) then
				return false
			end
		end

		return true
	end

	for _, item in ipairs(blackmarket_items) do
		local weapon_data = tweak_data.weapon[item.weapon_id]

		for i, gui_category in ipairs(gui_categories) do
			if test_weapon_categories(weapon_data.categories, gui_category) then
				table.insert(item_categories[i], item)
			end
		end
	end

	for i, category in ipairs(item_categories) do
		local category_key = table.concat(gui_categories[i], "_")
		item_categories[category_key] = category
		item_categories[i] = nil
		sorted_categories[i] = category_key
	end

	for category, items in pairs(item_categories) do
		table.sort(items, function (x, y)
			if _G.IS_VR and x.vr_locked ~= y.vr_locked then
				return not x.vr_locked
			end

			x_unlocked = managers.blackmarket:weapon_unlocked(x.weapon_id)
			y_unlocked = managers.blackmarket:weapon_unlocked(y.weapon_id)

			if x_unlocked ~= y_unlocked then
				return x_unlocked
			end

			x_level = x.level or 0
			y_level = y.level or 0

			if x_level ~= y_level then
				return x_level < y_level
			end

			x_id = x.weapon_id
			y_id = y.weapon_id
			x_gv = weapon_tweak[x_id].global_value
			y_gv = weapon_tweak[y_id].global_value
			x_sn = x_gv and tweak_data.lootdrop.global_values[x_gv].sort_number or 0
			y_sn = y_gv and tweak_data.lootdrop.global_values[y_gv].sort_number or 0

			if x_sn ~= y_sn then
				return x_sn < y_sn
			end

			x_skill = x.skill_based
			y_skill = y.skill_based

			if x_skill ~= y_skill then
				return y_skill
			end

			return x_id < y_id
		end)
	end

	local item_data = nil
	local rows = tweak_data.gui.WEAPON_ROWS_PER_PAGE or 3
	local columns = tweak_data.gui.WEAPON_COLUMNS_PER_PAGE or 3

	for _, category in ipairs(sorted_categories) do
		local items = item_categories[category]
		item_data = {}

		for _, item in ipairs(items) do
			table.insert(item_data, item)
		end

		local name_id = managers.localization:to_upper_text("menu_" .. category)

		table.insert(new_node_data, {
			name = category,
			category = data.category,
			prev_node_data = data,
			name_localized = name_id,
			on_create_func = data.on_create_func,
			on_create_func_name = not data.on_create_func and (data.on_create_func_name or "populate_buy_weapon"),
			on_create_data = item_data,
			identifier = self.identifiers.weapon,
			override_slots = {
				columns,
				rows
			}
		})
	end

	new_node_data.buying_weapon = true
	new_node_data.topic_id = "bm_menu_buy_weapon_title"
	new_node_data.topic_params = {
		weapon_category = managers.localization:text("bm_menu_" .. data.category)
	}
	new_node_data.blur_fade = self._data.blur_fade

	managers.menu:open_node(self._inception_node_name, {
		new_node_data
	})
end

function BlackMarketGui:choose_weapon_buy_callback2(data)
	local items = managers.blackmarket:get_weapon_category(data.category) or {}
	local new_node_data = {}
	local weapon_tweak = tweak_data.weapon
	local x_id, y_id, x_level, y_level, x_skill, y_skill, x_gv, y_gv, x_sn, y_sn = nil

	table.sort(items, function (x, y)
		if x.unlocked ~= y.unlocked then
			return x.unlocked
		end

		x_id = x.weapon_id
		y_id = y.weapon_id
		x_gv = weapon_tweak[x_id].global_value
		y_gv = weapon_tweak[y_id].global_value
		x_sn = x_gv and tweak_data.lootdrop.global_values[x_gv].sort_number or 0
		y_sn = y_gv and tweak_data.lootdrop.global_values[y_gv].sort_number or 0

		if x_sn ~= y_sn then
			return x_sn < y_sn
		end

		x_skill = x.skill_based
		y_skill = y.skill_based

		if x_skill ~= y_skill then
			return y_skill
		end

		x_level = x.level or 0
		y_level = y.level or 0

		if x_level ~= y_level then
			return x_level < y_level
		end

		return x_id < y_id
	end)

	local item_data = {}

	for i = 1, math.ceil(#items / 9), 1 do
		item_data = {}

		for id = (i - 1) * 9 + 1, math.min(i * 9, #items), 1 do
			table.insert(item_data, items[id])
		end

		table.insert(new_node_data, {
			on_create_func_name = "populate_buy_weapon",
			name = tostring(i),
			category = data.category,
			prev_node_data = data,
			name_localized = tostring(i),
			on_create_data = item_data,
			identifier = self.identifiers.weapon
		})
	end

	new_node_data.buying_weapon = true
	new_node_data.topic_id = "bm_menu_buy_weapon_title"
	new_node_data.topic_params = {
		weapon_category = managers.localization:text("bm_menu_" .. data.category)
	}
	new_node_data.blur_fade = self._data.blur_fade

	managers.menu:open_node(self._inception_node_name, {
		new_node_data
	})
end

function BlackMarketGui:choose_mask_global_value_callback(data)
	local masks = managers.blackmarket:get_inventory_masks() or {}
	local new_node_data = {}
	local items = {}

	for _, mask in pairs(masks) do
		local new_global_value = true

		for _, global_value in ipairs(items) do
			if global_value == mask.global_value then
				new_global_value = false
			end
		end

		if new_global_value then
			table.insert(items, mask.global_value)
		end
	end

	table.sort(items, function (x, y)
		local global_values = {
			infamous = 4,
			exceptional = 3,
			superior = 2,
			normal = 1
		}

		if global_values[x] and global_values[y] then
			return global_values[x] < global_values[y]
		end
	end)

	local item_data = {}

	for i = 1, math.ceil(#items / 9), 1 do
		item_data = {}

		for id = (i - 1) * 9 + 1, math.min(i * 9, #items), 1 do
			table.insert(item_data, items[id])
		end

		table.insert(new_node_data, {
			on_create_func_name = "populate_mask_global_value",
			name = tostring(i),
			category = data.category,
			prev_node_data = data,
			name_localized = tostring(i),
			on_create_data = item_data,
			identifier = self.identifiers.mask
		})
	end

	new_node_data.topic_id = "bm_menu_choose_global_value_title"
	new_node_data.topic_params = {
		category = managers.localization:text("bm_menu_buy_mask_title")
	}
	new_node_data.blur_fade = self._data.blur_fade

	managers.menu:open_node(self._inception_node_name, {
		new_node_data
	})
end

function BlackMarketGui:choose_weapon_slot_unlock_callback(data)
	local params = {
		money = managers.experience:cash_string(managers.money:get_buy_weapon_slot_price()),
		yes_func = callback(self, self, "_dialog_yes", callback(self, self, "_buy_weapon_slot_callback", data)),
		no_func = callback(self, self, "_dialog_no")
	}

	managers.menu:show_confirm_blackmarket_buy_weapon_slot(params)
end

function BlackMarketGui:choose_mask_slot_unlock_callback(data)
	local params = {
		money = managers.experience:cash_string(managers.money:get_buy_mask_slot_price()),
		yes_func = callback(self, self, "_dialog_yes", callback(self, self, "_buy_mask_slot_callback", data)),
		no_func = callback(self, self, "_dialog_no")
	}

	managers.menu:show_confirm_blackmarket_buy_mask_slot(params)
end

function BlackMarketGui:choose_mask_buy_callback(data)
	local masks_data = tweak_data.blackmarket.masks
	local masks = managers.blackmarket:get_inventory_masks() or {}
	local new_node_data = {}
	local items = {}
	local itemids = {}

	local function func_add_item(global_value, item_id, item)
		if not masks_data[item_id] or masks_data[item_id].inaccessible or not tweak_data.lootdrop.global_values[global_value] then
			return
		end

		local category = tweak_data.lootdrop.global_values[global_value].category

		if category then
			global_value = category
		end

		itemids[global_value] = itemids[global_value] or {}
		items[global_value] = items[global_value] or {}

		if not table.contains(itemids[global_value], item_id) then
			table.insert(items[global_value], item)
			table.insert(itemids[global_value], item_id)
		end
	end

	for _, mask in ipairs(masks) do
		func_add_item(mask.global_value, mask.mask_id, mask)
	end

	for mask_id, mask in pairs(masks_data) do
		if mask.pc or mask.pcs then
			local global_values = {}

			if mask.dlc or mask.dlcs then
				local dlcs = {}

				if mask.dlc then
					table.insert(dlcs, mask.dlc)
				end

				for i, dlc in ipairs(mask.dlcs or {}) do
					table.insert(dlcs, dlc)
				end

				local add_dlc = false
				local dlc_tweak, global_value_tweak, global_value = nil

				for _, dlc in ipairs(dlcs) do
					global_value = mask.global_value or dlc
					global_value_tweak = tweak_data.lootdrop.global_values[global_value] or {}
					add_dlc = not global_value_tweak.hide_unavailable or managers.dlc:is_dlc_unlocked(dlc)

					if add_dlc then
						table.insert(global_values, global_value)

						if mask.global_value then
							break
						end
					end
				end
			elseif mask.global_value then
				table.insert(global_values, mask.global_value)
			else
				table.insert(global_values, mask.infamous and "infamous" or "normal")
			end

			for _, global_value in ipairs(global_values) do
				func_add_item(global_value, mask_id, {
					amount = 0,
					global_value = global_value,
					mask_id = mask_id
				})
			end
		end
	end

	local iso = tweak_data.gui.masks_sort_order
	local x_iso, y_iso = nil
	local sort_td = tweak_data.blackmarket.masks
	local x_td, y_td, x_sn, y_sn = nil
	local global_value_sort = {}
	local loc_man = managers.localization
	local saved_locs = {}

	local function sort_func(x, y)
		x_td = sort_td[x.mask_id]
		y_td = sort_td[y.mask_id]
		x_sn = tweak_data.lootdrop.global_values[x.global_value].sort_number or 0
		y_sn = tweak_data.lootdrop.global_values[y.global_value].sort_number or 0
		x_sn = x_sn + (x_td.sort_number or 0)
		y_sn = y_sn + (y_td.sort_number or 0)
		x_iso = table.get_key(iso, x.mask_id) or 0
		y_iso = table.get_key(iso, y.mask_id) or 0

		if x_sn ~= y_sn then
			return x_sn < y_sn
		end

		if x_td.value == 0 and y_td.value ~= 0 then
			return false
		elseif x_td.value ~= 0 and y_td.value == 0 then
			return true
		end

		if x_iso ~= y_iso then
			return x_iso < y_iso
		end

		local x_loc = saved_locs[x.mask_id] or loc_man:to_upper_text(x_td.name_id)
		local y_loc = saved_locs[y.mask_id] or loc_man:to_upper_text(y_td.name_id)
		saved_locs[x.mask_id] = x_loc
		saved_locs[y.mask_id] = y_loc

		if x_loc ~= y_loc then
			return x_loc < y_loc
		end

		return x.mask_id < y.mask_id
	end

	for global_value, gv_items in pairs(items) do
		table.insert(global_value_sort, global_value)
		table.sort(gv_items, sort_func)
	end

	table.sort(global_value_sort, function (x, y)
		x_td = tweak_data.lootdrop.global_value_category[x] or tweak_data.lootdrop.global_values[x]
		y_td = tweak_data.lootdrop.global_value_category[y] or tweak_data.lootdrop.global_values[y]
		x_sn = x_td and x_td.sort_number or 1
		y_sn = y_td and y_td.sort_number or 1

		return x_sn < y_sn
	end)

	local item_data = nil

	for _, global_value in ipairs(global_value_sort) do
		item_data = {}

		for _, mask in ipairs(items[global_value]) do
			table.insert(item_data, mask)
		end

		local name_id = tweak_data.lootdrop.global_value_category[global_value] and tweak_data.lootdrop.global_value_category[global_value].name_id or tweak_data.lootdrop.global_values[global_value].name_id

		table.insert(new_node_data, {
			on_create_func_name = "populate_buy_mask",
			name = global_value,
			category = data.category,
			prev_node_data = data,
			name_localized = managers.localization:to_upper_text(name_id),
			on_create_data = item_data,
			override_slots = BUY_MASK_SLOTS,
			identifier = self.identifiers.mask
		})
	end

	new_node_data.topic_id = "bm_menu_buy_mask_title"
	new_node_data.topic_params = {}
	new_node_data.blur_fade = self._data.blur_fade

	managers.menu:open_node(self._inception_node_name, {
		new_node_data
	})
end

function BlackMarketGui:buy_mask_callback(data)
	if self._item_bought then
		return
	end

	local params = {
		name = data.name_localized or data.name,
		category = data.category,
		slot = data.slot,
		weapon = data.name,
		yes_func = callback(self, self, "_dialog_yes", callback(self, self, "_buy_mask_callback", data)),
		no_func = callback(self, self, "_dialog_no")
	}

	managers.menu:show_confirm_blackmarket_assemble(params)
end

function BlackMarketGui:mask_mods_callback(data)
	local all_mods_by_type = {
		materials = managers.blackmarket:get_inventory_category("materials"),
		textures = managers.blackmarket:get_inventory_category("textures"),
		colors = managers.blackmarket:get_inventory_category("colors")
	}
	local new_node_data = {}
	local list = {
		"materials",
		"textures",
		"colors"
	}
	local mask_default_blueprint = managers.blackmarket:get_mask_default_blueprint(data.name)

	for _, category in pairs(list) do
		local listed_items = {}
		local items = all_mods_by_type[category]
		local default = mask_default_blueprint[category]
		local mods = {}

		if default then
			if default.id == "no_color_no_material" then
				default = managers.blackmarket:customize_mask_category_default(category)
			end

			if default.id ~= "nothing" and default.id ~= "no_color_no_material" then
				table.insert(mods, default)

				mods[#mods].pcs = {
					0
				}
				mods[#mods].default = true
				listed_items[default.id] = true
			end
		end

		if category == "materials" and not listed_items.plastic then
			table.insert(mods, {
				id = "plastic",
				global_value = "normal"
			})

			mods[#mods].pcs = {
				0
			}
			mods[#mods].default = true
		end

		local td = nil

		for i = 1, #items, 1 do
			td = tweak_data.blackmarket[category][items[i].id]

			if not listed_items[items[i].id] and td.texture or td.colors then
				table.insert(mods, items[i])

				mods[#mods].pc = td.pc or td.pcs and td.pcs[1] or 10
				mods[#mods].colors = td.colors
			end
		end

		local sort_td = tweak_data.blackmarket[category]
		local x_pc, y_pc = nil

		table.sort(mods, function (x, y)
			if x.colors and y.colors then
				for i = 1, 2, 1 do
					local x_color = x.colors[i]
					local x_max = math.max(x_color.r, x_color.g, x_color.b)
					local x_min = math.min(x_color.r, x_color.g, x_color.b)
					local x_diff = x_max - x_min
					local x_wl = nil

					if x_max == x_min then
						x_wl = 10 - x_color.r
					elseif x_max == x_color.r then
						x_wl = (x_color.g - x_color.b) / x_diff % 6
					elseif x_max == x_color.g then
						x_wl = (x_color.b - x_color.r) / x_diff + 2
					elseif x_max == x_color.b then
						x_wl = (x_color.r - x_color.g) / x_diff + 4
					end

					local y_color = y.colors[i]
					local y_max = math.max(y_color.r, y_color.g, y_color.b)
					local y_min = math.min(y_color.r, y_color.g, y_color.b)
					local y_diff = y_max - y_min
					local y_wl = nil

					if y_max == y_min then
						y_wl = 10 - y_color.r
					elseif y_max == y_color.r then
						y_wl = (y_color.g - y_color.b) / y_diff % 6
					elseif y_max == y_color.g then
						y_wl = (y_color.b - y_color.r) / y_diff + 2
					elseif y_max == y_color.b then
						y_wl = (y_color.r - y_color.g) / y_diff + 4
					end

					if x_wl ~= y_wl then
						return x_wl < y_wl
					end
				end
			end

			x_pc = x.pc or x.pcs and x.pcs[1] or 1001
			y_pc = y.pc or y.pcs and y.pcs[1] or 1001
			x_pc = x_pc + (x.global_value and tweak_data.lootdrop.global_values[x.global_value].sort_number or 0)
			y_pc = y_pc + (y.global_value and tweak_data.lootdrop.global_values[y.global_value].sort_number or 0)

			return x_pc < y_pc
		end)

		local max_x = 6
		local max_y = 3
		local mod_data = mods or {}

		table.insert(new_node_data, {
			on_create_func_name = "populate_choose_mask_mod",
			name = category,
			category = category,
			prev_node_data = data,
			name_localized = managers.localization:to_upper_text("bm_menu_" .. category),
			on_create_data = mod_data,
			override_slots = {
				max_x,
				max_y
			},
			identifier = self.identifiers.mask_mod
		})
	end

	new_node_data.topic_id = "bm_menu_customize_mask_title"
	new_node_data.topic_params = {
		mask_name = data.name_localized
	}
	local params = {
		yes_func = callback(self, self, "_dialog_yes", callback(self, self, "_abort_customized_mask_callback")),
		no_func = callback(self, self, "_dialog_no")
	}
	new_node_data.back_callback = callback(self, self, "_warn_abort_customized_mask_callback", params)
	new_node_data.init_callback_name = "start_customize_mask"
	new_node_data.init_callback_params = {
		run_once = true,
		slot = data.slot
	}
	new_node_data.blur_fade = self._data.blur_fade

	managers.menu:open_node("blackmarket_mask_node", {
		new_node_data
	})
end

function BlackMarketGui:mask_mods_callback2(data)
	local mods = {
		materials = managers.blackmarket:get_inventory_category("materials"),
		textures = managers.blackmarket:get_inventory_category("textures"),
		colors = managers.blackmarket:get_inventory_category("colors")
	}
	local new_node_data = {}
	local mods_list = {}

	for id, data in pairs(mods) do
		table.insert(mods_list, id)
	end

	local max_x = 3
	local max_y = 1
	local mod_data = {}

	for i = 1, math.max(1, math.ceil(#mods_list / (max_x * max_y))), 1 do
		mod_data = {}

		for id = (i - 1) * max_x * max_y + 1, math.min(i * max_x * max_y, #mods_list), 1 do
			mod_data[mods_list[id]] = mods[mods_list[id]]
		end

		table.insert(new_node_data, {
			on_create_func_name = "populate_mask_mod_types",
			name = tostring(i),
			category = data.category,
			prev_node_data = data,
			name_localized = tostring(i),
			on_create_data = mod_data,
			override_slots = {
				max_x,
				max_y
			},
			identifier = self.identifiers.mask_mod
		})
	end

	new_node_data.topic_id = "bm_menu_customize_mask_title"
	new_node_data.topic_params = {
		mask_name = data.name_localized
	}
	local params = {
		yes_func = callback(self, self, "_dialog_yes", callback(self, self, "_abort_customized_mask_callback")),
		no_func = callback(self, self, "_dialog_no")
	}
	new_node_data.back_callback = callback(self, self, "_warn_abort_customized_mask_callback", params)
	new_node_data.init_callback_name = "start_customize_mask"
	new_node_data.init_callback_params = {
		run_once = true,
		slot = data.slot
	}
	new_node_data.blur_fade = self._data.blur_fade

	managers.menu:open_node("blackmarket_mask_node", {
		new_node_data
	})
end

function BlackMarketGui:start_customize_mask(params)
	managers.blackmarket:start_customize_mask(params.slot)
end

function BlackMarketGui:choose_mask_mod_callback(type_category, data, prev_node_params)
	self:choose_mask_type_callback(data, prev_node_params, type_category)
end

function BlackMarketGui:choose_mask_type_callback(data, prev_node_params, type_category)
	if not managers.blackmarket:currently_customizing_mask() then
		return
	end

	local items = deep_clone(data.all_mods_by_type[type_category]) or {}
	local new_node_data = {}
	local category = type_category or data.category
	local default = managers.blackmarket:customize_mask_category_default(category)
	local mods = {}

	if default then
		table.insert(mods, default)

		mods[#mods].pcs = {
			0
		}
		mods[#mods].default = true
	end

	local td = nil

	for i = 1, #items, 1 do
		td = tweak_data.blackmarket[category][items[i].id]

		if td.texture or td.colors then
			table.insert(mods, items[i])

			mods[#mods].pc = td.pc or td.pcs and td.pcs[1] or 0
			mods[#mods].colors = td.colors
		end
	end

	local sort_td = tweak_data.blackmarket[category]
	local x_pc, y_pc = nil

	table.sort(mods, function (x, y)
		if x.colors and y.colors then
			for i = 1, 2, 1 do
				local x_color = x.colors[i]
				local x_max = math.max(x_color.r, x_color.g, x_color.b)
				local x_min = math.min(x_color.r, x_color.g, x_color.b)
				local x_diff = x_max - x_min
				local x_wl = nil

				if x_max == x_min then
					x_wl = 10 - x_color.r
				elseif x_max == x_color.r then
					x_wl = (x_color.g - x_color.b) / x_diff % 6
				elseif x_max == x_color.g then
					x_wl = (x_color.b - x_color.r) / x_diff + 2
				elseif x_max == x_color.b then
					x_wl = (x_color.r - x_color.g) / x_diff + 4
				end

				local y_color = y.colors[i]
				local y_max = math.max(y_color.r, y_color.g, y_color.b)
				local y_min = math.min(y_color.r, y_color.g, y_color.b)
				local y_diff = y_max - y_min
				local y_wl = nil

				if y_max == y_min then
					y_wl = 10 - y_color.r
				elseif y_max == y_color.r then
					y_wl = (y_color.g - y_color.b) / y_diff % 6
				elseif y_max == y_color.g then
					y_wl = (y_color.b - y_color.r) / y_diff + 2
				elseif y_max == y_color.b then
					y_wl = (y_color.r - y_color.g) / y_diff + 4
				end

				if x_wl ~= y_wl then
					return x_wl < y_wl
				end
			end
		end

		x_pc = x.pc or x.pcs and x.pcs[1] or 1001
		y_pc = y.pc or y.pcs and y.pcs[1] or 1001
		x_pc = x_pc + (x.global_value and tweak_data.lootdrop.global_values[x.global_value].sort_number or 0)
		y_pc = y_pc + (y.global_value and tweak_data.lootdrop.global_values[y.global_value].sort_number or 0)

		return x_pc < y_pc
	end)

	local max_x = 6
	local max_y = 3
	local mod_data = {}

	for i = 1, math.ceil(#mods / (max_x * max_y)), 1 do
		mod_data = {}

		for id = (i - 1) * max_x * max_y + 1, math.min(i * max_x * max_y, #mods), 1 do
			table.insert(mod_data, mods[id])
		end

		table.insert(new_node_data, {
			on_create_func_name = "populate_choose_mask_mod",
			name = tostring(i),
			category = category,
			prev_node_data = data,
			name_localized = tostring(i),
			on_create_data = mod_data,
			override_slots = {
				max_x,
				max_y
			},
			identifier = self.identifiers.mask_mod
		})
	end

	new_node_data.topic_id = "bm_menu_customize_mask_title"
	new_node_data.topic_params = {
		mask_name = prev_node_params.mask_name
	}
	new_node_data.open_callback_name = "update_mod_mask"
	new_node_data.blur_fade = self._data.blur_fade

	managers.menu:open_node("blackmarket_mask_node", {
		new_node_data
	})
end

function BlackMarketGui:preview_customized_mask_callback(data)
	if not managers.blackmarket:can_view_customized_mask() then
		-- Nothing
	end

	managers.menu:open_node("blackmarket_preview_mask_node", {})
	managers.blackmarket:view_customized_mask()
end

function BlackMarketGui:preview_customized_mask_with_mod_callback(data)
	if not managers.blackmarket:can_view_customized_mask_with_mod(data.category, data.name, data.global_value) then
		return
	end

	managers.menu:open_node("blackmarket_preview_mask_node", {})
	managers.blackmarket:view_customized_mask_with_mod(data.category, data.name)
end

function BlackMarketGui:_warn_abort_customized_mask_callback(params)
	return managers.blackmarket:warn_abort_customize_mask(params)
end

function BlackMarketGui:_abort_customized_mask_callback()
	managers.blackmarket:abort_customize_mask()
	managers.menu:back(true)
end

function BlackMarketGui:buy_customized_mask_callback(data)
	if self._item_bought then
		return
	end

	local params = {
		name = managers.localization:text(tweak_data.blackmarket.masks[managers.blackmarket:get_customize_mask_id()].name_id),
		category = data.category,
		slot = data.slot,
		money = managers.experience:cash_string(managers.blackmarket:get_customize_mask_value()),
		yes_func = callback(self, self, "_dialog_yes", callback(self, self, "_buy_customized_mask_callback", data)),
		no_func = callback(self, self, "_dialog_no")
	}

	managers.menu:show_confirm_blackmarket_finalize(params)
end

function BlackMarketGui:_buy_customized_mask_callback(data)
	self._item_bought = true

	managers.menu_component:post_event("finalize_mask")
	managers.blackmarket:finish_customize_mask()
	managers.menu:back(true)
end

function BlackMarketGui:choose_mask_part_callback(data)
	if managers.blackmarket:select_customize_mask(data.category, data.name, data.global_value) then
		self:reload()
	end
end

function BlackMarketGui:buy_weapon_callback(data)
	if self._item_bought then
		return
	end

	local params = {
		name = data.name_localized or data.name,
		category = data.category,
		slot = data.slot,
		weapon = data.name,
		money = managers.experience:cash_string(managers.money:get_weapon_price_modified(data.name)),
		yes_func = callback(self, self, "_dialog_yes", callback(self, self, "_buy_weapon_callback", data)),
		no_func = callback(self, self, "_dialog_no")
	}

	managers.menu:show_confirm_blackmarket_buy(params)
end

function BlackMarketGui:show_available_mask_mods_callback(data)
	local mask_components = {}
	local masks = deep_clone(managers.blackmarket:get_inventory_masks() or {})

	for i, data in pairs(masks) do
		data.name_id = managers.localization:text(tweak_data.blackmarket.masks[data.mask_id].name_id)
	end

	local sort_td = tweak_data.blackmarket.masks
	local x_td, y_td, x_pc, y_pc = nil

	table.sort(masks, function (x, y)
		return x.name_id < y.name_id
	end)

	mask_components.masks = masks
	local all_mods = {
		materials = managers.blackmarket:get_inventory_category("materials"),
		textures = managers.blackmarket:get_inventory_category("textures"),
		colors = managers.blackmarket:get_inventory_category("colors")
	}

	for _, type_category in ipairs({
		"materials",
		"textures",
		"colors"
	}) do
		local items = deep_clone(all_mods[type_category]) or {}
		local new_node_data = {}
		local category = type_category or data.category
		local default = managers.blackmarket:customize_mask_category_default(category)
		local mods = {}

		if default then
			table.insert(mods, default)
		end

		local td = nil

		for i = 1, #items, 1 do
			td = tweak_data.blackmarket[category][items[i].id]

			if td.texture or td.colors then
				table.insert(mods, items[i])
			end
		end

		for i, data in pairs(mods) do
			data.name_id = managers.localization:text(tweak_data.blackmarket[type_category][data.id].name_id)
		end

		local sort_td = tweak_data.blackmarket[category]
		local x_pc, y_pc = nil

		table.sort(mods, function (x, y)
			return x.name_id < y.name_id
		end)

		mask_components[type_category] = mods
	end

	local reload_gui = false
	local text_block = ""
	local color_table = {}
	local i = 1

	for _, category in ipairs({
		"masks",
		"materials",
		"textures",
		"colors"
	}) do
		local mods = mask_components[category]
		text_block = text_block .. "--- " .. managers.localization:to_upper_text("bm_menu_" .. category) .. " ---"

		for _, part_data in ipairs(mods) do
			local part_id = part_data.id or part_data.mask_id
			local global_value = part_data.global_value
			text_block = text_block .. "\n "
			color_table[i] = tweak_data.lootdrop.global_values[global_value].color
			text_block = text_block .. "##" .. tostring(part_data.name_id) .. "##"

			if managers.blackmarket:check_new_drop(global_value, category, part_id) then
				text_block = text_block .. managers.localization:get_default_macro("BTN_INV_NEW")

				managers.blackmarket:remove_new_drop(global_value, category, part_id)

				reload_gui = true
			end

			i = i + 1
		end

		if category ~= "colors" then
			text_block = text_block .. "\n\n"
		end
	end

	local params = {
		color_table = color_table,
		weapon_id = data.name,
		text_block = text_block
	}

	managers.menu:show_mask_mods_available(params)

	if reload_gui then
		self:reload()
	end
end

function BlackMarketGui:show_buy_dlc_callback(data)
	local dlc_data = Global.dlc_manager.all_dlc_data[data.global_value]
	local app_id = dlc_data and dlc_data.app_id

	if app_id and not dlc_data.external and MenuCallbackHandler:is_overlay_enabled() then
		Steam:overlay_activate("store", app_id)
	end
end

function BlackMarketGui:show_available_mods_callback(data)
	local dropable_mods = managers.blackmarket:get_dropable_mods_by_weapon_id(data.name)
	local text_block = ""
	local color_table = {}
	local index = table.size(dropable_mods)
	local sort_data = {}

	for category, mods in pairs(dropable_mods) do
		table.insert(sort_data, category)
	end

	table.sort(sort_data, function (x, y)
		return x < y
	end)

	local sort_td = tweak_data.blackmarket.weapon_mods
	local x_td, y_td, x_pc, y_pc = nil

	local function sort_func(x, y)
		x_td = sort_td[x[1]]
		y_td = sort_td[y[1]]
		x_pc = x_td.value or x_td.pcs and x_td.pcs[1] or 0
		y_pc = y_td.value or y_td.pcs and y_td.pcs[1] or 0

		if x_td.infamous then
			x_pc = x_pc + 100
		end

		if y_td.infamous then
			y_pc = y_pc + 100
		end

		return x_pc < y_pc or x_pc == y_pc and x[1] < y[1]
	end

	for category, mods in pairs(dropable_mods) do
		table.sort(mods, sort_func)
	end

	local reload_gui = false
	local i = 1

	for _, category in ipairs(sort_data) do
		local mods = dropable_mods[category]
		text_block = text_block .. "--- " .. managers.localization:to_upper_text("bm_menu_" .. category) .. " ---"

		for _, part_data in ipairs(mods) do
			local part_id = part_data[1]
			local global_value = part_data[2]
			local got_part = managers.blackmarket:get_item_amount(global_value, "weapon_mods", part_id, true) > 0
			text_block = text_block .. "\n "

			if got_part then
				color_table[i] = tweak_data.lootdrop.global_values[global_value].color
			else
				color_table[i] = Color(0.5, 0.5, 0.5)
			end

			text_block = text_block .. "##" .. managers.localization:text(tweak_data.weapon.factory.parts[part_id].name_id) .. "##"

			if managers.blackmarket:check_new_drop(global_value, "weapon_mods", part_id) then
				text_block = text_block .. managers.localization:get_default_macro("BTN_INV_NEW")

				managers.blackmarket:remove_new_drop(global_value, "weapon_mods", part_id)

				reload_gui = true
			end

			i = i + 1
		end

		index = index - 1

		if index > 0 then
			text_block = text_block .. "\n\n"
		end
	end

	local params = {
		color_table = color_table,
		weapon_id = data.name,
		text_block = text_block
	}

	managers.menu:show_weapon_mods_available(params)

	if reload_gui then
		self:reload()
	end
end

function BlackMarketGui:_buy_mask_slot_callback(data)
	self._item_bought = true

	managers.menu_component:post_event("item_buy")
	managers.blackmarket:buy_unlock_mask_slot(data.slot)
	self:reload()
end

function BlackMarketGui:_buy_weapon_slot_callback(data)
	self._item_bought = true

	managers.menu_component:post_event("item_buy")
	managers.blackmarket:buy_unlock_weapon_slot(data.category, data.slot)
	self:reload()
end

function BlackMarketGui:_buy_mask_callback(data)
	self._item_bought = true

	managers.menu_component:post_event("item_buy")
	managers.blackmarket:on_buy_mask_to_inventory(data.name, data.global_value, data.slot, nil)
	managers.menu:back(true, math.max(data.num_backs - 1, 0))
end

function BlackMarketGui:_buy_weapon_callback(data)
	self._item_bought = true

	managers.menu_component:post_event("item_buy")
	managers.blackmarket:on_buy_weapon_platform(data.category, data.name, data.slot)
	managers.menu:back(true)
	managers.mission:call_global_event(Message.OnWeaponBought)
end

function BlackMarketGui:preview_buy_weapon_callback(data)
	managers.blackmarket:view_weapon_platform(data.name, callback(self, self, "_open_preview_node"))
end

function BlackMarketGui:preview_buy_mask_callback(data)
	managers.menu:open_node("blackmarket_preview_mask_node", {})
	managers.blackmarket:view_mask_with_mask_id(data.name)
end

function BlackMarketGui:choose_mod_callback(data, prev_node_params)
	local mods = deep_clone(data.mods) or {}
	local new_node_data = {}
	local factory_id = managers.blackmarket:get_crafted_category(data.category)[data.slot].factory_id
	local mod_data = {}

	for i = 1, math.ceil(#mods / 9), 1 do
		mod_data = {}

		for id = (i - 1) * 9 + 1, math.min(i * 9, #mods), 1 do
			table.insert(mod_data, {
				mods[id],
				false
			})
		end

		table.insert(new_node_data, {
			on_create_func_name = "populate_mods",
			name = tostring(i),
			category = data.category,
			prev_node_data = data,
			name_localized = tostring(i),
			on_create_data = mod_data,
			identifier = self.identifiers.weapon_mod
		})
	end

	new_node_data.topic_id = "bm_menu_blackmarket_title"
	new_node_data.topic_params = {
		item = prev_node_params.weapon_name
	}
	new_node_data.show_tabs = true

	managers.menu:open_node(self._inception_node_name, {
		new_node_data
	})
end

function BlackMarketGui:buy_mod_callback(data)
	if self._item_bought then
		return
	end

	local params = {
		name = data.name_localized or data.name,
		category = data.category,
		slot = data.slot,
		weapon_name = managers.weapon_factory:get_weapon_name_by_factory_id(managers.blackmarket:get_crafted_category(data.category)[data.slot].factory_id),
		add = true
	}
	local weapon_id = managers.blackmarket:get_crafted_category(data.category)[data.slot].weapon_id
	local cost = managers.money:get_weapon_modify_price(weapon_id, data.name, data.global_value) or 0
	params.money = cost > 0 and managers.experience:cash_string(cost)
	local replaces, removes = managers.blackmarket:get_modify_weapon_consequence(data.category, data.slot, data.name)
	params.replaces = replaces or {}
	params.removes = removes or {}

	if data.default_mod then
		table.delete(replaces, data.default_mod)
		table.delete(removes, data.default_mod)
	end

	params.yes_func = callback(self, self, "_dialog_yes", callback(self, self, "_buy_mod_callback", data))
	params.no_func = callback(self, self, "_dialog_no")

	managers.menu:show_confirm_blackmarket_mod(params)
end

function BlackMarketGui:_buy_mod_callback(data)
	self._item_bought = true

	managers.menu_component:post_event("item_buy")
	managers.blackmarket:buy_and_modify_weapon(data.category, data.slot, data.global_value, data.name, false, data.free_of_charge)

	local factory = tweak_data.weapon.factory.parts[data.name]

	if factory then
		local texture_switch = factory.texture_switch

		if texture_switch then
			local default = tweak_data.gui.part_texture_switches[data.name] or tweak_data.gui.default_part_texture_switch

			managers.blackmarket:set_part_texture_switch(data.category, data.slot, data.name, default)
		end
	end

	self:reload()
end

function BlackMarketGui:preview_weapon_with_mod_callback(data)
	managers.blackmarket:view_weapon_with_mod(data.category, data.slot, data.name, callback(self, self, "_update_crafting_node"), nil, BlackMarketGui.get_crafting_custom_data())
	self:reload()
end

function BlackMarketGui:remove_mod_callback(data)
	local params = {
		name = managers.localization:text(tweak_data.weapon.factory.parts[data.name].name_id),
		category = data.category,
		slot = data.slot,
		weapon_name = managers.weapon_factory:get_weapon_name_by_factory_id(managers.blackmarket:get_crafted_category(data.category)[data.slot].factory_id),
		add = false,
		ignore_lost_mods = data.free_of_charge
	}

	if data.default_mod then
		-- Nothing
	end

	local replaces, removes = managers.blackmarket:get_modify_weapon_consequence(data.category, data.slot, data.default_mod or data.name, true)
	local weapon_id = managers.blackmarket:get_crafted_category(data.category)[data.slot].weapon_id
	local cost = managers.money:get_weapon_modify_price(weapon_id, data.name, data.global_value) or 0
	params.money = cost > 0 and managers.experience:cash_string(cost)
	params.replaces = replaces
	params.removes = removes
	params.yes_func = callback(self, self, "_dialog_yes", callback(self, self, "_remove_mod_callback", data))
	params.no_func = callback(self, self, "_dialog_no")

	managers.menu:show_confirm_blackmarket_mod(params)
end

function BlackMarketGui:_remove_mod_callback(data)
	managers.menu_component:post_event("item_sell")

	if data.default_mod then
		local global_value = tweak_data.blackmarket.weapon_mods[data.default_mod] and (tweak_data.blackmarket.weapon_mods[data.default_mod].infamous and "infamous" or tweak_data.blackmarket.weapon_mods[data.default_mod].dlc) or "normal"

		managers.blackmarket:buy_and_modify_weapon(data.category, data.slot, global_value, data.default_mod, true, true)
	else
		managers.blackmarket:remove_weapon_part(data.category, data.slot, data.global_value, data.name)
	end

	local factory = tweak_data.weapon.factory.parts[data.name]

	if factory then
		local texture_switch = factory.texture_switch

		if texture_switch then
			managers.blackmarket:set_part_texture_switch(data.category, data.slot, data.name, "1 1")
		end
	end

	self:reload()
end

function BlackMarketGui:preview_weapon_without_mod_callback(data)
	if data.default_mod then
		managers.blackmarket:view_weapon_with_mod(data.category, data.slot, data.default_mod, callback(self, self, "_update_crafting_node"), nil, BlackMarketGui.get_crafting_custom_data())
	else
		managers.blackmarket:view_weapon_without_mod(data.category, data.slot, data.name, callback(self, self, "_update_crafting_node"), nil, BlackMarketGui.get_crafting_custom_data())
	end

	self:reload()
end

function BlackMarketGui:lo_equip_deployable_callback(data)
	data.target_slot = 1

	managers.blackmarket:equip_deployable(data)
	self:reload()
end

function BlackMarketGui:lo_equip_deployable_callback_secondary(data)
	data.target_slot = 2

	managers.blackmarket:equip_deployable(data)
	self:reload()
end

function BlackMarketGui:lo_unequip_deployable_callback(data)
	data.target_slot = managers.blackmarket:equipped_deployable_slot(data.name)

	if not data.target_slot then
		return
	end

	data.name = nil

	managers.blackmarket:equip_deployable(data)

	if data.target_slot == 1 and managers.player:has_category_upgrade("player", "second_deployable") and managers.blackmarket:equipped_deployable(2) then
		local secondary_data = {
			target_slot = 1,
			name = managers.blackmarket:equipped_deployable(2)
		}

		managers.blackmarket:equip_deployable({
			target_slot = 2
		})
		managers.blackmarket:equip_deployable(secondary_data)
	end

	self:reload()
end

function BlackMarketGui:lo_equip_grenade_callback(data)
	managers.blackmarket:equip_grenade(data.name)
	self:reload()
end

function BlackMarketGui:preview_grenade_callback(data)
	managers.menu:open_node(self._preview_node_name, {})
	managers.blackmarket:preview_grenade(data.name)
end

function BlackMarketGui:lo_equip_melee_weapon_callback(data)
	managers.blackmarket:equip_melee_weapon(data.name)
	self:reload()
end

function BlackMarketGui:preview_melee_weapon_callback(data)
	managers.menu:open_node(self._preview_node_name, {})
	managers.blackmarket:preview_melee_weapon(data.name)
end

function BlackMarketGui:add_melee_weapon_favorite(data)
	self:_set_melee_weapon_favorite(data.name, true, data)
end

function BlackMarketGui:remove_melee_weapon_favorite(data)
	self:_set_melee_weapon_favorite(data.name, false, data)
end

function BlackMarketGui:_set_melee_weapon_favorite(melee_weapon_id, favorite, data)
	managers.blackmarket:set_melee_weapon_favorite(melee_weapon_id, favorite)
	self:reload()

	local tab_data = self._data[self._selected]

	if tab_data and data and tab_data.category == data.category and self._tabs[self._selected] then
		local selected = self._tabs[self._selected]._slot_selected or 1
		local new_selected = selected

		for i, item in ipairs(tab_data) do
			if item.name == melee_weapon_id then
				new_selected = i

				break
			end
		end

		local slot = self._tabs[self._selected]:select_slot(new_selected, new_selected == selected)

		self:on_slot_selected(slot)
	end
end

function BlackMarketGui:update_mod_mask()
	if not managers.blackmarket:currently_customizing_mask() then
		managers.menu:back(true)
	else
		managers.blackmarket:view_customized_mask()
	end
end

function BlackMarketGui:_dialog_yes(clbk)
	if clbk and type(clbk) == "function" then
		clbk()
	end
end

function BlackMarketGui:_dialog_no(clbk)
	if clbk and type(clbk) == "function" then
		clbk()
	end
end

function BlackMarketGui:request_texture(texture_path, panel, keep_aspect_ratio, blend_mode)
	if not managers.menu_component then
		return
	end

	local texture_count = managers.menu_component:request_texture(texture_path, callback(self, self, "texture_done_clbk", {
		panel = panel,
		keep_aspect_ratio = keep_aspect_ratio,
		blend_mode = blend_mode
	}))

	table.insert(self._requested_textures, {
		texture_count = texture_count,
		texture = texture_path
	})
end

function BlackMarketGui:unretrieve_textures()
	if self._requested_textures then
		for i, data in pairs(self._requested_textures) do
			managers.menu_component:unretrieve_texture(data.texture, data.texture_count)
		end
	end

	self._requested_textures = {}
end

function BlackMarketGui:texture_done_clbk(params, texture_ids)
	params = params or {}
	local panel = params.panel or params[1]
	local keep_aspect_ratio = params.keep_aspect_ratio
	local blend_mode = params.blend_mode
	local name = params.name or "streamed_texture"

	if not alive(panel) then
		Application:error("[MenuNodeBaseGui:texture_done_clbk] Missing GUI panel", "texture_ids", texture_ids, "params", inspect(params))

		return
	end

	local image = panel:bitmap({
		name = name,
		texture = texture_ids,
		blend_mode = blend_mode
	})

	if keep_aspect_ratio then
		local texture_width = image:texture_width()
		local texture_height = image:texture_height()
		local panel_width = panel:w()
		local panel_height = panel:h()
		local tw = texture_width
		local th = texture_height
		local pw = panel_width
		local ph = panel_height

		if tw == 0 or th == 0 then
			Application:error("[MenuNodeBaseGui:texture_done_clbk] Texture size error!:", "width", tw, "height", th)

			tw = 1
			th = 1
		end

		local sw = math.min(pw, ph * tw / th)
		local sh = math.min(ph, pw / (tw / th))

		image:set_size(math.round(sw), math.round(sh))
		image:set_center(panel:w() * 0.5, panel:h() * 0.5)
	else
		image:set_size(panel:size())
	end
end

function BlackMarketGui:set_tradable_loaded(error)
	MenuCallbackHandler:refresh_node()

	if not self._data.allow_tradable_reload or not self._enabled then
		return
	end

	if error then
		managers.menu:show_inventory_load_fail_dialog()

		return
	end

	if managers.blackmarket:has_new_tradable_items() then
		self:reload()
	end
end

function BlackMarketGui:hide()
	self._old_enabled = self._enabled
	self._enabled = false

	self._ws:panel():hide()
	self._fullscreen_ws:panel():hide()
end

function BlackMarketGui:show()
	self._enabled = self._old_enabled
	self._old_enabled = nil

	self._ws:panel():show()
	self._fullscreen_ws:panel():show()
end

function BlackMarketGui:destroy()
	self:unretrieve_textures()

	for i, tab in pairs(self._tabs) do
		tab:destroy()
	end
end

function BlackMarketGui:close()
	if self._rename_clbk_id then
		managers.network.account:remove_gamepad_text_listener(self._rename_clbk_id)

		self._rename_clbk_id = nil
	end

	if self._keyboard_connected then
		self._keyboard_connected = nil

		self._ws:disconnect_keyboard()
		self._panel:key_press(nil)
	end

	WalletGuiObject.close_wallet(self._panel)
	self:destroy()
	managers.blackmarket:drop_hold_crafted_item()
	self._ws:panel():remove(self._panel)
	self._fullscreen_ws:panel():remove(self._fullscreen_panel)

	if not managers.menu_component._menuscene_info_gui then
		managers.menu:active_menu().renderer.ws:show()
	end

	managers.blackmarket:verfify_crew_loadout()
end

function BlackMarketGui:_pre_reload()
	self._temp_panel = self._panel
	self._temp_fullscreen_panel = self._fullscreen_panel

	WalletGuiObject.close_wallet(self._panel)
	self:destroy()

	self._panel = nil
	self._fullscreen_panel = nil

	if alive(self._temp_panel) then
		self._temp_panel:hide()
	end

	if alive(self._temp_fullscreen_panel) then
		self._temp_fullscreen_panel:hide()
	end
end

function BlackMarketGui:_post_reload()
	self._ws:panel():remove(self._temp_panel)
	self._fullscreen_ws:panel():remove(self._temp_fullscreen_panel)

	self._temp_panel = nil
	self._temp_fullscreen_panel = nil
end

function BlackMarketGui:reload()
	if self._rename_clbk_id then
		managers.network.account:remove_gamepad_text_listener(self._rename_clbk_id)

		self._rename_clbk_id = nil
	end

	if self._keyboard_connected then
		self._keyboard_connected = nil

		self._ws:disconnect_keyboard()
		self._panel:key_press(nil)
	end

	self:_pre_reload()

	self._tabs = {}
	self._btns = {}
	self._equipped_comparision_data = {}

	BlackMarketGui._setup(self, false, self._data)
	self:_post_reload()
end

function BlackMarketGui:get_safe_for_economy_item(id)
	local function find_safe_name(id)
		for safe_id, safe_data in pairs(tweak_data.economy.contents) do
			for category, tbl in pairs(safe_data.contains) do
				for _, item_id in ipairs(tbl) do
					if id == item_id then
						return safe_id
					end
				end
			end
		end
	end

	local safe_id = find_safe_name(id)

	for content_id, safe_data in pairs(tweak_data.economy.contents) do
		if safe_data.contains.contents and table.contains(safe_data.contains.contents, safe_id) then
			safe_id = content_id
		end
	end

	return tweak_data.economy.safes[safe_id], safe_id
end

function BlackMarketGui:create_preload_ws()
	if self._preload_ws then
		return
	end

	self._preload_ws = managers.gui_data:create_fullscreen_workspace()
	local panel = self._preload_ws:panel()

	panel:set_layer(tweak_data.gui.DIALOG_LAYER)

	local new_script = {
		progress = 1
	}

	function new_script.step_progress()
		new_script.set_progress(new_script.progress + 1)
	end

	function new_script.set_progress(progress)
		new_script.progress = progress
		local square_panel = panel:child("square_panel")
		local progress_rect = panel:child("progress")

		if progress == 0 then
			progress_rect:hide()
		end

		for i, child in ipairs(square_panel:children()) do
			child:set_color(i < progress and Color.white or Color(0.3, 0.3, 0.3))

			if i == progress then
				progress_rect:set_world_center(child:world_center())
				progress_rect:show()
			end
		end
	end

	panel:set_script(new_script)

	local square_panel = panel:panel({
		layer = 1,
		name = "square_panel"
	})
	local num_squares = 0

	for i, preload in ipairs(self._preloading_list) do
		num_squares = num_squares + 1
	end

	local rows = math.max(1, math.ceil(num_squares / 8))
	local next_row_at = math.ceil(num_squares / rows)
	local row_index = 0
	local x = 0
	local y = 0
	local last_rect = nil
	local max_w = 0
	local max_h = 0

	for i = 1, num_squares, 1 do
		row_index = row_index + 1
		last_rect = square_panel:rect({
			blend_mode = "add",
			h = 15,
			w = 15,
			x = x,
			y = y,
			color = Color(0.3, 0.3, 0.3)
		})
		x = x + 24
		max_w = math.max(max_w, last_rect:right())
		max_h = math.max(max_h, last_rect:bottom())

		if row_index == next_row_at then
			row_index = 0
			y = y + 24
			x = 0
		end
	end

	square_panel:set_size(max_w, max_h)
	panel:rect({
		blend_mode = "add",
		name = "progress",
		h = 19,
		w = 19,
		layer = 2,
		color = Color(0.3, 0.3, 0.3)
	})

	local bg = panel:rect({
		alpha = 0.8,
		color = Color.black
	})
	local width = square_panel:w() + 19
	local height = square_panel:h() + 19

	bg:set_size(width, height)
	bg:set_center(panel:w() / 2, panel:h() / 2)
	square_panel:set_center(bg:center())

	local box_panel = panel:panel({
		layer = 2
	})

	box_panel:set_shape(bg:shape())
	BoxGuiObject:new(box_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	panel:script().set_progress(1)

	local function fade_in_animation(panel)
		panel:hide()
		coroutine.yield()
		panel:show()
	end

	panel:animate(fade_in_animation)
end

function BlackMarketGui.blur_panel(panel, bg_alpha)
	panel:bitmap({
		texture = "guis/textures/test_blur_df",
		layer = -1,
		halign = "scale",
		alpha = 1,
		render_template = "VertexColorTexturedBlur3D",
		valign = "scale",
		w = panel:w(),
		h = panel:h()
	})
	panel:rect({
		valign = "scale",
		halign = "scale",
		color = Color.black,
		alpha = bg_alpha or 0.5
	})
end

function BlackMarketGui:buy_crew_item_callback(data)
	local cost = managers.blackmarket:crew_item_cost(data.name)
	local macros = {
		item = data.name_localized,
		cost = cost
	}
	local coins = 0
	coins = managers.custom_safehouse:coins()

	if cost <= coins then
		local dialog_data = {}

		if data.category == "ability" then
			dialog_data.title = managers.localization:text("dialog_crew_ability_unlock_title", macros)
			dialog_data.text = managers.localization:text("dialog_crew_ability_unlock_text", macros)
		else
			dialog_data.title = managers.localization:text("dialog_crew_boost_unlock_title", macros)
			dialog_data.text = managers.localization:text("dialog_crew_boost_unlock_text", macros)
		end

		local yes_button = {
			text = managers.localization:text("dialog_yes"),
			callback_func = callback(self, self, "_confirm_buy_crew_item_callback", data)
		}
		local no_button = {
			text = managers.localization:text("dialog_cancel"),
			cancel_button = true
		}
		dialog_data.button_list = {
			yes_button,
			no_button
		}

		managers.system_menu:show(dialog_data)
	else
		local dialog_data = {
			title = managers.localization:text("dialog_crew_item_cant_afford_title", macros),
			text = managers.localization:text("dialog_crew_item_cant_afford_text", macros)
		}
		local ok_button = {
			text = managers.localization:text("dialog_ok")
		}
		dialog_data.button_list = {
			ok_button
		}

		managers.system_menu:show(dialog_data)
	end
end

function BlackMarketGui:_confirm_buy_crew_item_callback(data)
	managers.menu_component:post_event("item_sell")
	managers.blackmarket:buy_crew_item(data.name)
	self:reload()
end
