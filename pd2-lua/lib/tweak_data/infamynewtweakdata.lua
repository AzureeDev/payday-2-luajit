InfamyTweakData = InfamyTweakData or class()

function InfamyTweakData:init()
	local function digest(value)
		return Application:digest_value(value, true)
	end

	local cost_old = digest(200000000)
	local cost_new = digest(0)
	self.ranks = 500
	self.offshore_cost = {
		cost_old,
		cost_old,
		cost_old,
		cost_old,
		cost_old,
		cost_new
	}
	self.card_sequences = {}
	self.statistics_rank_steps = {}

	for i = 0, 100 do
		table.insert(self.statistics_rank_steps, 1, i)
	end

	for i = 150, self.ranks, 50 do
		table.insert(self.statistics_rank_steps, 1, i)
	end

	self.join_stingers = 35
	self.free_join_stingers = {
		0,
		18
	}
	self.icon_rank_step = 100
	self.infamy_icons = {
		{
			hud_icon = "infamy_icon_1",
			color = Color("000000")
		},
		{
			hud_icon = "infamy_icon_2",
			color = Color("B8000A")
		},
		{
			hud_icon = "infamy_icon_3",
			color = Color("000000")
		},
		{
			hud_icon = "infamy_icon_4",
			color = Color("B8000A")
		},
		{
			hud_icon = "infamy_icon_5",
			color = Color("FFD700")
		}
	}
	self.tree = {
		"infamy_root",
		"infamy_xp_medium_4",
		"infamy_mastermind",
		"infamy_xp_medium_5",
		"infamy_enforcer",
		"infamy_xp_medium_8",
		"infamy_technician",
		"infamy_xp_medium_9",
		"infamy_ghost",
		"infamy_xp_medium_2",
		"infamy_maskpack_balaclava",
		"infamy_xp_medium_6",
		"infamy_maskpack_lurker",
		"infamy_xp_medium_7",
		"infamy_maskpack_daft",
		"infamy_xp_medium_11",
		"infamy_maskpack_punk",
		"infamy_xp_medium_1",
		"infamy_maskpack_pain",
		"infamy_xp_medium_3",
		"infamy_maskpack_ranger",
		"infamy_xp_medium_10",
		"infamy_maskpack_hood",
		"infamy_xp_medium_12",
		"infamy_maskpack_destroyer",
		"infamy_stinger_002",
		"infamy_color_inf_01",
		"infamy_color_inf_02",
		"infamy_stinger_003",
		"infamy_suitpack_t800",
		"infamy_stinger_004",
		"infamy_color_inf_03",
		"infamy_color_inf_04",
		"infamy_stinger_005",
		"infamy_glovepack_molten",
		"infamy_stinger_006",
		"infamy_color_inf_05",
		"infamy_color_inf_06",
		"infamy_stinger_007",
		"infamy_suitpack_t800_toughboy",
		"infamy_stinger_008",
		"infamy_color_inf_07",
		"infamy_color_inf_08",
		"infamy_stinger_009",
		"infamy_glovepack_tiger",
		"infamy_stinger_010",
		"infamy_color_inf_09",
		"infamy_color_inf_10",
		"infamy_stinger_011",
		"infamy_suitpack_t800_red",
		"infamy_stinger_012",
		"infamy_color_inf_11",
		"infamy_color_inf_12",
		"infamy_stinger_013",
		"infamy_glovepack_cosmos",
		"infamy_stinger_014",
		"infamy_color_inf_13",
		"infamy_color_inf_14",
		"infamy_stinger_015",
		"infamy_suitpack_t800_cowboy",
		"infamy_stinger_016",
		"infamy_color_inf_15",
		"infamy_color_inf_16",
		"infamy_stinger_017",
		"infamy_glovepack_neoncity",
		"in31_suitpack_leather",
		"in31_weapon_color_stinger_01",
		"in31_glovepack_wool",
		"in31_weapon_color_stinger_02",
		"in31_suitpack_leather_black",
		"in31_weapon_color_stinger_03",
		"in31_maskpack_lastlaugh",
		"in31_weapon_color_stinger_04",
		"in31_suitpack_leather_red",
		"in31_weapon_color_stinger_05",
		"in31_maskpack_cyberpunk",
		"in31_weapon_color_stinger_06",
		"in31_suitpack_leather_white",
		"in31_weapon_color_stinger_07",
		"in31_glovepack_silver",
		"in31_weapon_color_stinger_08",
		"in32_glovepack_goldnet",
		"in32_weapon_color_stinger_01",
		"in32_suitpack_gangstercoat",
		"in32_weapon_color_stinger_02",
		"in32_suitpack_gangstercoat_british",
		"in32_weapon_color_stinger_03",
		"in32_maskpack_goldenbrute",
		"in32_weapon_color_stinger_04",
		"in32_suitpack_gangstercoat_french",
		"in32_weapon_color_stinger_05",
		"in32_suitpack_gangstercoat_irish",
		"in32_weapon_color_stinger_06",
		"in32_maskpack_ingoldnito",
		"in32_weapon_color_stinger_07",
		"in32_suitpack_general_default_blue",
		"in32_weapon_color_stinger_08",
		"in32_suitglovepack_general_postmoto",
		"in32_weapon_color_stinger_09"
	}
	self.cost = {
		root = digest(0),
		tier1 = digest(0)
	}
	self.items = {}
	local skilltree_multiplier = 0.9
	local skillcost_multiplier = 0.75
	local skilltree_readable_multiplier = "10%"
	local skillcost_readable_multiplier = "25%"
	local infamous_lootdrop_multiplier = 2
	local infamous_readable_multiplier = "100%"
	local infamous_xp_multiplier_base = 1.05
	local infamous_readable_xp_multiplier_base = "5%"
	local infamous_xp_multiplier_small = 1.075
	local infamous_readable_xp_multiplier_small = "7.5%"
	local infamous_xp_multiplier_medium = 1.1
	local infamous_readable_xp_multiplier_medium = "10%"
	local infamous_xp_multiplier_large = 1.15
	local infamous_readable_xp_multiplier_large = "15%"
	self.items.infamy_root = {
		add_tier = false,
		name_id = "menu_infamy_name_root",
		desc_id = "menu_infamy_desc_root_new",
		desc_params = {
			cashcost = skillcost_readable_multiplier,
			xpboost = infamous_readable_xp_multiplier_base,
			multibasic = skilltree_readable_multiplier
		},
		icon_xy = {
			0,
			0
		},
		cost = self.cost.root,
		upgrades = {
			{
				nil,
				"masks",
				"aviator"
			},
			join_stingers = {
				1
			},
			infamous_lootdrop = infamous_lootdrop_multiplier,
			infamous_xp = infamous_xp_multiplier_base,
			skillcost = {
				multiplier = skillcost_multiplier
			},
			skilltree = {
				trees = {
					"mastermind",
					"enforcer",
					"technician",
					"ghost",
					"hoxton"
				},
				multiplier = skilltree_multiplier
			}
		}
	}
	self.items.infamy_mastermind = {
		add_tier = false,
		name_id = "menu_infamy_name_mastermind",
		desc_id = "menu_infamy_desc_mastermind_new",
		desc_params = {
			multibasic = skilltree_readable_multiplier,
			xpboost = infamous_readable_xp_multiplier_base
		},
		icon_xy = {
			2,
			0
		},
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"masks",
				"plague"
			},
			{
				nil,
				"textures",
				"imperial"
			},
			{
				nil,
				"materials",
				"dark_leather"
			},
			infamous_xp = infamous_xp_multiplier_base
		}
	}
	self.items.infamy_enforcer = {
		add_tier = false,
		name_id = "menu_infamy_name_enforcer",
		desc_id = "menu_infamy_desc_enforcer_new",
		desc_params = {
			multibasic = skilltree_readable_multiplier,
			xpboost = infamous_readable_xp_multiplier_base
		},
		icon_xy = {
			3,
			0
		},
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"masks",
				"welder"
			},
			{
				nil,
				"textures",
				"fatman"
			},
			{
				nil,
				"materials",
				"copper"
			},
			infamous_xp = infamous_xp_multiplier_base
		}
	}
	self.items.infamy_technician = {
		add_tier = false,
		name_id = "menu_infamy_name_technician",
		desc_id = "menu_infamy_desc_technician_new",
		desc_params = {
			multibasic = skilltree_readable_multiplier,
			xpboost = infamous_readable_xp_multiplier_base
		},
		icon_xy = {
			1,
			0
		},
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"masks",
				"smoker"
			},
			{
				nil,
				"textures",
				"toto"
			},
			{
				nil,
				"materials",
				"electric"
			},
			infamous_xp = infamous_xp_multiplier_base
		}
	}
	self.items.infamy_ghost = {
		add_tier = false,
		name_id = "menu_infamy_name_ghost",
		desc_id = "menu_infamy_desc_ghost_new",
		desc_params = {
			multibasic = skilltree_readable_multiplier,
			xpboost = infamous_readable_xp_multiplier_base
		},
		icon_xy = {
			0,
			1
		},
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"masks",
				"ghost"
			},
			{
				nil,
				"textures",
				"ribcage"
			},
			{
				nil,
				"materials",
				"sinister"
			},
			infamous_xp = infamous_xp_multiplier_base
		}
	}
	local generic_medium_xp_item = {
		name_id = "menu_infamy_name_xp",
		add_tier = false,
		desc_id = "menu_infamy_desc_xp",
		desc_params = {
			xpboost = infamous_readable_xp_multiplier_medium
		},
		icon_xy = {
			1,
			1
		},
		cost = self.cost.tier1,
		upgrades = {
			infamous_xp = infamous_xp_multiplier_medium
		}
	}

	for i = 1, 15 do
		self.items["infamy_xp_medium_" .. i] = deep_clone(generic_medium_xp_item)
	end

	self.items.infamy_maskpack_balaclava = {
		name_id = "menu_infamy_name_balaclava",
		add_tier = false,
		desc_id = "menu_infamy_desc_balaclava",
		desc_params = {
			xpboost = infamous_readable_xp_multiplier_small
		},
		icon_xy = {
			2,
			1
		},
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"masks",
				"balaclava"
			},
			{
				nil,
				"textures",
				"pain"
			},
			{
				nil,
				"materials",
				"eye"
			},
			infamous_xp = infamous_xp_multiplier_small
		}
	}
	self.items.infamy_maskpack_lurker = {
		name_id = "menu_infamy_name_lurker",
		add_tier = false,
		desc_id = "menu_infamy_desc_lurker",
		desc_params = {
			xpboost = infamous_readable_xp_multiplier_small
		},
		icon_xy = {
			2,
			1
		},
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"masks",
				"infamy_lurker"
			},
			{
				nil,
				"textures",
				"hellsanchor"
			},
			{
				nil,
				"materials",
				"baby"
			},
			infamous_xp = infamous_xp_multiplier_small
		}
	}
	self.items.infamy_maskpack_hood = {
		name_id = "menu_infamy_name_hood",
		add_tier = false,
		desc_id = "menu_infamy_desc_hood",
		desc_params = {
			xpboost = infamous_readable_xp_multiplier_small
		},
		icon_xy = {
			2,
			1
		},
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"masks",
				"infamy_hood"
			},
			{
				nil,
				"textures",
				"evileye"
			},
			{
				nil,
				"materials",
				"plastic_hood"
			},
			infamous_xp = infamous_xp_multiplier_small
		}
	}
	self.items.infamy_maskpack_pain = {
		name_id = "menu_infamy_name_pain",
		add_tier = false,
		desc_id = "menu_infamy_desc_pain",
		desc_params = {
			xpboost = infamous_readable_xp_multiplier_small
		},
		icon_xy = {
			2,
			1
		},
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"masks",
				"pain"
			},
			{
				nil,
				"textures",
				"spook"
			},
			{
				nil,
				"materials",
				"hades"
			},
			infamous_xp = infamous_xp_multiplier_small
		}
	}
	self.items.infamy_maskpack_ranger = {
		name_id = "menu_infamy_name_ranger",
		add_tier = false,
		desc_id = "menu_infamy_desc_ranger",
		desc_params = {
			xpboost = infamous_readable_xp_multiplier_small
		},
		icon_xy = {
			2,
			1
		},
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"masks",
				"ranger"
			},
			{
				nil,
				"textures",
				"monstervisor"
			},
			{
				nil,
				"materials",
				"alien_slime"
			},
			infamous_xp = infamous_xp_multiplier_small
		}
	}
	self.items.infamy_maskpack_punk = {
		name_id = "menu_infamy_name_punk",
		add_tier = false,
		desc_id = "menu_infamy_desc_punk",
		desc_params = {
			xpboost = infamous_readable_xp_multiplier_small
		},
		icon_xy = {
			2,
			1
		},
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"masks",
				"punk"
			},
			{
				nil,
				"textures",
				"steampunk"
			},
			{
				nil,
				"materials",
				"punk"
			},
			infamous_xp = infamous_xp_multiplier_small
		}
	}
	self.items.infamy_maskpack_daft = {
		name_id = "menu_infamy_name_daft",
		add_tier = false,
		desc_id = "menu_infamy_desc_daft",
		desc_params = {
			xpboost = infamous_readable_xp_multiplier_small
		},
		icon_xy = {
			2,
			1
		},
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"masks",
				"daft"
			},
			{
				nil,
				"textures",
				"digital"
			},
			{
				nil,
				"materials",
				"haze"
			},
			infamous_xp = infamous_xp_multiplier_small
		}
	}
	self.items.infamy_maskpack_destroyer = {
		name_id = "menu_infamy_name_destroyer",
		add_tier = false,
		desc_id = "menu_infamy_desc_destroyer",
		desc_params = {
			xpboost = infamous_readable_xp_multiplier_small
		},
		icon_xy = {
			2,
			1
		},
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"masks",
				"destroyer"
			},
			{
				nil,
				"textures",
				"exmachina"
			},
			{
				nil,
				"materials",
				"arizona"
			},
			infamous_xp = infamous_xp_multiplier_small
		}
	}
	local generic_join_stinger_item = {
		desc_id = "menu_infamy_join_stinger_desc",
		name_id = "",
		desc_params = {},
		icon_xy = {
			0,
			2
		},
		cost = self.cost.tier1,
		upgrades = {
			join_stingers = {}
		}
	}
	local single_pack_join_stingers = {
		2,
		3,
		4,
		5,
		6,
		7,
		8,
		9,
		10,
		11,
		12,
		13,
		14,
		15,
		16,
		17
	}

	for _, index in ipairs(single_pack_join_stingers) do
		local item_id = string.format("infamy_stinger_%03d", index)
		self.items[item_id] = deep_clone(generic_join_stinger_item)
		self.items[item_id].name_id = "menu_" .. item_id .. "_name"

		table.insert(self.items[item_id].upgrades.join_stingers, index)
	end

	self.items.infamy_suitpack_t800 = {
		name_id = "menu_infamy_name_suitpack_t800",
		desc_id = "menu_infamy_suits_desc",
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"player_styles",
				"t800",
				"default"
			}
		}
	}
	self.items.infamy_suitpack_t800_cowboy = {
		name_id = "menu_infamy_name_suitpack_t800_cowboy",
		desc_id = "menu_infamy_suits_desc",
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"player_styles",
				"t800",
				"cowboy"
			}
		}
	}
	self.items.infamy_suitpack_t800_toughboy = {
		name_id = "menu_infamy_name_suitpack_t800_toughboy",
		desc_id = "menu_infamy_suits_desc",
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"player_styles",
				"t800",
				"toughboy"
			}
		}
	}
	self.items.infamy_suitpack_t800_red = {
		name_id = "menu_infamy_name_suitpack_t800_red",
		desc_id = "menu_infamy_suits_desc",
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"player_styles",
				"t800",
				"red"
			}
		}
	}
	self.items.infamy_glovepack_tiger = {
		name_id = "menu_infamy_name_glovepack_tiger",
		desc_id = "menu_infamy_gloves_desc",
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"gloves",
				"tiger"
			}
		}
	}
	self.items.infamy_glovepack_neoncity = {
		name_id = "menu_infamy_name_glovepack_neoncity",
		desc_id = "menu_infamy_gloves_desc",
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"gloves",
				"neoncity"
			}
		}
	}
	self.items.infamy_glovepack_cosmos = {
		name_id = "menu_infamy_name_glovepack_cosmos",
		desc_id = "menu_infamy_gloves_desc",
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"gloves",
				"cosmos"
			}
		}
	}
	self.items.infamy_glovepack_molten = {
		name_id = "menu_infamy_name_glovepack_molten",
		desc_id = "menu_infamy_gloves_desc",
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"gloves",
				"molten"
			}
		}
	}
	local generic_weapon_color_item = {
		desc_id = "menu_infamy_weapon_color_desc",
		name_id = "",
		desc_params = {},
		icon_xy = {
			2,
			3
		},
		cost = self.cost.tier1,
		upgrades = {}
	}
	local weapon_colors = {
		"color_inf_01",
		"color_inf_02",
		"color_inf_03",
		"color_inf_04",
		"color_inf_05",
		"color_inf_06",
		"color_inf_07",
		"color_inf_08",
		"color_inf_09",
		"color_inf_10",
		"color_inf_11",
		"color_inf_12",
		"color_inf_13",
		"color_inf_14",
		"color_inf_15",
		"color_inf_16"
	}

	for _, id in ipairs(weapon_colors) do
		local item_id = "infamy_" .. id
		local color_id = id
		self.items[item_id] = deep_clone(generic_weapon_color_item)
		self.items[item_id].name_id = "menu_infamy_" .. id .. "_name"

		table.insert(self.items[item_id].upgrades, {
			nil,
			"weapon_skins",
			color_id
		})
	end

	local infamy_color_and_stinger_packs = {}
	self.items.in31_maskpack_cyberpunk = {
		name_id = "menu_in31_maskpack_cyberpunk_name",
		desc_id = "menu_in31_maskpack_cyberpunk_desc",
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"masks",
				"cyberpunk"
			}
		}
	}
	self.items.in31_maskpack_lastlaugh = {
		name_id = "menu_in31_maskpack_lastlaugh_name",
		desc_id = "menu_in31_maskpack_lastlaugh_desc",
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"masks",
				"lastlaugh"
			}
		}
	}
	self.items.in31_glovepack_wool = {
		name_id = "menu_infamy_name_glovepack_wool",
		desc_id = "menu_infamy_gloves_desc",
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"gloves",
				"wool"
			}
		}
	}
	self.items.in31_glovepack_silver = {
		name_id = "menu_infamy_name_glovepack_silver",
		desc_id = "menu_infamy_gloves_desc",
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"gloves",
				"silver"
			}
		}
	}
	self.items.in31_suitpack_leather = {
		name_id = "menu_infamy_name_suitpack_leather",
		desc_id = "menu_infamy_suits_desc",
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"player_styles",
				"leather",
				"default"
			}
		}
	}
	self.items.in31_suitpack_leather_black = {
		name_id = "menu_infamy_name_suitpack_leather_black",
		desc_id = "menu_infamy_suits_desc",
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"player_styles",
				"leather",
				"black"
			}
		}
	}
	self.items.in31_suitpack_leather_red = {
		name_id = "menu_infamy_name_suitpack_leather_red",
		desc_id = "menu_infamy_suits_desc",
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"player_styles",
				"leather",
				"red"
			}
		}
	}
	self.items.in31_suitpack_leather_white = {
		name_id = "menu_infamy_name_suitpack_leather_white",
		desc_id = "menu_infamy_suits_desc",
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"player_styles",
				"leather",
				"white"
			}
		}
	}

	table.list_append(infamy_color_and_stinger_packs, {
		{
			join_stinger = 19,
			item_id = "in31_weapon_color_stinger_01",
			weapon_color = "color_in31_06"
		},
		{
			join_stinger = 20,
			item_id = "in31_weapon_color_stinger_02",
			weapon_color = "color_in31_04"
		},
		{
			join_stinger = 21,
			item_id = "in31_weapon_color_stinger_03",
			weapon_color = "color_in31_05"
		},
		{
			join_stinger = 22,
			item_id = "in31_weapon_color_stinger_04",
			weapon_color = "color_in31_02"
		},
		{
			join_stinger = 23,
			item_id = "in31_weapon_color_stinger_05",
			weapon_color = "color_in31_01"
		},
		{
			join_stinger = 24,
			item_id = "in31_weapon_color_stinger_06",
			weapon_color = "color_in31_08"
		},
		{
			join_stinger = 25,
			item_id = "in31_weapon_color_stinger_07",
			weapon_color = "color_in31_03"
		},
		{
			join_stinger = 26,
			item_id = "in31_weapon_color_stinger_08",
			weapon_color = "color_in31_07"
		}
	})

	self.items.in32_maskpack_goldenbrute = {
		name_id = "menu_in32_maskpack_goldenbrute_name",
		desc_id = "menu_in32_maskpack_goldenbrute_desc",
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"masks",
				"goldenbrute"
			}
		}
	}
	self.items.in32_maskpack_ingoldnito = {
		name_id = "menu_in32_maskpack_ingoldnito_name",
		desc_id = "menu_in32_maskpack_ingoldnito_desc",
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"masks",
				"ingoldnito"
			}
		}
	}
	self.items.in32_suitpack_gangstercoat = {
		name_id = "menu_in32_suitpack_gangstercoat",
		desc_id = "menu_infamy_suits_desc",
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"player_styles",
				"gangstercoat",
				"default"
			}
		}
	}
	self.items.in32_suitpack_gangstercoat_irish = {
		name_id = "menu_in32_suitpack_gangstercoat_irish",
		desc_id = "menu_infamy_suits_desc",
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"player_styles",
				"gangstercoat",
				"irish"
			}
		}
	}
	self.items.in32_suitpack_gangstercoat_british = {
		name_id = "menu_in32_suitpack_gangstercoat_british",
		desc_id = "menu_infamy_suits_desc",
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"player_styles",
				"gangstercoat",
				"british"
			}
		}
	}
	self.items.in32_suitpack_gangstercoat_french = {
		name_id = "menu_in32_suitpack_gangstercoat_french",
		desc_id = "menu_infamy_suits_desc",
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"player_styles",
				"gangstercoat",
				"french"
			}
		}
	}
	self.items.in32_suitpack_general_default_blue = {
		name_id = "menu_in32_suitpack_general_default_blue",
		desc_id = "menu_infamy_suits_desc",
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"player_styles",
				"general",
				"default"
			},
			{
				nil,
				"player_styles",
				"general",
				"blue"
			}
		}
	}
	self.items.in32_suitglovepack_general_postmoto = {
		name_id = "menu_in32_suitglovepack_general_postmoto",
		desc_id = "menu_infamy_suits_desc",
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"player_styles",
				"general",
				"red"
			},
			{
				nil,
				"player_styles",
				"general",
				"white"
			},
			{
				nil,
				"gloves",
				"postmoto"
			}
		}
	}
	self.items.in32_glovepack_goldnet = {
		name_id = "menu_in32_glovepack_goldnet",
		desc_id = "menu_infamy_gloves_desc",
		cost = self.cost.tier1,
		upgrades = {
			{
				nil,
				"gloves",
				"goldnet"
			}
		}
	}

	table.list_append(infamy_color_and_stinger_packs, {
		{
			join_stinger = 27,
			item_id = "in32_weapon_color_stinger_01",
			weapon_color = "color_in32_01"
		},
		{
			join_stinger = 28,
			item_id = "in32_weapon_color_stinger_02",
			weapon_color = "color_in32_02"
		},
		{
			join_stinger = 29,
			item_id = "in32_weapon_color_stinger_03",
			weapon_color = "color_in32_03"
		},
		{
			join_stinger = 30,
			item_id = "in32_weapon_color_stinger_04",
			weapon_color = "color_in32_04"
		},
		{
			join_stinger = 31,
			item_id = "in32_weapon_color_stinger_05",
			weapon_color = "color_in32_05"
		},
		{
			join_stinger = 32,
			item_id = "in32_weapon_color_stinger_06",
			weapon_color = "color_in32_06"
		},
		{
			join_stinger = 33,
			item_id = "in32_weapon_color_stinger_07",
			weapon_color = "color_in32_07"
		},
		{
			join_stinger = 34,
			item_id = "in32_weapon_color_stinger_08",
			weapon_color = "color_in32_08"
		},
		{
			join_stinger = 35,
			item_id = "in32_weapon_color_stinger_09",
			weapon_color = "color_in32_09"
		}
	})

	local generic_infamy_weapon_color_and_stinger_item = {
		name_id = "menu_infamy_color_stinger_name",
		desc_id = "menu_infamy_color_stinger_desc",
		desc_params = {},
		desc_param_ids = {},
		icon_xy = {
			2,
			3
		},
		cost = self.cost.tier1,
		upgrades = {
			join_stingers = {}
		}
	}

	for index, data in ipairs(infamy_color_and_stinger_packs) do
		local item_id = data.item_id
		local color_id = data.weapon_color
		local join_stinger = data.join_stinger
		local join_stinger_id = string.format("infamy_stinger_%03d", data.join_stinger)
		self.items[item_id] = deep_clone(generic_infamy_weapon_color_and_stinger_item)
		self.items[item_id].desc_param_ids.weapon_color = "bm_wskn_" .. color_id
		self.items[item_id].desc_param_ids.join_stinger = "menu_" .. join_stinger_id .. "_name"

		table.insert(self.items[item_id].upgrades, {
			nil,
			"weapon_skins",
			color_id
		})
		table.insert(self.items[item_id].upgrades.join_stingers, join_stinger)
	end

	self.items.infamy_secret_9 = {
		icon_xy = {
			1,
			1
		}
	}
	self.items.infamy_secret_8 = {
		icon_xy = {
			2,
			1
		}
	}
	self.items.infamy_secret_7 = {
		icon_xy = {
			3,
			1
		}
	}
	self.items.infamy_secret_6 = {
		icon_xy = {
			0,
			2
		}
	}
	self.items.infamy_secret_5 = {
		icon_xy = {
			1,
			2
		}
	}
	self.items.infamy_secret_4 = {
		icon_xy = {
			2,
			2
		}
	}
	self.items.infamy_secret_3 = {
		icon_xy = {
			3,
			2
		}
	}
	self.items.infamy_secret_2 = {
		icon_xy = {
			0,
			3
		}
	}
	self.items.infamy_secret_1 = {
		icon_xy = {
			1,
			3
		}
	}
end

function InfamyTweakData:get_infamy_item_rank_requirement(infamy_item)
	for rank, item in pairs(self.tree) do
		if item == infamy_item then
			return rank
		end
	end

	return nil
end
