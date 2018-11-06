core:module("CoreFreezeState")
core:import("CoreFiniteStateMachine")
core:import("CoreFreezeStateMelted")
core:import("CoreSessionGenericState")

FreezeState = FreezeState or class(CoreSessionGenericState.State)

function FreezeState:init()
	self._state = CoreFiniteStateMachine.FiniteStateMachine:new(CoreFreezeStateMelted.Melted, "freeze_state", self)
end

function FreezeState:set_debug(debug_on)
	self._state:set_debug(debug_on)
end

function FreezeState.default_data(data)
	data.start_state = "CoreFreezeStateMelted.Melted"
end

function FreezeState:save(data)
	self._state:save(data.start_state)
end

function FreezeState:transition()
	self._state:transition()
end
