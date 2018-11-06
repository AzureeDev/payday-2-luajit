BookBoxGui = BookBoxGui or class(TextBoxGui)

function BookBoxGui:init(ws, title, config)
	config = config or {}
	config.h = config.h or 310
	config.w = config.w or 360
	local x, y = ws:size()
	config.x = config.x or x - config.w
	config.y = config.y or y - config.h - CoreMenuRenderer.Renderer.border_height
	self._header_type = config.header_type or "event"

	BookBoxGui.super.init(self, ws, title, nil, nil, config)

	self._pages = {}
	self._page_panels = {}
end

function BookBoxGui:add_page(name, box_gui, visible)
	local panel = self._panel:panel({
		h = 20,
		w = 40,
		x = 0,
		layer = 10,
		name = name
	})

	panel:rect({
		name = "bg_rect",
		layer = 0,
		color = Color(1, 0.5, 0.5, 0.5)
	})
	panel:text({
		y = 0,
		name = "name_text",
		vertical = "center",
		hvertical = "center",
		align = "center",
		halign = "center",
		x = 0,
		layer = 1,
		text = string.upper(name),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size
	})
	box_gui:set_visible(self._visible and (visible or false))
	box_gui:set_position(self:position())
	box_gui:set_size(self:size())
	box_gui:set_title(nil)
	box_gui._panel:child("bottom_line"):set_visible(false)
	box_gui._panel:child("top_line"):set_visible(false)
	table.insert(self._page_panels, panel)
	self:_layout_page_panels()

	self._pages[name] = {
		box_gui = box_gui,
		panel = panel
	}

	if visible then
		self:set_page(name)
	end
end

function BookBoxGui:has_page(name)
	return self._pages[name]
end

function BookBoxGui:_layout_page_panels()
	local total_w = 0

	for _, p in ipairs(self._page_panels) do
		local name_text = p:child("name_text")
		local _, _, wt, ht = name_text:text_rect()
		total_w = total_w + wt + 1
	end

	local w = 0

	for _, p in ipairs(self._page_panels) do
		local name_text = p:child("name_text")
		local _, _, wt, ht = name_text:text_rect()
		local ws = math.ceil(wt / total_w * self._panel:w())

		if self._header_type == "fit" then
			ws = wt + 10
		end

		p:set_size(ws, ht)
		name_text:set_size(ws, ht)
		name_text:set_center(p:w() / 2, p:h() / 2)
		p:child("bg_rect"):set_size(ws, ht)
		p:set_x(math.ceil(w))

		w = w + math.ceil(p:w()) + 2
	end
end

function BookBoxGui:remove_page(name)
	print("BookBoxGui:remove_page( name )", name)

	local page = self._pages[name]

	print("page", page)

	if not page then
		return
	end

	page.box_gui:close()

	self._pages[name] = nil

	print(":remove_page(", self._active_page_name, name)

	if self._active_page_name == name then
		self._active_page_name = nil
		local n, _ = next(self._pages)

		print("change to", n)
		self:set_page(n)
	end

	for i, panel in ipairs(self._page_panels) do
		if panel:name() == name then
			table.remove(self._page_panels, i)
			self._panel:remove(panel)
		end
	end

	self:_layout_page_panels()
end

function BookBoxGui:set_size(x, y)
	BookBoxGui.super.set_size(self, x, y)

	for name, page in pairs(self._pages) do
		page.box_gui:set_size(x, y)
	end
end

function BookBoxGui:set_centered()
	BookBoxGui.super.set_centered(self)

	for name, page in pairs(self._pages) do
		page.box_gui:set_position(self._panel:x(), self._panel:y())
	end
end

function BookBoxGui:set_position(x, y)
	BookBoxGui.super.set_position(self, x, y)

	for name, page in pairs(self._pages) do
		page.box_gui:set_position(x, y)
	end
end

function BookBoxGui:set_visible(visible)
	BookBoxGui.super.set_visible(self, visible)

	for name, page in pairs(self._pages) do
		page.box_gui:set_visible(visible and name == self._active_page_name)
	end
end

function BookBoxGui:set_enabled(enabled)
	BookBoxGui.super.set_enabled(self, enabled)

	for name, page in pairs(self._pages) do
		page.box_gui:set_enabled(enabled)
	end
end

function BookBoxGui:set_layer(layer)
	BookBoxGui.super.set_layer(self, layer)

	for name, page in pairs(self._pages) do
		page.box_gui:set_layer(layer)
	end
end

function BookBoxGui:close()
	BookBoxGui.super.close(self)

	for name, page in pairs(self._pages) do
		if page.box_gui then
			page.box_gui:close()
		end
	end
end

function BookBoxGui:set_page(name)
	if self._active_page_name == name then
		return
	end

	if self._active_page_name and self._active_page_name ~= name then
		self._pages[self._active_page_name].box_gui:close_page()
	end

	for page_name, page in pairs(self._pages) do
		page.box_gui:set_visible(self._visible and page_name == name)
		page.panel:child("bg_rect"):set_color(page_name == name and Color(0.5, 1, 1, 1) or Color(0.5, 0.5, 0.5, 0.5))
	end

	self._active_page_name = name

	self._pages[self._active_page_name].box_gui:open_page()
end

function BookBoxGui:input_focus()
	if not self._active_page_name then
		return false
	end

	if self._pages[self._active_page_name].box_gui:input_focus() then
		return true
	end
end

function BookBoxGui:mouse_pressed(button, x, y)
	if not self:can_take_input() then
		return
	end

	if button == Idstring("0") then
		for name, page in pairs(self._pages) do
			if page.panel:inside(x, y) then
				self:set_page(name)

				return true
			end
		end
	end

	if not self._active_page_name then
		return false
	end

	if self._pages[self._active_page_name].box_gui:mouse_pressed(button, x, y) then
		return true
	end
end

function BookBoxGui:check_grab_scroll_bar(x, y)
	if not self:can_take_input() then
		return false
	end

	if self._text_box:inside(x, y) and self._text_box:child("top_line"):inside(x, y) then
		self._grabbed_title = true
		self._grabbed_offset_x = self:x() - x
		self._grabbed_offset_y = self:y() - y

		return true
	end

	if not self._active_page_name then
		return false
	end

	if self._pages[self._active_page_name].box_gui:check_grab_scroll_bar(x, y) then
		return true
	end
end

function BookBoxGui:release_scroll_bar()
	local used, pointer = BookBoxGui.super.release_scroll_bar(self)

	if used then
		return true, pointer
	end

	if not self._active_page_name then
		return false
	end

	if self._pages[self._active_page_name].box_gui:release_scroll_bar() then
		return true
	end
end

function BookBoxGui:mouse_wheel_down(x, y)
	if not self._visible then
		return
	end

	if not self._active_page_name then
		return false
	end

	if self._pages[self._active_page_name].box_gui:mouse_wheel_down(x, y) then
		return true
	end
end

function BookBoxGui:mouse_wheel_up(x, y)
	if not self._visible then
		return
	end

	if not self._active_page_name then
		return false
	end

	if self._pages[self._active_page_name].box_gui:mouse_wheel_up(x, y) then
		return true
	end
end

function BookBoxGui:moved_scroll_bar(x, y)
	local used, pointer = BookBoxGui.super.moved_scroll_bar(self, x, y)

	if used then
		return true, pointer
	end

	if not self._active_page_name then
		return false
	end

	if self._pages[self._active_page_name].box_gui:moved_scroll_bar(x, y) then
		return true
	end
end

function BookBoxGui:mouse_moved(x, y)
	local pointer = nil

	if not self:can_take_input() then
		return false, pointer
	end

	if not self._active_page_name then
		return false, pointer
	end

	local used, wpointer = self._pages[self._active_page_name].box_gui:mouse_moved(x, y)
	pointer = wpointer or pointer

	if used then
		return true, pointer
	end

	if self:_mouse_over_page_panel(x, y) then
		pointer = "arrow"
	elseif self._text_box:inside(x, y) and self._text_box:child("top_line"):inside(x, y) then
		pointer = "hand"
	end

	return false, pointer
end

function BookBoxGui:_mouse_over_page_panel(x, y)
	for _, panel in ipairs(self._page_panels) do
		if panel:inside(x, y) then
			return panel
		end
	end

	return nil
end
