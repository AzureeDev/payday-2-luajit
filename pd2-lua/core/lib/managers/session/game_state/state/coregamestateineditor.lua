core:module("CoreGameStateInEditor")
core:import("CoreGameStateInEditorPrepareStartSimulation")

InEditor = InEditor or class()

function InEditor:init()
	self.game_state._is_in_editor = true

	EventManager:trigger_event(Idstring("game_state_editor"), nil)
end

function InEditor:destroy()
	self.game_state._is_in_editor = false
end

function InEditor:transition()
	if not self.game_state._game_requester:is_requested() then
		return
	end

	if self.game_state._session_manager:_main_systems_are_stable_for_loading() then
		return CoreGameStateInEditorPrepareStartSimulation.PrepareStartSimulation
	end
end
