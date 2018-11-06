ModifierMoreSpecials = ModifierMoreSpecials or class(BaseModifier)
ModifierMoreSpecials._type = "ModifierMoreSpecials"
ModifierMoreSpecials.name_id = "none"
ModifierMoreSpecials.desc_id = "menu_cs_modifier_specials"
ModifierMoreSpecials.default_value = "inc"
ModifierMoreSpecials.unit_tweak_id = "tank"

function ModifierMoreSpecials:init(data)
	ModifierMoreSpecials.super.init(self, data)

	for key, value in pairs(tweak_data.group_ai.special_unit_spawn_limits) do
		if key == self.unit_tweak_id then
			tweak_data.group_ai.special_unit_spawn_limits[key] = tweak_data.group_ai.special_unit_spawn_limits[key] + self:value()
		end
	end
end
