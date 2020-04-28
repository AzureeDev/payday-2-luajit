require("lib/managers/menu/items/MenuItemMultiChoice")
require("lib/managers/menu/ExtendedUiElemets")
require("lib/managers/menu/BoxGuiObject")

MenuItemGrid = MenuItemGrid or class(MenuItemMultiChoice)
MenuItemGrid.TYPE = "grid"
MenuItemGrid.INPUT_ON_HIJACK = true
local ids_texture = Idstring("texture")

function MenuItemGrid:init(data_node, parameters)
	CoreMenuItem.Item.init(self, data_node, parameters)

	self._type = self.TYPE
	self._columns = parameters.columns or 1
	self._rows = parameters.rows or 1
	self._options = {}
	self._current_index = 1
	self._selection_index = 1
	self._scroll_y = 1
	self._all_options = {}
	self._requested_textures = {}

	if parameters.sort_callback then
		self._sort_callback_name_list = string.split(parameters.sort_callback, " ")
	end

	if data_node then
		for _, c in ipairs(data_node) do
			local type = c._meta

			if type == "option" then
				local option = CoreMenuItemOption.ItemOption:new(c)

				table.insert(self._all_options, option)

				local visible_callback = c.visible_callback

				if visible_callback then
					option.visible_callback_names = string.split(visible_callback, " ")
				end

				option.enabled = true
				local enabled_callback = c.enabled_callback

				if enabled_callback then
					option.enabled_callback_names = string.split(enabled_callback, " ")
				end

				option.disabled_icon = c.disabled_icon
				option.disabled_icon_callback = c.disabled_icon_callback
			end
		end
	end

	self._enabled = true

	self:_show_options(nil)

	self._selection_index = self._current_index
end

function MenuItemGrid:set_enabled(enabled)
	MenuItemGrid.super.set_enabled(self, enabled)
end

function MenuItemGrid:sort()
	if self._sort_callback_list then
		for _, sort_callback in ipairs(self._sort_callback_list) do
			table.sort(self._all_options, sort_callback)
		end
	end
end

function MenuItemGrid:set_callback_handler(callback_handler)
	MenuItemGrid.super.set_callback_handler(self, callback_handler)

	local icon, texture_rect = nil

	for _, option in ipairs(self._all_options) do
		if option.enabled_callback_names then
			for _, enabled_callback_name in pairs(option.enabled_callback_names) do
				if callback_handler[enabled_callback_name] then
					if not callback_handler[enabled_callback_name](self, option) then
						option.enabled = false

						if not option.disabled_icon and option.disabled_icon_callback then
							icon, texture_rect = callback_handler[option.disabled_icon_callback](self, option)
							option.disabled_icon = icon
							option.disabled_texture_rect = texture_rect
						end

						break
					end
				else
					Application:error("[MenuItemGrid:set_callback_handler] inexistent callback:", enabled_callback_name)
				end
			end
		end
	end

	if self._sort_callback_name_list then
		for _, sort_callback_name in pairs(self._sort_callback_name_list) do
			self._sort_callback_list = self._sort_callback_list or {}

			table.insert(self._sort_callback_list, callback(callback_handler, callback_handler, sort_callback_name))
		end
	end

	self:sort()
end

function MenuItemGrid:visible(...)
	return MenuItemGrid.super.visible(self, ...)
end

function MenuItemGrid:_show_options(callback_handler)
	local selected_value = self:selected_option() and self:selected_option():value()
	self._options = {}

	for _, option in ipairs(self._all_options) do
		local show = true

		if callback_handler and option.visible_callback_names then
			for _, id in ipairs(option.visible_callback_names) do
				if not callback_handler[id](callback_handler, option) then
					show = false

					break
				end
			end
		end

		if show then
			option:parameters().exclude = nil

			table.insert(self._options, option)
		else
			option:parameters().exclude = true
		end
	end

	if selected_value then
		self:set_current_index(1)
		self:set_value(selected_value)
	end

	if self._selection_index > #self._options then
		self._selection_index = self._current_index
	end
end

function MenuItemGrid:add_option(option)
	MenuItemGrid.super.add_option(self, option)
	self:sort()
end

function MenuItemGrid:clear_options()
	MenuItemGrid.super.clear_options(self)
end

function MenuItemGrid:options()
	return MenuItemGrid.super.options(self)
end

function MenuItemGrid:get_option(value)
	for i, option in ipairs(self._all_options) do
		if option:parameters().value == value then
			return option
		end
	end
end

function MenuItemGrid:selected_option()
	return MenuItemGrid.super.selected_option(self)
end

function MenuItemGrid:current_index()
	return MenuItemGrid.super.current_index(self)
end

function MenuItemGrid:set_current_index(index)
	MenuItemGrid.super.set_current_index(self, index)
end

function MenuItemGrid:set_value(value)
	MenuItemGrid.super.set_value(self, value)
end

function MenuItemGrid:value()
	return MenuItemGrid.super.value(self)
end

function MenuItemGrid:_highest_option_index()
	return MenuItemGrid.super._highest_option_index(self)
end

function MenuItemGrid:_lowest_option_index()
	return MenuItemGrid.super._lowest_option_index(self)
end

function MenuItemGrid:reload(row_item, node)
	if not row_item then
		return
	end

	if node.localize_strings and self:selected_option():parameters().localize ~= false then
		row_item.option_text = managers.localization:text(self:selected_option():parameters().text_id)
	else
		row_item.option_text = self:selected_option():parameters().text_id
	end

	return true
end

function MenuItemGrid:next()
	return MenuItemGrid.super.next(self)
end

function MenuItemGrid:previous()
	return MenuItemGrid.super.previous(self)
end

function MenuItemGrid:input_focus()
	return 1
end

function MenuItemGrid:move_x(x, row_item)
	self._selection_index = (self._selection_index + x - 1) % #self._options + 1

	return true

	local current_row = math.ceil(self._selection_index / self._columns)
	local new_selection_index = self._selection_index + x
	local new_row = math.ceil(new_selection_index / self._columns)

	if new_row == current_row and new_selection_index <= #self._options then
		self._selection_index = new_selection_index

		return true
	end

	return false
end

function MenuItemGrid:move_y(y, row_item)
	local current_row = math.ceil(self._selection_index / self._columns)
	local max_row = math.ceil(#self._options / self._columns)
	local new_selection_index = self._selection_index + self._columns * y

	if new_selection_index > 0 and new_selection_index <= #self._options then
		self._selection_index = new_selection_index
		local selection_option = self._options[self._selection_index]

		row_item.scroll_panel:scroll_to_show(selection_option.gui_panel:top(), selection_option.gui_panel:bottom())

		return true
	elseif new_selection_index > #self._options and current_row ~= max_row then
		self._selection_index = #self._options
		local selection_option = self._options[self._selection_index]

		row_item.scroll_panel:scroll_to_show(selection_option.gui_panel:top(), selection_option.gui_panel:bottom())

		return true
	end

	return false
end

function MenuItemGrid:set_to_selection()
	if self._selection_index ~= self._current_index then
		self:set_current_index(self._selection_index)

		return true
	end

	return false
end

function MenuItemGrid:scroll_bar_grabbed(row_item)
	return row_item.scroll_panel:scroll_item()._grabbed_scroll_bar
end

function MenuItemGrid:wheel_scroll_start(dy, row_item)
	local scroll_item = row_item.scroll_panel:scroll_item()

	scroll_item:perform_scroll(scroll_item.SCROLL_SPEED * TimerManager:main():delta_time() * 200, dy)
end

function MenuItemGrid:mouse_released(button, x, y, row_item)
	row_item.grid_panel:mouse_released(button, x, y)

	if self:scroll_bar_grabbed(row_item) then
		return
	end
end

function MenuItemGrid:mouse_pressed(button, x, y, row_item)
	local delay_down = 0.1
	local delay_pressed = 0.2
	local active_menu = managers.menu:active_menu()

	if not managers.menu:active_menu() then
		return
	end

	local logic = active_menu.logic
	local input = active_menu.input
	local controller = input:get_controller_class()
	local node_gui = row_item.node_gui
	local mouse_click = button == Idstring("0")

	if node_gui and node_gui._listening_to_input then
		return
	end

	row_item.grid_panel:mouse_pressed(button, x, y)

	if self:scroll_bar_grabbed(row_item) then
		return
	end

	local inside_selection = self._options[self._selection_index].gui_panel:inside(x, y)

	if (controller:get_input_pressed("confirm") or mouse_click and inside_selection) and self:set_to_selection() then
		input:post_event("selection_next")
		logic:trigger_item(true, self)
	end
end

function MenuItemGrid:mouse_moved(x, y, row_item)
	local hover, cursor_type = row_item.grid_panel:mouse_moved(self, x, y)

	if self:scroll_bar_grabbed(row_item) then
		return cursor_type
	end

	if not self._options[self._selection_index].gui_panel:inside(x, y) then
		for index, option in ipairs(self._options) do
			if self._selection_index ~= index and option.gui_panel:inside(x, y) then
				self._selection_index = index

				self:update_selection_position(row_item)

				return "link"
			end
		end
	else
		return "link"
	end

	return cursor_type
end

function MenuItemGrid:setup_gui(node_gui, row_item)
	local safe_rect = managers.gui_data:scaled_size()
	local align_line_padding = self:parameters().align_line_padding or node_gui:align_line_padding()
	local gui_width = safe_rect.width - node_gui:_mid_align(self:parameters().align_line_proportions) - align_line_padding * 2
	local slot_width = (gui_width - 10) / self._columns
	local slot_height = slot_width * (self:parameters().height_aspect or 1)
	local gui_height = slot_height * self._rows
	row_item.gui_panel = node_gui.item_panel:panel({
		w = gui_width,
		h = gui_height
	})
	row_item.grid_panel = ExtendedPanel:new(row_item.gui_panel)
	row_item.scroll_panel = ScrollableList:new(row_item.grid_panel, {
		input = true,
		input_focus = true,
		scrollbar_y_padding = 0,
		x_padding = 0.0001,
		bar_minimum_size = 0,
		y_padding = 0,
		scrollbar_padding = 2,
		scroll_w = 4,
		layer = node_gui.layers.items,
		update = self._scroll_update,
		w = gui_width,
		h = gui_height
	}, {
		padding = 0
	})
	local scroll_item = row_item.scroll_panel:scroll_item()
	local scroll_canvas = row_item.scroll_panel:canvas()
	local scroll_placer = scroll_canvas:placer()
	local box = BoxGuiObject:new(scroll_item:scroll_panel(), {
		w = scroll_canvas:w(),
		sides = {
			0,
			0,
			0,
			0
		}
	})
	scroll_item.scroll_indicators = {
		up_no_scroll = BoxGuiObject:new(box._panel, {
			sides = {
				0,
				0,
				0,
				0
			}
		}),
		up_scroll = BoxGuiObject:new(box._panel, {
			sides = {
				0,
				0,
				2,
				0
			}
		}),
		down_no_scroll = BoxGuiObject:new(box._panel, {
			sides = {
				0,
				0,
				0,
				0
			}
		}),
		down_scroll = BoxGuiObject:new(box._panel, {
			sides = {
				0,
				0,
				0,
				2
			}
		})
	}
	row_item.marker_panel = row_item.grid_panel:panel({
		name = "marker_panel",
		layer = node_gui.layers.items + 3
	})
	row_item.selection_panel = scroll_canvas:panel({
		name = "selection_panel",
		w = slot_width,
		h = slot_height,
		layer = node_gui.layers.items + 2
	})
	row_item.current_panel = scroll_canvas:panel({
		name = "current_panel",
		w = slot_width,
		h = slot_height,
		layer = node_gui.layers.items + 2
	})
	row_item.gui_boxes = {}

	self:_create_gui_box(row_item, "marker", row_item.marker_panel, 2, false)
	self:_create_gui_box(row_item, "current", row_item.current_panel, 1)
	self:_create_gui_box(row_item, "selection", row_item.selection_panel, 2)
	row_item.gui_boxes.selection:set_visible(self.highlighted)

	local color, texture_path, parameters, column, row = nil
	local current_row = 0

	for index, option in ipairs(self._options) do
		parameters = option:parameters()
		column = (index - 1) % self._columns
		row = math.floor((index - 1) / self._columns)

		if row ~= current_row then
			scroll_placer:new_row()

			current_row = row
		end

		option.gui_panel = scroll_canvas:panel({
			alpha = 1,
			w = slot_width,
			h = slot_height
		})

		scroll_placer:add_right(option.gui_panel)

		if parameters.texture then
			texture_path = Idstring(parameters.texture)

			if table.contains(self._requested_textures, texture_path) then
				self:option_texture_loaded_clbk(option, texture_path)
			elseif DB:has(ids_texture, texture_path) then
				TextureCache:request(texture_path, "NORMAL", callback(self, self, "option_texture_loaded_clbk", option), 100)
			end
		end

		if not option.enabled and option.disabled_icon then
			option.gui_disabled_icon = option.gui_panel:bitmap({
				blend_mode = "normal",
				layer = 1,
				y = 32,
				w = 32,
				texture = option.disabled_icon,
				texture_rect = option.disabled_texture_rect,
				color = parameters.disabled_icon_color or tweak_data.screen_colors.important_1
			})

			option.gui_disabled_icon:set_center(option.gui_panel:w() / 2, option.gui_panel:h() / 2)
		end
	end

	if self.scroll_y then
		scroll_item:scroll_to(self.scroll_y)
	end

	local current_option = self._options[self._current_index]

	if current_option then
		row_item.scroll_panel:scroll_to_show(current_option.gui_panel:top(), current_option.gui_panel:bottom())
	end

	scroll_item:reset_scroll_indicator_alphas()
	self:update_selection_position(row_item)

	if row_item.gui_info_panel then
		node_gui:_align_item_gui_info_panel(row_item.gui_info_panel)
		node_gui:_align_info_panel(row_item)
	end

	return true
end

function MenuItemGrid:_scroll_update(dt)
	local element, step = nil

	for element_name, data in pairs(self._alphas) do
		step = dt == -1 and 1 or dt * data.speed
		data.current = math.step(data.current, data.target, step)
		element = self:panel():child(element_name)

		if alive(element) then
			element:set_alpha(data.current)
		end
	end

	if self._alphas.scroll_up_indicator_arrow.target == 1 then
		self.scroll_indicators.up_scroll:show()
		self.scroll_indicators.up_no_scroll:hide()
	else
		self.scroll_indicators.up_scroll:hide()
		self.scroll_indicators.up_no_scroll:show()
	end

	if self._alphas.scroll_down_indicator_arrow.target == 1 then
		self.scroll_indicators.down_scroll:show()
		self.scroll_indicators.down_no_scroll:hide()
	else
		self.scroll_indicators.down_scroll:hide()
		self.scroll_indicators.down_no_scroll:show()
	end
end

function MenuItemGrid:close(row_item)
	for _, ids in ipairs(self._requested_textures) do
		TextureCache:unretrieve(ids)
	end

	self._requested_textures = {}
end

function MenuItemGrid:option_texture_loaded_clbk(option, texture_idstring)
	option.gui_icon = option.gui_panel:bitmap({
		blend_mode = "normal",
		texture = texture_idstring
	})

	if not table.contains(self._requested_textures, texture_idstring) then
		table.insert(self._requested_textures, texture_idstring)
	end

	if not option.enabled then
		option.gui_icon:set_color(Color(0.5, 0.5, 0.5))
	end

	self:_update_option_icon_size(option)
end

function MenuItemGrid:_update_option_icon_size(option)
	if not option.gui_icon then
		return
	end

	local texture_width = option.gui_icon:texture_width()
	local texture_height = option.gui_icon:texture_height()
	local panel_width = option.gui_panel:width()
	local panel_height = option.gui_panel:height()
	local aspect = panel_width / panel_height
	local sw = math.min(texture_width, texture_height * aspect)
	local sh = math.min(texture_height, texture_width / aspect)
	local dw = texture_width / sw
	local dh = texture_height / sh

	option.gui_icon:set_size(dw * panel_width, dh * panel_height)
	option.gui_icon:set_center(panel_width / 2, panel_height / 2)
end

function MenuItemGrid:clear_gui(row_item)
	if row_item.scroll_panel then
		self.scroll_y = -row_item.scroll_panel:canvas():y()
	end

	for _, option in ipairs(self._all_options) do
		if option.gui_panel then
			option.gui_panel:parent():remove(option.gui_panel)

			option.gui_panel = nil
			option.gui_icon = nil
			option.gui_disabled_icon = nil
		end
	end
end

function MenuItemGrid:highlight_row_item(node, row_item, mouse_over)
	if row_item.gui_info_panel then
		row_item.gui_info_panel:set_visible(true)
	end

	row_item.gui_boxes.marker:hide()
	row_item.gui_boxes.selection:show()

	self._selection_index = self._current_index

	self:update_selection_position(row_item)

	local selection_option = self._options[self._selection_index]

	row_item.scroll_panel:scroll_to_show(selection_option.gui_panel:top(), selection_option.gui_panel:bottom())

	return true
end

function MenuItemGrid:fade_row_item(node, row_item, mouse_over)
	if row_item.gui_info_panel then
		row_item.gui_info_panel:set_visible(false)
	end

	row_item.gui_boxes.marker:hide()
	row_item.gui_boxes.selection:hide()

	return true
end

function MenuItemGrid:align_panel(row_item, item_panel)
	row_item.gui_panel:set_center_x(item_panel:w() / 2)

	return true
end

function MenuItemGrid:align_marker(row_item, marker_data, node_gui)
	marker_data.gradient:hide()
	marker_data.marker:hide()

	return true
end

function MenuItemGrid:update_selection_position(row_item)
	local current_option = self._options[self._current_index]

	row_item.current_panel:set_position(current_option.gui_panel:position())

	local selection_option = self._options[self._selection_index]

	row_item.selection_panel:set_position(selection_option.gui_panel:position())
end

function MenuItemGrid:_create_gui_box(row_item, box_name, panel, sides, visible)
	if row_item.gui_boxes[box_name] then
		row_item.gui_boxes[box_name]:close()

		row_item.gui_boxes[box_name] = nil
	end

	row_item.gui_boxes[box_name] = BoxGuiObject:new(panel, {
		sides = {
			sides,
			sides,
			sides,
			sides
		}
	})

	if visible ~= nil then
		row_item.gui_boxes[box_name]:set_visible(visible)
	end
end
