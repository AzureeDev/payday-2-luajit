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

local disabled_connections = {
	"confirm",
	"menu_up",
	"menu_down",
	"menu_left",
	"menu_right",
	"menu_move"
}

function ControllerWrapperVR:get_input_bool(connection)
	if rawget(_G, "setup").IS_START_MENU then
		for _, c in ipairs(disabled_connections) do
			if connection == c then
				return
			end
		end
	end

	return ControllerWrapperVR.super.get_input_bool(self, connection)
end

function ControllerWrapperVR:get_input_pressed(connection)
	if rawget(_G, "setup").IS_START_MENU then
		for _, c in ipairs(disabled_connections) do
			if connection == c then
				return
			end
		end
	end

	return ControllerWrapperVR.super.get_input_pressed(self, connection)
end

function ControllerWrapperVR:get_input_released(connection)
	if rawget(_G, "setup").IS_START_MENU then
		for _, c in ipairs(disabled_connections) do
			if connection == c then
				return
			end
		end
	end

	return ControllerWrapperVR.super.get_input_released(self, connection)
end

function ControllerWrapperVR:get_input_axis(connection)
	if rawget(_G, "setup").IS_START_MENU then
		for _, c in ipairs(disabled_connections) do
			if connection == c then
				return Vector3(0, 0, 0)
			end
		end
	end

	return ControllerWrapperVR.super.get_input_axis(self, connection)
end
