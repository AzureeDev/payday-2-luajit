core:module("CoreGameStateInEditorStopSimulation")
core:import("CoreGameStateInEditor")

StopSimulation = StopSimulation or class()

function StopSimulation:init()
	self.game_state._front_end_requester:task_started()
end

function StopSimulation:destroy()
	self.game_state._front_end_requester:task_completed()
end

function StopSimulation:transition()
	return CoreGameStateInEditor.InEditor
end
