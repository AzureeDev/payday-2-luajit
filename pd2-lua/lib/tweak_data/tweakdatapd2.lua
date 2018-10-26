
function TweakData:_init_pd2()
	print("TweakData:_init_pd2()")

	self.hud_players = {
		name_font = "fonts/font_small_mf",
		name_size = 19,
		ammo_font = "fonts/font_large_mf",
		ammo_size = 24,
		timer_font = "fonts/font_medium_shadow_mf",
		timer_size = 30,
		timer_flash_size = 50
	}
	self.hud_present = {
		title_font = "fonts/font_medium_mf",
		title_size = 28,
		text_font = "fonts/font_medium_mf",
		text_size = 28
	}
	self.hud_mask_off = {
		text_size = 28,
		text_font = "fonts/font_medium_mf"
	}
	self.hud_stats = {
		objectives_font = "fonts/font_medium_mf",
		objective_desc_font = "fonts/font_medium_mf",
		objectives_title_size = 28,
		objectives_size = 24,
		loot_size = 24,
		loot_title_size = 28,
		day_description_size = 22,
		potential_xp_color = Color(0, 0.6666666666666666, 1)
	}
	self.hud_corner = {
		assault_font = "fonts/font_medium_mf",
		assault_size = 24,
		noreturn_size = 24,
		numhostages_size = 24
	}
	self.hud_downed = {timer_message_size = 24}
	self.hud_custody = {
		custody_font = "fonts/font_medium_mf",
		custody_font_large = "fonts/font_large_mf",
		font_size = 28,
		small_font_size = 24
	}
	self.hud_icons.bag_icon = {
		texture = "guis/textures/pd2/hud_tabs",
		texture_rect = {
			2,
			34,
			20,
			17
		}
	}
	self.hud_icons.pd2_mask_1 = {
		texture = "guis/textures/pd2/masks",
		texture_rect = {
			0,
			0,
			64,
			64
		}
	}
	self.hud_icons.pd2_mask_2 = {
		texture = "guis/textures/pd2/masks",
		texture_rect = {
			64,
			0,
			64,
			64
		}
	}
	self.hud_icons.pd2_mask_3 = {
		texture = "guis/textures/pd2/masks",
		texture_rect = {
			64,
			64,
			64,
			64
		}
	}
	self.hud_icons.pd2_mask_4 = {
		texture = "guis/textures/pd2/masks",
		texture_rect = {
			0,
			64,
			64,
			64
		}
	}
	self.hud_icons.equipment_bg = {
		texture = "guis/textures/pd2/equipment",
		texture_rect = {
			64,
			32,
			32,
			32
		}
	}
	self.hud_icons.equipment_cable_ties = {
		texture = "guis/textures/pd2/equipment",
		texture_rect = {
			0,
			0,
			32,
			32
		}
	}
	self.hud_icons.mugshot_swansong = {
		texture = "guis/textures/pd2/hud_swansong_icon",
		texture_rect = {
			0,
			0,
			64,
			64
		}
	}
	self.hud_icons.equipment_ammo_bag = {
		texture = "guis/textures/pd2/equipment",
		texture_rect = {
			0,
			32,
			32,
			32
		}
	}
	self.hud_icons.equipment_doctor_bag = {
		texture = "guis/textures/pd2/equipment",
		texture_rect = {
			96,
			0,
			32,
			32
		}
	}
	self.hud_icons.equipment_sentry = {
		texture = "guis/textures/pd2/equipment",
		texture_rect = {
			32,
			32,
			32,
			32
		}
	}
	self.hud_icons.equipment_sentry_silent = {
		texture = "guis/textures/pd2/equipment",
		texture_rect = {
			96,
			96,
			32,
			32
		}
	}
	self.hud_icons.equipment_trip_mine = {
		texture = "guis/textures/pd2/equipment",
		texture_rect = {
			64,
			0,
			32,
			32
		}
	}
	self.hud_icons.equipment_ecm_jammer = {
		texture = "guis/textures/pd2/equipment",
		texture_rect = {
			32,
			0,
			32,
			32
		}
	}
	self.hud_icons.equipment_armor_kit = {
		texture = "guis/textures/pd2/equipment",
		texture_rect = {
			32,
			64,
			32,
			32
		}
	}
	self.hud_icons.equipment_first_aid_kit = {
		texture = "guis/textures/pd2/equipment",
		texture_rect = {
			0,
			64,
			32,
			32
		}
	}
	self.hud_icons.equipment_bodybags_bag = {
		texture = "guis/textures/pd2/equipment",
		texture_rect = {
			96,
			32,
			32,
			32
		}
	}
	self.hud_icons.equipment_generic_key = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			32,
			64,
			32,
			32
		}
	}
	self.hud_icons.equipment_chavez_key = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			32,
			64,
			32,
			32
		}
	}
	self.hud_icons.equipment_bank_manager_key = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			32,
			0,
			32,
			32
		}
	}
	self.hud_icons.equipment_drill = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			0,
			0,
			32,
			32
		}
	}
	self.hud_icons.equipment_drillfix = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			96,
			64,
			32,
			32
		}
	}
	self.hud_icons.equipment_thermite = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			64,
			64,
			32,
			32
		}
	}
	self.hud_icons.equipment_c4 = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			96,
			0,
			32,
			32
		}
	}
	self.hud_icons.equipment_saw = {
		texture = "guis/textures/pd2/mission_equipment",
		texture_rect = {
			42,
			84,
			42,
			42
		}
	}
	self.hud_icons.equipment_cutter = {
		texture = "guis/textures/pd2/mission_equipment",
		texture_rect = {
			42,
			84,
			42,
			42
		}
	}
	self.hud_icons.equipment_gasoline = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			64,
			0,
			32,
			32
		}
	}
	self.hud_icons.equipment_planks = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			0,
			32,
			32,
			32
		}
	}
	self.hud_icons.equipment_muriatic_acid = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			32,
			32,
			32,
			32
		}
	}
	self.hud_icons.equipment_hydrogen_chloride = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			64,
			32,
			32,
			32
		}
	}
	self.hud_icons.equipment_caustic_soda = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			96,
			32,
			32,
			32
		}
	}
	self.hud_icons.equipment_crowbar = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			0,
			64,
			32,
			32
		}
	}
	self.hud_icons.equipment_barcode = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			0,
			96,
			32,
			32
		}
	}
	self.hud_icons.equipment_glasscutter = {
		texture = "guis/textures/pd2/hud_pickups",
		texture_rect = {
			64,
			128,
			32,
			32
		}
	}
	self.hud_icons.equipment_body_bag = {
		texture = "guis/textures/pd2/equipment",
		texture_rect = {
			96,
			32,
			32,
			32
		}
	}
	self.hud_icons.ak = {
		texture = "guis/textures/pd2/weapons",
		texture_rect = {
			0,
			0,
			64,
			64
		}
	}
	self.hud_icons.hk21 = {
		texture = "guis/textures/pd2/weapons",
		texture_rect = {
			64,
			64,
			64,
			64
		}
	}
	self.hud_icons.mac11 = {
		texture = "guis/textures/pd2/weapons",
		texture_rect = {
			64,
			0,
			64,
			64
		}
	}
	self.hud_icons.glock = {
		texture = "guis/textures/pd2/weapons",
		texture_rect = {
			0,
			64,
			64,
			64
		}
	}
	self.hud_icons.beretta92 = {
		texture = "guis/textures/pd2/weapons",
		texture_rect = {
			128,
			128,
			64,
			64
		}
	}
	self.hud_icons.m4 = {
		texture = "guis/textures/pd2/weapons",
		texture_rect = {
			128,
			0,
			64,
			64
		}
	}
	self.hud_icons.r870_shotgun = {
		texture = "guis/textures/pd2/weapons",
		texture_rect = {
			64,
			128,
			64,
			64
		}
	}
	self.hud_icons.mp5 = {
		texture = "guis/textures/pd2/weapons",
		texture_rect = {
			0,
			192,
			64,
			64
		}
	}
	self.hud_icons.c45 = {
		texture = "guis/textures/pd2/weapons",
		texture_rect = {
			192,
			0,
			64,
			64
		}
	}
	self.hud_icons.raging_bull = {
		texture = "guis/textures/pd2/weapons",
		texture_rect = {
			0,
			128,
			64,
			64
		}
	}
	self.hud_icons.mossberg = {
		texture = "guis/textures/pd2/weapons",
		texture_rect = {
			192,
			64,
			64,
			64
		}
	}
	self.hud_icons.m14 = {
		texture = "guis/textures/pd2/weapons",
		texture_rect = {
			192,
			128,
			64,
			64
		}
	}
	self.hud_icons.m79 = {
		texture = "guis/textures/pd2/weapons",
		texture_rect = {
			128,
			64,
			64,
			64
		}
	}
	self.hud_icons.risk_pd = {
		texture = "guis/textures/pd2/hud_difficultymarkers_2",
		texture_rect = {
			90,
			0,
			30,
			30
		}
	}
	self.hud_icons.risk_swat = {
		texture = "guis/textures/pd2/hud_difficultymarkers_2",
		texture_rect = {
			0,
			0,
			30,
			30
		}
	}
	self.hud_icons.risk_fbi = {
		texture = "guis/textures/pd2/hud_difficultymarkers_2",
		texture_rect = {
			30,
			0,
			30,
			30
		}
	}
	self.hud_icons.risk_death_squad = {
		texture = "guis/textures/pd2/hud_difficultymarkers_2",
		texture_rect = {
			60,
			0,
			30,
			30
		}
	}
	self.hud_icons.risk_easy_wish = {
		texture = "guis/textures/pd2/hud_difficultymarkers_2",
		texture_rect = {
			90,
			0,
			30,
			30
		}
	}
	self.hud_icons.risk_murder_squad = {
		texture = "guis/textures/pd2/hud_difficultymarkers_2",
		texture_rect = {
			0,
			32,
			30,
			30
		}
	}
	self.hud_icons.risk_sm_wish = {
		texture = "guis/textures/pd2/hud_difficultymarkers_2",
		texture_rect = {
			30,
			32,
			30,
			30
		}
	}
	self.hud_icons.frag_grenade = {
		texture = "guis/textures/pd2/equipment",
		texture_rect = {
			64,
			32,
			32,
			32
		}
	}
	self.hud_icons.molotov_grenade = {
		texture = "guis/textures/pd2/equipment",
		texture_rect = {
			64,
			64,
			32,
			32
		}
	}
	self.hud_icons.dynamite_grenade = {
		texture = "guis/textures/pd2/equipment",
		texture_rect = {
			96,
			64,
			32,
			32
		}
	}
	self.hud_icons.four_projectile = {
		texture = "guis/textures/pd2/equipment",
		texture_rect = {
			0,
			96,
			32,
			32
		}
	}
	self.hud_icons.ace_projectile = {
		texture = "guis/textures/pd2/equipment",
		texture_rect = {
			32,
			96,
			32,
			32
		}
	}
	self.hud_icons.jav_projectile = {
		texture = "guis/textures/pd2/equipment",
		texture_rect = {
			64,
			96,
			32,
			32
		}
	}
	self.hud_icons.throwing_axe = {
		texture = "guis/textures/pd2/equipment_02",
		texture_rect = {
			0,
			0,
			32,
			32
		}
	}
	self.hud_icons.concussion_grenade = {
		texture = "guis/textures/pd2/equipment_02",
		texture_rect = {
			32,
			0,
			32,
			32
		}
	}
	self.hud_icons.hobby_knife = {
		texture = "guis/textures/pd2/equipment_02",
		texture_rect = {
			64,
			0,
			32,
			32
		}
	}
	self.hud_icons.chico_injector = {
		texture = "guis/textures/pd2/equipment_02",
		texture_rect = {
			96,
			0,
			32,
			32
		}
	}
	self.hud_icons.fir_grenade = {
		texture = "guis/textures/pd2/equipment_02",
		texture_rect = {
			0,
			32,
			32,
			32
		}
	}
	self.hud_icons.smoke_screen_grenade = {
		texture = "guis/textures/pd2/equipment_02",
		texture_rect = {
			32,
			32,
			32,
			32
		}
	}
	self.hud_icons.dada_com = {
		texture = "guis/textures/pd2/equipment_02",
		texture_rect = {
			96,
			32,
			32,
			32
		}
	}
	self.hud_icons.damage_control = {
		texture = "guis/textures/pd2/equipment_02",
		texture_rect = {
			0,
			64,
			32,
			32
		}
	}
	self.hud_icons.tag_team = {
		texture = "guis/textures/pd2/equipment_02",
		texture_rect = {
			32,
			64,
			32,
			32
		}
	}
	self.hud_icons.none_icon = {
		texture = "guis/textures/pd2/equipment_02",
		texture_rect = {
			64,
			32,
			32,
			32
		}
	}
end

