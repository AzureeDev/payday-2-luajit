core:import("CoreMissionScriptElement")

ElementMissionFilter = ElementMissionFilter or class(CoreMissionScriptElement.MissionScriptElement)

function ElementMissionFilter:init(...)
	ElementMissionFilter.super.init(self, ...)
end

function ElementMissionFilter:client_on_executed(...)
	self:on_executed(...)
end

function ElementMissionFilter:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if not self:_check_mission_filters() then
		return
	end

	ElementMissionFilter.super.on_executed(self, instigator)
end

function ElementMissionFilter:_check_mission_filters()
	if self._values[1] and managers.mission:check_mission_filter(1) then
		return true
	end

	if self._values[2] and managers.mission:check_mission_filter(2) then
		return true
	end

	if self._values[3] and managers.mission:check_mission_filter(3) then
		return true
	end

	if self._values[4] and managers.mission:check_mission_filter(4) then
		return true
	end

	if self._values[5] and managers.mission:check_mission_filter(5) then
		return true
	end

	return false
end
