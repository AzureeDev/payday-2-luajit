CoreWorldInstanceManager = CoreWorldInstanceManager or class()

function CoreWorldInstanceManager:init()
	self._instance_data = {}
	self._registered_input_elements = {}
	self._registered_output_event_elements = {}
	self._instance_params = {}
	self._start_offset_index = 30000
end

function CoreWorldInstanceManager:start_offset_index()
	return self._start_offset_index
end

function CoreWorldInstanceManager:add_instance_data(data)
	table.insert(self._instance_data, data)
end

function CoreWorldInstanceManager:get_instance_data_by_name(name)
	for _, instance_data in ipairs(self._instance_data) do
		if instance_data.name == name then
			return instance_data
		end
	end

	return false
end

function CoreWorldInstanceManager:has_instance(name)
	for _, instance_data in ipairs(self._instance_data) do
		if instance_data.name == name then
			return true
		end
	end

	return false
end

function CoreWorldInstanceManager:get_safe_name(instance_name, name)
	local start_number = 1

	if name then
		local sub_name = name

		for i = string.len(name), 0, -1 do
			local sub = string.sub(name, i, string.len(name))
			sub_name = string.sub(name, 0, i)

			if tonumber(sub) then
				start_number = tonumber(sub)
			else
				break
			end
		end

		name = sub_name
	else
		name = instance_name .. "_"
	end

	local names = {}

	for _, instance_data in ipairs(self._instance_data) do
		names[instance_data.name] = true
	end

	for i = start_number, 10000 do
		i = (i < 10 and "00" or i < 100 and "0" or "") .. i
		local name_id = name .. i

		if not names[name_id] then
			return name_id
		end
	end
end

function CoreWorldInstanceManager:get_safe_start_index(index_size, continent)
	local start_indices = {}
	local end_indices = {}

	for _, instance_data in ipairs(self._instance_data) do
		if instance_data.continent == continent then
			table.insert(start_indices, instance_data.start_index)
			table.insert(end_indices, instance_data.start_index + (instance_data.index_size or 600) - 1)
		end
	end

	table.sort(start_indices)
	table.sort(end_indices)

	local new_index = 0

	for i, si in ipairs(start_indices) do
		local ei = end_indices[i]

		if not start_indices[i + 1] then
			return ei + 1
		else
			local next_si = start_indices[i + 1]

			if index_size < next_si - ei then
				return ei + 1
			end
		end
	end

	return 0
end

function CoreWorldInstanceManager:get_used_indices(continent)
	local start_indices = {}
	local end_indices = {}

	for _, instance_data in ipairs(self._instance_data) do
		if instance_data.continent == continent then
			table.insert(start_indices, instance_data.start_index)
			table.insert(end_indices, instance_data.start_index + (instance_data.index_size or 600) - 1)
		end
	end

	table.sort(start_indices)
	table.sort(end_indices)

	return start_indices, end_indices
end

function CoreWorldInstanceManager:rename_instance(name, new_name)
	local data = self:get_instance_data_by_name(name)

	if data then
		data.name = new_name
	end
end

function CoreWorldInstanceManager:instance_data()
	return self._instance_data
end

function CoreWorldInstanceManager:instance_names_by_script(script)
	local names = {}

	for _, instance_data in ipairs(self._instance_data) do
		if instance_data.script == script then
			table.insert(names, instance_data.name)
		end
	end

	table.sort(names)

	return names
end

function CoreWorldInstanceManager:instance_names(continent)
	local names = {}

	for _, instance_data in ipairs(self._instance_data) do
		if not continent or instance_data.continent == continent then
			table.insert(names, instance_data.name)
		end
	end

	table.sort(names)

	return names
end

function CoreWorldInstanceManager:instances_data_by_continent(continent)
	local instances = {}

	for _, instance_data in ipairs(self._instance_data) do
		if not continent or instance_data.continent == continent then
			table.insert(instances, instance_data)
		end
	end

	return instances
end

function CoreWorldInstanceManager:packages_by_instance(instance)
	local folder = instance.folder
	local package = folder .. "/" .. "world"
	local init_package = folder .. "/" .. "world_init"

	return {
		package = package,
		init_package = init_package
	}
end

function CoreWorldInstanceManager:custom_create_instance(instance_name, custom_data)
	local instance = self:get_instance_data_by_name(instance_name)

	if not instance then
		return
	end

	local continent_data = managers.worlddefinition._continents[instance.continent]
	local package_data = managers.world_instance:packages_by_instance(instance)
	instance.position = custom_data.position or Vector3()
	instance.rotation = custom_data.rotation or Rotation()
	local prepared_unit_data = managers.world_instance:prepare_unit_data(instance, continent_data)

	if prepared_unit_data.statics then
		for _, static in ipairs(prepared_unit_data.statics) do
			local unit = managers.worlddefinition:_create_statics_unit(static, Vector3())

			if Application:editor() then
				managers.editor:layer("Statics"):add_unit_to_created_units(unit)
			end
		end
	end

	if prepared_unit_data.dynamics then
		for _, entry in ipairs(prepared_unit_data.dynamics) do
			local unit = managers.worlddefinition:_create_dynamics_unit(entry, Vector3())

			if Application:editor() then
				managers.editor:layer("Dynamics"):add_unit_to_created_units(unit)
			end
		end
	end

	local prepare_mission_data = self:prepare_mission_data_by_name(instance_name)

	managers.mission:script(instance.script):external_create_instance_elements(prepare_mission_data)
end

function CoreWorldInstanceManager:_get_instance_continent_data(path)
	if Application:editor() then
		return self:_serialize_to_script("continent", path)
	end

	self._instance_continent_data = self._instance_continent_data or {}

	if self._instance_continent_data[path] then
		return deep_clone(self._instance_continent_data[path])
	end

	self._instance_continent_data[path] = self:_serialize_to_script("continent", path)

	return deep_clone(self._instance_continent_data[path])
end

function CoreWorldInstanceManager:prepare_unit_data(instance, continent_data)
	local start_index = instance.start_index
	local folder = instance.folder
	local path = folder .. "/" .. "world"
	local instance_data = self:_get_instance_continent_data(path)

	local function _prepare_entries(entries)
		if not entries then
			return
		end

		for _, entry in ipairs(entries) do
			entry.unit_data.rotation = instance.rotation * entry.unit_data.rotation
			entry.unit_data.position = instance.position + entry.unit_data.position:rotate_with(instance.rotation)
			entry.unit_data.unit_id = continent_data.base_id + self:_get_mod_id(entry.unit_data.unit_id) + self._start_offset_index + start_index
			entry.unit_data.instance = instance.name
			entry.unit_data.continent = instance.continent

			if entry.unit_data.zipline then
				entry.unit_data.zipline.end_pos = instance.position + entry.unit_data.zipline.end_pos:rotate_with(instance.rotation)
			end
		end
	end

	_prepare_entries(instance_data.statics)
	_prepare_entries(instance_data.dynamics)

	return instance_data
end

function CoreWorldInstanceManager:_get_mod_id(id)
	return math.mod(id, 100000)
end

function CoreWorldInstanceManager:prepare_serialized_instance_data(instance)
	local folder = instance.folder
	local path = folder .. "/" .. "world"

	self:_get_instance_mission_data(path)
	self:_get_instance_continent_data(path)
end

function CoreWorldInstanceManager:check_highest_id(instance)
	local folder = instance.folder
	local highest_id = 0
	local amount = 0
	local type_amount = {}

	local function compare(datas)
		if not datas then
			return 0
		end

		local type_amount = 0

		for _, data in ipairs(datas) do
			local mod_id = self:_get_mod_id(data.unit_data.unit_id)
			highest_id = highest_id < mod_id and mod_id or highest_id
			amount = amount + 1
			type_amount = type_amount + 1
		end

		return type_amount
	end

	local path = folder .. "/" .. "world"
	local instance_data = self:_serialize_to_script("continent", path)
	type_amount.statics = compare(instance_data.statics)
	type_amount.dynamics = compare(instance_data.dynamics)
	local path = folder .. "/" .. "mission"
	local instance_data = self:_serialize_to_script("continent", path)
	type_amount.mission = compare(instance_data.mission)

	return highest_id, amount, type_amount
end

function CoreWorldInstanceManager:prepare_mission_data_by_name(name)
	local instance_data = self:get_instance_data_by_name(name)

	if instance_data then
		return self:prepare_mission_data(instance_data)
	end
end

function CoreWorldInstanceManager:_get_instance_mission_data(path)
	if Application:editor() then
		return self:_serialize_to_script("mission", path)
	end

	self._instance_mission_data = self._instance_mission_data or {}

	if self._instance_mission_data[path] then
		return deep_clone(self._instance_mission_data[path])
	end

	self._instance_mission_data[path] = self:_serialize_to_script("mission", path)

	return deep_clone(self._instance_mission_data[path])
end

function CoreWorldInstanceManager:prepare_mission_data(instance)
	local start_index = instance.start_index
	local folder = instance.folder
	local path = folder .. "/" .. "world"
	local instance_data = self:_get_instance_mission_data(path)
	local continent_data = managers.worlddefinition._continents[instance.continent]
	local convert_list = {}

	for script, script_data in pairs(instance_data) do
		for _, element in ipairs(script_data.elements) do
			element.values.instance_name = instance.name
			convert_list[element.id] = continent_data.base_id + self:_get_mod_id(element.id) + self._start_offset_index + start_index
			element.id = convert_list[element.id]

			if element.values.rotation then
				element.values.rotation = instance.rotation * element.values.rotation
			end

			if element.values.position then
				element.values.position = instance.position + element.values.position:rotate_with(instance.rotation)
			end

			if element.class == "ElementSpecialObjective" then
				element.values.search_position = instance.position + element.values.search_position:rotate_with(instance.rotation)
			elseif element.class == "ElementLootBag" then
				if element.values.spawn_dir then
					element.values.spawn_dir = element.values.spawn_dir:rotate_with(instance.rotation)
				end
			elseif element.class == "ElementSpawnGrenade" then
				element.values.spawn_dir = element.values.spawn_dir:rotate_with(instance.rotation)
			elseif element.class == "ElementSpawnUnit" then
				element.values.unit_spawn_dir = element.values.unit_spawn_dir:rotate_with(instance.rotation)
			elseif element.class == "ElementLaserTrigger" then
				for _, point in pairs(element.values.points) do
					point.rot = instance.rotation * point.rot
					point.pos = instance.position + point.pos:rotate_with(instance.rotation)
				end
			end
		end
	end

	for script, script_data in pairs(instance_data) do
		for _, element in ipairs(script_data.elements) do
			self:_convert_table(convert_list, element.values, continent_data, start_index)
		end
	end

	return instance_data
end

function CoreWorldInstanceManager:_convert_table(convert_list, convert_table, continent_data, start_index)
	for key, value in pairs(convert_table) do
		if type_name(value) == "table" then
			self:_convert_table(convert_list, value, continent_data, start_index)
		elseif type_name(value) == "number" then
			if convert_list[value] then
				convert_table[key] = convert_list[value]
			elseif value >= 100000 then
				convert_table[key] = continent_data.base_id + self:_get_mod_id(value) + self._start_offset_index + start_index
			end
		end
	end
end

function CoreWorldInstanceManager:get_mission_inputs_by_name(name)
	local instance_data = self:get_instance_data_by_name(name)

	if instance_data then
		return self:get_mission_inputs(instance_data)
	end
end

function CoreWorldInstanceManager:get_mission_inputs(instance)
	local start_index = instance.start_index
	local folder = instance.folder
	local path = folder .. "/" .. "world"
	local instance_data = self:_serialize_to_script("mission", path)
	local mission_inputs = {}

	for script, script_data in pairs(instance_data) do
		for _, element in ipairs(script_data.elements) do
			if element.class == "ElementInstanceInput" then
				local id = element.id + self._start_offset_index + start_index

				table.insert(mission_inputs, element.values.event)
			end
		end
	end

	table.sort(mission_inputs)

	return mission_inputs
end

function CoreWorldInstanceManager:get_mission_outputs_by_name(name)
	local instance_data = self:get_instance_data_by_name(name)

	if instance_data then
		return self:get_mission_outputs(instance_data)
	end
end

function CoreWorldInstanceManager:get_mission_outputs(instance)
	local start_index = instance.start_index
	local folder = instance.folder
	local path = folder .. "/" .. "world"
	local instance_data = self:_serialize_to_script("mission", path)
	local mission_inputs = {}

	for script, script_data in pairs(instance_data) do
		for _, element in ipairs(script_data.elements) do
			if element.class == "ElementInstanceOutput" then
				local id = element.id + self._start_offset_index + start_index

				table.insert(mission_inputs, tostring(element.values.event))
			end
		end
	end

	table.sort(mission_inputs)

	return mission_inputs
end

function CoreWorldInstanceManager:get_instance_params_by_name(name)
	local instance_data = self:get_instance_data_by_name(name)

	if instance_data then
		return self:get_instance_params(instance_data)
	end
end

function CoreWorldInstanceManager:get_instance_params(instance)
	local folder = instance.folder
	local path = folder .. "/" .. "world"
	local instance_data = self:_serialize_to_script("mission", path)
	local instance_params = {}

	for script, script_data in pairs(instance_data) do
		for _, element in ipairs(script_data.elements) do
			if element.class == "ElementInstanceParams" then
				for _, params in ipairs(element.values.params) do
					table.insert(instance_params, params)
				end
			end
		end
	end

	return instance_params
end

function CoreWorldInstanceManager:_serialize_to_script(type, name)
	if Application:editor() then
		return PackageManager:editor_load_script_data(type:id(), name:id())
	else
		if not PackageManager:has(type:id(), name:id()) then
			Application:throw_exception("Script data file " .. name .. " of type " .. type .. " has not been loaded.")
		end

		return PackageManager:script_data(type:id(), name:id())
	end
end

function CoreWorldInstanceManager:register_input_element(instance_name, instance_input, mission_element)
	self._registered_input_elements[instance_name] = self._registered_input_elements[instance_name] or {}
	self._registered_input_elements[instance_name][instance_input] = self._registered_input_elements[instance_name][instance_input] or {}

	table.insert(self._registered_input_elements[instance_name][instance_input], mission_element)
end

function CoreWorldInstanceManager:get_registered_input_elements(instance_name, instance_input)
	if not self._registered_input_elements[instance_name] then
		return nil
	end

	if not self._registered_input_elements[instance_name][instance_input] then
		return nil
	end

	return self._registered_input_elements[instance_name][instance_input]
end

function CoreWorldInstanceManager:register_output_event_element(instance_name, instance_output, mission_element)
	self._registered_output_event_elements[instance_name] = self._registered_output_event_elements[instance_name] or {}
	self._registered_output_event_elements[instance_name][instance_output] = self._registered_output_event_elements[instance_name][instance_output] or {}

	table.insert(self._registered_output_event_elements[instance_name][instance_output], mission_element)
end

function CoreWorldInstanceManager:get_registered_output_event_elements(instance_name, instance_output)
	if not self._registered_output_event_elements[instance_name] then
		return nil
	end

	if not self._registered_output_event_elements[instance_name][instance_output] then
		return nil
	end

	return self._registered_output_event_elements[instance_name][instance_output]
end

function CoreWorldInstanceManager:set_instance_params(instance_name, params)
	self._instance_params[instance_name] = params
end

function CoreWorldInstanceManager:get_instance_param(instance_name, var_name)
	if not self._instance_params[instance_name] then
		return nil
	end

	return self._instance_params[instance_name][var_name]
end

function CoreWorldInstanceManager:sync_save(data)
	local state = {
		instance_params = self._instance_params
	}
	data.CoreWorldInstanceManager = state
end

function CoreWorldInstanceManager:sync_load(data)
	local state = data.CoreWorldInstanceManager

	if state then
		self._instance_params = state.instance_params
	end
end

function CoreWorldInstanceManager:on_simulation_ended()
	self._registered_input_elements = {}
	self._registered_output_event_elements = {}
	self._instance_params = {}
end

function CoreWorldInstanceManager:clear()
	self._instance_data = {}
end
