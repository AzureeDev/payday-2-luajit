GageModifierMaxStamina = GageModifierMaxStamina or class(GageModifier)
GageModifierMaxStamina._type = "GageModifierMaxStamina"
GageModifierMaxStamina.default_value = "stamina"

function GageModifierMaxStamina:get_stamina_multiplier()
	return 1 + self:value() / 100
end

function GageModifierMaxStamina:modify_value(id, value)
	if id == "PlayerManager:GetStaminaMultiplier" then
		return value * self:get_stamina_multiplier()
	end

	return value
end
