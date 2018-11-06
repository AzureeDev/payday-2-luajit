GageModifierQuickReload = GageModifierQuickReload or class(GageModifier)
GageModifierQuickReload._type = "GageModifierQuickReload"
GageModifierQuickReload.default_value = "speed"

function GageModifierQuickReload:get_speed_multiplier()
	return 1 + self:value() / 100
end

function GageModifierQuickReload:modify_value(id, value)
	if id == "WeaponBase:GetReloadSpeedMultiplier" then
		return value * self:get_speed_multiplier()
	end

	return value
end
