HUDPlayerDowned = HUDPlayerDowned or class()

function HUDPlayerDowned:init(hud)
	self._hud = hud
	self._hud_panel = hud.panel

	if self._hud_panel:child("downed_panel") then
		self._hud_panel:remove(self._hud_panel:child("downed_panel"))
	end

	local downed_panel = self._hud_panel:panel({
		name = "downed_panel"
	})
	local timer_msg = downed_panel:text({
		text = "BLEH BLEH IN",
		vertical = "center",
		h = 40,
		name = "timer_msg",
		w = 400,
		align = "center",
		font = tweak_data.hud.medium_font_noshadow,
		font_size = tweak_data.hud_downed.timer_message_size
	})
	local _, _, w, h = timer_msg:text_rect()

	timer_msg:set_h(h)
	timer_msg:set_x(math.round(self._hud_panel:center_x() - timer_msg:w() / 2))
	timer_msg:set_y(28)
	self._hud.timer:set_font(tweak_data.menu.pd2_large_font_id)
	self._hud.timer:set_font_size(42)

	local _, _, w, h = self._hud.timer:text_rect()

	self._hud.timer:set_h(h)
	self._hud.timer:set_y(math.round(timer_msg:bottom() - 6))
	self._hud.timer:set_center_x(self._hud_panel:center_x())
	self._hud.arrest_finished_text:set_font(Idstring(tweak_data.hud.medium_font_noshadow))
	self._hud.arrest_finished_text:set_font_size(tweak_data.hud_mask_off.text_size)
	self:set_arrest_finished_text()

	local _, _, w, h = self._hud.arrest_finished_text:text_rect()

	self._hud.arrest_finished_text:set_h(h)
	self._hud.arrest_finished_text:set_y(28)
	self._hud.arrest_finished_text:set_center_x(self._hud_panel:center_x())
end

function HUDPlayerDowned:set_arrest_finished_text()
	self._hud.arrest_finished_text:set_text(utf8.to_upper(managers.localization:text("hud_instruct_finish_arrest", {
		BTN_INTERACT = managers.localization:btn_macro("interact")
	})))
end

function HUDPlayerDowned:on_downed()
	local downed_panel = self._hud_panel:child("downed_panel")
	local timer_msg = downed_panel:child("timer_msg")

	timer_msg:set_text(utf8.to_upper(managers.localization:text("hud_custody_in")))
end

function HUDPlayerDowned:on_arrested()
	local downed_panel = self._hud_panel:child("downed_panel")
	local timer_msg = downed_panel:child("timer_msg")

	timer_msg:set_text(utf8.to_upper(managers.localization:text("hud_uncuffed_in")))
end

function HUDPlayerDowned:show_timer()
	local downed_panel = self._hud_panel:child("downed_panel")
	local timer_msg = downed_panel:child("timer_msg")

	timer_msg:set_visible(true)
	self._hud.timer:set_visible(true)
	timer_msg:set_alpha(1)
	self._hud.timer:set_alpha(1)
end

function HUDPlayerDowned:hide_timer()
	local downed_panel = self._hud_panel:child("downed_panel")
	local timer_msg = downed_panel:child("timer_msg")

	timer_msg:set_alpha(0.65)
	self._hud.timer:set_alpha(0.65)
end

function HUDPlayerDowned:show_arrest_finished()
	self._hud.arrest_finished_text:set_visible(true)

	local downed_panel = self._hud_panel:child("downed_panel")
	local timer_msg = downed_panel:child("timer_msg")

	timer_msg:set_visible(false)
	self._hud.timer:set_visible(false)
end

function HUDPlayerDowned:hide_arrest_finished()
	self._hud.arrest_finished_text:set_visible(false)
end

if _G.IS_VR then
	require("lib/managers/hud/vr/HUDPlayerDownedVR")
end
