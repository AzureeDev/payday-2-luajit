local is_nextgen_console = SystemInfo:platform() == Idstring("PS4") or SystemInfo:platform() == Idstring("XB1")
local allow_halloween_lootdrop = is_nextgen_console
allow_halloween_lootdrop = true

function BlackMarketTweakData:_init_masks(tweak_data)
	self.masks = {
		character_locked = {}
	}
	self.masks.character_locked.name_id = "bm_msk_character_locked"
	self.masks.character_locked.inaccessible = true
	self.masks.character_locked.dallas = "dallas"
	self.masks.character_locked.wolf = "wolf"
	self.masks.character_locked.hoxton = "hoxton"
	self.masks.character_locked.chains = "chains"
	self.masks.character_locked.jowi = "jw_shades"
	self.masks.character_locked.old_hoxton = "old_hoxton"
	self.masks.character_locked.female_1 = "msk_grizel"
	self.masks.character_locked.dragan = "dragan"
	self.masks.character_locked.jacket = "richard_returns"
	self.masks.character_locked.bonnie = "bonnie"
	self.masks.character_locked.sokol = "sokol"
	self.masks.character_locked.dragon = "jiro"
	self.masks.character_locked.bodhi = "bodhi"
	self.masks.character_locked.jimmy = "jimmy_duct"
	self.masks.character_locked.sydney = "sydney"
	self.masks.character_locked.wild = "rust"
	self.masks.character_locked.chico = "chc_terry"
	self.masks.character_locked.max = "max"
	self.masks.character_locked.joy = "joy"
	self.masks.character_locked.myh = "myh"
	self.masks.character_locked.ecp_male = "ecp_male"
	self.masks.character_locked.ecp_female = "ecp_female"
	self.masks.skull = {
		unit = "units/payday2/masks/msk_skull/msk_skull",
		name_id = "bm_msk_skull",
		pcs = {
			10,
			20,
			30,
			40
		},
		dlc = "preorder",
		value = 1
	}
	self.masks.wolf_clean = {
		unit = "units/payday2/masks/msk_wolf_clean/msk_wolf_clean",
		name_id = "bm_msk_wolf_clean",
		pcs = {
			10,
			20,
			30,
			40
		},
		infamous = true,
		value = 9,
		qlvl = 0
	}
	self.masks.hoxton_clean = {
		unit = "units/payday2/masks/msk_hoxton_clean/msk_hoxton_clean",
		name_id = "bm_msk_hoxton_clean",
		pcs = {
			10,
			20,
			30,
			40
		},
		infamous = true,
		value = 9,
		qlvl = 0
	}
	self.masks.dallas_clean = {
		unit = "units/payday2/masks/msk_dallas_clean/msk_dallas_clean",
		name_id = "bm_msk_dallas_clean",
		pcs = {
			10,
			20,
			30,
			40
		},
		infamous = true,
		value = 10,
		qlvl = 0
	}
	self.masks.chains_clean = {
		unit = "units/payday2/masks/msk_chains_clean/msk_chains_clean",
		name_id = "bm_msk_chains_clean",
		pcs = {
			10,
			20,
			30,
			40
		},
		infamous = true,
		value = 9,
		qlvl = 0
	}
	self.masks.dallas = {
		unit = "units/payday2/masks/msk_dallas/msk_dallas",
		name_id = "bm_msk_dallas",
		pcs = {
			10,
			20,
			30,
			40
		},
		infamous = true,
		value = 7,
		offsets = {
			jacket = {
				Vector3(0, 0, 0.554498),
				Rotation(0, 0, -0)
			},
			joy = {
				Vector3(0, 0, 0.554498),
				Rotation(-0, -0, -0)
			}
		}
	}
	self.masks.hoxton = {
		unit = "units/payday2/masks/msk_hoxton/msk_hoxton",
		name_id = "bm_msk_hoxton",
		pcs = {
			10,
			20,
			30,
			40
		},
		infamous = true,
		value = 7
	}
	self.masks.chains = {
		unit = "units/payday2/masks/msk_chains/msk_chains",
		name_id = "bm_msk_chains",
		pcs = {
			10,
			20,
			30,
			40
		},
		infamous = true,
		value = 7
	}
	self.masks.old_hoxton = {
		unit = "units/pd2_dlc_old_hoxton/masks/old_hoxton/msk_old_hoxton",
		name_id = "bm_msk_old_hoxton",
		pcs = {},
		value = 0,
		global_value = "infamous"
	}
	self.masks.wolf = {
		unit = "units/payday2/masks/msk_wolf/msk_wolf",
		name_id = "bm_msk_wolf",
		pcs = {
			10,
			20,
			30,
			40
		},
		infamous = true,
		value = 7
	}
	self.masks.dragan = {
		unit = "units/pd2_dlc_dragan/masks/dragan/msk_dragan",
		name_id = "bm_msk_dragan",
		pcs = {},
		value = 0,
		texture_bundle_folder = "character_pack_dragan",
		dlc = "character_pack_dragan"
	}
	self.masks.dragan_begins = {
		unit = "units/pd2_dlc_dragan/masks/dragan_begins/msk_dragan_begins",
		name_id = "bm_msk_dragan_begins",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		texture_bundle_folder = "character_pack_dragan",
		dlc = "character_pack_dragan"
	}
	self.masks.bonnie = {
		unit = "units/pd2_dlc_bonnie/masks/bonnie/msk_bonnie",
		name_id = "bm_msk_bonnie",
		pcs = {},
		value = 0,
		global_value = "infamous",
		texture_bundle_folder = "character_pack_bonnie"
	}
	self.masks.bonnie_begins = {
		unit = "units/pd2_dlc_bonnie/masks/bonnie_begins/msk_bonnie_begins",
		name_id = "bm_msk_bonnie_begins",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		global_value = "infamous",
		texture_bundle_folder = "character_pack_bonnie"
	}
	self.masks.cthulhu = {
		unit = "units/payday2/masks/msk_cthulhu/msk_cthulhu",
		name_id = "bm_msk_cthulhu",
		pcs = {
			10,
			20,
			30,
			40
		},
		infamous = true,
		value = 8,
		qlvl = 0
	}
	self.masks.grin = {
		unit = "units/payday2/masks/msk_grin/msk_grin",
		name_id = "bm_msk_grin",
		pcs = {
			10,
			20,
			30,
			40
		},
		infamous = true,
		value = 8,
		qlvl = 0
	}
	self.masks.anonymous = {
		unit = "units/payday2/masks/msk_anonymous/msk_anonymous",
		name_id = "bm_msk_anonymous",
		pcs = {
			10,
			20,
			30,
			40
		},
		infamous = true,
		value = 6,
		qlvl = 0
	}
	self.masks.dillinger_death_mask = {
		unit = "units/payday2/masks/msk_dillinger_death_mask/msk_dillinger_death_mask",
		name_id = "bm_msk_dillinger_death_mask",
		pcs = {
			10,
			20,
			30,
			40
		},
		infamous = true,
		value = 9,
		qlvl = 0
	}
	self.masks.alienware = {
		unit = "units/payday2/masks/msk_alienware/msk_alienware",
		name_id = "bm_msk_alienware",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.masks.greek_tragedy = {
		unit = "units/payday2/masks/msk_greek_tragedy/msk_greek_tragedy",
		name_id = "bm_msk_greek_tragedy",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 7,
		qlvl = 0
	}
	self.masks.jaw = {
		unit = "units/payday2/masks/msk_jaw/msk_jaw",
		name_id = "bm_msk_jaw",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.masks.hockey = {
		unit = "units/payday2/masks/msk_hockey_a/msk_hockey_a_mask",
		name_id = "bm_msk_hockey",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 5
	}
	self.masks.troll = {
		unit = "units/payday2/masks/msk_troll/msk_troll",
		name_id = "bm_msk_troll",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.masks.gagball = {
		unit = "units/payday2/masks/msk_gagball/msk_gagball",
		name_id = "bm_msk_gagball",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.masks.tounge = {
		unit = "units/payday2/masks/msk_tounge/msk_tounge",
		name_id = "bm_msk_tounge",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.masks.zipper = {
		unit = "units/payday2/masks/msk_zipper/msk_zipper",
		name_id = "bm_msk_zipper",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 5
	}
	self.masks.biglips = {
		unit = "units/payday2/masks/msk_biglips/msk_biglips",
		name_id = "bm_msk_biglips",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.masks.clowncry = {
		unit = "units/payday2/masks/msk_clowncry/msk_clowncry",
		name_id = "bm_msk_clowncry",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.masks.mr_sinister = {
		unit = "units/payday2/masks/msk_mr_sinister/msk_mr_sinister",
		name_id = "bm_msk_mr_sinister",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 5
	}
	self.masks.clown_56 = {
		unit = "units/payday2/masks/msk_clown_56/msk_clown_56",
		name_id = "bm_msk_clown_56",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.masks.dripper = {
		unit = "units/payday2/masks/msk_dripper/msk_dripper",
		name_id = "bm_msk_dripper",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 8,
		qlvl = 0
	}
	self.masks.buha = {
		unit = "units/payday2/masks/msk_buha/msk_buha",
		name_id = "bm_msk_buha",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 5
	}
	self.masks.shogun = {
		unit = "units/payday2/masks/msk_shogun/msk_shogun",
		name_id = "bm_msk_shogun",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 6
	}
	self.masks.oni = {
		unit = "units/payday2/masks/msk_oni/msk_oni",
		name_id = "bm_msk_oni",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4,
		offsets = {
			jacket = {
				Vector3(0, 0.673745, 0.316006),
				Rotation(-0, -0, -0)
			}
		}
	}
	self.masks.monkeybiss = {
		unit = "units/payday2/masks/msk_monkeybiss/msk_monkeybiss",
		name_id = "bm_msk_monkeybiss",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 5
	}
	self.masks.babyrhino = {
		unit = "units/payday2/masks/msk_babyrhino/msk_babyrhino",
		name_id = "bm_msk_babyrhino",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.masks.hog = {
		unit = "units/payday2/masks/msk_hog/msk_hog",
		name_id = "bm_msk_hog",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3,
		qlvl = 0
	}
	self.masks.outlandish_a = {
		unit = "units/payday2/masks/msk_outlandish_a/msk_outlandish_a",
		name_id = "bm_msk_outlandish_a",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.masks.outlandish_b = {
		unit = "units/payday2/masks/msk_outlandish_b/msk_outlandish_b",
		name_id = "bm_msk_outlandish_b",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.masks.outlandish_c = {
		unit = "units/payday2/masks/msk_outlandish_c/msk_outlandish_c",
		name_id = "bm_msk_outlandish_c",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.masks.bullet = {
		unit = "units/payday2/masks/msk_bullet/msk_bullet",
		name_id = "bm_msk_bullet",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.masks.shrunken = {
		unit = "units/payday2/masks/msk_shrunken/msk_shrunken",
		name_id = "bm_msk_shrunken",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.masks.brainiack = {
		unit = "units/payday2/masks/msk_brainiack/msk_brainiack",
		name_id = "bm_msk_brainiack",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 6
	}
	self.masks.zombie = {
		unit = "units/payday2/masks/msk_zombie/msk_zombie",
		name_id = "bm_msk_zombie",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.masks.scarecrow = {
		unit = "units/payday2/masks/msk_scarecrow/msk_scarecrow",
		name_id = "bm_msk_scarecrow",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 7,
		qlvl = 0
	}
	self.masks.mummy = {
		unit = "units/payday2/masks/msk_mummy/msk_mummy",
		name_id = "bm_msk_mummy",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.masks.vampire = {
		unit = "units/payday2/masks/msk_vampire/msk_vampire",
		name_id = "bm_msk_vampire",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.masks.day_of_the_dead = {
		unit = "units/payday2/masks/msk_day_of_the_dead/msk_day_of_the_dead",
		name_id = "bm_msk_day_of_the_dead",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3,
		qlvl = 0
	}
	self.masks.dawn_of_the_dead = {
		unit = "units/payday2/masks/msk_dawn_of_the_dead/msk_dawn_of_the_dead",
		name_id = "bm_msk_dawn_of_the_dead",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 2
	}
	self.masks.demon = {
		unit = "units/payday2/masks/msk_demon/msk_demon",
		name_id = "bm_msk_demon",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 10,
		qlvl = 0
	}
	self.masks.stonekisses = {
		unit = "units/payday2/masks/msk_stonekisses/msk_stonekisses",
		name_id = "bm_msk_stonekisses",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4
	}
	self.masks.demonictender = {
		unit = "units/payday2/masks/msk_demonictender/msk_demonictender",
		name_id = "bm_msk_demonictender",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.masks.kawaii = {
		unit = "units/payday2/masks/msk_kawaii/msk_kawaii",
		name_id = "bm_msk_kawaii",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.masks.irondoom = {
		unit = "units/payday2/masks/msk_irondoom/msk_irondoom",
		name_id = "bm_msk_irondoom",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.masks.rubber_male = {
		unit = "units/payday2/masks/msk_rubber_male/msk_rubber_male",
		name_id = "bm_msk_rubber_male",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.masks.rubber_female = {
		unit = "units/payday2/masks/msk_rubber_female/msk_rubber_female",
		name_id = "bm_msk_rubber_female",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3
	}
	self.masks.pumpkin_king = {
		unit = "units/payday2/masks/msk_pumpkin_king/msk_pumpkin_king",
		name_id = "bm_msk_pumpkin_king"
	}

	if allow_halloween_lootdrop then
		self.masks.pumpkin_king.pcs = {
			10,
			20,
			30,
			40
		}
		self.masks.pumpkin_king.weight = 25
		self.masks.pumpkin_king.got_item_weight_mod = 0.02
	else
		self.masks.pumpkin_king.pcs = nil
		self.masks.pumpkin_king.weight = 1000
		self.masks.pumpkin_king.got_item_weight_mod = 0.001
	end

	self.masks.pumpkin_king.global_value = "halloween"
	self.masks.pumpkin_king.value = 0
	self.masks.pumpkin_king.qlvl = 0
	self.masks.pumpkin_king.sort_number = 1
	self.masks.witch = {
		unit = "units/payday2/masks/msk_witch/msk_witch",
		name_id = "bm_msk_witch"
	}

	if allow_halloween_lootdrop then
		self.masks.witch.pcs = {
			10,
			20,
			30,
			40
		}
		self.masks.witch.weight = 25
		self.masks.witch.got_item_weight_mod = 0.02
	else
		self.masks.witch.pcs = nil
		self.masks.witch.weight = 1000
		self.masks.witch.got_item_weight_mod = 0.001
	end

	self.masks.witch.global_value = "halloween"
	self.masks.witch.value = 0
	self.masks.witch.qlvl = 0
	self.masks.witch.sort_number = 1
	self.masks.venomorph = {
		unit = "units/payday2/masks/msk_venomorph/msk_venomorph",
		name_id = "bm_msk_venomorph"
	}

	if allow_halloween_lootdrop then
		self.masks.venomorph.pcs = {
			10,
			20,
			30,
			40
		}
		self.masks.venomorph.weight = 25
		self.masks.venomorph.got_item_weight_mod = 0.02
	else
		self.masks.venomorph.pcs = nil
		self.masks.venomorph.weight = 1000
		self.masks.venomorph.got_item_weight_mod = 0.001
	end

	self.masks.venomorph.global_value = "halloween"
	self.masks.venomorph.value = 0
	self.masks.venomorph.qlvl = 0
	self.masks.venomorph.sort_number = 1
	self.masks.frank = {
		unit = "units/payday2/masks/msk_frank/msk_frank",
		name_id = "bm_msk_frank"
	}

	if allow_halloween_lootdrop then
		self.masks.frank.pcs = {
			10,
			20,
			30,
			40
		}
		self.masks.frank.weight = 25
		self.masks.frank.got_item_weight_mod = 0.02
	else
		self.masks.frank.pcs = nil
		self.masks.frank.weight = 1000
		self.masks.frank.got_item_weight_mod = 0.001
	end

	self.masks.frank.global_value = "halloween"
	self.masks.frank.value = 0
	self.masks.frank.qlvl = 0
	self.masks.frank.sort_number = 1
	self.masks.brazil_baby = {
		unit = "units/payday2/masks/msk_brazil_baby/msk_brazil_baby",
		name_id = "bm_msk_brazil_baby",
		global_value = "halloween",
		value = 0,
		qlvl = 0,
		sort_number = 2
	}
	self.masks.baby_angry = {
		unit = "units/payday2/masks/msk_baby_angry/msk_baby_angry",
		name_id = "bm_msk_baby_angry",
		global_value = "halloween",
		value = 0,
		qlvl = 0,
		sort_number = 2
	}
	self.masks.baby_cry = {
		unit = "units/payday2/masks/msk_baby_cry/msk_baby_cry",
		name_id = "bm_msk_baby_cry",
		global_value = "halloween",
		value = 0,
		qlvl = 0,
		sort_number = 2
	}
	self.masks.baby_happy = {
		unit = "units/payday2/masks/msk_baby_happy/msk_baby_happy",
		name_id = "bm_msk_baby_happy",
		global_value = "halloween",
		value = 0,
		qlvl = 0,
		sort_number = 2
	}
	self.masks.the_one_below = {
		unit = "units/pd2_humble_halloween/masks/the_one_below/msk_the_one_below",
		name_id = "bm_msk_onebelow",
		pcs = {},
		dlc = "humble_pack2",
		value = 0,
		sort_number = 4
	}
	self.masks.lycan = {
		unit = "units/pd2_humble_halloween/masks/lycan/msk_lycan",
		name_id = "bm_msk_lycanwulf",
		pcs = {},
		dlc = "humble_pack2",
		value = 0,
		sort_number = 4
	}
	self.masks.krampus = {
		unit = "units/pd2_dlc_pines/masks/krampus/msk_krampus",
		name_id = "bm_msk_krampus",
		pcs = {},
		value = 0,
		sort_number = 1,
		texture_bundle_folder = "pines"
	}
	self.masks.mrs_claus = {
		unit = "units/pd2_dlc_pines/masks/mrs_claus/msk_mrs_claus",
		name_id = "bm_msk_mrs_claus",
		pcs = {},
		value = 0,
		sort_number = 1,
		texture_bundle_folder = "pines"
	}
	self.masks.strinch = {
		unit = "units/pd2_dlc_pines/masks/strinch/msk_the_strinch",
		name_id = "bm_msk_the_strinch",
		pcs = {},
		type = "helmet",
		value = 0,
		sort_number = 1,
		texture_bundle_folder = "pines"
	}
	self.masks.almirs_beard = {
		unit = "units/pd2_dlc_pines/masks/almirs_beard/msk_almirs_beard",
		name_id = "bm_msk_almirs_beard",
		pcs = {},
		type = "beard",
		skip_mask_on_sequence = true,
		value = 0,
		sort_number = 1,
		texture_bundle_folder = "pines"
	}
	self.masks.robo_santa = {
		unit = "units/pd2_dlc_pines/masks/robo_santa/msk_robo_santa",
		name_id = "bm_msk_robo_santa",
		pcs = {},
		value = 0,
		sort_number = 1,
		texture_bundle_folder = "pines"
	}
	self.masks.heat = {
		unit = "units/pd2_dlc1/masks/msk_hockey_b/msk_hockey_b",
		name_id = "bm_msk_heat",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 6,
		dlc = "pd2_clan",
		sort_number = 2
	}
	self.masks.bear = {
		unit = "units/payday2/masks/msk_bear/msk_bear",
		name_id = "bm_msk_bear",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 3,
		qlvl = 0,
		dlc = "pd2_clan",
		sort_number = 1
	}
	self.masks.clinton = {
		unit = "units/pd2_dlc1/masks/msk_clinton/msk_clinton",
		name_id = "bm_msk_clinton",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 6,
		dlc = "armored_transport",
		texture_bundle_folder = "dlc1"
	}
	self.masks.bush = {
		unit = "units/pd2_dlc1/masks/msk_bush/msk_bush",
		name_id = "bm_msk_bush",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 6,
		dlc = "armored_transport",
		texture_bundle_folder = "dlc1"
	}
	self.masks.obama = {
		unit = "units/pd2_dlc1/masks/msk_obama/msk_obama",
		name_id = "bm_msk_obama",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 6,
		dlc = "armored_transport",
		texture_bundle_folder = "dlc1"
	}
	self.masks.nixon = {
		unit = "units/pd2_dlc1/masks/msk_nixon/msk_nixon",
		name_id = "bm_msk_nixon",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 6,
		dlc = "armored_transport",
		texture_bundle_folder = "dlc1"
	}
	self.masks.goat = {
		unit = "units/pd2_dlc_dec5/masks/msk_goat/msk_goat",
		name_id = "bm_msk_goat",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4,
		texture_bundle_folder = "gage_pack",
		dlc = "gage_pack"
	}
	self.masks.panda = {
		unit = "units/pd2_dlc_dec5/masks/msk_panda/msk_panda",
		name_id = "bm_msk_panda",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4,
		texture_bundle_folder = "gage_pack",
		dlc = "gage_pack"
	}
	self.masks.pitbull = {
		unit = "units/pd2_dlc_dec5/masks/msk_pitbull/msk_pitbull",
		name_id = "bm_msk_pitbull",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4,
		texture_bundle_folder = "gage_pack",
		dlc = "gage_pack"
	}
	self.masks.eagle = {
		unit = "units/pd2_dlc_dec5/masks/msk_eagle/msk_eagle",
		name_id = "bm_msk_eagle",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4,
		qlvl = 0,
		texture_bundle_folder = "gage_pack",
		dlc = "gage_pack"
	}
	self.masks.santa_happy = {
		unit = "units/pd2_dlc2/masks/msk_santa_happy/msk_santa_happy",
		name_id = "bm_msk_santa_happy",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4,
		dlc = "pd2_clan",
		sort_number = 3
	}
	self.masks.santa_mad = {
		unit = "units/pd2_dlc_xmas/masks/msk_santa_mad/msk_santa_mad",
		name_id = "bm_msk_santa_mad",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4,
		dlc = "xmas_soundtrack"
	}
	self.masks.santa_drunk = {
		unit = "units/pd2_dlc_xmas/masks/msk_santa_drunk/msk_santa_drunk",
		name_id = "bm_msk_santa_drunk",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4,
		dlc = "xmas_soundtrack"
	}
	self.masks.santa_surprise = {
		unit = "units/pd2_dlc_xmas/masks/msk_santa_suprise/msk_santa_suprise",
		name_id = "bm_msk_santa_surprise",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4,
		dlc = "xmas_soundtrack"
	}
	self.masks.aviator = {
		unit = "units/pd2_dlc_infamy/masks/msk_aviator/msk_aviator",
		name_id = "bm_msk_aviator",
		pcs = {},
		value = 0,
		type = "glasses",
		skip_mask_on_sequence = true,
		global_value = "infamy",
		texture_bundle_folder = "infamous",
		infamy_lock = "infamy_root",
		offsets = {
			joy = {
				Vector3(0.077513, 1.62772, -1.71118),
				Rotation(0, 5.70954, 0)
			}
		}
	}
	self.masks.ghost = {
		unit = "units/pd2_dlc_infamy/masks/msk_ghost/msk_ghost",
		name_id = "bm_msk_ghost",
		pcs = {},
		value = 0,
		global_value = "infamy",
		texture_bundle_folder = "infamous",
		type = "helmet",
		infamy_lock = "infamy_ghost"
	}
	self.masks.welder = {
		unit = "units/pd2_dlc_infamy/masks/msk_welder/msk_welder",
		name_id = "bm_msk_welder",
		pcs = {},
		value = 0,
		global_value = "infamy",
		texture_bundle_folder = "infamous",
		infamy_lock = "infamy_enforcer"
	}
	self.masks.plague = {
		unit = "units/pd2_dlc_infamy/masks/msk_plague/msk_plague",
		name_id = "bm_msk_plague",
		pcs = {},
		value = 0,
		global_value = "infamy",
		texture_bundle_folder = "infamous",
		infamy_lock = "infamy_mastermind"
	}
	self.masks.smoker = {
		unit = "units/pd2_dlc_infamy/masks/msk_smoker/msk_smoker",
		name_id = "bm_msk_smoker",
		pcs = {},
		value = 0,
		global_value = "infamy",
		texture_bundle_folder = "infamous",
		infamy_lock = "infamy_technician",
		offsets = {
			jacket = {
				Vector3(0, 0.792991, 0.077513),
				Rotation(0, 0.558094, 0)
			}
		}
	}
	self.masks.cloth_commander = {
		unit = "units/pd2_dlc_gage_lmg/masks/cloth_commander/msk_cloth_commander",
		name_id = "bm_msk_cloth_commander",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4,
		qlvl = 0,
		dlc = "gage_pack_lmg",
		texture_bundle_folder = "gage_pack_lmg"
	}
	self.masks.gage_blade = {
		unit = "units/pd2_dlc_gage_lmg/masks/msk_gage_blade/msk_gage_blade",
		name_id = "bm_msk_gage_blade",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4,
		qlvl = 0,
		texture_bundle_folder = "gage_pack_lmg",
		dlc = "gage_pack_lmg"
	}
	self.masks.gage_rambo = {
		unit = "units/pd2_dlc_gage_lmg/masks/msk_gage_rambo/msk_gage_rambo",
		name_id = "bm_msk_rambo",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4,
		qlvl = 0,
		texture_bundle_folder = "gage_pack_lmg",
		dlc = "gage_pack_lmg"
	}
	self.masks.gage_deltaforce = {
		unit = "units/pd2_dlc_gage_lmg/masks/msk_gage_deltaforce/msk_gage_deltaforce",
		name_id = "bm_msk_deltaforce",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 4,
		qlvl = 0,
		texture_bundle_folder = "gage_pack_lmg",
		dlc = "gage_pack_lmg"
	}
	self.masks.robberfly = {
		unit = "units/pd2_dlc_gage_snp/masks/msk_robberfly/msk_robberfly",
		name_id = "bm_msk_robberfly",
		pcs = {},
		value = 0,
		qlvl = 0,
		texture_bundle_folder = "gage_pack_snp",
		dlc = "gage_pack_snp"
	}
	self.masks.spider = {
		unit = "units/pd2_dlc_gage_snp/masks/msk_spider/msk_spider",
		name_id = "bm_msk_spider",
		pcs = {},
		value = 0,
		qlvl = 0,
		texture_bundle_folder = "gage_pack_snp",
		dlc = "gage_pack_snp"
	}
	self.masks.mantis = {
		unit = "units/pd2_dlc_gage_snp/masks/msk_mantis/msk_mantis",
		name_id = "bm_msk_mantis",
		pcs = {},
		value = 0,
		qlvl = 0,
		texture_bundle_folder = "gage_pack_snp",
		dlc = "gage_pack_snp"
	}
	self.masks.wasp = {
		unit = "units/pd2_dlc_gage_snp/masks/msk_wasp/msk_wasp",
		name_id = "bm_msk_wasp",
		pcs = {},
		value = 0,
		qlvl = 0,
		texture_bundle_folder = "gage_pack_snp",
		dlc = "gage_pack_snp"
	}
	self.masks.skullhard = {
		unit = "units/payday2/masks/msk_skullhard/msk_skullhard",
		name_id = "bm_msk_skullhard",
		pcs = {},
		value = 0,
		qlvl = 0,
		infamous = true,
		sort_number = 30
	}
	self.masks.skullveryhard = {
		unit = "units/payday2/masks/msk_skullveryhard/msk_skullveryhard",
		name_id = "bm_msk_skullveryhard",
		pcs = {},
		value = 0,
		qlvl = 0,
		infamous = true,
		sort_number = 31
	}
	self.masks.skulloverkill = {
		unit = "units/payday2/masks/msk_skulloverkill/msk_skulloverkill",
		name_id = "bm_msk_skulloverkill",
		pcs = {},
		value = 0,
		qlvl = 0,
		infamous = true,
		sort_number = 32
	}
	self.masks.gitgud_e_wish = {
		unit = "units/pd2_dlc_gitgud/masks/e_wish/msk_gitgud_e_wish",
		name_id = "bm_e_wish",
		pcs = {},
		value = 0,
		qlvl = 0,
		infamous = true,
		texture_bundle_folder = "gitgud",
		sort_number = 33
	}
	self.masks.skulloverkillplus = {
		unit = "units/payday2/masks/msk_skulloverkillplus/msk_skulloverkillplus",
		name_id = "bm_msk_skulloverkillplus",
		pcs = {},
		value = 0,
		qlvl = 0,
		infamous = true,
		sort_number = 34
	}
	self.masks.gitgud_sm_wish = {
		unit = "units/pd2_dlc_gitgud/masks/sm_wish/msk_gitgud_sm_wish",
		name_id = "bm_sm_wish",
		pcs = {},
		value = 0,
		qlvl = 0,
		infamous = true,
		texture_bundle_folder = "gitgud",
		sort_number = 35
	}
	self.masks.metalhead = {
		unit = "units/pd2_poetry_winners/masks/veggie/msk_metalhead",
		name_id = "bm_msk_metalhead",
		pcs = {},
		value = 0,
		dlc = "poetry_soundtrack",
		global_value = "poetry_soundtrack"
	}
	self.masks.tcn = {
		unit = "units/pd2_poetry_winners/masks/tcn/msk_tcn",
		name_id = "bm_msk_tcn",
		pcs = {},
		value = 0,
		dlc = "poetry_soundtrack",
		global_value = "poetry_soundtrack"
	}
	self.masks.surprise = {
		unit = "units/pd2_poetry_winners/masks/shaegro/msk_surprise",
		name_id = "bm_msk_surprise",
		pcs = {},
		value = 0,
		dlc = "poetry_soundtrack",
		global_value = "poetry_soundtrack"
	}
	self.masks.optimist_prime = {
		unit = "units/pd2_poetry_winners/masks/optimist_prime/msk_optimist_prime",
		name_id = "bm_msk_optimist_prime",
		pcs = {},
		value = 0,
		dlc = "poetry_soundtrack",
		global_value = "poetry_soundtrack"
	}
	self.masks.samurai = {
		unit = "units/payday2/masks/msk_samurai/msk_samurai",
		name_id = "bm_msk_samurai",
		pcs = {},
		value = 0,
		qlvl = 0,
		infamous = true
	}
	self.masks.twitch_orc = {
		unit = "units/pd2_twitch_pack/masks/msk_twitch_orc/msk_twitch_orc",
		name_id = "bm_msk_twitch_orc",
		pcs = {},
		value = 0,
		qlvl = 0,
		texture_bundle_folder = "twitch_pack",
		dlc = "twitch_pack",
		sort_number = 3
	}
	self.masks.ancient = {
		unit = "units/pd2_twitch_pack/masks/msk_ancient/msk_ancient",
		name_id = "bm_msk_ancient",
		pcs = {},
		value = 0,
		qlvl = 0,
		texture_bundle_folder = "twitch_pack",
		dlc = "twitch_pack",
		sort_number = 3
	}
	self.masks.unicorn = {
		unit = "units/payday2/masks/msk_unicorn/msk_unicorn",
		name_id = "bm_msk_unicorn",
		pcs = {},
		value = 0,
		dlc = "pd2_clan",
		sort_number = 4
	}
	self.masks.franklin = {
		unit = "units/pd2_dlc_big/masks/msk_franklin/msk_franklin",
		name_id = "bm_msk_franklin",
		pcs = {},
		value = 0,
		qlvl = 0,
		dlc = "big_bank",
		texture_bundle_folder = "big_bank"
	}
	self.masks.lincoln = {
		unit = "units/pd2_dlc_big/masks/msk_lincoln/msk_lincoln",
		name_id = "bm_msk_lincoln",
		pcs = {},
		value = 0,
		qlvl = 0,
		dlc = "big_bank",
		texture_bundle_folder = "big_bank"
	}
	self.masks.grant = {
		unit = "units/pd2_dlc_big/masks/msk_grant/msk_grant",
		name_id = "bm_msk_grant",
		pcs = {},
		value = 0,
		qlvl = 0,
		dlc = "big_bank",
		texture_bundle_folder = "big_bank"
	}
	self.masks.washington = {
		unit = "units/pd2_dlc_big/masks/msk_washington/msk_washington",
		name_id = "bm_msk_washington",
		pcs = {},
		value = 0,
		qlvl = 0,
		dlc = "big_bank",
		texture_bundle_folder = "big_bank"
	}
	self.masks.silverback = {
		unit = "units/pd2_dlc_gage_shot/masks/silverback/msk_silverback",
		name_id = "bm_msk_silverback",
		pcs = {},
		value = 0,
		dlc = "gage_pack_shotgun",
		texture_bundle_folder = "gage_pack_shotgun"
	}
	self.masks.mandril = {
		unit = "units/pd2_dlc_gage_shot/masks/mandrill/msk_mandril",
		name_id = "bm_msk_mandril",
		pcs = {},
		value = 0,
		dlc = "gage_pack_shotgun",
		texture_bundle_folder = "gage_pack_shotgun"
	}
	self.masks.skullmonkey = {
		unit = "units/pd2_dlc_gage_shot/masks/skullmonkey/msk_skullmonkey",
		name_id = "bm_msk_skullmonkey",
		pcs = {},
		value = 0,
		dlc = "gage_pack_shotgun",
		texture_bundle_folder = "gage_pack_shotgun"
	}
	self.masks.orangutang = {
		unit = "units/pd2_dlc_gage_shot/masks/orangutang/msk_orangutang",
		name_id = "bm_msk_orangutang",
		pcs = {},
		value = 0,
		dlc = "gage_pack_shotgun",
		texture_bundle_folder = "gage_pack_shotgun"
	}
	self.masks.galax = {
		unit = "units/pd2_dlc_gage_assault/masks/msk_galax/msk_galax",
		name_id = "bm_msk_galax",
		pcs = {},
		value = 0,
		dlc = "gage_pack_assault",
		texture_bundle_folder = "gage_pack_assault"
	}
	self.masks.crowgoblin = {
		unit = "units/pd2_dlc_gage_assault/masks/msk_crowgoblin/msk_crowgoblin",
		name_id = "bm_msk_crowgoblin",
		pcs = {},
		value = 0,
		dlc = "gage_pack_assault",
		texture_bundle_folder = "gage_pack_assault"
	}
	self.masks.evil = {
		unit = "units/pd2_dlc_gage_assault/masks/msk_evil/msk_evil",
		name_id = "bm_msk_evil",
		pcs = {},
		value = 0,
		dlc = "gage_pack_assault",
		texture_bundle_folder = "gage_pack_assault"
	}
	self.masks.volt = {
		unit = "units/pd2_dlc_gage_assault/masks/msk_volt/msk_volt",
		name_id = "bm_msk_volt",
		pcs = {},
		value = 0,
		dlc = "gage_pack_assault",
		texture_bundle_folder = "gage_pack_assault"
	}
	self.masks.white_wolf = {
		unit = "units/pd2_dlc_miami/masks/msk_white_wolf/msk_white_wolf",
		name_id = "bm_msk_white_wolf",
		pcs = {},
		value = 0,
		dlc = "hl_miami",
		texture_bundle_folder = "hl_miami"
	}
	self.masks.owl = {
		unit = "units/pd2_dlc_miami/masks/msk_owl/msk_owl",
		name_id = "bm_msk_owl",
		pcs = {},
		value = 0,
		dlc = "hl_miami",
		texture_bundle_folder = "hl_miami"
	}
	self.masks.rabbit = {
		unit = "units/pd2_dlc_miami/masks/msk_rabbit/msk_rabbit",
		name_id = "bm_msk_rabbit",
		pcs = {},
		value = 0,
		dlc = "hl_miami",
		texture_bundle_folder = "hl_miami"
	}
	self.masks.pig = {
		unit = "units/pd2_dlc_miami/masks/msk_pig/msk_pig",
		name_id = "bm_msk_pig",
		pcs = {},
		value = 0,
		dlc = "hl_miami",
		texture_bundle_folder = "hl_miami"
	}
	self.masks.panther = {
		unit = "units/pd2_dlc_miami/masks/msk_panther/msk_panther",
		name_id = "bm_msk_panther",
		pcs = {},
		value = 0,
		dlc = "hlm_game",
		texture_bundle_folder = "hl_miami"
	}
	self.masks.rooster = {
		unit = "units/pd2_dlc_miami/masks/msk_rooster/msk_rooster",
		name_id = "bm_msk_rooster",
		pcs = {},
		value = 0,
		dlc = "hlm_game",
		texture_bundle_folder = "hl_miami"
	}
	self.masks.horse = {
		unit = "units/pd2_dlc_miami/masks/msk_horse/msk_horse",
		name_id = "bm_msk_horse",
		pcs = {},
		value = 0,
		dlc = "hlm_game",
		texture_bundle_folder = "hl_miami"
	}
	self.masks.tiger = {
		unit = "units/pd2_dlc_miami/masks/msk_tiger/msk_tiger",
		name_id = "bm_msk_tiger",
		pcs = {},
		value = 0,
		dlc = "hlm_game",
		texture_bundle_folder = "hl_miami"
	}
	self.masks.combusto = {
		unit = "units/pd2_crimefest_2014/oct19/masks/combusto/msk_combusto",
		name_id = "bm_msk_combusto",
		pcs = {},
		dlc = "pd2_clan",
		value = 0,
		sort_number = 5
	}
	self.masks.spackle = {
		unit = "units/pd2_crimefest_2014/oct19/masks/spackle/msk_spackle",
		name_id = "bm_msk_spackle",
		pcs = {},
		dlc = "pd2_clan",
		value = 0,
		sort_number = 5
	}
	self.masks.jw_shades = {
		unit = "units/pd2_crimefest_2014/oct22/masks/jw_shades/msk_jw_shades",
		name_id = "bm_msk_jw_shades",
		pcs = {},
		value = 0,
		type = "glasses",
		skip_mask_on_sequence = true,
		global_value = "infamous"
	}
	self.masks.stoneface = {
		unit = "units/pd2_crimefest_2014/oct22/masks/stoneface/msk_stoneface",
		name_id = "bm_msk_stoneface",
		pcs = {},
		value = 0,
		dlc = "pd2_clan",
		type = "glasses",
		skip_mask_on_sequence = true,
		sort_number = 7
	}
	self.masks.wayfarer = {
		unit = "units/pd2_crimefest_2014/oct22/masks/wayfarer/msk_wayfarer",
		name_id = "bm_msk_wayfarer",
		pcs = {},
		value = 0,
		dlc = "pd2_clan",
		type = "glasses",
		skip_mask_on_sequence = true,
		sort_number = 7
	}
	self.masks.smiley = {
		unit = "units/pd2_crimefest_2014/oct23/masks/smiley/msk_smiley",
		name_id = "bm_msk_smiley",
		pcs = {},
		dlc = "pd2_clan",
		value = 0,
		sort_number = 6
	}
	self.masks.gumbo = {
		unit = "units/pd2_crimefest_2014/oct23/masks/gumbo/msk_gumbo",
		name_id = "bm_msk_gumbo",
		pcs = {},
		dlc = "pd2_clan",
		value = 0,
		sort_number = 6
	}
	self.masks.crazy_lion = {
		unit = "units/pd2_crimefest_2014/oct26/masks/msk_crazy_lion/crazy_lion_mask",
		name_id = "bm_msk_crazy_lion",
		pcs = {},
		dlc = "pd2_clan",
		value = 0,
		sort_number = 8
	}
	self.masks.churchill = {
		unit = "units/pd2_dlc_gage_historical/masks/churchill/msk_churchill",
		name_id = "bm_msk_churchill",
		pcs = {},
		value = 0,
		dlc = "gage_pack_historical",
		texture_bundle_folder = "gage_pack_historical"
	}
	self.masks.red_hurricane = {
		unit = "units/pd2_dlc_gage_historical/masks/red_hurricane/msk_red_hurricane",
		name_id = "bm_msk_red_hurricane",
		pcs = {},
		value = 0,
		dlc = "gage_pack_historical",
		texture_bundle_folder = "gage_pack_historical"
	}
	self.masks.patton = {
		unit = "units/pd2_dlc_gage_historical/masks/patton/msk_patton",
		name_id = "bm_msk_patton",
		pcs = {},
		value = 0,
		dlc = "gage_pack_historical",
		texture_bundle_folder = "gage_pack_historical"
	}
	self.masks.de_gaulle = {
		unit = "units/pd2_dlc_gage_historical/masks/de_gaulle/msk_de_gaulle",
		name_id = "bm_msk_de_gaulle",
		pcs = {},
		value = 0,
		dlc = "gage_pack_historical",
		texture_bundle_folder = "gage_pack_historical"
	}
	self.masks.msk_grizel = {
		unit = "units/pd2_dlc_clover/masks/msk_grizel/msk_grizel",
		name_id = "bm_msk_msk_grizel",
		pcs = {},
		value = 0,
		dlc = "character_pack_clover",
		texture_bundle_folder = "character_pack_clover"
	}
	self.masks.grizel_clean = {
		unit = "units/pd2_dlc_clover/masks/msk_clover_begins/msk_clover_begins",
		name_id = "bm_msk_grizel_clean",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		dlc = "character_pack_clover",
		texture_bundle_folder = "character_pack_clover"
	}
	self.masks.medusa = {
		unit = "units/pd2_indiana/masks/medusa/msk_medusa",
		name_id = "bm_msk_medusa",
		pcs = {},
		value = 0,
		dlc = "hope_diamond",
		texture_bundle_folder = "character_pack_clover"
	}
	self.masks.anubis = {
		unit = "units/pd2_indiana/masks/anubis/msk_anubis",
		name_id = "bm_msk_anubis",
		type = "helmet",
		pcs = {},
		value = 0,
		dlc = "hope_diamond",
		texture_bundle_folder = "character_pack_clover"
	}
	self.masks.pazuzu = {
		unit = "units/pd2_indiana/masks/pazuzu/msk_pazuzu",
		name_id = "bm_msk_pazuzu",
		pcs = {},
		value = 0,
		dlc = "hope_diamond",
		texture_bundle_folder = "character_pack_clover"
	}
	self.masks.cursed_crown = {
		unit = "units/pd2_indiana/masks/msk_cursed_crown/msk_cursed_crown",
		name_id = "bm_msk_cursed_crown",
		pcs = {},
		value = 0,
		dlc = "hope_diamond",
		texture_bundle_folder = "character_pack_clover"
	}
	self.masks.butcher = {
		unit = "units/pd2_dlc_dragan/masks/butcher/msk_butcher",
		name_id = "bm_msk_butcher",
		pcs = {},
		value = 0,
		dlc = "the_bomb",
		texture_bundle_folder = "the_bomb"
	}
	self.masks.doctor = {
		unit = "units/pd2_dlc_cro/masks/msk_doctor/msk_doctor",
		name_id = "bm_msk_doctor",
		pcs = {},
		value = 0,
		dlc = "the_bomb",
		type = "helmet",
		texture_bundle_folder = "the_bomb",
		skip_mask_on_sequence = true
	}
	self.masks.tech_lion = {
		unit = "units/pd2_dlc_cro/masks/msk_tech_lion/msk_tech_lion",
		name_id = "bm_msk_tech_lion",
		pcs = {},
		value = 0,
		dlc = "the_bomb",
		texture_bundle_folder = "the_bomb"
	}
	self.masks.lady_butcher = {
		unit = "units/pd2_dlc_cro/masks/msk_butcher/msk_butcher",
		name_id = "bm_msk_lady_butcher",
		pcs = {},
		value = 0,
		dlc = "the_bomb",
		texture_bundle_folder = "the_bomb"
	}
	self.masks.nun_town = {
		unit = "units/pd2_dlc_goty/masks/nun_town/msk_nun_town",
		name_id = "bm_msk_nun_town",
		pcs = {},
		value = 0,
		dlc = "goty_heist_bundle_2014",
		dlc_list = {
			"armored_transport",
			"big_bank",
			"hl_miami",
			"hope_diamond"
		},
		texture_bundle_folder = "pd2_goty"
	}
	self.masks.robo_arnold = {
		unit = "units/pd2_dlc_goty/masks/robo_arnold/msk_robo_arnold",
		name_id = "bm_msk_robo_arnold",
		pcs = {},
		value = 0,
		dlc = "goty_weapon_bundle_2014",
		dlc_list = {
			"gage_pack",
			"gage_pack_lmg",
			"gage_pack_jobs",
			"gage_pack_snp",
			"gage_pack_shotgun",
			"gage_pack_assault",
			"gage_pack_historical"
		},
		texture_bundle_folder = "pd2_goty"
	}
	self.masks.arch_nemesis = {
		unit = "units/pd2_dlc_goty/masks/arch_nemesis/msk_arch_nemesis",
		name_id = "bm_msk_arch_nemesis",
		pcs = {},
		value = 0,
		type = "helmet",
		default_blueprint = {
			materials = "deep_bronze",
			textures = "no_color_full_material"
		},
		dlc = "goty_dlc_bundle_2014",
		dlc_list = {
			"character_pack_clover",
			"armored_transport",
			"big_bank",
			"hl_miami",
			"hope_diamond",
			"gage_pack",
			"gage_pack_lmg",
			"gage_pack_jobs",
			"gage_pack_snp",
			"gage_pack_shotgun",
			"gage_pack_assault",
			"gage_pack_historical"
		},
		texture_bundle_folder = "pd2_goty"
	}
	self.masks.carnotaurus = {
		unit = "units/pd2_dlc_akm4_modpack/masks/carnotaurus/msk_carnotaurus",
		name_id = "bm_msk_carnotaurus",
		pcs = {},
		value = 0,
		texture_bundle_folder = "dlc_akm4",
		dlc = "akm4_pack"
	}
	self.masks.triceratops = {
		unit = "units/pd2_dlc_akm4_modpack/masks/triceratops/msk_triceratops",
		name_id = "bm_msk_triceratops",
		pcs = {},
		value = 0,
		texture_bundle_folder = "dlc_akm4",
		dlc = "akm4_pack"
	}
	self.masks.pachy = {
		unit = "units/pd2_dlc_akm4_modpack/masks/pachy/msk_pachy",
		name_id = "bm_msk_pachy",
		pcs = {},
		value = 0,
		texture_bundle_folder = "dlc_akm4",
		dlc = "akm4_pack"
	}
	self.masks.velociraptor = {
		unit = "units/pd2_dlc_akm4_modpack/masks/velociraptor/msk_velociraptor",
		name_id = "bm_msk_velociraptor",
		pcs = {},
		value = 0,
		texture_bundle_folder = "dlc_akm4",
		dlc = "akm4_pack"
	}
	self.masks.champion_dallas = {
		unit = "units/pd2_hw_boxing/masks/champion_dallas/msk_champion_dallas",
		name_id = "bm_msk_champion_dallas",
		pcs = {},
		value = 0,
		dlc = nil,
		texture_bundle_folder = "pd2_hw_boxing",
		sort_number = 10
	}

	if SystemInfo:distribution() == Idstring("STEAM") then
		self.masks.area51 = {
			unit = "units/pd2_dlc_alienware/masks/area51/msk_area51",
			name_id = "bm_msk_area51",
			texture_bundle_folder = "alienware_alpha",
			pcs = {},
			value = 0,
			dlc = "alienware_alpha",
			type = "helmet",
			sort_number = 5
		}
		self.masks.alien_helmet = {
			unit = "units/pd2_dlc_alienware/masks/alien_helmet/msk_alien_helmet",
			name_id = "bm_msk_alien_helmet",
			texture_bundle_folder = "alienware_alpha",
			pcs = {},
			value = 0,
			dlc = "alienware_alpha",
			type = "helmet",
			default_blueprint = {
				materials = "gunmetal",
				textures = "no_color_full_material"
			},
			sort_number = 5
		}
	end

	self.masks.infamy_lurker = {
		unit = "units/pd2_dlc_infamy/masks/msk_infamy_lurker/msk_infamy_lurker",
		name_id = "bm_msk_infamy_lurker",
		global_value = "infamy",
		texture_bundle_folder = "infamous",
		pcs = {},
		value = 0,
		infamy_lock = "infamy_maskpack_lurker"
	}
	self.masks.infamy_hood = {
		unit = "units/pd2_dlc_infamy/masks/msk_infamy_hood/msk_infamy_hood",
		name_id = "bm_msk_infamy_hood",
		global_value = "infamy",
		texture_bundle_folder = "infamous",
		pcs = {},
		value = 0,
		type = "helmet",
		infamy_lock = "infamy_maskpack_hood"
	}
	self.masks.ranger = {
		unit = "units/pd2_dlc_infamy/masks/ranger/msk_ranger",
		name_id = "bm_msk_ranger",
		global_value = "infamy",
		texture_bundle_folder = "infamous",
		pcs = {},
		value = 0,
		type = "helmet",
		infamy_lock = "infamy_maskpack_ranger"
	}
	self.masks.punk = {
		unit = "units/pd2_dlc_infamy/masks/punk/msk_punk",
		name_id = "bm_msk_punk",
		global_value = "infamy",
		texture_bundle_folder = "infamous",
		pcs = {},
		value = 0,
		infamy_lock = "infamy_maskpack_punk"
	}
	self.masks.daft = {
		unit = "units/pd2_dlc_infamy/masks/daft/msk_daft",
		name_id = "bm_msk_daft",
		global_value = "infamy",
		texture_bundle_folder = "infamous",
		pcs = {},
		value = 0,
		infamy_lock = "infamy_maskpack_daft"
	}
	self.masks.pain = {
		unit = "units/pd2_dlc_infamy/masks/pain/msk_pain",
		name_id = "bm_msk_pain",
		global_value = "infamy",
		texture_bundle_folder = "infamous",
		pcs = {},
		value = 0,
		type = "helmet",
		skip_mask_on_sequence = true,
		infamy_lock = "infamy_maskpack_pain"
	}
	self.masks.destroyer = {
		unit = "units/pd2_dlc_infamy/masks/destroyer/msk_destroyer",
		name_id = "bm_msk_destroyer",
		global_value = "infamy",
		texture_bundle_folder = "infamous",
		pcs = {},
		value = 0,
		infamy_lock = "infamy_maskpack_destroyer"
	}
	self.masks.balaclava_chains = {
		unit = "units/pd2_dlc_infamy/masks/msk_balaclava_chains/msk_balaclava_chains",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true
	}
	self.masks.balaclava_wolf = {
		unit = "units/pd2_dlc_infamy/masks/msk_balaclava_wolf/msk_balaclava_wolf",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true
	}
	self.masks.balaclava_clover = {
		unit = "units/pd2_dlc_infamy/masks/msk_balaclava_clover/msk_balaclava_clover",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true
	}
	self.masks.balaclava_dallas = {
		unit = "units/pd2_dlc_infamy/masks/msk_balaclava_dallas/msk_balaclava_dallas",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true,
		offsets = {
			myh = {
				Vector3(0, -0.16098, -0.399472),
				Rotation(-0.30048, 2.27524, -0.30048)
			},
			ecp_female = {
				Vector3(0, -0.399472, 0),
				Rotation(-0, -0, -0)
			}
		}
	}
	self.masks.balaclava_dragan = {
		unit = "units/pd2_dlc_infamy/masks/msk_balaclava_dragan/msk_balaclava_dragan",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true
	}
	self.masks.balaclava_hoxton = {
		unit = "units/pd2_dlc_infamy/masks/msk_balaclava_hoxton/msk_balaclava_hoxton",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true
	}
	self.masks.balaclava_john_wick = {
		unit = "units/pd2_dlc_infamy/masks/msk_balaclava_john_wick/msk_balaclava_john_wick",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true
	}
	self.masks.balaclava_sokol = {
		unit = "units/pd2_dlc_character_sokol/masks/msk_balaclava_sokol/msk_balaclava_sokol",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true
	}
	self.masks.balaclava_wild = {
		unit = "units/pd2_dlc_wild/masks/msk_balaclava_wild/msk_balaclava_wild",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true
	}
	self.masks.balaclava_chico = {
		unit = "units/pd2_dlc_chico/masks/msk_balaclava_chico/msk_balaclava_chico",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true
	}
	self.masks.balaclava_max = {
		unit = "units/pd2_dlc_max/masks/msk_balaclava_max/msk_balaclava_max",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true
	}
	self.masks.balaclava_ecp_male = {
		unit = "units/pd2_dlc_ecp/masks/msk_balaclava_ecp_male/msk_balaclava_ecp_male",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true,
		offsets = {}
	}
	self.masks.balaclava_joy = {
		unit = "units/pd2_dlc_joy/masks/msk_balaclava_joy/msk_balaclava_joy",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true,
		offsets = {
			joy = {
				Vector3(-0.16098, -0.280226, 0.316006),
				Rotation(-0, -0, 3.13382)
			}
		}
	}
	self.masks.balaclava = {
		name_id = "bm_msk_balaclava",
		global_value = "infamy",
		value = 0,
		pcs = {},
		type = "helmet",
		texture_bundle_folder = "infamous",
		infamy_lock = "infamy_maskpack_balaclava",
		characters = {
			bonnie = "balaclava_dallas",
			sokol = "balaclava_sokol",
			myh = "balaclava_dallas",
			chico = "balaclava_chico",
			dragan = "balaclava_dragan",
			ecp_male = "balaclava_ecp_male",
			ecp_female = "balaclava_dallas",
			dragon = "balaclava_dallas",
			old_hoxton = "balaclava_hoxton",
			jowi = "balaclava_john_wick",
			max = "balaclava_dallas",
			joy = "balaclava_joy",
			dallas = "balaclava_dallas",
			jacket = "balaclava_wolf",
			jimmy = "balaclava_dallas",
			bodhi = "balaclava_dallas",
			wolf = "balaclava_wolf",
			wild = "balaclava_wild",
			hoxton = "balaclava_dragan",
			female_1 = "balaclava_clover",
			chains = "balaclava_chains",
			sydney = "balaclava_sokol"
		}
	}
	self.masks.the_overkill_mask = {
		unit = "units/pd2_dlc_overkill_pack/masks/msk_the_overkill_mask/msk_the_overkill_mask",
		name_id = "bm_msk_the_overkill_mask",
		pcs = {},
		value = 0,
		dlc = "overkill_pack",
		texture_bundle_folder = "dlc_pack_overkill",
		type = "glasses"
	}
	self.masks.dallas_glow = {
		unit = "units/pd2_dlc_cop/masks/msk_dallas_glow/msk_dallas_glow",
		name_id = "bm_msk_dallas_glow",
		dlc = "complete_overkill_pack",
		texture_bundle_folder = "dlc_pack_overkill",
		value = 0
	}
	self.masks.wolf_glow = {
		unit = "units/pd2_dlc_cop/masks/msk_wolf_glow/msk_wolf_glow",
		name_id = "bm_msk_wolf_glow",
		dlc = "complete_overkill_pack",
		texture_bundle_folder = "dlc_pack_overkill",
		value = 0
	}
	self.masks.hoxton_glow = {
		unit = "units/pd2_dlc_cop/masks/msk_hoxton_glow/msk_hoxton_glow",
		name_id = "bm_msk_hoxton_glow",
		dlc = "complete_overkill_pack",
		texture_bundle_folder = "dlc_pack_overkill",
		value = 0
	}
	self.masks.chains_glow = {
		unit = "units/pd2_dlc_cop/masks/msk_chains_glow/msk_chains_glow",
		name_id = "bm_msk_chains_glow",
		dlc = "complete_overkill_pack",
		texture_bundle_folder = "dlc_pack_overkill",
		value = 0
	}
	self.masks.jake = {
		unit = "units/pd2_dlc_hotline2/masks/jake/msk_jake",
		name_id = "bm_msk_jake",
		pcs = {},
		texture_bundle_folder = "hlm2",
		dlc = "hlm2",
		value = 0
	}
	self.masks.richter = {
		unit = "units/pd2_dlc_hotline2/masks/richter/msk_richter",
		name_id = "bm_msk_richter",
		pcs = {},
		texture_bundle_folder = "hlm2",
		dlc = "hlm2",
		value = 0
	}
	self.masks.biker = {
		unit = "units/pd2_dlc_hotline2/masks/biker/msk_biker",
		name_id = "bm_msk_biker",
		pcs = {},
		texture_bundle_folder = "hlm2",
		dlc = "hlm2",
		value = 0,
		type = "helmet"
	}
	self.masks.alex = {
		unit = "units/pd2_dlc_hotline2/masks/alex/msk_alex",
		name_id = "bm_msk_alex",
		pcs = {},
		texture_bundle_folder = "hlm2",
		dlc = "hlm2",
		value = 0
	}
	self.masks.corey = {
		unit = "units/pd2_dlc_hotline2/masks/corey/msk_corey",
		name_id = "bm_msk_corey",
		pcs = {},
		texture_bundle_folder = "hlm2",
		dlc = "hlm2",
		value = 0
	}
	self.masks.tonys_revenge = {
		unit = "units/pd2_dlc_hotline2/masks/tonys_revenge/msk_tonys_revenge",
		name_id = "bm_msk_tonys_revenge",
		pcs = {},
		texture_bundle_folder = "hlm2",
		dlc = "hlm2",
		value = 0
	}
	self.masks.richard_returns = {
		unit = "units/pd2_dlc_hotline2/masks/richard_returns/msk_richard_returns",
		name_id = "bm_msk_richard_returns",
		pcs = {},
		texture_bundle_folder = "hlm2",
		dlc = "hlm2_deluxe",
		value = 0,
		type = "helmet"
	}
	self.masks.richard_begins = {
		unit = "units/pd2_dlc_hotline2/masks/richard_begins/msk_richard_begins",
		name_id = "bm_msk_richard_begins",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture_bundle_folder = "hlm2",
		dlc = "hlm2_deluxe",
		value = 0,
		type = "helmet"
	}
	self.masks.simpson = {
		unit = "units/pd2_dlc_cage/masks/simpson/msk_simpson",
		name_id = "bm_msk_simpson",
		pcs = {},
		type = "helmet",
		value = 0
	}
	self.masks.hothead = {
		unit = "units/pd2_speedrunners/masks/hothead/msk_hothead",
		name_id = "bm_msk_hothead",
		pcs = {},
		texture_bundle_folder = "speedrunners",
		dlc = "speedrunners",
		value = 0
	}
	self.masks.falcon = {
		unit = "units/pd2_speedrunners/masks/falcon/msk_falcon",
		name_id = "bm_msk_falcon",
		pcs = {},
		type = "helmet",
		texture_bundle_folder = "speedrunners",
		dlc = "speedrunners",
		value = 0
	}
	self.masks.unic = {
		unit = "units/pd2_speedrunners/masks/unic/msk_unic",
		name_id = "bm_msk_unic",
		pcs = {},
		type = "helmet",
		texture_bundle_folder = "speedrunners",
		dlc = "speedrunners",
		value = 0
	}
	self.masks.speedrunner = {
		unit = "units/pd2_speedrunners/masks/speedrunner/msk_speedrunner",
		name_id = "bm_msk_speedrunner",
		pcs = {},
		type = "helmet",
		texture_bundle_folder = "speedrunners",
		dlc = "speedrunners",
		value = 0
	}
	self.masks.hectors_helmet = {
		unit = "units/pd2_mcmansion/masks/msk_hectors_helmet/msk_hectors_helmet",
		name_id = "bm_msk_hectors_helmet",
		type = "helmet",
		infamous = true,
		pcs = {},
		value = 0,
		texture_bundle_folder = "hoxton_revenge"
	}
	self.masks.old_hoxton_begins = {
		unit = "units/pd2_mcmansion/masks/old_hoxton_begins/msk_old_hoxton_begins",
		name_id = "bm_msk_old_hoxton_begins",
		pcs = {
			10,
			20,
			30,
			40
		},
		global_value = "infamous",
		value = 0,
		texture_bundle_folder = "hoxton_revenge"
	}
	self.masks.firedemon = {
		unit = "units/pd2_dlc_bbq/masks/msk_firedemon/msk_firedemon",
		name_id = "bm_msk_firedemon",
		pcs = {},
		value = 0,
		dlc = "bbq",
		texture_bundle_folder = "bbq"
	}
	self.masks.gasmask = {
		unit = "units/pd2_dlc_bbq/masks/msk_gasmask/msk_gasmask",
		name_id = "bm_msk_gasmask",
		pcs = {},
		value = 0,
		dlc = "bbq",
		texture_bundle_folder = "bbq"
	}
	self.masks.firemask = {
		unit = "units/pd2_dlc_bbq/masks/msk_firemask/msk_firemask",
		name_id = "bm_msk_firemask",
		pcs = {},
		value = 0,
		dlc = "bbq",
		texture_bundle_folder = "bbq"
	}
	self.masks.chef_hat = {
		unit = "units/pd2_dlc_bbq/masks/msk_chef_hat/msk_chef_hat",
		name_id = "bm_msk_chef_hat",
		pcs = {},
		value = 0,
		dlc = "bbq",
		texture_bundle_folder = "bbq",
		type = "helmet"
	}
	self.masks.bandit = {
		unit = "units/pd2_dlc_west/masks/msk_bandit/msk_bandit",
		name_id = "bm_msk_bandit",
		pcs = {},
		dlc = "west",
		texture_bundle_folder = "west",
		value = 0,
		type = "helmet"
	}
	self.masks.bullskull = {
		unit = "units/pd2_dlc_west/masks/msk_bullskull/msk_bullskull",
		name_id = "bm_msk_bullskull",
		pcs = {},
		dlc = "west",
		texture_bundle_folder = "west",
		value = 0
	}
	self.masks.kangee = {
		unit = "units/pd2_dlc_west/masks/msk_kangee/msk_kangee",
		name_id = "bm_msk_kangee",
		pcs = {},
		dlc = "west",
		texture_bundle_folder = "west",
		value = 0
	}
	self.masks.lone = {
		unit = "units/pd2_dlc_west/masks/msk_lone/msk_lone",
		name_id = "bm_msk_lone",
		pcs = {},
		dlc = "west",
		texture_bundle_folder = "west",
		value = 0,
		type = "helmet",
		skip_mask_on_sequence = true,
		offsets = {
			joy = {
				Vector3(0.196759, -0.399472, -0.637965),
				Rotation(-0, -0, -0)
			}
		}
	}
	self.masks.grendel = {
		unit = "units/pd2_dlc_shoutout_raid/masks/grendel/msk_grendel",
		name_id = "bm_msk_grendel",
		pcs = {},
		value = 0,
		global_value = "infamous"
	}
	self.masks.concert_male = {
		unit = "units/pd2_dlc_arena/masks/concert_male/msk_concert_male",
		name_id = "bm_msk_concert_male",
		pcs = {},
		value = 0,
		dlc = "arena",
		texture_bundle_folder = "dlc_arena"
	}
	self.masks.concert_female = {
		unit = "units/pd2_dlc_arena/masks/concert_female/msk_concert_female",
		name_id = "bm_msk_concert_female",
		pcs = {},
		value = 0,
		dlc = "arena",
		texture_bundle_folder = "dlc_arena"
	}
	self.masks.boombox = {
		unit = "units/pd2_dlc_arena/masks/boombox/msk_boombox",
		name_id = "bm_msk_boombox",
		pcs = {},
		value = 0,
		dlc = "arena",
		texture_bundle_folder = "dlc_arena"
	}
	self.masks.cantus = {
		unit = "units/pd2_dlc_arena/masks/cantus/msk_cantus",
		name_id = "bm_msk_cantus",
		pcs = {},
		value = 0,
		dlc = "arena",
		texture_bundle_folder = "dlc_arena"
	}
	self.masks.titan = {
		unit = "units/pd2_dlc_humble_summer15/masks/titan/msk_titan",
		name_id = "bm_msk_titan",
		pcs = {},
		value = 0,
		dlc = "humble_pack3",
		texture_bundle_folder = "humble_summer_2015",
		sort_number = 6
	}
	self.masks.pokachu = {
		unit = "units/pd2_dlc_humble_summer15/masks/pokachu/msk_pokachu",
		name_id = "bm_msk_pokachu",
		pcs = {},
		value = 0,
		dlc = "humble_pack3",
		texture_bundle_folder = "humble_summer_2015",
		sort_number = 6
	}
	self.masks.moon = {
		unit = "units/pd2_dlc_humble_summer15/masks/moon/msk_moon",
		name_id = "bm_msk_moon",
		pcs = {},
		value = 0,
		dlc = "humble_pack4",
		texture_bundle_folder = "humble_summer_2015",
		sort_number = 7
	}
	self.masks.borsuk = {
		unit = "units/pd2_dlc_humble_summer15/masks/borsuk/msk_borsuk",
		name_id = "bm_msk_borsuk",
		pcs = {},
		value = 0,
		dlc = "humble_pack4",
		texture_bundle_folder = "humble_summer_2015",
		sort_number = 7
	}
	self.masks.card_jack = {
		unit = "units/pd2_dlc_playingcards/masks/msk_card_jack/msk_card_jack",
		name_id = "bm_msk_card_jack",
		pcs = {},
		dlc = "e3_s15a",
		texture_bundle_folder = "humble_summer_2015",
		value = 0,
		sort_number = 8
	}
	self.masks.card_queen = {
		unit = "units/pd2_dlc_playingcards/masks/msk_card_queen/msk_card_queen",
		name_id = "bm_msk_card_queen",
		pcs = {},
		dlc = "e3_s15b",
		texture_bundle_folder = "humble_summer_2015",
		value = 0,
		sort_number = 8
	}
	self.masks.card_king = {
		unit = "units/pd2_dlc_playingcards/masks/msk_card_king/msk_card_king",
		name_id = "bm_msk_card_king",
		pcs = {},
		dlc = "e3_s15c",
		texture_bundle_folder = "humble_summer_2015",
		value = 0,
		sort_number = 8
	}
	self.masks.card_joker = {
		unit = "units/pd2_dlc_playingcards/masks/msk_card_joker/msk_card_joker",
		name_id = "bm_msk_card_joker",
		pcs = {},
		dlc = "e3_s15d",
		texture_bundle_folder = "humble_summer_2015",
		value = 0,
		sort_number = 8
	}
	self.masks.king_of_jesters = {
		unit = "units/pd2_dlc_paydaycon2015/masks/king_of_jesters/msk_king_of_jesters",
		name_id = "bm_msk_king_of_jesters",
		pcs = {},
		dlc = "pdcon_2015",
		value = 0,
		sort_number = 9
	}
	self.masks.sokol = {
		unit = "units/pd2_dlc_character_sokol/masks/sokol/msk_sokol",
		name_id = "bm_msk_sokol",
		pcs = {},
		value = 0,
		texture_bundle_folder = "character_pack_sokol",
		dlc = "character_pack_sokol"
	}
	self.masks.sokol_begins = {
		unit = "units/pd2_dlc_character_sokol/masks/sokol_begins/msk_sokol_begins",
		name_id = "bm_msk_sokol_begins",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		texture_bundle_folder = "character_pack_sokol",
		dlc = "character_pack_sokol"
	}
	self.masks.jiro = {
		unit = "units/pd2_dlc_dragon/masks/jiro/msk_jiro",
		name_id = "bm_msk_jiro",
		pcs = {},
		value = 0,
		texture_bundle_folder = "dragon",
		dlc = "dragon"
	}
	self.masks.jiro_begins = {
		unit = "units/pd2_dlc_dragon/masks/jiro_begins/msk_jiro_begins",
		name_id = "bm_msk_jiro_begins",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		texture_bundle_folder = "dragon",
		dlc = "dragon"
	}
	self.masks.croupier_hat = {
		unit = "units/pd2_dlc_casino/masks/msk_croupier_hat/msk_croupier_hat",
		name_id = "bm_msk_croupier_hat",
		pcs = {},
		value = 0,
		dlc = "kenaz",
		texture_bundle_folder = "kenaz",
		type = "glasses",
		offsets = {
			joy = {
				Vector3(0, -0.518719, 0.912237),
				Rotation(-0, -0, -0)
			}
		}
	}
	self.masks.gladiator_helmet = {
		unit = "units/pd2_dlc_casino/masks/msk_gladiator/msk_gladiator",
		name_id = "bm_msk_gladiator_helmet",
		pcs = {},
		value = 0,
		dlc = "kenaz",
		texture_bundle_folder = "kenaz",
		type = "helmet"
	}
	self.masks.the_king_mask = {
		unit = "units/pd2_dlc_casino/masks/msk_the_king/msk_the_king",
		name_id = "bm_msk_the_king_mask",
		pcs = {},
		value = 0,
		dlc = "kenaz",
		texture_bundle_folder = "kenaz",
		type = "helmet"
	}
	self.masks.sports_utility_mask = {
		unit = "units/pd2_dlc_casino/masks/msk_sports_utility/msk_sports_utility",
		name_id = "bm_msk_sports_utility_mask",
		pcs = {},
		value = 0,
		dlc = "kenaz",
		texture_bundle_folder = "kenaz"
	}
	self.masks.starvr = {
		unit = "units/pd2_dlc_humble_summer15/masks/starvr/msk_starvr",
		name_id = "bm_msk_starvr",
		pcs = {},
		value = 0,
		infamous = true,
		texture_bundle_folder = "humble_summer_2015",
		type = "helmet"
	}
	self.masks.slicer = {
		unit = "units/pd2_dlc_turtles/masks/slicer/msk_slicer",
		name_id = "bm_msk_slicer",
		pcs = {},
		value = 0,
		texture_bundle_folder = "turtles",
		dlc = "turtles"
	}
	self.masks.kage = {
		unit = "units/pd2_dlc_turtles/masks/kage/msk_kage",
		name_id = "bm_msk_kage",
		pcs = {},
		value = 0,
		texture_bundle_folder = "turtles",
		dlc = "turtles"
	}
	self.masks.ninja_hood = {
		unit = "units/pd2_dlc_turtles/masks/ninja_hood/msk_ninja_hood",
		name_id = "bm_msk_ninja_hood",
		pcs = {},
		value = 0,
		type = "helmet",
		texture_bundle_folder = "turtles",
		dlc = "turtles"
	}
	self.masks.shirai = {
		unit = "units/pd2_dlc_turtles/masks/shirai/msk_shirai",
		name_id = "bm_msk_shirai",
		pcs = {},
		value = 0,
		type = "helmet",
		skip_mask_on_sequence = true,
		texture_bundle_folder = "turtles",
		dlc = "turtles"
	}
	self.masks.bobblehead_dozer = {
		unit = "units/pd2_merchandise/masks/msk_bobblehead_dozer/msk_bobblehead_dozer",
		name_id = "bm_msk_bobblehead_dozer",
		pcs = {},
		value = 0,
		texture_bundle_folder = "merchandise",
		dlc = "bobblehead",
		type = "helmet",
		sort_number = 9
	}
	self.masks.mason_knight_veteran = {
		unit = "units/pd2_dlc_steel/masks/mason_knight_veteran/msk_mason_knight_veteran",
		name_id = "bm_msk_mason_knight_veteran",
		pcs = {},
		value = 0,
		dlc = "steel",
		texture_bundle_folder = "steel",
		type = "helmet"
	}
	self.masks.agatha_knight = {
		unit = "units/pd2_dlc_steel/masks/agatha_knight/msk_agatha_knight",
		name_id = "bm_msk_agatha_knight",
		pcs = {},
		value = 0,
		dlc = "steel",
		texture_bundle_folder = "steel",
		type = "helmet"
	}
	self.masks.agatha_vanguard_veteran = {
		unit = "units/pd2_dlc_steel/masks/agatha_vanguard_veteran/msk_agatha_vanguard_veteran",
		name_id = "bm_msk_agatha_vanguard_veteran",
		pcs = {},
		value = 0,
		dlc = "steel",
		texture_bundle_folder = "steel",
		type = "helmet"
	}
	self.masks.mason_vanguard_veteran = {
		unit = "units/pd2_dlc_steel/masks/mason_vanguard_veteran/msk_mason_vanguard_veteran",
		name_id = "bm_msk_mason_vanguard_veteran",
		pcs = {},
		value = 0,
		dlc = "steel",
		texture_bundle_folder = "steel",
		type = "helmet"
	}
	self.masks.rus_hat = {
		unit = "units/pd2_crimefest_2015/update_2/masks/rus_hat/msk_rus_hat",
		name_id = "bm_msk_rus_hat",
		pcs = {
			10,
			20,
			30,
			40
		},
		sort_number = 8,
		value = 0,
		type = "helmet"
	}
	self.masks.sputnik = {
		unit = "units/pd2_crimefest_2015/update_2/masks/sputnik/msk_sputnik",
		name_id = "bm_msk_sputnik",
		pcs = {
			10,
			20,
			30,
			40
		},
		sort_number = 8,
		value = 0,
		type = "helmet"
	}
	self.masks.tiara = {
		unit = "units/pd2_crimefest_2015/update_2/masks/tiara/msk_tiara",
		name_id = "bm_msk_tiara",
		pcs = {
			10,
			20,
			30,
			40
		},
		sort_number = 8,
		value = 0,
		type = "tiara",
		skip_mask_on_sequence = true,
		offsets = {
			joy = {
				Vector3(2.93943, 2.46244, -4.45385),
				Rotation(16.871, 22.0224, 0.558107)
			},
			sydney = {
				Vector3(0, -1.71118, 5.08586),
				Rotation(0, -20.9063, 0)
			}
		}
	}
	self.masks.baba_yaga = {
		unit = "units/pd2_crimefest_2015/update_2/masks/baba_yaga/msk_baba_yaga",
		name_id = "bm_msk_baba_yaga",
		pcs = {
			10,
			20,
			30,
			40
		},
		sort_number = 8,
		value = 0
	}
	self.masks.vlad_armor = {
		unit = "units/pd2_crimefest_2015/update_2/masks/vlad_armor/msk_vlad_armor",
		name_id = "bm_msk_vlad_armor",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		sort_number = 8,
		type = "helmet"
	}
	self.masks.lcv = {
		unit = "units/pd2_dlc_rave/masks/msk_lcv",
		name_id = "bm_msk_lcv",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		sort_number = 9,
		texture_bundle_folder = "rave"
	}
	self.masks.pirate_skull = {
		unit = "units/pd2_crimefest_2015/update_8/masks/pirate_skull/msk_pirate_skull",
		name_id = "bm_msk_pirate_skull",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		sort_number = 10,
		type = "helmet"
	}
	self.masks.fatboy = {
		unit = "units/pd2_crimefest_2015/update_8/masks/msk_fatboy/msk_fatboy",
		name_id = "bm_msk_fatboy",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		sort_number = 10
	}
	self.masks.oliver = {
		unit = "units/pd2_crimefest_2015/update_8/masks/oliver/msk_oliver",
		name_id = "bm_msk_oliver",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		sort_number = 10,
		default_blueprint = {
			materials = "deep_bronze",
			textures = "no_color_full_material"
		}
	}
	self.masks.eggian = {
		unit = "units/pd2_crimefest_2015/update_8/masks/eggian/msk_eggian",
		name_id = "bm_msk_eggian",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		sort_number = 10
	}
	self.masks.groucho_glasses = {
		unit = "units/pd2_crimefest_2015/update_9/masks/msk_groucho_glasses/msk_groucho_glasses",
		name_id = "bm_msk_groucho",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		type = "glasses",
		sort_number = 11,
		skip_mask_on_sequence = true
	}
	self.masks.glasses_tinted_love = {
		unit = "units/pd2_crimefest_2015/update_9/masks/msk_tinted_love/msk_glasses_tinted_love",
		name_id = "bm_msk_tinted_love",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		type = "glasses",
		sort_number = 11,
		skip_mask_on_sequence = true
	}
	self.masks.baitface = {
		unit = "units/pd2_crimefest_2015/update_10/masks/baitface/msk_baitface",
		name_id = "bm_msk_baitface",
		pcs = {},
		value = 0,
		sort_number = 12
	}
	self.masks.nomegusta = {
		unit = "units/pd2_crimefest_2015/update_10/masks/nomegusta/msk_nomegusta",
		name_id = "bm_msk_nomegusta",
		pcs = {},
		value = 0,
		sort_number = 12
	}
	self.masks.rageface = {
		unit = "units/pd2_crimefest_2015/update_10/masks/rageface/msk_rageface",
		name_id = "bm_msk_rageface",
		pcs = {},
		value = 0,
		sort_number = 12
	}
	self.masks.dawg = {
		unit = "units/pd2_crimefest_2015/update_10/masks/msk_dawg/msk_dawg",
		name_id = "bm_msk_dawg",
		pcs = {},
		value = 0,
		sort_number = 12
	}
	self.masks.invader = {
		unit = "units/pd2_dlc_nails/masks/invader/msk_invader",
		name_id = "bm_msk_invader",
		global_value = "halloween",
		texture_bundle_folder = "nails",
		sort_number = 3,
		value = 0
	}
	self.masks.satan = {
		unit = "units/pd2_dlc_nails/masks/satan/msk_satan",
		name_id = "bm_msk_satan",
		global_value = "halloween",
		texture_bundle_folder = "nails",
		sort_number = 3,
		value = 0
	}
	self.masks.tormentor = {
		unit = "units/pd2_dlc_tormentor_mask/masks/tormentor/msk_tormentor",
		name_id = "bm_msk_tormentor",
		pcs = {},
		value = 0,
		sort_number = 12
	}
	self.masks.bodhi = {
		unit = "units/pd2_dlc_rip/masks/bodhi/msk_bodhi",
		name_id = "bm_msk_bodhi",
		pcs = {},
		value = 0,
		global_value = "infamous",
		texture_bundle_folder = "rip"
	}
	self.masks.bodhi_begins = {
		unit = "units/pd2_dlc_rip/masks/bodhi_begins/msk_bodhi_begins",
		name_id = "bm_msk_bodhi_begins",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		global_value = "infamous",
		texture_bundle_folder = "rip"
	}
	self.masks.water_spirit = {
		unit = "units/pd2_dlc_jerry/masks/msk_water_spirit/msk_water_spirit",
		name_id = "bm_msk_water_spirit",
		pcs = {},
		value = 0,
		dlc = "berry",
		texture_bundle_folder = "berry"
	}
	self.masks.tane = {
		unit = "units/pd2_dlc_jerry/masks/tane/msk_tane",
		name_id = "bm_msk_tane",
		pcs = {},
		value = 0,
		dlc = "berry",
		texture_bundle_folder = "berry"
	}
	self.masks.oro = {
		unit = "units/pd2_dlc_jerry/masks/oro/msk_oro",
		name_id = "bm_msk_oro",
		pcs = {},
		value = 0,
		dlc = "berry",
		texture_bundle_folder = "berry"
	}
	self.masks.maui = {
		unit = "units/pd2_dlc_jerry/masks/maui/msk_maui",
		name_id = "bm_msk_maui",
		pcs = {},
		value = 0,
		dlc = "berry",
		texture_bundle_folder = "berry"
	}
	self.masks.rudeolph = {
		unit = "units/pd2_dlc_cane/masks/rudeolph/msk_rudeolph",
		name_id = "bm_msk_rudeolph",
		type = "tiara",
		pcs = {},
		value = 0,
		sort_number = 13
	}
	self.masks.greedy_the_elf = {
		unit = "units/pd2_dlc_cane/masks/greedy_the_elf/msk_greedy_the_elf",
		name_id = "bm_msk_greedy_the_elf",
		type = "hat",
		pcs = {},
		value = 0,
		sort_number = 13
	}
	self.masks.tall_goat = {
		unit = "units/pd2_dlc_peta/masks/mask_tall_goat/msk_tall_goat",
		name_id = "bm_msk_tall_goat",
		pcs = {},
		value = 0,
		sort_number = 14,
		dlc = "peta",
		texture_bundle_folder = "peta"
	}
	self.masks.goat_goat = {
		unit = "units/pd2_dlc_peta/masks/mask_goat/msk_goat_goat",
		name_id = "bm_msk_goat_goat",
		pcs = {},
		value = 0,
		sort_number = 14,
		dlc = "peta",
		texture_bundle_folder = "peta"
	}
	self.masks.wet_goat = {
		unit = "units/pd2_dlc_peta/masks/mask_wet_goat/msk_wet_goat",
		name_id = "bm_msk_slimy_goat",
		pcs = {},
		value = 0,
		sort_number = 14,
		dlc = "peta",
		texture_bundle_folder = "peta"
	}
	self.masks.fancy_goat = {
		unit = "units/pd2_dlc_peta/masks/mask_fancy_goat/msk_fancy_goat",
		name_id = "bm_msk_fancy_goat",
		pcs = {},
		value = 0,
		sort_number = 14,
		dlc = "peta",
		texture_bundle_folder = "peta"
	}
	self.masks.devourer = {
		unit = "units/pd2_dlc_dbd_community/masks/devourer/msk_devourer",
		name_id = "bm_msk_devourer",
		pcs = {},
		value = 0,
		dlc = "dbd_clan",
		texture_bundle_folder = "daylight"
	}
	self.masks.unborn = {
		unit = "units/pd2_dlc_dbd_community/masks/unborn/msk_unborn",
		name_id = "bm_msk_unborn",
		pcs = {},
		value = 0,
		dlc = "dbd_clan",
		texture_bundle_folder = "daylight"
	}
	self.masks.horned_king = {
		unit = "units/pd2_dlc_lupus/masks/lupus_horned_king/msk_horned_king",
		name_id = "bm_msk_horned_king",
		type = "tiara",
		pcs = {},
		value = 0,
		dlc = "pal",
		texture_bundle_folder = "lupus",
		sort_number = 15,
		offsets = {
			joy = {
				Vector3(0, 1.15073, -0.518717),
				Rotation(-0, -0, -0)
			}
		}
	}
	self.masks.viking = {
		unit = "units/pd2_dlc_lupus/masks/lupus_viking/msk_viking",
		name_id = "bm_msk_viking",
		pcs = {},
		value = 0,
		dlc = "pal",
		texture_bundle_folder = "lupus",
		sort_number = 15
	}
	self.masks.nutcracker = {
		unit = "units/pd2_dlc_lupus/masks/lupus_nutcracker/msk_nutcracker",
		name_id = "bm_msk_nutcracker",
		pcs = {},
		value = 0,
		dlc = "pal",
		texture_bundle_folder = "lupus",
		sort_number = 15
	}
	self.masks.divided = {
		unit = "units/pd2_dlc_lupus/masks/lupus_divided/msk_divided",
		name_id = "bm_msk_divided",
		pcs = {},
		value = 0,
		dlc = "pal",
		texture_bundle_folder = "lupus",
		sort_number = 15
	}
	self.masks.megacthulhu = {
		unit = "units/pd2_dlc_super/masks/megacthulu/msk_megacthulhu",
		name_id = "bm_msk_megacthulhu",
		dlc = "complete_overkill_pack",
		texture_bundle_folder = "super",
		value = 0
	}
	self.masks.hunter = {
		unit = "units/pd2_dlc_super/masks/hunter/msk_hunter",
		name_id = "bm_msk_hunter",
		dlc = "complete_overkill_pack",
		texture_bundle_folder = "super",
		value = 0
	}
	self.masks.cop_skull = {
		unit = "units/pd2_dlc_super/masks/cop_skull/msk_cop_skull",
		name_id = "bm_cop_mega_skull",
		dlc = "complete_overkill_pack",
		texture_bundle_folder = "super",
		value = 0
	}
	self.masks.cop_plague_doctor = {
		unit = "units/pd2_dlc_super/masks/cop_plague_doctor/msk_cop_plague_doctor",
		name_id = "bm_cop_plague_doctor",
		dlc = "complete_overkill_pack",
		texture_bundle_folder = "super",
		value = 0
	}
	self.masks.cop_kawaii = {
		unit = "units/pd2_dlc_super/masks/cop_kawaii/msk_cop_kawaii",
		name_id = "bm_cop_kawaii",
		dlc = "complete_overkill_pack",
		texture_bundle_folder = "super",
		value = 0
	}
	self.masks.jimmy = {
		unit = "units/pd2_dlc_coco/masks/jimmy/msk_jimmy",
		name_id = "bm_msk_jimmy",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		global_value = "infamous",
		texture_bundle_folder = "coco",
		sort_number = 16
	}
	self.masks.jimmy_duct = {
		unit = "units/pd2_dlc_coco/masks/jimmy_duct/msk_jimmy_duct",
		name_id = "bm_msk_jimmy_duct",
		pcs = {},
		value = 0,
		global_value = "infamous",
		texture_bundle_folder = "coco",
		sort_number = 16
	}
	self.masks.half_mask = {
		unit = "units/pd2_dlc_mad/masks/mad_halv_mask/msk_half_mask",
		name_id = "bm_msk_andromeda",
		pcs = {},
		value = 0,
		type = "helmet",
		skip_mask_on_sequence = true,
		texture_bundle_folder = "mad",
		sort_number = 17
	}
	self.masks.visor = {
		unit = "units/pd2_dlc_mad/masks/mad_helmet_mask/msk_visor",
		name_id = "bm_msk_visor",
		pcs = {},
		value = 0,
		type = "helmet",
		texture_bundle_folder = "mad",
		sort_number = 17
	}
	self.masks.mad_goggles = {
		unit = "units/pd2_dlc_mad/masks/mad_goggles/msk_mad_goggles",
		name_id = "bm_msk_goggles",
		pcs = {},
		value = 0,
		type = "helmet",
		texture_bundle_folder = "mad",
		sort_number = 17,
		night_vision = {
			effect = "color_night_vision_blue",
			light = not _G.IS_VR and 0.3 or 0.1
		}
	}
	self.masks.mad_mask = {
		unit = "units/pd2_dlc_mad/masks/mad_mask/msk_mad_mask",
		name_id = "bm_msk_mad_mask",
		pcs = {},
		value = 0,
		texture_bundle_folder = "mad",
		sort_number = 17
	}
	self.masks.dbd_01 = {
		unit = "units/pd2_dlc_boo_1/masks/msk_dbd_01",
		name_id = "bm_msk_dbd_01",
		pcs = {},
		value = 0,
		type = "helmet",
		texture_bundle_folder = "boo_1",
		dlc = "dbd_clan",
		sort_number = 18
	}
	self.masks.dbd_02 = {
		unit = "units/pd2_dlc_boo_2/masks/msk_dbd_02",
		name_id = "bm_msk_dbd_02",
		pcs = {},
		value = 0,
		texture_bundle_folder = "boo_2",
		dlc = "dbd_deluxe",
		sort_number = 18
	}
	self.masks.dbd_03 = {
		unit = "units/pd2_dlc_boo_3/masks/msk_dbd_03",
		name_id = "bm_msk_dbd_03",
		pcs = {},
		value = 0,
		texture_bundle_folder = "boo_3",
		dlc = "dbd_deluxe",
		sort_number = 18
	}
	self.masks.dbd_04 = {
		unit = "units/pd2_dlc_boo/masks/dbd_04/msk_boo_dbd_04",
		name_id = "bm_msk_dbd_00",
		pcs = {},
		value = 0,
		texture_bundle_folder = "boo",
		dlc = "dbd_clan",
		sort_number = 18
	}
	self.masks.dbd_slasher = {
		unit = "units/pd2_dlc_boo_4/masks/msk_dbd_slasher",
		name_id = "bm_msk_dbd_04",
		pcs = {},
		value = 0,
		type = "helmet",
		texture_bundle_folder = "boo_4",
		dlc = "dbd_clan",
		sort_number = 18
	}
	self.masks.sydney = {
		unit = "units/pd2_dlc_opera/masks/sydney/msk_sydney",
		name_id = "bm_msk_sydney",
		pcs = {},
		value = 0,
		dlc = "opera",
		texture_bundle_folder = "opera",
		sort_number = 19
	}
	self.masks.sydney_begins = {
		unit = "units/pd2_dlc_opera/masks/sydney_begins/msk_sydney_begins",
		name_id = "bm_msk_sydney_begins",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		dlc = "opera",
		texture_bundle_folder = "opera",
		sort_number = 19
	}
	self.masks.jig_01 = {
		unit = "units/pd2_dlc_jigg/masks/mask_jigg_01/msk_jig_01",
		name_id = "bm_msk_jig_01",
		value = 0,
		texture_bundle_folder = "jigg",
		dlc = "jigg",
		sort_number = 20
	}
	self.masks.jig_02 = {
		unit = "units/pd2_dlc_jigg/masks/mask_jigg_02/msk_jig_02",
		name_id = "bm_msk_jig_02",
		value = 0,
		texture_bundle_folder = "jigg",
		type = "helmet",
		dlc = "jigg",
		sort_number = 20
	}
	self.masks.damned = {
		unit = "units/pd2_dlc_jigg/masks/damned/msk_damned",
		name_id = "bm_msk_damned",
		value = 0,
		texture_bundle_folder = "jigg",
		dlc = "jigg",
		sort_number = 20
	}
	self.masks.born_biker_01 = {
		unit = "units/pd2_dlc_born/masks/born_01/msk_born_biker_01",
		name_id = "bm_msk_biker_classic",
		pcs = {},
		value = 0,
		type = "helmet",
		texture_bundle_folder = "born",
		sort_number = 21,
		dlc = "born"
	}
	self.masks.born_biker_02 = {
		unit = "units/pd2_dlc_born/masks/born_02/msk_born_biker_02",
		name_id = "bm_msk_speed_demon",
		pcs = {},
		value = 0,
		texture_bundle_folder = "born",
		sort_number = 21,
		dlc = "born"
	}
	self.masks.born_biker_03 = {
		unit = "units/pd2_dlc_born/masks/born_03/msk_born_biker_03",
		name_id = "bm_msk_rage_demon",
		pcs = {},
		value = 0,
		type = "helmet",
		texture_bundle_folder = "born",
		sort_number = 21,
		dlc = "born",
		offsets = {
			joy = {
				Vector3(0, -0.637965, 0.435252),
				Rotation(-0.30048, -8.88622, -1.66753e-09)
			}
		}
	}
	self.masks.brutal = {
		unit = "units/pd2_dlc_born/masks/brutal/msk_brutal",
		name_id = "bm_msk_brutal",
		pcs = {},
		value = 0,
		texture_bundle_folder = "born",
		sort_number = 21,
		dlc = "born"
	}
	self.masks.rust = {
		unit = "units/pd2_dlc_wild/masks/rust/msk_rust",
		name_id = "bm_msk_rust",
		pcs = {},
		value = 0,
		texture_bundle_folder = "wild",
		sort_number = 22,
		dlc = "wild"
	}
	self.masks.rust_begins = {
		unit = "units/pd2_dlc_wild/masks/rust_begins/msk_rust_begins",
		name_id = "bm_msk_rust_begins",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		texture_bundle_folder = "wild",
		sort_number = 22,
		dlc = "wild"
	}
	self.masks.fab_mega_grin = {
		unit = "units/pd2_dlc_fab/masks/mega_grin/msk_fab_mega_grin",
		name_id = "bm_msk_mega_grin",
		value = 0,
		texture_bundle_folder = "fab",
		dlc = "complete_overkill_pack"
	}
	self.masks.fab_mega_doctor = {
		unit = "units/pd2_dlc_fab/masks/mega_doctor/msk_fab_mega_doctor",
		name_id = "bm_msk_mega_doctor",
		value = 0,
		texture_bundle_folder = "fab",
		dlc = "complete_overkill_pack"
	}
	self.masks.fab_mega_alien = {
		unit = "units/pd2_dlc_fab/masks/mega_alien/msk_fab_mega_alien",
		name_id = "bm_msk_mega_alien",
		value = 0,
		texture_bundle_folder = "fab",
		dlc = "complete_overkill_pack"
	}
	self.masks.cop_mega_gage_blade = {
		unit = "units/pd2_dlc_fab/masks/cop_mega_gage_blade/msk_cop_mega_gage_blade",
		name_id = "bm_msk_mega_blade",
		value = 0,
		texture_bundle_folder = "fab",
		dlc = "complete_overkill_pack"
	}
	self.masks.fab_mega_mark = {
		unit = "units/pd2_dlc_fab/masks/mega_bear/msk_fab_mega_mark",
		name_id = "bm_msk_mega_mark",
		value = 0,
		texture_bundle_folder = "fab",
		dlc = "complete_overkill_pack"
	}
	self.masks.solus = {
		unit = "units/pd2_dlc_solus/masks/msk_solus",
		name_id = "bm_msk_solus",
		pcs = {},
		value = 0,
		texture_bundle_folder = "solus",
		sort_number = 23,
		dlc = "solus_clan"
	}
	self.masks.mig_death = {
		unit = "units/pd2_dlc_migg/masks/migg_death/msk_mig_death",
		name_id = "bm_msk_death_rider",
		pcs = {},
		value = 0,
		texture_bundle_folder = "migg",
		sort_number = 24,
		dlc = "pd2_clan"
	}
	self.masks.mig_war = {
		unit = "units/pd2_dlc_migg/masks/migg_war/msk_mig_war",
		name_id = "bm_msk_war",
		pcs = {},
		value = 0,
		type = "helmet",
		texture_bundle_folder = "migg",
		sort_number = 24,
		dlc = "pd2_clan"
	}
	self.masks.mig_conquest = {
		unit = "units/pd2_dlc_migg/masks/migg_conquest/msk_mig_conquest",
		name_id = "bm_msk_conquest",
		pcs = {},
		value = 0,
		texture_bundle_folder = "migg",
		sort_number = 24,
		dlc = "pd2_clan"
	}
	self.masks.mig_famine = {
		unit = "units/pd2_dlc_migg/masks/migg_famine/msk_mig_famine",
		name_id = "bm_msk_famine",
		pcs = {},
		value = 0,
		texture_bundle_folder = "migg",
		sort_number = 24,
		dlc = "pd2_clan"
	}
	self.masks.fib_fox = {
		unit = "units/pd2_dlc_fibb/masks/fib_fox_mask/msk_fib_fox",
		name_id = "bm_msk_fable_fox",
		pcs = {},
		value = 0,
		texture_bundle_folder = "fibb",
		sort_number = 25,
		dlc = "pd2_clan"
	}
	self.masks.fib_cat = {
		unit = "units/pd2_dlc_fibb/masks/fib_cat_mask/msk_fib_cat",
		name_id = "bm_msk_fable_cat",
		pcs = {},
		value = 0,
		texture_bundle_folder = "fibb",
		sort_number = 25,
		dlc = "pd2_clan"
	}
	self.masks.fib_mouse = {
		unit = "units/pd2_dlc_fibb/masks/fib_mouse_mask/msk_fib_mouse",
		name_id = "bm_msk_fable_mouse",
		pcs = {},
		value = 0,
		texture_bundle_folder = "fibb",
		sort_number = 25,
		dlc = "pd2_clan"
	}
	self.masks.fib_hare = {
		unit = "units/pd2_dlc_fibb/masks/fib_hare_mask/msk_fib_hare",
		name_id = "bm_msk_fable_hare",
		pcs = {},
		value = 0,
		texture_bundle_folder = "fibb",
		sort_number = 25,
		dlc = "pd2_clan"
	}
	self.masks.pim_dog = {
		unit = "units/pd2_dlc_pim/masks/pim_dog_mask/msk_pim_dog",
		name_id = "bm_msk_pim_daisy",
		pcs = {},
		value = 0,
		texture_bundle_folder = "pim",
		sort_number = 26,
		dlc = "pim"
	}
	self.masks.pim_russian_ballistic = {
		unit = "units/pd2_dlc_pim/masks/pim_russian_ballistic_mask/msk_pim_russian_ballistic",
		name_id = "bm_msk_pim_dirty_russian",
		pcs = {},
		value = 0,
		texture_bundle_folder = "pim",
		sort_number = 26,
		dlc = "pim"
	}
	self.masks.pim_hotelier = {
		unit = "units/pd2_dlc_pim/masks/pim_hotelier_mask/msk_pim_hotelier",
		name_id = "bm_msk_pim_hotelier",
		pcs = {},
		value = 0,
		texture_bundle_folder = "pim",
		sort_number = 26,
		dlc = "pim"
	}
	self.masks.pim_mustang = {
		unit = "units/pd2_dlc_pim/masks/pim_mustang_mask/msk_pim_mustang",
		name_id = "bm_msk_pim_mustang",
		pcs = {},
		value = 0,
		type = "helmet",
		texture_bundle_folder = "pim",
		sort_number = 26,
		dlc = "pim"
	}
	self.masks.nyck_cap = {
		unit = "units/pd2_crimefest_2016/nyck/masks/nyck_cap_mask/msk_nck_cap",
		name_id = "bm_jar_head",
		pcs = {},
		value = 0,
		type = "tiara",
		texture_bundle_folder = "nyck",
		sort_number = 27
	}
	self.masks.nyck_ace = {
		unit = "units/pd2_crimefest_2016/nyck/masks/nyck_ace_mask/msk_nck_ace",
		name_id = "bm_ace",
		pcs = {},
		value = 0,
		type = "helmet",
		texture_bundle_folder = "nyck",
		sort_number = 27
	}
	self.masks.nyck_beret = {
		unit = "units/pd2_crimefest_2016/nyck/masks/nyck_beret_mask/msk_nck_beret",
		name_id = "bm_beret",
		pcs = {},
		value = 0,
		type = "tiara",
		texture_bundle_folder = "nyck",
		sort_number = 27,
		offsets = {
			joy = {
				Vector3(0.316008, 1.86621, 0.316008),
				Rotation(-0, -0, -0)
			}
		}
	}
	self.masks.nyck_pickle = {
		unit = "units/pd2_crimefest_2016/nyck/masks/nyck_pickle_mask/msk_nck_pickle",
		name_id = "bm_mr_pickle",
		pcs = {},
		value = 0,
		texture_bundle_folder = "nyck",
		sort_number = 27
	}
	self.masks.spk_party = {
		unit = "units/pd2_dlc_sparkle/masks/sparkle_party/msk_spk_party",
		name_id = "bm_sparkle_party",
		pcs = {},
		value = 0,
		type = "tiara",
		texture_bundle_folder = "sparkle",
		skip_mask_on_sequence = true,
		sort_number = 28,
		dlc = "sparkle",
		offsets = {
			sydney = {
				Vector3(-0.876458, -3.14214, 7.23229),
				Rotation(0, -27.7748, 0)
			},
			dragon = {
				Vector3(-0.637965, -2.30741, 2.22395),
				Rotation(0, -8.02764, 0)
			},
			female_1 = {
				Vector3(-0.995704, -0.399472, 0.673745),
				Rotation(0, 0, -0)
			},
			hoxton = {
				Vector3(-0.995704, -1.83043, 0.316006),
				Rotation(0, 0, -0)
			},
			sokol = {
				Vector3(0.316006, -2.66515, 0),
				Rotation(0, 0, -0)
			},
			wolf = {
				Vector3(-0.637965, -2.42666, 2.46244),
				Rotation(0, -13.1791, 0)
			},
			bodhi = {
				Vector3(-0.876458, -1.59194, 1.50847),
				Rotation(0, -7.16907, 0)
			},
			jimmy = {
				Vector3(0, 0.792991, 0),
				Rotation(0, 0, -0)
			},
			jacket = {
				Vector3(-0.0417333, -0.995704, 0.196759),
				Rotation(0, 10.861, 0)
			},
			dallas = {
				Vector3(-1.11495, -1.11495, 0),
				Rotation(0, 2.27524, 0)
			},
			joy = {
				Vector3(0.196759, 0.554498, 0),
				Rotation(0, 0, -0)
			},
			bonnie = {
				Vector3(-1.47269, -1.71118, 4.60887),
				Rotation(0, -20.9063, 0)
			},
			chains = {
				Vector3(-0.637965, -1.35344, -2.42666),
				Rotation(0, 16.871, 0)
			},
			old_hoxton = {
				Vector3(-0.637965, -2.06892, 0),
				Rotation(0, 0, -0)
			},
			wild = {
				Vector3(-4.21536, -2.18817, 0.673745),
				Rotation(-14.0377, -9.74479, 15.1538)
			},
			ecp_female = {
				Vector3(-0.757211, -2.18817, 3.05867),
				Rotation(0, -15.7548, 0)
			},
			ecp_male = {
				Vector3(0, -1.83043, 1.03148),
				Rotation(0, 0, -0)
			},
			max = {
				Vector3(-0.637965, -1.59194, 0.435252),
				Rotation(0, -4.59335, 0)
			},
			chico = {
				Vector3(-0.399472, -3.26138, 4.48963),
				Rotation(0, -21.7648, 0)
			},
			myh = {
				Vector3(-0.876458, -2.18817, 0),
				Rotation(0, -2.01763, 0)
			},
			jowi = {
				Vector3(-0.399472, -1.71118, 1.38922),
				Rotation(0, 0, -0)
			},
			dragan = {
				Vector3(-0.399472, -2.18817, 2.70093),
				Rotation(0, -11.4619, 0)
			}
		}
	}
	self.masks.gti_al_capone = {
		unit = "units/pd2_dlc_gotti/masks/al_capone/msk_gti_al_capone",
		name_id = "bm_al_pacino",
		pcs = {},
		value = 0,
		texture_bundle_folder = "gotti",
		sort_number = 29
	}
	self.masks.gti_bugsy = {
		unit = "units/pd2_dlc_gotti/masks/bugsy/msk_gti_bugsy",
		name_id = "bm_bugsy",
		pcs = {},
		value = 0,
		texture_bundle_folder = "gotti",
		sort_number = 29
	}
	self.masks.gti_madame_st_claire = {
		unit = "units/pd2_dlc_gotti/masks/madame/msk_gti_madame_st_claire",
		name_id = "bm_madame_st_claire",
		pcs = {},
		value = 0,
		texture_bundle_folder = "gotti",
		sort_number = 29
	}
	self.masks.gti_lucky_luciano = {
		unit = "units/pd2_dlc_gotti/masks/lucky_luciano/msk_gti_lucky_luciano",
		name_id = "bm_lucky_luciano",
		pcs = {},
		value = 0,
		texture_bundle_folder = "gotti",
		sort_number = 29
	}
	self.masks.urf_seal = {
		unit = "units/pd2_dlc_urf/masks/msk_urf_seal",
		name_id = "bm_sad_seal",
		pcs = {},
		value = 0,
		texture_bundle_folder = "urf",
		sort_number = 31
	}
	self.masks.hwl_dallas_zombie = {
		unit = "units/pd2_dlc_howl/masks/dallas_zombie/msk_hwl_dallas_zombie",
		name_id = "bm_dallas_rising",
		pcs = {},
		value = 0,
		texture_bundle_folder = "howl",
		sort_number = 32,
		global_value = "halloween"
	}
	self.masks.hwl_wolf_zombie = {
		unit = "units/pd2_dlc_howl/masks/wolf_zombie/msk_hwl_wolf_zombie",
		name_id = "bm_wolf_rising",
		pcs = {},
		value = 0,
		texture_bundle_folder = "howl",
		sort_number = 32,
		global_value = "halloween"
	}
	self.masks.hwl_hoxton_zombie = {
		unit = "units/pd2_dlc_howl/masks/hoxton_zombie/msk_hwl_hoxton_zombie",
		name_id = "bm_hoxton_rising",
		pcs = {},
		value = 0,
		texture_bundle_folder = "howl",
		sort_number = 32,
		global_value = "halloween"
	}
	self.masks.howl_chains_zombie = {
		unit = "units/pd2_dlc_howl/masks/chains_zombie/msk_howl_chains_zombie",
		name_id = "bm_chains_rising",
		pcs = {},
		value = 0,
		texture_bundle_folder = "howl",
		sort_number = 32,
		global_value = "halloween"
	}
	self.masks.pdc16_clover = {
		unit = "units/pd2_dlc_paydaycon2016/masks/msk_pdc16_clover",
		name_id = "bm_mega_clover",
		pcs = {},
		value = 0,
		texture_bundle_folder = "pdc16",
		sort_number = 33,
		global_value = "pdcon_2016",
		dlc = "pdcon_2016"
	}
	self.masks.win_donald = {
		unit = "units/pd2_dlc_win/masks/msk_win_donald/msk_win_donald",
		name_id = "bm_donald",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		texture_bundle_folder = "win",
		sort_number = 34
	}
	self.masks.win_donald_mega = {
		unit = "units/pd2_dlc_win/masks/msk_win_donald_mega/msk_win_donald_mega",
		name_id = "bm_donald_mega",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		texture_bundle_folder = "win",
		sort_number = 34
	}
	self.masks.tng_bandana = {
		unit = "units/pd2_dlc_tng/masks/tng_bandana/msk_tng_bandana",
		name_id = "bm_bandana",
		pcs = {},
		value = 0,
		type = "tiara",
		texture_bundle_folder = "tng",
		sort_number = 35,
		skip_mask_on_sequence = true,
		dlc = "tango",
		offsets = {
			joy = {
				Vector3(0.0775149, 0, 0),
				Rotation(-0, -0, -0)
			}
		}
	}
	self.masks.tng_cloaker = {
		unit = "units/pd2_dlc_tng/masks/tng_cloaker/msk_tng_cloaker",
		name_id = "bm_cloaker",
		pcs = {},
		value = 0,
		type = "helmet",
		texture_bundle_folder = "tng",
		sort_number = 35,
		dlc = "tango",
		night_vision = {
			effect = "color_night_vision",
			light = not _G.IS_VR and 0.3 or 0.1
		}
	}
	self.masks.tng_zeal_swat_mask = {
		unit = "units/pd2_dlc_tng/masks/tng_zeal_swat_mask/msk_tng_zeal_swat_mask",
		name_id = "bm_zeal_mask",
		pcs = {},
		value = 0,
		type = "helmet",
		texture_bundle_folder = "tng",
		sort_number = 35,
		dlc = "tango"
	}
	self.masks.tng_cap = {
		unit = "units/pd2_dlc_tng/masks/tng_cap/msk_tng_cap",
		name_id = "bm_cap_n_beard",
		pcs = {},
		value = 0,
		type = "helmet",
		texture_bundle_folder = "tng",
		sort_number = 35,
		dlc = "tango",
		offsets = {
			joy = {
				Vector3(0, -0.280226, 0.912237),
				Rotation(-0, -0, -0)
			}
		}
	}
	self.masks.moon_paycheck_dallas = {
		unit = "units/pd2_dlc_moon/masks/paycheck_dallas/msk_moon_paycheck_dallas",
		name_id = "bm_paycheck_dallas",
		pcs = {},
		value = 0,
		texture_bundle_folder = "moon",
		sort_number = 36
	}
	self.masks.moon_paycheck_chains = {
		unit = "units/pd2_dlc_moon/masks/paycheck_chains/msk_moon_paycheck_chains",
		name_id = "bm_paycheck_chains",
		pcs = {},
		value = 0,
		texture_bundle_folder = "moon",
		sort_number = 36
	}
	self.masks.sfm_01 = {
		unit = "units/pd2_dlc_friend/masks/sfm_01/msk_sfm_01",
		name_id = "bm_sfm_01",
		pcs = {},
		value = 0,
		texture_bundle_folder = "friend",
		sort_number = 37,
		dlc = "friend"
	}
	self.masks.sfm_02 = {
		unit = "units/pd2_dlc_friend/masks/sfm_02/msk_sfm_02",
		name_id = "bm_sfm_02",
		pcs = {},
		value = 0,
		texture_bundle_folder = "friend",
		sort_number = 37,
		dlc = "friend"
	}
	self.masks.sfm_03 = {
		unit = "units/pd2_dlc_friend/masks/sfm_03/msk_sfm_03",
		name_id = "bm_sfm_03",
		pcs = {},
		value = 0,
		texture_bundle_folder = "friend",
		type = "glasses",
		skip_mask_on_sequence = true,
		sort_number = 37,
		dlc = "friend"
	}
	self.masks.sfm_04 = {
		unit = "units/pd2_dlc_friend/masks/sfm_04/msk_sfm_04",
		name_id = "bm_sfm_04",
		pcs = {},
		value = 0,
		texture_bundle_folder = "friend",
		sort_number = 37,
		dlc = "friend"
	}
	self.masks.chc_terry = {
		unit = "units/pd2_dlc_chico/masks/terry/msk_chc_terry",
		name_id = "bm_msk_chico",
		pcs = {},
		value = 0,
		texture_bundle_folder = "chico",
		sort_number = 38,
		dlc = "chico"
	}
	self.masks.chc_terry_begins = {
		unit = "units/pd2_dlc_chico/masks/terry_begins/msk_chc_terry_begins",
		name_id = "bm_msk_chico_begins",
		pcs = {},
		value = 0,
		dlc = "chico",
		texture_bundle_folder = "chico",
		sort_number = 38
	}
	self.masks.swm_sydney = {
		unit = "units/pd2_dlc_swm/masks/msk_swm_sydney",
		name_id = "bm_msk_mega_sydney",
		pcs = {},
		value = 0,
		texture_bundle_folder = "swm",
		sort_number = 39,
		dlc = "swm",
		global_value = "swm"
	}
	self.masks.sha_01 = {
		unit = "units/pd2_dlc_sha/masks/sha_01/msk_sha_01",
		name_id = "bm_sha_01",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		texture_bundle_folder = "sha",
		sort_number = 40,
		global_value = "sha"
	}
	self.masks.sha_02 = {
		unit = "units/pd2_dlc_sha/masks/sha_02/msk_sha_02",
		name_id = "bm_sha_02",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		texture_bundle_folder = "sha",
		sort_number = 40,
		global_value = "sha"
	}
	self.masks.sha_03 = {
		unit = "units/pd2_dlc_sha/masks/sha_03/msk_sha_03",
		name_id = "bm_sha_03",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		texture_bundle_folder = "sha",
		sort_number = 40,
		global_value = "sha"
	}
	self.masks.sha_04 = {
		unit = "units/pd2_dlc_sha/masks/sha_04/msk_sha_04",
		name_id = "bm_sha_04",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		texture_bundle_folder = "sha",
		sort_number = 40,
		global_value = "sha"
	}
	self.masks.spa_01 = {
		unit = "units/pd2_dlc_spa/masks/spa_01/msk_spa_01",
		name_id = "bm_msk_spa_01",
		pcs = {},
		value = 0,
		texture_bundle_folder = "spa",
		type = "helmet",
		sort_number = 41,
		dlc = "spa",
		global_value = "spa",
		offsets = {
			joy = {
				Vector3(0, 1.38922, 0.316008),
				Rotation(0, -1.15904, 0)
			}
		}
	}
	self.masks.spa_02 = {
		unit = "units/pd2_dlc_spa/masks/spa_02/msk_spa_02",
		name_id = "bm_msk_spa_02",
		pcs = {},
		value = 0,
		texture_bundle_folder = "spa",
		type = "helmet",
		sort_number = 41,
		dlc = "spa",
		global_value = "spa",
		offsets = {
			jacket = {
				Vector3(0, -0.160978, -0.160978),
				Rotation(0, 0, -0)
			},
			dallas = {
				Vector3(0, -0.75721, -0.518717),
				Rotation(0, 0, -0)
			},
			joy = {
				Vector3(0, 0.196761, 0.0775149),
				Rotation(-0, -0, -0)
			},
			sydney = {
				Vector3(-2.06892, -0.637963, 2.82018),
				Rotation(-10.6034, -14.0376, -1.06722e-07)
			},
			dragon = {
				Vector3(-0.160978, -0.399471, -0.280224),
				Rotation(0, 0, -0)
			},
			old_hoxton = {
				Vector3(0, -1.11495, -0.637963),
				Rotation(0, 0, -0)
			},
			female_1 = {
				Vector3(-0.399471, 1.38922, -0.995702),
				Rotation(-0.300467, 5.70955, 1.41668)
			},
			hoxton = {
				Vector3(0, -0.995702, -0.0417315),
				Rotation(0, 0, -0)
			},
			sokol = {
				Vector3(0.0775149, -0.518717, -0.399471),
				Rotation(0, 0, -0)
			},
			chains = {
				Vector3(0, -0.876456, -0.518717),
				Rotation(0, 0, -0)
			},
			wolf = {
				Vector3(0, -0.637963, 0.196761),
				Rotation(0, 0, -0)
			},
			jowi = {
				Vector3(0, -1.2342, 0.0775149),
				Rotation(0, 0, -0)
			},
			chico = {
				Vector3(0.673747, -0.637963, -0.518717),
				Rotation(3.9924, 1.41668, 4.85098)
			},
			jimmy = {
				Vector3(0.0775149, 0.435254, -0.518717),
				Rotation(0, 0, -0)
			},
			bodhi = {
				Vector3(0, -0.518717, -0.399471),
				Rotation(0, 0, -0)
			},
			wild = {
				Vector3(0, -1.47269, -0.75721),
				Rotation(0, 0, -0)
			}
		}
	}
	self.masks.spa_03 = {
		unit = "units/pd2_dlc_spa/masks/spa_03/msk_spa_03",
		name_id = "bm_msk_spa_03",
		pcs = {},
		value = 0,
		texture_bundle_folder = "spa",
		sort_number = 41,
		dlc = "spa",
		global_value = "spa"
	}
	self.masks.spa_04 = {
		unit = "units/pd2_dlc_spa/masks/spa_04/msk_spa_04",
		name_id = "bm_msk_spa_04",
		pcs = {},
		value = 0,
		texture_bundle_folder = "spa",
		sort_number = 41,
		dlc = "spa",
		global_value = "spa"
	}
	self.masks.yor = {
		unit = "units/pd2_dlc_yor/masks/yor/msk_yor",
		name_id = "bm_msk_yor",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		texture_bundle_folder = "yor",
		sort_number = 42
	}
	self.masks.grv_01_bodhi = {
		unit = "units/pd2_dlc_grv/masks/grv_01/grv_01_bodhi/msk_grv_01_bodhi",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true,
		offsets = {
			dallas = {
				Vector3(0, -0.518717, 0.673747),
				Rotation(-0, -0, -0)
			},
			sydney = {
				Vector3(-0.280224, -0.518717, 1.15073),
				Rotation(-0.300467, -0.300467, 0.558107)
			},
			dragon = {
				Vector3(-0.280224, 0.196761, 0.435254),
				Rotation(-0, -0, -0)
			},
			female_1 = {
				Vector3(0, 0, 0.435254),
				Rotation(0, 2.27525, 0)
			},
			hoxton = {
				Vector3(0, -0.160978, 0.912239),
				Rotation(-0, -0, -0)
			},
			wild = {
				Vector3(0, -1.71118, 1.03149),
				Rotation(0, -6.31048, 0)
			},
			chains = {
				Vector3(-0.280224, -0.995702, 0.435254),
				Rotation(0, 0.558107, 0)
			},
			chico = {
				Vector3(-0.0417315, -0.518717, 0.912239),
				Rotation(-0, -0, -0)
			},
			old_hoxton = {
				Vector3(0, 0.196761, 0.0775149),
				Rotation(0, 3.9924, 0)
			},
			bodhi = {
				Vector3(0.196761, -0.280224, 0.5545),
				Rotation(-0, -0, -0)
			},
			dragan = {
				Vector3(0, -0.160978, 0.912239),
				Rotation(-0, -0, -0)
			},
			max = {
				Vector3(0, -0.160978, 0.912239),
				Rotation(-0, -0, -0)
			},
			joy = {
				Vector3(0, -0.16098, 1.26998),
				Rotation(-0, -0, -0)
			}
		}
	}
	self.masks.grv_01_bonnie = {
		unit = "units/pd2_dlc_grv/masks/grv_01/grv_01_bonnie/msk_grv_01_bonnie",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true,
		offsets = {
			jacket = {
				Vector3(0, 0, 0.196761),
				Rotation(-0, -0, -0)
			},
			wolf = {
				Vector3(0, -0.518717, 1.03149),
				Rotation(0, -1.15904, 0)
			},
			jowi = {
				Vector3(-0.160978, -0.160978, 0.792993),
				Rotation(-0, -0, -0)
			},
			jimmy = {
				Vector3(-0.0417315, 0.5545, -0.160978),
				Rotation(0, 2.27525, 0)
			},
			sokol = {
				Vector3(0, 0, 0.316008),
				Rotation(-0, -0, -0)
			},
			bonnie = {
				Vector3(0.0775149, 0.673747, 0.435254),
				Rotation(-0, -0, -0)
			},
			myh = {
				Vector3(0, -0.637965, 0.196759),
				Rotation(-0, -0, -0)
			}
		}
	}
	self.masks.grv_01_ecp_male = {
		unit = "units/pd2_dlc_ecp/masks/msk_grv_01_ecp_male/msk_grv_01_ecp_male",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true,
		offsets = {
			ecp_male = {
				Vector3(-0.280226, -2.90365, 1.74696),
				Rotation(-1.15905, -11.4619, 1.33402e-08)
			}
		}
	}
	self.masks.grv_01_ecp_female = {
		unit = "units/pd2_dlc_ecp/masks/msk_grv_01_ecp_female/msk_grv_01_ecp_female",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true,
		offsets = {
			ecp_female = {
				Vector3(0, -0.637965, 0.673745),
				Rotation(-0, -0, -0)
			}
		}
	}
	self.masks.grv_01 = {
		name_id = "bm_msk_grv_01",
		value = 0,
		pcs = {},
		type = "helmet",
		texture_bundle_folder = "grv",
		sort_number = 43,
		dlc = "grv",
		global_value = "grv",
		characters = {
			dragan = "grv_01_bodhi",
			wild = "grv_01_bodhi",
			myh = "grv_01_bonnie",
			chico = "grv_01_bodhi",
			dragon = "grv_01_bodhi",
			ecp_male = "grv_01_ecp_male",
			ecp_female = "grv_01_ecp_female",
			jowi = "grv_01_bonnie",
			old_hoxton = "grv_01_bodhi",
			bonnie = "grv_01_bonnie",
			max = "grv_01_bodhi",
			joy = "grv_01_bodhi",
			dallas = "grv_01_bodhi",
			jacket = "grv_01_bonnie",
			jimmy = "grv_01_bonnie",
			bodhi = "grv_01_bodhi",
			wolf = "grv_01_bonnie",
			sokol = "grv_01_bonnie",
			hoxton = "grv_01_bodhi",
			female_1 = "grv_01_bodhi",
			chains = "grv_01_bodhi",
			sydney = "grv_01_bodhi"
		}
	}
	self.masks.grv_02 = {
		unit = "units/pd2_dlc_grv/masks/grv_02/msk_grv_02",
		name_id = "bm_msk_grv_02",
		pcs = {},
		value = 0,
		texture_bundle_folder = "grv",
		sort_number = 43,
		dlc = "grv",
		global_value = "grv"
	}
	self.masks.grv_03 = {
		unit = "units/pd2_dlc_grv/masks/grv_03/msk_grv_03",
		name_id = "bm_msk_grv_03",
		pcs = {},
		value = 0,
		texture_bundle_folder = "grv",
		type = "tiara",
		skip_mask_on_sequence = true,
		sort_number = 43,
		dlc = "grv",
		global_value = "grv"
	}
	self.masks.grv_04 = {
		unit = "units/pd2_dlc_grv/masks/grv_04/msk_grv_04",
		name_id = "bm_msk_grv_04",
		pcs = {},
		value = 0,
		type = "helmet",
		texture_bundle_folder = "grv",
		sort_number = 43,
		dlc = "grv",
		offsets = {
			sydney = {
				Vector3(-0.0417333, -1.59194, 1.03148),
				Rotation(0, 0, -1.15905)
			},
			chains = {
				Vector3(0, -1.59194, 0.435252),
				Rotation(0, -3.73477, 0)
			},
			female_1 = {
				Vector3(0, -1.83043, 0.673745),
				Rotation(0, 0, -0)
			},
			hoxton = {
				Vector3(0, -2.30741, 1.38922),
				Rotation(0, -8.02764, 0)
			},
			wild = {
				Vector3(0, -1.83043, 0),
				Rotation(1.41667, -3.73477, -0)
			},
			wolf = {
				Vector3(0, -1.35344, 0.673745),
				Rotation(0, 0, -0)
			},
			bodhi = {
				Vector3(-0.399472, -2.42666, 0),
				Rotation(0, 0, -0)
			},
			jowi = {
				Vector3(0, -1.35344, 0),
				Rotation(0, 0, -0)
			},
			jacket = {
				Vector3(0, -1.35344, 0.077513),
				Rotation(0, 0, -0)
			},
			dallas = {
				Vector3(0, -1.71118, 0.554498),
				Rotation(-0, -0, -0)
			},
			old_hoxton = {
				Vector3(0, -1.94967, -0.995704),
				Rotation(0, 2.27524, 0)
			},
			bonnie = {
				Vector3(0.196759, -0.757211, 0.196759),
				Rotation(1.41667, -0.30048, -8.33763e-10)
			},
			sokol = {
				Vector3(0, -1.94967, 1.15073),
				Rotation(-3.3351e-09, -6.3105, -0.30048)
			},
			chico = {
				Vector3(0, -1.83043, 0.792991),
				Rotation(0, -3.73477, 0)
			},
			dragon = {
				Vector3(0, -0.995704, 1.15073),
				Rotation(0, -7.16907, 0)
			},
			jimmy = {
				Vector3(0.435252, -1.47269, 0),
				Rotation(2.27524, 2.08444e-09, -0.30048)
			},
			dragan = {
				Vector3(0, -1.35344, 0.554498),
				Rotation(0, 0, -0)
			}
		}
	}
	self.masks.amp_01 = {
		unit = "units/pd2_dlc_amp/masks/amp_01/msk_amp_01",
		name_id = "bm_msk_amp_01",
		pcs = {},
		value = 0,
		texture_bundle_folder = "amp",
		sort_number = 43,
		offsets = {
			joy = {
				Vector3(0, -1.2342, 1.15073),
				Rotation(-0, -0, -0)
			}
		}
	}
	self.masks.amp_02 = {
		unit = "units/pd2_dlc_amp/masks/amp_02/msk_amp_02",
		name_id = "bm_msk_amp_02",
		pcs = {},
		value = 0,
		texture_bundle_folder = "amp",
		sort_number = 43
	}
	self.masks.amp_03 = {
		unit = "units/pd2_dlc_amp/masks/amp_03/msk_amp_03",
		name_id = "bm_msk_amp_03",
		pcs = {},
		value = 0,
		texture_bundle_folder = "amp",
		sort_number = 43
	}
	self.masks.amp_04 = {
		unit = "units/pd2_dlc_amp/masks/amp_04/msk_amp_04",
		name_id = "bm_msk_amp_04",
		pcs = {},
		value = 0,
		texture_bundle_folder = "amp",
		sort_number = 43
	}
	self.masks.mp2_01 = {
		unit = "units/pd2_dlc_mp2/masks/mp2_01/msk_mp2_01",
		name_id = "bm_msk_mp2_01",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		texture_bundle_folder = "mp2",
		sort_number = 44,
		offsets = {
			female_1 = {
				Vector3(0, 0.435252, 0),
				Rotation(-0, -0, -0)
			}
		}
	}
	self.masks.mp2_02 = {
		unit = "units/pd2_dlc_mp2/masks/mp2_02/msk_mp2_02",
		name_id = "bm_msk_mp2_02",
		pcs = {},
		value = 0,
		texture_bundle_folder = "mp2",
		sort_number = 44
	}
	self.masks.mp2_03 = {
		unit = "units/pd2_dlc_mp2/masks/mp2_03/msk_mp2_03",
		name_id = "bm_msk_mp2_03",
		pcs = {},
		value = 0,
		texture_bundle_folder = "mp2",
		sort_number = 44
	}
	self.masks.mp2_04 = {
		unit = "units/pd2_dlc_mp2/masks/mp2_04/msk_mp2_04",
		name_id = "bm_msk_mp2_04",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		texture_bundle_folder = "mp2",
		sort_number = 44
	}
	self.masks.mrm = {
		unit = "units/pd2_dlc_mrm/masks/msk_mrm",
		name_id = "bm_msk_mrm",
		pcs = {},
		value = 0,
		texture_bundle_folder = "mrm",
		sort_number = 45,
		infamous = true
	}
	self.masks.bny_01_bonnie = {
		unit = "units/pd2_dlc_bny/masks/bny_01/msk_bny_01_bonnie",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true,
		offsets = {
			wolf = {
				Vector3(0, 3.41641, 0.435254),
				Rotation(0, -3.73476, 0)
			},
			sydney = {
				Vector3(0, 3.53566, 0.435254),
				Rotation(0, -4.59333, 0)
			},
			chico = {
				Vector3(0, 3.65491, -1.47269),
				Rotation(0.558107, -0.300467, -0.041893)
			},
			jimmy = {
				Vector3(0, 4.48963, -2.06892),
				Rotation(0, 2.27525, 0)
			},
			joy = {
				Vector3(0, 3.65491, 0.673747),
				Rotation(0, -9.74478, 0)
			},
			myh = {
				Vector3(0, 3.6549, 0.316006),
				Rotation(0, -13.1791, 0)
			},
			bonnie = {
				Vector3(0, 3.77415, 0),
				Rotation(0, -8.02763, 0)
			}
		}
	}
	self.masks.bny_01_bodhi = {
		unit = "units/pd2_dlc_bny/masks/bny_01/msk_bny_01_bodhi",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true,
		offsets = {
			dragon = {
				Vector3(0, 3.8934, -0.637963),
				Rotation(0, -5.45191, 0)
			},
			hoxton = {
				Vector3(0, 3.41641, 0.435254),
				Rotation(0, -11.4619, 0)
			},
			wild = {
				Vector3(0, 3.77415, -0.518717),
				Rotation(0, -8.8862, 0)
			},
			sokol = {
				Vector3(0, 2.82018, 0.316008),
				Rotation(0, -4.59333, 0)
			},
			old_hoxton = {
				Vector3(0, 4.25114, -2.54591),
				Rotation(0, 8.28527, 0)
			},
			bodhi = {
				Vector3(0, 4.48963, -0.637963),
				Rotation(0, -4.59333, 0)
			},
			jowi = {
				Vector3(0, 4.13189, -1.59193),
				Rotation(0, 3.13383, 0)
			},
			chains = {
				Vector3(0, 3.41641, 1.03149),
				Rotation(0, -12.3205, 0)
			},
			dragan = {
				Vector3(0, 4.13189, -0.0417315),
				Rotation(0, -6.31048, 0)
			},
			max = {
				Vector3(0, 4.13189, -0.0417315),
				Rotation(0, -6.31048, 0)
			}
		}
	}
	self.masks.bny_01_clover = {
		unit = "units/pd2_dlc_bny/masks/bny_01/msk_bny_01_clover",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true,
		offsets = {
			chico = {
				Vector3(0.00826851, 1.74696, -1.59193),
				Rotation(-0.300467, 5.70955, -0.300467)
			},
			dallas = {
				Vector3(0, 1.38922, 2.1047),
				Rotation(0, -16.6134, 0)
			},
			jacket = {
				Vector3(0, 1.03149, -1.2342),
				Rotation(0.0409595, 5.70955, -4.16882e-10)
			}
		}
	}
	self.masks.bny_01_clover_b = {
		unit = "units/pd2_dlc_bny/masks/bny_01/msk_bny_01_clover_b",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true
	}
	self.masks.bny_01_ecp_male = {
		unit = "units/pd2_dlc_ecp/masks/msk_bny_01_ecp_male/msk_bny_01_ecp_male",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true,
		offsets = {
			ecp_male = {
				Vector3(0, 2.58169, -0.876458),
				Rotation(-0, -0, -0)
			}
		}
	}
	self.masks.bny_01_ecp_female = {
		unit = "units/pd2_dlc_ecp/masks/msk_bny_01_ecp_female/msk_bny_01_ecp_female",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true,
		offsets = {
			ecp_female = {
				Vector3(0, 2.46244, 0.435252),
				Rotation(0, -3.73477, 0)
			}
		}
	}
	self.masks.bny_01 = {
		name_id = "bm_msk_bny_01",
		value = 0,
		pcs = {},
		type = "helmet",
		texture_bundle_folder = "bny",
		sort_number = 46,
		characters = {
			dragan = "bny_01_bodhi",
			wild = "bny_01_bodhi",
			myh = "bny_01_bonnie",
			chico = "bny_01_bonnie",
			dragon = "bny_01_bodhi",
			ecp_male = "bny_01_ecp_male",
			ecp_female = "bny_01_ecp_female",
			jowi = "bny_01_bodhi",
			old_hoxton = "bny_01_bodhi",
			bonnie = "bny_01_bonnie",
			max = "bny_01_bodhi",
			joy = "bny_01_bonnie",
			dallas = "bny_01_clover",
			jacket = "bny_01_clover",
			jimmy = "bny_01_bonnie",
			bodhi = "bny_01_bodhi",
			wolf = "bny_01_bonnie",
			sokol = "bny_01_bodhi",
			hoxton = "bny_01_bodhi",
			female_1 = "bny_01_clover_b",
			chains = "bny_01_bodhi",
			sydney = "bny_01_bonnie"
		}
	}
	self.masks.bny_02_bonnie = {
		unit = "units/pd2_dlc_bny/masks/bny_02/msk_bny_02_bonnie",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true,
		offsets = {
			jacket = {
				Vector3(0, 2.22395, -0.518717),
				Rotation(-0.00046676, -8.8862, -3.25689e-12)
			},
			sydney = {
				Vector3(0, 2.3432, -0.0417315),
				Rotation(1.0422e-10, -6.31048, 0.030943)
			},
			dragon = {
				Vector3(0, 1.86621, -0.399471),
				Rotation(0, -9.74478, 0)
			},
			wild = {
				Vector3(0, 2.46244, 0.5545),
				Rotation(0, -14.8962, 0)
			},
			dragan = {
				Vector3(0, 1.86621, -0.0417315),
				Rotation(0, -8.02763, 0)
			},
			wolf = {
				Vector3(0, 1.98546, -0.637963),
				Rotation(0, -3.73476, 0)
			},
			sokol = {
				Vector3(0, 0.792993, -0.0417315),
				Rotation(0, -8.8862, 0)
			},
			chico = {
				Vector3(0, 1.74696, 0.5545),
				Rotation(0, -15.7548, 0)
			},
			jimmy = {
				Vector3(0, 2.82018, -0.876456),
				Rotation(-0.041893, -9.74478, 4.16882e-10)
			},
			jowi = {
				Vector3(0, 2.22395, -0.160978),
				Rotation(0, -8.02763, 0)
			},
			bonnie = {
				Vector3(0, 2.58169, -0.637963),
				Rotation(0, -5.45191, 0)
			},
			joy = {
				Vector3(0.0775149, 1.74696, 1.38922),
				Rotation(0, -17.4719, 0)
			},
			myh = {
				Vector3(0, 2.70093, -0.0417333),
				Rotation(0, -13.1791, 0.558094)
			},
			ecp_male = {
				Vector3(0, 1.62772, -1.35344),
				Rotation(-0.30048, -3.73477, -0)
			}
		}
	}
	self.masks.bny_02_ecp_male = {
		unit = "units/pd2_dlc_ecp/masks/msk_bny_02_ecp_male/msk_bny_02_ecp_male",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true,
		offsets = {
			ecp_male = {
				Vector3(0, 1.62772, -1.35344),
				Rotation(-0.30048, -3.73477, -0)
			}
		}
	}
	self.masks.bny_02_bodhi = {
		unit = "units/pd2_dlc_bny/masks/bny_02/msk_bny_02_bodhi",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true,
		offsets = {
			dallas = {
				Vector3(0, 2.58169, -0.0417315),
				Rotation(-0.041893, -4.59334, 1.0422e-10)
			},
			chains = {
				Vector3(0, 2.3432, -0.637963),
				Rotation(0, -2.87619, 0)
			},
			hoxton = {
				Vector3(0, 2.3432, -0.995702),
				Rotation(-0, -0, -0)
			},
			bodhi = {
				Vector3(0, 1.98546, 0.792993),
				Rotation(-0.041893, -8.8862, -2.08441e-10)
			},
			old_hoxton = {
				Vector3(0, 2.1047, -1.83043),
				Rotation(0, 3.9924, 0)
			},
			max = {
				Vector3(0, 2.82018, -1.35344),
				Rotation(-0, -0, -0)
			},
			ecp_female = {
				Vector3(0, 2.46244, -0.518719),
				Rotation(-0, -0, -0)
			}
		}
	}
	self.masks.bny_02_clover = {
		unit = "units/pd2_dlc_bny/masks/bny_02/msk_bny_02_clover",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true,
		offsets = {
			female_1 = {
				Vector3(0, 0, 0),
				Rotation(0, -3.73476, 0)
			}
		}
	}
	self.masks.bny_02 = {
		name_id = "bm_msk_bny_02",
		value = 0,
		pcs = {},
		type = "helmet",
		texture_bundle_folder = "bny",
		sort_number = 46,
		characters = {
			dragan = "bny_02_bonnie",
			wild = "bny_02_bonnie",
			myh = "bny_02_bonnie",
			chico = "bny_02_bonnie",
			dragon = "bny_02_bonnie",
			ecp_male = "bny_02_ecp_male",
			ecp_female = "bny_02_bodhi",
			jowi = "bny_02_bonnie",
			old_hoxton = "bny_02_bodhi",
			bonnie = "bny_02_bonnie",
			max = "bny_02_bodhi",
			joy = "bny_02_bonnie",
			dallas = "bny_02_bodhi",
			jacket = "bny_02_bonnie",
			jimmy = "bny_02_bonnie",
			bodhi = "bny_02_bodhi",
			wolf = "bny_02_bonnie",
			sokol = "bny_02_bonnie",
			hoxton = "bny_02_bodhi",
			female_1 = "bny_02_clover",
			chains = "bny_02_bodhi",
			sydney = "bny_02_bonnie"
		}
	}
	self.masks.bny_03_clover = {
		unit = "units/pd2_dlc_bny/masks/bny_03/msk_bny_03_clover",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true,
		offsets = {
			jacket = {
				Vector3(0, 2.1047, -2.18817),
				Rotation(0, 7.4267, 0)
			},
			dallas = {
				Vector3(0, 1.50847, -0.399471),
				Rotation(0, 0, -0)
			},
			female_1 = {
				Vector3(0.5545, 2.46244, -3.49988),
				Rotation(0, 11.7196, 0)
			}
		}
	}
	self.masks.bny_03_bodhi = {
		unit = "units/pd2_dlc_bny/masks/bny_03/msk_bny_03_bodhi",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true,
		offsets = {
			max = {
				Vector3(0, 3.17792, 0.316008),
				Rotation(0, 0, -0)
			},
			joy = {
				Vector3(0, 4.13189, 0),
				Rotation(-0, -0, -0)
			},
			myh = {
				Vector3(0, 2.1047, -0.16098),
				Rotation(0, 3.99239, 0)
			},
			ecp_male = {
				Vector3(0, 2.58169, -0.399472),
				Rotation(-0, -0, -0)
			},
			ecp_female = {
				Vector3(0, 1.98545, 0.196759),
				Rotation(-0, -0, -0)
			},
			bonnie = {
				Vector3(0, 3.17792, 0.316008),
				Rotation(0, 0, -0)
			},
			sydney = {
				Vector3(0, 3.65491, 1.86621),
				Rotation(0, -6.31048, 0)
			},
			chains = {
				Vector3(0, 1.62772, 1.15073),
				Rotation(0, -3.73476, 0)
			},
			hoxton = {
				Vector3(0, 1.50847, 1.98546),
				Rotation(0, -11.4619, 0)
			},
			jimmy = {
				Vector3(0, 3.8934, -0.876456),
				Rotation(0, 0, -0)
			},
			old_hoxton = {
				Vector3(0, 3.17792, -1.94967),
				Rotation(0, 7.4267, 0)
			},
			sokol = {
				Vector3(0, 2.1047, 0.912239),
				Rotation(0, -5.45191, 0)
			},
			bodhi = {
				Vector3(0, 1.74696, 1.15073),
				Rotation(0.0409595, -5.45191, 6.25322e-10)
			},
			wolf = {
				Vector3(0, 2.1047, 1.38922),
				Rotation(0, 0, -0)
			},
			wild = {
				Vector3(0, 2.46244, -0.160978),
				Rotation(0, 0, -0)
			},
			chico = {
				Vector3(0, 1.74696, 0.792993),
				Rotation(0, -2.87619, 0)
			},
			jowi = {
				Vector3(0, 2.70093, -0.876456),
				Rotation(0, 3.13383, 0)
			},
			dragon = {
				Vector3(0, 2.46244, 1.15073),
				Rotation(-0.0347619, -6.31048, -2.08441e-10)
			},
			dragan = {
				Vector3(0, 2.1047, 0.792993),
				Rotation(0, 0, -0)
			}
		}
	}
	self.masks.bny_03 = {
		name_id = "bm_msk_bny_03",
		value = 0,
		pcs = {},
		type = "helmet",
		texture_bundle_folder = "bny",
		sort_number = 46,
		characters = {
			dragan = "bny_03_bodhi",
			wild = "bny_03_bodhi",
			myh = "bny_03_bodhi",
			chico = "bny_03_bodhi",
			dragon = "bny_03_bodhi",
			ecp_male = "bny_03_bodhi",
			ecp_female = "bny_03_bodhi",
			jowi = "bny_03_bodhi",
			old_hoxton = "bny_03_bodhi",
			bonnie = "bny_03_bodhi",
			max = "bny_03_bodhi",
			joy = "bny_03_bodhi",
			dallas = "bny_03_clover",
			jacket = "bny_03_clover",
			jimmy = "bny_03_bodhi",
			bodhi = "bny_03_bodhi",
			wolf = "bny_03_bodhi",
			sokol = "bny_03_bodhi",
			hoxton = "bny_03_bodhi",
			female_1 = "bny_03_clover",
			chains = "bny_03_bodhi",
			sydney = "bny_03_bodhi"
		}
	}
	self.masks.bny_04 = {
		unit = "units/pd2_dlc_bny/masks/bny_04/msk_bny_04",
		name_id = "bm_msk_bny_04",
		pcs = {},
		value = 0,
		texture_bundle_folder = "bny",
		sort_number = 46,
		type = "helmet",
		offsets = {
			joy = {
				Vector3(0, 3.05867, 0.196761),
				Rotation(0, -5.45191, 0)
			},
			ecp_male = {
				Vector3(0.077513, -0.876458, -0.637965),
				Rotation(-2.00261e-08, 3.99239, 2.27524)
			},
			ecp_female = {
				Vector3(0.077513, -1.35344, 1.98545),
				Rotation(0, -4.59335, 0)
			}
		}
	}
	self.masks.mdm = {
		unit = "units/pd2_dlc_mdm/masks/msk_mdm/msk_mdm",
		name_id = "bm_msk_mdm",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		texture_bundle_folder = "mdm",
		sort_number = 47,
		infamous = true,
		global_value = "infamous"
	}
	self.masks.max = {
		unit = "units/pd2_dlc_max/masks/msk_max",
		name_id = "bm_msk_max",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		texture_bundle_folder = "max",
		sort_number = 48,
		infamous = true,
		global_value = "infamous"
	}
	self.masks.max_begins = {
		unit = "units/pd2_dlc_max/masks/msk_max_begins",
		name_id = "bm_msk_max_begins",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		texture_bundle_folder = "max",
		sort_number = 49,
		infamous = true,
		global_value = "infamous"
	}
	self.masks.ant_01 = {
		unit = "units/pd2_dlc_ant/masks/ant_01/msk_ant_01",
		name_id = "bm_msk_ant_01",
		pcs = {},
		value = 0,
		texture_bundle_folder = "ant",
		sort_number = 49,
		type = "helmet",
		dlc = "ant",
		global_value = "ant"
	}
	self.masks.ant_02 = {
		unit = "units/pd2_dlc_ant/masks/ant_02/msk_ant_02",
		name_id = "bm_msk_ant_02",
		pcs = {},
		value = 0,
		texture_bundle_folder = "ant",
		sort_number = 49,
		type = "helmet",
		dlc = "ant",
		global_value = "ant"
	}
	self.masks.ant_03 = {
		unit = "units/pd2_dlc_ant/masks/ant_03/msk_ant_03",
		name_id = "bm_msk_ant_03",
		pcs = {},
		value = 0,
		texture_bundle_folder = "ant",
		sort_number = 49,
		type = "helmet",
		dlc = "ant",
		global_value = "ant"
	}
	self.masks.ant_04 = {
		unit = "units/pd2_dlc_ant/masks/ant_04/msk_ant_04",
		name_id = "bm_msk_ant_04",
		pcs = {},
		value = 0,
		texture_bundle_folder = "ant",
		sort_number = 49,
		type = "helmet",
		dlc = "ant",
		global_value = "ant"
	}
	self.masks.ant_05 = {
		unit = "units/pd2_dlc_ant/masks/ant_05/msk_ant_05",
		name_id = "bm_msk_ant_05",
		pcs = {},
		value = 0,
		texture_bundle_folder = "ant",
		sort_number = 50,
		type = "helmet",
		global_value = "ant_free"
	}
	self.masks.ant_06 = {
		unit = "units/pd2_dlc_ant/masks/ant_06/msk_ant_06",
		name_id = "bm_msk_ant_06",
		pcs = {},
		value = 0,
		texture_bundle_folder = "ant",
		sort_number = 49,
		type = "helmet",
		dlc = "ant",
		global_value = "ant"
	}
	self.masks.ant_07 = {
		unit = "units/pd2_dlc_ant/masks/ant_07/msk_ant_07",
		name_id = "bm_msk_ant_07",
		pcs = {},
		value = 0,
		texture_bundle_folder = "ant",
		sort_number = 50,
		type = "helmet",
		global_value = "ant_free"
	}
	self.masks.ant_08 = {
		unit = "units/pd2_dlc_ant/masks/ant_08/msk_ant_08",
		name_id = "bm_msk_ant_08",
		pcs = {},
		value = 0,
		texture_bundle_folder = "ant",
		sort_number = 49,
		type = "helmet",
		dlc = "ant",
		global_value = "ant"
	}
	self.masks.dgm = {
		unit = "units/pd2_dlc_dgm/masks/msk_dgm",
		name_id = "bm_msk_dgm",
		pcs = {},
		value = 0,
		texture_bundle_folder = "dgm",
		sort_number = 50,
		global_value = "pd2_clan"
	}
	self.masks.eng_01 = {
		unit = "units/pd2_dlc_eng/masks/eng_01/msk_eng_01",
		name_id = "bm_msk_eng_01",
		pcs = {},
		value = 0,
		texture_bundle_folder = "eng",
		sort_number = 51,
		type = "helmet",
		global_value = "eng"
	}
	self.masks.eng_02 = {
		unit = "units/pd2_dlc_eng/masks/eng_02/msk_eng_02",
		name_id = "bm_msk_eng_02",
		pcs = {},
		value = 0,
		texture_bundle_folder = "eng",
		sort_number = 51,
		type = "helmet",
		global_value = "eng"
	}
	self.masks.eng_03 = {
		unit = "units/pd2_dlc_eng/masks/eng_03/msk_eng_03",
		name_id = "bm_msk_eng_03",
		pcs = {},
		value = 0,
		texture_bundle_folder = "eng",
		sort_number = 51,
		type = "helmet",
		global_value = "eng"
	}
	self.masks.eng_04 = {
		unit = "units/pd2_dlc_eng/masks/eng_04/msk_eng_04",
		name_id = "bm_msk_eng_04",
		pcs = {},
		value = 0,
		texture_bundle_folder = "eng",
		sort_number = 51,
		type = "helmet",
		global_value = "eng",
		offsets = {
			sydney = {
				Vector3(0, 0.435252, 0),
				Rotation(-0, -0, -0)
			}
		}
	}
	self.masks.wmp_01 = {
		unit = "units/pd2_dlc_wmp/masks/wmp_01/msk_wmp_01",
		name_id = "bm_msk_wmp_01",
		pcs = {},
		value = 0,
		texture_bundle_folder = "wmp",
		sort_number = 52,
		type = "helmet",
		global_value = "pd2_clan",
		offsets = {
			sydney = {
				Vector3(0, 0.435252, 0),
				Rotation(0, 2.27524, 0)
			}
		}
	}
	self.masks.wmp_02 = {
		unit = "units/pd2_dlc_wmp/masks/wmp_02/msk_wmp_02",
		name_id = "bm_msk_wmp_02",
		pcs = {},
		value = 0,
		texture_bundle_folder = "wmp",
		sort_number = 52,
		type = "helmet",
		global_value = "pd2_clan",
		offsets = {
			wild = {
				Vector3(0, -1.11495, 0),
				Rotation(0, 0, -0)
			},
			wolf = {
				Vector3(0, -0.757211, 0),
				Rotation(0, 0, -0)
			},
			dragan = {
				Vector3(0, -0.637965, 0),
				Rotation(-0, -0, -0)
			},
			chains = {
				Vector3(0, -0.518719, 0),
				Rotation(0, 0, -0)
			},
			max = {
				Vector3(0, -0.637965, 0),
				Rotation(0, 0, -0)
			},
			jacket = {
				Vector3(0, -0.757211, 0),
				Rotation(0, 0, -0)
			},
			bonnie = {
				Vector3(0, -0.280226, 0),
				Rotation(0, 0, -0)
			}
		}
	}
	self.masks.wmp_03 = {
		unit = "units/pd2_dlc_wmp/masks/wmp_03/msk_wmp_03",
		name_id = "bm_msk_wmp_03",
		pcs = {},
		value = 0,
		texture_bundle_folder = "wmp",
		sort_number = 52,
		type = "tiara",
		global_value = "pd2_clan",
		offsets = {
			jacket = {
				Vector3(0, 0.435252, 0),
				Rotation(-0, -0, -0)
			},
			sydney = {
				Vector3(0, 1.26998, 2.46244),
				Rotation(0, -9.74479, 0)
			},
			dragon = {
				Vector3(0, 0, 0.316006),
				Rotation(0, 0, -0)
			},
			female_1 = {
				Vector3(0.077513, 2.1047, 0.077513),
				Rotation(-0, -0, -0)
			},
			wild = {
				Vector3(0, 0.316006, 0),
				Rotation(-0, -0, -0)
			},
			sokol = {
				Vector3(0, 0.554498, 0.435252),
				Rotation(0, 0, -0)
			},
			bonnie = {
				Vector3(0, 1.26998, 0.316006),
				Rotation(0, 0, -0)
			},
			wolf = {
				Vector3(0, 0.077513, 0.554498),
				Rotation(0, 0, -0)
			},
			chico = {
				Vector3(0, 0.673745, 0.316006),
				Rotation(0, 0, -0)
			},
			bodhi = {
				Vector3(0, 0, 0.554498),
				Rotation(0, 0, -0)
			},
			jimmy = {
				Vector3(0, 0.554498, 0),
				Rotation(0, 0, -0)
			},
			jowi = {
				Vector3(0, 0, 0.792991),
				Rotation(0, 0, -0)
			},
			dragan = {
				Vector3(0, 0.316006, 0.554498),
				Rotation(0, 0, -0)
			},
			joy = {
				Vector3(0.435254, 1.38922, 0.435254),
				Rotation(-0, -0, -0)
			}
		}
	}
	self.masks.wmp_04 = {
		unit = "units/pd2_dlc_wmp/masks/wmp_04/msk_wmp_04",
		name_id = "bm_msk_wmp_04",
		pcs = {},
		value = 0,
		texture_bundle_folder = "wmp",
		sort_number = 52,
		type = "helmet",
		global_value = "pd2_clan"
	}
	self.masks.gcm = {
		unit = "units/pd2_dlc_gcm/masks/msk_gcm",
		name_id = "bm_msk_gcm",
		pcs = {},
		value = 0,
		texture_bundle_folder = "gcm",
		sort_number = 53,
		global_value = "pd2_clan"
	}
	self.masks.jfr_01 = {
		unit = "units/pd2_dlc_jfr/masks/jfr_01/msk_jfr_01",
		name_id = "bm_msk_jfr_01",
		pcs = {},
		value = 0,
		texture_bundle_folder = "jfr",
		sort_number = 54,
		type = "helmet",
		offsets = {
			sydney = {
				Vector3(0, 1.26998, 0),
				Rotation(0, 3.13382, 0)
			}
		}
	}
	self.masks.jfr_02 = {
		unit = "units/pd2_dlc_jfr/masks/jfr_02/msk_jfr_02",
		name_id = "bm_msk_jfr_02",
		pcs = {},
		value = 0,
		texture_bundle_folder = "jfr",
		sort_number = 54,
		type = "helmet",
		offsets = {
			joy = {
				Vector3(0, 1.98546, 0.792993),
				Rotation(0, -9.74478, 0)
			},
			female_1 = {
				Vector3(0, 0.673745, -0.518719),
				Rotation(0, 0, -0)
			},
			sydney = {
				Vector3(0, 1.03148, 0),
				Rotation(0, 0, -0)
			}
		}
	}
	self.masks.jfr_03 = {
		unit = "units/pd2_dlc_jfr/masks/jfr_03/msk_jfr_03",
		name_id = "bm_msk_jfr_03",
		pcs = {},
		value = 0,
		texture_bundle_folder = "jfr",
		sort_number = 54,
		type = "helmet"
	}
	self.masks.jfr_04 = {
		unit = "units/pd2_dlc_jfr/masks/jfr_04/msk_jfr_04",
		name_id = "bm_msk_jfr_04",
		pcs = {},
		value = 0,
		texture_bundle_folder = "jfr",
		sort_number = 54,
		type = "beard",
		skip_mask_on_sequence = true,
		offsets = {
			sydney = {
				Vector3(0, -1.11495, 0.196759),
				Rotation(0, 0, -0)
			},
			chains = {
				Vector3(0, 0, -0.876458),
				Rotation(0, 0, -0)
			},
			female_1 = {
				Vector3(0, 0.435252, -0.995704),
				Rotation(0, 3.99239, 0)
			},
			hoxton = {
				Vector3(0, 0, -0.637965),
				Rotation(0, 0, -0)
			},
			sokol = {
				Vector3(-0.280226, 0.792991, -1.11495),
				Rotation(0, 6.56811, 0)
			},
			wolf = {
				Vector3(0, -0.757211, -0.16098),
				Rotation(0, 0, -0)
			},
			bodhi = {
				Vector3(0, 0, -0.757211),
				Rotation(0, 0, -0)
			},
			jimmy = {
				Vector3(0, 1.98545, -1.11495),
				Rotation(0, 4.85096, 0)
			},
			jacket = {
				Vector3(0, -0.16098, 0.077513),
				Rotation(0, -2.01763, 0)
			},
			dallas = {
				Vector3(0, 0.077513, -0.399472),
				Rotation(0, 1.41667, 0)
			},
			old_hoxton = {
				Vector3(0, 2.70093, -2.7844),
				Rotation(0, 15.1538, 0)
			},
			dragan = {
				Vector3(0, -0.995704, -0.399472),
				Rotation(0, 0, -0)
			},
			max = {
				Vector3(0, 0.673745, -0.876458),
				Rotation(0, 4.85096, 0)
			},
			wild = {
				Vector3(0, 0, -1.2342),
				Rotation(0, 0, -0)
			},
			chico = {
				Vector3(0, -0.876458, -0.637965),
				Rotation(0, 0, -0)
			},
			jowi = {
				Vector3(0, -0.995704, -0.876458),
				Rotation(0, 0, -0)
			},
			dragon = {
				Vector3(0, 1.38922, -1.2342),
				Rotation(0, 5.70954, 0)
			},
			bonnie = {
				Vector3(0, 0, -0.518719),
				Rotation(0, 0.558094, 0)
			}
		}
	}
	self.masks.joy = {
		unit = "units/pd2_dlc_joy/masks/msk_joy",
		name_id = "bm_msk_joy",
		pcs = {},
		value = 0,
		texture_bundle_folder = "joy",
		sort_number = 57,
		infamous = true,
		global_value = "infamous",
		offsets = {
			wild = {
				Vector3(0, -1.11495, 0),
				Rotation(-0, -0, -0)
			},
			chico = {
				Vector3(0, -1.47269, 0),
				Rotation(-0, -0, -0)
			}
		}
	}
	self.masks.joy_begins = {
		unit = "units/pd2_dlc_joy/masks/msk_joy_begins",
		name_id = "bm_msk_joy_begins",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		texture_bundle_folder = "joy",
		sort_number = 57,
		infamous = true,
		global_value = "infamous",
		offsets = {
			wild = {
				Vector3(0, -0.876456, 0),
				Rotation(-0, -0, -0)
			},
			chico = {
				Vector3(0, -1.11495, 0),
				Rotation(-0, -0, -0)
			}
		}
	}
	self.masks.mmj = {
		unit = "units/pd2_dlc_mmj/masks/msk_mmj",
		name_id = "bm_msk_mmj",
		pcs = {},
		value = 0,
		texture_bundle_folder = "mmj",
		sort_number = 55,
		type = "helmet",
		offsets = {
			joy = {
				Vector3(-0.518717, 1.15073, -0.399471),
				Rotation(-0, -0, -0)
			}
		}
	}
	self.masks.fdm = {
		unit = "units/pd2_dlc_fdm/masks/msk_fdm",
		name_id = "bm_msk_fdm",
		pcs = {},
		value = 0,
		texture_bundle_folder = "fdm",
		sort_number = 55,
		type = "helmet",
		dlc = "fdm",
		global_value = "fdm",
		offsets = {
			sydney = {
				Vector3(0.435254, -0.876456, 1.26998),
				Rotation(-0.300467, -1.68403e-09, -8.02763)
			},
			dragon = {
				Vector3(0.316008, -0.280224, 0),
				Rotation(0, 0, -11.4619)
			},
			female_1 = {
				Vector3(0.0775149, 0.196761, 0.673747),
				Rotation(2.5018e-09, -1.15904, -1.15904)
			},
			hoxton = {
				Vector3(0.5545, -1.35344, 0.5545),
				Rotation(-8.167e-08, -3.73476, -11.4619)
			},
			sokol = {
				Vector3(0.0775149, -0.160978, 0.196761),
				Rotation(0, 1.41668, 0)
			},
			wolf = {
				Vector3(0.0775149, -0.876456, 0.673747),
				Rotation(0, 0, -0)
			},
			bodhi = {
				Vector3(0, -1.11495, 0.5545),
				Rotation(0, 0, -0)
			},
			jimmy = {
				Vector3(-0.280224, -0.399471, -0.0417315),
				Rotation(0, 0, -0)
			},
			max = {
				Vector3(0, -1.11495, 0.5545),
				Rotation(0, 0, -0)
			},
			dallas = {
				Vector3(0, -2.66515, 2.58169),
				Rotation(0, -11.4619, 0)
			},
			joy = {
				Vector3(0, 0.912239, 0.316008),
				Rotation(-0, -0, -0)
			},
			old_hoxton = {
				Vector3(0, -1.71118, 0),
				Rotation(-0, -0, 3.13383)
			},
			dragan = {
				Vector3(0, -0.995702, 0.792993),
				Rotation(0, -2.01761, 0)
			},
			jacket = {
				Vector3(0, -0.280224, -0.0417315),
				Rotation(0, 1.41668, -0.300467)
			},
			chico = {
				Vector3(0, -0.995702, 0.5545),
				Rotation(-5.0036e-09, 2.27525, -1.15904)
			},
			jowi = {
				Vector3(4.13189, -1.2342, 2.1047),
				Rotation(19.4467, -11.4619, -0)
			},
			chains = {
				Vector3(0.435254, -1.47269, -0.160978),
				Rotation(0, 0, -9.74478)
			},
			bonnie = {
				Vector3(-0.160978, -0.637963, 0.316008),
				Rotation(-0, -0, 5.70955)
			},
			ecp_female = {
				Vector3(0, -2.54591, 0.554498),
				Rotation(0, 1.41667, 0)
			},
			ecp_male = {
				Vector3(0, -1.47269, -0.757211),
				Rotation(0, 5.70954, 0)
			}
		}
	}
	self.masks.ztm = {
		unit = "units/pd2_dlc_ztm/masks/msk_ztm",
		name_id = "bm_msk_ztm",
		pcs = {},
		value = 0,
		texture_bundle_folder = "ztm",
		sort_number = 55,
		dlc = "ztm",
		global_value = "ztm"
	}
	self.masks.cmo_01 = {
		unit = "units/pd2_dlc_cmo/masks/cmo_01/msk_cmo_01",
		name_id = "bm_msk_cmo_01",
		pcs = {},
		value = 0,
		texture_bundle_folder = "cmo",
		sort_number = 56
	}
	self.masks.cmo_02 = {
		unit = "units/pd2_dlc_cmo/masks/cmo_02/msk_cmo_02",
		name_id = "bm_msk_cmo_02",
		pcs = {},
		value = 0,
		texture_bundle_folder = "cmo",
		sort_number = 56
	}
	self.masks.cmo_03 = {
		unit = "units/pd2_dlc_cmo/masks/cmo_03/msk_cmo_03",
		name_id = "bm_msk_cmo_03",
		pcs = {},
		value = 0,
		texture_bundle_folder = "cmo",
		sort_number = 56
	}
	self.masks.cmo_04 = {
		unit = "units/pd2_dlc_cmo/masks/cmo_04/msk_cmo_04",
		name_id = "bm_msk_cmo_04",
		pcs = {},
		value = 0,
		texture_bundle_folder = "cmo",
		sort_number = 56
	}
	self.masks.dnm = {
		unit = "units/pd2_dlc_dnm/masks/msk_dnm",
		name_id = "bm_msk_dnm",
		pcs = {},
		value = 0,
		qlvl = 0,
		infamous = true,
		sort_number = 29,
		texture_bundle_folder = "dnm"
	}
	self.masks.pbm = {
		unit = "units/pd2_dlc_pbm/masks/msk_pbm",
		name_id = "bm_msk_pbm",
		pcs = {},
		value = 0,
		texture_bundle_folder = "pbm",
		sort_number = 57,
		type = "helmet",
		dlc = "pbm",
		global_value = "pbm"
	}
	self.masks.kwm = {
		unit = "units/pd2_dlc_kwm/masks/msk_kwm",
		name_id = "bm_msk_kwm",
		pcs = {},
		value = 0,
		texture_bundle_folder = "kwm",
		sort_number = 58,
		type = "helmet"
	}
	self.masks.myh = {
		unit = "units/pd2_dlc_myh/masks/msk_myh",
		name_id = "bm_msk_myh",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		texture_bundle_folder = "myh",
		sort_number = 55,
		infamous = true,
		global_value = "infamous"
	}
	self.masks.myh_begins = {
		unit = "units/pd2_dlc_myh/masks/msk_myh_begins",
		name_id = "bm_msk_myh_begins",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		texture_bundle_folder = "myh",
		sort_number = 55,
		infamous = true,
		global_value = "infamous"
	}
	self.masks.mmh = {
		unit = "units/pd2_dlc_mmh/masks/mmh_01/msk_mmh",
		name_id = "bm_msk_mmh",
		pcs = {},
		value = 0,
		texture_bundle_folder = "mmh",
		sort_number = 56,
		global_value = "mmh"
	}
	self.masks.sds_01 = {
		unit = "units/pd2_dlc_sds/masks/sds_01/msk_sds_01",
		name_id = "bm_msl_sds_01",
		pcs = {},
		value = 0,
		texture_bundle_folder = "sds",
		sort_number = 59,
		global_value = "halloween"
	}
	self.masks.sds_02 = {
		unit = "units/pd2_dlc_sds/masks/sds_02/msk_sds_02",
		name_id = "bm_msl_sds_02",
		pcs = {},
		value = 0,
		texture_bundle_folder = "sds",
		sort_number = 59,
		global_value = "halloween"
	}
	self.masks.sds_03 = {
		unit = "units/pd2_dlc_sds/masks/sds_03/msk_sds_03",
		name_id = "bm_msl_sds_03",
		pcs = {},
		value = 0,
		texture_bundle_folder = "sds",
		sort_number = 59,
		global_value = "halloween"
	}
	self.masks.sds_04 = {
		unit = "units/pd2_dlc_sds/masks/sds_04/msk_sds_04",
		name_id = "bm_msl_sds_04",
		pcs = {},
		value = 0,
		texture_bundle_folder = "sds",
		sort_number = 59,
		global_value = "halloween"
	}
	self.masks.sds_05 = {
		unit = "units/pd2_dlc_sds/masks/sds_05/msk_sds_05",
		name_id = "bm_msl_sds_05",
		pcs = {},
		value = 0,
		texture_bundle_folder = "sds",
		sort_number = 59,
		global_value = "halloween"
	}
	self.masks.sds_06 = {
		unit = "units/pd2_dlc_sds/masks/sds_06/msk_sds_06",
		name_id = "bm_msl_sds_06",
		pcs = {},
		value = 0,
		texture_bundle_folder = "sds",
		sort_number = 59,
		global_value = "halloween"
	}
	self.masks.sds_07 = {
		unit = "units/pd2_dlc_sds/masks/sds_07/msk_sds_07",
		name_id = "bm_msl_sds_07",
		pcs = {},
		value = 0,
		texture_bundle_folder = "sds",
		sort_number = 59,
		global_value = "halloween"
	}
	self.masks.ecp_male = {
		unit = "units/pd2_dlc_ecp/masks/msk_ecp_male/msk_ecp_male",
		name_id = "bm_msk_ecp_male",
		pcs = {},
		value = 0,
		texture_bundle_folder = "ecp",
		sort_number = 60,
		type = "helmet",
		global_value = "ecp"
	}
	self.masks.ecp_female = {
		unit = "units/pd2_dlc_ecp/masks/msk_ecp_female/msk_ecp_female",
		name_id = "bm_msk_ecp_female",
		pcs = {},
		value = 0,
		texture_bundle_folder = "ecp",
		sort_number = 60,
		type = "helmet",
		global_value = "ecp"
	}
	self.masks.ecp_male.offsets = {
		wolf = {
			Vector3(0, 0, 0.792991),
			Rotation(-0, -0, -0)
		},
		sydney = {
			Vector3(0, 0, 0.912237),
			Rotation(-0, -0, -0)
		},
		dragan = {
			Vector3(0, 0, 0.316006),
			Rotation(-0, -0, -0)
		},
		female_1 = {
			Vector3(0, 0, 0.196759),
			Rotation(-0, -0, -0)
		}
	}
	self.masks.ecp_female_begins = {
		unit = "units/pd2_dlc_ecp/masks/msk_ecp_female_begins/msk_ecp_female_begins",
		name_id = "bm_msk_ecp_female_begins",
		pcs = {},
		value = 0,
		texture_bundle_folder = "ecp",
		sort_number = 60,
		global_value = "ecp"
	}
	self.masks.ecp_male_begins = {
		unit = "units/pd2_dlc_ecp/masks/msk_ecp_male_begins/msk_ecp_male_begins",
		name_id = "bm_msk_ecp_male_begins",
		pcs = {},
		value = 0,
		texture_bundle_folder = "ecp",
		sort_number = 60,
		global_value = "ecp"
	}
	self.masks.rvd_01 = {
		unit = "units/pd2_dlc_rvd/masks/msk_rvd_01/msk_rvd_01",
		name_id = "bm_msk_rvd_01",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		texture_bundle_folder = "rvd",
		sort_number = 61,
		type = "glasses",
		skip_mask_on_sequence = true,
		global_value = "rvd",
		offsets = {
			sydney = {
				Vector3(0, 4.01264, -1.94967),
				Rotation(0, 18.5881, 0)
			},
			dragon = {
				Vector3(0.196759, 4.48963, -1.2342),
				Rotation(0, 15.1538, 0)
			},
			female_1 = {
				Vector3(0, 3.6549, -1.11495),
				Rotation(0, 15.1538, 0)
			},
			hoxton = {
				Vector3(0, 3.6549, -1.94967),
				Rotation(0, 15.1538, 0)
			},
			sokol = {
				Vector3(0, 2.82018, -0.637965),
				Rotation(0, 10.0024, 0)
			},
			wolf = {
				Vector3(0, 3.53566, -0.280226),
				Rotation(0, 10.861, 0)
			},
			bodhi = {
				Vector3(-0.16098, 3.6549, -1.94967),
				Rotation(0, 16.0124, 0)
			},
			jimmy = {
				Vector3(0, 3.53566, -0.757211),
				Rotation(0, 10.0024, 0)
			},
			max = {
				Vector3(0, 4.13189, -2.66515),
				Rotation(0, 18.5881, 0)
			},
			dallas = {
				Vector3(0, 3.17792, -1.71118),
				Rotation(0, 14.2953, 0)
			},
			dragan = {
				Vector3(0, 3.05867, -1.59194),
				Rotation(0, 14.2953, 0)
			},
			wild = {
				Vector3(0, 3.17792, -1.47269),
				Rotation(0, 9.14383, 0)
			},
			old_hoxton = {
				Vector3(0, 3.6549, -2.54591),
				Rotation(0, 18.5881, 0)
			},
			chains = {
				Vector3(0, 3.6549, -1.11495),
				Rotation(0, 14.2953, 0)
			},
			ecp_female = {
				Vector3(0, 2.70093, -1.11495),
				Rotation(0, 10.861, 0)
			},
			ecp_male = {
				Vector3(0.077513, 3.17792, -1.2342),
				Rotation(0, 14.2953, 0)
			},
			jowi = {
				Vector3(0.077513, 3.29716, -1.59194),
				Rotation(0, 15.1538, 0)
			},
			chico = {
				Vector3(0, 4.13189, -2.90365),
				Rotation(0, 18.5881, 0)
			},
			myh = {
				Vector3(0, 3.6549, -2.7844),
				Rotation(0, 19.4467, 0)
			},
			jacket = {
				Vector3(0.077513, 4.01264, -1.59194),
				Rotation(0, 16.0124, 0)
			},
			bonnie = {
				Vector3(0, 3.8934, -1.2342),
				Rotation(0, 14.2953, 0)
			},
			joy = {
				Vector3(0, 4.37038, -2.06892),
				Rotation(0, 18.5881, 0)
			}
		}
	}
	self.masks.rvd_02 = {
		unit = "units/pd2_dlc_rvd/masks/msk_rvd_02/msk_rvd_02",
		name_id = "bm_msk_rvd_02",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		texture_bundle_folder = "rvd",
		type = "glasses",
		skip_mask_on_sequence = true,
		sort_number = 60,
		global_value = "rvd",
		offsets = {
			jacket = {
				Vector3(0, 1.03149, -1.11495),
				Rotation(0, 3.9924, 0)
			},
			dallas = {
				Vector3(0, 0.316008, -1.47269),
				Rotation(0, 3.9924, 0)
			},
			jowi = {
				Vector3(0, 0.673747, -1.59193),
				Rotation(0, 7.4267, 0)
			},
			max = {
				Vector3(0, 1.15073, -1.59193),
				Rotation(0, 4.85098, 0)
			},
			dragon = {
				Vector3(0, 0.435254, -0.399471),
				Rotation(-0, -0, -0)
			},
			old_hoxton = {
				Vector3(0, 0.435254, -1.83043),
				Rotation(0, 6.56812, 0)
			},
			chains = {
				Vector3(0.0775149, 0.792993, -1.11495),
				Rotation(-0.300467, 4.85098, 1.66753e-09)
			},
			chico = {
				Vector3(-0.0417315, 0.673747, -1.2342),
				Rotation(0, 3.13383, 0)
			},
			myh = {
				Vector3(0, 0.5545, -1.47269),
				Rotation(0, 5.70955, 0)
			},
			hoxton = {
				Vector3(0, 0.5545, -0.876456),
				Rotation(0, 3.13383, 0)
			},
			sokol = {
				Vector3(0, -0.637963, -0.0417315),
				Rotation(0, -2.01761, 0)
			},
			ecp_female = {
				Vector3(0, -0.518717, -0.876456),
				Rotation(-0, -0, -0)
			},
			ecp_male = {
				Vector3(0, 0.5545, -1.2342),
				Rotation(0, 7.4267, 0)
			},
			wild = {
				Vector3(0, 0.5545, -1.2342),
				Rotation(0, 3.9924, 0)
			},
			bodhi = {
				Vector3(0, 0.912239, -0.75721),
				Rotation(0, 5.70955, 0)
			},
			jimmy = {
				Vector3(0, 1.26998, -1.11495),
				Rotation(0, 4.85098, 0)
			},
			chains = {
				Vector3(0, 0.316008, -0.995702),
				Rotation(-0, -0, -0)
			},
			bonnie = {
				Vector3(0, 0.316008, 0.0775149),
				Rotation(0, -0.300467, 0)
			}
		}
	}
	self.masks.rvd_03 = {
		unit = "units/pd2_dlc_rvd/masks/rvd_03/msk_rvd_03",
		name_id = "bm_msk_rvd_03",
		pcs = {
			10,
			20,
			30,
			40
		},
		value = 0,
		texture_bundle_folder = "rvd",
		sort_number = 61,
		type = "glasses",
		skip_mask_on_sequence = true,
		global_value = "rvd",
		offsets = {
			sydney = {
				Vector3(0.077513, 3.53566, -1.11495),
				Rotation(0, 13.4367, 0)
			},
			dragon = {
				Vector3(0.196759, 3.29716, -1.11495),
				Rotation(0, 10.861, 0)
			},
			female_1 = {
				Vector3(0, 2.34319, -0.995704),
				Rotation(0, 8.28526, 0)
			},
			hoxton = {
				Vector3(0, 3.29716, -1.83043),
				Rotation(0, 13.4367, 0)
			},
			sokol = {
				Vector3(0, 1.26998, 0.673745),
				Rotation(0, 0, -0)
			},
			wolf = {
				Vector3(0, 3.05867, -0.280226),
				Rotation(0, 10.0024, 0)
			},
			bodhi = {
				Vector3(0, 2.93943, -1.71118),
				Rotation(0, 11.7196, 0)
			},
			jowi = {
				Vector3(0, 3.05867, -1.94967),
				Rotation(0, 14.2953, -0.30048)
			},
			jacket = {
				Vector3(-0.0417333, 2.93943, -0.399472),
				Rotation(0, 6.56811, 0)
			},
			dallas = {
				Vector3(0, 2.70093, -1.35344),
				Rotation(0, 10.0024, 0)
			},
			bonnie = {
				Vector3(0, 2.70093, -0.518719),
				Rotation(0, 6.56811, 0)
			},
			chains = {
				Vector3(0, 3.41641, -1.83043),
				Rotation(0, 13.4367, 0)
			},
			old_hoxton = {
				Vector3(0, 2.58169, -1.71118),
				Rotation(0, 11.7196, 0)
			},
			wild = {
				Vector3(0, 2.34319, -0.399472),
				Rotation(0, 4.85096, 0)
			},
			ecp_female = {
				Vector3(0, 2.1047, -0.876458),
				Rotation(0, 5.70954, 0)
			},
			ecp_male = {
				Vector3(0, 3.29716, -1.2342),
				Rotation(0, 16.0124, 0)
			},
			max = {
				Vector3(0, 3.41641, -2.30741),
				Rotation(0, 15.1538, 0)
			},
			chico = {
				Vector3(0, 2.93943, -1.2342),
				Rotation(0, 11.7196, 0)
			},
			myh = {
				Vector3(0, 3.05867, -2.06892),
				Rotation(0, 15.1538, 0)
			},
			jimmy = {
				Vector3(0, 4.13189, -1.47269),
				Rotation(0, 12.5781, 0)
			},
			dragan = {
				Vector3(0, 2.46244, -0.876458),
				Rotation(0, 9.14383, 0)
			},
			joy = {
				Vector3(0, 3.29716, -0.637965),
				Rotation(0, 12.5781, 0)
			}
		}
	}
	self.masks.ami_01 = {
		unit = "units/pd2_dlc_ami/masks/ami_01/msk_ami_01",
		name_id = "bm_msk_ami_01",
		pcs = {},
		value = 0,
		texture_bundle_folder = "ami",
		sort_number = 62,
		global_value = "infamous",
		offsets = {
			joy = {
				Vector3(0, 0.077513, 0.912237),
				Rotation(-0, -0, -0)
			},
			dragon = {
				Vector3(0, 0.673745, 0),
				Rotation(-0, -0, -0)
			},
			bodhi = {
				Vector3(0, 0.196759, 0),
				Rotation(-0, -0, -0)
			}
		}
	}
	self.masks.ami_02 = {
		unit = "units/pd2_dlc_ami/masks/ami_02/msk_ami_02",
		name_id = "bm_msk_ami_02",
		pcs = {},
		value = 0,
		texture_bundle_folder = "ami",
		sort_number = 62,
		global_value = "infamous"
	}
	self.masks.ami_03 = {
		unit = "units/pd2_dlc_ami/masks/ami_03/msk_ami_03",
		name_id = "bm_msk_ami_03",
		pcs = {},
		value = 0,
		texture_bundle_folder = "ami",
		sort_number = 62,
		global_value = "infamous"
	}
	self.masks.ami_04 = {
		unit = "units/pd2_dlc_ami/masks/ami_04/msk_ami_04",
		name_id = "bm_msk_ami_04",
		pcs = {},
		value = 0,
		type = "helmet",
		texture_bundle_folder = "ami",
		sort_number = 62,
		global_value = "infamous"
	}
	self.masks.ami_05 = {
		unit = "units/pd2_dlc_ami/masks/ami_05/msk_ami_05",
		name_id = "bm_msk_ami_05",
		pcs = {},
		value = 0,
		texture_bundle_folder = "ami",
		sort_number = 62,
		global_value = "infamous"
	}
	self.masks.ami_06 = {
		unit = "units/pd2_dlc_ami/masks/ami_06/msk_ami_06",
		name_id = "bm_msk_ami_06",
		pcs = {},
		value = 0,
		texture_bundle_folder = "ami",
		sort_number = 62,
		global_value = "infamous"
	}
	self.masks.cmt_01 = {
		unit = "units/pd2_dlc_cmt/masks/cmt_01/msk_cmt_01",
		name_id = "bm_msk_cmt_01",
		pcs = {},
		value = 0,
		texture_bundle_folder = "cmt",
		sort_number = 62,
		global_value = "cmt"
	}
	self.masks.cmt_02 = {
		unit = "units/pd2_dlc_cmt/masks/cmt_02/msk_cmt_02",
		name_id = "bm_msk_cmt_02",
		pcs = {},
		value = 0,
		texture_bundle_folder = "cmt",
		sort_number = 62,
		global_value = "cmt"
	}
	self.masks.cmt_03 = {
		unit = "units/pd2_dlc_cmt/masks/cmt_03/msk_cmt_03",
		name_id = "bm_msk_cmt_03",
		pcs = {},
		value = 0,
		texture_bundle_folder = "cmt",
		sort_number = 62,
		global_value = "cmt"
	}
	self.masks.cmt_04 = {
		unit = "units/pd2_dlc_cmt/masks/cmt_04/msk_cmt_04",
		name_id = "bm_msk_cmt_04",
		pcs = {},
		value = 0,
		texture_bundle_folder = "cmt",
		sort_number = 62,
		global_value = "cmt"
	}
	self.masks.sdm_01 = {
		unit = "units/pd2_dlc_sdm/masks/sdm_01/msk_sdm_01",
		name_id = "bm_msk_sdm_01",
		pcs = {},
		value = 0,
		texture_bundle_folder = "sdm",
		sort_number = 64,
		global_value = "sdm"
	}
	self.masks.sdm_02 = {
		unit = "units/pd2_dlc_sdm/masks/sdm_02/msk_sdm_02",
		name_id = "bm_msk_sdm_02",
		pcs = {},
		value = 0,
		texture_bundle_folder = "sdm",
		sort_number = 64,
		global_value = "sdm"
	}
	self.masks.sdm_03 = {
		unit = "units/pd2_dlc_sdm/masks/sdm_03/msk_sdm_03",
		name_id = "bm_msk_sdm_03",
		pcs = {},
		value = 0,
		texture_bundle_folder = "sdm",
		sort_number = 64,
		global_value = "sdm"
	}
	self.masks.sdm_04 = {
		unit = "units/pd2_dlc_sdm/masks/sdm_04/msk_sdm_04",
		name_id = "bm_msk_sdm_04",
		pcs = {},
		value = 0,
		texture_bundle_folder = "sdm",
		sort_number = 64,
		global_value = "sdm"
	}
	self.masks.gwm = {
		unit = "units/pd2_dlc_gwm/masks/gwm/msk_gwm",
		name_id = "bm_msk_gwm",
		pcs = {},
		value = 0,
		texture_bundle_folder = "gwm",
		sort_number = 65,
		global_value = "pd2_clan"
	}
	self.masks.ggac_od_t2 = {
		unit = "units/pd2_dlc_ggac/masks/ggac_od_t2/msk_ggac_od_t2",
		name_id = "bm_msk_ggac",
		pcs = {},
		value = 0,
		qlvl = 0,
		infamous = true,
		texture_bundle_folder = "ggac",
		sort_number = 36
	}
	self.masks.flm_01 = {
		unit = "units/pd2_dlc_flm/masks/flm/msk_flm_01",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true,
		offsets = {
			dragon = {
				Vector3(0, 0.077513, 0.673745),
				Rotation(0, -5.45192, 0)
			},
			wolf = {
				Vector3(0, -0.757211, 1.38922),
				Rotation(0, -3.73477, 0)
			},
			old_hoxton = {
				Vector3(0, -0.757211, 0.077513),
				Rotation(0, -3.73477, 0)
			},
			chico = {
				Vector3(0, -0.757211, 1.50847),
				Rotation(0, -6.3105, 0)
			},
			jowi = {
				Vector3(0, -0.757211, 1.03148),
				Rotation(0, -1.15905, 0)
			},
			jimmy = {
				Vector3(0, 0.554498, 0.316006),
				Rotation(0, -0.30048, 0)
			},
			bonnie = {
				Vector3(0, -0.280226, 1.26998),
				Rotation(0, -2.8762, 0)
			}
		}
	}
	self.masks.flm_clover = {
		unit = "units/pd2_dlc_flm/masks/flm/msk_flm_clover",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true
	}
	self.masks.flm_jacket = {
		unit = "units/pd2_dlc_flm/masks/flm/msk_flm_jacket",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true,
		offsets = {
			jacket = {
				Vector3(0, 0, 0),
				Rotation(0, -0.30048, 0)
			},
			joy = {
				Vector3(0, 0.673745, 0),
				Rotation(-0, -0, -0)
			}
		}
	}
	self.masks.flm_sydney = {
		unit = "units/pd2_dlc_flm/masks/flm/msk_flm_sydney",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true,
		offsets = {
			sydney = {
				Vector3(0, -0.0417333, 0.435252),
				Rotation(0, 0.558094, 0)
			}
		}
	}
	self.masks.flm_sokol = {
		unit = "units/pd2_dlc_flm/masks/flm/msk_flm_sokol",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true
	}
	self.masks.flm_ethan = {
		unit = "units/pd2_dlc_flm/masks/flm/msk_flm_ethan",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true,
		offsets = {
			ecp_male = {
				Vector3(0, -3.02289, 1.38922),
				Rotation(0, -12.3205, 0)
			}
		}
	}
	self.masks.flm = {
		name_id = "bm_msk_flm",
		value = 0,
		pcs = {},
		type = "helmet",
		texture_bundle_folder = "flm",
		sort_number = 68,
		dlc = "flm",
		global_value = "flm",
		night_vision = {
			effect = "color_night_vision",
			light = not _G.IS_VR and 0.3 or 0.1
		},
		characters = {
			dragan = "flm_01",
			wild = "flm_01",
			myh = "flm_01",
			chico = "flm_01",
			dragon = "flm_01",
			ecp_male = "flm_ethan",
			ecp_female = "flm_01",
			jowi = "flm_01",
			old_hoxton = "flm_01",
			bonnie = "flm_01",
			max = "flm_01",
			joy = "flm_jacket",
			dallas = "flm_01",
			jacket = "flm_jacket",
			jimmy = "flm_01",
			bodhi = "flm_01",
			wolf = "flm_01",
			sokol = "flm_sokol",
			hoxton = "flm_01",
			female_1 = "flm_clover",
			chains = "flm_01",
			sydney = "flm_sydney"
		}
	}
	self.masks.toon_01 = {
		unit = "units/pd2_dlc_toon/masks/toon_01/msk_toon_01",
		name_id = "bm_msk_toon_01",
		pcs = {},
		value = 0,
		texture_bundle_folder = "toon",
		sort_number = 69,
		dlc = "toon",
		global_value = "toon"
	}
	self.masks.toon_02 = {
		unit = "units/pd2_dlc_toon/masks/toon_02/msk_toon_02",
		name_id = "bm_msk_toon_02",
		pcs = {},
		value = 0,
		texture_bundle_folder = "toon",
		sort_number = 69,
		dlc = "toon",
		global_value = "toon"
	}
	self.masks.toon_03 = {
		unit = "units/pd2_dlc_toon/masks/toon_03/msk_toon_03",
		name_id = "bm_msk_toon_03",
		pcs = {},
		value = 0,
		texture_bundle_folder = "toon",
		sort_number = 69,
		dlc = "toon",
		global_value = "toon",
		offsets = {
			wild = {
				Vector3(0, -0.399472, -0.280226),
				Rotation(0, 3.99239, 0)
			},
			sydney = {
				Vector3(0, -0.876458, -0.995704),
				Rotation(0, 9.14383, 0)
			}
		}
	}
	self.masks.toon_04 = {
		unit = "units/pd2_dlc_toon/masks/toon_04/msk_toon_04",
		name_id = "bm_msk_toon_04",
		pcs = {},
		value = 0,
		texture_bundle_folder = "toon",
		sort_number = 69,
		dlc = "toon",
		global_value = "toon"
	}
	self.masks.ghx = {
		unit = "units/pd2_dlc_ghx/masks/msk_ghx_reborn/msk_ghx_reborn",
		name_id = "bm_msk_ghx",
		pcs = {},
		value = 0,
		texture_bundle_folder = "ghx",
		sort_number = 65,
		global_value = "pd2_clan",
		offsets = {
			joy = {
				Vector3(-0.399472, 0.435252, 0),
				Rotation(-0, -0, -0)
			}
		}
	}
	self.masks.ghm = {
		unit = "units/pd2_dlc_ghm/masks/msk_ghm/msk_ghm",
		name_id = "bm_msk_ghm",
		pcs = {},
		value = 0,
		texture_bundle_folder = "ghm",
		sort_number = 65,
		global_value = "pd2_clan"
	}
	self.masks.tam = {
		unit = "units/pd2_dlc_tam/masks/tam/msk_tam",
		name_id = "bm_msk_tam",
		pcs = {},
		value = 0,
		texture_bundle_folder = "tam",
		sort_number = 70,
		global_value = "tam"
	}
	self.masks.skm_07 = {
		global_value = "infamous",
		unit = "units/pd2_dlc_skm/masks/skm_07/msk_skm_07",
		name_id = "bm_msk_skm_07",
		pcs = {},
		value = 0,
		type = "helmet",
		texture_bundle_folder = "skm",
		sort_number = 71
	}
	self.masks.skm_08 = {
		global_value = "infamous",
		unit = "units/pd2_dlc_skm/masks/skm_08/msk_skm_08",
		name_id = "bm_msk_skm_08",
		pcs = {},
		value = 0,
		type = "helmet",
		texture_bundle_folder = "skm",
		sort_number = 71
	}
	self.masks.skm_common_01 = {
		unit = "units/pd2_dlc_skm/masks/skm_01/msk_skm_01",
		name_id = "bm_msk_cheat_error",
		pcs = {},
		value = 0,
		texture_bundle_folder = "skm",
		sort_number = 71,
		type = "helmet",
		inaccessible = true,
		offsets = {
			sydney = {
				Vector3(0.554498, 3.29716, -0.399472),
				Rotation(0, 4.85096, 0)
			},
			chains = {
				Vector3(0, 0, 0.196759),
				Rotation(-0, -0, -0)
			},
			female_1 = {
				Vector3(0, 3.17792, -1.11495),
				Rotation(0, 9.14383, 0)
			},
			hoxton = {
				Vector3(0.316006, 0, 0),
				Rotation(-0, -0, -0)
			},
			sokol = {
				Vector3(0.316006, 1.86621, 0.077513),
				Rotation(0, 3.99239, 0)
			},
			wolf = {
				Vector3(0.435252, 1.50847, 0.554498),
				Rotation(-0, -0, -0)
			},
			bodhi = {
				Vector3(0, 0.196759, 0.554498),
				Rotation(-0, -0, -0)
			},
			jimmy = {
				Vector3(0.077513, 2.70093, -2.42666),
				Rotation(0, 11.7196, 0)
			},
			max = {
				Vector3(0.196759, 1.03148, 0),
				Rotation(-0, -0, -0)
			},
			dallas = {
				Vector3(0, -0.16098, 0),
				Rotation(-0, -0, -0)
			},
			joy = {
				Vector3(0.316006, 2.93943, -1.2342),
				Rotation(0, 6.56811, 0)
			},
			bonnie = {
				Vector3(0.316006, 1.98545, 0.792991),
				Rotation(-0, -0, -0)
			},
			old_hoxton = {
				Vector3(0, 0.316006, 0),
				Rotation(-0, -0, -0)
			},
			dragon = {
				Vector3(0.196759, -0.16098, 0.435252),
				Rotation(-0, -0, -0)
			},
			wild = {
				Vector3(0.316006, 0, 0),
				Rotation(-0, -0, -0)
			},
			ecp_male = {
				Vector3(0.316006, 1.98545, -1.47269),
				Rotation(0, 8.28526, 0)
			},
			jacket = {
				Vector3(0.316006, 1.26998, -0.0417333),
				Rotation(0, 3.13382, 0)
			},
			chico = {
				Vector3(0.554498, 1.15073, 0.792991),
				Rotation(-0, -0, -0)
			},
			myh = {
				Vector3(0.077513, 0.196759, 0.316006),
				Rotation(-0, -0, -0)
			},
			jowi = {
				Vector3(0.316006, 0.316006, 1.03148),
				Rotation(-0, -0, -0)
			},
			dragan = {
				Vector3(0.196759, 1.50847, -0.757211),
				Rotation(0, 6.56811, 0)
			}
		}
	}
	self.masks.skm_hila_01 = {
		unit = "units/pd2_dlc_skm/masks/skm_01/msk_skm_hila_01",
		name_id = "bm_msk_cheat_error",
		type = "glasses",
		skip_mask_on_sequence = true,
		inaccessible = true,
		offsets = {
			ecp_female = {
				Vector3(0, 0.196759, -1.47269),
				Rotation(0, 10.0024, 0)
			}
		}
	}
	self.masks.skm_01 = {
		global_value = "infamous",
		name_id = "bm_msk_skm_01",
		value = 0,
		pcs = {},
		type = "helmet",
		texture_bundle_folder = "skm",
		sort_number = 71,
		characters = {
			dragan = "skm_common_01",
			dragon = "skm_common_01",
			myh = "skm_common_01",
			chico = "skm_common_01",
			sokol = "skm_common_01",
			ecp_male = "skm_common_01",
			ecp_female = "skm_hila_01",
			jowi = "skm_common_01",
			old_hoxton = "skm_common_01",
			bonnie = "skm_common_01",
			max = "skm_common_01",
			joy = "skm_common_01",
			dallas = "skm_common_01",
			jacket = "skm_common_01",
			jimmy = "skm_common_01",
			bodhi = "skm_common_01",
			wolf = "skm_common_01",
			wild = "skm_common_01",
			hoxton = "skm_common_01",
			female_1 = "skm_common_01",
			chains = "skm_common_01",
			sydney = "skm_common_01"
		}
	}
	self.masks.skm_02 = {
		global_value = "infamous",
		unit = "units/pd2_dlc_skm/masks/skm_02/msk_skm_02",
		name_id = "bm_msk_skm_02",
		pcs = {},
		value = 0,
		texture_bundle_folder = "skm",
		sort_number = 71,
		type = "glasses",
		skip_mask_on_sequence = true,
		offsets = {
			sydney = {
				Vector3(0, -0.399472, 0),
				Rotation(-0, -0, -0)
			},
			dragon = {
				Vector3(0, 5.20511, -2.30741),
				Rotation(0, 20.3053, 0)
			},
			hoxton = {
				Vector3(-0.16098, 0.196759, 0.077513),
				Rotation(-0, -0, -0)
			},
			wild = {
				Vector3(-0.280226, -0.16098, 0.435252),
				Rotation(-2.8762, 0, 0)
			},
			ecp_female = {
				Vector3(-0.0417333, -0.399472, 0),
				Rotation(-0, -0, -0)
			},
			ecp_male = {
				Vector3(-0.0417333, -0.399472, 0.196759),
				Rotation(-0, -0, -0)
			},
			old_hoxton = {
				Vector3(0, 2.46244, -0.399472),
				Rotation(0, 12.5781, 0)
			},
			chico = {
				Vector3(0, 4.01264, -1.94967),
				Rotation(0, 21.1639, 0)
			},
			jowi = {
				Vector3(0, 4.01264, -1.94967),
				Rotation(0, 21.1639, 0)
			},
			bonnie = {
				Vector3(0, 5.32435, -1.71118),
				Rotation(0, 20.3053, 0)
			},
			dragan = {
				Vector3(0, 3.41641, -1.35344),
				Rotation(0, 15.1538, 0)
			}
		}
	}
	self.masks.skm_common_03 = {
		global_value = "infamous",
		unit = "units/pd2_dlc_skm/masks/skm_03/msk_skm_03",
		name_id = "bm_msk_cheat_error",
		pcs = {},
		value = 0,
		texture_bundle_folder = "skm",
		sort_number = 71,
		type = "glasses",
		skip_mask_on_sequence = true,
		inaccessible = true,
		offsets = {
			sydney = {
				Vector3(0, -0.995704, 0),
				Rotation(0, 0, -0)
			},
			chains = {
				Vector3(0, -0.280226, 0),
				Rotation(0, 0, -0)
			},
			female_1 = {
				Vector3(0, -0.876458, -0.280226),
				Rotation(0, 0, -0)
			},
			hoxton = {
				Vector3(0, 0.554498, -1.83043),
				Rotation(0, 6.56811, 0)
			},
			sokol = {
				Vector3(0, -0.757211, -0.16098),
				Rotation(0, -2.01763, 0)
			},
			wolf = {
				Vector3(0, -0.399472, 0),
				Rotation(0, 0, -0)
			},
			jowi = {
				Vector3(0, -0.399472, 0),
				Rotation(0, 0, -0)
			},
			max = {
				Vector3(0, 0.077513, -1.47269),
				Rotation(3.33607e-09, 3.13382, 1.41667)
			},
			dallas = {
				Vector3(0, 0.196759, -1.47269),
				Rotation(0, 5.70954, 0)
			},
			joy = {
				Vector3(0, -0.876458, 0),
				Rotation(0, 0, -0)
			},
			old_hoxton = {
				Vector3(0, 0.077513, -1.59194),
				Rotation(0, 6.56811, 0)
			},
			ecp_female = {
				Vector3(0, -0.757211, -0.0417333),
				Rotation(0, 0, -0)
			},
			chico = {
				Vector3(0, -0.16098, -0.757211),
				Rotation(0, 0, -0)
			},
			jimmy = {
				Vector3(0.077513, 0.554498, -0.399472),
				Rotation(0, 0, -0)
			},
			dragan = {
				Vector3(0, -0.280226, -1.2342),
				Rotation(0, 3.13382, 0)
			}
		}
	}
	self.masks.skm_duke_03 = {
		unit = "units/pd2_dlc_skm/masks/skm_03/msk_skm_duke_03",
		name_id = "bm_msk_cheat_error",
		type = "glasses",
		skip_mask_on_sequence = true,
		inaccessible = true
	}
	self.masks.skm_ethan_03 = {
		unit = "units/pd2_dlc_skm/masks/skm_03/msk_skm_ethan_03",
		name_id = "bm_msk_cheat_error",
		type = "glasses",
		skip_mask_on_sequence = true,
		inaccessible = true
	}
	self.masks.skm_jiro_03 = {
		unit = "units/pd2_dlc_skm/masks/skm_03/msk_skm_jiro_03",
		name_id = "bm_msk_cheat_error",
		type = "glasses",
		skip_mask_on_sequence = true,
		inaccessible = true
	}
	self.masks.skm_rust_03 = {
		unit = "units/pd2_dlc_skm/masks/skm_03/msk_skm_rust_03",
		name_id = "bm_msk_cheat_error",
		type = "glasses",
		skip_mask_on_sequence = true,
		inaccessible = true
	}
	self.masks.skm_03 = {
		global_value = "infamous",
		name_id = "bm_msk_skm_03",
		value = 0,
		pcs = {},
		type = "glasses"
	}
	self.masks.skm_rust_03.skip_mask_on_sequence = true
	self.masks.skm_03.texture_bundle_folder = "skm"
	self.masks.skm_03.sort_number = 71
	self.masks.skm_03.characters = {
		dragan = "skm_common_03",
		dragon = "skm_jiro_03",
		myh = "skm_duke_03",
		chico = "skm_common_03",
		sokol = "skm_common_03",
		ecp_male = "skm_ethan_03",
		ecp_female = "skm_common_03",
		jowi = "skm_common_03",
		old_hoxton = "skm_common_03",
		bonnie = "skm_common_03",
		max = "skm_common_03",
		joy = "skm_common_03",
		dallas = "skm_common_03",
		jacket = "skm_common_03",
		jimmy = "skm_common_03",
		bodhi = "skm_common_03",
		wolf = "skm_common_03",
		wild = "skm_rust_03",
		hoxton = "skm_common_03",
		female_1 = "skm_common_03",
		chains = "skm_common_03",
		sydney = "skm_common_03"
	}
	self.masks.skm_04_common = {
		unit = "units/pd2_dlc_skm/masks/skm_04/msk_skm_04",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true,
		offsets = {
			chains = {
				Vector3(0, 0.196759, -0.518719),
				Rotation(-0, -0, -0)
			},
			dallas = {
				Vector3(0, 0, -0.995704),
				Rotation(-0, -0, -0)
			},
			chains = {
				Vector3(0, 0.316006, -0.637965),
				Rotation(-0, -0, -0)
			},
			dragan = {
				Vector3(-0.280226, 1.38922, -0.876458),
				Rotation(0, 5.70954, 0)
			},
			ecp_female = {
				Vector3(0, -0.518719, -0.637965),
				Rotation(-0, -0, -0)
			},
			bonnie = {
				Vector3(-0.518719, 2.1047, -0.518719),
				Rotation(-2.01763, 4.85096, 1.41667)
			}
		}
	}
	self.masks.skm_john_wick_04 = {
		unit = "units/pd2_dlc_skm/masks/skm_04/msk_skm_john_wick_04",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true
	}
	self.masks.skm_jiro_04 = {
		unit = "units/pd2_dlc_skm/masks/skm_04/msk_skm_jiro_04",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true,
		offsets = {
			dragon = {
				Vector3(0, 0.792991, -0.637965),
				Rotation(-0, -0, -0)
			}
		}
	}
	self.masks.skm_jimmy_04 = {
		unit = "units/pd2_dlc_skm/masks/skm_04/msk_skm_jimmy_04",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true,
		offsets = {
			sokol = {
				Vector3(0, 0, 0),
				Rotation(10.861, 0, 0)
			},
			female_1 = {
				Vector3(0, 0.673745, -0.637965),
				Rotation(0, 3.13382, 0)
			},
			sydney = {
				Vector3(0, 0.554498, 0.077513),
				Rotation(0, 3.13382, 0)
			}
		}
	}
	self.masks.skm_hila_04 = {
		unit = "units/pd2_dlc_skm/masks/skm_04/msk_skm_hila_04",
		name_id = "bm_msk_cheat_error",
		type = "glasses",
		skip_mask_on_sequence = true,
		inaccessible = true
	}
	self.masks.skm_rust_04 = {
		unit = "units/pd2_dlc_skm/masks/skm_04/msk_skm_rust_04",
		name_id = "bm_msk_cheat_error",
		type = "helmet",
		inaccessible = true,
		offsets = {
			max = {
				Vector3(0, 0, 0.316006),
				Rotation(-0, -0, -0)
			},
			myh = {
				Vector3(0, 0.196759, -0.280226),
				Rotation(-2.01763, 3.13382, -6.67011e-09)
			},
			ecp_male = {
				Vector3(0, 1.38922, -0.518719),
				Rotation(0.558094, 8.28526, -3.33505e-09)
			},
			old_hoxton = {
				Vector3(0, 1.15073, -0.757211),
				Rotation(0, 5.70954, 0)
			},
			sokol = {
				Vector3(0, -0.876458, 0.912237),
				Rotation(0, -4.59335, 0)
			},
			bodhi = {
				Vector3(0, 1.86621, -0.876458),
				Rotation(0, 8.28526, 0)
			}
		}
	}
	self.masks.skm_04 = {
		global_value = "infamous",
		name_id = "bm_msk_skm_04",
		value = 0,
		pcs = {},
		type = "helmet",
		texture_bundle_folder = "skm",
		sort_number = 71,
		characters = {
			bonnie = "skm_04_common",
			max = "skm_rust_04",
			myh = "skm_rust_04",
			chico = "skm_rust_04",
			chains = "skm_04_common",
			ecp_male = "skm_rust_04",
			ecp_female = "skm_hila_04",
			jowi = "skm_john_wick_04",
			old_hoxton = "skm_rust_04",
			dragan = "skm_04_common",
			wild = "skm_rust_04",
			joy = "skm_jimmy_04",
			dallas = "skm_jimmy_04",
			jacket = "skm_jimmy_04",
			jimmy = "skm_jimmy_04",
			bodhi = "skm_rust_04",
			wolf = "skm_jimmy_04",
			sokol = "skm_rust_04",
			hoxton = "skm_jimmy_04",
			female_1 = "skm_jimmy_04",
			dragon = "skm_jiro_04",
			sydney = "skm_jimmy_04"
		}
	}
	self.masks.skm_05 = {
		global_value = "infamous",
		unit = "units/pd2_dlc_skm/masks/skm_05/msk_skm_05",
		name_id = "bm_msk_skm_05",
		pcs = {},
		value = 0,
		texture_bundle_folder = "skm",
		sort_number = 71
	}
	self.masks.skm_06 = {
		global_value = "infamous",
		unit = "units/pd2_dlc_skm/masks/skm_06/msk_skm_06",
		name_id = "bm_msk_skm_06",
		type = "helmet",
		pcs = {},
		value = 0,
		texture_bundle_folder = "skm",
		sort_number = 71
	}
	self.masks.smo_01 = {
		unit = "units/pd2_dlc_smo/masks/smo_01/msk_smo_01",
		name_id = "bm_msk_smo_01",
		pcs = {},
		value = 0,
		type = "helmet",
		global_value = "infamous",
		texture_bundle_folder = "smo",
		sort_number = 72
	}
	self.masks.smo_common_02 = {
		unit = "units/pd2_dlc_smo/masks/smo_02/msk_smo_02",
		name_id = "bm_msk_smo_02",
		pcs = {},
		value = 0,
		type = "helmet",
		inaccessible = true,
		texture_bundle_folder = "smo",
		sort_number = 71,
		offsets = {
			jacket = {
				Vector3(0, -0.0417333, -0.637965),
				Rotation(-0, -0, -0)
			},
			sydney = {
				Vector3(0, 0, -0.518719),
				Rotation(-0, -0, -0)
			},
			dragon = {
				Vector3(0, 0, -0.16028),
				Rotation(-0, -0, -0)
			},
			wild = {
				Vector3(0, 0, -0.518719),
				Rotation(-0, -0, -0)
			},
			bonnie = {
				Vector3(0, 0, -0.16028),
				Rotation(-0, -0, -0)
			},
			max = {
				Vector3(0, 0.196759, 0),
				Rotation(-0, -0, -0)
			},
			chico = {
				Vector3(0, 0, -0.399472),
				Rotation(-0, -0, -0)
			},
			myh = {
				Vector3(0, 0, -0.518719),
				Rotation(-0, -0, -0)
			},
			bodhi = {
				Vector3(0, 0, -0.16028),
				Rotation(-0, -0, -0)
			},
			dragan = {
				Vector3(0, 0, -0.16028),
				Rotation(-0, -0, -0)
			}
		}
	}
	self.masks.smo_big_02 = {
		unit = "units/pd2_dlc_smo/masks/smo_02/msk_smo_big_02",
		name_id = "bm_msk_smo_02",
		type = "helmet",
		inaccessible = true,
		offsets = {
			joy = {
				Vector3(0, 0, 0),
				Rotation(-0, -0, -0)
			},
			jowi = {
				Vector3(0, 0, 1.15073),
				Rotation(-0, -0, -0)
			},
			jimmy = {
				Vector3(0, 0.316006, -0.0417333),
				Rotation(-0, -0, -0)
			}
		}
	}
	self.masks.smo_hila_02 = {
		unit = "units/pd2_dlc_smo/masks/smo_02/msk_smo_02",
		name_id = "bm_msk_smo_02",
		type = "glasses",
		skip_mask_on_sequence = true,
		inaccessible = true
	}
	self.masks.smo_02 = {
		name_id = "bm_msk_smo_02",
		value = 0,
		pcs = {},
		type = "helmet",
		global_value = "infamous",
		texture_bundle_folder = "smo",
		sort_number = 71,
		characters = {
			dragan = "smo_common_02",
			dragon = "smo_common_02",
			myh = "smo_common_02",
			chico = "smo_common_02",
			sokol = "smo_big_02",
			ecp_male = "smo_big_02",
			ecp_female = "smo_hila_02",
			jowi = "smo_big_02",
			old_hoxton = "smo_big_02",
			bonnie = "smo_common_02",
			max = "smo_common_02",
			joy = "smo_big_02",
			dallas = "smo_common_02",
			jacket = "smo_common_02",
			jimmy = "smo_big_02",
			bodhi = "smo_common_02",
			wolf = "smo_common_02",
			wild = "smo_common_02",
			hoxton = "smo_common_02",
			female_1 = "smo_big_02",
			chains = "smo_common_02",
			sydney = "smo_common_02"
		}
	}
	self.masks.smo_03 = {
		unit = "units/pd2_dlc_smo/masks/smo_03/msk_smo_03",
		name_id = "bm_msk_smo_03",
		pcs = {},
		value = 0,
		type = "helmet",
		global_value = "infamous",
		texture_bundle_folder = "smo",
		sort_number = 72,
		offsets = {
			ecp_male = {
				Vector3(-0.0417333, -0.280226, -1.83043),
				Rotation(-0, -0, -0)
			}
		}
	}
	self.masks.smo_04 = {
		unit = "units/pd2_dlc_smo/masks/smo_04/msk_smo_04",
		name_id = "bm_msk_smo_04",
		pcs = {},
		value = 0,
		type = "helmet",
		global_value = "infamous",
		texture_bundle_folder = "smo",
		sort_number = 72,
		offsets = {
			sydney = {
				Vector3(0, -0.876458, 2.22395),
				Rotation(-0, -0, -0)
			},
			chains = {
				Vector3(0, -1.94967, 3.05867),
				Rotation(0, -8.02764, 0)
			},
			female_1 = {
				Vector3(0, -1.47269, 1.15073),
				Rotation(-0, -0, -0)
			},
			hoxton = {
				Vector3(0, -2.18817, 4.01264),
				Rotation(0, -11.4619, 0)
			},
			sokol = {
				Vector3(0, -2.54591, 1.62772),
				Rotation(-0, -0, -0)
			},
			wolf = {
				Vector3(0, -2.18817, 2.70093),
				Rotation(0, -4.59335, 0)
			},
			bodhi = {
				Vector3(0, -2.30741, 1.86621),
				Rotation(-0, -0, -0)
			},
			jimmy = {
				Vector3(0, -1.47269, 1.03148),
				Rotation(-0, -0, -0)
			},
			jacket = {
				Vector3(0, -1.94967, 1.38922),
				Rotation(-0, -0, -0)
			},
			dallas = {
				Vector3(0, -1.94967, 1.98545),
				Rotation(-0, -0, -0)
			},
			joy = {
				Vector3(0, -0.637965, 2.22395),
				Rotation(-0, -0, -0)
			},
			jowi = {
				Vector3(0, -2.06892, 2.70093),
				Rotation(-0, -0, -0)
			},
			max = {
				Vector3(0, -1.83043, 1.98545),
				Rotation(-0, -0, -0)
			},
			old_hoxton = {
				Vector3(0, -2.7844, 1.15073),
				Rotation(-0, -0, -0)
			},
			dragan = {
				Vector3(0, -1.83043, 1.38922),
				Rotation(-0, -0, -0)
			},
			ecp_female = {
				Vector3(0, -0.876458, 2.34319),
				Rotation(-0, -0, -0)
			},
			ecp_male = {
				Vector3(0, -1.47269, 1.62772),
				Rotation(-0, -0, -0)
			},
			wild = {
				Vector3(0, -1.94967, 1.62772),
				Rotation(-0, -0, -0)
			},
			chico = {
				Vector3(0, -1.59194, 2.1047),
				Rotation(-0, -0, -0)
			},
			myh = {
				Vector3(0, -3.49988, 1.26998),
				Rotation(-0, -0, -0)
			},
			dragon = {
				Vector3(0, -1.83043, 1.15073),
				Rotation(-0, -0, -0)
			},
			bonnie = {
				Vector3(0, -1.83043, 1.15073),
				Rotation(-0, -0, -0)
			},
			jimmy = {
				Vector3(0, -1.59194, 2.1047),
				Rotation(-0, -0, -0)
			},
			jacket = {
				Vector3(-0.399472, -3.97686, 2.46244),
				Rotation(-0.30048, -7.16907, -0)
			}
		}
	}
	self.masks.smo_05 = {
		unit = "units/pd2_dlc_smo/masks/smo_05/msk_smo_05",
		name_id = "bm_msk_smo_05",
		pcs = {},
		value = 0,
		type = "helmet",
		global_value = "infamous",
		texture_bundle_folder = "smo",
		sort_number = 72
	}
	self.masks.smo_06 = {
		unit = "units/pd2_dlc_smo/masks/smo_06/msk_smo_06",
		name_id = "bm_msk_smo_06",
		pcs = {},
		value = 0,
		global_value = "infamous",
		texture_bundle_folder = "smo",
		sort_number = 72
	}
	self.masks.smo_07 = {
		unit = "units/pd2_dlc_smo/masks/smo_07/msk_smo_07",
		name_id = "bm_msk_smo_07",
		pcs = {},
		value = 0,
		type = "helmet",
		global_value = "infamous",
		texture_bundle_folder = "smo",
		sort_number = 72
	}
	self.masks.smo_08 = {
		unit = "units/pd2_dlc_smo/masks/smo_08/msk_smo_08",
		name_id = "bm_msk_smo_08",
		pcs = {},
		value = 0,
		global_value = "infamous",
		texture_bundle_folder = "smo",
		sort_number = 72
	}
	self.masks.smo_09 = {
		unit = "units/pd2_dlc_smo/masks/smo_09/msk_smo_09",
		name_id = "bm_msk_smo_09",
		pcs = {},
		value = 0,
		global_value = "infamous",
		texture_bundle_folder = "smo",
		sort_number = 72
	}
	self.masks.smo_10 = {
		unit = "units/pd2_dlc_smo/masks/smo_10/msk_smo_10",
		name_id = "bm_msk_smo_10",
		pcs = {},
		value = 0,
		global_value = "infamous",
		type = "tiara",
		skip_mask_on_sequence = true,
		texture_bundle_folder = "smo",
		sort_number = 72,
		offsets = {
			max = {
				Vector3(0, 0.077513, -1.11495),
				Rotation(0, 0, -0)
			},
			sydney = {
				Vector3(0, 1.26998, 3.53566),
				Rotation(0, -1.15905, 0)
			},
			joy = {
				Vector3(0, 1.98545, 0),
				Rotation(-0, -0, -0)
			},
			female_1 = {
				Vector3(0, 1.50847, -1.35344),
				Rotation(0, -0.30048, 0)
			},
			bonnie = {
				Vector3(-0.399472, 0, 0),
				Rotation(0, 0, -0)
			},
			wild = {
				Vector3(-0.280226, -0.876458, 0),
				Rotation(0, 0, -0)
			},
			chains = {
				Vector3(-0.637965, 0, -0.16098),
				Rotation(0, 0, -0)
			},
			ecp_male = {
				Vector3(0, 0, -1.71118),
				Rotation(0, 0, -0)
			},
			jimmy = {
				Vector3(0, 4.25114, 0),
				Rotation(0, 0, -0)
			},
			jacket = {
				Vector3(-0.518719, 0, -2.66515),
				Rotation(0, 15.1538, 0)
			},
			myh = {
				Vector3(-0.876458, -0.399472, 0.196759),
				Rotation(0, 0, -0)
			},
			dragon = {
				Vector3(0, 0.316006, -0.995704),
				Rotation(0, 10.0024, 0)
			},
			dragan = {
				Vector3(0, 0, 1.15073),
				Rotation(0, 0, -0)
			}
		}
	}
	self.masks.smo_11 = {
		unit = "units/pd2_dlc_smo/masks/smo_11/msk_smo_11",
		name_id = "bm_msk_smo_11",
		pcs = {},
		value = 0,
		type = "helmet",
		global_value = "infamous",
		texture_bundle_folder = "smo",
		sort_number = 72
	}
	self.masks.smo_12 = {
		unit = "units/pd2_dlc_smo/masks/smo_12/msk_smo_12",
		name_id = "bm_msk_smo_12",
		pcs = {},
		value = 0,
		global_value = "infamous",
		texture_bundle_folder = "smo",
		sort_number = 72
	}
	self.masks.maw_01 = {
		unit = "units/pd2_dlc_maw/masks/msk_maw_01",
		name_id = "bm_msk_maw_01",
		pcs = {},
		value = 0,
		texture_bundle_folder = "maw",
		sort_number = 73,
		global_value = "maw"
	}
	self.masks.sms_01 = {
		unit = "units/pd2_dlc_sms/masks/sms_01/msk_sms_01",
		name_id = "bm_msk_sms_01",
		value = 0,
		global_value = "infamous",
		texture_bundle_folder = "sms",
		sort_number = 73
	}
	self.masks.sms_02 = {
		unit = "units/pd2_dlc_sms/masks/sms_02/msk_sms_02",
		name_id = "bm_msk_sms_02",
		value = 0,
		global_value = "infamous",
		texture_bundle_folder = "sms",
		sort_number = 73
	}
	self.masks.sms_03 = {
		unit = "units/pd2_dlc_sms/masks/sms_03/msk_sms_03",
		name_id = "bm_msk_sms_03",
		value = 0,
		global_value = "infamous",
		texture_bundle_folder = "sms",
		sort_number = 73
	}
	self.masks.sms_04 = {
		unit = "units/pd2_dlc_sms/masks/sms_04/msk_sms_04",
		name_id = "bm_msk_sms_04",
		value = 0,
		global_value = "infamous",
		texture_bundle_folder = "sms",
		sort_number = 73
	}
	self.masks.sms_05 = {
		unit = "units/pd2_dlc_sms/masks/sms_05/msk_sms_05",
		name_id = "bm_msk_sms_05",
		value = 0,
		global_value = "infamous",
		texture_bundle_folder = "sms",
		sort_number = 73
	}
	self.masks.sms_06 = {
		unit = "units/pd2_dlc_sms/masks/sms_06/msk_sms_06",
		name_id = "bm_msk_sms_06",
		value = 0,
		global_value = "infamous",
		texture_bundle_folder = "sms",
		sort_number = 73,
		offsets = {
			wild = {
				Vector3(0, -0.399472, 0),
				Rotation(-0, -0, -0)
			},
			joy = {
				Vector3(0, 0, 0.316006),
				Rotation(-0, -0, -0)
			},
			sydney = {
				Vector3(0, -1.35344, 0),
				Rotation(-0, -0, -0)
			}
		}
	}
	self.masks.sms_07 = {
		unit = "units/pd2_dlc_sms/masks/sms_07/msk_sms_07",
		name_id = "bm_msk_sms_07",
		value = 0,
		global_value = "infamous",
		texture_bundle_folder = "sms",
		sort_number = 73
	}
	self.masks.sms_08 = {
		unit = "units/pd2_dlc_sms/masks/sms_08/msk_sms_08",
		name_id = "bm_msk_sms_08",
		value = 0,
		global_value = "infamous",
		texture_bundle_folder = "sms",
		sort_number = 73
	}
	self.masks.scm_01 = {
		unit = "units/pd2_dlc_scm/masks/scm_01/msk_scm_01",
		name_id = "bm_msk_scm_01",
		value = 0,
		global_value = "infamous",
		texture_bundle_folder = "scm",
		sort_number = 75
	}
	self.masks.scm_02 = {
		unit = "units/pd2_dlc_scm/masks/scm_02/msk_scm_02",
		name_id = "bm_msk_scm_02",
		value = 0,
		global_value = "infamous",
		texture_bundle_folder = "scm",
		sort_number = 75
	}
	local free_dlcs = tweak_data:free_dlc_list()

	for _, data in pairs(self.masks) do
		if free_dlcs[data.dlc] then
			data.dlc = nil
		end
	end

	self:_add_desc_from_name_macro(self.masks)
end
