core:module("CoreElementPhysicsPush")
core:import("CoreMissionScriptElement")

ElementPhysicsPush = ElementPhysicsPush or class(CoreMissionScriptElement.MissionScriptElement)
ElementPhysicsPush.IDS_EFFECT = Idstring("core/physic_effects/hubelement_push")

function ElementPhysicsPush:client_on_executed(...)
	self:on_executed(...)
end

function ElementPhysicsPush:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	World:play_physic_effect(self.IDS_EFFECT, self._values.position, self._values.physicspush_range, self._values.physicspush_velocity, self._values.physicspush_mass)
	ElementPhysicsPush.super.on_executed(self, instigator)
end
