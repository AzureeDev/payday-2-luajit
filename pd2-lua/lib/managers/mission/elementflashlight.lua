core:import("CoreMissionScriptElement")

ElementFlashlight = ElementFlashlight or class(CoreMissionScriptElement.MissionScriptElement)

function ElementFlashlight:init(...)
	ElementFlashlight.super.init(self, ...)
end

function ElementFlashlight:client_on_executed(...)
	self:on_executed(...)
end

function ElementFlashlight:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._values.on_player then
		managers.game_play_central:set_flashlights_on_player_on(self._values.state)
	end

	managers.game_play_central:set_flashlights_on(self._values.state)
	ElementFlashlight.super.on_executed(self, instigator)
end
