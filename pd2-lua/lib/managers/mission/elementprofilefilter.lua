core:import("CoreMissionScriptElement")

ElementProfileFilter = ElementProfileFilter or class(CoreMissionScriptElement.MissionScriptElement)

function ElementProfileFilter:init(...)
	ElementProfileFilter.super.init(self, ...)
end

function ElementProfileFilter:client_on_executed(...)
end

function ElementProfileFilter:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if not self:_check_player_lvl() then
		return
	end

	if not self:_check_total_money_earned() then
		return
	end

	if not self:_check_total_money_offshore() then
		return
	end

	if not self:_check_achievement() then
		return
	end

	ElementProfileFilter.super.on_executed(self, instigator)
end

function ElementProfileFilter:_check_player_lvl()
	local pass = self._values.player_lvl <= managers.experience:current_level()

	return pass
end

function ElementProfileFilter:_check_total_money_earned()
	local pass = managers.money:total_collected() >= self._values.money_earned * 1000

	return pass
end

function ElementProfileFilter:_check_total_money_offshore()
	if not self._values.money_offshore then
		return false
	end

	local pass = managers.money:offshore() >= self._values.money_offshore * 1000

	return pass
end

function ElementProfileFilter:_check_achievement()
	if self._values.achievement == "none" then
		return true
	end

	local info = managers.achievment:get_info(self._values.achievement)
	local pass = info and info.awarded

	return pass
end
