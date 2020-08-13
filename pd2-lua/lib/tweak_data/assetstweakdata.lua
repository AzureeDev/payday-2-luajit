AssetsTweakData = AssetsTweakData or class()

function AssetsTweakData:init(tweak_data)
	self:_init_empty_asset(tweak_data)
	self:_init_assets(tweak_data)
	self:_init_risk_assets(tweak_data)
	self:_init_safehouse_assets(tweak_data)
	self:_init_gage_assets(tweak_data)
end

function AssetsTweakData:_init_empty_asset(tweak_data)
	self.none = {
		name_id = nil,
		unlock_desc_id = nil,
		texture = nil,
		stages = nil,
		exclude_stages = nil,
		require_to_unlock = nil,
		visible_if_locked = nil,
		no_mystery = nil,
		saved_job_lock = nil,
		job_lock = nil,
		money_lock = nil,
		upgrade_lock = nil,
		achievment_lock = nil,
		dlc_lock = nil,
		server_lock = nil,
		set_saved_job_value = nil,
		set_job_value = nil,
		award_achievement = nil,
		progress_stat = nil
	}
end

function AssetsTweakData:_init_safehouse_assets(tweak_data)
end

function AssetsTweakData:_init_risk_assets(tweak_data)
	self.risk_pd = {
		name_id = "menu_asset_risklevel_0",
		texture = "guis/textures/pd2/mission_briefing/assets/assets_risklevel_0",
		stages = "all",
		exclude_stages = {
			"safehouse",
			"chill",
			"crojob1",
			"haunted",
			"cage",
			"kosugi",
			"dark",
			"mad",
			"fish"
		},
		risk_lock = 0
	}
	self.risk_swat = {
		name_id = "menu_asset_risklevel_1",
		texture = "guis/textures/pd2/mission_briefing/assets/assets_risklevel_1",
		stages = "all",
		exclude_stages = {
			"safehouse",
			"chill",
			"crojob1",
			"haunted",
			"cage",
			"kosugi",
			"dark",
			"mad",
			"fish"
		},
		risk_lock = 1
	}
	self.risk_fbi = {
		name_id = "menu_asset_risklevel_2",
		texture = "guis/textures/pd2/mission_briefing/assets/assets_risklevel_2",
		stages = "all",
		exclude_stages = {
			"safehouse",
			"chill",
			"crojob1",
			"haunted",
			"cage",
			"kosugi",
			"dark",
			"mad",
			"fish"
		},
		risk_lock = 2
	}
	self.risk_death_squad = {
		name_id = "menu_asset_risklevel_3",
		texture = "guis/textures/pd2/mission_briefing/assets/assets_risklevel_3",
		stages = "all",
		exclude_stages = {
			"safehouse",
			"chill",
			"crojob1",
			"haunted",
			"cage",
			"kosugi",
			"dark",
			"mad",
			"fish"
		},
		risk_lock = 3
	}
	self.risk_easy_wish = {
		name_id = "menu_asset_risklevel_4",
		texture = "guis/textures/pd2/mission_briefing/assets/assets_risklevel_4",
		stages = "all",
		exclude_stages = {
			"safehouse",
			"chill",
			"crojob1",
			"haunted",
			"cage",
			"kosugi",
			"dark",
			"mad",
			"fish"
		},
		risk_lock = 4
	}
	self.risk_death_wish = {
		name_id = "menu_asset_risklevel_5",
		texture = "guis/textures/pd2/mission_briefing/assets/assets_risklevel_5",
		stages = "all",
		exclude_stages = {
			"safehouse",
			"chill",
			"crojob1",
			"haunted",
			"cage",
			"kosugi",
			"dark",
			"mad",
			"fish"
		},
		risk_lock = 5
	}
	self.risk_sm_wish = {
		name_id = "menu_asset_risklevel_6",
		texture = "guis/textures/pd2/mission_briefing/assets/assets_risklevel_6",
		stages = "all",
		exclude_stages = {
			"safehouse",
			"chill",
			"crojob1",
			"haunted",
			"cage",
			"kosugi",
			"dark",
			"mad",
			"fish"
		},
		risk_lock = 6
	}
end

function AssetsTweakData:_init_gage_assets(tweak_data)
	self.gage_assignment = {
		name_id = "menu_asset_gage_assignment",
		texture = "guis/dlcs/gage_pack_jobs/textures/pd2/mission_briefing/assets/gage_assignment",
		stages = "all",
		exclude_stages = {
			"safehouse",
			"chill",
			"chill_combat",
			"haunted",
			"crojob1",
			"short1_stage1",
			"short1_stage2",
			"short2_stage1",
			"short2_stage2b"
		}
	}
end

function AssetsTweakData:_init_assets(tweak_data)
	self.safe_escape = {
		name_id = "menu_asset_safe_escape",
		texture = "guis/textures/pd2/mission_briefing/assets/generic_assets/generic_escape",
		stages = {
			"framing_frame_2",
			"ukrainian_job",
			"jewelry_store",
			"four_stores",
			"nightclub",
			"arm_fac",
			"arm_par",
			"arm_hcm",
			"arm_bri",
			"arm_cro",
			"arm_und",
			"family"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_safe_escape_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_medium", 10),
		upgrade_lock = {
			upgrade = "additional_assets",
			category = "player"
		}
	}
	self.bodybags_bag = {
		name_id = "menu_asset_bodybags_bag",
		texture = "guis/textures/pd2/mission_briefing/assets/generic_assets/bodybags_bag",
		stages = {
			"welcome_to_the_jungle_1",
			"welcome_to_the_jungle_1_night",
			"welcome_to_the_jungle_2",
			"election_day_1",
			"election_day_2",
			"firestarter_2",
			"ukrainian_job",
			"jewelry_store",
			"four_stores",
			"nightclub",
			"arm_for",
			"family",
			"roberts",
			"cage",
			"hox_3",
			"arena",
			"red2",
			"dark",
			"friend",
			"fish",
			"dah",
			"tag",
			"sah",
			"vit"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_bodybags_bag_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 4),
		upgrade_lock = {
			upgrade = "buy_bodybags_asset",
			category = "player"
		}
	}
	self.spotter = {
		name_id = "menu_asset_spotter",
		texture = "guis/textures/pd2/mission_briefing/assets/generic_assets/spotter",
		stages = {
			"election_day_1",
			"election_day_2",
			"firestarter_2"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_spotter_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 8),
		upgrade_lock = {
			upgrade = "buy_spotter_asset",
			category = "player"
		}
	}
	self.grenade_crate = {
		name_id = "menu_asset_grenade_crate",
		texture = "guis/dlcs/gage_pack/textures/pd2/mission_briefing/assets/grenade_crate",
		stages = {
			"watchdogs_1",
			"watchdogs_1_night",
			"watchdogs_2",
			"watchdogs_2_day",
			"welcome_to_the_jungle_1",
			"welcome_to_the_jungle_1_night",
			"welcome_to_the_jungle_2",
			"alex_1",
			"ratatouille",
			"firestarter_1",
			"firestarter_2",
			"arm_for",
			"roberts",
			"election_day_1",
			"election_day_3",
			"election_day_3_skip1",
			"election_day_3_skip2",
			"rat",
			"hox_3",
			"arena",
			"jolly",
			"red2",
			"pbr2",
			"nail",
			"dinner",
			"cane",
			"peta",
			"peta2",
			"man",
			"pal",
			"mad",
			"born",
			"chew",
			"flat",
			"help",
			"moon",
			"friend",
			"spa",
			"glace",
			"run",
			"rvd1",
			"rvd2",
			"dah",
			"wwh",
			"hvh",
			"brb",
			"des",
			"sah",
			"bph",
			"vit",
			"nmh",
			"mex_cooking"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_grenade_crate_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 1),
		dlc_lock = "gage_pack",
		server_lock = true,
		progress_stat = "gage_10_stats"
	}
	self.ammo_bag = {
		name_id = "menu_asset_ammo",
		texture = "guis/textures/pd2/mission_briefing/assets/watch_dogs/day1/asset01",
		stages = {
			"roberts",
			"election_day_1",
			"election_day_2",
			"election_day_3",
			"election_day_3_skip1",
			"election_day_3_skip2",
			"arm_for",
			"rat",
			"hox_3",
			"shoutout_raid",
			"arena",
			"jolly",
			"red2",
			"pbr2",
			"nail",
			"dinner",
			"cane",
			"peta",
			"peta2",
			"man",
			"pal",
			"mad",
			"born",
			"chew",
			"flat",
			"help",
			"moon",
			"friend",
			"spa",
			"glace",
			"run",
			"rvd1",
			"rvd2",
			"dah",
			"wwh",
			"hvh",
			"brb",
			"des",
			"sah",
			"bph",
			"vit",
			"nmh",
			"mex_cooking"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_ammo_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 2)
	}
	self.health_bag = {
		name_id = "menu_asset_health",
		texture = "guis/textures/pd2/mission_briefing/assets/watch_dogs/day1/asset02",
		stages = {
			"roberts",
			"election_day_1",
			"election_day_2",
			"election_day_3",
			"election_day_3_skip1",
			"election_day_3_skip2",
			"arm_for",
			"rat",
			"hox_3",
			"shoutout_raid",
			"arena",
			"jolly",
			"red2",
			"pbr2",
			"nail",
			"dinner",
			"cane",
			"peta",
			"peta2",
			"man",
			"pal",
			"mad",
			"born",
			"chew",
			"flat",
			"help",
			"moon",
			"friend",
			"spa",
			"glace",
			"run",
			"rvd1",
			"rvd2",
			"dah",
			"wwh",
			"hvh",
			"brb",
			"des",
			"sah",
			"bph",
			"vit",
			"nmh",
			"mex_cooking"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_health_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 3)
	}
	self.camera_access = {
		name_id = "menu_asset_cam",
		texture = "guis/textures/pd2/mission_briefing/assets/big_oil/day2/asset03",
		stages = {
			"example_level",
			"friend"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_cam_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 7)
	}
	self.sniper_spot_jewelery = {
		name_id = "menu_asset_sniper_spot",
		texture = "guis/textures/pd2/mission_briefing/assets/jewelery_store/sniper_spot_jewelery",
		stages = {
			"jewelry_store",
			"ukrainian_job"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_sniper_spot_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 4),
		dlc_lock = "gage_pack_snp",
		server_lock = true
	}
	self.sniper_spot_election1 = {
		name_id = "menu_asset_sniper_spot",
		texture = "guis/textures/pd2/mission_briefing/assets/election_day/day1/sniper_spot_election1",
		stages = {
			"election_day_1"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_sniper_spot_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 4),
		dlc_lock = "gage_pack_snp",
		server_lock = true
	}
	self.sniper_spot_election2 = {
		name_id = "menu_asset_sniper_spot",
		texture = "guis/textures/pd2/mission_briefing/assets/election_day/day2/sniper_spot_election2",
		stages = {
			"election_day_2"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_sniper_spot_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 4),
		dlc_lock = "gage_pack_snp",
		server_lock = true
	}
	self.sniper_spot_rats1 = {
		name_id = "menu_asset_sniper_spot",
		texture = "guis/textures/pd2/mission_briefing/assets/rat/day1/sniper_spot_rats1",
		stages = {
			"alex_1",
			"ratatouille",
			"rat"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_sniper_spot_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 4),
		dlc_lock = "gage_pack_snp",
		server_lock = true
	}
	self.sniper_spot_rats3 = {
		name_id = "menu_asset_sniper_spot",
		texture = "guis/textures/pd2/mission_briefing/assets/rat/day3/sniper_spot_rats3",
		stages = {
			"alex_3"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_sniper_spot_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 4),
		dlc_lock = "gage_pack_snp",
		server_lock = true
	}
	self.sniper_spot_firestarter1 = {
		name_id = "menu_asset_sniper_spot",
		texture = "guis/textures/pd2/mission_briefing/assets/firestarter/day1/sniper_spot_firestarter1",
		stages = {
			"firestarter_1"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_sniper_spot_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 4),
		dlc_lock = "gage_pack_snp",
		server_lock = true
	}
	self.ukrainian_job_tiara = {
		name_id = "menu_asset_test_jewelry_store_tiara",
		texture = "guis/textures/pd2/mission_briefing/assets/ukranian_job/asset01",
		stages = {
			"ukrainian_job"
		},
		no_mystery = true
	}
	self.ukrainian_job_front = {
		name_id = "menu_asset_test_jewelry_store_front",
		texture = "guis/textures/pd2/mission_briefing/assets/ukranian_job/asset02",
		stages = {
			"ukrainian_job"
		}
	}
	self.ukrainian_job_cam = {
		name_id = "menu_asset_cam",
		texture = "guis/textures/pd2/mission_briefing/assets/ukranian_job/asset07",
		stages = {
			"ukrainian_job"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_cam_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 6)
	}
	self.ukrainian_job_metal_detector = {
		name_id = "menu_asset_test_jewelry_store_blueprint",
		texture = "guis/textures/pd2/mission_briefing/assets/ukranian_job/asset05",
		stages = {
			"ukrainian_job"
		}
	}
	self.ukrainian_job_shutter = {
		name_id = "menu_asset_test_jewelry_store_code",
		unlock_desc_id = "menu_asset_ukrainian_job_shutter_desc",
		texture = "guis/textures/pd2/mission_briefing/assets/ukranian_job/asset06",
		stages = {
			"ukrainian_job"
		},
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 3)
	}
	self.security_safe_05x05 = {
		name_id = "menu_asset_test_jewelry_store_safe",
		texture = "guis/textures/pd2/mission_briefing/assets/ukranian_job/asset04",
		stages = {
			"ukrainian_job"
		}
	}
	self.welcome_to_the_jungle_keycard = {
		name_id = "menu_asset_welcome_to_the_jungle_keycard",
		unlock_desc_id = "menu_asset_welcome_to_the_jungle_keycard_desc",
		texture = "guis/textures/pd2/mission_briefing/assets/big_oil/day2/asset07",
		stages = {
			"welcome_to_the_jungle_2"
		},
		job_lock = "keycard"
	}
	self.welcome_to_the_jungle_shuttercode = {
		name_id = "menu_asset_welcome_to_the_jungle_shuttercode",
		unlock_desc_id = "menu_asset_welcome_to_the_jungle_shuttercode_desc",
		texture = "guis/textures/pd2/mission_briefing/assets/big_oil/day2/asset02",
		stages = {
			"welcome_to_the_jungle_2"
		},
		job_lock = "shuttercode"
	}
	self.welcome_to_the_jungle_plane_keys = {
		name_id = "menu_asset_welcome_to_the_jungle_plane_keys",
		unlock_desc_id = "menu_asset_welcome_to_the_jungle_plane_keys_desc",
		texture = "guis/textures/pd2/mission_briefing/assets/big_oil/day2/asset05",
		stages = {
			"welcome_to_the_jungle_2"
		},
		job_lock = "planekeys"
	}
	self.welcome_to_the_jungle_blueprints = {
		name_id = "menu_asset_welcome_to_the_jungle_blueprints",
		unlock_desc_id = "menu_asset_welcome_to_the_jungle_blueprints_desc",
		texture = "guis/textures/pd2/mission_briefing/assets/big_oil/day2/asset09",
		stages = {
			"welcome_to_the_jungle_2"
		},
		job_lock = "blueprints"
	}
	self.welcome_to_the_jungle_fusion = {
		name_id = "menu_asset_welcome_to_the_jungle_fusion",
		unlock_desc_id = "menu_asset_welcome_to_the_jungle_fusion_desc",
		texture = "guis/textures/pd2/mission_briefing/assets/big_oil/day2/asset08",
		stages = {
			"welcome_to_the_jungle_2"
		},
		job_lock = "fusion"
	}
	self.welcome_to_the_jungle_guards = {
		name_id = "menu_asset_welcome_to_the_jungle_guards",
		unlock_desc_id = "menu_asset_welcome_to_the_jungle_guards_desc",
		texture = "guis/textures/pd2/mission_briefing/assets/big_oil/day2/asset06",
		stages = {
			"welcome_to_the_jungle_2"
		},
		job_lock = "guards"
	}
	self.welcome_to_the_jungle_rossy = {
		name_id = "menu_asset_welcome_to_the_jungle_rossy",
		unlock_desc_id = "menu_asset_welcome_to_the_jungle_rossy_desc",
		texture = "guis/textures/pd2/mission_briefing/assets/big_oil/day2/asset04",
		stages = {
			"welcome_to_the_jungle_2"
		},
		job_lock = "rossy"
	}
	self.watchdogs_1_ammo = {
		name_id = "menu_asset_ammo",
		texture = "guis/textures/pd2/mission_briefing/assets/watch_dogs/day1/asset01",
		stages = {
			"watchdogs_1",
			"watchdogs_1_night"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_ammo_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 3)
	}
	self.watchdogs_1_health = {
		name_id = "menu_asset_health",
		texture = "guis/textures/pd2/mission_briefing/assets/watch_dogs/day1/asset02",
		stages = {
			"watchdogs_1",
			"watchdogs_1_night"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_health_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 3)
	}
	self.watchdogs_1_escape_car = {
		name_id = "menu_asset_watchdogs_escape",
		texture = "guis/textures/pd2/mission_briefing/assets/watch_dogs/day1/escapecar",
		stages = {
			"watchdogs_1",
			"watchdogs_1_night"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_watchdogs_escape_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 7)
	}
	self.watchdogs_2_ammo = {
		name_id = "menu_asset_ammo",
		texture = "guis/textures/pd2/mission_briefing/assets/watch_dogs/day2/assets_watchdogs2_ammo",
		stages = {
			"watchdogs_2",
			"watchdogs_2_day"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_ammo_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 3)
	}
	self.watchdogs_2_health = {
		name_id = "menu_asset_health",
		texture = "guis/textures/pd2/mission_briefing/assets/watch_dogs/day2/assets_watchdogs2_medic",
		stages = {
			"watchdogs_2",
			"watchdogs_2_day"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_health_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 3)
	}
	self.watchdogs_2_sniper = {
		name_id = "menu_asset_sniper",
		texture = "guis/textures/pd2/mission_briefing/assets/watch_dogs/day2/assets_watchdogs_sniper",
		stages = {
			"watchdogs_2",
			"watchdogs_2_day"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_sniper_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 6)
	}
	self.firestarter_1_ammo = {
		name_id = "menu_asset_ammo",
		texture = "guis/textures/pd2/mission_briefing/assets/watch_dogs/day1/asset01",
		stages = {
			"firestarter_1"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_ammo_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 3)
	}
	self.firestarter_1_health = {
		name_id = "menu_asset_health",
		texture = "guis/textures/pd2/mission_briefing/assets/watch_dogs/day1/asset02",
		stages = {
			"firestarter_1"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_health_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 3)
	}
	self.firestarter_2_cam = {
		name_id = "menu_asset_cam",
		texture = "guis/textures/pd2/mission_briefing/assets/big_oil/day2/asset03",
		stages = {
			"firestarter_2"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_cam_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 7)
	}
	self.firestarter_3_insiderinfo = {
		name_id = "menu_asset_branchbank_insiderinfo",
		texture = "guis/textures/pd2/mission_briefing/assets/bank/assets_bank_insiderinfo",
		stages = {
			"firestarter_3"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_branchbank_insiderinfo_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 2)
	}
	self.firestarter_3_map_basic = {
		name_id = "menu_asset_branchbank_blueprint",
		texture = "guis/textures/pd2/mission_briefing/assets/bank/assets_bank_blueprint",
		stages = {
			"firestarter_3"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_branchbank_blueprint_unlock_desc",
		no_mystery = true
	}
	self.framing_frame_2_sniper = {
		name_id = "menu_asset_sniper",
		texture = "guis/textures/pd2/mission_briefing/assets/framing_frame/day2/asset01",
		stages = {
			"framing_frame_2",
			"born"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_sniper_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 6)
	}
	self.election_day_1_keycard = {
		name_id = "menu_asset_election1_keycard",
		texture = "guis/textures/pd2/mission_briefing/assets/election_day/day1/assets_election_day_1_keycard",
		stages = {
			"election_day_1"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_election1_keycard_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 4)
	}
	self.election_day_2_ladder = {
		name_id = "menu_asset_election2_ladder",
		texture = "guis/textures/pd2/mission_briefing/assets/election_day/day2/assets_election_day_2_ladder",
		stages = {
			"election_day_2"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_election2_ladder_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 3)
	}
	self.election_day_2_keycard = {
		name_id = "menu_asset_election2_keycard",
		texture = "guis/textures/pd2/mission_briefing/assets/election_day/day2/assets_election_day_2_keycard",
		stages = {
			"election_day_2"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_election2_keycard_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 5)
	}
	self.jungle_1_bikers = {
		name_id = "menu_asset_big_oil_1_bikers",
		texture = "guis/textures/pd2/mission_briefing/assets/big_oil/day1/big_oil_1_biker_gang",
		stages = {
			"welcome_to_the_jungle_1",
			"welcome_to_the_jungle_1_night"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_big_oil_1_bikers_desc",
		no_mystery = true
	}
	self.jungle_2_gas = {
		name_id = "menu_asset_jungle_2_gas",
		texture = "guis/textures/pd2/mission_briefing/assets/big_oil/day2/asset01",
		stages = {
			"welcome_to_the_jungle_2"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_jungle_2_gas_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 2)
	}
	self.jungle_2_cam = {
		name_id = "menu_asset_cam",
		texture = "guis/textures/pd2/mission_briefing/assets/big_oil/day2/asset03",
		stages = {
			"welcome_to_the_jungle_2"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_cam_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 2)
	}
	self.jungle_2_ammo = {
		name_id = "menu_asset_jungle_2_ammo",
		texture = "guis/textures/pd2/mission_briefing/assets/watch_dogs/day1/asset01",
		stages = {
			"welcome_to_the_jungle_2"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_jungle_2_ammo_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 2)
	}
	self.rat_1_ammo = {
		name_id = "menu_asset_ammo",
		texture = "guis/textures/pd2/mission_briefing/assets/watch_dogs/day1/asset01",
		texture = "guis/textures/pd2/mission_briefing/assets/watch_dogs/day1/asset01",
		stages = {
			"alex_1",
			"ratatouille"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_ammo_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 3)
	}
	self.rat_1_health = {
		name_id = "menu_asset_health",
		texture = "guis/textures/pd2/mission_briefing/assets/watch_dogs/day1/asset02",
		stages = {
			"alex_1",
			"ratatouille"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_health_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 3)
	}
	self.rat_1_lights = {
		name_id = "menu_asset_lights",
		texture = "guis/textures/pd2/mission_briefing/assets/rat/day1/asset01",
		stages = {
			"alex_1",
			"ratatouille",
			"rat"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_lights_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 3)
	}
	self.rat_3_pilot = {
		name_id = "menu_asset_pilot",
		texture = "guis/textures/pd2/mission_briefing/assets/rat/day3/asset01",
		stages = {
			"alex_3"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_pilot_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 3)
	}
	self.mallcrasher_ammo = {
		name_id = "menu_asset_ammo",
		texture = "guis/textures/pd2/mission_briefing/assets/watch_dogs/day1/asset01",
		stages = {
			"mallcrasher"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_ammo_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 2)
	}
	self.mallcrasher_health = {
		name_id = "menu_asset_health",
		texture = "guis/textures/pd2/mission_briefing/assets/watch_dogs/day1/asset02",
		stages = {
			"mallcrasher"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_health_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 2)
	}
	self.mallcrasher_gascan_south = {
		name_id = "menu_asset_mallcrasher_gascan_south",
		texture = "guis/textures/pd2/mission_briefing/assets/mallcrasher/asset01",
		stages = {
			"mallcrasher"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_mallcrasher_gascan_south_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 2)
	}
	self.mallcrasher_gascan_north = {
		name_id = "menu_asset_mallcrasher_gascan_north",
		texture = "guis/textures/pd2/mission_briefing/assets/mallcrasher/asset02",
		stages = {
			"mallcrasher"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_mallcrasher_gascan_north_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 2)
	}
	self.nightclub_ammo = {
		name_id = "menu_asset_ammo",
		texture = "guis/textures/pd2/mission_briefing/assets/watch_dogs/day1/asset01",
		stages = {
			"nightclub"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_ammo_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 2)
	}
	self.nightclub_health = {
		name_id = "menu_asset_health",
		texture = "guis/textures/pd2/mission_briefing/assets/watch_dogs/day1/asset02",
		stages = {
			"nightclub"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_health_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 2)
	}
	self.nightclub_fire1 = {
		name_id = "menu_asset_nightclub_fire1",
		texture = "guis/textures/pd2/mission_briefing/assets/nightclub/asset04",
		stages = {
			"nightclub"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_nightclub_fire1_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 2)
	}
	self.nightclub_fire2 = {
		name_id = "menu_asset_nightclub_fire2",
		texture = "guis/textures/pd2/mission_briefing/assets/nightclub/asset03",
		stages = {
			"nightclub"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_nightclub_fire2_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 2)
	}
	self.nightclub_badmusic = {
		name_id = "menu_asset_nightclub_badmusic",
		texture = "guis/textures/pd2/mission_briefing/assets/nightclub/asset02",
		stages = {
			"nightclub"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_nightclub_badmusic_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 3)
	}
	self.nightclub_lootpickup = {
		name_id = "menu_asset_nightclub_lootpickup",
		texture = "guis/textures/pd2/mission_briefing/assets/nightclub/asset01",
		stages = {
			"nightclub"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_nightclub_lootpickup_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 5)
	}
	self.four_stores_overview = {
		name_id = "menu_asset_four_stores_overview",
		texture = "guis/textures/pd2/mission_briefing/assets/four_stores/asset01",
		stages = {
			"four_stores"
		}
	}
	self.arm_for_info = {
		name_id = "menu_asset_arm_info",
		texture = "guis/dlcs/dlc1/textures/pd2/mission_briefing/assets/train_01",
		stages = {
			"arm_for"
		}
	}
	self.arm_for_ammo = {
		name_id = "menu_asset_ammo",
		texture = "guis/textures/pd2/mission_briefing/assets/watch_dogs/day1/asset01",
		stages = {
			"arm_cro",
			"arm_und",
			"arm_par",
			"arm_fac",
			"arm_hcm"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_ammo_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 2)
	}
	self.arm_for_health = {
		name_id = "menu_asset_health",
		texture = "guis/textures/pd2/mission_briefing/assets/watch_dogs/day1/asset02",
		stages = {
			"arm_cro",
			"arm_und",
			"arm_par",
			"arm_fac",
			"arm_hcm"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_health_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 3)
	}
	self.arm_cro_info = {
		name_id = "menu_asset_arm_location",
		texture = "guis/dlcs/dlc1/textures/pd2/mission_briefing/assets/arm/crossroads",
		stages = {
			"arm_cro"
		}
	}
	self.arm_fac_info = {
		name_id = "menu_asset_arm_location",
		texture = "guis/dlcs/dlc1/textures/pd2/mission_briefing/assets/arm/harbor",
		stages = {
			"arm_fac"
		}
	}
	self.arm_par_info = {
		name_id = "menu_asset_arm_location",
		texture = "guis/dlcs/dlc1/textures/pd2/mission_briefing/assets/arm/park",
		stages = {
			"arm_par"
		}
	}
	self.arm_hcm_info = {
		name_id = "menu_asset_arm_location",
		texture = "guis/dlcs/dlc1/textures/pd2/mission_briefing/assets/arm/downtown",
		stages = {
			"arm_hcm"
		}
	}
	self.arm_und_info = {
		name_id = "menu_asset_arm_location",
		texture = "guis/dlcs/dlc1/textures/pd2/mission_briefing/assets/arm/underpass",
		stages = {
			"arm_und"
		}
	}
	self.roberts_pilot = {
		name_id = "menu_asset_roberts_pilot",
		texture = "guis/textures/pd2/mission_briefing/assets/roberts/asset_pilot_amateur",
		stages = {
			"roberts"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_roberts_pilot_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_medium", 10)
	}
	self.roberts_plan_a = {
		name_id = "menu_asset_roberts_plan_a",
		texture = "guis/textures/pd2/mission_briefing/assets/roberts/asset_plan_a",
		stages = {
			"roberts"
		},
		visible_if_locked = true,
		no_mystery = true
	}
	self.roberts_plan_b = {
		name_id = "menu_asset_roberts_plan_b",
		texture = "guis/textures/pd2/mission_briefing/assets/roberts/asset_plan_b",
		stages = {
			"roberts"
		},
		visible_if_locked = true,
		no_mystery = true
	}
	self.hox_1 = {
		name_id = "heist_hox_1_asset_armoredcar",
		texture = "guis/textures/pd2/mission_briefing/assets/hoxtonbreakout/assets_hox01_armoredcar",
		stages = {
			"hox_1"
		},
		visible_if_locked = true,
		no_mystery = true
	}
	self.hox_2 = {
		name_id = "heist_hox_2_asset_hooverbuilding",
		texture = "guis/textures/pd2/mission_briefing/assets/hoxtonbreakout/assets_hox02_bldg",
		stages = {
			"hox_2"
		},
		visible_if_locked = true,
		no_mystery = true
	}
	self.crojob1_plan = {
		name_id = "menu_asset_arm_info",
		texture = "guis/textures/pd2/mission_briefing/assets/bcrojob/stage_1/assets_crojob_insiderinfo_bomb",
		stages = {
			"crojob1"
		},
		visible_if_locked = true,
		no_mystery = true
	}
	self.crojob2_plan_a = {
		name_id = "menu_asset_roberts_plan_a",
		texture = "guis/textures/pd2/mission_briefing/assets/crojob/stage_2/assets_crojob_insiderinfo_stealth",
		stages = {
			"crojob2"
		},
		visible_if_locked = true,
		no_mystery = true
	}
	self.crojob2_plan_b = {
		name_id = "menu_asset_roberts_plan_b",
		texture = "guis/textures/pd2/mission_briefing/assets/crojob/stage_2/assets_crojob_insiderinfo_loud",
		stages = {
			"crojob2"
		},
		visible_if_locked = true,
		no_mystery = true
	}
	self.crojob3_plan = {
		name_id = "menu_asset_roberts_plan_a",
		texture = "guis/textures/pd2/mission_briefing/assets/crojob/stage_3/assets_crojob_insiderinfo",
		stages = {
			"crojob3",
			"crojob3_night"
		},
		visible_if_locked = true,
		no_mystery = true
	}
	self.dumpsters = {
		name_id = "menu_asset_dumpsters",
		texture = "guis/textures/pd2/mission_briefing/assets/carshop/asset_carshop_dumpster",
		stages = {
			"cage"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_dumpsters_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 8)
	}
	self.hox_3_alarm = {
		name_id = "heist_hox_3_alarm",
		texture = "guis/textures/pd2/mission_briefing/assets/hox3/asset_hox3_alertbox",
		stages = {
			"hox_3"
		},
		visible_if_locked = true,
		no_mystery = true
	}
	self.extra_cutter = {
		name_id = "menu_asset_extra_cutter",
		texture = "guis/dlcs/dlc_arena/textures/pd2/mission_briefing/assets/asset_arena_metal_cutter",
		stages = {
			"arena"
		},
		visible_if_locked = true,
		server_lock = true,
		no_mystery = true,
		unlock_desc_id = "menu_asset_extra_cutter_desc",
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_medium", 3)
	}
	self.planks = {
		name_id = "menu_asset_planks",
		texture = "guis/dlcs/peta/textures/pd2/mission_briefing/assets/asset_barn_planks",
		stages = {
			"peta2"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_planks_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 8)
	}
	self.mad_briefcase = {
		name_id = "menu_asset_mad_briefcase",
		texture = "guis/dlcs/mad/textures/pd2/mission_briefing/assets/mad_briefcase",
		stages = {
			"mad"
		}
	}
	self.mad_russian_merc_cameras = {
		name_id = "menu_asset_mad_russian_merc",
		texture = "guis/dlcs/mad/textures/pd2/mission_briefing/assets/mad_russian_merc",
		stages = {
			"mad"
		}
	}
	self.dark_emp = {
		name_id = "menu_asset_dark_emp",
		texture = "guis/dlcs/mad/textures/pd2/mission_briefing/assets/dark_emp",
		stages = {
			"dark"
		}
	}
	self.dark_drone = {
		name_id = "menu_asset_dark_drone",
		texture = "guis/dlcs/mad/textures/pd2/mission_briefing/assets/dark_drone",
		stages = {
			"dark"
		}
	}
	self.dark_additional_cameras = {
		name_id = "menu_asset_dark_additional_cameras",
		texture = "guis/dlcs/mad/textures/pd2/mission_briefing/assets/dark_additional_cameras",
		stages = {
			"dark"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_dark_additional_cameras_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 8)
	}
	self.sniper_spot_born = {
		name_id = "menu_asset_sniper_spot_born",
		texture = "guis/dlcs/born/textures/pd2/mission_briefing/assets/assets_born_snipernest",
		stages = {
			"born"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_sniper_spot_born_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 7)
	}
	self.flat_chavez = {
		name_id = "menu_asset_flat_chavez",
		texture = "guis/dlcs/flat/textures/pd2/mission_briefing/assets/flat_chavez",
		stages = {
			"flat"
		}
	}
	self.flat_panic_room_blueprint = {
		name_id = "menu_asset_flat_panic_room_blueprint",
		texture = "guis/dlcs/flat/textures/pd2/mission_briefing/assets/flat_panic_room_blueprint",
		stages = {
			"flat"
		}
	}
	self.flat_recon_photos = {
		name_id = "menu_asset_recon_photos",
		texture = "guis/dlcs/help/textures/pd2/mission_briefing/assets/recon_photos",
		stages = {
			"help"
		}
	}
	self.moon_security_camera = {
		name_id = "menu_asset_moon_security_camera",
		texture = "guis/dlcs/moon/textures/pd2/mission_briefing/assets/moon_security_camera",
		stages = {
			"moon"
		}
	}
	self.moon_mall_pamflet = {
		name_id = "menu_asset_moon_mall_pamflet",
		texture = "guis/dlcs/moon/textures/pd2/mission_briefing/assets/moon_mall_pamflet",
		stages = {
			"moon"
		}
	}
	self.recon_intel = {
		name_id = "menu_asset_recon_intel",
		texture = "guis/dlcs/friend/textures/pd2/mission_briefing/assets/recon_intel",
		stages = {
			"friend"
		},
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 1),
		no_mystery = true
	}
	self.rope_ladder = {
		name_id = "menu_asset_rope_ladder",
		unlock_desc_id = "menu_asset_rope_ladder_desc",
		texture = "guis/dlcs/friend/textures/pd2/mission_briefing/assets/rope_ladder",
		stages = {
			"friend"
		},
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 2),
		no_mystery = true
	}
	self.potential_location = {
		name_id = "menu_asset_potential_location",
		texture = "guis/dlcs/fish/textures/pd2/mission_briefing/assets/potential_location",
		stages = {
			"fish"
		},
		no_mystery = true
	}
	self.colored_tags = {
		name_id = "menu_asset_colored_tags",
		texture = "guis/dlcs/fish/textures/pd2/mission_briefing/assets/colored_tags",
		stages = {
			"fish"
		},
		no_mystery = true
	}
	self.laptop = {
		name_id = "menu_asset_laptop",
		texture = "guis/dlcs/fish/textures/pd2/mission_briefing/assets/laptop",
		stages = {
			"fish"
		},
		no_mystery = true
	}
	self.charon = {
		name_id = "menu_asset_charon",
		texture = "guis/dlcs/spa/textures/pd2/mission_briefing/assets/charon",
		stages = {
			"spa"
		},
		no_mystery = true
	}
	self.location = {
		name_id = "menu_asset_location",
		texture = "guis/dlcs/run/textures/pd2/mission_briefing/assets/location",
		stages = {
			"run"
		},
		no_mystery = true
	}
	self.prison_transport_trucks = {
		name_id = "menu_asset_prison_transport_trucks",
		texture = "guis/dlcs/glace/textures/pd2/mission_briefing/assets/prison_transport_trucks",
		stages = {
			"glace"
		},
		no_mystery = true
	}
	self.asset_sah_ladder = {
		name_id = "menu_asset_sah_ladder",
		texture = "guis/dlcs/sah/textures/pd2/mission_briefing/assets/asset_sah_ladder_df",
		stages = {
			"sah"
		},
		visible_if_locked = true,
		unlock_desc_id = "menu_asset_sah_ladder_desc",
		no_mystery = true,
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 3)
	}
	self.sah_cutter = {
		name_id = "menu_asset_sah_cutter",
		texture = "guis/dlcs/dlc_arena/textures/pd2/mission_briefing/assets/asset_arena_metal_cutter",
		stages = {
			"sah"
		},
		visible_if_locked = true,
		no_mystery = true,
		unlock_desc_id = "menu_asset_sah_cutter_desc",
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_medium", 3)
	}
end

function AssetsTweakData:_init_debug_assets(tweak_data)
	self.debug_1 = {
		name_id = "debug_1",
		texture = "guis/textures/pd2/blackmarket/icons/armors/level_1",
		money_lock = 10,
		stages = {
			"safehouse"
		},
		visible_if_locked = true
	}
	self.debug_2 = {
		name_id = "debug_2",
		texture = "guis/textures/pd2/blackmarket/icons/armors/level_2",
		stages = {
			"safehouse"
		},
		money_lock = 20000
	}
	self.debug_3 = {
		name_id = "debug_3",
		texture = "guis/textures/pd2/blackmarket/icons/armors/level_3",
		stages = {
			"safehouse"
		},
		money_lock = 30,
		visible_if_locked = false
	}
	self.debug_4 = {
		name_id = "debug_4",
		texture = "guis/textures/pd2/blackmarket/icons/armors/level_4",
		stages = {
			"safehouse"
		},
		money_lock = 4000000,
		visible_if_locked = true
	}
	self.debug_5 = {
		name_id = "debug_5",
		texture = "guis/textures/pd2/blackmarket/icons/armors/level_5",
		stages = {
			"safehouse"
		},
		money_lock = 50
	}
	self.debug_6 = {
		name_id = "debug_6",
		texture = "guis/textures/pd2/blackmarket/icons/armors/level_6",
		stages = {
			"safehouse"
		},
		money_lock = 60000000,
		visible_if_locked = true
	}
	self.debug_7 = {
		name_id = "debug_7",
		texture = "guis/textures/pd2/blackmarket/icons/armors/level_7",
		stages = {
			"safehouse"
		},
		money_lock = 700,
		visible_if_locked = true
	}
end

function AssetsTweakData:debug_assets()
	local levels = {}

	for i, level_id in ipairs(tweak_data.levels:get_level_index()) do
		levels[level_id] = 0
	end

	local function f(id)
		if id == "all" then
			for i, d in pairs(levels) do
				levels[i] = levels[i] + 1
			end
		else
			levels[id] = levels[id] + 1
		end
	end

	for id, asset in pairs(self) do
		if id ~= "none" then
			local stages = asset.stages

			if not stages or type(stages) == "string" then
				f(stages)
			else
				for _, lid in ipairs(stages) do
					f(lid)
				end
			end
		end
	end

	local asset_levels = {}

	for i, d in pairs(levels) do
		if d > 0 then
			asset_levels[i] = d
		end
	end

	print(inspect(asset_levels))
end
