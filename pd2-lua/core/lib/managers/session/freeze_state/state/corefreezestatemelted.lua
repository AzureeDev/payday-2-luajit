core:module("CoreFreezeStateMelted")

Melted = Melted or class()

function Melted:init()
	self.freeze_state:_set_stable_for_loading()
end

function Melted:destroy()
	self.freeze_state:_not_stable_for_loading()
end

function Melted:transition()
end
