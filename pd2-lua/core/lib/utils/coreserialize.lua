core:module("CoreSerialize")

function string_to_classtable(s)
	local module_name, name = nil

	if string.find(s, "[.]") then
		module_name, name = unpack(string.split(s, "[.]"))
	else
		name = s
		module_name = "_G"
	end

	if module_name == "_G" then
		local obj = rawget(_G, name)

		assert(obj, "Can't find '" .. name .. "' in _G")

		return obj
	else
		local module = core:_name_to_module(module_name)
		local obj = module[name]

		assert(obj, "Can't get name '" .. name .. "' from module '" .. module_name .. "'")

		return obj
	end
end

function classtable_to_string(ct)
	local module_name = core:_module_to_name(ct.__module__)

	for name, obj in pairs(ct.__module__) do
		if obj == ct then
			return module_name .. "." .. name
		end
	end

	error("Can't find classtable in module '" .. module_name .. "'")
end
