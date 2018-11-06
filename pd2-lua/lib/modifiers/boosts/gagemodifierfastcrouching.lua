GageModifierFastCrouching = GageModifierFastCrouching or class(GageModifier)
GageModifierFastCrouching._type = "GageModifierFastCrouching"

function GageModifierFastCrouching:modify_value(id, value, state_data, speed_tweak)
	if id == "PlayerStandard:GetMaxWalkSpeed" and state_data.ducking then
		return speed_tweak.STANDARD_MAX
	end

	return value
end
