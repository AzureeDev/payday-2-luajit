IngameManualGui = IngameManualGui or class()
IngameManualGui.PAGES = 8

function IngameManualGui:init(ws, fullscreen_ws)
	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._manual_panel = self._ws:panel():panel()
	self._fullscreen_panel = self._fullscreen_ws:panel():panel()
	self._active = true
	local black_bg = self._fullscreen_panel:rect({
		valign = "scale",
		alpha = 0,
		halign = "scale",
		layer = 0,
		color = Color.black
	})

	local function fade_in_anim(o)
		over(0.35, function (p)
			o:set_alpha(p)
		end)
	end

	black_bg:animate(fade_in_anim)

	local width = math.round(self._manual_panel:w())
	local height = math.round((self._manual_panel:h() - self._manual_panel:w() / 2) * 0.5)

	self._manual_panel:rect({
		h = 1,
		x = 0,
		layer = 4,
		w = width,
		y = height
	})
	self._manual_panel:rect({
		h = 1,
		x = 0,
		layer = 4,
		w = width,
		y = self._manual_panel:h() - height - 1
	})
	self._manual_panel:rect({
		w = 1,
		x = 0,
		layer = 4,
		h = self._manual_panel:h() - height * 2 - 2,
		y = height + 1
	})
	self._manual_panel:rect({
		w = 1,
		layer = 4,
		h = self._manual_panel:h() - height * 2 - 2,
		x = self._manual_panel:w() - 1,
		y = height + 1
	})

	self._manual_y = height
	self._page_counter = self._manual_panel:text({
		align = "center",
		layer = 4,
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		text = "1/" .. tostring(self.PAGES)
	})
	self._zoom = 1

	self:open_manual_page(1)
end

function IngameManualGui:_setup_controller_input()
	self._left_axis_vector = Vector3()
	self._right_axis_vector = Vector3()

	self._fullscreen_ws:connect_controller(managers.menu:active_menu().input:get_controller(), true)
	self._fullscreen_panel:axis_move(callback(self, self, "_axis_move"))
end

function IngameManualGui:_destroy_controller_input()
	self._fullscreen_ws:disconnect_all_controllers()

	if alive(self._fullscreen_panel) then
		self._fullscreen_panel:axis_move(nil)
	end
end

function IngameManualGui:_axis_move(o, axis_name, axis_vector, controller)
	if axis_name == Idstring("left") then
		mvector3.set(self._left_axis_vector, axis_vector)
	elseif axis_name == Idstring("right") then
		mvector3.set(self._right_axis_vector, axis_vector)
	end
end

function IngameManualGui:update(t, dt)
	if managers.menu:is_pc_controller() then
		return
	end

	local left_x, left_y = managers.menu_component:get_left_controller_axis()
	local right_x, right_y = managers.menu_component:get_right_controller_axis()

	self:controller_move(-left_x * dt, left_y * dt)
	self:controller_zoom(right_y * dt)
end

function IngameManualGui:correct_position()
	if self._page:left() > 0 then
		self._page:set_left(0)
	elseif self._page:right() < self._page_panel:w() then
		self._page:set_right(self._page_panel:w())
	end

	if self._page:top() > 0 then
		self._page:set_top(0)
	elseif self._page:bottom() < self._page_panel:h() then
		self._page:set_bottom(self._page_panel:h())
	end
end

function IngameManualGui:controller_move(x, y)
	if self._loading then
		return
	end

	if not alive(self._page) then
		return
	end

	local speed = 512

	self._page:move(x * speed, y * speed)
	self:correct_position()
end

function IngameManualGui:controller_zoom(y)
	if self._loading then
		return
	end

	if not alive(self._page) then
		return
	end

	self._zoom = math.clamp(self._zoom + y * 2, 1, 2)
	local w, h = self._manual_panel:size()
	local px, py = self._page:position()
	local x = w / 2 - px
	local y = h / 2 - py
	local sx = x / self._page:w()
	local sy = y / self._page:h()
	local aspect = self._page:texture_height() / math.max(self._page:texture_width(), 1)
	local width = self._page_panel:w()
	local height = self._page_panel:h()

	self._page:set_size(width * self._zoom, width * aspect * self._zoom)
	self._page:set_position(w / 2 - sx * self._page:w(), h / 2 - sy * self._page:h())
	self:correct_position()
end

function IngameManualGui:next_page()
	self:open_manual_page(self._current_page + 1)
end

function IngameManualGui:previous_page()
	self:open_manual_page(self._current_page - 1)
end

function IngameManualGui:input_focus()
	return 1
end

function IngameManualGui:open_manual_page(page)
	local new_page = math.clamp(page, 1, self.PAGES)

	if new_page == self._current_page then
		return
	end

	local path = "guis/textures/pd2/ingame_manual/page_"
	local lang_key = SystemInfo:language():key()
	local files = {
		[Idstring("french"):key()] = "_fr",
		[Idstring("spanish"):key()] = "_es"
	}
	self._zoom = 1
	self._current_page = new_page

	self._page_counter:set_text(tostring(self._current_page) .. "/" .. tostring(self.PAGES))

	local new_page = path .. tostring(page) .. (files[lang_key] or "")

	self:create_page(new_page)
end

function IngameManualGui:remove_page(unretrieve_texture)
	if alive(self._page_panel) then
		self._page_panel:parent():remove(self._page_panel)

		self._page_panel = nil
		self._page = nil
	end

	if alive(self._page) then
		self._page:parent():remove(self._page)

		self._page = nil
	end

	if unretrieve_texture then
		self:unretrieve_texture()
	end
end

function IngameManualGui:create_page(texture_path)
	self:remove_page(true)

	self._page = self._manual_panel:panel()
	local loading_text = self._page:text({
		font = tweak_data.menu.pd2_large_font,
		font_size = tweak_data.menu.pd2_large_font_size,
		text = managers.localization:to_upper_text("debug_loading_level")
	})
	local x, y, w, h = loading_text:text_rect()

	loading_text:set_size(w, h)

	local spinning_item = self._page:bitmap({
		w = 32,
		texture = "guis/textures/icon_loading",
		h = 32
	})

	loading_text:set_position(10, self._manual_y + 10)
	spinning_item:set_left(loading_text:right())
	spinning_item:set_center_y(loading_text:center_y())

	local function spin_anim(o)
		local dt = nil

		while true do
			dt = coroutine.yield()

			o:rotate(360 * dt)
		end
	end

	spinning_item:animate(spin_anim)

	self._loading = true

	if not managers.menu_component then
		return
	end

	if DB:has(Idstring("texture"), texture_path) then
		local texture_count = managers.menu_component:request_texture(texture_path, callback(self, self, "texture_done_clbk"))
		self._requested_texture = {
			texture_count = texture_count,
			texture = texture_path
		}
	end
end

function IngameManualGui:unretrieve_texture()
	if self._requested_texture then
		managers.menu_component:unretrieve_texture(self._requested_texture.texture, self._requested_texture.texture_count)

		self._requested_texture = nil
	end
end

function IngameManualGui:texture_done_clbk(texture_ids)
	local new_page_panel = self._manual_panel:panel({
		visible = false
	})
	local texture = new_page_panel:bitmap({
		name = "texture",
		layer = 1,
		texture = texture_ids
	})

	new_page_panel:show()
	self:remove_page(false)

	self._page_panel = new_page_panel
	self._page = texture
	local aspect = self._page:texture_height() / math.max(self._page:texture_width(), 1)
	local width = self._manual_panel:w()
	local height = self._manual_panel:h()

	new_page_panel:set_h(width * aspect)
	new_page_panel:set_w(width)
	new_page_panel:set_center(self._manual_panel:w() / 2, self._manual_panel:h() / 2)
	self._page:set_w(new_page_panel:w())
	self._page:set_h(new_page_panel:h())
	texture:set_size(self._page:w(), self._page:h())

	self._loading = nil
end

function IngameManualGui:set_layer(layer)
end

function IngameManualGui:close()
	self:remove_page(true)
	self._ws:panel():remove(self._manual_panel)
	self._fullscreen_ws:panel():remove(self._fullscreen_panel)
end
