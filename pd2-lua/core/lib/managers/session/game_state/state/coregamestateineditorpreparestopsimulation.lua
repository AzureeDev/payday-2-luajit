core:module("CoreGameStateInEditorPrepareStopSimulation")
core:import("CoreGameStateInEditorStopSimulation")

PrepareStopSimulation = PrepareStopSimulation or class()

function PrepareStopSimulation:init(level_handler)
	self._level_handler = level_handler
end

function PrepareStopSimulation:destroy()
	local local_user_manager = self.game_state._session_manager._local_user_manager

	self.game_state:player_slots():leave_level_handler(self._level_handler)
	local_user_manager:leave_level_handler(self._level_handler)
	self._level_handler:destroy()
end

function PrepareStopSimulation:transition()
	if self.game_state._session_manager:all_systems_are_stable_for_loading() then
		return CoreGameStateInEditorStopSimulation.StopSimulation
	end
end
