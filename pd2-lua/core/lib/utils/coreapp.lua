core:module("CoreApp")

function arg_supplied(key)
	for _, arg in ipairs(Application:argv()) do
		if arg == key then
			return true
		end
	end

	return false
end

function arg_value(key)
	local found = nil

	for _, arg in ipairs(Application:argv()) do
		if found then
			return arg
		elseif arg == key then
			found = true
		end
	end
end

function min_exe_version(version, system_name)
end
