CarryTweakData = CarryTweakData or class()

function CarryTweakData:init(tweak_data)
	self.value_multiplier = tweak_data.money_manager.bag_value_multiplier
	self.dye = {
		chance = 0.5,
		value_multiplier = 60
	}
	self.types = {being = {}}
	self.types.being.move_speed_modifier = 0.5
	self.types.being.jump_modifier = 0.5
	self.types.being.can_run = false
	self.types.being.throw_distance_multiplier = 0.5
	self.types.mega_heavy = {
		move_speed_modifier = 0.25,
		jump_modifier = 0.25,
		can_run = false,
		throw_distance_multiplier = 0.125
	}
	self.types.very_heavy = {
		move_speed_modifier = 0.25,
		jump_modifier = 0.25,
		can_run = false,
		throw_distance_multiplier = 0.3
	}
	self.types.slightly_very_heavy = deep_clone(self.types.very_heavy)
	self.types.slightly_very_heavy.throw_distance_multiplier = 0.65
	self.types.slightly_very_heavy.move_speed_modifier = 0.5
	self.types.heavy = {
		move_speed_modifier = 0.5,
		jump_modifier = 0.5,
		can_run = false,
		throw_distance_multiplier = 0.5
	}
	self.types.slightly_heavy = {
		move_speed_modifier = 0.6,
		jump_modifier = 1,
		can_run = false,
		throw_distance_multiplier = 0.8
	}
	self.types.medium = {
		move_speed_modifier = 0.75,
		jump_modifier = 1,
		can_run = false,
		throw_distance_multiplier = 1
	}
	self.types.light = {
		move_speed_modifier = 1,
		jump_modifier = 1,
		can_run = true,
		throw_distance_multiplier = 1
	}
	self.types.coke_light = {
		move_speed_modifier = 1,
		jump_modifier = 1,
		can_run = true,
		throw_distance_multiplier = 1
	}
	self.types.explosives = deep_clone(self.types.medium)
	self.types.explosives.can_explode = true
	self.types.cloaker_explosives = deep_clone(self.types.medium)
	self.types.cloaker_explosives.can_poof = true
	self.small_loot = {
		money_bundle = tweak_data:get_value("money_manager", "small_loot", "money_bundle"),
		money_bundle_value = tweak_data:get_value("money_manager", "small_loot", "money_bundle_value"),
		ring_band = tweak_data:get_value("money_manager", "small_loot", "ring_band"),
		diamondheist_vault_bust = tweak_data:get_value("money_manager", "small_loot", "diamondheist_vault_bust"),
		diamondheist_vault_diamond = tweak_data:get_value("money_manager", "small_loot", "diamondheist_vault_diamond"),
		diamondheist_big_diamond = tweak_data:get_value("money_manager", "small_loot", "diamondheist_big_diamond"),
		mus_small_artifact = tweak_data:get_value("money_manager", "small_loot", "mus_small_artifact"),
		value_gold = tweak_data:get_value("money_manager", "small_loot", "value_gold"),
		gen_atm = tweak_data:get_value("money_manager", "small_loot", "gen_atm"),
		special_deposit_box = tweak_data:get_value("money_manager", "small_loot", "special_deposit_box"),
		slot_machine_payout = tweak_data:get_value("money_manager", "small_loot", "slot_machine_payout"),
		vault_loot_chest = tweak_data:get_value("money_manager", "small_loot", "vault_loot_chest"),
		vault_loot_diamond_chest = tweak_data:get_value("money_manager", "small_loot", "vault_loot_diamond_chest"),
		vault_loot_banknotes = tweak_data:get_value("money_manager", "small_loot", "vault_loot_banknotes"),
		vault_loot_silver = tweak_data:get_value("money_manager", "small_loot", "vault_loot_silver"),
		vault_loot_diamond_collection = tweak_data:get_value("money_manager", "small_loot", "vault_loot_diamond_collection"),
		vault_loot_trophy = tweak_data:get_value("money_manager", "small_loot", "vault_loot_trophy"),
		money_wrap_single_bundle_vscaled = tweak_data:get_value("money_manager", "small_loot", "money_wrap_single_bundle_vscaled"),
		spawn_bucket_of_money = tweak_data:get_value("money_manager", "small_loot", "spawn_bucket_of_money"),
		vault_loot_gold = tweak_data:get_value("money_manager", "small_loot", "vault_loot_gold"),
		vault_loot_cash = tweak_data:get_value("money_manager", "small_loot", "vault_loot_cash"),
		vault_loot_coins = tweak_data:get_value("money_manager", "small_loot", "vault_loot_coins"),
		vault_loot_ring = tweak_data:get_value("money_manager", "small_loot", "vault_loot_ring"),
		vault_loot_jewels = tweak_data:get_value("money_manager", "small_loot", "vault_loot_jewels"),
		vault_loot_macka = tweak_data:get_value("money_manager", "small_loot", "vault_loot_macka")
	}
	self.gold = {
		type = "heavy",
		name_id = "hud_carry_gold",
		bag_value = "gold",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.money = {
		type = "medium",
		name_id = "hud_carry_money",
		bag_value = "money",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		dye = true,
		AI_carry = {SO_category = "enemies"}
	}
	self.diamonds = {
		type = "light",
		name_id = "hud_carry_diamonds",
		bag_value = "diamonds",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.painting = {
		type = "light",
		name_id = "hud_carry_painting",
		bag_value = "painting",
		unit = "units/payday2/pickups/gen_pku_canvasbag/gen_pku_canvasbag",
		visual_unit_name = "units/payday2/characters/npc_acc_canvas_bag_1/npc_acc_canvas_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.coke = {
		type = "coke_light",
		name_id = "hud_carry_coke",
		bag_value = "coke",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.meth = {
		type = "coke_light",
		name_id = "hud_carry_meth",
		bag_value = "meth",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.lance_bag = {
		type = "medium",
		name_id = "hud_carry_lance_bag",
		skip_exit_secure = true,
		unit = "units/payday2/pickups/gen_pku_toolbag/gen_pku_toolbag",
		visual_unit_name = "units/payday2/characters/npc_acc_tools_bag_1/npc_acc_tools_bag_1"
	}
	self.lance_bag_large = {
		type = "heavy",
		name_id = "hud_carry_huge_bag",
		skip_exit_secure = true,
		unit = "units/payday2/pickups/gen_pku_toolbag_large/gen_pku_toolbag_large",
		visual_unit_name = "units/payday2/characters/npc_acc_tools_bag_large_1/npc_acc_tools_bag_large_1"
	}
	self.cage_bag = {
		type = "medium",
		name_id = "hud_carry_cage_bag",
		skip_exit_secure = true,
		unit = "units/payday2/pickups/gen_pku_cage_bag/gen_pku_cage_bag",
		visual_unit_name = "units/payday2/characters/npc_acc_cage_bag_1/npc_acc_cage_bag_1"
	}
	self.weapon = {
		type = "heavy",
		name_id = "hud_carry_weapon",
		bag_value = "weapons",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1"
	}
	self.weapons = {
		type = "heavy",
		bag_value = "weapons",
		name_id = "hud_carry_weapons",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1"
	}
	self.grenades = {
		type = "explosives",
		name_id = "hud_carry_grenades",
		bag_value = "weapons",
		unit = "units/pd2_dlc1/pickups/gen_pku_explosivesbag/gen_pku_explosivesbag",
		visual_unit_name = "units/payday2/characters/npc_acc_explosives_bag_1/npc_acc_explosives_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.person = {
		type = "being",
		name_id = "hud_carry_person",
		unit = "units/payday2/pickups/gen_pku_bodybag/gen_pku_bodybag",
		visual_unit_name = "units/payday2/characters/npc_acc_body_bag_1/npc_acc_body_bag_1",
		default_value = 1,
		is_unique_loot = true,
		skip_exit_secure = true
	}
	self.special_person = {
		type = "being",
		name_id = "hud_carry_special_person",
		unit = "units/payday2/pickups/gen_pku_bodybag/gen_pku_bodybag",
		visual_unit_name = "units/payday2/characters/npc_acc_body_bag_1/npc_acc_body_bag_1",
		default_value = 1,
		is_unique_loot = true,
		skip_exit_secure = true
	}
	self.circuit = {
		type = "heavy",
		name_id = "hud_carry_circuit",
		bag_value = "circuit",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1"
	}
	self.engine_01 = {
		type = "heavy",
		name_id = "hud_carry_engine_1",
		skip_exit_secure = true,
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.engine_02 = {
		type = "heavy",
		name_id = "hud_carry_engine_2",
		skip_exit_secure = true,
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.engine_03 = {
		type = "heavy",
		name_id = "hud_carry_engine_3",
		skip_exit_secure = true,
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.engine_04 = {
		type = "heavy",
		name_id = "hud_carry_engine_4",
		skip_exit_secure = true,
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.engine_05 = {
		type = "heavy",
		name_id = "hud_carry_engine_5",
		skip_exit_secure = true,
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.engine_06 = {
		type = "heavy",
		name_id = "hud_carry_engine_6",
		skip_exit_secure = true,
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.engine_07 = {
		type = "heavy",
		name_id = "hud_carry_engine_7",
		skip_exit_secure = true,
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.engine_08 = {
		type = "heavy",
		name_id = "hud_carry_engine_8",
		skip_exit_secure = true,
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.engine_09 = {
		type = "heavy",
		name_id = "hud_carry_engine_9",
		skip_exit_secure = true,
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.engine_10 = {
		type = "heavy",
		name_id = "hud_carry_engine_10",
		skip_exit_secure = true,
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.engine_11 = {
		type = "heavy",
		name_id = "hud_carry_engine_11",
		skip_exit_secure = true,
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.engine_12 = {
		type = "heavy",
		name_id = "hud_carry_engine_12",
		skip_exit_secure = true,
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.turret = {
		type = "heavy",
		name_id = "hud_carry_turret",
		bag_value = "turret",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.ammo = {
		type = "medium",
		name_id = "hud_carry_ammo",
		bag_value = "shells",
		unit = "units/pd2_dlc1/pickups/gen_pku_explosivesbag/gen_pku_explosivesbag",
		visual_unit_name = "units/payday2/characters/npc_acc_explosives_bag_1/npc_acc_explosives_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.artifact_statue = {
		type = "very_heavy",
		name_id = "hud_carry_artifact",
		bag_value = "artifact_statue",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.mus_artifact = {
		type = "medium",
		name_id = "hud_carry_artifact",
		bag_value = "mus_artifact_bag",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.mus_artifact_paint = {
		type = "light",
		name_id = "hud_carry_artifact",
		bag_value = "mus_artifact_bag",
		unit = "units/payday2/pickups/gen_pku_canvasbag/gen_pku_canvasbag",
		visual_unit_name = "units/payday2/characters/npc_acc_canvas_bag_1/npc_acc_canvas_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.samurai_suit = {
		type = "medium",
		name_id = "hud_carry_samurai",
		bag_value = "samurai_suit",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.equipment_bag = {
		type = "medium",
		name_id = "hud_carry_equipment_bag",
		skip_exit_secure = true,
		unit = "units/payday2/pickups/gen_pku_toolbag/gen_pku_toolbag",
		visual_unit_name = "units/payday2/characters/npc_acc_tools_bag_1/npc_acc_tools_bag_1"
	}
	self.coke_pure = {
		type = "coke_light",
		name_id = "hud_carry_coke_pure",
		bag_value = "coke_pure",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.evidence_bag = {
		type = "light",
		name_id = "hud_carry_evidence_bag",
		bag_value = "evidence_bag",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.sandwich = {
		type = "very_heavy",
		name_id = "hud_carry_sandwich",
		bag_value = "sandwich",
		AI_carry = {SO_category = "enemies"},
		unit = "units/payday2/pickups/gen_pku_cage_bag/gen_pku_cage_bag",
		visual_unit_name = "units/payday2/characters/npc_acc_cage_bag_1/npc_acc_cage_bag_1"
	}
	self.hope_diamond = {
		type = "coke_light",
		name_id = "hud_carry_hope_diamond",
		bag_value = "hope_diamond",
		AI_carry = {SO_category = "enemies"},
		unit = "units/payday2/pickups/gen_pku_cage_bag/gen_pku_cage_bag",
		visual_unit_name = "units/payday2/characters/npc_acc_cage_bag_1/npc_acc_cage_bag_1"
	}
	self.cro_loot1 = {
		type = "medium",
		name_id = "hud_carry_cro_loot",
		bag_value = "cro_loot",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.cro_loot2 = {
		type = "heavy",
		name_id = "hud_carry_cro_loot",
		bag_value = "cro_loot",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.ladder_bag = {
		type = "light",
		name_id = "hud_carry_ladder_bag",
		skip_exit_secure = true,
		unit = "units/payday2/pickups/gen_pku_cage_bag/gen_pku_cage_bag",
		visual_unit_name = "units/payday2/characters/npc_acc_cage_bag_1/npc_acc_cage_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.vehicle_falcogini = {
		type = "light",
		name_id = "hud_carry_vehicle_falcogini",
		skip_exit_secure = false,
		is_vehicle = true,
		visual_object = "",
		unit = "",
		bag_value = "vehicle_falcogini",
		AI_carry = {SO_category = ""}
	}
	self.warhead = {
		type = "very_heavy",
		name_id = "hud_carry_warhead",
		bag_value = "warhead",
		unit = "units/pd2_dlc1/pickups/gen_pku_explosivesbag/gen_pku_explosivesbag",
		visual_unit_name = "units/payday2/characters/npc_acc_explosives_bag_1/npc_acc_explosives_bag_1"
	}
	self.winch_part = {
		type = "heavy",
		name_id = "hud_carry_winch_bag",
		skip_exit_secure = true,
		unit = "units/payday2/pickups/gen_pku_toolbag_large/gen_pku_toolbag_large",
		visual_unit_name = "units/payday2/characters/npc_acc_tools_bag_large_1/npc_acc_tools_bag_large_1"
	}
	self.winch_part_2 = {
		type = "heavy",
		name_id = "hud_carry_winch_bag",
		skip_exit_secure = true,
		unit = "units/payday2/pickups/gen_pku_toolbag_large/gen_pku_toolbag_large_2",
		visual_unit_name = "units/payday2/characters/npc_acc_tools_bag_large_1/npc_acc_tools_bag_large_1"
	}
	self.winch_part_3 = {
		type = "heavy",
		name_id = "hud_carry_winch_bag",
		skip_exit_secure = true,
		unit = "units/payday2/pickups/gen_pku_toolbag_large/gen_pku_toolbag_large_3",
		visual_unit_name = "units/payday2/characters/npc_acc_tools_bag_large_1/npc_acc_tools_bag_large_1"
	}
	self.fireworks = {
		type = "light",
		name_id = "hud_carry_fireworks_bag",
		skip_exit_secure = true,
		unit = "units/payday2/pickups/gen_pku_cage_bag/gen_pku_cage_bag",
		visual_unit_name = "units/payday2/characters/npc_acc_cage_bag_1/npc_acc_cage_bag_1"
	}
	self.watertank_empty = {
		type = "light",
		name_id = "hud_carry_watertank_empty_bag",
		skip_exit_secure = true,
		unit = "units/payday2/pickups/gen_pku_cage_bag/gen_pku_cage_bag",
		visual_unit_name = "units/payday2/characters/npc_acc_cage_bag_1/npc_acc_cage_bag_1"
	}
	self.watertank_full = {
		type = "heavy",
		name_id = "hud_carry_watertank_full_bag",
		skip_exit_secure = true,
		unit = "units/payday2/pickups/gen_pku_cage_bag/gen_pku_cage_bag",
		visual_unit_name = "units/payday2/characters/npc_acc_cage_bag_1/npc_acc_cage_bag_1"
	}
	self.unknown = {
		type = "heavy",
		name_id = "hud_carry_???",
		skip_exit_secure = false,
		AI_carry = {SO_category = "enemies"},
		unit = "units/payday2/pickups/gen_pku_cage_bag/gen_pku_cage_bag",
		visual_unit_name = "units/payday2/characters/npc_acc_cage_bag_1/npc_acc_cage_bag_1"
	}
	self.safe_wpn = {
		type = "slightly_very_heavy",
		name_id = "hud_carry_safe",
		unit = "units/pd2_dlc_jolly/pickups/gen_pku_safe_wpn_bag/gen_pku_safe_wpn_bag",
		visual_unit_name = "units/payday2/characters/npc_acc_safe_wpn_1/npc_acc_safe_wpn_1"
	}
	self.safe_ovk = {
		type = "slightly_very_heavy",
		name_id = "hud_carry_compl_ovk_safe",
		unit = "units/pd2_dlc_jolly/pickups/gen_pku_safe_ovk_bag/gen_pku_safe_ovk_bag",
		visual_unit_name = "units/payday2/characters/npc_acc_safe_ovk_1/npc_acc_safe_ovk_1"
	}
	self.safe_secure_dummy = {
		type = "slightly_very_heavy",
		name_id = "hud_carry_safe",
		bag_value = "safe",
		unit = "units/pd2_dlc_jolly/pickups/gen_safe_secure_dummy/gen_safe_secure_dummy",
		visual_unit_name = "units/payday2/characters/npc_acc_safe_wpn_1/npc_acc_safe_wpn_1"
	}
	self.din_pig = {
		type = "heavy",
		name_id = "hud_carry_pig",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.nail_muriatic_acid = {
		type = "light",
		name_id = "hud_int_equipment_acid",
		skip_exit_secure = true,
		unit = "units/payday2/pickups/gen_pku_toolbag/gen_pku_toolbag",
		visual_unit_name = "units/payday2/characters/npc_acc_tools_bag_1/npc_acc_tools_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.nail_caustic_soda = {
		type = "light",
		name_id = "hud_int_equipment_caustic_soda",
		skip_exit_secure = true,
		unit = "units/payday2/pickups/gen_pku_toolbag_large/gen_pku_toolbag_large",
		visual_unit_name = "units/payday2/characters/npc_acc_tools_bag_large_1/npc_acc_tools_bag_large_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.nail_hydrogen_chloride = {
		type = "light",
		name_id = "hud_int_equipment_hydrogen_chloride",
		skip_exit_secure = true,
		unit = "units/payday2/pickups/gen_pku_cage_bag/gen_pku_cage_bag",
		visual_unit_name = "units/payday2/characters/npc_acc_cage_bag_1/npc_acc_cage_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.nail_euphadrine_pills = {
		type = "light",
		name_id = "hud_carry_euphadrine_pills",
		skip_exit_secure = true,
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.meth_half = {
		type = "coke_light",
		name_id = "hud_carry_meth",
		bag_value = "meth_half",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.equipment_bag_global_event = {
		type = "medium",
		name_id = "hud_carry_equipment_bag",
		skip_exit_secure = true,
		unit = "units/pd2_dlc_cane/pickups/gen_pku_toolbag_global_event/gen_pku_toolbag_global_event",
		visual_unit_name = "units/payday2/characters/npc_acc_tools_bag_1/npc_acc_tools_bag_1"
	}
	self.present = {
		type = "coke_light",
		name_id = "hud_carry_present",
		bag_value = "present",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.paper_roll = {
		type = "medium",
		name_id = "hud_carry_paper_roll",
		skip_exit_secure = true,
		unit = "units/payday2/pickups/gen_pku_toolbag/gen_pku_toolbag",
		visual_unit_name = "units/payday2/characters/npc_acc_tools_bag_1/npc_acc_tools_bag_1"
	}
	self.counterfeit_money = {
		type = "medium",
		name_id = "hud_carry_counterfeit_money",
		bag_value = "counterfeit_money",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.goat = {
		type = "medium",
		name_id = "hud_carry_goat",
		unit = "units/pd2_dlc_peta/pickups/pta_pku_goatbag/pta_pku_goatbag",
		visual_unit_name = "units/pd2_dlc_peta/characters/npc_acc_goat_bag_1/npc_acc_goat_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.masterpiece_painting = {
		type = "light",
		name_id = "hud_carry_masterpiece_painting",
		bag_value = "masterpiece_painting",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.breaching_charges = {
		type = "medium",
		name_id = "hud_carry_breaching_charges",
		skip_exit_secure = true,
		unit = "units/payday2/pickups/gen_pku_toolbag/gen_pku_toolbag",
		visual_unit_name = "units/payday2/characters/npc_acc_tools_bag_1/npc_acc_tools_bag_1"
	}
	self.prototype = {
		type = "medium",
		name_id = "hud_carry_prototype",
		bag_value = "prototype",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.master_server = {
		type = "heavy",
		name_id = "hud_carry_master_server",
		bag_value = "master_server",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.lost_artifact = {
		type = "medium",
		name_id = "hud_carry_lost_artifact",
		bag_value = "lost_artifact",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.parachute = {
		type = "light",
		name_id = "hud_carry_parachute",
		skip_exit_secure = true,
		visual_unit_name = "units/pd2_dlc_jerry/characters/npc_acc_parachute_1/npc_acc_parachute_1",
		unit = "units/pd2_dlc_jerry/pickups/gen_pku_parachute_bag/gen_pku_parachute_bag",
		AI_carry = {SO_category = "enemies"}
	}
	self.drk_bomb_part = {
		type = "medium",
		name_id = "hud_carry_cro_loot",
		bag_value = "drk_bomb_part",
		unit = "units/pd2_dlc1/pickups/gen_pku_explosivesbag/gen_pku_explosivesbag",
		visual_unit_name = "units/payday2/characters/npc_acc_explosives_bag_1/npc_acc_explosives_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.weapon_glock = {
		type = "light",
		name_id = "hud_carry_weapon_glock",
		bag_value = "weapon_glock",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1"
	}
	self.weapon_scar = {
		type = "medium",
		name_id = "hud_carry_weapon_scar",
		bag_value = "weapon_scar",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1"
	}
	self.mad_master_server_value_1 = {
		type = "heavy",
		name_id = "hud_carry_master_server",
		bag_value = "mad_master_server_value_1",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.mad_master_server_value_2 = {
		type = "heavy",
		name_id = "hud_carry_master_server",
		bag_value = "mad_master_server_value_2",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.mad_master_server_value_3 = {
		type = "heavy",
		name_id = "hud_carry_master_server",
		bag_value = "mad_master_server_value_3",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.mad_master_server_value_4 = {
		type = "heavy",
		name_id = "hud_carry_master_server",
		bag_value = "mad_master_server_value_4",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.bike_part_light = {
		type = "light",
		name_id = "hud_carry_bike_part",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.bike_part_heavy = {
		type = "heavy",
		name_id = "hud_carry_bike_part",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.drone_control_helmet = {
		type = "light",
		name_id = "hud_carry_helmet",
		bag_value = "mad_master_server_value_4",
		unit = "units/payday2/pickups/gen_pku_cage_bag/gen_pku_cage_bag",
		visual_unit_name = "units/payday2/characters/npc_acc_cage_bag_1/npc_acc_cage_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.chl_puck = {
		type = "light",
		name_id = "hud_carry_lance_bag",
		skip_exit_secure = true,
		unit = "units/payday2/pickups/gen_pku_toolbag/gen_pku_toolbag",
		visual_unit_name = "units/payday2/characters/npc_acc_tools_bag_1/npc_acc_tools_bag_1"
	}
	self.toothbrush = {
		type = "heavy",
		name_id = "hud_carry_giant_toothbrush",
		bag_value = "toothbrush",
		unit = "units/payday2/pickups/gen_pku_cage_bag/gen_pku_cage_bag",
		visual_unit_name = "units/payday2/characters/npc_acc_cage_bag_1/npc_acc_cage_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.cloaker_gold = {}
	self.cloaker_gold = {
		type = "cloaker_explosives",
		name_id = "hud_carry_cloaker_gold",
		bag_value = "cloaker_gold",
		unit = "units/pd2_dlc_help/pickups/gen_pku_spooky_bag/gen_pku_spooky_bag",
		visual_unit_name = "units/pd2_dlc_help/characters/npc_acc_spooky_bag/npc_acc_spooky_bag",
		AI_carry = {SO_category = "enemies"}
	}
	self.cloaker_money = {
		type = "cloaker_explosives",
		name_id = "hud_carry_cloaker_money",
		bag_value = "cloaker_money",
		unit = "units/pd2_dlc_help/pickups/gen_pku_spooky_bag/gen_pku_spooky_bag",
		visual_unit_name = "units/pd2_dlc_help/characters/npc_acc_spooky_bag/npc_acc_spooky_bag",
		AI_carry = {SO_category = "enemies"}
	}
	self.cloaker_cocaine = {
		type = "cloaker_explosives",
		name_id = "hud_carry_cloaker_cocaine",
		bag_value = "cloaker_cocaine",
		unit = "units/pd2_dlc_help/pickups/gen_pku_spooky_bag/gen_pku_spooky_bag",
		visual_unit_name = "units/pd2_dlc_help/characters/npc_acc_spooky_bag/npc_acc_spooky_bag",
		AI_carry = {SO_category = "enemies"}
	}
	self.diamond_necklace = {
		type = "light",
		name_id = "hud_carry_diamond_necklace",
		bag_value = "diamond_necklace",
		unit = "units/payday2/pickups/gen_pku_cage_bag/gen_pku_cage_bag",
		visual_unit_name = "units/payday2/characters/npc_acc_cage_bag_1/npc_acc_cage_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.vr_headset = {
		type = "light",
		name_id = "hud_carry_vr_headset",
		bag_value = "vr_headset",
		unit = "units/payday2/pickups/gen_pku_cage_bag/gen_pku_cage_bag",
		visual_unit_name = "units/payday2/characters/npc_acc_cage_bag_1/npc_acc_cage_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.women_shoes = {
		type = "light",
		name_id = "hud_carry_shoes",
		bag_value = "women_shoes",
		unit = "units/payday2/pickups/gen_pku_cage_bag/gen_pku_cage_bag",
		visual_unit_name = "units/payday2/characters/npc_acc_cage_bag_1/npc_acc_cage_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.expensive_vine = {
		type = "light",
		name_id = "hud_carry_expensive_wine",
		bag_value = "expensive_vine",
		unit = "units/payday2/pickups/gen_pku_cage_bag/gen_pku_cage_bag",
		visual_unit_name = "units/payday2/characters/npc_acc_cage_bag_1/npc_acc_cage_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.ordinary_wine = {
		type = "light",
		name_id = "hud_carry_wine",
		bag_value = "ordinary_wine",
		unit = "units/payday2/pickups/gen_pku_cage_bag/gen_pku_cage_bag",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.robot_toy = {
		type = "light",
		name_id = "hud_carry_robot_toy",
		bag_value = "robot_toy",
		unit = "units/payday2/pickups/gen_pku_cage_bag/gen_pku_cage_bag",
		visual_unit_name = "units/payday2/characters/npc_acc_cage_bag_1/npc_acc_cage_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.yayo = {
		type = "coke_light",
		name_id = "hud_carry_yayo",
		bag_value = "coke",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.rubies = {
		type = "heavy",
		name_id = "hud_carry_rubies",
		bag_value = "rubies",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.red_diamond = {
		type = "coke_light",
		name_id = "hud_carry_red_diamond",
		bag_value = "red_diamond",
		AI_carry = {SO_category = "enemies"},
		unit = "units/payday2/pickups/gen_pku_cage_bag/gen_pku_cage_bag",
		visual_unit_name = "units/payday2/characters/npc_acc_cage_bag_1/npc_acc_cage_bag_1"
	}
	self.diamonds_dah = {
		type = "light",
		name_id = "hud_carry_diamonds_dah",
		bag_value = "diamonds",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
	self.box_unknown_tag = {
		type = "heavy",
		bag_value = "box_unknown",
		name_id = "hud_carry_box",
		skip_exit_secure = false,
		AI_carry = {SO_category = "enemies"},
		unit = "units/payday2/pickups/gen_pku_cage_bag/gen_pku_cage_bag",
		visual_unit_name = "units/payday2/characters/npc_acc_cage_bag_1/npc_acc_cage_bag_1"
	}
	self.battery = {
		type = "slightly_heavy",
		name_id = "hud_carry_battery",
		unit = "units/payday2/pickups/gen_pku_toolbag/gen_pku_toolbag",
		visual_unit_name = "units/payday2/characters/npc_acc_tools_bag_1/npc_acc_tools_bag_1",
		skip_exit_secure = true,
		AI_carry = {SO_category = "enemies"}
	}
	self.box_unknown = {
		type = "heavy",
		bag_value = "box_unknown",
		name_id = "hud_carry_box",
		skip_exit_secure = false,
		AI_carry = {SO_category = "enemies"},
		unit = "units/payday2/pickups/gen_pku_cage_bag/gen_pku_cage_bag",
		visual_unit_name = "units/payday2/characters/npc_acc_cage_bag_1/npc_acc_cage_bag_1"
	}
	self.black_tablet = {
		type = "medium",
		bag_value = "box_unknown",
		name_id = "hud_carry_black_tablet",
		skip_exit_secure = false,
		AI_carry = {SO_category = "enemies"},
		unit = "units/payday2/pickups/gen_pku_cage_bag/gen_pku_cage_bag",
		visual_unit_name = "units/payday2/characters/npc_acc_cage_bag_1/npc_acc_cage_bag_1"
	}
	self.old_wine = {
		type = "slightly_heavy",
		name_id = "hud_carry_old_wine",
		bag_value = "old_wine",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
		AI_carry = {SO_category = "enemies"}
	}
end

function CarryTweakData:get_carry_ids()
	local t = {}

	for id, _ in pairs(tweak_data.carry) do
		if type(tweak_data.carry[id]) == "table" and tweak_data.carry[id].type then
			table.insert(t, id)
		end
	end

	table.sort(t)

	return t
end

function CarryTweakData:get_zipline_offset(carry_id)
	local unit_name = tweak_data.carry[carry_id].unit or "units/payday2/pickups/gen_pku_lootbag/gen_pku_lootbag"

	if unit_name == "units/payday2/pickups/gen_pku_bodybag/gen_pku_bodybag" then
		return Vector3(0, 0, -17)
	elseif unit_name == "units/payday2/pickups/gen_pku_canvasbag/gen_pku_canvasbag" then
		return Vector3(0, 0, 0)
	end

	return Vector3(15, 0, -8)
end

