core:import("CoreMissionScriptElement")

ElementLootSecuredTrigger = ElementLootSecuredTrigger or class(CoreMissionScriptElement.MissionScriptElement)

function ElementLootSecuredTrigger:init(...)
	ElementLootSecuredTrigger.super.init(self, ...)
end

function ElementLootSecuredTrigger:client_on_executed(...)
end

function ElementLootSecuredTrigger:on_script_activated()
	if self._values.report_only then
		managers.loot:add_trigger(self._id, "report_only", self._values.amount, callback(self, self, "on_executed"))
	else
		managers.loot:add_trigger(self._id, self._values.include_instant_cash and "total_amount" or "amount", self._values.amount, callback(self, self, "on_executed"))
	end
end

function ElementLootSecuredTrigger:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementLootSecuredTrigger.super.on_executed(self, instigator)
end
