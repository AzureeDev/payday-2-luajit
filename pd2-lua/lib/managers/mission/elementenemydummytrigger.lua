core:import("CoreMissionScriptElement")

ElementEnemyDummyTrigger = ElementEnemyDummyTrigger or class(CoreMissionScriptElement.MissionScriptElement)

function ElementEnemyDummyTrigger:init(...)
	ElementEnemyDummyTrigger.super.init(self, ...)
end

function ElementEnemyDummyTrigger:on_script_activated()
	for _, id in ipairs(self._values.elements) do
		local element = self:get_mission_element(id)

		element:add_event_callback(self._values.event, callback(self, self, "on_executed"))
	end
end

function ElementEnemyDummyTrigger:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementEnemyDummyTrigger.super.on_executed(self, instigator)
end

function ElementEnemyDummyTrigger:load()
end
