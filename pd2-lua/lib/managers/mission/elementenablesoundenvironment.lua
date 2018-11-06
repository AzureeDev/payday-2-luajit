core:import("CoreMissionScriptElement")

ElementEnableSoundEnvironment = ElementEnableSoundEnvironment or class(CoreMissionScriptElement.MissionScriptElement)

function ElementEnableSoundEnvironment:init(...)
	ElementEnableSoundEnvironment.super.init(self, ...)
end

function ElementEnableSoundEnvironment:client_on_executed(...)
	self:on_executed(...)
end

function ElementEnableSoundEnvironment:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	for _, name in pairs(self._values.elements) do
		managers.sound_environment:enable_area(name, self._values.enable)
	end

	ElementEnableSoundEnvironment.super.on_executed(self, instigator)
end
