core:import("CoreMissionScriptElement")

ElementDifficultyLevelCheck = ElementDifficultyLevelCheck or class(CoreMissionScriptElement.MissionScriptElement)

function ElementDifficultyLevelCheck:init(...)
	ElementDifficultyLevelCheck.super.init(self, ...)
end

function ElementDifficultyLevelCheck:client_on_executed(...)
	self:on_executed(...)
end

function ElementDifficultyLevelCheck:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local diff = Global.game_settings and Global.game_settings.difficulty or "hard"

	if self._values.difficulty == "overkill" and diff == "overkill_145" then
		-- Nothing
	elseif self._values.difficulty ~= diff then
		return
	end

	ElementDifficultyLevelCheck.super.on_executed(self, instigator)
end
