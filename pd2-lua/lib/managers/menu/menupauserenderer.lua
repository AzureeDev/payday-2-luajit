core:import("CoreMenuNodeGui")

MenuPauseRenderer = MenuPauseRenderer or class(MenuRenderer)

function MenuPauseRenderer:init(logic)
	MenuRenderer.init(self, logic)
end

function MenuPauseRenderer:_setup_bg()
end

function MenuPauseRenderer:show_node(node)
	local gui_class = MenuNodeGui

	if node:parameters().gui_class then
		gui_class = CoreSerialize.string_to_classtable(node:parameters().gui_class)
	end

	if not managers.menu:active_menu() then
		Application:error("now everything is broken")
	end

	local parameters = {
		marker_alpha = 0.6,
		align = "right",
		row_item_blend_mode = "add",
		to_upper = true,
		font = tweak_data.menu.pd2_medium_font,
		row_item_color = tweak_data.screen_colors.button_stage_3,
		row_item_hightlight_color = tweak_data.screen_colors.button_stage_2,
		font_size = tweak_data.menu.pd2_medium_font_size,
		node_gui_class = gui_class,
		spacing = node:parameters().spacing,
		marker_color = tweak_data.screen_colors.button_stage_3:with_alpha(0.2)
	}

	MenuPauseRenderer.super.super.show_node(self, node, parameters)
end

function MenuPauseRenderer:open(...)
	MenuPauseRenderer.super.super.open(self, ...)

	self._menu_bg = self._fullscreen_panel:gradient({
		blend_mode = "normal",
		visible = true,
		orientation = "vertical",
		valign = "center",
		y = managers.gui_data:y_safe_to_full(0),
		w = self._fullscreen_panel:w(),
		h = managers.gui_data:scaled_size().height,
		gradient_points = {
			0,
			Color(1, 0, 0, 0),
			0.25,
			Color(0, 0.4, 0.2, 0),
			1,
			Color(1, 0, 0, 0)
		}
	})
	self._blur_bg = self._fullscreen_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		name = "blur_bg",
		layer = -1,
		render_template = "VertexColorTexturedBlur3D",
		valign = "center",
		y = managers.gui_data:y_safe_to_full(0),
		w = self._fullscreen_panel:w(),
		h = managers.gui_data:scaled_size().height
	})
	self._top_rect = self._fullscreen_panel:rect({
		y = -2,
		rotation = 360,
		valign = {
			0,
			0.5
		},
		color = Color.black,
		w = self._fullscreen_panel:w(),
		h = managers.gui_data:y_safe_to_full(0) + 2
	})
	self._bottom_rect = self._fullscreen_panel:rect({
		rotation = 360,
		valign = {
			0.5,
			0.5
		},
		color = Color.black,
		y = managers.gui_data:y_safe_to_full(managers.gui_data:scaled_size().height),
		w = self._fullscreen_panel:w(),
		h = managers.gui_data:y_safe_to_full(0) + 2
	})

	MenuRenderer._create_framing(self)
end

function MenuPauseRenderer:_layout_menu_bg()
end

function MenuPauseRenderer:update(t, dt)
	MenuPauseRenderer.super.update(self, t, dt)

	local x, y = managers.mouse_pointer:modified_mouse_pos()
	y = math.clamp(y, 0, managers.gui_data:scaled_size().height)
	y = y / managers.gui_data:scaled_size().height

	self._menu_bg:set_gradient_points({
		0,
		(tweak_data.screen_colors.button_stage_2 / 4):with_alpha(0.75),
		y,
		(tweak_data.screen_colors.button_stage_3 / 4):with_alpha(0.65),
		1,
		(tweak_data.screen_colors.button_stage_2 / 4):with_alpha(0.75)
	})
end

function MenuPauseRenderer:resolution_changed(...)
	MenuPauseRenderer.super.resolution_changed(self, ...)
end

function MenuPauseRenderer:set_bg_visible(visible)
	self._menu_bg:set_visible(visible)
	self._blur_bg:set_visible(visible)
end

function MenuPauseRenderer:set_bg_area(area)
	if self._menu_bg then
		if area == "full" then
			self._menu_bg:set_size(self._menu_bg:parent():size())
			self._menu_bg:set_position(0, 0)
		elseif area == "half" then
			self._menu_bg:set_size(self._menu_bg:parent():w() * 0.5, self._menu_bg:parent():h())
			self._menu_bg:set_top(0)
			self._menu_bg:set_right(self._menu_bg:parent():w())
		else
			self._menu_bg:set_size(self._menu_bg:parent():size())
			self._menu_bg:set_position(0, 0)
		end

		if self._blur_bg then
			self._blur_bg:set_shape(self._menu_bg:shape())
		end
	end
end

function MenuPauseRenderer:close(...)
	MenuPauseRenderer.super.close(self, ...)
end
