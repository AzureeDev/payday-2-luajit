LevelsTweakData = LevelsTweakData or class()
LevelsTweakData.LevelType = {
	America = "america",
	Russia = "russia",
	Zombie = "zombie",
	Murkywater = "murkywater"
}

function LevelsTweakData:init()
	local america = LevelsTweakData.LevelType.America
	local russia = LevelsTweakData.LevelType.Russia
	local zombie = LevelsTweakData.LevelType.Zombie
	local murkywater = LevelsTweakData.LevelType.Murkywater
	self.ai_groups = {
		default = america,
		america = america,
		russia = russia,
		zombie = zombie,
		murkywater = murkywater
	}
	self.framing_frame_1 = {
		name_id = "heist_framing_frame_1_hl",
		briefing_id = "heist_framing_frame_1_briefing",
		briefing_dialog = "Play_pln_framing_stage1_brief",
		world_name = "narratives/e_framing_frame/stage_1",
		intro_event = "Play_pln_framing_stage1_intro_a",
		outro_event = {
			"Play_pln_framing_stage1_end_a",
			"Play_pln_framing_stage1_end_b"
		},
		music = "heist",
		package = {
			"packages/narr_framing_1"
		},
		cube = "cube_apply_heist_bank",
		ghost_bonus = 0.075,
		max_bags = 13,
		ai_group_type = america,
		load_screen = "guis/dlcs/pic/textures/loading/job_framingframe_01"
	}
	self.framing_frame_2 = {
		name_id = "heist_framing_frame_2_hl",
		briefing_id = "heist_framing_frame_2_briefing",
		briefing_dialog = "Play_pln_framing_stage2_brief",
		world_name = "narratives/e_framing_frame/stage_2",
		intro_event = "Play_pln_framing_stage2_intro_a",
		outro_event = {
			"Play_pln_framing_stage2_end_a",
			"Play_pln_framing_stage2_end_b"
		},
		music = "heist",
		package = {
			"packages/narr_framing_2"
		},
		cube = "cube_apply_heist_bank",
		ghost_bonus = 0.025,
		max_bags = 13,
		repossess_bags = true,
		ai_group_type = america,
		load_screen = "guis/dlcs/pic/textures/loading/job_frame02"
	}
	self.framing_frame_3 = {
		name_id = "heist_framing_frame_3_hl",
		briefing_id = "heist_framing_frame_3_briefing",
		briefing_dialog = "Play_pln_framing_stage3_brief",
		world_name = "narratives/e_framing_frame/stage_3",
		intro_event = "Play_pln_framing_stage3_intro",
		outro_event = {
			"Play_pln_framing_stage3_end_a",
			"Play_pln_framing_stage3_end_b",
			"Play_pln_framing_stage3_end_c"
		},
		music = "heist",
		package = "packages/narr_framing_3",
		cube = "cube_apply_heist_bank",
		ghost_bonus = 0.15,
		max_bags = 21,
		ai_group_type = america,
		load_screen = "guis/dlcs/pic/textures/loading/job_framingframe_03"
	}
	self.election_day_1 = {
		name_id = "heist_election_day_1_hl",
		briefing_id = "eday1_brief",
		briefing_dialog = "Play_pln_ed1_brf",
		world_name = "narratives/e_election_day/stage_1",
		intro_event = "Play_pln_ed1_intro_a",
		outro_event = {
			"Play_pln_ed1_end_a",
			"Play_pln_ed1_end_b",
			"Play_pln_ed1_end_c"
		},
		music = "heist",
		package = {
			"packages/narr_election1"
		},
		cube = "cube_apply_heist_bank",
		ghost_bonus = 0.05,
		max_bags = 0,
		ai_group_type = america,
		load_screen = "guis/dlcs/pic/textures/loading/job_electionday_01"
	}
	self.election_day_2 = {
		name_id = "heist_election_day_2_hl",
		briefing_id = "eday2_brief",
		briefing_dialog = "Play_pln_ed2_brf",
		world_name = "narratives/e_election_day/stage_2",
		intro_event = "Play_pln_ed2_intro_a",
		outro_event = {
			"Play_pln_ed2_end_a",
			"Play_pln_ed2_end_b"
		},
		music = "heist",
		package = {
			"packages/narr_election2"
		},
		cube = "cube_apply_heist_bank",
		ghost_bonus = 0.15,
		max_bags = 21,
		ai_group_type = america,
		load_screen = "guis/dlcs/pic/textures/loading/job_electionday_02"
	}
	self.election_day_3 = {
		name_id = "heist_election_day_3_hl",
		briefing_id = "eday3_brief_skip1",
		briefing_dialog = "Play_pln_ed3_brf_b",
		world_name = "narratives/e_election_day/stage_3",
		intro_event = "Play_pln_ed3_intro_a",
		outro_event = "Play_pln_ed3_end_a",
		music = "heist",
		package = "packages/narr_election3",
		cube = "cube_apply_heist_bank",
		max_bags = 16,
		ai_group_type = america,
		load_screen = "guis/dlcs/pic/textures/loading/job_electionday_03"
	}
	self.election_day_3_skip1 = deep_clone(self.election_day_3)
	self.election_day_3_skip1.briefing_id = "eday3_brief_skip1"
	self.election_day_3_skip1.briefing_dialog = "Play_pln_ed3_brf_b"
	self.election_day_3_skip2 = deep_clone(self.election_day_3)
	self.election_day_3_skip2.briefing_id = "eday3_brief_skip2"
	self.election_day_3_skip2.briefing_dialog = "Play_pln_ed3_brf_c"
	self.alex_1 = {
		name_id = "heist_alex_1_hl",
		briefing_id = "heist_alex_1_briefing",
		briefing_dialog = "Play_pln_rat_stage1_brief",
		world_name = "narratives/h_alex_must_die/stage_1",
		intro_event = "Play_pln_rat_stage1_intro_a",
		outro_event = {
			"Play_pln_rat_stage1_end_a",
			"Play_pln_rat_stage1_end_b",
			"Play_pln_rat_stage1_end_c"
		},
		music = "heist",
		package = "packages/narr_alex1",
		cube = "cube_apply_heist_bank",
		max_bags = 11,
		ai_group_type = america,
		load_screen = "guis/dlcs/pic/textures/loading/job_rats01"
	}
	self.alex_2 = {
		name_id = "heist_alex_2_hl",
		briefing_id = "heist_alex_2_briefing",
		briefing_dialog = "Play_pln_rat_stage2_brief",
		world_name = "narratives/h_alex_must_die/stage_2",
		intro_event = "Play_pln_rat_stage2_intro_a",
		outro_event = {
			"Play_pln_rat_stage2_end_a",
			"Play_pln_rat_stage2_end_b",
			"Play_pln_rat_stage2_end_c",
			"Play_pln_rat_stage2_end_d",
			"Play_pln_rat_stage2_end_e"
		},
		music = "heist",
		package = "packages/narr_alex2",
		cube = "cube_apply_heist_bank",
		max_bags = 19,
		repossess_bags = true,
		ai_group_type = america,
		load_screen = "guis/dlcs/pic/textures/loading/job_rats02"
	}
	self.alex_3 = {
		name_id = "heist_alex_3_hl",
		briefing_id = "heist_alex_3_briefing",
		briefing_dialog = "Play_pln_rat_stage3_brief",
		world_name = "narratives/h_alex_must_die/stage_3",
		intro_event = "Play_pln_rat_stage3_intro_a",
		outro_event = {
			"Play_pln_rat_stage3_end_a",
			"Play_pln_rat_stage3_end_b",
			"Play_pln_rat_stage3_end_c"
		},
		music = "heist",
		package = "packages/narr_alex3",
		cube = "cube_apply_heist_bank",
		max_bags = 34,
		ai_group_type = america,
		load_screen = "guis/dlcs/pic/textures/loading/job_rats03"
	}
	self.watchdogs_1 = {
		name_id = "heist_watchdogs_1_hl",
		briefing_id = "heist_watchdogs_1_briefing",
		briefing_dialog = "Play_pln_watchdogs_new_stage1_brief",
		briefing_assets_gui = Idstring("guis/mission_briefing/preload_stage_watchdogs_1"),
		world_name = "narratives/h_watchdogs/stage_1",
		intro_event = "Play_pln_watchdogs_new_stage1_intro_a",
		outro_event = {
			"Play_pln_watchdogs_new_stage1_end_a",
			"Play_pln_watchdogs_new_stage1_end_b"
		},
		music = "heist",
		package = {
			"packages/narr_watchdogs1"
		},
		cube = "cube_apply_heist_bank",
		max_bags = 16,
		ai_group_type = america,
		load_screen = "guis/dlcs/pic/textures/loading/job_watchdogs_01"
	}
	self.watchdogs_1_night = deep_clone(self.watchdogs_1)
	self.watchdogs_1_night.env_params = {
		environment = "environments/pd2_env_night/pd2_env_night"
	}
	self.watchdogs_1_night.package = {
		"packages/narr_watchdogs1_night"
	}
	self.watchdogs_2 = {
		name_id = "heist_watchdogs_2_hl",
		briefing_id = "heist_watchdogs_2_briefing",
		briefing_dialog = "Play_pln_watchdogs_new_stage2_brief",
		briefing_assets_gui = Idstring("guis/mission_briefing/preload_stage_watchdogs_2"),
		world_name = "narratives/h_watchdogs/stage_2",
		intro_event = {
			"Play_pln_watchdogs_new_stage2_intro_a",
			"Play_pln_watchdogs_new_stage2_intro_b"
		},
		outro_event = {
			"Play_pln_watchdogs_new_stage2_end_a",
			"Play_pln_watchdogs_new_stage2_end_b"
		},
		music = "heist",
		package = {
			"packages/narr_watchdogs2"
		},
		cube = "cube_apply_heist_bank",
		max_bags = 16,
		repossess_bags = true,
		ai_group_type = america,
		load_screen = "guis/dlcs/pic/textures/loading/job_watchdogs_02"
	}
	self.watchdogs_2_day = deep_clone(self.watchdogs_2)
	self.watchdogs_2_day.env_params = {
		environment = "environments/pd2_env_wd2_evening/pd2_env_wd2_evening"
	}
	self.watchdogs_2_day.package = {
		"packages/narr_watchdogs2_day"
	}
	self.firestarter_1 = {
		name_id = "heist_firestarter_1_hl",
		briefing_id = "heist_firestarter_1_briefing",
		briefing_dialog = "Play_pln_firestarter_stage1_brief",
		world_name = "narratives/h_firestarter/stage_1",
		intro_event = "Play_pln_firestarter_stage1_intro_a",
		outro_event = {
			"Play_pln_firestarter_stage1_end_a",
			"Play_pln_firestarter_stage1_end_b"
		},
		music = "heist",
		package = "packages/narr_firestarter1",
		cube = "cube_apply_heist_bank",
		max_bags = 16,
		ai_group_type = america,
		load_screen = "guis/dlcs/pic/textures/loading/job_firestarter_01"
	}
	self.firestarter_2 = {
		name_id = "heist_firestarter_2_hl",
		briefing_id = "heist_firestarter_2_briefing",
		briefing_dialog = "Play_pln_firestarter_stage2_brief",
		world_name = "narratives/h_firestarter/stage_2",
		intro_event = "Play_pln_firestarter_stage2_intro_a",
		outro_event = {
			"Play_pln_firestarter_stage2_end_a",
			"Play_pln_firestarter_stage2_end_b"
		},
		music = "heist",
		package = "packages/narr_firestarter2",
		cube = "cube_apply_heist_bank",
		ghost_bonus = 0.15,
		max_bags = 34,
		ai_group_type = america,
		load_screen = "guis/dlcs/pic/textures/loading/job_firestarter_02"
	}
	self.firestarter_3 = {
		name_id = "heist_firestarter_3_hl",
		briefing_id = "heist_firestarter_3_briefing",
		briefing_dialog = "Play_pln_firestarter_stage3_brief",
		world_name = "narratives/h_firestarter/stage_3",
		intro_event = "Play_pln_firestarter_stage3_intro_a",
		outro_event = {
			"Play_pln_firestarter_stage3_end_a",
			"Play_pln_firestarter_stage3_end_b"
		},
		music = "heist",
		package = "packages/narr_firestarter3",
		cube = "cube_apply_heist_bank",
		mission_data = {
			{
				mission = "default"
			}
		},
		ghost_bonus = 0.05,
		max_bags = 54,
		ai_group_type = america,
		load_screen = "guis/dlcs/pic/textures/loading/job_branchbank"
	}
	self.welcome_to_the_jungle_1 = {
		name_id = "heist_welcome_to_the_jungle_1_hl",
		briefing_id = "heist_welcome_to_the_jungle_1_briefing",
		briefing_dialog = "Play_pln_bigoil_stage1_brief",
		briefing_assets_gui = Idstring("guis/mission_briefing/preload_stage_welcome_to_the_jungle_1"),
		world_name = "narratives/e_welcome_to_the_jungle/stage_1",
		intro_event = "Play_pln_bigoil_stage1_intro_a",
		outro_event = {
			"Play_pln_bigoil_stage1_end_a",
			"Play_pln_bigoil_stage1_end_b"
		},
		music = "heist",
		package = {
			"packages/narr_jungle1"
		},
		cube = "cube_apply_heist_bank",
		ghost_bonus = 0.15,
		max_bags = 14,
		ai_group_type = america,
		load_screen = "guis/dlcs/pic/textures/loading/job_bigoil_01"
	}
	self.welcome_to_the_jungle_1_night = deep_clone(self.welcome_to_the_jungle_1)
	self.welcome_to_the_jungle_1_night.env_params = {
		environment = "environments/pd2_env_night/pd2_env_night"
	}
	self.welcome_to_the_jungle_1_night.package = {
		"packages/narr_jungle1_night"
	}
	self.welcome_to_the_jungle_2 = {
		name_id = "heist_welcome_to_the_jungle_2_hl",
		briefing_id = "heist_welcome_to_the_jungle_2_briefing",
		briefing_dialog = "Play_pln_bigoil_stage2_brief",
		briefing_assets_gui = Idstring("guis/mission_briefing/preload_stage_welcome_to_the_jungle_2"),
		world_name = "narratives/e_welcome_to_the_jungle/stage_2",
		intro_event = "Play_pln_bigoil_stage2_intro_a",
		outro_event = {
			"Play_pln_bigoil_stage2_end_a",
			"Play_pln_bigoil_stage2_end_b"
		},
		music = "heist",
		package = {
			"packages/narr_jungle2"
		},
		cube = "cube_apply_heist_bank",
		max_bags = 15,
		ai_group_type = america,
		load_screen = "guis/dlcs/pic/textures/loading/job_bigoil_02"
	}
	self.ukrainian_job = {
		name_id = "heist_ukrainian_job_hl",
		briefing_id = "heist_ukrainian_job_briefing",
		briefing_dialog = "Play_pln_ukranian_stage1_brief",
		briefing_assets_gui = Idstring("guis/mission_briefing/preload_stage_quick_diamond"),
		world_name = "narratives/vlad/ukrainian_job",
		intro_event = "Play_pln_ukranian_stage1_intro_a",
		outro_event = {
			"Play_pln_ukranian_stage1_end_a",
			"Play_pln_ukranian_stage1_end_b",
			"Play_pln_ukranian_stage1_end_c"
		},
		music = "heist",
		package = {
			"packages/ukrainian_job"
		},
		cube = "cube_apply_heist_bank",
		group_ai_preset = "small_urban",
		ghost_bonus = 0.05,
		max_bags = 16,
		ai_group_type = america
	}
	self.four_stores = {
		name_id = "heist_four_stores_hl",
		briefing_id = "heist_four_stores_briefing",
		briefing_dialog = "Play_pln_fourstores_stage1_brief",
		world_name = "narratives/vlad/four_stores",
		intro_event = "Play_pln_fourstores_stage1_intro_a",
		outro_event = {
			"Play_pln_fourstores_stage1_end_a",
			"Play_pln_fourstores_stage1_end_b"
		},
		music = "heist",
		package = "packages/vlad_four_stores",
		cube = "cube_apply_heist_bank",
		ghost_bonus = 0.05,
		max_bags = 5,
		ai_group_type = america
	}
	self.jewelry_store = {
		name_id = "heist_jewelry_store_hl",
		briefing_id = "heist_jewelry_store_briefing",
		briefing_dialog = "pln_jewelrystore_stage1_brf_speak",
		world_name = "narratives/vlad/jewelry_store",
		intro_event = {
			"pln_jewelrystore_stage1_intro_01",
			"pln_jewelrystore_stage1_intro_02",
			"pln_jewelrystore_stage1_intro_03",
			"pln_jewelrystore_stage1_intro_04",
			"pln_jewelrystore_stage1_intro_05",
			"pln_jewelrystore_stage1_intro_06"
		},
		outro_event = "pln_jewelerystore_stage1_end",
		music = "heist",
		package = "packages/ukrainian_job",
		cube = "cube_apply_heist_bank",
		ghost_bonus = 0.05,
		max_bags = 16,
		ai_group_type = america
	}
	self.mallcrasher = {
		name_id = "heist_mallcrasher_hl",
		briefing_id = "heist_mallcrasher_briefing",
		briefing_dialog = "Play_pln_mallcrasch_stage1_brief",
		world_name = "narratives/vlad/mallcrasher",
		intro_event = "Play_pln_mallcrasch_stage1_intro_a",
		outro_event = {
			"Play_pln_mallcrasch_stage1_end_a",
			"Play_pln_mallcrasch_stage1_end_b"
		},
		music = "heist",
		package = "packages/vlad_mallcrasher",
		cube = "cube_apply_heist_bank",
		max_bags = 12,
		ai_group_type = america
	}
	self.nightclub = {
		name_id = "heist_nightclub_hl",
		briefing_id = "heist_nightclub_briefing",
		briefing_dialog = "Play_pln_nightclub_stage1_brief",
		world_name = "narratives/vlad/nightclub",
		intro_event = "Play_pln_nightclub_stage1_intro_a",
		outro_event = {
			"Play_pln_nightclub_stage1_end_a",
			"Play_pln_nightclub_stage1_end_b"
		},
		music = "heist",
		package = "packages/vlad_nightclub",
		cube = "cube_apply_heist_bank",
		ghost_bonus = 0.1,
		max_bags = 28,
		ai_group_type = america
	}
	self.branchbank = {
		name_id = "heist_branchbank_hl",
		briefing_id = "heist_branchbank_briefing",
		briefing_dialog = "Play_pln_branchbank_random_stage1_brief",
		world_name = "narratives/h_firestarter/stage_3",
		intro_event = {
			"Play_pln_branchbank_random_a_intro_a",
			"Play_pln_branchbank_gold_a_intro_a",
			"Play_pln_branchbank_depositbox_a_intro_a",
			"Play_pln_branchbank_cash_stage1_intro_a"
		},
		outro_event = "Play_pln_branchbank_stage1_end",
		ghost_bonus = 0.1,
		max_bags = 24,
		ai_group_type = america,
		music = "heist",
		package = "packages/narr_firestarter3",
		cube = "cube_apply_heist_bank",
		mission_data = {
			{
				mission = "standalone"
			}
		}
	}
	self.escape_cafe_day = {
		name_id = "heist_escape_cafe_hl",
		briefing_id = "heist_escape_cafe_briefing",
		briefing_dialog = "nothing",
		world_name = "narratives/escapes/escape_cafe_day",
		intro_event = "Play_dr1_a01",
		outro_event = "nothing",
		music = "heist",
		package = "packages/escape_cafe",
		cube = "cube_apply_heist_bank",
		ai_group_type = america,
		repossess_bags = true,
		load_screen = "guis/dlcs/pic/textures/loading/escape_cafe"
	}
	self.escape_park_day = {
		name_id = "heist_escape_park_hl",
		briefing_id = "heist_escape_park_briefing",
		briefing_dialog = "nothing",
		world_name = "narratives/escapes/escape_park_day",
		intro_event = "Play_dr1_a01",
		outro_event = "nothing",
		music = "heist",
		package = "packages/escape_park",
		cube = "cube_apply_heist_bank",
		repossess_bags = true,
		load_screen = "guis/dlcs/pic/textures/loading/escape_park"
	}
	self.escape_cafe = {
		name_id = "heist_escape_cafe_hl",
		briefing_id = "heist_escape_cafe_briefing",
		briefing_dialog = "nothing",
		world_name = "narratives/escapes/escape_cafe",
		intro_event = "Play_dr1_a01",
		outro_event = "nothing",
		music = "heist",
		package = "packages/escape_cafe",
		cube = "cube_apply_heist_bank",
		ai_group_type = america,
		repossess_bags = true,
		load_screen = "guis/dlcs/pic/textures/loading/escape_cafe"
	}
	self.escape_park = {
		name_id = "heist_escape_park_hl",
		briefing_id = "heist_escape_park_briefing",
		briefing_dialog = "nothing",
		world_name = "narratives/escapes/escape_park",
		intro_event = "Play_dr1_a01",
		outro_event = "nothing",
		music = "heist",
		package = "packages/escape_park",
		cube = "cube_apply_heist_bank",
		ai_group_type = america,
		repossess_bags = true,
		load_screen = "guis/dlcs/pic/textures/loading/escape_park"
	}
	self.escape_street = {
		name_id = "heist_escape_street_hl",
		briefing_id = "heist_escape_street_briefing",
		briefing_dialog = "nothing",
		world_name = "narratives/escapes/escape_street",
		intro_event = "Play_dr1_a01",
		outro_event = "nothing",
		music = "heist",
		package = "packages/escape_street",
		cube = "cube_apply_heist_bank",
		ai_group_type = america,
		repossess_bags = true,
		load_screen = "guis/dlcs/pic/textures/loading/escape_street"
	}
	self.escape_overpass = {
		name_id = "heist_escape_overpass_hl",
		briefing_id = "heist_escape_overpass_briefing",
		briefing_dialog = "nothing",
		world_name = "narratives/escapes/escape_overpass",
		intro_event = "Play_dr1_a01",
		outro_event = "nothing",
		music = "heist",
		package = "packages/escape_overpass",
		cube = "cube_apply_heist_bank",
		ai_group_type = america,
		repossess_bags = true,
		load_screen = "guis/dlcs/pic/textures/loading/escape_overpass"
	}
	self.escape_overpass_night = deep_clone(self.escape_overpass)
	self.escape_garage = {
		name_id = "heist_escape_garage_hl",
		briefing_id = "heist_escape_garage_briefing",
		briefing_dialog = "nothing",
		world_name = "narratives/escapes/escape_garage",
		intro_event = "Play_dr1_a01",
		outro_event = "nothing",
		music = "heist",
		package = "packages/escape_garage",
		cube = "cube_apply_heist_bank",
		ai_group_type = america,
		repossess_bags = true,
		load_screen = "guis/dlcs/pic/textures/loading/escape_garage"
	}
	self.driving_escapes_industry_day = {
		name_id = "heist_driving_escapes_industry_hl",
		briefing_id = "heist_driving_escapes_industry_briefing",
		ignore_statistics = true,
		briefing_dialog = "nothing",
		world_name = "wip/driving_escapes_industry",
		intro_event = "Play_dr1_a01",
		outro_event = "nothing",
		music = "heist",
		package = "packages/escape_2_industry",
		cube = "cube_apply_heist_bank",
		ai_group_type = america
	}
	self.driving_escapes_city_day = {
		name_id = "heist_driving_escapes_city_hl",
		briefing_id = "heist_driving_escapes_city_briefing",
		ignore_statistics = true,
		briefing_dialog = "nothing",
		world_name = "wip/driving_escapes_city",
		intro_event = "Play_dr1_a01",
		outro_event = "nothing",
		music = "heist",
		package = "packages/escape_2_city",
		cube = "cube_apply_heist_bank",
		ai_group_type = america
	}
	self.safehouse = {
		name_id = "heist_safehouse_hl",
		briefing_id = "heist_safehouse_briefing",
		briefing_dialog = "Play_pln_sh_intro",
		world_name = "narratives/safehouse",
		intro_event = "nothing",
		outro_event = "nothing",
		music = "heist",
		package = "packages/safehouse",
		cube = "cube_apply_heist_bank",
		team_ai_off = true,
		ai_group_type = america
	}
	self.crojob2 = {
		name_id = "heist_crojob2_hl",
		briefing_id = "heist_crojob2_briefing",
		briefing_dialog = "Play_pln_cr2_brf_01",
		world_name = "narratives/butcher/thebomb/stage_2",
		intro_event = "Play_pln_cr2_intro_01",
		outro_event = {
			"butcher_cr1_debrief_01",
			"butcher_cr1_debrief_02"
		},
		music = "heist",
		package = {
			"packages/dlcs/the_bomb/crojob_stage_2"
		},
		cube = "cube_apply_heist_bank",
		ghost_bonus = 0.2,
		max_bags = 21,
		ai_group_type = america
	}
	self.crojob3 = {
		name_id = "heist_crojob3_hl",
		briefing_id = "heist_crojob3_briefing",
		briefing_dialog = "Play_pln_cr3_brf_01",
		world_name = "narratives/butcher/thebomb/stage_3",
		intro_event = "Play_pln_cr3_intro_01",
		outro_event = "lol",
		music = "heist",
		package = {
			"packages/dlcs/the_bomb/crojob_stage_3"
		},
		cube = "cube_apply_heist_bank",
		max_bags = 16,
		ai_group_type = america
	}
	self.crojob3_night = deep_clone(self.crojob3)
	self.crojob3_night.env_params = {
		environment = "environments/pd2_env_cro_night/pd2_env_cro_night"
	}
	self.crojob3_night.package = {
		"packages/dlcs/the_bomb/crojob_stage_3_night"
	}
	self.arm_cro = {
		name_id = "heist_arm_cro_hl",
		briefing_id = "heist_arm_cro_briefing",
		briefing_dialog = "Play_pln_at1_brf_01",
		world_name = "narratives/armadillo/arm_cro",
		intro_event = "Play_pln_at1_intro_02",
		outro_event = {
			"Play_pln_at1_end_01",
			"Play_pln_at1_end_02",
			"Play_pln_at1_end_03",
			"Play_pln_at1_end_01b",
			"Play_pln_at1_end_02b",
			"Play_pln_at1_end_03b"
		},
		music = "heist",
		package = "packages/narr_arm_cro",
		cube = "cube_apply_heist_bank",
		max_bags = 22,
		ai_group_type = america
	}
	self.arm_und = {
		name_id = "heist_arm_und_hl",
		briefing_id = "heist_arm_und_briefing",
		briefing_dialog = "Play_pln_at1_brf_05",
		world_name = "narratives/armadillo/arm_und",
		intro_event = "Play_pln_at1_intro_06",
		outro_event = {
			"Play_pln_at1_end_01",
			"Play_pln_at1_end_02",
			"Play_pln_at1_end_03",
			"Play_pln_at1_end_01b",
			"Play_pln_at1_end_02b",
			"Play_pln_at1_end_03b"
		},
		music = "heist",
		package = "packages/narr_arm_und",
		cube = "cube_apply_heist_bank",
		max_bags = 22,
		ai_group_type = america
	}
	self.arm_hcm = {
		name_id = "heist_arm_hcm_hl",
		briefing_id = "heist_arm_hcm_briefing",
		briefing_dialog = "Play_pln_at1_brf_02",
		world_name = "narratives/armadillo/arm_hcm",
		intro_event = "Play_pln_at1_intro_03",
		outro_event = {
			"Play_pln_at1_end_01",
			"Play_pln_at1_end_02",
			"Play_pln_at1_end_03",
			"Play_pln_at1_end_01b",
			"Play_pln_at1_end_02b",
			"Play_pln_at1_end_03b"
		},
		music = "heist",
		package = "packages/narr_arm_hcm",
		cube = "cube_apply_heist_bank",
		max_bags = 22,
		ai_group_type = america
	}
	self.arm_par = {
		name_id = "heist_arm_par_hl",
		briefing_id = "heist_arm_par_briefing",
		briefing_dialog = "Play_pln_at1_brf_04",
		world_name = "narratives/armadillo/arm_par",
		intro_event = "Play_pln_at1_intro_05",
		outro_event = {
			"Play_pln_at1_end_01",
			"Play_pln_at1_end_02",
			"Play_pln_at1_end_03",
			"Play_pln_at1_end_01b",
			"Play_pln_at1_end_02b",
			"Play_pln_at1_end_03b"
		},
		music = "heist",
		package = "packages/narr_arm_par",
		cube = "cube_apply_heist_bank",
		max_bags = 22,
		ai_group_type = america
	}
	self.arm_fac = {
		name_id = "heist_arm_fac_hl",
		briefing_id = "heist_arm_fac_briefing",
		briefing_dialog = "Play_pln_at1_brf_03",
		world_name = "narratives/armadillo/arm_fac",
		intro_event = "Play_pln_at1_intro_04",
		outro_event = {
			"Play_pln_at1_end_01",
			"Play_pln_at1_end_02",
			"Play_pln_at1_end_03",
			"Play_pln_at1_end_01b",
			"Play_pln_at1_end_02b",
			"Play_pln_at1_end_03b"
		},
		music = "heist",
		package = "packages/narr_arm_fac",
		cube = "cube_apply_heist_bank",
		max_bags = 22,
		ai_group_type = america
	}
	self.arm_for = {
		name_id = "heist_arm_for_hl",
		briefing_id = "heist_arm_for_briefing",
		briefing_dialog = "Play_pln_tr1_brf_01",
		world_name = "narratives/armadillo/arm_for",
		intro_event = "Play_pln_tr1_intro_01",
		outro_event = {
			"Play_pln_tr1_end_01",
			"Play_pln_tr1_end_02"
		},
		music = "heist",
		package = "packages/narr_arm_for",
		cube = "cube_apply_heist_bank",
		bonus_escape = true,
		max_bags = 30,
		ghost_bonus = 0.1,
		ai_group_type = america
	}
	self.family = {
		name_id = "heist_family_hl",
		briefing_id = "heist_family_briefing",
		briefing_dialog = "pln_fj1_brf_01",
		world_name = "narratives/bain/diamond_store",
		intro_event = "Play_pln_fj1_intro_01",
		outro_event = {
			"Play_pln_fj1_end_01",
			"Play_pln_fj1_end_02"
		},
		music = "heist",
		package = "packages/narr_family",
		cube = "cube_apply_heist_bank",
		ghost_bonus = 0.05,
		max_bags = 24,
		ai_group_type = america,
		load_screen = "guis/dlcs/pic/textures/loading/job_diamondstore"
	}
	self.big = {
		name_id = "heist_big_hl",
		briefing_id = "heist_big_briefing",
		briefing_dialog = "Play_pln_bb1_brf_01",
		world_name = "narratives/bain/big",
		intro_event = "Play_pln_bb1_intro_01",
		outro_event = {
			"Play_pln_bb1_end_01",
			"Play_pln_bb1_end_02",
			"Play_pln_bb1_end_03",
			"Play_pln_bb1_end_04"
		},
		music = "big_bank",
		package = "packages/narr_big",
		cube = "cube_apply_heist_bank",
		ghost_bonus = 0.15,
		max_bags = 28,
		ai_group_type = america
	}

	if SystemInfo:distribution() == Idstring("STEAM") then
		self.roberts = {
			name_id = "heist_roberts_hl",
			briefing_id = "heist_roberts_briefing",
			briefing_dialog = "Play_pln_cs1_brf",
			world_name = "narratives/bain/roberts",
			intro_event = "Play_pln_cs1_intro_01",
			outro_event = {
				"Play_pln_cs1_end_01",
				"Play_pln_cs1_end_02",
				"Play_pln_cs1_end_03"
			},
			music = "heist",
			package = "packages/narr_roberts",
			cube = "cube_apply_heist_bank",
			ghost_bonus = 0.1,
			max_bags = 14,
			ai_group_type = america
		}
	end

	self.mia_1 = {
		name_id = "heist_mia_1_hl",
		briefing_id = "heist_mia_1_briefing",
		briefing_dialog = "Play_pln_hm1_brf_01",
		world_name = "narratives/dentist/mia/stage1",
		intro_event = "Play_pln_hm1_intro_01",
		outro_event = "Play_pln_hm1_end_01",
		music = "heist",
		package = "packages/narr_mia_1",
		cube = "cube_apply_heist_bank",
		max_bags = 20,
		ai_group_type = america
	}
	self.mia_2 = {
		name_id = "heist_mia_2_hl",
		briefing_id = "heist_mia_2_briefing",
		briefing_dialog = "Play_pln_hm2_brf_01",
		world_name = "narratives/dentist/mia/stage2",
		intro_event = "Play_pln_hm2_intro_01",
		outro_event = {
			"dentist_hm1_debrief"
		},
		music = "heist",
		package = "packages/narr_mia_2",
		cube = "cube_apply_heist_bank",
		max_bags = 35,
		ai_group_type = america,
		load_screen = "guis/dlcs/pic/textures/loading/job_hlm_02",
		teams = {
			criminal1 = {
				foes = {
					mobster_boss = true,
					law1 = true,
					mobster1 = true
				},
				friends = {
					converted_enemy = true
				}
			},
			law1 = {
				foes = {
					converted_enemy = true,
					criminal1 = true,
					mobster1 = true
				},
				friends = {}
			},
			mobster1 = {
				foes = {
					converted_enemy = true,
					law1 = true,
					criminal1 = true
				},
				friends = {}
			},
			mobster_boss = {
				foes = {
					converted_enemy = true,
					criminal1 = true
				},
				friends = {}
			},
			converted_enemy = {
				foes = {
					mobster_boss = true,
					law1 = true,
					mobster1 = true
				},
				friends = {
					criminal1 = true
				}
			},
			neutral1 = {
				foes = {},
				friends = {}
			},
			hacked_turret = {
				foes = {
					law1 = true,
					mobster1 = true
				},
				friends = {}
			}
		}
	}
	self.mia2_new = {
		name_id = "heist_mia2_new_hl",
		briefing_id = "heist_mia_2_briefing",
		briefing_dialog = "Play_pln_hm2_brf_01",
		world_name = "narratives/dentist/mia/stage2",
		intro_event = "Play_pln_hm2_intro_01",
		outro_event = {
			"Play_gus_hm1_debrief_01",
			"Play_gus_hm1_debrief_01"
		},
		music = "heist",
		package = "packages/narr_mia_2",
		cube = "cube_apply_heist_bank",
		teams = self.mia_2.teams,
		ai_group_type = america
	}
	self.kosugi = {
		name_id = "heist_kosugi_hl",
		briefing_id = "heist_kosugi_briefing",
		briefing_dialog = "Play_pln_ko1_brf_01",
		world_name = "narratives/bain/shadow_raid",
		intro_event = "Play_pln_ko1_intro_01",
		outro_event = {
			"Play_pln_ko1_end_01"
		},
		music = "no_music",
		music_ext = "kosugi_music",
		music_ext_start = "suspense_1",
		package = "packages/kosugi",
		cube = "cube_apply_heist_bank",
		ghost_bonus = 0.05,
		ghost_required = true,
		max_bags = 30,
		ai_group_type = america
	}
	self.gallery = deep_clone(self.framing_frame_1)
	self.gallery.name_id = "heist_gallery_hl"
	self.gallery.briefing_id = "heist_gallery_briefing"
	self.gallery.intro_event = "Play_pln_art_intro"
	self.gallery.outro_event = {
		"Play_pln_art_end"
	}
	self.gallery.briefing_dialog = "Play_pln_art_brf"
	self.gallery.load_screen = "guis/dlcs/pic/textures/loading/job_gallery"
	self.hox_1 = {
		name_id = "heist_hox_1_hl",
		briefing_id = "heist_hox_1_briefing",
		briefing_dialog = "Play_pln_hb1_brf_01",
		world_name = "narratives/dentist/hox/stage_1",
		intro_event = "Play_pln_hb1_intro_01",
		outro_event = {
			"Play_pln_hb1_end_01"
		},
		music = "heist",
		package = "packages/narr_hox_1",
		cube = "cube_apply_heist_bank",
		block_AIs = {
			old_hoxton = true
		},
		ai_group_type = america
	}
	self.hox_2 = {
		name_id = "heist_hox_2_hl",
		briefing_id = "heist_hox_2_briefing",
		briefing_dialog = "Play_rb5_hb2_brf_01",
		world_name = "narratives/dentist/hox/stage_2",
		intro_event = "Play_rb5_hb2_intro_01",
		outro_event = {
			"Play_rb5_hb2_end_01"
		},
		music = "heist",
		package = "packages/narr_hox_2",
		cube = "cube_apply_heist_bank",
		block_AIs = {
			old_hoxton = true
		},
		ai_group_type = america,
		load_screen = "guis/dlcs/pic/textures/loading/job_breakout_02"
	}
	self.pines = {
		name_id = "heist_pines_hl",
		briefing_id = "heist_pines_briefing",
		briefing_dialog = "Play_pln_cp1_brf_01",
		world_name = "narratives/vlad/pines",
		intro_event = "Play_pln_cp1_intro_01",
		outro_event = "Play_vld_cp1_end",
		music = "heist",
		package = "packages/narr_pines",
		cube = "cube_apply_heist_bank",
		max_bags = 1200,
		ai_group_type = america
	}
	self.mus = {
		name_id = "heist_mus_hl",
		briefing_id = "heist_mus_briefing",
		briefing_dialog = "Play_pln_hd1_brf_01",
		world_name = "narratives/dentist/mus",
		intro_event = "Play_pln_hd1_intro_01",
		outro_event = {
			"dentist_hd1_debrief_01",
			"dentist_hd1_debrief_02"
		},
		music = "heist",
		package = "packages/narr_mus",
		cube = "cube_apply_heist_bank",
		max_bags = 30,
		ghost_bonus = 0.15,
		ai_group_type = america
	}
	self.cage = {
		name_id = "heist_cage_hl",
		briefing_id = "heist_cage_briefing",
		briefing_dialog = "Play_pln_ch1_brf_01",
		world_name = "narratives/bain/cage",
		intro_event = "Play_pln_ch1_intro_01",
		outro_event = "Play_pln_ch1_end_01",
		music = "heist",
		package = "packages/narr_cage",
		cube = "cube_apply_heist_bank",
		max_bags = 6,
		ghost_bonus = 0,
		ghost_required_visual = true,
		ai_group_type = america
	}
	self.hox_3 = {
		name_id = "heist_hox_3_hl",
		briefing_id = "heist_hox_3_briefing",
		briefing_dialog = "Play_pln_hb3_brf_01",
		world_name = "narratives/bain/revenge",
		intro_event = "Play_pln_hb3_01",
		outro_event = "lol",
		music = "heist",
		package = "packages/narr_hox_3",
		cube = "cube_apply_heist_bank",
		max_bags = 10,
		ghost_bonus = 0.1,
		ai_group_type = america
	}
	self.rat = {
		name_id = "heist_rat_hl",
		briefing_id = "heist_rat_briefing",
		briefing_dialog = "Play_pln_rt1b_brf_01",
		world_name = "narratives/bain/rat",
		intro_event = "Play_pln_rt1b_intro_01",
		outro_event = {
			"Play_pln_rt1b_end_01",
			"Play_pln_rt1b_end_02",
			"Play_pln_rt1b_end_03",
			"Play_pln_rt1b_end_04"
		},
		music = "heist",
		package = "packages/narr_alex1",
		cube = "cube_apply_heist_bank",
		max_bags = 1200,
		ai_group_type = america
	}
	self.shoutout_raid = {
		name_id = "heist_shoutout_raid_hl",
		briefing_id = "heist_shoutout_raid_briefing",
		briefing_dialog = "Play_pln_ko1b_brf_01",
		world_name = "narratives/vlad/shout",
		intro_event = "Play_pln_ko1b_intro_01",
		outro_event = "Play_vld_ko1b_end_01",
		music = "heist",
		package = "packages/vlad_shout",
		cube = "cube_apply_heist_bank",
		max_bags = 20,
		ai_group_type = america
	}
	self.arena = {
		name_id = "heist_arena_hl",
		briefing_id = "heist_arena_briefing",
		briefing_dialog = "Play_pln_al1_brf_01",
		world_name = "narratives/bain/arena",
		intro_event = "Play_pln_al1_intro_01",
		outro_event = {
			"Play_pln_al1_54",
			"Play_pln_al1_55"
		},
		music = "no_music",
		death_track = "track_01",
		death_event = "music_heist_assault",
		package = "packages/narr_arena",
		cube = "cube_apply_heist_bank",
		max_bags = 25,
		ghost_bonus = 0.1,
		ai_group_type = america,
		load_screen = "guis/dlcs/pic/textures/loading/job_alesso"
	}
	self.kenaz = {
		name_id = "heist_kenaz_hl",
		briefing_id = "heist_kenaz_briefing",
		briefing_dialog = "Play_pln_ca1_brf_01",
		world_name = "narratives/dentist/cas",
		intro_event = {
			"Play_pln_ca1_intro_01",
			"Play_pln_ca1_intro_02"
		},
		outro_event = {
			"dentist_ca1_debrief_01",
			"dentist_ca1_debrief_02"
		},
		music = "heist",
		package = {
			"packages/kenaz"
		},
		cube = "cube_apply_heist_bank",
		ghost_bonus = 0.1,
		max_bags = 40,
		ai_group_type = america
	}
	self.jolly = {
		name_id = "heist_jolly_hl",
		briefing_id = "heist_jolly_briefing",
		briefing_dialog = "Play_pln_as1_brf_01",
		world_name = "narratives/vlad/jolly",
		intro_event = "Play_plt_as1_intro_01",
		outro_event = {
			"vld_as1_17",
			"vld_as1_17"
		},
		music = "heist",
		package = "packages/jolly",
		cube = "cube_apply_heist_bank",
		max_bags = 15,
		ai_group_type = america
	}
	self.red2 = {
		name_id = "heist_red2_hl",
		briefing_id = "heist_red2_briefing",
		briefing_dialog = "Play_pln_fwb_brf_01",
		world_name = "narratives/classics/red2",
		intro_event = "Play_pln_fwb_intro_01",
		outro_event = {
			"Play_pln_fwb_34",
			"Play_pln_fwb_65"
		},
		music = "heist",
		package = {
			"packages/narr_red2"
		},
		cube = "cube_apply_heist_bank",
		max_bags = 84,
		ghost_bonus = 0.15,
		ai_group_type = america
	}
	self.dinner = {
		name_id = "heist_dinner_hl",
		briefing_id = "heist_dinner_briefing",
		briefing_dialog = "Play_pln_dn1_brf_01",
		world_name = "narratives/classics/dinner",
		intro_event = "Play_pln_dn1_intro_01",
		outro_event = {
			"Play_pln_dn1_31"
		},
		music = "heist",
		package = {
			"packages/narr_dinner"
		},
		cube = "cube_apply_heist_bank",
		max_bags = 20,
		ai_group_type = america
	}
	self.pbr = {
		name_id = "heist_pbr_hl",
		briefing_id = "heist_pbr_briefing",
		briefing_dialog = "Play_pln_jr1_brf_01",
		world_name = "narratives/pbr/berry",
		intro_event = "Play_mer_jr1_intro_01",
		outro_event = "Play_pln_jr1_09",
		music = "heist",
		package = {
			"packages/narr_jerry1"
		},
		cube = "cube_apply_heist_bank",
		max_bags = 20,
		ai_group_type = murkywater
	}
	self.pbr2 = {
		name_id = "heist_pbr2_hl",
		briefing_id = "heist_pbr2_briefing",
		briefing_dialog = "Play_pln_jr2_brf_01",
		world_name = "narratives/pbr/jerry",
		intro_event = "Play_pln_jr2_intro_01",
		outro_event = "Play_loc_jr2_44",
		music = "heist",
		package = {
			"packages/narr_jerry2"
		},
		cube = "cube_apply_heist_bank",
		max_bags = 20,
		ai_group_type = america
	}
	self.cane = {
		name_id = "heist_cane_hl",
		briefing_id = "heist_cane_briefing",
		briefing_dialog = "Play_pln_can_brf_01",
		world_name = "narratives/vlad/cane",
		intro_event = "Play_pln_can_intro_01",
		outro_event = "Play_vld_can_11",
		package = "packages/cane",
		cube = "cube_apply_heist_bank",
		max_bags = 3600,
		ai_group_type = america
	}
	self.nail = {
		name_id = "heist_nail_hl",
		briefing_id = "heist_nail_briefing",
		briefing_dialog = "Play_pln_nai_brf_01",
		world_name = "narratives/bain/nail",
		intro_event = "Play_pln_nai_intro_01",
		outro_event = {
			"Play_pln_nai_17",
			"Play_pln_nai_18",
			"Play_pln_nai_19",
			"Play_pln_nai_20"
		},
		music = "heist",
		package = {
			"packages/job_nail"
		},
		cube = "cube_apply_heist_bank",
		max_bags = 1000,
		ai_group_type = america
	}
	self.peta = {
		name_id = "heist_peta_hl",
		briefing_id = "heist_peta_briefing",
		briefing_dialog = "Play_pln_pt1_brf",
		world_name = "narratives/vlad/peta/stage1",
		intro_event = "Play_vld_pt1_intro",
		outro_event = "Play_vld_pt1_07",
		music = "heist",
		package = "packages/narr_peta",
		cube = "cube_apply_heist_bank",
		ai_group_type = america,
		load_screen = "guis/dlcs/pic/textures/loading/job_goatsim_01"
	}
	self.peta2 = {
		name_id = "heist_peta2_hl",
		briefing_id = "heist_peta2_briefing",
		briefing_dialog = "Play_pln_pt2_brf",
		world_name = "narratives/vlad/peta/stage2",
		intro_event = "Play_brs_pt2_intro",
		outro_event = "Play_vld_pt2_04",
		music = "heist",
		package = "packages/narr_peta2",
		cube = "cube_apply_heist_bank",
		ai_group_type = america,
		repossess_bags = true,
		load_screen = "guis/dlcs/pic/textures/loading/job_goatsim_02"
	}
	self.pal = {
		name_id = "heist_pal_hl",
		briefing_id = "heist_pal_briefing",
		briefing_dialog = "Play_pln_pal_brf",
		world_name = "narratives/classics/pal",
		intro_event = "Play_pln_pal_intro",
		outro_event = "Play_pln_pal_81",
		music = "heist",
		package = {
			"packages/narr_pal"
		},
		cube = "cube_apply_heist_bank",
		max_bags = 1200
	}
	self.man = {
		name_id = "heist_man_hl",
		briefing_id = "heist_man_briefing",
		briefing_dialog = "Play_pln_man_brf",
		world_name = "narratives/classics/man",
		intro_event = "Play_pln_man_intro",
		outro_event = "Play_pln_man_81",
		music = "heist",
		package = "packages/narr_man",
		cube = "cube_apply_heist_bank",
		max_bags = 10
	}
	self.dark = {
		name_id = "heist_dark_hl",
		briefing_id = "heist_dark_briefing",
		briefing_dialog = "Play_pln_drk_brf",
		world_name = "narratives/elephant/dark",
		intro_event = "Play_pln_drk_intro_01",
		outro_event = {
			"Play_rb14_drk_outro_01",
			"Play_rb14_drk_outro_02"
		},
		music = "no_music",
		music_ext = "music_dark",
		music_ext_start = "suspense_1",
		package = "packages/job_dark",
		cube = "cube_apply_heist_bank",
		max_bags = 20,
		ghost_bonus = 0.15,
		ghost_required = true
	}
	self.mad = {
		name_id = "heist_mad_hl",
		briefing_id = "heist_mad_briefing",
		briefing_dialog = "Play_pln_mad_brf_01",
		world_name = "narratives/elephant/mad",
		intro_event = "Play_plt_mad_intro_01",
		outro_event = "Play_rb14_mad_outro_01",
		music = "heist",
		package = "packages/lvl_mad",
		cube = "cube_apply_heist_bank",
		ai_group_type = russia
	}
	self.biker_train = {
		name_id = "heist_biker_train_hl",
		briefing_id = "heist_biker_train_briefing",
		world_name = "wip/biker_train_test",
		intro_event = "Play_pln_jr2_intro_01",
		outro_event = {
			"Play_loc_jr2_44"
		},
		music = "heist",
		cube = "cube_apply_heist_bank"
	}
	self.born = {
		name_id = "heist_born_hl",
		briefing_id = "heist_born_briefing",
		briefing_dialog = "Play_elp_brn_brf_01",
		world_name = "narratives/elephant/born",
		intro_event = "Play_bkl_brn_intro",
		outro_event = "Play_elp_brn_01",
		intro_cues = {
			"intro_firestarter_301",
			"intro_firestarter_302",
			"intro_firestarter_303",
			"intro_firestarter_304"
		},
		music = "heist",
		package = "packages/narr_born_1",
		cube = "cube_apply_heist_bank",
		max_bags = 10
	}
	self.chew = {
		name_id = "heist_chew_hl",
		briefing_id = "heist_chew_briefing",
		briefing_dialog = "Play_elp_chw_brf_01",
		world_name = "narratives/elephant/chew",
		intro_event = "Play_plt_chw_intro",
		outro_event = "Play_elp_chw_01",
		music = "heist",
		package = "packages/lvl_chew",
		cube = "cube_apply_heist_bank",
		load_screen = "guis/dlcs/pic/textures/loading/job_chew"
	}
	self.short1_stage1 = {
		name_id = "heist_short1_stage1_hl",
		briefing_id = "heist_short1_stage1_briefing",
		briefing_dialog = "Play_pln_sh11_brf_01",
		world_name = "narratives/short1/stage1",
		intro_event = "Play_pln_sh11_intro_01",
		outro_event = "Play_pln_sh11_30",
		music = "heist",
		package = "packages/job_short1_stage1",
		cube = "cube_apply_heist_bank",
		force_equipment = {
			character = "russian",
			throwable = "none",
			melee = "none",
			secondary = "wpn_fps_pis_g17",
			armor = "level_1",
			deployable = "none",
			primary = "wpn_fps_ass_amcar",
			primary_mods = {
				"wpn_fps_upg_ns_ass_smg_small"
			},
			secondary_mods = {
				"wpn_fps_upg_ns_pis_medium"
			}
		},
		disable_mutators = true,
		load_screen = "guis/dlcs/pic/textures/loading/job_basics_stealth1"
	}
	self.short1_stage2 = {
		name_id = "heist_short1_stage2_hl",
		briefing_id = "heist_short1_stage2_briefing",
		briefing_dialog = "Play_pln_sh12_brf_01",
		world_name = "narratives/short1/stage2",
		intro_event = "Play_pln_sh12_intro_01",
		outro_event = "Play_pln_sh12_30",
		music = "heist",
		package = "packages/job_short1_stage2",
		cube = "cube_apply_heist_bank",
		force_equipment = {
			character = "russian",
			throwable = "none",
			melee = "none",
			secondary = "wpn_fps_pis_g17",
			armor = "level_1",
			deployable = "ecm_jammer",
			primary = "wpn_fps_ass_amcar",
			primary_mods = {
				"wpn_fps_upg_ns_ass_smg_small"
			},
			secondary_mods = {
				"wpn_fps_upg_ns_pis_medium"
			}
		},
		disable_mutators = true,
		load_screen = "guis/dlcs/pic/textures/loading/job_basics_stealth2"
	}
	self.short2_stage1 = {
		name_id = "heist_short2_stage1_hl",
		briefing_id = "heist_short2_stage1_briefing",
		briefing_dialog = "Play_pln_sh21_brf_01",
		world_name = "narratives/short2/stage1",
		intro_event = "Play_pln_sh21_intro_01",
		outro_event = "Play_rb4_sh21_06",
		music = "heist",
		package = "packages/job_short2_stage1",
		cube = "cube_apply_heist_bank",
		force_equipment = {
			deployable = "none",
			armor = "level_4",
			character = "russian",
			throwable = "none",
			secondary = "wpn_fps_pis_g17",
			primary = "wpn_fps_ass_amcar",
			melee = "none"
		},
		disable_mutators = true,
		load_screen = "guis/dlcs/pic/textures/loading/job_basics_loud1"
	}
	self.short2_stage2b = {
		name_id = "heist_short2_stage2b_hl",
		briefing_id = "heist_short2_stage2b_briefing",
		briefing_dialog = "Play_pln_sh22_brf_01",
		world_name = "narratives/short2/stage2",
		intro_event = "Play_dr1_a01",
		outro_event = "Play_rb4_sh22_05",
		music = "heist",
		package = "packages/job_short2_stage2b",
		cube = "cube_apply_heist_bank",
		force_equipment = {
			deployable = "doctor_bag",
			armor = "level_4",
			character = "russian",
			throwable = "none",
			secondary = "wpn_fps_pis_g17",
			primary = "wpn_fps_ass_amcar",
			melee = "none"
		},
		disable_mutators = true,
		load_screen = "guis/dlcs/pic/textures/loading/job_basics_loud2"
	}
	self.chill = {
		name_id = "heist_chill_hl",
		briefing_id = "heist_chill_hl_briefing",
		briefing_dialog = "Play_rb5_sfh_brf",
		world_name = "narratives/chill",
		intro_event = "Play_pln_bb1_intro_01",
		outro_event = {
			"Play_pln_bb1_end_01",
			"Play_pln_bb1_end_02"
		},
		package = "packages/narr_chill",
		cube = "cube_apply_heist_bank",
		max_bags = 28,
		team_ai_off = true,
		on_enter_clbks = {
			function ()
				managers.mission:call_global_event(Message.OnEnterSafeHouse)
			end
		},
		hud = {
			no_timer = true,
			no_hostages = true
		},
		is_safehouse = true,
		disable_mutators = true
	}
	self.chill_combat = {
		name_id = "heist_chill_combat_hl",
		briefing_id = "heist_chill_combat_hl_briefing",
		briefing_dialog = "Play_pln_sfr_brf",
		world_name = "narratives/chill",
		intro_event = "Play_pln_sfr_intro",
		outro_event = "Play_pln_sfr_end",
		package = "packages/narr_chill",
		cube = "cube_apply_heist_bank"
	}
	self.chill.ghost_bonus = 0.15
	self.chill_combat.max_bags = 28
	self.chill_combat.team_ai_off = false
	self.chill_combat.group_ai_state = "safehouse"
	self.chill_combat.ai_group_type = america
	self.chill_combat.wave_count = 3
	self.chill_combat.disable_mutators = true
	self.friend = {
		name_id = "heist_friend_hl",
		briefing_id = "heist_friend_hl_briefing",
		briefing_dialog = "Play_pln_fri_brf_01",
		world_name = "narratives/butcher/friend",
		intro_event = "Play_pln_fri_intro",
		outro_event = {
			"Play_btc_fri_end_a",
			"Play_btc_fri_end_b"
		},
		package = "packages/lvl_friend",
		cube = "cube_apply_heist_bank",
		ghost_bonus = 0.15,
		max_bags = 28,
		ai_group_type = america
	}
	self.flat = {
		name_id = "heist_flat_hl",
		briefing_id = "heist_flat_hl_briefing",
		briefing_dialog = "Play_pln_flt_brf_01",
		world_name = "narratives/classics/flat",
		intro_event = "Play_pln_flt_intro_01",
		outro_event = "Play_pln_flt_50",
		package = "packages/narr_flat",
		cube = "cube_apply_heist_bank",
		max_bags = 11,
		music_overrides = {
			track_47_gen = "track_47_flat"
		},
		ai_group_type = america
	}
	self.help = {
		name_id = "heist_help_hl",
		briefing_id = "heist_help_hl_briefing",
		briefing_dialog = "Play_big_clk_hlp_brf",
		world_name = "narratives/bain/help",
		intro_event = "Play_big_clk_hlp_intro",
		outro_event = "Play_big_clk_hlp_end",
		failure_event = "Play_big_clk_hlp_fal",
		package = "packages/lvl_help",
		cube = "cube_apply_heist_bank",
		ghost_bonus = nil,
		max_bags = 9999,
		ai_group_type = america
	}
	self.moon = {
		name_id = "heist_moon_hl",
		briefing_id = "heist_moon_hl_briefing",
		briefing_dialog = "Play_pln_moon_brf",
		world_name = "narratives/vlad/moon",
		intro_event = "Play_vld_moon_intro",
		outro_event = "Play_vld_moon_end",
		package = "packages/lvl_moon",
		cube = "cube_apply_heist_bank",
		ghost_bonus = nil,
		max_bags = 12,
		ai_group_type = america
	}
	self.spa = {
		name_id = "heist_spa_hl",
		briefing_id = "heist_spa_hl_briefing",
		briefing_dialog = "Play_rb6_spa_brf_01",
		world_name = "narratives/continental/spa",
		intro_event = "Play_pln_spa_intro",
		outro_event = "Play_cha_spa_end",
		package = "packages/job_spa",
		cube = "cube_apply_heist_bank",
		ghost_bonus = nil,
		max_bags = 9999,
		ai_group_type = america
	}
	self.fish = {
		name_id = "heist_fish_hl",
		briefing_id = "heist_fish_hl_briefing",
		briefing_dialog = "Play_pln_fish_brf",
		world_name = "narratives/continental/fish",
		intro_event = "Play_pln_fish_intro",
		outro_event = "Play_pln_fish_end",
		failure_music = "Play_fish_jazz_game_over",
		music = "no_music",
		music_ext = "music_fish",
		music_ext_start = "suspense_1",
		package = "packages/lvl_fish",
		cube = "cube_apply_heist_bank",
		ghost_bonus = 0.1,
		ghost_required = true,
		max_bags = 9999,
		ai_group_type = america
	}
	self.haunted = {
		name_id = "heist_haunted_hl",
		briefing_id = "heist_haunted_briefing",
		world_name = "narratives/haunted_safehouse",
		intro_event = "Play_hw13_intro",
		outro_event = {
			"lol",
			"lolo"
		},
		music = "heist",
		package = "packages/narr_haunted",
		cube = "cube_apply_heist_bank",
		max_bags = 4
	}
	self.run = {
		name_id = "heist_run_hl",
		briefing_id = "heist_run_briefing",
		briefing_dialog = "Play_pln_run_brf",
		world_name = "narratives/classics/run",
		intro_event = "Play_pln_run_intro",
		outro_event = "Play_loc_run_end",
		music = "heist",
		package = "packages/narr_run",
		cube = "cube_apply_heist_bank"
	}
	self.glace = {
		name_id = "heist_glace_hl",
		briefing_id = "heist_glace_briefing",
		briefing_dialog = "Play_pln_glace_brf",
		world_name = "narratives/classics/glace",
		intro_event = "Play_pln_glace_intro",
		outro_event = "Play_pln_glace_end",
		music = "heist",
		package = "packages/narr_glace",
		cube = "cube_apply_heist_bank",
		environment_effects = {
			"rain",
			"raindrop_screen",
			"lightning"
		},
		equipment = {
			"saw"
		},
		player_style = "raincoat"
	}
	self.dah = {
		name_id = "heist_dah_hl",
		briefing_id = "heist_dah_briefing",
		package = "packages/lvl_dah",
		briefing_dialog = "Play_pln_dah_brf",
		world_name = "narratives/classics/dah",
		intro_event = "Play_pln_dah_intro",
		outro_event = {
			"Play_pln_dah_end_stealth",
			"Play_pln_dah_end_loud"
		},
		music = "heist",
		cube = "cube_apply_heist_bank",
		max_bags = 20,
		ghost_bonus = 0.1,
		ai_group_type = america,
		player_style = "sneak_suit",
		load_screen = "guis/dlcs/pic/textures/loading/job_diamond_heist_df"
	}
	self.rvd1 = {
		name_id = "heist_rvd1_hl",
		briefing_id = "heist_rvd1_briefing",
		briefing_dialog = "Play_loc_rvd_brf",
		world_name = "narratives/bain/rvd/stage1",
		intro_event = "Play_loc_rvd_intro",
		outro_event = "Play_loc_rvd_end",
		music = "heist",
		package = "packages/job_rvd",
		cube = "cube_apply_heist_bank",
		max_bags = 10,
		ai_group_type = america,
		narrator = "locke",
		load_screen = "guis/dlcs/rvd/textures/loading/job_rvd_01_df"
	}
	self.rvd2 = {
		name_id = "heist_rvd2_hl",
		briefing_id = "heist_rvd2_briefing",
		briefing_dialog = "Play_pln_rvd_brf",
		world_name = "narratives/bain/rvd/stage2",
		intro_event = "Play_pln_rvd_02",
		outro_event = "Play_pln_rvd_end",
		music = "heist",
		package = "packages/job_rvd2",
		cube = "cube_apply_heist_bank",
		ai_group_type = america,
		max_bags = 30,
		load_screen = "guis/dlcs/rvd/textures/loading/job_rvd_02_df"
	}
	self.hvh = {
		name_id = "heist_hvh_hl",
		briefing_id = "heist_hvh_briefing",
		package = "packages/narr_hvh",
		briefing_dialog = "Play_hvh_brf_01",
		world_name = "narratives/bain/hvh",
		intro_event = "Play_hvh_intro_01",
		outro_event = {
			"lol",
			"lolo"
		},
		music = "heist",
		cube = "cube_apply_heist_bank",
		max_bags = 80,
		ai_group_type = zombie,
		load_screen = "guis/dlcs/pic/textures/loading/job_halloween2017"
	}
	self.wwh = {
		name_id = "heist_wwh_hl",
		briefing_id = "heist_wwh_briefing",
		package = "packages/lvl_wwh",
		briefing_dialog = "Play_pln_wwh_brf",
		world_name = "narratives/locke/wwh",
		intro_event = "Play_loc_wwh_intro",
		outro_event = "Play_pln_wwh_end",
		music = "heist",
		cube = "cube_apply_heist_bank",
		environment_effects = {
			"snow"
		},
		player_style = "winter_suit",
		max_bags = 12,
		ai_group_type = america,
		drop_pickups_to_ground = true
	}
	self.brb = {
		name_id = "heist_brb_hl",
		briefing_id = "heist_brb_briefing",
		briefing_dialog = "Play_loc_brb_brf",
		world_name = "narratives/locke/brb",
		intro_event = "Play_loc_brb_intro",
		outro_event = "Play_loc_brb_end",
		music = "heist",
		package = "packages/lvl_brb",
		cube = "cube_apply_heist_bank",
		max_bags = 26,
		narrator = "locke",
		load_screen = "guis/dlcs/brb/textures/loading/job_brb_df"
	}
	self.tag = {
		name_id = "heist_tag_hl",
		briefing_id = "heist_tag_briefing",
		package = "packages/job_tag",
		briefing_dialog = "Play_loc_tag_brf",
		world_name = "narratives/locke/tag",
		intro_event = "Play_loc_tag_intro",
		outro_event = "Play_loc_tag_end",
		music = "no_music",
		cube = "cube_apply_heist_bank",
		music_ext = "music_tag",
		music_ext_start = "suspense_1",
		max_bags = 20,
		ghost_bonus = 0.1,
		ai_group_type = america,
		narrator = "locke",
		ghost_required = true,
		load_screen = "guis/dlcs/tag/textures/loading/job_tag_df"
	}
	self.des = {
		name_id = "heist_des_hl",
		briefing_id = "heist_des_briefing",
		package = "packages/job_des",
		briefing_dialog = "Play_loc_des_brf",
		world_name = "narratives/locke/des",
		intro_event = "Play_loc_des_intro",
		outro_event = "Play_loc_des_end",
		music = "heist",
		cube = "cube_apply_heist_bank",
		max_bags = 20,
		ai_group_type = murkywater,
		narrator = "locke",
		load_screen = "guis/dlcs/des/textures/loading/job_des_df"
	}
	self.nmh = {
		name_id = "heist_nmh_hl",
		briefing_id = "heist_nmh_briefing",
		package = "packages/dlcs/nmh/job_nmh",
		briefing_dialog = "Play_pln_nmh_brf",
		world_name = "narratives/classics/nmh",
		intro_event = "Play_pln_nmh_intro",
		outro_event = "Play_pln_nmh_end_win",
		cube = "cube_apply_heist_bank",
		failure_event = "Play_pln_nmh_end_fail",
		max_bags = 0,
		ghost_bonus = 0.1,
		ai_group_type = america,
		narrator = "bain",
		load_screen = "guis/dlcs/nmh/textures/loading/job_nmh_df"
	}
	self.sah = {
		name_id = "heist_sah_hl",
		briefing_id = "heist_sah_briefing",
		package = "packages/dlcs/sah/job_sah",
		briefing_dialog = "Play_loc_sah_brf",
		world_name = "narratives/locke/sah",
		intro_event = "Play_loc_sah_intro",
		outro_event = {
			"Play_loc_sah_end_stealth",
			"Play_loc_sah_end_loud"
		},
		cube = "cube_apply_heist_bank",
		music_ext = "music_tag",
		music_ext_start = "suspense_1",
		max_bags = 40,
		ghost_bonus = 0.1,
		ai_group_type = america,
		narrator = "locke",
		player_style = "tux"
	}
	self.bph = {
		name_id = "heist_bph_hl",
		briefing_id = "heist_bph_briefing",
		package = "packages/dlcs/bph/job_bph",
		briefing_dialog = "Play_loc_bph_brf",
		world_name = "narratives/locke/bph",
		intro_event = "Play_loc_bph_intro",
		outro_event = "Play_loc_bph_end_win",
		failure_event = "Play_loc_bph_end_fail",
		music = "heist",
		cube = "cube_apply_heist_bank",
		max_bags = 20,
		ai_group_type = murkywater,
		player_style = "sneak_suit",
		narrator = "locke",
		load_screen = "guis/dlcs/bph/textures/loading/job_bph_df"
	}
	self.skm_mus = {
		name_id = "heist_skm_mus_h1",
		briefing_id = "heist_skm_mus_briefing",
		package = "packages/dlcs/skm/job_skm",
		briefing_dialog = "Play_loc_skm_brf",
		world_name = "narratives/skm/skm_mus",
		intro_event = "Play_loc_skm_intro",
		outro_event = {
			"Play_loc_skm_end_win",
			"Play_loc_skm_end_fail"
		},
		cube = "cube_apply_heist_bank",
		music_ext = "heist",
		ai_group_type = america,
		group_ai_state = "skirmish",
		wave_count = 9,
		narrator = "locke"
	}
	self.skm_red2 = {
		name_id = "heist_skm_red2_h1",
		briefing_id = "heist_skm_red2_briefing",
		briefing_dialog = "Play_loc_skm_brf",
		world_name = "narratives/skm/skm_red2",
		intro_event = "Play_loc_skm_intro",
		outro_event = {
			"Play_loc_skm_end_win",
			"Play_loc_skm_end_fail"
		},
		music = "heist",
		package = "packages/dlcs/skm/job_skm",
		cube = "cube_apply_heist_bank",
		ai_group_type = america,
		group_ai_state = "skirmish",
		wave_count = 9,
		narrator = "locke"
	}
	self.skm_run = {
		name_id = "heist_skm_run_h1",
		briefing_id = "heist_skm_run_briefing",
		briefing_dialog = "Play_loc_skm_brf",
		world_name = "narratives/skm/skm_run",
		intro_event = "Play_loc_skm_intro",
		outro_event = {
			"Play_loc_skm_end_win",
			"Play_loc_skm_end_fail"
		},
		music = "heist",
		package = "packages/dlcs/skm/job_skm",
		cube = "cube_apply_heist_bank",
		ai_group_type = america,
		group_ai_state = "skirmish",
		wave_count = 9,
		narrator = "locke"
	}
	self.skm_watchdogs_stage2 = {
		name_id = "heist_skm_watchdogs_stage2_h1",
		briefing_id = "heist_skm_watchdogs_stage2_briefing",
		briefing_dialog = "Play_loc_skm_brf",
		world_name = "narratives/skm/skm_watchdogs_stage2",
		intro_event = "Play_loc_skm_intro",
		outro_event = {
			"Play_loc_skm_end_win",
			"Play_loc_skm_end_fail"
		},
		music = "heist",
		package = "packages/dlcs/skm/job_skm",
		cube = "cube_apply_heist_bank",
		ai_group_type = america,
		group_ai_state = "skirmish",
		wave_count = 9,
		narrator = "locke"
	}
	self.vit = {
		name_id = "heist_vit_hl",
		briefing_id = "heist_vit_briefing",
		package = "packages/dlcs/vit/job_vit",
		briefing_dialog = "Play_loc_vit_brf",
		world_name = "narratives/locke/vit",
		intro_event = "Play_loc_vit_intro",
		outro_event = {
			"Play_loc_vit_end_win",
			"Play_pln_uno_end_win"
		},
		failure_event = "Play_loc_vit_end_fail",
		music = "heist",
		cube = "cube_apply_heist_bank",
		max_bags = 20,
		ai_group_type = murkywater,
		narrator = "locke",
		player_style = "murky_suit",
		load_screen = "guis/dlcs/vit/textures/loading/job_vit_df"
	}
	self.mex = {
		name_id = "heist_mex_hl",
		briefing_id = "heist_mex_briefing",
		package = "packages/job_mex",
		briefing_dialog = "Play_loc_mex_brf_01",
		world_name = "narratives/locke/mex",
		intro_event = "Play_loc_med_intro",
		outro_event = {
			"Play_loc_mex_end_stealth_01",
			"Play_loc_mex_end_loud_01"
		},
		music = "heist",
		cube = "cube_apply_heist_bank",
		max_bags = 100,
		ai_group_type = murkywater,
		narrator = "locke",
		load_screen = "guis/dlcs/mex/textures/loading/job_mex_df"
	}
	self.mex_cooking = {
		name_id = "heist_mex_cooking_hl",
		briefing_id = "heist_mex_cooking_briefing",
		package = "packages/job_mex2",
		briefing_dialog = "Play_loc_mex_cook_brf_01",
		world_name = "narratives/locke/mex",
		intro_event = "Play_loc_mex_cook_intro",
		outro_event = {
			"Play_loc_count_gen_13",
			"Play_loc_count_gen_14",
			"Play_loc_count_gen_15",
			"Play_loc_count_gen_16"
		},
		music = "heist",
		cube = "cube_apply_heist_bank",
		max_bags = 100,
		ai_group_type = murkywater,
		narrator = "locke",
		load_screen = "guis/dlcs/mex/textures/loading/job_mex_cooking_df"
	}
	self._level_index = {
		"welcome_to_the_jungle_1",
		"welcome_to_the_jungle_1_night",
		"welcome_to_the_jungle_2",
		"framing_frame_1",
		"framing_frame_2",
		"framing_frame_3",
		"election_day_1",
		"election_day_2",
		"election_day_3",
		"election_day_3_skip1",
		"election_day_3_skip2",
		"watchdogs_1",
		"watchdogs_2",
		"watchdogs_1_night",
		"watchdogs_2_day",
		"alex_1",
		"alex_2",
		"alex_3",
		"firestarter_1",
		"firestarter_2",
		"firestarter_3",
		"ukrainian_job",
		"jewelry_store",
		"four_stores",
		"mallcrasher",
		"nightclub",
		"branchbank",
		"escape_cafe",
		"escape_park",
		"escape_cafe_day",
		"escape_park_day",
		"escape_street",
		"escape_overpass",
		"escape_garage",
		"escape_overpass_night",
		"safehouse",
		"arm_fac",
		"arm_par",
		"arm_hcm",
		"arm_cro",
		"arm_und",
		"arm_for",
		"family",
		"big",
		"mia_1",
		"mia_2",
		"mia2_new",
		"kosugi",
		"gallery",
		"hox_1",
		"hox_2",
		"pines",
		"cage",
		"hox_3",
		"mus",
		"crojob2",
		"crojob3",
		"crojob3_night",
		"rat",
		"shoutout_raid",
		"arena",
		"kenaz",
		"driving_escapes_industry_day",
		"driving_escapes_city_day",
		"jolly",
		"cane",
		"red2",
		"dinner",
		"pbr",
		"pbr2",
		"peta",
		"peta2",
		"pal",
		"nail",
		"man",
		"dark",
		"mad",
		"short1_stage1",
		"short1_stage2",
		"short2_stage1",
		"short2_stage2b",
		"born",
		"chew",
		"chill",
		"chill_combat",
		"friend",
		"flat",
		"help",
		"haunted",
		"moon",
		"spa",
		"fish",
		"run",
		"glace",
		"dah",
		"rvd1",
		"rvd2",
		"hvh",
		"wwh",
		"brb",
		"tag",
		"des",
		"nmh",
		"sah",
		"skm_mus",
		"skm_red2",
		"skm_run",
		"skm_watchdogs_stage2",
		"vit",
		"bph",
		"mex",
		"mex_cooking"
	}

	if SystemInfo:distribution() == Idstring("STEAM") then
		table.insert(self._level_index, "roberts")
	end

	self.escape_levels = {
		"escape_cafe",
		"escape_park",
		"escape_street",
		"escape_overpass",
		"escape_garage",
		"escape_overpass_night",
		"escape_cafe_day",
		"escape_park_day",
		"election_day_3",
		"arm_for",
		"escape_hell",
		"blueharvest_3",
		"driving_escapes_industry_day",
		"driving_escapes_city_day"
	}
end

function LevelsTweakData:get_level_index()
	return self._level_index
end

function LevelsTweakData:get_world_name_from_index(index)
	if not self._level_index[index] then
		return
	end

	return self[self._level_index[index]].world_name
end

function LevelsTweakData:get_level_name_from_index(index)
	return self._level_index[index]
end

function LevelsTweakData:get_index_from_world_name(world_name)
	for index, entry_name in ipairs(self._level_index) do
		if world_name == self[entry_name].world_name then
			return index
		end
	end
end

function LevelsTweakData:get_index_from_level_id(level_id)
	for index, entry_name in ipairs(self._level_index) do
		if entry_name == level_id then
			return index
		end
	end
end

function LevelsTweakData:requires_dlc(level_id)
	return self[level_id].dlc
end

function LevelsTweakData:requires_dlc_by_index(index)
	return self[self._level_index[index]].dlc
end

function LevelsTweakData:get_level_name_from_world_name(world_name)
	for _, entry_name in ipairs(self._level_index) do
		if world_name == self[entry_name].world_name then
			return entry_name
		end
	end
end

function LevelsTweakData:get_localized_level_name_from_world_name(world_name)
	for _, entry_name in ipairs(self._level_index) do
		if world_name == self[entry_name].world_name then
			return managers.localization:text(self[entry_name].name_id)
		end
	end
end

function LevelsTweakData:get_localized_level_name_from_level_id(level_id)
	for _, entry_name in ipairs(self._level_index) do
		if level_id == entry_name then
			return managers.localization:text(self[entry_name].name_id)
		end
	end
end

function LevelsTweakData:get_music_switches()
	if not Global.level_data then
		return nil
	end

	local level_data = Global.level_data.level_id and tweak_data.levels[Global.level_data.level_id]
	local music_id = level_data and level_data.music or "default"

	if music_id == "no_music" then
		return nil
	end

	local switches = {}

	if not Global.music_manager.loadout_selection then
		switches = managers.music:jukebox_random_all()
	elseif Global.music_manager.loadout_selection == "global" then
		switches = deep_clone(managers.music:playlist())
	elseif Global.music_manager.loadout_selection == "heist" then
		local track = managers.music:jukebox_heist_specific()

		if track == "all" then
			switches = managers.music:jukebox_random_all()
		elseif track == "playlist" then
			switches = deep_clone(managers.music:playlist())
		else
			table.insert(switches, track)
		end
	elseif Global.music_manager.loadout_selection == "server" then
		if Network:is_server() then
			switches = managers.music:jukebox_random_all()
		else
			table.insert(switches, Global.music_manager.synced_track)
		end
	else
		table.insert(switches, Global.music_manager.loadout_selection)
	end

	if #switches == 0 then
		Application:error("[LevelsTweakData:get_music_switches] Failed to find a track. JOB_ID = " .. (Global.job_manager.current_job and Global.job_manager.current_job.job_id or "[Missing]") .. ", SELECTION = " .. Global.music_manager.loadout_selection)
	end

	local overrides = level_data and level_data.music_overrides

	if overrides then
		for i, track in ipairs(switches) do
			local override = overrides[switches[i]]

			if override then
				print("[LevelsTweakData:get_music_switches] override track ", switches[i], "->", override)

				switches[i] = override
			end
		end
	end

	return switches
end

function LevelsTweakData:get_music_event(stage)
	local level_data = Global.level_data.level_id and tweak_data.levels[Global.level_data.level_id]
	local music_id = level_data and level_data.music or "default"

	if music_id == "no_music" then
		return nil
	end

	return tweak_data.music[music_id][stage]
end

function LevelsTweakData:get_music_event_ext()
	local level_data = Global.level_data.level_id and tweak_data.levels[Global.level_data.level_id]
	local music = level_data and level_data.music_ext
	local music_start = level_data and level_data.music_ext_start

	return music, music_start
end

function LevelsTweakData:get_default_team_ID(type)
	local lvl_tweak = self[Global.level_data.level_id]

	if lvl_tweak and lvl_tweak.default_teams and lvl_tweak.default_teams[type] then
		if lvl_tweak.teams[lvl_tweak.default_teams[type]] then
			return lvl_tweak.default_teams[type]
		else
			debug_pause("[LevelsTweakData:get_default_player_team_ID] Team not defined ", lvl_tweak.default_teams[type], "in", Global.level_data.level_id)
		end
	end

	if type == "player" then
		return "criminal1"
	elseif type == "combatant" then
		return "law1"
	elseif type == "non_combatant" then
		return "neutral1"
	else
		return "mobster1"
	end
end

function LevelsTweakData:get_team_setup()
	local lvl_tweak = nil
	lvl_tweak = (not Application:editor() or not managers.editor or self[managers.editor:layer("Level Settings"):get_setting("simulation_level_id")]) and Global.level_data and Global.level_data.level_id and self[Global.level_data.level_id]
	local teams = lvl_tweak and lvl_tweak.teams

	if teams then
		teams = deep_clone(teams)
	else
		teams = {
			criminal1 = {
				foes = {
					law1 = true,
					mobster1 = true
				},
				friends = {
					converted_enemy = true
				}
			},
			law1 = {
				foes = {
					converted_enemy = true,
					criminal1 = true,
					mobster1 = true
				},
				friends = {}
			},
			mobster1 = {
				foes = {
					converted_enemy = true,
					law1 = true,
					criminal1 = true
				},
				friends = {}
			},
			converted_enemy = {
				foes = {
					law1 = true,
					mobster1 = true
				},
				friends = {
					criminal1 = true
				}
			},
			neutral1 = {
				foes = {},
				friends = {}
			},
			hacked_turret = {
				foes = {
					law1 = true,
					mobster1 = true
				},
				friends = {}
			}
		}

		for id, team in pairs(teams) do
			team.id = id
		end
	end

	return teams
end

function LevelsTweakData:get_default_team_IDs()
	local lvl_tweak = nil
	lvl_tweak = (not Application:editor() or not managers.editor or self[managers.editor:layer("Level Settings"):get_setting("simulation_level_id")]) and Global.level_data and Global.level_data.level_id and self[Global.level_data.level_id]
	local default_team_IDs = lvl_tweak and lvl_tweak.default_teams
	default_team_IDs = default_team_IDs or {
		player = self:get_default_team_ID("player"),
		combatant = self:get_default_team_ID("combatant"),
		non_combatant = self:get_default_team_ID("non_combatant"),
		gangster = self:get_default_team_ID("gangster")
	}

	return default_team_IDs
end

function LevelsTweakData:get_team_names_indexed()
	local teams_index = self._teams_index

	if not teams_index then
		teams_index = {}
		local teams = self:get_team_setup()

		for team_id, team_data in pairs(teams) do
			table.insert(teams_index, team_id)
		end

		table.sort(teams_index)

		self._teams_index = teams_index
	end

	return teams_index
end

function LevelsTweakData:get_team_index(team_id)
	local teams_index = self:get_team_names_indexed()

	for index, test_team_id in ipairs(teams_index) do
		if team_id == test_team_id then
			return index
		end
	end
end

function LevelsTweakData:get_ai_group_type()
	local level_data = Global.level_data and Global.level_data.level_id and self[Global.level_data.level_id]

	if level_data then
		local ai_group_type = level_data.ai_group_type

		if ai_group_type then
			return ai_group_type
		end
	end

	print("[LevelsTweakData:get_ai_group_type] group is not defined for this level, fallback on default")

	return self.ai_groups.default
end
