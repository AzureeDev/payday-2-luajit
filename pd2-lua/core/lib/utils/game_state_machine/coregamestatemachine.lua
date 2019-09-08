core:module("CoreGameStateMachine")
core:import("CoreInitState")

GameStateMachine = GameStateMachine or class()

function GameStateMachine:init(start_state)
	self._states = {}
	self._transitions = {}
	local init = CoreInitState._InitState:new(self)
	self._states[init:name()] = init
	self._transitions[init:name()] = self._transitions[init:name()] or {}
	self._transitions[init:name()][start_state:name()] = init.default_transition
	self._current_state = init
	self._queued_transitions = {
		{
			start_state
		}
	}

	self:_do_state_change()
end

function GameStateMachine:destroy()
	for _, state in pairs(self._states) do
		state:destroy()
	end

	self._states = {}
	self._transitions = {}
end

function GameStateMachine:add_transition(from, to, trans_func)
	self._states[from:name()] = from
	self._states[to:name()] = to
	self._transitions[from:name()] = self._transitions[from:name()] or {}
	self._transitions[from:name()][to:name()] = trans_func
end

function GameStateMachine:current_state()
	return self._current_state
end

function GameStateMachine:can_change_state(state)
	local state_from = self._queued_transitions and self._queued_transitions[#self._queued_transitions][1] or self._current_state
	local valid_transitions = self._transitions[state_from:name()]

	return valid_transitions and valid_transitions[state:name()] ~= nil
end

function GameStateMachine:change_state(state, params)
	if self._doing_state_change then
		Application:error("[GameStateMachine:change_state] State change during transition!")
		Application:stack_dump()
	end

	local transition_debug_string = string.format("'%s' --> '%s'", tostring(self:last_queued_state_name()), tostring(state:name()))

	cat_print("game_state_machine", "[GameStateMachine] Requested state change " .. transition_debug_string)

	if self:can_change_state(state) then
		self._queued_transitions = self._queued_transitions or {}

		table.insert(self._queued_transitions, {
			state,
			params
		})
	end
end

function GameStateMachine:current_state_name()
	return self._current_state:name()
end

function GameStateMachine:can_change_state_by_name(state_name)
	local state = assert(self._states[state_name], "[GameStateMachine] Name '" .. tostring(state_name) .. "' does not correspond to a valid state.")

	return self:can_change_state(state)
end

function GameStateMachine:change_state_by_name(state_name, params)
	local state = assert(self._states[state_name], "[GameStateMachine] Name '" .. tostring(state_name) .. "' does not correspond to a valid state.")

	self:change_state(state, params)
end

function GameStateMachine:update(t, dt)
	if self._current_state.update then
		self._current_state:update(t, dt)
	end
end

function GameStateMachine:paused_update(t, dt)
	if self._current_state.paused_update then
		self._current_state:paused_update(t, dt)
	end
end

function GameStateMachine:end_update(t, dt)
	if self._queued_transitions then
		self:_do_state_change()
	end
end

function GameStateMachine:_do_state_change()
	if not self._queued_transitions then
		return
	end

	self._doing_state_change = true

	for i_transition, transition in ipairs(self._queued_transitions) do
		local new_state = transition[1]
		local params = transition[2]
		local old_state = self._current_state
		local trans_func = self._transitions[old_state:name()][new_state:name()]

		cat_print("game_state_machine", "[GameStateMachine] Executing state change '" .. tostring(old_state:name()) .. "' --> '" .. tostring(new_state:name()) .. "'")

		self._current_state = new_state

		trans_func(old_state, new_state, params)
	end

	self._queued_transitions = nil
	self._doing_state_change = false
end

function GameStateMachine:last_queued_state_name()
	if self._queued_transitions then
		return self._queued_transitions[#self._queued_transitions][1]:name()
	else
		return self:current_state_name()
	end
end
