core:import("CoreMissionScriptElement")

ElementMissionEnd = ElementMissionEnd or class(CoreMissionScriptElement.MissionScriptElement)

function ElementMissionEnd:init(...)
	ElementMissionEnd.super.init(self, ...)
end

function ElementMissionEnd:client_on_executed(instigator)
	if self._values.state == "leave_safehouse" and instigator:base().is_local_player then
		MenuCallbackHandler:leave_safehouse()
	end
end

function ElementMissionEnd:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._values.state ~= "none" and managers.platform:presence() == "Playing" then
		if self._values.state == "success" then
			local num_winners = managers.network:session():amount_of_alive_players()

			managers.network:session():send_to_peers("mission_ended", true, num_winners)
			game_state_machine:change_state_by_name("victoryscreen", {
				num_winners = num_winners,
				personal_win = alive(managers.player:player_unit())
			})
		elseif self._values.state == "failed" then
			managers.network:session():send_to_peers("mission_ended", false, 0)
			game_state_machine:change_state_by_name("gameoverscreen")
		elseif self._values.state == "leave" then
			MenuCallbackHandler:leave_mission()
		elseif self._values.state == "leave_safehouse" and instigator:base().is_local_player then
			MenuCallbackHandler:leave_safehouse()
		end
	elseif Application:editor() then
		managers.editor:output_error("Cant change to state " .. self._values.state .. " in mission end element " .. self._editor_name .. ".")
	end

	ElementMissionEnd.super.on_executed(self, instigator)
end
