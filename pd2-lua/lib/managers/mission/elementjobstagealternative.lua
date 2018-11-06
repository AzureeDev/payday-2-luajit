core:import("CoreMissionScriptElement")

ElementJobStageAlternative = ElementJobStageAlternative or class(CoreMissionScriptElement.MissionScriptElement)

function ElementJobStageAlternative:init(...)
	ElementJobStageAlternative.super.init(self, ...)
end

function ElementJobStageAlternative:client_on_executed(...)
	self:on_executed(...)
end

function ElementJobStageAlternative:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	print("ElementJobStageAlternative:on_executed", self._values.alternative, self._values.interupt)

	if self._values.interupt and self._values.interupt ~= "none" then
		managers.job:set_next_interupt_stage(self._values.interupt)
	elseif Network:is_server() then
		managers.job:set_next_alternative_stage(self._values.alternative)
	end

	ElementJobStageAlternative.super.on_executed(self, self._unit or instigator)
end
