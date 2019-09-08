core:module("CoreControllerWrapperPS4")
core:import("CoreControllerWrapper")

ControllerWrapperPS4 = ControllerWrapperPS4 or class(CoreControllerWrapper.ControllerWrapper)
ControllerWrapperPS4.TYPE = "ps4"
ControllerWrapperPS4.CONTROLLER_TYPE_LIST = {
	"ps4_controller"
}

function ControllerWrapperPS4:init(manager, id, name, controller, setup, debug, skip_virtual_controller)
	local func_map = {
		confirm = callback(self, self, "virtual_connect_confirm"),
		cancel = callback(self, self, "virtual_connect_cancel")
	}

	ControllerWrapperPS4.super.init(self, manager, id, name, {
		ps4pad = controller
	}, "ps4pad", setup, debug, skip_virtual_controller, {
		ps4pad = func_map
	})
end

function ControllerWrapperPS4:virtual_connect_confirm(controller_id, controller, input_name, connection_name, connection)
	input_name = self:is_confirm_cancel_inverted() and "circle" or "cross"

	self:virtual_connect2(controller_id, controller, input_name, connection_name, connection)
end

function ControllerWrapperPS4:virtual_connect_cancel(controller_id, controller, input_name, connection_name, connection)
	input_name = self:is_confirm_cancel_inverted() and "cross" or "circle"

	self:virtual_connect2(controller_id, controller, input_name, connection_name, connection)
end

local is_PS4 = SystemInfo:platform() == Idstring("PS4")

function ControllerWrapperPS4:is_confirm_cancel_inverted()
	return is_PS4 and PS3:pad_cross_circle_inverted()
end
