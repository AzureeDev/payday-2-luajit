core:module("CoreSequenceManager")
core:import("CoreEngineAccess")
core:import("CoreLinkedStackMap")
core:import("CoreTable")
core:import("CoreUnit")
core:import("CoreClass")

SequenceManager = SequenceManager or class()
SequenceManager.GLOBAL_CORE_SEQUENCE_PATH = "core/settings/core_sequence_manager"
SequenceManager.GLOBAL_SEQUENCE_PATH = "settings/sequence_manager"
SequenceManager.SEQUENCE_FILE_EXTENSION = "sequence_manager"
SequenceManager.IDS_UNIT = Idstring("unit")

function SequenceManager:init(area_damage_mask, target_world_mask, beings_mask)
	self._area_damage_mask = area_damage_mask
	self._target_world_mask = target_world_mask
	self._beings_mask = beings_mask
	self._event_element_class_map = {}

	self:register_event_element_class(AnimationGroupElement)
	self:register_event_element_class(AnimationRedirectElement)
	self:register_event_element_class(AreaDamageElement)
	self:register_event_element_class(AlertElement)
	self:register_event_element_class(AttentionElement)
	self:register_event_element_class(BodyElement)
	self:register_event_element_class(ConstraintElement)
	self:register_event_element_class(DebugElement)
	self:register_event_element_class(DecalMeshElement)
	self:register_event_element_class(EffectElement)
	self:register_event_element_class(EffectSpawnerElement)
	self:register_event_element_class(EnemyKilledElement)
	self:register_event_element_class(FunctionElement)
	self:register_event_element_class(GraphicGroupElement)
	self:register_event_element_class(LightElement)
	self:register_event_element_class(ObjectElement)
	self:register_event_element_class(MaterialConfigElement)
	self:register_event_element_class(MaterialElement)
	self:register_event_element_class(MorphExpressionElement)
	self:register_event_element_class(MorphExpressionMovieElement)
	self:register_event_element_class(PhantomElement)
	self:register_event_element_class(PhysicEffectElement)
	self:register_event_element_class(ProjectDecalElement)
	self:register_event_element_class(RemoveStartTimeElement)
	self:register_event_element_class(RunSequenceElement)
	self:register_event_element_class(RunSpawnSystemSequenceElement)
	self:register_event_element_class(SetDamageElement)
	self:register_event_element_class(SetExtensionVarElement)
	self:register_event_element_class(SetGlobalVariableElement)
	self:register_event_element_class(SetGlobalVariablesElement)
	self:register_event_element_class(SetInflictElement)
	self:register_event_element_class(SetPhysicEffectElement)
	self:register_event_element_class(SetProximityElement)
	self:register_event_element_class(SetSaveDataElement)
	self:register_event_element_class(SpawnSystemUnitEnabledElement)
	self:register_event_element_class(SetVariableElement)
	self:register_event_element_class(SetVariablesElement)
	self:register_event_element_class(SetWaterElement)
	self:register_event_element_class(ShakeCameraElement)
	self:register_event_element_class(SlotElement)

	if SoundDevice:device_info() == "Wwise device" then
		self:register_event_element_class(WwiseElement)
	else
		self:register_event_element_class(SoundElement)
	end

	self:register_event_element_class(SpawnUnitElement)
	self:register_event_element_class(StopEffectElement)
	self:register_event_element_class(StopPhysicEffectElement)
	self:register_event_element_class(TriggerElement)

	self._filter_element_class_map = {}

	self:register_filter_element_class(CheckFilterElement)
	self:register_filter_element_class(SideFilterElement)
	self:register_filter_element_class(ZoneFilterElement)

	self._inflict_element_class_map = {}

	self:register_inflict_element_class(InflictElectricityElement)
	self:register_inflict_element_class(InflictFireElement)

	self._unit_elements = {}
	self._sequence_file_map = {}
	self._start_time_id_element_map = {}
	self._last_startup_callback_id = 0
	self._start_time_callback_list = {}
	self._last_start_time_callback_id = 0
	self._current_start_time_callback_index = 0
	self._retry_callback_list = {}
	self._retry_callback_indices = {}
	self._current_retry_callback_index = 0
	self._callback_map = {}
	self._last_callback_id = 0
	self._inflict_updator_damage_type_map = {
		fire = true
	}
	self._inflict_updator_body_map = {}
	self._inflict_updator_body_count = {}

	for damage_type in pairs(self._inflict_updator_damage_type_map) do
		self._inflict_updator_body_map[damage_type] = {}
		self._inflict_updator_body_count[damage_type] = {}
	end

	self._proximity_masks = {}
	self._collisions_enabled = true
	self._proximity_enabled = true
	self._global_unit_element = nil
	self._global_core_unit_element = nil
	self._area_damage_callback_map = {}
	self._last_area_damage_callback_id = 0
end

function SequenceManager:register_event_element_class(element_class)
	if not self._event_element_class_map[element_class.NAME] then
		self._event_element_class_map[element_class.NAME] = element_class
	else
		Application:error("Unable to register event element class \"" .. tostring(class_name(element_class)) .. "\" since there already exists an element with the same name \"" .. tostring(element_class.NAME) .. "\" in class \"" .. tostring(class_name(self._event_element_class_map[element_class.NAME])) .. "\".")
	end
end

function SequenceManager:get_event_element_class_map()
	return self._event_element_class_map
end

function SequenceManager:register_filter_element_class(element_class)
	if not self._filter_element_class_map[element_class.NAME] then
		self._filter_element_class_map[element_class.NAME] = element_class
	else
		Application:error("Unable to register filter element class \"" .. tostring(class_name(element_class)) .. "\" since there already exists an element with the same name \"" .. tostring(element_class.NAME) .. "\" in class \"" .. tostring(class_name(self._filter_element_class_map[element_class.NAME])) .. "\".")
	end
end

function SequenceManager:get_filter_element_class_map()
	return self._filter_element_class_map
end

function SequenceManager:register_inflict_element_class(element_class)
	if not self._inflict_element_class_map[element_class.NAME] then
		self._inflict_element_class_map[element_class.NAME] = element_class
	else
		Application:error("Unable to register inflict element class \"" .. tostring(class_name(element_class)) .. "\" since there already exists an element with the same name \"" .. tostring(element_class.NAME) .. "\" in class \"" .. tostring(class_name(self._inflict_element_class_map[element_class.NAME])) .. "\".")
	end
end

function SequenceManager:get_inflict_element_class_map()
	return self._inflict_element_class_map
end

function SequenceManager:get_inflict_updator_unit_map(damage_type)
	return self._inflict_updator_body_map[damage_type]
end

function SequenceManager:get_inflict_updator_body_map(damage_type, unit_key)
	local damage_type = self._inflict_updator_body_map[damage_type]

	if damage_type then
		return damage_type[unit_key]
	else
		Application:stack_dump_error("Invalid inflict updator damage type \"" .. tostring(damage_type) .. "\". Valid values: " .. SequenceManager:get_keys_as_string(self._inflict_updator_body_map, "", true, false))
	end
end

function SequenceManager:add_inflict_updator_body(damage_type, unit_key, body_key, body_ext)
	local unit_map = self._inflict_updator_body_map[damage_type]

	if unit_map then
		local body_map = unit_map[unit_key] or {}
		unit_map[unit_key] = body_map

		if not body_map[body_key] then
			local count_map = self._inflict_updator_body_count[damage_type]
			count_map[body_key] = (count_map[body_key] or 0) + 1
		end

		body_map[body_key] = body_ext
	else
		Application:stack_dump_error("Invalid inflict updator damage type \"" .. tostring(damage_type) .. "\". Valid values: " .. SequenceManager:get_keys_as_string(self._inflict_updator_body_map, "", true, false))
	end
end

function SequenceManager:remove_inflict_updator_body(damage_type, unit_key, body_key)
	local unit_map = self._inflict_updator_body_map[damage_type]

	if unit_map then
		local body_map = unit_map[unit_key]

		if body_map and body_map[body_key] then
			body_map[body_key] = nil
			local count_map = self._inflict_updator_body_count[damage_type]
			local count = count_map[body_key] - 1
			count_map[body_key] = count

			if count == 0 then
				unit_map[unit_key] = nil
				count_map[body_key] = nil
			end
		end
	else
		Application:stack_dump_error("Invalid inflict updator damage type \"" .. tostring(damage_type) .. "\". Valid values: " .. SequenceManager:get_keys_as_string(self._inflict_updator_body_map, "", true, false))
	end
end

function SequenceManager:remove_inflict_updator_body_map(damage_type, unit_key)
	local unit_map = self._inflict_updator_body_map[damage_type]

	if unit_map then
		unit_map[unit_key] = nil
	else
		Application:stack_dump_error("Invalid inflict updator damage type \"" .. tostring(damage_type) .. "\". Valid values: " .. SequenceManager:get_keys_as_string(self._inflict_updator_body_map, "", true, false))
	end
end

function SequenceManager:get_global_core_unit_element()
	return self._global_core_unit_element
end

function SequenceManager:get_global_unit_element()
	return self._global_unit_element
end

function SequenceManager:get_global_sequence(sequence_name)
	return self._global_unit_element and self._global_unit_element._sequence_elements[sequence_name] or self._global_core_unit_element and self._global_core_unit_element._sequence_elements[sequence_name]
end

function SequenceManager:get_global_sequence_map()
	return self._global_unit_element and self._global_unit_element._sequence_elements or self._global_core_unit_element and self._global_core_unit_element._sequence_elements or {}
end

function SequenceManager:get_global_filter(filter_name)
	return self._global_unit_element and self._global_unit_element._filters and self._global_unit_element._filters[filter_name] or self._global_core_unit_element and self._global_core_unit_element._filters and self._global_core_unit_element._filters[filter_name]
end

function SequenceManager:set_collisions_enabled(enabled)
	self._collisions_enabled = enabled
end

function SequenceManager:is_collisions_enabled()
	return self._collisions_enabled
end

function SequenceManager:set_proximity_enabled(enabled)
	self._proximity_enabled = enabled
end

function SequenceManager:is_proximity_enabled()
	return self._proximity_enabled
end

function SequenceManager:editor_info(unit_name)
	local unit_element = self:get(unit_name, true)
	local endurance_type_list = {}

	if unit_element then
		local body_element_list = unit_element:get_body_element_list()

		for _, body_element in pairs(body_element_list) do
			local endurance_list = body_element:get_first_endurance_element_list()

			for endurance_type, _ in pairs(endurance_list) do
				endurance_type_list[endurance_type] = (endurance_type_list[endurance_type] or 0) + 1
			end
		end
	end

	return self:get_keys_as_string(endurance_type_list, "[None]", true, false)
end

function SequenceManager:get_proximity_mask(name)
	return self._proximity_masks[name]
end

function SequenceManager:get_proximity_mask_map()
	return self._proximity_masks
end

function SequenceManager:get_keys_as_string(key_value_list, none_string, dot_at_end, only_values)
	local count = 0

	local function func()
		return none_string
	end

	for key, value in pairs(key_value_list) do
		local last_func = func
		local append_string = nil

		if only_values then
			append_string = value
		else
			append_string = key
		end

		function func(count, first)
			if count == 1 then
				if first then
					return append_string .. (dot_at_end and "." or "")
				else
					return append_string
				end
			elseif first then
				return last_func(count - 1, false) .. " and " .. append_string .. (dot_at_end and "." or "")
			else
				return last_func(count - 1, false) .. ", " .. append_string
			end
		end

		count = count + 1
	end

	return func(count, true)
end

function SequenceManager:has(unit_name)
	return self._unit_elements[unit_name:key()] ~= nil
end

function SequenceManager:get(unit_name, ignore_error, create_empty)
	local unit_element = self._unit_elements[unit_name:key()]

	if unit_element == nil then
		if create_empty then
			unit_element = UnitElement:new(nil, unit_name)
			self._unit_elements[unit_name:key()] = unit_element
		elseif not ignore_error then
			Application:throw_exception("The unit \"" .. unit_name:t() .. "\" does not have a \"sequence_manager\" tag within its object xml file.")
		end
	end

	return unit_element
end

function SequenceManager:get_sequence_file(unit_name)
	return self._sequence_file_map[unit_name:key()]
end

function SequenceManager:parse_event(node, unit_element)
	local element_class = self._event_element_class_map[node._meta]

	if element_class ~= nil then
		return element_class:new(node, unit_element)
	elseif node._meta == "xdefine" then
		return nil
	else
		Application:throw_exception("Unit \"" .. tostring(unit_element._name) .. "\" has an invalid element \"" .. tostring(node._meta) .. "\".")
	end
end

function SequenceManager:run_sequence_simple(name, dest_unit, params)
	self:run_sequence_simple2(name, "", dest_unit, params)
end

function SequenceManager:run_sequence_simple2(name, endurance_type, dest_unit, params)
	self:run_sequence_simple3(name, endurance_type, dest_unit, dest_unit, params)
end

function SequenceManager:run_sequence_simple3(name, endurance_type, source_unit, dest_unit, params)
	if alive(dest_unit) then
		self:run_sequence(name, endurance_type, source_unit, dest_unit, nil, math.UP, dest_unit:position(), math.DOWN, 0, Vector3(), params)
	end
end

function SequenceManager:run_sequence(name, endurance_type, source_unit, dest_unit, dest_body, dest_normal, position, direction, damage, velocity, params)
	if alive(dest_unit) then
		local unit_element = self:get(dest_unit:name(), true)

		if unit_element then
			unit_element:run_sequence(name, endurance_type, source_unit, dest_unit, dest_body, dest_normal, position, direction, damage, velocity, params)
		end
	end
end

function SequenceManager:get_body_param(unit_name, body_name, param_name)
	local unit_element = self:get(unit_name, true)

	if unit_element then
		local body_element = unit_element._bodies[body_name]

		return body_element and body_element:get_body_param(param_name)
	else
		return nil
	end
end

function SequenceManager:_register_start_time_callback(id, element, node)
	if not self._is_reloading and self._start_time_id_element_map[id] then
		element:print_error("Element id \"" .. id .. "\" already exists.", false, nil, node)
	end

	self._start_time_id_element_map[id] = element
end

function SequenceManager:_add_start_time_callback(element_id, env, delay, repeat_nr, sequence_name)
	self._last_start_time_callback_id = self._last_start_time_callback_id + 1
	local time_callback = {
		id = self._last_start_time_callback_id,
		element_id = element_id,
		env = env,
		delay = tonumber(delay) or 0
	}
	time_callback.start_time = time_callback.delay
	time_callback.repeat_nr = tonumber(repeat_nr) or 1
	time_callback.sequence_name = sequence_name

	table.insert(self._start_time_callback_list, time_callback)

	return self._last_start_time_callback_id
end

function SequenceManager:_remove_start_time_callback(id)
	for index, time_callback in ipairs(self._start_time_callback_list) do
		if time_callback.id == id then
			if index <= self._current_start_time_callback_index then
				self._current_start_time_callback_index = self._current_start_time_callback_index - 1
			end

			table.remove(self._start_time_callback_list, index)

			return
		end
	end
end

function SequenceManager:add_retry_callback(callback_type, func, try_immediately)
	if not try_immediately or not func() then
		if not self._retry_callback_list[callback_type] then
			self._retry_callback_list[callback_type] = {}
			self._retry_callback_indices[callback_type] = 0
		end

		local index = self._retry_callback_indices[callback_type] - 1

		if index < 1 then
			index = 1
			self._retry_callback_indices[callback_type] = 1
		end

		table.insert(self._retry_callback_list[callback_type], index, func)
	end
end

function SequenceManager:add_callback(func)
	self._last_callback_id = self._last_callback_id + 1
	self._callback_map[self._last_callback_id] = func

	return self._last_callback_id
end

function SequenceManager:remove_callback(id)
	self._remove_callback_map = self._remove_callback_map or {}
	self._remove_callback_map[id] = true
end

function SequenceManager:add_startup_callback(func)
	self._last_startup_callback_id = self._last_startup_callback_id + 1
	self._startup_callback_map = self._startup_callback_map or {}
	self._startup_callback_map[self._last_startup_callback_id] = func

	return self._last_startup_callback_id
end

function SequenceManager:remove_startup_callback(id)
	if self._startup_callback_map then
		self._startup_callback_map[id] = nil
	end
end

function SequenceManager:update(t, dt)
	self:update_startup_callbacks()
	self:update_start_time_callbacks(dt)
	self:update_retry_callbacks()
	self:update_callbacks(t, dt)
end

function SequenceManager:update_startup_callbacks()
	if self._startup_callback_map then
		local startup_callback_map_copy = self._startup_callback_map
		self._startup_callback_map = nil

		for _, func in pairs(startup_callback_map_copy) do
			func()
		end
	end
end

function SequenceManager:update_start_time_callbacks(dt)
	self._current_start_time_callback_index = 1
	local time_callback = self._start_time_callback_list[self._current_start_time_callback_index]

	while time_callback do
		time_callback.start_time = time_callback.start_time - dt

		if time_callback.start_time <= 0 then
			local is_repeat = nil
			local env = time_callback.env

			if env then
				if time_callback.is_corrupt then
					Application:error("Failed to load a time callback in SequenceManager. " .. self:get_time_callback_info(time_callback))
				else
					is_repeat = time_callback.repeat_nr > 1

					if is_repeat and time_callback.params then
						if not time_callback.env_params_copy then
							time_callback.env_params_copy = table.map_copy(time_callback.params)
						elseif time_callback.repeat_nr > 2 then
							env.params = table.map_copy(time_callback.env_params_copy)
						else
							env.params = time_callback.env_params_copy
						end
					end

					if time_callback.sequence_name then
						if alive(env.dest_unit) then
							self:run_sequence(time_callback.sequence_name, "trigger", env.src_unit, env.dest_unit, nil, env.dest_normal, env.pos, env.dir, env.damage, env.velocity, env.params)
						else
							is_repeat = false
						end
					else
						local element = self._start_time_id_element_map[time_callback.element_id]

						if not element then
							Application:error("Different version of the game saved than the one that loaded. " .. self:get_time_callback_info(time_callback))

							is_repeat = false
						else
							element:start_time_callback(time_callback.env)
						end
					end
				end
			end

			if is_repeat then
				time_callback.start_time = time_callback.delay
				time_callback.repeat_nr = time_callback.repeat_nr - 1
			else
				table.remove(self._start_time_callback_list, self._current_start_time_callback_index)

				self._current_start_time_callback_index = self._current_start_time_callback_index - 1
			end
		end

		self._current_start_time_callback_index = self._current_start_time_callback_index + 1
		time_callback = self._start_time_callback_list[self._current_start_time_callback_index]
	end

	self._current_start_time_callback_index = 0
end

function SequenceManager:get_time_callback_info(time_callback)
	if time_callback.element_id then
		return "Element: " .. tostring(time_callback.element_id) .. ", Unit: " .. tostring(time_callback.env and time_callback.env.dest_unit)
	else
		return "Sequence: " .. tostring(time_callback.sequence_name) .. ", Unit: " .. tostring(time_callback.env and time_callback.env.dest_unit)
	end
end

function SequenceManager:update_retry_callbacks()
	if next(self._retry_callback_list) then
		local remove_retry_callback_map = nil

		for callback_type, list in pairs(self._retry_callback_list) do
			if not next(self._retry_callback_list[callback_type]) then
				remove_retry_callback_map = remove_retry_callback_map or {}

				table.insert(remove_retry_callback_map, callback_type)
			else
				local retry_func = self._retry_callback_list[callback_type][self._retry_callback_indices[callback_type]]

				if retry_func() then
					table.remove(self._retry_callback_list[callback_type], self._retry_callback_indices[callback_type])

					self._retry_callback_indices[callback_type] = self._retry_callback_indices[callback_type] - 1
				end

				self._retry_callback_indices[callback_type] = self._retry_callback_indices[callback_type] + 1

				if self._retry_callback_indices[callback_type] > #self._retry_callback_list[callback_type] then
					self._retry_callback_indices[callback_type] = 1
				end
			end
		end

		if remove_retry_callback_map then
			for _, callback_type in pairs(remove_retry_callback_map) do
				if not next(self._retry_callback_list[callback_type]) then
					self._retry_callback_list[callback_type] = nil
					self._retry_callback_indices[callback_type] = nil
				end
			end
		end
	end
end

function SequenceManager:update_callbacks(t, dt)
	if next(self._callback_map) then
		if self._remove_callback_map then
			for id in pairs(self._remove_callback_map) do
				self._callback_map[id] = nil
			end

			self._remove_callback_map = nil
		end

		for id, func in pairs(self._callback_map) do
			if not self._remove_callback_map or not self._remove_callback_map[id] then
				func(t, dt)
			end
		end
	end
end

function SequenceManager:_serialize_to_script(type, name)
	if Application:editor() then
		return PackageManager:editor_load_script_data(type:id(), name)
	else
		return PackageManager:script_data(type:id(), name)
	end
end

function SequenceManager:_add_sequences_from_unit_data(unit_data)
	local unit_name = unit_data:name()
	local unit_name_key = unit_name:key()

	if self._sequence_file_map[unit_name_key] then
		return
	end

	local seq_manager_filename = unit_data:sequence_manager_filename()

	if seq_manager_filename then
		for key, file in pairs(self._sequence_file_map) do
			if file == seq_manager_filename then
				self._sequence_file_map[unit_name_key] = seq_manager_filename
				self._unit_elements[unit_name_key] = self._unit_elements[key]

				return
			end
		end

		if DB:has(self.SEQUENCE_FILE_EXTENSION, seq_manager_filename) then
			self._sequence_file_map[unit_name_key] = seq_manager_filename
			manager_node = self:_serialize_to_script(self.SEQUENCE_FILE_EXTENSION:id(), seq_manager_filename)
		elseif Application:production_build() then
			Application:error("Unit \"" .. unit_name:t() .. "\" refers to the external sequence manager file \"" .. seq_manager_filename:t() .. "." .. self.SEQUENCE_FILE_EXTENSION .. "\", but it doesn't exist.")
		else
			Application:error("Unit \"" .. tostring(unit_name) .. "\" refers to the external sequence manager file \"" .. tostring(seq_manager_filename) .. "\", but it doesn't exist.")
		end

		if manager_node then
			for _, data in ipairs(manager_node) do
				if data._meta == "unit" then
					if self._unit_elements[unit_name_key] then
						if Application:production_build() then
							Application:throw_exception("Unit \"" .. unit_name:t() .. "\" has duplicate <unit/>-elements in the external sequence manager file \"" .. seq_manager_filename:t() .. "." .. self.SEQUENCE_FILE_EXTENSION .. "\".")
						else
							Application:error("Unit \"" .. tostring(unit_name) .. "\" has duplicate <unit/>-elements in the external sequence manager file \"" .. tostring(seq_manager_filename) .. "\".")
						end
					else
						self._unit_elements[unit_name_key] = UnitElement:new(data, unit_name)
					end
				end
			end
		end
	end
end

function SequenceManager:preload()
	for _, unit_data in pairs(PackageManager:all_loaded_unit_data()) do
		self:_add_sequences_from_unit_data(unit_data)
	end
end

function SequenceManager:clbk_pkg_manager_unit_loaded(type, unit_name)
	self:_add_sequences_from_unit_data(PackageManager:unit_data(unit_name))
end

function SequenceManager:reload(unit_name, sequences_only)
	if self:remove(unit_name) then
		if not sequences_only then
			CoreEngineAccess._editor_reload(self.IDS_UNIT, unit_name:id())
			Application:reload_material_config(PackageManager:unit_data(unit_name:id()):material_config():id())
		end

		local unit_data = PackageManager:unit_data(unit_name)
		local sequence_file = unit_data:sequence_manager_filename()

		if sequence_file then
			PackageManager:reload(self.SEQUENCE_FILE_EXTENSION:id(), sequence_file)
		end

		self._is_reloading = true

		self:_add_sequences_from_unit_data(unit_data)

		self._is_reloading = nil
	end
end

function SequenceManager:reload_all()
	local old_unit_element_map = self._unit_elements

	self:clear()

	for _, unit_element in pairs(old_unit_element_map) do
		CoreEngineAccess._editor_reload(self.IDS_UNIT, unit_element:get_name():id())
	end

	self:preload()
end

function SequenceManager:clear()
	self:internal_load()

	self._unit_elements = {}
	self._sequence_file_map = {}
	self._start_time_id_element_map = {}
end

function SequenceManager:remove(unit_name)
	local unit_name_key = unit_name:key()
	local unit_element = self._unit_elements[unit_name_key]
	self._unit_elements[unit_name_key] = nil
	self._sequence_file_map[unit_name_key] = nil

	return unit_element ~= nil
end

function SequenceManager:verify_material_configs(skip_unit_map, processed_unit_map, processed_unit_list)
	local index_file = DB:open("index", "indices/types/unit")
	local unit_list_string = index_file:read()
	local unit_list = string.split(unit_list_string, "[\r\n]")
	local unit_id = Idstring("unit")
	local assets_path = Application:base_path() .. "../../assets/"

	if managers.debug then
		assets_path = managers.debug.macro:get_cleaned_path(assets_path) or assets_path
	end

	cat_print("debug", "Verifying " .. #unit_list .. " units...")

	local printed_progress = 0

	for index, unit_name in ipairs(unit_list) do
		local progress = math.floor(100 * index / #unit_list)

		if printed_progress < progress then
			cat_print("debug", "Progress " .. progress .. "% (" .. index .. "/" .. #unit_list .. ")")

			printed_progress = progress
		end

		if not skip_unit_map or not skip_unit_map[unit_name] then
			if processed_unit_map then
				processed_unit_map[unit_name] = true
			end

			if processed_unit_list then
				table.insert(processed_unit_list, unit_name)
			end

			local unit_xml = DB:open("unit", unit_name):read()
			local unit_data = ScriptSerializer:from_custom_xml(unit_xml)

			if unit_data.object and unit_data.object.file then
				local object_xml = DB:open("object", unit_data.object.file):read()
				local object_data = ScriptSerializer:from_custom_xml(object_xml)

				if object_data.sequence_manager and object_data.sequence_manager.file then
					if not DB:has("sequence_manager", object_data.sequence_manager.file) then
						cat_print("debug", "Unit \"" .. assets_path .. unit_name .. ".unit\" specified an non-existing sequence file \"" .. assets_path .. object_data.sequence_manager.file .. ".sequence_manager\".")
					elseif not object_data.diesel or not object_data.diesel.materials then
						cat_print("debug", "Unit \"" .. assets_path .. unit_name .. ".unit\" lacks material config in its object file \"" .. assets_path .. unit_data.object.file .. ".object\".")
					else
						local sequence_binary = DB:open("sequence_manager", object_data.sequence_manager.file):read()
						local sequence_data = ScriptSerializer:from_binary(sequence_binary)
						local material_xml = DB:open("material_config", object_data.diesel.materials):read()
						local material_data = ScriptSerializer:from_custom_xml(material_xml)
						local material_config_map = {}

						self:_verify_material_configs(sequence_data, material_config_map, material_data.group, object_data.sequence_manager.file)

						if next(material_config_map) then
							if not material_data.group then
								cat_print("debug", "Unit \"" .. assets_path .. unit_name .. ".unit\" material config lacks a group attribute.")
							else
								for material_config, material_group in pairs(material_config_map) do
									cat_print("debug", "Unit \"" .. assets_path .. unit_name .. ".unit\" can switch to material config \"" .. assets_path .. material_config .. ".material_config\" but it lacks the group \"" .. material_data.group .. "\" (it was \"" .. material_group .. "\").")
								end
							end
						end
					end
				end
			end
		end
	end

	cat_print("debug", "Done")
end

function SequenceManager:_verify_material_configs(data, material_config_map, material_group, sequence_file_name)
	for _, sub_data in ipairs(data) do
		if sub_data._meta == "material_config" then
			local name_func, error_msg = loadstring("return " .. tostring(sub_data.name))

			if name_func then
				setfenv(name_func, SequenceEnvironment)

				local material_config_path = name_func()

				if not material_config_path or not material_config_map[material_config_path] then
					if material_config_path and DB:has("material_config", material_config_path) then
						local material_xml = DB:open("material_config", material_config_path):read()
						local material_data = ScriptSerializer:from_custom_xml(material_xml)

						if material_data.group ~= material_group then
							material_config_map[material_config_path] = material_data.group or ""
						end
					else
						cat_print("debug", "Invalid material_config attribute \"" .. tostring(material_config_path) .. "\" in \"" .. sequence_file_name .. "\".")
					end
				end
			else
				cat_print("debug", "Failed to read material_config attribute in \"" .. sequence_file_name .. "\". Error message: " .. tostring(error_msg))
			end
		else
			self:_verify_material_configs(sub_data, material_config_map, material_group, sequence_file_name)
		end
	end
end

function SequenceManager:test_unit_by_name(unit_name, pos, rot)
	local pos = pos or Vector3(math.random(-5000, 5000), math.random(-5000, 5000), math.random(-5000, 5000))
	local rot = rot or Rotation()
	local unit = CoreUnit.safe_spawn_unit(unit_name, pos, rot)

	self:test_unit_variations(unit)

	if alive(unit) then
		unit:set_slot(0)
	end

	unit = CoreUnit.safe_spawn_unit(unit_name, pos, rot)

	self:test_unit_damage(unit)

	if alive(unit) then
		unit:set_slot(0)
	end
end

function SequenceManager:test_unit_variations(unit)
	if alive(unit) and unit:damage() then
		local unit_element = self._unit_elements[unit:name():key()]
		local variation_list = unit_element:get_parameter_sequence_name_list("editable_state", true)

		if #variation_list > 0 then
			local reset_variation_list = unit_element:get_parameter_sequence_name_list("reset_editable_state", true)

			if #reset_variation_list == 0 then
				Application:error("Unit had " .. #variation_list .. " sequences with the attribute \"editable_state\" set to true but no sequence with the attribute \"reset_editable_state\" set to true.")
			elseif #reset_variation_list > 1 then
				Application:error("Too many sequences with the attribute \"reset_editable_state\". Found " .. #reset_variation_list .. ", should only be 1.")
			end

			local param_list = {
				"change_state",
				unit,
				unit,
				nil,
				math.UP,
				unit:position(),
				math.DOWN,
				0,
				Vector3()
			}

			for _, name in ipairs(variation_list) do
				unit_element:run_sequence(name, unpack(param_list))

				if #reset_variation_list > 0 then
					unit_element:run_sequence(reset_variation_list[1], unpack(param_list))
				end
			end
		end
	end
end

function SequenceManager:test_unit_damage(unit)
	if alive(unit) and unit:damage() then
		local unit_element = self._unit_elements[unit:name():key()]

		for body_name, body_element in pairs(unit_element._bodies) do
			if alive(unit) then
				for endurance_type, endurance in pairs(body_element._first_endurance) do
					local body = unit:body(body_name)

					if alive(body) then
						cat_debug("debug", "-Damaging endurance_type: " .. endurance_type .. ", on body:" .. body_name)

						local func = body:extension().damage["damage_" .. endurance_type]

						if func then
							local damage = 0.5

							for i = 1, 10 do
								func(body:extension().damage, unit, Vector3(0, 0, 1), body:position(), Vector3(0, 0, -1), damage, Vector3(0, 0, 10000))

								damage = damage * 2
							end
						else
							Application:error("Invalid endurance_type \"" .. endurance_type .. "\"!")
						end
					end
				end
			else
				break
			end
		end
	end
end

function SequenceManager:load_element_data(unit, element_name, data)
	self._event_element_class_map[element_name].load(unit, data)
end

function SequenceManager:save(data)
	local state = {}
	local changed = self:save_global_save_data(state)
	local unit_element_map = {}

	for _, unit_element in pairs(self._unit_elements) do
		changed = unit_element:save(unit_element_map) or changed
	end

	if changed then
		state.unit_element_map = unit_element_map
	end

	if self._last_start_time_callback_id ~= 0 then
		state.last_start_time_callback_id = self._last_start_time_callback_id
		changed = true
	end

	if next(self._start_time_callback_list) then
		local start_time_callback_list = self:safe_save_map(self._start_time_callback_list)

		for index = #start_time_callback_list, 1, -1 do
			local time_callback = start_time_callback_list[index]

			if not time_callback.env.dest_unit then
				table.remove(start_time_callback_list, index)
			end
		end

		if next(start_time_callback_list) then
			state.start_time_callback_list = start_time_callback_list
			changed = true
		end
	end

	if changed then
		data.CoreSequenceManager = state
	end
end

function SequenceManager:load(data)
	local state = data.CoreSequenceManager
	SequenceEnvironment.g_save_data = {}
	self._start_time_callback_list = {}
	self._last_start_time_callback_id = 0

	if state then
		if state.unit_element_map then
			for unit_name, _ in pairs(state.unit_element_map) do
				local unit_element = self:get(unit_name, true)

				if unit_element then
					unit_element:load(state)
				end
			end
		end

		self:load_global_save_data(state)

		if state.last_start_time_callback_id then
			self._last_start_time_callback_id = state.last_start_time_callback_id
		end

		if state.start_time_callback_list then
			for _, time_callback in ipairs(state.start_time_callback_list) do
				table.insert(self._start_time_callback_list, self:safe_load_map(time_callback))
			end
		end
	end
end

function SequenceManager:save_global_save_data(data)
	if next(SequenceEnvironment.g_save_data) then
		local state = {
			g_save_data = table.map_copy(SequenceEnvironment.g_save_data)
		}
		data.SequenceEnvironment = state

		return true
	else
		return false
	end
end

function SequenceManager:load_global_save_data(data)
	local state = data.SequenceEnvironment

	if state then
		SequenceEnvironment.g_save_data = table.map_copy(state.g_save_data)
	end
end

function SequenceManager:safe_save_map(map)
	return self:_safe_save_map(map, {})
end

function SequenceManager:_safe_save_map(map, visited_map)
	local state = {}

	if visited_map[map] then
		return visited_map[map]
	end

	visited_map[map] = state

	for key, value in pairs(map) do
		local value_type = type(value)

		if value_type == "userdata" then
			local type_name = CoreClass.type_name(value)

			if type_name == "Unit" then
				if alive(value) then
					local id = value:editor_id()

					if id > 0 then
						value = {
							__is_unit = true,
							id = id
						}
					else
						value = nil
					end
				else
					value = nil
				end
			elseif type_name ~= "Vector3" and type_name ~= "Rotation" and type_name ~= "Idstring" then
				value = nil
			end
		elseif value_type == "table" then
			local is_sequence_env = getmetatable(value) == SequenceEnvironment
			value = self:_safe_save_map(value, visited_map)

			if is_sequence_env then
				value.__is_sequence_env = true
			end
		end

		state[key] = value
	end

	return state
end

function SequenceManager:safe_load_map(data_map)
	data_map = table.deep_map_copy(data_map)
	local wait_unit_load_map = {}
	local done_callback_func = callback(self, self, "_safe_load_map_done", data_map)
	data_map.is_corrupt = true

	self:_safe_load_map(data_map, wait_unit_load_map, done_callback_func, {})

	if not next(wait_unit_load_map) then
		done_callback_func()
	end

	return data_map
end

function SequenceManager:_safe_load_map_done(data_map)
	local env = data_map.env

	if env and type(env) == "table" and env.__is_sequence_env then
		if alive(env.dest_unit) then
			local unit_name = env.dest_unit:name()
			local unit_element = self._unit_elements[unit_name:key()]

			if unit_element then
				data_map.env = SequenceEnvironment:new(env.damage_type, env.src_unit, env.dest_unit, env.dest_body, env.dest_normal, env.pos, env.dir, env.damage, env.velocity, env.params, unit_element, env.dest_unit:damage())
				data_map.is_corrupt = nil
			else
				data_map.env = nil

				Application:stack_dump_error("Unit \"" .. tostring(unit_name) .. "\" doesn't exists.\n")

				return false
			end
		else
			data_map.env = nil

			return false
		end
	else
		data_map.is_corrupt = nil
	end
end

function SequenceManager:_safe_load_map(state, wait_unit_load_map, done_callback_func, visited_map)
	if visited_map[state] then
		return
	end

	visited_map[state] = true

	for key, value in pairs(state) do
		if type(value) == "table" then
			if value.__is_unit then
				local id = value.id
				local data = {
					id = id,
					state = state,
					key = key,
					wait_unit_load_map = wait_unit_load_map,
					done_callback_func = done_callback_func
				}
				wait_unit_load_map[id] = (wait_unit_load_map[id] or 0) + 1
				local unit = managers.worlddefinition:get_unit_on_load(id, callback(self, self, "_on_load_unit_done_callback", data))

				if unit ~= nil then
					state[key] = unit

					self:_count_down_wait_unit_load_map(wait_unit_load_map, id)
				end
			else
				self:_safe_load_map(value, wait_unit_load_map, done_callback_func, visited_map)
			end
		end
	end
end

function SequenceManager:_on_load_unit_done_callback(data, unit)
	data.state[data.key] = unit

	self:_count_down_wait_unit_load_map(data.wait_unit_load_map, data.id)

	if not next(data.wait_unit_load_map) then
		data.done_callback_func()
	end
end

function SequenceManager:_count_down_wait_unit_load_map(wait_unit_load_map, id)
	wait_unit_load_map[id] = wait_unit_load_map[id] - 1

	if wait_unit_load_map[id] <= 0 then
		wait_unit_load_map[id] = nil
	end
end

function SequenceManager:internal_load()
	if DB:has(self.SEQUENCE_FILE_EXTENSION, self.GLOBAL_CORE_SEQUENCE_PATH) then
		local core_data = PackageManager:script_data(self.SEQUENCE_FILE_EXTENSION:id(), self.GLOBAL_CORE_SEQUENCE_PATH:id())

		if core_data and core_data._meta == "sequence_manager" then
			SequenceEnvironment:init_static_env()

			self._global_core_unit_element = UnitElement:new(core_data, "[Global core sequence]", true)
			self._global_core_unit_element.get_sequence_element = managers.sequence.get_global_sequence
		end
	end

	if DB:has(self.SEQUENCE_FILE_EXTENSION, self.GLOBAL_SEQUENCE_PATH) then
		local data = PackageManager:script_data(self.SEQUENCE_FILE_EXTENSION:id(), self.GLOBAL_SEQUENCE_PATH:id())

		if data and data._meta == "sequence_manager" then
			SequenceEnvironment:init_static_env()

			self._global_unit_element = UnitElement:new(data, "[Global sequence]", true)
		end
	end

	SequenceEnvironment:init_static_env()
end

function SequenceManager:add_area_damage_callback(func)
	self._last_area_damage_callback_id = self._last_area_damage_callback_id + 1
	self._area_damage_callback_map[self._last_area_damage_callback_id] = func

	return self._last_area_damage_callback_id
end

function SequenceManager:remove_area_damage_callback(id)
	self._area_damage_callback_map[id] = nil
end

function SequenceManager:do_area_damage(damage_type, attack_unit, pos, range, constant_damage, damage, physic_effect, mass, ignore_unit, direct_attack_unit, ignore_mask, get_damage_func, velocity)
	local checked_unit_map = {}
	local damaged_prop_map = {}
	local killed_prop_map = {}
	local hit_prop_map = {}
	local damaged_being_map = {}
	local killed_being_map = {}
	local hit_being_map = {}
	local ray_caller, ignore_unit_key = nil

	if alive(ignore_unit) then
		ray_caller = attack_unit
		ignore_unit_key = ignore_unit:key()
	else
		ignore_unit = attack_unit
		ray_caller = World
	end

	local body_sphere = attack_unit:find_bodies("intersect", "sphere", pos, range, self._area_damage_mask - ignore_mask)

	for _, body in ipairs(body_sphere) do
		local unit = alive(body) and body:unit()
		local unit_key = unit and unit:key()

		if unit and unit_key ~= ignore_unit_key then
			local body_extension = body:extension()
			body_extension = body_extension and body_extension.damage

			if body_extension then
				local hit_pos = body:center_of_mass()
				local dir = (hit_pos - pos):normalized()
				local unit_extension = unit:damage()
				local body_damage = nil

				if get_damage_func then
					body_damage = get_damage_func(unit, body, dir, hit_pos, damage_type, attack_unit, pos, range, constant_damage, damage, velocity, ignore_unit, direct_attack_unit, ignore_mask)
				elseif constant_damage then
					body_damage = damage
				else
					body_damage = damage * (1 - math.clamp(get_distance_to_body(body, pos) / range, 0, 1))
				end

				self:do_area_damage_on_body(unit, body, body_extension, damage_type, attack_unit, -dir, pos, dir, body_damage, velocity, ignore_unit, direct_attack_unit)

				if not checked_unit_map[unit_key] then
					local dead, damage = self:do_area_damage_on_unit(unit, body, unit_extension, damage_type, attack_unit, -dir, pos, dir, body_damage, velocity, velocity, ignore_unit, direct_attack_unit)
					hit_prop_map[unit_key] = unit

					if damage then
						if type(damage) ~= "number" then
							Application:error("Unit \"" .. tostring(unit:name()) .. "\" has an invalid damage extension \"" .. tostring(class_name(getmetatable(unit_extension))) .. "\", its \"damage_" .. tostring(damage_type) .. "\"-function returned the invalid values \"" .. tostring(dead) .. ", " .. tostring(damage) .. "\". Should be \"dead, damage\".\nTHIS WILL CRASH SOON, SO FIX IT!\n")
						elseif damage > 0 then
							damaged_prop_map[unit_key] = unit

							if dead then
								killed_prop_map[unit_key] = unit
							end
						end
					end

					checked_unit_map[unit_key] = true
				end
			end
		end
	end

	local unit_sphere = attack_unit:find_units("sphere", pos, range, self._beings_mask - ignore_mask)

	for _, unit in ipairs(unit_sphere) do
		local unit_key = alive(unit) and unit:key()
		local unit_extension = unit_key and unit:damage()

		if unit_key and unit_key ~= ignore_unit_key and not checked_unit_map[unit_key] and unit_extension then
			local hit, hit_pos = self:is_hit_by_area_damage(unit, pos, ray_caller, ignore_unit)

			if hit then
				local dir = (unit:position() - pos):normalized()
				local unit_damage = nil

				if get_damage_func then
					unit_damage = get_damage_func(unit, nil, dir, hit_pos, damage_type, attack_unit, pos, range, constant_damage, damage, velocity, ignore_unit, direct_attack_unit, ignore_mask)
				elseif constant_damage then
					unit_damage = damage
				else
					unit_damage = damage * (1 - math.clamp((hit_pos - pos):length() / range, 0, 1))
				end

				local dead, damage = self:do_area_damage_on_unit(unit, nil, unit_extension, damage_type, attack_unit, -dir, pos, dir, unit_damage, velocity, ignore_unit, direct_attack_unit)
				hit_being_map[unit_key] = unit

				if damage then
					if type(damage) ~= "number" then
						Application:error("Unit \"" .. tostring(unit:name()) .. "\" has an invalid damage extension \"" .. tostring(class_name(getmetatable(unit_extension))) .. "\", its \"damage_" .. tostring(damage_type) .. "\"-function returned the invalid values \"" .. tostring(dead) .. ", " .. tostring(damage) .. "\". Should be \"dead, damage\".\nTHIS WILL CRASH SOON, SO FIX IT!\n")
					elseif damage > 0 then
						damaged_being_map[unit_key] = unit

						if dead then
							killed_being_map[unit_key] = unit
						end
					end
				end
			end
		end
	end

	if physic_effect then
		if mass then
			World:play_physic_effect(physic_effect, pos, range, mass)
		else
			World:play_physic_effect(physic_effect, pos, range)
		end
	end

	for id, func in pairs(self._area_damage_callback_map) do
		func(id, killed_being_map, damaged_being_map, killed_prop_map, damaged_prop_map, hit_being_map, hit_prop_map)
	end

	return killed_being_map, damaged_being_map, killed_prop_map, damaged_prop_map, hit_being_map, hit_prop_map
end

function SequenceManager:do_area_damage_on_body(unit, body, body_extension, damage_type, attack_unit, normal, pos, dir, body_damage, velocity, ignore_unit, direct_attack_unit)
	return body_extension:damage_by_area(damage_type, attack_unit, normal, pos, dir, body_damage, velocity or Vector3())
end

function SequenceManager:do_area_damage_on_unit(unit, body, unit_extension, damage_type, attack_unit, normal, pos, dir, body_damage, velocity, ignore_unit, direct_attack_unit)
	unit_extension:set_direct_attack_unit(direct_attack_unit)

	local return_param_list = {
		unit_extension:damage_by_area(damage_type, attack_unit, body, normal, pos, dir, body_damage, velocity or Vector3())
	}

	unit_extension:set_direct_attack_unit(nil)

	return unpack(return_param_list)
end

function SequenceManager:is_hit_by_area_damage(dest_unit, position, ray_caller, ignore_unit)
	local ray = nil
	local had_target_object = false

	if dest_unit:unit_data() and dest_unit:unit_data().target_objects then
		for _, obj in pairs(dest_unit:unit_data().target_objects) do
			had_target_object = true
			ray = ray_caller:raycast("ray", obj:position(), position, "slot_mask", self._target_world_mask, "ignore_unit", {
				dest_unit,
				ignore_unit
			})

			if not ray then
				return true, obj:position()
			end
		end
	end

	if not had_target_object then
		ray = ray_caller:raycast("ray", dest_unit:position(), position, "slot_mask", self._target_world_mask, "ignore_unit", {
			dest_unit,
			ignore_unit
		})

		if not ray then
			return true, dest_unit:position()
		end
	end

	return false
end

function SequenceManager:get_editable_state_sequence_list(unit_name)
	return self:get_sequence_list(unit_name, "editable_state", true)
end

function SequenceManager:get_reset_editable_state_sequence_list(unit_name)
	return self:get_sequence_list(unit_name, "reset_editable_state", true)
end

function SequenceManager:get_triggable_sequence_list(unit_name)
	return self:get_sequence_list(unit_name, "triggable", true)
end

function SequenceManager:get_trigger_list(unit_name)
	local unit_element = self:get(unit_name, true)

	if unit_element then
		return unit_element:get_trigger_name_list()
	else
		return {}
	end
end

function SequenceManager:get_trigger_map(unit_name)
	local unit_element = self:get(unit_name, true)

	if unit_element then
		return unit_element:get_trigger_name_map()
	else
		return {}
	end
end

function SequenceManager:get_sequence_list(unit_name, property_name, property_value)
	local sequence_list = {}
	local unit_element = self:get(unit_name, true)

	if unit_element then
		if property_name then
			sequence_list = unit_element:get_parameter_sequence_name_list(property_name, property_value)
		else
			sequence_list = unit_element:get_sequence_name_list()
		end
	end

	return sequence_list
end

function SequenceManager:has_sequence_name(unit_name, sequence_name, ignore_error)
	local unit_element = self:get(unit_name, ignore_error)

	if unit_element then
		return unit_element:has_sequence_name(sequence_name)
	end

	return false
end

function SequenceManager:get_unit_count()
	local count = 0

	for _ in pairs(self._unit_elements) do
		count = count + 1
	end

	return count
end

function SequenceManager.set_effect_spawner_enabled(effect_spawner, enabled)
	if enabled then
		effect_spawner:activate()
	else
		local id = effect_spawner:effect_id()

		if id ~= -1 then
			effect_spawner:kill_effect()
		else
			return false
		end
	end

	return true
end

SequenceEnvironment = SequenceEnvironment or class()
SequenceEnvironment.self = SequenceEnvironment.self or {}
SequenceEnvironment.g_save_data = SequenceEnvironment.g_save_data or {}
SequenceEnvironment.str = tostring
SequenceEnvironment.nr = tonumber
SequenceEnvironment.v = Vector3
SequenceEnvironment.rot = Rotation
SequenceEnvironment.print = callback(nil, _G, "cat_print", "sequence")
SequenceEnvironment.alive = alive
SequenceEnvironment.clamp = math.clamp
SequenceEnvironment.rand = math.random
SequenceEnvironment.abs = math.abs
SequenceEnvironment.string = string
SequenceEnvironment.stack_dump = Application.stack_dump
SequenceEnvironment.Idstring = Idstring

function SequenceEnvironment:init(endurance_type, source_unit, dest_unit, dest_body, dest_normal, position, direction, damage, velocity, params, unit_element, damage_ext)
	self.damage_type = endurance_type
	self.src_unit = source_unit
	self.dest_body = dest_body
	self.dest_normal = dest_normal
	self.pos = position
	self.dir = direction
	self.damage = damage
	self.velocity = velocity
	self.g_vars = unit_element._global_vars
	self.params = params or {}
	self.__run_params = CoreTable.clone(self.params)
	self.dest_unit = dest_unit
	local ext = damage_ext or dest_unit:damage()

	if ext then
		self.vars = ext._variables
	else
		SequenceEnvironment.self = self
		SequenceEnvironment.element = unit_element

		self:print_vars()
		Application:error("Unit doesn't have a damage extension.")
	end
end

function SequenceEnvironment:init_static_env()
	self.damage_type = "init"
	self.src_unit = nil
	self.dest_body = nil
	self.dest_normal = Vector3(0, 0, 1)
	self.pos = Vector3()
	self.dir = Vector3(0, 0, -1)
	self.damage = 0
	self.velocity = Vector3()
	local global_core_unit_element = managers.sequence:get_global_core_unit_element()

	if global_core_unit_element then
		self.g_vars = table.map_copy(global_core_unit_element:get_global_set_var_map() or {})
		self.vars = table.map_copy(global_core_unit_element:get_set_var_map() or {})
	end

	local global_unit_element = managers.sequence:get_global_unit_element()

	if global_unit_element then
		self.g_vars = table.map_copy(global_unit_element:get_global_set_var_map() or {})
		self.vars = table.map_copy(global_unit_element:get_set_var_map() or {})
	end

	self.params = {}
	self.__run_params = CoreTable.clone(self.params)
	self.dest_unit = nil
end

function SequenceEnvironment.src_unit_pos()
	return SequenceEnvironment.self.src_unit:position()
end

function SequenceEnvironment.src_unit_rot()
	return SequenceEnvironment.self.src_unit:rotation()
end

function SequenceEnvironment.dest_unit_pos()
	return SequenceEnvironment.self.dest_unit:position()
end

function SequenceEnvironment.dest_unit_rot()
	return SequenceEnvironment.self.dest_unit:rotation()
end

function SequenceEnvironment.dest_body_pos()
	return SequenceEnvironment.self.dest_body:position()
end

function SequenceEnvironment.dest_body_rot()
	return SequenceEnvironment.self.dest_body:rotation()
end

function SequenceEnvironment.object(object_name)
	return object_name and SequenceEnvironment.self.dest_unit:get_object(object_name:id())
end

function SequenceEnvironment.body(body_name)
	return body_name and SequenceEnvironment.self.dest_unit:body(body_name)
end

function SequenceEnvironment.object_pos(object_name)
	local obj = object_name and SequenceEnvironment.self.dest_unit:get_object(object_name:id())

	if obj then
		return obj:position()
	else
		SequenceEnvironment.element:print_error("Invalid object name \"" .. tostring(object_name) .. "\" in domain function \"object_pos\".", true, SequenceEnvironment.self)

		return Vector3()
	end
end

function SequenceEnvironment.object_rot(object_name)
	local obj = object_name and SequenceEnvironment.self.dest_unit:get_object(object_name:id())

	if obj then
		return obj:rotation()
	else
		SequenceEnvironment.element:print_error("Invalid object name \"" .. tostring(object_name) .. "\" in domain function \"object_rot\".", true, SequenceEnvironment.self)

		return Rotation()
	end
end

function SequenceEnvironment.object_rot_x(object_name)
	local obj = object_name and SequenceEnvironment.self.dest_unit:get_object(object_name:id())

	if obj then
		return obj:rotation():x()
	else
		SequenceEnvironment.element:print_error("Invalid object name \"" .. tostring(object_name) .. "\" in domain function \"object_rot_x\".", true, SequenceEnvironment.self)

		return Vector3()
	end
end

function SequenceEnvironment.object_rot_y(object_name)
	local obj = object_name and SequenceEnvironment.self.dest_unit:get_object(object_name:id())

	if obj then
		return obj:rotation():y()
	else
		SequenceEnvironment.element:print_error("Invalid object name \"" .. tostring(object_name) .. "\" in domain function \"object_rot_y\".", true, SequenceEnvironment.self)

		return Vector3()
	end
end

function SequenceEnvironment.object_rot_z(object_name)
	local obj = object_name and SequenceEnvironment.self.dest_unit:get_object(object_name:id())

	if obj then
		return obj:rotation():z()
	else
		SequenceEnvironment.element:print_error("Invalid object name \"" .. tostring(object_name) .. "\" in domain function \"object_rot_z\".", true, SequenceEnvironment.self)

		return Vector3()
	end
end

function SequenceEnvironment.object_local_pos(object_name)
	local obj = object_name and SequenceEnvironment.self.dest_unit:get_object(object_name:id())

	if obj then
		return obj:local_position()
	else
		SequenceEnvironment.element:print_error("Invalid object name \"" .. tostring(object_name) .. "\" in domain function \"object_local_pos\".", true, SequenceEnvironment.self)

		return Vector3()
	end
end

function SequenceEnvironment.object_local_rot(object_name)
	local obj = object_name and SequenceEnvironment.self.dest_unit:get_object(object_name:id())

	if obj then
		return obj:local_rotation()
	else
		SequenceEnvironment.element:print_error("Invalid object name \"" .. tostring(object_name) .. "\" in domain function \"object_local_rot\".", true, SequenceEnvironment.self)

		return Rotation()
	end
end

function SequenceEnvironment.object_local_rot_x(object_name)
	local obj = object_name and SequenceEnvironment.self.dest_unit:get_object(object_name:id())

	if obj then
		return obj:local_rotation():x()
	else
		SequenceEnvironment.element:print_error("Invalid object name \"" .. tostring(object_name) .. "\" in domain function \"object_local_rot_x\".", true, SequenceEnvironment.self)

		return Vector3()
	end
end

function SequenceEnvironment.object_local_rot_y(object_name)
	local obj = object_name and SequenceEnvironment.self.dest_unit:get_object(object_name:id())

	if obj then
		return obj:local_rotation():y()
	else
		SequenceEnvironment.element:print_error("Invalid object name \"" .. tostring(object_name) .. "\" in domain function \"object_local_rot_y\".", true, SequenceEnvironment.self)

		return Vector3()
	end
end

function SequenceEnvironment.object_local_rot_z(object_name)
	local obj = object_name and SequenceEnvironment.self.dest_unit:get_object(object_name:id())

	if obj then
		return obj:local_rotation():z()
	else
		SequenceEnvironment.element:print_error("Invalid object name \"" .. tostring(object_name) .. "\" in domain function \"object_local_rot_z\".", true, SequenceEnvironment.self)

		return Vector3()
	end
end

function SequenceEnvironment.object_rot_y_flat(object_name)
	local obj = object_name and SequenceEnvironment.self.dest_unit:get_object(object_name:id())

	if obj then
		local y_dir = obj:rotation():y()

		mvector3.set_z(y_dir, 0)

		return Rotation(y_dir, math.UP)
	else
		SequenceEnvironment.element:print_error("Invalid object name \"" .. tostring(object_name) .. "\" in domain function \"object_rot_y\".", true, SequenceEnvironment.self)

		return Rotation()
	end
end

function SequenceEnvironment.Z()
	return math.Z
end

function SequenceEnvironment.pick(...)
	local pick_list = {
		...
	}

	return pick_list[math.random(1, #pick_list)]
end

function SequenceEnvironment.rot_sum(...)
	local rot_list = {
		...
	}
	local rot_sum = Rotation()

	for _, rot in ipairs(rot_list) do
		rot_sum = Rotation(rot_sum:yaw() + rot:yaw(), rot_sum:pitch() + rot:pitch(), rot_sum:roll() + rot:roll())
	end

	return rot_sum
end

function SequenceEnvironment.rot_mul(rot, float)
	return Rotation(rot:yaw() * float, rot:pitch() * float, rot:roll() * float)
end

function SequenceEnvironment.rot_div(rot, float)
	if float ~= 0 then
		return Rotation(rot:yaw() / float, rot:pitch() / float, rot:roll() / float)
	else
		SequenceEnvironment.element:print_error("The rotation \"" .. tostring(object_name) .. "\" was divided by zero in domain function \"rot_div\".", true, SequenceEnvironment.self)

		return Rotation()
	end
end

function SequenceEnvironment.t()
	return TimerManager:game():time()
end

function SequenceEnvironment.print_vars()
	cat_print("debug", "damage_type: " .. tostring(SequenceEnvironment.self.damage_type))
	cat_print("debug", "src_unit: " .. tostring(SequenceEnvironment.self.src_unit))
	cat_print("debug", "dest_unit: " .. tostring(SequenceEnvironment.self.dest_unit))

	if alive(SequenceEnvironment.self.dest_body) then
		cat_print("debug", "dest_body: " .. tostring(SequenceEnvironment.self.dest_body:name()))
	else
		cat_print("debug", "dest_body: " .. tostring(SequenceEnvironment.self.dest_body))
	end

	cat_print("debug", "dest_normal: " .. tostring(SequenceEnvironment.self.dest_normal))
	cat_print("debug", "pos: " .. tostring(SequenceEnvironment.self.pos))
	cat_print("debug", "dir: " .. tostring(SequenceEnvironment.self.dir))
	cat_print("debug", "damage: " .. tostring(SequenceEnvironment.self.damage))
	cat_print("debug", "velocity: " .. tostring(SequenceEnvironment.self.velocity))

	local first = true

	for k, v in pairs(SequenceEnvironment.self.params) do
		if first then
			cat_print("debug", "Parameters:")

			first = false
		end

		cat_print("debug", "  params." .. tostring(k) .. "=" .. tostring(v))
	end

	first = true

	for k, v in pairs(SequenceEnvironment.self.__run_params) do
		if first then
			cat_print("debug", "Original parameters:")

			first = false
		end

		cat_print("debug", "  params." .. tostring(k) .. "=" .. tostring(v))
	end

	first = true

	for k, v in pairs(SequenceEnvironment.self.vars) do
		if first then
			cat_print("debug", "Local variables:")

			first = false
		end

		cat_print("debug", "  vars." .. tostring(k) .. "=" .. tostring(v))
	end

	first = true

	for k, v in pairs(SequenceEnvironment.self.g_vars) do
		if first then
			cat_print("debug", "Global variables:")

			first = false
		end

		cat_print("debug", "  g_vars." .. tostring(k) .. "=" .. tostring(v))
	end

	cat_print("debug", SequenceEnvironment.element:get_xml_origin())
end

function SequenceEnvironment.angle(v1, v2, up)
	if up then
		local side = math.cross(v1, up)

		if math.dot(v2, side) >= 0 then
			return v1:angle(v2)
		else
			return v1:angle(v2) + 180
		end
	else
		return v1:angle(v2)
	end
end

function SequenceEnvironment.pos_side(obj, pos)
	local dir = (pos - obj:position()):normalized()

	return SequenceEnvironment.dir_side(obj, dir)
end

function SequenceEnvironment.dir_side(obj, dir)
	local world_dir = (-dir):rotate_with(obj:rotation())
	local abs_x = math.abs(world_dir.x)
	local abs_y = math.abs(world_dir.y)
	local abs_z = math.abs(world_dir.z)

	if abs_y <= abs_x and abs_z <= abs_x then
		if world_dir.x > 0 then
			return "right"
		else
			return "left"
		end
	elseif abs_z <= abs_y then
		if world_dir.y > 0 then
			return "front"
		else
			return "back"
		end
	elseif world_dir.z > 0 then
		return "up"
	else
		return "down"
	end
end

function SequenceEnvironment.within_box(pos, box_pos1, box_pos2)
	return (box_pos1.x <= box_pos2.x and box_pos1.x <= pos.x and pos.x <= box_pos1.x or box_pos2.x <= pos.x and pos.x <= box_pos2.x) and (box_pos1.y <= box_pos2.y and box_pos1.y <= pos.x and pos.x <= box_pos1.y or box_pos2.y <= pos.y and pos.y <= box_pos2.y) and (box_pos1.z <= box_pos2.z and box_pos1.z <= pos.z and pos.z <= box_pos1.z or box_pos2.z <= pos.z and pos.z <= box_pos2.z)
end

function SequenceEnvironment.light_mul(light_name)
	local light = light_name and SequenceEnvironment.self.dest_unit:get_object(light_name:id())

	if light and light.multiplier then
		return light:multiplier()
	else
		SequenceEnvironment.element:print_error("Invalid light object name \"" .. tostring(light_name) .. "\" in domain function \"light_mul\".", true, SequenceEnvironment.self)

		return 0
	end
end

function SequenceEnvironment.light_color(light_name)
	local light = light_name and SequenceEnvironment.self.dest_unit:get_object(light_name:id())

	if light and light.color then
		return light:color()
	else
		SequenceEnvironment.element:print_error("Invalid light object name \"" .. tostring(light_name) .. "\" in domain function \"light_color\".", true, SequenceEnvironment.self)

		return Vector3()
	end
end

function SequenceEnvironment.light_far_range(light_name)
	local light = light_name and SequenceEnvironment.self.dest_unit:get_object(light_name:id())

	if light and light.far_range then
		return light:far_range()
	else
		SequenceEnvironment.element:print_error("Invalid light object name \"" .. tostring(light_name) .. "\" in domain function \"light_far_range\".", true, SequenceEnvironment.self)

		return 0
	end
end

function SequenceEnvironment.light_spot_angle_start(light_name)
	local light = light_name and SequenceEnvironment.self.dest_unit:get_object(light_name:id())

	if light and light.spot_angle_start then
		return light:spot_angle_start()
	else
		SequenceEnvironment.element:print_error("Invalid light object name \"" .. tostring(light_name) .. "\" in domain function \"light_spot_angle_start\".", true, SequenceEnvironment.self)

		return 0
	end
end

function SequenceEnvironment.light_spot_angle_end(light_name)
	local light = light_name and SequenceEnvironment.self.dest_unit:get_object(light_name:id())

	if light and light.spot_angle_end then
		return light:spot_angle_end()
	else
		SequenceEnvironment.element:print_error("Invalid light object name \"" .. tostring(light_name) .. "\" in domain function \"light_spot_angle_start\".", true, SequenceEnvironment.self)

		return 0
	end
end

function SequenceEnvironment.get_unique_save_data(id)
	local global_id = SequenceEnvironment.get_unique_save_data_id(id)

	return SequenceEnvironment.g_save_data[global_id]
end

function SequenceEnvironment.set_unique_save_data(id, save_value)
	local global_id = SequenceEnvironment.get_unique_save_data_id(id)
	SequenceEnvironment.g_save_data[global_id] = save_value
end

function SequenceEnvironment.get_unique_save_data_id(id)
	return string.format("%s_%s", tostring(alive(SequenceEnvironment.self.dest_unit) and SequenceEnvironment.self.dest_unit:editor_id()), tostring(id))
end

function SequenceEnvironment.get_camera_pos(index)
	local viewport = managers.viewport:get_active_vp(index)

	if viewport then
		return viewport:camera():position()
	else
		return Vector3()
	end
end

function SequenceEnvironment.get_camera_rot(index)
	local viewport = managers.viewport:get_active_vp(index)

	if viewport then
		return viewport:camera():rotation()
	else
		return Rotation()
	end
end

BaseElement = BaseElement or class()
BaseElement.BASE_ATTRIBUTE_MAP = BaseElement.BASE_ATTRIBUTE_MAP or {
	repeat_nr = true,
	start_time_id_var = true,
	start_time_element_id = true,
	filter = true,
	delayed_filter = true,
	start_time = true
}
BaseElement.SAVE_STATE = true

function BaseElement:init(node, unit_element)
	self._unit_element = unit_element
	local __filter_name, __delayed_filter_name = nil

	if node then
		self._node_file = self:retrieve_node_file(node)
		self._node_line = self:retrieve_node_line(node)
		self._parameters = {}

		for n, data in pairs(node) do
			if n ~= "_meta" and CoreClass.type_name(data) ~= "table" then
				self._parameters[n] = data
			end
		end

		self._start_time = self:get("start_time")

		if not unit_element then
			self._start_time = nil

			self:print_error("Unable to use \"start_time\"-attribute because the unit_element is missing.", true, nil, node)
		end

		if self._start_time then
			self._start_time_element_id = self:get("start_time_element_id")
			self._start_time_element_id = self._start_time_element_id and self:run_parsed_func(SequenceEnvironment, self._start_time_element_id)
			self._start_time_element_id = unit_element:_register_start_time_callback(self._start_time_element_id, self, node)
		end

		self._start_time_id_var = self:get("start_time_id_var")
		self._repeat_nr = self:get("repeat_nr")
		__filter_name = self:get("filter")
		__delayed_filter_name = self:get("delayed_filter")
	else
		self._parameters = {}
	end

	if __filter_name ~= nil and unit_element then
		function self:_is_allowed_func(env)
			local filter_name = self:run_parsed_func(env, __filter_name)
			local filter = filter_name and unit_element:get_filter(filter_name)

			if filter then
				return filter:is_allowed(env)
			else
				return filter_name
			end
		end
	end

	if __delayed_filter_name ~= nil and unit_element then
		function self:_delayed_is_allowed_func(env)
			local filter_name = self:run_parsed_func(env, __delayed_filter_name)
			local filter = unit_element:get_filter(filter_name)

			if filter then
				return filter:is_allowed(env)
			else
				return filter_name
			end
		end
	end
end

function BaseElement:retrieve_node_file(node)
	return node.file and node:file() or nil
end

function BaseElement:retrieve_node_line(node)
	local line = node.line and node:line() or nil

	if line and (line <= 0 or line >= 276577824) then
		return nil
	else
		return line
	end
end

function BaseElement:get(name, set_function)
	return self:get_static(name, self._parameters[name], set_function)
end

function BaseElement:get_static(name, value, set_function, node)
	local __func = nil

	if value ~= nil then
		local error_msg = nil
		__func, error_msg = loadstring("return " .. tostring(value))

		if __func then
			if set_function then
				return function (env, ...)
					setfenv(__func, env)
					set_function(self, env, __func(), ...)
				end
			else
				return function (env, ...)
					setfenv(__func, env)

					return __func(env, ...)
				end
			end
		else
			self:print_error("Unable to parse " .. tostring(name) .. "=\"" .. tostring(value) .. "\".\n" .. tostring(error_msg), true, nil, node)
		end
	end

	return nil
end

function BaseElement:run_parsed_func(env, func)
	if func ~= nil then
		return func(env)
	else
		return nil
	end
end

function BaseElement:run_parsed_func_list(env, list)
	local parsed_list = {}

	for _, func in ipairs(list) do
		table.insert(parsed_list, self:run_parsed_func(env, func))
	end

	return parsed_list
end

function BaseElement:run_parsed_func_map(env, map)
	local parsed_map = {}

	for key, func in ipairs(map) do
		parsed_map[key] = self:run_parsed_func(env, func)
	end

	return parsed_map
end

function BaseElement:activate(env)
	SequenceEnvironment.self = env
	SequenceEnvironment.element = self

	if alive(env.dest_unit) and self:filter_callback(env) then
		local start_time = self:run_parsed_func(env, self._start_time) or 0
		local repeat_nr = self:run_parsed_func(env, self._repeat_nr) or 1

		if start_time > 0 then
			local start_time_id_var = self:run_parsed_func(env, self._start_time_id_var)
			local id = managers.sequence:_add_start_time_callback(self._start_time_element_id, env, start_time, repeat_nr, nil)

			if start_time_id_var then
				env.vars[start_time_id_var] = id
			end
		else
			for i = 1, repeat_nr do
				if alive(env.dest_unit) then
					SequenceEnvironment.self = env
					SequenceEnvironment.element = self

					self:activate_callback(env)
				else
					break
				end
			end
		end
	end
end

function BaseElement:start_time_callback(env)
	if alive(env.dest_unit) and self:delayed_filter_callback(env) then
		SequenceEnvironment.self = env
		SequenceEnvironment.element = self

		self:activate_callback(env)
	end
end

function BaseElement:filter_callback(env)
	return not self._is_allowed_func or self:_is_allowed_func(env)
end

function BaseElement:delayed_filter_callback(env)
	return not self._delayed_is_allowed_func or self:_delayed_is_allowed_func(env)
end

function BaseElement:activate_callback(env)
end

function BaseElement:set_state(unit, data)
	local extension = unit:damage()

	if extension then
		extension._state = extension._state or {}
		extension._state[self.NAME] = data
	end
end

function BaseElement:set_cat_state(unit, category, cat_data)
	local extension = unit:damage()

	if extension then
		extension._state = extension._state or {}
		local data = extension._state[self.NAME] or {}
		data[category] = cat_data
		extension._state[self.NAME] = data
	end
end

function BaseElement:set_cat_state2(unit, category1, category2, cat_data)
	local extension = unit:damage()

	if extension then
		extension._state = extension._state or {}
		local data = extension._state[self.NAME] or {}
		local key = type(category1) == "userdata" and category1:key() or category1
		data[key] = data[key] or {}
		data[key][category2] = cat_data
		extension._state[self.NAME] = data
	end
end

function BaseElement:check_invalid_node(node, valid_node_list)
	if self:is_valid_xml_node(node) then
		local unit_name = self._unit_element and self._unit_element:get_name() or self._name or "[None]"

		Application:error("\"" .. tostring(node:name()) .. "\" elements for unit \"" .. tostring(unit_name) .. "\" are not supported in the \"" .. tostring(self._element_name or "<nil>") .. "\" elements, only the following are allowed: " .. SequenceManager:get_keys_as_string(valid_node_list, "[None]", true, #valid_node_list > 0) .. " " .. self:get_xml_origin())
	end
end

function BaseElement:is_valid_xml_node(node)
	return #node:name() ~= 0 and node:name() ~= "xdefine" and node:name() ~= "#text"
end

function BaseElement:print_attribute_error(attribute_name, attribute_value, valid_values, recoverable, env_to_print, node)
	local msg = string.format("Attribute \"%s\" evaluated to the invalid value \"%s\".", attribute_name, tostring(attribute_value))

	if valid_values then
		msg = msg .. " Valid values: " .. valid_values
	end

	self:print_error(msg, recoverable, env_to_print, node)
end

function BaseElement:print_error(msg, recoverable, env_to_print, node)
end

function BaseElement:get_xml_origin(node)
	local file = node and self:retrieve_node_file(node) or self:get_model_xml_file()
	local line = node and self:retrieve_node_line(node) or self._node_line
	file = string.gsub(tostring(managers.database and managers.database:base_path() or "") .. tostring(file), "(.-)[/\\]+(.-)", "%1\\%2")

	return "File: \"" .. tostring(file or "N/A") .. "\" (Line: " .. tostring(line or "N/A, remove .xmb file") .. ")\nUnit: \"" .. tostring(self._unit_element and self._unit_element:get_name():t() or "[None]") .. "\"\nElement: " .. self:get_xml_element_string(node)
end

local is_win32 = SystemInfo:platform() == Idstring("WIN32")

function BaseElement:get_model_xml_file()
	if self._node_file then
		return self._node_file
	elseif self._unit_element and DB:has("unit", self._unit_element:get_name():id()) then
		local model_name = CoreEngineAccess._editor_unit_data(self._unit_element:get_name():id()):model()

		return is_win32 and model_name:s() or model_name
	end

	return nil
end

function BaseElement:get_xml_element_string(node)
	local name = node and type(node.name) == "function" and node:name() or self._element_name
	local str = "<" .. tostring(name)
	local paramaters = node and (type(node.parameter_map) == "function" and node:parameter_map() or type(node.parameters) == "function" and node:parameters()) or self._parameters

	for k, v in pairs(paramaters) do
		str = str .. " " .. k .. "=\"" .. tostring(v) .. "\""
	end

	return str .. "/>"
end

UnitElement = UnitElement or class(BaseElement)

function UnitElement:init(node, name, is_global)
	BaseElement.init(self, node, self)

	self._name = name

	if not is_global then
		local global_core_unit_element = managers.sequence:get_global_core_unit_element()

		if global_core_unit_element then
			local global_vars = global_core_unit_element:get_global_set_var_map()

			if global_vars then
				self._set_global_vars = table.map_copy(global_vars)
			end

			local vars = global_core_unit_element:get_set_var_map()

			if vars then
				self._set_variables = table.map_copy(vars)
			end
		end

		local global_unit_element = managers.sequence:get_global_unit_element()

		if global_unit_element then
			local global_vars = global_unit_element:get_global_set_var_map()

			if global_vars then
				self._set_global_vars = table.map_copy(global_vars)
			end

			local vars = global_unit_element:get_set_var_map()

			if vars then
				self._set_variables = table.map_copy(vars)
			end
		end
	end

	local endurance = self:get("endurance")

	if endurance then
		endurance = endurance(SequenceEnvironment) or 0
	else
		endurance = 0
	end

	if endurance ~= 0 then
		self._global_vars = self._global_vars or {}
		self._global_vars.endurance = endurance
	end

	self._sequence_elements = {}
	self._bodies = {}
	self._proximity_element = nil

	if node then
		for _, data in ipairs(node) do
			local element_name = data._meta

			if element_name == "variables" then
				for _, v_data in ipairs(data) do
					local name = v_data._meta
					self._set_variables = self._set_variables or {}
					self._set_variables[name] = self:get_static("value", v_data.value, nil, data)

					if self._set_variables[name] then
						self._set_variables[name] = self._set_variables[name](SequenceEnvironment)
					end
				end
			elseif element_name == "global_variables" then
				for _, v_data in ipairs(data) do
					local name = v_data._meta
					self._global_vars = self._global_vars or {}
					self._global_vars[name] = self:get_static("value", v_data.value, nil, data)

					if self._global_vars[name] then
						self._global_vars[name] = self._global_vars[name](SequenceEnvironment)
					end
				end
			end
		end

		local sequence_nodes = {}
		local water_node_list = {}
		local body_nodes = {}

		for _, data in ipairs(node) do
			local element_name = data._meta

			if element_name == "trigger" then
				local trigger = TriggerDeclarationElement:new(data, self)
				self._triggers = self._triggers or {}
				self._triggers[trigger._name] = trigger
			elseif element_name == "filter" then
				local filter = FilterElement:new(data, self)
				self._filters = self._filters or {}
				self._filters[filter._name] = filter
			elseif element_name == "sequence" then
				local name = self:get_static("name", data.name, nil, data)
				name = name and name(SequenceEnvironment)

				if not name then
					self:print_attribute_error("name", name, nil, false, nil, data)
				else
					sequence_nodes[name] = data
				end
			elseif element_name == "body" then
				table.insert(body_nodes, data)
			elseif element_name == "water" then
				table.insert(water_node_list, child_node)
			elseif element_name == "proximities" then
				if not self._proximity_element then
					self._proximity_element = ProximityElement:new(data, self)
				else
					Application:throw_exception("\"" .. tostring(node:name()) .. "\" element for unit \"" .. tostring(unit_element._name) .. "\" has more than one \"proximity\" element.")
				end
			elseif element_name ~= "variables" and element_name ~= "global_variables" then
				self:check_invalid_node(data, {
					"trigger",
					"filter",
					"sequence",
					"body",
					"proximities"
				})
			end
		end

		for name, sequence_node in pairs(sequence_nodes) do
			self._sequence_elements[name] = SequenceElement:new(sequence_node, self, nil, nil)
		end

		for _, water_node in ipairs(water_node_list) do
			local water_element = WaterElement:new(water_node, self)

			if self._water_element_map and self._water_element_map[water_element._name] then
				error("Duplicate " .. water_element._element_name .. " element \"" .. tostring(water_element._name) .. "\" in unit \"" .. self._name:t() .. "\".")
			elseif not water_element:is_empty() and water_element._name then
				self._water_element_map = self._water_element_map or {}
				self._water_element_map[water_element._name] = water_element
			end
		end

		for _, body_node in ipairs(body_nodes) do
			local body_element = RootBodyElement:new(body_node, self)

			if self._bodies[body_element._name] then
				error("Duplicate " .. body_element._element_name .. " element \"" .. tostring(body_element._name) .. "\" in unit \"" .. self._name:t() .. "\".")
			else
				self._bodies[body_element._name] = body_element
			end
		end

		if self._global_vars then
			for k, v in pairs(self._global_vars) do
				_set_global_vars = _set_global_vars or {}
				self._set_global_vars[k] = v
			end
		end
	end
end

function UnitElement:_register_start_time_callback(id, element, node)
	if id == nil then
		self._last_created_start_time_element_id = (self._last_created_start_time_element_id or 0) + 1
		id = (self._unit_element and self._unit_element:get_name():key() or "[None]") .. "_" .. self._last_created_start_time_element_id
	end

	managers.sequence:_register_start_time_callback(id, element, node)

	return id
end

function UnitElement:get_startup_sequence_map(unit, damage_ext)
	local env, map = nil

	for name, sequence in pairs(self._sequence_elements) do
		local startup = sequence._startup

		if startup then
			if not env then
				env = SequenceEnvironment:new("startup", unit, unit, nil, math.UP, Vector3(), math.DOWN, 0, Vector3(), nil, self, damage_ext)
				SequenceEnvironment.self = env
			end

			if sequence:run_parsed_func(env, startup) then
				map = map or {}
				map[name] = true
			end
		end
	end

	return map
end

function UnitElement:get_editor_startup_sequence_map(unit, damage_ext)
	local env, map = nil

	for name, sequence in pairs(self._sequence_elements) do
		local editor_startup = sequence._editor_startup

		if editor_startup then
			if not env then
				env = SequenceEnvironment:new("editor_startup", unit, unit, nil, math.UP, Vector3(), math.DOWN, 0, Vector3(), nil, self, damage_ext)
				SequenceEnvironment.self = env
			end

			if sequence:run_parsed_func(env, editor_startup) then
				map = map or {}
				map[name] = true
			end
		end
	end

	return map
end

function UnitElement:get_name()
	return self._name
end

function UnitElement:get_global_set_var_map()
	return self._set_global_vars
end

function UnitElement:get_set_var_map()
	return self._set_variables
end

function UnitElement:get_body_element(body_name)
	return self._bodies[body_name]
end

function UnitElement:get_trigger_name_list()
	local trigger_name_list = {}

	if self._triggers then
		for name, _ in pairs(self._triggers) do
			table.insert(trigger_name_list, name)
		end
	end

	return trigger_name_list
end

function UnitElement:has_trigger_name(trigger_name)
	return self._triggers and self._triggers[trigger_name] ~= nil
end

function UnitElement:get_trigger_name_map()
	return self._triggers or {}
end

function UnitElement:get_sequence_name_list()
	local sequence_name_list = {}

	for name, _ in pairs(self._sequence_elements) do
		table.insert(sequence_name_list, name)
	end

	for name, _ in pairs(managers.sequence:get_global_sequence_map()) do
		table.insert(sequence_name_list, name)
	end

	return sequence_name_list
end

function UnitElement:get_parameter_sequence_name_list(parameter_name, parameter_value)
	local sequence_name_list = {}

	for name, sequence_element in pairs(self._sequence_elements) do
		local value = sequence_element:get(parameter_name)

		if value and value(SequenceEnvironment) == parameter_value then
			table.insert(sequence_name_list, name)
		end
	end

	return sequence_name_list
end

function UnitElement:has_sequence_name(sequence_name)
	return self._sequence_elements[sequence_name] ~= nil
end

function UnitElement:get_body_element(body_name)
	return self._bodies[body_name]
end

function UnitElement:get_body_element_list()
	return self._bodies
end

function UnitElement:get_endurance()
	return self._global_vars and self._global_vars.endurance or 0
end

function UnitElement:set_endurance(endurance)
	self._global_vars = self._global_vars or {}
	self._global_vars.endurance = endurance
end

function UnitElement:reset_damage(unit)
	for _, root_body in pairs(self._bodies) do
		local extension = unit:body(root_body._name):extension().damage

		for damage_type, endurance_element in pairs(root_body._first_endurance) do
			extension._endurance[damage_type] = endurance_element
			extension._damage[damage_type] = 0
		end
	end

	unit:damage()._damage = 0
end

function UnitElement:run_sequence(name, endurance_type, source_unit, dest_unit, dest_body, dest_normal, position, direction, damage, velocity, params)
	local sequence = self:get_sequence_element(name)
	local env = SequenceEnvironment:new(endurance_type, source_unit, dest_unit, dest_body, dest_normal, position, direction, damage, velocity, params, self)

	if sequence then
		sequence:activate(env)
	else
		SequenceEnvironment.self = env
		SequenceEnvironment.element = self
	end
end

function UnitElement:has_sequence(sequence_name)
	return self:get_sequence_element(sequence_name) ~= nil
end

function UnitElement:get_sequence_element(sequence_name)
	return self._sequence_elements[sequence_name] or managers.sequence:get_global_sequence(sequence_name)
end

function UnitElement:get_proximity_element_map()
	if self._proximity_element then
		return self._proximity_element:get_proximity_element_map()
	else
		return {}
	end
end

function UnitElement:save_by_unit(unit, data)
	local state = {}
	local changed = false

	for name, _ in pairs(self._bodies) do
		changed = unit:body(name):extension().damage:save(state) or changed
	end

	if changed then
		data.UnitElement = state
	end

	return changed
end

function UnitElement:load_by_unit(unit, data)
	local state = data.UnitElement

	if state then
		for name, _ in pairs(self._bodies) do
			unit:body(name):extension().damage:load(state)
		end
	end
end

function UnitElement:get_filter(filter_name)
	return self._filters and self._filters[filter_name] or managers.sequence:get_global_filter(filter_name)
end

function UnitElement:get_water_element_map()
	return self._water_element_map
end

function UnitElement:save(data)
	local state = {}
	local changed = false

	if self._global_vars then
		for k, v in pairs(self._global_vars) do
			if not self._set_global_vars or self._set_global_vars[k] ~= v then
				state.global_vars = table.map_copy(self._global_vars)
				changed = true

				break
			end
		end
	end

	if changed then
		data[self._name] = state
	end
end

function UnitElement:load(data)
	local state = data[self._name]

	if state and state.global_vars then
		self._global_vars = table.map_copy(state.global_vars)
	end
end

TriggerDeclarationElement = TriggerDeclarationElement or class(BaseElement)

function TriggerDeclarationElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._name = self:get("name")

	if self._name then
		self._name = self._name(SequenceEnvironment)
	end

	if self._name == nil then
		Application:throw_exception("Unit \"" .. tostring(unit_element._name) .. "\" has an invalid trigger element name \"" .. tostring(self._parameters.name) .. "\".")
	end
end

FilterElement = FilterElement or class(BaseElement)

function FilterElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._name = self:get("name")

	if self._name then
		self._name = self._name(SequenceEnvironment)
	end

	if self._name == nil then
		Application:throw_exception("Unit \"" .. tostring(unit_element._name) .. "\" has an invalid filter element name \"" .. tostring(self._parameters.name) .. "\".")
	end

	self._allow = self:get("allow")
	self._check_all = self:get("check_all")
	self._elements = {}
	local filter_element_class_map = managers.sequence:get_filter_element_class_map()

	for _, data in ipairs(node) do
		local element_class = filter_element_class_map[data._meta]

		if element_class then
			local element = element_class:new(data, unit_element)

			table.insert(self._elements, element)
		else
			self:check_invalid_node(data, filter_element_class_map)
		end
	end
end

function FilterElement:is_allowed(env)
	local allow = self:run_parsed_func(env, self._allow) or true
	local check_all = self:run_parsed_func(env, self._check_all) or true
	local allowed = true

	for _, element in ipairs(self._elements) do
		allowed = element:is_allowed(env) == allow

		if check_all and not allowed then
			break
		elseif not check_all and allowed then
			break
		end
	end

	return allowed
end

CheckFilterElement = CheckFilterElement or class(BaseElement)
CheckFilterElement.NAME = "check"

function CheckFilterElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._value = self:get("value")

	if self._value == nil then
		Application:throw_exception("\"" .. tostring(node:name()) .. "\" element for unit \"" .. tostring(unit_element._name) .. "\" defined an invalid value \"" .. tostring(self._value) .. "\".")
	end
end

function CheckFilterElement:is_allowed(env)
	return self:run_parsed_func(env, self._value) == true
end

SideFilterElement = SideFilterElement or class(BaseElement)
SideFilterElement.NAME = "side"

function SideFilterElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._axis = self:get("axis")

	if self._axis then
		self._axis = self._axis(SequenceEnvironment)
	end

	if self._axis == nil then
		self._axis = "y"
	else
		if self._axis:sub(1, 1) == "-" then
			self._axis = self._axis:sub(2)
			self._multiplier = -1
		else
			self._multiplier = 1
		end

		if self._axis ~= "x" and self._axis ~= "y" and self._axis ~= "z" then
			Application:throw_exception("\"" .. tostring(node:name()) .. "\" element for unit \"" .. tostring(unit_element._name) .. "\" defined an invalid axis \"" .. tostring(self._axis) .. "\".")
		end
	end
end

function SideFilterElement:is_allowed(env)
	if alive(env.dest_body) then
		local rotation = env.dest_body:rotation()
		local dot = math.dot(env.dest_normal, self._multiplier * rotation[self._axis](rotation))

		return dot > 0.9
	else
		self:print_error("Unable to use filter on destroyed dest_body. This is probably because a scripter didn't specify a body when a sequence was executed or if it was executed from a sequence that had \"startup\" attribute set to true or if the sequence was triggered from a water element.", true, env)

		return false
	end
end

ZoneFilterElement = ZoneFilterElement or class(BaseElement)
ZoneFilterElement.NAME = "zone"

function ZoneFilterElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	local name = self:get("name")
	name = name and name(SequenceEnvironment)
	self._ref_object = self:get("ref_object")

	if self._ref_object == nil then
		Application:throw_exception("\"" .. tostring(node:name()) .. "\" element for unit \"" .. tostring(unit_element._name) .. "\" defined an invalid \"ref_object\" in zone \"" .. tostring(name) .. "\".")
	end

	self._func_list = {}
	local negative = false

	for i = 1, #name do
		local __chr = string.sub(name, i, i)

		if __chr == "-" then
			negative = true
		elseif __chr == "x" or __chr == "y" or __chr == "z" then
			local func = nil

			if negative then
				function func(zone_vector)
					return zone_vector[__chr] < 0
				end
			else
				function func(zone_vector)
					return zone_vector[__chr] >= 0
				end
			end

			table.insert(self._func_list, func)

			negative = false
		end
	end

	if #self._func_list == 0 then
		Application:throw_exception("\"" .. tostring(node:name()) .. "\" element for unit \"" .. tostring(unit_element._name) .. "\" defined an invalid name \"" .. tostring(name) .. "\".")
	end
end

function ZoneFilterElement:is_allowed(env)
	local obj_name = self:run_parsed_func(env, self._ref_object)
	local obj = obj_name and env.dest_unit:get_object(obj_name:id())

	if obj then
		local zone_vector = (env.pos - obj:position()):rotate_with(obj:rotation():inverse())
		local allowed = true

		for _, func in ipairs(self._func_list) do
			allowed = func(zone_vector)

			if not allowed then
				break
			end
		end

		return allowed
	else
		self:print_attribute_error("ref_object", obj, nil, true, env, nil)

		return false
	end
end

SequenceElement = SequenceElement or class(BaseElement)

function SequenceElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._name = self:get("name")

	if self._name then
		self._name = self._name(SequenceEnvironment)
	else
		Application:throw_exception("\"" .. tostring(node:name()) .. "\" element for unit \"" .. tostring(unit_element._name) .. "\" doesn't have a name.")
	end

	self._activate_once = self:get("once")
	self._startup = self:get("startup")
	self._editor_startup = self:get("editor_startup")
	self._elements = {}

	for _, data in ipairs(node) do
		local name = data._meta
		local element = managers.sequence:parse_event(data, unit_element)

		if element then
			table.insert(self._elements, element)
		else
			self:check_invalid_node(data, managers.sequence:get_event_element_class_map())
		end
	end
end

function SequenceElement:activate_callback(env)
	managers.sequence:update_startup_callbacks()

	local damage_ext = env.dest_unit:damage()

	if not damage_ext._runned_sequences or not damage_ext._runned_sequences[self._name] then
		if self:run_parsed_func(env, self._activate_once) then
			damage_ext._runned_sequences = damage_ext._runned_sequences or {}
			damage_ext._runned_sequences[self._name] = true
		end

		if Global.category_print.sequence then
			cat_print("sequence", string.format("[SequenceManager] Run sequence: %s, Type: %s, Unit: %s, Id: %s, Key: %s", tostring(self._name), tostring(env.damage_type), tostring(env.dest_unit:name()), tostring(env.dest_unit:editor_id()), tostring(env.dest_unit:key())))
		end

		managers.mission:runned_unit_sequence(env.dest_unit, self._name, env.params)

		for _, element in ipairs(self._elements) do
			element:activate(env)
		end
	end
end

ProximityElement = ProximityElement or class(BaseElement)

function ProximityElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._element_map = {}

	for _, child_node in ipairs(node) do
		local element = ProximityTypeElement:new(child_node, unit_element)
		local proximity_name = element:get_name()

		if not self._element_map[proximity_name] then
			self._element_map[proximity_name] = element
		else
			element:print_error("Proximity with name \"" .. proximity_name:t() .. "\" has already been defined.", false, nil)
		end
	end
end

function ProximityElement:get_proximity_element_map()
	return self._element_map
end

ProximityTypeElement = ProximityTypeElement or class(BaseElement)
ProximityTypeElement.MIN_INTERVAL = 0.2

function ProximityTypeElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._name = self:get("name")
	self._name = self._name and self._name(SequenceEnvironment)

	if not self._name then
		self:print_attribute_error("name", self._name, nil, false, nil)
	end

	local proximity_type = self:get("type")
	proximity_type = proximity_type and proximity_type(SequenceEnvironment)
	self._slotmask = proximity_type and managers.sequence:get_proximity_mask(proximity_type)

	if not self._slotmask then
		local supported_values = SequenceManager:get_keys_as_string(managers.sequence:get_proximity_mask_map(), "", true, false)

		self:print_attribute_error("type", proximity_type, supported_values, false, nil)

		return
	end

	self._ref_object = self:get("ref_object")
	self._ref_object = self._ref_object and self._ref_object(SequenceEnvironment)
	self._enabled = self:get("enabled")

	if self._enabled then
		self._enabled = self._enabled(SequenceEnvironment)
	else
		self._enabled = true
	end

	self._interval = self:get("interval")
	self._interval = self._interval and tonumber(self._interval(SequenceEnvironment))
	self._interval = math.max(tonumber(self._interval) or 0, self.MIN_INTERVAL)
	self._quick = self:get("quick")
	self._quick = self._quick and self._quick(SequenceEnvironment) or true
	self._start_within = self:get("start_within")
	self._start_within = self._start_within and self._quick(SequenceEnvironment)

	if self._start_within == nil then
		self._start_within = false
	end

	self._within_element = nil
	self._outside_element = nil

	for _, child_node in ipairs(node) do
		local name = child_node._meta

		if name == "within" then
			if not self._within_element then
				self._within_element = ProximityRangeElement:new(child_node, unit_element, true)
			else
				Application:throw_exception("Unit \"" .. tostring(unit_element._name) .. "\" have defined more than one \"within\" element.")
			end
		elseif name == "outside" then
			if not self._outside_element then
				self._outside_element = ProximityRangeElement:new(child_node, unit_element, false)
			else
				Application:throw_exception("Unit \"" .. tostring(unit_element._name) .. "\" have defined more than one \"outside\" element.")
			end
		end
	end

	if (not self._within_element or #self._within_element._elements == 0) and (not self._outside_element or #self._outside_element._elements == 0) then
		Application:throw_exception("\"" .. tostring(node:name()) .. "\" element on unit \"" .. tostring(unit_element._name) .. "\" doesn't have a \"within\" nor a \"outside\" element or they doesn't contain any \"run_sequence\" elements.")
	end
end

function ProximityTypeElement:get_name()
	return self._name
end

function ProximityTypeElement:get_slotmask()
	return self._slotmask
end

function ProximityTypeElement:get_enabled()
	return self._enabled
end

function ProximityTypeElement:get_ref_object()
	return self._ref_object
end

function ProximityTypeElement:get_interval()
	return self._interval
end

function ProximityTypeElement:is_quick()
	return self._quick
end

function ProximityTypeElement:get_start_within()
	return self._start_within
end

function ProximityTypeElement:get_within_element()
	return self._within_element
end

function ProximityTypeElement:get_outside_element()
	return self._outside_element
end

ProximityRangeElement = ProximityRangeElement or class(BaseElement)

function ProximityRangeElement:init(node, unit_element, within)
	BaseElement.init(self, node, unit_element)

	self._within = within
	self._max_activation_count = self:get("max_activations")
	self._max_activation_count = self._max_activation_count and self._max_activation_count(SequenceEnvironment) or -1
	self._delay = self:get("delay")
	self._delay = self._delay and self._delay(SequenceEnvironment) or 0
	self._range = self:get("range")
	self._range = self._range and tonumber(self._range(SequenceEnvironment))
	self._count = self:get("count")
	self._count = self._count and self._count(SequenceEnvironment) or self._within and 1 or 0
	self._elements = {}

	if not self._range or self._range <= 0 then
		Application:throw_exception("\"" .. tostring(name) .. "\" element on unit \"" .. tostring(unit_element._name) .. "\" doesn't have a range specified or it is not more than zero (specified range: " .. tostring(self._range) .. ").")
	end

	for _, child_node in ipairs(node) do
		local name = child_node._meta

		if name == "run_sequence" then
			local element = managers.sequence:parse_event(child_node, unit_element)

			if element then
				table.insert(self._elements, element)
			end
		elseif #name ~= 0 and name ~= "xdefine" then
			Application:throw_exception("\"" .. tostring(name) .. "\" elements for unit \"" .. tostring(unit_element._name) .. "\" are not supported in the \"" .. tostring(node:name()) .. "\" elements, only \"run_sequence\" elements are supported.")
		end
	end
end

function ProximityRangeElement:get_max_activation_count()
	return self._max_activation_count
end

function ProximityRangeElement:get_delay()
	return self._delay
end

function ProximityRangeElement:get_range()
	return self._range
end

function ProximityRangeElement:get_count()
	return self._count
end

function ProximityRangeElement:activate_elements(env)
	for _, element in ipairs(self._elements) do
		element:activate(env)
	end
end

WaterElement = WaterElement or class(BaseElement)

function WaterElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._name = self:get("name")
	self._name = self._name and self._name(SequenceEnvironment)

	if not self._name then
		self:print_error("\"" .. tostring(node:name()) .. "\" element for unit \"" .. tostring(unit_element._name) .. "\" doesn't have a name.", true, nil)
	end

	self._enabled = self:get("enabled")
	self._enabled = self._enabled == nil or self._enabled(SequenceEnvironment)
	self._interval = self:get("interval")
	self._interval = tonumber(self._interval and self._interval(SequenceEnvironment)) or 1
	self._ref_object = self:get("ref_object")
	self._ref_object = self._ref_object and self._ref_object(SequenceEnvironment)
	self._ref_body = self:get("ref_body")
	self._ref_body = self._ref_body and self._ref_body(SequenceEnvironment)
	self._body_depth = self:get("body_depth")
	self._body_depth = self._body_depth and self._body_depth(SequenceEnvironment) or 0
	self._physic_effect = self:get("physic_effect")
	self._physic_effect = self._physic_effect and self._physic_effect(SequenceEnvironment)
	self._enter_element = nil
	self._exit_element = nil

	for child_node in node:children() do
		local name = child_node:name()

		if name == "enter" then
			local element = EnterWaterElement:new(child_node, unit_element)

			if not self._enter_element then
				self._enter_element = element
			else
				element:print_error("Duplicate enter element found in water element \"" .. tostring(self._name) .. "\".", false, nil)
			end
		elseif name == "exit" then
			local element = ExitWaterElement:new(child_node, unit_element)

			if not self._exit_element then
				self._exit_element = element
			else
				element:print_error("Duplicate exit element found in water element \"" .. tostring(self._name) .. "\".", false, nil)
			end
		else
			self:check_invalid_node(child_node, {
				"enter",
				"exit"
			})
		end
	end

	if self:is_empty() then
		self:print_error("Water element \"" .. tostring(self._name) .. "\" is empty.", false, nil)
	end
end

function WaterElement:is_empty()
	return (not self._enter_element or self._enter_element:sequence_count() == 0) and (not self._exit_element or self._exit_element:sequence_count() == 0)
end

function WaterElement:get_name()
	return self._name
end

function WaterElement:get_enabled()
	return self._enabled
end

function WaterElement:get_interval()
	return self._interval
end

function WaterElement:get_ref_object()
	return self._ref_object
end

function WaterElement:get_ref_body()
	return self._ref_body
end

function WaterElement:get_body_depth()
	return self._body_depth
end

function WaterElement:get_physic_effect()
	return self._physic_effect
end

function WaterElement:activate_enter(env)
	if self._enter_element then
		self._enter_element:activate(env)
	end
end

function WaterElement:activate_exit(env)
	if self._exit_element then
		self._exit_element:activate(env)
	end
end

SequenceContainerElement = SequenceContainerElement or class(BaseElement)

function SequenceContainerElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._sequence_list = {}

	for _, child_node in ipairs(node) do
		local name = child_node._meta

		if name == "run_sequence" then
			local element = managers.sequence:parse_event(child_node, unit_element)

			if element then
				table.insert(self._sequence_list, element)
			end
		else
			self:check_invalid_node(child_node, {
				"run_sequence"
			})
		end
	end
end

function SequenceContainerElement:sequence_count()
	return #self._sequence_list
end

function SequenceContainerElement:activate_callback(env)
	for _, element in ipairs(self._sequence_list) do
		element:activate(env)
	end
end

EnterWaterElement = EnterWaterElement or class(SequenceContainerElement)
ExitWaterElement = ExitWaterElement or class(SequenceContainerElement)
RootBodyElement = RootBodyElement or class(BaseElement)

function RootBodyElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._name = self:get("name")

	if self._name then
		self._name = self._name(SequenceEnvironment)
	else
		error("\"" .. tostring(node:name()) .. "\" element for unit \"" .. tostring(unit_element._name) .. "\" doesn't have a name.")
	end

	self._damage_multiplier = self:get("damage_multiplier")

	if self._damage_multiplier then
		self._damage_multiplier = self._damage_multiplier(SequenceEnvironment) or 1
	else
		self._damage_multiplier = 1
	end

	self._inflict_element = nil
	self._first_endurance = {}

	for _, data in ipairs(node) do
		local name = data._meta
		local element = nil

		if name == "inflict" then
			if self._inflict_element then
				Application:throw_exception("\"" .. self._name .. "\" element for unit \"" .. tostring(unit_element._name) .. "\" have a duplicate \"inflict\" element.")
			else
				self._inflict_element = RootInflictElement:new(data, unit_element)
			end
		elseif name == "endurance" then
			element = EnduranceElement:new(data, unit_element)

			for k, v in pairs(element._endurance) do
				if self._first_endurance[k] == nil then
					self._first_endurance[k] = element
				elseif v < self._first_endurance[k]._endurance[k] then
					element._next[k] = self._first_endurance[k]
					self._first_endurance[k] = element
				else
					local next_element = self._first_endurance[k]

					while next_element._next[k] and next_element._next[k]._endurance[k] <= v do
						next_element = next_element._next[k]
					end

					element._next[k] = next_element._next[k]
					next_element._next[k] = element
				end
			end
		else
			self:check_invalid_node(data, {
				"inflict",
				"endurance"
			})
		end
	end

	self._body_params = {}

	for param_name, _ in pairs(self._parameters) do
		if param_name ~= "name" and param_name ~= "damage_multiplier" then
			self._body_params[param_name] = self:get(param_name)

			if self._body_params[param_name] then
				self._body_params[param_name] = self._body_params[param_name](SequenceEnvironment)
			end
		end
	end
end

function RootBodyElement:get_body_param(param_name)
	return self._body_params[param_name]
end

function RootBodyElement:get_body_param_list()
	return self._body_params
end

function RootBodyElement:get_first_endurance_element(endurance_type)
	return self._first_endurance[endurance_type]
end

function RootBodyElement:get_first_endurance_element_list()
	return self._first_endurance
end

function RootBodyElement:activate_inflict_enter(env)
	self._inflict_element:activate_enter(env)
end

function RootBodyElement:activate_inflict_damage(env)
	self._inflict_element:activate_damage(env)
end

function RootBodyElement:activate_inflict_exit(env)
	self._inflict_element:activate_exit(env)
end

function RootBodyElement:get_inflict_element_list()
	if self._inflict_element then
		return self._inflict_element:get_element_list()
	end
end

RootInflictElement = RootInflictElement or class(BaseElement)

function RootInflictElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._element_list = {}
	local inflict_element_class_map = managers.sequence:get_inflict_element_class_map()

	for _, child_node in ipairs(node) do
		local element_class = inflict_element_class_map[child_node._meta]

		if element_class then
			local element = element_class:new(child_node, unit_element)
			self._element_list[element._element_name] = element
		else
			self:check_invalid_node(child_node, inflict_element_class_map)
		end
	end
end

function RootInflictElement:activate_enter(env)
	self._element_list[env.damage_type]:activate_enter(env)
end

function RootInflictElement:activate_damage(env)
	self._element_list[env.damage_type]:activate_damage(env)
end

function RootInflictElement:activate_exit(env)
	self._element_list[env.damage_type]:activate_exit(env)
end

function RootInflictElement:get_element_list()
	return self._element_list
end

InflictElement = InflictElement or class(BaseElement)

function InflictElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._element_name = node._meta
	self._damage = self:get("give_damage")
	self._damage = self._damage and self._damage(SequenceEnvironment)
	self._interval = self:get("interval")
	self._interval = self._interval and self._interval(SequenceEnvironment)
	self._instant = self:get("instant")
	self._instant = self._instant and self._instant(SequenceEnvironment)

	if self._instant == nil then
		self._instant = false
	end

	self._enabled = self:get("enabled")
	self._enabled = self._enabled and self._enabled(SequenceEnvironment)

	if self._enabled == nil then
		self._enabled = true
	end

	self._enter_element = nil
	self._damage_element = nil
	self._exit_element = nil
	self._enter_sequence_list = {}
	self._sequence_list = {}
	self._exit_sequence_list = {}

	for _, child_node in ipairs(node) do
		local child_name = child_node._meta

		if child_name == "enter" then
			self._enter_element = EnterInflictElement:new(child_node, unit_element)
		elseif child_name == "damage" then
			self._damage_element = DamageInflictElement:new(child_node, unit_element)
		elseif child_name == "exit" then
			self._exit_element = ExitInflictElement:new(child_node, unit_element)
		else
			self:check_invalid_node(child_node, {
				"enter",
				"damage",
				"exit"
			})
		end
	end
end

function InflictElement:get_damage()
	return self._damage
end

function InflictElement:get_interval()
	return self._interval
end

function InflictElement:get_instant()
	return self._instant
end

function InflictElement:get_enabled()
	return self._enabled
end

function InflictElement:get_enter_element()
	return self._enter_element
end

function InflictElement:get_exit_element()
	return self._exit_element
end

function InflictElement:get_damage_element()
	return self._damage_element
end

function InflictElement:activate_enter(env)
	if self._enter_element then
		self._enter_element:activate(env)
	end
end

function InflictElement:activate_damage(env)
	if self._damage_element then
		self._damage_element:activate(env)
	end
end

function InflictElement:activate_exit(env)
	if self._exit_element then
		self._exit_element:activate(env)
	end
end

function InflictElement:enter_sequence_count()
	if self._enter_element then
		return self._enter_element:sequence_count()
	else
		return 0
	end
end

function InflictElement:damage_sequence_count()
	if self._damage_element then
		return self._damage_element:sequence_count()
	else
		return 0
	end
end

function InflictElement:exit_sequence_count()
	if self._exit_element then
		return self._exit_element:sequence_count()
	else
		return 0
	end
end

InflictElectricityElement = InflictElectricityElement or class(InflictElement)
InflictElectricityElement.NAME = "electricity"
InflictFireElement = InflictFireElement or class(InflictElement)
InflictFireElement.NAME = "fire"

function InflictFireElement:init(node, unit_element)
	InflictElement.init(self, node, unit_element)

	self._fire_object_name = self:get("fire_object")
	self._fire_object_name = self._fire_object_name and self._fire_object_name(SequenceEnvironment)
	self._fire_height = self:get("fire_height")
	self._fire_height = self._fire_height and self._fire_height(SequenceEnvironment)
	self._velocity = self:get("velocity")
	self._velocity = self._velocity and self._velocity(SequenceEnvironment)
	self._falloff = self:get("falloff")
	self._falloff = self._falloff and self._falloff(SequenceEnvironment)
end

function InflictFireElement:get_fire_object_name()
	return self._fire_object_name
end

function InflictFireElement:get_fire_height()
	return self._fire_height
end

function InflictFireElement:get_velocity()
	return self._velocity
end

function InflictFireElement:get_falloff()
	return self._falloff
end

EnterInflictElement = EnterInflictElement or class(SequenceContainerElement)
DamageInflictElement = DamageInflictElement or class(SequenceContainerElement)
ExitInflictElement = ExitInflictElement or class(SequenceContainerElement)
EnduranceElement = EnduranceElement or class(BaseElement)

function EnduranceElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._can_skip = self:get("can_skip")
	self._can_skip = self._can_skip and self._can_skip(SequenceEnvironment)
	self._players_only = self:get("players_only")
	self._next = {}
	self._endurance = {}
	self._abs = {}

	for k, v in pairs(self._parameters) do
		if k ~= "can_skip" and k ~= "players_only" and string.sub(k, -4) ~= "_abs" then
			self._endurance[k] = self:get(k)

			if self._endurance[k] then
				self._endurance[k] = self._endurance[k](SequenceEnvironment)
			end

			if self._endurance[k] then
				self._abs[k] = self:get(k .. "_abs")

				if self._abs[k] then
					self._abs[k] = self._abs[k](SequenceEnvironment) or 0
				else
					self._abs[k] = 0
				end
			else
				Application:throw_exception("\"" .. tostring(node._meta) .. "\" element for unit \"" .. tostring(unit_element._name) .. "\" had a endurance \"" .. k .. "\" with the invalid value of \"" .. v .. "\".")
			end
		end
	end

	self._elements = {}

	for _, data in ipairs(node) do
		if data._meta == "run_sequence" then
			local element = managers.sequence:parse_event(data, unit_element)

			if element then
				table.insert(self._elements, element)
			end
		else
			self:check_invalid_node(data, {
				"run_sequence"
			})
		end
	end
end

function EnduranceElement:can_skip()
	return self._can_skip
end

function EnduranceElement:damage(env)
	local new_damage = env.damage - self._abs[env.damage_type]

	if self._players_only then
		local attacker_id = managers.criminals:character_peer_id_by_unit(env.src_unit)

		if not attacker_id then
			return
		end
	end

	if new_damage >= 0 then
		local extension = env.dest_body:extension().damage
		extension._damage[env.damage_type] = extension._damage[env.damage_type] + new_damage

		if self._endurance[env.damage_type] <= extension._damage[env.damage_type] then
			local old_damage = extension._damage[env.damage_type]

			self:activate(env)
		end
	end
end

function EnduranceElement:activate(env)
	local extension = env.dest_body:extension().damage
	extension._endurance[env.damage_type] = self._next[env.damage_type]
	local next_endurance_element = self._next[env.damage_type]
	local skip = next_endurance_element and self._can_skip and next_endurance_element._endurance[env.damage_type] <= extension._damage[env.damage_type]

	if not skip then
		self:activate_elements(env)

		next_endurance_element = self._next[env.damage_type]
	end

	if next_endurance_element and next_endurance_element._endurance[env.damage_type] <= extension._damage[env.damage_type] then
		next_endurance_element:activate(env)

		local unit_map = managers.sequence:get_inflict_updator_unit_map(env.damage_type)

		if unit_map and not extension._damage[env.damage_type] and alive(env.dest_body) then
			managers.sequence:remove_inflict_updator_body(env.damage_type, env.dest_unit:key(), env.dest_body:key())
		end
	end
end

function EnduranceElement:activate_elements(env)
	for _, element in ipairs(self._elements) do
		element:activate(env)
	end
end

AnimationGroupElement = AnimationGroupElement or class(BaseElement)
AnimationGroupElement.NAME = "animation_group"

function AnimationGroupElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._name = self:get("name")
	self._enabled = self:get("enabled")
	self._duration = self:get("duration")
	self._once = self:get("once")
	self._speed = self:get("speed")
	self._time = self:get("from") or self:get("time")
	self._end_time = self:get("to") or self:get("end_time")
	self._loop = self:get("loop")
	self._start_loop_time = self:get("start_loop_time")
end

function AnimationGroupElement:activate_callback(env)
	local name = self:run_parsed_func(env, self._name)

	if self._time then
		self:set_time(env, name)
	end

	if self._enabled then
		local enabled = self:run_parsed_func(env, self._enabled)

		if enabled then
			self:play(env, name)
		else
			self:stop(env, name)
		end
	end
end

function AnimationGroupElement:play(env, name)
	local once = self:run_parsed_func(env, self._once)
	local ids_name = Idstring(name)

	if not once or not env.dest_unit:anim_is_playing(ids_name) then
		local duration = self:run_parsed_func(env, self._duration)
		local speed = self:run_parsed_func(env, self._speed) or 1
		local end_time = nil
		local loop = self:run_parsed_func(env, self._loop)

		if duration and speed < 0 then
			duration = -duration
		end

		if loop then
			local start_loop_time = self:run_parsed_func(env, self._start_loop_time) or env.dest_unit:anim_time(ids_name)

			if duration then
				end_time = start_loop_time + duration
			else
				end_time = self:run_parsed_func(env, self._end_time)
			end

			end_time = end_time or env.dest_unit:anim_length(ids_name)

			env.dest_unit:anim_play_loop(ids_name, start_loop_time, end_time, speed)

			if self.SAVE_STATE then
				self:set_cat_state(env.dest_unit, name, {
					"anim_play_loop",
					start_loop_time,
					end_time,
					speed
				})
			end
		else
			if duration then
				end_time = env.dest_unit:anim_time(name) + duration
			else
				end_time = self:run_parsed_func(env, self._end_time)
			end

			if end_time then
				env.dest_unit:anim_play_to(ids_name, end_time, speed)

				if self.SAVE_STATE then
					self:set_cat_state(env.dest_unit, name, {
						"anim_play_to",
						end_time,
						speed
					})
				end
			else
				env.dest_unit:anim_play(ids_name, speed)

				if self.SAVE_STATE then
					self:set_cat_state(env.dest_unit, name, {
						"anim_play",
						speed
					})
				end
			end
		end
	end
end

function AnimationGroupElement:stop(env, name)
	env.dest_unit:anim_stop(Idstring(name))

	if self.SAVE_STATE then
		self:set_cat_state(env.dest_unit, name, {
			"anim_stop"
		})
	end
end

function AnimationGroupElement:set_time(env, name)
	local time = self:run_parsed_func(env, self._time)

	if time then
		env.dest_unit:anim_set_time(Idstring(name), time)
	end
end

function AnimationGroupElement.load(unit, data)
	for name, cat_data in pairs(data) do
		unit[cat_data[1]](unit, Idstring(name), cat_data[2], cat_data[3], cat_data[4])
	end
end

AnimationRedirectElement = AnimationRedirectElement or class(BaseElement)
AnimationRedirectElement.NAME = "animation_redirect"

function AnimationRedirectElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._name = self:get("name")
	self._enabled = self:get("enabled")
end

function AnimationRedirectElement:activate_callback(env)
	local name = self:run_parsed_func(env, self._name)

	env.dest_unit:play_redirect(Idstring(name))
end

AreaDamageElement = AreaDamageElement or class(BaseElement)
AreaDamageElement.NAME = "area_damage"

function AreaDamageElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._damage_type = self:get("damage_type")
	self._position = self:get("position")
	self._range = self:get("range")
	self._damage = self:get("damage")
	self._physic_effect = self:get("physic_effect")
	self._mass = self:get("mass")
	self._falloff = self:get("falloff")
	self._ignore_mask = self:get("ignore_mask")
	self._falloff_func_map = {
		linear = nil,
		keys = "get_falloff_key_damage",
		preset1 = "get_falloff_preset1_damage"
	}
	self._key_list = {}

	for child_node in node:children() do
		local element_name = child_node:name()

		if element_name == "key" then
			local key = AreaDamageKeyElement:new(child_node, unit_element)

			table.insert(self._key_list, key)
		else
			self:check_invalid_node(child_node, {
				"key"
			})
		end
	end
end

function AreaDamageElement:activate_callback(env)
	local damage_type = self:run_parsed_func(env, self._damage_type)

	if not damage_type then
		self:print_attribute_error("damage_type", damage_type, nil, false, env)
	else
		local position = self:run_parsed_func(env, self._position)

		if not position then
			self:print_attribute_error("position", position, nil, false, env)
		else
			local range = self:run_parsed_func(env, self._range)

			if range and range > 0 then
				local damage = self:run_parsed_func(env, self._damage) or 0
				local physic_effect = self:run_parsed_func(env, self._physic_effect)
				local mass = self:run_parsed_func(env, self._mass)
				local falloff = self:run_parsed_func(env, self._falloff)
				local damage_callback_func_name = falloff and self._falloff_func_map[falloff]
				local damage_callback_func = nil
				local ignore_mask = self:run_parsed_func(env, self._ignore_mask)
				ignore_mask = ignore_mask and managers.slot:get_mask(ignore_mask)

				if #self._key_list == 0 then
					if falloff == "keys" then
						falloff, damage_callback_func_name = nil
					end
				else
					damage_callback_func_name = damage_callback_func_name or self._falloff_func_map.keys
				end

				if damage_callback_func_name then
					local params = self:get_params(env)
					damage_callback_func = callback(self, self, damage_callback_func_name, params)
				end

				self:do_area_damage(env, damage_type, env.dest_unit, position, range, not falloff, damage, physic_effect, mass, nil, env.src_unit, ignore_mask, damage_callback_func, env.velocity)
			end
		end
	end
end

function AreaDamageElement:get_params(env)
	local params = {
		env = env,
		parsed_key_list = {}
	}

	for _, key in ipairs(self._key_list) do
		local parsed_key = key:get_parsed_key(env)
		local index = nil

		for current_index, current_parsed_key in ipairs(params.parsed_key_list) do
			if current_parsed_key:get_variable("range") < parsed_key:get_variable("range") then
				index = current_index

				break
			end
		end

		table.insert(params.parsed_key_list, index or #params.parsed_key_list + 1, parsed_key)
	end

	return params
end

function AreaDamageElement:do_area_damage(env, damage_type, attack_unit, pos, range, constant_damage, damage, physic_effect, mass, ignore_unit, direct_attack_unit, ignore_mask, get_damage_func, velocity)
	managers.sequence:do_area_damage(damage_type, attack_unit, pos, range, constant_damage, damage, physic_effect, mass, ignore_unit, direct_attack_unit, ignore_mask, get_damage_func, velocity)
end

function AreaDamageElement:get_falloff_key_damage(params, unit, body, dir, hit_pos, damage_type, attack_unit, pos, range, constant_damage, damage, velocity, ignore_unit, direct_attack_unit, ignore_mask)
	local distance = self:get_distance(body, hit_pos, pos)
	local key, index = nil

	for current_index, current_key in ipairs(params.parsed_key_list) do
		if current_key:get_variable("range") < distance then
			if not key then
				key = current_key
				index = current_index
			end

			break
		else
			key = current_key
			index = current_index
		end
	end

	if key then
		local prev_key = params.parsed_key_list[index + 1]
		local prev_key_damage, prev_key_range = nil

		if prev_key then
			prev_key_damage = prev_key:get_variable("damage")
			prev_key_range = prev_key:get_variable("range")

			prev_key:get_key_element():activate(params.env, unit, body, hit_pos, distance, range)
		elseif key:get_variable("range") <= distance then
			prev_key_damage = key:get_variable("damage")
			prev_key_range = key:get_variable("range")
		else
			prev_key_damage = damage
			prev_key_range = 0
		end

		return key:get_key_element():get_distance_damage(key, distance, prev_key_range, prev_key_damage)
	else
		return damage
	end
end

function AreaDamageElement:get_falloff_preset1_damage(params, unit, body, dir, hit_pos, damage_type, attack_unit, pos, range, constant_damage, damage, velocity, ignore_unit, direct_attack_unit, ignore_mask)
	local distance = self:get_distance(body, hit_pos, pos)

	return (1 - (distance / range)^2) * damage
end

function AreaDamageElement:get_distance(body, hit_pos, pos)
	return body and get_distance_to_body(body, pos) or (hit_pos - pos):length()
end

AreaDamageKeyElement = AreaDamageKeyElement or class(BaseElement)

function AreaDamageKeyElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._range = self:get("range")
	self._damage = self:get("damage")
	self._falloff_type = self:get("falloff")
	self._physic_effect = self:get("physic_effect")
	self._mass = self:get("mass")
	self._falloff_func_map = {
		linear = self.get_linear_damage
	}
end

function AreaDamageKeyElement:get_parsed_key(env)
	local parsed_key = ParsedKeyElement:new(self)

	parsed_key:set_variable("range", tonumber(self:run_parsed_func(env, self._range)) or 0)
	parsed_key:set_variable("damage", tonumber(self:run_parsed_func(env, self._damage)) or 0)

	local falloff_type = self:run_parsed_func(env, self._falloff_type)

	parsed_key:set_variable("falloff_func", falloff_type and self._falloff_func_map[falloff_type])
	parsed_key:set_variable("physic_effect", self:run_parsed_func(env, self._physic_effect))
	parsed_key:set_variable("mass", self:run_parsed_func(env, self._mass))

	return parsed_key
end

function AreaDamageKeyElement:get_distance_damage(parsed_key, distance, prev_key_range, prev_key_damage)
	local falloff_func = parsed_key:get_variable("falloff_func")

	if falloff_func then
		local damage = parsed_key:get_variable("damage")
		local range = parsed_key:get_variable("range")

		return falloff_func(self, distance, range, damage, prev_key_range, prev_key_damage)
	else
		return prev_key_damage
	end
end

function AreaDamageKeyElement:activate(env, unit, body, pos, distance, total_range)
	SequenceEnvironment.element = self
	local physic_effect = self:run_parsed_func(env, self._physic_effect)

	if physic_effect then
		local mass = self:run_parsed_func(env, self._mass)

		if mass then
			World:play_physic_effect(physic_effect, body or unit, total_range, distance, self._range, mass)
		else
			World:play_physic_effect(physic_effect, body or unit, total_range, distance, self._range)
		end
	end
end

function AreaDamageKeyElement:get_linear_damage(distance, range, damage, prev_key_range, prev_key_damage)
	local diff = range - prev_key_range
	local offset = nil

	if diff > 0 then
		offset = math.clamp(distance - prev_key_range, 0, diff) / diff
	else
		offset = 0
	end

	return math.lerp(prev_key_damage, damage, offset)
end

ParsedKeyElement = ParsedKeyElement or class()

function ParsedKeyElement:init(key_element, variable_map)
	self._key_element = key_element
	self._variable_map = variable_map or {}
end

function ParsedKeyElement:get_key_element()
	return self._key_element
end

function ParsedKeyElement:get_variable(name)
	return self._variable_map[name]
end

function ParsedKeyElement:set_variable(name, value)
	self._variable_map[name] = value
end

BodyElement = BodyElement or class(BaseElement)
BodyElement.NAME = "body"
BodyElement.VALID_MOTION_MAP = BodyElement.VALID_MOTION_MAP or {
	keyframed = "set_keyframed",
	dynamic = "set_dynamic",
	fixed = "set_fixed"
}
BodyElement.FUNC_MAP = BodyElement.FUNC_MAP or {
	mover = "set_mover",
	body_collision = "set_body_collision",
	enabled = "set_enabled",
	remove_ray_type = "remove_ray_type",
	pushed_by_mover = "set_pushed_by_mover",
	motion = "set_motion",
	add_ray_type = "add_ray_type",
	interpolate = "interpolate",
	mover_collision = "set_mover_collision"
}
BodyElement.VALID_MOVER_MAP = BodyElement.VALID_MOVER_MAP or {
	callback = "callback",
	none = ""
}

function BodyElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._name = self:get("name")
	self._set_function_map = {}

	for attribute, func_name in pairs(self.FUNC_MAP) do
		self._set_function_map[attribute] = self:get(attribute, self[func_name])
	end
end

function BodyElement:activate_callback(env)
	local name = self:run_parsed_func(env, self._name)

	if name ~= nil then
		local body = env.dest_unit:body(name)

		if alive(body) then
			for _, func in pairs(self._set_function_map) do
				func(env, body)
			end

			return
		end
	end

	local body_name_list = {}

	for i = 1, env.dest_unit:num_bodies() do
		local body = env.dest_unit:body(i - 1)

		if alive(body) then
			table.insert(body_name_list, body:name())
		end
	end

	local supported_values = SequenceManager:get_keys_as_string(body_name_list, "", true, false)

	self:print_attribute_error("name", name, supported_values, true, env, nil)
end

function BodyElement:set_motion(env, motion, body)
	local func_name = motion and self.VALID_MOTION_MAP[motion]

	if func_name then
		body[func_name](body)

		if self.SAVE_STATE then
			self:set_cat_state2(body:unit(), body:unit():get_body_index(body:name()), "motion", {
				func_name
			})
		end
	else
		local supported_values = SequenceManager:get_keys_as_string(self.VALID_MOTION_MAP, "", true, true)

		self:print_attribute_error("motion", motion, supported_values, true, env, nil)
	end
end

function BodyElement:set_enabled(env, enabled, body)
	body:set_enabled(enabled)

	if self.SAVE_STATE then
		self:set_cat_state2(body:unit(), body:unit():get_body_index(body:name()), "enabled", {
			"set_enabled",
			enabled
		})
	end
end

function BodyElement:add_ray_type(env, ray_type, body)
	print("BodyElement:add_ray_type", ray_type, body:name())
	body:add_ray_type(Idstring(ray_type))

	if self.SAVE_STATE then
		self:set_cat_state2(body:unit(), body:unit():get_body_index(body:name()), "add_ray_type", {
			"add_ray_type",
			ray_type
		})
	end
end

function BodyElement:remove_ray_type(env, ray_type, body)
	print("BodyElement:remove_ray_type", ray_type, body:name())
	body:remove_ray_type(Idstring(ray_type))

	if self.SAVE_STATE then
		self:set_cat_state2(body:unit(), body:unit():get_body_index(body:name()), "remove_ray_type", {
			"remove_ray_type",
			ray_type
		})
	end
end

function BodyElement:set_body_collision(env, enabled, body)
	body:set_collisions_enabled(enabled)

	if self.SAVE_STATE then
		self:set_cat_state2(body:unit(), body:unit():get_body_index(body:name()), "body_collision", {
			"set_collisions_enabled",
			enabled
		})
	end
end

function BodyElement:set_mover_collision(env, enabled, body)
	body:set_collides_with_mover(enabled)

	if self.SAVE_STATE then
		self:set_cat_state2(body:unit(), body:unit():get_body_index(body:name()), "mover_collision", {
			"set_collides_with_mover",
			enabled
		})
	end
end

function BodyElement:set_pushed_by_mover(env, enabled, body)
	body:set_pushed_by_mover(enabled)

	if self.SAVE_STATE then
		self:set_cat_state2(body:unit(), body:unit():get_body_index(body:name()), "pushed_by_mover", {
			"set_pushed_by_mover",
			enabled
		})
	end
end

function BodyElement:set_mover(env, mover, body)
	local value = mover and self.VALID_MOVER_MAP[mover]

	if value then
		body:set_mover(value)

		if self.SAVE_STATE then
			self:set_cat_state2(body:unit(), body:unit():get_body_index(body:name()), "mover", {
				"set_mover",
				value
			})
		end
	else
		local supported_values = SequenceManager:get_keys_as_string(self.VALID_MOVER_MAP, "", true, true)

		self:print_attribute_error("mover", mover, supported_values, true, env, nil)
	end
end

function BodyElement:interpolate(env, value, body)
	value = tonumber(value)

	if value then
		body:interpolate(value)

		if self.SAVE_STATE then
			self:set_cat_state2(body:unit(), body:unit():get_body_index(body:name()), "interpolate", {
				"interpolate",
				value
			})
		end
	else
		self:print_attribute_error("interpolate", value, nil, true, env, nil)
	end
end

function BodyElement.load(unit, data)
	for body_id, cat_data in pairs(data) do
		for _, sub_data in pairs(cat_data) do
			local body = unit:body(body_id)
			local param = sub_data[2]

			if type(param) == "string" then
				param = Idstring(param)
			end

			body[sub_data[1]](body, param)
		end
	end
end

ConstraintElement = ConstraintElement or class(BaseElement)
ConstraintElement.NAME = "constraint"

function ConstraintElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._name = self:get("name")
	self._enabled = self:get("enabled")
	self._remove = self:get("remove")
end

function ConstraintElement:activate_callback(env)
	local name = self:run_parsed_func(env, self._name)
	local unit = env.dest_unit

	if self._enabled then
		local enabled = self:run_parsed_func(env, self._enabled)

		if enabled then
			unit:enable_constraint(Idstring(name))

			if self.SAVE_STATE then
				self:set_cat_state(unit, name, "enable_constraint")
			end
		else
			unit:disable_constraint(Idstring(name))

			if self.SAVE_STATE then
				self:set_cat_state(unit, name, "disable_constraint")
			end
		end
	end

	if self._remove and self:run_parsed_func(env, self._remove) then
		unit:remove_constraint(name)

		if self.SAVE_STATE then
			self:set_cat_state(unit, name, "remove_constraint")
		end
	end
end

function ConstraintElement.load(unit, data)
	for constraint_name, func_name in pairs(data) do
		unit[func_name](unit, Idstring(constraint_name))
	end
end

DebugElement = DebugElement or class(BaseElement)
DebugElement.NAME = "debug"

function DebugElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._text = self:get("text")
end

function DebugElement:activate_callback(env)
	local text = self:run_parsed_func(env, self._text)

	cat_debug("sequence", "[SequenceManager] " .. tostring(text))
end

AlertElement = AlertElement or class(BaseElement)
AlertElement.NAME = "alert"

function AlertElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._range = self:get("range")
end

function AlertElement:activate_callback(env)
	local range = self:run_parsed_func(env, self._range) or 1200
	local new_alert = {
		"aggression",
		env.pos,
		range,
		managers.groupai:state():get_unit_type_filter("civilians_enemies"),
		env.dest_unit
	}

	managers.groupai:state():propagate_alert(new_alert)
end

AttentionElement = AttentionElement or class(BaseElement)
AttentionElement.NAME = "attention"

function AttentionElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._preset_name = self:get("preset_name")
	self._operation = self:get("operation")
	self._giveaway = self:get("giveaway")
	self._obj_name = self:get("object_name")
end

function AttentionElement:activate_callback(env)
	local operation = self:run_parsed_func(env, self._operation)
	local preset_name = self:run_parsed_func(env, self._preset_name)
	local giveaway = self:run_parsed_func(env, self._giveaway)
	local obj_name = self:run_parsed_func(env, self._obj_name)

	if not env.dest_unit:attention() then
		_G.debug_pause_unit(env.dest_unit, "AttentionElement:activate_callback: unit missing attention extension", env.dest_unit)
	elseif operation == "add" then
		local attention_setting = _G.PlayerMovement._create_attention_setting_from_descriptor(self, _G.tweak_data.attention.settings[preset_name], preset_name)
		attention_setting.giveaway = giveaway

		env.dest_unit:attention():add_attention(attention_setting)

		if obj_name then
			env.dest_unit:attention():set_detection_object_name(obj_name)
		end
	elseif operation == "remove" then
		env.dest_unit:attention():remove_attention(preset_name)
	else
		_G.debug_pause_unit(env.dest_unit, "AttentionElement:activate_callback: operation not 'add' nor 'remove'", operation, env.dest_unit)
	end
end

DecalMeshElement = DecalMeshElement or class(BaseElement)
DecalMeshElement.NAME = "decal_mesh"

function DecalMeshElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._name = self:get("name")
	self._enabled = self:get("enabled")
	self._material = self:get("material")
end

function DecalMeshElement:activate_callback(env)
	local decal_surface = env.dest_unit:decal_surface()

	if not decal_surface then
		self:print_error("The unit didn't have a decal surface.", true, env)
	else
		local name = self:run_parsed_func(env, self._name)

		if not name then
			self:print_attribute_error("name", name, nil, true, env)
		else
			if self._enabled then
				local enabled = self:run_parsed_func(env, self._enabled)

				decal_surface:set_mesh_enabled(Idstring(name), enabled)

				if self.SAVE_STATE then
					self:set_cat_state2(env.dest_unit, name, "set_mesh_enabled", enabled)
				end
			end

			if self._material then
				local material = self:run_parsed_func(env, self._material)

				if material then
					decal_surface:set_mesh_material(Idstring(name), Idstring(material))

					if self.SAVE_STATE then
						self:set_cat_state2(env.dest_unit, name, "set_mesh_material", material)
					end
				else
					self:print_attribute_error("material", material, nil, true, env)
				end
			end
		end
	end
end

function DecalMeshElement.load(unit, data)
	local decal_surface = unit:decal_surface()

	for name, cat_data in pairs(data) do
		for func_name, value in pairs(cat_data) do
			if type(value) == "string" then
				value = Idstring(value)
			end

			decal_surface[func_name](decal_surface, Idstring(name), value)
		end
	end
end

EffectElement = EffectElement or class(BaseElement)
EffectElement.NAME = "effect"

function EffectElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._name = self:get("name")
	self._position = self:get("position")
	self._align = self:get("align")
	self._velocity = self:get("velocity")
	self._parent = self:get("parent")
	self._store_id_list_var = self:get("store_id_list_var")
	self._param_list = {}

	for i = 1, 5 do
		local param = self:get("param" .. i)

		if param then
			table.insert(self._param_list, param)
		else
			break
		end
	end
end

function EffectElement:activate_callback(env)
	local name = self:run_parsed_func(env, self._name)
	local position = self:run_parsed_func(env, self._position)
	local parent = self:run_parsed_func(env, self._parent)

	if not name then
		self:print_attribute_error("name", name, nil, true, env)
	elseif not position and not parent then
		self:print_attribute_error("position", position, nil, true, env)
	elseif DB:has("effect", name) then
		if parent then
			if type(parent) == "string" then
				parent = env.dest_unit:get_object(parent:id())
			elseif parent.type_name ~= "Object3D" then
				parent = nil
			end

			if not parent then
				self:print_attribute_error("parent", parent, nil, true, env)
			end
		end

		local param_map = {
			effect = name:id(),
			parent = parent,
			position = position,
			velocity = self:run_parsed_func(env, self._velocity) or Vector3()
		}
		local align = self:run_parsed_func(env, self._align)

		if align then
			if align.type_name == "Vector3" then
				param_map.normal = align
			elseif align.type_name == "Rotation" then
				param_map.rotation = align
			else
				self:print_attribute_error("align", align, nil, true, env)

				return
			end
		elseif not parent then
			param_map.normal = math.UP
		end

		if Application:editor() then
			CoreEngineAccess._editor_load(Idstring("effect"), param_map.effect)
		end

		local id = World:effect_manager():spawn(param_map)
		local store_id_list_var = self:run_parsed_func(env, self._store_id_list_var)

		if store_id_list_var then
			local store_id_list = env.vars[store_id_list_var]

			if not store_id_list then
				store_id_list = {}
				env.vars[store_id_list_var] = store_id_list
			end

			table.insert(store_id_list, id)

			if #store_id_list == 100 then
				self:print_error("\"store_id_list_var\" contains 100 elements. You aren't using the variable or it spawns too many effects.", true, env, nil)
			end
		end
	elseif not position then
		self:print_attribute_error("position", position, nil, true, env)
	else
		self:print_attribute_error("name", name, nil, true, env)
		Application:error("THIS WILL CRASH SOON, SO FIX IT!\n")
	end
end

EffectSpawnerElement = EffectSpawnerElement or class(BaseElement)
EffectSpawnerElement.NAME = "effect_spawner"

function EffectSpawnerElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._name = self:get("name")
	self._set_function_list = {}
	local enabled = self:get("enabled", self.set_enabled)

	if enabled then
		table.insert(self._set_function_list, enabled)
	end
end

function EffectSpawnerElement:activate_callback(env)
	local name = self:run_parsed_func(env, self._name)

	if name then
		local effect_spawner = env.dest_unit:effect_spawner(name:id())

		if effect_spawner then
			for _, func in ipairs(self._set_function_list) do
				func(env, effect_spawner, name)
			end
		else
			self:print_error("Effect spawner \"" .. tostring(name) .. "\" not found.", true, env)
		end
	else
		self:print_attribute_error("name", name, nil, true, env)
	end
end

function EffectSpawnerElement:set_enabled(env, enabled, effect_spawner, name)
	SequenceManager.set_effect_spawner_enabled(effect_spawner, enabled)

	if self.SAVE_STATE then
		self:set_cat_state2(env.dest_unit, name, "set_enabled", enabled)
	end
end

function EffectSpawnerElement.load(unit, data)
	for effect_surface_name, cat_data in pairs(data) do
		local effect_spawner = unit:effect_spawner(Idstring(effect_surface_name))

		if effect_spawner then
			for func_name, value in pairs(cat_data) do
				if func_name == "set_enabled" then
					SequenceManager.set_effect_spawner_enabled(effect_spawner, value)
				end
			end
		end
	end
end

EnemyKilledElement = EnemyKilledElement or class(BaseElement)
EnemyKilledElement.NAME = "enemy_killed"

function EnemyKilledElement:activate_callback(env)
	local enemy_data = env.dest_unit:enemy_data()

	if not enemy_data then
		self:print_error("Unable to report enemy kill. Unit \"" .. env.dest_unit:name() .. "\" doesn't have a \"enemy_data\" extension.", true, env)
	else
		local group = enemy_data.enemy_group

		if group then
			group:unit_killed()
		end
	end
end

FunctionElement = FunctionElement or class(BaseElement)
FunctionElement.NAME = "function"

function FunctionElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._obj = self:get("object")
	self._extension = self:get("extension")
	self._function_name = self:get("function")
	self._param1 = self:get("param1")

	if self._param1 == nil then
		self._function = self.function0
	else
		self._param2 = self:get("param2")

		if self._param2 == nil then
			self._function = self.function1
		else
			self._param3 = self:get("param3")

			if self._param3 == nil then
				self._function = self.function2
			else
				self._param4 = self:get("param4")

				if self._param4 == nil then
					self._function = self.function3
				else
					self._param5 = self:get("param5")

					if self._param5 == nil then
						self._function = self.function4
					else
						self._function = self.function5
					end
				end
			end
		end
	end
end

function FunctionElement:activate_callback(env)
	local target = self:run_parsed_func(env, self._obj)
	local extension = self:run_parsed_func(env, self._extension)
	local function_name = self:run_parsed_func(env, self._function_name)

	if target == nil then
		target = env.dest_unit

		if not alive(target) then
			return
		end
	end

	if extension and target[extension] then
		target = target[extension](target)
		SequenceEnvironment.self = env
		SequenceEnvironment.element = self

		if not target then
			self:print_attribute_error("extension", extension, nil, true, env, nil)

			return
		end
	end

	local func = function_name and target[function_name]

	if func then
		self:_function(env, target, func)
	else
		self:print_attribute_error("function", function_name, nil, true, env, nil)
	end
end

function FunctionElement:function0(env, target, func)
	func(target)
end

function FunctionElement:function1(env, target, func)
	local param1 = self:run_parsed_func(env, self._param1)

	func(target, param1)
end

function FunctionElement:function2(env, target, func)
	local param1 = self:run_parsed_func(env, self._param1)
	local param2 = self:run_parsed_func(env, self._param2)

	func(target, param1, param2)
end

function FunctionElement:function3(env, target, func)
	local param1 = self:run_parsed_func(env, self._param1)
	local param2 = self:run_parsed_func(env, self._param2)
	local param3 = self:run_parsed_func(env, self._param3)

	func(target, param1, param2, param3)
end

function FunctionElement:function4(env, target, func)
	local param1 = self:run_parsed_func(env, self._param1)
	local param2 = self:run_parsed_func(env, self._param2)
	local param3 = self:run_parsed_func(env, self._param3)
	local param4 = self:run_parsed_func(env, self._param4)

	func(target, param1, param2, param3, param4)
end

function FunctionElement:function5(env, target, func)
	local param1 = self:run_parsed_func(env, self._param1)
	local param2 = self:run_parsed_func(env, self._param2)
	local param3 = self:run_parsed_func(env, self._param3)
	local param4 = self:run_parsed_func(env, self._param4)
	local param5 = self:run_parsed_func(env, self._param5)

	func(target, param1, param2, param3, param4, param5)
end

GraphicGroupElement = GraphicGroupElement or class(BaseElement)
GraphicGroupElement.NAME = "graphic_group"

function GraphicGroupElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._name = self:get("name")
	self._activate = self:get("activate")
	self._visibility = self:get("visibility")
end

function GraphicGroupElement:activate_callback(env)
	local name = self:run_parsed_func(env, self._name)
	local activate = self:run_parsed_func(env, self._activate) ~= false
	local visibility = self:run_parsed_func(env, self._visibility)

	if activate then
		env.dest_unit:activate_graphic_group(Idstring(name))

		if self.SAVE_STATE then
			self:set_cat_state(env.dest_unit, name, {
				"activate_graphic_group"
			})
		end
	end

	if visibility ~= nil then
		env.dest_unit:set_visibility(Idstring(name), visibility)

		if self.SAVE_STATE then
			self:set_cat_state(env.dest_unit, name, {
				"set_visibility",
				visibility
			})
		end
	end
end

function GraphicGroupElement.load(unit, data)
	for name, sub_data in pairs(data) do
		unit[sub_data[1]](unit, Idstring(name), sub_data[2])
	end
end

LightElement = LightElement or class(BaseElement)
LightElement.NAME = "light"

function LightElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._name = self:get("name")
	self._set_functions = {}
	local enabled = self:get("enabled", self.set_enabled)

	if enabled then
		table.insert(self._set_functions, enabled)
	end

	local multiplier = self:get("multiplier", self.set_multiplier)

	if multiplier then
		table.insert(self._set_functions, multiplier)
	end

	local color = self:get("color", self.set_color)

	if color then
		table.insert(self._set_functions, color)
	end

	local far_range = self:get("far_range", self.set_far_range)

	if far_range then
		table.insert(self._set_functions, far_range)
	end

	local spot_angle_end = self:get("spot_angle_end", self.set_spot_angle_end)

	if spot_angle_end then
		table.insert(self._set_functions, spot_angle_end)
	end

	local spot_angle_start = self:get("spot_angle_start", self.set_spot_angle_start)

	if spot_angle_start then
		table.insert(self._set_functions, spot_angle_start)
	end
end

function LightElement:activate_callback(env)
	local name = self:run_parsed_func(env, self._name)
	local light_obj = name and env.dest_unit:get_object(name:id())

	if light_obj and light_obj.set_multiplier then
		for _, func in ipairs(self._set_functions) do
			func(env, light_obj, name)
		end
	else
		self:print_attribute_error("name", name, nil, true, env, nil)
	end
end

function LightElement:set_enabled(env, enabled, light_obj, name)
	light_obj:set_enable(enabled)

	if self.SAVE_STATE then
		self:set_cat_state(env.dest_unit, name, {
			"set_enable",
			enabled
		})
	end

	for _, child in ipairs(light_obj:children()) do
		child:set_visibility(enabled)

		if self.SAVE_STATE then
			self:set_cat_state(env.dest_unit, child:name(), {
				"set_visibility",
				enabled
			})
		end
	end
end

function LightElement:set_multiplier(env, multiplier, light_obj, name)
	light_obj:set_multiplier(multiplier)

	if self.SAVE_STATE then
		self:set_cat_state(env.dest_unit, name, {
			"set_multiplier",
			multiplier
		})
	end
end

function LightElement:set_color(env, color, light_obj, name)
	light_obj:set_color(color)

	if self.SAVE_STATE then
		self:set_cat_state(env.dest_unit, name, {
			"set_color",
			color
		})
	end
end

function LightElement:set_far_range(env, far_range, light_obj, name)
	light_obj:set_far_range(far_range)

	if self.SAVE_STATE then
		self:set_cat_state(env.dest_unit, name, {
			"set_far_range",
			far_range
		})
	end
end

function LightElement:set_spot_angle_start(env, spot_angle_start, light_obj, name)
	light_obj:set_spot_angle_start(spot_angle_start)

	if self.SAVE_STATE then
		self:set_cat_state(env.dest_unit, name, {
			"set_spot_angle_start",
			spot_angle_start
		})
	end
end

function LightElement:set_spot_angle_end(env, spot_angle_end, light_obj, name)
	light_obj:set_spot_angle_end(spot_angle_end)

	if self.SAVE_STATE then
		self:set_cat_state(env.dest_unit, name, {
			"set_spot_angle_end",
			spot_angle_end
		})
	end
end

function LightElement.load(unit, data)
	for obj_name, sub_data in pairs(data) do
		local obj = unit:get_object(obj_name:id())

		obj[sub_data[1]](obj, sub_data[2])
	end
end

MaterialConfigElement = MaterialConfigElement or class(BaseElement)
MaterialConfigElement.NAME = "material_config"

function MaterialConfigElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._name = self:get("name")
	self._synchronous = self:get("synchronous")
end

function MaterialConfigElement:activate_callback(env)
	local name = self:run_parsed_func(env, self._name)
	local synchronous = self:run_parsed_func(env, self._synchronous)

	if not name then
		self:print_attribute_error("name", name, nil, true, env)
	else
		managers.dyn_resource:change_material_config(Idstring(name), env.dest_unit, synchronous)

		if self.SAVE_STATE then
			self:set_cat_state(env.dest_unit, "material", Idstring(name))
		end
	end
end

function MaterialConfigElement.load(unit, data)
	managers.dyn_resource:change_material_config(data.material, unit)
end

MaterialElement = MaterialElement or class(BaseElement)
MaterialElement.NAME = "material"
MaterialElement.MATERIAL_ATTRIBUTE_MAP = MaterialElement.MATERIAL_ATTRIBUTE_MAP or {
	diffuse_color = true,
	name = true,
	diffuse_color_alpha = true
}
MaterialElement.FUNC_MAP = MaterialElement.FUNC_MAP or {
	time = "set_time",
	state = "set_material_state",
	render_template = "set_render_template",
	glossiness = "set_glossiness"
}
MaterialElement.TIMER_STATE_MAP = MaterialElement.TIMER_STATE_MAP or {
	stop = 0,
	play = 1,
	pause = 0
}

function MaterialElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._name = self:get("name")
	self._diffuse_color = self:get("diffuse_color")
	self._diffuse_color_alpha = self:get("diffuse_color_alpha")
	self._set_func_list = {}

	for key, value in pairs(self._parameters) do
		local func_name = self.FUNC_MAP[key]
		local func = nil

		if func_name then
			func = self:get(key, self[func_name])
		elseif not self.BASE_ATTRIBUTE_MAP[key] and not self.MATERIAL_ATTRIBUTE_MAP[key] then
			func = self:get(key, self.set_variable)
		end

		if func then
			self._set_func_list[key] = func
		end
	end
end

function MaterialElement:activate_callback(env)
	local name = self:run_parsed_func(env, self._name)

	if not name then
		self:print_attribute_error("name", name, nil, true, env)
	else
		local material = env.dest_unit:material(name:id())

		if material then
			for key, func in pairs(self._set_func_list) do
				func(env, material, key)
			end

			local color = self:run_parsed_func(env, self._diffuse_color)
			local alpha = self:run_parsed_func(env, self._diffuse_color_alpha)

			if color or alpha then
				material:set_diffuse_color(color or material:diffuse_color(), alpha or material:diffuse_color_alpha())
			end
		else
			self:print_error("Invalid material name \"" .. tostring(name) .. "\".", true, env)
		end
	end
end

function MaterialElement:set_glossiness(env, glossiness, material)
	material:set_glossiness(glossiness)
end

function MaterialElement:set_render_template(env, render_template, material)
	material:set_render_template(render_template)
end

function MaterialElement:set_time(env, time, material)
	material:set_time(time)
end

function MaterialElement:set_variable(env, value, material, key)
	material:set_variable(Idstring(key), value)
end

function MaterialElement:set_material_state(env, state, material)
	local args = string.split(state, " ")
	state = args[1]

	table.remove(args, 1)

	for i, arg in ipairs(args) do
		args[i] = tonumber(arg)
	end

	if state and self.TIMER_STATE_MAP[state] then
		for i = #args, self.TIMER_STATE_MAP[state] - 1 do
			table.insert(args, 1)
		end

		material[state](material, unpack(args))
	else
		local supported_values = SequenceManager:get_keys_as_string(self.TIMER_STATE_MAP, "", true)

		self:print_attribute_error("state", state, supported_values, true, env, nil)
	end
end

MorphExpressionElement = MorphExpressionElement or class(BaseElement)
MorphExpressionElement.NAME = "morph_expression"

function MorphExpressionElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._model = self:get("model")
	self._parameters = {}

	for i = 1, 3 do
		local expression = self:get("expression" .. i)
		local weight = self:get("weight" .. i)

		if expression and weight then
			table.insert(self._parameters, expression)
			table.insert(self._parameters, weight)
		end
	end

	if #self._parameters == 0 then
		self:print_error("No expressions or weights defined.", false, nil)
	end
end

function MorphExpressionElement:activate_callback(env)
	local model = self:run_parsed_func(env, self._model)

	if model then
		local parameters = self:run_parsed_func_list(env, self._parameters)

		env.dest_unit:set_morph_target_expressions(model, unpack(parameters))
	else
		self:print_attribute_error("model", model, nil, true, env)
	end
end

MorphExpressionMovieElement = MorphExpressionMovieElement or class(BaseElement)
MorphExpressionMovieElement.NAME = "morph_expression_movie"

function MorphExpressionMovieElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._model = self:get("model")
	self._movie = self:get("movie")
	self._loop = self:get("loop")
end

function MorphExpressionMovieElement:activate_callback(env)
	local model = self:run_parsed_func(env, self._model)
	local movie = self:run_parsed_func(env, self._movie)

	if not model then
		self:print_attribute_error("model", model, nil, true, env)
	elseif not movie then
		self:print_attribute_error("movie", movie, nil, true, env)
	else
		local loop = self:run_parsed_func(env, self._loop)

		managers.expression:play(env.dest_unit, model, movie, loop)
	end
end

ObjectElement = ObjectElement or class(BaseElement)
ObjectElement.NAME = "object"

function ObjectElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._set_function_list = {}
	self._name = self:get("name")
	local visible = self:get("enabled", self.set_visibility)

	if visible then
		table.insert(self._set_function_list, visible)
	end

	local rotation = self:get("rotation", self.set_rotation)

	if rotation then
		table.insert(self._set_function_list, rotation)
	end

	local position = self:get("position", self.set_position)

	if position then
		table.insert(self._set_function_list, position)
	end

	self._local_scope = self:get("local_scope")
end

function ObjectElement:activate_callback(env)
	local name = self:run_parsed_func(env, self._name)

	if name then
		local object_list = {
			env.dest_unit:get_object(Idstring(name))
		}
		local local_scope = self:run_parsed_func(env, self._local_scope)

		for _, func in ipairs(self._set_function_list) do
			func(env, object_list, local_scope)
		end
	else
		self:print_attribute_error("name", name, nil, true, env)
	end
end

function ObjectElement:set_visibility(env, visible, object_list, local_scope)
	self:set_object(env.dest_unit, object_list, "set_visibility", visible)
end

function ObjectElement:set_position(env, position, object_list, local_scope)
	local func_name = nil

	if local_scope then
		func_name = "set_local_position"
	else
		func_name = "set_position"
	end

	self:set_object(env.dest_unit, object_list, func_name, position)
end

function ObjectElement:set_rotation(env, rotation, object_list, local_scope)
	local func_name = nil

	if local_scope then
		func_name = "set_local_rotation"
	else
		func_name = "set_rotation"
	end

	self:set_object(env.dest_unit, object_list, func_name, rotation)
end

function ObjectElement:set_object(dest_unit, object_list, func_name, value)
	for _, obj in ipairs(object_list) do
		obj[func_name](obj, value)

		if self.SAVE_STATE then
			self:set_cat_state2(dest_unit, obj:name(), func_name, {
				obj:name(),
				value
			})
		end
	end
end

function ObjectElement.load(unit, data)
	for name, sub_data in pairs(data) do
		for func_name, values in pairs(sub_data) do
			local obj = unit:get_object(values[1])

			obj[func_name](obj, values[2])
		end
	end
end

PhantomElement = PhantomElement or class(BaseElement)
PhantomElement.NAME = "phantom"

function PhantomElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._name = self:get("name")
	self._enabled = self:get("enabled")
end

function PhantomElement:activate_callback(env)
	local name = self:run_parsed_func(env, self._name)
	local phantom = env.dest_unit:phantom(name)

	if phantom then
		local enabled = self:run_parsed_func(env, self._enabled)

		phantom:set_enabled(enabled)

		if self.SAVE_STATE then
			self:set_cat_state(env.dest_unit, name, enabled)
		end
	else
		self:print_attribute_error("name", name, nil, true, env, nil)
	end
end

function PhantomElement.load(unit, data)
	for name, enabled in pairs(data) do
		local phantom = unit:phantom(name)

		phantom:set_enabled(enabled)
	end
end

PhysicEffectElement = PhysicEffectElement or class(BaseElement)
PhysicEffectElement.NAME = "physic_effect"

function PhysicEffectElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._name = self:get("name")
	self._target = self:get("target")
	self._store_id_var = self:get("store_id_var")
	self._param_list = {}

	for i = 1, 5 do
		self._param_list[i] = self:get("param" .. i)

		if not self._param_list[i] then
			break
		end
	end
end

function PhysicEffectElement:activate_callback(env)
	local name = self:run_parsed_func(env, self._name)
	local target = self:run_parsed_func(env, self._target)
	local param_list = self:run_parsed_func_list(env, self._param_list)
	local store_id_var = self:run_parsed_func(env, self._store_id_var) or "last_physic_effect_id"
	env.vars[store_id_var] = World:play_physic_effect(Idstring(name), target, unpack(param_list))
end

ProjectDecalElement = ProjectDecalElement or class(BaseElement)
ProjectDecalElement.NAME = "project_decal"

function ProjectDecalElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._name = self:get("name")
	self._position = self:get("position")
	self._direction = self:get("direction")
	self._decal_x = self:get("decal_x")
	self._normal = self:get("normal")
	self._slotmask = self:get("slotmask")
	self._ray_distance = self:get("ray_distance")
	self._play_effect = self:get("play_effect")
	self._ignore_unit = self:get("ignore_unit")
end

function ProjectDecalElement:activate_callback(env)
	local name = self:run_parsed_func(env, self._name)
	local position = self:run_parsed_func(env, self._position)
	local direction = self:run_parsed_func(env, self._direction)
	local slotmask = self._slotmask and managers.slot:get_mask(self:run_parsed_func(env, self._slotmask))

	if not name then
		self:print_attribute_error("name", name, nil, true, env)
	elseif not position then
		self:print_attribute_error("position", position, nil, true, env)
	elseif not direction then
		self:print_attribute_error("direction", direction, nil, true, env)
	elseif not slotmask then
		local supported_values = SequenceManager:get_keys_as_string(managers.slot:get_mask_map(), "", true, false)

		self:print_attribute_error("slotmask", slotmask, supported_values, true, env)
	else
		direction = direction:normalized()
		local ray_distance = self:run_parsed_func(env, self._ray_distance)
		local normal = self:run_parsed_func(env, self._normal)
		local ignore_unit = self:run_parsed_func(env, self._ignore_unit)

		if not alive(ignore_unit) then
			ignore_unit = nil
		end

		if ray_distance then
			local ray = (ignore_unit or World):raycast("ray", position, position + direction * ray_distance, "slot_mask", slotmask)

			if ray then
				position = ray.position
				normal = normal or ray.normal
			else
				return
			end
		end

		local arg_list = {}

		table.insert(arg_list, self:run_parsed_func(env, self._decal_x))
		table.insert(arg_list, normal)
		table.insert(arg_list, ignore_unit)
		table.insert(arg_list, slotmask)

		local effect = World:project_decal(name, position, direction, unpack(arg_list))

		if #effect > 0 and self:run_parsed_func(env, self._play_effect) then
			World:effect_manager():spawn({
				effect = effect,
				position = position,
				normal = normal or math.UP
			})
		end
	end
end

RemoveStartTimeElement = RemoveStartTimeElement or class(BaseElement)
RemoveStartTimeElement.NAME = "remove_start_time"

function RemoveStartTimeElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._id = self:get("id")
end

function RemoveStartTimeElement:activate_callback(env)
	local id = self:run_parsed_func(env, self._id)

	if id then
		managers.sequence:_remove_start_time_callback(id)
	end
end

RunSequenceElement = RunSequenceElement or class(BaseElement)
RunSequenceElement.RUN_SEQUENCE_ATTRIBUTE_MAP = RunSequenceElement.RUN_SEQUENCE_ATTRIBUTE_MAP or {
	name = true
}
RunSequenceElement.NAME = "run_sequence"

function RunSequenceElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._name = self:get("name")
	self._params = {}

	for k, v in pairs(self._parameters) do
		if not self.BASE_ATTRIBUTE_MAP[k] and not self.RUN_SEQUENCE_ATTRIBUTE_MAP[k] then
			self._params[k] = self:get(k)
		end
	end
end

function RunSequenceElement:activate_callback(env)
	local sequence_name = self:run_parsed_func(env, self._name)

	if sequence_name and sequence_name ~= "" then
		local sequence = self._unit_element:get_sequence_element(sequence_name)

		if sequence then
			local old_params = env.params
			env.params = CoreTable.clone(env.params)

			for k, v in pairs(self._params) do
				if not env.__run_params[k] then
					env.params[k] = self:run_parsed_func(env, v)
				end
			end

			sequence:activate(env)

			env.params = old_params
		else
			local supported_values = SequenceManager:get_keys_as_string(self._unit_element:get_sequence_name_list(), "", true, true)

			self:print_attribute_error("name", sequence_name, supported_values, true, env, nil)
		end
	end
end

RunSpawnSystemSequenceElement = RunSpawnSystemSequenceElement or class(BaseElement)
RunSpawnSystemSequenceElement.NAME = "run_spawn_system_sequence"

function RunSpawnSystemSequenceElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._socket_name = self:get("socket")
	self._unit_name = self:get("unit")
	self._sequence_name = self:get("sequence")
end

function RunSpawnSystemSequenceElement:activate_callback(env)
	local socket_name = self:run_parsed_func(env, self._socket_name)
	local unit_name = self:run_parsed_func(env, self._unit_name)
	local sequence_name = self:run_parsed_func(env, self._sequence_name)

	if not socket_name then
		self:print_attribute_error("socket", socket_name, nil, false, env)
	elseif not unit_name then
		self:print_attribute_error("unit", unit_name, nil, false, env)
	elseif not sequence_name then
		self:print_attribute_error("sequence", sequence_name, nil, false, env)
	else
		local spawn_system_ext = env.dest_unit:spawn_system()

		if spawn_system_ext then
			local unit = spawn_system_ext:get_child_unit(socket_name, unit_name)

			if alive(unit) then
				local damage_ext = unit:damage()

				if damage_ext then
					damage_ext:run_sequence_simple(sequence_name)
				else
					self:print_error("No damage extension found on unit \"" .. tostring(unit) .. "\".", true, env)
				end
			end
		else
			self:print_error("No spawn_system extension found on unit \"" .. tostring(env.dest_unit) .. "\".", true, env)
		end
	end
end

SetDamageElement = SetDamageElement or class(BaseElement)
SetDamageElement.NAME = "set_damage"

function SetDamageElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._damage = {}
	self._set_functions = {}

	for k, v in pairs(self._parameters) do
		self._damage[k] = self:get(k, self.set_damage)
	end
end

function SetDamageElement:activate_callback(env)
	if alive(env.dest_body) then
		if env.dest_body:extension() and env.dest_body:extension().damage then
			for k, func in pairs(self._damage) do
				func(env, k)
			end
		else
			self:print_error("Unable to set body damage on unit \"" .. tostring(env.dest_unit) .. "\" with body \"" .. env.dest_body:name() .. "\" since it didn't have a damage extension on the body.", true, env)
		end
	else
		self:print_error("Unable to set body damage on destroyed body. This is probably because a scripter didn't specify a body when a sequence was executed or if it was executed from a sequence that had \"startup\" attribute set to true or if the sequence was triggered from a water element.", true, env)
	end
end

function SetDamageElement:set_damage(env, damage, damage_type)
	local extension = env.dest_body:extension().damage

	extension:set_damage(damage_type, damage)
end

SetExtensionVarElement = SetExtensionVarElement or class(BaseElement)
SetExtensionVarElement.NAME = "set_extension_var"

function SetExtensionVarElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._name = self:get("name")
	self._variable = self:get("variable")
	self._value = self:get("value")
end

function SetExtensionVarElement:activate_callback(env)
	local name = self:run_parsed_func(env, self._name)
	local extension = name and env.dest_unit[name](env.dest_unit)

	if not extension then
		local supported_values = SequenceManager:get_keys_as_string(env.dest_unit:extensions(), "", true, true)

		self:print_attribute_error("name", name, supported_values, true, env)
	else
		local variable = self:run_parsed_func(env, self._variable)

		if not variable then
			self:print_attribute_error("variable", variable, nil, true, env)
		else
			local value = self:run_parsed_func(env, self._value)
			extension[variable] = value
		end
	end
end

SetGlobalVariableElement = SetGlobalVariableElement or class(BaseElement)
SetGlobalVariableElement.NAME = "set_global_variable"

function SetGlobalVariableElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._name = self:get("name")
	self._value = self:get("value")
end

function SetGlobalVariableElement:activate_callback(env)
	local name = self:run_parsed_func(env, self._name)

	if name then
		local value = self:run_parsed_func(env, self._value)

		self:set_variable(env, name, value)
	else
		self:print_attribute_error("name", name, nil, true, env)
	end
end

function SetGlobalVariableElement:set_variable(env, name, value)
	env.g_vars[name] = value
	self._unit_element._global_vars[name] = value
end

SetGlobalVariablesElement = SetGlobalVariablesElement or class(BaseElement)
SetGlobalVariablesElement.NAME = "set_global_variables"

function SetGlobalVariablesElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._variables = {}

	for name, value in pairs(self._parameters) do
		if not self.BASE_ATTRIBUTE_MAP[name] then
			self._variables[name] = self:get(name)
		end
	end
end

function SetGlobalVariablesElement:activate_callback(env)
	for name, value in pairs(self._variables) do
		self:set_variable(env, name, self:run_parsed_func(env, value))
	end
end

function SetGlobalVariablesElement:set_variable(env, name, value)
	env.g_vars[name] = value
	self._unit_element._global_vars[name] = value
end

SetInflictElement = SetInflictElement or class(BaseElement)
SetInflictElement.NAME = "set_inflict"

function SetInflictElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._body_name = self:get("body")
	self._damage_type = self:get("type")
	self._set_func_list = {
		damage = self:get("damage"),
		interval = self:get("interval"),
		instant = self:get("instant"),
		enabled = self:get("enabled"),
		fire_object = self:get("fire_object"),
		fire_height = self:get("fire_height"),
		velocity = self:get("velocity"),
		falloff = self:get("falloff")
	}
end

function SetInflictElement:activate_callback(env)
	local body_name = self:run_parsed_func(env, self._body_name)
	local body = body_name and env.dest_unit:body(body_name)
	local body_ext = body and body:extension()
	local damage_ext = body_ext and body_ext.damage

	if damage_ext then
		local damage_type = self:run_parsed_func(env, self._damage_type)

		for name, value in pairs(self._set_func_list) do
			local parsed_value = self:run_parsed_func(env, value)
			local valid_value, valid_damage_type = damage_ext:set_inflict_attribute(damage_type, name, parsed_value)

			if not valid_damage_type then
				local supported_values = SequenceManager:get_keys_as_string(managers.sequence:get_inflict_element_class_map(), "", true, false)

				self:print_attribute_error("type", damage_type, supported_values, true, env)
			elseif not valid_value then
				self:print_attribute_error(name, parsed_value, nil, true, env)
			end
		end
	else
		self:print_attribute_error("body", body_name, nil, true, env)
	end
end

SetPhysicEffectElement = SetPhysicEffectElement or class(BaseElement)
SetPhysicEffectElement.NAME = "set_physic_effect"

function SetPhysicEffectElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._id = self:get("id")
	self._param_list = {}

	for i = 1, 5 do
		self._param_list[i] = self:get("param" .. i)
	end

	self._body_list = {}
	self._center_of_mass = {}
	self._offset_list = {}

	for i = 1, 5 do
		self._body_list[i] = self:get("body" .. i)

		if self._body_list[i] then
			self._center_of_mass_list[i] = self:get("center" .. i)
			self._offset_list[i] = self:get("offset" .. i)
		end
	end
end

function SetPhysicEffectElement:activate_callback(env)
	local id = self:run_parsed_func(env, self._id) or env.vars.last_physic_effect_id

	if not id then
		self:print_attribute_error("id", id, nil, true, env)
	else
		for i, param in pairs(self._param_list) do
			local parsed_param = self:run_parsed_func(env, param)

			World:set_physic_effect_parameter(id, i, parsed_param)
		end

		for i, body in pairs(self._body_list) do
			local parsed_body = self:run_parsed_func(env, body)
			local center_of_mass = self:run_parsed_func(env, self._center_of_mass[i])
			local offset = self:run_parsed_func(env, self._offset_list[i])

			World:set_physic_effect_parameter(id, i, parsed_body, center_of_mass, offset)
		end
	end
end

SetProximityElement = SetProximityElement or class(BaseElement)
SetProximityElement.NAME = "set_proximity"

function SetProximityElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._name = self:get("name")
	self._set_func_list = {}
	local enabled = self:get("enabled", self.set_enabled)

	if enabled then
		table.insert(self._set_func_list, enabled)
	end

	local proximity_type = self:get("type", self.set_type)

	if proximity_type then
		table.insert(self._set_func_list, proximity_type)
	end

	local ref_object = self:get("ref_object", self.set_ref_object)

	if ref_object then
		table.insert(self._set_func_list, ref_object)
	end

	local interval = self:get("interval", self.set_interval)

	if interval then
		table.insert(self._set_func_list, interval)
	end

	local quick = self:get("quick", self.set_quick)

	if quick then
		table.insert(self._set_func_list, quick)
	end

	local is_within = self:get("is_within", self.set_is_within)

	if is_within then
		table.insert(self._set_func_list, is_within)
	end

	local within_activations = self:get("within_activations", self.set_within_activations)

	if within_activations then
		table.insert(self._set_func_list, within_activations)
	end

	local within_max_activations = self:get("within_max_activations", self.set_within_max_activations)

	if within_max_activations then
		table.insert(self._set_func_list, within_max_activations)
	end

	local within_delay = self:get("within_delay", self.set_within_delay)

	if within_delay then
		table.insert(self._set_func_list, within_delay)
	end

	local within_range = self:get("within_range", self.set_within_range)

	if within_range then
		table.insert(self._set_func_list, within_range)
	end

	local within_count = self:get("within_count", self.set_within_count)

	if within_count then
		table.insert(self._set_func_list, within_count)
	end

	local outside_activations = self:get("outside_activations", self.set_outside_activations)

	if outside_activations then
		table.insert(self._set_func_list, outside_activations)
	end

	local outside_max_activations = self:get("outside_max_activations", self.set_outside_max_activations)

	if outside_max_activations then
		table.insert(self._set_func_list, outside_max_activations)
	end

	local outside_delay = self:get("outside_delay", self.set_outside_delay)

	if outside_delay then
		table.insert(self._set_func_list, outside_delay)
	end

	local outside_range = self:get("outside_range", self.set_outside_range)

	if outside_range then
		table.insert(self._set_func_list, outside_range)
	end

	local outside_count = self:get("outside_count", self.set_outside_count)

	if outside_count then
		table.insert(self._set_func_list, outside_count)
	end
end

function SetProximityElement:activate_callback(env)
	local name = self:run_parsed_func(env, self._name)
	local proximity_map = env.dest_unit:damage():get_proximity_map()

	if name and proximity_map[name] then
		for _, func in ipairs(self._set_func_list) do
			func(env, name)
		end
	else
		local supported_values = SequenceManager:get_keys_as_string(proximity_map, "", true, true)

		self:print_attribute_error("name", name, supported_values, true, env)
	end
end

function SetProximityElement:set_enabled(env, enabled, name)
	env.dest_unit:damage():set_proximity_enabled(name, enabled == true)
end

function SetProximityElement:set_type(env, proximity_type, name)
	local slotmask = managers.sequence:get_proximity_mask(proximity_type)

	if slotmask then
		env.dest_unit:damage():set_proximity_slotmask(name, slotmask)
	else
		local supported_values = SequenceManager:get_keys_as_string(managers.sequence:get_proximity_mask_map(), "", true, false)

		self:print_attribute_error("type", proximity_type, supported_values, true, env)
	end
end

function SetProximityElement:set_ref_obj_name(env, ref_obj_name, name)
	damage_ext:set_proximity_ref_obj_name(name, ref_obj_name)
end

function SetProximityElement:set_interval(env, interval, name)
	env.dest_unit:damage():set_proximity_interval(name, math.min(tonumber(interval) or 0, ProximityTypeElement.MIN_INTERVAL))
end

function SetProximityElement:set_quick(env, quick, name)
	env.dest_unit:damage():set_proximity_quick(name, quick ~= false)
end

function SetProximityElement:set_is_within(env, is_within, name)
	env.dest_unit:damage():set_proximity_is_within(name, is_within == true)
end

function SetProximityElement:set_within_activations(env, activations, name)
	env.dest_unit:damage():set_proximity_within_activations(name, tonumber(activations) or 0)
end

function SetProximityElement:set_within_max_activations(env, max_activations, name)
	env.dest_unit:damage():set_proximity_within_max_activations(name, tonumber(max_activations) or -1)
end

function SetProximityElement:set_within_delay(env, delay, name)
	env.dest_unit:damage():set_proximity_within_delay(name, tonumber(delay) or 0)
end

function SetProximityElement:set_within_range(env, range, name)
	env.dest_unit:damage():set_proximity_within_range(name, max(tonumber(range) or 0, 0))
end

function SetProximityElement:set_inside_count(env, count, name)
	env.dest_unit:damage():set_proximity_inside_count(name, tonumber(count) or -1)
end

function SetProximityElement:set_outside_activations(env, activations, name)
	env.dest_unit:damage():set_proximity_outside_activations(name, tonumber(activations) or 0)
end

function SetProximityElement:set_outside_max_activations(env, max_activations, name)
	env.dest_unit:damage():set_proximity_outside_max_activations(name, tonumber(max_activations) or -1)
end

function SetProximityElement:set_outside_delay(env, delay, name)
	env.dest_unit:damage():set_proximity_outside_delay(name, tonumber(delay) or 0)
end

function SetProximityElement:set_outside_range(env, range, name)
	env.dest_unit:damage():set_proximity_outside_range(name, max(tonumber(range) or 0, 0))
end

function SetProximityElement:set_outside_count(env, count, name)
	env.dest_unit:damage():set_proximity_outside_count(name, tonumber(count) or -1)
end

SetSaveDataElement = SetSaveDataElement or class(BaseElement)
SetSaveDataElement.NAME = "set_save_data"
SetSaveDataElement.SET_SAVE_DATA_ATTRIBUTE_MAP = SetSaveDataElement.SET_SAVE_DATA_ATTRIBUTE_MAP or {
	unique = true
}

function SetSaveDataElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._unique = self:get("unique")
	self._variables = {}

	for name, value in pairs(self._parameters) do
		if not self.BASE_ATTRIBUTE_MAP[name] and not self.SET_SAVE_DATA_ATTRIBUTE_MAP[name] then
			self._variables[name] = self:get(name)
		end
	end
end

function SetSaveDataElement:activate_callback(env)
	local unique = self:run_parsed_func(env, self._unique)

	for name, value in pairs(self._variables) do
		value = self:run_parsed_func(env, value)

		if unique then
			env.set_unique_save_data(name, value)
		else
			env.g_save_data[name] = value
		end
	end
end

SpawnSystemUnitEnabledElement = SpawnSystemUnitEnabledElement or class(BaseElement)
SpawnSystemUnitEnabledElement.NAME = "set_spawn_system_unit_enabled"

function SpawnSystemUnitEnabledElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._socket_name = self:get("socket")
	self._unit_name = self:get("unit")
	self._enabled = self:get("enabled")
end

function SpawnSystemUnitEnabledElement:activate_callback(env)
	local socket_name = self:run_parsed_func(env, self._socket_name)
	local unit_name = self:run_parsed_func(env, self._unit_name)
	local enabled = self:run_parsed_func(env, self._enabled)

	if not socket_name then
		self:print_attribute_error("socket", socket_name, nil, false, env)
	elseif not unit_name then
		self:print_attribute_error("unit", unit_name, nil, false, env)
	else
		local spawn_system_ext = env.dest_unit:spawn_system()

		if spawn_system_ext then
			local unit = spawn_system_ext:set_unit_enabled(socket_name, unit_name, enabled)
		else
			self:print_error("No spawn_system extension found on unit \"" .. tostring(env.dest_unit) .. "\".", true, env)
		end
	end
end

SetVariableElement = SetVariableElement or class(SetGlobalVariableElement)
SetVariableElement.NAME = "set_variable"

function SetVariableElement:set_variable(env, name, value)
	env.vars = env.dest_unit:damage():set_variable(name, value)
end

SetVariablesElement = SetVariablesElement or class(SetGlobalVariablesElement)
SetVariablesElement.NAME = "set_variables"

function SetVariablesElement:set_variable(env, name, value)
	env.vars = env.dest_unit:damage():set_variable(name, value)
end

SetWaterElement = SetWaterElement or class(BaseElement)
SetWaterElement.NAME = "set_water"

function SetWaterElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._name = self:get("name")
	self._enabled = self:get("enabled")
	self._interval = self:get("interval")
	self._ref_object_name = self:get("ref_object")
	self._ref_body_name = self:get("ref_body")
	self._body_depth = self:get("body_depth")
	self._physic_effect = self:get("physic_effect")
end

function SetWaterElement:activate_callback(env)
	local name = self:run_parsed_func(env, self._name)

	if name then
		local damage_ext = env.dest_unit:damage()
		local enabled = nil
		local interval = tonumber(self:run_parsed_func(env, self._interval)) or 1
		local ref_object_name = self:run_parsed_func(env, self._ref_object_name)
		local ref_body_name = self:run_parsed_func(env, self._ref_body_name)
		local body_depth = tonumber(self:run_parsed_func(env, self._body_depth)) or 0
		local physic_effect = self:run_parsed_func(env, self._physic_effect)
		enabled = (not self._enabled or self:run_parsed_func(env, self._enabled)) and (damage_ext:is_water_check_active(name) or not damage_ext:exists_water_check(name))

		damage_ext:set_water_check(name, enabled, interval, ref_object_name, ref_body_name, body_depth, physic_effect)
	else
		local supported_values = SequenceManager:get_keys_as_string(env.dest_unit:damage():get_water_check_map(), "", true, false)

		self:print_attribute_error("name", name, supported_values, true, env)
	end
end

ShakeCameraElement = ShakeCameraElement or class(BaseElement)
ShakeCameraElement.NAME = "shake_camera"

function ShakeCameraElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._shaker = self:get("shaker")
	self._amplitude = self:get("amplitude")
	self._frequency = self:get("frequency")
	self._offset = self:get("offset")
end

function ShakeCameraElement:activate_callback(env)
	local shaker_name = self:run_parsed_func(env, self._shaker)
	local amplitude = self:run_parsed_func(env, self._amplitude) or 1
	local frequency = self:run_parsed_func(env, self._frequency) or 1
	local offset = self:run_parsed_func(env, self._offset) or 0
	local shaker = managers.viewport:get_current_shaker()

	if shaker then
		managers.viewport:get_current_shaker():play(shaker_name, amplitude, frequency, offset)
	end
end

SlotElement = SlotElement or class(BaseElement)
SlotElement.NAME = "slot"

function SlotElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._slot = self:get("slot")
	self._frustum_delay = self:get("frustum_delay")
	self._frustum_close_radius = self:get("frustum_close_radius")
	self._frustum_extension = self:get("frustum_extension")
	self._frustum_far_clip = self:get("frustum_far_clip")
end

function SlotElement:activate_callback(env)
	if self._frustum_delay then
		local visible = self:run_parsed_func(env, self._frustum_delay)
		local frustum_close_radius = self:run_parsed_func(env, self._frustum_close_radius)
		local frustum_extension = self:run_parsed_func(env, self._frustum_extension)
		local frustum_far_clip = self:run_parsed_func(env, self._frustum_far_clip)
		local data = {}

		local function func()
			return self:check_frustum_delay(frustum_close_radius, frustum_extension, frustum_far_clip, visible, env, data)
		end

		data._body_index = 1
		data._bodies = {}
		local body_count = env.dest_unit:num_bodies()

		for i = 0, body_count - 1 do
			table.insert(data._bodies, env.dest_unit:body(i))
		end

		if #data._bodies == 0 then
			self:activate_element(env)
		end

		managers.sequence:add_retry_callback("culling", func, true)

		if self.SAVE_STATE then
			self:set_state(env.dest_unit, tonumber(self:run_parsed_func(env, self._slot)))
		end

		return
	end

	self:activate_element(env)
end

function SlotElement:activate_element(env)
	local slot = tonumber(self:run_parsed_func(env, self._slot))

	if slot then
		env.dest_unit:set_slot(slot)

		if self.SAVE_STATE then
			self:set_state(env.dest_unit, slot)
		end
	else
		self:print_attribute_error("slot", slot, nil, true, env, nil)
	end
end

function SlotElement.load(unit, data)
	unit:set_slot(data)
end

function SlotElement:check_frustum_delay(frustum_close_radius, frustum_extension, frustum_far_clip, visible, env, data)
	if not alive(env.dest_unit) then
		return true
	end

	local body = data._bodies[data._body_index]
	local pos = body:position()

	if World:in_view_with_options(pos, frustum_close_radius or 0, frustum_extension or 350, frustum_far_clip or 150000) == visible then
		self:hide_objects(body:root_object())
		table.remove(data._bodies, data._body_index)

		if #data._bodies == 0 then
			self:activate_element(env)

			return true
		end
	else
		data._body_index = data._body_index + 1
	end

	if data._body_index > #data._bodies then
		data._body_index = 1
	end

	return false
end

function SlotElement:hide_objects(obj)
	obj:set_visibility(false)

	for _, child_obj in ipairs(obj:children()) do
		self:hide_objects(child_obj)
	end
end

WwiseElement = WwiseElement or class(BaseElement)
WwiseElement.NAME = "sound"

function WwiseElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._action = self:get("action")
	self._source = self:get("source")
	self._object = self:get("object")
	self._event = self:get("event")
	self._switch = self:get("switch")
	self._skip_save = self:get("skip_save")
end

function WwiseElement:activate_callback(env)
	local func_name = self:run_parsed_func(env, self._action) or "play"
	local func = self[func_name]

	if func then
		func(self, env)
	end
end

function WwiseElement:play(env)
	local source = self:run_parsed_func(env, self._source)
	local object = self:run_parsed_func(env, self._object)
	local event = self:run_parsed_func(env, self._event)
	local skip_save = self:run_parsed_func(env, self._skip_save)
	local switch = self:run_parsed_func(env, self._switch)
	local sound_source = self:_get_sound_source(env)

	if not event then
		self:print_attribute_error("event", event, nil, true, env, nil)

		return
	end

	if not sound_source then
		Application:throw_exception("[WwiseElement:play]: Unable to play environment sound.")

		return
	end

	if switch then
		local switches = string.split(switch, " ")
		local i = 1

		while i < #switches do
			local switch_name = switches[i]
			local value = switches[i + 1]

			sound_source:set_switch(switch_name, value)

			i = i + 2
		end
	end

	sound_source:post_event(event)

	if self.SAVE_STATE and not skip_save and source then
		self:set_cat_state(env.dest_unit, source, {
			"post_event",
			event
		})
	end
end

function WwiseElement:stop(env)
	local source = self:run_parsed_func(env, self._source)
	local event = self:run_parsed_func(env, self._event)

	if not source then
		self:print_attribute_error("source", source, nil, true, env, nil)
	end

	if not event then
		self:print_attribute_error("event", event, nil, true, env, nil)

		return
	end

	local sound_source = env.dest_unit:sound_source(source and Idstring(source))

	sound_source:stop()

	if self.SAVE_STATE then
		self:set_cat_state(env.dest_unit, source, {
			"stop",
			event
		})
	end
end

function WwiseElement:set_switch(env)
	local switch = self:run_parsed_func(env, self._switch)
	local sound_source = self:_get_sound_source(env)

	if switch then
		local switches = string.split(switch, " ")
		local i = 1

		while i < #switches do
			local switch_name = switches[i]
			local value = switches[i + 1]

			sound_source:set_switch(switch_name, value)

			i = i + 2
		end
	end
end

function WwiseElement:_get_sound_source(env)
	local source = self:run_parsed_func(env, self._source)
	local object = self:run_parsed_func(env, self._object)
	local sound_source = nil

	if source then
		if source == "" then
			sound_source = env.dest_unit:sound_source()
		else
			sound_source = env.dest_unit:sound_source(Idstring(source))
		end

		if not sound_source then
			self:print_attribute_error("source", source, nil, true, env, nil)
		end
	elseif object then
		sound_source = env.dest_unit:damage():get_sound_source(object)

		if not sound_source then
			self:print_attribute_error("object", object, nil, true, env, nil)
		end
	end

	return sound_source
end

function WwiseElement.load(unit, data)
	for source, sub_data in pairs(data) do
		local sound_source = unit:sound_source(source and Idstring(source))

		sound_source[sub_data[1]](sound_source, sub_data[2])
	end
end

SoundElement = SoundElement or class(BaseElement)
SoundElement.NAME = "sound"

function SoundElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._action = self:get("action")
	self._target = self:get("target")
	self._cue = self:get("cue")
	self._gain_abs = self:get("gain")
	self._pitch_abs = self:get("pitch")
	self._crossfade = self:get("crossfade")
	self._t = self:get("t")
end

function SoundElement:activate_callback(env)
	local func_name = self:run_parsed_func(env, self._action) or "play"
	local func = self[func_name]

	if func then
		func(self, env)
	end
end

function SoundElement:play(env)
	local cue = self:run_parsed_func(env, self._cue)

	if cue ~= nil then
		local obj_name = self:run_parsed_func(env, self._target)
		local param_map = {
			gain_abs = self:run_parsed_func(env, self._gain_abs),
			pitch_abs = self:run_parsed_func(env, self._pitch_abs),
			crossfade = self:run_parsed_func(env, self._crossfade),
			t = self:run_parsed_func(env, self._t)
		}

		if obj_name then
			if env.dest_unit:get_object(obj_name:id()) then
				env.dest_unit:play_at(cue, obj_name, table.unpack_map(param_map))
			else
				self:print_attribute_error("target", obj_name, nil, true, env, nil)
			end
		else
			env.dest_unit:play(cue, table.unpack_map(param_map))
		end
	else
		self:print_attribute_error("cue", cue, nil, true, env, nil)
	end
end

function SoundElement:stop(env)
	local cue = self:run_parsed_func(env, self._cue)

	if cue ~= nil then
		env.dest_unit:stop(cue)
	else
		self:print_attribute_error("cue", cue, nil, true, env, nil)
	end
end

SpawnUnitElement = SpawnUnitElement or class(BaseElement)
SpawnUnitElement.NAME = "spawn_unit"
SpawnUnitElement.SPAWN_UNIT_ATTRIBUTE_MAP = SpawnUnitElement.SPAWN_UNIT_ATTRIBUTE_MAP or {
	position = true,
	name = true,
	from_trigger_sequence = true,
	to_trigger_sequence = true,
	src_link_obj = true,
	run_sequence = true,
	dest_link_obj = true,
	transfer_velocity = true,
	from_trigger = true,
	rotation = true,
	to_trigger = true
}

function SpawnUnitElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._name = self:get("name")
	self._position = self:get("position")
	self._rotation = self:get("rotation")
	self._transfer_velocity = self:get("transfer_velocity")
	self._transfer_ang_velocity = self:get("transfer_ang_velocity")
	self._run_sequence = self:get("run_sequence")
	self._src_link_obj = self:get("src_link_obj")
	self._dest_link_obj = self:get("dest_link_obj")
	self._from_trigger = self:get("from_trigger")
	self._from_trigger_sequence = self:get("from_trigger_sequence")
	self._to_trigger = self:get("to_trigger")
	self._to_trigger_sequence = self:get("to_trigger_sequence")
	self._inherit_destroy = self:get("inherit_destroy")
	self._params = {}

	for k, v in pairs(self._parameters) do
		if not self.BASE_ATTRIBUTE_MAP[k] and not self.SPAWN_UNIT_ATTRIBUTE_MAP[k] then
			self._params[k] = self:get(k)
		end
	end
end

function SpawnUnitElement:activate_callback(env)
	local name = self:run_parsed_func(env, self._name)
	local position = self:run_parsed_func(env, self._position)
	local rotation = self:run_parsed_func(env, self._rotation)
	local src_link_obj = self:run_parsed_func(env, self._src_link_obj)
	local run_sequence = self:run_parsed_func(env, self._run_sequence)

	if not name then
		self:print_attribute_error("name", name, nil, true, env)
	elseif not position then
		self:print_attribute_error("position", position, nil, true, env)
	elseif not rotation then
		self:print_attribute_error("rotation", rotation, nil, true, env)
	else
		local unit = nil
		local dest_damage_ext = env.dest_unit:damage()

		if MassUnitManager:can_spawn_unit(Idstring(name)) then
			unit = MassUnitManager:spawn_unit(name, position, rotation)
		else
			if Network:multiplayer() and Network:is_client() then
				local network_sync = PackageManager:unit_data(name:id()):network_sync()

				if network_sync ~= "none" and network_sync ~= "client" then
					return
				end
			end

			unit = CoreUnit.safe_spawn_unit(name, position, rotation)

			if unit then
				if dest_damage_ext.external_spawn_unit_callback then
					dest_damage_ext:external_spawn_unit_callback(unit, env)
				end

				if alive(env.src_unit) and env.dest_unit ~= env.src_unit then
					local src_damage_ext = env.src_unit:damage()

					if src_damage_ext and src_damage_ext.external_spawn_unit_callback then
						src_damage_ext:external_spawn_unit_callback(unit, env)
					end
				end
			end
		end

		if src_link_obj then
			if not unit then
				self:print_error("Spawned mass unit must be enabled before it can be linked.", false, env)
			else
				local dest_link_obj = self:run_parsed_func(env, self._dest_link_obj)

				if dest_link_obj then
					env.dest_unit:link(src_link_obj, unit, dest_link_obj)
				else
					env.dest_unit:link(src_link_obj, unit)
				end
			end
		end

		local transfer_velocity = self:run_parsed_func(env, self._transfer_velocity)

		if transfer_velocity then
			if not unit then
				self:print_error("Spawned mass unit must be enabled to be able to transfer velocity \"" .. tostring(transfer_velocity) .. "\".", false, env)
			else
				local velocity = nil

				if getmetatable(transfer_velocity) == Vector3 then
					velocity = transfer_velocity
				elseif env.damage_type == "collision" then
					velocity = env.velocity
				elseif alive(env.dest_body) then
					velocity = env.dest_body:velocity()
				else
					velocity = env.dest_unit:velocity()
				end

				local ang_velocity = self:run_parsed_func(env, self._transfer_ang_velocity)
				local physic_effect_name = nil

				if ang_velocity then
					if getmetatable(ang_velocity) ~= Vector3 then
						if alive(env.dest_body) then
							ang_velocity = env.dest_body:angular_velocity()
						else
							ang_velocity = Vector3()

							for i = 1, env.dest_unit:num_bodies() do
								local body = env.dest_unit:body(i - 1)
								local body_ang_velocity = body:angular_velocity()

								if ang_velocity:length() < body_ang_velocity:length() then
									ang_velocity = body_ang_velocity
								end
							end
						end
					end

					physic_effect_name = "core/physic_effects/sequencemanager_push_with_ang"
				else
					physic_effect_name = "core/physic_effects/sequencemanager_push"
				end

				World:play_physic_effect(Idstring(physic_effect_name), unit, velocity, unit:mass(), ang_velocity)
			end
		end

		local params = nil

		if run_sequence and run_sequence ~= "" then
			if not unit then
				self:print_error("Spawned mass unit must be enabled before sequence \"" .. tostring(run_sequence) .. "\" can be runned on it.", false, env)
			elseif unit:damage() then
				params = self:get_params(env)

				managers.sequence:run_sequence(run_sequence, env.damage_type, env.src_unit or env.dest_unit, unit, nil, env.dest_normal, env.pos, env.dir, env.damage, env.velocity, params)

				SequenceEnvironment.self = env
				SequenceEnvironment.element = self
			else
				self:print_error("Unable to run sequence \"" .. tostring(run_sequence) .. "\" on unit \"" .. tostring(unit) .. "\" since it doesn't have a damage-extension.", true, env)
			end
		end

		local from_trigger = self:run_parsed_func(env, self._from_trigger)

		if from_trigger then
			if not unit then
				self:print_error("Spawned mass unit must be enabled before trigger \"" .. tostring(from_trigger) .. "\" on it can be connected.", false, env)
			else
				local damage_ext = unit:damage()

				if damage_ext then
					if damage_ext._unit_element:has_trigger_name(from_trigger) then
						local from_trigger_sequence = self:run_parsed_func(env, self._from_trigger_sequence)

						if from_trigger_sequence and self._unit_element:get_sequence_element(from_trigger_sequence) then
							params = params or self:get_params(env)

							unit:damage():add_trigger_sequence(from_trigger, from_trigger_sequence, env.dest_unit, nil, nil, params, false)
						else
							local supported_values = SequenceManager:get_keys_as_string(self._unit_element:get_sequence_name_list(), "", true, true)

							self:print_attribute_error("from_trigger_sequence", from_trigger_sequence, supported_values, true, env)
						end
					else
						local supported_values = SequenceManager:get_keys_as_string(damage_ext._unit_element:get_trigger_name_map(), "", true, true)

						self:print_attribute_error("from_trigger", from_trigger, supported_values, true, env)
					end
				else
					self:print_error("Unable to connect trigger \"" .. tostring(from_trigger) .. "\" on unit \"" .. tostring(unit) .. "\" since it doesn't have a damage-extension.", true, env)
				end
			end
		end

		local to_trigger = self:run_parsed_func(env, self._to_trigger)

		if to_trigger then
			if not unit then
				self:print_error("Spawned mass unit must be enabled before trigger \"" .. tostring(to_trigger) .. "\" can be connected to a sequence on it.", false, env)
			else
				local damage_ext = unit:damage()

				if damage_ext then
					if self._unit_element:has_trigger_name(to_trigger) then
						local to_trigger_sequence = self:run_parsed_func(env, self._to_trigger_sequence)

						if to_trigger_sequence and damage_ext._unit_element:get_sequence_element(to_trigger_sequence) then
							params = params or self:get_params(env)

							dest_damage_ext:add_trigger_sequence(to_trigger, to_trigger_sequence, unit, nil, nil, params, false)
						else
							local supported_values = SequenceManager:get_keys_as_string(damage_ext._unit_element:get_sequence_name_list(), "", true, true)

							self:print_attribute_error("to_trigger_sequence", to_trigger_sequence, supported_values, true, env)
						end
					else
						local supported_values = SequenceManager:get_keys_as_string(self._unit_element:get_trigger_name_map(), "", true, true)

						self:print_attribute_error("to_trigger", to_trigger, supported_values, true, env)
					end
				else
					self:print_error("Unable to connect trigger \"" .. tostring(to_trigger) .. "\" on unit \"" .. tostring(unit) .. "\" since it doesn't have a damage-extension.", true, env)
				end
			end
		end

		local inherit_destroy = self:run_parsed_func(env, self._inherit_destroy)

		if inherit_destroy then
			if not unit then
				self:print_error("Spawned mass unit must be enabled if \"inherit_destroy\"-attribute is used.", false, env)
			else
				dest_damage_ext:add_inherit_destroy_unit(unit)
			end
		end
	end
end

function SpawnUnitElement:get_params(env)
	local params = CoreTable.clone(env.params)

	for k, v in pairs(self._params) do
		params[k] = self:run_parsed_func(env, v)
	end

	params.spawn_unit = env.dest_unit

	return params
end

StopPhysicEffectElement = StopPhysicEffectElement or class(BaseElement)
StopPhysicEffectElement.NAME = "stop_physic_effect"

function StopPhysicEffectElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._id = self:get("id")
end

function StopPhysicEffectElement:activate_callback(env)
	local id = self:run_parsed_func(env, self._id)

	if not id then
		self:print_attribute_error("id", id, nil, true, env)
	else
		World:stop_physic_effect(id)
	end
end

StopEffectElement = StopEffectElement or class(BaseElement)
StopEffectElement.NAME = "stop_effect"

function StopEffectElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._id_list_var = self:get("id_list_var")
	self._instant = self:get("instant")
end

function StopEffectElement:activate_callback(env)
	local id_list_var = self:run_parsed_func(env, self._id_list_var)

	if not id_list_var then
		self:print_attribute_error("id_list_var", id_list_var, nil, true, env)
	else
		local id_list = env.vars[id_list_var]

		if id_list then
			if type(id_list) == "table" then
				local instant = self:run_parsed_func(env, self._instant)
				local effect_manager = World:effect_manager()
				local func = instant and effect_manager.kill or effect_manager.fade_kill

				for _, id in ipairs(id_list) do
					if instant then
						func(effect_manager, id)
					else
						func(effect_manager, id)
					end
				end

				env.vars[id_list_var] = nil
			else
				self:print_error("\"id_list_var\" referred to a variable that wasn't a table but a \"" .. tostring(type(id_list)) .. "\".", false, env, nil)
			end
		end
	end
end

TriggerElement = TriggerElement or class(BaseElement)
TriggerElement.NAME = "trigger"

function TriggerElement:init(node, unit_element)
	BaseElement.init(self, node, unit_element)

	self._name = self:get("name")
end

function TriggerElement:activate_callback(env)
	local name = self:run_parsed_func(env, self._name)
	local dest_unit_damage_ext = env.dest_unit:damage()

	dest_unit_damage_ext:on_trigger_callback(name, env)

	local trigger_data_list = dest_unit_damage_ext:get_trigger_data_list(name)

	if trigger_data_list then
		for _, trigger_data in ipairs(trigger_data_list) do
			if trigger_data.params then
				for k, v in pairs(trigger_data.params) do
					env.params[k] = v
				end
			end

			local damage_ext = trigger_data.notify_unit:damage()

			if damage_ext then
				env = SequenceEnvironment:new(env.damage_type, env.dest_unit, trigger_data.notify_unit, nil, env.dest_normal, env.pos, env.dir, env.damage, env.velocity, env.params, damage_ext:get_unit_element(), damage_ext)

				managers.sequence:_add_start_time_callback(nil, env, trigger_data.time, trigger_data.repeat_nr, trigger_data.notify_unit_sequence)
			end
		end
	end
end
