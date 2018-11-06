core:module("CoreInputLayerDescriptionPrioritizer")

Prioritizer = Prioritizer or class()

function Prioritizer:init()
	self._layer_descriptions = {}
end

function Prioritizer:add_layer_description(input_layer_description_description)
	self._layer_descriptions[input_layer_description_description] = input_layer_description_description

	if not self._layer_description or input_layer_description_description:priority() < self._layer_description:priority() then
		self._layer_description = input_layer_description_description
	end
end

function Prioritizer:remove_layer_description(input_layer_description_description)
	local needs_to_search = self._layer_description == input_layer_description_description

	assert(self._layer_descriptions[input_layer_description_description] ~= nil)

	self._layer_descriptions[input_layer_description_description] = nil
	local best_layer_description = nil

	for _, layer_description in pairs(self._layer_descriptions) do
		if not best_layer_description or layer_description:priority() < best_layer_description:priority() then
			best_layer_description = layer_description
		end
	end

	self._layer_description = best_layer_description
end

function Prioritizer:active_layer_description()
	return self._layer_description
end
