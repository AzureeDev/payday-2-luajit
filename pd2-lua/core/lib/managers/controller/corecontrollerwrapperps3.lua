core:module("CoreControllerWrapperPS3")
core:import("CoreControllerWrapper")

ControllerWrapperPS3 = ControllerWrapperPS3 or class(CoreControllerWrapper.ControllerWrapper)
ControllerWrapperPS3.TYPE = "ps3"
ControllerWrapperPS3.CONTROLLER_TYPE_LIST = {
	"ps3_controller"
}

function ControllerWrapperPS3:init(manager, id, name, controller, setup, debug, skip_virtual_controller)
	local func_map = {
		confirm = callback(self, self, "virtual_connect_confirm"),
		cancel = callback(self, self, "virtual_connect_cancel")
	}

	ControllerWrapperPS3.super.init(self, manager, id, name, {
		ps3pad = controller
	}, "ps3pad", setup, debug, skip_virtual_controller, {
		ps3pad = func_map
	})
end

function ControllerWrapperPS3:virtual_connect_confirm(controller_id, controller, input_name, connection_name, connection)
	input_name = self:is_confirm_cancel_inverted() and "circle" or "cross"

	self:virtual_connect2(controller_id, controller, input_name, connection_name, connection)
end

function ControllerWrapperPS3:virtual_connect_cancel(controller_id, controller, input_name, connection_name, connection)
	input_name = self:is_confirm_cancel_inverted() and "cross" or "circle"

	self:virtual_connect2(controller_id, controller, input_name, connection_name, connection)
end

local is_PS3 = SystemInfo:platform() == Idstring("PS3")

function ControllerWrapperPS3:is_confirm_cancel_inverted()
	return is_PS3 and PS3:pad_cross_circle_inverted()
end
