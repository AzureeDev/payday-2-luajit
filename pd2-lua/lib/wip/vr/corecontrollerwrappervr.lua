core:module("CoreControllerWrapperVR")
core:import("CoreControllerWrapper")

ControllerWrapperVR = ControllerWrapperVR or class(CoreControllerWrapper.ControllerWrapper)
ControllerWrapperVR.TYPE = "vr"
ControllerWrapperVR.CONTROLLER_TYPE_LIST = {
	"vr_controller"
}

function ControllerWrapperVR:init(manager, id, name, controller, setup, debug, skip_virtual_controller)
	local func_map = {}

	ControllerWrapperVR.super.init(self, manager, id, name, {
		keyboard = Input:keyboard(),
		mouse = Input:mouse(),
		vr = controller
	}, "vr", setup, debug, skip_virtual_controller, {
		vr = func_map
	})
end
