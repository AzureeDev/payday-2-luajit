core:import("CoreMissionScriptElement")

ElementDropinState = ElementDropinState or class(CoreMissionScriptElement.MissionScriptElement)

function ElementDropinState:init(...)
	ElementDropinState.super.init(self, ...)
end

function ElementDropinState:client_on_executed(...)
	self:on_executed(...)
end

function ElementDropinState:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	managers.groupai:state():set_allow_dropin(self._values.state)
	ElementDropinState.super.on_executed(self, instigator)
end
