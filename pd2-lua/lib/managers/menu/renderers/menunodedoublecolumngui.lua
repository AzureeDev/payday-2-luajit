MenuNodeDoubleColumnGui = MenuNodeDoubleColumnGui or class(MenuNodeGui)

function MenuNodeDoubleColumnGui:init(node, layer, parameters)
	MenuNodeDoubleColumnGui.super.init(self, node, layer, parameters)
end

function MenuNodeDoubleColumnGui:_setup_size(node)
	MenuNodeDoubleColumnGui.super._setup_size(self)

	local safe_width = self:_scaled_size().width
	local item_width = safe_width * (1 - self._align_line_proportions)
	local column_ratio = tonumber(node:parameters().column_ratio) or 0.5
	self._split_size = 10
	self._width_primary = item_width * (1 - column_ratio) - self._split_size * 0.5
	self._width_secondary = item_width * column_ratio - self._split_size * 0.5

	for _, row_item in pairs(self.primary_row_items) do
		if row_item.item:parameters().both_column then
			row_item.gui_panel:set_width(item_width)
			row_item.menu_unselected:set_width(item_width)
		elseif not row_item.item:parameters().back then
			row_item.gui_panel:set_width(self._width_primary)
			row_item.menu_unselected:set_width(self._width_primary)
		end
	end

	for _, row_item in pairs(self.secondary_row_items) do
		if row_item.item:parameters().both_column then
			row_item.gui_panel:set_width(item_width)
			row_item.menu_unselected:set_width(item_width)
		elseif not row_item.item:parameters().back then
			row_item.gui_panel:set_width(self._width_secondary)
			row_item.menu_unselected:set_width(self._width_secondary)
		end
	end
end

function MenuNodeDoubleColumnGui:_set_item_positions()
	local total_height = self:_item_panel_height()
	local current_y = self.height_padding
	local current_item_height = 0
	local scaled_size = managers.gui_data:scaled_size()
	local start_x = scaled_size.width * self._align_line_proportions

	for _, row_item in pairs(self.primary_row_items) do
		local item_width = self._width_primary
		local item_left = start_x + self._width_secondary + self._split_size * 0.5

		if row_item.item:parameters().both_column then
			item_width = scaled_size.width * (1 - self._align_line_proportions)
			item_left = start_x
		end

		if not row_item.item:parameters().back then
			row_item.position.y = current_y

			row_item.gui_panel:set_y(row_item.position.y)
			row_item.menu_unselected:set_left(item_left)
			row_item.menu_unselected:set_h(64 * row_item.gui_panel:h() / 32)
			row_item.menu_unselected:set_center_y(row_item.gui_panel:center_y())
			row_item.menu_unselected:set_width(item_width)
			row_item.gui_panel:set_right(row_item.menu_unselected:right())

			if row_item.current_of_total then
				row_item.current_of_total:set_w(200)
				row_item.current_of_total:set_center_y(row_item.menu_unselected:center_y())
				row_item.current_of_total:set_right(row_item.menu_unselected:right() - self._align_line_padding)
			end

			row_item.item:on_item_position(row_item, self)

			if alive(row_item.icon) then
				local left = row_item.gui_panel:left()
				local right = row_item.gui_panel:right()

				if row_item.gui_panel.set_text then
					local x, y, w, h = row_item.gui_panel:text_rect()
					left = x
					right = x + w
				end

				if row_item.item:parameters().icon_align == "left" then
					row_item.icon:set_right(left)
				else
					row_item.icon:set_left(right)
				end

				row_item.icon:set_center_y(row_item.gui_panel:center_y())
				row_item.icon:set_color(row_item.gui_panel:color())
			end

			local x, y, w, h = row_item.gui_panel:shape()
			current_item_height = h + self.spacing
			current_y = current_y + current_item_height
		end
	end

	current_y = self.height_padding
	current_item_height = 0

	for _, row_item in pairs(self.secondary_row_items) do
		local item_width = self._width_secondary
		local item_left = start_x

		if row_item.item:parameters().both_column then
			item_width = scaled_size.width * (1 - self._align_line_proportions)
			item_left = start_x
		end

		if not row_item.item:parameters().back then
			row_item.position.y = current_y

			row_item.gui_panel:set_y(row_item.position.y)
			row_item.menu_unselected:set_left(item_left)
			row_item.menu_unselected:set_h(64 * row_item.gui_panel:h() / 32)
			row_item.menu_unselected:set_center_y(row_item.gui_panel:center_y())
			row_item.menu_unselected:set_width(item_width)
			row_item.gui_panel:set_right(row_item.menu_unselected:right())

			if row_item.current_of_total then
				row_item.current_of_total:set_w(200)
				row_item.current_of_total:set_center_y(row_item.menu_unselected:center_y())
				row_item.current_of_total:set_right(row_item.menu_unselected:right() - self._align_line_padding)
			end

			row_item.item:on_item_position(row_item, self)

			if alive(row_item.icon) then
				local left = row_item.gui_panel:left()
				local right = row_item.gui_panel:right()

				if row_item.gui_panel.set_text then
					local x, y, w, h = row_item.gui_panel:text_rect()
					left = x
					right = x + w
				end

				if row_item.item:parameters().icon_align == "left" then
					row_item.icon:set_right(left)
				else
					row_item.icon:set_left(right)
				end

				row_item.icon:set_center_y(row_item.gui_panel:center_y())
				row_item.icon:set_color(row_item.gui_panel:color())
			end

			local x, y, w, h = row_item.gui_panel:shape()
			current_item_height = h + self.spacing
			current_y = current_y + current_item_height
		end
	end

	for _, row_item in pairs(self.primary_row_items) do
		if not row_item.item:parameters().back and not row_item.item:parameters().pd2_corner then
			row_item.item:on_item_positions_done(row_item, self)
		end
	end

	for _, row_item in pairs(self.secondary_row_items) do
		if not row_item.item:parameters().back and not row_item.item:parameters().pd2_corner then
			row_item.item:on_item_positions_done(row_item, self)
		end
	end

	if self._primary_title then
		self._primary_title:set_width(self._width_primary)
		self._primary_title:set_left(start_x + self._width_secondary + self._split_size * 0.5)
	end

	if self._secondary_title then
		self._secondary_title:set_width(self._width_secondary)
		self._secondary_title:set_left(start_x)
	end
end

function MenuNodeDoubleColumnGui:_setup_item_rows(node)
	if node:parameters().title and not self.safe_rect_panel:child("primary_title") then
		self._primary_title = self.safe_rect_panel:text({
			name = "primary_title",
			layer = 99999,
			text = utf8.to_upper(managers.localization:text(node:parameters().title)),
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size
		})
	end

	if node:parameters().secondary_title and not self.safe_rect_panel:child("secondary_title") then
		self._secondary_title = self.safe_rect_panel:text({
			name = "secondary_title",
			layer = 99999,
			text = utf8.to_upper(managers.localization:text(node:parameters().secondary_title)),
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size
		})
	end

	self.primary_row_items = {}
	self.secondary_row_items = {}
	local items = node:items()
	local i = 0

	for _, item in pairs(items) do
		if item:visible() then
			item:parameters().gui_node = self
			local item_name = item:name()
			local item_text = "menu item missing 'text_id'"

			if item:parameters().no_text then
				item_text = nil
			end

			local help_text = nil
			local params = item:parameters()

			if params.text_id then
				if self.localize_strings and params.localize ~= false and params.localize ~= "false" then
					item_text = managers.localization:text(params.text_id)
				else
					item_text = params.text_id
				end
			end

			if params.help_id then
				if self.localize_strings and params.localize_help ~= false and params.localize_help ~= "false" then
					help_text = managers.localization:text(params.help_id)
				else
					help_text = params.help_id
				end
			end

			local row_item = {}

			if params.both_column and params.both_column ~= "false" or params.back then
				table.insert(self.secondary_row_items, row_item)
				table.insert(self.primary_row_items, row_item)
			elseif params.left_column and params.left_column ~= "false" then
				table.insert(self.secondary_row_items, row_item)
			else
				table.insert(self.primary_row_items, row_item)
			end

			row_item.item = item
			row_item.node = node
			row_item.node_gui = self
			row_item.type = item._type
			row_item.name = item_name
			row_item.position = {
				x = 0,
				y = self.font_size * i + self.spacing * (i - 1)
			}
			row_item.color = params.color or self.row_item_color
			row_item.row_item_color = params.row_item_color
			row_item.hightlight_color = params.hightlight_color
			row_item.disabled_color = params.disabled_color or self.row_item_disabled_text_color
			row_item.marker_color = params.marker_color or self.marker_color
			row_item.marker_disabled_color = params.marker_disabled_color or self.marker_disabled_color
			row_item.font = params.font or self.font
			row_item.font_size = params.font_size or self.font_size
			row_item.text = item_text
			row_item.help_text = help_text
			row_item.align = params.align or self.align or "left"
			row_item.halign = params.halign or self.halign or "left"
			row_item.vertical = params.vertical or self.vertical or "center"
			row_item.to_upper = params.to_upper == nil and self.to_upper or params.to_upper or false
			row_item.color_ranges = params.color_ranges or self.color_ranges or nil

			self:_create_menu_item(row_item)
			self:reload_item(item)

			i = i + 1
		end
	end

	node:select_item()

	self._highlighted_item = node:selected_item()
	self.row_items = {}

	for _, v in ipairs(self.primary_row_items) do
		table.insert(self.row_items, v)
	end

	for _, v in ipairs(self.secondary_row_items) do
		table.insert(self.row_items, v)
	end

	self:_setup_size(node)
	self:scroll_setup()
	self:_set_item_positions()
	self:highlight_item(node:selected_item())
end

function MenuNodeDoubleColumnGui:_align_marker(row_item)
	MenuNodeDoubleColumnGui.super._align_marker(self, row_item)
	self._marker_data.marker:set_width(row_item.menu_unselected:width())

	if self:left_active() then
		self._marker_data.marker:set_right(row_item.gui_panel:right())
	end
end

function MenuNodeDoubleColumnGui:left_active()
	local selected_item = self._highlighted_item or self.node:selected_item()

	if selected_item then
		local column = self:get_item_index(selected_item)

		return column ~= "primary"
	end

	return false
end

function MenuNodeDoubleColumnGui:row_item(item)
	local item_name = item:name()

	for _, row_item in ipairs(self.primary_row_items) do
		if row_item.name == item_name then
			return row_item
		end
	end

	for _, row_item in ipairs(self.secondary_row_items) do
		if row_item.name == item_name then
			return row_item
		end
	end

	return nil
end

function MenuNodeDoubleColumnGui:_clear_column(column)
	for i, row_item in ipairs(column) do
		if alive(row_item.gui_panel) then
			row_item.gui_panel:parent():remove(row_item.gui_panel)

			row_item.gui_panel = nil

			if alive(row_item.menu_unselected) then
				row_item.menu_unselected:parent():remove(row_item.menu_unselected)

				row_item.menu_unselected = nil
			end
		end

		if alive(row_item.gui_info_panel) then
			self.safe_rect_panel:remove(row_item.gui_info_panel)
		end

		if alive(row_item.icon) then
			row_item.icon:parent():remove(row_item.icon)
		end

		if alive(row_item.gui_pd2_panel) then
			row_item.gui_pd2_panel:parent():remove(row_item.gui_pd2_panel)
		end

		column[i] = nil
	end

	column = {}
end

function MenuNodeDoubleColumnGui:_clear_gui()
	self:_clear_column(self.primary_row_items)
	self:_clear_column(self.secondary_row_items)
end

function MenuNodeDoubleColumnGui:_item_panel_height()
	local primary_height = self.height_padding * 2

	for _, row_item in pairs(self.primary_row_items) do
		if not row_item.item:parameters().back and not row_item.item:parameters().pd2_corner then
			local x, y, w, h = row_item.gui_panel:shape()
			primary_height = primary_height + h + self.spacing
		end
	end

	local secondary_height = self.height_padding * 2

	for _, row_item in pairs(self.secondary_row_items) do
		if not row_item.item:parameters().back and not row_item.item:parameters().pd2_corner then
			local x, y, w, h = row_item.gui_panel:shape()
			secondary_height = secondary_height + h + self.spacing
		end
	end

	return secondary_height < primary_height and primary_height or secondary_height
end

function MenuNodeDoubleColumnGui:highlight_item(item, mouse_over)
	local column = self:get_item_index(item)

	MenuNodeDoubleColumnGui.super.highlight_item(self, item, mouse_over)
end

function MenuNodeDoubleColumnGui:input_focus()
	return 1
end

function MenuNodeDoubleColumnGui:update(t, dt)
	MenuNodeDoubleColumnGui.super.update(self, t, dt)

	if managers.menu:is_pc_controller() then
		local scaled_size = managers.gui_data:scaled_size()
		local start_x = scaled_size.width * self._align_line_proportions
		local width_primary = self._width_primary - self._split_size * 0.5
		local split = start_x + self._width_secondary
		local mouse_x = managers.mouse_pointer:modified_mouse_pos()

		if not self._left_active and mouse_x <= split then
			self.row_items = self.secondary_row_items
			self._left_active = true
		elseif self._left_active and split < mouse_x then
			self.row_items = self.primary_row_items
			self._left_active = false
		end
	end
end

function MenuNodeDoubleColumnGui:move_up()
	local selected_item = self.node:selected_item() or self._highlighted_item or self.node:item(self.node:default_item_name())
	local column, index = self:get_item_index(selected_item)

	if index then
		local row_list = column == "primary" and self.primary_row_items or self.secondary_row_items
		local prev_index = (index - 2) % #row_list + 1
		local prev_item = row_list[prev_index].item

		managers.menu:active_menu().logic:select_item(prev_item:name())

		return true
	end

	local item = self.primary_row_items[1].item

	managers.menu:active_menu().logic:select_item(item:name())

	return true
end

function MenuNodeDoubleColumnGui:move_down()
	local selected_item = self.node:selected_item() or self._highlighted_item or self.node:item(self.node:default_item_name())
	local column, index = self:get_item_index(selected_item)

	if index then
		local row_list = column == "primary" and self.primary_row_items or self.secondary_row_items
		local next_index = index % #row_list + 1
		local next_item = row_list[next_index].item

		managers.menu:active_menu().logic:select_item(next_item:name())

		return true
	end

	local item = self.primary_row_items[1].item

	managers.menu:active_menu().logic:select_item(item:name())

	return true
end

function MenuNodeDoubleColumnGui:move_left()
	local selected_item = self.node:selected_item() or self._highlighted_item or self.node:item(self.node:default_item_name())
	local column, index = self:get_item_index(selected_item)

	if index then
		local row_list = column == "primary" and self.secondary_row_items or self.primary_row_items

		if index <= #row_list then
			local next_item = row_list[index].item

			managers.menu:active_menu().logic:select_item(next_item:name())
		end

		return true
	end

	local item = self.primary_row_items[1].item

	managers.menu:active_menu().logic:select_item(item:name())

	return true
end

function MenuNodeDoubleColumnGui:move_right()
	return self:move_left()
end

function MenuNodeDoubleColumnGui:confirm_pressed()
	local selected_item = self.node:selected_item()
	local column = "primary"
	local index = 1

	if selected_item then
		self:get_item_index(selected_item)
		selected_item:trigger()
		managers.menu:active_menu().input:select_node()
	end

	return true
end

function MenuNodeDoubleColumnGui:get_item_index(item)
	local index, primary = nil

	if item then
		for i, row in ipairs(self.primary_row_items) do
			if row.item == item then
				index = i
				primary = true

				break
			end
		end

		if not primary then
			for i, row in ipairs(self.secondary_row_items) do
				if row.item == item then
					index = i
					primary = false

					break
				end
			end
		end

		if index then
			local column = primary and "primary" or "secondary"

			return column, index
		end
	else
		Application:error("[MenuNodeDoubleColumnGui:get_item_index] Item is nil!")

		return
	end

	Application:error("[MenuNodeDoubleColumnGui:get_item_index] Item index could not be found!")
end
