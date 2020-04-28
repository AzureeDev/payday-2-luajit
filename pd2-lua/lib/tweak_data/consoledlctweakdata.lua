function DLCTweakData:init_console()
	self.complete_overkill_pack.content_on_consoles = true
	self.complete_overkill_pack2.content_on_consoles = true
	self.complete_overkill_pack3.content_on_consoles = true
	self.xone_bonus = {
		free = true,
		content = {},
		content_on_consoles = true
	}
	self.xone_bonus.content.loot_global_value = "infamous"
	self.xone_bonus.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "unforsaken",
			amount = 1
		}
	}
	self.console_kenaz = {
		content_on_consoles = true,
		dlc = "has_parent_dlc",
		parent_dlc = "kenaz",
		content = {}
	}
	self.console_kenaz.content.loot_global_value = "kenaz"
	self.console_kenaz.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "croupier_hat",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "gladiator_helmet",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "the_king_mask",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "sports_utility_mask",
			amount = 1
		}
	}
	self.console_akm4_pack = {
		content_on_consoles = true,
		dlc = "has_parent_dlc",
		parent_dlc = "akm4_pack",
		content = {}
	}
	self.console_akm4_pack.content.loot_global_value = "akm4_pack"
	self.console_akm4_pack.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "carnotaurus",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "triceratops",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "pachy",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "velociraptor",
			amount = 1
		}
	}
	self.console_bbq = {
		content_on_consoles = true,
		dlc = "has_parent_dlc",
		parent_dlc = "bbq",
		content = {}
	}
	self.console_bbq.content.loot_global_value = "bbq"
	self.console_bbq.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "firedemon",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "gasmask",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "firemask",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "chef_hat",
			amount = 1
		}
	}
	self.console_west = {
		content_on_consoles = true,
		dlc = "has_parent_dlc",
		parent_dlc = "west",
		content = {}
	}
	self.console_west.content.loot_global_value = "west"
	self.console_west.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "bandit",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "bullskull",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "kangee",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "lone",
			amount = 1
		}
	}
	self.console_arena = {
		content_on_consoles = true,
		dlc = "has_parent_dlc",
		parent_dlc = "arena",
		content = {}
	}
	self.console_arena.content.loot_global_value = "arena"
	self.console_arena.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "concert_male",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "concert_female",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "boombox",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "cantus",
			amount = 1
		}
	}
	self.console_turtles = {
		content_on_consoles = true,
		dlc = "has_parent_dlc",
		parent_dlc = "turtles",
		content = {}
	}
	self.console_turtles.content.loot_global_value = "turtles"
	self.console_turtles.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "slicer",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "kage",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "ninja_hood",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "shirai",
			amount = 1
		}
	}
	self.console_berry = {
		content_on_consoles = true,
		dlc = "has_parent_dlc",
		parent_dlc = "berry",
		content = {}
	}
	self.console_berry.content.loot_global_value = "berry"
	self.console_berry.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "water_spirit",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "tane",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "oro",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "maui",
			amount = 1
		}
	}
	self.console_steel = {
		content_on_consoles = true,
		dlc = "has_parent_dlc",
		parent_dlc = "steel",
		content = {}
	}
	self.console_steel.content.loot_global_value = "steel"
	self.console_steel.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "mason_knight_veteran",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "agatha_knight",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "agatha_vanguard_veteran",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "mason_vanguard_veteran",
			amount = 1
		}
	}
	self.console_sokol = {
		content_on_consoles = true,
		dlc = "has_parent_dlc",
		parent_dlc = "character_pack_sokol",
		content = {}
	}
	self.console_sokol.content.loot_global_value = "character_pack_sokol"
	self.console_sokol.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "sokol",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "sokol_begins",
			amount = 1
		}
	}
	self.console_dragon = {
		content_on_consoles = true,
		dlc = "has_parent_dlc",
		parent_dlc = "dragon",
		content = {}
	}
	self.console_dragon.content.loot_global_value = "dragon"
	self.console_dragon.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "jiro",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "jiro_begins",
			amount = 1
		}
	}
	self.console_hlm2_deluxe = {
		content_on_consoles = true,
		free = true,
		content = {}
	}
	self.console_hlm2_deluxe.content.loot_global_value = "normal"
	self.console_hlm2_deluxe.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "richard_returns",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "richard_begins",
			amount = 1
		}
	}
	self.console_bonnie = {
		content_on_consoles = true,
		free = true,
		content = {}
	}
	self.console_bonnie.content.loot_global_value = "infamous"
	self.console_bonnie.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "bonnie",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "bonnie_begins",
			amount = 1
		}
	}
	self.console_rip = {
		content_on_consoles = true,
		free = true,
		content = {}
	}
	self.console_rip.content.loot_global_value = "infamous"
	self.console_rip.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "bodhi",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "bodhi_begins",
			amount = 1
		}
	}
	self.console_crimewave = {
		content_on_consoles = true,
		dlc = "has_crimewave_edition",
		content = {}
	}
	self.console_crimewave.content.loot_global_value = "normal"
	self.console_crimewave.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "clinton",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "bush",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "obama",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "nixon",
			amount = 2
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_m45_m_extended",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_m45_g_bling",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_s552_b_long",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_s552_fg_railed",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_m45_b_small",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_ppk_g_laser",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_s552_g_standard_green",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_ppk_b_long",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_m45_g_ergo",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_s552_body_standard_black",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_o_cmore",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_s552_s_standard_green",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_m45_b_green",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_m45_body_green",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_s552_fg_standard_green",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_m45_s_folded",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "goat",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "panda",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "pitbull",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "eagle",
			amount = 2
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_m4_g_mgrip",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_i_singlefire",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_p226_co_comp_1",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_scar_b_short",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_scar_b_long",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_scar_s_sniper",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_m4_g_hgrip",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_i_autofire",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_scar_fg_railext",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_p226_b_long",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_p226_co_comp_2",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_mp7_m_extended",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_mp7_s_long",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_p226_b_equinox",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_mp7_b_suppressed",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_p226_g_ergo",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_p226_m_extended",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "cloth_commander",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "gage_blade",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "gage_rambo",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "gage_deltaforce",
			amount = 2
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_lmg_m249_fg_mk46",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_lmg_hk21_b_long",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_lmg_m249_b_long",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_lmg_rpk_s_standard",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_lmg_rpk_fg_standard",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_lmg_m249_s_solid",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_lmg_hk21_g_ergo",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_lmg_hk21_fg_short",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ak_g_hgrip",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_rage_extra",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_fg_midwest",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_fg_jp",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_m4_s_mk46",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_o_eotech_xps",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_o_reflex",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ak_fg_tapco",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_deagle_extra",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_fg_smr",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_o_cs",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_pis_ns_flash",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ak_g_wgrip",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_o_rx30",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ak_g_pgrip",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_shot_ns_king",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ass_ns_surefire",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ak_b_draco",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_fl_ass_laser",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_o_rx01",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_fl_ass_peq15",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_m4_m_quad",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ak_m_quad",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ns_pis_medium_slim",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ass_ns_linear",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_o_rmr",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ass_ns_jprifles",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_m4_s_crane",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "robberfly",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "spider",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "mantis",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "wasp",
			amount = 2
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_msr_body_msr",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_r93_body_wood",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_r93_b_suppressed",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_o_leupold",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_o_45iron",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_m95_barrel_short",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_msr_ns_suppressor",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_r93_b_short",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_m95_barrel_suppressed",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_m95_barrel_long",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_msr_b_long",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "silverback",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "mandril",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "skullmonkey",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "orangutang",
			amount = 2
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_sho_striker_b_suppressed",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_o_mbus_rear",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_sho_ben_s_collapsed",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_a_piercing",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_sho_ksg_b_long",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_sho_ksg_b_short",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_sho_ben_b_long",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_a_explosive",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_a_custom",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_sho_striker_b_long",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_sho_ben_s_solid",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_sho_ben_b_short",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_a_slug",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "galax",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "crowgoblin",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "evil",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "volt",
			amount = 2
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_galil_fg_sar",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_g3_s_sniper",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_g3_g_sniper",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_galil_fg_fab",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_famas_b_short",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_g3_g_retro",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_galil_s_fab",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_galil_g_sniper",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_g3_fg_railed",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_galil_s_sniper",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_g3_s_wood",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_galil_s_skeletal",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_g3_fg_retro_plastic",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_famas_b_suppressed",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_famas_b_long",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_famas_b_sniper",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_gre_m79_barrel_short",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_g3_fg_psg",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_g3_b_short",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_famas_g_retro",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_gre_m79_stock_short",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_galil_s_light",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_galil_fg_sniper",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_galil_s_wood",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_galil_s_plastic",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_g3_fg_retro",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_galil_fg_mar",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_g3_b_sniper",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "churchill",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "red_hurricane",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "patton",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "de_gaulle",
			amount = 2
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_c96_m_extended",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_sterling_m_short",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_sterling_s_nostock",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_sterling_b_short",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_mosin_iron_sight",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_mosin_b_standard",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_mosin_b_short",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_lmg_mg42_b_mg34",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_sterling_s_solid",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_mosin_b_sniper",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_sterling_m_long",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_c96_s_solid",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_lmg_mg42_b_vg38",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_c96_b_long",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_sterling_b_suppressed",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_mosin_body_black",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_c96_nozzle",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_sterling_b_long",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_sterling_s_folded",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_c96_sight",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_sterling_b_e11",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_snp_mosin_ns_bayonet",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "franklin",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "lincoln",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "grant",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "washington",
			amount = 2
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_fal_g_01",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_fal_fg_04",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_fal_s_01",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_fal_fg_wood",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_fal_fg_03",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_fal_s_03",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_fal_s_wood",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_fal_m_01",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_fal_fg_01",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "white_wolf",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "owl",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "rabbit",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "pig",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "panther",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "rooster",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "horse",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "tiger",
			amount = 2
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_scorpion_s_nostock",
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
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_uzi_b_suppressed",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_tec9_b_standard",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_uzi_fg_rail",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_tec9_s_unfolded",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_uzi_s_solid",
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
			item_entry = "wpn_fps_smg_tec9_m_extended",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_scorpion_g_wood",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_tec9_ns_ext",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_uzi_s_leather",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_smg_scorpion_g_ergo",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "medusa",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "anubis",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "pazuzu",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "cursed_crown",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "msk_grizel",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "grizel_clean",
			amount = 2
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_l85a2_b_long",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_l85a2_g_worn",
			amount = 1
		},
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
			item_entry = "wpn_fps_ass_l85a2_b_short",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "dragan",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "dragan_begins",
			amount = 2
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_vhs_b_short",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_vhs_b_silenced",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_ass_vhs_b_sniper",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "butcher",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "doctor",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "tech_lion",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "lady_butcher",
			amount = 2
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_hs2000_sl_custom",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_hs2000_m_extended",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_pis_hs2000_sl_long",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "santa_mad",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "santa_drunk",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "santa_surprise",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "nun_town",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "robo_arnold",
			amount = 2
		},
		{
			type_items = "masks",
			item_entry = "arch_nemesis",
			amount = 2
		}
	}
	self.console_mad = {
		content_on_consoles = true,
		dlc = "has_parent_dlc",
		parent_dlc = "mad",
		content = {}
	}
	self.console_mad.content.loot_global_value = "mad"
	self.console_mad.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "mad_mask",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "half_mask",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "mad_goggles",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "visor",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "nebula",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "planet",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "rusty",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "spaceship",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "hexagons",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "jimmy_phoenix",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "rebel",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "squares",
			amount = 1
		}
	}
	self.console_coco = {
		content_on_consoles = true,
		dlc = "has_parent_dlc",
		parent_dlc = "coco",
		content = {}
	}
	self.console_coco.content.loot_global_value = "coco"
	self.console_coco.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "jimmy",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "jimmy_duct",
			amount = 1
		}
	}
	self.console_pal = {
		content_on_consoles = true,
		dlc = "has_parent_dlc",
		parent_dlc = "pal",
		content = {}
	}
	self.console_pal.content.loot_global_value = "pal"
	self.console_pal.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "divided",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "viking",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "nutcracker",
			amount = 1
		},
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
			type_items = "materials",
			item_entry = "day",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "redwhite",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "mushroom_cloud",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "fenris",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "kurbits",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "luse",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "split",
			amount = 1
		}
	}
	self.console_peta = {
		content_on_consoles = true,
		dlc = "has_parent_dlc",
		parent_dlc = "peta",
		content = {}
	}
	self.console_peta.content.loot_global_value = "peta"
	self.console_peta.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "goat_goat",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "fancy_goat",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "tall_goat",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "wet_goat",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "goateye",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "flamingoeye",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "hay",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "tongue",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "giraffe",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "illumigoati",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "goatface",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "fur",
			amount = 1
		}
	}
	self.console_opera = {
		content_on_consoles = true,
		dlc = "has_parent_dlc",
		parent_dlc = "opera",
		content = {}
	}
	self.console_opera.content.loot_global_value = "opera"
	self.console_opera.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "sydney",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "sydney_begins",
			amount = 1
		}
	}
	self.console_born = {
		content_on_consoles = true,
		dlc = "has_parent_dlc",
		parent_dlc = "born",
		content = {}
	}
	self.console_born.content.loot_global_value = "born"
	self.console_born.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "born_biker_01",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "born_biker_02",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "born_biker_03",
			amount = 1
		},
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
			type_items = "materials",
			item_entry = "devil_eye",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "hotrod_red",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "shiny_and_chrome",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "biker_face",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "skull_engine",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "skull_wing",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "tire_fire",
			amount = 1
		}
	}
	self.console_wild = {
		content_on_consoles = true,
		dlc = "has_parent_dlc",
		parent_dlc = "wild",
		content = {}
	}
	self.console_wild.content.loot_global_value = "wild"
	self.console_wild.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "rust",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "rust_begins",
			amount = 1
		}
	}
	self.console_clan_migg = {
		content_on_consoles = true,
		free = true,
		content = {}
	}
	self.console_clan_migg.content.loot_global_value = "normal"
	self.console_clan_migg.content.loot_drops = {
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
	self.console_clan_fibb = {
		content_on_consoles = true,
		free = true,
		content = {}
	}
	self.console_clan_fibb.content.loot_global_value = "normal"
	self.console_clan_fibb.content.loot_drops = {
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
	self.console_gotti_bundle = {
		content_on_consoles = true,
		free = true,
		content = {}
	}
	self.console_gotti_bundle.content.loot_global_value = "normal"
	self.console_gotti_bundle.content.loot_drops = {
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
	self.console_nyck_bundle = {
		content_on_consoles = true,
		free = false,
		content = {}
	}
	self.console_nyck_bundle.content.loot_global_value = "normal"
	self.console_nyck_bundle.content.loot_drops = {
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
	self.console_urf_bundle = {
		content_on_consoles = true,
		free = false,
		content = {}
	}
	self.console_urf_bundle.content.loot_global_value = "normal"
	self.console_urf_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "urf_seal",
			amount = 1
		}
	}
	self.console_howl = {
		content_on_consoles = true,
		free = false,
		content = {}
	}
	self.console_howl.content.loot_global_value = "halloween"
	self.console_howl.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "hwl_dallas_zombie",
			amount = 1
		}
	}
	self.console_help_4 = {
		content_on_consoles = true,
		free = false,
		content = {}
	}
	self.console_help_4.content.loot_global_value = "halloween"
	self.console_help_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "hwl_wolf_zombie",
			amount = 1
		}
	}
	self.console_help_5 = {
		content_on_consoles = true,
		free = false,
		achievement_id = "orange_5",
		content = {}
	}
	self.console_help_5.content.loot_global_value = "halloween"
	self.console_help_5.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "howl_chains_zombie",
			amount = 1
		}
	}
	self.console_help_6 = {
		content_on_consoles = true,
		free = false,
		content = {}
	}
	self.console_help_6.content.loot_global_value = "halloween"
	self.console_help_6.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "hwl_hoxton_zombie",
			amount = 1
		}
	}
	self.console_moon = {
		content_on_consoles = true,
		free = true,
		content = {}
	}
	self.console_moon.content.loot_global_value = "normal"
	self.console_moon.content.loot_drops = {
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
	self.console_win_bundle = {
		content_on_consoles = true,
		free = false,
		content = {}
	}
	self.console_win_bundle.content.loot_global_value = "normal"
	self.console_win_bundle.content.loot_drops = {
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
	self.console_yor_bundle = {
		content_on_consoles = true,
		free = false,
		content = {}
	}
	self.console_yor_bundle.content.loot_global_value = "normal"
	self.console_yor_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "yor",
			amount = 1
		}
	}
	self.console_yor_bundle.content.upgrades = {
		"chinchilla"
	}
	self.console_bny_bundle = {
		content_on_consoles = true,
		free = false,
		content = {}
	}
	self.console_bny_bundle.content.loot_global_value = "normal"
	self.console_bny_bundle.content.loot_drops = {
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
	self.console_amp_bundle = {
		content_on_consoles = true,
		free = true,
		content = {}
	}
	self.console_amp_bundle.content.loot_global_value = "normal"
	self.console_amp_bundle.content.loot_drops = {
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
	self.console_mdm_bundle = {
		content_on_consoles = true,
		free = false,
		content = {}
	}
	self.console_mdm_bundle.content.loot_global_value = "infamous"
	self.console_mdm_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "mdm",
			amount = 1
		}
	}
	self.console_pim = {
		content_on_consoles = true,
		dlc = "has_parent_dlc",
		parent_dlc = "pim",
		content = {}
	}
	self.console_pim.content.loot_global_value = "pim"
	self.console_pim.content.loot_drops = {
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
		},
		{
			type_items = "masks",
			item_entry = "pim_mustang",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "pim_hotelier",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "pim_russian_ballistic",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "pim_dog",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "wheel",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "club",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "mist",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "dog",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "oneshot",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "piety",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "warface",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "daisy",
			amount = 1
		}
	}
	self.console_tango = {
		content_on_consoles = true,
		dlc = "has_parent_dlc",
		parent_dlc = "tango",
		content = {}
	}
	self.console_tango.content.loot_global_value = "tango"
	self.console_tango.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "tng_bandana",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "tng_cloaker",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "tng_zeal_swat_mask",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "tng_cap",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "army_deep_green",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "ranger_black",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "digital_camo",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "midnight_camo",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "facepaint",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "sight",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "bullets",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "stripes",
			amount = 1
		},
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
	self.console_chico_bundle = {
		content_on_consoles = true,
		dlc = "has_parent_dlc",
		parent_dlc = "chico",
		content = {}
	}
	self.console_chico_bundle.content.loot_global_value = "chico"
	self.console_chico_bundle.content.loot_drops = {
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
	self.console_friend_bundle = {
		content_on_consoles = true,
		dlc = "has_parent_dlc",
		parent_dlc = "friend",
		content = {}
	}
	self.console_friend_bundle.content.loot_global_value = "friend"
	self.console_friend_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "sfm_02",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "sfm_04",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "sfm_01",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "sfm_03",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "golden_hour",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "black_marble",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "oxidized_copper",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "red_velvet",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "scar_mask",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "diablada",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "liberty_flame",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "my_little",
			amount = 1
		}
	}
	self.console_spa_bundle = {
		content_on_consoles = true,
		dlc = "has_parent_dlc",
		parent_dlc = "spa",
		content = {}
	}
	self.console_spa_bundle.content.loot_global_value = "spa"
	self.console_spa_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "spa_04",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "spa_03",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "spa_02",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "spa_01",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "underground_neon",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "carbon_fiber_weave",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "neon_blue",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "black_suede",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "baba_yaga",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "hood_stripes",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "hotel_pattern",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "continental",
			amount = 1
		}
	}
	self.console_grv_bundle = {
		content_on_consoles = true,
		dlc = "has_parent_dlc",
		parent_dlc = "grv",
		content = {}
	}
	self.console_grv_bundle.content.loot_global_value = "grv"
	self.console_grv_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "grv_04",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "grv_01",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "grv_03",
			amount = 1
		},
		{
			type_items = "masks",
			item_entry = "grv_02",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "tricolor",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "russian_camouflage",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "propaganda_palette",
			amount = 1
		},
		{
			type_items = "materials",
			item_entry = "ceramics_gzhel",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "russian_gamble",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "red_star",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "bear_fight",
			amount = 1
		},
		{
			type_items = "textures",
			item_entry = "prison_statement",
			amount = 1
		}
	}
	self.console_flip_bundle = {
		content_on_consoles = true,
		free = true,
		content = {}
	}
	self.console_flip_bundle.content.loot_global_value = "normal"
	self.console_flip_bundle.content.loot_drops = {
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
	self.console_kwm_bundle = {
		content_on_consoles = true,
		free = true,
		content = {}
	}
	self.console_kwm_bundle.content.loot_global_value = "normal"
	self.console_kwm_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "kwm",
			amount = 1
		}
	}
	self.console_mmj_bundle = {
		content_on_consoles = true,
		free = true,
		content = {}
	}
	self.console_mmj_bundle.content.loot_global_value = "normal"
	self.console_mmj_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "mmj",
			amount = 1
		}
	}
	self.ant_free = {
		content_on_consoles = true,
		free = true,
		content = {}
	}
	self.ant_free.content.loot_global_value = "ant"
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
		content_on_consoles = true,
		content = {}
	}
	self.ant.content.loot_global_value = "ant"
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
	self.ach_eng_1 = {
		content_on_consoles = true,
		content = {},
		dlc = true,
		free = true
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
		content_on_consoles = true,
		content = {},
		dlc = true,
		free = true
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
		content_on_consoles = true,
		content = {},
		dlc = true,
		free = true
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
		content_on_consoles = true,
		content = {},
		dlc = true,
		free = true
	}
	self.ach_eng_4.content.loot_global_value = "eng"
	self.ach_eng_4.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "eng_04",
			amount = 1
		}
	}
	self.sha_bundle = {
		content = {},
		free = true,
		content_on_consoles = true
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
	self.kouti_bundle = {
		content_on_consoles = true,
		content = {}
	}
	self.kouti_bundle.content.loot_global_value = "infamous"
	self.kouti_bundle.dlc = "has_parent_dlc"
	self.kouti_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "unforsaken_mega",
			amount = 1
		},
		{
			type_items = "armor_skins",
			item_entry = "ast_armor1"
		},
		{
			type_items = "armor_skins",
			item_entry = "ast_armor2"
		},
		{
			type_items = "armor_skins",
			item_entry = "ast_armor3"
		},
		{
			type_items = "armor_skins",
			item_entry = "ast_armor4"
		},
		{
			type_items = "armor_skins",
			item_entry = "ast_armor5"
		},
		{
			type_items = "armor_skins",
			item_entry = "ast_armor6"
		}
	}
	self.dbd_clan_award = {
		dlc = true,
		free = true,
		content_on_consoles = true,
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
		content_on_consoles = true,
		dlc = true,
		content = {}
	}
	self.dbd_deluxe.content.loot_global_value = "dbd_clan"
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
	self.dbd_boo_0_award = {
		content_on_consoles = true,
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
		content_on_consoles = true,
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
		content_on_consoles = true,
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
	self.solus_clan_award = {
		free = true,
		dlc = true,
		content_on_consoles = true,
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
	self.console_wmp_bundle = {
		free = true,
		content_on_consoles = true,
		content = {}
	}
	self.console_wmp_bundle.content.loot_global_value = "normal"
	self.console_wmp_bundle.content.loot_drops = {
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
	self.console_jfr = {
		content = {},
		content_on_consoles = true
	}
	self.console_dgm_bundle = {
		free = true,
		content_on_consoles = true,
		content = {}
	}
	self.console_dgm_bundle.content.loot_global_value = "normal"
	self.console_dgm_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "dgm",
			amount = 1
		}
	}
	self.console_ach_trk_a_0 = {
		content = {},
		free = true,
		content_on_consoles = true
	}
	self.console_ach_trk_a_0.content.loot_global_value = "infamous"
	self.console_ach_trk_a_0.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "dnm",
			amount = 1
		}
	}
	self.console_cmo_bundle = {
		free = true,
		content_on_consoles = true,
		content = {}
	}
	self.console_cmo_bundle.content.loot_global_value = "normal"
	self.console_cmo_bundle.content.loot_drops = {
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
	self.console_pn2_bundle = {
		free = true,
		content_on_consoles = true,
		content = {}
	}
	self.console_pn2_bundle.content.loot_global_value = "normal"
	self.console_pn2_bundle.content.loot_drops = {}
	self.console_pbm_bundle = {
		free = true,
		content_on_consoles = true,
		content = {}
	}
	self.console_pbm_bundle.content.loot_global_value = "normal"
	self.console_pbm_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "pbm",
			amount = 1
		}
	}
	self.console_ach_cee_3 = {
		free = false,
		content_on_consoles = true,
		content = {}
	}
	self.console_ach_cee_3.content.loot_global_value = "infamous"
	self.console_ach_cee_3.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "mrm",
			amount = 1
		}
	}
	self.console_rvd_bundle = {
		content = {},
		free = true,
		content_on_consoles = true
	}
	self.console_rvd_bundle.content.loot_global_value = "rvd"
	self.console_rvd_bundle.content.loot_drops = {
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
	self.console_gcm_bundle = {
		free = true,
		content = {},
		content_on_consoles = true
	}
	self.console_gcm_bundle.content.loot_global_value = "normal"
	self.console_gcm_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "gcm",
			amount = 1
		}
	}
	self.console_ach_ggez_1 = {
		free = false,
		content_on_consoles = true,
		content = {}
	}
	self.console_ach_ggez_1.content.loot_global_value = "infamous"
	self.console_ach_ggez_1.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "ggac_od_t2",
			amount = 1
		}
	}
	self.console_ghx_bundle = {
		free = true,
		content_on_consoles = true,
		content = {}
	}
	self.console_ghx_bundle.content.loot_global_value = "normal"
	self.console_ghx_bundle.content.loot_drops = {}
	self.console_maw_bundle = {
		free = true,
		content_on_consoles = true,
		content = {}
	}
	self.console_maw_bundle.content.loot_global_value = "infamous"
	self.console_maw_bundle.content.loot_drops = {
		{
			type_items = "masks",
			item_entry = "maw_01",
			amount = 1
		}
	}
	self.console_mwm_bundle = {
		dlc = "has_parent_dlc",
		parent_dlc = "mwm",
		content_on_consoles = true,
		content = {}
	}
	self.console_mwm_bundle.content.loot_global_value = "mwm"
	self.console_mwm_bundle.content.loot_drops = {
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ns_ass_smg_v6",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_g_m4_surgeon",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_o_sig",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_o_bmg",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_o_rms",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_o_rikt",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_o_uh",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_o_fc1",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_o_45steel",
			amount = 1
		},
		{
			type_items = "weapon_mods",
			item_entry = "wpn_fps_upg_ns_pis_typhoon",
			amount = 1
		}
	}
	self.console_mex_bundle = {
		dlc = "has_parent_dlc",
		parent_dlc = "mex",
		content_on_consoles = true,
		content = {}
	}
	self.console_mex_bundle.content.loot_global_value = "mex"
	self.console_mex_bundle.content.loot_drops = {}
	self.console_trd_bundle = {
		dlc = "has_parent_dlc",
		parent_dlc = "trd",
		content_on_consoles = true,
		content = {}
	}
	self.console_trd_bundle.content.loot_global_value = "trd"
	self.console_trd_bundle.content.loot_drops = {
		{
			type_items = "player_styles",
			item_entry = "jumpsuit",
			amount = 1
		},
		{
			type_items = "player_styles",
			item_entry = "clown",
			amount = 1
		},
		{
			type_items = "player_styles",
			item_entry = "miami",
			amount = 1
		},
		{
			type_items = "player_styles",
			item_entry = "peacoat",
			amount = 1
		}
	}
end
