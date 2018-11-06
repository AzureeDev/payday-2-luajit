MutatorHydra = MutatorHydra or class(BaseMutator)
MutatorHydra._type = "MutatorHydra"
MutatorHydra.name_id = "mutator_hydra"
MutatorHydra.desc_id = "mutator_hydra_desc"
MutatorHydra.has_options = true
MutatorHydra.reductions = {
	money = 0,
	exp = 0
}
MutatorHydra.disables_achievements = true
MutatorHydra.categories = {
	"enemies",
	"gameplay"
}
MutatorHydra.incompatiblities = {
	"MutatorExplodingEnemies",
	"MutatorShotgunTweak"
}
MutatorHydra.icon_coords = {
	1,
	1
}
MutatorHydra.raw_enemy_list = {
	["units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"] = {
		"units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"
	},
	["units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"] = {
		{
			"units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1",
			3
		},
		{
			"units/payday2/characters/ene_spook_1/ene_spook_1",
			1
		}
	},
	["units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"] = {
		{
			"units/payday2/characters/ene_shield_1/ene_shield_1",
			4
		},
		{
			"units/payday2/characters/ene_spook_1/ene_spook_1",
			1
		}
	},
	["units/pd2_dlc_vip/characters/ene_vip_1/ene_vip_1"] = {},
	["units/pd2_dlc_vip/characters/ene_phalanx_1/ene_phalanx_1"] = {
		"units/payday2/characters/ene_tazer_1/ene_tazer_1"
	},
	["units/payday2/characters/ene_shield_1/ene_shield_1"] = {
		{
			"units/payday2/characters/ene_tazer_1/ene_tazer_1",
			3
		},
		{
			"units/payday2/characters/ene_spook_1/ene_spook_1",
			1
		}
	},
	["units/payday2/characters/ene_shield_2/ene_shield_2"] = {
		{
			"units/payday2/characters/ene_tazer_1/ene_tazer_1",
			4
		},
		{
			"units/payday2/characters/ene_spook_1/ene_spook_1",
			1
		}
	},
	["units/payday2/characters/ene_sniper_2/ene_sniper_2"] = {},
	["units/payday2/characters/ene_sniper_1/ene_sniper_1"] = {},
	["units/payday2/characters/ene_medic_m4/ene_medic_m4"] = {
		"units/payday2/characters/ene_spook_1/ene_spook_1",
		"units/payday2/characters/ene_tazer_1/ene_tazer_1"
	},
	["units/payday2/characters/ene_medic_r870/ene_medic_r870"] = {
		"units/payday2/characters/ene_spook_1/ene_spook_1",
		"units/payday2/characters/ene_tazer_1/ene_tazer_1"
	},
	["units/payday2/characters/ene_spook_1/ene_spook_1"] = {
		"units/payday2/characters/ene_tazer_1/ene_tazer_1"
	},
	["units/payday2/characters/ene_tazer_1/ene_tazer_1"] = {
		"units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2"
	},
	["units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_3/ene_zeal_bulldozer_3"] = {
		"units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer/ene_zeal_bulldozer"
	},
	["units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer/ene_zeal_bulldozer"] = {
		{
			"units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_2/ene_zeal_bulldozer_2",
			3
		},
		{
			"units/pd2_dlc_gitgud/characters/ene_zeal_cloaker/ene_zeal_cloaker",
			1
		}
	},
	["units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_2/ene_zeal_bulldozer_2"] = {
		"units/pd2_dlc_gitgud/characters/ene_zeal_swat_shield/ene_zeal_swat_shield"
	},
	["units/pd2_dlc_gitgud/characters/ene_zeal_swat_shield/ene_zeal_swat_shield"] = {
		"units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy"
	},
	["units/pd2_dlc_gitgud/characters/ene_zeal_cloaker/ene_zeal_cloaker"] = {
		"units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy"
	},
	["units/pd2_dlc_gitgud/characters/ene_zeal_tazer/ene_zeal_tazer"] = {
		"units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy"
	},
	["units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy"] = {
		"units/pd2_dlc_gitgud/characters/ene_zeal_swat/ene_zeal_swat"
	},
	["units/pd2_dlc_gitgud/characters/ene_zeal_swat/ene_zeal_swat"] = {
		"units/payday2/characters/ene_city_swat_3/ene_city_swat_3",
		"units/payday2/characters/ene_city_swat_2/ene_city_swat_2",
		"units/payday2/characters/ene_city_swat_1/ene_city_swat_1"
	},
	["units/payday2/characters/ene_city_swat_3/ene_city_swat_3"] = {
		"units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1"
	},
	["units/payday2/characters/ene_city_swat_2/ene_city_swat_2"] = {
		"units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1"
	},
	["units/payday2/characters/ene_city_swat_1/ene_city_swat_1"] = {
		"units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1"
	},
	["units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1"] = {
		"units/payday2/characters/ene_swat_heavy_1/ene_swat_heavy_1"
	},
	["units/payday2/characters/ene_swat_heavy_1/ene_swat_heavy_1"] = {
		"units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2"
	},
	["units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2"] = {
		"units/payday2/characters/ene_swat_2/ene_swat_2",
		"units/payday2/characters/ene_swat_1/ene_swat_1"
	},
	["units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"] = {
		"units/payday2/characters/ene_swat_2/ene_swat_2",
		"units/payday2/characters/ene_swat_1/ene_swat_1"
	},
	["units/payday2/characters/ene_swat_2/ene_swat_2"] = {
		"units/payday2/characters/ene_fbi_3/ene_fbi_3",
		"units/payday2/characters/ene_fbi_2/ene_fbi_2",
		"units/payday2/characters/ene_fbi_1/ene_fbi_1"
	},
	["units/payday2/characters/ene_swat_1/ene_swat_1"] = {
		"units/payday2/characters/ene_fbi_3/ene_fbi_3",
		"units/payday2/characters/ene_fbi_2/ene_fbi_2",
		"units/payday2/characters/ene_fbi_1/ene_fbi_1"
	},
	["units/payday2/characters/ene_fbi_3/ene_fbi_3"] = {
		"units/payday2/characters/ene_cop_1/ene_cop_1",
		"units/payday2/characters/ene_cop_2/ene_cop_2",
		"units/payday2/characters/ene_cop_3/ene_cop_3",
		"units/payday2/characters/ene_cop_4/ene_cop_4"
	},
	["units/payday2/characters/ene_fbi_2/ene_fbi_2"] = {
		"units/payday2/characters/ene_cop_1/ene_cop_1",
		"units/payday2/characters/ene_cop_2/ene_cop_2",
		"units/payday2/characters/ene_cop_3/ene_cop_3",
		"units/payday2/characters/ene_cop_4/ene_cop_4"
	},
	["units/payday2/characters/ene_fbi_1/ene_fbi_1"] = {
		"units/payday2/characters/ene_cop_1/ene_cop_1",
		"units/payday2/characters/ene_cop_2/ene_cop_2",
		"units/payday2/characters/ene_cop_3/ene_cop_3",
		"units/payday2/characters/ene_cop_4/ene_cop_4"
	},
	["units/payday2/characters/ene_cop_1/ene_cop_1"] = {
		"units/payday2/characters/ene_cop_2/ene_cop_2",
		"units/payday2/characters/ene_cop_3/ene_cop_3",
		"units/payday2/characters/ene_cop_4/ene_cop_4"
	},
	["units/payday2/characters/ene_cop_2/ene_cop_2"] = {
		"units/payday2/characters/ene_cop_1/ene_cop_1",
		"units/payday2/characters/ene_cop_3/ene_cop_3",
		"units/payday2/characters/ene_cop_4/ene_cop_4"
	},
	["units/payday2/characters/ene_cop_3/ene_cop_3"] = {
		"units/payday2/characters/ene_cop_1/ene_cop_1",
		"units/payday2/characters/ene_cop_2/ene_cop_2",
		"units/payday2/characters/ene_cop_4/ene_cop_4"
	},
	["units/payday2/characters/ene_cop_4/ene_cop_4"] = {
		"units/payday2/characters/ene_cop_1/ene_cop_1",
		"units/payday2/characters/ene_cop_2/ene_cop_2",
		"units/payday2/characters/ene_cop_3/ene_cop_3"
	},
	["units/pd2_dlc_mad/characters/ene_akan_fbi_tank_rpk_lmg/ene_akan_fbi_tank_rpk_lmg"] = {
		"units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga"
	},
	["units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga"] = {
		{
			"units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870",
			3
		},
		{
			"units/pd2_dlc_mad/characters/ene_akan_fbi_spooc_asval_smg/ene_akan_fbi_spooc_asval_smg",
			1
		}
	},
	["units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870"] = {
		{
			"units/pd2_dlc_mad/characters/ene_akan_fbi_shield_sr2_smg/ene_akan_fbi_shield_sr2_smg",
			3
		},
		{
			"units/pd2_dlc_mad/characters/ene_akan_fbi_spooc_asval_smg/ene_akan_fbi_spooc_asval_smg",
			1
		}
	},
	["units/pd2_dlc_mad/characters/ene_akan_fbi_shield_sr2_smg/ene_akan_fbi_shield_sr2_smg"] = {
		{
			"units/pd2_dlc_mad/characters/ene_akan_cs_tazer_ak47_ass/ene_akan_cs_tazer_ak47_ass",
			4
		},
		{
			"units/pd2_dlc_mad/characters/ene_akan_fbi_spooc_asval_smg/ene_akan_fbi_spooc_asval_smg",
			1
		}
	},
	["units/pd2_dlc_mad/characters/ene_akan_cs_shield_c45/ene_akan_cs_shield_c45"] = {
		{
			"units/pd2_dlc_mad/characters/ene_akan_cs_tazer_ak47_ass/ene_akan_cs_tazer_ak47_ass",
			4
		},
		{
			"units/pd2_dlc_mad/characters/ene_akan_fbi_spooc_asval_smg/ene_akan_fbi_spooc_asval_smg",
			1
		}
	},
	["units/pd2_dlc_mad/characters/ene_akan_fbi_spooc_asval_smg/ene_akan_fbi_spooc_asval_smg"] = {
		"units/pd2_dlc_mad/characters/ene_akan_cs_tazer_ak47_ass/ene_akan_cs_tazer_ak47_ass"
	},
	["units/pd2_dlc_mad/characters/ene_akan_cs_tazer_ak47_ass/ene_akan_cs_tazer_ak47_ass"] = {
		"units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"
	},
	["units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_ak47_ass/ene_akan_fbi_swat_dw_ak47_ass"] = {
		"units/pd2_dlc_mad/characters/ene_akan_fbi_swat_r870/ene_akan_fbi_swat_r870",
		"units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"
	},
	["units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_r870/ene_akan_fbi_swat_dw_r870"] = {
		"units/pd2_dlc_mad/characters/ene_akan_fbi_swat_r870/ene_akan_fbi_swat_r870",
		"units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"
	},
	["units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36/ene_akan_fbi_heavy_g36"] = {
		"units/pd2_dlc_mad/characters/ene_akan_fbi_swat_r870/ene_akan_fbi_swat_r870",
		"units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"
	},
	["units/pd2_dlc_mad/characters/ene_akan_fbi_swat_r870/ene_akan_fbi_swat_r870"] = {
		"units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"
	},
	["units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"] = {
		"units/pd2_dlc_mad/characters/ene_akan_cs_heavy_ak47_ass/ene_akan_cs_heavy_ak47_ass"
	},
	["units/pd2_dlc_mad/characters/ene_akan_cs_heavy_ak47_ass/ene_akan_cs_heavy_ak47_ass"] = {
		"units/pd2_dlc_mad/characters/ene_akan_cs_swat_r870/ene_akan_cs_swat_r870"
	},
	["units/pd2_dlc_mad/characters/ene_akan_cs_swat_r870/ene_akan_cs_swat_r870"] = {
		"units/pd2_dlc_mad/characters/ene_akan_cs_swat_ak47_ass/ene_akan_cs_swat_ak47_ass"
	},
	["units/pd2_dlc_mad/characters/ene_akan_cs_swat_ak47_ass/ene_akan_cs_swat_ak47_ass"] = {
		"units/pd2_dlc_mad/characters/ene_akan_cs_swat_r870/ene_akan_cs_swat_r870"
	},
	["units/pd2_dlc_mad/characters/ene_akan_cs_cop_akmsu_smg/ene_akan_cs_cop_akmsu_smg"] = {},
	["units/pd2_dlc_mad/characters/ene_akan_cs_cop_r870/ene_akan_cs_cop_r870"] = {},
	["units/pd2_dlc_mad/characters/ene_akan_cs_cop_asval_smg/ene_akan_cs_cop_asval_smg"] = {},
	["units/payday2/characters/ene_murkywater_1/ene_murkywater_1"] = {
		"units/payday2/characters/ene_murkywater_1/ene_murkywater_1"
	},
	["units/payday2/characters/ene_murkywater_2/ene_murkywater_2"] = {
		"units/payday2/characters/ene_murkywater_2/ene_murkywater_2"
	},
	["units/pd2_dlc_berry/characters/ene_murkywater_no_light/ene_murkywater_no_light"] = {
		"units/pd2_dlc_berry/characters/ene_murkywater_no_light/ene_murkywater_no_light"
	},
	["units/pd2_mcmansion/characters/ene_male_hector_1/ene_male_hector_1"] = {
		"units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"
	},
	["units/pd2_mcmansion/characters/ene_male_hector_2/ene_male_hector_2"] = {
		"units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"
	},
	["units/pd2_dlc_born/characters/ene_gang_biker_boss/ene_gang_biker_boss"] = {
		"units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"
	},
	["units/payday2/characters/ene_gang_mobster_boss/ene_gang_mobster_boss"] = {
		"units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"
	},
	["units/payday2/characters/ene_gang_mobster_4/ene_gang_mobster_4"] = {
		"units/payday2/characters/ene_gang_mobster_1/ene_gang_mobster_1",
		"units/payday2/characters/ene_gang_mobster_2/ene_gang_mobster_2",
		"units/payday2/characters/ene_gang_mobster_3/ene_gang_mobster_3"
	},
	["units/payday2/characters/ene_gang_mobster_3/ene_gang_mobster_3"] = {
		"units/payday2/characters/ene_gang_mobster_1/ene_gang_mobster_1",
		"units/payday2/characters/ene_gang_mobster_2/ene_gang_mobster_2",
		"units/payday2/characters/ene_gang_mobster_4/ene_gang_mobster_4"
	},
	["units/payday2/characters/ene_gang_mobster_2/ene_gang_mobster_2"] = {
		"units/payday2/characters/ene_gang_mobster_1/ene_gang_mobster_1",
		"units/payday2/characters/ene_gang_mobster_3/ene_gang_mobster_3",
		"units/payday2/characters/ene_gang_mobster_4/ene_gang_mobster_4"
	},
	["units/payday2/characters/ene_gang_mobster_1/ene_gang_mobster_1"] = {
		"units/payday2/characters/ene_gang_mobster_2/ene_gang_mobster_2",
		"units/payday2/characters/ene_gang_mobster_3/ene_gang_mobster_3",
		"units/payday2/characters/ene_gang_mobster_4/ene_gang_mobster_4"
	},
	["units/payday2/characters/ene_secret_service_2/ene_secret_service_2"] = {
		"units/payday2/characters/ene_secret_service_2/ene_secret_service_2"
	},
	["units/payday2/characters/ene_secret_service_1/ene_secret_service_1"] = {
		"units/payday2/characters/ene_secret_service_1/ene_secret_service_1"
	},
	["units/payday2/characters/ene_security_3/ene_security_3"] = {
		"units/payday2/characters/ene_security_2/ene_security_2",
		"units/payday2/characters/ene_security_1/ene_security_1"
	},
	["units/payday2/characters/ene_security_2/ene_security_2"] = {
		"units/payday2/characters/ene_security_1/ene_security_1"
	},
	["units/payday2/characters/ene_security_1/ene_security_1"] = {
		"units/payday2/characters/ene_security_2/ene_security_2"
	},
	["units/payday2/characters/ene_biker_4/ene_biker_4"] = {
		"units/payday2/characters/ene_biker_3/ene_biker_3",
		"units/payday2/characters/ene_biker_2/ene_biker_2",
		"units/payday2/characters/ene_biker_1/ene_biker_1"
	},
	["units/payday2/characters/ene_biker_3/ene_biker_3"] = {
		"units/payday2/characters/ene_biker_4/ene_biker_4",
		"units/payday2/characters/ene_biker_2/ene_biker_2",
		"units/payday2/characters/ene_biker_1/ene_biker_1"
	},
	["units/payday2/characters/ene_biker_2/ene_biker_2"] = {
		"units/payday2/characters/ene_biker_4/ene_biker_4",
		"units/payday2/characters/ene_biker_3/ene_biker_3",
		"units/payday2/characters/ene_biker_1/ene_biker_1"
	},
	["units/payday2/characters/ene_biker_1/ene_biker_1"] = {
		"units/payday2/characters/ene_biker_4/ene_biker_4",
		"units/payday2/characters/ene_biker_3/ene_biker_3",
		"units/payday2/characters/ene_biker_2/ene_biker_2"
	},
	["units/payday2/characters/ene_gang_mexican_4/ene_gang_mexican_4"] = {},
	["units/payday2/characters/ene_gang_mexican_3/ene_gang_mexican_3"] = {},
	["units/payday2/characters/ene_gang_mexican_2/ene_gang_mexican_2"] = {},
	["units/payday2/characters/ene_gang_mexican_1/ene_gang_mexican_1"] = {},
	["units/payday2/characters/ene_gang_black_4/ene_gang_black_4"] = {},
	["units/payday2/characters/ene_gang_black_3/ene_gang_black_3"] = {},
	["units/payday2/characters/ene_gang_black_2/ene_gang_black_2"] = {},
	["units/payday2/characters/ene_gang_black_1/ene_gang_black_1"] = {},
	["units/payday2/characters/ene_gang_russian_3/ene_gang_russian_3"] = {},
	["units/payday2/characters/ene_gang_russian_2/ene_gang_russian_2"] = {},
	["units/payday2/characters/ene_gang_russian_1/ene_gang_russian_1"] = {}
}

function MutatorHydra:register_values(mutator_manager)
	self:register_value("max_unit_depth", 2, "md")
end

function MutatorHydra:setup(mutator_manager)
	self._units = {}

	mutator_manager:register_message(Message.OnCopDamageDeath, "MutatorHydra", callback(self, self, "split_enemy"))
	self:_setup_enemy_list()
end

function MutatorHydra:_setup_enemy_list()
	local converted_list = {}

	for k, units in pairs(self.raw_enemy_list) do
		local selector = WeightedSelector:new()
		local _k = Idstring(k):key()

		for i, unit_data in pairs(units) do
			if type(unit_data) == "table" then
				selector:add(unit_data[1] and Idstring(unit_data[1]) or false, unit_data[2] or 1)
			else
				selector:add(Idstring(unit_data), 1)
			end
		end

		converted_list[_k] = selector
	end

	self.enemy_list = converted_list
end

function MutatorHydra:name()
	local name = MutatorHydra.super.name(self)

	if self:_mutate_name("max_unit_depth") then
		local macros = {
			splits = self:value("max_unit_depth")
		}

		return string.format("%s - %s", name, managers.localization:text("mutator_hydra_split_num", macros))
	else
		return name
	end
end

function MutatorHydra:get_max_unit_depth()
	return self:value("max_unit_depth")
end

function MutatorHydra:update(t, dt)
	for i, spawn_data in pairs(self._hydra_spawns or {}) do
		spawn_data.t = spawn_data.t - dt

		if spawn_data.t <= 0 then
			print("[Mutators] Spawn hydra unit: ", spawn_data.name, spawn_data.depth)

			local unit = safe_spawn_unit(spawn_data.name, spawn_data.position, spawn_data.rotation)

			if unit then
				if spawn_data.group then
					managers.groupai:state():assign_enemy_to_existing_group(unit, spawn_data.group)
				else
					managers.groupai:state():assign_enemy_to_group_ai(unit, spawn_data.team_id)
				end

				self:set_hydra_depth(unit, spawn_data.depth)

				local spine = unit:get_object(Idstring("Spine2"))

				if spine then
					MutatorHydra.play_split_particle(spine:position(), Rotation())
				end
			end

			table.remove(self._hydra_spawns, i)
		end
	end
end

MutatorHydra._sound_devices = 0

function MutatorHydra.play_split_particle(position, rotation)
	if not _G.managers or not managers.mutators or not PackageManager:loaded(managers.mutators.package) then
		return false
	end

	if not managers.player:player_unit() then
		return
	end

	World:effect_manager():spawn({
		effect = Idstring("effects/payday2/particles/explosions/smoke_puff_alt"),
		position = position,
		rotation = Rotation()
	})

	local sound_device = SoundDevice:create_source("MutatorHydra_" .. tostring(MutatorHydra._sound_devices))

	if sound_device then
		sound_device:stop()
		sound_device:set_position(position)
		sound_device:set_orientation(rotation)
		sound_device:post_event("mutators_hydra_01")
	else
		Application:error("[Mutators] No sound device for hydra to use!")
	end

	MutatorHydra._sound_devices = MutatorHydra._sound_devices + 1

	if Network:is_server() then
		managers.network:session():send_to_peers("sync_mutator_hydra_split", position)
	end
end

function MutatorHydra:split_enemy(cop_damage, attack_data)
	if Network:is_server() then
		local parent_unit = cop_damage._unit
		local spawn_selector = self.enemy_list[parent_unit:name():key()]

		if spawn_selector then
			math.randomseed(os.time())
			math.random()
			math.random()
			math.random()

			local unit_depth = self:get_hydra_depth(parent_unit)

			self:_spawn_unit(spawn_selector:select(), parent_unit, unit_depth)
			self:_spawn_unit(spawn_selector:select(), parent_unit, unit_depth)
			self:set_hydra_depth(parent_unit, nil)
		else
			print("[Mutators] No hydra spawn data for unit: ", alive(parent_unit) and parent_unit:name() or "no parent_unit")
		end
	end
end

function MutatorHydra:_spawn_unit(name, parent_unit, depth)
	if not name or self:get_max_unit_depth() <= depth then
		return false
	end

	local ang = math.random() * 360 * math.pi
	local rad = math.random(30, 50)
	local offset = Vector3(math.cos(ang) * rad, math.sin(ang) * rad, 0)
	local position = parent_unit:position() + offset

	if parent_unit:brain()._logic_data.group then
		local units = parent_unit:brain()._logic_data.group.units

		if units then
			units[parent_unit:key()] = nil
		end
	end

	self._hydra_spawns = self._hydra_spawns or {}

	table.insert(self._hydra_spawns, {
		t = 0.1,
		name = name,
		position = position,
		rotation = parent_unit:rotation(),
		depth = depth + 1,
		group = parent_unit:brain()._logic_data.group,
		team_id = parent_unit:brain()._logic_data.team and parent_unit:brain()._logic_data.team.id or "law1"
	})
end

function MutatorHydra:get_hydra_depth(unit)
	return self._units[unit:key()] or 0
end

function MutatorHydra:set_hydra_depth(unit, depth)
	self._units[unit:key()] = depth
end

function MutatorHydra:_min_splits()
	return 1
end

function MutatorHydra:_max_splits()
	return 4
end

function MutatorHydra:setup_options_gui(node)
	local params = {
		name = "hydra_split_slider",
		callback = "_update_mutator_value",
		text_id = "menu_mutator_hydra_max",
		update_callback = callback(self, self, "_update_max_unit_depth")
	}
	local data_node = {
		show_value = true,
		step = 1,
		type = "CoreMenuItemSlider.ItemSlider",
		decimal_count = 0,
		min = self:_min_splits(),
		max = self:_max_splits()
	}
	local new_item = node:create_item(data_node, params)

	new_item:set_value(self:get_max_unit_depth())
	node:add_item(new_item)

	self._node = node

	return new_item
end

function MutatorHydra:_update_max_unit_depth(item)
	self:set_value("max_unit_depth", math.round(item:value()))
end

function MutatorHydra:reset_to_default()
	self:clear_values()

	if self._node then
		local slider = self._node:item("hydra_split_slider")

		if slider then
			slider:set_value(self:get_max_unit_depth())
		end
	end
end

function MutatorHydra:options_fill()
	return self:_get_percentage_fill(1, self:_max_splits(), self:get_max_unit_depth())
end
