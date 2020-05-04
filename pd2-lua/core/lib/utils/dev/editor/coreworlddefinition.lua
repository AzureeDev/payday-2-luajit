core:module("CoreWorldDefinition")
core:import("CoreUnit")
core:import("CoreMath")
core:import("CoreEditorUtils")
core:import("CoreEngineAccess")

local sky_orientation_data_key = Idstring("sky_orientation/rotation"):key()
WorldDefinition = WorldDefinition or class()

function WorldDefinition:init(params)
	managers.worlddefinition = self
	self._world_dir = params.world_dir
	self._cube_lights_path = params.cube_lights_path

	PackageManager:set_resource_loaded_clbk(Idstring("unit"), nil)
	self:_load_world_package()

	self._definition = self:_serialize_to_script(params.file_type, params.file_path)
	self._continent_definitions = {}
	self._continents = {}
	self._portal_slot_mask = World:make_slot_mask(1)
	self._massunit_replace_names = {}
	self._replace_names = {}
	self._replace_units_path = "assets/lib/utils/dev/editor/xml/replace_units"

	self:_parse_replace_unit()

	self._ignore_spawn_list = {}
	self._excluded_continents = {}

	self:_parse_world_setting(params.world_setting)

	self._blacklist_data = {}

	self:_load_blacklist()
	self:parse_continents()
	managers.sequence:preload()
	PackageManager:set_resource_loaded_clbk(Idstring("unit"), callback(managers.sequence, managers.sequence, "clbk_pkg_manager_unit_loaded"))

	self._all_units = {}
	self._trigger_units = {}
	self._use_unit_callbacks = {}
	self._mission_element_units = {}
	self._delayed_units = {}
	self._termination_counter = 0
end

function WorldDefinition:_serialize_to_script(type, name)
	if Application:editor() then
		return PackageManager:editor_load_script_data(type:id(), name:id())
	else
		if not PackageManager:has(type:id(), name:id()) then
			Application:throw_exception("Script data file " .. name .. " of type " .. type .. " has not been loaded. Could be that old world format is being loaded. Try resaving the level.")
		end

		return PackageManager:script_data(type:id(), name:id())
	end
end

function WorldDefinition:get_max_id()
	return self._definition.world_data.max_id
end

function WorldDefinition:_parse_replace_unit()
	local is_editor = Application:editor()

	if DB:has("xml", self._replace_units_path) then
		local node = DB:load_node("xml", self._replace_units_path)

		for unit in node:children() do
			local old_name = unit:name()
			local replace_with = unit:parameter("replace_with")
			self._replace_names[old_name] = replace_with

			if is_editor then
				managers.editor:output_info("Unit " .. old_name .. " will be replaced with " .. replace_with)
			end
		end
	end
end

function WorldDefinition:world_dir()
	return self._world_dir
end

function WorldDefinition:continent_excluded(name)
	return self._excluded_continents[name]
end

function WorldDefinition:_load_world_package()
	if Application:editor() then
		return
	end

	local package = self._world_dir .. "world"

	if not DB:is_bundled() and not DB:has("package", package) then
		Application:throw_exception("No world.package file found in " .. self._world_dir .. ", please resave level")

		return
	end

	if not PackageManager:loaded(package) then
		PackageManager:load(package)

		self._current_world_package = package
	end

	local package = self._world_dir .. "world_init"

	if not DB:is_bundled() and not DB:has("package", package) then
		Application:throw_exception("No world_init.package file found in " .. self._world_dir .. ", please resave level")

		return
	end

	if not PackageManager:loaded(package) then
		PackageManager:load(package)

		self._current_world_init_package = package
	end

	self:_load_sound_package()
end

function WorldDefinition:_load_sound_package()
	local package = self._world_dir .. "world_sounds"

	if not DB:is_bundled() and not DB:has("package", package) then
		Application:error("No world_sounds.package file found in " .. self._world_dir .. ", emitters and ambiences won't work (resave level)")

		return
	end

	if not PackageManager:loaded(package) then
		PackageManager:load(package)

		self._current_sound_package = package
	end
end

function WorldDefinition:_load_continent_init_package(path)
	if Application:editor() then
		return
	end

	if not DB:is_bundled() and not DB:has("package", path) then
		Application:error("Missing init package for a continent(" .. path .. "), resave level " .. self._world_dir .. ".")

		return
	end

	self._continent_init_packages = self._continent_init_packages or {}

	if not PackageManager:loaded(path) then
		PackageManager:load(path)
		table.insert(self._continent_init_packages, path)
	end
end

function WorldDefinition:_load_continent_package(path)
	function blacklist_filter_pred(t, name)
		if t == Idstring("unit") then
			return not self._blacklist_data[name:key()]
		end

		return true
	end

	if Application:editor() then
		return
	end

	if not PackageManager:package_exists(path) then
		Application:error("Missing package for a continent(" .. path .. "), resave level " .. self._world_dir .. ".")

		return
	end

	self._continent_packages = self._continent_packages or {}

	if not PackageManager:loaded(path) then
		PackageManager:load_filtered(path, blacklist_filter_pred)
		table.insert(self._continent_packages, path)
	end
end

function WorldDefinition:unload_packages()
	self:_unload_package(self._current_world_package)
	self:_unload_package(self._current_sound_package)

	for _, package in ipairs(self._continent_packages) do
		self:_unload_package(package)
	end
end

function WorldDefinition:_unload_package(package)
	if not package then
		return
	end

	if PackageManager:loaded(package) then
		PackageManager:unload(package)
	end
end

function WorldDefinition:_parse_world_setting(world_setting)
	if not world_setting then
		return
	end

	local path = self:world_dir() .. world_setting

	if not DB:has("world_setting", path) then
		Application:error("There is no world_setting file " .. world_setting .. " at path " .. path)

		return
	end

	local t = self:_serialize_to_script("world_setting", path)

	if t._meta then
		Application:throw_exception("Loading old world setting file (" .. path .. "), resave it!")
	end

	for name, bool in pairs(t) do
		self._excluded_continents[name] = bool
	end
end

function WorldDefinition:_load_blacklist()
	if not Application:editor() then
		local path = self:world_dir() .. "blacklist"

		if DB:has("blacklist", path) then
			local blacklist_data = self:_serialize_to_script("blacklist", path)

			for _, k in ipairs(blacklist_data) do
				self._blacklist_data[Idstring(k):key()] = true
			end
		end
	end
end

function WorldDefinition:parse_continents(node, t)
	local path = self:world_dir() .. self._definition.world_data.continents_file

	if not DB:has("continents", path) then
		Application:error("Continent file didn't exist " .. path .. ").")

		return
	end

	self._continents = self:_serialize_to_script("continents", path)
	self._continents._meta = nil

	for name, data in pairs(self._continents) do
		if not self:_continent_editor_only(data) then
			if not self._excluded_continents[name] then
				local init_path = self:world_dir() .. name .. "/" .. name .. "_init"

				self:_load_continent_init_package(init_path)

				local path = self:world_dir() .. name .. "/" .. name

				self:_load_continent_package(path)

				if DB:has("continent", path) then
					self._continent_definitions[name] = self:_serialize_to_script("continent", path)

					if Application:editor() then
						local path = self:world_dir() .. name .. "/mission"

						if DB:has("continent", path) then
							local mission_data = self:_serialize_to_script("continent", path)

							for mission_data_name, mission_data_block in pairs(mission_data) do
								self._continent_definitions[name][mission_data_name] = mission_data_block
							end
						end
					end
				else
					Application:error("Continent file " .. path .. ".continent doesnt exist.")
				end
			end
		else
			self._excluded_continents[name] = true
		end
	end

	self:_insert_instances()
end

function WorldDefinition:_insert_instances()
	for name, data in pairs(self._continent_definitions) do
		if data.instances then
			for i, instance in ipairs(data.instances) do
				local package_data = managers.world_instance:packages_by_instance(instance)

				self:_load_continent_init_package(package_data.init_package)
				self:_load_continent_package(package_data.package)

				if Application:editor() or not instance.mission_placed then
					local prepared_unit_data = managers.world_instance:prepare_unit_data(instance, self._continents[instance.continent])

					if prepared_unit_data.statics then
						for _, static in ipairs(prepared_unit_data.statics) do
							data.statics = data.statics or {}

							table.insert(data.statics, static)
						end
					end

					if prepared_unit_data.dynamics then
						for _, dynamic in ipairs(prepared_unit_data.dynamics) do
							data.dynamics = data.dynamics or {}

							table.insert(data.dynamics, dynamic)
						end
					end
				else
					managers.world_instance:prepare_serialized_instance_data(instance)
				end
			end
		end
	end
end

function WorldDefinition:_continent_editor_only(data)
	return not Application:editor() and data.editor_only
end

function WorldDefinition:init_done()
	if self._continent_init_packages then
		for _, package in ipairs(self._continent_init_packages) do
			self:_unload_package(package)
		end
	end

	self:_unload_package(self._current_world_init_package)

	self._continent_definitions = nil
	self._definition = nil
end

function WorldDefinition:create(layer, offset)
	Application:check_termination()

	offset = offset or Vector3()
	local return_data = {}

	if (layer == "level_settings" or layer == "all") and self._definition.level_settings then
		self:_load_level_settings(self._definition.level_settings.settings, offset)

		return_data = self._definition.level_settings.settings
	end

	if layer == "markers" then
		return_data = self._definition.world_data.markers
	end

	if layer == "values" then
		local t = {}

		for name, continent in pairs(self._continent_definitions) do
			t[name] = continent.values
		end

		return_data = t
	end

	if layer == "editor_groups" then
		return_data = self:_create_editor_groups()
	end

	if layer == "continents" then
		return_data = self._continents
	end

	if layer == "instances" or layer == "all" then
		for name, continent in pairs(self._continent_definitions) do
			if continent.instances then
				for _, data in ipairs(continent.instances) do
					managers.world_instance:add_instance_data(data)
					table.insert(return_data, data)
				end
			end
		end
	end

	if layer == "ai" and self._definition.ai then
		for _, values in ipairs(self._definition.ai) do
			local unit = self:_create_ai_editor_unit(values, offset)

			if unit then
				table.insert(return_data, unit)
			end
		end
	end

	if layer == "ai" or layer == "all" then
		if self._definition.ai_nav_graphs then
			self:_load_ai_nav_graphs(self._definition.ai_nav_graphs, offset)
			Application:cleanup_thread_garbage()
		end

		if self._definition.ai_mop_graphs then
			self:_load_ai_mop_graphs(self._definition.ai_mop_graphs, offset)
			Application:cleanup_thread_garbage()
		end
	end

	Application:check_termination()

	if (layer == "ai_settings" or layer == "all") and self._definition.ai_settings then
		return_data = self:_load_ai_settings(self._definition.ai_settings, offset)
	end

	Application:check_termination()

	if (layer == "portal" or layer == "all") and self._definition.portal then
		self:_create_portal(self._definition.portal, offset)

		return_data = self._definition.portal
	end

	Application:check_termination()

	if layer == "sounds" or layer == "all" then
		return_data = self:_create_sounds(self._definition.sounds)
	end

	Application:check_termination()

	if layer == "mission_scripts" then
		return_data.scripts = return_data.scripts or {}

		if self._definition.mission_scripts then
			for _, values in ipairs(self._definition.mission_scripts) do
				for name, script in pairs(values) do
					return_data.scripts[name] = script
				end
			end
		end

		for name, continent in pairs(self._continent_definitions) do
			if continent.mission_scripts then
				for _, values in ipairs(continent.mission_scripts) do
					for name, script in pairs(values) do
						return_data.scripts[name] = script
					end
				end
			end
		end
	end

	if layer == "mission" then
		if self._definition.mission then
			for _, values in ipairs(self._definition.mission) do
				table.insert(return_data, self:_create_mission_unit(values, offset))
			end
		end

		for name, continent in pairs(self._continent_definitions) do
			if continent.mission then
				for _, values in ipairs(continent.mission) do
					table.insert(return_data, self:_create_mission_unit(values, offset))
				end
			end
		end
	end

	if (layer == "brush" or layer == "all") and self._definition.brush then
		self:_create_massunit(self._definition.brush, offset)
	end

	Application:check_termination()

	if layer == "environment" or layer == "all" then
		local environment = self._definition.environment

		self:_create_environment(environment, offset)

		return_data = environment
	end

	if layer == "world_camera" or layer == "all" then
		self:_create_world_cameras(self._definition.world_camera)
	end

	if (layer == "wires" or layer == "all") and self._definition.wires then
		for _, values in ipairs(self._definition.wires) do
			table.insert(return_data, self:_create_wires_unit(values, offset))
		end
	end

	if layer == "statics" or layer == "all" then
		local is_editor = Application:editor()

		if self._definition.statics then
			for _, values in ipairs(self._definition.statics) do
				local unit_data = values.unit_data

				if not is_editor and unit_data.delayed_load then
					self._delayed_units[unit_data.unit_id] = {
						unit_data,
						offset,
						return_data
					}
				else
					local unit = self:_create_statics_unit(values, offset)

					if unit then
						table.insert(return_data, unit)
					end
				end
			end
		end

		for name, continent in pairs(self._continent_definitions) do
			if continent.statics then
				for _, values in ipairs(continent.statics) do
					local unit_data = values.unit_data

					if not is_editor and unit_data.delayed_load then
						self._delayed_units[unit_data.unit_id] = {
							unit_data,
							offset,
							return_data
						}
					else
						local unit = self:_create_statics_unit(values, offset)

						if unit then
							table.insert(return_data, unit)
						end
					end
				end
			end
		end
	end

	if layer == "dynamics" or layer == "all" then
		if self._definition.dynamics then
			for _, values in ipairs(self._definition.dynamics) do
				table.insert(return_data, self:_create_dynamics_unit(values, offset))
			end
		end

		for name, continent in pairs(self._continent_definitions) do
			if continent.dynamics then
				for _, values in ipairs(continent.dynamics) do
					local unit = self:_create_dynamics_unit(values, offset)

					if unit then
						table.insert(return_data, unit)
					end
				end
			end
		end
	end

	return return_data
end

function WorldDefinition:_load_level_settings(data, offset)
end

function WorldDefinition:_load_ai_nav_graphs(data, offset)
	local path = self:world_dir() .. data.file

	if not DB:has("nav_data", path) then
		Application:error("The specified nav data file '" .. path .. ".nav_data' was not found for this level! ", path, "Navigation graph will not be loaded!")

		return
	end

	local values = self:_serialize_to_script("nav_data", path)

	Application:check_termination()
	managers.navigation:set_load_data(values)

	values = nil
end

function WorldDefinition:_load_ai_mop_graphs(data, offset)
	local path = self:world_dir() .. data.file

	if not DB:has("mop_data", path) then
		Application:error("The specified mop data file '" .. path .. ".mop_data' was not found for this level! ", path, "Motion paths will not be loaded!")

		return
	end

	local values = self:_serialize_to_script("mop_data", path)

	Application:check_termination()
	managers.motion_path:set_load_data(values)

	values = nil
end

function WorldDefinition:_load_ai_settings(data, offset)
	managers.groupai:set_state(data.ai_settings.group_state)
	managers.ai_data:load_data(data.ai_data)

	return data.ai_settings
end

function WorldDefinition:_create_portal(data, offset)
	if not Application:editor() then
		for _, portal in ipairs(data.portals) do
			local t = {}

			for _, point in ipairs(portal.points) do
				table.insert(t, point.position + offset)
			end

			local top = portal.top
			local bottom = portal.bottom

			if top == 0 and bottom == 0 then
				top, bottom = nil
			end

			managers.portal:add_portal(t, bottom, top)
		end
	end

	data.unit_groups._meta = nil

	for name, data in pairs(data.unit_groups) do
		local group = managers.portal:add_unit_group(name)
		local shapes = data.shapes or data

		for _, shape in ipairs(shapes) do
			group:add_shape(shape)
		end

		group:set_ids(data.ids)
	end
end

function WorldDefinition:_create_editor_groups()
	local groups = {}
	local group_names = {}

	if self._definition.editor_groups then
		for _, values in ipairs(self._definition.editor_groups) do
			if not groups[values.name] then
				groups[values.name] = values

				table.insert(group_names, values.name)
			end
		end
	end

	for name, continent in pairs(self._continent_definitions) do
		if continent.editor_groups then
			for _, values in ipairs(continent.editor_groups) do
				if not groups[values.name] then
					groups[values.name] = values

					table.insert(group_names, values.name)
				end
			end
		end
	end

	return {
		groups = groups,
		group_names = group_names
	}
end

function WorldDefinition:_create_sounds(data)
	local path = self:world_dir() .. data.file

	if not DB:has("world_sounds", path) then
		Application:error("The specified sound file '" .. path .. ".world_sounds' was not found for this level! ", path, "No sound will be loaded!")

		return
	end

	local values = self:_serialize_to_script("world_sounds", path)

	managers.sound_environment:set_default_environment(values.default_environment)
	managers.sound_environment:set_default_ambience(values.default_ambience)
	managers.sound_environment:set_ambience_enabled(values.ambience_enabled)
	managers.sound_environment:set_default_occasional(values.default_occasional)

	for _, sound_environment in ipairs(values.sound_environments) do
		managers.sound_environment:add_area(sound_environment)
	end

	for _, sound_emitter in ipairs(values.sound_emitters) do
		managers.sound_environment:add_emitter(sound_emitter)
	end

	for _, sound_area_emitter in ipairs(values.sound_area_emitters) do
		managers.sound_environment:add_area_emitter(sound_area_emitter)
	end
end

function WorldDefinition:_create_massunit(data, offset)
	local path = self:world_dir() .. data.file

	if Application:editor() then
		CoreEngineAccess._editor_load(Idstring("massunit"), path:id())

		local l = MassUnitManager:list(path:id())

		for _, name in ipairs(l) do
			if DB:has(Idstring("unit"), name:id()) then
				CoreEngineAccess._editor_load(Idstring("unit"), name:id())
			elseif not table.has(self._massunit_replace_names, name:s()) then
				managers.editor:output("Unit " .. name:s() .. " does not exist")

				local old_name = name:s()
				name = managers.editor:show_replace_massunit()

				if name and DB:has(Idstring("unit"), name:id()) then
					CoreEngineAccess._editor_load(Idstring("unit"), name:id())
				end

				self._massunit_replace_names[old_name] = name or ""

				managers.editor:output("Unit " .. old_name .. " changed to " .. tostring(name))
			end
		end
	end

	MassUnitManager:delete_all_units()
	MassUnitManager:load(path:id(), offset, Rotation(), self._massunit_replace_names)
end

function WorldDefinition:sky_rotation_modifier()
	return self._environment.sky_rot, true
end

function WorldDefinition:_set_environment(environment_name)
	if Global.game_settings.level_id then
		local env_params = _G.tweak_data.levels[Global.game_settings.level_id].env_params

		if env_params then
			environment_name = env_params.environment or environment_name
		end
	end

	if environment_name ~= "none" then
		managers.viewport:preload_environment(environment_name)
		managers.viewport:set_default_environment(environment_name, nil, nil)
	end
end

function WorldDefinition:_set_default_color_grading(color_grading_name)
	if Global.game_settings.level_id then
		local env_params = _G.tweak_data.levels[Global.game_settings.level_id].env_params

		if env_params then
			color_grading_name = env_params.color_grading or color_grading_name
		end
	end

	managers.environment_controller:set_default_color_grading(color_grading_name)
	managers.environment_controller:refresh_render_settings()
end

function WorldDefinition:_create_environment(data, offset)
	self:_set_environment(data.environment_values.environment)
	self:_set_default_color_grading(data.environment_values.color_grading)

	if not self._environment_modifier_id and not Application:editor() then
		self._environment_modifier_id = managers.viewport:create_global_environment_modifier(sky_orientation_data_key, true, function ()
			return self:sky_rotation_modifier()
		end)
	end

	self._environment = {
		sky_rot = data.environment_values.sky_rot
	}
	local wind = data.wind

	Wind:set_direction(wind.angle, wind.angle_var, 5)
	Wind:set_tilt(wind.tile, wind.tilt_var, 5)
	Wind:set_speed_m_s(wind.speed or 6, wind.speed_variation or 1, 5)
	Wind:set_enabled(true)

	if not Application:editor() then
		for _, unit_effect in ipairs(data.effects) do
			local name = Idstring(unit_effect.name)

			if DB:has("effect", name) then
				managers.portal:add_effect({
					effect = name,
					position = unit_effect.position,
					rotation = unit_effect.rotation
				})
			end
		end
	end

	for _, environment_area in ipairs(data.environment_areas) do
		managers.viewport:preload_environment(environment_area.environment)
		managers.environment_area:add_area(environment_area)
	end

	if Application:editor() then
		local units = {}

		for _, gizmo in ipairs(data.cubemap_gizmos) do
			local unit = self:make_unit(gizmo, offset)

			table.insert(units, unit)
		end

		data.units = units
	end

	if data.dome_occ_shapes then
		local shape_data = data.dome_occ_shapes[1]

		if shape_data then
			local corner = shape_data.position
			local size = Vector3(shape_data.depth, shape_data.width, shape_data.height)
			local texture_name = self:world_dir() .. "cube_lights/" .. "dome_occlusion"

			if not DB:has(Idstring("texture"), Idstring(texture_name)) then
				Application:error("Dome occlusion texture doesn't exists, probably needs to be generated", texture_name)
			else
				managers.environment_controller:set_dome_occ_params(corner, size, texture_name)
			end
		end
	end
end

function WorldDefinition:_create_world_cameras(data)
	local path = self:world_dir() .. data.file

	if not DB:has("world_cameras", path) then
		Application:error("No world_camera file found! (" .. path .. ")")

		return
	end

	local values = self:_serialize_to_script("world_cameras", path)

	managers.worldcamera:load(values)
end

function WorldDefinition:_create_mission_unit(data, offset)
	self:preload_unit(data.unit_data.name)

	local unit = self:make_unit(data.unit_data, offset)

	if unit then
		unit:mission_element_data().script = data.script

		self:add_mission_element_unit(unit)

		for name, value in pairs(data.script_data) do
			unit:mission_element_data()[name] = value
		end

		unit:mission_element():post_init()
	end

	return unit
end

function WorldDefinition:_create_wires_unit(data, offset)
	self:preload_unit(data.unit_data.name)

	local unit = self:make_unit(data.unit_data, offset)

	if unit then
		unit:wire_data().slack = data.wire_data.slack
		local target = unit:get_object(Idstring("a_target"))

		target:set_position(data.wire_data.target_pos)
		target:set_rotation(data.wire_data.target_rot)
		CoreMath.wire_set_midpoint(unit, unit:orientation_object():name(), Idstring("a_target"), Idstring("a_bender"))
		unit:set_moving()
	end

	return unit
end

function WorldDefinition:create_delayed_unit(new_unit_id)
	local spawn_data = self._delayed_units[new_unit_id]

	if spawn_data then
		local unit_data = spawn_data[1]

		PackageManager:load_delayed("unit", unit_data.name)
		self:preload_unit(unit_data.name)

		local unit = self:make_unit(unit_data, spawn_data[2])

		if unit then
			unit:set_spawn_delayed(true)
			table.insert(spawn_data[3], unit)
		end
	end
end

function WorldDefinition:_create_statics_unit(data, offset)
	self:preload_unit(data.unit_data.name)

	return self:make_unit(data.unit_data, offset)
end

function WorldDefinition:_create_dynamics_unit(data, offset)
	self:preload_unit(data.unit_data.name)

	return self:make_unit(data.unit_data, offset)
end

function WorldDefinition:_create_ai_editor_unit(data, offset)
	local unit = self:_create_statics_unit(data, offset)

	if data.ai_editor_data then
		for name, value in pairs(data.ai_editor_data) do
			unit:ai_editor_data()[name] = value
		end
	end

	return unit
end

function WorldDefinition:preload_unit(name)
	local is_editor = Application:editor()

	if table.has(self._replace_names, name) then
		name = self._replace_names[name]
	elseif is_editor and (not DB:has(Idstring("unit"), name:id()) or CoreEngineAccess._editor_unit_data(name:id()):type():id() == Idstring("deleteme")) then
		if not DB:has(Idstring("unit"), name:id()) then
			managers.editor:output_info("Unit " .. name .. " does not exist")
		else
			managers.editor:output_info("Unit " .. name .. " is of type " .. CoreEngineAccess._editor_unit_data(name:id()):type():t())
		end

		local old_name = name
		name = managers.editor:show_replace_unit()
		self._replace_names[old_name] = name

		managers.editor:output_info("Unit " .. old_name .. " changed to " .. tostring(name))
	end

	if is_editor and name then
		CoreEngineAccess._editor_load(Idstring("unit"), name:id())
	end
end

local is_editor = Application:editor()

function WorldDefinition:make_unit(data, offset)
	local name = data.name

	if self._ignore_spawn_list[Idstring(name):key()] then
		return nil
	end

	if table.has(self._replace_names, name) then
		name = self._replace_names[name]
	end

	if not name then
		return nil
	end

	if not is_editor and not Network:is_server() then
		local network_sync = PackageManager:unit_data(name:id()):network_sync()

		if network_sync ~= "none" and network_sync ~= "client" then
			return
		end
	end

	local unit = nil

	if MassUnitManager:can_spawn_unit(Idstring(name)) and not is_editor then
		unit = MassUnitManager:spawn_unit(Idstring(name), data.position + offset, data.rotation)
	else
		unit = CoreUnit.safe_spawn_unit(name, data.position, data.rotation)
	end

	if unit then
		self:assign_unit_data(unit, data)
	elseif is_editor then
		local s = "Failed creating unit " .. tostring(name)

		Application:throw_exception(s)
	end

	if self._termination_counter == 0 then
		Application:check_termination()
	end

	self._termination_counter = (self._termination_counter + 1) % 100

	return unit
end

local is_editor = Application:editor()

function WorldDefinition:assign_unit_data(unit, data)
	if not unit:unit_data() then
		Application:error("The unit " .. unit:name():s() .. " (" .. unit:author() .. ") does not have the required extension unit_data (ScriptUnitData)")
	end

	if unit:unit_data().only_exists_in_editor and not is_editor then
		self._ignore_spawn_list[unit:name():key()] = true

		unit:set_slot(0)

		return
	end

	unit:unit_data().instance = data.instance

	self:_setup_unit_id(unit, data)
	self:_setup_editor_unit_data(unit, data)

	if unit:unit_data().helper_type and unit:unit_data().helper_type ~= "none" then
		managers.helper_unit:add_unit(unit, unit:unit_data().helper_type)
	end

	if data.continent and is_editor then
		managers.editor:add_unit_to_continent(data.continent, unit)
	end

	self:_setup_lights(unit, data)
	self:_setup_variations(unit, data)
	self:_setup_editable_gui(unit, data)
	self:add_trigger_sequence(unit, data.triggers)
	self:_set_only_visible_in_editor(unit, data)
	self:_setup_cutscene_actor(unit, data)
	self:_setup_disable_shadow(unit, data)
	self:_setup_disable_collision(unit, data)
	self:_setup_delayed_load(unit, data)
	self:_setup_hide_on_projection_light(unit, data)
	self:_setup_disable_on_ai_graph(unit, data)
	self:_add_to_portal(unit, data)
	self:_setup_projection_light(unit, data)
	self:_setup_ladder(unit, data)
	self:_setup_zipline(unit, data)
	self:_project_assign_unit_data(unit, data)
end

function WorldDefinition:_setup_unit_id(unit, data)
	unit:unit_data().unit_id = data.unit_id

	unit:set_editor_id(unit:unit_data().unit_id)

	self._all_units[unit:unit_data().unit_id] = unit

	self:use_me(unit, Application:editor())
end

function WorldDefinition:_setup_editor_unit_data(unit, data)
	if not Application:editor() then
		return
	end

	unit:unit_data().name_id = data.name_id
	unit:unit_data().world_pos = unit:position()
	unit:unit_data().projection_lights = data.projection_lights
end

function WorldDefinition:_setup_lights(unit, data)
	if not data.lights then
		return
	end

	for _, l in ipairs(data.lights) do
		local light = unit:get_object(l.name:id())

		if light then
			light:set_enable(l.enabled)
			light:set_far_range(l.far_range)
			light:set_near_range(l.near_range or light:near_range())
			light:set_color(l.color)
			light:set_spot_angle_start(l.spot_angle_start)
			light:set_spot_angle_end(l.spot_angle_end)

			if l.multiplier_nr then
				light:set_multiplier(l.multiplier_nr)
			end

			if l.specular_multiplier_nr then
				light:set_specular_multiplier(l.specular_multiplier_nr)
			end

			if l.multiplier then
				l.multiplier = l.multiplier:id()

				light:set_multiplier(LightIntensityDB:lookup(l.multiplier))
				light:set_specular_multiplier(LightIntensityDB:lookup_specular_multiplier(l.multiplier))
			end

			light:set_falloff_exponent(l.falloff_exponent)

			if l.clipping_values then
				light:set_clipping_values(l.clipping_values)
			end
		end
	end
end

function WorldDefinition:setup_lights(...)
	self:_setup_lights(...)
end

function WorldDefinition:_setup_variations(unit, data)
	if data.mesh_variation and data.mesh_variation ~= "default" then
		if not Application:editor() or unit:damage() and unit:damage():has_sequence(data.mesh_variation) then
			unit:unit_data().mesh_variation = data.mesh_variation

			managers.sequence:run_sequence_simple2(unit:unit_data().mesh_variation, "change_state", unit)
		elseif Application:editor() then
			managers.editor:output_info("Removed variation sequence " .. data.mesh_variation .. " from unit " .. unit:name():s())
		end
	end

	if data.material_variation and data.material_variation ~= "default" then
		unit:unit_data().material = data.material_variation

		unit:set_material_config(Idstring(unit:unit_data().material), true, function ()
		end)
	end
end

function WorldDefinition:_setup_editable_gui(unit, data)
	if not data.editable_gui then
		return
	end

	if not unit:editable_gui() then
		Application:error("Unit has editable gui data saved but no editable gui extesnion. No text will be loaded. (probably cause the unit should no longer have editable text)")

		return
	end

	unit:editable_gui():set_text(data.editable_gui.text)
	unit:editable_gui():set_font_color(data.editable_gui.font_color)
	unit:editable_gui():set_font_size(data.editable_gui.font_size)
	unit:editable_gui():set_font(data.editable_gui.font)
	unit:editable_gui():set_align(data.editable_gui.align)
	unit:editable_gui():set_vertical(data.editable_gui.vertical)
	unit:editable_gui():set_blend_mode(data.editable_gui.blend_mode)
	unit:editable_gui():set_render_template(data.editable_gui.render_template)
	unit:editable_gui():set_wrap(data.editable_gui.wrap)
	unit:editable_gui():set_word_wrap(data.editable_gui.word_wrap)
	unit:editable_gui():set_alpha(data.editable_gui.alpha)
	unit:editable_gui():set_shape(data.editable_gui.shape)

	if not Application:editor() then
		unit:editable_gui():lock_gui()
	end
end

function WorldDefinition:_setup_ladder(unit, data)
	if not data.ladder then
		return
	end

	if not unit:ladder() then
		Application:error("Unit has ladder data saved but no ladder extension. No ladder data will be loaded.")

		return
	end

	unit:ladder():set_width(data.ladder.width)
	unit:ladder():set_height(data.ladder.height)
	unit:ladder():set_pc_disabled(data.ladder.pc_disabled)
	unit:ladder():set_vr_disabled(data.ladder.vr_disabled)
end

function WorldDefinition:_setup_zipline(unit, data)
	if not data.zipline then
		return
	end

	if not unit:zipline() then
		Application:error("Unit has zipline data saved but no zipline extension. No zipline data will be loaded.")

		return
	end

	unit:zipline():set_end_pos(data.zipline.end_pos)
	unit:zipline():set_speed(data.zipline.speed)
	unit:zipline():set_slack(data.zipline.slack)
	unit:zipline():set_usage_type(data.zipline.usage_type)
	unit:zipline():set_ai_ignores_bag(data.zipline.ai_ignores_bag)
end

function WorldDefinition:external_set_only_visible_in_editor(unit)
	self:_set_only_visible_in_editor(unit, nil)
end

function WorldDefinition:_set_only_visible_in_editor(unit, data)
	if Application:editor() then
		return
	end

	if unit:unit_data().only_visible_in_editor then
		unit:set_visible(false)
	end
end

function WorldDefinition:_setup_cutscene_actor(unit, data)
	if not data.cutscene_actor then
		return
	end

	unit:unit_data().cutscene_actor = data.cutscene_actor

	managers.cutscene:register_cutscene_actor(unit)
end

function WorldDefinition:_setup_disable_shadow(unit, data)
	if not data.disable_shadows then
		return
	end

	if Application:editor() then
		unit:unit_data().disable_shadows = data.disable_shadows
	end

	unit:set_shadows_disabled(data.disable_shadows)
end

function WorldDefinition:_setup_delayed_load(unit, data)
	if not data.delayed_load then
		return
	end

	unit:unit_data().delayed_load = data.delayed_load
end

function WorldDefinition:_setup_disable_collision(unit, data)
	if not data.disable_collision then
		return
	end

	if Application:editor() then
		unit:unit_data().disable_collision = data.disable_collision

		if managers.editor:is_simulating() then
			return
		end
	end

	for index = 0, unit:num_bodies() - 1 do
		local body = unit:body(index)

		if body then
			body:set_collisions_enabled(not data.disable_collision)
			body:set_collides_with_mover(not data.disable_collision)
			body:set_enabled(not data.disable_collision)
		end
	end
end

function WorldDefinition:_setup_hide_on_projection_light(unit, data)
	if not data.hide_on_projection_light then
		return
	end

	if Application:editor() then
		unit:unit_data().hide_on_projection_light = data.hide_on_projection_light
	end
end

function WorldDefinition:_setup_disable_on_ai_graph(unit, data)
	if not data.disable_on_ai_graph then
		return
	end

	if Application:editor() then
		unit:unit_data().disable_on_ai_graph = data.disable_on_ai_graph
	end
end

function WorldDefinition:_add_to_portal(unit, data)
	if Application:editor() or not self._portal_slot_mask then
		return
	end

	if unit:in_slot(self._portal_slot_mask) and not unit:unit_data().only_visible_in_editor then
		managers.portal:add_unit(unit)
	end
end

function WorldDefinition:_setup_projection_light(unit, data)
	if not data.projection_light then
		return
	end

	unit:unit_data().projection_textures = data.projection_textures
	unit:unit_data().projection_light = data.projection_light
	local light = unit:get_object(Idstring(data.projection_light))
	local texture_name = nil

	if unit:unit_data().projection_textures then
		texture_name = unit:unit_data().projection_textures[data.projection_light]

		if not DB:has(Idstring("texture"), Idstring(texture_name)) then
			Application:error("Projection light texture doesn't exists,", texture_name)

			return
		end
	else
		texture_name = (self._cube_lights_path or self:world_dir()) .. "cube_lights/" .. unit:unit_data().unit_id

		if not DB:has(Idstring("texture"), Idstring(texture_name)) then
			Application:error("Cube light texture doesn't exists, probably needs to be generated", texture_name)

			return
		end
	end

	local omni = string.find(light:properties(), "omni") and true or false

	light:set_projection_texture(Idstring(texture_name), omni, true)
end

function WorldDefinition:setup_projection_light(...)
	self:_setup_projection_light(...)
end

function WorldDefinition:_project_assign_unit_data(...)
end

function WorldDefinition:add_trigger_sequence(unit, triggers)
	local is_editor = Application:editor()

	if not triggers then
		return
	end

	for _, trigger in ipairs(triggers) do
		if is_editor and Global.running_simulation then
			local notify_unit = managers.editor:unit_with_id(trigger.notify_unit_id)

			unit:damage():add_trigger_sequence(trigger.name, trigger.notify_unit_sequence, notify_unit, trigger.time, nil, nil, is_editor)
		elseif self._all_units[trigger.notify_unit_id] then
			unit:damage():add_trigger_sequence(trigger.name, trigger.notify_unit_sequence, self._all_units[trigger.notify_unit_id], trigger.time, nil, nil, is_editor)
		elseif self._trigger_units[trigger.notify_unit_id] then
			table.insert(self._trigger_units[trigger.notify_unit_id], {
				unit = unit,
				trigger = trigger
			})
		else
			self._trigger_units[trigger.notify_unit_id] = {
				{
					unit = unit,
					trigger = trigger
				}
			}
		end
	end
end

function WorldDefinition:use_me(unit, is_editor)
	local id = unit:unit_data().unit_id
	id = id ~= 0 and id or unit:editor_id()
	self._all_units[id] = self._all_units[id] or unit

	if self._trigger_units[id] then
		for _, t in ipairs(self._trigger_units[id]) do
			t.unit:damage():add_trigger_sequence(t.trigger.name, t.trigger.notify_unit_sequence, unit, t.trigger.time, nil, nil, is_editor)
		end

		self._trigger_units[id] = nil
	end

	if self._use_unit_callbacks[id] then
		for _, call in ipairs(self._use_unit_callbacks[id]) do
			call(unit)
		end

		self._use_unit_callbacks[id] = nil
	end
end

function WorldDefinition:get_unit_on_load(id, call)
	if self._all_units[id] then
		return self._all_units[id]
	end

	if self._use_unit_callbacks[id] then
		table.insert(self._use_unit_callbacks[id], call)
	else
		self._use_unit_callbacks[id] = {
			call
		}
	end

	return nil
end

function WorldDefinition:get_unit(id)
	return self._all_units[id]
end

function WorldDefinition:add_mission_element_unit(unit, id)
	self._mission_element_units[id or unit:unit_data().unit_id] = unit
end

function WorldDefinition:get_mission_element_unit(id)
	return self._mission_element_units[id]
end
