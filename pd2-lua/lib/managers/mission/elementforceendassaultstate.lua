core:import("CoreMissionScriptElement")

ElementForceEndAssaultState = ElementForceEndAssaultState or class(CoreMissionScriptElement.MissionScriptElement)

function ElementForceEndAssaultState:init(...)
	ElementForceEndAssaultState.super.init(self, ...)
end

function ElementForceEndAssaultState:client_on_executed(...)
end

function ElementForceEndAssaultState:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if managers.groupai:state().force_end_assault_phase then
		managers.groupai:state():force_end_assault_phase(true)
	end

	ElementForceEndAssaultState.super.on_executed(self, instigator)
end
