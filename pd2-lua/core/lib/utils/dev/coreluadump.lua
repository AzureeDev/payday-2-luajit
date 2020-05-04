core:module("CoreLuaDump")

local function string_to_binary(str)
	local out_str = nil

	for i = 1, string.len(str) do
		out_str = out_str and out_str .. " "
		out_str = (out_str or "") .. string.byte(str, i)
	end

	return out_str or ""
end

local function dump_collect(tab, t, level, max_level)
	if level < max_level then
		for k, v in pairs(tab) do
			local k_str = nil
			local v_type = type(v)

			if type(k) == "userdata" then
				local meta = getmetatable(k)

				if meta and meta.tostring then
					k_str = meta.tostring(k)
				else
					k_str = "(" .. tostring({}) .. ") UNKNOWN"
				end
			else
				k_str = tostring(k)
			end

			if level == 0 then
				cat_print("debug", "Dumping: " .. k_str)
			end

			if v == tab then
				t[k_str] = {
					_type = "recursive",
					_value = "(" .. tostring({}) .. ") UNKNOWN"
				}
			elseif v_type == "function" then
				local info = debug.getinfo(v, "S")

				if info.what == "Lua" then
					t[k_str] = {
						_type = v_type,
						_value = info.source .. ":" .. info.linedefined
					}
				end
			elseif v_type == "table" then
				t[k_str] = {
					_type = v_type,
					_value = dump_collect(v, {}, level + 1, max_level)
				}
			elseif v_type == "userdata" then
				local meta = getmetatable(tab)

				if meta and meta.tostring then
					local str = meta.tostring(tab)
					t[k_str] = {
						_type = v_type,
						_value = str
					}
				else
					t[k_str] = {
						_type = v_type,
						_value = "(" .. tostring({}) .. ") UNKNOWN"
					}
				end
			else
				t[k_str] = {
					_type = v_type,
					_value = tostring(v)
				}
			end
		end
	else
		t["(" .. tostring({}) .. ") UNKNOWN"] = {
			_type = "unexplored",
			_value = "(" .. tostring({}) .. ") UNKNOWN"
		}
	end

	return t
end

local function write_to_file(file, t, level)
	for k, v in pairs(t) do
		if v._type == "table" then
			file:write(level .. "<table name=\"" .. string_to_binary(k) .. "\">\n")
			write_to_file(file, v._value, level .. "\t")
			file:write(level .. "</table>\n")
		else
			file:write(level .. "<" .. v._type .. " name=\"" .. string_to_binary(k) .. "\" value=\"" .. string_to_binary(v._value) .. "\"/>\n")
		end
	end
end

local function write_locals(file)
	local i = 1
	local value = 1

	while true do
		local name, value = debug.getlocal(3, i)

		if name and value then
			local v_str = nil

			if type(value) == "userdata" then
				local meta = getmetatable(value)

				if meta and meta.tostring then
					v_str = meta.tostring(value)
				else
					v_str = "(" .. tostring({}) .. ") UNKNOWN"
				end
			else
				v_str = tostring(value)
			end

			file:write("\t<local name=\"" .. string_to_binary(name) .. "\" value=\"" .. string_to_binary(v_str) .. "\"/>\n")

			i = i + 1
		else
			break
		end
	end
end

function core_lua_dump(file_name, root, max_level, no_bin)
	local file = File:open(file_name or "lua_dump.xml", "w")

	assert(file)

	if no_bin then
		function string_to_binary(str)
			return str
		end
	end

	cat_print("debug", "Starting LUA dump...")
	file:write("<lua_dump>\n")
	file:write("\t<traceback data=\"" .. string_to_binary(debug.traceback()) .. "\"/>\n")
	write_locals(file)
	write_to_file(file, dump_collect(root or _G, {}, 0, max_level or 10), "\t")
	file:write("</lua_dump>\n")
	file:close()
	cat_print("debug", "LUA dump done!")
end
