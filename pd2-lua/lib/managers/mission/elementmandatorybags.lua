core:import("CoreMissionScriptElement")

ElementMandatoryBags = ElementMandatoryBags or class(CoreMissionScriptElement.MissionScriptElement)

function ElementMandatoryBags:init(...)
	ElementMandatoryBags.super.init(self, ...)
end

function ElementMandatoryBags:client_on_executed(...)
	self:on_executed(...)
end

function ElementMandatoryBags:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	print("ElementMandatoryBags:on_executed", self._values.carry_id, self._values.amount)
	managers.loot:set_mandatory_bags_data(self._values.carry_id, self._values.amount)
	ElementMandatoryBags.super.on_executed(self, instigator)
end
