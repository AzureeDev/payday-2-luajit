core:module("CoreMenuStateLoadingFrontEnd")
core:import("CoreMenuStateFrontEnd")
core:import("CoreMenuStateStopLoadingFrontEnd")

LoadingFrontEnd = LoadingFrontEnd or class()

function LoadingFrontEnd:init()
	self.menu_state:_set_stable_for_loading()

	local menu_handler = self.menu_state._menu_handler

	menu_handler:start_loading_front_end_environment()
end

function LoadingFrontEnd:destroy()
	self.menu_state:_not_stable_for_loading()
end

function LoadingFrontEnd:transition()
	local game_state = self.menu_state._game_state

	if game_state:is_in_front_end() or game_state:is_in_pre_front_end() then
		return CoreMenuStateStopLoadingFrontEnd.StopLoadingFrontEnd
	end
end
