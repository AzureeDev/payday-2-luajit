core:import("CoreMissionScriptElement")

ElementAwardAchievment = ElementAwardAchievment or class(CoreMissionScriptElement.MissionScriptElement)

function ElementAwardAchievment:init(...)
	ElementAwardAchievment.super.init(self, ...)
end

function ElementAwardAchievment:client_on_executed_end_screen(...)
	self:on_executed(...)
end

function ElementAwardAchievment:client_on_executed(...)
	self:on_executed(...)
end

function ElementAwardAchievment:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local award_achievement = true

	if self._values.award_instigator and type(instigator) == "userdata" and alive(instigator) then
		local local_player = managers.player:local_player()
		award_achievement = alive(local_player) and local_player == instigator

		if not award_achievement then
			if instigator:vehicle_driving() then
				local seat = instigator:vehicle_driving():find_seat_for_player(local_player)

				if seat and seat.driving then
					award_achievement = true
				end
			elseif false then
				-- Nothing
			end
		end
	end

	if self._values.players_from_start and (managers.statistics:is_dropin() or game_state_machine:current_state_name() == "ingame_waiting_for_players") then
		award_achievement = false
	end

	if award_achievement then
		print("[ElementAwardAchievment:on_executed]", "achievment", self._values.achievment)
		managers.achievment:award(self._values.achievment)
	end

	ElementAwardAchievment.super.on_executed(self, instigator)
end
