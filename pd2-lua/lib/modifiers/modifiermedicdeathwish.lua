ModifierMedicDeathwish = ModifierMedicDeathwish or class(BaseModifier)
ModifierMedicDeathwish._type = "ModifierMedicDeathwish"
ModifierMedicDeathwish.name_id = "none"
ModifierMedicDeathwish.desc_id = "menu_cs_modifier_medic_deathwish"

function ModifierMedicDeathwish:OnEnemyDied(unit, damage_info)
	if Network:is_client() then
		return
	end

	if unit:base():has_tag("medic") then
		local enemies = World:find_units_quick(unit, "sphere", unit:position(), tweak_data.medic.radius, managers.slot:get_mask("enemies"))

		for _, enemy in ipairs(enemies) do
			if unit:character_damage():heal_unit(enemy, true) then
				enemy:movement():action_request({
					body_part = 3,
					type = "healed",
					client_interrupt = Network:is_client()
				})
			end
		end
	end
end
