core:module("CoreControllerWrapperSteam")
core:import("CoreControllerWrapper")

ControllerWrapperSteam = ControllerWrapperSteam or class(CoreControllerWrapper.ControllerWrapper)
ControllerWrapperSteam.TYPE = "steam"
ControllerWrapperSteam.CONTROLLER_TYPE_LIST = {
	"steam_controller"
}

function ControllerWrapperSteam:init(manager, id, name, controller, setup, debug, skip_virtual_controller)
	local func_map = {
		confirm = callback(self, self, "virtual_connect_confirm"),
		cancel = callback(self, self, "virtual_connect_cancel")
	}

	ControllerWrapperSteam.super.init(self, manager, id, name, {
		keyboard = Input:keyboard(),
		mouse = Input:mouse(),
		steampad = controller
	}, "steampad", setup, debug, skip_virtual_controller, {
		steampad = func_map
	})
end

function ControllerWrapperSteam:virtual_connect_confirm(controller_id, controller, input_name, connection_name, connection)
	self:virtual_connect2(controller_id, controller, "button_a", connection_name, connection)
end

function ControllerWrapperSteam:virtual_connect_cancel(controller_id, controller, input_name, connection_name, connection)
	self:virtual_connect2(controller_id, controller, "button_b", connection_name, connection)
end

function ControllerWrapperSteam:show_binding_panel()
	if self._controller_map and self._controller_map.steampad then
		return self._controller_map.steampad:show_binding_panel()
	end
end

function ControllerWrapperSteam.convert_virtual_action(action)
	if action == "confirm" then
		return "button_a"
	elseif action == "cancel" then
		return "button_b"
	end

	return action
end

function ControllerWrapperSteam.change_mode(controller, mode)
	if controller and mode then
		controller:change_mode(mode)

		return mode
	end
end
