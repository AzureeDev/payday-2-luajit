core:import("CoreMenuItemToggle")

MenuItemToggleWithIcon = MenuItemToggleWithIcon or class(CoreMenuItemToggle.ItemToggle)

function MenuItemToggleWithIcon:init(data_node, parameters, ...)
	MenuItemToggleWithIcon.super.init(self, data_node, parameters, ...)

	self._icon_texture = parameters and parameters.icon
end

function MenuItemToggleWithIcon:setup_gui(node, row_item, ...)
	MenuItemToggleWithIcon.super.setup_gui(self, node, row_item, ...)

	self._icon = row_item.gui_panel:bitmap({
		name = "icon",
		h = 16,
		y = 6,
		w = 16,
		layer = 0,
		texture = self._icon_texture,
		blend_mode = node.row_item_blend_mode
	})

	self._icon:set_visible(false)

	return true
end

function MenuItemToggleWithIcon:reload(row_item, node, ...)
	MenuItemToggleWithIcon.super.reload(self, row_item, node, ...)
	self._icon:set_right(row_item.gui_panel:w())
	row_item.gui_text:set_right(self._icon:x() - 8)

	return true
end

function MenuItemToggleWithIcon:highlight_row_item(node, row_item, mouse_over, ...)
	MenuItemToggleWithIcon.super.highlight_row_item(self, node, row_item, mouse_over, ...)
	self._icon:set_color(row_item.color)

	return true
end

function MenuItemToggleWithIcon:fade_row_item(node, row_item, ...)
	MenuItemToggleWithIcon.super.fade_row_item(self, node, row_item, ...)
	self._icon:set_color(row_item.color)

	return true
end

function MenuItemToggleWithIcon:set_icon_visible(state)
	self._icon:set_visible(state)
end
