WeightedSelector = WeightedSelector or class()

function WeightedSelector:init()
	self:clear()
end

function WeightedSelector:add(value, weight)
	table.insert(self._values, {
		value = value,
		weight = weight
	})

	self._total_weight = self._total_weight + weight
end

function WeightedSelector:select()
	local rand = math.random() * self._total_weight

	for idx, item in ipairs(self._values) do
		if rand < item.weight then
			return item.value
		end

		rand = rand - item.weight
	end

	return nil
end

function WeightedSelector:clear()
	self._values = {}
	self._total_weight = 0
end
