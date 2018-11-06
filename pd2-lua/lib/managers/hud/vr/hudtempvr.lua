HUDTempVR = HUDTemp
HUDTempVR.old_init = HUDTemp.init

function HUDTempVR:init(hud)
	self._tablet_panel = managers.hud:tablet_page("right_page")
	hud.old_panel = hud.panel
	hud.panel = self._tablet_panel:panel({
		name = "temp_panel",
		x = self._tablet_panel:w() / 2,
		w = self._tablet_panel:w() / 2
	})

	self:old_init(hud)

	hud.panel = hud.old_panel
	hud.old_panel = nil
end
