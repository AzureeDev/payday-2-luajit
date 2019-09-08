core:import("CoreMenuItem")
core:import("CoreMenuItemOption")

MenuItemExpand = MenuItemExpand or class(CoreMenuItem.Item)
MenuItemExpand.TYPE = "expand"

function MenuItemExpand:init(data_node, parameters)
	CoreMenuItem.Item.init(self, data_node, parameters)

	self._type = MenuItemExpand.TYPE
	self._expanded = false
	self._items = {}
	self._current_index = 1
	self._all_items = {}

	if data_node then
		for _, c in ipairs(data_node) do
			local type = c._meta

			if type == "item" then
				local item = CoreMenuNode.MenuNode.create_item(self, c)

				self:add_item(item)

				local visible_callback = c.visible_callback

				if visible_callback then
					item.visible_callback_names = string.split(visible_callback, " ")
				end
			end
		end
	end

	self._enabled = true

	self:_show_items(nil)
end

function MenuItemExpand:set_enabled(enabled)
	self._enabled = enabled

	self:dirty()
end

function MenuItemExpand:set_callback_handler(callback_handler)
	MenuItemExpand.super.set_callback_handler(self, callback_handler)
	self:_show_items(callback_handler)
end

function MenuItemExpand:_show_items(callback_handler)
	self._items = {}

	for _, item in ipairs(self._all_items) do
		local show = true

		if callback_handler and item._visible_callback_name_list then
			for _, id in ipairs(item._visible_callback_name_list) do
				if not callback_handler[id](callback_handler, item) then
					show = false

					break
				end
			end
		end

		if show then
			table.insert(self._items, item)
		end
	end
end

function MenuItemExpand:add_item(item)
	item:parameters().parent_item = self

	table.insert(self._all_items, item)
end

function MenuItemExpand:get_item(name)
	for _, item in ipairs(self._all_items) do
		if item:parameters().name == name then
			return item
		end
	end

	return nil
end

function MenuItemExpand:visible_items()
	for _, item in ipairs(self._items) do
		-- Nothing
	end

	return self._items
end

function MenuItemExpand:items()
	return self._items
end

function MenuItemExpand:expand_value()
	return 20
end

function MenuItemExpand:update_expanded_items(node)
	local row_item = node:row_item(self)

	self:collaps(node, row_item)
	self:_show_items(self._callback_handler)
	self:expand(node, row_item)
	node:need_repositioning()
	row_item.node:select_item(self:name())
	node:highlight_item(self, false)
end

function MenuItemExpand:expand(node, row_item)
	local need_repos = false

	for i, eitem in ipairs(self._items) do
		eitem:parameters().is_expanded = true
		eitem:parameters().expand_value = self:expand_value() + (self:parameters().is_expanded and self:parameters().expand_value or 0)
		need_repos = true

		for j, nitem in pairs(row_item.node._items) do
			if nitem == self then
				row_item.node:insert_item(eitem, j + i)

				break
			end
		end

		for j, ritem in pairs(node.row_items) do
			if ritem == row_item then
				node:_insert_row_item(eitem, row_item.node, j + i)
			end
		end
	end

	return need_repos
end

function MenuItemExpand:collaps(node, row_item)
	local need_repos = false

	for i, eitem in ipairs(self._items) do
		local type = eitem:type()

		if (type == "expand" or type == "weapon_expand") and eitem:expanded() then
			eitem:toggle()
			node:_reload_expand(eitem)
		end

		if row_item.node:delete_item(eitem:name()) then
			need_repos = true
		end

		node:_delete_row_item(eitem)
	end

	return need_repos
end

function MenuItemExpand:get_h(row_item, node)
	local h = row_item.gui_panel:h()

	if self:expanded() then
		for _, item in ipairs(self:items()) do
			local child_row_item = node:row_item(item)

			if child_row_item then
				h = h + child_row_item.gui_panel:h()
			end
		end
	end

	return nil
end

function MenuItemExpand:on_item_position(row_item, node)
	row_item.expanded_indicator:set_position(row_item.gui_panel:position())
	row_item.expanded_indicator:set_left(row_item.expanded_indicator:left() - node:align_line_padding())
	row_item.expanded_indicator:set_center_y(row_item.gui_panel:center_y())
	row_item.expand_line:set_lefttop(row_item.gui_panel:leftbottom())
	row_item.expand_line:set_left(row_item.expand_line:left() - node:align_line_padding())
end

function MenuItemExpand:_create_indicator(row_item, node)
	row_item.expanded_indicator = row_item.gui_panel:parent():bitmap({
		texture = "guis/textures/menu_selected",
		y = 0,
		visible = false,
		x = 0,
		layer = node.layers.items - 1
	})

	row_item.expanded_indicator:set_w(row_item.gui_panel:w() + node:align_line_padding())
	row_item.expanded_indicator:set_height(64 * row_item.gui_panel:height() / 32)
end

function MenuItemExpand:reload(row_item, node)
	if not row_item.expanded_indicator then
		self:_create_indicator(row_item, node)
	end

	row_item.expand_line = row_item.expand_line or row_item.gui_panel:parent():bitmap({
		texture = "guis/textures/headershadowdown",
		y = 100,
		texture_rect = {
			0,
			4,
			256,
			60
		},
		layer = node.layers.items + 1,
		color = Color.white,
		w = row_item.gui_panel:w() + node:align_line_padding()
	})

	row_item.expanded_indicator:set_visible(self:expanded())
	row_item.expand_line:set_visible(self:expanded())

	if self:expanded() then
		row_item.expanded_indicator:set_color(node.row_item_color)
		row_item.menu_unselected:set_color(node.row_item_color)
	else
		row_item.expanded_indicator:set_color(node.row_item_hightlight_color)
		row_item.menu_unselected:set_color(node.row_item_hightlight_color)
	end

	self:_set_row_item_state(node, row_item)
end

function MenuItemExpand:_set_row_item_state(node, row_item)
	if self:expanded() or row_item.highlighted then
		row_item.gui_panel:set_color(node.row_item_hightlight_color)
		row_item.gui_panel:set_font(row_item.font and Idstring(row_item.font) or tweak_data.menu.default_font_no_outline_id)
		row_item.current_of_total:set_color(self:expanded() and row_item.color or node.row_item_hightlight_color)
		row_item.current_of_total:set_font(row_item.font and Idstring(row_item.font) or tweak_data.menu.default_font_no_outline_id)
	else
		row_item.gui_panel:set_color(row_item.color)
		row_item.gui_panel:set_font(row_item.font and Idstring(row_item.font) or tweak_data.menu.default_font_id)
		row_item.current_of_total:set_color(row_item.color)
		row_item.current_of_total:set_font(row_item.font and Idstring(row_item.font) or tweak_data.menu.default_font_id)
	end
end

function MenuItemExpand:highlight_row_item(node, row_item, mouse_over)
	self:_set_row_item_state(node, row_item)

	return true
end

function MenuItemExpand:fade_row_item(node, row_item, mouse_over)
	self:_set_row_item_state(node, row_item)

	return true
end

function MenuItemExpand:on_delete_row_item(row_item, ...)
	MenuItemExpand.super.on_delete_row_item(self, row_item, ...)
	row_item.gui_panel:parent():remove(row_item.expand_line)
end

function MenuItemExpand:selected_item()
	return self._items[self._current_index]
end

function MenuItemExpand:current_index()
	return self._current_index
end

function MenuItemExpand:set_current_index(index)
	self._current_index = index

	self:dirty()
end

function MenuItemExpand:set_value(value)
	for i, item in ipairs(self._items) do
		if item:parameters().value == value then
			self._current_index = i

			break
		end
	end

	self:dirty()
end

function MenuItemExpand:value()
	local value = ""
	local selected_item = self:selected_item()

	if selected_item then
		value = selected_item:parameters().value
	end

	return value
end

function MenuItemExpand:_highest_item_index()
	local index = 1

	for i, item in ipairs(self._items) do
		if not item:parameters().exclude then
			index = i
		end
	end

	return index
end

function MenuItemExpand:_lowest_item_index()
	for i, item in ipairs(self._items) do
		if not item:parameters().exclude then
			return i
		end
	end
end

function MenuItemExpand:expanded()
	return self._expanded
end

function MenuItemExpand:can_expand()
	return true
end

function MenuItemExpand:toggle()
	self._expanded = not self._expanded
end

function MenuItemExpand:is_parent_to_item(child_item)
	for i, item in ipairs(self._items) do
		if child_item == item then
			return true
		end
	end

	return false
end

MenuItemExpandAction = MenuItemExpandAction or class(CoreMenuItem.Item)

function MenuItemExpandAction:init(data_node, parameters)
	MenuItemExpandAction.super.init(self, data_node, parameters)
end

function MenuItemExpandAction:setup_gui(node, row_item)
	local scaled_size = managers.gui_data:scaled_size()
	row_item.gui_panel = node.item_panel:panel({
		w = node.item_panel:w()
	})
	row_item.action_name = node:_text_item_part(row_item, row_item.gui_panel, node:align_line_padding())

	row_item.action_name:set_font_size(22)

	local _, _, w, h = row_item.action_name:text_rect()

	row_item.action_name:set_h(h)

	if row_item.align == "right" then
		row_item.gui_panel:set_right(node:_mid_align() + self._parameters.expand_value)
	else
		row_item.gui_panel:set_left(node:_mid_align() + self._parameters.expand_value)
	end

	row_item.gui_panel:set_w(scaled_size.width - row_item.gui_panel:left())
	row_item.gui_panel:set_h(h)

	local texture, rect = tweak_data.hud_icons:get_icon_data(self._parameters.action_type == "equip" and "icon_equipped" or self._parameters.action_type == "repair" and "icon_repair" or self._parameters.action_type == "buy_upgrades" and "icon_addon" or self._parameters.action_type == "buy" and "icon_buy" or self._parameters.action_type == "attach_upgrade" and "icon_equipped" or self._parameters.action_type == "buy_upgrade" and "icon_buy")
	row_item.action_icon = row_item.gui_panel:bitmap({
		texture = texture,
		texture_rect = rect,
		layer = node.layers.items
	})

	row_item.action_icon:set_center(h / 2, h / 2)

	if row_item.align == "right" then
		row_item.action_name:set_right(row_item.gui_panel:w() - 10 - self._parameters.expand_value)
	else
		row_item.action_name:set_left(h + 4)
	end

	if self._parameters.action_type == "repair" then
		local texture, rect = tweak_data.hud_icons:get_icon_data("icon_circlebg")
		row_item.circlefill = row_item.gui_panel:bitmap({
			visible = true,
			texture = texture,
			texture_rect = rect,
			layer = node.layers.items
		})

		row_item.circlefill:set_center(h / 2, h / 2)
		row_item.circlefill:set_right(row_item.circlefill:parent():w() - 4)

		local texture, rect = tweak_data.hud_icons:get_icon_data("icon_circlefill" .. self._parameters.parent_item:condition())
		row_item.repair_circle = row_item.gui_panel:bitmap({
			visible = self._parameters.unlocked,
			texture = texture,
			texture_rect = rect,
			layer = node.layers.items + 1,
			color = self:_repair_circle_color(self._parameters.parent_item:condition())
		})

		row_item.repair_circle:set_position(row_item.circlefill:position())
	end

	return true
end

function MenuItemExpandAction:reload(row_item, node)
	MenuItemExpandAction.super.reload(self, row_item, node)
	row_item.menu_unselected:set_color(node.row_item_hightlight_color)

	if self._parameters.action_type == "equip" then
		self:parameters().parent_item:on_equip(node)
	elseif self._parameters.action_type == "repair" then
		self:parameters().parent_item:on_repair(node)

		local texture, rect = tweak_data.hud_icons:get_icon_data("icon_circlefill" .. self._parameters.parent_item:condition())

		row_item.repair_circle:set_texture_rect(rect[1], rect[2], rect[3], rect[4])
		row_item.repair_circle:set_size(rect[3], rect[4])
		row_item.repair_circle:set_color(self:_repair_circle_color(self._parameters.parent_item:condition()))
	elseif self._parameters.action_type == "buy" then
		-- Nothing
	elseif self._parameters.action_type == "attach_upgrade" then
		self:parameters().parent_item:on_attach_upgrade(node)
	end

	self:_set_row_item_state(node, row_item)

	return true
end

function MenuItemExpandAction:_set_row_item_state(node, row_item)
	if row_item.highlighted then
		row_item.action_name:set_color(row_item.color)
		row_item.action_name:set_font(row_item.font and Idstring(row_item.font) or tweak_data.menu.default_font_no_outline_id)
	else
		if self._parameters.action_type == "repair" and self:_at_max_condition() then
			row_item.action_name:set_color(node.row_item_hightlight_color)
		else
			row_item.action_name:set_color(row_item.color)
		end

		row_item.action_name:set_font(row_item.font and Idstring(row_item.font) or tweak_data.menu.default_font_id)
	end
end

function MenuItemExpandAction:highlight_row_item(node, row_item, mouse_over)
	self:_set_row_item_state(node, row_item)

	return true
end

function MenuItemExpandAction:fade_row_item(node, row_item)
	self:_set_row_item_state(node, row_item)

	return true
end

function MenuItemExpandAction:_max_condition()
	return self:parameters().parent_item:_max_condition()
end

function MenuItemExpandAction:_at_max_condition()
	return self:parameters().parent_item:_at_max_condition()
end

function MenuItemExpandAction:_repair_circle_color(...)
	return self:parameters().parent_item:_repair_circle_color(...)
end
