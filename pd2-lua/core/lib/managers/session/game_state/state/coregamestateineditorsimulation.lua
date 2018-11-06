core:module("CoreGameStateInEditorSimulation")
core:import("CoreGameStatePrepareLoadingFrontEnd")
core:import("CoreGameStateInGame")
core:import("CoreGameStateInEditorPrepareStopSimulation")

Simulation = Simulation or class(CoreGameStateInGame.InGame)

function Simulation:transition()
	if not self.game_state._front_end_requester:is_requested() then
		return
	end

	if self.game_state._session_manager:_main_systems_are_stable_for_loading() then
		return CoreGameStateInEditorPrepareStopSimulation.PrepareStopSimulation, self._level_handler
	end
end
