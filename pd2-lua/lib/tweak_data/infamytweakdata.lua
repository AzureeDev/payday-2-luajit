InfamyTweakData = InfamyTweakData or class()

function InfamyTweakData:init()
	local function digest(value)
		return Application:digest_value(value, true)
	end

	local cost_old = digest(200000000)
	local cost_new = digest(0)
	self.ranks = {
		cost_old,
		cost_old,
		cost_old,
		cost_old,
		cost_old,
		cost_new,
		cost_new,
		cost_new,
		cost_new,
		cost_new,
		cost_new,
		cost_new,
		cost_new,
		cost_new,
		cost_new,
		cost_new,
		cost_new,
		cost_new,
		cost_new,
		cost_new,
		cost_new,
		cost_new,
		cost_new,
		cost_new,
		cost_new
	}
	self.tree_rows = 5
	self.tree_cols = 5
	self.tree = {
		"infamy_xp_medium_1",
		"infamy_maskpack_ranger",
		"infamy_xp_medium_2",
		"infamy_maskpack_lurker",
		"infamy_xp_medium_3",
		"infamy_maskpack_punk",
		"infamy_xp_medium_4",
		"infamy_ghost",
		"infamy_xp_medium_5",
		"infamy_maskpack_balaclava",
		"infamy_xp_medium_6",
		"infamy_mastermind",
		"infamy_root",
		"infamy_enforcer",
		"infamy_xp_medium_7",
		"infamy_maskpack_daft",
		"infamy_xp_medium_8",
		"infamy_technician",
		"infamy_xp_medium_9",
		"infamy_maskpack_hood",
		"infamy_xp_medium_10",
		"infamy_maskpack_destroyer",
		"infamy_xp_medium_11",
		"infamy_maskpack_pain",
		"infamy_xp_medium_12"
	}
	self.cost = {
		root = digest(1),
		tier1 = digest(1)
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
		desc_id = "menu_infamy_desc_root",
		desc_params = {
			cashcost = skillcost_readable_multiplier,
			xpboost = infamous_readable_xp_multiplier_base
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
			infamous_lootdrop = infamous_lootdrop_multiplier,
			infamous_xp = infamous_xp_multiplier_base,
			skillcost = {
				multiplier = skillcost_multiplier
			}
		}
	}
	self.items.infamy_mastermind = {
		add_tier = false,
		name_id = "menu_infamy_name_mastermind",
		desc_id = "menu_infamy_desc_mastermind",
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
			infamous_xp = infamous_xp_multiplier_base,
			skilltree = {
				trees = {
					"mastermind",
					"hoxton"
				},
				multiplier = skilltree_multiplier
			}
		}
	}
	self.items.infamy_enforcer = {
		add_tier = false,
		name_id = "menu_infamy_name_enforcer",
		desc_id = "menu_infamy_desc_enforcer",
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
			infamous_xp = infamous_xp_multiplier_base,
			skilltree = {
				trees = {
					"enforcer",
					"hoxton"
				},
				multiplier = skilltree_multiplier
			}
		}
	}
	self.items.infamy_technician = {
		add_tier = false,
		name_id = "menu_infamy_name_technician",
		desc_id = "menu_infamy_desc_technician",
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
			infamous_xp = infamous_xp_multiplier_base,
			skilltree = {
				trees = {
					"technician",
					"hoxton"
				},
				multiplier = skilltree_multiplier
			}
		}
	}
	self.items.infamy_ghost = {
		add_tier = false,
		name_id = "menu_infamy_name_ghost",
		desc_id = "menu_infamy_desc_ghost",
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
			infamous_xp = infamous_xp_multiplier_base,
			skilltree = {
				trees = {
					"ghost",
					"hoxton"
				},
				multiplier = skilltree_multiplier
			}
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
