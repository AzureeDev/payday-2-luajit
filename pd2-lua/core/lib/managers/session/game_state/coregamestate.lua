core:module("CoreGameState")
core:import("CoreFiniteStateMachine")
core:import("CoreGameStateInit")
core:import("CoreSessionGenericState")
core:import("CoreRequester")

GameState = GameState or class(CoreSessionGenericState.State)

function GameState:init(player_slots, session_manager)
	self._player_slots = player_slots
	self._session_manager = session_manager
	self._game_requester = CoreRequester.Requester:new()
	self._front_end_requester = CoreRequester.Requester:new()

	assert(self._session_manager)

	self._state = CoreFiniteStateMachine.FiniteStateMachine:new(CoreGameStateInit.Init, "game_state", self)
end

function GameState:set_debug(debug_on)
	self._state:set_debug(debug_on)
end

function GameState.default_data(data)
	data.start_state = "GameStateInit"
end

function GameState:save(data)
	self._state:save(data.start_state)
end

function GameState:update(t, dt)
	if self._state:state().update then
		self._state:update(t, dt)
	end
end

function GameState:end_update(t, dt)
	if self._state:state().end_update then
		self._state:state():end_update(t, dt)
	end
end

function GameState:transition()
	self._state:transition()
end

function GameState:player_slots()
	return self._player_slots
end

function GameState:is_in_pre_front_end()
	return self._is_in_pre_front_end
end

function GameState:is_in_front_end()
	return self._is_in_front_end
end

function GameState:is_in_init()
	return self._is_in_init
end

function GameState:is_in_editor()
	return self._is_in_editor
end

function GameState:is_in_game()
	return self._is_in_game
end

function GameState:is_preparing_for_loading_game()
	return self._is_preparing_for_loading_game
end

function GameState:is_preparing_for_loading_front_end()
	return self._is_preparing_for_loading_front_end
end

function GameState:_session_info()
	return self._session_manager:session():session_info()
end

function GameState:request_game()
	self._game_requester:request()
end

function GameState:request_front_end()
	self._front_end_requester:request()
end
