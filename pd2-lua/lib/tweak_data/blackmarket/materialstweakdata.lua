function BlackMarketTweakData:_init_materials(tweak_data)
	self.materials = {
		plastic = {}
	}
	self.materials.plastic.name_id = "bm_mtl_plastic"
	self.materials.plastic.texture = "units/payday2/matcaps/matcap_plastic_df"
	self.materials.plastic.value = 0
	self.materials.titanium = {
		name_id = "bm_mtl_titanium",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_titanium_df",
		infamous = true,
		value = 5
	}
	self.materials.mercury = {
		name_id = "bm_mtl_mercury",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_mercury_df",
		value = 3
	}
	self.materials.oxide_bronze = {
		name_id = "bm_mtl_oxide_bronze",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_oxide_bronze_df",
		value = 4
	}
	self.materials.deep_bronze = {
		name_id = "bm_mtl_deep_bronze",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_deep_bronze_df",
		infamous = true,
		value = 5
	}
	self.materials.slime = {
		name_id = "bm_mtl_slime",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_slime_df",
		infamous = true,
		value = 2
	}
	self.materials.gold_clean = {
		name_id = "bm_mtl_gold_clean",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_gold_clean_df",
		infamous = true,
		value = 10
	}
	self.materials.concrete1 = {
		name_id = "bm_mtl_concrete1",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_concrete1_df",
		material_amount = 0,
		value = 2
	}
	self.materials.rock1 = {
		name_id = "bm_mtl_rock1",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_rock1_df",
		material_amount = 0,
		value = 3
	}
	self.materials.rock2 = {
		name_id = "bm_mtl_rock2",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_rock2_df",
		material_amount = 0,
		value = 2
	}
	self.materials.rock3 = {
		name_id = "bm_mtl_rock3",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_rock3_df",
		material_amount = 0,
		value = 2
	}
	self.materials.whiterock = {
		name_id = "bm_mtl_whiterock",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_whiterock_df",
		material_amount = 0,
		value = 3
	}
	self.materials.metal1 = {
		name_id = "bm_mtl_metal1",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_metal1_df",
		material_amount = 0,
		value = 6
	}
	self.materials.cracks1 = {
		name_id = "bm_mtl_cracks1",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_cracks1_df",
		material_amount = 0,
		value = 2
	}
	self.materials.wicker1 = {
		name_id = "bm_mtl_wicker1",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_wicker1_df",
		material_amount = 0,
		value = 3
	}
	self.materials.scales = {
		name_id = "bm_mtl_scales",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_scales_df",
		infamous = true,
		material_amount = 0,
		value = 7
	}
	self.materials.oldbronze = {
		name_id = "bm_mtl_oldbronze",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_oldbronze_df",
		material_amount = 0,
		infamous = true,
		value = 8
	}
	self.materials.bark1 = {
		name_id = "bm_mtl_bark1",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_bark1_df",
		material_amount = 0,
		value = 4
	}
	self.materials.bark2 = {
		name_id = "bm_mtl_bark2",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_bark2_df",
		material_amount = 0,
		value = 3
	}
	self.materials.bark3 = {
		name_id = "bm_mtl_bark3",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_bark3_df",
		material_amount = 0,
		value = 2
	}
	self.materials.carbon = {
		name_id = "bm_mtl_carbon",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_carbon_df",
		material_amount = 0,
		value = 6
	}
	self.materials.leather = {
		name_id = "bm_mtl_leather1",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_leather1_df",
		material_amount = 0,
		value = 6
	}
	self.materials.bloodred = {
		name_id = "bm_mtl_bloodred",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_bloodred_df",
		value = 8
	}
	self.materials.waterblue = {
		name_id = "bm_mtl_waterblue",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_waterblue_df",
		value = 4
	}
	self.materials.matteblack = {
		name_id = "bm_mtl_matteblack",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_matteblack_df",
		value = 9
	}
	self.materials.pianoblack = {
		name_id = "bm_mtl_pianoblack",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_pianoblack_df",
		infamous = true,
		value = 10
	}
	self.materials.twoblue = {
		name_id = "bm_mtl_twoblue",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_twoblue_df",
		value = 6
	}
	self.materials.rainbow = {
		name_id = "bm_mtl_rainbow",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_rainbow_df",
		infamous = true,
		value = 3
	}
	self.materials.magma = {
		name_id = "bm_mtl_magma",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_magma_df",
		value = 6
	}
	self.materials.radioactive = {
		name_id = "bm_mtl_radioactive",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_radioactive_df",
		infamous = true,
		value = 7
	}
	self.materials.bismuth = {
		name_id = "bm_mtl_bismuth",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_bismuth_df",
		value = 3
	}
	self.materials.greygloss = {
		name_id = "bm_mtl_greygloss",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_greygloss_df",
		value = 5
	}
	self.materials.finewood = {
		name_id = "bm_mtl_finewood",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_finewood_df",
		material_amount = 0,
		value = 8
	}
	self.materials.skin = {
		name_id = "bm_mtl_skin",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_skin_df",
		material_amount = 0,
		value = 6
	}
	self.materials.alligator = {
		name_id = "bm_mtl_alligator",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_alligator_df",
		material_amount = 0,
		value = 6
	}
	self.materials.denim = {
		name_id = "bm_mtl_denim",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_denim_df",
		material_amount = 0,
		value = 2
	}
	self.materials.candy = {
		name_id = "bm_mtl_candy",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_candy_df",
		value = 5
	}
	self.materials.chrome_purple = {
		name_id = "bm_mtl_chrome_purple",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_chrome_purple_df",
		value = 5
	}
	self.materials.hot_cold = {
		name_id = "bm_mtl_hot_cold",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_hot_cold_df",
		value = 5
	}
	self.materials.orchish = {
		name_id = "bm_mtl_orchish",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/matcaps/matcap_orcish_df",
		value = 5
	}
	self.materials.cash = {
		name_id = "bm_mtl_cash",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc1/matcaps/matcap_cash_df",
		material_amount = 0,
		value = 5,
		dlc = "armored_transport"
	}
	self.materials.jade = {
		name_id = "bm_mtl_jade",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc1/matcaps/matcap_jade_df",
		value = 5,
		dlc = "armored_transport"
	}
	self.materials.redwhiteblue = {
		name_id = "bm_mtl_redwhiteblue",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc1/matcaps/matcap_redwhiteblue_df",
		value = 5,
		dlc = "armored_transport"
	}
	self.materials.marble = {
		name_id = "bm_mtl_marble",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc1/matcaps/matcap_marble_df",
		value = 5,
		dlc = "armored_transport"
	}
	self.materials.fur = {
		name_id = "bm_mtl_fur",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_dec5/matcaps/matcap_fur_df",
		material_amount = 0,
		value = 5,
		dlc = "gage_pack"
	}
	self.materials.galvanized = {
		name_id = "bm_mtl_galvanized",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_dec5/matcaps/matcap_galvanized_df",
		material_amount = 0,
		value = 5,
		dlc = "gage_pack"
	}
	self.materials.heavymetal = {
		name_id = "bm_mtl_heavymetal",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_dec5/matcaps/matcap_heavymetal_df",
		material_amount = 0,
		value = 5,
		dlc = "gage_pack"
	}
	self.materials.oilmetal = {
		name_id = "bm_mtl_oilmetal",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_dec5/matcaps/matcap_oilmetal_df",
		value = 5,
		dlc = "gage_pack"
	}
	self.materials.gunmetal = {
		name_id = "bm_mtl_gunmetal",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_gage_lmg/matcaps/matcap_gunmetal_df",
		value = 5,
		dlc = "gage_pack_lmg"
	}
	self.materials.mud = {
		name_id = "bm_mtl_mud",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_gage_lmg/matcaps/matcap_mud_df",
		material_amount = 0,
		value = 5,
		dlc = "gage_pack_lmg"
	}
	self.materials.splinter = {
		name_id = "bm_mtl_splinter",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_gage_lmg/matcaps/matcap_splinter_df",
		material_amount = 0,
		value = 5,
		dlc = "gage_pack_lmg"
	}
	self.materials.erdl = {
		name_id = "bm_mtl_erdl",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_gage_lmg/matcaps/matcap_erdl_df",
		material_amount = 0,
		value = 5,
		dlc = "gage_pack_lmg"
	}
	self.materials.arizona = {
		name_id = "bm_mtl_arizona",
		pcs = {},
		texture = "units/pd2_dlc_infamy/matcaps/matcap_arizona_df",
		value = 0,
		global_value = "infamy",
		infamy_lock = "infamy_maskpack_destroyer"
	}
	self.materials.baby = {
		name_id = "bm_mtl_baby",
		pcs = {},
		texture = "units/pd2_dlc_infamy/matcaps/matcap_baby_df",
		value = 0,
		global_value = "infamy",
		infamy_lock = "infamy_maskpack_lurker"
	}
	self.materials.alien_slime = {
		name_id = "bm_mtl_alien_slime",
		pcs = {},
		texture = "units/pd2_dlc_infamy/matcaps/matcap_alien_slime_df",
		value = 0,
		global_value = "infamy",
		infamy_lock = "infamy_maskpack_ranger"
	}
	self.materials.eye = {
		name_id = "bm_mtl_eye",
		pcs = {},
		texture = "units/pd2_dlc_infamy/matcaps/matcap_eye_df",
		value = 0,
		global_value = "infamy",
		infamy_lock = "infamy_maskpack_balaclava"
	}
	self.materials.hades = {
		name_id = "bm_mtl_hades",
		pcs = {},
		texture = "units/pd2_dlc_infamy/matcaps/matcap_hades_df",
		value = 0,
		global_value = "infamy",
		infamy_lock = "infamy_maskpack_pain"
	}
	self.materials.punk = {
		name_id = "bm_mtl_punk",
		pcs = {},
		texture = "units/pd2_dlc_infamy/matcaps/matcap_punk_df",
		value = 0,
		global_value = "infamy",
		infamy_lock = "infamy_maskpack_punk"
	}
	self.materials.haze = {
		name_id = "bm_mtl_haze",
		pcs = {},
		texture = "units/pd2_dlc_infamy/matcaps/matcap_haze_df",
		value = 0,
		global_value = "infamy",
		infamy_lock = "infamy_maskpack_daft"
	}
	self.materials.plastic_hood = {
		name_id = "bm_mtl_plastic_hood",
		pcs = {},
		texture = "units/pd2_dlc_infamy/matcaps/matcap_plastic_hood_df",
		value = 0,
		global_value = "infamy",
		infamy_lock = "infamy_maskpack_hood"
	}
	self.materials.copper = {
		name_id = "bm_mtl_copper",
		pcs = {},
		texture = "units/pd2_dlc_infamy/matcaps/matcap_copper_df",
		material_amount = 0,
		value = 0,
		global_value = "infamy",
		infamy_lock = "infamy_enforcer"
	}
	self.materials.dark_leather = {
		name_id = "bm_mtl_dark_leather",
		pcs = {},
		texture = "units/pd2_dlc_infamy/matcaps/matcap_dark_leather_df",
		material_amount = 0,
		value = 0,
		global_value = "infamy",
		infamy_lock = "infamy_mastermind"
	}
	self.materials.sinister = {
		name_id = "bm_mtl_sinister",
		pcs = {},
		texture = "units/pd2_dlc_infamy/matcaps/matcap_sinister_df",
		value = 0,
		global_value = "infamy",
		infamy_lock = "infamy_ghost"
	}
	self.materials.electric = {
		name_id = "bm_mtl_electric",
		pcs = {},
		texture = "units/pd2_dlc_infamy/matcaps/matcap_electric_df",
		value = 0,
		global_value = "infamy",
		infamy_lock = "infamy_technician"
	}
	self.materials.bugshell = {
		name_id = "bm_mtl_bugshell",
		pcs = {},
		texture = "units/pd2_dlc_gage_snp/materials/matcap_bugshell_df",
		material_amount = 0,
		value = 0,
		dlc = "gage_pack_snp"
	}
	self.materials.carapace = {
		name_id = "bm_mtl_carapace",
		pcs = {},
		texture = "units/pd2_dlc_gage_snp/materials/matcap_carapace_df",
		value = 0,
		dlc = "gage_pack_snp"
	}
	self.materials.hardshell = {
		name_id = "bm_mtl_hardshell",
		pcs = {},
		texture = "units/pd2_dlc_gage_snp/materials/matcap_hardshell_df",
		material_amount = 0,
		value = 0,
		dlc = "gage_pack_snp"
	}
	self.materials.insectoid = {
		name_id = "bm_mtl_insectoid",
		pcs = {},
		texture = "units/pd2_dlc_gage_snp/materials/matcap_insectoid_df",
		value = 0,
		dlc = "gage_pack_snp"
	}
	self.materials.blackmetal = {
		name_id = "bm_mtl_blackmetal",
		pcs = {},
		texture = "units/pd2_poetry_winners/materials/matcap_blackmetal_df",
		material_amount = 0,
		value = 0,
		dlc = "poetry_soundtrack",
		global_value = "poetry_soundtrack"
	}
	self.materials.carbongrid = {
		name_id = "bm_mtl_carbongrid",
		pcs = {},
		texture = "units/pd2_poetry_winners/materials/matcap_carbongrid_df",
		material_amount = 0,
		value = 0,
		dlc = "poetry_soundtrack",
		global_value = "poetry_soundtrack"
	}
	self.materials.cosmoline = {
		name_id = "bm_mtl_cosmoline",
		pcs = {},
		texture = "units/pd2_poetry_winners/materials/matcap_cosmoline_df",
		value = 0,
		dlc = "poetry_soundtrack",
		global_value = "poetry_soundtrack"
	}
	self.materials.electronic = {
		name_id = "bm_mtl_electronic",
		pcs = {},
		texture = "units/pd2_poetry_winners/materials/matcap_electronic_df",
		material_amount = 0,
		value = 0,
		dlc = "poetry_soundtrack",
		global_value = "poetry_soundtrack"
	}
	self.materials.gemstone = {
		name_id = "bm_mtl_gemstone",
		pcs = {},
		texture = "units/pd2_dlc_big/matcaps/matcap_gemstone_df",
		value = 0,
		dlc = "big_bank"
	}
	self.materials.old = {
		name_id = "bm_mtl_old",
		pcs = {},
		texture = "units/pd2_dlc_big/matcaps/matcap_old_df",
		value = 0,
		dlc = "big_bank"
	}
	self.materials.clay = {
		name_id = "bm_mtl_clay",
		pcs = {},
		texture = "units/pd2_dlc_big/matcaps/matcap_clay_df",
		material_amount = 0,
		value = 0,
		dlc = "big_bank"
	}
	self.materials.parchment = {
		name_id = "bm_mtl_parchment",
		pcs = {},
		texture = "units/pd2_dlc_big/matcaps/matcap_parchment_df",
		material_amount = 0,
		value = 0,
		dlc = "big_bank"
	}
	self.materials.sparks = {
		name_id = "bm_mtl_sparks",
		pcs = {},
		texture = "units/pd2_dlc_gage_shot/matcaps/matcap_sparks_df",
		value = 0,
		dlc = "gage_pack_shotgun"
	}
	self.materials.explosive = {
		name_id = "bm_mtl_explosive",
		pcs = {},
		texture = "units/pd2_dlc_gage_shot/matcaps/matcap_explosive_df",
		value = 0,
		dlc = "gage_pack_shotgun"
	}
	self.materials.bananapeel = {
		name_id = "bm_mtl_bananapeel",
		pcs = {},
		texture = "units/pd2_dlc_gage_shot/matcaps/matcap_bananapeel_df",
		material_amount = 0,
		value = 0,
		dlc = "gage_pack_shotgun"
	}
	self.materials.leaf = {
		name_id = "bm_mtl_leaf",
		pcs = {},
		texture = "units/pd2_dlc_gage_shot/matcaps/matcap_leaf_df",
		material_amount = 0,
		value = 0,
		dlc = "gage_pack_shotgun"
	}
	self.materials.bone = {
		name_id = "bm_mtl_bone",
		pcs = {},
		texture = "units/pd2_dlc_gage_assault/materials/matcap_bone_df",
		material_amount = 0,
		value = 0,
		dlc = "gage_pack_assault"
	}
	self.materials.frost = {
		name_id = "bm_mtl_frost",
		pcs = {},
		texture = "units/pd2_dlc_gage_assault/materials/matcap_frost_df",
		material_amount = 0,
		value = 0,
		dlc = "gage_pack_assault"
	}
	self.materials.evil = {
		name_id = "bm_mtl_evil",
		pcs = {},
		texture = "units/pd2_dlc_gage_assault/materials/matcap_evil_df",
		value = 0,
		dlc = "gage_pack_assault"
	}
	self.materials.void = {
		name_id = "bm_mtl_void",
		pcs = {},
		texture = "units/pd2_dlc_gage_assault/materials/matcap_void_df",
		value = 0,
		dlc = "gage_pack_assault"
	}
	self.materials.sunset = {
		name_id = "bm_mtl_sunset",
		pcs = {},
		texture = "units/pd2_dlc_miami/matcaps/matcap_sunset_df",
		value = 0,
		dlc = "hl_miami"
	}
	self.materials.chromescape = {
		name_id = "bm_mtl_chromescape",
		pcs = {},
		texture = "units/pd2_dlc_miami/matcaps/matcap_chromescape_df",
		value = 0,
		dlc = "hl_miami"
	}
	self.materials.rubber = {
		name_id = "bm_mtl_rubber",
		pcs = {},
		texture = "units/pd2_dlc_miami/matcaps/matcap_rubber_df",
		value = 0,
		dlc = "hl_miami"
	}
	self.materials.error = {
		name_id = "bm_mtl_error",
		pcs = {},
		texture = "units/pd2_dlc_miami/matcaps/matcap_error_df",
		material_amount = 0,
		value = 0,
		dlc = "hl_miami"
	}
	self.materials.rug = {
		name_id = "bm_mtl_rug",
		pcs = {},
		texture = "units/pd2_dlc_miami/matcaps/matcap_rug_df",
		material_amount = 0,
		value = 0,
		dlc = "hlm_game"
	}
	self.materials.cushion = {
		name_id = "bm_mtl_cushion",
		pcs = {},
		texture = "units/pd2_dlc_miami/matcaps/matcap_cushion_df",
		material_amount = 0,
		value = 0,
		dlc = "hlm_game"
	}
	self.materials.hatred = {
		name_id = "bm_mtl_hatred",
		pcs = {},
		texture = "units/pd2_dlc_miami/matcaps/matcap_hatred_df",
		value = 0,
		dlc = "hlm_game"
	}
	self.materials.neon = {
		name_id = "bm_mtl_neon",
		pcs = {},
		texture = "units/pd2_dlc_miami/matcaps/matcap_neon_df",
		value = 0,
		dlc = "hlm_game"
	}
	self.materials.armygreen = {
		name_id = "bm_mtl_armygreen",
		pcs = {},
		texture = "units/pd2_dlc_gage_historical/materials/matcap_armygreen_df",
		material_amount = 0,
		value = 0,
		dlc = "gage_pack_historical"
	}
	self.materials.gunsmoke = {
		name_id = "bm_mtl_gunsmoke",
		pcs = {},
		texture = "units/pd2_dlc_gage_historical/materials/matcap_gunsmoke_df",
		value = 0,
		dlc = "gage_pack_historical"
	}
	self.materials.patriot = {
		name_id = "bm_mtl_patriot",
		pcs = {},
		texture = "units/pd2_dlc_gage_historical/materials/matcap_patriot_df",
		material_amount = 0,
		value = 0,
		dlc = "gage_pack_historical"
	}
	self.materials.redsun = {
		name_id = "bm_mtl_redsun",
		pcs = {},
		texture = "units/pd2_dlc_gage_historical/materials/matcap_redsun_df",
		value = 0,
		dlc = "gage_pack_historical"
	}
	self.materials.diamond = {
		name_id = "bm_mtl_diamond",
		pcs = {},
		texture = "units/pd2_indiana/materials/matcap_diamond_df",
		value = 0,
		dlc = "hope_diamond"
	}
	self.materials.bandages = {
		name_id = "bm_mtl_bandages",
		pcs = {},
		texture = "units/pd2_indiana/materials/matcap_bandages_df",
		material_amount = 0,
		value = 0,
		dlc = "hope_diamond"
	}
	self.materials.rust = {
		name_id = "bm_mtl_dark_rust",
		pcs = {},
		texture = "units/pd2_indiana/materials/matcap_rust_df",
		material_amount = 0,
		value = 0,
		dlc = "hope_diamond"
	}
	self.materials.sand = {
		name_id = "bm_mtl_dark_sand",
		pcs = {},
		texture = "units/pd2_indiana/materials/matcap_sand_df",
		material_amount = 0,
		value = 0,
		dlc = "hope_diamond"
	}
	self.materials.meat = {
		name_id = "bm_mtl_meat",
		pcs = {},
		texture = "units/pd2_dlc_cro/matcaps/matcaps_meat_df",
		material_amount = 0,
		value = 0,
		dlc = "the_bomb",
		texture_bundle_folder = "the_bomb"
	}
	self.materials.plywood = {
		name_id = "bm_mtl_plywood",
		pcs = {},
		texture = "units/pd2_dlc_cro/matcaps/matcaps_plywood_df",
		material_amount = 0,
		value = 0,
		dlc = "the_bomb",
		texture_bundle_folder = "the_bomb"
	}
	self.materials.rhino_skin = {
		name_id = "bm_mtl_rhino",
		pcs = {},
		texture = "units/pd2_dlc_cro/matcaps/matcaps_rhino_df",
		material_amount = 0,
		value = 0,
		dlc = "the_bomb",
		texture_bundle_folder = "the_bomb"
	}
	self.materials.rock_marble = {
		name_id = "bm_mtl_rock_marble",
		pcs = {},
		texture = "units/pd2_dlc_cro/matcaps/matcaps_rock_marble_df",
		material_amount = 0,
		value = 0,
		dlc = "the_bomb",
		texture_bundle_folder = "the_bomb"
	}
	self.materials.dawn = {
		name_id = "bm_mtl_dawn",
		pcs = {},
		texture = "units/pd2_dlc_akm4_modpack/materials/matcap_dawn_df",
		value = 0,
		dlc = "akm4_pack",
		texture_bundle_folder = "dlc_akm4"
	}
	self.materials.prehistoric = {
		name_id = "bm_mtl_prehistoric",
		pcs = {},
		texture = "units/pd2_dlc_akm4_modpack/materials/matcap_prehistoric_df",
		value = 0,
		dlc = "akm4_pack",
		texture_bundle_folder = "dlc_akm4"
	}
	self.materials.fossil = {
		name_id = "bm_mtl_fossil",
		pcs = {},
		texture = "units/pd2_dlc_akm4_modpack/materials/matcap_fossil_df",
		material_amount = 0,
		value = 0,
		dlc = "akm4_pack",
		texture_bundle_folder = "dlc_akm4"
	}
	self.materials.feathers = {
		name_id = "bm_mtl_feathers",
		pcs = {},
		texture = "units/pd2_dlc_akm4_modpack/materials/matcap_feathers_df",
		material_amount = 0,
		value = 0,
		dlc = "akm4_pack",
		texture_bundle_folder = "dlc_akm4"
	}
	self.materials.candlelight = {
		name_id = "bm_mtl_candlelight",
		pcs = {},
		texture = "units/pd2_dlc_bbq/materials/matcap_candlelight_df",
		value = 0,
		dlc = "bbq",
		texture_bundle_folder = "bbq"
	}
	self.materials.burn = {
		name_id = "bm_mtl_burn",
		pcs = {},
		texture = "units/pd2_dlc_bbq/materials/matcap_burn_df",
		value = 0,
		dlc = "bbq",
		texture_bundle_folder = "bbq"
	}
	self.materials.toast = {
		name_id = "bm_mtl_toast",
		pcs = {},
		texture = "units/pd2_dlc_bbq/materials/matcap_toast_df",
		value = 0,
		material_amount = 0,
		dlc = "bbq",
		texture_bundle_folder = "bbq"
	}
	self.materials.coal = {
		name_id = "bm_mtl_coal",
		pcs = {},
		texture = "units/pd2_dlc_bbq/materials/matcap_coal_df",
		value = 0,
		material_amount = 0,
		dlc = "bbq",
		texture_bundle_folder = "bbq"
	}
	self.materials.goldfever = {
		name_id = "bm_mtl_goldfever",
		pcs = {},
		texture = "units/pd2_dlc_west/masks/materials/matcap_goldfever_df",
		dlc = "west",
		value = 0
	}
	self.materials.westernsunset = {
		name_id = "bm_mtl_westernsunset",
		pcs = {},
		texture = "units/pd2_dlc_west/masks/materials/matcap_westernsunset_df",
		dlc = "west",
		value = 0
	}
	self.materials.scorpion = {
		name_id = "bm_mtl_scorpion",
		pcs = {},
		texture = "units/pd2_dlc_west/masks/materials/matcap_scorpion_df",
		dlc = "west",
		material_amount = 0,
		value = 0
	}
	self.materials.cactus = {
		name_id = "bm_mtl_cactus",
		pcs = {},
		texture = "units/pd2_dlc_west/masks/materials/matcap_cactus_df",
		dlc = "west",
		material_amount = 0,
		value = 0
	}
	self.materials.stained_glass = {
		name_id = "bm_mtl_stained_glass",
		pcs = {},
		texture = "units/pd2_dlc_arena/masks/materials/matcap_stained_glass_df",
		dlc = "arena",
		material_amount = 0,
		value = 0
	}
	self.materials.bionic = {
		name_id = "bm_mtl_bionic",
		pcs = {},
		texture = "units/pd2_dlc_arena/masks/materials/matcap_bionic_df",
		dlc = "arena",
		material_amount = 0,
		value = 0
	}
	self.materials.enlightment = {
		name_id = "bm_mtl_enlightment",
		pcs = {},
		texture = "units/pd2_dlc_arena/masks/materials/matcap_enlightment_df",
		dlc = "arena",
		value = 0
	}
	self.materials.dimblue = {
		name_id = "bm_mtl_dimblue",
		pcs = {},
		texture = "units/pd2_dlc_arena/masks/materials/matcap_dimblue_df",
		dlc = "arena",
		value = 0
	}
	self.materials.carpet = {
		name_id = "bm_mtl_carpet",
		pcs = {},
		texture = "units/pd2_dlc_casino/matcaps/matcap_carpet_df",
		material_amount = 0,
		value = 0,
		dlc = "kenaz",
		texture_bundle_folder = "kenaz"
	}
	self.materials.casino = {
		name_id = "bm_mtl_casino",
		pcs = {},
		texture = "units/pd2_dlc_casino/matcaps/matcap_casino_df",
		value = 0,
		dlc = "kenaz",
		texture_bundle_folder = "kenaz"
	}
	self.materials.plush = {
		name_id = "bm_mtl_plush",
		pcs = {},
		texture = "units/pd2_dlc_casino/matcaps/matcap_plush_df",
		material_amount = 0,
		value = 0,
		dlc = "kenaz",
		texture_bundle_folder = "kenaz"
	}
	self.materials.stars = {
		name_id = "bm_mtl_stars",
		pcs = {},
		texture = "units/pd2_dlc_casino/matcaps/matcap_stars_df",
		value = 0,
		dlc = "kenaz",
		texture_bundle_folder = "kenaz"
	}
	self.materials.still_waters = {
		name_id = "bm_mtl_still_waters",
		pcs = {},
		texture = "units/pd2_dlc_turtles/masks/materials/matcap_still_waters_df",
		value = 0,
		dlc = "turtles"
	}
	self.materials.sakura = {
		name_id = "bm_mtl_sakura",
		pcs = {},
		texture = "units/pd2_dlc_turtles/masks/materials/matcap_sakura_df",
		value = 0,
		dlc = "turtles"
	}
	self.materials.bamboo = {
		name_id = "bm_mtl_bamboo",
		pcs = {},
		texture = "units/pd2_dlc_turtles/masks/materials/matcap_bamboo_df",
		material_amount = 0,
		value = 0,
		dlc = "turtles"
	}
	self.materials.origami = {
		name_id = "bm_mtl_origami",
		pcs = {},
		texture = "units/pd2_dlc_turtles/masks/materials/matcap_origami_df",
		material_amount = 0,
		value = 0,
		dlc = "turtles"
	}
	self.materials.forged = {
		name_id = "bm_mtl_forged",
		pcs = {},
		texture = "units/pd2_dlc_steel/masks/materials/matcap_forged_df",
		value = 0,
		dlc = "steel"
	}
	self.materials.blooded = {
		name_id = "bm_mtl_blooded",
		pcs = {},
		texture = "units/pd2_dlc_steel/masks/materials/matcap_blooded_df",
		value = 0,
		dlc = "steel"
	}
	self.materials.chain_armor = {
		name_id = "bm_mtl_chain_armor",
		pcs = {},
		texture = "units/pd2_dlc_steel/masks/materials/matcap_chain_armor_df",
		material_amount = 0,
		value = 0,
		dlc = "steel"
	}
	self.materials.scale_armor = {
		name_id = "bm_mtl_scale_armor",
		pcs = {},
		texture = "units/pd2_dlc_steel/masks/materials/matcap_scale_armor_df",
		material_amount = 0,
		value = 0,
		dlc = "steel"
	}
	self.materials.flow = {
		name_id = "bm_mtl_flow",
		pcs = {},
		texture = "units/pd2_dlc_jerry/masks/materials/matcap_flow_df",
		dlc = "berry",
		material_amount = 0,
		value = 0
	}
	self.materials.sancti = {
		name_id = "bm_mtl_sancti",
		pcs = {},
		texture = "units/pd2_dlc_jerry/masks/materials/matcap_sancti_df",
		dlc = "berry",
		value = 0
	}
	self.materials.glade = {
		name_id = "bm_mtl_glade",
		pcs = {},
		texture = "units/pd2_dlc_jerry/masks/materials/matcap_glade_df",
		dlc = "berry",
		value = 0
	}
	self.materials.wade = {
		name_id = "bm_mtl_wade",
		pcs = {},
		texture = "units/pd2_dlc_jerry/masks/materials/matcap_wade_df",
		dlc = "berry",
		value = 0
	}
	self.materials.goateye = {
		name_id = "bm_mtl_goateye",
		pcs = {},
		texture = "units/pd2_dlc_peta/masks/materials/matcap_goateye_df",
		value = 0,
		dlc = "peta"
	}
	self.materials.flamingoeye = {
		name_id = "bm_mtl_flamingoeye",
		pcs = {},
		texture = "units/pd2_dlc_peta/masks/materials/matcap_flamingoeye_df",
		value = 0,
		dlc = "peta"
	}
	self.materials.hay = {
		name_id = "bm_mtl_hay",
		pcs = {},
		texture = "units/pd2_dlc_peta/masks/materials/matcap_hay_df",
		material_amount = 0,
		value = 0,
		dlc = "peta"
	}
	self.materials.tongue = {
		name_id = "bm_mtl_tongue",
		pcs = {},
		texture = "units/pd2_dlc_peta/masks/materials/matcap_tongue_df",
		material_amount = 0,
		value = 0,
		dlc = "peta"
	}
	self.materials.day = {
		name_id = "bm_mtl_days",
		pcs = {},
		texture = "units/pd2_dlc_lupus/materials/matcap_days_df",
		material_amount = 0,
		value = 0,
		dlc = "pal"
	}
	self.materials.houndstooth = {
		name_id = "bm_mtl_houndstooth",
		pcs = {},
		texture = "units/pd2_dlc_lupus/materials/matcap_houndstooth_df",
		material_amount = 0,
		value = 0,
		dlc = "pal"
	}
	self.materials.redwhite = {
		name_id = "bm_mtl_matcap_redwhite_df",
		pcs = {},
		texture = "units/pd2_dlc_lupus/materials/matcap_redwhite_df",
		value = 0,
		dlc = "pal"
	}
	self.materials.mushroom_cloud = {
		name_id = "bm_mtl_matcap_mushroom_cloud_df",
		pcs = {},
		texture = "units/pd2_dlc_lupus/materials/matcap_mushroom_cloud_df",
		value = 0,
		dlc = "pal"
	}
	self.materials.nebula = {
		name_id = "bm_mtl_nebula",
		pcs = {},
		texture = "units/pd2_dlc_mad/masks/materials/matcap_nebula_df",
		value = 0
	}
	self.materials.planet = {
		name_id = "bm_mtl_planet",
		pcs = {},
		texture = "units/pd2_dlc_mad/masks/materials/matcap_planet_df",
		value = 0
	}
	self.materials.rusty = {
		name_id = "bm_mtl_rusty",
		pcs = {},
		texture = "units/pd2_dlc_mad/masks/materials/matcap_rusty_df",
		material_amount = 0,
		value = 0
	}
	self.materials.spaceship = {
		name_id = "bm_mtl_spaceship",
		pcs = {},
		texture = "units/pd2_dlc_mad/masks/materials/matcap_spaceship_df",
		material_amount = 0,
		value = 0
	}
	self.materials.chromey = {
		name_id = "bm_mtl_chromey",
		pcs = {},
		texture = "units/pd2_dlc_born/masks/materials/matcap_chrome_pastel_df",
		value = 0,
		texture_bundle_folder = "born",
		dlc = "born"
	}
	self.materials.devil_eye = {
		name_id = "bm_mtl_devil_eye",
		pcs = {},
		texture = "units/pd2_dlc_born/masks/materials/matcap_devil_eye_df",
		value = 0,
		texture_bundle_folder = "born",
		dlc = "born"
	}
	self.materials.hotrod_red = {
		name_id = "bm_mtl_hotrod_red",
		pcs = {},
		texture = "units/pd2_dlc_born/masks/materials/matcap_hotrod_red_df",
		value = 0,
		texture_bundle_folder = "born",
		dlc = "born"
	}
	self.materials.shiny_and_chrome = {
		name_id = "bm_mtl_shiny_and_chrome",
		pcs = {},
		texture = "units/pd2_dlc_born/masks/materials/matcap_red_gold_df",
		value = 0,
		texture_bundle_folder = "born",
		dlc = "born"
	}
	self.materials.club = {
		name_id = "bm_mtl_club",
		pcs = {},
		texture = "units/pd2_dlc_pim/masks/materials/matcap_club_df",
		value = 0,
		dlc = "pim"
	}
	self.materials.mist = {
		name_id = "bm_mtl_mist",
		pcs = {},
		texture = "units/pd2_dlc_pim/masks/materials/matcap_mist_df",
		value = 0,
		dlc = "pim"
	}
	self.materials.dog = {
		material_amount = 0,
		name_id = "bm_mtl_dog",
		pcs = {},
		texture = "units/pd2_dlc_pim/masks/materials/matcap_dog_df",
		value = 0,
		dlc = "pim"
	}
	self.materials.wheel = {
		material_amount = 0,
		name_id = "bm_mtl_wheel",
		pcs = {},
		texture = "units/pd2_dlc_pim/masks/materials/matcap_wheel_df",
		value = 0,
		dlc = "pim"
	}
	self.materials.army_deep_green = {
		name_id = "bm_mtl_army_deep_green",
		pcs = {},
		texture = "units/pd2_dlc_tng/masks/materials/matcap_army_deep_green_df",
		value = 0,
		dlc = "tango"
	}
	self.materials.ranger_black = {
		name_id = "bm_mtl_ranger_black",
		pcs = {},
		texture = "units/pd2_dlc_tng/masks/materials/matcap_ranger_black_df",
		value = 0,
		dlc = "tango"
	}
	self.materials.digital_camo = {
		name_id = "bm_mtl_digital_camo",
		pcs = {},
		texture = "units/pd2_dlc_tng/masks/materials/matcap_digital_camo_df",
		value = 0,
		material_amount = 0,
		dlc = "tango"
	}
	self.materials.midnight_camo = {
		name_id = "bm_mtl_midnight_camo",
		pcs = {},
		texture = "units/pd2_dlc_tng/masks/materials/matcap_midnight_camo_df",
		value = 0,
		material_amount = 0,
		dlc = "tango"
	}
	self.materials.oxidized_copper = {
		name_id = "bm_mtl_oxidized_copper",
		pcs = {},
		texture = "units/pd2_dlc_friend/masks/materials/matcap_oxidized_copper_df",
		value = 0,
		material_amount = 0,
		dlc = "friend"
	}
	self.materials.golden_hour = {
		name_id = "bm_mtl_golden_hour",
		pcs = {},
		texture = "units/pd2_dlc_friend/masks/materials/matcap_golden_hour_df",
		value = 0,
		dlc = "friend"
	}
	self.materials.red_velvet = {
		name_id = "bm_mtl_red_velvet",
		pcs = {},
		texture = "units/pd2_dlc_friend/masks/materials/matcap_red_velvet_df",
		value = 0,
		dlc = "friend"
	}
	self.materials.black_marble = {
		name_id = "bm_mtl_black_marble",
		pcs = {},
		texture = "units/pd2_dlc_friend/masks/materials/matcap_black_marble_df",
		value = 0,
		material_amount = 0,
		dlc = "friend"
	}
	self.materials.carbon_fiber_weave = {
		name_id = "bm_mtl_carbon_fiber_weave",
		pcs = {},
		texture = "units/pd2_dlc_spa/masks/materials/matcap_carbon_fiber_weave_df",
		value = 0,
		material_amount = 0,
		dlc = "spa"
	}
	self.materials.black_suede = {
		name_id = "bm_mtl_black_suede",
		pcs = {},
		texture = "units/pd2_dlc_spa/masks/materials/matcap_black_suede_df",
		value = 0,
		material_amount = 0,
		dlc = "spa"
	}
	self.materials.neon_blue = {
		name_id = "bm_mtl_neon_blue",
		pcs = {},
		texture = "units/pd2_dlc_spa/masks/materials/matcap_neon_blue_df",
		value = 0,
		dlc = "spa"
	}
	self.materials.underground_neon = {
		name_id = "bm_mtl_underground_neon",
		pcs = {},
		texture = "units/pd2_dlc_spa/masks/materials/matcap_underground_neon_df",
		value = 0,
		dlc = "spa"
	}
	self.materials.russian_camouflage = {
		name_id = "bm_mtl_russian_camouflage",
		pcs = {},
		texture = "units/pd2_dlc_grv/masks/materials/matcap_russian_camouflage_df",
		value = 0,
		material_amount = 0,
		dlc = "grv"
	}
	self.materials.ceramics_gzhel = {
		name_id = "bm_mtl_ceramics_gzhel",
		pcs = {},
		texture = "units/pd2_dlc_grv/masks/materials/matcap_ceramics_gzhel_df",
		value = 0,
		material_amount = 0,
		dlc = "grv"
	}
	self.materials.propaganda_palette = {
		name_id = "bm_mtl_propaganda_palette",
		pcs = {},
		texture = "units/pd2_dlc_grv/masks/materials/matcap_propaganda_palette_df",
		value = 0,
		dlc = "grv"
	}
	self.materials.tricolor = {
		name_id = "bm_mtl_tricolor",
		pcs = {},
		texture = "units/pd2_dlc_grv/masks/materials/matcap_tricolor_df",
		value = 0,
		dlc = "grv"
	}
	self.materials.solid_greyscale70 = {
		name_id = "bm_mtl_matcap_solid_greyscale70",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_greyscale70_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_greyscale50 = {
		name_id = "bm_mtl_matcap_solid_grey50",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_greyscale50_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_greyscale10 = {
		name_id = "bm_mtl_matcap_solid_greyscale10",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_greyscale10_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_green = {
		name_id = "bm_mtl_matcap_solid_green",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_green_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_green_dark = {
		name_id = "bm_mtl_matcap_solid_green_dark",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_green_dark_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_green_desaturated = {
		name_id = "bm_mtl_matcap_solid_green_desaturated",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_green_desaturated_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_yellow = {
		name_id = "bm_mtl_matcap_solid_yellow",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_yellow_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_yellow_dark = {
		name_id = "bm_mtl_matcap_solid_yellow_dark",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_yellow_dark_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_yellow_desaturated = {
		name_id = "bm_mtl_matcap_solid_yellow_desaturated",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_yellow_desaturated_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_orange = {
		name_id = "bm_mtl_matcap_solid_orange",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_orange_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_orange_dark = {
		name_id = "bm_mtl_matcap_solid_orange_dark",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_orange_dark_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_orange_desaturated = {
		name_id = "bm_mtl_matcap_solid_orange_desaturated",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_orange_desaturated_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_red = {
		name_id = "bm_mtl_matcap_solid_red",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_red_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_red_dark = {
		name_id = "bm_mtl_matcap_solid_red_dark",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_red_dark_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_red_desaturated = {
		name_id = "bm_mtl_matcap_solid_red_desaturated",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_red_desaturated_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_purple = {
		name_id = "bm_mtl_matcap_solid_purple",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_purple_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_purple_dark = {
		name_id = "bm_mtl_matcap_solid_purple_dark",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_purple_dark_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_purple_desaturated = {
		name_id = "bm_mtl_matcap_solid_purple_desaturated",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_purple_desaturated_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_pink = {
		name_id = "bm_mtl_matcap_solid_pink",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_pink_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_pink_dark = {
		name_id = "bm_mtl_matcap_solid_pink_dark",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_pink_dark_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_pink_desaturated = {
		name_id = "bm_mtl_matcap_solid_pink_desaturated",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_pink_desaturated_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_blue = {
		name_id = "bm_mtl_matcap_solid_blue",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_blue_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_blue_dark = {
		name_id = "bm_mtl_matcap_solid_blue_dark",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_blue_dark_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_blue_desaturated = {
		name_id = "bm_mtl_matcap_solid_blue_desaturated",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_blue_desaturated_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_paydayblue = {
		name_id = "bm_mtl_matcap_solid_paydayblue",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_paydayblue_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_paydayblue_dark = {
		name_id = "bm_mtl_matcap_solid_paydayblue_dark",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_paydayblue_dark_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_paydayblue_desaturated = {
		name_id = "bm_mtl_matcap_solid_paydayblue_desaturated",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_paydayblue_desaturated_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_teal = {
		name_id = "bm_mtl_matcap_solid_teal",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_teal_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_teal_dark = {
		name_id = "bm_mtl_matcap_solid_teal_dark",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_teal_dark_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_teal_desaturated = {
		name_id = "bm_mtl_matcap_solid_teal_desaturated",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_teal_desaturated_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_magenta = {
		name_id = "bm_mtl_matcap_solid_magenta",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_magenta_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_magenta_dark = {
		name_id = "bm_mtl_matcap_solid_magenta_dark",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_magenta_dark_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	self.materials.solid_magenta_desaturated = {
		name_id = "bm_mtl_matcap_solid_magenta_desaturated",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/materials/matcap_solid_magenta_desaturated_df",
		value = 0,
		material_amount = 0,
		texture_bundle_folder = "pmp"
	}
	local free_dlcs = tweak_data:free_dlc_list()

	for _, data in pairs(self.materials) do
		if free_dlcs[data.dlc] then
			data.dlc = nil
		end
	end
end
