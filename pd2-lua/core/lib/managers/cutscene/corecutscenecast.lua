CoreCutsceneCast = CoreCutsceneCast or class()

function CoreCutsceneCast:prime(cutscene)
	assert(cutscene and cutscene:is_valid(), "Attempting to prime invalid cutscene.")

	local preload = true

	self:_actor_units_in_cutscene(cutscene)
	self:_animation_blob_controller(cutscene, preload)
end

function CoreCutsceneCast:unload()
	for _, blob_controller in pairs(self._animation_blob_controllers or {}) do
		if blob_controller ~= false and alive(blob_controller) then
			if blob_controller:is_playing() then
				blob_controller:stop()
			end

			blob_controller:destroy()
		end
	end

	self._animation_blob_controllers = nil

	for _, unit in pairs(self._spawned_units or {}) do
		if alive(unit) then
			local unit_type = unit:name()

			World:delete_unit(unit)
		end
	end

	self._spawned_units = nil

	if alive(self.__root_unit) then
		World:delete_unit(self.__root_unit)
	end

	self.__root_unit = nil
end

function CoreCutsceneCast:is_ready(cutscene)
	local blob_controller = cutscene and self:_animation_blob_controller(cutscene)

	return blob_controller == nil or blob_controller:ready()
end

function CoreCutsceneCast:set_timer(timer)
	for _, unit in pairs(self._spawned_units or {}) do
		if alive(unit) then
			unit:set_timer(timer)
			unit:set_animation_timer(timer)
		end
	end
end

function CoreCutsceneCast:set_cutscene_visible(cutscene, visible)
	for unit_name, unit in pairs(self._spawned_units or {}) do
		if cutscene:has_unit(unit_name, true) then
			self:_set_unit_and_children_visible(unit, visible and self:unit_visible(unit_name))
		end
	end
end

function CoreCutsceneCast:set_unit_visible(unit_name, visible)
	visible = not not visible
	self._hidden_units = self._hidden_units or {}
	local current_visibility = not self._hidden_units[unit_name]

	if visible ~= current_visibility then
		self._hidden_units[unit_name] = not visible or nil
		local unit = self:unit(unit_name)

		if unit then
			self:_set_unit_and_children_visible(unit, visible)
		end
	end
end

function CoreCutsceneCast:unit_visible(unit_name)
	return (self._hidden_units and self._hidden_units[unit_name]) == nil
end

function CoreCutsceneCast:unit(unit_name)
	return self._spawned_units and self._spawned_units[unit_name]
end

function CoreCutsceneCast:actor_unit(unit_name, cutscene)
	local unit = self:unit(unit_name)

	if unit and cutscene:has_unit(unit_name) then
		return unit
	else
		return self:_actor_units_in_cutscene(cutscene)[unit_name]
	end
end

function CoreCutsceneCast:unit_names()
	return self._spawned_units and table.map_keys(self._spawned_units) or {}
end

function CoreCutsceneCast:evaluate_cutscene_at_time(cutscene, time)
	self._last_evaluated_cutscene = self._last_evaluated_cutscene or cutscene

	if cutscene ~= self._last_evaluated_cutscene then
		self:_stop_animations_on_actor_units_in_cutscene(self._last_evaluated_cutscene)
	end

	local orientation_unit = cutscene:find_spawned_orientation_unit()

	if orientation_unit and self:_root_unit():parent() ~= orientation_unit then
		self:_reparent_to_locator_unit(orientation_unit, self:_root_unit())
	end

	local blob_controller = self:_animation_blob_controller(cutscene)

	if blob_controller then
		if blob_controller:ready() then
			if not blob_controller:is_playing() then
				local actor_units = self:_actor_units_in_cutscene(cutscene)
				local blend_sets = table.remap(actor_units, function (unit_name)
					return unit_name, cutscene:blend_set_for_unit(unit_name)
				end)

				blob_controller:play(actor_units, blend_sets)
				blob_controller:pause()
			end

			blob_controller:set_time(time)
		end
	else
		for unit_name, unit in pairs(self:_actor_units_in_cutscene(cutscene)) do
			local unit_animation = cutscene:animation_for_unit(unit_name)

			if unit_animation then
				local machine = unit:anim_state_machine()

				if not machine:enabled() then
					machine:set_enabled(true)

					if not self:_state_machine_is_playing_raw_animation(machine, unit_animation) then
						machine:play_raw(unit_animation)
					end
				end

				local anim_length = cutscene:duration()
				local normalized_time = anim_length == 0 and 0 or time / anim_length

				machine:set_parameter(unit_animation, "t", normalized_time)
			end
		end
	end

	self._last_evaluated_cutscene = cutscene
end

function CoreCutsceneCast:evaluate_object_at_time(cutscene, unit_name, object_name, time)
	assert(cutscene:is_optimized(), "Currently only supported with optimized cutscenes.")

	local blob_controller = self:_animation_blob_controller(cutscene)

	if alive(blob_controller) and blob_controller:ready() and blob_controller:is_playing() then
		local bone_name = unit_name .. object_name

		return blob_controller:position(bone_name, time), blob_controller:rotation(bone_name, time)
	else
		return Vector3(0, 0, 0), Rotation()
	end
end

function CoreCutsceneCast:spawn_unit(unit_name, unit_type)
	if DB:has("unit", unit_type) then
		cat_print("cutscene", string.format("[CoreCutsceneCast] Spawning \"%s\" named \"%s\".", unit_type, unit_name))
		World:effect_manager():set_spawns_enabled(false)

		local unit = safe_spawn_unit(unit_type, Vector3(0, 0, 0), Rotation())

		World:effect_manager():set_spawns_enabled(true)
		unit:set_timer(managers.cutscene:timer())
		unit:set_animation_timer(managers.cutscene:timer())
		self:_reparent_to_locator_unit(self:_root_unit(), unit)
		self:_set_unit_and_children_visible(unit, false)
		unit:set_animation_lod(1, 100000, 10000000, 10000000)

		if unit:cutscene() and unit:cutscene().setup then
			unit:cutscene():setup()
		end

		if unit:anim_state_machine() then
			unit:anim_state_machine():set_enabled(false)
		end

		managers.cutscene:actor_database():append_unit_info(unit)

		self._spawned_units = self._spawned_units or {}
		self._spawned_units[unit_name] = unit

		return unit
	else
		error("Unit type \"" .. tostring(unit_type) .. "\" not found.")
	end
end

function CoreCutsceneCast:delete_unit(unit_name)
	local unit = self:unit(unit_name)

	if unit and alive(unit) then
		local unit_type = unit:name()

		World:delete_unit(unit)
	end

	if self._spawned_units then
		self._spawned_units[unit_name] = nil
	end

	if self._hidden_units then
		self._hidden_units[unit_name] = nil
	end

	return unit ~= nil
end

function CoreCutsceneCast:rename_unit(unit_name, new_unit_name)
	local unit = self:unit(unit_name)

	if unit then
		self._spawned_units[unit_name] = nil
		self._spawned_units[new_unit_name] = unit

		if self._hidden_units and self._hidden_units[unit_name] then
			self._hidden_units[unit_name] = nil
			self._hidden_units[new_unit_name] = true
		end

		return true
	end

	return false
end

function CoreCutsceneCast:_stop_animations_on_actor_units_in_cutscene(cutscene)
	local blob_controller = self:_animation_blob_controller(cutscene)

	if blob_controller then
		blob_controller:stop()
	else
		for unit_name, unit in pairs(self:_actor_units_in_cutscene(cutscene)) do
			local machine = unit:anim_state_machine()

			if machine then
				machine:set_enabled(false)
			end
		end
	end
end

function CoreCutsceneCast:_state_machine_is_playing_raw_animation(machine, animation)
	local state_names = table.collect(machine:config():states(), function (state)
		return state:name()
	end)

	return table.contains(state_names, animation) and machine:is_playing(animation)
end

function CoreCutsceneCast:_reparent_to_locator_unit(parent, child)
	local parent_locator = assert(parent:get_object("locator"), "Parent does not have an Object named \"locator\".")

	child:unlink()
	parent:link(parent_locator:name(), child, child:orientation_object():name())
end

function CoreCutsceneCast:_set_unit_and_children_visible(unit, visible, excluded_units)
	unit:set_visible(visible)
	unit:set_enabled(visible)

	excluded_units = excluded_units or table.remap(self._spawned_units or {}, function (unit_name, unit)
		return unit, true
	end)

	for _, child in ipairs(unit:children()) do
		if not excluded_units[child] then
			self:_set_unit_and_children_visible(child, visible, excluded_units)
		end
	end
end

function CoreCutsceneCast:_animation_blob_controller(cutscene, preloading)
	if cutscene:animation_blobs() == nil then
		return nil
	end

	self._animation_blob_controllers = self._animation_blob_controllers or {}
	local blob_controller = self._animation_blob_controllers[cutscene]

	if blob_controller == nil then
		if not preloading then
			Application:error("The cutscene \"" .. cutscene:name() .. "\" was not preloaded, causing a performance spike.")
		end

		blob_controller = CutScene:load(cutscene:animation_blobs())
		self._animation_blob_controllers[cutscene] = blob_controller
	end

	return blob_controller
end

function CoreCutsceneCast:_actor_units_in_cutscene(cutscene)
	self._spawned_units = self._spawned_units or {}
	local result = {}

	for unit_name, unit_type in pairs(cutscene:controlled_unit_types()) do
		local unit = self._spawned_units[unit_name]

		if unit == nil then
			unit = self:spawn_unit(unit_name, unit_type)
		elseif not alive(unit) then
			cat_print("debug", string.format("[CoreCutsceneCast] Zombie Unit detected! Actor \"%s\" of unit type \"%s\" in cutscene \"%s\".", unit_name, unit_type, cutscene:name()))

			unit = nil
		else
			assert(unit:name() == unit_type, "Named unit type mismatch.")
		end

		result[unit_name] = unit
	end

	return result
end

function CoreCutsceneCast:_root_unit()
	if self.__root_unit == nil then
		self.__root_unit = World:spawn_unit(Idstring("core/units/locator/locator"), Vector3(0, 0, 0), Rotation())
	end

	return self.__root_unit
end
