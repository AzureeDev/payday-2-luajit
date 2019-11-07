NarrativeTweakData = NarrativeTweakData or class()

function NarrativeTweakData:init(tweak_data)
	self.STARS = {
		{
			jcs = {
				70,
				60,
				50,
				40,
				30,
				20,
				10
			}
		},
		{
			jcs = {
				70,
				60,
				50,
				40,
				30,
				20,
				10
			}
		},
		{
			jcs = {
				80,
				70,
				60,
				50,
				40,
				30,
				20,
				10
			}
		},
		{
			jcs = {
				90,
				80,
				70,
				60,
				50,
				40,
				30,
				20,
				10
			}
		},
		{
			jcs = {
				100,
				90,
				80,
				70,
				60,
				50,
				40,
				30,
				20,
				10
			}
		},
		{
			jcs = {
				100,
				90,
				80,
				70,
				60,
				50,
				40,
				30,
				20,
				10
			}
		},
		{
			jcs = {
				100,
				90,
				80,
				70,
				60,
				50,
				40,
				30,
				20,
				10
			}
		},
		{
			jcs = {
				100,
				90,
				80,
				70,
				60,
				50,
				40,
				30,
				20,
				10
			}
		},
		{
			jcs = {
				100,
				90,
				80,
				70,
				60,
				50,
				40,
				30,
				20,
				10
			}
		},
		{
			jcs = {
				100,
				90,
				80,
				70,
				60,
				50,
				40,
				30,
				20,
				10
			}
		}
	}
	self.STARS_CURVES = {
		1.6,
		1.5,
		1.5,
		1.5,
		1.5,
		1.5,
		1.5,
		1.4,
		1.3,
		1.2
	}
	self.JC_CHANCE = 0.01
	self.JC_PICKS = 35
	self.CONTRACT_COOLDOWN_TIME = 300
	self.HEAT_OTHER_JOBS_RATIO = 0.3
	self.ABSOLUTE_ZERO_JOBS_HEATS_OTHERS = false
	self.HEATED_MAX_XP_MUL = 1.15
	self.FREEZING_MAX_XP_MUL = 0.7
	self.DEFAULT_HEAT = {
		this_job = -5,
		other_jobs = 5
	}
	self.MAX_JOBS_IN_CONTAINERS = {
		6,
		18,
		24,
		false,
		12,
		4,
		1
	}
	self.DEFAULT_GHOST_BONUS = 0
	self.contacts = {
		dallas = {}
	}
	self.contacts.dallas.name_id = "heist_contact_dallas"
	self.contacts.dallas.description_id = "heist_contact_dallas_description"
	self.contacts.dallas.package = "packages/contact_dallas"
	self.contacts.dallas.assets_gui = Idstring("guis/mission_briefing/preload_contact_dallas")
	self.contacts.vlad = {
		name_id = "heist_contact_vlad",
		description_id = "heist_contact_vlad_description",
		package = "packages/contact_vlad",
		assets_gui = Idstring("guis/mission_briefing/preload_contact_vlad")
	}
	self.contacts.hector = {
		name_id = "heist_contact_hector",
		description_id = "heist_contact_hector_description",
		package = "packages/contact_hector",
		assets_gui = Idstring("guis/mission_briefing/preload_contact_hector")
	}
	self.contacts.the_elephant = {
		name_id = "heist_contact_the_elephant",
		description_id = "heist_contact_the_elephant_description",
		package = "packages/contact_the_elephant",
		assets_gui = Idstring("guis/mission_briefing/preload_contact_the_elephant")
	}
	self.contacts.bain = {
		name_id = "heist_contact_bain",
		description_id = "heist_contact_bain_description",
		package = "packages/contact_bain",
		assets_gui = Idstring("guis/mission_briefing/preload_contact_bain")
	}
	self.contacts.bain_no_variation = deep_clone(self.contacts.bain)
	self.contacts.bain_no_variation.assets_gui = Idstring("guis/mission_briefing/preload_contact_bain_no_variation")
	self.contacts.classic = {
		name_id = "heist_contact_classic",
		description_id = "heist_contact_classic_description",
		package = "packages/contact_bain",
		assets_gui = Idstring("guis/mission_briefing/preload_contact_bain")
	}
	self.contacts.the_dentist = {
		name_id = "heist_contact_the_dentist",
		description_id = "heist_contact_the_dentist_description",
		package = "packages/contact_the_dentist",
		assets_gui = Idstring("guis/dlcs/big_bank/guis/preload_contact_the_dentist")
	}
	self.contacts.the_butcher = {
		name_id = "heist_contact_the_butcher",
		description_id = "heist_contact_the_butcher_description",
		package = "packages/contact_the_butcher",
		assets_gui = Idstring("guis/dlcs/the_bomb/guis/preload_contact_the_butcher")
	}
	self.contacts.interupt = {
		name_id = "heist_contact_interupt",
		description_id = "heist_contact_interupt_description",
		package = "packages/contact_interupt",
		assets_gui = Idstring("guis/mission_briefing/preload_contact_interupt")
	}
	self.contacts.events = {
		name_id = "heist_contact_events",
		description_id = "heist_contact_events_description",
		package = "packages/contact_bain",
		assets_gui = Idstring("guis/mission_briefing/preload_contact_bain")
	}
	self.contacts.locke = {
		name_id = "heist_contact_locke",
		description_id = "heist_contact_locke_description",
		package = "packages/contact_locke",
		assets_gui = Idstring("guis/dlcs/berry/guis/preload_contact_locke")
	}
	self.contacts.jimmy = {
		name_id = "heist_contact_jimmy",
		description_id = "heist_contact_jimmy_description",
		package = "packages/contact_jimmy",
		assets_gui = Idstring("guis/dlcs/mad/guis/preload_contact_jimmy")
	}
	self.contacts.hoxton = {
		name_id = "heist_contact_hoxton",
		description_id = "heist_contact_hoxton_description",
		package = "packages/contact_hoxton",
		assets_gui = Idstring("guis/mission_briefing/preload_contact_hoxton"),
		hidden = true
	}
	self.contacts.the_continental = {
		name_id = "heist_contact_continental",
		description_id = "heist_contact_continental_description",
		package = "packages/contact_continental",
		assets_gui = Idstring("guis/mission_briefing/preload_contact_continental")
	}
	self.contacts.skirmish = {
		name_id = "heist_contact_skirmish",
		description_id = "heist_contact_bain_description",
		package = "packages/contact_bain",
		assets_gui = Idstring("guis/mission_briefing/preload_contact_bain"),
		hide_stream = true,
		hidden = true
	}
	self.jobs = {}
	self.stages = {
		firestarter_1 = {
			type = "d",
			type_id = "heist_type_hijack",
			level_id = "firestarter_1"
		},
		firestarter_2 = {
			type = "d",
			type_id = "heist_type_stealth",
			level_id = "firestarter_2"
		},
		firestarter_3 = {
			type = "d",
			level_id = "firestarter_3",
			type_id = "heist_type_knockover",
			mission = "default",
			mission_filter = {
				5
			}
		}
	}
	self.jobs.firestarter = {
		name_id = "heist_firestarter",
		briefing_id = "heist_firestarter_crimenet",
		package = "packages/job_firestarter",
		contact = "hector",
		jc = 50,
		chain = {
			self.stages.firestarter_1,
			self.stages.firestarter_2,
			self.stages.firestarter_3
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_firestarter_01",
		briefing_event = "hct_firestarter_brf",
		debrief_event = "hct_firestarter_debrief",
		crimenet_callouts = {
			"hct_firestarter_cnc_01"
		},
		crimenet_videos = {
			"cn_fires1",
			"cn_fires2",
			"cn_fires3"
		},
		payout = {
			70000,
			95000,
			125000,
			200000,
			250000,
			250000,
			250000
		},
		contract_cost = {
			39000,
			78000,
			195000,
			390000,
			500000,
			500000,
			500000
		},
		experience_mul = {
			1.2,
			1.2,
			1.2,
			1.2,
			1.2
		},
		contract_visuals = {}
	}
	self.jobs.firestarter.contract_visuals.min_mission_xp = {
		30000,
		30000,
		30000,
		30000,
		30000,
		30000,
		30000
	}
	self.jobs.firestarter.contract_visuals.max_mission_xp = {
		44000,
		44000,
		44000,
		44000,
		44000,
		44000,
		44000
	}
	self.stages.alex_1 = {
		type = "d",
		type_id = "heist_type_survive",
		level_id = "alex_1"
	}
	self.stages.alex_2 = {
		type = "d",
		type_id = "heist_type_survive",
		level_id = "alex_2"
	}
	self.stages.alex_3 = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "alex_3"
	}
	self.jobs.alex = {
		name_id = "heist_alex",
		briefing_id = "heist_alex_crimenet",
		package = "packages/job_rats",
		contact = "hector",
		jc = 40,
		chain = {
			self.stages.alex_1,
			self.stages.alex_2,
			self.stages.alex_3
		},
		briefing_event = "hct_rats_brf_speak",
		debrief_event = "hct_rats_debrief",
		crimenet_callouts = {
			"hct_rats_cnc_01"
		},
		crimenet_videos = {
			"cn_rat1",
			"cn_rat2",
			"cn_rat3"
		},
		experience_mul = {
			1,
			1,
			1,
			1,
			1.5
		},
		payout = {
			10000,
			15000,
			20000,
			30000,
			50000,
			50000,
			50000
		},
		contract_cost = {
			24000,
			48000,
			120000,
			240000,
			300000,
			300000,
			300000
		},
		contract_visuals = {}
	}
	self.jobs.alex.contract_visuals.min_mission_xp = {
		24000,
		24000,
		24000,
		24000,
		24000,
		24000,
		24000
	}
	self.jobs.alex.contract_visuals.max_mission_xp = {
		96000,
		96000,
		96000,
		96000,
		96000,
		96000,
		96000
	}
	self.stages.welcome_to_the_jungle_1_d = {
		type = "e",
		world_setting = "day",
		level_id = "welcome_to_the_jungle_1",
		type_id = "heist_type_assault",
		mission_filter = {
			1
		}
	}
	self.stages.welcome_to_the_jungle_1_n = {
		type = "e",
		world_setting = "night",
		level_id = "welcome_to_the_jungle_1_night",
		type_id = "heist_type_assault",
		mission_filter = {
			1
		}
	}
	self.stages.welcome_to_the_jungle_2 = {
		type = "e",
		type_id = "heist_type_stealth",
		level_id = "welcome_to_the_jungle_2",
		mission_filter = {
			1
		}
	}
	self.jobs.welcome_to_the_jungle_wrapper = {
		name_id = "heist_welcome_to_the_jungle",
		briefing_id = "heist_welcome_to_the_jungle_crimenet",
		contact = "the_elephant",
		jc = 50,
		chain = {
			{}
		},
		job_wrapper = {
			"welcome_to_the_jungle",
			"welcome_to_the_jungle_night"
		},
		briefing_event = "elp_bigoil_brf",
		debrief_event = "elp_bigoil_debrief",
		crimenet_callouts = {
			"elp_bigoil_cnc_01"
		},
		crimenet_videos = {
			"cn_bigoil1",
			"cn_bigoil2",
			"cn_bigoil3"
		},
		payout = {
			200000,
			275000,
			400000,
			500000,
			800000,
			800000,
			800000
		},
		contract_cost = {
			20000,
			36000,
			50000,
			90000,
			150000,
			150000,
			150000
		},
		contract_visuals = {}
	}
	self.jobs.welcome_to_the_jungle_wrapper.contract_visuals.min_mission_xp = {
		33000,
		33000,
		33000,
		33000,
		33000,
		33000,
		33000
	}
	self.jobs.welcome_to_the_jungle_wrapper.contract_visuals.max_mission_xp = {
		37500,
		37500,
		37500,
		37500,
		37500,
		37500,
		37500
	}
	self.jobs.welcome_to_the_jungle_wrapper_prof = deep_clone(self.jobs.welcome_to_the_jungle_wrapper)
	self.jobs.welcome_to_the_jungle_wrapper_prof.job_wrapper = {
		"welcome_to_the_jungle_prof",
		"welcome_to_the_jungle_night_prof"
	}
	self.jobs.welcome_to_the_jungle_wrapper_prof.jc = 70
	self.jobs.welcome_to_the_jungle_wrapper_prof.region = "professional"
	self.jobs.welcome_to_the_jungle_wrapper_prof.payout = {
		250000,
		300000,
		450000,
		550000,
		850000,
		850000,
		850000
	}
	self.jobs.welcome_to_the_jungle_wrapper_prof.contract_cost = {
		54000,
		108000,
		270000,
		540000,
		700000,
		700000,
		700000
	}
	self.jobs.welcome_to_the_jungle = {
		job_wrapper = nil,
		package = "packages/job_bigoil",
		chain = {
			self.stages.welcome_to_the_jungle_1_d,
			self.stages.welcome_to_the_jungle_2
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_bigoil_01"
	}
	self.jobs.welcome_to_the_jungle_prof = deep_clone(self.jobs.welcome_to_the_jungle)
	self.jobs.welcome_to_the_jungle_night = deep_clone(self.jobs.welcome_to_the_jungle)
	self.jobs.welcome_to_the_jungle_night.chain = {
		self.stages.welcome_to_the_jungle_1_n,
		self.stages.welcome_to_the_jungle_2
	}
	self.jobs.welcome_to_the_jungle_night_prof = deep_clone(self.jobs.welcome_to_the_jungle_night)
	self.stages.framing_frame_1 = {
		type = "e",
		type_id = "heist_type_knockover",
		level_id = "framing_frame_1",
		mission_filter = {
			1
		}
	}
	self.stages.framing_frame_2 = {
		type = "e",
		type_id = "heist_type_trade",
		level_id = "framing_frame_2",
		mission_filter = {
			1
		}
	}
	self.stages.framing_frame_3 = {
		type = "e",
		type_id = "heist_type_stealth",
		level_id = "framing_frame_3",
		mission_filter = {
			1
		}
	}
	self.jobs.framing_frame = {
		name_id = "heist_framing_frame",
		briefing_id = "heist_framing_frame_crimenet",
		package = "packages/job_framing_frame",
		contact = "the_elephant",
		jc = 50,
		chain = {
			self.stages.framing_frame_1,
			self.stages.framing_frame_2,
			self.stages.framing_frame_3
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_framingframe_01",
		briefing_event = "elp_framing_brf",
		debrief_event = "elp_framing_debrief",
		crimenet_callouts = {
			"elp_framing_cmc_01"
		},
		crimenet_videos = {
			"cn_framingframe1",
			"cn_framingframe2",
			"cn_framingframe3"
		},
		payout = {
			60000,
			120000,
			300000,
			600000,
			800000,
			800000,
			800000
		},
		contract_cost = {
			31000,
			62000,
			155000,
			310000,
			400000,
			400000,
			400000
		},
		contract_visuals = {}
	}
	self.jobs.framing_frame.contract_visuals.min_mission_xp = {
		18500,
		20000,
		20000,
		20000,
		20000,
		20000,
		20000
	}
	self.jobs.framing_frame.contract_visuals.max_mission_xp = {
		42000,
		42000,
		42000,
		42000,
		42000,
		42000,
		42000
	}
	self.stages.watchdogs_1_d = {
		type = "d",
		type_id = "heist_type_survive",
		world_setting = "day",
		level_id = "watchdogs_1"
	}
	self.stages.watchdogs_1_n = {
		type = "d",
		type_id = "heist_type_survive",
		world_setting = "night",
		level_id = "watchdogs_1_night"
	}
	self.stages.watchdogs_2_d = {
		type = "d",
		type_id = "heist_type_survive",
		world_setting = "day",
		level_id = "watchdogs_2_day"
	}
	self.stages.watchdogs_2_n = {
		type = "d",
		type_id = "heist_type_survive",
		world_setting = "night",
		level_id = "watchdogs_2"
	}
	self.jobs.watchdogs_wrapper = {
		name_id = "heist_watchdogs",
		briefing_id = "heist_watchdogs_crimenet",
		contact = "hector",
		region = "dock",
		jc = 50,
		chain = {
			{}
		},
		job_wrapper = {
			"watchdogs",
			"watchdogs_night"
		},
		briefing_event = "hct_watchdogs_brf_speak",
		debrief_event = "hct_watchdogs_debrief",
		crimenet_callouts = {
			"hct_watchdogs_cnc_01"
		},
		crimenet_videos = {
			"cn_watchdog1",
			"cn_watchdog2",
			"cn_watchdog3"
		},
		payout = {
			60000,
			74000,
			125000,
			185000,
			260000,
			260000,
			260000
		},
		contract_cost = {
			31000,
			62000,
			155000,
			310000,
			400000,
			400000,
			400000
		},
		contract_visuals = {}
	}
	self.jobs.watchdogs_wrapper.contract_visuals.min_mission_xp = {
		24000,
		24000,
		24000,
		24000,
		24000,
		24000,
		24000
	}
	self.jobs.watchdogs_wrapper.contract_visuals.max_mission_xp = {
		40000,
		40000,
		40000,
		40000,
		40000,
		40000,
		40000
	}
	self.jobs.watchdogs = {
		package = "packages/job_watchdogs",
		chain = {
			self.stages.watchdogs_1_d,
			self.stages.watchdogs_2_n
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_watchdogs_01"
	}
	self.jobs.watchdogs_night = deep_clone(self.jobs.watchdogs)
	self.jobs.watchdogs_night.chain = {
		self.stages.watchdogs_1_n,
		self.stages.watchdogs_2_d
	}
	self.jobs.watchdogs_night.load_screen = "guis/dlcs/pic/textures/loading/job_watchdogs_01"
	self.stages.nightclub = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "nightclub"
	}
	self.jobs.nightclub = {
		name_id = "heist_nightclub",
		briefing_id = "heist_nightclub_crimenet",
		package = "packages/job_nightclub",
		region = "street",
		contact = "vlad",
		jc = 30,
		chain = {
			self.stages.nightclub
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_nightclub",
		briefing_event = "vld_nightclub_brf",
		debrief_event = "vld_nightclub_debrief",
		crimenet_callouts = {
			"vld_nightclub_cnc_01"
		},
		crimenet_videos = {
			"cn_nightc1",
			"cn_nightc2",
			"cn_nightc3"
		},
		payout = {
			20000,
			22500,
			40000,
			60000,
			80000,
			80000,
			80000
		},
		contract_cost = {
			16000,
			32000,
			80000,
			160000,
			200000,
			200000,
			200000
		},
		contract_visuals = {}
	}
	self.jobs.nightclub.contract_visuals.min_mission_xp = {
		8000,
		8000,
		8000,
		8000,
		8000,
		8000,
		8000
	}
	self.jobs.nightclub.contract_visuals.max_mission_xp = {
		12000,
		12000,
		12000,
		12000,
		12000,
		12000,
		12000
	}
	self.stages.ukrainian_job = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "ukrainian_job"
	}
	self.jobs.ukrainian_job = {
		name_id = "heist_ukrainian_job",
		briefing_id = "heist_ukrainian_job_crimenet",
		package = "packages/job_ukrainian",
		contact = "vlad",
		region = "street",
		jc = 20,
		chain = {
			self.stages.ukrainian_job
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_jewelry_store",
		briefing_event = "vld_ukranian_brf",
		debrief_event = "vld_ukranian_debrief",
		crimenet_callouts = {
			"vld_ukranian_cnc_01"
		},
		crimenet_videos = {
			"cn_ukr1",
			"cn_ukr2",
			"cn_ukr3"
		},
		payout = {
			20000,
			21000,
			23000,
			25000,
			30000,
			30000,
			30000
		},
		contract_visuals = {}
	}
	self.jobs.ukrainian_job.contract_visuals.min_mission_xp = {
		4000,
		4000,
		4000,
		4000,
		4000,
		4000,
		4000
	}
	self.jobs.ukrainian_job.contract_visuals.max_mission_xp = {
		10000,
		10000,
		10000,
		10000,
		10000,
		10000,
		10000
	}
	self.jobs.ukrainian_job_prof = deep_clone(self.jobs.ukrainian_job)
	self.jobs.ukrainian_job_prof.jc = 20
	self.jobs.ukrainian_job_prof.region = "professional"
	self.jobs.ukrainian_job_prof.payout = {
		21000,
		24000,
		26000,
		30000,
		40000,
		40000,
		40000
	}
	self.jobs.ukrainian_job_prof.contract_cost = {
		8000,
		16000,
		40000,
		80000,
		100000,
		100000,
		100000
	}
	self.stages.jewelry_store = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "jewelry_store"
	}
	self.jobs.jewelry_store = {
		name_id = "heist_jewelry_store",
		briefing_id = "heist_jewelry_store_crimenet",
		package = "packages/job_jewelry",
		contact = "bain",
		region = "street",
		jc = 10,
		chain = {
			self.stages.jewelry_store
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_jewelry_store",
		briefing_event = "pln_jewelerystore_stage1_brief",
		debrief_event = nil,
		crimenet_callouts = {
			"pln_jewelrystore_stage1_cnc_01"
		},
		crimenet_videos = {
			"cn_jewel1",
			"cn_jewel2",
			"cn_jewel3"
		},
		experience_mul = {
			1,
			1,
			1,
			1,
			3
		},
		payout = {
			6000,
			12000,
			30000,
			50000,
			60000,
			60000,
			60000
		},
		contract_cost = {
			4000,
			8000,
			20000,
			40000,
			100000,
			100000,
			100000
		},
		contract_visuals = {}
	}
	self.jobs.jewelry_store.contract_visuals.min_mission_xp = {
		2000,
		2000,
		2000,
		2000,
		2000,
		2000,
		2000
	}
	self.jobs.jewelry_store.contract_visuals.max_mission_xp = {
		8000,
		8000,
		8000,
		8000,
		8000,
		8000,
		8000
	}
	self.stages.four_stores = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "four_stores"
	}
	self.jobs.four_stores = {
		name_id = "heist_four_stores",
		briefing_id = "heist_four_stores_crimenet",
		package = "packages/job_four_stores",
		contact = "vlad",
		region = "street",
		jc = 20,
		chain = {
			self.stages.four_stores
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_fourstores",
		briefing_event = "vld_fourstores_brf",
		debrief_event = "vld_fourstores_debrief",
		crimenet_callouts = {
			"vld_fourstores_cnc_01"
		},
		crimenet_videos = {
			"cn_fours1",
			"cn_fours2",
			"cn_fours3"
		},
		payout = {
			9000,
			18000,
			45000,
			90000,
			120000,
			120000,
			120000
		},
		contract_cost = {
			8000,
			16000,
			40000,
			80000,
			100000,
			100000,
			100000
		},
		contract_visuals = {}
	}
	self.jobs.four_stores.contract_visuals.min_mission_xp = 6000
	self.jobs.four_stores.contract_visuals.max_mission_xp = 6000
	self.stages.mallcrasher = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "mallcrasher"
	}
	self.jobs.mallcrasher = {
		name_id = "heist_mallcrasher",
		briefing_id = "heist_mallcrasher_crimenet",
		package = "packages/job_mallcrasher",
		contact = "vlad",
		region = "street",
		jc = 20,
		chain = {
			self.stages.mallcrasher
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_mallcrasher",
		briefing_event = "vld_mallcrashers_brf",
		debrief_event = "vld_mallcrashers_debrief",
		crimenet_callouts = {
			"vld_mallcrashers_cnc_01"
		},
		crimenet_videos = {
			"cn_mallcrash1",
			"cn_mallcrash2",
			"cn_mallcrash3"
		},
		payout = {
			9000,
			18000,
			45000,
			90000,
			120000,
			120000,
			120000
		},
		contract_cost = {
			8000,
			16000,
			40000,
			80000,
			100000,
			100000,
			100000
		},
		contract_visuals = {}
	}
	self.jobs.mallcrasher.contract_visuals.min_mission_xp = {
		6000,
		6000,
		6000,
		6000,
		6000,
		6000,
		6000
	}
	self.jobs.mallcrasher.contract_visuals.max_mission_xp = {
		6000,
		6000,
		6000,
		6000,
		6000,
		6000,
		6000
	}
	self.stages.branchbank_random = {
		type = "d",
		level_id = "branchbank",
		type_id = "heist_type_assault",
		mission = "standalone",
		mission_filter = {
			4
		}
	}
	self.jobs.branchbank = {
		name_id = "heist_branchbank",
		briefing_id = "heist_branchbank_crimenet",
		package = "packages/job_branchbank_random",
		contact = "bain",
		region = "street",
		jc = 30,
		chain = {
			self.stages.branchbank_random
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_branchbank",
		briefing_event = "pln_branchbank_random_brf_speak",
		debrief_event = nil,
		crimenet_callouts = {
			"pln_branchbank_random_cnc_01"
		},
		crimenet_videos = {
			"cn_branchbank1",
			"cn_branchbank2",
			"cn_branchbank3"
		},
		payout = {
			20000,
			30000,
			40000,
			70000,
			80000,
			80000,
			80000
		},
		contract_cost = {
			16000,
			32000,
			80000,
			160000,
			200000,
			200000,
			200000
		},
		contract_visuals = {}
	}
	self.jobs.branchbank.contract_visuals.min_mission_xp = {
		12000,
		12000,
		12000,
		12000,
		12000,
		12000,
		12000
	}
	self.jobs.branchbank.contract_visuals.max_mission_xp = {
		12000,
		12000,
		12000,
		12000,
		12000,
		12000,
		12000
	}
	self.jobs.branchbank_prof = deep_clone(self.jobs.branchbank)
	self.jobs.branchbank_prof.jc = 30
	self.jobs.branchbank_prof.region = "professional"
	self.jobs.branchbank_prof.payout = {
		26000,
		40000,
		48000,
		70000,
		85000,
		85000,
		85000
	}
	self.jobs.branchbank_prof.contract_cost = {
		16000,
		32000,
		80000,
		160000,
		200000,
		200000,
		200000
	}
	self.stages.branchbank_deposit = {
		briefing_id = "heist_branchbank_deposit_briefing",
		briefing_dialog = "Play_pln_branchbank_depositbox_stage1_brief",
		level_id = "branchbank",
		type = "d",
		type_id = "heist_type_assault",
		mission = "standalone",
		mission_filter = {
			1
		}
	}
	self.jobs.branchbank_deposit = {
		name_id = "heist_branchbank_deposit",
		briefing_id = "heist_branchbank_deposit_crimenet",
		package = "packages/job_branchbank_deposit",
		contact = "bain",
		region = "street",
		jc = 30,
		chain = {
			self.stages.branchbank_deposit
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_branchbank",
		briefing_event = "pln_branchbank_depositbox_brf_speak",
		debrief_event = nil,
		crimenet_callouts = {
			"pln_branchbank_deposit_cnc_01"
		},
		crimenet_videos = {
			"cn_branchbank1",
			"cn_branchbank2",
			"cn_branchbank3"
		},
		payout = {
			30000,
			35000,
			44000,
			68000,
			76000,
			76000,
			76000
		},
		contract_cost = {
			16000,
			32000,
			80000,
			160000,
			200000,
			200000,
			200000
		},
		contract_visuals = {}
	}
	self.jobs.branchbank_deposit.contract_visuals.min_mission_xp = {
		12000,
		12000,
		12000,
		12000,
		12000,
		12000,
		12000
	}
	self.jobs.branchbank_deposit.contract_visuals.max_mission_xp = {
		12000,
		12000,
		12000,
		12000,
		12000,
		12000,
		12000
	}
	self.stages.branchbank_cash = {
		briefing_id = "heist_branchbank_cash_briefing",
		briefing_dialog = "Play_pln_branchbank_cash_stage1_brief",
		level_id = "branchbank",
		type = "d",
		type_id = "heist_type_assault",
		mission = "standalone",
		mission_filter = {
			2
		}
	}
	self.jobs.branchbank_cash = {
		name_id = "heist_branchbank_cash",
		briefing_id = "heist_branchbank_cash_crimenet",
		package = "packages/job_branchbank_cash",
		contact = "bain",
		region = "street",
		jc = 30,
		chain = {
			self.stages.branchbank_cash
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_branchbank",
		briefing_event = "pln_branchbank_cash_brf_speak",
		debrief_event = nil,
		crimenet_callouts = {
			"pln_branchbank_cash_cnc_01"
		},
		crimenet_videos = {
			"cn_branchbank1",
			"cn_branchbank2",
			"cn_branchbank3"
		},
		payout = {
			10000,
			15000,
			40000,
			60000,
			75000,
			75000,
			75000
		},
		contract_cost = {
			16000,
			32000,
			80000,
			160000,
			200000,
			200000,
			200000
		},
		contract_visuals = {}
	}
	self.jobs.branchbank_cash.contract_visuals.min_mission_xp = {
		12000,
		12000,
		12000,
		12000,
		12000,
		12000,
		12000
	}
	self.jobs.branchbank_cash.contract_visuals.max_mission_xp = {
		12000,
		12000,
		12000,
		12000,
		12000,
		12000,
		12000
	}
	self.stages.branchbank_gold = {
		briefing_id = "heist_branchbank_gold_briefing",
		briefing_dialog = "Play_pln_branchbank_gold_stage1_brief",
		level_id = "branchbank",
		type = "d",
		type_id = "heist_type_assault",
		mission = "standalone",
		mission_filter = {
			3
		}
	}
	self.jobs.branchbank_gold = {
		name_id = "heist_branchbank_gold",
		briefing_id = "heist_branchbank_gold_crimenet",
		package = "packages/job_branchbank_gold",
		contact = "bain",
		region = "street",
		jc = 30,
		chain = {
			self.stages.branchbank_gold
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_branchbank",
		briefing_event = "pln_branchbank_gold_brf_speak",
		debrief_event = nil,
		crimenet_callouts = {
			"pln_branchbank_gold_cnc_01"
		},
		crimenet_videos = {
			"cn_branchbank1",
			"cn_branchbank2",
			"cn_branchbank3"
		},
		payout = {
			20000,
			25000,
			50000,
			75000,
			85000,
			85000,
			85000
		},
		contract_cost = {
			16000,
			32000,
			80000,
			160000,
			200000,
			200000,
			200000
		},
		contract_visuals = {}
	}
	self.jobs.branchbank_gold.contract_visuals.min_mission_xp = {
		12000,
		12000,
		12000,
		12000,
		12000,
		12000,
		12000
	}
	self.jobs.branchbank_gold.contract_visuals.max_mission_xp = {
		12000,
		12000,
		12000,
		12000,
		12000,
		12000,
		12000
	}
	self.jobs.branchbank_gold_prof = deep_clone(self.jobs.branchbank_gold)
	self.jobs.branchbank_gold_prof.jc = 30
	self.jobs.branchbank_gold_prof.region = "professional"
	self.jobs.branchbank_gold_prof.payout = {
		26000,
		40000,
		54000,
		76000,
		90000,
		90000,
		90000
	}
	self.jobs.branchbank_gold_prof.contract_cost = {
		16000,
		32000,
		80000,
		160000,
		200000,
		200000,
		200000
	}
	self.stages.election_day_1 = {
		type = "e",
		type_id = "heist_type_assault",
		level_id = "election_day_1",
		mission_filter = {
			1
		}
	}
	self.stages.election_day_2 = {
		type = "e",
		type_id = "heist_type_assault",
		level_id = "election_day_2",
		mission_filter = {
			1
		}
	}
	self.stages.election_day_3 = {
		type = "e",
		type_id = "heist_type_knockover",
		level_id = "election_day_3",
		mission_filter = {
			1
		}
	}
	self.stages.election_day_3_skip1 = {
		type = "e",
		type_id = "heist_type_knockover",
		level_id = "election_day_3_skip1",
		mission_filter = {
			1
		}
	}
	self.stages.election_day_3_skip2 = {
		type = "e",
		type_id = "heist_type_knockover",
		level_id = "election_day_3_skip2",
		mission_filter = {
			1
		}
	}
	self.jobs.election_day = {
		name_id = "heist_election_day",
		briefing_id = "heist_election_day_crimenet",
		package = "packages/job_election_day",
		contact = "the_elephant",
		jc = 40,
		chain = {
			self.stages.election_day_1,
			{
				self.stages.election_day_2,
				self.stages.election_day_3,
				self.stages.election_day_3_skip1,
				self.stages.election_day_3_skip2
			}
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_electionday_01",
		briefing_event = "elp_election_brf",
		debrief_event = "elp_election_debrief",
		crimenet_callouts = {
			"elp_election_cmc_01"
		},
		crimenet_videos = {
			"cn_elcday1",
			"cn_elcday2",
			"cn_elcday3"
		},
		payout = {
			20000,
			25000,
			40000,
			60000,
			90000,
			90000,
			90000
		},
		contract_cost = {
			24000,
			48000,
			120000,
			240000,
			300000,
			300000,
			300000
		},
		contract_visuals = {}
	}
	self.jobs.election_day.contract_visuals.min_mission_xp = {
		10000,
		10000,
		10000,
		10000,
		10000,
		10000,
		10000
	}
	self.jobs.election_day.contract_visuals.max_mission_xp = {
		44000,
		44000,
		44000,
		44000,
		44000,
		44000,
		44000
	}
	self.stages.safehouse = {
		type_id = "heist_type_assault",
		type = "d",
		level_id = "safehouse",
		briefing_id = Global.mission_manager and Global.mission_manager.saved_job_values.playedSafeHouseBefore and "heist_safehouse_briefing_2" or nil
	}
	self.jobs.safehouse = {
		name_id = "heist_safehouse",
		briefing_id = "heist_safehouse_crimenet"
	}
	local platform = SystemInfo:platform()

	if platform == Idstring("XB1") or platform == Idstring("PS4") then
		self.jobs.safehouse.contact = "bain_no_variation"
	else
		self.jobs.safehouse.contact = "bain"
	end

	self.jobs.safehouse.jc = 5
	self.jobs.safehouse.chain = {
		self.stages.safehouse
	}
	self.jobs.safehouse.briefing_event = nil
	self.jobs.safehouse.debrief_event = nil
	self.jobs.safehouse.crimenet_callouts = {}
	self.jobs.arm_wrapper = {}
	self.jobs.arm_wrapper = {
		name_id = "heist_arm_temp",
		briefing_id = "heist_arm_crimenet",
		contact = "bain",
		jc = 30,
		chain = {
			{}
		},
		job_wrapper = {
			"arm_cro",
			"arm_und",
			"arm_hcm",
			"arm_par",
			"arm_fac"
		},
		briefing_event = "pln_at1_brf_01",
		crimenet_callouts = {
			"pln_at1_cnc_01"
		},
		crimenet_videos = {
			"cn_branchbank1",
			"cn_branchbank3"
		},
		payout = {
			8500,
			11000,
			30000,
			32000,
			44000,
			44000,
			44000
		},
		experience_mul = {
			1,
			1,
			1,
			1.2,
			1.2
		},
		contract_cost = {
			16000,
			32000,
			80000,
			160000,
			200000,
			200000,
			200000
		}
	}
	self.stages.arm_cro = {
		type = "d",
		dlc = "armored_transport",
		level_id = "arm_cro",
		type_id = "heist_type_assault",
		mission_filter = {
			4
		}
	}
	self.jobs.arm_cro = {
		name_id = "heist_arm_cro",
		briefing_id = "heist_arm_cro_crimenet",
		package = "packages/job_arm_cro",
		contact = "bain",
		region = "street",
		jc = 30,
		chain = {
			self.stages.arm_cro
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_crossroads",
		briefing_event = "pln_at1_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"pln_at1_cnc_01_01"
		},
		crimenet_videos = {
			"cn_branchbank1",
			"cn_branchbank3"
		},
		payout = {
			30500,
			34000,
			50000,
			62000,
			74000,
			74000,
			74000
		},
		experience_mul = {
			1,
			1,
			1,
			1.2,
			1.2
		},
		contract_cost = {
			16000,
			32000,
			80000,
			160000,
			200000,
			200000,
			200000
		},
		dlc = "armored_transport",
		spawn_chance_multiplier = 0.5,
		contract_visuals = {}
	}
	self.jobs.arm_cro.contract_visuals.min_mission_xp = {
		12000,
		12000,
		12000,
		12000,
		12000,
		12000,
		12000
	}
	self.jobs.arm_cro.contract_visuals.max_mission_xp = {
		12000,
		12000,
		12000,
		12000,
		12000,
		12000,
		12000
	}
	self.stages.arm_und = {
		type = "d",
		dlc = "armored_transport",
		level_id = "arm_und",
		type_id = "heist_type_assault",
		mission_filter = {
			4
		}
	}
	self.jobs.arm_und = {
		name_id = "heist_arm_und",
		briefing_id = "heist_arm_und_crimenet",
		package = "packages/job_arm_und",
		contact = "bain",
		region = "street",
		jc = 30,
		chain = {
			self.stages.arm_und
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_underpass",
		briefing_event = "pln_at1_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"pln_at1_cnc_05_01"
		},
		crimenet_videos = {
			"cn_branchbank1",
			"cn_branchbank3"
		},
		payout = {
			27500,
			31000,
			48000,
			53000,
			66600,
			66600,
			66600
		},
		contract_cost = {
			16000,
			32000,
			80000,
			160000,
			200000,
			200000,
			200000
		},
		experience_mul = {
			1,
			1,
			1,
			1.2,
			1.2
		},
		dlc = "armored_transport",
		spawn_chance_multiplier = 0.5,
		contract_visuals = {}
	}
	self.jobs.arm_und.contract_visuals.min_mission_xp = {
		12000,
		12000,
		12000,
		12000,
		12000,
		12000,
		12000
	}
	self.jobs.arm_und.contract_visuals.max_mission_xp = {
		12000,
		12000,
		12000,
		12000,
		12000,
		12000,
		12000
	}
	self.stages.arm_hcm = {
		type = "d",
		dlc = "armored_transport",
		level_id = "arm_hcm",
		type_id = "heist_type_assault",
		mission_filter = {
			4
		}
	}
	self.jobs.arm_hcm = {
		name_id = "heist_arm_hcm",
		briefing_id = "heist_arm_hcm_crimenet",
		package = "packages/job_arm_hcm",
		contact = "bain",
		region = "street",
		jc = 30,
		chain = {
			self.stages.arm_hcm
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_downtown",
		briefing_event = "pln_at1_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"pln_at1_cnc_02_01"
		},
		crimenet_videos = {
			"cn_branchbank1",
			"cn_branchbank3"
		},
		payout = {
			26500,
			31000,
			50000,
			52000,
			64000,
			64000,
			64000
		},
		contract_cost = {
			16000,
			32000,
			80000,
			160000,
			200000,
			200000,
			200000
		},
		experience_mul = {
			1,
			1,
			1,
			1.2,
			1.2
		},
		dlc = "armored_transport",
		spawn_chance_multiplier = 0.5,
		contract_visuals = {}
	}
	self.jobs.arm_hcm.contract_visuals.min_mission_xp = {
		12000,
		12000,
		12000,
		12000,
		12000,
		12000,
		12000
	}
	self.jobs.arm_hcm.contract_visuals.max_mission_xp = {
		12000,
		12000,
		12000,
		12000,
		12000,
		12000,
		12000
	}
	self.stages.arm_par = {
		type = "d",
		dlc = "armored_transport",
		level_id = "arm_par",
		type_id = "heist_type_assault",
		mission_filter = {
			4
		}
	}
	self.jobs.arm_par = {
		name_id = "heist_arm_par",
		briefing_id = "heist_arm_par_crimenet",
		package = "packages/job_arm_par",
		contact = "bain",
		region = "street",
		jc = 30,
		chain = {
			self.stages.arm_par
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_park",
		briefing_event = "pln_at1_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"pln_at1_cnc_04_01"
		},
		crimenet_videos = {
			"cn_branchbank1",
			"cn_branchbank3"
		},
		payout = {
			28500,
			31000,
			40000,
			43000,
			56000,
			56000,
			56000
		},
		contract_cost = {
			16000,
			32000,
			80000,
			160000,
			200000,
			200000,
			200000
		},
		experience_mul = {
			1,
			1,
			1,
			1.2,
			1.2
		},
		dlc = "armored_transport",
		spawn_chance_multiplier = 0.5,
		contract_visuals = {}
	}
	self.jobs.arm_par.contract_visuals.min_mission_xp = {
		12000,
		12000,
		12000,
		12000,
		12000,
		12000,
		12000
	}
	self.jobs.arm_par.contract_visuals.max_mission_xp = {
		12000,
		12000,
		12000,
		12000,
		12000,
		12000,
		12000
	}
	self.stages.arm_fac = {
		type = "d",
		dlc = "armored_transport",
		level_id = "arm_fac",
		type_id = "heist_type_assault",
		mission_filter = {
			4
		}
	}
	self.jobs.arm_fac = {
		name_id = "heist_arm_fac",
		briefing_id = "heist_arm_fac_crimenet",
		package = "packages/job_arm_fac",
		contact = "bain",
		region = "street",
		jc = 30,
		chain = {
			self.stages.arm_fac
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_harbor",
		briefing_event = "pln_at1_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"pln_at1_cnc_03_01"
		},
		crimenet_videos = {
			"cn_branchbank1",
			"cn_branchbank3"
		},
		payout = {
			22500,
			29000,
			40000,
			42000,
			54000,
			54000,
			54000
		},
		contract_cost = {
			16000,
			32000,
			80000,
			160000,
			200000,
			200000,
			200000
		},
		experience_mul = {
			1,
			1,
			1,
			1.2,
			1.2
		},
		dlc = "armored_transport",
		spawn_chance_multiplier = 0.5,
		contract_visuals = {}
	}
	self.jobs.arm_fac.contract_visuals.min_mission_xp = {
		12000,
		12000,
		12000,
		12000,
		12000,
		12000,
		12000
	}
	self.jobs.arm_fac.contract_visuals.max_mission_xp = {
		12000,
		12000,
		12000,
		12000,
		12000,
		12000,
		12000
	}
	self.stages.arm_for = {
		type = "d",
		dlc = "armored_transport",
		level_id = "arm_for",
		type_id = "heist_type_assault",
		mission_filter = {
			4
		}
	}
	self.jobs.arm_for = {
		name_id = "heist_arm_for",
		briefing_id = "heist_arm_for_crimenet",
		contact = "bain",
		region = "street",
		jc = 70,
		package = "packages/job_arm_for",
		chain = {
			self.stages.arm_for
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_trainheist",
		briefing_event = "pln_tr1b_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"pln_tr1b_cnc_01_01"
		},
		crimenet_videos = {
			"cn_jewel1",
			"cn_jewel2",
			"cn_jewel1"
		},
		payout = {
			26000,
			37000,
			81000,
			101000,
			202000,
			202000,
			202000
		},
		experience_mul = {
			1,
			1,
			1,
			1.5,
			1.5
		},
		contract_cost = {
			31000,
			62000,
			155000,
			310000,
			400000,
			400000,
			400000
		},
		dlc = "armored_transport",
		contract_visuals = {}
	}
	self.jobs.arm_for.contract_visuals.min_mission_xp = {
		20200,
		20200,
		20200,
		20200,
		20200,
		20200,
		20200
	}
	self.jobs.arm_for.contract_visuals.max_mission_xp = {
		36000,
		36000,
		36000,
		36000,
		36000,
		36000,
		36000
	}
	self.stages.rat = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "rat"
	}
	self.jobs.rat = {
		name_id = "heist_rat",
		briefing_id = "heist_rat_crimenet",
		contact = "bain",
		region = "street",
		jc = 60,
		package = "packages/narr_rat",
		chain = {
			self.stages.rat
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_cookoff",
		briefing_event = "pln_rt1b_cbf_01",
		debrief_event = {
			"Play_pln_rt1b_end_01",
			"Play_pln_rt1b_end_02",
			"Play_pln_rt1b_end_03",
			"Play_pln_rt1b_end_04"
		},
		crimenet_callouts = {
			"pln_rt1b_cnc_01"
		},
		crimenet_videos = {
			"cn_branchbank1",
			"cn_branchbank2",
			"cn_branchbank3"
		},
		payout = {
			90000,
			135000,
			180000,
			310000,
			380000,
			380000,
			380000
		},
		contract_cost = {
			47000,
			94000,
			235000,
			470000,
			600000,
			600000,
			600000
		},
		contract_visuals = {}
	}
	self.jobs.rat.contract_visuals.min_mission_xp = {
		16000,
		16000,
		16000,
		16000,
		16000,
		16000,
		16000
	}
	self.jobs.rat.contract_visuals.max_mission_xp = {
		9600000,
		9600000,
		9600000,
		9600000,
		9600000,
		9600000,
		9600000
	}
	self.stages.family = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "family"
	}
	self.jobs.family = {
		name_id = "heist_family",
		briefing_id = "heist_family_crimenet",
		package = "packages/job_family",
		contact = "bain",
		region = "street",
		jc = 20,
		chain = {
			self.stages.family
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_diamondstore",
		briefing_event = "pln_fj1_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"pln_fj1_cnc_01_01"
		},
		crimenet_videos = {
			"cn_jewel1",
			"cn_jewel2",
			"cn_jewel3"
		},
		payout = {
			6000,
			12000,
			30000,
			50000,
			60000,
			60000,
			60000
		},
		contract_cost = {
			16000,
			32000,
			80000,
			160000,
			200000,
			200000,
			200000
		},
		experience_mul = {
			1.5,
			1.5,
			1.5,
			1.5,
			1.5
		},
		contract_visuals = {}
	}
	self.jobs.family.contract_visuals.min_mission_xp = {
		6000,
		6000,
		6000,
		6000,
		6000,
		6000,
		6000
	}
	self.jobs.family.contract_visuals.max_mission_xp = {
		20000,
		20000,
		20000,
		20000,
		20000,
		20000,
		20000
	}
	self.stages.big = {
		type = "d",
		dlc = "big_bank",
		level_id = "big",
		world_setting = "day",
		type_id = "heist_type_assault",
		mission_filter = {
			1
		}
	}
	self.jobs.big = {
		name_id = "heist_big",
		briefing_id = "heist_big_crimenet",
		package = "packages/job_big",
		contact = "the_dentist",
		region = "street",
		jc = 60,
		chain = {
			self.stages.big
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_bigbank",
		briefing_event = "gus_bb1_cbf_01",
		debrief_event = "gus_bb1_debrief_01",
		crimenet_callouts = {
			"gus_bb1_cnc_01"
		},
		crimenet_videos = {
			"cn_big1",
			"cn_big2",
			"cn_big3"
		},
		payout = {
			90000,
			135000,
			180000,
			310000,
			380000,
			380000,
			380000
		},
		contract_cost = {
			47000,
			94000,
			235000,
			470000,
			600000,
			600000,
			600000
		},
		dlc = "big_bank",
		contract_visuals = {}
	}
	self.jobs.big.contract_visuals.min_mission_xp = {
		34000,
		34000,
		34000,
		34000,
		34000,
		34000,
		34000
	}
	self.jobs.big.contract_visuals.max_mission_xp = {
		45000,
		45000,
		45000,
		45000,
		45000,
		45000,
		45000
	}

	if SystemInfo:distribution() == Idstring("STEAM") then
		self.stages.roberts = {
			type = "d",
			type_id = "heist_type_assault",
			level_id = "roberts"
		}
		self.jobs.roberts = {
			name_id = "heist_roberts",
			briefing_id = "heist_roberts_crimenet",
			package = "packages/job_roberts",
			contact = "bain",
			region = "street",
			jc = 40,
			chain = {
				self.stages.roberts
			},
			load_screen = "guis/dlcs/pic/textures/loading/job_go_bank",
			briefing_event = "pln_cs1_cbf_01",
			debrief_event = nil,
			crimenet_callouts = {
				"pln_cs1_cnc_01"
			},
			crimenet_videos = {
				"cn_jewel1",
				"cn_jewel2",
				"cn_jewel3"
			},
			payout = {
				55000,
				110000,
				275000,
				550000,
				700000,
				700000,
				700000
			},
			experience_mul = {
				1,
				1,
				1,
				1.2,
				1.2
			},
			contract_cost = {
				24000,
				48000,
				120000,
				240000,
				300000,
				300000,
				300000
			},
			contract_visuals = {}
		}
		self.jobs.roberts.contract_visuals.min_mission_xp = {
			6500,
			6500,
			6500,
			6500,
			6500,
			6500,
			6500
		}
		self.jobs.roberts.contract_visuals.max_mission_xp = {
			22000,
			22000,
			22000,
			22000,
			22000,
			22000,
			22000
		}
	end

	self.stages.kosugi = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "kosugi"
	}
	self.jobs.kosugi = {
		name_id = "heist_kosugi",
		briefing_id = "heist_kosugi_crimenet",
		contact = "bain",
		region = "street",
		jc = 30,
		package = "packages/narr_kosugi",
		chain = {
			self.stages.kosugi
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_shadow_raid",
		briefing_event = "pln_ko1_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"pln_ko1_cnc_01"
		},
		crimenet_videos = {
			"cn_branchbank1",
			"cn_branchbank2",
			"cn_branchbank3"
		},
		contract_cost = {
			0,
			0,
			0,
			100000,
			130000,
			130000,
			130000
		},
		contract_cost = {
			24000,
			48000,
			120000,
			240000,
			300000,
			300000,
			300000
		},
		payout = {
			10000,
			20000,
			30000,
			40000,
			80000,
			80000,
			80000
		},
		experience_mul = {
			1,
			1,
			1,
			1.5,
			1.8
		},
		contract_visuals = {}
	}
	self.jobs.kosugi.contract_visuals.min_mission_xp = {
		5500,
		5500,
		5500,
		5500,
		5500,
		5500,
		5500
	}
	self.jobs.kosugi.contract_visuals.max_mission_xp = {
		22000,
		22000,
		22000,
		22000,
		22000,
		22000,
		22000
	}
	self.stages.mia_1 = {
		type = "d",
		type_id = "heist_type_assault",
		dlc = "hl_miami",
		level_id = "mia_1"
	}
	self.stages.mia_2 = {
		type = "d",
		type_id = "heist_type_assault",
		dlc = "hl_miami",
		level_id = "mia_2"
	}
	self.jobs.mia = {
		name_id = "heist_mia",
		briefing_id = "heist_mia_crimenet",
		contact = "the_dentist",
		region = "street",
		jc = 60,
		package = "packages/narr_mia",
		chain = {
			self.stages.mia_1,
			self.stages.mia_2
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_hlm_01",
		briefing_event = "dentist_hm1_cnc_01",
		debrief_event = "dentist_hm1_debrief_01_01",
		crimenet_callouts = {
			"dentist_hm1_cnc_01"
		},
		crimenet_videos = {
			"cn_hlm1",
			"cn_hlm2",
			"cn_hlm3",
			"cn_big1",
			"cn_big2",
			"cn_big3"
		},
		dlc = "hl_miami",
		payout = {
			37000,
			43000,
			60000,
			70000,
			80000,
			80000,
			80000
		},
		contract_cost = {
			62000,
			124000,
			310000,
			620000,
			800000,
			800000,
			800000
		},
		experience_mul = {
			1.4,
			1.4,
			1.4,
			1.4,
			1.4
		},
		contract_visuals = {}
	}
	self.jobs.mia.contract_visuals.min_mission_xp = {
		40000,
		40000,
		40000,
		40000,
		40000,
		40000,
		40000
	}
	self.jobs.mia.contract_visuals.max_mission_xp = {
		69000,
		69000,
		69000,
		69000,
		69000,
		69000,
		69000
	}
	self.stages.gallery = {
		type = "e",
		dlc = "pd2_clan",
		level_id = "gallery",
		type_id = "heist_type_knockover",
		mission_filter = {
			2
		}
	}
	self.jobs.gallery = {
		name_id = "heist_gallery",
		briefing_id = "heist_gallery_crimenet",
		package = "packages/job_big",
		contact = "bain",
		region = "street",
		jc = 20,
		chain = {
			self.stages.gallery
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_gallery",
		briefing_event = "pln_art_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"pln_art_cnc_01"
		},
		crimenet_videos = {
			"cn_branchbank1",
			"cn_branchbank2",
			"cn_branchbank3"
		},
		payout = {
			6000,
			12500,
			40000,
			60000,
			80000,
			80000,
			80000
		},
		contract_cost = {
			16000,
			32000,
			80000,
			160000,
			200000,
			200000,
			200000
		},
		dlc = "pd2_clan",
		contract_visuals = {}
	}
	self.jobs.gallery.contract_visuals.min_mission_xp = {
		5000,
		5000,
		5000,
		5000,
		5000,
		5000,
		5000
	}
	self.jobs.gallery.contract_visuals.max_mission_xp = {
		12000,
		12000,
		12000,
		12000,
		12000,
		12000,
		12000
	}
	self.stages.hox_1 = {
		type = "d",
		type_id = "heist_type_assault",
		dlc = "pd2_clan",
		level_id = "hox_1"
	}
	self.stages.hox_2 = {
		type = "d",
		type_id = "heist_type_assault",
		dlc = "pd2_clan",
		level_id = "hox_2"
	}
	self.jobs.hox = {
		name_id = "heist_hox",
		briefing_id = "heist_hox_crimenet",
		contact = "the_dentist",
		region = "street",
		jc = 60,
		chain = {
			self.stages.hox_1,
			self.stages.hox_2
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_breakout_01",
		briefing_event = "dentist_hb1_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"dentist_hb1_cnc_01"
		},
		crimenet_videos = {
			"cn_hox1",
			"cn_hox2",
			"cn_hox3",
			"cn_hox4",
			"cn_big1",
			"cn_big2",
			"cn_big3"
		},
		payout = {
			250000,
			500000,
			1250000,
			2500000,
			3200000,
			3200000,
			3200000
		},
		dlc = "pd2_clan",
		experience_mul = {
			2.14,
			2.14,
			2.14,
			2.14,
			2.14
		},
		contract_cost = {
			62000,
			124000,
			310000,
			620000,
			800000,
			800000,
			800000
		},
		contract_visuals = {}
	}
	self.jobs.hox.contract_visuals.min_mission_xp = {
		48800,
		48800,
		48800,
		48800,
		48800,
		48800,
		48800
	}
	self.jobs.hox.contract_visuals.max_mission_xp = {
		53400,
		53400,
		53400,
		53400,
		53400,
		53400,
		53400
	}
	self.stages.pines = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "pines"
	}
	self.jobs.pines = {
		name_id = "heist_pines",
		briefing_id = "heist_pines_crimenet",
		package = "packages/job_pines",
		contact = "vlad",
		region = "street",
		jc = 40,
		chain = {
			self.stages.pines
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_whitexmas",
		briefing_event = "vld_cp1_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"vld_cp1_cnc_01"
		},
		crimenet_videos = {
			"cn_ukr1",
			"cn_ukr2",
			"cn_ukr3"
		},
		payout = {
			8000,
			16000,
			40000,
			80000,
			100000,
			100000,
			100000
		},
		experience_mul = {
			1,
			1,
			1,
			1,
			1
		},
		contract_cost = {
			24000,
			48000,
			120000,
			240000,
			300000,
			300000,
			300000
		},
		contract_visuals = {}
	}
	self.jobs.pines.contract_visuals.min_mission_xp = {
		8000,
		8000,
		8000,
		8000,
		8000,
		8000,
		8000
	}
	self.jobs.pines.contract_visuals.max_mission_xp = {
		2408000,
		2408000,
		2408000,
		2408000,
		2408000,
		2408000,
		2408000
	}
	self.jobs.pines.is_christmas_heist = true
	self.stages.mus = {
		type = "d",
		type_id = "heist_type_assault",
		dlc = "hope_diamond",
		level_id = "mus"
	}
	self.jobs.mus = {
		name_id = "heist_mus",
		briefing_id = "heist_mus_crimenet",
		package = "packages/job_mus",
		contact = "the_dentist",
		region = "street",
		jc = 50,
		chain = {
			self.stages.mus
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_diamond",
		briefing_event = "dentist_hd1_cbf_01",
		debrief_event = {
			"dentist_hd1_debrief_01",
			"dentist_hd1_debrief_02"
		},
		crimenet_callouts = {
			"dentist_hd1_cnc_01_01"
		},
		crimenet_videos = {
			"cn_hox1",
			"cn_hox2",
			"cn_hox3",
			"cn_hox4",
			"cn_big1",
			"cn_big2",
			"cn_big3"
		},
		payout = {
			8000,
			16000,
			40000,
			80000,
			100000,
			100000,
			100000
		},
		dlc = "hope_diamond",
		contract_cost = {
			62000,
			124000,
			310000,
			620000,
			800000,
			800000,
			800000
		},
		contract_visuals = {}
	}
	self.jobs.mus.contract_visuals.min_mission_xp = {
		17000,
		17000,
		17000,
		17000,
		17000,
		17000,
		17000
	}
	self.jobs.mus.contract_visuals.max_mission_xp = {
		36000,
		36000,
		36000,
		36000,
		36000,
		36000,
		36000
	}
	self.stages.cage = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "cage"
	}
	self.jobs.cage = {
		name_id = "heist_cage",
		briefing_id = "heist_cage_crimenet",
		package = "packages/narr_cage",
		contact = "bain",
		region = "street",
		jc = 30,
		chain = {
			self.stages.cage
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_carshop",
		briefing_event = "pln_ch1_cbf_01",
		debrief_event = "pln_ch1_end_01",
		crimenet_callouts = {
			"pln_ch1_cnc_01_01"
		},
		crimenet_videos = {
			"cn_jewel1",
			"cn_jewel2",
			"cn_jewel3"
		},
		payout = {
			20000,
			30000,
			40000,
			70000,
			80000,
			80000,
			80000
		},
		contract_cost = {
			16000,
			32000,
			80000,
			160000,
			200000,
			200000,
			200000
		},
		contract_visuals = {}
	}
	self.jobs.cage.contract_visuals.min_mission_xp = {
		10000,
		10000,
		10000,
		10000,
		10000,
		10000,
		10000
	}
	self.jobs.cage.contract_visuals.max_mission_xp = {
		13000,
		13000,
		13000,
		13000,
		13000,
		13000,
		13000
	}
	self.stages.hox_3 = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "hox_3"
	}
	self.jobs.hox_3 = {
		name_id = "heist_hox_3",
		briefing_id = "heist_hox_3_crimenet",
		package = "packages/job_hox",
		contact = "the_dentist",
		region = "street",
		jc = 40,
		chain = {
			self.stages.hox_3
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_hoxtonrevenge",
		briefing_event = "hoxton_hb3_cbf_01",
		debrief_event = "hoxton_hb3_debrief_01",
		crimenet_callouts = {
			"hoxton_hb3_cnc_01_01"
		},
		crimenet_videos = {
			"cn_hox1",
			"cn_hox2",
			"cn_hox3",
			"cn_hox4",
			"cn_big1",
			"cn_big2",
			"cn_big3"
		},
		payout = {
			8000,
			16000,
			40000,
			80000,
			100000,
			100000,
			100000
		},
		contract_cost = {
			62000,
			124000,
			310000,
			620000,
			800000,
			800000,
			800000
		},
		contract_visuals = {}
	}
	self.jobs.hox_3.contract_visuals.min_mission_xp = {
		20000,
		20000,
		20000,
		20000,
		20000,
		20000,
		20000
	}
	self.jobs.hox_3.contract_visuals.max_mission_xp = {
		26000,
		26000,
		26000,
		26000,
		26000,
		26000,
		26000
	}
	self.stages.crojob1 = {
		type = "d",
		dlc = "the_bomb",
		level_id = "crojob2",
		type_id = "heist_type_assault",
		mission_filter = {
			1
		}
	}
	self.jobs.crojob1 = {
		name_id = "heist_crojob1",
		briefing_id = "heist_crojob1_crimenet",
		package = "packages/job_crojob",
		contact = "the_butcher",
		jc = 60,
		chain = {
			self.stages.crojob1
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_bomb_dockyard",
		briefing_event = "butcher_cr1_cbf_02",
		debrief_event = {
			"butcher_cr1_debrief_01",
			"butcher_cr1_debrief_02"
		},
		crimenet_callouts = {
			"butcher_cr1_cnc_01"
		},
		crimenet_videos = {
			"cn_cro1",
			"cn_cro2",
			"cn_cro3"
		},
		payout = {
			8000,
			16000,
			40000,
			80000,
			100000,
			100000,
			100000
		},
		contract_cost = {
			62000,
			124000,
			310000,
			620000,
			800000,
			800000,
			800000
		},
		experience_mul = {
			1.1,
			1.1,
			1.1,
			1.1,
			1.1
		},
		dlc = "the_bomb",
		contract_visuals = {}
	}
	self.jobs.crojob1.contract_visuals.min_mission_xp = {
		18000,
		18000,
		18000,
		18000,
		18000,
		18000,
		18000
	}
	self.jobs.crojob1.contract_visuals.max_mission_xp = {
		33500,
		33500,
		33500,
		33500,
		33500,
		33500,
		33500
	}
	self.jobs.crojob_wrapper = {
		name_id = "heist_crojob2",
		briefing_id = "heist_crojob2_crimenet",
		contact = "the_butcher",
		jc = 60,
		chain = {
			{}
		},
		job_wrapper = {
			"crojob2",
			"crojob2_night"
		},
		wrapper_weights = {
			9,
			1
		},
		briefing_event = "butcher_cr1_cbf_03",
		debrief_event = "butcher_cr1_debrief_03",
		crimenet_callouts = {
			"butcher_cr1_cnc_01"
		},
		crimenet_videos = {
			"cn_cro1",
			"cn_cro1",
			"cn_cro1"
		},
		payout = {
			8000,
			16000,
			40000,
			80000,
			100000,
			100000,
			100000
		},
		experience_mul = {
			1.4,
			1.4,
			1.4,
			1.4,
			1.4
		},
		contract_cost = {
			62000,
			124000,
			310000,
			620000,
			800000,
			800000,
			800000
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_bomb_forest",
		contract_visuals = {}
	}
	self.jobs.crojob_wrapper.contract_visuals.min_mission_xp = {
		34000,
		34000,
		34000,
		34000,
		34000,
		34000,
		34000
	}
	self.jobs.crojob_wrapper.contract_visuals.max_mission_xp = {
		41500,
		41500,
		41500,
		41500,
		41500,
		41500,
		41500
	}
	self.jobs.crojob_wrapper.dlc = "the_bomb"
	self.stages.crojob2_d = {
		type = "d",
		world_setting = "day",
		dlc = "the_bomb",
		level_id = "crojob3",
		type_id = "heist_type_survive"
	}
	self.stages.crojob2_n = {
		type = "d",
		world_setting = "night",
		dlc = "the_bomb",
		level_id = "crojob3_night",
		type_id = "heist_type_survive"
	}
	self.jobs.crojob2 = {
		package = "packages/job_crojob",
		chain = {
			self.stages.crojob2_d
		}
	}
	self.jobs.crojob2_night = deep_clone(self.jobs.crojob2)
	self.jobs.crojob2_night.chain = {
		self.stages.crojob2_n
	}
	self.stages.shoutout_raid = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "shoutout_raid"
	}
	self.jobs.shoutout_raid = {
		name_id = "heist_shoutout_raid",
		briefing_id = "heist_shoutout_raid_crimenet",
		package = "packages/narr_shoutout",
		contact = "vlad",
		region = "street",
		jc = 30,
		chain = {
			self.stages.shoutout_raid
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_meltdown",
		briefing_event = "vld_ko1b_cbf_01_01",
		debrief_event = nil,
		crimenet_callouts = {
			"vld_ko1b_cnc_01_01"
		},
		crimenet_videos = {
			"cn_ukr1",
			"cn_ukr2",
			"cn_ukr3"
		},
		payout = {
			26000,
			37000,
			81000,
			101000,
			202000,
			202000,
			202000
		},
		contract_cost = {
			62000,
			124000,
			310000,
			620000,
			800000,
			800000,
			800000
		},
		contract_visuals = {}
	}
	self.jobs.shoutout_raid.contract_visuals.min_mission_xp = {
		20000,
		20000,
		20000,
		20000,
		20000,
		20000,
		20000
	}
	self.jobs.shoutout_raid.contract_visuals.max_mission_xp = {
		34000,
		34000,
		34000,
		34000,
		34000,
		34000,
		34000
	}
	self.stages.arena = {
		type = "d",
		type_id = "heist_type_assault",
		dlc = "arena",
		level_id = "arena"
	}
	self.jobs.arena = {
		name_id = "heist_arena",
		briefing_id = "heist_arena_crimenet",
		contact = "bain",
		region = "street",
		jc = 60,
		chain = {
			self.stages.arena
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_alesso",
		briefing_event = "pln_al1_cbf_01_01",
		debrief_event = nil,
		crimenet_callouts = {
			"pln_al1_cnc_01_01"
		},
		crimenet_videos = {
			"cn_branchbank1",
			"cn_branchbank2",
			"cn_branchbank3"
		},
		payout = {
			93000,
			186000,
			465000,
			930000,
			1209000,
			1209000,
			1209000
		},
		contract_cost = {
			62000,
			124000,
			310000,
			620000,
			800000,
			800000,
			800000
		},
		dlc = "arena",
		contract_visuals = {}
	}
	self.jobs.arena.contract_visuals.min_mission_xp = {
		19500,
		19500,
		19500,
		19500,
		19500,
		19500,
		19500
	}
	self.jobs.arena.contract_visuals.max_mission_xp = {
		51600,
		51600,
		51600,
		51600,
		51600,
		51600,
		51600
	}
	self.stages.kenaz = {
		type = "e",
		dlc = "kenaz",
		level_id = "kenaz",
		type_id = "heist_type_assault",
		mission_filter = {
			1
		}
	}
	self.jobs.kenaz = {
		name_id = "heist_kenaz_full",
		briefing_id = "heist_kenaz_crimenet",
		package = "packages/job_kenaz",
		contact = "the_dentist",
		jc = 70,
		chain = {
			self.stages.kenaz
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_casino",
		briefing_event = "dentist_ca1_cbf_01",
		debrief_event = {
			"dentist_ca1_debrief_01",
			"dentist_ca1_debrief_02"
		},
		intro_event = {
			"Play_pln_ca1_intro_01",
			"Play_pln_ca1_intro_02"
		},
		crimenet_callouts = {
			"dentist_ca1_cnc_01_01"
		},
		crimenet_videos = {
			"cn_big1",
			"cn_big1",
			"cn_big1"
		},
		payout = {
			10000,
			20000,
			50000,
			100000,
			130000,
			130000,
			130000
		},
		contract_cost = {
			62000,
			124000,
			310000,
			620000,
			800000,
			800000,
			800000
		},
		dlc = "kenaz",
		contract_visuals = {}
	}
	self.jobs.kenaz.contract_visuals.min_mission_xp = {
		39250,
		39250,
		39250,
		39250,
		39250,
		39250,
		39250
	}
	self.jobs.kenaz.contract_visuals.max_mission_xp = {
		67500,
		67500,
		67500,
		67500,
		67500,
		67500,
		67500
	}
	self.stages.jolly = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "jolly"
	}
	self.jobs.jolly = {
		name_id = "heist_jolly",
		briefing_id = "heist_jolly_crimenet",
		package = "packages/jolly",
		contact = "vlad",
		region = "street",
		jc = 30,
		chain = {
			self.stages.jolly
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_aftershock",
		contract_visuals = {}
	}
	self.jobs.jolly.contract_visuals.min_mission_xp = {
		30000,
		30000,
		30000,
		30000,
		30000,
		30000,
		30000
	}
	self.jobs.jolly.contract_visuals.max_mission_xp = {
		34000,
		34000,
		34000,
		34000,
		34000,
		34000,
		34000
	}
	self.jobs.jolly.briefing_event = "vld_as1_cbf_01"
	self.jobs.jolly.debrief_event = "vld_as1_17"
	self.jobs.jolly.crimenet_callouts = {
		"vld_as1_cnc_01"
	}
	self.jobs.jolly.crimenet_videos = {
		"cn_ukr1",
		"cn_ukr2",
		"cn_ukr3"
	}
	self.jobs.jolly.payout = {
		124000,
		248000,
		620000,
		1150000,
		1600000,
		1600000,
		1600000
	}
	self.jobs.jolly.contract_cost = {
		105000,
		150000,
		550000,
		1050000,
		1400000,
		1400000,
		1400000
	}
	self.stages.red2 = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "red2"
	}
	self.jobs.red2 = {
		name_id = "heist_red2",
		briefing_id = "heist_red2_crimenet",
		package = "packages/narr_red2",
		contact = "classic",
		region = "street",
		jc = 60,
		chain = {
			self.stages.red2
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_fwb",
		briefing_event = "pln_fwb_cbf_01",
		debrief_event = "pln_fwb_34",
		crimenet_callouts = {
			"pln_fwb_cnc_01",
			"pln_fwb_cnc_01",
			"pln_fwb_cnc_01"
		},
		crimenet_videos = {
			"cn_branchbank1",
			"cn_branchbank2",
			"cn_branchbank3"
		},
		payout = {
			100000,
			200000,
			500000,
			1000000,
			1300000,
			1300000,
			1300000
		},
		contract_cost = {
			80000,
			150000,
			400000,
			850000,
			1000000,
			1000000,
			1000000
		},
		contract_visuals = {}
	}
	self.jobs.red2.contract_visuals.min_mission_xp = {
		17500,
		17500,
		17500,
		17500,
		17500,
		17500,
		17500
	}
	self.jobs.red2.contract_visuals.max_mission_xp = {
		34000,
		34000,
		34000,
		34000,
		34000,
		34000,
		34000
	}
	self.stages.dinner = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "dinner"
	}
	self.jobs.dinner = {
		name_id = "heist_dinner",
		briefing_id = "heist_dinner_crimenet",
		package = "packages/narr_dinner",
		contact = "classic",
		region = "street",
		jc = 30,
		chain = {
			self.stages.dinner
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_slaughterhouse",
		briefing_event = "pln_dn1_cbf_01",
		debrief_event = "pln_dn1_31",
		crimenet_callouts = {
			"pln_dn1_cnc_01"
		},
		crimenet_videos = {
			"cn_branchbank1",
			"cn_branchbank2",
			"cn_branchbank3"
		},
		payout = {
			120000,
			240000,
			600000,
			1100000,
			1500000,
			1500000,
			1500000
		},
		contract_cost = {
			80000,
			150000,
			400000,
			850000,
			1000000,
			1000000,
			1000000
		},
		contract_visuals = {}
	}
	self.jobs.dinner.contract_visuals.min_mission_xp = {
		34000,
		34000,
		34000,
		34000,
		34000,
		34000,
		34000
	}
	self.jobs.dinner.contract_visuals.max_mission_xp = {
		40000,
		40000,
		40000,
		40000,
		40000,
		40000,
		40000
	}
	self.stages.pbr = {
		type = "d",
		type_id = "heist_type_assault",
		dlc = "berry",
		level_id = "pbr"
	}
	self.jobs.pbr = {
		name_id = "heist_pbr",
		briefing_id = "heist_pbr_crimenet",
		package = "packages/narr_jerry1",
		contact = "locke",
		region = "street",
		dlc = "berry",
		jc = 30,
		chain = {
			self.stages.pbr
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_beneath_the_mountain",
		briefing_event = "loc_jr1_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"loc_jr1_cnc_01"
		},
		crimenet_videos = {
			"codex/locke1"
		},
		payout = {
			60000,
			74000,
			125000,
			185000,
			260000,
			260000,
			260000
		},
		contract_cost = {
			31000,
			62000,
			155000,
			310000,
			400000,
			400000,
			400000
		},
		contract_visuals = {}
	}
	self.jobs.pbr.contract_visuals.min_mission_xp = {
		22400,
		22400,
		22400,
		22400,
		22400,
		22400,
		22400
	}
	self.jobs.pbr.contract_visuals.max_mission_xp = {
		32000,
		32000,
		32000,
		32000,
		32000,
		32000,
		32000
	}
	self.stages.pbr2 = {
		type = "d",
		type_id = "heist_type_assault",
		dlc = "berry",
		level_id = "pbr2"
	}
	self.jobs.pbr2 = {
		name_id = "heist_pbr2",
		briefing_id = "heist_pbr2_crimenet",
		package = "packages/narr_jerry2",
		contact = "locke",
		region = "street",
		dlc = "berry",
		jc = 30,
		chain = {
			self.stages.pbr2
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_birth_of_sky",
		briefing_event = "loc_jr2_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"loc_jr2_cnc_01"
		},
		crimenet_videos = {
			"codex/locke1"
		},
		payout = {
			115000,
			230000,
			575000,
			1150000,
			1500000,
			1500000,
			1500000
		},
		contract_cost = {
			31000,
			62000,
			155000,
			310000,
			400000,
			400000,
			400000
		},
		contract_visuals = {}
	}
	self.jobs.pbr2.contract_visuals.min_mission_xp = {
		31100,
		31100,
		31100,
		31100,
		31100,
		31100,
		31100
	}
	self.jobs.pbr2.contract_visuals.max_mission_xp = {
		31100,
		31100,
		31100,
		31100,
		31100,
		31100,
		31100
	}
	self.stages.pal = {
		type = "d",
		type_id = "heist_type_assault",
		dlc = "pal",
		level_id = "pal"
	}
	self.jobs.pal = {
		name_id = "heist_pal",
		briefing_id = "heist_pal_crimenet",
		package = "packages/job_pal",
		contact = "classic",
		region = "street",
		dlc = "pal",
		jc = 30,
		chain = {
			self.stages.pal
		}
	}
	self.jobs.branchbank.contract_visuals.preview_image = {
		icon = "branchbank"
	}
	self.jobs.pal.load_screen = "guis/dlcs/pic/textures/loading/job_counterfeit"
	self.jobs.pal.briefing_event = "pln_pal_cbf_01"
	self.jobs.pal.debrief_event = nil
	self.jobs.pal.crimenet_callouts = {
		"pln_pal_cnc_01"
	}
	self.jobs.pal.crimenet_videos = {
		"cn_branchbank1",
		"cn_branchbank2",
		"cn_branchbank3"
	}
	self.jobs.pal.payout = {
		115000,
		230000,
		575000,
		1150000,
		1500000,
		1500000,
		1500000
	}
	self.jobs.pal.contract_cost = {
		31000,
		62000,
		155000,
		310000,
		400000,
		400000,
		400000
	}
	self.jobs.pal.contract_visuals = {
		min_mission_xp = {
			21000,
			21000,
			21000,
			21000,
			21000,
			21000,
			21000
		},
		max_mission_xp = {
			3621000,
			3621000,
			3621000,
			3621000,
			3621000,
			3621000,
			3621000
		}
	}
	self.stages.cane = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "cane"
	}
	self.jobs.cane = {
		name_id = "heist_cane",
		briefing_id = "heist_cane_crimenet",
		package = "packages/cane",
		contact = "vlad",
		region = "street",
		jc = 10,
		chain = {
			self.stages.cane
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_santasworkshop",
		briefing_event = "vld_can_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"vld_can_cnc_01"
		},
		crimenet_videos = {
			"cn_ukr1",
			"cn_ukr2",
			"cn_ukr3"
		},
		contract_cost = {
			24000,
			48000,
			120000,
			240000,
			300000,
			300000,
			300000
		},
		payout = {
			10000,
			20000,
			30000,
			40000,
			80000,
			80000,
			80000
		},
		is_christmas_heist = true,
		contract_visuals = {}
	}
	self.jobs.cane.contract_visuals.min_mission_xp = {
		10900,
		10900,
		10900,
		10900,
		10900,
		10900,
		10900
	}
	self.jobs.cane.contract_visuals.max_mission_xp = {
		6218000,
		6218000,
		6218000,
		6218000,
		6218000,
		6218000,
		6218000
	}
	self.stages.nail = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "nail"
	}
	self.jobs.nail = {
		name_id = "heist_nail",
		briefing_id = "heist_nail_crimenet",
		package = "packages/job_nail",
		contact = "events",
		region = "street",
		jc = 30,
		chain = {
			self.stages.nail
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_labrats",
		briefing_event = "pln_nai_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"pln_nai_cnc_01"
		},
		crimenet_videos = {
			"cn_jewel1",
			"cn_jewel2",
			"cn_jewel3"
		},
		payout = {
			6000,
			12000,
			30000,
			50000,
			60000,
			60000,
			60000
		},
		contract_cost = {
			4000,
			8000,
			20000,
			40000,
			100000,
			100000,
			100000
		},
		is_halloween_level = true,
		contract_visuals = {}
	}
	self.jobs.nail.contract_visuals.min_mission_xp = {
		20000,
		20000,
		20000,
		20000,
		20000,
		20000,
		20000
	}
	self.jobs.nail.contract_visuals.max_mission_xp = {
		3785000,
		3785000,
		3785000,
		3785000,
		3785000,
		3785000,
		3785000
	}
	self.stages.peta_1 = {
		type = "d",
		type_id = "heist_type_assault",
		dlc = "peta",
		level_id = "peta"
	}
	self.stages.peta_2 = {
		type = "d",
		type_id = "heist_type_assault",
		dlc = "peta",
		level_id = "peta2"
	}
	self.jobs.peta = {
		name_id = "heist_peta",
		briefing_id = "heist_peta_crimenet",
		package = "packages/job_peta",
		contact = "vlad",
		region = "street",
		dlc = "peta",
		jc = 30,
		chain = {
			self.stages.peta_1,
			self.stages.peta_2
		},
		briefing_event = "vld_pt1_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"vld_pt1_cnc_01",
			"vld_pt1_cnc_01",
			"vld_pt1_cnc_01"
		},
		crimenet_videos = {
			"cn_ukr1",
			"cn_ukr2",
			"cn_ukr3"
		},
		contract_cost = {
			62000,
			124000,
			310000,
			620000,
			800000,
			800000,
			800000
		},
		payout = {
			250000,
			500000,
			1250000,
			2500000,
			3200000,
			3200000,
			3200000
		},
		contract_visuals = {}
	}
	self.jobs.peta.contract_visuals.min_mission_xp = {
		38000,
		38000,
		38000,
		38000,
		38000,
		38000,
		38000
	}
	self.jobs.peta.contract_visuals.max_mission_xp = {
		122000,
		122000,
		122000,
		122000,
		122000,
		122000,
		122000
	}
	self.stages.man = {
		type = "d",
		type_id = "heist_type_assault",
		dlc = "pal",
		level_id = "man"
	}
	self.jobs.man = {
		name_id = "heist_man",
		briefing_id = "heist_man_crimenet",
		contact = "classic",
		region = "street",
		dlc = "pal",
		jc = 30,
		chain = {
			self.stages.man
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_undercover",
		briefing_event = "pln_man_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"pln_man_cnc_01"
		},
		crimenet_videos = {
			"cn_branchbank1",
			"cn_branchbank2",
			"cn_branchbank3"
		},
		contract_cost = {
			62000,
			124000,
			310000,
			620000,
			800000,
			800000,
			800000
		},
		payout = {
			135000,
			275000,
			692307,
			1350000,
			1800000,
			1800000,
			1800000
		},
		contract_visuals = {}
	}
	self.jobs.man.contract_visuals.min_mission_xp = {
		27500,
		27500,
		27500,
		27500,
		27500,
		27500,
		27500
	}
	self.jobs.man.contract_visuals.max_mission_xp = {
		28500,
		28500,
		28500,
		28500,
		28500,
		28500,
		28500
	}
	self.stages.dark = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "dark"
	}
	self.jobs.dark = {
		name_id = "heist_dark",
		briefing_id = "heist_dark_crimenet",
		contact = "jimmy",
		region = "street",
		jc = 30,
		chain = {
			self.stages.dark
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_murkystation",
		briefing_event = "rb14_drk_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"rb14_drk_cnc_01"
		},
		crimenet_videos = {
			"cn_dark"
		},
		contract_cost = {
			24000,
			48000,
			120000,
			240000,
			300000,
			300000,
			300000
		},
		payout = {
			10000,
			20000,
			30000,
			40000,
			80000,
			80000,
			80000
		},
		contract_visuals = {}
	}
	self.jobs.dark.contract_visuals.min_mission_xp = {
		14000,
		14000,
		14000,
		14000,
		14000,
		14000,
		14000
	}
	self.jobs.dark.contract_visuals.max_mission_xp = {
		32000,
		32000,
		32000,
		32000,
		32000,
		32000,
		32000
	}
	self.stages.mad = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "mad"
	}
	self.jobs.mad = {
		name_id = "heist_mad",
		briefing_id = "heist_mad_crimenet",
		contact = "jimmy",
		region = "street",
		jc = 30,
		chain = {
			self.stages.mad
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_boilingpoint",
		briefing_event = "rb14_mad_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"rb14_mad_cnc_01"
		},
		crimenet_videos = {
			"cn_mad"
		},
		contract_cost = {
			62000,
			124000,
			310000,
			620000,
			800000,
			800000,
			800000
		},
		payout = {
			135000,
			275000,
			692307,
			1350000,
			1800000,
			1800000,
			1800000
		},
		contract_visuals = {}
	}
	self.jobs.mad.contract_visuals.min_mission_xp = {
		31000,
		31000,
		31000,
		31000,
		31000,
		31000,
		31000
	}
	self.jobs.mad.contract_visuals.max_mission_xp = {
		46000,
		46000,
		46000,
		46000,
		46000,
		46000,
		46000
	}
	self.stages.born = {
		type = "d",
		type_id = "heist_type_assault",
		dlc = "born",
		level_id = "born"
	}
	self.stages.chew = {
		type = "d",
		type_id = "heist_type_assault",
		dlc = "born",
		level_id = "chew"
	}
	self.jobs.born = {
		name_id = "heist_born",
		briefing_id = "heist_born_crimenet",
		contact = "the_elephant",
		region = "street",
		jc = 30,
		dlc = "born",
		chain = {
			self.stages.born,
			self.stages.chew
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_born",
		briefing_event = "elp_brn_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"elp_brn_cnc_01"
		},
		crimenet_videos = {
			"cn_elcday1",
			"cn_elcday2",
			"cn_elcday3"
		},
		payout = {
			26000,
			37000,
			81000,
			101000,
			202000,
			202000,
			202000
		},
		contract_cost = {
			62000,
			124000,
			310000,
			620000,
			800000,
			800000,
			800000
		},
		payout = {
			135000,
			275000,
			692307,
			1350000,
			1800000,
			1800000,
			1800000
		},
		contract_visuals = {}
	}
	self.jobs.born.contract_visuals.min_mission_xp = {
		10000,
		10000,
		10000,
		10000,
		10000,
		10000,
		10000
	}
	self.jobs.born.contract_visuals.max_mission_xp = {
		14000,
		14000,
		14000,
		14000,
		14000,
		14000,
		14000
	}
	self.stages.short_1_1 = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "short1_stage1"
	}
	self.stages.short_1_2 = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "short1_stage2"
	}
	self.stages.short_2_1 = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "short2_stage1"
	}
	self.stages.short_2_2 = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "short2_stage2b"
	}
	self.jobs.short = {
		name_id = "heist_short",
		briefing_id = "heist_short1_stage1_crimenet",
		contact = "bain",
		region = "street",
		jc = 10,
		chain = {
			self.stages.short_1_1,
			self.stages.short_1_2,
			self.stages.short_2_1,
			self.stages.short_2_2
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_branchbank",
		briefing_event = "pln_sh11_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"pln_cs1_cnc_01",
			"pln_cs1_cnc_02",
			"pln_cs1_cnc_03"
		},
		crimenet_videos = {
			"cn_branchbank1",
			"cn_branchbank2",
			"cn_branchbank3"
		},
		payout = {
			52000,
			74000,
			162000,
			202000,
			404000,
			404000,
			404000
		}
	}
	self.jobs.short1 = {
		name_id = "heist_short1",
		briefing_id = "heist_short1_crimenet",
		contact = "bain",
		region = "street",
		jc = 10,
		chain = {
			self.stages.short_1_1,
			self.stages.short_1_2
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_branchbank",
		briefing_event = "pln_sh11_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"pln_cs1_cnc_01",
			"pln_cs1_cnc_02",
			"pln_cs1_cnc_03"
		},
		crimenet_videos = {
			"cn_branchbank1",
			"cn_branchbank2",
			"cn_branchbank3"
		},
		payout = {
			26000,
			37000,
			81000,
			101000,
			202000,
			202000,
			202000
		}
	}
	self.jobs.short2 = {
		name_id = "heist_short2",
		briefing_id = "heist_short2_crimenet",
		contact = "bain",
		region = "street",
		jc = 10,
		chain = {
			self.stages.short_2_1,
			self.stages.short_2_2
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_branchbank",
		briefing_event = "pln_sh21_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"pln_cs1_cnc_01",
			"pln_cs1_cnc_02",
			"pln_cs1_cnc_03"
		},
		crimenet_videos = {
			"cn_branchbank1",
			"cn_branchbank2",
			"cn_branchbank3"
		},
		payout = {
			26000,
			37000,
			81000,
			101000,
			202000,
			202000,
			202000
		}
	}
	self.tutorials = {
		{
			job = "short1"
		},
		{
			job = "short2"
		}
	}
	self.stages.chill = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "chill",
		mission_filter = {
			1
		}
	}
	self.stages.chill_combat = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "chill_combat",
		mission_filter = {
			2
		}
	}
	self.jobs.chill = {
		name_id = "heist_chill",
		briefing_id = "heist_chill_crimenet",
		contact = "hoxton",
		region = "street",
		jc = 30,
		chain = {
			self.stages.chill
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_safehouse_new",
		briefing_event = "pln_sh21_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"pln_cs1_cnc_01",
			"pln_cs1_cnc_02",
			"pln_cs1_cnc_03"
		},
		crimenet_videos = {
			"cn_branchbank1",
			"cn_branchbank2",
			"cn_branchbank3"
		},
		payout = {
			26000,
			37000,
			81000,
			101000,
			202000,
			202000,
			202000
		}
	}
	local chill_combat_marker_dot_color = Color(1, 0, 0)
	local chill_combat_marker_dot_color_to = Color(0.2, 0, 0)
	self.jobs.chill_combat = {
		name_id = "heist_chill_combat",
		briefing_id = "heist_chill_combat_crimenet",
		contact = "hoxton",
		region = "street",
		jc = 30,
		chain = {
			self.stages.chill_combat
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_safehouse_new",
		briefing_event = "pln_sfr_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"pln_sfr_cnc_01_01"
		},
		crimenet_videos = {
			"cn_branchbank1",
			"cn_branchbank2",
			"cn_branchbank3"
		},
		payout = {
			26000,
			37000,
			81000,
			101000,
			180000,
			202000,
			220000
		},
		marker_dot_color = chill_combat_marker_dot_color,
		color_lerp = {
			speed = 10,
			from = chill_combat_marker_dot_color,
			to = chill_combat_marker_dot_color_to
		}
	}
	self.stages.friend = {
		type = "d",
		type_id = "heist_type_assault",
		dlc = "friend",
		level_id = "friend"
	}
	self.jobs.friend = {
		name_id = "heist_friend",
		briefing_id = "heist_friend_crimenet",
		contact = "the_butcher",
		region = "street",
		jc = 30,
		dlc = "friend",
		chain = {
			self.stages.friend
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_mansion",
		briefing_event = "Play_butcher_fri_cbf_01",
		debrief_event = {
			"Play_btc_fri_end_a",
			"Play_btc_fri_end_b"
		},
		crimenet_callouts = {
			"Play_butcher_fri_cnc_01"
		},
		crimenet_videos = {
			"cn_cro1",
			"cn_cro2",
			"cn_cro3"
		},
		payout = {
			180000,
			270000,
			360000,
			620000,
			380000,
			380000,
			380000
		},
		contract_cost = {
			47000,
			94000,
			235000,
			470000,
			600000,
			600000,
			600000
		},
		contract_visuals = {}
	}
	self.jobs.friend.contract_visuals.min_mission_xp = {
		17000,
		17000,
		17000,
		17000,
		17000,
		17000,
		17000
	}
	self.jobs.friend.contract_visuals.max_mission_xp = {
		35000,
		35000,
		35000,
		35000,
		35000,
		35000,
		35000
	}
	self.stages.moon = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "moon"
	}
	self.jobs.moon = {
		name_id = "heist_moon",
		briefing_id = "heist_moon_crimenet",
		contact = "vlad",
		region = "street",
		jc = 30,
		chain = {
			self.stages.moon
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_stealing_xmas",
		briefing_event = "vld_moon_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"vld_moon_cnc_01"
		},
		crimenet_videos = {
			"cn_ukr1",
			"cn_ukr2",
			"cn_ukr3"
		},
		payout = {
			124000,
			248000,
			620000,
			1150000,
			1600000,
			1600000,
			1600000
		},
		contract_cost = {
			105000,
			150000,
			550000,
			1050000,
			1400000,
			1400000,
			1400000
		},
		is_christmas_heist = true,
		contract_visuals = {}
	}
	self.jobs.moon.contract_visuals.min_mission_xp = {
		8300,
		8300,
		8300,
		8300,
		8300,
		8300,
		8300
	}
	self.jobs.moon.contract_visuals.max_mission_xp = {
		17800,
		17800,
		17800,
		17800,
		17800,
		17800,
		17800
	}
	self.stages.spa = {
		type = "d",
		type_id = "heist_type_assault",
		dlc = "spa",
		level_id = "spa"
	}
	self.jobs.spa = {
		name_id = "heist_spa",
		briefing_id = "heist_spa_crimenet",
		briefing_dialog = "Play_pln_bb1_brf_01",
		contact = "the_continental",
		dlc = "spa",
		region = "street",
		jc = 30,
		chain = {
			self.stages.spa
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_brooklyn1010",
		briefing_event = "pln_spa_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"pln_spa_cnc_01"
		},
		crimenet_videos = {
			"contact_continental1"
		},
		package = "packages/job_spa",
		cube = "cube_apply_heist_bank",
		ghost_bonus = 0.15,
		max_bags = 28,
		payout = {
			124000,
			248000,
			620000,
			1150000,
			1600000,
			1600000,
			1600000
		},
		contract_cost = {
			105000,
			150000,
			550000,
			1050000,
			1400000,
			1400000,
			1400000
		},
		contract_visuals = {}
	}
	self.jobs.spa.contract_visuals.min_mission_xp = {
		26000,
		26000,
		26000,
		26000,
		26000,
		26000,
		26000
	}
	self.jobs.spa.contract_visuals.max_mission_xp = {
		30000,
		30000,
		30000,
		30000,
		30000,
		30000,
		30000
	}
	self.stages.fish = {
		type = "d",
		type_id = "heist_type_assault",
		dlc = "spa",
		level_id = "fish"
	}
	self.jobs.fish = {
		name_id = "heist_fish",
		briefing_id = "heist_fish_crimenet",
		contact = "the_continental",
		dlc = "spa",
		region = "street",
		jc = 30,
		chain = {
			self.stages.fish
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_yachtheist",
		briefing_event = "cha_fish_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"cha_fish_cnc_01"
		},
		crimenet_videos = {
			"contact_continental1"
		},
		payout = {
			70000,
			95000,
			125000,
			200000,
			250000,
			250000,
			250000
		},
		contract_cost = {
			39000,
			78000,
			195000,
			390000,
			500000,
			500000,
			500000
		},
		contract_visuals = {}
	}
	self.jobs.fish.contract_visuals.min_mission_xp = {
		12000,
		12000,
		12000,
		12000,
		12000,
		12000,
		12000
	}
	self.jobs.fish.contract_visuals.max_mission_xp = {
		15000,
		15000,
		15000,
		15000,
		15000,
		15000,
		15000
	}
	self.stages.flat = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "flat"
	}
	self.jobs.flat = {
		name_id = "heist_flat",
		briefing_id = "heist_flat_crimenet",
		contact = "classic",
		region = "street",
		jc = 30,
		chain = {
			self.stages.flat
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_panicroom",
		briefing_event = "pln_flt_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"pln_flt_cnc_01"
		},
		crimenet_videos = {
			"cn_branchbank1",
			"cn_branchbank2",
			"cn_branchbank3"
		},
		payout = {
			118000,
			236000,
			826000,
			1180000,
			1357000,
			1534000,
			1652000
		},
		contract_cost = {
			70000,
			150000,
			350307,
			700000,
			900000,
			900000,
			900000
		},
		contract_visuals = {}
	}
	self.jobs.flat.contract_visuals.min_mission_xp = {
		12000,
		25000,
		25000,
		25000,
		25000,
		25000,
		25000
	}
	self.jobs.flat.contract_visuals.max_mission_xp = {
		30500,
		30500,
		30500,
		30500,
		30500,
		30500,
		30500
	}
	self.stages.help = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "help"
	}
	self.jobs.help = {
		name_id = "heist_help",
		briefing_id = "heist_help_crimenet",
		contact = "events",
		region = "street",
		jc = 30,
		chain = {
			self.stages.help
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_prisonnightmare",
		briefing_event = "pln_hlp_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"pln_hlp_cnc_01_01"
		},
		crimenet_videos = {
			"cn_branchbank1",
			"cn_branchbank2",
			"cn_branchbank3"
		},
		payout = {
			6000,
			12000,
			30000,
			50000,
			60000,
			60000,
			60000
		},
		contract_cost = {
			70000,
			150000,
			350307,
			700000,
			900000,
			900000,
			900000
		},
		objective_stinger = "hlp_stinger_objectivecomplete",
		is_halloween_level = true,
		contract_visuals = {}
	}
	self.jobs.help.contract_visuals.min_mission_xp = {
		14000,
		14000,
		14000,
		14000,
		14000,
		14000,
		14000
	}
	self.jobs.help.contract_visuals.max_mission_xp = {
		8507150,
		8507150,
		8507150,
		8507150,
		8507150,
		8507150,
		8507150
	}
	self.stages.run = {
		type = "d",
		type_id = "heist_type_survive",
		level_id = "run"
	}
	self.jobs.run = {
		name_id = "heist_run",
		briefing_id = "heist_run_crimenet",
		package = "packages/narr_run",
		contact = "classic",
		region = "street",
		jc = 50,
		chain = {
			self.stages.run
		},
		briefing_event = "Play_loc_run_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"Play_loc_run_cnc_01"
		},
		crimenet_videos = {
			"codex/locke1"
		},
		payout = {
			110000,
			220000,
			550000,
			1100000,
			1265000,
			1430000,
			1540000
		},
		contract_cost = {
			70000,
			150000,
			350307,
			700000,
			900000,
			900000,
			900000
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_heatstreet",
		contract_visuals = {}
	}
	self.jobs.run.contract_visuals.min_mission_xp = {
		26000,
		26000,
		26000,
		26000,
		26000,
		26000,
		26000
	}
	self.jobs.run.contract_visuals.max_mission_xp = {
		26000,
		26000,
		26000,
		26000,
		260000,
		26000,
		26000
	}
	self.stages.glace = {
		type = "d",
		type_id = "heist_type_survive",
		level_id = "glace"
	}
	self.jobs.glace = {
		name_id = "heist_glace",
		briefing_id = "heist_glace_crimenet",
		package = "packages/job_rats",
		contact = "classic",
		jc = 50,
		chain = {
			self.stages.glace
		},
		load_screen = "guis/dlcs/pic/textures/loading/job_greenbridge",
		briefing_event = "Play_pln_glc_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"Play_pln_glc_cnc_01"
		},
		crimenet_videos = {
			"cn_branchbank1",
			"cn_branchbank2",
			"cn_branchbank3"
		},
		payout = {
			115000,
			225000,
			555000,
			1150000,
			1266000,
			1435000,
			1545000
		},
		contract_cost = {
			70000,
			150000,
			350307,
			700000,
			900000,
			900000,
			900000
		},
		contract_visuals = {}
	}
	self.jobs.glace.contract_visuals.min_mission_xp = {
		24000,
		24000,
		24000,
		24000,
		24000,
		24000,
		24000
	}
	self.jobs.glace.contract_visuals.max_mission_xp = {
		28000,
		28000,
		28000,
		28000,
		28000,
		28000,
		28000
	}
	self.stages.haunted = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "haunted"
	}
	self.jobs.haunted = {
		name_id = "heist_haunted",
		briefing_id = "heist_haunted_crimenet",
		contact = "events",
		region = "street",
		jc = 10,
		chain = {
			self.stages.haunted
		},
		load_screen = "guis/dlcs/pic/textures/loading/old_safehouse_halloween_df",
		briefing_event = nil,
		debrief_event = nil,
		crimenet_videos = {
			"cn_branchbank1",
			"cn_branchbank2",
			"cn_branchbank3"
		},
		payout = {
			20000,
			30000,
			40000,
			70000,
			80000,
			90000,
			100000
		},
		contract_cost = {
			16000,
			32000,
			80000,
			160000,
			200000,
			240000,
			280000
		},
		is_halloween_level = true,
		contract_visuals = {}
	}
	self.jobs.haunted.contract_visuals.min_mission_xp = {
		10000,
		10000,
		10000,
		10000,
		10000,
		10000,
		10000
	}
	self.jobs.haunted.contract_visuals.max_mission_xp = {
		10000,
		10000,
		10000,
		10000,
		10000,
		10000,
		10000
	}
	self.stages.dah = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "dah"
	}
	self.jobs.dah = {
		name_id = "heist_dah",
		briefing_id = "heist_dah_crimenet",
		contact = "classic",
		region = "street",
		jc = 30,
		chain = {
			self.stages.dah
		},
		briefing_event = "Play_pln_dah_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"Play_pln_dah_cnc_01"
		},
		crimenet_videos = {
			"cn_branchbank1"
		},
		payout = {
			50000,
			125000,
			250000,
			550000,
			700000,
			700000,
			700000
		},
		contract_cost = {
			24000,
			48000,
			120000,
			240000,
			300000,
			300000,
			300000
		},
		contract_visuals = {}
	}
	self.jobs.dah.contract_visuals.min_mission_xp = {
		14200,
		14200,
		14200,
		14200,
		14200,
		14200,
		14200
	}
	self.jobs.dah.contract_visuals.max_mission_xp = {
		23200,
		23200,
		23200,
		23200,
		23200,
		23200,
		23200
	}
	self.jobs.dah.contract_visuals.preview_image = {
		id = "dah"
	}
	self.jobs.dah.date_added = {
		2017,
		10,
		27
	}
	self.stages.rvd_1 = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "rvd1"
	}
	self.stages.rvd_2 = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "rvd2"
	}
	self.jobs.rvd = {
		name_id = "heist_rvd",
		briefing_id = "heist_rvd_crimenet",
		package = "packages/narr_rvd",
		contact = "bain",
		region = "street",
		jc = 60,
		chain = {
			self.stages.rvd_1,
			self.stages.rvd_2
		},
		briefing_event = "Play_pln_rvd_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"Play_pln_rvd_cnc_01"
		},
		crimenet_videos = {
			"cn_branchbank1",
			"cn_branchbank3"
		},
		payout = {
			20000,
			30000,
			40000,
			70000,
			80000,
			80000,
			80000
		},
		contract_cost = {
			16000,
			32000,
			80000,
			160000,
			200000,
			200000,
			200000
		},
		contract_visuals = {}
	}
	self.jobs.rvd.contract_visuals.min_mission_xp = {
		29500,
		29500,
		29500,
		29500,
		29500,
		29500,
		29500
	}
	self.jobs.rvd.contract_visuals.max_mission_xp = {
		47500,
		47500,
		47500,
		47500,
		47500,
		47500,
		47500
	}
	self.jobs.rvd.contract_visuals.preview_image = {
		id = "rvd",
		folder = "rvd"
	}
	self.jobs.rvd.date_added = {
		2017,
		12,
		14
	}
	self.stages.brb = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "brb"
	}
	self.jobs.brb = {
		name_id = "heist_brb",
		briefing_id = "heist_brb_crimenet",
		contact = "locke",
		region = "street",
		jc = 10,
		chain = {
			self.stages.brb
		},
		briefing_event = "Play_loc_brb_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"Play_loc_brb_cnc_01"
		},
		crimenet_videos = {
			"codex/locke1"
		},
		payout = {
			8000,
			16000,
			40000,
			80000,
			100000,
			100000,
			100000
		},
		contract_cost = {
			62000,
			124000,
			310000,
			620000,
			800000,
			800000,
			800000
		},
		contract_visuals = {}
	}
	self.jobs.brb.contract_visuals.min_mission_xp = {
		16400,
		16400,
		16400,
		16400,
		16400,
		16400,
		16400
	}
	self.jobs.brb.contract_visuals.max_mission_xp = {
		25600,
		25600,
		25600,
		25600,
		25600,
		25600,
		25600
	}
	self.jobs.brb.contract_visuals.preview_image = {
		id = "brb",
		folder = "brb"
	}
	self.jobs.brb.date_added = {
		2017,
		12,
		21
	}
	self.jobs.crime_spree = {
		name_id = "heist_crime_spree",
		briefing_id = "heist_crime_spree_brief",
		contact = "hoxton",
		region = "street",
		jc = 0,
		chain = {},
		briefing_event = nil,
		debrief_event = nil,
		crimenet_callouts = {},
		crimenet_videos = {
			"cn_branchbank1"
		},
		payout = {
			0,
			0,
			0,
			0,
			0,
			0,
			0
		},
		experience_mul = {
			0,
			0,
			0,
			0,
			0,
			0,
			0
		},
		contract_cost = {
			0,
			0,
			0,
			0,
			0,
			0,
			0
		},
		contract_visuals = {}
	}
	self.jobs.crime_spree.contract_visuals.min_mission_xp = {
		0,
		0,
		0,
		0,
		0,
		0,
		0
	}
	self.jobs.crime_spree.contract_visuals.max_mission_xp = {
		0,
		0,
		0,
		0,
		0,
		0,
		0
	}
	self.jobs.crime_spree.ignore_heat = true
	self.jobs.crime_spree.hidden = true
	self.stages.hvh = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "hvh"
	}
	self.jobs.hvh = {
		name_id = "heist_hvh",
		briefing_id = "heist_hvh_crimenet",
		package = "packages/narr_hvh",
		contact = "events",
		region = "street",
		jc = 30,
		chain = {
			self.stages.hvh
		},
		briefing_event = "hvh_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"hvh_cnc_01"
		},
		crimenet_videos = {
			"cn_jewel1",
			"cn_jewel2",
			"cn_jewel3"
		},
		payout = {
			20000,
			30000,
			40000,
			70000,
			80000,
			80000,
			80000
		},
		contract_cost = {
			16000,
			32000,
			80000,
			160000,
			200000,
			200000,
			200000
		},
		is_halloween_level = true,
		contract_visuals = {}
	}
	self.jobs.hvh.contract_visuals.min_mission_xp = {
		2000,
		2000,
		2000,
		2000,
		2000,
		2000,
		2000
	}
	self.jobs.hvh.contract_visuals.max_mission_xp = {
		60000,
		60000,
		60000,
		60000,
		60000,
		60000,
		60000
	}
	self.jobs.hvh.date_added = {
		2017,
		10,
		31
	}
	self.stages.wwh = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "wwh"
	}
	self.jobs.wwh = {
		name_id = "heist_wwh",
		briefing_id = "heist_wwh_crimenet",
		contact = "locke",
		region = "street",
		jc = 30,
		chain = {
			self.stages.wwh
		},
		briefing_event = "Play_loc_wwh_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"Play_loc_wwh_cnc_01"
		},
		crimenet_videos = {
			"codex/locke1"
		},
		payout = {
			60000,
			150000,
			300000,
			600000,
			750000,
			750000,
			750000
		},
		contract_cost = {
			24000,
			48000,
			120000,
			240000,
			300000,
			300000,
			300000
		},
		contract_visuals = {}
	}
	self.jobs.wwh.contract_visuals.min_mission_xp = {
		14000,
		14000,
		14000,
		14000,
		14000,
		14000,
		14000
	}
	self.jobs.wwh.contract_visuals.max_mission_xp = {
		18000,
		18000,
		18000,
		18000,
		18000,
		18000,
		18000
	}
	self.jobs.wwh.contract_visuals.preview_image = {
		id = "lockeload"
	}
	self.jobs.wwh.load_screen = "guis/dlcs/pic/textures/loading/job_lockeload"
	self.jobs.wwh.date_added = {
		2017,
		10,
		23
	}
	self.jobs.arm_cro.contract_visuals.preview_image = {
		id = "armor_crossroads"
	}
	self.jobs.arm_fac.contract_visuals.preview_image = {
		id = "armor_harbor"
	}
	self.jobs.arm_for.contract_visuals.preview_image = {
		id = "armor_train"
	}
	self.jobs.arm_hcm.contract_visuals.preview_image = {
		id = "armor_downtown"
	}
	self.jobs.arm_par.contract_visuals.preview_image = {
		id = "armor_park"
	}
	self.jobs.arm_und.contract_visuals.preview_image = {
		id = "armor_underpass"
	}
	self.jobs.gallery.contract_visuals.preview_image = {
		id = "gallery"
	}
	self.jobs.cage.contract_visuals.preview_image = {
		id = "carshop"
	}
	self.jobs.branchbank_cash.contract_visuals.preview_image = {
		id = "branchbank"
	}
	self.jobs.branchbank_gold_prof.contract_visuals.preview_image = {
		id = "branchbank"
	}
	self.jobs.branchbank_prof.contract_visuals.preview_image = {
		id = "branchbank"
	}
	self.jobs.branchbank_deposit.contract_visuals.preview_image = {
		id = "branchbank"
	}
	self.jobs.rat.contract_visuals.preview_image = {
		id = "cook_off"
	}
	self.jobs.family.contract_visuals.preview_image = {
		id = "diamondstore"
	}
	self.jobs.arena.contract_visuals.preview_image = {
		id = "arena"
	}
	self.jobs.roberts.contract_visuals.preview_image = {
		id = "go_bank"
	}
	self.jobs.jewelry_store.contract_visuals.preview_image = {
		id = "jewelrystore"
	}
	self.jobs.kosugi.contract_visuals.preview_image = {
		id = "shadowraid"
	}
	self.jobs.pbr.contract_visuals.preview_image = {
		id = "beneath_the_mountain"
	}
	self.jobs.pbr2.contract_visuals.preview_image = {
		id = "birth_of_sky"
	}
	self.jobs.dark.contract_visuals.preview_image = {
		id = "murkystation"
	}
	self.jobs.mad.contract_visuals.preview_image = {
		id = "boilingpoint"
	}
	self.jobs.firestarter.contract_visuals.preview_image = {
		id = "firestarter_01"
	}
	self.jobs.alex.contract_visuals.preview_image = {
		id = "rats_01"
	}
	self.jobs.watchdogs_wrapper.contract_visuals.preview_image = {
		id = "watchdogs_01"
	}
	self.jobs.friend.contract_visuals.preview_image = {
		id = "mansion"
	}
	self.jobs.crojob1.contract_visuals.preview_image = {
		id = "bomb_dockyard"
	}
	self.jobs.crojob_wrapper.contract_visuals.preview_image = {
		id = "bomb_forest"
	}
	self.jobs.spa.contract_visuals.preview_image = {
		id = "brooklyn"
	}
	self.jobs.fish.contract_visuals.preview_image = {
		id = "yacht"
	}
	self.jobs.kenaz.contract_visuals.preview_image = {
		id = "casino"
	}
	self.jobs.mia.contract_visuals.preview_image = {
		id = "hotline_miami_01"
	}
	self.jobs.hox.contract_visuals.preview_image = {
		id = "hoxton_breakout_01"
	}
	self.jobs.hox_3.contract_visuals.preview_image = {
		id = "hoxton_revenge"
	}
	self.jobs.big.contract_visuals.preview_image = {
		id = "bigbank"
	}
	self.jobs.mus.contract_visuals.preview_image = {
		id = "museum"
	}
	self.jobs.born.contract_visuals.preview_image = {
		id = "biker_01"
	}
	self.jobs.welcome_to_the_jungle_wrapper_prof.contract_visuals.preview_image = {
		id = "bigoil_01"
	}
	self.jobs.election_day.contract_visuals.preview_image = {
		id = "electionday_02"
	}
	self.jobs.framing_frame.contract_visuals.preview_image = {
		id = "gallery"
	}
	self.jobs.jolly.contract_visuals.preview_image = {
		id = "aftershock"
	}
	self.jobs.cane.contract_visuals.preview_image = {
		id = "santas_workshop"
	}
	self.jobs.moon.contract_visuals.preview_image = {
		id = "stealing_xmas"
	}
	self.jobs.ukrainian_job_prof.contract_visuals.preview_image = {
		id = "jewelrystore"
	}
	self.jobs.pines.contract_visuals.preview_image = {
		id = "white_xmas"
	}
	self.jobs.peta.contract_visuals.preview_image = {
		id = "goatsim_01"
	}
	self.jobs.four_stores.contract_visuals.preview_image = {
		id = "fourstores"
	}
	self.jobs.mallcrasher.contract_visuals.preview_image = {
		id = "mallcrasher"
	}
	self.jobs.nightclub.contract_visuals.preview_image = {
		id = "nightclub"
	}
	self.jobs.shoutout_raid.contract_visuals.preview_image = {
		id = "meltdown"
	}
	self.jobs.nail.contract_visuals.preview_image = {
		id = "labrats"
	}
	self.jobs.help.contract_visuals.preview_image = {
		id = "prison_nightmare"
	}
	self.jobs.hvh.contract_visuals.preview_image = {
		id = "halloween2017"
	}
	self.jobs.red2.contract_visuals.preview_image = {
		id = "fwb"
	}
	self.jobs.glace.contract_visuals.preview_image = {
		id = "green_bridge"
	}
	self.jobs.run.contract_visuals.preview_image = {
		id = "heat_street"
	}
	self.jobs.flat.contract_visuals.preview_image = {
		id = "panicroom"
	}
	self.jobs.dinner.contract_visuals.preview_image = {
		id = "slaughterhouse"
	}
	self.jobs.pal.contract_visuals.preview_image = {
		id = "counterfeit"
	}
	self.jobs.man.contract_visuals.preview_image = {
		id = "undercover"
	}
	self.jobs.haunted.contract_visuals = {
		preview_image = {
			id = "safehouse_old"
		}
	}
	self.stages.tag = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "tag"
	}
	self.jobs.tag = {
		name_id = "heist_tag",
		briefing_id = "heist_tag_crimenet",
		contact = "locke",
		region = "street",
		jc = 30,
		chain = {
			self.stages.tag
		},
		briefing_event = "Play_loc_tag_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"Play_loc_tag_cnc_01"
		},
		crimenet_videos = {
			"codex/locke1"
		},
		payout = {
			20000,
			30000,
			40000,
			70000,
			80000,
			80000,
			80000
		},
		contract_cost = {
			16000,
			32000,
			80000,
			160000,
			200000,
			200000,
			200000
		},
		contract_visuals = {}
	}
	self.jobs.tag.contract_visuals.min_mission_xp = {
		11000,
		11000,
		11000,
		11000,
		11000,
		11000,
		11000
	}
	self.jobs.tag.contract_visuals.max_mission_xp = {
		23000,
		23000,
		23000,
		23000,
		23000,
		23000,
		23000
	}
	self.jobs.tag.contract_visuals.preview_image = {
		id = "tag",
		folder = "tag"
	}
	self.jobs.tag.date_added = {
		2018,
		4,
		23
	}
	self.stages.des = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "des"
	}
	self.jobs.des = {
		name_id = "heist_des",
		briefing_id = "heist_des_crimenet",
		contact = "locke",
		region = "street",
		jc = 30,
		chain = {
			self.stages.des
		},
		briefing_event = "Play_rb22_des_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"Play_loc_des_cnc_01"
		},
		crimenet_videos = {
			"codex/locke1"
		},
		payout = {
			50000,
			125000,
			250000,
			550000,
			700000,
			700000,
			700000
		},
		contract_cost = {
			24000,
			48000,
			120000,
			240000,
			300000,
			300000,
			300000
		},
		contract_visuals = {}
	}
	self.jobs.des.contract_visuals.min_mission_xp = {
		14200,
		14200,
		14200,
		14200,
		14200,
		14200,
		14200
	}
	self.jobs.des.contract_visuals.max_mission_xp = {
		23200,
		23200,
		23200,
		23200,
		23200,
		23200,
		23200
	}
	self.jobs.des.contract_visuals.preview_image = {
		id = "des",
		folder = "des"
	}
	self.jobs.des.date_added = {
		2018,
		4,
		29
	}
	self.stages.vit = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "vit"
	}
	self.jobs.vit = {
		name_id = "heist_vit",
		briefing_id = "heist_vit_crimenet",
		contact = "locke",
		region = "street",
		jc = 30,
		chain = {
			self.stages.vit
		},
		briefing_event = "Play_pln_vit_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"Play_loc_vit_cnc_01"
		},
		crimenet_videos = {
			"codex/locke1"
		},
		payout = {
			50000,
			125000,
			250000,
			550000,
			700000,
			700000,
			700000
		},
		contract_cost = {
			24000,
			48000,
			120000,
			240000,
			300000,
			300000,
			300000
		},
		contract_visuals = {}
	}
	self.jobs.vit.contract_visuals.min_mission_xp = {
		14200,
		14200,
		14200,
		14200,
		14200,
		14200,
		14200
	}
	self.jobs.vit.contract_visuals.max_mission_xp = {
		23200,
		23200,
		23200,
		23200,
		23200,
		23200,
		23200
	}
	self.jobs.vit.contract_visuals.preview_image = {
		id = "vit",
		folder = "vit"
	}
	self.jobs.vit.date_added = {
		2018,
		11,
		1
	}
	self.stages.bph = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "bph"
	}
	self.jobs.bph = {
		name_id = "heist_bph",
		briefing_id = "heist_bph_crimenet",
		contact = "locke",
		region = "street",
		jc = 30,
		chain = {
			self.stages.bph
		},
		briefing_event = "Play_loc_bph_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"Play_loc_bph_cnc_01"
		},
		crimenet_videos = {
			"codex/locke1"
		},
		payout = {
			60000,
			150000,
			300000,
			600000,
			750000,
			750000,
			750000
		},
		contract_cost = {
			24000,
			48000,
			120000,
			240000,
			300000,
			300000,
			300000
		},
		contract_visuals = {}
	}
	self.jobs.bph.contract_visuals.min_mission_xp = {
		14200,
		14200,
		14200,
		14200,
		14200,
		14200,
		14200
	}
	self.jobs.bph.contract_visuals.max_mission_xp = {
		23200,
		23200,
		23200,
		23200,
		23200,
		23200,
		23200
	}
	self.jobs.bph.contract_visuals.preview_image = {
		id = "bph",
		folder = "bph"
	}
	self.jobs.bph.date_added = {
		2018,
		10,
		26
	}
	self.stages.mex = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "mex",
		mission_filter = {
			1
		}
	}
	self.stages.mex_cooking = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "mex_cooking",
		mission_filter = {
			2
		}
	}
	self.jobs.mex = {
		name_id = "heist_mex",
		briefing_id = "heist_mex_crimenet",
		contact = "locke",
		region = "street",
		jc = 30,
		dlc = "mex",
		chain = {
			self.stages.mex
		},
		briefing_event = "Play_loc_mex_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"Play_loc_mex_cnc_01"
		},
		crimenet_videos = {
			"codex/locke1"
		},
		payout = {
			50000,
			125000,
			250000,
			550000,
			700000,
			700000,
			700000
		},
		contract_cost = {
			24000,
			48000,
			120000,
			240000,
			300000,
			300000,
			300000
		},
		contract_visuals = {}
	}
	self.jobs.mex.contract_visuals.min_mission_xp = {
		14200,
		14200,
		14200,
		14200,
		14200,
		14200,
		14200
	}
	self.jobs.mex.contract_visuals.max_mission_xp = {
		23200,
		23200,
		23200,
		23200,
		23200,
		23200,
		23200
	}
	self.jobs.mex.contract_visuals.preview_image = {
		id = "mex",
		folder = "mex"
	}
	self.jobs.mex.date_added = {
		2019,
		11,
		7
	}
	self.jobs.mex_cooking = {
		name_id = "heist_mex_cooking",
		briefing_id = "heist_mex_cooking_crimenet",
		contact = "locke",
		region = "street",
		jc = 30,
		dlc = "mex",
		chain = {
			self.stages.mex_cooking
		},
		briefing_event = "Play_loc_mex_cook_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"Play_loc_mex_cook_cnc_01"
		},
		crimenet_videos = {
			"codex/locke1"
		},
		payout = {
			50000,
			125000,
			250000,
			550000,
			700000,
			700000,
			700000
		},
		contract_cost = {
			24000,
			48000,
			120000,
			240000,
			300000,
			300000,
			300000
		},
		contract_visuals = {}
	}
	self.jobs.mex_cooking.contract_visuals.min_mission_xp = {
		14200,
		14200,
		14200,
		14200,
		14200,
		14200,
		14200
	}
	self.jobs.mex_cooking.contract_visuals.max_mission_xp = {
		23200,
		23200,
		23200,
		23200,
		23200,
		23200,
		23200
	}
	self.jobs.mex_cooking.contract_visuals.preview_image = {
		id = "mex_cooking",
		folder = "mex"
	}
	self.jobs.mex_cooking.date_added = {
		2019,
		11,
		7
	}
	self.stages.lbe_lobby_end = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "lbe_lobby_end",
		mission_filter = {
			2
		}
	}
	self.jobs.lbe_lobby_end = {
		name_id = "heist_lbe_lobby_end",
		briefing_id = "heist_lbe_lobby_end_crimenet",
		package = "packages/load_default",
		contact = "wip",
		region = "street",
		jc = 30,
		chain = {
			self.stages.lbe_lobby_end
		},
		briefing_event = "pln_branchbank_cash_brf_speak",
		debrief_event = nil,
		crimenet_callouts = {
			"pln_branchbank_cash_cnc_01"
		},
		crimenet_videos = {
			"cn_branchbank1",
			"cn_branchbank2",
			"cn_branchbank3"
		},
		payout = {
			10000,
			15000,
			40000,
			60000,
			75000,
			75000,
			75000
		},
		contract_cost = {
			16000,
			32000,
			80000,
			160000,
			200000,
			200000,
			200000
		},
		contract_visuals = {}
	}
	self.jobs.lbe_lobby_end.contract_visuals.min_mission_xp = {
		12000,
		12000,
		12000,
		12000,
		12000,
		12000,
		12000
	}
	self.jobs.lbe_lobby_end.contract_visuals.max_mission_xp = {
		12000,
		12000,
		12000,
		12000,
		12000,
		12000,
		12000
	}
	self.stages.lbe_lobby = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "lbe_lobby",
		mission_filter = {
			1
		}
	}
	self.jobs.lbe_lobby = {
		name_id = "heist_lbe_lobby",
		briefing_id = "heist_lbe_lobby_crimenet",
		package = "packages/load_default",
		contact = "wip",
		region = "street",
		jc = 30,
		chain = {
			self.stages.lbe_lobby,
			self.stages.bbv,
			self.stages.lbe_lobby_end
		},
		briefing_event = "pln_branchbank_cash_brf_speak",
		debrief_event = nil,
		crimenet_callouts = {
			"pln_branchbank_cash_cnc_01"
		},
		crimenet_videos = {
			"cn_branchbank1",
			"cn_branchbank2",
			"cn_branchbank3"
		},
		payout = {
			10000,
			15000,
			40000,
			60000,
			75000,
			75000,
			75000
		},
		contract_cost = {
			16000,
			32000,
			80000,
			160000,
			200000,
			200000,
			200000
		},
		contract_visuals = {}
	}
	self.jobs.lbe_lobby.contract_visuals.min_mission_xp = {
		12000,
		12000,
		12000,
		12000,
		12000,
		12000,
		12000
	}
	self.jobs.lbe_lobby.contract_visuals.max_mission_xp = {
		12000,
		12000,
		12000,
		12000,
		12000,
		12000,
		12000
	}
	self.stages.nmh = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "nmh"
	}
	self.jobs.nmh = {
		name_id = "heist_nmh",
		briefing_id = "heist_nmh_crimenet",
		contact = "classic",
		region = "street",
		jc = 30,
		chain = {
			self.stages.nmh
		},
		briefing_event = "Play_rb1_nmh_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"Play_pln_nmh_cnc_01"
		},
		crimenet_videos = {
			"cn_branchbank1",
			"cn_branchbank3"
		},
		payout = {
			60000,
			74000,
			125000,
			185000,
			260000,
			260000,
			260000
		},
		contract_cost = {
			31000,
			62000,
			155000,
			310000,
			400000,
			400000,
			400000
		},
		contract_visuals = {}
	}
	self.jobs.nmh.contract_visuals.min_mission_xp = {
		22400,
		22400,
		22400,
		22400,
		22400,
		22400,
		22400
	}
	self.jobs.nmh.contract_visuals.max_mission_xp = {
		32000,
		32000,
		32000,
		32000,
		32000,
		32000,
		32000
	}
	self.jobs.nmh.contract_visuals.preview_image = {
		id = "nmh",
		folder = "nmh"
	}
	self.jobs.nmh.date_added = {
		2018,
		10,
		30
	}
	self.stages.sah = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "sah"
	}
	self.jobs.sah = {
		name_id = "heist_sah",
		briefing_id = "heist_sah_crimenet",
		contact = "locke",
		region = "street",
		jc = 30,
		chain = {
			self.stages.sah
		},
		load_screen = "guis/dlcs/sah/textures/loading/job_sah_df",
		briefing_event = "Play_rb22_sah_cbf_01",
		debrief_event = nil,
		crimenet_callouts = {
			"Play_loc_sah_cnc_01"
		},
		crimenet_videos = {
			"codex/locke1"
		},
		payout = {
			100000,
			0,
			0,
			0,
			0,
			0,
			0
		},
		contract_cost = {
			70000,
			150000,
			350307,
			700000,
			900000,
			900000,
			900000
		},
		contract_visuals = {}
	}
	self.jobs.sah.contract_visuals.min_mission_xp = {
		11000,
		11000,
		11000,
		11000,
		11000,
		11000,
		11000
	}
	self.jobs.sah.contract_visuals.max_mission_xp = {
		23000,
		23000,
		23000,
		23000,
		23000,
		23000,
		23000
	}
	self.jobs.sah.contract_visuals.preview_image = {
		id = "sah",
		folder = "sah"
	}
	self.jobs.sah.date_added = {
		2018,
		8,
		15
	}
	local skirmish_payout = {
		0,
		0,
		0,
		0,
		0,
		0,
		0
	}
	local skirmish_exp = {
		max = 135900,
		min = 8000
	}
	self.stages.skm_mus = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "skm_mus"
	}
	self.jobs.skm_mus = {
		name_id = "heist_skm_mus",
		briefing_id = "heist_skm_mus_crimenet",
		contact = "skirmish",
		region = "street",
		jc = 50,
		chain = {
			self.stages.skm_mus
		},
		briefing_event = "dentist_hd1_cbf_01",
		debrief_event = {
			"dentist_hd1_debrief_01",
			"dentist_hd1_debrief_02"
		},
		crimenet_callouts = {
			"Play_loc_tag_cnc_01"
		},
		crimenet_videos = {
			"codex/locke1"
		},
		payout = skirmish_payout,
		contract_cost = {
			16000,
			32000,
			80000,
			160000,
			200000,
			200000,
			200000
		},
		contract_visuals = {}
	}
	self.jobs.skm_mus.contract_visuals.min_mission_xp = skirmish_exp.min
	self.jobs.skm_mus.contract_visuals.max_mission_xp = skirmish_exp.max
	self.jobs.skm_mus.contract_visuals.preview_image = {
		id = "tag",
		folder = "tag"
	}
	self.jobs.skm_mus.contract_visuals.weekly_skirmish_image = "guis/textures/pd2/skirmish/menu_landing_mus"
	self.jobs.skm_mus.date_added = {
		2018,
		4,
		23
	}
	self.stages.skm_red2 = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "skm_red2"
	}
	self.jobs.skm_red2 = {
		name_id = "heist_skm_red2",
		briefing_id = "heist_skm_red2_crimenet",
		contact = "skirmish",
		region = "street",
		jc = 60,
		chain = {
			self.stages.skm_red2
		},
		briefing_event = "pln_fwb_cbf_01",
		debrief_event = "pln_fwb_34",
		crimenet_callouts = {
			"Play_loc_tag_cnc_01"
		},
		crimenet_videos = {
			"codex/locke1"
		},
		payout = skirmish_payout,
		contract_cost = {
			16000,
			32000,
			80000,
			160000,
			200000,
			200000,
			200000
		},
		contract_visuals = {}
	}
	self.jobs.skm_red2.contract_visuals.min_mission_xp = skirmish_exp.min
	self.jobs.skm_red2.contract_visuals.max_mission_xp = skirmish_exp.max
	self.jobs.skm_red2.contract_visuals.preview_image = {
		id = "tag",
		folder = "tag"
	}
	self.jobs.skm_red2.contract_visuals.weekly_skirmish_image = "guis/textures/pd2/skirmish/menu_landing_red2"
	self.jobs.skm_red2.date_added = {
		2018,
		4,
		23
	}
	self.stages.skm_run = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "skm_run"
	}
	self.jobs.skm_run = {
		name_id = "heist_skm_run",
		briefing_id = "heist_skm_run_crimenet",
		contact = "skirmish",
		region = "street",
		jc = 60,
		chain = {
			self.stages.skm_run
		},
		briefing_event = "pln_fwb_cbf_01",
		debrief_event = "pln_fwb_34",
		crimenet_callouts = {
			"Play_loc_tag_cnc_01"
		},
		crimenet_videos = {
			"codex/locke1"
		},
		payout = skirmish_payout,
		contract_cost = {
			16000,
			32000,
			80000,
			160000,
			200000,
			200000,
			200000
		},
		contract_visuals = {}
	}
	self.jobs.skm_run.contract_visuals.min_mission_xp = skirmish_exp.min
	self.jobs.skm_run.contract_visuals.max_mission_xp = skirmish_exp.max
	self.jobs.skm_run.contract_visuals.preview_image = {
		id = "tag",
		folder = "tag"
	}
	self.jobs.skm_run.contract_visuals.weekly_skirmish_image = "guis/textures/pd2/skirmish/menu_landing_run"
	self.jobs.skm_run.date_added = {
		2018,
		4,
		23
	}
	self.stages.skm_watchdogs_stage2 = {
		type = "d",
		type_id = "heist_type_assault",
		level_id = "skm_watchdogs_stage2"
	}
	self.jobs.skm_watchdogs_stage2 = {
		name_id = "heist_skm_watchdogs_stage2",
		briefing_id = "heist_skm_watchdogs_stage2_crimenet",
		contact = "skirmish",
		region = "street",
		jc = 60,
		chain = {
			self.stages.skm_watchdogs_stage2
		},
		briefing_event = "pln_fwb_cbf_01",
		debrief_event = "pln_fwb_34",
		crimenet_callouts = {
			"Play_loc_tag_cnc_01"
		},
		crimenet_videos = {
			"codex/locke1"
		},
		payout = skirmish_payout,
		contract_cost = {
			16000,
			32000,
			80000,
			160000,
			200000,
			200000,
			200000
		},
		contract_visuals = {}
	}
	self.jobs.skm_watchdogs_stage2.contract_visuals.min_mission_xp = skirmish_exp.min
	self.jobs.skm_watchdogs_stage2.contract_visuals.max_mission_xp = skirmish_exp.max
	self.jobs.skm_watchdogs_stage2.contract_visuals.preview_image = {
		id = "tag",
		folder = "tag"
	}
	self.jobs.skm_watchdogs_stage2.contract_visuals.weekly_skirmish_image = "guis/textures/pd2/skirmish/menu_landing_watchdogs"
	self.jobs.skm_watchdogs_stage2.date_added = {
		2018,
		4,
		23
	}
	self._jobs_index = {
		"jewelry_store",
		"four_stores",
		"nightclub",
		"mallcrasher",
		"ukrainian_job_prof",
		"branchbank_deposit",
		"branchbank_cash",
		"branchbank_prof",
		"branchbank_gold_prof",
		"firestarter",
		"alex",
		"watchdogs_wrapper",
		"watchdogs",
		"watchdogs_night",
		"framing_frame",
		"welcome_to_the_jungle_wrapper_prof",
		"welcome_to_the_jungle_prof",
		"welcome_to_the_jungle_night_prof",
		"family",
		"election_day",
		"kosugi",
		"arm_fac",
		"arm_par",
		"arm_hcm",
		"arm_und",
		"arm_cro",
		"arm_for",
		"big",
		"mia",
		"gallery",
		"hox",
		"hox_3",
		"pines",
		"cage",
		"mus",
		"crojob1",
		"crojob_wrapper",
		"crojob2",
		"crojob2_night",
		"rat",
		"shoutout_raid",
		"arena",
		"kenaz",
		"jolly",
		"red2",
		"dinner",
		"nail",
		"cane",
		"pbr",
		"pbr2",
		"peta",
		"pal",
		"man",
		"mad",
		"dark",
		"born",
		"chill",
		"chill_combat",
		"friend",
		"flat",
		"help",
		"haunted",
		"spa",
		"fish",
		"moon",
		"run",
		"glace",
		"dah",
		"rvd",
		"crime_spree",
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
	self.forced_jobs = {
		firestarter = true,
		branchbank_prof = true,
		branchbank_cash = true,
		welcome_to_the_jungle = true,
		ukrainian_job_prof = true,
		arm_par = true,
		branchbank_deposit = true,
		brb = true,
		hox_3 = true,
		hox = true,
		pines = true,
		dinner = true,
		moon = true,
		wwh = true,
		arm_cro = true,
		jewelry_store = true,
		welcome_to_the_jungle_wrapper_prof = true,
		welcome_to_the_jungle_prof = true,
		spa = true,
		kosugi = true,
		arm_fac = true,
		friend = true,
		fish = true,
		run = true,
		election_day = true,
		flat = true,
		man = true,
		help = true,
		branchbank_gold_prof = true,
		family = true,
		nightclub = true,
		mallcrasher = true,
		welcome_to_the_jungle_night = true,
		welcome_to_the_jungle_night_prof = true,
		pal = true,
		rvd = true,
		mad = true,
		four_stores = true,
		arm_for = true,
		watchdogs_wrapper = true,
		arm_und = true,
		dark = true,
		red2 = true,
		arm_hcm = true,
		mia = true,
		welcome_to_the_jungle_wrapper = true,
		gallery = true
	}

	if SystemInfo:distribution() == Idstring("STEAM") then
		table.insert(self._jobs_index, "roberts")
	end

	self:set_job_wrappers()

	local free_dlcs = tweak_data:free_dlc_list()

	for _, data in pairs(self.jobs) do
		if free_dlcs[data.dlc] then
			data.dlc = nil
		end
	end
end

function NarrativeTweakData:set_job_wrappers()
	for _, job_id in ipairs(self._jobs_index) do
		local job_wrapper = self.jobs[job_id].job_wrapper

		if job_wrapper then
			for _, wrapped_job_id in ipairs(job_wrapper) do
				if self.jobs[wrapped_job_id].job_wrapper then
					Application:throw_exception("Can't wrap " .. tostring(wrapped_job_id) .. " into another wrapper.")
				elseif self.jobs[wrapped_job_id].wrapped_to_job then
					Application:throw_exception("The job " .. tostring(wrapped_job_id) .. " is already included in another wrapper (" .. tostring(self.jobs[wrapped_job_id].wrapped_to_job) .. ")")
				else
					self.jobs[wrapped_job_id].wrapped_to_job = job_id
				end
			end
		end
	end
end

function NarrativeTweakData:has_job_wrapper(job_id)
	return self.jobs[job_id] and not not self.jobs[job_id].job_wrapper
end

function NarrativeTweakData:is_wrapped_to_job(job_id)
	return self.jobs[job_id] and not not self.jobs[job_id].wrapped_to_job
end

function NarrativeTweakData:get_jobs_index()
	return self._jobs_index
end

function NarrativeTweakData:get_index_from_job_id(job_id)
	for index, entry_name in ipairs(self._jobs_index) do
		if entry_name == job_id then
			return index
		end
	end

	return 0
end

function NarrativeTweakData:get_job_name_from_index(index)
	return self._jobs_index[index]
end

function NarrativeTweakData:job_data(job_id, unique_to_job)
	if not job_id or not self.jobs[job_id] then
		return
	end

	if unique_to_job then
		return self.jobs[job_id]
	end

	if self.jobs[job_id].wrapped_to_job then
		return self.jobs[self.jobs[job_id].wrapped_to_job]
	end

	return self.jobs[job_id]
end

function NarrativeTweakData:job_chain(job_id)
	if not job_id or not self.jobs[job_id] then
		return {}
	end

	if self.jobs[job_id].job_wrapper then
		return self.jobs[self.jobs[job_id].job_wrapper[1]].chain or {}
	end

	return self.jobs[job_id].chain or {}
end

function NarrativeTweakData:create_job_name(job_id, skip_professional)
	local color_ranges = {}
	local job_tweak = self:job_data(job_id)
	local text_id = managers.localization:to_upper_text(job_tweak.name_id)

	if job_tweak.dlc and (not tweak_data.dlc[job_tweak.dlc] or not tweak_data.dlc[job_tweak.dlc].free) then
		local pro_text = "  "

		if job_tweak.dlc == "pd2_clan" then
			if SystemInfo:distribution() == Idstring("STEAM") then
				pro_text = pro_text .. managers.localization:to_upper_text("cn_menu_community")
			end
		else
			pro_text = pro_text .. managers.localization:to_upper_text("cn_menu_dlc")
		end

		local s_len = utf8.len(text_id)
		text_id = text_id .. pro_text
		local e_len = utf8.len(text_id)

		table.insert(color_ranges, {
			start = s_len,
			stop = e_len,
			color = job_tweak.dlc == "pd2_clan" and tweak_data.screen_colors.community_color or tweak_data.screen_colors.dlc_color
		})
	end

	if not skip_professional and job_tweak.professional then
		local pro_text = "  " .. managers.localization:to_upper_text("cn_menu_pro_job")
		local s_len = utf8.len(text_id)
		text_id = text_id .. pro_text
		local e_len = utf8.len(text_id)

		table.insert(color_ranges, {
			start = s_len,
			stop = e_len,
			color = tweak_data.screen_colors.pro_color
		})
	end

	if job_tweak.competitive then
		local competitive_text = "  " .. managers.localization:to_upper_text("cn_menu_competitive_job")
		local s_len = utf8.len(text_id)
		text_id = text_id .. competitive_text
		local e_len = utf8.len(text_id)

		table.insert(color_ranges, {
			start = s_len,
			stop = e_len,
			color = tweak_data.screen_colors.competitive_color
		})
	end

	return text_id, color_ranges
end

function NarrativeTweakData:test_contract_packages()
	for i, job_id in ipairs(self._jobs_index) do
		local package = self.jobs[job_id] and self.jobs[job_id].package

		if not package or not DB:has(Idstring("package"), package) then
			print("test_contract_packages", "1", job_id)
		end
	end

	for job_id, job in ipairs(self.jobs) do
		if job.package and not DB:has(Idstring("package"), job.package) then
			print("test_contract_packages", "2", job_id)
		end
	end
end

function NarrativeTweakData:is_job_locked(job_id)
	return false
end
