ModifierCloakerKick = ModifierCloakerKick or class(BaseModifier)
ModifierCloakerKick._type = "ModifierCloakerKick"
ModifierCloakerKick.name_id = "none"
ModifierCloakerKick.desc_id = "menu_cs_modifier_cloaker_smoke"
ModifierCloakerKick.default_value = "effect"

function ModifierCloakerKick:OnPlayerCloakerKicked(cloaker_unit)
	local effect_func = MutatorCloakerEffect["effect_" .. tostring(self:value())]

	if effect_func then
		effect_func(self, cloaker_unit)
	end
end
