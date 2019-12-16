UpgradesTweakData = UpgradesTweakData or class()

function UpgradesTweakData:_init_pd2_values()
	self:_init_value_tables()

	self.values.rep_upgrades = {
		classes = {
			"rep_upgrade"
		},
		values = {
			2
		}
	}
	self.values.player.body_armor = {
		armor = {
			0,
			3,
			4,
			5,
			7,
			9,
			15
		},
		movement = {
			1.05,
			1.025,
			1,
			0.95,
			0.75,
			0.65,
			0.575
		},
		concealment = {
			30,
			26,
			23,
			21,
			18,
			12,
			1
		},
		dodge = {
			0.05,
			-0.05,
			-0.1,
			-0.15,
			-0.2,
			-0.25,
			-0.55
		},
		damage_shake = {
			1,
			0.96,
			0.92,
			0.85,
			0.8,
			0.7,
			0.5
		},
		stamina = {
			1.025,
			1,
			0.95,
			0.9,
			0.85,
			0.8,
			0.7
		}
	}

	if _G.IS_VR then
		self.values.player.body_armor.armor = {
			0,
			3,
			4,
			5,
			7,
			9,
			15
		}
		self.values.player.body_armor.dodge = {
			0.05,
			-0.05,
			-0.1,
			-0.15,
			-0.2,
			-0.25,
			-0.55
		}
	end

	self.values.player.body_armor.skill_ammo_mul = {
		1,
		1.02,
		1.04,
		1.06,
		1.8,
		1.1,
		1.12
	}
	self.values.player.ballistic_vest_concealment = {
		4
	}
	self.values.player.body_armor.skill_max_health_store = {
		14,
		13.5,
		12.5,
		12,
		10.5,
		9.5,
		4
	}
	self.values.player.body_armor.skill_kill_change_regenerate_speed = {
		14,
		13.5,
		12.5,
		12,
		10.5,
		9.5,
		4
	}
	self.values.player.special_enemy_highlight = {
		true
	}
	self.values.player.hostage_trade = {
		true
	}
	self.values.player.sec_camera_highlight = {
		true
	}
	self.values.player.sec_camera_highlight_mask_off = {
		true
	}
	self.values.player.special_enemy_highlight_mask_off = {
		true
	}
	self.values.player.super_syndrome = {
		1
	}
	self.values.player.stability_increase_bonus_1 = {
		2
	}
	self.values.player.stability_increase_bonus_2 = {
		4
	}
	self.values.player.not_moving_accuracy_increase = {
		4
	}
	self.values.player.hip_fire_accuracy_inc = {
		3
	}
	self.values.player.melee_damage_stacking = {
		{
			max_multiplier = 16,
			melee_multiplier = 1
		}
	}
	self.ammo_bag_base = 4
	self.ecm_jammer_base_battery_life = 20
	self.ecm_jammer_base_low_battery_life = 8
	self.ecm_jammer_base_range = 2500
	self.ecm_feedback_min_duration = 15
	self.ecm_feedback_max_duration = 20
	self.ecm_feedback_interval = 1.5
	self.sentry_gun_base_ammo = 100
	self.sentry_gun_base_armor = 10
	self.doctor_bag_base = 2
	self.first_aid_kit = {
		revived_damage_reduction = {
			{
				0.7,
				5
			},
			{
				0.2,
				5
			}
		}
	}
	self.grenade_crate_base = 3
	self.max_grenade_amount = 3
	self.bodybag_crate_base = 3
	self.cop_hurt_alert_radius_whisper = 600
	self.cop_hurt_alert_radius = 400
	self.drill_alert_radius = 2500
	self.taser_malfunction_min = 5
	self.taser_malfunction_max = 30
	self.counter_taser_damage = 0.5
	self.morale_boost_speed_bonus = 1.2
	self.morale_boost_suppression_resistance = 1
	self.morale_boost_time = 10
	self.morale_boost_reload_speed_bonus = 1.2
	self.morale_boost_base_cooldown = 3.5
	self.max_weapon_dmg_mul_stacks = 4
	self.max_melee_weapon_dmg_mul_stacks = 1
	self.hostage_near_player_radius = 1000
	self.hostage_near_player_check_t = 0.5
	self.hostage_near_player_multiplier = 1.25
	self.hostage_max_num = {
		damage_dampener = 1,
		health_regen = 1,
		stamina = 4,
		health = 4
	}
	self.on_headshot_dealt_cooldown = 2
	self.on_killshot_cooldown = 1
	self.on_damage_dealt_cooldown = 2
	self.close_combat_distance = 1800
	self.killshot_close_panic_range = 900
	self.berserker_movement_speed_multiplier = 0.4
	self.weapon_cost_multiplier = {
		akimbo = 1.4
	}
	self.weapon_movement_penalty = {
		lmg = 1,
		minigun = 1
	}
	self.explosive_bullet = {
		curve_pow = 0.5,
		player_dmg_mul = 0.1,
		range = 200
	}
	self.explosive_bullet.feedback_range = self.explosive_bullet.range
	self.explosive_bullet.camera_shake_max_mul = 2
	self.values.player.crime_net_deal = {
		0.9,
		0.8
	}
	self.values.player.corpse_alarm_pager_bluff = {
		true
	}
	self.values.player.marked_enemy_extra_damage = {
		true
	}
	self.values.player.marked_enemy_damage_mul = 1.15
	self.values.player.marked_distance_mul = {
		20
	}
	self.values.cable_tie.interact_speed_multiplier = {
		0.25
	}
	self.values.cable_tie.quantity_1 = {
		4
	}
	self.values.cable_tie.can_cable_tie_doors = {
		true
	}
	self.values.temporary.combat_medic_damage_multiplier = {
		{
			1.25,
			10
		},
		{
			1.25,
			15
		}
	}
	self.values.player.revive_health_boost = {
		1
	}
	self.revive_health_multiplier = {
		1.3
	}
	self.values.temporary.revived_damage_resist = {
		{
			0.7,
			10
		}
	}
	self.values.temporary.increased_movement_speed = {
		{
			1.3,
			10
		}
	}
	self.values.temporary.swap_weapon_faster = {
		{
			2,
			10
		}
	}
	self.values.temporary.reload_weapon_faster = {
		{
			2,
			10
		}
	}
	self.values.player.melee_kill_increase_reload_speed = {
		{
			1.5,
			10
		}
	}
	self.values.player.civ_harmless_bullets = {
		true
	}
	self.values.player.civ_harmless_melee = {
		true
	}
	self.values.player.civ_calming_alerts = {
		true
	}
	self.values.player.civ_intimidation_mul = {
		1.5
	}
	self.values.team.pistol.recoil_multiplier = {
		0.75
	}
	self.values.team.akimbo.recoil_multiplier = self.values.team.pistol.recoil_multiplier
	self.values.team.weapon.recoil_multiplier = {
		0.5
	}
	self.values.team.pistol.suppression_recoil_multiplier = self.values.team.pistol.recoil_multiplier
	self.values.team.akimbo.suppression_recoil_multiplier = self.values.team.akimbo.recoil_multiplier
	self.values.team.weapon.suppression_recoil_multiplier = self.values.team.weapon.recoil_multiplier
	self.values.weapon.enter_steelsight_speed_multiplier = {
		2
	}
	self.values.player.assets_cost_multiplier = {
		0.5
	}
	self.values.player.additional_assets = {
		true
	}
	self.values.player.stamina_multiplier = {
		2
	}
	self.values.team.stamina.multiplier = {
		1.5
	}
	self.values.team.damage = {
		hostage_absorption = {
			0.05
		},
		hostage_absorption_limit = 8
	}
	self.values.player.intimidate_enemies = {
		true
	}
	self.values.player.intimidate_range_mul = {
		1.5
	}
	self.values.player.intimidate_aura = {
		1000
	}
	self.values.player.civilian_reviver = {
		true
	}
	self.values.player.civilian_gives_ammo = {
		true
	}
	self.values.player.buy_cost_multiplier = {
		0.9,
		0.7
	}
	self.values.player.sell_cost_multiplier = {
		1.25
	}
	self.values.player.armor_carry_bonus = {
		1.01
	}
	self.values.doctor_bag.quantity = {
		1
	}
	self.values.doctor_bag.amount_increase = {
		2
	}
	self.values.player.convert_enemies = {
		true
	}
	self.values.player.convert_enemies_max_minions = {
		1,
		2
	}
	self.values.player.convert_enemies_health_multiplier = {
		0.45
	}
	self.values.player.convert_enemies_damage_multiplier = {
		0.65,
		1
	}
	self.values.player.xp_multiplier = {
		1.15
	}
	self.values.team.xp.multiplier = {
		1.3
	}
	self.values.pistol.reload_speed_multiplier = {
		1.5
	}
	self.values.akimbo.reload_speed_multiplier = self.values.pistol.reload_speed_multiplier
	self.values.pistol.damage_addend = {
		0.5,
		1.5
	}
	self.values.pistol.damage_multiplier = {
		1.5
	}
	self.values.pistol.magazine_capacity_inc = {
		5
	}
	self.values.pistol.stacked_accuracy_bonus = {
		{
			max_stacks = 4,
			accuracy_bonus = 0.9,
			max_time = 10
		}
	}
	self.values.pistol.stacking_hit_damage_multiplier = {
		{
			max_stacks = 1,
			max_time = 2,
			damage_bonus = 2.2
		},
		{
			max_stacks = 1,
			max_time = 4,
			damage_bonus = 2.2
		}
	}
	self.values.assault_rifle.reload_speed_multiplier = {
		1.15
	}
	self.values.assault_rifle.move_spread_multiplier = {
		0.5
	}
	self.values.player.messiah_revive_from_bleed_out = {
		1
	}
	self.values.player.recharge_messiah = {
		1
	}
	self.values.pistol.spread_multiplier = {
		0.9
	}
	self.values.akimbo.spread_multiplier = self.values.pistol.spread_multiplier
	self.values.pistol.swap_speed_multiplier = {
		1.5
	}
	self.values.pistol.fire_rate_multiplier = {
		1.5
	}
	self.values.player.revive_interaction_speed_multiplier = {
		0.5
	}
	self.values.cooldown.long_dis_revive = {
		{
			1,
			20
		}
	}
	self.values.doctor_bag.interaction_speed_multiplier = {
		0.8
	}
	self.values.team.stamina.passive_multiplier = {
		1.5,
		1.3
	}
	self.values.player.passive_intimidate_range_mul = {
		1.25
	}
	self.values.team.health.passive_multiplier = {
		1.1
	}
	self.values.player.passive_convert_enemies_damage_multiplier = {
		1.15
	}
	self.values.player.convert_enemies_interaction_speed_multiplier = {
		0.35
	}
	self.values.player.empowered_intimidation_mul = {
		3
	}
	self.values.player.passive_assets_cost_multiplier = {
		0.5
	}
	self.values.player.escape_taser = {
		2
	}
	self.values.player.suppression_multiplier = {
		1.75
	}
	self.values.carry.movement_speed_multiplier = {
		1.5
	}
	self.values.carry.throw_distance_multiplier = {
		1.5
	}
	self.values.player.no_ammo_cost = {
		true,
		true
	}
	self.values.player.non_special_melee_multiplier = {
		2
	}
	self.values.player.melee_damage_multiplier = {
		2
	}

	if _G.IS_VR then
		self.values.player.non_special_melee_multiplier = {
			2
		}
		self.values.player.melee_damage_multiplier = {
			2
		}
	end

	self.values.player.primary_weapon_when_downed = {
		true
	}
	self.values.player.armor_regen_timer_multiplier = {
		0.85
	}
	self.values.temporary.dmg_multiplier_outnumbered = {
		{
			1.15,
			7
		}
	}
	self.values.temporary.dmg_dampener_outnumbered = {
		{
			0.9,
			7
		}
	}
	self.values.player.extra_ammo_multiplier = {
		1.25
	}
	self.values.player.pick_up_ammo_multiplier = {
		1.35,
		1.75
	}
	self.values.player.regain_throwable_from_ammo = {
		{
			chance = 0.05,
			chance_inc = 1.01
		}
	}
	self.values.player.damage_shake_multiplier = {
		0.5
	}
	self.values.player.bleed_out_health_multiplier = {
		1.5
	}
	self.values.shotgun.recoil_multiplier = {
		0.75
	}
	self.values.shotgun.damage_multiplier = {
		1.05,
		1.15
	}
	self.values.ammo_bag.quantity = {
		1
	}
	self.values.ammo_bag.ammo_increase = {
		2
	}
	self.values.shotgun.reload_speed_multiplier = {
		1.15,
		1.5
	}
	self.values.shotgun.enter_steelsight_speed_multiplier = {
		2.25
	}
	self.values.saw.extra_ammo_multiplier = {
		1.5
	}
	self.values.player.flashbang_multiplier = {
		0.25,
		0.25
	}
	self.values.shotgun.hip_fire_spread_multiplier = {
		0.8
	}
	self.values.pistol.hip_fire_spread_multiplier = {
		0.8
	}
	self.values.assault_rifle.hip_fire_spread_multiplier = {
		0.8
	}
	self.values.smg.hip_fire_spread_multiplier = {
		0.8
	}
	self.values.smg.zoom_increase = {
		2
	}
	self.values.saw.hip_fire_spread_multiplier = {
		0.8
	}
	self.values.player.saw_speed_multiplier = {
		0.95,
		0.65
	}
	self.values.saw.lock_damage_multiplier = {
		1.2,
		1.4
	}
	self.values.saw.enemy_slicer = {
		7
	}
	self.values.player.melee_damage_health_ratio_multiplier = {
		2.5
	}
	self.values.player.damage_health_ratio_multiplier = {
		1
	}
	self.player_damage_health_ratio_threshold = 0.5
	self.values.player.shield_knock = {
		true
	}
	self.values.temporary.overkill_damage_multiplier = {
		{
			1.75,
			20
		}
	}
	self.values.player.overkill_all_weapons = {
		true
	}
	self.values.temporary.unseen_strike = {
		{
			1.35,
			6
		},
		{
			1.35,
			18
		}
	}
	self.values.player.passive_suppression_multiplier = {
		1.1,
		1.2
	}
	self.values.player.passive_health_multiplier = {
		1.1,
		1.2,
		1.4,
		1.8
	}
	self.values.weapon.passive_damage_multiplier = {
		1.05
	}
	self.values.weapon.knock_down = {
		0.05,
		0.2
	}
	self.values.weapon.automatic_head_shot_add = {
		0.3,
		0.9
	}
	self.values.assault_rifle.enter_steelsight_speed_multiplier = {
		2
	}
	self.values.assault_rifle.zoom_increase = {
		2
	}
	self.values.player.crafting_weapon_multiplier = {
		0.9
	}
	self.values.player.crafting_mask_multiplier = {
		0.9
	}
	self.values.trip_mine.can_switch_on_off = {
		true
	}
	self.values.player.drill_speed_multiplier = {
		0.85,
		0.7
	}
	self.values.player.drill_melee_hit_restart_chance = {
		true
	}
	self.values.player.drill_restart_chance = {
		true
	}
	self.values.player.trip_mine_deploy_time_multiplier = {
		0.8,
		0.6
	}
	self.values.trip_mine.sensor_toggle = {
		true
	}
	self.values.trip_mine.fire_trap = {
		{
			0,
			1
		},
		{
			10,
			1.5
		}
	}
	self.values.player.drill_fix_interaction_speed_multiplier = {
		0.75
	}
	self.values.player.drill_autorepair_1 = {
		0.1
	}
	self.values.player.drill_autorepair_2 = {
		0.2
	}
	self.values.player.sentry_gun_deploy_time_multiplier = {
		0.5
	}
	self.values.sentry_gun.armor_multiplier = {
		2.5
	}
	self.values.weapon.single_spread_multiplier = {
		0.8
	}
	self.values.assault_rifle.recoil_multiplier = {
		0.75
	}
	self.sharpshooter_categories = {
		"assault_rifle",
		"smg",
		"snp"
	}
	self.values.player.taser_malfunction = {
		{
			interval = 1,
			chance_to_trigger = 0.3
		}
	}
	self.values.player.taser_self_shock = {
		true
	}
	self.values.sentry_gun.spread_multiplier = {
		2
	}
	self.values.sentry_gun.rot_speed_multiplier = {
		2
	}
	self.values.player.interacting_damage_multiplier = {
		0.5
	}
	self.values.player.steelsight_when_downed = {
		true
	}
	self.values.player.drill_alert_rad = {
		900
	}
	self.values.player.silent_drill = {
		true
	}
	self.values.sentry_gun.extra_ammo_multiplier = {
		2
	}
	self.values.sentry_gun.shield = {
		true
	}
	self.values.trip_mine.explosion_size_multiplier_1 = {
		1.3
	}
	self.values.trip_mine.explosion_size_multiplier_2 = {
		1.7
	}
	self.values.player.trip_mine_shaped_charge = {
		true
	}
	self.values.sentry_gun.quantity = {
		1,
		3
	}
	self.values.sentry_gun.damage_multiplier = {
		2.5
	}
	self.values.weapon.clip_ammo_increase = {
		5,
		15
	}
	self.values.player.armor_multiplier = {
		1.3
	}
	self.values.team.armor.regen_time_multiplier = {
		0.75
	}
	self.values.player.passive_crafting_weapon_multiplier = {
		0.99,
		0.96,
		0.91
	}
	self.values.player.passive_crafting_mask_multiplier = {
		0.99,
		0.96,
		0.91
	}
	self.values.weapon.passive_recoil_multiplier = {
		0.95,
		0.9
	}
	self.values.weapon.passive_headshot_damage_multiplier = {
		1.25
	}
	self.values.player.passive_armor_multiplier = {
		1.1,
		1.25
	}
	self.values.team.armor.passive_regen_time_multiplier = {
		0.9
	}
	self.values.player.small_loot_multiplier = {
		1.3
	}
	self.values.player.stamina_regen_timer_multiplier = {
		0.75
	}
	self.values.player.stamina_regen_multiplier = {
		1.25
	}
	self.values.player.run_dodge_chance = {
		0.1
	}
	self.values.player.run_speed_multiplier = {
		1.25
	}
	self.values.player.fall_damage_multiplier = {
		0.25
	}
	self.values.player.fall_health_damage_multiplier = {
		0
	}
	self.values.player.respawn_time_multiplier = {
		0.5
	}
	self.values.weapon.special_damage_taken_multiplier = {
		1.05
	}
	self.values.player.buy_bodybags_asset = {
		true
	}
	self.values.player.corpse_dispose = {
		true
	}
	self.values.player.corpse_dispose_amount = {
		1,
		2
	}
	self.values.carry.interact_speed_multiplier = {
		0.75,
		0.25
	}
	self.values.player.suspicion_multiplier = {
		0.75
	}
	self.values.player.camouflage_bonus = {
		0.85,
		0.65
	}
	self.values.temporary.damage_speed_multiplier = {
		{
			1.3,
			5
		}
	}
	self.values.player.team_damage_speed_multiplier_send = {
		true
	}
	self.values.temporary.team_damage_speed_multiplier_received = {
		{
			1.3,
			5
		}
	}
	self.values.player.walk_speed_multiplier = {
		1.25
	}
	self.values.player.crouch_speed_multiplier = {
		1.1,
		1.2
	}
	self.values.player.silent_kill = {
		25
	}
	self.values.player.melee_knockdown_mul = {
		1.5
	}
	self.values.player.damage_dampener = {
		0.95
	}
	self.values.player.melee_damage_dampener = {
		0.5
	}
	self.values.smg.reload_speed_multiplier = {
		1.15
	}
	self.values.smg.fire_rate_multiplier = {
		1.2
	}
	self.values.player.additional_lives = {
		1,
		3
	}
	self.values.player.cheat_death_chance = {
		0.15,
		0.45
	}
	self.values.ecm_jammer.can_activate_feedback = {
		true
	}
	self.values.ecm_jammer.feedback_duration_boost = {
		1.25
	}
	self.values.ecm_jammer.interaction_speed_multiplier = {
		0
	}
	self.values.weapon.silencer_damage_multiplier = {
		1.15,
		1.3
	}
	self.values.weapon.armor_piercing_chance_silencer = {
		0.2,
		0.4
	}
	self.values.ecm_jammer.duration_multiplier = {
		true
	}
	self.values.ecm_jammer.duration_multiplier_2 = {
		true
	}
	self.values.ecm_jammer.can_open_sec_doors = {
		true
	}
	self.values.player.pick_lock_easy = {
		true
	}
	self.values.player.pick_lock_easy_speed_multiplier = {
		0.5
	}
	self.values.player.pick_lock_hard = {
		true
	}
	self.values.weapon.silencer_recoil_multiplier = {
		0.5
	}
	self.values.weapon.silencer_spread_multiplier = {
		0.5
	}
	self.values.weapon.silencer_enter_steelsight_speed_multiplier = {
		2
	}
	self.values.player.loot_drop_multiplier = {
		1.5,
		3
	}
	self.values.ecm_jammer.quantity = {
		1,
		3
	}
	self.values.ecm_jammer.feedback_duration_boost_2 = {
		1.25
	}
	self.values.ecm_jammer.affects_pagers = {
		true
	}
	self.values.player.can_strafe_run = {
		true
	}
	self.values.player.can_free_run = {
		true
	}
	self.values.ecm_jammer.affects_cameras = {
		true
	}
	self.values.player.passive_dodge_chance = {
		0.15,
		0.3,
		0.45
	}
	self.values.weapon.passive_swap_speed_multiplier = {
		1.8,
		2
	}
	self.values.player.passive_concealment_modifier = {
		1
	}
	self.values.player.passive_armor_movement_penalty_multiplier = {
		0.75
	}
	self.values.player.passive_loot_drop_multiplier = {
		1.1
	}
	self.values.player.automatic_mag_increase = {
		15
	}
	self.values.weapon.armor_piercing_chance = {
		0.25
	}
	self.values.lmg.recoil_multiplier = {
		0.75
	}
	self.values.lmg.enter_steelsight_speed_multiplier = {
		2
	}
	self.values.lmg.reload_speed_multiplier = {
		1.25
	}
	self.values.lmg.move_spread_multiplier = {
		0.5
	}
	self.values.lmg.hip_fire_spread_multiplier = {
		0.8
	}
	self.values.lmg.hip_fire_damage_multiplier = {
		1.2
	}
	self.values.lmg.zoom_increase = {
		2
	}
	self.values.snp.recoil_multiplier = {
		0.75
	}
	self.values.snp.enter_steelsight_speed_multiplier = {
		2
	}
	self.values.snp.reload_speed_multiplier = {
		1.15
	}
	self.values.snp.move_spread_multiplier = {
		0.5
	}
	self.values.snp.hip_fire_spread_multiplier = {
		0.8
	}
	self.values.snp.hip_fire_damage_multiplier = {
		1.2
	}
	self.values.snp.zoom_increase = {
		2
	}
	self.values.player.silencer_concealment_increase = {
		1
	}
	self.values.player.silencer_concealment_penalty_decrease = {
		2
	}
	self.values.player.run_and_shoot = {
		true
	}
	self.values.player.run_and_reload = {
		true
	}
	self.values.player.morale_boost = {
		true
	}
	self.values.player.electrocution_resistance_multiplier = {
		0.25
	}
	self.values.player.single_shot_accuracy_inc = {
		0.8
	}
	self.values.player.deploy_interact_faster = {
		0.5
	}
	self.values.player.second_deployable = {
		true
	}
	self.values.player.armor_depleted_stagger_shot = {
		0,
		6
	}
	self.values.player.revived_health_regain = {
		1.4
	}
	self.values.player.head_shot_ammo_return = {
		{
			headshots = 3,
			ammo = 1,
			time = 6
		},
		{
			headshots = 2,
			ammo = 1,
			time = 6
		}
	}
	self.values.player.concealment_modifier = {
		5,
		10,
		15
	}
	self.values.sentry_gun.armor_multiplier2 = {
		1.25
	}
	self.values.sentry_gun.cost_reduction = {
		2,
		3
	}
	self.values.sentry_gun.less_noisy = {
		true
	}
	self.values.sentry_gun.ap_bullets = {
		true
	}
	self.values.sentry_gun.fire_rate_reduction = {
		4
	}
	self.values.saw.armor_piercing_chance = {
		1
	}
	self.values.saw.swap_speed_multiplier = {
		1.8
	}
	self.values.saw.reload_speed_multiplier = {
		1.5
	}
	self.values.saw.ignore_shields = {
		true
	}
	self.values.saw.panic_when_kill = {
		{
			chance = 0.5,
			area = 1000,
			amount = 200
		}
	}
	self.values.team.health.hostage_multiplier = {
		1.06
	}
	self.values.team.stamina.hostage_multiplier = {
		1.12
	}
	self.values.player.minion_master_speed_multiplier = {
		1.1
	}
	self.values.player.minion_master_health_multiplier = {
		1.3
	}
	self.values.player.mark_enemy_time_multiplier = {
		2
	}
	self.values.player.critical_hit_chance = {
		0.25,
		0.5
	}
	self.values.player.melee_kill_snatch_pager_chance = {
		0.25
	}
	self.values.player.detection_risk_add_crit_chance = {
		{
			0.03,
			3,
			"below",
			35,
			0.3
		},
		{
			0.03,
			1,
			"below",
			35,
			0.3
		}
	}
	self.values.player.detection_risk_add_dodge_chance = {
		{
			0.01,
			3,
			"below",
			35,
			0.1
		},
		{
			0.01,
			1,
			"below",
			35,
			0.1
		}
	}
	self.values.player.detection_risk_damage_multiplier = {
		{
			0.05,
			7,
			"above",
			40
		}
	}
	self.values.player.unseen_increased_crit_chance = {
		{
			min_time = 4,
			max_duration = 6,
			crit_chance = 1.35
		},
		{
			min_time = 4,
			max_duration = 18,
			crit_chance = 1.35
		}
	}
	self.values.shotgun.steelsight_accuracy_inc = {
		0.6
	}
	self.values.shotgun.steelsight_range_inc = {
		1.5
	}
	self.values.shotgun.hip_run_and_shoot = {
		true
	}
	self.values.shotgun.hip_rate_of_fire = {
		1.35
	}
	self.values.shotgun.magazine_capacity_inc = {
		15
	}
	self.values.player.overkill_health_to_damage_multiplier = {
		0.66
	}
	self.values.player.tased_recover_multiplier = {
		0.5
	}
	self.values.player.secured_bags_speed_multiplier = {
		1.02
	}
	self.values.temporary.no_ammo_cost_buff = {
		{
			true,
			60
		}
	}
	self.values.player.secured_bags_money_multiplier = {
		1.02
	}
	self.values.pistol.stacking_hit_expire_t = {
		6,
		20
	}
	self.values.pistol.zoom_increase = {
		2
	}
	self.values.carry.movement_penalty_nullifier = {
		true
	}
	self.values.temporary.berserker_damage_multiplier = {
		{
			1,
			3
		},
		{
			1,
			6
		}
	}
	self.values.player.berserker_no_ammo_cost = {
		true
	}
	self.values.player.hostage_health_regen_addend = {
		0.015,
		0.045
	}
	self.values.player.carry_sentry_and_trip = {
		true
	}
	self.values.player.tier_armor_multiplier = {
		1.05,
		1.1,
		1.2,
		1.3,
		1.15,
		1.35
	}
	self.values.player.double_drop = {
		6
	}
	self.values.player.increased_pickup_area = {
		1.5
	}
	self.values.player.weapon_accuracy_increase = {
		2
	}
	self.values.player.weapon_movement_stability = {
		0.8
	}
	self.values.shotgun.hip_fire_damage_multiplier = {
		1.2
	}
	self.values.pistol.hip_fire_damage_multiplier = {
		1.2
	}
	self.values.assault_rifle.hip_fire_damage_multiplier = {
		1.2
	}
	self.values.smg.hip_fire_damage_multiplier = {
		1.2
	}
	self.values.saw.hip_fire_damage_multiplier = {
		1.2
	}
	self.values.shotgun.consume_no_ammo_chance = {
		0.01,
		0.03
	}
	self.values.player.add_armor_stat_skill_ammo_mul = {
		true
	}
	self.values.saw.melee_knockdown_mul = {
		1.75
	}
	self.values.shotgun.melee_knockdown_mul = {
		1.75
	}
	self.values.player.assets_cost_multiplier_b = {
		0.5
	}
	self.values.player.premium_contract_cost_multiplier = {
		0.5
	}
	self.values.player.morale_boost_cooldown_multiplier = {
		0.5
	}
	self.values.player.level_interaction_timer_multiplier = {
		{
			0.01,
			10
		}
	}
	self.values.team.player.clients_buy_assets = {
		true
	}
	self.values.player.steelsight_normal_movement_speed = {
		true
	}
	self.values.team.weapon.move_spread_multiplier = {
		1.1
	}
	self.values.team.player.civ_intimidation_mul = {
		1.15
	}
	self.values.sentry_gun.can_revive = {
		true
	}
	self.values.sentry_gun.can_reload = {
		true
	}
	self.sentry_gun_reload_ratio = 1
	self.values.weapon.modded_damage_multiplier = {
		1.1
	}
	self.values.weapon.modded_spread_multiplier = {
		0.9
	}
	self.values.weapon.modded_recoil_multiplier = {
		0.9
	}
	self.values.sentry_gun.armor_piercing_chance = {
		0.15
	}
	self.values.sentry_gun.armor_piercing_chance_2 = {
		0.05
	}
	self.values.weapon.armor_piercing_chance_2 = {
		0.05
	}
	self.values.player.resist_firing_tased = {
		true
	}
	self.values.player.crouch_dodge_chance = {
		0.05,
		0.15
	}
	self.values.player.climb_speed_multiplier = {
		1.2,
		1.75
	}
	self.values.player.ap_bullets = {
		true
	}
	self.values.team.xp.stealth_multiplier = {
		1.5
	}
	self.values.team.cash.stealth_money_multiplier = {
		1.5
	}
	self.values.team.cash.stealth_bags_multiplier = {
		1.5
	}
	self.values.player.tape_loop_duration = {
		10,
		20
	}
	self.values.player.tape_loop_interact_distance_mul = {
		1.4
	}
	self.values.player.buy_spotter_asset = {
		true
	}
	self.values.player.close_to_hostage_boost = {
		true
	}
	self.values.trip_mine.sensor_highlight = {
		true
	}
	self.values.player.on_zipline_dodge_chance = {
		0.15
	}
	self.values.player.movement_speed_multiplier = {
		1.1
	}
	self.values.player.level_2_armor_addend = {
		2
	}
	self.values.player.level_3_armor_addend = {
		2
	}
	self.values.player.level_4_armor_addend = {
		2
	}
	self.values.player.level_2_dodge_addend = {
		0.05,
		0.15,
		0.25
	}
	self.values.player.level_3_dodge_addend = {
		0.05,
		0.15,
		0.25
	}
	self.values.player.level_4_dodge_addend = {
		0.05,
		0.15,
		0.25
	}
	self.values.player.damage_shake_addend = {
		1
	}
	self.values.player.melee_concealment_modifier = {
		2
	}
	self.values.player.melee_sharp_damage_multiplier = {
		3
	}
	self.values.team.armor.multiplier = {
		1.05
	}
	self.values.player.armor_regen_timer_multiplier_passive = {
		0.9
	}
	self.values.player.armor_regen_timer_multiplier_tier = {
		0.9
	}
	self.values.player.armor_regen_time_mul = {
		0.85
	}
	self.values.player.camouflage_multiplier = {
		0.85
	}
	self.values.player.uncover_multiplier = {
		1.15
	}
	self.values.player.passive_xp_multiplier = {
		1.45
	}
	self.values.player.pick_up_ammo_multiplier_2 = {
		1.3
	}
	self.values.team.damage_dampener.team_damage_reduction = {
		0.92
	}
	self.values.team.damage_dampener.hostage_multiplier = {
		0.92
	}
	self.values.player.level_2_armor_multiplier = {
		1.2,
		1.4,
		1.65
	}
	self.values.player.level_3_armor_multiplier = {
		1.2,
		1.4,
		1.65
	}
	self.values.player.level_4_armor_multiplier = {
		1.2,
		1.4,
		1.65
	}
	self.values.player.passive_health_regen = {
		0.03
	}
	self.values.player.healing_reduction = {
		0.25,
		1
	}
	self.values.player.health_damage_reduction = {
		0.9,
		0.75
	}
	self.values.player.max_health_reduction = {
		0.3
	}
	self.values.cable_tie.quantity_2 = {
		4
	}
	self.ecm_feedback_retrigger_interval = 240
	self.ecm_feedback_retrigger_chance = 1
	self.values.player.revive_damage_reduction_level = {
		1,
		2
	}
	self.values.ecm_jammer.can_retrigger = {
		true
	}
	self.values.player.panic_suppression = {
		true
	}
	self.values.akimbo.extra_ammo_multiplier = {
		1.5,
		2
	}
	self.values.akimbo.damage_multiplier = {
		1.5,
		3
	}
	self.values.akimbo.recoil_multiplier = {
		2.5,
		2,
		1.5
	}
	self.values.akimbo.passive_recoil_multiplier = {
		2.5,
		2
	}
	self.values.akimbo.clip_ammo_increase = self.values.weapon.clip_ammo_increase
	self.values.player.perk_armor_regen_timer_multiplier = {
		0.95,
		0.85,
		0.75,
		0.65,
		0.55
	}
	self.values.player.perk_armor_loss_multiplier = {
		0.95,
		0.9,
		0.85,
		0.8
	}
	self.values.player.headshot_regen_armor_bonus = {
		0.5,
		2.5
	}
	self.values.bodybags_bag.quantity = {
		1
	}
	self.values.first_aid_kit.quantity = {
		7,
		10
	}
	self.values.first_aid_kit.deploy_time_multiplier = {
		0.5
	}
	self.values.first_aid_kit.damage_reduction_upgrade = {
		true
	}
	self.values.first_aid_kit.downs_restore_chance = {
		0.1
	}
	self.values.first_aid_kit.first_aid_kit_auto_recovery = {
		500
	}
	self.values.temporary.first_aid_damage_reduction = {
		{
			0.9,
			120
		}
	}
	self.values.player.extra_corpse_dispose_amount = {
		1
	}
	self.values.player.standstill_omniscience = {
		true
	}
	self.values.player.mask_off_pickup = {
		true
	}
	self.values.player.cleaner_cost_multiplier = {
		0.25
	}
	self.values.player.counter_strike_melee = {
		true
	}
	self.values.player.counter_strike_spooc = {
		true
	}
	self.values.temporary.passive_revive_damage_reduction = {
		{
			0.7,
			5
		},
		{
			0.2,
			5
		}
	}
	self.values.temporary.revive_damage_reduction = {
		{
			0.7,
			5
		}
	}
	self.values.player.revive_damage_reduction = {
		0.7
	}
	self.values.player.passive_convert_enemies_health_multiplier = {
		0.55,
		0.01
	}
	self.values.player.automatic_faster_reload = {
		{
			min_reload_increase = 1.4,
			penalty = 0.98,
			target_enemies = 2,
			min_bullets = 20,
			max_reload_increase = 2
		}
	}
	self.values.player.run_and_shoot = {
		true
	}
	self.values.player.armor_regen_timer_stand_still_multiplier = {
		0.8
	}
	self.values.player.tier_dodge_chance = {
		0.2,
		0.25,
		0.3
	}
	self.values.player.stand_still_crouch_camouflage_bonus = {
		0.9,
		0.85,
		0.8
	}
	self.values.player.corpse_dispose_speed_multiplier = {
		0.8
	}
	self.values.player.pick_lock_speed_multiplier = {
		0.8
	}
	self.values.player.alarm_pager_speed_multiplier = {
		0.9
	}
	self.values.temporary.melee_life_leech = {
		{
			0.2,
			10
		}
	}
	self.values.temporary.dmg_dampener_outnumbered_strong = {
		{
			0.88,
			7
		}
	}
	self.values.temporary.dmg_dampener_close_contact = {
		{
			0.92,
			7
		},
		{
			0.84,
			7
		},
		{
			0.76,
			7
		}
	}
	self.values.melee.stacking_hit_damage_multiplier = {
		10,
		10
	}
	self.values.melee.stacking_hit_expire_t = {
		7
	}
	self.values.player.melee_kill_life_leech = {
		0.1
	}
	self.values.player.killshot_regen_armor_bonus = {
		3
	}
	self.values.player.killshot_close_regen_armor_bonus = {
		3
	}
	self.values.player.killshot_close_panic_chance = {
		0.75
	}
	self.loose_ammo_restore_health_values = {
		{
			0,
			4
		},
		{
			4,
			8
		},
		{
			8,
			12
		},
		multiplier = 0.2,
		cd = 3,
		base = 8
	}
	self.values.player.marked_inc_dmg_distance = {
		{
			1000,
			1.5
		}
	}
	self.loose_ammo_give_team_ratio = 0.5
	self.loose_ammo_give_team_health_ratio = 0.5
	self.values.temporary.loose_ammo_restore_health = {}

	for i, data in ipairs(self.loose_ammo_restore_health_values) do
		local base = self.loose_ammo_restore_health_values.base

		table.insert(self.values.temporary.loose_ammo_restore_health, {
			{
				base + data[1],
				base + data[2]
			},
			self.loose_ammo_restore_health_values.cd
		})
	end

	self.values.temporary.loose_ammo_give_team = {
		{
			true,
			5
		}
	}
	self.values.player.loose_ammo_restore_health_give_team = {
		true
	}
	self.values.temporary.single_shot_fast_reload = {
		{
			2,
			4
		}
	}
	self.values.player.gain_life_per_players = {
		0.2
	}
	self.damage_to_hot_data = {
		tick_time = 0.3,
		works_with_armor_kit = true,
		stacking_cooldown = 1.5,
		total_ticks = 10,
		max_stacks = false,
		armors_allowed = {
			"level_1",
			"level_2"
		},
		add_stack_sources = {
			projectile = true,
			fire = true,
			bullet = true,
			melee = true,
			explosion = true,
			civilian = false,
			poison = true,
			taser_tased = true,
			swat_van = true
		}
	}
	self.values.player.damage_to_hot = {
		0.1,
		0.2,
		0.3,
		0.4
	}
	self.values.player.damage_to_hot_extra_ticks = {
		4
	}
	self.values.player.armor_piercing_chance = {
		0.1,
		0.3
	}
	self.values.player.armor_regen_damage_health_ratio_multiplier = {
		0.2,
		0.4,
		0.6
	}
	self.values.player.movement_speed_damage_health_ratio_multiplier = {
		0.2
	}
	self.values.player.armor_regen_damage_health_ratio_threshold_multiplier = {
		2
	}
	self.values.player.movement_speed_damage_health_ratio_threshold_multiplier = {
		2
	}
	self.values.player.armor_grinding = {
		{
			{
				1,
				2
			},
			{
				1.5,
				3
			},
			{
				2,
				4
			},
			{
				2.5,
				5
			},
			{
				3.5,
				6
			},
			{
				4.5,
				7
			},
			{
				8.5,
				10
			}
		}
	}
	self.values.player.health_decrease = {
		0.5
	}
	self.values.player.armor_increase = {
		1,
		1.1,
		1.2
	}
	self.values.player.damage_to_armor = {
		{
			{
				3,
				1.5
			},
			{
				3,
				1.5
			},
			{
				3,
				1.5
			},
			{
				3,
				1.5
			},
			{
				3,
				1.5
			},
			{
				3,
				1.5
			},
			{
				3,
				1.5
			}
		}
	}
	self.values.assault_rifle.move_spread_index_addend = {
		2
	}
	self.values.snp.move_spread_index_addend = {
		2
	}
	self.values.smg.move_spread_index_addend = {
		2
	}
	self.values.pistol.spread_index_addend = {
		2
	}
	self.values.shotgun.hip_fire_spread_index_addend = {
		1
	}
	self.values.weapon.hip_fire_spread_index_addend = {
		1
	}
	self.values.weapon.single_spread_index_addend = {
		2
	}
	self.values.weapon.silencer_spread_index_addend = {
		3
	}
	self.values.team.pistol.recoil_index_addend = {
		1
	}
	self.values.team.weapon.recoil_index_addend = {
		2
	}
	self.values.team.pistol.suppression_recoil_index_addend = self.values.team.pistol.recoil_index_addend
	self.values.team.weapon.suppression_recoil_index_addend = self.values.team.weapon.recoil_index_addend
	self.values.shotgun.recoil_index_addend = {
		2
	}
	self.values.assault_rifle.recoil_index_addend = {
		2
	}
	self.values.weapon.silencer_recoil_index_addend = {
		2
	}
	self.values.lmg.recoil_index_addend = {
		1
	}
	self.values.snp.recoil_index_addend = {
		2
	}
	self.values.akimbo.recoil_index_addend = {
		-9,
		-7,
		-5,
		-3,
		-1
	}
	self.values.weapon.steelsight_highlight_specials = {
		true
	}
	self.armor_health_store_kill_amount = 1
	self.kill_change_regenerate_speed_percentage = false
	self.values.player.armor_health_store_amount = {
		0.4,
		0.8,
		1.2
	}
	self.values.player.armor_max_health_store_multiplier = {
		1.5
	}
	self.values.player.kill_change_regenerate_speed = {
		1.4
	}
	self.values.temporary.armor_break_invulnerable = {
		{
			2,
			15
		}
	}
	self.values.player.passive_always_regen_armor = {
		1.5
	}
	self.values.player.passive_damage_reduction = {
		0.5
	}
	self.cocaine_stacks_convert_levels = {
		30,
		25
	}
	self.cocaine_stacks_dmg_absorption_value = 0.1
	self.cocaine_stacks_tick_t = 4
	self.max_cocaine_stacks_per_tick = 240
	self.max_total_cocaine_stacks = 600
	self.cocaine_stacks_decay_t = 8
	self.cocaine_stacks_decay_amount_per_tick = 80
	self.cocaine_stacks_decay_percentage_per_tick = 0.6
	self.values.player.cocaine_stacking = {
		1
	}
	self.values.player.sync_cocaine_stacks = {
		true
	}
	self.values.player.cocaine_stacks_decay_multiplier = {
		0.5
	}
	self.values.player.sync_cocaine_upgrade_level = {
		2
	}
	self.values.player.cocaine_stack_absorption_multiplier = {
		2
	}
	self.wild_trigger_time = 4
	self.wild_max_triggers_per_time = 4
	self.values.player.wild_health_amount = {
		0.5
	}
	self.values.player.wild_armor_amount = {
		0.5
	}
	self.values.player.less_health_wild_armor = {
		{
			0.1,
			0.1
		}
	}
	self.values.player.less_health_wild_cooldown = {
		{
			0.1,
			0.1
		}
	}
	self.values.player.less_armor_wild_health = {
		{
			0.1,
			0.1
		}
	}
	self.values.player.less_armor_wild_cooldown = {
		{
			0.1,
			0.1
		}
	}
	self.values.temporary.chico_injector = {
		{
			0.75,
			6
		}
	}
	self.values.player.chico_armor_multiplier = {
		1.15,
		1.2,
		1.25
	}
	self.values.player.chico_preferred_target = {
		true
	}
	self.values.player.chico_injector_low_health_multiplier = {
		{
			0.5,
			0.25
		}
	}
	self.values.player.chico_injector_health_to_speed = {
		{
			5,
			1
		}
	}
	self.values.player.pocket_ecm_jammer_base = {
		{
			cooldown_drain = 6,
			duration = 6
		}
	}
	self.values.player.pocket_ecm_heal_on_kill = {
		2
	}
	self.values.team.pocket_ecm_heal_on_kill = {
		1
	}
	self.values.temporary.pocket_ecm_kill_dodge = {
		{
			0.2,
			30,
			1
		}
	}
	self.values.player.dodge_shot_gain = {
		{
			0.2,
			4
		}
	}
	self.values.player.dodge_replenish_armor = {
		true
	}
	self.values.player.smoke_screen_ally_dodge_bonus = {
		0.1
	}
	self.values.player.sicario_multiplier = {
		2
	}
	self.values.player.tag_team_base = {
		{
			kill_health_gain = 1.5,
			radius = 0.6,
			distance = 18,
			kill_extension = 1.3,
			duration = 12,
			tagged_health_gain_ratio = 0.5
		}
	}
	self.values.player.tag_team_cooldown_drain = {
		{
			tagged = 0,
			owner = 2
		},
		{
			tagged = 2,
			owner = 2
		}
	}
	self.values.player.tag_team_damage_absorption = {
		{
			kill_gain = 0.2,
			max = 2
		}
	}
	self.values.player.armor_to_health_conversion = {
		100
	}
	self.values.player.damage_control_passive = {
		{
			75,
			9
		}
	}
	self.values.player.damage_control_auto_shrug = {
		4
	}
	self.values.player.damage_control_cooldown_drain = {
		{
			0,
			1
		},
		{
			35,
			2
		}
	}
	self.values.player.damage_control_healing = {
		50
	}
	self.values.player.warp_health = {
		{
			0,
			0.3,
			5,
			5
		},
		{
			0,
			0.6,
			5,
			5
		},
		{
			0,
			0.9,
			5,
			5
		},
		{
			0,
			1.2,
			5,
			5
		},
		{
			0,
			1.5,
			5,
			5
		}
	}
	self.values.player.warp_armor = {
		{
			0.2,
			0.6,
			3,
			3
		},
		{
			0.4,
			1,
			3,
			3
		},
		{
			0.6,
			1.4,
			3,
			3
		},
		{
			0.8,
			1.8,
			3,
			3
		},
		{
			1,
			2.2,
			3,
			3
		}
	}
	self.values.player.warp_dodge = {
		{
			0.01,
			0.06,
			3
		},
		{
			0.01,
			0.07,
			3
		},
		{
			0.01,
			0.08,
			3
		},
		{
			0.01,
			0.09,
			3
		},
		{
			0.01,
			0.1,
			3
		}
	}
	self.values.player.warp_armor_lite = {
		{
			0.1,
			0.3,
			3,
			5
		},
		{
			0.2,
			0.5,
			3,
			5
		},
		{
			0.3,
			0.7,
			3,
			5
		},
		{
			0.4,
			0.9,
			3,
			5
		},
		{
			0.5,
			1.1,
			3,
			5
		}
	}
	self.values.player.stamina_ammo_refill_single = {
		{
			25,
			0.01
		}
	}
	self.values.player.stamina_ammo_refill_auto = {
		{
			40,
			0.05
		}
	}
	self.values.player.post_warp_suppression = {
		{
			800,
			1,
			3
		}
	}
	self.values.player.post_warp_reload_speed = {
		{
			0.2,
			0.5
		}
	}
	self.values.player.run_dodge_chance_vr = {
		{
			1,
			5
		}
	}
	self.values.snp.graze_damage = {
		{
			radius = 100,
			damage_factor = 0.2,
			damage_factor_headshot = 0.2
		},
		{
			radius = 100,
			damage_factor = 0.2,
			damage_factor_headshot = 1
		}
	}
	self.values.team.crew_add_health = {
		6
	}
	self.values.team.crew_add_armor = {
		3
	}
	self.values.team.crew_add_dodge = {
		0.05
	}
	self.values.team.crew_add_concealment = {
		3
	}
	self.values.team.crew_add_stamina = {
		50
	}
	self.values.team.crew_reduce_speed_penalty = {
		0.5
	}
	self.values.team.crew_faster_reload = {
		1.5
	}
	self.values.team.crew_faster_swap = {
		1.5
	}
	self.values.team.crew_throwable_regen = {
		35
	}
	self.values.team.crew_health_regen = {
		0.5
	}
	self.values.team.crew_active = {
		1,
		2,
		3
	}
	self.values.team.crew_inspire = {
		{
			360,
			240,
			120
		}
	}
	self.values.team.crew_scavenge = {
		{
			0.2,
			0.4,
			0.6
		}
	}
	self.values.team.crew_interact = {
		{
			0.75,
			0.5,
			0.25
		}
	}
	self.values.team.crew_ai_ap_ammo = {
		true
	}
	local editable_crew_descrition = {
		crew_healthy = {
			"60"
		},
		crew_sturdy = {
			"30"
		},
		crew_evasive = {
			"5"
		},
		crew_quiet = {
			"3"
		},
		crew_motivated = {
			"50",
			"50%"
		},
		crew_eager = {
			"50%",
			"50%"
		},
		crew_generous = {
			"35"
		},
		crew_regen = {
			"5",
			"5"
		},
		crew_inspire = {
			"6",
			"2"
		},
		crew_scavenge = {
			"20%",
			"+20%"
		},
		crew_interact = {
			"25%",
			"+25%"
		}
	}
	self.crew_descs = {}

	for id, desc in pairs(editable_crew_descrition) do
		self.crew_descs[id] = {}

		for i, value in ipairs(desc) do
			self.crew_descs[id]["value" .. i] = value
		end
	end

	local editable_skill_descs = {
		ammo_2x = {
			{
				"2"
			},
			{
				"50%"
			}
		},
		ammo_reservoir = {
			{
				"5"
			},
			{
				"10",
				"15"
			}
		},
		assassin = {
			{
				"25%",
				"10%"
			},
			{
				"95%"
			}
		},
		bandoliers = {
			{
				"25%"
			},
			{
				"175%",
				"75%",
				"5%",
				"1%"
			}
		},
		black_marketeer = {
			{
				"1.5%",
				"5"
			},
			{
				"4.5%",
				"5"
			}
		},
		blast_radius = {
			{
				"70%"
			},
			{}
		},
		cable_guy = {
			{
				"75%",
				"50%"
			},
			{
				"4",
				"2"
			}
		},
		carbon_blade = {
			{
				"20%",
				"50%"
			},
			{
				"50%",
				"20%",
				"10"
			}
		},
		cat_burglar = {
			{
				"75%"
			},
			{
				"50%"
			}
		},
		chameleon = {
			{
				"25%",
				"10",
				"3.5"
			},
			{
				"15%",
				"75%"
			}
		},
		cleaner = {
			{
				"5%",
				"3",
				"1",
				"1",
				"2"
			},
			{
				"1",
				"2"
			}
		},
		combat_medic = {
			{
				"30%",
				"5"
			},
			{
				"30%"
			}
		},
		control_freak = {
			{
				"10%",
				"40%",
				"45%"
			},
			{
				"20%",
				"40%",
				"30%",
				"54%"
			}
		},
		discipline = {
			{
				"50%"
			},
			{}
		},
		dominator = {
			{},
			{
				"50%"
			}
		},
		drill_expert = {
			{
				"15%"
			},
			{
				"15%"
			}
		},
		ecm_2x = {
			{
				"2"
			},
			{
				"25%",
				"25%"
			}
		},
		ecm_booster = {
			{
				"25%"
			},
			{}
		},
		ecm_feedback = {
			{
				"50%-100%",
				"25",
				"1.5",
				"15-20"
			},
			{
				"25%",
				"100%",
				"4"
			}
		},
		enforcer = {
			{
				"400%"
			},
			{}
		},
		equilibrium = {
			{
				"4",
				"50%",
				"33%"
			},
			{
				"100%",
				"8"
			}
		},
		fast_learner = {
			{
				"10%",
				"5",
				"30%"
			},
			{
				"20%",
				"50%"
			}
		},
		from_the_hip = {
			{
				"4"
			},
			{
				"4"
			}
		},
		ghost = {
			{
				"1",
				"20"
			},
			{}
		},
		good_luck_charm = {
			{
				"10",
				"1"
			},
			{
				"10"
			}
		},
		gun_fighter = {
			{
				"50%",
				"5"
			},
			{
				"15",
				"10"
			}
		},
		hardware_expert = {
			{
				"25%",
				"20%"
			},
			{
				"30%",
				"50%",
				"10%"
			}
		},
		single_shot_ammo_return = {
			{
				"20%",
				"100cm"
			},
			{
				"100%",
				"20%"
			}
		},
		inside_man = {
			{
				"50%"
			},
			{}
		},
		inspire = {
			{
				"100%",
				"20%",
				"10"
			},
			{
				"100%",
				"20",
				"9"
			}
		},
		insulation = {
			{
				"30%"
			},
			{
				"50%",
				"2"
			}
		},
		iron_man = {
			{
				"50%",
				"25%"
			},
			{
				"25%",
				"100%"
			}
		},
		joker = {
			{},
			{
				"55%",
				"35%",
				"65%"
			}
		},
		juggernaut = {
			{
				"30%"
			},
			{}
		},
		kilmer = {
			{
				"25%"
			},
			{
				"8"
			}
		},
		leadership = {
			{
				"4"
			},
			{
				"8"
			}
		},
		mag_plus = {
			{
				"5"
			},
			{
				"10"
			}
		},
		magic_touch = {
			{
				"25%"
			},
			{
				"25%"
			}
		},
		martial_arts = {
			{
				"50%"
			},
			{
				"50%"
			}
		},
		master_craftsman = {
			{
				"30%"
			},
			{
				"15%"
			}
		},
		mastermind = {
			{
				"2"
			},
			{}
		},
		medic_2x = {
			{
				"2"
			},
			{
				"2"
			}
		},
		nine_lives = {
			{
				"1",
				"50%"
			},
			{
				"35%",
				"1"
			}
		},
		oppressor = {
			{
				"25%",
				"15%"
			},
			{
				"50%",
				"75%"
			}
		},
		overkill = {
			{
				"75%",
				"20"
			},
			{
				"80%"
			}
		},
		pack_mule = {
			{
				"50%"
			},
			{
				"50%",
				"10",
				"1%"
			}
		},
		messiah = {
			{
				"1"
			},
			{
				"2"
			}
		},
		portable_saw = {
			{},
			{
				"1",
				"40%"
			}
		},
		rifleman = {
			{
				"100%"
			},
			{
				"25%",
				"16"
			}
		},
		scavenger = {
			{
				"30%",
				"5"
			},
			{
				"20%",
				"30%"
			}
		},
		sentry_2_0 = {
			{},
			{}
		},
		sentry_gun = {
			{},
			{
				"150%"
			}
		},
		sentry_gun_2x = {
			{
				"2"
			},
			{
				"300%"
			}
		},
		sentry_targeting_package = {
			{
				"100%"
			},
			{
				"150%",
				"50%"
			}
		},
		shades = {
			{
				"25%"
			},
			{
				"50%"
			}
		},
		shaped_charge = {
			{
				"3"
			},
			{}
		},
		sharpshooter = {
			{
				"4",
				"8"
			},
			{
				"8",
				"20%"
			}
		},
		shotgun_cqb = {
			{
				"50%",
				"15%"
			},
			{
				"35%",
				"125%",
				"12"
			}
		},
		shotgun_impact = {
			{
				"8",
				"5%"
			},
			{
				"15%",
				"10%"
			}
		},
		show_of_force = {
			{
				"50%"
			},
			{
				"15%",
				"20"
			}
		},
		silence = {
			{},
			{}
		},
		silence_expert = {
			{
				"8",
				"100%"
			},
			{
				"8",
				"20%",
				"12"
			}
		},
		silent_drilling = {
			{
				"65%"
			},
			{}
		},
		smg_master = {
			{
				"35%"
			},
			{
				"20%"
			}
		},
		smg_training = {
			{},
			{}
		},
		sprinter = {
			{
				"25%",
				"25%"
			},
			{
				"10%",
				"10%",
				"15%"
			}
		},
		steroids = {
			{
				"100%"
			},
			{
				"100%"
			}
		},
		stockholm_syndrome = {
			{
				"50%"
			},
			{
				"1"
			}
		},
		tactician = {
			{
				"15%"
			},
			{}
		},
		target_mark = {
			{},
			{}
		},
		technician = {
			{
				"2"
			},
			{}
		},
		tough_guy = {
			{
				"50%"
			},
			{
				"25%"
			}
		},
		transporter = {
			{
				"25%"
			},
			{
				"50%"
			}
		},
		triathlete = {
			{
				"100%",
				"4",
				"75%"
			},
			{
				"0.5",
				"8"
			}
		},
		trip_mine_expert = {
			{
				"30%"
			},
			{
				"50%"
			}
		},
		trip_miner = {
			{
				"1"
			},
			{
				"20%"
			}
		},
		underdog = {
			{
				"18",
				"15%",
				"7"
			},
			{
				"18",
				"10%",
				"7"
			}
		},
		wolverine = {
			{
				"25%",
				"250%",
				"50%"
			},
			{
				"25%",
				"100%",
				"50%"
			}
		},
		stable_shot = {
			{
				"8"
			},
			{
				"16"
			}
		},
		hitman = {
			{
				"15%"
			},
			{
				"50%",
				"10",
				"100%"
			}
		},
		speedy_reload = {
			{
				"15%"
			},
			{
				"100%",
				"4"
			}
		},
		spotter_teamwork = {
			{
				"3",
				"6",
				"1"
			},
			{
				"2",
				"1"
			}
		},
		far_away = {
			{
				"40%"
			},
			{
				"50%"
			}
		},
		close_by = {
			{},
			{
				"35%",
				"15"
			}
		},
		scavenging = {
			{
				"50%"
			},
			{
				"6"
			}
		},
		dire_need = {
			{},
			{
				"6"
			}
		},
		unseen_strike = {
			{
				"4",
				"35%",
				"6"
			},
			{
				"18"
			}
		},
		dance_instructor = {
			{
				"5"
			},
			{
				"50%"
			}
		},
		akimbo_skill = {
			{
				"8"
			},
			{
				"8",
				"50%"
			}
		},
		running_from_death = {
			{
				"100%",
				"10"
			},
			{
				"30%",
				"10"
			}
		},
		up_you_go = {
			{
				"30%",
				"10"
			},
			{
				"40%"
			}
		},
		feign_death = {
			{
				"15%"
			},
			{
				"30%"
			}
		},
		bloodthirst = {
			{
				"100%",
				"1600%"
			},
			{
				"50%",
				"10"
			}
		},
		frenzy = {
			{
				"30%",
				"10%",
				"75%"
			},
			{
				"25%",
				"0%"
			}
		},
		defense_up = {
			{
				"5%"
			},
			{}
		},
		eco_sentry = {
			{
				"5%"
			},
			{
				"150%"
			}
		},
		engineering = {
			{},
			{
				"75%",
				"250%"
			}
		},
		jack_of_all_trades = {
			{
				"100%"
			},
			{
				"50%"
			}
		},
		tower_defense = {
			{
				"1"
			},
			{
				"2"
			}
		},
		steady_grip = {
			{
				"8"
			},
			{
				"16"
			}
		},
		heavy_impact = {
			{
				"5%"
			},
			{
				"20%"
			}
		},
		fire_control = {
			{
				"12"
			},
			{
				"20%"
			}
		},
		shock_and_awe = {
			{},
			{
				"2",
				"100%",
				"1%",
				"20",
				"40%"
			}
		},
		fast_fire = {
			{
				"15"
			},
			{}
		},
		body_expertise = {
			{
				"30%"
			},
			{
				"90%"
			}
		},
		kick_starter = {
			{
				"20%"
			},
			{
				"1",
				"50%"
			}
		},
		expert_handling = {
			{
				"10%",
				"10",
				"4"
			},
			{
				"1",
				"50%"
			}
		},
		optic_illusions = {
			{
				"35%"
			},
			{
				"1",
				"2"
			}
		},
		more_fire_power = {
			{
				"1",
				"4"
			},
			{
				"2",
				"7"
			}
		},
		fire_trap = {
			{
				"10",
				"4"
			},
			{
				"10",
				"50%"
			}
		},
		combat_engineering = {
			{
				"30%"
			},
			{
				"50%"
			}
		},
		hoxton = {
			{
				"4"
			},
			{}
		},
		freedom_call = {
			{
				"20%"
			},
			{
				"15%"
			}
		},
		hidden_blade = {
			{
				"2"
			},
			{
				"95%"
			}
		},
		tea_time = {
			{
				"50%"
			},
			{
				"10%",
				"120"
			}
		},
		awareness = {
			{
				"10%",
				"20%"
			},
			{
				"75%"
			}
		},
		alpha_dog = {
			{
				"5%"
			},
			{
				"10%"
			}
		},
		tea_cookies = {
			{
				"3",
				"7"
			},
			{
				"7",
				"5",
				"3",
				"20"
			}
		},
		cell_mates = {
			{
				"10%"
			},
			{
				"25%"
			}
		},
		thug_life = {
			{
				"1"
			},
			{
				"75%"
			}
		},
		thick_skin = {
			{
				"10",
				"2"
			},
			{
				"20",
				"4"
			}
		},
		backstab = {
			{
				"3%",
				"3",
				"35",
				"30%"
			},
			{
				"3%",
				"1",
				"35",
				"30%"
			}
		},
		drop_soap = {
			{},
			{}
		},
		second_chances = {
			{
				"1",
				"25"
			},
			{
				"2",
				"100%"
			}
		},
		trigger_happy = {
			{
				"10%",
				"2",
				"1",
				"120%"
			},
			{
				"8",
				"4"
			}
		},
		perseverance = {
			{
				"0",
				"3",
				"60%"
			},
			{
				"3"
			}
		},
		jail_workout = {
			{
				"3.5",
				"10",
				"25%"
			},
			{
				"30%"
			}
		},
		akimbo = {
			{
				"-16",
				"8"
			},
			{
				"-8",
				"150%",
				"8",
				"50%"
			}
		},
		jail_diet = {
			{
				"1%",
				"3",
				"35",
				"10%"
			},
			{
				"1%",
				"1",
				"35",
				"10%"
			}
		},
		prison_wife = {
			{
				"15",
				"2",
				"5"
			},
			{
				"30",
				"2",
				"20"
			}
		},
		mastermind_tier1 = {
			{
				"20%"
			}
		},
		mastermind_tier2 = {
			{
				"15%"
			}
		},
		mastermind_tier3 = {
			{
				"25%"
			}
		},
		mastermind_tier4 = {
			{
				"10%"
			}
		},
		mastermind_tier5 = {
			{
				"65%"
			}
		},
		mastermind_tier6 = {
			{
				"200%",
				"50%"
			}
		},
		enforcer_tier1 = {
			{
				"10%"
			}
		},
		enforcer_tier2 = {
			{
				"10%"
			}
		},
		enforcer_tier3 = {
			{
				"10%"
			}
		},
		enforcer_tier4 = {
			{
				"10%"
			}
		},
		enforcer_tier5 = {
			{
				"5%"
			}
		},
		enforcer_tier6 = {
			{
				"30%"
			}
		},
		technician_tier1 = {
			{
				"1%"
			}
		},
		technician_tier2 = {
			{
				"5%"
			}
		},
		technician_tier3 = {
			{
				"3%"
			}
		},
		technician_tier4 = {
			{
				"25%"
			}
		},
		technician_tier5 = {
			{
				"5%"
			}
		},
		technician_tier6 = {
			{
				"5%",
				"10%",
				"10%"
			}
		},
		ghost_tier1 = {
			{
				"5%"
			}
		},
		ghost_tier2 = {
			{
				"20%"
			}
		},
		ghost_tier3 = {
			{
				"10%"
			}
		},
		ghost_tier4 = {
			{
				"+5",
				"25%"
			}
		},
		ghost_tier5 = {
			{
				"80%"
			}
		},
		ghost_tier6 = {
			{
				"10%",
				"15%"
			}
		},
		hoxton_tier1 = {
			{}
		},
		hoxton_tier2 = {
			{}
		},
		hoxton_tier3 = {
			{}
		},
		hoxton_tier4 = {
			{}
		},
		hoxton_tier5 = {
			{}
		},
		hoxton_tier6 = {
			{}
		}
	}

	if _G.IS_VR then
		editable_skill_descs.steroids = {
			{
				"100%"
			},
			{
				"100%"
			}
		}
	end

	self.skill_descs = {}

	for skill_id, skill_desc in pairs(editable_skill_descs) do
		self.skill_descs[skill_id] = {}

		for index, skill_version in ipairs(skill_desc) do
			local version = index == 1 and "multibasic" or "multipro"
			self.skill_descs[skill_id][index] = #skill_version

			for i, desc in ipairs(skill_version) do
				self.skill_descs[skill_id][version .. (i == 1 and "" or tostring(i))] = desc
			end
		end
	end

	local editable_skill_btns = {
		jack_of_all_trades = {
			BTN_CHANGE_EQ = function ()
				return managers.localization:btn_macro("change_equipment") or managers.localization:get_default_macro("BTN_CHANGE_EQ")
			end
		}
	}
	self.skill_btns = {}

	for skill_id, skill_btns in pairs(editable_skill_btns) do
		self.skill_btns[skill_id] = {}

		for i, desc in pairs(skill_btns) do
			self.skill_btns[skill_id][tostring(i)] = desc
		end
	end

	local editable_specialization_descs = {
		{
			{
				"10%",
				"8%",
				"50%"
			},
			{
				"25%"
			},
			{
				"50%",
				"25%",
				"6%"
			},
			{
				"+1",
				"15%",
				"45%"
			},
			{
				"10%",
				"20%"
			},
			{
				"135%"
			},
			{
				"10%",
				"5%"
			},
			{
				"5%",
				"20%"
			},
			{
				"6%",
				"12%",
				"4",
				"8%",
				"10%"
			}
		},
		{
			{
				"10%"
			},
			{
				"25%"
			},
			{
				"15%",
				"10%"
			},
			{
				"+1",
				"15%",
				"45%"
			},
			{
				"20%"
			},
			{
				"135%"
			},
			{},
			{
				"5%",
				"20%"
			},
			{
				"40%",
				"3%",
				"5",
				"10%"
			}
		},
		{
			{
				"10%"
			},
			{
				"25%"
			},
			{
				"10%"
			},
			{
				"+1",
				"15%",
				"45%"
			},
			{
				"10%"
			},
			{
				"135%"
			},
			{
				"10%",
				"2",
				"15"
			},
			{
				"5%",
				"20%"
			},
			{
				"5%",
				"10%",
				"10%"
			}
		},
		{
			{
				"15%"
			},
			{
				"25%"
			},
			{
				"15%",
				"45%"
			},
			{
				"+1",
				"15%",
				"45%"
			},
			{
				"15%",
				"135%"
			},
			{
				"135%"
			},
			{
				"15%"
			},
			{
				"5%",
				"20%"
			},
			{
				"25%",
				"80%",
				"10%"
			}
		},
		{
			{
				"5%"
			},
			{
				"25%"
			},
			{
				"10%",
				"5%",
				"-24",
				"50%",
				"-16"
			},
			{
				"+1",
				"15%",
				"45%"
			},
			{
				"10%",
				"5%"
			},
			{
				"135%"
			},
			{
				"10%",
				"5%"
			},
			{
				"5%",
				"20%"
			},
			{
				"10%",
				"5%",
				"-16",
				"125%",
				"10%",
				"1.5"
			}
		},
		{
			{
				"15%"
			},
			{
				"25%"
			},
			{
				"5%",
				"20%"
			},
			{
				"+1",
				"15%",
				"45%"
			},
			{
				"10%",
				"20%"
			},
			{
				"135%"
			},
			{
				"10%",
				"25%"
			},
			{
				"5%",
				"20%"
			},
			{
				"10%",
				"10%"
			}
		},
		{
			{
				"20%"
			},
			{
				"25%"
			},
			{
				"10%",
				"20%"
			},
			{
				"+1",
				"15%",
				"45%"
			},
			{
				"5%",
				"5%",
				"20%"
			},
			{
				"135%"
			},
			{
				"5%",
				"5%",
				"10%"
			},
			{
				"5%",
				"20%"
			},
			{
				"20%",
				"10%"
			}
		},
		{
			{
				"12%",
				"1",
				"10"
			},
			{
				"25%"
			},
			{
				"8%"
			},
			{
				"+1",
				"15%",
				"45%"
			},
			{
				"8%",
				"10%",
				"7",
				"4"
			},
			{
				"135%"
			},
			{
				"8%"
			},
			{
				"5%",
				"20%"
			},
			{
				"20%",
				"10",
				"10%"
			}
		},
		{
			{
				"12%",
				"1",
				"10"
			},
			{
				"25%"
			},
			{
				"30",
				"1",
				"10%"
			},
			{
				"+1",
				"15%",
				"45%"
			},
			{
				"10%",
				"1",
				"8%"
			},
			{
				"135%"
			},
			{
				"30",
				"1",
				"10%"
			},
			{
				"5%",
				"20%"
			},
			{
				"75%",
				"1",
				"10%"
			}
		},
		{
			{
				"16",
				"24",
				"3",
				"20%"
			},
			{
				"25%"
			},
			{
				"50%",
				"5",
				"20%"
			},
			{
				"+1",
				"15%",
				"45%"
			},
			{
				"50%",
				"20%"
			},
			{
				"135%"
			},
			{
				"8"
			},
			{
				"5%",
				"20%"
			},
			{
				"8",
				"10%"
			}
		},
		{
			{
				"1",
				"0.3",
				"3",
				"1.5"
			},
			{
				"25%"
			},
			{
				"2",
				"0.3",
				"3",
				"20%"
			},
			{
				"+1",
				"15%",
				"45%"
			},
			{
				"3",
				"0.3",
				"3",
				"10%"
			},
			{
				"135%"
			},
			{
				"4",
				"0.3",
				"3",
				"20%"
			},
			{
				"5%",
				"20%"
			},
			{
				"4",
				"0.3",
				"4.2",
				"20%",
				"10%"
			}
		},
		{
			{
				"25%",
				"20%"
			},
			{
				"25%"
			},
			{
				"25%",
				"20%"
			},
			{
				"+1",
				"15%",
				"45%"
			},
			{
				"25%",
				"20%"
			},
			{
				"135%"
			},
			{
				"25%",
				"20%"
			},
			{
				"5%",
				"20%"
			},
			{
				"50%",
				"25%",
				"10%"
			}
		},
		{
			{
				"4",
				"1"
			},
			{
				"25%"
			},
			{
				"4",
				"10%",
				"10%"
			},
			{
				"+1",
				"15%",
				"45%"
			},
			{
				"50%",
				"10%",
				"10%"
			},
			{
				"135%"
			},
			{
				"4",
				"20%",
				"10%"
			},
			{
				"5%",
				"20%"
			},
			{
				"20%",
				"10%"
			}
		},
		{
			{
				"100%",
				"240",
				"4",
				"600",
				"1",
				"30",
				"60% + 80",
				"8"
			},
			{
				"25%"
			},
			{},
			{
				"+1",
				"15%",
				"45%"
			},
			{
				"60% + 40",
				"8"
			},
			{
				"135%"
			},
			{
				"1",
				"25"
			},
			{
				"5%",
				"20%"
			},
			{
				"100%",
				"10%"
			}
		},
		{
			{
				"2",
				"15"
			},
			{
				"25%"
			},
			{
				"50%",
				"100%"
			},
			{
				"+1",
				"15%",
				"45%"
			},
			{
				"50%",
				"110%"
			},
			{
				"135%"
			},
			{
				"50%",
				"120%"
			},
			{
				"5%",
				"20%"
			},
			{
				"10",
				"1.5",
				"10%"
			}
		},
		{
			{
				"5",
				"5",
				"4",
				"4"
			},
			{
				"25%"
			},
			{
				"10%",
				"1"
			},
			{
				"+1",
				"15%",
				"45%"
			},
			{
				"10%",
				"4",
				"0.1"
			},
			{
				"135%"
			},
			{
				"10%",
				"1"
			},
			{
				"5%",
				"20%"
			},
			{
				"10%",
				"4",
				"0.1",
				"10%"
			}
		},
		{
			{
				"75%",
				"6",
				"30"
			},
			{
				"25%"
			},
			{
				"10%"
			},
			{
				"+1",
				"15%",
				"45%"
			},
			{
				"10%"
			},
			{
				"135%"
			},
			{
				"20%",
				"50%",
				"25%"
			},
			{
				"5%",
				"20%"
			},
			{
				"40%",
				"100%",
				"5",
				"1",
				"10%"
			}
		},
		{
			{
				"10",
				"50%",
				"60",
				"50%",
				"1"
			},
			{
				"25%"
			},
			{
				"20%",
				"4"
			},
			{
				"+1",
				"15%",
				"45%"
			},
			{
				"15%"
			},
			{
				"135%"
			},
			{},
			{
				"5%",
				"20%"
			},
			{
				"100%",
				"10%",
				"10%"
			}
		}
	}
	local delayed_percentage = self.values.player.damage_control_passive[1][1]
	local tick_percentage = self.values.player.damage_control_passive[1][2] * 0.01 * delayed_percentage
	local damage_duration = math.ceil(delayed_percentage / tick_percentage)
	local auto_shrug_time = self.values.player.damage_control_auto_shrug[1]
	local health_threshold = self.values.player.damage_control_cooldown_drain[2][1]
	local cooldown_drain_1 = self.values.player.damage_control_cooldown_drain[1][2]
	local cooldown_drain_2 = self.values.player.damage_control_cooldown_drain[2][2]
	local heal_percentage = self.values.player.damage_control_healing[1]

	table.insert(editable_specialization_descs, {
		{
			tostring(delayed_percentage) .. "%",
			damage_duration,
			"10"
		},
		{
			"25%"
		},
		{},
		{
			"+1",
			"15%",
			"45%"
		},
		{
			auto_shrug_time
		},
		{
			"135%"
		},
		{
			tostring(health_threshold) .. "%",
			cooldown_drain_2,
			cooldown_drain_1
		},
		{
			"5%",
			"20%"
		},
		{
			tostring(heal_percentage) .. "%",
			"10%"
		}
	})

	local distance = self.values.player.tag_team_base[1].distance
	local heal_amount = self.values.player.tag_team_base[1].kill_health_gain * 10
	local heal_amount_tagged = heal_amount * self.values.player.tag_team_base[1].tagged_health_gain_ratio
	local kill_extension = self.values.player.tag_team_base[1].kill_extension
	local duration = self.values.player.tag_team_base[1].duration
	local cooldown = 60
	local cooldown_drain_owner = self.values.player.tag_team_cooldown_drain[1].owner
	local cooldown_drain_tagged = self.values.player.tag_team_cooldown_drain[2].tagged
	local health_bonus_1 = (self.values.player.passive_health_multiplier[2] - 1) * 100
	local health_bonus_2 = (self.values.player.passive_health_multiplier[3] - 1) * 100 - health_bonus_1
	local kill_absorption = self.values.player.tag_team_damage_absorption[1].kill_gain * 10
	local kill_absorption_max = self.values.player.tag_team_damage_absorption[1].max * 10

	table.insert(editable_specialization_descs, {
		{
			distance,
			heal_amount,
			heal_amount_tagged,
			kill_extension,
			cooldown_drain_owner,
			duration,
			cooldown
		},
		{
			"25%"
		},
		{
			health_bonus_1 .. "%"
		},
		{
			"+1",
			"15%",
			"45%"
		},
		{
			kill_absorption,
			kill_absorption_max
		},
		{
			"135%"
		},
		{
			health_bonus_2 .. "%"
		},
		{
			"5%",
			"20%"
		},
		{
			cooldown_drain_tagged,
			"10%"
		}
	})

	local duration = self.values.player.pocket_ecm_jammer_base[1].duration
	local charges = 2
	local cooldown = 100
	local cooldown_drain = self.values.player.pocket_ecm_jammer_base[1].cooldown_drain
	local health_bonus = (self.values.player.passive_health_multiplier[2] - 1) * 100
	local kill_health_gain = self.values.player.pocket_ecm_heal_on_kill[1] * 10
	local kill_health_gain_team = self.values.team.pocket_ecm_heal_on_kill[1] * 10
	local kill_dodge_bonus_count = 1
	local kill_dodge_bonus = 20
	local kill_dodge_bonus_duration = 30

	table.insert(editable_specialization_descs, {
		{
			duration,
			charges,
			cooldown,
			cooldown_drain
		},
		{
			"25%"
		},
		{
			health_bonus .. "%"
		},
		{
			"+1",
			"15%",
			"45%"
		},
		{
			kill_health_gain
		},
		{
			"135%"
		},
		{
			kill_dodge_bonus_count,
			kill_dodge_bonus,
			kill_dodge_bonus_duration
		},
		{
			"5%",
			"20%"
		},
		{
			kill_health_gain_team,
			"10%"
		}
	})

	self.specialization_descs = {}

	for tree, data in pairs(editable_specialization_descs) do
		self.specialization_descs[tree] = {}

		for tier, tier_data in ipairs(data) do
			self.specialization_descs[tree][tier] = {}

			for i, desc in ipairs(tier_data) do
				self.specialization_descs[tree][tier]["multiperk" .. (i == 1 and "" or tostring(i))] = desc
			end
		end
	end
end

function UpgradesTweakData:init(tweak_data)
	self.level_tree = {
		[0] = {
			upgrades = {
				"frag",
				"dynamite",
				"molotov",
				"wpn_dallas_mask",
				"corgi",
				"clean",
				"aziz"
			}
		},
		{
			name_id = "body_armor",
			upgrades = {
				"body_armor2",
				"ak74",
				"frag_com",
				"nin",
				"concussion",
				"fir_com",
				"dada_com"
			}
		},
		{
			name_id = "weapons",
			upgrades = {
				"colt_1911",
				"mac10",
				"hajk",
				"x_hajk",
				"x_mac10"
			}
		},
		{
			name_id = "weapons",
			upgrades = {
				"spatula",
				"fork",
				"boot"
			}
		},
		{
			name_id = "weapons",
			upgrades = {
				"new_m4",
				"shovel"
			}
		},
		[6] = {
			name_id = "weapons",
			upgrades = {
				"new_raging_bull",
				"b92fs",
				"x_rage"
			}
		},
		[7] = {
			name_id = "body_armor",
			upgrades = {
				"body_armor1",
				"moneybundle"
			}
		},
		[8] = {
			name_id = "weapons",
			upgrades = {
				"r870",
				"aug",
				"fight"
			}
		},
		[10] = {
			name_id = "lvl_10",
			upgrades = {
				"rep_upgrade1",
				"cutters",
				"shawn"
			}
		},
		[12] = {
			name_id = "body_armor3",
			upgrades = {
				"body_armor3",
				"cobray",
				"boxcutter",
				"x_cobray"
			}
		},
		[13] = {
			name_id = "weapons",
			upgrades = {
				"new_mp5",
				"serbu",
				"microphone",
				"selfie"
			}
		},
		[14] = {
			name_id = "weapons",
			upgrades = {
				"bayonet",
				"m1928",
				"sparrow",
				"gator",
				"pl14",
				"x_m1928",
				"x_sparrow",
				"x_pl14"
			}
		},
		[15] = {
			name_id = "weapons",
			upgrades = {
				"msr",
				"benelli",
				"plainsrider",
				"sub2000",
				"road",
				"legacy",
				"x_legacy"
			}
		},
		[16] = {
			name_id = "weapons",
			upgrades = {
				"akm",
				"g36",
				"hunter",
				"iceaxe",
				"zeus",
				"flint",
				"oxide",
				"sword"
			}
		},
		[17] = {
			name_id = "weapons",
			upgrades = {
				"akm_gold",
				"baton",
				"slot_lever",
				"frankish",
				"ecp"
			}
		},
		[18] = {
			name_id = "weapons",
			upgrades = {
				"baseballbat",
				"scorpion",
				"oldbaton",
				"hockey",
				"meter",
				"hauteur",
				"shock",
				"fear",
				"x_scorpion"
			}
		},
		[19] = {
			name_id = "weapons",
			upgrades = {
				"olympic",
				"mp9",
				"baka",
				"pugio",
				"ballistic",
				"x_baka",
				"x_olympic",
				"x_mp9"
			}
		},
		[20] = {
			name_id = "lvl_20",
			upgrades = {
				"rep_upgrade2",
				"schakal",
				"agave",
				"happy",
				"shepheard",
				"x_shepheard",
				"slap",
				"x_schakal"
			}
		},
		[21] = {
			name_id = "body_armor4",
			upgrades = {
				"body_armor4",
				"kampfmesser",
				"buck",
				"tecci",
				"wing"
			}
		},
		[22] = {
			name_id = "community_item",
			upgrades = {
				"g22c",
				"ksg",
				"branding_iron",
				"detector",
				"croupier_rake"
			}
		},
		[23] = {
			name_id = "weapons",
			upgrades = {
				"bullseye",
				"c96",
				"par",
				"m37",
				"rota",
				"x_rota",
				"x_c96",
				"cs",
				"brick",
				"ostry"
			}
		},
		[24] = {
			name_id = "weapons",
			upgrades = {
				"model24",
				"l85a2",
				"scalper",
				"switchblade"
			}
		},
		[25] = {
			name_id = "weapons",
			upgrades = {
				"boxing_gloves",
				"meat_cleaver",
				"wpn_prj_four",
				"sr2",
				"grip",
				"push",
				"breech",
				"ching",
				"erma",
				"x_breech",
				"x_erma",
				"sap"
			}
		},
		[26] = {
			name_id = "weapons",
			upgrades = {
				"new_m14",
				"saiga",
				"sandsteel",
				"packrat",
				"lemming",
				"chinchilla",
				"x_chinchilla"
			}
		},
		[27] = {
			name_id = "weapons",
			upgrades = {
				"famas",
				"g26",
				"twins",
				"pitchfork",
				"shrew",
				"x_shrew",
				"basset",
				"x_basset"
			}
		},
		[28] = {
			name_id = "weapons",
			upgrades = {
				"hs2000",
				"vhs",
				"bowie",
				"micstand",
				"x_hs2000"
			}
		},
		[29] = {
			name_id = "weapons",
			upgrades = {
				"akmsu",
				"glock_18c",
				"asval",
				"long",
				"x_g18c"
			}
		},
		[30] = {
			name_id = "lvl_30",
			upgrades = {
				"rep_upgrade3",
				"shuno"
			}
		},
		[31] = {
			name_id = "body_armor5",
			upgrades = {
				"body_armor5",
				"chef",
				"peacemaker",
				"wpn_prj_ace"
			}
		},
		[32] = {
			name_id = "weapons",
			upgrades = {
				"x46",
				"tec9",
				"tiger",
				"model70",
				"x_tec9"
			}
		},
		[33] = {
			name_id = "weapons",
			upgrades = {
				"ak5",
				"striker",
				"wa2000",
				"beardy",
				"catch",
				"elastic"
			}
		},
		[34] = {
			name_id = "weapons",
			upgrades = {
				"galil",
				"cleaver",
				"mateba",
				"taser",
				"desertfox",
				"wpn_prj_target",
				"tti",
				"x_2006m"
			}
		},
		[35] = {
			name_id = "weapons",
			upgrades = {
				"r93",
				"judge",
				"mining_pick",
				"wing",
				"x_judge"
			}
		},
		[36] = {
			name_id = "weapons",
			upgrades = {
				"p90",
				"deagle",
				"winchester1874",
				"x_p90"
			}
		},
		[37] = {
			name_id = "weapons",
			upgrades = {
				"shillelagh",
				"hammer",
				"stick"
			}
		},
		[38] = {
			name_id = "weapons",
			upgrades = {
				"m134",
				"rpg7",
				"arblast",
				"scoutknife",
				"komodo"
			}
		},
		[39] = {
			name_id = "weapons",
			upgrades = {
				"m16",
				"huntsman",
				"polymer",
				"china",
				"x_polymer"
			}
		},
		[40] = {
			name_id = "lvl_40",
			upgrades = {
				"rep_upgrade4"
			}
		},
		[41] = {
			name_id = "weapons",
			upgrades = {
				"gerber",
				"fairbair",
				"wpn_prj_jav",
				"wpn_prj_hur",
				"contraband",
				"ray"
			}
		},
		[42] = {
			name_id = "weapons",
			upgrades = {
				"fal",
				"tomahawk",
				"coal",
				"x_coal"
			}
		},
		[43] = {
			name_id = "weapons",
			upgrades = {
				"b682",
				"m32",
				"morning",
				"coach"
			}
		},
		[44] = {
			name_id = "weapons",
			upgrades = {
				"flamethrower_mk2",
				"poker"
			}
		},
		[45] = {
			name_id = "weapons",
			upgrades = {
				"m249",
				"barbedwire"
			}
		},
		[46] = {
			name_id = "weapons",
			upgrades = {
				"gre_m79",
				"great",
				"siltstone"
			}
		},
		[47] = {
			name_id = "weapons",
			upgrades = {
				"freedom",
				"whiskey",
				"arbiter",
				"system"
			}
		},
		[48] = {
			name_id = "weapons",
			upgrades = {
				"dingdong",
				"tenderizer"
			}
		},
		[50] = {
			name_id = "lvl_50",
			upgrades = {
				"rep_upgrade5"
			}
		},
		[51] = {
			name_id = "weapons",
			upgrades = {
				"machete",
				"sterling",
				"x_sterling"
			}
		},
		[52] = {
			name_id = "weapons",
			upgrades = {
				"g3",
				"aa12"
			}
		},
		[54] = {
			name_id = "weapons",
			upgrades = {
				"becker",
				"mosin",
				"cqc"
			}
		},
		[55] = {
			name_id = "weapons",
			upgrades = {
				"uzi",
				"x_uzi"
			}
		},
		[60] = {
			name_id = "lvl_60",
			upgrades = {
				"rep_upgrade6"
			}
		},
		[61] = {
			name_id = "weapons",
			upgrades = {
				"rambo"
			}
		},
		[65] = {
			name_id = "weapons",
			upgrades = {
				"m95"
			}
		},
		[70] = {
			name_id = "lvl_70",
			upgrades = {
				"rep_upgrade7"
			}
		},
		[71] = {
			name_id = "weapons",
			upgrades = {
				"fireaxe",
				"mg42"
			}
		},
		[75] = {
			name_id = "weapons",
			upgrades = {
				"hk21"
			}
		},
		[80] = {
			name_id = "lvl_80",
			upgrades = {
				"rep_upgrade8"
			}
		},
		[90] = {
			name_id = "lvl_90",
			upgrades = {
				"rep_upgrade9"
			}
		},
		[100] = {
			name_id = "lvl_100",
			upgrades = {
				"rep_upgrade10"
			}
		}
	}

	self:_init_pd2_values()
	self:_init_values()

	self.steps = {}
	self.values.player = self.values.player or {}
	self.values.player.thick_skin = {
		2,
		4,
		6,
		8,
		10
	}
	self.values.player.primary_weapon_when_carrying = {
		true
	}
	self.values.player.health_multiplier = {
		1.1
	}
	self.values.player.dye_pack_chance_multiplier = {
		0.5
	}
	self.values.player.dye_pack_cash_loss_multiplier = {
		0.4
	}
	self.values.player.toolset = {
		0.95,
		0.9,
		0.85,
		0.8
	}
	self.values.player.uncover_progress_mul = {
		0.5
	}
	self.values.player.uncover_progress_decay_mul = {
		1.5
	}
	self.values.player.suppressed_multiplier = {
		0.5
	}
	self.values.player.intimidate_specials = {
		true
	}
	self.values.player.intimidation_multiplier = {
		1.25
	}
	self.steps.player = {
		thick_skin = {
			nil,
			8,
			18,
			27,
			39
		},
		extra_ammo_multiplier = {
			nil,
			7,
			16,
			24,
			38
		},
		toolset = {
			nil,
			7,
			16,
			38
		}
	}
	self.values.trip_mine = self.values.trip_mine or {}
	self.values.trip_mine.quantity = {
		4,
		11
	}
	self.values.trip_mine.damage_multiplier = {
		1.5
	}
	self.values.shape_charge = self.values.shape_charge or {}
	self.values.shape_charge.quantity = {
		1,
		3
	}
	self.values.trip_mine.quantity_increase = {
		2
	}
	self.values.trip_mine.explode_timer_delay = {
		2
	}
	self.steps.trip_mine = {
		quantity = {
			14,
			22,
			29,
			36,
			42,
			47
		},
		damage_multiplier = {
			6,
			32
		}
	}
	self.values.ammo_bag = self.values.ammo_bag or {}
	self.steps.ammo_bag = {
		ammo_increase = {
			10,
			19,
			30
		}
	}
	self.values.ecm_jammer = self.values.ecm_jammer or {}
	self.values.first_aid_kit = self.values.first_aid_kit or {}
	self.values.sentry_gun = self.values.sentry_gun or {}
	self.steps.sentry_gun = {}
	self.values.doctor_bag = self.values.doctor_bag or {}
	self.steps.doctor_bag = {
		amount_increase = {
			11,
			19,
			33
		}
	}
	self.values.extra_cable_tie = {
		quantity = {
			1,
			2,
			3,
			4
		}
	}
	self.steps.extra_cable_tie = {
		quantity = {
			nil,
			12,
			23,
			33
		}
	}
	self.values.striker = {
		reload_speed_multiplier = {
			1.15
		}
	}
	self.definitions = {}

	self:_player_definitions()
	self:_trip_mine_definitions()
	self:_ecm_jammer_definitions()
	self:_ammo_bag_definitions()
	self:_doctor_bag_definitions()
	self:_cable_tie_definitions()
	self:_sentry_gun_definitions()
	self:_armor_kit_definitions()
	self:_first_aid_kit_definitions()
	self:_bodybags_bag_definitions()
	self:_rep_definitions()
	self:_jowi_definitions()
	self:_x_1911_definitions()
	self:_x_b92fs_definitions()
	self:_x_deagle_definitions()
	self:_g26_definitions()
	self:_akimbo_definitions()
	self:_kabartanto_definitions()
	self:_toothbrush_definitions()
	self:_chef_definitions()
	self:_olympic_definitions()
	self:_amcar_definitions()
	self:_m16_definitions()
	self:_new_m4_definitions()
	self:_glock_18c_definitions()
	self:_saiga_definitions()
	self:_akmsu_definitions()
	self:_ak74_definitions()
	self:_akm_definitions()
	self:_akm_gold_definitions()
	self:_ak5_definitions()
	self:_aug_definitions()
	self:_g36_definitions()
	self:_p90_definitions()
	self:_new_m14_definitions()
	self:_mp9_definitions()
	self:_deagle_definitions()
	self:_new_mp5_definitions()
	self:_colt_1911_definitions()
	self:_mac10_definitions()
	self:_glock_17_definitions()
	self:_b92fs_definitions()
	self:_huntsman_definitions()
	self:_r870_definitions()
	self:_serbu_definitions()
	self:_new_raging_bull_definitions()
	self:_saw_definitions()
	self:_usp_definitions()
	self:_g22c_definitions()
	self:_judge_definitions()
	self:_m45_definitions()
	self:_s552_definitions()
	self:_ppk_definitions()
	self:_mp7_definitions()
	self:_scar_definitions()
	self:_p226_definitions()
	self:_hk21_definitions()
	self:_m249_definitions()
	self:_rpk_definitions()
	self:_m95_definitions()
	self:_msr_definitions()
	self:_r93_definitions()
	self:_fal_definitions()
	self:_benelli_definitions()
	self:_striker_definitions()
	self:_ksg_definitions()
	self:_scorpion_definitions()
	self:_tec9_definitions()
	self:_uzi_definitions()
	self:_gre_m79_definitions()
	self:_g3_definitions()
	self:_galil_definitions()
	self:_famas_definitions()
	self:_spas12_definitions()
	self:_mg42_definitions()
	self:_c96_definitions()
	self:_sterling_definitions()
	self:_mosin_definitions()
	self:_m1928_definitions()
	self:_l85a2_definitions()
	self:_vhs_definitions()
	self:_hs2000_definitions()
	self:_m134_weapon_definitions()
	self:_rpg7_weapon_definitions()
	self:_cobray_definitions()
	self:_b682_weapon_definitions()
	self:_x_g22c_definitions()
	self:_x_g17_definitions()
	self:_x_usp_definitions()
	self:_weapon_definitions()
	self:_pistol_definitions()
	self:_assault_rifle_definitions()
	self:_smg_definitions()
	self:_shotgun_definitions()
	self:_lmg_definitions()
	self:_snp_definitions()
	self:_flamethrower_mk2_definitions()
	self:_m32_definitions()
	self:_aa12_definitions()
	self:_bbq_weapon_definitions()
	self:_peacemaker_definitions()
	self:_winchester1874_definitions()
	self:_plainsrider_definitions()
	self:_mateba_definitions()
	self:_asval_definitions()
	self:_sub2000_definitions()
	self:_wa2000_definitions()
	self:_polymer_definitions()
	self:_hunter_definitions()
	self:_baka_definitions()
	self:_arblast_weapon_definitions()
	self:_frankish_weapon_definitions()
	self:_long_weapon_definitions()
	self:_par_weapon_definitions()
	self:_sparrow_weapon_definitions()
	self:_model70_weapon_definitions()
	self:_m37_weapon_definitions()
	self:_china_weapon_definitions()
	self:_sr2_weapon_definitions()
	self:_x_sr2_weapon_definitions()
	self:_pl14_weapon_definitions()
	self:_x_mp5_weapon_definitions()
	self:_x_akmsu_weapon_definitions()
	self:_tecci_weapon_definitions()
	self:_hajk_weapon_definitions()
	self:_boot_weapon_definitions()
	self:_packrat_weapon_definitions()
	self:_schakal_weapon_definitions()
	self:_desertfox_weapon_definitions()
	self:_x_packrat_weapon_definitions()
	self:_rota_weapon_definitions()
	self:_arbiter_weapon_definitions()
	self:_contraband_weapon_definitions()
	self:_ray_weapon_definitions()
	self:_tti_weapon_definitions()
	self:_siltstone_weapon_definitions()
	self:_flint_weapon_definitions()
	self:_coal_weapon_definitions()
	self:_lemming_weapon_definitions()
	self:_chinchilla_weapon_definitions()
	self:_x_chinchilla_weapon_definitions()
	self:_shepheard_weapon_definitions()
	self:_x_shepheard_weapon_definitions()
	self:_breech_weapon_definitions()
	self:_ching_weapon_definitions()
	self:_erma_weapon_definitions()
	self:_ecp_weapon_definitions()
	self:_shrew_weapon_definitions()
	self:_x_shrew_weapon_definitions()
	self:_basset_weapon_definitions()
	self:_x_basset_weapon_definitions()
	self:_corgi_weapon_definitions()
	self:_slap_weapon_definitions()
	self:_x_coal_weapon_definitions()
	self:_x_baka_weapon_definitions()
	self:_x_cobray_weapon_definitions()
	self:_x_erma_weapon_definitions()
	self:_x_hajk_weapon_definitions()
	self:_x_m45_weapon_definitions()
	self:_x_m1928_weapon_definitions()
	self:_x_mac10_weapon_definitions()
	self:_x_mp7_weapon_definitions()
	self:_x_mp9_weapon_definitions()
	self:_x_olympic_weapon_definitions()
	self:_x_p90_weapon_definitions()
	self:_x_polymer_weapon_definitions()
	self:_x_schakal_weapon_definitions()
	self:_x_scorpion_weapon_definitions()
	self:_x_sterling_weapon_definitions()
	self:_x_tec9_weapon_definitions()
	self:_x_uzi_weapon_definitions()
	self:_x_2006m_weapon_definitions()
	self:_x_breech_weapon_definitions()
	self:_x_c96_weapon_definitions()
	self:_x_g18c_weapon_definitions()
	self:_x_hs2000_weapon_definitions()
	self:_x_p226_weapon_definitions()
	self:_x_pl14_weapon_definitions()
	self:_x_ppk_weapon_definitions()
	self:_x_rage_weapon_definitions()
	self:_x_sparrow_weapon_definitions()
	self:_x_judge_weapon_definitions()
	self:_x_rota_weapon_definitions()
	self:_shuno_weapon_definitions()
	self:_system_weapon_definitions()
	self:_komodo_weapon_definitions()
	self:_elastic_weapon_definitions()
	self:_legacy_weapon_definitions()
	self:_x_legacy_weapon_definitions()
	self:_coach_weapon_definitions()
	self:_melee_weapon_definitions()
	self:_grenades_definitions()
	self:_carry_definitions()
	self:_team_definitions()
	self:_temporary_definitions()
	self:_cooldown_definitions()
	self:_shape_charge_definitions()

	self.definitions.lucky_charm = {
		name_id = "menu_lucky_charm",
		category = "what_is_this"
	}
	self.levels = {}

	for name, upgrade in pairs(self.definitions) do
		local unlock_lvl = upgrade.unlock_lvl or 1
		self.levels[unlock_lvl] = self.levels[unlock_lvl] or {}

		if upgrade.prio and upgrade.prio == "high" then
			table.insert(self.levels[unlock_lvl], 1, name)
		else
			table.insert(self.levels[unlock_lvl], name)
		end
	end

	self.progress = {
		{},
		{},
		{},
		{}
	}

	for name, upgrade in pairs(self.definitions) do
		if upgrade.tree then
			if upgrade.step then
				if self.progress[upgrade.tree][upgrade.step] then
					Application:error("upgrade collision", upgrade.tree, upgrade.step, self.progress[upgrade.tree][upgrade.step], name)
				end

				self.progress[upgrade.tree][upgrade.step] = name
			else
				print(name, upgrade.tree, "is in no step")
			end
		end
	end

	self.progress[1][49] = "mr_nice_guy"
	self.progress[2][49] = "mr_nice_guy"
	self.progress[3][49] = "mr_nice_guy"
	self.progress[4][49] = "mr_nice_guy"
	local free_dlcs = tweak_data:free_dlc_list()

	for _, data in pairs(self.definitions) do
		if free_dlcs[data.dlc] then
			data.dlc = nil
		end
	end
end

function UpgradesTweakData:_init_value_tables()
	self.values = {
		player = {},
		carry = {},
		trip_mine = {},
		ammo_bag = {},
		ecm_jammer = {},
		sentry_gun = {},
		doctor_bag = {},
		cable_tie = {},
		bodybags_bag = {},
		first_aid_kit = {},
		weapon = {},
		pistol = {},
		assault_rifle = {},
		smg = {},
		shotgun = {},
		saw = {},
		lmg = {},
		snp = {},
		akimbo = {},
		minigun = {},
		melee = {},
		temporary = {},
		cooldown = {},
		team = {}
	}
	self.values.team.player = {}
	self.values.team.weapon = {}
	self.values.team.pistol = {}
	self.values.team.akimbo = {}
	self.values.team.xp = {}
	self.values.team.armor = {}
	self.values.team.stamina = {}
	self.values.team.health = {}
	self.values.team.cash = {}
	self.values.team.damage_dampener = {}
end

function UpgradesTweakData:_init_values()
	self.values.weapon = self.values.weapon or {}
	self.values.weapon.reload_speed_multiplier = {
		1
	}
	self.values.weapon.damage_multiplier = {
		1
	}
	self.values.weapon.swap_speed_multiplier = {
		1.8
	}
	self.values.weapon.passive_reload_speed_multiplier = {
		1.1
	}
	self.values.weapon.auto_spread_multiplier = {
		1
	}
	self.values.weapon.spread_multiplier = {
		0.9
	}
	self.values.weapon.fire_rate_multiplier = {
		2
	}
	self.values.pistol = self.values.pistol or {}
	self.values.pistol.exit_run_speed_multiplier = {
		1.25
	}
	self.values.assault_rifle = self.values.assault_rifle or {}
	self.values.smg = self.values.smg or {}
	self.values.shotgun = self.values.shotgun or {}
	self.values.carry = self.values.carry or {}
	self.values.carry.catch_interaction_speed = {
		0.6,
		0.1
	}
	self.values.carry.carry_bag_count = {
		2
	}
	self.values.cable_tie = self.values.cable_tie or {}
	self.values.cable_tie.quantity_unlimited = {
		true
	}
	self.values.temporary = self.values.temporary or {}
	self.values.temporary.combat_medic_enter_steelsight_speed_multiplier = {
		{
			1.2,
			15
		}
	}
	self.values.temporary.pistol_revive_from_bleed_out = {
		{
			true,
			1
		}
	}
	self.values.temporary.revive_health_boost = {
		{
			true,
			10
		}
	}
	self.values.cooldown = self.values.cooldown or {}
	self.values.team = self.values.team or {}
	self.values.team.player = self.values.team.player or {}
	self.values.team.pistol = self.values.team.pistol or {}
	self.values.team.weapon = self.values.team.weapon or {}
	self.values.team.xp = self.values.team.xp or {}
	self.values.team.armor = self.values.team.armor or {}
	self.values.team.stamina = self.values.team.stamina or {}
	self.values.saw = self.values.saw or {}
	self.values.saw.recoil_multiplier = {
		0.75
	}
	self.values.saw.fire_rate_multiplier = {
		1.25,
		1.5
	}
end

function UpgradesTweakData:_player_definitions()
	self.definitions.body_armor1 = {
		name_id = "bm_armor_level_2",
		armor_id = "level_2",
		category = "armor"
	}
	self.definitions.body_armor2 = {
		name_id = "bm_armor_level_3",
		armor_id = "level_3",
		category = "armor"
	}
	self.definitions.body_armor3 = {
		name_id = "bm_armor_level_4",
		armor_id = "level_4",
		category = "armor"
	}
	self.definitions.body_armor4 = {
		name_id = "bm_armor_level_5",
		armor_id = "level_5",
		category = "armor"
	}
	self.definitions.body_armor5 = {
		name_id = "bm_armor_level_6",
		armor_id = "level_6",
		category = "armor"
	}
	self.definitions.body_armor6 = {
		name_id = "bm_armor_level_7",
		armor_id = "level_7",
		category = "armor"
	}
	self.definitions.thick_skin = {
		description_text_id = "thick_skin",
		category = "equipment",
		equipment_id = "thick_skin",
		tree = 2,
		image = "upgrades_thugskin",
		image_slice = "upgrades_thugskin_slice",
		title_id = "debug_upgrade_player_upgrade",
		slot = 2,
		subtitle_id = "debug_upgrade_thick_skin1",
		name_id = "debug_upgrade_thick_skin1",
		icon = "equipment_armor",
		unlock_lvl = 0,
		step = 2,
		aquire = {
			upgrade = "thick_skin1"
		}
	}

	for i, _ in ipairs(self.values.player.thick_skin) do
		local depends_on = i - 1 > 0 and "thick_skin" .. i - 1
		local unlock_lvl = 3
		local prio = i == 1 and "high"
		self.definitions["thick_skin" .. i] = {
			description_text_id = "thick_skin",
			tree = 2,
			image = "upgrades_thugskin",
			image_slice = "upgrades_thugskin_slice",
			title_id = "debug_upgrade_player_upgrade",
			category = "feature",
			icon = "equipment_thick_skin",
			step = self.steps.player.thick_skin[i],
			subtitle_id = "debug_upgrade_thick_skin" .. i,
			name_id = "debug_upgrade_thick_skin" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "thick_skin",
				category = "player",
				value = i
			}
		}
	end

	self.definitions.extra_start_out_ammo = {
		description_text_id = "extra_ammo_multiplier",
		category = "equipment",
		equipment_id = "extra_start_out_ammo",
		tree = 3,
		image = "upgrades_extrastartammo",
		image_slice = "upgrades_extrastartammo_slice",
		slot = 2,
		title_id = "debug_upgrade_player_upgrade",
		prio = "high",
		subtitle_id = "debug_upgrade_extra_start_out_ammo1",
		name_id = "debug_upgrade_extra_start_out_ammo1",
		icon = "equipment_extra_start_out_ammo",
		unlock_lvl = 13,
		step = 2,
		aquire = {
			upgrade = "extra_ammo_multiplier1"
		}
	}

	for i, _ in ipairs(self.values.player.extra_ammo_multiplier) do
		local depends_on = i - 1 > 0 and "extra_ammo_multiplier" .. i - 1
		local unlock_lvl = 14
		local prio = i == 1 and "high"
		self.definitions["extra_ammo_multiplier" .. i] = {
			description_text_id = "extra_ammo_multiplier",
			tree = 3,
			image = "upgrades_extrastartammo",
			image_slice = "upgrades_extrastartammo_slice",
			title_id = "debug_upgrade_player_upgrade",
			category = "feature",
			icon = "equipment_extra_start_out_ammo",
			step = self.steps.player.extra_ammo_multiplier[i],
			name_id = "debug_upgrade_extra_start_out_ammo" .. i,
			subtitle_id = "debug_upgrade_extra_start_out_ammo" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "extra_ammo_multiplier",
				category = "player",
				value = i
			}
		}
	end

	self.definitions.player_add_armor_stat_skill_ammo_mul = {
		name_id = "menu_player_add_armor_stat_skill_ammo_mul",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "add_armor_stat_skill_ammo_mul",
			category = "player"
		}
	}
	self.definitions.player_overkill_health_to_damage_multiplier = {
		name_id = "menu_player_overkill_health_to_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "overkill_health_to_damage_multiplier",
			category = "player"
		}
	}
	self.definitions.player_detection_risk_add_crit_chance_1 = {
		name_id = "menu_player_detection_risk_add_crit_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "detection_risk_add_crit_chance",
			category = "player"
		}
	}
	self.definitions.player_detection_risk_add_crit_chance_2 = {
		name_id = "menu_player_detection_risk_add_crit_chance",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "detection_risk_add_crit_chance",
			category = "player"
		}
	}
	self.definitions.player_detection_risk_add_dodge_chance_1 = {
		name_id = "menu_player_detection_risk_add_dodge_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "detection_risk_add_dodge_chance",
			category = "player"
		}
	}
	self.definitions.player_detection_risk_add_dodge_chance_2 = {
		name_id = "menu_player_detection_risk_add_dodge_chance",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "detection_risk_add_dodge_chance",
			category = "player"
		}
	}
	self.definitions.player_detection_risk_damage_multiplier = {
		name_id = "menu_player_detection_risk_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "detection_risk_damage_multiplier",
			category = "player"
		}
	}
	self.definitions.player_melee_kill_snatch_pager_chance = {
		name_id = "menu_player_melee_kill_snatch_pager_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "melee_kill_snatch_pager_chance",
			category = "player"
		}
	}
	self.definitions.player_critical_hit_chance_1 = {
		incremental = true,
		name_id = "menu_player_critical_hit_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "critical_hit_chance",
			category = "player"
		}
	}
	self.definitions.player_critical_hit_chance_2 = {
		incremental = true,
		name_id = "menu_player_critical_hit_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "critical_hit_chance",
			category = "player"
		}
	}
	self.definitions.player_unseen_increased_crit_chance_1 = {
		name_id = "menu_player_unseen_increased_crit_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "unseen_increased_crit_chance",
			category = "player"
		}
	}
	self.definitions.player_unseen_increased_crit_chance_2 = {
		name_id = "menu_player_unseen_increased_crit_chance",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "unseen_increased_crit_chance",
			category = "player"
		}
	}
	self.definitions.player_unseen_temp_increased_crit_chance_1 = {
		name_id = "menu_player_unseen_increased_crit_chance",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "unseen_strike",
			category = "temporary"
		}
	}
	self.definitions.player_unseen_temp_increased_crit_chance_2 = {
		name_id = "menu_player_unseen_increased_crit_chance",
		category = "temporary",
		upgrade = {
			value = 2,
			upgrade = "unseen_strike",
			category = "temporary"
		}
	}
	self.definitions.player_mark_enemy_time_multiplier = {
		name_id = "menu_player_mark_enemy_time_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "mark_enemy_time_multiplier",
			category = "player"
		}
	}
	self.definitions.player_minion_master_health_multiplier = {
		name_id = "menu_player_minion_master_health_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "minion_master_health_multiplier",
			category = "player"
		}
	}
	self.definitions.player_minion_master_speed_multiplier = {
		name_id = "menu_player_minion_master_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "minion_master_speed_multiplier",
			category = "player"
		}
	}
	self.definitions.player_flashbang_multiplier_1 = {
		name_id = "menu_player_flashbang_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "flashbang_multiplier",
			category = "player"
		}
	}
	self.definitions.player_flashbang_multiplier_2 = {
		name_id = "menu_player_flashbang_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "flashbang_multiplier",
			category = "player"
		}
	}
	self.definitions.player_revive_damage_reduction_1 = {
		name_id = "menu_player_revive_damage_reduction",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "revive_damage_reduction",
			category = "player"
		}
	}
	self.definitions.player_revive_damage_reduction_level_1 = {
		name_id = "menu_player_revive_damage_reduction_level",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "revive_damage_reduction_level",
			category = "player"
		}
	}
	self.definitions.player_revive_damage_reduction_level_2 = {
		name_id = "menu_player_revive_damage_reduction_level",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "revive_damage_reduction_level",
			category = "player"
		}
	}
	self.definitions.player_passive_damage_reduction_1 = {
		name_id = "menu_player_damage_reduction",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_damage_reduction",
			category = "player"
		}
	}
	self.definitions.player_passive_health_multiplier_4 = {
		name_id = "menu_player_health_multiplier",
		category = "feature",
		upgrade = {
			value = 4,
			upgrade = "passive_health_multiplier",
			category = "player"
		}
	}
	self.definitions.player_tier_armor_multiplier_4 = {
		name_id = "menu_player_tier_armor_multiplier_3",
		category = "feature",
		upgrade = {
			value = 4,
			upgrade = "tier_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_tier_armor_multiplier_5 = {
		name_id = "menu_player_tier_armor_multiplier_3",
		category = "feature",
		upgrade = {
			value = 5,
			upgrade = "tier_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_tier_armor_multiplier_6 = {
		name_id = "menu_player_tier_armor_multiplier_3",
		category = "feature",
		upgrade = {
			value = 6,
			upgrade = "tier_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_pick_up_ammo_multiplier = {
		name_id = "menu_player_pick_up_ammo_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "pick_up_ammo_multiplier",
			category = "player"
		}
	}
	self.definitions.player_pick_up_ammo_multiplier_2 = {
		name_id = "menu_player_pick_up_ammo_multiplier_2",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "pick_up_ammo_multiplier",
			category = "player"
		}
	}
	self.definitions.player_regain_throwable_from_ammo_1 = {
		name_id = "menu_player_regain_throwable_from_ammo",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "regain_throwable_from_ammo",
			category = "player"
		}
	}
	self.definitions.player_panic_suppression = {
		name_id = "menu_player_panic_suppression",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "panic_suppression",
			category = "player"
		}
	}
	self.definitions.player_armor_regen_timer_multiplier_passive = {
		name_id = "menu_player_armor_regen_timer_multiplier_passive",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_regen_timer_multiplier_passive",
			category = "player"
		}
	}
	self.definitions.player_armor_regen_time_mul_1 = {
		name_id = "menu_player_armor_regen_time_mul",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_regen_time_mul",
			category = "player"
		}
	}
	self.definitions.player_revived_damage_resist_1 = {
		name_id = "menu_player_revived_damage_resist",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "revived_damage_resist",
			category = "temporary"
		}
	}
	self.definitions.player_temp_swap_weapon_faster_1 = {
		name_id = "menu_player_temp_swap_weapon_faster",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "swap_weapon_faster",
			category = "temporary"
		}
	}
	self.definitions.player_temp_reload_weapon_faster_1 = {
		name_id = "menu_player_temp_reload_weapon_faster",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "reload_weapon_faster",
			category = "temporary"
		}
	}
	self.definitions.player_temp_increased_movement_speed_1 = {
		name_id = "menu_player_temp_increased_movement_speed",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "increased_movement_speed",
			category = "temporary"
		}
	}
	self.definitions.player_hostage_health_regen_addend_1 = {
		name_id = "menu_player_hostage_health_regen_addend",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "hostage_health_regen_addend",
			category = "player"
		}
	}
	self.definitions.player_hostage_health_regen_addend_2 = {
		name_id = "menu_player_hostage_health_regen_addend",
		category = "temporary",
		upgrade = {
			value = 2,
			upgrade = "hostage_health_regen_addend",
			category = "player"
		}
	}
	self.definitions.player_passive_dodge_chance_3 = {
		name_id = "menu_player_run_dodge_chance",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "passive_dodge_chance",
			category = "player"
		}
	}
	self.definitions.player_passive_dodge_chance_4 = {
		name_id = "menu_player_run_dodge_chance",
		category = "feature",
		upgrade = {
			value = 4,
			upgrade = "passive_dodge_chance",
			category = "player"
		}
	}
	self.definitions.player_passive_always_regen_armor_1 = {
		name_id = "player_always_regen_armor",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_always_regen_armor",
			category = "player"
		}
	}
	self.definitions.team_passive_armor_multiplier = {
		name_id = "menu_team_passive_armor_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "multiplier",
			category = "armor"
		}
	}
	self.definitions.player_camouflage_multiplier = {
		name_id = "menu_player_camouflage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "camouflage_multiplier",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_uncover_multiplier = {
		name_id = "menu_player_uncover_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "uncover_multiplier",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_primary_weapon_when_downed = {
		name_id = "menu_player_primary_weapon_when_downed",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "primary_weapon_when_downed",
			category = "player"
		}
	}
	self.definitions.player_primary_weapon_when_carrying = {
		name_id = "menu_player_primary_weapon_when_carrying",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "primary_weapon_when_carrying",
			category = "player"
		}
	}
	self.definitions.player_messiah_revive_from_bleed_out_1 = {
		name_id = "menu_player_pistol_revive_from_bleed_out",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "messiah_revive_from_bleed_out",
			category = "player"
		}
	}
	self.definitions.player_recharge_messiah_1 = {
		name_id = "menu_player_recharge_pistol_messiah",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "recharge_messiah",
			category = "player"
		}
	}
	self.definitions.player_can_strafe_run = {
		name_id = "menu_player_can_strafe_run",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "can_strafe_run",
			category = "player"
		}
	}
	self.definitions.player_can_free_run = {
		name_id = "menu_player_can_free_run",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "can_free_run",
			category = "player"
		}
	}
	self.definitions.player_damage_shake_multiplier = {
		name_id = "menu_player_damage_shake_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "damage_shake_multiplier",
			category = "player"
		}
	}
	self.definitions.player_health_multiplier = {
		name_id = "menu_player_health_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "health_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_health_multiplier_1 = {
		name_id = "menu_player_health_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_health_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_health_multiplier_2 = {
		name_id = "menu_player_health_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "passive_health_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_health_multiplier_3 = {
		name_id = "menu_player_health_multiplier",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "passive_health_multiplier",
			category = "player"
		}
	}
	self.definitions.player_bleed_out_health_multiplier = {
		name_id = "menu_player_bleed_out_health_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "bleed_out_health_multiplier",
			category = "player"
		}
	}
	self.definitions.player_revive_interaction_speed_multiplier = {
		name_id = "menu_player_revive_interaction_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "revive_interaction_speed_multiplier",
			category = "player"
		}
	}
	self.definitions.player_shield_knock = {
		name_id = "menu_player_shield_knock",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "shield_knock",
			category = "player"
		}
	}
	self.definitions.player_steelsight_when_downed = {
		name_id = "menu_player_steelsight_when_downed",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "steelsight_when_downed",
			category = "player"
		}
	}
	self.definitions.player_double_drop_1 = {
		name_id = "menu_player_double_drop",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "double_drop",
			category = "player"
		}
	}
	self.definitions.player_increased_pickup_area_1 = {
		name_id = "menu_player_increased_pickup_area",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "increased_pickup_area",
			category = "player"
		}
	}
	self.definitions.player_armor_multiplier = {
		name_id = "menu_player_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_tier_armor_multiplier_1 = {
		name_id = "menu_player_tier_armor_multiplier_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "tier_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_tier_armor_multiplier_2 = {
		name_id = "menu_player_tier_armor_multiplier_2",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "tier_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_tier_armor_multiplier_3 = {
		name_id = "menu_player_tier_armor_multiplier_3",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "tier_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.single_shot_accuracy_inc_1 = {
		name_id = "menu_single_shot_accuracy_inc",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "single_shot_accuracy_inc",
			category = "player"
		}
	}
	self.definitions.head_shot_ammo_return_1 = {
		incremental = true,
		name_id = "menu_head_shot_ammo_return_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "head_shot_ammo_return",
			category = "player"
		}
	}
	self.definitions.head_shot_ammo_return_2 = {
		incremental = true,
		name_id = "menu_head_shot_ammo_return_2",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "head_shot_ammo_return",
			category = "player"
		}
	}
	self.definitions.player_passive_convert_enemies_health_multiplier_1 = {
		incremental = true,
		name_id = "menu_player_passive_convert_enemies_health_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_convert_enemies_health_multiplier",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_passive_convert_enemies_health_multiplier_2 = {
		incremental = true,
		name_id = "menu_player_passive_convert_enemies_health_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "passive_convert_enemies_health_multiplier",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_counter_strike_melee = {
		name_id = "menu_player_counter_strike_melee",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "counter_strike_melee",
			category = "player"
		}
	}
	self.definitions.player_counter_strike_spooc = {
		name_id = "menu_player_counter_strike_spooc",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "counter_strike_spooc",
			category = "player"
		}
	}
	self.definitions.player_extra_corpse_dispose_amount = {
		name_id = "menu_player_extra_corpse_dispose_amount",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "extra_corpse_dispose_amount",
			category = "player"
		}
	}
	self.definitions.player_armor_regen_timer_multiplier_tier = {
		name_id = "menu_player_armor_regen_timer_multiplier_tier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_regen_timer_multiplier_tier",
			category = "player"
		}
	}
	self.definitions.player_standstill_omniscience = {
		name_id = "menu_player_standstill_omniscience",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "standstill_omniscience",
			category = "player"
		}
	}
	self.definitions.player_mask_off_pickup = {
		name_id = "menu_player_mask_off_pickup",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "mask_off_pickup",
			category = "player"
		}
	}
	self.definitions.player_cleaner_cost_multiplier = {
		name_id = "menu_player_cleaner_cost_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "cleaner_cost_multiplier",
			category = "player"
		}
	}
	self.definitions.player_level_2_armor_addend = {
		name_id = "menu_player_level_2_armor_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_2_armor_addend",
			category = "player"
		}
	}
	self.definitions.player_level_3_armor_addend = {
		name_id = "menu_player_level_3_armor_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_3_armor_addend",
			category = "player"
		}
	}
	self.definitions.player_level_4_armor_addend = {
		name_id = "menu_player_level_4_armor_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_4_armor_addend",
			category = "player"
		}
	}
	self.definitions.player_level_2_dodge_addend_1 = {
		incremental = true,
		name_id = "menu_player_level_2_dodge_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_2_dodge_addend",
			category = "player"
		}
	}
	self.definitions.player_level_3_dodge_addend_1 = {
		incremental = true,
		name_id = "menu_player_level_3_dodge_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_3_dodge_addend",
			category = "player"
		}
	}
	self.definitions.player_level_4_dodge_addend_1 = {
		incremental = true,
		name_id = "menu_player_level_4_dodge_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_4_dodge_addend",
			category = "player"
		}
	}
	self.definitions.player_level_2_dodge_addend_2 = {
		incremental = true,
		name_id = "menu_player_level_2_dodge_addend",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "level_2_dodge_addend",
			category = "player"
		}
	}
	self.definitions.player_level_3_dodge_addend_2 = {
		incremental = true,
		name_id = "menu_player_level_3_dodge_addend",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "level_3_dodge_addend",
			category = "player"
		}
	}
	self.definitions.player_level_4_dodge_addend_2 = {
		incremental = true,
		name_id = "menu_player_level_4_dodge_addend",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "level_4_dodge_addend",
			category = "player"
		}
	}
	self.definitions.player_level_2_dodge_addend_3 = {
		incremental = true,
		name_id = "menu_player_level_2_dodge_addend",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "level_2_dodge_addend",
			category = "player"
		}
	}
	self.definitions.player_level_3_dodge_addend_3 = {
		incremental = true,
		name_id = "menu_player_level_3_dodge_addend",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "level_3_dodge_addend",
			category = "player"
		}
	}
	self.definitions.player_level_4_dodge_addend_3 = {
		incremental = true,
		name_id = "menu_player_level_4_dodge_addend",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "level_4_dodge_addend",
			category = "player"
		}
	}
	self.definitions.player_damage_shake_addend = {
		name_id = "menu_player_damage_shake_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "damage_shake_addend",
			category = "player"
		}
	}
	self.definitions.player_level_2_armor_multiplier_1 = {
		incremental = true,
		name_id = "menu_player_level_2_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_2_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_level_3_armor_multiplier_1 = {
		incremental = true,
		name_id = "menu_player_level_3_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_3_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_level_4_armor_multiplier_1 = {
		incremental = true,
		name_id = "menu_player_level_4_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_4_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_level_2_armor_multiplier_2 = {
		incremental = true,
		name_id = "menu_player_level_2_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_2_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_level_3_armor_multiplier_2 = {
		incremental = true,
		name_id = "menu_player_level_3_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_3_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_level_4_armor_multiplier_2 = {
		incremental = true,
		name_id = "menu_player_level_4_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_4_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_level_2_armor_multiplier_3 = {
		incremental = true,
		name_id = "menu_player_level_2_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_2_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_level_3_armor_multiplier_3 = {
		incremental = true,
		name_id = "menu_player_level_3_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_3_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_level_4_armor_multiplier_3 = {
		incremental = true,
		name_id = "menu_player_level_4_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_4_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_tier_dodge_chance_1 = {
		name_id = "menu_player_tier_dodge_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "tier_dodge_chance",
			category = "player"
		}
	}
	self.definitions.player_tier_dodge_chance_2 = {
		name_id = "menu_player_tier_dodge_chance",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "tier_dodge_chance",
			category = "player"
		}
	}
	self.definitions.player_tier_dodge_chance_3 = {
		name_id = "menu_player_tier_dodge_chance",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "tier_dodge_chance",
			category = "player"
		}
	}
	self.definitions.player_stand_still_crouch_camouflage_bonus_1 = {
		name_id = "menu_player_stand_still_crouch_camouflage_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "stand_still_crouch_camouflage_bonus",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_stand_still_crouch_camouflage_bonus_2 = {
		name_id = "menu_player_stand_still_crouch_camouflage_bonus",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "stand_still_crouch_camouflage_bonus",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_stand_still_crouch_camouflage_bonus_3 = {
		name_id = "menu_player_stand_still_crouch_camouflage_bonus",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "stand_still_crouch_camouflage_bonus",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_pick_lock_speed_multiplier = {
		name_id = "menu_player_pick_lock_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "pick_lock_speed_multiplier",
			category = "player"
		}
	}
	self.definitions.player_corpse_dispose_speed_multiplier = {
		name_id = "menu_player_corpse_dispose_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "corpse_dispose_speed_multiplier",
			category = "player"
		}
	}
	self.definitions.player_alarm_pager_speed_multiplier = {
		name_id = "menu_player_alarm_pager_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "alarm_pager_speed_multiplier",
			category = "player"
		}
	}
	self.definitions.player_melee_life_leech = {
		name_id = "menu_player_melee_life_leech",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "melee_life_leech",
			category = "temporary"
		}
	}
	self.definitions.player_damage_dampener_outnumbered_strong = {
		name_id = "menu_player_dmg_dampener_outnumbered_strong",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "dmg_dampener_outnumbered_strong",
			category = "temporary"
		}
	}
	self.definitions.player_melee_kill_life_leech = {
		name_id = "menu_player_melee_kill_life_leech",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "melee_kill_life_leech",
			category = "player"
		}
	}
	self.definitions.player_killshot_regen_armor_bonus = {
		name_id = "menu_player_killshot_regen_armor_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "killshot_regen_armor_bonus",
			category = "player"
		}
	}
	self.definitions.player_killshot_close_regen_armor_bonus = {
		name_id = "menu_player_killshot_close_regen_armor_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "killshot_close_regen_armor_bonus",
			category = "player"
		}
	}
	self.definitions.player_killshot_close_panic_chance = {
		name_id = "menu_player_killshot_close_panic_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "killshot_close_panic_chance",
			category = "player"
		}
	}
	self.definitions.player_damage_dampener_close_contact_1 = {
		name_id = "menu_player_dmg_dampener_close_contact",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "dmg_dampener_close_contact",
			category = "temporary"
		}
	}
	self.definitions.player_damage_dampener_close_contact_2 = {
		name_id = "menu_player_dmg_dampener_close_contact",
		category = "temporary",
		upgrade = {
			value = 2,
			upgrade = "dmg_dampener_close_contact",
			category = "temporary"
		}
	}
	self.definitions.player_damage_dampener_close_contact_3 = {
		name_id = "menu_player_dmg_dampener_close_contact",
		category = "temporary",
		upgrade = {
			value = 3,
			upgrade = "dmg_dampener_close_contact",
			category = "temporary"
		}
	}
	self.definitions.temporary_single_shot_fast_reload_1 = {
		name_id = "menu_temporary_single_shot_fast_reload",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "single_shot_fast_reload",
			category = "temporary"
		}
	}
	self.definitions.temporary_revive_damage_reduction_1 = {
		name_id = "menu_temporary_revive_damage_reduction",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "revive_damage_reduction",
			category = "temporary"
		}
	}
	self.definitions.melee_stacking_hit_damage_multiplier_1 = {
		name_id = "menu_melee_stacking_hit_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "stacking_hit_damage_multiplier",
			category = "melee"
		}
	}
	self.definitions.melee_stacking_hit_damage_multiplier_2 = {
		name_id = "menu_melee_stacking_hit_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "stacking_hit_damage_multiplier",
			category = "melee"
		}
	}
	self.definitions.melee_stacking_hit_expire_t = {
		name_id = "menu_melee_stacking_hit_expire_t",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "stacking_hit_expire_t",
			category = "melee"
		}
	}
	self.definitions.player_armor_health_store_amount_1 = {
		name_id = "menu_player_armor_health_store_amount",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_health_store_amount",
			category = "player"
		}
	}
	self.definitions.player_armor_health_store_amount_2 = {
		name_id = "menu_player_armor_health_store_amount",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "armor_health_store_amount",
			category = "player"
		}
	}
	self.definitions.player_armor_health_store_amount_3 = {
		name_id = "menu_player_armor_health_store_amount",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "armor_health_store_amount",
			category = "player"
		}
	}
	self.definitions.player_armor_max_health_store_multiplier = {
		name_id = "menu_player_armor_max_health_store_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_max_health_store_multiplier",
			category = "player"
		}
	}
	self.definitions.player_kill_change_regenerate_speed = {
		name_id = "menu_player_kill_change_regenerate_speed",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "kill_change_regenerate_speed",
			category = "player"
		}
	}
	self.definitions.player_armor_grinding_1 = {
		name_id = "menu_player_armor_grinding",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_grinding",
			category = "player"
		}
	}
	self.definitions.player_armor_increase_1 = {
		name_id = "menu_player_health_to_armor_conversion",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_increase",
			category = "player"
		}
	}
	self.definitions.player_armor_increase_2 = {
		name_id = "menu_player_health_to_armor_conversion",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "armor_increase",
			category = "player"
		}
	}
	self.definitions.player_armor_increase_3 = {
		name_id = "menu_player_health_to_armor_conversion",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "armor_increase",
			category = "player"
		}
	}
	self.definitions.player_health_decrease_1 = {
		name_id = "menu_player_health_decrease",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "health_decrease",
			category = "player"
		}
	}
	self.definitions.player_damage_to_armor_1 = {
		name_id = "menu_player_damage_to_armor",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "damage_to_armor",
			category = "player"
		}
	}

	for i, value in ipairs(self.values.player.perk_armor_regen_timer_multiplier) do
		self.definitions["player_perk_armor_regen_timer_multiplier_" .. tostring(i)] = {
			name_id = "menu_player_perk_armor_regen_timer_multiplier",
			category = "feature",
			upgrade = {
				upgrade = "perk_armor_regen_timer_multiplier",
				category = "player",
				value = i
			}
		}
	end

	for i, value in ipairs(self.values.player.perk_armor_loss_multiplier) do
		self.definitions["player_perk_armor_loss_multiplier_" .. tostring(i)] = {
			name_id = "menu_player_perk_armor_loss_multiplier",
			category = "feature",
			upgrade = {
				upgrade = "perk_armor_loss_multiplier",
				category = "player",
				value = i
			}
		}
	end

	self.definitions.player_passive_armor_multiplier_1 = {
		name_id = "menu_player_passive_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_armor_multiplier_2 = {
		name_id = "menu_player_passive_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "passive_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_armor_regen_timer_multiplier = {
		name_id = "menu_player_armor_regen_timer_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_regen_timer_multiplier",
			category = "player"
		}
	}
	self.definitions.player_armor_regen_timer_stand_still_multiplier = {
		name_id = "menu_player_armor_regen_timer_stand_still_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_regen_timer_stand_still_multiplier",
			category = "player"
		}
	}
	self.definitions.player_temp_melee_kill_increase_reload_speed_1 = {
		name_id = "menu_player_temp_melee_kill_increase_reload_speed",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "melee_kill_increase_reload_speed",
			category = "player"
		}
	}
	self.definitions.player_hostage_health_regen_addend = {
		name_id = "menu_player_hostage_health_regen_addend",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "hostage_health_regen_addend",
			category = "player"
		}
	}
	self.definitions.player_passive_health_regen = {
		name_id = "menu_player_passive_health_regen",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "passive_health_regen",
			category = "player"
		}
	}
	self.definitions.player_close_to_hostage_boost = {
		name_id = "menu_player_close_to_hostage_boost",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "close_to_hostage_boost",
			category = "player"
		}
	}
	self.definitions.player_stamina_multiplier = {
		name_id = "menu_player_stamina_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "stamina_multiplier",
			category = "player"
		}
	}
	self.definitions.player_stamina_regen_multiplier = {
		name_id = "menu_player_stamina_regen_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "stamina_regen_multiplier",
			category = "player"
		}
	}
	self.definitions.player_stamina_regen_timer_multiplier = {
		name_id = "menu_player_stamina_regen_timer_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "stamina_regen_timer_multiplier",
			category = "player"
		}
	}
	self.definitions.player_revived_health_regain_1 = {
		name_id = "menu_revived_health_regain",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "revived_health_regain",
			category = "player"
		}
	}
	self.definitions.player_run_speed_multiplier = {
		name_id = "menu_player_run_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "run_speed_multiplier",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_passive_dodge_chance_1 = {
		name_id = "menu_player_run_dodge_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_dodge_chance",
			category = "player"
		}
	}
	self.definitions.player_passive_dodge_chance_2 = {
		name_id = "menu_player_run_dodge_chance",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "passive_dodge_chance",
			category = "player"
		}
	}
	self.definitions.player_run_dodge_chance = {
		name_id = "menu_player_run_dodge_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "run_dodge_chance",
			category = "player"
		}
	}
	self.definitions.player_melee_damage_stacking_1 = {
		name_id = "menu_player_melee_damage_stacking",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "melee_damage_stacking",
			category = "player"
		}
	}
	self.definitions.player_walk_speed_multiplier = {
		name_id = "menu_player_walk_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "walk_speed_multiplier",
			category = "player"
		}
	}
	self.definitions.player_crouch_speed_multiplier = {
		incremental = true,
		name_id = "menu_player_crouch_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "crouch_speed_multiplier",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_crouch_speed_multiplier_2 = {
		incremental = true,
		name_id = "menu_player_crouch_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "crouch_speed_multiplier",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_gain_life_per_players = {
		name_id = "menu_player_gain_life_per_players",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "gain_life_per_players",
			category = "player"
		}
	}
	self.definitions.player_fall_damage_multiplier = {
		name_id = "menu_player_fall_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "fall_damage_multiplier",
			category = "player"
		}
	}
	self.definitions.player_fall_health_damage_multiplier = {
		name_id = "menu_player_fall_health_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "fall_health_damage_multiplier",
			category = "player"
		}
	}
	self.definitions.player_interacting_damage_multiplier = {
		name_id = "menu_player_interacting_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "interacting_damage_multiplier",
			category = "player"
		}
	}
	self.definitions.player_damage_health_ratio_multiplier = {
		name_id = "menu_player_damage_health_ratio_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "damage_health_ratio_multiplier",
			category = "player"
		}
	}
	self.definitions.player_melee_damage_health_ratio_multiplier = {
		name_id = "menu_player_melee_damage_health_ratio_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "melee_damage_health_ratio_multiplier",
			category = "player"
		}
	}
	self.definitions.player_melee_damage_multiplier = {
		name_id = "menu_player_melee_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "melee_damage_multiplier",
			category = "player"
		}
	}
	self.definitions.player_respawn_time_multiplier = {
		name_id = "menu_player_respawn_time_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "respawn_time_multiplier",
			category = "player"
		}
	}
	self.definitions.passive_player_xp_multiplier = {
		name_id = "menu_player_xp_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_xp_multiplier",
			category = "player"
		}
	}
	self.definitions.player_xp_multiplier = {
		name_id = "menu_player_xp_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "xp_multiplier",
			category = "player"
		}
	}
	self.definitions.player_non_special_melee_multiplier = {
		name_id = "menu_player_non_special_melee_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "non_special_melee_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_suspicion_bonus = {
		name_id = "menu_player_passive_suspicion_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_concealment_modifier",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_concealment_bonus_1 = {
		incremental = true,
		name_id = "menu_player_passive_suspicion_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "concealment_modifier",
			category = "player"
		}
	}
	self.definitions.player_concealment_bonus_2 = {
		incremental = true,
		name_id = "menu_player_passive_suspicion_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "concealment_modifier",
			category = "player"
		}
	}
	self.definitions.player_concealment_bonus_3 = {
		incremental = true,
		name_id = "menu_player_passive_suspicion_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "concealment_modifier",
			category = "player"
		}
	}
	self.definitions.player_melee_concealment_modifier = {
		incremental = true,
		name_id = "menu_player_melee_concealment_modifier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "melee_concealment_modifier",
			category = "player"
		}
	}
	self.definitions.player_melee_sharp_damage_multiplier = {
		incremental = true,
		name_id = "menu_player_melee_sharp_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "melee_sharp_damage_multiplier",
			category = "player"
		}
	}
	self.definitions.player_suspicion_bonus = {
		name_id = "menu_player_suspicion_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "suspicion_multiplier",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_loose_ammo_restore_health_give_team = {
		name_id = "menu_player_loose_ammo_restore_health_give_team",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "loose_ammo_restore_health_give_team",
			category = "player"
		}
	}
	self.definitions.player_uncover_progress_mul = {
		name_id = "player_uncover_progress_mul",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "uncover_progress_mul",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_uncover_progress_decay_mul = {
		name_id = "menu_player_uncover_progress_decay_mul",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "uncover_progress_decay_mul",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_camouflage_bonus_1 = {
		name_id = "menu_player_camouflage_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "camouflage_bonus",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_camouflage_bonus_2 = {
		name_id = "menu_player_camouflage_bonus",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "camouflage_bonus",
			synced = true,
			category = "player"
		}
	}
	self.definitions.temporary_damage_speed_multiplier = {
		name_id = "menu_temporary_damage_speed_1",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "damage_speed_multiplier",
			category = "temporary"
		}
	}
	self.definitions.player_team_damage_speed_multiplier_send = {
		name_id = "menu_temporary_damage_speed_2",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "team_damage_speed_multiplier_send",
			category = "player"
		}
	}
	self.definitions.temporary_team_damage_speed_multiplier_received = {
		name_id = "menu_temporary_team_damage_speed",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "team_damage_speed_multiplier_received",
			category = "temporary"
		}
	}
	self.definitions.player_suppressed_bonus = {
		name_id = "menu_player_suppressed_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "suppressed_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_suppression_bonus_1 = {
		name_id = "menu_player_suppression_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_suppression_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_suppression_bonus_2 = {
		name_id = "menu_player_suppression_bonus",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "passive_suppression_multiplier",
			category = "player"
		}
	}
	self.definitions.player_suppression_bonus = {
		name_id = "menu_player_suppression_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "suppression_multiplier",
			category = "player"
		}
	}
	self.definitions.player_civilian_reviver = {
		name_id = "menu_player_civilian_reviver",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "civilian_reviver",
			category = "player"
		}
	}
	self.definitions.player_overkill_damage_multiplier = {
		name_id = "menu_player_overkill_damage_multiplier",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "overkill_damage_multiplier",
			category = "temporary"
		}
	}
	self.definitions.player_overkill_all_weapons = {
		name_id = "menu_player_overkill_all_weapons",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "overkill_all_weapons",
			category = "player"
		}
	}
	self.definitions.player_berserker_no_ammo_cost = {
		name_id = "menu_player_berserker_no_ammo_cost",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "berserker_no_ammo_cost",
			category = "player"
		}
	}
	self.definitions.player_damage_multiplier_outnumbered = {
		name_id = "menu_player_dmg_mul_outnumbered",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "dmg_multiplier_outnumbered",
			category = "temporary"
		}
	}
	self.definitions.player_damage_dampener_outnumbered = {
		name_id = "menu_player_dmg_damp_outnumbered",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "dmg_dampener_outnumbered",
			category = "temporary"
		}
	}
	self.definitions.player_corpse_alarm_pager_bluff = {
		name_id = "menu_player_pager_dis",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "corpse_alarm_pager_bluff",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_buy_bodybags_asset = {
		name_id = "menu_player_buy_bodybags_asset",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "buy_bodybags_asset",
			category = "player"
		}
	}
	self.definitions.player_corpse_dispose = {
		name_id = "menu_player_corpse_disp",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "corpse_dispose",
			category = "player"
		}
	}
	self.definitions.player_corpse_dispose_amount_1 = {
		name_id = "menu_player_corpse_disp_amount_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "corpse_dispose_amount",
			category = "player"
		}
	}
	self.definitions.player_corpse_dispose_amount_2 = {
		name_id = "menu_player_corpse_disp_amount_2",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "corpse_dispose_amount",
			category = "player"
		}
	}
	self.definitions.player_taser_malfunction = {
		name_id = "menu_player_taser_malf",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "taser_malfunction",
			category = "player"
		}
	}
	self.definitions.player_taser_self_shock = {
		name_id = "menu_player_taser_shock",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "taser_self_shock",
			category = "player"
		}
	}
	self.definitions.player_electrocution_resistance = {
		name_id = "menu_player_electrocution_resistance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "electrocution_resistance_multiplier",
			category = "player"
		}
	}
	self.definitions.player_tased_recover_multiplier = {
		name_id = "menu_player_tased_recover_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "tased_recover_multiplier",
			category = "player"
		}
	}
	self.definitions.player_secured_bags_speed_multiplier = {
		name_id = "menu_player_secured_bags_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "secured_bags_speed_multiplier",
			category = "player"
		}
	}
	self.definitions.player_secured_bags_money_multiplier = {
		name_id = "menu_secured_bags_money_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "secured_bags_money_multiplier",
			category = "player"
		}
	}
	self.definitions.player_silent_kill = {
		name_id = "menu_player_silent_kill",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "silent_kill",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_armor_carry_bonus_1 = {
		name_id = "menu_player_armor_carry_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_carry_bonus",
			category = "player"
		}
	}
	self.definitions.player_run_and_shoot_1 = {
		name_id = "menu_run_and_shoot",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "run_and_shoot",
			category = "player"
		}
	}
	self.definitions.player_automatic_faster_reload_1 = {
		name_id = "menu_automatic_faster_reload",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "automatic_faster_reload",
			category = "player"
		}
	}
	self.definitions.player_melee_knockdown_mul = {
		name_id = "menu_player_melee_knockdown_mul",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "melee_knockdown_mul",
			category = "player"
		}
	}
	self.definitions.player_suppression_mul_1 = {
		name_id = "menu_player_suppression_mul_2",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "suppression_multiplier",
			category = "player"
		}
	}
	self.definitions.player_damage_dampener = {
		name_id = "menu_player_damage_dampener",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "damage_dampener",
			category = "player"
		}
	}
	self.definitions.player_melee_damage_dampener = {
		name_id = "menu_player_melee_damage_dampener",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "melee_damage_dampener",
			category = "player"
		}
	}
	self.definitions.player_marked_enemy_extra_damage = {
		name_id = "menu_player_marked_enemy_extra_damage",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "marked_enemy_extra_damage",
			category = "player"
		}
	}
	self.definitions.player_marked_distance_mul = {
		name_id = "menu_player_marked_distance_mul",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "marked_distance_mul",
			category = "player"
		}
	}
	self.definitions.player_civ_intimidation_mul = {
		name_id = "menu_player_civ_intimidation_mul",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "civ_intimidation_mul",
			category = "player"
		}
	}
	self.definitions.player_civ_harmless_bullets = {
		name_id = "menu_player_civ_harmless_bullets",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "civ_harmless_bullets",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_civ_harmless_melee = {
		name_id = "menu_player_civ_harmless_melee",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "civ_harmless_melee",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_civ_calming_alerts = {
		name_id = "menu_player_civ_calming_alerts",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "civ_calming_alerts",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_special_enemy_highlight = {
		name_id = "menu_player_special_enemy_highlight",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "special_enemy_highlight",
			category = "player"
		}
	}
	self.definitions.player_drill_alert = {
		name_id = "menu_player_drill_alert",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "drill_alert_rad",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_silent_drill = {
		name_id = "menu_player_silent_drill",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "silent_drill",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_drill_speed_multiplier1 = {
		name_id = "menu_player_drill_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "drill_speed_multiplier",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_drill_speed_multiplier2 = {
		name_id = "menu_player_drill_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "drill_speed_multiplier",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_drill_melee_hit_restart_chance_1 = {
		name_id = "menu_player_drill_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "drill_melee_hit_restart_chance",
			category = "player"
		}
	}
	self.definitions.player_saw_speed_multiplier_1 = {
		name_id = "menu_player_saw_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "saw_speed_multiplier",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_saw_speed_multiplier_2 = {
		name_id = "menu_player_saw_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "saw_speed_multiplier",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_drill_fix_interaction_speed_multiplier = {
		name_id = "menu_player_drill_fix_interaction_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "drill_fix_interaction_speed_multiplier",
			category = "player"
		}
	}
	self.definitions.player_dye_pack_chance_multiplier = {
		name_id = "menu_player_dye_pack_chance_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "dye_pack_chance_multiplier",
			category = "player"
		}
	}
	self.definitions.player_dye_pack_cash_loss_multiplier = {
		name_id = "menu_player_dye_pack_cash_loss_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "dye_pack_cash_loss_multiplier",
			category = "player"
		}
	}
	self.definitions.player_cheat_death_chance_1 = {
		name_id = "menu_player_cheat_death_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "cheat_death_chance",
			category = "player"
		}
	}
	self.definitions.player_cheat_death_chance_2 = {
		name_id = "menu_player_cheat_death_chance",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "cheat_death_chance",
			category = "player"
		}
	}
	self.definitions.player_additional_lives_1 = {
		name_id = "menu_player_additional_lives_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "additional_lives",
			category = "player"
		}
	}
	self.definitions.player_additional_lives_2 = {
		name_id = "menu_player_additional_lives_2",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "additional_lives",
			category = "player"
		}
	}
	self.definitions.player_trip_mine_shaped_charge = {
		name_id = "menu_player_trip_mine_shaped_charge",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "trip_mine_shaped_charge",
			category = "player"
		}
	}
	self.definitions.player_small_loot_multiplier_1 = {
		name_id = "menu_player_small_loot_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "small_loot_multiplier",
			category = "player"
		}
	}
	self.definitions.player_intimidate_enemies = {
		name_id = "menu_player_intimidate_enemies",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "intimidate_enemies",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_intimidate_specials = {
		name_id = "menu_player_intimidate_specials",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "intimidate_specials",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_passive_empowered_intimidation = {
		name_id = "menu_player_passive_empowered_intimidation",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "empowered_intimidation_mul",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_intimidation_multiplier = {
		name_id = "menu_player_intimidation_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "intimidation_multiplier",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_sentry_gun_deploy_time_multiplier = {
		name_id = "menu_player_sentry_gun_deploy_time_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "sentry_gun_deploy_time_multiplier",
			category = "player"
		}
	}
	self.definitions.player_trip_mine_deploy_time_multiplier = {
		incremental = true,
		name_id = "menu_player_trip_mine_deploy_time_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "trip_mine_deploy_time_multiplier",
			category = "player"
		}
	}
	self.definitions.player_trip_mine_deploy_time_multiplier_2 = {
		incremental = true,
		name_id = "menu_player_trip_mine_deploy_time_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "trip_mine_deploy_time_multiplier",
			category = "player"
		}
	}
	self.definitions.player_convert_enemies = {
		name_id = "menu_player_convert_enemies",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "convert_enemies",
			category = "player"
		}
	}
	self.definitions.player_convert_enemies_max_minions_1 = {
		incremental = true,
		name_id = "menu_player_convert_enemies_max_minions",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "convert_enemies_max_minions",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_convert_enemies_max_minions_2 = {
		incremental = true,
		name_id = "menu_player_convert_enemies_max_minions",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "convert_enemies_max_minions",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_super_syndrome_1 = {
		name_id = "menu_player_super_syndrome",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "super_syndrome",
			category = "player"
		}
	}
	self.definitions.player_convert_enemies_interaction_speed_multiplier = {
		name_id = "menu_player_convert_enemies_interaction_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "convert_enemies_interaction_speed_multiplier",
			category = "player"
		}
	}
	self.definitions.player_convert_enemies_health_multiplier = {
		name_id = "menu_player_convert_enemies_health_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "convert_enemies_health_multiplier",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_convert_enemies_damage_multiplier_1 = {
		name_id = "menu_player_convert_enemies_damage_multiplier_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "convert_enemies_damage_multiplier",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_convert_enemies_damage_multiplier_2 = {
		name_id = "menu_player_convert_enemies_damage_multiplier_2",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "convert_enemies_damage_multiplier",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_passive_convert_enemies_damage_multiplier = {
		name_id = "menu_player_passive_convert_enemies_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_convert_enemies_damage_multiplier",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_passive_intimidate_range_mul = {
		name_id = "menu_player_intimidate_range_mul",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_intimidate_range_mul",
			category = "player"
		}
	}
	self.definitions.deploy_interact_faster_1 = {
		name_id = "menu_deploy_interact_faster",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "deploy_interact_faster",
			category = "player"
		}
	}
	self.definitions.second_deployable_1 = {
		name_id = "menu_second_deployable",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "second_deployable",
			category = "player"
		}
	}
	self.definitions.player_intimidate_range_mul = {
		name_id = "menu_player_intimidate_range_mul",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "intimidate_range_mul",
			category = "player"
		}
	}
	self.definitions.player_intimidate_aura = {
		name_id = "menu_player_intimidate_aura",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "intimidate_aura",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_civilian_gives_ammo = {
		name_id = "menu_player_civilian_gives_ammo",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "civilian_gives_ammo",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_drill_autorepair_1 = {
		name_id = "menu_player_drill_autorepair",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "drill_autorepair_1",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_drill_autorepair_2 = {
		name_id = "menu_player_drill_autorepair",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "drill_autorepair_2",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_hostage_trade = {
		name_id = "menu_player_hostage_trade",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "hostage_trade",
			category = "player"
		}
	}
	self.definitions.player_sec_camera_highlight = {
		name_id = "menu_player_sec_camera_highlight",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "sec_camera_highlight",
			category = "player"
		}
	}
	self.definitions.player_sec_camera_highlight_mask_off = {
		name_id = "menu_player_sec_camera_highlight_mask_off",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "sec_camera_highlight_mask_off",
			category = "player"
		}
	}
	self.definitions.player_special_enemy_highlight_mask_off = {
		name_id = "menu_player_special_enemy_highlight_mask_off",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "special_enemy_highlight_mask_off",
			category = "player"
		}
	}
	self.definitions.player_morale_boost = {
		name_id = "menu_player_morale_boost",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "morale_boost",
			category = "player"
		}
	}
	self.definitions.player_ap_bullets_1 = {
		name_id = "menu_player_ap_bullets_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "ap_bullets",
			category = "player"
		}
	}
	self.definitions.player_morale_boost_cooldown_multiplier = {
		name_id = "menu_player_morale_boost_cooldown_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "morale_boost_cooldown_multiplier",
			category = "player"
		}
	}
	self.definitions.player_long_dis_revive_2 = {
		name_id = "menu_player_long_dis_revive",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "long_dis_revive",
			category = "player"
		}
	}
	self.definitions.player_healing_reduction_1 = {
		name_id = "menu_player_healing_reduction",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "healing_reduction",
			category = "player"
		}
	}
	self.definitions.player_healing_reduction_2 = {
		name_id = "menu_player_healing_reduction",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "healing_reduction",
			category = "player"
		}
	}
	self.definitions.player_health_damage_reduction_1 = {
		name_id = "menu_player_health_damage_reduction",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "health_damage_reduction",
			category = "player"
		}
	}
	self.definitions.player_health_damage_reduction_2 = {
		name_id = "menu_player_health_damage_reduction",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "health_damage_reduction",
			category = "player"
		}
	}
	self.definitions.player_max_health_reduction_1 = {
		name_id = "menu_player_max_health_reduction",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "max_health_reduction",
			category = "player"
		}
	}
	self.definitions.player_pick_lock_easy = {
		name_id = "menu_player_pick_lock_easy",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "pick_lock_easy",
			category = "player"
		}
	}
	self.definitions.player_pick_lock_hard = {
		name_id = "menu_player_pick_lock_hard",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "pick_lock_hard",
			category = "player"
		}
	}
	self.definitions.player_pick_lock_easy_speed_multiplier = {
		name_id = "menu_player_pick_lock_easy_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "pick_lock_easy_speed_multiplier",
			category = "player"
		}
	}
	self.definitions.player_loot_drop_multiplier_1 = {
		name_id = "menu_player_loot_drop_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "loot_drop_multiplier",
			category = "player"
		}
	}
	self.definitions.player_loot_drop_multiplier_2 = {
		name_id = "menu_player_loot_drop_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "loot_drop_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_loot_drop_multiplier = {
		name_id = "menu_player_passive_loot_drop_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_loot_drop_multiplier",
			category = "player"
		}
	}
	self.definitions.weapon_passive_armor_piercing_chance = {
		name_id = "menu_weapon_passive_armor_piercing_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_piercing_chance",
			category = "weapon"
		}
	}
	self.definitions.weapon_armor_piercing_chance_2 = {
		name_id = "menu_weapon_armor_piercing_chance_2",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_piercing_chance_2",
			category = "weapon"
		}
	}
	self.definitions.weapon_silencer_armor_piercing_chance_1 = {
		incremental = true,
		name_id = "menu_weapon_silencer_armor_piercing_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_piercing_chance_silencer",
			category = "weapon"
		}
	}
	self.definitions.weapon_silencer_armor_piercing_chance_2 = {
		incremental = true,
		name_id = "menu_weapon_silencer_armor_piercing_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_piercing_chance_silencer",
			category = "weapon"
		}
	}
	self.definitions.weapon_automatic_head_shot_add_1 = {
		name_id = "menu_weapon_automatic_head_shot_add",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "automatic_head_shot_add",
			category = "weapon"
		}
	}
	self.definitions.weapon_automatic_head_shot_add_2 = {
		name_id = "menu_weapon_automatic_head_shot_add",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "automatic_head_shot_add",
			category = "weapon"
		}
	}
	self.definitions.player_passive_armor_movement_penalty_multiplier = {
		name_id = "menu_passive_armor_movement_penalty_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_armor_movement_penalty_multiplier",
			category = "player"
		}
	}
	self.definitions.player_buy_cost_multiplier_1 = {
		name_id = "menu_player_buy_cost_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "buy_cost_multiplier",
			category = "player"
		}
	}
	self.definitions.player_buy_cost_multiplier_2 = {
		name_id = "menu_player_buy_cost_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "buy_cost_multiplier",
			category = "player"
		}
	}
	self.definitions.player_crime_net_deal = {
		name_id = "menu_player_crime_net_deal",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "crime_net_deal",
			category = "player"
		}
	}
	self.definitions.player_crime_net_deal_2 = {
		name_id = "menu_player_crime_net_deal",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "crime_net_deal",
			category = "player"
		}
	}
	self.definitions.player_sell_cost_multiplier_1 = {
		name_id = "menu_player_sell_cost_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "sell_cost_multiplier",
			category = "player"
		}
	}
	self.definitions.player_crafting_weapon_multiplier = {
		name_id = "menu_player_crafting_weapon_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "crafting_weapon_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_crafting_weapon_multiplier_1 = {
		name_id = "menu_player_crafting_weapon_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_crafting_weapon_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_crafting_weapon_multiplier_2 = {
		name_id = "menu_player_crafting_weapon_multiplier_2",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "passive_crafting_weapon_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_crafting_weapon_multiplier_3 = {
		name_id = "menu_player_crafting_weapon_multiplier_3",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "passive_crafting_weapon_multiplier",
			category = "player"
		}
	}
	self.definitions.player_crafting_mask_multiplier = {
		name_id = "menu_player_crafting_mask_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "crafting_mask_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_crafting_mask_multiplier_1 = {
		name_id = "menu_player_crafting_mask_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_crafting_mask_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_crafting_mask_multiplier_2 = {
		name_id = "menu_player_crafting_mask_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "passive_crafting_mask_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_crafting_mask_multiplier_3 = {
		name_id = "menu_player_crafting_mask_multiplier",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "passive_crafting_mask_multiplier",
			category = "player"
		}
	}
	self.definitions.player_additional_assets = {
		name_id = "menu_player_additional_assets",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "additional_assets",
			category = "player"
		}
	}
	self.definitions.player_assets_cost_multiplier = {
		name_id = "menu_player_assets_cost_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "assets_cost_multiplier",
			category = "player"
		}
	}
	self.definitions.player_assets_cost_multiplier_b = {
		name_id = "menu_player_assets_cost_multiplier_b",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "assets_cost_multiplier_b",
			category = "player"
		}
	}
	self.definitions.player_premium_contract_cost_multiplier = {
		name_id = "menu_player_premium_contract_cost_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "premium_contract_cost_multiplier",
			category = "player"
		}
	}
	self.definitions.passive_player_assets_cost_multiplier = {
		name_id = "menu_passive_player_assets_cost_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_assets_cost_multiplier",
			category = "player"
		}
	}
	self.definitions.player_revive_health_boost = {
		name_id = "menu_player_revive_health_boost",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "revive_health_boost",
			category = "player"
		}
	}
	self.definitions.player_run_and_shoot = {
		name_id = "menu_player_run_and_shoot",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "run_and_shoot",
			category = "player"
		}
	}
	self.definitions.player_carry_sentry_and_trip = {
		name_id = "menu_player_carry_sentry_and_trip",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "carry_sentry_and_trip",
			category = "player"
		}
	}
	self.definitions.player_run_and_reload = {
		name_id = "menu_player_run_and_reload",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "run_and_reload",
			category = "player"
		}
	}
	self.definitions.player_armor_depleted_stagger_shot_1 = {
		name_id = "menu_player_armor_depleted_stagger_shot",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_depleted_stagger_shot",
			category = "player"
		}
	}
	self.definitions.player_armor_depleted_stagger_shot_2 = {
		name_id = "menu_player_armor_depleted_stagger_shot",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "armor_depleted_stagger_shot",
			category = "player"
		}
	}
	self.definitions.player_level_interaction_timer_multiplier = {
		name_id = "menu_player_level_interaction_timer_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_interaction_timer_multiplier",
			category = "player"
		}
	}
	self.definitions.player_steelsight_normal_movement_speed = {
		name_id = "menu_player_steelsight_normal_movement_speed",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "steelsight_normal_movement_speed",
			category = "player"
		}
	}
	self.definitions.player_headshot_regen_armor_bonus_1 = {
		name_id = "menu_player_headshot_regen_armor_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "headshot_regen_armor_bonus",
			category = "player"
		}
	}
	self.definitions.player_headshot_regen_armor_bonus_2 = {
		name_id = "menu_player_headshot_regen_armor_bonus",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "headshot_regen_armor_bonus",
			category = "player"
		}
	}
	self.definitions.player_resist_firing_tased = {
		name_id = "menu_player_resist_firing_tased",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "resist_firing_tased",
			category = "player"
		}
	}
	self.definitions.player_crouch_dodge_chance_1 = {
		name_id = "menu_player_crouch_dodge_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "crouch_dodge_chance",
			category = "player"
		}
	}
	self.definitions.player_crouch_dodge_chance_2 = {
		name_id = "menu_player_crouch_dodge_chance",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "crouch_dodge_chance",
			category = "player"
		}
	}
	self.definitions.player_on_zipline_dodge_chance = {
		name_id = "menu_player_on_zipline_dodge_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "on_zipline_dodge_chance",
			category = "player"
		}
	}
	self.definitions.player_movement_speed_multiplier = {
		name_id = "menu_player_movement_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "movement_speed_multiplier",
			category = "player"
		}
	}
	self.definitions.weapon_knock_down_1 = {
		name_id = "menu_weapon_knock_down",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "knock_down",
			category = "weapon"
		}
	}
	self.definitions.weapon_knock_down_2 = {
		name_id = "menu_weapon_knock_down",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "knock_down",
			category = "weapon"
		}
	}
	self.definitions.player_climb_speed_multiplier_1 = {
		name_id = "menu_player_climb_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "climb_speed_multiplier",
			category = "player"
		}
	}
	self.definitions.player_climb_speed_multiplier_2 = {
		name_id = "menu_player_climb_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "climb_speed_multiplier",
			category = "player"
		}
	}
	self.definitions.player_silencer_concealment_increase_1 = {
		name_id = "menu_player_silencer_concealment_increase",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "silencer_concealment_increase",
			category = "player"
		}
	}
	self.definitions.player_silencer_concealment_penalty_decrease_1 = {
		name_id = "menu_player_silencer_concealment_penalty_decrease",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "silencer_concealment_penalty_decrease",
			category = "player"
		}
	}
	self.definitions.player_tape_loop_duration_1 = {
		name_id = "menu_player_tape_loop_duration",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "tape_loop_duration",
			category = "player"
		}
	}
	self.definitions.player_tape_loop_duration_2 = {
		name_id = "menu_player_tape_loop_duration",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "tape_loop_duration",
			category = "player"
		}
	}
	self.definitions.player_tape_loop_interact_distance_mul_1 = {
		name_id = "menu_player_tape_loop_interact_distance_mul",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "tape_loop_interact_distance_mul",
			category = "player"
		}
	}
	self.definitions.player_buy_spotter_asset = {
		name_id = "menu_player_buy_spotter_asset",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "buy_spotter_asset",
			category = "player"
		}
	}
	self.definitions.player_ballistic_vest_concealment_1 = {
		name_id = "menu_player_ballistic_vest_concealment",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "ballistic_vest_concealment",
			category = "player"
		}
	}
	self.definitions.player_damage_to_hot_1 = {
		name_id = "menu_player_damage_to_hot",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "damage_to_hot",
			category = "player"
		}
	}
	self.definitions.player_damage_to_hot_2 = {
		name_id = "menu_player_damage_to_hot",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "damage_to_hot",
			category = "player"
		}
	}
	self.definitions.player_damage_to_hot_3 = {
		name_id = "menu_player_damage_to_hot",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "damage_to_hot",
			category = "player"
		}
	}
	self.definitions.player_damage_to_hot_4 = {
		name_id = "menu_player_damage_to_hot",
		category = "feature",
		upgrade = {
			value = 4,
			upgrade = "damage_to_hot",
			category = "player"
		}
	}
	self.definitions.player_damage_to_hot_extra_ticks = {
		name_id = "menu_player_damage_to_hot_extra_ticks",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "damage_to_hot_extra_ticks",
			category = "player"
		}
	}
	self.definitions.player_armor_piercing_chance_1 = {
		name_id = "menu_player_armor_piercing_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_piercing_chance",
			category = "player"
		}
	}
	self.definitions.player_armor_piercing_chance_2 = {
		name_id = "menu_player_armor_piercing_chance",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "armor_piercing_chance",
			category = "player"
		}
	}
	self.definitions.player_marked_inc_dmg_distance_1 = {
		name_id = "menu_player_armor_piercing_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "marked_inc_dmg_distance",
			category = "player"
		}
	}
	self.definitions.player_armor_regen_damage_health_ratio_multiplier_1 = {
		name_id = "menu_player_armor_regen_damage_health_ratio_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_regen_damage_health_ratio_multiplier",
			category = "player"
		}
	}
	self.definitions.player_armor_regen_damage_health_ratio_multiplier_2 = {
		name_id = "menu_player_armor_regen_damage_health_ratio_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "armor_regen_damage_health_ratio_multiplier",
			category = "player"
		}
	}
	self.definitions.player_armor_regen_damage_health_ratio_multiplier_3 = {
		name_id = "menu_player_armor_regen_damage_health_ratio_multiplier",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "armor_regen_damage_health_ratio_multiplier",
			category = "player"
		}
	}
	self.definitions.player_movement_speed_damage_health_ratio_multiplier = {
		name_id = "menu_player_movement_speed_damage_health_ratio_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "movement_speed_damage_health_ratio_multiplier",
			category = "player"
		}
	}
	self.definitions.player_armor_regen_damage_health_ratio_threshold_multiplier = {
		name_id = "menu_player_armor_regen_damage_health_ratio_threshold_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_regen_damage_health_ratio_threshold_multiplier",
			category = "player"
		}
	}
	self.definitions.player_movement_speed_damage_health_ratio_threshold_multiplier = {
		name_id = "menu_player_movement_speed_damage_health_ratio_threshold_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "movement_speed_damage_health_ratio_threshold_multiplier",
			category = "player"
		}
	}
	self.definitions.player_stability_increase_bonus_1 = {
		name_id = "menu_player_stability_increase_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "stability_increase_bonus_1",
			category = "player"
		}
	}
	self.definitions.player_stability_increase_bonus_2 = {
		incremental = true,
		name_id = "menu_player_stability_increase_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "stability_increase_bonus_2",
			category = "player"
		}
	}
	self.definitions.player_weapon_accuracy_increase_1 = {
		name_id = "menu_player_weapon_accuracy_increase",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "weapon_accuracy_increase",
			category = "player"
		}
	}
	self.definitions.player_weapon_movement_stability_1 = {
		name_id = "menu_player_weapon_movement_stability",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "weapon_movement_stability",
			category = "player"
		}
	}
	self.definitions.player_hip_fire_accuracy_inc_1 = {
		name_id = "menu_player_hip_fire_accuracy_inc",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "hip_fire_accuracy_inc",
			category = "player"
		}
	}
	self.definitions.player_automatic_mag_increase_1 = {
		name_id = "menu_automatic_mag_increase",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "automatic_mag_increase",
			category = "player"
		}
	}
	self.definitions.player_escape_taser_1 = {
		name_id = "menu_escape_taser",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "escape_taser",
			category = "player"
		}
	}
	self.definitions.player_not_moving_accuracy_increase_bonus_1 = {
		name_id = "menu_player_stability_increase_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "not_moving_accuracy_increase",
			category = "player"
		}
	}
	self.definitions.player_cocaine_stacking_1 = {
		name_id = "menu_player_cocaine_stacking_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "cocaine_stacking",
			category = "player"
		}
	}
	self.definitions.player_sync_cocaine_stacks = {
		name_id = "menu_player_sync_cocaine_stacks",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "sync_cocaine_stacks",
			category = "player"
		}
	}
	self.definitions.player_cocaine_stacks_decay_multiplier_1 = {
		name_id = "menu_player_cocaine_stacks_decay_multiplier_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "cocaine_stacks_decay_multiplier",
			category = "player"
		}
	}
	self.definitions.player_sync_cocaine_upgrade_level_1 = {
		name_id = "menu_player_sync_cocaine_upgrade_level_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "sync_cocaine_upgrade_level",
			category = "player"
		}
	}
	self.definitions.player_cocaine_stack_absorption_multiplier_1 = {
		name_id = "menu_player_cocaine_stack_absorption_multiplier_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "cocaine_stack_absorption_multiplier",
			category = "player"
		}
	}
	self.definitions.player_wild_health_amount_1 = {
		name_id = "menu_player_wild_health_amount_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "wild_health_amount",
			category = "player"
		}
	}
	self.definitions.player_wild_armor_amount_1 = {
		name_id = "menu_player_wild_armor_amount_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "wild_armor_amount",
			category = "player"
		}
	}
	self.definitions.player_less_health_wild_armor_1 = {
		name_id = "menu_player_less_health_wild_armor_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "less_health_wild_armor",
			category = "player"
		}
	}
	self.definitions.player_less_health_wild_cooldown_1 = {
		name_id = "menu_player_less_health_wild_cooldown_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "less_health_wild_cooldown",
			category = "player"
		}
	}
	self.definitions.player_less_armor_wild_health_1 = {
		name_id = "menu_player_less_armor_wild_health_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "less_armor_wild_health",
			category = "player"
		}
	}
	self.definitions.player_less_armor_wild_cooldown_1 = {
		name_id = "menu_player_less_armor_wild_cooldown_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "less_armor_wild_cooldown",
			category = "player"
		}
	}
	self.definitions.temporary_chico_injector_1 = {
		name_id = "menu_temporary_chico_injector_1",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "chico_injector",
			synced = true,
			category = "temporary"
		}
	}
	self.definitions.player_chico_armor_multiplier_1 = {
		name_id = "menu_player_chico_armor_multiplier_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "chico_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_chico_armor_multiplier_2 = {
		name_id = "menu_player_chico_armor_multiplier_1",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "chico_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_chico_armor_multiplier_3 = {
		name_id = "menu_player_chico_armor_multiplier_1",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "chico_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_chico_preferred_target = {
		name_id = "menu_player_chico_preferred_target",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "chico_preferred_target",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_chico_injector_low_health_multiplier = {
		name_id = "menu_player_chico_injector_low_health_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "chico_injector_low_health_multiplier",
			category = "player"
		}
	}
	self.definitions.player_chico_injector_health_to_speed = {
		name_id = "menu_player_chico_injector_health_to_speed",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "chico_injector_health_to_speed",
			category = "player"
		}
	}
	self.definitions.player_dodge_shot_gain = {
		name_id = "menu_player_dodge_shot_gain",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "dodge_shot_gain",
			category = "player"
		}
	}
	self.definitions.player_dodge_replenish_armor = {
		name_id = "menu_player_dodge_replenish_armor",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "dodge_replenish_armor",
			category = "player"
		}
	}
	self.definitions.player_smoke_screen_ally_dodge_bonus = {
		name_id = "menu_player_smoke_screen_ally_dodge_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "smoke_screen_ally_dodge_bonus",
			category = "player"
		}
	}
	self.definitions.player_sicario_multiplier = {
		name_id = "menu_player_sicario_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "sicario_multiplier",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_pocket_ecm_jammer_base = {
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "pocket_ecm_jammer_base",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_pocket_ecm_kill_dodge_1 = {
		name_id = "menu_player_pocket_ecm_kill_dodge_1",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "pocket_ecm_kill_dodge",
			category = "temporary"
		}
	}
	self.definitions.player_pocket_ecm_heal_on_kill_1 = {
		name_id = "menu_player_pocket_ecm_heal_on_kill_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "pocket_ecm_heal_on_kill",
			category = "player"
		}
	}
	self.definitions.team_pocket_ecm_heal_on_kill_1 = {
		name_id = "menu_team_pocket_ecm_heal_on_kill_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "pocket_ecm_heal_on_kill",
			synced = true,
			category = "team"
		}
	}
	self.definitions.player_tag_team_base = {
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "tag_team_base",
			synced = true,
			category = "player"
		}
	}
	self.definitions.player_tag_team_damage_absorption = {
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "tag_team_damage_absorption",
			category = "player"
		}
	}
	self.definitions.player_tag_team_cooldown_drain_1 = {
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "tag_team_cooldown_drain",
			category = "player"
		}
	}
	self.definitions.player_tag_team_cooldown_drain_2 = {
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "tag_team_cooldown_drain",
			category = "player"
		}
	}
	self.definitions.player_armor_to_health_conversion = {
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_to_health_conversion",
			category = "player"
		}
	}
	self.definitions.player_damage_control_passive = {
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "damage_control_passive",
			category = "player"
		}
	}
	self.definitions.player_damage_control_auto_shrug = {
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "damage_control_auto_shrug",
			category = "player"
		}
	}
	self.definitions.player_damage_control_cooldown_drain_1 = {
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "damage_control_cooldown_drain",
			category = "player"
		}
	}
	self.definitions.player_damage_control_cooldown_drain_2 = {
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "damage_control_cooldown_drain",
			category = "player"
		}
	}
	self.definitions.player_damage_control_healing = {
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "damage_control_healing",
			category = "player"
		}
	}
	self.definitions.player_warp_health_1 = {
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "warp_health",
			category = "player"
		}
	}
	self.definitions.player_warp_health_2 = {
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "warp_health",
			category = "player"
		}
	}
	self.definitions.player_warp_health_3 = {
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "warp_health",
			category = "player"
		}
	}
	self.definitions.player_warp_health_4 = {
		category = "feature",
		upgrade = {
			value = 4,
			upgrade = "warp_health",
			category = "player"
		}
	}
	self.definitions.player_warp_health_5 = {
		category = "feature",
		upgrade = {
			value = 5,
			upgrade = "warp_health",
			category = "player"
		}
	}
	self.definitions.player_warp_armor_1 = {
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "warp_armor",
			category = "player"
		}
	}
	self.definitions.player_warp_armor_2 = {
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "warp_armor",
			category = "player"
		}
	}
	self.definitions.player_warp_armor_3 = {
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "warp_armor",
			category = "player"
		}
	}
	self.definitions.player_warp_armor_4 = {
		category = "feature",
		upgrade = {
			value = 4,
			upgrade = "warp_armor",
			category = "player"
		}
	}
	self.definitions.player_warp_armor_5 = {
		category = "feature",
		upgrade = {
			value = 5,
			upgrade = "warp_armor",
			category = "player"
		}
	}
	self.definitions.player_warp_dodge_1 = {
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "warp_dodge",
			category = "player"
		}
	}
	self.definitions.player_warp_dodge_2 = {
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "warp_dodge",
			category = "player"
		}
	}
	self.definitions.player_warp_dodge_3 = {
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "warp_dodge",
			category = "player"
		}
	}
	self.definitions.player_warp_dodge_4 = {
		category = "feature",
		upgrade = {
			value = 4,
			upgrade = "warp_dodge",
			category = "player"
		}
	}
	self.definitions.player_warp_dodge_5 = {
		category = "feature",
		upgrade = {
			value = 5,
			upgrade = "warp_dodge",
			category = "player"
		}
	}
	self.definitions.player_warp_armor_lite_1 = {
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "warp_armor_lite",
			category = "player"
		}
	}
	self.definitions.player_warp_armor_lite_2 = {
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "warp_armor_lite",
			category = "player"
		}
	}
	self.definitions.player_warp_armor_lite_3 = {
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "warp_armor_lite",
			category = "player"
		}
	}
	self.definitions.player_warp_armor_lite_4 = {
		category = "feature",
		upgrade = {
			value = 4,
			upgrade = "warp_armor_lite",
			category = "player"
		}
	}
	self.definitions.player_warp_armor_lite_5 = {
		category = "feature",
		upgrade = {
			value = 5,
			upgrade = "warp_armor_lite",
			category = "player"
		}
	}
	self.definitions.player_stamina_ammo_refill_single = {
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "stamina_ammo_refill_single",
			category = "player"
		}
	}
	self.definitions.player_stamina_ammo_refill_auto = {
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "stamina_ammo_refill_auto",
			category = "player"
		}
	}
	self.definitions.player_post_warp_suppression = {
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "post_warp_suppression",
			category = "player"
		}
	}
	self.definitions.player_post_warp_reload_speed = {
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "post_warp_reload_speed",
			category = "player"
		}
	}
	self.definitions.player_run_dodge_chance_vr = {
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "run_dodge_chance_vr",
			category = "player"
		}
	}
	self.definitions.toolset = {
		description_text_id = "toolset",
		category = "equipment",
		equipment_id = "toolset",
		tree = 4,
		image = "upgrades_toolset",
		image_slice = "upgrades_toolset_slice",
		title_id = "debug_upgrade_player_upgrade",
		slot = 2,
		subtitle_id = "debug_upgrade_toolset1",
		name_id = "debug_upgrade_toolset1",
		icon = "equipment_toolset",
		unlock_lvl = 0,
		step = 1,
		aquire = {
			upgrade = "toolset1"
		}
	}

	for i, _ in ipairs(self.values.player.toolset) do
		local depends_on = i - 1 > 0 and "toolset" .. i - 1
		local unlock_lvl = 3
		local prio = i == 1 and "high"
		self.definitions["toolset" .. i] = {
			description_text_id = "toolset",
			tree = 4,
			image = "upgrades_toolset",
			image_slice = "upgrades_toolset_slice",
			title_id = "debug_upgrade_player_upgrade",
			category = "feature",
			icon = "equipment_toolset",
			step = self.steps.player.toolset[i],
			subtitle_id = "debug_upgrade_toolset" .. i,
			name_id = "debug_upgrade_toolset" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "toolset",
				category = "player",
				value = i
			}
		}
	end
end

function UpgradesTweakData:_trip_mine_definitions()
	self.definitions.trip_mine = {
		description_text_id = "trip_mine",
		category = "equipment",
		slot = 1,
		equipment_id = "trip_mine",
		tree = 2,
		image = "upgrades_tripmines",
		image_slice = "upgrades_tripmines_slice",
		title_id = "debug_upgrade_new_equipment",
		prio = "high",
		subtitle_id = "debug_trip_mine",
		name_id = "debug_trip_mine",
		icon = "equipment_trip_mine",
		unlock_lvl = 0,
		step = 4
	}
	self.definitions.trip_mine_can_switch_on_off = {
		name_id = "menu_trip_mine_can_switch_on_off",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "can_switch_on_off",
			category = "trip_mine"
		}
	}
	self.definitions.trip_mine_sensor_toggle = {
		name_id = "menu_trip_mine_sensor_toggle",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "sensor_toggle",
			category = "trip_mine"
		}
	}
	self.definitions.trip_mine_sensor_highlight = {
		name_id = "menu_trip_mine_sensor_toggle",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "sensor_highlight",
			category = "trip_mine"
		}
	}
	self.definitions.trip_mine_quantity_increase_1 = {
		name_id = "menu_trip_mine_quantity_increase_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "quantity",
			category = "trip_mine"
		}
	}
	self.definitions.trip_mine_quantity_increase_2 = {
		name_id = "menu_trip_mine_quantity_increase_1",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "quantity",
			category = "trip_mine"
		}
	}
	self.definitions.trip_mine_explosion_size_multiplier_1 = {
		incremental = true,
		name_id = "menu_trip_mine_explosion_size_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "explosion_size_multiplier_1",
			category = "trip_mine"
		}
	}
	self.definitions.trip_mine_explosion_size_multiplier_2 = {
		incremental = true,
		name_id = "menu_trip_mine_explosion_size_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "explosion_size_multiplier_2",
			category = "trip_mine"
		}
	}
	self.definitions.trip_mine_explode_timer_delay = {
		incremental = true,
		name_id = "menu_trip_mine_explode_timer_delay",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "explode_timer_delay",
			category = "trip_mine"
		}
	}
	self.definitions.trip_mine_fire_trap_1 = {
		name_id = "menu_trip_mine_fire_trap",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "fire_trap",
			category = "trip_mine"
		}
	}
	self.definitions.trip_mine_fire_trap_2 = {
		name_id = "menu_trip_mine_fire_trap",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "fire_trap",
			category = "trip_mine"
		}
	}
	self.definitions.shape_charge_quantity_increase_1 = {
		name_id = "menu_shape_charge_quantity_increase",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "quantity",
			category = "shape_charge"
		}
	}
	self.definitions.shape_charge_quantity_increase_2 = {
		name_id = "menu_shape_charge_quantity_increase",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "quantity",
			category = "shape_charge"
		}
	}
	self.definitions.trip_mine_damage_multiplier_1 = {
		name_id = "menu_trip_mine_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "damage_multiplier",
			category = "trip_mine"
		}
	}
end

function UpgradesTweakData:_ecm_jammer_definitions()
	self.definitions.ecm_jammer = {
		name_id = "menu_equipment_ecm_jammer",
		slot = 1,
		equipment_id = "ecm_jammer",
		category = "equipment"
	}
	self.definitions.ecm_jammer_can_activate_feedback = {
		name_id = "menu_ecm_jammer_can_activate_feedback",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "can_activate_feedback",
			category = "ecm_jammer"
		}
	}
	self.definitions.ecm_jammer_can_open_sec_doors = {
		name_id = "menu_ecm_jammer_can_open_sec_doors",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "can_open_sec_doors",
			category = "ecm_jammer"
		}
	}
	self.definitions.ecm_jammer_quantity_increase_1 = {
		name_id = "menu_ecm_jammer_quantity_1",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "quantity",
			category = "ecm_jammer"
		}
	}
	self.definitions.ecm_jammer_quantity_increase_2 = {
		name_id = "menu_ecm_jammer_quantity_2",
		category = "equipment_upgrade",
		upgrade = {
			value = 2,
			upgrade = "quantity",
			category = "ecm_jammer"
		}
	}
	self.definitions.ecm_jammer_duration_multiplier = {
		name_id = "menu_ecm_jammer_duration_multiplier",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "duration_multiplier",
			category = "ecm_jammer"
		}
	}
	self.definitions.ecm_jammer_duration_multiplier_2 = {
		name_id = "menu_ecm_jammer_duration_multiplier",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "duration_multiplier_2",
			category = "ecm_jammer"
		}
	}
	self.definitions.ecm_jammer_affects_cameras = {
		name_id = "menu_ecm_jammer_affects_cameras",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "affects_cameras",
			synced = true,
			category = "ecm_jammer"
		}
	}
	self.definitions.ecm_jammer_affects_pagers = {
		name_id = "",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "affects_pagers",
			synced = true,
			category = "ecm_jammer"
		}
	}
	self.definitions.ecm_jammer_feedback_duration_boost = {
		name_id = "menu_ecm_jammer_feedback_duration_boost",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "feedback_duration_boost",
			synced = true,
			category = "ecm_jammer"
		}
	}
	self.definitions.ecm_jammer_feedback_duration_boost_2 = {
		name_id = "menu_ecm_jammer_feedback_duration_boost_2",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "feedback_duration_boost_2",
			synced = true,
			category = "ecm_jammer"
		}
	}
	self.definitions.ecm_jammer_interaction_speed_multiplier = {
		name_id = "menu_ecm_jammer_interaction_speed_multiplier",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "interaction_speed_multiplier",
			category = "ecm_jammer"
		}
	}
	self.definitions.ecm_jammer_can_retrigger = {
		name_id = "menu_ecm_jammer_can_retrigger",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "can_retrigger",
			synced = true,
			category = "ecm_jammer"
		}
	}
end

function UpgradesTweakData:_ammo_bag_definitions()
	self.definitions.ammo_bag = {
		description_text_id = "ammo_bag",
		category = "equipment",
		slot = 1,
		equipment_id = "ammo_bag",
		tree = 1,
		image = "upgrades_ammobag",
		image_slice = "upgrades_ammobag_slice",
		title_id = "debug_upgrade_new_equipment",
		prio = "high",
		subtitle_id = "debug_ammo_bag",
		name_id = "debug_ammo_bag",
		icon = "equipment_ammo_bag",
		unlock_lvl = 0,
		step = 2
	}

	for i, _ in ipairs(self.values.ammo_bag.ammo_increase) do
		local depends_on = i - 1 > 0 and "ammo_bag_ammo_increase" .. i - 1 or "ammo_bag"
		local unlock_lvl = 11
		local prio = i == 1 and "high"
		self.definitions["ammo_bag_ammo_increase" .. i] = {
			description_text_id = "ammo_bag_increase",
			tree = 1,
			image = "upgrades_ammobag",
			image_slice = "upgrades_ammobag_slice",
			title_id = "debug_ammo_bag",
			category = "equipment_upgrade",
			icon = "equipment_ammo_bag",
			step = self.steps.ammo_bag.ammo_increase[i],
			name_id = "debug_upgrade_ammo_bag_ammo_increase" .. i,
			subtitle_id = "debug_upgrade_amount_increase" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "ammo_increase",
				category = "ammo_bag",
				value = i
			}
		}
	end

	self.definitions.ammo_bag_quantity = {
		name_id = "menu_ammo_bag_quantity",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "quantity",
			category = "ammo_bag"
		}
	}
end

function UpgradesTweakData:_doctor_bag_definitions()
	self.definitions.doctor_bag = {
		description_text_id = "doctor_bag",
		category = "equipment",
		slot = 1,
		equipment_id = "doctor_bag",
		tree = 3,
		image = "upgrades_doctorbag",
		image_slice = "upgrades_doctorbag_slice",
		title_id = "debug_upgrade_new_equipment",
		prio = "high",
		subtitle_id = "debug_doctor_bag",
		name_id = "debug_doctor_bag",
		icon = "equipment_doctor_bag",
		unlock_lvl = 2,
		step = 5
	}

	for i, _ in ipairs(self.values.doctor_bag.amount_increase) do
		local depends_on = i - 1 > 0 and "doctor_bag_amount_increase" .. i - 1 or "doctor_bag"
		local unlock_lvl = 3
		local prio = i == 1 and "high"
		self.definitions["doctor_bag_amount_increase" .. i] = {
			description_text_id = "doctor_bag_increase",
			tree = 3,
			image = "upgrades_doctorbag",
			image_slice = "upgrades_doctorbag_slice",
			title_id = "debug_doctor_bag",
			category = "equipment_upgrade",
			icon = "equipment_doctor_bag",
			step = self.steps.doctor_bag.amount_increase[i],
			name_id = "debug_upgrade_doctor_bag_amount_increase" .. i,
			subtitle_id = "debug_upgrade_amount_increase" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "amount_increase",
				category = "doctor_bag",
				value = i
			}
		}
	end

	self.definitions.doctor_bag_quantity = {
		name_id = "menu_doctor_bag_quantity",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "quantity",
			category = "doctor_bag"
		}
	}
	self.definitions.passive_doctor_bag_interaction_speed_multiplier = {
		name_id = "menu_passive_doctor_bag_interaction_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "interaction_speed_multiplier",
			category = "doctor_bag"
		}
	}
end

function UpgradesTweakData:_cable_tie_definitions()
	self.definitions.cable_tie = {
		equipment_id = "cable_tie",
		image = "upgrades_extracableties",
		image_slice = "upgrades_extracableties_slice",
		title_id = "debug_equipment_cable_tie",
		prio = "high",
		category = "equipment",
		name_id = "debug_equipment_cable_tie",
		icon = "equipment_cable_ties",
		unlock_lvl = 0
	}
	self.definitions.extra_cable_tie = {
		description_text_id = "extra_cable_tie",
		category = "equipment",
		equipment_id = "extra_cable_tie",
		tree = 1,
		image = "upgrades_extracableties",
		image_slice = "upgrades_extracableties_slice",
		slot = 2,
		title_id = "debug_equipment_cable_tie",
		prio = "high",
		subtitle_id = "debug_upgrade_amount_increase1",
		name_id = "debug_upgrade_extra_cable_tie_quantity1",
		icon = "equipment_extra_cable_ties",
		unlock_lvl = 3,
		step = 4,
		aquire = {
			upgrade = "extra_cable_tie_quantity1"
		}
	}

	for i, _ in ipairs(self.values.extra_cable_tie.quantity) do
		local depends_on = i - 1 > 0 and "extra_cable_tie_quantity" .. i - 1 or "extra_cable_tie"
		local unlock_lvl = 4
		local prio = i == 1 and "high"
		self.definitions["extra_cable_tie_quantity" .. i] = {
			description_text_id = "extra_cable_tie",
			tree = 1,
			image = "upgrades_extracableties",
			image_slice = "upgrades_extracableties_slice",
			title_id = "debug_equipment_cable_tie",
			category = "equipment_upgrade",
			icon = "equipment_extra_cable_ties",
			step = self.steps.extra_cable_tie.quantity[i],
			name_id = "debug_upgrade_extra_cable_tie_quantity" .. i,
			subtitle_id = "debug_upgrade_amount_increase" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "quantity",
				category = "extra_cable_tie",
				value = i
			}
		}
	end

	self.definitions.cable_tie_quantity = {
		name_id = "menu_cable_tie_quantity",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "quantity_1",
			category = "cable_tie"
		}
	}
	self.definitions.cable_tie_quantity_2 = {
		name_id = "menu_cable_tie_quantity_2",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "quantity_2",
			category = "cable_tie"
		}
	}
	self.definitions.cable_tie_interact_speed_multiplier = {
		name_id = "menu_cable_tie_interact_speed_multiplier",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "interact_speed_multiplier",
			category = "cable_tie"
		}
	}
	self.definitions.cable_tie_can_cable_tie_doors = {
		name_id = "menu_cable_tie_can_cable_tie_doors",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "can_cable_tie_doors",
			category = "cable_tie"
		}
	}
	self.definitions.cable_tie_quantity_unlimited = {
		name_id = "menu_cable_tie_quantity_unlimited",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "quantity_unlimited",
			category = "cable_tie"
		}
	}
end

function UpgradesTweakData:_armor_kit_definitions()
	self.definitions.armor_kit = {
		name_id = "menu_equipment_armor_kit",
		slot = 1,
		equipment_id = "armor_kit",
		category = "equipment"
	}
end

function UpgradesTweakData:_sentry_gun_definitions()
	self.definitions.sentry_gun = {
		description_text_id = "sentry_gun",
		category = "equipment",
		slot = 1,
		equipment_id = "sentry_gun",
		tree = 4,
		image = "upgrades_sentry",
		image_slice = "upgrades_sentry_slice",
		title_id = "debug_upgrade_new_equipment",
		prio = "high",
		subtitle_id = "debug_sentry_gun",
		name_id = "debug_sentry_gun",
		icon = "equipment_sentry",
		unlock_lvl = 0,
		step = 5
	}
	self.definitions.sentry_gun_silent = {
		description_text_id = "sentry_gun",
		category = "equipment",
		slot = 1,
		equipment_id = "sentry_gun_silent",
		tree = 4,
		image = "upgrades_sentry",
		image_slice = "upgrades_sentry_slice",
		title_id = "debug_upgrade_new_equipment",
		prio = "high",
		subtitle_id = "debug_sentry_gun",
		name_id = "debug_silent_sentry_gun",
		icon = "equipment_sentry",
		unlock_lvl = 0,
		step = 6
	}
	self.definitions.sentry_gun_quantity_1 = {
		name_id = "menu_sentry_gun_quantity_increase",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "quantity",
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_quantity_2 = {
		name_id = "menu_sentry_gun_quantity_increase",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "quantity",
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_damage_multiplier = {
		name_id = "menu_sentry_gun_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "damage_multiplier",
			synced = true,
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_extra_ammo_multiplier_1 = {
		incremental = true,
		name_id = "menu_sentry_gun_extra_ammo_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "extra_ammo_multiplier",
			synced = true,
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_extra_ammo_multiplier_2 = {
		incremental = true,
		name_id = "menu_sentry_gun_extra_ammo_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "extra_ammo_multiplier",
			synced = true,
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_armor_multiplier = {
		name_id = "menu_sentry_gun_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_multiplier",
			synced = true,
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_armor_multiplier2 = {
		name_id = "menu_sentry_gun_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_multiplier2",
			synced = true,
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_spread_multiplier = {
		name_id = "menu_sentry_gun_spread_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "spread_multiplier",
			synced = true,
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_rot_speed_multiplier = {
		name_id = "menu_sentry_gun_rot_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "rot_speed_multiplier",
			synced = true,
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_shield = {
		name_id = "menu_sentry_gun_shield",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "shield",
			synced = true,
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_can_revive = {
		name_id = "menu_sentry_gun_can_revive",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "can_revive",
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_can_reload = {
		name_id = "menu_sentry_gun_can_reload",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "can_reload",
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_armor_piercing_chance = {
		name_id = "menu_sentry_gun_armor_piercing_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_piercing_chance",
			synced = true,
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_armor_piercing_chance_2 = {
		name_id = "menu_sentry_gun_armor_piercing_chance_2",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_piercing_chance_2",
			synced = true,
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_cost_reduction_1 = {
		name_id = "menu_sentry_gun_cost_reduction",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "cost_reduction",
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_cost_reduction_2 = {
		name_id = "menu_sentry_gun_cost_reduction",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "cost_reduction",
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_less_noisy = {
		name_id = "menu_sentry_gun_less_noisy",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "less_noisy",
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_fire_rate_reduction_1 = {
		name_id = "menu_sentry_gun_fire_rate_reduction",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "fire_rate_reduction",
			synced = true,
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_ap_bullets = {
		name_id = "menu_sentry_gun_ap_bullets",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "ap_bullets",
			synced = true,
			category = "sentry_gun"
		}
	}
end

function UpgradesTweakData:_rep_definitions()
	local rep_upgrades = self.values.rep_upgrades

	for index, rep_class in ipairs(rep_upgrades.classes) do
		for i = 1, 10, 1 do
			self.definitions[rep_class .. i] = {
				category = "rep_upgrade",
				value = rep_upgrades.values[index]
			}
		end
	end
end

function UpgradesTweakData:_c45_definitions()
	self.definitions.c45 = {
		description_text_id = "des_c45",
		prio = "high",
		category = "weapon",
		tree = 1,
		image = "upgrades_45",
		image_slice = "upgrades_45_slice",
		title_id = "debug_upgrade_new_weapon",
		subtitle_id = "debug_c45_short",
		name_id = "debug_c45",
		icon = "c45",
		unlock_lvl = 30,
		step = 13,
		unit_name = Idstring("units/weapons/c45/c45")
	}

	for i, _ in ipairs(self.values.c45.clip_ammo_increase) do
		local depends_on = i - 1 > 0 and "c45_mag" .. i - 1 or "c45"
		local unlock_lvl = 31
		local prio = i == 1 and "high"
		self.definitions["c45_mag" .. i] = {
			description_text_id = "clip_ammo_increase",
			tree = 1,
			image = "upgrades_45",
			image_slice = "upgrades_45_slice",
			title_id = "debug_c45_short",
			category = "feature",
			icon = "c45",
			step = self.steps.c45.clip_ammo_increase[i],
			name_id = "debug_upgrade_c45_mag" .. i,
			subtitle_id = "debug_upgrade_mag" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "clip_ammo_increase",
				category = "c45",
				value = i
			}
		}
	end

	for i, _ in ipairs(self.values.c45.recoil_multiplier) do
		local depends_on = i - 1 > 0 and "c45_recoil" .. i - 1 or "c45"
		local unlock_lvl = 31
		local prio = i == 1 and "high"
		self.definitions["c45_recoil" .. i] = {
			description_text_id = "recoil_multiplier",
			tree = 1,
			image = "upgrades_45",
			image_slice = "upgrades_45_slice",
			title_id = "debug_c45_short",
			category = "feature",
			icon = "c45",
			step = self.steps.c45.recoil_multiplier[i],
			name_id = "debug_upgrade_c45_recoil" .. i,
			subtitle_id = "debug_upgrade_recoil" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "recoil_multiplier",
				category = "c45",
				value = i
			}
		}
	end

	for i, _ in ipairs(self.values.c45.damage_multiplier) do
		local depends_on = i - 1 > 0 and "c45_damage" .. i - 1 or "c45"
		local unlock_lvl = 31
		local prio = i == 1 and "high"
		self.definitions["c45_damage" .. i] = {
			description_text_id = "damage_multiplier",
			tree = 1,
			image = "upgrades_45",
			image_slice = "upgrades_45_slice",
			title_id = "debug_c45_short",
			category = "feature",
			icon = "c45",
			step = self.steps.c45.damage_multiplier[i],
			name_id = "debug_upgrade_c45_damage" .. i,
			subtitle_id = "debug_upgrade_damage" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "damage_multiplier",
				category = "c45",
				value = i
			}
		}
	end
end

function UpgradesTweakData:_beretta92_definitions()
	self.definitions.beretta92 = {
		description_text_id = "des_beretta92",
		image_slice = "upgrades_m9sd_slice",
		prio = "high",
		subtitle_id = "debug_beretta92_short",
		image = "upgrades_m9sd",
		weapon_id = "beretta92",
		title_id = "debug_upgrade_new_weapon",
		category = "weapon",
		name_id = "debug_beretta92",
		icon = "beretta92",
		unlock_lvl = 0,
		unit_name = Idstring("units/weapons/beretta92/beretta92")
	}

	for i, _ in ipairs(self.values.beretta92.clip_ammo_increase) do
		local depends_on = i - 1 > 0 and "beretta_mag" .. i - 1 or "beretta92"
		local unlock_lvl = 2
		local prio = i == 1 and "high"
		self.definitions["beretta_mag" .. i] = {
			description_text_id = "clip_ammo_increase",
			tree = 1,
			image = "upgrades_m9sd",
			image_slice = "upgrades_m9sd_slice",
			title_id = "debug_beretta92_short",
			category = "feature",
			icon = "beretta92",
			step = self.steps.beretta92.clip_ammo_increase[i],
			name_id = "debug_upgrade_beretta_mag" .. i,
			subtitle_id = "debug_upgrade_mag" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "clip_ammo_increase",
				category = "beretta92",
				value = i
			}
		}
	end

	for i, _ in ipairs(self.values.beretta92.recoil_multiplier) do
		local depends_on = i - 1 > 0 and "beretta_recoil" .. i - 1 or "beretta92"
		local unlock_lvl = 2
		local prio = i == 1 and "high"
		self.definitions["beretta_recoil" .. i] = {
			description_text_id = "recoil_multiplier",
			tree = 2,
			image = "upgrades_m9sd",
			image_slice = "upgrades_m9sd_slice",
			title_id = "debug_beretta92_short",
			category = "feature",
			icon = "beretta92",
			step = self.steps.beretta92.recoil_multiplier[i],
			name_id = "debug_upgrade_beretta_recoil" .. i,
			subtitle_id = "debug_upgrade_recoil" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "recoil_multiplier",
				category = "beretta92",
				value = i
			}
		}
	end

	for i, _ in ipairs(self.values.beretta92.spread_multiplier) do
		local depends_on = i - 1 > 0 and "beretta_spread" .. i - 1 or "beretta92"
		local unlock_lvl = 2
		local prio = i == 1 and "high"
		self.definitions["beretta_spread" .. i] = {
			description_text_id = "spread_multiplier",
			tree = 3,
			image = "upgrades_m9sd",
			image_slice = "upgrades_m9sd_slice",
			title_id = "debug_beretta92_short",
			category = "feature",
			icon = "beretta92",
			step = self.steps.beretta92.spread_multiplier[i],
			name_id = "debug_upgrade_beretta_spread" .. i,
			subtitle_id = "debug_upgrade_spread" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "spread_multiplier",
				category = "beretta92",
				value = i
			}
		}
	end
end

function UpgradesTweakData:_raging_bull_definitions()
	self.definitions.raging_bull = {
		description_text_id = "des_raging_bull",
		image_slice = "upgrades_ragingbull_slice",
		prio = "high",
		category = "weapon",
		tree = 3,
		image = "upgrades_ragingbull",
		weapon_id = "raging_bull",
		title_id = "debug_upgrade_new_weapon",
		subtitle_id = "debug_raging_bull_short",
		name_id = "debug_raging_bull",
		icon = "raging_bull",
		unlock_lvl = 60,
		step = 6,
		unit_name = Idstring("units/weapons/raging_bull/raging_bull")
	}

	for i, _ in ipairs(self.values.raging_bull.spread_multiplier) do
		local depends_on = i - 1 > 0 and "raging_bull_spread" .. i - 1
		local unlock_lvl = 61
		local prio = i == 1 and "high"
		self.definitions["raging_bull_spread" .. i] = {
			description_text_id = "spread_multiplier",
			tree = 3,
			image = "upgrades_ragingbull",
			image_slice = "upgrades_ragingbull_slice",
			title_id = "debug_raging_bull_short",
			category = "feature",
			icon = "raging_bull",
			step = self.steps.raging_bull.spread_multiplier[i],
			name_id = "debug_upgrade_raging_bull_spread" .. i,
			subtitle_id = "debug_upgrade_spread" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "spread_multiplier",
				category = "raging_bull",
				value = i
			}
		}
	end

	for i, _ in ipairs(self.values.raging_bull.reload_speed_multiplier) do
		local depends_on = i - 1 > 0 and "raging_bull_reload_speed" .. i - 1 or "raging_bull"
		local unlock_lvl = 61
		local prio = i == 1 and "high"
		self.definitions["raging_bull_reload_speed" .. i] = {
			description_text_id = "reload_speed_multiplier",
			tree = 3,
			image = "upgrades_ragingbull",
			image_slice = "upgrades_ragingbull_slice",
			title_id = "debug_raging_bull_short",
			category = "feature",
			icon = "raging_bull",
			step = self.steps.raging_bull.reload_speed_multiplier[i],
			name_id = "debug_upgrade_raging_bull_reload_speed" .. i,
			subtitle_id = "debug_upgrade_reload_speed" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "reload_speed_multiplier",
				category = "raging_bull",
				value = i
			}
		}
	end

	for i, _ in ipairs(self.values.raging_bull.damage_multiplier) do
		local depends_on = i - 1 > 0 and "raging_bull_damage" .. i - 1 or "raging_bull"
		local unlock_lvl = 61
		local prio = i == 1 and "high"
		self.definitions["raging_bull_damage" .. i] = {
			description_text_id = "damage_multiplier",
			tree = 3,
			image = "upgrades_ragingbull",
			image_slice = "upgrades_ragingbull_slice",
			title_id = "debug_raging_bull_short",
			category = "feature",
			icon = "raging_bull",
			step = self.steps.raging_bull.damage_multiplier[i],
			name_id = "debug_upgrade_raging_bull_damage" .. i,
			subtitle_id = "debug_upgrade_damage" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "damage_multiplier",
				category = "raging_bull",
				value = i
			}
		}
	end
end

function UpgradesTweakData:_olympic_definitions()
	self.definitions.olympic = {
		factory_id = "wpn_fps_smg_olympic",
		weapon_id = "olympic",
		category = "weapon"
	}
	self.definitions.olympic_primary = {
		factory_id = "wpn_fps_smg_olympic_primary",
		weapon_id = "olympic_primary",
		category = "weapon"
	}
end

function UpgradesTweakData:_amcar_definitions()
	self.definitions.amcar = {
		free = true,
		factory_id = "wpn_fps_ass_amcar",
		weapon_id = "amcar",
		category = "weapon"
	}
end

function UpgradesTweakData:_m16_definitions()
	self.definitions.m16 = {
		factory_id = "wpn_fps_ass_m16",
		weapon_id = "m16",
		category = "weapon"
	}
end

function UpgradesTweakData:_new_m4_definitions()
	self.definitions.new_m4 = {
		factory_id = "wpn_fps_ass_m4",
		weapon_id = "new_m4",
		category = "weapon"
	}
	self.definitions.m4_secondary = {
		factory_id = "wpn_fps_ass_m4_secondary",
		weapon_id = "m4_secondary",
		category = "weapon"
	}
end

function UpgradesTweakData:_glock_18c_definitions()
	self.definitions.glock_18c = {
		factory_id = "wpn_fps_pis_g18c",
		weapon_id = "glock_18c",
		category = "weapon"
	}
	self.definitions.glock_18c_primary = {
		factory_id = "wpn_fps_pis_g18c_primary",
		weapon_id = "glock_18c_primary",
		category = "weapon"
	}
end

function UpgradesTweakData:_saiga_definitions()
	self.definitions.saiga = {
		factory_id = "wpn_fps_shot_saiga",
		weapon_id = "saiga",
		category = "weapon"
	}
end

function UpgradesTweakData:_akmsu_definitions()
	self.definitions.akmsu = {
		factory_id = "wpn_fps_smg_akmsu",
		weapon_id = "akmsu",
		category = "weapon"
	}
	self.definitions.akmsu_primary = {
		factory_id = "wpn_fps_smg_akmsu_primary",
		weapon_id = "akmsu_primary",
		category = "weapon"
	}
end

function UpgradesTweakData:_ak74_definitions()
	self.definitions.ak74 = {
		factory_id = "wpn_fps_ass_74",
		weapon_id = "ak74",
		category = "weapon"
	}
	self.definitions.ak74_secondary = {
		factory_id = "wpn_fps_ass_74_secondary",
		weapon_id = "ak74_secondary",
		category = "weapon"
	}
end

function UpgradesTweakData:_akm_definitions()
	self.definitions.akm = {
		factory_id = "wpn_fps_ass_akm",
		weapon_id = "akm",
		category = "weapon"
	}
end

function UpgradesTweakData:_akm_gold_definitions()
	self.definitions.akm_gold = {
		dlc = "pd2_clan",
		factory_id = "wpn_fps_ass_akm_gold",
		weapon_id = "akm_gold",
		category = "weapon"
	}
end

function UpgradesTweakData:_ak5_definitions()
	self.definitions.ak5 = {
		factory_id = "wpn_fps_ass_ak5",
		weapon_id = "ak5",
		category = "weapon"
	}
end

function UpgradesTweakData:_aug_definitions()
	self.definitions.aug = {
		factory_id = "wpn_fps_ass_aug",
		weapon_id = "aug",
		category = "weapon"
	}
	self.definitions.aug_secondary = {
		factory_id = "wpn_fps_ass_aug_secondary",
		weapon_id = "aug_secondary",
		category = "weapon"
	}
end

function UpgradesTweakData:_g36_definitions()
	self.definitions.g36 = {
		factory_id = "wpn_fps_ass_g36",
		weapon_id = "g36",
		category = "weapon"
	}
end

function UpgradesTweakData:_p90_definitions()
	self.definitions.p90 = {
		factory_id = "wpn_fps_smg_p90",
		weapon_id = "p90",
		category = "weapon"
	}
end

function UpgradesTweakData:_new_m14_definitions()
	self.definitions.new_m14 = {
		factory_id = "wpn_fps_ass_m14",
		weapon_id = "new_m14",
		category = "weapon"
	}
end

function UpgradesTweakData:_mp9_definitions()
	self.definitions.mp9 = {
		factory_id = "wpn_fps_smg_mp9",
		weapon_id = "mp9",
		category = "weapon"
	}
end

function UpgradesTweakData:_deagle_definitions()
	self.definitions.deagle = {
		factory_id = "wpn_fps_pis_deagle",
		weapon_id = "deagle",
		category = "weapon"
	}
	self.definitions.deagle_primary = {
		factory_id = "wpn_fps_pis_deagle_primary",
		weapon_id = "deagle_primary",
		category = "weapon"
	}
end

function UpgradesTweakData:_new_mp5_definitions()
	self.definitions.new_mp5 = {
		factory_id = "wpn_fps_smg_mp5",
		weapon_id = "new_mp5",
		category = "weapon"
	}
end

function UpgradesTweakData:_colt_1911_definitions()
	self.definitions.colt_1911 = {
		factory_id = "wpn_fps_pis_1911",
		weapon_id = "colt_1911",
		category = "weapon"
	}
	self.definitions.colt_1911_primary = {
		factory_id = "wpn_fps_pis_1911_primary",
		weapon_id = "colt_1911_primary",
		category = "weapon"
	}
end

function UpgradesTweakData:_mac10_definitions()
	self.definitions.mac10 = {
		factory_id = "wpn_fps_smg_mac10",
		weapon_id = "mac10",
		category = "weapon"
	}
end

function UpgradesTweakData:_glock_17_definitions()
	self.definitions.glock_17 = {
		free = true,
		factory_id = "wpn_fps_pis_g17",
		weapon_id = "glock_17",
		category = "weapon"
	}
end

function UpgradesTweakData:_b92fs_definitions()
	self.definitions.b92fs = {
		factory_id = "wpn_fps_pis_beretta",
		weapon_id = "b92fs",
		category = "weapon"
	}
	self.definitions.b92fs_primary = {
		factory_id = "wpn_fps_pis_beretta_primary",
		weapon_id = "b92fs_primary",
		category = "weapon"
	}
end

function UpgradesTweakData:_huntsman_definitions()
	self.definitions.huntsman = {
		factory_id = "wpn_fps_shot_huntsman",
		weapon_id = "huntsman",
		category = "weapon"
	}
end

function UpgradesTweakData:_r870_definitions()
	self.definitions.r870 = {
		factory_id = "wpn_fps_shot_r870",
		weapon_id = "r870",
		category = "weapon"
	}
end

function UpgradesTweakData:_serbu_definitions()
	self.definitions.serbu = {
		factory_id = "wpn_fps_shot_serbu",
		weapon_id = "serbu",
		category = "weapon"
	}
end

function UpgradesTweakData:_new_raging_bull_definitions()
	self.definitions.new_raging_bull = {
		factory_id = "wpn_fps_pis_rage",
		weapon_id = "new_raging_bull",
		category = "weapon"
	}
	self.definitions.raging_bull_primary = {
		factory_id = "wpn_fps_pis_rage_primary",
		weapon_id = "raging_bull_primary",
		category = "weapon"
	}
end

function UpgradesTweakData:_saw_definitions()
	self.definitions.saw = {
		factory_id = "wpn_fps_saw",
		weapon_id = "saw",
		category = "weapon"
	}
	self.definitions.saw_secondary = {
		factory_id = "wpn_fps_saw_secondary",
		weapon_id = "saw_secondary",
		category = "weapon"
	}
	self.definitions.saw_extra_ammo_multiplier = {
		name_id = "menu_saw_extra_ammo_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "extra_ammo_multiplier",
			category = "saw"
		}
	}
	self.definitions.saw_enemy_slicer = {
		name_id = "menu_saw_enemy_slicer",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "enemy_slicer",
			category = "saw"
		}
	}
	self.definitions.saw_recoil_multiplier = {
		name_id = "menu_saw_recoil_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "recoil_multiplier",
			category = "saw"
		}
	}
	self.definitions.saw_fire_rate_multiplier_1 = {
		name_id = "menu_saw_fire_rate_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "fire_rate_multiplier",
			category = "saw"
		}
	}
	self.definitions.saw_fire_rate_multiplier_2 = {
		name_id = "menu_saw_fire_rate_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "fire_rate_multiplier",
			category = "saw"
		}
	}
	self.definitions.saw_lock_damage_multiplier_1 = {
		name_id = "menu_lock_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "lock_damage_multiplier",
			category = "saw"
		}
	}
	self.definitions.saw_lock_damage_multiplier_2 = {
		name_id = "menu_lock_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "lock_damage_multiplier",
			category = "saw"
		}
	}
	self.definitions.saw_hip_fire_spread_multiplier = {
		name_id = "menu_saw_hip_fire_spread_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "hip_fire_spread_multiplier",
			category = "saw"
		}
	}
	self.definitions.saw_hip_fire_damage_multiplier = {
		name_id = "menu_saw_hip_fire_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "hip_fire_damage_multiplier",
			category = "saw"
		}
	}
	self.definitions.saw_armor_piercing_chance = {
		name_id = "menu_saw_armor_piercing_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_piercing_chance",
			category = "saw"
		}
	}
	self.definitions.saw_swap_speed_multiplier = {
		name_id = "menu_saw_swap_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "swap_speed_multiplier",
			category = "saw"
		}
	}
	self.definitions.saw_reload_speed_multiplier = {
		name_id = "menu_saw_reload_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "reload_speed_multiplier",
			category = "saw"
		}
	}
	self.definitions.saw_melee_knockdown_mul = {
		name_id = "menu_saw_melee_knockdown_mul",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "melee_knockdown_mul",
			category = "saw"
		}
	}
	self.definitions.saw_ignore_shields_1 = {
		name_id = "menu_saw_ignore_shields",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "ignore_shields",
			category = "saw"
		}
	}
	self.definitions.saw_panic_when_kill_1 = {
		name_id = "menu_saw_panic_when_kill",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "panic_when_kill",
			category = "saw"
		}
	}
end

function UpgradesTweakData:_usp_definitions()
	self.definitions.usp = {
		dlc = "pd2_clan",
		factory_id = "wpn_fps_pis_usp",
		weapon_id = "usp",
		category = "weapon"
	}
end

function UpgradesTweakData:_g22c_definitions()
	self.definitions.g22c = {
		dlc = "pd2_clan",
		factory_id = "wpn_fps_pis_g22c",
		weapon_id = "g22c",
		category = "weapon"
	}
end

function UpgradesTweakData:_judge_definitions()
	self.definitions.judge = {
		dlc = "pd2_clan",
		factory_id = "wpn_fps_pis_judge",
		weapon_id = "judge",
		category = "weapon"
	}
end

function UpgradesTweakData:_m45_definitions()
	self.definitions.m45 = {
		dlc = "armored_transport",
		factory_id = "wpn_fps_smg_m45",
		weapon_id = "m45",
		category = "weapon"
	}
end

function UpgradesTweakData:_s552_definitions()
	self.definitions.s552 = {
		dlc = "armored_transport",
		factory_id = "wpn_fps_ass_s552",
		weapon_id = "s552",
		category = "weapon"
	}
	self.definitions.s552_secondary = {
		dlc = "armored_transport",
		factory_id = "wpn_fps_ass_s552_secondary",
		weapon_id = "s552_secondary",
		category = "weapon"
	}
end

function UpgradesTweakData:_ppk_definitions()
	self.definitions.ppk = {
		dlc = "armored_transport",
		factory_id = "wpn_fps_pis_ppk",
		weapon_id = "ppk",
		category = "weapon"
	}
end

function UpgradesTweakData:_mp7_definitions()
	self.definitions.mp7 = {
		dlc = "gage_pack",
		factory_id = "wpn_fps_smg_mp7",
		weapon_id = "mp7",
		category = "weapon"
	}
end

function UpgradesTweakData:_scar_definitions()
	self.definitions.scar = {
		dlc = "gage_pack",
		factory_id = "wpn_fps_ass_scar",
		weapon_id = "scar",
		category = "weapon"
	}
end

function UpgradesTweakData:_p226_definitions()
	self.definitions.p226 = {
		dlc = "gage_pack",
		factory_id = "wpn_fps_pis_p226",
		weapon_id = "p226",
		category = "weapon"
	}
end

function UpgradesTweakData:_hk21_definitions()
	self.definitions.hk21 = {
		dlc = "gage_pack_lmg",
		factory_id = "wpn_fps_lmg_hk21",
		weapon_id = "hk21",
		category = "weapon"
	}
end

function UpgradesTweakData:_m249_definitions()
	self.definitions.m249 = {
		dlc = "gage_pack_lmg",
		factory_id = "wpn_fps_lmg_m249",
		weapon_id = "m249",
		category = "weapon"
	}
end

function UpgradesTweakData:_rpk_definitions()
	self.definitions.rpk = {
		dlc = "gage_pack_lmg",
		factory_id = "wpn_fps_lmg_rpk",
		weapon_id = "rpk",
		category = "weapon"
	}
end

function UpgradesTweakData:_m95_definitions()
	self.definitions.m95 = {
		dlc = "gage_pack_snp",
		factory_id = "wpn_fps_snp_m95",
		weapon_id = "m95",
		category = "weapon"
	}
end

function UpgradesTweakData:_msr_definitions()
	self.definitions.msr = {
		dlc = "gage_pack_snp",
		factory_id = "wpn_fps_snp_msr",
		weapon_id = "msr",
		category = "weapon"
	}
end

function UpgradesTweakData:_r93_definitions()
	self.definitions.r93 = {
		dlc = "gage_pack_snp",
		factory_id = "wpn_fps_snp_r93",
		weapon_id = "r93",
		category = "weapon"
	}
end

function UpgradesTweakData:_fal_definitions()
	self.definitions.fal = {
		dlc = "big_bank",
		factory_id = "wpn_fps_ass_fal",
		weapon_id = "fal",
		category = "weapon"
	}
end

function UpgradesTweakData:_benelli_definitions()
	self.definitions.benelli = {
		dlc = "gage_pack_shotgun",
		factory_id = "wpn_fps_sho_ben",
		weapon_id = "benelli",
		category = "weapon"
	}
end

function UpgradesTweakData:_striker_definitions()
	self.definitions.striker = {
		dlc = "gage_pack_shotgun",
		factory_id = "wpn_fps_sho_striker",
		weapon_id = "striker",
		category = "weapon"
	}
	self.definitions.striker_reload_speed_default = {
		name_id = "menu_reload_speed_multiplierr",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "reload_speed_multiplier",
			category = "striker"
		}
	}
end

function UpgradesTweakData:_ksg_definitions()
	self.definitions.ksg = {
		dlc = "gage_pack_shotgun",
		factory_id = "wpn_fps_sho_ksg",
		weapon_id = "ksg",
		category = "weapon"
	}
end

function UpgradesTweakData:_scorpion_definitions()
	self.definitions.scorpion = {
		dlc = "hl_miami",
		factory_id = "wpn_fps_smg_scorpion",
		weapon_id = "scorpion",
		category = "weapon"
	}
end

function UpgradesTweakData:_tec9_definitions()
	self.definitions.tec9 = {
		dlc = "hl_miami",
		factory_id = "wpn_fps_smg_tec9",
		weapon_id = "tec9",
		category = "weapon"
	}
end

function UpgradesTweakData:_uzi_definitions()
	self.definitions.uzi = {
		dlc = "hl_miami",
		factory_id = "wpn_fps_smg_uzi",
		weapon_id = "uzi",
		category = "weapon"
	}
end

function UpgradesTweakData:_gre_m79_definitions()
	self.definitions.gre_m79 = {
		dlc = "gage_pack_assault",
		factory_id = "wpn_fps_gre_m79",
		weapon_id = "gre_m79",
		category = "weapon"
	}
end

function UpgradesTweakData:_g3_definitions()
	self.definitions.g3 = {
		dlc = "gage_pack_assault",
		factory_id = "wpn_fps_ass_g3",
		weapon_id = "g3",
		category = "weapon"
	}
end

function UpgradesTweakData:_galil_definitions()
	self.definitions.galil = {
		dlc = "gage_pack_assault",
		factory_id = "wpn_fps_ass_galil",
		weapon_id = "galil",
		category = "weapon"
	}
end

function UpgradesTweakData:_famas_definitions()
	self.definitions.famas = {
		dlc = "gage_pack_assault",
		factory_id = "wpn_fps_ass_famas",
		weapon_id = "famas",
		category = "weapon"
	}
end

function UpgradesTweakData:_spas12_definitions()
	self.definitions.spas12 = {
		dlc = "pd2_clan",
		factory_id = "wpn_fps_sho_spas12",
		weapon_id = "spas12",
		category = "weapon"
	}
end

function UpgradesTweakData:_mg42_definitions()
	self.definitions.mg42 = {
		dlc = "gage_pack_historical",
		factory_id = "wpn_fps_lmg_mg42",
		weapon_id = "mg42",
		category = "weapon"
	}
end

function UpgradesTweakData:_c96_definitions()
	self.definitions.c96 = {
		dlc = "gage_pack_historical",
		factory_id = "wpn_fps_pis_c96",
		weapon_id = "c96",
		category = "weapon"
	}
end

function UpgradesTweakData:_sterling_definitions()
	self.definitions.sterling = {
		dlc = "gage_pack_historical",
		factory_id = "wpn_fps_smg_sterling",
		weapon_id = "sterling",
		category = "weapon"
	}
end

function UpgradesTweakData:_mosin_definitions()
	self.definitions.mosin = {
		dlc = "gage_pack_historical",
		factory_id = "wpn_fps_snp_mosin",
		weapon_id = "mosin",
		category = "weapon"
	}
end

function UpgradesTweakData:_m1928_definitions()
	self.definitions.m1928 = {
		dlc = "pd2_clan",
		factory_id = "wpn_fps_smg_thompson",
		weapon_id = "m1928",
		category = "weapon"
	}
end

function UpgradesTweakData:_l85a2_definitions()
	self.definitions.l85a2 = {
		dlc = "character_pack_clover",
		factory_id = "wpn_fps_ass_l85a2",
		weapon_id = "l85a2",
		category = "weapon"
	}
end

function UpgradesTweakData:_vhs_definitions()
	self.definitions.vhs = {
		dlc = "character_pack_dragan",
		factory_id = "wpn_fps_ass_vhs",
		weapon_id = "vhs",
		category = "weapon"
	}
end

function UpgradesTweakData:_hs2000_definitions()
	self.definitions.hs2000 = {
		dlc = "the_bomb",
		factory_id = "wpn_fps_pis_hs2000",
		weapon_id = "hs2000",
		category = "weapon"
	}
end

function UpgradesTweakData:_m134_weapon_definitions()
	self.definitions.m134 = {
		dlc = "overkill_pack",
		factory_id = "wpn_fps_lmg_m134",
		weapon_id = "m134",
		category = "weapon"
	}
end

function UpgradesTweakData:_rpg7_weapon_definitions()
	self.definitions.rpg7 = {
		dlc = "overkill_pack",
		factory_id = "wpn_fps_rpg7",
		weapon_id = "rpg7",
		category = "weapon"
	}
end

function UpgradesTweakData:_cobray_definitions()
	self.definitions.cobray = {
		dlc = "hlm2_deluxe",
		factory_id = "wpn_fps_smg_cobray",
		weapon_id = "cobray",
		category = "weapon"
	}
end

function UpgradesTweakData:_b682_weapon_definitions()
	self.definitions.b682 = {
		dlc = "pd2_clan",
		factory_id = "wpn_fps_shot_b682",
		weapon_id = "b682",
		category = "weapon"
	}
end

function UpgradesTweakData:_melee_weapon_definitions()
	self.definitions.weapon = {
		category = "melee_weapon"
	}
	self.definitions.fists = {
		category = "melee_weapon"
	}
	self.definitions.kabar = {
		dlc = "gage_pack_lmg",
		category = "melee_weapon"
	}
	self.definitions.rambo = {
		dlc = "gage_pack_lmg",
		category = "melee_weapon"
	}
	self.definitions.gerber = {
		dlc = "gage_pack_lmg",
		category = "melee_weapon"
	}
	self.definitions.kampfmesser = {
		dlc = "gage_pack_lmg",
		category = "melee_weapon"
	}
	self.definitions.brass_knuckles = {
		dlc = "pd2_clan",
		category = "melee_weapon"
	}
	self.definitions.tomahawk = {
		dlc = "gage_pack_shotgun",
		category = "melee_weapon"
	}
	self.definitions.baton = {
		dlc = "gage_pack_shotgun",
		category = "melee_weapon"
	}
	self.definitions.shovel = {
		dlc = "gage_pack_shotgun",
		category = "melee_weapon"
	}
	self.definitions.becker = {
		dlc = "gage_pack_shotgun",
		category = "melee_weapon"
	}
	self.definitions.moneybundle = {
		dlc = "pd2_clan",
		category = "melee_weapon"
	}
	self.definitions.barbedwire = {
		dlc = "pd2_clan",
		category = "melee_weapon"
	}
	self.definitions.x46 = {
		dlc = "gage_pack_assault",
		category = "melee_weapon"
	}
	self.definitions.dingdong = {
		dlc = "gage_pack_assault",
		category = "melee_weapon"
	}
	self.definitions.bayonet = {
		dlc = "gage_pack_assault",
		category = "melee_weapon"
	}
	self.definitions.bullseye = {
		dlc = "gage_pack_assault",
		category = "melee_weapon"
	}
	self.definitions.baseballbat = {
		dlc = "hl_miami",
		category = "melee_weapon"
	}
	self.definitions.cleaver = {
		dlc = "hl_miami",
		category = "melee_weapon"
	}
	self.definitions.fireaxe = {
		dlc = "hl_miami",
		category = "melee_weapon"
	}
	self.definitions.machete = {
		dlc = "hl_miami",
		category = "melee_weapon"
	}
	self.definitions.briefcase = {
		dlc = "hlm_game",
		category = "melee_weapon"
	}
	self.definitions.fairbair = {
		dlc = "gage_pack_historical",
		category = "melee_weapon"
	}
	self.definitions.freedom = {
		dlc = "gage_pack_historical",
		category = "melee_weapon"
	}
	self.definitions.model24 = {
		dlc = "gage_pack_historical",
		category = "melee_weapon"
	}
	self.definitions.swagger = {
		dlc = "gage_pack_historical",
		category = "melee_weapon"
	}
	self.definitions.alien_maul = {
		dlc = "alienware_alpha_promo",
		category = "melee_weapon"
	}
	self.definitions.shillelagh = {
		dlc = "character_pack_clover",
		category = "melee_weapon"
	}
	self.definitions.boxing_gloves = {
		dlc = "pd2_clan",
		category = "melee_weapon"
	}
	self.definitions.meat_cleaver = {
		dlc = "character_pack_dragan",
		category = "melee_weapon"
	}
	self.definitions.hammer = {
		dlc = "hlm2_deluxe",
		category = "melee_weapon"
	}
	self.definitions.whiskey = {
		dlc = "pd2_clan",
		category = "melee_weapon"
	}
	self.definitions.scalper = {
		dlc = "west",
		category = "melee_weapon"
	}
	self.definitions.mining_pick = {
		dlc = "west",
		category = "melee_weapon"
	}
	self.definitions.branding_iron = {
		dlc = "west",
		category = "melee_weapon"
	}
	self.definitions.bowie = {
		dlc = "west",
		category = "melee_weapon"
	}
	self.definitions.microphone = {
		dlc = "arena",
		category = "melee_weapon"
	}
	self.definitions.detector = {
		dlc = "arena",
		category = "melee_weapon"
	}
	self.definitions.micstand = {
		dlc = "arena",
		category = "melee_weapon"
	}
	self.definitions.oldbaton = {
		dlc = "arena",
		category = "melee_weapon"
	}
	self.definitions.switchblade = {
		dlc = "kenaz",
		category = "melee_weapon"
	}
	self.definitions.taser = {
		dlc = "kenaz",
		category = "melee_weapon"
	}
	self.definitions.slot_lever = {
		dlc = "kenaz",
		category = "melee_weapon"
	}
	self.definitions.croupier_rake = {
		dlc = "kenaz",
		category = "melee_weapon"
	}
	self.definitions.hockey = {
		dlc = "character_pack_sokol",
		category = "melee_weapon"
	}
	self.definitions.twins = {
		dlc = "turtles",
		category = "melee_weapon"
	}
	self.definitions.cqc = {
		dlc = "turtles",
		category = "melee_weapon"
	}
	self.definitions.tiger = {
		dlc = "turtles",
		category = "melee_weapon"
	}
	self.definitions.fight = {
		dlc = "turtles",
		category = "melee_weapon"
	}
	self.definitions.sandsteel = {
		dlc = "dragon",
		category = "melee_weapon"
	}
	self.definitions.great = {
		dlc = "steel",
		category = "melee_weapon"
	}
	self.definitions.beardy = {
		dlc = "steel",
		category = "melee_weapon"
	}
	self.definitions.buck = {
		dlc = "steel",
		category = "melee_weapon"
	}
	self.definitions.morning = {
		dlc = "steel",
		category = "melee_weapon"
	}
	self.definitions.cutters = {
		category = "melee_weapon"
	}
	self.definitions.boxcutter = {
		category = "melee_weapon"
	}
	self.definitions.selfie = {
		dlc = "berry",
		category = "melee_weapon"
	}
	self.definitions.gator = {
		dlc = "berry",
		category = "melee_weapon"
	}
	self.definitions.pugio = {
		dlc = "berry",
		category = "melee_weapon"
	}
	self.definitions.iceaxe = {
		dlc = "berry",
		category = "melee_weapon"
	}
	self.definitions.shawn = {
		dlc = "peta",
		category = "melee_weapon"
	}
	self.definitions.stick = {
		dlc = "peta",
		category = "melee_weapon"
	}
	self.definitions.pitchfork = {
		dlc = "peta",
		category = "melee_weapon"
	}
	self.definitions.scoutknife = {
		dlc = "peta",
		category = "melee_weapon"
	}
	self.definitions.nin = {
		dlc = "pal",
		category = "melee_weapon"
	}
	self.definitions.ballistic = {
		category = "melee_weapon"
	}
	self.definitions.zeus = {
		category = "melee_weapon"
	}
	self.definitions.wing = {
		dlc = "opera",
		category = "melee_weapon"
	}
	self.definitions.road = {
		dlc = "wild",
		category = "melee_weapon"
	}
	self.definitions.cs = {
		dlc = "chico",
		category = "melee_weapon"
	}
	self.definitions.brick = {
		dlc = "friend",
		category = "melee_weapon"
	}
	self.definitions.ostry = {
		dlc = "sha",
		category = "melee_weapon"
	}
	self.definitions.catch = {
		dlc = "spa",
		category = "melee_weapon"
	}
	self.definitions.oxide = {
		dlc = "grv",
		category = "melee_weapon"
	}
	self.definitions.sword = {
		dlc = "pn2",
		category = "melee_weapon"
	}
	self.definitions.agave = {
		category = "melee_weapon"
	}
	self.definitions.happy = {
		category = "melee_weapon"
	}
	self.definitions.push = {
		category = "melee_weapon"
	}
	self.definitions.grip = {
		dlc = "raidww2_clan",
		category = "melee_weapon"
	}
	self.definitions.sap = {
		category = "melee_weapon"
	}
	self.definitions.clean = {
		category = "melee_weapon"
	}
	self.definitions.meter = {
		dlc = "ecp",
		category = "melee_weapon"
	}
	self.definitions.aziz = {
		dlc = "flm",
		category = "melee_weapon"
	}
	self.definitions.hauteur = {
		category = "melee_weapon"
	}
	self.definitions.shock = {
		category = "melee_weapon"
	}
	self.definitions.fear = {
		category = "melee_weapon"
	}
end

function UpgradesTweakData:_grenades_definitions()
	self.definitions.molotov = {
		dlc = "bbq",
		category = "grenade"
	}
	self.definitions.frag = {
		dlc = "gage_pack",
		category = "grenade"
	}
	self.definitions.dynamite = {
		dlc = "west",
		category = "grenade"
	}
	self.definitions.wpn_prj_four = {
		dlc = "turtles",
		category = "grenade"
	}
	self.definitions.wpn_prj_ace = {
		dlc = "pd2_clan",
		category = "grenade"
	}
	self.definitions.wpn_prj_jav = {
		dlc = "steel",
		category = "grenade"
	}
	self.definitions.wpn_prj_hur = {
		dlc = "born",
		category = "grenade"
	}
	self.definitions.wpn_prj_target = {
		dlc = "pim",
		category = "grenade"
	}
	self.definitions.frag_com = {
		dlc = "pd2_clan",
		category = "grenade"
	}
	self.definitions.concussion = {
		category = "grenade"
	}
	self.definitions.chico_injector = {
		dlc = "chico",
		category = "grenade"
	}
	self.definitions.fir_com = {
		dlc = "pd2_clan",
		category = "grenade"
	}
	self.definitions.smoke_screen_grenade = {
		category = "grenade"
	}
	self.definitions.dada_com = {
		dlc = "pd2_clan",
		category = "grenade"
	}
	self.definitions.pocket_ecm_jammer = {
		category = "grenade"
	}
	self.definitions.tag_team = {
		dlc = "ecp",
		category = "grenade"
	}
	self.definitions.damage_control = {
		category = "grenade"
	}
	self.definitions.wpn_dallas_mask = {
		category = "grenade"
	}
end

function UpgradesTweakData:_weapon_definitions()
	self.definitions.weapon_steelsight_highlight_specials = {
		name_id = "menu_weapon_steelsight_highlight_specials",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "steelsight_highlight_specials",
			category = "weapon"
		}
	}
	self.definitions.assault_rifle_move_spread_index_addend = {
		name_id = "menu_assault_rifle_move_spread_index_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "move_spread_index_addend",
			category = "assault_rifle"
		}
	}
	self.definitions.snp_move_spread_index_addend = {
		name_id = "menu_snp_move_spread_index_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "move_spread_index_addend",
			category = "snp"
		}
	}
	self.definitions.smg_move_spread_index_addend = {
		name_id = "menu_snp_move_spread_index_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "move_spread_index_addend",
			category = "smg"
		}
	}
	self.definitions.weapon_silencer_spread_index_addend = {
		name_id = "menu_weapon_silencer_spread_index_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "silencer_spread_index_addend",
			category = "weapon"
		}
	}
	self.definitions.pistol_spread_index_addend = {
		name_id = "menu_pistol_spread_index_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "spread_index_addend",
			category = "pistol"
		}
	}
	self.definitions.shotgun_hip_fire_spread_index_addend = {
		name_id = "menu_shotgun_hip_fire_spread_index_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "hip_fire_spread_index_addend",
			category = "shotgun"
		}
	}
	self.definitions.shotgun_hip_run_and_shoot_1 = {
		name_id = "menu_shotgun_hip_run_and_shoot",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "hip_run_and_shoot",
			category = "shotgun"
		}
	}
	self.definitions.shotgun_hip_rate_of_fire_1 = {
		name_id = "menu_shotgun_hip_run_and_shoot",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "hip_rate_of_fire",
			category = "shotgun"
		}
	}
	self.definitions.shotgun_magazine_capacity_inc_1 = {
		name_id = "menu_shotgun_magazine_capacity_inc",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "magazine_capacity_inc",
			category = "shotgun"
		}
	}
	self.definitions.shotgun_steelsight_accuracy_inc_1 = {
		name_id = "menu_shotgun_steelsight_accuracy_inc",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "steelsight_accuracy_inc",
			category = "shotgun"
		}
	}
	self.definitions.shotgun_steelsight_range_inc_1 = {
		name_id = "menu_shotgun_steelsight_range_inc",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "steelsight_range_inc",
			category = "shotgun"
		}
	}
	self.definitions.weapon_hip_fire_spread_index_addend = {
		name_id = "menu_weapon_hip_fire_spread_index_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "hip_fire_spread_index_addend",
			category = "weapon"
		}
	}
	self.definitions.weapon_single_spread_index_addend = {
		name_id = "menu_weapon_single_spread_index_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "single_spread_index_addend",
			category = "weapon"
		}
	}
	self.definitions.shotgun_recoil_index_addend = {
		name_id = "menu_shotgun_recoil_index_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "recoil_index_addend",
			category = "shotgun"
		}
	}
	self.definitions.assault_rifle_recoil_index_addend = {
		name_id = "menu_assault_rifle_recoil_index_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "recoil_index_addend",
			category = "assault_rifle"
		}
	}
	self.definitions.lmg_recoil_index_addend = {
		name_id = "menu_lmg_recoil_index_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "recoil_index_addend",
			category = "lmg"
		}
	}
	self.definitions.snp_recoil_index_addend = {
		name_id = "menu_snp_recoil_index_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "recoil_index_addend",
			category = "snp"
		}
	}
	self.definitions.akimbo_recoil_index_addend_1 = {
		incremental = true,
		name_id = "menu_akimbo_recoil_index_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "recoil_index_addend",
			category = "akimbo"
		}
	}
	self.definitions.akimbo_recoil_index_addend_2 = {
		incremental = true,
		name_id = "menu_akimbo_recoil_index_addend",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "recoil_index_addend",
			category = "akimbo"
		}
	}
	self.definitions.akimbo_recoil_index_addend_3 = {
		incremental = true,
		name_id = "menu_akimbo_recoil_index_addend",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "recoil_index_addend",
			category = "akimbo"
		}
	}
	self.definitions.akimbo_recoil_index_addend_4 = {
		incremental = true,
		name_id = "menu_akimbo_recoil_index_addend",
		category = "feature",
		upgrade = {
			value = 4,
			upgrade = "recoil_index_addend",
			category = "akimbo"
		}
	}
	self.definitions.weapon_silencer_recoil_index_addend = {
		name_id = "menu_weapon_silencer_recoil_index_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "silencer_recoil_index_addend",
			category = "weapon"
		}
	}
	self.definitions.weapon_modded_damage_multiplier = {
		name_id = "menu_modded_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "modded_damage_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_modded_spread_multiplier = {
		name_id = "menu_modded_spread_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "modded_spread_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_modded_recoil_multiplier = {
		name_id = "menu_modded_recoil_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "modded_recoil_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_clip_ammo_increase_1 = {
		name_id = "menu_weapon_clip_ammo_increase_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "clip_ammo_increase",
			category = "weapon"
		}
	}
	self.definitions.weapon_clip_ammo_increase_2 = {
		name_id = "menu_weapon_clip_ammo_increase_2",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "clip_ammo_increase",
			category = "weapon"
		}
	}
	self.definitions.weapon_passive_swap_speed_multiplier_1 = {
		name_id = "menu_weapon_swap_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_swap_speed_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_passive_swap_speed_multiplier_2 = {
		name_id = "menu_weapon_swap_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "passive_swap_speed_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_swap_speed_multiplier = {
		name_id = "menu_weapon_swap_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "swap_speed_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_single_spread_multiplier = {
		name_id = "menu_weapon_single_spread_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "single_spread_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_silencer_enter_steelsight_speed_multiplier = {
		name_id = "menu_weapon_silencer_enter_steelsight_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "silencer_enter_steelsight_speed_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_silencer_spread_multiplier = {
		name_id = "menu_silencer_spread_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "silencer_spread_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_enter_steelsight_speed_multiplier = {
		name_id = "menu_weapon_enter_steelsight_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "enter_steelsight_speed_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_silencer_recoil_multiplier = {
		name_id = "menu_silencer_recoil_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "silencer_recoil_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_passive_reload_speed_multiplier = {
		name_id = "menu_weapon_reload_speed",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_reload_speed_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_passive_recoil_multiplier_1 = {
		name_id = "menu_weapon_recoil_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_recoil_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_passive_recoil_multiplier_2 = {
		name_id = "menu_weapon_recoil_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "passive_recoil_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_passive_headshot_damage_multiplier = {
		name_id = "menu_weapon_headshot_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_headshot_damage_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_passive_damage_multiplier = {
		name_id = "menu_weapon_passive_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_damage_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_special_damage_taken_multiplier = {
		name_id = "menu_weapon_special_damage_taken_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "special_damage_taken_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_spread_multiplier = {
		name_id = "menu_weapon_spread_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "spread_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_fire_rate_multiplier = {
		name_id = "menu_weapon_fire_rate_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "fire_rate_multiplier",
			category = "weapon"
		}
	}
	self.definitions.snp_graze_damage_1 = {
		name_id = "menu_snp_graze_damage",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "graze_damage",
			category = "snp"
		}
	}
	self.definitions.snp_graze_damage_2 = {
		name_id = "menu_snp_graze_damage",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "graze_damage",
			category = "snp"
		}
	}
end

function UpgradesTweakData:_pistol_definitions()
	self.definitions.pistol_reload_speed_multiplier = {
		name_id = "menu_pistol_reload_speed",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "reload_speed_multiplier",
			category = "pistol"
		}
	}
	self.definitions.pistol_damage_multiplier = {
		name_id = "menu_pistol_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "damage_multiplier",
			category = "pistol"
		}
	}
	self.definitions.pistol_spread_multiplier = {
		name_id = "menu_pistol_spread_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "spread_multiplier",
			category = "pistol"
		}
	}
	self.definitions.pistol_fire_rate_multiplier = {
		name_id = "menu_pistol_fire_rate_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "fire_rate_multiplier",
			category = "pistol"
		}
	}
	self.definitions.pistol_stacked_accuracy_bonus_1 = {
		name_id = "menu_pistol_stacked_accuracy_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "stacked_accuracy_bonus",
			category = "pistol"
		}
	}
	self.definitions.pistol_stacking_hit_damage_multiplier_1 = {
		name_id = "menu_pistol_stacking_hit_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "stacking_hit_damage_multiplier",
			category = "pistol"
		}
	}
	self.definitions.pistol_stacking_hit_damage_multiplier_2 = {
		name_id = "menu_pistol_stacking_hit_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "stacking_hit_damage_multiplier",
			category = "pistol"
		}
	}
	self.definitions.pistol_exit_run_speed_multiplier = {
		name_id = "menu_exit_run_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "exit_run_speed_multiplier",
			category = "pistol"
		}
	}
	self.definitions.pistol_hip_fire_spread_multiplier = {
		name_id = "menu_pistol_hip_fire_spread_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "hip_fire_spread_multiplier",
			category = "pistol"
		}
	}
	self.definitions.pistol_hip_fire_damage_multiplier = {
		name_id = "menu_pistol_hip_fire_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "hip_fire_damage_multiplier",
			category = "pistol"
		}
	}
	self.definitions.pistol_swap_speed_multiplier = {
		name_id = "menu_pistol_swap_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "swap_speed_multiplier",
			category = "pistol"
		}
	}
	self.definitions.pistol_stacking_hit_expire_t_1 = {
		name_id = "menu_pistol_stacking_hit_expire_t",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "stacking_hit_expire_t",
			category = "pistol"
		}
	}
	self.definitions.pistol_stacking_hit_expire_t_2 = {
		name_id = "menu_pistol_stacking_hit_expire_t",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "stacking_hit_expire_t",
			category = "pistol"
		}
	}
	self.definitions.pistol_damage_addend_1 = {
		name_id = "menu_pistol_damage_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "damage_addend",
			category = "pistol"
		}
	}
	self.definitions.pistol_damage_addend_2 = {
		name_id = "menu_pistol_damage_addend",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "damage_addend",
			category = "pistol"
		}
	}
	self.definitions.pistol_magazine_capacity_inc_1 = {
		name_id = "menu_pistol_magazine_capacity_inc",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "magazine_capacity_inc",
			category = "pistol"
		}
	}
	self.definitions.pistol_zoom_increase = {
		name_id = "menu_pistol_zoom_increase",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "zoom_increase",
			category = "pistol"
		}
	}
end

function UpgradesTweakData:_assault_rifle_definitions()
	self.definitions.assault_rifle_recoil_multiplier = {
		name_id = "menu_assault_rifle_recoil_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "recoil_multiplier",
			category = "assault_rifle"
		}
	}
	self.definitions.assault_rifle_enter_steelsight_speed_multiplier = {
		name_id = "menu_assault_rifle_enter_steelsight_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "enter_steelsight_speed_multiplier",
			category = "assault_rifle"
		}
	}
	self.definitions.assault_rifle_reload_speed_multiplier = {
		name_id = "menu_assault_rifle_reload_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "reload_speed_multiplier",
			category = "assault_rifle"
		}
	}
	self.definitions.assault_rifle_move_spread_multiplier = {
		name_id = "menu_assault_rifle_move_spread_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "move_spread_multiplier",
			category = "assault_rifle"
		}
	}
	self.definitions.assault_rifle_hip_fire_spread_multiplier = {
		name_id = "menu_assault_rifle_hip_fire_spread_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "hip_fire_spread_multiplier",
			category = "assault_rifle"
		}
	}
	self.definitions.assault_rifle_hip_fire_damage_multiplier = {
		name_id = "menu_assault_rifle_hip_fire_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "hip_fire_damage_multiplier",
			category = "assault_rifle"
		}
	}
	self.definitions.assault_rifle_zoom_increase = {
		name_id = "menu_assault_rifle_zoom_increase",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "zoom_increase",
			category = "assault_rifle"
		}
	}
end

function UpgradesTweakData:_lmg_definitions()
	self.definitions.lmg_recoil_multiplier = {
		name_id = "menu_lmg_recoil_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "recoil_multiplier",
			category = "lmg"
		}
	}
	self.definitions.lmg_enter_steelsight_speed_multiplier = {
		name_id = "menu_lmg_enter_steelsight_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "enter_steelsight_speed_multiplier",
			category = "lmg"
		}
	}
	self.definitions.lmg_reload_speed_multiplier = {
		name_id = "menu_lmg_reload_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "reload_speed_multiplier",
			category = "lmg"
		}
	}
	self.definitions.lmg_move_spread_multiplier = {
		name_id = "menu_lmg_move_spread_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "move_spread_multiplier",
			category = "lmg"
		}
	}
	self.definitions.lmg_hip_fire_spread_multiplier = {
		name_id = "menu_lmg_hip_fire_spread_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "hip_fire_spread_multiplier",
			category = "lmg"
		}
	}
	self.definitions.lmg_hip_fire_damage_multiplier = {
		name_id = "menu_lmg_hip_fire_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "hip_fire_damage_multiplier",
			category = "lmg"
		}
	}
	self.definitions.lmg_zoom_increase = {
		name_id = "menu_lmg_zoom_increase",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "zoom_increase",
			category = "lmg"
		}
	}
end

function UpgradesTweakData:_snp_definitions()
	self.definitions.snp_recoil_multiplier = {
		name_id = "menu_snp_recoil_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "recoil_multiplier",
			category = "snp"
		}
	}
	self.definitions.snp_enter_steelsight_speed_multiplier = {
		name_id = "menu_snp_enter_steelsight_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "enter_steelsight_speed_multiplier",
			category = "snp"
		}
	}
	self.definitions.snp_reload_speed_multiplier = {
		name_id = "menu_snp_reload_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "reload_speed_multiplier",
			category = "snp"
		}
	}
	self.definitions.snp_move_spread_multiplier = {
		name_id = "menu_snp_move_spread_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "move_spread_multiplier",
			category = "snp"
		}
	}
	self.definitions.snp_hip_fire_spread_multiplier = {
		name_id = "menu_snp_hip_fire_spread_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "hip_fire_spread_multiplier",
			category = "snp"
		}
	}
	self.definitions.snp_hip_fire_damage_multiplier = {
		name_id = "menu_snp_hip_fire_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "hip_fire_damage_multiplier",
			category = "snp"
		}
	}
	self.definitions.snp_zoom_increase = {
		name_id = "menu_snp_zoom_increase",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "zoom_increase",
			category = "snp"
		}
	}
end

function UpgradesTweakData:_smg_definitions()
	self.definitions.smg_reload_speed_multiplier = {
		name_id = "menu_reload_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "reload_speed_multiplier",
			category = "smg"
		}
	}
	self.definitions.smg_recoil_multiplier = {
		name_id = "menu_smg_recoil_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "recoil_multiplier",
			category = "smg"
		}
	}
	self.definitions.smg_fire_rate_multiplier = {
		name_id = "menu_smg_fire_rate_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "fire_rate_multiplier",
			category = "smg"
		}
	}
	self.definitions.smg_hip_fire_spread_multiplier = {
		name_id = "menu_smg_hip_fire_spread_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "hip_fire_spread_multiplier",
			category = "smg"
		}
	}
	self.definitions.smg_hip_fire_damage_multiplier = {
		name_id = "menu_smg_hip_fire_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "hip_fire_damage_multiplier",
			category = "smg"
		}
	}
	self.definitions.smg_zoom_increase = {
		name_id = "menu_snp_zoom_increase",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "zoom_increase",
			category = "smg"
		}
	}
end

function UpgradesTweakData:_shotgun_definitions()
	self.definitions.shotgun_recoil_multiplier = {
		name_id = "menu_shotgun_recoil_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "recoil_multiplier",
			category = "shotgun"
		}
	}
	self.definitions.shotgun_damage_multiplier_1 = {
		name_id = "menu_shotgun_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "damage_multiplier",
			category = "shotgun"
		}
	}
	self.definitions.shotgun_damage_multiplier_2 = {
		name_id = "menu_shotgun_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "damage_multiplier",
			category = "shotgun"
		}
	}
	self.definitions.shotgun_reload_speed_multiplier_1 = {
		name_id = "menu_shotgun_reload_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "reload_speed_multiplier",
			category = "shotgun"
		}
	}
	self.definitions.shotgun_reload_speed_multiplier_2 = {
		name_id = "menu_shotgun_reload_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "reload_speed_multiplier",
			category = "shotgun"
		}
	}
	self.definitions.shotgun_enter_steelsight_speed_multiplier = {
		name_id = "menu_shotgun_enter_steelsight_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "enter_steelsight_speed_multiplier",
			category = "shotgun"
		}
	}
	self.definitions.shotgun_hip_fire_spread_multiplier = {
		name_id = "menu_shotgun_hip_fire_spread_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "hip_fire_spread_multiplier",
			category = "shotgun"
		}
	}
	self.definitions.shotgun_hip_fire_damage_multiplier = {
		name_id = "menu_shotgun_hip_fire_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "hip_fire_damage_multiplier",
			category = "shotgun"
		}
	}
	self.definitions.shotgun_consume_no_ammo_chance_1 = {
		name_id = "menu_shotgun_consume_no_ammo_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "consume_no_ammo_chance",
			category = "shotgun"
		}
	}
	self.definitions.shotgun_consume_no_ammo_chance_2 = {
		name_id = "menu_shotgun_consume_no_ammo_chance",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "consume_no_ammo_chance",
			category = "shotgun"
		}
	}
	self.definitions.shotgun_melee_knockdown_mul = {
		name_id = "menu_shotgun_melee_knockdown_mul",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "melee_knockdown_mul",
			category = "shotgun"
		}
	}
end

function UpgradesTweakData:_carry_definitions()
	self.definitions.carry_movement_penalty_nullifier = {
		name_id = "menu_carry_movement_penalty_nullifier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "movement_penalty_nullifier",
			category = "carry"
		}
	}
	self.definitions.carry_movement_speed_multiplier = {
		name_id = "menu_carry_movement_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "movement_speed_multiplier",
			category = "carry"
		}
	}
	self.definitions.carry_throw_distance_multiplier = {
		name_id = "menu_carry_throw_distance_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "throw_distance_multiplier",
			category = "carry"
		}
	}
	self.definitions.carry_interact_speed_multiplier_1 = {
		name_id = "menu_carry_interact_speed_multiplierr",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "interact_speed_multiplier",
			category = "carry"
		}
	}
	self.definitions.carry_catch_interaction_speed_1 = {
		name_id = "menu_carry_catch_interaction_speed",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "catch_interaction_speed",
			category = "carry"
		}
	}
	self.definitions.carry_interact_speed_multiplier_2 = {
		name_id = "menu_carry_interact_speed_multiplierr",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "interact_speed_multiplier",
			category = "carry"
		}
	}
	self.definitions.carry_catch_interaction_speed_2 = {
		name_id = "menu_carry_catch_interaction_speed",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "catch_interaction_speed",
			category = "carry"
		}
	}
	self.definitions.carry_bag_count_1 = {
		name_id = "menu_carry_catch_interaction_speed",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "carry_bag_count",
			category = "carry"
		}
	}
end

function UpgradesTweakData:_team_definitions()
	self.definitions.team_pistol_recoil_index_addend = {
		name_id = "menu_team_pistol_recoil_index_addend",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "recoil_index_addend",
			category = "pistol"
		}
	}
	self.definitions.team_weapon_recoil_index_addend = {
		name_id = "menu_team_weapon_recoil_index_addend",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "recoil_index_addend",
			category = "weapon"
		}
	}
	self.definitions.team_pistol_suppression_recoil_index_addend = {
		name_id = "menu_team_pistol_suppression_recoil_index_addend",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "suppression_recoil_index_addend",
			category = "pistol"
		}
	}
	self.definitions.team_weapon_suppression_recoil_index_addend = {
		name_id = "menu_team_weapon_suppression_recoil_index_addend",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "suppression_recoil_index_addend",
			category = "weapon"
		}
	}
	self.definitions.team_pistol_suppression_recoil_multiplier = {
		name_id = "menu_team_pistol_suppression_recoil_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "suppression_recoil_multiplier",
			category = "pistol"
		}
	}
	self.definitions.team_akimbo_suppression_recoil_multiplier = {
		name_id = "menu_team_akimbo_suppression_recoil_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "suppression_recoil_multiplier",
			category = "akimbo"
		}
	}
	self.definitions.team_pistol_recoil_multiplier = {
		name_id = "menu_team_pistol_recoil_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "recoil_multiplier",
			category = "pistol"
		}
	}
	self.definitions.team_akimbo_recoil_multiplier = {
		name_id = "menu_team_akimbo_recoil_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "recoil_multiplier",
			category = "akimbo"
		}
	}
	self.definitions.team_weapon_suppression_recoil_multiplier = {
		name_id = "menu_team_weapon_suppression_recoil_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "suppression_recoil_multiplier",
			category = "weapon"
		}
	}
	self.definitions.team_weapon_recoil_multiplier = {
		name_id = "menu_team_weapon_recoil_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "recoil_multiplier",
			category = "weapon"
		}
	}
	self.definitions.team_xp_multiplier = {
		name_id = "menu_team_xp_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "multiplier",
			category = "xp"
		}
	}
	self.definitions.team_armor_regen_time_multiplier = {
		name_id = "menu_team_armor_regen_time_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "regen_time_multiplier",
			category = "armor"
		}
	}
	self.definitions.team_passive_armor_regen_time_multiplier = {
		name_id = "menu_team_armor_regen_time_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "passive_regen_time_multiplier",
			category = "armor"
		}
	}
	self.definitions.team_stamina_multiplier = {
		name_id = "menu_team_stamina_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "multiplier",
			category = "stamina"
		}
	}
	self.definitions.team_damage_hostage_absorption = {
		name_id = "menu_team_damage_hostage_absorption",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "hostage_absorption",
			category = "damage"
		}
	}
	self.definitions.team_passive_stamina_multiplier_1 = {
		name_id = "menu_team_stamina_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "passive_multiplier",
			category = "stamina"
		}
	}
	self.definitions.team_passive_stamina_multiplier_2 = {
		name_id = "menu_team_stamina_multiplier",
		category = "team",
		upgrade = {
			value = 2,
			upgrade = "passive_multiplier",
			category = "stamina"
		}
	}
	self.definitions.team_passive_health_multiplier = {
		name_id = "menu_team_health_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "passive_multiplier",
			category = "health"
		}
	}
	self.definitions.team_hostage_health_multiplier = {
		name_id = "menu_team_hostage_health_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "hostage_multiplier",
			category = "health"
		}
	}
	self.definitions.team_hostage_stamina_multiplier = {
		name_id = "menu_team_hostage_stamina_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "hostage_multiplier",
			category = "stamina"
		}
	}
	self.definitions.team_clients_buy_assets = {
		name_id = "menu_team_clients_buy_assets",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "clients_buy_assets",
			category = "player"
		}
	}
	self.definitions.team_move_spread_multiplier = {
		name_id = "menu_team_move_spread_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "move_spread_multiplier",
			category = "weapon"
		}
	}
	self.definitions.team_civ_intimidation_mul = {
		name_id = "menu_team_civ_intimidation_mul",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "civ_intimidation_mul",
			category = "player"
		}
	}
	self.definitions.team_xp_stealth_multiplier = {
		name_id = "menu_team_xp_stealth_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "stealth_multiplier",
			category = "xp"
		}
	}
	self.definitions.team_cash_stealth_multiplier = {
		name_id = "menu_team_cash_stealth_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "stealth_money_multiplier",
			category = "cash"
		}
	}
	self.definitions.team_bags_stealth_multiplier = {
		name_id = "menu_team_bags_stealth_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "stealth_bags_multiplier",
			category = "cash"
		}
	}
	self.definitions.team_hostage_damage_dampener_multiplier = {
		name_id = "menu_team_hostage_damage_dampener_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "hostage_multiplier",
			category = "damage_dampener"
		}
	}
	self.definitions.team_damage_reduction_1 = {
		name_id = "menu_team_hostage_damage_dampener_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "team_damage_reduction",
			category = "damage_dampener"
		}
	}

	self:_crew_definitions()
end

function UpgradesTweakData:_crew_definitions()
	self.crew_skill_definitions = self.crew_skill_definitions or {}
	self.crew_ability_definitions = self.crew_ability_definitions or {}
	self.crew_skill_definitions.crew_healthy = {
		name_id = "menu_crew_healthy",
		icon = "skill_1",
		upgrades = {
			{
				value = 1,
				upgrade = "crew_add_health",
				category = "team"
			}
		}
	}
	self.crew_skill_definitions.crew_sturdy = {
		name_id = "menu_crew_sturdy",
		icon = "skill_2",
		upgrades = {
			{
				value = 1,
				upgrade = "crew_add_armor",
				category = "team"
			}
		}
	}
	self.crew_skill_definitions.crew_evasive = {
		name_id = "menu_crew_evasive",
		icon = "skill_3",
		upgrades = {
			{
				value = 1,
				upgrade = "crew_add_dodge",
				category = "team"
			}
		}
	}
	self.crew_skill_definitions.crew_regen = {
		name_id = "menu_crew_regen",
		icon = "skill_5",
		upgrades = {
			{
				value = 1,
				upgrade = "crew_health_regen",
				category = "team"
			}
		}
	}
	self.crew_skill_definitions.crew_motivated = {
		name_id = "menu_crew_motivated",
		icon = "skill_4",
		upgrades = {
			{
				value = 1,
				upgrade = "crew_add_stamina",
				category = "team"
			},
			{
				value = 1,
				upgrade = "crew_reduce_speed_penalty",
				category = "team"
			}
		}
	}
	self.crew_skill_definitions.crew_eager = {
		name_id = "menu_crew_eager",
		icon = "skill_8",
		upgrades = {
			{
				value = 1,
				upgrade = "crew_faster_swap",
				category = "team"
			},
			{
				value = 1,
				upgrade = "crew_faster_reload",
				category = "team"
			}
		}
	}
	self.crew_skill_definitions.crew_quiet = {
		name_id = "menu_crew_quiet",
		icon = "skill_6",
		upgrades = {
			{
				value = 1,
				upgrade = "crew_add_concealment",
				category = "team"
			}
		}
	}
	self.crew_skill_definitions.crew_generous = {
		name_id = "menu_crew_generous",
		icon = "skill_7",
		upgrades = {
			{
				value = 1,
				upgrade = "crew_throwable_regen",
				category = "team"
			}
		}
	}
	self.crew_ability_definitions.crew_inspire = {
		name_id = "menu_crew_inspire",
		icon = "ability_1"
	}
	self.crew_ability_definitions.crew_scavenge = {
		name_id = "menu_crew_scavenge",
		icon = "ability_2"
	}
	self.crew_ability_definitions.crew_interact = {
		name_id = "menu_crew_interact",
		icon = "ability_3"
	}
	self.crew_ability_definitions.crew_ai_ap_ammo = {
		name_id = "menu_crew_ai_ap_ammo",
		icon = "ability_4"
	}
end

function UpgradesTweakData:_temporary_definitions()
	self.definitions.temporary_armor_break_invulnerable_1 = {
		name_id = "menu_player_health_multiplier",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "armor_break_invulnerable",
			category = "temporary"
		}
	}
	self.definitions.temporary_combat_medic_damage_multiplier1 = {
		incremental = true,
		name_id = "menu_temporary_combat_medic_damage_multiplier",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "combat_medic_damage_multiplier",
			category = "temporary"
		}
	}
	self.definitions.temporary_combat_medic_damage_multiplier2 = {
		incremental = true,
		name_id = "menu_temporary_combat_medic_damage_multiplier",
		category = "temporary",
		upgrade = {
			value = 2,
			upgrade = "combat_medic_damage_multiplier",
			category = "temporary"
		}
	}
	self.definitions.temporary_combat_medic_enter_steelsight_speed_multiplier = {
		name_id = "menu_temporary_combat_medic_enter_steelsight_speed_multiplier",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "combat_medic_enter_steelsight_speed_multiplier",
			category = "temporary"
		}
	}
	self.definitions.temporary_revive_health_boost = {
		name_id = "menu_temporary_revive_health_boost",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "revive_health_boost",
			category = "temporary"
		}
	}
	self.definitions.temporary_berserker_damage_multiplier_1 = {
		name_id = "menu_temporary_berserker_damage_multiplier",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "berserker_damage_multiplier",
			category = "temporary"
		}
	}
	self.definitions.temporary_berserker_damage_multiplier_2 = {
		name_id = "menu_temporary_berserker_damage_multiplier",
		category = "temporary",
		upgrade = {
			value = 2,
			upgrade = "berserker_damage_multiplier",
			category = "temporary"
		}
	}
	self.definitions.temporary_no_ammo_cost_buff = {
		name_id = "menu_temporary_no_ammo_cost_buff",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "no_ammo_cost_buff",
			category = "temporary"
		}
	}
	self.definitions.temporary_no_ammo_cost_1 = {
		name_id = "menu_temporary_no_ammo_cost_1",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "no_ammo_cost",
			category = "player"
		}
	}
	self.definitions.temporary_no_ammo_cost_2 = {
		name_id = "menu_temporary_no_ammo_cost_2",
		category = "temporary",
		upgrade = {
			value = 2,
			upgrade = "no_ammo_cost",
			category = "player"
		}
	}
	self.definitions.temporary_first_aid_damage_reduction = {
		name_id = "menu_temporary_first_aid_damage_reduction",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "first_aid_damage_reduction",
			category = "temporary"
		}
	}
	self.definitions.temporary_passive_revive_damage_reduction_1 = {
		name_id = "menu_passive_revive_damage_reduction_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_revive_damage_reduction_1",
			category = "temporary"
		}
	}
	self.definitions.temporary_passive_revive_damage_reduction_2 = {
		name_id = "menu_passive_revive_damage_reduction",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "passive_revive_damage_reduction",
			category = "temporary"
		}
	}
	self.definitions.temporary_loose_ammo_restore_health_1 = {
		name_id = "menu_temporary_loose_ammo_restore_health",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "loose_ammo_restore_health",
			category = "temporary"
		}
	}
	self.definitions.temporary_loose_ammo_restore_health_2 = {
		name_id = "menu_temporary_loose_ammo_restore_health",
		category = "temporary",
		upgrade = {
			value = 2,
			upgrade = "loose_ammo_restore_health",
			category = "temporary"
		}
	}
	self.definitions.temporary_loose_ammo_restore_health_3 = {
		name_id = "menu_temporary_loose_ammo_restore_health",
		category = "temporary",
		upgrade = {
			value = 3,
			upgrade = "loose_ammo_restore_health",
			category = "temporary"
		}
	}
	self.definitions.temporary_loose_ammo_give_team = {
		name_id = "menu_temporary_loose_ammo_give_team",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "loose_ammo_give_team",
			category = "temporary"
		}
	}
end

function UpgradesTweakData:_cooldown_definitions()
	self.definitions.cooldown_long_dis_revive = {
		name_id = "menu_cooldown_long_dis_revive",
		category = "cooldown",
		upgrade = {
			value = 1,
			upgrade = "long_dis_revive",
			category = "cooldown"
		}
	}
end

function UpgradesTweakData:_shape_charge_definitions()
	self.definitions.shape_charge = {
		name_id = "menu_shape_charge",
		equipment_id = "shape_charge",
		category = "equipment"
	}
end

function UpgradesTweakData:_m4_definitions()
	self.definitions.m4 = {
		description_text_id = "des_m4",
		prio = "high",
		weapon_id = "m4",
		image = "upgrades_m4",
		image_slice = "upgrades_m4_slice",
		title_id = "debug_m4_rifle_short",
		category = "weapon",
		name_id = "debug_m4_rifle",
		icon = "m4",
		unlock_lvl = 0,
		unit_name = Idstring("units/weapons/m4_rifle/m4_rifle")
	}

	for i, _ in ipairs(self.values.m4.clip_ammo_increase) do
		local depends_on = i - 1 > 0 and "m4_mag" .. i - 1 or "m4"
		local unlock_lvl = 3
		local prio = i == 1 and "high"
		self.definitions["m4_mag" .. i] = {
			description_text_id = "clip_ammo_increase",
			tree = 3,
			image = "upgrades_m4",
			image_slice = "upgrades_m4_slice",
			title_id = "debug_m4_rifle_short",
			category = "feature",
			icon = "m4",
			step = self.steps.m4.clip_ammo_increase[i],
			name_id = "debug_upgrade_m4_mag" .. i,
			subtitle_id = "debug_upgrade_mag" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "clip_ammo_increase",
				category = "m4",
				value = i
			}
		}
	end

	for i, _ in ipairs(self.values.m4.spread_multiplier) do
		local depends_on = i - 1 > 0 and "m4_spread" .. i - 1 or "m4"
		local unlock_lvl = 4
		local prio = i == 1 and "high"
		self.definitions["m4_spread" .. i] = {
			description_text_id = "spread_multiplier",
			tree = 2,
			image = "upgrades_m4",
			image_slice = "upgrades_m4_slice",
			title_id = "debug_m4_rifle_short",
			category = "feature",
			icon = "m4",
			step = self.steps.m4.spread_multiplier[i],
			name_id = "debug_upgrade_m4_spread" .. i,
			subtitle_id = "debug_upgrade_spread" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "spread_multiplier",
				category = "m4",
				value = i
			}
		}
	end

	for i, _ in ipairs(self.values.m4.damage_multiplier) do
		local depends_on = i - 1 > 0 and "m4_damage" .. i - 1 or "m4"
		local unlock_lvl = 5
		local prio = i == 1 and "high"
		self.definitions["m4_damage" .. i] = {
			description_text_id = "damage_multiplier",
			tree = 1,
			image = "upgrades_m4",
			image_slice = "upgrades_m4_slice",
			title_id = "debug_m4_rifle_short",
			category = "feature",
			icon = "m4",
			step = self.steps.m4.damage_multiplier[i],
			name_id = "debug_upgrade_m4_damage" .. i,
			subtitle_id = "debug_upgrade_damage" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "damage_multiplier",
				category = "m4",
				value = i
			}
		}
	end
end

function UpgradesTweakData:_m14_definitions()
	self.definitions.m14 = {
		description_text_id = "des_m14",
		image_slice = "upgrades_m14_slice",
		prio = "high",
		category = "weapon",
		tree = 2,
		image = "upgrades_m14",
		weapon_id = "m14",
		title_id = "debug_upgrade_new_weapon",
		subtitle_id = "debug_m14_short",
		name_id = "debug_m14",
		icon = "m14",
		unlock_lvl = 101,
		step = 17,
		unit_name = Idstring("units/weapons/m14/m14")
	}

	for i, _ in ipairs(self.values.m14.clip_ammo_increase) do
		local depends_on = i - 1 > 0 and "m14_mag" .. i - 1 or "m14"
		local unlock_lvl = 102
		local prio = i == 1 and "high"
		self.definitions["m14_mag" .. i] = {
			description_text_id = "clip_ammo_increase",
			tree = 2,
			image = "upgrades_m14",
			image_slice = "upgrades_m14_slice",
			title_id = "debug_m14_short",
			category = "feature",
			icon = "m14",
			step = self.steps.m14.clip_ammo_increase[i],
			name_id = "debug_upgrade_m14_mag" .. i,
			subtitle_id = "debug_upgrade_mag" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "clip_ammo_increase",
				category = "m14",
				value = i
			}
		}
	end

	for i, _ in ipairs(self.values.m14.spread_multiplier) do
		local depends_on = i - 1 > 0 and "m14_spread" .. i - 1 or "m14"
		local unlock_lvl = 102
		local prio = i == 1 and "high"
		self.definitions["m14_spread" .. i] = {
			description_text_id = "spread_multiplier",
			tree = 2,
			image = "upgrades_m14",
			image_slice = "upgrades_m14_slice",
			title_id = "debug_m14_short",
			category = "feature",
			icon = "m14",
			step = self.steps.m14.spread_multiplier[i],
			name_id = "debug_upgrade_m14_spread" .. i,
			subtitle_id = "debug_upgrade_spread" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "spread_multiplier",
				category = "m14",
				value = i
			}
		}
	end

	for i, _ in ipairs(self.values.m14.damage_multiplier) do
		local depends_on = i - 1 > 0 and "m14_damage" .. i - 1 or "m14"
		local unlock_lvl = 102
		local prio = i == 1 and "high"
		self.definitions["m14_damage" .. i] = {
			description_text_id = "damage_multiplier",
			tree = 2,
			image = "upgrades_m14",
			image_slice = "upgrades_m14_slice",
			title_id = "debug_m14_short",
			category = "feature",
			icon = "m14",
			step = self.steps.m14.damage_multiplier[i],
			name_id = "debug_upgrade_m14_damage" .. i,
			subtitle_id = "debug_upgrade_damage" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "damage_multiplier",
				category = "m14",
				value = i
			}
		}
	end

	for i, _ in ipairs(self.values.m14.recoil_multiplier) do
		local depends_on = i - 1 > 0 and "m14_recoil" .. i - 1 or "m14"
		local unlock_lvl = 102
		local prio = i == 1 and "high"
		self.definitions["m14_recoil" .. i] = {
			description_text_id = "recoil_multiplier",
			tree = 2,
			image = "upgrades_m14",
			image_slice = "upgrades_m14_slice",
			title_id = "debug_m14_short",
			category = "feature",
			icon = "m14",
			step = self.steps.m14.recoil_multiplier[i],
			name_id = "debug_upgrade_m14_recoil" .. i,
			subtitle_id = "debug_upgrade_recoil" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "recoil_multiplier",
				category = "m14",
				value = i
			}
		}
	end
end

function UpgradesTweakData:_mp5_definitions()
	self.definitions.mp5 = {
		description_text_id = "des_mp5",
		image_slice = "upgrades_mp5_slice",
		prio = "high",
		category = "weapon",
		tree = 3,
		image = "upgrades_mp5",
		weapon_id = "mp5",
		title_id = "debug_upgrade_new_weapon",
		subtitle_id = "debug_mp5_short",
		name_id = "debug_mp5",
		icon = "mp5",
		unlock_lvl = 6,
		step = 21,
		unit_name = Idstring("units/weapons/mp5/mp5")
	}

	for i, _ in ipairs(self.values.mp5.spread_multiplier) do
		local depends_on = i - 1 > 0 and "mp5_spread" .. i - 1 or "mp5"
		local unlock_lvl = 7
		local prio = i == 1 and "high"
		self.definitions["mp5_spread" .. i] = {
			description_text_id = "spread_multiplier",
			tree = 3,
			image = "upgrades_mp5",
			image_slice = "upgrades_mp5_slice",
			title_id = "debug_mp5_short",
			category = "feature",
			icon = "mp5",
			step = self.steps.mp5.spread_multiplier[i],
			name_id = "debug_upgrade_mp5_spread" .. i,
			subtitle_id = "debug_upgrade_spread" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "spread_multiplier",
				category = "mp5",
				value = i
			}
		}
	end

	for i, _ in ipairs(self.values.mp5.recoil_multiplier) do
		local depends_on = i - 1 > 0 and "mp5_recoil" .. i - 1 or "mp5"
		local unlock_lvl = 8
		local prio = i == 1 and "high"
		self.definitions["mp5_recoil" .. i] = {
			description_text_id = "recoil_multiplier",
			tree = 3,
			image = "upgrades_mp5",
			image_slice = "upgrades_mp5_slice",
			title_id = "debug_mp5_short",
			category = "feature",
			icon = "mp5",
			step = self.steps.mp5.recoil_multiplier[i],
			name_id = "debug_upgrade_mp5_recoil" .. i,
			subtitle_id = "debug_upgrade_recoil" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "recoil_multiplier",
				category = "mp5",
				value = i
			}
		}
	end

	for i, _ in ipairs(self.values.mp5.reload_speed_multiplier) do
		local depends_on = i - 1 > 0 and "mp5_reload_speed" .. i - 1 or "mp5"
		local unlock_lvl = 9
		local prio = i == 1 and "high"
		self.definitions["mp5_reload_speed" .. i] = {
			description_text_id = "reload_speed_multiplier",
			tree = 3,
			image = "upgrades_mp5",
			image_slice = "upgrades_mp5_slice",
			title_id = "debug_mp5_short",
			category = "feature",
			icon = "mp5",
			step = self.steps.mp5.reload_speed_multiplier[i],
			name_id = "debug_upgrade_mp5_reload_speed" .. i,
			subtitle_id = "debug_upgrade_reload_speed" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "reload_speed_multiplier",
				category = "mp5",
				value = i
			}
		}
	end

	for i, _ in ipairs(self.values.mp5.enter_steelsight_speed_multiplier) do
		local depends_on = i - 1 > 0 and "mp5_enter_steelsight_speed" .. i - 1 or "mp5"
		local unlock_lvl = 10
		local prio = i == 1 and "high"
		self.definitions["mp5_enter_steelsight_speed" .. i] = {
			description_text_id = "enter_steelsight_speed_multiplier",
			tree = 3,
			image = "upgrades_mp5",
			image_slice = "upgrades_mp5_slice",
			title_id = "debug_mp5_short",
			category = "feature",
			icon = "mp5",
			step = self.steps.mp5.enter_steelsight_speed_multiplier[i],
			name_id = "debug_upgrade_mp5_enter_steelsight_speed" .. i,
			subtitle_id = "debug_upgrade_enter_steelsight_speed" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "enter_steelsight_speed_multiplier",
				category = "mp5",
				value = i
			}
		}
	end
end

function UpgradesTweakData:_mac11_definitions()
	self.definitions.mac11 = {
		description_text_id = "des_mac11",
		image_slice = "upgrades_mac10_slice",
		prio = "high",
		category = "weapon",
		tree = 1,
		image = "upgrades_mac10",
		weapon_id = "mac11",
		title_id = "debug_upgrade_new_weapon",
		subtitle_id = "debug_mac11_short",
		name_id = "debug_mac11",
		icon = "mac11",
		unlock_lvl = 81,
		step = 5,
		unit_name = Idstring("units/weapons/mac11/mac11")
	}

	for i, _ in ipairs(self.values.mac11.recoil_multiplier) do
		local depends_on = i - 1 > 0 and "mac11_recoil" .. i - 1 or "mac11"
		local unlock_lvl = 82
		local prio = i == 1 and "high"
		self.definitions["mac11_recoil" .. i] = {
			description_text_id = "recoil_multiplier",
			tree = 1,
			image = "upgrades_mac10",
			image_slice = "upgrades_mac10_slice",
			title_id = "debug_mac11_short",
			category = "feature",
			icon = "mac11",
			step = self.steps.mac11.recoil_multiplier[i],
			name_id = "debug_upgrade_mac11_recoil" .. i,
			subtitle_id = "debug_upgrade_recoil" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "recoil_multiplier",
				category = "mac11",
				value = i
			}
		}
	end

	for i, _ in ipairs(self.values.mac11.enter_steelsight_speed_multiplier) do
		local depends_on = i - 1 > 0 and "mac11_enter_steelsight_speed" .. i - 1 or "mac11"
		local unlock_lvl = 82
		local prio = i == 1 and "high"
		self.definitions["mac11_enter_steelsight_speed" .. i] = {
			description_text_id = "enter_steelsight_speed_multiplier",
			tree = 1,
			image = "upgrades_mac10",
			image_slice = "upgrades_mac10_slice",
			title_id = "debug_mac11_short",
			category = "feature",
			icon = "mac11",
			step = self.steps.mac11.enter_steelsight_speed_multiplier[i],
			name_id = "debug_upgrade_mac11_enter_steelsight_speed" .. i,
			subtitle_id = "debug_upgrade_enter_steelsight_speed" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "enter_steelsight_speed_multiplier",
				category = "mac11",
				value = i
			}
		}
	end

	for i, _ in ipairs(self.values.mac11.clip_ammo_increase) do
		local depends_on = i - 1 > 0 and "mac11_mag" .. i - 1 or "mac11"
		local unlock_lvl = 82
		local prio = i == 1 and "high"
		self.definitions["mac11_mag" .. i] = {
			description_text_id = "clip_ammo_increase",
			tree = 1,
			image = "upgrades_mac10",
			image_slice = "upgrades_mac10_slice",
			title_id = "debug_mac11_short",
			category = "feature",
			icon = "mac11",
			step = self.steps.mac11.clip_ammo_increase[i],
			name_id = "debug_upgrade_mac11_mag" .. i,
			subtitle_id = "debug_upgrade_mag" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "clip_ammo_increase",
				category = "mac11",
				value = i
			}
		}
	end
end

function UpgradesTweakData:_remington_definitions()
	self.definitions.r870_shotgun = {
		description_text_id = "des_r870_shotgun",
		image_slice = "upgrades_remington_slice",
		prio = "high",
		category = "weapon",
		tree = 3,
		image = "upgrades_remington",
		weapon_id = "r870_shotgun",
		title_id = "debug_upgrade_new_weapon",
		subtitle_id = "debug_r870_shotgun_short",
		name_id = "debug_r870_shotgun",
		icon = "r870_shotgun",
		unlock_lvl = 1,
		step = 13,
		unit_name = Idstring("units/weapons/r870_shotgun/r870_shotgun")
	}

	for i, _ in ipairs(self.values.r870_shotgun.clip_ammo_increase) do
		local depends_on = i - 1 > 0 and "remington_mag" .. i - 1 or "r870_shotgun"
		local unlock_lvl = 2
		local prio = i == 1 and "high"
		self.definitions["remington_mag" .. i] = {
			description_text_id = "clip_ammo_increase",
			tree = 3,
			image = "upgrades_remington",
			image_slice = "upgrades_remington_slice",
			title_id = "debug_r870_shotgun_short",
			category = "feature",
			icon = "r870_shotgun",
			step = self.steps.r870_shotgun.clip_ammo_increase[i],
			name_id = "debug_upgrade_remington_mag" .. i,
			subtitle_id = "debug_upgrade_mag" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "clip_ammo_increase",
				category = "r870_shotgun",
				value = i
			}
		}
	end

	for i, _ in ipairs(self.values.r870_shotgun.recoil_multiplier) do
		local depends_on = i - 1 > 0 and "remington_recoil" .. i - 1 or "r870_shotgun"
		local unlock_lvl = 3
		local prio = i == 1 and "high"
		self.definitions["remington_recoil" .. i] = {
			description_text_id = "recoil_multiplier",
			tree = 3,
			image = "upgrades_remington",
			image_slice = "upgrades_remington_slice",
			title_id = "debug_r870_shotgun_short",
			category = "feature",
			icon = "r870_shotgun",
			step = self.steps.r870_shotgun.recoil_multiplier[i],
			name_id = "debug_upgrade_remington_recoil" .. i,
			subtitle_id = "debug_upgrade_recoil" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "recoil_multiplier",
				category = "r870_shotgun",
				value = i
			}
		}
	end

	for i, _ in ipairs(self.values.r870_shotgun.damage_multiplier) do
		local depends_on = i - 1 > 0 and "remington_damage" .. i - 1 or "r870_shotgun"
		local unlock_lvl = 4
		local prio = i == 1 and "high"
		self.definitions["remington_damage" .. i] = {
			description_text_id = "damage_multiplier",
			tree = 3,
			image = "upgrades_remington",
			image_slice = "upgrades_remington_slice",
			title_id = "debug_r870_shotgun_short",
			category = "feature",
			icon = "r870_shotgun",
			step = self.steps.r870_shotgun.damage_multiplier[i],
			name_id = "debug_upgrade_remington_damage" .. i,
			subtitle_id = "debug_upgrade_damage" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "damage_multiplier",
				category = "r870_shotgun",
				value = i
			}
		}
	end
end

function UpgradesTweakData:_mossberg_definitions()
	self.definitions.mossberg = {
		description_text_id = "des_mossberg",
		image_slice = "upgrades_mossberg_slice",
		prio = "high",
		category = "weapon",
		tree = 2,
		image = "upgrades_mossberg",
		weapon_id = "mossberg",
		title_id = "debug_upgrade_new_weapon",
		subtitle_id = "debug_mossberg_short",
		name_id = "debug_mossberg",
		icon = "mossberg",
		unlock_lvl = 120,
		step = 7,
		unit_name = Idstring("units/weapons/mossberg/mossberg")
	}

	for i, _ in ipairs(self.values.mossberg.clip_ammo_increase) do
		local depends_on = i - 1 > 0 and "mossberg_mag" .. i - 1 or "mossberg"
		local unlock_lvl = 121
		local prio = i == 1 and "high"
		self.definitions["mossberg_mag" .. i] = {
			description_text_id = "clip_ammo_increase",
			tree = 2,
			image = "upgrades_mossberg",
			image_slice = "upgrades_mossberg_slice",
			title_id = "debug_mossberg_short",
			category = "feature",
			icon = "mossberg",
			step = self.steps.mossberg.clip_ammo_increase[i],
			name_id = "debug_upgrade_mossberg_mag" .. i,
			subtitle_id = "debug_upgrade_mag" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "clip_ammo_increase",
				category = "mossberg",
				value = i
			}
		}
	end

	for i, _ in ipairs(self.values.mossberg.reload_speed_multiplier) do
		local depends_on = i - 1 > 0 and "mossberg_reload_speed" .. i - 1 or "mossberg"
		local unlock_lvl = 121
		local prio = i == 1 and "high"
		self.definitions["mossberg_reload_speed" .. i] = {
			description_text_id = "reload_speed_multiplier",
			tree = 2,
			image = "upgrades_mossberg",
			image_slice = "upgrades_mossberg_slice",
			title_id = "debug_mossberg_short",
			category = "feature",
			icon = "mossberg",
			step = self.steps.mossberg.reload_speed_multiplier[i],
			name_id = "debug_upgrade_mossberg_reload_speed" .. i,
			subtitle_id = "debug_upgrade_reload_speed" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "reload_speed_multiplier",
				category = "mossberg",
				value = i
			}
		}
	end

	for i, _ in ipairs(self.values.mossberg.fire_rate_multiplier) do
		local depends_on = i - 1 > 0 and "mossberg_fire_rate_multiplier" .. i - 1 or "mossberg"
		local unlock_lvl = 121
		local prio = i == 1 and "high"
		self.definitions["mossberg_fire_rate_multiplier" .. i] = {
			description_text_id = "fire_rate_multiplier",
			tree = 2,
			image = "upgrades_mossberg",
			image_slice = "upgrades_mossberg_slice",
			title_id = "debug_mossberg_short",
			category = "feature",
			icon = "mossberg",
			step = self.steps.mossberg.fire_rate_multiplier[i],
			name_id = "debug_upgrade_mossberg_fire_rate" .. i,
			subtitle_id = "debug_upgrade_fire_rate" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "fire_rate_multiplier",
				category = "mossberg",
				value = i
			}
		}
	end

	for i, _ in ipairs(self.values.mossberg.recoil_multiplier) do
		local depends_on = i - 1 > 0 and "mossberg_recoil_multiplier" .. i - 1 or "mossberg"
		local unlock_lvl = 121
		local prio = i == 1 and "high"
		self.definitions["mossberg_recoil_multiplier" .. i] = {
			description_text_id = "recoil_multiplier",
			tree = 2,
			image = "upgrades_mossberg",
			image_slice = "upgrades_mossberg_slice",
			title_id = "debug_mossberg_short",
			category = "feature",
			icon = "mossberg",
			step = self.steps.mossberg.recoil_multiplier[i],
			name_id = "debug_upgrade_mossberg_recoil_multiplier" .. i,
			subtitle_id = "debug_upgrade_recoil" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "recoil_multiplier",
				category = "mossberg",
				value = i
			}
		}
	end
end

function UpgradesTweakData:_ak47_definitions()
	self.definitions.ak47 = {
		description_text_id = "des_ak47",
		image_slice = "upgrades_ak_slice",
		prio = "high",
		category = "weapon",
		tree = 4,
		image = "upgrades_ak",
		weapon_id = "ak47",
		title_id = "debug_upgrade_new_weapon",
		subtitle_id = "debug_ak47_short",
		name_id = "debug_ak47",
		icon = "ak",
		unlock_lvl = 0,
		step = 9,
		unit_name = Idstring("units/weapons/ak47/ak")
	}

	for i, _ in ipairs(self.values.ak47.damage_multiplier) do
		local depends_on = i - 1 > 0 and "ak47_damage" .. i - 1 or "ak47"
		local unlock_lvl = 141
		local prio = i == 1 and "high"
		self.definitions["ak47_damage" .. i] = {
			description_text_id = "damage_multiplier",
			tree = 4,
			image = "upgrades_ak",
			image_slice = "upgrades_ak_slice",
			title_id = "debug_ak47_short",
			category = "feature",
			icon = "ak",
			step = self.steps.ak47.damage_multiplier[i],
			name_id = "debug_upgrade_ak47_damage" .. i,
			subtitle_id = "debug_upgrade_damage" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "damage_multiplier",
				category = "ak47",
				value = i
			}
		}
	end

	for i, _ in ipairs(self.values.ak47.recoil_multiplier) do
		local depends_on = i - 1 > 0 and "ak47_recoil" .. i - 1 or "ak47"
		local unlock_lvl = 141
		local prio = i == 1 and "high"
		self.definitions["ak47_recoil" .. i] = {
			description_text_id = "recoil_multiplier",
			tree = 4,
			image = "upgrades_ak",
			image_slice = "upgrades_ak_slice",
			title_id = "debug_ak47_short",
			category = "feature",
			icon = "ak",
			step = self.steps.ak47.recoil_multiplier[i],
			name_id = "debug_upgrade_ak47_recoil" .. i,
			subtitle_id = "debug_upgrade_recoil" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "recoil_multiplier",
				category = "ak47",
				value = i
			}
		}
	end

	for i, _ in ipairs(self.values.ak47.spread_multiplier) do
		local depends_on = i - 1 > 0 and "ak47_spread" .. i - 1 or "ak47"
		local unlock_lvl = 141
		local prio = i == 1 and "high"
		self.definitions["ak47_spread" .. i] = {
			description_text_id = "spread_multiplier",
			tree = 4,
			image = "upgrades_ak",
			image_slice = "upgrades_ak_slice",
			title_id = "debug_ak47_short",
			category = "feature",
			icon = "ak",
			step = self.steps.ak47.spread_multiplier[i],
			name_id = "debug_upgrade_ak47_spread" .. i,
			subtitle_id = "debug_upgrade_spread" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "spread_multiplier",
				category = "ak47",
				value = i
			}
		}
	end

	for i, _ in ipairs(self.values.ak47.clip_ammo_increase) do
		local depends_on = i - 1 > 0 and "ak47_mag" .. i - 1 or "ak47"
		local unlock_lvl = 141
		local prio = i == 1 and "high"
		self.definitions["ak47_mag" .. i] = {
			description_text_id = "clip_ammo_increase",
			tree = 4,
			image = "upgrades_ak",
			image_slice = "upgrades_ak_slice",
			title_id = "debug_ak47_short",
			category = "feature",
			icon = "ak",
			step = self.steps.ak47.clip_ammo_increase[i],
			name_id = "debug_upgrade_ak47_mag" .. i,
			subtitle_id = "debug_upgrade_mag" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "clip_ammo_increase",
				category = "ak47",
				value = i
			}
		}
	end
end

function UpgradesTweakData:_glock_definitions()
	self.definitions.glock = {
		description_text_id = "des_glock",
		image_slice = "upgrades_glock_slice",
		prio = "high",
		category = "weapon",
		tree = 4,
		image = "upgrades_glock",
		weapon_id = "glock",
		title_id = "debug_upgrade_new_weapon",
		subtitle_id = "debug_glock_short",
		name_id = "debug_glock",
		icon = "glock",
		unlock_lvl = 0,
		step = 2,
		unit_name = Idstring("units/weapons/glock/glock")
	}

	for i, _ in ipairs(self.values.glock.damage_multiplier) do
		local depends_on = i - 1 > 0 and "glock_damage" .. i - 1 or "glock"
		local unlock_lvl = 141
		local prio = i == 1 and "high"
		self.definitions["glock_damage" .. i] = {
			description_text_id = "damage_multiplier",
			tree = 4,
			image = "upgrades_glock",
			image_slice = "upgrades_glock_slice",
			title_id = "debug_glock_short",
			category = "feature",
			icon = "glock",
			step = self.steps.glock.damage_multiplier[i],
			name_id = "debug_upgrade_glock_damage" .. i,
			subtitle_id = "debug_upgrade_damage" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "damage_multiplier",
				category = "glock",
				value = i
			}
		}
	end

	for i, _ in ipairs(self.values.glock.recoil_multiplier) do
		local depends_on = i - 1 > 0 and "glock_recoil" .. i - 1 or "glock"
		local unlock_lvl = 141
		local prio = i == 1 and "high"
		self.definitions["glock_recoil" .. i] = {
			description_text_id = "recoil_multiplier",
			tree = 4,
			image = "upgrades_glock",
			image_slice = "upgrades_glock_slice",
			title_id = "debug_glock_short",
			category = "feature",
			icon = "glock",
			step = self.steps.glock.recoil_multiplier[i],
			name_id = "debug_upgrade_glock_recoil" .. i,
			subtitle_id = "debug_upgrade_recoil" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "recoil_multiplier",
				category = "glock",
				value = i
			}
		}
	end

	for i, _ in ipairs(self.values.glock.clip_ammo_increase) do
		local depends_on = i - 1 > 0 and "glock_mag" .. i - 1 or "glock"
		local unlock_lvl = 141
		local prio = i == 1 and "high"
		self.definitions["glock_mag" .. i] = {
			description_text_id = "clip_ammo_increase",
			tree = 4,
			image = "upgrades_glock",
			image_slice = "upgrades_glock_slice",
			title_id = "debug_glock_short",
			category = "feature",
			icon = "glock",
			step = self.steps.glock.clip_ammo_increase[i],
			name_id = "debug_upgrade_glock_mag" .. i,
			subtitle_id = "debug_upgrade_mag" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "clip_ammo_increase",
				category = "glock",
				value = i
			}
		}
	end

	for i, _ in ipairs(self.values.glock.reload_speed_multiplier) do
		local depends_on = i - 1 > 0 and "glock_reload_speed" .. i - 1 or "glock"
		local unlock_lvl = 141
		local prio = i == 1 and "high"
		self.definitions["glock_reload_speed" .. i] = {
			description_text_id = "reload_speed_multiplier",
			tree = 4,
			image = "upgrades_glock",
			image_slice = "upgrades_glock_slice",
			title_id = "debug_glock_short",
			category = "feature",
			icon = "glock",
			step = self.steps.glock.reload_speed_multiplier[i],
			name_id = "debug_upgrade_glock_reload_speed" .. i,
			subtitle_id = "debug_upgrade_reload_speed" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "reload_speed_multiplier",
				category = "glock",
				value = i
			}
		}
	end
end

function UpgradesTweakData:_m79_definitions()
	self.definitions.m79 = {
		description_text_id = "des_m79",
		image_slice = "upgrades_grenade_slice",
		prio = "high",
		category = "weapon",
		tree = 4,
		image = "upgrades_grenade",
		weapon_id = "m79",
		title_id = "debug_upgrade_new_weapon",
		subtitle_id = "debug_m79_short",
		name_id = "debug_m79",
		icon = "m79",
		unlock_lvl = 0,
		step = 21,
		unit_name = Idstring("units/weapons/m79/m79")
	}

	for i, _ in ipairs(self.values.m79.damage_multiplier) do
		local depends_on = i - 1 > 0 and "m79_damage" .. i - 1 or "m79"
		local unlock_lvl = 141
		local prio = i == 1 and "high"
		self.definitions["m79_damage" .. i] = {
			description_text_id = "damage_multiplier",
			tree = 4,
			image = "upgrades_grenade",
			image_slice = "upgrades_grenade_slice",
			title_id = "debug_m79_short",
			category = "feature",
			icon = "m79",
			step = self.steps.m79.damage_multiplier[i],
			name_id = "debug_upgrade_m79_damage" .. i,
			subtitle_id = "debug_upgrade_damage" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "damage_multiplier",
				category = "m79",
				value = i
			}
		}
	end

	for i, _ in ipairs(self.values.m79.explosion_range_multiplier) do
		local depends_on = i - 1 > 0 and "m79_expl_range" .. i - 1 or "m79"
		local unlock_lvl = 141
		local prio = i == 1 and "high"
		self.definitions["m79_expl_range" .. i] = {
			description_text_id = "explosion_range_multiplier",
			tree = 4,
			image = "upgrades_grenade",
			image_slice = "upgrades_grenade_slice",
			title_id = "debug_m79_short",
			category = "feature",
			icon = "m79",
			step = self.steps.m79.explosion_range_multiplier[i],
			name_id = "debug_upgrade_m79_expl_range" .. i,
			subtitle_id = "debug_upgrade_expl_range" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "explosion_range_multiplier",
				category = "m79",
				value = i
			}
		}
	end

	for i, _ in ipairs(self.values.m79.clip_amount_increase) do
		local depends_on = i - 1 > 0 and "m79_clip_num" .. i - 1 or "m79"
		local unlock_lvl = 141
		local prio = i == 1 and "high"
		self.definitions["m79_clip_num" .. i] = {
			description_text_id = "clip_amount_increase",
			tree = 4,
			image = "upgrades_grenade",
			image_slice = "upgrades_grenade_slice",
			title_id = "debug_m79_short",
			category = "feature",
			icon = "m79",
			step = self.steps.m79.clip_amount_increase[i],
			name_id = "debug_upgrade_m79_clip_num" .. i,
			subtitle_id = "debug_upgrade_clip_num" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "clip_amount_increase",
				category = "m79",
				value = i
			}
		}
	end
end

function UpgradesTweakData:_akimbo_definitions()
	self.definitions.akimbo_damage_multiplier_1 = {
		name_id = "menu_akimbo_damage_multiplier",
		incremental = true,
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "damage_multiplier",
			category = "akimbo"
		}
	}
	self.definitions.akimbo_damage_multiplier_2 = {
		name_id = "menu_akimbo_damage_multiplier",
		incremental = true,
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "damage_multiplier",
			category = "akimbo"
		}
	}
	self.definitions.akimbo_extra_ammo_multiplier_1 = {
		incremental = true,
		name_id = "menu_akimbo_extra_ammo_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "extra_ammo_multiplier",
			category = "akimbo"
		}
	}
	self.definitions.akimbo_extra_ammo_multiplier_2 = {
		incremental = true,
		name_id = "menu_akimbo_extra_ammo_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "extra_ammo_multiplier",
			category = "akimbo"
		}
	}
	self.definitions.akimbo_recoil_multiplier_1 = {
		name_id = "menu_akimbo_recoil_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "recoil_multiplier",
			category = "akimbo"
		}
	}
	self.definitions.akimbo_recoil_multiplier_2 = {
		name_id = "menu_akimbo_recoil_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "recoil_multiplier",
			category = "akimbo"
		}
	}
	self.definitions.akimbo_recoil_multiplier_3 = {
		name_id = "menu_akimbo_recoil_multiplier",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "recoil_multiplier",
			category = "akimbo"
		}
	}
	self.definitions.akimbo_passive_recoil_multiplier_1 = {
		name_id = "menu_akimbo_passive_recoil_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_recoil_multiplier",
			category = "akimbo"
		}
	}
	self.definitions.akimbo_passive_recoil_multiplier_2 = {
		name_id = "menu_akimbo_passive_recoil_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "passive_recoil_multiplier",
			category = "akimbo"
		}
	}
	self.definitions.akimbo_passive_recoil_multiplier_3 = {
		name_id = "menu_akimbo_passive_recoil_multiplier",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "passive_recoil_multiplier",
			category = "akimbo"
		}
	}
	self.definitions.akimbo_spread_multiplier = {
		name_id = "menu_pistol_spread_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "spread_multiplier",
			category = "akimbo"
		}
	}
end

function UpgradesTweakData:_first_aid_kit_definitions()
	self.definitions.first_aid_kit = {
		name_id = "menu_equipment_first_aid_kit",
		slot = 1,
		equipment_id = "first_aid_kit",
		category = "equipment"
	}
	self.definitions.first_aid_kit_quantity_increase_1 = {
		incremental = true,
		name_id = "menu_first_aid_kit_quantity_1",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "quantity",
			category = "first_aid_kit"
		}
	}
	self.definitions.first_aid_kit_quantity_increase_2 = {
		incremental = true,
		name_id = "menu_first_aid_kit_quantity_2",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "quantity",
			category = "first_aid_kit"
		}
	}
	self.definitions.first_aid_kit_deploy_time_multiplier = {
		incremental = true,
		name_id = "menu_first_aid_kit_deploy_time_multiplier",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "deploy_time_multiplier",
			category = "first_aid_kit"
		}
	}
	self.definitions.first_aid_kit_damage_reduction_upgrade = {
		incremental = true,
		name_id = "menu_first_aid_kit_damage_reduction_upgrade",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "damage_reduction_upgrade",
			category = "first_aid_kit"
		}
	}
	self.definitions.first_aid_kit_downs_restore_chance = {
		incremental = true,
		name_id = "menu_first_aid_kit_downs_restore_chance",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "downs_restore_chance",
			category = "first_aid_kit"
		}
	}
	self.definitions.first_aid_kit_auto_recovery_1 = {
		name_id = "menu_first_aid_kit_downs_restore_chance",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "first_aid_kit_auto_recovery",
			category = "first_aid_kit"
		}
	}
end

function UpgradesTweakData:_bodybags_bag_definitions()
	self.definitions.bodybags_bag = {
		name_id = "menu_equipment_bodybags_bag",
		slot = 1,
		equipment_id = "bodybags_bag",
		category = "equipment"
	}
	self.definitions.bodybags_bag_quantity = {
		name_id = "menu_bodybags_bag_quantity",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "quantity",
			category = "bodybags_bag"
		}
	}
end

function UpgradesTweakData:_jowi_definitions()
	self.definitions.jowi = {
		factory_id = "wpn_fps_jowi",
		weapon_id = "jowi",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_1911_definitions()
	self.definitions.x_1911 = {
		factory_id = "wpn_fps_x_1911",
		weapon_id = "x_1911",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_b92fs_definitions()
	self.definitions.x_b92fs = {
		factory_id = "wpn_fps_x_b92fs",
		weapon_id = "x_b92fs",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_deagle_definitions()
	self.definitions.x_deagle = {
		factory_id = "wpn_fps_x_deagle",
		weapon_id = "x_deagle",
		category = "weapon"
	}
end

function UpgradesTweakData:_g26_definitions()
	self.definitions.g26 = {
		dlc = "pd2_clan",
		factory_id = "wpn_fps_pis_g26",
		weapon_id = "g26",
		category = "weapon"
	}
end

function UpgradesTweakData:_kabartanto_definitions()
	self.definitions.kabartanto = {
		dlc = "pd2_clan",
		category = "melee_weapon"
	}
end

function UpgradesTweakData:_toothbrush_definitions()
	self.definitions.toothbrush = {
		dlc = "pd2_clan",
		category = "melee_weapon"
	}
end

function UpgradesTweakData:_chef_definitions()
	self.definitions.chef = {
		dlc = "pd2_clan",
		category = "melee_weapon"
	}
end

function UpgradesTweakData:_x_g22c_definitions()
	self.definitions.x_g22c = {
		factory_id = "wpn_fps_pis_x_g22c",
		weapon_id = "x_g22c",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_g17_definitions()
	self.definitions.x_g17 = {
		factory_id = "wpn_fps_pis_x_g17",
		weapon_id = "x_g17",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_usp_definitions()
	self.definitions.x_usp = {
		factory_id = "wpn_fps_pis_x_usp",
		weapon_id = "x_usp",
		category = "weapon"
	}
end

function UpgradesTweakData:_flamethrower_mk2_definitions()
	self.definitions.flamethrower_mk2 = {
		dlc = "bbq",
		factory_id = "wpn_fps_fla_mk2",
		weapon_id = "flamethrower_mk2",
		category = "weapon"
	}
end

function UpgradesTweakData:_m32_definitions()
	self.definitions.m32 = {
		dlc = "bbq",
		factory_id = "wpn_fps_gre_m32",
		weapon_id = "m32",
		category = "weapon"
	}
end

function UpgradesTweakData:_aa12_definitions()
	self.definitions.aa12 = {
		dlc = "bbq",
		factory_id = "wpn_fps_sho_aa12",
		weapon_id = "aa12",
		category = "weapon"
	}
end

function UpgradesTweakData:_bbq_weapon_definitions()
	self.definitions.fork = {
		dlc = "bbq",
		category = "melee_weapon"
	}
	self.definitions.spatula = {
		dlc = "bbq",
		category = "melee_weapon"
	}
	self.definitions.poker = {
		dlc = "bbq",
		category = "melee_weapon"
	}
	self.definitions.tenderizer = {
		dlc = "bbq",
		category = "melee_weapon"
	}
	self.flame_bullet = {
		show_blood_hits = false
	}
end

function UpgradesTweakData:_peacemaker_definitions()
	self.definitions.peacemaker = {
		dlc = "west",
		factory_id = "wpn_fps_pis_peacemaker",
		weapon_id = "peacemaker",
		category = "weapon"
	}
end

function UpgradesTweakData:_winchester1874_definitions()
	self.definitions.winchester1874 = {
		dlc = "west",
		factory_id = "wpn_fps_snp_winchester",
		weapon_id = "winchester1874",
		category = "weapon"
	}
end

function UpgradesTweakData:_plainsrider_definitions()
	self.definitions.plainsrider = {
		dlc = "west",
		factory_id = "wpn_fps_bow_plainsrider",
		weapon_id = "plainsrider",
		category = "weapon"
	}
end

function UpgradesTweakData:_mateba_definitions()
	self.definitions.mateba = {
		dlc = "arena",
		factory_id = "wpn_fps_pis_2006m",
		weapon_id = "mateba",
		category = "weapon"
	}
end

function UpgradesTweakData:_asval_definitions()
	self.definitions.asval = {
		dlc = "character_pack_sokol",
		factory_id = "wpn_fps_ass_asval",
		weapon_id = "asval",
		category = "weapon"
	}
end

function UpgradesTweakData:_sub2000_definitions()
	self.definitions.sub2000 = {
		dlc = "kenaz",
		factory_id = "wpn_fps_ass_sub2000",
		weapon_id = "sub2000",
		category = "weapon"
	}
end

function UpgradesTweakData:_wa2000_definitions()
	self.definitions.wa2000 = {
		dlc = "turtles",
		factory_id = "wpn_fps_snp_wa2000",
		weapon_id = "wa2000",
		category = "weapon"
	}
end

function UpgradesTweakData:_polymer_definitions()
	self.definitions.polymer = {
		dlc = "turtles",
		factory_id = "wpn_fps_smg_polymer",
		weapon_id = "polymer",
		category = "weapon"
	}
end

function UpgradesTweakData:_hunter_definitions()
	self.definitions.hunter = {
		dlc = "turtles",
		factory_id = "wpn_fps_bow_hunter",
		weapon_id = "hunter",
		category = "weapon"
	}
end

function UpgradesTweakData:_baka_definitions()
	self.definitions.baka = {
		dlc = "dragon",
		factory_id = "wpn_fps_smg_baka",
		weapon_id = "baka",
		category = "weapon"
	}
end

function UpgradesTweakData:_arblast_weapon_definitions()
	self.definitions.arblast = {
		dlc = "steel",
		factory_id = "wpn_fps_bow_arblast",
		weapon_id = "arblast",
		category = "weapon"
	}
end

function UpgradesTweakData:_frankish_weapon_definitions()
	self.definitions.frankish = {
		dlc = "steel",
		factory_id = "wpn_fps_bow_frankish",
		weapon_id = "frankish",
		category = "weapon"
	}
end

function UpgradesTweakData:_long_weapon_definitions()
	self.definitions.long = {
		dlc = "steel",
		factory_id = "wpn_fps_bow_long",
		weapon_id = "long",
		category = "weapon"
	}
end

function UpgradesTweakData:_par_weapon_definitions()
	self.definitions.par = {
		factory_id = "wpn_fps_lmg_par",
		weapon_id = "par",
		category = "weapon"
	}
end

function UpgradesTweakData:_sparrow_weapon_definitions()
	self.definitions.sparrow = {
		dlc = "berry",
		factory_id = "wpn_fps_pis_sparrow",
		weapon_id = "sparrow",
		category = "weapon"
	}
end

function UpgradesTweakData:_model70_weapon_definitions()
	self.definitions.model70 = {
		factory_id = "wpn_fps_snp_model70",
		weapon_id = "model70",
		category = "weapon"
	}
end

function UpgradesTweakData:_m37_weapon_definitions()
	self.definitions.m37 = {
		dlc = "peta",
		factory_id = "wpn_fps_shot_m37",
		weapon_id = "m37",
		category = "weapon"
	}
end

function UpgradesTweakData:_china_weapon_definitions()
	self.definitions.china = {
		dlc = "pal",
		factory_id = "wpn_fps_gre_china",
		weapon_id = "china",
		category = "weapon"
	}
end

function UpgradesTweakData:_sr2_weapon_definitions()
	self.definitions.sr2 = {
		factory_id = "wpn_fps_smg_sr2",
		weapon_id = "sr2",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_sr2_weapon_definitions()
	self.definitions.x_sr2 = {
		factory_id = "wpn_fps_smg_x_sr2",
		weapon_id = "x_sr2",
		category = "weapon"
	}
end

function UpgradesTweakData:_pl14_weapon_definitions()
	self.definitions.pl14 = {
		factory_id = "wpn_fps_pis_pl14",
		weapon_id = "pl14",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_mp5_weapon_definitions()
	self.definitions.x_mp5 = {
		factory_id = "wpn_fps_smg_x_mp5",
		weapon_id = "x_mp5",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_akmsu_weapon_definitions()
	self.definitions.x_akmsu = {
		factory_id = "wpn_fps_smg_x_akmsu",
		weapon_id = "x_akmsu",
		category = "weapon"
	}
end

function UpgradesTweakData:_tecci_weapon_definitions()
	self.definitions.tecci = {
		dlc = "opera",
		factory_id = "wpn_fps_ass_tecci",
		weapon_id = "tecci",
		category = "weapon"
	}
end

function UpgradesTweakData:_hajk_weapon_definitions()
	self.definitions.hajk = {
		dlc = "born",
		factory_id = "wpn_fps_smg_hajk",
		weapon_id = "hajk",
		category = "weapon"
	}
end

function UpgradesTweakData:_boot_weapon_definitions()
	self.definitions.boot = {
		dlc = "wild",
		factory_id = "wpn_fps_sho_boot",
		weapon_id = "boot",
		category = "weapon"
	}
end

function UpgradesTweakData:_packrat_weapon_definitions()
	self.definitions.packrat = {
		dlc = "pim",
		factory_id = "wpn_fps_pis_packrat",
		weapon_id = "packrat",
		category = "weapon"
	}
end

function UpgradesTweakData:_schakal_weapon_definitions()
	self.definitions.schakal = {
		dlc = "pim",
		factory_id = "wpn_fps_smg_schakal",
		weapon_id = "schakal",
		category = "weapon"
	}
end

function UpgradesTweakData:_desertfox_weapon_definitions()
	self.definitions.desertfox = {
		dlc = "pim",
		factory_id = "wpn_fps_snp_desertfox",
		weapon_id = "desertfox",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_packrat_weapon_definitions()
	self.definitions.x_packrat = {
		dlc = "pim",
		factory_id = "wpn_fps_x_packrat",
		weapon_id = "x_packrat",
		category = "weapon"
	}
end

function UpgradesTweakData:_rota_weapon_definitions()
	self.definitions.rota = {
		dlc = "rota",
		factory_id = "wpn_fps_sho_rota",
		weapon_id = "rota",
		category = "weapon"
	}
end

function UpgradesTweakData:_arbiter_weapon_definitions()
	self.definitions.arbiter = {
		dlc = "tango",
		factory_id = "wpn_fps_gre_arbiter",
		weapon_id = "arbiter",
		category = "weapon"
	}
end

function UpgradesTweakData:_contraband_weapon_definitions()
	self.definitions.contraband = {
		dlc = "chico",
		factory_id = "wpn_fps_ass_contraband",
		weapon_id = "contraband",
		category = "weapon"
	}
	self.definitions.contraband_m203 = {
		dlc = "chico",
		factory_id = "wpn_fps_ass_contraband_gl_m203",
		weapon_id = "contraband_m203",
		category = "weapon"
	}
end

function UpgradesTweakData:_ray_weapon_definitions()
	self.definitions.ray = {
		dlc = "friend",
		factory_id = "wpn_fps_gre_ray",
		weapon_id = "ray",
		category = "weapon"
	}
end

function UpgradesTweakData:_tti_weapon_definitions()
	self.definitions.tti = {
		dlc = "spa",
		factory_id = "wpn_fps_snp_tti",
		weapon_id = "tti",
		category = "weapon"
	}
end

function UpgradesTweakData:_siltstone_weapon_definitions()
	self.definitions.siltstone = {
		dlc = "grv",
		factory_id = "wpn_fps_snp_siltstone",
		weapon_id = "siltstone",
		category = "weapon"
	}
end

function UpgradesTweakData:_flint_weapon_definitions()
	self.definitions.flint = {
		dlc = "grv",
		factory_id = "wpn_fps_ass_flint",
		weapon_id = "flint",
		category = "weapon"
	}
end

function UpgradesTweakData:_coal_weapon_definitions()
	self.definitions.coal = {
		dlc = "grv",
		factory_id = "wpn_fps_smg_coal",
		weapon_id = "coal",
		category = "weapon"
	}
end

function UpgradesTweakData:_lemming_weapon_definitions()
	self.definitions.lemming = {
		dlc = "pd2_clan",
		factory_id = "wpn_fps_pis_lemming",
		weapon_id = "lemming",
		category = "weapon"
	}
end

function UpgradesTweakData:_chinchilla_weapon_definitions()
	self.definitions.chinchilla = {
		dlc = "max",
		factory_id = "wpn_fps_pis_chinchilla",
		weapon_id = "chinchilla",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_chinchilla_weapon_definitions()
	self.definitions.x_chinchilla = {
		dlc = "max",
		factory_id = "wpn_fps_pis_x_chinchilla",
		weapon_id = "x_chinchilla",
		category = "weapon"
	}
end

function UpgradesTweakData:_shepheard_weapon_definitions()
	self.definitions.shepheard = {
		factory_id = "wpn_fps_smg_shepheard",
		weapon_id = "shepheard",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_shepheard_weapon_definitions()
	self.definitions.x_shepheard = {
		factory_id = "wpn_fps_smg_x_shepheard",
		weapon_id = "x_shepheard",
		category = "weapon"
	}
end

function UpgradesTweakData:_breech_weapon_definitions()
	self.definitions.breech = {
		factory_id = "wpn_fps_pis_breech",
		weapon_id = "breech",
		category = "weapon"
	}
end

function UpgradesTweakData:_ching_weapon_definitions()
	self.definitions.ching = {
		factory_id = "wpn_fps_ass_ching",
		weapon_id = "ching",
		category = "weapon"
	}
end

function UpgradesTweakData:_erma_weapon_definitions()
	self.definitions.erma = {
		factory_id = "wpn_fps_smg_erma",
		weapon_id = "erma",
		category = "weapon"
	}
end

function UpgradesTweakData:_ecp_weapon_definitions()
	self.definitions.ecp = {
		dlc = "ecp",
		factory_id = "wpn_fps_bow_ecp",
		weapon_id = "ecp",
		category = "weapon"
	}
end

function UpgradesTweakData:_shrew_weapon_definitions()
	self.definitions.shrew = {
		factory_id = "wpn_fps_pis_shrew",
		weapon_id = "shrew",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_shrew_weapon_definitions()
	self.definitions.x_shrew = {
		factory_id = "wpn_fps_pis_x_shrew",
		weapon_id = "x_shrew",
		category = "weapon"
	}
end

function UpgradesTweakData:_basset_weapon_definitions()
	self.definitions.basset = {
		factory_id = "wpn_fps_sho_basset",
		weapon_id = "basset",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_basset_weapon_definitions()
	self.definitions.x_basset = {
		factory_id = "wpn_fps_sho_x_basset",
		weapon_id = "x_basset",
		category = "weapon"
	}
end

function UpgradesTweakData:_corgi_weapon_definitions()
	self.definitions.corgi = {
		factory_id = "wpn_fps_ass_corgi",
		weapon_id = "corgi",
		category = "weapon"
	}
end

function UpgradesTweakData:_slap_weapon_definitions()
	self.definitions.slap = {
		factory_id = "wpn_fps_gre_slap",
		weapon_id = "slap",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_coal_weapon_definitions()
	self.definitions.x_coal = {
		factory_id = "wpn_fps_smg_x_coal",
		weapon_id = "x_coal",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_baka_weapon_definitions()
	self.definitions.x_baka = {
		factory_id = "wpn_fps_smg_x_baka",
		weapon_id = "x_baka",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_cobray_weapon_definitions()
	self.definitions.x_cobray = {
		factory_id = "wpn_fps_smg_x_cobray",
		weapon_id = "x_cobray",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_erma_weapon_definitions()
	self.definitions.x_erma = {
		factory_id = "wpn_fps_smg_x_erma",
		weapon_id = "x_erma",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_hajk_weapon_definitions()
	self.definitions.x_hajk = {
		factory_id = "wpn_fps_smg_x_hajk",
		weapon_id = "x_hajk",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_m45_weapon_definitions()
	self.definitions.x_m45 = {
		factory_id = "wpn_fps_smg_x_m45",
		weapon_id = "x_m45",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_m1928_weapon_definitions()
	self.definitions.x_m1928 = {
		factory_id = "wpn_fps_smg_x_m1928",
		weapon_id = "x_m1928",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_mac10_weapon_definitions()
	self.definitions.x_mac10 = {
		factory_id = "wpn_fps_smg_x_mac10",
		weapon_id = "x_mac10",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_mp7_weapon_definitions()
	self.definitions.x_mp7 = {
		factory_id = "wpn_fps_smg_x_mp7",
		weapon_id = "x_mp7",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_mp9_weapon_definitions()
	self.definitions.x_mp9 = {
		factory_id = "wpn_fps_smg_x_mp9",
		weapon_id = "x_mp9",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_olympic_weapon_definitions()
	self.definitions.x_olympic = {
		factory_id = "wpn_fps_smg_x_olympic",
		weapon_id = "x_olympic",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_p90_weapon_definitions()
	self.definitions.x_p90 = {
		factory_id = "wpn_fps_smg_x_p90",
		weapon_id = "x_p90",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_polymer_weapon_definitions()
	self.definitions.x_polymer = {
		factory_id = "wpn_fps_smg_x_polymer",
		weapon_id = "x_polymer",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_schakal_weapon_definitions()
	self.definitions.x_schakal = {
		factory_id = "wpn_fps_smg_x_schakal",
		weapon_id = "x_schakal",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_scorpion_weapon_definitions()
	self.definitions.x_scorpion = {
		factory_id = "wpn_fps_smg_x_scorpion",
		weapon_id = "x_scorpion",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_sterling_weapon_definitions()
	self.definitions.x_sterling = {
		factory_id = "wpn_fps_smg_x_sterling",
		weapon_id = "x_sterling",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_tec9_weapon_definitions()
	self.definitions.x_tec9 = {
		factory_id = "wpn_fps_smg_x_tec9",
		weapon_id = "x_tec9",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_uzi_weapon_definitions()
	self.definitions.x_uzi = {
		factory_id = "wpn_fps_smg_x_uzi",
		weapon_id = "x_uzi",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_2006m_weapon_definitions()
	self.definitions.x_2006m = {
		factory_id = "wpn_fps_pis_x_2006m",
		weapon_id = "x_2006m",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_breech_weapon_definitions()
	self.definitions.x_breech = {
		factory_id = "wpn_fps_pis_x_breech",
		weapon_id = "x_breech",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_c96_weapon_definitions()
	self.definitions.x_c96 = {
		factory_id = "wpn_fps_pis_x_c96",
		weapon_id = "x_c96",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_g18c_weapon_definitions()
	self.definitions.x_g18c = {
		factory_id = "wpn_fps_pis_x_g18c",
		weapon_id = "x_g18c",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_hs2000_weapon_definitions()
	self.definitions.x_hs2000 = {
		factory_id = "wpn_fps_pis_x_hs2000",
		weapon_id = "x_hs2000",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_lemming_weapon_definitions()
	self.definitions.x_lemming = {
		factory_id = "wpn_fps_pis_x_lemming",
		weapon_id = "x_lemming",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_p226_weapon_definitions()
	self.definitions.x_p226 = {
		factory_id = "wpn_fps_pis_x_p226",
		weapon_id = "x_p226",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_peacemaker_weapon_definitions()
	self.definitions.x_peacemaker = {
		factory_id = "wpn_fps_pis_x_peacemaker",
		weapon_id = "x_peacemaker",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_pl14_weapon_definitions()
	self.definitions.x_pl14 = {
		factory_id = "wpn_fps_pis_x_pl14",
		weapon_id = "x_pl14",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_ppk_weapon_definitions()
	self.definitions.x_ppk = {
		factory_id = "wpn_fps_pis_x_ppk",
		weapon_id = "x_ppk",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_rage_weapon_definitions()
	self.definitions.x_rage = {
		factory_id = "wpn_fps_pis_x_rage",
		weapon_id = "x_rage",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_sparrow_weapon_definitions()
	self.definitions.x_sparrow = {
		factory_id = "wpn_fps_pis_x_sparrow",
		weapon_id = "x_sparrow",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_judge_weapon_definitions()
	self.definitions.x_judge = {
		factory_id = "wpn_fps_pis_x_judge",
		weapon_id = "x_judge",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_rota_weapon_definitions()
	self.definitions.x_rota = {
		factory_id = "wpn_fps_sho_x_rota",
		weapon_id = "x_rota",
		category = "weapon"
	}
end

function UpgradesTweakData:_shuno_weapon_definitions()
	self.definitions.shuno = {
		dlc = "dmg",
		factory_id = "wpn_fps_lmg_shuno",
		weapon_id = "shuno",
		category = "weapon"
	}
end

function UpgradesTweakData:_system_weapon_definitions()
	self.definitions.system = {
		factory_id = "wpn_fps_fla_system",
		weapon_id = "system",
		category = "weapon"
	}
end

function UpgradesTweakData:_komodo_weapon_definitions()
	self.definitions.komodo = {
		factory_id = "wpn_fps_ass_komodo",
		weapon_id = "komodo",
		category = "weapon"
	}
end

function UpgradesTweakData:_elastic_weapon_definitions()
	self.definitions.elastic = {
		factory_id = "wpn_fps_bow_elastic",
		weapon_id = "elastic",
		category = "weapon"
	}
end

function UpgradesTweakData:_legacy_weapon_definitions()
	self.definitions.legacy = {
		factory_id = "wpn_fps_pis_legacy",
		weapon_id = "legacy",
		category = "weapon"
	}
end

function UpgradesTweakData:_x_legacy_weapon_definitions()
	self.definitions.x_legacy = {
		factory_id = "wpn_fps_pis_x_legacy",
		weapon_id = "x_legacy",
		category = "weapon"
	}
end

function UpgradesTweakData:_coach_weapon_definitions()
	self.definitions.coach = {
		factory_id = "wpn_fps_sho_coach",
		weapon_id = "coach",
		category = "weapon"
	}
end
