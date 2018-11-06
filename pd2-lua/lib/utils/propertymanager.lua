PropertyManager = PropertyManager or class()

function PropertyManager:init()
	self._properties = {}
end

function PropertyManager:add_to_property(prop, value)
	if not self._properties[prop] then
		self._properties[prop] = value
	else
		self._properties[prop] = self._properties[prop] + value
	end
end

function PropertyManager:mul_to_property(prop, value)
	if not self._properties[prop] then
		self._properties[prop] = value
	else
		self._properties[prop] = self._properties[prop] * value
	end
end

function PropertyManager:set_property(prop, value)
	self._properties[prop] = value
end

function PropertyManager:get_property(prop, default)
	if self._properties[prop] then
		return self._properties[prop]
	end

	return default
end

function PropertyManager:has_property(prop)
	if self._properties[prop] then
		return true
	end

	return false
end

function PropertyManager:remove_property(prop)
	if self._properties[prop] then
		self._properties[prop] = nil
	end
end
