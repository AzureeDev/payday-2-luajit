GageModifierQuickLocks = GageModifierQuickLocks or class(GageModifier)
GageModifierQuickLocks._type = "GageModifierQuickLocks"
GageModifierQuickLocks.default_value = "speed"

function GageModifierQuickLocks:get_speed_divisor()
	return 1 + self:value() / 100
end

function GageModifierQuickLocks:modify_value(id, value, interact_object)
	if id == "PlayerStandard:OnStartInteraction" then
		local tweak_id = interact_object:interaction().tweak_data
		local tweak = tweak_id and tweak_data.interaction[tweak_id]

		if tweak and tweak.is_lockpicking then
			return value / self:get_speed_divisor()
		end
	end

	return value
end
