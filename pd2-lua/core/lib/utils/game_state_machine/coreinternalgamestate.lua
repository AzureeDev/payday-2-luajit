core:module("CoreInternalGameState")

GameState = GameState or class()

function GameState:init(name, game_state_machine)
	self._name = name
	self._gsm = game_state_machine
end

function GameState:destroy()
end

function GameState:name()
	return self._name
end

function GameState:gsm()
	return self._gsm
end

function GameState:at_enter(previous_state)
end

function GameState:at_exit(next_state)
end

function GameState:default_transition(next_state)
	self:at_exit(next_state)
	next_state:at_enter(self)
end

function GameState:force_editor_state()
	self._gsm:change_state_by_name("editor")
end

function GameState:allow_world_camera_sequence()
	return false
end

function GameState:play_world_camera_sequence(name, sequence)
	error("NotImplemented")
end

function GameState:allow_freeflight()
	return true
end

function GameState:freeflight_drop_player(pos, rot, velocity)
	Application:error("[FreeFlight] Drop player not implemented for state '" .. self:name() .. "'")
end
