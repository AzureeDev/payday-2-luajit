ModifierDozerMinigun = ModifierDozerMinigun or class(BaseModifier)
ModifierDozerMinigun._type = "ModifierDozerMinigun"
ModifierDozerMinigun.name_id = "none"
ModifierDozerMinigun.desc_id = "menu_cs_modifier_dozer_minigun"

function ModifierDozerMinigun:init(data)
	ModifierDozerMinigun.super.init(self, data)

	local unit_types = tweak_data.group_ai.unit_categories.FBI_tank.unit_types
	local unit_name = Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun/ene_bulldozer_minigun")

	table.insert(unit_types.america, unit_name)
	table.insert(unit_types.russia, unit_name)
	table.insert(unit_types.murkywater, unit_name)
	table.insert(unit_types.federales, unit_name)
end
