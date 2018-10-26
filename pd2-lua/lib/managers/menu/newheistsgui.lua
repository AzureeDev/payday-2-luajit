NewHeistsGui = NewHeistsGui or class(MenuGuiComponent)
NewHeistsGui.make_fine_text = BlackMarketGui.make_fine_text
local PANEL_PADDING = 10
local IMAGE_H = 123
local IMAGE_W = 416
local TIME_PER_PAGE = 6
local CHANGE_TIME = 0.5
local SPOT_W = 32
local SPOT_H = 8
local BAR_W = 32
local BAR_H = 6
local BAR_X = (SPOT_W - BAR_W) / 2
local BAR_Y = 0

function NewHeistsGui:init(ws, fullscreen_ws)
	local tweak = tweak_data.gui.new_heists
	self._page_count = math.min(#tweak, tweak.limit)
	self._current_page = 1
	self._block_change = false
	self._highlighted = false
	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._panel = ws:panel()
	self._full_panel = fullscreen_ws:panel()
	self._content_panel = self._full_panel:panel({w = IMAGE_W})

	self._content_panel:set_right(self._panel:width())

	local header_h = tweak_data.menu.pd2_small_font_size + PANEL_PADDING
	self._contents = {}
	self._internal_content_panel = self._content_panel:panel()
	self._internal_image_panel = self._internal_content_panel:panel({
		y = header_h,
		h = IMAGE_H
	})
	local max_h = 0
	self._font_size = tweak_data.menu.pd2_small_font_size
	self._text = self._internal_content_panel:text({
		text = "ASDF",
		font = tweak_data.menu.pd2_small_font,
		font_size = self._font_size,
		y = PANEL_PADDING - 5
	})

	self:_set_text(managers.localization:to_upper_text(tweak[1].name_id))

	for i = 1, self._page_count, 1 do
		local content_panel = self._internal_content_panel:panel({x = (i == 1 and 0 or 1) * self._content_panel:w()})
		local image_panel = content_panel:panel({
			y = header_h,
			height = IMAGE_H
		})

		image_panel:bitmap({texture = tweak[i].texture_path})
		content_panel:set_h(image_panel:bottom())

		max_h = math.max(max_h, image_panel:bottom())

		table.insert(self._contents, content_panel)
	end

	BoxGuiObject:new(self._internal_image_panel, {sides = {
		1,
		1,
		1,
		1
	}})

	self._selected_box = BoxGuiObject:new(self._internal_image_panel, {sides = {
		2,
		2,
		2,
		2
	}})

	self._selected_box:set_visible(false)
	self._internal_content_panel:set_h(max_h)

	self._page_panel = self._content_panel:panel({
		h = 16,
		y = self._internal_content_panel:bottom() + PANEL_PADDING
	})
	self._page_buttons = {}

	for i = 1, self._page_count, 1 do
		local page_button = self._page_panel:bitmap({texture = "guis/textures/pd2/ad_spot"})

		page_button:set_center_x((i / (self._page_count + 1) * self._page_panel:w()) / 2 + self._page_panel:w() / 4)
		page_button:set_center_y((self._page_panel:h() - page_button:h()) / 2)
		table.insert(self._page_buttons, page_button)
	end

	self._content_panel:set_h(self._page_panel:bottom())

	if managers.menu_component._player_profile_gui then
		local wx = self._content_panel:world_x()
		local wy = managers.menu_component._player_profile_gui._panel:world_y()
		wx, wy = managers.gui_data:convert_pos(ws, fullscreen_ws, wx, wy)

		self._content_panel:set_world_y(wy - header_h)
		self._content_panel:set_x(wx)
	else
		self._content_panel:set_bottom(self._panel:height() - PANEL_PADDING * 2)
	end

	self._bar = self._page_panel:bitmap({
		texture = "guis/textures/pd2/shared_lines",
		valign = "grow",
		halign = "grow",
		wrap_mode = "wrap",
		x = BAR_X,
		y = BAR_Y,
		w = BAR_W,
		h = BAR_H
	})

	self:set_bar_width(BAR_W, true)
	self._bar:set_top(self._page_buttons[1]:top() + BAR_Y)
	self._bar:set_left(self._page_buttons[1]:left() + BAR_X)

	self._select_rect = self._full_panel:bitmap({
		texture = "guis/textures/pd2/ad_blue2",
		layer = -2
	})

	self._select_rect:set_visible(false)
	self._select_rect:set_bottom(self._full_panel:height())
	self._select_rect:set_right(self._full_panel:width())

	self._queued_page = nil

	self:try_get_dummy()
end

function NewHeistsGui:try_get_dummy()
	local active_node_gui = managers.menu:active_menu().renderer:active_node_gui()

	if active_node_gui then
		self._dummy_item = active_node_gui:row_item_by_name("ad_dummy")

		if self._dummy_item and self._dummy_item.item then
			self._dummy_item.item:set_actual_item(self)
		end
	end

	return self._dummy_item
end

function NewHeistsGui:set_bar_width(w, random)
	w = w or BAR_W
	self._bar_width = w

	self._bar:set_width(w)

	self._bar_x = not random and self._bar_x or math.random(1, 255)
	self._bar_y = not random and self._bar_y or math.random(0, math.round(self._bar:texture_height() / 2 - 1)) * 2
	local x = self._bar_x
	local y = self._bar_y
	local h = 6
	local mvector_tl = Vector3()
	local mvector_tr = Vector3()
	local mvector_bl = Vector3()
	local mvector_br = Vector3()

	mvector3.set_static(mvector_tl, x, y, 0)
	mvector3.set_static(mvector_tr, x + w, y, 0)
	mvector3.set_static(mvector_bl, x, y + h, 0)
	mvector3.set_static(mvector_br, x + w, y + h, 0)
	self._bar:set_texture_coordinates(mvector_tl, mvector_tr, mvector_bl, mvector_br)
end
local animating = nil

function NewHeistsGui:update(t, dt)
	if not self._dummy_item then
		self:try_get_dummy()
	end

	local ng = managers.menu:active_menu().renderer:active_node_gui()
	local node = ng and ng.node

	if node and node:parameters() then
		self:set_enabled(node:parameters().name == "main")
	end

	if self._page_count <= 1 then
		return
	end

	self._next_time = self._next_time or t + TIME_PER_PAGE

	if self._block_change then
		self._next_time = t + TIME_PER_PAGE
	else
		if self._next_time <= t then
			self:_next_page()

			self._next_time = t + TIME_PER_PAGE
		end

		self:set_bar_width(BAR_W * (1 - (self._next_time - t) / TIME_PER_PAGE))
	end

	if not animating and self._queued_page then
		self:_move_to_page(self._queued_page)

		self._queued_page = nil
	end
end

function NewHeistsGui:_set_text(text)
	self._text:set_text(text)
	self:make_fine_text(self._text)
	self._text:set_right(self._internal_content_panel:w())
end

function NewHeistsGui:_move_pages(pages)
	local target_page = ((self._current_page + pages) - 1) % self._page_count + 1

	if animating then
		self._queued_page = target_page

		return
	end

	local function swipe_func(o, other_object, swipe_distance, time, end_pos)
		time = math.max(0.0001, time or 1)
		local fade_text_t = time / 2
		local text_changed = false
		local t = 0

		if not alive(o) then
			return
		end

		if not alive(other_object) then
			return
		end

		local speed = swipe_distance / time
		local start_pos = o:x()
		local final_pos = (start_pos - swipe_distance) - 5

		while alive(o) and alive(other_object) and final_pos <= o:x() do
			local dt = coroutine.yield()
			t = t + dt

			o:move(-dt * speed, 0)

			if start_pos <= other_object:x() then
				other_object:set_left(o:right() - 5)
			end

			if t < fade_text_t then
				self._text:set_alpha(1 - t / fade_text_t)
			else
				if not text_changed then
					self:_set_text(managers.localization:to_upper_text(tweak_data.gui.new_heists[target_page].name_id))
				end

				self._text:set_alpha((t - fade_text_t) / fade_text_t)
			end
		end

		if end_pos then
			o:set_x(end_pos)
		end

		other_object:set_x(start_pos)

		if not text_changed then
			self:_set_text(managers.localization:to_upper_text(tweak_data.gui.new_heists[target_page].name_id))
		end

		self._text:set_alpha(1)

		animating = false
	end

	if pages == 0 then
		return
	end

	self._contents[self._current_page]:stop()
	self._contents[target_page]:stop()
	self._contents[self._current_page]:animate(swipe_func, self._contents[target_page], self._content_panel:w(), CHANGE_TIME, self._content_panel:w())
	self._bar:set_top(self._page_buttons[target_page]:top() + BAR_Y)
	self._bar:set_left(self._page_buttons[target_page]:left() + BAR_X)
	self:set_bar_width(self._block_change and BAR_W or 0, true)

	animating = true
	self._current_page = target_page
end

function NewHeistsGui:dummy_set_highlight(highlight, node, row_item, mouse_over)
	self._select_rect:set_visible(highlight)

	self._highlighted = highlight

	self:set_bar_width(highlight and BAR_W or 0)

	self._block_change = highlight
end

function NewHeistsGui:dummy_trigger()
	Steam:overlay_activate("url", tweak_data.gui.new_heists[self._current_page].url)
end

function NewHeistsGui:_next_page()
	self:_move_pages(1)
end

function NewHeistsGui:_move_to_page(page)
	if animating then
		self._queued_page = page

		return
	end

	local num_pages = page - self._current_page

	if num_pages < 0 then
		num_pages = num_pages + self._page_count
	end

	if num_pages ~= 0 then
		self:_move_pages(num_pages, page)
	end

	self._next_time = Application:time() + TIME_PER_PAGE
end

function NewHeistsGui:close()
	self._panel:remove(self._content_panel)
	self._full_panel:remove(self._content_panel)
end

function NewHeistsGui:move_left()
	self:_move_pages(-1)
end

function NewHeistsGui:move_right()
	self:_move_pages(1)
end

function NewHeistsGui:mouse_pressed(button, x, y)
	if not self._enabled or button ~= Idstring("0") then
		return
	end

	x, y = managers.gui_data:convert_pos(self._ws, self._fullscreen_ws, x, y)

	if not self._content_panel:inside(x, y) then
		return
	end

	if self._internal_image_panel:inside(x, y) and self._contents[self._current_page]:inside(x, y) then
		Steam:overlay_activate("url", tweak_data.gui.new_heists[self._current_page].url)

		return true
	end

	for i, button in ipairs(self._page_buttons) do
		if i ~= self._current_page and button:inside(x, y) then
			self:_move_to_page(i)

			return true
		end
	end
end

function NewHeistsGui:mouse_moved(o, x, y)
	if not self._enabled then
		return
	end

	x, y = managers.gui_data:convert_pos(self._ws, self._fullscreen_ws, x, y)

	if self._dummy_item and not self._dummy_item.highlighted and self._content_panel:inside(x, y) then
		managers.menu:active_menu().logic:mouse_over_select_item(self._dummy_item.name, false)
	end

	self._selected_box:set_visible(self._highlighted)

	if self._internal_image_panel:inside(x, y) then
		return true, "link"
	end

	for i, button in ipairs(self._page_buttons) do
		if button:inside(x, y) then
			return true, "link"
		end
	end
end

function NewHeistsGui:set_enabled(enabled)
	self._enabled = enabled

	self._content_panel:set_visible(enabled)
end

