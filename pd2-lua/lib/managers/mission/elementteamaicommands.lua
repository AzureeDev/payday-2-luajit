core:import("CoreMissionScriptElement")

ElementTeamAICommands = ElementTeamAICommands or class(CoreMissionScriptElement.MissionScriptElement)

function ElementTeamAICommands:init(...)
	ElementTeamAICommands.super.init(self, ...)
end

function ElementTeamAICommands:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if instigator and type(instigator) == "userdata" then
		if alive(instigator) and managers.groupai:state():all_AI_criminals()[instigator:key()] then
			if self._values.command == "enter_bleedout" then
				instigator:character_damage():force_bleedout()
			elseif self._values.command == "enter_custody" then
				instigator:character_damage():force_custody()
			elseif self._values.command == "ignore_player" then
				instigator:brain():set_player_ignore(true)
			end
		end
	elseif self._values.command == "enter_bleedout" then
		for _, data in pairs(managers.groupai:state():all_AI_criminals()) do
			if data and alive(data.unit) then
				data.unit:character_damage():force_bleedout()
			end
		end
	elseif self._values.command == "enter_custody" then
		for _, data in pairs(managers.groupai:state():all_AI_criminals()) do
			if data and alive(data.unit) then
				data.unit:character_damage():force_custody()
			end
		end
	elseif self._values.command == "ignore_player" then
		for _, data in pairs(managers.groupai:state():all_AI_criminals()) do
			if data and alive(data.unit) then
				data.unit:brain():set_player_ignore(true)
			end
		end
	end

	ElementTeamAICommands.super.on_executed(self, instigator)
end

function ElementTeamAICommands:client_on_executed(...)
	self:on_executed(...)
end
