core:module("CoreInputLayerDescription")

LayerDescription = LayerDescription or class()

function LayerDescription:init(name, priority)
	self._name = name
	self._priority = priority
end

function LayerDescription:layer_description_name()
	return self._name
end

function LayerDescription:set_context_description(context_description)
	assert(self._context_description == nil)

	self._context_description = context_description
end

function LayerDescription:context_description()
	assert(self._context_description, "Must specify context for this layer_description")

	return self._context_description
end

function LayerDescription:priority()
	return self._priority
end
