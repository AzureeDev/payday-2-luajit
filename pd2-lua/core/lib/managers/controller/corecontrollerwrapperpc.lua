core:module("CoreControllerWrapperPC")
core:import("CoreControllerWrapper")

ControllerWrapperPC = ControllerWrapperPC or class(CoreControllerWrapper.ControllerWrapper)
ControllerWrapperPC.TYPE = "pc"
ControllerWrapperPC.CONTROLLER_TYPE_LIST = {
	"win32_keyboard",
	"win32_mouse"
}

function ControllerWrapperPC:init(manager, id, name, controller, setup, debug, skip_virtual_controller, gamepads)
	local func_map = {
		keyboard_axis_1 = callback(self, self, "virtual_connect_keyboard_axis_1"),
		keyboard_axis_2 = callback(self, self, "virtual_connect_keyboard_axis_2"),
		confirm = callback(self, self, "virtual_connect_confirm"),
		cancel = callback(self, self, "virtual_connect_cancel")
	}

	ControllerWrapperPC.super.init(self, manager, id, name, {
		keyboard = Input:keyboard(),
		mouse = Input:mouse(),
		gamepads = gamepads
	}, "keyboard", setup, debug, skip_virtual_controller, {
		keyboard = func_map
	})
end

function ControllerWrapperPC:virtual_connect_keyboard_axis_1(controller_id, controller, input_name, connection_name, connection)
	self._virtual_controller:add_axis(Idstring(connection_name))
	self._virtual_controller:connect(controller, Idstring("button"), Idstring("a"), Idstring("axis"), Idstring(connection_name), 0, Idstring("range"), 0, -1)
	self._virtual_controller:connect(controller, Idstring("button"), Idstring("d"), Idstring("axis"), Idstring(connection_name), 0, Idstring("range"), 0, 1)
	self._virtual_controller:connect(controller, Idstring("button"), Idstring("w"), Idstring("axis"), Idstring(connection_name), 1, Idstring("range"), 0, 1)
	self._virtual_controller:connect(controller, Idstring("button"), Idstring("s"), Idstring("axis"), Idstring(connection_name), 1, Idstring("range"), 0, -1)
end

function ControllerWrapperPC:virtual_connect_keyboard_axis_2(controller_id, controller, input_name, connection_name, connection)
	self._virtual_controller:add_axis(connection_name)
	self._virtual_controller:connect(controller, Idstring("button"), Idstring("left"), Idstring("axis"), Idstring(connection_name), 0, Idstring("range"), 0, -1)
	self._virtual_controller:connect(controller, Idstring("button"), Idstring("right"), Idstring("axis"), Idstring(connection_name), 0, Idstring("range"), 0, 1)
	self._virtual_controller:connect(controller, Idstring("button"), Idstring("up"), Idstring("axis"), Idstring(connection_name), 1, Idstring("range"), 0, 1)
	self._virtual_controller:connect(controller, Idstring("button"), Idstring("down"), Idstring("axis"), Idstring(connection_name), 1, Idstring("range"), 0, -1)
end

function ControllerWrapperPC:virtual_connect_confirm(controller_id, controller, input_name, connection_name, connection)
	self:virtual_connect2(controller_id, controller, "enter", connection_name, connection)
end

function ControllerWrapperPC:virtual_connect_cancel(controller_id, controller, input_name, connection_name, connection)
	self:virtual_connect2(controller_id, controller, "esc", connection_name, connection)
end

function ControllerWrapperPC:virtual_connect2(controller_id, controller, input_name, connection_name, connection)
	local min_src, max_src, min_dest, max_dest = connection:get_range()
	local connect_src_type = connection:get_connect_src_type()
	local connect_dest_type = connection:get_connect_dest_type()

	if connection._btn_connections and input_name == "buttons" then
		local btn_data = {
			up = {
				1,
				0,
				1
			},
			down = {
				1,
				0,
				-1
			},
			left = {
				0,
				0,
				-1
			},
			right = {
				0,
				0,
				1
			},
			accelerate = {
				1,
				0,
				1
			},
			brake = {
				1,
				0,
				-1
			},
			turn_left = {
				0,
				0,
				-1
			},
			turn_right = {
				0,
				0,
				1
			}
		}

		if not self._virtual_controller:has_axis(Idstring(connection_name)) then
			self._virtual_controller:add_axis(Idstring(connection_name))
		end

		for btn, input in pairs(connection._btn_connections) do
			local controller = self._controller_map.keyboard

			if (not controller:has_button(Idstring(input.name)) or input.type ~= "button") and (not controller:has_axis(Idstring(input.name)) or input.type ~= "axis") then
				controller = self._controller_map.gamepads
			end

			if controller:has_button(Idstring(input.name)) and input.type == "button" or controller:has_axis(Idstring(input.name)) and input.type == "axis" then
				if input.type == "axis" then
					self._virtual_controller:connect(controller, Idstring("axis"), Idstring(input.name), tonumber(input.dir), Idstring("range"), tonumber(input.range1), tonumber(input.range2), Idstring("axis"), Idstring(connection_name), btn_data[btn][1], Idstring("range"), btn_data[btn][2], btn_data[btn][3])
				else
					self._virtual_controller:connect(controller, Idstring("button"), Idstring(input.name), Idstring("axis"), Idstring(connection_name), btn_data[btn][1], Idstring("range"), btn_data[btn][2], btn_data[btn][3])
				end
			end
		end
	else
		local input_name_str = type(input_name) == "number" and tostring(input_name) or input_name

		if self._controller_map.gamepads:has_button(Idstring(input_name_str)) or self._controller_map.gamepads:has_axis(Idstring(input_name_str)) then
			controller = self._controller_map.gamepads
		end

		if controller:has_button(Idstring(input_name_str)) or controller:has_axis(Idstring(input_name_str)) then
			self._virtual_controller:connect(controller, Idstring(connect_src_type), Idstring(input_name_str), Idstring("range"), min_src, max_src, Idstring(connect_dest_type), Idstring(connection_name), Idstring("range"), min_dest, max_dest)
		elseif self._virtual_controller:has_button(Idstring(input_name_str)) or self._virtual_controller:has_axis(Idstring(input_name_str)) then
			self._virtual_controller:connect(self._virtual_controller, Idstring(connect_src_type), Idstring(input_name_str), Idstring("range"), min_src, max_src, Idstring(connect_dest_type), Idstring(connection_name), Idstring("range"), min_dest, max_dest)
		else
			Application:error("Invalid input name \"" .. tostring(input_name_str) .. "\". Controller type: \"" .. tostring(controller_id) .. "\", Connection name: \"" .. tostring(connection_name) .. "\".")
		end
	end
end
