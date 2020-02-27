DLCTweakData = DLCTweakData or class()

require("lib/tweak_data/GeneratedDLCTweakData")

function DLCTweakData:init(tweak_data)
	if managers.dlc:is_installing() then
		tweak_data.BUNDLED_DLC_PACKAGES = {}
	else
		tweak_data.BUNDLED_DLC_PACKAGES = {
			cmo = true,
			washington_reveal = true,
			fir = true,
			dlc_pack_overkill = true,
			mom = true,
			dsg = true,
			grv = true,
			fez1 = true,
			gage_pack_shotgun = true,
			gage_pack_historical = true,
			super = 1,
			chill = 1,
			west = true,
			fish = true,
			coco = true,
			max = true,
			dlc_akm4 = 1,
			peta = true,
			yor = 1,
			sparkle = 1,
			wild = true,
			howl = 1,
			rip = true,
			ztm = true,
			lxy = true,
			gage_pack_lmg = true,
			dos = true,
			cmt = true,
			paydaycon2016 = 1,
			dnm = true,
			wwh = true,
			mdm = 1,
			pic = true,
			myh = true,
			fdm = true,
			hoxton_revenge = 1,
			ecp = true,
			hl_miami = true,
			the_bomb = true,
			pn2 = true,
			tam = true,
			sft = true,
			pim = true,
			cash = true,
			sdb = true,
			bbq = true,
			ram = true,
			jigg = 1,
			season_pass = true,
			gage_pack_snp = true,
			dlc1 = true,
			ghm = true,
			ssm = true,
			steel = true,
			pd2_million = true,
			hlm2 = true,
			mmh = true,
			fgl = true,
			pd2_hw_boxing = true,
			speedrunners = 1,
			infamous = 1,
			pines = true,
			alienware_alpha = true,
			born = true,
			humble_summer_2015 = 1,
			khp = true,
			trk = true,
			pmp = true,
			apa = true,
			wmp = true,
			opera = true,
			pd2_goty = 1,
			joy = true,
			mrm = 1,
			big_bank = true,
			character_pack_dragan = true,
			spa = true,
			kenaz = true,
			osa = true,
			dlc_arena = true,
			dragon = true,
			gage_pack = true,
			swm = 1,
			tng = true,
			pal = true,
			favorite = true,
			ktm = true,
			mad = true,
			turtles = true,
			gage_pack_jobs = false,
			butcher_pack_mods = true,
			ggac = true,
			gcm = true,
			character_pack_bonnie = true,
			animal = true,
			gage_pack_assault = true,
			character_pack_sokol = true,
			pbm = true,
			sha = true,
			character_pack_clover = true,
			twitch_pack = 1
		}
	end

	self:init_generated()

	self.starvr_free = {
		free = true,
		content = {}
	}
	self.starvr_free.content.loot_global_value = "infamous"
	self.starvr_free.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "starvr",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "starvr",
			amount = 1
		}
	}
	self.starter_kit = {
		free = true,
		content = {}
	}
	self.starter_kit.content.loot_global_value = "normal"
	self.starter_kit.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ns_pis_medium",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_m4_uupg_m_std",
			amount = 1
		}
	}
	self.starter_kit.content.upgrades = {
		"fists",
		"molotov",
		"frag",
		"dynamite"
	}
	local all_normal_masks = {
		"alienware",
		"babyrhino",
		"mr_sinister",
		"day_of_the_dead",
		"irondoom",
		"greek_tragedy",
		"hockey",
		"kawaii",
		"demonictender",
		"monkeybiss",
		"rubber_male",
		"scarecrow",
		"tounge",
		"rubber_female",
		"oni",
		"biglips",
		"brainiack",
		"bullet",
		"outlandish_a",
		"clowncry",
		"dripper",
		"gagball",
		"hog",
		"demon",
		"jaw",
		"mummy",
		"outlandish_b",
		"outlandish_c",
		"stonekisses",
		"buha",
		"shogun",
		"shrunken",
		"clown_56",
		"troll",
		"dawn_of_the_dead",
		"vampire",
		"zipper",
		"zombie"
	}
	local lootdrops = {}

	for i, mask_id in ipairs(all_normal_masks) do
		table.insert(lootdrops, {
			type_items = "masks",
			amount = 1,
			item_entry = mask_id
		})
	end

	self.starter_kit_mask = {
		free = true,
		content = {}
	}
	self.starter_kit_mask.content.loot_global_value = "normal"
	self.starter_kit_mask.content.loot_drops = {
		lootdrops
	}
	self.pd2_clan = {
		content = {}
	}
	self.pd2_clan.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "bear",
			amount = 1
		}
	}
	self.pd2_clan2 = {
		content = {},
		dlc = "has_pd2_clan"
	}
	self.pd2_clan2.content.loot_global_value = "pd2_clan"
	self.pd2_clan2.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_fl_pis_tlr1",
			amount = 1
		}
	}
	self.pd2_clan2.content.upgrades = {
		"usp"
	}
	self.pd2_clan3 = {
		content = {},
		dlc = "has_pd2_clan"
	}
	self.pd2_clan3.content.loot_global_value = "pd2_clan"
	self.pd2_clan3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "heat",
			amount = 1
		}
	}
	self.pd2_clan4 = {
		content = {},
		dlc = "has_pd2_clan"
	}
	self.pd2_clan4.content.loot_global_value = "pd2_clan"
	self.pd2_clan4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "santa_happy",
			amount = 1
		}
	}
	self.pd2_clan5 = {
		content = {},
		dlc = "has_pd2_clan"
	}
	self.pd2_clan5.content.loot_global_value = "pd2_clan"
	self.pd2_clan5.content.loot_drops = {}
	self.pd2_clan5.content.upgrades = {
		"brass_knuckles"
	}
	self.pd2_clan6 = {
		content = {},
		dlc = "has_pd2_clan"
	}
	self.pd2_clan6.content.loot_global_value = "pd2_clan"
	self.pd2_clan6.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "unicorn",
			amount = 1
		}
	}
	self.raidww2_clan_bundle = {
		content = {},
		dlc = "has_raidww2_clan"
	}
	self.raidww2_clan_bundle.content.loot_drops = {}
	self.pd2_clan_crimefest_oct19 = {
		content = {},
		dlc = "has_pd2_clan"
	}
	self.pd2_clan_crimefest_oct19.content.loot_global_value = "pd2_clan"
	self.pd2_clan_crimefest_oct19.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "combusto",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "spackle",
			amount = 1
		}
	}
	self.pd2_clan_johnwick = {
		content = {},
		dlc = "has_pd2_clan"
	}
	self.pd2_clan_johnwick.content.loot_global_value = "pd2_clan"
	self.pd2_clan_johnwick.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_g26_b_custom",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_g26_body_custom",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_g26_m_contour",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_g26_g_gripforce",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_fl_pis_crimson",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ns_pis_ipsccomp",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ns_pis_medium_gem",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "stoneface",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "wayfarer",
			amount = 1
		}
	}
	self.pd2_clan_johnwick.content.upgrades = {
		"kabartanto"
	}
	self.pd2_clan_crimefest_oct23 = {
		content = {},
		dlc = "has_pd2_clan"
	}
	self.pd2_clan_crimefest_oct23.content.loot_global_value = "pd2_clan"
	self.pd2_clan_crimefest_oct23.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "smiley",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "gumbo",
			amount = 1
		}
	}
	self.pd2_clan_lgl = {
		content = {},
		dlc = "has_pd2_clan"
	}
	self.pd2_clan_lgl.content.loot_global_value = "pd2_clan"
	self.pd2_clan_lgl.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "crazy_lion",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_sho_s_spas12_folded",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_sho_s_spas12_nostock",
			amount = 1
		}
	}
	self.pd2_clan_lgl.content.upgrades = {
		"spas12"
	}
	self.pd2_clan_hoxton = {
		content = {},
		dlc = "has_pd2_clan"
	}
	self.pd2_clan_hoxton.content.loot_global_value = "pd2_clan"
	self.pd2_clan_hoxton.content.loot_drops = {}
	self.ach_bulldog_1 = {
		dlc = "has_achievement",
		achievement_id = "bulldog_1",
		content = {}
	}
	self.ach_bulldog_1.content.loot_global_value = "infamous"
	self.ach_bulldog_1.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "old_hoxton",
			amount = 1
		}
	}
	self.freed_old_hoxton = {
		dlc = "has_freed_old_hoxton",
		achievement_id = "bulldog_1",
		content = {}
	}
	self.freed_old_hoxton.content.loot_global_value = "pd2_clan"
	self.freed_old_hoxton.content.loot_drops = {}
	self.freed_old_hoxton.content.upgrades = {
		"toothbrush"
	}
	self.crimefest2_u2 = {
		content = {},
		free = true
	}
	self.crimefest2_u2.content.loot_global_value = "normal"
	self.crimefest2_u2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "rus_hat",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "sputnik",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "tiara",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "baba_yaga",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "vlad_armor",
			amount = 1
		}
	}
	self.crimefest2_par = {
		content = {},
		free = true
	}
	self.crimefest2_par.content.loot_global_value = "normal"
	self.crimefest2_par.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_bp_lmg_lionbipod",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_lmg_par_b_short",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_lmg_par_s_plastic",
			amount = 1
		}
	}
	self.crimefest2_rave = {
		content = {},
		free = true
	}
	self.crimefest2_rave.content.loot_global_value = "normal"
	self.crimefest2_rave.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "lcv",
			amount = 1
		}
	}
	self.crimefest2_u8 = {
		content = {},
		free = true
	}
	self.crimefest2_u8.content.loot_global_value = "normal"
	self.crimefest2_u8.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "pirate_skull",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "fatboy",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "oliver",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "eggian",
			amount = 1
		}
	}
	self.crimefest2_u9 = {
		content = {},
		free = true
	}
	self.crimefest2_u9.content.loot_global_value = "normal"
	self.crimefest2_u9.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "groucho_glasses",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "glasses_tinted_love",
			amount = 1
		}
	}
	self.ach_brooklyn_1 = {
		dlc = "has_achievement",
		achievement_id = "brooklyn_1",
		content = {}
	}
	self.ach_brooklyn_1.content.loot_global_value = "normal"
	self.ach_brooklyn_1.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "baitface",
			amount = 1
		}
	}
	self.ach_brooklyn_2 = {
		dlc = "has_achievement",
		achievement_id = "brooklyn_2",
		content = {}
	}
	self.ach_brooklyn_2.content.loot_global_value = "normal"
	self.ach_brooklyn_2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "nomegusta",
			amount = 1
		}
	}
	self.ach_brooklyn_3 = {
		dlc = "has_achievement",
		achievement_id = "brooklyn_3",
		content = {}
	}
	self.ach_brooklyn_3.content.loot_global_value = "normal"
	self.ach_brooklyn_3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "rageface",
			amount = 1
		}
	}
	self.ach_brooklyn_4 = {
		dlc = "has_achievement",
		achievement_id = "brooklyn_4",
		content = {}
	}
	self.ach_brooklyn_4.content.loot_global_value = "normal"
	self.ach_brooklyn_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "dawg",
			amount = 1
		}
	}
	self.pd2_clan_bonnie = {
		content = {},
		dlc = "has_pd2_clan"
	}
	self.pd2_clan_bonnie.content.loot_global_value = "infamous"
	self.pd2_clan_bonnie.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "bonnie",
			amount = 1
		}
	}
	self.preorder = {
		content = {},
		content_on_consoles = true
	}
	self.preorder.content.loot_drops = {
		{
			type_items = "colors",
			item_entry = "red_black",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "fan",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "skull",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_o_aimpoint_2",
			amount = 1
		},
		{
			type_items = "cash",
			item_entry = "cash_preorder",
			amount = 1
		}
	}
	self.preorder.content.upgrades = {
		"player_crime_net_deal"
	}

	if SystemInfo:platform() == Idstring("PS4") then
		table.insert(self.preorder.content.loot_drops, {
			type_items = "masks",
			item_entry = "finger",
			amount = 1
		})
	elseif SystemInfo:platform() == Idstring("XB1") then
		table.insert(self.preorder.content.loot_drops, {
			type_items = "masks",
			item_entry = "instinct",
			amount = 1
		})
	end

	self.cce = {
		content = {}
	}
	self.cce.content.loot_drops = {}
	self.cce.content.upgrades = {
		"player_crime_net_deal_2"
	}
	self.soundtrack = {
		content = {}
	}
	self.soundtrack.content.loot_drops = {}
	self.poetry_soundtrack = {
		dlc = "has_soundtrack_or_cce",
		content = {}
	}
	self.poetry_soundtrack.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "metalhead",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "tcn",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "surprise",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "optimist_prime",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "blackmetal",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "carbongrid",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "cosmoline",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "electronic",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "deathcube",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "tcn",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "tribalstroke",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "kraken",
			amount = 1
		}
	}
	self.ach_lab_1 = {
		dlc = "has_achievement",
		achievement_id = "lab_1",
		content = {}
	}
	self.ach_lab_1.content.loot_global_value = "halloween"
	self.ach_lab_1.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "invader",
			amount = 1
		}
	}
	self.ach_lab_2 = {
		dlc = "has_achievement",
		achievement_id = "lab_2",
		content = {}
	}
	self.ach_lab_2.content.loot_global_value = "halloween"
	self.ach_lab_2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "satan",
			amount = 1
		}
	}
	self.free_halloween_textures = {
		free = true,
		content = {}
	}
	self.free_halloween_textures.content.loot_global_value = "halloween"
	self.free_halloween_textures.content.loot_drops = {
		{
			type_items = "textures",
			item_entry = "pumpgrin",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "shout",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "webbed",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "hannibalistic",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "stitches",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "doomweaver",
			amount = 1
		}
	}
	self.halloween_nightmare_1 = {
		dlc = "has_achievement",
		achievement_id = "halloween_nightmare_1",
		content = {}
	}
	self.halloween_nightmare_1.content.loot_global_value = "halloween"
	self.halloween_nightmare_1.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "baby_happy",
			amount = 1
		}
	}
	self.halloween_nightmare_2 = {
		dlc = "has_achievement",
		achievement_id = "halloween_nightmare_2",
		content = {}
	}
	self.halloween_nightmare_2.content.loot_global_value = "halloween"
	self.halloween_nightmare_2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "brazil_baby",
			amount = 1
		}
	}
	self.halloween_nightmare_3 = {
		dlc = "has_achievement",
		achievement_id = "halloween_nightmare_3",
		content = {}
	}
	self.halloween_nightmare_3.content.loot_global_value = "halloween"
	self.halloween_nightmare_3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "baby_angry",
			amount = 1
		}
	}
	self.halloween_nightmare_4 = {
		dlc = "has_achievement",
		achievement_id = "halloween_nightmare_4",
		content = {}
	}
	self.halloween_nightmare_4.content.loot_global_value = "halloween"
	self.halloween_nightmare_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "baby_cry",
			amount = 1
		}
	}
	self.armored_transport = {
		content = {}
	}
	self.armored_transport.content.loot_drops = {
		{
			{
				type_items = "masks",
				item_entry = "clinton",
				amount = 1
			},
			{
				type_items = "masks",
				item_entry = "bush",
				amount = 1
			},
			{
				type_items = "masks",
				item_entry = "obama",
				amount = 1
			},
			{
				type_items = "masks",
				item_entry = "nixon",
				amount = 1
			}
		},
		{
			{
				type_items = "materials",
				item_entry = "cash",
				amount = 1
			},
			{
				type_items = "materials",
				item_entry = "jade",
				amount = 1
			},
			{
				type_items = "materials",
				item_entry = "redwhiteblue",
				amount = 1
			},
			{
				type_items = "materials",
				item_entry = "marble",
				amount = 1
			}
		},
		{
			{
				type_items = "textures",
				item_entry = "racestripes",
				amount = 1
			},
			{
				type_items = "textures",
				item_entry = "americaneagle",
				amount = 1
			},
			{
				type_items = "textures",
				item_entry = "stars",
				amount = 1
			},
			{
				type_items = "textures",
				item_entry = "forestcamo",
				amount = 1
			}
		}
	}
	self.armored_transport.content.upgrades = {
		"m45",
		"s552",
		"ppk"
	}
	self.armored_transport_intel = {
		dlc = "has_armored_transport_and_intel",
		achievement_id = "armored_2",
		content = {}
	}
	self.armored_transport_intel.content.loot_drops = {}
	self.gage_pack = {
		content = {}
	}
	self.gage_pack.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_i_singlefire",
			amount = 5
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_i_autofire",
			amount = 5
		},
		{
			{
				type_items = "masks",
				item_entry = "goat",
				amount = 1
			},
			{
				type_items = "masks",
				item_entry = "panda",
				amount = 1
			},
			{
				type_items = "masks",
				item_entry = "pitbull",
				amount = 1
			},
			{
				type_items = "masks",
				item_entry = "eagle",
				amount = 1
			}
		},
		{
			{
				type_items = "materials",
				item_entry = "fur",
				amount = 1
			},
			{
				type_items = "materials",
				item_entry = "galvanized",
				amount = 1
			},
			{
				type_items = "materials",
				item_entry = "heavymetal",
				amount = 1
			},
			{
				type_items = "materials",
				item_entry = "oilmetal",
				amount = 1
			}
		},
		{
			{
				type_items = "textures",
				item_entry = "army",
				amount = 1
			},
			{
				type_items = "textures",
				item_entry = "commando",
				amount = 1
			},
			{
				type_items = "textures",
				item_entry = "hunter",
				amount = 1
			},
			{
				type_items = "textures",
				item_entry = "digitalcamo",
				amount = 1
			}
		}
	}
	self.gage_pack.content.upgrades = {
		"mp7",
		"scar",
		"p226"
	}

	if SystemInfo:distribution() == Idstring("STEAM") then
		self.gage_pack_shotgun_free = {
			free = true,
			content = {}
		}
		self.gage_pack_shotgun_free.content.loot_global_value = "normal"
		self.gage_pack_shotgun_free.content.loot_drops = {
			{
				type_items = "weapon_mods",
				item_entry = "wpn_fps_upg_a_custom_free",
				amount = 2
			}
		}
	end

	self.gage_pack_shotgun = {
		content = {}
	}
	self.gage_pack_shotgun.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_a_slug",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_a_custom",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_a_explosive",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_a_piercing",
			amount = 1
		}
	}
	self.ach_gage4_2 = {
		dlc = "has_achievement",
		achievement_id = "gage4_2",
		content = {}
	}
	self.ach_gage4_2.content.loot_global_value = "gage_pack_shotgun"
	self.ach_gage4_2.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_o_mbus_rear",
			amount = 1
		}
	}
	self.ach_gage4_4 = {
		dlc = "has_achievement",
		achievement_id = "gage4_4",
		content = {}
	}
	self.ach_gage4_4.content.loot_global_value = "gage_pack_shotgun"
	self.ach_gage4_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "mandril",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "explosive",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "terror",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_sho_ben_b_short",
			amount = 1
		}
	}
	self.ach_gage4_5 = {
		dlc = "has_achievement",
		achievement_id = "gage4_5",
		content = {}
	}
	self.ach_gage4_5.content.loot_global_value = "gage_pack_shotgun"
	self.ach_gage4_5.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_sho_ben_b_long",
			amount = 1
		}
	}
	self.ach_gage4_6 = {
		dlc = "has_achievement",
		achievement_id = "gage4_6",
		content = {}
	}
	self.ach_gage4_6.content.loot_global_value = "gage_pack_shotgun"
	self.ach_gage4_6.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_sho_ben_s_collapsed",
			amount = 1
		}
	}
	self.ach_gage4_7 = {
		dlc = "has_achievement",
		achievement_id = "gage4_7",
		content = {}
	}
	self.ach_gage4_7.content.loot_global_value = "gage_pack_shotgun"
	self.ach_gage4_7.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_sho_ksg_b_short",
			amount = 1
		}
	}
	self.ach_gage4_8 = {
		dlc = "has_achievement",
		achievement_id = "gage4_8",
		content = {}
	}
	self.ach_gage4_8.content.loot_global_value = "gage_pack_shotgun"
	self.ach_gage4_8.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "skullmonkey",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "leaf",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "monkeyskull",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_sho_ksg_b_long",
			amount = 1
		}
	}
	self.ach_gage4_9 = {
		dlc = "has_achievement",
		achievement_id = "gage4_9",
		content = {}
	}
	self.ach_gage4_9.content.loot_global_value = "gage_pack_shotgun"
	self.ach_gage4_9.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_sho_ben_s_solid",
			amount = 1
		}
	}
	self.ach_gage4_10 = {
		dlc = "has_achievement",
		achievement_id = "gage4_10",
		content = {}
	}
	self.ach_gage4_10.content.loot_global_value = "gage_pack_shotgun"
	self.ach_gage4_10.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "silverback",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "sparks",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "chief",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_sho_striker_b_long",
			amount = 1
		}
	}
	self.ach_gage4_11 = {
		dlc = "has_achievement",
		achievement_id = "gage4_11",
		content = {}
	}
	self.ach_gage4_11.content.loot_global_value = "gage_pack_shotgun"
	self.ach_gage4_11.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "orangutang",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "bananapeel",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "banana",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_sho_striker_b_suppressed",
			amount = 1
		}
	}
	self.gage_pack_assault = {
		content = {}
	}
	self.gage_pack_assault.content.loot_drops = {}
	self.ach_gage5_1 = {
		dlc = "has_achievement",
		achievement_id = "gage5_1",
		content = {}
	}
	self.ach_gage5_1.content.loot_global_value = "gage_pack_assault"
	self.ach_gage5_1.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "evil",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_g3_b_sniper",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_g3_fg_psg",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_g3_g_sniper",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_g3_s_sniper",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_galil_fg_sniper",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_galil_g_sniper",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_galil_s_sniper",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_famas_b_sniper",
			amount = 1
		}
	}
	self.ach_gage5_2 = {
		dlc = "has_achievement",
		achievement_id = "gage5_2",
		content = {}
	}
	self.ach_gage5_2.content.loot_global_value = "gage_pack_assault"
	self.ach_gage5_2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "crowgoblin",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_gre_m79_stock_short",
			amount = 1
		}
	}
	self.ach_gage5_3 = {
		dlc = "has_achievement",
		achievement_id = "gage5_3",
		content = {}
	}
	self.ach_gage5_3.content.loot_global_value = "gage_pack_assault"
	self.ach_gage5_3.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_galil_fg_mar",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_galil_s_plastic",
			amount = 1
		}
	}
	self.ach_gage5_4 = {
		dlc = "has_achievement",
		achievement_id = "gage5_4",
		content = {}
	}
	self.ach_gage5_4.content.loot_global_value = "gage_pack_assault"
	self.ach_gage5_4.content.loot_drops = {
		{
			type_items = "materials",
			item_entry = "evil",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "vicious",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_g3_b_short",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_g3_fg_retro_plastic",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_galil_s_light",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_famas_b_short",
			amount = 1
		}
	}
	self.ach_gage5_5 = {
		dlc = "has_achievement",
		achievement_id = "gage5_5",
		content = {}
	}
	self.ach_gage5_5.content.loot_global_value = "gage_pack_assault"
	self.ach_gage5_5.content.loot_drops = {
		{
			type_items = "materials",
			item_entry = "bone",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "muerte",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_gre_m79_barrel_short",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_galil_s_wood",
			amount = 1
		}
	}
	self.ach_gage5_6 = {
		dlc = "has_achievement",
		achievement_id = "gage5_6",
		content = {}
	}
	self.ach_gage5_6.content.loot_global_value = "gage_pack_assault"
	self.ach_gage5_6.content.loot_drops = {
		{
			type_items = "materials",
			item_entry = "void",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "death",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_famas_b_long",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_g3_fg_railed",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_galil_fg_sar",
			amount = 1
		}
	}
	self.ach_gage5_7 = {
		dlc = "has_achievement",
		achievement_id = "gage5_7",
		content = {}
	}
	self.ach_gage5_7.content.loot_global_value = "gage_pack_assault"
	self.ach_gage5_7.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_g3_fg_retro",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_g3_g_retro",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_g3_s_wood",
			amount = 1
		}
	}
	self.ach_gage5_8 = {
		dlc = "has_achievement",
		achievement_id = "gage5_8",
		content = {}
	}
	self.ach_gage5_8.content.loot_global_value = "gage_pack_assault"
	self.ach_gage5_8.content.loot_drops = {
		{
			type_items = "materials",
			item_entry = "frost",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "emperor",
			amount = 1
		}
	}
	self.ach_gage5_9 = {
		dlc = "has_achievement",
		achievement_id = "gage5_9",
		content = {}
	}
	self.ach_gage5_9.content.loot_global_value = "gage_pack_assault"
	self.ach_gage5_9.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "volt",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_galil_fg_fab",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_galil_s_fab",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_galil_s_skeletal",
			amount = 1
		}
	}
	self.ach_gage5_10 = {
		dlc = "has_achievement",
		achievement_id = "gage5_10",
		content = {}
	}
	self.ach_gage5_10.content.loot_global_value = "gage_pack_assault"
	self.ach_gage5_10.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "galax",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_famas_b_suppressed",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_famas_g_retro",
			amount = 1
		}
	}
	self.gage_pack_lmg = {
		content = {}
	}
	self.gage_pack_lmg.content.loot_drops = {
		{
			{
				type_items = "masks",
				item_entry = "cloth_commander",
				amount = 1
			},
			{
				type_items = "masks",
				item_entry = "gage_blade",
				amount = 1
			},
			{
				type_items = "masks",
				item_entry = "gage_rambo",
				amount = 1
			},
			{
				type_items = "masks",
				item_entry = "gage_deltaforce",
				amount = 1
			}
		},
		{
			{
				type_items = "materials",
				item_entry = "gunmetal",
				amount = 1
			},
			{
				type_items = "materials",
				item_entry = "mud",
				amount = 1
			},
			{
				type_items = "materials",
				item_entry = "splinter",
				amount = 1
			},
			{
				type_items = "materials",
				item_entry = "erdl",
				amount = 1
			}
		},
		{
			{
				type_items = "textures",
				item_entry = "styx",
				amount = 1
			},
			{
				type_items = "textures",
				item_entry = "fingerpaint",
				amount = 1
			},
			{
				type_items = "textures",
				item_entry = "fighter",
				amount = 1
			},
			{
				type_items = "textures",
				item_entry = "warrior",
				amount = 1
			}
		}
	}
	self.gage_pack_lmg.content.upgrades = {
		"rpk",
		"kabar"
	}
	self.gage_pack_snp = {
		content = {}
	}
	self.gage_pack_snp.content.loot_drops = {}
	self.gage_pack_snp.content.upgrades = {}
	self.ach_gage3_3 = {
		dlc = "has_achievement",
		achievement_id = "gage3_3",
		content = {}
	}
	self.ach_gage3_3.content.loot_global_value = "gage_pack_snp"
	self.ach_gage3_3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "robberfly",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "carapace",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "bugger",
			amount = 1
		}
	}
	self.ach_gage3_4 = {
		dlc = "has_achievement",
		achievement_id = "gage3_4",
		content = {}
	}
	self.ach_gage3_4.content.loot_global_value = "gage_pack_snp"
	self.ach_gage3_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "spider",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "insectoid",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "spidereyes",
			amount = 1
		}
	}
	self.ach_gage3_5 = {
		dlc = "has_achievement",
		achievement_id = "gage3_5",
		content = {}
	}
	self.ach_gage3_5.content.loot_global_value = "gage_pack_snp"
	self.ach_gage3_5.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "wasp",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "bugshell",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "venomous",
			amount = 1
		}
	}
	self.ach_gage3_6 = {
		dlc = "has_achievement",
		achievement_id = "gage3_6",
		content = {}
	}
	self.ach_gage3_6.content.loot_global_value = "gage_pack_snp"
	self.ach_gage3_6.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "mantis",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "hardshell",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "wingsofdeath",
			amount = 1
		}
	}
	self.ach_gage3_7 = {
		dlc = "has_achievement",
		achievement_id = "gage3_7",
		content = {}
	}
	self.ach_gage3_7.content.loot_global_value = "gage_pack_snp"
	self.ach_gage3_7.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_m95_barrel_long",
			amount = 1
		}
	}
	self.ach_gage3_8 = {
		dlc = "has_achievement",
		achievement_id = "gage3_8",
		content = {}
	}
	self.ach_gage3_8.content.loot_global_value = "gage_pack_snp"
	self.ach_gage3_8.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_r93_b_suppressed",
			amount = 1
		}
	}
	self.ach_gage3_9 = {
		dlc = "has_achievement",
		achievement_id = "gage3_9",
		content = {}
	}
	self.ach_gage3_9.content.loot_global_value = "gage_pack_snp"
	self.ach_gage3_9.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_o_45iron",
			amount = 1
		}
	}
	self.ach_gage3_10 = {
		dlc = "has_achievement",
		achievement_id = "gage3_10",
		content = {}
	}
	self.ach_gage3_10.content.loot_global_value = "gage_pack_snp"
	self.ach_gage3_10.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_r93_b_short",
			amount = 1
		}
	}
	self.ach_gage3_11 = {
		dlc = "has_achievement",
		achievement_id = "gage3_11",
		content = {}
	}
	self.ach_gage3_11.content.loot_global_value = "gage_pack_snp"
	self.ach_gage3_11.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_m95_barrel_suppressed",
			amount = 1
		}
	}
	self.ach_gage3_12 = {
		dlc = "has_achievement",
		achievement_id = "gage3_12",
		content = {}
	}
	self.ach_gage3_12.content.loot_global_value = "gage_pack_snp"
	self.ach_gage3_12.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_m95_barrel_short",
			amount = 1
		}
	}
	self.ach_gage3_13 = {
		dlc = "has_achievement",
		achievement_id = "gage3_13",
		content = {}
	}
	self.ach_gage3_13.content.loot_global_value = "gage_pack_snp"
	self.ach_gage3_13.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_o_leupold",
			amount = 1
		}
	}
	self.ach_gage3_14 = {
		dlc = "has_achievement",
		achievement_id = "gage3_14",
		content = {}
	}
	self.ach_gage3_14.content.loot_global_value = "gage_pack_snp"
	self.ach_gage3_14.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_msr_body_msr",
			amount = 1
		}
	}
	self.ach_gage3_15 = {
		dlc = "has_achievement",
		achievement_id = "gage3_15",
		content = {}
	}
	self.ach_gage3_15.content.loot_global_value = "gage_pack_snp"
	self.ach_gage3_15.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_r93_body_wood",
			amount = 1
		}
	}
	self.ach_gage3_16 = {
		dlc = "has_achievement",
		achievement_id = "gage3_16",
		content = {}
	}
	self.ach_gage3_16.content.loot_global_value = "gage_pack_snp"
	self.ach_gage3_16.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_msr_ns_suppressor",
			amount = 1
		}
	}
	self.ach_gage3_17 = {
		dlc = "has_achievement",
		achievement_id = "gage3_17",
		content = {}
	}
	self.ach_gage3_17.content.loot_global_value = "gage_pack_snp"
	self.ach_gage3_17.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_msr_b_long",
			amount = 1
		}
	}
	self.big_bank = {
		content = {}
	}
	self.big_bank.content.loot_drops = {}
	self.ach_bigbank_1 = {
		dlc = "has_achievement",
		achievement_id = "bigbank_1",
		content = {}
	}
	self.ach_bigbank_1.content.loot_global_value = "big_bank"
	self.ach_bigbank_1.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "franklin",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "parchment",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "roman",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_fal_g_01",
			amount = 1
		}
	}
	self.ach_bigbank_2 = {
		dlc = "has_achievement",
		achievement_id = "bigbank_2",
		content = {}
	}
	self.ach_bigbank_2.content.loot_global_value = "big_bank"
	self.ach_bigbank_2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "washington",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "old",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "ruler",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_fal_m_01",
			amount = 1
		}
	}
	self.ach_bigbank_3 = {
		dlc = "has_achievement",
		achievement_id = "bigbank_3",
		content = {}
	}
	self.ach_bigbank_3.content.loot_global_value = "big_bank"
	self.ach_bigbank_3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "lincoln",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "clay",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "spartan",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_fal_fg_04",
			amount = 1
		}
	}
	self.ach_bigbank_4 = {
		dlc = "has_achievement",
		achievement_id = "bigbank_4",
		content = {}
	}
	self.ach_bigbank_4.content.loot_global_value = "big_bank"
	self.ach_bigbank_4.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_fal_fg_wood",
			amount = 1
		}
	}
	self.ach_bigbank_5 = {
		dlc = "has_achievement",
		achievement_id = "bigbank_5",
		content = {}
	}
	self.ach_bigbank_5.content.loot_global_value = "big_bank"
	self.ach_bigbank_5.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_fal_s_01",
			amount = 1
		}
	}
	self.ach_bigbank_6 = {
		dlc = "has_achievement",
		achievement_id = "bigbank_6",
		content = {}
	}
	self.ach_bigbank_6.content.loot_global_value = "big_bank"
	self.ach_bigbank_6.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "grant",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "gemstone",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "wargod",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_fal_s_wood",
			amount = 1
		}
	}
	self.ach_bigbank_7 = {
		dlc = "has_achievement",
		achievement_id = "bigbank_7",
		content = {}
	}
	self.ach_bigbank_7.content.loot_global_value = "big_bank"
	self.ach_bigbank_7.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_fal_fg_01",
			amount = 1
		}
	}
	self.ach_bigbank_8 = {
		dlc = "has_achievement",
		achievement_id = "bigbank_8",
		content = {}
	}
	self.ach_bigbank_8.content.loot_global_value = "big_bank"
	self.ach_bigbank_8.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_fal_fg_03",
			amount = 1
		}
	}
	self.ach_bigbank_10 = {
		dlc = "has_achievement",
		achievement_id = "bigbank_10",
		content = {}
	}
	self.ach_bigbank_10.content.loot_global_value = "big_bank"
	self.ach_bigbank_10.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_fal_s_03",
			amount = 1
		}
	}
	self.skull_mask_1 = {
		dlc = "has_achievement",
		achievement_id = "death_27",
		content = {}
	}
	self.skull_mask_1.content.loot_global_value = "infamous"
	self.skull_mask_1.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "skullhard",
			amount = 1
		}
	}
	self.skull_mask_2 = {
		dlc = "has_achievement",
		achievement_id = "death_28",
		content = {}
	}
	self.skull_mask_2.content.loot_global_value = "infamous"
	self.skull_mask_2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "skullveryhard",
			amount = 1
		}
	}
	self.skull_mask_3 = {
		dlc = "has_achievement",
		achievement_id = "death_29",
		content = {}
	}
	self.skull_mask_3.content.loot_global_value = "infamous"
	self.skull_mask_3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "skulloverkill",
			amount = 1
		}
	}
	self.skull_mask_31 = {
		dlc = "has_achievement",
		achievement_id = "pick_66",
		content = {}
	}
	self.skull_mask_31.content.loot_global_value = "infamous"
	self.skull_mask_31.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "gitgud_e_wish",
			amount = 1
		}
	}
	self.skull_mask_4 = {
		dlc = "has_achievement",
		achievement_id = "death_30",
		content = {}
	}
	self.skull_mask_4.content.loot_global_value = "infamous"
	self.skull_mask_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "skulloverkillplus",
			amount = 1
		}
	}
	self.skull_mask_41 = {
		dlc = "has_achievement",
		achievement_id = "axe_66",
		content = {}
	}
	self.skull_mask_41.content.loot_global_value = "infamous"
	self.skull_mask_41.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "gitgud_sm_wish",
			amount = 1
		}
	}
	self.charliesierra = {
		content = {},
		free = true
	}
	self.charliesierra.content.loot_global_value = "normal"
	self.charliesierra.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_o_acog",
			amount = 1
		}
	}
	self.xmas_soundtrack = {
		content = {}
	}
	self.xmas_soundtrack.content.loot_drops = {
		{
			{
				type_items = "masks",
				item_entry = "santa_mad",
				amount = 1
			},
			{
				type_items = "masks",
				item_entry = "santa_drunk",
				amount = 1
			},
			{
				type_items = "masks",
				item_entry = "santa_surprise",
				amount = 1
			}
		}
	}
	self.gage_pack_jobs = {}
	self.gage_pack_jobs = {
		content = {}
	}
	self.gage_pack_jobs.content.loot_drops = {}
	self.kosugi_4 = {
		dlc = "has_achievement",
		achievement_id = "kosugi_4",
		content = {}
	}
	self.kosugi_4.content.loot_global_value = "infamous"
	self.kosugi_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "samurai",
			amount = 1
		}
	}
	self.twitch_pack = {
		content = {}
	}
	self.twitch_pack.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "twitch_orc",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "ancient",
			amount = 1
		}
	}
	self.twitch_pack2 = {
		content = {},
		dlc = "has_twitch_pack"
	}
	self.twitch_pack2.content.loot_global_value = "twitch_pack"
	self.twitch_pack2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "twitch_orc",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "ancient",
			amount = 1
		}
	}
	self.humble_pack2 = {
		content = {}
	}
	self.humble_pack2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "the_one_below",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "lycan",
			amount = 1
		}
	}
	self.humble_pack3 = {
		content = {}
	}
	self.humble_pack3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "titan",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "pokachu",
			amount = 1
		}
	}
	self.humble_pack4 = {
		content = {}
	}
	self.humble_pack4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "moon",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "borsuk",
			amount = 1
		}
	}
	self.e3_s15a = {
		content = {}
	}
	self.e3_s15a.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "card_jack",
			amount = 1
		}
	}
	self.e3_s15b = {
		content = {}
	}
	self.e3_s15b.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "card_queen",
			amount = 1
		}
	}
	self.e3_s15c = {
		content = {}
	}
	self.e3_s15c.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "card_king",
			amount = 1
		}
	}
	self.e3_s15d = {
		content = {}
	}
	self.e3_s15d.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "card_joker",
			amount = 1
		}
	}
	self.sweettooth = {
		content = {}
	}
	self.sweettooth.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "sweettooth",
			amount = 1
		}
	}
	self.hl_miami = {
		content = {}
	}
	self.hl_miami.content.loot_drops = {}
	self.hlm_game = {
		content = {}
	}
	self.hlm_game.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "rooster",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "tiger",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "panther",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "horse",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "neon",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "hatred",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "cushion",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "rug",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "uglyrug",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "hotline",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "leopard",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "shutupandbleed",
			amount = 1
		}
	}
	self.hlm_game.content.upgrades = {
		"briefcase"
	}
	self.ach_miami_2 = {
		dlc = "has_achievement",
		achievement_id = "pig_2",
		content = {}
	}
	self.ach_miami_2.content.loot_global_value = "hl_miami"
	self.ach_miami_2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "owl",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "chromescape",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "palmtrees",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_uzi_fg_rail",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_uzi_s_leather",
			amount = 1
		}
	}
	self.ach_miami_3 = {
		dlc = "has_achievement",
		achievement_id = "pig_3",
		content = {}
	}
	self.ach_miami_3.content.loot_global_value = "hl_miami"
	self.ach_miami_3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "white_wolf",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "rubber",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "hiptobepolygon",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_uzi_s_solid",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_scorpion_g_wood",
			amount = 1
		}
	}
	self.ach_miami_4 = {
		dlc = "has_achievement",
		achievement_id = "pig_4",
		content = {}
	}
	self.ach_miami_4.content.loot_global_value = "hl_miami"
	self.ach_miami_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "rabbit",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "error",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "bsomebody",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_tec9_ns_ext",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_tec9_m_extended",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_tec9_s_unfolded",
			amount = 1
		}
	}
	self.ach_miami_5 = {
		dlc = "has_achievement",
		achievement_id = "pig_5",
		content = {}
	}
	self.ach_miami_5.content.loot_global_value = "hl_miami"
	self.ach_miami_5.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_uzi_b_suppressed",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_uzi_s_standard",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_scorpion_b_suppressed",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_scorpion_s_nostock",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_tec9_b_standard",
			amount = 1
		}
	}
	self.ach_miami_7 = {
		dlc = "has_achievement",
		achievement_id = "pig_7",
		content = {}
	}
	self.ach_miami_7.content.loot_global_value = "hl_miami"
	self.ach_miami_7.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "pig",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "sunset",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "doodles",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_scorpion_g_ergo",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_scorpion_m_extended",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_scorpion_s_unfolded",
			amount = 1
		}
	}
	self.ach_eagle_1 = {
		dlc = "has_achievement",
		achievement_id = "eagle_1",
		content = {}
	}
	self.ach_eagle_1.content.loot_global_value = "gage_pack_historical"
	self.ach_eagle_1.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "de_gaulle",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "gunsmoke",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "dazzle",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_mosin_b_sniper",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_mosin_b_standard",
			amount = 1
		}
	}
	self.ach_eagle_2 = {
		dlc = "has_achievement",
		achievement_id = "eagle_2",
		content = {}
	}
	self.ach_eagle_2.content.loot_global_value = "gage_pack_historical"
	self.ach_eagle_2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "red_hurricane",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "redsun",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "deathdealer",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_sterling_b_e11",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_c96_nozzle",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_c96_sight",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_sterling_b_short",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_sterling_b_suppressed",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_sterling_m_short",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_sterling_s_folded",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_sterling_s_nostock",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_sterling_s_solid",
			amount = 1
		}
	}
	self.ach_eagle_3 = {
		dlc = "has_achievement",
		achievement_id = "eagle_3",
		content = {}
	}
	self.ach_eagle_3.content.loot_global_value = "gage_pack_historical"
	self.ach_eagle_3.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_mosin_body_black",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_c96_b_long",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_mosin_b_short",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_sterling_m_long",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_sterling_b_long",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_lmg_mg42_b_vg38",
			amount = 1
		}
	}
	self.ach_eagle_4 = {
		dlc = "has_achievement",
		achievement_id = "eagle_4",
		content = {}
	}
	self.ach_eagle_4.content.loot_global_value = "gage_pack_historical"
	self.ach_eagle_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "churchill",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "armygreen",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "filthythirteen",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_c96_m_extended",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_c96_s_solid",
			amount = 1
		}
	}
	self.ach_eagle_5 = {
		dlc = "has_achievement",
		achievement_id = "eagle_5",
		content = {}
	}
	self.ach_eagle_5.content.loot_global_value = "gage_pack_historical"
	self.ach_eagle_5.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "patton",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "patriot",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "captainwar",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_lmg_mg42_b_mg34",
			amount = 1
		}
	}
	self.gage_pack_historical = {
		content = {}
	}
	self.gage_pack_historical.content.loot_global_value = "gage_pack_historical"
	self.gage_pack_historical.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_mosin_ns_bayonet",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_mosin_iron_sight",
			amount = 1
		}
	}
	self.gage_pack_historical.content.upgrades = {
		"swagger"
	}

	if SystemInfo:distribution() == Idstring("STEAM") then
		self.alienware_alpha = {
			content = {}
		}
		self.alienware_alpha.content.loot_drops = {
			{
				type_items = "masks",
				item_entry = "area51",
				amount = 1
			},
			{
				type_items = "masks",
				item_entry = "alien_helmet",
				amount = 1
			}
		}
		self.alienware_alpha_promo = {
			content = {}
		}
		self.alienware_alpha_promo.content.loot_drops = {}
		self.alienware_alpha_promo.content.upgrades = {
			"alien_maul"
		}
	end

	self.goty_weapon_bundle_2014 = {
		dlc = "has_goty_weapon_bundle_2014",
		content = {}
	}
	self.goty_weapon_bundle_2014.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "robo_arnold",
			amount = 1
		}
	}
	self.goty_heist_bundle_2014 = {
		dlc = "has_goty_heist_bundle_2014",
		content = {}
	}
	self.goty_heist_bundle_2014.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "nun_town",
			amount = 1
		}
	}
	self.goty_dlc_bundle_2014 = {
		dlc = "has_goty_all_dlc_bundle_2014",
		content = {}
	}
	self.goty_dlc_bundle_2014.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "arch_nemesis",
			amount = 1
		}
	}
	self.ach_deer_1 = {
		dlc = "has_achievement",
		achievement_id = "deer_1",
		content = {}
	}
	self.ach_deer_1.content.loot_global_value = "normal"
	self.ach_deer_1.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "mrs_claus",
			amount = 1
		}
	}
	self.ach_deer_2 = {
		dlc = "has_achievement",
		achievement_id = "deer_2",
		content = {}
	}
	self.ach_deer_2.content.loot_global_value = "normal"
	self.ach_deer_2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "strinch",
			amount = 1
		}
	}
	self.ach_deer_3 = {
		dlc = "has_achievement",
		achievement_id = "deer_3",
		content = {}
	}
	self.ach_deer_3.content.loot_global_value = "normal"
	self.ach_deer_3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "krampus",
			amount = 1
		}
	}
	self.ach_deer_4 = {
		dlc = "has_achievement",
		achievement_id = "deer_4",
		content = {}
	}
	self.ach_deer_4.content.loot_global_value = "normal"
	self.ach_deer_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "robo_santa",
			amount = 1
		}
	}
	self.ach_deer_6 = {
		dlc = "has_achievement",
		achievement_id = "deer_6",
		content = {}
	}
	self.ach_deer_6.content.loot_global_value = "normal"
	self.ach_deer_6.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "almirs_beard",
			amount = 1
		}
	}
	self.character_pack_clover = {
		content = {}
	}
	self.character_pack_clover.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "msk_grizel",
			amount = 1
		},
		{
			{
				type_items = "weapon_mods",
				item_entry = "wpn_fps_ass_l85a2_m_emag",
				amount = 1
			},
			{
				type_items = "weapon_mods",
				item_entry = "wpn_fps_ass_l85a2_fg_short",
				amount = 1
			},
			{
				type_items = "weapon_mods",
				item_entry = "wpn_fps_ass_l85a2_g_worn",
				amount = 1
			},
			{
				type_items = "weapon_mods",
				item_entry = "wpn_fps_ass_l85a2_b_long",
				amount = 1
			},
			{
				type_items = "weapon_mods",
				item_entry = "wpn_fps_ass_l85a2_b_short",
				amount = 1
			}
		}
	}
	self.hope_diamond = {
		content = {}
	}
	self.hope_diamond.content.loot_drops = {}
	self.ach_bat_2 = {
		dlc = "has_achievement",
		achievement_id = "bat_2",
		content = {}
	}
	self.ach_bat_2.content.loot_global_value = "hope_diamond"
	self.ach_bat_2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "cursed_crown",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "sand",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "hieroglyphs",
			amount = 1
		}
	}
	self.ach_bat_3 = {
		dlc = "has_achievement",
		achievement_id = "bat_3",
		content = {}
	}
	self.ach_bat_3.content.loot_global_value = "hope_diamond"
	self.ach_bat_3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "medusa",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "rust",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "runes",
			amount = 1
		}
	}
	self.ach_bat_4 = {
		dlc = "has_achievement",
		achievement_id = "bat_4",
		content = {}
	}
	self.ach_bat_4.content.loot_global_value = "hope_diamond"
	self.ach_bat_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "pazuzu",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "diamond",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "horus",
			amount = 1
		}
	}
	self.ach_bat_6 = {
		dlc = "has_achievement",
		achievement_id = "bat_6",
		content = {}
	}
	self.ach_bat_6.content.loot_global_value = "hope_diamond"
	self.ach_bat_6.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "anubis",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "bandages",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "hawkhelm",
			amount = 1
		}
	}
	self.the_bomb = {
		content = {}
	}
	self.the_bomb.content.loot_drops = {}
	self.ach_cow_3 = {
		dlc = "has_achievement",
		achievement_id = "cow_3",
		content = {}
	}
	self.ach_cow_3.content.loot_global_value = "the_bomb"
	self.ach_cow_3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "butcher",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "meat",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "cro_pattern_4",
			amount = 1
		}
	}
	self.ach_cow_4 = {
		dlc = "has_achievement",
		achievement_id = "cow_4",
		content = {}
	}
	self.ach_cow_4.content.loot_global_value = "the_bomb"
	self.ach_cow_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "tech_lion",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "rock_marble",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "cro_pattern_3",
			amount = 1
		}
	}
	self.ach_cow_5 = {
		dlc = "has_achievement",
		achievement_id = "cow_5",
		content = {}
	}
	self.ach_cow_5.content.loot_global_value = "the_bomb"
	self.ach_cow_5.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "doctor",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "plywood",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "cro_pattern_1",
			amount = 1
		}
	}
	self.ach_cow_8 = {
		dlc = "has_achievement",
		achievement_id = "cow_8",
		content = {}
	}
	self.ach_cow_8.content.loot_global_value = "the_bomb"
	self.ach_cow_8.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "lady_butcher",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "rhino_skin",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "cro_pattern_2",
			amount = 1
		}
	}
	self.ach_cow_9 = {
		dlc = "has_achievement",
		achievement_id = "cow_9",
		content = {}
	}
	self.ach_cow_9.content.loot_global_value = "the_bomb"
	self.ach_cow_9.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_hs2000_m_extended",
			amount = 1
		}
	}
	self.ach_cow_10 = {
		dlc = "has_achievement",
		achievement_id = "cow_10",
		content = {}
	}
	self.ach_cow_10.content.loot_global_value = "the_bomb"
	self.ach_cow_10.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_hs2000_sl_long",
			amount = 1
		}
	}
	self.ach_cow_11 = {
		dlc = "has_achievement",
		achievement_id = "cow_11",
		content = {}
	}
	self.ach_cow_11.content.loot_global_value = "the_bomb"
	self.ach_cow_11.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_hs2000_sl_custom",
			amount = 1
		}
	}
	self.akm4_pack = {
		content = {}
	}
	self.akm4_pack.content.loot_drops = {}
	self.ach_ameno_1 = {
		dlc = "has_achievement",
		achievement_id = "ameno_1",
		content = {}
	}
	self.ach_ameno_1.content.loot_global_value = "akm4_pack"
	self.ach_ameno_1.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ass_m4_upper_reciever_core",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ass_m4_lower_reciever_core",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ass_m16_fg_stag",
			amount = 1
		}
	}
	self.ach_ameno_2 = {
		dlc = "has_achievement",
		achievement_id = "ameno_2",
		content = {}
	}
	self.ach_ameno_2.content.loot_global_value = "akm4_pack"
	self.ach_ameno_2.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ak_g_rk3",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ak_fg_zenit",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ass_m4_upper_reciever_ballos",
			amount = 1
		}
	}
	self.ach_ameno_3 = {
		dlc = "has_achievement",
		achievement_id = "ameno_3",
		content = {}
	}
	self.ach_ameno_3.content.loot_global_value = "akm4_pack"
	self.ach_ameno_3.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_o_ak_scopemount",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ns_ass_pbs1",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "carnotaurus",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "dawn",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "dinoskull",
			amount = 1
		}
	}
	self.ach_ameno_4 = {
		dlc = "has_achievement",
		achievement_id = "ameno_4",
		content = {}
	}
	self.ach_ameno_4.content.loot_global_value = "akm4_pack"
	self.ach_ameno_4.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ass_ak_b_zastava",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ak_m_uspalm",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "triceratops",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "prehistoric",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "dinostripes",
			amount = 1
		}
	}
	self.ach_ameno_5 = {
		dlc = "has_achievement",
		achievement_id = "ameno_5",
		content = {}
	}
	self.ach_ameno_5.content.loot_global_value = "akm4_pack"
	self.ach_ameno_5.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ass_m4_fg_moe",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_smg_olympic_fg_lr300",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ass_m4_fg_lvoa",
			amount = 1
		}
	}
	self.ach_ameno_6 = {
		dlc = "has_achievement",
		achievement_id = "ameno_6",
		content = {}
	}
	self.ach_ameno_6.content.loot_global_value = "akm4_pack"
	self.ach_ameno_6.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ak_s_solidstock",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_m4_s_ubr",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "pachy",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "fossil",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "predator",
			amount = 1
		}
	}
	self.ach_ameno_7 = {
		dlc = "has_achievement",
		achievement_id = "ameno_7",
		content = {}
	}
	self.ach_ameno_7.content.loot_global_value = "akm4_pack"
	self.ach_ameno_7.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ass_m4_b_beowulf",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_m4_m_l5",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "velociraptor",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "feathers",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "dinoscars",
			amount = 1
		}
	}
	self.ach_ameno_8 = {
		dlc = "has_achievement",
		achievement_id = "ameno_8",
		content = {}
	}
	self.ach_ameno_8.content.loot_global_value = "akm4_pack"
	self.ach_ameno_8.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ak_fg_trax",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ak_fg_krebs",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ak_b_ak105",
			amount = 1
		}
	}
	self.butch_pack_free = {
		free = true,
		content = {}
	}
	self.butch_pack_free.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_saw_body_silent",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_saw_body_speed",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_saw_m_blade_durable",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_saw_m_blade_sharp",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_aug_body_f90",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_ak5_b_short",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_mp5_m_straight",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_mp9_b_suppressed",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_p90_b_civilian",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_p90_b_ninja",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_o_m14_scopemount",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_1911_g_engraved",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_beretta_g_engraved",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_fl_ass_utg",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_fl_pis_m3x",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ass_ns_battle",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ns_ass_filter",
			amount = 5
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ns_pis_jungle",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ns_sho_salvo_large",
			amount = 1
		}
	}
	self.character_pack_dragan = {
		content = {}
	}
	self.character_pack_dragan.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "dragan",
			amount = 1
		}
	}
	self.ach_gorilla_1 = {
		dlc = "has_achievement",
		achievement_id = "gorilla_1",
		content = {}
	}
	self.ach_gorilla_1.content.loot_global_value = "normal"
	self.ach_gorilla_1.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "champion_dallas",
			amount = 1
		}
	}
	self.overkill_pack = {
		content = {}
	}
	self.overkill_pack.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "the_overkill_mask",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_lmg_m134_barrel_short",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_lmg_m134_barrel_extreme",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_lmg_m134_body_upper_light",
			amount = 1
		}
	}
	self.complete_overkill_pack = {
		content = {}
	}
	self.complete_overkill_pack.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "dallas_glow",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "wolf_glow",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "hoxton_glow",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "chains_glow",
			amount = 1
		}
	}
	self.complete_overkill_pack2 = {
		dlc = "has_parent_dlc",
		parent_dlc = "complete_overkill_pack",
		content = {}
	}
	self.complete_overkill_pack2.content.loot_global_value = "complete_overkill_pack"
	self.complete_overkill_pack2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "megacthulhu",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "hunter",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "cop_skull",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "cop_plague_doctor",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "cop_kawaii",
			amount = 1
		}
	}
	self.complete_overkill_pack3 = {
		dlc = "has_parent_dlc",
		parent_dlc = "complete_overkill_pack",
		content = {}
	}
	self.complete_overkill_pack3.content.loot_global_value = "complete_overkill_pack"
	self.complete_overkill_pack3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "fab_mega_grin",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "fab_mega_doctor",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "fab_mega_alien",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "cop_mega_gage_blade",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "fab_mega_mark",
			amount = 1
		}
	}
	self.hlm2 = {
		dlc = "has_hlm2",
		content = {}
	}
	self.hlm2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "jake",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "richter",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "biker",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "alex",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "corey",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "tonys_revenge",
			amount = 1
		}
	}
	self.hlm2_deluxe = {
		dlc = "has_hlm2_deluxe",
		content = {}
	}
	self.hlm2_deluxe.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "richard_returns",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_cobray_body_upper_jacket",
			amount = 1
		}
	}
	self.ach_fort_4 = {
		dlc = "has_achievement",
		achievement_id = "fort_4",
		content = {}
	}
	self.ach_fort_4.content.loot_global_value = "normal"
	self.ach_fort_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "simpson",
			amount = 1
		}
	}
	self.speedrunners = {
		content = {}
	}
	self.speedrunners.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "hothead",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "falcon",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "unic",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "speedrunner",
			amount = 1
		}
	}
	self.ach_payback_3 = {
		dlc = "has_achievement",
		achievement_id = "payback_3",
		content = {}
	}
	self.ach_payback_3.content.loot_global_value = "infamous"
	self.ach_payback_3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "hectors_helmet",
			amount = 1
		}
	}
	self.bbq = {
		content = {}
	}
	self.bbq.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_gre_m32_no_stock",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_gre_m32_barrel_short",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_sho_aa12_barrel_long",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_sho_aa12_barrel_silenced",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_sho_aa12_mag_drum",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_a_dragons_breath",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_a_grenade_launcher_incendiary",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_fla_mk2_mag_rare",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_fla_mk2_mag_welldone",
			amount = 1
		}
	}
	self.ach_bbq_1 = {
		dlc = "has_achievement",
		achievement_id = "grill_1",
		content = {}
	}
	self.ach_bbq_1.content.loot_global_value = "bbq"
	self.ach_bbq_1.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "firedemon",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "coal",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "fireborn",
			amount = 1
		}
	}
	self.ach_bbq_2 = {
		dlc = "has_achievement",
		achievement_id = "grill_2",
		content = {}
	}
	self.ach_bbq_2.content.loot_global_value = "bbq"
	self.ach_bbq_2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "gasmask",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "candlelight",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "flammable",
			amount = 1
		}
	}
	self.ach_bbq_3 = {
		dlc = "has_achievement",
		achievement_id = "grill_3",
		content = {}
	}
	self.ach_bbq_3.content.loot_global_value = "bbq"
	self.ach_bbq_3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "firemask",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "burn",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "flamer",
			amount = 1
		}
	}
	self.ach_bbq_4 = {
		dlc = "has_achievement",
		achievement_id = "grill_4",
		content = {}
	}
	self.ach_bbq_4.content.loot_global_value = "bbq"
	self.ach_bbq_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "chef_hat",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "toast",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "hotflames",
			amount = 1
		}
	}
	self.west = {
		content = {}
	}
	self.west.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_a_bow_explosion",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_winchester_o_classic",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_winchester_b_suppressed",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_winchester_b_long",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_peacemaker_s_skeletal",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_peacemaker_g_bling",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_peacemaker_b_short",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_peacemaker_b_long",
			amount = 1
		}
	}
	self.ach_west_1 = {
		dlc = "has_achievement",
		achievement_id = "scorpion_1",
		content = {}
	}
	self.ach_west_1.content.loot_global_value = "west"
	self.ach_west_1.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "bullskull",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "westernsunset",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "pattern",
			amount = 1
		}
	}
	self.ach_west_2 = {
		dlc = "has_achievement",
		achievement_id = "scorpion_2",
		content = {}
	}
	self.ach_west_2.content.loot_global_value = "west"
	self.ach_west_2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "bandit",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "cactus",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "coyote",
			amount = 1
		}
	}
	self.ach_west_3 = {
		dlc = "has_achievement",
		achievement_id = "scorpion_3",
		content = {}
	}
	self.ach_west_3.content.loot_global_value = "west"
	self.ach_west_3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "lone",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "scorpion",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "totem",
			amount = 1
		}
	}
	self.ach_west_4 = {
		dlc = "has_achievement",
		achievement_id = "scorpion_4",
		content = {}
	}
	self.ach_west_4.content.loot_global_value = "west"
	self.ach_west_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "kangee",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "goldfever",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "native",
			amount = 1
		}
	}
	self.ach_melt_3 = {
		dlc = "has_achievement",
		achievement_id = "melt_3",
		content = {}
	}
	self.ach_melt_3.content.loot_global_value = "infamous"
	self.ach_melt_3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "grendel",
			amount = 1
		}
	}
	self.arena = {
		content = {}
	}
	self.arena.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_2006m_b_long",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_2006m_b_medium",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_2006m_b_short",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_2006m_g_bling",
			amount = 1
		}
	}
	self.ach_arena_2 = {
		dlc = "has_achievement",
		achievement_id = "live_2",
		content = {}
	}
	self.ach_arena_2.content.loot_global_value = "arena"
	self.ach_arena_2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "boombox",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "enlightment",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "arena_logo",
			amount = 1
		}
	}
	self.ach_arena_3 = {
		dlc = "has_achievement",
		achievement_id = "live_3",
		content = {}
	}
	self.ach_arena_3.content.loot_global_value = "arena"
	self.ach_arena_3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "cantus",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "bionic",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "circle_raster",
			amount = 1
		}
	}
	self.ach_arena_4 = {
		dlc = "has_achievement",
		achievement_id = "live_4",
		content = {}
	}
	self.ach_arena_4.content.loot_global_value = "arena"
	self.ach_arena_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "concert_female",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "stained_glass",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "soundwave",
			amount = 1
		}
	}
	self.ach_arena_5 = {
		dlc = "has_achievement",
		achievement_id = "live_5",
		content = {}
	}
	self.ach_arena_5.content.loot_global_value = "arena"
	self.ach_arena_5.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "concert_male",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "dimblue",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "smoke",
			amount = 1
		}
	}
	self.character_pack_sokol = {
		content = {}
	}
	self.character_pack_sokol.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "sokol",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_asval_b_proto",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_asval_s_solid",
			amount = 1
		}
	}
	self.kenaz = {
		content = {}
	}
	self.kenaz.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_sub2000_fg_gen2",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_sub2000_fg_railed",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_sub2000_fg_suppressed",
			amount = 1
		}
	}
	self.ach_kenaz_2 = {
		dlc = "has_achievement",
		achievement_id = "kenaz_2",
		content = {}
	}
	self.ach_kenaz_2.content.loot_global_value = "kenaz"
	self.ach_kenaz_2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "croupier_hat",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "stars",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "chips",
			amount = 1
		}
	}
	self.ach_kenaz_3 = {
		dlc = "has_achievement",
		achievement_id = "kenaz_3",
		content = {}
	}
	self.ach_kenaz_3.content.loot_global_value = "kenaz"
	self.ach_kenaz_3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "gladiator_helmet",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "casino",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "royale",
			amount = 1
		}
	}
	self.ach_kenaz_4 = {
		dlc = "has_achievement",
		achievement_id = "kenaz_4",
		content = {}
	}
	self.ach_kenaz_4.content.loot_global_value = "kenaz"
	self.ach_kenaz_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "the_king_mask",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "plush",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "cards",
			amount = 1
		}
	}
	self.ach_kenaz_5 = {
		dlc = "has_achievement",
		achievement_id = "kenaz_5",
		content = {}
	}
	self.ach_kenaz_5.content.loot_global_value = "kenaz"
	self.ach_kenaz_5.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "sports_utility_mask",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "carpet",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "dices",
			amount = 1
		}
	}
	self.turtles = {
		content = {}
	}
	self.turtles.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_bow_hunter_b_carbon",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_bow_hunter_b_skeletal",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_bow_hunter_g_camo",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_bow_hunter_g_walnut",
			amount = 1
		}
	}
	self.turtles_mods_fix = {
		dlc = "has_turtles",
		content = {}
	}
	self.turtles_mods_fix.content.loot_global_value = "turtles"
	self.turtles_mods_fix.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_wa2000_b_long",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_wa2000_b_suppressed",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_wa2000_g_light",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_wa2000_g_stealth",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_wa2000_g_walnut",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_polymer_barrel_precision",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_polymer_ns_silencer",
			amount = 1
		}
	}
	self.turtles_free = {
		free = true,
		content = {}
	}
	self.turtles_free.content.loot_global_value = "normal"
	self.turtles_free.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_a_bow_poison",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_a_crossbow_poison",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_a_crossbow_explosion",
			amount = 1
		}
	}
	self.ach_turtles_1 = {
		dlc = "has_achievement",
		achievement_id = "turtles_1",
		content = {}
	}
	self.ach_turtles_1.content.loot_global_value = "turtles"
	self.ach_turtles_1.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "slicer",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "still_waters",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "youkai",
			amount = 1
		}
	}
	self.ach_turtles_2 = {
		dlc = "has_achievement",
		achievement_id = "turtles_2",
		content = {}
	}
	self.ach_turtles_2.content.loot_global_value = "turtles"
	self.ach_turtles_2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "kage",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "sakura",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "oni",
			amount = 1
		}
	}
	self.ach_turtles_3 = {
		dlc = "has_achievement",
		achievement_id = "turtles_3",
		content = {}
	}
	self.ach_turtles_3.content.loot_global_value = "turtles"
	self.ach_turtles_3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "ninja_hood",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "bamboo",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "koi",
			amount = 1
		}
	}
	self.ach_turtles_4 = {
		dlc = "has_achievement",
		achievement_id = "turtles_4",
		content = {}
	}
	self.ach_turtles_4.content.loot_global_value = "turtles"
	self.ach_turtles_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "shirai",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "origami",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "origami",
			amount = 1
		}
	}
	self.dragon = {
		content = {}
	}
	self.dragon.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_baka_b_comp",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_baka_b_longsupp",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_baka_b_midsupp",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_baka_b_smallsupp",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_baka_s_standard",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_baka_s_unfolded",
			amount = 1
		}
	}
	self.dragon_maskfix = {
		dlc = "has_dragon",
		content = {}
	}
	self.dragon_maskfix.content.loot_global_value = "dragon"
	self.dragon_maskfix.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "jiro",
			amount = 1
		}
	}
	self.steel_free = {
		free = true,
		content = {}
	}
	self.steel_free.content.loot_global_value = "normal"
	self.steel_free.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_bow_arblast_m_poison",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_bow_arblast_m_explosive",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_bow_frankish_m_poison",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_bow_frankish_m_explosive",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_bow_long_m_explosive",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_bow_long_m_poison",
			amount = 1
		}
	}
	self.ach_steel_1 = {
		dlc = "has_achievement",
		achievement_id = "steel_1",
		content = {}
	}
	self.ach_steel_1.content.loot_global_value = "steel"
	self.ach_steel_1.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "agatha_knight",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "blooded",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "agatha",
			amount = 1
		}
	}
	self.ach_steel_2 = {
		dlc = "has_achievement",
		achievement_id = "steel_2",
		content = {}
	}
	self.ach_steel_2.content.loot_global_value = "steel"
	self.ach_steel_2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "agatha_vanguard_veteran",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "chain_armor",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "med_pat",
			amount = 1
		}
	}
	self.ach_steel_3 = {
		dlc = "has_achievement",
		achievement_id = "steel_3",
		content = {}
	}
	self.ach_steel_3.content.loot_global_value = "steel"
	self.ach_steel_3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "mason_knight_veteran",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "scale_armor",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "mason",
			amount = 1
		}
	}
	self.ach_steel_4 = {
		dlc = "has_achievement",
		achievement_id = "steel_4",
		content = {}
	}
	self.ach_steel_4.content.loot_global_value = "steel"
	self.ach_steel_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "mason_vanguard_veteran",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "forged",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "checkered_out",
			amount = 1
		}
	}
	self.rip_free = {
		content = {},
		free = true
	}
	self.rip_free.content.loot_global_value = "infamous"
	self.rip_free.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "bodhi",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			global_value = "normal",
			item_entry = "wpn_fps_snp_model70_iron_sight",
			amount = 1
		}
	}
	self.ach_berry_2 = {
		dlc = "has_achievement",
		achievement_id = "berry_2",
		content = {}
	}
	self.ach_berry_2.content.loot_global_value = "berry"
	self.ach_berry_2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "water_spirit",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "flow",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "sunavatar",
			amount = 1
		}
	}
	self.ach_berry_5 = {
		dlc = "has_achievement",
		achievement_id = "berry_5",
		content = {}
	}
	self.ach_berry_5.content.loot_global_value = "berry"
	self.ach_berry_5.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "tane",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "sancti",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "tribalface",
			amount = 1
		}
	}
	self.ach_jerry_3 = {
		dlc = "has_achievement",
		achievement_id = "jerry_3",
		content = {}
	}
	self.ach_jerry_3.content.loot_global_value = "berry"
	self.ach_jerry_3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "oro",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "glade",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "tribalwave",
			amount = 1
		}
	}
	self.ach_jerry_4 = {
		dlc = "has_achievement",
		achievement_id = "jerry_4",
		content = {}
	}
	self.ach_jerry_4.content.loot_global_value = "berry"
	self.ach_jerry_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "maui",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "wade",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "ornamentalcrown",
			amount = 1
		}
	}
	self.tormentor_mask = {
		free = true,
		content = {}
	}
	self.tormentor_mask.content.loot_global_value = "normal"
	self.tormentor_mask.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "tormentor",
			amount = 1
		}
	}
	self.ach_cane_3 = {
		dlc = "has_achievement",
		achievement_id = "cane_3",
		content = {}
	}
	self.ach_cane_3.content.loot_global_value = "normal"
	self.ach_cane_3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "rudeolph",
			amount = 1
		}
	}
	self.ach_cane_4 = {
		dlc = "has_achievement",
		achievement_id = "cane_4",
		content = {}
	}
	self.ach_cane_4.content.loot_global_value = "normal"
	self.ach_cane_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "greedy_the_elf",
			amount = 1
		}
	}
	self.ach_peta_2 = {
		dlc = "has_achievement",
		achievement_id = "peta_2",
		content = {}
	}
	self.ach_peta_2.content.loot_global_value = "peta"
	self.ach_peta_2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "tall_goat",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "goateye",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "giraffe",
			amount = 1
		}
	}
	self.ach_peta_3 = {
		dlc = "has_achievement",
		achievement_id = "peta_3",
		content = {}
	}
	self.ach_peta_3.content.loot_global_value = "peta"
	self.ach_peta_3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "goat_goat",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "flamingoeye",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "illumigoati",
			amount = 1
		}
	}
	self.ach_peta_4 = {
		dlc = "has_achievement",
		achievement_id = "peta_4",
		content = {}
	}
	self.ach_peta_4.content.loot_global_value = "peta"
	self.ach_peta_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "wet_goat",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "hay",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "goatface",
			amount = 1
		}
	}
	self.ach_peta_5 = {
		dlc = "has_achievement",
		achievement_id = "peta_5",
		content = {}
	}
	self.ach_peta_5.content.loot_global_value = "peta"
	self.ach_peta_5.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "fancy_goat",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "tongue",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "fur",
			amount = 1
		}
	}
	self.ach_pal_2 = {
		dlc = "has_achievement",
		achievement_id = "pal_2",
		content = {}
	}
	self.ach_pal_2.content.loot_global_value = "pal"
	self.ach_pal_2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "horned_king",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "houndstooth",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "fenris",
			amount = 1
		}
	}
	self.ach_pal_3 = {
		dlc = "has_achievement",
		achievement_id = "pal_3",
		content = {}
	}
	self.ach_pal_3.content.loot_global_value = "pal"
	self.ach_pal_3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "viking",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "day",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "kurbits",
			amount = 1
		}
	}
	self.ach_man_3 = {
		dlc = "has_achievement",
		achievement_id = "man_3",
		content = {}
	}
	self.ach_man_3.content.loot_global_value = "pal"
	self.ach_man_3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "nutcracker",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "redwhite",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "luse",
			amount = 1
		}
	}
	self.ach_man_4 = {
		dlc = "has_achievement",
		achievement_id = "man_4",
		content = {}
	}
	self.ach_man_4.content.loot_global_value = "pal"
	self.ach_man_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "divided",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "mushroom_cloud",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "split",
			amount = 1
		}
	}
	self.coco = {
		content = {}
	}
	self.coco.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "jimmy_duct",
			amount = 1
		}
	}
	self.coco.free = true
	self.coco.content.loot_global_value = "infamous"
	self.mad = {
		content = {},
		free = true
	}
	self.mad.content.loot_drops = {
		{
			type_items = "weapon_mods",
			global_value = "normal",
			item_entry = "wpn_fps_pis_pl14_b_comp",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			global_value = "normal",
			item_entry = "wpn_fps_pis_pl14_m_extended",
			amount = 1
		}
	}
	self.ach_mad_2 = {
		dlc = "has_achievement",
		achievement_id = "mad_2",
		content = {}
	}
	self.ach_mad_2.content.loot_global_value = "normal"
	self.ach_mad_2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "mad_mask",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "nebula",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "hexagons",
			amount = 1
		}
	}
	self.ach_mad_3 = {
		dlc = "has_achievement",
		achievement_id = "mad_3",
		content = {}
	}
	self.ach_mad_3.content.loot_global_value = "normal"
	self.ach_mad_3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "visor",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "planet",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "jimmy_phoenix",
			amount = 1
		}
	}
	self.ach_dark_2 = {
		dlc = "has_achievement",
		achievement_id = "dark_2",
		content = {}
	}
	self.ach_dark_2.content.loot_global_value = "normal"
	self.ach_dark_2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "mad_goggles",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "rusty",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "rebel",
			amount = 1
		}
	}
	self.ach_dark_3 = {
		dlc = "has_achievement",
		achievement_id = "dark_3",
		content = {}
	}
	self.ach_dark_3.content.loot_global_value = "normal"
	self.ach_dark_3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "half_mask",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "spaceship",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "squares",
			amount = 1
		}
	}
	self.pim = {
		content = {}
	}
	self.pim.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_packrat_m_extended",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_packrat_ns_wick",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_packrat_o_expert",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_schakal_b_civil",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_schakal_m_long",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_schakal_m_short",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_schakal_ns_silencer",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_schakal_s_civil",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_schakal_s_folded",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_schakal_vg_surefire",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_desertfox_b_long",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_desertfox_b_silencer",
			amount = 1
		}
	}
	self.ach_pim_1 = {
		dlc = "has_achievement",
		achievement_id = "pim_1",
		content = {}
	}
	self.ach_pim_1.content.loot_global_value = "pim"
	self.ach_pim_1.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "pim_mustang",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "wheel",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "oneshot",
			amount = 1
		}
	}
	self.ach_pim_2 = {
		dlc = "has_achievement",
		achievement_id = "pim_2",
		content = {}
	}
	self.ach_pim_2.content.loot_global_value = "pim"
	self.ach_pim_2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "pim_hotelier",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "club",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "piety",
			amount = 1
		}
	}
	self.ach_pim_3 = {
		dlc = "has_achievement",
		achievement_id = "pim_3",
		content = {}
	}
	self.ach_pim_3.content.loot_global_value = "pim"
	self.ach_pim_3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "pim_russian_ballistic",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "mist",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "warface",
			amount = 1
		}
	}
	self.ach_pim_4 = {
		dlc = "has_achievement",
		achievement_id = "pim_4",
		content = {}
	}
	self.ach_pim_4.content.loot_global_value = "pim"
	self.ach_pim_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "pim_dog",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "dog",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "daisy",
			amount = 1
		}
	}
	self.opera = {
		content = {}
	}
	self.opera.content.loot_global_value = "opera"
	self.opera.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "sydney",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_tecci_ns_special",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_tecci_b_long",
			amount = 1
		}
	}
	self.dos = {
		free = true,
		content = {}
	}
	self.dos.content.loot_global_value = "normal"
	self.dos.content.loot_drops = {}
	self.dos.content.upgrades = {}
	self.jigg = {
		content = {}
	}
	self.jigg.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "jig_01",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "jig_02",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "damned",
			amount = 1
		}
	}
	self.dbd_clan = {
		content = {}
	}
	self.dbd_clan.content.loot_drops = {}
	self.dbd_clan_award = {
		dlc = "has_dbd_clan",
		content = {}
	}
	self.dbd_clan_award.content.loot_global_value = "dbd_clan"
	self.dbd_clan_award.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "devourer",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "unborn",
			amount = 1
		}
	}
	self.dbd_deluxe = {
		dlc = "has_dbd_deluxe",
		content = {}
	}
	self.dbd_deluxe.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "dbd_02",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "dbd_03",
			amount = 1
		}
	}
	self.pdcon_2015 = {
		content = {}
	}
	self.pdcon_2015.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "king_of_jesters",
			amount = 1
		}
	}
	self.pdcon_2016 = {
		content = {}
	}
	self.pdcon_2016.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "pdc16_clover",
			amount = 1
		}
	}
	self.bobblehead = {
		content = {}
	}
	self.bobblehead.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "bobblehead_dozer",
			amount = 1
		}
	}
	self.free_jwshades = {
		free = true,
		content = {}
	}
	self.free_jwshades.content.loot_global_value = "infamous"
	self.free_jwshades.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "jw_shades",
			amount = 1
		}
	}
	self.dbd_boo_0_award = {
		dlc = "has_dbd_clan",
		content = {}
	}
	self.dbd_boo_0_award.content.loot_global_value = "dbd_clan"
	self.dbd_boo_0_award.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "dbd_04",
			amount = 1
		}
	}
	self.dbd_boo_1_award = {
		dlc = "has_dbd_clan",
		content = {}
	}
	self.dbd_boo_1_award.content.loot_global_value = "dbd_clan"
	self.dbd_boo_1_award.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "dbd_01",
			amount = 1
		}
	}
	self.dbd_boo_4_award = {
		dlc = "has_dbd_clan",
		content = {}
	}
	self.dbd_boo_4_award.content.loot_global_value = "dbd_clan"
	self.dbd_boo_4_award.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "dbd_slasher",
			amount = 1
		}
	}
	self.wild = {
		content = {}
	}
	self.wild.content.loot_global_value = "wild"
	self.wild.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "rust",
			amount = 1
		}
	}
	self.born = {
		content = {}
	}
	self.born.content.loot_drops = {}
	self.ach_born_3 = {
		dlc = "has_achievement",
		achievement_id = "born_3",
		content = {}
	}
	self.ach_born_3.content.loot_global_value = "born"
	self.ach_born_3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "born_biker_01",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "hotrod_red",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "skull_engine",
			amount = 1
		}
	}
	self.ach_born_4 = {
		dlc = "has_achievement",
		achievement_id = "born_4",
		content = {}
	}
	self.ach_born_4.content.loot_global_value = "born"
	self.ach_born_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "born_biker_03",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "shiny_and_chrome",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "tire_fire",
			amount = 1
		}
	}
	self.ach_born_5 = {
		dlc = "has_achievement",
		achievement_id = "born_5",
		content = {}
	}
	self.ach_born_5.content.loot_global_value = "born"
	self.ach_born_5.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "born_biker_02",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "devil_eye",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "skull_wing",
			amount = 1
		}
	}
	self.ach_born_6 = {
		dlc = "has_achievement",
		achievement_id = "born_6",
		content = {}
	}
	self.ach_born_6.content.loot_global_value = "born"
	self.ach_born_6.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "brutal",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "chromey",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "biker_face",
			amount = 1
		}
	}
	self.solus_clan = {
		content = {}
	}
	self.solus_clan.content.loot_drops = {}
	self.solus_clan_award = {
		dlc = "has_solus_clan",
		content = {}
	}
	self.solus_clan_award.content.loot_global_value = "solus_clan"
	self.solus_clan_award.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "solus",
			amount = 1
		}
	}
	self.pd2_clan_migg = {
		content = {},
		dlc = "has_pd2_clan"
	}
	self.pd2_clan_migg.content.loot_global_value = "pd2_clan"
	self.pd2_clan_migg.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "mig_death",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "mig_war",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "mig_conquest",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "mig_famine",
			amount = 1
		}
	}
	self.pd2_clan_fibb = {
		content = {},
		dlc = "has_pd2_clan"
	}
	self.pd2_clan_fibb.content.loot_global_value = "pd2_clan"
	self.pd2_clan_fibb.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "fib_fox",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "fib_cat",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "fib_mouse",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "fib_hare",
			amount = 1
		}
	}
	self.gotti_bundle = {
		content = {}
	}
	self.gotti_bundle.content.loot_global_value = "normal"
	self.gotti_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "gti_al_capone",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "gti_bugsy",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "gti_madame_st_claire",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "gti_lucky_luciano",
			amount = 1
		}
	}
	self.nyck_bundle = {
		content = {}
	}
	self.nyck_bundle.content.loot_global_value = "normal"
	self.nyck_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "nyck_cap",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "nyck_ace",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "nyck_beret",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "nyck_pickle",
			amount = 1
		}
	}
	self.urf_bundle = {
		content = {}
	}
	self.urf_bundle.content.loot_global_value = "normal"
	self.urf_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "urf_seal",
			amount = 1
		}
	}
	self.howl = {
		free = true,
		content = {}
	}
	self.howl.content.loot_global_value = "halloween"
	self.howl.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "hwl_dallas_zombie",
			amount = 1
		}
	}
	self.ach_help_4 = {
		dlc = "has_achievement",
		achievement_id = "orange_4",
		content = {}
	}
	self.ach_help_4.content.loot_global_value = "halloween"
	self.ach_help_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "hwl_wolf_zombie",
			amount = 1
		}
	}
	self.ach_help_5 = {
		dlc = "has_achievement",
		achievement_id = "orange_5",
		content = {}
	}
	self.ach_help_5.content.loot_global_value = "halloween"
	self.ach_help_5.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "howl_chains_zombie",
			amount = 1
		}
	}
	self.ach_help_6 = {
		dlc = "has_achievement",
		achievement_id = "orange_6",
		content = {}
	}
	self.ach_help_6.content.loot_global_value = "halloween"
	self.ach_help_6.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "hwl_hoxton_zombie",
			amount = 1
		}
	}
	self.tango = {
		content = {}
	}
	self.tango.content.loot_global_value = "tango"
	self.tango.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_o_45rds",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_1911_m_big",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_mp5_fg_flash",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_o_spot",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_aug_m_quick",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_mp5_s_folding",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_m4_upg_m_quick",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_p90_m_strap",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ns_duck",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_usp_m_big",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_gre_arbiter_b_comp",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_mac10_m_quick",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_g36_m_quick",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ak_m_quick",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_g36_fg_long",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_g36_o_vintage",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_o_box",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_sho_saiga_fg_holy",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_sho_saiga_b_short",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_sr2_m_quick",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_gre_arbiter_b_long",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_a_grenade_launcher_incendiary_arbiter",
			amount = 1
		}
	}
	self.win_bundle = {
		content = {}
	}
	self.win_bundle.content.loot_global_value = "normal"
	self.win_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "win_donald",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "win_donald_mega",
			amount = 1
		}
	}
	self.ach_moon_4 = {
		dlc = "has_achievement",
		achievement_id = "moon_4",
		content = {}
	}
	self.ach_moon_4.content.loot_global_value = "normal"
	self.ach_moon_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "moon_paycheck_dallas",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "moon_paycheck_chains",
			amount = 1
		}
	}
	self.chico_bundle = {
		content = {}
	}
	self.chico_bundle.content.loot_global_value = "chico"
	self.chico_bundle.dlc = "has_chico"
	self.chico_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "chc_terry",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "chc_terry_begins",
			amount = 1
		}
	}
	self.friend_bundle = {
		content = {}
	}
	self.friend_bundle.content.loot_global_value = "friend"
	self.friend_bundle.dlc = "has_friend"
	self.friend_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "sfm_02",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "golden_hour",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "scar_mask",
			amount = 1
		}
	}
	self.ach_friend_4 = {
		dlc = "has_achievement",
		achievement_id = "friend_4",
		content = {}
	}
	self.ach_friend_4.content.loot_global_value = "friend"
	self.ach_friend_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "sfm_04",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "black_marble",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "diablada",
			amount = 1
		}
	}
	self.ach_friend_5 = {
		dlc = "has_achievement",
		achievement_id = "friend_5",
		content = {}
	}
	self.ach_friend_5.content.loot_global_value = "friend"
	self.ach_friend_5.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "sfm_01",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "oxidized_copper",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "liberty_flame",
			amount = 1
		}
	}
	self.ach_friend_6 = {
		dlc = "has_achievement",
		achievement_id = "friend_6",
		content = {}
	}
	self.ach_friend_6.content.loot_global_value = "friend"
	self.ach_friend_6.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "sfm_03",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "red_velvet",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "my_little",
			amount = 1
		}
	}
	self.swm_bundle = {
		dlc = "has_swm",
		content = {}
	}
	self.swm_bundle.content.loot_global_value = "swm"
	self.swm_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "swm_sydney",
			amount = 1
		}
	}
	self.sparkle_bundle = {
		dlc = "has_sparkle",
		content = {}
	}
	self.sparkle_bundle.content.loot_global_value = "sparkle"
	self.sparkle_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "spk_party",
			amount = 1
		}
	}
	self.sha_bundle = {
		free = true,
		content = {}
	}
	self.sha_bundle.content.loot_global_value = "sha"
	self.sha_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "sha_01",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "sha_02",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "sha_03",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "sha_04",
			amount = 1
		}
	}
	self.yor_bundle = {
		free = true,
		content = {}
	}
	self.yor_bundle.content.loot_global_value = "normal"
	self.yor_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "yor",
			amount = 1
		}
	}
	self.spa_bundle = {
		content = {}
	}
	self.spa_bundle.content.loot_global_value = "spa"
	self.spa_bundle.dlc = "has_spa"
	self.spa_bundle.content.loot_drops = {}
	self.ach_spa_5 = {
		dlc = "has_achievement",
		achievement_id = "spa_5",
		content = {}
	}
	self.ach_spa_5.content.loot_global_value = "spa"
	self.ach_spa_5.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "spa_04",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "underground_neon",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "baba_yaga",
			amount = 1
		}
	}
	self.ach_spa_6 = {
		dlc = "has_achievement",
		achievement_id = "spa_6",
		content = {}
	}
	self.ach_spa_6.content.loot_global_value = "spa"
	self.ach_spa_6.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "spa_03",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "carbon_fiber_weave",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "hood_stripes",
			amount = 1
		}
	}
	self.ach_fish_5 = {
		dlc = "has_achievement",
		achievement_id = "fish_5",
		content = {}
	}
	self.ach_fish_5.content.loot_global_value = "spa"
	self.ach_fish_5.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "spa_02",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "neon_blue",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "hotel_pattern",
			amount = 1
		}
	}
	self.ach_fish_6 = {
		dlc = "has_achievement",
		achievement_id = "fish_6",
		content = {}
	}
	self.ach_fish_6.content.loot_global_value = "spa"
	self.ach_fish_6.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "spa_01",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "black_suede",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "continental",
			amount = 1
		}
	}
	self.grv_bundle = {
		content = {}
	}
	self.grv_bundle.content.loot_global_value = "grv"
	self.grv_bundle.dlc = "has_grv"
	self.grv_bundle.content.loot_drops = {}
	self.ach_grv_1 = {
		dlc = "has_achievement",
		achievement_id = "grv_1",
		content = {}
	}
	self.ach_grv_1.content.loot_global_value = "grv"
	self.ach_grv_1.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "grv_04",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "tricolor",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "russian_gamble",
			amount = 1
		}
	}
	self.ach_grv_2 = {
		dlc = "has_achievement",
		achievement_id = "grv_2",
		content = {}
	}
	self.ach_grv_2.content.loot_global_value = "grv"
	self.ach_grv_2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "grv_01",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "russian_camouflage",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "red_star",
			amount = 1
		}
	}
	self.ach_grv_3 = {
		dlc = "has_achievement",
		achievement_id = "grv_3",
		content = {}
	}
	self.ach_grv_3.content.loot_global_value = "grv"
	self.ach_grv_3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "grv_03",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "propaganda_palette",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "bear_fight",
			amount = 1
		}
	}
	self.ach_grv_4 = {
		dlc = "has_achievement",
		achievement_id = "grv_4",
		content = {}
	}
	self.ach_grv_4.content.loot_global_value = "grv"
	self.ach_grv_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "grv_02",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "ceramics_gzhel",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "prison_statement",
			amount = 1
		}
	}
	self.bny_bundle = {
		free = true,
		content = {}
	}
	self.bny_bundle.content.loot_global_value = "normal"
	self.bny_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "bny_01",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "bny_02",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "bny_03",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "bny_04",
			amount = 1
		}
	}
	self.ach_cee_3 = {
		dlc = "has_achievement",
		achievement_id = "cee_3",
		content = {}
	}
	self.ach_cee_3.content.loot_global_value = "infamous"
	self.ach_cee_3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "mrm",
			amount = 1
		}
	}
	self.pn2_bundle = {
		dlc = "has_pn2",
		content = {}
	}
	self.pn2_bundle.content.loot_global_value = "pn2"
	self.pn2_bundle.content.loot_drops = {}
	self.mp2_bundle = {
		free = true,
		content = {}
	}
	self.mp2_bundle.content.loot_global_value = "normal"
	self.mp2_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "mp2_01",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "mp2_02",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "mp2_03",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "mp2_04",
			amount = 1
		}
	}
	self.amp_bundle = {
		free = true,
		content = {}
	}
	self.amp_bundle.content.loot_global_value = "normal"
	self.amp_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "amp_01",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "amp_02",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "amp_03",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "amp_04",
			amount = 1
		}
	}
	self.flip_bundle = {
		free = true,
		content = {}
	}
	self.flip_bundle.content.loot_global_value = "normal"
	self.flip_bundle.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_o_xpsg33_magnifier",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_o_45rds_v2",
			amount = 1
		}
	}
	self.mdm_bundle = {
		free = true,
		content = {}
	}
	self.mdm_bundle.content.loot_global_value = "infamous"
	self.mdm_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "mdm",
			amount = 1
		}
	}
	self.ant_free = {
		free = true,
		content = {}
	}
	self.ant_free.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "ant_05",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "ant_07",
			amount = 1
		}
	}
	self.ant = {
		dlc = "has_ant",
		content = {}
	}
	self.ant.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "ant_01",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "ant_02",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "ant_03",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "ant_04",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "ant_06",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "ant_08",
			amount = 1
		}
	}
	self.dgm_bundle = {
		free = true,
		content = {}
	}
	self.dgm_bundle.content.loot_global_value = "pd2_clan"
	self.dgm_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "dgm",
			amount = 1
		}
	}
	self.gcm_bundle = {
		free = true,
		content = {}
	}
	self.gcm_bundle.content.loot_global_value = "pd2_clan"
	self.gcm_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "gcm",
			amount = 1
		}
	}
	self.ztm_bundle = {
		dlc = "has_ztm",
		content = {}
	}
	self.ztm_bundle.content.loot_global_value = "ztm"
	self.ztm_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "ztm",
			amount = 1
		}
	}
	self.wmp_bundle = {
		free = true,
		content = {}
	}
	self.wmp_bundle.content.loot_global_value = "pd2_clan"
	self.wmp_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "wmp_01",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "wmp_02",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "wmp_03",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "wmp_04",
			amount = 1
		}
	}
	self.cmo_bundle = {
		free = true,
		content = {}
	}
	self.cmo_bundle.content.loot_global_value = "normal"
	self.cmo_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "cmo_01",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "cmo_02",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "cmo_03",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "cmo_04",
			amount = 1
		}
	}
	self.cmt = {
		free = true,
		content = {}
	}
	self.cmt.content.loot_drops = {}
	self.pbm_bundle = {
		dlc = "has_pbm",
		content = {}
	}
	self.pbm_bundle.content.loot_global_value = "pbm"
	self.pbm_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "pbm",
			amount = 1
		}
	}
	self.dnm = {
		free = true,
		content = {}
	}
	self.dnm.content.loot_drops = {}
	self.ach_trk_a_0 = {
		dlc = "has_achievement",
		achievement_id = "trk_a_0",
		content = {}
	}
	self.ach_trk_a_0.content.loot_global_value = "infamous"
	self.ach_trk_a_0.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "dnm",
			amount = 1
		}
	}
	self.wwh = {
		free = true,
		content = {}
	}
	self.wwh.content.loot_drops = {}
	self.eng = {
		free = true,
		content = {}
	}
	self.eng.content.loot_drops = {}
	self.ach_eng_1 = {
		dlc = "has_achievement",
		achievement_id = "eng_1",
		content = {}
	}
	self.ach_eng_1.content.loot_global_value = "eng"
	self.ach_eng_1.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "eng_01",
			amount = 1
		}
	}
	self.ach_eng_2 = {
		dlc = "has_achievement",
		achievement_id = "eng_2",
		content = {}
	}
	self.ach_eng_2.content.loot_global_value = "eng"
	self.ach_eng_2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "eng_02",
			amount = 1
		}
	}
	self.ach_eng_3 = {
		dlc = "has_achievement",
		achievement_id = "eng_4",
		content = {}
	}
	self.ach_eng_3.content.loot_global_value = "eng"
	self.ach_eng_3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "eng_03",
			amount = 1
		}
	}
	self.ach_eng_4 = {
		dlc = "has_achievement",
		achievement_id = "eng_3",
		content = {}
	}
	self.ach_eng_4.content.loot_global_value = "eng"
	self.ach_eng_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "eng_04",
			amount = 1
		}
	}
	self.fdm_bundle = {
		dlc = "has_fdm",
		content = {}
	}
	self.fdm_bundle.content.loot_global_value = "fdm"
	self.fdm_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "fdm",
			amount = 1
		}
	}
	self.jfr = {
		free = true,
		content = {}
	}
	self.kwm_bundle = {
		free = true,
		content = {}
	}
	self.kwm_bundle.content.loot_global_value = "normal"
	self.kwm_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "kwm",
			amount = 1
		}
	}
	self.mmj_bundle = {
		free = true,
		content = {}
	}
	self.mmj_bundle.content.loot_global_value = "normal"
	self.mmj_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "mmj",
			amount = 1
		}
	}
	self.ami_2 = {
		dlc = "has_achievement_milestone",
		milestone_id = "ami_2",
		content = {}
	}
	self.ami_2.content.loot_global_value = "infamous"
	self.ami_2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "ami_02",
			amount = 1
		}
	}
	self.ami_4 = {
		dlc = "has_achievement_milestone",
		milestone_id = "ami_4",
		content = {}
	}
	self.ami_4.content.loot_global_value = "infamous"
	self.ami_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "ami_03",
			amount = 1
		}
	}
	self.ami_6 = {
		dlc = "has_achievement_milestone",
		milestone_id = "ami_6",
		content = {}
	}
	self.ami_6.content.loot_global_value = "infamous"
	self.ami_6.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "ami_05",
			amount = 1
		}
	}
	self.ami_8 = {
		dlc = "has_achievement_milestone",
		milestone_id = "ami_8",
		content = {}
	}
	self.ami_8.content.loot_global_value = "infamous"
	self.ami_8.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "ami_04",
			amount = 1
		}
	}
	self.ami_10 = {
		dlc = "has_achievement_milestone",
		milestone_id = "ami_10",
		content = {}
	}
	self.ami_10.content.loot_global_value = "infamous"
	self.ami_10.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "ami_01",
			amount = 1
		}
	}
	self.ami_12 = {
		dlc = "has_achievement_milestone",
		milestone_id = "ami_12",
		content = {}
	}
	self.ami_12.content.loot_global_value = "infamous"
	self.ami_12.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "ami_06",
			amount = 1
		}
	}
	self.ami_13 = {
		dlc = "has_achievement_milestone",
		milestone_id = "ami_13",
		content = {}
	}
	self.ami_13.content.loot_global_value = "tam"
	self.ami_13.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "tam",
			amount = 1
		},
		{
			type_items = "armor_skins",
			item_entry = "tam"
		}
	}

	for key, _ in pairs(tweak_data.weapon) do
		if tweak_data.blackmarket.weapon_skins[key .. "_tam"] then
			local drop = {
				type_items = "weapon_skins",
				item_entry = key .. "_tam"
			}

			table.insert(self.ami_13.content.loot_drops, drop)
		end
	end

	self.ecp_bundle = {
		dlc = "has_ecp",
		content = {}
	}
	self.ecp_bundle.content.loot_global_value = "ecp"
	self.ecp_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "ecp_female",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "ecp_male",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "ecp_female_begins",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "ecp_male_begins",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_bow_ecp_m_arrows_explosive",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_bow_ecp_m_arrows_poison",
			amount = 1
		}
	}
	self.fgl_bundle = {
		dlc = "has_fgl",
		content = {}
	}
	self.fgl_bundle.content.loot_global_value = "fgl"
	self.fgl_bundle.content.loot_drops = {}
	self.osa_bundle = {
		dlc = "has_osa",
		content = {}
	}
	self.osa_bundle.content.loot_global_value = "osa"
	self.osa_bundle.content.loot_drops = {}
	self.gwm_bundle = {
		free = true,
		content = {}
	}
	self.gwm_bundle.content.loot_global_value = "pd2_clan"
	self.gwm_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "gwm",
			amount = 1
		}
	}
	self.rvd_bundle = {
		dlc = "has_rvd",
		content = {}
	}
	self.rvd_bundle.content.loot_global_value = "rvd"
	self.rvd_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "rvd_01",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "rvd_02",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "rvd_03",
			amount = 1
		}
	}
	self.ach_brb_8 = {
		dlc = "has_achievement",
		achievement_id = "brb_8",
		content = {}
	}
	self.ach_brb_8.content.loot_global_value = "cmt"
	self.ach_brb_8.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "cmt_01",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "cmt_02",
			amount = 1
		}
	}
	self.ach_brb_9 = {
		dlc = "has_achievement",
		achievement_id = "brb_9",
		content = {}
	}
	self.ach_brb_9.content.loot_global_value = "cmt"
	self.ach_brb_9.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "cmt_03",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "cmt_04",
			amount = 1
		}
	}
	self.ami_bundle = {
		dlc = "has_ami",
		content = {}
	}
	self.ami_bundle.content.loot_global_value = "normal"
	self.ami_bundle.content.loot_drops = {}
	self.dmg_bundle = {
		dlc = "has_dmg",
		content = {}
	}
	self.dmg_bundle.content.loot_global_value = "dmg"
	self.dmg_bundle.content.loot_drops = {}
	self.ach_ggez_1 = {
		dlc = "has_achievement",
		achievement_id = "ggez_1",
		content = {}
	}
	self.ach_ggez_1.content.loot_global_value = "infamous"
	self.ach_ggez_1.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "ggac_od_t2",
			amount = 1
		}
	}
	self.pmp_bundle = {
		dlc = "has_pmp",
		content = {}
	}
	self.pmp_bundle.content.loot_global_value = "normal"
	self.pmp_bundle.content.loot_drops = {
		{
			type_items = "textures",
			item_entry = "pizzaface"
		},
		{
			{
				type_items = "materials",
				item_entry = "solid_greyscale70"
			},
			{
				type_items = "materials",
				item_entry = "solid_greyscale50"
			},
			{
				type_items = "materials",
				item_entry = "solid_greyscale10"
			}
		},
		{
			{
				type_items = "materials",
				item_entry = "solid_green"
			},
			{
				type_items = "materials",
				item_entry = "solid_yellow"
			},
			{
				type_items = "materials",
				item_entry = "solid_orange"
			}
		},
		{
			{
				type_items = "materials",
				item_entry = "solid_purple"
			},
			{
				type_items = "materials",
				item_entry = "solid_blue"
			},
			{
				type_items = "materials",
				item_entry = "solid_paydayblue"
			},
			{
				type_items = "materials",
				item_entry = "solid_teal"
			}
		},
		{
			{
				type_items = "materials",
				item_entry = "solid_red"
			},
			{
				type_items = "materials",
				item_entry = "solid_pink"
			},
			{
				type_items = "materials",
				item_entry = "solid_magenta"
			}
		},
		{
			{
				type_items = "materials",
				item_entry = "solid_green_dark"
			},
			{
				type_items = "materials",
				item_entry = "solid_yellow_dark"
			},
			{
				type_items = "materials",
				item_entry = "solid_orange_dark"
			}
		},
		{
			{
				type_items = "materials",
				item_entry = "solid_purple_dark"
			},
			{
				type_items = "materials",
				item_entry = "solid_blue_dark"
			},
			{
				type_items = "materials",
				item_entry = "solid_paydayblue_dark"
			},
			{
				type_items = "materials",
				item_entry = "solid_teal_dark"
			}
		},
		{
			{
				type_items = "materials",
				item_entry = "solid_pink_dark"
			},
			{
				type_items = "materials",
				item_entry = "solid_magenta_dark"
			},
			{
				type_items = "materials",
				item_entry = "solid_red_dark"
			}
		},
		{
			{
				type_items = "materials",
				item_entry = "solid_green_desaturated"
			},
			{
				type_items = "materials",
				item_entry = "solid_yellow_desaturated"
			},
			{
				type_items = "materials",
				item_entry = "solid_orange_desaturated"
			}
		},
		{
			{
				type_items = "materials",
				item_entry = "solid_purple_desaturated"
			},
			{
				type_items = "materials",
				item_entry = "solid_blue_desaturated"
			},
			{
				type_items = "materials",
				item_entry = "solid_paydayblue_desaturated"
			},
			{
				type_items = "materials",
				item_entry = "solid_teal_desaturated"
			}
		},
		{
			{
				type_items = "materials",
				item_entry = "solid_pink_desaturated"
			},
			{
				type_items = "materials",
				item_entry = "solid_magenta_desaturated"
			},
			{
				type_items = "materials",
				item_entry = "solid_red_desaturated"
			}
		},
		{
			{
				type_items = "colors",
				item_entry = "red_gray"
			},
			{
				type_items = "colors",
				item_entry = "red_scary_green"
			},
			{
				type_items = "colors",
				item_entry = "red_dark_gray"
			},
			{
				type_items = "colors",
				item_entry = "red_orange"
			}
		},
		{
			{
				type_items = "colors",
				item_entry = "coral_red_white"
			},
			{
				type_items = "colors",
				item_entry = "coral_red_dark_gray"
			},
			{
				type_items = "colors",
				item_entry = "coral_red_black"
			},
			{
				type_items = "colors",
				item_entry = "coral_red_light_gray"
			},
			{
				type_items = "colors",
				item_entry = "coral_red_solid"
			}
		},
		{
			{
				type_items = "colors",
				item_entry = "dark_red_red"
			},
			{
				type_items = "colors",
				item_entry = "dark_red_bright_yellow"
			},
			{
				type_items = "colors",
				item_entry = "dark_red_black"
			},
			{
				type_items = "colors",
				item_entry = "dark_red_gray"
			},
			{
				type_items = "colors",
				item_entry = "blood_red_toxic_green"
			},
			{
				type_items = "colors",
				item_entry = "blood_red_cobalt_blue"
			}
		},
		{
			{
				type_items = "colors",
				item_entry = "pink_yellow"
			},
			{
				type_items = "colors",
				item_entry = "pink_cobalt_blue"
			},
			{
				type_items = "colors",
				item_entry = "pink_black"
			},
			{
				type_items = "colors",
				item_entry = "pink_white"
			},
			{
				type_items = "colors",
				item_entry = "pink_navy_blue"
			},
			{
				type_items = "colors",
				item_entry = "pink_gray"
			}
		},
		{
			{
				type_items = "colors",
				item_entry = "turquoise_black"
			},
			{
				type_items = "colors",
				item_entry = "turquoise_warm_yellow"
			},
			{
				type_items = "colors",
				item_entry = "turquoise_gray"
			},
			{
				type_items = "colors",
				item_entry = "turquoise_black"
			},
			{
				type_items = "colors",
				item_entry = "turquoise_white"
			},
			{
				type_items = "colors",
				item_entry = "turquoise_solid"
			}
		},
		{
			{
				type_items = "colors",
				item_entry = "light_blue_black"
			},
			{
				type_items = "colors",
				item_entry = "light_blue_white"
			},
			{
				type_items = "colors",
				item_entry = "light_blue_bright_yellow"
			},
			{
				type_items = "colors",
				item_entry = "light_blue_coral_red"
			},
			{
				type_items = "colors",
				item_entry = "light_blue_navy_blue"
			},
			{
				type_items = "colors",
				item_entry = "light_blue_orange"
			}
		},
		{
			{
				type_items = "colors",
				item_entry = "cobalt_blue_solid"
			},
			{
				type_items = "colors",
				item_entry = "cobalt_blue_warm_yellow"
			},
			{
				type_items = "colors",
				item_entry = "cobalt_blue_gray"
			},
			{
				type_items = "colors",
				item_entry = "cobalt_blue_orange"
			},
			{
				type_items = "colors",
				item_entry = "cobalt_blue_black"
			}
		},
		{
			{
				type_items = "colors",
				item_entry = "blue_white"
			},
			{
				type_items = "colors",
				item_entry = "blue_black"
			},
			{
				type_items = "colors",
				item_entry = "blue_navy_blue"
			},
			{
				type_items = "colors",
				item_entry = "blue_gray"
			}
		},
		{
			{
				type_items = "colors",
				item_entry = "white_yellow"
			},
			{
				type_items = "colors",
				item_entry = "white_orange"
			},
			{
				type_items = "colors",
				item_entry = "white_dark_red"
			},
			{
				type_items = "colors",
				item_entry = "white_cyan"
			},
			{
				type_items = "colors",
				item_entry = "white_scary_green"
			}
		},
		{
			{
				type_items = "colors",
				item_entry = "black_cyan"
			},
			{
				type_items = "colors",
				item_entry = "black_green"
			},
			{
				type_items = "colors",
				item_entry = "black_yellow"
			},
			{
				type_items = "colors",
				item_entry = "black_gray"
			}
		},
		{
			{
				type_items = "colors",
				item_entry = "dark_gray_white"
			},
			{
				type_items = "colors",
				item_entry = "dark_gray_black"
			},
			{
				type_items = "colors",
				item_entry = "dark_gray_coral_red"
			},
			{
				type_items = "colors",
				item_entry = "dark_gray_cobalt_blue"
			},
			{
				type_items = "colors",
				item_entry = "dark_gray_turquoise"
			},
			{
				type_items = "colors",
				item_entry = "dark_gray_green"
			}
		},
		{
			{
				type_items = "colors",
				item_entry = "dark_gray_yellow"
			},
			{
				type_items = "colors",
				item_entry = "dark_gray_magenta"
			},
			{
				type_items = "colors",
				item_entry = "dark_gray_dark_red"
			},
			{
				type_items = "colors",
				item_entry = "dark_gray_purple"
			},
			{
				type_items = "colors",
				item_entry = "dark_gray_bright_yellow"
			}
		},
		{
			{
				type_items = "colors",
				item_entry = "gray_white"
			},
			{
				type_items = "colors",
				item_entry = "gray_purple"
			},
			{
				type_items = "colors",
				item_entry = "gray_cobalt_blue"
			},
			{
				type_items = "colors",
				item_entry = "gray_turquoise"
			},
			{
				type_items = "colors",
				item_entry = "gray_green"
			},
			{
				type_items = "colors",
				item_entry = "gray_yellow"
			}
		},
		{
			{
				type_items = "colors",
				item_entry = "gray_dark_red"
			},
			{
				type_items = "colors",
				item_entry = "gray_magenta"
			},
			{
				type_items = "colors",
				item_entry = "gray_orange"
			},
			{
				type_items = "colors",
				item_entry = "gray_red"
			},
			{
				type_items = "colors",
				item_entry = "gray_bright_yellow"
			}
		},
		{
			{
				type_items = "colors",
				item_entry = "light_brown_black"
			},
			{
				type_items = "colors",
				item_entry = "light_brown_white"
			},
			{
				type_items = "colors",
				item_entry = "light_brown_gray"
			}
		},
		{
			{
				type_items = "colors",
				item_entry = "purple_black"
			},
			{
				type_items = "colors",
				item_entry = "purple_white"
			},
			{
				type_items = "colors",
				item_entry = "purple_cyan"
			}
		},
		{
			{
				type_items = "colors",
				item_entry = "leaf_green_black"
			},
			{
				type_items = "colors",
				item_entry = "leaf_green_dark_green"
			},
			{
				type_items = "colors",
				item_entry = "dark_green_leaf_green"
			}
		},
		{
			{
				type_items = "colors",
				item_entry = "magenta_black"
			},
			{
				type_items = "colors",
				item_entry = "magenta_white"
			},
			{
				type_items = "colors",
				item_entry = "magenta_yellow"
			},
			{
				type_items = "colors",
				item_entry = "magenta_warm_yellow"
			},
			{
				type_items = "colors",
				item_entry = "magenta_dark_gray"
			}
		},
		{
			{
				type_items = "colors",
				item_entry = "yellow_black"
			},
			{
				type_items = "colors",
				item_entry = "yellow_white"
			},
			{
				type_items = "colors",
				item_entry = "yellow_gray"
			},
			{
				type_items = "colors",
				item_entry = "yellow_dark_gray"
			},
			{
				type_items = "colors",
				item_entry = "yellow_red"
			}
		},
		{
			{
				type_items = "colors",
				item_entry = "orange_gray"
			},
			{
				type_items = "colors",
				item_entry = "orange_turquoise"
			},
			{
				type_items = "colors",
				item_entry = "bright_yellow_solid"
			},
			{
				type_items = "colors",
				item_entry = "bright_yellow_dark_red"
			}
		},
		{
			{
				type_items = "colors",
				item_entry = "warm_yellow_light_blue"
			},
			{
				type_items = "colors",
				item_entry = "warm_yellow_purple"
			},
			{
				type_items = "colors",
				item_entry = "warm_yellow_dark_red"
			},
			{
				type_items = "colors",
				item_entry = "warm_yellow_solid"
			}
		},
		{
			{
				type_items = "textures",
				item_entry = "hands_batman"
			},
			{
				type_items = "textures",
				item_entry = "hands_ok"
			},
			{
				type_items = "textures",
				item_entry = "hands_peace"
			},
			{
				type_items = "textures",
				item_entry = "hands_loser"
			},
			{
				type_items = "textures",
				item_entry = "hands_shutup"
			},
			{
				type_items = "textures",
				item_entry = "hands_pans"
			}
		},
		{
			{
				type_items = "textures",
				item_entry = "clowns_qc"
			},
			{
				type_items = "textures",
				item_entry = "clowns_ahe"
			},
			{
				type_items = "textures",
				item_entry = "clowns_hoc"
			},
			{
				type_items = "textures",
				item_entry = "clowns_in"
			},
			{
				type_items = "textures",
				item_entry = "clowns_it"
			}
		},
		{
			{
				type_items = "textures",
				item_entry = "barf"
			},
			{
				type_items = "textures",
				item_entry = "basketball"
			},
			{
				type_items = "textures",
				item_entry = "crashdummy"
			},
			{
				type_items = "textures",
				item_entry = "friedegg"
			},
			{
				type_items = "textures",
				item_entry = "phantom"
			}
		},
		{
			{
				type_items = "textures",
				item_entry = "facepaint_cupcake"
			},
			{
				type_items = "textures",
				item_entry = "facepaint_flowers"
			},
			{
				type_items = "textures",
				item_entry = "facepaint_football"
			},
			{
				type_items = "textures",
				item_entry = "facepaint_rainbow"
			},
			{
				type_items = "textures",
				item_entry = "facepaint_skull"
			}
		},
		{
			{
				type_items = "textures",
				item_entry = "heraldry_ord_fess"
			},
			{
				type_items = "textures",
				item_entry = "heraldry_ord_pale"
			},
			{
				type_items = "textures",
				item_entry = "heraldry_ord_pall"
			},
			{
				type_items = "textures",
				item_entry = "heraldry_ord_saltire"
			}
		},
		{
			{
				type_items = "textures",
				item_entry = "heraldry_ord_cross"
			},
			{
				type_items = "textures",
				item_entry = "heraldry_ord_chevron"
			},
			{
				type_items = "textures",
				item_entry = "heraldry_ord_bend"
			}
		},
		{
			{
				type_items = "textures",
				item_entry = "heraldry_div_tiercedpall"
			},
			{
				type_items = "textures",
				item_entry = "heraldry_div_quarterly"
			},
			{
				type_items = "textures",
				item_entry = "heraldry_div_persaltire"
			},
			{
				type_items = "textures",
				item_entry = "heraldry_div_perpale"
			}
		},
		{
			{
				type_items = "textures",
				item_entry = "heraldry_div_perfess"
			},
			{
				type_items = "textures",
				item_entry = "heraldry_div_perchevron"
			},
			{
				type_items = "textures",
				item_entry = "heraldry_div_perbend"
			}
		},
		{
			{
				type_items = "textures",
				item_entry = "heraldry_geo_paly"
			},
			{
				type_items = "textures",
				item_entry = "heraldry_geo_lozengy"
			},
			{
				type_items = "textures",
				item_entry = "heraldry_geo_gyronny"
			},
			{
				type_items = "textures",
				item_entry = "heraldry_geo_fusil"
			}
		},
		{
			{
				type_items = "textures",
				item_entry = "heraldry_geo_checky"
			},
			{
				type_items = "textures",
				item_entry = "heraldry_geo_bendy"
			},
			{
				type_items = "textures",
				item_entry = "heraldry_geo_barrypale"
			},
			{
				type_items = "textures",
				item_entry = "heraldry_geo_barry"
			}
		},
		{
			{
				type_items = "textures",
				item_entry = "warpaint_freedom"
			},
			{
				type_items = "textures",
				item_entry = "warpaint_half_hawk"
			},
			{
				type_items = "textures",
				item_entry = "warpaint_crow_beak"
			},
			{
				type_items = "textures",
				item_entry = "warpaint_cross_marking"
			},
			{
				type_items = "textures",
				item_entry = "warpaint_darkness_eyes"
			}
		}
	}
	self.joy_bundle = {
		dlc = "has_joy",
		content = {}
	}
	self.joy_bundle.content.loot_global_value = "infamous"
	self.joy_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "joy",
			amount = 1
		}
	}
	self.ghm_bundle = {
		dlc = "has_ghm",
		content = {}
	}
	self.ghm_bundle.content.loot_global_value = "pd2_clan"
	self.ghm_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "ghm",
			amount = 1
		}
	}
	self.khp_bundle = {
		free = true,
		content = {}
	}
	self.khp_bundle.content.loot_global_value = "normal"
	self.khp_bundle.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_legacy_b_threaded",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_legacy_g_wood",
			amount = 1
		}
	}
	self.sdb_bundle = {
		free = true,
		content = {}
	}
	self.sdb_bundle.content.loot_global_value = "normal"
	self.sdb_bundle.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_sho_coach_b_short",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_sho_coach_s_short",
			amount = 1
		}
	}
	self.ram_bundle = {
		free = true,
		content = {}
	}
	self.ram_bundle.content.loot_global_value = "normal"
	self.ram_bundle.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_bow_elastic_m_explosive",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_bow_elastic_m_poison",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_bow_elastic_body_tactic",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_bow_elastic_g_2",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_bow_elastic_g_3",
			amount = 1
		}
	}
	self.sms_bundle_1 = {
		dlc = "has_stat",
		stat_id = "tester",
		content = {}
	}
	self.sms_bundle_1.content.loot_global_value = "infamous"
	self.sms_bundle_1.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "sms_01",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "sms_02",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "sms_03",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "sms_04",
			amount = 1
		}
	}
	self.sms_bundle_2 = {
		dlc = "has_achievement",
		achievement_id = "fin_1",
		content = {}
	}
	self.sms_bundle_2.content.loot_global_value = "infamous"
	self.sms_bundle_2.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "sms_05",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "sms_06",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "sms_07",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "sms_08",
			amount = 1
		}
	}
	self.scm_bundle = {
		dlc = "has_stat",
		stat_id = "uno_puzzle_door_activated",
		content = {}
	}
	self.scm_bundle.content.loot_global_value = "infamous"
	self.scm_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "scm_01",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "scm_02",
			amount = 1
		}
	}
	self.ach_trd_dah_1 = {
		dlc = "has_achievement",
		achievement_id = "dah_1",
		content = {}
	}
	self.ach_trd_dah_1.content.loot_drops = {
		{
			type_items = "player_styles",
			item_entry = "sneak_suit"
		}
	}
	self.ach_trd_nmh_1 = {
		dlc = "has_achievement",
		achievement_id = "nmh_1",
		content = {}
	}
	self.ach_trd_nmh_1.content.loot_drops = {
		{
			type_items = "player_styles",
			item_entry = "scrub"
		}
	}
	self.ach_trd_glace_1 = {
		dlc = "has_achievement",
		achievement_id = "glace_1",
		content = {}
	}
	self.ach_trd_glace_1.content.loot_drops = {
		{
			type_items = "player_styles",
			item_entry = "raincoat"
		}
	}
	self.ach_trd_sah_1 = {
		dlc = "has_achievement",
		achievement_id = "sah_1",
		content = {}
	}
	self.ach_trd_sah_1.content.loot_drops = {
		{
			type_items = "player_styles",
			item_entry = "tux"
		}
	}
	self.ach_trd_wwh_1 = {
		dlc = "has_achievement",
		achievement_id = "wwh_1",
		content = {}
	}
	self.ach_trd_wwh_1.content.loot_drops = {
		{
			type_items = "player_styles",
			item_entry = "winter_suit"
		}
	}
	self.ach_trd_mex_9 = {
		dlc = "has_achievement",
		achievement_id = "mex_9",
		content = {}
	}
	self.ach_trd_mex_9.content.loot_drops = {
		{
			type_items = "player_styles",
			item_entry = "murky_suit"
		}
	}
	self.pd2_clan_trd = {
		content = {},
		dlc = "has_pd2_clan"
	}
	self.pd2_clan_trd.content.loot_drops = {
		{
			type_items = "player_styles",
			item_entry = "jail_pd2_clan"
		}
	}
	self.ach_trk_cou_0 = {
		dlc = "has_achievement",
		achievement_id = "trk_cou_0",
		content = {}
	}
	self.ach_trk_cou_0.content.loot_drops = {
		{
			type_items = "player_styles",
			item_entry = "poolrepair"
		}
	}
	self.ach_trd_mex_10 = {
		dlc = "has_achievement",
		achievement_id = "mex_10",
		content = {}
	}
	self.ach_trd_mex_10.content.loot_global_value = "mex"
	self.ach_trd_mex_10.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "roman",
			amount = 1
		}
	}
	self.wcs_starter_pack = {
		free = true,
		content = {}
	}
	self.wcs_starter_pack.content.loot_global_value = "normal"
	self.wcs_starter_pack.content.loot_drops = {
		{
			type_items = "weapon_skins",
			item_entry = "color_gray_black",
			amount = 1
		},
		{
			type_items = "weapon_skins",
			item_entry = "color_tan_khaki",
			amount = 1
		}
	}
	self.wcs_pd2_clan = {
		dlc = "has_pd2_clan",
		content = {}
	}
	self.wcs_pd2_clan.content.loot_global_value = "pd2_clan"
	self.wcs_pd2_clan.content.loot_drops = {
		{
			type_items = "weapon_skins",
			item_entry = "color_blue_payday",
			amount = 1
		}
	}
	self.ach_trd_bex_1 = {
		dlc = "has_achievement",
		achievement_id = "bex_1",
		content = {}
	}
	self.ach_trd_bex_1.content.loot_global_value = "bex"
	self.ach_trd_bex_1.content.loot_drops = {
		{
			type_items = "player_styles",
			item_entry = "mariachi"
		}
	}
	self.ach_trd_bex_2 = {
		dlc = "has_achievement",
		achievement_id = "bex_2",
		content = {}
	}
	self.ach_trd_bex_2.content.loot_global_value = "bex"
	self.ach_trd_bex_2.content.loot_drops = {
		{
			type_items = "suit_variations",
			item_entry = {
				"mariachi",
				"brown"
			}
		}
	}
	self.ach_trd_bex_3 = {
		dlc = "has_achievement",
		achievement_id = "bex_4",
		content = {}
	}
	self.ach_trd_bex_3.content.loot_global_value = "bex"
	self.ach_trd_bex_3.content.loot_drops = {
		{
			type_items = "suit_variations",
			item_entry = {
				"mariachi",
				"white"
			}
		}
	}
	self.ach_trd_bex_4 = {
		dlc = "has_achievement",
		achievement_id = "bex_6",
		content = {}
	}
	self.ach_trd_bex_4.content.loot_global_value = "bex"
	self.ach_trd_bex_4.content.loot_drops = {
		{
			type_items = "suit_variations",
			item_entry = {
				"mariachi",
				"red"
			}
		}
	}
	self.ach_trd_bex_5 = {
		dlc = "has_achievement",
		achievement_id = "bex_7",
		content = {}
	}
	self.ach_trd_bex_5.content.loot_global_value = "bex"
	self.ach_trd_bex_5.content.loot_drops = {
		{
			type_items = "suit_variations",
			item_entry = {
				"mariachi",
				"black"
			}
		}
	}
	self.ach_mask_bex_9 = {
		dlc = "has_achievement",
		achievement_id = "bex_9",
		content = {}
	}
	self.ach_mask_bex_9.content.loot_global_value = "bex"
	self.ach_mask_bex_9.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "sombrero",
			amount = 1
		}
	}
	self.ach_wcs_bex_10 = {
		dlc = "has_achievement",
		achievement_id = "bex_10",
		content = {}
	}
	self.ach_wcs_bex_10.content.loot_global_value = "normal"
	self.ach_wcs_bex_10.content.loot_drops = {
		{
			type_items = "weapon_skins",
			item_entry = "color_white",
			amount = 1
		}
	}
	self.ach_wcs_bex_11 = {
		dlc = "has_achievement",
		achievement_id = "bex_11",
		content = {}
	}
	self.ach_wcs_bex_11.content.loot_global_value = "normal"
	self.ach_wcs_bex_11.content.loot_drops = {
		{
			type_items = "weapon_skins",
			item_entry = "color_green_money",
			amount = 1
		}
	}
end
