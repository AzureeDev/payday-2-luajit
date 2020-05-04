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
	self.hud_downed = {
		timer_message_size = 24
	}
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
	self.hud_icons.minions_converted = {
		texture = "guis/textures/pd2/skilltree/icons_atlas",
		texture_rect = {
			384,
			512,
			64,
			64
		}
	}
	self.hud_icons.pagers_used = {
		texture = "guis/textures/pd2/pagers_used",
		texture_rect = {
			0,
			0,
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

	self:_setup_scene_poses()
	self:_setup_scene_pose_items()
end

function TweakData:get_scene_pose_items(scene_pose)
	local items = self.scene_pose_items[scene_pose] or {
		"primary",
		"secondary"
	}

	return {
		a_weapon_right_front = items[1],
		a_weapon_left_front = items[2]
	}
end

function TweakData:get_scene_pose(scene, pose_category, ...)
	local poses = nil
	local scene_poses = self.scene_poses[scene]

	if scene_poses then
		local possible_ids = {
			...
		}
		local i = 1

		while not poses and possible_ids[i] do
			poses = scene_poses[possible_ids[i]]
			i = i + 1
		end
	end

	poses = poses or scene_poses

	if type(poses[1]) ~= "string" then
		poses = poses[pose_category]
	end

	poses = poses or scene_poses.generic or self.scene_poses.generic
	local pose = poses[math.random(#poses)]
	local required_poses = poses.required_pose and table.list_copy(poses)

	return pose, required_poses
end

function TweakData:_setup_scene_pose_items()
	self.scene_pose_items = {
		husk1 = {},
		husk2 = {},
		husk3 = {},
		husk4 = {},
		lobby_generic_idle4 = {},
		husk_minigun = {
			"primary"
		},
		lobby_generic_idle1 = {
			"primary"
		},
		lobby_generic_idle2 = {
			"primary"
		},
		lobby_generic_idle3 = {
			"primary"
		},
		husk_bow1 = {
			"primary"
		},
		husk_bow2 = {
			"primary"
		},
		husk_card1 = {
			nil,
			"infamy"
		},
		husk_card2 = {
			nil,
			"infamy"
		},
		husk_card3 = {
			nil,
			"infamy"
		},
		husk_card4 = {
			nil,
			"infamy"
		},
		husk_ray = {
			nil,
			"secondary"
		},
		cvc_var1 = {},
		cvc_var2 = {},
		cvc_var3 = {},
		husk_akimbo1 = {
			"primary",
			"secondary"
		},
		husk_akimbo2 = {
			"primary",
			"secondary"
		}
	}
end

function TweakData:_setup_scene_poses()
	self.scene_poses = {
		generic = {
			"husk_generic1",
			"husk_generic2",
			"husk_generic3",
			"husk_generic4"
		},
		template = {}
	}
	self.scene_poses.template.generic = {
		"husk_generic1",
		"husk_generic2",
		"husk_generic3",
		"husk_generic4"
	}
	self.scene_poses.weapon = {
		assault_rifle = {
			"husk_rifle1",
			"husk_rifle2"
		},
		pistol = {
			"husk_pistol1"
		},
		saw = {
			"husk_saw1"
		},
		shotgun = {
			primary = {
				"husk_shotgun1"
			}
		},
		snp = {
			"husk_bullpup"
		},
		lmg = {
			"husk_lmg"
		},
		bow = {
			"husk_bow1",
			"husk_bow2",
			required_pose = true
		},
		akimbo = {
			"husk_akimbo1",
			"husk_akimbo2"
		},
		infamous = {
			"husk_infamous1",
			"husk_infamous3",
			"husk_infamous4"
		},
		m95 = {
			"husk_m95"
		},
		r93 = {
			"husk_r93"
		},
		huntsman = {
			"husk_mosconi",
			"husk_bullpup"
		},
		gre_m79 = {
			"husk_mosconi"
		},
		ksg = {
			"husk_mosconi",
			"husk_bullpup",
			required_pose = true
		},
		m249 = {
			"husk_m249"
		},
		m134 = {
			"husk_minigun",
			required_pose = true
		},
		famas = {
			"husk_bullpup",
			required_pose = true
		},
		aug = {
			"husk_bullpup",
			required_pose = true
		},
		wa2000 = {
			"husk_bullpup",
			required_pose = true
		},
		l85a2 = {
			"husk_bullpup",
			required_pose = true
		},
		vhs = {
			"husk_bullpup",
			required_pose = true
		},
		flamethrower_mk2 = {
			"husk_bullpup",
			required_pose = true
		},
		desertfox = {
			"husk_bullpup",
			required_pose = true
		},
		corgi = {
			"husk_bullpup",
			required_pose = true
		},
		komodo = {
			"husk_bullpup",
			required_pose = true
		},
		x_basset = {
			"husk_bullpup",
			required_pose = true
		},
		arbiter = {
			"husk_bullpup",
			required_pose = true
		},
		ray = {
			"husk_ray",
			required_pose = true
		}
	}
	self.scene_poses.infamy = {
		generic = {
			{
				"husk_card1"
			},
			{
				"husk_card2"
			},
			{
				"husk_card3"
			},
			{
				"husk_card4"
			},
			required_pose = true
		}
	}
	self.scene_poses.armor = {
		generic = {
			"cvc_var1",
			"cvc_var2"
		},
		level_1 = {
			"suit",
			"suit"
		},
		level_2 = {
			"lbv",
			"lbv"
		},
		level_3 = {
			"bv",
			"bv"
		},
		level_4 = {
			"hbv",
			"hbv"
		},
		level_5 = {
			"fj",
			"fj"
		},
		level_6 = {
			"ctv",
			"ctv"
		},
		level_7 = {
			"ictv",
			"ictv"
		}
	}
	self.scene_poses.player_style = {
		generic = {
			"suit_generic1",
			"suit_generic2",
			"suit_generic3",
			"suit_generic4",
			"suit_generic5",
			"suit_generic6",
			"suit_generic7"
		},
		sneak_suit = {
			"sneak",
			"sneak"
		},
		scrub = {
			"doctor",
			"doctor"
		},
		raincoat = {
			"rain",
			"rain"
		},
		murky_suit = {
			"military",
			"military"
		},
		tux = {
			"tuxedo",
			"tuxedo"
		},
		winter_suit = {
			"winter",
			"winter"
		},
		jumpsuit = {
			"jump",
			"jump"
		},
		clown = {
			"clown",
			"clown"
		},
		peacoat = {
			"peacoat",
			"peacoat"
		},
		miami = {
			"italian",
			"italian"
		},
		jail = {
			"standard_suit",
			"standard_suit"
		},
		poolrepair = {
			"pool",
			"pool"
		}
	}
end
