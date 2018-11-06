UpgradesVisualTweakData = UpgradesVisualTweakData or class()

function UpgradesVisualTweakData:init()
	self.upgrade = {
		c45 = {
			base = true,
			fire_obj = "fire",
			objs = {
				g_extension1 = false,
				g_extension = false
			}
		},
		c45_mag1 = nil,
		c45_mag2 = nil,
		c45_recoil1 = {
			fire_obj = "fire_2",
			objs = {
				g_extension1 = false,
				g_extension = true
			}
		},
		c45_recoil2 = nil,
		c45_recoil3 = {
			fire_obj = "fire_2",
			objs = {
				g_extension1 = true,
				g_extension = false
			}
		},
		c45_recoil4 = nil,
		c45_damage1 = nil,
		c45_damage2 = nil,
		c45_damage3 = nil,
		c45_damage4 = nil,
		beretta92 = {
			base = true,
			fire_obj = "fire",
			objs = {
				g_silencer = true,
				g_silencer_2 = false
			}
		},
		beretta_mag1 = nil,
		beretta_mag2 = nil,
		beretta_recoil1 = nil,
		beretta_recoil2 = nil,
		beretta_recoil3 = {
			fire_obj = "fire_2",
			objs = {
				g_silencer = false,
				g_silencer_2 = true
			}
		},
		beretta_recoil4 = nil,
		beretta_spread1 = nil,
		beretta_spread2 = nil,
		raging_bull = {
			base = true,
			fire_obj = "fire",
			objs = {
				g_shell_2_dumdum = false,
				g_shell_4_dumdum = false,
				g_6_bullets_dumdum = false,
				g_shell_3 = true,
				g_shell_5 = true,
				g_6_bullets_dumdum_not_empty = false,
				g_shell_1_dumdum = false,
				g_muzzle_2 = false,
				g_sight = false,
				g_6_bullets_not_empty = true,
				g_shell_5_dumdum = false,
				g_shell_2 = true,
				g_shell_6_dumdum = false,
				g_muzzle_1 = true,
				g_shell_3_dumdum = false,
				g_6_bullets = true,
				g_sight_short = true,
				g_shell_6 = true,
				g_shell_1 = true,
				g_shell_4 = true
			}
		},
		raging_bull_spread1 = {
			fire_obj = "fire_2",
			objs = {
				g_muzzle_1 = false,
				g_sight_short = false,
				g_muzzle_2 = true,
				g_sight = true
			}
		},
		raging_bull_spread2 = nil,
		raging_bull_spread3 = nil,
		raging_bull_spread4 = nil,
		raging_bull_reload_speed1 = nil,
		raging_bull_reload_speed2 = nil,
		raging_bull_damage1 = nil,
		raging_bull_damage2 = nil,
		raging_bull_damage3 = {
			objs = {
				g_shell_2_dumdum = true,
				g_shell_3 = false,
				g_shell_5 = false,
				g_6_bullets = false,
				g_6_bullets_dumdum = true,
				g_6_bullets_not_empty = false,
				g_shell_1_dumdum = true,
				g_shell_3_dumdum = true,
				g_shell_6 = false,
				g_shell_4_dumdum = true,
				g_shell_1 = false,
				g_shell_5_dumdum = true,
				g_shell_4 = false,
				g_shell_2 = false,
				g_6_bullets_dumdum_not_empty = true,
				g_shell_6_dumdum = true
			}
		},
		raging_bull_damage4 = nil,
		m4 = {
			base = true,
			fire_obj = "fire",
			objs = {
				g_reddot = false,
				g_nozzle_2 = false,
				g_front_steelsight = true,
				g_sight = false,
				g_handle_sight = true,
				g_gfx_lens = false,
				g_front_steelsight_down = true,
				g_nozzle_1 = true,
				g_sight_il = true
			}
		},
		m4_mag1 = nil,
		m4_mag2 = nil,
		m4_spread1 = nil,
		m4_spread2 = {
			fire_obj = "fire_nozzle_2",
			objs = {
				g_nozzle_2 = true,
				g_nozzle_1 = false
			}
		},
		m4_spread3 = nil,
		m4_spread4 = {
			objs = {
				g_front_steelsight_down = true,
				g_gfx_lens = true,
				g_front_steelsight = false,
				g_reddot = true,
				g_sight = true,
				g_handle_sight = false,
				g_sight_il = false
			}
		},
		m4_damage1 = nil,
		m4_damage2 = nil,
		m14 = {
			base = true,
			objs = {
				g_reddot = false,
				g_iron_sight_2 = false,
				g_sight_lens = false,
				g_sight = false,
				g_iron_sight_1 = true
			}
		},
		m14_mag1 = nil,
		m14_mag2 = nil,
		m14_spread1 = {
			objs = {
				g_reddot = false,
				g_iron_sight_2 = false,
				g_sight_lens = true,
				g_sight = true,
				g_iron_sight_1 = true
			}
		},
		m14_spread2 = {
			objs = {
				g_reddot = true,
				g_iron_sight_2 = true,
				g_sight_lens = true,
				g_sight = true,
				g_iron_sight_1 = false
			}
		},
		m14_damage1 = nil,
		m14_damage2 = nil,
		m14_recoil1 = nil,
		m14_recoil2 = nil,
		m14_recoil3 = nil,
		m14_recoil4 = nil,
		mp5 = {
			base = true,
			objs = {
				g_mag_straight = false,
				g_mag = true,
				g_standard_grip = true,
				g_double = false,
				g_standard_grip_not = false
			}
		},
		mp5_spread1 = nil,
		mp5_spread2 = {
			objs = {
				g_standard_grip = false,
				g_standard_grip_not = true
			}
		},
		mp5_recoil1 = nil,
		mp5_recoil2 = nil,
		mp5_reload_speed1 = {
			objs = {
				g_mag_straight = true,
				g_mag = false,
				g_double = false
			}
		},
		mp5_reload_speed2 = nil,
		mp5_reload_speed3 = {
			objs = {
				g_mag_straight = false,
				g_mag = false,
				g_double = true
			}
		},
		mp5_reload_speed4 = nil,
		mp5_enter_steelsight_speed1 = nil,
		mp5_enter_steelsight_speed2 = nil,
		mac11 = {
			base = true,
			objs = {
				g_silencer_big = true,
				g_mag = true,
				g_silencer_bigger = false,
				g_mag_extended = false
			}
		},
		mac11_recoil1 = nil,
		mac11_recoil2 = nil,
		mac11_recoil3 = nil,
		mac11_recoil4 = {
			objs = {
				g_silencer_big = false,
				g_silencer_bigger = true
			}
		},
		mac11_enter_steelsight_speed1 = nil,
		mac11_enter_steelsight_speed2 = nil,
		mac11_mag1 = {
			objs = {
				g_mag_extended = true,
				g_mag = false
			}
		},
		mac11_mag2 = nil,
		mac11_mag3 = nil,
		mac11_mag4 = nil,
		r870_shotgun = {
			base = true,
			objs = {
				g_kylflans = false,
				g_rail = true,
				g_extender = false
			}
		},
		remington_mag1 = {
			objs = {
				g_extender = true
			}
		},
		remington_mag2 = nil,
		remington_recoil1 = nil,
		remington_recoil2 = nil,
		remington_recoil3 = nil,
		remington_recoil4 = {
			objs = {
				g_rail = false,
				g_kylflans = true
			}
		},
		remington_damage1 = nil,
		remington_damage2 = nil,
		remington_damage3 = nil,
		remington_damage4 = nil,
		mossberg = {
			base = true,
			objs = {
				g_reload_pipe_2 = false,
				g_reload_pipe = true,
				g_shell_extension = false,
				g_pump_1 = true,
				g_pump_2 = false
			}
		},
		mossberg_mag1 = nil,
		mossberg_mag2 = {
			objs = {
				g_shell_extension = true
			}
		},
		mossberg_reload_speed1 = nil,
		mossberg_reload_speed2 = nil,
		mossberg_fire_rate_multiplier1 = nil,
		mossberg_fire_rate_multiplier2 = {
			objs = {
				g_reload_pipe_2 = true,
				g_reload_pipe = false
			}
		},
		mossberg_fire_rate_multiplier3 = nil,
		mossberg_fire_rate_multiplier4 = {
			objs = {
				g_pump_2 = true,
				g_pump_1 = false
			}
		},
		mossberg_recoil_multiplier1 = nil,
		mossberg_recoil_multiplier2 = nil,
		hk21 = {
			base = true,
			objs = {
				g_mag_plast = false,
				g_mag = false,
				g_l_bipod = false,
				g_sight = false,
				g_r_bipod = false,
				g_mag_rund = true,
				g_reddot = false,
				g_lens = false,
				g_sight_iron = true
			}
		},
		hk21_mag1 = nil,
		hk21_mag2 = nil,
		hk21_mag3 = nil,
		hk21_mag4 = {
			objs = {
				g_mag_rund = false,
				g_mag = true,
				g_mag_plast = true
			}
		},
		hk21_recoil1 = {
			objs = {
				g_r_bipod = true,
				g_l_bipod = true
			}
		},
		hk21_recoil2 = {
			objs = {
				g_sight = true,
				g_reddot = true,
				g_lens = true,
				g_sight_iron = false
			}
		},
		hk21_damage1 = nil,
		hk21_damage2 = nil,
		hk21_damage3 = nil,
		hk21_damage4 = nil,
		ak47 = {
			base = true,
			objs = {
				g_il_steelsight = true,
				g_steelsight = true,
				g_plastic = false,
				g_dot_sight = false,
				g_dot = false,
				g_lens = false,
				g_wood = true
			}
		},
		ak47_damage1 = nil,
		ak47_damage2 = nil,
		ak47_damage3 = nil,
		ak47_damage4 = nil,
		ak47_mag1 = nil,
		ak47_mag2 = nil,
		ak47_recoil1 = nil,
		ak47_recoil2 = nil,
		ak47_recoil3 = {
			objs = {
				g_plastic = true,
				g_wood = false
			}
		},
		ak47_recoil4 = nil,
		ak47_spread1 = {
			objs = {
				g_il_steelsight = false,
				g_dot_sight = true,
				g_steelsight = false,
				g_dot = true,
				g_lens = true
			}
		},
		ak47_spread2 = nil,
		glock = {
			base = true,
			objs = {
				g_mag_long = false,
				g_mag = true
			}
		},
		glock_damage1 = nil,
		glock_damage2 = nil,
		glock_mag1 = {
			objs = {
				g_mag_long = true,
				g_mag = false
			}
		},
		glock_mag2 = nil,
		glock_mag3 = nil,
		glock_mag4 = nil,
		glock_recoil1 = nil,
		glock_recoil2 = nil,
		glock_reload_speed1 = nil,
		glock_reload_speed2 = nil,
		m79 = {
			base = true,
			objs = {
				g_grenade = true,
				g_grenade_high_explosive = false,
				g_sight = false
			}
		},
		m79_clip_num1 = nil,
		m79_clip_num2 = nil,
		m79_damage1 = nil,
		m79_damage2 = nil,
		m79_damage3 = nil,
		m79_damage4 = {
			objs = {
				g_grenade = false,
				g_grenade_high_explosive = true
			}
		},
		m79_expl_range1 = nil,
		m79_expl_range2 = {
			objs = {
				g_sight = true
			}
		}
	}
end
