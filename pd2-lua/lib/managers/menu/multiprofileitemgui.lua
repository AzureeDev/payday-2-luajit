MultiProfileItemGui = MultiProfileItemGui or class()
MultiProfileItemGui.quick_panel_w = 36
MultiProfileItemGui.quick_panel_h = 36
MultiProfileItemGui.profile_panel_w = 280
MultiProfileItemGui.profile_panel_h = 36
MultiProfileItemGui.padding = 5

function MultiProfileItemGui:init(ws, panel)
	self._ws = ws
	local panel_w = self.profile_panel_w
	local panel_h = self.profile_panel_h

	if managers.menu:is_pc_controller() then
		panel_w = self.quick_panel_w + self.padding + self.profile_panel_w
		panel_h = math.max(self.quick_panel_h, self.profile_panel_h)
	end

	self._panel = self._panel or panel:panel({
		w = panel_w,
		h = panel_h
	})

	self._panel:set_bottom(panel:bottom() - 4)
	self._panel:set_center_x(panel:w() / 2)

	self._profile_panel = self._profile_panel or self._panel:panel({
		w = self.profile_panel_w,
		h = self.profile_panel_h
	})

	self._profile_panel:set_center_y(self._panel:h() / 2)
	self._profile_panel:set_top(math.round(self._profile_panel:top()))

	local box_panel_w = self._profile_panel:w()

	if managers.menu:is_pc_controller() then
		self._quick_select_panel = self._quick_select_panel or self._panel:panel({
			w = self.quick_panel_w,
			h = self.quick_panel_h
		})

		self._quick_select_panel:set_left(self._profile_panel:right() + self.padding)
		self._quick_select_panel:set_center_y(self._panel:h() / 2)
		self._quick_select_panel:set_top(math.round(self._quick_select_panel:top()))

		if not self._quick_select_panel_elements then
			self._quick_select_panel_elements = {}

			table.insert(self._quick_select_panel_elements, self._quick_select_panel:rect({
				h = 3,
				y = 7,
				w = 5,
				x = 5,
				color = tweak_data.screen_colors.button_stage_3
			}))
			table.insert(self._quick_select_panel_elements, self._quick_select_panel:rect({
				h = 3,
				y = 7,
				w = 16,
				x = 12,
				color = tweak_data.screen_colors.button_stage_3
			}))
			table.insert(self._quick_select_panel_elements, self._quick_select_panel:rect({
				h = 3,
				y = 13,
				w = 5,
				x = 5,
				color = tweak_data.screen_colors.button_stage_3
			}))
			table.insert(self._quick_select_panel_elements, self._quick_select_panel:rect({
				h = 3,
				y = 13,
				w = 16,
				x = 12,
				color = tweak_data.screen_colors.button_stage_3
			}))
			table.insert(self._quick_select_panel_elements, self._quick_select_panel:rect({
				h = 3,
				y = 19,
				w = 5,
				x = 5,
				color = tweak_data.screen_colors.button_stage_3
			}))
			table.insert(self._quick_select_panel_elements, self._quick_select_panel:rect({
				h = 3,
				y = 19,
				w = 16,
				x = 12,
				color = tweak_data.screen_colors.button_stage_3
			}))
			table.insert(self._quick_select_panel_elements, self._quick_select_panel:rect({
				h = 3,
				y = 25,
				w = 5,
				x = 5,
				color = tweak_data.screen_colors.button_stage_3
			}))
			table.insert(self._quick_select_panel_elements, self._quick_select_panel:rect({
				h = 3,
				y = 25,
				w = 16,
				x = 12,
				color = tweak_data.screen_colors.button_stage_3
			}))
		end

		box_panel_w = box_panel_w + self.quick_panel_w + self.padding
	end

	self._box_panel = self._panel:panel()

	self._box_panel:rect({
		alpha = 0.4,
		layer = -100,
		color = Color.black
	})

	self._box = BoxGuiObject:new(self._box_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	self._caret = self._profile_panel:rect({
		blend_mode = "add",
		name = "caret",
		h = 0,
		y = 0,
		w = 0,
		x = 0,
		color = Color(0.1, 1, 1, 1)
	})
	self._max_length = 15
	self._name_editing_enabled = true

	self:update()
end

function MultiProfileItemGui:panel()
	return self._panel
end

function MultiProfileItemGui:profile_panel()
	return self._profile_panel
end

function MultiProfileItemGui:set_name_editing_enabled(enabled)
	self._name_editing_enabled = enabled
end

function MultiProfileItemGui:update()
	local mult = managers.multi_profile
	local name = mult:current_profile_name()
	self._name_text = self._profile_panel:child("name")

	if alive(self._name_text) then
		self._profile_panel:remove(self._name_text)
	end

	self._name_text = self._profile_panel:text({
		name = "name",
		vertical = "center",
		align = "center",
		text = name,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.button_stage_3
	})
	local text_width = self._name_text:w()

	self._name_text:set_w(text_width * 0.8)
	self._name_text:set_left(text_width * 0.1)

	local arrow_left = self._profile_panel:child("arrow_left")

	if not arrow_left then
		if managers.menu:is_pc_controller() and not managers.menu:is_steam_controller() then
			arrow_left = self._profile_panel:bitmap({
				texture = "guis/textures/menu_arrows",
				name = "arrow_left",
				texture_rect = {
					24,
					0,
					24,
					24
				},
				color = mult:has_previous() and tweak_data.screen_colors.button_stage_3 or tweak_data.menu.default_disabled_text_color
			})
		else
			local BTN_TOP_L = managers.menu:is_steam_controller() and managers.localization:steam_btn("trigger_l") or managers.localization:get_default_macro("BTN_TOP_L")
			arrow_left = self._profile_panel:text({
				name = "arrow_left",
				h = 24,
				vertical = "center",
				w = 24,
				align = "center",
				text = BTN_TOP_L,
				color = not mult:has_previous() and Color(0, 0, 0, 0),
				font = tweak_data.menu.pd2_small_font,
				font_size = tweak_data.menu.pd2_small_font_size
			})
		end
	end

	local arrow_right = self._profile_panel:child("arrow_right")

	if not arrow_right then
		if managers.menu:is_pc_controller() and not managers.menu:is_steam_controller() then
			arrow_right = self._profile_panel:bitmap({
				texture = "guis/textures/menu_arrows",
				name = "arrow_right",
				size = 32,
				rotation = 180,
				texture_rect = {
					24,
					0,
					24,
					24
				},
				color = mult:has_next() and tweak_data.screen_colors.button_stage_3 or tweak_data.menu.default_disabled_text_color
			})
		else
			local BTN_TOP_R = managers.menu:is_steam_controller() and managers.localization:steam_btn("trigger_r") or managers.localization:get_default_macro("BTN_TOP_R")
			arrow_right = self._profile_panel:text({
				name = "arrow_right",
				h = 24,
				vertical = "center",
				w = 24,
				align = "center",
				text = BTN_TOP_R,
				color = not mult:has_next() and Color(0, 0, 0, 0),
				font = tweak_data.menu.pd2_small_font,
				font_size = tweak_data.menu.pd2_small_font_size
			})
		end
	end

	arrow_left:set_left(5)
	arrow_right:set_right(self._profile_panel:w() - 5)
	arrow_left:set_center_y(self._profile_panel:h() / 2)
	arrow_right:set_center_y(self._profile_panel:h() / 2)
	self:_update_caret()
end

function MultiProfileItemGui:mouse_moved(x, y)
	local function anim_func(o, large)
		local current_width = o:w()
		local current_height = o:h()
		local end_width = large and 32 or 24
		local end_height = end_width
		local cx, cy = o:center()

		over(0.2, function (p)
			o:set_size(math.lerp(current_width, end_width, p), math.lerp(current_height, end_height, p))
			o:set_center(cx, cy)
		end)
	end

	local mult = managers.multi_profile
	local pointer, used = nil
	local arrow_left = self._profile_panel:child("arrow_left")
	self._arrow_selection = nil

	if arrow_left and mult:has_previous() then
		if arrow_left:inside(x, y) then
			if self._is_left_selected ~= true then
				arrow_left:set_color(tweak_data.screen_colors.button_stage_2)
				arrow_left:animate(anim_func, true)
				managers.menu_component:post_event("highlight")

				self._is_left_selected = true
			end

			self._arrow_selection = "left"
			pointer = "link"
			used = true
		elseif self._is_left_selected == true then
			arrow_left:set_color(tweak_data.screen_colors.button_stage_3)
			arrow_left:animate(anim_func, false)

			self._is_left_selected = false
		end
	end

	local arrow_right = self._profile_panel:child("arrow_right")

	if arrow_right and mult:has_next() then
		if arrow_right:inside(x, y) then
			if self._is_right_selected ~= true then
				arrow_right:set_color(tweak_data.screen_colors.button_stage_2)
				arrow_right:animate(anim_func, true)
				managers.menu_component:post_event("highlight")

				self._is_right_selected = true
			end

			self._arrow_selection = "right"
			pointer = "link"
			used = true
		elseif self._is_right_selected == true then
			arrow_right:set_color(tweak_data.screen_colors.button_stage_3)
			arrow_right:animate(anim_func, false)

			self._is_right_selected = false
		end
	end

	if alive(self._quick_select_panel) then
		if self._quick_select_panel:inside(x, y) then
			if self._is_quick_selected ~= true then
				for _, element in ipairs(self._quick_select_panel_elements) do
					element:set_color(tweak_data.screen_colors.button_stage_2)
				end

				managers.menu_component:post_event("highlight")

				self._is_quick_selected = true
			end

			self._arrow_selection = "quick"
			pointer = "link"
			used = true
		elseif self._is_quick_selected == true then
			for _, element in ipairs(self._quick_select_panel_elements) do
				element:set_color(tweak_data.screen_colors.button_stage_3)
			end

			self._is_quick_selected = false
		end
	end

	if self._name_text:inside(x, y) then
		if not self._name_selection then
			self._name_text:set_color(tweak_data.screen_colors.button_stage_2)
			managers.menu_component:post_event("highlight")
		end

		self._name_selection = true
		pointer = "link"
		used = true
	elseif self._name_selection then
		self._name_text:set_color(tweak_data.screen_colors.button_stage_3)

		self._name_selection = false
	end

	return used, pointer
end

function MultiProfileItemGui:mouse_pressed(button, x, y)
	if button == Idstring("0") then
		if self:arrow_selection() == "left" then
			managers.multi_profile:previous_profile()
			managers.menu_component:post_event("menu_enter")

			return
		elseif self:arrow_selection() == "right" then
			managers.multi_profile:next_profile()
			managers.menu_component:post_event("menu_enter")

			return
		elseif self:arrow_selection() == "quick" then
			managers.multi_profile:open_quick_select()
			managers.menu_component:post_event("menu_enter")

			return
		end

		if self._name_selection then
			self:trigger()
		end
	end
end

function MultiProfileItemGui:arrow_selection()
	return self._arrow_selection
end

function MultiProfileItemGui:set_editing(editing)
	if not self._name_editing_enabled then
		return
	end

	self._editing = editing

	if editing then
		managers.menu:active_menu().input:set_back_enabled(false)
		managers.menu:active_menu().input:accept_input(false)
		managers.menu:active_menu().input:set_force_input(false)
		managers.menu:active_menu().input:deactivate_mouse()
		self._ws:connect_keyboard(Input:keyboard())
		self._profile_panel:key_press(callback(self, self, "key_press"))
		self._profile_panel:key_release(callback(self, self, "key_release"))
		self._profile_panel:enter_text(callback(self, self, "enter_text"))

		local n = utf8.len(self._name_text:text())

		self._name_text:set_selection(n, n)

		if _G.IS_VR then
			Input:keyboard():show_with_text(self._name_text:text(), self._max_length)
		end
	else
		managers.menu:active_menu().input:activate_mouse()
		managers.menu:active_menu().input:accept_input(true)
		managers.menu:active_menu().input:set_back_enabled(true)
		self._ws:disconnect_keyboard()
		self._profile_panel:key_press(nil)
		self._profile_panel:key_release(nil)
		self._profile_panel:enter_text(nil)
	end
end

function MultiProfileItemGui.blink(o)
	while true do
		o:set_color(Color(0.05, 1, 1, 1))
		wait(0.4)
		o:set_color(Color(0.9, 1, 1, 1))
		wait(0.4)
	end
end

function MultiProfileItemGui:set_blinking(b)
	local caret = self._caret

	if b == self._blinking then
		return
	end

	if b then
		caret:animate(self.blink)
	else
		caret:stop()
	end

	self._blinking = b

	if not self._blinking then
		caret:set_color(Color(0.9, 1, 1, 1))
	end
end

function MultiProfileItemGui:_update_caret()
	local text = self._name_text
	local caret = self._caret
	local s, e = text:selection()
	local x, y, w, h = text:selection_rect()

	if s == 0 and e == 0 and utf8.len(text:text()) == 0 then
		x = text:world_center()
		y = text:world_y() + 6
	end

	h = text:line_height()

	if w < 3 then
		w = 3
	end

	if not self._editing then
		w = 0
		h = 0
	end

	caret:set_world_shape(x, y + 2, w, h, -8)
	self:set_blinking(s == e and self._editing)
end

function MultiProfileItemGui:update_key_down(o, k)
	wait(0.6)

	while self._key_pressed == k do
		self:handle_key(k, true)
		self:_update_caret()
		wait(0.03)
	end
end

function MultiProfileItemGui:key_press(o, k)
	if not self._editing then
		return
	end

	local text = self._name_text
	self._key_pressed = k

	text:stop()
	text:animate(callback(self, self, "update_key_down"), k)
	self:handle_key(k, true)
	self:_update_caret()
end

function MultiProfileItemGui:key_release(o, k)
	if not self._editing then
		return
	end

	if self._key_pressed == k then
		self._key_pressed = nil
	end

	self:handle_key(k, false)
	self:_update_caret()
end

function MultiProfileItemGui:trigger()
	if not self._editing then
		self:set_editing(true)
	else
		local mult = managers.multi_profile

		if mult:current_profile() then
			mult:current_profile().name = self._name_text:text()
		end

		self:set_editing(false)
	end

	self:_update_caret()
end

function MultiProfileItemGui:enter_text(o, s)
	if not self._editing then
		return
	end

	if _G.IS_VR then
		self._name_text:set_text(s)
	else
		local s_len = utf8.len(self._name_text:text())
		s = utf8.sub(s, 1, self._max_length - s_len)

		self._name_text:replace_text(s)
	end
end

function MultiProfileItemGui:handle_key(k, pressed)
	local text = self._name_text
	local s, e = text:selection()
	local n = utf8.len(text:text())
	local d = math.abs(e - s)

	if pressed then
		if k == Idstring("backspace") then
			if s == e and s > 0 then
				text:set_selection(s - 1, e)
			end

			text:replace_text("")
		elseif k == Idstring("delete") then
			if s == e and s < n then
				text:set_selection(s, e + 1)
			end

			text:replace_text("")
		elseif k == Idstring("left") then
			if s < e then
				text:set_selection(s, s)
			elseif s > 0 then
				text:set_selection(s - 1, s - 1)
			end
		elseif k == Idstring("right") then
			if s < e then
				text:set_selection(e, e)
			elseif s < n then
				text:set_selection(s + 1, s + 1)
			end
		elseif k == Idstring("home") then
			text:set_selection(0, 0)
		elseif k == Idstring("end") then
			text:set_selection(n, n)
		end
	elseif k == Idstring("enter") then
		self:trigger()
	elseif k == Idstring("esc") then
		text:set_text(managers.multi_profile:current_profile_name())
		self:set_editing(false)
	end
end
