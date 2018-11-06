ModifierCloakerArrest = ModifierCloakerArrest or class(BaseModifier)
ModifierCloakerArrest._type = "ModifierCloakerArrest"
ModifierCloakerArrest.name_id = "none"
ModifierCloakerArrest.desc_id = "menu_cs_modifier_cloaker_arrest"

function ModifierCloakerArrest:modify_value(id, value)
	if id == "PlayerMovement:OnSpooked" then
		return "arrested"
	end

	return value
end
