ModifierCloakerTearGas = ModifierCloakerTearGas or class(BaseModifier)
ModifierCloakerTearGas._type = "ModifierCloakerTearGas"
ModifierCloakerTearGas.name_id = "none"
ModifierCloakerTearGas.desc_id = "menu_cs_modifier_cloaker_tear_gas"

function ModifierCloakerTearGas:OnEnemyDied(unit, damage_info)
	if Network:is_client() then
		return
	end

	if unit:base()._tweak_table == "spooc" then
		local grenade = World:spawn_unit(Idstring("units/pd2_dlc_drm/weapons/smoke_grenade_tear_gas/smoke_grenade_tear_gas"), unit:position(), unit:rotation())

		grenade:base():set_properties({
			radius = self:value("diameter") * 0.5 * 100,
			damage = self:value("damage") * 0.1,
			duration = self:value("duration")
		})
		grenade:base():detonate()
	end
end
