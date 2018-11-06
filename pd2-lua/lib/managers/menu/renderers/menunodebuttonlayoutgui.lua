MenuNodeButtonLayoutGui = MenuNodeButtonLayoutGui or class(MenuNodeGui)

function MenuNodeButtonLayoutGui:init(node, layer, parameters)
	MenuNodeButtonLayoutGui.super.init(self, node, layer, parameters)
	self:_setup(node)
end

function MenuNodeButtonLayoutGui:_setup_panels(node)
	MenuNodeButtonLayoutGui.super._setup_panels(self, node)

	local safe_rect_pixels = managers.viewport:get_safe_rect_pixels()
end

function MenuNodeButtonLayoutGui:_setup()
	self._coords = tweak_data:get_controller_help_coords() or {}
	self._categories = {}

	for category, _ in pairs(self._coords) do
		table.insert(self._categories, category)
	end

	self._current_category = self.node:item("controls"):value()

	for category, coords in pairs(self._coords) do
		for button, data in pairs(coords) do
			local c = data.id == "menu_button_unassigned" and Color(0.5, 0.5, 0.5) or Color.white
			data.text = self.ws:panel():text({
				visible = false,
				valign = "center",
				halign = "center",
				text = managers.localization:to_upper_text(data.id),
				font_size = self.font_size,
				font = self.font,
				layer = self.layers.items,
				align = data.align,
				vertical = data.vertical,
				color = c
			})
		end
	end

	self._blur = managers.menu_component._fullscreen_ws:panel():panel()

	self._blur:bitmap({
		texture = "guis/textures/test_blur_df",
		render_template = "VertexColorTexturedBlur3D",
		w = managers.menu_component._fullscreen_ws:panel():w(),
		h = managers.menu_component._fullscreen_ws:panel():h(),
		layer = self.layers.background
	})
	self._blur:rect({
		alpha = 0.6,
		color = Color.black
	})

	local function func(o)
		local start_blur = 0

		over(0.6, function (p)
			o:set_alpha(math.lerp(start_blur, 1, p))
		end)
	end

	self._blur:animate(func)

	self._bg = self.ws:panel():rect({
		visible = false,
		color = Color(1, 0.4, 0.4, 0.4),
		layer = self.layers.background
	})
	self._controller = self.ws:panel():bitmap({
		texture = "guis/textures/controller",
		w = 512,
		h = 256,
		layer = self.layers.items
	})

	self:_layout()
end

function MenuNodeButtonLayoutGui:_layout()
	local safe_rect_pixels = managers.viewport:get_safe_rect_pixels()
	local res = RenderSettings.resolution
	local scale = tweak_data.scale.button_layout_multiplier

	self._bg:set_h(res.y - (tweak_data.menu.upper_saferect_border + safe_rect_pixels.y) * 2 + 2)
	self._bg:set_center_y(res.y / 2)
	self._blur:set_size(managers.menu_component._fullscreen_ws:panel():w(), managers.menu_component._fullscreen_ws:panel():h())
	self._controller:set_size(self._controller:w() * scale, self._controller:h() * scale)
	self._controller:set_center(self.ws:panel():w() / 2, self.ws:panel():h() / 2)

	for category, coords in pairs(self._coords) do
		for id, data in pairs(coords) do
			local _, _, w, h = data.text:text_rect()

			data.text:set_size(w, h)
			data.text:set_visible(category == self._current_category)

			if data.x then
				local x = self._controller:x() + data.x * scale
				local y = self._controller:y() + data.y * scale

				if data.align == "left" then
					data.text:set_left(x)
				elseif data.align == "right" then
					data.text:set_right(x)
				elseif data.align == "center" then
					data.text:set_center_x(x)
				end

				if data.vertical == "top" then
					data.text:set_top(y)
				elseif data.vertical == "bottom" then
					data.text:set_bottom(y)
				else
					data.text:set_center_y(y)
				end
			end

			data.text:set_position(math.round(data.text:x()), math.round(data.text:y()))
		end
	end
end

function MenuNodeButtonLayoutGui:_create_menu_item(row_item)
	MenuNodeButtonLayoutGui.super._create_menu_item(self, row_item)
end

function MenuNodeButtonLayoutGui:_setup_item_panel_parent(safe_rect)
	MenuNodeButtonLayoutGui.super._setup_item_panel_parent(self, safe_rect)
end

function MenuNodeButtonLayoutGui:_setup_item_panel(safe_rect, res)
	MenuNodeButtonLayoutGui.super._setup_item_panel(self, safe_rect, res)
end

function MenuNodeButtonLayoutGui:set_current_category(category)
	self._current_category = category

	self:_layout()
end

function MenuNodeButtonLayoutGui:resolution_changed()
	MenuNodeButtonLayoutGui.super.resolution_changed(self)
	self:_layout()
end

function MenuNodeButtonLayoutGui:close(...)
	self._bg:parent():remove(self._bg)
	self._blur:parent():remove(self._blur)
	MenuNodeButtonLayoutGui.super.close(self, ...)
end
