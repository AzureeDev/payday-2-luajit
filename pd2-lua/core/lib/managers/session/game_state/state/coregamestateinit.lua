core:module("CoreGameStateInit")
core:import("CoreGameStateInEditor")
core:import("CoreGameStatePreFrontEnd")

Init = Init or class()

function Init:init()
	self.game_state._is_in_init = true
end

function Init:destroy()
	self.game_state._is_in_init = false
end

function Init:transition()
	if Application:editor() then
		return CoreGameStateInEditor.InEditor
	else
		return CoreGameStatePreFrontEnd.PreFrontEnd
	end
end
