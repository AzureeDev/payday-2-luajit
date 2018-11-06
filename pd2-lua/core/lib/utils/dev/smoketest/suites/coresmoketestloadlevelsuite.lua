core:module("CoreSmoketestLoadLevelSuite")
core:import("CoreClass")
core:import("CoreSmoketestCommonSuite")

LoadLevelSuite = LoadLevelSuite or class(CoreSmoketestCommonSuite.CommonSuite)

function LoadLevelSuite:init()
	LoadLevelSuite.super.init(self)
	self:add_step("load_level", CoreSmoketestCommonSuite.CallAndWaitEventSubstep, CoreSmoketestCommonSuite.CallAndWaitEventSubstep.step_arguments(callback(self, self, "load_level"), Idstring("game_state_ingame")))
	self:add_step("in_game", CoreSmoketestCommonSuite.DelaySubstep, CoreSmoketestCommonSuite.DelaySubstep.step_arguments(1))
end

function LoadLevelSuite:load_level()
	local session_info = self._session_state:session_info()

	session_info:set_level_name(self:get_argument("level"))
	self._session_state:player_slots():primary_slot():request_debug_local_user_binding()
	self._session_state:join_standard_session()
end
