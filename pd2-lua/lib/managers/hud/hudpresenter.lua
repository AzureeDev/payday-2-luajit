HUDPresenter = HUDPresenter or class()

function HUDPresenter:init(hud)
	self._hud_panel = hud.panel

	if self._hud_panel:child("present_panel") then
		self._hud_panel:remove(self._hud_panel:child("present_panel"))
	end

	local h = 68
	local w = 450
	local x = math.round(self._hud_panel:w() / 2 - w / 2)
	local y = math.round(self._hud_panel:h() / 14)
	local present_panel = self._hud_panel:panel({
		layer = 10,
		name = "present_panel",
		visible = false
	})
	self._bg_box = HUDBGBox_create(present_panel, {
		w = w,
		h = h,
		x = x,
		y = y,
		valign = {
			0.2,
			0
		}
	})

	self._bg_box:set_center_y(math.round(self._hud_panel:h() / 5))

	local title = self._bg_box:text({
		layer = 1,
		name = "title",
		vertical = "bottom",
		text = "TITLE",
		x = 8,
		valign = "bottom",
		color = Color.white:with_alpha(1),
		font = tweak_data.hud_present.title_font,
		font_size = tweak_data.hud_present.title_size
	})
	local _, _, _, h = title:text_rect()

	title:set_h(h)
	title:set_bottom(math.floor(self._bg_box:h() / 2) + 2)

	local text = self._bg_box:text({
		layer = 1,
		name = "text",
		vertical = "top",
		text = "TEXT",
		x = 8,
		valign = "top",
		color = Color.white,
		font = tweak_data.hud_present.text_font,
		font_size = tweak_data.hud_present.text_size
	})
	local _, _, _, h = text:text_rect()

	text:set_h(h)
	text:set_top(math.ceil(self._bg_box:h() / 2) - 2)
end

function HUDPresenter:present(params)
	self._present_queue = self._present_queue or {}

	if self._presenting then
		table.insert(self._present_queue, params)

		return
	end

	if params.present_mid_text then
		self:_present_information(params)
	end
end

function HUDPresenter:_present_information(params)
	local present_panel = self._hud_panel:child("present_panel")
	local title = self._bg_box:child("title")
	local text = self._bg_box:child("text")

	title:set_text(utf8.to_upper(params.title or ""))
	text:set_text(utf8.to_upper(params.text))
	title:set_visible(false)
	text:set_visible(false)

	local _, _, w, _ = title:text_rect()

	title:set_w(w)

	local _, _, w2, _ = text:text_rect()

	text:set_w(w2)

	local tw = math.max(w, w2)

	self._bg_box:set_w(tw + 16)
	self._bg_box:set_left(math.round(self._bg_box:parent():w() / 2 - self._bg_box:w() / 2))

	if params.icon then
		-- Nothing
	end

	if params.event then
		managers.hud._sound_source:post_event(params.event)
	end

	local callback_params = {
		has_title = params.title ~= nil,
		seconds = params.time or 4,
		use_icon = params.icon,
		done_cb = callback(self, self, "_present_done")
	}

	present_panel:animate(callback(self, self, "_animate_present_information"), callback_params)

	self._presenting = true
end

function HUDPresenter:_present_done()
	self._presenting = false
	local queued = table.remove(self._present_queue, 1)

	if queued and queued.present_mid_text then
		setup:add_end_frame_clbk(callback(self, self, "_do_it", queued))
	end
end

function HUDPresenter:_do_it(queued)
	self:_present_information(queued)
end

function HUDPresenter:_animate_present_information(present_panel, params)
	present_panel:set_visible(true)
	present_panel:set_alpha(1)

	local title = self._bg_box:child("title")
	local text = self._bg_box:child("text")

	if params.has_title then
		self._bg_box:set_height(68)
		text:set_top(math.ceil(self._bg_box:height() / 2) - 2)
	else
		self._bg_box:set_height(34)
		text:set_center_y(math.ceil(self._bg_box:height() / 2))
	end

	local function open_done()
		title:set_visible(params.has_title)
		text:set_visible(true)
		title:animate(callback(self, self, "_animate_show_text"), text)
		wait(params.seconds)
		title:animate(callback(self, self, "_animate_hide_text"), text)
		wait(0.5)

		local function close_done()
			present_panel:set_visible(false)
			self:_present_done()
		end

		self._bg_box:animate(callback(nil, _G, "HUDBGBox_animate_close_center"), close_done)
	end

	self._bg_box:stop()
	self._bg_box:animate(callback(nil, _G, "HUDBGBox_animate_open_center"), nil, self._bg_box:w(), open_done)
end

function HUDPresenter:_animate_show_text(title, text)
	local TOTAL_T = 0.5
	local t = TOTAL_T

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		local alpha = math.round(math.abs(math.sin(t * 360 * 3)))

		title:set_alpha(alpha)
		text:set_alpha(alpha)
	end

	title:set_alpha(1)
	text:set_alpha(1)
end

function HUDPresenter:_animate_hide_text(title, text)
	local TOTAL_T = 0.5
	local t = TOTAL_T

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		local vis = math.round(math.abs(math.cos(t * 360 * 3)))

		title:set_alpha(vis)
		text:set_alpha(vis)
	end

	title:set_alpha(1)
	text:set_alpha(1)
	title:set_visible(false)
	text:set_visible(false)
end

if _G.IS_VR then
	require("lib/managers/hud/vr/HUDPresenterVR")
end
