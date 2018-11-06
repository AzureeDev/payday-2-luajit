core:module("CoreSessionGenericState")

State = State or class()

function State:init()
end

function State:_set_stable_for_loading()
	self._is_stable_for_loading = true
end

function State:_not_stable_for_loading()
	self._is_stable_for_loading = nil
end

function State:is_stable_for_loading()
	return self._is_stable_for_loading ~= nil
end

function State:transition()
	assert(false, "you must override transition()")
end
