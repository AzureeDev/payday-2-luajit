core:import("CoreMissionScriptElement")

ElementSpecialObjectiveTrigger = ElementSpecialObjectiveTrigger or class(CoreMissionScriptElement.MissionScriptElement)

function ElementSpecialObjectiveTrigger:init(...)
	ElementSpecialObjectiveTrigger.super.init(self, ...)
end

function ElementSpecialObjectiveTrigger:on_script_activated()
	for _, id in ipairs(self._values.elements) do
		local element = self:get_mission_element(id)

		element:add_event_callback(self._values.event, callback(self, self, "on_executed"))
	end
end

function ElementSpecialObjectiveTrigger:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementSpecialObjectiveTrigger.super.on_executed(self, instigator)
end
