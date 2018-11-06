core:module("CoreGameStateFrontEnd")
core:import("CoreGameStatePrepareLoadingGame")

FrontEnd = FrontEnd or class()

function FrontEnd:init()
	self.game_state._is_in_front_end = true
end

function FrontEnd:destroy()
	self.game_state._is_in_front_end = false
end

function FrontEnd:transition()
	if not self.game_state._game_requester:is_requested() then
		return
	end

	if self.game_state._session_manager:_main_systems_are_stable_for_loading() then
		return CoreGameStatePrepareLoadingGame.PrepareLoadingGame
	end
end
