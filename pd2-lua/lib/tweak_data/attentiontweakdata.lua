AttentionTweakData = AttentionTweakData or class()

function AttentionTweakData:init()
	self.settings = {}
	self.indexes = {}

	self:_init_player()
	self:_init_team_AI()
	self:_init_civilian()
	self:_init_enemy()
	self:_init_drill()
	self:_init_sentry_gun()
	self:_init_prop()
	self:_init_custom()
	self:_post_init()
end

function AttentionTweakData:_init_player()
	self.settings.pl_civilian = {
		max_range = 1,
		reaction = "REACT_IDLE",
		notice_delay_mul = 1,
		notice_requires_FOV = true,
		verification_interval = 4,
		release_delay = 1,
		filter = "none"
	}
	self.settings.pl_mask_off_friend_combatant = {
		max_range = 1000,
		reaction = "REACT_IDLE",
		notice_delay_mul = 1,
		relation = "friend",
		filter = "combatant",
		notice_requires_FOV = false,
		verification_interval = 4,
		release_delay = 3,
		duration = {
			2,
			5
		},
		pause = {
			15,
			25
		}
	}
	self.settings.pl_mask_off_foe_combatant = {
		max_range = 600,
		reaction = "REACT_SUSPICIOUS",
		notice_delay_mul = 0.3,
		suspicion_duration = 4,
		suspicion_range = 500,
		relation = "foe",
		filter = "combatant",
		uncover_range = 150,
		turn_around_range = 250,
		notice_requires_FOV = true,
		verification_interval = 0.02,
		release_delay = 2
	}
	self.settings.pl_mask_off_foe_non_combatant = {
		max_range = 600,
		reaction = "REACT_IDLE",
		notice_delay_mul = 0,
		notice_interval = 0.5,
		filter = "non_combatant",
		attract_chance = 0.5,
		notice_requires_FOV = true,
		verification_interval = 2,
		release_delay = 3,
		duration = {
			2,
			15
		},
		pause = {
			10,
			60
		}
	}
	self.settings.pl_mask_off_friend_non_combatant = {
		max_range = 600,
		reaction = "REACT_IDLE",
		notice_delay_mul = 0,
		notice_interval = 0.5,
		relation = "friend",
		filter = "non_combatant",
		attract_chance = 0.5,
		notice_requires_FOV = true,
		verification_interval = 2,
		release_delay = 3,
		duration = {
			2,
			15
		},
		pause = {
			10,
			60
		}
	}
	self.settings.pl_mask_on_friend_combatant_whisper_mode = {
		max_range = 2000,
		reaction = "REACT_CHECK",
		notice_delay_mul = 1,
		relation = "friend",
		filter = "combatant",
		notice_requires_FOV = true,
		verification_interval = 4,
		release_delay = 3,
		duration = {
			2,
			5
		},
		pause = {
			25,
			50
		}
	}
	self.settings.pl_mask_on_friend_non_combatant_whisper_mode = self.settings.pl_mask_off_friend_non_combatant
	self.settings.pl_mask_on_foe_combatant_whisper_mode_stand = {
		max_range = 2000,
		reaction = "REACT_COMBAT",
		notice_delay_mul = 2,
		relation = "foe",
		filter = "combatant",
		uncover_range = 200,
		notice_requires_FOV = true,
		notice_clbk = "clbk_attention_notice_sneak",
		verification_interval = 0.1,
		release_delay = 1
	}
	self.settings.pl_mask_on_foe_non_combatant_whisper_mode_stand = {
		uncover_range = 550,
		reaction = "REACT_COMBAT",
		notice_delay_mul = 1.5,
		notice_requires_FOV = true,
		notice_clbk = "clbk_attention_notice_sneak",
		verification_interval = 0.1,
		release_delay = 1,
		filter = "non_combatant"
	}
	self.settings.pl_mask_on_foe_combatant_whisper_mode_crouch = {
		max_range = 1200,
		reaction = "REACT_COMBAT",
		notice_delay_mul = 2,
		relation = "foe",
		filter = "combatant",
		uncover_range = 200,
		notice_requires_FOV = true,
		notice_clbk = "clbk_attention_notice_sneak",
		verification_interval = 0.1,
		release_delay = 1
	}
	self.settings.pl_mask_on_foe_non_combatant_whisper_mode_crouch = {
		max_range = 1500,
		reaction = "REACT_COMBAT",
		notice_delay_mul = 3,
		filter = "non_combatant",
		uncover_range = 200,
		notice_requires_FOV = true,
		notice_clbk = "clbk_attention_notice_sneak",
		verification_interval = 0.1,
		release_delay = 1
	}
	self.settings.pl_friend_combatant_cbt = {
		max_range = 3000,
		reaction = "REACT_CHECK",
		notice_delay_mul = 1,
		relation = "friend",
		filter = "combatant",
		notice_requires_FOV = false,
		verification_interval = 4,
		release_delay = 3,
		duration = {
			2,
			3
		},
		pause = {
			45,
			60
		}
	}
	self.settings.pl_friend_non_combatant_cbt = {
		uncover_range = 550,
		reaction = "REACT_SCARED",
		notice_delay_mul = 1.5,
		release_delay = 1,
		notice_requires_FOV = true,
		verification_interval = 0.1,
		relation = "friend",
		filter = "non_combatant"
	}
	self.settings.pl_foe_combatant_cbt_crouch = {
		uncover_range = 350,
		reaction = "REACT_COMBAT",
		notice_delay_mul = 2,
		release_delay = 1,
		notice_requires_FOV = true,
		verification_interval = 0.1,
		relation = "foe",
		filter = "combatant"
	}
	self.settings.pl_foe_combatant_cbt_stand = {
		reaction = "REACT_COMBAT",
		notice_interval = 0.1,
		relation = "foe",
		filter = "combatant",
		uncover_range = 550,
		notice_requires_FOV = true,
		notice_clbk = "clbk_attention_notice_sneak",
		verification_interval = 1,
		release_delay = 1
	}
	self.settings.pl_foe_non_combatant_cbt_crouch = {
		uncover_range = 200,
		reaction = "REACT_COMBAT",
		notice_delay_mul = 2.5,
		notice_requires_FOV = true,
		notice_clbk = "clbk_attention_notice_sneak",
		verification_interval = 0.1,
		release_delay = 1,
		filter = "non_combatant"
	}
	self.settings.pl_foe_non_combatant_cbt_stand = deep_clone(self.settings.pl_foe_combatant_cbt_stand)
	self.settings.pl_foe_non_combatant_cbt_stand.filter = "non_combatant"
end

function AttentionTweakData:_init_team_AI()
	self.settings.team_team_idle = {
		max_range = 1000,
		reaction = "REACT_IDLE",
		relation = "friend",
		filter = "all",
		notice_requires_FOV = false,
		verification_interval = 3,
		release_delay = 2,
		duration = {
			1.5,
			4
		},
		pause = {
			25,
			40
		}
	}
	self.settings.team_enemy_idle = {
		max_range = 550,
		reaction = "REACT_IDLE",
		relation = "foe",
		filter = "combatant",
		notice_requires_FOV = false,
		verification_interval = 3,
		release_delay = 1,
		duration = {
			1.5,
			3
		},
		pause = {
			35,
			60
		}
	}
	self.settings.team_enemy_cbt = {
		max_range = 20000,
		reaction = "REACT_COMBAT",
		notice_interval = 1,
		relation = "foe",
		filter = "all",
		uncover_range = 400,
		notice_requires_FOV = true,
		verification_interval = 1.5,
		release_delay = 1,
		weight_mul = 0.5
	}
end

function AttentionTweakData:_init_civilian()
	self.settings.civ_all_peaceful = {
		max_range = 2000,
		reaction = "REACT_IDLE",
		notice_requires_FOV = true,
		verification_interval = 3,
		release_delay = 2,
		filter = "all",
		duration = {
			1.5,
			6
		},
		pause = {
			35,
			60
		}
	}
	self.settings.civ_enemy_cbt = {
		max_range = 8000,
		reaction = "REACT_SCARED",
		notice_delay_mul = 1,
		filter = "all",
		uncover_range = 300,
		notice_requires_FOV = true,
		notice_clbk = "clbk_attention_notice_corpse",
		verification_interval = 0.1,
		release_delay = 6,
		duration = {
			3,
			6
		}
	}
	self.settings.civ_murderer_cbt = {
		max_range = 20000,
		reaction = "REACT_SHOOT",
		notice_interval = 1,
		relation = "foe",
		filter = "murderer",
		uncover_range = 300,
		notice_requires_FOV = true,
		verification_interval = 1.5,
		release_delay = 1,
		weight_mul = 0.75
	}
	self.settings.civ_enemy_corpse_sneak = {
		uncover_range = 300,
		reaction = "REACT_SCARED",
		notice_delay_mul = 0.05,
		max_range = 2500,
		notice_requires_FOV = true,
		verification_interval = 0.1,
		release_delay = 6,
		filter = "all"
	}
	self.settings.civ_civ_cbt = {
		uncover_range = 300,
		reaction = "REACT_SCARED",
		notice_delay_mul = 0.05,
		notice_requires_FOV = true,
		verification_interval = 0.1,
		release_delay = 6,
		filter = "all",
		duration = {
			3,
			6
		}
	}
end

function AttentionTweakData:_init_enemy()
	self.settings.enemy_team_idle = {
		max_range = 2000,
		reaction = "REACT_IDLE",
		relation = "foe",
		filter = "combatant",
		notice_requires_FOV = false,
		verification_interval = 3,
		release_delay = 1,
		duration = {
			2,
			4
		},
		pause = {
			9,
			40
		}
	}
	self.settings.enemy_team_cbt = {
		max_range = 20000,
		reaction = "REACT_COMBAT",
		notice_delay_mul = 0,
		notice_interval = 0.2,
		relation = "foe",
		filter = "combatant",
		notice_requires_FOV = false,
		verification_interval = 0.75,
		release_delay = 2
	}
	self.settings.enemy_law_corpse_sneak = self.settings.civ_enemy_corpse_sneak
	self.settings.enemy_team_corpse_sneak = self.settings.civ_enemy_corpse_sneak
	self.settings.enemy_combatant_corpse_cbt = {
		max_range = 800,
		reaction = "REACT_CHECK",
		notice_delay_mul = 0.1,
		notice_requires_FOV = true,
		verification_interval = 1.5,
		release_delay = 1,
		filter = "combatant",
		duration = {
			2,
			3
		}
	}
	self.settings.enemy_enemy_cbt = {
		max_range = 3900,
		reaction = "REACT_SCARED",
		notice_delay_mul = 0.5,
		relation = "friend",
		filter = "combatant",
		uncover_range = 300,
		notice_requires_FOV = true,
		verification_interval = 0.5,
		release_delay = 1
	}
	self.settings.enemy_civ_cbt = {
		max_range = 8000,
		reaction = "REACT_SCARED",
		notice_delay_mul = 0.2,
		filter = "non_combatant",
		uncover_range = 300,
		notice_requires_FOV = true,
		verification_interval = 0.5,
		release_delay = 6,
		duration = {
			1.5,
			3
		}
	}
end

function AttentionTweakData:_init_custom()
	self.settings.custom_void = {
		max_range = 2000,
		reaction = "REACT_IDLE",
		verification_interval = 10,
		release_delay = 10,
		filter = "none"
	}
	self.settings.custom_team_idle = {
		max_range = 2000,
		reaction = "REACT_IDLE",
		notice_requires_FOV = false,
		verification_interval = 3,
		release_delay = 1,
		filter = "criminal",
		duration = {
			2,
			4
		},
		pause = {
			9,
			40
		}
	}
	self.settings.custom_team_cbt = {
		max_range = 20000,
		reaction = "REACT_COMBAT",
		notice_requires_FOV = false,
		verification_interval = 1.5,
		release_delay = 2,
		filter = "criminal"
	}
	self.settings.custom_team_shoot_const = {
		max_range = 10000,
		reaction = "REACT_SHOOT",
		notice_requires_FOV = false,
		verification_interval = 1.5,
		release_delay = 2,
		filter = "criminal"
	}
	self.settings.custom_team_shoot_burst = {
		max_range = 10000,
		reaction = "REACT_SHOOT",
		notice_requires_FOV = false,
		verification_interval = 1.5,
		release_delay = 2,
		filter = "criminal",
		duration = {
			2,
			4
		}
	}
	self.settings.custom_team_aim_const = {
		max_range = 10000,
		reaction = "REACT_AIM",
		notice_requires_FOV = false,
		verification_interval = 1.5,
		release_delay = 2,
		filter = "criminal"
	}
	self.settings.custom_enemy_forest_survive_kruka = {
		max_range = 20000,
		reaction = "REACT_COMBAT",
		notice_requires_FOV = false,
		verification_interval = 1,
		release_delay = 2,
		filter = "all_enemy"
	}
	self.settings.custom_enemy_suburbia_shootout = {
		max_range = 12000,
		reaction = "REACT_SHOOT",
		notice_requires_FOV = true,
		turn_around_range = 15000,
		weight_mul = 0.5,
		verification_interval = 2,
		release_delay = 5,
		filter = "all_enemy"
	}
	self.settings.custom_enemy_suburbia_shootout_cops = {
		max_range = 2000,
		reaction = "REACT_SHOOT",
		notice_requires_FOV = true,
		turn_around_range = 15000,
		verification_interval = 2,
		release_delay = 5,
		filter = "all_enemy"
	}
	self.settings.custom_enemy_china_store_vase_shoot = {
		max_range = 1200,
		reaction = "REACT_COMBAT",
		notice_requires_FOV = true,
		turn_around_range = 500,
		verification_interval = 2,
		release_delay = 3,
		filter = "all_enemy"
	}
	self.settings.custom_enemy_china_store_vase_melee = {
		max_range = 500,
		reaction = "REACT_MELEE",
		notice_requires_FOV = true,
		pause = 10,
		turn_around_range = 250,
		verification_interval = 5,
		release_delay = 10,
		filter = "all_enemy"
	}
	self.settings.custom_enemy_china_store_vase_aim = {
		max_range = 500,
		reaction = "REACT_COMBAT",
		notice_requires_FOV = false,
		pause = 10,
		verification_interval = 5,
		release_delay = 10,
		filter = "all_enemy"
	}
	self.settings.custom_enemy_shoot_const = {
		max_range = 10000,
		reaction = "REACT_SHOOT",
		notice_requires_FOV = true,
		verification_interval = 1,
		release_delay = 2,
		filter = "all_enemy"
	}
	self.settings.custom_gangster_shoot_const = {
		max_range = 10000,
		reaction = "REACT_SHOOT",
		notice_requires_FOV = true,
		verification_interval = 1,
		release_delay = 2,
		filter = "gangster"
	}
	self.settings.custom_law_shoot_const = {
		max_range = 100000,
		reaction = "REACT_SHOOT",
		notice_requires_FOV = false,
		verification_interval = 1,
		release_delay = 2,
		filter = "law_enforcer"
	}
	self.settings.custom_law_look_in_container = {
		max_range = 100000,
		reaction = "REACT_AIM",
		notice_requires_FOV = false,
		verification_interval = 1,
		release_delay = 2,
		filter = "law_enforcer"
	}
	self.settings.custom_law_shoot_const_escape_vehicle = {
		max_range = 4500,
		reaction = "REACT_COMBAT",
		notice_requires_FOV = false,
		verification_interval = 1,
		release_delay = 2,
		filter = "law_enforcer"
	}
	self.settings.custom_law_shoot_const_container = {
		max_range = 2000,
		reaction = "REACT_SHOOT",
		notice_requires_FOV = false,
		verification_interval = 1,
		release_delay = 2,
		filter = "law_enforcer"
	}
	self.settings.custom_gangsters_shoot_warehouse = {
		max_range = 2000,
		reaction = "REACT_COMBAT",
		notice_requires_FOV = false,
		verification_interval = 1,
		release_delay = 2,
		filter = "gangster"
	}
	self.settings.custom_gangster_sniper_apartment_suspicous = {
		max_range = 850,
		reaction = "REACT_SCARED",
		notice_requires_FOV = true,
		uncover_range = 350,
		notice_delay_mul = 0.1,
		verification_interval = 1,
		release_delay = 6,
		filter = "law_enforcer"
	}
	self.settings.custom_gangster_docks_idle = {
		max_range = 10000,
		reaction = "REACT_CURIOUS",
		notice_requires_FOV = true,
		verification_interval = 1,
		release_delay = 6,
		filter = "gangster"
	}
	self.settings.custom_enemy_civ_scared = {
		reaction = "REACT_SCARED",
		notice_requires_FOV = true,
		verification_interval = 5,
		release_delay = 2,
		filter = "civilians_enemies",
		duration = {
			2,
			4
		}
	}
	self.settings.custom_boat_gangster = {
		max_range = 4000,
		reaction = "REACT_COMBAT",
		notice_requires_FOV = false,
		verification_interval = 1,
		release_delay = 2,
		filter = "gangster"
	}
	self.settings.custom_law_cbt = {
		uncover_range = 350,
		reaction = "REACT_COMBAT",
		notice_requires_FOV = true,
		notice_clbk = "clbk_attention_notice_sneak",
		verification_interval = 1,
		release_delay = 1,
		filter = "law_enforcer"
	}
	self.settings.custom_airport_window = {
		max_range = 1500,
		reaction = "REACT_CURIOUS",
		notice_delay_mul = 0.2,
		filter = "all_enemy",
		uncover_range = 100,
		notice_requires_FOV = true,
		verification_interval = 1.5,
		release_delay = 6,
		duration = {
			3,
			6
		}
	}
	self.settings.custom_look_at = {
		max_range = 15000,
		reaction = "REACT_IDLE",
		notice_delay_mul = 0.2,
		notice_requires_FOV = false,
		verification_interval = 1,
		release_delay = 3,
		filter = "all_enemy"
	}
	self.settings.custom_look_at_FOV = {
		max_range = 1500,
		reaction = "REACT_CURIOUS",
		notice_delay_mul = 0.2,
		notice_requires_FOV = true,
		verification_interval = 1.5,
		release_delay = 6,
		filter = "all_enemy",
		duration = {
			3,
			6
		}
	}
	self.settings.custom_server_room = {
		max_range = 350,
		reaction = "REACT_SCARED",
		notice_delay_mul = 0.2,
		filter = "all_enemy",
		uncover_range = 100,
		notice_requires_FOV = true,
		verification_interval = 1.5,
		release_delay = 6,
		duration = {
			3,
			6
		}
	}
end

function AttentionTweakData:_init_drill()
	self.settings.drill_civ_ene_ntl = {
		suspicion_range = 1100,
		reaction = "REACT_SCARED",
		notice_requires_FOV = false,
		uncover_range = 200,
		max_range = 2300,
		verification_interval = 0.4,
		release_delay = 1,
		filter = "civilians_enemies"
	}
	self.settings.drill_silent_civ_ene_ntl = {
		suspicion_range = 1000,
		reaction = "REACT_SCARED",
		notice_requires_FOV = true,
		uncover_range = 200,
		max_range = 2200,
		verification_interval = 0.4,
		release_delay = 1,
		filter = "civilians_enemies"
	}
end

function AttentionTweakData:_init_sentry_gun()
	self.settings.sentry_gun_enemy_cbt = {
		uncover_range = 300,
		reaction = "REACT_COMBAT",
		release_delay = 1,
		verification_interval = 1.5,
		relation = "foe",
		filter = "combatant"
	}
	self.settings.sentry_gun_enemy_cbt_hacked = {
		uncover_range = 300,
		reaction = "REACT_COMBAT",
		release_delay = 1,
		weight_mul = 0.2,
		verification_interval = 1.5,
		relation = "foe",
		filter = "combatant"
	}
end

function AttentionTweakData:_init_prop()
	self.settings.prop_carry_bag = {
		max_range = 1800,
		reaction = "REACT_SCARED",
		notice_requires_FOV = true,
		uncover_range = 200,
		suspicion_range = 800,
		verification_interval = 0.4,
		release_delay = 1,
		filter = "law_enforcer"
	}
	self.settings.prop_carry_bodybag = {
		max_range = 1900,
		reaction = "REACT_SCARED",
		notice_requires_FOV = true,
		uncover_range = 200,
		suspicion_range = 800,
		verification_interval = 0.4,
		release_delay = 1,
		filter = "civilians_enemies"
	}
	self.settings.prop_civ_ene_ntl = {
		uncover_range = 500,
		reaction = "REACT_AIM",
		notice_requires_FOV = true,
		verification_interval = 0.4,
		release_delay = 1,
		filter = "civilians_enemies"
	}
	self.settings.prop_ene_ntl_edaycrate = {
		uncover_range = 300,
		reaction = "REACT_AIM",
		notice_requires_FOV = true,
		max_range = 700,
		verification_interval = 0.4,
		release_delay = 1,
		filter = "all_enemy"
	}
	self.settings.prop_ene_ntl = {
		uncover_range = 500,
		reaction = "REACT_AIM",
		notice_requires_FOV = true,
		verification_interval = 0.4,
		release_delay = 1,
		filter = "all_enemy"
	}
	self.settings.broken_cam_ene_ntl = {
		uncover_range = 100,
		reaction = "REACT_AIM",
		notice_requires_FOV = true,
		max_range = 1200,
		suspicion_range = 1000,
		verification_interval = 0.4,
		release_delay = 1,
		filter = "law_enforcer"
	}
	self.settings.prop_law_scary = {
		uncover_range = 300,
		reaction = "REACT_SCARED",
		notice_requires_FOV = true,
		verification_interval = 0.4,
		release_delay = 1,
		filter = "law_enforcer"
	}
	self.settings.prop_state_civ_ene_ntl = {
		uncover_range = 200,
		reaction = "REACT_CURIOUS",
		notice_requires_FOV = true,
		verification_interval = 0.4,
		release_delay = 1,
		filter = "civilians_enemies"
	}
	self.settings.no_staff_ene_ntl = {
		uncover_range = 100,
		reaction = "REACT_AIM",
		notice_requires_FOV = true,
		max_range = 1200,
		suspicion_range = 1000,
		verification_interval = 0.4,
		release_delay = 1,
		filter = "law_enforcer"
	}
	self.settings.timelock_ene_ntl = {
		uncover_range = 100,
		reaction = "REACT_AIM",
		notice_requires_FOV = true,
		max_range = 1200,
		suspicion_range = 1000,
		verification_interval = 0.4,
		release_delay = 1,
		filter = "law_enforcer"
	}
	self.settings.open_security_gate_ene_ntl = {
		uncover_range = 100,
		reaction = "REACT_AIM",
		notice_requires_FOV = true,
		max_range = 1200,
		suspicion_range = 1000,
		verification_interval = 0.4,
		release_delay = 1,
		filter = "law_enforcer"
	}
	self.settings.open_vault_ene_ntl = {
		uncover_range = 100,
		reaction = "REACT_AIM",
		notice_requires_FOV = true,
		max_range = 600,
		suspicion_range = 500,
		verification_interval = 0.4,
		release_delay = 1,
		filter = "law_enforcer"
	}
	self.settings.vehicle_enemy_cbt = {
		max_range = 20000,
		reaction = "REACT_SHOOT",
		notice_interval = 1,
		relation = "foe",
		filter = "all",
		uncover_range = 1200,
		notice_requires_FOV = true,
		verification_interval = 1.5,
		release_delay = 1,
		weight_mul = 0.4
	}
	self.settings.open_elevator_ene_ntl = {
		uncover_range = 800,
		reaction = "REACT_AIM",
		notice_requires_FOV = true,
		max_range = 1500,
		suspicion_range = 1200,
		verification_interval = 0.4,
		release_delay = 1,
		filter = "civilians_enemies"
	}
end

function AttentionTweakData:get_attention_index(setting_name)
	for i_setting, test_setting_name in ipairs(self.indexes) do
		if setting_name == test_setting_name then
			return i_setting
		end
	end
end

function AttentionTweakData:get_attention_name(index)
	return self.indexes[index]
end

function AttentionTweakData:_post_init()
	for setting_name, setting in pairs(self.settings) do
		local i_insert = 1

		while self.indexes[i_insert] and self.indexes[i_insert] <= setting_name do
			i_insert = i_insert + 1
		end

		table.insert(self.indexes, i_insert, setting_name)
	end
end
