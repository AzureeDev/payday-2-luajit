ModifierHeavies = ModifierHeavies or class(BaseModifier)
ModifierHeavies._type = "ModifierHeavies"
ModifierHeavies.name_id = "none"
ModifierHeavies.desc_id = "menu_cs_modifier_heavies"
ModifierHeavies.unit_swaps = {
	["units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2"] = "units/payday2/characters/ene_city_heavy_g36/ene_city_heavy_g36",
	["units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"] = "units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870"
}

function ModifierHeavies:init(data)
	ModifierHeavies.super.init(self, data)

	for group, unit_group in pairs(tweak_data.group_ai.unit_categories) do
		if unit_group.unit_types then
			for continent, units in pairs(unit_group.unit_types) do
				for i, unit_id in ipairs(units) do
					for swap_id, new_id in pairs(ModifierHeavies.unit_swaps) do
						if unit_id == Idstring(swap_id) then
							units[i] = Idstring(new_id)

							break
						end
					end
				end
			end
		end
	end
end
