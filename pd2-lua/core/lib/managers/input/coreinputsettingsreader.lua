core:module("CoreInputSettingsReader")
core:import("CoreInputLayerDescription")
core:import("CoreInputContextDescription")
core:import("CoreInputLayoutDescription")
core:import("CoreInputDeviceLayoutDescription")
core:import("CoreInputTargetDescription")

SettingsReader = SettingsReader or class()
SettingsReader.db_type = "input_settings"
SettingsReader.db_path = "settings/input"

function SettingsReader:init()
	self._layer_descriptions = {}

	self:_read_settings()
end

function SettingsReader:layer_descriptions()
	return self._layer_descriptions
end

function SettingsReader:_read_settings()
	if not DB:has(SettingsReader.db_type, SettingsReader.db_path) then
		return
	end

	local xml_node = DB:load_node(SettingsReader.db_type, SettingsReader.db_path)
	local xml_node_children = xml_node:children()

	self:_read_children(xml_node_children)
end

function SettingsReader:_read_children(nodes)
	self._layer_descriptions = {}
	local layer_description_priority = 1

	for node in nodes do
		assert(node:name() == "layer")

		local layer_description = CoreInputLayerDescription.LayerDescription:new(node:parameter("name"), layer_description_priority)

		self:_read_layer_description_children(node:children(), layer_description)

		self._layer_descriptions[layer_description:layer_description_name()] = layer_description
		layer_description_priority = layer_description_priority + 1
	end
end

function SettingsReader:_read_layer_description_children(nodes, layer_description)
	for node in nodes do
		assert(node:name() == "context")

		local context_description = CoreInputContextDescription.ContextDescription:new(node:parameter("name"))

		layer_description:set_context_description(context_description)
		self:_read_context_description_children(node:children(), context_description)
	end
end

function SettingsReader:_read_context_description_children(nodes, context_description)
	for node in nodes do
		if node:name() == "input" then
			self:_read_input(node, context_description)
		elseif node:name() == "layouts" then
			self:_read_layout_descriptions_children(node:children(), context_description)
		elseif node:name() == "context" then
			local new_context_description = CoreInputContextDescription.ContextDescription:new(node:parameter("name"))

			context_description:add_context_description(new_context_description)
			self:_read_context_description_children(node:children(), new_context_description)
		end
	end
end

function SettingsReader:_read_input(node, context_description)
	local type_name = node:parameter("type")
	local name = node:parameter("name")
	local input_target_description = CoreInputTargetDescription.TargetDescription:new(name, type_name)

	context_description:add_input_target_description(input_target_description)
end

function SettingsReader:_read_layout_descriptions_children(nodes, context_description)
	for node in nodes do
		assert(node:name() == "layout")

		local layout_description = CoreInputLayoutDescription.LayoutDescription:new(node:parameter("name"))

		self:_read_layout_description_children(node:children(), context_description, layout_description)
		context_description:add_layout_description(layout_description)
	end
end

function SettingsReader:_read_layout_description_children(nodes, context_description, layout_description)
	for node in nodes do
		assert(node:name() == "device", "Only <device> is allowed as children to <layout>. Encountered '" .. node:name() .. "'")

		local device_layout_description = CoreInputDeviceLayoutDescription.DeviceLayoutDescription:new(node:parameter("type"))

		self:_read_device_layout_description_children(node:children(), context_description, device_layout_description)
		layout_description:add_device_layout_description(device_layout_description)
	end
end

function SettingsReader:_read_device_layout_description_children(nodes, context_description, device_layout_description)
	for node in nodes do
		assert(node:name() == "bind")
		self:_read_bind(node, context_description, device_layout_description)
	end
end

function SettingsReader:_read_bind(node, context_description, device_layout_description)
	local axis_name = node:parameter("axis")
	local input_name = node:parameter("input")
	local input_target_description = context_description:input_target_description(input_name)

	assert(input_target_description, "Illegal input target name:'" .. input_name .. "'")

	if axis_name then
		device_layout_description:add_bind_axis(axis_name, input_target_description)
	else
		local button_name = node:parameter("button")

		if button_name then
			device_layout_description:add_bind_button(button_name, input_target_description)
		else
			assert(false, "Unknown source, must be button or axis")
		end
	end
end
