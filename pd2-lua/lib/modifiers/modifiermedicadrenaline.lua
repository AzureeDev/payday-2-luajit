ModifierMedicAdrenaline = ModifierMedicAdrenaline or class(BaseModifier)
ModifierMedicAdrenaline._type = "ModifierMedicAdrenaline"
ModifierMedicAdrenaline.name_id = "none"
ModifierMedicAdrenaline.desc_id = "menu_cs_modifier_medic_adrenaline"

function ModifierMedicAdrenaline:OnEnemyHealed(medic, target)
	target:base():add_buff("base_damage", self:value("damage") * 0.01)
end
