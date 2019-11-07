CrimeSpreeContractMenuComponent = CrimeSpreeContractMenuComponent or class(MenuGuiComponentGeneric)

function CrimeSpreeContractMenuComponent:init(ws, fullscreen_ws, node)
	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._init_layer = self._ws:panel():layer()
	self._data = node:parameters().menu_component_data or {}
	self._buttons = {}
	self._hosting = not self._data.server or self._data.id == "crime_spree"

	self:_setup()
end

function CrimeSpreeContractMenuComponent:close()
	if not managers.menu:is_pc_controller() then
		managers.menu:active_menu().input:activate_controller_mouse()
	end

	self._ws:panel():remove(self._panel)
	self._fullscreen_ws:panel():remove(self._fullscreen_panel)
end

function CrimeSpreeContractMenuComponent:_is_host()
	return self._hosting
end

function CrimeSpreeContractMenuComponent:_host_spree_level()
	return tonumber(self._data.crime_spree or 0)
end

function CrimeSpreeContractMenuComponent:_setup()
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

	if not managers.menu:is_pc_controller() then
		managers.menu:active_menu().input:deactivate_controller_mouse()
		self:_setup_controller_input()
	end

	local font_size = tweak_data.menu.pd2_small_font_size
	local font = tweak_data.menu.pd2_small_font
	local risk_color = tweak_data.screen_colors.risk
	local padding = tweak_data.gui.crime_net.contract_gui.padding
	local width = tweak_data.gui.crime_net.contract_gui.width
	local height = tweak_data.gui.crime_net.contract_gui.height
	local text_w = tweak_data.gui.crime_net.contract_gui.text_width
	local text_h = math.round(height * 0.4)

	self._fullscreen_panel:rect({
		alpha = 0.75,
		layer = 0,
		color = Color.black
	})

	local blur = self._fullscreen_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		render_template = "VertexColorTexturedBlur3D",
		layer = 1,
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

	local show_level = managers.crime_spree:in_progress() or not self:_is_host()
	local spree_text = show_level and "cn_crime_spree_level" or "cn_crime_spree"
	local spree_level = self:_is_host() and managers.crime_spree:spree_level() or self:_host_spree_level()
	self._contact_text_header = self._panel:text({
		vertical = "top",
		align = "left",
		layer = 1,
		text = managers.localization:to_upper_text(spree_text, {
			level = managers.experience:cash_string(spree_level, "")
		}),
		font_size = tweak_data.menu.pd2_large_font_size,
		font = tweak_data.menu.pd2_large_font,
		color = tweak_data.screen_colors.text
	})
	local x, y, w, h = self._contact_text_header:text_rect()

	self._contact_text_header:set_size(width, h)
	self._contact_text_header:set_center_x(self._panel:w() * 0.5)

	if show_level then
		local range = {
			from = utf8.len(managers.localization:text("cn_crime_spree_level_no_num")),
			to = utf8.len(managers.localization:text(self._contact_text_header:text())),
			color = tweak_data.screen_colors.crime_spree_risk
		}

		self._contact_text_header:set_range_color(range.from, range.to, range.color)
	end

	self._contract_panel = self._panel:panel({
		layer = 1,
		h = height,
		w = width,
		x = self._contact_text_header:x(),
		y = self._contact_text_header:bottom()
	})

	self._contract_panel:set_center_y(self._panel:h() * 0.5)
	self._contact_text_header:set_bottom(self._contract_panel:top())

	if self._contact_text_header:y() < 0 then
		local y_offset = -self._contact_text_header:y()

		self._contact_text_header:move(0, y_offset)
		self._contract_panel:move(0, y_offset)
	end

	BoxGuiObject:new(self._contract_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	self._desc_text = self._contract_panel:text({
		vertical = "top",
		wrap = true,
		align = "left",
		wrap_word = true,
		text = managers.localization:text("cn_crime_spree_brief"),
		w = text_w,
		h = text_h,
		font_size = font_size,
		font = font,
		color = tweak_data.screen_colors.text,
		x = padding,
		y = padding
	})
	local _, _, _, h = self._desc_text:text_rect()
	local scale = 1

	if text_h < h then
		scale = text_h / (h - font_size)
	end

	self._desc_text:set_font_size(font_size * scale)
	CrimeNetGui.make_color_text(self, self._desc_text, tweak_data.screen_colors.important_1)

	if managers.crime_spree:in_progress() then
		self:_setup_continue_crime_spree(text_w, text_h)
	else
		self:_setup_new_crime_spree(text_w, text_h)
	end
end

function CrimeSpreeContractMenuComponent:_setup_new_crime_spree(text_w, text_h)
	local padding = tweak_data.gui.crime_net.contract_gui.padding
	self._coins_panel = self._contract_panel:panel({
		x = padding,
		y = padding,
		h = tweak_data.menu.pd2_medium_font_size
	})

	self._coins_panel:set_bottom(self._contract_panel:h() - padding)

	local coins = 0
	coins = managers.custom_safehouse:coins()
	self._cost_text = self._coins_panel:text({
		y = 0,
		x = 0,
		layer = 1,
		text = managers.experience:cash_string(math.floor(coins), managers.localization:get_default_macro("BTN_CONTINENTAL_COINS")),
		color = Color.white,
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size
	})

	BlackMarketGui.make_fine_text(self, self._cost_text)

	local h = CrimeSpreeStartingLevelItem.size.h + padding * 2
	self._levels_panel = self._contract_panel:panel({
		layer = 1,
		x = padding,
		y = self._contract_panel:h() - h - padding * 2 - tweak_data.menu.pd2_medium_font_size,
		w = text_w,
		h = h
	})
	local starting_text = self._contract_panel:text({
		vertical = "top",
		wrap = true,
		align = "left",
		wrap_word = true,
		text = managers.localization:to_upper_text("cn_crime_spree_starting"),
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		color = tweak_data.screen_colors.text
	})

	BlackMarketGui.make_fine_text(self, starting_text)
	starting_text:set_bottom(self._levels_panel:top())
	starting_text:set_left(self._levels_panel:left())

	local levels = {}
	local highest_level = 0

	for idx, level in ipairs(tweak_data.crime_spree.starting_levels) do
		table.insert(levels, level)

		highest_level = math.max(level, highest_level)
	end

	if tweak_data.crime_spree.allow_highscore_continue then
		local level = managers.crime_spree:highest_level()

		if not self:_is_host() and self:_host_spree_level() < level then
			level = self:_host_spree_level()
		end

		if not table.contains(levels, level) then
			table.insert(levels, level)

			highest_level = math.max(level, highest_level)
		end
	end

	highest_level = highest_level * 1.05

	for idx, level in ipairs(levels) do
		local btn = CrimeSpreeStartingLevelItem:new(self._levels_panel, {
			index = idx,
			level = level,
			highest_level = highest_level,
			is_maximum = idx == #levels,
			num_items = #levels
		})

		btn:set_callback(callback(self, self, "set_active_starting_level", btn))
		table.insert(self._buttons, btn)
	end

	if not self:_is_host() then
		local grow_size = 24 + padding

		starting_text:set_y(starting_text:y() - grow_size)
		self._levels_panel:set_y(self._levels_panel:y() - grow_size)
		self._levels_panel:grow(0, grow_size)

		local btn = CrimeSpreeStartingLevelItem:new(self._levels_panel, {
			num_items = 1,
			highest_level = 1,
			text = "",
			x = 0,
			level = -1,
			y = CrimeSpreeStartingLevelItem.size.h + padding * 2,
			w = self._levels_panel:w(),
			h = grow_size,
			cost_text = managers.localization:to_upper_text("menu_cs_continue_without_starting")
		})

		btn:set_callback(callback(self, self, "set_active_starting_level", btn))
		btn._cost_text:set_center_y(btn._panel:h() * 0.5)

		local coins = 0
		coins = managers.custom_safehouse:coins()
		local insert_pos = 1

		if tweak_data.crime_spree.initial_cost <= coins then
			insert_pos = #self._buttons
		end

		table.insert(self._buttons, insert_pos, btn)
	end

	local default_btn = self._buttons[1]

	if default_btn:can_activate() then
		self:set_active_starting_level(default_btn)
	end

	if not self:_is_host() then
		local warning_text = self._contract_panel:text({
			vertical = "bottom",
			align = "left",
			text = managers.localization:to_upper_text("menu_cs_not_in_progress_join_lobby"),
			font_size = tweak_data.menu.pd2_medium_font_size,
			font = tweak_data.menu.pd2_medium_font,
			color = tweak_data.screen_colors.important_1,
			x = padding,
			w = text_w,
			h = tweak_data.menu.pd2_medium_font_size
		})
		local warning_desc = self._contract_panel:text({
			vertical = "bottom",
			wrap = true,
			align = "left",
			wrap_word = true,
			text = managers.localization:text("menu_cs_not_in_progress_join_lobby_desc"),
			font_size = tweak_data.menu.pd2_small_font_size,
			font = tweak_data.menu.pd2_small_font,
			color = tweak_data.screen_colors.important_1,
			x = padding,
			w = text_w,
			h = text_h
		})

		BlackMarketGui.make_fine_text(self, warning_desc)
		BlackMarketGui.make_fine_text(self, warning_text)
		warning_desc:set_bottom(starting_text:top() - padding)
		warning_text:set_bottom(warning_desc:top())
	end

	if not managers.menu:is_pc_controller() then
		local controls_text = self._contract_panel:text({
			vertical = "top",
			wrap = true,
			align = "left",
			wrap_word = true,
			text = managers.localization:get_default_macro("BTN_X") .. " / " .. managers.localization:get_default_macro("BTN_Y"),
			font_size = tweak_data.menu.pd2_medium_font_size,
			font = tweak_data.menu.pd2_medium_font,
			color = tweak_data.screen_colors.text
		})

		BlackMarketGui.make_fine_text(self, controls_text)
		controls_text:set_bottom(self._levels_panel:top())
		controls_text:set_right(self._levels_panel:right())
	end
end

function CrimeSpreeContractMenuComponent:_setup_continue_crime_spree(text_w, text_h)
	if self:_is_host() then
		self:_setup_continue_host(text_w, text_h)
	else
		self:_setup_continue_client(text_w, text_h)
	end
end

function CrimeSpreeContractMenuComponent:_setup_continue_host(text_w, text_h)
	local padding = tweak_data.gui.crime_net.contract_gui.padding
	local modifiers = managers.crime_spree:active_modifiers()
	local next_modifiers_h = tweak_data.menu.pd2_small_font_size * 2
	local line_h = tweak_data.menu.pd2_small_font_size * 1.5
	local table_split = 0.125
	self._modifiers_panel = self._contract_panel:panel({
		x = padding,
		y = self._desc_text:bottom() + padding + tweak_data.menu.pd2_medium_font_size,
		w = text_w,
		h = self._contract_panel:h() - text_h - padding * 3 - tweak_data.menu.pd2_medium_font_size
	})

	CrimeSpreeModifierDetailsPage.add_modifiers_panel(self, self._modifiers_panel, managers.crime_spree:active_modifiers(), false)

	local text = self._contract_panel:text({
		vertical = "top",
		wrap = true,
		align = "left",
		wrap_word = true,
		text = managers.localization:to_upper_text("cn_crime_spree_modifiers"),
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		color = tweak_data.screen_colors.text
	})

	BlackMarketGui.make_fine_text(self, text)
	text:set_bottom(self._modifiers_panel:top())
	text:set_left(self._modifiers_panel:left())

	if #modifiers == 0 then
		local panel = self._scroll:canvas():panel({
			y = line_h,
			h = line_h
		})

		panel:text({
			halign = "left",
			vertical = "center",
			align = "left",
			layer = 1,
			alpha = 0.8,
			y = 5,
			valign = "center",
			text = managers.localization:text("cn_crime_spree_no_modifiers"),
			x = padding + panel:w() * table_split,
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			w = panel:w() * (1 - table_split),
			h = tweak_data.menu.pd2_small_font_size,
			color = Color.white
		})
	end

	self._scroll:update_canvas_size()
end

function CrimeSpreeContractMenuComponent:_setup_continue_client(text_w, text_h)
	local padding = tweak_data.gui.crime_net.contract_gui.padding
	self._info_panel = self._contract_panel:panel({
		x = padding,
		y = self._desc_text:bottom() + padding + tweak_data.menu.pd2_medium_font_size,
		w = text_w,
		h = self._contract_panel:h() - text_h - padding * 3 - tweak_data.menu.pd2_medium_font_size
	})
	local text = self._contract_panel:text({
		vertical = "top",
		wrap = true,
		align = "left",
		wrap_word = true,
		text = managers.localization:to_upper_text("menu_cs_in_progress"),
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		color = tweak_data.screen_colors.text
	})

	BlackMarketGui.make_fine_text(self, text)
	text:set_bottom(self._info_panel:top())
	text:set_left(self._info_panel:left())

	local desc = self._info_panel:text({
		vertical = "top",
		wrap = true,
		align = "left",
		wrap_word = true,
		x = 0,
		text = managers.localization:text("menu_cs_in_progress_desc"),
		w = text_w,
		h = text_h,
		font_size = tweak_data.menu.pd2_small_font_size,
		font = tweak_data.menu.pd2_small_font,
		color = tweak_data.screen_colors.text,
		y = padding
	})

	BlackMarketGui.make_fine_text(self, desc)

	local level_desc_text, level_desc_col = nil
	local level_higher = self:_host_spree_level() < managers.crime_spree:spree_level()
	local level_lower = managers.crime_spree:spree_level() < self:_host_spree_level()

	if level_higher then
		level_desc_text = "menu_cs_in_progress_desc_higher"
		level_desc_col = tweak_data.screen_colors.important_1
	elseif level_lower then
		level_desc_text = "menu_cs_in_progress_desc_lower"
		level_desc_col = tweak_data.screen_colors.heat_warm_color
	end

	if level_desc_text then
		local level_warning = self._info_panel:text({
			vertical = "top",
			wrap = true,
			align = "left",
			wrap_word = true,
			x = 0,
			text = managers.localization:text(level_desc_text),
			w = text_w,
			h = text_h,
			font_size = tweak_data.menu.pd2_small_font_size,
			font = tweak_data.menu.pd2_small_font,
			color = level_desc_col,
			y = padding
		})

		BlackMarketGui.make_fine_text(self, level_warning)
		level_warning:set_top(desc:bottom() + padding)
	end
end

function CrimeSpreeContractMenuComponent:_get_button_index(button)
	for idx, btn in ipairs(self._buttons) do
		if button == btn then
			return idx
		end
	end

	return 1
end

function CrimeSpreeContractMenuComponent:set_active_starting_level(btn)
	if btn:can_activate() then
		for idx, btn in ipairs(self._buttons) do
			btn:set_active(false)
		end

		btn:set_active(true)
		managers.crime_spree:set_starting_level(btn:level())

		self._selected_index = self:_get_button_index(btn)
	else
		managers.menu_component:post_event("menu_error")
	end
end

function CrimeSpreeContractMenuComponent:mouse_moved(o, x, y)
	local used, pointer = nil

	for idx, btn in ipairs(self._buttons) do
		btn:set_selected(btn:inside(x, y))

		if btn:is_selected() then
			pointer = "link"
			used = true
		end
	end

	return used, pointer
end

function CrimeSpreeContractMenuComponent:mouse_pressed(o, button, x, y)
	for idx, btn in ipairs(self._buttons) do
		if btn:is_selected() and btn:callback() then
			btn:callback()()

			return true
		end
	end
end

function CrimeSpreeContractMenuComponent:mouse_wheel_up(x, y)
	if alive(self._scroll) then
		self._scroll:scroll(x, y, 1)
	end
end

function CrimeSpreeContractMenuComponent:mouse_wheel_down(x, y)
	if alive(self._scroll) then
		self._scroll:scroll(x, y, -1)
	end
end

function CrimeSpreeContractMenuComponent:special_btn_pressed(button)
	local change = 0

	if button == Idstring("menu_modify_item") then
		change = 1
	end

	if button == Idstring("voice_message") then
		change = -1
	end

	if change ~= 0 then
		local new_index = (self._selected_index or 0) + change

		if new_index > #self._buttons then
			new_index = 1
		end

		if new_index < 1 then
			new_index = #self._buttons
		end

		if self._buttons[new_index] then
			self:set_active_starting_level(self._buttons[new_index])
		end
	end
end

function CrimeSpreeContractMenuComponent:_setup_controller_input()
	self._gui = {
		_left_axis_vector = Vector3(),
		_right_axis_vector = Vector3()
	}

	self._ws:connect_controller(managers.menu:active_menu().input:get_controller(), true)
	self._panel:axis_move(callback(self, self, "_axis_move"))
end

function CrimeSpreeContractMenuComponent:_axis_move(o, axis_name, axis_vector, controller)
	if axis_name == Idstring("left") then
		mvector3.set(self._gui._left_axis_vector, axis_vector)
	elseif axis_name == Idstring("right") then
		mvector3.set(self._gui._right_axis_vector, axis_vector)
	end
end

function CrimeSpreeContractMenuComponent:update(t, dt)
	if not managers.menu:is_pc_controller() and self._gui and self._gui._right_axis_vector and alive(self._scroll) and not mvector3.is_zero(self._gui._right_axis_vector) then
		local x = mvector3.x(self._gui._right_axis_vector)
		local y = mvector3.y(self._gui._right_axis_vector)

		self._scroll:perform_scroll(ScrollablePanel.SCROLL_SPEED * dt * 24, y)
	end
end

CrimeSpreeStartingLevelItem = CrimeSpreeStartingLevelItem or class(MenuGuiItem)
CrimeSpreeStartingLevelItem.size = {
	h = 140
}

function CrimeSpreeStartingLevelItem:init(parent, data)
	local padding = tweak_data.gui.crime_net.contract_gui.padding
	self._parent = parent
	self._level = data.level or 0
	self._start_cost = managers.crime_spree:get_start_cost(self._level)
	local index = data.index or 1
	local w = (parent:w() - padding * (data.num_items - 1)) / data.num_items
	local h = 48
	local x = padding * (index - 1) + w * (index - 1)
	local y = padding
	self._panel = parent:panel({
		w = data.w or w,
		h = data.h or CrimeSpreeStartingLevelItem.size.h,
		x = data.x or x,
		y = data.y or y
	})

	BoxGuiObject:new(self._panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	self._bg = self._panel:rect({
		alpha = 0.4,
		layer = -1,
		color = Color.black
	})
	self._highlight = self._panel:rect({
		blend_mode = "add",
		layer = 1,
		color = tweak_data.screen_colors.button_stage_3
	})
	self._active_bg = self._panel:rect({
		alpha = 0.8,
		blend_mode = "add",
		layer = 0,
		color = tweak_data.screen_colors.button_stage_3
	})
	local level_w = self._level / (data.highest_level or 100)
	level_w = level_w == 0 and 10 or self._panel:w() * level_w
	self._level_bg = self._panel:rect({
		blend_mode = "add",
		alpha = 0.2,
		layer = -1,
		color = Color.white,
		w = level_w
	})

	self._level_bg:set_visible(false)

	self._text = self._panel:text({
		halign = "center",
		vertical = "center",
		layer = 1,
		align = "center",
		x = 0,
		valign = "center",
		text = data.text or managers.localization:text("menu_cs_level", {
			level = self._level
		}),
		y = self._panel:h() * 0.25,
		h = tweak_data.menu.pd2_large_font_size,
		color = tweak_data.screen_colors.crime_spree_risk,
		font = tweak_data.menu.pd2_large_font,
		font_size = tweak_data.menu.pd2_large_font_size
	})
	self._cost_text = self._panel:text({
		layer = 1,
		vertical = "center",
		halign = "center",
		align = "center",
		valign = "center",
		text = data.cost_text or managers.localization:text("menu_cs_coin_cost", {
			coins = managers.experience:cash_string(math.floor(self._start_cost), "")
		}),
		y = self._panel:h() - padding * 2 - tweak_data.menu.pd2_medium_font_size,
		h = tweak_data.menu.pd2_medium_font_size,
		color = Color.white,
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size
	})

	if data.is_maximum then
		self._maximum_text = self._panel:text({
			layer = 1,
			vertical = "center",
			halign = "center",
			alpha = 0.6,
			align = "center",
			valign = "center",
			text = managers.localization:to_upper_text("menu_cs_maximum"),
			y = self._text:top() - tweak_data.menu.pd2_medium_font_size - 5,
			h = tweak_data.menu.pd2_medium_font_size,
			color = Color.white,
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size
		})
	end

	local coins = 0
	coins = managers.custom_safehouse:coins()

	if coins < self._start_cost then
		self._highlight:set_color(tweak_data.screen_colors.important_1)
		self._active_bg:set_color(tweak_data.screen_colors.important_1)
		self._cost_text:set_color(tweak_data.screen_colors.important_1)
	end

	self._outline_panel = self._panel:panel({})

	BoxGuiObject:new(self._outline_panel, {
		sides = {
			2,
			2,
			2,
			2
		}
	})
	self:refresh()
end

function CrimeSpreeStartingLevelItem:refresh()
	self._bg:set_visible(not self:is_selected())
	self._highlight:set_visible(not self:is_active() and self:is_selected())
	self._active_bg:set_visible(self:is_active())
	self._outline_panel:set_visible(self:is_active())

	local coins = 0
	coins = managers.custom_safehouse:coins()

	if coins < self._start_cost then
		self._level_bg:set_color(tweak_data.screen_colors.important_1)
		self._highlight:set_alpha(self:is_selected() and 0.6 or 0.2)
	else
		self._level_bg:set_color(self:is_active() and tweak_data.screen_colors.button_stage_3 or Color.white)
		self._level_bg:set_alpha(self:is_active() and 1 or 0.2)
	end
end

function CrimeSpreeStartingLevelItem:can_activate()
	return self._start_cost <= managers.custom_safehouse:coins()
end

function CrimeSpreeStartingLevelItem:inside(x, y)
	return self._panel:inside(x, y)
end

function CrimeSpreeStartingLevelItem:callback()
	return self._callback
end

function CrimeSpreeStartingLevelItem:set_callback(clbk)
	self._callback = clbk
end

function CrimeSpreeStartingLevelItem:level()
	return self._level
end

function CrimeSpreeStartingLevelItem:panel()
	return self._panel
end

MenuCrimeNetCrimeSpreeContractInitiator = MenuCrimeNetCrimeSpreeContractInitiator or class()

function MenuCrimeNetCrimeSpreeContractInitiator:modify_node(original_node, data)
	local node = deep_clone(original_node)

	if Global.game_settings.single_player then
		node:item("toggle_ai"):set_value(Global.game_settings.team_ai and Global.game_settings.team_ai_option or 0)
	elseif data.smart_matchmaking then
		-- Nothing
	elseif data.id == "crime_spree" then
		node:item("lobby_kicking_option"):set_value(Global.game_settings.kick_option)
		node:item("lobby_permission"):set_value(Global.game_settings.permission)
		node:item("lobby_reputation_permission"):set_value(Global.game_settings.reputation_permission)
		node:item("lobby_drop_in_option"):set_value(Global.game_settings.drop_in_option)
		node:item("toggle_ai"):set_value(Global.game_settings.team_ai and Global.game_settings.team_ai_option or 0)
		node:item("toggle_auto_kick"):set_value(Global.game_settings.auto_kick and "on" or "off")
		node:item("toggle_allow_modded_players"):set_value(Global.game_settings.allow_modded_players and "on" or "off")

		if tweak_data.quickplay.stealth_levels[data.job_id] then
			local job_plan_item = node:item("lobby_job_plan")
			local stealth_option = nil

			for _, option in ipairs(job_plan_item:options()) do
				if option:value() == 2 then
					stealth_option = option

					break
				end
			end

			job_plan_item:clear_options()
			job_plan_item:add_option(stealth_option)
		end
	end

	node:item("accept_contract"):set_enabled(managers.crime_spree:unlocked())

	if data and data.back_callback then
		table.insert(node:parameters().back_callback, data.back_callback)
	end

	node:parameters().menu_component_data = data

	return node
end
