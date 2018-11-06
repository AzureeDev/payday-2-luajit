core:module("CoreDialogStateNone")

None = None or class()

function None:init()
	self.dialog_state:_set_stable_for_loading()
end

function None:destroy()
	self.dialog_state._not_stable_for_loading()
end

function None:transition()
end
