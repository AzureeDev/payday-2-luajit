require("lib/utils/gui/GUIObjectWrapper")

BlackBorders = BlackBorders or class(GUIObjectWrapper)

function BlackBorders:init(parent, config)
	config = config or {}
	local blackborder_panel = parent:panel({
		name = "blackborders",
		layer = config and config.layer or 1000
	})
	local top_border = blackborder_panel:rect({
		name = "top_border",
		color = Color.black
	})
	local bottom_border = blackborder_panel:rect({
		name = "bottom_border",
		color = Color.black
	})
	local left_border = blackborder_panel:rect({
		name = "left_border",
		color = Color.black
	})
	local right_border = blackborder_panel:rect({
		name = "right_border",
		color = Color.black
	})
	local top = blackborder_panel:top()
	local bottom = blackborder_panel:bottom()
	local left = blackborder_panel:left()
	local right = blackborder_panel:right()
	local width = blackborder_panel:w()
	local height = blackborder_panel:h()
	local gui_width, gui_height = managers.gui_data:get_base_res()
	local border_w = math.ceil((width - gui_width) / 2)
	local border_h = math.ceil((height - gui_height) / 2)
	local padding = config and config.padding or 1
	local size_padding = padding * 2

	top_border:set_size(width + size_padding, border_h + size_padding)
	bottom_border:set_size(width + size_padding, border_h + size_padding)
	left_border:set_size(border_w + size_padding, height + size_padding)
	right_border:set_size(border_w + size_padding, height + size_padding)
	top_border:set_lefttop(left - padding, top - padding)
	bottom_border:set_leftbottom(left - padding, bottom + padding)
	left_border:set_lefttop(left - padding, top - padding)
	right_border:set_righttop(right + padding, top - padding)
	top_border:set_visible(border_h > 0)
	bottom_border:set_visible(border_h > 0)
	left_border:set_visible(border_w > 0)
	right_border:set_visible(border_w > 0)
	BlackBorders.super.init(self, blackborder_panel)
end
