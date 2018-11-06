core:module("CoreXml")
core:import("CoreClass")
core:import("CoreMath")

function simple_value_string(name, value, t)
	t = t or ""
	local string = t
	local type = CoreClass.type_name(value)
	local v = tostring(value)

	if type == "Vector3" then
		v = CoreMath.vector_to_string(value, "%.4f")
	elseif type == "Rotation" then
		v = CoreMath.rotation_to_string(value, "%.4f")
	elseif type == "table" then
		string = string .. "<value name=\"" .. name .. "\" type=\"" .. type .. "\">\n"
		string = string .. save_table_value_string(value, "", t)
		string = string .. t .. "</value>"

		return string
	end

	string = string .. "<value name=\"" .. name .. "\" value=\"" .. v .. "\" type=\"" .. type .. "\"/>"

	return string
end

function save_value_string(c, name, t, unit)
	t = t or ""
	local string = t

	if name == "unit:position" then
		name = "position"
		c[name] = unit:position()
	end

	if name == "unit:rotation" then
		name = "rotation"
		c[name] = unit:rotation()
	end

	local type = CoreClass.type_name(c[name])
	local v = tostring(c[name])

	if type == "Vector3" then
		v = CoreMath.vector_to_string(c[name], "%.4f")
	elseif type == "Rotation" then
		v = CoreMath.rotation_to_string(c[name], "%.4f")
	elseif type == "table" then
		string = string .. "<value name=\"" .. name .. "\" type=\"" .. type .. "\">\n"
		string = string .. save_table_value_string(c[name], "", t)
		string = string .. t .. "</value>"

		return string
	end

	string = string .. "<value name=\"" .. name .. "\" value=\"" .. v .. "\" type=\"" .. type .. "\"/>"

	return string
end

function save_table_value_string(in_table, string, t)
	t = t .. "\t"

	for i, value in pairs(in_table) do
		local type = CoreClass.type_name(value)
		local v = tostring(value)

		if type == "table" then
			string = string .. t .. "<value name=\"" .. i .. "\" type=\"" .. type .. "\">\n"
			string = string .. save_table_value_string(value, "", t)
			string = string .. t .. "</value>\n"
		else
			if type == "Vector3" then
				v = CoreMath.vector_to_string(value, "%.4f")
			elseif type == "Rotation" then
				v = CoreMath.rotation_to_string(value, "%.4f")
			end

			string = string .. t .. "<value name=\"" .. i .. "\" value=\"" .. v .. "\" type=\"" .. type .. "\"/>\n"
		end
	end

	return string
end

function parse_values_node(node)
	local t = {}

	for node_value in node:children() do
		local name, value = parse_value_node(node_value)
		t[name] = value
	end

	return t
end

function parse_value_node(node)
	local value_name = node:parameter("name")
	local type = node:parameter("type")

	if type == "table" then
		local t = {}

		for table_node in node:children() do
			local name = table_node:parameter("name")
			name = tonumber(name) or name
			local _, value = parse_value_node(table_node)
			t[name] = value
		end

		return value_name, t
	end

	local val = node:parameter("value")

	return value_name, CoreMath.string_to_value(type, val)
end
