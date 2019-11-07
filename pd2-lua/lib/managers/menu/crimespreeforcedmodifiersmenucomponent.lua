CrimeSpreeForcedModifiersMenuComponent = CrimeSpreeForcedModifiersMenuComponent or class(MenuGuiComponentGeneric)
local padding = 10

function CrimeSpreeForcedModifiersMenuComponent:init(ws, fullscreen_ws, node)
	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._modifiers = {}

	self:_setup()
end

function CrimeSpreeForcedModifiersMenuComponent:close()
	self._ws:panel():remove(self._panel)
	self._ws:panel():remove(self._text_header)
	self._fullscreen_ws:panel():remove(self._fullscreen_panel)
end

function CrimeSpreeForcedModifiersMenuComponent:_setup()
	local modifiers = self:get_modifers()
	local parent = self._ws:panel()

	if alive(self._panel) then
		parent:remove(self._panel)
	end

	self._panel = self._ws:panel():panel({
		layer = 51
	})
	self._fullscreen_panel = self._fullscreen_ws:panel():panel({
		layer = 50
	})

	self._fullscreen_panel:rect({
		alpha = 0.75,
		layer = 0,
		color = Color.black
	})

	local blur = self._fullscreen_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		render_template = "VertexColorTexturedBlur3D",
		w = self._fullscreen_ws:panel():w(),
		h = self._fullscreen_ws:panel():h()
	})

	local function func(o)
		local start_blur = 0

		over(0.6, function (p)
			o:set_alpha(math.lerp(start_blur, 1, p))
		end)
	end

	blur:animate(func)

	local modifier_columns = math.clamp(#modifiers, 2, tweak_data.crime_spree.max_modifiers_displayed)
	local modifier_rows = math.ceil(#modifiers / tweak_data.crime_spree.max_modifiers_displayed)
	local modifiers_width = (CrimeSpreeModifierButton.size.w + padding) * modifier_columns + padding + (modifier_rows > 1 and 18 or 0)
	local modifiers_height = CrimeSpreeModifierButton.size.h + padding * 3
	local info_text_id = #modifiers == 1 and "menu_cs_modifiers_forced_single" or "menu_cs_modifiers_forced_multiple"
	local info_text = FineText:new(self._panel, {
		wrap = true,
		word_wrap = true,
		text = managers.localization:text(info_text_id, {
			count = #modifiers
		}),
		x = padding,
		y = padding,
		w = modifiers_width - padding * 2
	})
	self._modifiers_scroll = ScrollablePanel:new(self._panel, "modifiers_scroll", {
		w = modifiers_width,
		h = modifiers_height,
		y = info_text:bottom(),
		padding = padding
	})
	self._button_panel = self._panel:panel({
		y = self._modifiers_scroll:panel():bottom(),
		w = modifiers_width,
		h = tweak_data.menu.pd2_medium_font_size
	})

	for i, modifier in ipairs(modifiers) do
		local btn = CrimeSpreeModifierButton:new(self._modifiers_scroll:canvas(), modifier)
		local zi = i - 1
		local column = zi % 3
		local row = math.floor(zi / 3)

		if #modifiers == 1 then
			btn:set_x((modifiers_width - CrimeSpreeModifierButton.size.w) * 0.5 - padding)
		else
			btn:set_x((CrimeSpreeModifierButton.size.w + padding) * column)
			btn:set_y((CrimeSpreeModifierButton.size.h + padding) * row)
		end

		table.insert(self._modifiers, btn)
	end

	self:add_modifiers_to_spree(modifiers)
	self._modifiers_scroll:update_canvas_size()

	self._back_btn = CrimeSpreeButton:new(self._button_panel)

	self._back_btn:set_text(managers.localization:to_upper_text("menu_back"))
	self._back_btn:set_callback(callback(self, self, "_on_back"))
	self._back_btn:shrink_wrap_button(0, 0)
	self._back_btn:panel():set_right(self._button_panel:w() - padding * 2)
	self._back_btn:panel():set_visible(managers.menu:is_pc_controller())

	if not managers.menu:is_pc_controller() then
		self._legend_text = self._button_panel:text({
			halign = "right",
			vertical = "bottom",
			layer = 1,
			blend_mode = "add",
			align = "right",
			text = "",
			y = 0,
			x = 0,
			valign = "bottom",
			color = tweak_data.screen_colors.text,
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size
		})

		self._legend_text:set_right(self._back_btn:panel():right())

		local legend_string = managers.localization:to_upper_text("menu_legend_back")

		self._legend_text:set_text(legend_string)
		self._legend_text:set_rotation(360)
	end

	self._panel:set_w(self._modifiers_scroll:panel():w())
	self._panel:set_h(self._button_panel:bottom() + padding)
	self._panel:set_center_x(parent:center_x())
	self._panel:set_center_y(parent:center_y())
	self._panel:rect({
		alpha = 0.4,
		layer = -1,
		color = Color.black
	})

	self._text_header = self._ws:panel():text({
		vertical = "top",
		align = "left",
		layer = 51,
		text = managers.localization:to_upper_text("menu_cs_modifiers_forced"),
		font_size = tweak_data.menu.pd2_large_font_size,
		font = tweak_data.menu.pd2_large_font,
		color = tweak_data.screen_colors.text
	})
	local x, y, w, h = self._text_header:text_rect()

	self._text_header:set_size(self._panel:w(), h)
	self._text_header:set_left(self._panel:left())
	self._text_header:set_bottom(self._panel:top())
	BoxGuiObject:new(self._panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
end

function CrimeSpreeForcedModifiersMenuComponent:get_modifers()
	local count = managers.crime_spree:modifiers_to_select("forced", true)

	if count > 0 then
		return managers.crime_spree:get_forced_modifiers(), "forced"
	else
		Application:error("Showing Crime Spree modifiers menu when there are no modifiers to select!")

		return {}, "forced"
	end
end

function CrimeSpreeForcedModifiersMenuComponent:add_modifiers_to_spree(modifiers)
	if Network:is_server() then
		for _, modifier in ipairs(modifiers) do
			managers.crime_spree:select_modifier(modifier.id)
		end
	else
		for _, modifier in ipairs(modifiers) do
			managers.crime_spree:set_server_modifier(modifier.id, managers.crime_spree:server_spree_level())
		end
	end
end

function CrimeSpreeForcedModifiersMenuComponent:_on_back()
	managers.menu:back(true)
end

function CrimeSpreeForcedModifiersMenuComponent:update(t, dt)
	self._back_btn:update(t, dt)

	local cx, cy = managers.menu_component:get_right_controller_axis()

	if cy ~= 0 and self._modifiers_scroll then
		self._modifiers_scroll:perform_scroll(math.abs(cy * 500 * dt), math.sign(cy))
	end
end

function CrimeSpreeForcedModifiersMenuComponent:confirm_pressed()
	if self._selected_item and self._selected_item:callback() then
		self._selected_item:callback()()
	end
end

function CrimeSpreeForcedModifiersMenuComponent:mouse_moved(o, x, y)
	if not managers.menu:is_pc_controller() then
		return
	end

	local used = false
	local pointer = nil
	self._selected_item = nil
	used, pointer = self._modifiers_scroll:mouse_moved(nil, x, y)

	self._back_btn:set_selected(self._back_btn:inside(x, y))

	if self._back_btn:is_selected() then
		self._selected_item = self._back_btn
		pointer = "link"
		used = true
	end

	return used, pointer
end

function CrimeSpreeForcedModifiersMenuComponent:mouse_pressed(button, x, y)
	if self._back_btn:is_selected() and self._back_btn:callback() then
		self._back_btn:callback()()

		return true
	end

	return self._modifiers_scroll:mouse_pressed(button, x, y)
end

function CrimeSpreeForcedModifiersMenuComponent:mouse_released(button, x, y)
	return self._modifiers_scroll:mouse_released(button, x, y)
end

function CrimeSpreeForcedModifiersMenuComponent:mouse_wheel_up(x, y)
	return self._modifiers_scroll:scroll(x, y, 1)
end

function CrimeSpreeForcedModifiersMenuComponent:mouse_wheel_down(x, y)
	return self._modifiers_scroll:scroll(x, y, -1)
end

function CrimeSpreeForcedModifiersMenuComponent:_select_back_btn()
	self._back_btn:set_selected(true)

	self._selected_item = self._back_btn

	return true
end

CrimeSpreeForcedModifiersMenuComponent.move_up = CrimeSpreeForcedModifiersMenuComponent._select_back_btn
CrimeSpreeForcedModifiersMenuComponent.move_down = CrimeSpreeForcedModifiersMenuComponent._select_back_btn
CrimeSpreeForcedModifiersMenuComponent.move_left = CrimeSpreeForcedModifiersMenuComponent._select_back_btn
CrimeSpreeForcedModifiersMenuComponent.move_right = CrimeSpreeForcedModifiersMenuComponent._select_back_btn
