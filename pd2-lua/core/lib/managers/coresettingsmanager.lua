core:module("CoreSettingsManager")
core:import("CoreClass")

SettingsManager = SettingsManager or CoreClass.class()

function SettingsManager:init(settings_file_path)
	assert(type(settings_file_path) == "string")

	self.__path = settings_file_path
	local script = nil
	local file = SystemFS:open(settings_file_path, "r")

	if not file:at_end() then
		script = file:read()
	end

	SystemFS:close(file)

	self.__settings = script and loadstring(script)() or {}
end

function SettingsManager:destroy()
	self:save()
end

function SettingsManager:save()
	local file = SystemFS:open(self.__path, "w")

	file:write("return ")
	self:_serialize(self.__settings, file)
	SystemFS:close(file)
	managers.database:recompile(file)
end

function SettingsManager:get(category)
	self.__settings[category] = self.__settings[category] or {}

	return self.__settings[category]
end

function SettingsManager:_serialize(value, file, indentation)
	indentation = indentation or 1
	local t = type(value)

	if t == "table" then
		local indent = string.rep("\t", indentation)

		file:write("{\n")

		for key, value in pairs(value) do
			assert(type(key) ~= "table", "Using a table for a key is unsupported.")
			file:write(indent .. "[" .. self:_inspect(key) .. "] = ")
			self:_serialize(value, file, indentation + 1)
			file:write(";\n")
		end

		file:write(string.rep("\t", indentation - 1) .. "}")
	elseif t == "string" or t == "number" or t == "boolean" then
		file:write(self:_inspect(value), file, indentation)
	else
		error("Unable to serialize type \"" .. t .. "\".")
	end
end

function SettingsManager:_inspect(value)
	local t = type(value)

	if t == "string" then
		return string.format("%q", value)
	elseif t == "number" or t == "boolean" then
		return tostring(value)
	else
		error("Unable to inspect type \"" .. t .. "\".")
	end
end
