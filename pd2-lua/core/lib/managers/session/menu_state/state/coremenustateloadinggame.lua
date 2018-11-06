core:module("CoreMenuStateLoadingGame")
core:import("CoreMenuStateInGame")
core:import("CoreMenuStateStopLoadingGame")

LoadingGame = LoadingGame or class()

function LoadingGame:init()
	self.menu_state:_set_stable_for_loading()

	local menu_handler = self.menu_state._menu_handler

	menu_handler:start_loading_game_environment()
end

function LoadingGame:destroy()
	self.menu_state:_not_stable_for_loading()
end

function LoadingGame:transition()
	local game_state = self.menu_state._game_state

	if game_state:is_in_game() then
		return CoreMenuStateStopLoadingGame.StopLoadingGame
	end
end
