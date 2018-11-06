core:module("CoreInputLayoutDescription")

LayoutDescription = LayoutDescription or class()

function LayoutDescription:init(name)
	self._name = name
	self._device_layout_descriptions = {}
end

function LayoutDescription:layout_name()
	return self._name
end

function LayoutDescription:add_device_layout_description(device_layout_description)
	self._device_layout_descriptions[device_layout_description:device_type()] = device_layout_description
end

function LayoutDescription:device_layout_description(device_type)
	return self._device_layout_descriptions[device_type]
end
