MenuItemTextBox = MenuItemTextBox or class(MenuItemInput)
MenuItemTextBox.TYPE = "textbox"

function MenuItemTextBox:init(data_node, parameters)
	MenuItemTextBox.super.init(self, data_node, parameters)

	self._type = MenuItemTextBox.TYPE
	self._row_height = nil
	self._row_count = self._parameters.rows or 5
	self._panel_row_count = self._row_count + 1
	self._editing = false
	self._should_disable = false
	self._scroll_pos = 0
end

function MenuItemTextBox:_ctrl()
	local k = Input:keyboard()

	return k:down(Idstring("left ctrl")) or k:down(Idstring("right ctrl")) or k:has_button(Idstring("ctrl")) and k:down(Idstring("ctrl"))
end

function MenuItemTextBox:setup_gui(node, row_item)
	local right_align = node:_right_align()
	row_item.gui_panel = node.item_panel:panel({
		alpha = 0.9,
		w = node.item_panel:w()
	})
	row_item.gui_text = node:_text_item_part(row_item, row_item.gui_panel, right_align, row_item.align)
	row_item.title_text = node:_text_item_part(row_item, row_item.gui_panel, right_align, row_item.align)
	row_item.input_bg = row_item.gui_panel:rect({
		alpha = 0,
		vertical = "scale",
		blend_mdoe = "add",
		halign = "scale",
		align = "scale",
		valign = "scale",
		color = Color(0.5, 0.5, 0.5),
		layer = node.layers.items - 1
	})

	row_item.title_text:set_alpha(1)
	row_item.gui_text:set_text("")

	row_item.caret = row_item.gui_panel:rect({
		rotation = 360,
		name = "caret",
		h = 0,
		w = 0,
		blend_mode = "add",
		y = 0,
		x = 0,
		color = Color(0.1, 1, 1, 1),
		layer = node.layers.items + 2
	})

	self:_layout_gui(node, row_item)

	return true
end

function MenuItemTextBox:_layout_gui(node, row_item)
	local safe_rect = managers.gui_data:scaled_size()
	local right_align = node:_right_align()
	local left_align = node:_left_align()

	row_item.gui_text:set_text(self._input_text or "")

	local n = utf8.len(row_item.gui_text:text())

	row_item.gui_text:set_selection(n, n)
	row_item.gui_text:set_vertical("top")
	row_item.gui_text:set_wrap(true)

	local _, _, w, h = row_item.title_text:text_rect()

	row_item.gui_panel:set_height(h * self._panel_row_count)
	row_item.gui_panel:set_width(safe_rect.width - node:_mid_align())
	row_item.gui_panel:set_x(node:_mid_align())

	self._align_right = row_item.gui_panel:w()
	self._align_left = node:_right_align() - row_item.gui_panel:x()

	self:_layout(row_item)
end

function MenuItemTextBox:_layout(row_item)
	local w = row_item.gui_panel:w()

	row_item.gui_text:set_width(w - 10)

	local _, _, w, h = row_item.title_text:text_rect()

	row_item.title_text:set_h(h)
	row_item.title_text:set_width(w + 5)

	_, _, w, h = row_item.gui_text:text_rect()

	row_item.gui_text:set_y(row_item.gui_text:line_height() + self._scroll_pos)
	row_item.gui_text:set_h(h)

	if row_item.align == "right" then
		row_item.gui_text:set_left(self._align_left)
		row_item.title_text:set_right(self._align_right)
	else
		row_item.gui_text:set_right(self._align_right)
		row_item.title_text:set_left(self._align_left)
	end

	row_item.gui_text:set_align("left")
	self:_update_caret(row_item)
	self:_update_input_bg(row_item)

	return true
end

function MenuItemTextBox:_update_input_bg(row_item)
	if not row_item or not alive(row_item.gui_text) then
		return
	end

	row_item.input_bg:set_alpha(self._editing and 0.6 or 0)
end

function MenuItemTextBox:highlight_row_item(node, row_item, mouse_over)
	row_item.gui_text:set_color(row_item.color)
	row_item.title_text:set_color(row_item.color)
	self:_on_focus(row_item)

	return true
end

function MenuItemTextBox:fade_row_item(node, row_item, mouse_over)
	row_item.gui_text:set_color(row_item.color)
	row_item.title_text:set_color(row_item.color)
	self:_loose_focus(row_item)

	return true
end

function MenuItemTextBox:esc_key_released_callback(row_item)
	if not row_item or not alive(row_item.gui_text) then
		return
	end

	self:_set_enabled(false)
	row_item.gui_text:set_text(self:input_text() or "")
	self:_layout(row_item)
end

function MenuItemTextBox:enter_key_released_callback(row_item)
	if not row_item or not alive(row_item.gui_text) then
		return
	end

	if not self._editing then
		self:_set_enabled(true)

		return
	end

	if self:_shift() then
		self:_insert_line_break(row_item)

		return
	end

	self:_set_enabled(false)

	local text = row_item.gui_text
	local message = text:text()

	self:set_input_text(message)
	self:_layout(row_item)
end

function MenuItemTextBox:_insert_line_break(row_item)
	local text = row_item.gui_text

	text:replace_text("\n")
end

function MenuItemTextBox:_set_enabled(enabled)
	if not self:enabled() then
		return
	end

	if enabled then
		self._editing = true

		managers.menu:active_menu().input:set_back_enabled(false)
		managers.menu:active_menu().input:accept_input(false)
		managers.menu:active_menu().input:deactivate_mouse()
	else
		self._editing = false

		managers.menu:active_menu().input:activate_mouse()
		managers.menu:active_menu().input:accept_input(true)
		managers.menu:active_menu().input:set_back_enabled(true)
	end
end

function MenuItemTextBox:_animate_input_bg(input_bg)
	local t = 0

	while true do
		local dt = coroutine.yield()
		t = t + dt
		local a = 0.75 + (1 + math.sin(t * 200)) / 8

		input_bg:set_alpha(a)
	end
end

function MenuItemTextBox:trigger()
	if type(self._enter_released_callback) ~= "number" then
		self._enter_released_callback()
	end

	for _, callback in pairs((self:enabled() or self:parameters().ignore_disabled) and self:parameters().callback or self:parameters().callback_disabled) do
		callback(self)
	end
end

function MenuItemTextBox:_on_focus(row_item)
	if self._focus then
		return
	end

	self._focus = true

	row_item.gui_panel:stop()
	row_item.gui_panel:animate(callback(self, self, "_animate_show_input"))
	row_item.node_gui.ws:connect_keyboard(Input:keyboard())
	row_item.gui_panel:key_press(callback(self, self, "key_press", row_item))
	row_item.gui_panel:enter_text(callback(self, self, "enter_text", row_item))
	row_item.gui_panel:key_release(callback(self, self, "key_release", row_item))
	row_item.node_gui.ws:connect_mouse(Input:mouse())
	row_item.gui_panel:mouse_press(callback(self, self, "mouse_press", row_item))

	self._esc_released_callback = callback(self, self, "esc_key_released_callback", row_item)
	self._enter_released_callback = callback(self, self, "enter_key_released_callback", row_item)
	self._typing_callback = 0
	self._enter_text_set = false

	self:_layout(row_item)
end

function MenuItemTextBox:_loose_focus(row_item)
	if not self._focus then
		return false
	end

	self._focus = false
	self._one_scroll_up_delay = nil
	self._one_scroll_dn_delay = nil
	local text = row_item.gui_text

	text:set_text(self._input_text or "")

	local n = utf8.len(text:text())

	text:set_selection(n, n)
	row_item.node_gui.ws:disconnect_keyboard()
	row_item.gui_panel:mouse_press(nil)
	row_item.node_gui.ws:disconnect_mouse()
	row_item.gui_panel:key_press(nil)
	row_item.gui_panel:enter_text(nil)
	row_item.gui_panel:key_release(nil)

	self._esc_released_callback = 0
	self._enter_released_callback = 0
	self._typing_callback = 0

	row_item.gui_panel:stop()
	row_item.gui_panel:animate(callback(self, self, "_animate_hide_input"))

	local text = row_item.gui_text

	text:stop()

	if not managers.menu:active_menu().input._mouse_active and table.empty(managers.mouse_pointer._mouse_callbacks) then
		managers.menu:active_menu().input:activate_mouse()
	end

	self:_layout(row_item)

	return true
end

function MenuItemTextBox:_update_caret(row_item)
	local text = row_item.gui_text
	local caret = row_item.caret
	local s, e = text:selection()
	local x, y, w, h = text:selection_rect()

	if s == 0 and e == 0 then
		if text:align() == "center" then
			x = text:world_x() + text:w() / 2
		elseif text:align() == "right" then
			x = text:world_right()
		else
			x = text:world_left()
		end

		y = text:world_y()
	end

	if s == e and s > 0 then
		text:set_selection(s, e + 1)

		if text:selected_text() == "\n" then
			text:set_selection(s - 1, e - 1)

			x, y, w, h = text:selection_rect()

			text:set_selection(s - 1, e)

			local _, _, dw, _ = text:selection_rect()
			x = x + dw
		end

		text:set_selection(s, e)
	end

	h = text:line_height()

	if w < 3 then
		w = 3
	end

	if not self._editing then
		w = 0
		h = 0
	end

	caret:set_world_shape(x, y + 2, w, h - 4)

	if row_item.align == "right" then
		caret:set_world_right(x)
	end

	self:set_blinking(s == e and self._editing, row_item)
end

function MenuItemTextBox:_get_current_line(text)
	local line_breaks = text:line_breaks()

	if #line_breaks <= 1 then
		return 1
	end

	line_breaks[1] = -1
	local s, e = text:selection()

	for i, lb in ipairs(line_breaks) do
		if e <= lb then
			return i - 1
		end
	end

	return #line_breaks
end

function MenuItemTextBox:enter_text(row_item, o, s)
	if not row_item or not alive(row_item.gui_text) or not self._editing or self:_ctrl() then
		return
	end

	if self._skip_first then
		self._skip_first = false

		return
	end

	local text = row_item.gui_text
	local m = self._input_limit
	local n = utf8.len(text:text())
	s = utf8.sub(s, 1, m - n)

	if type(self._typing_callback) ~= "number" then
		self._typing_callback()
	end

	text:replace_text(s)
	self:_layout(row_item)
end

function MenuItemTextBox:update_key_down(row_item, o, k)
	if not row_item or not alive(row_item.gui_text) then
		return
	end

	wait(0.6)

	while self._key_pressed == k do
		self:handle_key(row_item, o, k)
		self:_layout(row_item)
		wait(0.03)
	end
end

function MenuItemTextBox:key_release(row_item, o, k)
	if not row_item or not alive(row_item.gui_text) or not self._editing then
		return
	end

	if self._key_pressed == k then
		self._key_pressed = false
	end

	if k == Idstring("esc") then
		if self._editing and type(self._esc_released_callback) ~= "number" then
			self._esc_released_callback()
		end
	elseif k == Idstring("enter") and self._should_disable then
		self._should_disable = false

		self:trigger()
	end
end

function MenuItemTextBox:key_press(row_item, o, k)
	if not row_item or not alive(row_item.gui_text) or not self._editing then
		return
	end

	local text = row_item.gui_text
	self._key_pressed = k

	text:stop()
	text:animate(callback(self, self, "update_key_down", row_item), k)
	self:handle_key(row_item, o, k)
	self:_layout(row_item)
end

function MenuItemTextBox:find_first_non_letter(str)
	local latin_str = utf8.to_latin1(str)

	return string.find(latin_str, utf8.to_latin1("[^A-Za-z0-9ÅÄÖåäöÁÉÓÚÍÝáéóúíýÂÊÛÎÔâêûîôÃÕÑãõñÜËüë]"))
end

function MenuItemTextBox:find_last_non_letter(str)
	return self:find_first_non_letter(utf8.reverse(str))
end

function MenuItemTextBox:handle_key(row_item, o, k)
	local text = row_item.gui_text
	local s, e = text:selection()
	local n = utf8.len(text:text())
	local d = math.abs(e - s)

	if k == Idstring("backspace") then
		if s == e and s > 0 then
			if self:_ctrl() then
				local prev_text = utf8.sub(text:text(), 1, s)
				local index = self:find_last_non_letter(prev_text)

				if index then
					index = index - 1
				else
					index = s
				end

				if index == 0 then
					index = index + 1
				end

				text:set_selection(s - index, e)
			else
				text:set_selection(s - 1, e)
			end
		end

		text:replace_text("")
	elseif k == Idstring("delete") then
		if s == e and s < n then
			if self:_ctrl() then
				local next_text = utf8.sub(text:text(), s + 1)
				local index = self:find_first_non_letter(next_text)

				if index then
					index = index - 1
				else
					index = n - s
				end

				if index == 0 then
					index = index + 1
				end

				text:set_selection(s, e + index)
			else
				text:set_selection(s, e + 1)
			end
		end

		text:replace_text("")
	elseif k == Idstring("insert") or self:_ctrl() and k == Idstring("v") then
		local clipboard = Application:get_clipboard() or ""

		if self._input_limit < n + utf8.len(clipboard) then
			clipboard = utf8.sub(clipboard, 1, self._input_limit - n)
		end

		text:replace_text(clipboard)
	elseif k == Idstring("left") then
		if s < e then
			text:set_selection(s, s)
		elseif s > 0 then
			if self:_ctrl() then
				local prev_text = utf8.sub(text:text(), 1, s)
				local index = self:find_last_non_letter(prev_text)

				if index then
					index = index - 1
				else
					index = s
				end

				if index == 0 then
					index = index + 1
				end

				text:set_selection(s - index, s - index)
			else
				text:set_selection(s - 1, s - 1)
			end
		end
	elseif k == Idstring("right") then
		if s < e then
			text:set_selection(e, e)
		elseif s < n then
			if self:_ctrl() then
				local next_text = utf8.sub(text:text(), s + 1)
				local index = self:find_first_non_letter(next_text)

				if index then
					index = index - 1
				else
					index = n - s
				end

				if index == 0 then
					index = index + 1
				end

				text:set_selection(s + index, s + index)
			else
				text:set_selection(s + 1, s + 1)
			end
		end
	elseif k == Idstring("up") then
		local line_breaks = text:line_breaks()

		if #line_breaks < 2 or #line_breaks >= 2 and e <= line_breaks[2] then
			text:set_selection(0, 0)
		else
			table.insert(line_breaks, n)

			line_breaks[1] = -1

			for i, lb in ipairs(line_breaks) do
				if e <= lb then
					local line_end = line_breaks[i - 1]
					local prev_line_end = line_breaks[i - 2]
					local new_index = math.min(prev_line_end + e - line_end, line_end)

					text:set_selection(new_index, new_index)

					break
				end
			end
		end
	elseif k == Idstring("down") then
		local line_breaks = text:line_breaks()

		if #line_breaks < 2 or #line_breaks >= 2 and line_breaks[#line_breaks] < e then
			text:set_selection(n, n)
		else
			table.insert(line_breaks, n)

			line_breaks[1] = -1

			for i, lb in ipairs(line_breaks) do
				if e <= lb then
					local next_line_end = line_breaks[i + 1] or lb
					local line_end = lb
					local prev_line_end = line_breaks[i - 1] or -1
					local new_index = math.min(e - prev_line_end + line_end, next_line_end)

					text:set_selection(new_index, new_index)

					break
				end
			end
		end
	elseif self._key_pressed == Idstring("end") then
		local line_breaks = text:line_breaks()
		local new_index = n

		if #line_breaks > 1 then
			table.insert(line_breaks, n)

			line_breaks[1] = -1

			for i, lb in ipairs(line_breaks) do
				if e <= lb then
					new_index = lb

					break
				end
			end
		end

		text:set_selection(new_index, new_index)
	elseif self._key_pressed == Idstring("home") then
		local line_breaks = text:line_breaks()
		local new_index = 0

		if #line_breaks > 1 then
			table.insert(line_breaks, n)

			line_breaks[1] = -1

			for i, lb in ipairs(line_breaks) do
				if e <= lb then
					new_index = line_breaks[i - 1] + 1

					break
				end
			end
		end

		text:set_selection(new_index, new_index)
	elseif k == Idstring("enter") then
		self._should_disable = true
	elseif self:_ctrl() and k == Idstring("s") then
		self:set_input_text(text:text())
	end

	if not self:is_line_visible(row_item, self:_get_current_line(text)) then
		self:scroll_to_line(row_item, self:_get_current_line(text))
	end
end

function MenuItemTextBox:mouse_press(row_item, o, k, x, y)
	if k ~= Idstring("mouse wheel up") and k ~= Idstring("mouse wheel down") then
		return
	end

	if k == Idstring("mouse wheel up") then
		self:scroll(row_item, 5)
	elseif k == Idstring("mouse wheel down") then
		self:scroll(row_item, -5)
	end
end

function MenuItemTextBox:scroll(row_item, amount)
	self:set_scroll_pos(row_item, self._scroll_pos + amount)
end

function MenuItemTextBox:scroll_to_line(row_item, line, direction)
	local scroll_pos_abs = math.abs(self._scroll_pos)
	direction = direction or scroll_pos_abs > line * row_item.gui_text:line_height() and "up" or "down"

	print(direction)

	if direction == "up" then
		local scroll_pos = line * row_item.gui_text:line_height()

		if scroll_pos_abs > scroll_pos then
			self:set_scroll_pos(row_item, -scroll_pos)
		end
	elseif direction == "down" then
		local scroll_pos = math.max(line - self._row_count, 0) * row_item.gui_text:line_height()

		if scroll_pos_abs < scroll_pos then
			self:set_scroll_pos(row_item, -scroll_pos)
		end
	end
end

function MenuItemTextBox:is_line_visible(row_item, line)
	local text = row_item.gui_text

	if text:number_of_lines() <= self._row_count and self._scroll_pos == 0 then
		return true
	end

	local scroll_pos_abs = math.abs(self._scroll_pos)
	local line_pos = line * text:line_height()
	local max_visible = self._row_count * text:line_height() + scroll_pos_abs

	if scroll_pos_abs <= line_pos and line_pos <= max_visible then
		return true
	end

	return false
end

function MenuItemTextBox:set_scroll_pos(row_item, pos)
	local text = row_item.gui_text
	local max_scroll = math.max(text:number_of_lines() - self._row_count, 0) * text:line_height() * -1

	if max_scroll == 0 then
		self._scroll_pos = 0

		return
	end

	self._scroll_pos = math.min(math.max(pos, max_scroll), 0)

	self:_layout(row_item)
end
