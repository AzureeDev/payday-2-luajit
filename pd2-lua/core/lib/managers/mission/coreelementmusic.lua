core:module("CoreElementMusic")
core:import("CoreMissionScriptElement")

ElementMusic = ElementMusic or class(CoreMissionScriptElement.MissionScriptElement)

function ElementMusic:init(...)
	ElementMusic.super.init(self, ...)
end

function ElementMusic:client_on_executed(...)
	self:on_executed(...)
end

function ElementMusic:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if not self._values.use_instigator or instigator == managers.player:player_unit() then
		if self._values.music_event then
			managers.music:post_event(self._values.music_event)
		elseif Application:editor() then
			managers.editor:output_error("Cant play music event nil [" .. self._editor_name .. "]")
		end
	end

	ElementMusic.super.on_executed(self, instigator)
end
