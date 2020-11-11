require("lib/tweak_data/TextureCorrectionTweakData")

HudIconsTweakData = HudIconsTweakData or class()

function HudIconsTweakData:init()
	self.mouse_left_click = {
		texture = "guis/textures/pd2/mouse_buttons",
		texture_rect = {
			1,
			1,
			17,
			23
		}
	}
	self.mouse_right_click = {
		texture = "guis/textures/pd2/mouse_buttons",
		texture_rect = {
			18,
			1,
			17,
			23
		}
	}
	self.mouse_scroll_wheel = {
		texture = "guis/textures/pd2/mouse_buttons",
		texture_rect = {
			35,
			1,
			17,
			23
		}
	}
	self.scroll_up = {
		texture = "guis/textures/scroll_items",
		texture_rect = {
			0,
			0,
			15,
			18
		}
	}
	self.scroll_dn = {
		texture = "guis/textures/scroll_items",
		texture_rect = {
			15,
			0,
			15,
			18
		}
	}
	self.scrollbar_arrow = {
		texture = "guis/textures/pd2/scrollbar_arrows",
		texture_rect = {
			1,
			1,
			9,
			10
		}
	}
	self.scrollbar = {
		texture = "guis/textures/scroll_items",
		texture_rect = {
			30,
			0,
			15,
			32
		}
	}
	self.icon_buy = {
		texture = "guis/textures/scroll_items",
		texture_rect = {
			45,
			16,
			16,
			16
		}
	}
	self.icon_repair = {
		texture = "guis/textures/scroll_items",
		texture_rect = {
			45,
			0,
			16,
			16
		}
	}
	self.icon_addon = {
		texture = "guis/textures/scroll_items",
		texture_rect = {
			45,
			16,
			16,
			16
		}
	}
	self.icon_equipped = {
		texture = "guis/textures/scroll_items",
		texture_rect = {
			45,
			32,
			16,
			16
		}
	}
	self.icon_locked = {
		texture = "guis/textures/scroll_items",
		texture_rect = {
			0,
			16,
			16,
			16
		}
	}
	self.icon_circlebg = {
		texture = "guis/textures/scroll_items",
		texture_rect = {
			45,
			48,
			16,
			16
		}
	}
	self.icon_circlefill0 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			0,
			0,
			1,
			1
		}
	}
	self.icon_circlefill1 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			0,
			0,
			16,
			16
		}
	}
	self.icon_circlefill2 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			16,
			0,
			16,
			16
		}
	}
	self.icon_circlefill3 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			32,
			0,
			16,
			16
		}
	}
	self.icon_circlefill4 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			48,
			0,
			16,
			16
		}
	}
	self.icon_circlefill5 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			0,
			16,
			16,
			16
		}
	}
	self.icon_circlefill6 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			16,
			16,
			16,
			16
		}
	}
	self.icon_circlefill7 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			32,
			16,
			16,
			16
		}
	}
	self.icon_circlefill8 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			48,
			16,
			16,
			16
		}
	}
	self.icon_circlefill9 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			0,
			32,
			16,
			16
		}
	}
	self.icon_circlefill10 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			16,
			32,
			16,
			16
		}
	}
	self.icon_circlefill11 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			32,
			32,
			16,
			16
		}
	}
	self.icon_circlefill12 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			48,
			32,
			16,
			16
		}
	}
	self.icon_circlefill13 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			0,
			48,
			16,
			16
		}
	}
	self.icon_circlefill14 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			16,
			48,
			16,
			16
		}
	}
	self.icon_circlefill15 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			32,
			48,
			16,
			16
		}
	}
	self.icon_circlefill16 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			48,
			48,
			16,
			16
		}
	}
	self.fallback = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			480,
			0,
			32,
			32
		}
	}
	self.develop = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			0,
			192,
			48,
			48
		}
	}
	self.locked = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			192,
			144,
			48,
			48
		}
	}
	self.firemode_single = {
		texture = "guis/textures/pd2/hud_fireselector",
		texture_rect = {
			2,
			0,
			8,
			18
		}
	}
	self.firemode_auto = {
		texture = "guis/textures/pd2/hud_fireselector",
		texture_rect = {
			12,
			0,
			8,
			18
		}
	}
	self.firemode_single_locked = {
		texture = "guis/textures/pd2/hud_fireselector",
		texture_rect = {
			22,
			0,
			8,
			18
		}
	}
	self.firemode_auto_locked = {
		texture = "guis/textures/pd2/hud_fireselector",
		texture_rect = {
			32,
			0,
			8,
			18
		}
	}
	self.loading = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			464,
			96,
			32,
			32
		}
	}
	self.beretta92 = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			0,
			0,
			48,
			48
		}
	}
	self.m4 = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			48,
			0,
			48,
			48
		}
	}
	self.r870_shotgun = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			96,
			0,
			48,
			48
		}
	}
	self.mp5 = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			144,
			0,
			48,
			48
		}
	}
	self.c45 = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			192,
			0,
			48,
			48
		}
	}
	self.raging_bull = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			240,
			0,
			48,
			48
		}
	}
	self.mossberg = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			288,
			0,
			48,
			48
		}
	}
	self.hk21 = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			384,
			0,
			48,
			48
		}
	}
	self.m14 = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			336,
			0,
			48,
			48
		}
	}
	self.mac11 = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			432,
			0,
			48,
			48
		}
	}
	self.glock = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			368,
			288,
			48,
			48
		}
	}
	self.ak = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			416,
			288,
			48,
			48
		}
	}
	self.m79 = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			464,
			288,
			48,
			48
		}
	}
	self.pd2_lootdrop = {
		texture = "guis/textures/pd2/pd2_waypoints",
		texture_rect = {
			0,
			0,
			32,
			32
		}
	}
	self.pd2_escape = {
		texture = "guis/textures/pd2/pd2_waypoints",
		texture_rect = {
			32,
			0,
			32,
			32
		}
	}
	self.pd2_talk = {
		texture = "guis/textures/pd2/pd2_waypoints",
		texture_rect = {
			64,
			0,
			32,
			32
		}
	}
	self.pd2_kill = {
		texture = "guis/textures/pd2/pd2_waypoints",
		texture_rect = {
			96,
			0,
			32,
			32
		}
	}
	self.pd2_drill = {
		texture = "guis/textures/pd2/pd2_waypoints",
		texture_rect = {
			128,
			0,
			32,
			32
		}
	}
	self.pd2_generic_look = {
		texture = "guis/textures/pd2/pd2_waypoints",
		texture_rect = {
			160,
			0,
			32,
			32
		}
	}
	self.pd2_phone = {
		texture = "guis/textures/pd2/pd2_waypoints",
		texture_rect = {
			192,
			0,
			32,
			32
		}
	}
	self.pd2_c4 = {
		texture = "guis/textures/pd2/pd2_waypoints",
		texture_rect = {
			224,
			0,
			32,
			32
		}
	}
	self.pd2_generic_saw = {
		texture = "guis/textures/pd2/pd2_waypoints",
		texture_rect = {
			192,
			64,
			32,
			32
		}
	}
	self.pd2_chainsaw = {
		texture = "guis/textures/pd2/pd2_waypoints",
		texture_rect = {
			224,
			64,
			32,
			32
		}
	}
	self.pd2_power = {
		texture = "guis/textures/pd2/pd2_waypoints",
		texture_rect = {
			0,
			32,
			32,
			32
		}
	}
	self.pd2_door = {
		texture = "guis/textures/pd2/pd2_waypoints",
		texture_rect = {
			32,
			32,
			32,
			32
		}
	}
	self.pd2_computer = {
		texture = "guis/textures/pd2/pd2_waypoints",
		texture_rect = {
			64,
			32,
			32,
			32
		}
	}
	self.pd2_wirecutter = {
		texture = "guis/textures/pd2/pd2_waypoints",
		texture_rect = {
			96,
			32,
			32,
			32
		}
	}
	self.pd2_fire = {
		texture = "guis/textures/pd2/pd2_waypoints",
		texture_rect = {
			128,
			32,
			32,
			32
		}
	}
	self.pd2_loot = {
		texture = "guis/textures/pd2/pd2_waypoints",
		texture_rect = {
			160,
			32,
			32,
			32
		}
	}
	self.pd2_methlab = {
		texture = "guis/textures/pd2/pd2_waypoints",
		texture_rect = {
			192,
			32,
			32,
			32
		}
	}
	self.pd2_generic_interact = {
		texture = "guis/textures/pd2/pd2_waypoints",
		texture_rect = {
			224,
			32,
			32,
			32
		}
	}
	self.pd2_goto = {
		texture = "guis/textures/pd2/pd2_waypoints",
		texture_rect = {
			0,
			64,
			32,
			32
		}
	}
	self.pd2_ladder = {
		texture = "guis/textures/pd2/pd2_waypoints",
		texture_rect = {
			32,
			64,
			32,
			32
		}
	}
	self.pd2_fix = {
		texture = "guis/textures/pd2/pd2_waypoints",
		texture_rect = {
			64,
			64,
			32,
			32
		}
	}
	self.pd2_question = {
		texture = "guis/textures/pd2/pd2_waypoints",
		texture_rect = {
			96,
			64,
			32,
			32
		}
	}
	self.pd2_defend = {
		texture = "guis/textures/pd2/pd2_waypoints",
		texture_rect = {
			160,
			64,
			32,
			32
		}
	}
	self.wp_arrow = {
		texture = "guis/textures/pd2/pd2_waypoints",
		texture_rect = {
			0,
			96,
			32,
			15
		}
	}
	self.pd2_car = {
		texture = "guis/textures/pd2/pd2_waypoints",
		texture_rect = {
			32,
			96,
			32,
			32
		}
	}
	self.pd2_melee = {
		texture = "guis/textures/pd2/pd2_waypoints",
		texture_rect = {
			64,
			96,
			32,
			32
		}
	}
	self.pd2_water_tap = {
		texture = "guis/textures/pd2/pd2_waypoints",
		texture_rect = {
			96,
			96,
			32,
			32
		}
	}
	self.pd2_bodybag = {
		texture = "guis/textures/pd2/pd2_waypoints",
		texture_rect = {
			128,
			96,
			32,
			32
		}
	}
	self.wp_vial = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			240,
			310,
			32,
			32
		}
	}
	self.wp_standard = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			432,
			64,
			32,
			32
		}
	}
	self.wp_revive = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			464,
			64,
			32,
			32
		}
	}
	self.wp_rescue = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			464,
			96,
			32,
			32
		}
	}
	self.wp_trade = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			432,
			96,
			32,
			32
		}
	}
	self.wp_powersupply = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			70,
			242,
			32,
			32
		}
	}
	self.wp_watersupply = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			104,
			242,
			32,
			32
		}
	}
	self.wp_drill = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			2,
			242,
			32,
			32
		}
	}
	self.wp_hack = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			2,
			276,
			32,
			32
		}
	}
	self.wp_talk = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			36,
			276,
			32,
			32
		}
	}
	self.wp_c4 = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			36,
			242,
			32,
			32
		}
	}
	self.wp_crowbar = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			70,
			276,
			32,
			32
		}
	}
	self.wp_planks = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			104,
			276,
			32,
			32
		}
	}
	self.wp_door = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			2,
			310,
			32,
			32
		}
	}
	self.wp_saw = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			36,
			310,
			32,
			32
		}
	}
	self.wp_bag = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			70,
			310,
			32,
			32
		}
	}
	self.wp_exit = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			104,
			310,
			32,
			32
		}
	}
	self.wp_can = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			2,
			344,
			32,
			32
		}
	}
	self.wp_target = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			36,
			344,
			32,
			32
		}
	}
	self.wp_key = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			70,
			344,
			32,
			32
		}
	}
	self.wp_winch = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			104,
			344,
			32,
			32
		}
	}
	self.wp_escort = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			138,
			344,
			32,
			32
		}
	}
	self.wp_powerbutton = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			172,
			344,
			32,
			32
		}
	}
	self.wp_server = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			206,
			344,
			32,
			32
		},
		texture_rect = {
			206,
			344,
			32,
			32
		}
	}
	self.wp_powercord = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			240,
			344,
			32,
			32
		}
	}
	self.wp_phone = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			480,
			144,
			32,
			32
		}
	}
	self.wp_scrubs = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			480,
			177,
			32,
			32
		}
	}
	self.wp_sentry = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			480,
			210,
			32,
			32
		}
	}
	self.wp_suspicious = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			480,
			243,
			32,
			32
		}
	}
	self.wp_detected = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			479,
			433,
			32,
			32
		}
	}
	self.wp_calling_in = {
		texture = "guis/textures/pd2/hud_stealth_alarm01",
		texture_rect = {
			0,
			0,
			64,
			32
		}
	}
	self.wp_calling_in_hazard = {
		texture = "guis/textures/pd2/hud_stealth_alarm02",
		texture_rect = {
			0,
			0,
			64,
			32
		}
	}
	self.equipment_trip_mine = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			0,
			96,
			48,
			48
		}
	}
	self.equipment_ammo_bag = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			48,
			96,
			48,
			48
		}
	}
	self.equipment_doctor_bag = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			96,
			96,
			48,
			48
		}
	}
	self.equipment_ecm_jammer = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			272,
			288,
			48,
			48
		}
	}
	self.equipment_money_bag = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			144,
			96,
			48,
			48
		}
	}
	self.equipment_bank_manager_key = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			288,
			144,
			48,
			48
		}
	}
	self.equipment_chavez_key = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			192,
			96,
			48,
			48
		}
	}
	self.equipment_drill = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			240,
			96,
			48,
			48
		}
	}
	self.equipment_ejection_seat = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			384,
			144,
			48,
			48
		}
	}
	self.equipment_saw = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			336,
			144,
			48,
			48
		}
	}
	self.equipment_cutter = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			384,
			192,
			48,
			48
		}
	}
	self.equipment_hack_ipad = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			432,
			192,
			48,
			48
		}
	}
	self.equipment_gold = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			384,
			240,
			48,
			48
		}
	}
	self.equipment_thermite = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			288,
			96,
			48,
			48
		}
	}
	self.equipment_c4 = {
		texture = "guis/textures/pd2/pickups",
		texture_rect = {
			336,
			96,
			48,
			48
		}
	}
	self.equipment_cable_ties = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			384,
			96,
			48,
			48
		}
	}
	self.equipment_bleed_out = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			96,
			144,
			48,
			48
		}
	}
	self.equipment_planks = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			144,
			288,
			48,
			48
		}
	}
	self.equipment_sentry = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			320,
			288,
			48,
			48
		}
	}
	self.equipment_stash_server = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			96,
			224,
			32,
			32
		}
	}
	self.equipment_vialOK = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			336,
			48,
			48,
			48
		}
	}
	self.equipment_vial = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			416,
			336,
			48,
			48
		}
	}
	self.equipment_ticket = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			64,
			96,
			32,
			32
		}
	}
	self.equipment_files = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			96,
			96,
			32,
			32
		}
	}
	self.equipment_harddrive = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			0,
			128,
			32,
			32
		}
	}
	self.equipment_evidence = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			32,
			128,
			32,
			32
		}
	}
	self.equipment_chainsaw = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			96,
			128,
			32,
			32
		}
	}
	self.equipment_manifest = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			0,
			160,
			32,
			32
		}
	}
	self.equipment_fire_extinguisher = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			32,
			160,
			32,
			32
		}
	}
	self.equipment_winch_hook = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			64,
			160,
			32,
			32
		}
	}
	self.equipment_bottle = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			96,
			160,
			32,
			32
		}
	}
	self.equipment_sleeping_gas = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			0,
			192,
			32,
			32
		}
	}
	self.equipment_usb_with_data = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			32,
			192,
			32,
			32
		}
	}
	self.equipment_usb_no_data = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			64,
			192,
			32,
			32
		}
	}
	self.equipment_empty_cooling_bottle = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			0,
			160,
			32,
			32
		}
	}
	self.equipment_cooling_bottle = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			0,
			128,
			32,
			32
		}
	}
	self.equipment_bfd_tool = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			0,
			0,
			32,
			32
		}
	}
	self.equipment_elevator_key = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			32,
			64,
			32,
			32
		}
	}
	self.equipment_blow_torch = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			96,
			192,
			32,
			32
		}
	}
	self.equipment_printer_ink = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			0,
			224,
			32,
			32
		}
	}
	self.equipment_plates = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			32,
			224,
			32,
			32
		}
	}
	self.equipment_paper_roll = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			64,
			224,
			32,
			32
		}
	}
	self.equipment_key_chain = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			128,
			160,
			32,
			32
		}
	}
	self.equipment_hand = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			128,
			0,
			32,
			32
		}
	}
	self.equipment_briefcase = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			96,
			224,
			32,
			32
		}
	}
	self.equipment_soda = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			128,
			64,
			32,
			32
		}
	}
	self.equipment_chrome_mask = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			128,
			32,
			32,
			32
		}
	}
	self.equipment_born_tool = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			96,
			64,
			32,
			32
		}
	}
	self.equipment_liquid_nitrogen_canister = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			128,
			96,
			32,
			32
		}
	}
	self.equipment_medallion = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			128,
			128,
			32,
			32
		}
	}
	self.equipment_bloodvial = {
		texture = "guis/dlcs/nmh/textures/pd2/hud_pickups_bloodvial",
		texture_rect = {
			0,
			0,
			32,
			32
		}
	}
	self.equipment_bloodvialok = {
		texture = "guis/dlcs/nmh/textures/pd2/hud_pickups_bloodvial",
		texture_rect = {
			32,
			0,
			32,
			32
		}
	}
	self.equipment_chimichanga = {
		texture = "guis/dlcs/tag/textures/pd2/hud_pickups_tag",
		texture_rect = {
			0,
			0,
			32,
			32
		}
	}
	self.equipment_stapler = {
		texture = "guis/dlcs/tag/textures/pd2/hud_pickups_stapler",
		texture_rect = {
			0,
			0,
			32,
			32
		}
	}
	self.equipment_compounda = {
		texture = "guis/dlcs/des/textures/pd2/hud_pickups_des",
		texture_rect = {
			0,
			0,
			32,
			32
		}
	}
	self.equipment_compoundb = {
		texture = "guis/dlcs/des/textures/pd2/hud_pickups_des",
		texture_rect = {
			32,
			0,
			32,
			32
		}
	}
	self.equipment_compoundc = {
		texture = "guis/dlcs/des/textures/pd2/hud_pickups_des",
		texture_rect = {
			0,
			32,
			32,
			32
		}
	}
	self.equipment_compoundd = {
		texture = "guis/dlcs/des/textures/pd2/hud_pickups_des",
		texture_rect = {
			32,
			32,
			32,
			32
		}
	}
	self.equipment_compoundok = {
		texture = "guis/dlcs/des/textures/pd2/hud_pickups_des",
		texture_rect = {
			64,
			0,
			32,
			32
		}
	}
	self.equipment_mayan_gold = {
		texture = "guis/dlcs/uno/textures/pd2/hud_pickups_uno",
		texture_rect = {
			0,
			0,
			32,
			32
		}
	}
	self.equipment_blueprint = {
		texture = "guis/dlcs/mex/textures/pd2/hud_pickups_blueprint",
		texture_rect = {
			0,
			0,
			32,
			32
		}
	}
	self.equipment_tape_fingerprint = {
		texture = "guis/dlcs/bex/textures/pd2/hud_pickups_tape_fingerprint",
		texture_rect = {
			0,
			0,
			32,
			32
		}
	}
	self.equipment_tape = {
		texture = "guis/dlcs/bex/textures/pd2/hud_pickups_tape",
		texture_rect = {
			0,
			0,
			32,
			32
		}
	}
	self.equipment_boltcutter = {
		texture = "guis/dlcs/pex/textures/pd2/hud_pickups_boltcutter",
		texture_rect = {
			0,
			0,
			32,
			32
		}
	}
	self.equipment_policebadge = {
		texture = "guis/dlcs/pex/textures/pd2/hud_pickups_policebadge",
		texture_rect = {
			0,
			0,
			32,
			32
		}
	}
	self.equipment_flammable = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			64,
			64,
			32,
			32
		}
	}
	self.equipment_rfid_tag_01 = {
		texture = "guis/dlcs/pex/textures/pd2/hud_pickups_rfid_tag_01",
		texture_rect = {
			0,
			0,
			32,
			32
		}
	}
	self.equipment_rfid_tag_02 = {
		texture = "guis/dlcs/pex/textures/pd2/hud_pickups_rfid_tag_02",
		texture_rect = {
			0,
			0,
			32,
			32
		}
	}
	self.equipment_globe = {
		texture = "guis/dlcs/fex/textures/pd2/hud_pickups_fex",
		texture_rect = {
			0,
			0,
			32,
			32
		}
	}
	self.equipment_scythe = {
		texture = "guis/dlcs/fex/textures/pd2/hud_pickups_fex",
		texture_rect = {
			32,
			0,
			32,
			32
		}
	}
	self.equipment_electrical = {
		texture = "guis/dlcs/fex/textures/pd2/hud_pickups_fex",
		texture_rect = {
			64,
			0,
			32,
			32
		}
	}
	self.equipment_fertilizer = {
		texture = "guis/dlcs/fex/textures/pd2/hud_pickups_fex",
		texture_rect = {
			96,
			0,
			32,
			32
		}
	}
	self.equipment_timer = {
		texture = "guis/dlcs/fex/textures/pd2/hud_pickups_fex",
		texture_rect = {
			0,
			32,
			32,
			32
		}
	}
	self.interaction_free = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			48,
			192,
			48,
			48
		}
	}
	self.interaction_trade = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			432,
			144,
			48,
			48
		}
	}
	self.interaction_intimidate = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			96,
			192,
			48,
			48
		}
	}
	self.interaction_money_wrap = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			144,
			191,
			48,
			48
		}
	}
	self.interaction_christmas_present = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			144,
			240,
			48,
			48
		}
	}
	self.interaction_powerbox = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			192,
			288,
			48,
			48
		}
	}
	self.interaction_gold = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			384,
			240,
			48,
			48
		}
	}
	self.interaction_open_door = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			96,
			192,
			48,
			48
		}
	}
	self.interaction_diamond = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			432,
			240,
			48,
			48
		}
	}
	self.interaction_powercord = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			272,
			336,
			48,
			48
		}
	}
	self.interaction_help = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			192,
			192,
			48,
			48
		}
	}
	self.interaction_answerphone = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			368,
			336,
			48,
			48
		}
	}
	self.interaction_patientfile = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			320,
			336,
			48,
			48
		}
	}
	self.interaction_wirecutter = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			464,
			336,
			48,
			48
		}
	}
	self.interaction_elevator = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			464,
			384,
			48,
			48
		}
	}
	self.interaction_sentrygun = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			320,
			288,
			48,
			48
		}
	}
	self.interaction_keyboard = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			368,
			384,
			48,
			48
		}
	}
	self.laptop_objective = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			240,
			144,
			48,
			48
		}
	}
	self.interaction_bar = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			1,
			393,
			358,
			20
		}
	}
	self.interaction_bar_background = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			0,
			414,
			360,
			22
		}
	}
	self.mugshot_health_background = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			240,
			240,
			12,
			48
		}
	}
	self.mugshot_health_armor = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			252,
			240,
			12,
			48
		}
	}
	self.mugshot_health_health = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			264,
			240,
			12,
			48
		}
	}
	self.mugshot_talk = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			240,
			288,
			16,
			16
		}
	}
	self.mugshot_in_custody = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			192,
			464,
			48,
			48
		}
	}
	self.mugshot_downed = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			240,
			464,
			48,
			48
		}
	}
	self.mugshot_cuffed = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			288,
			464,
			48,
			48
		}
	}
	self.mugshot_electrified = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			336,
			464,
			48,
			48
		}
	}
	self.control_marker = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			352,
			288,
			16,
			48
		}
	}
	self.control_left = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			304,
			288,
			48,
			48
		}
	}
	self.control_right = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			256,
			288,
			48,
			48
		}
	}
	self.assault = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			276,
			192,
			108,
			96
		}
	}
	self.ps3buttonhighlight = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			240,
			192,
			32,
			32
		}
	}
	self.jukebox_playing_icon = {
		texture = "guis/textures/pd2/jukebox_playing",
		texture_rect = {
			0,
			0,
			16,
			16
		}
	}
	self.jukebox_mute_icon = {
		texture = "guis/textures/pd2/jukebox_mute",
		texture_rect = {
			0,
			0,
			16,
			16
		}
	}
	self.downcard_overkill_deck = {
		texture = "guis/textures/pd2/lootscreen/loot_cards",
		texture_rect = {
			0,
			0,
			128,
			180
		}
	}
	self.upcard_mask = {
		texture = "guis/textures/pd2/lootscreen/loot_cards",
		texture_rect = {
			128,
			0,
			128,
			180
		}
	}
	self.upcard_material = {
		texture = "guis/textures/pd2/lootscreen/loot_cards",
		texture_rect = {
			128,
			180,
			128,
			180
		}
	}
	self.upcard_color = {
		texture = "guis/textures/pd2/lootscreen/loot_cards",
		texture_rect = {
			256,
			180,
			128,
			180
		}
	}
	self.upcard_pattern = {
		texture = "guis/textures/pd2/lootscreen/loot_cards",
		texture_rect = {
			384,
			180,
			128,
			180
		}
	}
	self.upcard_weapon = {
		texture = "guis/textures/pd2/lootscreen/loot_cards",
		texture_rect = {
			256,
			0,
			128,
			180
		}
	}
	self.upcard_cash = {
		texture = "guis/textures/pd2/lootscreen/loot_cards",
		texture_rect = {
			384,
			0,
			128,
			180
		}
	}
	self.upcard_xp = {
		texture = "guis/textures/pd2/lootscreen/loot_cards",
		texture_rect = {
			0,
			180,
			128,
			180
		}
	}
	self.upcard_safe = {
		texture = "guis/textures/pd2/lootscreen/loot_cards",
		texture_rect = {
			512,
			0,
			128,
			180
		}
	}
	self.upcard_drill = {
		texture = "guis/textures/pd2/lootscreen/loot_cards",
		texture_rect = {
			512,
			180,
			128,
			180
		}
	}
	self.upcard_weapon_bonus = {
		texture = "guis/textures/pd2/lootscreen/loot_cards",
		texture_rect = {
			640,
			0,
			128,
			180
		}
	}
	self.upcard_random = {
		texture = "guis/textures/pd2/lootscreen/loot_cards",
		texture_rect = {
			640,
			180,
			128,
			180
		}
	}
	self.upcard_coins = {
		texture = "guis/textures/pd2/lootscreen/loot_cards",
		texture_rect = {
			768,
			0,
			128,
			180
		}
	}
	self.upcard_cosmetic = {
		texture = "guis/textures/pd2/lootscreen/loot_cards",
		texture_rect = {
			768,
			180,
			128,
			180
		}
	}
	self.ace_of_spade = {
		texture = "guis/textures/pd2/lootscreen/loot_cards",
		texture_rect = {
			102,
			0,
			102,
			142
		}
	}
	self.two_of_spade = {
		texture = "guis/textures/pd2/lootscreen/loot_cards",
		texture_rect = {
			204,
			0,
			102,
			142
		}
	}
	self.three_of_spade = {
		texture = "guis/textures/pd2/lootscreen/loot_cards",
		texture_rect = {
			306,
			0,
			102,
			142
		}
	}
	self.four_of_spade = {
		texture = "guis/textures/pd2/lootscreen/loot_cards",
		texture_rect = {
			408,
			0,
			102,
			142
		}
	}
	self.five_of_spade = {
		texture = "guis/textures/pd2/lootscreen/loot_cards",
		texture_rect = {
			0,
			142,
			102,
			142
		}
	}
	self.six_of_spade = {
		texture = "guis/textures/pd2/lootscreen/loot_cards",
		texture_rect = {
			102,
			142,
			102,
			142
		}
	}
	self.seven_of_spade = {
		texture = "guis/textures/pd2/lootscreen/loot_cards",
		texture_rect = {
			204,
			142,
			102,
			142
		}
	}
	self.eight_of_spade = {
		texture = "guis/textures/pd2/lootscreen/loot_cards",
		texture_rect = {
			306,
			142,
			102,
			142
		}
	}
	self.nine_of_spade = {
		texture = "guis/textures/pd2/lootscreen/loot_cards",
		texture_rect = {
			408,
			142,
			102,
			142
		}
	}
	self.joker_of_spade = {
		texture = "guis/textures/pd2/lootscreen/loot_cards",
		texture_rect = {
			0,
			284,
			102,
			142
		}
	}
	self.one_of_spade = {
		texture = "guis/textures/pd2/lootscreen/loot_cards",
		texture_rect = {
			102,
			284,
			102,
			142
		}
	}
	self.infamy_icon_1 = {
		texture = "guis/textures/pd2/infamous_symbol",
		texture_rect = {
			32,
			4,
			16,
			16
		}
	}
	self.infamy_icon_2 = {
		texture = "guis/textures/pd2/infamous_symbol",
		texture_rect = {
			48,
			4,
			16,
			16
		}
	}
	self.infamy_icon_3 = {
		texture = "guis/textures/pd2/infamous_symbol",
		texture_rect = {
			0,
			4,
			16,
			16
		}
	}
	self.infamy_icon_4 = {
		texture = "guis/textures/pd2/infamous_symbol",
		texture_rect = {
			16,
			4,
			16,
			16
		}
	}
	self.infamy_icon_5 = {
		texture = "guis/textures/pd2/infamous_symbol",
		texture_rect = {
			64,
			4,
			16,
			16
		}
	}
	self.ai_stopped = {
		texture = "guis/textures/pd2/stophand_symbol",
		texture_rect = {
			0,
			0,
			16,
			32
		}
	}
	self.unit_heal = {
		texture = "guis/textures/unit_heal",
		texture_rect = {
			0,
			0,
			32,
			32
		}
	}
	local crime_spree_atlas_size = 128
	self.crime_spree_health = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/modifiers_atlas",
		texture_rect = {
			crime_spree_atlas_size * 0,
			crime_spree_atlas_size * 0,
			crime_spree_atlas_size,
			crime_spree_atlas_size
		}
	}
	self.crime_spree_damage = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/modifiers_atlas",
		texture_rect = {
			crime_spree_atlas_size * 1,
			crime_spree_atlas_size * 0,
			crime_spree_atlas_size,
			crime_spree_atlas_size
		}
	}
	self.crime_spree_cloaker_smoke = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/modifiers_atlas",
		texture_rect = {
			crime_spree_atlas_size * 2,
			crime_spree_atlas_size * 0,
			crime_spree_atlas_size,
			crime_spree_atlas_size
		}
	}
	self.crime_spree_shield_reflect = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/modifiers_atlas",
		texture_rect = {
			crime_spree_atlas_size * 3,
			crime_spree_atlas_size * 0,
			crime_spree_atlas_size,
			crime_spree_atlas_size
		}
	}
	self.crime_spree_more_medics = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/modifiers_atlas",
		texture_rect = {
			crime_spree_atlas_size * 0,
			crime_spree_atlas_size * 1,
			crime_spree_atlas_size,
			crime_spree_atlas_size
		}
	}
	self.crime_spree_more_dozers = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/modifiers_atlas",
		texture_rect = {
			crime_spree_atlas_size * 1,
			crime_spree_atlas_size * 1,
			crime_spree_atlas_size,
			crime_spree_atlas_size
		}
	}
	self.crime_spree_no_hurt = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/modifiers_atlas",
		texture_rect = {
			crime_spree_atlas_size * 2,
			crime_spree_atlas_size * 1,
			crime_spree_atlas_size,
			crime_spree_atlas_size
		}
	}
	self.crime_spree_medic_speed = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/modifiers_atlas",
		texture_rect = {
			crime_spree_atlas_size * 3,
			crime_spree_atlas_size * 1,
			crime_spree_atlas_size,
			crime_spree_atlas_size
		}
	}
	self.crime_spree_heavies = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/modifiers_atlas",
		texture_rect = {
			crime_spree_atlas_size * 0,
			crime_spree_atlas_size * 2,
			crime_spree_atlas_size,
			crime_spree_atlas_size
		}
	}
	self.crime_spree_dozer_explosion = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/modifiers_atlas",
		texture_rect = {
			crime_spree_atlas_size * 1,
			crime_spree_atlas_size * 2,
			crime_spree_atlas_size,
			crime_spree_atlas_size
		}
	}
	self.crime_spree_dozer_lmg = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/modifiers_atlas",
		texture_rect = {
			crime_spree_atlas_size * 2,
			crime_spree_atlas_size * 2,
			crime_spree_atlas_size,
			crime_spree_atlas_size
		}
	}
	self.crime_spree_pager = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/modifiers_atlas",
		texture_rect = {
			crime_spree_atlas_size * 3,
			crime_spree_atlas_size * 2,
			crime_spree_atlas_size,
			crime_spree_atlas_size
		}
	}
	self.crime_spree_civs_killed = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/modifiers_atlas",
		texture_rect = {
			crime_spree_atlas_size * 0,
			crime_spree_atlas_size * 3,
			crime_spree_atlas_size,
			crime_spree_atlas_size
		}
	}
	self.crime_spree_concealment = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/modifiers_atlas",
		texture_rect = {
			crime_spree_atlas_size * 1,
			crime_spree_atlas_size * 3,
			crime_spree_atlas_size,
			crime_spree_atlas_size
		}
	}
	self.crime_spree_assault_extender = {
		texture = "guis/dlcs/drm/textures/pd2/crime_spree/modifiers_atlas_2",
		texture_rect = {
			crime_spree_atlas_size * 0,
			crime_spree_atlas_size * 2,
			crime_spree_atlas_size,
			crime_spree_atlas_size
		}
	}
	self.crime_spree_cloaker_arrest = {
		texture = "guis/dlcs/drm/textures/pd2/crime_spree/modifiers_atlas_2",
		texture_rect = {
			crime_spree_atlas_size * 1,
			crime_spree_atlas_size * 0,
			crime_spree_atlas_size,
			crime_spree_atlas_size
		}
	}
	self.crime_spree_cloaker_tear_gas = {
		texture = "guis/dlcs/drm/textures/pd2/crime_spree/modifiers_atlas_2",
		texture_rect = {
			crime_spree_atlas_size * 1,
			crime_spree_atlas_size * 2,
			crime_spree_atlas_size,
			crime_spree_atlas_size
		}
	}
	self.crime_spree_dozer_medic = {
		texture = "guis/dlcs/drm/textures/pd2/crime_spree/modifiers_atlas_2",
		texture_rect = {
			crime_spree_atlas_size * 0,
			crime_spree_atlas_size * 1,
			crime_spree_atlas_size,
			crime_spree_atlas_size
		}
	}
	self.crime_spree_dozer_minigun = {
		texture = "guis/dlcs/drm/textures/pd2/crime_spree/modifiers_atlas_2",
		texture_rect = {
			crime_spree_atlas_size * 3,
			crime_spree_atlas_size * 1,
			crime_spree_atlas_size,
			crime_spree_atlas_size
		}
	}
	self.crime_spree_dozer_rage = {
		texture = "guis/dlcs/drm/textures/pd2/crime_spree/modifiers_atlas_2",
		texture_rect = {
			crime_spree_atlas_size * 2,
			crime_spree_atlas_size * 2,
			crime_spree_atlas_size,
			crime_spree_atlas_size
		}
	}
	self.crime_spree_heavy_sniper = {
		texture = "guis/dlcs/drm/textures/pd2/crime_spree/modifiers_atlas_2",
		texture_rect = {
			crime_spree_atlas_size * 3,
			crime_spree_atlas_size * 2,
			crime_spree_atlas_size,
			crime_spree_atlas_size
		}
	}
	self.crime_spree_medic_adrenaline = {
		texture = "guis/dlcs/drm/textures/pd2/crime_spree/modifiers_atlas_2",
		texture_rect = {
			crime_spree_atlas_size * 3,
			crime_spree_atlas_size * 0,
			crime_spree_atlas_size,
			crime_spree_atlas_size
		}
	}
	self.crime_spree_medic_deathwish = {
		texture = "guis/dlcs/drm/textures/pd2/crime_spree/modifiers_atlas_2",
		texture_rect = {
			crime_spree_atlas_size * 1,
			crime_spree_atlas_size * 1,
			crime_spree_atlas_size,
			crime_spree_atlas_size
		}
	}
	self.crime_spree_medic_rage = {
		texture = "guis/dlcs/drm/textures/pd2/crime_spree/modifiers_atlas_2",
		texture_rect = {
			crime_spree_atlas_size * 2,
			crime_spree_atlas_size * 0,
			crime_spree_atlas_size,
			crime_spree_atlas_size
		}
	}
	self.crime_spree_shield_phalanx = {
		texture = "guis/dlcs/drm/textures/pd2/crime_spree/modifiers_atlas_2",
		texture_rect = {
			crime_spree_atlas_size * 0,
			crime_spree_atlas_size * 0,
			crime_spree_atlas_size,
			crime_spree_atlas_size
		}
	}
	self.crime_spree_taser_overcharge = {
		texture = "guis/dlcs/drm/textures/pd2/crime_spree/modifiers_atlas_2",
		texture_rect = {
			crime_spree_atlas_size * 2,
			crime_spree_atlas_size * 1,
			crime_spree_atlas_size,
			crime_spree_atlas_size
		}
	}
	local csm_w = 280
	local csm_h = 140
	self.csm_biker_1 = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 0,
			csm_h * 0,
			csm_w,
			csm_h
		}
	}
	self.csm_biker_2 = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 1,
			csm_h * 0,
			csm_w,
			csm_h
		}
	}
	self.csm_carshop = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 2,
			csm_h * 0,
			csm_w,
			csm_h
		}
	}
	self.csm_branchbank = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 3,
			csm_h * 0,
			csm_w,
			csm_h
		}
	}
	self.csm_shadow_raid = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 4,
			csm_h * 0,
			csm_w,
			csm_h
		}
	}
	self.csm_crossroads = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 5,
			csm_h * 0,
			csm_w,
			csm_h
		}
	}
	self.csm_downtown = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 6,
			csm_h * 0,
			csm_w,
			csm_h
		}
	}
	self.csm_park = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 0,
			csm_h * 1,
			csm_w,
			csm_h
		}
	}
	self.csm_overpass = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 1,
			csm_h * 1,
			csm_w,
			csm_h
		}
	}
	self.csm_harbor = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 2,
			csm_h * 1,
			csm_w,
			csm_h
		}
	}
	self.csm_murky = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 3,
			csm_h * 1,
			csm_w,
			csm_h
		}
	}
	self.csm_prison = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 4,
			csm_h * 1,
			csm_w,
			csm_h
		}
	}
	self.csm_fs_1 = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 5,
			csm_h * 1,
			csm_w,
			csm_h
		}
	}
	self.csm_fs_2 = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 6,
			csm_h * 1,
			csm_w,
			csm_h
		}
	}
	self.csm_santas_workshop = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 0,
			csm_h * 2,
			csm_w,
			csm_h
		}
	}
	self.csm_hoxvenge = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 1,
			csm_h * 2,
			csm_w,
			csm_h
		}
	}
	self.csm_election_1 = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 2,
			csm_h * 2,
			csm_w,
			csm_h
		}
	}
	self.csm_election_2 = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 3,
			csm_h * 2,
			csm_w,
			csm_h
		}
	}
	self.csm_election_3 = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 4,
			csm_h * 2,
			csm_w,
			csm_h
		}
	}
	self.csm_bigoil_1 = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 5,
			csm_h * 2,
			csm_w,
			csm_h
		}
	}
	self.csm_bigoil_2 = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 6,
			csm_h * 2,
			csm_w,
			csm_h
		}
	}
	self.csm_framing_3 = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 0,
			csm_h * 3,
			csm_w,
			csm_h
		}
	}
	self.csm_train_forest = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 1,
			csm_h * 3,
			csm_w,
			csm_h
		}
	}
	self.csm_yacht = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 2,
			csm_h * 3,
			csm_w,
			csm_h
		}
	}
	self.csm_counterfeit = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 3,
			csm_h * 3,
			csm_w,
			csm_h
		}
	}
	self.csm_undercover = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 4,
			csm_h * 3,
			csm_w,
			csm_h
		}
	}
	self.csm_panic_room = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 5,
			csm_h * 3,
			csm_w,
			csm_h
		}
	}
	self.csm_watchdogs_1 = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 6,
			csm_h * 3,
			csm_w,
			csm_h
		}
	}
	self.csm_docks = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 0,
			csm_h * 4,
			csm_w,
			csm_h
		}
	}
	self.csm_white_xmas = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 1,
			csm_h * 4,
			csm_w,
			csm_h
		}
	}
	self.csm_aftershock = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 2,
			csm_h * 4,
			csm_w,
			csm_h
		}
	}
	self.csm_stealing_xmas = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 3,
			csm_h * 4,
			csm_w,
			csm_h
		}
	}
	self.csm_friend = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 4,
			csm_h * 4,
			csm_w,
			csm_h
		}
	}
	self.csm_brooklyn = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 5,
			csm_h * 4,
			csm_w,
			csm_h
		}
	}
	self.csm_rats_1 = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 6,
			csm_h * 4,
			csm_w,
			csm_h
		}
	}
	self.csm_fwb = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 0,
			csm_h * 5,
			csm_w,
			csm_h
		}
	}
	self.csm_slaughterhouse = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 1,
			csm_h * 5,
			csm_w,
			csm_h
		}
	}
	self.csm_big = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 2,
			csm_h * 5,
			csm_w,
			csm_h
		}
	}
	self.csm_miami_1 = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 3,
			csm_h * 5,
			csm_w,
			csm_h
		}
	}
	self.csm_miami_2 = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 4,
			csm_h * 5,
			csm_w,
			csm_h
		}
	}
	self.csm_hoxout_1 = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 5,
			csm_h * 5,
			csm_w,
			csm_h
		}
	}
	self.csm_hoxout_2 = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 6,
			csm_h * 5,
			csm_w,
			csm_h
		}
	}
	self.csm_diamond = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 0,
			csm_h * 6,
			csm_w,
			csm_h
		}
	}
	self.csm_mountain = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 1,
			csm_h * 6,
			csm_w,
			csm_h
		}
	}
	self.csm_go = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 2,
			csm_h * 6,
			csm_w,
			csm_h
		}
	}
	self.csm_sky = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 3,
			csm_h * 6,
			csm_w,
			csm_h
		}
	}
	self.csm_labrats = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 4,
			csm_h * 6,
			csm_w,
			csm_h
		}
	}
	self.csm_run = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 5,
			csm_h * 6,
			csm_w,
			csm_h
		}
	}
	self.csm_glace = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/missions_atlas",
		texture_rect = {
			csm_w * 6,
			csm_h * 6,
			csm_w,
			csm_h
		}
	}
	self.csm_wwh = {
		texture = "guis/textures/pd2/crime_spree/missions_atlas_02",
		texture_rect = {
			csm_w * 0,
			csm_h * 0,
			csm_w,
			csm_h
		}
	}
	self.csm_rvd_2 = {
		texture = "guis/textures/pd2/crime_spree/missions_atlas_02",
		texture_rect = {
			csm_w * 1,
			csm_h * 0,
			csm_w,
			csm_h
		}
	}
	self.csm_rvd_1 = {
		texture = "guis/textures/pd2/crime_spree/missions_atlas_02",
		texture_rect = {
			csm_w * 2,
			csm_h * 0,
			csm_w,
			csm_h
		}
	}
	self.csm_brb = {
		texture = "guis/textures/pd2/crime_spree/missions_atlas_02",
		texture_rect = {
			csm_w * 3,
			csm_h * 0,
			csm_w,
			csm_h
		}
	}
	self.csm_dah = {
		texture = "guis/textures/pd2/crime_spree/missions_atlas_02",
		texture_rect = {
			csm_w * 4,
			csm_h * 0,
			csm_w,
			csm_h
		}
	}
	local csb_size = 128
	self.csb_reload = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
		texture_rect = {
			csb_size * 0,
			csb_size * 0,
			csb_size,
			csb_size
		}
	}
	self.csb_stamina = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
		texture_rect = {
			csb_size * 1,
			csb_size * 0,
			csb_size,
			csb_size
		}
	}
	self.csb_ammo = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
		texture_rect = {
			csb_size * 2,
			csb_size * 0,
			csb_size,
			csb_size
		}
	}
	self.csb_lifesteal = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
		texture_rect = {
			csb_size * 3,
			csb_size * 0,
			csb_size,
			csb_size
		}
	}
	self.csb_armor = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
		texture_rect = {
			csb_size * 4,
			csb_size * 0,
			csb_size,
			csb_size
		}
	}
	self.csb_absorb = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
		texture_rect = {
			csb_size * 5,
			csb_size * 0,
			csb_size,
			csb_size
		}
	}
	self.csb_health = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
		texture_rect = {
			csb_size * 6,
			csb_size * 0,
			csb_size,
			csb_size
		}
	}
	self.csb_switch = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
		texture_rect = {
			csb_size * 7,
			csb_size * 0,
			csb_size,
			csb_size
		}
	}
	self.csb_lives = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
		texture_rect = {
			csb_size * 0,
			csb_size * 1,
			csb_size,
			csb_size
		}
	}
	self.csb_throwables = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
		texture_rect = {
			csb_size * 1,
			csb_size * 1,
			csb_size,
			csb_size
		}
	}
	self.csb_deployables = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
		texture_rect = {
			csb_size * 2,
			csb_size * 1,
			csb_size,
			csb_size
		}
	}
	self.csb_panic = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
		texture_rect = {
			csb_size * 3,
			csb_size * 1,
			csb_size,
			csb_size
		}
	}
	self.csb_melee = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
		texture_rect = {
			csb_size * 4,
			csb_size * 1,
			csb_size,
			csb_size
		}
	}
	self.csb_explosion = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
		texture_rect = {
			csb_size * 5,
			csb_size * 1,
			csb_size,
			csb_size
		}
	}
	self.csb_pagers = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
		texture_rect = {
			csb_size * 6,
			csb_size * 1,
			csb_size,
			csb_size
		}
	}
	self.csb_bodybags = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
		texture_rect = {
			csb_size * 7,
			csb_size * 1,
			csb_size,
			csb_size
		}
	}
	self.csb_crouch = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
		texture_rect = {
			csb_size * 0,
			csb_size * 2,
			csb_size,
			csb_size
		}
	}
	self.csb_locks = {
		texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
		texture_rect = {
			csb_size * 1,
			csb_size * 2,
			csb_size,
			csb_size
		}
	}
	self.C_All_H_All_01Job_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			870,
			522,
			85,
			85
		}
	}
	self.C_All_H_All_AllJobs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			261,
			522,
			85,
			85
		}
	}
	self.C_All_H_All_AllJobs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			783,
			522,
			85,
			85
		}
	}
	self.C_All_H_All_AllJobs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			435,
			783,
			85,
			85
		}
	}
	self.C_All_H_All_AllJobs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			609,
			348,
			85,
			85
		}
	}
	self.C_All_H_All_AllJobs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			348,
			609,
			85,
			85
		}
	}
	self.C_All_H_All_AllJobs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			435,
			696,
			85,
			85
		}
	}
	self.C_All_H_All_AllJobs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			696,
			522,
			85,
			85
		}
	}
	self.C_Bain_H_All_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			870,
			174,
			85,
			85
		}
	}
	self.C_Bain_H_All_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			87,
			522,
			85,
			85
		}
	}
	self.C_Bain_H_All_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			261,
			87,
			85,
			85
		}
	}
	self.C_Bain_H_All_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			348,
			870,
			85,
			85
		}
	}
	self.C_Bain_H_All_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			0,
			87,
			85,
			85
		}
	}
	self.C_Bain_H_All_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			696,
			870,
			85,
			85
		}
	}
	self.C_Bain_H_All_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			174,
			261,
			85,
			85
		}
	}
	self.C_Bain_H_Arena_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			261,
			696,
			85,
			85
		}
	}
	self.C_Bain_H_Arena_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			261,
			87,
			85,
			85
		}
	}
	self.C_Bain_H_Arena_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			87,
			348,
			85,
			85
		}
	}
	self.C_Bain_H_Arena_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			870,
			609,
			85,
			85
		}
	}
	self.C_Bain_H_Arena_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			261,
			348,
			85,
			85
		}
	}
	self.C_Bain_H_Arena_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			870,
			261,
			85,
			85
		}
	}
	self.C_Bain_H_Arena_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			348,
			348,
			85,
			85
		}
	}
	self.C_Bain_H_Arena_Even = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			0,
			0,
			85,
			85
		}
	}
	self.C_Bain_H_Arena_FuckIt = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			783,
			870,
			85,
			85
		}
	}
	self.C_Bain_H_Arena_MFStev = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			522,
			696,
			85,
			85
		}
	}
	self.C_Bain_H_Arena_SoundofSilence = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			609,
			522,
			85,
			85
		}
	}
	self.C_Bain_H_ArtGallery_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			609,
			174,
			85,
			85
		}
	}
	self.C_Bain_H_ArtGallery_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			0,
			0,
			85,
			85
		}
	}
	self.C_Bain_H_ArtGallery_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			0,
			435,
			85,
			85
		}
	}
	self.C_Bain_H_ArtGallery_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			435,
			609,
			85,
			85
		}
	}
	self.C_Bain_H_ArtGallery_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			174,
			348,
			85,
			85
		}
	}
	self.C_Bain_H_ArtGallery_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			783,
			696,
			85,
			85
		}
	}
	self.C_Bain_H_ArtGallery_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			174,
			696,
			85,
			85
		}
	}
	self.C_Bain_H_ArtGallery_TheTurtle = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			348,
			609,
			85,
			85
		}
	}
	self.C_Bain_H_ArtGallery_TheWolfLures = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			174,
			261,
			85,
			85
		}
	}
	self.C_Bain_H_BankVarious_SaintFrancis = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			696,
			87,
			85,
			85
		}
	}
	self.C_Bain_H_BankC_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			696,
			435,
			85,
			85
		}
	}
	self.C_Bain_H_BankC_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			174,
			261,
			85,
			85
		}
	}
	self.C_Bain_H_BankC_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			696,
			87,
			85,
			85
		}
	}
	self.C_Bain_H_BankC_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			174,
			174,
			85,
			85
		}
	}
	self.C_Bain_H_BankC_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			0,
			696,
			85,
			85
		}
	}
	self.C_Bain_H_BankC_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			522,
			522,
			85,
			85
		}
	}
	self.C_Bain_H_BankC_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			87,
			870,
			85,
			85
		}
	}
	self.C_Bain_H_BankD_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			0,
			870,
			85,
			85
		}
	}
	self.C_Bain_H_BankD_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			348,
			348,
			85,
			85
		}
	}
	self.C_Bain_H_BankD_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			0,
			870,
			85,
			85
		}
	}
	self.C_Bain_H_BankD_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			870,
			870,
			85,
			85
		}
	}
	self.C_Bain_H_BankD_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			174,
			783,
			85,
			85
		}
	}
	self.C_Bain_H_BankD_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			870,
			87,
			85,
			85
		}
	}
	self.C_Bain_H_BankD_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			609,
			609,
			85,
			85
		}
	}
	self.C_Bain_H_BankG_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			348,
			0,
			85,
			85
		}
	}
	self.C_Bain_H_BankG_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			348,
			435,
			85,
			85
		}
	}
	self.C_Bain_H_BankG_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			435,
			261,
			85,
			85
		}
	}
	self.C_Bain_H_BankG_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			435,
			435,
			85,
			85
		}
	}
	self.C_Bain_H_BankG_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			87,
			783,
			85,
			85
		}
	}
	self.C_Bain_H_BankG_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			696,
			696,
			85,
			85
		}
	}
	self.C_Bain_H_BankG_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			174,
			870,
			85,
			85
		}
	}
	self.C_Bain_H_BankR_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			609,
			0,
			85,
			85
		}
	}
	self.C_Bain_H_BankR_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			522,
			870,
			85,
			85
		}
	}
	self.C_Bain_H_BankR_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			435,
			174,
			85,
			85
		}
	}
	self.C_Bain_H_BankR_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			87,
			261,
			85,
			85
		}
	}
	self.C_Bain_H_BankR_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			522,
			87,
			85,
			85
		}
	}
	self.C_Bain_H_BankR_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			783,
			870,
			85,
			85
		}
	}
	self.C_Bain_H_BankR_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			0,
			783,
			85,
			85
		}
	}
	self.C_Bain_H_Car_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			609,
			348,
			85,
			85
		}
	}
	self.C_Bain_H_Car_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			261,
			435,
			85,
			85
		}
	}
	self.C_Bain_H_Car_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			435,
			0,
			85,
			85
		}
	}
	self.C_Bain_H_Car_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			783,
			174,
			85,
			85
		}
	}
	self.C_Bain_H_Car_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			522,
			87,
			85,
			85
		}
	}
	self.C_Bain_H_Car_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			87,
			174,
			85,
			85
		}
	}
	self.C_Bain_H_Car_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			522,
			609,
			85,
			85
		}
	}
	self.C_Bain_H_Car_Gone = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			87,
			87,
			85,
			85
		}
	}
	self.C_Bain_H_Car_Tag = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			174,
			261,
			85,
			85
		}
	}
	self.C_Bain_H_CookOff_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			783,
			0,
			85,
			85
		}
	}
	self.C_Bain_H_CookOff_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			783,
			783,
			85,
			85
		}
	}
	self.C_Bain_H_CookOff_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			87,
			696,
			85,
			85
		}
	}
	self.C_Bain_H_CookOff_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			870,
			174,
			85,
			85
		}
	}
	self.C_Bain_H_CookOff_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			522,
			522,
			85,
			85
		}
	}
	self.C_Bain_H_CookOff_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			87,
			696,
			85,
			85
		}
	}
	self.C_Bain_H_CookOff_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			783,
			696,
			85,
			85
		}
	}
	self.C_Bain_H_CookOff_KissTheChef = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			261,
			174,
			85,
			85
		}
	}
	self.C_Bain_H_DiamondStore_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			87,
			0,
			85,
			85
		}
	}
	self.C_Bain_H_DiamondStore_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			348,
			870,
			85,
			85
		}
	}
	self.C_Bain_H_DiamondStore_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			696,
			522,
			85,
			85
		}
	}
	self.C_Bain_H_DiamondStore_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			261,
			522,
			85,
			85
		}
	}
	self.C_Bain_H_DiamondStore_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			783,
			522,
			85,
			85
		}
	}
	self.C_Bain_H_DiamondStore_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			435,
			609,
			85,
			85
		}
	}
	self.C_Bain_H_DiamondStore_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			522,
			0,
			85,
			85
		}
	}
	self.C_Bain_H_GOBank_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			783,
			435,
			85,
			85
		}
	}
	self.C_Bain_H_GOBank_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			609,
			783,
			85,
			85
		}
	}
	self.C_Bain_H_GOBank_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			261,
			348,
			85,
			85
		}
	}
	self.C_Bain_H_GOBank_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			348,
			0,
			85,
			85
		}
	}
	self.C_Bain_H_GOBank_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			261,
			435,
			85,
			85
		}
	}
	self.C_Bain_H_GOBank_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			783,
			261,
			85,
			85
		}
	}
	self.C_Bain_H_GOBank_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			0,
			0,
			85,
			85
		}
	}
	self.C_Bain_H_GOBank_AllEggs = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			174,
			174,
			85,
			85
		}
	}
	self.C_Bain_H_GOBank_DeadPresents = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			870,
			609,
			85,
			85
		}
	}
	self.C_Bain_H_GOBank_Eco = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			870,
			348,
			85,
			85
		}
	}
	self.C_Bain_H_GOBank_IsEverythingOK = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			87,
			0,
			85,
			85
		}
	}
	self.C_Bain_H_GOBank_SewerRats = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			0,
			261,
			85,
			85
		}
	}
	self.C_Bain_H_GOBank_UpsideDown = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			348,
			696,
			85,
			85
		}
	}
	self.C_Bain_H_GOBank_WeAreAll = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			435,
			522,
			85,
			85
		}
	}
	self.C_Bain_H_JewelryStore_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			87,
			783,
			85,
			85
		}
	}
	self.C_Bain_H_JewelryStore_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			870,
			783,
			85,
			85
		}
	}
	self.C_Bain_H_JewelryStore_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			0,
			261,
			85,
			85
		}
	}
	self.C_Bain_H_JewelryStore_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			609,
			261,
			85,
			85
		}
	}
	self.C_Bain_H_JewelryStore_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			696,
			870,
			85,
			85
		}
	}
	self.C_Bain_H_JewelryStore_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			696,
			261,
			85,
			85
		}
	}
	self.C_Bain_H_JewelryStore_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			435,
			261,
			85,
			85
		}
	}
	self.C_Bain_H_JewelryStore_Diamonds = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			0,
			348,
			85,
			85
		}
	}
	self.C_Bain_H_JewelryStore_PrivateParty = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			522,
			348,
			85,
			85
		}
	}
	self.C_Bain_H_ShadowRaid_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			522,
			0,
			85,
			85
		}
	}
	self.C_Bain_H_ShadowRaid_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			609,
			870,
			85,
			85
		}
	}
	self.C_Bain_H_ShadowRaid_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			0,
			870,
			85,
			85
		}
	}
	self.C_Bain_H_ShadowRaid_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			348,
			261,
			85,
			85
		}
	}
	self.C_Bain_H_ShadowRaid_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			261,
			783,
			85,
			85
		}
	}
	self.C_Bain_H_ShadowRaid_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			435,
			348,
			85,
			85
		}
	}
	self.C_Bain_H_ShadowRaid_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			87,
			261,
			85,
			85
		}
	}
	self.C_Bain_H_ShadowRaid_IAmNinja = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			0,
			696,
			85,
			85
		}
	}
	self.C_Bain_H_ShadowRaid_IHaveNoIdea = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			348,
			0,
			85,
			85
		}
	}
	self.C_Bain_H_ShadowRaid_IWillFade = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			174,
			522,
			85,
			85
		}
	}
	self.C_Bain_H_ShadowRaid_IWillPass = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			522,
			0,
			85,
			85
		}
	}
	self.C_Bain_H_ShadowRaid_IWillTake = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			783,
			609,
			85,
			85
		}
	}
	self.C_Bain_H_ShadowRaid_IWillWalk = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			696,
			783,
			85,
			85
		}
	}
	self.C_Bain_H_TransportVarious_ButWait = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			348,
			522,
			85,
			85
		}
	}
	self.C_Bain_H_TransportVarious_IDoWhat = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			348,
			174,
			85,
			85
		}
	}
	self.C_Bain_H_TransportVarious_IfYouLikedIt = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			87,
			435,
			85,
			85
		}
	}
	self.C_Bain_H_TransportCrossroads_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			0,
			435,
			85,
			85
		}
	}
	self.C_Bain_H_TransportCrossroads_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			174,
			696,
			85,
			85
		}
	}
	self.C_Bain_H_TransportCrossroads_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			348,
			261,
			85,
			85
		}
	}
	self.C_Bain_H_TransportCrossroads_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			87,
			522,
			85,
			85
		}
	}
	self.C_Bain_H_TransportCrossroads_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			261,
			0,
			85,
			85
		}
	}
	self.C_Bain_H_TransportCrossroads_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			435,
			696,
			85,
			85
		}
	}
	self.C_Bain_H_TransportCrossroads_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			435,
			87,
			85,
			85
		}
	}
	self.C_Bain_H_TransportDowntown_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			87,
			870,
			85,
			85
		}
	}
	self.C_Bain_H_TransportDowntown_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			870,
			348,
			85,
			85
		}
	}
	self.C_Bain_H_TransportDowntown_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			0,
			0,
			85,
			85
		}
	}
	self.C_Bain_H_TransportDowntown_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			87,
			870,
			85,
			85
		}
	}
	self.C_Bain_H_TransportDowntown_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			522,
			435,
			85,
			85
		}
	}
	self.C_Bain_H_TransportDowntown_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			0,
			435,
			85,
			85
		}
	}
	self.C_Bain_H_TransportDowntown_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			783,
			696,
			85,
			85
		}
	}
	self.C_Bain_H_TransportHarbor_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			783,
			0,
			85,
			85
		}
	}
	self.C_Bain_H_TransportHarbor_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			870,
			870,
			85,
			85
		}
	}
	self.C_Bain_H_TransportHarbor_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			261,
			870,
			85,
			85
		}
	}
	self.C_Bain_H_TransportHarbor_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			174,
			87,
			85,
			85
		}
	}
	self.C_Bain_H_TransportHarbor_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			261,
			870,
			85,
			85
		}
	}
	self.C_Bain_H_TransportHarbor_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			696,
			609,
			85,
			85
		}
	}
	self.C_Bain_H_TransportHarbor_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			0,
			783,
			85,
			85
		}
	}
	self.C_Bain_H_TransportPark_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			870,
			783,
			85,
			85
		}
	}
	self.C_Bain_H_TransportPark_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			609,
			435,
			85,
			85
		}
	}
	self.C_Bain_H_TransportPark_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			783,
			870,
			85,
			85
		}
	}
	self.C_Bain_H_TransportPark_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			522,
			261,
			85,
			85
		}
	}
	self.C_Bain_H_TransportPark_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			174,
			522,
			85,
			85
		}
	}
	self.C_Bain_H_TransportPark_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			348,
			87,
			85,
			85
		}
	}
	self.C_Bain_H_TransportPark_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			87,
			348,
			85,
			85
		}
	}
	self.C_Bain_H_TrainHeist_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			348,
			522,
			85,
			85
		}
	}
	self.C_Bain_H_TrainHeist_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			87,
			174,
			85,
			85
		}
	}
	self.C_Bain_H_TrainHeist_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			696,
			435,
			85,
			85
		}
	}
	self.C_Bain_H_TrainHeist_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			783,
			435,
			85,
			85
		}
	}
	self.C_Bain_H_TrainHeist_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			522,
			348,
			85,
			85
		}
	}
	self.C_Bain_H_TrainHeist_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			609,
			783,
			85,
			85
		}
	}
	self.C_Bain_H_TrainHeist_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			174,
			435,
			85,
			85
		}
	}
	self.C_Bain_H_TrainHeist_LetThem = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			609,
			261,
			85,
			85
		}
	}
	self.C_Bain_H_TrainHeist_WereGonnaNeed = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			435,
			87,
			85,
			85
		}
	}
	self.C_Bain_H_TransportUnderpass_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			783,
			87,
			85,
			85
		}
	}
	self.C_Bain_H_TransportUnderpass_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			696,
			696,
			85,
			85
		}
	}
	self.C_Bain_H_TransportUnderpass_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			0,
			609,
			85,
			85
		}
	}
	self.C_Bain_H_TransportUnderpass_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			870,
			870,
			85,
			85
		}
	}
	self.C_Bain_H_TransportUnderpass_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			174,
			609,
			85,
			85
		}
	}
	self.C_Bain_H_TransportUnderpass_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			609,
			435,
			85,
			85
		}
	}
	self.C_Bain_H_TransportUnderpass_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			87,
			261,
			85,
			85
		}
	}
	self.C_Butcher_H_All_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			174,
			783,
			85,
			85
		}
	}
	self.C_Butcher_H_All_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			609,
			522,
			85,
			85
		}
	}
	self.C_Butcher_H_All_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			261,
			783,
			85,
			85
		}
	}
	self.C_Butcher_H_All_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			0,
			522,
			85,
			85
		}
	}
	self.C_Butcher_H_All_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			261,
			174,
			85,
			85
		}
	}
	self.C_Butcher_H_All_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			0,
			435,
			85,
			85
		}
	}
	self.C_Butcher_H_All_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			870,
			696,
			85,
			85
		}
	}
	self.C_Butcher_H_BombDock_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			87,
			870,
			85,
			85
		}
	}
	self.C_Butcher_H_BombDock_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			435,
			435,
			85,
			85
		}
	}
	self.C_Butcher_H_BombDock_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			435,
			783,
			85,
			85
		}
	}
	self.C_Butcher_H_BombDock_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			87,
			0,
			85,
			85
		}
	}
	self.C_Butcher_H_BombDock_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			783,
			0,
			85,
			85
		}
	}
	self.C_Butcher_H_BombDock_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			870,
			0,
			85,
			85
		}
	}
	self.C_Butcher_H_BombDock_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			696,
			696,
			85,
			85
		}
	}
	self.C_Butcher_H_BombDock_Breaking = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			870,
			609,
			85,
			85
		}
	}
	self.C_Butcher_H_BombDock_Done = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			261,
			261,
			85,
			85
		}
	}
	self.C_Butcher_H_BombDock_HighTimes = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			696,
			522,
			85,
			85
		}
	}
	self.C_Butcher_H_BombDock_IveGot = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			348,
			174,
			85,
			85
		}
	}
	self.C_Butcher_H_BombDock_Sneaking = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			522,
			261,
			85,
			85
		}
	}
	self.C_Butcher_H_BombForest_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			696,
			348,
			85,
			85
		}
	}
	self.C_Butcher_H_BombForest_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			783,
			435,
			85,
			85
		}
	}
	self.C_Butcher_H_BombForest_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			174,
			0,
			85,
			85
		}
	}
	self.C_Butcher_H_BombForest_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			0,
			261,
			85,
			85
		}
	}
	self.C_Butcher_H_BombForest_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			609,
			348,
			85,
			85
		}
	}
	self.C_Butcher_H_BombForest_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			87,
			87,
			85,
			85
		}
	}
	self.C_Butcher_H_BombForest_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			435,
			174,
			85,
			85
		}
	}
	self.C_Butcher_H_BombForest_Beaver = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			696,
			870,
			85,
			85
		}
	}
	self.C_Butcher_H_BombForest_Oppressor = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			348,
			522,
			85,
			85
		}
	}
	self.C_Butcher_H_BombForest_PumpIt = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			435,
			609,
			85,
			85
		}
	}
	self.C_Butcher_H_Scarface_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			435,
			870,
			85,
			85
		}
	}
	self.C_Butcher_H_Scarface_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			870,
			870,
			85,
			85
		}
	}
	self.C_Butcher_H_Scarface_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			261,
			435,
			85,
			85
		}
	}
	self.C_Butcher_H_Scarface_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			696,
			261,
			85,
			85
		}
	}
	self.C_Butcher_H_Scarface_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			261,
			348,
			85,
			85
		}
	}
	self.C_Butcher_H_Scarface_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			696,
			87,
			85,
			85
		}
	}
	self.C_Butcher_H_Scarface_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			522,
			609,
			85,
			85
		}
	}
	self.C_Butcher_H_Scarface_LookAtThese = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			87,
			348,
			85,
			85
		}
	}
	self.C_Butcher_H_Scarface_SayHello = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			435,
			348,
			85,
			85
		}
	}
	self.C_Butcher_H_Scarface_WhatYouWant = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			522,
			870,
			85,
			85
		}
	}
	self.C_Classics_H_All_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			783,
			348,
			85,
			85
		}
	}
	self.C_Classics_H_All_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			522,
			0,
			85,
			85
		}
	}
	self.C_Classics_H_All_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			609,
			0,
			85,
			85
		}
	}
	self.C_Classics_H_All_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			348,
			0,
			85,
			85
		}
	}
	self.C_Classics_H_All_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			522,
			870,
			85,
			85
		}
	}
	self.C_Classics_H_All_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			522,
			174,
			85,
			85
		}
	}
	self.C_Classics_H_All_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			609,
			783,
			85,
			85
		}
	}
	self.C_Classics_H_Counterfeit_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			783,
			348,
			85,
			85
		}
	}
	self.C_Classics_H_Counterfeit_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			696,
			870,
			85,
			85
		}
	}
	self.C_Classics_H_Counterfeit_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			870,
			696,
			85,
			85
		}
	}
	self.C_Classics_H_Counterfeit_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			870,
			522,
			85,
			85
		}
	}
	self.C_Classics_H_Counterfeit_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			435,
			87,
			85,
			85
		}
	}
	self.C_Classics_H_Counterfeit_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			870,
			261,
			85,
			85
		}
	}
	self.C_Classics_H_Counterfeit_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			609,
			609,
			85,
			85
		}
	}
	self.C_Classics_H_Counterfeit_Basement = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			261,
			522,
			85,
			85
		}
	}
	self.C_Classics_H_Counterfeit_Crowd = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			609,
			609,
			85,
			85
		}
	}
	self.C_Classics_H_Counterfeit_CuttingTheRed = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			174,
			0,
			85,
			85
		}
	}
	self.C_Classics_H_Counterfeit_DrEvil = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			522,
			261,
			85,
			85
		}
	}
	self.C_Classics_H_FirstWorldBank_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			0,
			609,
			85,
			85
		}
	}
	self.C_Classics_H_FirstWorldBank_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			696,
			783,
			85,
			85
		}
	}
	self.C_Classics_H_FirstWorldBank_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			261,
			261,
			85,
			85
		}
	}
	self.C_Classics_H_FirstWorldBank_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			174,
			783,
			85,
			85
		}
	}
	self.C_Classics_H_FirstWorldBank_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			609,
			0,
			85,
			85
		}
	}
	self.C_Classics_H_FirstWorldBank_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			174,
			435,
			85,
			85
		}
	}
	self.C_Classics_H_FirstWorldBank_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			174,
			87,
			85,
			85
		}
	}
	self.C_Classics_H_FirstWorldBank_Au = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			783,
			261,
			85,
			85
		}
	}
	self.C_Classics_H_FirstWorldBank_Cloaker = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			348,
			522,
			85,
			85
		}
	}
	self.C_Classics_H_FirstWorldBank_Hidden = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			435,
			0,
			85,
			85
		}
	}
	self.C_Classics_H_FirstWorldBank_LEET = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			348,
			783,
			85,
			85
		}
	}
	self.C_Classics_H_FirstWorldBank_Original = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			435,
			261,
			85,
			85
		}
	}
	self.C_Classics_H_FirstWorldBank_Overdrill = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			87,
			87,
			85,
			85
		}
	}
	self.C_Classics_H_GreenBridge_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			870,
			783,
			85,
			85
		}
	}
	self.C_Classics_H_GreenBridge_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			0,
			783,
			85,
			85
		}
	}
	self.C_Classics_H_GreenBridge_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			348,
			0,
			85,
			85
		}
	}
	self.C_Classics_H_GreenBridge_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			174,
			348,
			85,
			85
		}
	}
	self.C_Classics_H_GreenBridge_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			783,
			435,
			85,
			85
		}
	}
	self.C_Classics_H_GreenBridge_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			0,
			87,
			85,
			85
		}
	}
	self.C_Classics_H_GreenBridge_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			261,
			87,
			85,
			85
		}
	}
	self.C_Classics_H_GreenBridge_BackToPrison = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			696,
			0,
			85,
			85
		}
	}
	self.C_Classics_H_GreenBridge_Caution = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			174,
			696,
			85,
			85
		}
	}
	self.C_Classics_H_GreenBridge_FeltBad = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			0,
			522,
			85,
			85
		}
	}
	self.C_Classics_H_HeatStreet_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			522,
			696,
			85,
			85
		}
	}
	self.C_Classics_H_HeatStreet_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			348,
			0,
			85,
			85
		}
	}
	self.C_Classics_H_HeatStreet_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			783,
			522,
			85,
			85
		}
	}
	self.C_Classics_H_HeatStreet_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			0,
			0,
			85,
			85
		}
	}
	self.C_Classics_H_HeatStreet_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			522,
			261,
			85,
			85
		}
	}
	self.C_Classics_H_HeatStreet_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			0,
			87,
			85,
			85
		}
	}
	self.C_Classics_H_HeatStreet_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			870,
			522,
			85,
			85
		}
	}
	self.C_Classics_H_HeatStreet_ItsNice = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			87,
			87,
			85,
			85
		}
	}
	self.C_Classics_H_HeatStreet_Patience = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			696,
			609,
			85,
			85
		}
	}
	self.C_Classics_H_HeatStreet_Zookeeper = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			870,
			870,
			85,
			85
		}
	}
	self.C_Classics_H_PanicRoom_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			87,
			522,
			85,
			85
		}
	}
	self.C_Classics_H_PanicRoom_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			609,
			87,
			85,
			85
		}
	}
	self.C_Classics_H_PanicRoom_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			0,
			174,
			85,
			85
		}
	}
	self.C_Classics_H_PanicRoom_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			435,
			0,
			85,
			85
		}
	}
	self.C_Classics_H_PanicRoom_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			609,
			261,
			85,
			85
		}
	}
	self.C_Classics_H_PanicRoom_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			609,
			0,
			85,
			85
		}
	}
	self.C_Classics_H_PanicRoom_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			348,
			435,
			85,
			85
		}
	}
	self.C_Classics_H_PanicRoom_Cardio = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			261,
			783,
			85,
			85
		}
	}
	self.C_Classics_H_PanicRoom_DontYouDare = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			435,
			522,
			85,
			85
		}
	}
	self.C_Classics_H_PanicRoom_TheDentist = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			87,
			696,
			85,
			85
		}
	}
	self.C_Classics_H_Slaughterhouse_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			696,
			87,
			85,
			85
		}
	}
	self.C_Classics_H_Slaughterhouse_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			261,
			261,
			85,
			85
		}
	}
	self.C_Classics_H_Slaughterhouse_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			870,
			87,
			85,
			85
		}
	}
	self.C_Classics_H_Slaughterhouse_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			522,
			522,
			85,
			85
		}
	}
	self.C_Classics_H_Slaughterhouse_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			174,
			696,
			85,
			85
		}
	}
	self.C_Classics_H_Slaughterhouse_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			783,
			696,
			85,
			85
		}
	}
	self.C_Classics_H_Slaughterhouse_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			870,
			609,
			85,
			85
		}
	}
	self.C_Classics_H_Slaughterhouse_ButHow = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			609,
			696,
			85,
			85
		}
	}
	self.C_Classics_H_Slaughterhouse_Making = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			870,
			783,
			85,
			85
		}
	}
	self.C_Classics_H_Slaughterhouse_NotHard = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			870,
			0,
			85,
			85
		}
	}
	self.C_Classics_H_Slaughterhouse_PorkRoyale = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			174,
			783,
			85,
			85
		}
	}
	self.C_Classics_H_Slaughterhouse_Pyromaniacs = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			261,
			261,
			85,
			85
		}
	}
	self.C_Classics_H_Undercover_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			87,
			609,
			85,
			85
		}
	}
	self.C_Classics_H_Undercover_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			348,
			174,
			85,
			85
		}
	}
	self.C_Classics_H_Undercover_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			261,
			609,
			85,
			85
		}
	}
	self.C_Classics_H_Undercover_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			261,
			0,
			85,
			85
		}
	}
	self.C_Classics_H_Undercover_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			435,
			870,
			85,
			85
		}
	}
	self.C_Classics_H_Undercover_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			783,
			609,
			85,
			85
		}
	}
	self.C_Classics_H_Undercover_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			522,
			870,
			85,
			85
		}
	}
	self.C_Classics_H_Undercover_BlowOut = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			87,
			174,
			85,
			85
		}
	}
	self.C_Classics_H_Undercover_KeepClear = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			783,
			0,
			85,
			85
		}
	}
	self.C_Classics_H_Undercover_NotEven = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			174,
			609,
			85,
			85
		}
	}
	self.C_Classics_H_Undercover_TheSaviour = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			435,
			522,
			85,
			85
		}
	}
	self.C_Continental_H_All_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			783,
			87,
			85,
			85
		}
	}
	self.C_Continental_H_All_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			435,
			261,
			85,
			85
		}
	}
	self.C_Continental_H_All_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			0,
			348,
			85,
			85
		}
	}
	self.C_Continental_H_All_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			261,
			696,
			85,
			85
		}
	}
	self.C_Continental_H_All_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			783,
			696,
			85,
			85
		}
	}
	self.C_Continental_H_All_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			87,
			435,
			85,
			85
		}
	}
	self.C_Continental_H_All_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			870,
			609,
			85,
			85
		}
	}
	self.C_Continental_H_Brooklyn_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			174,
			522,
			85,
			85
		}
	}
	self.C_Continental_H_Brooklyn_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			174,
			783,
			85,
			85
		}
	}
	self.C_Continental_H_Brooklyn_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			87,
			0,
			85,
			85
		}
	}
	self.C_Continental_H_Brooklyn_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			348,
			783,
			85,
			85
		}
	}
	self.C_Continental_H_Brooklyn_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			696,
			522,
			85,
			85
		}
	}
	self.C_Continental_H_Brooklyn_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			174,
			348,
			85,
			85
		}
	}
	self.C_Continental_H_Brooklyn_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			609,
			174,
			85,
			85
		}
	}
	self.C_Continental_H_Brooklyn_Apartment = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			261,
			783,
			85,
			85
		}
	}
	self.C_Continental_H_Brooklyn_ARendezvous = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			435,
			0,
			85,
			85
		}
	}
	self.C_Continental_H_Brooklyn_PassTheAmmo = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			87,
			522,
			85,
			85
		}
	}
	self.C_Continental_H_YachtHeist_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			696,
			348,
			85,
			85
		}
	}
	self.C_Continental_H_YachtHeist_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			435,
			261,
			85,
			85
		}
	}
	self.C_Continental_H_YachtHeist_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			174,
			261,
			85,
			85
		}
	}
	self.C_Continental_H_YachtHeist_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			870,
			609,
			85,
			85
		}
	}
	self.C_Continental_H_YachtHeist_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			174,
			348,
			85,
			85
		}
	}
	self.C_Continental_H_YachtHeist_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			696,
			174,
			85,
			85
		}
	}
	self.C_Continental_H_YachtHeist_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			174,
			348,
			85,
			85
		}
	}
	self.C_Continental_H_YachtHeist_Blood = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			609,
			870,
			85,
			85
		}
	}
	self.C_Continental_H_YachtHeist_Pacifish = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			348,
			87,
			85,
			85
		}
	}
	self.C_Continental_H_YachtHeist_Thalasso = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			870,
			174,
			85,
			85
		}
	}
	self.C_Dentist_H_All_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			0,
			435,
			85,
			85
		}
	}
	self.C_Dentist_H_All_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			348,
			174,
			85,
			85
		}
	}
	self.C_Dentist_H_All_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			348,
			609,
			85,
			85
		}
	}
	self.C_Dentist_H_All_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			696,
			348,
			85,
			85
		}
	}
	self.C_Dentist_H_All_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			0,
			87,
			85,
			85
		}
	}
	self.C_Dentist_H_All_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			696,
			174,
			85,
			85
		}
	}
	self.C_Dentist_H_All_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			87,
			174,
			85,
			85
		}
	}
	self.C_Dentist_H_BigBank_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			261,
			261,
			85,
			85
		}
	}
	self.C_Dentist_H_BigBank_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			87,
			696,
			85,
			85
		}
	}
	self.C_Dentist_H_BigBank_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			696,
			609,
			85,
			85
		}
	}
	self.C_Dentist_H_BigBank_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			261,
			696,
			85,
			85
		}
	}
	self.C_Dentist_H_BigBank_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			522,
			348,
			85,
			85
		}
	}
	self.C_Dentist_H_BigBank_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			0,
			435,
			85,
			85
		}
	}
	self.C_Dentist_H_BigBank_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			435,
			783,
			85,
			85
		}
	}
	self.C_Dentist_H_BigBank_Backing = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			0,
			174,
			85,
			85
		}
	}
	self.C_Dentist_H_BigBank_DontBring = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			696,
			87,
			85,
			85
		}
	}
	self.C_Dentist_H_BigBank_Entrapment = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			522,
			435,
			85,
			85
		}
	}
	self.C_Dentist_H_BigBank_ItTakesAPig = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			0,
			609,
			85,
			85
		}
	}
	self.C_Dentist_H_BigBank_ItTakesTwo = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			783,
			609,
			85,
			85
		}
	}
	self.C_Dentist_H_BigBank_SweetSixteen = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			0,
			0,
			85,
			85
		}
	}
	self.C_Dentist_H_BigBank_TwelveAngry = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			522,
			696,
			85,
			85
		}
	}
	self.C_Dentist_H_BigBank_YouOweMeOne = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			87,
			783,
			85,
			85
		}
	}
	self.C_Dentist_H_Diamond_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			174,
			435,
			85,
			85
		}
	}
	self.C_Dentist_H_Diamond_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			696,
			435,
			85,
			85
		}
	}
	self.C_Dentist_H_Diamond_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			348,
			522,
			85,
			85
		}
	}
	self.C_Dentist_H_Diamond_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			870,
			435,
			85,
			85
		}
	}
	self.C_Dentist_H_Diamond_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			174,
			174,
			85,
			85
		}
	}
	self.C_Dentist_H_Diamond_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			87,
			783,
			85,
			85
		}
	}
	self.C_Dentist_H_Diamond_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			870,
			348,
			85,
			85
		}
	}
	self.C_Dentist_H_Diamond_CatBurglar = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			261,
			348,
			85,
			85
		}
	}
	self.C_Dentist_H_Diamond_Culture = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			87,
			783,
			85,
			85
		}
	}
	self.C_Dentist_H_Diamond_Diamonds = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			783,
			435,
			85,
			85
		}
	}
	self.C_Dentist_H_Diamond_Honor = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			522,
			87,
			85,
			85
		}
	}
	self.C_Dentist_H_Diamond_Smoke = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			0,
			783,
			85,
			85
		}
	}
	self.C_Dentist_H_GoldenGrinCasino_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			783,
			783,
			85,
			85
		}
	}
	self.C_Dentist_H_GoldenGrinCasino_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			348,
			261,
			85,
			85
		}
	}
	self.C_Dentist_H_GoldenGrinCasino_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			87,
			609,
			85,
			85
		}
	}
	self.C_Dentist_H_GoldenGrinCasino_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			0,
			609,
			85,
			85
		}
	}
	self.C_Dentist_H_GoldenGrinCasino_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			870,
			870,
			85,
			85
		}
	}
	self.C_Dentist_H_GoldenGrinCasino_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			174,
			696,
			85,
			85
		}
	}
	self.C_Dentist_H_GoldenGrinCasino_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			348,
			870,
			85,
			85
		}
	}
	self.C_Dentist_H_GoldenGrinCasino_BlindEye = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			522,
			609,
			85,
			85
		}
	}
	self.C_Dentist_H_GoldenGrinCasino_CityofSin = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			783,
			0,
			85,
			85
		}
	}
	self.C_Dentist_H_GoldenGrinCasino_HailtotheKing = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			696,
			696,
			85,
			85
		}
	}
	self.C_Dentist_H_GoldenGrinCasino_HighRoller = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			870,
			0,
			85,
			85
		}
	}
	self.C_Dentist_H_HotlineMiami_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			609,
			783,
			85,
			85
		}
	}
	self.C_Dentist_H_HotlineMiami_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			696,
			174,
			85,
			85
		}
	}
	self.C_Dentist_H_HotlineMiami_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			348,
			348,
			85,
			85
		}
	}
	self.C_Dentist_H_HotlineMiami_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			261,
			870,
			85,
			85
		}
	}
	self.C_Dentist_H_HotlineMiami_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			174,
			0,
			85,
			85
		}
	}
	self.C_Dentist_H_HotlineMiami_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			522,
			783,
			85,
			85
		}
	}
	self.C_Dentist_H_HotlineMiami_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			609,
			435,
			85,
			85
		}
	}
	self.C_Dentist_H_HotlineMiami_DoYouLike = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			435,
			435,
			85,
			85
		}
	}
	self.C_Dentist_H_HotlineMiami_Overdose = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			696,
			87,
			85,
			85
		}
	}
	self.C_Dentist_H_HotlineMiami_Phew = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			522,
			522,
			85,
			85
		}
	}
	self.C_Dentist_H_HotlineMiami_SoundsofAnimals = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			0,
			261,
			85,
			85
		}
	}
	self.C_Dentist_H_HoxtonBreakout_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			348,
			261,
			85,
			85
		}
	}
	self.C_Dentist_H_HoxtonBreakout_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			87,
			435,
			85,
			85
		}
	}
	self.C_Dentist_H_HoxtonBreakout_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			348,
			87,
			85,
			85
		}
	}
	self.C_Dentist_H_HoxtonBreakout_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			522,
			696,
			85,
			85
		}
	}
	self.C_Dentist_H_HoxtonBreakout_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			522,
			0,
			85,
			85
		}
	}
	self.C_Dentist_H_HoxtonBreakout_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			435,
			522,
			85,
			85
		}
	}
	self.C_Dentist_H_HoxtonBreakout_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			696,
			0,
			85,
			85
		}
	}
	self.C_Dentist_H_HoxtonBreakout_SituationNormal = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			522,
			870,
			85,
			85
		}
	}
	self.C_Dentist_H_HoxtonBreakout_TabulaRasa = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			870,
			174,
			85,
			85
		}
	}
	self.C_Dentist_H_HotlineMiami_WalkFaster = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			435,
			522,
			85,
			85
		}
	}
	self.C_Dentist_H_HoxtonBreakout_Wind = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			609,
			696,
			85,
			85
		}
	}
	self.C_Dentist_H_HoxtonRevenge_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			870,
			261,
			85,
			85
		}
	}
	self.C_Dentist_H_HoxtonRevenge_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			435,
			435,
			85,
			85
		}
	}
	self.C_Dentist_H_HoxtonRevenge_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			174,
			696,
			85,
			85
		}
	}
	self.C_Dentist_H_HoxtonRevenge_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			174,
			87,
			85,
			85
		}
	}
	self.C_Dentist_H_HoxtonRevenge_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			348,
			696,
			85,
			85
		}
	}
	self.C_Dentist_H_HoxtonRevenge_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			435,
			174,
			85,
			85
		}
	}
	self.C_Dentist_H_HoxtonRevenge_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			87,
			435,
			85,
			85
		}
	}
	self.C_Dentist_H_HoxtonRevenge_Silent = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			609,
			261,
			85,
			85
		}
	}
	self.C_Elephant_H_All_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			0,
			174,
			85,
			85
		}
	}
	self.C_Elephant_H_All_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			522,
			174,
			85,
			85
		}
	}
	self.C_Elephant_H_All_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			609,
			870,
			85,
			85
		}
	}
	self.C_Elephant_H_All_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			870,
			522,
			85,
			85
		}
	}
	self.C_Elephant_H_All_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			696,
			870,
			85,
			85
		}
	}
	self.C_Elephant_H_All_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			348,
			435,
			85,
			85
		}
	}
	self.C_Elephant_H_All_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			435,
			87,
			85,
			85
		}
	}
	self.C_Elephant_H_BigOil_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			0,
			696,
			85,
			85
		}
	}
	self.C_Elephant_H_BigOil_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			87,
			609,
			85,
			85
		}
	}
	self.C_Elephant_H_BigOil_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			174,
			609,
			85,
			85
		}
	}
	self.C_Elephant_H_BigOil_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			609,
			261,
			85,
			85
		}
	}
	self.C_Elephant_H_BigOil_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			348,
			696,
			85,
			85
		}
	}
	self.C_Elephant_H_BigOil_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			261,
			0,
			85,
			85
		}
	}
	self.C_Elephant_H_BigOil_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			609,
			870,
			85,
			85
		}
	}
	self.C_Elephant_H_BigOil_BostonSaints = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			522,
			87,
			85,
			85
		}
	}
	self.C_Elephant_H_BigOil_DoctorFantastic = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			0,
			696,
			85,
			85
		}
	}
	self.C_Elephant_H_BigOil_DoctorMiserable = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			0,
			609,
			85,
			85
		}
	}
	self.C_Elephant_H_BigOil_HouseKeeping = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			174,
			174,
			85,
			85
		}
	}
	self.C_Elephant_H_BigOil_IKnewWhatIDid = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			435,
			696,
			85,
			85
		}
	}
	self.C_Elephant_H_Biker_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			870,
			0,
			85,
			85
		}
	}
	self.C_Elephant_H_Biker_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			435,
			348,
			85,
			85
		}
	}
	self.C_Elephant_H_Biker_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			174,
			609,
			85,
			85
		}
	}
	self.C_Elephant_H_Biker_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			348,
			87,
			85,
			85
		}
	}
	self.C_Elephant_H_Biker_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			522,
			783,
			85,
			85
		}
	}
	self.C_Elephant_H_Biker_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			522,
			174,
			85,
			85
		}
	}
	self.C_Elephant_H_Biker_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			522,
			696,
			85,
			85
		}
	}
	self.C_Elephant_H_Biker_EyeforanEye = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			435,
			696,
			85,
			85
		}
	}
	self.C_Elephant_H_Biker_FullThrottle = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			522,
			870,
			85,
			85
		}
	}
	self.C_Elephant_H_Biker_LetTheMan = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			0,
			174,
			85,
			85
		}
	}
	self.C_Elephant_H_Biker_Scavenger = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			0,
			0,
			85,
			85
		}
	}
	self.C_Elephant_H_ElectionDay_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			87,
			174,
			85,
			85
		}
	}
	self.C_Elephant_H_ElectionDay_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			783,
			261,
			85,
			85
		}
	}
	self.C_Elephant_H_ElectionDay_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			261,
			348,
			85,
			85
		}
	}
	self.C_Elephant_H_ElectionDay_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			783,
			261,
			85,
			85
		}
	}
	self.C_Elephant_H_ElectionDay_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			783,
			870,
			85,
			85
		}
	}
	self.C_Elephant_H_ElectionDay_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			0,
			870,
			85,
			85
		}
	}
	self.C_Elephant_H_ElectionDay_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			435,
			87,
			85,
			85
		}
	}
	self.C_Elephant_H_ElectionDay_DeathWishSwinger = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			783,
			609,
			85,
			85
		}
	}
	self.C_Elephant_H_ElectionDay_HotLava = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			696,
			522,
			85,
			85
		}
	}
	self.C_Elephant_H_ElectionDay_ImASwinger = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			609,
			348,
			85,
			85
		}
	}
	self.C_Elephant_H_ElectionDay_MasterDetective = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			870,
			261,
			85,
			85
		}
	}
	self.C_Elephant_H_ElectionDay_Murphy = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			0,
			174,
			85,
			85
		}
	}
	self.C_Elephant_H_ElectionDay_Reputation = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			261,
			87,
			85,
			85
		}
	}
	self.C_Elephant_H_ElectionDay_Speedlock = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			435,
			696,
			85,
			85
		}
	}
	self.C_Elephant_H_ElectionDay_StorageHunter = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			696,
			348,
			85,
			85
		}
	}
	self.C_Elephant_H_FramingFrame_Dark = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			174,
			696,
			85,
			85
		}
	}
	self.C_Elephant_H_FramingFrame_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			348,
			609,
			85,
			85
		}
	}
	self.C_Elephant_H_FramingFrame_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			609,
			783,
			85,
			85
		}
	}
	self.C_Elephant_H_FramingFrame_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			0,
			87,
			85,
			85
		}
	}
	self.C_Elephant_H_FramingFrame_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			609,
			87,
			85,
			85
		}
	}
	self.C_Elephant_H_FramingFrame_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			435,
			522,
			85,
			85
		}
	}
	self.C_Elephant_H_FramingFrame_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			87,
			870,
			85,
			85
		}
	}
	self.C_Elephant_H_FramingFrame_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			174,
			87,
			85,
			85
		}
	}
	self.C_Elephant_H_FramingFrame_BigDeal = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			609,
			261,
			85,
			85
		}
	}
	self.C_Elephant_H_FramingFrame_IWasnt = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			348,
			261,
			85,
			85
		}
	}
	self.C_Elephant_H_FramingFrame_PaintingYourself = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			522,
			783,
			85,
			85
		}
	}
	self.C_Elephant_H_FramingFrame_WeDoIt = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			609,
			609,
			85,
			85
		}
	}
	self.C_Escape_H_Cafe_Cappuccino = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			261,
			174,
			85,
			85
		}
	}
	self.C_Escape_H_Garage_TheySeeMe = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			261,
			435,
			85,
			85
		}
	}
	self.C_Escape_H_Overpass_YouShallNot = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			174,
			435,
			85,
			85
		}
	}
	self.C_Escape_H_Park_King = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			87,
			696,
			85,
			85
		}
	}
	self.C_Escape_H_Street_Bullet = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			783,
			609,
			85,
			85
		}
	}
	self.C_Event_H_All_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			174,
			174,
			85,
			85
		}
	}
	self.C_Event_H_All_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			0,
			348,
			85,
			85
		}
	}
	self.C_Event_H_All_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			609,
			522,
			85,
			85
		}
	}
	self.C_Event_H_All_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			348,
			783,
			85,
			85
		}
	}
	self.C_Event_H_All_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			174,
			87,
			85,
			85
		}
	}
	self.C_Event_H_All_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			174,
			609,
			85,
			85
		}
	}
	self.C_Event_H_All_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			435,
			174,
			85,
			85
		}
	}
	self.C_Event_H_LabRats_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			609,
			435,
			85,
			85
		}
	}
	self.C_Event_H_LabRats_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			609,
			870,
			85,
			85
		}
	}
	self.C_Event_H_LabRats_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			609,
			348,
			85,
			85
		}
	}
	self.C_Event_H_LabRats_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			435,
			696,
			85,
			85
		}
	}
	self.C_Event_H_LabRats_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			783,
			348,
			85,
			85
		}
	}
	self.C_Event_H_LabRats_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			435,
			870,
			85,
			85
		}
	}
	self.C_Event_H_LabRats_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			783,
			522,
			85,
			85
		}
	}
	self.C_Event_H_LabRats_Skill = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			174,
			174,
			85,
			85
		}
	}
	self.C_Event_H_LabRats_TrickorTreat = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			0,
			783,
			85,
			85
		}
	}
	self.C_Event_H_PrisonNightmare_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			174,
			522,
			85,
			85
		}
	}
	self.C_Event_H_PrisonNightmare_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			870,
			696,
			85,
			85
		}
	}
	self.C_Event_H_PrisonNightmare_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			435,
			696,
			85,
			85
		}
	}
	self.C_Event_H_PrisonNightmare_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			696,
			348,
			85,
			85
		}
	}
	self.C_Event_H_PrisonNightmare_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			609,
			696,
			85,
			85
		}
	}
	self.C_Event_H_PrisonNightmare_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			870,
			0,
			85,
			85
		}
	}
	self.C_Event_H_PrisonNightmare_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			87,
			0,
			85,
			85
		}
	}
	self.C_Event_H_PrisonNightmare_ALongNight = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			609,
			87,
			85,
			85
		}
	}
	self.C_Event_H_PrisonNightmare_HesGotExperience = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			870,
			261,
			85,
			85
		}
	}
	self.C_Event_H_PrisonNightmare_SalemAsylum = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			0,
			348,
			85,
			85
		}
	}
	self.C_Event_H_SafeHouseNightmare_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			261,
			609,
			85,
			85
		}
	}
	self.C_Event_H_SafeHouseNightmare_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			435,
			174,
			85,
			85
		}
	}
	self.C_Event_H_SafeHouseNightmare_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			609,
			783,
			85,
			85
		}
	}
	self.C_Event_H_SafeHouseNightmare_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			696,
			174,
			85,
			85
		}
	}
	self.C_Event_H_SafeHouseNightmare_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			87,
			522,
			85,
			85
		}
	}
	self.C_Event_H_SafeHouseNightmare_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			435,
			870,
			85,
			85
		}
	}
	self.C_Event_H_SafeHouseNightmare_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			87,
			87,
			85,
			85
		}
	}
	self.C_Hector_H_All_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			0,
			174,
			85,
			85
		}
	}
	self.C_Hector_H_All_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			870,
			435,
			85,
			85
		}
	}
	self.C_Hector_H_All_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			522,
			609,
			85,
			85
		}
	}
	self.C_Hector_H_All_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			870,
			348,
			85,
			85
		}
	}
	self.C_Hector_H_All_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			783,
			870,
			85,
			85
		}
	}
	self.C_Hector_H_All_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			174,
			870,
			85,
			85
		}
	}
	self.C_Hector_H_All_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			261,
			174,
			85,
			85
		}
	}
	self.C_Hector_H_Firestarter_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			261,
			435,
			85,
			85
		}
	}
	self.C_Hector_H_Firestarter_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			261,
			0,
			85,
			85
		}
	}
	self.C_Hector_H_Firestarter_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			696,
			348,
			85,
			85
		}
	}
	self.C_Hector_H_Firestarter_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			696,
			261,
			85,
			85
		}
	}
	self.C_Hector_H_Firestarter_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			348,
			435,
			85,
			85
		}
	}
	self.C_Hector_H_Firestarter_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			696,
			174,
			85,
			85
		}
	}
	self.C_Hector_H_Firestarter_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			348,
			609,
			85,
			85
		}
	}
	self.C_Hector_H_Firestarter_ForDaisy = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			696,
			0,
			85,
			85
		}
	}
	self.C_Hector_H_Firestarter_Guessing = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			435,
			609,
			85,
			85
		}
	}
	self.C_Hector_H_Firestarter_HereComesThePain = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			435,
			174,
			85,
			85
		}
	}
	self.C_Hector_H_Firestarter_ItsGettingHot = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			0,
			174,
			85,
			85
		}
	}
	self.C_Hector_H_Firestarter_Lord = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			348,
			348,
			85,
			85
		}
	}
	self.C_Hector_H_Firestarter_TheFirst = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			87,
			174,
			85,
			85
		}
	}
	self.C_Hector_H_Firestarter_Wasteful = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			0,
			87,
			85,
			85
		}
	}
	self.C_Hector_H_Firestarter_YouCanRun = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			870,
			87,
			85,
			85
		}
	}
	self.C_Hector_H_Rats_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			87,
			435,
			85,
			85
		}
	}
	self.C_Hector_H_Rats_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			783,
			174,
			85,
			85
		}
	}
	self.C_Hector_H_Rats_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			261,
			522,
			85,
			85
		}
	}
	self.C_Hector_H_Rats_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			522,
			174,
			85,
			85
		}
	}
	self.C_Hector_H_Rats_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			522,
			609,
			85,
			85
		}
	}
	self.C_Hector_H_Rats_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			435,
			174,
			85,
			85
		}
	}
	self.C_Hector_H_Rats_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			696,
			696,
			85,
			85
		}
	}
	self.C_Hector_H_Rats_Caribbean = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			174,
			0,
			85,
			85
		}
	}
	self.C_Hector_H_Rats_Cooking = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			870,
			696,
			85,
			85
		}
	}
	self.C_Hector_H_Rats_FinChem = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			609,
			174,
			85,
			85
		}
	}
	self.C_Hector_H_Rats_FourMonkeys = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			870,
			261,
			85,
			85
		}
	}
	self.C_Hector_H_Rats_FullMeasure = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			783,
			870,
			85,
			85
		}
	}
	self.C_Hector_H_Rats_IAmTheOne = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			435,
			0,
			85,
			85
		}
	}
	self.C_Hector_H_Rats_Short = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			783,
			174,
			85,
			85
		}
	}
	self.C_Hector_H_Watchdogs_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			261,
			783,
			85,
			85
		}
	}
	self.C_Hector_H_Watchdogs_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			0,
			522,
			85,
			85
		}
	}
	self.C_Hector_H_Watchdogs_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			261,
			174,
			85,
			85
		}
	}
	self.C_Hector_H_Watchdogs_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			0,
			348,
			85,
			85
		}
	}
	self.C_Hector_H_Watchdogs_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			261,
			0,
			85,
			85
		}
	}
	self.C_Hector_H_Watchdogs_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			435,
			609,
			85,
			85
		}
	}
	self.C_Hector_H_Watchdogs_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			870,
			435,
			85,
			85
		}
	}
	self.C_Hector_H_Watchdogs_Coming = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			174,
			435,
			85,
			85
		}
	}
	self.C_Hector_H_Watchdogs_Fish = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			435,
			783,
			85,
			85
		}
	}
	self.C_Hector_H_Watchdogs_Unusual = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			348,
			348,
			85,
			85
		}
	}
	self.C_Hector_H_Watchdogs_WeAreRockstars = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			261,
			609,
			85,
			85
		}
	}
	self.C_Hoxton_H_SafeHouse_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			87,
			261,
			85,
			85
		}
	}
	self.C_Hoxton_H_SafeHouse_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			609,
			87,
			85,
			85
		}
	}
	self.C_Hoxton_H_SafeHouse_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			696,
			783,
			85,
			85
		}
	}
	self.C_Hoxton_H_SafeHouse_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			522,
			174,
			85,
			85
		}
	}
	self.C_Hoxton_H_SafeHouse_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			87,
			87,
			85,
			85
		}
	}
	self.C_Hoxton_H_SafeHouse_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			87,
			696,
			85,
			85
		}
	}
	self.C_Hoxton_H_SafeHouse_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			435,
			348,
			85,
			85
		}
	}
	self.C_Hoxton_H_SafeHouse_Tip = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			696,
			261,
			85,
			85
		}
	}
	self.C_Jimmy_H_All_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			261,
			348,
			85,
			85
		}
	}
	self.C_Jimmy_H_All_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			696,
			870,
			85,
			85
		}
	}
	self.C_Jimmy_H_All_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			870,
			435,
			85,
			85
		}
	}
	self.C_Jimmy_H_All_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			348,
			435,
			85,
			85
		}
	}
	self.C_Jimmy_H_All_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			0,
			870,
			85,
			85
		}
	}
	self.C_Jimmy_H_All_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			87,
			0,
			85,
			85
		}
	}
	self.C_Jimmy_H_All_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			348,
			783,
			85,
			85
		}
	}
	self.C_Jimmy_H_Boiling_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			522,
			0,
			85,
			85
		}
	}
	self.C_Jimmy_H_Boiling_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			609,
			696,
			85,
			85
		}
	}
	self.C_Jimmy_H_Boiling_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			609,
			0,
			85,
			85
		}
	}
	self.C_Jimmy_H_Boiling_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			0,
			0,
			85,
			85
		}
	}
	self.C_Jimmy_H_Boiling_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			0,
			609,
			85,
			85
		}
	}
	self.C_Jimmy_H_Boiling_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			348,
			261,
			85,
			85
		}
	}
	self.C_Jimmy_H_Boiling_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			174,
			522,
			85,
			85
		}
	}
	self.C_Jimmy_H_Boiling_CrazyIvan = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			609,
			522,
			85,
			85
		}
	}
	self.C_Jimmy_H_Boiling_TheGround = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			261,
			870,
			85,
			85
		}
	}
	self.C_Jimmy_H_Boiling_UMPForMe = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			609,
			696,
			85,
			85
		}
	}
	self.C_Jimmy_H_Boiling_WhenInRussia = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			0,
			696,
			85,
			85
		}
	}
	self.C_Jimmy_H_MurkyStation_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			261,
			87,
			85,
			85
		}
	}
	self.C_Jimmy_H_MurkyStation_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			0,
			348,
			85,
			85
		}
	}
	self.C_Jimmy_H_MurkyStation_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			696,
			522,
			85,
			85
		}
	}
	self.C_Jimmy_H_MurkyStation_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			261,
			696,
			85,
			85
		}
	}
	self.C_Jimmy_H_MurkyStation_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			609,
			435,
			85,
			85
		}
	}
	self.C_Jimmy_H_MurkyStation_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			348,
			696,
			85,
			85
		}
	}
	self.C_Jimmy_H_MurkyStation_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			348,
			696,
			85,
			85
		}
	}
	self.C_Jimmy_H_MurkyStation_CrouchedandHidden = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			0,
			522,
			85,
			85
		}
	}
	self.C_Jimmy_H_MurkyStation_GhostRun = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			0,
			435,
			85,
			85
		}
	}
	self.C_Jimmy_H_MurkyStation_Janitor = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			522,
			522,
			85,
			85
		}
	}
	self.C_Jimmy_H_MurkyStation_Lootinh = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			696,
			435,
			85,
			85
		}
	}
	self.C_Jimmy_H_MurkyStation_NoWitnesses = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			0,
			696,
			85,
			85
		}
	}
	self.C_Jimmy_H_MurkyStation_ThePacifist = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			87,
			348,
			85,
			85
		}
	}
	self.C_Locke_H_All_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			696,
			609,
			85,
			85
		}
	}
	self.C_Locke_H_All_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			87,
			609,
			85,
			85
		}
	}
	self.C_Locke_H_All_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			174,
			870,
			85,
			85
		}
	}
	self.C_Locke_H_All_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			261,
			696,
			85,
			85
		}
	}
	self.C_Locke_H_All_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			522,
			87,
			85,
			85
		}
	}
	self.C_Locke_H_All_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			522,
			435,
			85,
			85
		}
	}
	self.C_Locke_H_All_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			435,
			870,
			85,
			85
		}
	}
	self.C_Locke_H_Beneath_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			0,
			870,
			85,
			85
		}
	}
	self.C_Locke_H_Beneath_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			174,
			783,
			85,
			85
		}
	}
	self.C_Locke_H_Beneath_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			696,
			0,
			85,
			85
		}
	}
	self.C_Locke_H_Beneath_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			435,
			348,
			85,
			85
		}
	}
	self.C_Locke_H_Beneath_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			0,
			522,
			85,
			85
		}
	}
	self.C_Locke_H_Beneath_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			870,
			783,
			85,
			85
		}
	}
	self.C_Locke_H_Beneath_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			87,
			522,
			85,
			85
		}
	}
	self.C_Locke_H_Beneath_Clean = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			609,
			609,
			85,
			85
		}
	}
	self.C_Locke_H_Beneath_Commando = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			609,
			522,
			85,
			85
		}
	}
	self.C_Locke_H_Beneath_Juggernauts = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			783,
			435,
			85,
			85
		}
	}
	self.C_Locke_H_BirthOfSky_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			174,
			435,
			85,
			85
		}
	}
	self.C_Locke_H_BirthOfSky_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			696,
			435,
			85,
			85
		}
	}
	self.C_Locke_H_BirthOfSky_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			522,
			348,
			85,
			85
		}
	}
	self.C_Locke_H_BirthOfSky_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			522,
			261,
			85,
			85
		}
	}
	self.C_Locke_H_BirthOfSky_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			261,
			522,
			85,
			85
		}
	}
	self.C_Locke_H_BirthOfSky_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			348,
			609,
			85,
			85
		}
	}
	self.C_Locke_H_BirthOfSky_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			87,
			783,
			85,
			85
		}
	}
	self.C_Locke_H_BirthOfSky_BlackTie = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			435,
			0,
			85,
			85
		}
	}
	self.C_Locke_H_BirthOfSky_Mellon = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			522,
			87,
			85,
			85
		}
	}
	self.C_Locke_H_BirthOfSky_NoBlood = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			696,
			609,
			85,
			85
		}
	}
	self.C_Locke_H_BirthOfSky_OneTwoThree = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			348,
			0,
			85,
			85
		}
	}
	self.C_Locke_H_BirthOfSky_Pinpoint = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			783,
			522,
			85,
			85
		}
	}
	self.C_Vlad_H_All_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			522,
			783,
			85,
			85
		}
	}
	self.C_Vlad_H_All_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			870,
			522,
			85,
			85
		}
	}
	self.C_Vlad_H_All_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			696,
			783,
			85,
			85
		}
	}
	self.C_Vlad_H_All_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			261,
			609,
			85,
			85
		}
	}
	self.C_Vlad_H_All_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			261,
			609,
			85,
			85
		}
	}
	self.C_Vlad_H_All_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			87,
			609,
			85,
			85
		}
	}
	self.C_Vlad_H_All_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			0,
			783,
			85,
			85
		}
	}
	self.C_Vlad_H_Ashock_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			783,
			0,
			85,
			85
		}
	}
	self.C_Vlad_H_Ashock_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			435,
			435,
			85,
			85
		}
	}
	self.C_Vlad_H_Ashock_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			87,
			609,
			85,
			85
		}
	}
	self.C_Vlad_H_Ashock_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			696,
			609,
			85,
			85
		}
	}
	self.C_Vlad_H_Ashock_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			435,
			783,
			85,
			85
		}
	}
	self.C_Vlad_H_Ashock_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			435,
			87,
			85,
			85
		}
	}
	self.C_Vlad_H_Ashock_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			261,
			174,
			85,
			85
		}
	}
	self.C_Vlad_H_Ashock_FourHundredBucks = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			696,
			261,
			85,
			85
		}
	}
	self.C_Vlad_H_FourStores_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			435,
			522,
			85,
			85
		}
	}
	self.C_Vlad_H_FourStores_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			783,
			87,
			85,
			85
		}
	}
	self.C_Vlad_H_FourStores_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			348,
			87,
			85,
			85
		}
	}
	self.C_Vlad_H_FourStores_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			0,
			609,
			85,
			85
		}
	}
	self.C_Vlad_H_FourStores_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			783,
			783,
			85,
			85
		}
	}
	self.C_Vlad_H_FourStores_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			87,
			696,
			85,
			85
		}
	}
	self.C_Vlad_H_FourStores_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			435,
			348,
			85,
			85
		}
	}
	self.C_Vlad_H_FourStores_YeahHe = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			261,
			261,
			85,
			85
		}
	}
	self.C_Vlad_H_GoatSim_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			87,
			0,
			85,
			85
		}
	}
	self.C_Vlad_H_GoatSim_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			696,
			522,
			85,
			85
		}
	}
	self.C_Vlad_H_GoatSim_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			435,
			783,
			85,
			85
		}
	}
	self.C_Vlad_H_GoatSim_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			0,
			261,
			85,
			85
		}
	}
	self.C_Vlad_H_GoatSim_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			435,
			261,
			85,
			85
		}
	}
	self.C_Vlad_H_GoatSim_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			522,
			435,
			85,
			85
		}
	}
	self.C_Vlad_H_GoatSim_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			609,
			261,
			85,
			85
		}
	}
	self.C_Vlad_H_GoatSim_Baaaa = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			435,
			609,
			85,
			85
		}
	}
	self.C_Vlad_H_GoatSim_FarmerMiserable = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			261,
			87,
			85,
			85
		}
	}
	self.C_Vlad_H_GoatSim_GoatIn = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			348,
			261,
			85,
			85
		}
	}
	self.C_Vlad_H_GoatSim_Hazzard = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			696,
			174,
			85,
			85
		}
	}
	self.C_Vlad_H_Mallcrasher_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			870,
			696,
			85,
			85
		}
	}
	self.C_Vlad_H_Mallcrasher_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			348,
			522,
			85,
			85
		}
	}
	self.C_Vlad_H_Mallcrasher_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			783,
			348,
			85,
			85
		}
	}
	self.C_Vlad_H_Mallcrasher_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			348,
			435,
			85,
			85
		}
	}
	self.C_Vlad_H_Mallcrasher_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			783,
			174,
			85,
			85
		}
	}
	self.C_Vlad_H_Mallcrasher_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			609,
			696,
			85,
			85
		}
	}
	self.C_Vlad_H_Mallcrasher_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			783,
			174,
			85,
			85
		}
	}
	self.C_Vlad_H_Mallcrasher_OnePointEight = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			87,
			348,
			85,
			85
		}
	}
	self.C_Vlad_H_Mallcrasher_Shoot = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			435,
			783,
			85,
			85
		}
	}
	self.C_Vlad_H_Meltdown_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			522,
			261,
			85,
			85
		}
	}
	self.C_Vlad_H_Meltdown_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			174,
			348,
			85,
			85
		}
	}
	self.C_Vlad_H_Meltdown_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			522,
			348,
			85,
			85
		}
	}
	self.C_Vlad_H_Meltdown_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			174,
			348,
			85,
			85
		}
	}
	self.C_Vlad_H_Meltdown_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			87,
			870,
			85,
			85
		}
	}
	self.C_Vlad_H_Meltdown_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			435,
			348,
			85,
			85
		}
	}
	self.C_Vlad_H_Meltdown_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			87,
			522,
			85,
			85
		}
	}
	self.C_Vlad_H_Meltdown_ThereWas = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			609,
			87,
			85,
			85
		}
	}
	self.C_Vlad_H_Meltdown_TheyDontPay = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			174,
			522,
			85,
			85
		}
	}
	self.C_Vlad_H_Nightclub_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			783,
			870,
			85,
			85
		}
	}
	self.C_Vlad_H_Nightclub_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			870,
			87,
			85,
			85
		}
	}
	self.C_Vlad_H_Nightclub_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			261,
			261,
			85,
			85
		}
	}
	self.C_Vlad_H_Nightclub_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			870,
			174,
			85,
			85
		}
	}
	self.C_Vlad_H_Nightclub_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			696,
			696,
			85,
			85
		}
	}
	self.C_Vlad_H_Nightclub_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			870,
			174,
			85,
			85
		}
	}
	self.C_Vlad_H_Nightclub_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			783,
			87,
			85,
			85
		}
	}
	self.C_Vlad_H_Nightclub_Everyday = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			348,
			783,
			85,
			85
		}
	}
	self.C_Vlad_H_Nightclub_HeyMr = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			87,
			174,
			85,
			85
		}
	}
	self.C_Vlad_H_Nightclub_ImGoing = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			174,
			435,
			85,
			85
		}
	}
	self.C_Vlad_H_Nightclub_KeeptheParty = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			348,
			870,
			85,
			85
		}
	}
	self.C_Vlad_H_Nightclub_OVESAW = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			870,
			870,
			85,
			85
		}
	}
	self.C_Vlad_H_Nightclub_TheEighth = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			609,
			174,
			85,
			85
		}
	}
	self.C_Vlad_H_Santa_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			609,
			696,
			85,
			85
		}
	}
	self.C_Vlad_H_Santa_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			87,
			261,
			85,
			85
		}
	}
	self.C_Vlad_H_Santa_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			435,
			609,
			85,
			85
		}
	}
	self.C_Vlad_H_Santa_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			174,
			870,
			85,
			85
		}
	}
	self.C_Vlad_H_Santa_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			696,
			0,
			85,
			85
		}
	}
	self.C_Vlad_H_Santa_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			348,
			348,
			85,
			85
		}
	}
	self.C_Vlad_H_Santa_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			174,
			870,
			85,
			85
		}
	}
	self.C_Vlad_H_Santa_EuroBag = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			261,
			609,
			85,
			85
		}
	}
	self.C_Vlad_H_Santa_OnlySanta = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			783,
			174,
			85,
			85
		}
	}
	self.C_Vlad_H_Santa_PumpedUp = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			522,
			783,
			85,
			85
		}
	}
	self.C_Vlad_H_Santa_SantaSlays = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			261,
			522,
			85,
			85
		}
	}
	self.C_Vlad_H_StealingXmas_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			696,
			87,
			85,
			85
		}
	}
	self.C_Vlad_H_StealingXmas_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			783,
			783,
			85,
			85
		}
	}
	self.C_Vlad_H_StealingXmas_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			261,
			870,
			85,
			85
		}
	}
	self.C_Vlad_H_StealingXmas_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			783,
			348,
			85,
			85
		}
	}
	self.C_Vlad_H_StealingXmas_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			261,
			609,
			85,
			85
		}
	}
	self.C_Vlad_H_StealingXmas_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			348,
			696,
			85,
			85
		}
	}
	self.C_Vlad_H_StealingXmas_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			435,
			870,
			85,
			85
		}
	}
	self.C_Vlad_H_StealingXmas_Christmas = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			261,
			87,
			85,
			85
		}
	}
	self.C_Vlad_H_StealingXmas_Grinch = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			261,
			435,
			85,
			85
		}
	}
	self.C_Vlad_H_StealingXmas_Imitations = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			348,
			87,
			85,
			85
		}
	}
	self.C_Vlad_H_Ukrainian_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			174,
			0,
			85,
			85
		}
	}
	self.C_Vlad_H_Ukrainian_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			0,
			348,
			85,
			85
		}
	}
	self.C_Vlad_H_Ukrainian_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			174,
			609,
			85,
			85
		}
	}
	self.C_Vlad_H_Ukrainian_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			87,
			609,
			85,
			85
		}
	}
	self.C_Vlad_H_Ukrainian_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			870,
			783,
			85,
			85
		}
	}
	self.C_Vlad_H_Ukrainian_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			696,
			435,
			85,
			85
		}
	}
	self.C_Vlad_H_Ukrainian_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			0,
			174,
			85,
			85
		}
	}
	self.C_Vlad_H_Ukrainian_LetsDoTh = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			609,
			870,
			85,
			85
		}
	}
	self.C_Vlad_H_XMas_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			609,
			870,
			85,
			85
		}
	}
	self.C_Vlad_H_XMas_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			261,
			0,
			85,
			85
		}
	}
	self.C_Vlad_H_XMas_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			522,
			435,
			85,
			85
		}
	}
	self.C_Vlad_H_XMas_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			0,
			435,
			85,
			85
		}
	}
	self.C_Vlad_H_XMas_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			783,
			696,
			85,
			85
		}
	}
	self.C_Vlad_H_XMas_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			261,
			783,
			85,
			85
		}
	}
	self.C_Vlad_H_XMas_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			348,
			174,
			85,
			85
		}
	}
	self.C_Vlad_H_XMas_Impossible = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			609,
			522,
			85,
			85
		}
	}
	self.C_Vlad_H_XMas_Riders = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			522,
			435,
			85,
			85
		}
	}
	self.Other_H_All_AllLevel005 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			696,
			0,
			85,
			85
		}
	}
	self.Other_H_All_AllLevel010 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			0,
			522,
			85,
			85
		}
	}
	self.Other_H_All_AllLevel025 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			783,
			783,
			85,
			85
		}
	}
	self.Other_H_All_AllLevel050 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			348,
			435,
			85,
			85
		}
	}
	self.Other_H_All_AllLevel075 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			348,
			87,
			85,
			85
		}
	}
	self.Other_H_All_AllLevel100 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			870,
			87,
			85,
			85
		}
	}
	self.Other_H_All_Infamy_01 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			348,
			696,
			85,
			85
		}
	}
	self.Other_H_All_Infamy_02 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			522,
			261,
			85,
			85
		}
	}
	self.Other_H_All_Infamy_03 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			0,
			87,
			85,
			85
		}
	}
	self.Other_H_All_Infamy_04 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			783,
			261,
			85,
			85
		}
	}
	self.Other_H_All_Infamy_05 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			696,
			783,
			85,
			85
		}
	}
	self.Other_H_All_Infamy_06 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			870,
			174,
			85,
			85
		}
	}
	self.Other_H_All_Infamy_07 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			87,
			696,
			85,
			85
		}
	}
	self.Other_H_All_Infamy_08 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			783,
			87,
			85,
			85
		}
	}
	self.Other_H_All_Infamy_09 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			522,
			522,
			85,
			85
		}
	}
	self.Other_H_All_Infamy_10 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			87,
			348,
			85,
			85
		}
	}
	self.Other_H_All_Infamy_11 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			870,
			348,
			85,
			85
		}
	}
	self.Other_H_All_Infamy_12 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			261,
			435,
			85,
			85
		}
	}
	self.Other_H_All_Infamy_13 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			522,
			87,
			85,
			85
		}
	}
	self.Other_H_All_Infamy_14 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			87,
			87,
			85,
			85
		}
	}
	self.Other_H_All_Infamy_15 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			0,
			696,
			85,
			85
		}
	}
	self.Other_H_All_Infamy_16 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			522,
			609,
			85,
			85
		}
	}
	self.Other_H_All_Infamy_17 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			696,
			783,
			85,
			85
		}
	}
	self.Other_H_All_Infamy_18 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			174,
			0,
			85,
			85
		}
	}
	self.Other_H_All_Infamy_19 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			0,
			261,
			85,
			85
		}
	}
	self.Other_H_All_Infamy_20 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			696,
			348,
			85,
			85
		}
	}
	self.Other_H_All_Infamy_21 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			609,
			783,
			85,
			85
		}
	}
	self.Other_H_All_Infamy_22 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			696,
			261,
			85,
			85
		}
	}
	self.Other_H_All_Infamy_23 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			261,
			522,
			85,
			85
		}
	}
	self.Other_H_All_Infamy_24 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			870,
			0,
			85,
			85
		}
	}
	self.Other_H_All_Infamy_25 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			783,
			783,
			85,
			85
		}
	}
	self.Other_H_Any_AboveTheLaw = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			609,
			348,
			85,
			85
		}
	}
	self.Other_H_Any_Affordable = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			696,
			870,
			85,
			85
		}
	}
	self.Other_H_Any_AreYouKidding = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			348,
			174,
			85,
			85
		}
	}
	self.Other_H_Any_Artillery = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			435,
			261,
			85,
			85
		}
	}
	self.Other_H_Any_ATaste = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			870,
			348,
			85,
			85
		}
	}
	self.Other_H_Any_Bang = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			87,
			174,
			85,
			85
		}
	}
	self.Other_H_Any_BigBadaBoom = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			0,
			261,
			85,
			85
		}
	}
	self.Other_H_Any_BlackKnight = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			522,
			783,
			85,
			85
		}
	}
	self.Other_H_Any_BringYourCop = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			609,
			609,
			85,
			85
		}
	}
	self.Other_H_Any_Bullet = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			783,
			0,
			85,
			85
		}
	}
	self.Other_H_Any_BullsEye = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			87,
			783,
			85,
			85
		}
	}
	self.Other_H_Any_Bunnyhopping = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			609,
			348,
			85,
			85
		}
	}
	self.Other_H_Any_Cavity = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			261,
			522,
			85,
			85
		}
	}
	self.Other_H_Any_CelsiusOr = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			348,
			522,
			85,
			85
		}
	}
	self.Other_H_Any_ClayPigeon = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			522,
			0,
			85,
			85
		}
	}
	self.Other_H_Any_Cloak = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			783,
			783,
			85,
			85
		}
	}
	self.Other_H_Any_Commando = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			870,
			696,
			85,
			85
		}
	}
	self.Other_H_Any_CrimeSpree050 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			870,
			696,
			85,
			85
		}
	}
	self.Other_H_Any_CrimeSpree100 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			522,
			783,
			85,
			85
		}
	}
	self.Other_H_Any_CrimeSpree250 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			609,
			174,
			85,
			85
		}
	}
	self.Other_H_Any_DeathFrom = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			609,
			522,
			85,
			85
		}
	}
	self.Other_H_Any_DidntSee = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			261,
			348,
			85,
			85
		}
	}
	self.Other_H_Any_DiscoInferno = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			870,
			435,
			85,
			85
		}
	}
	self.Other_H_Any_Dodge = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			870,
			0,
			85,
			85
		}
	}
	self.Other_H_Any_Dont = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			87,
			261,
			85,
			85
		}
	}
	self.Other_H_Any_DoubleKill = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			0,
			261,
			85,
			85
		}
	}
	self.Other_H_Any_Ducking = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			522,
			609,
			85,
			85
		}
	}
	self.Other_H_Any_EagleEyes = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			348,
			783,
			85,
			85
		}
	}
	self.Other_H_Any_FarFar = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			696,
			609,
			85,
			85
		}
	}
	self.Other_H_Any_FastestGun = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			522,
			348,
			85,
			85
		}
	}
	self.Other_H_Any_FireInTheHole = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			870,
			87,
			85,
			85
		}
	}
	self.Other_H_Any_FoolMe = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			261,
			870,
			85,
			85
		}
	}
	self.Other_H_Any_FromRussia = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			174,
			0,
			85,
			85
		}
	}
	self.Other_H_Any_Fugu = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			87,
			870,
			85,
			85
		}
	}
	self.Other_H_Any_GhostRiders = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			174,
			609,
			85,
			85
		}
	}
	self.Other_H_Any_Hammertime = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			87,
			87,
			85,
			85
		}
	}
	self.Other_H_Any_HardCorps = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			783,
			261,
			85,
			85
		}
	}
	self.Other_H_Any_Hedgehog = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			261,
			609,
			85,
			85
		}
	}
	self.Other_H_Any_Heisters = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			609,
			0,
			85,
			85
		}
	}
	self.Other_H_Any_Holy = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			783,
			174,
			85,
			85
		}
	}
	self.Other_H_Any_IAintGotTime = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			87,
			435,
			85,
			85
		}
	}
	self.Other_H_Any_IAmAn = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			348,
			435,
			85,
			85
		}
	}
	self.Other_H_Any_IDidNot = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			696,
			783,
			85,
			85
		}
	}
	self.Other_H_Any_IGotIt = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			870,
			261,
			85,
			85
		}
	}
	self.Other_H_Any_ImNot = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			261,
			435,
			85,
			85
		}
	}
	self.Other_H_Any_Inception = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			696,
			696,
			85,
			85
		}
	}
	self.Other_H_Any_INeverAsked = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			522,
			696,
			85,
			85
		}
	}
	self.Other_H_Any_InTown = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			174,
			261,
			85,
			85
		}
	}
	self.Other_H_Any_ItsAlive = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			522,
			870,
			85,
			85
		}
	}
	self.Other_H_Any_IWant = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			174,
			435,
			85,
			85
		}
	}
	self.Other_H_Any_JumpJump = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			174,
			522,
			85,
			85
		}
	}
	self.Other_H_Any_KillinsAsEasy = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			261,
			783,
			85,
			85
		}
	}
	self.Other_H_Any_KnockKnock = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			87,
			261,
			85,
			85
		}
	}
	self.Other_H_Any_Knockout = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			174,
			609,
			85,
			85
		}
	}
	self.Other_H_Any_LastAction = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			261,
			870,
			85,
			85
		}
	}
	self.Other_H_Any_LetThem = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			87,
			348,
			85,
			85
		}
	}
	self.Other_H_Any_License = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			261,
			696,
			85,
			85
		}
	}
	self.Other_H_Any_LikeABoy = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			609,
			87,
			85,
			85
		}
	}
	self.Other_H_Any_LockStock = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			261,
			348,
			85,
			85
		}
	}
	self.Other_H_Any_Maximum = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			522,
			609,
			85,
			85
		}
	}
	self.Other_H_Any_Megalo = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			783,
			87,
			85,
			85
		}
	}
	self.Other_H_Any_MySpiderSense = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			174,
			87,
			85,
			85
		}
	}
	self.Other_H_Any_NamesAreFor = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			870,
			435,
			85,
			85
		}
	}
	self.Other_H_Any_NoHeist = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			609,
			609,
			85,
			85
		}
	}
	self.Other_H_Any_NoOneCan = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			522,
			174,
			85,
			85
		}
	}
	self.Other_H_Any_NoOneCared = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			435,
			435,
			85,
			85
		}
	}
	self.Other_H_Any_NoScope = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			174,
			174,
			85,
			85
		}
	}
	self.Other_H_Any_Nothing = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			87,
			261,
			85,
			85
		}
	}
	self.Other_H_Any_NothingPersonal = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			348,
			783,
			85,
			85
		}
	}
	self.Other_H_Any_NotInvited = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			522,
			348,
			85,
			85
		}
	}
	self.Other_H_Any_NotToday = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			870,
			783,
			85,
			85
		}
	}
	self.Other_H_Any_OhThatsHow = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			174,
			870,
			85,
			85
		}
	}
	self.Other_H_Any_OneHoundredTwenty = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			174,
			174,
			85,
			85
		}
	}
	self.Other_H_Any_OVERGRILL = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			87,
			435,
			85,
			85
		}
	}
	self.Other_H_Any_Pink = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			174,
			783,
			85,
			85
		}
	}
	self.Other_H_Any_PoliceBrutality = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			261,
			174,
			85,
			85
		}
	}
	self.Other_H_Any_PrayingMantis = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			609,
			87,
			85,
			85
		}
	}
	self.Other_H_Any_Precision = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			696,
			261,
			85,
			85
		}
	}
	self.Other_H_Any_PublicEnemies = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			348,
			870,
			85,
			85
		}
	}
	self.Other_H_Any_PublicEnemy = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			783,
			348,
			85,
			85
		}
	}
	self.Other_H_Any_PumpAction = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			783,
			609,
			85,
			85
		}
	}
	self.Other_H_Any_Rabbit = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			435,
			870,
			85,
			85
		}
	}
	self.Other_H_Any_Recycling = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			870,
			522,
			85,
			85
		}
	}
	self.Other_H_Any_Reindeer = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			261,
			0,
			85,
			85
		}
	}
	self.Other_H_Any_SevenEleven = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			261,
			261,
			85,
			85
		}
	}
	self.Other_H_Any_ShareTheLove = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			0,
			348,
			85,
			85
		}
	}
	self.Other_H_Any_ShockAndAwe = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			87,
			348,
			85,
			85
		}
	}
	self.Other_H_Any_Shotgun = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			0,
			870,
			85,
			85
		}
	}
	self.Other_H_Any_Shuriken = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			348,
			609,
			85,
			85
		}
	}
	self.Other_H_Any_Sinper_Kills_050 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			435,
			522,
			85,
			85
		}
	}
	self.Other_H_Any_Sinper_Kills_100 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			522,
			435,
			85,
			85
		}
	}
	self.Other_H_Any_Sinper_Kills_250 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			0,
			783,
			85,
			85
		}
	}
	self.Other_H_Any_Sinper_Kills_500 = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			261,
			696,
			85,
			85
		}
	}
	self.Other_H_Any_Skewer = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			783,
			522,
			85,
			85
		}
	}
	self.Other_H_Any_SoMany = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			348,
			870,
			85,
			85
		}
	}
	self.Other_H_Any_SpecialOp = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			0,
			522,
			85,
			85
		}
	}
	self.Other_H_Any_StickAFork = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			0,
			696,
			85,
			85
		}
	}
	self.Other_H_Any_Surprise = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			174,
			87,
			85,
			85
		}
	}
	self.Other_H_Any_Swing = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			174,
			696,
			85,
			85
		}
	}
	self.Other_H_Any_Swiss = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			783,
			609,
			85,
			85
		}
	}
	self.Other_H_Any_TheCollector = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			522,
			174,
			85,
			85
		}
	}
	self.Other_H_Any_TheirArmor = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			870,
			435,
			85,
			85
		}
	}
	self.Other_H_Any_TheManWith = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			783,
			87,
			85,
			85
		}
	}
	self.Other_H_Any_TheNobel = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			522,
			522,
			85,
			85
		}
	}
	self.Other_H_Any_TheOneThatHad = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			870,
			609,
			85,
			85
		}
	}
	self.Other_H_Any_TheOneThatSur = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			783,
			348,
			85,
			85
		}
	}
	self.Other_H_Any_TheOneWho = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			696,
			435,
			85,
			85
		}
	}
	self.Other_H_Any_TheOnlyOne = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			522,
			696,
			85,
			85
		}
	}
	self.Other_H_Any_ThePumpkinKing = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			0,
			522,
			85,
			85
		}
	}
	self.Other_H_Any_ThereAndBack = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			435,
			435,
			85,
			85
		}
	}
	self.Other_H_Any_TheReconing = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			609,
			174,
			85,
			85
		}
	}
	self.Other_H_Any_TheyDrewFirst = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			783,
			696,
			85,
			85
		}
	}
	self.Other_H_Any_ThreeThousandMiles = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			522,
			696,
			85,
			85
		}
	}
	self.Other_H_Any_TourDeClarion = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			435,
			0,
			85,
			85
		}
	}
	self.Other_H_Any_TripleKill = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			609,
			696,
			85,
			85
		}
	}
	self.Other_H_Any_Wanted = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			348,
			609,
			85,
			85
		}
	}
	self.Other_H_Any_WitchDoctor = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			348,
			174,
			85,
			85
		}
	}
	self.Other_H_Any_YouCant = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			870,
			522,
			85,
			85
		}
	}
	self.Other_H_Any_FundingFather = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			348,
			696,
			85,
			85
		}
	}
	self.Other_H_None_Armed = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			696,
			0,
			85,
			85
		}
	}
	self.Other_H_None_ArmyofOne = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			435,
			696,
			85,
			85
		}
	}
	self.Other_H_None_AVote = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			174,
			870,
			85,
			85
		}
	}
	self.Other_H_None_BuildMe = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			87,
			609,
			85,
			85
		}
	}
	self.Other_H_None_ChristmasCame = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			87,
			435,
			85,
			85
		}
	}
	self.Other_H_None_FullyLoaded = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			609,
			435,
			85,
			85
		}
	}
	self.Other_H_None_GoingPlaces = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			348,
			870,
			85,
			85
		}
	}
	self.Other_H_None_GunsAreLike = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas8",
		texture_rect = {
			0,
			87,
			85,
			85
		}
	}
	self.Other_H_None_HaveNiceDay = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			609,
			174,
			85,
			85
		}
	}
	self.Other_H_None_Heat = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			0,
			609,
			85,
			85
		}
	}
	self.Other_H_None_HighSpeed = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			696,
			174,
			85,
			85
		}
	}
	self.Other_H_None_HowDoYou = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			174,
			261,
			85,
			85
		}
	}
	self.Other_H_None_ImAHealerTank = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			348,
			348,
			85,
			85
		}
	}
	self.Other_H_None_LikeAnAngry = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			783,
			435,
			85,
			85
		}
	}
	self.Other_H_None_MallNinja = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			435,
			87,
			85,
			85
		}
	}
	self.Other_H_None_ManOfIron = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			174,
			261,
			85,
			85
		}
	}
	self.Other_H_None_Masked = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			174,
			348,
			85,
			85
		}
	}
	self.Other_H_None_Merry = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			435,
			609,
			85,
			85
		}
	}
	self.Other_H_None_Point = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas2",
		texture_rect = {
			87,
			522,
			85,
			85
		}
	}
	self.Other_H_None_Russian = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			783,
			522,
			85,
			85
		}
	}
	self.Other_H_None_RussianArsenal = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas3",
		texture_rect = {
			870,
			348,
			85,
			85
		}
	}
	self.Other_H_None_SeakyBeaky = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas5",
		texture_rect = {
			783,
			261,
			85,
			85
		}
	}
	self.Other_H_None_SoUncivilized = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas4",
		texture_rect = {
			261,
			696,
			85,
			85
		}
	}
	self.Other_H_None_SpendMoney = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6",
		texture_rect = {
			609,
			0,
			85,
			85
		}
	}
	self.Other_H_None_SprayControl = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			870,
			87,
			85,
			85
		}
	}
	self.Other_H_None_Weapon = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			609,
			435,
			85,
			85
		}
	}
	self.Other_H_None_WithAnIron = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas",
		texture_rect = {
			174,
			522,
			85,
			85
		}
	}
	self.Other_H_None_WouldYouLike = {
		texture = "guis/dlcs/trk/textures/pd2/achievements_atlas7",
		texture_rect = {
			348,
			522,
			85,
			85
		}
	}

	self:create_grid_atlas("guis/dlcs/mom/textures/pd2/ai_abilities", 512, 512, 128, 128)

	self.ability_1 = self:create_next_icon("guis/dlcs/mom/textures/pd2/ai_abilities")
	self.ability_2 = self:create_next_icon("guis/dlcs/mom/textures/pd2/ai_abilities")
	self.ability_3 = self:create_next_icon("guis/dlcs/mom/textures/pd2/ai_abilities")
	self.ability_4 = self:create_next_icon("guis/dlcs/mom/textures/pd2/ai_abilities")

	self:create_grid_atlas("guis/dlcs/mom/textures/pd2/ai_skills", 512, 512, 128, 128)

	self.skill_1 = self:create_next_icon("guis/dlcs/mom/textures/pd2/ai_skills")
	self.skill_2 = self:create_next_icon("guis/dlcs/mom/textures/pd2/ai_skills")
	self.skill_3 = self:create_next_icon("guis/dlcs/mom/textures/pd2/ai_skills")
	self.skill_4 = self:create_next_icon("guis/dlcs/mom/textures/pd2/ai_skills")
	self.skill_5 = self:create_next_icon("guis/dlcs/mom/textures/pd2/ai_skills")
	self.skill_6 = self:create_next_icon("guis/dlcs/mom/textures/pd2/ai_skills")
	self.skill_7 = self:create_next_icon("guis/dlcs/mom/textures/pd2/ai_skills")
	self.skill_8 = self:create_next_icon("guis/dlcs/mom/textures/pd2/ai_skills")
	local sidebar_atlas = "guis/dlcs/new/textures/pd2/crimenet/crimenet_sidebar_icons"

	self:create_grid_atlas(sidebar_atlas, 256, 256, 64, 64)

	self.sidebar_mutators = self:create_next_icon(sidebar_atlas)
	self.sidebar_codex = self:create_next_icon(sidebar_atlas)
	self.sidebar_broker = self:create_next_icon(sidebar_atlas)
	self.sidebar_gage = self:create_next_icon(sidebar_atlas)
	self.sidebar_expand = self:create_next_icon(sidebar_atlas)
	self.sidebar_casino = self:create_next_icon(sidebar_atlas)
	self.sidebar_safehouse = self:create_next_icon(sidebar_atlas)
	self.sidebar_basics = self:create_next_icon(sidebar_atlas)
	self.sidebar_crimespree = self:create_next_icon(sidebar_atlas)
	self.sidebar_filters = self:create_next_icon(sidebar_atlas)
	self.sidebar_question = self:create_next_icon(sidebar_atlas)
	self.sidebar_skirmish = {
		texture = "guis/dlcs/skm/textures/pd2/crimenet/crimenet_sidebar_icon_skm",
		texture_rect = {
			0,
			0,
			64,
			64
		}
	}
	self.sidebar_side_jobs = {
		texture = "guis/dlcs/sju/textures/pd2/crimenet_sidebar_sidejobs",
		texture_rect = {
			0,
			0,
			64,
			64
		}
	}
	self.C_Locke_H_AlsDeal_AllDiffs_D0 = {
		texture = "guis/dlcs/wwh/textures/pd2/wwh_achievements_atlas",
		texture_rect = {
			87,
			0,
			85,
			85
		}
	}
	self.C_Locke_H_AlsDeal_AllDiffs_D1 = {
		texture = "guis/dlcs/wwh/textures/pd2/wwh_achievements_atlas",
		texture_rect = {
			174,
			87,
			85,
			85
		}
	}
	self.C_Locke_H_AlsDeal_AllDiffs_D2 = {
		texture = "guis/dlcs/wwh/textures/pd2/wwh_achievements_atlas",
		texture_rect = {
			174,
			0,
			85,
			85
		}
	}
	self.C_Locke_H_AlsDeal_AllDiffs_D3 = {
		texture = "guis/dlcs/wwh/textures/pd2/wwh_achievements_atlas",
		texture_rect = {
			261,
			87,
			85,
			85
		}
	}
	self.C_Locke_H_AlsDeal_AllDiffs_D4 = {
		texture = "guis/dlcs/wwh/textures/pd2/wwh_achievements_atlas",
		texture_rect = {
			261,
			0,
			85,
			85
		}
	}
	self.C_Locke_H_AlsDeal_AllDiffs_D5 = {
		texture = "guis/dlcs/wwh/textures/pd2/wwh_achievements_atlas",
		texture_rect = {
			348,
			87,
			85,
			85
		}
	}
	self.C_Locke_H_AlsDeal_AllDiffs_D6 = {
		texture = "guis/dlcs/wwh/textures/pd2/wwh_achievements_atlas",
		texture_rect = {
			348,
			0,
			85,
			85
		}
	}
	self.C_Locke_H_AlsDeal_HeadlessSnow = {
		texture = "guis/dlcs/wwh/textures/pd2/wwh_achievements_atlas",
		texture_rect = {
			87,
			87,
			85,
			85
		}
	}
	self.C_Locke_H_AlsDeal_TheFuelMust = {
		texture = "guis/dlcs/wwh/textures/pd2/wwh_achievements_atlas",
		texture_rect = {
			0,
			87,
			85,
			85
		}
	}
	self.C_Locke_H_AlsDeal_ThereWasRoom = {
		texture = "guis/dlcs/wwh/textures/pd2/wwh_achievements_atlas",
		texture_rect = {
			0,
			0,
			85,
			85
		}
	}
	self.C_Classics_H_DiamondHesit_AllDiffs_D0 = {
		texture = "guis/dlcs/dah/textures/pd2/achievements_atlas_dah",
		texture_rect = {
			0,
			0,
			85,
			85
		}
	}
	self.C_Classics_H_DiamondHesit_AllDiffs_D1 = {
		texture = "guis/dlcs/dah/textures/pd2/achievements_atlas_dah",
		texture_rect = {
			87,
			87,
			85,
			85
		}
	}
	self.C_Classics_H_DiamondHesit_AllDiffs_D2 = {
		texture = "guis/dlcs/dah/textures/pd2/achievements_atlas_dah",
		texture_rect = {
			87,
			0,
			85,
			85
		}
	}
	self.C_Classics_H_DiamondHesit_AllDiffs_D3 = {
		texture = "guis/dlcs/dah/textures/pd2/achievements_atlas_dah",
		texture_rect = {
			174,
			87,
			85,
			85
		}
	}
	self.C_Classics_H_DiamondHesit_AllDiffs_D4 = {
		texture = "guis/dlcs/dah/textures/pd2/achievements_atlas_dah",
		texture_rect = {
			174,
			0,
			85,
			85
		}
	}
	self.C_Classics_H_DiamondHesit_AllDiffs_D5 = {
		texture = "guis/dlcs/dah/textures/pd2/achievements_atlas_dah",
		texture_rect = {
			261,
			87,
			85,
			85
		}
	}
	self.C_Classics_H_DiamondHesit_AllDiffs_D6 = {
		texture = "guis/dlcs/dah/textures/pd2/achievements_atlas_dah",
		texture_rect = {
			261,
			0,
			85,
			85
		}
	}
	self.C_Classics_H_DiamondHesit_BloodDia = {
		texture = "guis/dlcs/dah/textures/pd2/achievements_atlas_dah",
		texture_rect = {
			0,
			87,
			85,
			85
		}
	}
	self.C_Classics_H_DiamondHesit_DeadChange = {
		texture = "guis/dlcs/dah/textures/pd2/achievements_atlas_dah",
		texture_rect = {
			348,
			0,
			85,
			85
		}
	}
	self.C_Classics_H_DiamondHesit_TheHuntfor = {
		texture = "guis/dlcs/dah/textures/pd2/achievements_atlas_dah",
		texture_rect = {
			348,
			87,
			85,
			85
		}
	}
	self.C_Bain_H_ReservoirDogs_AllDiffs_D0 = {
		texture = "guis/dlcs/rvd/textures/pd2/rvd_achievements_atlas",
		texture_rect = {
			89,
			263,
			85,
			85
		}
	}
	self.C_Bain_H_ReservoirDogs_AllDiffs_D1 = {
		texture = "guis/dlcs/rvd/textures/pd2/rvd_achievements_atlas",
		texture_rect = {
			176,
			350,
			85,
			85
		}
	}
	self.C_Bain_H_ReservoirDogs_AllDiffs_D2 = {
		texture = "guis/dlcs/rvd/textures/pd2/rvd_achievements_atlas",
		texture_rect = {
			2,
			89,
			85,
			85
		}
	}
	self.C_Bain_H_ReservoirDogs_AllDiffs_D3 = {
		texture = "guis/dlcs/rvd/textures/pd2/rvd_achievements_atlas",
		texture_rect = {
			89,
			176,
			85,
			85
		}
	}
	self.C_Bain_H_ReservoirDogs_AllDiffs_D4 = {
		texture = "guis/dlcs/rvd/textures/pd2/rvd_achievements_atlas",
		texture_rect = {
			176,
			263,
			85,
			85
		}
	}
	self.C_Bain_H_ReservoirDogs_AllDiffs_D5 = {
		texture = "guis/dlcs/rvd/textures/pd2/rvd_achievements_atlas",
		texture_rect = {
			263,
			350,
			85,
			85
		}
	}
	self.C_Bain_H_ReservoirDogs_AllDiffs_D6 = {
		texture = "guis/dlcs/rvd/textures/pd2/rvd_achievements_atlas",
		texture_rect = {
			2,
			2,
			85,
			85
		}
	}
	self.C_Bain_H_ReservoirDogs_United = {
		texture = "guis/dlcs/rvd/textures/pd2/rvd_achievements_atlas",
		texture_rect = {
			89,
			89,
			85,
			85
		}
	}
	self.C_Bain_H_ReservoirDogs_GetOffMy = {
		texture = "guis/dlcs/rvd/textures/pd2/rvd_achievements_atlas",
		texture_rect = {
			2,
			176,
			85,
			85
		}
	}
	self.C_Bain_H_ReservoirDogs_Pinky = {
		texture = "guis/dlcs/rvd/textures/pd2/rvd_achievements_atlas",
		texture_rect = {
			2,
			263,
			85,
			85
		}
	}
	self.C_Bain_H_ReservoirDogs_WasteNot = {
		texture = "guis/dlcs/rvd/textures/pd2/rvd_achievements_atlas",
		texture_rect = {
			2,
			350,
			85,
			85
		}
	}
	self.C_Bain_H_ReservoirDogs_CloseShave = {
		texture = "guis/dlcs/rvd/textures/pd2/rvd_achievements_atlas",
		texture_rect = {
			89,
			350,
			85,
			85
		}
	}
	self.C_Locke_H_BrooklynBank_AllDiffs_D0 = {
		texture = "guis/dlcs/brb/textures/pd2/achievements_atlas_brb",
		texture_rect = {
			350,
			2,
			85,
			85
		}
	}
	self.C_Locke_H_BrooklynBank_AllDiffs_D1 = {
		texture = "guis/dlcs/brb/textures/pd2/achievements_atlas_brb",
		texture_rect = {
			2,
			89,
			85,
			85
		}
	}
	self.C_Locke_H_BrooklynBank_AllDiffs_D2 = {
		texture = "guis/dlcs/brb/textures/pd2/achievements_atlas_brb",
		texture_rect = {
			2,
			2,
			85,
			85
		}
	}
	self.C_Locke_H_BrooklynBank_AllDiffs_D3 = {
		texture = "guis/dlcs/brb/textures/pd2/achievements_atlas_brb",
		texture_rect = {
			89,
			89,
			85,
			85
		}
	}
	self.C_Locke_H_BrooklynBank_AllDiffs_D4 = {
		texture = "guis/dlcs/brb/textures/pd2/achievements_atlas_brb",
		texture_rect = {
			89,
			2,
			85,
			85
		}
	}
	self.C_Locke_H_BrooklynBank_AllDiffs_D5 = {
		texture = "guis/dlcs/brb/textures/pd2/achievements_atlas_brb",
		texture_rect = {
			176,
			89,
			85,
			85
		}
	}
	self.C_Locke_H_BrooklynBank_AllDiffs_D6 = {
		texture = "guis/dlcs/brb/textures/pd2/achievements_atlas_brb",
		texture_rect = {
			176,
			2,
			85,
			85
		}
	}
	self.C_Locke_H_BrooklynBank_AlltheGold = {
		texture = "guis/dlcs/brb/textures/pd2/achievements_atlas_brb",
		texture_rect = {
			263,
			89,
			85,
			85
		}
	}
	self.C_Locke_H_BrooklynBank_AnimalKingdom = {
		texture = "guis/dlcs/brb/textures/pd2/achievements_atlas_brb",
		texture_rect = {
			350,
			89,
			85,
			85
		}
	}
	self.C_Locke_H_BrooklynBank_Obsessive = {
		texture = "guis/dlcs/brb/textures/pd2/achievements_atlas_brb",
		texture_rect = {
			263,
			2,
			85,
			85
		}
	}
	self.C_All_H_All_AllJobs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			2,
			611,
			85,
			85
		}
	}
	self.C_Bain_H_All_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			176,
			2,
			85,
			85
		}
	}
	self.C_Bain_H_BankR_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			89,
			785,
			85,
			85
		}
	}
	self.C_Bain_H_Car_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			89,
			872,
			85,
			85
		}
	}
	self.C_Bain_H_CookOff_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			89,
			263,
			85,
			85
		}
	}
	self.C_Bain_H_GOBank_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			89,
			350,
			85,
			85
		}
	}
	self.C_Bain_H_JewelryStore_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			2,
			698,
			85,
			85
		}
	}
	self.C_Bain_H_ReservoirDogs_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			2,
			176,
			85,
			85
		}
	}
	self.C_Bain_H_ShadowRaid_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			350,
			89,
			85,
			85
		}
	}
	self.C_Bain_H_TransportCrossroads_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			89,
			2,
			85,
			85
		}
	}
	self.C_Bain_H_TransportHarbor_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			176,
			176,
			85,
			85
		}
	}
	self.C_Bain_H_TransportPark_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			350,
			437,
			85,
			85
		}
	}
	self.C_Bain_H_TrainHeist_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			2,
			872,
			85,
			85
		}
	}
	self.C_Bain_H_TransportUnderpass_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			2,
			524,
			85,
			85
		}
	}
	self.C_Butcher_H_BombDock_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			263,
			437,
			85,
			85
		}
	}
	self.C_Butcher_H_Scarface_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			263,
			698,
			85,
			85
		}
	}
	self.C_Classics_H_All_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			89,
			698,
			85,
			85
		}
	}
	self.C_Classics_H_Counterfeit_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			89,
			611,
			85,
			85
		}
	}
	self.C_Classics_H_DiamondHesit_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			350,
			872,
			85,
			85
		}
	}
	self.C_Classics_H_FirstWorldBank_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			263,
			611,
			85,
			85
		}
	}
	self.C_Classics_H_GreenBridge_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			350,
			2,
			85,
			85
		}
	}
	self.C_Classics_H_HeatStreet_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			89,
			89,
			85,
			85
		}
	}
	self.C_Classics_H_Slaughterhouse_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			2,
			89,
			85,
			85
		}
	}
	self.C_Classics_H_Undercover_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			176,
			785,
			85,
			85
		}
	}
	self.C_Continental_H_All_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			350,
			698,
			85,
			85
		}
	}
	self.C_Continental_H_Brooklyn_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			2,
			437,
			85,
			85
		}
	}
	self.C_Continental_H_YachtHeist_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			89,
			176,
			85,
			85
		}
	}
	self.C_Dentist_H_All_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			350,
			350,
			85,
			85
		}
	}
	self.C_Dentist_H_BigBank_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			350,
			263,
			85,
			85
		}
	}
	self.C_Dentist_H_Diamond_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			350,
			611,
			85,
			85
		}
	}
	self.C_Dentist_H_GoldenGrinCasino_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			2,
			2,
			85,
			85
		}
	}
	self.C_Dentist_H_HotlineMiami_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			263,
			2,
			85,
			85
		}
	}
	self.C_Elephant_H_All_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			2,
			263,
			85,
			85
		}
	}
	self.C_Elephant_H_Biker_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			263,
			350,
			85,
			85
		}
	}
	self.C_Elephant_H_ElectionDay_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			176,
			698,
			85,
			85
		}
	}
	self.C_Event_H_All_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			176,
			872,
			85,
			85
		}
	}
	self.C_Event_H_LabRats_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			350,
			524,
			85,
			85
		}
	}
	self.C_Event_H_PrisonNightmare_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			263,
			524,
			85,
			85
		}
	}
	self.C_Event_H_SafeHouseNightmare_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			176,
			611,
			85,
			85
		}
	}
	self.C_Hector_H_All_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			89,
			524,
			85,
			85
		}
	}
	self.C_Hector_H_Firestarter_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			176,
			89,
			85,
			85
		}
	}
	self.C_Hector_H_Watchdogs_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			350,
			176,
			85,
			85
		}
	}
	self.C_Hoxton_H_SafeHouse_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			2,
			785,
			85,
			85
		}
	}
	self.C_Jimmy_H_MurkyStation_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			263,
			785,
			85,
			85
		}
	}
	self.C_Locke_H_All_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			263,
			89,
			85,
			85
		}
	}
	self.C_Locke_H_AlsDeal_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			350,
			785,
			85,
			85
		}
	}
	self.C_Locke_H_BirthOfSky_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			176,
			524,
			85,
			85
		}
	}
	self.C_Vlad_H_All_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			2,
			350,
			85,
			85
		}
	}
	self.C_Vlad_H_FourStores_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			263,
			176,
			85,
			85
		}
	}
	self.C_Vlad_H_Mallcrasher_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			176,
			350,
			85,
			85
		}
	}
	self.C_Vlad_H_Meltdown_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			263,
			263,
			85,
			85
		}
	}
	self.C_Vlad_H_Santa_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			89,
			437,
			85,
			85
		}
	}
	self.C_Vlad_H_StealingXmas_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			176,
			437,
			85,
			85
		}
	}
	self.C_Vlad_H_Ukrainian_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			263,
			872,
			85,
			85
		}
	}
	self.C_Vlad_H_XMas_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas",
		texture_rect = {
			176,
			263,
			85,
			85
		}
	}
	self.C_Bain_H_Arena_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas2",
		texture_rect = {
			2,
			2,
			85,
			85
		}
	}
	self.C_Bain_H_ArtGallery_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas2",
		texture_rect = {
			2,
			263,
			85,
			85
		}
	}
	self.C_Bain_H_BankC_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas2",
		texture_rect = {
			176,
			89,
			85,
			85
		}
	}
	self.C_Bain_H_BankD_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas2",
		texture_rect = {
			263,
			176,
			85,
			85
		}
	}
	self.C_Bain_H_BankG_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas2",
		texture_rect = {
			176,
			2,
			85,
			85
		}
	}
	self.C_Bain_H_DiamondStore_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas2",
		texture_rect = {
			263,
			263,
			85,
			85
		}
	}
	self.C_Bain_H_TransportDowntown_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas2",
		texture_rect = {
			89,
			89,
			85,
			85
		}
	}
	self.C_Butcher_H_All_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas2",
		texture_rect = {
			350,
			263,
			85,
			85
		}
	}
	self.C_Butcher_H_BombForest_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas2",
		texture_rect = {
			350,
			176,
			85,
			85
		}
	}
	self.C_Classics_H_PanicRoom_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas2",
		texture_rect = {
			2,
			176,
			85,
			85
		}
	}
	self.C_Dentist_H_HoxtonBreakout_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas2",
		texture_rect = {
			176,
			263,
			85,
			85
		}
	}
	self.C_Dentist_H_HoxtonRevenge_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas2",
		texture_rect = {
			2,
			350,
			85,
			85
		}
	}
	self.C_Elephant_H_BigOil_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas2",
		texture_rect = {
			263,
			350,
			85,
			85
		}
	}
	self.C_Elephant_H_FramingFrame_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas2",
		texture_rect = {
			2,
			89,
			85,
			85
		}
	}
	self.C_Hector_H_Rats_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas2",
		texture_rect = {
			176,
			176,
			85,
			85
		}
	}
	self.C_Jimmy_H_All_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas2",
		texture_rect = {
			176,
			350,
			85,
			85
		}
	}
	self.C_Jimmy_H_Boiling_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas2",
		texture_rect = {
			350,
			350,
			85,
			85
		}
	}
	self.C_Locke_H_Beneath_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas2",
		texture_rect = {
			263,
			89,
			85,
			85
		}
	}
	self.C_Locke_H_BrooklynBank_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas2",
		texture_rect = {
			89,
			350,
			85,
			85
		}
	}
	self.C_Vlad_H_Ashock_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas2",
		texture_rect = {
			89,
			176,
			85,
			85
		}
	}
	self.C_Vlad_H_GoatSim_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas2",
		texture_rect = {
			89,
			263,
			85,
			85
		}
	}
	self.C_Vlad_H_Nightclub_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ggez_achievements_atlas2",
		texture_rect = {
			89,
			2,
			85,
			85
		}
	}
	self.C_Event_H_CursedKillRoom_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/textures/pd2/ckr_achievements_atlas",
		texture_rect = {
			2,
			2,
			85,
			85
		}
	}
	self.C_Event_H_CursedKillRoom_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/textures/pd2/ckr_achievements_atlas",
		texture_rect = {
			89,
			89,
			85,
			85
		}
	}
	self.C_Event_H_CursedKillRoom_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/textures/pd2/ckr_achievements_atlas",
		texture_rect = {
			89,
			2,
			85,
			85
		}
	}
	self.C_Event_H_CursedKillRoom_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/textures/pd2/ckr_achievements_atlas",
		texture_rect = {
			176,
			89,
			85,
			85
		}
	}
	self.C_Event_H_CursedKillRoom_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/textures/pd2/ckr_achievements_atlas",
		texture_rect = {
			176,
			2,
			85,
			85
		}
	}
	self.C_Event_H_CursedKillRoom_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/textures/pd2/ckr_achievements_atlas",
		texture_rect = {
			263,
			89,
			85,
			85
		}
	}
	self.C_Event_H_CursedKillRoom_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ckr_achievements_atlas",
		texture_rect = {
			263,
			2,
			85,
			85
		}
	}
	self.C_Event_H_CursedKillRoom_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/textures/pd2/ckr_achievements_atlas",
		texture_rect = {
			2,
			89,
			85,
			85
		}
	}
	self.C_Event_H_SafeHouseNightmare_GiliamsSweet = {
		texture = "guis/dlcs/trk/textures/pd2/achievement_atlas_nbm",
		texture_rect = {
			89,
			2,
			85,
			85
		}
	}
	self.C_Event_H_SafeHouseNightmare_Temper = {
		texture = "guis/dlcs/trk/textures/pd2/achievement_atlas_nbm",
		texture_rect = {
			89,
			89,
			85,
			85
		}
	}
	self.C_Event_H_SafeHouseNightmare_CheerfulChild = {
		texture = "guis/dlcs/trk/textures/pd2/achievement_atlas_nbm",
		texture_rect = {
			2,
			2,
			85,
			85
		}
	}
	self.C_Event_H_SafeHouseNightmare_WaterWorks = {
		texture = "guis/dlcs/trk/textures/pd2/achievement_atlas_nbm",
		texture_rect = {
			2,
			89,
			85,
			85
		}
	}
	self.C_Bain_H_ArtGallery_Masterpiece = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			350,
			176,
			85,
			85
		}
	}
	self.C_Bain_H_ArtGallery_VanGogh = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			437,
			350,
			85,
			85
		}
	}
	self.C_Bain_H_ReservoirDogs_JustShutUP = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			176,
			263,
			85,
			85
		}
	}
	self.C_Bain_H_ReservoirDogs_Silver = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			2,
			263,
			85,
			85
		}
	}
	self.C_Bain_H_ShadowRaid_IWillSucceed = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			89,
			89,
			85,
			85
		}
	}
	self.C_Classics_H_FirstWorldBank_DownPayment = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			263,
			263,
			85,
			85
		}
	}
	self.C_Classics_H_Counterfeit_Why = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			350,
			263,
			85,
			85
		}
	}
	self.C_Classics_H_FirstWorldBank_Federal = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			524,
			263,
			85,
			85
		}
	}
	self.C_Classics_H_PanicRoom_QuickDraw = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			176,
			350,
			85,
			85
		}
	}
	self.C_Classics_H_Undercover_IFeelLike = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			437,
			176,
			85,
			85
		}
	}
	self.C_Dentist_H_BigBank_Matrix = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			2,
			350,
			85,
			85
		}
	}
	self.C_Dentist_H_GoldenGrinCasino_ItWasRigged = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			350,
			2,
			85,
			85
		}
	}
	self.C_Dentist_H_HoxtonBreakout_WatchThePower = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			524,
			89,
			85,
			85
		}
	}
	self.C_Elephant_H_BigOil_DamItBile = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			437,
			263,
			85,
			85
		}
	}
	self.C_Elephant_H_BigOil_Junkyard = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			263,
			89,
			85,
			85
		}
	}
	self.C_Event_H_CursedKillRoom_FasterFaster = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			176,
			89,
			85,
			85
		}
	}
	self.C_Event_H_CursedKillRoom_SayHello = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			437,
			89,
			85,
			85
		}
	}
	self.C_Hoxton_H_SafeHouse_Draganborn = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			698,
			350,
			85,
			85
		}
	}
	self.C_Hoxton_H_SafeHouse_TheRaid = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			611,
			263,
			85,
			85
		}
	}
	self.C_Jimmy_H_Boiling_Remember = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			2,
			2,
			85,
			85
		}
	}
	self.C_Locke_H_AlsDeal_GlobalWarming = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			611,
			176,
			85,
			85
		}
	}
	self.C_Locke_H_BirthOfSky_Expert = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			263,
			350,
			85,
			85
		}
	}
	self.C_Vlad_H_Ukrainian_ImSure = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			89,
			2,
			85,
			85
		}
	}
	self.Other_H_Any_ATazed = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			176,
			2,
			85,
			85
		}
	}
	self.Other_H_Any_C40 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			89,
			263,
			85,
			85
		}
	}
	self.Other_H_Any_CompactConf = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			89,
			350,
			85,
			85
		}
	}
	self.Other_H_Any_Denied = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			176,
			176,
			85,
			85
		}
	}
	self.Other_H_Any_DriveBy = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			263,
			2,
			85,
			85
		}
	}
	self.Other_H_Any_Hipster = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			350,
			89,
			85,
			85
		}
	}
	self.Other_H_Any_HumanSentry = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			437,
			2,
			85,
			85
		}
	}
	self.Other_H_Any_Lieutenant = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			524,
			350,
			85,
			85
		}
	}
	self.Other_H_Any_NoHardFeelings = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			263,
			176,
			85,
			85
		}
	}
	self.Other_H_Any_OneMan = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			2,
			89,
			85,
			85
		}
	}
	self.Other_H_Any_SnipeThis = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			350,
			350,
			85,
			85
		}
	}
	self.Other_H_Any_TheSafeWords = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			611,
			350,
			85,
			85
		}
	}
	self.Other_H_Any_Virus = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			89,
			176,
			85,
			85
		}
	}
	self.Other_H_Any_WULULU = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			2,
			176,
			85,
			85
		}
	}
	self.Other_H_NONE_GoldenGrin = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_cac",
		texture_rect = {
			524,
			176,
			85,
			85
		}
	}
	self.C_Locke_H_BreakinFeds_AMoment = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_tag",
		texture_rect = {
			2,
			2,
			85,
			85
		}
	}
	self.C_Locke_H_BreakinFeds_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_tag",
		texture_rect = {
			89,
			350,
			85,
			85
		}
	}
	self.C_Locke_H_BreakinFeds_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_tag",
		texture_rect = {
			2,
			176,
			85,
			85
		}
	}
	self.C_Locke_H_BreakinFeds_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_tag",
		texture_rect = {
			89,
			263,
			85,
			85
		}
	}
	self.C_Locke_H_BreakinFeds_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_tag",
		texture_rect = {
			176,
			350,
			85,
			85
		}
	}
	self.C_Locke_H_BreakinFeds_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_tag",
		texture_rect = {
			2,
			89,
			85,
			85
		}
	}
	self.C_Locke_H_BreakinFeds_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_tag",
		texture_rect = {
			89,
			176,
			85,
			85
		}
	}
	self.C_Locke_H_BreakinFeds_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_tag",
		texture_rect = {
			176,
			263,
			85,
			85
		}
	}
	self.C_Locke_H_BreakinFeds_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_tag",
		texture_rect = {
			2,
			263,
			85,
			85
		}
	}
	self.C_Locke_H_BreakinFeds_Salker = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_tag",
		texture_rect = {
			263,
			350,
			85,
			85
		}
	}
	self.C_Locke_H_BreakinFeds_Staple = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_tag",
		texture_rect = {
			2,
			350,
			85,
			85
		}
	}
	self.C_Locke_H_HenrysRock_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_des",
		texture_rect = {
			85,
			85,
			85,
			85
		}
	}
	self.C_Locke_H_HenrysRock_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_des",
		texture_rect = {
			170,
			170,
			85,
			85
		}
	}
	self.C_Locke_H_HenrysRock_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_des",
		texture_rect = {
			85,
			0,
			85,
			85
		}
	}
	self.C_Locke_H_HenrysRock_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_des",
		texture_rect = {
			170,
			85,
			85,
			85
		}
	}
	self.C_Locke_H_HenrysRock_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_des",
		texture_rect = {
			255,
			170,
			85,
			85
		}
	}
	self.C_Locke_H_HenrysRock_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_des",
		texture_rect = {
			170,
			0,
			85,
			85
		}
	}
	self.C_Locke_H_HenrysRock_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_des",
		texture_rect = {
			255,
			85,
			85,
			85
		}
	}
	self.C_Locke_H_HenrysRock_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_des",
		texture_rect = {
			0,
			170,
			85,
			85
		}
	}
	self.C_Locke_H_HenrysRock_BoomHead = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_des",
		texture_rect = {
			0,
			0,
			85,
			85
		}
	}
	self.C_Locke_H_HenrysRock_Hidden = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_des",
		texture_rect = {
			85,
			170,
			85,
			85
		}
	}
	self.C_Locke_H_HenrysRock_TheRedButt = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_des",
		texture_rect = {
			0,
			85,
			85,
			85
		}
	}
	self.C_Locke_H_Shacklethorne_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_sah",
		texture_rect = {
			2,
			263,
			85,
			85
		}
	}
	self.C_Locke_H_Shacklethorne_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_sah",
		texture_rect = {
			89,
			350,
			85,
			85
		}
	}
	self.C_Locke_H_Shacklethorne_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_sah",
		texture_rect = {
			2,
			176,
			85,
			85
		}
	}
	self.C_Locke_H_Shacklethorne_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_sah",
		texture_rect = {
			89,
			263,
			85,
			85
		}
	}
	self.C_Locke_H_Shacklethorne_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_sah",
		texture_rect = {
			176,
			350,
			85,
			85
		}
	}
	self.C_Locke_H_Shacklethorne_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_sah",
		texture_rect = {
			2,
			89,
			85,
			85
		}
	}
	self.C_Locke_H_Shacklethorne_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_sah",
		texture_rect = {
			89,
			176,
			85,
			85
		}
	}
	self.C_Locke_H_Shacklethorne_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_sah",
		texture_rect = {
			176,
			263,
			85,
			85
		}
	}
	self.C_Locke_H_Shacklethorne_AuctionCry = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_sah",
		texture_rect = {
			2,
			2,
			85,
			85
		}
	}
	self.C_Locke_H_Shacklethorne_HeavyMetal = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_sah",
		texture_rect = {
			2,
			350,
			85,
			85
		}
	}
	self.C_Locke_H_Shacklethorne_PressF = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_sah",
		texture_rect = {
			263,
			350,
			85,
			85
		}
	}
	self.C_Classics_H_NoMercy_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_nmh",
		texture_rect = {
			89,
			263,
			85,
			85
		}
	}
	self.C_Classics_H_NoMercy_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_nmh",
		texture_rect = {
			176,
			350,
			85,
			85
		}
	}
	self.C_Classics_H_NoMercy_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_nmh",
		texture_rect = {
			2,
			89,
			85,
			85
		}
	}
	self.C_Classics_H_NoMercy_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_nmh",
		texture_rect = {
			89,
			176,
			85,
			85
		}
	}
	self.C_Classics_H_NoMercy_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_nmh",
		texture_rect = {
			176,
			263,
			85,
			85
		}
	}
	self.C_Classics_H_NoMercy_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_nmh",
		texture_rect = {
			263,
			350,
			85,
			85
		}
	}
	self.C_Classics_H_NoMercy_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_nmh",
		texture_rect = {
			2,
			2,
			85,
			85
		}
	}
	self.C_Classics_H_NoMercy_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_nmh",
		texture_rect = {
			89,
			350,
			85,
			85
		}
	}
	self.C_Classics_H_NoMercy_KeepingTheCool = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_nmh",
		texture_rect = {
			2,
			176,
			85,
			85
		}
	}
	self.C_Classics_H_NoMercy_Nyctophobia = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_nmh",
		texture_rect = {
			2,
			263,
			85,
			85
		}
	}
	self.C_Classics_H_NoMercy_OrWasIt = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_nmh",
		texture_rect = {
			2,
			350,
			85,
			85
		}
	}
	self.C_Locke_H_HellsIsland_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_bph",
		texture_rect = {
			2,
			350,
			85,
			85
		}
	}
	self.C_Locke_H_HellsIsland_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_bph",
		texture_rect = {
			2,
			263,
			85,
			85
		}
	}
	self.C_Locke_H_HellsIsland_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_bph",
		texture_rect = {
			89,
			350,
			85,
			85
		}
	}
	self.C_Locke_H_HellsIsland_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_bph",
		texture_rect = {
			2,
			176,
			85,
			85
		}
	}
	self.C_Locke_H_HellsIsland_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_bph",
		texture_rect = {
			89,
			263,
			85,
			85
		}
	}
	self.C_Locke_H_HellsIsland_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_bph",
		texture_rect = {
			176,
			350,
			85,
			85
		}
	}
	self.C_Locke_H_HellsIsland_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_bph",
		texture_rect = {
			2,
			89,
			85,
			85
		}
	}
	self.C_Locke_H_HellsIsland_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_bph",
		texture_rect = {
			176,
			263,
			85,
			85
		}
	}
	self.C_Locke_H_HellsIsland_Another = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_bph",
		texture_rect = {
			263,
			350,
			85,
			85
		}
	}
	self.C_Locke_H_HellsIsland_Beacon = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_bph",
		texture_rect = {
			89,
			176,
			85,
			85
		}
	}
	self.C_Locke_H_HellsIsland_PrisonRules = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_bph",
		texture_rect = {
			2,
			2,
			85,
			85
		}
	}
	self.C_Locke_H_WhiteHouse_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_vit",
		texture_rect = {
			2,
			350,
			85,
			85
		}
	}
	self.C_Locke_H_WhiteHouse_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_vit",
		texture_rect = {
			2,
			263,
			85,
			85
		}
	}
	self.C_Locke_H_WhiteHouse_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_vit",
		texture_rect = {
			89,
			350,
			85,
			85
		}
	}
	self.C_Locke_H_WhiteHouse_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_vit",
		texture_rect = {
			2,
			176,
			85,
			85
		}
	}
	self.C_Locke_H_WhiteHouse_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_vit",
		texture_rect = {
			89,
			263,
			85,
			85
		}
	}
	self.C_Locke_H_WhiteHouse_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_vit",
		texture_rect = {
			176,
			350,
			85,
			85
		}
	}
	self.C_Locke_H_WhiteHouse_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_vit",
		texture_rect = {
			2,
			89,
			85,
			85
		}
	}
	self.C_Locke_H_WhiteHouse_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_vit",
		texture_rect = {
			89,
			176,
			85,
			85
		}
	}
	self.C_Locke_H_WhiteHouse_BigBrother = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_vit",
		texture_rect = {
			263,
			350,
			85,
			85
		}
	}
	self.C_Locke_H_WhiteHouse_HeistToRemember = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_vit",
		texture_rect = {
			176,
			263,
			85,
			85
		}
	}
	self.C_Locke_H_WhiteHouse_President = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_vit",
		texture_rect = {
			2,
			2,
			85,
			85
		}
	}
	self.C_Bain_H_BankVarious_AGoodHaul = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_uno",
		texture_rect = {
			263,
			89,
			85,
			85
		}
	}
	self.C_Bain_H_DiamondStore_Hostage = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_uno",
		texture_rect = {
			350,
			89,
			85,
			85
		}
	}
	self.C_Vlad_H_Mallcrasher_SelfCheck = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_uno",
		texture_rect = {
			2,
			2,
			85,
			85
		}
	}
	self.C_Butcher_H_Scarface_Setting = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_uno",
		texture_rect = {
			263,
			2,
			85,
			85
		}
	}
	self.C_Classics_H_GreenBridge_Attacked = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_uno",
		texture_rect = {
			176,
			2,
			85,
			85
		}
	}
	self.C_Hector_H_Watchdogs_OutOf = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_uno",
		texture_rect = {
			176,
			89,
			85,
			85
		}
	}
	self.C_Locke_H_HenrysRock_Hack = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_uno",
		texture_rect = {
			89,
			2,
			85,
			85
		}
	}
	self.C_Vlad_H_Nightclub_LetThem = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_uno",
		texture_rect = {
			2,
			89,
			85,
			85
		}
	}
	self.C_Vlad_H_XMas_Whats = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_uno",
		texture_rect = {
			89,
			89,
			85,
			85
		}
	}
	self.Other_The_End_Offshore_PAYDAY = {
		texture = "guis/dlcs/trk/atlases/fin_1",
		texture_rect = {
			0,
			0,
			85,
			85
		}
	}
	self.C_Locke_H_BorderCrossing_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_mex",
		texture_rect = {
			176,
			176,
			85,
			85
		}
	}
	self.C_Locke_H_BorderCrossing_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_mex",
		texture_rect = {
			263,
			263,
			85,
			85
		}
	}
	self.C_Locke_H_BorderCrossing_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_mex",
		texture_rect = {
			350,
			350,
			85,
			85
		}
	}
	self.C_Locke_H_BorderCrossing_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_mex",
		texture_rect = {
			89,
			2,
			85,
			85
		}
	}
	self.C_Locke_H_BorderCrossing_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_mex",
		texture_rect = {
			176,
			89,
			85,
			85
		}
	}
	self.C_Locke_H_BorderCrossing_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_mex",
		texture_rect = {
			263,
			176,
			85,
			85
		}
	}
	self.C_Locke_H_BorderCrossing_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_mex",
		texture_rect = {
			350,
			263,
			85,
			85
		}
	}
	self.C_Locke_H_BorderCrossing_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_mex",
		texture_rect = {
			176,
			263,
			85,
			85
		}
	}
	self.C_Locke_H_BorderCrossing_Identity = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_mex",
		texture_rect = {
			89,
			176,
			85,
			85
		}
	}
	self.C_Locke_H_BorderCrossing_TwoStep = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_mex",
		texture_rect = {
			2,
			2,
			85,
			85
		}
	}
	self.C_Locke_H_BorderCrystals_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_mex",
		texture_rect = {
			2,
			350,
			85,
			85
		}
	}
	self.C_Locke_H_BorderCrystals_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_mex",
		texture_rect = {
			2,
			263,
			85,
			85
		}
	}
	self.C_Locke_H_BorderCrystals_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_mex",
		texture_rect = {
			89,
			89,
			85,
			85
		}
	}
	self.C_Locke_H_BorderCrystals_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_mex",
		texture_rect = {
			2,
			176,
			85,
			85
		}
	}
	self.C_Locke_H_BorderCrystals_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_mex",
		texture_rect = {
			89,
			263,
			85,
			85
		}
	}
	self.C_Locke_H_BorderCrystals_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_mex",
		texture_rect = {
			176,
			350,
			85,
			85
		}
	}
	self.C_Locke_H_BorderCrystals_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_mex",
		texture_rect = {
			2,
			89,
			85,
			85
		}
	}
	self.C_Locke_H_BorderCrystals_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_mex",
		texture_rect = {
			263,
			350,
			85,
			85
		}
	}
	self.C_Locke_H_BorderCrystals_HeisterCocinero = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_mex",
		texture_rect = {
			89,
			350,
			85,
			85
		}
	}
	self.C_Vlad_H_SanMartinBank_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_bex",
		texture_rect = {
			89,
			176,
			85,
			85
		}
	}
	self.C_Vlad_H_SanMartinBank_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_bex",
		texture_rect = {
			176,
			263,
			85,
			85
		}
	}
	self.C_Vlad_H_SanMartinBank_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_bex",
		texture_rect = {
			263,
			350,
			85,
			85
		}
	}
	self.C_Vlad_H_SanMartinBank_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_bex",
		texture_rect = {
			2,
			2,
			85,
			85
		}
	}
	self.C_Vlad_H_SanMartinBank_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_bex",
		texture_rect = {
			2,
			350,
			85,
			85
		}
	}
	self.C_Vlad_H_SanMartinBank_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_bex",
		texture_rect = {
			2,
			263,
			85,
			85
		}
	}
	self.C_Vlad_H_SanMartinBank_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_bex",
		texture_rect = {
			89,
			350,
			85,
			85
		}
	}
	self.C_Vlad_H_SanMartinBank_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_bex",
		texture_rect = {
			176,
			350,
			85,
			85
		}
	}
	self.C_Vlad_H_SanMartinBank_Silencioso = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_bex",
		texture_rect = {
			89,
			263,
			85,
			85
		}
	}
	self.C_Vlad_H_SanMartinBank_Gunpowder = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_bex",
		texture_rect = {
			2,
			89,
			85,
			85
		}
	}
	self.C_Vlad_H_SanMartinBank_HitMe = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_bex",
		texture_rect = {
			2,
			176,
			85,
			85
		}
	}
	self.C_Locke_H_BreakfastInTijuana_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_pex",
		texture_rect = {
			176,
			263,
			85,
			85
		}
	}
	self.C_Locke_H_BreakfastInTijuana_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_pex",
		texture_rect = {
			89,
			350,
			85,
			85
		}
	}
	self.C_Locke_H_BreakfastInTijuana_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_pex",
		texture_rect = {
			2,
			176,
			85,
			85
		}
	}
	self.C_Locke_H_BreakfastInTijuana_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_pex",
		texture_rect = {
			89,
			263,
			85,
			85
		}
	}
	self.C_Locke_H_BreakfastInTijuana_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_pex",
		texture_rect = {
			176,
			350,
			85,
			85
		}
	}
	self.C_Locke_H_BreakfastInTijuana_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_pex",
		texture_rect = {
			2,
			89,
			85,
			85
		}
	}
	self.C_Locke_H_BreakfastInTijuana_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_pex",
		texture_rect = {
			89,
			176,
			85,
			85
		}
	}
	self.C_Locke_H_BreakfastInTijuana_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_pex",
		texture_rect = {
			263,
			350,
			85,
			85
		}
	}
	self.C_Locke_H_BreakfastInTijuana_LowMurder = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_pex",
		texture_rect = {
			2,
			350,
			85,
			85
		}
	}
	self.C_Locke_H_BreakfastInTijuana_PaidInFull = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_pex",
		texture_rect = {
			2,
			263,
			85,
			85
		}
	}
	self.C_Locke_H_BreakfastInTijuana_StolenValor = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_pex",
		texture_rect = {
			2,
			2,
			85,
			85
		}
	}
	self.C_Vlad_H_BulocsMansion_AllDiffs_D0 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_fex",
		texture_rect = {
			89,
			350,
			85,
			85
		}
	}
	self.C_Vlad_H_BulocsMansion_AllDiffs_D1 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_fex",
		texture_rect = {
			2,
			176,
			85,
			85
		}
	}
	self.C_Vlad_H_BulocsMansion_AllDiffs_D2 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_fex",
		texture_rect = {
			89,
			263,
			85,
			85
		}
	}
	self.C_Vlad_H_BulocsMansion_AllDiffs_D3 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_fex",
		texture_rect = {
			176,
			350,
			85,
			85
		}
	}
	self.C_Vlad_H_BulocsMansion_AllDiffs_D4 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_fex",
		texture_rect = {
			2,
			89,
			85,
			85
		}
	}
	self.C_Vlad_H_BulocsMansion_AllDiffs_D5 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_fex",
		texture_rect = {
			89,
			176,
			85,
			85
		}
	}
	self.C_Vlad_H_BulocsMansion_AllDiffs_D6 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_fex",
		texture_rect = {
			176,
			263,
			85,
			85
		}
	}
	self.C_Vlad_H_BulocsMansion_AllDiffs_OD_D6 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_fex",
		texture_rect = {
			2,
			2,
			85,
			85
		}
	}
	self.C_Vlad_H_BulocsMansion_Everything = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_fex",
		texture_rect = {
			2,
			263,
			85,
			85
		}
	}
	self.C_Vlad_H_BulocsMansion_Sugar = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_fex",
		texture_rect = {
			2,
			350,
			85,
			85
		}
	}
	self.C_Vlad_H_BulocsMansion_WeExpect = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_fex",
		texture_rect = {
			263,
			350,
			85,
			85
		}
	}
	self.C_Bain_H_Arena_Holdout_3 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			89,
			176,
			85,
			85
		}
	}
	self.C_Bain_H_Arena_Holdout_5 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			176,
			263,
			85,
			85
		}
	}
	self.C_Bain_H_Arena_Holdout_7 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			2,
			2,
			85,
			85
		}
	}
	self.C_Bain_H_Arena_Holdout_9 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			176,
			176,
			85,
			85
		}
	}
	self.C_Classics_H_FirstWorldBank_Holdout_3 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			698,
			263,
			85,
			85
		}
	}
	self.C_Classics_H_FirstWorldBank_Holdout_5 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			785,
			350,
			85,
			85
		}
	}
	self.C_Classics_H_FirstWorldBank_Holdout_7 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			2,
			350,
			85,
			85
		}
	}
	self.C_Classics_H_FirstWorldBank_Holdout_9 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			2,
			263,
			85,
			85
		}
	}
	self.C_Classics_H_HeatStreet_Holdout_3 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			350,
			350,
			85,
			85
		}
	}
	self.C_Classics_H_HeatStreet_Holdout_5 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			350,
			2,
			85,
			85
		}
	}
	self.C_Classics_H_HeatStreet_Holdout_7 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			524,
			176,
			85,
			85
		}
	}
	self.C_Classics_H_HeatStreet_Holdout_9 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			698,
			350,
			85,
			85
		}
	}
	self.C_Dentist_H_BigBank_Holdout_3 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			611,
			350,
			85,
			85
		}
	}
	self.C_Dentist_H_BigBank_Holdout_5 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			437,
			89,
			85,
			85
		}
	}
	self.C_Dentist_H_BigBank_Holdout_7 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			611,
			263,
			85,
			85
		}
	}
	self.C_Dentist_H_BigBank_Holdout_9 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			437,
			2,
			85,
			85
		}
	}
	self.C_Dentist_H_Diamond_Holdout_3 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			263,
			89,
			85,
			85
		}
	}
	self.C_Dentist_H_Diamond_Holdout_5 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			437,
			263,
			85,
			85
		}
	}
	self.C_Dentist_H_Diamond_Holdout_7 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			263,
			2,
			85,
			85
		}
	}
	self.C_Dentist_H_Diamond_Holdout_9 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			437,
			176,
			85,
			85
		}
	}
	self.C_Dentist_H_GoldenGrinCasino_Holdout_3 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			176,
			89,
			85,
			85
		}
	}
	self.C_Dentist_H_GoldenGrinCasino_Holdout_5 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			350,
			263,
			85,
			85
		}
	}
	self.C_Dentist_H_GoldenGrinCasino_Holdout_7 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			176,
			2,
			85,
			85
		}
	}
	self.C_Dentist_H_GoldenGrinCasino_Holdout_9 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			89,
			350,
			85,
			85
		}
	}
	self.C_Hector_H_Watchdogs_Holdout_3 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			263,
			176,
			85,
			85
		}
	}
	self.C_Hector_H_Watchdogs_Holdout_5 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			437,
			350,
			85,
			85
		}
	}
	self.C_Hector_H_Watchdogs_Holdout_7 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			2,
			176,
			85,
			85
		}
	}
	self.C_Hector_H_Watchdogs_Holdout_9 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			89,
			263,
			85,
			85
		}
	}
	self.C_Vlad_H_Mallcrasher_Holdout_3 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			524,
			89,
			85,
			85
		}
	}
	self.C_Vlad_H_Mallcrasher_Holdout_5 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			263,
			350,
			85,
			85
		}
	}
	self.C_Vlad_H_Mallcrasher_Holdout_7 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			2,
			89,
			85,
			85
		}
	}
	self.C_Vlad_H_Mallcrasher_Holdout_9 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			176,
			350,
			85,
			85
		}
	}
	self.C_Vlad_H_SanMartinBank_Holdout_3 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			89,
			89,
			85,
			85
		}
	}
	self.C_Vlad_H_SanMartinBank_Holdout_5 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			263,
			263,
			85,
			85
		}
	}
	self.C_Vlad_H_SanMartinBank_Holdout_7 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			611,
			176,
			85,
			85
		}
	}
	self.C_Vlad_H_SanMartinBank_Holdout_9 = {
		texture = "guis/dlcs/trk/atlases/achievement_atlas_shl",
		texture_rect = {
			89,
			2,
			85,
			85
		}
	}
	self.Other_H_All_Infamy_50 = {
		texture = "guis/dlcs/trk/atlases/inf_achievement",
		texture_rect = {
			89,
			2,
			85,
			85
		}
	}
	self.Other_H_All_Infamy_75 = {
		texture = "guis/dlcs/trk/atlases/inf_achievement",
		texture_rect = {
			176,
			2,
			85,
			85
		}
	}
	self.Other_H_All_Infamy_C = {
		texture = "guis/dlcs/trk/atlases/inf_achievement",
		texture_rect = {
			2,
			2,
			85,
			85
		}
	}

	TextureCorrectionTweakData:new(self)

	self.milestone_trophy = {
		texture = "guis/dlcs/ami/textures/pd2/milestone_trophy_icon",
		texture_rect = {
			0,
			0,
			128,
			128
		}
	}
end

local atlas_data = nil

function HudIconsTweakData:create_grid_atlas(image_name, tex_w, tex_h, grid_w, grid_h)
	atlas_data = atlas_data or {}
	atlas_data[image_name] = {
		y = 0,
		x = 0,
		tex_w = tex_w,
		tex_h = tex_h,
		grid_w = grid_w,
		grid_h = grid_h
	}
end

function HudIconsTweakData:create_next_icon(image_name)
	local data = atlas_data[image_name]

	assert(data, "No atlas definition found. Use create_grid_atlas(or potentially some other create atlas function) first!")
	assert(data.y < data.tex_h, "Atlas already full!")

	local rtn = {
		texture = image_name,
		texture_rect = {
			data.x,
			data.y,
			data.grid_w,
			data.grid_h
		}
	}
	data.x = data.x + data.grid_w

	if data.tex_w <= data.x then
		data.x = 0
		data.y = data.y + data.grid_h
	end

	return rtn
end

function HudIconsTweakData:get_icon_data(icon_id, default_rect)
	local icon_data = self[icon_id]
	local icon = icon_data and icon_data.texture or icon_id
	local texture_rect = icon_data and icon_data.texture_rect or default_rect or {
		0,
		0,
		48,
		48
	}

	return icon, texture_rect
end

function HudIconsTweakData:get_icon_or(icon_id, ...)
	local icon_data = self[icon_id]

	if not icon_data then
		return ...
	end

	return icon_data.texture, icon_data.texture_rect
end

function HudIconsTweakData:get_texture(texture_path)
	local icon_data = self[texture_path]

	if not icon_data then
		return texture_path
	end

	return icon_data.texture, icon_data.texture_rect
end
