CoreCutsceneActorDatabase = CoreCutsceneActorDatabase or class()
CoreCutsceneActorDatabaseUnitTypeInfo = CoreCutsceneActorDatabaseUnitTypeInfo or class()

function CoreCutsceneActorDatabase:unit_type_info(unit_type)
	return unit_type and self._registered_unit_types and self._registered_unit_types[unit_type]
end

function CoreCutsceneActorDatabase:append_unit_info(unit)
	self._registered_unit_types = self._registered_unit_types or {}
	self._registered_unit_types[unit:name()] = self._registered_unit_types[unit:name()] or core_or_local("CutsceneActorDatabaseUnitTypeInfo", unit:name())

	self._registered_unit_types[unit:name()]:_append_unit_info(unit)
end

function CoreCutsceneActorDatabaseUnitTypeInfo:init(unit_type)
	self._unit_type = unit_type
end

function CoreCutsceneActorDatabaseUnitTypeInfo:unit_type()
	return self._unit_type
end

function CoreCutsceneActorDatabaseUnitTypeInfo:object_names()
	return self._object_names or {}
end

function CoreCutsceneActorDatabaseUnitTypeInfo:initial_object_visibility(object_name)
	return self._object_visibilities and self._object_visibilities[object_name] or false
end

function CoreCutsceneActorDatabaseUnitTypeInfo:extensions()
	return self._extensions or {}
end

function CoreCutsceneActorDatabaseUnitTypeInfo:animation_groups()
	return self._animation_groups or {}
end

function CoreCutsceneActorDatabaseUnitTypeInfo:_append_unit_info(unit)
	assert(self:unit_type() == unit:name())

	if self._object_names == nil then
		self._object_names = table.collect(unit:get_objects("*"), function (object)
			return object:name()
		end)

		table.sort(self._object_names, string.case_insensitive_compare)
		freeze(self._object_names)
	end

	if self._object_visibilities == nil then
		self._object_visibilities = table.remap(unit:get_objects("*"), function (_, object)
			return object:name(), object.visibility and object:visibility() or nil
		end)
	end

	if self._extensions == nil then
		self._extensions = {}

		for _, extension_name in ipairs(unit:extensions()) do
			local extension = unit[extension_name] and unit[extension_name](unit)

			if extension then
				local methods = {}

				for key, value in pairs(getmetatable(extension)) do
					if type(value) == "function" and not string.begins(key, "_") and key ~= "new" and key ~= "init" then
						methods[key] = self:_argument_names_for_function(value)
					end
				end

				self._extensions[extension_name] = methods
			end
		end

		freeze(self._extensions)
	end

	if self._animation_groups == nil then
		self._animation_groups = unit:anim_groups()
	end

	freeze(self)
end

function CoreCutsceneActorDatabaseUnitTypeInfo:_argument_names_for_function(func)
	if not Application:ews_enabled() then
		return {}
	end

	local argument_names = {}
	local info = debug.getinfo(func)
	local source_path = managers.database:base_path() .. info.source
	local file = SystemFS:open(source_path, "r")
	local func_definition = self:_file_line(file, info.linedefined)

	file:close()

	local arg_list = string.match(string.match(func_definition, "%b()") or "", "%((.+)%)")

	return arg_list and string.split(arg_list, "[,%s]") or {}
end

function CoreCutsceneActorDatabaseUnitTypeInfo:_file_line(file, line)
	while not file:at_end() do
		local text = file:gets()
		line = line - 1

		if line == 0 then
			return text
		end
	end
end
