local ids_unit = Idstring("unit")
WeaponFactoryManager = WeaponFactoryManager or class()
WeaponFactoryManager._uses_tasks = false
WeaponFactoryManager._uses_streaming = true

function WeaponFactoryManager:init()
	self:_setup()

	self._tasks = {}

	self:set_use_thq_weapon_parts(managers.user:get_setting("use_thq_weapon_parts"))
end

function WeaponFactoryManager:_setup()
	if not Global.weapon_factory then
		Global.weapon_factory = {}
	end

	self._global = Global.weapon_factory
	Global.weapon_factory.loaded_packages = Global.weapon_factory.loaded_packages or {}
	self._loaded_packages = Global.weapon_factory.loaded_packages

	self:_read_factory_data()
end

function WeaponFactoryManager:set_use_thq_weapon_parts(use_thq_weapon_parts)
	self._use_thq_weapon_parts = use_thq_weapon_parts
end

function WeaponFactoryManager:use_thq_weapon_parts()
	return self._use_thq_weapon_parts
end

function WeaponFactoryManager:update(t, dt)
	if self._active_task then
		if self:_update_task(self._active_task) then
			self._active_task = nil

			self:_check_task()
		end
	elseif next(self._tasks) then
		self:_check_task()
	end
end

function WeaponFactoryManager:_read_factory_data()
	self._parts_by_type = {}
	local weapon_data = tweak_data.weapon

	for id, data in pairs(tweak_data.weapon.factory.parts) do
		self._parts_by_type[data.type] = self._parts_by_type[data.type] or {}
		self._parts_by_type[data.type][id] = true
	end

	self._parts_by_weapon = {}
	self._part_used_by_weapons = {}

	for factory_id, data in pairs(tweak_data.weapon.factory) do
		if factory_id ~= "parts" then
			self._parts_by_weapon[factory_id] = self._parts_by_weapon[factory_id] or {}

			for _, part_id in ipairs(data.uses_parts or {}) do
				local type = tweak_data.weapon.factory.parts[part_id].type
				self._parts_by_weapon[factory_id][type] = self._parts_by_weapon[factory_id][type] or {}

				table.insert(self._parts_by_weapon[factory_id][type], part_id)

				if not string.match(factory_id, "_npc") and weapon_data[self:get_weapon_id_by_factory_id(factory_id)] then
					self._part_used_by_weapons[part_id] = self._part_used_by_weapons[part_id] or {}

					table.insert(self._part_used_by_weapons[part_id], factory_id)
				end
			end
		end
	end
end

function WeaponFactoryManager:get_all_weapon_categories()
	local weapon_categories = {}
	local weapon_data = tweak_data.weapon
	local category = nil

	for factory_id, data in pairs(tweak_data.weapon.factory) do
		if factory_id ~= "parts" and not string.match(factory_id, "_npc") and weapon_data[self:get_weapon_id_by_factory_id(factory_id)] then
			category = weapon_data[self:get_weapon_id_by_factory_id(factory_id)].categories[1]
			weapon_categories[category] = weapon_categories[category] or {}

			table.insert(weapon_categories[category], factory_id)
		end
	end

	return weapon_categories
end

function WeaponFactoryManager:get_all_weapon_families()
	local weapon_families = {}
	local weapon_data = tweak_data.weapon

	for factory_id, data in pairs(tweak_data.weapon.factory) do
		if factory_id ~= "parts" and not string.match(factory_id, "_npc") and weapon_data[self:get_weapon_id_by_factory_id(factory_id)] and data.family then
			weapon_families[data.family] = weapon_families[data.family] or {}

			table.insert(weapon_families[data.family], factory_id)
		end
	end

	return weapon_families
end

function WeaponFactoryManager:get_weapons_uses_part(part_id)
	return self._part_used_by_weapons[part_id]
end

function WeaponFactoryManager:get_weapon_id_by_factory_id(factory_id)
	local upgrade = managers.upgrades:weapon_upgrade_by_factory_id(factory_id)

	if not upgrade then
		Application:error("[WeaponFactoryManager:get_weapon_id_by_factory_id] Found no upgrade for factory id", factory_id)

		return
	end

	return upgrade.weapon_id
end

function WeaponFactoryManager:get_weapon_name_by_weapon_id(weapon_id)
	if not tweak_data.weapon[weapon_id] then
		return
	end

	return managers.localization:text(tweak_data.weapon[weapon_id].name_id)
end

function WeaponFactoryManager:get_weapon_name_by_factory_id(factory_id)
	local upgrade = managers.upgrades:weapon_upgrade_by_factory_id(factory_id)

	if not upgrade then
		Application:error("[WeaponFactoryManager:get_weapon_name_by_factory_id] Found no upgrade for factory id", factory_id)

		return
	end

	local weapon_id = upgrade.weapon_id

	return managers.localization:text(tweak_data.weapon[weapon_id].name_id)
end

function WeaponFactoryManager:get_factory_id_by_weapon_id(weapon_id)
	local upgrade = managers.upgrades:weapon_upgrade_by_weapon_id(weapon_id)

	if not upgrade then
		Application:error("[WeaponFactoryManager:get_factory_id_by_weapon_id] Found no upgrade for factory id", weapon_id)

		return
	end

	return upgrade.factory_id
end

function WeaponFactoryManager:get_default_blueprint_by_factory_id(factory_id)
	return tweak_data.weapon.factory[factory_id] and tweak_data.weapon.factory[factory_id].default_blueprint or {}
end

function WeaponFactoryManager:create_limited_blueprints(factory_id)
	local i_table = self:_indexed_parts(factory_id)
	local all_parts_used_once = {}

	for j = 1, #i_table, 1 do
		for k = j == 1 and 1 or 2, #i_table[j].parts, 1 do
			local perm = {}
			local part = i_table[j].parts[k]

			if part ~= "" then
				table.insert(perm, i_table[j].parts[k])
			end

			for l = 1, #i_table, 1 do
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

function WeaponFactoryManager:create_blueprints(factory_id)
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

function WeaponFactoryManager:_indexed_parts(factory_id)
	local i_table = {}
	local all_parts = self._parts_by_weapon[factory_id]
	local optional_types = tweak_data.weapon.factory[factory_id].optional_types or {}
	local num_variations = 1
	local tot_parts = 0

	for type, parts in pairs(all_parts) do
		print(type, parts)

		if type ~= "foregrip_ext" and type ~= "stock_adapter" and type ~= "sight_special" and type ~= "extra" then
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
	end

	print("num_variations", num_variations, "tot_parts", tot_parts)

	return i_table
end

function WeaponFactoryManager:_check_task()
	if not self._active_task and #self._tasks > 0 then
		self._active_task = table.remove(self._tasks, 1)

		if not alive(self._active_task.p_unit) then
			self._active_task = nil

			self:_check_task()
		end
	end
end

function WeaponFactoryManager:preload_blueprint(factory_id, blueprint, third_person, npc, done_cb, only_record)
	return self:_preload_blueprint(factory_id, blueprint, third_person, npc, done_cb, only_record)
end

function WeaponFactoryManager:_preload_blueprint(factory_id, blueprint, third_person, npc, done_cb, only_record)
	if not done_cb then
		Application:error("[WeaponFactoryManager] _preload_blueprint(): No done_cb!", "factory_id: " .. factory_id, "blueprint: " .. inspect(blueprint))
		Application:stack_dump()
	end

	local factory = tweak_data.weapon.factory
	local factory_weapon = factory[factory_id]
	local forbidden = self:_get_forbidden_parts(factory_id, blueprint)

	return self:_preload_parts(factory_id, factory_weapon, blueprint, forbidden, third_person, npc, done_cb, only_record)
end

function WeaponFactoryManager:_preload_parts(factory_id, factory_weapon, blueprint, forbidden, third_person, npc, done_cb, only_record)
	local parts = {}
	local need_parent = {}
	local override = self:_get_override_parts(factory_id, blueprint)
	local async_task_data = nil

	if not only_record and self._uses_streaming then
		async_task_data = {
			spawn = false,
			third_person = third_person,
			npc = npc,
			parts = parts,
			done_cb = done_cb,
			blueprint = blueprint
		}
		self._async_load_tasks = self._async_load_tasks or {}
		self._async_load_tasks[async_task_data] = true
	end

	for _, part_id in ipairs(blueprint) do
		self:_preload_part(factory_id, part_id, forbidden, override, parts, third_person, need_parent, done_cb, async_task_data, only_record)
	end

	for _, part_id in ipairs(need_parent) do
		self:_preload_part(factory_id, part_id, forbidden, override, parts, third_person, need_parent, done_cb, async_task_data, only_record)
	end

	if async_task_data then
		async_task_data.all_requests_sent = true

		self:clbk_part_unit_loaded(async_task_data, false, Idstring(), Idstring())
	else
		done_cb(parts, blueprint)
	end

	return parts, blueprint
end

function WeaponFactoryManager:get_assembled_blueprint(factory_id, blueprint)
	local assembled_blueprint = {}
	local factory = tweak_data.weapon.factory
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

function WeaponFactoryManager:_preload_part(factory_id, part_id, forbidden, override, parts, third_person, need_parent, done_cb, async_task_data, only_record)
	if forbidden[part_id] then
		return
	end

	local factory = tweak_data.weapon.factory
	local part = self:_part_data(part_id, factory_id, override)
	local original_part = factory.parts[part_id] or part

	if factory[factory_id].adds and factory[factory_id].adds[part_id] then
		for _, add_id in ipairs(factory[factory_id].adds[part_id]) do
			self:_preload_part(factory_id, add_id, forbidden, override, parts, third_person, need_parent, done_cb, async_task_data, only_record)
		end
	end

	if part.adds_type then
		for _, add_type in ipairs(part.adds_type) do
			local add_id = factory[factory_id][add_type]

			self:_preload_part(factory_id, add_id, forbidden, override, parts, third_person, need_parent, done_cb, async_task_data, only_record)
		end
	end

	if part.adds then
		for _, add_id in ipairs(part.adds) do
			self:_preload_part(factory_id, add_id, forbidden, override, parts, third_person, need_parent, done_cb, async_task_data, only_record)
		end
	end

	if parts[part_id] then
		return
	end

	if part.parent and not async_task_data and not self:get_part_from_weapon_by_type(part.parent, parts) then
		table.insert(need_parent, part_id)

		return
	end

	local unit_name = third_person and part.third_unit or part.unit
	local ids_unit_name = Idstring(unit_name)
	local original_unit_name = third_person and original_part.third_unit or original_part.unit
	local ids_orig_unit_name = Idstring(original_unit_name)
	local package = nil

	if not third_person and ids_unit_name == ids_orig_unit_name and not self._uses_streaming then
		package = "packages/fps_weapon_parts/" .. part_id

		if DB:has(Idstring("package"), Idstring(package)) then
			parts[part_id] = {
				package = package
			}

			self:load_package(parts[part_id].package)
		else
			print("[WeaponFactoryManager] Expected weapon part packages for", part_id)

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

function WeaponFactoryManager:assemble_default(factory_id, p_unit, third_person, npc, done_cb, skip_queue)
	local blueprint = clone(tweak_data.weapon.factory[factory_id].default_blueprint)

	return self:_assemble(factory_id, p_unit, blueprint, third_person, npc, done_cb, skip_queue), blueprint
end

function WeaponFactoryManager:assemble_from_blueprint(factory_id, p_unit, blueprint, third_person, npc, done_cb, skip_queue)
	return self:_assemble(factory_id, p_unit, blueprint, third_person, npc, done_cb, skip_queue)
end

function WeaponFactoryManager:_assemble(factory_id, p_unit, blueprint, third_person, npc, done_cb, skip_queue)
	if not done_cb then
		Application:error("-----------------------------")
		Application:stack_dump()
	end

	local factory = tweak_data.weapon.factory
	local factory_weapon = factory[factory_id]
	local forbidden = self:_get_forbidden_parts(factory_id, blueprint)

	return self:_add_parts(p_unit, factory_id, factory_weapon, blueprint, forbidden, third_person, npc, done_cb, skip_queue)
end

function WeaponFactoryManager:_get_forbidden_parts(factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local forbidden = {}
	local override = self:_get_override_parts(factory_id, blueprint)

	for _, part_id in ipairs(blueprint) do
		if self:is_part_valid(part_id) then
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
		else
			Application:error("[WeaponFactoryManager:_get_forbidden_parts] Part do not exist!", part_id, "factory_id", factory_id)

			forbidden[forbidden_id] = part_id
		end
	end

	return forbidden
end

function WeaponFactoryManager:_get_override_parts(factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local overridden = {}
	local override_override = {}

	for _, part_id in ipairs(blueprint) do
		local part = self:_part_data(part_id, factory_id)

		if part and part.override then
			for override_id, override_data in pairs(part.override) do
				if override_data.override then
					override_override[override_id] = override_data
				end
			end
		end
	end

	for _, part_id in ipairs(blueprint) do
		local part = self:_part_data(part_id, factory_id, override_override)

		if part and part.override then
			for override_id, override_data in pairs(part.override) do
				overridden[override_id] = override_data
			end
		end
	end

	return overridden
end

function WeaponFactoryManager:_update_task(task)
	if not alive(task.p_unit) then
		return true
	end

	if task.blueprint_i <= #task.blueprint then
		local part_id = task.blueprint[task.blueprint_i]

		self:_add_part(task.p_unit, task.factory_id, part_id, task.forbidden, task.override, task.parts, task.third_person, task.need_parent)

		task.blueprint_i = task.blueprint_i + 1

		return
	end

	if task.need_parent_i <= #task.need_parent then
		local part_id = task.need_parent[task.need_parent_i]

		self:_add_part(task.p_unit, task.factory_id, part_id, task.forbidden, task.override, task.parts, task.third_person, task.need_parent)

		task.need_parent_i = task.need_parent_i + 1

		return
	end

	print("WeaponFactoryManager:_update_task done")
	task.done_cb(task.parts, task.blueprint)

	return true
end

function WeaponFactoryManager:_add_parts(p_unit, factory_id, factory_weapon, blueprint, forbidden, third_person, npc, done_cb, skip_queue)
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
			third_person = third_person,
			npc = npc,
			parts = parts,
			need_parent = need_parent,
			override = override
		})
	else
		local async_task_data = nil

		if self._uses_streaming then
			async_task_data = {
				spawn = true,
				third_person = third_person,
				npc = npc,
				parts = parts,
				done_cb = done_cb,
				blueprint = blueprint
			}
			self._async_load_tasks = self._async_load_tasks or {}
			self._async_load_tasks[async_task_data] = true
		end

		for _, part_id in ipairs(blueprint) do
			self:_add_part(p_unit, factory_id, part_id, forbidden, override, parts, third_person, need_parent, async_task_data)
		end

		for _, part_id in ipairs(need_parent) do
			self:_add_part(p_unit, factory_id, part_id, forbidden, override, parts, third_person, need_parent, async_task_data)
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

function WeaponFactoryManager:is_part_valid(part_id)
	local valid_part = not not tweak_data.weapon.factory.parts[part_id]

	return valid_part
end

function WeaponFactoryManager:_part_data(part_id, factory_id, override)
	local factory = tweak_data.weapon.factory

	if not self:is_part_valid(part_id) then
		Application:error("[WeaponFactoryManager:_part_data] Part do not exist!", part_id, "factory_id", factory_id)

		return {}
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

function WeaponFactoryManager:_add_part(p_unit, factory_id, part_id, forbidden, override, parts, third_person, need_parent, async_task_data)
	if forbidden[part_id] then
		return
	end

	local factory = tweak_data.weapon.factory
	local part = self:_part_data(part_id, factory_id, override)

	if factory[factory_id].adds and factory[factory_id].adds[part_id] then
		for _, add_id in ipairs(factory[factory_id].adds[part_id]) do
			self:_add_part(p_unit, factory_id, add_id, forbidden, override, parts, third_person, need_parent, async_task_data)
		end
	end

	if part.adds_type then
		for _, add_type in ipairs(part.adds_type) do
			local add_id = factory[factory_id][add_type]

			self:_add_part(p_unit, factory_id, add_id, forbidden, override, parts, third_person, need_parent, async_task_data)
		end
	end

	if part.adds then
		for _, add_id in ipairs(part.adds) do
			self:_add_part(p_unit, factory_id, add_id, forbidden, override, parts, third_person, need_parent, async_task_data)
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
		local parent_part = self:get_part_from_weapon_by_type(part.parent, parts)

		if parent_part then
			link_to_unit = parent_part.unit
		else
			table.insert(need_parent, part_id)

			return
		end
	end

	local unit_name = third_person and part.third_unit or part.unit
	local ids_unit_name = Idstring(unit_name)
	local package = nil

	if not third_person and not async_task_data then
		local tweak_unit_name = tweak_data:get_raw_value("weapon", "factory", "parts", part_id, "unit")
		local ids_tweak_unit_name = tweak_unit_name and Idstring(tweak_unit_name)

		if ids_tweak_unit_name and ids_tweak_unit_name == ids_unit_name then
			package = "packages/fps_weapon_parts/" .. part_id

			if DB:has(Idstring("package"), Idstring(package)) then
				self:load_package(package)
			else
				print("[WeaponFactoryManager] Expected weapon part packages for", part_id)

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
			reload_objects = part.reload_objects
		}

		managers.dyn_resource:load(ids_unit, ids_unit_name, "packages/dyn_resources", callback(self, self, "clbk_part_unit_loaded", async_task_data))
	else
		if not package then
			managers.dyn_resource:load(ids_unit, ids_unit_name, "packages/dyn_resources", false)
		end

		local unit = self:_spawn_and_link_unit(ids_unit_name, Idstring(part.a_obj), third_person, link_to_unit)
		parts[part_id] = {
			unit = unit,
			animations = part.animations,
			name = ids_unit_name,
			package = package,
			reload_objects = part.reload_objects
		}
	end
end

function WeaponFactoryManager:clbk_part_unit_loaded(task_data, status, u_type, u_name)
	if not self._async_load_tasks[task_data] then
		return
	end

	if task_data.spawn then
		local function _spawn(part)
			local unit = self:_spawn_and_link_unit(part.name, part.a_obj, task_data.third_person, part.link_to_unit)

			unit:set_enabled(false)

			part.unit = unit

			part.unit:set_visible(part.link_to_unit:visible())

			part.a_obj = nil
			part.link_to_unit = nil
		end

		for part_id, part in pairs(task_data.parts) do
			if part.name == u_name and part.is_streaming then
				part.is_streaming = nil

				if part.link_to_unit then
					_spawn(part)
				else
					local parent_part = self:get_part_from_weapon_by_type(part.parent, task_data.parts)

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
					local parent_part = self:get_part_from_weapon_by_type(part.parent, task_data.parts)

					if parent_part and parent_part.unit then
						part.link_to_unit = parent_part.unit

						_spawn(part)

						re_iterate = true
					end
				end
			end
		until not re_iterate
	else
		for part_id, part in pairs(task_data.parts) do
			if part.name == u_name and part.is_streaming then
				part.is_streaming = nil
			end
		end
	end

	if not task_data.all_requests_sent then
		return
	end

	for part_id, part in pairs(task_data.parts) do
		if part.is_streaming or task_data.spawn and not part.unit then
			return
		end
	end

	for part_id, part in pairs(task_data.parts) do
		if alive(part.unit) then
			part.unit:set_enabled(true)
			self:_set_visibility(part_id, part, task_data.npc)
		end
	end

	self._async_load_tasks[task_data] = nil

	if not task_data.done_cb then
		return
	end

	task_data.done_cb(task_data.parts, task_data.blueprint)
end

function WeaponFactoryManager:_set_visibility(part_id, part, npc)
	local visibility = self:_visibility_from_part_id(part_id)

	if visibility then
		for _, group in ipairs(visibility) do
			if not group.condition or group:condition(part, npc) then
				for object_name, visible in pairs(group.objects) do
					local object = part.unit:get_object(Idstring(object_name))

					if object then
						object:set_visibility(visible)
					end
				end
			end
		end
	end
end

function WeaponFactoryManager:_visibility_from_part_id(part_id)
	local factory = tweak_data.weapon.factory

	return factory.parts[part_id] and factory.parts[part_id].visibility
end

function WeaponFactoryManager:_spawn_and_link_unit(u_name, a_obj, third_person, link_to_unit)
	local unit = World:spawn_unit(u_name, Vector3(), Rotation())
	local res = link_to_unit:link(a_obj, unit, unit:orientation_object():name())

	if managers.occlusion and not third_person then
		managers.occlusion:remove_occlusion(unit)
	end

	return unit
end

function WeaponFactoryManager:load_package(package)
	if not self._loaded_packages[package] then
		PackageManager:load(package)

		self._loaded_packages[package] = 1
	else
		self._loaded_packages[package] = self._loaded_packages[package] + 1
	end
end

function WeaponFactoryManager:unload_package(package)
	print("WeaponFactoryManager:_unload_package", package)

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

function WeaponFactoryManager:get_parts_from_weapon_by_type_or_perk(type_or_perk, factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local type_parts = {}

	for _, id in ipairs(self:get_assembled_blueprint(factory_id, blueprint)) do
		local part = self:_part_data(id, factory_id)

		if part.type == type_or_perk or part.perks and table.contains(part.perks, type_or_perk) then
			table.insert(type_parts, id)
		end
	end

	return type_parts
end

function WeaponFactoryManager:get_parts_from_weapon_by_perk(perk, parts)
	local factory = tweak_data.weapon.factory
	local type_parts = {}

	for id, data in pairs(parts) do
		local perks = factory.parts[id].perks

		if perks and table.contains(perks, perk) then
			table.insert(type_parts, parts[id])
		end
	end

	return type_parts
end

function WeaponFactoryManager:get_custom_stats_from_part_id(part_id)
	local factory = tweak_data.weapon.factory.parts

	return factory[part_id] and factory[part_id].custom_stats or false
end

function WeaponFactoryManager:get_custom_stats_from_weapon(factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local t = {}

	for _, id in ipairs(self:get_assembled_blueprint(factory_id, blueprint)) do
		local part = self:_part_data(id, factory_id)

		if part.custom_stats then
			t[id] = part.custom_stats
		end
	end

	return t
end

function WeaponFactoryManager:get_ammo_data_from_weapon(factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local t = {}

	for _, id in ipairs(self:get_assembled_blueprint(factory_id, blueprint)) do
		if factory.parts[id].type == "ammo" then
			local part = self:_part_data(id, factory_id)
			t = part.custom_stats
		end
	end

	return t
end

function WeaponFactoryManager:get_part_id_from_weapon_by_type(type, blueprint)
	local factory = tweak_data.weapon.factory

	for _, part_id in pairs(blueprint) do
		if factory.parts[part_id].type == type then
			return part_id
		end
	end

	return false
end

function WeaponFactoryManager:get_part_from_weapon_by_type(type, parts)
	local factory = tweak_data.weapon.factory

	for id, data in pairs(parts) do
		if factory.parts[id].type == type then
			return parts[id]
		end
	end

	return false
end

function WeaponFactoryManager:get_part_data_type_from_weapon_by_type(type, data_type, parts)
	local factory = tweak_data.weapon.factory

	for id, data in pairs(parts) do
		if factory.parts[id].type == type then
			return factory.parts[id][data_type]
		end
	end

	return false
end

function WeaponFactoryManager:is_weapon_unmodded(factory_id, blueprint)
	local weapon_tweak = tweak_data.weapon.factory[factory_id]
	local blueprint_map = {}

	for _, part in ipairs(blueprint) do
		blueprint_map[part] = true
	end

	for _, part in ipairs(weapon_tweak.default_blueprint) do
		if not blueprint_map[part] then
			return false
		end

		blueprint_map[part] = nil
	end

	return table.size(blueprint_map) == 0
end

function WeaponFactoryManager:get_duplicate_parts_by_type(blueprint)
	local duplicate_parts = {}
	local types_gotten = {}
	local parts_tweak = tweak_data.weapon.factory.parts
	local part_type = nil

	for _, part_id in ipairs(blueprint) do
		part_type = parts_tweak[part_id] and parts_tweak[part_id].type

		if part_type then
			if types_gotten[part_type] then
				table.insert(duplicate_parts, part_id)
			end

			types_gotten[part_type] = true
		end
	end

	return duplicate_parts
end

function WeaponFactoryManager:has_weapon_more_than_default_parts(factory_id)
	local weapon_tweak = tweak_data.weapon.factory[factory_id]

	return #weapon_tweak.uses_parts > #weapon_tweak.default_blueprint
end

function WeaponFactoryManager:get_parts_from_factory_id(factory_id)
	return self._parts_by_weapon[factory_id]
end

function WeaponFactoryManager:get_parts_from_weapon_id(weapon_id)
	local factory_id = self:get_factory_id_by_weapon_id(weapon_id)

	return self._parts_by_weapon[factory_id]
end

function WeaponFactoryManager:is_part_standard_issue(factory_id, part_id)
	local weapon_factory_tweak_data = tweak_data.weapon.factory[factory_id]
	local part_tweak_data = tweak_data.weapon.factory.parts[part_id]

	if not part_tweak_data then
		Application:error("[WeaponFactoryManager:is_part_standard_issue] Found no part with part id", part_id)

		return false
	end

	if not weapon_factory_tweak_data then
		Application:error("[WeaponFactoryManager:is_part_standard_issue] Found no weapon with factory id", factory_id)

		return false
	end

	return table.contains(weapon_factory_tweak_data.default_blueprint or {}, part_id)
end

function WeaponFactoryManager:is_part_standard_issue_by_weapon_id(weapon_id, part_id)
	return self:is_part_standard_issue(self:get_factory_id_by_weapon_id(weapon_id), part_id)
end

function WeaponFactoryManager:get_part_desc_by_part_id_from_weapon(part_id, factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local override = self:_get_override_parts(factory_id, blueprint)
	local part = self:_part_data(part_id, factory_id, override)
	local desc_id = part.desc_id or tweak_data.blackmarket.weapon_mods[part_id].desc_id
	local params = {
		BTN_GADGET = managers.localization:btn_macro("weapon_gadget", true),
		BTN_BIPOD = managers.localization:btn_macro("deploy_bipod", true)
	}

	if managers.menu:is_pc_controller() and managers.localization:exists(desc_id .. "_pc") then
		return managers.localization:text(desc_id .. "_pc", params)
	elseif managers.localization:exists(desc_id) then
		return managers.localization:text(desc_id, params)
	end

	return Application:production_build() and managers.localization:text(desc_id) or ""
end

function WeaponFactoryManager:get_part_data_by_part_id_from_weapon(part_id, factory_id, blueprint)
	local override = self:_get_override_parts(factory_id, blueprint)

	return self:_part_data(part_id, factory_id, override)
end

function WeaponFactoryManager:get_part_name_by_part_id_from_weapon(part_id, factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local forbidden = self:_get_forbidden_parts(factory_id, blueprint)
	local override = self:_get_override_parts(factory_id, blueprint)

	if not forbidden[part_id] then
		local part = self:_part_data(part_id, factory_id, override)
		local name_id = part.name_id

		return managers.localization:text(name_id)
	end
end

function WeaponFactoryManager:get_part_desc_by_part_id(part_id)
	local part_tweak_data = tweak_data.weapon.factory.parts[part_id]

	if not part_tweak_data then
		Application:error("[WeaponFactoryManager:get_part_desc_by_part_id] Found no part with part id", part_id)

		return
	end

	local desc_id = tweak_data.blackmarket.weapon_mods[part_id].desc_id

	return desc_id and managers.localization:text(desc_id, {
		BTN_GADGET = managers.localization:btn_macro("weapon_gadget", true)
	}) or Application:production_build() and "Add ##desc_id## to ##" .. part_id .. "## in tweak_data.blackmarket.weapon_mods" or ""
end

function WeaponFactoryManager:get_part_name_by_part_id(part_id)
	local part_tweak_data = tweak_data.weapon.factory.parts[part_id]

	if not part_tweak_data then
		Application:error("[WeaponFactoryManager:get_part_name_by_part_id] Found no part with part id", part_id)

		return
	end

	return managers.localization:text(part_tweak_data.name_id or "")
end

function WeaponFactoryManager:change_part(p_unit, factory_id, part_id, parts, blueprint)
	local factory = tweak_data.weapon.factory
	local part = factory.parts[part_id]

	if not part then
		Application:error("WeaponFactoryManager:change_part Part", part_id, "doesn't exist!")

		return parts
	end

	local type = part.type

	if self._parts_by_weapon[factory_id][type] then
		if table.contains(self._parts_by_weapon[factory_id][type], part_id) then
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
			Application:error("WeaponFactoryManager:change_part Part", part_id, "not allowed for weapon", factory_id, "!")
		end
	else
		Application:error("WeaponFactoryManager:change_part Part", part_id, "not allowed for weapon", factory_id, "!")
	end

	return parts
end

function WeaponFactoryManager:remove_part_from_blueprint(part_id, blueprint)
	local factory = tweak_data.weapon.factory
	local part = factory.parts[part_id]

	if not part then
		Application:error("WeaponFactoryManager:remove_part_from_blueprint Part", part_id, "doesn't exist!")

		return
	end

	table.delete(blueprint, part_id)
end

function WeaponFactoryManager:change_part_blueprint_only(factory_id, part_id, blueprint, remove_part)
	local factory = tweak_data.weapon.factory
	local part = factory.parts[part_id]

	if not part then
		Application:error("WeaponFactoryManager:change_part Part", part_id, " doesn't exist!")

		return false
	end

	local type = part.type

	if remove_part then
		table.delete(blueprint, part_id)

		local forbidden = WeaponFactoryManager:_get_forbidden_parts(factory_id, blueprint) or {}

		for _, rem_id in ipairs(blueprint) do
			if forbidden[rem_id] then
				table.delete(blueprint, rem_id)
			end
		end
	elseif self._parts_by_weapon[factory_id][type] then
		if table.contains(self._parts_by_weapon[factory_id][type], part_id) then
			for _, rem_id in ipairs(blueprint) do
				if factory.parts[rem_id].type == type then
					table.delete(blueprint, rem_id)

					break
				end
			end

			table.insert(blueprint, part_id)

			local forbidden = WeaponFactoryManager:_get_forbidden_parts(factory_id, blueprint) or {}

			for _, rem_id in ipairs(blueprint) do
				if forbidden[rem_id] then
					table.delete(blueprint, rem_id)
				end
			end

			return true
		else
			Application:error("WeaponFactoryManager:change_part Part", part_id, "not allowed for weapon", factory_id, "!")
		end
	else
		Application:error("WeaponFactoryManager:change_part Part", part_id, "not allowed for weapon", factory_id, "!")
	end

	return false
end

function WeaponFactoryManager:get_replaces_parts(factory_id, part_id, blueprint, remove_part)
	local factory = tweak_data.weapon.factory
	local part = factory.parts[part_id]

	if not part then
		Application:error("WeaponFactoryManager:change_part Part", part_id, " doesn't exist!")

		return nil
	end

	local replaces = {}
	local type = part.type

	if self._parts_by_weapon[factory_id][type] then
		if table.contains(self._parts_by_weapon[factory_id][type], part_id) then
			for _, rep_id in ipairs(blueprint) do
				if factory.parts[rep_id].type == type then
					table.insert(replaces, rep_id)

					break
				end
			end
		else
			Application:error("WeaponFactoryManager:check_replaces_part Part", part_id, "not allowed for weapon", factory_id, "!")
		end
	else
		Application:error("WeaponFactoryManager:check_replaces_part Part", part_id, "not allowed for weapon", factory_id, "!")
	end

	return replaces
end

function WeaponFactoryManager:get_removes_parts(factory_id, part_id, blueprint, remove_part)
	local factory = tweak_data.weapon.factory
	local part = factory.parts[part_id]

	if not part then
		Application:error("WeaponFactoryManager:get_removes_parts Part", part_id, " doesn't exist!")

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

function WeaponFactoryManager:can_add_part(factory_id, part_id, blueprint)
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

function WeaponFactoryManager:remove_part(p_unit, factory_id, part_id, parts, blueprint)
	local factory = tweak_data.weapon.factory
	local part = factory.parts[part_id]

	if not part then
		Application:error("WeaponFactoryManager:remove_part Part", part_id, "doesn't exist!")

		return parts
	end

	table.delete(blueprint, part_id)
	self:disassemble(parts)

	return self:assemble_from_blueprint(factory_id, p_unit, blueprint)
end

function WeaponFactoryManager:remove_part_by_type(p_unit, factory_id, type, parts, blueprint)
	local factory = tweak_data.weapon.factory

	for part_id, part_data in pairs(parts) do
		if factory.parts[part_id].type == type then
			table.delete(blueprint, part_id)

			break
		end
	end

	self:disassemble(parts)

	return self:assemble_from_blueprint(factory_id, p_unit, blueprint)
end

function WeaponFactoryManager:change_blueprint(p_unit, factory_id, parts, blueprint)
	self:disassemble(parts)

	return self:assemble_from_blueprint(factory_id, p_unit, blueprint)
end

function WeaponFactoryManager:blueprint_to_string(factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local index_table = {}

	for i, part_id in ipairs(factory[factory_id] and factory[factory_id].uses_parts or {}) do
		index_table[part_id] = i
	end

	local s = ""

	for _, part_id in ipairs(blueprint) do
		if index_table[part_id] then
			s = s .. tostring(index_table[part_id]) .. " "
		else
			Application:error("[WeaponFactoryManager:blueprint_to_string] Part do not exist in weapon's uses_parts!", "factory_id", factory_id, "part_id", part_id)
		end
	end

	return s
end

function WeaponFactoryManager:unpack_blueprint_from_string(factory_id, blueprint_string)
	local factory = tweak_data.weapon.factory
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

function WeaponFactoryManager:get_stats(factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local forbidden = self:_get_forbidden_parts(factory_id, blueprint)
	local override = self:_get_override_parts(factory_id, blueprint)
	local stats = {}

	for _, part_id in ipairs(blueprint) do
		if not forbidden[part_id] and factory.parts[part_id].stats then
			local part = self:_part_data(part_id, factory_id)

			for stat_type, value in pairs(part.stats) do
				if type(value) == "number" then
					stats[stat_type] = stats[stat_type] or 0
					stats[stat_type] = stats[stat_type] + value
				elseif type(value) == "table" then
					stats[stat_type] = stats[stat_type] or {}

					for i = 1, #value, 1 do
						stats[stat_type][i] = stats[stat_type][i] or 0
						stats[stat_type][i] = stats[stat_type][i] + value[i]
					end
				end
			end
		end
	end

	return stats
end

function WeaponFactoryManager:get_stance_mod(factory_id, blueprint, using_second_sight)
	local factory = tweak_data.weapon.factory
	local assembled_blueprint = self:get_assembled_blueprint(factory_id, blueprint)
	local forbidden = self:_get_forbidden_parts(factory_id, assembled_blueprint)
	local override = self:_get_override_parts(factory_id, assembled_blueprint)
	local part = nil
	local translation = Vector3()
	local rotation = Rotation()

	for _, part_id in ipairs(assembled_blueprint) do
		if not forbidden[part_id] then
			part = self:_part_data(part_id, factory_id, override)

			if part.stance_mod and (part.type ~= "sight" and part.type ~= "gadget" or using_second_sight and part.type == "gadget" or not using_second_sight and part.type == "sight") and part.stance_mod[factory_id] then
				local part_translation = part.stance_mod[factory_id].translation

				if part_translation then
					mvector3.add(translation, part_translation)
				end

				local part_rotation = part.stance_mod[factory_id].rotation

				if part_rotation then
					mrotation.multiply(rotation, part_rotation)
				end
			end
		end
	end

	return {
		translation = translation,
		rotation = rotation
	}
end

function WeaponFactoryManager:has_perk(perk_name, factory_id, blueprint)
	local factory = tweak_data.weapon.factory
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

function WeaponFactoryManager:get_perk_stats(perk_name, factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local forbidden = self:_get_forbidden_parts(factory_id, blueprint)

	for _, part_id in ipairs(blueprint) do
		if not forbidden[part_id] and factory.parts[part_id].perks then
			for _, perk in ipairs(factory.parts[part_id].perks) do
				if perk == perk_name then
					return factory.parts[part_id].stats
				end
			end
		end
	end

	return nil
end

function WeaponFactoryManager:get_type_from_part_id(part_id)
	local factory = tweak_data.weapon.factory

	return factory.parts[part_id] and factory.parts[part_id].type
end

function WeaponFactoryManager:get_perks_from_part_id(part_id)
	local factory = tweak_data.weapon.factory

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

function WeaponFactoryManager:get_perks(factory_id, blueprint)
	local factory = tweak_data.weapon.factory
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

function WeaponFactoryManager:get_sound_switch(switch_group, factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local forbidden = self:_get_forbidden_parts(factory_id, blueprint)
	local t = {}

	for _, part_id in ipairs(blueprint) do
		if not forbidden[part_id] and factory.parts[part_id].sound_switch and factory.parts[part_id].sound_switch[switch_group] and not table.contains(t, part_id) then
			table.insert(t, part_id)
		end
	end

	if #t > 0 then
		if #t > 1 then
			local part_x, part_y = nil

			table.sort(t, function (x, y)
				part_x = factory.parts[x]
				part_y = factory.parts[y]

				if part_x.sub_type == "silencer" then
					return true
				end

				if part_y.sub_type == "silencer" then
					return false
				end

				return x < y
			end)
		end

		return factory.parts[t[1]].sound_switch[switch_group]
	end

	return nil
end

function WeaponFactoryManager:disassemble(parts)
	for task_data, _ in pairs(self._async_load_tasks) do
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

function WeaponFactoryManager:save(data)
	data.weapon_factory = self._global
end

function WeaponFactoryManager:load(data)
	self._global = data.weapon_factory
end

function WeaponFactoryManager:debug_get_stats(factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local forbidden = self:_get_forbidden_parts(factory_id, blueprint)
	local stats = {}

	for _, part_id in ipairs(blueprint) do
		if not forbidden[part_id] then
			stats[part_id] = factory.parts[part_id].stats
		end
	end

	return stats
end
