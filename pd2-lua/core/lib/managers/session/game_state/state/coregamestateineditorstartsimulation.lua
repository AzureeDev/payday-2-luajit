core:module("CoreGameStateInEditorStartSimulation")
core:import("CoreGameStateInGame")
core:import("CoreGameStateLoadingGame")

StartSimulation = StartSimulation or class(CoreGameStateLoadingGame.LoadingGame)

function StartSimulation:transition()
	return CoregameStateInEditorSimulation.Simulation
end
