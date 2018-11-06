ModifierTaserOvercharge = ModifierTaserOvercharge or class(BaseModifier)
ModifierTaserOvercharge._type = "ModifierTaserOvercharge"
ModifierTaserOvercharge.name_id = "none"
ModifierTaserOvercharge.desc_id = "menu_cs_modifier_taser_overcharge"
ModifierTaserOvercharge.default_value = "speed"

function ModifierTaserOvercharge:modify_value(id, value)
	if id == "PlayerTased:TasedTime" then
		value = value / (self:value() * 0.01 + 1)
	end

	return value
end
