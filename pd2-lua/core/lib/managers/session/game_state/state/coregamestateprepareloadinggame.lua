core:module("CoreGameStatePrepareLoadingGame")
core:import("CoreGameStateLoadingGame")

PrepareLoadingGame = PrepareLoadingGame or class()

function PrepareLoadingGame:init()
	self.game_state._game_requester:task_started()

	self.game_state._is_preparing_for_loading_game = true

	self.game_state:_set_stable_for_loading()
end

function PrepareLoadingGame:destroy()
	self.game_state._game_requester:task_completed()

	self.game_state._is_preparing_for_loading_game = false
end

function PrepareLoadingGame:transition()
	if self.game_state._session_manager:all_systems_are_stable_for_loading() then
		return CoreGameStateLoadingGame.LoadingGame
	end
end
