ModifierShieldPhalanx = ModifierShieldPhalanx or class(BaseModifier)
ModifierShieldPhalanx._type = "ModifierShieldPhalanx"
ModifierShieldPhalanx.name_id = "none"
ModifierShieldPhalanx.desc_id = "menu_cs_modifier_shield_phalanx"

function ModifierShieldPhalanx:init(data)
	ModifierShieldPhalanx.super.init(data)

	tweak_data.group_ai.unit_categories.CS_shield = tweak_data.group_ai.unit_categories.Phalanx_minion
	tweak_data.group_ai.unit_categories.FBI_shield = tweak_data.group_ai.unit_categories.Phalanx_minion
end

function ModifierShieldPhalanx:modify_value(id, value, unit)
	if id ~= "PlayerStandart:_start_action_intimidate" then
		return value
	end

	local unit_tweak = unit:base()._tweak_table

	if unit_tweak ~= "phalanx_minion" then
		return value
	end

	if unit:base().is_phalanx then
		return
	end

	return "f31x_any"
end
