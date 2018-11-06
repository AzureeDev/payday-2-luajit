core:module("CoreMenuStateInGame")
core:import("CoreMenuStatePrepareLoadingFrontEnd")

InGame = InGame or class()

function InGame:transition()
	local game_state = self.menu_state._game_state

	if game_state:is_preparing_for_loading_front_end() then
		return CoreMenuStatePrepareLoadingFrontEnd.PrepareLoadingFrontEnd
	end
end
