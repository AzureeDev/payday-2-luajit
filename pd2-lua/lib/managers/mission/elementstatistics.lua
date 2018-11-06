core:import("CoreMissionScriptElement")

ElementStatistics = ElementStatistics or class(CoreMissionScriptElement.MissionScriptElement)

function ElementStatistics:init(...)
	ElementStatistics.super.init(self, ...)
end

function ElementStatistics:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	managers.statistics:mission_stats(self._values.name)
	ElementStatistics.super.on_executed(self, instigator)
end

function ElementStatistics:client_on_executed(...)
	self:on_executed(...)
end
