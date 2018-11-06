core:import("CoreMissionScriptElement")

ElementGameEventIsDone = ElementGameEventIsDone or class(CoreMissionScriptElement.MissionScriptElement)

function ElementGameEventIsDone:init(...)
	ElementGameEventIsDone.super.init(self, ...)
end

function ElementGameEventIsDone:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local ok = false

	if not ok then
		return
	end

	ElementGameEventIsDone.super.on_executed(self, instigator)
end

function ElementGameEventIsDone:client_on_executed(...)
	self:on_executed(...)
end
