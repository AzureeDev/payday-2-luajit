SkillTreeTweakData = SkillTreeTweakData or class()

function SkillTreeTweakData:init()
	local function digest(value)
		return Application:digest_value(value, true)
	end

	self.tier_unlocks = {
		digest(0),
		digest(1),
		digest(3),
		digest(18)
	}
	self.costs = {
		unlock_tree = digest(0),
		default = digest(1),
		pro = digest(3),
		hightier = digest(4),
		hightierpro = digest(8)
	}
	self.unlock_tree_cost = {
		digest(0),
		digest(0),
		digest(0),
		digest(0),
		digest(0)
	}
	self.skill_pages_order = {
		"mastermind",
		"enforcer",
		"technician",
		"ghost",
		"hoxton"
	}
	self.tier_cost = {
		{
			1,
			3
		},
		{
			2,
			4
		},
		{
			3,
			6
		},
		{
			4,
			8
		}
	}
	self.num_tiers = #self.tier_cost
	self.HIDE_TIER_BONUS = true
	self.skills = {}
	self.skilltree = {
		mastermind = {
			name_id = "st_menu_mastermind",
			desc_id = "st_menu_mastermind_desc"
		},
		enforcer = {
			name_id = "st_menu_enforcer",
			desc_id = "st_menu_enforcer_desc"
		},
		technician = {
			name_id = "st_menu_technician",
			desc_id = "st_menu_technician_desc"
		},
		ghost = {
			name_id = "st_menu_ghost",
			desc_id = "st_menu_ghost_desc"
		},
		hoxton = {
			name_id = "st_menu_hoxton_pack",
			desc_id = "st_menu_hoxton_pack_desc"
		}
	}
	self.skills.black_marketeer = {
		{
			upgrades = {
				"player_hostage_health_regen_addend_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_hostage_health_regen_addend_2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_black_marketeer_beta",
		desc_id = "menu_black_marketeer_beta_desc",
		icon_xy = {
			2,
			10
		}
	}
	self.skills.gun_fighter = {
		{
			upgrades = {
				"pistol_damage_addend_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"pistol_damage_addend_2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_gun_fighter_beta",
		desc_id = "menu_gun_fighter_beta_desc",
		icon_xy = {
			7,
			11
		}
	}
	self.skills.combat_medic = {
		{
			upgrades = {
				"temporary_revive_damage_reduction_1",
				"player_revive_damage_reduction_1"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_revive_health_boost"
			},
			cost = self.costs.pro
		},
		name_id = "menu_combat_medic_beta",
		desc_id = "menu_combat_medic_beta_desc",
		icon_xy = {
			5,
			7
		}
	}
	self.skills.control_freak = {
		{
			upgrades = {
				"player_minion_master_speed_multiplier",
				"player_passive_convert_enemies_health_multiplier_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_minion_master_health_multiplier",
				"player_passive_convert_enemies_health_multiplier_2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_control_freak_beta",
		desc_id = "menu_control_freak_beta_desc",
		icon_xy = {
			1,
			10
		}
	}
	self.skills.leadership = {
		{
			upgrades = {
				"team_pistol_recoil_index_addend",
				"team_pistol_suppression_recoil_index_addend"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"team_weapon_recoil_index_addend",
				"team_weapon_suppression_recoil_index_addend"
			},
			cost = self.costs.pro
		},
		name_id = "menu_leadership_beta",
		desc_id = "menu_leadership_beta_desc",
		icon_xy = {
			7,
			7
		}
	}
	self.skills.inside_man = {
		{
			upgrades = {
				"player_civ_calming_alerts",
				"player_civ_intimidation_mul"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_additional_assets"
			},
			cost = self.costs.pro
		},
		name_id = "menu_inside_man_beta",
		desc_id = "menu_inside_man_beta_desc",
		icon_xy = {
			6,
			7
		}
	}
	self.skills.target_mark = {
		{
			upgrades = {},
			cost = self.costs.default
		},
		{
			cost = self.costs.pro
		},
		name_id = "menu_target_mark_beta",
		desc_id = "menu_target_mark_beta_desc",
		icon_xy = {
			3,
			7
		}
	}
	self.skills.dominator = {
		{
			upgrades = {},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_intimidate_range_mul",
				"player_intimidate_aura"
			},
			cost = self.costs.pro
		},
		name_id = "menu_dominator_beta",
		desc_id = "menu_dominator_beta_desc",
		icon_xy = {
			2,
			8
		}
	}
	self.skills.fast_learner = {
		{
			upgrades = {
				"player_revive_damage_reduction_level_1"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_revive_damage_reduction_level_2"
			},
			cost = self.costs.pro
		},
		name_id = "menu_fast_learner_beta",
		desc_id = "menu_fast_learner_beta_desc",
		icon_xy = {
			0,
			10
		}
	}
	self.skills.stockholm_syndrome = {
		{
			upgrades = {
				"player_civ_calming_alerts"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_super_syndrome_1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_stockholm_syndrome_beta",
		desc_id = "menu_stockholm_syndrome_beta_desc",
		icon_xy = {
			3,
			8
		}
	}
	self.skills.cable_guy = {
		{
			upgrades = {
				"player_intimidate_range_mul",
				"player_intimidate_aura",
				"player_civ_intimidation_mul"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_convert_enemies_max_minions_2"
			},
			cost = self.costs.pro
		},
		name_id = "menu_cable_guy_beta",
		desc_id = "menu_cable_guy_beta_desc",
		icon_xy = {
			2,
			8
		}
	}
	self.skills.tactician = {
		{
			upgrades = {
				"player_marked_enemy_extra_damage"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_buy_spotter_asset"
			},
			cost = self.costs.pro
		},
		name_id = "menu_tactician_beta",
		desc_id = "menu_tactician_beta_desc",
		icon_xy = {
			3,
			7
		}
	}
	self.skills.triathlete = {
		{
			upgrades = {
				"cable_tie_quantity",
				"cable_tie_interact_speed_multiplier"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"team_damage_hostage_absorption"
			},
			cost = self.costs.pro
		},
		name_id = "menu_triathlete_beta",
		desc_id = "menu_triathlete_beta_desc",
		icon_xy = {
			4,
			7
		}
	}
	self.skills.equilibrium = {
		{
			upgrades = {
				"pistol_swap_speed_multiplier"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"pistol_spread_index_addend"
			},
			cost = self.costs.pro
		},
		name_id = "menu_equilibrium_beta",
		desc_id = "menu_equilibrium_beta_desc",
		icon_xy = {
			3,
			9
		}
	}
	self.skills.negotiator = {
		{
			upgrades = {},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"pistol_fire_rate_multiplier"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_negotiator_beta",
		desc_id = "menu_negotiator_beta_desc",
		icon_xy = {
			7,
			8
		}
	}
	self.skills.medic_2x = {
		{
			upgrades = {
				"doctor_bag_quantity"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"doctor_bag_amount_increase1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_medic_2x_beta",
		desc_id = "menu_medic_2x_beta_desc",
		icon_xy = {
			5,
			8
		}
	}
	self.skills.joker = {
		{
			upgrades = {
				"player_convert_enemies_damage_multiplier_1",
				"player_convert_enemies",
				"player_convert_enemies_max_minions_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_convert_enemies_damage_multiplier_2",
				"player_convert_enemies_interaction_speed_multiplier"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_joker_beta",
		desc_id = "menu_joker_beta_desc",
		icon_xy = {
			6,
			8
		}
	}
	self.skills.inspire = {
		{
			upgrades = {
				"player_revive_interaction_speed_multiplier",
				"player_morale_boost"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"cooldown_long_dis_revive"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_inspire_beta",
		desc_id = "menu_inspire_beta_desc",
		icon_xy = {
			4,
			9
		}
	}
	self.skills.messiah = {
		{
			upgrades = {
				"player_messiah_revive_from_bleed_out_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_recharge_messiah_1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_pistol_beta_messiah",
		desc_id = "menu_pistol_beta_messiah_desc",
		icon_xy = {
			2,
			9
		}
	}
	self.skills.ammo_reservoir = {
		{
			upgrades = {
				"temporary_no_ammo_cost_1"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"temporary_no_ammo_cost_2"
			},
			cost = self.costs.pro
		},
		name_id = "menu_ammo_reservoir_beta",
		desc_id = "menu_ammo_reservoir_beta_desc",
		icon_xy = {
			4,
			5
		}
	}
	self.skills.demolition_man = {
		{
			upgrades = {},
			cost = self.costs.default
		},
		{
			upgrades = {},
			cost = self.costs.pro
		},
		name_id = "menu_demolition_man_beta",
		desc_id = "menu_demolition_man_beta_desc",
		icon_xy = {
			4,
			5
		}
	}
	self.skills.oppressor = {
		{
			upgrades = {
				"player_armor_regen_time_mul_1"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_flashbang_multiplier_1",
				"player_flashbang_multiplier_2"
			},
			cost = self.costs.pro
		},
		name_id = "menu_oppressor_beta",
		desc_id = "menu_oppressor_beta_desc",
		icon_xy = {
			2,
			12
		}
	}
	self.skills.steroids = {
		{
			upgrades = {
				"player_non_special_melee_multiplier"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_melee_damage_multiplier"
			},
			cost = self.costs.pro
		},
		name_id = "menu_steroids_beta",
		desc_id = "menu_steroids_beta_desc",
		icon_xy = {
			1,
			3
		}
	}
	self.skills.bandoliers = {
		{
			upgrades = {
				"extra_ammo_multiplier1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_pick_up_ammo_multiplier",
				"player_pick_up_ammo_multiplier_2",
				"player_regain_throwable_from_ammo_1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_bandoliers_beta",
		desc_id = "menu_bandoliers_beta_desc",
		icon_xy = {
			3,
			0
		}
	}
	self.skills.pack_mule = {
		{
			upgrades = {
				"carry_throw_distance_multiplier"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_armor_carry_bonus_1"
			},
			cost = self.costs.pro
		},
		name_id = "menu_pack_mule_beta",
		desc_id = "menu_pack_mule_beta_desc",
		icon_xy = {
			8,
			8
		}
	}
	self.skills.shotgun_impact = {
		{
			upgrades = {
				"shotgun_recoil_index_addend",
				"shotgun_damage_multiplier_1"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"shotgun_damage_multiplier_2"
			},
			cost = self.costs.pro
		},
		name_id = "menu_shotgun_impact_beta",
		desc_id = "menu_shotgun_impact_beta_desc",
		icon_xy = {
			4,
			1
		}
	}
	self.skills.portable_saw = {
		{
			upgrades = {
				"saw_secondary"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"saw_extra_ammo_multiplier",
				"player_saw_speed_multiplier_2",
				"saw_lock_damage_multiplier_2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_portable_saw_beta",
		desc_id = "menu_portable_saw_beta_desc",
		icon_xy = {
			0,
			1
		}
	}
	self.skills.tough_guy = {
		{
			upgrades = {
				"player_damage_shake_multiplier"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_bleed_out_health_multiplier"
			},
			cost = self.costs.pro
		},
		name_id = "menu_tough_guy_beta",
		desc_id = "menu_tough_guy_beta_desc",
		icon_xy = {
			0,
			0
		}
	}
	self.skills.underdog = {
		{
			upgrades = {
				"player_damage_multiplier_outnumbered"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_damage_dampener_outnumbered"
			},
			cost = self.costs.pro
		},
		name_id = "menu_underdog_beta",
		desc_id = "menu_underdog_beta_desc",
		icon_xy = {
			2,
			1
		}
	}
	self.skills.juggernaut = {
		{
			upgrades = {
				"player_armor_multiplier"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"body_armor6"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_juggernaut_beta",
		desc_id = "menu_juggernaut_beta_desc",
		icon_xy = {
			3,
			1
		}
	}
	self.skills.from_the_hip = {
		{
			upgrades = {
				"shotgun_hip_fire_spread_index_addend"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"weapon_hip_fire_spread_index_addend"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_from_the_hip_beta",
		desc_id = "menu_from_the_hip_beta_desc",
		icon_xy = {
			4,
			1
		}
	}
	self.skills.shotgun_cqb = {
		{
			upgrades = {
				"shotgun_reload_speed_multiplier_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"shotgun_enter_steelsight_speed_multiplier",
				"shotgun_reload_speed_multiplier_2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_shotgun_cqb_beta",
		desc_id = "menu_shotgun_cqb_beta_desc",
		icon_xy = {
			8,
			7
		}
	}
	self.skills.shades = {
		{
			upgrades = {
				"player_flashbang_multiplier_1"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_flashbang_multiplier_2"
			},
			cost = self.costs.pro
		},
		name_id = "menu_shades_beta",
		desc_id = "menu_shades_beta_desc",
		icon_xy = {
			6,
			1
		}
	}
	self.skills.ammo_2x = {
		{
			upgrades = {
				"ammo_bag_quantity"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"ammo_bag_ammo_increase1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_ammo_2x_beta",
		desc_id = "menu_ammo_2x_beta_desc",
		icon_xy = {
			7,
			1
		}
	}
	self.skills.carbon_blade = {
		{
			upgrades = {
				"saw_enemy_slicer"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"saw_ignore_shields_1",
				"saw_panic_when_kill_1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_carbon_blade_beta",
		desc_id = "menu_carbon_blade_beta_desc",
		icon_xy = {
			0,
			2
		}
	}
	self.skills.show_of_force = {
		{
			upgrades = {
				"player_interacting_damage_multiplier"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_level_2_armor_addend",
				"player_level_3_armor_addend",
				"player_level_4_armor_addend"
			},
			cost = self.costs.pro
		},
		name_id = "menu_show_of_force_beta",
		desc_id = "menu_show_of_force_beta_desc",
		icon_xy = {
			8,
			9
		}
	}
	self.skills.wolverine = {
		{
			upgrades = {
				"player_melee_damage_health_ratio_multiplier"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_damage_health_ratio_multiplier"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_wolverine_beta",
		desc_id = "menu_wolverine_beta_desc",
		icon_xy = {
			2,
			2
		}
	}
	self.skills.overkill = {
		{
			upgrades = {
				"player_overkill_damage_multiplier"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_overkill_all_weapons",
				"weapon_swap_speed_multiplier"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_overkill_beta",
		desc_id = "menu_overkill_beta_desc",
		icon_xy = {
			3,
			2
		}
	}
	self.skills.mag_plus = {
		{
			upgrades = {
				"weapon_clip_ammo_increase_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"weapon_clip_ammo_increase_2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_mag_plus_beta",
		desc_id = "menu_mag_plus_beta_desc",
		icon_xy = {
			2,
			0
		}
	}
	self.skills.iron_man = {
		{
			upgrades = {
				"team_armor_regen_time_multiplier"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_shield_knock"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_iron_man_beta",
		desc_id = "menu_iron_man_beta_desc",
		icon_xy = {
			8,
			10
		}
	}
	self.skills.rifleman = {
		{
			upgrades = {
				"weapon_enter_steelsight_speed_multiplier",
				"player_steelsight_normal_movement_speed"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"assault_rifle_zoom_increase",
				"snp_zoom_increase",
				"smg_zoom_increase",
				"lmg_zoom_increase",
				"pistol_zoom_increase",
				"assault_rifle_move_spread_index_addend",
				"snp_move_spread_index_addend",
				"smg_move_spread_index_addend"
			},
			cost = self.costs.pro
		},
		name_id = "menu_rifleman_beta",
		desc_id = "menu_rifleman_beta_desc",
		icon_xy = {
			6,
			5
		}
	}
	self.skills.blast_radius = {
		{
			upgrades = {},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_carry_sentry_and_trip"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_blast_radius_beta",
		desc_id = "menu_blast_radius_beta_desc",
		icon_xy = {
			7,
			9
		}
	}
	self.skills.insulation = {
		{
			upgrades = {
				"player_taser_malfunction"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_taser_self_shock",
				"player_escape_taser_1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_insulation_beta",
		desc_id = "menu_insulation_beta_desc",
		icon_xy = {
			3,
			5
		}
	}
	self.skills.hardware_expert = {
		{
			upgrades = {
				"player_drill_fix_interaction_speed_multiplier",
				"player_trip_mine_deploy_time_multiplier_2",
				"player_drill_alert",
				"player_silent_drill"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_drill_autorepair_1"
			},
			cost = self.costs.pro
		},
		name_id = "menu_hardware_expert_beta",
		desc_id = "menu_hardware_expert_beta_desc",
		icon_xy = {
			9,
			6
		}
	}
	self.skills.trip_mine_expert = {
		{
			upgrades = {},
			cost = self.costs.default
		},
		{
			upgrades = {},
			cost = self.costs.pro
		},
		name_id = "menu_trip_mine_expert_beta",
		desc_id = "menu_trip_mine_expert_beta_desc",
		icon_xy = {
			8,
			0
		}
	}
	self.skills.sharpshooter = {
		{
			upgrades = {
				"weapon_single_spread_index_addend"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"single_shot_accuracy_inc_1"
			},
			cost = self.costs.pro
		},
		name_id = "menu_sharpshooter_beta",
		desc_id = "menu_sharpshooter_beta_desc",
		icon_xy = {
			8,
			1
		}
	}
	self.skills.sentry_gun = {
		{
			upgrades = {
				"sentry_gun"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"sentry_gun_armor_multiplier"
			},
			cost = self.costs.pro
		},
		name_id = "menu_sentry_gun_beta",
		desc_id = "menu_sentry_gun_beta_desc",
		icon_xy = {
			7,
			5
		}
	}
	self.skills.sentry_targeting_package = {
		{
			upgrades = {
				"sentry_gun_spread_multiplier"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"sentry_gun_rot_speed_multiplier",
				"sentry_gun_extra_ammo_multiplier_1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_sentry_targeting_package_beta",
		desc_id = "menu_sentry_targeting_package_beta_desc",
		icon_xy = {
			9,
			1
		}
	}
	self.skills.sentry_2_0 = {
		{
			upgrades = {
				"sentry_gun_can_reload"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"sentry_gun_shield"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_sentry_2_0_beta",
		desc_id = "menu_sentry_2_0_beta_desc",
		icon_xy = {
			5,
			6
		}
	}
	self.skills.drill_expert = {
		{
			upgrades = {
				"player_drill_speed_multiplier1"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_drill_speed_multiplier2"
			},
			cost = self.costs.pro
		},
		name_id = "menu_drill_expert_beta",
		desc_id = "menu_drill_expert_beta_desc",
		icon_xy = {
			3,
			6
		}
	}
	self.skills.military_grade = {
		{
			upgrades = {
				"trip_mine_quantity_increase_2"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {},
			cost = self.costs.hightierpro
		},
		name_id = "menu_military_grade_beta",
		desc_id = "menu_military_grade_beta_desc",
		icon_xy = {
			4,
			6
		}
	}
	self.skills.dye_pack_removal = {
		{
			upgrades = {
				"player_dye_pack_chance_multiplier"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_dye_pack_cash_loss_multiplier"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_dye_pack_removal_beta",
		desc_id = "menu_dye_pack_removal_beta_desc",
		icon_xy = {
			0,
			6
		}
	}
	self.skills.silent_drilling = {
		{
			upgrades = {},
			cost = self.costs.hightier
		},
		{
			upgrades = {},
			cost = self.costs.hightierpro
		},
		name_id = "menu_silent_drilling_beta",
		desc_id = "menu_silent_drilling_beta_desc",
		icon_xy = {
			2,
			6
		}
	}
	self.skills.discipline = {
		{
			upgrades = {
				"player_interacting_damage_multiplier"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_steelsight_when_downed"
			},
			cost = self.costs.pro
		},
		name_id = "menu_discipline_beta",
		desc_id = "menu_discipline_beta_desc",
		icon_xy = {
			6,
			6
		}
	}
	self.skills.trip_miner = {
		{
			upgrades = {
				"trip_mine_quantity_increase_1"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_trip_mine_deploy_time_multiplier"
			},
			cost = self.costs.pro
		},
		name_id = "menu_trip_miner_beta",
		desc_id = "menu_trip_miner_beta_desc",
		icon_xy = {
			2,
			5
		}
	}
	self.skills.shaped_charge = {
		{
			upgrades = {
				"trip_mine_quantity_increase_2"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_trip_mine_shaped_charge"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_shaped_charge_beta",
		desc_id = "menu_shaped_charge_beta_desc",
		icon_xy = {
			0,
			7
		}
	}
	self.skills.ecm_booster = {
		{
			upgrades = {
				"ecm_jammer_duration_multiplier",
				"ecm_jammer_feedback_duration_boost"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"ecm_jammer_can_open_sec_doors"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_ecm_booster_beta",
		desc_id = "menu_ecm_booster_beta_desc",
		icon_xy = {
			6,
			3
		}
	}
	self.skills.sprinter = {
		{
			upgrades = {
				"player_stamina_regen_timer_multiplier",
				"player_stamina_regen_multiplier",
				"player_run_speed_multiplier"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_run_dodge_chance"
			},
			cost = self.costs.pro
		},
		name_id = "menu_sprinter_beta",
		desc_id = "menu_sprinter_beta_desc",
		icon_xy = {
			10,
			5
		}
	}
	self.skills.smg_training = {
		{
			upgrades = {
				"smg_reload_speed_multiplier"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"smg_recoil_multiplier"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_smg_training_beta",
		desc_id = "menu_smg_training_beta_desc",
		icon_xy = {
			3,
			3
		}
	}
	self.skills.smg_master = {
		{
			upgrades = {
				"smg_reload_speed_multiplier"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"smg_fire_rate_multiplier"
			},
			cost = self.costs.pro
		},
		name_id = "menu_smg_master_beta",
		desc_id = "menu_smg_master_beta_desc",
		icon_xy = {
			3,
			3
		}
	}
	self.skills.transporter = {
		{
			upgrades = {
				"carry_interact_speed_multiplier_1"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_armor_carry_bonus_1"
			},
			cost = self.costs.pro
		},
		name_id = "menu_transporter_beta",
		desc_id = "menu_transporter_beta_desc",
		icon_xy = {
			4,
			3
		}
	}
	self.skills.cat_burglar = {
		{
			upgrades = {},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_respawn_time_multiplier"
			},
			cost = self.costs.pro
		},
		name_id = "menu_cat_burglar_beta",
		desc_id = "menu_cat_burglar_beta_desc",
		icon_xy = {
			0,
			4
		}
	}
	self.skills.chameleon = {
		{
			upgrades = {
				"player_standstill_omniscience"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_buy_bodybags_asset",
				"player_additional_assets",
				"player_cleaner_cost_multiplier",
				"player_buy_spotter_asset"
			},
			cost = self.costs.pro
		},
		name_id = "menu_chameleon_beta",
		desc_id = "menu_chameleon_beta_desc",
		icon_xy = {
			6,
			10
		}
	}
	self.skills.cleaner = {
		{
			upgrades = {
				"player_corpse_dispose_amount_2",
				"player_extra_corpse_dispose_amount"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"bodybags_bag_quantity"
			},
			cost = self.costs.pro
		},
		name_id = "menu_cleaner_beta",
		desc_id = "menu_cleaner_beta_desc",
		icon_xy = {
			7,
			2
		}
	}
	self.skills.ecm_2x = {
		{
			upgrades = {
				"ecm_jammer_quantity_increase_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"ecm_jammer_duration_multiplier_2",
				"ecm_jammer_feedback_duration_boost_2",
				"ecm_jammer_affects_pagers"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_ecm_2x_beta",
		desc_id = "menu_ecm_2x_beta_desc",
		icon_xy = {
			3,
			4
		}
	}
	self.skills.assassin = {
		{
			upgrades = {
				"player_walk_speed_multiplier",
				"player_crouch_speed_multiplier"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_silent_kill"
			},
			cost = self.costs.pro
		},
		name_id = "menu_assassin_beta",
		desc_id = "menu_assassin_beta_desc",
		icon_xy = {
			0,
			3
		}
	}
	self.skills.martial_arts = {
		{
			upgrades = {
				"player_melee_damage_dampener"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_melee_knockdown_mul"
			},
			cost = self.costs.pro
		},
		name_id = "menu_martial_arts_beta",
		desc_id = "menu_martial_arts_beta_desc",
		icon_xy = {
			11,
			7
		}
	}
	self.skills.nine_lives = {
		{
			upgrades = {
				"player_bleed_out_health_multiplier"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_additional_lives_1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_nine_lives_beta",
		desc_id = "menu_nine_lives_beta_desc",
		icon_xy = {
			5,
			2
		}
	}
	self.skills.ecm_feedback = {
		{
			upgrades = {},
			cost = self.costs.hightier
		},
		{
			upgrades = {},
			cost = self.costs.hightierpro
		},
		name_id = "menu_ecm_feedback_beta",
		desc_id = "menu_ecm_feedback_beta_desc",
		icon_xy = {
			6,
			2
		}
	}
	self.skills.moving_target = {
		{
			upgrades = {
				"player_can_strafe_run"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {},
			cost = self.costs.hightierpro
		},
		name_id = "menu_moving_target_beta",
		desc_id = "menu_moving_target_beta_desc",
		icon_xy = {
			2,
			4
		}
	}
	self.skills.scavenger = {
		{
			upgrades = {
				"temporary_damage_speed_multiplier"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_team_damage_speed_multiplier_send"
			},
			cost = self.costs.pro
		},
		name_id = "menu_scavenger_beta",
		desc_id = "menu_scavenger_beta_desc",
		icon_xy = {
			10,
			9
		}
	}
	self.skills.silence_expert = {
		{
			upgrades = {
				"weapon_silencer_recoil_index_addend",
				"weapon_silencer_enter_steelsight_speed_multiplier"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"weapon_silencer_spread_index_addend"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_silence_expert_beta",
		desc_id = "menu_silence_expert_beta_desc",
		icon_xy = {
			4,
			4
		}
	}
	self.skills.good_luck_charm = {
		{
			upgrades = {
				"player_tape_loop_duration_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {},
			cost = self.costs.hightierpro
		},
		name_id = "menu_good_luck_charm_beta",
		desc_id = "menu_good_luck_charm_beta_desc",
		icon_xy = {
			4,
			2
		}
	}
	self.skills.disguise = {
		{
			cost = self.costs.hightier
		},
		{
			cost = self.costs.hightierpro
		},
		name_id = "menu_disguise_beta",
		desc_id = "menu_disguise_beta_desc",
		icon_xy = {
			6,
			4
		}
	}
	self.skills.magic_touch = {
		{
			upgrades = {
				"player_pick_lock_easy",
				"player_pick_lock_easy_speed_multiplier"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {},
			cost = self.costs.hightierpro
		},
		name_id = "menu_magic_touch_beta",
		desc_id = "menu_magic_touch_beta_desc",
		icon_xy = {
			5,
			4
		}
	}
	self.skills.freedom_call = {
		{
			upgrades = {},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_on_zipline_dodge_chance"
			},
			cost = self.costs.pro
		},
		name_id = "menu_freedom_call_beta",
		desc_id = "menu_freedom_call_beta_desc",
		icon_xy = {
			5,
			10
		}
	}
	self.skills.hidden_blade = {
		{
			upgrades = {},
			cost = self.costs.default
		},
		{
			upgrades = {},
			cost = self.costs.pro
		},
		name_id = "menu_hidden_blade_beta",
		desc_id = "menu_hidden_blade_beta_desc",
		icon_xy = {
			4,
			10
		}
	}
	self.skills.tea_time = {
		{
			upgrades = {
				"first_aid_kit_deploy_time_multiplier"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"first_aid_kit_damage_reduction_upgrade"
			},
			cost = self.costs.pro
		},
		name_id = "menu_tea_time_beta",
		desc_id = "menu_tea_time_beta_desc",
		icon_xy = {
			1,
			11
		}
	}
	self.skills.awareness = {
		{
			upgrades = {
				"player_movement_speed_multiplier",
				"player_climb_speed_multiplier_1"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_can_free_run",
				"player_run_and_reload"
			},
			cost = self.costs.pro
		},
		name_id = "menu_awareness_beta",
		desc_id = "menu_awareness_beta_desc",
		icon_xy = {
			10,
			6
		}
	}
	self.skills.alpha_dog = {
		{
			upgrades = {
				"player_crouch_dodge_chance_1"
			},
			cost = self.costs.default
		},
		{
			upgrades = {},
			cost = self.costs.pro
		},
		name_id = "menu_alpha_dog_beta",
		desc_id = "menu_alpha_dog_beta_desc",
		icon_xy = {
			0,
			11
		}
	}
	self.skills.tea_cookies = {
		{
			upgrades = {
				"first_aid_kit_quantity_increase_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"first_aid_kit_quantity_increase_2",
				"first_aid_kit_auto_recovery_1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_tea_cookies_beta",
		desc_id = "menu_tea_cookies_beta_desc",
		icon_xy = {
			2,
			11
		}
	}
	self.skills.cell_mates = {
		{
			upgrades = {
				"player_cheat_death_chance_1"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_cheat_death_chance_1"
			},
			cost = self.costs.pro
		},
		name_id = "menu_cell_mates_beta",
		desc_id = "menu_cell_mates_beta_desc",
		icon_xy = {
			4,
			11
		}
	}
	self.skills.thug_life = {
		{
			upgrades = {},
			cost = self.costs.default
		},
		{
			upgrades = {
				"pistol_reload_speed_multiplier"
			},
			cost = self.costs.pro
		},
		name_id = "menu_thug_life_beta",
		desc_id = "menu_thug_life_beta_desc",
		icon_xy = {
			3,
			12
		}
	}
	self.skills.thick_skin = {
		{
			upgrades = {
				"player_melee_concealment_modifier"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_ballistic_vest_concealment_1"
			},
			cost = self.costs.pro
		},
		name_id = "menu_thick_skin_beta",
		desc_id = "menu_thick_skin_beta_desc",
		icon_xy = {
			10,
			7
		}
	}
	self.skills.backstab = {
		{
			upgrades = {
				"player_detection_risk_add_crit_chance_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_detection_risk_add_crit_chance_2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_backstab_beta",
		desc_id = "menu_backstab_beta_desc",
		icon_xy = {
			0,
			12
		}
	}
	self.skills.drop_soap = {
		{
			upgrades = {
				"player_counter_strike_melee"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_counter_strike_spooc"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_drop_soap_beta",
		desc_id = "menu_drop_soap_beta_desc",
		icon_xy = {
			4,
			12
		}
	}
	self.skills.second_chances = {
		{
			upgrades = {
				"player_tape_loop_duration_1",
				"player_tape_loop_duration_2"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_pick_lock_hard",
				"player_pick_lock_easy_speed_multiplier"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_second_chances_beta",
		desc_id = "menu_second_chances_beta_desc",
		icon_xy = {
			10,
			4
		}
	}
	self.skills.trigger_happy = {
		{
			upgrades = {
				"pistol_stacking_hit_damage_multiplier_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"pistol_stacking_hit_damage_multiplier_2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_trigger_happy_beta",
		desc_id = "menu_trigger_happy_beta_desc",
		icon_xy = {
			11,
			2
		}
	}
	self.skills.perseverance = {
		{
			upgrades = {
				"temporary_berserker_damage_multiplier_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"temporary_berserker_damage_multiplier_2",
				"player_berserker_no_ammo_cost"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_perseverance_beta",
		desc_id = "menu_perseverance_beta_desc",
		icon_xy = {
			5,
			12
		}
	}
	self.skills.jail_workout = {
		{
			upgrades = {
				"player_suspicion_bonus",
				"player_sec_camera_highlight_mask_off",
				"player_special_enemy_highlight_mask_off"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_mask_off_pickup",
				"player_small_loot_multiplier_1"
			},
			cost = self.costs.pro
		},
		name_id = "menu_jail_workout_beta",
		desc_id = "menu_jail_workout_beta_desc",
		icon_xy = {
			5,
			3
		}
	}
	self.skills.akimbo = {
		{
			upgrades = {
				"akimbo_recoil_index_addend_2"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"akimbo_extra_ammo_multiplier_1",
				"akimbo_recoil_index_addend_3"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_akimbo_skill_beta",
		desc_id = "menu_akimbo_skill_beta_desc",
		icon_xy = {
			3,
			11
		}
	}
	self.skills.jail_diet = {
		{
			upgrades = {
				"player_detection_risk_add_dodge_chance_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_detection_risk_add_dodge_chance_2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_jail_diet_beta",
		desc_id = "menu_jail_diet_beta_desc",
		icon_xy = {
			1,
			12
		}
	}
	self.skills.prison_wife = {
		{
			upgrades = {
				"player_headshot_regen_armor_bonus_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_headshot_regen_armor_bonus_2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_prison_wife_beta",
		desc_id = "menu_prison_wife_beta_desc",
		icon_xy = {
			6,
			11
		}
	}
	self.skills.stable_shot = {
		{
			upgrades = {
				"player_stability_increase_bonus_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_not_moving_accuracy_increase_bonus_1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_stable_shot_beta",
		desc_id = "menu_stable_shot_beta_desc",
		icon_xy = {
			0,
			5
		}
	}
	self.skills.hitman = {
		{
			upgrades = {
				"player_marked_enemy_extra_damage"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_marked_inc_dmg_distance_1",
				"weapon_steelsight_highlight_specials",
				"player_mark_enemy_time_multiplier",
				"player_marked_distance_mul"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_spotter_teamwork_beta",
		desc_id = "menu_spotter_teamwork_beta_desc",
		icon_xy = {
			8,
			2
		}
	}
	self.skills.spotter_teamwork = {
		{
			upgrades = {
				"head_shot_ammo_return_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"head_shot_ammo_return_2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_single_shot_ammo_return_beta",
		desc_id = "menu_single_shot_ammo_return_beta_desc",
		icon_xy = {
			8,
			4
		}
	}
	self.skills.speedy_reload = {
		{
			upgrades = {
				"assault_rifle_reload_speed_multiplier",
				"smg_reload_speed_multiplier",
				"snp_reload_speed_multiplier"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"temporary_single_shot_fast_reload_1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_speedy_reload_beta",
		desc_id = "menu_speedy_reload_beta_desc",
		icon_xy = {
			8,
			3
		}
	}
	self.skills.far_away = {
		{
			upgrades = {
				"shotgun_steelsight_accuracy_inc_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"shotgun_steelsight_range_inc_1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_far_away_beta",
		desc_id = "menu_far_away_beta_desc",
		icon_xy = {
			8,
			5
		}
	}
	self.skills.close_by = {
		{
			upgrades = {
				"shotgun_hip_run_and_shoot_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"shotgun_hip_rate_of_fire_1",
				"shotgun_magazine_capacity_inc_1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_close_by_beta",
		desc_id = "menu_close_by_beta_desc",
		icon_xy = {
			8,
			6
		}
	}
	self.skills.scavenging = {
		{
			upgrades = {
				"player_increased_pickup_area_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_double_drop_1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_scavenging_beta",
		desc_id = "menu_scavenging_beta_desc",
		icon_xy = {
			8,
			11
		}
	}
	self.skills.defense_up = {
		{
			upgrades = {
				"sentry_gun_cost_reduction_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"sentry_gun_shield"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_defense_up_beta",
		desc_id = "menu_defense_up_beta_desc",
		icon_xy = {
			9,
			0
		}
	}
	self.skills.eco_sentry = {
		{
			upgrades = {
				"sentry_gun_cost_reduction_2"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"sentry_gun_armor_multiplier"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_eco_sentry_beta",
		desc_id = "menu_eco_sentry_beta_desc",
		icon_xy = {
			9,
			2
		}
	}
	self.skills.engineering = {
		{
			upgrades = {
				"sentry_gun_silent"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"sentry_gun_ap_bullets",
				"sentry_gun_fire_rate_reduction_1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_engineering_beta",
		desc_id = "menu_engineering_beta_desc",
		icon_xy = {
			9,
			3
		}
	}
	self.skills.jack_of_all_trades = {
		{
			upgrades = {
				"deploy_interact_faster_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"second_deployable_1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_jack_of_all_trades_beta",
		desc_id = "menu_jack_of_all_trades_beta_desc",
		icon_xy = {
			9,
			4
		}
	}
	self.skills.tower_defense = {
		{
			upgrades = {
				"sentry_gun_quantity_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"sentry_gun_quantity_2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_tower_defense_beta",
		desc_id = "menu_tower_defense_beta_desc",
		icon_xy = {
			9,
			5
		}
	}
	self.skills.kick_starter = {
		{
			upgrades = {
				"player_drill_autorepair_2"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_drill_melee_hit_restart_chance_1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_kick_starter_beta",
		desc_id = "menu_kick_starter_beta_desc",
		icon_xy = {
			9,
			8
		}
	}
	self.skills.fire_trap = {
		{
			upgrades = {
				"trip_mine_fire_trap_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"trip_mine_fire_trap_2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_fire_trap_beta",
		desc_id = "menu_fire_trap_beta_desc",
		icon_xy = {
			9,
			9
		}
	}
	self.skills.fast_fire = {
		{
			upgrades = {
				"player_automatic_mag_increase_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_ap_bullets_1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_fast_fire_beta",
		desc_id = "menu_fast_fire_beta_desc",
		icon_xy = {
			10,
			2
		}
	}
	self.skills.steady_grip = {
		{
			upgrades = {
				"player_weapon_accuracy_increase_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_stability_increase_bonus_2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_steady_grip_beta",
		desc_id = "menu_steady_grip_beta_desc",
		icon_xy = {
			9,
			11
		}
	}
	self.skills.fire_control = {
		{
			upgrades = {
				"player_hip_fire_accuracy_inc_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_weapon_movement_stability_1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_fire_control_beta",
		desc_id = "menu_fire_control_beta_desc",
		icon_xy = {
			9,
			10
		}
	}
	self.skills.shock_and_awe = {
		{
			upgrades = {
				"player_run_and_shoot_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_automatic_faster_reload_1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_shock_and_awe_beta",
		desc_id = "menu_shock_and_awe_beta_desc",
		icon_xy = {
			10,
			0
		}
	}
	self.skills.heavy_impact = {
		{
			upgrades = {
				"weapon_knock_down_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"weapon_knock_down_2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_heavy_impact_beta",
		desc_id = "menu_heavy_impact_beta_desc",
		icon_xy = {
			10,
			1
		}
	}
	self.skills.body_expertise = {
		{
			upgrades = {
				"weapon_automatic_head_shot_add_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"weapon_automatic_head_shot_add_2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_body_expertise_beta",
		desc_id = "menu_body_expertise_beta_desc",
		icon_xy = {
			10,
			3
		}
	}
	self.skills.unseen_strike = {
		{
			upgrades = {
				"player_unseen_increased_crit_chance_1",
				"player_unseen_temp_increased_crit_chance_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_unseen_increased_crit_chance_2",
				"player_unseen_temp_increased_crit_chance_2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_unseen_strike_beta",
		desc_id = "menu_unseen_strike_beta_desc",
		icon_xy = {
			10,
			11
		}
	}
	self.skills.dire_need = {
		{
			upgrades = {
				"player_armor_depleted_stagger_shot_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_armor_depleted_stagger_shot_2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_dire_need_beta",
		desc_id = "menu_dire_need_beta_desc",
		icon_xy = {
			10,
			8
		}
	}
	self.skills.up_you_go = {
		{
			upgrades = {
				"player_revived_damage_resist_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_revived_health_regain_1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_up_you_go_beta",
		desc_id = "menu_up_you_go_beta_desc",
		icon_xy = {
			11,
			4
		}
	}
	self.skills.running_from_death = {
		{
			upgrades = {
				"player_temp_swap_weapon_faster_1",
				"player_temp_reload_weapon_faster_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_temp_increased_movement_speed_1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_running_from_death_beta",
		desc_id = "menu_running_from_death_beta_desc",
		icon_xy = {
			11,
			3
		}
	}
	self.skills.dance_instructor = {
		{
			upgrades = {
				"pistol_magazine_capacity_inc_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"pistol_fire_rate_multiplier"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_dance_instructor",
		desc_id = "menu_dance_instructor_desc",
		icon_xy = {
			11,
			0
		}
	}
	self.skills.expert_handling = {
		{
			upgrades = {
				"pistol_stacked_accuracy_bonus_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"pistol_reload_speed_multiplier"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_expert_handling",
		desc_id = "menu_expert_handling_desc",
		icon_xy = {
			11,
			1
		}
	}
	self.skills.bloodthirst = {
		{
			upgrades = {
				"player_melee_damage_stacking_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_temp_melee_kill_increase_reload_speed_1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_bloodthirst",
		desc_id = "menu_bloodthirst_desc",
		icon_xy = {
			11,
			6
		}
	}
	self.skills.feign_death = {
		{
			upgrades = {
				"player_cheat_death_chance_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_cheat_death_chance_2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_feign_death",
		desc_id = "menu_feign_death_desc",
		icon_xy = {
			11,
			5
		}
	}
	self.skills.frenzy = {
		{
			upgrades = {
				"player_healing_reduction_1",
				"player_health_damage_reduction_1",
				"player_max_health_reduction_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_healing_reduction_2",
				"player_health_damage_reduction_2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_frenzy",
		desc_id = "menu_frenzy_desc",
		icon_xy = {
			11,
			8
		}
	}
	self.skills.optic_illusions = {
		{
			upgrades = {
				"player_camouflage_bonus_1",
				"player_camouflage_bonus_2"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_silencer_concealment_penalty_decrease_1",
				"player_silencer_concealment_increase_1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_optic_illusions",
		desc_id = "menu_optic_illusions_desc",
		icon_xy = {
			10,
			10
		}
	}
	self.skills.more_fire_power = {
		{
			upgrades = {
				"shape_charge_quantity_increase_1",
				"trip_mine_quantity_increase_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"shape_charge_quantity_increase_2",
				"trip_mine_quantity_increase_2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_more_fire_power",
		desc_id = "menu_more_fire_power_desc",
		icon_xy = {
			9,
			7
		}
	}
	self.skills.combat_engineering = {
		{
			upgrades = {
				"trip_mine_explosion_size_multiplier_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"trip_mine_damage_multiplier_1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_combat_engineering",
		desc_id = "menu_combat_engineering_desc",
		icon_xy = {
			1,
			5
		}
	}
	self.skills.single_shot_ammo_return = {
		{
			upgrades = {
				"snp_graze_damage_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"snp_graze_damage_2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_sniper_graze_damage",
		desc_id = "menu_sniper_graze_damage_desc",
		icon_xy = {
			11,
			9
		}
	}
	self.trees = {
		{
			skill = "mastermind",
			name_id = "st_menu_mastermind_inspire",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"combat_medic"
				},
				{
					"tea_time",
					"fast_learner"
				},
				{
					"tea_cookies",
					"medic_2x"
				},
				{
					"inspire"
				}
			}
		},
		{
			skill = "mastermind",
			name_id = "st_menu_mastermind_dominate",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"triathlete"
				},
				{
					"cable_guy",
					"joker"
				},
				{
					"stockholm_syndrome",
					"control_freak"
				},
				{
					"black_marketeer"
				}
			}
		},
		{
			skill = "mastermind",
			name_id = "st_menu_mastermind_single_shot",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"stable_shot"
				},
				{
					"rifleman",
					"sharpshooter"
				},
				{
					"spotter_teamwork",
					"speedy_reload"
				},
				{
					"single_shot_ammo_return"
				}
			}
		},
		{
			skill = "enforcer",
			name_id = "st_menu_enforce_shotgun",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"underdog"
				},
				{
					"shotgun_cqb",
					"shotgun_impact"
				},
				{
					"far_away",
					"close_by"
				},
				{
					"overkill"
				}
			}
		},
		{
			skill = "enforcer",
			name_id = "st_menu_enforcer_armor",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"oppressor"
				},
				{
					"show_of_force",
					"pack_mule"
				},
				{
					"iron_man",
					"prison_wife"
				},
				{
					"juggernaut"
				}
			}
		},
		{
			skill = "enforcer",
			name_id = "st_menu_enforcer_ammo",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"scavenging"
				},
				{
					"ammo_reservoir",
					"portable_saw"
				},
				{
					"ammo_2x",
					"carbon_blade"
				},
				{
					"bandoliers"
				}
			}
		},
		{
			skill = "technician",
			name_id = "st_menu_technician_sentry",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"defense_up"
				},
				{
					"sentry_targeting_package",
					"eco_sentry"
				},
				{
					"engineering",
					"jack_of_all_trades"
				},
				{
					"tower_defense"
				}
			}
		},
		{
			skill = "technician",
			name_id = "st_menu_technician_breaching",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"hardware_expert"
				},
				{
					"combat_engineering",
					"drill_expert"
				},
				{
					"more_fire_power",
					"kick_starter"
				},
				{
					"fire_trap"
				}
			}
		},
		{
			skill = "technician",
			name_id = "st_menu_technician_auto",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"steady_grip"
				},
				{
					"heavy_impact",
					"fire_control"
				},
				{
					"shock_and_awe",
					"fast_fire"
				},
				{
					"body_expertise"
				}
			}
		},
		{
			skill = "ghost",
			name_id = "st_menu_ghost_stealth",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"jail_workout"
				},
				{
					"cleaner",
					"chameleon"
				},
				{
					"second_chances",
					"ecm_booster"
				},
				{
					"ecm_2x"
				}
			}
		},
		{
			skill = "ghost",
			name_id = "st_menu_ghost_concealed",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"sprinter"
				},
				{
					"awareness",
					"thick_skin"
				},
				{
					"dire_need",
					"insulation"
				},
				{
					"jail_diet"
				}
			}
		},
		{
			skill = "ghost",
			name_id = "st_menu_ghost_silencer",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"scavenger"
				},
				{
					"optic_illusions",
					"silence_expert"
				},
				{
					"backstab",
					"hitman"
				},
				{
					"unseen_strike"
				}
			}
		},
		{
			skill = "hoxton",
			name_id = "st_menu_fugitive_pistol_akimbo",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"equilibrium"
				},
				{
					"dance_instructor",
					"akimbo"
				},
				{
					"gun_fighter",
					"expert_handling"
				},
				{
					"trigger_happy"
				}
			}
		},
		{
			skill = "hoxton",
			name_id = "st_menu_fugitive_undead",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"nine_lives"
				},
				{
					"running_from_death",
					"up_you_go"
				},
				{
					"perseverance",
					"feign_death"
				},
				{
					"messiah"
				}
			}
		},
		{
			skill = "hoxton",
			name_id = "st_menu_fugitive_berserker",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"martial_arts"
				},
				{
					"bloodthirst",
					"steroids"
				},
				{
					"drop_soap",
					"wolverine"
				},
				{
					"frenzy"
				}
			}
		}
	}
	self.default_upgrades = {
		"player_fall_damage_multiplier",
		"player_fall_health_damage_multiplier",
		"player_silent_kill",
		"player_primary_weapon_when_downed",
		"player_intimidate_enemies",
		"player_special_enemy_highlight",
		"player_hostage_trade",
		"player_sec_camera_highlight",
		"player_corpse_dispose",
		"player_corpse_dispose_amount_1",
		"player_civ_harmless_melee",
		"player_walk_speed_multiplier",
		"player_steelsight_when_downed",
		"player_crouch_speed_multiplier",
		"carry_interact_speed_multiplier_1",
		"carry_interact_speed_multiplier_2",
		"carry_movement_speed_multiplier",
		"trip_mine_sensor_toggle",
		"trip_mine_sensor_highlight",
		"trip_mine_can_switch_on_off",
		"ecm_jammer_can_activate_feedback",
		"ecm_jammer_interaction_speed_multiplier",
		"ecm_jammer_can_retrigger",
		"ecm_jammer_affects_cameras",
		"striker_reload_speed_default",
		"temporary_first_aid_damage_reduction",
		"temporary_passive_revive_damage_reduction_2",
		"akimbo_recoil_index_addend_1",
		"doctor_bag",
		"ammo_bag",
		"trip_mine",
		"ecm_jammer",
		"first_aid_kit",
		"sentry_gun",
		"bodybags_bag",
		"saw",
		"cable_tie",
		"jowi",
		"x_1911",
		"x_b92fs",
		"x_deagle",
		"x_g22c",
		"x_g17",
		"x_usp",
		"x_sr2",
		"x_mp5",
		"x_akmsu",
		"x_packrat",
		"x_p226",
		"x_m45",
		"x_mp7",
		"x_ppk"
	}
	self.skill_switches = {
		{
			name_id = "menu_st_skill_switch_1"
		},
		{
			name_id = "menu_st_skill_switch_2",
			locks = {
				level = 50
			}
		},
		{
			name_id = "menu_st_skill_switch_3",
			locks = {
				level = 75
			}
		},
		{
			name_id = "menu_st_skill_switch_4",
			locks = {
				level = 100
			}
		},
		{
			name_id = "menu_st_skill_switch_5",
			locks = {
				level = 100
			}
		},
		{
			name_id = "menu_st_skill_switch_6",
			locks = {
				level = 100
			}
		},
		{
			name_id = "menu_st_skill_switch_7",
			locks = {
				level = 100
			}
		},
		{
			name_id = "menu_st_skill_switch_8",
			locks = {
				level = 100
			}
		},
		{
			name_id = "menu_st_skill_switch_9",
			locks = {
				level = 100
			}
		},
		{
			name_id = "menu_st_skill_switch_10",
			locks = {
				level = 100
			}
		},
		{
			name_id = "menu_st_skill_switch_11",
			locks = {
				level = 100
			}
		},
		{
			name_id = "menu_st_skill_switch_12",
			locks = {
				level = 100
			}
		},
		{
			name_id = "menu_st_skill_switch_13",
			locks = {
				level = 100
			}
		},
		{
			name_id = "menu_st_skill_switch_14",
			locks = {
				level = 100
			}
		},
		{
			name_id = "menu_st_skill_switch_15",
			locks = {
				achievement = "frog_1",
				level = 100
			}
		}
	}
	self.specialization_convertion_rate = {
		100,
		200,
		300,
		400,
		500,
		600,
		700,
		800,
		900,
		1000
	}
	local deck2 = {
		cost = 300,
		desc_id = "menu_deckall_2_desc",
		name_id = "menu_deckall_2",
		upgrades = {
			"weapon_passive_headshot_damage_multiplier"
		},
		icon_xy = {
			1,
			0
		}
	}
	local deck4 = {
		cost = 600,
		desc_id = "menu_deckall_4_desc",
		name_id = "menu_deckall_4",
		upgrades = {
			"passive_player_xp_multiplier",
			"player_passive_suspicion_bonus",
			"player_passive_armor_movement_penalty_multiplier"
		},
		icon_xy = {
			3,
			0
		}
	}
	local deck6 = {
		cost = 1600,
		desc_id = "menu_deckall_6_desc",
		name_id = "menu_deckall_6",
		upgrades = {
			"armor_kit",
			"player_pick_up_ammo_multiplier"
		},
		icon_xy = {
			5,
			0
		}
	}
	local deck8 = {
		cost = 3200,
		desc_id = "menu_deckall_8_desc",
		name_id = "menu_deckall_8",
		upgrades = {
			"weapon_passive_damage_multiplier",
			"passive_doctor_bag_interaction_speed_multiplier"
		},
		icon_xy = {
			7,
			0
		}
	}
	self.specializations = {
		{
			{
				cost = 200,
				desc_id = "menu_deck1_1_desc",
				name_id = "menu_deck1_1",
				upgrades = {
					"team_damage_reduction_1",
					"player_passive_damage_reduction_1"
				},
				icon_xy = {
					0,
					0
				}
			},
			deck2,
			{
				cost = 400,
				desc_id = "menu_deck1_3_desc",
				name_id = "menu_deck1_3",
				upgrades = {
					"team_passive_stamina_multiplier_1",
					"player_passive_intimidate_range_mul",
					"player_damage_dampener_close_contact_1"
				},
				icon_xy = {
					2,
					0
				}
			},
			deck4,
			{
				cost = 1000,
				desc_id = "menu_deck1_5_desc",
				name_id = "menu_deck1_5",
				upgrades = {
					"team_passive_health_multiplier",
					"player_passive_health_multiplier_1"
				},
				icon_xy = {
					4,
					0
				}
			},
			deck6,
			{
				cost = 2400,
				desc_id = "menu_deck1_7_desc",
				name_id = "menu_deck1_7",
				upgrades = {
					"player_tier_armor_multiplier_1",
					"team_passive_armor_multiplier"
				},
				icon_xy = {
					6,
					0
				}
			},
			deck8,
			{
				cost = 4000,
				desc_id = "menu_deck1_9_desc",
				name_id = "menu_deck1_9",
				upgrades = {
					"player_passive_loot_drop_multiplier",
					"team_hostage_health_multiplier",
					"team_hostage_stamina_multiplier",
					"team_hostage_damage_dampener_multiplier"
				},
				icon_xy = {
					0,
					1
				}
			},
			desc_id = "menu_st_spec_1_desc",
			name_id = "menu_st_spec_1"
		},
		{
			{
				cost = 200,
				desc_id = "menu_deck2_1_desc",
				name_id = "menu_deck2_1",
				upgrades = {
					"player_passive_health_multiplier_1"
				},
				icon_xy = {
					0,
					0
				}
			},
			deck2,
			{
				cost = 400,
				desc_id = "menu_deck2_3_desc",
				name_id = "menu_deck2_3",
				upgrades = {
					"player_passive_health_multiplier_2",
					"player_uncover_multiplier"
				},
				icon_xy = {
					1,
					1
				}
			},
			deck4,
			{
				cost = 1000,
				desc_id = "menu_deck2_5_desc",
				name_id = "menu_deck2_5",
				upgrades = {
					"player_passive_health_multiplier_3"
				},
				icon_xy = {
					2,
					1
				}
			},
			deck6,
			{
				cost = 2400,
				desc_id = "menu_deck2_7_desc",
				name_id = "menu_deck2_7",
				upgrades = {
					"player_panic_suppression"
				},
				icon_xy = {
					3,
					1
				}
			},
			deck8,
			{
				cost = 4000,
				desc_id = "menu_deck2_9_desc",
				name_id = "menu_deck2_9",
				upgrades = {
					"player_passive_loot_drop_multiplier",
					"player_passive_health_multiplier_4",
					"player_passive_health_regen"
				},
				icon_xy = {
					4,
					1
				}
			},
			desc_id = "menu_st_spec_2_desc",
			name_id = "menu_st_spec_2"
		},
		{
			{
				cost = 200,
				desc_id = "menu_deck3_1_desc",
				name_id = "menu_deck3_1",
				upgrades = {
					"player_tier_armor_multiplier_1",
					"player_tier_armor_multiplier_2"
				},
				icon_xy = {
					6,
					0
				}
			},
			deck2,
			{
				cost = 400,
				desc_id = "menu_deck3_3_desc",
				name_id = "menu_deck3_3",
				upgrades = {
					"player_tier_armor_multiplier_3"
				},
				icon_xy = {
					5,
					1
				}
			},
			deck4,
			{
				cost = 1000,
				desc_id = "menu_deck3_5_desc",
				name_id = "menu_deck3_5",
				upgrades = {
					"player_tier_armor_multiplier_4"
				},
				icon_xy = {
					7,
					1
				}
			},
			deck6,
			{
				cost = 2400,
				desc_id = "menu_deck3_7_desc",
				name_id = "menu_deck3_7",
				upgrades = {
					"player_armor_regen_timer_multiplier_passive",
					"temporary_armor_break_invulnerable_1"
				},
				icon_xy = {
					6,
					1
				}
			},
			deck8,
			{
				cost = 4000,
				desc_id = "menu_deck3_9_desc",
				name_id = "menu_deck3_9",
				upgrades = {
					"player_passive_loot_drop_multiplier",
					"player_tier_armor_multiplier_5",
					"player_tier_armor_multiplier_6",
					"team_passive_armor_regen_time_multiplier"
				},
				icon_xy = {
					0,
					2
				}
			},
			desc_id = "menu_st_spec_3_desc",
			name_id = "menu_st_spec_3"
		},
		{
			{
				cost = 200,
				desc_id = "menu_deck4_1_desc",
				name_id = "menu_deck4_1",
				upgrades = {
					"player_passive_dodge_chance_1"
				},
				icon_xy = {
					1,
					2
				}
			},
			deck2,
			{
				cost = 400,
				desc_id = "menu_deck4_3_desc",
				name_id = "menu_deck4_3",
				upgrades = {
					"player_camouflage_multiplier"
				},
				icon_xy = {
					4,
					2
				}
			},
			deck4,
			{
				cost = 1000,
				desc_id = "menu_deck4_5_desc",
				name_id = "menu_deck4_5",
				upgrades = {
					"player_passive_dodge_chance_2"
				},
				icon_xy = {
					2,
					2
				}
			},
			deck6,
			{
				cost = 2400,
				desc_id = "menu_deck4_7_desc",
				name_id = "menu_deck4_7",
				upgrades = {
					"player_passive_dodge_chance_3"
				},
				icon_xy = {
					3,
					2
				}
			},
			deck8,
			{
				cost = 4000,
				desc_id = "menu_deck4_9_desc",
				name_id = "menu_deck4_9",
				upgrades = {
					"player_passive_loot_drop_multiplier",
					"weapon_passive_armor_piercing_chance",
					"weapon_passive_swap_speed_multiplier_1"
				},
				icon_xy = {
					5,
					2
				}
			},
			desc_id = "menu_st_spec_4_desc",
			name_id = "menu_st_spec_4"
		},
		{
			{
				cost = 200,
				desc_id = "menu_deck5_1_desc",
				name_id = "menu_deck5_1",
				upgrades = {
					"player_perk_armor_regen_timer_multiplier_1"
				},
				icon_xy = {
					6,
					2
				}
			},
			deck2,
			{
				cost = 400,
				desc_id = "menu_deck5_3_desc",
				name_id = "menu_deck5_3",
				upgrades = {
					"player_perk_armor_regen_timer_multiplier_2",
					"akimbo_recoil_index_addend_4",
					"akimbo_extra_ammo_multiplier_2"
				},
				icon_xy = {
					7,
					2
				}
			},
			deck4,
			{
				cost = 1000,
				desc_id = "menu_deck5_5_desc",
				name_id = "menu_deck5_5",
				upgrades = {
					"player_perk_armor_regen_timer_multiplier_3"
				},
				icon_xy = {
					0,
					3
				}
			},
			deck6,
			{
				cost = 2400,
				desc_id = "menu_deck5_7_desc",
				name_id = "menu_deck5_7",
				upgrades = {
					"player_perk_armor_regen_timer_multiplier_4"
				},
				icon_xy = {
					1,
					3
				}
			},
			deck8,
			{
				cost = 4000,
				desc_id = "menu_deck5_9_desc",
				name_id = "menu_deck5_9",
				upgrades = {
					"player_passive_loot_drop_multiplier",
					"player_perk_armor_regen_timer_multiplier_5",
					"player_passive_always_regen_armor_1"
				},
				icon_xy = {
					3,
					3
				}
			},
			desc_id = "menu_st_spec_5_desc",
			name_id = "menu_st_spec_5"
		},
		{
			{
				cost = 200,
				desc_id = "menu_deck6_1_desc",
				name_id = "menu_deck6_1",
				upgrades = {
					"player_passive_dodge_chance_1"
				},
				icon_xy = {
					1,
					2
				}
			},
			deck2,
			{
				cost = 400,
				desc_id = "menu_deck6_3_desc",
				name_id = "menu_deck6_3",
				upgrades = {
					"player_level_2_dodge_addend_1",
					"player_level_3_dodge_addend_1",
					"player_level_4_dodge_addend_1",
					"player_level_2_armor_multiplier_1",
					"player_level_3_armor_multiplier_1",
					"player_level_4_armor_multiplier_1"
				},
				icon_xy = {
					4,
					3
				}
			},
			deck4,
			{
				cost = 1000,
				desc_id = "menu_deck6_5_desc",
				name_id = "menu_deck6_5",
				upgrades = {
					"player_level_2_dodge_addend_2",
					"player_level_3_dodge_addend_2",
					"player_level_4_dodge_addend_2",
					"player_level_2_armor_multiplier_2",
					"player_level_3_armor_multiplier_2",
					"player_level_4_armor_multiplier_2"
				},
				icon_xy = {
					5,
					3
				}
			},
			deck6,
			{
				cost = 2400,
				desc_id = "menu_deck6_7_desc",
				name_id = "menu_deck6_7",
				upgrades = {
					"player_level_2_dodge_addend_3",
					"player_level_3_dodge_addend_3",
					"player_level_4_dodge_addend_3",
					"player_level_2_armor_multiplier_3",
					"player_level_3_armor_multiplier_3",
					"player_level_4_armor_multiplier_3"
				},
				icon_xy = {
					6,
					3
				}
			},
			deck8,
			{
				cost = 4000,
				desc_id = "menu_deck6_9_desc",
				name_id = "menu_deck6_9",
				upgrades = {
					"player_passive_loot_drop_multiplier",
					"player_armor_regen_timer_multiplier_tier"
				},
				icon_xy = {
					6,
					2
				}
			},
			desc_id = "menu_st_spec_6_desc",
			name_id = "menu_st_spec_6"
		},
		{
			{
				cost = 200,
				desc_id = "menu_deck7_1_desc",
				name_id = "menu_deck7_1",
				upgrades = {
					"player_tier_dodge_chance_1"
				},
				icon_xy = {
					1,
					2
				}
			},
			deck2,
			{
				cost = 400,
				desc_id = "menu_deck7_3_desc",
				name_id = "menu_deck7_3",
				upgrades = {
					"player_stand_still_crouch_camouflage_bonus_1",
					"player_corpse_dispose_speed_multiplier"
				},
				icon_xy = {
					0,
					4
				}
			},
			deck4,
			{
				cost = 1000,
				desc_id = "menu_deck7_5_desc",
				name_id = "menu_deck7_5",
				upgrades = {
					"player_tier_dodge_chance_2",
					"player_stand_still_crouch_camouflage_bonus_2",
					"player_pick_lock_speed_multiplier"
				},
				icon_xy = {
					7,
					3
				}
			},
			deck6,
			{
				cost = 2400,
				desc_id = "menu_deck7_7_desc",
				name_id = "menu_deck7_7",
				upgrades = {
					"player_tier_dodge_chance_3",
					"player_stand_still_crouch_camouflage_bonus_3",
					"player_alarm_pager_speed_multiplier"
				},
				icon_xy = {
					1,
					4
				}
			},
			deck8,
			{
				cost = 4000,
				desc_id = "menu_deck7_9_desc",
				name_id = "menu_deck7_9",
				upgrades = {
					"player_passive_loot_drop_multiplier",
					"player_armor_regen_timer_stand_still_multiplier",
					"player_crouch_speed_multiplier_2"
				},
				icon_xy = {
					2,
					4
				}
			},
			name_id = "menu_st_spec_7",
			dlc = "character_pack_clover",
			desc_id = "menu_st_spec_7_desc"
		},
		{
			{
				cost = 200,
				desc_id = "menu_deck8_7_desc",
				name_id = "menu_deck8_7",
				upgrades = {
					"player_damage_dampener_outnumbered_strong",
					"melee_stacking_hit_damage_multiplier_1"
				},
				icon_xy = {
					6,
					4
				}
			},
			deck2,
			{
				cost = 400,
				desc_id = "menu_deck8_1_desc",
				name_id = "menu_deck8_1",
				upgrades = {
					"player_damage_dampener_close_contact_1"
				},
				icon_xy = {
					3,
					4
				}
			},
			deck4,
			{
				cost = 1000,
				desc_id = "menu_deck8_3_desc",
				name_id = "menu_deck8_3",
				upgrades = {
					"player_damage_dampener_close_contact_2",
					"melee_stacking_hit_expire_t",
					"melee_stacking_hit_damage_multiplier_1"
				},
				icon_xy = {
					4,
					4
				}
			},
			deck6,
			{
				cost = 2400,
				desc_id = "menu_deck8_3_desc",
				name_id = "menu_deck8_5",
				upgrades = {
					"player_damage_dampener_close_contact_3"
				},
				icon_xy = {
					5,
					4
				}
			},
			deck8,
			{
				cost = 4000,
				desc_id = "menu_deck8_9_desc",
				name_id = "menu_deck8_9",
				upgrades = {
					"player_passive_loot_drop_multiplier",
					"player_melee_life_leech"
				},
				icon_xy = {
					7,
					4
				}
			},
			name_id = "menu_st_spec_8",
			dlc = "character_pack_dragan",
			desc_id = "menu_st_spec_8_desc"
		},
		{
			{
				cost = 200,
				desc_id = "menu_deck9_1_desc",
				name_id = "menu_deck9_1",
				upgrades = {
					"player_damage_dampener_outnumbered_strong",
					"melee_stacking_hit_damage_multiplier_1"
				},
				icon_xy = {
					6,
					4
				}
			},
			deck2,
			{
				cost = 400,
				desc_id = "menu_deck9_3_desc",
				name_id = "menu_deck9_3",
				upgrades = {
					"player_killshot_regen_armor_bonus",
					"player_tier_armor_multiplier_1",
					"player_tier_armor_multiplier_2"
				},
				icon_xy = {
					0,
					5
				}
			},
			deck4,
			{
				cost = 1000,
				desc_id = "menu_deck9_5_desc",
				name_id = "menu_deck9_5",
				upgrades = {
					"player_melee_kill_life_leech",
					"player_damage_dampener_close_contact_1"
				},
				icon_xy = {
					1,
					5
				}
			},
			deck6,
			{
				cost = 2400,
				desc_id = "menu_deck9_7_desc",
				name_id = "menu_deck9_7",
				upgrades = {
					"player_killshot_close_regen_armor_bonus",
					"player_tier_armor_multiplier_3"
				},
				icon_xy = {
					2,
					5
				}
			},
			deck8,
			{
				cost = 4000,
				desc_id = "menu_deck9_9_desc",
				name_id = "menu_deck9_9",
				upgrades = {
					"player_passive_loot_drop_multiplier",
					"player_killshot_close_panic_chance"
				},
				icon_xy = {
					3,
					5
				}
			},
			name_id = "menu_st_spec_9",
			dlc = "hlm2_deluxe",
			desc_id = "menu_st_spec_9_desc"
		},
		{
			{
				cost = 200,
				desc_id = "menu_deck10_1_desc",
				name_id = "menu_deck10_1",
				upgrades = {
					"temporary_loose_ammo_restore_health_1",
					"player_gain_life_per_players"
				},
				icon_xy = {
					4,
					5
				}
			},
			deck2,
			{
				cost = 400,
				desc_id = "menu_deck10_3_desc",
				name_id = "menu_deck10_3",
				upgrades = {
					"temporary_loose_ammo_give_team",
					"player_passive_health_multiplier_1",
					"player_passive_health_multiplier_2"
				},
				icon_xy = {
					5,
					5
				}
			},
			deck4,
			{
				cost = 1000,
				desc_id = "menu_deck10_5_desc",
				name_id = "menu_deck10_5",
				upgrades = {
					"player_loose_ammo_restore_health_give_team",
					"player_passive_health_multiplier_3"
				},
				icon_xy = {
					6,
					5
				}
			},
			deck6,
			{
				cost = 2400,
				desc_id = "menu_deck10_7_desc",
				name_id = "menu_deck10_7",
				upgrades = {
					"temporary_loose_ammo_restore_health_2"
				},
				icon_xy = {
					7,
					5
				}
			},
			deck8,
			{
				cost = 4000,
				desc_id = "menu_deck10_9_desc",
				name_id = "menu_deck10_9",
				upgrades = {
					"player_passive_loot_drop_multiplier",
					"temporary_loose_ammo_restore_health_3"
				},
				icon_xy = {
					0,
					6
				}
			},
			desc_id = "menu_st_spec_10_desc",
			name_id = "menu_st_spec_10"
		},
		{
			{
				cost = 200,
				desc_id = "menu_deck11_1_desc",
				name_id = "menu_deck11_1",
				upgrades = {
					"player_damage_to_hot_1"
				},
				icon_xy = {
					1,
					6
				}
			},
			deck2,
			{
				cost = 400,
				desc_id = "menu_deck11_3_desc",
				name_id = "menu_deck11_3",
				upgrades = {
					"player_damage_to_hot_2",
					"player_passive_health_multiplier_1",
					"player_passive_health_multiplier_2"
				},
				icon_xy = {
					2,
					6
				}
			},
			deck4,
			{
				cost = 1000,
				desc_id = "menu_deck11_5_desc",
				name_id = "menu_deck11_5",
				upgrades = {
					"player_damage_to_hot_3",
					"player_armor_piercing_chance_1"
				},
				icon_xy = {
					3,
					6
				}
			},
			deck6,
			{
				cost = 2400,
				desc_id = "menu_deck11_7_desc",
				name_id = "menu_deck11_7",
				upgrades = {
					"player_damage_to_hot_4",
					"player_passive_health_multiplier_3"
				},
				icon_xy = {
					4,
					6
				}
			},
			deck8,
			{
				cost = 4000,
				desc_id = "menu_deck11_9_desc",
				name_id = "menu_deck11_9",
				upgrades = {
					"player_passive_loot_drop_multiplier",
					"player_damage_to_hot_extra_ticks",
					"player_armor_piercing_chance_2"
				},
				icon_xy = {
					5,
					6
				}
			},
			name_id = "menu_st_spec_11",
			dlc = "character_pack_sokol",
			desc_id = "menu_st_spec_11_desc"
		},
		{
			{
				cost = 200,
				desc_id = "menu_deck12_1_desc",
				name_id = "menu_deck12_1",
				upgrades = {
					"player_armor_regen_damage_health_ratio_multiplier_1"
				},
				icon_xy = {
					6,
					6
				}
			},
			deck2,
			{
				cost = 400,
				desc_id = "menu_deck12_3_desc",
				name_id = "menu_deck12_3",
				upgrades = {
					"player_movement_speed_damage_health_ratio_multiplier"
				},
				icon_xy = {
					7,
					6
				}
			},
			deck4,
			{
				cost = 1000,
				desc_id = "menu_deck12_5_desc",
				name_id = "menu_deck12_5",
				upgrades = {
					"player_armor_regen_damage_health_ratio_multiplier_2"
				},
				icon_xy = {
					0,
					7
				}
			},
			deck6,
			{
				cost = 2400,
				desc_id = "menu_deck12_7_desc",
				name_id = "menu_deck12_7",
				upgrades = {
					"player_armor_regen_damage_health_ratio_multiplier_3"
				},
				icon_xy = {
					1,
					7
				}
			},
			deck8,
			{
				cost = 4000,
				desc_id = "menu_deck12_9_desc",
				name_id = "menu_deck12_9",
				upgrades = {
					"player_passive_loot_drop_multiplier",
					"player_armor_regen_damage_health_ratio_threshold_multiplier",
					"player_movement_speed_damage_health_ratio_threshold_multiplier"
				},
				icon_xy = {
					2,
					7
				}
			},
			name_id = "menu_st_spec_12",
			dlc = "dragon",
			desc_id = "menu_st_spec_12_desc"
		},
		{
			{
				cost = 200,
				desc_id = "menu_deck13_1_desc",
				name_id = "menu_deck13_1",
				upgrades = {
					"player_armor_health_store_amount_1"
				},
				icon_xy = {
					3,
					7
				}
			},
			deck2,
			{
				cost = 400,
				desc_id = "menu_deck13_3_desc",
				name_id = "menu_deck13_3",
				upgrades = {
					"player_armor_health_store_amount_2",
					"player_passive_health_multiplier_1"
				},
				icon_xy = {
					4,
					7
				}
			},
			deck4,
			{
				cost = 1000,
				desc_id = "menu_deck13_5_desc",
				name_id = "menu_deck13_5",
				upgrades = {
					"player_armor_max_health_store_multiplier",
					"player_passive_health_multiplier_2",
					"player_passive_dodge_chance_1"
				},
				icon_xy = {
					5,
					7
				}
			},
			deck6,
			{
				cost = 2400,
				desc_id = "menu_deck13_7_desc",
				name_id = "menu_deck13_7",
				upgrades = {
					"player_armor_health_store_amount_3",
					"player_passive_health_multiplier_3"
				},
				icon_xy = {
					6,
					7
				}
			},
			deck8,
			{
				cost = 4000,
				desc_id = "menu_deck13_9_desc",
				name_id = "menu_deck13_9",
				upgrades = {
					"player_passive_loot_drop_multiplier",
					"player_kill_change_regenerate_speed"
				},
				icon_xy = {
					7,
					7
				}
			},
			desc_id = "menu_st_spec_13_desc",
			name_id = "menu_st_spec_13"
		},
		{
			{
				cost = 200,
				texture_bundle_folder = "coco",
				desc_id = "menu_deck14_1_desc",
				name_id = "menu_deck14_1",
				upgrades = {
					"player_cocaine_stacking_1"
				},
				icon_xy = {
					0,
					0
				}
			},
			deck2,
			{
				cost = 400,
				texture_bundle_folder = "coco",
				desc_id = "menu_deck14_3_desc",
				name_id = "menu_deck14_3",
				upgrades = {
					"player_sync_cocaine_stacks"
				},
				icon_xy = {
					1,
					0
				}
			},
			deck4,
			{
				cost = 1000,
				texture_bundle_folder = "coco",
				desc_id = "menu_deck14_5_desc",
				name_id = "menu_deck14_5",
				upgrades = {
					"player_cocaine_stacks_decay_multiplier_1"
				},
				icon_xy = {
					2,
					0
				}
			},
			deck6,
			{
				cost = 2400,
				texture_bundle_folder = "coco",
				desc_id = "menu_deck14_7_desc",
				name_id = "menu_deck14_7",
				upgrades = {
					"player_sync_cocaine_upgrade_level_1"
				},
				icon_xy = {
					3,
					0
				}
			},
			deck8,
			{
				cost = 4000,
				texture_bundle_folder = "coco",
				desc_id = "menu_deck14_9_desc",
				name_id = "menu_deck14_9",
				upgrades = {
					"player_passive_loot_drop_multiplier",
					"player_cocaine_stack_absorption_multiplier_1"
				},
				icon_xy = {
					0,
					1
				}
			},
			desc_id = "menu_st_spec_14_desc",
			name_id = "menu_st_spec_14"
		},
		{
			{
				cost = 200,
				texture_bundle_folder = "opera",
				desc_id = "menu_deck15_1_desc",
				name_id = "menu_deck15_1",
				upgrades = {
					"player_armor_grinding_1",
					"temporary_armor_break_invulnerable_1"
				},
				icon_xy = {
					0,
					0
				}
			},
			deck2,
			{
				cost = 400,
				texture_bundle_folder = "opera",
				desc_id = "menu_deck15_3_desc",
				name_id = "menu_deck15_3",
				upgrades = {
					"player_health_decrease_1",
					"player_armor_increase_1"
				},
				icon_xy = {
					1,
					0
				}
			},
			deck4,
			{
				cost = 1000,
				texture_bundle_folder = "opera",
				desc_id = "menu_deck15_5_desc",
				name_id = "menu_deck15_5",
				upgrades = {
					"player_armor_increase_2"
				},
				icon_xy = {
					2,
					0
				}
			},
			deck6,
			{
				cost = 2400,
				texture_bundle_folder = "opera",
				desc_id = "menu_deck15_7_desc",
				name_id = "menu_deck15_7",
				upgrades = {
					"player_armor_increase_3"
				},
				icon_xy = {
					3,
					0
				}
			},
			deck8,
			{
				cost = 4000,
				texture_bundle_folder = "opera",
				desc_id = "menu_deck15_9_desc",
				name_id = "menu_deck15_9",
				upgrades = {
					"player_passive_loot_drop_multiplier",
					"player_damage_to_armor_1"
				},
				icon_xy = {
					0,
					1
				}
			},
			name_id = "menu_st_spec_15",
			dlc = "opera",
			desc_id = "menu_st_spec_15_desc"
		},
		{
			{
				cost = 200,
				texture_bundle_folder = "wild",
				desc_id = "menu_deck16_1_desc",
				name_id = "menu_deck16_1",
				upgrades = {
					"player_wild_health_amount_1",
					"player_wild_armor_amount_1"
				},
				icon_xy = {
					0,
					0
				}
			},
			deck2,
			{
				cost = 400,
				texture_bundle_folder = "wild",
				desc_id = "menu_deck16_3_desc",
				name_id = "menu_deck16_3",
				upgrades = {
					"player_less_health_wild_armor_1"
				},
				icon_xy = {
					1,
					0
				}
			},
			deck4,
			{
				cost = 1000,
				texture_bundle_folder = "wild",
				desc_id = "menu_deck16_5_desc",
				name_id = "menu_deck16_5",
				upgrades = {
					"player_less_health_wild_cooldown_1"
				},
				icon_xy = {
					2,
					0
				}
			},
			deck6,
			{
				cost = 2400,
				texture_bundle_folder = "wild",
				desc_id = "menu_deck16_7_desc",
				name_id = "menu_deck16_7",
				upgrades = {
					"player_less_armor_wild_health_1"
				},
				icon_xy = {
					3,
					0
				}
			},
			deck8,
			{
				cost = 4000,
				texture_bundle_folder = "wild",
				desc_id = "menu_deck16_9_desc",
				name_id = "menu_deck16_9",
				upgrades = {
					"player_passive_loot_drop_multiplier",
					"player_less_armor_wild_cooldown_1"
				},
				icon_xy = {
					0,
					1
				}
			},
			name_id = "menu_st_spec_16",
			dlc = "wild",
			desc_id = "menu_st_spec_16_desc"
		},
		{
			{
				cost = 200,
				texture_bundle_folder = "chico",
				desc_id = "menu_deck17_1_desc",
				name_id = "menu_deck17_1",
				upgrades = {
					"temporary_chico_injector_1",
					"chico_injector"
				},
				icon_xy = {
					0,
					0
				}
			},
			deck2,
			{
				cost = 400,
				texture_bundle_folder = "chico",
				desc_id = "menu_deck17_3_desc",
				name_id = "menu_deck17_3",
				upgrades = {
					"player_passive_health_multiplier_1"
				},
				icon_xy = {
					1,
					0
				}
			},
			deck4,
			{
				cost = 1000,
				texture_bundle_folder = "chico",
				desc_id = "menu_deck17_5_desc",
				name_id = "menu_deck17_5",
				upgrades = {
					"player_chico_preferred_target",
					"player_passive_health_multiplier_2"
				},
				icon_xy = {
					2,
					0
				}
			},
			deck6,
			{
				cost = 2400,
				texture_bundle_folder = "chico",
				desc_id = "menu_deck17_7_desc",
				name_id = "menu_deck17_7",
				upgrades = {
					"player_passive_health_multiplier_3",
					"player_chico_injector_low_health_multiplier"
				},
				icon_xy = {
					3,
					0
				}
			},
			deck8,
			{
				cost = 4000,
				texture_bundle_folder = "chico",
				desc_id = "menu_deck17_9_desc",
				name_id = "menu_deck17_9",
				upgrades = {
					"player_passive_loot_drop_multiplier",
					"player_passive_health_multiplier_4",
					"player_chico_injector_health_to_speed"
				},
				icon_xy = {
					0,
					1
				}
			},
			name_id = "menu_st_spec_17",
			dlc = "chico",
			desc_id = "menu_st_spec_17_desc"
		},
		{
			{
				cost = 200,
				texture_bundle_folder = "max",
				desc_id = "menu_deck18_1_desc",
				name_id = "menu_deck18_1",
				upgrades = {
					"smoke_screen_grenade"
				},
				icon_xy = {
					0,
					0
				}
			},
			deck2,
			{
				cost = 400,
				texture_bundle_folder = "max",
				desc_id = "menu_deck18_3_desc",
				name_id = "menu_deck18_3",
				upgrades = {
					"player_dodge_shot_gain"
				},
				icon_xy = {
					1,
					0
				}
			},
			deck4,
			{
				cost = 1000,
				texture_bundle_folder = "max",
				desc_id = "menu_deck18_5_desc",
				name_id = "menu_deck18_5",
				upgrades = {
					"player_passive_dodge_chance_1"
				},
				icon_xy = {
					2,
					0
				}
			},
			deck6,
			{
				cost = 2400,
				texture_bundle_folder = "max",
				desc_id = "menu_deck18_7_desc",
				name_id = "menu_deck18_7",
				upgrades = {
					"player_dodge_replenish_armor"
				},
				icon_xy = {
					3,
					0
				}
			},
			deck8,
			{
				cost = 4000,
				texture_bundle_folder = "max",
				desc_id = "menu_deck18_9_desc",
				name_id = "menu_deck18_9",
				upgrades = {
					"player_passive_loot_drop_multiplier",
					"player_smoke_screen_ally_dodge_bonus",
					"player_sicario_multiplier"
				},
				icon_xy = {
					0,
					1
				}
			},
			desc_id = "menu_st_spec_18_desc",
			name_id = "menu_st_spec_18"
		},
		{
			{
				cost = 200,
				texture_bundle_folder = "myh",
				desc_id = "menu_deck19_1_desc",
				name_id = "menu_deck19_1",
				upgrades = {
					"damage_control",
					"player_damage_control_passive",
					"player_damage_control_cooldown_drain_1"
				},
				icon_xy = {
					0,
					0
				}
			},
			deck2,
			{
				cost = 400,
				texture_bundle_folder = "myh",
				desc_id = "menu_deck19_3_desc",
				name_id = "menu_deck19_3",
				upgrades = {
					"player_armor_to_health_conversion"
				},
				icon_xy = {
					1,
					0
				}
			},
			deck4,
			{
				cost = 1000,
				texture_bundle_folder = "myh",
				desc_id = "menu_deck19_5_desc",
				name_id = "menu_deck19_5",
				upgrades = {
					"player_damage_control_auto_shrug"
				},
				icon_xy = {
					2,
					0
				}
			},
			deck6,
			{
				cost = 2400,
				texture_bundle_folder = "myh",
				desc_id = "menu_deck19_7_desc",
				name_id = "menu_deck19_7",
				upgrades = {
					"player_damage_control_cooldown_drain_2"
				},
				icon_xy = {
					3,
					0
				}
			},
			deck8,
			{
				cost = 4000,
				texture_bundle_folder = "myh",
				desc_id = "menu_deck19_9_desc",
				name_id = "menu_deck19_9",
				upgrades = {
					"player_passive_loot_drop_multiplier",
					"player_damage_control_healing"
				},
				icon_xy = {
					0,
					1
				}
			},
			desc_id = "menu_st_spec_19_desc",
			name_id = "menu_st_spec_19"
		},
		{
			{
				cost = 200,
				texture_bundle_folder = "ecp",
				desc_id = "menu_deck20_1_desc",
				name_id = "menu_deck20_1",
				upgrades = {
					"tag_team",
					"player_tag_team_base",
					"player_tag_team_cooldown_drain_1"
				},
				icon_xy = {
					0,
					0
				}
			},
			deck2,
			{
				cost = 400,
				texture_bundle_folder = "ecp",
				desc_id = "menu_deck20_3_desc",
				name_id = "menu_deck20_3",
				upgrades = {
					"player_passive_health_multiplier_1",
					"player_passive_health_multiplier_2"
				},
				icon_xy = {
					1,
					0
				}
			},
			deck4,
			{
				cost = 1000,
				texture_bundle_folder = "ecp",
				desc_id = "menu_deck20_5_desc",
				name_id = "menu_deck20_5",
				upgrades = {
					"player_tag_team_damage_absorption"
				},
				icon_xy = {
					2,
					0
				}
			},
			deck6,
			{
				cost = 2400,
				texture_bundle_folder = "ecp",
				desc_id = "menu_deck20_7_desc",
				name_id = "menu_deck20_7",
				upgrades = {
					"player_passive_health_multiplier_3"
				},
				icon_xy = {
					3,
					0
				}
			},
			deck8,
			{
				cost = 4000,
				texture_bundle_folder = "ecp",
				desc_id = "menu_deck20_9_desc",
				name_id = "menu_deck20_9",
				upgrades = {
					"player_passive_loot_drop_multiplier",
					"player_tag_team_cooldown_drain_2"
				},
				icon_xy = {
					0,
					1
				}
			},
			name_id = "menu_st_spec_20",
			dlc = "ecp",
			desc_id = "menu_st_spec_20_desc"
		},
		{
			{
				cost = 200,
				texture_bundle_folder = "joy",
				desc_id = "menu_deck21_1_desc",
				name_id = "menu_deck21_1",
				upgrades = {
					"pocket_ecm_jammer",
					"player_pocket_ecm_jammer_base"
				},
				icon_xy = {
					0,
					0
				}
			},
			deck2,
			{
				cost = 400,
				texture_bundle_folder = "joy",
				desc_id = "menu_deck21_3_desc",
				name_id = "menu_deck21_3",
				upgrades = {
					"player_passive_health_multiplier_1",
					"player_passive_health_multiplier_2"
				},
				icon_xy = {
					1,
					0
				}
			},
			deck4,
			{
				cost = 1000,
				texture_bundle_folder = "joy",
				desc_id = "menu_deck21_5_desc",
				name_id = "menu_deck21_5",
				upgrades = {
					"player_pocket_ecm_heal_on_kill_1",
					"player_passive_dodge_chance_1"
				},
				icon_xy = {
					2,
					0
				}
			},
			deck6,
			{
				cost = 2400,
				texture_bundle_folder = "joy",
				desc_id = "menu_deck21_7_desc",
				name_id = "menu_deck21_7",
				upgrades = {
					"player_pocket_ecm_kill_dodge_1"
				},
				icon_xy = {
					3,
					0
				}
			},
			deck8,
			{
				cost = 4000,
				texture_bundle_folder = "joy",
				desc_id = "menu_deck21_9_desc",
				name_id = "menu_deck21_9",
				upgrades = {
					"player_passive_loot_drop_multiplier",
					"team_pocket_ecm_heal_on_kill_1",
					"player_passive_dodge_chance_2"
				},
				icon_xy = {
					0,
					1
				}
			},
			desc_id = "menu_st_spec_21_desc",
			name_id = "menu_st_spec_21"
		}
	}
end

function SkillTreeTweakData:get_tier_position_from_skill_name(skill_name)
	for tree_idx in pairs(self.trees) do
		local count = 0
		local tree = self.trees[tree_idx]

		for tier_idx in pairs(tree.tiers) do
			count = count + 1
			local tier = tree.tiers[tier_idx]

			for skill_idx in pairs(tier) do
				if skill_name == tier[skill_idx] then
					return count
				end
			end
		end
	end

	return -1
end

function SkillTreeTweakData:get_tree(tree_name)
	local list = {}

	for i, tree in ipairs(self.trees) do
		if tree.skill == tree_name then
			table.insert(list, tree)
		end
	end

	return list
end

function SkillTreeTweakData:get_tiers(tree_idx)
	local tiers = deep_clone(self.trees[tree_idx].tiers)

	return tiers
end

function SkillTreeTweakData:get_tier_unlocks()
	local function digest(value)
		return Application:digest_value(value, false)
	end

	local tier_unlocks = self.tier_unlocks
	local unlock_values = {}

	for i = 1, #tier_unlocks do
		table.insert(unlock_values, digest(tier_unlocks[i]))
	end

	return unlock_values
end

function SkillTreeTweakData:get_specialization_icon_data(spec, no_fallback)
	spec = spec or managers.skilltree:get_specialization_value("current_specialization")

	print(spec, type(spec))

	local data = tweak_data.skilltree.specializations[spec]
	local max_tier = managers.skilltree:get_specialization_value(spec, "tiers", "max_tier")
	local tier_data = data and data[max_tier]

	if not tier_data then
		if no_fallback then
			return
		else
			print("fallback")

			return tweak_data.hud_icons:get_icon_data("fallback")
		end
	end

	local guis_catalog = "guis/" .. (tier_data.texture_bundle_folder and "dlcs/" .. tostring(tier_data.texture_bundle_folder) .. "/" or "")
	local x = tier_data.icon_xy and tier_data.icon_xy[1] or 0
	local y = tier_data.icon_xy and tier_data.icon_xy[2] or 0

	return guis_catalog .. "textures/pd2/specialization/icons_atlas", {
		x * 64,
		y * 64,
		64,
		64
	}
end
