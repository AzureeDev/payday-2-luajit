core:import("CoreWorldDefinition")
core:import("CoreEditorUtils")
core:import("CoreEngineAccess")
core:import("CoreUnit")

local sky_orientation_data_key = Idstring("sky_orientation/rotation"):key()
CoreOldWorldDefinition = CoreOldWorldDefinition or class()
CoreMissionElementUnit = CoreMissionElementUnit or class()
WorldHolder = WorldHolder or class()

function WorldHolder:get_world_file()
	Application:error("FIXME: Either unused or broken.")

	return nil
end

function WorldHolder:init(params)
	if type_name(params) ~= "table" then
		Application:throw_exception("WorldHolder:init needs a table as param (was of type " .. type_name(params) .. "). Check wiki for documentation.")

		return
	end

	local file_path = params.file_path
	local file_type = params.file_type
	self._worlds = {}

	if file_path then
		self._worldfile_generation = self:_worldfile_generation(file_type, file_path)

		if self._worldfile_generation == "level" then
			Application:throw_exception("Level format no longer supported, use type world with resaved data. (" .. file_path .. ")")

			return
		end

		local reverse = string.reverse(file_path)
		local i = string.find(reverse, "/")
		self._world_dir = string.reverse(string.sub(reverse, i))

		if not DB:has(file_type, file_path) then
			if not Application:editor() then
				assert(false, file_path .. "." .. file_type .. " is not in the database!")
			end

			return
		end

		if self._worldfile_generation == "new" then
			params.world_dir = self._world_dir
			self._definition = CoreWorldDefinition.WorldDefinition:new(params)
		elseif self._worldfile_generation == "old" then
			self:_error("World " .. file_path .. "." .. file_type .. " is old format! Will soon result in crash, please resave.")

			local t = {
				world_dir = self._world_dir,
				world_setting = params.world_setting
			}
			local WorldDefinitionClass = rawget(_G, "WorldDefinition") or rawget(_G, "CoreOldWorldDefinition")
			local path = managers.database:entry_expanded_path(file_type, file_path)
			local node = SystemFS:parse_xml(path)

			for world in node:children() do
				if world:name() == "world" then
					t.node = world
					self._worlds[world:parameter("name")] = WorldDefinitionClass:new(t)
				end
			end
		end
	end
end

function WorldHolder:_error(msg)
	if Application:editor() then
		managers.editor:output_error(msg)
	end

	Application:error(msg)
end

function WorldHolder:_worldfile_generation(file_type, file_path)
	if file_type == "level" then
		return "level"
	end

	if not Application:editor() then
		return "new"
	end

	local path = managers.database:entry_expanded_path(file_type, file_path)
	local node = SystemFS:parse_xml(path)

	if not node then
		return "missing"
	end

	if node:name() == "worlds" then
		return "old"
	end

	if node:name() == "generic_scriptdata" then
		return "new"
	end

	return "unknown"
end

function WorldHolder:status()
	if self._worldfile_generation == "new" then
		return "ok"
	end

	return self._worldfile_generation
end

function WorldHolder:create_world(world, layer, offset)
	if self._definition then
		local return_data = self._definition:create(layer, offset)

		if not Application:editor() and (layer == "statics" or layer == "all") and not Global.running_slave then
			World:occlusion_manager():merge_occluders(5)
		end

		return return_data
	end

	local c_world = self._worlds[world]

	if c_world then
		local return_data = c_world:create(layer, offset)

		if not Application:editor() and (layer == "statics" or layer == "all") and not Global.running_slave then
			World:culling_octree():build_tree()
			World:occlusion_manager():merge_occluders(5)
		end

		if not Application:editor() and layer == "all" then
			c_world:clear_definitions()
		end

		return return_data
	else
		Application:error("WorldHolder:create_world :: Could not create world", world, "for layer", layer)
	end
end

function WorldHolder:get_player_data(world, layer, offset)
	local c_world = self._worlds[world]

	if c_world then
		return c_world:get_player_data(offset)
	else
		Application:error("WorldHolder:create_world :: Could not create world", world, "for layer", layer)
	end
end

function WorldHolder:get_max_id(world)
	if self._definition then
		return self._definition:get_max_id()
	end

	local c_world = self._worlds[world]

	if c_world then
		return c_world:get_max_id()
	else
		Application:error("WorldHolder:create_world :: Could not return max id", world)
	end
end

function WorldHolder:get_level_name(world)
	local c_world = self._worlds[world]

	if c_world then
		return c_world:get_level_name()
	else
		Application:error("WorldHolder:create_world :: Could not return level name", world)
	end
end

function CoreOldWorldDefinition:init(params)
	managers.worlddefinition = self
	self._max_id = 0
	self._level_name = "none"
	self._definitions = {}
	self._world_dir = params.world_dir

	self:_load_world_package()
	managers.sequence:preload()

	self._old_groups = {
		groups = {},
		group_names = {}
	}
	self._portal_slot_mask = World:make_slot_mask(1)
	self._massunit_replace_names = {}
	self._replace_names = {}
	self._replace_units_path = "assets/lib/utils/dev/editor/xml/replace_units"

	self:parse_replace_unit()

	self._excluded_continents = {}

	self:_parse_world_setting(params.world_setting)

	local node = params.node
	local level = params.level

	if node then
		if node:has_parameter("max_id") then
			self._max_id = tonumber(node:parameter("max_id"))
		end

		if node:has_parameter("level_name") then
			self._level_name = node:parameter("level_name")
		end

		self:parse_definitions(node)
	elseif level then
		self._level_file = level
		self._max_id = self._level_file:data(Idstring("world")).max_id
		self._level_name = self._level_file:data(Idstring("world")).level_name
	end

	self._definitions.editor_groups = self._definitions.editor_groups or {
		groups = self._old_groups.groups,
		group_names = self._old_groups.group_names
	}
	self._all_units = {}
	self._stage_depended_units = {}
	self._trigger_units = {}
	self._use_unit_callbacks = {}
	self._mission_element_units = {}
end

function CoreOldWorldDefinition:_load_node(type, path)
	local path = managers.database:entry_expanded_path(type, path)

	return SystemFS:parse_xml(path)
end

function CoreOldWorldDefinition:_load_world_package()
	if Application:editor() then
		return
	end

	local package = self._world_dir .. "world"

	if not DB:has("package", package) then
		Application:throw_exception("No world.package file found in " .. self._world_dir .. ", please resave level")

		return
	end

	if not PackageManager:loaded(package) then
		PackageManager:load(package)

		self._current_world_package = package
	end
end

function CoreOldWorldDefinition:_load_continent_package(path)
	if Application:editor() then
		return
	end

	if not DB:has("package", path) then
		Application:error("Missing package for a continent(" .. path .. "), resave level " .. self._world_dir .. ".")

		return
	end

	self._continent_packages = self._continent_packages or {}

	if not PackageManager:loaded(path) then
		PackageManager:load(path)
		table.insert(self._continent_packages, path)
		managers.sequence:preload()
	end
end

function CoreOldWorldDefinition:unload_packages()
	if self._current_world_package and PackageManager:loaded(self._current_world_package) then
		PackageManager:unload(self._current_world_package)
	end

	for _, package in ipairs(self._continent_packages) do
		PackageManager:unload(package)
	end
end

function CoreOldWorldDefinition:nice_path(path)
	path = string.match(string.gsub(path, ".*assets[/\\]", ""), "([^.]*)")
	path = string.gsub(path, "\\", "/")

	return path
end

function CoreOldWorldDefinition:_parse_world_setting(world_setting)
	if not world_setting then
		return
	end

	local path = self:world_dir() .. world_setting

	if not DB:has("world_setting", path) then
		Application:error("There is no world_setting file " .. world_setting .. " at path " .. path)

		return
	end

	local settings = DB:load_node("world_setting", path)

	for continent in settings:children() do
		self._excluded_continents[continent:parameter("name")] = toboolean(continent:parameter("exclude"))
	end
end

function CoreOldWorldDefinition:parse_definitions(node)
	local num_children = node:num_children()
	local num_progress = 0

	for type in node:children() do
		local name = type:name()
		self._definitions[name] = self._definitions[name] or {}

		if managers.editor then
			num_progress = num_progress + 50 / num_children

			managers.editor:update_load_progress(num_progress, "Parse layer: " .. name)
		end

		if self["parse_" .. name] then
			self["parse_" .. name](self, type, self._definitions[name])
		else
			Application:error("CoreOldWorldDefinition:No parse function for type/layer", name)
		end
	end
end

function CoreOldWorldDefinition:world_dir()
	return self._world_dir
end

function CoreOldWorldDefinition:get_max_id()
	return self._max_id
end

function CoreOldWorldDefinition:get_level_name()
	return self._level_name
end

function CoreOldWorldDefinition:parse_continents(node, t)
	local path = node:parameter("file")

	if not DB:has("continents", path) then
		path = self:world_dir() .. path
	end

	if not DB:has("continents", path) then
		Application:error("Continent file didn't exist " .. path .. ").")

		return
	end

	local continents = self:_load_node("continents", path)

	for continent in continents:children() do
		local data = parse_values_node(continent)
		data = data._values or {}

		if not self:_continent_editor_only(data) then
			local name = continent:parameter("name")

			if not self._excluded_continents[name] then
				local path = self:world_dir() .. name .. "/" .. name

				self:_load_continent_package(path)

				data.base_id = data.base_id or tonumber(continent:parameter("base_id"))

				if DB:has("continent", path) then
					local node = self:_load_node("continent", path)

					for world in node:children() do
						data.level_name = world:parameter("level_name")
						t[name] = data

						self:parse_definitions(world)
					end
				else
					Application:error("Continent file " .. path .. ".continent doesnt exist.")
				end
			end
		end
	end
end

function CoreOldWorldDefinition:_continent_editor_only(data)
	return not Application:editor() and data.editor_only
end

function CoreOldWorldDefinition:parse_values(node, t)
	for child in node:children() do
		local name, value = parse_value_node(child)
		t[name] = value
	end
end

function CoreOldWorldDefinition:parse_markers(node, t)
	for child in node:children() do
		table.insert(t, LoadedMarker:new(child))
	end
end

function CoreOldWorldDefinition:parse_groups(node, t)
	for child in node:children() do
		local name = child:parameter("name")
		local reference = tonumber(child:parameter("reference_unit_id"))

		if reference ~= 0 then
			self:add_editor_group(name, reference)
		else
			cat_error("Removed empty group", name, "when converting from old GroupHandler to new.")
		end
	end
end

function CoreOldWorldDefinition:parse_editor_groups(node, t)
	local groups = self._old_groups.groups
	local group_names = self._old_groups.group_names

	for group in node:children() do
		local name = group:parameter("name")

		if not groups[name] then
			local reference = tonumber(group:parameter("reference_id"))
			local continent = nil

			if group:has_parameter("continent") and group:parameter("continent") ~= "nil" then
				continent = group:parameter("continent")
			end

			local units = {}

			for unit in group:children() do
				table.insert(units, tonumber(unit:parameter("id")))
			end

			groups[name] = {
				reference = reference,
				continent = continent,
				units = units
			}

			table.insert(group_names, name)
		end
	end

	t.groups = groups
	t.group_names = group_names
end

function CoreOldWorldDefinition:add_editor_group(name, reference)
	table.insert(self._old_groups.group_names, name)

	self._old_groups.groups[name] = {
		reference = reference
	}
	self._old_groups.groups[name].units = self._old_groups.groups[name].units or {}
end

function CoreOldWorldDefinition:add_editor_group_unit(name, id)
	self._old_groups.groups[name].units = self._old_groups.groups[name].units or {}

	table.insert(self._old_groups.groups[name].units, id)
end

function CoreOldWorldDefinition:parse_brush(node)
	if node:has_parameter("path") then
		self._massunit_path = node:parameter("path")
	elseif node:has_parameter("file") then
		self._massunit_path = node:parameter("file")

		if not DB:has("massunit", self._massunit_path) then
			self._massunit_path = self:world_dir() .. self._massunit_path
		end
	end
end

function CoreOldWorldDefinition:parse_sounds(node, t)
	local path = nil

	if node:has_parameter("path") then
		path = node:parameter("path")
	elseif node:has_parameter("file") then
		path = node:parameter("file")

		if not DB:has("world_sounds", path) then
			path = self:world_dir() .. path
		end
	end

	if not DB:has("world_sounds", path) then
		Application:error("The specified sound file '" .. path .. ".world_sounds' was not found for this level! ", path, "No sound will be loaded!")

		return
	end

	local node = self:_load_node("world_sounds", path)
	self._sounds = CoreWDSoundEnvironment:new(node)
end

function CoreOldWorldDefinition:parse_mission_scripts(node, t)
	if not Application:editor() then
		return
	end

	t.scripts = t.scripts or {}
	local values = parse_values_node(node)

	for name, data in pairs(values._scripts) do
		t.scripts[name] = data
	end
end

function CoreOldWorldDefinition:parse_mission(node, t)
	if Application:editor() then
		local MissionClass = rawget(_G, "MissionElementUnit") or rawget(_G, "CoreMissionElementUnit")

		for child in node:children() do
			table.insert(t, MissionClass:new(child))
		end
	end
end

function CoreOldWorldDefinition:parse_environment(node)
	self._environment = CoreEnvironment:new(node)
end

function CoreOldWorldDefinition:parse_world_camera(node)
	if node:has_parameter("path") then
		self._world_camera_path = node:parameter("path")
	elseif node:has_parameter("file") then
		self._world_camera_path = node:parameter("file")

		if not DB:has("world_cameras", self._world_camera_path) then
			self._world_camera_path = self:world_dir() .. self._world_camera_path
		end
	end
end

function CoreOldWorldDefinition:parse_portal(node)
	self._portal = CorePortal:new(node)
end

function CoreOldWorldDefinition:parse_wires(node, t)
	for child in node:children() do
		table.insert(t, CoreWire:new(child))
	end
end

function CoreOldWorldDefinition:parse_statics(node, t)
	for child in node:children() do
		table.insert(t, CoreStaticUnit:new(child))
	end
end

function CoreOldWorldDefinition:parse_dynamics(node, t)
	for child in node:children() do
		table.insert(t, CoreDynamicUnit:new(child))
	end
end

function CoreOldWorldDefinition:release_sky_orientation_modifier()
	if self._environment then
		self._environment:release_sky_orientation_modifier()
	end
end

function CoreOldWorldDefinition:clear_definitions()
	self._definitions = nil
end

function CoreOldWorldDefinition:create(layer, offset)
	if self._level_file then
		self:create_from_level_file({
			layer = layer,
			level_file = self._level_file,
			offset = offset
		})
		self:_create_continent_level(layer, offset)
		self._level_file:destroy()

		return true
	else
		return self:create_units(layer, offset)
	end
end

function CoreOldWorldDefinition:_create_continent_level(layer, offset)
	if not self._level_file:data(Idstring("continents")) then
		Application:error("No continent data saved to level file, please resave.")

		return
	end

	local path = self:world_dir() .. self._level_file:data(Idstring("continents")).file

	if not DB:has("continents", path) then
		Application:error("Continent file didn't exist " .. path .. ").")

		return
	end

	local continents = DB:load_node("continents", path)

	for continent in continents:children() do
		local data = parse_values_node(continent)
		data = data._values or {}

		if not self:_continent_editor_only(data) then
			local name = continent:parameter("name")

			if not self._excluded_continents[name] then
				local path = self:world_dir() .. name .. "/" .. name

				self:_load_continent_package(path)

				if DB:has("level", path) then
					local level_file = Level:load(path)

					self:create_from_level_file({
						layer = layer,
						level_file = level_file,
						offset = offset
					})
					level_file:destroy()
				else
					Application:error("Continent file " .. path .. ".continent doesnt exist.")
				end
			end
		end
	end
end

function CoreOldWorldDefinition:create_units(layer, offset)
	if layer ~= "all" and not self._definitions[layer] then
		return {}
	end

	local return_data = {}

	if layer == "markers" then
		return_data = self._definitions.markers
	end

	if layer == "values" then
		return_data = self._definitions.values
	end

	if layer == "editor_groups" then
		return_data = self._definitions.editor_groups
	end

	if layer == "continents" then
		return_data = self._definitions.continents
	end

	if (layer == "portal" or layer == "all") and self._portal then
		self._portal:create(offset)

		return_data = self._portal
	end

	if (layer == "sounds" or layer == "all") and self._sounds then
		self._sounds:create()

		return_data = self._sounds
	end

	if layer == "mission_scripts" then
		return_data = self._definitions.mission_scripts
	end

	if layer == "mission" then
		for _, unit in ipairs(self._definitions.mission) do
			table.insert(return_data, unit:create_unit(offset))
		end
	end

	if (layer == "brush" or layer == "all") and self._massunit_path then
		self:load_massunit(self._massunit_path, offset)
	end

	if (layer == "environment" or layer == "all") and self._environment then
		self._environment:create(offset)

		return_data = self._environment
	end

	if (layer == "world_camera" or layer == "all") and self._world_camera_path then
		managers.worldcamera:load(self._world_camera_path, offset)
	end

	if (layer == "wires" or layer == "all") and self._definitions.wires then
		for _, unit in ipairs(self._definitions.wires) do
			table.insert(return_data, unit:create_unit(offset))
		end
	end

	if layer == "statics" or layer == "all" then
		for _, unit in ipairs(self._definitions.statics) do
			table.insert(return_data, unit:create_unit(offset))
		end
	end

	if layer == "dynamics" or layer == "all" then
		for _, unit in ipairs(self._definitions.dynamics) do
			table.insert(return_data, unit:create_unit(offset))
		end
	end

	return return_data
end

function CoreOldWorldDefinition:create_from_level_file(params)
	local layer = params.layer
	local offset = params.offset
	local level_file = params.level_file

	if (layer == "portal" or layer == "all") and not Application:editor() and level_file:data(Idstring("portal")) then
		self:create_portals(level_file:data(Idstring("portal")).portals, offset)
		self:create_portal_unit_groups(level_file:data(Idstring("portal")).unit_groups, offset)
	end

	if (layer == "sounds" or layer == "all") and level_file:data(Idstring("sounds")) then
		if level_file:data(Idstring("sounds")).path then
			self:create_sounds(level_file:data(Idstring("sounds")).path, offset)
		elseif level_file:data(Idstring("sounds")).file then
			self:create_sounds(self:world_dir() .. level_file:data(Idstring("sounds")).file, offset)
		end
	end

	if (layer == "brush" or layer == "all") and level_file:data(Idstring("brush")) then
		if level_file:data(Idstring("brush")).path then
			self:load_massunit(level_file:data(Idstring("brush")).path, offset)
		elseif level_file:data(Idstring("brush")).file then
			self:load_massunit(self:world_dir() .. level_file:data(Idstring("brush")).file, offset)
		end
	end

	if (layer == "environment" or layer == "all") and level_file:data(Idstring("environment")) then
		self:create_environment(level_file:data(Idstring("environment")), offset)
	end

	if (layer == "world_camera" or layer == "all") and level_file:data(Idstring("world_camera")) then
		if level_file:data(Idstring("world_camera")).path then
			managers.worldcamera:load(level_file:data(Idstring("world_camera")).path, offset)
		elseif level_file:data(Idstring("world_camera")).file then
			managers.worldcamera:load(self:world_dir() .. level_file:data(Idstring("world_camera")).file, offset)
		end
	end

	if layer == "wires" or layer == "all" then
		local t = self:create_level_units({
			layer = "wires",
			offset = offset,
			level_file = level_file
		})

		for _, d in ipairs(t) do
			local unit = d[1]
			local data = d[2]
			local wire = data.wire
			unit:wire_data().slack = wire.slack
			local target = unit:get_object(Idstring("a_target"))

			target:set_position(wire.target_pos)
			target:set_rotation(wire.target_rot)
			wire_set_midpoint(unit, Idstring("rp"), Idstring("a_target"), Idstring("a_bender"))
			unit:set_moving()
		end
	end

	if layer == "statics" or layer == "all" then
		self:create_level_units({
			layer = "statics",
			offset = offset,
			level_file = level_file
		})
	end

	if layer == "dynamics" or layer == "all" then
		self:create_level_units({
			layer = "dynamics",
			offset = offset,
			level_file = level_file
		})
	end
end

function CoreOldWorldDefinition:create_level_units(params)
	local layer = params.layer
	local offset = params.offset
	local level_file = params.level_file
	local t = level_file:create(layer)

	for _, d in ipairs(t) do
		local unit = d[1]
		local data = d[2]
		local generic_data = self:make_generic_data(data)

		self:assign_unit_data(unit, generic_data)
	end

	return t
end

function CoreOldWorldDefinition:create_portals(portals, offset)
	for _, portal in ipairs(portals) do
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

function CoreOldWorldDefinition:create_portal_unit_groups(unit_groups, offset)
	if not unit_groups then
		return
	end

	for name, shapes in pairs(unit_groups) do
		local group = managers.portal:add_unit_group(name)

		for _, shape in ipairs(shapes) do
			group:add_shape(shape)
		end
	end
end

function CoreOldWorldDefinition:create_sounds(path)
	local sounds_level = Level:load(path)
	local sounds = sounds_level:data(Idstring("sounds"))

	managers.sound_environment:set_default_environment(sounds.environment)
	managers.sound_environment:set_default_ambience(sounds.ambience, sounds.ambience_soundbank)
	managers.sound_environment:set_ambience_enabled(sounds.ambience_enabled)

	for _, sound_environment in ipairs(sounds.sound_environments) do
		managers.sound_environment:add_area(sound_environment)
	end

	for _, sound_emitter in ipairs(sounds.sound_emitters) do
		managers.sound_environment:add_emitter(sound_emitter)
	end

	if sounds.sound_area_emitters then
		for _, sound_area_emitter in ipairs(sounds.sound_area_emitters) do
			managers.sound_environment:add_area_emitter(sound_area_emitter)
		end
	end

	sounds_level:destroy()
end

function CoreOldWorldDefinition:create_environment(data, offset)
	managers.viewport:set_default_environment(data.environment, nil, nil)

	self._environment_modifier_id = managers.viewport:create_global_environment_modifier(sky_orientation_data_key, true, function ()
		return data.sky_rot
	end)
	local wind = data.wind

	Wind:set_direction(wind.angle, wind.angle_var, 5)
	Wind:set_tilt(wind.tilt, wind.tilt_var, 5)
	Wind:set_speed_m_s(wind.speed or 6, wind.speed_variation or 1, 5)
	Wind:set_enabled(true)

	if not Application:editor() then
		for _, effect in ipairs(data.effects) do
			local name = Idstring(effect.name)

			if DB:has("effect", name) then
				managers.portal:add_effect({
					effect = name,
					position = effect.position,
					rotation = effect.rotation
				})
			end
		end
	end

	for _, environment_area in ipairs(data.environment_areas) do
		managers.environment_area:add_area(environment_area)
	end
end

function CoreOldWorldDefinition:load_massunit(path, offset)
	if Application:editor() then
		local l = MassUnitManager:list(path:id())

		for _, name in ipairs(l) do
			if DB:has(Idstring("unit"), name:id()) then
				CoreUnit.editor_load_unit(name)
			elseif not table.has(self._massunit_replace_names, name:s()) then
				managers.editor:output("Unit " .. name:s() .. " does not exist")

				local old_name = name:s()
				name = managers.editor:show_replace_massunit()

				if name and DB:has(Idstring("unit"), name:id()) then
					CoreUnit.editor_load_unit(name)
				end

				self._massunit_replace_names[old_name] = name or ""

				managers.editor:output("Unit " .. old_name .. " changed to " .. tostring(name))
			end
		end
	end

	MassUnitManager:delete_all_units()
	MassUnitManager:load(path:id(), offset, Rotation(), self._massunit_replace_names)
end

function CoreOldWorldDefinition:parse_replace_unit()
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

function CoreOldWorldDefinition:preload_unit(name)
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
		CoreUnit.editor_load_unit(name)
	end
end

function CoreOldWorldDefinition:make_unit(name, data, offset)
	local is_editor = Application:editor()

	if table.has(self._replace_names, name) then
		name = self._replace_names[name]
	end

	local unit = nil

	if name then
		if MassUnitManager:can_spawn_unit(Idstring(name)) and not is_editor then
			unit = MassUnitManager:spawn_unit(Idstring(name), data._position + offset, data._rotation)
		else
			unit = safe_spawn_unit(name, data._position + offset, data._rotation)
		end

		if unit then
			self:assign_unit_data(unit, data)
		elseif is_editor then
			local s = "Failed creating unit " .. tostring(name)

			Application:throw_exception(s)
		end
	end

	return unit
end

function CoreOldWorldDefinition:assign_unit_data(unit, data)
	local is_editor = Application:editor()

	if not unit:unit_data() then
		Application:error("The unit " .. unit:name() .. " (" .. unit:author() .. ") does not have the required extension unit_data (ScriptUnitData)")
	end

	if unit:unit_data().only_exists_in_editor and not is_editor then
		unit:set_slot(0)

		return
	end

	if data._unit_id then
		unit:unit_data().unit_id = data._unit_id

		unit:set_editor_id(unit:unit_data().unit_id)

		self._all_units[unit:unit_data().unit_id] = unit

		self:use_me(unit, is_editor)
	end

	if is_editor then
		unit:unit_data().name_id = data._name_id
		unit:unit_data().world_pos = unit:position()
	end

	if data._group_name and is_editor and not self._level_file and data._group_name ~= "none" then
		self:add_editor_group_unit(data._group_name, unit:unit_data().unit_id)
	end

	if data._continent and is_editor then
		managers.editor:add_unit_to_continent(data._continent, unit)
	end

	for _, l in ipairs(data._lights) do
		local light = unit:get_object(Idstring(l.name))

		if light then
			light:set_enable(l.enable)
			light:set_far_range(l.far_range)
			light:set_color(l.color)

			if l.angle_start then
				light:set_spot_angle_start(l.angle_start)
				light:set_spot_angle_end(l.angle_end)
			end

			if l.multiplier then
				if tonumber(l.multiplier) then
					l.multiplier = CoreEditorUtils.get_intensity_preset(tonumber(l.multiplier))
				end

				if type_name(l.multiplier) == "string" then
					l.multiplier = Idstring(l.multiplier)
				end

				light:set_multiplier(LightIntensityDB:lookup(l.multiplier))
				light:set_specular_multiplier(LightIntensityDB:lookup_specular_multiplier(l.multiplier))
			end

			if l.falloff_exponent then
				light:set_falloff_exponent(l.falloff_exponent)
			end
		end
	end

	if data._variation and data._variation ~= "default" then
		unit:unit_data().mesh_variation = data._variation

		managers.sequence:run_sequence_simple2(unit:unit_data().mesh_variation, "change_state", unit)
	end

	if data._material_variation and data._material_variation ~= "default" then
		unit:unit_data().material = data._material_variation

		unit:set_material_config(unit:unit_data().material, true)
	end

	if data._editable_gui then
		unit:editable_gui():set_text(data._editable_gui.text)
		unit:editable_gui():set_font_color(data._editable_gui.font_color)
		unit:editable_gui():set_font_size(data._editable_gui.font_size)
		unit:editable_gui():set_font(data._editable_gui.font)
		unit:editable_gui():set_align(data._editable_gui.align)
		unit:editable_gui():set_vertical(data._editable_gui.vertical)
		unit:editable_gui():set_blend_mode(data._editable_gui.blend_mode)
		unit:editable_gui():set_render_template(data._editable_gui.render_template)
		unit:editable_gui():set_wrap(data._editable_gui.wrap)
		unit:editable_gui():set_word_wrap(data._editable_gui.word_wrap)
		unit:editable_gui():set_alpha(data._editable_gui.alpha)
		unit:editable_gui():set_shape(data._editable_gui.shape)

		if not is_editor then
			unit:editable_gui():lock_gui()
		end
	end

	self:add_trigger_sequence(unit, data._triggers)

	if not table.empty(data._exists_in_stages) then
		local t = clone(CoreScriptUnitData.exists_in_stages)

		for i, value in pairs(data._exists_in_stages) do
			t[i] = value
		end

		unit:unit_data().exists_in_stages = t

		table.insert(self._stage_depended_units, unit)
	end

	if unit:unit_data().only_visible_in_editor and not is_editor then
		unit:set_visible(false)
	end

	if data.cutscene_actor then
		unit:unit_data().cutscene_actor = data.cutscene_actor

		managers.cutscene:register_cutscene_actor(unit)
	end

	if data.disable_shadows then
		if is_editor then
			unit:unit_data().disable_shadows = data.disable_shadows
		end

		unit:set_shadows_disabled(data.disable_shadows)
	end

	if data.delayed_load then
		unit:unit_data().delayed_load = data.delayed_load
	end

	if not is_editor and self._portal_slot_mask and unit:in_slot(self._portal_slot_mask) and not unit:unit_data().only_visible_in_editor then
		managers.portal:add_unit(unit)
	end
end

function CoreOldWorldDefinition:add_trigger_sequence(unit, triggers)
	local is_editor = Application:editor()

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

function CoreOldWorldDefinition:use_me(unit, is_editor)
	local id = unit:unit_data().unit_id

	if self._trigger_units[id] then
		for _, t in ipairs(self._trigger_units[id]) do
			t.unit:damage():add_trigger_sequence(t.trigger.name, t.trigger.notify_unit_sequence, unit, t.trigger.time, nil, nil, is_editor)
		end
	end

	if self._use_unit_callbacks[id] then
		for _, call in ipairs(self._use_unit_callbacks[id]) do
			call(unit)
		end
	end
end

function CoreOldWorldDefinition:get_unit_on_load(id, call)
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

function CoreOldWorldDefinition:check_stage_depended_units(stage)
	for _, unit in ipairs(self._stage_depended_units) do
		for i, value in ipairs(unit:unit_data().exists_in_stages) do
			if stage == "stage" .. i and not value then
				World:delete_unit(unit)
			end
		end
	end
end

function CoreOldWorldDefinition:get_unit(id)
	return self._all_units[id]
end

function CoreOldWorldDefinition:add_mission_element_unit(unit)
	self._mission_element_units[unit:unit_data().unit_id] = unit
end

function CoreOldWorldDefinition:get_mission_element_unit(id)
	return self._mission_element_units[id]
end

function CoreOldWorldDefinition:get_hub_element_unit(id)
	Application:stack_dump_error("CoreOldWorldDefinition:get_hub_element_unit is deprecated, use CoreOldWorldDefinition:get_mission_element_unit instead.")

	return self._mission_element_units[id]
end

function CoreOldWorldDefinition:get_soundbank()
	return self._soundbank
end

LoadedMarker = LoadedMarker or class()

function LoadedMarker:init(node)
	self._name = node:parameter("name")
	self._pos = math.string_to_vector(node:parameter("pos"))
	self._rot = math.string_to_vector(node:parameter("rot"))
	self._rot = Rotation(self._rot.x, self._rot.y, self._rot.z)
end

CoreWDSoundEnvironment = CoreWDSoundEnvironment or class()

function CoreWDSoundEnvironment:init(node)
	self._sound_environments = {}
	self._sound_emitters = {}
	self._sound_area_emitters = {}

	node:for_each("default", callback(self, self, "parse_default"))
	node:for_each("ambience", callback(self, self, "parse_ambience"))
	node:for_each("sound_environment", callback(self, self, "parse_sound_environment"))
	node:for_each("sound_emitter", callback(self, self, "parse_sound_emitter"))
	node:for_each("sound_area_emitter", callback(self, self, "parse_sound_area_emitter"))
end

function CoreWDSoundEnvironment:parse_default(node)
	self._default_ambience_soundbank = node:parameter("ambience_soundbank")
	self._default_environment = node:parameter("environment")
	self._default_ambience = node:parameter("ambience")
end

function CoreWDSoundEnvironment:parse_ambience(node)
	self._ambience_enabled = toboolean(node:parameter("enabled"))
end

function CoreWDSoundEnvironment:parse_sound_environment(node)
	local t = {
		environment = node:parameter("environment"),
		ambience_event = node:parameter("ambience_event"),
		ambience_soundbank = node:parameter("ambience_soundbank"),
		position = math.string_to_vector(node:parameter("position")),
		rotation = math.string_to_rotation(node:parameter("rotation")),
		width = tonumber(node:parameter("width")),
		depth = tonumber(node:parameter("depth")),
		height = tonumber(node:parameter("height")),
		name = node:parameter("name")
	}

	table.insert(self._sound_environments, t)
end

function CoreWDSoundEnvironment:parse_sound_emitter(node)
	for emitter in node:children() do
		table.insert(self._sound_emitters, parse_values_node(emitter))
	end
end

function CoreWDSoundEnvironment:parse_sound_area_emitter(node)
	local t = {}

	for shape in node:children() do
		for value in shape:children() do
			local name, vt = parse_value_node(value)
			t = vt
		end

		t.position = math.string_to_vector(shape:parameter("position"))
		t.rotation = math.string_to_rotation(shape:parameter("rotation"))
	end

	table.insert(self._sound_area_emitters, t)
end

function CoreWDSoundEnvironment:create()
	managers.sound_environment:set_default_environment(self._default_environment)
	managers.sound_environment:set_default_ambience(self._default_ambience, self._default_ambience_soundbank)
	managers.sound_environment:set_ambience_enabled(self._ambience_enabled)

	for _, sound_environment in ipairs(self._sound_environments) do
		managers.sound_environment:add_area(sound_environment)
	end

	for _, sound_emitter in ipairs(self._sound_emitters) do
		managers.sound_environment:add_emitter(sound_emitter)
	end

	for _, sound_area_emitter in ipairs(self._sound_area_emitters) do
		managers.sound_environment:add_area_emitter(sound_area_emitter)
	end
end

CoreEnvironment = CoreEnvironment or class()

function CoreEnvironment:init(node)
	self._values = {}

	if node:has_parameter("environment") then
		self._values.environment = node:parameter("environment")
	end

	if node:has_parameter("sky_rot") then
		self._values.sky_rot = tonumber(node:parameter("sky_rot"))
	end

	node:for_each("value", callback(self, self, "parse_value"))
	node:for_each("wind", callback(self, self, "parse_wind"))

	self._unit_effects = {}

	node:for_each("unit_effect", callback(self, self, "parse_unit_effect"))

	self._environment_areas = {}

	node:for_each("environment_area", callback(self, self, "parse_environment_area"))

	self._units_data = {}
	self._units = {}

	node:for_each("unit", callback(self, self, "parse_unit"))
end

function CoreEnvironment:release_sky_orientation_modifier()
	if self._environment_modifier_id then
		managers.viewport:destroy_global_environment_modifier(self._environment_modifier_id)

		self._environment_modifier_id = nil
	end
end

function CoreEnvironment:parse_value(node)
	self._values[node:parameter("name")] = string_to_value(node:parameter("type"), node:parameter("value"))
end

function CoreEnvironment:parse_wind(node)
	self._wind = {
		wind_angle = tonumber(node:parameter("angle")),
		wind_dir_var = tonumber(node:parameter("angle_var")),
		wind_tilt = tonumber(node:parameter("tilt")),
		wind_tilt_var = tonumber(node:parameter("tilt_var"))
	}

	if node:has_parameter("speed") then
		self._wind.wind_speed = tonumber(node:parameter("speed"))
	end

	if node:has_parameter("speed_variation") then
		self._wind.wind_speed_variation = tonumber(node:parameter("speed_variation"))
	end
end

function CoreEnvironment:parse_unit_effect(node)
	local pos, rot = nil

	for o in node:children() do
		pos = math.string_to_vector(o:parameter("pos"))
		rot = math.string_to_rotation(o:parameter("rot"))
	end

	local name = node:parameter("name")
	local t = {
		pos = pos,
		rot = rot,
		name = name
	}

	table.insert(self._unit_effects, t)
end

function CoreEnvironment:parse_environment_area(node)
	local t = {}

	for shape in node:children() do
		t = managers.shape:parse(shape)
	end

	table.insert(self._environment_areas, t)
end

function CoreEnvironment:parse_unit(node)
	if not Application:editor() then
		return
	end

	local t = {
		name = node:parameter("name"),
		generic = Generic:new(node)
	}

	table.insert(self._units_data, t)
end

function CoreEnvironment:sky_rotation_modifier()
	return self._values.sky_rot
end

function CoreEnvironment:create(offset)
	if self._values.environment ~= "none" then
		managers.viewport:set_default_environment(self._values.environment, nil, nil)
	end

	if not Application:editor() then
		self._environment_modifier_id = self._environment_modifier_id or managers.viewport:create_global_environment_modifier(sky_orientation_data_key, true, function ()
			return self:sky_rotation_modifier()
		end)
	end

	if self._wind then
		Wind:set_direction(self._wind.wind_angle, self._wind.wind_dir_var, 5)
		Wind:set_tilt(self._wind.wind_tilt, self._wind.wind_tilt_var, 5)
		Wind:set_speed_m_s(self._wind.wind_speed or 6, self._wind.wind_speed_variation or 1, 5)
		Wind:set_enabled(true)
	end

	if not Application:editor() then
		for _, unit_effect in ipairs(self._unit_effects) do
			local name = Idstring(unit_effect.name)

			if DB:has("effect", name) then
				managers.portal:add_effect({
					effect = name,
					position = unit_effect.pos,
					rotation = unit_effect.rot
				})
			end
		end
	end

	for _, environment_area in ipairs(self._environment_areas) do
		managers.environment_area:add_area(environment_area)
	end

	for _, data in ipairs(self._units_data) do
		local unit = managers.worlddefinition:make_unit(data.name, data.generic, offset)

		table.insert(self._units, unit)
	end
end

CorePortal = CorePortal or class()

function CorePortal:init(node)
	managers.worlddefinition:preload_unit("core/units/portal_point/portal_point")

	self._portal_shapes = {}
	self._unit_groups = {}

	node:for_each("portal_list", callback(self, self, "parse_portal_list"))
	node:for_each("unit_group", callback(self, self, "parse_unit_group"))
end

function CorePortal:parse_portal_list(node)
	local name = node:parameter("name")
	local top = tonumber(node:parameter("top")) or 0
	local bottom = tonumber(node:parameter("bottom")) or 0
	local draw_base = tonumber(node:parameter("draw_base")) or 0
	self._portal_shapes[name] = {
		portal = {},
		top = top,
		bottom = bottom,
		draw_base = draw_base
	}
	local portal = self._portal_shapes[name].portal

	for o in node:children() do
		local p = math.string_to_vector(o:parameter("pos"))

		table.insert(portal, {
			pos = p
		})
	end
end

function CorePortal:parse_unit_group(node)
	local name = node:parameter("name")
	local shapes = {}

	for shape in node:children() do
		table.insert(shapes, managers.shape:parse(shape))
	end

	self._unit_groups[name] = shapes
end

function CorePortal:create(offset)
	if not Application:editor() then
		for name, portal in pairs(self._portal_shapes) do
			local t = {}

			for _, data in ipairs(portal.portal) do
				table.insert(t, data.pos + offset)
			end

			local top = portal.top
			local bottom = portal.bottom

			if top == 0 and bottom == 0 then
				top, bottom = nil
			end

			managers.portal:add_portal(t, bottom, top)
		end
	end

	for name, shapes in pairs(self._unit_groups) do
		local group = managers.portal:add_unit_group(name)

		for _, shape in ipairs(shapes) do
			group:add_shape(shape)
		end
	end
end

CoreWire = CoreWire or class()

function CoreWire:init(node)
	self._unit_name = node:parameter("name")

	managers.worlddefinition:preload_unit(self._unit_name)

	self._generic = Generic:new(node)

	node:for_each("wire", callback(self, self, "parse_wire"))
end

function CoreWire:parse_wire(node)
	self._target_pos = math.string_to_vector(node:parameter("target_pos"))
	local rot = math.string_to_vector(node:parameter("target_rot"))
	self._target_rot = Rotation(rot.x, rot.y, rot.z)
	self._slack = tonumber(node:parameter("slack"))
end

function CoreWire:create_unit(offset)
	self._unit = managers.worlddefinition:make_unit(self._unit_name, self._generic, offset)

	if self._unit then
		self._unit:wire_data().slack = self._slack
		local target = self._unit:get_object(Idstring("a_target"))

		target:set_position(self._target_pos)
		target:set_rotation(self._target_rot)
		wire_set_midpoint(self._unit, self._unit:orientation_object():name(), Idstring("a_target"), Idstring("a_bender"))
		self._unit:set_moving()
	end

	return self._unit
end

CoreStaticUnit = CoreStaticUnit or class()

function CoreStaticUnit:init(node)
	self._unit_name = node:parameter("name")

	managers.worlddefinition:preload_unit(self._unit_name)

	self._generic = Generic:new(node)

	self._generic:continent_upgrade_nil_to_world()
end

function CoreStaticUnit:create_unit(offset)
	self._unit = managers.worlddefinition:make_unit(self._unit_name, self._generic, offset)

	return self._unit
end

CoreDynamicUnit = CoreDynamicUnit or class()

function CoreDynamicUnit:init(node)
	self._unit_name = node:parameter("name")

	managers.worlddefinition:preload_unit(self._unit_name)

	self._generic = Generic:new(node)

	self._generic:continent_upgrade_nil_to_world()
end

function CoreDynamicUnit:create_unit(offset)
	self._unit = managers.worlddefinition:make_unit(self._unit_name, self._generic, offset)

	return self._unit
end

function CoreMissionElementUnit:init(node)
	self._unit_name = node:parameter("name")

	managers.worlddefinition:preload_unit(self._unit_name)

	if node:has_parameter("script") then
		self._script = node:parameter("script")
	end

	self._generic = Generic:new(node)

	self._generic:continent_upgrade_nil_to_world()
	node:for_each("values", callback(self, self, "parse_values"))
end

function CoreMissionElementUnit:parse_values(node)
	self._values = MissionElementValues:new(node)
end

function CoreMissionElementUnit:create_unit(offset)
	self._unit = managers.worlddefinition:make_unit(self._unit_name, self._generic, offset)

	if self._unit then
		self._unit:mission_element_data().script = self._script

		managers.worlddefinition:add_mission_element_unit(self._unit)

		if self._type then
			self._type:make_unit(self._unit)
		end

		if self._values then
			self._values:set_values(self._unit)
		end
	end

	return self._unit
end

MissionElementValues = MissionElementValues or class()

function MissionElementValues:init(node)
	self._values = parse_values_node(node)
end

function MissionElementValues:set_values(unit)
	for name, value in pairs(self._values) do
		unit:mission_element_data()[name] = value
	end
end

function CoreOldWorldDefinition:make_generic_data(in_data)
	local data = {
		_name_id = "none",
		_lights = {},
		_triggers = {},
		_exists_in_stages = {}
	}
	local generic = in_data.generic
	local lights = in_data.lights
	local variation = in_data.variation
	local material_variation = in_data.material_variation
	local triggers = in_data.triggers
	local cutscene_actor = in_data.cutscene_actor
	local disable_shadows = in_data.disable_shadows
	local disable_collision = in_data.disable_collision
	local delayed_load = in_data.delayed_load

	if generic then
		data._unit_id = generic.unit_id
		data._name_id = generic.name_id
		data._group_name = generic.group_name
	end

	for _, light in ipairs(lights) do
		table.insert(data._lights, light)
	end

	if variation then
		data._variation = variation.value
	end

	if material_variation then
		data._material_variation = material_variation.value
	end

	if triggers then
		for _, trigger in ipairs(triggers) do
			table.insert(data._triggers, trigger)
		end
	end

	if cutscene_actor then
		data.cutscene_actor = cutscene_actor.name
	end

	if disable_shadows then
		data.disable_shadows = disable_shadows.value
	end

	if disable_collision then
		data.disable_collision = disable_collision.value
	end

	if delayed_load then
		data.delayed_load = delayed_load.value
	end

	data._editable_gui = in_data.editable_gui

	return data
end

Generic = Generic or class()

function Generic:init(node)
	self._name_id = "none"
	self._lights = {}
	self._triggers = {}
	self._exists_in_stages = {}

	node:for_each("generic", callback(self, self, "parse_generic"))
	node:for_each("orientation", callback(self, self, "parse_orientation"))
	node:for_each("light", callback(self, self, "parse_light"))
	node:for_each("variation", callback(self, self, "parse_variation"))
	node:for_each("material_variation", callback(self, self, "parse_material_variation"))
	node:for_each("trigger", callback(self, self, "parse_trigger"))
	node:for_each("editable_gui", callback(self, self, "parse_editable_gui"))
	node:for_each("settings", callback(self, self, "parse_settings"))
	node:for_each("legend_settings", callback(self, self, "parse_legend_settings"))
	node:for_each("exists_in_stage", callback(self, self, "parse_exists_in_stage"))
	node:for_each("cutscene_actor", callback(self, self, "cutscene_actor_settings"))
	node:for_each("disable_shadows", callback(self, self, "parse_disable_shadows"))
	node:for_each("disable_collision", callback(self, self, "parse_disable_collision"))
	node:for_each("delayed_load", callback(self, self, "parse_delayed_load"))
end

function Generic:parse_orientation(node)
	self._position = math.string_to_vector(node:parameter("pos"))
	local rot = math.string_to_vector(node:parameter("rot"))
	self._rotation = Rotation(rot.x, rot.y, rot.z)
end

function Generic:parse_generic(node)
	if node:has_parameter("unit_id") then
		self._unit_id = tonumber(node:parameter("unit_id"))
	end

	if node:has_parameter("name_id") then
		self._name_id = node:parameter("name_id")
	end

	if node:has_parameter("group_name") then
		self._group_name = node:parameter("group_name")
	end

	if node:has_parameter("continent") then
		local c = node:parameter("continent")

		if c ~= "nil" then
			self._continent = c
		end
	end
end

function Generic:continent_upgrade_nil_to_world()
	if not self._continent then
		self._continent = "world"
	end
end

function Generic:parse_light(node)
	local name = node:parameter("name")
	local far_range = tonumber(node:parameter("far_range"))
	local enable = toboolean(node:parameter("enabled"))
	local color = math.string_to_vector(node:parameter("color"))
	local angle_start, angle_end, multiplier, falloff_exponent = nil

	if node:has_parameter("angle_start") then
		angle_start = tonumber(node:parameter("angle_start"))
		angle_end = tonumber(node:parameter("angle_end"))
	end

	if node:has_parameter("multiplier") then
		multiplier = node:parameter("multiplier")
	end

	if node:has_parameter("falloff_exponent") then
		falloff_exponent = tonumber(node:parameter("falloff_exponent"))
	end

	table.insert(self._lights, {
		name = name,
		far_range = far_range,
		enable = enable,
		color = color,
		angle_start = angle_start,
		angle_end = angle_end,
		multiplier = multiplier,
		falloff_exponent = falloff_exponent
	})
end

function Generic:parse_variation(node)
	self._variation = node:parameter("value")
end

function Generic:parse_material_variation(node)
	self._material_variation = node:parameter("value")
end

function Generic:parse_settings(node)
	self._unique_item = toboolean(node:parameter("unique_item"))
end

function Generic:parse_legend_settings(node)
	self._legend_name = node:parameter("legend_name")
end

function Generic:cutscene_actor_settings(node)
	self.cutscene_actor = node:parameter("name")
end

function Generic:parse_disable_shadows(node)
	self.disable_shadows = toboolean(node:parameter("value"))
end

function Generic:parse_disable_collision(node)
	self.disable_collision = toboolean(node:parameter("value"))
end

function Generic:parse_delayed_load(node)
	self.delayed_load = toboolean(node:parameter("value"))
end

function Generic:parse_exists_in_stage(node)
	self._exists_in_stages[tonumber(node:parameter("stage"))] = toboolean(node:parameter("value"))
end

function Generic:parse_trigger(node)
	local trigger = {
		name = node:parameter("name"),
		id = tonumber(node:parameter("id")),
		notify_unit_id = tonumber(node:parameter("notify_unit_id")),
		time = tonumber(node:parameter("time")),
		notify_unit_sequence = node:parameter("notify_unit_sequence")
	}

	table.insert(self._triggers, trigger)
end

function Generic:parse_editable_gui(node)
	local text = node:parameter("text")
	local font_color = math.string_to_vector(node:parameter("font_color"))
	local font_size = tonumber(node:parameter("font_size"))
	local align = node:parameter("align")
	local vertical = node:parameter("vertical")
	local blend_mode = node:parameter("blend_mode")
	local render_template = node:parameter("render_template")
	local wrap = node:parameter("wrap") == "on"
	local word_wrap = node:parameter("word_wrap") == "on"
	local alpha = tonumber(node:parameter("alpha"))
	local shape = string.split(node:parameter("shape"), " ")
	self._editable_gui = {
		text = text,
		font_color = font_color,
		font_size = font_size,
		align = align,
		vertical = vertical,
		blend_mode = blend_mode,
		render_template = render_template,
		wrap = wrap,
		word_wrap = word_wrap,
		alpha = alpha,
		shape = shape
	}
end
