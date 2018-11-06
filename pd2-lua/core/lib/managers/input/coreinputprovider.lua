core:module("CoreInputProvider")
core:import("CoreInputLayerDescriptionPrioritizer")
core:import("CoreInputLayer")

Provider = Provider or class()

function Provider:init(input_layer_descriptions)
	self._layer_description_to_layer = {}
	self._input_layer_descriptions = input_layer_descriptions
	self._prioritizer = CoreInputLayerDescriptionPrioritizer.Prioritizer:new()
end

function Provider:destroy()
end

function Provider:context()
	local layer_description = self._prioritizer:active_layer_description()

	if not layer_description then
		return
	end

	local layer = self._layer_description_to_layer[layer_description]

	return layer:context()
end

function Provider:create_layer(layer_description_name)
	local layer_description = self._input_layer_descriptions[layer_description_name]

	assert(layer_description, "Illegal layer description '" .. layer_description_name .. "'")

	local layer = CoreInputLayer.Layer:new(self, layer_description)
	self._layer_description_to_layer[layer_description] = layer

	self._prioritizer:add_layer_description(layer_description)

	return layer
end

function Provider:_layer_destroyed(layer)
	local layer_description = layer:layer_description()

	self._prioritizer:remove_layer_description(layer_description)
end
