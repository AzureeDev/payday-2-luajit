HUDPresenterVR = HUDPresenter
HUDPresenterVR.old_init = HUDPresenter.init

function HUDPresenterVR:init(hud)
	hud.old_panel = hud.panel
	hud.panel = managers.hud:floating_panel()

	self:old_init(hud)
	self._bg_box:set_y(math.round(self._hud_panel:h() / 4))

	hud.panel = hud.old_panel
	hud.old_panel = nil
end
