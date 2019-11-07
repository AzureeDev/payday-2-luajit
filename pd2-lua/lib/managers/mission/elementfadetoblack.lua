core:import("CoreMissionScriptElement")

ElementFadeToBlack = ElementFadeToBlack or class(CoreMissionScriptElement.MissionScriptElement)

function ElementFadeToBlack:init(...)
	ElementFadeToBlack.super.init(self, ...)
end

function ElementFadeToBlack:client_on_executed(...)
	self:on_executed(...)
end

function ElementFadeToBlack:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local fade_in = self._values.fade_in and tweak_data.overlay_effects[self._values.fade_in] or tweak_data.overlay_effects.element_fade_in
	local fade_out = self._values.fade_out and tweak_data.overlay_effects[self._values.fade_out] or tweak_data.overlay_effects.element_fade_out

	managers.overlay_effect:play_effect(self._values.state and fade_in or fade_out)
	ElementFadeToBlack.super.on_executed(self, instigator)
end
