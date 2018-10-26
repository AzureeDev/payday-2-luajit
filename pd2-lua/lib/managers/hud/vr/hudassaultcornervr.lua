HUDAssaultCornerVR = HUDAssaultCorner
HUDAssaultCornerVR.old_init = HUDAssaultCorner.init

function HUDAssaultCornerVR:init(hud, full_hud, tweak_hud)
	local old_panel = hud.panel
	hud.panel = managers.hud:tablet_page()

	self:old_init(hud, full_hud, tweak_hud)
	self._hud_panel:child("hostages_panel"):set_x(0)

	if self:should_display_waves() then
		self._hud_panel:child("wave_panel"):set_x(self._hud_panel:child("hostages_panel"):right())
	end

	hud.panel = old_panel
	local noreturn_text = self._noreturn_bg_box:child("point_of_no_return_text")

	noreturn_text:set_text(managers.localization:to_upper_text("hud_assault_point_no_return"))
	noreturn_text:set_align("center")
	noreturn_text:set_right(self._noreturn_bg_box:w())

	local watch_panel = managers.hud:watch_panel()
	self._watch_point_of_no_return_timer = watch_panel:text({
		name = "point_of_no_return_timer",
		vertical = "center",
		word_wrap = false,
		wrap = false,
		font_size = 26,
		align = "center",
		text = "00:00",
		visible = false,
		layer = 1,
		font = tweak_data.hud.medium_font_noshadow,
		color = self._noreturn_color
	})

	self._watch_point_of_no_return_timer:set_center(watch_panel:w() / 2, watch_panel:h() / 2)
end

function HUDAssaultCornerVR:show_point_of_no_return_timer()
	local delay_time = self._assault and 1.2 or 0

	self:_end_assault()
	self._hud_panel:child("point_of_no_return_panel"):stop()
	self._hud_panel:child("point_of_no_return_panel"):animate(callback(self, self, "_animate_show_noreturn"), delay_time)
	self._watch_point_of_no_return_timer:set_visible(true)
	self:_set_feedback_color(self._noreturn_color)

	self._point_of_no_return = true

	managers.hud._hud_heist_timer:hide()
end

function HUDAssaultCornerVR:hide_point_of_no_return_timer()
	self._noreturn_bg_box:stop()
	self._hud_panel:child("point_of_no_return_panel"):set_visible(false)
	self._watch_point_of_no_return_timer:set_visible(false)

	self._point_of_no_return = false

	self:_set_feedback_color(nil)
	managers.hud._hud_heist_timer:show()
end

function HUDAssaultCornerVR:feed_point_of_no_return_timer(time)
	time = math.floor(time)
	local minutes = math.floor(time / 60)
	local seconds = math.round(time - minutes * 60)
	local text = (minutes < 10 and "0" .. minutes or minutes) .. ":" .. (seconds < 10 and "0" .. seconds or seconds)

	self._watch_point_of_no_return_timer:set_text(text)
end

function HUDAssaultCornerVR:flash_point_of_no_return_timer()

	local function flash_timer(o)
		local t = 0

		while t < 0.5 do
			t = t + coroutine.yield()
			local n = 1 - math.sin(t * 180)
			local r = math.lerp(1 or self._noreturn_color.r, 1, n)
			local g = math.lerp(0 or self._noreturn_color.g, 0.8, n)
			local b = math.lerp(0 or self._noreturn_color.b, 0.2, n)

			o:set_color(Color(r, g, b))
			o:set_font_size(math.lerp(26, 32, n))
		end
	end

	self._watch_point_of_no_return_timer:animate(flash_timer)
end

function HUDAssaultCornerVR:_animate_show_noreturn(point_of_no_return_panel, delay_time)
	local icon_noreturnbox = point_of_no_return_panel:child("icon_noreturnbox")
	local point_of_no_return_text = self._noreturn_bg_box:child("point_of_no_return_text")

	point_of_no_return_text:set_visible(false)
	wait(delay_time)
	point_of_no_return_panel:set_visible(true)
	icon_noreturnbox:stop()
	icon_noreturnbox:animate(callback(self, self, "_show_icon_assaultbox"))

	local function open_done()
		point_of_no_return_text:animate(callback(self, self, "_animate_show_texts"), {point_of_no_return_text})
	end

	self._noreturn_bg_box:stop()
	self._noreturn_bg_box:animate(callback(nil, _G, "HUDBGBox_animate_open_left"), 0.75, 242, open_done, {
		attention_forever = true,
		attention_color = self._casing_color
	})
end

function HUDAssaultCornerVR:_set_hostage_offseted(is_offseted)
	if is_offseted then
		self:start_assault_callback()
	end
end

