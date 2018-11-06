HUDPlayerDownedVR = HUDPlayerDowned

function HUDPlayerDownedVR:init(hud)
	hud.panel = managers.hud:watch_panel():panel({})
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
		font_size = 16,
		font = tweak_data.hud.medium_font_noshadow
	})
	local _, _, w, h = timer_msg:text_rect()

	timer_msg:set_h(h)
	timer_msg:set_x(math.round(self._hud_panel:center_x() - timer_msg:w() / 2))
	timer_msg:set_y(28)

	self._hud.timer = self._hud_panel:text({
		text = "00",
		font_size = 28,
		align = "center",
		font = tweak_data.menu.pd2_large_font,
		y = math.round(timer_msg:bottom() - 4)
	})
	local _, _, w, h = self._hud.timer:text_rect()

	self._hud.timer:set_h(h)
	self._hud.timer:set_center_x(self._hud_panel:center_x())

	local prompt_panel = managers.hud:prompt_panel()
	self._hud.arrest_finished_text = prompt_panel:text({
		visible = false,
		y = 28,
		font_size = 28,
		align = "center",
		font = tweak_data.hud.medium_font_noshadow
	})

	self:set_arrest_finished_text()

	local _, _, w, h = self._hud.arrest_finished_text:text_rect()

	self._hud.arrest_finished_text:set_h(h)
	self._hud.arrest_finished_text:set_center_x(prompt_panel:w() / 2)

	local hud_component = managers.hud._component_map[PlayerBase.PLAYER_DOWNED_HUD:key()]
	hud_component.panel = hud.panel

	hud_component.panel:set_script(hud)
	managers.hud:hide(PlayerBase.PLAYER_DOWNED_HUD)

	function self._hud.show()
		managers.hud._hud_heist_timer:hide()
	end

	function self._hud.hide()
		managers.hud._hud_heist_timer:show()
	end

	VRManagerPD2.overlay_helper(self._hud_panel)
end
