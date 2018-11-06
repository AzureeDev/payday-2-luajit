core:import("CoreMissionScriptElement")

ElementSpawnTeamAI = ElementSpawnTeamAI or class(CoreMissionScriptElement.MissionScriptElement)

function ElementSpawnTeamAI:on_executed(instigator)
	ElementSpawnTeamAI.super.on_executed(self, instigator)

	local char_name = self._values.character

	if char_name == "any" then
		char_name = nil
	end

	managers.groupai:state():spawn_one_teamAI(false, char_name, self._values.position, self._values.rotation)
end
