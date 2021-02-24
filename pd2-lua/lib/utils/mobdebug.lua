local require = require
local io = io or require("io")
local table = table or require("table")
local string = string or require("string")
local coroutine = coroutine or require("coroutine")
local debug = require("debug")
local os = os or function (module)
	local ok, res = pcall(require, module)

	return ok and res or nil
end("os")
local mobdebug = {
	yieldtimeout = 0.02,
	_DESCRIPTION = "Mobile Remote Debugger for the Lua programming language",
	_NAME = "mobdebug",
	_VERSION = "0.706",
	_COPYRIGHT = "Paul Kulchenko",
	checkcount = 200,
	connecttimeout = 2,
	port = os and os.getenv and tonumber(os.getenv("MOBDEBUG_PORT")) or 8172
}
local HOOKMASK = "lcr"
local error = error
local getfenv = getfenv
local setfenv = setfenv
local loadstring = loadstring or load
local pairs = pairs
local setmetatable = setmetatable
local tonumber = tonumber
local unpack = table.unpack or unpack
local rawget = rawget
local gsub = string.gsub
local sub = string.sub
local find = string.find
local genv = _G or _ENV
local jit = rawget(genv, "jit")
local MOAICoroutine = rawget(genv, "MOAICoroutine")
local metagindex = getmetatable(genv) and getmetatable(genv).__index
local ngx = type(metagindex) == "table" and metagindex.rawget and metagindex:rawget("ngx") or nil
local corocreate = ngx and coroutine._create or coroutine.create
local cororesume = ngx and coroutine._resume or coroutine.resume
local coroyield = ngx and coroutine._yield or coroutine.yield
local corostatus = ngx and coroutine._status or coroutine.status
local corowrap = coroutine.wrap

if not setfenv then
	local function findenv(f)
		local level = 1

		repeat
			local name, value = debug.getupvalue(f, level)

			if name == "_ENV" then
				return level, value
			end

			level = level + 1
		until name == nil

		return nil
	end

	function getfenv(f)
		return select(2, findenv(f)) or _G
	end

	function setfenv(f, t)
		local level = findenv(f)

		if level then
			debug.setupvalue(f, level, t)
		end

		return f
	end
end

local win = os and os.getenv and (os.getenv("WINDIR") or (os.getenv("OS") or ""):match("[Ww]indows")) and true or false
local mac = not win and (os and os.getenv and os.getenv("DYLD_LIBRARY_PATH") or not io.open("/proc")) and true or false
local iscasepreserving = win or mac and io.open("/library") ~= nil

if jit and jit.off then
	jit.off()
end

local socket = require("lib/utils/socket")
local coro_debugger, coro_debugee = nil
local coroutines = {}

setmetatable(coroutines, {
	__mode = "k"
})

local events = {
	RESTART = 3,
	WATCH = 2,
	STACK = 4,
	BREAK = 1
}
local breakpoints = {}
local watches = {}
local lastsource, lastfile = nil
local watchescnt = 0
local abort = nil
local seen_hook = false
local checkcount = 0
local step_into = false
local step_over = false
local step_level = 0
local stack_level = 0
local server, buf = nil
local outputs = {}
local iobase = {
	print = print
}
local basedir = ""
local deferror = "execution aborted at default debugee"

local function debugee()
	local a = 1

	for _ = 1, 10 do
		a = a + 1
	end

	error(deferror)
end

local function q(s)
	return string.gsub(s, "([%(%)%.%%%+%-%*%?%[%^%$%]])", "%%%1")
end

local serpent = function ()
	local n = "serpent"
	local v = "0.302"
	local c = "Paul Kulchenko"
	local d = "Lua serializer and pretty printer"
	local snum = {
		nan = "0/0",
		inf = "1/0 --[[math.huge]]",
		["-inf"] = "-1/0 --[[-math.huge]]"
	}
	local badtype = {
		userdata = true,
		cdata = true,
		thread = true
	}
	local getmetatable = debug and debug.getmetatable or getmetatable

	local function pairs(t)
		return next, t
	end

	local keyword = {}
	local globals = {}
	local G = _G or _ENV

	for _, k in ipairs({
		"and",
		"break",
		"do",
		"else",
		"elseif",
		"end",
		"false",
		"for",
		"function",
		"goto",
		"if",
		"in",
		"local",
		"nil",
		"not",
		"or",
		"repeat",
		"return",
		"then",
		"true",
		"until",
		"while"
	}) do
		keyword[k] = true
	end

	for k, v in pairs(G) do
		globals[v] = k
	end

	for _, g in ipairs({
		"coroutine",
		"debug",
		"io",
		"math",
		"string",
		"table",
		"os"
	}) do
		for k, v in pairs(type(G[g]) == "table" and G[g] or {}) do
			globals[v] = g .. "." .. k
		end
	end

	local function s(t, opts)
		local name = opts.name
		local indent = opts.indent
		local fatal = opts.fatal
		local maxnum = opts.maxnum
		local sparse = opts.sparse
		local custom = opts.custom
		local huge = not opts.nohuge
		local space = opts.compact and "" or " "
		local maxl = opts.maxlevel or math.huge
		local maxlen = tonumber(opts.maxlength)
		local metatostring = opts.metatostring
		local iname = "_" .. (name or "")
		local comm = opts.comment and (tonumber(opts.comment) or math.huge)
		local numformat = opts.numformat or "%.17g"
		local seen = {}
		local sref = {
			"local " .. iname .. "={}"
		}
		local syms = {}
		local symn = 0

		local function gensym(val)
			return "_" .. tostring(tostring(val)):gsub("[^%w]", ""):gsub("(%d%w+)", function (s)
				if not syms[s] then
					symn = symn + 1
					syms[s] = symn
				end

				return tostring(syms[s])
			end)
		end

		local function safestr(s)
			return type(s) == "number" and tostring(huge and snum[tostring(s)] or numformat:format(s)) or type(s) ~= "string" and tostring(s) or ("%q"):format(s):gsub("\n", "n"):gsub("", "\\026")
		end

		local function comment(s, l)
			return comm and (l or 0) < comm and " --[[" .. select(2, pcall(tostring, s)) .. "]]" or ""
		end

		local function globerr(s, l)
			return globals[s] and globals[s] .. comment(s, l) or not fatal and safestr(select(2, pcall(tostring, s))) or error("Can't serialize " .. tostring(s))
		end

		local function safename(path, name)
			local n = name == nil and "" or name
			local plain = type(n) == "string" and n:match("^[%l%u_][%w_]*$") and not keyword[n]
			local safe = plain and n or "[" .. safestr(n) .. "]"

			return (path or "") .. (plain and path and "." or "") .. safe, safe
		end

		local alphanumsort = type(opts.sortkeys) == "function" and opts.sortkeys or function (k, o, n)
			local maxn = tonumber(n) or 12
			local to = {
				string = "b",
				number = "a"
			}

			local function padnum(d)
				return ("%0" .. tostring(maxn) .. "d"):format(tonumber(d))
			end

			table.sort(k, function (a, b)
				return (k[a] ~= nil and 0 or to[type(a)] or "z") .. tostring(a):gsub("%d+", padnum) < (k[b] ~= nil and 0 or to[type(b)] or "z") .. tostring(b):gsub("%d+", padnum)
			end)
		end

		local function val2str(t, name, indent, insref, path, plainindex, level)
			local ttype = type(t)
			local level = level or 0
			local mt = getmetatable(t)
			local spath, sname = safename(path, name)
			local tag = plainindex and (type(name) == "number" and "" or name .. space .. "=" .. space) or name ~= nil and sname .. space .. "=" .. space or ""

			if seen[t] then
				sref[#sref + 1] = spath .. space .. "=" .. space .. seen[t]

				return tag .. "nil" .. comment("ref", level)
			end

			if type(mt) == "table" and metatostring ~= false then
				local to, tr = pcall(function ()
					return mt.__tostring(t)
				end)
				local so, sr = pcall(function ()
					return mt.__serialize(t)
				end)

				if to or so then
					seen[t] = insref or spath
					t = so and sr or tr
					ttype = type(t)
				end
			end

			if ttype == "table" then
				if maxl <= level then
					return tag .. "{}" .. comment("maxlvl", level)
				end

				seen[t] = insref or spath

				if next(t) == nil then
					return tag .. "{}" .. comment(t, level)
				end

				if maxlen and maxlen < 0 then
					return tag .. "{}" .. comment("maxlen", level)
				end

				local maxn = math.min(#t, maxnum or #t)
				local o = {}
				local out = {}

				for key = 1, maxn do
					o[key] = key
				end

				if not maxnum or #o < maxnum then
					local n = #o

					for key in pairs(t) do
						if o[key] ~= key then
							n = n + 1
							o[n] = key
						end
					end
				end

				if maxnum and maxnum < #o then
					o[maxnum + 1] = nil
				end

				if opts.sortkeys and maxn < #o then
					alphanumsort(o, t, opts.sortkeys)
				end

				local sparse = sparse and maxn < #o

				for n, key in ipairs(o) do
					local value = t[key]
					local ktype = type(key)
					local plainindex = n <= maxn and not sparse

					if (not opts.valignore or not opts.valignore[value]) and (not opts.keyallow or opts.keyallow[key]) and (not opts.keyignore or not opts.keyignore[key]) and (not opts.valtypeignore or not opts.valtypeignore[type(value)]) then
						if sparse and value == nil then
							-- Nothing
						elseif ktype == "table" or ktype == "function" or badtype[ktype] then
							if not seen[key] and not globals[key] then
								sref[#sref + 1] = "placeholder"
								local sname = safename(iname, gensym(key))
								sref[#sref] = val2str(key, sname, indent, sname, iname, true)
							end

							sref[#sref + 1] = "placeholder"
							local path = seen[t] .. "[" .. tostring(seen[key] or globals[key] or gensym(key)) .. "]"
							sref[#sref] = path .. space .. "=" .. space .. tostring(seen[value] or val2str(value, nil, indent, path))
						else
							out[#out + 1] = val2str(value, key, indent, nil, seen[t], plainindex, level + 1)

							if maxlen then
								maxlen = maxlen - #out[#out]

								if maxlen < 0 then
									break
								end
							end
						end
					end
				end

				local prefix = string.rep(indent or "", level)
				local head = indent and "{\n" .. prefix .. indent or "{"
				local body = table.concat(out, "," .. (indent and "\n" .. prefix .. indent or space))
				local tail = indent and "\n" .. prefix .. "}" or "}"

				return (custom and custom(tag, head, body, tail, level) or tag .. head .. body .. tail) .. comment(t, level)
			elseif badtype[ttype] then
				seen[t] = insref or spath

				return tag .. globerr(t, level)
			elseif ttype == "function" then
				seen[t] = insref or spath

				if opts.nocode then
					return tag .. "function() --[[..skipped..]] end" .. comment(t, level)
				end

				local ok, res = pcall(string.dump, t)
				local func = ok and "((loadstring or load)(" .. safestr(res) .. ",'@serialized'))" .. comment(t, level)

				return tag .. (func or globerr(t, level))
			else
				return tag .. safestr(t)
			end
		end

		local sepr = indent and "\n" or ";" .. space
		local body = val2str(t, name, indent)
		local tail = #sref > 1 and table.concat(sref, sepr) .. sepr or ""
		local warn = opts.comment and #sref > 1 and space .. "--[[incomplete output with shared/self-references skipped]]" or ""

		return not name and body .. warn or "do local " .. body .. sepr .. tail .. "return " .. name .. sepr .. "end"
	end

	local function deserialize(data, opts)
		local env = opts and opts.safe == false and G or setmetatable({}, {
			__index = function (t, k)
				return t
			end,
			__call = function (t, ...)
				error("cannot call functions")
			end
		})
		local f, res = loadstring or load("return " .. data, nil, nil, env)

		if not f then
			f, res = loadstring or load(data, nil, nil, env)
		end

		if not f then
			return f, res
		end

		if setfenv then
			setfenv(f, env)
		end

		return pcall(f)
	end

	local function merge(a, b)
		if b then
			for k, v in pairs(b) do
				a[k] = v
			end
		end

		return a
	end

	return {
		_NAME = n,
		_COPYRIGHT = c,
		_DESCRIPTION = d,
		_VERSION = v,
		serialize = s,
		load = deserialize,
		dump = function (a, opts)
			return s(a, merge({
				sparse = true,
				name = "_",
				compact = true
			}, opts))
		end,
		line = function (a, opts)
			return s(a, merge({
				sortkeys = true,
				comment = true
			}, opts))
		end,
		block = function (a, opts)
			return s(a, merge({
				sortkeys = true,
				indent = "  ",
				comment = true
			}, opts))
		end
	}
end()
mobdebug.line = serpent.line
mobdebug.dump = serpent.dump
mobdebug.linemap = nil
mobdebug.loadstring = loadstring

local function removebasedir(path, basedir)
	if iscasepreserving then
		return path:lower():find("^" .. q(basedir:lower())) and path:sub(#basedir + 1) or path
	else
		return string.gsub(path, "^" .. q(basedir), "")
	end
end

local function stack(start)
	local function vars(f)
		local func = debug.getinfo(f, "f").func
		local i = 1
		local locals = {}

		while true do
			local name, value = debug.getlocal(f, i)

			if not name then
				break
			end

			if string.sub(name, 1, 1) ~= "(" then
				locals[name] = {
					value,
					select(2, pcall(tostring, value))
				}
			end

			i = i + 1
		end

		i = 1

		while true do
			local name, value = debug.getlocal(f, -i)

			if not name or name ~= "(*vararg)" then
				break
			end

			locals[name:gsub("%)$", " " .. i .. ")")] = {
				value,
				select(2, pcall(tostring, value))
			}
			i = i + 1
		end

		i = 1
		local ups = {}

		while func do
			local name, value = debug.getupvalue(func, i)

			if not name then
				break
			end

			ups[name] = {
				value,
				select(2, pcall(tostring, value))
			}
			i = i + 1
		end

		return locals, ups
	end

	local stack = {}
	local linemap = mobdebug.linemap

	for i = start or 0, 100 do
		local source = debug.getinfo(i, "Snl")

		if not source then
			break
		end

		local src = source.source

		if src:find("@") == 1 then
			src = src:sub(2):gsub("\\", "/")

			if src:find("%./") == 1 then
				src = src:sub(3)
			end
		end

		table.insert(stack, {
			{
				source.name,
				removebasedir(src, basedir),
				linemap and linemap(source.linedefined, source.source) or source.linedefined,
				linemap and linemap(source.currentline, source.source) or source.currentline,
				source.what,
				source.namewhat,
				source.short_src
			},
			vars(i + 1)
		})

		if source.what == "main" then
			break
		end
	end

	return stack
end

local function set_breakpoint(file, line)
	if file == "-" and lastfile then
		file = lastfile
	elseif iscasepreserving then
		file = string.lower(file)
	end

	if not breakpoints[line] then
		breakpoints[line] = {}
	end

	breakpoints[line][file] = true
end

local function remove_breakpoint(file, line)
	if file == "-" and lastfile then
		file = lastfile
	elseif file == "*" and line == 0 then
		breakpoints = {}
	elseif iscasepreserving then
		file = string.lower(file)
	end

	if breakpoints[line] then
		breakpoints[line][file] = nil
	end
end

local function has_breakpoint(file, line)
	return breakpoints[line] and breakpoints[line][iscasepreserving and string.lower(file) or file]
end

local function restore_vars(vars)
	if type(vars) ~= "table" then
		return
	end

	local i = 1

	while true do
		local name = debug.getlocal(3, i)

		if not name then
			break
		end

		i = i + 1
	end

	i = i - 1
	local written_vars = {}

	while i > 0 do
		local name = debug.getlocal(3, i)

		if not written_vars[name] then
			if string.sub(name, 1, 1) ~= "(" then
				debug.setlocal(3, i, rawget(vars, name))
			end

			written_vars[name] = true
		end

		i = i - 1
	end

	i = 1
	local func = debug.getinfo(3, "f").func

	while true do
		local name = debug.getupvalue(func, i)

		if not name then
			break
		end

		if not written_vars[name] then
			if string.sub(name, 1, 1) ~= "(" then
				debug.setupvalue(func, i, rawget(vars, name))
			end

			written_vars[name] = true
		end

		i = i + 1
	end
end

local function capture_vars(level, thread)
	level = (level or 0) + 2
	local func = (thread and debug.getinfo(thread, level, "f") or debug.getinfo(level, "f") or {}).func

	if not func then
		return {}
	end

	local vars = {
		["..."] = {}
	}
	local i = 1

	while true do
		local name, value = debug.getupvalue(func, i)

		if not name then
			break
		end

		if string.sub(name, 1, 1) ~= "(" then
			vars[name] = value
		end

		i = i + 1
	end

	i = 1

	while true do
		local name, value = nil

		if thread then
			name, value = debug.getlocal(thread, level, i)
		else
			name, value = debug.getlocal(level, i)
		end

		if not name then
			break
		end

		if string.sub(name, 1, 1) ~= "(" then
			vars[name] = value
		end

		i = i + 1
	end

	i = 1

	while true do
		local name, value = nil

		if thread then
			name, value = debug.getlocal(thread, level, -i)
		else
			name, value = debug.getlocal(level, -i)
		end

		if not name or name ~= "(*vararg)" then
			break
		end

		vars["..."][i] = value
		i = i + 1
	end

	setmetatable(vars, {
		__mode = "v",
		__index = getfenv(func),
		__newindex = getfenv(func)
	})

	return vars
end

local function stack_depth(start_depth)
	for i = start_depth, 0, -1 do
		if debug.getinfo(i, "l") then
			return i + 1
		end
	end

	return start_depth
end

local function is_safe(stack_level)
	if stack_level == 3 then
		return true
	end

	for i = 3, stack_level do
		local info = debug.getinfo(i, "S")

		if not info then
			return true
		end

		if info.what == "C" then
			return false
		end
	end

	return true
end

local function in_debugger()
	local this = debug.getinfo(1, "S").source

	for i = 3, 7 do
		local info = debug.getinfo(i, "S")

		if not info then
			return false
		end

		if info.source == this then
			return true
		end
	end

	return false
end

local function is_pending(peer)
	if not buf and mobdebug.checkcount <= checkcount then
		peer:settimeout(0)

		buf = peer:receive(1)

		peer:settimeout()

		checkcount = 0
	end

	return buf
end

local function readnext(peer, num)
	peer:settimeout(0)

	local res, err, partial = peer:receive(num)

	peer:settimeout()

	return res or partial or "", err
end

local function handle_breakpoint(peer)
	if not buf or buf:sub(1, 1) ~= "S" and buf:sub(1, 1) ~= "D" then
		return
	end

	if #buf == 1 then
		buf = buf .. readnext(peer, 1)
	end

	if buf:sub(2, 2) ~= "E" then
		return
	end

	buf = buf .. readnext(peer, 5 - #buf)

	if buf ~= "SETB " and buf ~= "DELB " then
		return
	end

	local res, _, partial = peer:receive()

	if not res then
		if partial then
			buf = buf .. partial
		end

		return
	end

	local _, _, cmd, file, line = (buf .. res):find("^([A-Z]+)%s+(.-)%s+(%d+)%s*$")

	if cmd == "SETB" then
		set_breakpoint(file, tonumber(line))
	elseif cmd == "DELB" then
		remove_breakpoint(file, tonumber(line))
	else
		return
	end

	buf = nil
end

local function normalize_path(file)
	local n = nil

	repeat
		file, n = file:gsub("/+%.?/+", "/")
	until n == 0

	repeat
		file, n = file:gsub("[^/]+/%.%./", "", 1)
	until n == 0

	return file:gsub("^(/?)%.%./", "%1")
end

local function debug_hook(event, line)
	if jit then
		local coro, main = coroutine.running()

		if not coro or main then
			coro = "main"
		end

		local disabled = coroutines[coro] == false or coroutines[coro] == nil and coro ~= (coro_debugee or "main")

		if coro_debugee and disabled or not coro_debugee and (disabled or in_debugger()) then
			return
		end
	end

	if abort and is_safe(stack_level) then
		error(abort)
	end

	if not seen_hook and in_debugger() then
		return
	end

	if event == "call" then
		stack_level = stack_level + 1
	elseif event == "return" or event == "tail return" then
		stack_level = stack_level - 1
	elseif event == "line" then
		if mobdebug.linemap then
			local ok, mappedline = pcall(mobdebug.linemap, line, debug.getinfo(2, "S").source)

			if ok then
				line = mappedline
			end

			if not line then
				return
			end
		end

		if not step_into and not step_over and not breakpoints[line] and watchescnt <= 0 and not is_pending(server) then
			checkcount = checkcount + 1

			return
		end

		checkcount = mobdebug.checkcount
		stack_level = stack_depth(stack_level + 1)
		local caller = debug.getinfo(2, "S")
		local file = lastfile

		if lastsource ~= caller.source then
			lastsource = caller.source
			file = caller.source

			if find(file, "^@") or not find(file, "[\r\n]") then
				file = gsub(gsub(file, "^@", ""), "\\", "/")

				if find(file, "^%.%./") then
					file = basedir .. file
				end

				if find(file, "/%.%.?/") then
					file = normalize_path(file)
				end

				if iscasepreserving then
					file = string.lower(file)
				end

				if find(file, "^%./") then
					file = sub(file, 3)
				else
					file = gsub(file, "^" .. q(basedir), "")
				end

				file = gsub(file, "\n", " ")
			else
				file = mobdebug.line(file)
			end

			seen_hook = true
			lastfile = file
		end

		if is_pending(server) then
			handle_breakpoint(server)
		end

		local vars, status, res = nil

		if watchescnt > 0 then
			vars = capture_vars(1)

			for index, value in pairs(watches) do
				setfenv(value, vars)

				local ok, fired = pcall(value)

				if ok and fired then
					status, res = cororesume(coro_debugger, events.WATCH, vars, file, line, index)

					break
				end
			end
		end

		local getin = status == nil and (step_into or step_over and step_over == (coroutine.running() or "main") and stack_level <= step_level or has_breakpoint(file, line) or is_pending(server))

		if getin then
			vars = vars or capture_vars(1)
			step_into = false
			step_over = false
			status, res = cororesume(coro_debugger, events.BREAK, vars, file, line)
		end

		while status and res == "stack" do
			if vars then
				restore_vars(vars)
			end

			status, res = cororesume(coro_debugger, events.STACK, stack(3), file, line)
		end

		if status and res and res ~= "stack" then
			if not abort and res == "exit" then
				mobdebug.onexit(1, true)

				return
			end

			if not abort and res == "done" then
				mobdebug.done()

				return
			end

			abort = res

			if is_safe(stack_level) then
				error(abort)
			end
		elseif not status and res then
			error(res, 2)
		end

		if vars then
			restore_vars(vars)
		end

		if step_over == true then
			step_over = coroutine.running() or "main"
		end
	end
end

local function stringify_results(params, status, ...)
	if not status then
		return status, ...
	end

	params = params or {}

	if params.nocode == nil then
		params.nocode = true
	end

	if params.comment == nil then
		params.comment = 1
	end

	local t = {
		...
	}

	for i, v in pairs(t) do
		local ok, res = pcall(mobdebug.line, v, params)
		t[i] = ok and res or ("%q"):format(res):gsub("\n", "n"):gsub("", "\\026")
	end

	return pcall(mobdebug.dump, t, {
		sparse = false
	})
end

local function isrunning()
	return coro_debugger and (corostatus(coro_debugger) == "suspended" or corostatus(coro_debugger) == "running")
end

local function done()
	if not isrunning() or not server then
		return
	end

	if not jit then
		for co, debugged in pairs(coroutines) do
			if debugged then
				debug.sethook(co)
			end
		end
	end

	debug.sethook()
	server:close()

	coro_debugger = nil
	seen_hook = nil
	abort = nil
end

local function debugger_loop(sev, svars, sfile, sline)
	local command = nil
	local eval_env = svars or {}

	local function emptyWatch()
		return false
	end

	local loaded = {}

	for k in pairs(package.loaded) do
		loaded[k] = true
	end

	while true do
		local line, err = nil

		if mobdebug.yield and server.settimeout then
			server:settimeout(mobdebug.yieldtimeout)
		end

		while true do
			line, err = server:receive()

			if not line then
				if err == "timeout" then
					if mobdebug.yield then
						mobdebug.yield()
					end
				elseif err == "closed" then
					error("Debugger connection closed", 0)
				else
					error(("Unexpected socket error: %s"):format(err), 0)
				end
			else
				if buf then
					line = buf .. line
					buf = nil
				end

				break
			end
		end

		if server.settimeout then
			server:settimeout()
		end

		command = string.sub(line, string.find(line, "^[A-Z]+"))

		if command == "SETB" then
			local _, _, _, file, line = string.find(line, "^([A-Z]+)%s+(.-)%s+(%d+)%s*$")

			if file and line then
				set_breakpoint(file, tonumber(line))
				server:send("200 OK\n")
			else
				server:send("400 Bad Request\n")
			end
		elseif command == "DELB" then
			local _, _, _, file, line = string.find(line, "^([A-Z]+)%s+(.-)%s+(%d+)%s*$")

			if file and line then
				remove_breakpoint(file, tonumber(line))
				server:send("200 OK\n")
			else
				server:send("400 Bad Request\n")
			end
		elseif command == "EXEC" then
			local params = string.match(line, "--%s*(%b{})%s*$")
			local _, _, chunk = string.find(line, "^[A-Z]+%s+(.+)$")

			if chunk then
				local func, res = mobdebug.loadstring(chunk)
				local status = nil

				if func then
					local pfunc = params and loadstring("return " .. params)
					params = pfunc and pfunc()
					params = type(params) == "table" and params or {}
					local stack = tonumber(params.stack)
					local env = stack and coro_debugee and capture_vars(stack - 1, coro_debugee) or eval_env

					setfenv(func, env)

					status, res = stringify_results(params, pcall(func, unpack(rawget(env, "...") or {})))
				end

				if status then
					if mobdebug.onscratch then
						mobdebug.onscratch(res)
					end

					server:send("200 OK " .. tostring(#res) .. "\n")
					server:send(res)
				else
					res = res or "Unknown error"

					server:send("401 Error in Expression " .. tostring(#res) .. "\n")
					server:send(res)
				end
			else
				server:send("400 Bad Request\n")
			end
		elseif command == "LOAD" then
			local _, _, size, name = string.find(line, "^[A-Z]+%s+(%d+)%s+(%S.-)%s*$")
			size = tonumber(size)

			if abort == nil then
				if size > 0 then
					server:receive(size)
				end

				if sfile and sline then
					server:send("201 Started " .. sfile .. " " .. tostring(sline) .. "\n")
				else
					server:send("200 OK 0\n")
				end
			else
				for k in pairs(package.loaded) do
					if not loaded[k] then
						package.loaded[k] = nil
					end
				end

				if size == 0 and name == "-" then
					server:send("200 OK 0\n")
					coroyield("load")
				else
					local chunk = size == 0 and "" or server:receive(size)

					if chunk then
						local func, res = mobdebug.loadstring(chunk, "@" .. name)

						if func then
							server:send("200 OK 0\n")

							debugee = func

							coroyield("load")
						else
							server:send("401 Error in Expression " .. tostring(#res) .. "\n")
							server:send(res)
						end
					else
						server:send("400 Bad Request\n")
					end
				end
			end
		elseif command == "SETW" then
			local _, _, exp = string.find(line, "^[A-Z]+%s+(.+)%s*$")

			if exp then
				local func, res = mobdebug.loadstring("return(" .. exp .. ")")

				if func then
					watchescnt = watchescnt + 1
					local newidx = #watches + 1
					watches[newidx] = func

					server:send("200 OK " .. tostring(newidx) .. "\n")
				else
					server:send("401 Error in Expression " .. tostring(#res) .. "\n")
					server:send(res)
				end
			else
				server:send("400 Bad Request\n")
			end
		elseif command == "DELW" then
			local _, _, index = string.find(line, "^[A-Z]+%s+(%d+)%s*$")
			index = tonumber(index)

			if index > 0 and index <= #watches then
				watchescnt = watchescnt - (watches[index] ~= emptyWatch and 1 or 0)
				watches[index] = emptyWatch

				server:send("200 OK\n")
			else
				server:send("400 Bad Request\n")
			end
		elseif command == "RUN" then
			server:send("200 OK\n")

			local ev, vars, file, line, idx_watch = coroyield()
			eval_env = vars

			if ev == events.BREAK then
				server:send("202 Paused " .. file .. " " .. tostring(line) .. "\n")
			elseif ev == events.WATCH then
				server:send("203 Paused " .. file .. " " .. tostring(line) .. " " .. tostring(idx_watch) .. "\n")
			elseif ev ~= events.RESTART then
				server:send("401 Error in Execution " .. tostring(#file) .. "\n")
				server:send(file)
			end
		elseif command == "STEP" then
			server:send("200 OK\n")

			step_into = true
			local ev, vars, file, line, idx_watch = coroyield()
			eval_env = vars

			if ev == events.BREAK then
				server:send("202 Paused " .. file .. " " .. tostring(line) .. "\n")
			elseif ev == events.WATCH then
				server:send("203 Paused " .. file .. " " .. tostring(line) .. " " .. tostring(idx_watch) .. "\n")
			elseif ev ~= events.RESTART then
				server:send("401 Error in Execution " .. tostring(#file) .. "\n")
				server:send(file)
			end
		elseif command == "OVER" or command == "OUT" then
			server:send("200 OK\n")

			step_over = true

			if command == "OUT" then
				step_level = stack_level - 1
			else
				step_level = stack_level
			end

			local ev, vars, file, line, idx_watch = coroyield()
			eval_env = vars

			if ev == events.BREAK then
				server:send("202 Paused " .. file .. " " .. tostring(line) .. "\n")
			elseif ev == events.WATCH then
				server:send("203 Paused " .. file .. " " .. tostring(line) .. " " .. tostring(idx_watch) .. "\n")
			elseif ev ~= events.RESTART then
				server:send("401 Error in Execution " .. tostring(#file) .. "\n")
				server:send(file)
			end
		elseif command == "BASEDIR" then
			local _, _, dir = string.find(line, "^[A-Z]+%s+(.+)%s*$")

			if dir then
				basedir = iscasepreserving and string.lower(dir) or dir
				lastsource = nil

				server:send("200 OK\n")
			else
				server:send("400 Bad Request\n")
			end
		elseif command == "SUSPEND" then
			-- Nothing
		elseif command == "DONE" then
			coroyield("done")

			return
		elseif command == "STACK" then
			local vars = {}
			local ev = nil

			if seen_hook then
				ev, vars = coroyield("stack")
			end

			if ev and ev ~= events.STACK then
				server:send("401 Error in Execution " .. tostring(#vars) .. "\n")
				server:send(vars)
			else
				local params = string.match(line, "--%s*(%b{})%s*$")
				local pfunc = params and loadstring("return " .. params)
				params = pfunc and pfunc()
				params = type(params) == "table" and params or {}

				if params.nocode == nil then
					params.nocode = true
				end

				if params.sparse == nil then
					params.sparse = false
				end

				if tonumber(params.maxlevel) then
					params.maxlevel = tonumber(params.maxlevel) + 4
				end

				local ok, res = pcall(mobdebug.dump, vars, params)

				if ok then
					server:send("200 OK " .. tostring(res) .. "\n")
				else
					server:send("401 Error in Execution " .. tostring(#res) .. "\n")
					server:send(res)
				end
			end
		elseif command == "OUTPUT" then
			local _, _, stream, mode = string.find(line, "^[A-Z]+%s+(%w+)%s+([dcr])%s*$")

			if stream and mode and stream == "stdout" then
				local default = mode == "d"
				genv.print = default and iobase.print or corowrap(function ()
					while true do
						local tbl = {
							coroutine.yield()
						}

						if mode == "c" then
							iobase.print(unpack(tbl))
						end

						for n = 1, #tbl do
							tbl[n] = select(2, pcall(mobdebug.line, tbl[n], {
								comment = false,
								nocode = true
							}))
						end

						local file = table.concat(tbl, "\t") .. "\n"

						server:send("204 Output " .. stream .. " " .. tostring(#file) .. "\n" .. file)
					end
				end)

				if not default then
					genv.print()
				end

				server:send("200 OK\n")
			else
				server:send("400 Bad Request\n")
			end
		elseif command == "EXIT" then
			server:send("200 OK\n")
			coroyield("exit")
		else
			server:send("400 Bad Request\n")
		end
	end
end

local function output(stream, data)
	if server then
		return server:send("204 Output " .. stream .. " " .. tostring(#data) .. "\n" .. data)
	end
end

local function connect(controller_host, controller_port)
	local sock, err = socket.tcp()

	if not sock then
		return nil, err
	end

	if sock.settimeout then
		sock:settimeout(mobdebug.connecttimeout)
	end

	local res, err = sock:connect(controller_host, tostring(controller_port))

	if sock.settimeout then
		sock:settimeout()
	end

	if not res then
		return nil, err
	end

	return sock
end

local lasthost, lastport = nil

local function start(controller_host, controller_port)
	if isrunning() then
		return
	end

	lasthost = controller_host or lasthost
	lastport = controller_port or lastport
	controller_host = lasthost or "localhost"
	controller_port = lastport or mobdebug.port
	local err = nil
	server, err = mobdebug.connect(controller_host, controller_port)

	if server then
		stack_level = stack_depth(16)

		local function f()
			return function ()
			end
		end

		if f() ~= f() then
			local dtraceback = debug.traceback

			function debug.traceback(...)
				if select("#", ...) >= 1 then
					local thr, err, lvl = ...

					if type(thr) ~= "thread" then
						lvl = err
						err = thr
					end

					local trace = dtraceback(err, (lvl or 1) + 1)

					if genv.print == iobase.print then
						return trace
					else
						genv.print(trace)

						return
					end
				end

				local tb = dtraceback("", 2)

				return type(tb) == "string" and tb:gsub("^\n", "") or tb
			end
		end

		coro_debugger = corocreate(debugger_loop)

		debug.sethook(debug_hook, HOOKMASK)

		seen_hook = nil
		step_into = true

		return true
	else
		print(("Could not connect to %s:%s: %s"):format(controller_host, controller_port, err or "unknown error"))
	end
end

local function controller(controller_host, controller_port, scratchpad)
	if isrunning() then
		return
	end

	lasthost = controller_host or lasthost
	lastport = controller_port or lastport
	controller_host = lasthost or "localhost"
	controller_port = lastport or mobdebug.port
	local exitonerror = not scratchpad
	local err = nil
	server, err = mobdebug.connect(controller_host, controller_port)

	if server then
		local function report(trace, err)
			local msg = err .. "\n" .. trace

			server:send("401 Error in Execution " .. tostring(#msg) .. "\n")
			server:send(msg)

			return err
		end

		seen_hook = true
		coro_debugger = corocreate(debugger_loop)

		while true do
			step_into = true
			abort = false

			if scratchpad then
				checkcount = mobdebug.checkcount
			end

			coro_debugee = corocreate(debugee)

			debug.sethook(coro_debugee, debug_hook, HOOKMASK)

			local status, err = cororesume(coro_debugee, unpack(arg or {}))

			if abort then
				if tostring(abort) == "exit" then
					break
				end
			elseif status then
				if corostatus(coro_debugee) == "suspended" then
					error("attempt to yield from the main thread", 3)
				end

				break
			elseif err and not string.find(tostring(err), deferror) then
				report(debug.traceback(coro_debugee), tostring(err))

				if exitonerror then
					break
				end

				if not coro_debugger then
					break
				end

				local status, err = cororesume(coro_debugger, events.RESTART, capture_vars(0))

				if not status or status and err == "exit" then
					break
				end
			end
		end
	else
		print(("Could not connect to %s:%s: %s"):format(controller_host, controller_port, err or "unknown error"))

		return false
	end

	return true
end

local function scratchpad(controller_host, controller_port)
	return controller(controller_host, controller_port, true)
end

local function loop(controller_host, controller_port)
	return controller(controller_host, controller_port, false)
end

local function on()
	if not isrunning() or not server then
		return
	end

	local co, main = coroutine.running()

	if main then
		co = nil
	end

	if co then
		coroutines[co] = true

		debug.sethook(co, debug_hook, HOOKMASK)
	else
		if jit then
			coroutines.main = true
		end

		debug.sethook(debug_hook, HOOKMASK)
	end
end

local function off()
	if not isrunning() or not server then
		return
	end

	local co, main = coroutine.running()

	if main then
		co = nil
	end

	if co then
		coroutines[co] = false

		if not jit then
			debug.sethook(co)
		end
	else
		if jit then
			coroutines.main = false
		end

		if not jit then
			debug.sethook()
		end
	end

	if jit then
		local remove = true

		for _, debugged in pairs(coroutines) do
			if debugged then
				remove = false

				break
			end
		end

		if remove then
			debug.sethook()
		end
	end
end

local function handle(params, client, options)
	local verbose = not options or options.verbose ~= nil and options.verbose
	local print = verbose and (type(verbose) == "function" and verbose or print) or function ()
	end
	local file, line, watch_idx = nil
	local _, _, command = string.find(params, "^([a-z]+)")

	if command == "run" or command == "step" or command == "out" or command == "over" or command == "exit" then
		client:send(string.upper(command) .. "\n")
		client:receive()

		while true do
			local done = true
			local breakpoint = client:receive()

			if not breakpoint then
				print("Program finished")

				return nil, nil, false
			end

			local _, _, status = string.find(breakpoint, "^(%d+)")

			if status == "200" then
				-- Nothing
			elseif status == "202" then
				_, _, file, line = string.find(breakpoint, "^202 Paused%s+(.-)%s+(%d+)%s*$")

				if file and line then
					print("Paused at file " .. file .. " line " .. line)
				end
			elseif status == "203" then
				_, _, file, line, watch_idx = string.find(breakpoint, "^203 Paused%s+(.-)%s+(%d+)%s+(%d+)%s*$")

				if file and line and watch_idx then
					print("Paused at file " .. file .. " line " .. line .. " (watch expression " .. watch_idx .. ": [" .. watches[watch_idx] .. "])")
				end
			elseif status == "204" then
				local _, _, stream, size = string.find(breakpoint, "^204 Output (%w+) (%d+)$")

				if stream and size then
					local size = tonumber(size)
					local msg = size > 0 and client:receive(size) or ""

					print(msg)

					if outputs[stream] then
						outputs[stream](msg)
					end

					done = false
				end
			elseif status == "401" then
				local _, _, size = string.find(breakpoint, "^401 Error in Execution (%d+)$")

				if size then
					local msg = client:receive(tonumber(size))

					print("Error in remote application: " .. msg)

					return nil, nil, msg
				end
			else
				print("Unknown error")

				return nil, nil, "Debugger error: unexpected response '" .. breakpoint .. "'"
			end

			if done then
				break
			end
		end
	elseif command == "done" then
		client:send(string.upper(command) .. "\n")
	elseif command == "setb" or command == "asetb" then
		_, _, _, file, line = string.find(params, "^([a-z]+)%s+(.-)%s+(%d+)%s*$")

		if file and line then
			if not file:find("^\".*\"$") then
				file = string.gsub(file, "\\", "/")
				file = removebasedir(file, basedir)
			end

			client:send("SETB " .. file .. " " .. line .. "\n")

			if command == "asetb" or client:receive() == "200 OK" then
				set_breakpoint(file, line)
			else
				print("Error: breakpoint not inserted")
			end
		else
			print("Invalid command")
		end
	elseif command == "setw" then
		local _, _, exp = string.find(params, "^[a-z]+%s+(.+)$")

		if exp then
			client:send("SETW " .. exp .. "\n")

			local answer = client:receive()
			local _, _, watch_idx = string.find(answer, "^200 OK (%d+)%s*$")

			if watch_idx then
				watches[watch_idx] = exp

				print("Inserted watch exp no. " .. watch_idx)
			else
				local _, _, size = string.find(answer, "^401 Error in Expression (%d+)$")

				if size then
					local err = client:receive(tonumber(size)):gsub(".-:%d+:%s*", "")

					print("Error: watch expression not set: " .. err)
				else
					print("Error: watch expression not set")
				end
			end
		else
			print("Invalid command")
		end
	elseif command == "delb" or command == "adelb" then
		_, _, _, file, line = string.find(params, "^([a-z]+)%s+(.-)%s+(%d+)%s*$")

		if file and line then
			if not file:find("^\".*\"$") then
				file = string.gsub(file, "\\", "/")
				file = removebasedir(file, basedir)
			end

			client:send("DELB " .. file .. " " .. line .. "\n")

			if command == "adelb" or client:receive() == "200 OK" then
				remove_breakpoint(file, line)
			else
				print("Error: breakpoint not removed")
			end
		else
			print("Invalid command")
		end
	elseif command == "delallb" then
		local file = "*"
		local line = 0

		client:send("DELB " .. file .. " " .. tostring(line) .. "\n")

		if client:receive() == "200 OK" then
			remove_breakpoint(file, line)
		else
			print("Error: all breakpoints not removed")
		end
	elseif command == "delw" then
		local _, _, index = string.find(params, "^[a-z]+%s+(%d+)%s*$")

		if index then
			client:send("DELW " .. index .. "\n")

			if client:receive() == "200 OK" then
				watches[index] = nil
			else
				print("Error: watch expression not removed")
			end
		else
			print("Invalid command")
		end
	elseif command == "delallw" then
		for index, exp in pairs(watches) do
			client:send("DELW " .. index .. "\n")

			if client:receive() == "200 OK" then
				watches[index] = nil
			else
				print("Error: watch expression at index " .. index .. " [" .. exp .. "] not removed")
			end
		end
	elseif command == "eval" or command == "exec" or command == "load" or command == "loadstring" or command == "reload" then
		local _, _, exp = string.find(params, "^[a-z]+%s+(.+)$")

		if exp or command == "reload" then
			if command == "eval" or command == "exec" then
				exp = exp:gsub("%-%-%[(=*)%[.-%]%1%]", ""):gsub("%-%-.-\n", " "):gsub("\n", " ")

				if command == "eval" then
					exp = "return " .. exp
				end

				client:send("EXEC " .. exp .. "\n")
			elseif command == "reload" then
				client:send("LOAD 0 -\n")
			elseif command == "loadstring" then
				local _, _, _, file, lines = string.find(exp, "^([\"'])(.-)%1%s(.+)")

				if not file then
					_, _, file, lines = string.find(exp, "^(%S+)%s(.+)")
				end

				client:send("LOAD " .. tostring(#lines) .. " " .. file .. "\n")
				client:send(lines)
			else
				local file = io.open(exp, "r")

				if not file and pcall(require, "winapi") then
					winapi.set_encoding(winapi.CP_UTF8)

					local shortp = winapi.short_path(exp)
					file = shortp and io.open(shortp, "r")
				end

				if not file then
					return nil, nil, "Cannot open file " .. exp
				end

				local lines = file:read("*all"):gsub("^#!.-\n", "\n")

				file:close()

				local fname = string.gsub(exp, "\\", "/")
				fname = removebasedir(fname, basedir)

				client:send("LOAD " .. tostring(#lines) .. " " .. fname .. "\n")

				if #lines > 0 then
					client:send(lines)
				end
			end

			while true do
				local params, err = client:receive()

				if not params then
					return nil, nil, "Debugger connection " .. (err or "error")
				end

				local done = true
				local _, _, status, len = string.find(params, "^(%d+).-%s+(%d+)%s*$")

				if status == "200" then
					len = tonumber(len)

					if len > 0 then
						local status, res = nil
						local str = client:receive(len)
						local func, err = loadstring(str)

						if func then
							status, res = pcall(func)

							if not status then
								err = res
							elseif type(res) ~= "table" then
								err = "received " .. type(res) .. " instead of expected 'table'"
							end
						end

						if err then
							print("Error in processing results: " .. err)

							return nil, nil, "Error in processing results: " .. err
						end

						print(unpack(res))

						return res[1], res
					end
				elseif status == "201" then
					_, _, file, line = string.find(params, "^201 Started%s+(.-)%s+(%d+)%s*$")
				elseif status ~= "202" then
					if params == "200 OK" then
						-- Nothing
					elseif status == "204" then
						local _, _, stream, size = string.find(params, "^204 Output (%w+) (%d+)$")

						if stream and size then
							local size = tonumber(size)
							local msg = size > 0 and client:receive(size) or ""

							print(msg)

							if outputs[stream] then
								outputs[stream](msg)
							end

							done = false
						end
					elseif status == "401" then
						len = tonumber(len)
						local res = client:receive(len)

						print("Error in expression: " .. res)

						return nil, nil, res
					else
						print("Unknown error")

						return nil, nil, "Debugger error: unexpected response after EXEC/LOAD '" .. params .. "'"
					end
				end

				if done then
					break
				end
			end
		else
			print("Invalid command")
		end
	elseif command == "listb" then
		for l, v in pairs(breakpoints) do
			for f in pairs(v) do
				print(f .. ": " .. l)
			end
		end
	elseif command == "listw" then
		for i, v in pairs(watches) do
			print("Watch exp. " .. i .. ": " .. v)
		end
	elseif command == "suspend" then
		client:send("SUSPEND\n")
	elseif command == "stack" then
		local opts = string.match(params, "^[a-z]+%s+(.+)$")

		client:send("STACK" .. (opts and " " .. opts or "") .. "\n")

		local resp = client:receive()
		local _, _, status, res = string.find(resp, "^(%d+)%s+%w+%s+(.+)%s*$")

		if status == "200" then
			local func, err = loadstring(res)

			if func == nil then
				print("Error in stack information: " .. err)

				return nil, nil, err
			end

			local ok, stack = pcall(func)

			if not ok then
				print("Error in stack information: " .. stack)

				return nil, nil, stack
			end

			for _, frame in ipairs(stack) do
				print(mobdebug.line(frame[1], {
					comment = false
				}))
			end

			return stack
		elseif status == "401" then
			local _, _, len = string.find(resp, "%s+(%d+)%s*$")
			len = tonumber(len)
			local res = len > 0 and client:receive(len) or "Invalid stack information."

			print("Error in expression: " .. res)

			return nil, nil, res
		else
			print("Unknown error")

			return nil, nil, "Debugger error: unexpected response after STACK"
		end
	elseif command == "output" then
		local _, _, stream, mode = string.find(params, "^[a-z]+%s+(%w+)%s+([dcr])%s*$")

		if stream and mode then
			client:send("OUTPUT " .. stream .. " " .. mode .. "\n")

			local resp, err = client:receive()

			if not resp then
				print("Unknown error: " .. err)

				return nil, nil, "Debugger connection error: " .. err
			end

			local _, _, status = string.find(resp, "^(%d+)%s+%w+%s*$")

			if status == "200" then
				print("Stream " .. stream .. " redirected")

				outputs[stream] = type(options) == "table" and options.handler or nil
			elseif type(options) == "table" and options.handler then
				outputs[stream] = options.handler
			else
				print("Unknown error")

				return nil, nil, "Debugger error: can't redirect " .. stream
			end
		else
			print("Invalid command")
		end
	elseif command == "basedir" then
		local _, _, dir = string.find(params, "^[a-z]+%s+(.+)$")

		if dir then
			dir = string.gsub(dir, "\\", "/")

			if not string.find(dir, "/$") then
				dir = dir .. "/"
			end

			local remdir = dir:match("\t(.+)")

			if remdir then
				dir = dir:gsub("/?\t.+", "/")
			end

			basedir = dir

			client:send("BASEDIR " .. (remdir or dir) .. "\n")

			local resp, err = client:receive()

			if not resp then
				print("Unknown error: " .. err)

				return nil, nil, "Debugger connection error: " .. err
			end

			local _, _, status = string.find(resp, "^(%d+)%s+%w+%s*$")

			if status == "200" then
				print("New base directory is " .. basedir)
			else
				print("Unknown error")

				return nil, nil, "Debugger error: unexpected response after BASEDIR"
			end
		else
			print(basedir)
		end
	elseif command == "help" then
		print("setb <file> <line>    -- sets a breakpoint")
		print("delb <file> <line>    -- removes a breakpoint")
		print("delallb               -- removes all breakpoints")
		print("setw <exp>            -- adds a new watch expression")
		print("delw <index>          -- removes the watch expression at index")
		print("delallw               -- removes all watch expressions")
		print("run                   -- runs until next breakpoint")
		print("step                  -- runs until next line, stepping into function calls")
		print("over                  -- runs until next line, stepping over function calls")
		print("out                   -- runs until line after returning from current function")
		print("listb                 -- lists breakpoints")
		print("listw                 -- lists watch expressions")
		print("eval <exp>            -- evaluates expression on the current context and returns its value")
		print("exec <stmt>           -- executes statement on the current context")
		print("load <file>           -- loads a local file for debugging")
		print("reload                -- restarts the current debugging session")
		print("stack                 -- reports stack trace")
		print("output stdout <d|c|r> -- capture and redirect io stream (default|copy|redirect)")
		print("basedir [<path>]      -- sets the base path of the remote application, or shows the current one")
		print("done                  -- stops the debugger and continues application execution")
		print("exit                  -- exits debugger and the application")
	else
		local _, _, spaces = string.find(params, "^(%s*)$")

		if spaces then
			return nil, nil, "Empty command"
		else
			print("Invalid command")

			return nil, nil, "Invalid command"
		end
	end

	return file, line
end

local function listen(host, port)
	host = host or "*"
	port = port or mobdebug.port
	local socket = require("lib/utils/socket")

	print("Lua Remote Debugger")
	print("Run the program you wish to debug")

	local server = socket.bind(host, port)
	local client = server:accept()

	client:send("STEP\n")
	client:receive()

	local breakpoint = client:receive()
	local _, _, file, line = string.find(breakpoint, "^202 Paused%s+(.-)%s+(%d+)%s*$")

	if file and line then
		print("Paused at file " .. file)
		print("Type 'help' for commands")
	else
		local _, _, size = string.find(breakpoint, "^401 Error in Execution (%d+)%s*$")

		if size then
			print("Error in remote application: ")
			print(client:receive(size))
		end
	end

	while true do
		io.write("> ")

		local file, _, err = handle(io.read("*line"), client)

		if not file and err == false then
			break
		end
	end

	client:close()
end

local cocreate = nil

local function coro()
	if cocreate then
		return
	end

	cocreate = cocreate or coroutine.create

	function coroutine.create(f, ...)
		return cocreate(function (...)
			mobdebug.on()

			return f(...)
		end, ...)
	end
end

local moconew = nil

local function moai()
	if moconew then
		return
	end

	moconew = moconew or MOAICoroutine and MOAICoroutine.new

	if not moconew then
		return
	end

	function MOAICoroutine.new(...)
		local thread = moconew(...)
		local mt = thread.run and thread or getmetatable(thread)
		local patched = mt.run

		function mt:run(f, ...)
			return patched(self, function (...)
				mobdebug.on()

				return f(...)
			end, ...)
		end

		return thread
	end
end

mobdebug.setbreakpoint = set_breakpoint
mobdebug.removebreakpoint = remove_breakpoint
mobdebug.listen = listen
mobdebug.loop = loop
mobdebug.scratchpad = scratchpad
mobdebug.handle = handle
mobdebug.connect = connect
mobdebug.start = start
mobdebug.on = on
mobdebug.off = off
mobdebug.moai = moai
mobdebug.coro = coro
mobdebug.done = done

function mobdebug.pause()
	step_into = true
end

mobdebug.yield = nil
mobdebug.output = output
mobdebug.onexit = os and os.exit or done
mobdebug.onscratch = nil

function mobdebug.basedir(b)
	if b then
		basedir = b
	end

	return basedir
end

return mobdebug
