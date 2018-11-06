GageModifierDamageAbsorption = GageModifierDamageAbsorption or class(GageModifier)
GageModifierDamageAbsorption._type = "GageModifierDamageAbsorption"
GageModifierDamageAbsorption.default_value = "absorption"

function GageModifierDamageAbsorption:modify_value(id, value)
	if id == "PlayerManager:GetDamageAbsorption" then
		return value + self:value()
	end

	return value
end
