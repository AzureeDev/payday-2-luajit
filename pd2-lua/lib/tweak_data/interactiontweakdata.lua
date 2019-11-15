InteractionTweakData = InteractionTweakData or class()

function InteractionTweakData:init(tweak_data)
	self.CULLING_DISTANCE = 2000
	self.INTERACT_DISTANCE = 200
	self.MAX_INTERACT_DISTANCE = 0
	self.copy_machine_smuggle = {
		icon = "equipment_thermite",
		text_id = "debug_interact_copy_machine",
		interact_distance = 305
	}
	self.safety_deposit = {
		icon = "develop",
		text_id = "debug_interact_safety_deposit"
	}
	self.paper_pickup = {
		icon = "develop",
		text_id = "debug_interact_paper_pickup"
	}
	self.thermite = {
		icon = "equipment_thermite",
		text_id = "debug_interact_thermite",
		equipment_text_id = "debug_interact_equipment_thermite",
		special_equipment = "thermite",
		equipment_consume = true,
		interact_distance = 300,
		timer = 3
	}
	self.thermite_not_consume = deep_clone(self.thermite)
	self.thermite_not_consume.equipment_consume = false
	self.gasoline = {
		icon = "equipment_thermite",
		text_id = "debug_interact_gas",
		equipment_text_id = "debug_interact_equipment_gas",
		special_equipment = "gas",
		equipment_consume = true,
		interact_distance = 300
	}
	self.gasoline_engine = {
		icon = "equipment_thermite",
		text_id = "debug_interact_gas",
		equipment_text_id = "debug_interact_equipment_gas",
		special_equipment = "gas",
		equipment_consume = true,
		interact_distance = 300,
		timer = 20
	}
	self.train_car = {
		icon = "develop",
		text_id = "debug_interact_train_car",
		equipment_text_id = "debug_interact_equipment_gas",
		special_equipment = "gas",
		equipment_consume = true,
		interact_distance = 400
	}
	self.walkout_van = {
		icon = "develop",
		text_id = "debug_interact_walkout_van",
		equipment_text_id = "debug_interact_equipment_gold",
		special_equipment = "gold",
		equipment_consume = true,
		interact_distance = 400
	}
	self.alaska_plane = {
		icon = "develop",
		text_id = "debug_interact_alaska_plane",
		equipment_text_id = "debug_interact_equipment_organs",
		special_equipment = "organs",
		equipment_consume = true,
		interact_distance = 400
	}
	self.suburbia_door_crowbar = {
		icon = "equipment_crowbar",
		text_id = "debug_interact_crowbar",
		equipment_text_id = "debug_interact_equipment_crowbar",
		special_equipment = "crowbar",
		timer = 5,
		start_active = false,
		sound_start = "bar_crowbar",
		sound_interupt = "bar_crowbar_cancel",
		sound_done = "bar_crowbar_end",
		interact_distance = 130
	}
	self.secret_stash_trunk_crowbar = {
		icon = "equipment_crowbar",
		text_id = "debug_interact_crowbar2",
		equipment_text_id = "debug_interact_equipment_crowbar",
		special_equipment = "crowbar",
		timer = 4,
		start_active = false,
		sound_start = "und_crowbar_trunk",
		sound_interupt = "und_crowbar_trunk_cancel",
		sound_done = "und_crowbar_trunk_finished"
	}
	self.requires_crowbar_interactive_template = {
		icon = "equipment_crowbar",
		text_id = "debug_interact_crowbar_breach",
		equipment_text_id = "debug_interact_equipment_crowbar",
		special_equipment = "crowbar",
		timer = 8,
		start_active = false,
		sound_start = "bar_crowbar_open_metal",
		sound_interupt = "bar_crowbar_open_metal_cancel",
		sound_done = "bar_crowbar_open_metal_finished"
	}
	self.requires_saw_blade = {
		icon = "develop",
		text_id = "hud_int_hold_add_blade",
		equipment_text_id = "hud_equipment_no_saw_blade",
		special_equipment = "saw_blade",
		timer = 2,
		start_active = false,
		equipment_consume = true
	}
	self.saw_blade = {
		text_id = "hud_int_hold_take_blade",
		action_text_id = "hud_action_taking_saw_blade",
		timer = 0.5,
		start_active = false,
		special_equipment_block = "saw_blade"
	}
	self.open_slash_close_sec_box = {
		text_id = "hud_int_hold_open_slash_close_sec_box",
		action_text_id = "hud_action_opening_slash_closing_sec_box",
		timer = 0.5,
		start_active = false
	}
	self.activate_camera = {
		text_id = "hud_int_hold_activate_camera",
		action_text_id = "hud_action_activating_camera",
		timer = 0.5,
		start_active = false
	}
	self.requires_ecm_jammer_double = {
		icon = "equipment_ecm_jammer",
		contour = "interactable_icon",
		text_id = "hud_int_use_ecm_jammer",
		required_deployable = "ecm_jammer",
		deployable_consume = true,
		timer = 4,
		sound_start = "bar_c4_apply",
		sound_interupt = "bar_c4_apply_cancel",
		sound_done = "bar_c4_apply_finished",
		action_text_id = "hud_action_placing_ecm_jammer",
		requires_upgrade = {
			upgrade = "can_open_sec_doors",
			category = "ecm_jammer"
		}
	}
	self.requires_ecm_jammer = deep_clone(self.requires_ecm_jammer_double)
	self.requires_ecm_jammer.axis = "y"
	self.requires_ecm_jammer_atm = deep_clone(self.requires_ecm_jammer)
	self.requires_ecm_jammer_atm.timer = 8
	self.requires_ecm_jammer_atm.requires_upgrade = {
		upgrade = "affects_cameras",
		category = "ecm_jammer"
	}
	self.weapon_cache_drop_zone = {
		icon = "equipment_vial",
		text_id = "debug_interact_hospital_veil_container",
		equipment_text_id = "debug_interact_equipment_blood_sample_verified",
		special_equipment = "blood_sample",
		equipment_consume = true,
		start_active = false,
		timer = 2
	}
	self.secret_stash_limo_roof_crowbar = {
		icon = "develop",
		text_id = "debug_interact_hold_to_breach",
		timer = 5,
		start_active = false,
		sound_start = "und_limo_chassis_open",
		sound_interupt = "und_limo_chassis_open_stop",
		sound_done = "und_limo_chassis_open_stop",
		axis = "y"
	}
	self.suburbia_iron_gate_crowbar = {
		icon = "equipment_crowbar",
		text_id = "debug_interact_crowbar",
		equipment_text_id = "debug_interact_equipment_crowbar",
		special_equipment = "crowbar",
		timer = 5,
		start_active = false,
		sound_start = "bar_crowbar_open_metal",
		sound_interupt = "bar_crowbar_open_metal_cancel",
		sound_done = "bar_crowbar_open_metal_finished"
	}
	self.apartment_key = {
		icon = "equipment_chavez_key",
		text_id = "debug_interact_apartment_key",
		equipment_text_id = "debug_interact_equiptment_apartment_key",
		special_equipment = "chavez_key",
		equipment_consume = true,
		interact_distance = 150
	}
	self.hospital_sample_validation_machine = {
		icon = "equipment_vial",
		text_id = "debug_interact_sample_validation",
		equipment_text_id = "debug_interact_equiptment_sample_validation",
		special_equipment = "blood_sample",
		equipment_consume = true,
		start_active = false,
		interact_distance = 150,
		axis = "y"
	}
	self.methlab_bubbling = {
		icon = "develop",
		text_id = "hud_int_methlab_bubbling",
		equipment_text_id = "hud_int_no_acid",
		special_equipment = "acid",
		equipment_consume = true,
		start_active = false,
		timer = 1,
		action_text_id = "hud_action_methlab_bubbling",
		sound_start = "liquid_pour",
		sound_interupt = "liquid_pour_stop",
		sound_done = "liquid_pour_stop"
	}
	self.methlab_caustic_cooler = {
		icon = "develop",
		text_id = "hud_int_methlab_caustic_cooler",
		equipment_text_id = "hud_int_no_caustic_soda",
		special_equipment = "caustic_soda",
		equipment_consume = true,
		start_active = false,
		timer = 1,
		action_text_id = "hud_action_methlab_caustic_cooler",
		sound_start = "liquid_pour",
		sound_interupt = "liquid_pour_stop",
		sound_done = "liquid_pour_stop"
	}
	self.methlab_gas_to_salt = {
		icon = "develop",
		text_id = "hud_int_methlab_gas_to_salt",
		equipment_text_id = "hud_int_no_hydrogen_chloride",
		special_equipment = "hydrogen_chloride",
		equipment_consume = true,
		start_active = false,
		timer = 1,
		action_text_id = "hud_action_methlab_gas_to_salt",
		sound_start = "bar_bag_generic",
		sound_interupt = "bar_bag_generic_cancel",
		sound_done = "bar_bag_generic_finished"
	}
	self.methlab_drying_meth = {
		icon = "develop",
		text_id = "hud_int_methlab_drying_meth",
		equipment_text_id = "hud_int_no_liquid_meth",
		special_equipment = "liquid_meth",
		equipment_consume = true,
		start_active = false,
		timer = 1,
		action_text_id = "hud_action_methlab_drying_meth",
		sound_start = "liquid_pour",
		sound_interupt = "liquid_pour_stop",
		sound_done = "liquid_pour_stop"
	}
	self.muriatic_acid = {
		icon = "develop",
		text_id = "hud_int_take_acid",
		start_active = false,
		interact_distance = 225,
		special_equipment_block = "acid"
	}
	self.caustic_soda = {
		icon = "develop",
		text_id = "hud_int_take_caustic_soda",
		start_active = false,
		interact_distance = 225,
		special_equipment_block = "caustic_soda"
	}
	self.hydrogen_chloride = {
		icon = "develop",
		text_id = "hud_int_take_hydrogen_chloride",
		start_active = false,
		interact_distance = 225,
		special_equipment_block = "hydrogen_chloride"
	}
	self.elevator_button = {
		icon = "interaction_elevator",
		text_id = "debug_interact_elevator_door",
		start_active = false
	}
	self.use_computer = {
		icon = "interaction_elevator",
		text_id = "hud_int_use_computer",
		start_active = false,
		timer = 2
	}
	self.elevator_button_roof = {
		icon = "interaction_elevator",
		text_id = "debug_interact_elevator_door_roof",
		start_active = false
	}
	self.key_double = {
		icon = "equipment_bank_manager_key",
		text_id = "hud_int_equipment_keycard",
		equipment_text_id = "hud_int_equipment_no_keycard",
		special_equipment = "bank_manager_key",
		equipment_consume = true,
		interact_distance = 100
	}
	self.key = deep_clone(self.key_double)
	self.key.axis = "x"
	self.numpad = {
		icon = "equipment_bank_manager_key",
		text_id = "debug_interact_numpad",
		start_active = false,
		axis = "z"
	}
	self.numpad_keycard = {
		icon = "equipment_bank_manager_key",
		text_id = "hud_int_numpad_keycard",
		equipment_text_id = "hud_int_numpad_no_keycard",
		special_equipment = "bank_manager_key",
		equipment_consume = true,
		start_active = false,
		axis = "z"
	}
	self.timelock_panel = {
		icon = "equipment_bank_manager_key",
		text_id = "hud_int_timelock_panel",
		equipment_text_id = "hud_int_equipment_no_keycard",
		special_equipment = "bank_manager_key",
		equipment_consume = true,
		start_active = false,
		axis = "y"
	}
	self.take_weapons = {
		icon = "develop",
		text_id = "hud_int_take_weapons",
		action_text_id = "hud_action_taking_weapons",
		timer = 3,
		axis = "x",
		interact_distance = 120
	}
	self.take_weapons_axis_z = {
		icon = "develop",
		text_id = "hud_int_take_weapons",
		action_text_id = "hud_action_taking_weapons",
		timer = 3,
		axis = "z",
		interact_distance = 150
	}
	self.take_weapons_not_active = deep_clone(self.take_weapons)
	self.take_weapons_not_active.start_active = false
	self.pick_lock_easy = {
		contour = "interactable_icon",
		icon = "equipment_bank_manager_key",
		text_id = "hud_int_pick_lock",
		start_active = true,
		timer = 10,
		interact_distance = 100,
		requires_upgrade = {
			upgrade = "pick_lock_easy",
			category = "player"
		},
		upgrade_timer_multipliers = {
			{
				upgrade = "pick_lock_easy_speed_multiplier",
				category = "player"
			},
			{
				upgrade = "pick_lock_speed_multiplier",
				category = "player"
			}
		},
		action_text_id = "hud_action_picking_lock",
		sound_start = "bar_pick_lock",
		sound_interupt = "bar_pick_lock_cancel",
		sound_done = "bar_pick_lock_finished",
		is_lockpicking = true
	}
	self.pick_lock_easy_no_skill = {
		contour = "interactable_icon",
		icon = "equipment_bank_manager_key",
		text_id = "hud_int_pick_lock",
		start_active = true,
		timer = 7,
		upgrade_timer_multipliers = {
			{
				upgrade = "pick_lock_easy_speed_multiplier",
				category = "player"
			},
			{
				upgrade = "pick_lock_speed_multiplier",
				category = "player"
			}
		},
		action_text_id = "hud_action_picking_lock",
		interact_distance = 100,
		sound_start = "bar_pick_lock",
		sound_interupt = "bar_pick_lock_cancel",
		sound_done = "bar_pick_lock_finished",
		is_lockpicking = true
	}
	self.pick_lock_hard = {
		contour = "interactable_icon",
		icon = "equipment_bank_manager_key",
		text_id = "hud_int_pick_lock",
		start_active = true,
		timer = 45,
		requires_upgrade = {
			upgrade = "pick_lock_hard",
			category = "player"
		},
		action_text_id = "hud_action_picking_lock",
		sound_start = "bar_pick_lock",
		sound_interupt = "bar_pick_lock_cancel",
		sound_done = "bar_pick_lock_finished",
		is_lockpicking = true
	}
	self.pick_lock_hard_no_skill = {
		contour = "interactable_icon",
		icon = "equipment_bank_manager_key",
		text_id = "hud_int_pick_lock",
		start_active = true,
		timer = 20,
		action_text_id = "hud_action_picking_lock",
		upgrade_timer_multipliers = {
			{
				upgrade = "pick_lock_easy_speed_multiplier",
				category = "player"
			},
			{
				upgrade = "pick_lock_speed_multiplier",
				category = "player"
			}
		},
		interact_distance = 100,
		sound_start = "bar_pick_lock",
		sound_interupt = "bar_pick_lock_cancel",
		sound_done = "bar_pick_lock_finished",
		is_lockpicking = true
	}
	self.pick_lock_deposit_transport = deep_clone(self.pick_lock_hard_no_skill)
	self.pick_lock_deposit_transport.timer = 15
	self.pick_lock_deposit_transport.axis = "y"
	self.pick_lock_deposit_transport.interact_distance = 80
	self.pick_lock_deposit_transport.is_lockpicking = true
	self.open_door_with_keys = {
		contour = "interactable_icon",
		icon = "equipment_bank_manager_key",
		text_id = "hud_int_try_keys",
		start_active = false,
		timer = 5,
		action_text_id = "hud_action_try_keys",
		interact_distance = 100,
		sound_start = "bar_unlock_grate_door",
		sound_interupt = "bar_unlock_grate_door_cancel",
		sound_done = "bar_unlock_grate_door_finished",
		special_equipment = "keychain",
		equipment_text_id = "hud_action_try_keys_no_key",
		is_lockpicking = true
	}
	self.cant_pick_lock = {
		icon = "equipment_bank_manager_key",
		text_id = "hud_int_pick_lock",
		start_active = false,
		interact_distance = 80
	}
	self.lockpick_int_off = deep_clone(self.cant_pick_lock)
	self.no_interact = deep_clone(self.cant_pick_lock)
	self.no_interact.interact_distance = 0
	self.hospital_veil_container = {
		icon = "equipment_vialOK",
		text_id = "debug_interact_hospital_veil_container",
		equipment_text_id = "debug_interact_equipment_blood_sample_verified",
		special_equipment = "blood_sample_verified",
		equipment_consume = true,
		start_active = false,
		timer = 2,
		axis = "y"
	}
	self.hospital_phone = {
		icon = "interaction_answerphone",
		text_id = "debug_interact_hospital_phone",
		start_active = false
	}
	self.hospital_security_cable = {
		text_id = "debug_interact_hospital_security_cable",
		icon = "interaction_wirecutter",
		start_active = false,
		timer = 5,
		interact_distance = 75
	}
	self.hospital_security_cable_red = {
		text_id = "hud_int_hold_cut_wire_red",
		icon = "interaction_wirecutter",
		start_active = false,
		timer = 5,
		interact_distance = 75
	}
	self.hospital_security_cable_blue = {
		text_id = "hud_int_hold_cut_wire_blue",
		icon = "interaction_wirecutter",
		start_active = false,
		timer = 5,
		interact_distance = 75
	}
	self.hospital_security_cable_green = {
		text_id = "hud_int_hold_cut_wire_green",
		icon = "interaction_wirecutter",
		start_active = false,
		timer = 5,
		interact_distance = 75
	}
	self.hospital_security_cable_yellow = {
		text_id = "hud_int_hold_cut_wire_yellow",
		icon = "interaction_wirecutter",
		start_active = false,
		timer = 5,
		interact_distance = 75
	}
	self.hospital_veil = {
		icon = "equipment_vial",
		text_id = "debug_interact_hospital_veil_hold",
		start_active = false,
		timer = 2
	}
	self.hospital_veil_take = {
		icon = "equipment_vial",
		text_id = "debug_interact_hospital_veil_take",
		start_active = false
	}
	self.hospital_sentry = {
		icon = "interaction_sentrygun",
		text_id = "debug_interact_hospital_sentry",
		start_active = false,
		timer = 2
	}
	self.drill = {
		icon = "equipment_drill",
		contour = "interactable_icon",
		text_id = "hud_int_equipment_drill",
		equipment_text_id = "hud_int_equipment_no_drill",
		timer = 3,
		blocked_hint = "no_drill",
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished",
		axis = "y",
		action_text_id = "hud_action_placing_drill"
	}
	self.drill_upgrade = {
		icon = "equipment_drill",
		contour = "upgradable",
		text_id = "hud_int_equipment_drill_upgrade",
		timer = 10,
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished",
		action_text_id = "hud_action_upgrading_drill"
	}
	self.drill_jammed = {
		icon = "equipment_drill",
		text_id = "hud_int_equipment_drill_jammed",
		timer = 10,
		sound_start = "bar_drill_fix",
		sound_interupt = "bar_drill_fix_cancel",
		sound_done = "bar_drill_fix_finished",
		upgrade_timer_multiplier = {
			upgrade = "drill_fix_interaction_speed_multiplier",
			category = "player"
		},
		action_text_id = "hud_action_fixing_drill",
		block_upgrade = true
	}
	self.lance = {
		icon = "equipment_drill",
		contour = "interactable_icon",
		text_id = "hud_int_equipment_lance",
		equipment_text_id = "hud_int_equipment_no_lance",
		timer = 3,
		blocked_hint = "no_lance",
		sound_start = "bar_thermal_lance_apply",
		sound_interupt = "bar_thermal_lance_apply_cancel",
		sound_done = "bar_thermal_lance_apply_finished",
		action_text_id = "hud_action_placing_lance"
	}
	self.lance_bbv = {
		icon = "equipment_drill",
		text_id = "hud_int_equipment_lance",
		equipment_text_id = "hud_int_equipment_no_lance",
		timer = 3,
		blocked_hint = "no_lance",
		sound_start = "bar_thermal_lance_apply",
		sound_interupt = "bar_thermal_lance_apply_cancel",
		sound_done = "bar_thermal_lance_apply_finished",
		action_text_id = "hud_action_placing_lance"
	}
	self.lance_jammed = {
		icon = "equipment_drill",
		text_id = "hud_int_equipment_lance_jammed",
		timer = 10,
		sound_start = "bar_thermal_lance_fix",
		sound_interupt = "bar_thermal_lance_fix_cancel",
		sound_done = "bar_thermal_lance_fix_finished",
		upgrade_timer_multiplier = {
			upgrade = "drill_fix_interaction_speed_multiplier",
			category = "player"
		},
		action_text_id = "hud_action_fixing_lance",
		block_upgrade = true
	}
	self.lance_upgrade = {
		icon = "equipment_drill",
		contour = "upgradable",
		text_id = "hud_int_equipment_lance_upgrade",
		timer = 10,
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished",
		action_text_id = "hud_action_upgrading_lance"
	}
	self.glass_cutter = {
		icon = "equipment_cutter",
		text_id = "debug_interact_glass_cutter",
		equipment_text_id = "debug_interact_equipment_glass_cutter",
		special_equipment = "glass_cutter",
		timer = 3,
		blocked_hint = "no_glass_cutter",
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished"
	}
	self.glass_cutter_jammed = {
		icon = "equipment_cutter",
		text_id = "debug_interact_cutter_jammed",
		timer = 10,
		sound_start = "bar_drill_fix",
		sound_interupt = "bar_drill_fix_cancel",
		sound_done = "bar_drill_fix_finished",
		block_upgrade = true
	}
	self.hack_ipad = {
		icon = "equipment_hack_ipad",
		text_id = "debug_interact_hack_ipad",
		timer = 3,
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished",
		axis = "x"
	}
	self.hack_ipad_jammed = {
		icon = "equipment_hack_ipad",
		text_id = "debug_interact_hack_ipad_jammed",
		timer = 10,
		sound_start = "bar_drill_fix",
		sound_interupt = "bar_drill_fix_cancel",
		sound_done = "bar_drill_fix_finished"
	}
	self.hack_suburbia = {
		icon = "equipment_hack_ipad",
		text_id = "debug_interact_hack_ipad",
		timer = 5,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished",
		axis = "y",
		contour = "contour_off"
	}
	self.hack_suburbia_outline = {
		icon = "equipment_hack_ipad",
		text_id = "debug_interact_hack_ipad",
		timer = 5,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished",
		axis = "y"
	}
	self.hack_suburbia_jammed = {
		icon = "equipment_hack_ipad",
		text_id = "debug_interact_hack_ipad_jammed",
		timer = 5,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.hack_suburbia_jammed_y = deep_clone(self.hack_suburbia_jammed)
	self.hack_suburbia_jammed_y.axis = "y"
	self.hack_suburbia_jammed_axis = deep_clone(self.hack_suburbia_jammed)
	self.hack_suburbia_jammed_axis.axis = "y"
	self.hack_suburbia_axis = deep_clone(self.hack_suburbia)
	self.hack_suburbia_axis.axis = "y"
	self.security_station = {
		icon = "equipment_hack_ipad",
		text_id = "debug_interact_security_station",
		timer = 3,
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished",
		axis = "z",
		start_active = false,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.security_station_keyboard = {
		icon = "interaction_keyboard",
		text_id = "debug_interact_security_station",
		timer = 6,
		axis = "z",
		start_active = false,
		interact_distance = 150,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.big_computer_hackable = {
		icon = "interaction_keyboard",
		text_id = "hud_int_big_computer_hackable",
		timer = 6,
		start_active = false,
		interact_distance = 200,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.big_computer_hackable_axis = {
		icon = "interaction_keyboard",
		text_id = "hud_int_big_computer_hackable",
		timer = 6,
		axis = "z",
		start_active = false,
		interact_distance = 200,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.big_computer_not_hackable = {
		icon = "interaction_keyboard",
		text_id = "hud_int_big_computer_hackable",
		timer = 6,
		start_active = false,
		interact_distance = 200,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished",
		equipment_text_id = "hud_int_big_computer_unhackable",
		special_equipment = "nothing"
	}
	self.big_computer_server = {
		icon = "interaction_keyboard",
		text_id = "hud_int_big_computer_server",
		timer = 6,
		start_active = false,
		interact_distance = 150,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.security_station_jammed = {
		icon = "interaction_keyboard",
		text_id = "debug_interact_security_station_jammed",
		timer = 10,
		sound_start = "bar_drill_fix",
		sound_interupt = "bar_drill_fix_cancel",
		sound_done = "bar_drill_fix_finished",
		axis = "z"
	}
	self.apartment_drill = {
		icon = "equipment_drill",
		text_id = "debug_interact_drill",
		equipment_text_id = "debug_interact_equipment_drill",
		timer = 3,
		blocked_hint = "no_drill",
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished",
		interact_distance = 200
	}
	self.apartment_drill_jammed = {
		icon = "equipment_drill",
		text_id = "debug_interact_drill_jammed",
		timer = 3,
		sound_start = "bar_drill_fix",
		sound_interupt = "bar_drill_fix_cancel",
		sound_done = "bar_drill_fix_finished",
		interact_distance = 200,
		block_upgrade = true
	}
	self.suburbia_drill = {
		icon = "equipment_drill",
		text_id = "debug_interact_drill",
		equipment_text_id = "debug_interact_equipment_drill",
		timer = 3,
		blocked_hint = "no_drill",
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished",
		interact_distance = 200
	}
	self.suburbia_drill_jammed = {
		icon = "equipment_drill",
		text_id = "debug_interact_drill_jammed",
		timer = 3,
		sound_start = "bar_drill_fix",
		sound_interupt = "bar_drill_fix_cancel",
		sound_done = "bar_drill_fix_finished",
		interact_distance = 200,
		block_upgrade = true
	}
	self.goldheist_drill = {
		icon = "equipment_drill",
		text_id = "debug_interact_drill",
		equipment_text_id = "debug_interact_equipment_drill",
		timer = 3,
		blocked_hint = "no_drill",
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished",
		interact_distance = 200
	}
	self.goldheist_drill_jammed = {
		icon = "equipment_drill",
		text_id = "debug_interact_drill_jammed",
		timer = 3,
		sound_start = "bar_drill_fix",
		sound_interupt = "bar_drill_fix_cancel",
		sound_done = "bar_drill_fix_finished",
		interact_distance = 200,
		block_upgrade = true
	}
	self.hospital_saw_teddy = {
		icon = "equipment_saw",
		text_id = "debug_interact_hospital_saw_teddy",
		start_active = false,
		timer = 2
	}
	self.hospital_saw = {
		icon = "equipment_saw",
		text_id = "debug_interact_saw",
		equipment_text_id = "debug_interact_equipment_saw",
		special_equipment = "saw",
		timer = 3,
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished",
		interact_distance = 200,
		axis = "z"
	}
	self.hospital_saw_jammed = {
		icon = "equipment_saw",
		text_id = "debug_interact_saw_jammed",
		timer = 3,
		sound_start = "bar_drill_fix",
		sound_interupt = "bar_drill_fix_cancel",
		sound_done = "bar_drill_fix_finished",
		interact_distance = 200,
		axis = "z",
		upgrade_timer_multiplier = {
			upgrade = "drill_fix_interaction_speed_multiplier",
			category = "player"
		},
		block_upgrade = true
	}
	self.apartment_saw = {
		icon = "equipment_saw",
		text_id = "debug_interact_saw",
		timer = 3,
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished",
		interact_distance = 200,
		axis = "z"
	}
	self.apartment_saw_jammed = {
		icon = "equipment_saw",
		text_id = "debug_interact_saw_jammed",
		timer = 3,
		sound_start = "bar_drill_fix",
		sound_interupt = "bar_drill_fix_cancel",
		sound_done = "bar_drill_fix_finished",
		interact_distance = 200,
		axis = "z",
		upgrade_timer_multiplier = {
			upgrade = "drill_fix_interaction_speed_multiplier",
			category = "player"
		},
		block_upgrade = true
	}
	self.secret_stash_saw = {
		icon = "equipment_saw",
		text_id = "debug_interact_saw",
		timer = 3,
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished",
		interact_distance = 200,
		axis = "z"
	}
	self.secret_stash_saw_jammed = {
		icon = "equipment_saw",
		text_id = "debug_interact_saw_jammed",
		timer = 3,
		sound_start = "bar_drill_fix",
		sound_interupt = "bar_drill_fix_cancel",
		sound_done = "bar_drill_fix_finished",
		interact_distance = 200,
		axis = "z",
		upgrade_timer_multiplier = {
			upgrade = "drill_fix_interaction_speed_multiplier",
			category = "player"
		},
		block_upgrade = true
	}
	self.revive = {
		icon = "interaction_help",
		text_id = "debug_interact_revive",
		start_active = false,
		interact_distance = 300,
		axis = "z",
		timer = 6,
		sound_start = "bar_helpup",
		sound_interupt = "bar_helpup_cancel",
		sound_done = "bar_helpup_finished",
		action_text_id = "hud_action_reviving",
		upgrade_timer_multiplier = {
			upgrade = "revive_interaction_speed_multiplier",
			category = "player"
		},
		contour_preset = "teammate_downed",
		contour_preset_selected = "teammate_downed_selected"
	}
	self.dead = {
		icon = "interaction_help",
		text_id = "debug_interact_revive",
		start_active = false,
		interact_distance = 300
	}
	self.free = {
		icon = "interaction_free",
		text_id = "debug_interact_free",
		start_active = false,
		interact_distance = 300,
		no_contour = true,
		timer = 1,
		sound_start = "bar_rescue",
		sound_interupt = "bar_rescue_cancel",
		sound_done = "bar_rescue_finished",
		action_text_id = "hud_action_freeing"
	}
	self.hostage_skm = {
		icon = "interaction_trade",
		text_id = "debug_interact_trade_hostage_skm",
		timer = 5,
		action_text_id = "hud_action_trading_hostage_skm"
	}
	self.hostage_trade = {
		icon = "interaction_trade",
		text_id = "debug_interact_trade",
		start_active = true,
		timer = 3,
		requires_upgrade = {
			upgrade = "hostage_trade",
			category = "player"
		},
		action_text_id = "hud_action_trading",
		contour_preset = "generic_interactable",
		contour_preset_selected = "generic_interactable_selected"
	}
	self.hostage_move = {
		icon = "interaction_trade",
		text_id = "debug_interact_hostage_move",
		start_active = true,
		timer = 1,
		action_text_id = "hud_action_standing_up",
		no_contour = true,
		interaction_obj = Idstring("Spine")
	}
	self.hostage_stay = {
		icon = "interaction_trade",
		text_id = "debug_interact_hostage_stay",
		start_active = true,
		timer = 0.4,
		action_text_id = "hud_action_getting_down",
		no_contour = true,
		interaction_obj = Idstring("Spine2")
	}
	self.trip_mine = {
		icon = "equipment_trip_mine",
		requires_upgrade = {
			upgrade = "can_switch_on_off",
			category = "trip_mine"
		},
		no_contour = true
	}
	self.sentry_gun_refill = {
		icon = "equipment_ammo_bag",
		requires_upgrade = {
			upgrade = "can_reload",
			category = "sentry_gun"
		},
		timer = 1.5,
		blocked_hint = "hint_reload_sentry",
		sound_start = "bar_turret_ammo",
		sound_interupt = "bar_turret_ammo_cancel",
		sound_done = "bar_turret_ammo_finished",
		action_text_id = "hud_action_reload_sentry",
		no_contour = true
	}
	self.sentry_gun_revive = {
		icon = "equipment_ammo_bag",
		requires_upgrade = {
			upgrade = "can_revive",
			category = "sentry_gun"
		},
		timer = 3.5,
		blocked_hint = "hint_reload_sentry",
		sound_start = "bar_bag_generic",
		sound_interupt = "bar_bag_generic_cancel",
		sound_done = "bar_bag_generic_finished",
		action_text_id = "hud_action_reload_sentry",
		no_contour = true
	}
	self.sentry_gun = {
		icon = "equipment_ammo_bag",
		timer = 0.5,
		text_id = "hud_interact_pickup_sentry_gun",
		blocked_hint = "hint_reload_sentry",
		sound_start = "bar_bag_generic",
		sound_interupt = "bar_bag_generic_cancel",
		sound_done = "bar_bag_generic_finished",
		action_text_id = "hud_action_pickup_sentry_gun",
		interact_distance = 200,
		no_contour = true,
		verify_owner = true
	}
	self.sentry_gun_fire_mode = {
		icon = "equipment_ammo_bag",
		requires_upgrade = {
			upgrade = "ap_bullets",
			category = "sentry_gun"
		},
		text_id = "hud_interact_sentry_gun_switch_fire_mode",
		blocked_hint = "hint_reload_sentry",
		sound_start = "bar_bag_generic",
		sound_interupt = "bar_bag_generic_cancel",
		sound_done = "bar_bag_generic_finished",
		action_text_id = "hud_action_sentry_gun_switch_fire_mode",
		interact_distance = 800,
		max_interact_distance = 200,
		no_contour = true,
		verify_owner = true
	}
	self.bodybags_bag = {
		icon = "equipment_ammo_bag",
		text_id = "debug_interact_bodybags_bag_take_bodybag",
		contour = "deployable",
		timer = 1.5,
		blocked_hint = "full_bodybags",
		sound_start = "bar_bag_generic",
		sound_interupt = "bar_bag_generic_cancel",
		sound_done = "bar_bag_generic_finished",
		action_text_id = "hud_action_grabbing_bag"
	}
	self.grenade_crate = {
		icon = "equipment_ammo_bag",
		text_id = "debug_interact_grenade_crate_take_grenades",
		contour = "deployable",
		timer = 1.5,
		blocked_hint = "full_grenades",
		sound_start = "bar_bag_generic",
		sound_interupt = "bar_bag_generic_cancel",
		sound_done = "bar_bag_generic_finished",
		action_text_id = "hud_action_taking_grenades"
	}
	self.ammo_bag = {
		icon = "equipment_ammo_bag",
		text_id = "debug_interact_ammo_bag_take_ammo",
		contour = "deployable",
		timer = 3.5,
		blocked_hint = "full_ammo",
		sound_start = "bar_bag_generic",
		sound_interupt = "bar_bag_generic_cancel",
		sound_done = "bar_bag_generic_finished",
		action_text_id = "hud_action_taking_ammo",
		upgrade_timer_multiplier = {
			upgrade = "deploy_interact_faster",
			category = "player"
		}
	}
	self.doctor_bag = {
		icon = "equipment_doctor_bag",
		text_id = "debug_interact_doctor_bag_heal",
		contour = "deployable",
		timer = 3.5,
		blocked_hint = "full_health",
		sound_start = "bar_helpup",
		sound_interupt = "bar_helpup_cancel",
		sound_done = "bar_helpup_finished",
		action_text_id = "hud_action_healing",
		upgrade_timer_multipliers = {
			{
				upgrade = "interaction_speed_multiplier",
				category = "doctor_bag"
			},
			{
				upgrade = "deploy_interact_faster",
				category = "player"
			}
		}
	}
	self.ecm_jammer = {
		icon = "equipment_ecm_jammer",
		text_id = "hud_int_equipment_ecm_feedback",
		requires_upgrade = {
			upgrade = "can_activate_feedback",
			category = "ecm_jammer"
		},
		upgrade_timer_multipliers = {
			{
				upgrade = "interaction_speed_multiplier",
				category = "ecm_jammer"
			},
			{
				upgrade = "deploy_interact_faster",
				category = "player"
			}
		},
		timer = 2,
		no_contour = true,
		force_update_position = true
	}
	self.laptop_objective = {
		icon = "laptop_objective",
		start_active = false,
		text_id = "debug_interact_laptop_objective",
		timer = 15,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished",
		say_waiting = "i01x_any",
		axis = "z",
		interact_distance = 100
	}
	self.money_bag = {
		icon = "equipment_money_bag",
		text_id = "debug_interact_money_bag",
		equipment_text_id = "debug_interact_equipment_money_bag",
		special_equipment = "money_bag",
		equipment_consume = false,
		sound_event = "ammo_bag_drop"
	}
	self.apartment_helicopter = {
		icon = "develop",
		text_id = "debug_interact_apartment_helicopter",
		sound_event = "ammo_bag_drop",
		timer = 13,
		interact_distance = 350
	}
	self.test_interactive_door = {
		icon = "develop",
		text_id = "debug_interact_temp_interact_box",
		sound_event = "ammo_bag_drop"
	}
	self.press_to_interact = {
		icon = "develop",
		text_id = "hud_press_to_interact",
		sound_event = "ammo_bag_drop"
	}
	self.test_interactive_door_one_direction = {
		icon = "develop",
		text_id = "debug_interact_temp_interact_box",
		sound_event = "ammo_bag_drop",
		axis = "y"
	}
	self.temp_interact_box = {
		icon = "develop",
		text_id = "debug_interact_temp_interact_box",
		sound_event = "ammo_bag_drop",
		timer = 4
	}
	self.requires_cable_ties = {
		icon = "develop",
		text_id = "debug_interact_temp_interact_box",
		equipment_text_id = "debug_interact_equipment_requires_cable_ties",
		sound_event = "ammo_bag_drop",
		special_equipment = "cable_tie",
		equipment_consume = true,
		timer = 5,
		requires_upgrade = {
			upgrade = "can_cable_tie_doors",
			category = "cable_tie"
		},
		upgrade_timer_multiplier = {
			upgrade = "interact_speed_multiplier",
			category = "cable_tie"
		}
	}
	self.temp_interact_box_no_timer = {
		icon = "develop",
		text_id = "debug_interact_temp_interact_box"
	}
	self.access_camera = {
		icon = "develop",
		text_id = "hud_int_access_camera",
		interact_distance = 125
	}
	self.access_camera_x_axis = {
		icon = "develop",
		text_id = "hud_int_access_camera",
		interact_distance = 125,
		axis = "x"
	}
	self.driving_console = {
		icon = "develop",
		text_id = "hud_int_driving_console",
		interact_distance = 500
	}
	self.driving_drive = {
		icon = "develop",
		text_id = "hud_int_driving_drive",
		timer = 1
	}
	self.interaction_ball = {
		icon = "develop",
		text_id = "debug_interact_interaction_ball",
		timer = 5,
		sound_start = "cft_hose_loop",
		sound_interupt = "cft_hose_cancel",
		sound_done = "cft_hose_end"
	}
	self.invisible_interaction_open = {
		icon = "develop",
		text_id = "hud_int_invisible_interaction_open",
		timer = 0.5
	}
	self.invisible_interaction_open_axis = deep_clone(self.invisible_interaction_open)
	self.invisible_interaction_open_axis.axis = "y"
	self.fork_lift_sound = deep_clone(self.invisible_interaction_open)
	self.fork_lift_sound.text_id = "hud_int_fork_lift_sound"
	self.money_briefcase = deep_clone(self.invisible_interaction_open)
	self.money_briefcase.axis = "x"
	self.grenade_briefcase = deep_clone(self.invisible_interaction_open)
	self.grenade_briefcase.contour = "deployable"
	self.cash_register = deep_clone(self.invisible_interaction_open)
	self.cash_register.axis = "x"
	self.cash_register.interact_distance = 110
	self.atm_interaction = deep_clone(self.invisible_interaction_open)
	self.atm_interaction.start_active = false
	self.atm_interaction.contour = "interactable_icon"
	self.bank_open_interaction = deep_clone(self.atm_interaction)
	self.bank_open_interaction.interact_distance = 90
	self.weapon_case = deep_clone(self.invisible_interaction_open)
	self.weapon_case.axis = "x"
	self.weapon_case.interact_distance = 110
	self.weapon_case_axis_z = deep_clone(self.invisible_interaction_open)
	self.weapon_case_axis_z.axis = "z"
	self.weapon_case_axis_z.interact_distance = 120
	self.weapon_case_close = deep_clone(self.weapon_case)
	self.weapon_case_close.text_id = "hud_int_invisible_interaction_close"
	self.invisible_interaction_close = deep_clone(self.invisible_interaction_open)
	self.invisible_interaction_close.text_id = "hud_int_invisible_interaction_close"
	self.interact_gen_pku_loot_take = {
		icon = "develop",
		text_id = "debug_interact_gen_pku_loot_take",
		timer = 2
	}
	self.water_tap = {
		icon = "develop",
		text_id = "debug_interact_water_tap",
		timer = 3,
		start_active = false,
		axis = "y"
	}
	self.water_manhole = {
		icon = "develop",
		text_id = "debug_interact_water_tap",
		timer = 3,
		start_active = false,
		axis = "z",
		interact_distance = 200
	}
	self.sewer_manhole = {
		icon = "develop",
		text_id = "debug_interact_sewer_manhole",
		timer = 3,
		start_active = false,
		interact_distance = 200,
		equipment_text_id = "debug_interact_equipment_crowbar"
	}
	self.circuit_breaker = {
		icon = "interaction_powerbox",
		text_id = "debug_interact_circuit_breaker",
		start_active = false,
		axis = "z"
	}
	self.circuit_breaker_off = {
		icon = "interaction_powerbox",
		text_id = "hud_int_hold_turn_off_power",
		start_active = false,
		axis = "z"
	}
	self.hold_circuit_breaker = deep_clone(self.circuit_breaker)
	self.hold_circuit_breaker.timer = 2
	self.hold_circuit_breaker.text_id = "hud_int_hold_turn_on_power"
	self.hold_circuit_breaker.action_text_id = "hud_action_turning_on_power"
	self.hold_circuit_breaker.axis = "y"
	self.transformer_box = {
		icon = "interaction_powerbox",
		text_id = "debug_interact_transformer_box",
		start_active = false,
		axis = "y",
		timer = 5,
		sound_start = "bar_power_box_loop",
		sound_interupt = "bar_power_box_cancel",
		sound_done = "bar_power_box_finished"
	}
	self.stash_server_cord = {
		icon = "interaction_powercord",
		text_id = "debug_interact_stash_server_cord",
		start_active = false,
		axis = "z"
	}
	self.stash_planks = {
		icon = "equipment_planks",
		contour = "interactable_icon",
		text_id = "debug_interact_stash_planks",
		start_active = false,
		timer = 2.5,
		equipment_text_id = "debug_interact_equipment_stash_planks",
		special_equipment = "planks",
		equipment_consume = true,
		sound_start = "bar_barricade_window",
		sound_interupt = "bar_barricade_window_cancel",
		sound_done = "bar_barricade_window_finished",
		action_text_id = "hud_action_barricading",
		axis = "z"
	}
	self.stash_planks_pickup = {
		icon = "equipment_planks",
		text_id = "debug_interact_stash_planks_pickup",
		start_active = false,
		timer = 2,
		axis = "z",
		special_equipment_block = "planks",
		sound_start = "bar_pick_up_planks",
		sound_interupt = "bar_pick_up_planks_cancel",
		sound_done = "bar_pick_up_planks_finished",
		action_text_id = "hud_action_grabbing_planks"
	}
	self.stash_server = {
		icon = "equipment_stash_server",
		text_id = "debug_interact_stash_server",
		timer = 2,
		start_active = false,
		axis = "z",
		equipment_text_id = "debug_interact_equipment_stash_server",
		special_equipment = "server",
		equipment_consume = true
	}
	self.stash_server_pickup = {
		icon = "equipment_stash_server",
		text_id = "hud_int_hold_take_hdd",
		timer = 1,
		start_active = false,
		axis = "z",
		special_equipment_block = "server",
		interact_distance = 250
	}
	self.shelf_sliding_suburbia = {
		icon = "develop",
		text_id = "debug_interact_move_bookshelf",
		start_active = false,
		timer = 3
	}
	self.tear_painting = {
		icon = "develop",
		text_id = "debug_interact_tear_painting",
		start_active = false,
		axis = "y"
	}
	self.ejection_seat_interact = {
		icon = "equipment_ejection_seat",
		text_id = "debug_interact_temp_interact_box",
		timer = 4
	}
	self.diamond_pickup = {
		icon = "interaction_diamond",
		text_id = "hud_int_take_jewelry",
		sound_event = "money_grab",
		start_active = false,
		requires_mask_off_upgrade = {
			upgrade = "mask_off_pickup",
			category = "player"
		}
	}
	self.diamond_pickup_pal = deep_clone(self.diamond_pickup)
	self.diamond_pickup_pal.interact_distance = 100
	self.safe_loot_pickup = deep_clone(self.diamond_pickup)
	self.safe_loot_pickup.start_active = true
	self.safe_loot_pickup.text_id = "hud_int_take"
	self.mus_pku_artifact = deep_clone(self.diamond_pickup)
	self.mus_pku_artifact.start_active = true
	self.mus_pku_artifact.text_id = "hud_int_take_artifact"
	self.tiara_pickup = {
		icon = "develop",
		text_id = "hud_int_pickup_tiara",
		sound_event = "money_grab",
		start_active = false
	}
	self.patientpaper_pickup = {
		icon = "interaction_patientfile",
		text_id = "debug_interact_patient_paper",
		timer = 2,
		start_active = false
	}
	self.diamond_case = {
		icon = "interaction_diamond",
		text_id = "debug_interact_diamond_case",
		start_active = false,
		axis = "x",
		interact_distance = 150
	}
	self.diamond_single_pickup = {
		icon = "interaction_diamond",
		text_id = "debug_interact_temp_interact_box_press",
		sound_event = "ammo_bag_drop",
		start_active = false
	}
	self.diamond_single_pickup_axis = {
		icon = "interaction_diamond",
		text_id = "debug_interact_temp_interact_box_press",
		sound_event = "ammo_bag_drop",
		axis = "x",
		start_active = false
	}
	self.suburbia_necklace_pickup = {
		icon = "interaction_diamond",
		text_id = "debug_interact_temp_interact_box_press",
		sound_event = "ammo_bag_drop",
		start_active = false,
		interact_distance = 100
	}
	self.temp_interact_box2 = {
		icon = "develop",
		text_id = "debug_interact_temp_interact_box",
		sound_event = "ammo_bag_drop",
		timer = 20
	}
	self.printing_plates = {
		icon = "develop",
		text_id = "hud_int_printing_plates"
	}
	self.c4 = {
		icon = "equipment_c4",
		text_id = "debug_interact_c4",
		timer = 4,
		sound_start = "bar_c4_apply",
		sound_interupt = "bar_c4_apply_cancel",
		sound_done = "bar_c4_apply_finished",
		action_text_id = "hud_action_placing_c4"
	}
	self.c4_mission_door = deep_clone(self.c4)
	self.c4_mission_door.special_equipment = "c4"
	self.c4_mission_door.equipment_text_id = "debug_interact_equipment_c4"
	self.c4_mission_door.equipment_consume = true
	self.c4_diffusible = {
		icon = "equipment_c4",
		text_id = "debug_c4_diffusible",
		timer = 4,
		sound_start = "bar_c4_apply",
		sound_interupt = "bar_c4_apply_cancel",
		sound_done = "bar_c4_apply_finished",
		axis = "z"
	}
	self.open_trunk = {
		icon = "develop",
		text_id = "debug_interact_open_trunk",
		timer = 0.5,
		axis = "x",
		action_text_id = "hud_action_opening_trunk"
	}
	self.open_door = {
		icon = "interaction_open_door",
		text_id = "debug_interact_open_door",
		interact_distance = 200
	}
	self.embassy_door = {
		start_active = false,
		icon = "interaction_open_door",
		text_id = "debug_interact_embassy_door",
		interact_distance = 150,
		timer = 5
	}
	self.c4_special = {
		icon = "equipment_c4",
		text_id = "debug_interact_c4",
		equipment_text_id = "debug_interact_equipment_c4",
		equipment_consume = true,
		timer = 4,
		sound_start = "bar_c4_apply",
		sound_interupt = "bar_c4_apply_cancel",
		sound_done = "bar_c4_apply_finished",
		axis = "z",
		action_text_id = "hud_action_placing_c4"
	}
	self.c4_bag = {
		text_id = "debug_interact_c4_bag",
		timer = 4,
		contour = "interactable",
		axis = "z",
		sound_start = "bar_bag_generic",
		sound_interupt = "bar_bag_generic_cancel",
		sound_done = "bar_bag_generic_finished"
	}
	self.money_wrap = {
		icon = "interaction_money_wrap",
		text_id = "debug_interact_money_wrap_take_money",
		start_active = false,
		timer = 3,
		action_text_id = "hud_action_taking_money",
		blocked_hint = "carry_block",
		sound_start = "bar_bag_money",
		sound_interupt = "bar_bag_money_cancel",
		sound_done = "bar_bag_money_finished"
	}
	self.money_wrap_axis = {
		icon = "interaction_money_wrap",
		text_id = "debug_interact_money_wrap_take_money",
		start_active = false,
		timer = 3,
		action_text_id = "hud_action_taking_money",
		blocked_hint = "carry_block",
		sound_start = "bar_bag_money",
		sound_interupt = "bar_bag_money_cancel",
		sound_done = "bar_bag_money_finished",
		axis = "y"
	}
	self.weapon_case_axis_x = deep_clone(self.money_wrap)
	self.weapon_case_axis_x.axis = "x"
	self.suburbia_money_wrap = {
		icon = "interaction_money_wrap",
		text_id = "debug_interact_money_printed_take_money",
		start_active = false,
		timer = 3,
		action_text_id = "hud_action_taking_money"
	}
	self.money_wrap_single_bundle = {
		icon = "interaction_money_wrap",
		text_id = "debug_interact_money_wrap_single_bundle_take_money",
		start_active = false,
		interact_distance = 110,
		requires_mask_off_upgrade = {
			upgrade = "mask_off_pickup",
			category = "player"
		}
	}
	self.christmas_present = {
		icon = "interaction_christmas_present",
		text_id = "debug_interact_take_christmas_present",
		start_active = true,
		interact_distance = 125
	}
	self.gold_pile = {
		icon = "interaction_gold",
		text_id = "debug_interact_gold_pile_take_money",
		start_active = false,
		timer = 1,
		action_text_id = "hud_action_taking_gold",
		blocked_hint = "carry_block"
	}
	self.gold_pile_axis_x = deep_clone(self.gold_pile)
	self.gold_pile_axis_x.axis = "x"
	self.gold_bag = {
		icon = "interaction_gold",
		text_id = "debug_interact_gold_bag",
		start_active = false,
		timer = 1,
		special_equipment_block = "gold_bag_equip",
		action_text_id = "hud_action_taking_gold"
	}
	self.requires_gold_bag = {
		icon = "interaction_gold",
		text_id = "debug_interact_requires_gold_bag",
		equipment_text_id = "debug_interact_equipment_requires_gold_bag",
		special_equipment = "gold_bag_equip",
		start_active = true,
		equipment_consume = true,
		timer = 1,
		sound_event = "ammo_bag_drop",
		axis = "x"
	}
	self.intimidate = {
		icon = "equipment_cable_ties",
		text_id = "debug_interact_intimidate",
		equipment_text_id = "debug_interact_equipment_cable_tie",
		start_active = false,
		special_equipment = "cable_tie",
		equipment_consume = true,
		no_contour = true,
		timer = 2,
		upgrade_timer_multiplier = {
			upgrade = "interact_speed_multiplier",
			category = "cable_tie"
		},
		action_text_id = "hud_action_cable_tying"
	}
	self.intimidate_and_search = {
		icon = "equipment_cable_ties",
		text_id = "debug_interact_intimidate",
		equipment_text_id = "debug_interact_search_key",
		start_active = false,
		special_equipment = "cable_tie",
		equipment_consume = true,
		dont_need_equipment = true,
		no_contour = true,
		timer = 3.5,
		action_text_id = "hud_action_cable_tying"
	}
	self.intimidate_with_contour = deep_clone(self.intimidate)
	self.intimidate_with_contour.no_contour = false
	self.intimidate_and_search_with_contour = deep_clone(self.intimidate_and_search)
	self.intimidate_and_search_with_contour.no_contour = false
	self.computer_test = {
		icon = "develop",
		text_id = "debug_interact_computer_test",
		start_active = false
	}
	self.carry_drop = {
		icon = "develop",
		text_id = "hud_int_hold_grab_the_bag",
		sound_event = "ammo_bag_drop",
		timer = 1,
		force_update_position = true,
		action_text_id = "hud_action_grabbing_bag",
		blocked_hint = "carry_block"
	}
	self.painting_carry_drop = {
		icon = "develop",
		text_id = "hud_int_hold_grab_the_painting",
		sound_event = "ammo_bag_drop",
		timer = 1,
		force_update_position = true,
		action_text_id = "hud_action_grabbing_painting",
		blocked_hint = "carry_block"
	}
	self.corpse_alarm_pager = {
		icon = "develop",
		text_id = "hud_int_disable_alarm_pager",
		sound_event = "ammo_bag_drop",
		timer = 10,
		force_update_position = true,
		action_text_id = "hud_action_disabling_alarm_pager",
		contour_preset = "generic_interactable",
		contour_preset_selected = "generic_interactable_selected",
		contour_flash_interval = 0.15,
		upgrade_timer_multiplier = {
			upgrade = "alarm_pager_speed_multiplier",
			category = "player"
		},
		interact_dont_interupt_on_distance = true
	}
	self.corpse_dispose = {
		icon = "develop",
		text_id = "hud_int_dispose_corpse",
		sound_event = "ammo_bag_drop",
		timer = 2,
		requires_upgrade = {
			upgrade = "corpse_dispose",
			category = "player"
		},
		upgrade_timer_multiplier = {
			upgrade = "corpse_dispose_speed_multiplier",
			category = "player"
		},
		action_text_id = "hud_action_disposing_corpse",
		no_contour = true
	}
	self.shaped_sharge = {
		icon = "equipment_c4",
		text_id = "hud_int_equipment_shaped_charge",
		contour = "interactable_icon",
		required_deployable = "trip_mine",
		deployable_consume = true,
		timer = 4,
		sound_start = "bar_c4_apply",
		sound_interupt = "bar_c4_apply_cancel",
		sound_done = "bar_c4_apply_finished",
		action_text_id = "hud_action_placing_shaped_charge",
		slot = 2,
		blocked_hint = ""
	}
	self.shaped_charge_single = deep_clone(self.shaped_sharge)
	self.shaped_charge_single.axis = "z"
	self.hostage_convert = {
		icon = "develop",
		text_id = "hud_int_hostage_convert",
		sound_event = "ammo_bag_drop",
		blocked_hint = "convert_enemy_failed",
		timer = 1.5,
		requires_upgrade = {
			upgrade = "convert_enemies",
			category = "player"
		},
		upgrade_timer_multiplier = {
			upgrade = "convert_enemies_interaction_speed_multiplier",
			category = "player"
		},
		action_text_id = "hud_action_converting_hostage",
		no_contour = true
	}
	self.break_open = {
		icon = "develop",
		text_id = "hud_int_break_open",
		start_active = false
	}
	self.cut_fence = {
		text_id = "hud_int_hold_cut_fence",
		action_text_id = "hud_action_cutting_fence",
		contour = "interactable_icon",
		timer = 0.5,
		start_active = true,
		sound_start = "bar_cut_fence",
		sound_interupt = "bar_cut_fence_cancel",
		sound_done = "bar_cut_fence_finished"
	}
	self.burning_money = {
		text_id = "hud_int_hold_ignite_money",
		action_text_id = "hud_action_igniting_money",
		timer = 2,
		start_active = false,
		interact_distance = 250
	}
	self.hold_take_painting = {
		text_id = "hud_int_hold_take_painting",
		action_text_id = "hud_action_taking_painting",
		start_active = false,
		axis = "y",
		timer = 2,
		sound_start = "bar_steal_painting",
		sound_interupt = "bar_steal_painting_cancel",
		sound_done = "bar_steal_painting_finished",
		blocked_hint = "carry_block"
	}
	self.barricade_fence = deep_clone(self.stash_planks)
	self.barricade_fence.contour = "interactable_icon"
	self.barricade_fence.sound_start = "bar_barricade_fence"
	self.barricade_fence.sound_interupt = "bar_barricade_fence_cancel"
	self.barricade_fence.sound_done = "bar_barricade_fence_finished"
	self.hack_numpad = {
		text_id = "hud_int_hold_hack_numpad",
		action_text_id = "hud_action_hacking_numpad",
		start_active = false,
		timer = 15
	}
	self.pickup_phone = {
		text_id = "hud_int_pickup_phone",
		start_active = false
	}
	self.pickup_tablet = deep_clone(self.pickup_phone)
	self.pickup_tablet.text_id = "hud_int_pickup_tablet"
	self.hold_take_server = {
		text_id = "hud_int_hold_take_server",
		action_text_id = "hud_action_taking_server",
		timer = 4,
		sound_start = "bar_steal_circuit",
		sound_interupt = "bar_steal_circuit_cancel",
		sound_done = "bar_steal_circuit_finished"
	}
	self.hold_take_server_axis = deep_clone(self.hold_take_server)
	self.hold_take_server_axis.axis = "y"
	self.hold_take_blueprints = {
		text_id = "hud_int_hold_take_blueprints",
		action_text_id = "hud_action_taking_blueprints",
		start_active = false,
		timer = 0.5,
		sound_start = "bar_steal_painting",
		sound_interupt = "bar_steal_painting_cancel",
		sound_done = "bar_steal_painting_finished"
	}
	self.take_confidential_folder = {
		text_id = "hud_int_take_confidential_folder",
		start_active = false
	}
	self.take_confidential_folder_event = {
		text_id = "hud_int_take_confidential_folder_event",
		start_active = false,
		timer = 1
	}
	self.hold_take_gas_can = {
		text_id = "hud_int_hold_take_gas",
		action_text_id = "hud_action_taking_gasoline",
		start_active = false,
		timer = 0.5,
		special_equipment_block = "gas"
	}
	self.gen_ladyjustice_statue = {
		text_id = "hud_int_ladyjustice_statue"
	}
	self.hold_place_gps_tracker = {
		text_id = "hud_int_hold_place_gps_tracker",
		action_text_id = "hud_action_placing_gps_tracker",
		contour = "interactable_icon",
		start_active = false,
		timer = 1.5,
		interact_distance = 200
	}
	self.keyboard_no_time = deep_clone(self.security_station_keyboard)
	self.keyboard_no_time.timer = 2.5
	self.keyboard_eday_1 = deep_clone(self.security_station_keyboard)
	self.keyboard_eday_1.timer = 2.5
	self.keyboard_eday_1.text_id = "hud_int_keyboard_eday_1"
	self.keyboard_eday_2 = deep_clone(self.security_station_keyboard)
	self.keyboard_eday_2.timer = 2.5
	self.keyboard_eday_2.text_id = "hud_int_keyboard_eday_2"
	self.keyboard_hox_1 = deep_clone(self.security_station_keyboard)
	self.keyboard_hox_1.timer = 2.5
	self.keyboard_hox_1.text_id = "hud_int_keyboard_hox_1"
	self.keyboard_hox_1.action_text_id = "hud_action_keyboard_hox_1"
	self.hold_use_computer = {
		start_active = false,
		text_id = "hud_int_hold_use_computer",
		action_text_id = "hud_action_using_computer",
		timer = 1,
		axis = "z",
		interact_distance = 100
	}
	self.use_server_device = {
		text_id = "hud_int_hold_use_device",
		action_text_id = "hud_action_using_device",
		timer = 1,
		start_active = false
	}
	self.iphone_answer = {
		text_id = "hud_int_answer_phone",
		start_active = false
	}
	self.use_flare = {
		text_id = "hud_int_use_flare",
		start_active = false
	}
	self.steal_methbag = {
		text_id = "hud_int_hold_steal_meth",
		action_text_id = "hud_action_stealing_meth",
		start_active = true,
		timer = 3
	}
	self.pickup_keycard = {
		text_id = "hud_int_pickup_keycard",
		sound_done = "pick_up_key_card",
		requires_mask_off_upgrade = {
			upgrade = "mask_off_pickup",
			category = "player"
		},
		blocked_hint = "full_keycard"
	}
	self.open_from_inside = {
		text_id = "hud_int_invisible_interaction_open",
		start_active = true,
		interact_distance = 100,
		timer = 0.2,
		axis = "x"
	}
	self.open_hatch_generic = {
		text_id = "hud_int_invisible_interaction_open",
		start_active = true,
		interact_distance = 100,
		timer = 0.2
	}
	self.money_luggage = deep_clone(self.money_wrap)
	self.money_luggage.start_active = true
	self.money_luggage.axis = "x"
	self.hold_pickup_lance = {
		text_id = "hud_int_hold_pickup_lance",
		action_text_id = "hud_action_grabbing_lance",
		sound_event = "ammo_bag_drop",
		timer = 1
	}
	self.barrier_numpad = {
		text_id = "hud_int_barrier_numpad",
		start_active = false,
		axis = "z"
	}
	self.timelock_numpad = {
		text_id = "hud_int_timelock_numpad",
		start_active = false,
		axis = "z"
	}
	self.pickup_asset = {
		text_id = "hud_int_pickup_asset",
		sound_event = "ammo_bag_drop"
	}
	self.open_slash_close = {
		text_id = "hud_int_press_interaction_open",
		start_active = false,
		axis = "y",
		interact_distance = 200
	}
	self.open_slash_close_act = {
		text_id = "hud_int_open_slash_close",
		action_text_id = "hud_action_open_slash_close",
		timer = 1,
		start_active = true
	}
	self.just_close = deep_clone(self.open_slash_close)
	self.just_close.text_id = "hud_int_press_interaction_close"
	self.raise_balloon = {
		text_id = "hud_int_hold_raise_balloon",
		action_text_id = "hud_action_raise_balloon",
		start_active = false,
		timer = 2,
		sound_start = "bar_winch_box_start",
		sound_interupt = "bar_winch_box_cancel",
		sound_done = "bar_winch_box_finish"
	}
	self.stn_int_place_camera = {
		text_id = "hud_int_place_camera",
		start_active = true
	}
	self.stn_int_take_camera = {
		text_id = "hud_int_take_camera",
		start_active = true
	}
	self.exit_to_crimenet = {
		text_id = "hud_int_exit_to_crimenet",
		start_active = false,
		timer = 0.5
	}
	self.gage_assignment = {
		icon = "develop",
		text_id = "debug_interact_gage_assignment_take",
		start_active = true,
		timer = 1,
		action_text_id = "hud_action_taking_gage_assignment",
		blocked_hint = "hint_gage_mods_dlc_block"
	}
	self.gen_pku_fusion_reactor = {
		text_id = "hud_int_hold_take_reaktor",
		action_text_id = "hud_action_taking_reaktor",
		blocked_hint = "carry_block",
		start_active = false,
		timer = 3,
		no_contour = true,
		sound_start = "bar_bag_money",
		sound_interupt = "bar_bag_money_cancel",
		sound_done = "bar_bag_money_finished"
	}
	self.gen_pku_cocaine = {
		text_id = "hud_int_hold_take_cocaine",
		action_text_id = "hud_action_taking_cocaine",
		timer = 3,
		sound_start = "bar_bag_money",
		sound_interupt = "bar_bag_money_cancel",
		sound_done = "bar_bag_money_finished",
		blocked_hint = "carry_block"
	}
	self.gen_pku_artifact_statue = {
		text_id = "hud_int_hold_take_artifact",
		action_text_id = "hud_action_taking_artifact",
		timer = 3,
		start_active = false,
		sound_start = "bar_bag_money",
		sound_interupt = "bar_bag_money_cancel",
		sound_done = "bar_bag_money_finished",
		blocked_hint = "carry_block"
	}
	self.gen_pku_artifact = deep_clone(self.gen_pku_artifact_statue)
	self.gen_pku_artifact.start_active = true
	self.gen_pku_artifact.sound_start = "bar_bag_armor"
	self.gen_pku_artifact.sound_interupt = "bar_bag_armor_cancel"
	self.gen_pku_artifact.sound_done = "bar_bag_armor_finished"
	self.gen_pku_artifact_painting = deep_clone(self.gen_pku_artifact_statue)
	self.gen_pku_artifact_painting.start_active = true
	self.gen_pku_artifact_painting.sound_start = "bar_steal_painting"
	self.gen_pku_artifact_painting.sound_interupt = "bar_steal_painting_cancel"
	self.gen_pku_artifact_painting.sound_done = "bar_steal_painting_finished"
	self.gen_pku_jewelry = {
		text_id = "hud_int_hold_take_jewelry",
		action_text_id = "hud_action_taking_jewelry",
		timer = 3,
		sound_start = "bar_bag_jewelry",
		sound_interupt = "bar_bag_jewelry_cancel",
		sound_done = "bar_bag_jewelry_finished",
		blocked_hint = "carry_block"
	}
	self.taking_meth = {
		text_id = "hud_int_hold_take_meth",
		action_text_id = "hud_action_taking_meth",
		timer = 3,
		sound_start = "bar_bag_money",
		sound_interupt = "bar_bag_money_cancel",
		sound_done = "bar_bag_money_finished",
		blocked_hint = "carry_block"
	}
	self.gen_pku_crowbar = {
		text_id = "hud_int_take_crowbar",
		special_equipment_block = "crowbar",
		sound_done = "pick_up_crowbar",
		requires_mask_off_upgrade = {
			upgrade = "mask_off_pickup",
			category = "player"
		}
	}
	self.gen_pku_crowbar_stack = {
		text_id = "hud_int_take_crowbar",
		special_equipment_block = "crowbar_stack",
		sound_done = "pick_up_crowbar",
		requires_mask_off_upgrade = {
			upgrade = "mask_off_pickup",
			category = "player"
		}
	}
	self.gen_pku_thermite = {
		text_id = "hud_int_take_thermite",
		special_equipment_block = "thermite"
	}
	self.gen_pku_thermite_paste = {
		text_id = "hud_int_take_thermite_paste",
		special_equipment_block = "thermite_paste",
		contour = "deployable",
		sound_done = "pick_up_thermite"
	}
	self.gen_pku_thermite_paste_not_deployable = {
		text_id = "hud_int_take_thermite_paste",
		special_equipment_block = "thermite_paste",
		sound_done = "pick_up_thermite"
	}
	self.button_infopad = {
		text_id = "hud_int_press_for_info",
		start_active = false,
		axis = "z"
	}
	self.crate_loot = {
		text_id = "hud_int_hold_crack_crate",
		action_text_id = "hud_action_cracking_crate",
		timer = 2,
		start_active = false,
		sound_start = "bar_open_crate",
		sound_interupt = "bar_open_crate_cancel",
		sound_done = "bar_open_crate_finished"
	}
	self.crate_loot_crowbar = deep_clone(self.crate_loot)
	self.crate_loot_crowbar.equipment_text_id = "debug_interact_equipment_crowbar"
	self.crate_loot_crowbar.special_equipment = "crowbar"
	self.crate_loot_crowbar.sound_start = "bar_crowbar"
	self.crate_loot_crowbar.sound_interupt = "bar_crowbar_cancel"
	self.crate_loot_crowbar.sound_done = "bar_crowbar_end"
	self.weapon_case_not_active = deep_clone(self.weapon_case)
	self.weapon_case_not_active.start_active = false
	self.crate_weapon_crowbar = deep_clone(self.weapon_case)
	self.crate_weapon_crowbar.equipment_text_id = "debug_interact_equipment_crowbar"
	self.crate_weapon_crowbar.timer = 2
	self.crate_weapon_crowbar.start_active = false
	self.crate_weapon_crowbar.special_equipment = "crowbar"
	self.crate_weapon_crowbar.sound_start = "bar_crowbar_plastic"
	self.crate_weapon_crowbar.sound_interupt = "bar_crowbar_plastic_cancel"
	self.crate_weapon_crowbar.sound_done = "bar_crowbar_plastic_finished"
	self.crate_loot_close = {
		text_id = "hud_int_hold_close_crate",
		action_text_id = "hud_action_closing_crate",
		timer = 2,
		start_active = false,
		sound_start = "bar_close_crate",
		sound_interupt = "bar_close_crate_cancel",
		sound_done = "bar_close_crate_finished"
	}
	self.halloween_trick = {
		text_id = "hud_int_trick_treat"
	}
	self.disassemble_turret = {
		text_id = "hud_int_hold_disassemble_turret",
		action_text_id = "hud_action_disassemble_turret",
		blocked_hint = "carry_block",
		start_active = false,
		timer = 3,
		sound_start = "bar_steal_circuit",
		sound_interupt = "bar_steal_circuit_cancel",
		sound_done = "bar_steal_circuit_finished"
	}
	self.take_ammo = {
		text_id = "hud_int_hold_pack_shells",
		action_text_id = "hud_action_packing_shells",
		blocked_hint = "carry_block",
		start_active = false,
		timer = 2
	}
	self.bank_note = {
		text_id = "hud_int_bank_note",
		start_active = false,
		timer = 3
	}
	self.pickup_boards = {
		text_id = "hud_int_hold_pickup_boards",
		action_text_id = "hud_action_picking_up",
		start_active = false,
		timer = 2,
		axis = "z",
		special_equipment_block = "boards",
		sound_start = "bar_pick_up_planks",
		sound_interupt = "bar_pick_up_planks_cancel",
		sound_done = "bar_pick_up_planks_finished"
	}
	self.need_boards = {
		contour = "interactable_icon",
		text_id = "debug_interact_stash_planks",
		action_text_id = "hud_action_barricading",
		start_active = false,
		timer = 2.5,
		equipment_text_id = "hud_equipment_need_boards",
		special_equipment = "boards",
		equipment_consume = true,
		sound_start = "bar_barricade_window",
		sound_interupt = "bar_barricade_window_cancel",
		sound_done = "bar_barricade_window_finished",
		axis = "z"
	}
	self.uload_database = {
		text_id = "hud_int_hold_use_computer",
		action_text_id = "hud_action_using_computer",
		timer = 4,
		start_active = false,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished",
		axis = "x",
		contour = "contour_off"
	}
	self.uload_database_jammed = {
		text_id = "hud_int_hold_resume_upload",
		action_text_id = "hud_action_resuming_upload",
		timer = 1,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished",
		axis = "x"
	}
	self.votingmachine2 = {
		text_id = "debug_interact_hack_ipad",
		timer = 5,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.votingmachine2_jammed = {
		text_id = "debug_interact_hack_ipad_jammed",
		timer = 5,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.sc_tape_loop = {
		icon = "interaction_help",
		text_id = "hud_int_tape_loop",
		start_active = true,
		interact_distance = 150,
		no_contour = true,
		timer = 4,
		action_text_id = "hud_action_tape_looping",
		requires_upgrade = {
			upgrade = "tape_loop_duration",
			category = "player"
		}
	}
	self.money_scanner = deep_clone(self.invisible_interaction_open)
	self.money_scanner.axis = "y"
	self.money_small = deep_clone(self.money_wrap)
	self.money_small.sound_start = "bar_bag_pour_money"
	self.money_small.sound_interupt = "bar_bag_pour_money_cancel"
	self.money_small.sound_done = "bar_bag_pour_money_finished"
	self.money_small_take = deep_clone(self.money_small)
	self.money_small_take.text_id = "debug_interact_money_printed_take_money"
	self.shape_charge_plantable = {
		text_id = "debug_interact_c4",
		action_text_id = "hud_action_placing_c4",
		equipment_text_id = "debug_interact_equipment_c4",
		special_equipment = "c4",
		equipment_consume = true,
		axis = "z",
		timer = 4,
		sound_start = "bar_c4_apply",
		sound_interupt = "bar_c4_apply_cancel",
		sound_done = "bar_c4_apply_finished"
	}
	self.player_zipline = {
		text_id = "hud_int_use_zipline"
	}
	self.bag_zipline = {
		text_id = "hud_int_bag_zipline"
	}
	self.huge_lance = {
		text_id = "hud_int_equipment_huge_lance",
		action_text_id = "hud_action_placing_huge_lance",
		timer = 3,
		sound_start = "bar_huge_lance_fix",
		sound_interupt = "bar_huge_lance_fix_cancel",
		sound_done = "bar_huge_lance_fix_finished"
	}
	self.huge_lance_jammed = {
		text_id = "hud_int_equipment_huge_lance_jammed",
		action_text_id = "hud_action_fixing_huge_lance",
		special_equipment = "lance_part",
		equipment_text_id = "hud_int_equipment_no_lance_part",
		blocked_hint = "no_huge_lance",
		equipment_consume = true,
		timer = 10,
		sound_start = "bar_huge_lance_fix",
		sound_interupt = "bar_huge_lance_fix_cancel",
		sound_done = "bar_huge_lance_fix_finished"
	}
	self.gen_pku_lance_part = {
		text_id = "hud_int_take_lance_part",
		special_equipment_block = "lance_part",
		sound_done = "drill_fix_end"
	}
	self.crane_joystick_left = {
		text_id = "hud_int_crane_left",
		start_active = false
	}
	self.crane_joystick_lift = {
		text_id = "hud_int_crane_lift",
		start_active = false
	}
	self.crane_joystick_right = {
		text_id = "hud_int_crane_right",
		start_active = false
	}
	self.crane_joystick_release = {
		text_id = "hud_int_crane_release",
		start_active = false
	}
	self.gen_int_thermite_rig = {
		text_id = "hud_int_hold_assemble_thermite",
		action_text_id = "hud_action_assemble_thermite",
		special_equipment = "thermite",
		equipment_text_id = "debug_interact_equipment_thermite",
		equipment_consume = true,
		contour = "interactable_icon",
		timer = 20,
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished"
	}
	self.gen_int_thermite_apply = {
		text_id = "hud_int_hold_ignite_thermite",
		action_text_id = "hud_action_ignite_thermite",
		contour = "interactable_icon",
		timer = 2,
		sound_start = "bar_thermal_lance_fix",
		sound_interupt = "bar_thermal_lance_fix_cancel",
		sound_done = "bar_thermal_lance_fix_finished"
	}
	self.apply_thermite_paste = {
		text_id = "hud_int_hold_ignite_thermite_paste",
		action_text_id = "hud_action_ignite_thermite_paste",
		special_equipment = "thermite_paste",
		equipment_text_id = "hud_int_need_thermite_paste",
		equipment_consume = true,
		start_active = false,
		contour = "interactable_icon",
		timer = 2,
		sound_start = "bar_thermal_lance_fix",
		sound_interupt = "bar_thermal_lance_fix_cancel",
		sound_done = "bar_thermal_lance_fix_finished"
	}
	self.set_off_alarm = {
		text_id = "hud_int_set_off_alarm",
		action_text_id = "hud_action_setting_off_alarm",
		timer = 0.5,
		start_active = false
	}
	self.hold_open_vault = {
		text_id = "hud_int_hold_open_vault",
		action_text_id = "hud_action_opening_vault",
		timer = 4,
		axis = "y",
		start_active = false
	}
	self.hold_open_vault_2s = {
		text_id = "hud_int_hold_open_vault",
		action_text_id = "hud_action_opening_vault",
		timer = 2,
		axis = "y",
		start_active = false
	}
	self.samurai_armor = {
		text_id = "hud_int_hold_bag_sa_armor",
		action_text_id = "hud_action_bagging_sa_armor",
		blocked_hint = "carry_block",
		start_active = false,
		timer = 3,
		sound_start = "bar_bag_armor",
		sound_interupt = "bar_bag_armor_cancel",
		sound_done = "bar_bag_armor_finished"
	}
	self.fingerprint_scanner = {
		text_id = "hud_int_use_scanner",
		start_active = false
	}
	self.enter_code = {
		text_id = "hud_int_enter_code",
		action_text_id = "hud_action_enter_code",
		timer = 1,
		start_active = false,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.take_keys = {
		text_id = "hud_int_take_keys"
	}
	self.push_button = {
		text_id = "hud_int_push_button",
		axis = "z"
	}
	self.use_chute = {
		text_id = "hud_int_use_chute",
		axis = "z"
	}
	self.breach_door = {
		text_id = "debug_interact_crowbar",
		action_text_id = "hud_action_breaching_door",
		start_active = false,
		timer = 2,
		sound_start = "bar_pry_open_elevator_door",
		sound_interupt = "bar_pry_open_elevator_door_cancel",
		sound_done = "bar_pry_open_elevator_door_finished"
	}
	self.bus_wall_phone = {
		text_id = "hud_int_use_phone_signal_bus",
		start_active = false
	}
	self.zipline_mount = {
		text_id = "hud_int_setup_zipline",
		action_text_id = "hud_action_setting_zipline",
		start_active = false,
		timer = 2,
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished"
	}
	self.rewire_timelock = deep_clone(self.security_station)
	self.rewire_timelock.text_id = "hud_int_rewire_timelock"
	self.rewire_timelock.action_text_id = "hud_action_rewiring_timelock"
	self.rewire_timelock.axis = "x"
	self.rewire_timelock.sound_start = "bar_wire_cut"
	self.rewire_timelock.sound_interupt = "bar_wire_cut_cancel"
	self.rewire_timelock.sound_done = "bar_wire_cut_finished"
	self.pick_lock_x_axis = deep_clone(self.pick_lock_hard_no_skill)
	self.pick_lock_x_axis.axis = "x"
	self.money_wrap_single_bundle_active = deep_clone(self.money_wrap_single_bundle)
	self.money_wrap_single_bundle_active.start_active = true
	self.pku_barcode_downtown = {
		text_id = "hud_int_hold_barcode",
		action_text_id = "hud_action_barcode",
		special_equipment_block = {
			"barcode_downtown",
			"barcode_brickell",
			"barcode_edgewater",
			"barcode_isles_beach",
			"barcode_opa_locka"
		},
		timer = 2
	}
	self.pku_barcode_brickell = deep_clone(self.pku_barcode_downtown)
	self.pku_barcode_brickell.special_equipment_block = {
		"barcode_downtown",
		"barcode_brickell",
		"barcode_edgewater",
		"barcode_isles_beach",
		"barcode_opa_locka"
	}
	self.pku_barcode_edgewater = deep_clone(self.pku_barcode_downtown)
	self.pku_barcode_edgewater.special_equipment_block = {
		"barcode_downtown",
		"barcode_brickell",
		"barcode_edgewater",
		"barcode_isles_beach",
		"barcode_opa_locka"
	}
	self.pku_barcode_isles_beach = deep_clone(self.pku_barcode_downtown)
	self.pku_barcode_isles_beach.special_equipment_block = {
		"barcode_downtown",
		"barcode_brickell",
		"barcode_edgewater",
		"barcode_isles_beach",
		"barcode_opa_locka"
	}
	self.pku_barcode_opa_locka = deep_clone(self.pku_barcode_downtown)
	self.pku_barcode_opa_locka.special_equipment_block = {
		"barcode_downtown",
		"barcode_brickell",
		"barcode_edgewater",
		"barcode_isles_beach",
		"barcode_opa_locka"
	}
	self.read_barcode_downtown = {
		text_id = "hud_int_hold_read_barcode",
		action_text_id = "hud_action_read_barcode",
		special_equipment = "barcode_downtown",
		dont_need_equipment = false,
		possible_special_equipment = {
			"barcode_downtown",
			"barcode_brickell",
			"barcode_edgewater",
			"barcode_isles_beach",
			"barcode_opa_locka"
		},
		equipment_text_id = "hud_equipment_need_barcode",
		equipment_consume = true,
		start_active = false,
		timer = 2
	}
	self.read_barcode_brickell = {
		text_id = "hud_int_hold_read_barcode",
		action_text_id = "hud_action_read_barcode",
		special_equipment = "barcode_brickell",
		dont_need_equipment = false,
		possible_special_equipment = {
			"barcode_downtown",
			"barcode_brickell",
			"barcode_edgewater",
			"barcode_isles_beach",
			"barcode_opa_locka"
		},
		equipment_text_id = "hud_equipment_need_barcode",
		equipment_consume = true,
		start_active = false,
		timer = 2
	}
	self.read_barcode_edgewater = {
		text_id = "hud_int_hold_read_barcode",
		action_text_id = "hud_action_read_barcode",
		special_equipment = "barcode_edgewater",
		dont_need_equipment = false,
		possible_special_equipment = {
			"barcode_downtown",
			"barcode_brickell",
			"barcode_edgewater",
			"barcode_isles_beach",
			"barcode_opa_locka"
		},
		equipment_text_id = "hud_equipment_need_barcode",
		equipment_consume = true,
		start_active = false,
		timer = 2
	}
	self.read_barcode_isles_beach = {
		text_id = "hud_int_hold_read_barcode",
		action_text_id = "hud_action_read_barcode",
		special_equipment = "barcode_isles_beach",
		dont_need_equipment = false,
		possible_special_equipment = {
			"barcode_downtown",
			"barcode_brickell",
			"barcode_edgewater",
			"barcode_isles_beach",
			"barcode_opa_locka"
		},
		equipment_text_id = "hud_equipment_need_barcode",
		equipment_consume = true,
		start_active = false,
		timer = 2
	}
	self.read_barcode_opa_locka = {
		text_id = "hud_int_hold_read_barcode",
		action_text_id = "hud_action_read_barcode",
		special_equipment = "barcode_opa_locka",
		dont_need_equipment = false,
		possible_special_equipment = {
			"barcode_downtown",
			"barcode_brickell",
			"barcode_edgewater",
			"barcode_isles_beach",
			"barcode_opa_locka"
		},
		equipment_text_id = "hud_equipment_need_barcode",
		equipment_consume = true,
		start_active = false,
		timer = 2
	}
	self.read_barcode_activate = {
		text_id = "hud_int_hold_activate_reader",
		action_text_id = "hud_action_activating_reader",
		start_active = false,
		timer = 2
	}
	self.hlm_motor_start = {
		text_id = "hud_int_hold_start_motor",
		action_text_id = "hud_action_startig_motor",
		start_active = false,
		force_update_position = true,
		timer = 2,
		sound_start = "bar_huge_lance_fix",
		sound_interupt = "bar_huge_lance_fix_cancel",
		sound_done = "bar_huge_lance_fix_finished"
	}
	self.hlm_connect_equip = {
		text_id = "hud_int_hold_connect_equip",
		action_text_id = "hud_action_connecting_equip",
		start_active = false,
		timer = 2
	}
	self.hlm_roll_carpet = {
		text_id = "hud_int_hold_roll_carpet",
		action_text_id = "hud_action_rolling_carpet",
		start_active = false,
		timer = 2,
		sound_start = "bar_roll_carpet",
		sound_interupt = "bar_roll_carpet_cancel",
		sound_done = "bar_roll_carpet_finished"
	}
	self.hold_pku_equipmentbag = {
		text_id = "hud_int_hold_pku_equipment",
		action_text_id = "hud_action_grabbing_equipment",
		sound_event = "ammo_bag_drop",
		timer = 1
	}
	self.hold_pku_briefcase = {
		text_id = "hud_int_hold_pku_briefcase",
		sound_event = "ammo_bag_drop",
		timer = 1
	}
	self.disarm_bomb = {
		text_id = "hud_int_hold_disarm_bomb",
		action_text_id = "hud_action_disarm_bomb",
		start_active = false,
		timer = 2.5
	}
	self.pku_take_mask = {
		text_id = "hud_int_take_mask",
		start_active = true
	}
	self.hold_activate_sprinklers = {
		text_id = "hud_int_hold_activate_sprinklers",
		action_text_id = "hud_action_activating_sprinklers",
		start_active = false,
		timer = 0.5,
		sound_start = "bar_thermal_lance_apply",
		sound_interupt = "bar_thermal_lance_apply_cancel",
		sound_done = "bar_thermal_lance_apply_finished"
	}
	self.hold_hlm_open_circuitbreaker = {
		text_id = "hud_int_hold_open_circuitbreaker",
		action_text_id = "hud_action_opening_circuitbreaker",
		start_active = false,
		timer = 0.5
	}
	self.hold_remove_cover = {
		text_id = "hud_int_hold_remove_cover",
		action_text_id = "hud_action_removing_cover",
		start_active = false,
		timer = 0.5
	}
	self.hold_cut_cable = {
		text_id = "hud_int_hold_cut_cable",
		action_text_id = "hud_action_cutting_cable",
		start_active = false,
		timer = 0.5,
		sound_start = "bar_cut_fence",
		sound_interupt = "bar_cut_fence_cancel",
		sound_done = "bar_cut_fence_finished"
	}
	self.firstaid_box = deep_clone(self.doctor_bag)
	self.firstaid_box.start_active = false
	self.first_aid_kit = {
		icon = "equipment_first_aid_kit",
		text_id = "debug_interact_doctor_bag_heal",
		contour = "deployable",
		timer = 0.5,
		blocked_hint = "full_health",
		sound_start = "bar_helpup",
		sound_interupt = "bar_helpup_cancel",
		sound_done = "bar_helpup_finished",
		action_text_id = "hud_action_healing"
	}
	self.road_spikes = {
		text_id = "hud_int_remove_stinger",
		action_text_id = "hud_action_removing_stinger",
		timer = 2,
		axis = "z",
		start_active = false,
		sound_start = "bar_roadspike",
		sound_interupt = "bar_roadspike_cancel",
		sound_done = "bar_roadspike_finished"
	}
	self.grab_server = {
		text_id = "hud_int_grab_server",
		action_text_id = "hud_action_grab_server",
		timer = 3,
		sound_start = "bar_bag_money",
		sound_interupt = "bar_bag_money_cancel",
		sound_done = "bar_bag_money_finished"
	}
	self.pickup_harddrive = {
		text_id = "hud_int_take_harddrive",
		action_text_id = "hud_action_take_harddrive",
		special_equipment_block = "harddrive",
		timer = 1
	}
	self.place_harddrive = {
		text_id = "hud_int_place_harddrive",
		action_text_id = "hud_action_place_harddrive",
		equipment_text_id = "hud_equipment_need_harddrive",
		special_equipment = "harddrive",
		equipment_consume = true,
		timer = 1
	}
	self.invisible_interaction_searching = {
		text_id = "hud_int_search_files",
		action_text_id = "hud_action_searching_files",
		timer = 4.5,
		axis = "x",
		contour = "interactable_icon",
		special_equipment_block = "files",
		interact_distance = 200,
		start_active = false,
		sound_start = "bar_shuffle_papers",
		sound_interupt = "bar_shuffle_papers_cancel",
		sound_done = "bar_shuffle_papers_finished"
	}
	self.invisible_interaction_gathering = {
		text_id = "hud_int_hold_gather_evidence",
		action_text_id = "hud_action_gathering_evidence",
		timer = 2,
		special_equipment_block = "evidence",
		start_active = false
	}
	self.invisible_interaction_checking = {
		text_id = "hud_int_hold_check_evidence",
		action_text_id = "hud_action_checking_evidence",
		equipment_text_id = "hud_equipment_need_evidence",
		special_equipment = "evidence",
		equipment_consume = true,
		timer = 2,
		start_active = false
	}
	self.take_medical_supplies = {
		text_id = "hud_int_take_supplies",
		action_text_id = "hud_int_taking_supplies",
		timer = 2
	}
	self.search_files_false = {
		text_id = "hud_int_search_files",
		action_text_id = "hud_action_searching_files",
		timer = 4.5,
		axis = "x",
		contour = "interactable_icon",
		interact_distance = 200,
		sound_start = "bar_shuffle_papers",
		sound_interupt = "bar_shuffle_papers_cancel",
		sound_done = "bar_shuffle_papers_finished"
	}
	self.use_files = {
		text_id = "hud_int_use_files",
		action_text_id = "hud_action_use_files",
		equipment_text_id = "hud_equipment_need_files",
		special_equipment = "files",
		equipment_consume = true,
		timer = 1,
		contour = "interactable_icon",
		interact_distance = 200
	}
	self.hack_electric_box = {
		text_id = "hud_int_hack_box",
		action_text_id = "hud_action_hack_box",
		timer = 6,
		start_active = false,
		axis = "y",
		sound_start = "bar_hack_fuse_box",
		sound_interupt = "bar_hack_fuse_box_cancel",
		sound_done = "bar_hack_fuse_box_finished"
	}
	self.take_ticket = {
		text_id = "hud_int_take_ticket",
		action_text_id = "hud_action_take_ticket",
		icon = "equipment_crowbar",
		timer = 3,
		special_equipment_block = "ticket",
		start_active = false,
		sound_start = "bar_ticket",
		sound_interupt = "bar_ticket_cancel",
		sound_done = "bar_ticket_finished"
	}
	self.use_ticket = {
		text_id = "hud_int_use_ticket",
		action_text_id = "hud_action_use_ticket",
		equipment_text_id = "hud_equipment_use_ticket",
		equipment_consume = true,
		timer = 3,
		special_equipment = "ticket",
		sound_start = "bar_ticket",
		sound_interupt = "bar_ticket_cancel",
		sound_done = "bar_ticket_finished"
	}
	self.hold_signal_driver = {
		text_id = "hud_int_signal_driver",
		action_text_id = "hud_action_signaling_driver",
		start_active = false,
		force_update_position = true,
		axis = "z",
		timer = 1.5,
		interact_distance = 500,
		sound_start = "bar_car_tap",
		sound_interupt = "bar_car_tap_cancel",
		sound_done = "bar_car_tap_finished"
	}
	self.hold_hack_comp = {
		text_id = "hud_int_hold_hack_computer",
		action_text_id = "hud_action_hacking_computer",
		start_active = false,
		axis = "z",
		timer = 1
	}
	self.hold_approve_req = {
		text_id = "hud_int_hold_approve_request",
		action_text_id = "hud_action_approving_request",
		start_active = false,
		axis = "z",
		timer = 1
	}
	self.hold_download_keys = {
		text_id = "hud_int_hold_download_keys",
		action_text_id = "hud_action_downloading_keys",
		start_active = false,
		axis = "z",
		timer = 5,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.hold_analyze_evidence = {
		text_id = "hud_int_hold_analyze_evidence",
		action_text_id = "hud_action_analyzing_evidence",
		start_active = false,
		axis = "z",
		timer = 1
	}
	self.take_bridge = {
		text_id = "hud_int_take_bridge",
		action_text_id = "hud_action_take_bridge",
		special_equipment_block = "bridge",
		timer = 1,
		interact_distance = 200,
		start_active = false
	}
	self.use_bridge = {
		text_id = "hud_int_use_bridge",
		action_text_id = "hud_action_use_bridge",
		equipment_text_id = "hud_equipment_use_bridge",
		equipment_consume = true,
		timer = 2,
		special_equipment = "bridge",
		interact_distance = 500,
		start_active = false
	}
	self.hold_close_keycard = {
		text_id = "hud_int_invisible_interaction_close",
		action_text_id = "hud_action_open_slash_close",
		equipment_text_id = "hud_int_equipment_no_keycard",
		special_equipment = "bank_manager_key",
		equipment_consume = true,
		start_active = true,
		axis = "y",
		timer = 0.5
	}
	self.hold_close = {
		text_id = "hud_int_invisible_interaction_close",
		action_text_id = "hud_action_open_slash_close",
		start_active = false,
		axis = "y",
		timer = 0.5
	}
	self.hold_open = {
		text_id = "hud_int_invisible_interaction_open",
		action_text_id = "hud_action_open_slash_close",
		start_active = false,
		axis = "y",
		timer = 0.5
	}
	self.hold_move_car = {
		text_id = "hud_int_hold_move_car",
		action_text_id = "hud_action_moving_car",
		start_active = false,
		timer = 3,
		interact_distance = 150,
		axis = "y",
		sound_start = "bar_cop_car",
		sound_interupt = "bar_cop_car_cancel",
		sound_done = "bar_cop_car_finished"
	}
	self.hold_remove_armor_plating = {
		text_id = "hud_int_hold_remove_armor_plating",
		action_text_id = "hud_action_removing_armor_plating",
		timer = 5,
		sound_start = "bar_steal_circuit",
		sound_interupt = "bar_steal_circuit_cancel",
		sound_done = "bar_steal_circuit_finished"
	}
	self.gen_pku_cocaine_pure = deep_clone(self.gen_pku_cocaine)
	self.gen_pku_cocaine_pure.text_id = "hud_int_hold_take_pure_cocaine"
	self.gen_pku_cocaine_pure.action_text_id = "hud_action_taking_pure_cocaine"
	self.gen_pku_sandwich = {
		text_id = "hud_int_hold_take_sandwich",
		action_text_id = "hud_action_taking_sandwich",
		timer = 3,
		sound_start = "bar_bag_money",
		sound_interupt = "bar_bag_money_cancel",
		sound_done = "bar_bag_money_finished",
		blocked_hint = "carry_block"
	}
	self.place_flare = {
		text_id = "hud_int_place_flare",
		start_active = false
	}
	self.ignite_flare = {
		text_id = "hud_int_ignite_flare",
		start_active = false
	}
	self.hold_open_xmas_present = {
		text_id = "hud_int_hold_open_xmas_present",
		action_text_id = "hud_action_opening_xmas_present",
		start_active = false,
		timer = 1.5,
		sound_start = "bar_gift_box_open",
		sound_interupt = "bar_gift_box_open_cancel",
		sound_done = "bar_gift_box_open_finished"
	}
	self.c4_bag_dynamic = deep_clone(self.c4_bag)
	self.c4_bag_dynamic.force_update_position = true
	self.shape_charge_plantable_c4_1 = deep_clone(self.shape_charge_plantable)
	self.shape_charge_plantable_c4_1.special_equipment = "c4_1"
	self.shape_charge_plantable_c4_x1 = deep_clone(self.shape_charge_plantable)
	self.shape_charge_plantable_c4_x1.special_equipment = "c4_x1"
	self.shape_charge_plantable_c4_x1.interact_distance = 500
	self.hold_call_captain = {
		text_id = "hud_int_hold_call_captain",
		action_text_id = "hud_action_calling_captain",
		start_active = false,
		timer = 1,
		interact_distance = 75
	}
	self.hold_pku_disassemble_cro_loot = {
		text_id = "hud_int_hold_disassemble_cro_loot",
		action_text_id = "hud_action_disassemble_cro_loot",
		blocked_hint = "carry_block",
		start_active = false,
		timer = 2,
		axis = "x",
		sound_start = "bar_bag_generic",
		sound_interupt = "bar_bag_generic_cancel",
		sound_done = "bar_bag_generic_finished"
	}
	self.hold_remove_ladder = {
		text_id = "hud_int_hold_remove_ladder",
		action_text_id = "hud_action_remove_ladder",
		start_active = false,
		timer = 2,
		sound_done = "",
		interact_distance = 150
	}
	self.connect_hose = {
		icon = "develop",
		text_id = "hud_int_hold_connect_hose",
		action_text_id = "hud_action_connect_hose",
		start_active = false,
		sound_event = "ammo_bag_drop",
		timer = 4,
		interact_distance = 300,
		sound_start = "bar_hose_ground_connect",
		sound_interupt = "bar_hose_ground_connect_cancel",
		sound_done = "bar_hose_ground_connect_finished"
	}
	self.generator_start = {
		text_id = "hud_generator_start",
		action_text_id = "hud_action_generator_start",
		start_active = false,
		timer = 4,
		interact_distance = 300
	}
	self.hold_open_bomb_case = {
		text_id = "hud_int_hold_open_case",
		action_text_id = "hud_action_int_hold_open_case",
		start_active = false,
		timer = 2,
		interact_distance = 120,
		axis = "x"
	}
	self.press_c4_pku = {
		text_id = "hud_int_take_c4",
		contour = "interactable",
		start_active = false,
		interact_distance = 150
	}
	self.open_train_cargo_door = {
		text_id = "hud_int_open_cargo_door",
		start_active = false,
		interact_distance = 150,
		timer = 0.5
	}
	self.close_train_cargo_door = {
		text_id = "hud_int_close_cargo_door",
		start_active = false,
		interact_distance = 150,
		timer = 0.5
	}
	self.take_chainsaw = {
		text_id = "hud_int_take_chainsaw",
		icon = "equipment_chainsaw",
		special_equipment_block = "chainsaw"
	}
	self.use_chainsaw = {
		text_id = "hud_int_hold_cut_tree",
		action_text_id = "hud_action_cutting_tree",
		equipment_text_id = "hint_no_chainsaw",
		special_equipment = "chainsaw",
		equipment_consume = false,
		timer = 2,
		sound_start = "bar_chainsaw",
		sound_interupt = "bar_chainsaw_cancel",
		sound_done = "bar_chainsaw_finished"
	}
	self.hack_ship_control = {
		icon = "interaction_keyboard",
		text_id = "hud_hack_ship_control",
		action_text_id = "hud_hacking_ship_control",
		timer = 6,
		axis = "z",
		start_active = false,
		interact_distance = 150,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.move_ship_gps_coords = {
		icon = "interaction_keyboard",
		text_id = "hud_move_ship_gps_coords",
		action_text_id = "hud_moving_ship_gps_coords",
		timer = 6,
		axis = "z",
		start_active = false,
		interact_distance = 150,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.pku_manifest = {
		text_id = "hud_pku_manifest",
		icon = "equipment_manifest",
		special_equipment_block = "manifest",
		start_active = false,
		interact_distance = 150,
		equipment_consume = false
	}
	self.c4_x1_bag = {
		text_id = "debug_interact_c4_bag",
		timer = 4,
		contour = "interactable",
		sound_start = "bar_bag_generic",
		sound_interupt = "bar_bag_generic_cancel",
		sound_done = "bar_bag_generic_finished"
	}
	self.cut_glass = {
		text_id = "hud_int_cut_glass",
		action_text_id = "hud_action_cut_glass",
		timer = 4,
		contour = "interactable_icon",
		axis = "y",
		equipment_text_id = "hud_equipment_need_glass_cutter",
		special_equipment = "mus_glas_cutter",
		sound_start = "bar_glasscutter",
		sound_interupt = "bar_glasscutter_cancel",
		sound_done = "bar_glasscutter_finished"
	}
	self.mus_hold_open_display = {
		text_id = "hud_int_hold_open_display",
		action_text_id = "hud_action_open_display",
		timer = 1
	}
	self.mus_take_diamond = {
		text_id = "debug_interact_diamond"
	}
	self.rewire_electric_box = {
		text_id = "hud_int_rewire_box",
		action_text_id = "hud_action_rewire_box",
		timer = 6,
		start_active = false,
		axis = "y",
		sound_start = "bar_hack_fuse_box",
		sound_interupt = "bar_hack_fuse_box_cancel",
		sound_done = "bar_hack_fuse_box_finished"
	}
	self.timelock_hack = {
		text_id = "hud_int_hack_timelock",
		action_text_id = "hud_action_hack_timelock",
		timer = 6,
		start_active = false,
		axis = "y",
		sound_start = "bar_hack_fuse_box",
		sound_interupt = "bar_hack_fuse_box_cancel",
		sound_done = "bar_hack_fuse_box_finished"
	}
	self.hold_unlock_car = {
		text_id = "hud_int_hold_unlock_car",
		action_text_id = "hud_unlocking_car",
		timer = 1,
		equipment_text_id = "hud_equipment_need_car_keys",
		special_equipment = "c_keys",
		equipment_consume = true
	}
	self.gen_pku_evidence_bag = {
		text_id = "hud_int_hold_take_evidence",
		action_text_id = "hud_action_taking_evidence_bag",
		timer = 3,
		axis = "y",
		sound_start = "bar_bag_money",
		sound_interupt = "bar_bag_money_cancel",
		sound_done = "bar_bag_money_finished",
		blocked_hint = "carry_block"
	}
	self.mcm_fbi_case = {
		text_id = "hud_int_hold_open_case",
		action_text_id = "hud_action_opening_case",
		timer = 3
	}
	self.mcm_fbi_taperecorder = {
		text_id = "hud_int_play_tape",
		action_text_id = "hud_action_play_tape",
		timer = 1
	}
	self.mcm_laptop = {
		text_id = "hud_int_hack_laptop",
		action_text_id = "hud_action_hack_laptop",
		timer = 3,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.mcm_laptop_code = {
		text_id = "hud_int_grab_code",
		action_text_id = "hud_action_grab_code",
		timer = 2,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.mcm_break_planks = {
		text_id = "hud_int_break_planks",
		action_text_id = "hud_action_break_planks",
		timer = 4,
		sound_start = "bar_wood_fence_break",
		sound_interupt = "bar_wood_fence_cancel",
		sound_done = "bar_wood_fence_finnished"
	}
	self.mcm_panicroom_keycard = {
		text_id = "hud_int_open_panicroom",
		action_text_id = "hud_action_open_panicroom",
		equipment_text_id = "hud_int_equipment_no_keycard",
		special_equipment = "bank_manager_key",
		equipment_consume = true,
		start_active = true,
		axis = "y",
		timer = 0.5
	}
	self.mcm_panicroom_keycard_2 = {
		text_id = "hud_int_equipment_keycard",
		equipment_text_id = "hud_int_equipment_no_keycard",
		special_equipment = "bank_manager_key",
		equipment_consume = true,
		start_active = true,
		axis = "y"
	}
	self.gen_prop_container_a_vault_seq = {
		text_id = "hud_int_hold_jam_vent",
		action_text_id = "hud_action_jamming_vent",
		equipment_text_id = "debug_interact_equipment_crowbar",
		special_equipment = "crowbar",
		timer = 1,
		start_active = false,
		equipment_consume = true,
		sound_start = "bar_fan_jam",
		sound_interupt = "bar_fan_jam_cancel",
		sound_done = "bar_fan_jam_finished"
	}
	self.gen_pku_warhead = {
		text_id = "hud_int_hold_take_warhead",
		action_text_id = "hud_action_taking_warhead",
		timer = 3,
		start_active = true,
		sound_start = "bar_bag_money",
		sound_interupt = "bar_bag_money_cancel",
		sound_done = "bar_bag_money_finished",
		blocked_hint = "carry_block"
	}
	self.gen_pku_warhead_box = {
		text_id = "hud_int_hold_open_case",
		action_text_id = "hud_action_opening_case",
		timer = 2,
		start_active = false,
		sound_start = "bar_open_warhead_box",
		sound_interupt = "bar_open_warhead_box_cancel",
		sound_done = "bar_open_warhead_box_finished"
	}
	self.gen_pku_circle_cutter = {
		text_id = "hud_int_hold_take_circle_cutter",
		action_text_id = "hud_action_taking_circle_cutter",
		timer = 1,
		sound_done = "pick_up_crowbar"
	}
	self.hold_circle_cutter = {
		text_id = "debug_interact_glass_cutter",
		action_text_id = "hud_action_placing_cutter",
		timer = 3,
		equipment_consume = true,
		equipment_text_id = "hud_equipment_need_circle_cutter",
		special_equipment = "circle_cutter",
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished"
	}
	self.circle_cutter_jammed = {
		text_id = "debug_interact_cutter_jammed",
		timer = 10,
		sound_start = "bar_drill_fix",
		sound_interupt = "bar_drill_fix_cancel",
		sound_done = "bar_drill_fix_finished"
	}
	self.answer_call = {
		text_id = "hud_int_hold_answer_call",
		action_text_id = "hud_action_answering_call",
		timer = 0.5,
		start_active = false
	}
	self.hold_take_fire_extinguisher = {
		text_id = "hud_int_hold_take_fire_extinguisher",
		action_text_id = "hud_action_taking_fire_extinguisher",
		timer = 1,
		start_active = false,
		special_equipment_block = "fire_extinguisher"
	}
	self.hold_extinguish_fire = {
		text_id = "hud_int_hold_extinguish_fire",
		action_text_id = "hud_action_extinguishing_fire",
		timer = 3,
		axis = "y",
		start_active = false,
		equipment_consume = true,
		equipment_text_id = "hud_equipment_need_fire_extinguisher",
		special_equipment = "fire_extinguisher",
		sound_start = "bar_fire_extinguisher",
		sound_interupt = "bar_fire_extinguisher_cancel",
		sound_done = "bar_fire_extinguisher_finished"
	}
	self.are_laptop = {
		text_id = "hud_int_hold_place_laptop",
		action_text_id = "hud_action_placeing_laptop",
		timer = 3,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.hold_search_c4 = {
		text_id = "hud_int_hold_search_c4",
		action_text_id = "hud_action_searching_c4",
		start_active = false,
		timer = 3,
		sound_start = "bar_gift_box_open",
		sound_interupt = "bar_gift_box_open_cancel",
		sound_done = "bar_gift_box_open_finished"
	}
	self.c4_x10 = deep_clone(self.c4_mission_door)
	self.c4_x10.special_equipment = "c4_x10"
	self.c4_x10.axis = "z"
	self.pick_lock_hard_no_skill_deactivated = deep_clone(self.pick_lock_hard_no_skill)
	self.pick_lock_hard_no_skill_deactivated.start_active = false
	self.are_turn_on_tv = {
		text_id = "hud_int_are_turn_on_tv",
		start_active = false,
		interact_distance = 100,
		axis = "y"
	}
	self.money_wrap_updating = deep_clone(self.money_wrap)
	self.money_wrap_updating.force_update_position = true
	self.panic_room_key = {
		icon = "equipment_chavez_key",
		text_id = "hud_int_take_chavez_keys",
		equipment_text_id = "hud_int_take_chavez_keys",
		special_equipment = "chavez_key",
		equipment_consume = true,
		interact_distance = 150
	}
	self.hack_skylight_barrier = {
		text_id = "hud_hack_skylight_barrier",
		action_text_id = "hud_action_hack_skylight_barrier",
		timer = 6,
		start_active = false,
		axis = "y",
		sound_start = "bar_hack_fuse_box",
		sound_interupt = "bar_hack_fuse_box_cancel",
		sound_done = "bar_hack_fuse_box_finished"
	}
	self.take_bottle = {
		text_id = "hud_int_take_bottle",
		action_text_id = "hud_action_take_bottle",
		icon = "equipment_bottle",
		special_equipment_block = "bottle",
		timer = 3
	}
	self.pour_spiked_drink = {
		text_id = "hud_int_pour_drink",
		equipment_text_id = "hint_no_bottle",
		special_equipment = "bottle",
		equipment_consume = true
	}
	self.computer_blueprints = {
		text_id = "hud_int_search_blueprints",
		action_text_id = "hud_action_searching_blueprints",
		timer = 4.5,
		axis = "x",
		contour = "interactable_icon",
		interact_distance = 200,
		sound_start = "bar_shuffle_papers",
		sound_interupt = "bar_shuffle_papers_cancel",
		sound_done = "bar_shuffle_papers_finished",
		icon = "equipment_files",
		special_equipment_block = "blueprints"
	}
	self.use_blueprints = {
		text_id = "hud_int_hold_scan_blueprints",
		action_text_id = "hud_action_scanning_blueprints",
		equipment_text_id = "hint_no_blueprints",
		special_equipment = "blueprints",
		equipment_consume = true,
		timer = 5,
		sound_start = "bar_scan_documents",
		sound_interupt = "bar_scan_documents_cancel",
		sound_done = "bar_scan_documents_finished"
	}
	self.send_blueprints = {
		text_id = "hud_int_send_blueprints"
	}
	self.cas_customer_database = {
		text_id = "hud_check_customer_database",
		action_text_id = "hud_action_cas_checking_customer_database",
		timer = 6,
		axis = "z",
		start_active = false,
		interact_distance = 150,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.disable_lasers = {
		text_id = "hud_disable_lasers",
		action_text_id = "hud_action_disabling_lasers",
		timer = 6,
		axis = "z",
		start_active = false,
		interact_distance = 150,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.pickup_hotel_room_keycard = {
		text_id = "hud_int_take_hotel_keycard",
		special_equipment_block = "hotel_room_key",
		start_active = true
	}
	self.use_hotel_room_key = {
		text_id = "hud_insert_hotel_room_key",
		equipment_text_id = "hint_no_hotel_room_key",
		special_equipment = "hotel_room_key",
		equipment_consume = true,
		interact_distance = 150
	}
	self.use_hotel_room_key_no_access = {
		text_id = "hud_insert_hotel_room_key",
		equipment_text_id = "hint_no_hotel_room_key",
		special_equipment = "hotel_room_key",
		equipment_consume = false,
		interact_distance = 150
	}
	self.lift_choose_floor = {
		text_id = "hud_int_lift_choose_floor",
		action_text_id = "hud_action_lift_choose_floor",
		start_active = false,
		interact_distance = 200
	}
	self.cas_open_briefcase = {
		text_id = "hud_open_cas_briefcase",
		action_text_id = "hud_opening_cas_briefcase",
		timer = 2,
		start_active = false,
		interact_distance = 150
	}
	self.cas_open_securityroom_door = {
		text_id = "hud_open_cas_securityroom_door",
		action_text_id = "hud_opening_cas_securityroom_door",
		timer = 1,
		interact_distance = 80,
		axis = "x"
	}
	self.cas_elevator_door_open = {
		text_id = "hud_open_cas_elevator",
		start_active = true,
		interact_distance = 100
	}
	self.cas_elevator_door_close = {
		text_id = "hud_close_cas_elevator",
		start_active = false,
		interact_distance = 100
	}
	self.lockpick_locker = {
		contour = "interactable_icon",
		icon = "equipment_bank_manager_key",
		text_id = "hud_int_pick_lock",
		start_active = true,
		timer = 2,
		upgrade_timer_multipliers = {
			{
				upgrade = "pick_lock_easy_speed_multiplier",
				category = "player"
			},
			{
				upgrade = "pick_lock_speed_multiplier",
				category = "player"
			}
		},
		action_text_id = "hud_action_picking_lock",
		interact_distance = 100,
		sound_start = "bar_pick_lock",
		sound_interupt = "bar_pick_lock_cancel",
		sound_done = "bar_pick_lock_finished",
		is_lockpicking = true
	}
	self.cas_copy_usb = {
		text_id = "hud_int_copy_data_usb",
		equipment_text_id = "hint_no_usb_key",
		interact_distance = 100,
		special_equipment = "cas_usb_key",
		start_active = false,
		equipment_consume = true
	}
	self.cas_use_usb = {
		text_id = "hud_insert_usb",
		equipment_text_id = "hint_no_data_usb_key",
		special_equipment = "cas_data_usb_key",
		equipment_consume = true,
		interact_distance = 150
	}
	self.cas_take_usb_key = {
		text_id = "hud_take_usb_key",
		interact_distance = 200,
		special_equipment_block = "cas_usb_key",
		start_active = false
	}
	self.cas_take_usb_key_data = {
		text_id = "hud_take_usb_key_data",
		interact_distance = 200,
		special_equipment_block = "cas_data_usb_key",
		start_active = false
	}
	self.cas_screw_down = {
		text_id = "hud_screw_down",
		action_text_id = "hud_action_screwing_down",
		interact_distance = 150,
		timer = 2,
		start_active = false,
		sound_start = "bar_secure_winch",
		sound_interupt = "bar_secure_winch_cancel",
		sound_done = "bar_secure_winch_finished"
	}
	self.cas_start_winch = {
		text_id = "hud_start_winch",
		action_text_id = "hud_action_starting_winch",
		interact_distance = 200,
		timer = 2,
		start_active = false
	}
	self.cas_take_hook = {
		text_id = "hud_take_hook",
		action_text_id = "hud_action_taking_hook",
		interact_distance = 100,
		timer = 2,
		start_active = false
	}
	self.cas_start_drill = {
		text_id = "hud_start_drill",
		action_text_id = "hud_action_starting_drill",
		interact_distance = 100,
		timer = 2,
		start_active = false
	}
	self.cas_stop_drill = {
		text_id = "hud_stop_drill",
		action_text_id = "hud_action_stoping_drill",
		interact_distance = 100,
		timer = 2,
		start_active = false
	}
	self.cas_take_empty_watertank = {
		text_id = "hud_take_watertank",
		action_text_id = "hud_action_taking_watertank",
		timer = 2,
		interact_distance = 100,
		start_active = false,
		sound_start = "bar_replace_empty_watertank",
		sound_interupt = "bar_replace_empty_watertank_cancel",
		sound_done = "bar_replace_empty_watertank_finished"
	}
	self.cas_take_full_watertank = {
		text_id = "hud_take_watertank",
		action_text_id = "hud_action_taking_watertank",
		timer = 2,
		interact_distance = 150,
		start_active = false,
		sound_start = "bar_take_watertank",
		sound_interupt = "bar_take_watertank_cancel",
		sound_done = "bar_take_watertank_finished"
	}
	self.cas_vent_gas = {
		text_id = "hud_place_sleeping_gass",
		action_text_id = "hud_action_placing_sleeping_gass",
		interact_distance = 150,
		timer = 2,
		equipment_text_id = "hint_no_sleeping_gas",
		special_equipment = "cas_sleeping_gas",
		start_active = false,
		equipment_consume = true,
		sound_start = "bar_sleeping_gas",
		sound_interupt = "bar_sleeping_gas_cancel",
		sound_done = "bar_sleeping_gas_finished",
		axis = "x"
	}
	self.cas_connect_power = {
		text_id = "hud_connect_cable",
		action_text_id = "hud_action_connecting_cable",
		interact_distance = 100,
		timer = 2,
		start_active = false
	}
	self.cas_take_sleeping_gas = {
		text_id = "hud_take_sleeping_gas",
		action_text_id = "hud_action_taking_sleeping_gas",
		timer = 2,
		interact_distance = 200,
		special_equipment_block = "cas_sleeping_gas",
		start_active = false,
		requires_mask_off_upgrade = {
			upgrade = "mask_off_pickup",
			category = "player"
		},
		can_interact_in_civilian = true
	}
	self.cas_chips_pile = {
		text_id = "hud_take_casino_chips",
		start_active = false,
		interact_distance = 110,
		requires_mask_off_upgrade = {
			upgrade = "mask_off_pickup",
			category = "player"
		},
		can_interact_in_civilian = true
	}
	self.cas_connect_winch_hook = {
		text_id = "hud_connect_which_hook",
		action_text_id = "hud_action_connecting_which_hook",
		equipment_text_id = "hint_no_winch_hook",
		special_equipment = "cas_winch_hook",
		start_active = false,
		interact_distance = 200,
		timer = 2,
		equipment_consume = true
	}
	self.cas_open_powerbox = {
		text_id = "hud_cas_open_powerbox",
		action_text_id = "hud_action_cas_opening_powerbox",
		start_active = false,
		interact_distance = 100,
		timer = 2
	}
	self.cas_take_fireworks_bag = {
		text_id = "hud_cas_take_fireworks_bag",
		action_text_id = "hud_action_cas_taking_fireworks_bag",
		blocked_hint = "carry_block",
		start_active = false,
		timer = 2,
		sound_start = "bar_bag_generic",
		sound_interupt = "bar_bag_generic_cancel",
		sound_done = "bar_bag_generic_finished"
	}
	self.cas_ignite_fireworks = {
		text_id = "hud_cas_ignite_fireworks",
		action_text_id = "hud_action_cas_igniting_fireworks",
		start_active = false,
		interact_distance = 200,
		timer = 2,
		sound_start = "bar_light_fireworks",
		sound_interupt = "bar_light_fireworks_cancel",
		sound_done = "bar_light_fireworks_finished"
	}
	self.cas_open_compartment = {
		text_id = "hud_cas_open_compartment",
		start_active = false,
		interact_distance = 150
	}
	self.cas_bfd_drill_toolbox = {
		text_id = "hud_take_bfd_tool",
		interact_distance = 200,
		special_equipment_block = "cas_bfd_tool",
		start_active = false
	}
	self.cas_fix_bfd_drill = {
		text_id = "hud_fix_bfd_drill",
		action_text_id = "hud_action_fixing_bfd_drill",
		interact_distance = 150,
		timer = 10,
		equipment_text_id = "hint_no_bfd_tool",
		special_equipment = "cas_bfd_tool",
		start_active = false,
		equipment_consume = true,
		sound_start = "bar_huge_lance_fix",
		sound_interupt = "bar_huge_lance_fix_cancel",
		sound_done = "bar_huge_lance_fix_finished"
	}
	self.cas_elevator_key = {
		text_id = "hud_take_elevator_key",
		interact_distance = 200,
		special_equipment_block = "cas_elevator_key",
		start_active = false
	}
	self.cas_use_elevator_key = {
		text_id = "hud_use_elevator_key",
		interact_distance = 150,
		equipment_text_id = "hint_no_elevator_key",
		special_equipment = "cas_elevator_key",
		start_active = false,
		equipment_consume = false
	}
	self.cas_open_door = {
		text_id = "hud_cas_open_door",
		start_active = true,
		interact_distance = 150,
		can_interact_in_civilian = true
	}
	self.cas_close_door = {
		text_id = "hud_cas_close_door",
		start_active = false,
		interact_distance = 150,
		can_interact_in_civilian = true
	}
	self.cas_slot_machine = {
		text_id = "hud_int_hold_play_slots",
		action_text_id = "hud_action_playing_slots",
		interact_distance = 100,
		timer = 2,
		start_active = false,
		can_interact_in_civilian = true,
		sound_done = "bar_slot_machine_pull_lever_finished",
		sound_interupt = "bar_slot_machine_pull_lever_cancel",
		sound_start = "bar_slot_machine_pull_lever"
	}
	self.cas_button_01 = {
		text_id = "hud_int_press_01",
		start_active = false,
		interact_distance = 50
	}
	self.cas_button_02 = {
		text_id = "hud_int_press_02",
		start_active = false,
		interact_distance = 50
	}
	self.cas_button_03 = {
		text_id = "hud_int_press_03",
		start_active = false,
		interact_distance = 50
	}
	self.cas_button_04 = {
		text_id = "hud_int_press_04",
		start_active = false,
		interact_distance = 50
	}
	self.cas_button_05 = {
		text_id = "hud_int_press_05",
		start_active = false,
		interact_distance = 50
	}
	self.cas_button_06 = {
		text_id = "hud_int_press_06",
		start_active = false,
		interact_distance = 50
	}
	self.cas_button_07 = {
		text_id = "hud_int_press_07",
		start_active = false,
		interact_distance = 50
	}
	self.cas_button_08 = {
		text_id = "hud_int_press_08",
		start_active = false,
		interact_distance = 50
	}
	self.cas_button_09 = {
		text_id = "hud_int_press_09",
		start_active = false,
		interact_distance = 50
	}
	self.cas_button_0 = {
		text_id = "hud_int_press_0",
		start_active = false,
		interact_distance = 50
	}
	self.cas_button_clear = {
		text_id = "hud_int_press_clear",
		start_active = false,
		interact_distance = 50
	}
	self.cas_button_enter = {
		text_id = "hud_int_press_enter",
		start_active = false,
		interact_distance = 50
	}
	self.cas_skylight_panel = {
		text_id = "hud_hack_skylight_panel",
		start_active = false,
		interact_distance = 50
	}
	self.cas_take_unknown = {
		text_id = "hud_take_???",
		action_text_id = "hud_action_taking_???",
		timer = 2,
		interact_distance = 100,
		start_active = false
	}
	self.cas_unpack_turret = {
		text_id = "hud_unpack_turret",
		action_text_id = "hud_action_unpacking_turret",
		timer = 2,
		interact_distance = 150,
		start_active = false
	}
	self.cas_open_guitar_case = {
		text_id = "hud_cas_open_guitar_case",
		action_text_id = "hud_action_cas_opening_guitar_case",
		timer = 3,
		interact_distance = 300,
		start_active = false,
		can_interact_only_in_civilian = true
	}
	self.cas_take_gear = {
		text_id = "hud_cas_take_gear",
		action_text_id = "hud_action_cas_taking_gear",
		contour = "deployable",
		timer = 3,
		interact_distance = 300,
		start_active = false,
		can_interact_only_in_civilian = true
	}
	self.cas_security_door = {
		text_id = "hud_cas_security_door",
		action_text_id = "hud_action_cas_security_door",
		timer = 10,
		interact_distance = 150,
		start_active = false,
		axis = "y"
	}
	self.pick_lock_30 = {
		contour = "interactable_icon",
		icon = "equipment_bank_manager_key",
		text_id = "hud_int_pick_lock",
		start_active = true,
		timer = 30,
		requires_upgrade = {
			upgrade = "pick_lock_hard",
			category = "player"
		},
		action_text_id = "hud_action_picking_lock",
		sound_start = "bar_pick_lock",
		sound_interupt = "bar_pick_lock_cancel",
		sound_done = "bar_pick_lock_finished",
		is_lockpicking = true
	}
	self.winning_slip = {
		text_id = "hud_int_take_win_slip",
		start_active = false,
		interact_distance = 110,
		can_interact_in_civilian = true
	}
	self.pku_safe = {
		text_id = "hud_int_hold_take_safe",
		action_text_id = "hud_action_taking_safe",
		start_active = false,
		timer = 3,
		blocked_hint = "carry_block"
	}
	self.gen_pku_saw = {
		text_id = "hud_int_hold_take_saw",
		action_text_id = "hud_action_taking_saw",
		timer = 1,
		special_equipment_block = "saw",
		sound_done = "pick_up_crowbar"
	}
	self.gen_int_saw = deep_clone(self.apartment_saw)
	self.gen_int_saw.equipment_text_id = "debug_interact_equipment_saw"
	self.gen_int_saw.special_equipment = "saw"
	self.gen_int_saw.equipment_consume = true
	self.gen_int_saw_jammed = deep_clone(self.apartment_saw_jammed)
	self.gen_int_saw_jammed.timer = 10
	self.gen_int_saw_upgrade = {
		contour = "upgradable",
		text_id = "hud_int_equipment_saw_upgrade",
		action_text_id = "hud_action_upgrading_saw",
		timer = 10,
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished"
	}
	self.safe_carry_drop = {
		icon = "develop",
		text_id = "hud_int_hold_take_safe",
		sound_event = "ammo_bag_drop",
		timer = 1,
		force_update_position = true,
		action_text_id = "hud_action_taking_safe",
		blocked_hint = "carry_block"
	}
	self.hold_pku_knife = {
		text_id = "hud_int_hold_pku_knife",
		action_text_id = "hud_action_pkuing_knife",
		start_active = true,
		timer = 0.5
	}
	self.c4_consume = deep_clone(self.c4_special)
	self.c4_consume.special_equipment = "c4"
	self.c4_consume.equipment_consume = true
	self.gen_pku_thermite_timer = deep_clone(self.gen_pku_thermite)
	self.gen_pku_thermite_timer.timer = 0.5
	self.gen_pku_thermite_timer.start_active = false
	self.red_no_key = {
		interact_distance = 100,
		timer = 5,
		text_id = "hud_int_hold_open_vault",
		action_text_id = "hud_action_opening_vault"
	}
	self.s_cube = {
		text_id = "debug_interact_temp_interact_box",
		start_active = false,
		timer = 2,
		contour = "interactable_look_at"
	}
	self.red_open_shutters = {
		text_id = "hud_int_hold_open_shutters",
		axis = "y"
	}
	self.red_close_shutters = {
		text_id = "hud_int_hold_close_shutters",
		axis = "y"
	}
	self.pd1_drill = deep_clone(self.drill)
	self.pd1_drill.contour = "interactable"
	self.hold_open_vent = {
		text_id = "hud_int_hold_open_vent",
		action_text_id = "hud_action_opening_vent",
		timer = 2,
		axis = "y",
		start_active = false
	}
	self.press_open_truck = {
		text_id = "hud_int_press_open_truck",
		start_active = false
	}
	self.red_take_envelope = {
		text_id = "hud_int_take_envelope",
		start_active = false,
		axis = "z"
	}
	self.din_crane_control = {
		text_id = "hud_int_hold_start_crane",
		action_text_id = "hud_action_starting_crane",
		timer = 4,
		sound_start = "bar_crane_control_panel",
		sound_interupt = "bar_crane_control_panel_cancel",
		sound_done = "bar_crane_control_panel_finished"
	}
	self.din_hold_ignite_trap = {
		text_id = "hud_int_hold_ignite_trap",
		action_text_id = "hud_action_igniting_trap",
		timer = 4,
		interact_distance = 300,
		sound_start = "bar_thermal_lance_fix",
		sound_interupt = "bar_thermal_lance_fix_cancel",
		sound_done = "bar_thermal_lance_fix_finished"
	}
	self.pku_pig = {
		text_id = "hud_int_hold_take_pig",
		action_text_id = "hud_action_taking_pig",
		start_active = false,
		timer = 3,
		blocked_hint = "carry_block"
	}
	self.pku_pills = {
		text_id = "hud_int_hold_take_pills",
		action_text_id = "hud_action_taking_pills",
		start_active = false,
		timer = 3,
		blocked_hint = "carry_block",
		axis = "y"
	}
	self.taking_meth_huge = {
		text_id = "hud_int_hold_take_meth",
		action_text_id = "hud_action_taking_meth",
		timer = 3,
		interact_distance = 300,
		sound_start = "bar_bag_money",
		sound_interupt = "bar_bag_money_cancel",
		sound_done = "bar_bag_money_finished",
		blocked_hint = "carry_block"
	}
	self.bry_control_jammed = deep_clone(self.hack_suburbia_jammed)
	self.bry_control_jammed.start_active = false
	self.hold_plant_breaching_charge = {
		text_id = "hud_int_hold_plant_breaching_charge",
		action_text_id = "hud_action_planting_breaching_charge",
		start_active = false,
		timer = 3,
		sound_start = "bar_plant_breaching_charges",
		sound_interupt = "bar_plant_breaching_charge_cancel",
		sound_done = "bar_plant_breaching_charge_finished"
	}
	self.hold_pku_breaching_charges = {
		text_id = "hud_int_hold_pku_breaching_charges",
		action_text_id = "hud_action_taking_breaching_charges",
		start_active = false,
		timer = 3
	}
	self.hold_unlock_display_ares = {
		text_id = "hud_int_hold_unlock_display_ares",
		action_text_id = "hud_action_unlocking",
		start_active = false,
		axis = "y",
		timer = 1,
		sound_start = "bar_vault_touchscreen",
		sound_interupt = "bar_vault_touchscreen_cancel",
		sound_done = "bar_vault_touchscreen_finished"
	}
	self.hold_unlock_display_chronos = deep_clone(self.hold_unlock_display_ares)
	self.hold_unlock_display_chronos.text_id = "hud_int_hold_unlock_display_chronos"
	self.hold_unlock_display_demeter = deep_clone(self.hold_unlock_display_ares)
	self.hold_unlock_display_demeter.text_id = "hud_int_hold_unlock_display_demeter"
	self.hold_unlock_display_hades = deep_clone(self.hold_unlock_display_ares)
	self.hold_unlock_display_hades.text_id = "hud_int_hold_unlock_display_hades"
	self.hold_unlock_display_poseidon = deep_clone(self.hold_unlock_display_ares)
	self.hold_unlock_display_poseidon.text_id = "hud_int_hold_unlock_display_poseidon"
	self.hold_unlock_display_zeus = deep_clone(self.hold_unlock_display_ares)
	self.hold_unlock_display_zeus.text_id = "hud_int_hold_unlock_display_zeus"
	self.gen_pku_blow_torch = {
		text_id = "hud_int_hold_take_blow_torch",
		action_text_id = "hud_action_taking_blow_torch",
		timer = 1,
		special_equipment_block = "blow_torch",
		sound_done = "pick_up_crowbar"
	}
	self.hold_blow_torch = {
		text_id = "hud_int_hold_cut",
		action_text_id = "hud_action_cutting",
		timer = 5,
		equipment_text_id = "hud_equipment_need_blow_torch",
		special_equipment = "blow_torch",
		sound_start = "bar_blowtorch",
		sound_interupt = "bar_blowtorch_end",
		sound_done = "bar_blowtorch_end"
	}
	self.hold_breaching_detonator = {
		text_id = "hud_int_hold_place_breaching_detonator",
		action_text_id = "hud_action_placing_breaching_detonator",
		timer = 3,
		sound_start = "bar_plant_breaching_detonator",
		sound_interupt = "bar_plant_breaching_detonator_cancel",
		sound_done = "bar_plant_breaching_detonator_finished"
	}
	self.hold_breaching_detonator_rearm = {
		text_id = "hud_int_hold_place_breaching_detonator_rearm",
		action_text_id = "hud_action_placing_breaching_detonator_rearm",
		timer = 3,
		sound_start = "bar_plant_breaching_detonator",
		sound_interupt = "bar_plant_breaching_detonator_cancel",
		sound_done = "bar_plant_breaching_detonator_finished"
	}
	self.bry_pku_prototype = {
		text_id = "hud_int_hold_take_prototype",
		action_text_id = "hud_action_taking_prototype",
		timer = 3,
		start_active = true,
		sound_start = "bar_bag_money",
		sound_interupt = "bar_bag_money_cancel",
		sound_done = "bar_bag_money_finished",
		blocked_hint = "carry_block"
	}
	self.parachute_carry_drop = deep_clone(self.carry_drop)
	self.parachute_carry_drop.text_id = "hud_int_hold_grab_parachute"
	self.parachute_carry_drop.action_text_id = "hud_action_grabbing_parachute"
	self.hold_take_parachute = {
		text_id = "hud_int_hold_grab_parachute",
		action_text_id = "hud_action_grabbing_parachute",
		start_active = false,
		timer = 2,
		sound_start = "bar_steal_painting",
		sound_interupt = "bar_steal_painting_cancel",
		sound_done = "bar_steal_painting_finished",
		blocked_hint = "carry_block"
	}
	self.hold_place_strap = {
		text_id = "hud_int_hold_fasten_strap",
		action_text_id = "hud_action_fastening_strap",
		timer = 2,
		sound_start = "bar_attach_money_stack",
		sound_interupt = "bar_attach_money_stack_cancel",
		sound_done = "bar_attach_money_stack_finished"
	}
	self.hold_take_paper_roll = {
		text_id = "hud_int_hold_take_paper_roll",
		action_text_id = "hud_action_taking_paper_roll",
		timer = 2,
		start_active = false,
		blocked_hint = "carry_block",
		sound_start = "bar_bag_money",
		sound_interupt = "bar_bag_money_cancel",
		sound_done = "bar_bag_money_finished"
	}
	self.hold_take_counterfeit_money = {
		text_id = "hud_int_hold_take_counterfeit_money",
		action_text_id = "hud_action_taking_counterfeit_money",
		timer = 2,
		start_active = false,
		blocked_hint = "carry_block",
		sound_start = "bar_bag_money",
		sound_interupt = "bar_bag_money_cancel",
		sound_done = "bar_bag_money_finished"
	}
	self.hold_start_printer = {
		text_id = "hud_int_hold_start_printer",
		action_text_id = "hud_action_starting_printer",
		timer = 0.5,
		start_active = false
	}
	self.hold_insert_printer_ink = {
		text_id = "hud_int_hold_insert_printer_ink",
		action_text_id = "hud_action_inserting_printer_ink",
		timer = 0.5,
		start_active = false,
		special_equipment = "printer_ink",
		equipment_text_id = "hud_equipment_need_printer_ink",
		equipment_consume = true,
		sound_start = "bar_insert_printer_ink",
		sound_interupt = "bar_insert_printer_ink_cancel"
	}
	self.press_printer_ink = {
		text_id = "hud_int_take_printer_ink",
		start_active = false,
		special_equipment_block = "printer_ink"
	}
	self.press_printer_paper = {
		text_id = "hud_int_take_paper_roll",
		start_active = false,
		special_equipment_block = "paper_roll"
	}
	self.hold_insert_paper_roll = {
		text_id = "hud_int_hold_insert_paper_roll",
		action_text_id = "hud_action_inserting_paper_roll",
		timer = 5,
		start_active = false,
		special_equipment = "paper_roll",
		equipment_text_id = "hud_equipment_need_a_paper_roll",
		equipment_consume = true,
		sound_start = "bar_insert_paperroll",
		sound_interupt = "bar_insert_paperroll_cancel",
		sound_done = "bar_insert_paperroll_finished"
	}
	self.press_plates = {
		text_id = "hud_int_take_plates",
		timer = 0.5,
		start_active = false,
		special_equipment_block = "plates"
	}
	self.press_plates_invis = {
		text_id = "hud_int_take_plates",
		timer = 5,
		start_active = false,
		special_equipment_block = "plates",
		sound_start = "bar_remove_printingplates",
		sound_interupt = "bar_remove_printingplates_cancel",
		sound_done = "bar_remove_printingplates_finished"
	}
	self.hold_insert_plates = {
		text_id = "hud_int_hold_insert_plates",
		action_text_id = "hud_action_inserting_plates",
		timer = 5,
		start_active = false,
		special_equipment = "plates",
		equipment_text_id = "hud_equipment_need_plates",
		sound_start = "bar_insert_printingplates",
		sound_interupt = "bar_insert_printingplates_cancel",
		sound_done = "bar_insert_printingplates_finished",
		equipment_consume = true
	}
	self.man_apply_tape = {
		text_id = "hud_man_apply_tape",
		timer = 4,
		interact_distance = 150,
		start_active = false
	}
	self.man_remove_bars = {
		text_id = "an_remove_bars",
		timer = 4,
		interact_distance = 150,
		start_active = false
	}
	self.hold_pku_present = {
		text_id = "hud_int_hold_bag_present",
		action_text_id = "hud_action_bagging_present",
		start_active = false,
		timer = 3,
		blocked_hint = "carry_block"
	}
	self.hold_grab_goat = {
		text_id = "hud_int_hold_grab_goat",
		sound_event = "ammo_bag_drop",
		timer = 1,
		force_update_position = true,
		start_active = false,
		action_text_id = "hud_action_grabbing_goat",
		blocked_hint = "carry_block"
	}
	self.goat_carry_drop = deep_clone(self.hold_grab_goat)
	self.goat_carry_drop.start_active = true
	self.hold_remove_debris = {
		text_id = "hud_int_hold_remove_debris",
		action_text_id = "hud_action_removing_debris",
		timer = 3,
		sound_start = "bar_break_wood",
		sound_interupt = "bar_break_wood_cancel",
		sound_done = "bar_break_wood_end",
		start_activate = false
	}
	self.man_trunk_picklock = {
		text_id = "hud_cas_security_door",
		equipment_text_id = "hud_action_cas_security_door",
		start_active = false,
		timer = 20,
		sound_start = "bar_pick_lock",
		sound_interupt = "bar_pick_lock_cancel",
		sound_done = "bar_pick_lock_finished",
		is_lockpicking = true
	}
	self.stash_server_pickup_server = deep_clone(self.stash_server_pickup)
	self.stash_server_pickup_server.text_id = "hud_int_grab_server"
	self.stash_server_pickup_server.action_text_id = "hud_action_grab_server"
	self.drk_hold_hack_computer = {
		text_id = "hud_int_big_computer_hackable",
		action_text_id = "hud_action_hacking_computer",
		timer = 10,
		axis = "y",
		start_active = false,
		sound_start = "bar_train_panel_hacking",
		sound_interupt = "bar_train_panel_hacking_cancel",
		sound_done = "bar_train_panel_hacking_finished"
	}
	self.hold_electric_lock = deep_clone(self.open_train_cargo_door)
	self.hold_electric_lock.text_id = "hud_hint_requires_panel_access"
	self.hold_electric_lock.timer = 0
	self.hold_electric_lock.equipment_text_id = "hud_hint_requires_panel_access"
	self.hold_electric_lock.special_equipment = "saw_blade"
	self.hold_pku_drk_bomb_part = deep_clone(self.hold_pku_disassemble_cro_loot)
	self.hold_pku_drk_bomb_part.start_active = true
	self.hold_pku_drk_bomb_part.axis = "z"
	self.drk_pku_blow_torch = deep_clone(self.gen_pku_blow_torch)
	self.drk_pku_blow_torch.axis = "z"
	self.access_camera_y_axis = {
		icon = "develop",
		text_id = "hud_int_access_camera",
		interact_distance = 125,
		axis = "y"
	}
	self.money_wrap_single_bundle_dyn = deep_clone(self.money_wrap_single_bundle)
	self.money_wrap_single_bundle_dyn.start_active = true
	self.money_wrap_single_bundle_dyn.force_update_position = true
	self.gen_pku_thermite_paste_z_axis = deep_clone(self.gen_pku_thermite_paste)
	self.gen_pku_thermite_paste_z_axis.axis = "y"
	self.gen_pku_thermite_paste_z_axis.contour = "interactable"
	self.hold_open_vent_dark = {
		text_id = "hud_int_hold_open_vent",
		action_text_id = "hud_action_opening_vent",
		timer = 2,
		interact_distance = 120,
		start_active = false,
		sound_start = "bar_move_vent_panel",
		sound_interupt = "bar_move_vent_panel_cancel",
		sound_done = "bar_move_vent_panel_finished"
	}
	self.dark_screw_down = {
		text_id = "hud_hold_remove_screw",
		action_text_id = "hud_action_remove_screw",
		interact_distance = 150,
		timer = 2,
		start_active = false,
		sound_start = "bar_unscrew_vent",
		sound_interupt = "bar_unscrew_vent_cancel",
		sound_done = "bar_unscrew_vent_finished"
	}
	self.hold_start_scan = {
		text_id = "hud_hold_start_scanning",
		action_text_id = "hud_action_start_scanning",
		interact_distance = 150,
		timer = 3,
		start_active = false,
		force_update_position = true,
		sound_start = "bar_train_panel_hacking",
		sound_interupt = "bar_train_panel_hacking_cancel",
		sound_done = "bar_train_panel_hacking_finished"
	}
	self.hold_start_scan_hand = deep_clone(self.hold_start_scan)
	self.hold_start_scan_hand.text_id = "hud_hold_scan_hand"
	self.hold_start_scan_hand.action_text_id = "hud_action_scanning_hand"
	self.hold_start_scan_hand.equipment_text_id = "hud_equipment_get_hand"
	self.hold_start_scan_hand.special_equipment = "hand"
	self.hold_start_scan_hand.equipment_consume = true
	self.hold_start_scan_hand.sound_start = "bar_scan_hand"
	self.hold_start_scan_hand.sound_interupt = "bar_scan_hand_cancel"
	self.hold_start_scan_hand.sound_done = "bar_scan_hand_finished"
	self.hold_remove_hand = {
		text_id = "hud_hold_removing_hand",
		action_text_id = "hud_action_removing_hand",
		special_equipment_block = "hand",
		interact_distance = 150,
		timer = 5,
		start_active = false,
		sound_start = "bar_cut_off_arm",
		sound_interupt = "bar_cut_off_arm_cancel",
		sound_done = "bar_cut_off_arm_finished"
	}
	self.hold_open_bomb_hatch = {
		text_id = "hud_hold_open_bomb_hatch",
		action_text_id = "hud_action_open_bomb_hatch",
		timer = 0.5,
		start_active = false
	}
	self.hold_start_bomb_charge = {
		text_id = "hud_hold_start_bomb_charge",
		action_text_id = "hud_action_start_bomb_charge",
		timer = 5,
		start_active = false,
		sound_start = "bar_start_emp",
		sound_interupt = "bar_start_emp_cancel",
		sound_done = "bar_start_emp_finished"
	}
	self.gen_pku_body = {
		text_id = "hud_int_hold_grab_body",
		action_text_id = "hud_action_grabbing_body",
		timer = 3,
		blocked_hint = "carry_block"
	}
	self.hold_fire_missile = {
		text_id = "hud_int_fire_missiles",
		action_text_id = "hud_action_firing_missiles",
		start_active = false,
		axis = "z",
		timer = 1
	}
	self.hold_turn_off_gas = {
		text_id = "hud_hold_turn_of_gas",
		action_text_id = "hud_action_turn_of_gas",
		timer = 5,
		start_active = false,
		sound_start = "bar_twist_valve",
		sound_interupt = "bar_twist_valve_cancel",
		sound_done = "bar_twist_valve_finished"
	}
	self.hold_born_search_tools = {
		text_id = "hud_int_hold_born_search_tools",
		timer = 5,
		interact_distance = 150,
		start_active = false,
		sound_start = "bar_search_toolbox",
		sound_interupt = "bar_search_toolbox_cancel",
		sound_done = "bar_search_toolbox_finished"
	}
	self.born_give_item = {
		text_id = "hud_born_give_item",
		timer = 0,
		interact_distance = 150,
		start_active = false,
		equipment_text_id = "hud_int_no_caustic_soda",
		special_equipment = "caustic_soda",
		equipment_consume = true,
		action_text_id = "hud_born_give_item",
		sound_done = "bag_light_drop"
	}
	self.hold_born_take_bike_part = {
		text_id = "hud_int_hold_born_take_bike_part",
		timer = 1,
		interact_distance = 150,
		start_active = false
	}
	self.hold_born_take_bike_part_y_axis = deep_clone(self.hold_born_take_bike_part)
	self.hold_born_take_bike_part_y_axis.axis = "y"
	self.hold_born_ride_the_bike = {
		text_id = "hud_int_hold_born_ride_the_bike",
		timer = 1,
		interact_distance = 150,
		start_active = false
	}
	self.hold_born_untie = {
		text_id = "hud_int_hold_born_untie",
		timer = 4,
		interact_distance = 150,
		start_active = false,
		sound_start = "bar_untie_hostage",
		sound_interupt = "bar_untie_hostage_cancel",
		sound_done = "bar_untie_hostage_finished"
	}
	self.hold_born_soda = {
		text_id = "hud_int_hold_born_soda",
		timer = 1,
		interact_distance = 150,
		start_active = false,
		sound_done = "bag_light_drop"
	}
	self.hold_born_receive_item_blow_torch = {
		text_id = "hud_int_hold_born_receive_item_blow_torch",
		timer = 1,
		interact_distance = 150,
		start_active = false,
		action_text_id = "hud_int_hold_born_receive_item_blow_torch",
		sound_done = "bag_light_drop"
	}
	self.hold_hand_over_soda = {
		text_id = "hud_int_hold_hand_over_soda",
		equipment_text_id = "hud_int_requires_soda",
		action_text_id = "hud_action_handing_over_soda",
		special_equipment = "soda",
		equipment_consume = true
	}
	self.hold_hand_over_tool = {
		text_id = "hud_int_hold_hand_over_tool",
		equipment_text_id = "hud_int_requires_tool",
		action_text_id = "hud_action_handing_over_tool",
		special_equipment = "tool",
		equipment_consume = true
	}
	self.hold_hand_over_chrome_skull = {
		text_id = "hud_int_hold_hand_over_chrome_skull",
		equipment_text_id = "hud_int_requires_chrome_skull",
		action_text_id = "hud_action_handing_over_chrome_skull",
		special_equipment = "chrome_skull",
		equipment_consume = true
	}
	self.born_plug_in_powercord = {
		text_id = "hud_born_plug_in_powercord",
		timer = 0,
		interact_distance = 150,
		start_active = false,
		sound_done = "insert_cable_gen"
	}
	self.hold_open_door = deep_clone(self.hold_open)
	self.hold_open_door.action_text_id = "hud_action_opening"
	self.hold_open_door.timer = 1
	self.hold_open_door.interact_distance = 250
	self.hold_open_door_no_axis = {
		text_id = "hud_int_invisible_interaction_open",
		action_text_id = "hud_action_opening",
		start_active = false,
		interact_distance = 200,
		timer = 1
	}
	self.hold_open_hatch = {
		text_id = "hud_int_hold_open_hatch",
		action_text_id = "hud_action_opening_hatch",
		axis = "y",
		start_active = false,
		timer = 0.5
	}
	self.hold_open_hatch = {
		text_id = "hud_int_hold_open_hatch",
		action_text_id = "hud_action_opening_hatch",
		axis = "y",
		start_active = false,
		timer = 0.5
	}
	self.ring_band = deep_clone(self.money_wrap_single_bundle)
	self.ring_band.text_id = "hud_int_take"
	self.fbi_usb_insert = {
		text_id = "hud_int_insert_flash_dive",
		equipment_text_id = "hint_no_fbi_usb_key",
		special_equipment = "cas_usb_key",
		sound_event = "insert_usb_stick",
		equipment_consume = true,
		interact_distance = 150
	}
	self.hold_release_hatch = {
		text_id = "hud_int_hold_release_hatch",
		action_text_id = "hud_action_releasing_hatch",
		timer = 1,
		start_active = false
	}
	self.hold_open_case = {
		text_id = "hud_int_hold_open_case",
		action_text_id = "hud_action_opening_case",
		timer = 0.5,
		start_active = false
	}
	self.hold_take_helmet = {
		text_id = "hud_int_hold_take_helmet",
		action_text_id = "hud_action_taking_helmet",
		timer = 2,
		start_active = true
	}
	self.press_pick_up = {
		text_id = "hud_int_press_pick_up",
		interact_distance = 100,
		start_active = false
	}
	self.press_new_paintjob = {
		text_id = "hud_press_new_paintjob",
		interact_distance = 200
	}
	self.press_anwser_machine = {
		text_id = "hud_press_answering_play",
		interact_distance = 200
	}
	self.press_shoot_puck = {
		text_id = "hud_int_press_shoot_puck",
		interact_distance = 350
	}
	self.press_play_music = {
		text_id = "hud_press_play_music",
		interact_distance = 150
	}
	self.press_stop_music = {
		text_id = "hud_press_stop_music",
		interact_distance = 150
	}
	self.press_spin_wheel = {
		text_id = "hud_int_spin_wheel",
		interact_distance = 300
	}
	self.press_bet_red = {
		text_id = "hud_press_bet_red",
		interact_distance = 150
	}
	self.press_bet_black = {
		text_id = "hud_press_bet_black",
		interact_distance = 150
	}
	self.hold_burn_offshore_money = {
		text_id = "hud_hold_burn_offshore_money",
		interact_distance = 150,
		sound_done = "bar_button_burn_stinger",
		sound_interupt = "bar_button_burn_cancel",
		sound_start = "bar_button_burn"
	}
	self.press_reset_damage_counter = {
		text_id = "hud_press_reset_damage_counter",
		interact_distance = 150
	}
	self.play_bank_invaders = {
		text_id = "hud_chill_access_bankinvader",
		interact_distance = 200
	}
	self.access_fbi_files = {
		text_id = "hud_chill_access_fbi",
		interact_distance = 200
	}
	self.access_pd2stash = {
		text_id = "hud_chill_access_pd2stash",
		interact_distance = 200
	}
	self.access_sidejobs = {
		text_id = "hud_chill_access_sidejobs",
		interact_distance = 200,
		axis = "y"
	}
	self.access_weapon_primary = {
		text_id = "hud_chill_access_primary",
		interact_distance = 200,
		category = "primaries"
	}
	self.access_weapon_secondary = {
		text_id = "hud_chill_access_secondary",
		interact_distance = 200,
		category = "secondaries"
	}
	self.chl_slot_machine = {
		text_id = "hud_hold_bet_slotmachine_chl",
		action_text_id = "hud_action_playing_slots",
		interact_distance = 100,
		timer = 2,
		start_active = false,
		can_interact_in_civilian = true,
		sound_done = "bar_slot_machine_pull_lever_finished",
		sound_interupt = "bar_slot_machine_pull_lever_cancel",
		sound_start = "bar_slot_machine_pull_lever"
	}
	self.talk_to_heister = {
		timer = 0,
		interact_distance = 300,
		max_interact_distance = 0,
		icon = "develop",
		no_contour = true,
		action_text_id = "hud_int_talk_dallas",
		interaction_obj = Idstring("Spine2")
	}

	for name, data in pairs(tweak_data.safehouse.heisters) do
		if name ~= "base" then
			local id = "talk_to_heister_" .. name
			self[id] = clone(self.talk_to_heister)
			self[id].text_id = "hud_int_talk_" .. name
		end
	end

	self.jiro_no_interaction = clone(self.talk_to_heister)
	self.jiro_no_interaction.interact_distance = 0
	self.press_start_weapon_course = {
		text_id = "hud_press_start_weapon_course",
		interact_distance = 150
	}
	self.pku_scubagear_tank = {
		text_id = "hud_int_hold_take_scubagear_tank_and_flippers",
		action_text_id = "hud_action_taking_scubagear_tank_and_flippers",
		timer = 1,
		interact_distance = 130,
		start_active = false,
		blocked_hint = "carry_block"
	}
	self.pku_scubagear_vest = {
		text_id = "hud_int_hold_take_scubagear_vest",
		action_text_id = "hud_action_taking_scubagear_vest",
		timer = 1,
		interact_distance = 130,
		start_active = false,
		blocked_hint = "carry_block"
	}
	self.glc_open_door = {
		text_id = "hud_cas_open_door",
		start_active = true,
		interact_distance = 300,
		can_interact_in_civilian = true
	}
	self.glc_hold_take_handcuffs = {
		text_id = "hud_int_hold_take_handcuffs",
		action_text_id = "hud_int_hold_action_take_handcuffs",
		timer = 1,
		start_active = false
	}
	self.pku_toothbrush = {
		text_id = "hud_int_hold_take_toothbrush",
		action_text_id = "hud_action_taking_toothbrush",
		timer = 3,
		interact_distance = 130,
		start_active = false,
		blocked_hint = "carry_block"
	}
	self.hold_insert_keycard_hlp = {
		text_id = "press_insert_keycard",
		equipment_text_id = "hint_no_keycard",
		special_equipment = "bank_manager_key",
		equipment_consume = true,
		interact_distance = 200
	}
	self.c4_consume_x1 = deep_clone(self.c4_special)
	self.c4_consume_x1.special_equipment = "c4_x1"
	self.c4_consume_x1.equipment_consume = true
	self.repair_wheel = {
		text_id = "hud_int_hold_repair_wheel",
		action_text_id = "hud_action_repair_wheel",
		timer = 3,
		interact_distance = 300,
		sound_start = "bar_drill_fix",
		sound_interupt = "bar_drill_fix_cancel",
		sound_done = "bar_drill_fix_finished"
	}
	self.hold_pull_switch = {
		text_id = "hud_int_hold_pull_switch",
		action_text_id = "hud_action_pulling_switch",
		timer = 1,
		interact_distance = 200,
		start_active = false
	}
	self.sfm_take_usb_key = deep_clone(self.cas_take_usb_key)
	self.sfm_take_usb_key.start_active = true
	self.hold_attach_magnet = {
		text_id = "hud_int_hold_attach_magnet",
		action_text_id = "hud_action_attaching_magnet",
		timer = 3,
		interact_distance = 300,
		sound_start = "bar_attach_magnet",
		sound_interupt = "bar_attach_magnet_cancel",
		sound_done = "bar_attach_magnet_finished"
	}
	self.hold_open_coke_bag = {
		text_id = "hud_int_hold_open_coke",
		action_text_id = "hud_action_opening_coke",
		timer = 2,
		interact_distance = 150,
		start_active = false,
		sound_start = "bar_bag_generic",
		sound_interupt = "bar_bag_generic_cancel",
		sound_done = "bar_bag_generic_finished"
	}
	self.hold_remove_bug = {
		text_id = "hud_mil_hold_remove_bug",
		action_text_id = "hud_action_removing_bug",
		timer = 1,
		interact_distance = 150
	}
	self.hold_open_lid = {
		text_id = "hud_int_hold_open_lid",
		action_text_id = "hud_action_opening_lid",
		timer = 1,
		interact_distance = 150,
		start_active = false
	}
	self.hold_unfold_ladder = {
		text_id = "hud_int_hold_unfold_ladder",
		action_text_id = "hud_action_unfolding_ladder",
		timer = 1,
		interact_distance = 150,
		start_active = false
	}
	self.sfm_laptop = {
		text_id = "hud_int_insert_flash_dive",
		equipment_text_id = "hint_usb_stick",
		special_equipment = "cas_usb_key",
		equipment_consume = true,
		interact_distance = 150
	}
	self.rewire_friend_fuse_box = {
		text_id = "hud_int_hold_rewire_fuse_box",
		action_text_id = "hud_action_rewire_fuse_box",
		timer = 6,
		start_active = false,
		axis = "y",
		sound_start = "bar_hack_fuse_box",
		sound_interupt = "bar_hack_fuse_box_cancel",
		sound_done = "bar_hack_fuse_box_finished"
	}
	self.hold_phone_call_office = {
		text_id = "hud_int_hold_phone_office",
		action_text_id = "hud_action_hold_phone_office",
		timer = 2,
		interact_distance = 150,
		start_active = false
	}
	self.friend_pku_yayo_cocaine = {
		text_id = "hud_int_hold_take_yayo",
		action_text_id = "hud_action_taking_yayo",
		timer = 3,
		sound_start = "bar_bag_money",
		sound_interupt = "bar_bag_money_cancel",
		sound_done = "bar_bag_money_finished",
		blocked_hint = "carry_block"
	}
	self.pickup_keys = {
		icon = "develop",
		text_id = "hud_int_hold_pick_up",
		start_active = true,
		timer = 1,
		action_text_id = "hud_action_picking_up",
		blocked_hint = "hint_key_pickup"
	}
	self.pickup_case = {
		icon = "develop",
		text_id = "hud_int_hold_pick_up",
		start_active = true,
		timer = 1,
		action_text_id = "hud_action_picking_up",
		blocked_hint = "hint_case_pickup"
	}
	self.hold_open_shopping_bag = {
		text_id = "hud_int_hold_open_shopping_bag",
		action_text_id = "hud_action_opening_shopping_bag",
		sound_done = "bar_open_shopping_bag_finish",
		timer = 1,
		interact_distance = 210
	}
	self.hold_take_toy = {
		text_id = "hud_int_hold_take_toy",
		action_text_id = "hud_action_taking_toy",
		timer = 1,
		sound_done = "bar_pick_up_tin_boy_finish",
		interact_distance = 220
	}
	self.hold_take_wine = {
		text_id = "hud_int_hold_take_wine",
		action_text_id = "hud_action_taking_wine",
		timer = 1,
		interact_distance = 220
	}
	self.hold_take_expensive_wine = {
		text_id = "hud_int_hold_take_expensive_wine",
		action_text_id = "hud_action_taking_expensive_wine",
		sound_done = "bar_pick_up_box_wine_finish",
		timer = 1,
		interact_distance = 220
	}
	self.hold_take_diamond_necklace = {
		text_id = "hud_int_hold_take_necklace",
		action_text_id = "hud_action_taking_necklace",
		timer = 1,
		interact_distance = 220
	}
	self.hold_take_vr_headset = {
		text_id = "hud_int_hold_take_vr_headset",
		action_text_id = "hud_action_taking_vr_headset",
		sound_done = "bar_pick_up_box_finish",
		timer = 1,
		interact_distance = 220
	}
	self.hold_take_shoes = {
		text_id = "hud_int_hold_take_shoes",
		action_text_id = "hud_action_taking_shoes",
		timer = 1,
		interact_distance = 220
	}
	self.hold_search_computer = {
		text_id = "hud_int_hold_search_computer",
		action_text_id = "hud_action_searching_computer",
		timer = 5,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished",
		interact_distance = 150
	}
	self.hold_moon_untie = {
		text_id = "hud_int_hold_born_untie",
		timer = 4,
		interact_distance = 150,
		start_active = false,
		sound_start = "bar_untie_hostage_02_loop",
		sound_interupt = "bar_untie_hostage_02_cancel",
		sound_done = "bar_untie_hostage_02_finish"
	}
	self.hold_take_mask = {
		text_id = "hud_int_hold_take_mask",
		action_text_id = "hud_action_taking_mask",
		timer = 1,
		interact_distance = 200
	}
	self.hold_moon_attach_winch = {
		text_id = "hud_int_hold_moon_attach_winch",
		action_text_id = "hud_action_attaching_winch",
		timer = 4,
		interact_distance = 150,
		start_active = false,
		sound_start = "bar_connect_hook_loop",
		sound_interupt = "bar_connect_hook_cancel"
	}
	self.hold_friend_attach_winch = {
		text_id = "hud_int_hold_moon_attach_winch",
		action_text_id = "hud_action_attaching_winch",
		timer = 4,
		interact_distance = 150,
		start_active = false,
		sound_start = "bar_friend_secure_winch",
		sound_interupt = "bar_friend_secure_winch_cancel",
		sound_done = "bar_friend_secure_winch_finished"
	}
	self.c4_consume_x3 = deep_clone(self.c4_special)
	self.c4_consume_x3.special_equipment = "c4_x3"
	self.c4_consume_x3.equipment_consume = true
	self.hold_search_cigar_boxes = {
		text_id = "hud_int_search_cigar_boxes",
		action_text_id = "hud_action_searching_cigar_boxes",
		timer = 1,
		interact_distance = 200,
		start_active = false,
		sound_start = "bar_humidor_start",
		sound_interupt = "bar_humidor_cancel"
	}
	self.money_wrap_active = {
		icon = "interaction_money_wrap",
		text_id = "debug_interact_money_wrap_take_money",
		start_active = true,
		timer = 3,
		action_text_id = "hud_action_taking_money",
		blocked_hint = "carry_block",
		sound_start = "bar_bag_money",
		sound_interupt = "bar_bag_money_cancel",
		sound_done = "bar_bag_money_finished"
	}
	self.hold_search_capsule = {
		text_id = "hud_int_search_capsule",
		action_text_id = "hud_action_searching_capsule",
		timer = 1,
		interact_distance = 200,
		start_active = false,
		sound_start = "bar_lifeboat_case_open",
		sound_interupt = "bar_lifeboat_case_open_cancel"
	}
	self.hold_search_cart = {
		text_id = "hud_int_search_cart",
		action_text_id = "hud_action_searching_cart",
		timer = 1,
		interact_distance = 200,
		start_active = false,
		sound_start = "bar_cart_open",
		sound_interupt = "bar_cart_open_cancel"
	}
	self.hold_open_window = {
		text_id = "hud_int_open_window",
		action_text_id = "hud_action_opening_window",
		timer = 1,
		interact_distance = 200,
		start_active = false,
		sound_start = "bar_sliding_window_open",
		sound_interupt = "bar_sliding_window_open_cancel"
	}
	self.hold_close_window = {
		text_id = "hud_int_close_window",
		action_text_id = "hud_action_closing_window",
		timer = 1,
		interact_distance = 200,
		start_active = false,
		sound_start = "bar_sliding_window_open",
		sound_interupt = "bar_sliding_window_open_cancel"
	}
	self.hold_search_cabinet_a = {
		text_id = "hud_int_search_cabinet",
		action_text_id = "hud_action_searching_cabinet",
		timer = 1,
		interact_distance = 200,
		start_active = false,
		sound_start = "bar_restaurant_kitchen_loop",
		sound_interupt = "bar_restaurant_kitchen_cancel"
	}
	self.hold_search_steel_cabinet = {
		text_id = "hud_int_search_steel_cabinet",
		action_text_id = "hud_action_searching_steel_cabinet",
		timer = 1,
		interact_distance = 200,
		start_active = false,
		sound_start = "bar_restaurant_kitchen_loop",
		sound_interupt = "bar_restaurant_kitchen_cancel"
	}
	self.hold_search_bookshelf = {
		text_id = "hud_int_search_bookshelf",
		action_text_id = "hud_action_searching_bookshelf",
		sound_start = "bar_wall_bookshelf",
		sound_interupt = "bar_wall_bookshelf_cancel",
		timer = 1,
		interact_distance = 200,
		start_active = false,
		axis = "y"
	}
	self.hold_search_drawer = {
		text_id = "hud_int_search_drawer",
		action_text_id = "hud_action_searching_drawer",
		timer = 1,
		interact_distance = 200,
		start_active = false,
		sound_start = "bar_desk_drawer_loop",
		sound_interupt = "bar_desk_drawer_cancel"
	}
	self.hold_search_drawers = {
		text_id = "hud_int_search_drawers",
		action_text_id = "hud_action_searching_drawers",
		timer = 1,
		interact_distance = 200,
		start_active = false,
		sound_start = "bar_desk_drawer_loop",
		sound_interupt = "bar_desk_drawer_cancel"
	}
	self.hold_search_shower = {
		text_id = "hud_int_search_shower",
		action_text_id = "hud_action_searching_shower",
		timer = 1,
		interact_distance = 200,
		start_active = false,
		sound_start = "bar_main_bath_shower_open",
		sound_interupt = "bar_main_bath_shower_open_cancel"
	}
	self.hold_search_luggage = {
		text_id = "hud_int_search_luggage",
		action_text_id = "hud_action_searching_luggage",
		sound_start = "bar_luggage_set_open",
		sound_interupt = "bar_luggage_set_open_cancel",
		timer = 1,
		interact_distance = 200,
		start_active = false
	}
	self.hold_search_flightcase = {
		text_id = "hud_int_search_case",
		action_text_id = "hud_action_searching_case",
		timer = 1,
		interact_distance = 200,
		start_active = false,
		sound_start = "bar_backstage_flightcase_open",
		sound_interupt = "bar_backstage_flightcase_open_cancel"
	}
	self.hold_search_fridge = {
		text_id = "hud_int_search_fridge",
		action_text_id = "hud_action_searching_fridge",
		timer = 1,
		interact_distance = 200,
		start_active = false,
		sound_start = "bar_restaurant_kitchen_loop",
		sound_interupt = "bar_restaurant_kitchen_cancel"
	}
	self.hold_search_display_case = {
		text_id = "hud_int_search_display_case",
		action_text_id = "hud_action_searching_display_case",
		timer = 1,
		interact_distance = 200,
		start_active = false,
		sound_start = "bar_humidor_start",
		sound_interupt = "bar_humidor_cancel"
	}
	self.hold_search_washer = {
		text_id = "hud_int_search_washer",
		action_text_id = "hud_action_searching_washer",
		timer = 1,
		interact_distance = 200,
		start_active = false,
		sound_start = "bar_restaurant_kitchen_loop",
		sound_interupt = "bar_restaurant_kitchen_cancel"
	}
	self.hold_type_in_password = {
		text_id = "hud_int_type_in_password",
		action_text_id = "hud_action_typing_in_password",
		timer = 5,
		interact_distance = 200,
		start_active = false,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.hold_hack_server_room = deep_clone(self.hold_type_in_password)
	self.hold_hack_server_room.text_id = "hud_int_hack_server_room"
	self.hold_hack_server_room.action_text_id = "hud_action_hacking_server_room"
	self.hold_turn_off = {
		text_id = "hud_int_turn_off",
		action_text_id = "hud_action_turning_off",
		timer = 4,
		interact_distance = 200,
		start_active = false,
		sound_start = "bar_turn_off_cooling_system_start",
		sound_interupt = "bar_turn_off_cooling_system_cancel"
	}
	self.press_play_jacket_sound = {
		text_id = "hud_press_play_jacket_sound",
		interact_distance = 200
	}
	self.hold_move_car_spa = {
		text_id = "hud_int_hold_move_car",
		action_text_id = "hud_action_moving_car",
		start_active = false,
		timer = 3,
		interact_distance = 220,
		sound_start = "bar_cop_car",
		sound_interupt = "bar_cop_car_cancel",
		sound_done = "bar_cop_car_finished"
	}
	self.pry_open_door_elevator = {
		icon = "equipment_crowbar",
		text_id = "hud_int_pry_open_elevator_door",
		action_text_id = "hud_action_prying_open_elevator_door",
		equipment_text_id = "debug_interact_equipment_crowbar",
		special_equipment = "crowbar",
		timer = 8,
		start_active = false,
		sound_start = "bar_elevator_crowbar_open",
		sound_interupt = "bar_elevator_crowbar_cancel"
	}
	self.hold_signal_mr_blonde = {
		text_id = "hud_int_hold_signal_mr_blonde",
		action_text_id = "hud_int_hold_action_signaling_mr_blonde",
		timer = 4
	}
	self.hold_take_diamond_briefcase = {
		text_id = "hud_int_hold_take_diamond_briefcase",
		action_text_id = "hud_int_hold_action_take_diamond_breifcase",
		timer = 1
	}
	self.press_hand_over_diamond_briefcase = {
		text_id = "hud_int_press_hand_over_breifcase",
		equipment_text_id = "hud_hint_no_briefcase",
		special_equipment = "briefcase_diamond",
		equipment_consume = true
	}
	self.press_pour_liquid_nitrogen = {
		text_id = "hud_int_press_pour_liquid_nitrogen",
		equipment_text_id = "hud_hint_no_liquid_nitrogen",
		special_equipment = "hydrogen_chloride",
		equipment_consume = true
	}
	self.press_take_liquid_nitrogen = {
		text_id = "hud_int_take_liquid_nitrogen",
		start_active = false,
		special_equipment_block = "liquid_nitrogen",
		sound_done = "liquid_nitrogen_pick_up"
	}
	self.hold_place_liquid_nitrogen = {
		text_id = "hud_int_hold_place_liquid_nitrogen",
		action_text_id = "hud_action_placing_liquid_nitrogen",
		equipment_text_id = "hud_equipment_liquid_nitrogen",
		special_equipment = "liquid_nitrogen",
		equipment_consume = true,
		timer = 4,
		sound_done = "bar_liquid_nitrogen_attach_finished",
		sound_start = "bar_liquid_nitrogen_attach",
		sound_interupt = "bar_liquid_nitrogen_attach_cancel"
	}
	self.hold_remove_liquid_nitrogen = {
		text_id = "hud_int_hold_remove_liquid_nitrogen",
		action_text_id = "hud_int_hold_action_removing_liquid_nitrogen",
		timer = 2
	}
	self.hold_cut_wires = {
		text_id = "hud_int_hold_cut_wires",
		action_text_id = "hud_int_hold_action_cutting_wires",
		timer = 4,
		start_active = false,
		axis = "y",
		sound_start = "bar_wire_cut",
		sound_interupt = "bar_wire_cut_cancel",
		sound_done = "bar_wire_cut_finished"
	}
	self.hold_rvd_open_vault = {
		text_id = "hud_int_hold_open_vault",
		action_text_id = "hud_action_opening_vault",
		timer = 2,
		start_active = false
	}
	self.invisible_interaction_open_axis_rvd = deep_clone(self.invisible_interaction_open)
	self.invisible_interaction_open_axis_rvd.axis = "y"
	self.invisible_interaction_open_axis_rvd.sound_start = "bar_train_panel_hacking"
	self.invisible_interaction_open_axis_rvd.sound_interupt = "bar_train_panel_hacking_cancel"
	self.invisible_interaction_open_axis_rvd.sound_done = "bar_train_panel_hacking_finished"
	self.press_take_folder = {
		text_id = "hud_int_german_folder",
		interact_distance = 200,
		start_active = true
	}
	self.hold_take_old_wine = {
		text_id = "hud_int_old_wine",
		action_text_id = "hud_action_old_wine",
		start_active = true,
		timer = 3,
		interact_distance = 150
	}
	self.take_jfr_briefcase = {
		text_id = "hud_take_briefcase",
		action_text_id = "hud_action_taking_briefcase",
		special_equipment_block = "briefcase",
		start_active = true,
		timer = 1
	}
	self.hold_take_missing_animal_poster = {
		text_id = "hud_int_take_missing_animal_poster",
		action_text_id = "hud_action_taking_missing_animal_poster",
		timer = 0.5,
		interact_distance = 200,
		start_active = false,
		sound_done = "pick_up_poster"
	}
	self.hold_pick_up_turtle = {
		text_id = "hud_int_hold_pick_up_turtle",
		action_text_id = "hud_action_picking_up_turtle",
		start_active = true,
		timer = 1,
		interact_distance = 90
	}
	self.hold_help_turtle = {
		text_id = "hud_int_hold_to_help_turtle",
		action_text_id = "hud_action_helping_turtle",
		start_active = true,
		timer = 1,
		interact_distance = 150
	}
	self.hold_generator_start = {
		text_id = "hud_generator_start",
		action_text_id = "hud_action_generator_start",
		start_active = false,
		timer = 3,
		interact_distance = 300,
		sound_start = "bar_water_pump",
		sound_cancel = "bar_water_pump_cancel",
		sound_done = "bar_water_pump_finish"
	}
	self.hold_remove_rope = {
		text_id = "hud_int_remove_rope",
		action_text_id = "hud_action_remove_rope",
		start_active = true,
		timer = 3,
		interact_distance = 150,
		sound_start = "bar_remove_rope_start",
		sound_cancel = "bar_remove_rope_cancel",
		sound_done = "bar_remove_rope_finish"
	}
	self.hold_move_gangplank = {
		text_id = "hud_int_move_gangplank",
		action_text_id = "hud_action_moving_gangplank",
		start_active = true,
		timer = 3,
		interact_distance = 300
	}
	self.hold_wwh_untie = {
		text_id = "hud_int_hold_born_untie",
		timer = 4,
		interact_distance = 150,
		start_active = false,
		sound_start = "bar_untie_hostage_start_02",
		sound_interupt = "bar_untie_hostage_cancel_02",
		sound_done = "bar_untie_hostage_finish_02"
	}
	self.connect_hose_wwh = {
		icon = "develop",
		text_id = "hud_int_hold_connect_hose",
		action_text_id = "hud_action_connect_hose",
		start_active = false,
		timer = 4,
		interact_distance = 200,
		sound_start = "bar_hose_drag_out",
		sound_interupt = "bar_hose_drag_out_cancel",
		sound_done = "bar_hose_drag_out_finish"
	}
	self.connect_hose_ship_wwh = {
		icon = "develop",
		text_id = "hud_int_hold_connect_hose",
		action_text_id = "hud_action_connect_hose",
		start_active = false,
		timer = 4,
		interact_distance = 200,
		sound_start = "bar_hose_attach_to_ship",
		sound_interupt = "bar_hose_attach_to_ship_cancel",
		sound_done = "bar_hose_attach_to_ship_finish"
	}
	self.connect_hose_pump_wwh = {
		icon = "develop",
		text_id = "hud_int_hold_connect_hose",
		action_text_id = "hud_action_connect_hose",
		start_active = false,
		timer = 4,
		interact_distance = 200,
		sound_start = "bar_hose_attach_to_water_pump",
		sound_interupt = "bar_hose_attach_to_water_pump_cancel",
		sound_done = "bar_hose_attach_to_water_pump_finish"
	}
	self.detach_hose_wwh = {
		icon = "develop",
		text_id = "hud_int_hold_detach_hose",
		action_text_id = "hud_action_detach_hose",
		start_active = false,
		timer = 4,
		interact_distance = 200,
		sound_start = "bar_hose_ground_connect",
		sound_interupt = "bar_hose_ground_connect_cancel",
		sound_done = "bar_hose_ground_connect_finished"
	}
	self.open_lid_wwh = {
		text_id = "hud_int_invisible_interaction_open",
		start_active = true,
		interact_distance = 150
	}
	self.take_confidential_folder_icc = {
		text_id = "hud_int_take_confidential_folder_icc",
		start_active = false,
		timer = 1,
		interact_distance = 100
	}
	self.hack_dah_jammed_x = deep_clone(self.hack_suburbia_jammed)
	self.hack_dah_jammed_x.axis = "x"
	self.diamond_pickup_3sec = {
		icon = "interaction_diamond",
		text_id = "hud_int_take_diamond",
		action_text_id = "hud_action_taking_diamond",
		sound_event = "money_grab",
		start_active = false,
		timer = 3,
		requires_mask_off_upgrade = {
			upgrade = "mask_off_pickup",
			category = "player"
		}
	}
	self.diamonds_pickup = {
		icon = "interaction_diamond",
		text_id = "hud_int_take_diamonds_dah",
		action_text_id = "hud_action_taking_diamonds_dah",
		sound_event = "money_grab",
		start_active = false,
		timer = 3,
		axis = "y",
		requires_mask_off_upgrade = {
			upgrade = "mask_off_pickup",
			category = "player"
		}
	}
	self.diamonds_pickup_full = {
		icon = "interaction_diamond",
		text_id = "hud_int_take_diamonds_dah",
		action_text_id = "hud_action_taking_diamonds_dah",
		sound_event = "money_grab",
		start_active = false,
		timer = 3,
		requires_mask_off_upgrade = {
			upgrade = "mask_off_pickup",
			category = "player"
		}
	}
	self.red_diamond_pickup = {
		icon = "interaction_diamond",
		text_id = "hud_int_take_red_diamond",
		action_text_id = "hud_action_taking_red_diamond",
		sound_event = "money_grab",
		start_active = false,
		timer = 3,
		axis = "x",
		requires_mask_off_upgrade = {
			upgrade = "mask_off_pickup",
			category = "player"
		}
	}
	self.red_diamond_pickup_no_axis = {
		icon = "interaction_diamond",
		text_id = "hud_int_take_red_diamond",
		action_text_id = "hud_action_taking_red_diamond",
		sound_event = "money_grab",
		start_active = false,
		timer = 3,
		requires_mask_off_upgrade = {
			upgrade = "mask_off_pickup",
			category = "player"
		}
	}
	self.dah_panicroom_keycard = {
		text_id = "hud_int_open_panicroom",
		action_text_id = "hud_action_open_panicroom",
		equipment_text_id = "hud_int_equipment_no_keycard",
		special_equipment = "bank_manager_key",
		equipment_consume = true,
		start_active = true,
		timer = 0.5
	}
	self.diamond_pickup_axis = {
		icon = "interaction_diamond",
		text_id = "hud_int_take_jewelry",
		sound_event = "money_grab",
		axis = "y",
		start_active = false,
		requires_mask_off_upgrade = {
			upgrade = "mask_off_pickup",
			category = "player"
		}
	}
	self.hold_to_choose_mask = {
		text_id = "hud_int_hold_to_choose_mask",
		action_text_id = "hud_action_choosing_mask",
		axis = "y",
		start_active = true,
		timer = 3,
		interact_distance = 150
	}
	self.hold_take_mask_axis = {
		text_id = "hud_int_hold_take_mask",
		action_text_id = "hud_action_taking_mask",
		timer = 1,
		axis = "z",
		interact_distance = 200
	}
	self.hold_search_toilet = {
		text_id = "hud_int_hold_search_toilet",
		action_text_id = "hud_action_searching_toilet",
		timer = 1,
		interact_distance = 200,
		start_active = false
	}
	self.hold_search_dumpster = {
		text_id = "hud_int_hold_search_dumpster",
		action_text_id = "hud_action_searching_dumpster",
		timer = 1,
		interact_distance = 200,
		start_active = false
	}
	self.hold_cut_tarp = {
		text_id = "hud_int_hold_cut_tarp",
		action_text_id = "hud_action_cutting_tarp",
		sound_start = "bar_cut_tarp_loop",
		sound_interupt = "bar_cut_tarp_cancel",
		sound_done = "bar_cut_tarp_finish",
		timer = 3,
		interact_distance = 200,
		start_active = true
	}
	self.hold_new_hack = {
		text_id = "hud_int_hold_start_new_hack",
		action_text_id = "hud_action_starting_new_hack",
		start_active = false,
		timer = 3,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.hold_take_medallion = {
		text_id = "hud_int_hold_take_medallion",
		action_text_id = "hud_action_taking_medallion",
		timer = 2,
		start_active = false,
		special_equipment_block = "medallion",
		sound_done = "liquid_nitrogen_pick_up"
	}
	self.apply_thermite_paste_no_consume = deep_clone(self.apply_thermite_paste)
	self.apply_thermite_paste_no_consume.equipment_consume = false
	self.apply_thermite_paste_no_consume.special_equipment = "thermite"
	self.brb_connect_winch_hook = {
		text_id = "hud_connect_which_hook_brb",
		action_text_id = "hud_action_connecting_which_hook_brb",
		equipment_text_id = "hint_no_winch_hook",
		special_equipment = "cas_winch_hook",
		start_active = false,
		interact_distance = 200,
		timer = 2,
		equipment_consume = true
	}
	self.press_insert_sample = {
		text_id = "hud_int_insert_blood_sample",
		equipment_text_id = "hint_no_blood_sample",
		special_equipment = "blood_sample",
		interact_distance = 150,
		start_active = false,
		equipment_consume = true
	}
	self.press_take_sample = {
		text_id = "hud_int_take_blood_sample",
		special_equipment_block = "blood_sample",
		interact_distance = 150,
		start_active = false
	}
	self.press_touch_book = {
		text_id = "hud_int_touch_book",
		interact_distance = 150,
		start_active = false
	}
	self.hold_take_sample = {
		text_id = "hud_int_hold_take_blood_sample",
		action_text_id = "hud_action_taking_blood_sample",
		special_equipment_block = "blood_sample",
		interact_distance = 150,
		start_active = false,
		timer = 3
	}
	self.hold_take_sample_valid = {
		text_id = "hud_int_hold_take_blood_valid_sample",
		action_text_id = "hud_action_taking_blood_valid_sample",
		special_equipment_block = "blood_sample_verified",
		interact_distance = 150,
		start_active = false
	}
	self.hold_stash_vial = {
		text_id = "hud_int_hold_stash_vial",
		action_text_id = "hud_action_stashing_vial",
		equipment_text_id = "hint_no_blood_sample",
		special_equipment = "blood_sample_verified",
		timer = 3,
		interact_distance = 150,
		start_active = false,
		equipment_consume = true
	}
	self.press_call_elevator = {
		text_id = "hud_int_call_elevator",
		interact_distance = 150,
		start_active = false
	}
	self.hold_check_file = {
		text_id = "hud_int_hold_check_file",
		action_text_id = "hud_action_checking_file",
		timer = 3,
		interact_distance = 150,
		start_active = false,
		sound_start = "bar_shuffle_papers",
		sound_interupt = "bar_shuffle_papers_cancel",
		sound_done = "bar_shuffle_papers_finished"
	}
	self.breach_crowbar = {
		text_id = "hud_int_hold_breach",
		action_text_id = "hud_action_breach",
		equipment_text_id = "debug_interact_equipment_crowbar",
		special_equipment = "crowbar",
		start_active = false,
		timer = 8,
		sound_start = "bar_pry_open_elevator_door",
		sound_interupt = "bar_pry_open_elevator_door_cancel",
		sound_done = "bar_pry_open_elevator_door_finished"
	}
	self.hold_place_sentry = {
		text_id = "hud_int_set_up_sentry",
		action_text_id = "hud_action_set_up_sentry",
		timer = 3,
		interact_distance = 150,
		start_active = false
	}
	self.tag_laptop = {
		text_id = "hud_int_hack_laptop",
		action_text_id = "hud_action_hack_laptop",
		timer = 3,
		axis = "y",
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.hold_new_hack_tag = {
		text_id = "hud_int_hold_start_new_hack",
		action_text_id = "hud_action_starting_new_hack",
		start_active = false,
		timer = 3,
		axis = "y",
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.tag_take_unknown = {
		text_id = "hud_int_hold_take_box",
		action_text_id = "hud_action_taking_box",
		timer = 2,
		interact_distance = 200,
		start_active = false
	}
	self.press_take_chimichanga = {
		text_id = "hud_int_press_take_chimichanga",
		interact_distance = 150,
		special_equipment_block = "chimichanga",
		start_active = false
	}
	self.press_place_chimichanga = {
		text_id = "hud_int_press_place_chimichanga",
		special_equipment = "chimichanga",
		equipment_text_id = "hud_int_need_chimichanga",
		equipment_consume = true,
		interact_distance = 150,
		start_active = false
	}
	self.hacking_barrier = {
		text_id = "hud_int_hold_hack_barrier",
		action_text_id = "hud_action_hack_barrier",
		timer = 4,
		interact_distance = 150,
		start_active = false,
		sound_start = "bar_pick_lock",
		sound_interupt = "bar_pick_lock_cancel",
		sound_done = "bar_pick_lock_finished"
	}
	self.hold_disable_alarm = {
		text_id = "hud_int_hold_disable_alarm",
		action_text_id = "hud_action_disabling_alarm",
		interact_distance = 150,
		timer = 2,
		start_active = false
	}
	self.hold_open_the_safe = {
		text_id = "hud_int_hold_open_safe",
		action_text_id = "hud_action_opening_safe",
		interact_distance = 150,
		timer = 1,
		start_active = false
	}
	self.hold_turn_off_light = {
		text_id = "hud_int_hold_turn_off_light",
		action_text_id = "hud_action_turning_off_light",
		interact_distance = 150,
		timer = 1,
		start_active = false
	}
	self.hold_relay_locke = {
		text_id = "hud_int_hold_relay_locke",
		action_text_id = "hud_action_relaying_locke",
		interact_distance = 150,
		timer = 3,
		start_active = false,
		axis = "y"
	}
	self.press_knock_on_door = {
		text_id = "hud_int_press_knock_on_door",
		interact_distance = 150,
		start_active = false
	}
	self.press_take_elevator = {
		text_id = "hud_int_press_take_elevator",
		interact_distance = 150,
		start_active = false
	}
	self.tag_take_stapler = {
		text_id = "hud_take_stapler",
		interact_distance = 100,
		start_active = true
	}
	self.press_place_stapler = {
		text_id = "hud_int_press_place_stapler",
		equipment_text_id = "hud_hint_no_stapler",
		special_equipment = "stapler",
		equipment_consume = true,
		interact_distance = 150,
		start_active = false
	}
	self.push_button_secret = {
		text_id = "hud_int_push_button",
		interact_distance = 90,
		axis = "z"
	}
	self.hold_charge_gun = {
		icon = "equipment_hack_ipad",
		text_id = "hold_interact_charge_gun",
		timer = 5,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished",
		axis = "y"
	}
	self.hold_mix_concoction = {
		text_id = "hud_int_hold_mix_concoction",
		action_text_id = "hud_action_mixing_concoction",
		special_equipment_block = "concoction",
		interact_distance = 150,
		timer = 3,
		start_active = false,
		sound_start = "bar_mix_compounds_start",
		sound_interupt = "bar_mix_compounds_cancel",
		sound_done = "bar_mix_compounds_finish"
	}
	self.hold_take_concoction = {
		text_id = "hud_int_hold_take_concoction",
		action_text_id = "hud_action_taking_concoction",
		special_equipment_block = "concoction",
		interact_distance = 150,
		timer = 1,
		start_active = false,
		sound_done = "liquid_nitrogen_pick_up"
	}
	self.apply_concoction_paste = {
		text_id = "hud_int_hold_ignite_concoction",
		action_text_id = "hud_action_ignite_concoction",
		special_equipment = "concoction",
		equipment_text_id = "hud_int_need_concoction_paste",
		equipment_consume = true,
		start_active = false,
		contour = "interactable_icon",
		timer = 2,
		sound_start = "bar_thermal_lance_fix",
		sound_interupt = "bar_thermal_lance_fix_cancel",
		sound_done = "bar_thermal_lance_fix_finished"
	}
	self.push_button_des = {
		text_id = "hud_int_push_button",
		axis = "z"
	}
	self.hold_push_button = {
		text_id = "hud_int_push_button",
		action_text_id = "hud_action_pushing_button",
		axis = "z"
	}
	self.hold_move_crane = {
		text_id = "hud_int_hold_move_crane",
		action_text_id = "hud_action_moving_crane",
		timer = 2,
		sound_start = "bar_crane_control_panel",
		sound_interupt = "bar_crane_control_panel_cancel",
		sound_done = "bar_crane_control_panel_finished"
	}
	self.hold_search_documents = {
		text_id = "hud_int_hold_search_documents",
		action_text_id = "hud_int_hold_action_searching_documents",
		timer = 2,
		sound_start = "bar_shuffle_papers",
		sound_interupt = "bar_shuffle_papers_cancel",
		sound_done = "bar_shuffle_papers_finished"
	}
	self.des_take_unknown = {
		text_id = "hud_int_hold_take_box",
		action_text_id = "hud_action_taking_box",
		timer = 2,
		interact_distance = 200,
		start_active = false
	}
	self.hold_add_compound_a = {
		text_id = "hud_int_hold_add_compound_a",
		action_text_id = "hud_action_adding_compound",
		equipment_text_id = "hint_no_compound_a",
		special_equipment = "compound_a",
		timer = 2,
		equipment_consume = true,
		interact_distance = 150,
		start_active = false,
		sound_start = "liquid_pour",
		sound_interupt = "liquid_pour_stop",
		sound_done = "liquid_pour_stop"
	}
	self.hold_add_compound_b = {
		text_id = "hud_int_hold_add_compound_b",
		action_text_id = "hud_action_adding_compound",
		equipment_text_id = "hint_no_compound_b",
		special_equipment = "compound_b",
		timer = 2,
		equipment_consume = true,
		interact_distance = 150,
		start_active = false,
		sound_start = "liquid_pour",
		sound_interupt = "liquid_pour_stop",
		sound_done = "liquid_pour_stop"
	}
	self.hold_add_compound_c = {
		text_id = "hud_int_hold_add_compound_c",
		action_text_id = "hud_action_adding_compound",
		equipment_text_id = "hint_no_compound_c",
		special_equipment = "compound_c",
		timer = 2,
		equipment_consume = true,
		interact_distance = 150,
		start_active = false,
		sound_start = "liquid_pour",
		sound_interupt = "liquid_pour_stop",
		sound_done = "liquid_pour_stop"
	}
	self.hold_add_compound_d = {
		text_id = "hud_int_hold_add_compound_d",
		action_text_id = "hud_action_adding_compound",
		equipment_text_id = "hint_no_compound_d",
		special_equipment = "compound_d",
		timer = 2,
		equipment_consume = true,
		interact_distance = 150,
		start_active = false,
		sound_start = "liquid_pour",
		sound_interupt = "liquid_pour_stop",
		sound_done = "liquid_pour_stop"
	}
	self.hold_take_compound_a = {
		text_id = "hud_int_hold_take_compound_a",
		special_equipment_block = "compound_a",
		interact_distance = 150,
		start_active = false,
		sound_done = "liquid_nitrogen_pick_up"
	}
	self.hold_take_compound_b = {
		text_id = "hud_int_hold_take_compound_b",
		special_equipment_block = "compound_b",
		interact_distance = 150,
		start_active = false,
		sound_done = "liquid_nitrogen_pick_up"
	}
	self.hold_take_compound_c = {
		text_id = "hud_int_hold_take_compound_c",
		special_equipment_block = "compound_c",
		interact_distance = 150,
		start_active = false,
		sound_done = "liquid_nitrogen_pick_up"
	}
	self.hold_take_compound_d = {
		text_id = "hud_int_hold_take_compound_d",
		special_equipment_block = "compound_d",
		interact_distance = 150,
		start_active = false,
		sound_done = "liquid_nitrogen_pick_up"
	}
	self.hold_take_battery = {
		text_id = "hud_int_hold_take_battery",
		action_text_id = "hud_int_hold_action_taking_battery",
		interact_distance = 210,
		timer = 2,
		start_active = false
	}
	self.hold_remove_battery = {
		text_id = "hud_int_hold_remove_battery",
		action_text_id = "hud_int_hold_action_removing_battery",
		interact_distance = 200,
		start_active = false
	}
	self.hold_aim_laser = {
		text_id = "hud_int_hold_aim_laser",
		action_text_id = "hud_int_hold_action_aiming_laser",
		interact_distance = 150,
		timer = 2,
		start_active = false
	}
	self.hold_fire_laser = {
		text_id = "hud_int_press_fire_laser",
		interact_distance = 150,
		start_active = false,
		sound_done = "bar_laser_weapon_button_push_finished"
	}
	self.press_pay_respects = {
		text_id = "hud_int_press_pay_respects",
		interact_distance = 150,
		start_active = false
	}
	self.hold_place_device = {
		text_id = "hud_int_hold_to_place_device",
		action_text_id = "hud_action_placing_device",
		start_active = true,
		timer = 3,
		interact_distance = 150,
		sound_start = "bar_plant_breaching_detonator",
		sound_interupt = "bar_plant_breaching_detonator_cancel",
		sound_done = "bar_plant_breaching_detonator_finished"
	}
	self.hold_take_tablet = {
		text_id = "hud_int_hold_to_take_tablet",
		action_text_id = "hud_action_taking_tablet",
		start_active = true,
		timer = 3,
		interact_distance = 150
	}
	self.hold_take_wrench = {
		text_id = "hud_int_hold_take_wrench",
		action_text_id = "hud_action_taking_wrench",
		start_active = false,
		timer = 1,
		interact_distance = 150
	}
	self.invisible_interaction_open_axis_sah = deep_clone(self.invisible_interaction_open)
	self.invisible_interaction_open_axis_sah.axis = "y"
	self.invisible_interaction_open_axis_sah.sound_start = "bar_train_panel_hacking"
	self.invisible_interaction_open_axis_sah.sound_interupt = "bar_train_panel_hacking_cancel"
	self.invisible_interaction_open_axis_sah.sound_done = "bar_train_panel_hacking_finished"
	self.invisible_interaction_open_axis_sah.timer = 4
	self.hold_extend_bridge = {
		axis = "y",
		text_id = "hud_int_press_extend_bridge",
		interact_distance = 150,
		start_active = false
	}
	self.hold_pull_switch_distance = {
		text_id = "hud_int_hold_pull_switch",
		action_text_id = "hud_action_pulling_switch",
		timer = 1,
		interact_distance = 90,
		start_active = false
	}
	self.take_pardons = {
		text_id = "hud_int_hold_take_pardons",
		action_text_id = "hud_action_taking_pardons",
		interact_distance = 150,
		start_active = false,
		timer = 1,
		axis = "y"
	}
	self.vit_take_usb_key = {
		text_id = "hud_int_hold_search_usb_key",
		special_equipment_block = "cas_usb_key",
		interact_distance = 150,
		start_active = false,
		timer = 3
	}
	self.vit_search = {
		text_id = "hud_int_hold_search_books",
		action_text_id = "hud_action_search_books",
		interact_distance = 150,
		start_active = false,
		timer = 1
	}
	self.vit_search_clues = {
		text_id = "hud_int_hold_search_clues",
		action_text_id = "hud_action_searching_clues",
		interact_distance = 150,
		start_active = false,
		timer = 3,
		timer = 3,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.vit_remove_painting = {
		text_id = "hud_int_hold_remove_painting",
		action_text_id = "hud_action_removing_painting",
		interact_distance = 150,
		start_active = false,
		timer = 3,
		sound_start = "bar_steal_painting",
		sound_interupt = "bar_steal_painting_cancel",
		sound_done = "bar_steal_painting_finished"
	}
	self.vit_insert_usb = {
		text_id = "hud_int_hold_insert_usb",
		action_text_id = "hud_action_inserting_usb",
		special_equipment = "cas_usb_key",
		equipment_text_id = "hint_no_usb_key",
		equipment_consume = true,
		interact_distance = 150,
		start_active = false,
		timer = 3
	}
	self.gen_pku_thermite_timer_3sec = deep_clone(self.gen_pku_thermite)
	self.gen_pku_thermite_timer_3sec.timer = 3
	self.gen_pku_thermite_timer_3sec.start_active = false
	self.vit_keycard_use = {
		text_id = "hud_int_equipment_keycard",
		equipment_text_id = "hud_int_equipment_no_keycard",
		special_equipment = "president_key",
		equipment_consume = true,
		start_active = true,
		axis = "y"
	}
	self.start_hacking = {
		text_id = "hud_int_hold_start_hack",
		action_text_id = "hud_action_starting_hack",
		interact_distance = 150,
		start_active = false,
		timer = 3
	}
	self.postpone_update = {
		text_id = "hud_int_hold_postpone_update",
		action_text_id = "hud_action_postponing_update",
		interact_distance = 150,
		start_active = false,
		timer = 1
	}
	self.reboot_computer = {
		text_id = "hud_int_hold_reboot",
		action_text_id = "hud_action_reboot",
		interact_distance = 150,
		start_active = false,
		timer = 3
	}
	self.bypass_the_firewall = {
		text_id = "hud_int_hold_bypass_firewall",
		action_text_id = "hud_action_bypassing_the_firewall",
		interact_distance = 150,
		start_active = false,
		timer = 3
	}
	self.uno_use_device = {
		text_id = "hud_int_use_device",
		interact_distance = 150,
		start_active = false
	}
	self.uno_assemble_device = {
		text_id = "hud_int_assemble_device",
		action_text_id = "hud_action_assemble_device",
		timer = 7,
		interact_distance = 200,
		start_active = false
	}
	self.uno_pull_lever = {
		text_id = "hud_int_hold_pull_lever",
		action_text_id = "hud_action_pulling_lever",
		interact_distance = 200,
		start_active = false,
		timer = 1
	}
	self.uno_open_door = {
		text_id = "hud_int_hold_open_door",
		action_text_id = "hud_action_opening_door",
		interact_distance = 200,
		start_active = false,
		timer = 1,
		can_interact_only_in_civilian = true
	}
	self.uno_hold_pku_gold = {
		text_id = "hud_int_hold_pku_uno_gold",
		action_text_id = "hud_action_taking_uno_gold",
		timer = 1,
		interact_distance = 200,
		start_active = false
	}
	self.uno_hold_pku_gold_bar = {
		text_id = "hud_int_take_mayan_gold_bar"
	}
	self.uno_hold_pku_gold.action_text_id = "hud_action_taking_mayan_gold_bar"
	self.uno_hold_pku_gold_bar.timer = 1
	self.uno_hold_pku_gold_bar.interact_distance = 200
	self.uno_hold_pku_gold_bar.start_active = false
	self.uno_press_activate = {
		text_id = "hud_int_press_activate",
		timer = 1,
		interact_distance = 150,
		start_active = false
	}
	self.uno_mayan_gold_bar = {
		text_id = "hud_int_place_mayan_gold_bar",
		action_text_id = "hud_action_placing_mayan_gold_bar",
		equipment_text_id = "hud_int_equipment_no_mayan_gold",
		special_equipment = "mayan_gold_bar",
		equipment_consume = true,
		start_active = true
	}
	self.hold_remove_parts = {
		text_id = "hud_int_hold_remove_parts",
		action_text_id = "hud_action_remove_parts",
		start_active = true,
		timer = 3,
		interact_distance = 150,
		sound_start = "bar_bag_generic",
		sound_interupt = "bar_bag_generic_cancel"
	}
	self.press_use_medallion = {
		text_id = "hud_int_press_use_medallion",
		equipment_text_id = "hud_int_hint_medallion",
		special_equipment = "medallion",
		equipment_consume = false,
		start_active = true,
		interact_distance = 150
	}
	self.hold_choose_hand_left = {
		text_id = "hud_int_hold_choose_hand_left",
		action_text_id = "hud_int_hold_action_choose_hand_left",
		timer = 2,
		interact_distance = 200,
		sound_done = "pick_up_poster"
	}
	self.hold_choose_hand_right = {
		text_id = "hud_int_hold_choose_hand_right",
		action_text_id = "hud_int_hold_action_choose_hand_right",
		timer = 2,
		interact_distance = 200,
		sound_done = "pick_up_poster"
	}
	self.hold_search_fridge_des = {
		text_id = "hud_int_search_fridge",
		action_text_id = "hud_action_searching_fridge",
		timer = 10,
		interact_distance = 200,
		start_active = false,
		sound_start = "bar_restaurant_kitchen_loop",
		sound_interupt = "bar_restaurant_kitchen_cancel"
	}
	self.hold_remove_tarp = {
		text_id = "hud_int_remove_tarp",
		action_text_id = "hud_action_removing_tarp",
		timer = 3,
		interact_distance = 200,
		start_active = false,
		sound_start = "bar_cut_tarp",
		sound_interupt = "bar_cut_tarp_cancel",
		sound_done = "bar_cut_tarp_finish"
	}
	self.unlock_gate = {
		text_id = "hud_int_unlock_gate",
		action_text_id = "hud_action_unlock_gate",
		axis = "y",
		timer = 1,
		interact_distance = 250,
		start_active = false,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel"
	}
	self.mex_pickup_meth_bag = {
		text_id = "hud_int_hold_grab_the_bag",
		action_text_id = "hud_action_grabbing_bag",
		start_active = true,
		timer = 3
	}
	self.hold_generator_start_directional = {
		text_id = "hud_generator_start",
		action_text_id = "hud_action_generator_start",
		start_active = false,
		timer = 4,
		interact_distance = 300,
		sound_start = "bar_water_pump",
		sound_cancel = "bar_water_pump_cancel",
		sound_interupt = "bar_water_pump_cancel",
		sound_done = "bar_water_pump_finish",
		axis = "y"
	}
	self.mex_red_room_key = {
		icon = "equipment_bank_manager_key",
		text_id = "hud_int_pickup_asset",
		equipment_text_id = "hud_int_pickup_asset",
		special_equipment = "keychain",
		sound_done = "pickup_key",
		equipment_consume = true,
		interact_distance = 150
	}
	self.mex_red_door = {
		icon = "equipment_bank_manager_key",
		text_id = "hud_cas_open_door",
		equipment_text_id = "hud_action_try_keys_no_key",
		special_equipment = "keychain",
		sound_start = "bar_unlock_grate_door",
		sound_interupt = "bar_unlock_grate_door_cancel",
		sound_done = "bar_unlock_grate_door_finished",
		equipment_consume = true,
		interact_distance = 150
	}
	self.money_wrap_updating_directional = deep_clone(self.money_wrap_updating)
	self.money_wrap_updating_directional.axis = "y"
	self.gen_pku_cocaine_directional = deep_clone(self.gen_pku_cocaine)
	self.gen_pku_cocaine_directional.axis = "y"
	self.connect_hose_directional = deep_clone(self.connect_hose)
	self.mex_pickup_murky_uniforms = {
		text_id = "hud_int_mex_pickup_murky_uniforms",
		action_text_id = "hud_action_mex_pickup_murky_uniforms",
		start_active = true,
		timer = 1,
		interact_distance = 250,
		start_active = false,
		sound_start = "play_bag_generic_pickup"
	}
	self.roman_armor = deep_clone(self.samurai_armor)
	self.roman_armor.text_id = "hud_int_hold_bag_ro_armor"
	self.roman_armor.action_text_id = "hud_action_bagging_ro_armor"
	self.hold_take_vault_blueprint = deep_clone(self.hold_take_blueprints)
	self.hold_take_vault_blueprint.icon = "equipment_blueprint"
	self.connect_hose_wwh_short_distance = deep_clone(self.connect_hose_wwh)
	self.connect_hose_wwh_short_distance.interact_distance = 100
	self.detach_hose_wwh_short_distance = deep_clone(self.detach_hose_wwh)
	self.detach_hose_wwh_short_distance.interact_distance = 100
	self.mex_gasoline = {
		icon = "equipment_thermite",
		text_id = "debug_interact_gas",
		equipment_text_id = "debug_interact_equipment_gas",
		special_equipment = "gas",
		equipment_consume = true,
		interact_distance = 300,
		axis = "y"
	}
	self.connect_hose_mex = {
		icon = "develop",
		text_id = "hud_int_hold_connect_hose",
		action_text_id = "hud_action_connect_hose",
		start_active = false,
		timer = 4,
		interact_distance = 200,
		sound_start = "bar_hose_drag_out",
		sound_interupt = "bar_hose_drag_out_cancel",
		sound_done = "bar_hose_drag_out_finish",
		axis = "y"
	}
end
