local is_nextgen_console = SystemInfo:platform() == Idstring("PS4") or SystemInfo:platform() == Idstring("XB1")

function BlackMarketTweakData:_init_textures(tweak_data)
	self.textures = {
		no_color_no_material = {}
	}
	self.textures.no_color_no_material.name_id = "bm_txt_no_color_no_material"
	self.textures.no_color_no_material.texture = "units/payday2/masks/shared_textures/patterns/pattern_no_color_no_material_df"
	self.textures.no_color_no_material.value = 0
	self.textures.no_color_full_material = {
		name_id = "bm_txt_no_color_full_material",
		texture = "units/payday2/masks/shared_textures/patterns/pattern_no_color_full_material_df",
		value = 1
	}
	self.textures.big_skull = {
		name_id = "bm_txt_big_skull",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_big_skull_df",
		value = 4
	}
	self.textures.eightball = {
		name_id = "bm_txt_eightball",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_eightball_df",
		value = 8
	}
	self.textures.zebra = {
		name_id = "bm_txt_zebra",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_zebra_df",
		value = 3
	}
	self.textures.overkill = {
		name_id = "bm_txt_overkill",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_overkill_df",
		infamous = true,
		value = 10
	}
	self.textures.spawn = {
		name_id = "bm_txt_spawn",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_spawn_df",
		infamous = true,
		value = 4
	}
	self.textures.marv = {
		name_id = "bm_txt_marv",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_marv_df",
		value = 5
	}
	self.textures.starbreeze = {
		name_id = "bm_txt_starbreeze",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_starbreeze_df",
		value = 3
	}
	self.textures.cobrakai = {
		name_id = "bm_txt_cobrakai",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_cobrakai_df",
		infamous = true,
		value = 4
	}
	self.textures.flames = {
		name_id = "bm_txt_flames",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_flames_df",
		value = 6
	}
	self.textures.tribal = {
		name_id = "bm_txt_tribal",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_tribal_df",
		value = 7
	}
	self.textures.skull = {
		name_id = "bm_txt_skull",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_skull_df",
		value = 8
	}
	self.textures.arrow = {
		name_id = "bm_txt_arrow",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_arrow_df",
		value = 3
	}
	self.textures.usa = {
		name_id = "bm_txt_usa",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_usa_df",
		value = 5
	}
	self.textures.unionjack = {
		name_id = "bm_txt_unionjack",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_unionjack_df",
		value = 6
	}
	self.textures.fleur = {
		name_id = "bm_txt_fleur",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_fleur_df",
		value = 7
	}
	self.textures.hearts = {
		name_id = "bm_txt_hearts",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_hearts_df",
		value = 4
	}
	self.textures.electric = {
		name_id = "bm_txt_electric",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_electric_df",
		value = 3,
		infamous = true
	}
	self.textures.puzzle = {
		name_id = "bm_txt_puzzle",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_puzzle_df",
		value = 5
	}
	self.textures.swe_camo = {
		name_id = "bm_txt_swe_camo",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_swe_camo_df",
		value = 6
	}
	self.textures.japan = {
		name_id = "bm_txt_japan",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_japan_df",
		value = 7
	}
	self.textures.celtic1 = {
		name_id = "bm_txt_celtic1",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_celtic1_df",
		value = 3
	}
	self.textures.dragon_full = {
		name_id = "bm_txt_dragon_full",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_dragon_full_df",
		infamous = true,
		value = 9
	}
	self.textures.dragon_split = {
		name_id = "bm_txt_dragon_split",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_dragon_split_df",
		value = 5
	}
	self.textures.horizon_circle = {
		name_id = "bm_txt_horizon_circle",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_horizon_circle_df",
		value = 4
	}
	self.textures.tribal2 = {
		name_id = "bm_txt_tribal2",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_tribal2_df",
		value = 8
	}
	self.textures.vertical = {
		name_id = "bm_txt_vertical",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_vertical_df",
		value = 4
	}
	self.textures.celtic2 = {
		name_id = "bm_txt_celtic2",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_celtic2_df",
		value = 2
	}
	self.textures.beast = {
		name_id = "bm_txt_beast",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_beast_df",
		value = 3
	}
	self.textures.headshot = {
		name_id = "bm_txt_headshot",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_headshot_df",
		value = 5
	}
	self.textures.circuit = {
		name_id = "bm_txt_circuit",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_circuit_df",
		value = 3
	}
	self.textures.paint1 = {
		name_id = "bm_txt_paint1",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_paint1_df",
		value = 2
	}
	self.textures.chains = {
		name_id = "bm_txt_chains",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_chains_df",
		value = 4
	}
	self.textures.yinyang = {
		name_id = "bm_txt_yinyang",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_yinyang_df",
		value = 6
	}
	self.textures.rorschach = {
		name_id = "bm_txt_rorschach",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_rorschach_df",
		infamous = true,
		value = 6
	}
	self.textures.zipper = {
		name_id = "bm_txt_zipper",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_zipper_df",
		value = 2
	}
	self.textures.daniel = {
		name_id = "bm_txt_daniel",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_daniel_df",
		value = 2
	}
	self.textures.ouroboros = {
		name_id = "bm_txt_ouroboros",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_ouroboros_df",
		value = 7
	}
	self.textures.ouro = {
		name_id = "bm_txt_ouro",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_ouro_df",
		value = 5
	}
	self.textures.cat = {
		name_id = "bm_txt_cat",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_cat_df",
		infamous = true,
		value = 6
	}
	self.textures.clown = {
		name_id = "bm_txt_clown",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_clown_df",
		value = 2
	}
	self.textures.paint2 = {
		name_id = "bm_txt_paint2",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_paint2_df",
		value = 2
	}
	self.textures.spider = {
		name_id = "bm_txt_spider",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_spider_df",
		value = 7
	}
	self.textures.target = {
		name_id = "bm_txt_target",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_target_df",
		value = 5
	}
	self.textures.illuminati = {
		name_id = "bm_txt_illuminati",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_illuminati_df",
		value = 7
	}
	self.textures.hypnotic = {
		name_id = "bm_txt_hypnotic",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_hypnotic_df",
		value = 3
	}
	self.textures.hexagon = {
		name_id = "bm_txt_hexagon",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_hexagon_df",
		value = 4
	}
	self.textures.messatsu = {
		name_id = "bm_txt_messatsu",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_messatsu_df",
		value = 2
	}
	self.textures.shazam = {
		name_id = "bm_txt_shazam",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_shazam_df",
		value = 2
	}
	self.textures.emblem1 = {
		name_id = "bm_txt_emblem1",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_emblem1_df",
		value = 1
	}
	self.textures.emblem2 = {
		name_id = "bm_txt_emblem2",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_emblem2_df",
		value = 2
	}
	self.textures.emblem3 = {
		name_id = "bm_txt_emblem3",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_emblem3_df",
		value = 3
	}
	self.textures.swirl = {
		name_id = "bm_txt_swirl",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_swirl_df",
		value = 4
	}
	self.textures.kabuki1 = {
		name_id = "bm_txt_kabuki1",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_kabuki1_df",
		value = 5
	}
	self.textures.ultimaterobber = {
		name_id = "bm_txt_ultimaterobber",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_ultimaterobber_df",
		infamous = true,
		value = 6
	}
	self.textures.nuclear = {
		name_id = "bm_txt_nuclear",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_nuclear_df",
		value = 7
	}
	self.textures.gearhead = {
		name_id = "bm_txt_gearhead",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_gearhead_df",
		value = 6
	}
	self.textures.atom = {
		name_id = "bm_txt_atom",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_atom_df",
		value = 5
	}
	self.textures.hand = {
		name_id = "bm_txt_hand",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_hand_df",
		value = 4
	}
	self.textures.scars = {
		name_id = "bm_txt_scars",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_scars_df",
		value = 3
	}
	self.textures.pirate = {
		name_id = "bm_txt_pirate",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_pirate_df",
		value = 2
	}
	self.textures.foot = {
		name_id = "bm_txt_foot",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_foot_df",
		value = 7
	}
	self.textures.star = {
		name_id = "bm_txt_star",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_star_df",
		value = 8
	}
	self.textures.portal = {
		name_id = "bm_txt_portal",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_portal_df",
		value = 6
	}
	self.textures.aperture = {
		name_id = "bm_txt_aperture",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_aperture_df",
		value = 5
	}
	self.textures.girlsandboys = {
		name_id = "bm_txt_girlsandboys",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_girlsandboys_df",
		value = 4
	}
	self.textures.loverboy = {
		name_id = "bm_txt_loverboy",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_loverboy_df",
		value = 3
	}
	self.textures.cogs = {
		name_id = "bm_txt_cogs",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_cogs_df",
		value = 4
	}
	self.textures.ace = {
		name_id = "bm_txt_ace",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_ace_df",
		infamous = true,
		value = 5
	}
	self.textures.compass = {
		name_id = "bm_txt_compass",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_compass_df",
		value = 2
	}
	self.textures.fan = {
		name_id = "bm_txt_fan",
		pcs = {
			10,
			20,
			30,
			40
		},
		dlc = "preorder",
		texture = "units/payday2/masks/shared_textures/patterns/pattern_fan_df",
		value = 1
	}
	self.textures.pd2 = {
		name_id = "bm_txt_pd2",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_pd2_df",
		value = 4
	}
	self.textures.fingerprint = {
		name_id = "bm_txt_fingerprint",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_fingerprint_df",
		infamous = true,
		value = 3
	}
	self.textures.biohazard = {
		name_id = "bm_txt_biohazard",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_biohazard_df",
		value = 2
	}
	self.textures.tf2 = {
		name_id = "bm_txt_tf2",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_tf2_df",
		value = 3
	}
	self.textures.cake = {
		name_id = "bm_txt_cake",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_cake_df",
		value = 4
	}
	self.textures.companioncube = {
		name_id = "bm_txt_companioncube",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_companioncube_df",
		value = 6
	}
	self.textures.two = {
		name_id = "bm_txt_two",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_two_df",
		value = 5
	}
	self.textures.striped = {
		name_id = "bm_txt_striped",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_striped_df",
		value = 3
	}
	self.textures.solidfirst = {
		name_id = "bm_txt_solidfirst",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_solidfirst_df",
		infamous = true,
		value = 6
	}
	self.textures.solidsecond = {
		name_id = "bm_txt_solidsecond",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_solidsecond_df",
		infamous = true,
		value = 6
	}
	self.textures.mantis = {
		name_id = "bm_txt_mantis",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_mantis_df",
		value = 7
	}
	self.textures.bite = {
		name_id = "bm_txt_bite",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_bite_df",
		value = 3
	}
	self.textures.wtf = {
		name_id = "bm_txt_wtf",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_wtf_df",
		value = 4
	}
	self.textures.bloodsucker = {
		name_id = "bm_txt_bloodsucker",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_bloodsucker_df",
		value = 2
	}
	self.textures.hawk = {
		name_id = "bm_txt_hawk",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_hawk_df",
		value = 4
	}
	self.textures.magnet = {
		name_id = "bm_txt_magnet",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_magnet_df",
		value = 2
	}
	self.textures.diamond = {
		name_id = "bm_txt_diamond",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_diamond_df",
		value = 3
	}
	self.textures.luchador = {
		name_id = "bm_txt_luchador",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_luchador_df",
		value = 1
	}
	self.textures.maskedfalcon = {
		name_id = "bm_txt_maskedfalcon",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_maskedfalcon_df",
		value = 3
	}
	self.textures.grayson = {
		name_id = "bm_txt_grayson",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_grayson_df",
		value = 2
	}
	self.textures.sidestripe = {
		name_id = "bm_txt_sidestripe",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_sidestripe_df",
		value = 5
	}
	self.textures.gradient = {
		name_id = "bm_txt_gradient",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_gradient_df",
		value = 4
	}
	self.textures.spikes = {
		name_id = "bm_txt_spikes",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_spikes_df",
		value = 3
	}
	self.textures.barbarian = {
		name_id = "bm_txt_barbarian",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_barbarian_df",
		value = 2
	}
	self.textures.reaper = {
		name_id = "bm_txt_reaper",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_reaper_df",
		value = 4
	}
	self.textures.whiner = {
		name_id = "bm_txt_whiner",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_whiner_df",
		value = 3
	}
	self.textures.emblem4 = {
		name_id = "bm_txt_emblem4",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_emblem4_df",
		value = 2
	}
	self.textures.daft_heart = {
		name_id = "bm_txt_daft_heart",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_daft_heart_df",
		value = 3
	}
	self.textures.anarchy = {
		name_id = "bm_txt_anarchy",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_anarchy_df",
		value = 4
	}
	self.textures.molecule = {
		name_id = "bm_txt_molecule",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_molecule_df",
		value = 3
	}
	self.textures.fleur2 = {
		name_id = "bm_txt_fleur2",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_fleur2_df",
		infamous = true,
		value = 3
	}
	self.textures.trekronor = {
		name_id = "bm_txt_trekronor",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_trekronor_df",
		value = 2
	}
	self.textures.raster = {
		name_id = "bm_txt_raster",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_raster_df",
		value = 1
	}
	self.textures.flag = {
		name_id = "bm_txt_flag",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_flag_df",
		value = 4
	}
	self.textures.cracker = {
		name_id = "bm_txt_cracker",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_cracker_df",
		value = 4
	}
	self.textures.hellish = {
		name_id = "bm_txt_hellish",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_hellish_df",
		value = 4
	}
	self.textures.poison = {
		name_id = "bm_txt_poison",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_poison_df",
		value = 4
	}
	self.textures.yggdrasil = {
		name_id = "bm_txt_yggdrasil",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/payday2/masks/shared_textures/patterns/pattern_yggdrasil_df",
		value = 4
	}
	self.textures.pumpgrin = {
		name_id = "bm_txt_pumpgrin"
	}

	if is_nextgen_console then
		self.textures.pumpgrin.pcs = {
			10,
			20,
			30,
			40
		}
	else
		self.textures.pumpgrin.pcs = {
			10,
			20,
			30,
			40
		}
		self.textures.pumpgrin.weight = 3
	end

	self.textures.pumpgrin.texture = "units/payday2/masks/shared_textures/patterns/pattern_pumpgrin_df"
	self.textures.pumpgrin.global_value = "halloween"
	self.textures.pumpgrin.value = 5
	self.textures.shout = {
		name_id = "bm_txt_shout"
	}

	if is_nextgen_console then
		self.textures.shout.pcs = {
			10,
			20,
			30,
			40
		}
	else
		self.textures.shout.pcs = {
			10,
			20,
			30,
			40
		}
		self.textures.shout.weight = 3
	end

	self.textures.shout.texture = "units/payday2/masks/shared_textures/patterns/pattern_shout_df"
	self.textures.shout.global_value = "halloween"
	self.textures.shout.value = 5
	self.textures.webbed = {
		name_id = "bm_txt_webbed"
	}

	if is_nextgen_console then
		self.textures.webbed.pcs = {
			10,
			20,
			30,
			40
		}
	else
		self.textures.webbed.pcs = {
			10,
			20,
			30,
			40
		}
		self.textures.webbed.weight = 3
	end

	self.textures.webbed.texture = "units/payday2/masks/shared_textures/patterns/pattern_webbed_df"
	self.textures.webbed.global_value = "halloween"
	self.textures.webbed.value = 5
	self.textures.hannibalistic = {
		name_id = "bm_txt_hannibalistic"
	}

	if is_nextgen_console then
		self.textures.hannibalistic.pcs = {
			10,
			20,
			30,
			40
		}
	else
		self.textures.hannibalistic.pcs = {
			10,
			20,
			30,
			40
		}
		self.textures.hannibalistic.weight = 3
	end

	self.textures.hannibalistic.texture = "units/payday2/masks/shared_textures/patterns/pattern_hannibalistic_df"
	self.textures.hannibalistic.global_value = "halloween"
	self.textures.hannibalistic.value = 5
	self.textures.stitches = {
		name_id = "bm_txt_stitches"
	}

	if is_nextgen_console then
		self.textures.stitches.pcs = {
			10,
			20,
			30,
			40
		}
	else
		self.textures.stitches.pcs = {
			10,
			20,
			30,
			40
		}
		self.textures.stitches.weight = 3
	end

	self.textures.stitches.texture = "units/payday2/masks/shared_textures/patterns/pattern_stitches_df"
	self.textures.stitches.global_value = "halloween"
	self.textures.stitches.value = 4
	self.textures.doomweaver = {
		name_id = "bm_txt_doomweaver"
	}

	if is_nextgen_console then
		self.textures.doomweaver.pcs = {
			10,
			20,
			30,
			40
		}
	else
		self.textures.doomweaver.pcs = {
			10,
			20,
			30,
			40
		}
		self.textures.doomweaver.weight = 3
	end

	self.textures.doomweaver.texture = "units/payday2/masks/shared_textures/patterns/pattern_doomweaver_df"
	self.textures.doomweaver.global_value = "halloween"
	self.textures.doomweaver.value = 4
	self.textures.racestripes = {
		name_id = "bm_txt_racestripes",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc1/masks/patterns/pattern_racestripes_df",
		value = 4,
		dlc = "armored_transport"
	}
	self.textures.americaneagle = {
		name_id = "bm_txt_americaneagle",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc1/masks/patterns/pattern_americaneagle_df",
		value = 4,
		dlc = "armored_transport"
	}
	self.textures.stars = {
		name_id = "bm_txt_stars",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc1/masks/patterns/pattern_stars_df",
		value = 4,
		dlc = "armored_transport"
	}
	self.textures.forestcamo = {
		name_id = "bm_txt_forestcamo",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc1/masks/patterns/pattern_forestcamo_df",
		value = 4,
		dlc = "armored_transport"
	}
	self.textures.army = {
		name_id = "bm_txt_army",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_dec5/masks/patterns/pattern_army_df",
		value = 4,
		dlc = "gage_pack"
	}
	self.textures.commando = {
		name_id = "bm_txt_commando",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_dec5/masks/patterns/pattern_commando_df",
		value = 4,
		dlc = "gage_pack"
	}
	self.textures.hunter = {
		name_id = "bm_txt_hunter",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_dec5/masks/patterns/pattern_hunter_df",
		value = 4,
		dlc = "gage_pack"
	}
	self.textures.digitalcamo = {
		name_id = "bm_txt_digitalcamo",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_dec5/masks/patterns/pattern_digitalcamo_df",
		value = 4,
		dlc = "gage_pack"
	}
	self.textures.ribcage = {
		name_id = "bm_txt_ribcage",
		pcs = {},
		texture = "units/pd2_dlc_infamy/masks/patterns/pattern_ribcage_df",
		value = 0,
		global_value = "infamy",
		infamy_lock = "infamy_ghost"
	}
	self.textures.toto = {
		name_id = "bm_txt_toto",
		pcs = {},
		texture = "units/pd2_dlc_infamy/masks/patterns/pattern_toto_df",
		value = 0,
		global_value = "infamy",
		infamy_lock = "infamy_technician"
	}
	self.textures.imperial = {
		name_id = "bm_txt_imperial",
		pcs = {},
		texture = "units/pd2_dlc_infamy/masks/patterns/pattern_imperial_df",
		value = 0,
		global_value = "infamy",
		infamy_lock = "infamy_mastermind"
	}
	self.textures.fatman = {
		name_id = "bm_txt_fatman",
		pcs = {},
		texture = "units/pd2_dlc_infamy/masks/patterns/pattern_fatman_df",
		value = 0,
		global_value = "infamy",
		infamy_lock = "infamy_enforcer"
	}
	self.textures.digital = {
		name_id = "bm_txt_digital",
		pcs = {},
		texture = "units/pd2_dlc_infamy/masks/patterns/pattern_digital_df",
		value = 0,
		global_value = "infamy",
		infamy_lock = "infamy_maskpack_daft"
	}
	self.textures.evileye = {
		name_id = "bm_txt_evileye",
		pcs = {},
		texture = "units/pd2_dlc_infamy/masks/patterns/pattern_evileye_df",
		value = 0,
		global_value = "infamy",
		infamy_lock = "infamy_maskpack_hood"
	}
	self.textures.exmachina = {
		name_id = "bm_txt_exmachina",
		pcs = {},
		texture = "units/pd2_dlc_infamy/masks/patterns/pattern_exmachina_df",
		value = 0,
		global_value = "infamy",
		infamy_lock = "infamy_maskpack_destroyer"
	}
	self.textures.hellsanchor = {
		name_id = "bm_txt_hellsanchor",
		pcs = {},
		texture = "units/pd2_dlc_infamy/masks/patterns/pattern_hellsanchor_df",
		value = 0,
		global_value = "infamy",
		infamy_lock = "infamy_maskpack_lurker"
	}
	self.textures.monstervisor = {
		name_id = "bm_txt_monstervisor",
		pcs = {},
		texture = "units/pd2_dlc_infamy/masks/patterns/pattern_monstervisor_df",
		value = 0,
		global_value = "infamy",
		infamy_lock = "infamy_maskpack_ranger"
	}
	self.textures.pain = {
		name_id = "bm_txt_pain",
		pcs = {},
		texture = "units/pd2_dlc_infamy/masks/patterns/pattern_pain_df",
		value = 0,
		global_value = "infamy",
		infamy_lock = "infamy_maskpack_balaclava"
	}
	self.textures.spook = {
		name_id = "bm_txt_spook",
		pcs = {},
		texture = "units/pd2_dlc_infamy/masks/patterns/pattern_spook_df",
		value = 0,
		global_value = "infamy",
		infamy_lock = "infamy_maskpack_pain"
	}
	self.textures.steampunk = {
		name_id = "bm_txt_steampunk",
		pcs = {},
		texture = "units/pd2_dlc_infamy/masks/patterns/pattern_steampunk_df",
		value = 0,
		global_value = "infamy",
		infamy_lock = "infamy_maskpack_punk"
	}
	self.textures.styx = {
		name_id = "bm_txt_styx",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_gage_lmg/masks/patterns/styx_df",
		value = 4,
		dlc = "gage_pack_lmg"
	}
	self.textures.fingerpaint = {
		name_id = "bm_txt_fingerpaint",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_gage_lmg/masks/patterns/fingerpaint_df",
		value = 4,
		dlc = "gage_pack_lmg"
	}
	self.textures.fighter = {
		name_id = "bm_txt_fighter",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_gage_lmg/masks/patterns/fighter_df",
		value = 4,
		dlc = "gage_pack_lmg"
	}
	self.textures.warrior = {
		name_id = "bm_txt_warrior",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_gage_lmg/masks/patterns/warrior_df",
		value = 4,
		dlc = "gage_pack_lmg"
	}
	self.textures.bugger = {
		name_id = "bm_txt_bugger",
		pcs = {},
		texture = "units/pd2_dlc_gage_snp/patterns/pattern_bugger_df",
		value = 0,
		dlc = "gage_pack_snp"
	}
	self.textures.spidereyes = {
		name_id = "bm_txt_spidereyes",
		pcs = {},
		texture = "units/pd2_dlc_gage_snp/patterns/pattern_spidereyes_df",
		value = 0,
		dlc = "gage_pack_snp"
	}
	self.textures.venomous = {
		name_id = "bm_txt_venomous",
		pcs = {},
		texture = "units/pd2_dlc_gage_snp/patterns/pattern_venomous_df",
		value = 0,
		dlc = "gage_pack_snp"
	}
	self.textures.wingsofdeath = {
		name_id = "bm_txt_wingsofdeath",
		pcs = {},
		texture = "units/pd2_dlc_gage_snp/patterns/pattern_wingsofdeath_df",
		value = 0,
		dlc = "gage_pack_snp"
	}
	self.textures.deathcube = {
		name_id = "bm_txt_deathcube",
		pcs = {},
		texture = "units/pd2_poetry_winners/patterns/pattern_deathcube_df",
		value = 0,
		dlc = "poetry_soundtrack",
		global_value = "poetry_soundtrack"
	}
	self.textures.tcn = {
		name_id = "bm_txt_tcn",
		pcs = {},
		texture = "units/pd2_poetry_winners/patterns/pattern_tcn_df",
		value = 0,
		dlc = "poetry_soundtrack",
		global_value = "poetry_soundtrack"
	}
	self.textures.tribalstroke = {
		name_id = "bm_txt_tribalstroke",
		pcs = {},
		texture = "units/pd2_poetry_winners/patterns/pattern_tribalstroke_df",
		value = 0,
		dlc = "poetry_soundtrack",
		global_value = "poetry_soundtrack"
	}
	self.textures.kraken = {
		name_id = "bm_txt_kraken",
		pcs = {},
		texture = "units/pd2_poetry_winners/patterns/pattern_kraken_df",
		value = 0,
		dlc = "poetry_soundtrack",
		global_value = "poetry_soundtrack"
	}
	self.textures.roman = {
		name_id = "bm_txt_roman",
		pcs = {},
		texture = "units/pd2_dlc_big/masks/patterns/pattern_roman_df",
		value = 0,
		dlc = "big_bank"
	}
	self.textures.wargod = {
		name_id = "bm_txt_wargod",
		pcs = {},
		texture = "units/pd2_dlc_big/masks/patterns/pattern_wargod_df",
		value = 0,
		dlc = "big_bank"
	}
	self.textures.spartan = {
		name_id = "bm_txt_spartan",
		pcs = {},
		texture = "units/pd2_dlc_big/masks/patterns/pattern_spartan_df",
		value = 0,
		dlc = "big_bank"
	}
	self.textures.ruler = {
		name_id = "bm_txt_ruler",
		pcs = {},
		texture = "units/pd2_dlc_big/masks/patterns/pattern_ruler_df",
		value = 0,
		dlc = "big_bank"
	}
	self.textures.banana = {
		name_id = "bm_txt_banana",
		pcs = {},
		texture = "units/pd2_dlc_gage_shot/patterns/pattern_banana_df",
		value = 0,
		dlc = "gage_pack_shotgun"
	}
	self.textures.chief = {
		name_id = "bm_txt_chief",
		pcs = {},
		texture = "units/pd2_dlc_gage_shot/patterns/pattern_chief_df",
		value = 0,
		dlc = "gage_pack_shotgun"
	}
	self.textures.monkeyskull = {
		name_id = "bm_txt_monkeyskull",
		pcs = {},
		texture = "units/pd2_dlc_gage_shot/patterns/pattern_monkeyskull_df",
		value = 0,
		dlc = "gage_pack_shotgun"
	}
	self.textures.terror = {
		name_id = "bm_txt_terror",
		pcs = {},
		texture = "units/pd2_dlc_gage_shot/patterns/pattern_terror_df",
		value = 0,
		dlc = "gage_pack_shotgun"
	}
	self.textures.muerte = {
		name_id = "bm_txt_muerte",
		pcs = {},
		texture = "units/pd2_dlc_gage_assault/masks/patterns/pattern_muerte_df",
		value = 0,
		dlc = "gage_pack_assault"
	}
	self.textures.emperor = {
		name_id = "bm_txt_emperor",
		pcs = {},
		texture = "units/pd2_dlc_gage_assault/masks/patterns/pattern_emperor_df",
		value = 0,
		dlc = "gage_pack_assault"
	}
	self.textures.vicious = {
		name_id = "bm_txt_vicious",
		pcs = {},
		texture = "units/pd2_dlc_gage_assault/masks/patterns/pattern_vicious_df",
		value = 0,
		dlc = "gage_pack_assault"
	}
	self.textures.death = {
		name_id = "bm_txt_death",
		pcs = {},
		texture = "units/pd2_dlc_gage_assault/masks/patterns/pattern_death_df",
		value = 0,
		dlc = "gage_pack_assault"
	}
	self.textures.doodles = {
		name_id = "bm_txt_doodles",
		pcs = {},
		texture = "units/pd2_dlc_miami/masks/patterns/pattern_doodles_df",
		value = 0,
		dlc = "hl_miami",
		texture_bundle_folder = "hl_miami"
	}
	self.textures.hiptobepolygon = {
		name_id = "bm_txt_hiptobepolygon",
		pcs = {},
		texture = "units/pd2_dlc_miami/masks/patterns/pattern_hiptobepolygon_df",
		value = 0,
		dlc = "hl_miami",
		texture_bundle_folder = "hl_miami"
	}
	self.textures.palmtrees = {
		name_id = "bm_txt_palmtrees",
		pcs = {},
		texture = "units/pd2_dlc_miami/masks/patterns/pattern_palmtrees_df",
		value = 0,
		dlc = "hl_miami",
		texture_bundle_folder = "hl_miami"
	}
	self.textures.bsomebody = {
		name_id = "bm_txt_bsomebody",
		pcs = {},
		texture = "units/pd2_dlc_miami/masks/patterns/pattern_bsomebody_df",
		value = 0,
		dlc = "hl_miami",
		texture_bundle_folder = "hl_miami"
	}
	self.textures.hotline = {
		name_id = "bm_txt_hotline",
		pcs = {},
		texture = "units/pd2_dlc_miami/masks/patterns/pattern_hotline_df",
		value = 0,
		dlc = "hlm_game",
		texture_bundle_folder = "hl_miami"
	}
	self.textures.leopard = {
		name_id = "bm_txt_leopard",
		pcs = {},
		texture = "units/pd2_dlc_miami/masks/patterns/pattern_leopard_df",
		value = 0,
		dlc = "hlm_game",
		texture_bundle_folder = "hl_miami"
	}
	self.textures.shutupandbleed = {
		name_id = "bm_txt_shutupandbleed",
		pcs = {},
		texture = "units/pd2_dlc_miami/masks/patterns/pattern_shutupandbleed_df",
		value = 0,
		dlc = "hlm_game",
		texture_bundle_folder = "hl_miami"
	}
	self.textures.uglyrug = {
		name_id = "bm_txt_uglyrug",
		pcs = {},
		texture = "units/pd2_dlc_miami/masks/patterns/pattern_uglyrug_df",
		value = 0,
		dlc = "hlm_game",
		texture_bundle_folder = "hl_miami"
	}
	self.textures.captainwar = {
		name_id = "bm_txt_captainwar",
		pcs = {},
		texture = "units/pd2_dlc_gage_historical/patterns/pattern_captainwar_df",
		value = 0,
		dlc = "gage_pack_historical"
	}
	self.textures.dazzle = {
		name_id = "bm_txt_dazzle",
		pcs = {},
		texture = "units/pd2_dlc_gage_historical/patterns/pattern_dazzle_df",
		value = 0,
		dlc = "gage_pack_historical"
	}
	self.textures.deathdealer = {
		name_id = "bm_txt_deathdealer",
		pcs = {},
		texture = "units/pd2_dlc_gage_historical/patterns/pattern_deathdealer_df",
		value = 0,
		dlc = "gage_pack_historical"
	}
	self.textures.filthythirteen = {
		name_id = "bm_txt_filthythirteen",
		pcs = {},
		texture = "units/pd2_dlc_gage_historical/patterns/pattern_filthythirteen_df",
		value = 0,
		dlc = "gage_pack_historical"
	}
	self.textures.hawkhelm = {
		name_id = "bm_txt_hawkhelm",
		pcs = {},
		texture = "units/pd2_indiana/patterns/pattern_hawkhelm_df",
		value = 0,
		dlc = "hope_diamond"
	}
	self.textures.hieroglyphs = {
		name_id = "bm_txt_hieroglyphs",
		pcs = {},
		texture = "units/pd2_indiana/patterns/pattern_hieroglyphs_df",
		value = 0,
		dlc = "hope_diamond"
	}
	self.textures.horus = {
		name_id = "bm_txt_horus",
		pcs = {},
		texture = "units/pd2_indiana/patterns/pattern_horus_df",
		value = 0,
		dlc = "hope_diamond"
	}
	self.textures.runes = {
		name_id = "bm_txt_runes",
		pcs = {},
		texture = "units/pd2_indiana/patterns/pattern_runes_df",
		value = 0,
		dlc = "hope_diamond"
	}
	self.textures.cro_pattern_1 = {
		name_id = "bm_txt_caduceus",
		pcs = {},
		texture = "units/pd2_dlc_cro/masks/patterns/caduceus",
		value = 0,
		dlc = "the_bomb",
		texture_bundle_folder = "the_bomb"
	}
	self.textures.cro_pattern_2 = {
		name_id = "bm_txt_checkerboard",
		pcs = {},
		texture = "units/pd2_dlc_cro/masks/patterns/checkerboard",
		value = 0,
		dlc = "the_bomb",
		texture_bundle_folder = "the_bomb"
	}
	self.textures.cro_pattern_3 = {
		name_id = "bm_txt_liongamelion",
		pcs = {},
		texture = "units/pd2_dlc_cro/masks/patterns/liongamelion",
		value = 0,
		dlc = "the_bomb",
		texture_bundle_folder = "the_bomb"
	}
	self.textures.cro_pattern_4 = {
		name_id = "bm_txt_pleter",
		pcs = {},
		texture = "units/pd2_dlc_cro/masks/patterns/pleter",
		value = 0,
		dlc = "the_bomb",
		texture_bundle_folder = "the_bomb"
	}
	self.textures.dinoskull = {
		name_id = "bm_txt_dinoskull",
		pcs = {},
		texture = "units/pd2_dlc_akm4_modpack/patterns/pattern_dinoskull_df",
		value = 0,
		texture_bundle_folder = "dlc_akm4",
		dlc = "akm4_pack"
	}
	self.textures.dinostripes = {
		name_id = "bm_txt_dinostripes",
		pcs = {},
		texture = "units/pd2_dlc_akm4_modpack/patterns/pattern_dinostripes_df",
		value = 0,
		texture_bundle_folder = "dlc_akm4",
		dlc = "akm4_pack"
	}
	self.textures.predator = {
		name_id = "bm_txt_predator",
		pcs = {},
		texture = "units/pd2_dlc_akm4_modpack/patterns/pattern_predator_df",
		value = 0,
		texture_bundle_folder = "dlc_akm4",
		dlc = "akm4_pack"
	}
	self.textures.dinoscars = {
		name_id = "bm_txt_dinoscars",
		pcs = {},
		texture = "units/pd2_dlc_akm4_modpack/patterns/pattern_scars_df",
		value = 0,
		texture_bundle_folder = "dlc_akm4",
		dlc = "akm4_pack"
	}
	self.textures.fireborn = {
		name_id = "bm_txt_fireborn",
		pcs = {},
		texture = "units/pd2_dlc_bbq/masks/patterns/pattern_fireborn_df",
		value = 0,
		dlc = "bbq",
		texture_bundle_folder = "bbq"
	}
	self.textures.flamer = {
		name_id = "bm_txt_flamer",
		pcs = {},
		texture = "units/pd2_dlc_bbq/masks/patterns/pattern_flamer_df",
		value = 0,
		dlc = "bbq",
		texture_bundle_folder = "bbq"
	}
	self.textures.flammable = {
		name_id = "bm_txt_flammable",
		pcs = {},
		texture = "units/pd2_dlc_bbq/masks/patterns/pattern_flammable_df",
		value = 0,
		dlc = "bbq",
		texture_bundle_folder = "bbq"
	}
	self.textures.hotflames = {
		name_id = "bm_txt_hotflames",
		pcs = {},
		texture = "units/pd2_dlc_bbq/masks/patterns/pattern_hotflames_df",
		value = 0,
		dlc = "bbq",
		texture_bundle_folder = "bbq"
	}
	self.textures.coyote = {
		name_id = "bm_txt_coyote",
		pcs = {},
		texture = "units/pd2_dlc_west/masks/patterns/pattern_coyote_df",
		dlc = "west",
		value = 0
	}
	self.textures.native = {
		name_id = "bm_txt_native",
		pcs = {},
		texture = "units/pd2_dlc_west/masks/patterns/pattern_native_df",
		dlc = "west",
		value = 0
	}
	self.textures.pattern = {
		name_id = "bm_txt_pattern",
		pcs = {},
		texture = "units/pd2_dlc_west/masks/patterns/pattern_pattern_df",
		dlc = "west",
		value = 0
	}
	self.textures.totem = {
		name_id = "bm_txt_totem",
		pcs = {},
		texture = "units/pd2_dlc_west/masks/patterns/pattern_totem_df",
		dlc = "west",
		value = 0
	}
	self.textures.soundwave = {
		name_id = "bm_txt_soundwave",
		pcs = {},
		texture = "units/pd2_dlc_arena/masks/patterns/pattern_soundwave_df",
		dlc = "arena",
		value = 0
	}
	self.textures.circle_raster = {
		name_id = "bm_txt_circle_raster",
		pcs = {},
		texture = "units/pd2_dlc_arena/masks/patterns/pattern_circle_raster_df",
		dlc = "arena",
		value = 0
	}
	self.textures.arena_logo = {
		name_id = "bm_txt_arena_logo",
		pcs = {},
		texture = "units/pd2_dlc_arena/masks/patterns/pattern_arena_logo_df",
		dlc = "arena",
		value = 0
	}
	self.textures.smoke = {
		name_id = "bm_txt_smoke",
		pcs = {},
		texture = "units/pd2_dlc_arena/masks/patterns/pattern_smoke_df",
		dlc = "arena",
		value = 0
	}
	self.textures.dices = {
		name_id = "bm_txt_dices",
		pcs = {},
		texture = "units/pd2_dlc_casino/masks/patterns/pattern_dices_df",
		value = 0,
		dlc = "kenaz",
		texture_bundle_folder = "kenaz"
	}
	self.textures.royale = {
		name_id = "bm_txt_royale",
		pcs = {},
		texture = "units/pd2_dlc_casino/masks/patterns/pattern_royale_df",
		value = 0,
		dlc = "kenaz",
		texture_bundle_folder = "kenaz"
	}
	self.textures.cards = {
		name_id = "bm_txt_cards",
		pcs = {},
		texture = "units/pd2_dlc_casino/masks/patterns/pattern_cards_df",
		value = 0,
		dlc = "kenaz",
		texture_bundle_folder = "kenaz"
	}
	self.textures.chips = {
		name_id = "bm_txt_chips",
		pcs = {},
		texture = "units/pd2_dlc_casino/masks/patterns/pattern_chips_df",
		value = 0,
		dlc = "kenaz",
		texture_bundle_folder = "kenaz"
	}
	self.textures.starvr = {
		name_id = "bm_txt_starvr",
		pcs = {},
		texture = "units/pd2_dlc_humble_summer15/masks/patterns/pattern_starvr_df",
		value = 0,
		infamous = true
	}
	self.textures.youkai = {
		name_id = "bm_txt_youkai",
		pcs = {},
		texture = "units/pd2_dlc_turtles/masks/patterns/pattern_youkai_df",
		value = 0,
		dlc = "turtles",
		texture_bundle_folder = "turtles"
	}
	self.textures.origami = {
		name_id = "bm_txt_origami",
		pcs = {},
		texture = "units/pd2_dlc_turtles/masks/patterns/pattern_origami_df",
		value = 0,
		dlc = "turtles",
		texture_bundle_folder = "turtles"
	}
	self.textures.oni = {
		name_id = "bm_txt_oni",
		pcs = {},
		texture = "units/pd2_dlc_turtles/masks/patterns/pattern_oni_df",
		value = 0,
		dlc = "turtles",
		texture_bundle_folder = "turtles"
	}
	self.textures.koi = {
		name_id = "bm_txt_koi",
		pcs = {},
		texture = "units/pd2_dlc_turtles/masks/patterns/pattern_koi_df",
		value = 0,
		dlc = "turtles",
		texture_bundle_folder = "turtles"
	}
	self.textures.agatha = {
		name_id = "bm_txt_agatha",
		pcs = {},
		texture = "units/pd2_dlc_steel/masks/patterns/pattern_agatha_df",
		value = 0,
		dlc = "steel"
	}
	self.textures.checkered_out = {
		name_id = "bm_txt_checkered_out",
		pcs = {},
		texture = "units/pd2_dlc_steel/masks/patterns/pattern_checkered_out_df",
		value = 0,
		dlc = "steel"
	}
	self.textures.mason = {
		name_id = "bm_txt_mason",
		pcs = {},
		texture = "units/pd2_dlc_steel/masks/patterns/pattern_mason_df",
		value = 0,
		dlc = "steel"
	}
	self.textures.med_pat = {
		name_id = "bm_txt_med_pat",
		pcs = {},
		texture = "units/pd2_dlc_steel/masks/patterns/pattern_med_patt_df",
		value = 0,
		dlc = "steel"
	}
	self.textures.sunavatar = {
		name_id = "bm_txt_sunavatar",
		pcs = {},
		texture = "units/pd2_dlc_jerry/masks/patterns/pattern_sunavatar_df",
		dlc = "berry",
		value = 0
	}
	self.textures.tribalface = {
		name_id = "bm_txt_tribalface",
		pcs = {},
		texture = "units/pd2_dlc_jerry/masks/patterns/pattern_tribalface_df",
		dlc = "berry",
		value = 0
	}
	self.textures.tribalwave = {
		name_id = "bm_txt_tribalwave",
		pcs = {},
		texture = "units/pd2_dlc_jerry/masks/patterns/pattern_tribalwave_df",
		dlc = "berry",
		value = 0
	}
	self.textures.ornamentalcrown = {
		name_id = "bm_txt_ornamentalcrown",
		pcs = {},
		texture = "units/pd2_dlc_jerry/masks/patterns/pattern_ornamentalcrown_df",
		dlc = "berry",
		value = 0
	}
	self.textures.giraffe = {
		name_id = "bm_txt_giraffe",
		pcs = {},
		texture = "units/pd2_dlc_peta/masks/patterns/pattern_giraffe_df",
		value = 0,
		dlc = "peta"
	}
	self.textures.illumigoati = {
		name_id = "bm_txt_illumigoati",
		pcs = {},
		texture = "units/pd2_dlc_peta/masks/patterns/pattern_illumigoati_df",
		value = 0,
		dlc = "peta"
	}
	self.textures.goatface = {
		name_id = "bm_txt_goatface",
		pcs = {},
		texture = "units/pd2_dlc_peta/masks/patterns/pattern_goatface_df",
		value = 0,
		dlc = "peta"
	}
	self.textures.fur = {
		name_id = "bm_txt_fur",
		pcs = {},
		texture = "units/pd2_dlc_peta/masks/patterns/pattern_fur_df",
		value = 0,
		dlc = "peta"
	}
	self.textures.fenris = {
		name_id = "bm_txt_fenris",
		pcs = {},
		texture = "units/pd2_dlc_lupus/patterns/pattern_fenris_df",
		value = 0,
		dlc = "pal"
	}
	self.textures.kurbits = {
		name_id = "bm_txt_kurbits",
		pcs = {},
		texture = "units/pd2_dlc_lupus/patterns/pattern_kurbits_df",
		value = 0,
		dlc = "pal"
	}
	self.textures.split = {
		name_id = "bm_txt_split",
		pcs = {},
		texture = "units/pd2_dlc_lupus/patterns/pattern_split_df",
		value = 0,
		dlc = "pal"
	}
	self.textures.luse = {
		name_id = "bm_txt_luse",
		pcs = {},
		texture = "units/pd2_dlc_lupus/patterns/pattern_luse_df",
		value = 0,
		dlc = "pal"
	}
	self.textures.jimmy_phoenix = {
		name_id = "bm_txt_jimmy_phoenix",
		pcs = {},
		texture = "units/pd2_dlc_mad/masks/patterns/pattern_jimmy_phoenix_df",
		value = 0
	}
	self.textures.hexagons = {
		name_id = "bm_txt_hexagons",
		pcs = {},
		texture = "units/pd2_dlc_mad/masks/patterns/pattern_hexagons_df",
		value = 0
	}
	self.textures.squares = {
		name_id = "bm_txt_squares",
		pcs = {},
		texture = "units/pd2_dlc_mad/masks/patterns/pattern_squares_df",
		value = 0
	}
	self.textures.rebel = {
		name_id = "bm_txt_rebel",
		pcs = {},
		texture = "units/pd2_dlc_mad/masks/patterns/pattern_rebel_df",
		value = 0
	}
	self.textures.biker_face = {
		name_id = "bm_txt_biker_face",
		pcs = {},
		texture = "units/pd2_dlc_born/masks/patterns/pattern_bikerface_df",
		value = 0,
		dlc = "born"
	}
	self.textures.skull_engine = {
		name_id = "bm_txt_skull_engine",
		pcs = {},
		texture = "units/pd2_dlc_born/masks/patterns/pattern_skullengine_df",
		value = 0,
		dlc = "born"
	}
	self.textures.skull_wing = {
		name_id = "bm_txt_skull_wing",
		pcs = {},
		texture = "units/pd2_dlc_born/masks/patterns/pattern_skullwings_df",
		value = 0,
		dlc = "born"
	}
	self.textures.tire_fire = {
		name_id = "bm_txt_tire_fire",
		pcs = {},
		texture = "units/pd2_dlc_born/masks/patterns/pattern_tirefire_df",
		value = 0,
		dlc = "born"
	}
	self.textures.oneshot = {
		name_id = "bm_txt_oneshot",
		pcs = {},
		texture = "units/pd2_dlc_pim/masks/patterns/pattern_oneshot_df",
		value = 0,
		dlc = "pim"
	}
	self.textures.daisy = {
		name_id = "bm_txt_daisy",
		pcs = {},
		texture = "units/pd2_dlc_pim/masks/patterns/pattern_daisy_df",
		value = 0,
		dlc = "pim"
	}
	self.textures.warface = {
		name_id = "bm_txt_warface",
		pcs = {},
		texture = "units/pd2_dlc_pim/masks/patterns/pattern_warface_df",
		value = 0,
		dlc = "pim"
	}
	self.textures.piety = {
		name_id = "bm_txt_piety",
		pcs = {},
		texture = "units/pd2_dlc_pim/masks/patterns/pattern_piety_df",
		value = 0,
		dlc = "pim"
	}
	self.textures.facepaint = {
		name_id = "bm_txt_facepaint",
		pcs = {},
		texture = "units/pd2_dlc_tng/masks/patterns/pattern_facepaint_df",
		value = 0,
		dlc = "tango"
	}
	self.textures.stripes = {
		name_id = "bm_txt_eye_stripes",
		pcs = {},
		texture = "units/pd2_dlc_tng/masks/patterns/pattern_stripes_df",
		value = 0,
		dlc = "tango"
	}
	self.textures.sight = {
		name_id = "bm_txt_sight",
		pcs = {},
		texture = "units/pd2_dlc_tng/masks/patterns/pattern_sight_df",
		value = 0,
		dlc = "tango"
	}
	self.textures.bullets = {
		name_id = "bm_txt_bullets",
		pcs = {},
		texture = "units/pd2_dlc_tng/masks/patterns/pattern_bullets_df",
		value = 0,
		dlc = "tango"
	}
	self.textures.liberty_flame = {
		name_id = "bm_txt_liberty_flame",
		pcs = {},
		texture = "units/pd2_dlc_friend/masks/patterns/pattern_liberty_flame_df",
		value = 0,
		dlc = "friend"
	}
	self.textures.diablada = {
		name_id = "bm_txt_diablada",
		pcs = {},
		texture = "units/pd2_dlc_friend/masks/patterns/pattern_diablada_df",
		value = 0,
		dlc = "friend"
	}
	self.textures.scar_mask = {
		name_id = "bm_txt_scar_mask",
		pcs = {},
		texture = "units/pd2_dlc_friend/masks/patterns/pattern_scar_mask_df",
		value = 0,
		dlc = "friend"
	}
	self.textures.my_little = {
		name_id = "bm_txt_pattern_my_little_df",
		pcs = {},
		texture = "units/pd2_dlc_friend/masks/patterns/pattern_my_little_df",
		value = 0,
		dlc = "friend"
	}
	self.textures.continental = {
		name_id = "bm_txt_continental",
		pcs = {},
		texture = "units/pd2_dlc_spa/masks/patterns/pattern_continental_df",
		value = 0,
		dlc = "spa"
	}
	self.textures.hotel_pattern = {
		name_id = "bm_txt_hotel_pattern",
		pcs = {},
		texture = "units/pd2_dlc_spa/masks/patterns/pattern_hotel_pattern_df",
		value = 0,
		dlc = "spa"
	}
	self.textures.baba_yaga = {
		name_id = "bm_txt_baba_yaga",
		pcs = {},
		texture = "units/pd2_dlc_spa/masks/patterns/pattern_baba_yaga_df",
		value = 0,
		dlc = "spa"
	}
	self.textures.hood_stripes = {
		name_id = "bm_txt_hood_stripes",
		pcs = {},
		texture = "units/pd2_dlc_spa/masks/patterns/pattern_hood_stripes_df",
		value = 0,
		dlc = "spa"
	}
	self.textures.red_star = {
		name_id = "bm_txt_red_star",
		pcs = {},
		texture = "units/pd2_dlc_grv/masks/patterns/pattern_red_star_df",
		value = 0,
		dlc = "grv"
	}
	self.textures.bear_fight = {
		name_id = "bm_txt_bear_fight",
		pcs = {},
		texture = "units/pd2_dlc_grv/masks/patterns/pattern_bear_fight_df",
		value = 0,
		dlc = "grv"
	}
	self.textures.prison_statement = {
		name_id = "bm_txt_prison_statement",
		pcs = {},
		texture = "units/pd2_dlc_grv/masks/patterns/pattern_prison_statement_df",
		value = 0,
		dlc = "grv"
	}
	self.textures.russian_gamble = {
		name_id = "bm_txt_russian_gamble",
		pcs = {},
		texture = "units/pd2_dlc_grv/masks/patterns/pattern_russian_gamble_df",
		value = 0,
		dlc = "grv"
	}
	self.textures.hands_batman = {
		name_id = "bm_txt_hands_batman",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_hands_batman_df",
		value = 0
	}
	self.textures.hands_ok = {
		name_id = "bm_txt_hands_ok",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_hands_ok_df",
		value = 0
	}
	self.textures.hands_peace = {
		name_id = "bm_txt_hands_peace",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_hands_peace_df",
		value = 0
	}
	self.textures.hands_loser = {
		name_id = "bm_txt_hands_loser",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_hands_loser_df",
		value = 0
	}
	self.textures.hands_shutup = {
		name_id = "bm_txt_hands_shutup",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_hands_shutup_df",
		value = 0
	}
	self.textures.hands_pans = {
		name_id = "bm_txt_hands_pans",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_hands_pans_df",
		value = 0
	}
	self.textures.clowns_qc = {
		name_id = "bm_txt_clowns_qc",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_clowns_qc_df",
		value = 0
	}
	self.textures.clowns_ahe = {
		name_id = "bm_txt_clowns_ahe",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_clowns_ahe_df",
		value = 0
	}
	self.textures.clowns_hoc = {
		name_id = "bm_txt_clowns_hoc",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_clowns_hoc_df",
		value = 0
	}
	self.textures.clowns_in = {
		name_id = "bm_txt_clowns_in",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_clowns_in_df",
		value = 0
	}
	self.textures.clowns_it = {
		name_id = "bm_txt_clowns_it",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_clowns_it_df",
		value = 0
	}
	self.textures.barf = {
		name_id = "bm_txt_barf",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_barf_df",
		value = 0
	}
	self.textures.basketball = {
		name_id = "bm_txt_basketball",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_basketball_df",
		value = 0
	}
	self.textures.crashdummy = {
		name_id = "bm_txt_crashdummy",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_crashdummy_df",
		value = 0
	}
	self.textures.friedegg = {
		name_id = "bm_txt_friedegg",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_friedegg_df",
		value = 0
	}
	self.textures.phantom = {
		name_id = "bm_txt_phantom",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_phantom_df",
		value = 0
	}
	self.textures.facepaint_cupcake = {
		name_id = "bm_txt_facepaint_cupcake",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_facepaint_cupcake_df",
		value = 0
	}
	self.textures.facepaint_flowers = {
		name_id = "bm_txt_facepaint_flowers",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_facepaint_flowers_df",
		value = 0
	}
	self.textures.facepaint_football = {
		name_id = "bm_txt_facepaint_football",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_facepaint_football_df",
		value = 0
	}
	self.textures.facepaint_rainbow = {
		name_id = "bm_txt_facepaint_rainbow",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_facepaint_rainbow_df",
		value = 0
	}
	self.textures.facepaint_skull = {
		name_id = "bm_txt_facepaint_skull",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_facepaint_skull_df",
		value = 0
	}
	self.textures.heraldry_ord_fess = {
		name_id = "bm_txt_heraldry_ord_fess",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_heraldry_ord_fess_df",
		value = 0
	}
	self.textures.heraldry_ord_pale = {
		name_id = "bm_txt_heraldry_ord_pale",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_heraldry_ord_pale_df",
		value = 0
	}
	self.textures.heraldry_ord_pall = {
		name_id = "bm_txt_heraldry_ord_pall",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_heraldry_ord_pall_df",
		value = 0
	}
	self.textures.heraldry_ord_saltire = {
		name_id = "bm_txt_heraldry_ord_saltire",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_heraldry_ord_saltire_df",
		value = 0
	}
	self.textures.heraldry_ord_cross = {
		name_id = "bm_txt_heraldry_ord_cross",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_heraldry_ord_cross_df",
		value = 0
	}
	self.textures.heraldry_ord_chevron = {
		name_id = "bm_txt_heraldry_ord_chevron",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_heraldry_ord_chevron_df",
		value = 0
	}
	self.textures.heraldry_ord_bend = {
		name_id = "bm_txt_heraldry_ord_bend",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_heraldry_ord_bend_df",
		value = 0
	}
	self.textures.heraldry_div_tiercedpall = {
		name_id = "bm_txt_heraldry_div_tiercedpall",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_heraldry_div_tiercedpall_df",
		value = 0
	}
	self.textures.heraldry_div_quarterly = {
		name_id = "bm_txt_heraldry_div_quarterly",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_heraldry_div_quarterly_df",
		value = 0
	}
	self.textures.heraldry_div_persaltire = {
		name_id = "bm_txt_heraldry_div_persaltire",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_heraldry_div_persaltire_df",
		value = 0
	}
	self.textures.heraldry_div_perpale = {
		name_id = "bm_txt_heraldry_div_perpale",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_heraldry_div_perpale_df",
		value = 0
	}
	self.textures.heraldry_div_perfess = {
		name_id = "bm_txt_heraldry_div_perfess",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_heraldry_div_perfess_df",
		value = 0
	}
	self.textures.heraldry_div_perchevron = {
		name_id = "bm_txt_heraldry_div_perchevron",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_heraldry_div_perchevron_df",
		value = 0
	}
	self.textures.heraldry_div_perbend = {
		name_id = "bm_txt_heraldry_div_perbend",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_heraldry_div_perbend_df",
		value = 0
	}
	self.textures.heraldry_geo_paly = {
		name_id = "bm_txt_heraldry_geo_paly",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_heraldry_geo_paly_df",
		value = 0
	}
	self.textures.heraldry_geo_lozengy = {
		name_id = "bm_txt_heraldry_geo_lozengy",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_heraldry_geo_lozengy_df",
		value = 0
	}
	self.textures.heraldry_geo_gyronny = {
		name_id = "bm_txt_heraldry_geo_gyronny",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_heraldry_geo_gyronny_df",
		value = 0
	}
	self.textures.heraldry_geo_fusil = {
		name_id = "bm_txt_heraldry_geo_fusil",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_heraldry_geo_fusil_df",
		value = 0
	}
	self.textures.heraldry_geo_checky = {
		name_id = "bm_txt_heraldry_geo_checky",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_heraldry_geo_checky_df",
		value = 0
	}
	self.textures.heraldry_geo_bendy = {
		name_id = "bm_txt_heraldry_geo_bendy",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_heraldry_geo_bendy_df",
		value = 0
	}
	self.textures.heraldry_geo_barrypale = {
		name_id = "bm_txt_heraldry_geo_barrypale",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_heraldry_geo_barrypale_df",
		value = 0
	}
	self.textures.heraldry_geo_barry = {
		name_id = "bm_txt_heraldry_geo_barry",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_heraldry_geo_barry_df",
		value = 0
	}
	self.textures.warpaint_freedom = {
		name_id = "bm_txt_warpaint_freedom",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_warpaint_freedom_df",
		value = 0
	}
	self.textures.warpaint_half_hawk = {
		name_id = "bm_txt_warpaint_half_hawk",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_warpaint_half_hawk_df",
		value = 0
	}
	self.textures.warpaint_crow_beak = {
		name_id = "bm_txt_warpaint_crow_beak",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_warpaint_crow_beak_df",
		value = 0
	}
	self.textures.warpaint_cross_marking = {
		name_id = "bm_txt_pattern_warpaint_cross_marking",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_warpaint_cross_marking_df",
		value = 0
	}
	self.textures.warpaint_darkness_eyes = {
		name_id = "bm_txt_pattern_warpaint_darkness_eyes",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_warpaint_darkness_eyes_df",
		value = 0
	}
	self.textures.pizzaface = {
		name_id = "bm_txt_pattern_pizzaface",
		pcs = {},
		texture = "units/pd2_dlc_pmp/masks/patterns/pattern_pizzaface_df",
		value = 0
	}
	self.textures.predator_billy = {
		name_id = "bm_txt_predator_billy",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_predator_billy_df",
		value = 0
	}
	self.textures.predator_blain = {
		name_id = "bm_txt_predator_blain",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_predator_blain_df",
		value = 0
	}
	self.textures.predator_dillan = {
		name_id = "bm_txt_predator_dillan",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_predator_dillan_df",
		value = 0
	}
	self.textures.predator_dutch = {
		name_id = "bm_txt_predator_dutch",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_predator_dutch_df",
		value = 0
	}
	self.textures.predator_hawkins = {
		name_id = "bm_txt_predator_hawkins",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_predator_hawkins_df",
		value = 0
	}
	self.textures.predator_mac = {
		name_id = "bm_txt_predator_mac",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_predator_mac_df",
		value = 0
	}
	self.textures.predator_poncho = {
		name_id = "bm_txt_predator_poncho",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_predator_poncho_df",
		value = 0
	}
	self.textures.ransom_1mdollars = {
		name_id = "bm_txt_ransom_1mdollars",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_ransom_1mdollars_df",
		value = 0
	}
	self.textures.ransom_bangbang = {
		name_id = "bm_txt_ransom_bangbang",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_ransom_bangbang_df",
		value = 0
	}
	self.textures.ransom_cashking = {
		name_id = "bm_txt_ransom_cashking",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_ransom_cashking_df",
		value = 0
	}
	self.textures.ransom_diepig = {
		name_id = "bm_txt_ransom_diepig",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_ransom_diepig_df",
		value = 0
	}
	self.textures.ransom_gameover = {
		name_id = "bm_txt_ransom_gameover",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_ransom_gameover_df",
		value = 0
	}
	self.textures.ransom_pledge = {
		name_id = "bm_txt_ransom_pledge",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_ransom_pledge_df",
		value = 0
	}
	self.textures.shades_3d = {
		name_id = "bm_txt_shades_3d",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_shades_3d_df",
		value = 0
	}
	self.textures.shades_80s = {
		name_id = "bm_txt_shades_80s",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_shades_80s_df",
		value = 0
	}
	self.textures.shades_band = {
		name_id = "bm_txt_shades_band",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_shades_band_df",
		value = 0
	}
	self.textures.shades_punk = {
		name_id = "bm_txt_shades_punk",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_shades_punk_df",
		value = 0
	}
	self.textures.shades_shutter = {
		name_id = "bm_txt_shades_shutter",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_shades_shutter_df",
		value = 0
	}
	self.textures.shades_sport = {
		name_id = "bm_txt_shades_sport",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_shades_sport_df",
		value = 0
	}
	self.textures.wavewarning = {
		name_id = "bm_txt_wavewarning",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_wavewarning_df",
		value = 0
	}
	self.textures.barbedwire = {
		name_id = "bm_txt_barbedwire",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_barbedwire_df",
		value = 0
	}
	self.textures.bloodhand = {
		name_id = "bm_txt_bloodhand",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_bloodhand_df",
		value = 0
	}
	self.textures.catface = {
		name_id = "bm_txt_catface",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_catface_df",
		value = 0
	}
	self.textures.clutter = {
		name_id = "bm_txt_clutter",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_clutter_df",
		value = 0
	}
	self.textures.facecollage = {
		name_id = "bm_txt_facecollage",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_facecollage_df",
		value = 0
	}
	self.textures.facename = {
		name_id = "bm_txt_facename",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_facename_df",
		value = 0
	}
	self.textures.frankenstein = {
		name_id = "bm_txt_frankenstein",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_frankenstein_df",
		value = 0
	}
	self.textures.hostage = {
		name_id = "bm_txt_hostage",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_hostage_df",
		value = 0
	}
	self.textures.knife = {
		name_id = "bm_txt_knife",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_knife_df",
		value = 0
	}
	self.textures.lovehate = {
		name_id = "bm_txt_lovehate",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_lovehate_df",
		value = 0
	}
	self.textures.skullshape = {
		name_id = "bm_txt_skullshape",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_skullshape_df",
		value = 0
	}
	self.textures.splat = {
		name_id = "bm_txt_splat",
		pcs = {
			10,
			20,
			30,
			40
		},
		texture = "units/pd2_dlc_skm/masks/patterns/pattern_splat_df",
		value = 0
	}
	local free_dlcs = tweak_data:free_dlc_list()

	for _, data in pairs(self.textures) do
		if free_dlcs[data.dlc] then
			data.dlc = nil
		end
	end
end
