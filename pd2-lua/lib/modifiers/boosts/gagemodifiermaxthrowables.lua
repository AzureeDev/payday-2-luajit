GageModifierMaxThrowables = GageModifierMaxThrowables or class(GageModifier)
GageModifierMaxThrowables._type = "GageModifierMaxThrowables"
GageModifierMaxThrowables.default_value = "throwables"

function GageModifierMaxThrowables:get_amount_multiplier()
	return 1 + self:value() / 100
end

function GageModifierMaxThrowables:modify_value(id, value)
	if id == "PlayerManager:GetThrowablesMaxAmount" then
		local new_val = math.floor(value * self:get_amount_multiplier())
		new_val = math.max(new_val, value + 1)

		return new_val
	end

	return value
end
