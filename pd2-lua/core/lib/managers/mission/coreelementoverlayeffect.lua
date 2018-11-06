core:module("CoreElementOverlayEffect")
core:import("CoreEngineAccess")
core:import("CoreMissionScriptElement")
core:import("CoreTable")

ElementOverlayEffect = ElementOverlayEffect or class(CoreMissionScriptElement.MissionScriptElement)

function ElementOverlayEffect:init(...)
	ElementOverlayEffect.super.init(self, ...)
end

function ElementOverlayEffect:client_on_executed(...)
	self:on_executed(...)
end

function ElementOverlayEffect:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._values.effect ~= "none" then
		local effect = CoreTable.clone(managers.overlay_effect:presets()[self._values.effect])
		effect.sustain = self._values.sustain or effect.sustain
		effect.fade_in = self._values.fade_in or effect.fade_in
		effect.fade_out = self._values.fade_out or effect.fade_out

		managers.overlay_effect:play_effect(effect)
	elseif Application:editor() then
		managers.editor:output_error("Cant activate overlay effect \"none\" [" .. self:editor_name() .. "]")
	end

	ElementOverlayEffect.super.on_executed(self, instigator)
end
