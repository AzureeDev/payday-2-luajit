
function BlackMarketTweakData:_init_bullets(tweak_data)
	self.bullets = {}
end

function BlackMarketTweakData:_init_projectiles(tweak_data)
	self.projectiles = {frag = {}}
	self.projectiles.frag.name_id = "bm_grenade_frag"
	self.projectiles.frag.unit = "units/payday2/weapons/wpn_frag_grenade/wpn_frag_grenade"
	self.projectiles.frag.unit_dummy = "units/payday2/weapons/wpn_frag_grenade/wpn_frag_grenade_husk"
	self.projectiles.frag.sprint_unit = "units/payday2/weapons/wpn_frag_grenade/wpn_frag_grenade_sprint"
	self.projectiles.frag.icon = "frag_grenade"
	self.projectiles.frag.dlc = "gage_pack"
	self.projectiles.frag.throwable = true
	self.projectiles.frag.max_amount = 3
	self.projectiles.frag.animation = "throw_grenade"
	self.projectiles.frag.anim_global_param = "projectile_frag"
	self.projectiles.frag.throw_allowed_expire_t = 0.1
	self.projectiles.frag.expire_t = 1.1
	self.projectiles.frag.repeat_expire_t = 1.5
	self.projectiles.frag.is_a_grenade = true
	self.projectiles.frag.is_explosive = true
	self.projectiles.concussion = {
		name_id = "bm_concussion",
		unit = "units/pd2_crimefest_2016/fez1/weapons/wpn_fps_gre_pressure/wpn_third_gre_pressure",
		unit_dummy = "units/pd2_crimefest_2016/fez1/weapons/wpn_fps_gre_pressure/wpn_fps_gre_pressure_husk",
		sprint_unit = "units/pd2_crimefest_2016/fez1/weapons/wpn_fps_gre_pressure/wpn_third_gre_pressure_sprint",
		icon = "concussion_grenade",
		throwable = true,
		max_amount = 6,
		animation = "throw_concussion",
		anim_global_param = "projectile_frag",
		texture_bundle_folder = "fez1",
		throw_allowed_expire_t = 0.1,
		expire_t = 0.9,
		repeat_expire_t = 1.5,
		is_a_grenade = true
	}
	self.projectiles.molotov = {
		name_id = "bm_grenade_molotov",
		unit = "units/pd2_dlc_bbq/weapons/molotov_cocktail/wpn_molotov_third",
		unit_dummy = "units/pd2_dlc_bbq/weapons/molotov_cocktail/wpn_molotov_husk",
		icon = "molotov_grenade",
		dlc = "bbq",
		no_cheat_count = true,
		impact_detonation = true,
		time_cheat = 1,
		throwable = true,
		max_amount = 3,
		texture_bundle_folder = "bbq",
		physic_effect = Idstring("physic_effects/molotov_throw"),
		animation = "throw_molotov",
		anim_global_param = "projectile_molotov",
		throw_allowed_expire_t = 0.1,
		expire_t = 1.3,
		repeat_expire_t = 1.5,
		is_a_grenade = true
	}
	self.projectiles.dynamite = {
		name_id = "bm_dynamite",
		unit = "units/pd2_dlc_west/weapons/wpn_gre_dynamite/wpn_gre_dynamite",
		unit_dummy = "units/pd2_dlc_west/weapons/wpn_gre_dynamite/wpn_gre_dynamite_husk",
		icon = "dynamite_grenade",
		dlc = "west",
		texture_bundle_folder = "west",
		max_amount = 3,
		throwable = true,
		animation = "throw_dynamite",
		anim_global_param = "projectile_dynamite",
		throw_allowed_expire_t = 0.1,
		expire_t = 1.3,
		repeat_expire_t = 1.5,
		is_a_grenade = true,
		is_explosive = true
	}
	self.projectiles.wpn_prj_four = {
		name_id = "bm_wpn_prj_four",
		unit = "units/pd2_dlc_turtles/weapons/wpn_prj_four/wpn_prj_four",
		unit_dummy = "units/pd2_dlc_turtles/weapons/wpn_prj_four/wpn_prj_four_husk",
		local_unit = "units/pd2_dlc_turtles/weapons/wpn_prj_four/wpn_prj_four_local",
		icon = "four_projectile",
		throw_shout = true,
		no_cheat_count = true,
		impact_detonation = true,
		client_authoritative = true,
		add_trail_effect = true,
		throwable = true,
		texture_bundle_folder = "turtles",
		dlc = "turtles",
		max_amount = 10,
		anim_global_param = "projectile_four",
		throw_allowed_expire_t = 0.15,
		expire_t = 1.1,
		repeat_expire_t = 0.5
	}
	self.projectiles.wpn_prj_ace = {
		name_id = "bm_wpn_prj_ace",
		unit = "units/pd2_dlc_cake/weapons/wpn_prj_ace/wpn_prj_ace",
		unit_dummy = "units/pd2_dlc_cake/weapons/wpn_prj_ace/wpn_prj_ace_husk",
		local_unit = "units/pd2_dlc_cake/weapons/wpn_prj_ace/wpn_prj_ace_local",
		icon = "ace_projectile",
		throw_shout = true,
		no_cheat_count = true,
		impact_detonation = true,
		client_authoritative = true,
		add_trail_effect = true,
		throwable = true,
		dlc = "pd2_clan",
		max_amount = 21,
		anim_global_param = "projectile_four",
		throw_allowed_expire_t = 0.15,
		expire_t = 1.1,
		repeat_expire_t = 0.3
	}
	self.projectiles.launcher_frag = {
		name_id = "bm_launcher_frag",
		unit = "units/pd2_dlc_gage_assault/weapons/wpn_launcher_frag_grenade/wpn_launcher_frag_grenade",
		weapon_id = "gre_m79",
		no_cheat_count = true,
		impact_detonation = true,
		is_explosive = true,
		time_cheat = 1
	}
	self.projectiles.rocket_frag = {
		name_id = "bm_rocket_frag",
		unit = "units/pd2_dlc_overkill_pack/weapons/wpn_third_rpg7_fired_rocket/wpn_third_rpg7_fired_rocket",
		weapon_id = "rpg7",
		no_cheat_count = true,
		impact_detonation = true,
		is_explosive = true,
		time_cheat = 1,
		physic_effect = Idstring("physic_effects/anti_gravitate"),
		adjust_z = 0
	}
	self.projectiles.launcher_incendiary = {
		name_id = "bm_launcher_incendiary",
		unit = "units/pd2_dlc_bbq/weapons/wpn_launcher_incendiary_grenade/wpn_launcher_incendiary_grenade",
		weapon_id = "gre_m79",
		no_cheat_count = true,
		impact_detonation = true,
		time_cheat = 1
	}
	self.projectiles.launcher_frag_m32 = deep_clone(self.projectiles.launcher_frag)
	self.projectiles.launcher_frag_m32.weapon_id = "m32"
	self.projectiles.launcher_incendiary_m32 = deep_clone(self.projectiles.launcher_incendiary)
	self.projectiles.launcher_incendiary_m32.weapon_id = "m32"
	self.projectiles.launcher_frag_china = deep_clone(self.projectiles.launcher_frag)
	self.projectiles.launcher_frag_china.weapon_id = "china"
	self.projectiles.launcher_frag_china.unit = "units/pd2_dlc_lupus/weapons/wpn_launcher_frag_grenade_china/wpn_launcher_frag_grenade_china"
	self.projectiles.launcher_incendiary_china = deep_clone(self.projectiles.launcher_incendiary)
	self.projectiles.launcher_incendiary_china.weapon_id = "china"
	self.projectiles.launcher_frag_arbiter = {
		name_id = "bm_launcher_frag",
		unit = "units/pd2_dlc_tng/weapons/wpn_arbiter_frag_grenade/wpn_arbiter_frag_grenade",
		weapon_id = "arbiter",
		no_cheat_count = true,
		impact_detonation = true,
		is_explosive = true,
		time_cheat = 0.2,
		adjust_z = 0
	}
	self.projectiles.launcher_incendiary_arbiter = {
		name_id = "bm_launcher_incendiary",
		unit = "units/pd2_dlc_tng/weapons/wpn_arbiter_frag_incendiary_grenade/wpn_arbiter_frag_incendiary_grenade",
		weapon_id = "arbiter",
		no_cheat_count = true,
		impact_detonation = true,
		time_cheat = 0.2,
		adjust_z = 0
	}
	self.projectiles.rocket_ray_frag = {
		name_id = "bm_rocket_frag",
		unit = "units/pd2_dlc_friend/weapons/wpn_third_ray_fired_rocket/wpn_third_ray_fired_rocket",
		weapon_id = "ray",
		no_cheat_count = true,
		impact_detonation = true,
		is_explosive = true,
		time_cheat = 1,
		physic_effect = Idstring("physic_effects/anti_gravitate"),
		adjust_z = 0
	}
	self.projectiles.launcher_frag_slap = deep_clone(self.projectiles.launcher_frag)
	self.projectiles.launcher_frag_slap.weapon_id = "slap"
	self.projectiles.launcher_incendiary_slap = deep_clone(self.projectiles.launcher_incendiary)
	self.projectiles.launcher_incendiary_slap.weapon_id = "slap"
	self.projectiles.west_arrow = {
		name_id = "bm_launcher_frag",
		unit = "units/pd2_dlc_west/weapons/wpn_prj_west_arrow/wpn_prj_west_arrow",
		local_unit = "units/pd2_dlc_west/weapons/wpn_prj_west_arrow/wpn_prj_west_arrow_local",
		weapon_id = "plainsrider",
		no_cheat_count = true,
		impact_detonation = true,
		client_authoritative = true
	}
	self.projectiles.west_arrow_exp = {
		name_id = "bm_launcher_frag",
		unit = "units/pd2_dlc_west/weapons/wpn_prj_west_arrow/wpn_prj_west_arrow_exp",
		local_unit = "units/pd2_dlc_west/weapons/wpn_prj_west_arrow/wpn_prj_west_arrow_exp_local",
		weapon_id = "plainsrider",
		no_cheat_count = true,
		impact_detonation = true,
		client_authoritative = true,
		is_explosive = true
	}
	self.projectiles.bow_poison_arrow = {
		unit = "units/pd2_dlc_turtles/weapons/wpn_prj_bow_poison_arrow/wpn_prj_bow_poison_arrow",
		local_unit = "units/pd2_dlc_turtles/weapons/wpn_prj_bow_poison_arrow/wpn_prj_bow_poison_arrow_local",
		weapon_id = "plainsrider",
		no_cheat_count = true,
		impact_detonation = true,
		client_authoritative = true
	}
	self.projectiles.crossbow_arrow = {
		unit = "units/pd2_dlc_turtles/weapons/wpn_prj_crossbow_arrow/wpn_prj_crossbow_arrow",
		local_unit = "units/pd2_dlc_turtles/weapons/wpn_prj_crossbow_arrow/wpn_prj_crossbow_arrow_local",
		weapon_id = "hunter",
		no_cheat_count = true,
		impact_detonation = true,
		client_authoritative = true
	}
	self.projectiles.crossbow_poison_arrow = {
		unit = "units/pd2_dlc_turtles/weapons/wpn_prj_crossbow_poison_arrow/wpn_prj_crossbow_poison_arrow",
		local_unit = "units/pd2_dlc_turtles/weapons/wpn_prj_crossbow_poison_arrow/wpn_prj_crossbow_poison_arrow_local",
		weapon_id = "hunter",
		no_cheat_count = true,
		impact_detonation = true,
		client_authoritative = true
	}
	self.projectiles.crossbow_arrow_exp = {
		unit = "units/pd2_dlc_turtles/weapons/wpn_prj_crossbow_arrow_exp/wpn_prj_crossbow_arrow_exp",
		local_unit = "units/pd2_dlc_turtles/weapons/wpn_prj_crossbow_arrow_exp/wpn_prj_crossbow_arrow_exp_local",
		weapon_id = "hunter",
		no_cheat_count = true,
		impact_detonation = true,
		client_authoritative = true,
		is_explosive = true
	}
	self.projectiles.wpn_prj_jav = {
		name_id = "bm_wpn_prj_jav",
		unit = "units/pd2_dlc_steel/weapons/wpn_prj_jav/wpn_prj_jav",
		unit_dummy = "units/pd2_dlc_steel/weapons/wpn_prj_jav/wpn_prj_jav_husk",
		local_unit = "units/pd2_dlc_steel/weapons/wpn_prj_jav/wpn_prj_jav_local",
		icon = "jav_projectile",
		throw_shout = true,
		no_cheat_count = true,
		impact_detonation = true,
		client_authoritative = true,
		add_trail_effect = true,
		throwable = true,
		texture_bundle_folder = "steel",
		dlc = "steel",
		max_amount = 3,
		anim_global_param = "projectile_jav",
		throw_allowed_expire_t = 0.4,
		expire_t = 1.1,
		repeat_expire_t = 1
	}
	self.projectiles.arblast_arrow = {
		unit = "units/pd2_dlc_steel/weapons/wpn_prj_arblast_arrow/wpn_prj_arblast_arrow",
		local_unit = "units/pd2_dlc_steel/weapons/wpn_prj_arblast_arrow/wpn_prj_arblast_arrow_local",
		weapon_id = "arblast",
		no_cheat_count = true,
		impact_detonation = true,
		client_authoritative = true
	}
	self.projectiles.arblast_poison_arrow = {
		unit = "units/pd2_dlc_steel/weapons/wpn_prj_arblast_poison_arrow/wpn_prj_arblast_poison_arrow",
		local_unit = "units/pd2_dlc_steel/weapons/wpn_prj_arblast_poison_arrow/wpn_prj_arblast_poison_arrow_local",
		weapon_id = "arblast",
		no_cheat_count = true,
		impact_detonation = true,
		client_authoritative = true
	}
	self.projectiles.arblast_arrow_exp = {
		unit = "units/pd2_dlc_steel/weapons/wpn_prj_arblast_arrow_exp/wpn_prj_arblast_arrow_exp",
		local_unit = "units/pd2_dlc_steel/weapons/wpn_prj_arblast_arrow_exp/wpn_prj_arblast_arrow_exp_local",
		weapon_id = "arblast",
		no_cheat_count = true,
		impact_detonation = true,
		client_authoritative = true,
		is_explosive = true
	}
	self.projectiles.frankish_arrow = {
		unit = "units/pd2_dlc_steel/weapons/wpn_prj_frankish_arrow/wpn_prj_frankish_arrow",
		local_unit = "units/pd2_dlc_steel/weapons/wpn_prj_frankish_arrow/wpn_prj_frankish_arrow_local",
		weapon_id = "frankish",
		no_cheat_count = true,
		impact_detonation = true,
		client_authoritative = true
	}
	self.projectiles.frankish_poison_arrow = {
		unit = "units/pd2_dlc_steel/weapons/wpn_prj_frankish_poison_arrow/wpn_prj_frankish_poison_arrow",
		local_unit = "units/pd2_dlc_steel/weapons/wpn_prj_frankish_poison_arrow/wpn_prj_frankish_poison_arrow_local",
		weapon_id = "frankish",
		no_cheat_count = true,
		impact_detonation = true,
		client_authoritative = true
	}
	self.projectiles.frankish_arrow_exp = {
		unit = "units/pd2_dlc_steel/weapons/wpn_prj_frankish_arrow_exp/wpn_prj_frankish_arrow_exp",
		local_unit = "units/pd2_dlc_steel/weapons/wpn_prj_frankish_arrow_exp/wpn_prj_frankish_arrow_exp_local",
		weapon_id = "frankish",
		no_cheat_count = true,
		impact_detonation = true,
		client_authoritative = true,
		is_explosive = true
	}
	self.projectiles.long_arrow = {
		unit = "units/pd2_dlc_steel/weapons/wpn_fps_bow_long_pts/wpn_prj_long_arrow",
		local_unit = "units/pd2_dlc_steel/weapons/wpn_fps_bow_long_pts/wpn_prj_long_arrow_local",
		weapon_id = "long",
		no_cheat_count = true,
		impact_detonation = true,
		client_authoritative = true
	}
	self.projectiles.long_poison_arrow = {
		unit = "units/pd2_dlc_steel/weapons/wpn_fps_bow_long_pts/wpn_prj_long_poison_arrow",
		local_unit = "units/pd2_dlc_steel/weapons/wpn_fps_bow_long_pts/wpn_prj_long_poison_arrow_local",
		weapon_id = "long",
		no_cheat_count = true,
		impact_detonation = true,
		client_authoritative = true
	}
	self.projectiles.long_arrow_exp = {
		unit = "units/pd2_dlc_steel/weapons/wpn_fps_bow_long_pts/wpn_prj_long_arrow_exp",
		local_unit = "units/pd2_dlc_steel/weapons/wpn_fps_bow_long_pts/wpn_prj_long_arrow_exp_local",
		weapon_id = "long",
		no_cheat_count = true,
		impact_detonation = true,
		client_authoritative = true,
		is_explosive = true
	}
	self.projectiles.wpn_prj_hur = {
		name_id = "bm_wpn_prj_hur",
		unit = "units/pd2_dlc_born/weapons/wpn_fps_mel_hur/wpn_prj_hur",
		unit_dummy = "units/pd2_dlc_born/weapons/wpn_fps_mel_hur/wpn_prj_hur_husk",
		local_unit = "units/pd2_dlc_born/weapons/wpn_fps_mel_hur/wpn_prj_hur_local",
		icon = "throwing_axe",
		throw_shout = true,
		no_cheat_count = true,
		impact_detonation = true,
		client_authoritative = true,
		add_trail_effect = true,
		throwable = true,
		texture_bundle_folder = "born",
		dlc = "born",
		max_amount = 3,
		anim_global_param = "projectile_four",
		throw_allowed_expire_t = 0.15,
		expire_t = 1.1,
		repeat_expire_t = 0.5
	}
	self.projectiles.wpn_prj_target = {
		name_id = "bm_wpn_prj_target",
		unit = "units/pd2_dlc_pim/weapons/wpn_prj_target/wpn_prj_target",
		unit_dummy = "units/pd2_dlc_pim/weapons/wpn_prj_target/wpn_prj_target_husk",
		local_unit = "units/pd2_dlc_pim/weapons/wpn_prj_target/wpn_prj_target_husk_local",
		icon = "hobby_knife",
		throw_shout = true,
		no_cheat_count = true,
		impact_detonation = true,
		client_authoritative = true,
		add_trail_effect = true,
		throwable = true,
		texture_bundle_folder = "pim",
		dlc = "pim",
		max_amount = 6,
		anim_global_param = "projectile_target",
		throw_allowed_expire_t = 0.1,
		expire_t = 0.8,
		repeat_expire_t = 0.6
	}
	self.projectiles.frag_com = {
		name_id = "bm_grenade_frag_com",
		desc_id = "bm_grenade_frag_com_desc",
		unit = "units/payday2/weapons/wpn_frag_grenade_com/wpn_frag_grenade_com",
		unit_dummy = "units/payday2/weapons/wpn_frag_grenade_com/wpn_frag_grenade_com_husk",
		sprint_unit = "units/payday2/weapons/wpn_frag_grenade_com/wpn_frag_grenade_com_sprint",
		icon = "frag_grenade",
		throwable = true,
		max_amount = 3,
		animation = "throw_grenade_com",
		anim_global_param = "projectile_frag_com",
		throw_allowed_expire_t = 0.1,
		expire_t = 1.1,
		repeat_expire_t = 1.5,
		is_a_grenade = true,
		is_explosive = true,
		dlc = "pd2_clan"
	}
	self.projectiles.fir_com = {
		name_id = "bm_grenade_fir_com",
		desc_id = "bm_grenade_fir_com_desc",
		unit = "units/pd2_dlc_fir/weapons/wpn_fps_gre_white/wpn_third_gre_white",
		unit_dummy = "units/pd2_dlc_fir/weapons/wpn_fps_gre_white/wpn_fps_gre_white_husk",
		sprint_unit = "units/pd2_dlc_fir/weapons/wpn_fps_gre_white/wpn_third_gre_white_sprint",
		icon = "fir_grenade",
		throwable = true,
		max_amount = 6,
		animation = "throw_concussion",
		anim_global_param = "projectile_frag",
		throw_allowed_expire_t = 0.1,
		expire_t = 1.1,
		repeat_expire_t = 1.5,
		is_a_grenade = true,
		dlc = "pd2_clan",
		texture_bundle_folder = "fir"
	}
	self.projectiles.chico_injector = {
		name_id = "bm_ability_chico_injector",
		desc_id = "bm_ability_chico_injector_desc",
		ignore_statistics = true,
		icon = "chico_injector",
		ability = "chico_injector",
		texture_bundle_folder = "chico",
		dlc = "chico",
		base_cooldown = 30,
		max_amount = 1,
		sounds = {
			activate = "perkdeck_activate",
			cooldown = "perkdeck_cooldown_over"
		}
	}
	self.projectiles.launcher_m203 = deep_clone(self.projectiles.launcher_frag)
	self.projectiles.launcher_m203.unit = "units/pd2_dlc_chico/weapons/wpn_launcher_frag_m203/wpn_launcher_frag_m203"
	self.projectiles.launcher_m203.add_trail_effect = true
	self.projectiles.launcher_m203.dlc = "chico"
	self.projectiles.launcher_m203.weapon_id = "contraband_m203"
	self.projectiles.launcher_m203.time_cheat = 0.1
	self.projectiles.smoke_screen_grenade = {
		name_id = "bm_grenade_smoke_screen_grenade",
		desc_id = "bm_grenade_smoke_screen_grenade_desc",
		unit = "units/pd2_dlc_max/weapons/wpn_fps_smoke_screen_grenade/wpn_third_smoke_screen_grenade",
		unit_dummy = "units/pd2_dlc_max/weapons/wpn_fps_smoke_screen_grenade/wpn_fps_smoke_screen_grenade_husk",
		sprint_unit = "units/pd2_dlc_max/weapons/wpn_fps_smoke_screen_grenade/wpn_third_smoke_screen_grenade_sprint",
		icon = "smoke_screen_grenade",
		texture_bundle_folder = "max",
		base_cooldown = 60,
		max_amount = 1,
		is_a_grenade = true,
		throwable = true,
		animation = "throw_grenade_com",
		anim_global_param = "projectile_frag_com",
		no_shouting = true
	}
	self.projectiles.pocket_ecm_jammer = {
		name_id = "bm_grenade_pocket_ecm_jammer",
		desc_id = "bm_grenade_pocket_ecm_jammer_desc",
		ignore_statistics = true,
		icon = "guis/dlcs/joy/textures/pd2/hud_pocket_ecm_jammer",
		texture_bundle_folder = "joy",
		ability = true,
		base_cooldown = 100,
		max_amount = 2,
		sounds = {cooldown = "perkdeck_cooldown_over"}
	}
	self.projectiles.dada_com = {
		name_id = "bm_grenade_dada_com",
		desc_id = "bm_grenade_dada_com_desc",
		unit = "units/pd2_dlc_mtl/weapons/wpn_fps_thr_dada/wpn_third_thr_dada",
		unit_dummy = "units/pd2_dlc_mtl/weapons/wpn_fps_thr_dada/wpn_fps_thr_dada_husk",
		icon = "dada_com",
		throwable = true,
		max_amount = 3,
		animation = "throw_dada",
		anim_global_param = "projectile_dada",
		throw_allowed_expire_t = 0.1,
		expire_t = 1.3,
		repeat_expire_t = 1.5,
		is_a_grenade = true,
		is_explosive = true,
		dlc = "pd2_clan",
		texture_bundle_folder = "mtl"
	}
	self.projectiles.tag_team = {
		name_id = "bm_grenade_tag_team",
		desc_id = "bm_grenade_tag_team_desc",
		icon = "tag_team",
		ability = "tag_team",
		texture_bundle_folder = "ecp",
		max_amount = 1,
		base_cooldown = 60,
		sounds = {
			activate = "perkdeck_activate",
			cooldown = "perkdeck_cooldown_over"
		}
	}
	self.projectiles.ecp_arrow = {
		unit = "units/pd2_dlc_ecp/weapons/wpn_prj_ecp_arrow/wpn_prj_ecp_arrow",
		local_unit = "units/pd2_dlc_ecp/weapons/wpn_prj_ecp_arrow/wpn_prj_ecp_arrow_local",
		weapon_id = "ecp",
		no_cheat_count = true,
		impact_detonation = true,
		client_authoritative = true
	}
	self.projectiles.ecp_arrow_poison = {
		unit = "units/pd2_dlc_ecp/weapons/wpn_prj_ecp_arrow_poison/wpn_prj_ecp_arrow_poison",
		local_unit = "units/pd2_dlc_ecp/weapons/wpn_prj_ecp_arrow_poison/wpn_prj_ecp_arrow_poison_local",
		weapon_id = "ecp",
		no_cheat_count = true,
		impact_detonation = true,
		client_authoritative = true
	}
	self.projectiles.ecp_arrow_exp = {
		unit = "units/pd2_dlc_ecp/weapons/wpn_prj_ecp_arrow_exp/wpn_prj_ecp_arrow_exp",
		local_unit = "units/pd2_dlc_ecp/weapons/wpn_prj_ecp_arrow_exp/wpn_prj_ecp_arrow_exp_local",
		weapon_id = "ecp",
		no_cheat_count = true,
		impact_detonation = true,
		client_authoritative = true,
		is_explosive = true
	}
	self.projectiles.damage_control = {
		name_id = "bm_grenade_damage_control",
		desc_id = "bm_grenade_damage_control_desc",
		icon = "damage_control",
		ability = true,
		texture_bundle_folder = "myh",
		max_amount = 1,
		base_cooldown = 10,
		sounds = {cooldown = "perkdeck_cooldown_over"}
	}
	self._projectiles_index = {
		"frag",
		"launcher_frag",
		"rocket_frag",
		"molotov",
		"launcher_incendiary",
		"launcher_frag_m32",
		"west_arrow",
		"west_arrow_exp",
		"dynamite",
		"bow_poison_arrow",
		"crossbow_arrow",
		"crossbow_poison_arrow",
		"crossbow_arrow_exp",
		"wpn_prj_four",
		"wpn_prj_ace",
		"wpn_prj_jav",
		"arblast_arrow",
		"arblast_poison_arrow",
		"arblast_arrow_exp",
		"frankish_arrow",
		"frankish_poison_arrow",
		"frankish_arrow_exp",
		"long_arrow",
		"long_poison_arrow",
		"long_arrow_exp",
		"launcher_incendiary_m32",
		"launcher_frag_china",
		"launcher_incendiary_china",
		"wpn_prj_hur",
		"wpn_prj_target",
		"frag_com",
		"concussion",
		"launcher_frag_arbiter",
		"launcher_incendiary_arbiter",
		"chico_injector",
		"launcher_m203",
		"rocket_ray_frag",
		"fir_com",
		"smoke_screen_grenade",
		"dada_com",
		"tag_team",
		"ecp_arrow",
		"ecp_arrow_exp",
		"ecp_arrow_poison",
		"pocket_ecm_jammer",
		"launcher_frag_slap",
		"launcher_incendiary_slap"
	}
	local free_dlcs = tweak_data:free_dlc_list()

	for _, data in pairs(self.projectiles) do
		if free_dlcs[data.dlc] then
			data.dlc = nil
		end
	end

	self:_add_desc_from_name_macro(self.projectiles)
end

function BlackMarketTweakData:get_projectiles_index()
	return self._projectiles_index
end

function BlackMarketTweakData:get_index_from_projectile_id(projectile_id)
	for index, entry_name in ipairs(self._projectiles_index) do
		if entry_name == projectile_id then
			return index
		end
	end

	return 0
end

function BlackMarketTweakData:get_projectile_name_from_index(index)
	return self._projectiles_index[index]
end

