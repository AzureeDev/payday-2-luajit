core:import("CoreMenuItem")

MenuItemCustomizeController = MenuItemCustomizeController or class(CoreMenuItem.Item)
MenuItemCustomizeController.TYPE = "customize_controller"

function MenuItemCustomizeController:init(data_node, parameters)
	CoreMenuItem.Item.init(self, data_node, parameters)

	self._type = MenuItemCustomizeController.TYPE
end

function MenuItemCustomizeController:setup_gui(node, row_item)
	row_item.gui_panel = node.item_panel:panel({
		w = node.item_panel:w()
	})
	row_item.controller_name = node:_text_item_part(row_item, row_item.gui_panel, node:_left_align())

	row_item.controller_name:set_align("right")

	row_item.controller_binding = node:_text_item_part(row_item, row_item.gui_panel, node:_left_align(), "left")

	row_item.controller_binding:set_align("left")
	row_item.controller_binding:set_text(string.upper(row_item.item:parameters().binding or ""))
	row_item.controller_binding:set_color(tweak_data.menu.default_changeable_text_color)
	self:_layout(node, row_item)

	return true
end

function MenuItemCustomizeController:reload(row_item, node)
	if self:parameters().axis then
		row_item.controller_binding:set_text(string.upper(self:parameters().binding or ""))
	else
		row_item.controller_binding:set_text(string.upper(self:parameters().binding or ""))
	end

	return true
end

function MenuItemCustomizeController:highlight_row_item(node, row_item, mouse_over)
	row_item.controller_binding:set_color(row_item.color)
	row_item.controller_binding:set_font(row_item.font and Idstring(row_item.font) or tweak_data.menu.default_font_no_outline_id)
	row_item.controller_name:set_color(row_item.color)
	row_item.controller_name:set_font(row_item.font and Idstring(row_item.font) or tweak_data.menu.default_font_no_outline_id)

	return true
end

function MenuItemCustomizeController:fade_row_item(node, row_item)
	row_item.controller_name:set_color(row_item.color)
	row_item.controller_name:set_font(row_item.font and Idstring(row_item.font) or tweak_data.menu.default_font_id)
	row_item.controller_binding:set_color(tweak_data.menu.default_changeable_text_color)
	row_item.controller_binding:set_font(row_item.font and Idstring(row_item.font) or tweak_data.menu.default_font_id)

	return true
end

function MenuItemCustomizeController:_layout(node, row_item)
	local safe_rect = managers.gui_data:scaled_size()

	row_item.controller_name:set_font_size(tweak_data.menu.customize_controller_size)

	local x, y, w, h = row_item.controller_name:text_rect()

	row_item.controller_name:set_height(h)
	row_item.controller_name:set_right(row_item.gui_panel:w() - node:align_line_padding())
	row_item.gui_panel:set_height(h)
	row_item.controller_binding:set_font_size(tweak_data.menu.customize_controller_size)
	row_item.controller_binding:set_height(h)
	row_item.controller_binding:set_left(node:_right_align())
end
