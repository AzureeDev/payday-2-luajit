ModifierMedicRage = ModifierMedicRage or class(BaseModifier)
ModifierMedicRage._type = "ModifierMedicRage"
ModifierMedicRage.name_id = "none"
ModifierMedicRage.desc_id = "menu_cs_modifier_medic_rage"

function ModifierMedicRage:OnEnemyDied(unit)
	if Network:is_client() then
		return
	end

	local team_id = unit:brain()._logic_data.team and unit:brain()._logic_data.team.id or "law1"

	if team_id ~= "law1" then
		return
	end

	local enemies = World:find_units_quick(unit, "sphere", unit:position(), tweak_data.medic.radius, managers.slot:get_mask("enemies"))

	for _, enemy in ipairs(enemies) do
		if enemy:base():has_tag("medic") then
			enemy:base():add_buff("base_damage", self:value("damage") * 0.01)
		end
	end
end
