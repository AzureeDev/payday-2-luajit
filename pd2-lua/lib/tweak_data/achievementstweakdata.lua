require("lib/tweak_data/GeneratedAchievementTweakData")

local function get_texture_path(tweak_data, category, id)
	local td = nil
	local rtn = {}

	if category == "armor_skins" then
		td = tweak_data.economy.armor_skins[id]
	else
		td = tweak_data:get_raw_value("blackmarket", category, id)
	end

	if category == "textures" then
		rtn.texture = td.texture
		rtn.render_template = "VertexColorTexturedPatterns"
	else
		local guis_catalog = "guis/"
		local bundle_folder = td.texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		if category == "armor_skins" then
			rtn.texture = guis_catalog .. "armor_skins/" .. id
		else
			rtn.texture = guis_catalog .. "textures/pd2/blackmarket/icons/" .. (category == "weapon_mods" and "mods" or category) .. "/" .. id
		end
	end

	if not DB:has(Idstring("texture"), Idstring(rtn.texture)) then
		Application:error("ERROR MISSING TEXTURE:", rtn.texture)

		rtn.texture = "guis/textures/pd2/endscreen/exp_ring"
	end

	return rtn
end

AchievementsTweakData = AchievementsTweakData or class()

function AchievementsTweakData:init(tweak_data)
	local normal_and_above = {
		"normal",
		"hard",
		"overkill",
		"overkill_145",
		"easy_wish",
		"overkill_290",
		"sm_wish"
	}
	local hard_and_above = {
		"hard",
		"overkill",
		"overkill_145",
		"easy_wish",
		"overkill_290",
		"sm_wish"
	}
	local veryhard_and_above = {
		"overkill",
		"overkill_145",
		"easy_wish",
		"overkill_290",
		"sm_wish"
	}
	local overkill_and_above = {
		"overkill_145",
		"easy_wish",
		"overkill_290",
		"sm_wish"
	}
	local easywish_and_above = {
		"easy_wish",
		"overkill_290",
		"sm_wish"
	}
	local deathwish_and_above = {
		"overkill_290",
		"sm_wish"
	}
	local sm_wish_and_above = {
		"sm_wish"
	}
	self.im_a_healer_tank_damage_dealer = 10
	self.iron_man = "level_7"
	self.going_places = 1000000
	self.spend_money_to_make_money = 1000000
	self.fully_loaded = 9
	self.weapon_collector = 18
	self.arms_dealer = 72
	self.how_do_you_like_me_now = "level_1"
	self.like_an_angry_bear = "bear"
	self.merry_christmas = "santa_happy"
	self.witch_doctor = {
		stat = "halloween_4_stats",
		mask = "witch"
	}
	self.its_alive_its_alive = {
		stat = "halloween_5_stats",
		mask = "frank"
	}
	self.pump_action = {
		stat = "halloween_6_stats",
		mask = "pumpkin_king"
	}
	self.cant_hear_you_scream = {
		stat = "halloween_7_stats",
		mask = "venomorph"
	}
	self.unique_selling_point = "usp"
	self.relation_with_bulldozer = {
		stat = "armored_8_stat",
		mask = "clinton"
	}
	self.no_we_cant = {
		stat = "armored_10_stat",
		mask = "obama"
	}
	self.heat_around_the_corner = "heat"
	self.fire_in_the_hole = {
		stat = "gage_9_stats",
		grenade = {
			"frag",
			"frag_com",
			"concussion",
			"dada_com"
		}
	}
	self.level_achievements = {
		you_gotta_start_somewhere = {
			award = "you_gotta_start_somewhere",
			level = 5
		},
		guilty_of_crime = {
			award = "guilty_of_crime",
			level = 10
		},
		gone_in_30_seconds = {
			award = "gone_in_30_seconds",
			level = 25
		},
		armed_and_dangerous = {
			award = "armed_and_dangerous",
			level = 50
		},
		big_shot = {
			award = "big_shot",
			level = 75
		},
		most_wanted = {
			award = "most_wanted",
			level = 100
		},
		story_basics_lvl10 = {
			story = "story_basics_lvl10",
			level = 10
		},
		story_chill_level = {
			story = "story_chill_level",
			level = 25
		},
		story_half_lvl = {
			story = "story_half_lvl",
			level = 50
		}
	}
	self.tango_4 = {
		award = "tango_achieve_4",
		count = 10,
		difficulty = overkill_and_above
	}
	self.infamous = {
		"ignominy_1",
		"ignominy_2",
		"ignominy_3",
		"ignominy_4",
		"ignominy_5",
		"ignominy_6",
		"ignominy_7",
		"ignominy_8",
		"ignominy_9",
		"ignominy_10",
		"ignominy_11",
		"ignominy_12",
		"ignominy_13",
		"ignominy_14",
		"ignominy_15",
		"ignominy_16",
		"ignominy_17",
		"ignominy_18",
		"ignominy_19",
		"ignominy_20",
		"ignominy_21",
		"ignominy_22",
		"ignominy_23",
		"ignominy_24",
		"ignominy_25"
	}
	self.final_rule = {
		heist = "nightclub",
		stat = "gage2_3_stats",
		melee_type = "fists"
	}
	self.easy_as_breathing = {
		award = "gage2_4",
		weapon_type = "lmg",
		count = 10
	}
	self.first_blood = {
		award = "gage2_5",
		count = 220,
		weapon_type = "lmg"
	}
	self.in_town_you_are_law = {
		award = "gage2_6",
		weapon_type = "shotgun"
	}
	self.dont_push_it = {
		award = "gage2_7",
		weapon = "deagle"
	}
	self.finally = {
		award = "gage2_8"
	}
	self.demise_knuckles = "brass_knuckles"
	self.vote_for_change = "g22c"
	self.steam_500k = "akm_gold"
	self.shotgun_one_o_one = {
		award = "gage4_5",
		count = 50,
		accuracy = 101
	}
	self.close_and_personal = {
		kill_type = "melee",
		count = 50,
		award = "gage4_3"
	}
	self.cavity = {
		award = "bulldog_4",
		melee_type = "toothbrush"
	}
	self.double_trouble = {
		award = "ovk_9",
		converted_cops = 4,
		difficulty = overkill_and_above
	}
	self.never_let_you_go = {
		weapon_id = "m134",
		timer = 25,
		award = "ovk_3"
	}
	self.nothing_to_see_here = {
		timer = 90,
		award = "slakt_2",
		total_value = 4
	}
	self.drive_away = "fort_2"
	self.disco_inferno = "grill_1"
	self.overgrill = "grill_4"
	self.pickup_sticks = {
		weapon_category = "bow",
		stat = "scorpion_1_stats"
	}
	self.pincushion = {
		award = "scorpion_3",
		weapon_category = "bow",
		enemy = "tank",
		count = 10
	}
	self.jordan_1 = "brooklyn_1"
	self.jordan_2 = {
		award = "brooklyn_2",
		timer = 30,
		count = 100
	}
	self.one_man_army = {
		award = "gage5_3",
		equipped = {
			secondary = "serbu",
			primary = "gre_m79",
			armor = "level_7"
		}
	}
	self.man_5 = {
		weapon_category = "grenade_launcher",
		award = "man_5",
		job = "man",
		difficulty = overkill_and_above
	}
	self.mad_5 = "mad_5"
	self.peta_4 = {
		carry_id = "goat",
		award = "peta_4",
		count = 1
	}
	self.weapons_owned = {
		gage4_2 = {
			"huntsman",
			"r870",
			"saiga",
			"ksg",
			"striker",
			"serbu",
			"benelli"
		},
		gage5_4 = {
			"gre_m79",
			"g3",
			"galil",
			"famas"
		}
	}
	self.gage_assignments = {
		green_mantis = "gmod_1_stats",
		yellow_bull = "gmod_2_stats",
		red_spider = "gmod_3_stats",
		blue_eagle = "gmod_4_stats",
		purple_snake = "gmod_5_stats"
	}
	self.gonna_find_them_all = 1
	self.weapon_blueprints = {
		gmod_7 = {
			"wpn_fps_upg_fg_jp",
			"wpn_fps_upg_m4_m_quad",
			"wpn_fps_upg_ass_ns_jprifles"
		},
		gmod_8 = {
			"wpn_fps_upg_o_rmr",
			"wpn_fps_upg_pis_ns_flash"
		},
		gmod_9 = {
			"wpn_fps_upg_fg_smr",
			"wpn_fps_upg_ass_ns_surefire",
			"wpn_fps_upg_o_eotech_xps",
			"wpn_fps_upg_m4_s_crane",
			"wpn_fps_upg_fl_ass_peq15"
		},
		gmod_10 = {
			"wpn_fps_upg_fg_midwest",
			"wpn_fps_upg_ak_b_draco",
			"wpn_fps_upg_ak_m_quad",
			"wpn_fps_upg_ass_ns_linear"
		},
		eagle_4 = {
			"wpn_fps_pis_c96_nozzle",
			"wpn_fps_pis_c96_sight"
		}
	}
	self.explosion_achievements = {
		shock_awe = {
			count = 4,
			award = "gage4_9",
			weapon_type = "shotgun"
		}
	}
	self.dot_achievements = {
		turtles_4 = {
			award = "turtles_4",
			count = 3,
			variant = "poison"
		}
	}
	self.grenade_achievements = {
		bada_boom = {
			kill = true,
			grenade_type = "launcher_frag",
			count = 4,
			award = "gage5_2"
		},
		artillery_barrage = {
			kill = true,
			grenade_type = "launcher_frag",
			distance = 4000,
			stat = "gage5_5_stats"
		},
		boom_shakalaka = {
			kill = true,
			flying_strike = true,
			award = "gage5_7",
			enemy = "spooc",
			grenade_type = "launcher_frag"
		},
		not_invited = {
			timer = 10,
			grenade_type = "launcher_frag_m32",
			award = "grill_3",
			kill_count = 10
		},
		threemite = {
			kill = true,
			grenade_type = "dynamite",
			count = 3,
			award = "scorpion_2"
		},
		steel_3 = {
			kill = true,
			grenade_type = "wpn_prj_jav",
			award = "steel_3",
			enemy = "spooc"
		},
		pim_2 = {
			kill = true,
			grenade_type = "wpn_prj_target",
			success = true,
			job = "dark",
			crouching = true,
			stat = "pim_2_stats",
			is_civilian = false
		},
		tango_2 = {
			kill = true,
			stat = "tango_2_stats",
			enemy = "sniper",
			grenade_type = "launcher_frag_arbiter"
		},
		any_kills = {
			kill = true,
			challenge_stat = "any_kills"
		},
		any_sniper_kills = {
			kill = true,
			enemy = "sniper",
			challenge_stat = "any_sniper_kills"
		},
		any_shield_kills = {
			kill = true,
			enemy = "shield",
			challenge_stat = "any_shield_kills"
		},
		any_taser_kills = {
			kill = true,
			enemy = "taser",
			challenge_stat = "any_taser_kills"
		},
		any_tank_kills = {
			kill = true,
			enemy = "tank",
			challenge_stat = "any_tank_kills"
		},
		any_spooc_kills = {
			kill = true,
			enemy = "spooc",
			challenge_stat = "any_spooc_kills"
		},
		trophy_special_kills = {
			kill = true,
			trophy_stat = "trophy_special_kills",
			enemies = {
				"sniper",
				"shield",
				"taser",
				"tank",
				"spooc",
				"medic"
			}
		},
		trophy_ace = {
			kill = true,
			trophy_stat = "trophy_ace",
			grenade_type = "wpn_prj_ace",
			difficulties = overkill_and_above
		},
		trophy_washington = {
			kill = true,
			trophy_stat = "trophy_washington"
		},
		trophy_medic = {
			kill = true,
			trophy_stat = "trophy_medic",
			enemies = {
				"medic"
			}
		},
		daily_grenades = {
			kill = true,
			trophy_stat = "daily_grenades",
			grenade_type = "frag",
			is_civilian = false
		},
		daily_grenades_community = {
			kill = true,
			trophy_stat = "daily_grenades",
			grenade_type = "frag_com",
			is_civilian = false
		},
		daily_grenades_dynamite = {
			kill = true,
			trophy_stat = "daily_grenades",
			grenade_type = "dynamite",
			is_civilian = false
		},
		daily_grenades_dada = {
			kill = true,
			trophy_stat = "daily_grenades",
			grenade_type = "dada_com",
			is_civilian = false
		},
		explosive_kills = {
			kill = true,
			explosive = true,
			challenge_stat = "explosive_kills"
		},
		cac_1 = {
			kill = true,
			grenade_type = "launcher_frag_slap",
			distance = 4000,
			enemy = "sniper",
			award = "cac_1"
		},
		cac_35 = {
			player_state = "driving",
			stat = "cac_35_stats",
			enemy_tags_all = {
				"law"
			}
		}
	}
	self.shotgun_single_shot_kills = {
		tango_1 = {
			award = "tango_achieve_1",
			count = 3,
			is_not_civilian = true,
			headshot = true,
			blueprint = {
				"wpn_fps_upg_ns_duck"
			}
		}
	}
	self.enemy_kill_achievements = {
		try_out_your_usp = {
			weapon = "usp",
			stat = "halloween_8_stats"
		},
		license_to_kill = {
			weapon = "ppk",
			stat = "armored_5_stat"
		},
		im_not_a_crook = {
			weapon = "s552",
			stat = "armored_7_stat",
			enemy = "sniper",
			mask = "nixon"
		},
		fool_me_once = {
			weapon = "m45",
			stat = "armored_9_stat",
			enemy = "shield",
			mask = "bush"
		},
		wanted = {
			weapon = "ak5",
			stat = "gage_1_stats",
			mask = "goat"
		},
		three_thousand_miles = {
			weapon = "p90",
			stat = "gage_2_stats",
			mask = "panda"
		},
		commando = {
			weapon = "aug",
			stat = "gage_3_stats",
			mask = "pitbull"
		},
		public_enemies = {
			weapon = "colt_1911",
			stat = "gage_4_stats",
			mask = "eagle"
		},
		inception = {
			weapon = "scar",
			stat = "gage_5_stats"
		},
		hard_corps = {
			weapon = "mp7",
			stat = "gage_6_stats"
		},
		above_the_law = {
			weapon = "p226",
			stat = "gage_7_stats"
		},
		surprise_motherfucker = {
			weapon = "m95",
			stat = "gage3_12_stats",
			enemy = "tank"
		},
		man_with_golden_gun = {
			weapon = "akm_gold",
			stat = "gage3_2_stats",
			enemy = "tank",
			enemy_weapon = "m249"
		},
		lord_of_flies = {
			in_head = true,
			stat = "gage3_3_stats",
			weapon_type = "snp"
		},
		arachnes_curse = {
			in_head = true,
			stat = "gage3_4_stats",
			weapon_type = "snp"
		},
		pest_control = {
			in_head = true,
			stat = "gage3_5_stats",
			weapon_type = "snp"
		},
		seer_of_death = {
			in_head = true,
			stat = "gage3_6_stats",
			weapon_type = "snp"
		},
		far_far_away = {
			weapon = "m95",
			stat = "gage3_7_stats",
			distance = 4000
		},
		last_action_villian = {
			in_head = true,
			weapon = "r93",
			award = "gage3_8",
			on_zipline = true
		},
		dodge_this = {
			in_head = true,
			stat = "gage3_11_stats",
			enemy = "spooc",
			weapon = "m95"
		},
		didnt_see_this_coming = {
			stat = "gage3_13_stats",
			weapon_type = "snp",
			on_zipline = true
		},
		grand_master_sniper = {
			weapon = "msr",
			stat = "gage3_14_stats",
			enemy = "sniper"
		},
		public_enemy_no_one = {
			weapon = "msr",
			stat = "gage3_17_stats"
		},
		knock_knock = {
			weapon_type = "shotgun",
			stat = "gage4_6_stats",
			enemy = "shield",
			part_id = "wpn_fps_upg_a_slug"
		},
		peek_a_boo = {
			weapon_type = "shotgun",
			stat = "gage4_8_stats",
			enemy = "sniper",
			part_id = "wpn_fps_upg_a_piercing"
		},
		seven_eleven = {
			count = 7,
			timer = 11,
			award = "gage4_4",
			in_head = true,
			weapon_type = "shotgun"
		},
		bang_for_buck = {
			weapon_type = "shotgun",
			stat = "gage4_10_stats",
			enemy = "tank",
			parts = {
				"wpn_fps_upg_a_custom",
				"wpn_fps_upg_a_custom_free"
			}
		},
		grind_fest = {
			weapon = "g3",
			stat = "gage5_1_stats",
			enemy = "tank"
		},
		kill_streak = {
			weapon = "galil",
			stat = "gage5_9_stats",
			enemy = "spooc"
		},
		le_picnic = {
			weapon = "famas",
			stat = "gage5_10_stats"
		},
		repel_from_rope = {
			weapon = "mosin",
			stat = "eagle_1_stats",
			on_rope = true
		},
		bullet_hell = {
			weapon = "mg42",
			timer = 10,
			award = "eagle_5",
			count = 10
		},
		akm4_shootout = {
			is_cop = true,
			stat = "ameno_08_stats",
			weapons = {
				"ak74",
				"akm",
				"akm_gold",
				"saiga",
				"rpk",
				"amcar",
				"new_m4",
				"m16",
				"akmsu",
				"olympic",
				"flint"
			}
		},
		scorpion_4 = {
			in_steelsight = false,
			timer = 6,
			award = "scorpion_4",
			weapon = "peacemaker",
			count = 6
		},
		turtles_1 = {
			weapon = "wa2000",
			award = "turtles_1",
			count_no_reload = 11
		},
		turtles_2 = {
			weapon = "polymer",
			kill_count = 100,
			award = "turtles_2"
		},
		berry_5 = {
			in_steelsight = false,
			count_in_row = 10,
			award = "berry_5",
			weapon = "model70",
			in_head = true
		},
		assault_rifle_kills = {
			weapon_type = "assault_rifle",
			challenge_stat = "assault_rifle_kills"
		},
		shotgun_kills = {
			weapon_type = "shotgun",
			challenge_stat = "shotgun_kills"
		},
		smg_kills = {
			weapon_type = "smg",
			challenge_stat = "smg_kills"
		},
		pistol_kills = {
			weapon_type = "pistol",
			challenge_stat = "pistol_kills"
		},
		lmg_kills = {
			weapon_type = "lmg",
			challenge_stat = "lmg_kills"
		},
		sniper_kills = {
			weapon_type = "snp",
			challenge_stat = "sniper_kills"
		},
		critical_kills = {
			critical = true,
			challenge_stat = "critical_kills"
		},
		explosive_kills = {
			variant = "explosion",
			challenge_stat = "explosive_kills"
		},
		sentry_kills = {
			attack_weapon_type = "sentry_gun",
			challenge_stat = "sentry_kills"
		},
		challenge_winters_mutated = {
			challenge_award = "challenge_winters_mutated",
			is_vip = true,
			mutators = {
				"MutatorHydra"
			}
		},
		any_kills = {
			challenge_stat = "any_kills"
		},
		any_headshot_kills = {
			in_head = true,
			challenge_stat = "any_headshot_kills"
		},
		any_sniper_kills = {
			enemy = "sniper",
			challenge_stat = "any_sniper_kills"
		},
		any_shield_kills = {
			enemy = "shield",
			challenge_stat = "any_shield_kills"
		},
		any_taser_kills = {
			enemy = "taser",
			challenge_stat = "any_taser_kills"
		},
		any_tank_kills = {
			enemy = "tank",
			challenge_stat = "any_tank_kills"
		},
		any_spooc_kills = {
			enemy = "spooc",
			challenge_stat = "any_spooc_kills"
		},
		trophy_headshots = {
			in_head = true,
			trophy_stat = "trophy_headshots"
		},
		trophy_washington = {
			trophy_stat = "trophy_washington"
		},
		trophy_smg = {
			timer = 25,
			trophy_stat = "trophy_smg",
			weapon_type = "smg",
			count = 25
		},
		trophy_special_kills = {
			trophy_stat = "trophy_special_kills",
			enemies = {
				"sniper",
				"shield",
				"taser",
				"tank",
				"spooc",
				"medic"
			}
		},
		trophy_medic = {
			trophy_stat = "trophy_medic",
			enemies = {
				"medic"
			}
		},
		pim_1 = {
			weapon = "desertfox",
			stat = "pim_1_stats",
			difficulty = overkill_and_above,
			enemies = {
				"sniper"
			}
		},
		pim_3 = {
			weapon = "schakal",
			level_id = "mad",
			stat = "pim_3_stats",
			difficulty = overkill_and_above,
			enemies = {
				"sniper",
				"shield",
				"taser",
				"tank",
				"spooc",
				"medic"
			}
		},
		grv_2 = {
			weapon = "coal",
			award = "grv_2",
			count_no_reload = 32
		},
		grv_3 = {
			stat = "grv_3_stats",
			weapons = {
				"siltstone",
				"flint",
				"coal"
			}
		},
		aru_2 = {
			stat = "aru_2",
			weapons = {
				"breech"
			}
		},
		aru_3 = {
			stat = "aru_3",
			weapons = {
				"erma"
			}
		},
		aru_4 = {
			stat = "aru_4",
			weapons = {
				"ching"
			}
		},
		cac_35 = {
			player_state = "driving",
			stat = "cac_35_stats",
			enemy_tags_all = {
				"law"
			}
		}
	}
	self.enemy_melee_hit_achievements = {
		cloak_n_dagger = {
			enemy = "spooc",
			melee_type = "knife",
			award = "gage2_2",
			result = "death"
		},
		are_you_kidding_me = {
			enemy = "tank",
			melee_type = "knife",
			award = "gage2_10",
			result = "death"
		},
		no_time_to_bleed = {
			health = 25,
			result = "death",
			stat = "gage2_9_stats",
			melee_type = "knife",
			enemies = {
				"fbi_swat",
				"fbi_heavy_swat"
			},
			difficulty = overkill_and_above
		},
		police_brutality = {
			enemy = "shield",
			melee_id = "baton",
			award = "gage4_1",
			result = "death"
		},
		every_day_shovelin = {
			stat = "gage4_7_stats",
			level_id = "nightclub",
			is_cop = true,
			result = "death",
			melee_id = "shovel"
		},
		cant_touch_this = {
			melee_id = "dingdong",
			stat = "gage5_8_stats",
			is_gangster = true,
			result = "death"
		},
		hurting_people = {
			melee_id = "baseballbat",
			result = "death",
			stat = "pig_3_stats",
			enemies = {
				"mobster",
				"mobster_boss",
				"biker_boss"
			},
			jobs = {
				"mia"
			}
		},
		special_operations = {
			stat = "eagle_2_stats",
			melee_id = "fairbair",
			is_stealth = true,
			result = "death",
			is_not_civilian = true
		},
		knockout = {
			enemy = "tank",
			melee_id = "boxing_gloves",
			award = "gorilla_1",
			result = "death"
		},
		stick_a_fork_in_me = {
			is_not_civilian = true,
			award = "grill_2",
			result = "death",
			melee_id = "fork",
			is_on_fire = true
		},
		steel_2 = {
			award = "steel_2",
			result = "death",
			melee_weapons = {
				"morning",
				"buck",
				"beardy",
				"great"
			},
			enemy_kills = {
				enemy = "shield",
				count = 10
			}
		},
		steel_4 = {
			enemy = "tank",
			enemy_weapon = "saiga",
			award = "steel_4",
			result = "death",
			melee_id = "great"
		},
		melee_kills = {
			result = "death",
			is_not_civilian = true,
			challenge_stat = "melee_kills"
		},
		any_kills = {
			result = "death",
			is_not_civilian = true,
			challenge_stat = "any_kills"
		},
		any_sniper_kills = {
			result = "death",
			is_not_civilian = true,
			enemy = "sniper",
			challenge_stat = "any_sniper_kills"
		},
		any_shield_kills = {
			result = "death",
			is_not_civilian = true,
			enemy = "shield",
			challenge_stat = "any_shield_kills"
		},
		any_taser_kills = {
			result = "death",
			is_not_civilian = true,
			enemy = "taser",
			challenge_stat = "any_taser_kills"
		},
		any_tank_kills = {
			result = "death",
			is_not_civilian = true,
			enemy = "tank",
			challenge_stat = "any_tank_kills"
		},
		any_spooc_kills = {
			result = "death",
			is_not_civilian = true,
			enemy = "spooc",
			challenge_stat = "any_spooc_kills"
		},
		trophy_knockouts = {
			trophy_stat = "trophy_knockouts",
			is_not_civilian = true,
			result = "death",
			melee_id = "boxing_gloves",
			enemies = {
				"tank",
				"tank_hw"
			}
		},
		trophy_washington = {
			is_not_civilian = true,
			trophy_stat = "trophy_washington",
			result = "death"
		},
		trophy_medic = {
			is_not_civilian = true,
			trophy_stat = "trophy_medic",
			enemy = "medic",
			result = "death"
		},
		trophy_special_kills = {
			trophy_stat = "trophy_special_kills",
			is_not_civilian = true,
			result = "death",
			enemies = {
				"sniper",
				"shield",
				"taser",
				"tank",
				"spooc",
				"medic"
			}
		},
		daily_hangover = {
			melee_id = "whiskey",
			trophy_stat = "daily_hangover",
			is_not_civilian = true,
			result = "death"
		},
		raid_aru_1 = {
			melee_id = "push",
			stat = "aru_1",
			is_not_civilian = true,
			result = "death"
		},
		critical_kills = {
			critical = true,
			is_not_civilian = true,
			result = "death",
			challenge_stat = "critical_kills"
		},
		challenge_melee_creeps = {
			result = "death",
			is_not_civilian = true,
			challenge_stat = "challenge_melee_creeps",
			mutators = {
				"MutatorExplodingEnemies"
			}
		},
		rvd_12 = {
			job = "rvd",
			melee_id = "clean",
			result = "death",
			stat = "rvd_12_stats",
			difficulty = overkill_and_above,
			enemy_tags_all = {
				"special"
			}
		},
		cac_6 = {
			award = "cac_6",
			melee_id = "moneybundle",
			enemy = "cop_female",
			job = "rvd"
		},
		cac_14 = {
			melee_id = "baton",
			award = "cac_14",
			result = "death",
			enemy_tags_all = {
				"spooc"
			}
		},
		cac_25 = {
			award = "cac_25",
			melee_id = "moneybundle",
			enemy = "bank_manager",
			job = "red2"
		},
		cac_29 = {
			award = "cac_29",
			result = "death",
			enemy_tags_all = {
				"sniper"
			}
		},
		cac_32 = {
			award = "cac_32",
			enemy_tags_all = {
				"spooc"
			},
			melee_weapons = {
				"taser",
				"zeus"
			},
			action = {
				body_part = 1,
				type = "spooc"
			}
		},
		cac_36 = {
			award = "cac_36",
			result = "death",
			enemy_tags_all = {
				"taser"
			},
			melee_weapons = {
				"taser",
				"zeus"
			}
		},
		bph_9 = {
			melee_id = "toothbrush",
			result = "death",
			stat = "bph_9_stat",
			is_dropin = false,
			difficulty = overkill_and_above
		}
	}
	self.complete_heist_achievements = {
		in_soviet_russia = {
			contract = "vlad",
			stat = "halloween_10_stats",
			mask = "bear",
			difficulty = overkill_and_above
		},
		i_take_scores = {
			stat = "armored_4_stat",
			mask = "heat",
			difficulty = overkill_and_above,
			jobs = {
				"arm_cro",
				"arm_und",
				"arm_hcm",
				"arm_par",
				"arm_fac"
			}
		},
		eco_round = {
			award = "charliesierra_7",
			no_shots = "primaries",
			job = "roberts",
			difficulty = overkill_and_above
		},
		stealth_election_day = {
			stealth = true,
			award = "bob_3",
			job = "election_day"
		},
		death_stealth_election_day = {
			award = "bob_7",
			stealth = true,
			job = "election_day",
			difficulty = deathwish_and_above
		},
		easywish_ukranian = {
			award = "pick_1",
			job = "ukrainian_job_prof",
			difficulty = easywish_and_above
		},
		easywish_mallcrasher = {
			award = "pick_2",
			job = "mallcrasher",
			difficulty = easywish_and_above
		},
		easywish_four_stores = {
			award = "pick_3",
			job = "four_stores",
			difficulty = easywish_and_above
		},
		easywish_nightclub = {
			award = "pick_4",
			job = "nightclub",
			difficulty = easywish_and_above
		},
		easywish_watchdogs = {
			award = "pick_5",
			difficulty = easywish_and_above,
			jobs = {
				"watchdogs_wrapper",
				"watchdogs_night",
				"watchdogs"
			}
		},
		easywish_rats = {
			award = "pick_7",
			job = "alex",
			difficulty = easywish_and_above
		},
		easywish_firestarter = {
			award = "pick_9",
			job = "firestarter",
			difficulty = easywish_and_above
		},
		easywish_framing_frame = {
			award = "pick_11",
			job = "framing_frame",
			difficulty = easywish_and_above
		},
		easywish_big_oil = {
			award = "pick_13",
			difficulty = easywish_and_above,
			jobs = {
				"welcome_to_the_jungle_wrapper_prof",
				"welcome_to_the_jungle_night_prof",
				"welcome_to_the_jungle_prof"
			}
		},
		easywish_jewelry_store = {
			award = "pick_14",
			job = "jewelry_store",
			difficulty = easywish_and_above
		},
		easywish_diamond_store = {
			award = "pick_15",
			job = "family",
			difficulty = easywish_and_above
		},
		easywish_go_bank = {
			award = "pick_16",
			job = "roberts",
			difficulty = easywish_and_above
		},
		easywish_bank_heist = {
			award = "pick_17",
			job = "branchbank_prof",
			difficulty = easywish_and_above
		},
		easywish_bank_heist_gold = {
			award = "pick_18",
			job = "branchbank_gold_prof",
			difficulty = easywish_and_above
		},
		easywish_bank_heist_cash = {
			award = "pick_19",
			job = "branchbank_cash",
			difficulty = easywish_and_above
		},
		easywish_bank_heist_deposit = {
			award = "pick_20",
			job = "branchbank_deposit",
			difficulty = easywish_and_above
		},
		easywish_transport_crossroads = {
			award = "pick_21",
			job = "arm_cro",
			difficulty = easywish_and_above
		},
		easywish_transport_downtown = {
			award = "pick_22",
			job = "arm_hcm",
			difficulty = easywish_and_above
		},
		easywish_transport_harbor = {
			award = "pick_23",
			job = "arm_fac",
			difficulty = easywish_and_above
		},
		easywish_transport_park = {
			award = "pick_24",
			job = "arm_par",
			difficulty = easywish_and_above
		},
		easywish_transport_underpass = {
			award = "pick_25",
			job = "arm_und",
			difficulty = easywish_and_above
		},
		easywish_transport_train = {
			award = "pick_26",
			job = "arm_for",
			difficulty = easywish_and_above
		},
		easywish_election_day = {
			award = "pick_27",
			job = "election_day",
			difficulty = easywish_and_above
		},
		easywish_kosugi = {
			award = "pick_29",
			job = "kosugi",
			difficulty = easywish_and_above
		},
		easywish_bigbank = {
			award = "pick_30",
			job = "big",
			difficulty = easywish_and_above
		},
		easywish_miami = {
			award = "pick_31",
			job = "mia",
			difficulty = easywish_and_above
		},
		easywish_artgallery = {
			award = "pick_33",
			job = "gallery",
			difficulty = easywish_and_above
		},
		easywish_hoxton = {
			award = "pick_34",
			job = "hox",
			difficulty = easywish_and_above
		},
		easywish_mus = {
			award = "pick_36",
			job = "mus",
			difficulty = easywish_and_above
		},
		easywish_red = {
			award = "pick_37",
			job = "red2",
			difficulty = easywish_and_above
		},
		easywish_dinner = {
			award = "pick_38",
			job = "dinner",
			difficulty = easywish_and_above
		},
		easywish_hox_3 = {
			award = "pick_39",
			job = "hox_3",
			difficulty = easywish_and_above
		},
		easywish_rat = {
			award = "pick_40",
			job = "rat",
			difficulty = easywish_and_above
		},
		easywish_cage = {
			award = "pick_41",
			job = "cage",
			difficulty = easywish_and_above
		},
		easywish_shoutout = {
			award = "pick_42",
			job = "shoutout_raid",
			difficulty = easywish_and_above
		},
		easywish_arena = {
			award = "pick_43",
			job = "arena",
			difficulty = easywish_and_above
		},
		easywish_kenaz = {
			award = "pick_44",
			difficulty = easywish_and_above,
			jobs = {
				"kenaz"
			}
		},
		easywish_sinus = {
			award = "pick_45",
			job = "jolly",
			difficulty = easywish_and_above
		},
		easywish_nails = {
			award = "pick_46",
			job = "nail",
			difficulty = easywish_and_above
		},
		easywish_berry = {
			award = "pick_47",
			job = "pbr",
			difficulty = easywish_and_above
		},
		easywish_jerry = {
			award = "pick_48",
			job = "pbr2",
			difficulty = easywish_and_above
		},
		easywish_peta = {
			award = "pick_49",
			difficulty = easywish_and_above,
			jobs = {
				"peta"
			}
		},
		easywish_pal = {
			award = "pick_51",
			job = "pal",
			difficulty = easywish_and_above
		},
		easywish_man = {
			award = "pick_52",
			job = "man",
			difficulty = easywish_and_above
		},
		easywish_dark = {
			award = "pick_53",
			job = "dark",
			difficulty = easywish_and_above
		},
		easywish_cane = {
			award = "pick_54",
			job = "cane",
			difficulty = easywish_and_above
		},
		easywish_flat = {
			award = "pick_55",
			job = "flat",
			difficulty = easywish_and_above
		},
		easywish_mad = {
			award = "pick_56",
			job = "mad",
			difficulty = easywish_and_above
		},
		easywish_born = {
			award = "pick_57",
			job = "born",
			difficulty = easywish_and_above
		},
		easywish_help = {
			award = "orange_1",
			job = "help",
			difficulty = easywish_and_above
		},
		easywish_moon = {
			award = "moon_1",
			job = "moon",
			difficulty = easywish_and_above
		},
		easywish_friend = {
			award = "friend_1",
			job = "friend",
			difficulty = easywish_and_above
		},
		easywish_spa = {
			award = "spa_1",
			job = "spa",
			difficulty = easywish_and_above
		},
		easywish_fish = {
			award = "fish_1",
			job = "fish",
			difficulty = easywish_and_above
		},
		easywish_glace = {
			award = "glace_5",
			job = "glace",
			difficulty = easywish_and_above
		},
		easywish_run = {
			award = "run_5",
			job = "run",
			difficulty = easywish_and_above
		},
		complete_pines_easywish = {
			award = "pick_59",
			difficulty = easywish_and_above,
			jobs = {
				"pines"
			}
		},
		complete_crojob_dock_easywish = {
			award = "pick_61",
			difficulty = easywish_and_above,
			jobs = {
				"crojob1"
			}
		},
		complete_crojob_for_easywish = {
			award = "pick_60",
			difficulty = easywish_and_above,
			jobs = {
				"crojob_wrapper",
				"crojob2",
				"crojob2_night"
			}
		},
		death_ukranian = {
			award = "death_1",
			job = "ukrainian_job_prof",
			difficulty = deathwish_and_above
		},
		death_mallcrasher = {
			award = "death_2",
			job = "mallcrasher",
			difficulty = deathwish_and_above
		},
		death_four_stores = {
			award = "death_3",
			job = "four_stores",
			difficulty = deathwish_and_above
		},
		death_nightclub = {
			award = "death_4",
			job = "nightclub",
			difficulty = deathwish_and_above
		},
		death_watchdogs = {
			award = "death_34",
			difficulty = deathwish_and_above,
			jobs = {
				"watchdogs_wrapper",
				"watchdogs_night",
				"watchdogs"
			}
		},
		death_rats = {
			award = "death_33",
			job = "alex",
			difficulty = deathwish_and_above
		},
		death_firestarter = {
			award = "death_32",
			job = "firestarter",
			difficulty = deathwish_and_above
		},
		death_framing_frame = {
			award = "death_35",
			job = "framing_frame",
			difficulty = deathwish_and_above
		},
		death_big_oil = {
			award = "death_11",
			difficulty = deathwish_and_above,
			jobs = {
				"welcome_to_the_jungle_wrapper_prof",
				"welcome_to_the_jungle_night_prof",
				"welcome_to_the_jungle_prof"
			}
		},
		death_jewelry_store = {
			award = "death_13",
			job = "jewelry_store",
			difficulty = deathwish_and_above
		},
		death_diamond_store = {
			award = "death_14",
			job = "family",
			difficulty = deathwish_and_above
		},
		death_go_bank = {
			award = "death_15",
			job = "roberts",
			difficulty = deathwish_and_above
		},
		death_bank_heist = {
			award = "death_16",
			job = "branchbank_prof",
			difficulty = deathwish_and_above
		},
		death_bank_heist_gold = {
			award = "death_17",
			job = "branchbank_gold_prof",
			difficulty = deathwish_and_above
		},
		death_bank_heist_cash = {
			award = "death_18",
			job = "branchbank_cash",
			difficulty = deathwish_and_above
		},
		death_bank_heist_deposit = {
			award = "death_19",
			job = "branchbank_deposit",
			difficulty = deathwish_and_above
		},
		death_transport_crossroads = {
			award = "death_20",
			job = "arm_cro",
			difficulty = deathwish_and_above
		},
		death_transport_downtown = {
			award = "death_21",
			job = "arm_hcm",
			difficulty = deathwish_and_above
		},
		death_transport_harbor = {
			award = "death_22",
			job = "arm_fac",
			difficulty = deathwish_and_above
		},
		death_transport_park = {
			award = "death_23",
			job = "arm_par",
			difficulty = deathwish_and_above
		},
		death_transport_underpass = {
			award = "death_24",
			job = "arm_und",
			difficulty = deathwish_and_above
		},
		death_transport_train = {
			award = "death_25",
			job = "arm_for",
			difficulty = deathwish_and_above
		},
		death_election_day = {
			award = "bob_9",
			job = "election_day",
			difficulty = deathwish_and_above
		},
		death_kosugi = {
			award = "kosugi_6",
			job = "kosugi",
			difficulty = deathwish_and_above
		},
		death_bigbank = {
			award = "bigbank_9",
			job = "big",
			difficulty = deathwish_and_above
		},
		death_miami = {
			award = "pig_1",
			job = "mia",
			difficulty = deathwish_and_above
		},
		death_artgallery = {
			award = "squek",
			job = "gallery",
			difficulty = deathwish_and_above
		},
		death_hoxton = {
			award = "bulldog_2",
			job = "hox",
			difficulty = deathwish_and_above
		},
		death_mus = {
			award = "bat_1",
			job = "mus",
			difficulty = deathwish_and_above
		},
		death_red = {
			award = "green_5",
			job = "red2",
			difficulty = deathwish_and_above
		},
		death_dinner = {
			award = "farm_5",
			job = "dinner",
			difficulty = deathwish_and_above
		},
		death_hox_3 = {
			award = "payback_1",
			job = "hox_3",
			difficulty = deathwish_and_above
		},
		death_rat = {
			award = "djur_1",
			job = "rat",
			difficulty = deathwish_and_above
		},
		death_cage = {
			award = "fort_1",
			job = "cage",
			difficulty = deathwish_and_above
		},
		death_shoutout = {
			award = "melt_1",
			job = "shoutout_raid",
			difficulty = deathwish_and_above
		},
		death_arena = {
			award = "live_1",
			job = "arena",
			difficulty = deathwish_and_above
		},
		death_kenaz = {
			award = "kenaz_1",
			difficulty = deathwish_and_above,
			jobs = {
				"kenaz"
			}
		},
		death_sinus = {
			award = "sinus_2",
			job = "jolly",
			difficulty = deathwish_and_above
		},
		death_nails = {
			award = "lab_3",
			job = "nail",
			difficulty = deathwish_and_above
		},
		death_berry = {
			award = "berry_1",
			job = "pbr",
			difficulty = deathwish_and_above
		},
		death_jerry = {
			award = "jerry_1",
			job = "pbr2",
			difficulty = deathwish_and_above
		},
		death_peta = {
			award = "peta_1",
			difficulty = deathwish_and_above,
			jobs = {
				"peta"
			}
		},
		death_pal = {
			award = "pal_1",
			job = "pal",
			difficulty = deathwish_and_above
		},
		death_man = {
			award = "man_1",
			job = "man",
			difficulty = deathwish_and_above
		},
		death_dark = {
			award = "dark_1",
			job = "dark",
			difficulty = deathwish_and_above
		},
		death_cane = {
			award = "cane_1",
			job = "cane",
			difficulty = deathwish_and_above
		},
		death_flat = {
			award = "flat_1",
			job = "flat",
			difficulty = deathwish_and_above
		},
		death_mad = {
			award = "mad_1",
			job = "mad",
			difficulty = deathwish_and_above
		},
		death_born = {
			award = "born_1",
			job = "born",
			difficulty = deathwish_and_above
		},
		death_help = {
			award = "orange_2",
			job = "help",
			difficulty = deathwish_and_above
		},
		death_moon = {
			award = "moon_2",
			job = "moon",
			difficulty = deathwish_and_above
		},
		death_friend = {
			award = "friend_2",
			job = "friend",
			difficulty = deathwish_and_above
		},
		death_spa = {
			award = "spa_2",
			job = "spa",
			difficulty = deathwish_and_above
		},
		death_fish = {
			award = "fish_2",
			job = "fish",
			difficulty = deathwish_and_above
		},
		death_glace = {
			award = "glace_6",
			job = "glace",
			difficulty = deathwish_and_above
		},
		death_run = {
			award = "run_6",
			job = "run",
			difficulty = deathwish_and_above
		},
		complete_pines_deathwish = {
			award = "deer_5",
			difficulty = deathwish_and_above,
			jobs = {
				"pines"
			}
		},
		complete_crojob_for_deathwish = {
			award = "cow_2",
			difficulty = deathwish_and_above,
			jobs = {
				"crojob_wrapper",
				"crojob2",
				"crojob2_night"
			}
		},
		complete_crojob_dock_deathwish = {
			award = "cow_7",
			difficulty = deathwish_and_above,
			jobs = {
				"crojob1"
			}
		},
		sm_wish_ukranian = {
			award = "axe_1",
			one_down = true,
			job = "ukrainian_job_prof",
			difficulty = sm_wish_and_above
		},
		sm_wish_mallcrasher = {
			award = "axe_2",
			one_down = true,
			job = "mallcrasher",
			difficulty = sm_wish_and_above
		},
		sm_wish_four_stores = {
			award = "axe_3",
			one_down = true,
			job = "four_stores",
			difficulty = sm_wish_and_above
		},
		sm_wish_nightclub = {
			award = "axe_4",
			one_down = true,
			job = "nightclub",
			difficulty = sm_wish_and_above
		},
		sm_wish_watchdogs = {
			award = "axe_5",
			one_down = true,
			difficulty = sm_wish_and_above,
			jobs = {
				"watchdogs_wrapper",
				"watchdogs_night",
				"watchdogs"
			}
		},
		sm_wish_rats = {
			award = "axe_7",
			one_down = true,
			job = "alex",
			difficulty = sm_wish_and_above
		},
		sm_wish_firestarter = {
			award = "axe_9",
			one_down = true,
			job = "firestarter",
			difficulty = sm_wish_and_above
		},
		sm_wish_framing_frame = {
			award = "axe_11",
			one_down = true,
			job = "framing_frame",
			difficulty = sm_wish_and_above
		},
		sm_wish_big_oil = {
			award = "axe_13",
			one_down = true,
			difficulty = sm_wish_and_above,
			jobs = {
				"welcome_to_the_jungle_wrapper_prof",
				"welcome_to_the_jungle_night_prof",
				"welcome_to_the_jungle_prof"
			}
		},
		sm_wish_jewelry_store = {
			award = "axe_14",
			one_down = true,
			job = "jewelry_store",
			difficulty = sm_wish_and_above
		},
		sm_wish_diamond_store = {
			award = "axe_15",
			one_down = true,
			job = "family",
			difficulty = sm_wish_and_above
		},
		sm_wish_go_bank = {
			award = "axe_16",
			one_down = true,
			job = "roberts",
			difficulty = sm_wish_and_above
		},
		sm_wish_bank_heist = {
			award = "axe_17",
			one_down = true,
			job = "branchbank_prof",
			difficulty = sm_wish_and_above
		},
		sm_wish_bank_heist_gold = {
			award = "axe_18",
			one_down = true,
			job = "branchbank_gold_prof",
			difficulty = sm_wish_and_above
		},
		sm_wish_bank_heist_cash = {
			award = "axe_19",
			one_down = true,
			job = "branchbank_cash",
			difficulty = sm_wish_and_above
		},
		sm_wish_bank_heist_deposit = {
			award = "axe_20",
			one_down = true,
			job = "branchbank_deposit",
			difficulty = sm_wish_and_above
		},
		sm_wish_transport_crossroads = {
			award = "axe_21",
			one_down = true,
			job = "arm_cro",
			difficulty = sm_wish_and_above
		},
		sm_wish_transport_downtown = {
			award = "axe_22",
			one_down = true,
			job = "arm_hcm",
			difficulty = sm_wish_and_above
		},
		sm_wish_transport_harbor = {
			award = "axe_23",
			one_down = true,
			job = "arm_fac",
			difficulty = sm_wish_and_above
		},
		sm_wish_transport_park = {
			award = "axe_24",
			one_down = true,
			job = "arm_par",
			difficulty = sm_wish_and_above
		},
		sm_wish_transport_underpass = {
			award = "axe_25",
			one_down = true,
			job = "arm_und",
			difficulty = sm_wish_and_above
		},
		sm_wish_transport_train = {
			award = "axe_26",
			one_down = true,
			job = "arm_for",
			difficulty = sm_wish_and_above
		},
		sm_wish_election_day = {
			award = "axe_27",
			one_down = true,
			job = "election_day",
			difficulty = sm_wish_and_above
		},
		sm_wish_kosugi = {
			award = "axe_29",
			one_down = true,
			job = "kosugi",
			difficulty = sm_wish_and_above
		},
		sm_wish_bigbank = {
			award = "axe_30",
			one_down = true,
			job = "big",
			difficulty = sm_wish_and_above
		},
		sm_wish_miami = {
			award = "axe_31",
			one_down = true,
			job = "mia",
			difficulty = sm_wish_and_above
		},
		sm_wish_artgallery = {
			award = "axe_33",
			one_down = true,
			job = "gallery",
			difficulty = sm_wish_and_above
		},
		sm_wish_hoxton = {
			award = "axe_34",
			one_down = true,
			job = "hox",
			difficulty = sm_wish_and_above
		},
		sm_wish_mus = {
			award = "axe_36",
			one_down = true,
			job = "mus",
			difficulty = sm_wish_and_above
		},
		sm_wish_red = {
			award = "axe_37",
			one_down = true,
			job = "red2",
			difficulty = sm_wish_and_above
		},
		sm_wish_dinner = {
			award = "axe_38",
			one_down = true,
			job = "dinner",
			difficulty = sm_wish_and_above
		},
		sm_wish_hox_3 = {
			award = "axe_39",
			one_down = true,
			job = "hox_3",
			difficulty = sm_wish_and_above
		},
		sm_wish_rat = {
			award = "axe_40",
			one_down = true,
			job = "rat",
			difficulty = sm_wish_and_above
		},
		sm_wish_cage = {
			award = "axe_41",
			one_down = true,
			job = "cage",
			difficulty = sm_wish_and_above
		},
		sm_wish_shoutout = {
			award = "axe_42",
			one_down = true,
			job = "shoutout_raid",
			difficulty = sm_wish_and_above
		},
		sm_wish_arena = {
			award = "axe_43",
			one_down = true,
			job = "arena",
			difficulty = sm_wish_and_above
		},
		sm_wish_kenaz = {
			award = "axe_44",
			one_down = true,
			difficulty = sm_wish_and_above,
			jobs = {
				"kenaz"
			}
		},
		sm_wish_sinus = {
			one_down = true,
			award = "axe_45",
			job = "jolly",
			difficulty = sm_wish_and_above
		},
		sm_wish_nails = {
			one_down = true,
			award = "axe_46",
			job = "nail",
			difficulty = sm_wish_and_above
		},
		sm_wish_berry = {
			award = "axe_47",
			one_down = true,
			job = "pbr",
			difficulty = sm_wish_and_above
		},
		sm_wish_jerry = {
			award = "axe_48",
			one_down = true,
			job = "pbr2",
			difficulty = sm_wish_and_above
		},
		sm_wish_peta = {
			award = "axe_49",
			one_down = true,
			difficulty = sm_wish_and_above,
			jobs = {
				"peta"
			}
		},
		sm_wish_pal = {
			award = "axe_51",
			one_down = true,
			job = "pal",
			difficulty = sm_wish_and_above
		},
		sm_wish_man = {
			award = "axe_52",
			one_down = true,
			job = "man",
			difficulty = sm_wish_and_above
		},
		sm_wish_dark = {
			award = "axe_53",
			one_down = true,
			job = "dark",
			difficulty = sm_wish_and_above
		},
		sm_wish_cane = {
			award = "axe_54",
			one_down = true,
			job = "cane",
			difficulty = sm_wish_and_above
		},
		sm_wish_flat = {
			award = "axe_55",
			one_down = true,
			job = "flat",
			difficulty = sm_wish_and_above
		},
		sm_wish_mad = {
			award = "axe_56",
			one_down = true,
			job = "mad",
			difficulty = sm_wish_and_above
		},
		sm_wish_born = {
			award = "axe_57",
			one_down = true,
			job = "born",
			difficulty = sm_wish_and_above
		},
		sm_wish_help = {
			award = "orange_3",
			one_down = true,
			job = "help",
			difficulty = sm_wish_and_above
		},
		sm_wish_moon = {
			award = "moon_3",
			one_down = true,
			job = "moon",
			difficulty = sm_wish_and_above
		},
		sm_wish_friend = {
			award = "friend_3",
			one_down = true,
			job = "friend",
			difficulty = sm_wish_and_above
		},
		sm_wish_spa = {
			award = "spa_3",
			one_down = true,
			job = "spa",
			difficulty = sm_wish_and_above
		},
		sm_wish_fish = {
			award = "fish_3",
			one_down = true,
			job = "fish",
			difficulty = sm_wish_and_above
		},
		sm_wish_glace = {
			award = "glace_7",
			one_down = true,
			job = "glace",
			difficulty = sm_wish_and_above
		},
		sm_wish_run = {
			award = "run_7",
			one_down = true,
			job = "run",
			difficulty = sm_wish_and_above
		},
		complete_pines_sm_wish = {
			award = "axe_59",
			one_down = true,
			difficulty = sm_wish_and_above,
			jobs = {
				"pines"
			}
		},
		complete_crojob_for_sm_wish = {
			award = "axe_60",
			one_down = true,
			difficulty = sm_wish_and_above,
			jobs = {
				"crojob_wrapper",
				"crojob2",
				"crojob2_night"
			}
		},
		complete_crojob_dock_sm_wish = {
			award = "axe_61",
			one_down = true,
			difficulty = sm_wish_and_above,
			jobs = {
				"crojob1"
			}
		},
		complete_hoxton = {
			award = "bulldog_1",
			jobs = {
				"hox"
			}
		},
		complete_pines_normal = {
			award = "deer_1",
			difficulty = normal_and_above,
			jobs = {
				"pines"
			}
		},
		complete_pines_hard = {
			award = "deer_2",
			difficulty = hard_and_above,
			jobs = {
				"pines"
			}
		},
		complete_pines_veryhard = {
			award = "deer_3",
			difficulty = veryhard_and_above,
			jobs = {
				"pines"
			}
		},
		complete_pines_overkill = {
			award = "deer_4",
			difficulty = overkill_and_above,
			jobs = {
				"pines"
			}
		},
		complete_crojob_for_all = {
			award = "cow_1",
			difficulty = normal_and_above,
			jobs = {
				"crojob_wrapper",
				"crojob2",
				"crojob2_night"
			}
		},
		complete_crojob_dock_all = {
			award = "cow_6",
			difficulty = normal_and_above,
			jobs = {
				"crojob1"
			}
		},
		melt_2 = {
			award = "melt_2",
			job = "shoutout_raid",
			difficulty = normal_and_above
		},
		farm_1 = {
			phalanx_vip_alive = true,
			award = "farm_1",
			job = "dinner",
			difficulty = overkill_and_above
		},
		hox_3_silent = {
			stealth = true,
			award = "payback_2",
			job = "hox_3"
		},
		owe_saw = {
			award = "ameno_1",
			job = "nightclub",
			equipped_team = {
				secondary = "wpn_fps_saw_secondary",
				primary = "wpn_fps_saw"
			}
		},
		pain_train = {
			loud = true,
			num_players = 4,
			award = "ameno_4",
			need_full_job = true,
			jobs = {
				"firestarter"
			},
			difficulty = overkill_and_above,
			equipped_team = {
				secondary_unmodded = true,
				primary_unmodded = true,
				primaries = {
					"wpn_fps_ass_74"
				},
				secondaries = {
					"wpn_fps_smg_olympic"
				}
			}
		},
		turtle_wins = {
			timer = 240,
			stealth = true,
			award = "ameno_6",
			job = "gallery",
			equipped_team = {
				reverse_deployable = true,
				armor = "level_7",
				deployable = "armor_kit"
			}
		},
		anticimex = {
			num_players = 4,
			award = "ovk_1",
			need_full_job = true,
			jobs = {
				"alex"
			},
			difficulty = overkill_and_above,
			equipped_team = {
				armor = "level_6",
				mask = "the_overkill_mask",
				primaries = {
					"wpn_fps_lmg_m134"
				},
				secondaries = {
					"wpn_fps_rpg7"
				}
			}
		},
		modern_ninja = {
			stealth = true,
			award = "ovk_2",
			job = "kosugi",
			equipped = {
				primaries = {
					weapon_id = "m134"
				},
				secondaries = {
					weapon_id = "rpg7"
				}
			}
		},
		newbee = {
			award = "ovk_4",
			need_full_job = true,
			jobs = {
				"watchdogs_wrapper"
			},
			difficulty = overkill_and_above,
			equipped_team = {
				num_skills = 0,
				primaries = {
					"wpn_fps_ass_amcar"
				},
				secondaries = {
					"wpn_fps_pis_g17"
				}
			}
		},
		intel_thief = {
			award = "ovk_6",
			stealth = true,
			levels = {
				"welcome_to_the_jungle_1",
				"welcome_to_the_jungle_1_night"
			},
			difficulty = overkill_and_above
		},
		ovk_8 = {
			num_players = 2,
			award = "ovk_8",
			need_full_job = true,
			jobs = {
				"welcome_to_the_jungle_wrapper_prof"
			},
			difficulty = overkill_and_above,
			equipped_team = {
				armor = "level_1",
				primaries = {
					"wpn_fps_x_b92fs"
				}
			}
		},
		kenaz_silent = {
			stealth = true,
			award = "kenaz_2",
			jobs = {
				"kenaz"
			}
		},
		kenaz_timed = {
			timer = 840,
			award = "kenaz_4",
			jobs = {
				"kenaz"
			}
		},
		not_for_old_men = {
			stealth = true,
			award = "gage4_11",
			equipped = {
				secondaries = {
					weapon_id = "serbu",
					blueprint = {
						{
							"wpn_fps_upg_ns_shot_thick"
						}
					}
				}
			}
		},
		turtles_3 = {
			killed_by_weapons = 0,
			stealth = true,
			award = "turtles_3",
			killed_by_melee = 0,
			killed_by_grenade = 4,
			civilians_killed = 0,
			equipped = {
				grenades = "wpn_prj_four"
			}
		},
		jordan_3 = {
			award = "brooklyn_3",
			memory = {
				is_shortterm = false
			}
		},
		jordan_4 = {
			jump_timer = 4,
			award = "brooklyn_4",
			memory = {
				value = true,
				is_shortterm = false
			}
		},
		steel_1 = {
			num_players = 4,
			award = "steel_1",
			need_full_job = true,
			difficulty = overkill_and_above,
			equipped_team = {
				primaries = {
					"wpn_fps_bow_long",
					"wpn_fps_bow_frankish",
					"wpn_fps_bow_arblast"
				},
				masks = {
					"mason_knight_veteran",
					"agatha_knight",
					"agatha_vanguard_veteran",
					"mason_vanguard_veteran"
				},
				armors = {
					"level_3",
					"level_4",
					"level_5",
					"level_6",
					"level_7"
				},
				melee_weapons = {
					"morning",
					"buck",
					"beardy",
					"great"
				}
			}
		},
		green_2 = {
			num_players = 4,
			award = "green_2",
			job = "red2",
			difficulty = overkill_and_above,
			equipped_team = {
				primaries = {
					"wpn_fps_shot_r870"
				},
				secondaries = {
					"wpn_fps_pis_beretta"
				},
				characters = {
					"russian",
					"german",
					"spanish",
					"old_hoxton"
				}
			}
		},
		jerry_5 = {
			award = "jerry_5",
			job = "pbr2",
			difficulty = overkill_and_above,
			equipped_team = {
				secondary_category = "pistol",
				armor = "level_1",
				primary_category = "akimbo"
			}
		},
		cane_4 = {
			award = "cane_4",
			job = "cane",
			equipped_team = {
				secondary_category = "shotgun",
				primary_category = "shotgun"
			}
		},
		mad_3 = {
			award = "mad_3",
			job = "mad",
			difficulty = veryhard_and_above,
			memory = {
				value = true,
				is_shortterm = false
			}
		},
		mad_4 = {
			award = "mad_4",
			job = "mad",
			difficulty = overkill_and_above,
			equipped_team = {
				primaries = {
					"wpn_fps_ass_akm_gold"
				},
				masks = {
					"rus_hat"
				}
			}
		},
		flake_1 = {
			award = "flake_1",
			need_full_job = true,
			jobs = {
				"framing_frame"
			},
			difficulty = overkill_and_above,
			equipped_team = {
				num_skills = 0,
				armor = "level_1",
				primaries = {
					"wpn_fps_snp_model70"
				},
				secondaries = {
					"wpn_fps_pis_judge"
				}
			}
		},
		pim_4 = {
			everyone_killed_by_melee = 0,
			award = "pim_4",
			job = "firestarter",
			need_full_job = true,
			everyone_killed_by_grenade = 0,
			difficulty = overkill_and_above,
			shots_by_weapon = {
				"packrat",
				"x_packrat"
			}
		},
		orange_6 = {
			award = "orange_6",
			job = "help",
			need_full_job = true,
			everyone_killed_by_grenade = 0,
			everyone_killed_by_weapons = 0,
			difficulty = hard_and_above,
			characters = {
				"old_hoxton"
			},
			equipped_team = {
				melee_weapons = {
					"toothbrush"
				}
			}
		},
		tango_3 = {
			award = "tango_achieve_3",
			difficulty = veryhard_and_above,
			killed_by_blueprint = {
				blueprint = "wpn_fps_upg_o_spot",
				amount = 200
			}
		},
		spa_4 = {
			award = "spa_4",
			job = "spa",
			need_full_job = true,
			difficulty = overkill_and_above,
			equipped_team = {
				primary_category = "snp",
				secondaries = {
					"wpn_fps_saw_secondary"
				}
			}
		},
		fish_4 = {
			timer = 360,
			award = "fish_4",
			job = "fish",
			difficulty = overkill_and_above
		},
		fish_5 = {
			everyone_killed_by_weapons = 0,
			everyone_killed_by_melee = 0,
			award = "fish_5",
			job = "fish",
			everyone_killed_by_grenade = 0
		},
		grv_1 = {
			award = "grv_1",
			difficulty = overkill_and_above,
			equipped_outfit = {
				secondary = "wpn_fps_smg_coal",
				melee_weapon = "oxide",
				primaries = {
					"wpn_fps_snp_siltstone",
					"wpn_fps_ass_flint"
				}
			}
		},
		grv_4 = {
			stealth = true,
			award = "grv_4",
			equipped_outfit = {
				secondary = "wpn_fps_smg_coal",
				melee_weapon = "oxide",
				primaries = {
					"wpn_fps_snp_siltstone",
					"wpn_fps_ass_flint"
				}
			}
		},
		glace_1 = {
			award = "glace_1",
			job = "glace",
			difficulty = normal_and_above
		},
		glace_2 = {
			award = "glace_2",
			job = "glace",
			difficulty = hard_and_above
		},
		glace_3 = {
			award = "glace_3",
			job = "glace",
			difficulty = veryhard_and_above
		},
		glace_4 = {
			award = "glace_4",
			job = "glace",
			difficulty = overkill_and_above
		},
		run_1 = {
			award = "run_1",
			job = "run",
			difficulty = normal_and_above
		},
		run_2 = {
			award = "run_2",
			job = "run",
			difficulty = hard_and_above
		},
		run_3 = {
			award = "run_3",
			job = "run",
			difficulty = veryhard_and_above
		},
		run_4 = {
			award = "run_4",
			job = "run",
			difficulty = overkill_and_above
		},
		wwh_1 = {
			award = "wwh_1",
			job = "wwh",
			difficulty = normal_and_above
		},
		wwh_2 = {
			award = "wwh_2",
			job = "wwh",
			difficulty = hard_and_above
		},
		wwh_3 = {
			award = "wwh_3",
			job = "wwh",
			difficulty = veryhard_and_above
		},
		wwh_4 = {
			award = "wwh_4",
			job = "wwh",
			difficulty = overkill_and_above
		},
		wwh_5 = {
			award = "wwh_5",
			job = "wwh",
			difficulty = easywish_and_above
		},
		wwh_6 = {
			award = "wwh_6",
			job = "wwh",
			difficulty = deathwish_and_above
		},
		wwh_7 = {
			award = "wwh_7",
			one_down = true,
			job = "wwh",
			difficulty = sm_wish_and_above
		},
		dah_1 = {
			award = "dah_1",
			job = "dah",
			difficulty = normal_and_above
		},
		dah_2 = {
			award = "dah_2",
			job = "dah",
			difficulty = hard_and_above
		},
		dah_3 = {
			award = "dah_3",
			job = "dah",
			difficulty = veryhard_and_above
		},
		dah_4 = {
			award = "dah_4",
			job = "dah",
			difficulty = overkill_and_above
		},
		dah_5 = {
			award = "dah_5",
			job = "dah",
			difficulty = easywish_and_above
		},
		dah_6 = {
			award = "dah_6",
			job = "dah",
			difficulty = deathwish_and_above
		},
		dah_7 = {
			award = "dah_7",
			one_down = true,
			job = "dah",
			difficulty = sm_wish_and_above
		},
		trk_af_0 = {
			award = "trk_af_0",
			job = "jolly",
			difficulty = normal_and_above
		},
		trk_af_1 = {
			award = "trk_af_1",
			job = "jolly",
			difficulty = hard_and_above
		},
		trk_af_2 = {
			award = "trk_af_2",
			job = "jolly",
			difficulty = veryhard_and_above
		},
		trk_af_3 = {
			award = "trk_af_3",
			job = "jolly",
			difficulty = overkill_and_above
		},
		trk_ag_0 = {
			award = "trk_ag_0",
			job = "gallery",
			difficulty = normal_and_above
		},
		trk_ag_1 = {
			award = "trk_ag_1",
			job = "gallery",
			difficulty = hard_and_above
		},
		trk_ag_2 = {
			award = "trk_ag_2",
			job = "gallery",
			difficulty = veryhard_and_above
		},
		trk_ag_3 = {
			award = "trk_ag_3",
			job = "gallery",
			difficulty = overkill_and_above
		},
		trk_al_0 = {
			award = "trk_al_0",
			job = "arena",
			difficulty = normal_and_above
		},
		trk_al_1 = {
			award = "trk_al_1",
			job = "arena",
			difficulty = hard_and_above
		},
		trk_al_2 = {
			award = "trk_al_2",
			job = "arena",
			difficulty = veryhard_and_above
		},
		trk_al_3 = {
			award = "trk_al_3",
			job = "arena",
			difficulty = overkill_and_above
		},
		trk_bb_0 = {
			award = "trk_bb_0",
			job = "big",
			difficulty = normal_and_above
		},
		trk_bb_1 = {
			award = "trk_bb_1",
			job = "big",
			difficulty = hard_and_above
		},
		trk_bb_2 = {
			award = "trk_bb_2",
			job = "big",
			difficulty = veryhard_and_above
		},
		trk_bb_3 = {
			award = "trk_bb_3",
			job = "big",
			difficulty = overkill_and_above
		},
		trk_bc_0 = {
			award = "trk_bc_0",
			job = "branchbank_cash",
			difficulty = normal_and_above
		},
		trk_bc_1 = {
			award = "trk_bc_1",
			job = "branchbank_cash",
			difficulty = hard_and_above
		},
		trk_bc_2 = {
			award = "trk_bc_2",
			job = "branchbank_cash",
			difficulty = veryhard_and_above
		},
		trk_bc_3 = {
			award = "trk_bc_3",
			job = "branchbank_cash",
			difficulty = overkill_and_above
		},
		trk_bd_0 = {
			award = "trk_bd_0",
			job = "branchbank_deposit",
			difficulty = normal_and_above
		},
		trk_bd_1 = {
			award = "trk_bd_1",
			job = "branchbank_deposit",
			difficulty = hard_and_above
		},
		trk_bd_2 = {
			award = "trk_bd_2",
			job = "branchbank_deposit",
			difficulty = veryhard_and_above
		},
		trk_bd_3 = {
			award = "trk_bd_3",
			job = "branchbank_deposit",
			difficulty = overkill_and_above
		},
		trk_bg_0 = {
			award = "trk_bg_0",
			job = "branchbank_gold_prof",
			difficulty = normal_and_above
		},
		trk_bg_1 = {
			award = "trk_bg_1",
			job = "branchbank_gold_prof",
			difficulty = hard_and_above
		},
		trk_bg_2 = {
			award = "trk_bg_2",
			job = "branchbank_gold_prof",
			difficulty = veryhard_and_above
		},
		trk_bg_3 = {
			award = "trk_bg_3",
			job = "branchbank_gold_prof",
			difficulty = overkill_and_above
		},
		trk_bi_0 = {
			award = "trk_bi_0",
			job = "born",
			difficulty = normal_and_above
		},
		trk_bi_1 = {
			award = "trk_bi_1",
			job = "born",
			difficulty = hard_and_above
		},
		trk_bi_2 = {
			award = "trk_bi_2",
			job = "born",
			difficulty = veryhard_and_above
		},
		trk_bi_3 = {
			award = "trk_bi_3",
			job = "born",
			difficulty = overkill_and_above
		},
		trk_bm_0 = {
			award = "trk_bm_0",
			job = "pbr",
			difficulty = normal_and_above
		},
		trk_bm_1 = {
			award = "trk_bm_1",
			job = "pbr",
			difficulty = hard_and_above
		},
		trk_bm_2 = {
			award = "trk_bm_2",
			job = "pbr",
			difficulty = veryhard_and_above
		},
		trk_bm_3 = {
			award = "trk_bm_3",
			job = "pbr",
			difficulty = overkill_and_above
		},
		trk_bo_0 = {
			award = "trk_bo_0",
			difficulty = normal_and_above,
			jobs = {
				"welcome_to_the_jungle_wrapper_prof",
				"welcome_to_the_jungle_night_prof",
				"welcome_to_the_jungle_prof"
			}
		},
		trk_bo_1 = {
			award = "trk_bo_1",
			difficulty = hard_and_above,
			jobs = {
				"welcome_to_the_jungle_wrapper_prof",
				"welcome_to_the_jungle_night_prof",
				"welcome_to_the_jungle_prof"
			}
		},
		trk_bo_2 = {
			award = "trk_bo_2",
			difficulty = veryhard_and_above,
			jobs = {
				"welcome_to_the_jungle_wrapper_prof",
				"welcome_to_the_jungle_night_prof",
				"welcome_to_the_jungle_prof"
			}
		},
		trk_bo_3 = {
			award = "trk_bo_3",
			difficulty = overkill_and_above,
			jobs = {
				"welcome_to_the_jungle_wrapper_prof",
				"welcome_to_the_jungle_night_prof",
				"welcome_to_the_jungle_prof"
			}
		},
		trk_bod_1 = {
			award = "trk_bod_1",
			job = "crojob1",
			difficulty = hard_and_above
		},
		trk_bod_2 = {
			award = "trk_bod_2",
			job = "crojob1",
			difficulty = veryhard_and_above
		},
		trk_bod_3 = {
			award = "trk_bod_3",
			job = "crojob1",
			difficulty = overkill_and_above
		},
		trk_bof_1 = {
			award = "trk_bof_1",
			difficulty = hard_and_above,
			jobs = {
				"crojob_wrapper",
				"crojob2",
				"crojob2_night"
			}
		},
		trk_bof_2 = {
			award = "trk_bof_2",
			difficulty = veryhard_and_above,
			jobs = {
				"crojob_wrapper",
				"crojob2",
				"crojob2_night"
			}
		},
		trk_bof_3 = {
			award = "trk_bof_3",
			difficulty = overkill_and_above,
			jobs = {
				"crojob_wrapper",
				"crojob2",
				"crojob2_night"
			}
		},
		trk_bp_0 = {
			award = "trk_bp_0",
			job = "mad",
			difficulty = normal_and_above
		},
		trk_bp_1 = {
			award = "trk_bp_1",
			job = "mad",
			difficulty = hard_and_above
		},
		trk_bp_2 = {
			award = "trk_bp_2",
			job = "mad",
			difficulty = veryhard_and_above
		},
		trk_bp_3 = {
			award = "trk_bp_3",
			job = "mad",
			difficulty = overkill_and_above
		},
		trk_br_0 = {
			award = "trk_br_0",
			job = "branchbank_prof",
			difficulty = normal_and_above
		},
		trk_br_1 = {
			award = "trk_br_1",
			job = "branchbank_prof",
			difficulty = hard_and_above
		},
		trk_br_2 = {
			award = "trk_br_2",
			job = "branchbank_prof",
			difficulty = veryhard_and_above
		},
		trk_br_3 = {
			award = "trk_br_3",
			job = "branchbank_prof",
			difficulty = overkill_and_above
		},
		trk_bs_0 = {
			award = "trk_bs_0",
			job = "pbr2",
			difficulty = normal_and_above
		},
		trk_bs_1 = {
			award = "trk_bs_1",
			job = "pbr2",
			difficulty = hard_and_above
		},
		trk_bs_2 = {
			award = "trk_bs_2",
			job = "pbr2",
			difficulty = veryhard_and_above
		},
		trk_bs_3 = {
			award = "trk_bs_3",
			job = "pbr2",
			difficulty = overkill_and_above
		},
		trk_bt_0 = {
			award = "trk_bt_0",
			job = "spa",
			difficulty = normal_and_above
		},
		trk_bt_1 = {
			award = "trk_bt_1",
			job = "spa",
			difficulty = hard_and_above
		},
		trk_bt_2 = {
			award = "trk_bt_2",
			job = "spa",
			difficulty = veryhard_and_above
		},
		trk_bt_3 = {
			award = "trk_bt_3",
			job = "spa",
			difficulty = overkill_and_above
		},
		trk_co_0 = {
			award = "trk_co_0",
			job = "rat",
			difficulty = normal_and_above
		},
		trk_co_1 = {
			award = "trk_co_1",
			job = "rat",
			difficulty = hard_and_above
		},
		trk_co_2 = {
			award = "trk_co_2",
			job = "rat",
			difficulty = veryhard_and_above
		},
		trk_co_3 = {
			award = "trk_co_3",
			job = "rat",
			difficulty = overkill_and_above
		},
		trk_cou_0 = {
			award = "trk_cou_0",
			job = "pal",
			difficulty = normal_and_above
		},
		trk_cou_1 = {
			award = "trk_cou_1",
			job = "pal",
			difficulty = hard_and_above
		},
		trk_cou_2 = {
			award = "trk_cou_2",
			job = "pal",
			difficulty = veryhard_and_above
		},
		trk_cou_3 = {
			award = "trk_cou_3",
			job = "pal",
			difficulty = overkill_and_above
		},
		trk_cs_0 = {
			award = "trk_cs_0",
			job = "cage",
			difficulty = normal_and_above
		},
		trk_cs_1 = {
			award = "trk_cs_1",
			job = "cage",
			difficulty = hard_and_above
		},
		trk_cs_2 = {
			award = "trk_cs_2",
			job = "cage",
			difficulty = veryhard_and_above
		},
		trk_cs_3 = {
			award = "trk_cs_3",
			job = "cage",
			difficulty = overkill_and_above
		},
		trk_dm_0 = {
			award = "trk_dm_0",
			job = "mus",
			difficulty = normal_and_above
		},
		trk_dm_1 = {
			award = "trk_dm_1",
			job = "mus",
			difficulty = hard_and_above
		},
		trk_dm_2 = {
			award = "trk_dm_2",
			job = "mus",
			difficulty = veryhard_and_above
		},
		trk_dm_3 = {
			award = "trk_dm_3",
			job = "mus",
			difficulty = overkill_and_above
		},
		trk_ds_0 = {
			award = "trk_ds_0",
			job = "family",
			difficulty = normal_and_above
		},
		trk_ds_1 = {
			award = "trk_ds_1",
			job = "family",
			difficulty = hard_and_above
		},
		trk_ds_2 = {
			award = "trk_ds_2",
			job = "family",
			difficulty = veryhard_and_above
		},
		trk_ds_3 = {
			award = "trk_ds_3",
			job = "family",
			difficulty = overkill_and_above
		},
		trk_ed_0 = {
			award = "trk_ed_0",
			job = "election_day",
			difficulty = normal_and_above
		},
		trk_ed_1 = {
			award = "trk_ed_1",
			job = "election_day",
			difficulty = hard_and_above
		},
		trk_ed_2 = {
			award = "trk_ed_2",
			job = "election_day",
			difficulty = veryhard_and_above
		},
		trk_ed_3 = {
			award = "trk_ed_3",
			job = "election_day",
			difficulty = overkill_and_above
		},
		trk_ff_0 = {
			award = "trk_ff_0",
			job = "framing_frame",
			difficulty = normal_and_above
		},
		trk_ff_1 = {
			award = "trk_ff_1",
			job = "framing_frame",
			difficulty = hard_and_above
		},
		trk_ff_2 = {
			award = "trk_ff_2",
			job = "framing_frame",
			difficulty = veryhard_and_above
		},
		trk_ff_3 = {
			award = "trk_ff_3",
			job = "framing_frame",
			difficulty = overkill_and_above
		},
		trk_fir_0 = {
			award = "trk_fir_0",
			job = "firestarter",
			difficulty = normal_and_above
		},
		trk_fir_1 = {
			award = "trk_fir_1",
			job = "firestarter",
			difficulty = hard_and_above
		},
		trk_fir_2 = {
			award = "trk_fir_2",
			job = "firestarter",
			difficulty = veryhard_and_above
		},
		trk_fir_3 = {
			award = "trk_fir_3",
			job = "firestarter",
			difficulty = overkill_and_above
		},
		trk_fs_0 = {
			award = "trk_fs_0",
			job = "four_stores",
			difficulty = normal_and_above
		},
		trk_fs_1 = {
			award = "trk_fs_1",
			job = "four_stores",
			difficulty = hard_and_above
		},
		trk_fs_2 = {
			award = "trk_fs_2",
			job = "four_stores",
			difficulty = veryhard_and_above
		},
		trk_fs_3 = {
			award = "trk_fs_3",
			job = "four_stores",
			difficulty = overkill_and_above
		},
		trk_fw_0 = {
			award = "trk_fw_0",
			job = "red2",
			difficulty = normal_and_above
		},
		trk_fw_1 = {
			award = "trk_fw_1",
			job = "red2",
			difficulty = hard_and_above
		},
		trk_fw_2 = {
			award = "trk_fw_2",
			job = "red2",
			difficulty = veryhard_and_above
		},
		trk_fw_3 = {
			award = "trk_fw_3",
			job = "red2",
			difficulty = overkill_and_above
		},
		trk_gb_0 = {
			award = "trk_gb_0",
			job = "roberts",
			difficulty = normal_and_above
		},
		trk_gb_1 = {
			award = "trk_gb_1",
			job = "roberts",
			difficulty = hard_and_above
		},
		trk_gb_2 = {
			award = "trk_gb_2",
			job = "roberts",
			difficulty = veryhard_and_above
		},
		trk_gb_3 = {
			award = "trk_gb_3",
			job = "roberts",
			difficulty = overkill_and_above
		},
		trk_gg_0 = {
			award = "trk_gg_0",
			job = "kenaz",
			difficulty = normal_and_above
		},
		trk_gg_1 = {
			award = "trk_gg_1",
			job = "kenaz",
			difficulty = hard_and_above
		},
		trk_gg_2 = {
			award = "trk_gg_2",
			job = "kenaz",
			difficulty = veryhard_and_above
		},
		trk_gg_3 = {
			award = "trk_gg_3",
			job = "kenaz",
			difficulty = overkill_and_above
		},
		trk_gs_0 = {
			award = "trk_gs_0",
			job = "peta",
			difficulty = normal_and_above
		},
		trk_gs_1 = {
			award = "trk_gs_1",
			job = "peta",
			difficulty = hard_and_above
		},
		trk_gs_2 = {
			award = "trk_gs_2",
			job = "peta",
			difficulty = veryhard_and_above
		},
		trk_gs_3 = {
			award = "trk_gs_3",
			job = "peta",
			difficulty = overkill_and_above
		},
		trk_hb_1 = {
			award = "trk_hb_1",
			job = "hox",
			difficulty = hard_and_above
		},
		trk_hb_2 = {
			award = "trk_hb_2",
			job = "hox",
			difficulty = veryhard_and_above
		},
		trk_hb_3 = {
			award = "trk_hb_3",
			job = "hox",
			difficulty = overkill_and_above
		},
		trk_hm_0 = {
			award = "trk_hm_0",
			job = "mia",
			difficulty = normal_and_above
		},
		trk_hm_1 = {
			award = "trk_hm_1",
			job = "mia",
			difficulty = hard_and_above
		},
		trk_hm_2 = {
			award = "trk_hm_2",
			job = "mia",
			difficulty = veryhard_and_above
		},
		trk_hm_3 = {
			award = "trk_hm_3",
			job = "mia",
			difficulty = overkill_and_above
		},
		trk_hr_0 = {
			award = "trk_hr_0",
			job = "hox_3",
			difficulty = normal_and_above
		},
		trk_hr_1 = {
			award = "trk_hr_1",
			job = "hox_3",
			difficulty = hard_and_above
		},
		trk_hr_2 = {
			award = "trk_hr_2",
			job = "hox_3",
			difficulty = veryhard_and_above
		},
		trk_hr_3 = {
			award = "trk_hr_3",
			job = "hox_3",
			difficulty = overkill_and_above
		},
		trk_js_0 = {
			award = "trk_js_0",
			job = "jewelry_store",
			difficulty = normal_and_above
		},
		trk_js_1 = {
			award = "trk_js_1",
			job = "jewelry_store",
			difficulty = hard_and_above
		},
		trk_js_2 = {
			award = "trk_js_2",
			job = "jewelry_store",
			difficulty = veryhard_and_above
		},
		trk_js_3 = {
			award = "trk_js_3",
			job = "jewelry_store",
			difficulty = overkill_and_above
		},
		trk_lr_0 = {
			award = "trk_lr_0",
			job = "nail",
			difficulty = normal_and_above
		},
		trk_lr_1 = {
			award = "trk_lr_1",
			job = "nail",
			difficulty = hard_and_above
		},
		trk_lr_2 = {
			award = "trk_lr_2",
			job = "nail",
			difficulty = veryhard_and_above
		},
		trk_lr_3 = {
			award = "trk_lr_3",
			job = "nail",
			difficulty = overkill_and_above
		},
		trk_mc_0 = {
			award = "trk_mc_0",
			job = "mallcrasher",
			difficulty = normal_and_above
		},
		trk_mc_1 = {
			award = "trk_mc_1",
			job = "mallcrasher",
			difficulty = hard_and_above
		},
		trk_mc_2 = {
			award = "trk_mc_2",
			job = "mallcrasher",
			difficulty = veryhard_and_above
		},
		trk_mc_3 = {
			award = "trk_mc_3",
			job = "mallcrasher",
			difficulty = overkill_and_above
		},
		trk_md_1 = {
			award = "trk_md_1",
			job = "shoutout_raid",
			difficulty = hard_and_above
		},
		trk_md_2 = {
			award = "trk_md_2",
			job = "shoutout_raid",
			difficulty = veryhard_and_above
		},
		trk_md_3 = {
			award = "trk_md_3",
			job = "shoutout_raid",
			difficulty = overkill_and_above
		},
		trk_ms_0 = {
			award = "trk_ms_0",
			job = "dark",
			difficulty = normal_and_above
		},
		trk_ms_1 = {
			award = "trk_ms_1",
			job = "dark",
			difficulty = hard_and_above
		},
		trk_ms_2 = {
			award = "trk_ms_2",
			job = "dark",
			difficulty = veryhard_and_above
		},
		trk_ms_3 = {
			award = "trk_ms_3",
			job = "dark",
			difficulty = overkill_and_above
		},
		trk_nc_0 = {
			award = "trk_nc_0",
			job = "nightclub",
			difficulty = normal_and_above
		},
		trk_nc_1 = {
			award = "trk_nc_1",
			job = "nightclub",
			difficulty = hard_and_above
		},
		trk_nc_2 = {
			award = "trk_nc_2",
			job = "nightclub",
			difficulty = veryhard_and_above
		},
		trk_nc_3 = {
			award = "trk_nc_3",
			job = "nightclub",
			difficulty = overkill_and_above
		},
		trk_pn_0 = {
			award = "trk_pn_0",
			job = "help",
			difficulty = normal_and_above
		},
		trk_pn_1 = {
			award = "trk_pn_1",
			job = "help",
			difficulty = hard_and_above
		},
		trk_pn_2 = {
			award = "trk_pn_2",
			job = "help",
			difficulty = veryhard_and_above
		},
		trk_pn_3 = {
			award = "trk_pn_3",
			job = "help",
			difficulty = overkill_and_above
		},
		trk_pr_0 = {
			award = "trk_pr_0",
			job = "flat",
			difficulty = normal_and_above
		},
		trk_pr_1 = {
			award = "trk_pr_1",
			job = "flat",
			difficulty = hard_and_above
		},
		trk_pr_2 = {
			award = "trk_pr_2",
			job = "flat",
			difficulty = veryhard_and_above
		},
		trk_pr_3 = {
			award = "trk_pr_3",
			job = "flat",
			difficulty = overkill_and_above
		},
		trk_ra_0 = {
			award = "trk_ra_0",
			job = "alex",
			difficulty = normal_and_above
		},
		trk_ra_1 = {
			award = "trk_ra_1",
			job = "alex",
			difficulty = hard_and_above
		},
		trk_ra_2 = {
			award = "trk_ra_2",
			job = "alex",
			difficulty = veryhard_and_above
		},
		trk_ra_3 = {
			award = "trk_ra_3",
			job = "alex",
			difficulty = overkill_and_above
		},
		trk_sa_0 = {
			award = "trk_sa_0",
			job = "chill_combat",
			difficulty = normal_and_above
		},
		trk_sa_1 = {
			award = "trk_sa_1",
			job = "chill_combat",
			difficulty = hard_and_above
		},
		trk_sa_2 = {
			award = "trk_sa_2",
			job = "chill_combat",
			difficulty = veryhard_and_above
		},
		trk_sa_3 = {
			award = "trk_sa_3",
			job = "chill_combat",
			difficulty = overkill_and_above
		},
		trk_sa_4 = {
			award = "trk_sa_4",
			job = "chill_combat",
			difficulty = easywish_and_above
		},
		trk_sa_5 = {
			award = "trk_sa_5",
			job = "chill_combat",
			difficulty = deathwish_and_above
		},
		trk_sa_6 = {
			award = "trk_sa_6",
			one_down = true,
			job = "chill_combat",
			difficulty = sm_wish_and_above
		},
		trk_sf_0 = {
			award = "trk_sf_0",
			job = "friend",
			difficulty = normal_and_above
		},
		trk_sf_1 = {
			award = "trk_sf_1",
			job = "friend",
			difficulty = hard_and_above
		},
		trk_sf_2 = {
			award = "trk_sf_2",
			job = "friend",
			difficulty = veryhard_and_above
		},
		trk_sf_3 = {
			award = "trk_sf_3",
			job = "friend",
			difficulty = overkill_and_above
		},
		trk_sh_0 = {
			award = "trk_sh_0",
			job = "dinner",
			difficulty = normal_and_above
		},
		trk_sh_1 = {
			award = "trk_sh_1",
			job = "dinner",
			difficulty = hard_and_above
		},
		trk_sh_2 = {
			award = "trk_sh_2",
			job = "dinner",
			difficulty = veryhard_and_above
		},
		trk_sh_3 = {
			award = "trk_sh_3",
			job = "dinner",
			difficulty = overkill_and_above
		},
		trk_sr_0 = {
			award = "trk_sr_0",
			job = "kosugi",
			difficulty = normal_and_above
		},
		trk_sr_1 = {
			award = "trk_sr_1",
			job = "kosugi",
			difficulty = hard_and_above
		},
		trk_sr_2 = {
			award = "trk_sr_2",
			job = "kosugi",
			difficulty = veryhard_and_above
		},
		trk_sr_3 = {
			award = "trk_sr_3",
			job = "kosugi",
			difficulty = overkill_and_above
		},
		trk_sw_0 = {
			award = "trk_sw_0",
			job = "cane",
			difficulty = normal_and_above
		},
		trk_sw_1 = {
			award = "trk_sw_1",
			job = "cane",
			difficulty = hard_and_above
		},
		trk_sw_2 = {
			award = "trk_sw_2",
			job = "cane",
			difficulty = veryhard_and_above
		},
		trk_sw_3 = {
			award = "trk_sw_3",
			job = "cane",
			difficulty = overkill_and_above
		},
		trk_sx_0 = {
			award = "trk_sx_0",
			job = "moon",
			difficulty = normal_and_above
		},
		trk_sx_1 = {
			award = "trk_sx_1",
			job = "moon",
			difficulty = hard_and_above
		},
		trk_sx_2 = {
			award = "trk_sx_2",
			job = "moon",
			difficulty = veryhard_and_above
		},
		trk_sx_3 = {
			award = "trk_sx_3",
			job = "moon",
			difficulty = overkill_and_above
		},
		trk_tc_0 = {
			award = "trk_tc_0",
			job = "arm_cro",
			difficulty = normal_and_above
		},
		trk_tc_1 = {
			award = "trk_tc_1",
			job = "arm_cro",
			difficulty = hard_and_above
		},
		trk_tc_2 = {
			award = "trk_tc_2",
			job = "arm_cro",
			difficulty = veryhard_and_above
		},
		trk_tc_3 = {
			award = "trk_tc_3",
			job = "arm_cro",
			difficulty = overkill_and_above
		},
		trk_td_0 = {
			award = "trk_td_0",
			job = "arm_hcm",
			difficulty = normal_and_above
		},
		trk_td_1 = {
			award = "trk_td_1",
			job = "arm_hcm",
			difficulty = hard_and_above
		},
		trk_td_2 = {
			award = "trk_td_2",
			job = "arm_hcm",
			difficulty = veryhard_and_above
		},
		trk_td_3 = {
			award = "trk_td_3",
			job = "arm_hcm",
			difficulty = overkill_and_above
		},
		trk_th_0 = {
			award = "trk_th_0",
			job = "arm_fac",
			difficulty = normal_and_above
		},
		trk_th_1 = {
			award = "trk_th_1",
			job = "arm_fac",
			difficulty = hard_and_above
		},
		trk_th_2 = {
			award = "trk_th_2",
			job = "arm_fac",
			difficulty = veryhard_and_above
		},
		trk_th_3 = {
			award = "trk_th_3",
			job = "arm_fac",
			difficulty = overkill_and_above
		},
		trk_tp_0 = {
			award = "trk_tp_0",
			job = "arm_par",
			difficulty = normal_and_above
		},
		trk_tp_1 = {
			award = "trk_tp_1",
			job = "arm_par",
			difficulty = hard_and_above
		},
		trk_tp_2 = {
			award = "trk_tp_2",
			job = "arm_par",
			difficulty = veryhard_and_above
		},
		trk_tp_3 = {
			award = "trk_tp_3",
			job = "arm_par",
			difficulty = overkill_and_above
		},
		trk_tt_0 = {
			award = "trk_tt_0",
			job = "arm_for",
			difficulty = normal_and_above
		},
		trk_tt_1 = {
			award = "trk_tt_1",
			job = "arm_for",
			difficulty = hard_and_above
		},
		trk_tt_2 = {
			award = "trk_tt_2",
			job = "arm_for",
			difficulty = veryhard_and_above
		},
		trk_tt_3 = {
			award = "trk_tt_3",
			job = "arm_for",
			difficulty = overkill_and_above
		},
		trk_tu_0 = {
			award = "trk_tu_0",
			job = "arm_und",
			difficulty = normal_and_above
		},
		trk_tu_1 = {
			award = "trk_tu_1",
			job = "arm_und",
			difficulty = hard_and_above
		},
		trk_tu_2 = {
			award = "trk_tu_2",
			job = "arm_und",
			difficulty = veryhard_and_above
		},
		trk_tu_3 = {
			award = "trk_tu_3",
			job = "arm_und",
			difficulty = overkill_and_above
		},
		trk_uc_0 = {
			award = "trk_uc_0",
			job = "man",
			difficulty = normal_and_above
		},
		trk_uc_1 = {
			award = "trk_uc_1",
			job = "man",
			difficulty = hard_and_above
		},
		trk_uc_2 = {
			award = "trk_uc_2",
			job = "man",
			difficulty = veryhard_and_above
		},
		trk_uc_3 = {
			award = "trk_uc_3",
			job = "man",
			difficulty = overkill_and_above
		},
		trk_uj_0 = {
			award = "trk_uj_0",
			job = "ukrainian_job_prof",
			difficulty = normal_and_above
		},
		trk_uj_1 = {
			award = "trk_uj_1",
			job = "ukrainian_job_prof",
			difficulty = hard_and_above
		},
		trk_uj_2 = {
			award = "trk_uj_2",
			job = "ukrainian_job_prof",
			difficulty = veryhard_and_above
		},
		trk_uj_3 = {
			award = "trk_uj_3",
			job = "ukrainian_job_prof",
			difficulty = overkill_and_above
		},
		trk_wd_0 = {
			award = "trk_wd_0",
			difficulty = normal_and_above,
			jobs = {
				"watchdogs_wrapper",
				"watchdogs_night",
				"watchdogs"
			}
		},
		trk_wd_1 = {
			award = "trk_wd_1",
			difficulty = hard_and_above,
			jobs = {
				"watchdogs_wrapper",
				"watchdogs_night",
				"watchdogs"
			}
		},
		trk_wd_2 = {
			award = "trk_wd_2",
			difficulty = veryhard_and_above,
			jobs = {
				"watchdogs_wrapper",
				"watchdogs_night",
				"watchdogs"
			}
		},
		trk_wd_3 = {
			award = "trk_wd_3",
			difficulty = overkill_and_above,
			jobs = {
				"watchdogs_wrapper",
				"watchdogs_night",
				"watchdogs"
			}
		},
		trk_yh_0 = {
			award = "trk_yh_0",
			job = "fish",
			difficulty = normal_and_above
		},
		trk_yh_1 = {
			award = "trk_yh_1",
			job = "fish",
			difficulty = hard_and_above
		},
		trk_yh_2 = {
			award = "trk_yh_2",
			job = "fish",
			difficulty = veryhard_and_above
		},
		trk_yh_3 = {
			award = "trk_yh_3",
			job = "fish",
			difficulty = overkill_and_above
		},
		rvd_1 = {
			award = "rvd_1",
			job = "rvd",
			difficulty = normal_and_above
		},
		rvd_2 = {
			award = "rvd_2",
			job = "rvd",
			difficulty = hard_and_above
		},
		rvd_3 = {
			award = "rvd_3",
			job = "rvd",
			difficulty = veryhard_and_above
		},
		rvd_4 = {
			award = "rvd_4",
			job = "rvd",
			difficulty = overkill_and_above
		},
		rvd_5 = {
			award = "rvd_5",
			job = "rvd",
			difficulty = easywish_and_above
		},
		rvd_6 = {
			award = "rvd_6",
			job = "rvd",
			difficulty = deathwish_and_above
		},
		rvd_7 = {
			award = "rvd_7",
			one_down = true,
			job = "rvd",
			difficulty = sm_wish_and_above
		},
		rvd_8 = {
			melee_used = false,
			award = "rvd_8",
			job = "rvd",
			difficulty = overkill_and_above,
			weapons_used = {
				"corgi"
			},
			equipped = {
				primaries = {
					weapon_id = "corgi"
				}
			}
		},
		brb_1 = {
			award = "brb_1",
			job = "brb",
			difficulty = normal_and_above
		},
		brb_2 = {
			award = "brb_2",
			job = "brb",
			difficulty = hard_and_above
		},
		brb_3 = {
			award = "brb_3",
			job = "brb",
			difficulty = veryhard_and_above
		},
		brb_4 = {
			award = "brb_4",
			job = "brb",
			difficulty = overkill_and_above
		},
		brb_5 = {
			award = "brb_5",
			job = "brb",
			difficulty = easywish_and_above
		},
		brb_6 = {
			award = "brb_6",
			job = "brb",
			difficulty = deathwish_and_above
		},
		brb_7 = {
			award = "brb_7",
			one_down = true,
			job = "brb",
			difficulty = sm_wish_and_above
		},
		ggez_13 = {
			award = "ggez_13",
			job = "fish",
			difficulty = sm_wish_and_above
		},
		ggez_14 = {
			award = "ggez_14",
			job = "haunted",
			difficulty = sm_wish_and_above
		},
		ggez_15 = {
			award = "ggez_15",
			job = "jolly",
			difficulty = sm_wish_and_above
		},
		ggez_16 = {
			award = "ggez_16",
			job = "wwh",
			difficulty = sm_wish_and_above
		},
		ggez_17 = {
			award = "ggez_17",
			job = "arena",
			difficulty = sm_wish_and_above
		},
		ggez_18 = {
			award = "ggez_18",
			job = "gallery",
			difficulty = sm_wish_and_above
		},
		ggez_19 = {
			award = "ggez_19",
			job = "branchbank_cash",
			difficulty = sm_wish_and_above
		},
		ggez_20 = {
			award = "ggez_20",
			job = "branchbank_deposit",
			difficulty = sm_wish_and_above
		},
		ggez_21 = {
			award = "ggez_21",
			job = "branchbank_gold_prof",
			difficulty = sm_wish_and_above
		},
		ggez_22 = {
			award = "ggez_22",
			job = "branchbank_prof",
			difficulty = sm_wish_and_above
		},
		ggez_23 = {
			award = "ggez_23",
			job = "pbr",
			difficulty = sm_wish_and_above
		},
		ggez_24 = {
			award = "ggez_24",
			job = "big",
			difficulty = sm_wish_and_above
		},
		ggez_25 = {
			award = "ggez_25",
			difficulty = sm_wish_and_above,
			jobs = {
				"welcome_to_the_jungle_wrapper_prof",
				"welcome_to_the_jungle_night_prof",
				"welcome_to_the_jungle_prof"
			}
		},
		ggez_26 = {
			award = "ggez_26",
			job = "born",
			difficulty = sm_wish_and_above
		},
		ggez_27 = {
			award = "ggez_27",
			job = "pbr2",
			difficulty = sm_wish_and_above
		},
		ggez_28 = {
			award = "ggez_28",
			job = "mad",
			difficulty = sm_wish_and_above
		},
		ggez_29 = {
			award = "ggez_29",
			job = "crojob1",
			difficulty = sm_wish_and_above
		},
		ggez_30 = {
			award = "ggez_30",
			difficulty = sm_wish_and_above,
			jobs = {
				"crojob_wrapper",
				"crojob2",
				"crojob2_night"
			}
		},
		ggez_31 = {
			award = "ggez_31",
			job = "spa",
			difficulty = sm_wish_and_above
		},
		ggez_32 = {
			award = "ggez_32",
			job = "brb",
			difficulty = sm_wish_and_above
		},
		ggez_33 = {
			award = "ggez_33",
			job = "cage",
			difficulty = sm_wish_and_above
		},
		ggez_34 = {
			award = "ggez_34",
			job = "rat",
			difficulty = sm_wish_and_above
		},
		ggez_35 = {
			award = "ggez_35",
			job = "pal",
			difficulty = sm_wish_and_above
		},
		ggez_36 = {
			award = "ggez_36",
			job = "dah",
			difficulty = sm_wish_and_above
		},
		ggez_37 = {
			award = "ggez_37",
			job = "mus",
			difficulty = sm_wish_and_above
		},
		ggez_38 = {
			award = "ggez_38",
			job = "family",
			difficulty = sm_wish_and_above
		},
		ggez_39 = {
			award = "ggez_39",
			job = "election_day",
			difficulty = sm_wish_and_above
		},
		ggez_40 = {
			award = "ggez_40",
			job = "firestarter",
			difficulty = sm_wish_and_above
		},
		ggez_41 = {
			award = "ggez_41",
			job = "red2",
			difficulty = sm_wish_and_above
		},
		ggez_42 = {
			award = "ggez_42",
			job = "four_stores",
			difficulty = sm_wish_and_above
		},
		ggez_43 = {
			award = "ggez_43",
			job = "framing_frame",
			difficulty = sm_wish_and_above
		},
		ggez_44 = {
			award = "ggez_44",
			job = "roberts",
			difficulty = sm_wish_and_above
		},
		ggez_45 = {
			award = "ggez_45",
			job = "peta",
			difficulty = sm_wish_and_above
		},
		ggez_46 = {
			award = "ggez_46",
			job = "kenaz",
			difficulty = sm_wish_and_above
		},
		ggez_47 = {
			award = "ggez_47",
			job = "glace",
			difficulty = sm_wish_and_above
		},
		ggez_48 = {
			award = "ggez_48",
			job = "run",
			difficulty = sm_wish_and_above
		},
		ggez_49 = {
			award = "ggez_49",
			job = "mia",
			difficulty = sm_wish_and_above
		},
		ggez_50 = {
			award = "ggez_50",
			job = "hox",
			difficulty = sm_wish_and_above
		},
		ggez_51 = {
			award = "ggez_51",
			job = "hox_3",
			difficulty = sm_wish_and_above
		},
		ggez_52 = {
			award = "ggez_52",
			job = "jewelry_store",
			difficulty = sm_wish_and_above
		},
		ggez_53 = {
			award = "ggez_53",
			job = "nail",
			difficulty = sm_wish_and_above
		},
		ggez_54 = {
			award = "ggez_54",
			job = "mallcrasher",
			difficulty = sm_wish_and_above
		},
		ggez_55 = {
			award = "ggez_55",
			job = "shoutout_raid",
			difficulty = sm_wish_and_above
		},
		ggez_56 = {
			award = "ggez_56",
			job = "dark",
			difficulty = sm_wish_and_above
		},
		ggez_57 = {
			award = "ggez_57",
			job = "nightclub",
			difficulty = sm_wish_and_above
		},
		ggez_58 = {
			award = "ggez_58",
			job = "flat",
			difficulty = sm_wish_and_above
		},
		ggez_59 = {
			award = "ggez_59",
			job = "help",
			difficulty = sm_wish_and_above
		},
		ggez_60 = {
			award = "ggez_60",
			job = "alex",
			difficulty = sm_wish_and_above
		},
		ggez_61 = {
			award = "ggez_61",
			job = "rvd",
			difficulty = sm_wish_and_above
		},
		ggez_62 = {
			award = "ggez_62",
			job = "chill_combat",
			difficulty = sm_wish_and_above
		},
		ggez_63 = {
			award = "ggez_63",
			job = "cane",
			difficulty = sm_wish_and_above
		},
		ggez_64 = {
			award = "ggez_64",
			job = "friend",
			difficulty = sm_wish_and_above
		},
		ggez_65 = {
			award = "ggez_65",
			job = "kosugi",
			difficulty = sm_wish_and_above
		},
		ggez_66 = {
			award = "ggez_66",
			job = "dinner",
			difficulty = sm_wish_and_above
		},
		ggez_67 = {
			award = "ggez_67",
			job = "moon",
			difficulty = sm_wish_and_above
		},
		ggez_68 = {
			award = "ggez_68",
			job = "arm_cro",
			difficulty = sm_wish_and_above
		},
		ggez_69 = {
			award = "ggez_69",
			job = "arm_hcm",
			difficulty = sm_wish_and_above
		},
		ggez_70 = {
			award = "ggez_70",
			job = "arm_fac",
			difficulty = sm_wish_and_above
		},
		ggez_71 = {
			award = "ggez_71",
			job = "arm_par",
			difficulty = sm_wish_and_above
		},
		ggez_72 = {
			award = "ggez_72",
			job = "arm_for",
			difficulty = sm_wish_and_above
		},
		ggez_73 = {
			award = "ggez_73",
			job = "arm_und",
			difficulty = sm_wish_and_above
		},
		ggez_74 = {
			award = "ggez_74",
			job = "ukrainian_job_prof",
			difficulty = sm_wish_and_above
		},
		ggez_75 = {
			award = "ggez_75",
			job = "man",
			difficulty = sm_wish_and_above
		},
		ggez_76 = {
			award = "ggez_76",
			difficulty = sm_wish_and_above,
			jobs = {
				"watchdogs_wrapper",
				"watchdogs_night",
				"watchdogs"
			}
		},
		ggez_77 = {
			award = "ggez_77",
			job = "pines",
			difficulty = sm_wish_and_above
		},
		ggez_78 = {
			award = "ggez_78",
			job = "hvh",
			difficulty = sm_wish_and_above
		},
		ckr_1 = {
			award = "ckr_1",
			job = "hvh",
			difficulty = normal_and_above
		},
		ckr_2 = {
			award = "ckr_2",
			job = "hvh",
			difficulty = hard_and_above
		},
		ckr_3 = {
			award = "ckr_3",
			job = "hvh",
			difficulty = veryhard_and_above
		},
		ckr_4 = {
			award = "ckr_4",
			job = "hvh",
			difficulty = overkill_and_above
		},
		ckr_5 = {
			award = "ckr_5",
			job = "hvh",
			difficulty = easywish_and_above
		},
		ckr_6 = {
			award = "ckr_6",
			job = "hvh",
			difficulty = deathwish_and_above
		},
		ckr_7 = {
			award = "ckr_7",
			one_down = true,
			job = "hvh",
			difficulty = sm_wish_and_above
		},
		nbm_1 = {
			award = "nbm_1",
			job = "haunted",
			difficulty = normal_and_above
		},
		nbm_2 = {
			award = "nbm_2",
			job = "haunted",
			difficulty = hard_and_above
		},
		nbm_3 = {
			award = "nbm_3",
			job = "haunted",
			difficulty = veryhard_and_above
		},
		nbm_4 = {
			award = "nbm_4",
			job = "haunted",
			difficulty = overkill_and_above
		},
		pick_666 = {
			award = "pick_666",
			job = "haunted",
			difficulty = easywish_and_above
		},
		halloween_nightmare_5 = {
			award = "halloween_nightmare_5",
			job = "haunted",
			difficulty = deathwish_and_above
		},
		axe_666 = {
			award = "axe_666",
			one_down = true,
			job = "haunted",
			difficulty = sm_wish_and_above
		},
		tag_1 = {
			award = "tag_1",
			job = "tag",
			difficulty = normal_and_above
		},
		tag_2 = {
			award = "tag_2",
			job = "tag",
			difficulty = hard_and_above
		},
		tag_3 = {
			award = "tag_3",
			job = "tag",
			difficulty = veryhard_and_above
		},
		tag_4 = {
			award = "tag_4",
			job = "tag",
			difficulty = overkill_and_above
		},
		tag_5 = {
			award = "tag_5",
			job = "tag",
			difficulty = easywish_and_above
		},
		tag_6 = {
			award = "tag_6",
			job = "tag",
			difficulty = deathwish_and_above
		},
		tag_7 = {
			award = "tag_7",
			job = "tag",
			difficulty = sm_wish_and_above
		},
		tag_8 = {
			award = "tag_8",
			one_down = true,
			job = "tag",
			difficulty = sm_wish_and_above
		},
		des_1 = {
			award = "des_1",
			job = "des",
			difficulty = normal_and_above
		},
		des_2 = {
			award = "des_2",
			job = "des",
			difficulty = hard_and_above
		},
		des_3 = {
			award = "des_3",
			job = "des",
			difficulty = veryhard_and_above
		},
		des_4 = {
			award = "des_4",
			job = "des",
			difficulty = overkill_and_above
		},
		des_5 = {
			award = "des_5",
			job = "des",
			difficulty = easywish_and_above
		},
		des_6 = {
			award = "des_6",
			job = "des",
			difficulty = deathwish_and_above
		},
		des_7 = {
			award = "des_7",
			job = "des",
			difficulty = sm_wish_and_above
		},
		des_8 = {
			award = "des_8",
			one_down = true,
			job = "des",
			difficulty = sm_wish_and_above
		},
		cac_4 = {
			loud = true,
			award = "cac_4",
			memory = {
				is_shortterm = false
			}
		},
		cac_5 = {
			award = "cac_5",
			job = "kosugi",
			no_preplan = true,
			difficulty = overkill_and_above
		},
		cac_23 = {
			everyone_killed_by_grenade = 0,
			award = "cac_23",
			job = "man",
			everyone_used_weapon_category = "bow",
			everyone_killed_by_melee = 0,
			no_bots = true,
			difficulty = overkill_and_above,
			equipped_team = {
				primary_unmodded = true,
				primary_category = "bow"
			}
		},
		cac_27 = {
			everyone_killed_by_grenade = 0,
			award = "cac_27",
			job = "wwh",
			everyone_used_weapon_category = "flamethrower",
			everyone_killed_by_melee = 0,
			equipped_team = {
				primary_category = "flamethrower"
			}
		},
		cac_31 = {
			loud = true,
			award = "cac_31",
			max_players = 1,
			no_bots = true,
			difficulty = overkill_and_above
		},
		sah_1 = {
			award = "sah_1",
			job = "sah",
			difficulty = normal_and_above
		},
		sah_2 = {
			award = "sah_2",
			job = "sah",
			difficulty = hard_and_above
		},
		sah_3 = {
			award = "sah_3",
			job = "sah",
			difficulty = veryhard_and_above
		},
		sah_4 = {
			award = "sah_4",
			job = "sah",
			difficulty = overkill_and_above
		},
		sah_5 = {
			award = "sah_5",
			job = "sah",
			difficulty = easywish_and_above
		},
		sah_6 = {
			award = "sah_6",
			job = "sah",
			difficulty = deathwish_and_above
		},
		sah_7 = {
			award = "sah_7",
			job = "sah",
			difficulty = sm_wish_and_above
		},
		sah_8 = {
			award = "sah_8",
			one_down = true,
			job = "sah",
			difficulty = sm_wish_and_above
		},
		nmh_1 = {
			award = "nmh_1",
			job = "nmh",
			difficulty = normal_and_above
		},
		nmh_2 = {
			award = "nmh_2",
			job = "nmh",
			difficulty = hard_and_above
		},
		nmh_3 = {
			award = "nmh_3",
			job = "nmh",
			difficulty = veryhard_and_above
		},
		nmh_4 = {
			award = "nmh_4",
			job = "nmh",
			difficulty = overkill_and_above
		},
		nmh_5 = {
			award = "nmh_5",
			job = "nmh",
			difficulty = easywish_and_above
		},
		nmh_6 = {
			award = "nmh_6",
			job = "nmh",
			difficulty = deathwish_and_above
		},
		nmh_7 = {
			award = "nmh_7",
			job = "nmh",
			difficulty = sm_wish_and_above
		},
		nmh_8 = {
			award = "nmh_8",
			one_down = true,
			job = "nmh",
			difficulty = sm_wish_and_above
		},
		bph_1 = {
			award = "bph_1",
			job = "bph",
			difficulty = normal_and_above
		},
		bph_2 = {
			award = "bph_2",
			job = "bph",
			difficulty = hard_and_above
		},
		bph_3 = {
			award = "bph_3",
			job = "bph",
			difficulty = veryhard_and_above
		},
		bph_4 = {
			award = "bph_4",
			job = "bph",
			difficulty = overkill_and_above
		},
		bph_5 = {
			award = "bph_5",
			job = "bph",
			difficulty = easywish_and_above
		},
		bph_6 = {
			award = "bph_6",
			job = "bph",
			difficulty = deathwish_and_above
		},
		bph_7 = {
			award = "bph_7",
			job = "bph",
			difficulty = sm_wish_and_above
		},
		bph_8 = {
			award = "bph_8",
			one_down = true,
			job = "bph",
			difficulty = sm_wish_and_above
		},
		vit_1 = {
			award = "vit_1",
			job = "vit",
			difficulty = normal_and_above
		},
		vit_2 = {
			award = "vit_2",
			job = "vit",
			difficulty = hard_and_above
		},
		vit_3 = {
			award = "vit_3",
			job = "vit",
			difficulty = veryhard_and_above
		},
		vit_4 = {
			award = "vit_4",
			job = "vit",
			difficulty = overkill_and_above
		},
		vit_5 = {
			award = "vit_5",
			job = "vit",
			difficulty = easywish_and_above
		},
		vit_6 = {
			award = "vit_6",
			job = "vit",
			difficulty = deathwish_and_above
		},
		vit_7 = {
			award = "vit_7",
			job = "vit",
			difficulty = sm_wish_and_above
		},
		vit_8 = {
			award = "vit_8",
			one_down = true,
			job = "vit",
			difficulty = sm_wish_and_above
		},
		vit_11 = {
			award = "vit_11",
			job = "vit",
			masks = {
				"bush",
				"clinton",
				"franklin",
				"grant",
				"lincoln",
				"nixon",
				"obama",
				"washington",
				"win_donald",
				"win_donald_mega"
			},
			difficulty = overkill_and_above
		},
		uno_1 = {
			award = "uno_1",
			bag_loot_value = 400000,
			jobs = {
				"branchbank_prof",
				"branchbank_gold_prof",
				"branchbank_cash",
				"branchbank_deposit"
			}
		},
		bain_jobs = {
			complete_job = true,
			contract = "bain",
			challenge_stat = "bain_jobs"
		},
		vlad_jobs = {
			complete_job = true,
			contract = "vlad",
			challenge_stat = "vlad_jobs"
		},
		hector_jobs = {
			complete_job = true,
			contract = "hector",
			challenge_stat = "hector_jobs"
		},
		elephant_jobs = {
			complete_job = true,
			contract = "the_elephant",
			challenge_stat = "elephant_jobs"
		},
		dentist_jobs = {
			complete_job = true,
			contract = "the_dentist",
			challenge_stat = "dentist_jobs"
		},
		butcher_jobs = {
			complete_job = true,
			contract = "the_butcher",
			challenge_stat = "butcher_jobs"
		},
		any_jobs = {
			complete_job = true,
			challenge_stat = "any_jobs"
		},
		monthly_rats = {
			challenge_award = "monthly_rats",
			need_full_job = true,
			jobs = {
				"alex"
			},
			difficulty = overkill_and_above,
			equipped_team = {
				num_skills = 0,
				armor = "level_1",
				primaries = {
					"wpn_fps_ass_amcar"
				},
				secondaries = {
					"wpn_fps_pis_g17"
				}
			}
		},
		monthly_firestarter = {
			challenge_award = "monthly_firestarter",
			need_full_job = true,
			jobs = {
				"firestarter"
			},
			difficulty = overkill_and_above,
			equipped_team = {
				num_skills = 0,
				armor = "level_1",
				primaries = {
					"wpn_fps_ass_amcar"
				},
				secondaries = {
					"wpn_fps_pis_g17"
				}
			}
		},
		monthly_shadowraid = {
			challenge_award = "monthly_shadowraid",
			job = "kosugi",
			need_full_job = true,
			difficulty = overkill_and_above,
			equipped_team = {
				num_skills = 0,
				armor = "level_1",
				primaries = {
					"wpn_fps_ass_amcar"
				},
				secondaries = {
					"wpn_fps_pis_g17"
				}
			}
		},
		challenge_safehouse_raid = {
			need_full_job = true,
			challenge_stat = "challenge_safehouse_raid",
			jobs = {
				"chill_combat"
			}
		},
		challenge_xmas_white = {
			need_full_job = true,
			challenge_award = "challenge_xmas_white",
			jobs = {
				"pines"
			}
		},
		challenge_xmas_santas = {
			need_full_job = true,
			challenge_award = "challenge_xmas_santas",
			jobs = {
				"cane"
			}
		},
		challenge_xmas_stealing = {
			need_full_job = true,
			challenge_award = "challenge_xmas_stealing",
			jobs = {
				"moon"
			}
		},
		challenge_art_ghost = {
			everyone_killed_by_melee = 0,
			challenge_award = "challenge_art_ghost",
			everyone_killed_by_weapons = 0,
			job = "gallery",
			everyone_killed_by_grenade = 0,
			stealth = true,
			secured = {
				carry_id = "painting",
				total_amount = 9
			}
		},
		challenge_cookoff_mutated = {
			need_full_job = true,
			challenge_award = "challenge_cookoff_mutated",
			mutators = 6,
			job = "rat"
		},
		challenge_mallcrasher_stealth = {
			need_full_job = true,
			challenge_award = "challenge_mallcrasher_stealth",
			stealth = true,
			job = "mallcrasher"
		},
		challenge_rats_pacifist = {
			need_full_job = true,
			challenge_award = "challenge_rats_pacifist",
			job = "alex",
			memory = {
				is_shortterm = false
			}
		},
		challenge_crime_spree = {
			crime_spree = true,
			challenge_stat = "challenge_crime_spree"
		},
		challenge_walking_nightmare = {
			need_full_job = true,
			challenge_award = "challenge_walking_nightmare",
			jobs = {
				"pines",
				"cane",
				"moon"
			},
			mutators = {
				"MutatorTitandozers"
			}
		},
		challenge_clone_1 = {
			challenge_award = "challenge_clone_1",
			need_full_job = true,
			difficulty = overkill_and_above,
			jobs = {
				"hox"
			},
			mutators = {
				{
					id = "MutatorEnemyReplacer",
					override_enemy = "tank"
				}
			}
		},
		challenge_clone_2 = {
			challenge_award = "challenge_clone_2",
			need_full_job = true,
			difficulty = overkill_and_above,
			jobs = {
				"welcome_to_the_jungle_wrapper_prof",
				"welcome_to_the_jungle_night_prof",
				"welcome_to_the_jungle_prof"
			},
			mutators = {
				{
					id = "MutatorEnemyReplacer",
					override_enemy = "taser"
				}
			}
		},
		challenge_clone_3 = {
			challenge_award = "challenge_clone_3",
			need_full_job = true,
			difficulty = overkill_and_above,
			jobs = {
				"watchdogs_wrapper",
				"watchdogs_night",
				"watchdogs"
			},
			mutators = {
				{
					id = "MutatorEnemyReplacer",
					override_enemy = "shield"
				}
			}
		},
		challenge_clone_4 = {
			challenge_award = "challenge_clone_4",
			need_full_job = true,
			difficulty = overkill_and_above,
			jobs = {
				"help"
			},
			mutators = {
				{
					id = "MutatorEnemyReplacer",
					override_enemy = "spooc"
				}
			}
		},
		challenge_clone_5 = {
			challenge_award = "challenge_clone_5",
			need_full_job = true,
			difficulty = overkill_and_above,
			jobs = {
				"red2"
			},
			mutators = {
				{
					id = "MutatorEnemyReplacer",
					override_enemy = "medic"
				}
			}
		},
		monthly_prison = {
			everyone_killed_by_grenade = 0,
			challenge_award = "monthly_prison",
			everyone_killed_by_weapons = 0,
			job = "help",
			difficulty = overkill_and_above
		},
		monthly_tabula = {
			challenge_award = "monthly_tabula",
			crime_spree = 100,
			equipped_team = {
				num_skills = 0,
				primaries = {
					"wpn_fps_ass_amcar"
				},
				secondaries = {
					"wpn_fps_pis_g17"
				}
			}
		},
		trophy_transport_crossroads = {
			trophy_stat = "trophy_transport_crossroads",
			level_id = "arm_cro",
			difficulty = overkill_and_above
		},
		trophy_transport_downtown = {
			trophy_stat = "trophy_transport_downtown",
			level_id = "arm_hcm",
			difficulty = overkill_and_above
		},
		trophy_transport_harbor = {
			trophy_stat = "trophy_transport_harbor",
			level_id = "arm_fac",
			difficulty = overkill_and_above
		},
		trophy_transport_park = {
			trophy_stat = "trophy_transport_park",
			level_id = "arm_par",
			difficulty = overkill_and_above
		},
		trophy_transport_underpass = {
			trophy_stat = "trophy_transport_underpass",
			level_id = "arm_und",
			difficulty = overkill_and_above
		},
		trophy_transport_train = {
			trophy_stat = "trophy_transport_train",
			level_id = "arm_for",
			difficulty = overkill_and_above
		},
		trophy_escapes = {
			trophy_stat = "trophy_escapes",
			levels = {
				"escape_cafe",
				"escape_cafe_day",
				"escape_park",
				"escape_park_day",
				"escape_street",
				"escape_overpass",
				"escape_garage"
			}
		},
		trophy_basics_stealth = {
			job = "short1",
			trophy_stat = "trophy_basics_stealth"
		},
		trophy_basics_loud = {
			job = "short2",
			trophy_stat = "trophy_basics_loud"
		},
		trophy_car_shop = {
			job = "cage",
			trophy_stat = "trophy_car_shop"
		},
		trophy_golden_grin = {
			trophy_stat = "trophy_golden_grin",
			used_weapon_category = "pistol",
			difficulty = deathwish_and_above,
			jobs = {
				"kenaz"
			},
			equipped = {
				primaries = {
					category = "pistol",
					blueprint_part_data = {
						sub_type = "silencer"
					}
				},
				secondaries = {
					category = "pistol",
					blueprint_part_data = {
						sub_type = "silencer"
					}
				}
			}
		},
		trophy_nightclub_dw = {
			stealth = true,
			trophy_stat = "trophy_nightclub_dw",
			job = "nightclub",
			difficulty = deathwish_and_above
		},
		trophy_tiara = {
			trophy_stat = "trophy_tiara",
			job = "ukrainian_job_prof",
			difficulty = deathwish_and_above,
			equipped_team = {
				deployable = "ecm_jammer",
				reverse_deployable = true
			}
		},
		trophy_train_bomb = {
			trophy_stat = "trophy_train_bomb",
			difficulty = deathwish_and_above,
			jobs = {
				"crojob_wrapper",
				"crojob2",
				"crojob2_night"
			}
		},
		trophy_shoutout = {
			timer = 420,
			trophy_stat = "trophy_shoutout",
			job = "shoutout_raid",
			difficulty = overkill_and_above
		},
		trophy_stealth = {
			stealth = true,
			trophy_stat = "trophy_stealth",
			complete_job = true,
			difficulty = overkill_and_above
		},
		trophy_bank_heists = {
			trophy_stat = "trophy_bank_heists",
			difficulty = overkill_and_above,
			jobs = {
				"branchbank_prof",
				"branchbank_gold_prof",
				"branchbank_cash",
				"branchbank_deposit"
			}
		},
		trophy_carshop_stealth = {
			trophy_stat = "trophy_carshop_stealth",
			job = "cage",
			equipped_team = {
				reverse_deployable = true,
				deployable = "ecm_jammer",
				detection = {
					max = 100,
					min = 70
				}
			}
		},
		trophy_watchout = {
			trophy_stat = "trophy_watchout",
			need_full_job = true,
			used_weapon_category = "snp",
			total_accuracy = 100,
			jobs = {
				"watchdogs_wrapper",
				"watchdogs_night",
				"watchdogs"
			},
			equipped = {
				primaries = {
					category = "snp"
				}
			}
		},
		trophy_piggy_bank = {
			trophy_stat = "trophy_piggy_bank",
			job = "big",
			difficulty = overkill_and_above,
			equipped_team = {
				num_skills = 0
			}
		},
		trophy_jfk = {
			everyone_killed_by_melee = 0,
			everyone_killed_by_grenade = 0,
			job = "man",
			everyone_used_weapon_category = "snp",
			trophy_stat = "trophy_jfk",
			difficulty = overkill_and_above,
			equipped_team = {
				armor = "level_1",
				num_skills = 0,
				primary_category = "snp"
			}
		},
		trophy_dance = {
			killed_by_weapons = 0,
			killed_by_melee = 0,
			job = "nightclub",
			trophy_stat = "trophy_dance",
			killed_by_grenade = 0,
			equipped_team = {
				deployable = "trip_mine"
			}
		},
		trophy_fbi = {
			trophy_stat = "trophy_fbi",
			stealth = true,
			levels = {
				"firestarter_2"
			}
		},
		trophy_host = {
			need_full_job = true,
			trophy_stat = "trophy_host",
			is_host = true
		},
		trophy_framing_frame = {
			need_full_stealth = true,
			trophy_stat = "trophy_framing_frame",
			need_full_job = true,
			difficulty = overkill_and_above,
			jobs = {
				"framing_frame"
			}
		},
		trophy_courtesy = {
			complete_job = true,
			job = "pbr",
			trophy_stat = "trophy_courtesy",
			difficulty = easywish_and_above,
			killed = {
				medic = 0
			}
		},
		trophy_evolution = {
			complete_job = true,
			trophy_stat = "trophy_evolution",
			mutators = true
		},
		trophy_flawless = {
			complete_job = true,
			num_players = 4,
			trophy_stat = "trophy_flawless",
			difficulty = deathwish_and_above,
			mutators = {
				"MutatorFriendlyFire"
			},
			memory = {
				is_shortterm = false
			}
		},
		trophy_defender = {
			complete_job = true,
			trophy_stat = "trophy_defender",
			difficulty = overkill_and_above,
			jobs = {
				"chill_combat"
			}
		},
		trophy_friendly_car = {
			stealth = false,
			complete_job = true,
			job = "friend",
			num_players = 4,
			trophy_stat = "trophy_friendly_car",
			difficulty = easywish_and_above,
			equipped_team = {
				num_skills = 0,
				perk_deck = 14
			}
		},
		trophy_fish_trophy = {
			need_full_job = true,
			trophy_stat = "trophy_fish_trophy",
			job = "fish",
			equipped_team = {
				detection = {
					max = 100,
					min = 75
				}
			}
		},
		trophy_glace_completion = {
			trophy_stat = "trophy_glace_completion",
			job = "glace",
			difficulty = normal_and_above
		},
		daily_classics = {
			trophy_stat = "daily_classics",
			jobs = {
				"red2",
				"flat",
				"dinner",
				"pal",
				"man",
				"run",
				"glace",
				"dah"
			}
		},
		daily_discord = {
			converted_cops = 1,
			trophy_stat = "daily_discord"
		},
		daily_fwtd = {
			everyone_killed_by_melee = 0,
			everyone_killed_by_grenade = 0,
			job = "red2",
			trophy_stat = "daily_fwtd",
			difficulty = overkill_and_above,
			everyone_weapons_used = {
				"sentry_gun",
				"swat_van_turret_module"
			}
		},
		daily_gears = {
			trophy_stat = "daily_gears",
			difficulty = overkill_and_above,
			jobs = {
				"arm_cro",
				"arm_und",
				"arm_hcm",
				"arm_fac",
				"arm_par",
				"arm_for"
			},
			equipped_team = {
				primaries = {
					"wpn_fps_saw"
				},
				secondaries = {
					"wpn_fps_saw_secondary"
				}
			},
			memory = {
				is_shortterm = true
			}
		},
		daily_spacetime = {
			need_full_job = true,
			trophy_stat = "daily_spacetime",
			jobs = {
				"hox"
			},
			characters = {
				"old_hoxton"
			}
		},
		daily_night_out = {
			trophy_stat = "daily_night_out",
			everyone_killed_by_weapons = 0,
			job = "nightclub"
		},
		daily_naked = {
			trophy_stat = "daily_naked",
			difficulty = overkill_and_above,
			jobs = {
				"pbr",
				"pbr2"
			},
			equipped_team = {
				perk_deck = 3,
				armor = "level_1",
				num_skills = 0
			}
		},
		daily_ninja = {
			killed_by_weapons = 0,
			trophy_stat = "daily_ninja",
			job = "arm_cro",
			equipped_outfit = {
				grenade = {
					"wpn_prj_ace",
					"wpn_prj_four",
					"wpn_prj_jav",
					"wpn_prj_hur",
					"wpn_prj_target",
					"chico_injector",
					"smoke_screen_grenade"
				}
			}
		},
		daily_whats_stealth = {
			job = "kosugi",
			need_full_job = true,
			trophy_stat = "daily_whats_stealth",
			difficulty = deathwish_and_above,
			equipped_team = {
				armor = "level_7"
			},
			memory = {
				is_shortterm = true
			}
		},
		daily_akimbo = {
			trophy_stat = "daily_akimbo",
			total_accuracy = 80,
			equipped_outfit = {
				primary_category = "akimbo"
			},
			equipped = {
				secondaries = {
					category = "pistol",
					blueprint_part_data = {
						sub_type = "silencer"
					}
				}
			}
		},
		story_basics_stealth = {
			job = "short1",
			story = "story_basics_stealth"
		},
		story_basics_loud = {
			job = "short2",
			story = "story_basics_loud"
		},
		story_jewelry_store = {
			job = "jewelry_store",
			story = "story_jewelry_store"
		},
		story_bank_heist = {
			story = "story_bank_heist",
			jobs = {
				"branchbank_prof",
				"branchbank_gold_prof",
				"branchbank_cash",
				"branchbank_deposit"
			}
		},
		story_go_bank = {
			job = "roberts",
			story = "story_go_bank"
		},
		story_diamond_store = {
			job = "family",
			story = "story_diamond_store"
		},
		story_transport_mult = {
			story = "story_transport_mult",
			jobs = {
				"arm_cro",
				"arm_hcm",
				"arm_fac",
				"arm_par",
				"arm_und",
				"arm_for"
			}
		},
		story_train_heist = {
			job = "arm_for",
			story = "story_train_heist"
		},
		story_hard_mallcrasher = {
			job = "mallcrasher",
			story = "story_hard_mallcrasher",
			difficulty = hard_and_above
		},
		story_hard_four_store = {
			job = "four_stores",
			story = "story_hard_four_store",
			difficulty = hard_and_above
		},
		story_hard_white_xmas = {
			job = "pines",
			story = "story_hard_white_xmas",
			difficulty = hard_and_above
		},
		story_hard_ukrainian_job = {
			job = "ukrainian_job_prof",
			story = "story_hard_ukrainian_job",
			difficulty = hard_and_above
		},
		story_hard_meltdown = {
			job = "shoutout_raid",
			story = "story_hard_meltdown",
			difficulty = hard_and_above
		},
		story_hard_aftershock = {
			job = "jolly",
			story = "story_hard_aftershock",
			difficulty = hard_and_above
		},
		story_hard_stealing_xmas = {
			job = "moon",
			story = "story_hard_stealing_xmas",
			difficulty = hard_and_above
		},
		story_hard_nightclub = {
			job = "nightclub",
			story = "story_hard_nightclub",
			difficulty = hard_and_above
		},
		story_very_hard_watchdog = {
			story = "story_very_hard_watchdog",
			jobs = {
				"watchdogs_wrapper",
				"watchdogs_night",
				"watchdogs"
			},
			difficulty = veryhard_and_above
		},
		story_very_hard_firestarter = {
			job = "firestarter",
			story = "story_very_hard_firestarter",
			difficulty = veryhard_and_above
		},
		story_very_hard_rats = {
			job = "alex",
			story = "story_very_hard_rats",
			difficulty = veryhard_and_above
		},
		story_very_hard_big_oil = {
			story = "story_very_hard_big_oil",
			jobs = {
				"welcome_to_the_jungle_wrapper_prof",
				"welcome_to_the_jungle_night_prof",
				"welcome_to_the_jungle_prof"
			},
			difficulty = veryhard_and_above
		},
		story_very_hard_framing_frames = {
			job = "framing_frame",
			story = "story_very_hard_framing_frames",
			difficulty = veryhard_and_above
		},
		story_very_hard_election_day = {
			job = "election_day",
			story = "story_very_hard_election_day",
			difficulty = veryhard_and_above
		},
		story_very_hard_big_bank = {
			job = "big",
			story = "story_very_hard_big_bank",
			difficulty = veryhard_and_above
		},
		story_very_hard_hotline_miami = {
			job = "mia",
			story = "story_very_hard_hotline_miami",
			difficulty = veryhard_and_above
		},
		story_very_hard_hoxton_breakout = {
			job = "hox",
			story = "story_very_hard_hoxton_breakout",
			difficulty = veryhard_and_above
		},
		story_very_hard_hoxton_revenge = {
			job = "hox_3",
			story = "story_very_hard_hoxton_revenge",
			difficulty = veryhard_and_above
		},
		story_very_hard_diamond = {
			job = "mus",
			story = "story_very_hard_diamond",
			difficulty = veryhard_and_above
		},
		story_very_hard_golden_grin = {
			job = "kenaz",
			story = "story_very_hard_golden_grin",
			difficulty = veryhard_and_above
		},
		story_very_hard_bomb_dockyard = {
			job = "crojob1",
			story = "story_very_hard_bomb_dockyard",
			difficulty = veryhard_and_above
		},
		story_very_hard_bomb_forest = {
			story = "story_very_hard_bomb_forest",
			jobs = {
				"crojob_wrapper",
				"crojob2",
				"crojob2_night"
			},
			difficulty = veryhard_and_above
		},
		story_very_hard_scarface = {
			job = "friend",
			story = "story_very_hard_scarface",
			difficulty = veryhard_and_above
		},
		story_very_hard_alesso = {
			job = "arena",
			story = "story_very_hard_alesso",
			difficulty = veryhard_and_above
		},
		story_very_hard_counterfeit = {
			job = "pal",
			story = "story_very_hard_counterfeit",
			difficulty = veryhard_and_above
		},
		story_very_hard_first_world_bank = {
			job = "red2",
			story = "story_very_hard_first_world_bank",
			difficulty = veryhard_and_above
		},
		story_very_hard_murky_station = {
			job = "dark",
			story = "story_very_hard_murky_station",
			difficulty = veryhard_and_above
		},
		story_very_hard_boiling_point = {
			job = "mad",
			story = "story_very_hard_boiling_point",
			difficulty = veryhard_and_above
		},
		story_very_hard_goat_sim = {
			job = "peta",
			story = "story_very_hard_goat_sim",
			difficulty = veryhard_and_above
		},
		story_very_hard_santas_workshop = {
			job = "cane",
			story = "story_very_hard_santas_workshop",
			difficulty = veryhard_and_above
		},
		story_very_hard_car_shop = {
			job = "cage",
			story = "story_very_hard_car_shop",
			difficulty = veryhard_and_above
		},
		story_very_hard_biker_heist = {
			job = "born",
			story = "story_very_hard_biker_heist",
			difficulty = veryhard_and_above
		},
		story_very_hard_panic_room = {
			job = "flat",
			story = "story_very_hard_panic_room",
			difficulty = veryhard_and_above
		},
		story_very_hard_brooklyn_10_10 = {
			job = "spa",
			story = "story_very_hard_brooklyn_10_10",
			difficulty = veryhard_and_above
		},
		story_very_hard_yacht = {
			job = "fish",
			story = "story_very_hard_yacht",
			difficulty = veryhard_and_above
		},
		story_very_hard_undercover = {
			job = "man",
			story = "story_very_hard_undercover",
			difficulty = veryhard_and_above
		},
		story_very_hard_slaughterhouse = {
			job = "dinner",
			story = "story_very_hard_slaughterhouse",
			difficulty = veryhard_and_above
		},
		story_very_hard_beneath_the_mountain = {
			job = "pbr",
			story = "story_very_hard_beneath_the_mountain",
			difficulty = veryhard_and_above
		},
		story_very_hard_birth_of_sky = {
			job = "pbr2",
			story = "story_very_hard_birth_of_sky",
			difficulty = veryhard_and_above
		},
		story_very_hard_heat_street = {
			job = "run",
			story = "story_very_hard_heat_street",
			difficulty = veryhard_and_above
		},
		story_very_hard_green_bridge = {
			job = "glace",
			story = "story_very_hard_green_bridge",
			difficulty = veryhard_and_above
		},
		story_very_hard_alaskan_deal = {
			job = "wwh",
			story = "story_very_hard_alaskan_deal",
			difficulty = veryhard_and_above
		},
		story_very_hard_diamond_heist = {
			job = "dah",
			story = "story_very_hard_diamond_heist",
			difficulty = veryhard_and_above
		},
		story_very_hard_reservoir_dogs = {
			job = "rvd",
			story = "story_very_hard_reservoir_dogs",
			difficulty = veryhard_and_above
		},
		story_very_hard_brooklyn_bank = {
			job = "brb",
			story = "story_very_hard_brooklyn_bank",
			difficulty = veryhard_and_above
		},
		story_very_hard_breakin_feds = {
			job = "tag",
			story = "story_very_hard_breakin_feds",
			difficulty = veryhard_and_above
		},
		story_very_hard_henrys_rock = {
			job = "des",
			story = "story_very_hard_henrys_rock",
			difficulty = veryhard_and_above
		},
		story_very_hard_sah = {
			job = "sah",
			story = "story_very_hard_sah",
			difficulty = veryhard_and_above
		},
		story_very_hard_bph = {
			job = "bph",
			story = "story_very_hard_bph",
			difficulty = veryhard_and_above
		},
		story_very_hard_nmh = {
			job = "nmh",
			story = "story_very_hard_nmh",
			difficulty = veryhard_and_above
		},
		story_very_hard_vit = {
			job = "vit",
			story = "story_very_hard_vit",
			difficulty = veryhard_and_above
		},
		challenge_srtd = {
			everyone_killed_by_melee = 0,
			everyone_killed_by_grenade = 0,
			job = "chill_combat",
			challenge_award = "challenge_srtd",
			difficulty = overkill_and_above,
			everyone_weapons_used = {
				"sentry_gun",
				"swat_van_turret_module"
			}
		},
		challenge_geneva = {
			complete_job = true,
			challenge_award = "challenge_geneva",
			job = "red2",
			difficulty = overkill_and_above,
			killed = {
				medic = 0
			}
		}
	}
	self.check_equipment_memory_on_leave = {
		self.complete_heist_achievements.daily_whats_stealth,
		self.complete_heist_achievements.daily_gears
	}
	self.complete_heist_statistics_achievements = {
		immortal_ballot = {
			num_players = 4,
			award = "ovk_5",
			total_downs = 0,
			levels = {
				"election_day_3",
				"election_day_3_skip1",
				"election_day_3_skip2"
			},
			difficulty = deathwish_and_above
		},
		full_two_twenty = {
			num_players = 4,
			total_kills = 120,
			award = "ovk_7",
			total_accuracy = 120
		},
		berry_4 = {
			is_dropin = false,
			award = "berry_4",
			level_id = "pbr",
			total_downs = 0,
			difficulty = overkill_and_above
		},
		flat_5 = {
			success = true,
			level_id = "flat",
			award = "flat_5",
			total_accuracy = 200
		},
		daily_professional = {
			trophy_stat = "daily_professional",
			difficulty = overkill_and_above,
			total_headshots = {
				invert = true,
				amount = 0
			}
		}
	}
	self.loot_cash_achievements = {
		mallrunner = {
			award = "ameno_3",
			total_value = 1800000,
			total_time = 50,
			jobs = {
				"mallcrasher"
			},
			difficulties = {
				"overkill_145"
			}
		},
		cane_5 = {
			award = "cane_5",
			job = "cane",
			no_deployable = true,
			no_assets = true,
			secured = {
				carry_id = "present",
				total_amount = 10
			}
		},
		pal_2 = {
			award = "pal_2",
			job = "pal",
			secured = {
				carry_id = "counterfeit_money",
				value = 1000000
			}
		},
		dah_9 = {
			award = "dah_9",
			job = "dah",
			difficulties = overkill_and_above,
			secured = {
				carry_id = "red_diamond",
				amount = 1
			}
		},
		trophy_tfturret = {
			trophy_stat = "trophy_tfturret",
			is_dropin = false,
			jobs = {
				"arm_for"
			},
			difficulties = overkill_and_above,
			secured = {
				{
					carry_id = "ammo",
					total_amount = 20
				},
				{
					carry_id = "turret",
					total_amount = 3
				}
			}
		},
		daily_mortage = {
			trophy_stat = "daily_mortage",
			is_dropin = false,
			jobs = {
				"family"
			},
			secured = {
				carry_id = "diamonds",
				total_amount = 16
			}
		},
		daily_toast = {
			trophy_stat = "daily_toast",
			is_dropin = false,
			jobs = {
				"pines"
			},
			secured = {
				carry_id = "sandwich",
				amount = 1
			}
		},
		daily_lodsofemone = {
			trophy_stat = "daily_lodsofemone",
			secured = {
				carry_id = "money",
				amount = 1
			}
		},
		daily_heirloom = {
			trophy_stat = "daily_heirloom",
			is_dropin = false,
			jobs = {
				"kosugi"
			},
			secured = {
				carry_id = "samurai_suit",
				total_amount = 4
			}
		},
		daily_candy = {
			trophy_stat = "daily_candy",
			secured = {
				{
					amount = 1,
					carry_id = {
						"coke",
						"coke_light",
						"coke_pure",
						"present",
						"yayo"
					}
				}
			}
		},
		daily_art = {
			trophy_stat = "daily_art",
			is_dropin = false,
			jobs = {
				"gallery"
			},
			secured = {
				carry_id = "painting",
				total_amount = 9
			}
		},
		trophy_coke = {
			trophy_stat = "trophy_coke",
			jobs = {
				"friend"
			},
			secured = {
				{
					amount = 1,
					carry_id = {
						"yayo"
					}
				}
			}
		},
		story_shadow_raid_bags = {
			amount = 1,
			story = "story_shadow_raid_bags",
			jobs = {
				"kosugi"
			}
		}
	}
	self.job_list = {
		vlad = {
			"ukrainian_job_prof",
			"mallcrasher",
			"four_stores",
			"nightclub",
			"pines",
			"shoutout_raid",
			"jolly",
			"cane",
			"peta",
			"moon"
		},
		hector = {
			"watchdogs_wrapper",
			"alex",
			"firestarter"
		},
		the_elephant = {
			"framing_frame",
			"welcome_to_the_jungle_wrapper_prof",
			"election_day",
			"born"
		},
		bain = {
			"jewelry_store",
			"family",
			"roberts",
			"branchbank_prof",
			"branchbank_gold_prof",
			"branchbank_cash",
			"branchbank_deposit",
			"arm_cro",
			"arm_hcm",
			"arm_fac",
			"arm_par",
			"arm_und",
			"arm_for",
			"kosugi",
			"gallery",
			"rat",
			"cage",
			"arena",
			"rvd"
		},
		the_dentist = {
			"big",
			"mia",
			"hox",
			"mus",
			"hox_3",
			"kenaz"
		},
		the_butcher = {
			"crojob_wrapper",
			"crojob1",
			"friend"
		},
		classic = {
			"red2",
			"dinner",
			"pal",
			"man",
			"flat",
			"run",
			"glace",
			"dah",
			"nmh"
		},
		locke = {
			"pbr",
			"pbr2",
			"wwh",
			"brb",
			"tag",
			"des",
			"sah",
			"bph",
			"vit"
		},
		jimmy = {
			"mad",
			"dark"
		},
		events = {
			"nail",
			"help",
			"haunted",
			"hvh"
		},
		the_continental = {
			"spa",
			"fish"
		}
	}
	self.persistent_stat_unlocks = {
		gage_9_stats = {
			{
				award = "gage_9",
				at = 100
			}
		},
		halloween_4_stats = {
			{
				award = "halloween_4",
				at = 50
			}
		},
		halloween_5_stats = {
			{
				award = "halloween_5",
				at = 25
			}
		},
		halloween_6_stats = {
			{
				award = "halloween_6",
				at = 666
			}
		},
		halloween_7_stats = {
			{
				award = "halloween_7",
				at = 50
			}
		},
		armored_8_stat = {
			{
				award = "armored_8",
				at = 7
			}
		},
		armored_10_stat = {
			{
				award = "armored_10",
				at = 61
			}
		},
		gage2_3_stats = {
			{
				award = "gage2_3",
				at = 50
			}
		},
		scorpion_1_stats = {
			{
				award = "scorpion_1",
				at = 100
			}
		},
		gage_10_stats = {
			{
				award = "gage_10",
				at = 100
			}
		},
		halloween_8_stats = {
			{
				award = "halloween_8",
				at = 666
			}
		},
		armored_5_stat = {
			{
				award = "armored_5",
				at = 378
			}
		},
		armored_7_stat = {
			{
				award = "armored_7",
				at = 69
			}
		},
		armored_9_stat = {
			{
				award = "armored_9",
				at = 95
			}
		},
		gage_1_stats = {
			{
				award = "gage_1",
				at = 100
			}
		},
		gage_2_stats = {
			{
				award = "gage_2",
				at = 100
			}
		},
		gage_3_stats = {
			{
				award = "gage_3",
				at = 100
			}
		},
		gage_4_stats = {
			{
				award = "gage_4",
				at = 100
			}
		},
		gage_5_stats = {
			{
				award = "gage_5",
				at = 100
			}
		},
		gage_6_stats = {
			{
				award = "gage_6",
				at = 100
			}
		},
		gage_7_stats = {
			{
				award = "gage_7",
				at = 100
			}
		},
		gage3_12_stats = {
			{
				award = "gage3_12",
				at = 10
			}
		},
		gage3_2_stats = {
			{
				award = "gage3_2",
				at = 6
			}
		},
		gage3_3_stats = {
			{
				award = "gage3_3",
				at = 50
			}
		},
		gage3_4_stats = {
			{
				award = "gage3_4",
				at = 100
			}
		},
		gage3_5_stats = {
			{
				award = "gage3_5",
				at = 250
			}
		},
		gage3_6_stats = {
			{
				award = "gage3_6",
				at = 500
			}
		},
		gage3_7_stats = {
			{
				award = "gage3_7",
				at = 25
			}
		},
		gage3_11_stats = {
			{
				award = "gage3_11",
				at = 10
			}
		},
		gage3_13_stats = {
			{
				award = "gage3_13",
				at = 10
			}
		},
		gage3_14_stats = {
			{
				award = "gage3_14",
				at = 25
			}
		},
		gage3_17_stats = {
			{
				award = "gage3_17",
				at = 250
			}
		},
		gage4_6_stats = {
			{
				award = "gage4_6",
				at = 50
			}
		},
		gage4_8_stats = {
			{
				award = "gage4_8",
				at = 10
			}
		},
		gage4_10_stats = {
			{
				award = "gage4_10",
				at = 10
			}
		},
		gage5_1_stats = {
			{
				award = "gage5_1",
				at = 25
			}
		},
		gage5_9_stats = {
			{
				award = "gage5_9",
				at = 10
			}
		},
		gage5_10_stats = {
			{
				award = "gage5_10",
				at = 200
			}
		},
		eagle_1_stats = {
			{
				award = "eagle_1",
				at = 25
			}
		},
		ameno_08_stats = {
			{
				award = "ameno_8",
				at = 100
			}
		},
		pim_1_stats = {
			{
				award = "pim_1",
				at = 30
			}
		},
		pim_3_stats = {
			{
				award = "pim_3",
				at = 45
			}
		},
		grv_3_stats = {
			{
				award = "grv_3",
				at = 300
			}
		},
		gmod_1_stats = {
			{
				award = "gmod_1",
				at = 5
			}
		},
		gmod_2_stats = {
			{
				award = "gmod_2",
				at = 10
			}
		},
		gmod_3_stats = {
			{
				award = "gmod_3",
				at = 15
			}
		},
		gmod_4_stats = {
			{
				award = "gmod_4",
				at = 20
			}
		},
		gmod_5_stats = {
			{
				award = "gmod_5",
				at = 25
			}
		},
		gage5_5_stats = {
			{
				award = "gage5_5",
				at = 25
			}
		},
		pim_2_stats = {
			{
				award = "pim_2",
				at = 8
			}
		},
		tango_2_stats = {
			{
				award = "tango_achieve_2",
				at = 50
			}
		},
		gage2_9_stats = {
			{
				award = "gage2_9",
				at = 15
			}
		},
		gage4_7_stats = {
			{
				award = "gage4_7",
				at = 25
			}
		},
		gage5_8_stats = {
			{
				award = "gage5_8",
				at = 25
			}
		},
		pig_3_stats = {
			{
				award = "pig_3",
				at = 30
			}
		},
		eagle_2_stats = {
			{
				award = "eagle_2",
				at = 25
			}
		},
		halloween_10_stats = {
			{
				award = "halloween_10",
				at = 25
			}
		},
		armored_4_stat = {
			{
				award = "armored_4",
				at = 15
			}
		},
		gage3_10_stats = {
			{
				award = "gage3_10",
				at = 10
			}
		},
		gage3_15_stats = {
			{
				award = "gage3_15",
				at = 25
			}
		},
		gage3_16_stats = {
			{
				award = "gage3_16",
				at = 25
			}
		},
		eng_1_stats = {
			{
				award = "eng_1",
				at = 5
			}
		},
		eng_2_stats = {
			{
				award = "eng_2",
				at = 5
			}
		},
		eng_3_stats = {
			{
				award = "eng_3",
				at = 5
			}
		},
		eng_4_stats = {
			{
				award = "eng_4",
				at = 5
			}
		},
		rvd_12_stats = {
			{
				award = "rvd_12",
				at = 92
			}
		},
		cac_3_stats = {
			{
				award = "cac_3",
				at = 30
			}
		},
		cac_7_stats = {
			{
				award = "cac_7",
				at = 1000000000
			}
		},
		cac_34_stats = {
			{
				award = "cac_34",
				at = 300
			}
		},
		cac_35_stats = {
			{
				award = "cac_35",
				at = 10
			}
		},
		bph_9_stat = {
			{
				award = "bph_9",
				at = 13
			}
		}
	}
	local jobs = {}
	local job_data = nil
	local available_jobs = {}

	for _, job_id in ipairs(tweak_data.narrative:get_jobs_index()) do
		if tweak_data.narrative:job_data(job_id).contact ~= "wip" and tweak_data.narrative:job_data(job_id).contact ~= "tests" then
			jobs[job_id] = true
			available_jobs[job_id] = tweak_data.narrative:job_data(job_id).contact
		end
	end

	for _, list in pairs(self.job_list) do
		for _, job_id in pairs(list) do
			if tweak_data.narrative:has_job_wrapper(job_id) then
				available_jobs[job_id] = nil

				for _, job_id in ipairs(tweak_data.narrative:job_data(job_id).job_wrapper) do
					available_jobs[job_id] = nil
				end
			elseif jobs[job_id] then
				available_jobs[job_id] = nil
			else
				Application:debug("[TWEAKDATA:ACHIEVEMENTS] Job missing in narrative", job_id)
			end
		end
	end

	if table.size(available_jobs) > 0 then
		Application:debug("[TWEAKDATA:ACHIEVEMENTS] Jobs not yet in achievement 'job_list':", inspect(available_jobs))
	end

	self.complete_heist_stats_achievements = {
		easywish_vlad = {
			award = "pick_62",
			contact = "vlad",
			difficulty = easywish_and_above
		},
		easywish_hector = {
			award = "pick_63",
			contact = "hector",
			difficulty = easywish_and_above
		},
		easywish_elephant = {
			award = "pick_64",
			contact = "the_elephant",
			difficulty = easywish_and_above
		},
		easywish_bain = {
			award = "pick_65",
			contact = "bain",
			difficulty = easywish_and_above
		},
		death_vlad = {
			award = "death_5",
			contact = "vlad",
			difficulty = deathwish_and_above
		},
		death_hector = {
			award = "death_9",
			contact = "hector",
			difficulty = deathwish_and_above
		},
		death_elephant = {
			award = "death_12",
			contact = "the_elephant",
			difficulty = deathwish_and_above
		},
		death_bain = {
			award = "death_26",
			contact = "bain",
			difficulty = deathwish_and_above
		},
		sm_vlad = {
			award = "axe_62",
			one_down = true,
			contact = "vlad",
			difficulty = sm_wish_and_above
		},
		sm_hector = {
			award = "axe_63",
			one_down = true,
			contact = "hector",
			difficulty = sm_wish_and_above
		},
		sm_elephant = {
			award = "axe_64",
			one_down = true,
			contact = "the_elephant",
			difficulty = sm_wish_and_above
		},
		sm_bain = {
			award = "axe_65",
			one_down = true,
			contact = "bain",
			difficulty = sm_wish_and_above
		},
		skull_hard = {
			award = "death_27",
			contact = "all",
			difficulty = hard_and_above
		},
		skull_very_hard = {
			award = "death_28",
			contact = "all",
			difficulty = veryhard_and_above
		},
		skull_overkill = {
			award = "death_29",
			contact = "all",
			difficulty = overkill_and_above
		},
		skull_easywish = {
			award = "pick_66",
			contact = "all",
			difficulty = easywish_and_above
		},
		skull_deathwish = {
			award = "death_30",
			contact = "all",
			difficulty = deathwish_and_above
		},
		skull_smwish = {
			award = "axe_66",
			contact = "all",
			difficulty = sm_wish_and_above
		},
		trk_a_0 = {
			award = "trk_a_0",
			contact = "all",
			difficulty = normal_and_above
		},
		trk_b_0 = {
			award = "trk_b_0",
			contact = "bain",
			difficulty = normal_and_above
		},
		trk_b_1 = {
			award = "trk_b_1",
			contact = "bain",
			difficulty = hard_and_above
		},
		trk_b_2 = {
			award = "trk_b_2",
			contact = "bain",
			difficulty = veryhard_and_above
		},
		trk_b_3 = {
			award = "trk_b_3",
			contact = "bain",
			difficulty = overkill_and_above
		},
		trk_c_0 = {
			award = "trk_c_0",
			contact = "the_continental",
			difficulty = normal_and_above
		},
		trk_c_1 = {
			award = "trk_c_1",
			contact = "the_continental",
			difficulty = hard_and_above
		},
		trk_c_2 = {
			award = "trk_c_2",
			contact = "the_continental",
			difficulty = veryhard_and_above
		},
		trk_c_3 = {
			award = "trk_c_3",
			contact = "the_continental",
			difficulty = overkill_and_above
		},
		trk_c_4 = {
			award = "trk_c_4",
			contact = "the_continental",
			difficulty = easywish_and_above
		},
		trk_c_5 = {
			award = "trk_c_5",
			contact = "the_continental",
			difficulty = deathwish_and_above
		},
		trk_c_6 = {
			award = "trk_c_6",
			one_down = true,
			contact = "the_continental",
			difficulty = sm_wish_and_above
		},
		trk_cb_0 = {
			award = "trk_cb_0",
			contact = "the_butcher",
			difficulty = normal_and_above
		},
		trk_cb_1 = {
			award = "trk_cb_1",
			contact = "the_butcher",
			difficulty = hard_and_above
		},
		trk_cb_2 = {
			award = "trk_cb_2",
			contact = "the_butcher",
			difficulty = veryhard_and_above
		},
		trk_cb_3 = {
			award = "trk_cb_3",
			contact = "the_butcher",
			difficulty = overkill_and_above
		},
		trk_cb_4 = {
			award = "trk_cb_4",
			contact = "the_butcher",
			difficulty = easywish_and_above
		},
		trk_cb_5 = {
			award = "trk_cb_5",
			contact = "the_butcher",
			difficulty = deathwish_and_above
		},
		trk_cb_6 = {
			award = "trk_cb_6",
			one_down = true,
			contact = "the_butcher",
			difficulty = sm_wish_and_above
		},
		trk_cc_0 = {
			award = "trk_cc_0",
			contact = "classic",
			difficulty = normal_and_above
		},
		trk_cc_1 = {
			award = "trk_cc_1",
			contact = "classic",
			difficulty = hard_and_above
		},
		trk_cc_2 = {
			award = "trk_cc_2",
			contact = "classic",
			difficulty = veryhard_and_above
		},
		trk_cc_3 = {
			award = "trk_cc_3",
			contact = "classic",
			difficulty = overkill_and_above
		},
		trk_cc_4 = {
			award = "trk_cc_4",
			contact = "classic",
			difficulty = easywish_and_above
		},
		trk_cc_5 = {
			award = "trk_cc_5",
			contact = "classic",
			difficulty = deathwish_and_above
		},
		trk_cc_6 = {
			award = "trk_cc_6",
			one_down = true,
			contact = "classic",
			difficulty = sm_wish_and_above
		},
		trk_d_0 = {
			award = "trk_d_0",
			contact = "the_dentist",
			difficulty = normal_and_above
		},
		trk_d_1 = {
			award = "trk_d_1",
			contact = "the_dentist",
			difficulty = hard_and_above
		},
		trk_d_2 = {
			award = "trk_d_2",
			contact = "the_dentist",
			difficulty = veryhard_and_above
		},
		trk_d_3 = {
			award = "trk_d_3",
			contact = "the_dentist",
			difficulty = overkill_and_above
		},
		trk_d_4 = {
			award = "trk_d_4",
			contact = "the_dentist",
			difficulty = easywish_and_above
		},
		trk_d_5 = {
			award = "trk_d_5",
			contact = "the_dentist",
			difficulty = deathwish_and_above
		},
		trk_d_6 = {
			award = "trk_d_6",
			one_down = true,
			contact = "the_dentist",
			difficulty = sm_wish_and_above
		},
		trk_e_0 = {
			award = "trk_e_0",
			contact = "the_elephant",
			difficulty = normal_and_above
		},
		trk_e_1 = {
			award = "trk_e_1",
			contact = "the_elephant",
			difficulty = hard_and_above
		},
		trk_e_2 = {
			award = "trk_e_2",
			contact = "the_elephant",
			difficulty = veryhard_and_above
		},
		trk_e_3 = {
			award = "trk_e_3",
			contact = "the_elephant",
			difficulty = overkill_and_above
		},
		trk_ev_0 = {
			award = "trk_ev_0",
			contact = "events",
			difficulty = normal_and_above
		},
		trk_ev_1 = {
			award = "trk_ev_1",
			contact = "events",
			difficulty = hard_and_above
		},
		trk_ev_2 = {
			award = "trk_ev_2",
			contact = "events",
			difficulty = veryhard_and_above
		},
		trk_ev_3 = {
			award = "trk_ev_3",
			contact = "events",
			difficulty = overkill_and_above
		},
		trk_ev_4 = {
			award = "trk_ev_4",
			contact = "events",
			difficulty = easywish_and_above
		},
		trk_ev_5 = {
			award = "trk_ev_5",
			contact = "events",
			difficulty = deathwish_and_above
		},
		trk_ev_6 = {
			award = "trk_ev_6",
			one_down = true,
			contact = "events",
			difficulty = sm_wish_and_above
		},
		trk_h_0 = {
			award = "trk_h_0",
			contact = "hector",
			difficulty = normal_and_above
		},
		trk_h_1 = {
			award = "trk_h_1",
			contact = "hector",
			difficulty = hard_and_above
		},
		trk_h_2 = {
			award = "trk_h_2",
			contact = "hector",
			difficulty = veryhard_and_above
		},
		trk_h_3 = {
			award = "trk_h_3",
			contact = "hector",
			difficulty = overkill_and_above
		},
		trk_j_0 = {
			award = "trk_j_0",
			contact = "jimmy",
			difficulty = normal_and_above
		},
		trk_j_1 = {
			award = "trk_j_1",
			contact = "jimmy",
			difficulty = hard_and_above
		},
		trk_j_2 = {
			award = "trk_j_2",
			contact = "jimmy",
			difficulty = veryhard_and_above
		},
		trk_j_3 = {
			award = "trk_j_3",
			contact = "jimmy",
			difficulty = overkill_and_above
		},
		trk_j_4 = {
			award = "trk_j_4",
			contact = "jimmy",
			difficulty = easywish_and_above
		},
		trk_j_5 = {
			award = "trk_j_5",
			contact = "jimmy",
			difficulty = deathwish_and_above
		},
		trk_j_6 = {
			award = "trk_j_6",
			one_down = true,
			contact = "jimmy",
			difficulty = sm_wish_and_above
		},
		trk_l_0 = {
			award = "trk_l_0",
			contact = "locke",
			difficulty = normal_and_above
		},
		trk_l_1 = {
			award = "trk_l_1",
			contact = "locke",
			difficulty = hard_and_above
		},
		trk_l_2 = {
			award = "trk_l_2",
			contact = "locke",
			difficulty = veryhard_and_above
		},
		trk_l_3 = {
			award = "trk_l_3",
			contact = "locke",
			difficulty = overkill_and_above
		},
		trk_l_4 = {
			award = "trk_l_4",
			contact = "locke",
			difficulty = easywish_and_above
		},
		trk_l_5 = {
			award = "trk_l_5",
			contact = "locke",
			difficulty = deathwish_and_above
		},
		trk_l_6 = {
			award = "trk_l_6",
			one_down = true,
			contact = "locke",
			difficulty = sm_wish_and_above
		},
		trk_v_0 = {
			award = "trk_v_0",
			contact = "vlad",
			difficulty = normal_and_above
		},
		trk_v_1 = {
			award = "trk_v_1",
			contact = "vlad",
			difficulty = hard_and_above
		},
		trk_v_2 = {
			award = "trk_v_2",
			contact = "vlad",
			difficulty = veryhard_and_above
		},
		trk_v_3 = {
			award = "trk_v_3",
			contact = "vlad",
			difficulty = overkill_and_above
		},
		ggez_1 = {
			award = "ggez_1",
			one_down = true,
			contact = "all",
			difficulty = sm_wish_and_above
		},
		ggez_2 = {
			award = "ggez_2",
			contact = "bain",
			difficulty = sm_wish_and_above
		},
		ggez_3 = {
			award = "ggez_3",
			contact = "classic",
			difficulty = sm_wish_and_above
		},
		ggez_4 = {
			award = "ggez_4",
			contact = "events",
			difficulty = sm_wish_and_above
		},
		ggez_5 = {
			award = "ggez_5",
			contact = "the_dentist",
			difficulty = sm_wish_and_above
		},
		ggez_6 = {
			award = "ggez_6",
			contact = "hector",
			difficulty = sm_wish_and_above
		},
		ggez_7 = {
			award = "ggez_7",
			contact = "jimmy",
			difficulty = sm_wish_and_above
		},
		ggez_8 = {
			award = "ggez_8",
			contact = "locke",
			difficulty = sm_wish_and_above
		},
		ggez_9 = {
			award = "ggez_9",
			contact = "the_butcher",
			difficulty = sm_wish_and_above
		},
		ggez_10 = {
			award = "ggez_10",
			contact = "the_continental",
			difficulty = sm_wish_and_above
		},
		ggez_11 = {
			award = "ggez_11",
			contact = "the_elephant",
			difficulty = sm_wish_and_above
		},
		ggez_12 = {
			award = "ggez_12",
			contact = "vlad",
			difficulty = sm_wish_and_above
		},
		trophy_smwish = {
			one_down = true,
			trophy_stat = "trophy_smwish",
			contact = "all",
			difficulty = sm_wish_and_above
		}
	}
	self.four_mask_achievements = {
		reindeer_games = {
			award = "charliesierra_9",
			masks = {
				"santa_happy",
				"santa_mad",
				"santa_drunk",
				"santa_surprise"
			}
		},
		ghost_riders = {
			award = "bob_10",
			masks = {
				"skullhard",
				"skullveryhard",
				"skulloverkill",
				"skulloverkillplus",
				"gitgud_e_wish",
				"gitgud_sm_wish",
				"dnm"
			}
		},
		funding_father = {
			award = "bigbank_10",
			masks = {
				"franklin",
				"lincoln",
				"grant",
				"washington"
			}
		},
		go_bananas = {
			award = "gage4_12",
			jobs = {
				"alex"
			},
			difficulties = overkill_and_above,
			masks = {
				"silverback",
				"mandril",
				"skullmonkey",
				"orangutang"
			}
		},
		animal_fight = {
			award = "pig_5",
			jobs = {
				"mia"
			},
			difficulties = hard_and_above,
			masks = {
				"white_wolf",
				"owl",
				"rabbit",
				"pig"
			}
		},
		guy_with_gun_now_with_night_jobs = {
			award = "gage5_6",
			jobs = {
				"watchdogs_wrapper",
				"watchdogs",
				"watchdogs_night"
			},
			difficulties = overkill_and_above,
			masks = {
				"galax",
				"crowgoblin",
				"evil",
				"volt"
			}
		},
		wind_of_change = {
			award = "eagle_3",
			jobs = {
				"hox"
			},
			difficulties = overkill_and_above,
			masks = {
				"churchill",
				"red_hurricane",
				"patton",
				"de_gaulle"
			}
		},
		xmas_2014 = {
			award = "deer_6",
			jobs = {
				"pines"
			},
			difficulties = deathwish_and_above,
			masks = {
				"krampus",
				"mrs_claus",
				"strinch",
				"robo_santa"
			}
		},
		blight = {
			award = "bat_5",
			jobs = {
				"mus"
			},
			difficulties = overkill_and_above,
			masks = {
				"medusa",
				"anubis",
				"pazuzu",
				"cursed_crown"
			}
		},
		brb_10 = {
			award = "brb_10",
			job = "brb",
			difficulties = overkill_and_above,
			masks = {
				"cmt_01",
				"cmt_02",
				"cmt_03",
				"cmt_04"
			}
		}
	}
	self.sniper_kill_achievements = {
		did_i_do_that = {
			weapon_type = "snp",
			award = "gage3_9",
			multi_kill = 3
		},
		max_peneration = {
			weapon = "r93",
			stat = "gage3_10_stats",
			obstacle = "shield",
			enemy = "shield"
		},
		you_cant_hide = {
			weapon = "r93",
			stat = "gage3_15_stats",
			obstacle = "wall"
		},
		two_for_one = {
			weapon = "msr",
			stat = "gage3_16_stats",
			multi_kill = 2
		}
	}
	self.inventory = {}
	self.crime_spree = {
		cee_1 = {
			award = "cee_1",
			level = 50
		},
		cee_2 = {
			award = "cee_2",
			level = 100
		},
		cee_3 = {
			award = "cee_3",
			level = 250
		},
		story_crime_spree = {
			story = "story_crime_spree",
			level = 20
		}
	}
	self.medic_heal_achievements = {
		challenge_overheal = {
			total = 50,
			challenge_award = "challenge_overheal"
		}
	}
	local gage_5_1_achievement = {
		max_progress = 25,
		stat = "gage5_1_stats",
		text_id = "bm_wp_gage5_1_achievment"
	}
	local gage_5_2_achievement = {
		award = "gage5_2",
		text_id = "bm_wp_gage5_2_achievment"
	}
	local gage_5_3_achievement = {
		award = "gage5_3",
		text_id = "bm_wp_gage5_3_achievment"
	}
	local gage_5_4_achievement = {
		award = "gage5_4",
		text_id = "bm_wp_gage5_4_achievment"
	}
	local gage_5_5_achievement = {
		max_progress = 25,
		stat = "gage5_5_stats",
		text_id = "bm_wp_gage5_5_achievment"
	}
	local gage_5_6_achievement = {
		award = "gage5_6",
		text_id = "bm_wp_gage5_6_achievment"
	}
	local gage_5_7_achievement = {
		award = "gage5_7",
		text_id = "bm_wp_gage5_7_achievment"
	}
	local gage_5_9_achievement = {
		max_progress = 10,
		stat = "gage5_9_stats",
		text_id = "bm_wp_gage5_9_achievment"
	}
	local gage_5_10_achievement = {
		max_progress = 200,
		stat = "gage5_10_stats",
		text_id = "bm_wp_gage5_10_achievment"
	}
	local pig_1_achievement = {
		award = "pig_1",
		text_id = "bm_wp_pig_1_achievment"
	}
	local pig_2_achievement = {
		award = "pig_2",
		text_id = "bm_wp_pig_2_achievment"
	}
	local pig_3_achievement = {
		max_progress = 25,
		stat = "pig_3_stats",
		text_id = "bm_wp_pig_3_achievment"
	}
	local pig_4_achievement = {
		award = "pig_4",
		text_id = "bm_wp_pig_4_achievment"
	}
	local pig_5_achievement = {
		award = "pig_5",
		text_id = "bm_wp_pig_5_achievment"
	}
	local eagle_1_achievement = {
		max_progress = 25,
		stat = "eagle_1_stats",
		text_id = "bm_wp_eagle_1_achievment"
	}
	local eagle_2_achievement = {
		max_progress = 25,
		stat = "eagle_2_stats",
		text_id = "bm_wp_eagle_2_achievment"
	}
	local eagle_3_achievement = {
		award = "eagle_3",
		text_id = "bm_wp_eagle_3_achievment"
	}
	local eagle_4_achievement = {
		award = "eagle_4",
		text_id = "bm_wp_eagle_4_achievment"
	}
	local eagle_5_achievement = {
		award = "eagle_5",
		text_id = "bm_wp_eagle_5_achievment"
	}
	local ameno_1_achievement = {
		award = "ameno_1",
		text_id = "bm_wp_ameno_1_achievment"
	}
	local ameno_2_achievement = {
		award = "ameno_2",
		text_id = "bm_wp_ameno_2_achievment"
	}
	local ameno_3_achievement = {
		award = "ameno_3",
		text_id = "bm_wp_ameno_3_achievment"
	}
	local ameno_4_achievement = {
		award = "ameno_4",
		text_id = "bm_wp_ameno_4_achievment"
	}
	local ameno_5_achievement = {
		award = "ameno_5",
		text_id = "bm_wp_ameno_5_achievment"
	}
	local ameno_6_achievement = {
		award = "ameno_6",
		text_id = "bm_wp_ameno_6_achievment"
	}
	local ameno_7_achievement = {
		award = "ameno_7",
		text_id = "bm_wp_ameno_7_achievment"
	}
	local ameno_8_achievement = {
		max_progress = 100,
		stat = "ameno_08_stats",
		text_id = "bm_wp_ameno_8_achievment"
	}
	self.mask_tracker = {}
	self.weapon_part_tracker = {
		wpn_fps_snp_m95_barrel_long = {
			max_progress = 25,
			stat = "gage3_7_stats",
			text_id = "bm_wp_m95_b_barrel_long_achievment"
		},
		wpn_fps_snp_r93_b_suppressed = {
			award = "gage3_8",
			text_id = "bm_wp_r93_b_suppressed_achievment"
		},
		wpn_fps_upg_o_45iron = {
			award = "gage3_9",
			text_id = "bm_wp_upg_o_45iron_achievment"
		},
		wpn_fps_snp_r93_b_short = {
			max_progress = 10,
			stat = "gage3_10_stats",
			text_id = "bm_wp_r93_b_short_achievment"
		},
		wpn_fps_snp_m95_barrel_suppressed = {
			max_progress = 10,
			stat = "gage3_11_stats",
			text_id = "bm_wp_m95_b_barrel_suppressed_achievment"
		},
		wpn_fps_snp_m95_barrel_short = {
			max_progress = 10,
			award = "gage3_12_stats",
			text_id = "bm_wp_m95_b_barrel_short_achievment"
		},
		wpn_fps_upg_o_leupold = {
			max_progress = 10,
			stat = "gage3_13_stats",
			text_id = "bm_wp_upg_o_leupold_achievment"
		},
		wpn_fps_snp_msr_body_msr = {
			max_progress = 25,
			stat = "gage3_14_stats",
			text_id = "bm_wp_msr_body_msr_achievment"
		},
		wpn_fps_snp_r93_body_wood = {
			max_progress = 25,
			stat = "gage3_15_stats",
			text_id = "bm_wp_r93_body_wood_achievment"
		},
		wpn_fps_snp_msr_ns_suppressor = {
			max_progress = 25,
			stat = "gage3_16_stats",
			text_id = "bm_wp_snp_msr_ns_suppressor_achievment"
		},
		wpn_fps_snp_msr_b_long = {
			max_progress = 250,
			stat = "gage3_17_stats",
			text_id = "bm_wp_snp_msr_b_long_achievment"
		},
		wpn_fps_ass_fal_fg_01 = {
			award = "bigbank_7",
			text_id = "bm_wp_fal_fg_01_achievment"
		},
		wpn_fps_ass_fal_fg_03 = {
			award = "bigbank_8",
			text_id = "bm_wp_fal_fg_03_achievment"
		},
		wpn_fps_ass_fal_fg_04 = {
			award = "bigbank_3",
			text_id = "bm_wp_fal_fg_04_achievment"
		},
		wpn_fps_ass_fal_fg_wood = {
			award = "bigbank_4",
			text_id = "bm_wp_fal_fg_wood_achievment"
		},
		wpn_fps_ass_fal_s_01 = {
			award = "bigbank_5",
			text_id = "bm_wp_fal_s_01_achievment"
		},
		wpn_fps_ass_fal_s_03 = {
			award = "bigbank_10",
			text_id = "bm_wp_fal_s_03_achievment"
		},
		wpn_fps_ass_fal_s_wood = {
			award = "bigbank_6",
			text_id = "bm_wp_fal_s_wood_achievment"
		},
		wpn_fps_ass_fal_g_01 = {
			award = "bigbank_1",
			text_id = "bm_wp_fal_g_01_achievment"
		},
		wpn_fps_ass_fal_m_01 = {
			award = "bigbank_2",
			text_id = "bm_wp_fal_m_01_achievment"
		},
		wpn_fps_upg_o_mbus_rear = {
			award = "gage4_2",
			text_id = "bm_wp_upg_o_mbus_rear_achievment"
		},
		wpn_fps_sho_ben_b_short = {
			award = "gage4_4",
			text_id = "bm_wp_ben_b_short_achievment"
		},
		wpn_fps_sho_ben_b_long = {
			award = "gage4_5",
			text_id = "bm_wp_ben_b_long_achievment"
		},
		wpn_fps_sho_ben_s_collapsed = {
			max_progress = 50,
			stat = "gage4_6",
			text_id = "bm_wp_ben_s_collapsed_achievment"
		},
		wpn_fps_sho_ksg_b_short = {
			max_progress = 25,
			stat = "gage4_7",
			text_id = "bm_wp_ksg_b_short_achievment"
		},
		wpn_fps_sho_ksg_b_long = {
			max_progress = 10,
			stat = "gage4_8",
			text_id = "bm_wp_ksg_b_long_achievment"
		},
		wpn_fps_sho_ben_s_solid = {
			award = "gage4_9",
			text_id = "bm_wp_ben_s_solid_achievment"
		},
		wpn_fps_sho_striker_b_long = {
			max_progress = 10,
			stat = "gage4_10_stats",
			text_id = "bm_wp_striker_b_long_achievment"
		},
		wpn_fps_sho_striker_b_suppressed = {
			award = "gage4_11",
			text_id = "bm_wp_striker_b_suppressed_achievment"
		},
		wpn_fps_gre_m79_barrel_short = gage_5_5_achievement,
		wpn_fps_gre_m79_stock_short = gage_5_2_achievement,
		wpn_fps_ass_g3_b_sniper = gage_5_1_achievement,
		wpn_fps_ass_g3_fg_psg = gage_5_1_achievement,
		wpn_fps_ass_g3_g_sniper = gage_5_1_achievement,
		wpn_fps_ass_g3_s_sniper = gage_5_1_achievement,
		wpn_fps_ass_g3_b_short = gage_5_4_achievement,
		wpn_fps_ass_g3_fg_retro_plastic = gage_5_4_achievement,
		wpn_fps_ass_g3_fg_railed = gage_5_6_achievement,
		wpn_fps_ass_g3_fg_retro = gage_5_7_achievement,
		wpn_fps_ass_g3_g_retro = gage_5_7_achievement,
		wpn_fps_ass_g3_s_wood = gage_5_7_achievement,
		wpn_fps_ass_galil_s_sniper = gage_5_1_achievement,
		wpn_fps_ass_galil_fg_sniper = gage_5_1_achievement,
		wpn_fps_ass_galil_g_sniper = gage_5_1_achievement,
		wpn_fps_ass_galil_fg_sar = gage_5_6_achievement,
		wpn_fps_ass_galil_fg_mar = gage_5_3_achievement,
		wpn_fps_ass_galil_s_plastic = gage_5_3_achievement,
		wpn_fps_ass_galil_s_light = gage_5_4_achievement,
		wpn_fps_ass_galil_s_wood = gage_5_5_achievement,
		wpn_fps_ass_galil_fg_fab = gage_5_9_achievement,
		wpn_fps_ass_galil_s_fab = gage_5_9_achievement,
		wpn_fps_ass_galil_s_skeletal = gage_5_9_achievement,
		wpn_fps_ass_famas_b_sniper = gage_5_1_achievement,
		wpn_fps_ass_famas_b_short = gage_5_4_achievement,
		wpn_fps_ass_famas_b_long = gage_5_6_achievement,
		wpn_fps_ass_famas_g_retro = gage_5_10_achievement,
		wpn_fps_ass_famas_b_suppressed = gage_5_10_achievement,
		wpn_fps_smg_scorpion_g_ergo = pig_1_achievement,
		wpn_fps_smg_scorpion_m_extended = pig_1_achievement,
		wpn_fps_smg_scorpion_s_unfolded = pig_1_achievement,
		wpn_fps_smg_uzi_fg_rail = pig_2_achievement,
		wpn_fps_smg_uzi_s_leather = pig_2_achievement,
		wpn_fps_smg_uzi_s_solid = pig_3_achievement,
		wpn_fps_smg_scorpion_g_wood = pig_3_achievement,
		wpn_fps_smg_tec9_ns_ext = pig_4_achievement,
		wpn_fps_smg_tec9_m_extended = pig_4_achievement,
		wpn_fps_smg_tec9_s_unfolded = pig_4_achievement,
		wpn_fps_smg_uzi_b_suppressed = pig_5_achievement,
		wpn_fps_smg_uzi_s_standard = pig_5_achievement,
		wpn_fps_smg_scorpion_b_suppressed = pig_5_achievement,
		wpn_fps_smg_scorpion_s_nostock = pig_5_achievement,
		wpn_fps_smg_tec9_b_standard = pig_5_achievement,
		wpn_fps_snp_mosin_b_sniper = eagle_1_achievement,
		wpn_fps_snp_mosin_b_standard = eagle_1_achievement,
		wpn_fps_smg_sterling_b_e11 = eagle_2_achievement,
		wpn_fps_pis_c96_nozzle = eagle_2_achievement,
		wpn_fps_pis_c96_sight = eagle_2_achievement,
		wpn_fps_smg_sterling_b_short = eagle_2_achievement,
		wpn_fps_smg_sterling_b_suppressed = eagle_2_achievement,
		wpn_fps_smg_sterling_m_short = eagle_2_achievement,
		wpn_fps_smg_sterling_s_folded = eagle_2_achievement,
		wpn_fps_smg_sterling_s_nostock = eagle_2_achievement,
		wpn_fps_smg_sterling_s_solid = eagle_2_achievement,
		wpn_fps_snp_mosin_body_black = eagle_3_achievement,
		wpn_fps_pis_c96_b_long = eagle_3_achievement,
		wpn_fps_snp_mosin_b_short = eagle_3_achievement,
		wpn_fps_smg_sterling_m_long = eagle_3_achievement,
		wpn_fps_smg_sterling_b_long = eagle_3_achievement,
		wpn_fps_lmg_mg42_b_vg38 = eagle_3_achievement,
		wpn_fps_pis_c96_m_extended = eagle_4_achievement,
		wpn_fps_pis_c96_s_solid = eagle_4_achievement,
		wpn_fps_lmg_mg42_b_mg34 = eagle_5_achievement,
		wpn_fps_upg_ass_m4_upper_reciever_core = ameno_1_achievement,
		wpn_fps_upg_ass_m4_lower_reciever_core = ameno_1_achievement,
		wpn_fps_upg_ass_m16_fg_stag = ameno_1_achievement,
		wpn_fps_upg_ak_g_rk3 = ameno_2_achievement,
		wpn_fps_upg_ak_fg_zenit = ameno_2_achievement,
		wpn_fps_upg_ass_m4_upper_reciever_ballos = ameno_2_achievement,
		wpn_fps_upg_o_ak_scopemount = ameno_3_achievement,
		wpn_fps_upg_ns_ass_pbs1 = ameno_3_achievement,
		wpn_fps_upg_ass_ak_b_zastava = ameno_4_achievement,
		wpn_fps_upg_ak_m_uspalm = ameno_4_achievement,
		wpn_fps_upg_ass_m4_fg_moe = ameno_5_achievement,
		wpn_fps_upg_smg_olympic_fg_lr300 = ameno_5_achievement,
		wpn_fps_upg_ass_m4_fg_lvoa = ameno_5_achievement,
		wpn_fps_upg_ak_s_solidstock = ameno_6_achievement,
		wpn_fps_upg_m4_s_ubr = ameno_6_achievement,
		wpn_fps_upg_ass_m4_b_beowulf = ameno_7_achievement,
		wpn_fps_upg_m4_m_l5 = ameno_7_achievement,
		wpn_fps_upg_ak_fg_trax = ameno_8_achievement,
		wpn_fps_upg_ak_fg_krebs = ameno_8_achievement,
		wpn_fps_upg_ak_b_ak105 = ameno_8_achievement
	}

	if SystemInfo:platform() == Idstring("PS4") or SystemInfo:platform() == Idstring("XB1") then
		self.weapon_part_tracker = {}
	end

	local default = "guis/dlcs/ami/textures/pd2/milestone_trophy_icon"
	self.milestones = {
		{
			id = "ami_0",
			at = 20,
			coins = 4,
			texture = default
		},
		{
			id = "ami_1",
			at = 50,
			coins = 8,
			texture = default
		},
		{
			at = 90,
			has_drop = true,
			id = "ami_2",
			coins = 12,
			texture = default
		},
		{
			id = "ami_3",
			at = 140,
			coins = 16,
			texture = default
		},
		{
			at = 200,
			has_drop = true,
			id = "ami_4",
			coins = 20,
			texture = default
		},
		{
			id = "ami_5",
			at = 270,
			coins = 24,
			texture = default
		},
		{
			at = 350,
			has_drop = true,
			id = "ami_6",
			coins = 28,
			texture = default
		},
		{
			id = "ami_7",
			at = 450,
			coins = 36,
			texture = default
		},
		{
			at = 550,
			has_drop = true,
			id = "ami_8",
			coins = 36,
			texture = default
		},
		{
			id = "ami_9",
			at = 650,
			coins = 36,
			texture = default
		},
		{
			at = 750,
			has_drop = true,
			id = "ami_10",
			coins = 36,
			texture = default
		},
		{
			id = "ami_11",
			at = 850,
			coins = 36,
			texture = default
		},
		{
			at = 950,
			has_drop = true,
			id = "ami_12",
			coins = 36,
			texture = default
		},
		{
			at = 1000,
			has_drop = true,
			id = "ami_13",
			coins = 36,
			texture = default
		}
	}
	local last_at = 0

	for _, v in ipairs(self.milestones) do
		v.rewards = v.coins and {
			{
				name_id = "menu_cs_coins",
				texture = "guis/dlcs/chill/textures/pd2/safehouse/continental_coins_drop",
				amount = v.coins
			}
		} or {}

		if v.has_drop then
			local data = tweak_data.dlc[v.id]

			for _, loot in ipairs(data.content.loot_drops) do
				local td, data = nil

				if loot.type_items == "armor_skins" then
					td = tweak_data.economy.armor_skins[loot.item_entry]
				else
					td = tweak_data:get_raw_value("blackmarket", loot.type_items, loot.item_entry)
				end

				if v.id == "ami_13" and loot.type_items == "weapon_skins" then
					td = nil
				end

				if td then
					data = get_texture_path(tweak_data, loot.type_items, loot.item_entry)
					data.name_id = td.name_id

					table.insert(v.rewards, data)
				end
			end
		end

		v.last_at = last_at
		last_at = v.at

		if v.id == "ami_13" then
			local tam_weapon_skin_reward = {
				texture = "guis/dlcs/tam/textures/pd2/blackmarket/icons/weapon_skins/tam_achievement_reward",
				name_id = "bm_wskn_tam"
			}

			table.insert(v.rewards, tam_weapon_skin_reward)
		end
	end

	self:_init_visual(tweak_data)
end

local tracking = {
	second = "second",
	realtime = "realtime",
	rarely = "rarely"
}

local function from_complete_heist_stats_item(self, item)
	local heists = nil

	if item.contact == "all" then
		local lists = table.map_values(self.job_list)
		heists = table.list_union(unpack(lists))
	else
		heists = table.list_copy(self.job_list[item.contact])
	end

	local function get_todo()
		local res = table.list_to_set(heists)

		for _, job in pairs(heists) do
			for _, difficulty in ipairs(item.difficulty) do
				if managers.statistics:completed_job(job, difficulty, item.one_down) > 0 then
					res[job] = nil

					break
				end
			end
		end

		return table.map_keys(res)
	end

	return {
		persistent = true,
		is_list = true,
		get_todo_list = get_todo,
		get = function ()
			return #heists - #get_todo()
		end,
		checklist = heists,
		max = #heists,
		update = tracking.rarely
	}
end

local function from_crimespree_item(item)
	return {
		get = function ()
			local rtn = managers.crime_spree:spree_level()

			return rtn == -1 and 0 or rtn
		end,
		max = item.level,
		update = tracking.realtime
	}
end

local function from_level(level)
	if not level then
		error()
	end

	return {
		persistent = true,
		get = function ()
			return managers.experience:current_level()
		end,
		max = level,
		update = tracking.realtime
	}
end

local function from_owned_weapons(num)
	if not num then
		error()
	end

	return {
		persistent = true,
		get = function ()
			return table.size(managers.blackmarket:get_crafted_category("primaries")) + table.size(managers.blackmarket:get_crafted_category("secondaries"))
		end,
		max = num,
		update = tracking.rarely
	}
end

local function from_timed_memory(item, memory_name, count_name)
	count_name = count_name or "count"

	if not memory_name or not item or not item[count_name] then
		error()
	end

	return {
		get = function ()
			local mem = managers.job:get_memory(memory_name, true) or {}
			local t = Application:time()

			return table.count(mem, function (time)
				return t - time < item.timer
			end)
		end,
		max = item[count_name],
		update = tracking.realtime
	}
end

function AchievementsTweakData:_init_visual(tweak_data)
	self.tags = {
		progress = {
			"leveling",
			"beginner",
			"completion",
			"heisting",
			"generic"
		},
		contracts = {
			"all"
		},
		difficulty = {
			"normal",
			"hard",
			"very_hard",
			"overkill",
			"mayhem",
			"death_wish",
			"death_sentence"
		},
		unlock = {
			"mask",
			"weapon",
			"skill_slot",
			"character"
		},
		tactics = {
			"loud",
			"stealth",
			"killer",
			"timed"
		},
		inventory = {
			"mask",
			"weapon",
			"armor",
			"skill",
			"equipment"
		},
		teamwork = {
			"players_1_to_4",
			"players_4"
		}
	}
	local contacts = {}

	for _, job_id in ipairs(tweak_data.narrative:get_jobs_index()) do
		local contact = tweak_data.narrative:job_data(job_id).contact

		if contact ~= "wip" and contact ~= "tests" and not table.contains(self.tags.contracts, contact) then
			table.insert(self.tags.contracts, contact)
		end
	end

	for cat_name, cat in pairs(self.tags) do
		local converted = {}

		for _, tag in pairs(cat) do
			converted[tag] = cat_name .. "_" .. tag
		end

		self.tags[cat_name] = converted
	end

	self.visual = init_auto_generated_achievement_data(self.tags)

	self:_init_non_auto_generated(tweak_data)

	for stat, unlocks in pairs(self.persistent_stat_unlocks) do
		for _, v in pairs(unlocks) do
			local data = self.visual[v.award]

			if not data then
				Application:error("Achievement visual data for '" .. v.award .. "' doesn't exists! (achievement was found in 'persistent_stat_unlocks')")
			elseif type(data.progress) ~= "table" then
				data.progress = {
					persistent = true,
					get = function ()
						return managers.achievment:get_stat(stat)
					end,
					max = v.at,
					update = tracking.second
				}
			end
		end
	end

	for name, data in pairs(tweak_data.dlc) do
		local visual = data.achievement_id and self.visual[data.achievement_id]

		if visual then
			if visual.need_unlock_icons == false then
				visual.need_unlock_icons = nil
			else
				visual.need_unlock_icons = nil
				visual.unlock_icons = visual.unlock_icons or {}
				visual.unlock_id = visual.unlock_id or true

				for _, loot in pairs(data.content.loot_drops) do
					local tex_data = get_texture_path(tweak_data, loot.type_items, loot.item_entry)

					if not table.contains(visual.unlock_icons, tex_data) then
						tex_data.type_items = loot.type_items
						tex_data.original_order = #visual.unlock_icons + 1

						table.insert(visual.unlock_icons, tex_data)
					end
				end

				local sort_order = {
					"characters",
					"weapon_mods",
					"masks",
					"melee_weapons",
					"materials",
					"textures"
				}

				table.sort(visual.unlock_icons, function (lhs, rhs)
					local l = table.index_of(sort_order, lhs.type_items)
					local r = table.index_of(sort_order, rhs.type_items)

					if l == r then
						return lhs.original_order < rhs.original_order
					elseif not l or not r then
						return l
					end

					return l < r
				end)
			end
		elseif data.achievement_id then
			for _, loot in pairs(data.content.loot_drops) do
				get_texture_path(tweak_data, loot.type_items, loot.item_entry)
			end
		end
	end

	for name, data in pairs(self.visual) do
		data.name_id = data.name_id or "achievement_" .. name
		data.desc_id = data.desc_id or "achievement_" .. name .. "_desc"
		data.additional_id = data.additional_id == true and "achievement_" .. name .. "_additional" or data.additional_id
		data.unlock_id = data.unlock_id == true and "achievement_" .. name .. "_unlock" or data.unlock_id
		data.icon_id = data.icon_id or data.sort_name
	end
end

function AchievementsTweakData:_init_non_auto_generated(tweak_data)
	self.visual.bulldog_1.unlock_icons = {
		{
			type_items = "characters",
			type_index = -1,
			original_order = -1,
			texture = "guis/dlcs/trk/textures/pd2/old_hoxton_unlock_icon"
		},
		table.map_append({
			type_items = "melee_weapons",
			type_index = 99,
			original_order = 0
		}, get_texture_path(tweak_data, "melee_weapons", "toothbrush"))
	}
	self.visual.frog_1.unlock_icons = {
		{
			type_items = "kill_slot",
			texture = "guis/dlcs/trk/textures/pd2/skills_slot_unlock_icon"
		}
	}
	self.visual.armored_2.need_unlock_icons = false
	self.visual.fin_1.need_unlock_icons = false

	for k, v in pairs(self.complete_heist_stats_achievements) do
		if v.award and self.visual[v.award] then
			self.visual[v.award].progress = from_complete_heist_stats_item(self, v)
		end
	end

	self.visual.armed_and_dangerous.progress = from_level(self.level_achievements.armed_and_dangerous.level)
	self.visual.big_shot.progress = from_level(self.level_achievements.big_shot.level)
	self.visual.gone_in_30_seconds.progress = from_level(self.level_achievements.gone_in_30_seconds.level)
	self.visual.guilty_of_crime.progress = from_level(self.level_achievements.guilty_of_crime.level)
	self.visual.most_wanted.progress = from_level(self.level_achievements.most_wanted.level)
	self.visual.you_gotta_start_somewhere.progress = from_level(self.level_achievements.you_gotta_start_somewhere.level)

	for id, v in pairs(self.crime_spree) do
		if v.award then
			self.visual[id].progress = from_crimespree_item(v)
		end
	end

	for i, v in pairs(self.infamous) do
		self.visual[v].progress = {
			get = function ()
				return managers.experience:current_rank() or 0
			end,
			max = i
		}
	end

	self.visual.fully_loaded.progress = from_owned_weapons(self.fully_loaded)
	self.visual.gage_8.progress = from_owned_weapons(self.arms_dealer)
	self.visual.weapon_collector.progress = from_owned_weapons(self.weapon_collector)
	self.visual.grill_3.progress = from_timed_memory(self.grenade_achievements.not_invited, "gre_ach_not_invited", "kill_count")
	self.visual.gage4_4.progress = from_timed_memory(self.enemy_kill_achievements.seven_eleven, "seven_eleven")
	self.visual.eagle_5.progress = from_timed_memory(self.enemy_kill_achievements.bullet_hell, "bullet_hell")
	self.visual.scorpion_4.progress = from_timed_memory(self.enemy_kill_achievements.scorpion_4, "scorpion_4")
	self.visual.brooklyn_1.progress = {
		max = 1,
		get = function ()
			return 0
		end,
		update = tracking.realtime
	}
	self.visual.berry_5.progress = {
		get = function ()
			return managers.job:get_memory("berry_5", true) or 0
		end,
		max = self.enemy_kill_achievements.berry_5.count_in_row,
		update = tracking.realtime
	}
	self.visual.turtles_1.progress = {
		get = function ()
			return managers.job:get_memory("kill_count_no_reload_wa2000", true) or 0
		end,
		max = self.enemy_kill_achievements.turtles_1.count_no_reload,
		update = tracking.realtime
	}
	self.visual.grv_2.progress = {
		get = function ()
			return managers.job:get_memory("kill_count_no_reload_coal", true) or 0
		end,
		max = self.enemy_kill_achievements.grv_2.count_no_reload,
		update = tracking.realtime
	}
	local cane_5 = self.loot_cash_achievements.cane_5
	self.visual.cane_5.progress = {
		get = function ()
			local total, _, _ = managers.loot:_count_achievement_secured("cane_5", cane_5.secured)

			return total or 0
		end,
		max = cane_5.secured.total_amount,
		update = tracking.second
	}
	self.visual.gage2_5.progress = {
		get = function ()
			return managers.statistics:session_killed_by_weapon_category(self.first_blood.weapon_type)
		end,
		max = self.first_blood.count,
		update = tracking.realtime
	}
	self.visual.going_places.progress = {
		get = function ()
			return managers.money:total()
		end,
		max = self.going_places,
		update = tracking.realtime
	}
	local pal_2 = self.loot_cash_achievements.pal_2
	self.visual.pal_2.progress = {
		get = function ()
			local _, _, value = managers.loot:_count_achievement_secured("pal_2", pal_2.secured)

			return value or 0
		end,
		max = pal_2.secured.value,
		update = tracking.second
	}
	local steel_2 = self.enemy_melee_hit_achievements.steel_2
	self.visual.steel_2.progress = {
		get = function ()
			if table.contains(steel_2.melee_weapons, managers.blackmarket:equipped_melee_weapon()) then
				return managers.statistics:session_enemy_killed_by_type(steel_2.enemy_kills.enemy, "melee")
			end

			return 0
		end,
		max = steel_2.enemy_kills.count,
		update = tracking.second
	}
	local tango_3 = self.complete_heist_achievements.tango_3
	self.visual.tango_achieve_3.progress = {
		get = function ()
			if not table.contains(tango_3.difficulty, Global.game_settings.difficulty) then
				return 0
			end

			local rtn = 0
			local weapons_to_check = {
				managers.blackmarket:equipped_primary(),
				managers.blackmarket:equipped_secondary()
			}

			for _, weapon_data in ipairs(weapons_to_check) do
				if table.contains(weapon_data.blueprint or {}, tango_3.killed_by_blueprint.blueprint) then
					rtn = rtn + (managers.statistics:session_killed_by_weapon(weapon_data.weapon_id) or 0)
				end
			end

			return rtn
		end,
		max = tango_3.killed_by_blueprint.amount,
		update = tracking.realtime
	}
	self.visual.tango_achieve_4.progress = {
		get = function ()
			local unit = managers.player:equipped_weapon_unit()

			if not unit or not unit:base() then
				return 0
			end

			local data = unit:base()._tango_4_data

			return data and data.count or 0
		end,
		max = self.tango_4.count
	}
	local turtles_2 = self.enemy_kill_achievements.turtles_2
	self.visual.turtles_2.progress = {
		get = function ()
			return managers.statistics:session_killed_by_weapon(turtles_2.weapon) or 0
		end,
		max = turtles_2.kill_count
	}
	self.visual.gage4_3.progress = {
		get = function ()
			return managers.statistics:session_total_killed()[self.close_and_personal.kill_type] or 0
		end,
		max = self.close_and_personal.count
	}
	self.visual.spend_money_to_make_money.progress = {
		get = function ()
			return managers.money:total_spent()
		end,
		max = self.spend_money_to_make_money
	}

	local function dummy_progress()
		return 0
	end

	self.visual.cac_2.progress = {
		max = 0,
		get = dummy_progress,
		update = tracking.realtime
	}
	self.visual.cac_20.progress = {
		max = 7,
		get = function ()
			local masks = {
				"sds_01",
				"sds_02",
				"sds_03",
				"sds_04",
				"sds_05",
				"sds_06",
				"sds_07"
			}
			local count = 0

			for _, mask_id in ipairs(masks) do
				if managers.blackmarket:has_item("halloween", "masks", mask_id) then
					count = count + 1
				end
			end

			return count
		end
	}
end
