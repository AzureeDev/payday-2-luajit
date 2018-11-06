core:import("CoreMissionScriptElement")

ElementGameEventSet = ElementGameEventSet or class(CoreMissionScriptElement.MissionScriptElement)

function ElementGameEventSet:init(...)
	ElementGameEventSet.super.init(self, ...)
end

function ElementGameEventSet:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementGameEventSet.super.on_executed(self, instigator)
end

function ElementGameEventSet:client_on_executed(...)
	self:on_executed(...)
end
