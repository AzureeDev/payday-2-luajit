function tprint(tbl, indent)
	indent = indent or 0
	local toprint = string.rep(" ", indent) .. "{\r\n"
	indent = indent + 2

	for k, v in pairs(tbl) do
		toprint = toprint .. string.rep(" ", indent)

		if type(k) == "number" then
			toprint = toprint .. "[" .. k .. "] = "
		elseif type(k) == "string" then
			toprint = toprint .. k .. "= "
		end

		if type(v) == "number" then
			toprint = toprint .. v .. ",\r\n"
		elseif type(v) == "string" then
			toprint = toprint .. "\"" .. v .. "\",\r\n"
		elseif type(v) == "table" then
			toprint = toprint .. tprint(v, indent + 2) .. ",\r\n"
		else
			toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
		end
	end

	toprint = toprint .. string.rep(" ", indent - 2) .. "}"

	return toprint
end

return tprint
