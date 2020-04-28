SkirmishTweakData = SkirmishTweakData or class()

function SkirmishTweakData:init(tweak_data)
	self:_init_special_unit_spawn_limits()
	self:_init_group_ai_data(tweak_data)
	self:_init_wave_phase_durations(tweak_data)
	self:_init_spawn_group_weights(tweak_data)
	self:_init_wave_modifiers()
	self:_init_weekly_modifiers()
	self:_init_weekly_rewards()
	self:_init_ransom_amounts()
	self:_init_job_list(tweak_data)
	self:_init_briefing()
	self:_init_additional_rewards()

	self.custody_game_over_delay = 10
end

function SkirmishTweakData:_init_special_unit_spawn_limits()
	self.special_unit_spawn_limits = {
		{
			shield = 4,
			medic = 3,
			taser = 2,
			tank = 2,
			spooc = 2
		},
		{
			shield = 4,
			medic = 3,
			taser = 2,
			tank = 2,
			spooc = 2
		},
		{
			shield = 4,
			medic = 3,
			taser = 2,
			tank = 2,
			spooc = 2
		},
		{
			shield = 5,
			medic = 3,
			taser = 2,
			tank = 3,
			spooc = 2
		},
		{
			shield = 5,
			medic = 3,
			taser = 2,
			tank = 3,
			spooc = 2
		},
		{
			shield = 6,
			medic = 3,
			taser = 3,
			tank = 4,
			spooc = 2
		},
		{
			shield = 6,
			medic = 3,
			taser = 3,
			tank = 4,
			spooc = 2
		},
		{
			shield = 6,
			medic = 4,
			taser = 3,
			tank = 4,
			spooc = 2
		},
		{
			shield = 7,
			medic = 4,
			taser = 3,
			tank = 5,
			spooc = 2
		},
		{
			shield = 7,
			medic = 4,
			taser = 3,
			tank = 5,
			spooc = 2
		},
		{
			shield = 8,
			medic = 4,
			taser = 4,
			tank = 6,
			spooc = 3
		},
		{
			shield = 8,
			medic = 4,
			taser = 4,
			tank = 6,
			spooc = 3
		},
		{
			shield = 8,
			medic = 4,
			taser = 4,
			tank = 6,
			spooc = 3
		},
		{
			shield = 9,
			medic = 4,
			taser = 4,
			tank = 7,
			spooc = 3
		},
		{
			shield = 9,
			medic = 5,
			taser = 4,
			tank = 7,
			spooc = 3
		},
		{
			shield = 10,
			medic = 5,
			taser = 5,
			tank = 8,
			spooc = 3
		},
		{
			shield = 10,
			medic = 5,
			taser = 5,
			tank = 8,
			spooc = 3
		},
		{
			shield = 10,
			medic = 5,
			taser = 5,
			tank = 8,
			spooc = 3
		},
		{
			shield = 11,
			medic = 5,
			taser = 5,
			tank = 9,
			spooc = 3
		},
		{
			shield = 11,
			medic = 5,
			taser = 5,
			tank = 9,
			spooc = 3
		},
		{
			shield = 12,
			medic = 6,
			taser = 6,
			tank = 10,
			spooc = 4
		}
	}
end

function SkirmishTweakData:_init_group_ai_data(tweak_data)
	local skirmish_data = deep_clone(tweak_data.group_ai.besiege)
	skirmish_data.assault.groups = nil
	tweak_data.group_ai.skirmish = skirmish_data
end

function SkirmishTweakData:_init_wave_phase_durations(tweak_data)
	local skirmish_data = tweak_data.group_ai.skirmish
	skirmish_data.assault.anticipation_duration = {
		{
			15,
			1
		}
	}
	skirmish_data.assault.build_duration = 15
	skirmish_data.assault.sustain_duration_min = {
		120,
		120,
		120
	}
	skirmish_data.assault.sustain_duration_max = {
		120,
		120,
		120
	}
	skirmish_data.assault.sustain_duration_balance_mul = {
		1,
		1,
		1,
		1
	}
	skirmish_data.assault.fade_duration = 5
	skirmish_data.assault.delay = {
		25,
		25,
		25
	}
end

function SkirmishTweakData:_init_spawn_group_weights(tweak_data)
	local nice_human_readable_table = {
		{
			18,
			18,
			18,
			18,
			3,
			4,
			3,
			5,
			5,
			3,
			5
		},
		{
			17.71,
			17.71,
			17.71,
			17.71,
			3.1,
			4.1,
			3.1,
			5.13,
			5.13,
			3.1,
			5.5
		},
		{
			17.43,
			17.43,
			17.43,
			17.43,
			3.2,
			4.2,
			3.2,
			5.25,
			5.25,
			3.2,
			6
		},
		{
			17.14,
			17.14,
			17.14,
			17.14,
			3.3,
			4.3,
			3.3,
			5.38,
			5.38,
			3.3,
			6.5
		},
		{
			16.85,
			16.85,
			16.85,
			16.85,
			3.4,
			4.4,
			3.4,
			5.5,
			5.5,
			3.4,
			7
		},
		{
			16.56,
			16.56,
			16.56,
			16.56,
			3.5,
			4.5,
			3.5,
			5.63,
			5.63,
			3.5,
			7.5
		},
		{
			16.28,
			16.28,
			16.28,
			16.28,
			3.6,
			4.6,
			3.6,
			5.75,
			5.75,
			3.6,
			8
		},
		{
			15.99,
			15.99,
			15.99,
			15.99,
			3.7,
			4.7,
			3.7,
			5.88,
			5.88,
			3.7,
			8.5
		},
		{
			15.7,
			15.7,
			15.7,
			15.7,
			3.8,
			4.8,
			3.8,
			6,
			6,
			3.8,
			9
		},
		{
			15.41,
			15.41,
			15.41,
			15.41,
			3.9,
			4.9,
			3.9,
			6.13,
			6.13,
			3.9,
			9.5
		},
		{
			15.13,
			15.13,
			15.13,
			15.13,
			4,
			5,
			4,
			6.25,
			6.25,
			4,
			10
		},
		{
			14.84,
			14.84,
			14.84,
			14.84,
			4.1,
			5.1,
			4.1,
			6.38,
			6.38,
			4.1,
			10.5
		},
		{
			14.55,
			14.55,
			14.55,
			14.55,
			4.2,
			5.2,
			4.2,
			6.5,
			6.5,
			4.2,
			11
		},
		{
			14.26,
			14.26,
			14.26,
			14.26,
			4.3,
			5.3,
			4.3,
			6.63,
			6.63,
			4.3,
			11.5
		},
		{
			13.98,
			13.98,
			13.98,
			13.98,
			4.4,
			5.4,
			4.4,
			6.75,
			6.75,
			4.4,
			12
		},
		{
			13.69,
			13.69,
			13.69,
			13.69,
			4.5,
			5.5,
			4.5,
			6.88,
			6.88,
			4.5,
			12.5
		},
		{
			13.4,
			13.4,
			13.4,
			13.4,
			4.6,
			5.6,
			4.6,
			7,
			7,
			4.6,
			13
		},
		{
			13.11,
			13.11,
			13.11,
			13.11,
			4.7,
			5.7,
			4.7,
			7.13,
			7.13,
			4.7,
			13.5
		},
		{
			12.83,
			12.83,
			12.83,
			12.83,
			4.8,
			5.8,
			4.8,
			7.25,
			7.25,
			4.8,
			14
		},
		{
			12.54,
			12.54,
			12.54,
			12.54,
			4.9,
			5.9,
			4.9,
			7.38,
			7.38,
			4.9,
			14.5
		},
		{
			12.25,
			12.25,
			12.25,
			12.25,
			5,
			6,
			5,
			7.5,
			7.5,
			5,
			15
		}
	}
	local ordered_spawn_group_names = {
		"tac_swat_shotgun_rush",
		"tac_swat_shotgun_flank",
		"tac_swat_rifle",
		"tac_swat_rifle_flank",
		"tac_shield_wall_ranged",
		"tac_shield_wall_charge",
		"tac_shield_wall",
		"tac_tazer_flanking",
		"tac_tazer_charge",
		"FBI_spoocs",
		"tac_bull_rush"
	}

	for _, wave in ipairs(nice_human_readable_table) do
		local total_weight = 0

		for _, weight in ipairs(wave) do
			total_weight = total_weight + weight
		end

		for i, weight in ipairs(wave) do
			wave[i] = weight / total_weight
		end
	end

	self.assault = {
		groups = {}
	}

	for i, src_weights in ipairs(nice_human_readable_table) do
		local dst_weights = {}

		for j, weight in ipairs(src_weights) do
			local group_name = ordered_spawn_group_names[j]
			dst_weights[group_name] = {
				weight,
				weight,
				weight
			}
		end

		self.assault.groups[i] = dst_weights
	end

	local skirmish_assault_meta = {
		__index = function (t, key)
			if key == "groups" then
				local current_wave = managers.skirmish:current_wave_number()
				local current_wave_index = math.clamp(current_wave, 1, #self.assault.groups)

				return self.assault.groups[current_wave_index]
			else
				return rawget(t, key)
			end
		end
	}

	setmetatable(tweak_data.group_ai.skirmish.assault, skirmish_assault_meta)
end

function SkirmishTweakData:_init_wave_modifiers()
	self.wave_modifiers = {}
	local health_damage_multipliers = {
		{
			damage = 1.5,
			health = 1.75
		},
		{
			damage = 2,
			health = 2.5
		},
		{
			damage = 2.5,
			health = 3.25
		},
		{
			damage = 3,
			health = 4
		},
		{
			damage = 3.5,
			health = 3.75
		},
		{
			damage = 4,
			health = 4.5
		},
		{
			damage = 4.5,
			health = 5.25
		},
		{
			damage = 5,
			health = 6
		},
		{
			damage = 5.5,
			health = 6.75
		},
		{
			damage = 6,
			health = 7.5
		},
		{
			damage = 6.5,
			health = 8.25
		},
		{
			damage = 7,
			health = 9
		},
		{
			damage = 1.9,
			health = 1.9
		},
		{
			damage = 1.975,
			health = 1.975
		},
		{
			damage = 2.05,
			health = 2.05
		},
		{
			damage = 2.125,
			health = 2.125
		},
		{
			damage = 2.2,
			health = 2.2
		},
		{
			damage = 2.275,
			health = 2.275
		},
		{
			damage = 2.35,
			health = 2.35
		},
		{
			damage = 2.425,
			health = 2.425
		},
		{
			damage = 2.5,
			health = 2.5
		}
	}
	self.wave_modifiers[1] = {
		{
			class = "ModifierEnemyHealthAndDamageByWave",
			data = {
				waves = health_damage_multipliers,
				excluded_enemies = {
					damage = {
						"sniper",
						"heavy_swat_sniper"
					},
					health = {}
				}
			}
		},
		{
			class = "ModifierCloakerArrest"
		}
	}
	self.wave_modifiers[3] = {
		{
			class = "ModifierSkulldozers"
		}
	}
	self.wave_modifiers[7] = {
		{
			class = "ModifierDozerMedic"
		}
	}
	self.wave_modifiers[9] = {
		{
			class = "ModifierDozerMinigun"
		}
	}
end

function SkirmishTweakData:_init_weekly_modifiers()
	self.weekly_modifiers = {
		wsm01 = {
			icon = "crime_spree_cloaker_tear_gas",
			class = "ModifierCloakerTearGas",
			data = {
				diameter = 4,
				duration = 5,
				damage = 10
			}
		},
		wsm02 = {
			icon = "crime_spree_dozer_rage",
			class = "ModifierDozerRage",
			data = {
				damage = 100
			}
		},
		wsm03 = {
			icon = "crime_spree_medic_speed",
			class = "ModifierHealSpeed",
			data = {
				speed = 40
			}
		},
		wsm04 = {
			icon = "crime_spree_medic_rage",
			class = "ModifierMedicRage",
			data = {
				damage = 20
			}
		},
		wsm05 = {
			icon = "crime_spree_medic_adrenaline",
			class = "ModifierMedicAdrenaline",
			data = {
				damage = 100
			}
		},
		wsm06 = {
			icon = "crime_spree_more_dozers",
			class = "ModifierMoreDozers",
			data = {
				inc = 4
			}
		},
		wsm07 = {
			icon = "crime_spree_shield_phalanx",
			class = "ModifierShieldPhalanx",
			data = {}
		},
		wsm08 = {
			icon = "crime_spree_shield_reflect",
			class = "ModifierShieldReflect",
			data = {}
		},
		wsm09 = {
			icon = "crime_spree_heavies",
			class = "ModifierHeavies",
			data = {}
		},
		wsm10 = {
			icon = "crime_spree_no_hurt",
			class = "ModifierNoHurtAnims",
			data = {}
		}
	}
end

function SkirmishTweakData:_init_weekly_rewards()
	self.weekly_rewards = {
		{
			textures = {
				"barbedwire",
				"catface",
				"clutter",
				"facecollage",
				"facename",
				"frankenstein",
				"knife",
				"lovehate",
				"predator_billy",
				"predator_blain",
				"predator_dillan",
				"predator_dutch",
				"predator_hawkins",
				"predator_mac",
				"predator_poncho",
				"shades_3d",
				"shades_80s",
				"shades_band",
				"shades_punk",
				"shades_shutter",
				"shades_sport",
				"wavewarning"
			}
		},
		{
			textures = {
				"bloodhand",
				"hostage",
				"ransom_1mdollars",
				"ransom_bangbang",
				"ransom_cashking",
				"ransom_diepig",
				"ransom_gameover",
				"ransom_pledge",
				"skullshape",
				"splat"
			},
			masks = {
				"skm_01",
				"skm_02",
				"skm_03",
				"skm_04",
				"smo_01",
				"smo_02",
				"smo_03",
				"smo_04",
				"smo_05",
				"smo_06"
			}
		},
		{
			masks = {
				"skm_05",
				"skm_06",
				"skm_07",
				"skm_08",
				"smo_07",
				"smo_08",
				"smo_09",
				"smo_10",
				"smo_11",
				"smo_12"
			}
		}
	}
end

function SkirmishTweakData:_init_ransom_amounts()
	self.ransom_amounts = {
		1600000,
		1840000,
		2120000,
		2440000,
		2810000,
		3240000,
		3730000,
		4290000,
		4940000
	}

	for i, ransom in ipairs(self.ransom_amounts) do
		self.ransom_amounts[i] = ransom + (self.ransom_amounts[i - 1] or 0)
	end
end

function SkirmishTweakData:_init_job_list(tweak_data)
	self.job_list = {}

	for job_name, job in pairs(tweak_data.narrative.jobs) do
		if job.contact == "skirmish" then
			local level_name = job.chain[1].level_id
			local level = tweak_data.levels[level_name]

			if level and level.group_ai_state == "skirmish" then
				table.insert(self.job_list, job_name)
			end
		end
	end
end

function SkirmishTweakData:_init_briefing()
	self.random_skirmish = {
		crimenet_videos = {
			"codex/locke1"
		}
	}
end

function SkirmishTweakData:_init_additional_rewards()
	local tier1 = deep_clone(self.weekly_rewards[1])
	local tier2 = deep_clone(self.weekly_rewards[2])
	local tier3 = deep_clone(self.weekly_rewards[3])
	tier2.weapon_skins = {
		"color_red_crust",
		"color_blue_deluxe",
		"color_purple_song",
		"color_blue_teal",
		"color_green_mellow"
	}
	tier3.weapon_skins = {
		"color_blue_deep",
		"color_blue_ice",
		"color_orange_mellow",
		"color_green_deluxe",
		"color_pink_cat"
	}
	self.additional_rewards = {
		[3] = tier1,
		[5] = tier2,
		[9] = tier3
	}
	self.additional_lootdrops = {
		[3.0] = 1,
		[5.0] = 2,
		[9.0] = 4
	}
	self.additional_coins = {
		[3.0] = 1,
		[5.0] = 2,
		[9.0] = 3
	}
end
