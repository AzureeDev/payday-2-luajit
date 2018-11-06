core:module("CoreCameraManager")
core:import("CoreEngineAccess")
core:import("CoreCameraMixer")
core:import("CoreCameraDataInterpreter")
core:import("CoreTransformCameraNode")
core:import("CoreUnitLinkCameraNode")
core:import("CoreCollisionCameraNode")
core:import("CoreSpringCameraNode")
core:import("CoreAimCameraNode")
core:import("CoreClass")
core:import("CoreMath")
core:import("CoreUnit")

CameraBase = CameraBase or CoreClass.class()

function CameraBase:init()
	self._nodes = {}
	self._name_to_nodes = {}
	self._setup = nil
	self._default_blend = 0
	self._blend_table = {}
end

function CameraBase:destroy()
	for index, node in ipairs(self._nodes) do
		node:destroy()
	end

	self._nodes = {}
	self._setup = nil
end

function CameraBase:name()
	return self._setup._name
end

function CameraBase:transition_blend(from_camera)
	return self._blend_table[from_camera:name()]
end

function CameraBase:default_blend()
	return self._default_blend
end

function CameraBase:node(node_name)
	return self._name_to_nodes[node_name]
end

function CameraBase:nodes()
	return self._nodes
end

CameraManager = CameraManager or CoreClass.class()

function CameraManager:init(templates)
	self._layers = {}

	self:create_layers(templates)
end

function CameraManager:destroy()
	for index, mixer in ipairs(self._layers) do
		mixer:destroy()
	end

	self._layers = {}
end

function CameraManager:create_layers(templates)
	for index, mixer in ipairs(self._layers) do
		mixer:destroy()
	end

	self._layers = {}
	self._name_to_layer = {}
	self._templates = templates
	self._interpreter = templates._interpreter_class:new()

	for index, layer_name in ipairs(templates._layers) do
		local mixer = CoreCameraMixer.CameraMixer:new(layer_name)

		table.insert(self._layers, mixer)

		self._name_to_layer[layer_name] = mixer
	end
end

function CameraManager:view_camera(camera_name, force_new_camera)
	local layer_name = self:get_camera_layer(camera_name)
	local mixer = self._name_to_layer[layer_name]
	local active_camera = mixer:active_camera()

	if active_camera and not force_new_camera and active_camera:name() == camera_name then
		return active_camera
	end

	local camera = self:create_camera(camera_name, self._unit)
	local blend_time = 0

	if active_camera then
		blend_time = camera:transition_blend(active_camera)
	end

	blend_time = blend_time or camera:default_blend()

	assert(blend_time)
	mixer:add_camera(camera, blend_time)

	return camera
end

function CameraManager:stop_all_layers()
	for index, layer in ipairs(self._layers) do
		layer:stop()
	end
end

function CameraManager:stop_layer(layer_name)
	local mixer = nil

	if layer_name then
		mixer = self._name_to_layer[layer_name]
	else
		mixer = self._layers[1]
	end

	mixer:stop()
end

function CameraManager:get_camera_layer(name)
	local camera_setups = self._templates._setups

	local function get_camera_layer(name)
		local camera_setup = camera_setups[name]

		assert(camera_setup)

		local layer = camera_setup._layer

		if layer then
			return layer
		end

		local parent_name = camera_setup._inherits

		if parent_name then
			return get_camera_layer(parent_name)
		end
	end

	local layer_name = get_camera_layer(name)

	assert(layer_name)

	return layer_name
end

function CameraManager:create_camera(name)
	local templates = self._templates
	local camera_setups = templates._setups
	local camera_node_setups = templates._node_setups
	local camera_list = {}

	local function get_camera_chain(name, cam_list)
		local camera_setup = camera_setups[name]

		assert(camera_setup)

		local parent_name = camera_setup._inherits

		if parent_name then
			get_camera_chain(parent_name, cam_list)
		end

		table.insert(cam_list, camera_setup)
	end

	get_camera_chain(name, camera_list)

	local camera = CameraBase:new()
	local nodes = camera._nodes
	local name_to_nodes = camera._name_to_nodes
	local blend_table = camera._blend_table
	local parent_node = nil
	local num_cameras = 0

	for _, camera_setup in ipairs(camera_list) do
		num_cameras = num_cameras + 1

		for index, node_table in ipairs(camera_setup._camera_nodes) do
			local node_setup = camera_node_setups[node_table._node_name]
			local camera_node = node_setup._class:new(node_setup._settings)

			if node_table._name then
				camera_node._name = node_table._name
			end

			name_to_nodes[camera_node._name] = camera_node

			if node_table._position then
				camera_node._pivot_position = node_table._position
			end

			if node_table._rotation then
				camera_node._pivot_rotation = node_table._rotation
			end

			if parent_node then
				camera_node:set_parent(parent_node)
			end

			parent_node = camera_node

			table.insert(nodes, camera_node)
		end

		if camera_setup._default_blend then
			camera._default_blend = camera_setup._default_blend
		end

		for key, value in pairs(camera_setup._blend_table) do
			blend_table[key] = value
		end

		if camera_setup._layer then
			camera._layer = camera_setup._layer
		end
	end

	camera._setup = camera_list[num_cameras]

	return camera
end

function CameraManager:update(time, dt)
	self._interpreter:reset()

	local interpreter_class = self._templates._interpreter_class

	for index, mixer in ipairs(self._layers) do
		mixer:update(self._interpreter, interpreter_class, time, dt)
	end

	if self._debug_render_enable then
		for index, mixer in ipairs(self._layers) do
			mixer:debug_render(time, dt)
		end
	end
end

function CameraManager:interpreter()
	return self._interpreter
end

function CameraManager:print_cameras()
	for index, mixer in ipairs(self._layers) do
		cat_print("debug", "layer: '" .. mixer._name .. "'")

		local cameras = mixer:cameras()

		for _, camera in ipairs(cameras) do
			cat_print("debug", "camera: '" .. camera._setup._name .. "'")
		end
	end
end

CameraTemplateManager = CameraTemplateManager or CoreClass.class()
CameraTemplateManager.camera_db_type = "camera"
CameraTemplateManager.camera_db_path = "cameras/cameras"

function CameraTemplateManager:init()
	self._camera_space = {}
	self._parse_func_table = {
		interpreter = CameraTemplateManager.parse_interpreter,
		layer = CameraTemplateManager.parse_layer,
		camera = CameraTemplateManager.parse_camera,
		camera_node = CameraTemplateManager.parse_camera_node,
		depends_on = CameraTemplateManager.parse_depends_on
	}
	self._camera_managers = {}

	self:load_cameras()
end

function CameraTemplateManager:create_camera_manager(camera_space)
	local camera_space = self._camera_space[camera_space]
	local cm = CameraManager:new(camera_space)

	table.insert(self._camera_managers, cm)

	return cm
end

function CameraTemplateManager:load_cameras()
	self:clear()

	if DB:has(CameraTemplateManager.camera_db_type, CameraTemplateManager.camera_db_path) then
		local xml_node = DB:load_node(CameraTemplateManager.camera_db_type, CameraTemplateManager.camera_db_path)
		local xml_node_children = xml_node:children()

		for xml_child_node in xml_node_children do
			if xml_child_node:name() == "camera_file" and xml_child_node:has_parameter("file") then
				self:load_camera_file(xml_child_node:parameter("file"))
			end
		end
	end

	for index, cm in ipairs(self._camera_managers) do
		local template_name = cm._templates._name
		local template = self._camera_space[template_name]

		cm:create_layers(template)
	end
end

function CameraTemplateManager:load_camera_file(file_name)
	if DB:has(CameraTemplateManager.camera_db_type, file_name) then
		local xml_node = DB:load_node(CameraTemplateManager.camera_db_type, file_name)

		if xml_node:name() == "camera_space" then
			local space_name = xml_node:parameter("name")
			self._camera_space[space_name] = self._camera_space[space_name] or {}
			local space = self._camera_space[space_name]
			space._name = space_name
			space._interpreter_class = CoreCameraDataInterpreter.CameraDataInterpreter
			space._node_setups = {}
			space._setups = {}
			space._layers = {}
			local xml_node_children = xml_node:children()

			for xml_child_node in xml_node_children do
				local parse_func = self._parse_func_table[xml_child_node:name()]

				if parse_func then
					parse_func(self, xml_child_node, space)
				end
			end
		end
	end
end

function CameraTemplateManager:clear()
	self._camera_space = {}
end

function CameraTemplateManager:get_layers(camera_space)
	local space = self._camera_space[camera_space]

	return space._layers
end

function CameraTemplateManager:parse_layer(xml_node, space)
	local layer_name = xml_node:parameter("name")

	table.insert(space._layers, layer_name)
end

function CameraTemplateManager:parse_interpreter(xml_node, space)
	local interpreter_class = xml_node:parameter("class")
	space._interpreter_class = rawget(_G, interpreter_class)
end

function CameraTemplateManager:parse_camera(xml_node, space)
	local camera_setups = space._setups
	local setup = {}
	local name = xml_node:parameter("name")

	assert(name)

	if xml_node:has_parameter("inherits") then
		setup._inherits = xml_node:parameter("inherits")
	end

	if xml_node:has_parameter("layer") then
		setup._layer = xml_node:parameter("layer")
	end

	setup._name = name
	setup._camera_nodes = {}
	setup._blend_table = {}
	camera_setups[name] = setup

	local function parse_node(xml_node)
		local node = {
			_node_name = xml_node:parameter("node_name")
		}

		assert(node._node_name)

		if xml_node:has_parameter("name") then
			node._name = xml_node:parameter("name")
		end

		if xml_node:has_parameter("position") then
			node._position = math.string_to_vector(xml_node:parameter("position"))
		end

		if xml_node:has_parameter("rotation") then
			node._rotation = CoreMath.string_to_rotation(xml_node:parameter("rotation"))
		end

		table.insert(setup._camera_nodes, node)
	end

	local function parse_default_blend(xml_node)
		if xml_node:has_parameter("blend") then
			setup._default_blend = tonumber(xml_node:parameter("blend"))
		end
	end

	local function parse_from_blend(xml_node)
		if xml_node:has_parameter("name") then
			local name = xml_node:parameter("name")
			local blend_value = 0

			if xml_node:has_parameter("blend") then
				blend_value = xml_node:parameter("blend")
			end

			setup._blend_table[name] = blend_value
		end
	end

	local parse_func_table = {
		node = parse_node,
		default = parse_default_blend,
		from = parse_from_blend
	}
	local xml_node_children = xml_node:children()

	for xml_child_node in xml_node_children do
		local parse_func = parse_func_table[xml_child_node:name()]

		if parse_func then
			parse_func(xml_child_node)
		end
	end
end

function CameraTemplateManager:parse_camera_node(xml_node, space)
	local function split_string(str)
		local strings = {}

		for word in string.gmatch(str, "[^%p]+") do
			table.insert(strings, word)
		end

		return strings
	end

	if xml_node:has_parameter("class") and xml_node:has_parameter("name") then
		local camera_node_setups = space._node_setups
		local class_name = xml_node:parameter("class")
		local class_hier = split_string(class_name)
		local class = nil

		if #class_hier > 1 then
			local module = core:import(class_hier[1])
			class = module[class_hier[2]]
		else
			class = rawget(_G, class_name)
		end

		if not class then
			assert(class)
		end

		local settings = {}

		class.compile_settings(xml_node, settings)

		local setup = {
			_class = class,
			_class_name = class_name,
			_settings = settings
		}
		local name = xml_node:parameter("name")
		camera_node_setups[name] = setup
	end
end

function CameraTemplateManager:parse_depends_on(xml_node, space)
	if Application:editor() then
		if xml_node:has_parameter("unit") then
			CoreUnit.editor_load_unit(xml_node:parameter("unit"))
		elseif xml_node:has_parameter("effect") then
			CoreEngineAccess._editor_load("effect", xml_node:parameter("effect"):id())
		end
	end
end

function CameraTemplateManager:update(t, dt)
	for index, cam_man in ipairs(self._camera_managers) do
		cam_man:update(t, dt)
	end
end
