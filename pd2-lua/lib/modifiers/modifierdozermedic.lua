ModifierDozerMedic = ModifierDozerMedic or class(BaseModifier)
ModifierDozerMedic._type = "ModifierDozerMedic"
ModifierDozerMedic.name_id = "none"
ModifierDozerMedic.desc_id = "menu_cs_modifier_dozer_medic"

function ModifierDozerMedic:init(data)
	ModifierDozerMedic.super.init(self, data)

	local unit_types = tweak_data.group_ai.unit_categories.FBI_tank.unit_types
	local unit_name = Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_medic/ene_bulldozer_medic")

	table.insert(unit_types.america, unit_name)
	table.insert(unit_types.russia, unit_name)
	table.insert(unit_types.murkywater, unit_name)
	table.insert(unit_types.federales, unit_name)
end
