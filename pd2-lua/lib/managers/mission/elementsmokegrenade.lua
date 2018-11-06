core:import("CoreMissionScriptElement")

ElementSmokeGrenade = ElementSmokeGrenade or class(CoreMissionScriptElement.MissionScriptElement)

function ElementSmokeGrenade:init(...)
	ElementSmokeGrenade.super.init(self, ...)
end

function ElementSmokeGrenade:client_on_executed(...)
end

function ElementSmokeGrenade:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local is_flashbang = self._values.effect_type == "flash"

	managers.groupai:state():queue_smoke_grenade(self:id(), self._values.position, self._values.duration, self._values.ignore_control, is_flashbang)

	if self._values.immediate and (managers.groupai:state():get_assault_mode() or self._values.ignore_control) then
		managers.groupai:state():detonate_world_smoke_grenade(self:id())
	end

	ElementSmokeGrenade.super.on_executed(self, instigator)
end
