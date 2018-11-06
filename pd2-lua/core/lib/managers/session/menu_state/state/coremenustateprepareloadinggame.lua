core:module("CoreMenuStatePrepareLoadingGame")
core:import("CoreSessionResponse")
core:import("CoreMenuStateInGame")
core:import("CoreMenuStateLoadingGame")

PrepareLoadingGame = PrepareLoadingGame or class()

function PrepareLoadingGame:init()
	self._response = CoreSessionResponse.Done:new()
	local menu_handler = self.menu_state._menu_handler

	menu_handler:prepare_loading_game(self._response)
end

function PrepareLoadingGame:destroy()
	self._response:destroy()
end

function PrepareLoadingGame:transition()
	if self._response:is_done() then
		return CoreMenuStateLoadingGame.LoadingGame
	end
end
