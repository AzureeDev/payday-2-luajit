core:import("CoreMissionScriptElement")

ElementBainState = ElementBainState or class(CoreMissionScriptElement.MissionScriptElement)

function ElementBainState:init(...)
	ElementBainState.super.init(self, ...)
end

function ElementBainState:client_on_executed(...)
	self:on_executed(...)
end

function ElementBainState:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	managers.groupai:state():set_bain_state(self._values.state)
	ElementBainState.super.on_executed(self, instigator)
end
