core:module("CoreControllerWrapperXbox360")
core:import("CoreControllerWrapper")

ControllerWrapperXbox360 = ControllerWrapperXbox360 or class(CoreControllerWrapper.ControllerWrapper)
ControllerWrapperXbox360.TYPE = "xbox360"
ControllerWrapperXbox360.CONTROLLER_TYPE_LIST = {
	"xbox_controller"
}

function ControllerWrapperXbox360:init(manager, id, name, controller, setup, debug, skip_virtual_controller)
	local func_map = {
		confirm = callback(self, self, "virtual_connect_confirm"),
		cancel = callback(self, self, "virtual_connect_cancel")
	}

	ControllerWrapperXbox360.super.init(self, manager, id, name, {
		xbox360pad = controller
	}, "xbox360pad", setup, debug, skip_virtual_controller, {
		xbox360pad = func_map
	})
end

function ControllerWrapperXbox360:virtual_connect_confirm(controller_id, controller, input_name, connection_name, connection)
	self:virtual_connect2(controller_id, controller, "a", connection_name, connection)
end

function ControllerWrapperXbox360:virtual_connect_cancel(controller_id, controller, input_name, connection_name, connection)
	self:virtual_connect2(controller_id, controller, "b", connection_name, connection)
end
