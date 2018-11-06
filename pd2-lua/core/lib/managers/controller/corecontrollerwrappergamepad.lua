core:module("CoreControllerWrapperGamepad")
core:import("CoreControllerWrapper")

ControllerWrapperGamepad = ControllerWrapperGamepad or class(CoreControllerWrapper.ControllerWrapper)
ControllerWrapperGamepad.TYPE = "gamepad"
ControllerWrapperGamepad.CONTROLLER_TYPE_LIST = {
	"win32_game_controller"
}
ControllerWrapperGamepad.IDS_POV_0 = Idstring("pov 0")
ControllerWrapperGamepad.IDS_AXIS = Idstring("axis")
ControllerWrapperGamepad.IDS_RANGE = Idstring("range")
ControllerWrapperGamepad.IDS_BUTTON = Idstring("button")
ControllerWrapperGamepad.IDS_DIRECTION = Idstring("direction")
ControllerWrapperGamepad.IDS_ROTATION = Idstring("rotation")

function ControllerWrapperGamepad:init(manager, id, name, controller, setup, debug, skip_virtual_controller)
	local func_map = {
		up = callback(self, self, "virtual_connect_up"),
		down = callback(self, self, "virtual_connect_down"),
		right = callback(self, self, "virtual_connect_right"),
		left = callback(self, self, "virtual_connect_left"),
		confirm = callback(self, self, "virtual_connect_confirm"),
		cancel = callback(self, self, "virtual_connect_cancel"),
		axis1 = callback(self, self, "virtual_connect_axis1"),
		axis2 = callback(self, self, "virtual_connect_axis2")
	}

	ControllerWrapperGamepad.super.init(self, manager, id, name, {
		gamepad = controller,
		keyboard = Input:keyboard(),
		mouse = Input:mouse()
	}, "gamepad", setup, debug, skip_virtual_controller, {
		gamepad = func_map
	})
end

function ControllerWrapperGamepad:virtual_connect_up(controller_id, controller, input_name, connection_name, connection)
	if controller:has_axis(self.IDS_POV_0) then
		self._virtual_controller:connect(controller, self.IDS_AXIS, self.IDS_POV_0, 1, self.IDS_RANGE, 0, -1, self.IDS_BUTTON, Idstring(connection_name))
	else
		controller_id, controller, input_name, connection_name, connection = self:get_fallback_button(controller_id, controller, input_name, connection_name, connection)

		self:virtual_connect2(controller_id, controller, input_name, connection_name, connection)
	end
end

function ControllerWrapperGamepad:virtual_connect_down(controller_id, controller, input_name, connection_name, connection)
	if controller:has_axis(self.IDS_POV_0) then
		self._virtual_controller:connect(controller, self.IDS_AXIS, self.IDS_POV_0, 1, self.IDS_RANGE, 0, 1, self.IDS_BUTTON, Idstring(connection_name))
	else
		controller_id, controller, input_name, connection_name, connection = self:get_fallback_button(controller_id, controller, input_name, connection_name, connection)

		self:virtual_connect2(controller_id, controller, input_name, connection_name, connection)
	end
end

function ControllerWrapperGamepad:virtual_connect_right(controller_id, controller, input_name, connection_name, connection)
	if controller:has_axis(self.IDS_POV_0) then
		self._virtual_controller:connect(controller, self.IDS_AXIS, self.IDS_POV_0, 0, self.IDS_RANGE, 0, 1, self.IDS_BUTTON, Idstring(connection_name))
	else
		controller_id, controller, input_name, connection_name, connection = self:get_fallback_button(controller_id, controller, input_name, connection_name, connection)

		self:virtual_connect2(controller_id, controller, input_name, connection_name, connection)
	end
end

function ControllerWrapperGamepad:virtual_connect_left(controller_id, controller, input_name, connection_name, connection)
	if controller:has_axis(self.IDS_POV_0) then
		self._virtual_controller:connect(controller, self.IDS_AXIS, self.IDS_POV_0, 0, self.IDS_RANGE, 0, -1, self.IDS_BUTTON, Idstring(connection_name))
	else
		controller_id, controller, input_name, connection_name, connection = self:get_fallback_button(controller_id, controller, input_name, connection_name, connection)

		self:virtual_connect2(controller_id, controller, input_name, connection_name, connection)
	end
end

function ControllerWrapperGamepad:virtual_connect_confirm(controller_id, controller, input_name, connection_name, connection)
	if controller:has_button(2) then
		self:virtual_connect2(controller_id, controller, 2, connection_name, connection)
	else
		controller_id, controller, input_name, connection_name, connection = self:get_fallback_button(controller_id, controller, input_name, connection_name, connection)

		self:virtual_connect2(controller_id, controller, input_name, connection_name, connection)
	end
end

function ControllerWrapperGamepad:virtual_connect_cancel(controller_id, controller, input_name, connection_name, connection)
	if controller:has_button(1) then
		self:virtual_connect2(controller_id, controller, 1, connection_name, connection)
	else
		controller_id, controller, input_name, connection_name, connection = self:get_fallback_button(controller_id, controller, input_name, connection_name, connection)

		self:virtual_connect2(controller_id, controller, input_name, connection_name, connection)
	end
end

function ControllerWrapperGamepad:virtual_connect_axis1(controller_id, controller, input_name, connection_name, connection)
	input_name = "direction"

	if not controller:has_axis(self.IDS_DIRECTION) then
		local axes_count = controller:num_axes()

		if axes_count > 0 then
			input_name = controller:axis_name(0)

			if axes_count > 1 and input_name == "rotation" then
				input_name = controller:axis_name(1)
			end
		end
	end

	self:virtual_connect2(controller_id, controller, input_name, connection_name, connection)
end

function ControllerWrapperGamepad:virtual_connect_axis2(controller_id, controller, input_name, connection_name, connection)
	input_name = "rotation"

	if not controller:has_axis(self.IDS_ROTATION) then
		local axes_count = controller:num_axes()

		if axes_count > 0 then
			input_name = controller:axis_name(0)

			if axes_count > 1 and input_name == "direction" then
				input_name = controller:axis_name(1)
			end
		end
	end

	self:virtual_connect2(controller_id, controller, input_name, connection_name, connection)
end

function ControllerWrapperGamepad:virtual_connect2(controller_id, controller, input_name, connection_name, connection)
	if connection:get_connect_src_type() == "axis" then
		if not controller:has_axis(Idstring(input_name)) then
			controller_id, controller, input_name, connection_name, connection = self:get_fallback_axis(controller_id, controller, input_name, connection_name, connection)
		end
	else
		local button_index = tonumber(input_name)

		if not button_index or not controller:has_button(button_index) then
			controller_id, controller, input_name, connection_name, connection = self:get_fallback_button(controller_id, controller, input_name, connection_name, connection)
		else
			input_name = button_index
		end
	end

	ControllerWrapperGamepad.super.virtual_connect2(self, controller_id, controller, input_name, connection_name, connection)
end

function ControllerWrapperGamepad:get_fallback_axis(controller_id, controller, input_name, connection_name, connection)
	return "mouse", Input:mouse(), "mouse", connection_name, connection
end

function ControllerWrapperGamepad:get_fallback_button(controller_id, controller, input_name, connection_name, connection)
	controller = Input:keyboard()

	if input_name == "cancel" then
		input_name = "esc"
	elseif not controller:has_button(Idstring(input_name)) then
		input_name = "enter"
	end

	return "keyboard", controller, input_name, connection_name, connection
end

function ControllerWrapperGamepad:get_input_axis(connection_name)
	local cache = ControllerWrapperGamepad.super.get_input_axis(self, connection_name)

	if connection_name == "look" then
		cache = Vector3(-cache.y, -cache.x, 0)
	end

	return cache
end
