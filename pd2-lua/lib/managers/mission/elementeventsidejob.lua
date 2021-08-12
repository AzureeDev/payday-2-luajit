ElementEventSideJobAward = ElementEventSideJobAward or class(CoreMissionScriptElement.MissionScriptElement)

function ElementEventSideJobAward:client_on_executed_end_screen(...)
	self:on_executed(...)
end

function ElementEventSideJobAward:client_on_executed(...)
	self:on_executed(...)
end

function ElementEventSideJobAward:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local award_progress = true

	if self:value("award_instigator") and type(instigator) == "userdata" and alive(instigator) then
		local local_player = managers.player:local_player()
		award_progress = alive(local_player) and local_player == instigator

		if not award_progress then
			if instigator:vehicle_driving() then
				local seat = instigator:vehicle_driving():find_seat_for_player(local_player)

				if seat and seat.driving then
					award_progress = true
				end
			elseif false then
				-- Nothing
			end
		end
	end

	if self:value("players_from_start") and (managers.statistics:is_dropin() or game_state_machine:current_state_name() == "ingame_waiting_for_players") then
		award_progress = false
	end

	if award_progress then
		if self:value("award_instantly") then
			managers.event_jobs:award(self:value("objective_id"))
		else
			managers.event_jobs:register_award_on_mission_end(self:value("objective_id"))
		end
	end

	ElementEventSideJobAward.super.on_executed(self, self._unit or instigator)
end

ElementSideJobFilter = ElementSideJobFilter or class(CoreMissionScriptElement.MissionScriptElement)

function ElementSideJobFilter:on_script_activated()
	ElementSideJobFilter.super.on_script_activated(self)

	if self:value("execute_on_startup") then
		self:on_executed()
	end
end

function ElementSideJobFilter:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local pass = true
	local unlocked = managers.event_jobs:is_item_found(self:value("challenge"), self:value("objective_id"))

	if self:value("check_type") == "complete" then
		pass = unlocked
	elseif self:value("check_type") == "incomplete" then
		pass = not unlocked
	end

	if pass then
		ElementSideJobFilter.super.on_executed(self, self._unit or instigator)
	end
end
