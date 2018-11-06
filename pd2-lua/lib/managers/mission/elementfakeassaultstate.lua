core:import("CoreMissionScriptElement")

ElementFakeAssaultState = ElementFakeAssaultState or class(CoreMissionScriptElement.MissionScriptElement)

function ElementFakeAssaultState:init(...)
	ElementFakeAssaultState.super.init(self, ...)
end

function ElementFakeAssaultState:client_on_executed(...)
	self:on_executed(...)
end

function ElementFakeAssaultState:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	managers.groupai:state():set_fake_assault_mode(self._values.state)
	ElementFakeAssaultState.super.on_executed(self, instigator)
end
