PlayerHandState = PlayerHandState or class()

function PlayerHandState:init(name, hand_state_machine, hand_unit, sequence)
	self._name = name
	self._hsm = hand_state_machine
	self._hand_unit = hand_unit
	self._sequence = sequence
end

function PlayerHandState:destroy()
end

function PlayerHandState:name()
	return self._name
end

function PlayerHandState:hsm()
	return self._hsm
end

function PlayerHandState:at_enter(previous_state, params)
	if self._hand_unit and self._sequence and self._hand_unit:damage():has_sequence(self._sequence) then
		self._hand_unit:damage():run_sequence_simple(self._sequence)
	end
end

function PlayerHandState:at_exit(next_state)
end

function PlayerHandState:default_transition(next_state, params)
	self:at_exit(next_state)
	next_state:at_enter(self, params)
end

function PlayerHandState:set_controller_enabled(enabled)
end
