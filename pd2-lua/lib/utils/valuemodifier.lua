ValueModifier = ValueModifier or class()

function ValueModifier:init()
	self._modifiers = {}
end

function ValueModifier:add_modifier(type, callback)
	local key = {}
	local modifiers = self._modifiers[type] or {}
	self._modifiers[type] = modifiers
	modifiers[key] = callback

	return key
end

function ValueModifier:remove_modifier(type, key)
	local modifiers = self._modifiers[type] or {}

	if not modifiers then
		return
	end

	modifiers[key] = nil
end

function ValueModifier:modify_value(type, base_value, ...)
	local modifiers = self._modifiers[type]
	local new_value = base_value

	if modifiers then
		for _, callback in pairs(modifiers) do
			new_value = new_value + (callback(base_value, ...) or 0)
		end
	end

	return new_value
end
