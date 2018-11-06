core:module("CoreDialogState")
core:import("CoreFiniteStateMachine")
core:import("CoreDialogStateNone")
core:import("CoreSessionGenericState")

DialogState = DialogState or class(CoreSessionGenericState.State)

function DialogState:init()
	self._state = CoreFiniteStateMachine.FiniteStateMachine:new(CoreDialogStateNone.None, "dialog_state", self)
end

function DialogState:set_debug(debug_on)
	self._state:set_debug(debug_on)
end

function DialogState.default_data(data)
	data.start_state = "CoreFreezeStateMelted.Melted"
end

function DialogState:save(data)
	self._state:save(data.start_state)
end

function DialogState:transition()
	self._state:transition()
end
