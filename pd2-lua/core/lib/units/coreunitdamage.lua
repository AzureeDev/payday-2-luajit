core:import("CoreSequenceManager")

CoreUnitDamage = CoreUnitDamage or class()
CoreUnitDamage.ALL_TRIGGERS = "*"
UnitDamage = UnitDamage or class(CoreUnitDamage)
local ids_damage = Idstring("damage")

function CoreUnitDamage:init(unit, default_body_extension_class, body_extension_class_map, ignore_body_collisions, ignore_mover_collisions, mover_collision_ignore_duration)
	self._unit = unit
	self._unit_element = managers.sequence:get(unit:name(), false, true)
	self._damage = 0

	if self._unit_element._set_variables and next(self._unit_element._set_variables) then
		self._variables = clone(self._unit_element._set_variables)
	end

	self._unit:set_extension_update_enabled(ids_damage, self._update_func_map ~= nil)

	for name, element in pairs(self._unit_element:get_proximity_element_map()) do
		local data = {
			name = name,
			enabled = element:get_enabled(),
			ref_object = element:get_ref_object() and self._unit:get_object(Idstring(element:get_ref_object())),
			interval = element:get_interval(),
			quick = element:is_quick(),
			is_within = element:get_start_within(),
			slotmask = element:get_slotmask()
		}
		data.last_check_time = TimerManager:game():time() + math.rand(math.min(data.interval, 0))

		self:populate_proximity_range_data(data, "within_data", element:get_within_element())
		self:populate_proximity_range_data(data, "outside_data", element:get_outside_element())

		self._proximity_map = self._proximity_map or {}
		self._proximity_map[name] = data
		self._proximity_count = (self._proximity_count or 0) + 1

		if data.enabled then
			if not self._proximity_enabled_count then
				self._proximity_enabled_count = 0

				self:set_update_callback("update_proximity_list", true)
			end

			self._proximity_enabled_count = self._proximity_enabled_count + 1
		end
	end

	self._mover_collision_ignore_duration = mover_collision_ignore_duration
	body_extension_class_map = body_extension_class_map or {}
	default_body_extension_class = default_body_extension_class or CoreBodyDamage
	local inflict_updator_damage_type_map = get_core_or_local("InflictUpdator").INFLICT_UPDATOR_DAMAGE_TYPE_MAP
	local unit_key = self._unit:key()

	for _, body_element in pairs(self._unit_element._bodies) do
		local body = self._unit:body(body_element._name)

		if body then
			body:set_extension(body:extension() or {})

			local body_ext = (body_extension_class_map[body_element._name] or default_body_extension_class):new(self._unit, self, body, body_element)
			body:extension().damage = body_ext
			local body_key = nil

			for damage_type, _ in pairs(body_ext:get_endurance_map()) do
				if inflict_updator_damage_type_map[damage_type] then
					body_key = body_key or body:key()
					self._added_inflict_updator_damage_type_map = self._added_inflict_updator_damage_type_map or {}
					self._added_inflict_updator_damage_type_map[damage_type] = {
						[body_key] = body_ext
					}

					managers.sequence:add_inflict_updator_body(damage_type, unit_key, body_key, body_ext)
				end
			end
		else
			Application:throw_exception("Unit \"" .. self._unit:name():t() .. "\" doesn't have the body \"" .. body_element._name .. "\" that was loaded into the SequenceManager.")
		end
	end

	if not ignore_body_collisions then
		self._unit:set_body_collision_callback(callback(self, self, "body_collision_callback"))
	end

	if self._unit:mover() and not ignore_mover_collisions then
		self._unit:set_mover_collision_callback(callback(self, self, "mover_collision_callback"))
	end

	self._water_check_element_map = self._unit_element:get_water_element_map()

	if self._water_check_element_map then
		for name, water_element in pairs(self._water_check_element_map) do
			self:set_water_check(name, water_element:get_enabled(), water_element:get_interval(), water_element:get_ref_object(), water_element:get_ref_body(), water_element:get_body_depth(), water_element:get_physic_effect())
		end
	end

	self._startup_sequence_map = self._unit_element:get_startup_sequence_map(self._unit, self)

	if self._startup_sequence_map then
		self._startup_sequence_callback_id = managers.sequence:add_startup_callback(callback(self, self, "run_startup_sequences"))
	end

	if Application:editor() then
		self._editor_startup_sequence_map = self._unit_element:get_editor_startup_sequence_map(self._unit, self)

		if self._editor_startup_sequence_map then
			self._editor_startup_sequence_callback_id = managers.sequence:add_startup_callback(callback(self, self, "run_editor_startup_sequences"))
		end
	end
end

function CoreUnitDamage:get_sound_source(object)
	self._sound_sources = self._sound_sources or {}
	local sound_source = self._sound_sources[object]

	if not sound_source then
		sound_source = SoundDevice:create_source(object)
		local obj = self._unit:get_object(Idstring(object))

		if obj then
			sound_source:link(obj)
		else
			return
		end

		self._sound_sources[object] = sound_source
	end

	return sound_source
end

function CoreUnitDamage:destroy()
	if self._added_inflict_updator_damage_type_map then
		local unit_key = self._unit:key()

		for damage_type, body_map in pairs(self._added_inflict_updator_damage_type_map) do
			for body_key in pairs(body_map) do
				managers.sequence:remove_inflict_updator_body(damage_type, unit_key, body_key)
			end
		end
	end

	if self._water_check_map then
		for name in pairs(self._water_check_map) do
			self:set_water_check_active(name, false)
		end
	end

	if self._inherit_destroy_unit_list then
		for _, unit in ipairs(self._inherit_destroy_unit_list) do
			if alive(unit) then
				unit:set_slot(0)
			end
		end
	end
end

function CoreUnitDamage:update(unit, t, dt)
	if self._update_func_map then
		for func_name, data in pairs(self._update_func_map) do
			self[func_name](self, unit, t, dt, data)
		end
	else
		Application:error("Some scripter tried to enable the damage extension on unit \"" .. tostring(unit:name()) .. "\" or an artist have specified more than one damage-extension in the unit xml. This would have resulted in a crash, so fix it!")
		self._unit:set_extension_update_enabled(ids_damage, false)
	end
end

function CoreUnitDamage:set_update_callback(func_name, data)
	if data then
		self._update_func_map = self._update_func_map or {}

		if not self._update_func_map[func_name] then
			if not self._update_func_count then
				self._update_func_count = 0

				self._unit:set_extension_update_enabled(ids_damage, true)
			end

			self._update_func_count = self._update_func_count + 1
		end

		self._update_func_map[func_name] = data
	elseif self._update_func_map and self._update_func_map[func_name] then
		self._update_func_count = self._update_func_count - 1
		self._update_func_map[func_name] = nil

		if self._update_func_count == 0 then
			self._unit:set_extension_update_enabled(ids_damage, false)

			self._update_func_map = nil
			self._update_func_count = nil
		end
	end
end

function CoreUnitDamage:populate_proximity_range_data(data, sub_data_name, element)
	if element then
		data[sub_data_name] = {
			element = element,
			activation_count = 0,
			max_activation_count = element:get_max_activation_count(),
			delay = element:get_delay()
		}
		data[sub_data_name].last_check_time = TimerManager:game():time() + math.rand(math.min(data[sub_data_name].delay, 0))
		data[sub_data_name].range = element:get_range()
		data[sub_data_name].count = element:get_count()
		data[sub_data_name].is_within = sub_data_name == "within_data"
	end
end

function CoreUnitDamage:set_proximity_enabled(name, enabled)
	local data = self._proximity_map and self._proximity_map[name]

	if data and not data.enabled ~= not enabled then
		data.enabled = enabled

		if enabled then
			if not self._proximity_enabled_count then
				self:set_update_callback("update_proximity_list", true)

				self._proximity_enabled_count = 0
			end

			self._proximity_enabled_count = self._proximity_enabled_count + 1
		else
			self._proximity_enabled_count = self._proximity_enabled_count - 1

			if self._proximity_enabled_count <= 0 then
				self._proximity_enabled_count = nil

				self:set_update_callback("update_proximity_list", nil)
			end
		end
	end
end

function CoreUnitDamage:update_proximity_list(unit, t, dt)
	if managers.sequence:is_proximity_enabled() then
		for name, data in pairs(self._proximity_map) do
			if data.enabled and t >= data.last_check_time + data.interval then
				local range_data, reversed, range_data_string = nil

				if data.is_within then
					range_data = data.outside_data
					range_data_string = "outside_data"

					if not range_data then
						range_data = data.within_data
						range_data_string = "within_data"
						reversed = true
					else
						reversed = false
					end
				else
					range_data = data.within_data
					range_data_string = "within_data"

					if not range_data then
						range_data = data.outside_data
						range_data_string = "outside_data"
						reversed = true
					else
						reversed = false
					end
				end

				data.last_check_time = t

				if self:check_proximity_activation_count(data) and t >= range_data.last_check_time + range_data.delay and self:update_proximity(unit, t, dt, data, range_data) ~= reversed then
					range_data.last_check_time = t
					data.is_within = not data.is_within

					if not reversed and self:is_proximity_range_active(range_data) then
						range_data.activation_count = range_data.activation_count + 1

						self:_do_proximity_activation(range_data)
						self:_check_send_sync_proximity_activation(name, range_data_string)
						self:check_proximity_activation_count(data)
					end
				end
			end
		end
	end
end

function CoreUnitDamage:_do_proximity_activation(range_data)
	self._proximity_env = self._proximity_env or CoreSequenceManager.SequenceEnvironment:new("proximity", self._unit, self._unit, nil, Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0), 0, Vector3(0, 0, 0), nil, self._unit_element)

	range_data.element:activate_elements(self._proximity_env)
end

function CoreUnitDamage:_check_send_sync_proximity_activation(name, range_data_string)
	if not Network:is_server() or self._unit:id() == -1 then
		return
	end

	managers.network:session():send_to_peers_synched("sync_proximity_activation", self._unit, name, range_data_string)
end

function CoreUnitDamage:sync_proximity_activation(name, range_data_string)
	local data = self._proximity_map[name]
	local range_data = data[range_data_string]

	self:_do_proximity_activation(range_data)
end

function CoreUnitDamage:is_proximity_range_active(range_data)
	return range_data and (range_data.max_activation_count < 0 or range_data.activation_count < range_data.max_activation_count)
end

function CoreUnitDamage:check_proximity_activation_count(data)
	if not self:is_proximity_range_active(data.within_data) and not self:is_proximity_range_active(data.outside_data) then
		self:set_proximity_enabled(data.name, false)

		return false
	else
		return true
	end
end

function CoreUnitDamage:update_proximity(unit, t, dt, data, range_data)
	local pos = nil

	if data.ref_object then
		pos = data.ref_object:position()
	else
		pos = self._unit:position()
	end

	local unit_list = {}
	local units = self._unit:find_units_quick("all", data.slotmask)

	for _, unit in ipairs(units) do
		if mvector3.distance(pos, unit:movement():m_newest_pos()) < range_data.range then
			table.insert(unit_list, unit)
		end
	end

	if data.is_within and range_data.is_within ~= data.is_within or not data.is_within and range_data.is_within == data.is_within then
		return #unit_list <= range_data.count
	else
		return range_data.count <= #unit_list
	end
end

function CoreUnitDamage:get_proximity_map()
	return self._proximity_map or {}
end

function CoreUnitDamage:set_proximity_slotmask(name, slotmask)
	self._proximity_map[name].slotmask = slotmask
end

function CoreUnitDamage:set_proximity_ref_obj_name(name, ref_obj_name)
	self._proximity_map[name].ref_object = ref_obj_name and self._unit:get_object(Idstring(ref_obj_name))
end

function CoreUnitDamage:set_proximity_interval(name, interval)
	self._proximity_map[name].interval = interval
end

function CoreUnitDamage:set_proximity_is_within(name, is_within)
	self._proximity_map[name].is_within = is_within
end

function CoreUnitDamage:set_proximity_within_activations(name, activations)
	local data = self._proximity_map[name]
	local within_data = data.within_data

	if within_data then
		within_data.activations = activations

		return self:check_proximity_activation_count(data)
	end
end

function CoreUnitDamage:set_proximity_within_max_activations(name, max_activations)
	local data = self._proximity_map[name]
	local within_data = data.within_data

	if within_data then
		within_data.max_activations = max_activations

		return self:check_proximity_activation_count(data)
	end
end

function CoreUnitDamage:set_proximity_within_delay(name, delay)
	local within_data = self._proximity_map[name].within_data

	if within_data then
		within_data.delay = delay
	end
end

function CoreUnitDamage:set_proximity_within_range(name, range)
	local within_data = self._proximity_map[name].within_data

	if within_data then
		within_data.range = range
	end
end

function CoreUnitDamage:set_proximity_inside_count(name, count)
	local within_data = self._proximity_map[name].within_data

	if within_data then
		within_data.count = count
	end
end

function CoreUnitDamage:set_proximity_outside_activations(name, activations)
	local data = self._proximity_map[name]
	local outside_data = data.outside_data

	if outside_data then
		outside_data.activations = activations

		return self:check_proximity_activation_count(data)
	end
end

function CoreUnitDamage:set_proximity_outside_max_activations(name, max_activations)
	local data = self._proximity_map[name]
	local outside_data = data.outside_data

	if outside_data then
		outside_data.max_activations = max_activations

		return self:check_proximity_activation_count(data)
	end
end

function CoreUnitDamage:set_proximity_outside_delay(name, delay)
	local outside_data = self._proximity_map[name].outside_data

	if outside_data then
		outside_data.delay = delay
	end
end

function CoreUnitDamage:set_proximity_outside_range(name, range)
	local outside_data = self._proximity_map[name].outside_data

	if outside_data then
		outside_data.range = range
	end
end

function CoreUnitDamage:set_proximity_outside_range(name, range)
	local outside_data = self._proximity_map[name].outside_data

	if outside_data then
		outside_data.range = count
	end
end

function CoreUnitDamage:get_water_check_map()
	return self._water_check_map
end

function CoreUnitDamage:set_water_check(name, enabled, interval, ref_object_name, ref_body_name, body_depth, physic_effect)
	self._water_check_map = self._water_check_map or {}
	local water_check = self._water_check_map[name]
	local ref_object = ref_object_name and self._unit:get_object(Idstring(ref_object_name))
	local ref_body = ref_body_name and self._unit:body(ref_body_name)

	if not water_check then
		water_check = CoreDamageWaterCheck:new(self._unit, self, name, interval, ref_object, ref_body, body_depth, physic_effect)
		self._water_check_map[name] = water_check
	else
		water_check:set_interval(interval)
		water_check:set_body_depth(body_depth)

		if ref_object then
			water_check:set_ref_object(ref_object)
		elseif ref_body then
			water_check:set_ref_body(ref_body)
		end
	end

	self:set_water_check_active(name, enabled)

	if not water_check:is_valid() then
		Application:error("Invalid water check \"" .. tostring(name) .. "\" in unit \"" .. tostring(self._unit:name()) .. "\". Neither ref_body nor ref_object is speicified in it.")
		self:remove_water_check(name)
	end
end

function CoreUnitDamage:remove_water_check(name)
	if self._water_check_map then
		local water_check = self._water_check_map[name]

		if water_check then
			self:set_water_check_active(name, false)

			self._water_check_map[name] = nil
		end
	end
end

function CoreUnitDamage:exists_water_check(name)
	return self._water_check_map and self._water_check_map[name] ~= nil
end

function CoreUnitDamage:is_water_check_active(name)
	return self._active_water_check_map and self._active_water_check_map[name] ~= nil
end

function CoreUnitDamage:set_water_check_active(name, active)
	local water_check = self._water_check_map and self._water_check_map[name]

	if water_check then
		if active then
			if not self._active_water_check_map or not self._active_water_check_map[name] then
				self._active_water_check_map = self._active_water_check_map or {}
				self._active_water_check_map[name] = water_check
				self._active_water_check_count = (self._active_water_check_count or 0) + 1

				if self._active_water_check_count == 1 then
					self._water_check_func_id = managers.sequence:add_callback(callback(self, self, "update_water_checks"))
				end
			end
		else
			water_check:set_activation_callbacks_enabled(false)

			if self._active_water_check_map and self._active_water_check_map[name] then
				self._active_water_check_map[name] = nil
				self._active_water_check_count = self._active_water_check_count - 1

				if self._active_water_check_count == 0 then
					managers.sequence:remove_callback(self._water_check_func_id)

					self._water_check_func_id = nil
					self._active_water_check_map = nil
					self._active_water_check_count = nil
				end
			end
		end
	end
end

function CoreUnitDamage:update_water_checks(t, dt)
	for name, water_check in pairs(self._active_water_check_map) do
		water_check:update(t, dt)
	end
end

function CoreUnitDamage:water_check_enter(name, water_check, src_unit, body, normal, position, direction, damage, velocity, water_depth)
	local element = self._water_check_element_map[name]

	if element then
		local env = CoreSequenceManager.SequenceEnvironment:new("water", src_unit, self._unit, body, normal, position, direction, damage, velocity, {
			water_depth = water_depth
		}, self._unit_element)

		element:activate_enter(env)
	end
end

function CoreUnitDamage:water_check_exit(name, water_check, src_unit, body, normal, position, direction, damage, velocity, water_depth)
	local element = self._water_check_element_map[name]

	if element then
		local env = CoreSequenceManager.SequenceEnvironment:new("water", src_unit, self._unit, body, normal, position, direction, damage, velocity, {
			water_depth = water_depth
		}, self._unit_element)

		element:activate_exit(env)
	end
end

function CoreUnitDamage:get_unit_element()
	return self._unit_element
end

function CoreUnitDamage:save(data)
	local state = {}
	local changed = false

	if self._runned_sequences then
		for k, v in pairs(self._runned_sequences) do
			state.runned_sequences = table.map_copy(self._runned_sequences)
			changed = true

			break
		end
	end

	if self._state then
		for k, v in pairs(self._state) do
			state.state = deep_clone(self._state)
			changed = true

			break
		end
	end

	if self._damage ~= 0 then
		state.damage = self._damage
		changed = true
	end

	if self._variables then
		for k, v in pairs(self._variables) do
			if (self._unit_element._set_variables == nil or self._unit_element._set_variables[k] ~= v) and (k ~= "damage" or v ~= self._damage) then
				state.variables = table.map_copy(self._variables)
				changed = true

				break
			end
		end
	end

	if self._proximity_count then
		changed = true
		state.proximity_count = self._proximity_count
		state.proximity_enabled_count = self._proximity_enabled_count

		for name, data in pairs(self._proximity_map or {}) do
			state.proximity_map = state.proximity_map or {}
			state.proximity_map[name] = {}

			for attribute_name, attribute_value in pairs(data) do
				if attribute_name == "ref_object" then
					state.proximity_map[name][attribute_name] = attribute_value and attribute_value:name()
				elseif attribute_name == "slotmask" then
					state.proximity_map[name][attribute_name] = managers.slot:get_mask_name(attribute_value)
				elseif attribute_name == "last_check_time" then
					state.proximity_map[name][attribute_name] = TimerManager:game():time() - attribute_value
				elseif attribute_name == "within_data" or attribute_name == "outside_data" then
					state.proximity_map[name][attribute_name] = {}

					for range_attribute_name, range_attribute_value in pairs(attribute_value) do
						if range_attribute_name ~= "element" then
							state.proximity_map[name][attribute_name][range_attribute_name] = range_attribute_value
						end
					end
				else
					state.proximity_map[name][attribute_name] = attribute_value
				end
			end
		end
	end

	if self._trigger_data_map then
		state.trigger_data_map = managers.sequence:safe_save_map(self._trigger_data_map)
		state.trigger_name_list = self._trigger_name_list and table.list_copy(self._trigger_name_list)
		state.last_trigger_id = self._last_trigger_id
		changed = true
	end

	for _, anim_name in ipairs(self._unit:anim_groups()) do
		state.anim = state.anim or {}
		local anim_time = self._unit:anim_time(anim_name)

		table.insert(state.anim, {
			name = anim_name,
			time = anim_time
		})

		changed = true
	end

	if not self._skip_save_anim_state_machine then
		local state_machine = self._unit:anim_state_machine()

		if state_machine then
			state.state_machine = state.state_machine or {}

			for _, segment in ipairs(state_machine:config():segments()) do
				local anim_state = state_machine:segment_state(segment)

				if anim_state ~= Idstring("") then
					changed = true
					local anim_time = state_machine:segment_real_time(segment)

					table.insert(state.state_machine, {
						anim_state = anim_state,
						anim_time = anim_time
					})
				end
			end
		end
	end

	changed = self._unit_element:save_by_unit(self._unit, state) or changed

	if self._queued_sequences then
		changed = true
		state.queued_sequences = self._queued_sequences
	end

	if self._startup_sequence_callback_id then
		state.trigger_startup_sequence_callback = true
		changed = true
	end

	if self._editor_startup_sequence_callback_id then
		state.trigger_editor_startup_sequence_callback = true
		changed = true
	end

	if changed then
		data.CoreUnitDamage = state
	end
end

function CoreUnitDamage:load(data)
	local state = data.CoreUnitDamage

	if self._startup_sequence_callback_id then
		managers.sequence:remove_startup_callback(self._startup_sequence_callback_id)

		self._startup_sequence_callback_id = nil
	end

	if self._editor_startup_sequence_callback_id then
		managers.sequence:remove_startup_callback(self._editor_startup_sequence_callback_id)

		self._editor_startup_sequence_callback_id = nil
	end

	if state then
		if state.trigger_startup_sequence_callback then
			self._startup_sequence_callback_id = managers.sequence:add_startup_callback(callback(self, self, "run_startup_sequences"))
		end

		if state.trigger_editor_startup_sequence_callback then
			self._editor_startup_sequence_callback_id = managers.sequence:add_startup_callback(callback(self, self, "run_editor_startup_sequences"))
		end

		if state.runned_sequences then
			self._runned_sequences = table.map_copy(state.runned_sequences)
		end

		if state.state then
			self._state = deep_clone(state.state)
		end

		self._damage = state.damage or self._damage

		if state.variables then
			self._variables = table.map_copy(state.variables)
		end

		self._queued_sequences = state.queued_sequences

		if state.proximity_map then
			self._proximity_count = state.proximity_count
			self._proximity_enabled_count = state.proximity_enabled_count

			for name, data in pairs(state.proximity_map) do
				self._proximity_map = self._proximity_map or {}

				for attribute_name, attribute_value in pairs(data) do
					if attribute_name == "ref_object" then
						self._proximity_map[name][attribute_name] = attribute_value and self._unit:get_object(attribute_value)
					elseif attribute_name == "slotmask" then
						self._proximity_map[name][attribute_name] = managers.slot:get_mask(attribute_value)
					elseif attribute_name == "last_check_time" then
						self._proximity_map[name][attribute_name] = TimerManager:game():time() - attribute_value
					elseif attribute_name == "within_data" or attribute_name == "outside_data" then
						for range_attribute_name, range_attribute_value in pairs(attribute_value) do
							if range_attribute_name ~= "last_check_time" then
								self._proximity_map[name][attribute_name][range_attribute_name] = range_attribute_value
							end
						end
					else
						self._proximity_map[name][attribute_name] = attribute_value
					end
				end
			end

			if self._proximity_enabled_count then
				self:set_update_callback("update_proximity_list", true)
			end
		end

		if state.trigger_data_map then
			self._trigger_data_map = managers.sequence:safe_load_map(state.trigger_data_map)
			self._trigger_name_list = state.trigger_name_list and table.list_copy(state.trigger_name_list)
			self._last_trigger_id = state.last_trigger_id
		end

		if state.anim then
			for _, anim_data in ipairs(state.anim) do
				self._unit:anim_set_time(anim_data.name, anim_data.time)
			end
		end

		if state.state_machine then
			for _, anim_data in ipairs(state.state_machine) do
				self._unit:play_state(anim_data.anim_state, anim_data.anim_time)
			end
		end

		if self._state then
			for element_name, data in pairs(self._state) do
				managers.sequence:load_element_data(self._unit, element_name, data)
			end
		end

		self._unit_element:load_by_unit(self._unit, state)
	end

	managers.worlddefinition:use_me(self._unit)
	managers.worlddefinition:external_set_only_visible_in_editor(self._unit)
	self:_process_sequence_queue()
end

function CoreUnitDamage:run_startup_sequences()
	local nil_vector = Vector3(0, 0, 0)

	managers.sequence:remove_startup_callback(self._startup_sequence_callback_id)

	self._startup_sequence_callback_id = nil

	for name in pairs(self._startup_sequence_map) do
		if alive(self._unit) then
			managers.sequence:run_sequence(name, "startup", self._unit, self._unit, nil, nil_vector, nil_vector, nil_vector, 0, nil_vector)
		else
			break
		end
	end
end

function CoreUnitDamage:run_editor_startup_sequences()
	local nil_vector = Vector3(0, 0, 0)

	managers.sequence:remove_startup_callback(self._editor_startup_sequence_callback_id)

	self._editor_startup_sequence_callback_id = nil

	for name in pairs(self._editor_startup_sequence_map) do
		if alive(self._unit) then
			managers.sequence:run_sequence(name, "editor_startup", self._unit, self._unit, nil, nil_vector, nil_vector, nil_vector, 0, nil_vector)
		else
			break
		end
	end
end

function CoreUnitDamage:add_trigger_callback(trigger_name, callback_func)
	if not trigger_name or trigger_name == self.ALL_TRIGGERS then
		for next_trigger_name in pairs(self._unit_element:get_trigger_name_map()) do
			self:add_trigger_callback(next_trigger_name, callback_func)
		end

		return
	end

	if not self._trigger_callback_map_list then
		self._trigger_callback_map_list = {}
	end

	local callback_list = self._trigger_callback_map_list[trigger_name]

	if not callback_list then
		callback_list = {}
		self._trigger_callback_map_list[trigger_name] = callback_list
	end

	table.insert(callback_list, callback_func)
end

function CoreUnitDamage:remove_trigger_callback(trigger_name, callback_func)
	if not trigger_name or trigger_name == self.ALL_TRIGGERS then
		for next_trigger_name in pairs(self._unit_element:get_trigger_name_map()) do
			self:remove_trigger_callback(next_trigger_name, callback_func)
		end

		return
	end

	local callback_list = self._trigger_callback_map_list[trigger_name]

	for index, next_callback_func in ipairs(callback_list) do
		if callback_func == next_callback_func then
			table.remove(callback_list, index)

			break
		end
	end

	if #callback_list == 0 then
		self._trigger_callback_map_list[trigger_name] = nil

		if not next(self._trigger_callback_map_list) then
			self._trigger_callback_map_list = nil
		end
	end

	if self._current_trigger_callback_index then
		self._current_trigger_callback_index = self._current_trigger_callback_index - 1
	end
end

function CoreUnitDamage:on_trigger_callback(trigger_name, env)
	if not self._trigger_callback_map_list then
		return
	end

	local callback_list = self._trigger_callback_map_list[trigger_name]

	if not callback_list then
		return
	end

	self._current_trigger_callback_index = 0

	while self._current_trigger_callback_index < #callback_list do
		self._current_trigger_callback_index = self._current_trigger_callback_index + 1

		callback_list[self._current_trigger_callback_index](trigger_name, env)
	end

	self._current_trigger_callback_index = nil
end

function CoreUnitDamage:remove_trigger_data(trigger_name, id)
	if self._trigger_data_map and self._trigger_data_map[trigger_name] then
		for index, data in ipairs(self._trigger_data_map[trigger_name]) do
			if data.id == id then
				table.remove(self._trigger_data_map[trigger_name], index)

				break
			end
		end
	end
end

function CoreUnitDamage:get_trigger_data(trigger_name, id)
	if self._trigger_data_map and self._trigger_data_map[trigger_name] then
		for index, data in ipairs(self._trigger_data_map[trigger_name]) do
			if data.id == id then
				return data
			end
		end
	end
end

function CoreUnitDamage:add_trigger_sequence(trigger_name, notify_unit_sequence, notify_unit, start_time, repeat_nr, params, is_editor)
	if not trigger_name or not self._unit_element:has_trigger_name(trigger_name) then
		Application:stack_dump_error("Trigger \"" .. tostring(trigger_name) .. "\" doesn't exist. Only the following triggers are available: " .. managers.sequence:get_keys_as_string(self._unit_element:get_trigger_name_map(), "[None]", true))

		return nil
	end

	self._last_trigger_id = (self._last_trigger_id or 0) + 1
	local trigger_data = {
		id = self._last_trigger_id,
		trigger_name = trigger_name,
		notify_unit_sequence = notify_unit_sequence,
		notify_unit = notify_unit,
		time = start_time,
		repeat_nr = repeat_nr,
		params = params
	}
	self._trigger_data_map = self._trigger_data_map or {}
	local list = self._trigger_data_map[trigger_name]

	if not list then
		list = {}
		self._trigger_data_map[trigger_name] = list
		self._trigger_name_list = self._trigger_name_list or {}

		table.insert(self._trigger_name_list, trigger_name)
	end

	table.insert(list, trigger_data)

	return self._last_trigger_id
end

function CoreUnitDamage:set_trigger_sequence_name(id, trigger_name, notify_unit_sequence)
	if self._trigger_data_map and self._trigger_data_map[trigger_name] then
		for _, data in ipairs(self._trigger_data_map[trigger_name]) do
			if data.id == id then
				data.notify_unit_sequence = notify_unit_sequence

				return id
			end
		end
	end

	return nil
end

function CoreUnitDamage:set_trigger_sequence_unit(id, trigger_name, notify_unit)
	if self._trigger_data_map and self._trigger_data_map[trigger_name] then
		for _, data in ipairs(self._trigger_data_map[trigger_name]) do
			if data.id == id then
				data.notify_unit = notify_unit

				return id
			end
		end
	end

	return nil
end

function CoreUnitDamage:set_trigger_sequence_time(id, trigger_name, start_time)
	if self._trigger_data_map and self._trigger_data_map[trigger_name] then
		for _, data in ipairs(self._trigger_data_map[trigger_name]) do
			if data.id == id then
				data.time = start_time

				return id
			end
		end
	end

	return nil
end

function CoreUnitDamage:set_trigger_sequence_repeat_nr(id, trigger_name, repeat_nr)
	if self._trigger_data_map and self._trigger_data_map[trigger_name] then
		for _, data in ipairs(self._trigger_data_map[trigger_name]) do
			if data.id == id then
				data.repeat_nr = repeat_nr

				return id
			end
		end
	end

	return nil
end

function CoreUnitDamage:set_trigger_sequence_params(id, trigger_name, params)
	if self._trigger_data_map and self._trigger_data_map[trigger_name] then
		for _, data in ipairs(self._trigger_data_map[trigger_name]) do
			if data.id == id then
				data.params = params

				return id
			end
		end
	end

	return nil
end

function CoreUnitDamage:get_trigger_name_list()
	return self._trigger_name_list
end

function CoreUnitDamage:get_trigger_data_list(trigger_name)
	if self._trigger_data_map then
		local trigger_data_list = self._trigger_data_map[trigger_name]

		if trigger_data_list then
			for index = #trigger_data_list, 1, -1 do
				local trigger_data = trigger_data_list[index]

				if trigger_data.is_corrupt or not alive(trigger_data.notify_unit) and not trigger_data.notify_unit_restore_id then
					if trigger_data.is_corrupt then
						Application:stack_dump_error("Failed to load a timed trigger callback. Id: " .. tostring(trigger_data.id) .. ", Unit: " .. tostring(self._unit))
					end

					print("removing dead unit!", index)
					table.remove(trigger_data_list, index)
				end
			end
		end

		return trigger_data_list
	else
		return nil
	end
end

function CoreUnitDamage:inflict_damage(damage_type, src_body, source_body, normal, position, direction, velocity)
	local damage = nil
	local body_ext = source_body:extension()
	local damage_ext = nil

	if body_ext then
		damage_ext = body_ext.damage

		if damage_ext then
			return damage_ext:inflict_damage(damage_type, self._unit, src_body, normal, position, direction)
		end
	end

	return nil, false
end

function CoreUnitDamage:damage_damage(attack_unit, dest_body, normal, position, direction, damage, unevadable)
	return self:add_damage("damage", attack_unit, dest_body, normal, position, direction, damage, Vector3(0, 0, 0), unevadable)
end

function CoreUnitDamage:damage_bullet(attack_unit, dest_body, normal, position, direction, damage, unevadable)
	return self:add_damage("bullet", attack_unit, dest_body, normal, position, direction, damage, Vector3(0, 0, 0), unevadable)
end

function CoreUnitDamage:damage_bullet_type(type, attack_unit, dest_body, normal, position, direction, damage, unevadable)
	return self:add_damage("bullet_" .. type, attack_unit, dest_body, normal, position, direction, damage, Vector3(0, 0, 0), unevadable)
end

function CoreUnitDamage:damage_lock(attack_unit, dest_body, normal, position, direction, damage, unevadable)
	return self:add_damage("lock", attack_unit, dest_body, normal, position, direction, damage, Vector3(0, 0, 0), unevadable)
end

function CoreUnitDamage:damage_explosion(attack_unit, dest_body, normal, position, direction, damage)
	return self:add_damage("explosion", attack_unit, dest_body, normal, position, direction, damage, Vector3(0, 0, 0))
end

function CoreUnitDamage:damage_collision(attack_unit, dest_body, normal, position, direction, damage, velocity)
	return self:add_damage("collision", attack_unit, dest_body, normal, position, direction, damage, velocity)
end

function CoreUnitDamage:damage_melee(attack_unit, dest_body, normal, position, direction, damage)
	return self:add_damage("melee", attack_unit, dest_body, normal, position, direction, damage, Vector3(0, 0, 0))
end

function CoreUnitDamage:damage_electricity(attack_unit, dest_body, normal, position, direction, damage)
	return self:add_damage("electricity", attack_unit, dest_body, normal, position, direction, damage, Vector3(0, 0, 0))
end

function CoreUnitDamage:damage_fire(attack_unit, dest_body, normal, position, direction, damage, velocity)
	return self:add_damage("fire", attack_unit, dest_body, normal, position, direction, damage, velocity)
end

function CoreUnitDamage:damage_by_area(endurance_type, attack_unit, dest_body, normal, position, direction, damage, velocity)
	local damage_func = self["damage_" .. endurance_type]

	if damage_func then
		return damage_func(self, attack_unit, dest_body, normal, position, direction, damage, velocity)
	else
		Application:error("Unit \"" .. tostring(self._unit:name()) .. "\" doesn't have a \"damage_" .. tostring(endurance_type) .. "\"-function on its unit damage extension.")

		return false, nil
	end
end

function CoreUnitDamage:add_damage(endurance_type, attack_unit, dest_body, normal, position, direction, damage, velocity)
	if self._unit_element then
		self._damage = self._damage + damage

		if self._unit_element:get_endurance() <= self._damage then
			return true, damage
		else
			return false, damage
		end
	else
		return false, 0
	end
end

function CoreUnitDamage:damage_effect(effect_type, attack_unit, dest_body, normal, position, direction, velocity, params)
end

function CoreUnitDamage:run_sequence_simple(name, params)
	self:run_sequence_simple2(name, "", params)
end

function CoreUnitDamage:run_sequence_simple2(name, endurance_type, params)
	self:run_sequence_simple3(name, endurance_type, self._unit, params)
end

function CoreUnitDamage:run_sequence_simple3(name, endurance_type, source_unit, params)
	self:run_sequence(name, endurance_type, source_unit, nil, Vector3(0, 0, 1), self._unit:position(), Vector3(0, 0, -1), 0, Vector3(0, 0, 0), params)
end

function CoreUnitDamage:run_sequence(name, endurance_type, source_unit, dest_body, normal, position, direction, damage, velocity, params)
	self._unit_element:run_sequence(name, endurance_type, source_unit, self._unit, dest_body, normal, position, direction, damage, velocity, params)
end

function CoreUnitDamage:get_damage()
	return self._damage
end

function CoreUnitDamage:get_endurance()
	if self._unit_element then
		return self._unit_element:get_endurance()
	else
		return 0
	end
end

function CoreUnitDamage:get_damage_ratio()
	if self._unit_element and self._unit_element:get_endurance() > 0 then
		return self._damage / self._unit_element:get_endurance()
	else
		return 0
	end
end

function CoreUnitDamage:update_inflict_damage(t, dt)
	if self._inflict_dest_body then
		for damage_type, dest_body in pairs(self._inflict_dest_body) do
			if not self._inflict_done or not self._inflict_done[damage_type] then
				local src_body = self._inflict_src_body and self._inflict_src_body[damage_type]

				if alive(src_body) and alive(dest_body) then
					self:exit_inflict_damage(damage_type, src_body, dest_body)
				end

				if self._inflict_src_body then
					self._inflict_src_body[damage_type] = nil
				end

				if self._inflict_dest_body then
					self._inflict_dest_body[damage_type] = nil
				end
			end
		end
	end

	self._inflict_done = nil
end

function CoreUnitDamage:check_inflict_damage(damage_type, src_body, dest_body, normal, pos, dir, velocity)
	local can_inflict, delayed = self:can_receive_inflict_damage(damage_type, dest_body)
	self._inflict_done = self._inflict_done or {}
	self._inflict_done[damage_type] = self._inflict_done[damage_type] or can_inflict or delayed

	if can_inflict then
		self._inflict_dest_body = self._inflict_dest_body or {}
		self._inflict_src_body = self._inflict_src_body or {}
		local old_dest_body = self._inflict_dest_body[damage_type]

		if alive(old_dest_body) and old_dest_body:key() ~= dest_body:key() then
			self:exit_inflict_damage(damage_type, self._inflict_src_body[damage_type], old_dest_body, normal, pos, dir, velocity)
		end

		self._inflict_dest_body[damage_type] = dest_body
		self._inflict_src_body[damage_type] = src_body
		local entered = self:enter_inflict_damage(damage_type, src_body, dest_body, normal, pos, dir, velocity)

		if not entered or dest_body:extension().damage:get_inflict_instant(damage_type) then
			return self:inflict_damage(damage_type, src_body, dest_body, normal, pos, dir, velocity)
		else
			return false, 0
		end
	end

	return false, nil
end

function CoreUnitDamage:can_receive_inflict_damage(damage_type, dest_body)
	if alive(dest_body) then
		local body_ext = dest_body:extension()

		if body_ext then
			local damage_ext = body_ext.damage

			if damage_ext then
				return damage_ext:can_inflict_damage(damage_type, self._unit)
			end
		end
	end

	return false, false
end

function CoreUnitDamage:enter_inflict_damage(damage_type, src_body, dest_body, normal, position, direction, velocity)
	return dest_body:extension().damage:enter_inflict_damage(damage_type, self._unit, src_body, normal, position, direction, velocity)
end

function CoreUnitDamage:inflict_damage(damage_type, src_body, dest_body, normal, position, direction, velocity)
	return dest_body:extension().damage:inflict_damage(damage_type, self._unit, src_body, normal, position, direction, velocity)
end

function CoreUnitDamage:exit_inflict_damage(damage_type, src_body, dest_body, normal, pos, dir, velocity)
	dest_body:extension().damage:exit_inflict_damage(damage_type, src_body, normal, pos, dir, velocity)
end

function CoreUnitDamage:set_direct_attack_unit(direct_attack_unit)
	self._direct_attack_unit = direct_attack_unit
end

function CoreUnitDamage:get_direct_attack_unit()
	return self._direct_attack_unit
end

function CoreUnitDamage:add_body_collision_callback(func)
	self._last_body_collision_callback_id = (self._last_body_collision_callback_id or 0) + 1
	self._body_collision_callback_list = self._body_collision_callback_list or {}
	self._body_collision_callback_list[self._last_body_collision_callback_id] = func

	return self._last_body_collision_callback_id
end

function CoreUnitDamage:remove_body_collision_callback(id)
	if self._body_collision_callback_list then
		self._body_collision_callback_list[id] = nil
	end
end

function CoreUnitDamage:add_mover_collision_callback(func)
	self._last_mover_collision_callback_id = (self._last_mover_collision_callback_id or 0) + 1
	self._mover_collision_callback_list = self._mover_collision_callback_list or {}
	self._mover_collision_callback_list[self._last_mover_collision_callback_id] = func

	return self._last_mover_collision_callback_id
end

function CoreUnitDamage:remove_mover_collision_callback(id)
	if self._mover_collision_callback_list then
		self._mover_collision_callback_list[id] = nil
	end
end

function CoreUnitDamage:set_ignore_mover_collision_unit(unit_key, time)
	self._ignore_mover_collision_unit_map = self._ignore_mover_collision_unit_map or {}
	self._ignore_mover_collision_unit_map[unit_key] = time
end

function CoreUnitDamage:set_ignore_mover_collision_body(body_key, time)
	self._ignore_mover_collision_body_map = self._ignore_mover_collision_body_map or {}
	self._ignore_mover_collision_body_map[body_key] = time
end

function CoreUnitDamage:clear_ignore_mover_collision_units()
	self._ignore_mover_collision_unit_map = nil
end

function CoreUnitDamage:clear_ignore_mover_collision_bodies()
	self._ignore_mover_collision_body_map = nil
end

function CoreUnitDamage:set_ignore_body_collision_unit(unit_key, time)
	self._ignore_body_collision_unit_map = self._ignore_body_collision_unit_map or {}
	self._ignore_body_collision_unit_map[unit_key] = time
end

function CoreUnitDamage:clear_ignore_body_collision_units()
	self._ignore_body_collision_unit_map = nil
end

function CoreUnitDamage:set_ignore_mover_on_mover_collisions(ignore)
	if ignore then
		self._ignore_mover_on_mover_collisions = true
	else
		self._ignore_mover_on_mover_collisions = nil
	end
end

function CoreUnitDamage:get_ignore_mover_on_mover_collisions()
	return not not self._ignore_mover_on_mover_collisions
end

function CoreUnitDamage:give_body_collision_velocity()
	return not self._skip_give_body_collision_velocity
end

function CoreUnitDamage:set_give_body_collision_velocity(give_body_velocity)
	self._skip_give_body_collision_velocity = not give_body_velocity
end

function CoreUnitDamage:give_mover_collision_velocity()
	return not self._skip_give_mover_collision_velocity
end

function CoreUnitDamage:set_give_mover_collision_velocity(give_mover_velocity)
	self._skip_give_mover_collision_velocity = not give_mover_velocity
end

function CoreUnitDamage:give_body_collision_damage()
	return not self._skip_give_body_collision_damage
end

function CoreUnitDamage:set_give_body_collision_damage(give_body_damage)
	self._skip_give_body_collision_damage = not give_body_damage
end

function CoreUnitDamage:give_mover_collision_damage()
	return not self._skip_give_mover_collision_damage
end

function CoreUnitDamage:set_give_mover_collision_damage(give_mover_damage)
	self._skip_give_mover_collision_damage = not give_mover_damage
end

function CoreUnitDamage:receive_body_collision_damage()
	return not self._skip_receive_body_collision_damage
end

function CoreUnitDamage:set_receive_body_collision_damage(receive_body_damage)
	self._skip_receive_body_collision_damage = not receive_body_damage
end

function CoreUnitDamage:receive_mover_collision_damage()
	return not self._skip_receive_mover_collision_damage
end

function CoreUnitDamage:set_receive_mover_collision_damage(receive_mover_damage)
	self._skip_receive_mover_collision_damage = not receive_mover_damage
end

function CoreUnitDamage:can_mover_collide(time, unit, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity)
	local alive_other_body = alive(other_body)
	local damage_ext = other_unit:damage()

	return (not damage_ext or damage_ext:give_mover_collision_damage()) and not self._skip_receive_mover_collision_damage and self._unit:mover() and (alive_other_body or not self._ignore_mover_on_mover_collisions) and managers.sequence:is_collisions_enabled() and (not self._ignore_mover_collision_unit_map or not self._ignore_mover_collision_unit_map[other_unit:key()] or self._ignore_mover_collision_unit_map[other_unit:key()] < time) and (not alive_other_body or not self._ignore_mover_collision_body_map or not self._ignore_mover_collision_body_map[other_body:key()] or self._ignore_mover_collision_body_map[other_body:key()] < time)
end

function CoreUnitDamage:can_body_collide(time, tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity)
	local damage_ext = other_unit:damage()

	return (not damage_ext or damage_ext:give_body_collision_damage()) and not self._skip_receive_body_collision_damage and managers.sequence:is_collisions_enabled() and (not self._ignore_body_collision_unit_map or not self._ignore_body_collision_unit_map[other_unit:key()] or self._ignore_body_collision_unit_map[other_unit:key()] < time)
end

function CoreUnitDamage:get_collision_velocity(position, body, other_body, other_unit, collision_velocity, normal, is_mover, velocity, other_velocity)
	local damage_ext = other_unit:damage()
	local is_other_mover = not alive(other_body)

	if damage_ext then
		if is_other_mover then
			if not damage_ext:give_mover_collision_velocity() then
				other_velocity = Vector3()
			end
		elseif not damage_ext:give_body_collision_velocity() then
			other_velocity = Vector3()
		end
	end

	if is_mover then
		local other_velocity_dir = other_velocity:normalized()
		local other_velocity_length = other_velocity:length()
		velocity = other_velocity_dir * math.clamp(math.dot(velocity, other_velocity_dir), 0, other_velocity_length)
	end

	collision_velocity = velocity - other_velocity

	if velocity:length() < other_velocity:length() then
		collision_velocity = -collision_velocity
	end

	local direction = collision_velocity:normalized()

	if direction:length() == 0 then
		direction = -normal
	end

	return self:add_angular_velocity(position, direction, body, other_body, other_unit, collision_velocity, is_mover)
end

function CoreUnitDamage:add_angular_velocity(position, direction, body, other_body, other_unit, collision_velocity, is_mover)
	local angular_velocity_addition = Vector3()

	if alive(body) then
		local body_ang_vel = body:angular_velocity()
		angular_velocity_addition = direction * 200 * body_ang_vel:length() * (1 + math.abs(math.dot(body_ang_vel:normalized(), direction))) / (10 * math.pi)
	end

	if alive(other_body) then
		local other_body_ang_vel = other_body:angular_velocity()
		angular_velocity_addition = angular_velocity_addition + direction * 200 * other_body_ang_vel:length() * (1 + math.abs(math.dot(other_body_ang_vel:normalized(), direction))) / (10 * math.pi)
		angular_velocity_addition = direction * math.clamp(angular_velocity_addition:length(), 0, 200)
	end

	return collision_velocity + angular_velocity_addition, direction
end

function CoreUnitDamage:get_collision_damage(tag, body, other_unit, other_body, position, normal, collision_velocity, is_mover_collision)
	return math.clamp((collision_velocity:length() - 400) / 100, 0, 75)
end

function CoreUnitDamage:body_collision_callback(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity)
	local time = TimerManager:game():time()
	local new_velocity, direction, damage = nil

	if self:can_body_collide(time, tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity) then
		new_velocity, direction = self:get_collision_velocity(position, body, other_body, other_unit, collision_velocity, normal, false, velocity, other_velocity)
		damage = self:get_collision_damage(tag, body, other_unit, other_body, position, normal, new_velocity, false)

		self:collision(tag, unit, body, other_unit, other_body, position, normal, direction, damage, new_velocity, false)
	end

	if self._body_collision_callback_list then
		for _, func in pairs(self._body_collision_callback_list) do
			func(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage)
		end
	end
end

function CoreUnitDamage:mover_collision_callback(unit, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity)
	local time = TimerManager:game():time()
	local new_velocity, direction, damage = nil

	if self:can_mover_collide(time, unit, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity) then
		new_velocity, direction = self:get_collision_velocity(position, nil, other_body, other_unit, collision_velocity, normal, true, velocity, other_velocity)
		damage = self:get_collision_damage(nil, nil, other_unit, other_body, position, normal, new_velocity, true)

		if damage > 0 then
			if alive(other_body) then
				local body_list = other_body:constrained_bodies()

				table.insert(body_list, other_body)

				for _, body in ipairs(body_list) do
					self:set_ignore_mover_collision_body(body:key(), time + (self._mover_collision_ignore_duration or 1))
				end
			elseif alive(other_unit) then
				self:set_ignore_mover_collision_unit(other_unit:key(), time + (self._mover_collision_ignore_duration or 1))
			end
		end

		self:collision(nil, unit, nil, other_unit, other_body, position, normal, direction, damage, new_velocity, true)
	end

	if self._mover_collision_callback_list then
		for _, func in pairs(self._mover_collision_callback_list) do
			func(unit, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage)
		end
	end
end

function CoreUnitDamage:collision(tag, unit, body, other_unit, other_body, position, normal, direction, damage, collision_velocity, is_mover_collision)
	if damage > 0 then
		if body then
			local body_ext = body:extension()

			if body_ext and body_ext.damage then
				body_ext.damage:damage_collision(other_unit, normal, position, direction, damage, collision_velocity)
			end
		else
			self:damage_collision(other_unit, body, normal, position, direction, damage, collision_velocity)
		end
	end
end

function CoreUnitDamage:toggle_debug_collision_all()
	self:toggle_debug_collision_body()
	self:toggle_debug_collision_mover()
end

function CoreUnitDamage:set_debug_collision_all(enabled)
	self:toggle_debug_collision_body(enabled)
	self:toggle_debug_collision_mover(enabled)
end

function CoreUnitDamage:toggle_debug_collision_body()
	self:set_debug_collision_body(not self._debug_collision_body_id)
end

function CoreUnitDamage:set_debug_collision_body(enabled)
	if not self._debug_collision_body_id ~= not enabled then
		if enabled then
			self._debug_collision_body_id = self:add_body_collision_callback(callback(self, self, "debug_collision_body"))
		else
			self:remove_body_collision_callback(self._debug_collision_body_id)

			self._debug_collision_body_id = nil
		end

		cat_debug("debug", "Body collision debugging " .. tostring(self._unit) .. " enabled: " .. tostring(not not enabled))
	end
end

function CoreUnitDamage:toggle_debug_collision_mover()
	self:set_debug_collision_mover(not self._debug_collision_mover_id)
end

function CoreUnitDamage:set_debug_collision_mover(enabled)
	if not self._debug_collision_mover_id ~= not enabled then
		if enabled then
			self._debug_collision_mover_id = self:add_mover_collision_callback(callback(self, self, "debug_collision_mover"))
		else
			self:remove_mover_collision_callback(self._debug_collision_mover_id)

			self._debug_collision_mover_id = nil
		end

		cat_debug("debug", "Mover collision debugging " .. tostring(self._unit) .. " enabled: " .. tostring(not not enabled))
	end
end

function CoreUnitDamage:debug_collision_body(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage)
	local time = TimerManager:game():time()

	cat_debug("debug", string.format("[B %g] Velocity: %g, Damage: %g, Ignored: %s", time, new_velocity and new_velocity:length() or 0, damage or 0, tostring(not new_velocity)))

	if managers.debug then
		managers.debug.gui:set_color(1, 1, 1, 1)
		managers.debug.gui:set(1, "[B] \"" .. tostring(alive(self._unit) and self._unit:name() or nil) .. "\" by \"" .. tostring(alive(other_unit) and other_unit:name() or nil) .. "\"")
		self:debug_draw_velocity(2, "[B] Own velocity", position, velocity, 0, 0, 1)
		self:debug_draw_velocity(3, "[B] Other velocity", position, other_velocity, 1, 0, 0)
		self:debug_draw_velocity(4, "[B] Collision velocity", position, collision_velocity, 0, 1, 1)
		self:debug_draw_velocity(5, "[B] Damage velocity", position, new_velocity, 0, 1, 0)
		managers.debug.gui:set_color(6, 1, 0.5, 0.5)
		managers.debug.gui:set(6, "[B] Damage: " .. tostring(damage))
		managers.debug.gui:set_color(7, 0.5, 0.5, 0.5)
		managers.debug.gui:set(7, "[B] Ignored: " .. tostring(not new_velocity))
	end
end

function CoreUnitDamage:debug_collision_mover(unit, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage)
	local time = TimerManager:game():time()

	cat_debug("debug", string.format("[M %g] Velocity: %g, Damage: %g, Ignored: %s", time, new_velocity and new_velocity:length() or 0, damage or 0, tostring(not new_velocity)))

	if managers.debug then
		managers.debug.gui:set_color(1, 1, 1, 1)
		managers.debug.gui:set(1, "[M] \"" .. tostring(alive(self._unit) and self._unit:name() or nil) .. "\" by \"" .. tostring(alive(other_unit) and other_unit:name() or nil) .. "\"")
		self:debug_draw_velocity(2, "[M] Own velocity", position, velocity, 0, 0, 1)
		self:debug_draw_velocity(3, "[M] Other velocity", position, other_velocity, 1, 0, 0)
		self:debug_draw_velocity(4, "[M] Collision velocity", position, collision_velocity, 0, 1, 1)
		self:debug_draw_velocity(5, "[M] Damage velocity", position, new_velocity, 0, 1, 0)
		managers.debug.gui:set_color(6, 1, 0.5, 0.5)
		managers.debug.gui:set(6, "[M] Damage: " .. tostring(damage))
		managers.debug.gui:set_color(7, 0.5, 0.5, 0.5)
		managers.debug.gui:set(7, "[M] Ignored: " .. tostring(not new_velocity))
	end
end

function CoreUnitDamage:debug_draw_velocity(index, label, position, velocity, red, green, blue)
	managers.debug.gui:set_color(index, red, green, blue)

	if velocity then
		managers.debug.gui:set(index, string.format("%s: %g   (%g, %g, %g)", label, velocity:length(), velocity.x, velocity.y, velocity.z))
	else
		managers.debug.gui:set(index, string.format("%s: nil", label))
	end

	managers.debug.pos:set(1, position + Vector3(0, 0, index - 2), "debug_collision_body_" .. index - 1, red, green, blue)
	managers.debug.pos:set(2, position + Vector3(0, 0, index - 2) + (velocity or Vector3()), "debug_collision_body_" .. index - 1, red, green, blue)
end

function CoreUnitDamage:outside_worlds_bounding_box()
	if alive(self._unit) then
		self:kill("collision", self._unit, nil, math.UP, self._unit:position(), math.DOWN, 0, self._unit:sampled_velocity())
	end
end

function CoreUnitDamage:report_enemy_killed()
	if not self._enemy_killed_reported then
		local enemy_data = self._unit:enemy_data()

		if enemy_data then
			local group = enemy_data.enemy_group

			if group then
				group:unit_killed()

				self._enemy_killed_reported = true
			end
		end
	end
end

function CoreUnitDamage:kill(endurance_type, attack_unit, dest_body, normal, position, direction, damage, velocity)
	if alive(self._unit) then
		self:report_enemy_killed()
	end
end

function CoreUnitDamage:remove()
	if alive(self._unit) then
		self:report_enemy_killed()
		self._unit:set_slot(0)
	end
end

function CoreUnitDamage:add_inherit_destroy_unit(unit)
	self._inherit_destroy_unit_list = self._inherit_destroy_unit_list or {}

	table.insert(self._inherit_destroy_unit_list, unit)
end

function CoreUnitDamage:has_sequence(sequence_name)
	return self._unit_element and self._unit_element:has_sequence(sequence_name)
end

function CoreUnitDamage:set_variable(key, val)
	self._variables = self._variables or {}
	self._variables[key] = val

	return self._variables
end

function CoreUnitDamage:anim_clbk_set_sequence_block_state(unit, state)
	state = state == "true" and true or false

	self:set_sequence_block_state(state)
end

function CoreUnitDamage:set_sequence_block_state(state)
	self._sequence_block_state = state

	if not state then
		self:_process_sequence_queue()
	end
end

function CoreUnitDamage:_process_sequence_queue()
	if self._sequence_block_state or not self._queued_sequences then
		return
	end

	while not self._sequence_block_state and self._queued_sequences and next(self._queued_sequences) do
		local front_seq = table.remove(self._queued_sequences, 1)

		self:run_sequence_simple(front_seq.name, front_seq.params)
	end

	if not next(self._queued_sequences) then
		self._queued_sequences = nil
	end
end

function CoreUnitDamage:add_queued_sequence(name, params)
	if not self._sequence_block_state then
		self:run_sequence_simple(name, params)

		return
	end

	self._queued_sequences = self._queued_sequences or {}
	local new_entry = {
		name = name,
		params = params
	}

	table.insert(self._queued_sequences, new_entry)
end

CoreBodyDamage = CoreBodyDamage or class()

function CoreBodyDamage:init(unit, unit_extension, body, body_element)
	self._unit = unit
	self._unit_extension = unit_extension
	self._body = body
	self._body_index = self._unit:get_body_index(self._body:name())
	self._body_element = body_element
	self._unit_element = unit_extension:get_unit_element()
	self._endurance = {}
	self._damage = {}

	if body_element then
		for k, v in pairs(body_element._first_endurance) do
			if k == "collision" then
				self._body:set_collision_script_tag(Idstring("core"))
			end

			self._endurance[k] = v
			self._damage[k] = 0
		end
	end

	if self._body_element then
		local inflict_element_list = self._body_element:get_inflict_element_list()

		if inflict_element_list then
			local updator_class = get_core_or_local("InflictUpdator")

			for damage_type, inflict_element in pairs(inflict_element_list) do
				local updator_type_class = updator_class.INFLICT_UPDATOR_DAMAGE_TYPE_MAP[damage_type]

				if updator_type_class then
					local updator = updator_type_class:new(unit, body, self, inflict_element, self._unit_element)

					if updator:is_valid() then
						self._inflict_updator_map = self._inflict_updator_map or {}
						self._inflict_updator_map[damage_type] = updator
					end
				else
					local inflict_data = {}
					self._inflict = self._inflict or {}
					self._inflict[damage_type] = inflict_data
					inflict_data.damage = inflict_element:get_damage() or 0
					inflict_data.interval = inflict_element:get_interval() or 0
					inflict_data.instant = inflict_element:get_instant()
					inflict_data.enabled = inflict_element:get_enabled()
					inflict_data = {}
					self._original_inflict = self._original_inflict or {}
					self._original_inflict[damage_type] = inflict_data

					for k, v in pairs(inflict_data) do
						inflict_data[k] = v
					end

					self._inflict_time = self._inflict_time or {}
					self._inflict_time[damage_type] = {}
					self._run_exit_inflict_sequences = self._run_exit_inflict_sequences or {}
					self._run_exit_inflict_sequences[damage_type] = inflict_element:exit_sequence_count() > 0
				end
			end
		end
	end
end

function CoreBodyDamage:set_damage(damage_type, damage)
	self._damage[damage_type] = damage
	local element = self._body_element._first_endurance[damage_type]

	while element and element._endurance[damage_type] <= self._damage[damage_type] do
		element = element._next[damage_type]
	end

	self._endurance[damage_type] = element
end

function CoreBodyDamage:get_body()
	return self._body
end

function CoreBodyDamage:get_inflict_updator_map()
	return self._inflict_updator_map
end

function CoreBodyDamage:get_endurance_map()
	return self._endurance
end

function CoreBodyDamage:get_inflict_time(damage_type, src_unit)
	return self._inflict_time[damage_type][src_unit]
end

function CoreBodyDamage:can_inflict_damage(damage_type, src_unit)
	if self._inflict and self._inflict[damage_type] and self._inflict[damage_type].enabled then
		local last_time = self._inflict_time[damage_type][src_unit:key()]

		if last_time then
			local delayed = TimerManager:game():time() < last_time + self._inflict[damage_type].interval

			return not delayed, delayed
		else
			return true, false
		end
	end

	return false, false
end

function CoreBodyDamage:enter_inflict_damage(damage_type, src_unit, src_body, normal, position, direction, velocity)
	local unit_key = src_unit:key()
	local list = self._inflict_time[damage_type]

	if not list[unit_key] then
		list[unit_key] = TimerManager:game():time()
		local damage = self._inflict[damage_type].damage
		local env = CoreSequenceManager.SequenceEnvironment:new(damage_type, src_unit, self._unit, self._body, normal, position, direction, damage, velocity, nil, self._unit_element)

		self._body_element:activate_inflict_enter(env)

		return true
	else
		return false
	end
end

function CoreBodyDamage:exit_inflict_damage(damage_type, src_body, normal, pos, dir, velocity)
	if alive(src_body) then
		local src_unit = src_body:unit()
		local unit_key = src_unit:key()
		local list = self._inflict_time[damage_type]

		if list[unit_key] then
			list[unit_key] = nil

			if self._run_exit_inflict_sequences and self._run_exit_inflict_sequences[damage_type] then
				local env = CoreSequenceManager.SequenceEnvironment:new(damage_type, src_unit, self._unit, self._body, normal, pos, dir, 0, velocity, nil, self._unit_element)

				self._body_element:activate_inflict_exit(env)
			end
		end
	end
end

function CoreBodyDamage:inflict_damage(damage_type, src_unit, src_body, normal, position, direction, velocity)
	local unit_key = src_unit:key()
	self._inflict_time[damage_type][unit_key] = TimerManager:game():time()
	local damage = self._inflict[damage_type].damage
	local env = CoreSequenceManager.SequenceEnvironment:new(damage_type, src_unit, self._unit, self._body, normal, position, direction, damage, velocity, nil, self._unit_element)

	self._body_element:activate_inflict_damage(env)

	local damage_ext = src_body:extension().damage

	return damage_ext["damage_" .. damage_type](damage_ext, self._unit, normal, position, direction, damage, velocity)
end

function CoreBodyDamage:damage_damage(attack_unit, normal, position, direction, damage, unevadable)
	damage = self:damage_endurance("damage", attack_unit, normal, position, direction, damage, Vector3(0, 0, 0))

	return self._unit_extension:damage_damage(attack_unit, self._body, normal, position, direction, damage, unevadable)
end

function CoreBodyDamage:damage_bullet(attack_unit, normal, position, direction, damage, unevadable)
	damage = self:damage_endurance("bullet", attack_unit, normal, position, direction, damage, Vector3(0, 0, 0))

	return self._unit_extension:damage_bullet(attack_unit, self._body, normal, position, direction, damage, unevadable)
end

function CoreBodyDamage:damage_bullet_type(type, attack_unit, normal, position, direction, damage, unevadable)
	damage = self:damage_endurance("bullet_" .. type, attack_unit, normal, position, direction, damage, Vector3(0, 0, 0))

	return self._unit_extension:damage_bullet_type(type, attack_unit, self._body, normal, position, direction, damage, unevadable)
end

function CoreBodyDamage:damage_lock(attack_unit, normal, position, direction, damage, unevadable)
	damage = self:damage_endurance("lock", attack_unit, normal, position, direction, damage, Vector3(0, 0, 0))

	return self._unit_extension:damage_lock(attack_unit, self._body, normal, position, direction, damage, unevadable)
end

function CoreBodyDamage:damage_explosion(attack_unit, normal, position, direction, damage)
	damage = self:damage_endurance("explosion", attack_unit, normal, position, direction, damage, Vector3(0, 0, 0))

	return false, 0
end

function CoreBodyDamage:damage_collision(attack_unit, normal, position, direction, damage, velocity)
	damage = self:damage_endurance("collision", attack_unit, normal, position, direction, damage, velocity)

	return self._unit_extension:damage_collision(attack_unit, self._body, normal, position, direction, damage, velocity)
end

function CoreBodyDamage:damage_melee(attack_unit, normal, position, direction, damage)
	damage = self:damage_endurance("melee", attack_unit, normal, position, direction, damage, Vector3(0, 0, 0))

	return self._unit_extension:damage_melee(attack_unit, self._body, normal, position, direction, damage)
end

function CoreBodyDamage:damage_electricity(attack_unit, normal, position, direction, damage)
	damage = self:damage_endurance("electricity", attack_unit, normal, position, direction, damage, Vector3(0, 0, 0))

	return self._unit_extension:damage_electricity(attack_unit, self._body, normal, position, direction, damage)
end

function CoreBodyDamage:damage_fire(attack_unit, normal, position, direction, damage, velocity)
	damage = self:damage_endurance("fire", attack_unit, normal, position, direction, damage, velocity)

	return self._unit_extension:damage_fire(attack_unit, self._body, normal, position, direction, damage, velocity)
end

function CoreBodyDamage:damage_by_area(endurance_type, attack_unit, normal, position, direction, damage, velocity)
	local damage_func = self["damage_" .. endurance_type]

	if damage_func then
		return damage_func(self, attack_unit, normal, position, direction, damage, velocity)
	else
		Application:error("Unit \"" .. tostring(self._unit:name()) .. "\" doesn't have a \"damage_" .. tostring(endurance_type) .. "\"-function on its body damage extension.")

		return false, nil
	end
end

function CoreBodyDamage:damage_effect(effect_type, attack_unit, normal, position, direction, velocity, params)
	return self._unit_extension:damage_effect(effect_type, attack_unit, self._body, normal, position, direction, velocity, params)
end

function CoreBodyDamage:endurance_exists(endurance_type)
	return self._endurance[endurance_type] ~= nil
end

function CoreBodyDamage:damage_endurance(endurance_type, attack_unit, normal, position, direction, damage, velocity)
	if self._body_element then
		damage = damage * self._body_element._damage_multiplier
	end

	if self._endurance[endurance_type] then
		local env = CoreSequenceManager.SequenceEnvironment:new(endurance_type, attack_unit, self._unit, self._body, normal, position, direction, damage, velocity, nil, self._unit_element)

		self._endurance[endurance_type]:damage(env)
	end

	return damage
end

function CoreBodyDamage:get_body_param(param_name)
	if self._body_element then
		return self._body_element:get_body_param(param_name)
	else
		return nil
	end
end

function CoreBodyDamage:set_inflict_damage(damage_type, damage)
	self:set_inflict_attribute(damage_type, "damage", damage)
end

function CoreBodyDamage:set_inflict_interval(damage_type, interval)
	self:set_inflict_attribute(damage_type, "interval", interval)
end

function CoreBodyDamage:set_inflict_instant(damage_type, instant)
	self:set_inflict_attribute(damage_type, "instant", instant)
end

function CoreBodyDamage:set_inflict_enabled(damage_type, enabled)
	self:set_inflict_attribute(damage_type, "enabled", enabled)
end

function CoreBodyDamage:get_inflict_damage(damage_type)
	return self:get_inflict_attribute(damage_type, "damage")
end

function CoreBodyDamage:get_inflict_interval(damage_type)
	return self:get_inflict_attribute(damage_type, "interval")
end

function CoreBodyDamage:get_inflict_instant(damage_type)
	return self:get_inflict_attribute(damage_type, "instant")
end

function CoreBodyDamage:get_inflict_enabled(damage_type)
	return self:get_inflict_attribute(damage_type, "enabled")
end

function CoreBodyDamage:set_inflict_attribute(damage_type, attribute, attribute_value)
	local inflict = self._inflict and self._inflict[damage_type]

	if inflict then
		if attribute_value ~= nil then
			inflict[attribute] = attribute_value

			return true, true
		else
			return false, true
		end
	else
		local updator = self._inflict_updator_map and self._inflict_updator_map[damage_type]

		if updator then
			return updator:set_attribute(attribute, attribute_value), true
		else
			return false, false
		end
	end
end

function CoreBodyDamage:get_inflict_attribute(damage_type, attribute)
	local inflict = self._inflict and self._inflict[damage_type]

	if inflict then
		return inflict[attribute]
	else
		local updator = self._inflict_updator_map and self._inflict_updator_map[damage_type]

		if updator then
			return updator:get_attribute(attribute)
		else
			error("Tried to get " .. tostring(attribute) .. " on non-existing \"" .. tostring(damage_type) .. "\"-inflict on body \"" .. tostring(self._body and self._body:name()) .. "\" that exist on unit \"" .. tostring(self._unit and self._unit:name()) .. "\".")
		end
	end

	return nil
end

function CoreBodyDamage:save(data)
	local state = {}
	local changed = false

	for k, v in pairs(self._damage) do
		if v ~= 0 then
			state.damage = table.map_copy(self._damage)
			changed = true

			break
		end
	end

	if self._inflict then
		for damage_type, inflict_data in pairs(self._inflict) do
			for k, v in pairs(inflict_data) do
				if v ~= self._original_inflict[damage_type][k] then
					state.inflict = state.inflict or {}
					state.inflict[damage_type] = state.inflict[damage_type] or {}
					state.inflict[damage_type][k] = v
					changed = true
				end
			end
		end
	end

	local updator_state = nil

	if self._inflict_updator_map then
		for damage_type, updator in pairs(self._inflict_updator_map) do
			local sub_updator_state = {}

			if updator:save(sub_updator_state) then
				updator_state = updator_state or {}
				updator_state[damage_type] = sub_updator_state
				changed = true
			end
		end
	end

	state.InflictUpdatorMap = updator_state

	if changed then
		data[self._body_index] = state
	end

	return changed
end

function CoreBodyDamage:load(data)
	local state = data[self._body_index]

	if state then
		if state.damage then
			for damage_type, damage in pairs(state.damage) do
				self:set_damage(damage_type, damage)
			end
		end

		if state.inflict then
			for damage_type, inflict_data in pairs(state.inflict) do
				for k, v in pairs(state.inflict) do
					self._inflict = self._inflict or {}
					self._inflict[damage_type][k] = v
				end
			end
		end

		local updator_state = state.InflictUpdatorMap

		if updator_state and self._inflict_updator_map then
			for damage_type, updator in pairs(self._inflict_updator_map) do
				local sub_updator_state = updator_state[damage_type]

				if sub_updator_state then
					updator:load(sub_updator_state)
				end
			end
		end
	end
end

CoreAfroBodyDamage = CoreAfroBodyDamage or class(CoreBodyDamage)

function CoreAfroBodyDamage:init(unit, unit_extension, body, body_element)
	CoreBodyDamage.init(self, unit, unit_extension, body, body_element)
end

function CoreAfroBodyDamage:damage_bullet(attack_unit, normal, position, direction, damage)
	return self:damage("bullet", attack_unit, normal, position, direction, damage, Vector3(0, 0, 0))
end

function CoreAfroBodyDamage:damage_explosion(attack_unit, normal, position, direction, damage)
	return self:damage("explosion", attack_unit, normal, position, direction, damage, Vector3(0, 0, 0))
end

function CoreAfroBodyDamage:damage_collision(attack_unit, normal, position, direction, damage, velocity)
	return self:damage("collision", attack_unit, normal, position, direction, damage, velocity)
end

function CoreAfroBodyDamage:damage_melee(attack_unit, normal, position, direction, damage)
	return self:damage("melee", attack_unit, normal, position, direction, damage, Vector3(0, 0, 0))
end

function CoreAfroBodyDamage:damage_electricity(attack_unit, normal, position, direction, damage)
	return self:damage("electricity", attack_unit, normal, position, direction, damage, Vector3(0, 0, 0))
end

function CoreAfroBodyDamage:damage_fire(attack_unit, normal, position, direction, damage, velocity)
	return self:damage("fire", attack_unit, normal, position, direction, damage, velocity)
end

function CoreAfroBodyDamage:damage(endurance_type, attack_unit, normal, position, direction, damage, velocity)
	damage = self:damage_endurance(endurance_type, attack_unit, normal, position, direction, damage, velocity)

	return false, 0
end

CoreDamageWaterCheck = CoreDamageWaterCheck or class()
CoreDamageWaterCheck.MIN_INTERVAL = 0.2
CoreDamageWaterCheck.DEFAULT_PHYSIC_EFFECT = "water_box"

function CoreDamageWaterCheck:init(unit, damage_ext, name, interval, ref_object, ref_body, body_depth, physic_effect)
	self._unit = unit
	self._damage_ext = damage_ext
	self._name = name
	self._activation_callbacks_enabled = false
	self._activation_listener_enabled = false
	self._current_ref_body_depth = nil

	self:set_interval(interval)
	self:set_ref_object(ref_object)
	self:set_body_depth(body_depth)
	self:set_ref_body(ref_body)

	self._physic_effect = physic_effect or self.DEFAULT_PHYSIC_EFFECT
	self._body_activation_func = callback(self, self, "body_activated")
	self._water_callback_func = callback(self, self, "water_collision")
	self._check_time = TimerManager:game():time() + math.random() * self._interval
	self._enter_water = false
end

function CoreDamageWaterCheck:is_valid()
	return self._ref_object or self._ref_body
end

function CoreDamageWaterCheck:update(t, dt)
	if self._check_time <= t and self:check_active_body() then
		local enter_water = self._in_water_check_func()

		if not self._enter_water ~= not enter_water then
			self._enter_water = enter_water

			if enter_water then
				self._damage_ext:water_check_enter(self._name, self, self:get_env_variables(enter_water))
			else
				self._damage_ext:water_check_exit(self._name, self, self:get_env_variables(enter_water))
			end
		end
	end
end

function CoreDamageWaterCheck:get_env_variables(enter_water)
	local normal, position, velocity, water_depth = nil

	if enter_water then
		normal = Vector3(0, 0, 1)
	else
		normal = Vector3(0, 0, -1)
	end

	if self._ref_object then
		position = self._ref_object:position()

		if alive(self._ref_body) then
			velocity = self._ref_body:velocity()
			water_depth = self._ref_body:in_water()
		else
			velocity = self._unit:velocity()
			water_depth = 0
		end
	else
		velocity = self._unit:velocity()
		water_depth = 0

		if alive(self._ref_body) then
			position = self._ref_body:position()
		else
			position = self._unit:position()
		end
	end

	return self._unit, self._ref_body, normal, position, velocity:normalized(), 0, velocity, water_depth
end

function CoreDamageWaterCheck:set_update_variables()
	if self._ref_object then
		self._in_water_check_func = callback(self, self, "is_ref_object_in_water")
	elseif alive(self._ref_body) then
		self._in_water_check_func = callback(self, self, "is_ref_body_in_water_depth")
	end
end

function CoreDamageWaterCheck:check_active_body()
	self._check_time = self._check_time + self._interval
	self._current_ref_body_depth = alive(self._ref_body) and self._ref_body:in_water()
	local static = not self._current_ref_body_depth or not self._ref_body:dynamic()

	if not static and not self._ref_body:active() and self._current_ref_body_depth > 0 == self._enter_water then
		self:set_activation_listener_enabled(true)

		return false
	end

	return true
end

function CoreDamageWaterCheck:set_activation_callbacks_enabled(enabled)
	if self._activation_callbacks_enabled ~= enabled then
		self._activation_callbacks_enabled = enabled

		if enabled then
			self._unit:add_body_activation_callback(self._body_activation_func)
			self._unit:add_water_collision_callback(self._water_callback_func)
		else
			self._unit:remove_body_activation_callback(self._body_activation_func)
			self._unit:remove_water_collision_callback(self._water_callback_func)

			self._check_time = TimerManager:game():time() + self._interval
		end
	end
end

function CoreDamageWaterCheck:set_activation_listener_enabled(enabled)
	if self._activation_listener_enabled ~= enabled then
		self._activation_listener_enabled = enabled

		self._damage_ext:set_water_check_active(self._name, not enabled)
		self:set_activation_callbacks_enabled(enabled)
	end
end

function CoreDamageWaterCheck:is_ref_object_in_water()
	return World:in_physic_effect(self._physic_effect, self._ref_object:position())
end

function CoreDamageWaterCheck:is_ref_body_in_water_depth()
	return self._current_ref_body_depth and body_depth < self._current_ref_body_depth
end

function CoreDamageWaterCheck:get_interval()
	return self._interval
end

function CoreDamageWaterCheck:set_interval(interval)
	self._interval = math.max(interval or self.MIN_INTERVAL, self.MIN_INTERVAL)
end

function CoreDamageWaterCheck:get_ref_object()
	return self._ref_object
end

function CoreDamageWaterCheck:set_ref_object(ref_object)
	self._ref_object = ref_object

	self:set_activation_listener_enabled(false)
	self:set_update_variables()
end

function CoreDamageWaterCheck:get_ref_body()
	return self._ref_body
end

function CoreDamageWaterCheck:set_ref_body(ref_body)
	self._ref_body = ref_body

	self:set_activation_listener_enabled(false)

	if self._ref_body then
		self._ref_body_key = self._ref_body:key()

		self._ref_body:set_activate_tag("CoreDamageWaterCheck")
		self._ref_body:set_deactivate_tag("CoreDamageWaterCheck")

		local water_tag = self._ref_body:enter_water_script_tag()

		if not water_tag or #water_tag == 0 then
			water_tag = "CoreDamageWaterCheck"
		end

		self._ref_body:set_enter_water_script_tag(water_tag)
		self._ref_body:set_exit_water_script_tag("CoreDamageWaterCheck")
		self._ref_body:set_enter_water_script_filter(0)
		self._ref_body:set_exit_water_script_filter(0)
	end

	self:set_update_variables()
end

function CoreDamageWaterCheck:get_body_depth()
	return self._body_depth
end

function CoreDamageWaterCheck:set_body_depth(body_depth)
	self._body_depth = math.max(body_depth or 0, 0)
end

function CoreDamageWaterCheck:water_collision(tag, unit, body, surface, enter, position, normal, velocity)
	if not enter ~= not self._enter_water and body:key() == self._ref_body_key then
		self:set_activation_listener_enabled(false)
	end
end

function CoreDamageWaterCheck:body_activated(tag, unit, body, activated)
	if activated and body:key() == self._ref_body_key then
		self:set_activation_listener_enabled(false)
	end
end

function CoreDamageWaterCheck:to_string()
	return string.format("[Unit: %s, Name: %s, Enabled: %s, Interval: %g, Object: %s, Body: %s, Body depth: %g]", self._unit:name(), self._name, tostring(self._damage_ext:is_water_check_active(self._name)), self._interval, tostring(alive(self._ref_object) and self._ref_object:name() or nil), tostring(alive(self._ref_body) and self._ref_body:name() or nil), self._body_depth)
end

CoreInflictUpdator = CoreInflictUpdator or class()
CoreInflictUpdator.INFLICT_UPDATOR_DAMAGE_TYPE_MAP = CoreInflictUpdator.INFLICT_UPDATOR_DAMAGE_TYPE_MAP or {}
CoreInflictUpdator.MIN_INTERVAL = 0.2

function CoreInflictUpdator:init(unit, body, body_damage_ext, inflict_element, unit_element)
	self._unit = unit
	self._body = body
	self._body_damage_ext = body_damage_ext
	self._inflict_element = inflict_element
	self._unit_element = unit_element
	self._update_func = callback(self, self, "update")

	self:set_damage(inflict_element:get_damage() or 0)
	self:set_interval(inflict_element:get_interval() or 1)
	self:set_instant(inflict_element:get_instant())
	self:set_enabled(inflict_element:get_enabled())

	self._original_damage = self._damage
	self._original_interval = self._interval
	self._original_instant = self._instant
	self._original_enabled = self._enabled
	self._check_time = TimerManager:game():time() + self._interval * math.random()
	self._is_inflicting = false
	self._set_attribute_func_map = {
		damage = callback(self, self, "set_damage"),
		interval = callback(self, self, "set_interval"),
		instant = callback(self, self, "set_instant"),
		enabled = callback(self, self, "set_enabled")
	}
	self._get_attribute_func_map = {
		damage = function ()
			return self._damage
		end,
		interval = function ()
			return self._interval
		end,
		instant = function ()
			return self._instant
		end,
		enabled = function ()
			return self._enabled
		end
	}
end

function CoreInflictUpdator:is_valid()
	return true
end

function CoreInflictUpdator:set_damage(damage)
	self._damage = damage or self._damage
end

function CoreInflictUpdator:set_interval(interval)
	local old_interval = self._interval
	self._interval = math.max(interval or self._interval, self.MIN_INTERVAL)

	if old_interval then
		self._check_time = math.clamp(self._check_time, self._check_time - old_interval, TimerManager:game():time() + self._interval)
	end
end

function CoreInflictUpdator:set_instant(instant)
	self._instant = not not instant
end

function CoreInflictUpdator:set_enabled(enabled)
	enabled = not not enabled

	if self._enabled ~= enabled then
		self._enabled = enabled

		if enabled then
			self._id = managers.sequence:add_callback(self._update_func)
			self._check_time = TimerManager:game():time() + math.random() * self._interval
		elseif self._id then
			managers.sequence:remove_callback(self._id)

			self._id = nil
		end
	end
end

function CoreInflictUpdator:save(data)
	local state = {}
	local changed = false

	if self._original_damage ~= self._damage then
		state.damage = self._damage
		changed = true
	end

	if self._original_interval ~= self._interval then
		state.interval = self._interval
		changed = true
	end

	if not self._original_instant ~= not self._instant then
		state.instant = self._instant
		changed = true
	end

	if not self._original_enabled ~= not self._enabled then
		state.enabled = self._enabled
		changed = true
	end

	if changed then
		data.CoreInflictUpdator = state
	end

	return changed
end

function CoreInflictUpdator:load(data)
	local state = data.CoreInflictUpdator

	if state then
		self._damage = state.damage or self._damage
		self._interval = state.interval or self._interval

		if state.instant ~= nil then
			self:set_instant(state.instant)
		end

		if state.enabled ~= nil then
			self:set_enabled(state.enabled)
		end
	end
end

function CoreInflictUpdator:update(t, dt)
	if self._check_time <= t then
		if alive(self._unit) then
			self._check_time = self._check_time + self._interval

			self:check_damage(t, dt)
		else
			self:set_enabled(false)
		end
	end
end

function CoreInflictUpdator:set_attribute(attribute, attribute_value)
	if attribute_value ~= nil then
		local func = self._set_attribute_func_map[attribute]

		if func then
			func(attribute_value)

			return true
		end
	end

	return false
end

function CoreInflictUpdator:get_attribute(attribute)
	if attribute then
		local func = self._get_attribute_func_map[attribute]

		if func then
			return func()
		end
	end

	error("Tried to get non existing attribute \"" .. tostring(attribute) .. "\" on body \"" .. tostring(self._body and self._body:name()) .. "\" that exist on unit \"" .. tostring(self._unit and self._unit:name()) .. "\".")

	return nil
end

CoreInflictFireUpdator = CoreInflictFireUpdator or class(CoreInflictUpdator)
CoreInflictUpdator.INFLICT_UPDATOR_DAMAGE_TYPE_MAP.fire = CoreInflictFireUpdator
CoreInflictFireUpdator.SPHERE_CHECK_SLOTMASK = "fire_damage"
CoreInflictFireUpdator.SPHERE_CHECK_PADDING = 100
CoreInflictFireUpdator.DAMAGE_TYPE = "fire"

function CoreInflictFireUpdator:init(unit, body, body_damage_ext, inflict_element, unit_element)
	CoreInflictUpdator.init(self, unit, body, body_damage_ext, inflict_element, unit_element)

	self._slotmask = managers.slot:get_mask(self.SPHERE_CHECK_SLOTMASK)
	self._velocity = self._inflict_element:get_velocity() or Vector3()
	self._falloff = self._inflict_element:get_falloff()
	self._fire_height = math.max(inflict_element:get_fire_height() or 0, 0)
	self._original_fire_object_name = inflict_element:get_fire_object_name()

	self:set_fire_object_name(self._original_fire_object_name)

	self._original_velocity = self._velocity
	self._original_falloff = self._falloff
	self._original_fire_height = self._fire_height
	local enter_element = inflict_element:get_enter_element()
	self._enter_element_func = enter_element and callback(enter_element, enter_element, "activate")
	local exit_element = inflict_element:get_exit_element()
	self._exit_element_func = exit_element and callback(exit_element, exit_element, "activate")
	local damage_element = inflict_element:get_damage_element()
	self._damage_element_func = damage_element and callback(damage_element, damage_element, "activate")
	self._set_attribute_func_map.fire_object = callback(self, self, "set_fire_object_name")
	self._set_attribute_func_map.fire_height = callback(self, self, "set_fire_height")
	self._set_attribute_func_map.velocity = callback(self, self, "set_velocity")
	self._set_attribute_func_map.falloff = callback(self, self, "set_falloff")

	function self._get_attribute_func_map.fire_object()
		return self._fire_object
	end

	function self._get_attribute_func_map.fire_height()
		return self._fire_height
	end

	function self._get_attribute_func_map.velocity()
		return self._velocity
	end

	function self._get_attribute_func_map.falloff()
		return self._falloff
	end
end

function CoreInflictFireUpdator:is_valid()
	return CoreInflictUpdator.is_valid(self) and self._fire_object ~= nil
end

function CoreInflictFireUpdator:set_fire_object_name(name)
	self._fire_object = name and self._unit:get_object(Idstring(name))

	if not self._fire_object then
		self:set_enabled(false)
		Application:error("Invalid inflict fire element object \"" .. tostring(name) .. "\".")

		local inflict_updator_map = self._body_damage_ext:get_inflict_updator_map()

		if inflict_updator_map then
			inflict_updator_map[self.DAMAGE_TYPE] = nil
		end

		return
	end

	self:set_fire_height(self._fire_height)
end

function CoreInflictFireUpdator:set_fire_height(height)
	self._fire_height = height
	self._sphere_check_range = (self._fire_object:oobb():size() / 2):length() + self._fire_height + self.SPHERE_CHECK_PADDING
end

function CoreInflictFireUpdator:set_velocity(velocity)
	self._velocity = velocity
end

function CoreInflictFireUpdator:set_falloff(falloff)
	self._falloff = falloff
end

function CoreInflictFireUpdator:save(data)
	local state = {}
	local changed = CoreInflictUpdator.save(self, data)

	if Idstring(self._original_fire_object_name) ~= self._fire_object:name() then
		state.fire_object_name = self._fire_object:name()
		changed = true
	end

	if self._original_velocity ~= self._velocity then
		state.velocity = self._velocity
		changed = true
	end

	if self._original_falloff ~= self._falloff then
		state.falloff = self._falloff
		changed = true
	end

	if self._original_fire_height ~= self._fire_height then
		state.fire_height = self._fire_height
		changed = true
	end

	if changed then
		data.CoreInflictFireUpdator = state
	end

	return changed
end

function CoreInflictFireUpdator:load(data)
	CoreInflictUpdator.load(self, data)

	local state = data.CoreInflictUpdator

	if state then
		if state.fire_object_name then
			self:set_fire_object_name(state.fire_object_name)
		end

		if state.fire_height then
			self:set_fire_height(state.fire_height)
		end

		self._velocity = state.velocity or self._velocity
		self._falloff = state.falloff or self._falloff
	end
end

local mvec1 = Vector3()
local mvec2 = Vector3()
local mvec3 = Vector3()

function CoreInflictFireUpdator:check_damage(t, dt)
	local oobb = self._fire_object:oobb()
	local oobb_center = oobb:center()
	local unit_list = self._unit:find_units_quick("sphere", oobb_center, self._sphere_check_range, self._slotmask)
	local inflicted_damage, exit_inflict_env = nil

	for _, unit in ipairs(unit_list) do
		local local_damage = unit == managers.player:player_unit() or unit:id() == -1
		local sync_damage = not local_damage and Network:is_server() and unit:id() ~= -1
		local do_damage = sync_damage or local_damage

		if do_damage then
			local unit_key = unit:key()
			local inflict_body_map = managers.sequence:get_inflict_updator_body_map(self.DAMAGE_TYPE, unit_key)

			if inflict_body_map then
				for body_key, body_ext in pairs(inflict_body_map) do
					local body = body_ext:get_body()

					if alive(body) then
						local body_center = mvec2

						mvector3.set(body_center, body:center_of_mass())

						local distance = oobb:principal_distance(body:oobb())
						local position, normal = nil
						local direction = mvec1

						mvector3.set(direction, oobb_center)
						mvector3.subtract(direction, body_center)
						mvector3.normalize(direction)

						local damage = nil

						if distance > 0 then
							local to = mvec3

							mvector3.set(to, body_center)
							mvector3.set_z(to, mvector3.z(body_center) - self._fire_height)

							position, normal = oobb:raycast(body_center, to)

							if position then
								if self._falloff and self._fire_height > 0 then
									damage = self._damage * math.clamp(1 - distance / self._fire_height, 0, 1)
								else
									damage = self._damage
								end
							end
						else
							normal = -direction
							position = body_center
							damage = self._damage
						end

						if position then
							local was_inflicting = self._is_inflicting
							inflicted_damage = true

							if not self._is_inflicting then
								self._is_inflicting = true

								if self._enter_element_func then
									local env = CoreSequenceManager.SequenceEnvironment:new(self.DAMAGE_TYPE, unit, self._unit, self._body, normal, position, direction, damage, self._velocity, {
										distance = distance
									}, self._unit_element)

									self._enter_element_func(env)
								end
							end

							if was_inflicting or self._instant then
								if self._damage_element_func then
									local env = CoreSequenceManager.SequenceEnvironment:new(self.DAMAGE_TYPE, unit, self._unit, self._body, normal, position, direction, damage, self._velocity, {
										distance = distance
									}, self._unit_element)

									self._damage_element_func(env)
								end

								body_ext:damage_fire(self._unit, normal, position, direction, damage, self._velocity)

								if sync_damage then
									managers.network:session():send_to_peers_synched("sync_inflict_body_damage", body, self._unit, normal, position, direction, damage, self._velocity)
								end
							end
						elseif self._exit_element_func and not exit_inflict_env then
							exit_inflict_env = CoreSequenceManager.SequenceEnvironment:new(self.DAMAGE_TYPE, unit, self._unit, self._body, -direction, body_center, direction, damage, self._velocity, {
								distance = distance
							}, self._unit_element)
						end
					else
						managers.sequence:remove_inflict_updator_body(self.DAMAGE_TYPE, unit_key, body_key)
					end
				end
			end
		end
	end

	if not inflicted_damage and self._is_inflicting then
		self._is_inflicting = false

		if exit_inflict_env then
			self._exit_element_func(exit_inflict_env)
		end
	end
end
