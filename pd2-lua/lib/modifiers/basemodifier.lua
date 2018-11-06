BaseModifier = BaseModifier or class()
BaseModifier._type = "BaseModifier"
BaseModifier.name_id = "none"
BaseModifier.desc_id = "none"
BaseModifier.default_value = nil
BaseModifier.total_localization = nil

function BaseModifier:init(data)
	self._data = data
end

function BaseModifier:destroy()
end

function BaseModifier:value(id)
	id = id or self.default_value

	return self._data[id]
end
