GageModifierMaxAmmo = GageModifierMaxAmmo or class(GageModifier)
GageModifierMaxAmmo._type = "GageModifierMaxAmmo"
GageModifierMaxAmmo.default_value = "ammo"

function GageModifierMaxAmmo:get_ammo_multiplier()
	return 1 + self:value() / 100
end

function GageModifierMaxAmmo:modify_value(id, value)
	if id == "WeaponBase:GetMaxAmmoMultiplier" then
		return value * self:get_ammo_multiplier()
	end

	return value
end
