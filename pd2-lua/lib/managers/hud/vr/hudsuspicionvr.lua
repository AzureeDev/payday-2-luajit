HUDSuspicionVR = HUDSuspicion
HUDSuspicionVR.old_init = HUDSuspicion.init

function HUDSuspicionVR:init(hud, sound_source)
	hud.old_panel = hud.panel
	hud.panel = managers.hud:floating_panel()

	self:old_init(hud, sound_source)

	hud.panel = hud.old_panel
	hud.old_panel = nil
end
