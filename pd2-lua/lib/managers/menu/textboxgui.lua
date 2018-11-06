TextBoxGui = TextBoxGui or class()
TextBoxGui.PRESETS = {
	system_menu = {
		w = 540,
		h = 270
	},
	weapon_stats = {
		w = 700,
		x = 60,
		h = 270,
		bottom = 620
	},
	help_dialog = {
		w = 540,
		h = 270,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size
	}
}

function TextBoxGui:init(...)
	self._target_alpha = {}
	self._visible = true
	self._enabled = true
	self._minimized = false

	self:_create_text_box(...)
	self:_check_scroll_indicator_states()

	self._thread = self._panel:animate(self._update, self)
end

function TextBoxGui._update(o, self)
	while true do
		local dt = coroutine.yield()

		if self._up_alpha then
			self._up_alpha.current = math.step(self._up_alpha.current, self._up_alpha.target, dt * 5)

			self._text_box:child("scroll_up_indicator_shade"):set_alpha(self._up_alpha.current)
			self._text_box:child("scroll_up_indicator_arrow"):set_color(self._text_box:child("scroll_up_indicator_arrow"):color():with_alpha(self._up_alpha.current))
		end

		if self._down_alpha then
			self._down_alpha.current = math.step(self._down_alpha.current, self._down_alpha.target, dt * 5)

			self._text_box:child("scroll_down_indicator_shade"):set_alpha(self._down_alpha.current)
			self._text_box:child("scroll_down_indicator_arrow"):set_color(self._text_box:child("scroll_down_indicator_arrow"):color():with_alpha(self._down_alpha.current))
		end
	end
end

function TextBoxGui:set_layer(layer)
	self._panel:set_layer(self._init_layer + layer)

	if self._background then
		self._background:set_layer(self._panel:layer() - 1)
	end

	if self._background2 then
		self._background2:set_layer(self._panel:layer() - 1)
	end
end

function TextBoxGui:layer()
	return self._panel:layer()
end

function TextBoxGui:add_background()
	if alive(self._fullscreen_ws) then
		managers.gui_data:destroy_workspace(self._fullscreen_ws)

		self._fullscreen_ws = nil
	end

	self._fullscreen_ws = managers.gui_data:create_fullscreen_workspace()
	self._background = self._fullscreen_ws:panel():bitmap({
		texture = "guis/textures/test_blur_df",
		name = "bg",
		alpha = 0,
		valign = "grow",
		render_template = "VertexColorTexturedBlur3D",
		layer = 0,
		color = Color.white,
		w = self._fullscreen_ws:panel():w(),
		h = self._fullscreen_ws:panel():h()
	})
	self._background2 = self._fullscreen_ws:panel():rect({
		blend_mode = "normal",
		name = "bg",
		halign = "grow",
		alpha = 0,
		valign = "grow",
		layer = 0,
		color = Color.black
	})
end

function TextBoxGui:set_centered()
	self._panel:set_center(self._ws:panel():center())
end

function TextBoxGui:recreate_text_box(...)
	self:close()
	self:_create_text_box(...)
	self:_check_scroll_indicator_states()

	self._thread = self._panel:animate(self._update, self)
end

function TextBoxGui:_create_text_box(ws, title, text, content_data, config)
	self._ws = ws
	self._init_layer = self._ws:panel():layer()

	if alive(self._text_box) then
		ws:panel():remove(self._text_box)

		self._text_box = nil
	end

	if self._info_box then
		self._info_box:close()

		self._info_box = nil
	end

	self._text_box_focus_button = nil
	local scaled_size = managers.gui_data:scaled_size()
	local type = config and config.type
	local preset = type and self.PRESETS[type]
	local stats_list = content_data and content_data.stats_list
	local stats_text = content_data and content_data.stats_text
	local button_list = content_data and content_data.button_list
	local focus_button = content_data and content_data.focus_button
	local use_indicator = config and config.use_indicator or false
	local no_close_legend = config and config.no_close_legend
	local no_scroll_legend = config and config.no_scroll_legend
	self._no_scroll_legend = true
	local only_buttons = config and config.only_buttons
	local use_minimize_legend = config and config.use_minimize_legend or false
	local w = preset and preset.w or config and config.w or scaled_size.width / 2.25
	local h = preset and preset.h or config and config.h or scaled_size.height / 2
	local x = preset and preset.x or config and config.x or 0
	local y = preset and preset.y or config and config.y or 0
	local bottom = preset and preset.bottom or config and config.bottom
	local forced_h = preset and preset.forced_h or config and config.forced_h or false
	local title_font = preset and preset.title_font or config and config.title_font or tweak_data.menu.pd2_large_font
	local title_font_size = preset and preset.title_font_size or config and config.title_font_size or 28
	local font = preset and preset.font or config and config.font or tweak_data.menu.pd2_medium_font
	local font_size = preset and preset.font_size or config and config.font_size or tweak_data.menu.pd2_medium_font_size
	local use_text_formating = preset and preset.use_text_formating or config and config.use_text_formating or false
	local text_formating_color = preset and preset.text_formating_color or config and config.text_formating_color or Color.white
	local text_formating_color_table = preset and preset.text_formating_color_table or config and config.text_formating_color_table or nil
	local is_title_outside = preset and preset.is_title_outside or config and config.is_title_outside or false
	local text_blend_mode = preset and preset.text_blend_mode or config and config.text_blend_mode or "normal"
	self._allow_moving = config and config.allow_moving or false
	local preset_or_config_y = y ~= 0
	title = title and utf8.to_upper(title)

	if text then
		-- Nothing
	end

	local main = ws:panel():panel({
		valign = "center",
		visible = self._visible,
		x = x,
		y = y,
		w = w,
		h = h,
		layer = self._init_layer
	})
	self._panel = main
	self._panel_h = self._panel:h()
	self._panel_w = self._panel:w()
	local title_text = main:text({
		word_wrap = false,
		name = "title",
		halign = "left",
		wrap = false,
		align = "left",
		vertical = "top",
		valign = "top",
		y = 10,
		rotation = 360,
		x = 10,
		layer = 1,
		text = title or "none",
		visible = title and true or false,
		font = title_font,
		font_size = title_font_size
	})
	local _, _, tw, th = title_text:text_rect()

	title_text:set_size(tw, th)

	th = th + 10

	if is_title_outside then
		th = 0
	end

	self._indicator = main:bitmap({
		texture = "guis/textures/icon_loading",
		name = "indicator",
		layer = 1,
		visible = use_indicator
	})

	self._indicator:set_right(main:w())

	local top_line = main:bitmap({
		texture = "guis/textures/headershadow",
		name = "top_line",
		y = 0,
		layer = 0,
		color = Color.white,
		w = main:w()
	})

	top_line:set_bottom(th)

	local bottom_line = main:bitmap({
		texture = "guis/textures/headershadow",
		name = "bottom_line",
		y = 100,
		rotation = 180,
		layer = 0,
		color = Color.white,
		w = main:w()
	})

	bottom_line:set_top(main:h() - th)
	top_line:hide()
	bottom_line:hide()

	local lower_static_panel = main:panel({
		name = "lower_static_panel",
		h = 0,
		y = 0,
		x = 0,
		layer = 0,
		w = main:w()
	})

	self:_create_lower_static_panel(lower_static_panel)

	local info_area = main:panel({
		name = "info_area",
		y = 0,
		x = 0,
		layer = 0,
		w = main:w(),
		h = main:h() - th * 2
	})
	local info_bg = info_area:rect({
		name = "info_bg",
		valign = "grow",
		halign = "grow",
		alpha = 0.6,
		layer = 0,
		color = Color(0, 0, 0)
	})
	local buttons_panel = self:_setup_buttons_panel(info_area, button_list, focus_button, only_buttons)
	local scroll_panel = info_area:panel({
		name = "scroll_panel",
		x = 10,
		layer = 1,
		y = math.round(th + 5),
		w = info_area:w() - 20,
		h = info_area:h()
	})
	local has_stats = stats_list and #stats_list > 0
	local stats_panel = self:_setup_stats_panel(scroll_panel, stats_list, stats_text)
	local text = scroll_panel:text({
		word_wrap = true,
		name = "text",
		wrap = true,
		align = "left",
		halign = "left",
		vertical = "top",
		valign = "top",
		layer = 1,
		text = text or "none",
		visible = text and true or false,
		w = scroll_panel:w() - math.round(stats_panel:w()) - (has_stats and 20 or 0),
		x = math.round(stats_panel:w()) + (has_stats and 20 or 0),
		font = font,
		font_size = font_size,
		blend_mode = text_blend_mode
	})

	if use_text_formating then
		local text_string = text:text()
		local text_dissected = utf8.characters(text_string)
		local idsp = Idstring("#")
		local start_ci = {}
		local end_ci = {}
		local first_ci = true

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

		if #start_ci ~= #end_ci then
			-- Nothing
		else
			for i = 1, #start_ci, 1 do
				start_ci[i] = start_ci[i] - ((i - 1) * 4 + 1)
				end_ci[i] = end_ci[i] - (i * 4 - 1)
			end
		end

		text_string = string.gsub(text_string, "##", "")

		text:set_text(text_string)
		text:clear_range_color(1, utf8.len(text_string))

		if #start_ci ~= #end_ci then
			Application:error("TextBoxGui: Not even amount of ##'s in skill description string!", #start_ci, #end_ci)
		else
			for i = 1, #start_ci, 1 do
				text:set_range_color(start_ci[i], end_ci[i], text_formating_color_table and text_formating_color_table[i] or text_formating_color)
			end
		end
	end

	local scroll_up_indicator_shade = main:panel({
		halign = "right",
		name = "scroll_up_indicator_shade",
		valign = "top",
		y = 100,
		layer = 5,
		x = scroll_panel:x(),
		w = main:w() - buttons_panel:w()
	})
	local scroll_down_indicator_shade = main:panel({
		halign = "right",
		name = "scroll_down_indicator_shade",
		valign = "bottom",
		y = 100,
		layer = 5,
		x = scroll_panel:x(),
		w = main:w() - buttons_panel:w()
	})
	local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")

	scroll_panel:grow(-rect[3], 0)
	scroll_up_indicator_shade:set_w(scroll_panel:w())
	scroll_down_indicator_shade:set_w(scroll_panel:w())
	text:set_w(scroll_panel:w())

	local _, _, ttw, tth = text:text_rect()

	text:set_h(tth)
	scroll_panel:set_h(forced_h or math.min(h - th, tth))

	if self._override_info_area_size then
		self:_override_info_area_size(info_area, scroll_panel, buttons_panel)
	else
		info_area:set_h(scroll_panel:bottom() + buttons_panel:h() + 10 + 5)
	end

	buttons_panel:set_bottom(info_area:h() - 10)

	if not preset_or_config_y then
		main:set_h(info_area:h())

		if content_data.clamp_to_screen then
			main:set_h(main:parent():h() * 0.9)
			main:set_center_y(main:parent():h() / 2)
		end

		if bottom then
			main:set_bottom(bottom)
		elseif y == 0 then
			main:set_center_y(main:parent():h() / 2)
		end
	end

	top_line:set_world_bottom(scroll_panel:world_top())
	bottom_line:set_world_top(scroll_panel:world_bottom())
	scroll_up_indicator_shade:set_top(top_line:bottom())
	scroll_down_indicator_shade:set_bottom(bottom_line:top())

	local scroll_up_indicator_arrow = main:bitmap({
		name = "scroll_up_indicator_arrow",
		layer = 3,
		halign = "right",
		valign = "top",
		texture = texture,
		texture_rect = rect,
		color = Color.white
	})

	scroll_up_indicator_arrow:set_lefttop(scroll_panel:right() + 2, scroll_up_indicator_shade:top() + 8)

	local scroll_down_indicator_arrow = main:bitmap({
		name = "scroll_down_indicator_arrow",
		layer = 3,
		halign = "right",
		valign = "bottom",
		rotation = 180,
		texture = texture,
		texture_rect = rect,
		color = Color.white
	})

	scroll_down_indicator_arrow:set_leftbottom(scroll_panel:right() + 2, scroll_down_indicator_shade:bottom() - 8)
	BoxGuiObject:new(scroll_up_indicator_shade, {
		sides = {
			0,
			0,
			2,
			0
		}
	}):set_aligns("scale", "scale")
	BoxGuiObject:new(scroll_down_indicator_shade, {
		sides = {
			0,
			0,
			0,
			2
		}
	}):set_aligns("scale", "scale")
	lower_static_panel:set_bottom(main:h() - h * 2)

	self._info_box = BoxGuiObject:new(info_area, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	local bar_h = scroll_down_indicator_arrow:top() - scroll_up_indicator_arrow:bottom()
	local scroll_bar = main:panel({
		name = "scroll_bar",
		halign = "right",
		w = 4,
		layer = 4,
		h = bar_h
	})
	self._scroll_bar_box_class = BoxGuiObject:new(scroll_bar, {
		sides = {
			2,
			2,
			0,
			0
		}
	})

	self._scroll_bar_box_class:set_aligns("scale", "scale")
	scroll_bar:set_w(8)
	scroll_bar:set_bottom(scroll_down_indicator_arrow:top())
	scroll_bar:set_center_x(scroll_down_indicator_arrow:center_x())

	local legend_minimize = main:text({
		text = "MINIMIZE",
		name = "legend_minimize",
		halign = "left",
		valign = "top",
		layer = 1,
		visible = use_minimize_legend,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size
	})
	local _, _, lw, lh = legend_minimize:text_rect()

	legend_minimize:set_size(lw, lh)
	legend_minimize:set_bottom(top_line:bottom() - 4)
	legend_minimize:set_right(top_line:right())

	local legend_close = main:text({
		text = "CLOSE",
		name = "legend_close",
		halign = "left",
		valign = "top",
		layer = 1,
		visible = not no_close_legend,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size
	})
	local _, _, lw, lh = legend_close:text_rect()

	legend_close:set_size(lw, lh)
	legend_close:set_top(bottom_line:top() + 4)

	local legend_scroll = main:text({
		text = "SCROLL WITH",
		name = "legend_scroll",
		halign = "right",
		valign = "top",
		layer = 1,
		visible = not no_scroll_legend,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size
	})
	local _, _, lw, lh = legend_scroll:text_rect()

	legend_scroll:set_size(lw, lh)
	legend_scroll:set_righttop(scroll_panel:right(), bottom_line:top() + 4)

	self._scroll_panel = scroll_panel
	self._text_box = main

	self:_set_scroll_indicator()

	if is_title_outside then
		title_text:set_bottom(0)
		title_text:set_rotation(360)

		self._is_title_outside = is_title_outside
	end

	return main
end

function TextBoxGui:_setup_stats_panel(scroll_panel, stats_list, stats_text)
	local has_stats = stats_list and #stats_list > 0
	local stats_panel = scroll_panel:panel({
		name = "stats_panel",
		x = 10,
		layer = 1,
		w = has_stats and scroll_panel:w() / 3 or 0,
		h = scroll_panel:h()
	})
	local total_h = 0

	if has_stats then
		for _, stats in ipairs(stats_list) do
			if stats.type == "bar" then
				local panel = stats_panel:panel({
					layer = -1,
					h = 20,
					w = stats_panel:w(),
					y = total_h
				})
				local bg = panel:rect({
					layer = -1,
					color = Color.black:with_alpha(0.5)
				})
				local w = (bg:w() - 4) * stats.current / stats.total
				local progress_bar = panel:rect({
					y = 1,
					x = 1,
					layer = 0,
					w = w,
					h = bg:h() - 2,
					color = tweak_data.hud.prime_color:with_alpha(0.5)
				})
				local text = panel:text({
					vertical = "center",
					halign = "left",
					align = "left",
					valign = "center",
					blend_mode = "normal",
					kern = 0,
					y = -1,
					x = 4,
					layer = 1,
					text = stats.text,
					w = panel:w(),
					h = panel:h(),
					font = tweak_data.menu.pd2_small_font,
					font_size = tweak_data.menu.pd2_small_font_size
				})
				total_h = total_h + panel:h()
			elseif stats.type == "condition" then
				local panel = stats_panel:panel({
					h = 22,
					w = stats_panel:w(),
					y = total_h
				})
				local texture, rect = tweak_data.hud_icons:get_icon_data("icon_repair")
				local icon = panel:bitmap({
					name = "icon",
					layer = 0,
					texture = texture,
					texture_rect = rect,
					color = Color.white
				})

				icon:set_center_y(panel:h() / 2)

				local text = panel:text({
					vertical = "center",
					valign = "center",
					align = "left",
					blend_mode = "normal",
					kern = 0,
					halign = "left",
					layer = 0,
					text = "CONDITION: " .. stats.value .. "%",
					w = panel:w(),
					h = panel:h(),
					x = icon:right(),
					font = tweak_data.menu.pd2_small_font,
					font_size = tweak_data.menu.pd2_small_font_size
				})

				text:set_center_y(panel:h() / 2)

				total_h = total_h + panel:h()
			elseif stats.type == "empty" then
				local panel = stats_panel:panel({
					w = stats_panel:w(),
					h = stats.h,
					y = total_h
				})
				total_h = total_h + panel:h()
			elseif stats.type == "mods" then
				local panel = stats_panel:panel({
					h = 22,
					w = stats_panel:w(),
					y = total_h
				})
				local texture, rect = tweak_data.hud_icons:get_icon_data("icon_addon")
				local icon = panel:bitmap({
					name = "icon",
					layer = 0,
					texture = texture,
					texture_rect = rect,
					color = Color.white
				})

				icon:set_center_y(panel:h() / 2)

				local text = panel:text({
					vertical = "center",
					valign = "center",
					align = "left",
					blend_mode = "normal",
					kern = 0,
					text = "ACTIVE MODS:",
					halign = "left",
					layer = 0,
					w = panel:w(),
					h = panel:h(),
					x = icon:right(),
					font = tweak_data.menu.pd2_small_font,
					font_size = tweak_data.menu.pd2_small_font_size
				})

				text:set_center_y(panel:h() / 2)

				local s = ""

				for _, mod in ipairs(stats.list) do
					s = s .. mod .. "\n"
				end

				local mods_text = panel:text({
					vertical = "top",
					halign = "left",
					align = "left",
					valign = "top",
					blend_mode = "normal",
					kern = 0,
					layer = 0,
					text = s,
					w = panel:w(),
					h = panel:h(),
					y = text:bottom(),
					x = icon:right(),
					font = tweak_data.menu.pd2_small_font,
					font_size = tweak_data.menu.pd2_small_font_size
				})
				local _, _, w, h = mods_text:text_rect()

				mods_text:set_h(h)
				panel:set_h(text:h() + mods_text:h())

				total_h = total_h + panel:h()
			end
		end

		local stats_text = stats_panel:text({
			vertical = "top",
			halign = "left",
			wrap = true,
			align = "left",
			word_wrap = true,
			valign = "top",
			blend_mode = "normal",
			kern = 0,
			layer = 0,
			text = stats_text or "Nunc vel diam vel neque sodales gravida et ac quam. Phasellus egestas, arcu in tristique mattis, velit nisi tincidunt lorem, bibendum molestie nunc purus id turpis. Donec sagittis nibh in eros ultrices aliquam. Vestibulum ante mauris, mattis quis commodo a, dictum eget sapien. Maecenas eu diam lorem. Nunc dolor metus, varius sit amet rhoncus vel, iaculis sed massa. Morbi tempus mi quis dolor posuere eu commodo magna eleifend. Pellentesque sit amet mattis nunc. Nunc lectus quam, pretium sit amet consequat sed, vestibulum vitae lorem. Sed bibendum egestas turpis, sit amet viverra risus viverra in. Suspendisse aliquam dapibus urna, posuere fermentum tellus vulputate vitae.",
			w = stats_panel:w(),
			y = total_h,
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size
		})
		local _, _, w, h = stats_text:text_rect()

		stats_text:set_h(h)

		total_h = total_h + h
	end

	stats_panel:set_h(total_h)

	return stats_panel
end

function TextBoxGui:_setup_buttons_panel(info_area, button_list, focus_button, only_buttons)
	local has_buttons = button_list and #button_list > 0
	local buttons_panel = info_area:panel({
		name = "buttons_panel",
		x = 10,
		layer = 1,
		w = has_buttons and 200 or 0,
		h = info_area:h()
	})

	buttons_panel:set_right(info_area:w())

	self._text_box_buttons_panel = buttons_panel

	if has_buttons then
		local button_text_config = {
			name = "button_text",
			vertical = "center",
			word_wrap = "true",
			wrap = "true",
			blend_mode = "add",
			halign = "right",
			x = 10,
			layer = 2,
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size,
			color = tweak_data.screen_colors.button_stage_3
		}
		local max_w = 0
		local max_h = 0

		if button_list then
			for i, button in ipairs(button_list) do
				local button_panel = buttons_panel:panel({
					halign = "grow",
					h = 20,
					y = 100,
					name = button.id_name
				})
				button_text_config.text = utf8.to_upper(button.text or "")
				local text = button_panel:text(button_text_config)
				local _, _, w, h = text:text_rect()
				max_w = math.max(max_w, w)
				max_h = math.max(max_h, h)

				text:set_size(w, h)
				button_panel:set_h(h)
				text:set_right(button_panel:w())
				button_panel:set_bottom(i * h)
			end

			buttons_panel:set_h(#button_list * max_h)
			buttons_panel:set_bottom(info_area:h() - 10)
		end

		buttons_panel:set_w(only_buttons and info_area:w() or math.max(max_w, 120) + 40)
		buttons_panel:set_right(info_area:w() - 10)

		local selected = buttons_panel:rect({
			blend_mode = "add",
			name = "selected",
			alpha = 0.3,
			color = tweak_data.screen_colors.button_stage_3
		})

		self:set_focus_button(focus_button)
	end

	return buttons_panel
end

function TextBoxGui:_create_lower_static_panel()
end

function TextBoxGui:check_focus_button(x, y)
	for i, panel in ipairs(self._text_box_buttons_panel:children()) do
		if panel.child and panel:inside(x, y) then
			self:set_focus_button(i)

			return true
		end
	end

	return false
end

function TextBoxGui:set_focus_button(focus_button)
	if focus_button ~= self._text_box_focus_button then
		managers.menu:post_event("highlight")

		if self._text_box_focus_button then
			self:_set_button_selected(self._text_box_focus_button, false)
		end

		self:_set_button_selected(focus_button, true)

		self._text_box_focus_button = focus_button
	end
end

function TextBoxGui:_set_button_selected(index, is_selected)
	local button_panel = self._text_box_buttons_panel:child(index - 1)

	if button_panel then
		local button_text = button_panel:child("button_text")
		local selected = self._text_box_buttons_panel:child("selected")

		if is_selected then
			button_text:set_color(tweak_data.screen_colors.button_stage_2)
			selected:set_shape(button_panel:shape())
			selected:move(2, -1)
		else
			button_text:set_color(tweak_data.screen_colors.button_stage_3)
		end
	end
end

function TextBoxGui:change_focus_button(change)
	local button_count = self._text_box_buttons_panel:num_children() - 1
	local focus_button = (self._text_box_focus_button + change) % button_count

	if focus_button == 0 then
		focus_button = button_count
	end

	self:set_focus_button(focus_button)
end

function TextBoxGui:get_focus_button()
	return self._text_box_focus_button
end

function TextBoxGui:get_focus_button_id()
	return self._text_box_buttons_panel:child(self._text_box_focus_button - 1):name()
end

function TextBoxGui:_set_scroll_indicator()
	local info_area = self._text_box:child("info_area")
	local scroll_panel = info_area:child("scroll_panel")
	local scroll_text = scroll_panel:child("text")
	local scroll_bar = self._text_box:child("scroll_bar")
	local legend_scroll = self._text_box:child("legend_scroll")
	local bar_h = self._text_box:child("scroll_down_indicator_arrow"):top() - self._text_box:child("scroll_up_indicator_arrow"):bottom()
	local is_visible = scroll_panel:h() < scroll_text:h()

	if scroll_text:h() ~= 0 then
		scroll_bar:set_h(bar_h * scroll_panel:h() / scroll_text:h())
	end

	scroll_bar:set_visible(is_visible)
	legend_scroll:set_visible(not self._no_scroll_legend and is_visible)
	self._text_box:child("scroll_up_indicator_shade"):set_visible(is_visible)
	self._text_box:child("scroll_up_indicator_arrow"):set_visible(is_visible)
	self._text_box:child("scroll_down_indicator_shade"):set_visible(is_visible)
	self._text_box:child("scroll_down_indicator_arrow"):set_visible(is_visible)
end

function TextBoxGui:_check_scroll_indicator_states()
	local info_area = self._text_box:child("info_area")
	local scroll_panel = info_area:child("scroll_panel")
	local scroll_text = scroll_panel:child("text")

	if not self._up_alpha then
		self._up_alpha = {
			current = 0
		}

		self._text_box:child("scroll_up_indicator_shade"):set_alpha(self._up_alpha.current)
		self._text_box:child("scroll_up_indicator_arrow"):set_color(self._text_box:child("scroll_up_indicator_arrow"):color():with_alpha(self._up_alpha.current))
	end

	if not self._down_alpha then
		self._down_alpha = {
			current = 1
		}

		self._text_box:child("scroll_down_indicator_shade"):set_alpha(self._down_alpha.current)
		self._text_box:child("scroll_down_indicator_arrow"):set_color(self._text_box:child("scroll_down_indicator_arrow"):color():with_alpha(self._down_alpha.current))
	end

	self._up_alpha.target = scroll_text:top() < 0 and 1 or 0
	self._down_alpha.target = scroll_panel:h() < scroll_text:bottom() and 1 or 0
	local up_arrow = self._text_box:child("scroll_up_indicator_arrow")
	local scroll_bar = self._text_box:child("scroll_bar")
	local sh = scroll_text:h() ~= 0 and scroll_text:h() or 1

	scroll_bar:set_top(up_arrow:bottom() - scroll_text:top() * (scroll_panel:h() - up_arrow:h() * 2 - 16) / sh)
end

function TextBoxGui:input_focus()
	return false
end

function TextBoxGui:mouse_pressed(button, x, y)
	return false
end

function TextBoxGui:check_close(x, y)
	if not self:can_take_input() then
		return false
	end

	local legend_close = self._panel:child("legend_close")

	if not legend_close:visible() then
		return false
	end

	if legend_close:inside(x, y) then
		return true
	end

	return false
end

function TextBoxGui:check_minimize(x, y)
	if not self:can_take_input() then
		return false
	end

	local legend_minimize = self._panel:child("legend_minimize")

	if not legend_minimize:visible() then
		return false
	end

	if legend_minimize:inside(x, y) then
		return true
	end

	return false
end

function TextBoxGui:check_grab_scroll_bar(x, y)
	if not self:can_take_input() or not alive(self._text_box) or not self._text_box:child("scroll_bar"):visible() then
		return false
	end

	if self._allow_moving and self._text_box:inside(x, y) and self._text_box:child("top_line"):inside(x, y) then
		self._grabbed_title = true
		self._grabbed_offset_x = self:x() - x
		self._grabbed_offset_y = self:y() - y

		return true
	end

	if self._text_box:child("scroll_bar") and self._text_box:child("scroll_bar"):inside(x, y) then
		self._grabbed_scroll_bar = true
		self._current_y = y

		return true
	end

	if self._text_box:child("scroll_up_indicator_arrow"):inside(x, y) then
		self._pressing_arrow_up = true

		return true
	end

	if self._text_box:child("scroll_down_indicator_arrow"):inside(x, y) then
		self._pressing_arrow_down = true

		return true
	end

	return false
end

function TextBoxGui:release_scroll_bar()
	self._pressing_arrow_up = false
	self._pressing_arrow_down = false

	if self._grabbed_scroll_bar then
		self._grabbed_scroll_bar = false

		return true
	end

	if self._grabbed_title then
		self._grabbed_title = false

		return true
	end

	return false
end

function TextBoxGui:mouse_moved(x, y)
	if not self:can_take_input() or not alive(self._panel) then
		return false, "arrow"
	end

	if self._grabbed_scroll_bar then
		self:scroll_with_bar(y, self._current_y)

		self._current_y = y

		return true, "grab"
	elseif self._grabbed_title then
		local _x = x + self._grabbed_offset_x
		local _y = y + self._grabbed_offset_y

		if self._ws:panel():w() < _x + self:w() then
			self._grabbed_offset_x = self:x() - x
			_x = self._ws:panel():w() - self:w()
		elseif _x < self._ws:panel():x() then
			self._grabbed_offset_x = self:x() - x
			_x = self._ws:panel():x()
		end

		if self._ws:panel():h() < _y + self:h() then
			self._grabbed_offset_y = self:y() - y
			_y = self._ws:panel():h() - self:h()
		elseif _y < self._ws:panel():y() then
			self._grabbed_offset_y = self:y() - y
			_y = self._ws:panel():y()
		end

		self:set_position(_x, _y)

		return true, "grab"
	elseif self._text_box:child("scroll_bar") and self._text_box:child("scroll_bar"):visible() and self._text_box:child("scroll_bar"):inside(x, y) then
		return true, "hand"
	elseif self._text_box:child("scroll_up_indicator_arrow"):visible() and self._text_box:child("scroll_up_indicator_arrow"):inside(x, y) then
		if self._pressing_arrow_up then
			self:scroll_up()
		end

		return true, "link"
	elseif self._text_box:child("scroll_down_indicator_arrow"):visible() and self._text_box:child("scroll_down_indicator_arrow"):inside(x, y) then
		if self._pressing_arrow_down then
			self:scroll_down()
		end

		return true, "link"
	else
		for i, panel in ipairs(self._text_box_buttons_panel:children()) do
			if panel.child and panel:inside(x, y) then
				return true, "link"
			end
		end
	end

	return false, "arrow"
end

function TextBoxGui:moved_scroll_bar(x, y)
	self._x = x
	self._y = y

	return

	if not self:can_take_input() then
		return false, "arrow"
	end

	if self._pressing_arrow_up and self._text_box:child("scroll_up_indicator_arrow"):inside(x, y) then
		self:scroll_up()
	end

	if self._pressing_arrow_down and self._text_box:child("scroll_down_indicator_arrow"):inside(x, y) then
		self:scroll_down()
	end

	if self._grabbed_scroll_bar then
		self:scroll_with_bar(y, self._current_y)

		self._current_y = y

		return true, "grab"
	end

	if self._grabbed_title then
		local _x = x + self._grabbed_offset_x
		local _y = y + self._grabbed_offset_y

		if self._ws:panel():w() < _x + self:w() then
			self._grabbed_offset_x = self:x() - x
			_x = self._ws:panel():w() - self:w()
		elseif _x < self._ws:panel():x() then
			self._grabbed_offset_x = self:x() - x
			_x = self._ws:panel():x()
		end

		if self._ws:panel():h() < _y + self:h() then
			self._grabbed_offset_y = self:y() - y
			_y = self._ws:panel():h() - self:h()
		elseif _y < self._ws:panel():y() then
			self._grabbed_offset_y = self:y() - y
			_y = self._ws:panel():y()
		end

		self:set_position(_x, _y)

		return true, "grab"
	end

	return false, "hand"
end

function TextBoxGui:mouse_wheel_up(x, y)
	if not self._visible then
		return false
	end

	local scroll_panel = self._text_box:child("info_area"):child("scroll_panel")
	local info_area = self._text_box:child("info_area")

	if info_area:inside(x, y) and scroll_panel:inside(x, y) then
		self:scroll_up(28)

		return true
	end
end

function TextBoxGui:mouse_wheel_down(x, y)
	if not self._visible then
		return false
	end

	local scroll_panel = self._text_box:child("info_area"):child("scroll_panel")
	local info_area = self._text_box:child("info_area")

	if info_area:inside(x, y) and scroll_panel:inside(x, y) then
		self:scroll_down(28)

		return true
	end
end

function TextBoxGui:scroll_up(y)
	if not alive(self._text_box) then
		return
	end

	local info_area = self._text_box:child("info_area")
	local scroll_panel = info_area:child("scroll_panel")
	local scroll_text = scroll_panel:child("text")

	if scroll_text:top() < 0 then
		if scroll_text:top() < 0 then
			scroll_text:set_y(scroll_text:y() + (y or TimerManager:main():delta_time() * 200))
		end

		if scroll_text:top() > 0 then
			scroll_text:set_top(0)
		end
	end

	self:_check_scroll_indicator_states()
end

function TextBoxGui:scroll_down(y)
	if not alive(self._text_box) then
		return
	end

	local info_area = self._text_box:child("info_area")
	local scroll_panel = info_area:child("scroll_panel")
	local scroll_text = scroll_panel:child("text")

	if scroll_panel:h() < scroll_text:bottom() then
		if scroll_panel:h() < scroll_text:bottom() then
			scroll_text:set_y(scroll_text:y() - (y or TimerManager:main():delta_time() * 200))
		end

		if scroll_text:bottom() < scroll_panel:h() then
			scroll_text:set_bottom(scroll_panel:h())
		end
	end

	self:_check_scroll_indicator_states()
end

function TextBoxGui:scroll_with_bar(target_y, current_y)
	local arrow_size = self._text_box:child("scroll_up_indicator_arrow"):size()
	local info_area = self._text_box:child("info_area")
	local scroll_panel = info_area:child("scroll_panel")
	local scroll_text = scroll_panel:child("text")

	if target_y < current_y then
		if target_y < scroll_panel:world_bottom() - arrow_size then
			local mul = (scroll_panel:h() - arrow_size * 2) / scroll_text:h()

			self:scroll_up((current_y - target_y) / mul)
		end

		current_y = target_y
	elseif current_y < target_y then
		if target_y > scroll_panel:world_y() + arrow_size then
			local mul = (scroll_panel:h() - arrow_size * 2) / scroll_text:h()

			self:scroll_down((target_y - current_y) / mul)
		end

		current_y = target_y
	end
end

function TextBoxGui:update_indicator(t, dt)
	if alive(self._indicator) then
		self._indicator:rotate(180 * dt)
	end

	if self._x and self._y then
		local used, pointer = self:mouse_moved(self._x, self._y)

		managers.mouse_pointer:set_pointer_image(pointer)
	end
end

function TextBoxGui:set_fade(fade)
	self:_set_alpha(fade)

	if alive(self._background) then
		self._background:set_alpha(fade * 0.9)
	end

	if alive(self._background2) then
		self._background2:set_alpha(fade * 0.3)
	end
end

function TextBoxGui:_set_alpha(alpha)
	self._panel:set_alpha(alpha)
	self._panel:set_visible(alpha ~= 0)
end

function TextBoxGui:_set_alpha_recursive(obj, alpha)
	if obj.set_color then
		local a = self._target_alpha[obj:key()] and self._target_alpha[obj:key()] * alpha or alpha

		obj:set_color(obj:color():with_alpha(a))
	end

	if obj.children then
		for _, child in ipairs(obj:children()) do
			self:_set_alpha_recursive(child, alpha)
		end
	end
end

function TextBoxGui:set_title(title)
	local title_text = self._panel:child("title")

	title_text:set_text(title or "none")

	local _, _, w, h = title_text:text_rect()

	title_text:set_size(w, h)
	title_text:set_visible(title and true or false)
end

function TextBoxGui:set_text(txt, no_upper)
	local text = self._panel:child("info_area"):child("scroll_panel"):child("text")

	text:set_text(no_upper and txt or utf8.to_upper(txt or ""))
end

function TextBoxGui:set_use_minimize_legend(use)
	self._panel:child("legend_minimize"):set_visible(use)
end

function TextBoxGui:in_focus(x, y)
	return self._panel:inside(x, y)
end

function TextBoxGui:in_info_area_focus(x, y)
	return self._panel:child("info_area"):inside(x, y)
end

function TextBoxGui:_set_visible_state()
	local visible = self._visible and self._enabled

	self._panel:set_visible(visible)

	if alive(self._background) then
		self._background:set_visible(visible)
	end

	if alive(self._background2) then
		self._background2:set_visible(visible)
	end
end

function TextBoxGui:can_take_input()
	return self._visible and self._enabled
end

function TextBoxGui:set_visible(visible)
	self._visible = visible

	self:_set_visible_state()
end

function TextBoxGui:set_enabled(enabled)
	if self._enabled == enabled then
		return
	end

	self._enabled = enabled

	self:_set_visible_state()

	if self._minimized then
		if not self._enabled then
			self:_remove_minimized(self._minimized_id)
		else
			self:_add_minimized()
		end
	end
end

function TextBoxGui:enabled()
	return self._enabled
end

function TextBoxGui:_maximize(data)
	self:set_visible(true)
	self:set_minimized(false, nil)
	self:_remove_minimized(data.id)
end

function TextBoxGui:set_minimized(minimized, minimized_data)
	self._minimized = minimized
	self._minimized_data = minimized_data

	if self._minimized then
		self:_add_minimized()
	end
end

function TextBoxGui:_add_minimized()
	self._minimized_data.callback = callback(self, self, "_maximize")

	self:set_visible(false)

	self._minimized_id = managers.menu_component:add_minimized(self._minimized_data)
end

function TextBoxGui:_remove_minimized(id)
	self._minimized_id = nil

	managers.menu_component:remove_minimized(id)
end

function TextBoxGui:minimized()
	return self._minimized
end

function TextBoxGui:set_position(x, y)
	self._panel:set_position(x, y)
end

function TextBoxGui:position()
	return self._panel:position()
end

function TextBoxGui:set_size(x, y)
	self._panel:set_size(x, y)

	local _, _, w, h = self._panel:child("title"):text_rect()
	local lower_static_panel = self._panel:child("lower_static_panel")

	lower_static_panel:set_w(self._panel:w())
	lower_static_panel:set_bottom(self._panel:h() - h)

	local lsp_h = lower_static_panel:h()
	local info_area = self._panel:child("info_area")

	info_area:set_size(self._panel:w(), self._panel:h() - h * 2 - lsp_h)

	if self._info_box then
		self._info_box:create_sides(info_area, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
	end

	local buttons_panel = info_area:child("buttons_panel")
	local scroll_panel = info_area:child("scroll_panel")

	scroll_panel:set_w(info_area:w() - buttons_panel:w() - 30)
	scroll_panel:set_y(scroll_panel:y() - 1)
	scroll_panel:set_y(scroll_panel:y() + 1)

	local scroll_up_indicator_shade = self._panel:child("scroll_up_indicator_shade")

	scroll_up_indicator_shade:set_w(scroll_panel:w())

	local scroll_up_indicator_arrow = self._panel:child("scroll_up_indicator_arrow")

	scroll_up_indicator_arrow:set_lefttop(scroll_panel:right() + 2, scroll_up_indicator_shade:top() + 8)

	local top_line = self._panel:child("top_line")

	top_line:set_w(self._panel:w())
	top_line:set_bottom(h)

	local bottom_line = self._panel:child("bottom_line")

	bottom_line:set_w(self._panel:w())
	bottom_line:set_top(self._panel:h() - h)

	local scroll_down_indicator_shade = self._panel:child("scroll_down_indicator_shade")

	scroll_down_indicator_shade:set_w(scroll_panel:w())
	scroll_down_indicator_shade:set_bottom(bottom_line:top())

	local scroll_down_indicator_arrow = self._panel:child("scroll_down_indicator_arrow")

	scroll_down_indicator_arrow:set_leftbottom(scroll_panel:right() + 2, scroll_down_indicator_shade:bottom() - 8)

	local scroll_bar = self._panel:child("scroll_bar")

	scroll_bar:set_center_x(scroll_down_indicator_arrow:center_x())

	local legend_close = self._panel:child("legend_close")

	legend_close:set_top(bottom_line:top() + 4)

	local legend_minimize = self._panel:child("legend_minimize")

	legend_minimize:set_bottom(top_line:bottom() - 4)
	legend_minimize:set_right(top_line:right())

	local legend_scroll = self._panel:child("legend_scroll")

	legend_scroll:set_righttop(scroll_panel:right(), bottom_line:top() + 4)
	self:_set_scroll_indicator()
	self:_check_scroll_indicator_states()
end

function TextBoxGui:size()
	return self._panel:size()
end

function TextBoxGui:open_page()
end

function TextBoxGui:close_page()
end

function TextBoxGui:x()
	return self._panel:x()
end

function TextBoxGui:y()
	return self._panel:y()
end

function TextBoxGui:h()
	return self._panel:h()
end

function TextBoxGui:w()
	return self._panel:w()
end

function TextBoxGui:h()
	return self._panel:h()
end

function TextBoxGui:visible()
	return self._visible
end

function TextBoxGui:close()
	if self._minimized then
		self:_remove_minimized(self._minimized_id)
	end

	if self._thread then
		self._panel:stop(self._thread)

		self._thread = nil
	end

	if self._info_box then
		self._info_box:close()

		self._info_box = nil
	end

	self._ws:panel():remove(self._panel)

	if alive(self._background) then
		self._fullscreen_ws:panel():remove(self._background)
	end

	if alive(self._background2) then
		self._fullscreen_ws:panel():remove(self._background2)
	end

	if alive(self._fullscreen_ws) then
		managers.gui_data:destroy_workspace(self._fullscreen_ws)

		self._fullscreen_ws = nil
	end
end
