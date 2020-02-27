core:module("CoreMenuItemOption")

ItemOption = ItemOption or class()

function ItemOption:init(data_node, parameters)
	local params = parameters or {}

	if data_node then
		for key, value in pairs(data_node) do
			if key ~= "_meta" and type(value) ~= "table" then
				params[key] = value
			end
		end
	end

	self:set_parameters(params)
end

function ItemOption:value()
	return self._parameters.value
end

function ItemOption:get_parameter(name)
	return self._parameters[name]
end

function ItemOption:parameters()
	return self._parameters
end

function ItemOption:set_parameters(parameters)
	self._parameters = parameters
end
