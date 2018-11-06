HUDDriving = HUDDriving or class()

function HUDDriving:init(hud, full_hud)
	self._hud_panel = hud.panel
	self._full_hud_panel = full_hud.panel

	self._hud_panel:clear()
	self._full_hud_panel:clear()

	self._markers = {}
	local y_pos = -90
	local legend_rect_bg = self._hud_panel:rect({
		name = "legend_rect_bg",
		h = 32,
		valign = "bottom",
		x = 150,
		layer = 0,
		color = Color.black,
		w = self._hud_panel:w() - 300,
		y = hud.panel:h() - 120
	})

	self._hud_panel:text({
		vertical = "bottom",
		name = "value_speed",
		layer = 1,
		wrap = false,
		font_size = 28,
		align = "center",
		word_wrap = false,
		text = "100 kmph",
		x = 0,
		valign = "bottom",
		y = y_pos,
		font = tweak_data.hud.medium_font,
		color = Color.white
	})
	self._hud_panel:text({
		vertical = "bottom",
		name = "value_RPM",
		layer = 1,
		wrap = false,
		font_size = 28,
		align = "left",
		word_wrap = false,
		text = "7200",
		valign = "bottom",
		x = legend_rect_bg:x() + 10,
		y = y_pos,
		font = tweak_data.hud.medium_font,
		color = Color.white
	})
	self._hud_panel:text({
		vertical = "bottom",
		name = "value_gear",
		layer = 1,
		wrap = false,
		font_size = 28,
		align = "right",
		word_wrap = false,
		text = "N",
		x = -170,
		valign = "bottom",
		y = y_pos,
		font = tweak_data.hud.medium_font,
		color = Color.white
	})
end

function HUDDriving:start()
	self._active = true
end

function HUDDriving:stop()
	self._active = false
end

function HUDDriving:set_vehicle_state(speed, rpm, gear)
	self._hud_panel:child("value_speed"):set_text(string.format("%d", speed) .. " km/h")
	self._hud_panel:child("value_RPM"):set_text(rpm .. " rpm")
	self._hud_panel:child("value_gear"):set_text(gear)
end
