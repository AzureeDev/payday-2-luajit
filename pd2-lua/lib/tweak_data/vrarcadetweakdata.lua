local SELECTION = {
	SECONDARY = 1,
	PRIMARY = 2
}
VRArcadeTweakData = VRArcadeTweakData or class()

function VRArcadeTweakData:init(tweak_data)
	self.packages = {
		"packages/vr_arcade_base"
	}
	self.loadouts = {
		rifle_american = {
			name_id = "bm_loadout_rifle_american",
			loadout = {
				secondaries = {
					factory_id = "wpn_fps_pis_1911",
					equipped = true,
					weapon_id = "colt_1911",
					global_values = {
						wpn_fps_upg_fl_pis_crimson = "pd2_clan",
						wpn_fps_pis_1911_co_2 = "normal"
					},
					blueprint = {
						"wpn_fps_pis_1911_body_standard",
						"wpn_fps_pis_1911_b_standard",
						"wpn_fps_pis_1911_g_standard",
						"wpn_fps_pis_1911_m_standard",
						"wpn_fps_pis_1911_co_2",
						"wpn_fps_upg_fl_pis_crimson"
					}
				},
				primaries = {
					factory_id = "wpn_fps_ass_amcar",
					equipped = true,
					weapon_id = "amcar",
					texture_switches = {
						wpn_fps_upg_o_45rds = "1 3"
					},
					global_values = {
						wpn_fps_m4_uupg_m_std = "normal",
						wpn_fps_upg_o_45rds = "tango",
						wpn_fps_upg_fl_ass_laser = "gage_pack_jobs"
					},
					blueprint = {
						"wpn_fps_m4_uupg_b_medium_vanilla",
						"wpn_fps_m4_lower_reciever",
						"wpn_fps_amcar_uupg_body_upperreciever",
						"wpn_fps_amcar_uupg_fg_amcar",
						"wpn_fps_upg_m4_s_standard_vanilla",
						"wpn_fps_upg_m4_g_standard_vanilla",
						"wpn_fps_upg_fl_ass_laser",
						"wpn_fps_upg_o_45rds",
						"wpn_fps_m4_uupg_m_std"
					}
				}
			}
		},
		rifle_russian = {
			name_id = "bm_loadout_rifle_russian",
			loadout = {
				secondaries = {
					factory_id = "wpn_fps_pis_g17",
					equipped = true,
					weapon_id = "glock_17",
					global_values = {
						wpn_fps_upg_fl_pis_crimson = "pd2_clan"
					},
					blueprint = {
						"wpn_fps_pis_g17_body_standard",
						"wpn_fps_pis_g17_b_standard",
						"wpn_fps_pis_g17_m_standard",
						"wpn_fps_upg_fl_pis_crimson"
					}
				},
				primaries = {
					factory_id = "wpn_fps_ass_akm",
					equipped = true,
					weapon_id = "akm",
					texture_switches = {
						wpn_fps_upg_o_docter = "1 3",
						wpn_fps_upg_o_45rds = "1 3"
					},
					global_values = {
						wpn_fps_upg_ak_s_solidstock = "akm4_pack",
						wpn_fps_upg_o_45rds = "tango",
						wpn_fps_upg_o_ak_scopemount = "akm4_pack",
						wpn_fps_upg_fl_ass_laser = "gage_pack_jobs",
						wpn_fps_upg_o_docter = "normal"
					},
					blueprint = {
						"wpn_upg_ak_fg_standard",
						"wpn_upg_ak_m_akm",
						"wpn_upg_ak_g_standard",
						"wpn_fps_ass_akm_b_standard",
						"wpn_fps_ass_akm_body_upperreceiver_vanilla",
						"wpn_fps_ass_ak_body_lowerreceiver",
						"wpn_fps_upg_fl_ass_laser",
						"wpn_fps_upg_o_docter",
						"wpn_fps_upg_o_45rds",
						"wpn_fps_upg_ak_s_solidstock",
						"wpn_fps_upg_o_ak_scopemount"
					}
				}
			}
		},
		sniper = {
			name_id = "bm_loadout_sniper",
			loadout = {
				secondaries = {
					factory_id = "wpn_fps_smg_mp5",
					equipped = true,
					weapon_id = "new_mp5",
					global_values = {
						wpn_fps_smg_mp5_fg_m5k = "normal",
						wpn_fps_smg_mp5_s_ring = "normal",
						wpn_fps_upg_fl_ass_laser = "gage_pack_jobs"
					},
					blueprint = {
						"wpn_fps_smg_mp5_body_mp5",
						"wpn_fps_smg_mp5_m_std",
						"wpn_fps_smg_mp5_fg_m5k",
						"wpn_fps_upg_fl_ass_laser",
						"wpn_fps_smg_mp5_s_ring"
					}
				},
				primaries = {
					factory_id = "wpn_fps_snp_tti",
					equipped = true,
					weapon_id = "tti",
					texture_switches = {
						wpn_fps_upg_o_acog = "1 3"
					},
					global_values = {
						wpn_fps_upg_o_45iron = "gage_pack_snp",
						wpn_fps_upg_o_acog = "normal",
						wpn_fps_upg_fl_ass_laser = "gage_pack_jobs"
					},
					blueprint = {
						"wpn_fps_snp_tti_vg_standard",
						"wpn_fps_snp_tti_ns_standard",
						"wpn_fps_snp_tti_m_standard",
						"wpn_fps_snp_tti_fg_standard",
						"wpn_fps_snp_tti_dhs_switch",
						"wpn_fps_snp_tti_dh_standard",
						"wpn_fps_snp_tti_bolt_standard",
						"wpn_fps_snp_tti_body_receiverupper",
						"wpn_fps_snp_tti_body_receiverlower",
						"wpn_fps_snp_tti_b_standard",
						"wpn_fps_ass_contraband_s_standard",
						"wpn_fps_upg_m4_g_standard_vanilla",
						"wpn_fps_upg_o_acog",
						"wpn_fps_upg_o_45iron",
						"wpn_fps_upg_fl_ass_laser"
					}
				}
			}
		},
		shotgun = {
			name_id = "bm_loadout_shotgun",
			loadout = {
				secondaries = {
					factory_id = "wpn_fps_smg_schakal",
					equipped = true,
					weapon_id = "schakal",
					texture_switches = {
						wpn_fps_upg_o_reflex = "1 3"
					},
					global_values = {
						wpn_fps_upg_o_reflex = "gage_pack_jobs",
						wpn_fps_smg_schakal_s_folded = "pim",
						wpn_fps_upg_fl_ass_laser = "gage_pack_jobs"
					},
					blueprint = {
						"wpn_fps_smg_schakal_b_standard",
						"wpn_fps_smg_schakal_body_lower",
						"wpn_fps_smg_schakal_body_upper",
						"wpn_fps_smg_schakal_m_standard",
						"wpn_fps_smg_schakal_dh_standard",
						"wpn_fps_smg_schakal_bolt_standard",
						"wpn_fps_upg_vg_ass_smg_verticalgrip",
						"wpn_fps_smg_schakal_extra_magrelease",
						"wpn_fps_upg_fl_ass_laser",
						"wpn_fps_upg_o_reflex",
						"wpn_fps_smg_schakal_s_folded"
					}
				},
				primaries = {
					factory_id = "wpn_fps_sho_aa12",
					equipped = true,
					weapon_id = "aa12",
					texture_switches = {
						wpn_fps_upg_o_docter = "1 3"
					},
					global_values = {
						wpn_fps_sho_aa12_mag_drum = "bbq",
						wpn_fps_upg_o_docter = "normal",
						wpn_fps_upg_fl_ass_laser = "gage_pack_jobs"
					},
					blueprint = {
						"wpn_fps_sho_aa12_dh",
						"wpn_fps_sho_aa12_bolt",
						"wpn_fps_sho_aa12_body",
						"wpn_fps_sho_aa12_barrel",
						"wpn_fps_upg_fl_ass_laser",
						"wpn_fps_sho_aa12_mag_drum",
						"wpn_fps_upg_o_docter"
					}
				}
			}
		}
	}
	self.forced_armor = "level_1"
	self.forced_difficulty = "normal"
	self.default_weapon_selection = SELECTION.SECONDARY
	self.infinite_reserve_ammo = true
	self.grenades_forbidden = true
	self.melee_forbidden = true
	self.disable_flashbangs = true
	self.extra_body_armor_sparks = true
	self.reload_time = 1
	self.respawn_time = 5
	self.respawn_grace_period = 5
	self.team_ai_players_add = {
		1,
		0,
		0
	}

	self:init_player_tweak_data(tweak_data)
	self:init_upgrades_tweak_data(tweak_data)
	self:init_weapon_tweak_data(tweak_data)
	self:init_weapon_factory_tweak_data(tweak_data)
	self:init_character_tweak_data(tweak_data)
	self:init_group_ai_tweak_data(tweak_data)
	self:init_interaction_tweak_data(tweak_data)
	self:init_scoring(tweak_data)
end

function VRArcadeTweakData:init_player_tweak_data(tweak_data)
	tweak_data.player.damage.REVIVE_HEALTH_STEPS = {
		1
	}
	tweak_data.player.damage.HEALTH_INIT = 100
end

function VRArcadeTweakData:init_upgrades_tweak_data(tweak_data)
	local default_armor_amount = 1
	tweak_data.upgrades.values.player.body_armor = {
		armor = {
			default_armor_amount,
			default_armor_amount,
			default_armor_amount,
			default_armor_amount,
			default_armor_amount,
			default_armor_amount,
			default_armor_amount
		},
		movement = {
			1,
			1,
			1,
			1,
			1,
			1,
			1
		},
		concealment = {
			30,
			30,
			30,
			30,
			30,
			30,
			30
		},
		dodge = {
			0,
			0,
			0,
			0,
			0,
			0,
			0
		},
		damage_shake = {
			1,
			1,
			1,
			1,
			1,
			1,
			1
		},
		stamina = {
			99,
			99,
			99,
			99,
			99,
			99,
			99
		}
	}
end

function VRArcadeTweakData:init_weapon_tweak_data(tweak_data)
	tweak_data.weapon.amcar.tracers = 2
	tweak_data.weapon.amcar.sounds = tweak_data.weapon.m16.sounds
	tweak_data.weapon.amcar.fire_mode_data = tweak_data.weapon.m16.fire_mode_data
	tweak_data.weapon.amcar.auto = tweak_data.weapon.m16.auto
	tweak_data.weapon.amcar.CLIP_AMMO_MAX = 30
	tweak_data.weapon.amcar.stats.spread = 22
	tweak_data.weapon.amcar.stats.damage = 8
	tweak_data.weapon.colt_1911.fire_mode_data.fire_rate = 0.07
	tweak_data.weapon.colt_1911.single.fire_rate = 0.07
	tweak_data.weapon.colt_1911.stats.spread = 24
	tweak_data.weapon.colt_1911.stats.damage = 11
	tweak_data.weapon.akm.tracers = 2
	tweak_data.weapon.akm.stats.spread = 24
	tweak_data.weapon.akm.stats.damage = 12
	tweak_data.weapon.glock_17.use_data.selection_index = SELECTION.SECONDARY
	tweak_data.weapon.glock_17.stats.spread = 22
	tweak_data.weapon.glock_17.stats.damage = 9
	tweak_data.weapon.tti.tracers = 3
	tweak_data.weapon.tti.fire_mode_data.fire_rate = 0.15
	tweak_data.weapon.tti.single.fire_rate = 0.15
	tweak_data.weapon.tti.stats.spread = 26
	tweak_data.weapon.tti.stats.damage = 28
	tweak_data.weapon.new_mp5.sounds = tweak_data.weapon.mp7.sounds
	tweak_data.weapon.new_mp5.fire_mode_data.fire_rate = tweak_data.weapon.mp7.fire_mode_data.fire_rate
	tweak_data.weapon.new_mp5.auto.fire_rate = tweak_data.weapon.mp7.auto.fire_rate
	tweak_data.weapon.new_mp5.stats.spread = 20
	tweak_data.weapon.new_mp5.stats.damage = 8
	tweak_data.weapon.schakal.stats.spread = 22
	tweak_data.weapon.schakal.stats.damage = 8
	tweak_data.weapon.aa12.stats.spread = 10
	tweak_data.weapon.aa12.stats.damage = 22
	tweak_data.vr.reload_timelines.amcar = {
		start = {
			{
				time = 0,
				sound = "wp_bbv_rifle_mag_out"
			},
			{
				time = 0.05,
				visible = false,
				pos = Vector3(0, 5, -20),
				rot = Rotation(0, 30, 0)
			}
		},
		finish = {
			{
				time = 0,
				sound = "wp_bbv_rifle_mag_in",
				visible = true,
				pos = Vector3(0, 0, -20)
			},
			{
				time = 0.1,
				pos = Vector3(0, 0, -4.5)
			},
			{
				time = 0.56,
				pos = Vector3(0, 0, -4)
			},
			{
				time = 0.6,
				sound = "wp_m4_lever_release",
				pos = Vector3()
			}
		}
	}
	tweak_data.vr.reload_timelines.glock_17 = {
		start = {
			{
				time = 0,
				sound = "wp_bbv_pistol_mag_out"
			},
			{
				time = 0.05,
				visible = false,
				pos = Vector3(0, -7, -20)
			}
		},
		finish = {
			{
				time = 0,
				sound = "wp_bbv_pistol_mag_in",
				visible = true,
				pos = Vector3(0, -7, -20)
			},
			{
				time = 0.1,
				pos = Vector3(0, -4, -10)
			},
			{
				time = 0.56,
				pos = Vector3(0, -4, -10)
			},
			{
				time = 0.6,
				sound = "wp_g17_lever_release",
				pos = Vector3()
			}
		}
	}
	tweak_data.vr.reload_timelines.aa12 = {
		start = {
			{
				time = 0,
				sound = "wp_bbv_shotgun_mag_out"
			},
			{
				time = 0.01,
				pos = Vector3(0, 0.1, -4)
			},
			{
				time = 0.06,
				pos = Vector3(0, 0.1, -4)
			},
			{
				time = 0.1,
				visible = false,
				pos = Vector3(0, 2, -30)
			}
		},
		finish = {
			{
				time = 0,
				sound = "wp_bbv_shotgun_mag_in",
				visible = true,
				pos = Vector3(0, 2, -20)
			},
			{
				time = 0.1,
				pos = Vector3(0, 0.1, -4.5)
			},
			{
				time = 0.56,
				pos = Vector3(0, 0.1, -4.5)
			},
			{
				time = 0.6,
				sound = "wp_aa12_lever_pull",
				pos = Vector3()
			}
		}
	}
	tweak_data.vr.reload_timelines.schakal = {
		start = {
			{
				time = 0,
				sound = "wp_bbv_smg_mag_out"
			},
			{
				time = 0.05,
				visible = false,
				pos = Vector3(0, 5, -20)
			}
		},
		finish = {
			{
				time = 0,
				sound = "wp_bbv_smg_mag_in",
				visible = true,
				pos = Vector3(0, 2.5, -10)
			},
			{
				time = 0.1,
				pos = Vector3(0, 0.9, -3.5)
			},
			{
				time = 0.56,
				pos = Vector3(0, 0.9, -3.5)
			},
			{
				time = 0.6,
				sound = "wp_schakal_bolt_slap",
				pos = Vector3()
			}
		}
	}
	tweak_data.vr.reload_timelines.akm = {
		start = {
			{
				time = 0,
				sound = "wp_bbv_rifle_mag_out"
			},
			{
				time = 0.02,
				pos = Vector3(0, 4, -1),
				rot = Rotation(0, 30, 0)
			},
			{
				time = 0.05,
				visible = false,
				pos = Vector3(0, 10, -20),
				rot = Rotation(0, 60, 0)
			}
		},
		finish = {
			{
				time = 0,
				sound = "wp_bbv_rifle_mag_in",
				visible = true,
				pos = Vector3(0, 0, -20),
				rot = Rotation()
			},
			{
				time = 0.3,
				pos = Vector3(0, 4, -1),
				rot = Rotation(0, 30, 0)
			},
			{
				time = 0.5,
				sound = "wp_ak47_lever_release",
				pos = Vector3(),
				rot = Rotation()
			}
		}
	}
	tweak_data.vr.reload_timelines.colt_1911 = {
		start = {
			{
				time = 0,
				sound = "wp_bbv_pistol_mag_out"
			},
			{
				time = 0.05,
				visible = false,
				pos = Vector3(0, -4, -12)
			}
		},
		finish = {
			{
				time = 0,
				sound = "wp_bbv_pistol_mag_in",
				visible = true,
				pos = Vector3(0, -5, -20)
			},
			{
				time = 0.1,
				pos = Vector3(0, -4, -12)
			},
			{
				time = 0.56,
				pos = Vector3(0, -4, -12)
			},
			{
				time = 0.6,
				sound = "wp_usp_mantel_back",
				pos = Vector3()
			}
		}
	}
	tweak_data.vr.reload_timelines.tti = {
		start = {
			{
				time = 0,
				sound = "wp_bbv_rifle_mag_out"
			},
			{
				time = 0.05,
				visible = false,
				pos = Vector3(0, 5, -20),
				rot = Rotation(0, 30, 0)
			}
		},
		finish = {
			{
				time = 0,
				sound = "wp_bbv_rifle_mag_in",
				visible = true,
				pos = Vector3(0, 0, -20)
			},
			{
				time = 0.1,
				pos = Vector3(0, 0, -4.5)
			},
			{
				time = 0.56,
				pos = Vector3(0, 0, -4)
			},
			{
				time = 0.6,
				sound = "wp_tti_release_lever",
				pos = Vector3()
			}
		}
	}
	tweak_data.vr.reload_timelines.new_mp5 = {
		start = {
			{
				time = 0,
				sound = "wp_bbv_smg_mag_out"
			},
			{
				time = 0.02,
				pos = Vector3(0, 2, -4),
				rot = Rotation(0, 20, 0)
			},
			{
				time = 0.05,
				visible = false,
				pos = Vector3(0, 2, -20),
				rot = Rotation(0, 10, 0)
			},
			{
				time = 0.051,
				pos = Vector3(0, 2, -10),
				rot = Rotation()
			}
		},
		finish = {
			{
				time = 0,
				sound = "wp_bbv_smg_mag_in",
				visible = true,
				pos = Vector3(0, 2, -10),
				rot = Rotation()
			},
			{
				time = 0.04,
				pos = Vector3(0, 2, -4),
				rot = Rotation()
			},
			{
				time = 0.045,
				pos = Vector3(0, 2, -4),
				rot = Rotation(0, 30, 0)
			},
			{
				time = 0.5,
				sound = "wp_mp5_lever_release",
				pos = Vector3(),
				rot = Rotation()
			}
		}
	}
	tweak_data.weapon.c45_npc.DAMAGE = 1
	tweak_data.weapon.mp5_npc.DAMAGE = 1
	tweak_data.weapon.m249_npc.DAMAGE = 1
	tweak_data.weapon.m4_npc.DAMAGE = 1
	tweak_data.weapon.r870_npc.DAMAGE = 1
	tweak_data.weapon.raging_bull_npc.DAMAGE = 1
	tweak_data.weapon.saiga_npc.DAMAGE = 1
	tweak_data.weapon.saiga_npc.CLIP_AMMO_MAX = 15
	tweak_data.weapon.ak47_npc.DAMAGE = 0.12
	tweak_data.weapon.ak47_crew.DAMAGE = 0.12
	tweak_data.weapon.beretta92_npc.DAMAGE = 0.1
end

function VRArcadeTweakData:init_weapon_factory_tweak_data(tweak_data)
	tweak_data.weapon.factory.allow_multiple_part_types = {
		"gadget"
	}
	tweak_data.weapon.factory.parts.wpn_fps_m4_uupg_m_std.stats.extra_ammo = nil
end

function VRArcadeTweakData:init_character_tweak_data(tweak_data)
	tweak_data.character.cop.HEALTH_INIT = 1
	tweak_data.character.cop.headshot_dmg_mul = 3
	tweak_data.character.cop.weapon = tweak_data.character.presets.weapon.normal
	tweak_data.character.swat.HEALTH_INIT = 1.5
	tweak_data.character.swat.headshot_dmg_mul = 2.5
	tweak_data.character.swat.weapon = tweak_data.character.presets.weapon.good
	tweak_data.character.heavy_swat.HEALTH_INIT = 2
	tweak_data.character.heavy_swat.headshot_dmg_mul = 2
	tweak_data.character.heavy_swat.weapon = tweak_data.character.presets.weapon.expert
	tweak_data.character.fbi.HEALTH_INIT = 1.8
	tweak_data.character.fbi.headshot_dmg_mul = 2
	tweak_data.character.fbi.weapon = tweak_data.character.presets.weapon.deathwish
	tweak_data.character.fbi_swat.HEALTH_INIT = 2
	tweak_data.character.fbi_swat.headshot_dmg_mul = 2
	tweak_data.character.fbi_swat.weapon = tweak_data.character.presets.weapon.good
	tweak_data.character.fbi_heavy_swat.HEALTH_INIT = 3
	tweak_data.character.fbi_heavy_swat.headshot_dmg_mul = 3
	tweak_data.character.fbi_heavy_swat.weapon = tweak_data.character.presets.weapon.good
	tweak_data.character.city_swat.HEALTH_INIT = 3
	tweak_data.character.city_swat.headshot_dmg_mul = 3
	tweak_data.character.city_swat.weapon = tweak_data.character.presets.weapon.good
	tweak_data.character.taser.HEALTH_INIT = 10
	tweak_data.character.taser.headshot_dmg_mul = 3
	tweak_data.character.tank.HEALTH_INIT = 50
	tweak_data.character.tank.headshot_dmg_mul = 5
	tweak_data.character.sniper.HEALTH_INIT = 1
	tweak_data.character.sniper.headshot_dmg_mul = 10
	tweak_data.character.presets.gang_member_damage.HEALTH_INIT = 1000
	tweak_data.character.presets.gang_member_damage.REGENERATE_TIME = 2
	tweak_data.character.presets.gang_member_damage.REGENERATE_TIME_AWAY = 2

	for _, char in ipairs(tweak_data.criminals.characters) do
		tweak_data.character[char.name].damage = tweak_data.character.presets.gang_member_damage
	end

	tweak_data.character.presets.weapon.normal.is_pistol.FALLOFF = {
		{
			dmg_mul = 1,
			r = 500,
			acc = {
				0.4,
				0.85
			},
			recoil = {
				0.1,
				0.25
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0.8,
			r = 1000,
			acc = {
				0.375,
				0.55
			},
			recoil = {
				0.15,
				0.3
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0.5,
			r = 2000,
			acc = {
				0.25,
				0.45
			},
			recoil = {
				0.3,
				0.7
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0.4,
			r = 3000,
			acc = {
				0.01,
				0.35
			},
			recoil = {
				0.4,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	tweak_data.character.presets.weapon.normal.is_revolver.FALLOFF = {
		{
			dmg_mul = 4,
			r = 500,
			acc = {
				0.5,
				0.85
			},
			recoil = {
				0.8,
				1.1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2.5,
			r = 1000,
			acc = {
				0.375,
				0.55
			},
			recoil = {
				0.8,
				1.1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 1.5,
			r = 2000,
			acc = {
				0.25,
				0.45
			},
			recoil = {
				1,
				1.3
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 3000,
			acc = {
				0.01,
				0.35
			},
			recoil = {
				1,
				1.5
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	tweak_data.character.presets.weapon.normal.is_shotgun_pump.FALLOFF = {
		{
			dmg_mul = 5,
			r = 500,
			acc = {
				0.4,
				0.9
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 3,
			r = 1000,
			acc = {
				0.2,
				0.75
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0.5,
			r = 2000,
			acc = {
				0.01,
				0.25
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0.2,
			r = 3000,
			acc = {
				0.05,
				0.35
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	tweak_data.character.presets.weapon.normal.is_smg.FALLOFF = {
		{
			dmg_mul = 1,
			r = 100,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.1,
				0.3
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 1,
			r = 500,
			acc = {
				0.4,
				0.9
			},
			recoil = {
				0.1,
				0.3
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 0.8,
			r = 1000,
			acc = {
				0.2,
				0.8
			},
			recoil = {
				0.3,
				0.4
			},
			mode = {
				0,
				3,
				3,
				0
			}
		},
		{
			dmg_mul = 0.6,
			r = 2000,
			acc = {
				0.1,
				0.45
			},
			recoil = {
				0.3,
				0.4
			},
			mode = {
				0,
				3,
				3,
				0
			}
		},
		{
			dmg_mul = 0.4,
			r = 3000,
			acc = {
				0.1,
				0.35
			},
			recoil = {
				0.5,
				0.6
			},
			mode = {
				1,
				3,
				2,
				0
			}
		}
	}
	tweak_data.character.presets.weapon.good.is_rifle.FALLOFF = {
		{
			dmg_mul = 1.5,
			r = 500,
			acc = {
				0.4,
				0.9
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 1.5,
			r = 1000,
			acc = {
				0.2,
				0.8
			},
			recoil = {
				0.35,
				0.75
			},
			mode = {
				1,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 2000,
			acc = {
				0.2,
				0.5
			},
			recoil = {
				0.4,
				1.2
			},
			mode = {
				3,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 0.7,
			r = 3000,
			acc = {
				0.01,
				0.35
			},
			recoil = {
				1.5,
				3
			},
			mode = {
				3,
				1,
				1,
				0
			}
		}
	}
	tweak_data.character.presets.weapon.good.is_shotgun_pump.FALLOFF = {
		{
			dmg_mul = 5,
			r = 500,
			acc = {
				0.4,
				0.95
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 3,
			r = 1000,
			acc = {
				0.2,
				0.75
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 2000,
			acc = {
				0.01,
				0.25
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0.4,
			r = 3000,
			acc = {
				0.05,
				0.35
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	tweak_data.character.presets.weapon.good.is_smg.FALLOFF = {
		{
			dmg_mul = 1,
			r = 100,
			acc = {
				0.4,
				0.8
			},
			recoil = {
				0.1,
				0.25
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 1,
			r = 500,
			acc = {
				0.4,
				0.7
			},
			recoil = {
				0.1,
				0.3
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 1,
			r = 1000,
			acc = {
				0.2,
				0.55
			},
			recoil = {
				0.35,
				0.8
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 0.5,
			r = 2000,
			acc = {
				0.1,
				0.45
			},
			recoil = {
				0.35,
				0.6
			},
			mode = {
				0,
				3,
				3,
				0
			}
		},
		{
			dmg_mul = 0.4,
			r = 3000,
			acc = {
				0.1,
				0.35
			},
			recoil = {
				0.5,
				0.6
			},
			mode = {
				1,
				3,
				2,
				0
			}
		}
	}
	tweak_data.character.presets.weapon.expert.is_shotgun_pump.aim_delay = {
		0.1,
		0.1
	}
	tweak_data.character.presets.weapon.expert.is_shotgun_pump.focus_delay = 4
	tweak_data.character.presets.weapon.expert.is_shotgun_pump.FALLOFF = {
		{
			dmg_mul = 7.5,
			r = 500,
			acc = {
				0.4,
				0.95
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 5,
			r = 1000,
			acc = {
				0.2,
				0.75
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 2000,
			acc = {
				0.01,
				0.25
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0.4,
			r = 3000,
			acc = {
				0.05,
				0.35
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	tweak_data.character.presets.weapon.expert.is_rifle.aim_delay = {
		0.1,
		0.1
	}
	tweak_data.character.presets.weapon.expert.is_rifle.focus_delay = 3
	tweak_data.character.presets.weapon.expert.is_rifle.FALLOFF = {
		{
			dmg_mul = 1.5,
			r = 500,
			acc = {
				0.4,
				0.9
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 1.5,
			r = 1000,
			acc = {
				0.2,
				0.8
			},
			recoil = {
				0.35,
				0.75
			},
			mode = {
				1,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 2000,
			acc = {
				0.2,
				0.5
			},
			recoil = {
				0.4,
				1.2
			},
			mode = {
				3,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 0.5,
			r = 3000,
			acc = {
				0.01,
				0.35
			},
			recoil = {
				1.5,
				3
			},
			mode = {
				3,
				1,
				1,
				0
			}
		}
	}
	tweak_data.character.presets.weapon.expert.is_smg.aim_delay = {
		0.1,
		0.2
	}
	tweak_data.character.presets.weapon.expert.is_smg.focus_delay = 2
	tweak_data.character.presets.weapon.expert.is_smg.FALLOFF = {
		{
			dmg_mul = 1.25,
			r = 100,
			acc = {
				0.4,
				0.95
			},
			recoil = {
				0.1,
				0.25
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 1.25,
			r = 500,
			acc = {
				0.4,
				0.9
			},
			recoil = {
				0.1,
				0.3
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 1.25,
			r = 1000,
			acc = {
				0.3,
				0.65
			},
			recoil = {
				0.35,
				0.5
			},
			mode = {
				0,
				3,
				3,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 2000,
			acc = {
				0.3,
				0.6
			},
			recoil = {
				0.35,
				0.7
			},
			mode = {
				0,
				3,
				3,
				0
			}
		},
		{
			dmg_mul = 0.5,
			r = 3000,
			acc = {
				0.2,
				0.35
			},
			recoil = {
				0.5,
				1.5
			},
			mode = {
				1,
				3,
				2,
				0
			}
		}
	}
	tweak_data.character.presets.weapon.deathwish.is_pistol.aim_delay = {
		0.1,
		0.1
	}
	tweak_data.character.presets.weapon.deathwish.is_pistol.focus_delay = 2
	tweak_data.character.presets.weapon.deathwish.is_pistol.RELOAD_SPEED = 1.2
	tweak_data.character.presets.weapon.deathwish.is_pistol.FALLOFF = {
		{
			dmg_mul = 2,
			r = 500,
			acc = {
				0.4,
				0.85
			},
			recoil = {
				0.1,
				0.25
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 1000,
			acc = {
				0.475,
				0.65
			},
			recoil = {
				0.15,
				0.3
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 2000,
			acc = {
				0.35,
				0.55
			},
			recoil = {
				0.3,
				0.7
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0.4,
			r = 3000,
			acc = {
				0.1,
				0.45
			},
			recoil = {
				0.4,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	tweak_data.character.presets.weapon.deathwish.is_rifle.aim_delay = {
		0.1,
		0.1
	}
	tweak_data.character.presets.weapon.deathwish.is_rifle.focus_delay = 3
	tweak_data.character.presets.weapon.deathwish.is_rifle.RELOAD_SPEED = 1.2
	tweak_data.character.presets.weapon.deathwish.is_rifle.FALLOFF = {
		{
			dmg_mul = 3,
			r = 500,
			acc = {
				0.4,
				0.8
			},
			recoil = {
				0.45,
				0.6
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 2,
			r = 1000,
			acc = {
				0.3,
				0.75
			},
			recoil = {
				0.35,
				0.75
			},
			mode = {
				1,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 2000,
			acc = {
				0.2,
				0.4
			},
			recoil = {
				0.4,
				1.1
			},
			mode = {
				3,
				2,
				2,
				0
			}
		},
		{
			dmg_mul = 0.5,
			r = 3000,
			acc = {
				0.01,
				0.25
			},
			recoil = {
				0.8,
				1.5
			},
			mode = {
				3,
				1,
				1,
				0
			}
		}
	}
	tweak_data.character.presets.weapon.deathwish.is_shotgun_pump.aim_delay = {
		0.1,
		0.1
	}
	tweak_data.character.presets.weapon.deathwish.is_shotgun_pump.focus_delay = 4
	tweak_data.character.presets.weapon.deathwish.is_shotgun_pump.RELOAD_SPEED = 1.2
	tweak_data.character.presets.weapon.deathwish.is_shotgun_pump.FALLOFF = {
		{
			dmg_mul = 9,
			r = 500,
			acc = {
				0.4,
				0.95
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 5,
			r = 1000,
			acc = {
				0.2,
				0.75
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 2000,
			acc = {
				0.01,
				0.25
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0.4,
			r = 3000,
			acc = {
				0.05,
				0.35
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	tweak_data.character.presets.weapon.deathwish.is_smg.aim_delay = {
		0.1,
		0.2
	}
	tweak_data.character.presets.weapon.deathwish.is_smg.focus_delay = 2
	tweak_data.character.presets.weapon.deathwish.is_smg.RELOAD_SPEED = 1.2
	tweak_data.character.presets.weapon.deathwish.is_smg.FALLOFF = {
		{
			dmg_mul = 1.25,
			r = 100,
			acc = {
				0.4,
				0.95
			},
			recoil = {
				0.1,
				0.25
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 1.25,
			r = 500,
			acc = {
				0.4,
				0.9
			},
			recoil = {
				0.1,
				0.3
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 1,
			r = 1000,
			acc = {
				0.3,
				0.4
			},
			recoil = {
				0.35,
				0.7
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 1,
			r = 2000,
			acc = {
				0.2,
				0.35
			},
			recoil = {
				0.35,
				0.8
			},
			mode = {
				0,
				3,
				3,
				0
			}
		},
		{
			dmg_mul = 0.5,
			r = 3000,
			acc = {
				0.1,
				0.35
			},
			recoil = {
				0.5,
				1.5
			},
			mode = {
				1,
				3,
				2,
				0
			}
		}
	}
	tweak_data.character.tank.weapon.is_shotgun_mag = {
		aim_delay = {
			0.1,
			0.1
		},
		focus_delay = 4,
		focus_dis = 200,
		spread = 20,
		miss_dis = 40,
		RELOAD_SPEED = 0.5,
		melee_speed = 1,
		melee_dmg = 25,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 2000,
			far = 5000,
			close = 1000
		},
		autofire_rounds = {
			5,
			7
		},
		FALLOFF = {
			{
				dmg_mul = 7,
				r = 100,
				acc = {
					0.4,
					0.7
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 4,
				r = 500,
				acc = {
					0.4,
					0.6
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 4,
				r = 1000,
				acc = {
					0.4,
					0.6
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					1,
					2,
					2,
					1
				}
			},
			{
				dmg_mul = 1,
				r = 2000,
				acc = {
					0.2,
					0.4
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					3,
					2,
					2,
					0
				}
			},
			{
				dmg_mul = 0.5,
				r = 3000,
				acc = {
					0.1,
					0.2
				},
				recoil = {
					1,
					1.2
				},
				mode = {
					3,
					1,
					1,
					0
				}
			}
		}
	}
	tweak_data.character.tank.weapon.is_rifle = {
		aim_delay = {
			0.1,
			0.2
		},
		focus_delay = 4,
		focus_dis = 800,
		spread = 20,
		miss_dis = 40,
		RELOAD_SPEED = 0.5,
		melee_speed = 1,
		melee_dmg = 25,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 2500,
			far = 5000,
			close = 1000
		},
		autofire_rounds = {
			40,
			80
		},
		FALLOFF = {
			{
				dmg_mul = 3,
				r = 100,
				acc = {
					0.1,
					0.2
				},
				recoil = {
					1,
					1.5
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 3,
				r = 500,
				acc = {
					0.1,
					0.2
				},
				recoil = {
					1,
					1.5
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 2,
				r = 1000,
				acc = {
					0.08,
					0.12
				},
				recoil = {
					1,
					1.5
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 1,
				r = 2000,
				acc = {
					0.06,
					0.08
				},
				recoil = {
					1.5,
					2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 0.5,
				r = 3000,
				acc = {
					0.04,
					0.06
				},
				recoil = {
					2,
					2.5
				},
				mode = {
					0,
					0,
					0,
					1
				}
			}
		}
	}

	tweak_data.character:_process_weapon_usage_table()
end

function VRArcadeTweakData:init_group_ai_tweak_data(tweak_data)
	if self.disable_flashbangs then
		for key, tactics in pairs(tweak_data.group_ai._tactics) do
			for i = #tactics, 1, -1 do
				if tactics[i] == "flash_grenade" then
					table.remove(tactics, i)
				end
			end
		end
	end

	local group_ai = tweak_data.group_ai
	group_ai.difficulty_curve_points = {
		0.25,
		0.5,
		0.75
	}
	group_ai.besiege.regroup.duration = {
		15,
		15,
		15,
		15,
		15
	}
	group_ai.besiege.assault.anticipation_duration = {
		{
			30,
			1
		},
		{
			30,
			1
		},
		{
			45,
			0.5
		},
		{
			45,
			0.5
		},
		{
			45,
			0.5
		}
	}
	group_ai.besiege.assault.sustain_duration_min = {
		40,
		120,
		160,
		160,
		160
	}
	group_ai.besiege.assault.sustain_duration_max = {
		40,
		120,
		160,
		160,
		160
	}
	group_ai.besiege.assault.delay = {
		20,
		20,
		15,
		10,
		10
	}
	group_ai.besiege.assault.hostage_hesitation_delay = {
		30,
		30,
		30,
		30,
		30
	}
	group_ai.besiege.assault.force = {
		40,
		40,
		40,
		40,
		40
	}
	group_ai.besiege.assault.force_pool = {
		120,
		120,
		160,
		160,
		200
	}
	group_ai.besiege.assault.force_balance_mul = {
		0.45,
		0.65,
		0.8,
		1
	}
	group_ai.besiege.assault.force_pool_balance_mul = {
		0.6,
		0.8,
		1,
		1.2
	}
	group_ai.smoke_and_flash_grenade_timeout = {
		60,
		80
	}
	group_ai.besiege.recon.groups.single_spooc = {
		0,
		0,
		0,
		0,
		0
	}
	group_ai.besiege.recon.groups.Phalanx = {
		0,
		0,
		0,
		0,
		0
	}
	group_ai.besiege.cloaker.groups = {
		single_spooc = {
			0,
			0,
			0,
			0,
			0
		}
	}
	group_ai.besiege.assault.groups = {
		tac_swat_shotgun_rush = {
			1,
			0.2,
			0,
			0,
			0
		},
		tac_swat_shotgun_flank = {
			0.2,
			0.8,
			0.3,
			0.05,
			0.05
		},
		tac_swat_rifle = {
			0,
			0.2,
			0.5,
			0.1,
			0.05
		},
		tac_swat_rifle_flank = {
			0,
			0,
			0.3,
			0.8,
			0.8
		},
		tac_shield_wall_ranged = {
			0,
			0,
			0.1,
			0.4,
			0.4
		},
		tac_shield_wall_charge = {
			0,
			0,
			0,
			0,
			0.5
		},
		FBI_spoocs = {
			0,
			0.4,
			0.6,
			0.4,
			0
		}
	}
	group_ai.besiege.reenforce.groups = {
		tac_bull_rush = {
			1,
			1,
			1,
			0,
			0
		},
		tac_shield_wall = {
			0,
			0,
			1,
			1,
			1
		}
	}
	group_ai.besiege.reenforce.interval = {
		10,
		20,
		30,
		30,
		30
	}
	group_ai.besiege.recon.groups = {
		tac_tazer_flanking = {
			1,
			1,
			0.7,
			0.4,
			0.2
		},
		tac_tazer_charge = {
			0,
			0,
			0.3,
			0.6,
			0.8
		}
	}
	group_ai.besiege.recon.interval = {
		5,
		5,
		5,
		5,
		5
	}
	group_ai.besiege.recon.force = {
		2,
		4,
		6,
		6,
		8
	}
	group_ai._tactics.CS_cop = {
		"provide_coverfire",
		"provide_support",
		"ranged_fire"
	}
	group_ai._tactics.CS_cop_stealth = {
		"flank",
		"provide_coverfire",
		"provide_support"
	}
	group_ai._tactics.CS_swat_rifle = {
		"smoke_grenade",
		"charge",
		"provide_coverfire",
		"provide_support",
		"ranged_fire"
	}
	group_ai._tactics.CS_swat_shotgun = {
		"smoke_grenade",
		"charge",
		"provide_coverfire",
		"provide_support",
		"shield_cover"
	}
	group_ai._tactics.CS_swat_rifle_flank = {
		"flank",
		"smoke_grenade",
		"charge",
		"provide_coverfire",
		"provide_support"
	}
	group_ai._tactics.FBI_swat_rifle = {
		"smoke_grenade",
		"provide_coverfire",
		"charge",
		"provide_support",
		"ranged_fire"
	}
	group_ai._tactics.FBI_swat_shotgun = {
		"smoke_grenade",
		"charge",
		"provide_coverfire",
		"provide_support"
	}
	group_ai._tactics.FBI_swat_rifle_flank = {
		"flank",
		"smoke_grenade",
		"charge",
		"provide_coverfire",
		"provide_support"
	}
	group_ai._tactics.FBI_suit = {
		"flank",
		"ranged_fire"
	}
	group_ai._tactics.FBI_suit_stealth = {
		"provide_coverfire",
		"provide_support",
		"flank"
	}
	group_ai.unit_categories.CITY_swat_m4 = {
		unit_types = {
			america = {
				Idstring("units/payday2/characters/ene_city_swat_1/ene_city_swat_1")
			}
		},
		access = {
			acrobatic = true,
			walk = true
		}
	}
	group_ai.unit_categories.CITY_swat_shotgun = {
		unit_types = {
			america = {
				Idstring("units/payday2/characters/ene_city_swat_2/ene_city_swat_2")
			}
		},
		access = {
			acrobatic = true,
			walk = true
		}
	}
	group_ai.unit_categories.CITY_swat_smg = {
		unit_types = {
			america = {
				Idstring("units/payday2/characters/ene_city_swat_3/ene_city_swat_3")
			}
		},
		access = {
			acrobatic = true,
			walk = true
		}
	}
	group_ai.enemy_spawn_groups = group_ai.enemy_spawn_groups or {}
	group_ai.enemy_spawn_groups.tac_swat_shotgun_rush = {
		amount = {
			3,
			4
		},
		spawn = {
			{
				freq = 1,
				amount_min = 1,
				rank = 1,
				unit = "CS_cop_C45_R870",
				tactics = group_ai._tactics.CS_cop
			},
			{
				unit = "CS_cop_stealth_MP5",
				freq = 0.25,
				rank = 2,
				tactics = group_ai._tactics.CS_cop_stealth
			}
		}
	}
	group_ai.enemy_spawn_groups.tac_swat_shotgun_flank = {
		amount = {
			3,
			4
		},
		spawn = {
			{
				unit = "CS_swat_MP5",
				freq = 0.33,
				rank = 3,
				tactics = group_ai._tactics.CS_swat_rifle_flank
			},
			{
				unit = "CS_swat_MP5",
				freq = 1,
				rank = 2,
				tactics = group_ai._tactics.CS_swat_rifle
			},
			{
				rank = 1,
				freq = 0.5,
				amount_max = 2,
				unit = "CS_swat_R870",
				tactics = group_ai._tactics.CS_swat_shotgun
			}
		}
	}
	group_ai.enemy_spawn_groups.tac_swat_rifle = {
		amount = {
			3,
			4
		},
		spawn = {
			{
				unit = "CS_heavy_M4",
				freq = 1,
				rank = 2,
				tactics = group_ai._tactics.CS_swat_rifle
			},
			{
				unit = "CS_heavy_M4",
				freq = 0.35,
				rank = 3,
				tactics = group_ai._tactics.CS_swat_rifle_flank
			},
			{
				rank = 2,
				freq = 0.5,
				amount_max = 2,
				unit = "CS_heavy_R870",
				tactics = group_ai._tactics.CS_swat_shotgun
			}
		}
	}
	group_ai.enemy_spawn_groups.tac_swat_rifle_flank = {
		amount = {
			3,
			4
		},
		spawn = {
			{
				freq = 1,
				amount_min = 1,
				rank = 2,
				unit = "FBI_swat_M4",
				tactics = group_ai._tactics.FBI_swat_rifle
			},
			{
				unit = "FBI_swat_M4",
				freq = 0.75,
				rank = 3,
				tactics = group_ai._tactics.FBI_swat_rifle_flank
			},
			{
				rank = 1,
				freq = 0.5,
				amount_max = 2,
				unit = "FBI_swat_R870",
				tactics = group_ai._tactics.FBI_swat_shotgun
			}
		}
	}
	group_ai.enemy_spawn_groups.tac_shield_wall_ranged = {
		amount = {
			2,
			3
		},
		spawn = {
			{
				freq = 1,
				amount_min = 1,
				rank = 1,
				unit = "FBI_heavy_G36",
				tactics = group_ai._tactics.FBI_swat_rifle
			},
			{
				unit = "FBI_heavy_G36",
				freq = 0.65,
				rank = 2,
				tactics = group_ai._tactics.FBI_swat_rifle_flank
			},
			{
				rank = 3,
				freq = 0.8,
				amount_max = 1,
				unit = "FBI_suit_M4_MP5",
				tactics = group_ai._tactics.FBI_swat_rifle_flank
			}
		}
	}
	group_ai.enemy_spawn_groups.tac_shield_wall_charge = {
		amount = {
			3,
			4
		},
		spawn = {
			{
				unit = "CITY_swat_m4",
				freq = 1,
				rank = 1,
				tactics = group_ai._tactics.FBI_swat_rifle
			},
			{
				unit = "CITY_swat_smg",
				freq = 0.5,
				rank = 1,
				tactics = group_ai._tactics.FBI_swat_rifle
			},
			{
				unit = "CITY_swat_m4",
				freq = 0.65,
				rank = 2,
				tactics = group_ai._tactics.FBI_swat_rifle_flank
			},
			{
				rank = 3,
				freq = 0.25,
				amount_max = 1,
				unit = "CITY_swat_shotgun",
				tactics = group_ai._tactics.FBI_swat_shotgun
			}
		}
	}
	group_ai.enemy_spawn_groups.tac_tazer_flanking = {
		amount = {
			2,
			3
		},
		spawn = {
			{
				freq = 1,
				amount_min = 1,
				rank = 1,
				unit = "CS_cop_stealth_MP5",
				tactics = group_ai._tactics.FBI_suit_stealth
			}
		}
	}
	group_ai.enemy_spawn_groups.tac_tazer_charge = {
		amount = {
			2,
			3
		},
		spawn = {
			{
				unit = "FBI_suit_C45_M4",
				freq = 1,
				rank = 1,
				tactics = group_ai._tactics.FBI_suit_stealth
			},
			{
				freq = 1,
				amount_min = 1,
				rank = 1,
				unit = "FBI_suit_stealth_MP5",
				tactics = group_ai._tactics.FBI_suit_stealth
			},
			{
				unit = "FBI_suit_M4_MP5",
				freq = 0.75,
				rank = 2,
				tactics = group_ai._tactics.FBI_suit
			}
		}
	}
	group_ai.enemy_spawn_groups.tac_shield_wall = {
		amount = {
			3,
			3
		},
		spawn = {
			{
				freq = 1,
				amount_min = 1,
				rank = 2,
				unit = "FBI_suit_C45_M4",
				tactics = group_ai._tactics.FBI_suit
			},
			{
				unit = "CS_cop_C45_R870",
				freq = 0.8,
				rank = 1,
				tactics = group_ai._tactics.FBI_suit
			},
			{
				unit = "FBI_swat_M4",
				freq = 0.4,
				rank = 1,
				tactics = group_ai._tactics.FBI_suit
			},
			{
				unit = "FBI_heavy_G36",
				freq = 0.4,
				rank = 1,
				tactics = group_ai._tactics.FBI_suit
			}
		}
	}
	group_ai.enemy_spawn_groups.tac_bull_rush = {
		amount = {
			3,
			4
		},
		spawn = {
			{
				freq = 1,
				amount_min = 1,
				rank = 1,
				unit = "CS_cop_C45_R870",
				tactics = group_ai._tactics.CS_cop
			},
			{
				unit = "CS_swat_MP5",
				freq = 0.7,
				rank = 1,
				tactics = group_ai._tactics.CS_cop
			},
			{
				unit = "CS_heavy_M4",
				freq = 0.7,
				rank = 1,
				tactics = group_ai._tactics.CS_cop
			}
		}
	}
	group_ai.enemy_spawn_groups.FBI_spoocs = {
		amount = {
			3,
			4
		},
		spawn = {
			{
				unit = "FBI_swat_M4",
				freq = 1,
				rank = 2,
				tactics = group_ai._tactics.FBI_swat_rifle
			},
			{
				unit = "FBI_swat_M4",
				freq = 0.7,
				rank = 3,
				tactics = group_ai._tactics.FBI_swat_rifle_flank
			},
			{
				unit = "CS_heavy_M4",
				freq = 1.2,
				rank = 2,
				tactics = group_ai._tactics.CS_swat_rifle
			},
			{
				unit = "FBI_suit_C45_M4",
				freq = 1.4,
				rank = 1,
				tactics = group_ai._tactics.FBI_suit
			},
			{
				unit = "FBI_suit_stealth_MP5",
				freq = 1.4,
				rank = 1,
				tactics = group_ai._tactics.FBI_suit_stealth
			}
		}
	}
end

function VRArcadeTweakData:init_scoring(tweak_data)
	self.score_multipliers = {
		bag = 20000,
		small_loot = 500,
		kill = 10,
		hostages_remaining = 3000,
		downed = -2500,
		no_downs_bonus = 10000
	}
	self.cash_multipliers = {
		bag = 20000,
		small_loot = 500
	}
end

function VRArcadeTweakData:init_interaction_tweak_data(tweak_data)
	tweak_data.interaction.intimidate.equipment_consume = false
	local timer_exclude = {
		hold_choose_handedness = true
	}

	for name, data in pairs(tweak_data.interaction) do
		if not timer_exclude[name] and type(data) == "table" and data.timer then
			data.timer = 0
		end
	end
end

function VRArcadeTweakData:set_difficulty(tweak_data, difficulty)
	tweak_data.character.presets.gang_member_damage.HEALTH_INIT = 1000
	tweak_data.character.presets.gang_member_damage.REGENERATE_TIME = 2
	tweak_data.character.presets.gang_member_damage.REGENERATE_TIME_AWAY = 2
	tweak_data.character.presets.weapon.expert.is_rifle.aim_delay = {
		0.5,
		1.4
	}
	tweak_data.character.presets.weapon.expert.is_rifle.focus_delay = 3
	tweak_data.character.presets.weapon.expert.is_rifle.focus_dis = 500
	tweak_data.character.presets.weapon.expert.is_rifle.spread = 30
	tweak_data.character.presets.weapon.expert.is_rifle.miss_dis = 40
	tweak_data.character.presets.weapon.expert.is_rifle.RELOAD_SPEED = 0.7
	tweak_data.character.presets.weapon.gang_member.is_rifle.FALLOFF = {
		{
			dmg_mul = 0.3,
			r = 100,
			acc = {
				0.2,
				0.33
			},
			recoil = {
				0.4,
				0.6
			},
			mode = {
				0,
				0,
				0.2,
				0.8
			}
		},
		{
			dmg_mul = 0.21,
			r = 500,
			acc = {
				0.16,
				0.28
			},
			recoil = {
				0.5,
				0.7
			},
			mode = {
				0,
				0,
				0.3,
				0.7
			}
		},
		{
			dmg_mul = 0.15,
			r = 1000,
			acc = {
				0.1,
				0.25
			},
			recoil = {
				0.9,
				1.4
			},
			mode = {
				0,
				0.3,
				0.4,
				0.3
			}
		},
		{
			dmg_mul = 0.09,
			r = 2000,
			acc = {
				0.1,
				0.2
			},
			recoil = {
				1.1,
				1.5
			},
			mode = {
				0.2,
				0.4,
				0.3,
				0.1
			}
		},
		{
			dmg_mul = 0.03,
			r = 3000,
			acc = {
				0.01,
				0.2
			},
			recoil = {
				1.4,
				2.4
			},
			mode = {
				0.4,
				0.4,
				0.2,
				0
			}
		}
	}

	for _, char in ipairs(tweak_data.criminals.characters) do
		tweak_data.character[char.name].damage = tweak_data.character.presets.gang_member_damage
		tweak_data.character[char.name].weapon = deep_clone(tweak_data.character.presets.weapon.gang_member)
		tweak_data.character[char.name].weapon.weapons_of_choice = {
			primary = "wpn_fps_ass_74_npc",
			secondary = Idstring("units/payday2/weapons/wpn_npc_beretta92/wpn_npc_beretta92")
		}
	end
end
