ModifierShieldReflect = ModifierShieldReflect or class(BaseModifier)
ModifierShieldReflect._type = "ModifierShieldReflect"
ModifierShieldReflect.name_id = "none"
ModifierShieldReflect.desc_id = "menu_cs_modifier_shield_reflect"

function ModifierShieldReflect:modify_value(id, value, hit_unit, unit)
	if id == "FragGrenade:ShouldReflect" then
		local is_shield = hit_unit:in_slot(8)

		if is_shield then
			return true
		end
	end

	return value
end
