core:module("CoreEngineAccess")

local function get_class_table(engine_class_name)
	local class_table = rawget(_G, engine_class_name)

	if class_table then
		return class_table, nil
	else
		return nil, string.format("Engine-side class not found: \"%s\".", engine_class_name)
	end
end

local function get_method_table(engine_class_name)
	local class_table, problem = get_class_table(engine_class_name)

	if problem then
		return nil, problem
	end

	local class_meta_table = getmetatable(class_table)

	if class_meta_table == nil then
		return nil, string.format("Global \"%s\" is not bound to a class table.", engine_class_name)
	end

	local method_table = rawget(class_meta_table, "__index")

	if method_table == nil then
		return nil, string.format("Metatable for class \"%s\" does not have an __index member.", engine_class_name)
	end

	if type(method_table) ~= "table" then
		return nil, string.format("Metatable for class \"%s\" does not use a table for indexing methods.", engine_class_name)
	end

	return method_table, nil
end

local function hide_static_engine_method(engine_class_name, method_name, message)
	assert(engine_class_name and method_name, "Invalid argument list.")

	local function failure_func(failure_message)
		return function (...)
			error(string.format("Failed to call hidden method %s:%s(...). %s", engine_class_name, method_name, failure_message))
		end
	end

	local method_table, problem = get_method_table(engine_class_name)

	if problem then
		return failure_func(problem)
	end

	local method = method_table[method_name]

	if type(method) ~= "function" then
		return failure_func("Method not found.")
	end

	method_table[method_name] = function ()
		error(string.format("%s:%s(...) has been hidden by core. %s", engine_class_name, method_name, message or "You should not call it directly."))
	end

	local class_table = assert(get_class_table(engine_class_name))

	return function (...)
		return method(class_table, ...)
	end
end

if not __required then
	__required = true
	_exec = hide_static_engine_method("Application", "exec", "Use CoreSetup:exec(...) instead!")
	_quit = hide_static_engine_method("Application", "quit", "Use CoreSetup:quit(...) instead!")
	_editor_package = hide_static_engine_method("PackageManager", "editor_package")
	_editor_load = hide_static_engine_method("PackageManager", "editor_load")
	_editor_reload = hide_static_engine_method("PackageManager", "editor_reload")
	_editor_reload_node = hide_static_engine_method("PackageManager", "editor_reload_node")
	_editor_unit_data = hide_static_engine_method("PackageManager", "editor_unit_data")
end
