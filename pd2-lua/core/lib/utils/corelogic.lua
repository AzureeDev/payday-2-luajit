core:module("CoreLogic")

function toboolean(value)
	if type(value) == "string" then
		return value == "true"
	elseif type(value) == "number" then
		return value == 1
	end
end

function iff(t, a, b)
	if t then
		return a
	else
		return b
	end
end
