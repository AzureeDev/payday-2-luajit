core:module("CoreKeywordArguments")
core:import("CoreClass")

function parse_kwargs(args, ...)
	assert(#args == 1)
	assert(type(args[1]) == "table")

	local kwargs = args[1]
	local result = {}

	for _, arg_def in ipairs({
		...
	}) do
		local j = string.find(arg_def, ":")
		local typ = string.sub(arg_def, 1, j - 1)
		local name = string.sub(arg_def, j + 1)
		local value = kwargs[name]

		assert(type(value) == typ, string.format("For value='%s' wanted type is '%s', received '%s'", name, typ, type(value)))
		table.insert(result, value)

		kwargs[name] = nil
	end

	for n, v in pairs(kwargs) do
		assert(n)
	end

	return unpack(result)
end

KeywordArguments = KeywordArguments or CoreClass.class()

function KeywordArguments:init(...)
	local args = {
		...
	}

	assert(#args == 1, "must be called with one argument only (a table with keyword arguments)")
	assert(type(args[1]) == "table", "must be called with table as first argument")

	self._kwargs = args[1]
	self._unconsumed_kwargs = {}

	for k, _ in pairs(self._kwargs) do
		self._unconsumed_kwargs[k] = k
	end
end

function KeywordArguments:assert_all_consumed()
	assert(table.size(self._unconsumed_kwargs) == 0, "unknown keyword argument(s): " .. string.join(", ", self._unconsumed_kwargs))
end

function KeywordArguments:mandatory(...)
	local ret_list = {}

	for _, n in ipairs({
		...
	}) do
		local v = self._kwargs[n]

		assert(v ~= nil, "a mandatory keyword argument (" .. n .. ") is missing")
		table.insert(ret_list, v)

		self._unconsumed_kwargs[n] = nil
	end

	return unpack(ret_list)
end

function KeywordArguments:mandatory_string(...)
	local ret_list = {}

	for _, n in ipairs({
		...
	}) do
		local v = self._kwargs[n]

		assert(v ~= nil, "a mandatory keyword argument (" .. n .. ") is missing")
		assert(type(v) == "string", "keyword argument is not a string (" .. n .. "=" .. tostring(v) .. ")")
		table.insert(ret_list, v)

		self._unconsumed_kwargs[n] = nil
	end

	return unpack(ret_list)
end

function KeywordArguments:mandatory_number(...)
	local ret_list = {}

	for _, n in ipairs({
		...
	}) do
		local v = self._kwargs[n]

		assert(v ~= nil, "a mandatory keyword argument (" .. n .. ") is missing")
		assert(type(v) == "number", "keyword argument is not a number (" .. n .. "=" .. tostring(v) .. ")")
		table.insert(ret_list, v)

		self._unconsumed_kwargs[n] = nil
	end

	return unpack(ret_list)
end

function KeywordArguments:mandatory_table(...)
	local ret_list = {}

	for _, n in ipairs({
		...
	}) do
		local v = self._kwargs[n]

		assert(v ~= nil, "a mandatory keyword argument (" .. n .. ") is missing")
		assert(type(v) == "table", "keyword argument is not a table (" .. n .. "=" .. tostring(v) .. ")")
		table.insert(ret_list, v)

		self._unconsumed_kwargs[n] = nil
	end

	return unpack(ret_list)
end

function KeywordArguments:mandatory_function(...)
	local ret_list = {}

	for _, n in ipairs({
		...
	}) do
		local v = self._kwargs[n]

		assert(v ~= nil, "a mandatory keyword argument (" .. n .. ") is missing")
		assert(type(v) == "function", "keyword argument is not a function (" .. n .. "=" .. tostring(v) .. ")")
		table.insert(ret_list, v)

		self._unconsumed_kwargs[n] = nil
	end

	return unpack(ret_list)
end

function KeywordArguments:mandatory_object(...)
	local ret_list = {}

	for _, n in ipairs({
		...
	}) do
		local v = self._kwargs[n]

		assert(v ~= nil, "a mandatory keyword argument (" .. n .. ") is missing")
		assert(type(v) == "table" or type(v) == "userdata", "keyword argument is not a table or userdata (" .. n .. "=" .. tostring(v) .. ")")
		table.insert(ret_list, v)

		self._unconsumed_kwargs[n] = nil
	end

	return unpack(ret_list)
end

function KeywordArguments:optional(...)
	local ret_list = {}

	for _, n in ipairs({
		...
	}) do
		table.insert(ret_list, self._kwargs[n])

		self._unconsumed_kwargs[n] = nil
	end

	return unpack(ret_list)
end

function KeywordArguments:optional_string(...)
	local ret_list = {}

	for _, n in ipairs({
		...
	}) do
		local v = self._kwargs[n]

		assert(v == nil or type(v) == "string", "keyword argument is not a string (" .. n .. "=" .. tostring(v) .. ")")
		table.insert(ret_list, v)

		self._unconsumed_kwargs[n] = nil
	end

	return unpack(ret_list)
end

function KeywordArguments:optional_number(...)
	local ret_list = {}

	for _, n in ipairs({
		...
	}) do
		local v = self._kwargs[n]

		assert(v == nil or type(v) == "number", "keyword argument is not a number (" .. n .. "=" .. tostring(v) .. ")")
		table.insert(ret_list, v)

		self._unconsumed_kwargs[n] = nil
	end

	return unpack(ret_list)
end

function KeywordArguments:optional_table(...)
	local ret_list = {}

	for _, n in ipairs({
		...
	}) do
		local v = self._kwargs[n]

		assert(v == nil or type(v) == "table", "keyword argument is not a table or userdata (" .. n .. "=" .. tostring(v) .. ")")
		table.insert(ret_list, v)

		self._unconsumed_kwargs[n] = nil
	end

	return unpack(ret_list)
end

function KeywordArguments:optional_function(...)
	local ret_list = {}

	for _, n in ipairs({
		...
	}) do
		local v = self._kwargs[n]

		assert(v == nil or type(v) == "function", "keyword argument is not a function (" .. n .. "=" .. tostring(v) .. ")")
		table.insert(ret_list, v)

		self._unconsumed_kwargs[n] = nil
	end

	return unpack(ret_list)
end

function KeywordArguments:optional_object(...)
	local ret_list = {}

	for _, n in ipairs({
		...
	}) do
		local v = self._kwargs[n]

		assert(v == nil or type(v) == "table" or type(v) == "userdata", "keyword argument is not a table or userdata (" .. n .. "=" .. tostring(v) .. ")")
		table.insert(ret_list, v)

		self._unconsumed_kwargs[n] = nil
	end

	return unpack(ret_list)
end
