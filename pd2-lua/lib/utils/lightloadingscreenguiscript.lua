LightLoadingScreenGuiScript = LightLoadingScreenGuiScript or class()

function LightLoadingScreenGuiScript:init(scene_gui, res, progress, base_layer, is_win32)
	self._base_layer = base_layer
	self._is_win32 = is_win32
	self._scene_gui = scene_gui
	self._res = res
	self._ws = scene_gui:create_screen_workspace()

	if _G.IS_VR then
		self._ws:set_pinned_screen(true)
	end

	self._safe_rect_pixels = self:get_safe_rect_pixels(res)
	self._saferect = self._scene_gui:create_screen_workspace()

	self:layout_saferect()

	local panel = self._ws:panel()
	self._panel = panel
	self._bg_gui = panel:rect({
		visible = true,
		color = Color.black,
		layer = base_layer
	})
	self._saferect_panel = self._saferect:panel()
	self._gui_tweak_data = {
		upper_saferect_border = 64,
		border_pad = 8
	}
	self._title_text = self._saferect_panel:text({
		y = 0,
		vertical = "bottom",
		h = 24,
		text_id = "debug_loading_level",
		font_size = 32,
		align = "left",
		font = "fonts/font_large_mf",
		halign = "left",
		color = Color.white,
		layer = self._base_layer + 1
	})

	self._title_text:set_text(string.upper(self._title_text:text()))

	self._stonecold_small_logo = self._saferect_panel:bitmap({
		texture = "guis/textures/game_small_logo",
		name = "stonecold_small_logo",
		h = 56,
		texture_rect = {
			0,
			0,
			256,
			56
		},
		layer = self._base_layer + 1
	})

	self._stonecold_small_logo:set_size(256, 56)

	self._indicator = self._saferect_panel:bitmap({
		texture = "guis/textures/icon_loading",
		name = "indicator",
		layer = self._base_layer + 1
	})
	self._dot_count = 0
	self._max_dot_count = 4
	self._init_progress = 0
	self._fake_progress = 0
	self._max_bar_width = 0

	self:setup(res, progress)
end

function LightLoadingScreenGuiScript:layout_saferect()
	local base_res = {
		x = 1280,
		y = 720
	}
	local safe_rect = self:get_safe_rect()
	local w = math.round(safe_rect.width * base_res.x)
	local h = math.round(safe_rect.height * base_res.y)
	local sh = math.min(self._safe_rect_pixels.height, self._safe_rect_pixels.width / (w / h))
	local sw = math.min(self._safe_rect_pixels.width, self._safe_rect_pixels.height * w / h)
	local x = math.round(self._res.x / 2 - sh * w / h / 2)
	local y = math.round(self._res.y / 2 - sw / (w / h) / 2)

	self._saferect:set_screen(w, h, x, y, sw)
end

function LightLoadingScreenGuiScript:get_safe_rect()
	local a = self._is_win32 and 0.032 or 0.05
	local b = 1 - a * 2

	return {
		x = a,
		y = a,
		width = b,
		height = b
	}
end

function LightLoadingScreenGuiScript:get_safe_rect_pixels(res)
	local safe_rect_scale = self:get_safe_rect()
	local safe_rect_pixels = {
		x = safe_rect_scale.x * res.x,
		y = safe_rect_scale.y * res.y,
		width = safe_rect_scale.width * res.x,
		height = safe_rect_scale.height * res.y
	}

	return safe_rect_pixels
end

function LightLoadingScreenGuiScript:setup(res, progress)
	self._gui_tweak_data = {
		upper_saferect_border = 64,
		border_pad = 8
	}

	self._title_text:set_font_size(32)
	self._stonecold_small_logo:set_size(256, 56)
	self._title_text:set_position(0, self._gui_tweak_data.border_pad)

	local _, _, w, h = self._title_text:text_rect()

	self._title_text:set_size(math.round(w), math.round(h))
	self._stonecold_small_logo:set_righttop(math.floor(self._saferect_panel:w()), 0)
	self._indicator:set_center_y(self._title_text:center_y() - 2)
	self._indicator:set_y(math.round(self._indicator:y()))
	self._indicator:set_left(math.round(self._title_text:right() + 8))
	self._bg_gui:set_size(res.x, res.y)

	if progress > 0 then
		self._init_progress = progress
	end
end

function LightLoadingScreenGuiScript:update(progress, dt)
	self._indicator:rotate(180 * dt)

	if self._init_progress < 100 and progress == -1 then
		self._fake_progress = self._fake_progress + 20 * dt

		if self._fake_progress > 100 then
			self._fake_progress = 100
		end

		progress = self._fake_progress
	end
end

function LightLoadingScreenGuiScript:set_text(text)
end

function LightLoadingScreenGuiScript:destroy()
	if alive(self._ws) then
		self._scene_gui:destroy_workspace(self._ws)
		self._scene_gui:destroy_workspace(self._saferect)

		self._ws = nil
		self._saferect = nil
	end
end

function LightLoadingScreenGuiScript:visible()
	return self._ws:visible()
end

function LightLoadingScreenGuiScript:set_visible(visible, res)
	if res then
		self._res = res
		self._safe_rect_pixels = self:get_safe_rect_pixels(res)

		self:layout_saferect()
		self:setup(res, -1)
	end

	if visible then
		if _G.IS_VR then
			return
		end

		self._ws:show()
		self._saferect:show()
	else
		self._ws:hide()
		self._saferect:hide()
	end
end
