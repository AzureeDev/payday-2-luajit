ModifierNoHurtAnims = ModifierNoHurtAnims or class(BaseModifier)
ModifierNoHurtAnims._type = "ModifierNoHurtAnims"
ModifierNoHurtAnims.name_id = "none"
ModifierNoHurtAnims.desc_id = "menu_cs_modifier_no_hurt"
ModifierNoHurtAnims.IgnoredHurtTypes = {
	"expl_hurt",
	"knock_down",
	"stagger",
	"heavy_hurt",
	"hurt",
	"light_hurt"
}

function ModifierNoHurtAnims:modify_value(id, value)
	if id == "CopMovement:HurtType" and table.contains(ModifierNoHurtAnims.IgnoredHurtTypes, value) then
		return nil, true
	end

	return value
end
