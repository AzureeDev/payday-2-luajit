core:import("CoreMissionScriptElement")

ElementBlurZone = ElementBlurZone or class(CoreMissionScriptElement.MissionScriptElement)

function ElementBlurZone:init(...)
	ElementBlurZone.super.init(self, ...)
end

function ElementBlurZone:client_on_executed(...)
	self:on_executed(...)
end

function ElementBlurZone:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._values.mode == 0 then
		managers.environment_controller:set_blurzone(self._id, self._values.mode)
	else
		managers.environment_controller:set_blurzone(self._id, self._values.mode, self._values.position, self._values.radius, self._values.height)
	end

	ElementBlurZone.super.on_executed(self, instigator)
end

function ElementBlurZone:operation_remove()
	managers.environment_controller:set_blurzone(self._id, -1)
end
