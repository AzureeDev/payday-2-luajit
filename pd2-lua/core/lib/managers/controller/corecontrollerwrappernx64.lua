core:module("CoreControllerWrapperNX64")
core:import("CoreControllerWrapper")

ControllerWrapperNX64 = ControllerWrapperNX64 or class(CoreControllerWrapper.ControllerWrapper)
ControllerWrapperNX64.TYPE = "nx64"
ControllerWrapperNX64.CONTROLLER_TYPE_LIST = {
	"nx64_controller"
}

function ControllerWrapperNX64:init(manager, id, name, controller, setup, debug, skip_virtual_controller)
	local func_map = {
		confirm = callback(self, self, "virtual_connect_confirm"),
		cancel = callback(self, self, "virtual_connect_cancel")
	}

	ControllerWrapperNX64.super.init(self, manager, id, name, {
		nx64pad = controller
	}, "nx64pad", setup, debug, skip_virtual_controller, {
		nx64pad = func_map
	})
end

function ControllerWrapperNX64:virtual_connect_confirm(controller_id, controller, input_name, connection_name, connection)
	input_name = self:is_confirm_cancel_inverted() and "button_a" or "button_b"

	self:virtual_connect2(controller_id, controller, input_name, connection_name, connection)
end

function ControllerWrapperNX64:virtual_connect_cancel(controller_id, controller, input_name, connection_name, connection)
	input_name = self:is_confirm_cancel_inverted() and "button_b" or "button_a"

	self:virtual_connect2(controller_id, controller, input_name, connection_name, connection)
end

local is_NX64 = SystemInfo:platform() == Idstring("NX64")

function ControllerWrapperNX64:is_confirm_cancel_inverted()
	return is_NX64
end
