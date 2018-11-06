GageModifierMaxArmor = GageModifierMaxArmor or class(GageModifier)
GageModifierMaxArmor._type = "GageModifierMaxArmor"
GageModifierMaxArmor.default_value = "armor"

function GageModifierMaxArmor:init(data)
	GageModifierMaxArmor.super.init(self, data)

	if managers.player and alive(managers.player:local_player()) then
		managers.player:local_player():character_damage():_regenerate_armor(true)
	end
end

function GageModifierMaxArmor:get_armor_multiplier()
	return 1 + self:value() / 100
end

function GageModifierMaxArmor:modify_value(id, value)
	if id == "PlayerDamage:GetMaxArmor" then
		return value * self:get_armor_multiplier()
	end

	return value
end
