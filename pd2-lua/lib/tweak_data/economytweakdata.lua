require("lib/tweak_data/GeneratedMarketLinkTweakData")

EconomyTweakData = EconomyTweakData or class()

function EconomyTweakData:init()
	self.safes = {}
	self.drills = {}
	self.gameplay = {}
	self.contents = {}
	self.bundles = {}
	self.rarities = {}
	self.qualities = {}
	self.market_links = init_auto_generated_steam_market_links()
	self.rarities.common = {
		index = 1,
		fake_chance = 75,
		open_safe_sequence = "anim_open_01",
		color = Color("2360D8"),
		header_col = "guis/dlcs/cash/textures/pd2/safe_raffle/header_col_common",
		bg_texture = "guis/dlcs/cash/textures/pd2/blackmarket/icons/rarity_common",
		name_id = "bm_menu_rarity_common",
		armor_sequence = "cvc_var1"
	}
	self.rarities.uncommon = {
		index = 2,
		fake_chance = 20,
		open_safe_sequence = "anim_open_02",
		color = Color("9900FF"),
		header_col = "guis/dlcs/cash/textures/pd2/safe_raffle/header_col_uncommon",
		bg_texture = "guis/dlcs/cash/textures/pd2/blackmarket/icons/rarity_uncommon",
		name_id = "bm_menu_rarity_uncommon",
		armor_sequence = "cvc_var2"
	}
	self.rarities.rare = {
		index = 3,
		fake_chance = 4,
		open_safe_sequence = "anim_open_03",
		color = Color("FF00FF"),
		header_col = "guis/dlcs/cash/textures/pd2/safe_raffle/header_col_rare",
		bg_texture = "guis/dlcs/cash/textures/pd2/blackmarket/icons/rarity_rare",
		name_id = "bm_menu_rarity_rare",
		armor_sequence = "cvc_var3"
	}
	self.rarities.epic = {
		index = 4,
		fake_chance = 1,
		open_safe_sequence = "anim_open_04",
		color = Color("FF0000"),
		header_col = "guis/dlcs/cash/textures/pd2/safe_raffle/header_col_epic",
		bg_texture = "guis/dlcs/cash/textures/pd2/blackmarket/icons/rarity_epic",
		name_id = "bm_menu_rarity_epic",
		armor_sequence = "cvc_var3"
	}
	self.rarities.legendary = {
		index = 5,
		fake_chance = 0,
		open_safe_sequence = "anim_open_05",
		color = Color("FFAA00"),
		header_col = "guis/dlcs/cash/textures/pd2/safe_raffle/header_col_legendary",
		bg_texture = "guis/dlcs/cash/textures/pd2/blackmarket/icons/rarity_legendary",
		name_id = "bm_menu_rarity_legendary",
		armor_sequence = "cvc_var3"
	}
	self.qualities.poor = {
		index = 1,
		wear_tear_value = 0.3,
		name_id = "bm_menu_quality_poor"
	}
	self.qualities.fair = {
		index = 2,
		wear_tear_value = 0.45,
		name_id = "bm_menu_quality_fair"
	}
	self.qualities.good = {
		index = 3,
		wear_tear_value = 0.6,
		name_id = "bm_menu_quality_good"
	}
	self.qualities.fine = {
		index = 4,
		wear_tear_value = 0.8,
		name_id = "bm_menu_quality_fine"
	}
	self.qualities.mint = {
		index = 5,
		wear_tear_value = 1,
		name_id = "bm_menu_quality_mint"
	}
	self.contents.legendary = {
		def_id = 10000,
		contains = {
			weapon_skins = {
				"ak74_rodina"
			}
		},
		rarity = "legendary"
	}
	self.contents.overkill_01 = {
		def_id = 10001,
		contains = {
			weapon_skins = {
				"new_m4_skullimov",
				"deagle_skullimov",
				"p90_skullimov",
				"plainsrider_skullimov",
				"m95_bombmatta",
				"huntsman_bloodsplat",
				"r93_wooh",
				"judge_wooh",
				"b92fs_bloodsplat",
				"mg42_bloodsplat",
				"m134_bloodsplat",
				"flamethrower_mk2_bloodsplat",
				"rpg7_bloodsplat",
				"g36_bloodsplat",
				"serbu_stunner",
				"new_m14_bloodsplat",
				"new_raging_bull_bloodsplat",
				"famas_bloodsplat",
				"r93_bloodsplat",
				"ak74_bloodsplat",
				"ppk_bloodsplat",
				"b92fs_wooh"
			},
			contents = {
				"overkill_01_legendary"
			}
		}
	}
	self.contents.overkill_01_legendary = {
		def_id = 10002,
		contains = {
			weapon_skins = {
				"flamethrower_mk2_fire",
				"rpg7_boom",
				"m134_bulletstorm"
			}
		},
		rarity = "legendary"
	}
	self.contents.event_01 = {
		def_id = 10003,
		contains = {
			weapon_skins = {
				"m95_forest",
				"famas_forest",
				"huntsman_forest",
				"r93_forest",
				"b92fs_forest",
				"m134_forest",
				"serbu_camohex",
				"new_m14_camohex",
				"judge_camohex",
				"mg42_camohex",
				"p90_luxury",
				"ak74_luxury",
				"ppk_luxury",
				"plainsrider_linked",
				"new_m4_payday"
			},
			contents = {
				"event_01_legendary"
			}
		}
	}
	self.contents.event_01_legendary = {
		def_id = 10004,
		contains = {
			weapon_skins = {
				"deagle_bling"
			}
		},
		rarity = "legendary"
	}
	self.contents.weapon_01 = {
		def_id = 10005,
		contains = {
			weapon_skins = {
				"serbu_woodland",
				"p90_woodland",
				"plainsrider_woodland",
				"rpg7_woodland",
				"ppk_woodland",
				"judge_woodland",
				"new_m4_goldstripes",
				"new_raging_bull_goldstripes",
				"flamethrower_mk2_goldstripes",
				"g36_goldstripes",
				"new_m14_luxury",
				"m95_luxury",
				"b92fs_luxury",
				"famas_hypno",
				"huntsman_hypno"
			},
			contents = {
				"legendary"
			}
		}
	}
	self.contents.event_red = {
		def_id = 10006,
		contains = {
			weapon_skins = {
				"p90_golddigger",
				"m95_golddigger",
				"serbu_golddigger",
				"huntsman_golddigger",
				"r93_golddigger",
				"ak74_golddigger",
				"m134_golddigger",
				"famas_golddigger",
				"new_m14_golddigger",
				"ppk_golddigger"
			},
			contents = {
				"event_01_legendary"
			}
		},
		type = "limited"
	}
	self.contents.event_dinner = {
		def_id = 10007,
		contains = {
			weapon_skins = {
				"judge_bloodbath",
				"b92fs_bloodbath",
				"new_raging_bull_bloodbath",
				"mg42_bloodbath",
				"plainsrider_bloodbath",
				"new_m4_bloodbath",
				"g36_bloodbath",
				"flamethrower_mk2_bloodbath",
				"deagle_bloodbath",
				"rpg7_bloodbath"
			},
			contents = {
				"legendary"
			}
		},
		type = "limited"
	}
	self.contents.dallas_01 = {
		def_id = 10008,
		contains = {
			weapon_skins = {
				"new_raging_bull_dallas",
				"mg42_dallas",
				"famas_dallas",
				"flamethrower_mk2_dallas",
				"huntsman_dallas",
				"r93_dallas",
				"ak74_dallas",
				"ppk_dallas",
				"deagle_dallas",
				"new_m14_dallas",
				"judge_dallas",
				"b92fs_dallas",
				"serbu_dallas",
				"g36_dallas",
				"m95_dallas"
			},
			contents = {
				"dallas_01_legendary"
			}
		}
	}
	self.contents.dallas_01_legendary = {
		def_id = 10009,
		contains = {
			weapon_skins = {
				"p90_dallas_sallad"
			}
		},
		rarity = "legendary"
	}
	self.contents.surf_01 = {
		def_id = 10010,
		contains = {
			weapon_skins = {
				"akm_waves",
				"asval_waves",
				"m16_waves",
				"baka_waves",
				"s552_waves",
				"usp_waves",
				"mac10_waves",
				"aug_waves",
				"scar_waves",
				"colt_1911_waves",
				"polymer_waves",
				"ak5_waves",
				"mosin_waves",
				"striker_waves",
				"x_g22c_waves"
			},
			contents = {
				"surf_01_legendary"
			}
		}
	}
	self.contents.surf_01_legendary = {
		def_id = 10011,
		contains = {
			weapon_skins = {
				"r870_waves"
			}
		},
		rarity = "legendary"
	}
	self.contents.event_flake = {
		def_id = 10012,
		contains = {
			weapon_skins = {
				"saiga_ginger",
				"p226_ginger",
				"new_mp5_ginger",
				"m249_ginger",
				"x_b92fs_ginger",
				"ksg_ginger",
				"m1928_ginger",
				"g22c_ginger",
				"wa2000_ginger",
				"akmsu_ginger"
			},
			contents = {
				"event_flake_legendary"
			}
		}
	}
	self.contents.event_flake_legendary = {
		def_id = 10013,
		contains = {
			weapon_skins = {
				"x_1911_ginger"
			}
		},
		rarity = "legendary"
	}
	self.contents.event_bah = {
		def_id = 10014,
		contains = {
			weapon_skins = {
				"ak5_baaah",
				"wa2000_baaah",
				"r870_baaah",
				"x_g22c_baaah",
				"usp_baaah",
				"polymer_baaah",
				"m16_baaah",
				"m249_baaah",
				"x_1911_baaah",
				"ksg_baaah"
			},
			contents = {
				"event_bah_legendary"
			}
		},
		type = "limited"
	}
	self.contents.event_bah_legendary = {
		def_id = 10015,
		contains = {
			weapon_skins = {
				"model70_baaah"
			}
		},
		rarity = "legendary"
	}
	self.contents.pack_01 = {
		def_id = 10016,
		contains = {
			weapon_skins = {
				"striker_wolf",
				"mosin_wolf",
				"colt_1911_wolf",
				"scar_wolf",
				"saiga_wolf",
				"g22c_wolf",
				"mac10_wolf",
				"p226_wolf",
				"akm_wolf",
				"baka_wolf",
				"aug_wolf",
				"asval_wolf",
				"x_deagle_wolf",
				"s552_wolf",
				"m16_wolf"
			},
			contents = {
				"pack_01_legendary"
			}
		}
	}
	self.contents.pack_01_legendary = {
		def_id = 10017,
		contains = {
			weapon_skins = {
				"par_wolf"
			}
		},
		rarity = "legendary"
	}
	self.contents.cola_01 = {
		def_id = 10018,
		contains = {
			weapon_skins = {
				"glock_17_cola",
				"scorpion_cola",
				"amcar_cola",
				"uzi_cola",
				"x_usp_cola",
				"m37_cola",
				"sparrow_cola",
				"benelli_cola",
				"hunter_cola",
				"hs2000_cola",
				"olympic_cola",
				"g3_cola",
				"b682_cola",
				"gre_m79_cola",
				"fal_cola"
			},
			contents = {
				"cola_01_legendary"
			}
		}
	}
	self.contents.cola_01_legendary = {
		def_id = 10019,
		contains = {
			weapon_skins = {
				"m16_cola"
			}
		},
		rarity = "legendary"
	}
	self.contents.burn_01 = {
		def_id = 10020,
		contains = {
			weapon_skins = {
				"gre_m79_burn",
				"b682_burn",
				"g3_burn",
				"mp9_burn",
				"hs2000_burn",
				"hunter_burn",
				"benelli_burn",
				"sparrow_burn",
				"m37_burn",
				"spas12_burn",
				"fal_burn",
				"glock_18c_burn",
				"uzi_burn",
				"glock_17_burn",
				"scorpion_burn"
			},
			contents = {
				"burn_01_legendary"
			}
		}
	}
	self.contents.burn_01_legendary = {
		def_id = 10021,
		contains = {
			weapon_skins = {
				"judge_burn"
			}
		},
		rarity = "legendary"
	}
	self.contents.buck_01 = {
		def_id = 10022,
		contains = {
			weapon_skins = {
				"wa2000_buck",
				"akmsu_buck",
				"x_1911_buck",
				"rpk_buck",
				"x_b92fs_buck",
				"ksg_buck",
				"m249_buck",
				"g22c_buck",
				"saw_buck",
				"winchester1874_buck",
				"m45_buck",
				"saiga_buck",
				"p226_buck",
				"new_mp5_buck",
				"m1928_buck"
			},
			contents = {
				"buck_01_legendary"
			}
		}
	}
	self.contents.buck_01_legendary = {
		def_id = 10023,
		contains = {
			weapon_skins = {
				"boot_buck"
			}
		},
		rarity = "legendary"
	}
	self.contents.same_01 = {
		def_id = 10024,
		contains = {
			weapon_skins = {
				"amcar_same",
				"usp_same",
				"gre_m79_same",
				"deagle_same",
				"colt_1911_same",
				"b92fs_same",
				"judge_same",
				"p90_same",
				"akm_same",
				"ak5_same",
				"baka_same",
				"model70_same",
				"new_raging_bull_same",
				"new_m14_same",
				"par_same"
			},
			contents = {
				"same_01_legendary"
			}
		}
	}
	self.contents.same_01_legendary = {
		def_id = 10025,
		contains = {
			weapon_skins = {
				"ksg_same"
			}
		},
		rarity = "legendary"
	}
	self.bundles.same_01 = {
		def_id = 30000,
		dlc_id = "518760",
		quality = "mint",
		bonus = false,
		contains = {
			weapon_skins = {
				"amcar_same",
				"usp_same",
				"gre_m79_same",
				"deagle_same",
				"colt_1911_same",
				"b92fs_same",
				"judge_same",
				"p90_same",
				"akm_same",
				"ak5_same",
				"baka_same",
				"model70_same",
				"new_raging_bull_same",
				"new_m14_same",
				"par_same",
				"ksg_same"
			}
		}
	}
	self.contents.grunt_01 = {
		def_id = 10026,
		contains = {
			weapon_skins = {
				"saiga_grunt",
				"m1928_grunt",
				"m45_grunt",
				"p226_grunt",
				"new_mp5_grunt",
				"wa2000_grunt",
				"boot_grunt",
				"g22c_grunt",
				"m249_grunt",
				"ksg_grunt",
				"winchester1874_grunt",
				"rpk_grunt",
				"x_b92fs_grunt",
				"akmsu_grunt",
				"x_1911_grunt"
			},
			contents = {
				"grunt_01_legendary"
			}
		}
	}
	self.contents.grunt_01_legendary = {
		def_id = 10027,
		contains = {
			weapon_skins = {
				"tecci_grunt"
			}
		},
		rarity = "legendary"
	}
	self.contents.lones_01 = {
		def_id = 10028,
		contains = {
			weapon_skins = {
				"x_mp5_lones",
				"sparrow_lones",
				"china_lones",
				"akmsu_lones",
				"par_lones",
				"model70_lones",
				"judge_lones"
			},
			contents = {
				"lones_01_legendary",
				"lones_01_legendary_02"
			}
		},
		type = "crimefest"
	}
	self.contents.lones_01_legendary = {
		def_id = 10029,
		contains = {
			weapon_skins = {
				"serbu_lones"
			}
		},
		rarity = "legendary"
	}
	self.contents.lones_01_legendary_02 = {
		def_id = 10030,
		contains = {
			weapon_skins = {
				"new_m14_lones"
			}
		},
		rarity = "legendary"
	}
	self.contents.smosh_01 = {
		def_id = 10031,
		contains = {
			weapon_skins = {
				"scar_smosh",
				"colt_1911_smosh",
				"scorpion_smosh",
				"deagle_smosh",
				"r870_smosh",
				"m32_smosh",
				"x_1911_smosh",
				"hs2000_smosh",
				"saw_smosh",
				"m37_smosh",
				"m1928_smosh",
				"mateba_smosh",
				"polymer_smosh",
				"new_m4_smosh",
				"aug_smosh"
			},
			contents = {
				"smosh_01_legendary"
			}
		}
	}
	self.contents.smosh_01_legendary = {
		def_id = 10032,
		contains = {
			weapon_skins = {
				"new_raging_bull_smosh"
			}
		},
		rarity = "legendary"
	}
	self.bundles.smosh_01 = {
		def_id = 30001,
		dlc_id = "558270",
		quality = "mint",
		bonus = false,
		contains = {
			weapon_skins = {
				"scar_smosh",
				"colt_1911_smosh",
				"scorpion_smosh",
				"deagle_smosh",
				"r870_smosh",
				"m32_smosh",
				"x_1911_smosh",
				"hs2000_smosh",
				"saw_smosh",
				"m37_smosh",
				"m1928_smosh",
				"mateba_smosh",
				"polymer_smosh",
				"new_m4_smosh",
				"aug_smosh",
				"new_raging_bull_smosh"
			}
		}
	}
	self.contents.sfs_01 = {
		def_id = 10033,
		contains = {
			weapon_skins = {
				"peacemaker_sfs",
				"x_akmsu_sfs",
				"china_sfs",
				"olympic_sfs",
				"desertfox_sfs",
				"msr_sfs",
				"hk21_sfs",
				"m16_sfs",
				"uzi_sfs",
				"spas12_sfs",
				"mateba_sfs",
				"colt_1911_sfs",
				"r870_sfs",
				"mac10_sfs",
				"galil_sfs"
			},
			contents = {
				"sfs_01_legendary"
			}
		}
	}
	self.contents.sfs_01_legendary = {
		def_id = 10034,
		contains = {
			weapon_skins = {
				"contraband_sfs"
			}
		},
		rarity = "legendary"
	}
	self.contents.wac_01 = {
		def_id = 10035,
		contains = {
			weapon_skins = {
				"mateba_wac",
				"c96_wac",
				"ksg_wac",
				"glock_18c_wac",
				"galil_wac",
				"spas12_wac",
				"amcar_wac",
				"aa12_wac",
				"mp9_wac",
				"desertfox_wac",
				"vhs_wac",
				"mp7_wac",
				"g26_wac",
				"x_mp5_wac",
				"msr_wac"
			},
			contents = {
				"wac_01_legendary"
			}
		}
	}
	self.contents.wac_01_legendary = {
		def_id = 10036,
		contains = {
			weapon_skins = {
				"x_akmsu_wac"
			}
		},
		rarity = "legendary"
	}
	self.contents.cs3_01 = {
		def_id = 10037,
		contains = {
			weapon_skins = {
				"judge_cs3",
				"m95_cs3",
				"peacemaker_cs3",
				"arbiter_cs3",
				"flint_cs3",
				"aa12_cs3",
				"new_mp5_cs3",
				"saw_cs3",
				"frankish_cs3",
				"new_m4_cs3",
				"sparrow_cs3",
				"tti_cs3",
				"new_raging_bull_cs3",
				"huntsman_cs3",
				"polymer_cs3"
			},
			contents = {
				"cs3_01_legendary"
			}
		}
	}
	self.contents.cs3_01_legendary = {
		def_id = 10038,
		contains = {
			weapon_skins = {
				"ppk_cs3"
			}
		},
		rarity = "legendary"
	}
	self.bundles.cs3_01 = {
		def_id = 30002,
		dlc_id = "627400",
		quality = "mint",
		bonus = false,
		contains = {
			weapon_skins = {
				"judge_cs3",
				"m95_cs3",
				"peacemaker_cs3",
				"arbiter_cs3",
				"flint_cs3",
				"aa12_cs3",
				"new_mp5_cs3",
				"saw_cs3",
				"frankish_cs3",
				"new_m4_cs3",
				"sparrow_cs3",
				"tti_cs3",
				"new_raging_bull_cs3",
				"huntsman_cs3",
				"ppk_cs3",
				"polymer_cs3"
			}
		}
	}
	self.contents.cvc_01 = {
		def_id = 10039,
		contains = {
			armor_skins = {
				"cvc_woodland_camo",
				"cvc_city_camo",
				"cvc_desert_camo",
				"cvc_avenger",
				"cvc_swat",
				"cvc_bone"
			},
			contents = {}
		}
	}
	self.contents.mxs_01 = {
		def_id = 10040,
		contains = {
			weapon_skins = {
				"x_usp_mxs",
				"x_deagle_mxs",
				"amcar_mxs",
				"tec9_mxs",
				"striker_mxs",
				"siltstone_mxs",
				"scar_mxs",
				"rota_mxs",
				"par_mxs",
				"lemming_mxs",
				"jowi_mxs",
				"contraband_mxs",
				"chinchilla_mxs",
				"china_mxs",
				"akm_mxs"
			},
			contents = {
				"mxs_01_legendary"
			}
		}
	}
	self.contents.mxs_01_legendary = {
		def_id = 10041,
		contains = {
			weapon_skins = {
				"x_chinchilla_mxs"
			}
		},
		rarity = "legendary"
	}
	self.contents.cs4_01 = {
		def_id = 10042,
		contains = {
			weapon_skins = {
				"polymer_cs4",
				"l85a2_cs4",
				"amcar_cs4",
				"usp_cs4",
				"m16_cs4",
				"benelli_cs4",
				"wa2000_cs4",
				"serbu_cs4",
				"arbiter_cs4",
				"flint_cs4",
				"chinchilla_cs4",
				"rpg7_cs4",
				"mac10_cs4",
				"new_raging_bull_cs4",
				"striker_cs4"
			},
			contents = {
				"cs4_01_legendary"
			}
		}
	}
	self.contents.cs4_01_legendary = {
		def_id = 10043,
		contains = {
			weapon_skins = {
				"p90_cs4"
			}
		},
		rarity = "legendary"
	}
	self.bundles.cs4_01 = {
		def_id = 30003,
		dlc_id = "694940",
		quality = "mint",
		bonus = false,
		contains = {
			weapon_skins = {
				"polymer_cs4",
				"l85a2_cs4",
				"amcar_cs4",
				"usp_cs4",
				"m16_cs4",
				"benelli_cs4",
				"wa2000_cs4",
				"serbu_cs4",
				"arbiter_cs4",
				"flint_cs4",
				"chinchilla_cs4",
				"rpg7_cs4",
				"mac10_cs4",
				"new_raging_bull_cs4",
				"striker_cs4",
				"p90_cs4"
			}
		}
	}
	self.contents.ast_01 = {
		def_id = 10044,
		contains = {
			armor_skins = {
				"ast_armor1",
				"ast_armor2",
				"ast_armor3",
				"ast_armor4",
				"ast_armor5",
				"ast_armor6"
			},
			contents = {}
		}
	}
	self.contents.wwt_01 = {
		def_id = 10045,
		contains = {
			weapon_skins = {
				"m1928_wwt",
				"b682_wwt",
				"flamethrower_mk2_wwt",
				"sterling_wwt",
				"peacemaker_wwt",
				"erma_wwt",
				"ching_wwt",
				"m37_wwt",
				"breech_wwt",
				"mg42_wwt"
			},
			contents = {
				"wwt_01_legendary"
			}
		}
	}
	self.contents.wwt_01_legendary = {
		def_id = 10046,
		contains = {
			weapon_skins = {
				"colt_1911_wwt"
			}
		},
		rarity = "legendary"
	}
	self.contents.skf_01 = {
		def_id = 10047,
		contains = {
			weapon_skins = {
				"new_m4_skf",
				"p226_skf",
				"amcar_skf",
				"ppk_skf",
				"aug_skf",
				"lemming_skf",
				"g26_skf",
				"ching_skf",
				"mp7_skf",
				"ray_skf",
				"b682_skf",
				"ak5_skf",
				"scar_skf",
				"famas_skf",
				"g36_skf"
			},
			contents = {
				"skf_01_legendary"
			}
		}
	}
	self.contents.skf_01_legendary = {
		def_id = 10048,
		contains = {
			weapon_skins = {
				"mac10_skf"
			}
		},
		rarity = "legendary"
	}
	self.bundles.skf_01 = {
		def_id = 30004,
		dlc_id = "729560",
		quality = "mint",
		bonus = false,
		contains = {
			weapon_skins = {
				"new_m4_skf",
				"p226_skf",
				"amcar_skf",
				"ppk_skf",
				"aug_skf",
				"lemming_skf",
				"g26_skf",
				"ching_skf",
				"mp7_skf",
				"ray_skf",
				"b682_skf",
				"ak5_skf",
				"scar_skf",
				"famas_skf",
				"g36_skf",
				"mac10_skf"
			}
		}
	}
	self.contents.cas_01 = {
		def_id = 10049,
		contains = {
			armor_skins = {
				"cas_m90",
				"cas_police",
				"cas_miami",
				"cas_slayer",
				"cas_trash",
				"cas_gensec"
			},
			contents = {}
		}
	}
	self.bundles.cas_01 = {
		def_id = 30005,
		dlc_id = "763390",
		contains = {
			armor_skins = {
				"cas_m90",
				"cas_police",
				"cas_miami",
				"cas_slayer",
				"cas_trash",
				"cas_gensec"
			}
		}
	}
	self.contents.css_01 = {
		def_id = 10050,
		contains = {
			weapon_skins = {
				"x_1911_css",
				"contraband_css",
				"par_css",
				"breech_css",
				"c96_css",
				"m95_css",
				"m37_css",
				"sparrow_css",
				"g26_css",
				"flint_css",
				"coal_css",
				"r93_css",
				"ching_css",
				"lemming_css",
				"ppk_css"
			},
			contents = {
				"css_01_legendary"
			}
		}
	}
	self.contents.css_01_legendary = {
		def_id = 10051,
		contains = {
			weapon_skins = {
				"polymer_css"
			}
		},
		rarity = "legendary"
	}
	self.bundles.css_01 = {
		def_id = 30006,
		dlc_id = "802500",
		quality = "mint",
		bonus = false,
		contains = {
			weapon_skins = table.list_add(self.contents.css_01.contains.weapon_skins, self.contents.css_01_legendary.contains.weapon_skins)
		}
	}
	self.contents.dss_01 = {
		def_id = 10052,
		contains = {
			weapon_skins = {
				"gre_m79_dss",
				"erma_dss",
				"boot_dss",
				"m1928_dss",
				"peacemaker_dss",
				"m45_dss",
				"x_shrew_dss",
				"mg42_dss",
				"ching_dss",
				"colt_1911_dss",
				"chinchilla_dss",
				"c96_dss",
				"winchester1874_dss",
				"huntsman_dss",
				"b682_dss"
			},
			contents = {
				"dss_01_legendary"
			}
		}
	}
	self.contents.dss_01_legendary = {
		def_id = 10053,
		contains = {
			weapon_skins = {
				"shrew_dss"
			}
		},
		rarity = "legendary"
	}
	self.contents.cat_01 = {
		def_id = 10054,
		contains = {
			weapon_skins = {
				"mp7_cat",
				"x_coal_cat",
				"m16_cat",
				"scar_cat",
				"deagle_cat",
				"p90_cat",
				"ksg_cat",
				"serbu_cat",
				"x_judge_cat",
				"new_mp5_cat",
				"x_chinchilla_cat",
				"boot_cat",
				"erma_cat",
				"x_usp_cat",
				"usp_cat"
			},
			contents = {
				"cat_01_legendary"
			}
		}
	}
	self.contents.cat_01_legendary = {
		def_id = 10055,
		contains = {
			weapon_skins = {
				"p226_cat"
			}
		},
		rarity = "legendary"
	}
	self.bundles.cat_01 = {
		def_id = 30007,
		dlc_id = "892410",
		quality = "mint",
		bonus = false,
		contains = {
			weapon_skins = table.list_add(self.contents.cat_01.contains.weapon_skins, self.contents.cat_01_legendary.contains.weapon_skins)
		}
	}
	self.contents.ait_01 = {
		def_id = 10056,
		contains = {
			weapon_skins = {
				"lemming_ait",
				"b92fs_ait",
				"sub2000_ait",
				"deagle_ait",
				"elastic_ait",
				"slap_ait",
				"m16_ait",
				"system_ait",
				"mac10_ait",
				"polymer_ait",
				"spas12_ait",
				"rota_ait",
				"komodo_ait",
				"tecci_ait",
				"uzi_ait"
			},
			contents = {
				"ait_01_legendary"
			}
		}
	}
	self.contents.ait_01_legendary = {
		def_id = 10057,
		contains = {
			weapon_skins = {
				"scar_ait"
			}
		},
		rarity = "legendary"
	}
	self.bundles.ait_01 = {
		def_id = 30008,
		dlc_id = "892410",
		quality = "mint",
		bonus = false,
		contains = {
			weapon_skins = table.list_add(self.contents.ait_01.contains.weapon_skins, self.contents.ait_01_legendary.contains.weapon_skins)
		}
	}
	self.safes.overkill_01 = {
		def_id = 50000,
		promo = true,
		drill = "overkill_01",
		content = "overkill_01",
		unit_name = "units/payday2_cash/safes/eco_safe_overkill_01/eco_safe_overkill_01",
		name_id = "bm_menu_safe_overkill_01",
		texture_bundle_folder = "cash/safes/cop",
		dlc = "complete_overkill_pack"
	}
	self.safes.event_01 = {
		drill = "event_01",
		content = "event_01",
		unit_name = "units/payday2_cash/safes/eco_safe_event_01/eco_safe_event_01",
		name_id = "bm_menu_safe_event_01",
		texture_bundle_folder = "cash/safes/cf15",
		market_link = "https://steamcommunity.com/market/listings/218620/Crimefest%202%20Safe"
	}
	self.safes.weapon_01 = {
		drill = "weapon_01",
		content = "weapon_01",
		unit_name = "units/payday2_cash/safes/eco_safe_weapon_01/eco_safe_weapon_01",
		name_id = "bm_menu_safe_weapon_01",
		texture_bundle_folder = "cash/safes/sputnik",
		market_link = "https://steamcommunity.com/market/listings/218620/Sputnik%20Safe"
	}
	self.safes.event_red = {
		def_id = 50003,
		free = true,
		drill = "event_red",
		content = "event_red",
		unit_name = "units/payday2_cash/safes/red/safe/eco_safe_event_red",
		name_id = "bm_menu_safe_event_red",
		texture_bundle_folder = "cash/safes/red",
		achievement = "green_7",
		market_link = "http://steamcommunity.com/market/listings/218620/First%20World%20Safe"
	}
	self.safes.event_dinner = {
		def_id = 50004,
		free = true,
		drill = "event_dinner",
		content = "event_dinner",
		unit_name = "units/payday2_cash/safes/dinner/safe/eco_safe_event_dinner",
		name_id = "bm_menu_safe_event_dinner",
		texture_bundle_folder = "cash/safes/dinner",
		achievement = "farm_6",
		market_link = "http://steamcommunity.com/market/listings/218620/Slaughter%20Safe"
	}
	self.safes.dallas_01 = {
		drill = "dallas_01",
		content = "dallas_01",
		name_id = "bm_menu_safe_dallas_01",
		unit_name = "units/payday2_cash/safes/dallas/safe/eco_safe_dallas",
		texture_bundle_folder = "cash/safes/dallas",
		market_link = "https://steamcommunity.com/market/listings/218620/Dallas%20Safe"
	}
	self.safes.surf_01 = {
		drill = "surf_01",
		content = "surf_01",
		name_id = "bm_menu_safe_surf_01",
		unit_name = "units/payday2_cash/safes/surf/safe/eco_safe_surf",
		texture_bundle_folder = "cash/safes/surf",
		market_link = "https://steamcommunity.com/market/listings/218620/Bodhi%20Safe"
	}
	self.safes.event_flake = {
		def_id = 50007,
		free = true,
		drill = "event_flake",
		content = "event_flake",
		name_id = "bm_menu_safe_event_flake",
		unit_name = "units/payday2_cash/safes/flake/safe/eco_safe_event_flake",
		texture_bundle_folder = "cash/safes/flake",
		achievement = "flake_1",
		market_link = "http://steamcommunity.com/market/listings/218620/Christmas%20Safe"
	}
	self.safes.event_bah = {
		def_id = 50008,
		free = true,
		drill = "event_bah",
		content = "event_bah",
		unit_name = "units/payday2_cash/safes/bah/safe/eco_safe_bah",
		name_id = "bm_menu_safe_event_bah",
		texture_bundle_folder = "cash/safes/bah",
		achievement = "bah_1",
		market_link = "http://steamcommunity.com/market/listings/218620/Goat%20Safe"
	}
	self.safes.pack_01 = {
		drill = "pack_01",
		content = "pack_01",
		name_id = "bm_menu_safe_pack_01",
		unit_name = "units/payday2_cash/safes/pack/safe/eco_safe_pack",
		texture_bundle_folder = "cash/safes/pack",
		market_link = "https://steamcommunity.com/market/listings/218620/Wolf%20Safe"
	}
	self.safes.cola_01 = {
		drill = "cola_01",
		content = "cola_01",
		name_id = "bm_menu_safe_cola_01",
		unit_name = "units/payday2_cash/safes/cola/safe/eco_safe_cola",
		texture_bundle_folder = "cash/safes/cola",
		market_link = "https://steamcommunity.com/market/listings/218620/Jimmy%20Safe"
	}
	self.safes.burn_01 = {
		drill = "burn_01",
		content = "burn_01",
		name_id = "bm_menu_safe_burn_01",
		unit_name = "units/payday2_cash/safes/burn/safe/eco_safe_burn",
		texture_bundle_folder = "cash/safes/burn",
		market_link = "https://steamcommunity.com/market/listings/218620/Sydney%20Safe"
	}
	self.safes.buck_01 = {
		free = true,
		drill = "buck_01",
		content = "buck_01",
		name_id = "bm_menu_safe_buck_01",
		unit_name = "units/payday2_cash/safes/buck/safe/eco_safe_buck",
		texture_bundle_folder = "cash/safes/buck",
		market_link = "https://steamcommunity.com/market/listings/218620/Biker%20Safe"
	}
	self.safes.same_01 = {
		free = true,
		drill = "same_01",
		content = "same_01",
		bundle = "same_01",
		name_id = "bm_menu_safe_same_01",
		unit_name = "units/payday2_cash/safes/same/safe/eco_safe_same",
		texture_bundle_folder = "cash/safes/same",
		market_link = "https://steamcommunity.com/market/listings/218620/Community%20Safe"
	}
	self.safes.grunt_01 = {
		free = true,
		drill = "grunt_01",
		content = "grunt_01",
		name_id = "bm_menu_safe_grunt_01",
		unit_name = "units/payday2_cash/safes/grunt/safe/eco_safe_grunt",
		texture_bundle_folder = "cash/safes/grunt",
		market_link = "https://steamcommunity.com/market/listings/218620/Chains%20Safe"
	}
	self.safes.lones_01 = {
		free = true,
		drill = "lones_01",
		content = "lones_01",
		name_id = "bm_menu_safe_lones_01",
		unit_name = "units/payday2_cash/safes/lones/safe/eco_safe_lones",
		texture_bundle_folder = "cash/safes/lones",
		market_link = "https://steamcommunity.com/market/listings/218620/Hoxton%20Safe"
	}
	self.safes.smosh_01 = {
		free = true,
		drill = "smosh_01",
		content = "smosh_01",
		bundle = "smosh_01",
		name_id = "bm_menu_safe_smosh_01",
		unit_name = "units/payday2_cash/safes/smosh/safe/eco_safe_smosh",
		texture_bundle_folder = "cash/safes/smosh",
		market_link = "https://steamcommunity.com/market/listings/218620/Community%20Safe%202"
	}
	self.safes.sfs_01 = {
		free = true,
		drill = "sfs_01",
		content = "sfs_01",
		name_id = "bm_menu_safe_sfs_01",
		unit_name = "units/payday2_cash/safes/sfs/safe/eco_safe_sfs",
		texture_bundle_folder = "cash/safes/sfs",
		market_link = "https://steamcommunity.com/market/listings/218620/Scarface%20Safe"
	}
	self.safes.wac_01 = {
		free = true,
		drill = "wac_01",
		content = "wac_01",
		name_id = "bm_menu_safe_wac_01",
		unit_name = "units/payday2_cash/safes/wac/safe/eco_safe_wac",
		texture_bundle_folder = "cash/safes/wac",
		market_link = "https://steamcommunity.com/market/listings/218620/John%20Wick%20Safe"
	}
	self.safes.cs3_01 = {
		free = true,
		drill = "cs3_01",
		content = "cs3_01",
		bundle = "cs3_01",
		name_id = "bm_menu_safe_cs3_01",
		unit_name = "units/payday2_cash/safes/cs3/safe/eco_safe_cs3",
		texture_bundle_folder = "cash/safes/cs3",
		market_link = "https://steamcommunity.com/market/listings/218620/Community%20Safe%203"
	}
	self.safes.cvc_01 = {
		free = true,
		drill = "cvc_01",
		content = "cvc_01",
		name_id = "bm_menu_safe_cvc_01",
		unit_name = "units/payday2_cash/safes/cvc/safe/eco_safe_cvc",
		texture_bundle_folder = "cash/safes/cvc",
		market_link = "https://steamcommunity.com/market/listings/218620/Armor%20Safe"
	}
	self.safes.mxs_01 = {
		free = true,
		drill = "mxs_01",
		content = "mxs_01",
		name_id = "bm_menu_safe_mxs_01",
		unit_name = "units/payday2_cash/safes/mxs/safe/eco_safe_mxs",
		texture_bundle_folder = "cash/safes/mxs",
		market_link = "https://steamcommunity.com/market/listings/218620/Sangres%20Safe"
	}
	self.safes.cs4_01 = {
		free = true,
		drill = "cs4_01",
		content = "cs4_01",
		bundle = "cs4_01",
		name_id = "bm_menu_safe_cs4_01",
		unit_name = "units/payday2_cash/safes/cs4/safe/eco_safe_cs4",
		texture_bundle_folder = "cash/safes/cs4",
		market_link = "https://steamcommunity.com/market/listings/218620/Community%20Safe%204"
	}
	self.safes.ast_01 = {
		free = true,
		drill = "ast_01",
		content = "ast_01",
		name_id = "bm_menu_safe_ast_01",
		unit_name = "units/payday2_cash/safes/ast/safe/eco_safe_ast",
		texture_bundle_folder = "cash/safes/ast",
		market_link = "https://steamcommunity.com/market/listings/218620/Armor%20Safe%202%3A%20WW2"
	}
	self.safes.wwt_01 = {
		free = true,
		drill = "wwt_01",
		content = "wwt_01",
		name_id = "bm_menu_safe_wwt_01",
		unit_name = "units/payday2_cash/safes/wwt/safe/eco_safe_wwt",
		texture_bundle_folder = "cash/safes/wwt",
		market_link = "https://steamcommunity.com/market/listings/218620/Aldstone%27s%20Heritage%20Safe"
	}
	self.safes.skf_01 = {
		free = true,
		drill = "skf_01",
		content = "skf_01",
		bundle = "skf_01",
		name_id = "bm_menu_safe_skf_01",
		unit_name = "units/payday2_cash/safes/skf/safe/eco_safe_skf",
		texture_bundle_folder = "cash/safes/skf",
		market_link = "https://steamcommunity.com/market/listings/218620/Community%20Safe%205"
	}
	self.safes.cas_01 = {
		free = true,
		drill = "cas_01",
		content = "cas_01",
		bundle = "cas_01",
		name_id = "bm_menu_safe_cas_01",
		unit_name = "units/payday2_cash/safes/cas/safe/eco_safe_cas",
		texture_bundle_folder = "cash/safes/cas",
		market_link = "https://steamcommunity.com/market/listings/218620/Community%20Armor%20Safe%201"
	}
	self.safes.css_01 = {
		free = true,
		drill = "css_01",
		content = "css_01",
		bundle = "css_01",
		name_id = "bm_menu_safe_css_01",
		unit_name = "units/payday2_cash/safes/css/safe/eco_safe_css",
		texture_bundle_folder = "cash/safes/css",
		market_link = "https://steamcommunity.com/market/listings/218620/Community%20Safe%206"
	}
	self.safes.dss_01 = {
		free = true,
		drill = "dss_01",
		content = "dss_01",
		name_id = "bm_menu_safe_dss_01",
		unit_name = "units/payday2_cash/safes/dss/safe/eco_safe_dss",
		texture_bundle_folder = "cash/safes/dss",
		market_link = "https://steamcommunity.com/market/listings/218620/Duke%20Safe"
	}
	self.safes.cat_01 = {
		free = true,
		drill = "cat_01",
		content = "cat_01",
		bundle = "cat_01",
		name_id = "bm_menu_safe_cat_01",
		unit_name = "units/payday2_cash/safes/cat/safe/eco_safe_cat",
		texture_bundle_folder = "cash/safes/cat",
		market_link = "https://steamcommunity.com/market/listings/218620/Community%20Safe%207"
	}
	self.safes.ait_01 = {
		free = true,
		drill = "ait_01",
		content = "ait_01",
		bundle = "ait_01",
		name_id = "bm_menu_safe_ait_01",
		unit_name = "units/payday2_cash/safes/ait/safe/eco_safe_ait",
		texture_bundle_folder = "cash/safes/ait",
		market_link = "https://steamcommunity.com/market/listings/218620/Community%20Safe%208"
	}
	self.drills.overkill_01 = {
		safe = "overkill_01",
		def_id = 70000,
		promo = true,
		unit_name = "units/payday2_cash/drills/eco_drill_overkill_01/eco_drill_overkill_01",
		name_id = "bm_menu_drill_overkill_01",
		desc_id = "bm_menu_drill_overkill_01_desc",
		texture_bundle_folder = "cash/safes/cop",
		dlc = "complete_overkill_pack"
	}
	self.drills.event_01 = {
		safe = "event_01",
		def_id = 70001,
		price = "2.49",
		unit_name = "units/payday2_cash/drills/eco_drill_event_01/eco_drill_event_01",
		name_id = "bm_menu_drill_event_01",
		desc_id = "bm_menu_drill_event_01_desc",
		texture_bundle_folder = "cash/safes/cf15"
	}
	self.drills.weapon_01 = {
		safe = "weapon_01",
		def_id = 70002,
		price = "2.49",
		unit_name = "units/payday2_cash/drills/eco_drill_weapon_01/eco_drill_weapon_01",
		name_id = "bm_menu_drill_weapon_01",
		desc_id = "bm_menu_drill_weapon_01_desc",
		texture_bundle_folder = "cash/safes/sputnik"
	}
	self.drills.event_red = {
		safe = "event_red",
		def_id = 70003,
		force_include = true,
		unit_name = "units/payday2_cash/safes/red/drill/eco_drill_event_red",
		name_id = "bm_menu_drill_event_red",
		desc_id = "bm_menu_drill_event_red_desc",
		texture_bundle_folder = "cash/safes/red",
		achievement = "green_7"
	}
	self.drills.event_dinner = {
		def_id = 70004,
		safe = "event_dinner",
		force_include = true,
		unit_name = "units/payday2_cash/safes/dinner/drill/eco_drill_event_dinner",
		name_id = "bm_menu_drill_event_dinner",
		desc_id = "bm_menu_drill_event_dinner_desc",
		texture_bundle_folder = "cash/safes/dinner",
		achievement = "farm_6"
	}
	self.drills.dallas_01 = {
		safe = "dallas_01",
		def_id = 70005,
		price = "2.49",
		name_id = "bm_menu_drill_dallas_01",
		desc_id = "bm_menu_drill_dallas_01_desc",
		unit_name = "units/payday2_cash/safes/dallas/drill/eco_drill_dallas",
		texture_bundle_folder = "cash/safes/dallas"
	}
	self.drills.surf_01 = {
		def_id = 70006,
		safe = "surf_01",
		price = "2.49",
		unit_name = "units/payday2_cash/safes/surf/drill/eco_drill_surf",
		name_id = "bm_menu_drill_surf",
		desc_id = "bm_menu_drill_surf_desc",
		texture_bundle_folder = "cash/safes/surf"
	}
	self.drills.event_flake = {
		def_id = 70007,
		safe = "event_flake",
		force_include = true,
		unit_name = "units/payday2_cash/safes/flake/drill/eco_drill_flake",
		name_id = "bm_menu_drill_event_flake",
		desc_id = "bm_menu_drill_event_flake_desc",
		texture_bundle_folder = "cash/safes/flake",
		achievement = "flake_1"
	}
	self.drills.event_bah = {
		def_id = 70008,
		safe = "event_bah",
		force_include = true,
		unit_name = "units/payday2_cash/safes/bah/drill/eco_drill_bah",
		name_id = "bm_menu_drill_event_bah",
		desc_id = "bm_menu_drill_event_bah_desc",
		texture_bundle_folder = "cash/safes/bah",
		achievement = "bah_1"
	}
	self.drills.pack_01 = {
		safe = "pack_01",
		def_id = 70009,
		price = "2.49",
		name_id = "bm_menu_drill_pack_01",
		desc_id = "bm_menu_drill_pack_01_desc",
		unit_name = "units/payday2_cash/safes/pack/drill/eco_drill_pack",
		texture_bundle_folder = "cash/safes/pack"
	}
	self.drills.cola_01 = {
		safe = "cola_01",
		def_id = 70010,
		price = "2.49",
		name_id = "bm_menu_drill_cola_01",
		desc_id = "bm_menu_drill_cola_01_desc",
		unit_name = "units/payday2_cash/safes/cola/drill/eco_drill_cola",
		texture_bundle_folder = "cash/safes/cola"
	}
	self.drills.burn_01 = {
		safe = "burn_01",
		def_id = 70011,
		price = "2.49",
		name_id = "bm_menu_drill_burn_01",
		desc_id = "bm_menu_drill_burn_01_desc",
		unit_name = "units/payday2_cash/safes/burn/drill/eco_drill_burn",
		texture_bundle_folder = "cash/safes/burn"
	}
	self.drills.buck_01 = {
		safe = "buck_01",
		unit_name = "units/payday2_cash/safes/buck/drill/eco_drill_buck"
	}
	self.drills.same_01 = {
		safe = "same_01",
		unit_name = "units/payday2_cash/safes/same/drill/eco_drill_same"
	}
	self.drills.grunt_01 = {
		safe = "grunt_01",
		unit_name = "units/payday2_cash/safes/grunt/drill/eco_drill_grunt"
	}
	self.drills.lones_01 = {
		safe = "lones_01",
		unit_name = "units/payday2_cash/safes/lones/drill/eco_drill_lones"
	}
	self.drills.smosh_01 = {
		safe = "smosh_01",
		unit_name = "units/payday2_cash/safes/smosh/drill/eco_drill_smosh"
	}
	self.drills.sfs_01 = {
		safe = "sfs_01",
		unit_name = "units/payday2_cash/safes/sfs/drill/eco_drill_sfs"
	}
	self.drills.wac_01 = {
		safe = "wac_01",
		unit_name = "units/payday2_cash/safes/wac/drill/eco_drill_wac"
	}
	self.drills.cs3_01 = {
		safe = "cs3_01",
		unit_name = "units/payday2_cash/safes/cs3/drill/eco_drill_cs3"
	}
	self.drills.cvc_01 = {
		safe = "cvc_01",
		unit_name = "units/payday2_cash/safes/cvc/drill/eco_drill_cvc"
	}
	self.drills.mxs_01 = {
		safe = "mxs_01",
		unit_name = "units/payday2_cash/safes/mxs/drill/eco_drill_mxs"
	}
	self.drills.cs4_01 = {
		safe = "cs4_01",
		unit_name = "units/payday2_cash/safes/cs4/drill/eco_drill_cs4"
	}
	self.drills.ast_01 = {
		safe = "ast_01",
		unit_name = "units/payday2_cash/safes/ast/drill/eco_drill_ast"
	}
	self.drills.wwt_01 = {
		safe = "wwt_01",
		unit_name = "units/payday2_cash/safes/wwt/drill/eco_drill_wwt"
	}
	self.drills.skf_01 = {
		safe = "skf_01",
		unit_name = "units/payday2_cash/safes/skf/drill/eco_drill_skf"
	}
	self.drills.cas_01 = {
		safe = "cas_01",
		unit_name = "units/payday2_cash/safes/cas/drill/eco_drill_cas"
	}
	self.drills.css_01 = {
		safe = "css_01",
		unit_name = "units/payday2_cash/safes/css/drill/eco_drill_css"
	}
	self.drills.dss_01 = {
		safe = "dss_01",
		unit_name = "units/payday2_cash/safes/dss/drill/eco_drill_dss"
	}
	self.drills.cat_01 = {
		safe = "cat_01",
		unit_name = "units/payday2_cash/safes/cat/drill/eco_drill_cat"
	}
	self.drills.ait_01 = {
		safe = "ait_01",
		unit_name = "units/payday2_cash/safes/ait/drill/eco_drill_ait"
	}
	self.bonuses = {
		concealment_p1 = {}
	}
	self.bonuses.concealment_p1.name_id = "bm_menu_bonus_concealment"
	self.bonuses.concealment_p1.stats = {
		concealment = 1
	}
	self.bonuses.concealment_p2 = {
		name_id = "bm_menu_bonus_concealment",
		stats = {
			concealment = 2
		}
	}
	self.bonuses.concealment_p3 = {
		name_id = "bm_menu_bonus_concealment",
		stats = {
			concealment = 3
		}
	}
	self.bonuses.spread_p1 = {
		name_id = "bm_menu_bonus_spread",
		stats = {
			spread = 1
		}
	}
	self.bonuses.spread_n1 = {
		name_id = "bm_menu_bonus_spread",
		stats = {
			spread = -1
		}
	}
	self.bonuses.recoil_p1 = {
		name_id = "bm_menu_bonus_recoil",
		stats = {
			recoil = 1
		}
	}
	self.bonuses.recoil_p2 = {
		name_id = "bm_menu_bonus_recoil",
		stats = {
			recoil = 2
		}
	}
	self.bonuses.damage_p1 = {
		name_id = "bm_menu_bonus_damage",
		stats = {
			damage = 1
		}
	}
	self.bonuses.damage_p2 = {
		name_id = "bm_menu_bonus_damage",
		stats = {
			damage = 2
		}
	}
	self.bonuses.total_ammo_p1 = {
		name_id = "bm_menu_bonus_total_ammo",
		stats = {
			total_ammo_mod = 1
		}
	}
	self.bonuses.total_ammo_p3 = {
		name_id = "bm_menu_bonus_total_ammo",
		stats = {
			total_ammo_mod = 3
		}
	}
	self.bonuses.concealment_p1_tem_p1 = {
		name_id = "bm_menu_bonus_concealment_tem",
		stats = {
			concealment = 1
		},
		exp_multiplier = 1.01,
		money_multiplier = 1.01
	}
	self.bonuses.concealment_p2_tem_p1 = {
		name_id = "bm_menu_bonus_concealment_tem",
		stats = {
			concealment = 2
		},
		exp_multiplier = 1.01,
		money_multiplier = 1.01
	}
	self.bonuses.concealment_p3_tem_p1 = {
		name_id = "bm_menu_bonus_concealment_tem",
		stats = {
			concealment = 3
		},
		exp_multiplier = 1.01,
		money_multiplier = 1.01
	}
	self.bonuses.spread_p1_tem_p1 = {
		name_id = "bm_menu_bonus_spread_tem",
		stats = {
			spread = 1
		},
		exp_multiplier = 1.01,
		money_multiplier = 1.01
	}
	self.bonuses.spread_n1_tem_p1 = {
		name_id = "bm_menu_bonus_spread_tem",
		stats = {
			spread = -1
		},
		exp_multiplier = 1.01,
		money_multiplier = 1.01
	}
	self.bonuses.recoil_p1_tem_p1 = {
		name_id = "bm_menu_bonus_recoil_tem",
		stats = {
			recoil = 1
		},
		exp_multiplier = 1.01,
		money_multiplier = 1.01
	}
	self.bonuses.recoil_p2_tem_p1 = {
		name_id = "bm_menu_bonus_recoil_tem",
		stats = {
			recoil = 2
		},
		exp_multiplier = 1.01,
		money_multiplier = 1.01
	}
	self.bonuses.damage_p1_tem_p1 = {
		name_id = "bm_menu_bonus_damage_tem",
		stats = {
			damage = 1
		},
		exp_multiplier = 1.01,
		money_multiplier = 1.01
	}
	self.bonuses.damage_p2_tem_p1 = {
		name_id = "bm_menu_bonus_damage_tem",
		stats = {
			damage = 2
		},
		exp_multiplier = 1.01,
		money_multiplier = 1.01
	}
	self.bonuses.total_ammo_p1_tem_p1 = {
		name_id = "bm_menu_bonus_total_ammo_tem",
		stats = {
			total_ammo_mod = 1
		},
		exp_multiplier = 1.01,
		money_multiplier = 1.01
	}
	self.bonuses.total_ammo_p3_tem_p1 = {
		name_id = "bm_menu_bonus_total_ammo_tem",
		stats = {
			total_ammo_mod = 3
		},
		exp_multiplier = 1.01,
		money_multiplier = 1.01
	}
	self.bonuses.team_exp_money_p3 = {
		name_id = "bm_menu_bonus_team_exp_money",
		exp_multiplier = 1.03,
		money_multiplier = 1.03
	}

	self:_init_armor_skins()
end

function EconomyTweakData:get_entry_from_index(category, index)
	for entry, data in pairs(self[category] or {}) do
		if not data.index then
			break
		end

		if data.index == index then
			return entry
		end
	end
end

function EconomyTweakData:get_index_from_entry(category, entry)
	return self[category] and self[category][entry] and self[category][entry].index
end

function EconomyTweakData:get_bonus_icons(entry)
	local bonus_data = self.bonuses[entry]
	local bonuses = {}

	if bonus_data then
		if bonus_data.stats then
			table.insert(bonuses, "guis/dlcs/cash/textures/pd2/safe_raffle/statboost_icon")
		end

		if bonus_data.exp_multiplier or bonus_data.money_multiplier then
			table.insert(bonuses, "guis/dlcs/cash/textures/pd2/safe_raffle/teamboost_icon")
		end
	end

	return bonuses
end

EconomyTweakData.market_link_search = "https://steamcommunity.com/market/search?appid=218620&q="

function EconomyTweakData:create_weapon_skin_market_search_url(weapon_id, cosmetic_id)
	local market_link = self.market_links.weapon_skins[cosmetic_id]

	if market_link then
		return EconomyTweakData.market_link_search .. market_link
	end

	local cosmetic_name = tweak_data.blackmarket.weapon_skins[cosmetic_id] and managers.localization:text(tweak_data.blackmarket.weapon_skins[cosmetic_id].name_id)
	local weapon_name = managers.weapon_factory:get_weapon_name_by_weapon_id(weapon_id)

	if cosmetic_name and weapon_name then
		cosmetic_name = string.gsub(cosmetic_name, " ", "+")
		weapon_name = string.gsub(weapon_name, " ", "+")

		return string.gsub(EconomyTweakData.market_link_search .. cosmetic_name .. "+" .. weapon_name, "++", "+")
	end

	return nil
end

function EconomyTweakData:create_armor_skin_market_search_url(cosmetic_id)
	local market_link = self.market_links.armor_skins[cosmetic_id]

	if market_link then
		return EconomyTweakData.market_link_search .. market_link
	end

	local cosmetic_name = tweak_data.economy.armor_skins[cosmetic_id] and managers.localization:text(tweak_data.economy.armor_skins[cosmetic_id].name_id)

	if cosmetic_name then
		cosmetic_name = string.gsub(cosmetic_name, " ", "+")

		return string.gsub(EconomyTweakData.market_link_search .. cosmetic_name .. "+", "++", "+")
	end

	return nil
end

function EconomyTweakData:create_market_link_url(category, entry)
	return self[category] and self[category][entry] and self[category][entry].market_link
end

function EconomyTweakData:create_buy_tradable_url(def_id, quantity)
	return "https://store.steampowered.com/buyitem/218620/" .. tostring(def_id) .. "/"
end

function EconomyTweakData:create_sell_tradable_url(steam_id, instance_id)
	return "https://steamcommunity.com/profiles/" .. tostring(steam_id) .. "/inventory/?sellOnLoad=1#218620_2_" .. tostring(instance_id)
end

function EconomyTweakData:get_bonuses_by_safe(safe)
	local safe_tweak = self.contents[safe]
	local ids = deep_clone(safe_tweak.contains.weapon_skins)

	if safe_tweak.contains.contents then
		for _, content in ipairs(safe_tweak.contains.contents) do
			local legendary_tweak = self.contents[content]

			for _, new_id in ipairs(legendary_tweak.contains.weapon_skins) do
				table.insert(ids, new_id)
			end
		end
	end

	local bonuses = {}

	for _, wid in ipairs(ids) do
		local bonus = "none"
		local item = tweak_data.blackmarket.weapon_skins[wid]

		if item.bonus then
			local bonus_data = self.bonuses[item.bonus]

			if bonus_data.stats and (bonus_data.exp_multiplier or bonus_data.money_multiplier) then
				bonus = "both"
			elseif bonus_data.stats then
				bonus = "single"
			else
				bonus = "team"
			end
		end

		bonuses[wid] = bonus
	end

	return bonuses
end
