core:module("CoreEditorUtils")
core:import("CoreEngineAccess")
core:import("CoreClass")

function all_lights()
	local lights = {}
	local all_units = World:find_units_quick("all")

	for _, unit in ipairs(all_units) do
		for _, light in ipairs(unit:get_objects_by_type(Idstring("light"))) do
			table.insert(lights, light)
		end
	end

	return lights
end

function get_editable_lights(unit)
	local has_lights = #unit:get_objects_by_type(Idstring("light")) > 0

	if not has_lights then
		return nil
	end

	local lights = {}
	local object_file = unit:model_filename()
	local node = DB:has("object", object_file) and DB:load_node("object", object_file)

	if node then
		for child in node:children() do
			if child:name() == "lights" then
				for light in child:children() do
					if light:has_parameter("editable") and light:parameter("editable") == "true" then
						table.insert(lights, unit:get_object(Idstring(light:parameter("name"))))
					end
				end
			end
		end
	end

	return lights
end

function has_editable_lights(unit)
	local lights = get_editable_lights(unit)

	return lights and #lights > 0
end

function has_any_projection_light(unit)
	local has_lights = #unit:get_objects_by_type(Idstring("light")) > 0

	if not has_lights then
		return nil
	end

	return has_projection_light(unit, "shadow_projection") or has_projection_light(unit, "projection")
end

function has_projection_light(unit, type)
	type = type or "projection"
	local object_file = CoreEngineAccess._editor_unit_data(unit:name():id()):model()
	local node = DB:has("object", object_file) and DB:load_node("object", object_file)

	if node then
		for child in node:children() do
			if child:name() == "lights" then
				for light in child:children() do
					if light:has_parameter(type) and light:parameter(type) == "true" then
						return light:parameter("name")
					end
				end
			end
		end
	end

	return nil
end

function is_projection_light(unit, light, type)
	type = type or "projection"
	local object_file = CoreEngineAccess._editor_unit_data(unit:name():id()):model()
	local node = DB:has("object", object_file) and DB:load_node("object", object_file)

	if node then
		for child in node:children() do
			if child:name() == "lights" then
				for light_node in child:children() do
					if light_node:has_parameter(type) and light_node:parameter(type) == "true" and light:name() == Idstring(light_node:parameter("name")) then
						return true
					end
				end
			end
		end
	end

	return false
end

function intensity_value()
	local t = {}

	for _, intensity in ipairs(LightIntensityDB:list()) do
		table.insert(t, LightIntensityDB:lookup(intensity))
	end

	table.sort(t)

	return t
end

INTENSITY_VALUES = intensity_value()

function get_intensity_preset(multiplier)
	local intensity = LightIntensityDB:reverse_lookup(multiplier)

	if intensity:s() ~= "undefined" then
		return intensity
	end

	local intensity_values = INTENSITY_VALUES

	for i = 1, #intensity_values do
		local next = intensity_values[i + 1]
		local this = intensity_values[i]

		if not next then
			return LightIntensityDB:reverse_lookup(this)
		end

		if this < multiplier and multiplier < next then
			if multiplier - this < next - multiplier then
				return LightIntensityDB:reverse_lookup(this)
			else
				return LightIntensityDB:reverse_lookup(next)
			end
		elseif multiplier < this then
			return LightIntensityDB:reverse_lookup(this)
		end
	end
end

function get_sequence_files_by_unit(unit, sequence_files)
	_get_sequence_file(CoreEngineAccess._editor_unit_data(unit:name()), sequence_files)
end

function get_sequence_files_by_unit_name(unit_name, sequence_files)
	_get_sequence_file(CoreEngineAccess._editor_unit_data(unit_name), sequence_files)
end

function _get_sequence_file(unit_data, sequence_files)
	for _, unit_name in ipairs(unit_data:unit_dependencies()) do
		_get_sequence_file(CoreEngineAccess._editor_unit_data(unit_name), sequence_files)
	end

	table.insert(sequence_files, unit_data:sequence_manager_filename())
end

GrabInfo = GrabInfo or CoreClass.class()

function GrabInfo:init(o, pos, rot)
	self._pos = pos or o:position()
	self._rot = rot or o:rotation()
end

function GrabInfo:rotation()
	return self._rot
end

function GrabInfo:position()
	return self._pos
end

layer_types = layer_types or {}

function parse_layer_types()
	assert(DB:has("xml", "core/settings/editor_types"), "Editor type settings are missing from core settings.")

	local node = DB:load_node("xml", "core/settings/editor_types")

	for layer in node:children() do
		layer_types[layer:name()] = {}

		for type in layer:children() do
			table.insert(layer_types[layer:name()], type:parameter("value"))
		end
	end

	if DB:has("xml", "settings/editor_types") then
		local node = DB:load_node("xml", "settings/editor_types")

		for layer in node:children() do
			layer_types[layer:name()] = {}

			for type in layer:children() do
				table.insert(layer_types[layer:name()], type:parameter("value"))
			end
		end
	end
end

function layer_type(layer)
	return layer_types[layer]
end

function get_layer_types()
	return layer_types
end

function toolbar_toggle(data, event)
	local c = data.class
	local toolbar = _G.type_name(data.toolbar) == "string" and c[data.toolbar] or data.toolbar
	c[data.value] = toolbar:tool_state(event:get_id())

	if c[data.menu] then
		c[data.menu]:set_checked(event:get_id(), c[data.value])
	end
end

function toolbar_toggle_trg(data)
	local c = data.class
	local toolbar = c[data.toolbar]

	toolbar:set_tool_state(data.id, not toolbar:tool_state(data.id))

	c[data.value] = toolbar:tool_state(data.id)

	if c[data.menu] then
		c[data.menu]:set_checked(data.id, c[data.value])
	end
end

function dump_mesh(units, name, get_objects_string)
	name = name or "dump_mesh"
	get_objects_string = get_objects_string or "g_*"
	units = units or World:find_units_quick("all", managers.slot:get_mask("dump_mesh"))
	local objects = {}
	local lods = {
		"e",
		"_e",
		"d",
		"_d",
		"c",
		"_c",
		"b",
		"_b",
		"a",
		"_a"
	}

	cat_print("editor", "Starting dump mesh")
	cat_print("editor", "  Dumping from " .. #units .. " units")

	for _, u in ipairs(units) do
		local i = 1
		local objs = {}

		if #objs == 0 then
			cat_print("editor", "getting gfx instead of lod for unit " .. u:name():s())

			objs = u:get_objects(get_objects_string)
		end

		cat_print("editor", "insert objs", #objs)

		for _, o in ipairs(objs) do
			cat_print("editor", "    " .. o:name():s())
			table.insert(objects, o)
		end

		objs = u:get_objects("gfx_*")

		cat_print("editor", "insert objs", #objs)

		for _, o in ipairs(objs) do
			cat_print("editor", "    " .. o:name():s())
			table.insert(objects, o)
		end
	end

	cat_print("editor", "  Dumped " .. #objects .. " objects")
	MeshDumper:dump_meshes(managers.database:root_path() .. name, objects, Rotation(Vector3(1, 0, 0), Vector3(0, 0, -1), Vector3(0, -1, 0)))
end

function dump_all(units, name, get_objects_string)
	name = name or "all_dumped"
	get_objects_string = get_objects_string or "g_*"
	units = units or World:find_units_quick("all", managers.slot:get_mask("dump_all"))
	local objects = {}

	cat_print("editor", "Starting dump mesh")
	cat_print("editor", "  Dumping from " .. #units .. " units")

	for _, u in ipairs(units) do
		local objs = {}
		local all_objs = u:get_objects("g_*")

		for i = 5, 0, -1 do
			for _, o in ipairs(all_objs) do
				if string.match(o:name():s(), "lod" .. i) then
					cat_print("editor", "insert obj", o:name():s())
					table.insert(objs, o)

					break
				end
			end

			if #objs > 0 then
				cat_print("editor", "enough lods, time to break")

				break
			end
		end

		if #objs == 0 then
			cat_print("editor", "getting gfx instead of lod for unit " .. u:name():s())

			objs = u:get_objects(get_objects_string)

			if #objs == 0 then
				objs = u:get_objects("gfx_*")
			end
		end

		cat_print("editor", "insert objs", #objs, "from unit", u:name():s())

		for _, o in ipairs(objs) do
			cat_print("editor", "    " .. o:name():s())
			table.insert(objects, o)
		end
	end

	cat_print("editor", "  Starting dump of " .. #objects .. " objects...")
	MeshDumper:dump_meshes(managers.database:root_path() .. name, objects, Rotation(Vector3(1, 0, 0), Vector3(0, 0, -1), Vector3(0, -1, 0)))
	cat_print("editor", "  .. dumping done.")
end
