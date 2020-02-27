EquipmentsTweakData = EquipmentsTweakData or class()

function EquipmentsTweakData:init()
	self.sentry_id_strings = {
		Idstring("units/payday2/equipment/gen_equipment_sentry/gen_equipment_sentry"),
		Idstring("units/payday2/equipment/gen_equipment_sentry/gen_equipment_sentry_silent")
	}
	self.trip_mine = {
		deploy_time = 2,
		dummy_unit = "units/payday2/equipment/gen_equipment_tripmine/gen_equipment_tripmine_dummy",
		use_function_name = "use_trip_mine",
		text_id = "debug_trip_mine",
		visual_object = "g_toolbag",
		icon = "equipment_trip_mine",
		description_id = "des_trip_mine",
		quantity = {
			3,
			3
		},
		upgrade_deploy_time_multiplier = {
			upgrade = "trip_mine_deploy_time_multiplier",
			category = "player"
		},
		upgrade_name = {
			"trip_mine",
			"shape_charge"
		}
	}
	self.ammo_bag = {
		deploy_time = 2,
		use_function_name = "use_ammo_bag",
		dummy_unit = "units/payday2/equipment/gen_equipment_ammobag/gen_equipment_ammobag_dummy_unit",
		text_id = "debug_ammo_bag",
		icon = "equipment_ammo_bag",
		description_id = "des_ammo_bag",
		visual_object = "g_ammobag",
		quantity = {
			1
		}
	}
	self.doctor_bag = {
		deploy_time = 2,
		dummy_unit = "units/payday2/equipment/gen_equipment_medicbag/gen_equipment_medicbag_dummy_unit",
		use_function_name = "use_doctor_bag",
		text_id = "debug_doctor_bag",
		visual_object = "g_medicbag",
		icon = "equipment_doctor_bag",
		description_id = "des_doctor_bag",
		quantity = {
			1
		},
		upgrade_deploy_time_multiplier = {
			upgrade = "deploy_time_multiplier",
			category = "first_aid_kit"
		}
	}
	self.flash_grenade = {
		use_function_name = "use_flash_grenade",
		icon = "equipment_ammo_bag",
		action_timer = 2
	}
	self.smoke_grenade = {
		use_function_name = "use_smoke_grenade",
		icon = "equipment_ammo_bag",
		action_timer = 2
	}
	self.frag_grenade = {
		use_function_name = "use_frag_grenade",
		icon = "equipment_ammo_bag",
		action_timer = 2
	}
	self.sentry_gun = {
		deploy_time = 1,
		dummy_unit = "units/payday2/equipment/gen_equipment_sentry/gen_equipment_sentry_dummy",
		text_id = "debug_sentry_gun",
		use_function_name = "use_sentry_gun",
		unit = 1,
		min_ammo_cost = 0.8,
		ammo_cost = 0.7,
		visual_object = "g_sentrybag",
		icon = "equipment_sentry",
		description_id = "des_sentry_gun",
		quantity = {
			1
		},
		upgrade_deploy_time_multiplier = {
			upgrade = "sentry_gun_deploy_time_multiplier",
			category = "player"
		}
	}
	self.sentry_gun_silent = {
		deploy_time = 1,
		dummy_unit = "units/payday2/equipment/gen_equipment_sentry/gen_equipment_sentry_dummy",
		text_id = "debug_sentry_gun",
		use_function_name = "use_sentry_gun",
		unit = 2,
		min_ammo_cost = 0.33,
		ammo_cost = 0.46,
		visual_object = "g_sentrybag",
		icon = "equipment_sentry_silent",
		description_id = "des_sentry_gun",
		quantity = {
			1
		},
		upgrade_deploy_time_multiplier = {
			upgrade = "sentry_gun_deploy_time_multiplier",
			category = "player"
		},
		upgrade_name = {
			"sentry_gun"
		}
	}
	self.ecm_jammer = {
		deploy_time = 2,
		use_function_name = "use_ecm_jammer",
		dummy_unit = "units/payday2/equipment/gen_equipment_jammer/gen_equipment_jammer_dummy",
		text_id = "debug_equipment_ecm_jammer",
		icon = "equipment_ecm_jammer",
		description_id = "des_ecm_jammer",
		visual_object = "g_toolbag",
		quantity = {
			1
		}
	}
	self.armor_kit = {
		deploy_time = 2,
		use_function_name = "use_armor_kit",
		sound_done = "bar_armor_finished",
		dropin_penalty_function_name = "use_armor_kit_dropin_penalty",
		icon = "equipment_armor_kit",
		description_id = "des_armor_kit",
		limit_movement = true,
		sound_start = "bar_armor",
		sound_interupt = "bar_armor_cancel",
		text_id = "debug_equipment_armor_kit",
		on_use_callback = "on_use_armor_bag",
		deploying_text_id = "hud_equipment_equipping_armor_kit",
		action_timer = 2,
		visual_object = "g_armorbag",
		quantity = {
			1
		}
	}
	self.first_aid_kit = {
		deploy_time = 1,
		dummy_unit = "units/pd2_dlc_old_hoxton/equipment/gen_equipment_first_aid_kit/gen_equipment_first_aid_kit_dummy",
		use_function_name = "use_first_aid_kit",
		text_id = "debug_equipment_first_aid_kit",
		visual_object = "g_firstaidbag",
		icon = "equipment_first_aid_kit",
		description_id = "des_first_aid_kit",
		quantity = {
			4
		},
		upgrade_deploy_time_multiplier = {
			upgrade = "deploy_time_multiplier",
			category = "first_aid_kit"
		}
	}
	self.bodybags_bag = {
		deploy_time = 2,
		dummy_unit = "units/payday2/equipment/gen_equipment_bodybags_bag/gen_equipment_bodybags_bag_dummy",
		use_function_name = "use_bodybags_bag",
		text_id = "debug_equipment_bodybags_bag",
		visual_object = "g_bodybagsbag",
		icon = "equipment_bodybags_bag",
		description_id = "des_bodybags_bag",
		quantity = {
			1
		},
		upgrade_deploy_time_multiplier = {
			upgrade = "bodybags_bag_deploy_time_multiplier",
			category = "player"
		}
	}
	self.specials = {
		cable_tie = {
			quantity = 2,
			text_id = "debug_equipment_cable_tie",
			max_quantity = 9,
			icon = "equipment_cable_ties",
			extra_quantity = {
				upgrade = "quantity",
				equipped_upgrade = "extra_cable_tie",
				category = "extra_cable_tie"
			}
		},
		extra_cable_tie = {
			icon = "equipment_extra_cable_ties",
			description_id = "des_extra_cable_tie",
			text_id = "debug_equipment_extra_cable_tie"
		},
		body_armor = {
			icon = "equipment_armor",
			description_id = "des_body_armor",
			text_id = "debug_body_armor"
		},
		thick_skin = {
			icon = "equipment_thick_skin",
			description_id = "des_thick_skin",
			text_id = "debug_thick_skin"
		},
		bleed_out_increase = {
			icon = "equipment_bleed_out",
			description_id = "des_bleed_out_increase",
			text_id = "debug_equipment_bleed_out"
		},
		intimidation = {
			icon = "interaction_intimidate",
			description_id = "des_intimidation",
			text_id = "debug_equipment_initimidation"
		},
		extra_start_out_ammo = {
			icon = "equipment_extra_start_out_ammo",
			description_id = "des_extra_start_out_ammo",
			text_id = "debug_equipment_extra_start_out_ammo"
		},
		toolset = {
			icon = "equipment_mill_tool",
			description_id = "des_toolset",
			text_id = "debug_toolset"
		},
		bank_manager_key = {
			sync_possession = true,
			action_message = "bank_manager_key_obtained",
			transfer_quantity = 4,
			text_id = "hud_int_equipment_pickup_keycard",
			icon = "equipment_bank_manager_key"
		},
		president_key = {
			sync_possession = true,
			action_message = "bank_manager_key_obtained",
			transfer_quantity = 4,
			text_id = "hud_int_equipment_pickup_presidential_keycard",
			icon = "equipment_bank_manager_key"
		},
		mayan_gold_bar = {
			sync_possession = true,
			action_message = "mayan_gold",
			transfer_quantity = 4,
			text_id = "hud_int_equipment_mayan_gold_bar",
			icon = "equipment_mayan_gold"
		},
		help_keycard = {
			sync_possession = true,
			action_message = "bank_manager_key_obtained",
			text_id = "hud_int_equipment_pickup_keycard",
			avoid_tranfer = true,
			icon = "equipment_bank_manager_key"
		},
		c_keys = {
			sync_possession = true,
			icon = "equipment_generic_key",
			text_id = "hud_int_equipment_c_keys"
		},
		keychain = {
			sync_possession = true,
			icon = "equipment_key_chain",
			text_id = "hud_int_equipment_pickup_keychain"
		},
		chavez_key = {
			action_message = "chavez_key_obtained",
			icon = "equipment_chavez_key",
			sync_possession = true,
			text_id = "hud_int_equipment_chavez_keys"
		},
		drill = {
			action_message = "drill_obtained",
			icon = "equipment_drill",
			sync_possession = true,
			text_id = "debug_equipment_drill"
		},
		lance = {
			sync_possession = true,
			icon = "equipment_drill",
			text_id = "hud_equipment_lance"
		},
		lance_part = {
			sync_possession = true,
			icon = "equipment_drillfix",
			transfer_quantity = 4,
			text_id = "hud_equipment_lance_part"
		},
		glass_cutter = {
			sync_possession = true,
			icon = "equipment_cutter",
			text_id = "debug_equipment_glass_cutter"
		},
		saw = {
			sync_possession = true,
			icon = "pd2_generic_saw",
			text_id = "hud_equipment_saw"
		},
		saw_blade = {
			sync_possession = true,
			icon = "equipment_saw",
			text_id = "hud_equipment_saw_blade"
		},
		money_bag = {
			icon = "equipment_money_bag",
			text_id = "debug_equipment_money_bag"
		},
		server = {
			sync_possession = true,
			icon = "equipment_stash_server",
			text_id = "debug_equipment_stash_server"
		},
		planks = {
			sync_possession = true,
			icon = "equipment_planks",
			transfer_quantity = 4,
			text_id = "debug_equipment_stash_planks"
		},
		boards = {
			sync_possession = true,
			icon = "equipment_planks",
			transfer_quantity = 4,
			text_id = "hud_equipment_boards"
		},
		gold_bag_equip = {
			sync_possession = true,
			icon = "equipment_gold",
			text_id = "debug_equipment_gold_bag"
		},
		thermite = {
			action_message = "thermite_obtained",
			icon = "equipment_thermite",
			sync_possession = true,
			text_id = "hud_equipment_thermite"
		},
		thermite_paste = {
			sync_possession = true,
			icon = "equipment_thermite",
			transfer_quantity = 4,
			text_id = "hud_equipment_thermite_paste"
		},
		gas = {
			sync_possession = true,
			action_message = "gas_obtained",
			transfer_quantity = 4,
			text_id = "debug_equipment_gas",
			icon = "equipment_gasoline"
		},
		c4 = {
			quantity = 4,
			action_message = "c4_obtained",
			transfer_quantity = 8,
			text_id = "hud_equipment_pickup_c4",
			sync_possession = true,
			icon = "pd2_c4"
		},
		c4_x3 = {
			quantity = 3,
			action_message = "c4_obtained",
			transfer_quantity = 8,
			text_id = "hud_equipment_pickup_c4",
			sync_possession = true,
			icon = "pd2_c4"
		},
		c4_x10 = {
			quantity = 10,
			action_message = "c4_obtained",
			transfer_quantity = 10,
			text_id = "hud_equipment_pickup_c4",
			max_quantity = 10,
			icon = "pd2_c4",
			sync_possession = true
		},
		organs = {
			action_message = "organs_obtained",
			icon = "equipment_thermite",
			text_id = "debug_equipment_organs"
		},
		crowbar = {
			sync_possession = true,
			icon = "equipment_crowbar",
			text_id = "debug_equipment_crowbar"
		},
		crowbar_stack = {
			sync_possession = true,
			icon = "equipment_crowbar",
			transfer_quantity = 4,
			text_id = "debug_equipment_crowbar"
		},
		fire_extinguisher = {
			sync_possession = true,
			icon = "equipment_fire_extinguisher",
			text_id = "hud_int_equipment_fire_extinguisher"
		},
		blood_sample = {
			sync_possession = true,
			icon = "equipment_vial",
			text_id = "debug_equipment_blood_sample"
		},
		acid = {
			sync_possession = true,
			icon = "equipment_muriatic_acid",
			transfer_quantity = 4,
			text_id = "hud_int_equipment_acid"
		},
		blood_sample_verified = {
			sync_possession = true,
			icon = "equipment_vialOK",
			text_id = "debug_equipment_blood_sample_valid"
		},
		caustic_soda = {
			sync_possession = true,
			icon = "equipment_caustic_soda",
			transfer_quantity = 4,
			text_id = "hud_int_equipment_caustic_soda"
		},
		hydrogen_chloride = {
			sync_possession = true,
			icon = "equipment_hydrogen_chloride",
			transfer_quantity = 4,
			text_id = "hud_int_equipment_hydrogen_chloride"
		},
		gold = {
			player_rule = "no_run",
			icon = "equipment_gold",
			text_id = "debug_equipment_gold"
		},
		circle_cutter = {
			quantity = 1,
			transfer_quantity = 4,
			sync_possession = true,
			text_id = "hud_equipment_circle_cutter",
			max_quantity = 3,
			icon = "equipment_glasscutter"
		}
	}
	local barcodes = {
		"barcode_downtown",
		"barcode_brickell",
		"barcode_edgewater",
		"barcode_isles_beach",
		"barcode_opa_locka"
	}
	self.specials.barcode_downtown = {
		sync_possession = true,
		text_id = "hud_int_equipment_barcode_downtown",
		avoid_tranfer = true,
		icon = "equipment_barcode",
		shares_pickup_with = barcodes
	}
	self.specials.barcode_brickell = {
		sync_possession = true,
		text_id = "hud_int_equipment_barcode_brickell",
		avoid_tranfer = true,
		icon = "equipment_barcode",
		shares_pickup_with = barcodes
	}
	self.specials.barcode_edgewater = {
		sync_possession = true,
		text_id = "hud_int_equipment_barcode_edgewater",
		avoid_tranfer = true,
		icon = "equipment_barcode",
		shares_pickup_with = barcodes
	}
	self.specials.barcode_isles_beach = {
		sync_possession = true,
		text_id = "hud_int_equipment_barcode_isles_beach",
		avoid_tranfer = true,
		icon = "equipment_barcode",
		shares_pickup_with = barcodes
	}
	self.specials.barcode_opa_locka = {
		sync_possession = true,
		text_id = "hud_int_equipment_barcode_opa_locka",
		avoid_tranfer = true,
		icon = "equipment_barcode",
		shares_pickup_with = barcodes
	}
	self.specials.evidence = {
		sync_possession = true,
		icon = "equipment_evidence",
		text_id = "hud_equipment_evidence"
	}
	self.specials.harddrive = {
		sync_possession = true,
		icon = "equipment_harddrive",
		text_id = "hud_equipment_harddrive"
	}
	self.specials.files = {
		sync_possession = true,
		icon = "equipment_files",
		text_id = "hud_equipment_files"
	}
	self.specials.ticket = {
		sync_possession = true,
		icon = "equipment_ticket",
		text_id = "hud_equipment_take_ticket"
	}
	self.specials.bridge = {
		sync_possession = true,
		icon = "equipment_planks",
		text_id = "hud_equipment_take_bridge"
	}
	self.specials.mus_glas_cutter = {
		sync_possession = true,
		icon = "equipment_glasscutter",
		text_id = "hud_equipment_mus_glass_cutter"
	}
	self.specials.c4_x1 = {
		quantity = 1,
		action_message = "c4_obtained",
		sync_possession = true,
		text_id = "hud_equipment_pickup_c4",
		icon = "pd2_c4"
	}
	self.specials.chainsaw = {
		sync_possession = true,
		icon = "equipment_chainsaw",
		text_id = "hud_equipment_chainsaw"
	}
	self.specials.manifest = {
		sync_possession = true,
		icon = "equipment_manifest",
		text_id = "hud_equipment_manifest"
	}
	self.specials.bottle = {
		sync_possession = true,
		icon = "equipment_bottle",
		text_id = "hud_equipment_bottle"
	}
	self.specials.hotel_room_key = {
		sync_possession = true,
		icon = "equipment_bank_manager_key",
		text_id = "hud_equipment_hotel_room_keycard"
	}
	self.specials.blueprints = {
		sync_possession = true,
		icon = "equipment_files",
		text_id = "hud_equipment_blueprints"
	}
	self.specials.cas_usb_key = {
		sync_possession = true,
		icon = "equipment_usb_no_data",
		text_id = "hud_equipment_usb_key"
	}
	self.specials.cas_data_usb_key = {
		sync_possession = true,
		icon = "equipment_usb_with_data",
		text_id = "hud_equipment_data_usb_key"
	}
	self.specials.cas_sleeping_gas = {
		sync_possession = true,
		icon = "equipment_sleeping_gas",
		text_id = "hud_equipment_sleeping_gas"
	}
	self.specials.cas_bfd_tool = {
		sync_possession = true,
		icon = "equipment_bfd_tool",
		transfer_quantity = 4,
		text_id = "hud_equipment_bfd_tool"
	}
	self.specials.cas_elevator_key = {
		sync_possession = true,
		icon = "equipment_elevator_key",
		text_id = "hud_equipment_elevator_key"
	}
	self.specials.cas_winch_hook = {
		sync_possession = true,
		icon = "equipment_winch_hook",
		text_id = "hud_equipment_winch_hook"
	}
	self.specials.printer_ink = {
		sync_possession = true,
		icon = "equipment_printer_ink",
		transfer_quantity = 4,
		text_id = "hud_int_equipment_printer_ink"
	}
	self.specials.plates = {
		sync_possession = true,
		icon = "equipment_plates",
		text_id = "hud_int_equipment_plates"
	}
	self.specials.paper_roll = {
		sync_possession = true,
		icon = "equipment_paper_roll",
		transfer_quantity = 4,
		text_id = "hud_int_equipment_paper_roll"
	}
	self.specials.chrome_skull = {
		sync_possession = true,
		icon = "equipment_chrome_mask",
		text_id = "hud_equipment_chrome_skull"
	}
	self.specials.soda = {
		sync_possession = true,
		icon = "equipment_soda",
		text_id = "hud_equipment_soda"
	}
	self.specials.tool = {
		sync_possession = true,
		icon = "equipment_born_tool",
		text_id = "hud_equipment_tool"
	}
	self.specials.blow_torch = {
		sync_possession = true,
		icon = "equipment_blow_torch",
		text_id = "hud_int_equipment_blow_torch"
	}
	self.max_amount = {
		trip_mine = 25,
		asset_sentry_gun = 4,
		ecm_jammer = 2,
		asset_doctor_bag = 3,
		ammo_bag = 2,
		grenades = 4,
		asset_ammo_bag = 4,
		asset_grenade_crate = 3,
		first_aid_kit = 14,
		asset_bodybags_bag = 3,
		bodybags_bag = 2,
		sentry_gun = -1,
		doctor_bag = 2
	}
	self.class_name_to_deployable_id = {
		BodyBagsBagBase = "bodybags_bag",
		FirstAidKitBase = "first_aid_kit",
		DoctorBagBase = "doctor_bag",
		AmmoBagBase = "ammo_bag"
	}
	self.specials.hand = {
		sync_possession = true,
		icon = "equipment_hand",
		text_id = "hud_int_equipment_hand"
	}
	self.specials.briefcase = {
		sync_possession = true,
		icon = "equipment_briefcase",
		text_id = "hud_int_equipment_briefcase"
	}
	self.specials.scubagear_tank_and_flippers = {
		sync_possession = true,
		icon = "equipment_chrome_mask",
		text_id = "hud_equipment_scubagear_tank_and_flippers"
	}
	self.specials.scubagear_vest = {
		sync_possession = true,
		icon = "equipment_soda",
		text_id = "hud_equipment_scubagear_vest"
	}
	self.specials.briefcase_diamond = {
		sync_possession = true,
		icon = "equipment_briefcase",
		text_id = "hud_int_equipment_briefcase_diamond"
	}
	self.specials.liquid_nitrogen = {
		sync_possession = true,
		icon = "equipment_liquid_nitrogen_canister",
		transfer_quantity = 4,
		text_id = "hud_int_equipment_liquid_nitrogen"
	}
	self.specials.medallion = {
		sync_possession = true,
		icon = "equipment_medallion",
		transfer_quantity = 1,
		text_id = "hud_int_equipment_medallion"
	}
	self.specials.chimichanga = {
		sync_possession = true,
		icon = "equipment_chimichanga",
		transfer_quantity = 4,
		text_id = "hud_int_equipment_chimichanga"
	}
	self.specials.stapler = {
		sync_possession = true,
		icon = "equipment_stapler",
		transfer_quantity = 4,
		text_id = "hud_int_equipment_stapler"
	}
	self.specials.compound_a = {
		sync_possession = false,
		icon = "equipment_compounda",
		text_id = "hud_int_equipment_compound_a"
	}
	self.specials.compound_b = {
		sync_possession = false,
		icon = "equipment_compoundb",
		text_id = "hud_int_equipment_compound_b"
	}
	self.specials.compound_c = {
		sync_possession = false,
		icon = "equipment_compoundc",
		text_id = "hud_int_equipment_compound_c"
	}
	self.specials.compound_d = {
		sync_possession = false,
		icon = "equipment_compoundd",
		text_id = "hud_int_equipment_compound_d"
	}
	self.specials.concoction = {
		action_message = "thermite_obtained",
		icon = "equipment_thermite",
		sync_possession = true,
		text_id = "hud_int_equipment_concoction"
	}
	self.specials.briefcase = {
		sync_possession = true,
		icon = "equipment_briefcase",
		text_id = "hud_briefcase"
	}
	self.specials.equipment_blueprint = {
		sync_possession = true,
		icon = "equipment_blueprint",
		text_id = "hud_equipment_blueprints"
	}
	self.specials.fingerprint = {
		sync_possession = true,
		icon = "equipment_tape_fingerprint",
		text_id = "hud_fingerprint"
	}
	self.specials.tape = {
		sync_possession = true,
		icon = "equipment_tape",
		text_id = "hud_equipment_take_tape"
	}
end
