local ids_unit = Idstring("unit")
VehicleFactoryManager = VehicleFactoryManager or class()
VehicleFactoryManager._uses_tasks = false
VehicleFactoryManager._uses_streaming = true

function VehicleFactoryManager:init()
	self:_setup()

	self._tasks = {}
end

function VehicleFactoryManager:_setup()
	if not Global.vehicle_factory then
		Global.vehicle_factory = {}
	end

	self._global = Global.vehicle_factory
	Global.vehicle_factory.loaded_packages = Global.vehicle_factory.loaded_packages or {}
	self._loaded_packages = Global.vehicle_factory.loaded_packages

	self:_read_factory_data()
end

function VehicleFactoryManager:update(t, dt)
	if self._active_task then
		if self:_update_task(self._active_task) then
			self._active_task = nil

			self:_check_task()
		end
	elseif next(self._tasks) then
		self:_check_task()
	end
end

function VehicleFactoryManager:_read_factory_data()
	self._parts_by_type = {}
	local vehicle_data = tweak_data.vehicle

	for id, data in pairs(tweak_data.vehicle.factory.parts) do
		self._parts_by_type[data.type] = self._parts_by_type[data.type] or {}
		self._parts_by_type[data.type][id] = true
	end

	self._parts_by_vehicle = {}
	self._part_used_by_vehicles = {}

	for factory_id, data in pairs(tweak_data.vehicle.factory) do
		if factory_id ~= "parts" and data.dummy_unit then
			self._parts_by_vehicle[factory_id] = self._parts_by_vehicle[factory_id] or {}

			for _, part_id in ipairs(data.uses_parts) do
				local type = tweak_data.vehicle.factory.parts[part_id].type
				self._parts_by_vehicle[factory_id][type] = self._parts_by_vehicle[factory_id][type] or {}

				table.insert(self._parts_by_vehicle[factory_id][type], part_id)
			end
		end
	end
end

function VehicleFactoryManager:get_all_vehicles(include_non_moddable)
	local vehicles = {}

	for factory_id, data in pairs(tweak_data.vehicle.factory) do
		if factory_id ~= "parts" and (data.dummy_unit or include_non_moddable) then
			table.insert(vehicles, factory_id)
		end
	end

	return vehicles
end

function VehicleFactoryManager:get_all_vehicle_categories()
	local vehicle_categories = {}
	local category = nil

	for factory_id, data in pairs(tweak_data.vehicle.factory) do
		if factory_id ~= "parts" and data.dummy_unit then
			category = data.category
			vehicle_categories[category] = vehicle_categories[category] or {}

			table.insert(vehicle_categories[category], factory_id)
		end
	end

	return vehicle_categories
end

function VehicleFactoryManager:get_vehicles_uses_part(part_id)
	return self._part_used_by_vehicles[part_id]
end

function VehicleFactoryManager:get_default_blueprint_by_factory_id(factory_id)
	return tweak_data:get_raw_value("vehicle", "factory", factory_id, "default_blueprint") or {}
end

function VehicleFactoryManager:get_vehicle_name(factory_id)
	if not tweak_data.vehicle.factory[factory_id] or not tweak_data.vehicle.factory[factory_id].name_id then
		return "NONAME"
	end

	return managers.localization:text(tweak_data.vehicle.factory[factory_id].name_id)
end

function VehicleFactoryManager:_indexed_parts(factory_id)
	local i_table = {}
	local all_parts = self._parts_by_vehicle[factory_id]
	local optional_types = tweak_data.vehicle.factory[factory_id].optional_types or {}
	local num_variations = 1
	local tot_parts = 0

	for type, parts in pairs(all_parts) do
		parts = clone(parts)

		if table.contains(optional_types, type) then
			table.insert(parts, "")
		end

		table.insert(i_table, {
			i = 1,
			parts = parts,
			amount = #parts
		})

		num_variations = num_variations * #parts
		tot_parts = tot_parts + #parts
	end

	print("num_variations", num_variations, "tot_parts", tot_parts)

	return i_table
end

function VehicleFactoryManager:create_limited_blueprints(factory_id)
	local i_table = self:_indexed_parts(factory_id)
	local all_parts_used_once = {}

	for j = 1, #i_table do
		for k = j == 1 and 1 or 2, #i_table[j].parts do
			local perm = {}
			local part = i_table[j].parts[k]

			if part ~= "" then
				table.insert(perm, i_table[j].parts[k])
			end

			for l = 1, #i_table do
				if j ~= l then
					local part = i_table[l].parts[1]

					if part ~= "" then
						table.insert(perm, i_table[l].parts[1])
					end
				end
			end

			table.insert(all_parts_used_once, perm)
		end
	end

	print("Limited", #all_parts_used_once)

	return all_parts_used_once
end

function VehicleFactoryManager:create_blueprints(factory_id)
	local i_table = self:_indexed_parts(factory_id)

	local function dump(i_category, result, new_combination_in)
		for i_pryl, pryl_name in ipairs(i_table[i_category].parts) do
			local new_combination = clone(new_combination_in)

			if pryl_name ~= "" then
				table.insert(new_combination, pryl_name)
			end

			if i_category == #i_table then
				table.insert(result, new_combination)
			else
				dump(i_category + 1, result, new_combination)
			end
		end
	end

	local result = {}

	dump(1, result, {})
	print("Combinations", #result)

	return result
end

function VehicleFactoryManager:_check_task()
	if not self._active_task and #self._tasks > 0 then
		self._active_task = table.remove(self._tasks, 1)

		if not alive(self._active_task.p_unit) then
			self._active_task = nil

			self:_check_task()
		end
	end
end

function VehicleFactoryManager:preload_blueprint(factory_id, blueprint, done_cb, only_record)
	return self:_preload_blueprint(factory_id, blueprint, done_cb, only_record)
end

function VehicleFactoryManager:_preload_blueprint(factory_id, blueprint, done_cb, only_record)
	if not done_cb then
		Application:error("[VehicleFactoryManager] _preload_blueprint(): No done_cb!", "factory_id: " .. factory_id, "blueprint: " .. inspect(blueprint))
		Application:stack_dump()
	end

	local factory_vehicle = tweak_data:get_raw_value("vehicle", "factory", factory_id)

	if not factory_vehicle then
		Application:error("[VehicleFactoryManager] _preload_blueprint(): Unknown factory_id!", "factory_id: " .. factory_id, "blueprint: " .. inspect(blueprint))
		Application:stack_dump()
	end

	local forbidden = self:_get_forbidden_parts(factory_id, blueprint)

	return self:_preload_parts(factory_id, factory_vehicle, blueprint, forbidden, done_cb, only_record)
end

function VehicleFactoryManager:_preload_parts(factory_id, factory_vehicle, blueprint, forbidden, done_cb, only_record)
	local parts = {}
	local need_parent = {}
	local override = self:_get_override_parts(factory_id, blueprint)
	local async_task_data = nil

	if not only_record and self._uses_streaming then
		async_task_data = {
			spawn = false,
			parts = parts,
			done_cb = done_cb,
			blueprint = blueprint
		}
		self._async_load_tasks = self._async_load_tasks or {}
		self._async_load_tasks[async_task_data] = true
	end

	for _, part_id in ipairs(blueprint) do
		self:_preload_part(factory_id, part_id, forbidden, override, parts, need_parent, done_cb, async_task_data, only_record)
	end

	for _, part_id in ipairs(need_parent) do
		self:_preload_part(factory_id, part_id, forbidden, override, parts, need_parent, done_cb, async_task_data, only_record)
	end

	if async_task_data then
		async_task_data.all_requests_sent = true

		self:clbk_part_unit_loaded(async_task_data, false, Idstring(), Idstring())
	else
		done_cb(parts, blueprint)
	end

	return parts, blueprint
end

function VehicleFactoryManager:get_assembled_blueprint(factory_id, blueprint)
	local assembled_blueprint = {}
	local factory = tweak_data.vehicle.factory
	local forbidden = self:_get_forbidden_parts(factory_id, blueprint)
	local override = self:_get_override_parts(factory_id, blueprint)

	for _, part_id in ipairs(blueprint) do
		if not forbidden[part_id] then
			local part = self:_part_data(part_id, factory_id, override)
			local original_part = factory.parts[part_id] or part

			if factory[factory_id].adds and factory[factory_id].adds[part_id] then
				local add_blueprint = self:get_assembled_blueprint(factory_id, factory[factory_id].adds[part_id]) or {}

				for i, d in ipairs(add_blueprint) do
					table.insert(assembled_blueprint, d)
				end
			end

			if part.adds_type then
				for _, add_type in ipairs(part.adds_type) do
					local add_id = factory[factory_id][add_type]

					table.insert(assembled_blueprint, add_id)
				end
			end

			if part.adds then
				for _, add_id in ipairs(part.adds) do
					table.insert(assembled_blueprint, add_id)
				end
			end

			table.insert(assembled_blueprint, part_id)
		end
	end

	return assembled_blueprint
end

function VehicleFactoryManager:_preload_part(factory_id, part_id, forbidden, override, parts, need_parent, done_cb, async_task_data, only_record)
	if forbidden[part_id] then
		return
	end

	local factory = tweak_data.vehicle.factory
	local part = self:_part_data(part_id, factory_id, override)
	local original_part = factory.parts[part_id] or part

	if factory[factory_id].adds and factory[factory_id].adds[part_id] then
		for _, add_id in ipairs(factory[factory_id].adds[part_id]) do
			self:_preload_part(factory_id, add_id, forbidden, override, parts, need_parent, done_cb, async_task_data, only_record)
		end
	end

	if part.adds_type then
		for _, add_type in ipairs(part.adds_type) do
			local add_id = factory[factory_id][add_type]

			self:_preload_part(factory_id, add_id, forbidden, override, parts, need_parent, done_cb, async_task_data, only_record)
		end
	end

	if part.adds then
		for _, add_id in ipairs(part.adds) do
			self:_preload_part(factory_id, add_id, forbidden, override, parts, need_parent, done_cb, async_task_data, only_record)
		end
	end

	if parts[part_id] then
		return
	end

	if part.parent and not async_task_data and not self:get_part_from_vehicle_by_type(part.parent, parts) then
		table.insert(need_parent, part_id)

		return
	end

	local unit_name = part.unit
	local ids_unit_name = Idstring(unit_name)
	local original_unit_name = original_part.unit
	local ids_orig_unit_name = Idstring(original_unit_name)
	local package = nil

	if ids_unit_name == ids_orig_unit_name and not self._uses_streaming then
		package = "packages/fps_vehicle_parts/" .. part_id

		if DB:has(Idstring("package"), Idstring(package)) then
			parts[part_id] = {
				package = package
			}

			self:load_package(parts[part_id].package)
		else
			print("[VehicleFactoryManager] Expected vehicle part packages for", part_id)

			package = nil
		end
	end

	if not package then
		parts[part_id] = {
			name = ids_unit_name,
			is_streaming = async_task_data and true or nil
		}

		if not only_record then
			if async_task_data then
				managers.dyn_resource:load(ids_unit, ids_unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE, callback(self, self, "clbk_part_unit_loaded", async_task_data))
			else
				managers.dyn_resource:load(unpack(parts[part_id]))
			end
		end
	end
end

function VehicleFactoryManager:assemble_default(factory_id, p_unit, done_cb, skip_queue)
	local blueprint = clone(tweak_data.vehicle.factory[factory_id].default_blueprint)

	return self:_assemble(factory_id, p_unit, blueprint, done_cb, skip_queue), blueprint
end

function VehicleFactoryManager:assemble_from_blueprint(factory_id, p_unit, blueprint, done_cb, skip_queue)
	return self:_assemble(factory_id, p_unit, blueprint, done_cb, skip_queue)
end

function VehicleFactoryManager:assemble_from_rng(factory_id, p_unit, done_cb, skip_queue)
	local blueprints = self:create_blueprints(factory_id)
	local blueprint = blueprints[math.random(#blueprints)]

	return self:_assemble(factory_id, p_unit, blueprint, done_cb, skip_queue), blueprint
end

local limited_blueprints = {}

function VehicleFactoryManager:assemble_from_limited_cycle(factory_id, p_unit, done_cb, skip_queue)
	limited_blueprints[factory_id] = limited_blueprints[factory_id] or {
		index = 1,
		blueprints = self:create_limited_blueprints(factory_id)
	}

	print("[VehicleFactoryManager:assemble_from_limited_cycle] Cycle index", limited_blueprints[factory_id].index, "Cycle max", #limited_blueprints[factory_id].blueprints)

	local blueprint = limited_blueprints[factory_id].blueprints[limited_blueprints[factory_id].index]
	limited_blueprints[factory_id].index = limited_blueprints[factory_id].index + 1

	if limited_blueprints[factory_id].index > #limited_blueprints[factory_id].blueprints then
		limited_blueprints[factory_id].index = 1

		print("[VehicleFactoryManager:assemble_from_limited_cycle] Recycling")
	end

	return self:_assemble(factory_id, p_unit, blueprint, done_cb, skip_queue), blueprint
end

function VehicleFactoryManager:_assemble(factory_id, p_unit, blueprint, done_cb, skip_queue)
	if not done_cb then
		Application:error("-----------------------------")
		Application:stack_dump()
	end

	local factory = tweak_data.vehicle.factory
	local factory_vehicle = factory[factory_id]
	local forbidden = self:_get_forbidden_parts(factory_id, blueprint)

	return self:_add_parts(p_unit, factory_id, factory_vehicle, blueprint, forbidden, done_cb, skip_queue)
end

function VehicleFactoryManager:_get_forbidden_parts(factory_id, blueprint)
	local factory = tweak_data.vehicle.factory
	local forbidden = {}
	local override = self:_get_override_parts(factory_id, blueprint)

	for _, part_id in ipairs(blueprint) do
		local part = self:_part_data(part_id, factory_id, override)

		if part.depends_on then
			local part_forbidden = true

			for _, other_part_id in ipairs(blueprint) do
				local other_part = self:_part_data(other_part_id, factory_id, override)

				if part.depends_on == other_part.type then
					part_forbidden = false

					break
				end
			end

			if part_forbidden then
				forbidden[part_id] = part.depends_on
			end
		end

		if part.forbids then
			for _, forbidden_id in ipairs(part.forbids) do
				forbidden[forbidden_id] = part_id
			end
		end

		if part.adds then
			local add_forbidden = self:_get_forbidden_parts(factory_id, part.adds)

			for forbidden_id, part_id in pairs(add_forbidden) do
				forbidden[forbidden_id] = part_id
			end
		end
	end

	return forbidden
end

function VehicleFactoryManager:_get_override_parts(factory_id, blueprint)
	local factory = tweak_data.vehicle.factory
	local overridden = {}
	local override_override = {}

	for _, part_id in ipairs(blueprint) do
		local part = self:_part_data(part_id, factory_id)

		if part.override then
			for override_id, override_data in pairs(part.override) do
				if override_data.override then
					override_override[override_id] = override_data
				end
			end
		end
	end

	for _, part_id in ipairs(blueprint) do
		local part = self:_part_data(part_id, factory_id, override_override)

		if part.override then
			for override_id, override_data in pairs(part.override) do
				overridden[override_id] = override_data
			end
		end
	end

	return overridden
end

function VehicleFactoryManager:_update_task(task)
	if not alive(task.p_unit) then
		return true
	end

	if task.blueprint_i <= #task.blueprint then
		local part_id = task.blueprint[task.blueprint_i]

		self:_add_part(task.p_unit, task.factory_id, part_id, task.forbidden, task.override, task.parts, task.need_parent)

		task.blueprint_i = task.blueprint_i + 1

		return
	end

	if task.need_parent_i <= #task.need_parent then
		local part_id = task.need_parent[task.need_parent_i]

		self:_add_part(task.p_unit, task.factory_id, part_id, task.forbidden, task.override, task.parts, task.need_parent)

		task.need_parent_i = task.need_parent_i + 1

		return
	end

	print("VehicleFactoryManager:_update_task done")
	task.done_cb(task.parts, task.blueprint)

	return true
end

function VehicleFactoryManager:_add_parts(p_unit, factory_id, factory_vehicle, blueprint, forbidden, done_cb, skip_queue)
	self._tasks = self._tasks or {}
	local parts = {}
	local need_parent = {}
	local override = self:_get_override_parts(factory_id, blueprint)

	if self._uses_tasks and not skip_queue then
		table.insert(self._tasks, {
			need_parent_i = 1,
			blueprint_i = 1,
			done_cb = done_cb,
			p_unit = p_unit,
			factory_id = factory_id,
			blueprint = blueprint,
			forbidden = forbidden,
			parts = parts,
			need_parent = need_parent,
			override = override
		})
	else
		local async_task_data = nil

		if self._uses_streaming then
			async_task_data = {
				spawn = true,
				parts = parts,
				done_cb = done_cb,
				blueprint = blueprint
			}
			self._async_load_tasks = self._async_load_tasks or {}
			self._async_load_tasks[async_task_data] = true
		end

		for _, part_id in ipairs(blueprint) do
			self:_add_part(p_unit, factory_id, part_id, forbidden, override, parts, need_parent, async_task_data)
		end

		for _, part_id in ipairs(need_parent) do
			self:_add_part(p_unit, factory_id, part_id, forbidden, override, parts, need_parent, async_task_data)
		end

		if async_task_data then
			async_task_data.all_requests_sent = true

			self:clbk_part_unit_loaded(async_task_data, false, Idstring(), Idstring())
		else
			done_cb(parts, blueprint)
		end
	end

	return parts, blueprint
end

function VehicleFactoryManager:_part_data(part_id, factory_id, override)
	local factory = tweak_data.vehicle.factory

	if not factory.parts[part_id] then
		Application:error("[VehicleFactoryManager:_part_data] Part do not exist!", part_id, "factory_id", factory_id)

		return
	end

	local part = deep_clone(factory.parts[part_id])

	if factory[factory_id].override and factory[factory_id].override[part_id] then
		for d, v in pairs(factory[factory_id].override[part_id]) do
			part[d] = type(v) == "table" and deep_clone(v) or v
		end
	end

	if override and override[part_id] then
		for d, v in pairs(override[part_id]) do
			part[d] = type(v) == "table" and deep_clone(v) or v
		end
	end

	return part
end

function VehicleFactoryManager:_add_part(p_unit, factory_id, part_id, forbidden, override, parts, need_parent, async_task_data)
	if forbidden[part_id] then
		return
	end

	local factory = tweak_data.vehicle.factory
	local part = self:_part_data(part_id, factory_id, override)

	if factory[factory_id].adds and factory[factory_id].adds[part_id] then
		for _, add_id in ipairs(factory[factory_id].adds[part_id]) do
			self:_add_part(p_unit, factory_id, add_id, forbidden, override, parts, need_parent, async_task_data)
		end
	end

	if part.adds_type then
		for _, add_type in ipairs(part.adds_type) do
			local add_id = factory[factory_id][add_type]

			self:_add_part(p_unit, factory_id, add_id, forbidden, override, parts, need_parent, async_task_data)
		end
	end

	if part.adds then
		for _, add_id in ipairs(part.adds) do
			self:_add_part(p_unit, factory_id, add_id, forbidden, override, parts, need_parent, async_task_data)
		end
	end

	if parts[part_id] then
		return
	end

	local link_to_unit = p_unit

	if async_task_data then
		if part.parent then
			link_to_unit = nil
		end
	elseif part.parent then
		local parent_part = self:get_part_from_vehicle_by_type(part.parent, parts)

		if parent_part then
			link_to_unit = parent_part.unit
		else
			table.insert(need_parent, part_id)

			return
		end
	end

	local unit_name = part.unit
	local ids_unit_name = Idstring(unit_name)
	local package = nil

	if not async_task_data then
		local tweak_unit_name = tweak_data:get_raw_value("vehicle", "factory", "parts", part_id, "unit")
		local ids_tweak_unit_name = tweak_unit_name and Idstring(tweak_unit_name)

		if ids_tweak_unit_name and ids_tweak_unit_name == ids_unit_name then
			package = "packages/fps_vehicle_parts/" .. part_id

			if DB:has(Idstring("package"), Idstring(package)) then
				print("HAS PART AS PACKAGE")
				self:load_package(package)
			else
				print("[VehicleFactoryManager] Expected vehicle part packages for", part_id)

				package = nil
			end
		end
	end

	if async_task_data then
		parts[part_id] = {
			is_streaming = true,
			animations = part.animations,
			name = ids_unit_name,
			link_to_unit = link_to_unit,
			a_obj = Idstring(part.a_obj),
			parent = part.parent,
			offset = part.offset,
			rotation = part.rotation
		}

		managers.dyn_resource:load(ids_unit, ids_unit_name, "packages/dyn_resources", callback(self, self, "clbk_part_unit_loaded", async_task_data))
	else
		if not package then
			managers.dyn_resource:load(ids_unit, ids_unit_name, "packages/dyn_resources", false)
		end

		local unit = self:_spawn_and_link_unit(ids_unit_name, Idstring(part.a_obj), link_to_unit, part.offset, part.rotation)
		parts[part_id] = {
			unit = unit,
			animations = part.animations,
			name = ids_unit_name,
			package = package
		}
	end
end

function VehicleFactoryManager:clbk_part_unit_loaded(task_data, status, u_type, u_name)
	if not self._async_load_tasks[task_data] then
		return
	end

	local function _spawn(part)
		local unit = self:_spawn_and_link_unit(part.name, part.a_obj, part.link_to_unit, part.offset, part.rotation)

		unit:set_enabled(false)

		part.unit = unit
		part.a_obj = nil
		part.link_to_unit = nil
		part.offset = nil
		part.rotation = nil
	end

	for part_id, part in pairs(task_data.parts) do
		if part.name == u_name and part.is_streaming then
			part.is_streaming = nil

			if part.link_to_unit then
				_spawn(part)
			else
				local parent_part = self:get_part_from_vehicle_by_type(part.parent, task_data.parts)

				if parent_part and parent_part.unit then
					part.link_to_unit = parent_part.unit

					_spawn(part)
				end
			end
		end
	end

	repeat
		local re_iterate = nil

		for part_id, part in pairs(task_data.parts) do
			if not part.unit and not part.is_streaming then
				local parent_part = self:get_part_from_vehicle_by_type(part.parent, task_data.parts)

				if parent_part and parent_part.unit then
					part.link_to_unit = parent_part.unit

					_spawn(part)

					re_iterate = true
				end
			end
		end
	until not re_iterate

	if not task_data.all_requests_sent then
		return
	end

	for part_id, part in pairs(task_data.parts) do
		if part.is_streaming or not part.unit then
			return
		end
	end

	for part_id, part in pairs(task_data.parts) do
		if alive(part.unit) then
			part.unit:set_enabled(true)
		end
	end

	self._async_load_tasks[task_data] = nil

	if not task_data.done_cb then
		return
	end

	task_data.done_cb(task_data.parts, task_data.blueprint)
end

function VehicleFactoryManager:_spawn_and_link_unit(u_name, a_obj, link_to_unit, offset, rotation)
	local unit = World:spawn_unit(u_name, Vector3(), Rotation())
	local res = link_to_unit:link(a_obj, unit, unit:orientation_object():name())

	if managers.occlusion then
		managers.occlusion:remove_occlusion(unit)
	end

	if offset then
		unit:set_local_position(offset)
	end

	if rotation then
		unit:set_local_rotation(rotation)
	end

	return unit
end

function VehicleFactoryManager:load_package(package)
	print("VehicleFactoryManager:_load_package", package)

	if not self._loaded_packages[package] then
		print("  Load for real", package)
		PackageManager:load(package)

		self._loaded_packages[package] = 1
	else
		self._loaded_packages[package] = self._loaded_packages[package] + 1
	end
end

function VehicleFactoryManager:unload_package(package)
	print("VehicleFactoryManager:_unload_package", package)

	if not self._loaded_packages[package] then
		Application:error("Trying to unload package that wasn't loaded")

		return
	end

	self._loaded_packages[package] = self._loaded_packages[package] - 1

	if self._loaded_packages[package] <= 0 then
		print("  Unload for real", package)
		PackageManager:unload(package)

		self._loaded_packages[package] = nil
	end
end

function VehicleFactoryManager:get_parts_from_vehicle_by_type_or_perk(type_or_perk, factory_id, blueprint)
	local factory = tweak_data.vehicle.factory
	local type_parts = {}

	for _, id in ipairs(self:get_assembled_blueprint(factory_id, blueprint)) do
		local part = self:_part_data(id, factory_id)

		if part.type == type_or_perk or part.perks and table.contains(part.perks, type_or_perk) then
			table.insert(type_parts, id)
		end
	end

	return type_parts
end

function VehicleFactoryManager:get_parts_from_vehicle_by_perk(perk, parts)
	local factory = tweak_data.vehicle.factory
	local type_parts = {}

	for id, data in pairs(parts) do
		local perks = factory.parts[id].perks

		if perks and table.contains(perks, perk) then
			table.insert(type_parts, parts[id])
		end
	end

	return type_parts
end

function VehicleFactoryManager:get_custom_stats_from_part_id(part_id)
	local factory = tweak_data.vehicle.factory.parts

	return factory[part_id] and factory[part_id].custom_stats or false
end

function VehicleFactoryManager:get_custom_stats_from_vehicle(factory_id, blueprint)
	local factory = tweak_data.vehicle.factory
	local t = {}

	for _, id in ipairs(self:get_assembled_blueprint(factory_id, blueprint)) do
		local part = self:_part_data(id, factory_id)

		if part.custom_stats then
			t[id] = part.custom_stats
		end
	end

	return t
end

function VehicleFactoryManager:get_part_id_from_vehicle_by_type(type, blueprint)
	local factory = tweak_data.vehicle.factory

	for _, part_id in pairs(blueprint) do
		if factory.parts[part_id].type == type then
			return part_id
		end
	end

	return false
end

function VehicleFactoryManager:get_part_from_vehicle_by_type(type, parts)
	local factory = tweak_data.vehicle.factory

	for id, data in pairs(parts) do
		if factory.parts[id].type == type then
			return parts[id]
		end
	end

	return false
end

function VehicleFactoryManager:get_part_data_type_from_vehicle_by_type(type, data_type, parts)
	local factory = tweak_data.vehicle.factory

	for id, data in pairs(parts) do
		if factory.parts[id].type == type then
			return factory.parts[id][data_type]
		end
	end

	return false
end

function VehicleFactoryManager:is_vehicle_unmodded(factory_id, blueprint)
	local vehicle_tweak = tweak_data.vehicle.factory[factory_id]
	local blueprint_map = {}

	for _, part in ipairs(blueprint) do
		blueprint_map[part] = true
	end

	for _, part in ipairs(vehicle_tweak.default_blueprint) do
		if not blueprint_map[part] then
			return false
		end

		blueprint_map[part] = nil
	end

	return table.size(blueprint_map) == 0
end

function VehicleFactoryManager:has_vehicle_more_than_default_parts(factory_id)
	local vehicle_tweak = tweak_data.vehicle.factory[factory_id]

	return #vehicle_tweak.uses_parts > #vehicle_tweak.default_blueprint
end

function VehicleFactoryManager:get_parts_from_factory_id(factory_id)
	return self._parts_by_vehicle[factory_id]
end

function VehicleFactoryManager:is_part_standard_issue(factory_id, part_id)
	local vehicle_factory_tweak_data = tweak_data.vehicle.factory[factory_id]
	local part_tweak_data = tweak_data.vehicle.factory.parts[part_id]

	if not part_tweak_data then
		Application:error("[VehicleFactoryManager:is_part_standard_issue] Found no part with part id", part_id)

		return false
	end

	if not vehicle_factory_tweak_data then
		Application:error("[VehicleFactoryManager:is_part_standard_issue] Found no vehicle with factory id", factory_id)

		return false
	end

	return table.contains(vehicle_factory_tweak_data.default_blueprint or {}, part_id)
end

function VehicleFactoryManager:get_part_desc_by_part_id_from_vehicle(part_id, factory_id, blueprint)
	local factory = tweak_data.vehicle.factory
	local override = self:_get_override_parts(factory_id, blueprint)
	local part = self:_part_data(part_id, factory_id, override)
	local desc_id = part.desc_id or tweak_data.blackmarket.vehicle_mods[part_id].desc_id

	return desc_id and managers.localization:text(desc_id, {
		BTN_GADGET = managers.localization:btn_macro("vehicle_gadget", true)
	}) or Application:production_build() and "Add ##desc_id## to ##" .. part_id .. "## in tweak_data.blackmarket.vehicle_mods" or ""
end

function VehicleFactoryManager:get_part_data_by_part_id_from_vehicle(part_id, factory_id, blueprint)
	local factory = tweak_data.vehicle.factory
	local override = self:_get_override_parts(factory_id, blueprint)

	return self:_part_data(part_id, factory_id, override)
end

function VehicleFactoryManager:get_part_name_by_part_id_from_vehicle(part_id, factory_id, blueprint)
	local factory = tweak_data.vehicle.factory
	local forbidden = self:_get_forbidden_parts(factory_id, blueprint)
	local override = self:_get_override_parts(factory_id, blueprint)

	if not forbidden[part_id] then
		local part = self:_part_data(part_id, factory_id, override)
		local name_id = part.name_id

		return managers.localization:text(name_id)
	end
end

function VehicleFactoryManager:get_part_desc_by_part_id(part_id)
	local part_tweak_data = tweak_data.vehicle.factory.parts[part_id]

	if not part_tweak_data then
		Application:error("[VehicleFactoryManager:get_part_desc_by_part_id] Found no part with part id", part_id)

		return
	end

	local desc_id = tweak_data.blackmarket.vehicle_mods[part_id].desc_id

	return desc_id and managers.localization:text(desc_id, {
		BTN_GADGET = managers.localization:btn_macro("vehicle_gadget", true)
	}) or Application:production_build() and "Add ##desc_id## to ##" .. part_id .. "## in tweak_data.blackmarket.vehicle_mods" or ""
end

function VehicleFactoryManager:get_part_name_by_part_id(part_id)
	local part_tweak_data = tweak_data.vehicle.factory.parts[part_id]

	if not part_tweak_data then
		Application:error("[VehicleFactoryManager:get_part_name_by_part_id] Found no part with part id", part_id)

		return
	end

	return part_tweak_data.name_id and managers.localization:text(part_tweak_data.name_id)
end

function VehicleFactoryManager:change_part(p_unit, factory_id, part_id, parts, blueprint)
	local factory = tweak_data.vehicle.factory
	local part = factory.parts[part_id]

	if not part then
		Application:error("VehicleFactoryManager:change_part Part", part_id, "doesn't exist!")

		return parts
	end

	local type = part.type

	if self._parts_by_vehicle[factory_id][type] then
		if table.contains(self._parts_by_vehicle[factory_id][type], part_id) then
			for rem_id, rem_data in pairs(parts) do
				if factory.parts[rem_id].type == type then
					table.delete(blueprint, rem_id)

					break
				end
			end

			table.insert(blueprint, part_id)
			self:disassemble(parts)

			return self:assemble_from_blueprint(factory_id, p_unit, blueprint)
		else
			Application:error("VehicleFactoryManager:change_part Part", part_id, "not allowed for vehicle", factory_id, "!")
		end
	else
		Application:error("VehicleFactoryManager:change_part Part", part_id, "not allowed for vehicle", factory_id, "!")
	end

	return parts
end

function VehicleFactoryManager:remove_part_from_blueprint(part_id, blueprint)
	local factory = tweak_data.vehicle.factory
	local part = factory.parts[part_id]

	if not part then
		Application:error("VehicleFactoryManager:remove_part_from_blueprint Part", part_id, "doesn't exist!")

		return
	end

	table.delete(blueprint, part_id)
end

function VehicleFactoryManager:change_part_blueprint_only(factory_id, part_id, blueprint, remove_part)
	local factory = tweak_data.vehicle.factory
	local part = factory.parts[part_id]

	if not part then
		Application:error("VehicleFactoryManager:change_part Part", part_id, " doesn't exist!")

		return false
	end

	local type = part.type

	if remove_part then
		table.delete(blueprint, part_id)

		local forbidden = VehicleFactoryManager:_get_forbidden_parts(factory_id, blueprint) or {}

		for _, rem_id in ipairs(blueprint) do
			if forbidden[rem_id] then
				table.delete(blueprint, rem_id)
			end
		end
	elseif self._parts_by_vehicle[factory_id][type] then
		if table.contains(self._parts_by_vehicle[factory_id][type], part_id) then
			for _, rem_id in ipairs(blueprint) do
				if factory.parts[rem_id].type == type then
					table.delete(blueprint, rem_id)

					break
				end
			end

			table.insert(blueprint, part_id)

			local forbidden = VehicleFactoryManager:_get_forbidden_parts(factory_id, blueprint) or {}

			for _, rem_id in ipairs(blueprint) do
				if forbidden[rem_id] then
					table.delete(blueprint, rem_id)
				end
			end

			return true
		else
			Application:error("VehicleFactoryManager:change_part Part", part_id, "not allowed for vehicle", factory_id, "!")
		end
	else
		Application:error("VehicleFactoryManager:change_part Part", part_id, "not allowed for vehicle", factory_id, "!")
	end

	return false
end

function VehicleFactoryManager:get_replaces_parts(factory_id, part_id, blueprint, remove_part)
	local factory = tweak_data.vehicle.factory
	local part = factory.parts[part_id]

	if not part then
		Application:error("VehicleFactoryManager:change_part Part", part_id, " doesn't exist!")

		return nil
	end

	local replaces = {}
	local type = part.type

	if self._parts_by_vehicle[factory_id][type] then
		if table.contains(self._parts_by_vehicle[factory_id][type], part_id) then
			for _, rep_id in ipairs(blueprint) do
				if factory.parts[rep_id].type == type then
					table.insert(replaces, rep_id)

					break
				end
			end
		else
			Application:error("VehicleFactoryManager:check_replaces_part Part", part_id, "not allowed for vehicle", factory_id, "!")
		end
	else
		Application:error("VehicleFactoryManager:check_replaces_part Part", part_id, "not allowed for vehicle", factory_id, "!")
	end

	return replaces
end

function VehicleFactoryManager:get_removes_parts(factory_id, part_id, blueprint, remove_part)
	local factory = tweak_data.vehicle.factory
	local part = factory.parts[part_id]

	if not part then
		Application:error("VehicleFactoryManager:get_removes_parts Part", part_id, " doesn't exist!")

		return nil
	end

	local removes = {}
	local new_blueprint = deep_clone(blueprint)

	self:change_part_blueprint_only(factory_id, part_id, new_blueprint, remove_part)

	for i, b_id in ipairs(blueprint) do
		if not table.contains(new_blueprint, b_id) then
			local b_part = factory.parts[b_id]

			if b_part and part and b_part.type ~= part.type then
				table.insert(removes, b_id)
			end
		end
	end

	return removes
end

function VehicleFactoryManager:can_add_part(factory_id, part_id, blueprint)
	local new_blueprint = deep_clone(blueprint)

	table.insert(new_blueprint, part_id)

	local forbidden = self:_get_forbidden_parts(factory_id, new_blueprint)

	for forbid_part_id, forbidder_part_id in pairs(forbidden) do
		if forbid_part_id == part_id then
			return forbidder_part_id
		end
	end

	return nil
end

function VehicleFactoryManager:remove_part(p_unit, factory_id, part_id, parts, blueprint, done_cb)
	local factory = tweak_data.vehicle.factory
	local part = factory.parts[part_id]

	if not part then
		Application:error("VehicleFactoryManager:remove_part Part", part_id, "doesn't exist!")

		return parts
	end

	table.delete(blueprint, part_id)
	self:disassemble(parts)

	return self:assemble_from_blueprint(factory_id, p_unit, blueprint, done_cb)
end

function VehicleFactoryManager:remove_part_by_type(p_unit, factory_id, type, parts, blueprint, done_cb)
	local factory = tweak_data.vehicle.factory

	for part_id, part_data in pairs(parts) do
		if factory.parts[part_id].type == type then
			table.delete(blueprint, part_id)

			break
		end
	end

	self:disassemble(parts)

	return self:assemble_from_blueprint(factory_id, p_unit, blueprint, done_cb)
end

function VehicleFactoryManager:change_blueprint(p_unit, factory_id, parts, blueprint, done_cb)
	self:disassemble(parts)

	return self:assemble_from_blueprint(factory_id, p_unit, blueprint, done_cb)
end

function VehicleFactoryManager:blueprint_to_string(factory_id, blueprint)
	local factory = tweak_data.vehicle.factory
	local index_table = {}

	for i, part_id in ipairs(factory[factory_id] and factory[factory_id].uses_parts or {}) do
		index_table[part_id] = i
	end

	local s = ""

	for _, part_id in ipairs(blueprint) do
		if index_table[part_id] then
			s = s .. tostring(index_table[part_id]) .. " "
		else
			Application:error("[VehicleFactoryManager:blueprint_to_string] Part do not exist in vehicle's uses_parts!", "factory_id", factory_id, "part_id", part_id)
		end
	end

	return s
end

function VehicleFactoryManager:unpack_blueprint_from_string(factory_id, blueprint_string)
	local factory = tweak_data.vehicle.factory
	local index_table = string.split(blueprint_string, " ")
	local blueprint = {}
	local part_id = nil

	for _, part_index in ipairs(index_table) do
		part_id = factory[factory_id].uses_parts[tonumber(part_index)]

		if part_id then
			table.insert(blueprint, part_id)
		end
	end

	return blueprint
end

function VehicleFactoryManager:get_stats(factory_id, blueprint)
	local factory = tweak_data.vehicle.factory
	local forbidden = self:_get_forbidden_parts(factory_id, blueprint)
	local override = self:_get_override_parts(factory_id, blueprint)
	local stats = {}

	for _, part_id in ipairs(blueprint) do
		if not forbidden[part_id] and factory.parts[part_id].stats then
			local part = self:_part_data(part_id, factory_id)

			for stat_type, value in pairs(part.stats) do
				stats[stat_type] = stats[stat_type] or 0
				stats[stat_type] = stats[stat_type] + value
			end
		end
	end

	return stats
end

function VehicleFactoryManager:has_perk(perk_name, factory_id, blueprint)
	local factory = tweak_data.vehicle.factory
	local forbidden = self:_get_forbidden_parts(factory_id, blueprint)

	for _, part_id in ipairs(blueprint) do
		if not forbidden[part_id] and factory.parts[part_id].perks then
			for _, perk in ipairs(factory.parts[part_id].perks) do
				if perk == perk_name then
					return true
				end
			end
		end
	end

	return false
end

function VehicleFactoryManager:get_perks_from_part_id(part_id)
	local factory = tweak_data.vehicle.factory

	if not factory.parts[part_id] then
		return {}
	end

	local perks = {}

	if factory.parts[part_id].perks then
		for _, perk in ipairs(factory.parts[part_id].perks) do
			perks[perk] = true
		end
	end

	return perks
end

function VehicleFactoryManager:get_perks(factory_id, blueprint)
	local factory = tweak_data.vehicle.factory
	local forbidden = self:_get_forbidden_parts(factory_id, blueprint)
	local perks = {}

	for _, part_id in ipairs(blueprint) do
		if not forbidden[part_id] and factory.parts[part_id].perks then
			for _, perk in ipairs(factory.parts[part_id].perks) do
				perks[perk] = true
			end
		end
	end

	return perks
end

function VehicleFactoryManager:get_sound_switch(switch_group, factory_id, blueprint)
	local factory = tweak_data.vehicle.factory
	local forbidden = self:_get_forbidden_parts(factory_id, blueprint)

	for _, part_id in ipairs(blueprint) do
		if not forbidden[part_id] and factory.parts[part_id].sound_switch and factory.parts[part_id].sound_switch[switch_group] then
			return factory.parts[part_id].sound_switch[switch_group]
		end
	end

	return nil
end

function VehicleFactoryManager:disassemble(parts)
	for task_data, _ in pairs(self._async_load_tasks or {}) do
		if task_data.parts == parts then
			self._async_load_tasks[task_data] = nil

			break
		end
	end

	local names = {}

	if parts then
		for part_id, data in pairs(parts) do
			if data.package then
				self:unload_package(data.package)
			else
				table.insert(names, data.name)
			end

			if alive(data.unit) then
				World:delete_unit(data.unit)
			end
		end
	end

	parts = {}

	for _, name in pairs(names) do
		managers.dyn_resource:unload(ids_unit, name, "packages/dyn_resources", false)
	end
end

function VehicleFactoryManager:debug_get_stats(factory_id, blueprint)
	local factory = tweak_data.vehicle.factory
	local forbidden = self:_get_forbidden_parts(factory_id, blueprint)
	local stats = {}

	for _, part_id in ipairs(blueprint) do
		if not forbidden[part_id] then
			stats[part_id] = factory.parts[part_id].stats
		end
	end

	return stats
end
