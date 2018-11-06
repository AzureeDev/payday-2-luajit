core:module("CoreInitState")
core:import("CoreInternalGameState")

_InitState = _InitState or class(CoreInternalGameState.GameState)

function _InitState:init(game_state_machine)
	CoreInternalGameState.GameState.init(self, "init", game_state_machine)
end

function _InitState:at_enter()
	error("[GameStateMachine] ERROR, you are not allowed to enter the init state")
end
