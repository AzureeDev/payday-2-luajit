core:import("CoreMissionScriptElement")

ElementCustomSafehouseFilter = ElementCustomSafehouseFilter or class(CoreMissionScriptElement.MissionScriptElement)

function ElementCustomSafehouseFilter:init(...)
	ElementCustomSafehouseFilter.super.init(self, ...)

	self._tier_value = tonumber(self:value("room_tier")) or 1
end

function ElementCustomSafehouseFilter:on_script_activated()
	ElementCustomSafehouseFilter.super.on_script_activated(self)

	if self:value("execute_on_startup") then
		self:on_executed()
	end
end

function ElementCustomSafehouseFilter:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local room_tier = nil

	if self:value("tier_check") == "current" then
		room_tier = managers.custom_safehouse:get_room_current_tier(self:value("room_id"))
	end

	if self:value("tier_check") == "highest_unlocked" then
		room_tier = managers.custom_safehouse:get_highest_tier_unlocked(self:value("room_id"))
	end

	if self:_check_value(room_tier) then
		ElementCustomSafehouseFilter.super.on_executed(self, self._unit or instigator)
	end
end

function ElementCustomSafehouseFilter:_check_value(value)
	local check_type = self:value("check_type")

	if not check_type or self._values.check_type == "equal" then
		return value == self._tier_value
	end

	if check_type == "less_or_equal" then
		return value <= self._tier_value
	end

	if check_type == "greater_or_equal" then
		return self._tier_value <= value
	end

	if check_type == "less_than" then
		return value < self._tier_value
	end

	if check_type == "greater_than" then
		return self._tier_value < value
	end
end

ElementCustomSafehouseTrophyFilter = ElementCustomSafehouseTrophyFilter or class(CoreMissionScriptElement.MissionScriptElement)

function ElementCustomSafehouseTrophyFilter:on_script_activated()
	ElementCustomSafehouseTrophyFilter.super.on_script_activated(self)

	if self:value("execute_on_startup") then
		self:on_executed()
	end
end

function ElementCustomSafehouseTrophyFilter:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	print("ElementCustomSafehouseTrophyFilter:on_executed is displaying trophy? ", self:value("trophy"), managers.custom_safehouse:is_trophy_displayed(self:value("trophy")))

	local unlocked = managers.custom_safehouse:is_trophy_displayed(self:value("trophy"))
	local pass = true

	if self:value("check_type") == "unlocked" then
		pass = unlocked
	elseif self:value("check_type") == "locked" then
		pass = not unlocked
	end

	if pass then
		ElementCustomSafehouseTrophyFilter.super.on_executed(self, self._unit or instigator)
	end
end

ElementCustomSafehouseAwardTrophy = ElementCustomSafehouseAwardTrophy or class(CoreMissionScriptElement.MissionScriptElement)

function ElementCustomSafehouseAwardTrophy:client_on_executed_end_screen(...)
	self:on_executed(...)
end

function ElementCustomSafehouseAwardTrophy:client_on_executed(...)
	self:on_executed(...)
end

function ElementCustomSafehouseAwardTrophy:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local award_trophy = true

	if self:value("award_instigator") and type(instigator) == "userdata" and alive(instigator) then
		local local_player = managers.player:local_player()
		award_trophy = alive(local_player) and local_player == instigator

		if not award_trophy then
			if instigator:vehicle_driving() then
				local seat = instigator:vehicle_driving():find_seat_for_player(local_player)

				if seat and seat.driving then
					award_trophy = true
				end
			elseif false then
				-- Nothing
			end
		end
	end

	if self:value("players_from_start") and (managers.statistics:is_dropin() or game_state_machine:current_state_name() == "ingame_waiting_for_players") then
		award_trophy = false
	end

	if award_trophy then
		managers.custom_safehouse:award(self:value("objective_id"))
	end

	ElementCustomSafehouseAwardTrophy.super.on_executed(self, self._unit or instigator)
end
