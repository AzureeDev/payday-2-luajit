core:module("CoreDebug")
core:import("CoreCode")
core:import("CoreApp")

Global.render_debug = Global.render_debug or {}
Global.render_debug_initialized = Global.render_debug_initialized or {}

if not Global.render_debug_initialized.coredebug then
	Global.render_debug.draw_enabled = true
	Global.render_debug.render_sky = true
	Global.render_debug.render_world = true
	Global.render_debug.render_overlay = true
	Global.render_debug_initialized.coredebug = true
end

function only_in_debug(f, klass)
	klass = klass or getmetatable(Application)
	local old = "old_" .. f

	if not klass[old] then
		klass[old] = klass[f]

		klass[f] = function (...)
			if Global.render_debug.draw_enabled then
				klass[old](...)
			end
		end
	end
end

only_in_debug("draw")
only_in_debug("draw_sphere")
only_in_debug("draw_line")
only_in_debug("draw_cone")
only_in_debug("draw_circle")
only_in_debug("draw_rotation")
only_in_debug("draw_cylinder")
only_in_debug("draw_line_unpaused")
only_in_debug("draw_sphere_unpaused")
only_in_debug("draw_rotation_size")
only_in_debug("draw_arrow")
only_in_debug("draw_link")
only_in_debug("arrow", Pen)

Global.category_print = Global.category_print or {}
Global.category_print_initialized = Global.category_print_initialized or {}

if not Global.category_print_initialized.coredebug then
	Global.category_print.debug = true
	Global.category_print.editor = false
	Global.category_print.sequence = false
	Global.category_print.controller_manager = false
	Global.category_print.game_state_machine = false
	Global.category_print.subtitle_manager = false
	Global.category_print_initialized.coredebug = true
end

function out(...)
	local CAT_TYPE = "debug"
	local NO_CAT = "spam"
	local args = {
		...
	}

	local function correct_spaces(...)
		local args = {
			...
		}
		local sel = {
			select(2, ...)
		}
		sel[1] = args[1] .. " " .. tostring(sel[1])

		return unpack(sel)
	end

	local function do_print(c, ...)
		local cat = CAT_TYPE
		local args = {
			...
		}

		for k, _ in pairs(Global.category_print) do
			if k == c then
				cat = c

				break
			end
		end

		cat_print(cat, ...)
	end

	if #args == 0 then
		return
	elseif #args > 1 and type(args[1]) == "string" then
		local a = args[1]
		args[1] = "[" .. a .. "]"

		do_print(a, correct_spaces(unpack(args)))
	else
		do_print(NO_CAT, correct_spaces("[" .. NO_CAT .. "]", unpack(args)))
	end
end

function cat_print(cat, ...)
	if Global.category_print[cat] then
		_G.print(...)
	end
end

function cat_debug(cat, ...)
	if Global.category_print[cat] then
		Application:debug(...)
	end
end

function cat_error(cat, ...)
	if Global.category_print[cat] then
		Application:error(...)
	end
end

function cat_stack_dump(cat)
	if Global.category_print[cat] then
		Application:stack_dump()
	end
end

function cat_print_inspect(cat, ...)
	if Global.category_print[cat] then
		for _, var in ipairs({
			...
		}) do
			cat_print(cat, CoreCode.inspect(var))
		end
	end
end

function cat_debug_inspect(cat, ...)
	if Global.category_print[cat] then
		for _, var in ipairs({
			...
		}) do
			cat_debug(cat, "\n" .. tostring(CoreCode.inspect(var)))
		end
	end
end

function catprint_save()
	local data = {
		_meta = "categories"
	}

	for name, allow_print in pairs(Global.category_print) do
		if Global.original_category_print[name] ~= allow_print then
			table.insert(data, {
				_meta = "category",
				name = name,
				print = allow_print
			})
		end
	end

	local path = managers.database:base_path() .. "settings/catprint.catprint"
	local file = SystemFS:open(path, "w")

	file:print(ScriptSerializer:to_custom_xml(data))
	file:close()
end

function catprint_load()
	if not Global.original_category_print then
		Global.original_category_print = {}

		for category, default in pairs(Global.category_print) do
			Global.original_category_print[category] = default
		end
	end

	local file_path = "settings/catprint"
	local file_extension = "catprint"

	if DB:has(file_extension, file_path) then
		local xml = DB:open(file_extension, file_path):read()
		local data = ScriptSerializer:from_custom_xml(xml)

		for _, sub_data in ipairs(data) do
			local name = tostring(sub_data.name)
			local allow_print = sub_data.print == true
			Global.category_print[name] = allow_print
		end
	end
end

function print_console_result(...)
	for i = 1, select("#", ...) do
		cat_print("debug", CoreCode.full_representation(select(i, ...)))
	end
end

function compile_and_reload()
	local function root_path()
		local path = Application:base_path() .. (CoreApp.arg_value("-assetslocation") or "../../")
		local f = nil

		function f(s)
			local str, i = string.gsub(s, "\\[%w_%.%s]+\\%.%.", "")

			return i > 0 and f(str) or str
		end

		return f(path)
	end

	assert(SystemInfo:platform() == Idstring("WIN32"), "You can only compile on win32 platforms!")
	Application:data_compile({
		target_db_name = "all",
		preprocessor_definitions = "preprocessor_definitions",
		verbose = false,
		platform = string.lower(SystemInfo:platform():s()),
		source_root = root_path() .. "//assets",
		target_db_root = Application:base_path() .. "assets"
	})
	DB:reload()
	Application:console_command("reload")
end

function class_name(class)
	return core:_lookup(class)
end

function full_class_name(class)
	local x, y = class_name(class)

	return y .. "." .. x
end

function watch(cond_func, exact)
	debug.sethook(function ()
		if cond_func() then
			if exact then
				cat_print("debug", string.format("[CoreVarTrace] %s", rawget(_G, "__watch_previnfo") or "? : -1"))
			else
				local src = debug.getinfo(2, "Sl")

				cat_print("debug", "[CoreVarTrace] Probably file: " .. (src and src.source or "?"))
				cat_print("debug", "[CoreVarTrace] Might be line: " .. (src and src.currentline or -1))
			end

			cat_print("debug", debug.traceback())
			debug.sethook()
		end

		if exact then
			local src = debug.getinfo(2, "Sl")

			if src then
				rawset(_G, "__watch_previnfo", string.format("%s : %i", src.source or "?", src.currentline or -1))
			end
		end
	end, "l", 1)
end

function trace_ref(class_name, init_name, destroy_name)
	local class_mt = type(class_name) == "string" and getmetatable(assert(rawget(_G, class_name))) or class_name

	local function ref()
		local t = rawget(_G, "_trace_ref_table")

		if not t then
			t = {}

			rawset(_G, "_trace_ref_table", t)
			cat_print("debug", "[CoreTraceRef] ---------------------- New Script Environment --------------------------")
		end
	end

	local function stack()
		return string.gsub(debug.traceback(), "%\n", "\n[CoreTraceRef]\t")
	end

	if not rawget(class_mt, "_" .. init_name) then
		rawset(class_mt, "_" .. init_name, assert(rawget(class_mt, init_name)))
		rawset(class_mt, init_name, function (...)
			ref()

			local r = rawget(class_mt, "_" .. init_name)(...)
			local t = rawget(_G, "_trace_ref_table")

			cat_print("debug", "[CoreTraceRef] New ref:", r)

			t[r] = stack()

			return r
		end)
	end

	if not rawget(class_mt, "_" .. destroy_name) then
		rawset(class_mt, "_" .. destroy_name, assert(rawget(class_mt, destroy_name)))
		rawset(class_mt, destroy_name, function (...)
			ref()

			local p = {
				...
			}
			local o = p[2]

			if not o or o.alive and not o:alive() then
				cat_print("debug", "[CoreTraceRef] WARNING! Deleting NULL ref: ", o, stack())
			else
				cat_print("debug", "[CoreTraceRef] Delete ref:", o)
			end

			local r = rawget(class_mt, "_" .. destroy_name)(...)
			local t = rawget(_G, "_trace_ref_table")
			t[o] = nil

			return r
		end)
	end

	if not rawget(_G, "_destroy") then
		rawset(_G, "_destroy", rawget(_G, "destroy"))
		rawset(_G, "destroy", function (...)
			ref()

			local d = rawget(_G, "_destroy")

			if d then
				d(...)
			end

			local c = 0
			local t = assert(rawget(_G, "_trace_ref_table"))

			for k, v in pairs(t) do
				c = c + 1
			end

			cat_print("debug", string.format("[CoreTraceRef] ---------------------- %i Script References Lost --------------------------", c))

			for k, v in pairs(t) do
				cat_print("debug", "[CoreTraceRef]", k, v)
			end
		end)
	end
end

function trace_ref_add_destroy_all(class_name, func_name)
	local class_mt = type(class_name) == "string" and getmetatable(assert(rawget(_G, class_name))) or class_name

	rawset(class_mt, "_" .. func_name, assert(rawget(class_mt, func_name)))

	if not rawget(class_mt, "_" .. func_name) then
		rawset(class_mt, func_name, function (...)
			local r = rawget(class_mt, "_" .. func_name)(...)

			cat_print("debug", "[CoreTraceRef] WARNING! Called destroy all function:", func_name)

			return r
		end)
	end
end

function debug_pause(...)
end

function debug_pause_unit(unit, ...)
end

function get_n_key(t, n)
	n = n or 1

	for k, _ in pairs(t) do
		if n == 1 then
			return k
		else
			n = n - 1
		end
	end
end

function get_n_value(t, n)
	n = n or 1

	for _, v in pairs(t) do
		if n == 1 then
			return v
		else
			n = n - 1
		end
	end
end
