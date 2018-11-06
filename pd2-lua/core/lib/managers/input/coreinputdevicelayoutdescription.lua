core:module("CoreInputDeviceLayoutDescription")

DeviceLayoutDescription = DeviceLayoutDescription or class()

function DeviceLayoutDescription:init(device_type)
	assert(device_type == "xbox_controller" or device_type == "ps3_controller" or device_type == "win32_mouse")

	self._device_type = device_type
	self._binds = {}
end

function DeviceLayoutDescription:device_type()
	return self._device_type
end

function DeviceLayoutDescription:add_bind_button(hardware_button_name, input_target_description)
	self._binds[hardware_button_name] = {
		type_name = "button",
		input_target_description = input_target_description
	}
end

function DeviceLayoutDescription:add_bind_axis(hardware_axis_name, input_target_description)
	self._binds[hardware_axis_name] = {
		type_name = "axis",
		input_target_description = input_target_description
	}
end

function DeviceLayoutDescription:binds()
	return self._binds
end
