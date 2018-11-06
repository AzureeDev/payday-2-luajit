core:module("CoreGameStatePrepareLoadingFrontEnd")
core:import("CoreGameStateLoadingFrontEnd")

PrepareLoadingFrontEnd = PrepareLoadingFrontEnd or class()

function PrepareLoadingFrontEnd:init(level_handler)
	self.game_state._is_preparing_for_loading_front_end = true

	self.game_state._front_end_requester:task_started()
	self.game_state:_set_stable_for_loading()

	self._level_handler = level_handler
end

function PrepareLoadingFrontEnd:destroy()
	self.game_state._front_end_requester:task_completed()

	self.game_state._is_preparing_for_loading_front_end = false
	local local_user_manager = self.game_state._session_manager._local_user_manager

	self.game_state:player_slots():leave_level_handler(self._level_handler)
	local_user_manager:leave_level_handler(self._level_handler)
	self._level_handler:destroy()
end

function PrepareLoadingFrontEnd:transition()
	if self.game_state._session_manager:all_systems_are_stable_for_loading() then
		return CoreGameStateLoadingFrontEnd.LoadingFrontEnd
	end
end
