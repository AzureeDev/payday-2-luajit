HUDAccessCamera = HUDAccessCamera or class()
local old_buttons = not _G.IS_VR

function HUDAccessCamera:init(hud, full_hud)
	self._hud_panel = hud.panel
	self._full_hud_panel = full_hud.panel

	self._hud_panel:clear()
	self._full_hud_panel:clear()

	self._markers = {}
	local legend_rect_bg = self._hud_panel:rect({
		name = "legend_rect_bg",
		h = 32,
		valign = "bottom",
		layer = 0,
		color = Color.black,
		w = self._hud_panel:w() / 2,
		x = self._hud_panel:w() / 4,
		y = hud.panel:h() - 64
	})
	local legend_prev = self._hud_panel:text({
		vertical = "bottom",
		name = "legend_prev",
		layer = 1,
		text_id = "hud_prev_camera",
		font_size = 28,
		align = "left",
		wrap = false,
		word_wrap = false,
		y = -32,
		valign = "bottom",
		x = legend_rect_bg:x() + 10,
		font = tweak_data.hud.medium_font,
		color = Color.white
	})
	local legend_next = self._hud_panel:text({
		vertical = "bottom",
		name = "legend_next",
		layer = 1,
		wrap = false,
		font_size = 28,
		align = "right",
		word_wrap = false,
		text = "[MOUSE 1]>",
		y = -32,
		valign = "bottom",
		x = legend_rect_bg:right() - 10,
		font = tweak_data.hud.medium_font,
		color = Color.white
	})

	legend_next:set_right(legend_rect_bg:right() - 10)

	local legend_exit = self._hud_panel:text({
		vertical = "bottom",
		name = "legend_exit",
		layer = 1,
		wrap = false,
		font_size = 28,
		align = "center",
		word_wrap = false,
		text = "EXIT[SPACE]",
		y = -32,
		x = 0,
		valign = "bottom",
		font = tweak_data.hud.medium_font,
		color = Color.white
	})

	legend_exit:set_center_x(legend_rect_bg:center_x())
	self._hud_panel:text({
		name = "camera_name",
		vertical = "bottom",
		layer = 1,
		wrap = false,
		font_size = 32,
		align = "left",
		word_wrap = false,
		text = "",
		x = 10,
		valign = "bottom",
		font = tweak_data.hud.medium_font,
		color = Color.white
	})
	self._hud_panel:text({
		name = "date",
		vertical = "bottom",
		layer = 1,
		wrap = false,
		font_size = 32,
		align = "right",
		word_wrap = false,
		text = "",
		x = -10,
		valign = "bottom",
		font = tweak_data.hud.medium_font,
		color = Color.white
	})
	self._hud_panel:rect({
		valign = "bottom",
		name = "rect_bg",
		h = 32,
		layer = 0,
		color = Color.black,
		y = hud.panel:h() - 32
	})
	self._hud_panel:rect({
		name = "destroyed_rect_bg",
		h = 32,
		visible = false,
		layer = 0,
		color = Color.black
	})
	self._hud_panel:text({
		vertical = "top",
		name = "destroyed_text",
		word_wrap = false,
		wrap = false,
		font_size = 32,
		align = "left",
		text = "FEED LOST",
		visible = false,
		x = 10,
		layer = 1,
		font = tweak_data.hud.medium_font,
		color = Color.white
	})
	self._full_hud_panel:rect({
		valign = "scale",
		name = "destroyed_rect",
		visible = false,
		layer = -1,
		color = Color(0.5, 0.5, 0.5)
	})

	local size = self._full_hud_panel:w() + 50

	self._full_hud_panel:bitmap({
		texture = "core/textures/noise",
		name = "noise",
		valign = "scale",
		wrap_mode = "wrap",
		halign = "scale",
		layer = 3,
		color = Color(0.2, 0, 0, 0),
		w = size,
		h = size
	})
	self._full_hud_panel:child("noise"):set_texture_rect(0, 0, size, size)
	self._full_hud_panel:bitmap({
		texture = "core/textures/noise",
		name = "noise2",
		valign = "scale",
		halign = "scale",
		wrap_mode = "wrap",
		y = 0,
		x = 0,
		layer = 3,
		color = Color(0.2, 0, 0, 0),
		w = size,
		h = size
	})
	self._full_hud_panel:child("noise2"):set_texture_rect(0, 0, size, size)
end

function HUDAccessCamera:start()
	local prev = "hud_prev_camera"
	local next = "hud_next_camera"

	self._hud_panel:child("legend_prev"):set_text(utf8.to_upper(managers.localization:text(prev, {
		BTN_PRIMARY = managers.localization:btn_macro(old_buttons and "primary_attack" or "suvcam_next")
	})))
	self._hud_panel:child("legend_next"):set_text(utf8.to_upper(managers.localization:text(next, {
		BTN_SECONDARY = managers.localization:btn_macro(old_buttons and "secondary_attack" or "suvcam_prev")
	})))
	self._hud_panel:child("legend_exit"):set_text(utf8.to_upper(managers.localization:text("hud_exit_camera", {
		BTN_JUMP = managers.localization:btn_macro(old_buttons and "jump" or "suvcam_exit")
	})))

	self._active = true

	self._hud_panel:animate(callback(self, self, "_animate_date"))
end

function HUDAccessCamera:stop()
	self._active = false
end

function HUDAccessCamera:set_destroyed(destroyed, no_feed)
	self._full_hud_panel:child("destroyed_rect"):set_visible(destroyed)
	self._hud_panel:child("destroyed_rect_bg"):set_visible(destroyed)
	self._hud_panel:child("destroyed_text"):set_text(managers.localization:text(no_feed and "hud_access_camera_no_feed" or "hud_access_camera_feed_lost"))
	self._hud_panel:child("destroyed_text"):set_visible(destroyed)
end

function HUDAccessCamera:set_camera_name(name)
	self._hud_panel:child("camera_name"):set_text(utf8.to_upper(name))
end

function HUDAccessCamera:set_date(date)
	self._hud_panel:child("date"):set_text(date)
end

function HUDAccessCamera:_animate_date()
	while self._active do
		local dt = coroutine.yield()

		self:set_date(Application:date("%Y-%m-%d %H:%M:%S"))
		self._full_hud_panel:child("noise"):set_x(-math.random(50))
		self._full_hud_panel:child("noise"):set_y(-math.random(50))
	end
end

function HUDAccessCamera:draw_marker(i, pos)
	self._markers = self._markers or {}

	if not self._markers[i] then
		self._markers[i] = self._full_hud_panel:bitmap({
			texture = "guis/textures/access_camera_marker",
			layer = -2,
			color = Color.white,
			x = pos.x,
			y = pos.y
		})
	end

	self._markers[i]:set_center(pos.x, pos.y)
end

function HUDAccessCamera:max_markers(amount)
	while amount < #self._markers do
		local obj = table.remove(self._markers, amount + 1)

		self._full_hud_panel:remove(obj)
	end
end
