core:import("CoreMissionScriptElement")

ElementExperience = ElementExperience or class(CoreMissionScriptElement.MissionScriptElement)

function ElementExperience:init(...)
	ElementExperience.super.init(self, ...)
end

function ElementExperience:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	managers.experience:mission_xp_award(self._values.amount)
	ElementExperience.super.on_executed(self, instigator)
end

function ElementExperience:client_on_executed(...)
	self:on_executed(...)
end
