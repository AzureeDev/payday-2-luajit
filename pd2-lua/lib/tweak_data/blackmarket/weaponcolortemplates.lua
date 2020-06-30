WeaponColorTemplates = WeaponColorTemplates or class()

function WeaponColorTemplates.setup_weapon_color_templates(tweak_data)
	local weapon_color_templates = {
		color_variation = WeaponColorTemplates._setup_color_variation_template(tweak_data),
		color_skin = WeaponColorTemplates._setup_color_skin_template(tweak_data)
	}

	return weapon_color_templates
end

function WeaponColorTemplates._setup_color_variation_template(tweak_data)
	local weapon_color_variation_template = {
		{
			base_foregrip = "base_metal",
			base_vertical_grip = "base_variation",
			base_stock = "base_variation",
			base_sights = "base_variation",
			gradient_default = "gradient_default",
			base_magazine = "base_variation",
			pattern_default = "pattern_default",
			base_default = "base_default",
			base_gadget = "base_variation",
			base_grip = "base_variation"
		},
		{
			base_barrel_ext = "base_variation",
			base_barrel = "base_variation",
			base_sights = "base_variation",
			base_slide = "base_variation",
			gradient_default = "gradient_default",
			base_magazine = "base_variation",
			pattern_default = "pattern_default",
			base_default = "base_default",
			base_gadget = "base_variation",
			base_grip = "base_variation"
		},
		{
			base_sights = "base_variation",
			gradient_default = "gradient_default",
			pattern_default = "pattern_default",
			base_default = "base_metal",
			base_gadget = "base_variation",
			base_magazine = "base_variation"
		},
		{
			base_sights = "base_variation",
			gradient_default = "gradient_default",
			pattern_default = "pattern_default",
			base_default = "base_plastic",
			base_gadget = "base_variation",
			base_magazine = "base_variation"
		},
		{
			base_sights = "base_variation",
			gradient_default = "gradient_default",
			pattern_default = "pattern_default",
			base_default = "base_half",
			base_gadget = "base_variation",
			base_magazine = "base_variation"
		},
		{
			base_sights = "base_variation",
			base_barrel_ext = "base_variation",
			pattern_default = "pattern_default",
			base_default = "base_half_02",
			gradient_default = "gradient_default",
			base_gadget = "base_variation",
			base_magazine = "base_variation"
		},
		{
			base_default = "base_variation",
			base_barrel = "base_default",
			base_grip = "base_default",
			base_sights = "base_default",
			base_slide = "base_default",
			gradient_default = "gradient_default",
			base_magazine = "base_default",
			pattern_default = "pattern_default",
			base_barrel_ext = "base_default",
			base_gadget = "base_default",
			base_stock = "base_default"
		},
		{
			base_sights = "base_metal",
			gradient_default = "gradient_default",
			pattern_default = "pattern_default",
			base_default = "base_default",
			base_gadget = "base_plastic",
			base_magazine = "base_plastic"
		},
		{
			pattern_default = "pattern_default",
			gradient_default = "gradient_default",
			base_grip = "base_plastic",
			base_default = "base_detail"
		},
		{
			gradient_default = "gradient_default",
			pattern_default = "pattern_default",
			base_default = "base_default"
		}
	}

	return weapon_color_variation_template
end

function WeaponColorTemplates._setup_color_skin_template(tweak_data)
	local weapon_color_skin_template = {
		base_gradient = "base_default",
		weapons = {},
		types = {},
		parts = {}
	}
	local types = weapon_color_skin_template.types
	types.sight = {
		base_gradient = "base_sights"
	}
	types.magazine = {
		base_gradient = "base_magazine"
	}
	types.grip = {
		base_gradient = "base_grip"
	}
	types.foregrip = {
		base_gradient = "base_foregrip"
	}
	types.vertical_grip = {
		base_gradient = "base_vertical_grip"
	}
	types.stock = {
		base_gradient = "base_stock"
	}
	types.gadget = {
		base_gradient = "base_gadget"
	}
	types.barrel = {
		base_gradient = "base_barrel"
	}
	types.barrel_ext = {
		base_gradient = "base_barrel_ext"
	}
	types.slide = {
		base_gradient = "base_slide"
	}
	weapon_color_skin_template.pattern = "pattern_default"
	weapon_color_skin_template.pattern_gradient = "gradient_default"
	types.sight.pattern = "pattern_sights"
	types.sight.pattern_gradient = "gradient_sights"
	types.magazine.pattern = "pattern_magazine"
	types.magazine.pattern_gradient = "gradient_magazine"
	types.grip.pattern = "pattern_grip"
	types.grip.pattern_gradient = "gradient_grip"
	types.foregrip.pattern = "pattern_foregrip"
	types.foregrip.pattern_gradient = "gradient_foregrip"
	types.vertical_grip.pattern = "pattern_vertical_grip"
	types.vertical_grip.pattern_gradient = "gradient_vertical_grip"
	types.stock.pattern = "pattern_stock"
	types.stock.pattern_gradient = "gradient_stock"
	types.gadget.pattern = "pattern_gadget"
	types.gadget.pattern_gradient = "gradient_gadget"
	types.barrel.pattern = "pattern_barrel"
	types.barrel.pattern_gradient = "gradient_barrel"
	types.barrel_ext.pattern = "pattern_barrel_ext"
	types.barrel_ext.pattern_gradient = "gradient_barrel_ext"
	types.slide.pattern = "pattern_slide"
	types.slide.pattern_gradient = "gradient_slide"
	weapon_color_skin_template.weapons = WeaponColorTemplates._setup_color_skin_weapons(tweak_data)
	weapon_color_skin_template.parts = WeaponColorTemplates._setup_color_skin_parts(tweak_data)

	return weapon_color_skin_template
end

function WeaponColorTemplates._setup_color_skin_parts(tweak_data)
	local parts = {}

	return parts
end

function WeaponColorTemplates._setup_akimbo_weapons(tweak_data, weapons)
	for weapon_id, akimbo_id in pairs(tweak_data.weapon_akimbo_mappings) do
		weapons[akimbo_id] = weapons[weapon_id]
	end
end

function WeaponColorTemplates._setup_color_skin_weapons(tweak_data)
	local weapons = {}

	for weapon, data in pairs(tweak_data.weapon) do
		if data.autohit then
			weapons[weapon] = {}
		end
	end

	weapons.aa12.pattern_tweak = Vector3(1, 0, 0)
	weapons.ak5.pattern_tweak = Vector3(1, 0, 0)
	weapons.ak74.pattern_pos = Vector3(0, -0.28953, 0)
	weapons.ak74.pattern_tweak = Vector3(1.11138, 0, 0)
	weapons.akm.pattern_tweak = Vector3(1, 0, 0)
	weapons.akmsu.pattern_tweak = Vector3(1, 0, 0)
	weapons.amcar.pattern_tweak = Vector3(0.825187, 0, 0)
	weapons.arblast.pattern_tweak = Vector3(1, 0, 0)
	weapons.asval.pattern_tweak = Vector3(1, 0, 0)
	weapons.aug.pattern_tweak = Vector3(1.68376, 0, 0)
	weapons.b682.pattern_tweak = Vector3(1, 0, 0)
	weapons.b92fs.pattern_tweak = Vector3(1, 0, 0)
	weapons.baka.pattern_tweak = Vector3(1, 0, 0)
	weapons.benelli.pattern_tweak = Vector3(1.49297, 0, 1)
	weapons.benelli.pattern_tweak = Vector3(1, 0, 0)
	weapons.c96.pattern_tweak = Vector3(1, 0, 0)
	weapons.deagle.pattern_tweak = Vector3(1.34987, 0, 0)
	weapons.fal.pattern_tweak = Vector3(1, 0, 0)
	weapons.famas.pattern_tweak = Vector3(1.30217, 0, 0)
	weapons.flamethrower_mk2.pattern_tweak = Vector3(1, 0, 0)
	weapons.frankish.pattern_tweak = Vector3(1.49297, 0, 0)
	weapons.g22c.pattern_tweak = Vector3(1, 0, 0)
	weapons.g26.pattern_tweak = Vector3(1, 0, 0)
	weapons.g3.pattern_tweak = Vector3(1, 0, 0)
	weapons.g36.pattern_pos = Vector3(0, 0.511806, 0)
	weapons.g36.pattern_tweak = Vector3(1.11138, 0, 0)
	weapons.galil.pattern_tweak = Vector3(1.44527, 0, 0)
	weapons.gre_m79.pattern_pos = Vector3(0.244694, 0.120678, 0)
	weapons.gre_m79.pattern_tweak = Vector3(1, 0, 0)
	weapons.hk21.pattern_tweak = Vector3(1, 0, 0)
	weapons.hs2000.pattern_tweak = Vector3(1, 0, 0)
	weapons.hunter.pattern_tweak = Vector3(1, 0, 0)
	weapons.huntsman.pattern_tweak = Vector3(1.25447, 0, 0)
	weapons.huntsman.pattern_tweak = Vector3(1, 0, 0)
	weapons.jowi.pattern_tweak = Vector3(1, 0, 0)
	weapons.ksg.pattern_tweak = Vector3(1, 0, 0)
	weapons.l85a2.pattern_tweak = Vector3(1, 0, 0)
	weapons.long.pattern_tweak = Vector3(3.6394, 0, 0)
	weapons.m134.pattern_tweak = Vector3(2.30384, 0, 0)
	weapons.m16.pattern_tweak = Vector3(0.920584, 0, 0)
	weapons.m16.pattern_tweak = Vector3(1, 0, 0)
	weapons.m1928.pattern_tweak = Vector3(1, 0, 0)
	weapons.m249.pattern_tweak = Vector3(1.58836, 0, 0)
	weapons.m32.pattern_pos = Vector3(0, 0.206535, 0)
	weapons.m32.pattern_tweak = Vector3(2.39924, 0, 0)
	weapons.m45.pattern_pos = Vector3(0.196995, 0.712139, 0)
	weapons.m45.pattern_tweak = Vector3(1, 0, 0)
	weapons.m95.pattern_pos = Vector3(0.225614, 0.321011, 0)
	weapons.m95.pattern_tweak = Vector3(2.01765, 0, 0)
	weapons.mateba.pattern_tweak = Vector3(1, 0, 0)
	weapons.mg42.pattern_pos = Vector3(0, 0.292392, 0)
	weapons.mg42.pattern_tweak = Vector3(2.82853, 0, 0)
	weapons.model70.pattern_tweak = Vector3(1, 0, 0)
	weapons.mosin.pattern_tweak = Vector3(1, 0, 0)
	weapons.mp7.pattern_tweak = Vector3(1, 0, 0)
	weapons.mp9.pattern_tweak = Vector3(1, 0, 0)
	weapons.msr.pattern_tweak = Vector3(1, 0, 0)
	weapons.new_m14.pattern_pos = Vector3(-0.00333866, -0.0224181, 0)
	weapons.new_m14.pattern_tweak = Vector3(1.58836, 0, 0)
	weapons.new_m4.pattern_tweak = Vector3(1, 0, 0)
	weapons.new_mp5.pattern_tweak = Vector3(1, 0, 0)
	weapons.olympic.pattern_tweak = Vector3(0.634393, 0, 0)
	weapons.p226.pattern_tweak = Vector3(1, 0, 0)
	weapons.par.pattern_tweak = Vector3(5.83353, 0, 0)
	weapons.plainsrider.pattern_pos = Vector3(0.0443599, 0.349631, 0)
	weapons.plainsrider.pattern_tweak = Vector3(3.30551, 0, 0)
	weapons.ppk.pattern_tweak = Vector3(1, 0, 0)
	weapons.r870.pattern_tweak = Vector3(1, 0, 0)
	weapons.r93.pattern_tweak = Vector3(1, 0, 0)
	weapons.rpg7.pattern_pos = Vector3(0, 0.206535, 0)
	weapons.rpg7.pattern_tweak = Vector3(2.54233, 0, 0)
	weapons.rpk.pattern_tweak = Vector3(1, 0, 0)
	weapons.s552.pattern_tweak = Vector3(1, 0, 0)
	weapons.saiga.pattern_tweak = Vector3(1, 0, 0)
	weapons.saw.pattern_tweak = Vector3(2.87622, 0, 0)
	weapons.scar.pattern_tweak = Vector3(1, 0, 0)
	weapons.scorpion.pattern_tweak = Vector3(1, 0, 0)
	weapons.sparrow.pattern_tweak = Vector3(1, 0, 0)
	weapons.spas12.pattern_tweak = Vector3(1, 0, 0)
	weapons.sterling.pattern_pos = Vector3(-0.0319578, 0.69306, 0)
	weapons.sterling.pattern_tweak = Vector3(1.30217, 3.01647, 0)
	weapons.striker.pattern_tweak = Vector3(1.68376, 0, 1)
	weapons.sub2000.pattern_tweak = Vector3(1.77916, 0, 0)
	weapons.tec9.pattern_tweak = Vector3(1, 0, 0)
	weapons.usp.pattern_pos = Vector3(0.292392, 0, 0)
	weapons.usp.pattern_tweak = Vector3(1.63606, 0, 1)
	weapons.usp.pattern_tweak = Vector3(1, 0, 0)
	weapons.uzi.pattern_tweak = Vector3(1, 0, 0)
	weapons.vhs.pattern_tweak = Vector3(1, 0, 0)
	weapons.wa2000.pattern_tweak = Vector3(1.92225, 0, 0)
	weapons.winchester1874.pattern_pos = Vector3(-0.451705, 0.301932, 0)
	weapons.winchester1874.pattern_tweak = Vector3(1.30217, 0, 0)
	weapons.peacemaker.pattern_tweak = Vector3(1, 0, 0)
	weapons.peacemaker.uv_scale = Vector3(1, 1, 0.131887)
	weapons.x_judge.pattern_tweak = Vector3(1, 0, 0)
	weapons.mac10.pattern_tweak = Vector3(1.58836, 0, 1)
	weapons.mac10.pattern_tweak = Vector3(1, 0, 0)
	weapons.x_mac10.pattern_tweak = Vector3(1.63606, 0, 1)
	weapons.x_mac10.pattern_tweak = Vector3(1, 0, 0)
	weapons.new_raging_bull.pattern_pos = Vector3(0, 0.111138, 0)
	weapons.new_raging_bull.pattern_tweak = Vector3(0.968283, 0, 0)
	weapons.new_raging_bull.types = {
		slide = {
			pattern_pos = Vector3(0.254233, 1.27498, 0),
			pattern_tweak = Vector3(0.825187, 0, 1)
		}
	}
	weapons.glock_17.pattern_tweak = Vector3(1, 0, 0)
	weapons.x_g17.pattern_pos = Vector3(0, 0.282853, 0)
	weapons.x_g17.pattern_tweak = Vector3(0.682091, 0, 0)
	weapons.x_g17.types = {
		lower_reciever = {
			pattern_tweak = Vector3(1.01598, 0, 1)
		},
		magazine = {
			pattern_tweak = Vector3(0.682091, 0, 1),
			pattern_pos = Vector3(0.721679, 1.00787, 0)
		}
	}
	weapons.p90.pattern_tweak = Vector3(1.44527, 0, 1)
	weapons.p90.pattern_tweak = Vector3(1, 0, 0)
	weapons.x_p90.pattern_pos = Vector3(0.158836, 0.7026, 0)
	weapons.x_p90.pattern_tweak = Vector3(1.34987, 0, 0)
	weapons.x_p90.parts = {
		wpn_fps_smg_p90_b_short = {
			[Idstring("short"):key()] = {
				pattern_tweak = Vector3(0.127709, 0, 1)
			}
		}
	}
	weapons.polymer.pattern_tweak = Vector3(1, 0, 0)
	weapons.x_polymer.pattern_pos = Vector3(0.69306, 0.416408, 0)
	weapons.x_polymer.pattern_tweak = Vector3(1, 0, 0)
	weapons.x_polymer.parts = {
		wpn_fps_smg_polymer_fg_standard = {
			[Idstring("mtr_fg"):key()] = {
				pattern_tweak = Vector3(0.448599, 0, 1),
				pattern_pos = Vector3(-0.432626, 0.864775, 0)
			}
		},
		wpn_fps_smg_polymer_body_standard = {
			[Idstring("mtr_body"):key()] = {
				uv_offset_rot = Vector3(0.080979, 0.800457, 0),
				uv_scale = Vector3(7.69993, 7.41388, 1)
			}
		},
		wpn_fps_smg_polymer_m_standard = {
			[Idstring("mtr_mag"):key()] = {
				uv_offset_rot = Vector3(-0.251371, 1.2082, 4.69478),
				uv_scale = Vector3(5.79294, 7.08016, 1)
			}
		}
	}
	weapons.m16.parts = {
		wpn_fps_m16_s_solid_vanilla = {
			[Idstring("solid"):key()] = {
				uv_offset_rot = Vector3(-0.453705, 1.11281, 0),
				uv_scale = Vector3(20, 20, 0)
			}
		}
	}
	weapons.m16.types = {
		lower_reciever = {
			pattern_tweak = Vector3(0.825187, 0, 1)
		},
		sight = {
			pattern_tweak = Vector3(0.443599, 0, 1)
		},
		upper_reciever = {
			pattern_tweak = Vector3(0.968283, 0, 1)
		}
	}
	weapons.colt_1911.pattern_pos = Vector3(0.0634393, 0.540425, 0)
	weapons.colt_1911.pattern_tweak = Vector3(0.939283, 0, 0)
	weapons.colt_1911.types = {
		slide = {
			pattern_tweak = Vector3(1.30217, 0, 1)
		},
		grip = {
			pattern_tweak = Vector3(0.259106, 0, 1),
			pattern_pos = Vector3(0.406869, -0.203673, 0)
		}
	}
	weapons.x_g18c.pattern_tweak = Vector3(1, 0, 0)
	weapons.glock_18c.pattern_tweak = Vector3(0.72979, 0, 0)
	weapons.glock_18c.types = {
		lower_reciever = {
			pattern_tweak = Vector3(0.825187, 0, 1),
			pattern_pos = Vector3(1.16051, 1.24582, 0)
		}
	}
	weapons.deagle.types = {
		slide = {
			pattern_tweak = Vector3(0.586694, 0, 1)
		},
		grip = {
			pattern_tweak = Vector3(0.252805, 1.47302, 1),
			pattern_pos = Vector3(1.37992, 0.931553, 0)
		}
	}
	weapons.sparrow.parts = {
		wpn_fps_pis_sparrow_body_rpl = {
			[Idstring("mtr_frame_rpl"):key()] = {
				pattern_pos = Vector3(0.321011, 1.22728, 0)
			}
		}
	}
	weapons.amcar.parts = {
		wpn_fps_amcar_uupg_body_upperreciever = {
			[Idstring("amcar_upper"):key()] = {
				pattern_pos = Vector3(0.616742, -0.00241808, 0)
			}
		}
	}
	weapons.ak74.parts = {
		wpn_upg_ak_fg_combo3 = {
			[Idstring("lower_rail"):key()] = {
				pattern_tweak = Vector3(0.968283, 0, 1)
			},
			[Idstring("ultimak"):key()] = {
				pattern_tweak = Vector3(0.682091, 0, 1)
			}
		},
		wpn_fps_upg_ak_s_solidstock = {
			[Idstring("mtr_solid"):key()] = {
				pattern_pos = Vector3(0.778917, 0.076979, 0)
			}
		},
		wpn_upg_ak_fg_combo2 = {
			[Idstring("ultimak"):key()] = {
				pattern_tweak = Vector3(0.586694, 0, 1)
			},
			[Idstring("handguard_lower_wood"):key()] = {
				pattern_tweak = Vector3(0.634393, 0, 1),
				pattern_pos = Vector3(-0.251371, 0.457028, 0)
			}
		},
		wpn_upg_ak_g_standard = {
			[Idstring("pistolgrip"):key()] = {
				pattern_tweak = Vector3(0.825187, 0, 1),
				pattern_pos = Vector3(-1.37706, 0.340091, 0)
			}
		},
		wpn_fps_ass_ak_body_lowerreceiver = {
			[Idstring("ak_base"):key()] = {
				pattern_pos = Vector3(-0.337228, -0.203673, 0)
			}
		},
		wpn_upg_ak_s_psl = {
			[Idstring("psl"):key()] = {}
		},
		wpn_fps_ass_74_body_upperreceiver = {
			[Idstring("ak74_dustcover"):key()] = {
				pattern_pos = Vector3(-1.12902, -1.01455, 0),
				pattern_tweak = Vector3(1.06368, 0, 1)
			}
		},
		wpn_upg_ak_fg_standard = {
			[Idstring("handguard_upper_wood"):key()] = {
				pattern_tweak = Vector3(0.538996, 0, 1),
				pattern_pos = Vector3(-1.20534, 0.998331, 0)
			},
			[Idstring("handguard_lower_wood"):key()] = {}
		}
	}
	weapons.ak74.types = {
		upper_reciever = {
			pattern_tweak = Vector3(0.777489, 0, 1),
			pattern_pos = Vector3(0.473647, 0.425948, 0)
		},
		magazine = {
			pattern_pos = Vector3(0, 0.521345, 0),
			pattern_tweak = Vector3(1.87455, 0, 1)
		}
	}
	weapons.aug.parts = {
		wpn_fps_aug_b_medium = {
			[Idstring("barrel"):key()] = {
				pattern_tweak = Vector3(1.01598, 0, 1)
			}
		}
	}
	weapons.aug.types = {
		lower_reciever = {
			pattern_pos = Vector3(0, 0.225614, 0)
		},
		vertical_grip = {
			pattern_tweak = Vector3(0.443599, 0, 1)
		},
		barrel = {
			pattern_tweak = Vector3(1.11138, 0, 1)
		},
		sight = {
			pattern_tweak = Vector3(0.777489, 0, 1),
			pattern_pos = Vector3(0, 0.235154, 0)
		}
	}
	weapons.akm.parts = {
		wpn_upg_ak_m_akm = {
			[Idstring("akm_mag"):key()] = {
				pattern_tweak = Vector3(1.20678, 0, 1)
			}
		},
		wpn_upg_ak_s_psl = {
			[Idstring("psl"):key()] = {
				pattern_pos = Vector3(0, -0.175053, 0)
			}
		},
		wpn_fps_upg_ak_s_solidstock = {
			[Idstring("mtr_solid"):key()] = {
				base_gradient = "base_variation",
				pattern_tweak = Vector3(1.06368, 0, 1),
				pattern_pos = Vector3(0.836156, 0.101598, 0)
			}
		},
		wpn_upg_ak_fg_standard = {
			[Idstring("handguard_upper_wood"):key()] = {
				pattern_tweak = Vector3(0.443599, 1.80269, 1),
				pattern_pos = Vector3(-0.518483, -0.136895, 0)
			},
			[Idstring("handguard_lower_wood"):key()] = {
				pattern_tweak = Vector3(0.634393, 0, 1),
				pattern_pos = Vector3(0, 0.950632, 0)
			}
		}
	}
	weapons.g36.parts = {
		wpn_fps_upg_g36_fg_long = {
			[Idstring("mtr_fg_g36"):key()] = {
				pattern_tweak = Vector3(2.11305, 0, 1)
			}
		}
	}
	weapons.new_m14.parts = {
		wpn_fps_ass_m14_body_dmr = {
			[Idstring("dmr1"):key()] = {
				pattern_tweak = Vector3(2.16075, 0, 1)
			}
		},
		wpn_fps_ass_m14_b_standard = {
			[Idstring("barrel"):key()] = {
				pattern_tweak = Vector3(0.586694, 0, 1)
			}
		},
		wpn_fps_ass_m14_body_lower = {
			[Idstring("lower"):key()] = {
				pattern_tweak = Vector3(0.920584, 0, 1),
				pattern_pos = Vector3(1.28452, -0.404006, 0)
			}
		},
		wpn_fps_ass_m14_body_upper = {
			[Idstring("base"):key()] = {
				pattern_tweak = Vector3(0.72979, 0, 1),
				pattern_pos = Vector3(-0.0701166, 0.292392, 0)
			}
		},
		wpn_fps_ass_m14_body_jae = {
			[Idstring("jae"):key()] = {
				pattern_tweak = Vector3(1.63606, 0, 1),
				pattern_pos = Vector3(-0.003, 0.133757, 0)
			}
		},
		wpn_fps_ass_m14_m_standard = {
			[Idstring("mag"):key()] = {
				pattern_tweak = Vector3(0.777489, 0, 1)
			}
		}
	}
	weapons.new_m14.types = {
		barrel_ext = {
			pattern_tweak = Vector3(0.72979, 0, 1)
		},
		sight = {
			pattern_tweak = Vector3(0.920584, 0, 1),
			pattern_pos = Vector3(0, 0.569044, 0)
		}
	}
	weapons.ak5.parts = {
		wpn_fps_ass_ak5_body_ak5 = {
			[Idstring("mtr_grip"):key()] = {
				pattern_tweak = Vector3(2.11305, 0, 1)
			}
		}
	}
	weapons.s552.types = {
		foregrip = {
			pattern_pos = Vector3(0, 0.36871, 0)
		}
	}
	weapons.scar.types = {
		barrel = {
			pattern_tweak = Vector3(0.443599, 0, 1)
		},
		barrel_ext = {
			pattern_tweak = Vector3(0.3959, 0, 1),
			pattern_pos = Vector3(0, 0.35917, 0)
		},
		upper_reciever = {
			pattern_tweak = Vector3(1.49297, 0, 1),
			pattern_pos = Vector3(0, -0.127355, 0)
		}
	}
	weapons.scar.parts = {
		wpn_fps_upg_vg_ass_smg_afg = {
			[Idstring("afg"):key()] = {
				pattern_tweak = Vector3(0.491297, 0, 1)
			}
		},
		wpn_fps_ass_scar_body_standard = {
			[Idstring("mtr_railcover"):key()] = {
				pattern_tweak = Vector3(0.300503, 0, 1)
			}
		},
		wpn_fps_ass_scar_o_flipups_up = {
			[Idstring("mtr_rear"):key()] = {
				pattern_tweak = Vector3(0.157408, 0, 1)
			},
			[Idstring("mtr_front"):key()] = {
				pattern_tweak = Vector3(0.300503, 0, 1)
			}
		}
	}
	weapons.fal.types = {
		barrel = {
			pattern_tweak = Vector3(1.54067, 0, 1)
		},
		magazine = {
			pattern_tweak = Vector3(0.586694, 0, 1)
		}
	}
	weapons.famas.types = {
		upper_reciever = {
			pattern_tweak = Vector3(1.54067, 0, 1)
		},
		grip = {
			pattern_tweak = Vector3(0.872886, 0, 0),
			pattern_pos = Vector3(-0.62342, -0.642499, 0)
		},
		barrel_ext = {
			pattern_tweak = Vector3(0.682091, 0, 1)
		},
		sight = {
			pattern_tweak = Vector3(0.634393, 0, 1)
		}
	}
	weapons.galil.types = {
		grip = {
			pattern_tweak = Vector3(0.872886, 0, 1),
			pattern_pos = Vector3(0.492726, 1.17005, 0)
		},
		sight = {
			pattern_tweak = Vector3(0.825187, 0, 1),
			pattern_pos = Vector3(0, 0.912473, 0)
		}
	}
	weapons.vhs.parts = {
		wpn_fps_ass_vhs_body = {
			[Idstring("mtr_body"):key()] = {
				pattern_tweak = Vector3(2.54233, 0, 1)
			}
		}
	}
	weapons.sub2000.pattern_pos = Vector3(0, 0.216075, 0)
	weapons.sub2000.parts = {
		wpn_fps_ass_sub2000_m_standard = {
			[Idstring("mtr_mag"):key()] = {
				pattern_tweak = Vector3(1.15908, 0, 1),
				pattern_pos = Vector3(0.445028, 0.473647, 0)
			}
		}
	}
	weapons.saw.parts = {
		wpn_fps_saw_m_blade = {
			[Idstring("mtr_blade"):key()] = {
				pattern = "pattern_none",
				pattern_gradient = "gradient_none",
				uv_offset_rot = Vector3(-0.01, 0, 0)
			}
		},
		wpn_fps_saw_m_blade_durable = {
			[Idstring("mtr_blade"):key()] = {
				pattern = "pattern_none",
				pattern_gradient = "gradient_none",
				uv_offset_rot = Vector3(-0.01, 0, 0)
			},
			[Idstring("mtr_blade_durable"):key()] = {
				pattern = "pattern_none",
				pattern_gradient = "gradient_none",
				uv_offset_rot = Vector3(-0.01, 0, 0)
			}
		},
		wpn_fps_saw_m_blade_sharp = {
			[Idstring("mtr_blade"):key()] = {
				pattern = "pattern_none",
				pattern_gradient = "gradient_none",
				uv_offset_rot = Vector3(-0.01, 0, 0)
			},
			[Idstring("mtr_blade_sharp"):key()] = {
				pattern = "pattern_none",
				pattern_gradient = "gradient_none",
				uv_offset_rot = Vector3(-0.01, 0, 0)
			}
		}
	}
	weapons.m134.parts = {
		wpn_fps_lmg_m134_body = {
			[Idstring("mtr_body"):key()] = {
				pattern_tweak = Vector3(2.35154, 0, 1),
				pattern_pos = Vector3(0, -0.0414975, 0)
			}
		}
	}
	weapons.m32.parts = {
		wpn_fps_gre_m32_barrel = {
			[Idstring("body"):key()] = {
				pattern_tweak = Vector3(1.49297, 0, 1)
			}
		},
		wpn_fps_gre_m32_stock_adapter = {
			[Idstring("adapter"):key()] = {
				pattern_tweak = Vector3(0.575694, 0, 1)
			}
		},
		wpn_fps_upg_m4_s_standard_vanilla = {
			[Idstring("stock_standard"):key()] = {
				pattern_tweak = Vector3(0.919886, 0, 1)
			}
		},
		wpn_fps_gre_m32_lower_reciever = {
			[Idstring("body"):key()] = {
				pattern_tweak = Vector3(2.16075, 0, 1)
			}
		}
	}
	weapons.m32.types = {
		stock = {
			pattern_tweak = Vector3(1.34987, 0, 1)
		},
		stock_adapter = {
			pattern_tweak = Vector3(0.777489, 0, 1)
		}
	}
	weapons.flamethrower_mk2.parts = {
		wpn_fps_fla_mk2_body = {
			[Idstring("body"):key()] = {
				pattern_tweak = Vector3(4.59337, 0, 1),
				pattern_pos = Vector3(-0.184593, -0.0987357, 0)
			}
		},
		wpn_fps_fla_mk2_mag = {
			[Idstring("flame_fuel_can"):key()] = {
				pattern_tweak = Vector3(1.06368, 0, 1)
			}
		}
	}
	weapons.arblast.parts = {
		wpn_fps_bow_arblast_b_steel = {
			[Idstring("mtr_xbow"):key()] = {
				pattern_tweak = Vector3(2.49464, 0, 1),
				pattern_pos = Vector3(0, 0.149297, 0)
			}
		}
	}
	weapons.model70.types = {
		stock = {
			pattern_tweak = Vector3(2.73313, 0, 1)
		}
	}
	weapons.msr.types = {
		stock = {
			pattern_tweak = Vector3(2.39924, 0, 1),
			pattern_pos = Vector3(0, 0.111138, 0)
		}
	}
	weapons.r93.parts = {
		wpn_fps_snp_r93_body_standard = {
			[Idstring("mtr_upper"):key()] = {
				pattern_tweak = Vector3(1.11138, 0, 1),
				pattern_pos = Vector3(0.149297, -0.00333866, 0)
			}
		}
	}
	weapons.r93.types = {
		barrel = {
			pattern_tweak = Vector3(1.54067, 0, 1)
		}
	}
	weapons.mosin.parts = {
		wpn_fps_snp_mosin_body_standard = {
			[Idstring("mtr_bolt"):key()] = {
				pattern_tweak = Vector3(0.586694, 0, 1),
				pattern_pos = Vector3(0, 1.05557, 0)
			}
		}
	}
	weapons.mosin.types = {
		stock = {
			pattern_tweak = Vector3(2.25614, 0, 1)
		}
	}
	weapons.wa2000.types = {
		stock = {
			pattern_tweak = Vector3(0.872886, 0, 1)
		},
		grip = {
			pattern_tweak = Vector3(2.20844, 0, 1)
		},
		sight = {
			pattern_tweak = Vector3(1.25447, 0, 1),
			pattern_pos = Vector3(0.216075, 0.225614, 0)
		}
	}
	weapons.spas12.parts = {
		wpn_fps_sho_body_spas12_standard = {
			[Idstring("mtr_body"):key()] = {
				pattern_tweak = Vector3(2.20844, 0, 1),
				pattern_pos = Vector3(-0.0414975, 0.349631, 0)
			}
		}
	}
	weapons.r870.types = {
		stock = {
			pattern_pos = Vector3(1.16851, 0.145297, 0),
			pattern_tweak = Vector3(1.44527, 0, 1)
		}
	}
	weapons.aa12.parts = {
		wpn_fps_sho_aa12_body = {
			[Idstring("aa12_main"):key()] = {
				pattern_tweak = Vector3(2.54233, 0, 1)
			}
		}
	}
	weapons.aa12.types = {
		magazine = {
			pattern_tweak = Vector3(1.01598, 0, 1)
		}
	}
	weapons.striker.parts = {
		wpn_fps_sho_striker_body_standard = {
			[Idstring("mtr_body"):key()] = {
				pattern_tweak = Vector3(3.16242, 0, 1)
			}
		}
	}
	weapons.sparrow.parts = {
		wpn_fps_pis_sparrow_body_rpl = {
			[Idstring("mtr_frame_rpl"):key()] = {
				pattern_pos = Vector3(0.321011, 1.22728, 0)
			}
		}
	}
	weapons.m37.types = {
		stock = {
			pattern_tweak = Vector3(2.87622, 0, 1)
		},
		foregrip = {
			pattern_tweak = Vector3(2.06535, 0, 1)
		},
		lower_reciever = {
			pattern_tweak = Vector3(0.682091, 1.7877, 1),
			pattern_pos = Vector3(0.721679, 1.78059, 0)
		},
		barrel = {
			pattern_tweak = Vector3(3.83019, 0, 1)
		}
	}
	weapons.china.pattern_tweak = Vector3(2.35154, 0, 0)
	weapons.sr2.pattern_tweak = Vector3(1, 0, 0)
	weapons.pl14.pattern_tweak = Vector3(1.68376, 0, 1)
	weapons.pl14.pattern_tweak = Vector3(1, 0, 0)
	weapons.x_pl14.pattern_pos = Vector3(1.9523, 0.120678, 0)
	weapons.x_pl14.pattern_tweak = Vector3(1.20678, 0, 0)
	weapons.tecci.pattern_pos = Vector3(0, 0.254233, 0)
	weapons.tecci.pattern_tweak = Vector3(1, 0, 0)
	weapons.tecci.parts = {
		wpn_fps_ass_tecci_lower_reciever = {
			[Idstring("mtr_lower"):key()] = {
				pattern_tweak = Vector3(2.54233, 0, 1),
				pattern_pos = Vector3(0.907775, 0.945632, 0)
			}
		},
		wpn_fps_ass_tecci_fg_standard = {
			[Idstring("mtr_fg"):key()] = {
				pattern_tweak = Vector3(1.44527, 0, 1),
				pattern_pos = Vector3(-0.136895, 0.168376, 0)
			}
		},
		wpn_fps_upg_m4_s_ubr = {
			[Idstring("mtr_ubr"):key()] = {
				pattern_tweak = Vector3(1.68376, 0, 1)
			}
		},
		wpn_fps_ass_tecci_vg_standard = {
			[Idstring("mtr_vg"):key()] = {
				pattern_tweak = Vector3(1.63606, 0, 1),
				pattern_pos = Vector3(-0.0701166, 0.0157408, 0)
			}
		}
	}
	weapons.hajk.pattern_tweak = Vector3(1, 0, 0)
	weapons.boot.pattern_pos = Vector3(0, 0.301932, 0)
	weapons.boot.pattern_tweak = Vector3(1, 0, 0)
	weapons.boot.parts = {
		wpn_fps_sho_boot_body_standard = {
			[Idstring("mtr_body"):key()] = {
				pattern_pos = Vector3(0.235154, 0.139757, 0)
			}
		}
	}
	weapons.desertfox.pattern_tweak = Vector3(1, 0, 0)
	weapons.schakal.pattern_tweak = Vector3(1, 0, 0)
	weapons.schakal.parts = {
		wpn_fps_smg_schakal_body_lower = {
			[Idstring("mtr_lower_reciever"):key()] = {
				pattern_tweak = Vector3(1.25447, 0, 1)
			}
		},
		wpn_fps_smg_schakal_body_upper = {
			[Idstring("mtr_upper_reciever"):key()] = {
				pattern_tweak = Vector3(3.11472, 0, 1)
			}
		}
	}
	weapons.x_schakal.pattern_pos = Vector3(0, 0.187455, 0)
	weapons.x_schakal.pattern_tweak = Vector3(1, 0, 0)
	weapons.x_schakal.parts = {
		wpn_fps_smg_schakal_body_upper = {
			[Idstring("mtr_upper_reciever"):key()] = {
				pattern_tweak = Vector3(2.73313, 0, 1)
			}
		}
	}
	weapons.rota.pattern_pos = Vector3(-0.0128784, 0.626282, 0)
	weapons.rota.pattern_tweak = Vector3(0.3959, 0, 0)
	weapons.rota.parts = {
		wpn_fps_sho_rota_body_upper = {
			[Idstring("mat_upper"):key()] = {
				pattern_tweak = Vector3(1.11138, 0, 1)
			}
		}
	}
	weapons.arbiter.pattern_tweak = Vector3(3.49631, 0, 0)
	weapons.contraband.pattern_pos = Vector3(0, 0.216075, 0)
	weapons.contraband.pattern_tweak = Vector3(1, 0, 0)
	weapons.contraband.parts = {
		wpn_fps_ass_contraband_s_standard = {
			[Idstring("mtr_stock"):key()] = {
				pattern_tweak = Vector3(1.34987, 0, 1)
			}
		},
		wpn_fps_ass_contraband_g_standard = {
			[Idstring("mtr_grip"):key()] = {
				pattern_tweak = Vector3(1.25447, 0, 1)
			}
		},
		wpn_fps_ass_contraband_body_standard = {
			[Idstring("mtr_lower"):key()] = {
				pattern_tweak = Vector3(1.77916, 0, 1)
			}
		}
	}
	weapons.ray.pattern_pos = Vector3(0, 0.068, 0)
	weapons.ray.pattern_tweak = Vector3(2.01765, 0, 0)
	weapons.tti.pattern_tweak = Vector3(1.01598, 0, 0)
	weapons.tti.parts = {
		wpn_fps_snp_tti_body_receiverlower = {
			[Idstring("tti_receiver_lowerr"):key()] = {
				pattern_tweak = Vector3(0.968283, 0, 1),
				pattern_pos = Vector3(0.196995, 0.7026, 0)
			}
		},
		wpn_fps_snp_tti_body_receiverupper = {
			[Idstring("tti_receiver_upper"):key()] = {
				pattern_tweak = Vector3(0.825187, 0, 1),
				pattern_pos = Vector3(-0.006, -0.013, 0)
			}
		},
		wpn_fps_ass_contraband_s_standard = {
			[Idstring("mtr_stock"):key()] = {
				pattern_tweak = Vector3(2.78083, 0, 1),
				pattern_pos = Vector3(-0.222752, 0.0157408, 0)
			}
		},
		wpn_fps_upg_m4_g_standard_vanilla = {
			[Idstring("standard_grip"):key()] = {
				pattern_tweak = Vector3(0.920584, 0, 1),
				pattern_pos = Vector3(0, 0.35917, 0)
			}
		}
	}
	weapons.tti.types = {
		stock = {
			pattern_tweak = Vector3(2.25614, 0, 1)
		},
		foregrip = {
			pattern_tweak = Vector3(1.73146, 0, 1)
		}
	}
	weapons.siltstone.pattern_tweak = Vector3(1.25447, 0, 0)
	weapons.siltstone.parts = {
		wpn_fps_snp_siltstone_body_receiver = {
			[Idstring("mat_body_low"):key()] = {
				pattern_tweak = Vector3(0.920584, 0, 1)
			}
		}
	}
	weapons.siltstone.types = {
		magazine = {
			base_gradient = "base_default",
			pattern_tweak = Vector3(0.443599, 0, 1)
		}
	}
	weapons.flint.pattern_tweak = Vector3(1, 0, 0)
	weapons.coal.pattern_pos = Vector3(-0.0987357, 0.168376, 0)
	weapons.coal.pattern_tweak = Vector3(0.920584, 0, 0)
	weapons.coal.parts = {
		wpn_fps_smg_coal_m_standard = {
			[Idstring("mat_mag"):key()] = {
				pattern_tweak = Vector3(0.72979, 0, 1),
				pattern_pos = Vector3(-0.203673, 0.464107, 0)
			}
		}
	}
	weapons.coal.types = {
		grip = {
			pattern_tweak = Vector3(0.177408, 0, 1)
		}
	}
	weapons.lemming.pattern_pos = Vector3(0.206535, 0.616742, 0)
	weapons.lemming.pattern_tweak = Vector3(1, 0, 0)
	weapons.chinchilla.pattern_tweak = Vector3(0.634393, 0, 0)
	weapons.shepheard.pattern_tweak = Vector3(1, 0, 0)
	weapons.breech.pattern_tweak = Vector3(1, 0, 0)
	weapons.breech.parts = {
		wpn_fps_pis_breech_b_short = {
			[Idstring("mtr_b_short"):key()] = {
				pattern_tweak = Vector3(0.205106, 0, 1)
			}
		}
	}
	weapons.ching.pattern_pos = Vector3(0, 0.235154, 0)
	weapons.ching.pattern_tweak = Vector3(1.73146, 0, 0.699499)
	weapons.ching.types = {
		barrel_ext = {
			pattern_tweak = Vector3(0.634393, 0, 1)
		},
		gadget = {
			pattern_tweak = Vector3(0.682091, 0, 1)
		}
	}
	weapons.erma.pattern_tweak = Vector3(1, 0, 0)
	weapons.ecp.pattern_tweak = Vector3(1.25447, 0, 1)
	weapons.shrew.pattern_tweak = Vector3(1, 0, 0)
	weapons.basset.pattern_tweak = Vector3(1, 0, 0)
	weapons.corgi.pattern_pos = Vector3(0.0252805, 0.740759, 0)
	weapons.corgi.pattern_tweak = Vector3(2.82853, 0, 0)
	weapons.slap.pattern_tweak = Vector3(1, 0, 0)
	weapons.shuno.pattern_tweak = Vector3(1.96995, 0, 1)
	weapons.shuno.parts = {
		wpn_fps_lmg_shuno_body_standard = {
			[Idstring("mat_battery_and_drum"):key()] = {
				pattern_tweak = Vector3(1.77916, 0, 1)
			},
			[Idstring("mat_grip_standard"):key()] = {
				pattern_tweak = Vector3(1.20678, 0, 1)
			},
			[Idstring("mat_body_standard"):key()] = {
				pattern_tweak = Vector3(1.77916, 0, 1)
			}
		},
		wpn_fps_lmg_shuno_b_standard = {
			[Idstring("mat_barrel_standard"):key()] = {
				pattern_tweak = Vector3(0.872886, 0, 1)
			}
		},
		wpn_fps_lmg_shuno_s_standard = {
			[Idstring("mat_stock"):key()] = {
				pattern_tweak = Vector3(1.96995, 0, 1),
				pattern_pos = Vector3(0.330551, 0.511806, 0)
			}
		}
	}
	weapons.komodo.pattern_tweak = Vector3(2.25614, 0, 1)
	weapons.elastic.pattern_tweak = Vector3(3.97329, 0, 1)
	weapons.elastic.parts = {
		wpn_fps_bow_elastic_sight = {
			[Idstring("mtr_whisker"):key()] = {
				pattern_tweak = Vector3(1.54067, 0, 1)
			},
			[Idstring("mtr_rail"):key()] = {
				pattern_tweak = Vector3(1.06368, 0, 1)
			}
		},
		wpn_fps_bow_elastic_whisker = {
			[Idstring("mtr_whisker"):key()] = {
				pattern_tweak = Vector3(0.825187, 0, 1)
			}
		},
		wpn_fps_bow_elastic_pin = {
			[Idstring("mtr_pin_crome"):key()] = {
				pattern_tweak = Vector3(1.06368, 0, 1)
			}
		}
	}
	weapons.elastic.types = {
		grip = {
			pattern_tweak = Vector3(0.825187, 0, 1)
		}
	}
	weapons.legacy.pattern_tweak = Vector3(0.634393, 0, 1)
	weapons.coach.pattern_pos = Vector3(1.04603, 0.206535, 0)
	weapons.holt.pattern_pos = Vector3(0.158836, 0, 0)
	weapons.holt.pattern_tweak = Vector3(0.825187, 0, 0)
	weapons.holt.types = {
		grip = {
			pattern_tweak = Vector3(0.348202, 0, 1)
		}
	}

	WeaponColorTemplates._setup_akimbo_weapons(tweak_data, weapons)

	return weapons
end
