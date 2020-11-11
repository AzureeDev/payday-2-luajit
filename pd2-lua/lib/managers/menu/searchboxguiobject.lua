local medium_font = tweak_data.menu.pd2_medium_font
local medium_font_size = tweak_data.menu.pd2_medium_font_size
SearchBoxGuiObject = SearchBoxGuiObject or class()

function SearchBoxGuiObject:init(parent_panel, ws)
	self._ws = ws
	self._sorting_list = {}

	self:set_searchbox(parent_panel)
end

function SearchBoxGuiObject:set_searchbox(parent_panel)
	self.panel = parent_panel:panel({
		w = 256,
		alpha = 1,
		layer = 15,
		h = medium_font_size
	})

	self.panel:rect({
		visible = true,
		layer = -1,
		color = Color.black:with_alpha(0.25)
	})
	BoxGuiObject:new(self.panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	self.placeholder_text = self.panel:text({
		vertical = "top",
		align = "center",
		alpha = 0.6,
		layer = 2,
		text = managers.localization:to_upper_text("menu_filter_search"),
		font = medium_font,
		font_size = medium_font_size,
		color = tweak_data.screen_colors.text
	})
	self.text = self.panel:text({
		vertical = "top",
		alpha = 1,
		align = "center",
		text = "",
		layer = 2,
		font = medium_font,
		font_size = medium_font_size,
		color = tweak_data.screen_colors.text,
		w = self.panel:w() - 3
	})
	self.caret = self.panel:rect({
		name = "caret",
		h = 0,
		y = 0,
		w = 0,
		x = 0,
		layer = 200,
		color = Color(0.05, 1, 1, 1)
	})

	self.caret:set_right(self.panel:w() * 0.5)
end

function SearchBoxGuiObject:register_callback(callback)
	self._finish_sorting_callback = callback
end

function SearchBoxGuiObject:register_list(list)
	self._sorting_list = list
end

function SearchBoxGuiObject:mouse_pressed(button, x, y)
	if button == Idstring("0") and self.panel:inside(x, y) then
		self:connect_search_input()
	elseif self._focus then
		self:disconnect_search_input()
	end
end

function SearchBoxGuiObject:build_and_apply_filter(search_string)
	local index_list = {}

	for index, list_item in ipairs(self._sorting_list) do
		for _, string_item in ipairs(list_item) do
			local item_text = utf8.to_lower(managers.localization:text(string_item))
			local value = string.find(item_text, string.lower(self.text:text()))

			if value ~= nil then
				table.insert(index_list, index)

				break
			end
		end
	end

	self._finish_sorting_callback(index_list, self.text:text())
end

function SearchBoxGuiObject:input_focus()
	return self._focus
end

SearchBoxGuiObject.MAX_SEARCH_LENGTH = 28

function SearchBoxGuiObject:connect_search_input()
	if self._adding_to_data or self._focus then
		return
	end

	self._ws:connect_keyboard(Input:keyboard())

	if _G.IS_VR then
		Input:keyboard():show_with_text(self.text:text())
	end

	self.panel:key_press(callback(self, self, "search_key_press"))
	self.panel:key_release(callback(self, self, "search_key_release"))

	self._enter_callback = callback(self, self, "enter_key_callback")
	self._esc_callback = callback(self, self, "esc_key_callback")
	self._focus = true

	self:update_caret()
end

function SearchBoxGuiObject:disconnect_search_input()
	if self._focus then
		self._ws:disconnect_keyboard()
		self.panel:key_press(nil)
		self.panel:key_release(nil)

		if self._key_pressed then
			self:search_key_release(nil, self._key_pressed)
		end

		self._focus = nil

		self:update_caret()
	end
end

function SearchBoxGuiObject:search_key_press(o, k)
	if self._skip_first then
		self._skip_first = false

		return
	end

	if not self._enter_text_set then
		self.panel:enter_text(callback(self, self, "enter_text"))

		self._enter_text_set = true
	end

	local text = self.text
	local s, e = text:selection()
	local n = utf8.len(text:text())
	local d = math.abs(e - s)
	self._key_pressed = k

	text:stop()
	text:animate(callback(self, self, "update_key_down"), k)

	local len = utf8.len(text:text())

	text:clear_range_color(0, len)

	if k == Idstring("backspace") then
		if s == e and s > 0 then
			text:set_selection(s - 1, e)
		end

		text:replace_text("")
		self:enter_text()
	elseif k == Idstring("delete") then
		if s == e and s < n then
			text:set_selection(s, e + 1)
		end

		text:replace_text("")
	elseif k == Idstring("insert") then
		local clipboard = Application:get_clipboard() or ""

		text:replace_text(clipboard)

		local lbs = text:line_breaks()

		if SearchBoxGuiObject.MAX_SEARCH_LENGTH < #text:text() then
			text:set_text(string.sub(text:text(), 1, SearchBoxGuiObject.MAX_SEARCH_LENGTH))
		end

		if #lbs > 1 then
			local s = lbs[2]
			local e = utf8.len(text:text())

			text:set_selection(s, e)
			text:replace_text("")
		end
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
	elseif self._key_pressed == Idstring("end") then
		text:set_selection(n, n)
	elseif self._key_pressed == Idstring("home") then
		text:set_selection(0, 0)
	elseif k == Idstring("enter") then
		if type(self._enter_callback) ~= "number" then
			self._enter_callback()
		end
	elseif k == Idstring("esc") and type(self._esc_callback) ~= "number" then
		if not _G.IS_VR then
			text:set_text("")
			text:set_selection(0, 0)
		end

		self._esc_callback()
	end

	self:update_caret()
end

function SearchBoxGuiObject:search_key_release(o, k)
	if self._key_pressed == k then
		self._key_pressed = false
	end
end

function SearchBoxGuiObject:update_key_down(o, k)
	wait(0.6)

	local text = self.text

	while self._key_pressed == k do
		local s, e = text:selection()
		local n = utf8.len(text:text())
		local d = math.abs(e - s)

		if self._key_pressed == Idstring("backspace") then
			if s == e and s > 0 then
				text:set_selection(s - 1, e)
			end

			text:replace_text("")
		elseif self._key_pressed == Idstring("delete") then
			if s == e and s < n then
				text:set_selection(s, e + 1)
			end

			text:replace_text("")
		elseif self._key_pressed == Idstring("insert") then
			local clipboard = Application:get_clipboard() or ""

			text:replace_text(clipboard)

			if SearchBoxGuiObject.MAX_SEARCH_LENGTH < #text:text() then
				text:set_text(string.sub(text:text(), 1, SearchBoxGuiObject.MAX_SEARCH_LENGTH))
			end

			local lbs = text:line_breaks()

			if #lbs > 1 then
				local s = lbs[2]
				local e = utf8.len(text:text())

				text:set_selection(s, e)
				text:replace_text("")
			end
		elseif self._key_pressed == Idstring("left") then
			if s < e then
				text:set_selection(s, s)
			elseif s > 0 then
				text:set_selection(s - 1, s - 1)
			end
		elseif self._key_pressed == Idstring("right") then
			if s < e then
				text:set_selection(e, e)
			elseif s < n then
				text:set_selection(s + 1, s + 1)
			end
		else
			self._key_pressed = false
		end

		self:update_caret()
		wait(0.03)
	end
end

function SearchBoxGuiObject:enter_text(o, s)
	if self._skip_first then
		self._skip_first = false

		return
	end

	local text = self.text

	if #text:text() < SearchBoxGuiObject.MAX_SEARCH_LENGTH then
		if _G.IS_VR then
			text:set_text(s)
		else
			text:replace_text(s)
		end
	end

	local lbs = text:line_breaks()

	if #lbs > 1 then
		local s = lbs[2]
		local e = utf8.len(text:text())

		text:set_selection(s, e)
		text:replace_text("")
	end

	self:update_caret()
	self:build_and_apply_filter()
end

function SearchBoxGuiObject:enter_key_callback()
	self:build_and_apply_filter()
end

function SearchBoxGuiObject:esc_key_callback()
	call_on_next_update(function ()
		self:build_and_apply_filter()
		self:disconnect_search_input()
	end)
end

function SearchBoxGuiObject.blink(o)
	while true do
		o:set_color(Color(0, 1, 1, 1))
		wait(0.3)
		o:set_color(Color.white)
		wait(0.3)
	end
end

function SearchBoxGuiObject:set_blinking(b)
	local caret = self.caret

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
		caret:set_color(Color.white)
	end
end

function SearchBoxGuiObject:update_caret()
	local text = self.text
	local caret = self.caret
	local s, e = text:selection()
	local x, y, w, h = text:selection_rect()
	local text_s = text:text()

	if #text_s == 0 then
		x = text:world_center_x()
		y = text:world_y()
	end

	h = text:h()

	if w < 3 then
		w = 3
	end

	if not self._focus then
		w = 0
		h = 0
	end

	caret:set_world_shape(x, y + 2, w, h - 4)
	self:set_blinking(s == e and self._focus)
	self.placeholder_text:set_visible(not self._focus and #text_s == 0)
end
