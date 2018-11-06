core:import("CoreMissionScriptElement")

ElementPointOfNoReturn = ElementPointOfNoReturn or class(CoreMissionScriptElement.MissionScriptElement)

function ElementPointOfNoReturn:init(...)
	ElementPointOfNoReturn.super.init(self, ...)
end

function ElementPointOfNoReturn:client_on_executed(...)
	self:on_executed(...)
end

function ElementPointOfNoReturn:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local diff = Global.game_settings and Global.game_settings.difficulty or "hard"

	if diff == "easy" then
		managers.groupai:state():set_point_of_no_return_timer(self._values.time_easy, self._id)
	elseif diff == "normal" then
		managers.groupai:state():set_point_of_no_return_timer(self._values.time_normal, self._id)
	elseif diff == "hard" then
		managers.groupai:state():set_point_of_no_return_timer(self._values.time_hard, self._id)
	elseif diff == "overkill" then
		managers.groupai:state():set_point_of_no_return_timer(self._values.time_overkill, self._id)
	elseif diff == "overkill_145" then
		managers.groupai:state():set_point_of_no_return_timer(self._values.time_overkill_145, self._id)
	elseif diff == "easy_wish" then
		managers.groupai:state():set_point_of_no_return_timer(self._values.time_easy_wish, self._id)
	elseif diff == "overkill_290" then
		managers.groupai:state():set_point_of_no_return_timer(self._values.time_overkill_290, self._id)
	elseif diff == "sm_wish" then
		managers.groupai:state():set_point_of_no_return_timer(self._values.time_sm_wish, self._id)
	end

	ElementPointOfNoReturn.super.on_executed(self, instigator)
end
