CrimeSpreeTweakData = CrimeSpreeTweakData or class()

function CrimeSpreeTweakData:init(tweak_data)
	self.unlock_level = 60
	self.base_difficulty = "overkill_145"
	self.base_difficulty_index = 5
	self.starting_levels = {
		0,
		20,
		40
	}
	self.allow_highscore_continue = true
	self.initial_cost = 0
	self.cost_per_level = 0.5
	self.randomization_cost = 6
	self.randomization_multiplier = 2
	self.catchup_bonus = 0.035
	self.winning_streak = 0.005
	self.winning_streak_reset_on_failure = false
	self.continue_cost = {
		6,
		0.7
	}
	self.crash_causes_loss = true
	self.protection_threshold = 16
	self.announce_modifier_stinger = "stinger_feedback_positive"

	self:init_missions(tweak_data)
	self:init_rewards(tweak_data)
	self:init_modifiers(tweak_data)
	self:init_gage_assets(tweak_data)
	self:init_gui(tweak_data)
end

function CrimeSpreeTweakData:init_missions(tweak_data)
	local debug_short_add = 5
	local debug_med_add = 7
	local debug_long_add = 10
	self.missions = {
		{
			{
				stage_id = "branchbank_cash",
				id = "bb_cash",
				icon = "csm_branchbank",
				add = debug_short_add,
				level = tweak_data.narrative.stages.branchbank_cash
			},
			{
				stage_id = "cage",
				id = "cage",
				icon = "csm_carshop",
				add = debug_short_add,
				level = tweak_data.narrative.stages.cage
			},
			{
				stage_id = "kosugi",
				id = "kosugi",
				icon = "csm_shadow_raid",
				add = debug_short_add,
				level = tweak_data.narrative.stages.kosugi
			},
			{
				stage_id = "dark",
				id = "dark",
				icon = "csm_murky",
				add = debug_short_add,
				level = tweak_data.narrative.stages.dark
			},
			{
				stage_id = "firestarter_2",
				add = 5,
				id = "fs_2",
				icon = "csm_fs_2",
				level = tweak_data.narrative.stages.firestarter_2
			},
			{
				stage_id = "hox_3",
				add = 4,
				id = "hox_3",
				icon = "csm_hoxvenge",
				level = tweak_data.narrative.stages.hox_3
			},
			{
				stage_id = "fish",
				add = 4,
				id = "fish",
				icon = "csm_yacht",
				level = tweak_data.narrative.stages.fish
			},
			{
				stage_id = "election_day_2",
				add = 4,
				id = "ed_2",
				icon = "csm_election_2",
				level = tweak_data.narrative.stages.election_day_2
			},
			{
				stage_id = "crojob1",
				add = 8,
				id = "crojob1",
				icon = "csm_docks",
				level = tweak_data.narrative.stages.crojob1
			},
			{
				stage_id = "framing_frame_3",
				id = "framing_frame_3",
				icon = "csm_framing_3",
				add = debug_med_add,
				level = tweak_data.narrative.stages.framing_frame_3
			},
			{
				stage_id = "arm_for",
				id = "arm_for",
				icon = "csm_train_forest",
				add = debug_med_add,
				level = tweak_data.narrative.stages.arm_for
			},
			{
				stage_id = "friend",
				add = 8,
				id = "friend",
				icon = "csm_friend",
				level = tweak_data.narrative.stages.friend
			},
			{
				stage_id = "big",
				add = 13,
				id = "big",
				icon = "csm_big",
				level = tweak_data.narrative.stages.big
			},
			{
				stage_id = "mus",
				id = "mus",
				icon = "csm_diamond",
				add = debug_long_add,
				level = tweak_data.narrative.stages.mus
			},
			{
				stage_id = "roberts",
				id = "roberts",
				icon = "csm_go",
				add = debug_long_add,
				level = tweak_data.narrative.stages.roberts
			},
			{
				stage_id = "red2",
				id = "red2",
				icon = "csm_fwb",
				add = debug_long_add,
				level = tweak_data.narrative.stages.red2
			}
		},
		{
			{
				stage_id = "wwh",
				add = 8,
				id = "wwh",
				icon = "csm_wwh",
				level = tweak_data.narrative.stages.wwh
			},
			{
				stage_id = "rvd1",
				add = 8,
				id = "rvd1",
				icon = "csm_rvd_1",
				level = tweak_data.narrative.stages.rvd_1
			},
			{
				stage_id = "rvd2",
				add = 10,
				id = "rvd2",
				icon = "csm_rvd_2",
				level = tweak_data.narrative.stages.rvd_2
			},
			{
				stage_id = "brb",
				add = 8,
				id = "brb",
				icon = "csm_brb",
				level = tweak_data.narrative.stages.brb
			},
			{
				stage_id = "arm_cro",
				id = "arm_cro",
				icon = "csm_crossroads",
				add = debug_short_add,
				level = tweak_data.narrative.stages.arm_cro
			},
			{
				stage_id = "help",
				id = "help",
				icon = "csm_prison",
				add = debug_short_add,
				level = tweak_data.narrative.stages.help
			},
			{
				stage_id = "cage",
				id = "arm_und",
				icon = "csm_overpass",
				add = debug_short_add,
				level = tweak_data.narrative.stages.arm_und
			},
			{
				stage_id = "arm_hcm",
				id = "arm_hcm",
				icon = "csm_downtown",
				add = debug_short_add,
				level = tweak_data.narrative.stages.arm_hcm
			},
			{
				stage_id = "arm_par",
				id = "arm_par",
				icon = "csm_park",
				add = debug_short_add,
				level = tweak_data.narrative.stages.arm_par
			},
			{
				stage_id = "arm_fac",
				id = "arm_fac",
				icon = "csm_harbor",
				add = debug_short_add,
				level = tweak_data.narrative.stages.arm_fac
			},
			{
				stage_id = "chew",
				add = 3,
				id = "biker_2",
				icon = "csm_biker_2",
				level = tweak_data.narrative.stages.chew
			},
			{
				stage_id = "firestarter_1",
				add = 4,
				id = "fs_1",
				icon = "csm_fs_1",
				level = tweak_data.narrative.stages.firestarter_1
			},
			{
				stage_id = "nail",
				id = "nail",
				icon = "csm_labrats",
				add = debug_short_add,
				level = tweak_data.narrative.stages.nail
			},
			{
				stage_id = "watchdogs_1_d",
				add = 6,
				id = "watchdogs_1_d",
				icon = "csm_watchdogs_1",
				level = tweak_data.narrative.stages.watchdogs_1_d
			},
			{
				stage_id = "pines",
				id = "pines",
				icon = "csm_white_xmas",
				add = debug_med_add,
				level = tweak_data.narrative.stages.pines
			},
			{
				stage_id = "moon",
				id = "moon",
				icon = "csm_stealing_xmas",
				add = debug_med_add,
				level = tweak_data.narrative.stages.moon
			},
			{
				stage_id = "spa",
				add = 8,
				id = "spa",
				icon = "csm_brooklyn",
				level = tweak_data.narrative.stages.spa
			},
			{
				stage_id = "cane",
				add = 8,
				id = "cane",
				icon = "csm_santas_workshop",
				level = tweak_data.narrative.stages.cane
			},
			{
				stage_id = "mia_2",
				add = 8,
				id = "mia_2",
				icon = "csm_miami_2",
				level = tweak_data.narrative.stages.mia_2
			}
		},
		{
			{
				stage_id = "pbr2",
				add = 9,
				id = "pbr2",
				icon = "csm_sky",
				level = tweak_data.narrative.stages.pbr2
			},
			{
				stage_id = "pal",
				add = 9,
				id = "pal",
				icon = "csm_counterfeit",
				level = tweak_data.narrative.stages.pal
			},
			{
				stage_id = "flat",
				add = 12,
				id = "flat",
				icon = "csm_panic_room",
				level = tweak_data.narrative.stages.flat
			},
			{
				stage_id = "born",
				id = "born",
				icon = "csm_biker_1",
				add = debug_long_add,
				level = tweak_data.narrative.stages.born
			},
			{
				stage_id = "hox_2",
				add = 15,
				id = "hoxton_2",
				icon = "csm_hoxout_2",
				level = tweak_data.narrative.stages.hox_2
			},
			{
				stage_id = "hox_1",
				add = 10,
				id = "hoxton_1",
				icon = "csm_hoxout_1",
				level = tweak_data.narrative.stages.hox_1
			},
			{
				stage_id = "welcome_to_the_jungle_2",
				add = 14,
				id = "bo_2",
				icon = "csm_bigoil_2",
				level = tweak_data.narrative.stages.welcome_to_the_jungle_2
			},
			{
				stage_id = "mia_1",
				add = 10,
				id = "mia_1",
				icon = "csm_miami_1",
				level = tweak_data.narrative.stages.mia_1
			},
			{
				stage_id = "rat",
				add = 13,
				id = "cook_off",
				icon = "csm_rats_1",
				level = tweak_data.narrative.stages.rat
			},
			{
				stage_id = "pbr",
				id = "pbr",
				icon = "csm_mountain",
				add = debug_long_add,
				level = tweak_data.narrative.stages.pbr
			},
			{
				stage_id = "glace",
				add = 12,
				id = "glace",
				icon = "csm_glace",
				level = tweak_data.narrative.stages.glace
			},
			{
				stage_id = "run",
				add = 12,
				id = "run",
				icon = "csm_run",
				level = tweak_data.narrative.stages.run
			},
			{
				stage_id = "man",
				id = "man",
				icon = "csm_undercover",
				add = debug_long_add,
				level = tweak_data.narrative.stages.man
			},
			{
				stage_id = "dinner",
				add = 12,
				id = "dinner",
				icon = "csm_slaughterhouse",
				level = tweak_data.narrative.stages.dinner
			},
			{
				stage_id = "jolly",
				add = 12,
				id = "jolly",
				icon = "csm_aftershock",
				level = tweak_data.narrative.stages.jolly
			}
		}
	}
end

function CrimeSpreeTweakData:init_modifiers(tweak_data)
	local health_increase = 25
	local damage_increase = 25
	self.max_modifiers_displayed = 3
	self.modifier_levels = {
		loud = 20,
		forced = 50,
		stealth = 26
	}
	self.modifiers = {
		forced = {
			{
				class = "ModifierEnemyHealthAndDamage",
				id = "damage_health_1",
				icon = "crime_spree_health",
				level = 50,
				data = {
					health = {
						20,
						"add"
					},
					damage = {
						15,
						"add"
					}
				}
			}
		},
		loud = {
			{
				id = "shield_reflect",
				icon = "crime_spree_shield_reflect",
				class = "ModifierShieldReflect",
				data = {}
			},
			{
				id = "cloaker_smoke",
				icon = "crime_spree_cloaker_smoke",
				class = "ModifierCloakerKick",
				data = {
					effect = {
						"smoke",
						"none"
					}
				}
			},
			{
				id = "medic_heal_1",
				icon = "crime_spree_medic_speed",
				class = "ModifierHealSpeed",
				data = {
					speed = {
						20,
						"add"
					}
				}
			},
			{
				id = "no_hurt",
				icon = "crime_spree_no_hurt",
				class = "ModifierNoHurtAnims",
				data = {}
			},
			{
				id = "taser_overcharge",
				icon = "crime_spree_taser_overcharge",
				class = "ModifierTaserOvercharge",
				data = {
					speed = {
						50,
						"add"
					}
				}
			},
			{
				id = "heavies",
				icon = "crime_spree_heavies",
				class = "ModifierHeavies",
				data = {}
			},
			{
				id = "medic_1",
				icon = "crime_spree_more_medics",
				class = "ModifierMoreMedics",
				data = {
					inc = {
						2,
						"add"
					}
				}
			},
			{
				id = "heavy_sniper",
				icon = "crime_spree_heavy_sniper",
				class = "ModifierHeavySniper",
				data = {
					spawn_chance = {
						5,
						"add"
					}
				}
			},
			{
				id = "dozer_rage",
				icon = "crime_spree_dozer_rage",
				class = "ModifierDozerRage",
				data = {
					damage = {
						100,
						"add"
					}
				}
			},
			{
				id = "cloaker_tear_gas",
				icon = "crime_spree_cloaker_tear_gas",
				class = "ModifierCloakerTearGas",
				data = {
					diameter = {
						4,
						"none"
					},
					damage = {
						30,
						"none"
					},
					duration = {
						10,
						"none"
					}
				}
			},
			{
				id = "dozer_1",
				icon = "crime_spree_more_dozers",
				class = "ModifierMoreDozers",
				data = {
					inc = {
						2,
						"add"
					}
				}
			},
			{
				id = "medic_heal_2",
				icon = "crime_spree_medic_speed",
				class = "ModifierHealSpeed",
				data = {
					speed = {
						20,
						"add"
					}
				}
			},
			{
				id = "dozer_lmg",
				icon = "crime_spree_dozer_lmg",
				class = "ModifierSkulldozers",
				data = {}
			},
			{
				id = "medic_adrenaline",
				icon = "crime_spree_medic_adrenaline",
				class = "ModifierMedicAdrenaline",
				data = {
					damage = {
						100,
						"add"
					}
				}
			},
			{
				id = "shield_phalanx",
				icon = "crime_spree_shield_phalanx",
				class = "ModifierShieldPhalanx",
				data = {}
			},
			{
				id = "dozer_2",
				icon = "crime_spree_more_dozers",
				class = "ModifierMoreDozers",
				data = {
					inc = {
						2,
						"add"
					}
				}
			},
			{
				id = "medic_deathwish",
				icon = "crime_spree_medic_deathwish",
				class = "ModifierMedicDeathwish",
				data = {}
			},
			{
				id = "dozer_minigun",
				icon = "crime_spree_dozer_minigun",
				class = "ModifierDozerMinigun",
				data = {}
			},
			{
				id = "medic_2",
				icon = "crime_spree_more_medics",
				class = "ModifierMoreMedics",
				data = {
					inc = {
						2,
						"add"
					}
				}
			},
			{
				id = "dozer_immunity",
				icon = "crime_spree_dozer_explosion",
				class = "ModifierExplosionImmunity",
				data = {}
			},
			{
				id = "dozer_medic",
				icon = "crime_spree_dozer_medic",
				class = "ModifierDozerMedic",
				data = {}
			},
			{
				id = "assault_extender",
				icon = "crime_spree_assault_extender",
				class = "ModifierAssaultExtender",
				data = {
					duration = {
						50,
						"add"
					},
					spawn_pool = {
						50,
						"add"
					},
					deduction = {
						4,
						"add"
					},
					max_hostages = {
						8,
						"none"
					}
				}
			},
			{
				id = "cloaker_arrest",
				icon = "crime_spree_cloaker_arrest",
				class = "ModifierCloakerArrest",
				data = {}
			},
			{
				id = "medic_rage",
				icon = "crime_spree_medic_rage",
				class = "ModifierMedicRage",
				data = {
					damage = {
						20,
						"add"
					}
				}
			}
		},
		stealth = {
			{
				class = "ModifierLessPagers",
				id = "pagers_1",
				icon = "crime_spree_pager",
				level = 26,
				data = {
					count = {
						1,
						"max"
					}
				}
			},
			{
				class = "ModifierCivilianAlarm",
				id = "civs_1",
				icon = "crime_spree_civs_killed",
				level = 26,
				data = {
					count = {
						10,
						"min"
					}
				}
			},
			{
				class = "ModifierLessConcealment",
				id = "conceal_1",
				icon = "crime_spree_concealment",
				level = 26,
				data = {
					conceal = {
						3,
						"add"
					}
				}
			},
			{
				class = "ModifierCivilianAlarm",
				id = "civs_2",
				icon = "crime_spree_civs_killed",
				level = 52,
				data = {
					count = {
						7,
						"min"
					}
				}
			},
			{
				class = "ModifierLessPagers",
				id = "pagers_2",
				icon = "crime_spree_pager",
				level = 78,
				data = {
					count = {
						2,
						"max"
					}
				}
			},
			{
				class = "ModifierLessConcealment",
				id = "conceal_2",
				icon = "crime_spree_concealment",
				level = 104,
				data = {
					conceal = {
						3,
						"add"
					}
				}
			},
			{
				class = "ModifierLessPagers",
				id = "pagers_3",
				icon = "crime_spree_pager",
				level = 130,
				data = {
					count = {
						3,
						"max"
					}
				}
			},
			{
				class = "ModifierCivilianAlarm",
				id = "civs_3",
				icon = "crime_spree_civs_killed",
				level = 156,
				data = {
					count = {
						4,
						"min"
					}
				}
			},
			{
				class = "ModifierLessPagers",
				id = "pagers_4",
				icon = "crime_spree_pager",
				level = 182,
				data = {
					count = {
						4,
						"max"
					}
				}
			}
		}
	}
	self.repeating_modifiers = {
		forced = {
			{
				class = "ModifierEnemyHealthAndDamage",
				id = "damage_health_rpt_",
				icon = "crime_spree_health",
				level = 5,
				data = {
					health = {
						20,
						"add"
					},
					damage = {
						15,
						"add"
					}
				}
			}
		}
	}
end

function CrimeSpreeTweakData:get_reward_icon(reward)
	for _, data in ipairs(self.rewards) do
		if data.id == reward then
			return data.icon
		end
	end

	return "downcard_overkill_deck"
end

function CrimeSpreeTweakData:init_rewards(tweak_data)
	self.loot_drop_reward_pay_class = 40
	local offshore_rate = tweak_data.money_manager.offshore_rate
	self.rewards = {
		{
			id = "experience",
			always_show = true,
			max_cards = 10,
			card_inc = 200000,
			name_id = "menu_challenge_xp_drop",
			icon = "upcard_xp",
			amount = 20000
		},
		{
			id = "cash",
			max_cards = 10,
			cash_string = "$",
			card_inc = 4000000,
			name_id = "menu_challenge_cash_drop",
			icon = "upcard_cash",
			always_show = true,
			amount = 400000
		},
		{
			id = "continental_coins",
			max_cards = 5,
			card_inc = 4,
			name_id = "menu_cs_coins",
			icon = "upcard_coins",
			amount = 0.4
		},
		{
			id = "loot_drop",
			max_cards = 5,
			card_inc = 5,
			name_id = "menu_challenge_loot_drop",
			icon = "upcard_random",
			amount = 0.2
		},
		{
			id = "random_cosmetic",
			max_cards = 5,
			card_inc = 1,
			name_id = "menu_challenge_cosmetic_drop",
			icon = "upcard_cosmetic",
			amount = 0.007
		}
	}
	self.all_cosmetics_reward = {
		amount = 6,
		type = "continental_coins"
	}
	self.cosmetic_rewards = {
		{
			id = "cvc_green",
			type = "armor"
		},
		{
			id = "cvc_black",
			type = "armor"
		},
		{
			id = "cvc_grey",
			type = "armor"
		},
		{
			id = "cvc_tan",
			type = "armor"
		},
		{
			id = "cvc_navy_blue",
			type = "armor"
		},
		{
			id = "drm_tree_stump",
			type = "armor"
		},
		{
			id = "drm_gray_raider",
			type = "armor"
		},
		{
			id = "drm_desert_twilight",
			type = "armor"
		},
		{
			id = "drm_navy_breeze",
			type = "armor"
		},
		{
			id = "drm_woodland_tech",
			type = "armor"
		},
		{
			id = "drm_khaki_eclipse",
			type = "armor"
		},
		{
			id = "drm_desert_tech",
			type = "armor"
		},
		{
			id = "drm_misted_grey",
			type = "armor"
		},
		{
			id = "drm_khaki_regular",
			type = "armor"
		},
		{
			id = "drm_somber_woodland",
			type = "armor"
		}
	}
end

function CrimeSpreeTweakData:init_gage_assets(tweak_data)
	local asset_cost = 18
	self.max_assets_unlocked = 4
	self.assets = {
		increased_health = {}
	}
	self.assets.increased_health.name_id = "menu_cs_ga_increased_health"
	self.assets.increased_health.unlock_desc_id = "menu_cs_ga_increased_health_desc"
	self.assets.increased_health.icon = "csb_health"
	self.assets.increased_health.cost = asset_cost
	self.assets.increased_health.data = {
		health = 10
	}
	self.assets.increased_health.class = "GageModifierMaxHealth"
	self.assets.increased_armor = {
		name_id = "menu_cs_ga_increased_armor",
		unlock_desc_id = "menu_cs_ga_increased_armor_desc",
		icon = "csb_armor",
		cost = asset_cost,
		data = {
			armor = 10
		},
		class = "GageModifierMaxArmor"
	}
	self.assets.increased_stamina = {
		name_id = "menu_cs_ga_increased_stamina",
		unlock_desc_id = "menu_cs_ga_increased_stamina_desc",
		icon = "csb_stamina",
		cost = asset_cost,
		data = {
			stamina = 100
		},
		class = "GageModifierMaxStamina"
	}
	self.assets.increased_ammo = {
		name_id = "menu_cs_ga_increased_ammo",
		unlock_desc_id = "menu_cs_ga_increased_ammo_desc",
		icon = "csb_ammo",
		cost = asset_cost,
		data = {
			ammo = 15
		},
		class = "GageModifierMaxAmmo"
	}
	self.assets.increased_lives = {
		name_id = "menu_cs_ga_increased_lives",
		unlock_desc_id = "menu_cs_ga_increased_lives_desc",
		icon = "csb_lives",
		cost = asset_cost,
		data = {
			lives = 1
		},
		class = "GageModifierMaxLives"
	}
	self.assets.increased_throwables = {
		name_id = "menu_cs_ga_increased_throwables",
		unlock_desc_id = "menu_cs_ga_increased_throwables_desc",
		icon = "csb_throwables",
		cost = asset_cost,
		data = {
			throwables = 70
		},
		class = "GageModifierMaxThrowables"
	}
	self.assets.increased_deployables = {
		name_id = "menu_cs_ga_increased_deployables",
		unlock_desc_id = "menu_cs_ga_increased_deployables_desc",
		icon = "csb_deployables",
		cost = asset_cost,
		data = {
			deployables = 50
		},
		class = "GageModifierMaxDeployables"
	}
	self.assets.increased_absorption = {
		name_id = "menu_cs_ga_increased_absorption",
		unlock_desc_id = "menu_cs_ga_increased_absorption_desc",
		icon = "csb_absorb",
		cost = asset_cost,
		data = {
			absorption = 0.5
		},
		class = "GageModifierDamageAbsorption"
	}
	self.assets.quick_reload = {
		name_id = "menu_cs_ga_quick_reload",
		unlock_desc_id = "menu_cs_ga_quick_reload_desc",
		icon = "csb_reload",
		cost = asset_cost,
		data = {
			speed = 25
		},
		class = "GageModifierQuickReload"
	}
	self.assets.quick_switch = {
		name_id = "menu_cs_ga_quick_switch",
		unlock_desc_id = "menu_cs_ga_quick_switch_desc",
		icon = "csb_switch",
		cost = asset_cost,
		data = {
			speed = 50
		},
		class = "GageModifierQuickSwitch"
	}
	self.assets.melee_invulnerability = {
		name_id = "menu_cs_ga_melee_invulnerability",
		unlock_desc_id = "menu_cs_ga_melee_invulnerability_desc",
		icon = "csb_melee",
		cost = asset_cost,
		data = {
			time = 5
		},
		class = "GageModifierMeleeInvincibility"
	}
	self.assets.explosion_immunity = {
		name_id = "menu_cs_ga_explosion_immunity",
		unlock_desc_id = "menu_cs_ga_explosion_immunity_desc",
		icon = "csb_explosion",
		cost = asset_cost,
		data = {},
		class = "GageModifierExplosionImmunity"
	}
	self.assets.life_steal = {
		name_id = "menu_cs_ga_life_steal",
		unlock_desc_id = "menu_cs_ga_life_steal_desc",
		icon = "csb_lifesteal",
		cost = asset_cost,
		data = {
			cooldown = 5,
			armor_restored = 0.05,
			health_restored = 0.05
		},
		class = "GageModifierLifeSteal"
	}
	self.assets.quick_pagers = {
		name_id = "menu_cs_ga_quick_pagers",
		unlock_desc_id = "menu_cs_ga_quick_pagers_desc",
		icon = "csb_pagers",
		cost = asset_cost,
		data = {
			speed = 50
		},
		stealth = true,
		class = "GageModifierQuickPagers"
	}
	self.assets.increased_body_bags = {
		name_id = "menu_cs_ga_increased_body_bags",
		unlock_desc_id = "menu_cs_ga_increased_body_bags_desc",
		icon = "csb_bodybags",
		cost = asset_cost,
		data = {
			bags = 2
		},
		stealth = true,
		class = "GageModifierMaxBodyBags"
	}
	self.assets.quick_locks = {
		name_id = "menu_cs_ga_quick_locks",
		unlock_desc_id = "menu_cs_ga_quick_locks_desc",
		icon = "csb_locks",
		cost = asset_cost,
		data = {
			speed = 25
		},
		stealth = true,
		class = "GageModifierQuickLocks"
	}
end

function CrimeSpreeTweakData:init_gui(tweak_data)
	self.gui = {
		randomize_time = {
			1.25,
			2.5
		},
		spin_speed = 800,
		spin_speed_limit = {
			80,
			1000
		},
		max_chat_lines = {
			lobby = 11,
			preplanning = 11
		},
		missions_displayed = 3,
		modifiers_before_scroll = 7
	}
end

function CrimeSpreeTweakData:get_index_from_id(level_id)
	if level_id then
		for i = 1, 3, 1 do
			for index, mission in ipairs(self.missions[i]) do
				if mission.id == level_id then
					local merged_index = i * 100 + index

					return merged_index
				end
			end
		end
	else
		return -1
	end
end

function CrimeSpreeTweakData:get_id_from_index(merged_index)
	local index_has_data = merged_index > 100

	if index_has_data then
		local mission_type = math.floor(merged_index / 100)
		local mission_index = merged_index % 100
		local mission_id = self.missions[mission_type][mission_index].id

		return mission_id
	else
		return -1
	end
end
