PrePlanningTweakData = PrePlanningTweakData or class()

function PrePlanningTweakData:get_custom_texture_rect(num)
	if not num then
		return
	end

	local x = math.floor(num / 10) - 1
	local y = num % 10 - 1

	return {
		x * 48,
		y * 48,
		48,
		48
	}
end

function PrePlanningTweakData:get_category_texture_rect(num)
	if not num then
		return
	end

	local x = math.floor(num / 10) - 1
	local y = num % 10 - 1

	return {
		x * 64,
		y * 64,
		64,
		64
	}
end

function PrePlanningTweakData:get_type_texture_rect(num)
	if not num then
		return
	end

	local x = math.floor(num / 10) - 1
	local y = num % 10 - 1

	return {
		x * 48,
		y * 48,
		48,
		48
	}
end

function PrePlanningTweakData:init(tweak_data)
	self:_create_locations(tweak_data)

	self.plans = {
		escape_plan = {}
	}
	self.plans.escape_plan.category = "escape_plan"
	self.plans.vault_plan = {
		category = "vault_plan"
	}
	self.plans.plan_of_action = {
		category = "plan_of_action"
	}
	self.plans.entry_plan = {
		category = "entry_plan"
	}
	self.plans.entry_plan_generic = {
		category = "entry_plan_generic"
	}
	self.gui = {
		custom_icons_path = "guis/dlcs/big_bank/textures/pd2/pre_planning/preplan_icon_types",
		type_icons_path = "guis/dlcs/big_bank/textures/pd2/pre_planning/preplan_icon_types",
		category_icons_path = "guis/dlcs/big_bank/textures/pd2/pre_planning/preplan_icon_frames",
		category_icons_bg = 42,
		MAX_DRAW_POINTS = 1000
	}
	self.categories = {
		default = {}
	}
	self.categories.default.name_id = "menu_pp_cat_default"
	self.categories.default.desc_id = "menu_pp_cat_default_desc"
	self.categories.default.icon = 32
	self.categories.default.prio = 0
	self.categories.dead_drop = {
		name_id = "menu_pp_cat_dead_drop",
		desc_id = "menu_pp_cat_dead_drop_desc",
		icon = 22,
		prio = 5
	}
	self.categories.mission_equipment = {
		name_id = "menu_pp_cat_mission_equipment",
		desc_id = "menu_pp_cat_mission_equipment_desc",
		icon = 11,
		prio = 0
	}
	self.categories.insider_help = {
		name_id = "menu_pp_cat_insider_help",
		desc_id = "menu_pp_cat_insider_help_desc",
		upgrade_lock = {
			upgrade = "additional_assets",
			category = "player"
		},
		icon = 21,
		prio = 2
	}
	self.categories.data_hacking = {
		name_id = "menu_pp_cat_data_hacking",
		desc_id = "menu_pp_cat_data_hacking_desc",
		icon = 31,
		prio = 3
	}
	self.categories.hired_help = {
		name_id = "menu_pp_cat_hired_help",
		desc_id = "menu_pp_cat_hired_help_desc",
		icon = 41,
		prio = 1
	}
	self.categories.surveillance = {
		name_id = "menu_pp_cat_surveillance",
		desc_id = "menu_pp_cat_surveillance_desc",
		icon = 41,
		prio = 4
	}
	self.categories.vault_plan = {
		name_id = "menu_pp_cat_vault_plan",
		desc_id = "menu_pp_cat_vault_plan_desc",
		plan = "vault_plan",
		icon = 11,
		prio = 2
	}
	self.categories.escape_plan = {
		name_id = "menu_pp_cat_escape_plan",
		desc_id = "menu_pp_cat_escape_plan_desc",
		plan = "escape_plan",
		icon = 12,
		total = 1,
		prio = 1
	}
	self.categories.plan_of_action = {
		name_id = "menu_pp_cat_plan_of_action",
		desc_id = "menu_pp_cat_plan_of_action_desc",
		plan = "plan_of_action",
		icon = 12,
		total = 1,
		prio = 1
	}
	self.categories.entry_plan_generic = {
		name_id = "menu_pp_cat_entry_plan_generic",
		desc_id = "menu_pp_cat_entry_plan_generic_desc",
		plan = "entry_plan",
		icon = 12,
		total = 1,
		prio = 1
	}
	self.categories.entry_plan = {
		name_id = "menu_pp_cat_entry_plan",
		desc_id = "menu_pp_cat_entry_plan_desc",
		plan = "entry_plan",
		icon = 12,
		total = 1,
		prio = 1
	}
	self.categories.BFD_upgrades = {
		name_id = "menu_pp_cat_BFD_upgrades",
		desc_id = "menu_pp_cat_BFD_upgrades_desc",
		icon = 12,
		prio = 1
	}
	self.categories.BFD_attachments = {
		name_id = "menu_pp_cat_BFD_attachments",
		desc_id = "menu_pp_cat_BFD_attachments_desc",
		icon = 12,
		prio = 1
	}
	self.types = {
		ammo_bag = {}
	}
	self.types.ammo_bag.name_id = "menu_pp_asset_ammo"
	self.types.ammo_bag.desc_id = "menu_pp_asset_ammo_desc"
	self.types.ammo_bag.deployable_id = "ammo_bag"
	self.types.ammo_bag.icon = 52
	self.types.ammo_bag.category = "dead_drop"
	self.types.ammo_bag.total = 2
	self.types.ammo_bag.cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_deaddropbag")
	self.types.ammo_bag.budget_cost = 2
	self.types.ammo_bag.post_event = "preplan_05"
	self.types.ammo_bag.prio = 5
	self.types.health_bag = {
		name_id = "menu_pp_asset_health",
		desc_id = "menu_pp_asset_health_desc",
		deployable_id = "doctor_bag",
		icon = 31,
		category = "dead_drop",
		total = 2,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_deaddropbag"),
		budget_cost = 2,
		post_event = "preplan_06",
		prio = 6
	}
	self.types.bodybags_bag = {
		name_id = "menu_pp_asset_bodybags_bag",
		desc_id = "menu_pp_asset_bodybags_bag_desc",
		deployable_id = "bodybags_bag",
		icon = 13,
		category = "dead_drop",
		upgrade_lock = {
			upgrade = "buy_bodybags_asset",
			category = "player"
		},
		total = 2,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_deaddropbag"),
		budget_cost = 2,
		post_event = "preplan_15",
		prio = 3
	}
	self.types.grenade_crate = {
		name_id = "menu_pp_asset_grenade_crate",
		desc_id = "menu_pp_asset_grenade_crate_desc",
		deployable_id = "grenade_crate",
		icon = 21,
		category = "dead_drop",
		dlc_lock = "gage_pack",
		total = 2,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_deaddropbag"),
		budget_cost = 2,
		post_event = "preplan_15",
		prio = 4,
		progress_stat = "gage_10_stats"
	}
	self.types.car = {
		name_id = "menu_asset_car",
		total = 1
	}
	self.types.drill_parts = {
		name_id = "menu_pp_asset_drill_parts",
		desc_id = "menu_pp_asset_drill_parts_desc",
		category = "dead_drop",
		icon = 12,
		total = 1,
		post_event = "preplan_16",
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_drillparts"),
		budget_cost = 3,
		prio = 2
	}
	self.types.zipline = {
		name_id = "menu_pp_asset_zipline",
		desc_id = "menu_pp_asset_zipline_desc",
		category = "mission_equipment",
		icon = 23,
		total = 1,
		post_event = "preplan_07",
		prio = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_zipline"),
		budget_cost = 2
	}
	self.types.zipline_generic = deep_clone(self.types.zipline)
	self.types.zipline_generic.desc_id = "menu_pp_asset_zipline_generic_desc"
	self.types.unlocked_door = {
		name_id = "menu_pp_asset_unlocked_door",
		desc_id = "menu_pp_asset_unlocked_door_desc",
		category = "mission_equipment",
		icon = 41,
		total = 1,
		post_event = "preplan_07",
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_unlocked_door"),
		budget_cost = 1,
		prio = 2
	}
	self.types.unlocked_window = {
		name_id = "menu_pp_asset_unlocked_window",
		desc_id = "menu_pp_asset_unlocked_window_desc",
		category = "mission_equipment",
		icon = 41,
		total = 5,
		post_event = "preplan_07",
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_unlocked_window"),
		budget_cost = 1,
		prio = 2
	}
	self.types.highlight_keybox = {
		name_id = "menu_pp_asset_highlight_keybox",
		desc_id = "menu_pp_asset_highlight_keybox_desc",
		category = "mission_equipment",
		icon = 43,
		total = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_highlight_keybox"),
		budget_cost = 2,
		post_event = "preplan_16",
		prio = 2
	}
	self.types.ladder = {
		name_id = "menu_pp_asset_ladder",
		category = "mission_equipment",
		total = 1,
		post_event = "preplan_07",
		prio = 2
	}
	self.types.disable_camera = {
		name_id = "menu_pp_asset_disable_camera",
		category = "surveillance",
		total = 1,
		post_event = "preplan_08",
		prio = 2
	}
	self.types.disable_metal_detector = {
		name_id = "menu_pp_asset_disable_metal_detector",
		category = "insider_help",
		upgrade_lock = {
			upgrade = "additional_assets",
			category = "player"
		},
		total = 1,
		post_event = "preplan_10",
		prio = 3
	}
	self.types.disable_guards_cake = {
		name_id = "menu_pp_asset_disable_guards_cake",
		desc_id = "menu_pp_asset_disable_guards_cake_desc",
		category = "insider_help",
		upgrade_lock = {
			upgrade = "additional_assets",
			category = "player"
		},
		icon = 25,
		total = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_cake"),
		budget_cost = 3,
		post_event = "preplan_09",
		prio = 1
	}
	self.types.extra_cameras = {
		name_id = "menu_pp_asset_extra_cameras",
		desc_id = "menu_pp_asset_extra_cameras_desc",
		category = "surveillance",
		look_angle = {
			length = 0.3,
			angle = 80,
			color = Color(192, 255, 170, 0) / 255
		},
		icon = 11,
		total = 9,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_extracameras"),
		budget_cost = 1,
		post_event = "preplan_16",
		prio = 2
	}
	self.types.keycard = {
		name_id = "menu_pp_asset_keycard",
		desc_id = "menu_pp_asset_keycard_desc",
		category = "insider_help",
		upgrade_lock = {
			upgrade = "additional_assets",
			category = "player"
		},
		icon = 53,
		total = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_keycard"),
		budget_cost = 2,
		post_event = "preplan_16",
		prio = 2
	}
	self.types.camera_access = {
		name_id = "menu_pp_camera_access",
		desc_id = "menu_pp_camera_access_desc",
		category = "surveillance",
		icon = 24,
		total = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_accesscameras"),
		budget_cost = 2,
		post_event = "preplan_16",
		prio = 8
	}
	self.types.delay_police_10 = {
		name_id = "menu_pp_asset_delay_police_10",
		desc_id = "menu_pp_asset_delay_police_10_desc",
		delay_weapons_hot_t = 10,
		icon = 42,
		category = "data_hacking",
		total = 1,
		post_event = "preplan_04",
		prio = 7
	}
	self.types.delay_police_10_no_pos = deep_clone(self.types.delay_police_10)
	self.types.delay_police_10_no_pos.budget_cost = 1
	self.types.delay_police_10_no_pos.cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_delay10")
	self.types.delay_police_10_no_pos.pos_not_important = true
	self.types.delay_police_20 = {
		name_id = "menu_pp_asset_delay_police_20",
		desc_id = "menu_pp_asset_delay_police_20_desc",
		delay_weapons_hot_t = 20,
		icon = 42,
		category = "data_hacking",
		total = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_delay20"),
		budget_cost = 1,
		post_event = "preplan_04",
		prio = 6
	}
	self.types.delay_police_30 = {
		name_id = "menu_pp_asset_delay_police_30",
		desc_id = "menu_pp_asset_delay_police_30_desc",
		delay_weapons_hot_t = 30,
		icon = 42,
		category = "data_hacking",
		total = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_delay30"),
		budget_cost = 2,
		post_event = "preplan_10",
		prio = 5
	}
	self.types.delay_police_30_no_pos = deep_clone(self.types.delay_police_30)
	self.types.delay_police_30_no_pos.pos_not_important = true
	self.types.delay_police_60 = {
		name_id = "menu_pp_asset_delay_police_60",
		desc_id = "menu_pp_asset_delay_police_60_desc",
		delay_weapons_hot_t = 60,
		icon = 42,
		category = "data_hacking",
		total = 1,
		budget_cost = 4,
		post_event = "preplan_04",
		prio = 4
	}
	self.types.reduce_timelock_60 = {
		name_id = "menu_pp_asset_reduce_timelock_60",
		desc_id = "menu_pp_asset_reduce_timelock_60_desc",
		reduce_timelock_t = 60,
		icon = 15,
		category = "data_hacking",
		total = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_timelock60"),
		budget_cost = 2,
		post_event = "preplan_10",
		prio = 3
	}
	self.types.reduce_timelock_120 = {
		name_id = "menu_pp_asset_reduce_timelock_120",
		desc_id = "menu_pp_asset_reduce_timelock_120_desc",
		reduce_timelock_t = 120,
		icon = 15,
		category = "data_hacking",
		total = 1,
		budget_cost = 4,
		post_event = "preplan_10",
		prio = 2
	}
	self.types.reduce_timelock_240 = {
		name_id = "menu_pp_asset_reduce_timelock_240",
		desc_id = "menu_pp_asset_reduce_timelock_240_desc",
		reduce_timelock_t = 240,
		icon = 15,
		category = "data_hacking",
		total = 1,
		budget_cost = 6,
		post_event = "preplan_10",
		prio = 1
	}
	self.types.spycam = {
		name_id = "menu_asset_spycam",
		desc_id = "menu_asset_spycam_desc",
		category = "surveillance",
		upgrade_lock = {
			upgrade = "buy_spotter_asset",
			category = "player"
		},
		look_angle = {
			length = 0.5,
			angle = 80,
			color = Color(192, 255, 51, 51) / 255
		},
		icon = 35,
		total = 3,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_spycam"),
		budget_cost = 2,
		post_event = "preplan_14",
		prio = 3
	}
	self.types.spotter = {
		name_id = "menu_asset_spotter",
		category = "hired_help",
		upgrade_lock = {
			upgrade = "buy_spotter_asset",
			category = "player"
		},
		look_angle = {
			length = 0.5,
			angle = 80,
			color = Color(192, 255, 51, 51) / 255
		},
		icon = 33,
		total = 1,
		budget_cost = 2,
		post_event = "preplan_13",
		prio = 4
	}
	self.types.spotter_des = deep_clone(self.types.spotter)
	self.types.spotter_des.budget_cost = 3
	self.types.spotter_des.cost = tweak_data:get_value("money_manager", "preplaning_thebomb_cost_spotter")
	self.types.spotter_des.desc_id = "menu_pp_asset_spotter_desc"
	self.types.sniper = {
		name_id = "menu_pp_asset_sniper",
		desc_id = "menu_pp_asset_sniper_desc",
		category = "hired_help",
		icon = 55,
		total = 1,
		post_event = "preplan_13",
		prio = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_mia_cost_sniper"),
		budget_cost = 1
	}
	self.types.delayed_police = {
		name_id = "menu_pp_asset_delayed_police",
		desc_id = "menu_pp_asset_delayed_police_desc",
		category = "hired_help",
		icon = 15,
		total = 1,
		post_event = "preplan_13",
		prio = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_mia_cost_delayed_police"),
		budget_cost = 1
	}
	self.types.reduce_mobsters = {
		name_id = "menu_pp_asset_reduce_mobsters",
		desc_id = "menu_pp_asset_reduce_mobsters_desc",
		category = "hired_help",
		icon = 61,
		total = 1,
		post_event = "preplan_13",
		prio = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_mia_cost_reduce_mobsters"),
		budget_cost = 1
	}
	self.types.escape_van_loud = {
		name_id = "menu_pp_escape_van_loud",
		desc_id = "menu_pp_escape_van_loud_desc",
		plan = "escape_plan",
		pos_not_important = false,
		category = "escape_plan",
		total = 1,
		cost = 0,
		budget_cost = 0,
		post_event = "preplan_17",
		prio = 6
	}
	self.types.escape_bus_loud = {
		name_id = "menu_pp_escape_bus_loud",
		desc_id = "menu_pp_escape_bus_loud_desc",
		plan = "escape_plan",
		pos_not_important = false,
		category = "escape_plan",
		icon = 54,
		total = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_escapebig"),
		budget_cost = 6,
		post_event = "preplan_17",
		prio = 1
	}
	self.types.escape_c4_loud = {
		name_id = "menu_pp_escape_c4_loud",
		desc_id = "menu_pp_escape_c4_loud_desc",
		plan = "escape_plan",
		pos_not_important = false,
		category = "escape_plan",
		icon = 54,
		total = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_escapebig"),
		budget_cost = 3,
		post_event = "preplan_17",
		prio = 2
	}
	self.types.escape_elevator_loud = {
		name_id = "menu_pp_escape_elevator_loud",
		desc_id = "menu_pp_escape_elevator_loud_desc",
		plan = "escape_plan",
		pos_not_important = false,
		category = "escape_plan",
		icon = 54,
		total = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_escapebig"),
		budget_cost = 3,
		post_event = "preplan_17",
		prio = 3
	}
	self.types.escape_zipline_loud = {
		name_id = "menu_pp_escape_zipline_loud",
		desc_id = "menu_pp_escape_zipline_loud_desc",
		plan = "escape_plan",
		pos_not_important = false,
		category = "escape_plan",
		icon = 54,
		total = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_zipline"),
		budget_cost = 3,
		post_event = "preplan_17",
		prio = 2
	}
	self.types.escape_helicopter_loud = {
		name_id = "menu_pp_escape_helicopter_loud",
		desc_id = "menu_pp_escape_helicopter_loud_desc",
		plan = "escape_plan",
		pos_not_important = false,
		category = "escape_plan",
		icon = 54,
		total = 1,
		cost = 0,
		budget_cost = 0,
		post_event = "preplan_17",
		prio = 3
	}
	self.types.escape_aliens_loud = {
		name_id = "menu_pp_escape_aliens_loud",
		desc_id = "menu_pp_escape_aliens_loud_desc",
		plan = "escape_plan",
		pos_not_important = false,
		deployable_id = "ammo_bag",
		category = "escape_plan",
		total = 1,
		cost = tweak_data:get_value("money_manager", "mission_asset_cost_large", 10),
		budget_cost = 10,
		post_event = "preplan_17",
		prio = 99
	}
	self.types.vault_drill = {
		name_id = "menu_pp_vault_drill",
		plan = "vault_plan",
		pos_not_important = false,
		category = "vault_plan",
		total = 1,
		cost = 0,
		budget_cost = 0,
		post_event = "preplan_17",
		prio = 2,
		prio = 5
	}
	self.types.vault_c4 = {
		name_id = "menu_pp_vault_c4",
		plan = "vault_plan",
		pos_not_important = false,
		category = "vault_plan",
		total = 1,
		cost = tweak_data:get_value("money_manager", "mission_asset_cost_large", 1),
		budget_cost = 4,
		post_event = "preplan_17",
		prio = 2
	}
	self.types.vault_lance = {
		name_id = "menu_pp_vault_lance",
		plan = "vault_plan",
		pos_not_important = false,
		category = "vault_plan",
		icon = 12,
		total = 1,
		cost = 0,
		budget_cost = 0,
		post_event = "preplan_17",
		prio = 5
	}
	self.types.vault_big_drill = {
		name_id = "menu_pp_vault_big_drill",
		desc_id = "menu_pp_vault_big_drill_desc",
		plan = "vault_plan",
		pos_not_important = false,
		category = "vault_plan",
		icon = 12,
		total = 1,
		cost = 0,
		budget_cost = 0,
		post_event = "preplan_17",
		prio = 5
	}
	self.types.vault_thermite = {
		name_id = "menu_pp_vault_thermite",
		desc_id = "menu_pp_vault_thermite_desc",
		plan = "vault_plan",
		pos_not_important = false,
		category = "vault_plan",
		icon = 51,
		total = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_thermite"),
		budget_cost = 5,
		post_event = "preplan_02",
		prio = 1
	}
	self.types.vault_singularity = {
		name_id = "menu_pp_vault_singularity",
		plan = "vault_plan",
		pos_not_important = false,
		category = "vault_plan",
		total = 1,
		cost = tweak_data:get_value("money_manager", "mission_asset_cost_large", 10),
		budget_cost = 10,
		post_event = "preplan_17",
		prio = 99
	}
	self.types.disable_alarm_button = {
		name_id = "menu_pp_asset_disable_alarm_button",
		desc_id = "menu_pp_asset_disable_alarm_button_desc",
		category = "data_hacking",
		icon = 42,
		total = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_disable_alarm_button"),
		budget_cost = 3,
		post_event = "preplan_16",
		prio = 1
	}
	self.types.safe_escape = {
		name_id = "menu_pp_asset_safe_escape",
		desc_id = "menu_pp_asset_safe_escape_desc",
		category = "insider_help",
		upgrade_lock = {
			upgrade = "additional_assets",
			category = "player"
		},
		icon = 54,
		total = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_safe_escape"),
		budget_cost = 3,
		post_event = "preplan_16",
		prio = 1
	}
	self.types.sniper_spot = {
		name_id = "menu_pp_asset_sniper_spot",
		desc_id = "menu_pp_asset_sniper_spot_desc",
		category = "hired_help",
		icon = 55,
		total = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_sniper_spot"),
		budget_cost = 3,
		post_event = "preplan_16",
		prio = 1
	}
	self.types.bag_shortcut = {
		name_id = "menu_pp_asset_bag_shortcut",
		desc_id = "menu_pp_asset_bag_shortcut_desc",
		category = "mission_equipment",
		icon = 34,
		total = 1,
		post_event = "preplan_16",
		prio = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_bag_shortcut"),
		budget_cost = 2
	}
	self.types.bag_zipline = {
		name_id = "menu_pp_asset_bag_zipline",
		desc_id = "menu_pp_asset_bag_zipline_desc",
		category = "mission_equipment",
		icon = 34,
		total = 1,
		post_event = "preplan_16",
		prio = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_bag_zipline"),
		budget_cost = 2
	}
	self.types.bag_zipline_stealth_only = {
		name_id = "menu_pp_asset_bag_zipline_stealth_only",
		desc_id = "menu_pp_asset_bag_zipline_stealth_only_desc",
		category = "mission_equipment",
		icon = 34,
		total = 1,
		post_event = "preplan_16",
		prio = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_bag_zipline"),
		budget_cost = 2
	}
	self.types.loot_drop_off = {
		name_id = "menu_pp_asset_loot_drop_off",
		desc_id = "menu_pp_asset_loot_drop_off_desc",
		category = "hired_help",
		icon = 34,
		total = 1,
		post_event = "preplan_16",
		prio = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_loot_drop_off"),
		budget_cost = 2
	}
	self.types.loot_drop_off_stealth_only = {
		name_id = "menu_pp_asset_loot_drop_off_stealth_only",
		desc_id = "menu_pp_asset_loot_drop_off_stealth_only_desc",
		category = "hired_help",
		icon = 34,
		total = 1,
		post_event = "preplan_16",
		prio = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_loot_drop_off"),
		budget_cost = 2
	}
	self.types.loot_drop_off_generic = deep_clone(self.types.loot_drop_off)
	self.types.loot_drop_off_generic.desc_id = "menu_pp_asset_loot_drop_off_generic_desc"
	self.types.thermal_paste = {
		name_id = "menu_pp_asset_thermal_paste",
		desc_id = "menu_pp_asset_thermal_paste_desc",
		category = "dead_drop",
		icon = 51,
		total = 1,
		post_event = "preplan_16",
		prio = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_thermal_paste"),
		budget_cost = 3,
		spawn_unit = "units/payday2/equipment/gen_equipment_thermal_paste_crate/gen_equipment_thermal_paste_crate"
	}
	self.types.framing_frame_1_truck = {
		name_id = "menu_pp_asset_framing_frame_1_truck",
		desc_id = "menu_pp_asset_framing_frame_1_truck_desc",
		category = "mission_equipment",
		icon = 63,
		total = 1,
		post_event = "preplan_07",
		prio = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_framing_frame_1_truck"),
		budget_cost = 2
	}
	self.types.framing_frame_1_entry_point = {
		name_id = "menu_pp_asset_framing_frame_1_entry_point",
		desc_id = "menu_pp_asset_framing_frame_1_entry_point_desc",
		category = "mission_equipment",
		icon = 41,
		total = 1,
		post_event = "preplan_07",
		prio = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_framing_frame_1_entry_point"),
		budget_cost = 2
	}
	self.types.branchbank_lance = {
		name_id = "menu_pp_branchbank_lance",
		desc_id = "menu_pp_branchbank_lance_desc",
		plan = "vault_plan",
		pos_not_important = false,
		category = "vault_plan",
		icon = 12,
		total = 1,
		cost = 0,
		budget_cost = 0,
		post_event = "preplan_17",
		prio = 5
	}
	self.types.branchbank_vault_key = {
		name_id = "menu_pp_asset_branchbank_vault_key",
		desc_id = "menu_pp_asset_branchbank_vault_key_desc",
		category = "mission_equipment",
		icon = 43,
		total = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_branchbank_vault_key"),
		budget_cost = 3,
		post_event = "preplan_16",
		prio = 2
	}
	self.types.crojob_stealth = {
		name_id = "menu_pp_crojob_stealth",
		desc_id = "menu_pp_crojob_stealth_desc",
		plan = "plan_of_action",
		pos_not_important = true,
		category = "plan_of_action",
		icon = 54,
		total = 0,
		cost = 0,
		budget_cost = 0,
		post_event = "",
		prio = 3
	}
	self.types.crojob_loud = {
		name_id = "menu_pp_crojob_loud",
		desc_id = "menu_pp_crojob_loud_desc",
		plan = "plan_of_action",
		pos_not_important = true,
		category = "plan_of_action",
		icon = 54,
		total = 0,
		cost = 0,
		budget_cost = 0,
		post_event = "",
		prio = 3
	}
	self.types.crojob2_escape_van = {
		name_id = "menu_pp_crojob2_escape_van",
		desc_id = "menu_pp_crojob2_escape_van_desc",
		plan = "escape_plan",
		pos_not_important = false,
		category = "escape_plan",
		icon = 54,
		total = 1,
		cost = 0,
		budget_cost = 0,
		post_event = "preplan_12",
		prio = 3
	}
	self.types.crojob2_escape_helicopter = {
		name_id = "menu_pp_crojob2_escape_helicopter",
		desc_id = "menu_pp_crojob2_escape_helicopter_desc",
		plan = "escape_plan",
		pos_not_important = false,
		category = "escape_plan",
		icon = 54,
		total = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_thebomb_cost_escape_mid"),
		budget_cost = 4,
		post_event = "preplan_17",
		prio = 3
	}
	self.types.crojob2_escape_boat = {
		name_id = "menu_pp_crojob2_escape_boat",
		desc_id = "menu_pp_crojob2_escape_boat_desc",
		plan = "escape_plan",
		pos_not_important = false,
		category = "escape_plan",
		icon = 54,
		total = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_thebomb_cost_escape_close"),
		budget_cost = 8,
		post_event = "preplan_13",
		prio = 3
	}
	self.types.crojob2_better_hacker = {
		name_id = "menu_pp_asset_crojob2_better_hacker",
		desc_id = "menu_pp_asset_crojob2_better_hacker_desc",
		icon = 15,
		pos_not_important = true,
		category = "hired_help",
		total = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_thebomb_cost_hacker"),
		budget_cost = 3,
		post_event = "preplan_10",
		prio = 3
	}
	self.types.crojob2_better_pilot = {
		name_id = "menu_pp_asset_crojob2_better_pilot",
		desc_id = "menu_pp_asset_crojob2_better_pilot_desc",
		icon = 73,
		pos_not_important = true,
		category = "hired_help",
		total = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_thebomb_cost_pilot"),
		budget_cost = 3,
		post_event = "preplan_17",
		prio = 3
	}
	self.types.crojob2_manifest = {
		name_id = "menu_pp_asset_crojob2_manifest",
		desc_id = "menu_pp_asset_crojob2_manifest_desc",
		icon = 71,
		pos_not_important = true,
		category = "mission_equipment",
		total = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_thebomb_cost_manifest"),
		budget_cost = 2,
		post_event = "preplan_14",
		prio = 3
	}
	self.types.crojob3_escape_boat = {
		name_id = "menu_pp_crojob3_escape_boat",
		desc_id = "menu_pp_crojob3_escape_boat_desc",
		plan = "escape_plan",
		pos_not_important = false,
		category = "escape_plan",
		icon = 54,
		total = 1,
		cost = 0,
		budget_cost = 0,
		post_event = "preplan_16",
		prio = 3
	}
	self.types.crojob3_escape_plane = {
		name_id = "menu_pp_crojob3_escape_plane",
		desc_id = "menu_pp_crojob3_escape_plane_desc",
		plan = "escape_plan",
		pos_not_important = false,
		category = "escape_plan",
		icon = 54,
		total = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_thebomb_cost_escape_mid"),
		budget_cost = 4,
		post_event = "preplan_13",
		prio = 3
	}
	self.types.crojob3_escape_helicopter = {
		name_id = "menu_pp_crojob3_escape_helicopter",
		desc_id = "menu_pp_crojob3_escape_helicopter_desc",
		plan = "escape_plan",
		pos_not_important = false,
		category = "escape_plan",
		icon = 54,
		total = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_thebomb_cost_escape_close"),
		budget_cost = 8,
		post_event = "preplan_14",
		prio = 3
	}
	self.types.crojob3_demolition_expert = {
		name_id = "menu_pp_asset_crojob3_demolition_expert",
		desc_id = "menu_pp_asset_crojob3_demolition_expert_desc",
		pos_not_important = false,
		icon = 65,
		category = "hired_help",
		total = 3,
		cost = tweak_data:get_value("money_manager", "preplaning_thebomb_cost_demolition"),
		budget_cost = 1,
		post_event = "preplan_14",
		prio = 3
	}
	self.types.crojob3_better_pilot = {
		name_id = "menu_pp_asset_crojob3_better_pilot",
		desc_id = "menu_pp_asset_crojob3_better_pilot_desc",
		pos_not_important = true,
		icon = 73,
		category = "hired_help",
		total = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_thebomb_cost_pilot"),
		budget_cost = 4,
		post_event = "preplan_17",
		prio = 3
	}
	self.types.crojob3_sniper = {
		name_id = "menu_pp_asset_sniper",
		desc_id = "menu_pp_asset_sniper_desc",
		pos_not_important = false,
		icon = 55,
		category = "hired_help",
		total = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_mia_cost_sniper"),
		budget_cost = 4,
		post_event = "preplan_13",
		prio = 3
	}
	self.types.crojob3_ladder = {
		name_id = "menu_pp_asset_crojob3_ladder",
		desc_id = "menu_pp_asset_crojob3_ladder_desc",
		pos_not_important = false,
		icon = 63,
		category = "mission_equipment",
		total = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_thebomb_cost_ladder"),
		budget_cost = 1,
		post_event = "preplan_15",
		prio = 5
	}
	self.types.crojob3_crowbar = {
		name_id = "menu_pp_asset_crojob3_crowbar",
		desc_id = "menu_pp_asset_crojob3_crowbar_desc",
		pos_not_important = false,
		icon = 72,
		category = "mission_equipment",
		total = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_thebomb_cost_crowbar"),
		budget_cost = 1,
		post_event = "preplan_15",
		prio = 5
	}
	self.types.glass_cutter = {
		name_id = "menu_pp_asset_glass_cutter",
		desc_id = "menu_pp_asset_glass_cutter_desc",
		category = "mission_equipment",
		icon = 64,
		total = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_glass_cutter"),
		budget_cost = 1,
		post_event = "preplan_16",
		prio = 2
	}
	self.types.kenaz_silent_entry = {
		name_id = "menu_pp_asset_kenaz_silent_entry",
		desc_id = "menu_pp_asset_kenaz_silent_entry_desc",
		plan = "entry_plan",
		pos_not_important = false,
		category = "entry_plan",
		icon = 94,
		cost = 0,
		budget_cost = 0,
		post_event = "",
		prio = 3
	}
	self.types.kenaz_loud_entry = {
		name_id = "menu_pp_asset_kenaz_loud_entry",
		desc_id = "menu_pp_asset_kenaz_loud_entry_desc",
		plan = "entry_plan",
		pos_not_important = false,
		category = "entry_plan",
		icon = 95,
		cost = 0,
		budget_cost = 0,
		post_event = "",
		prio = 3
	}
	self.types.kenaz_loud_entry_with_c4 = {
		name_id = "menu_pp_asset_kenaz_loud_entry_with_c4",
		desc_id = "menu_pp_asset_kenaz_loud_entry_with_c4_desc",
		plan = "entry_plan",
		pos_not_important = false,
		category = "entry_plan",
		icon = 95,
		cost = 0,
		budget_cost = 6,
		post_event = "",
		prio = 3
	}
	self.types.kenaz_limo_escape = {
		name_id = "menu_pp_asset_kenaz_limo_escape",
		desc_id = "menu_pp_asset_kenaz_limo_escape_desc",
		plan = "escape_plan",
		pos_not_important = false,
		category = "escape_plan",
		icon = 54,
		total = 1,
		cost = 0,
		budget_cost = 0,
		post_event = "preplan_12",
		prio = 3
	}
	self.types.kenaz_zeppelin_escape = {
		name_id = "menu_pp_asset_kenaz_zeppelin_escape",
		desc_id = "menu_pp_asset_kenaz_zeppelin_escape_desc",
		plan = "escape_plan",
		pos_not_important = false,
		category = "escape_plan",
		icon = 54,
		total = 1,
		cost = 0,
		budget_cost = 4,
		post_event = "preplan_12",
		prio = 3
	}
	self.types.kenaz_van_escape = {
		name_id = "menu_pp_asset_kenaz_van_escape",
		desc_id = "menu_pp_asset_kenaz_van_escape_desc",
		plan = "escape_plan",
		pos_not_important = false,
		category = "escape_plan",
		icon = 54,
		total = 1,
		cost = 0,
		budget_cost = 8,
		post_event = "preplan_12",
		prio = 3
	}
	self.types.kenaz_wrecking_ball_escape = {
		name_id = "menu_pp_asset_kenaz_wrecking_ball_escape",
		desc_id = "menu_pp_asset_kenaz_wrecking_ball_escape_desc",
		plan = "escape_plan",
		pos_not_important = false,
		category = "escape_plan",
		icon = 54,
		total = 1,
		cost = 0,
		budget_cost = 10,
		post_event = "preplan_12",
		prio = 3
	}
	self.types.sentry_gun = {
		name_id = "menu_pp_asset_sentry_gun",
		desc_id = "menu_pp_asset_sentry_gun_desc",
		icon = 75,
		category = "dead_drop",
		total = 2,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_deaddropbag"),
		budget_cost = 1,
		post_event = "",
		prio = 5
	}
	self.types.kenaz_drill_better_plasma_cutter = {
		name_id = "menu_pp_asset_kenaz_drill_better_plasma_cutter",
		desc_id = "menu_pp_asset_kenaz_drill_better_plasma_cutter_desc",
		pos_not_important = false,
		category = "BFD_upgrades",
		icon = 64,
		cost = 0,
		budget_cost = 2,
		post_event = "",
		prio = 3
	}
	self.types.kenaz_drill_improved_cooling_system = {
		name_id = "menu_pp_asset_kenaz_drill_improved_cooling_system",
		desc_id = "menu_pp_asset_kenaz_drill_improved_cooling_system_desc",
		pos_not_important = false,
		category = "BFD_upgrades",
		icon = 92,
		cost = 0,
		budget_cost = 3,
		post_event = "",
		prio = 3
	}
	self.types.kenaz_drill_engine_optimization = {
		name_id = "menu_pp_asset_kenaz_drill_engine_optimization",
		desc_id = "menu_pp_asset_kenaz_drill_engine_optimization_desc",
		pos_not_important = false,
		category = "BFD_upgrades",
		icon = 15,
		cost = 0,
		budget_cost = 2,
		post_event = "",
		prio = 3
	}
	self.types.kenaz_drill_engine_additional_power = {
		name_id = "menu_pp_asset_kenaz_drill_engine_additional_power",
		desc_id = "menu_pp_asset_kenaz_drill_engine_additional_power_desc",
		pos_not_important = false,
		category = "BFD_upgrades",
		icon = 44,
		cost = 0,
		budget_cost = 3,
		post_event = "",
		prio = 3
	}
	self.types.kenaz_drill_sentry = {
		name_id = "menu_pp_asset_kenaz_drill_sentry",
		desc_id = "menu_pp_asset_kenaz_drill_sentry_desc",
		pos_not_important = false,
		category = "BFD_attachments",
		icon = 75,
		total = 2,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_deaddropbag"),
		budget_cost = 1,
		post_event = "",
		prio = 3
	}
	self.types.kenaz_drill_extra_battery = {
		name_id = "menu_pp_asset_kenaz_drill_extra_battery",
		desc_id = "menu_pp_asset_kenaz_drill_extra_battery_desc",
		pos_not_important = false,
		category = "BFD_attachments",
		icon = 44,
		cost = 0,
		budget_cost = 3,
		post_event = "",
		prio = 3
	}
	self.types.kenaz_drill_water_level_indicator = {
		name_id = "menu_pp_asset_kenaz_drill_water_level_indicator",
		desc_id = "menu_pp_asset_kenaz_drill_water_level_indicator_desc",
		pos_not_important = false,
		category = "BFD_attachments",
		icon = 92,
		cost = 0,
		budget_cost = 1,
		post_event = "",
		prio = 3
	}
	self.types.kenaz_drill_timer_addon = {
		name_id = "menu_pp_asset_kenaz_drill_timer_addon",
		desc_id = "menu_pp_asset_kenaz_drill_timer_addon_desc",
		pos_not_important = false,
		category = "BFD_attachments",
		icon = 15,
		cost = 0,
		budget_cost = 1,
		post_event = "",
		prio = 3
	}
	self.types.kenaz_drill_toolbox = {
		name_id = "menu_pp_asset_kenaz_drill_toolbox",
		desc_id = "menu_pp_asset_kenaz_drill_toolbox_desc",
		pos_not_important = false,
		category = "BFD_attachments",
		icon = 93,
		cost = 0,
		budget_cost = 1,
		post_event = "",
		prio = 3
	}
	self.types.kenaz_drill_medkit = {
		name_id = "menu_pp_asset_kenaz_drill_medkit",
		desc_id = "menu_pp_asset_kenaz_drill_medkit_desc",
		pos_not_important = false,
		category = "BFD_attachments",
		icon = 31,
		cost = 0,
		budget_cost = 2,
		post_event = "",
		prio = 3
	}
	self.types.kenaz_drill_ammobox = {
		name_id = "menu_pp_asset_kenaz_drill_ammobox",
		desc_id = "menu_pp_asset_kenaz_drill_ammobox_desc",
		pos_not_important = false,
		category = "BFD_attachments",
		icon = 52,
		cost = 0,
		budget_cost = 2,
		post_event = "",
		prio = 3
	}
	self.types.kenaz_ace_pilot = {
		name_id = "menu_pp_asset_kenaz_ace_pilot",
		desc_id = "menu_pp_asset_kenaz_ace_pilot_desc",
		pos_not_important = true,
		category = "hired_help",
		icon = 73,
		cost = 0,
		budget_cost = 1,
		post_event = "",
		prio = 3
	}
	self.types.kenaz_faster_blimp = {
		name_id = "menu_pp_asset_kenaz_faster_blimp",
		desc_id = "menu_pp_asset_kenaz_faster_blimp_desc",
		pos_not_important = true,
		category = "hired_help",
		icon = 74,
		cost = 0,
		budget_cost = 2,
		post_event = "",
		prio = 3
	}
	self.types.kenaz_rig_slotmachine = {
		name_id = "menu_pp_asset_kenaz_rig_slotmachine",
		desc_id = "menu_pp_asset_kenaz_rig_slotmachine_desc",
		pos_not_important = true,
		category = "data_hacking",
		icon = 45,
		total = 1,
		cost = 0,
		budget_cost = 4,
		post_event = "",
		prio = 3
	}
	self.types.kenaz_sabotage_skylight_barrier = {
		name_id = "menu_pp_asset_kenaz_sabotage_skylight_barrier",
		desc_id = "menu_pp_asset_kenaz_sabotage_skylight_barrier_desc",
		pos_not_important = false,
		category = "data_hacking",
		icon = 42,
		total = 1,
		cost = 0,
		budget_cost = 3,
		post_event = "",
		prio = 3
	}
	self.types.kenaz_customer_data_USB = {
		name_id = "menu_pp_asset_kenaz_customer_data_USB",
		desc_id = "menu_pp_asset_kenaz_customer_data_USB_desc",
		pos_not_important = true,
		category = "mission_equipment",
		icon = 85,
		total = 1,
		cost = 0,
		budget_cost = 3,
		post_event = "",
		prio = 3
	}
	self.types.kenaz_unlocked_cages = {
		name_id = "menu_pp_asset_kenaz_unlocked_cages",
		desc_id = "menu_pp_asset_kenaz_unlocked_cages_desc",
		pos_not_important = false,
		category = "insider_help",
		upgrade_lock = {
			upgrade = "additional_assets",
			category = "player"
		},
		icon = 41,
		total = 1,
		cost = 0,
		budget_cost = 3,
		post_event = "",
		prio = 3
	}
	self.types.kenaz_unlocked_doors = {
		name_id = "menu_pp_asset_kenaz_unlocked_doors",
		desc_id = "menu_pp_asset_kenaz_unlocked_doors_desc",
		pos_not_important = false,
		category = "insider_help",
		upgrade_lock = {
			upgrade = "additional_assets",
			category = "player"
		},
		icon = 41,
		total = 1,
		cost = 0,
		budget_cost = 2,
		post_event = "",
		prio = 3
	}
	self.types.kenaz_guitar_case_position = {
		name_id = "menu_pp_asset_kenaz_guitar_case_position",
		desc_id = "menu_pp_asset_kenaz_guitar_case_position_desc",
		pos_not_important = false,
		category = "insider_help",
		upgrade_lock = {
			upgrade = "additional_assets",
			category = "player"
		},
		icon = 83,
		total = 1,
		cost = 0,
		budget_cost = 1,
		post_event = "",
		prio = 3
	}
	self.types.kenaz_disable_metal_detectors = {
		name_id = "menu_pp_asset_kenaz_disable_metal_detectors",
		desc_id = "menu_pp_asset_kenaz_disable_metal_detectors_desc",
		pos_not_important = true,
		category = "insider_help",
		upgrade_lock = {
			upgrade = "additional_assets",
			category = "player"
		},
		icon = 42,
		total = 1,
		cost = 0,
		budget_cost = 1,
		post_event = "",
		prio = 3
	}
	self.types.kenaz_celebrity_visit = {
		name_id = "menu_pp_asset_kenaz_celebrity_visit",
		desc_id = "menu_pp_asset_kenaz_celebrity_visit_desc",
		pos_not_important = false,
		category = "hired_help",
		icon = 91,
		total = 1,
		cost = 0,
		budget_cost = 2,
		post_event = "",
		prio = 3
	}
	self.types.kenaz_vault_gate_key = {
		name_id = "menu_pp_asset_kenaz_vault_gate_key",
		desc_id = "menu_pp_asset_kenaz_vault_gate_key_desc",
		pos_not_important = true,
		category = "mission_equipment",
		icon = 43,
		total = 1,
		cost = 0,
		budget_cost = 2,
		post_event = "",
		prio = 3
	}
	self.types.mex_keys = {
		name_id = "menu_pp_asset_mex_keys",
		desc_id = "menu_pp_asset_mex_keys_desc",
		category = "mission_equipment",
		icon = 43,
		total = 1,
		post_event = "gus_preplan_07",
		prio = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_mex_keys"),
		budget_cost = 3
	}
	self.types.roof_access = {
		name_id = "menu_pp_asset_roof_access",
		desc_id = "menu_pp_asset_roof_access_desc",
		category = "mission_equipment",
		icon = 63,
		total = 2,
		post_event = "gus_preplan_07",
		prio = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_roof_access"),
		budget_cost = 3
	}
	self.types.upper_floor_access = {
		name_id = "menu_pp_asset_upper_floor_access",
		desc_id = "menu_pp_asset_upper_floor_access_desc",
		category = "mission_equipment",
		icon = 63,
		total = 1,
		post_event = "gus_preplan_07",
		prio = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_upper_floor_access"),
		budget_cost = 2
	}
	self.types.crowbar_single = {
		name_id = "menu_pp_asset_crowbar_single",
		desc_id = "menu_pp_asset_crowbar_single_desc",
		category = "mission_equipment",
		icon = 72,
		total = 1,
		post_event = "gus_preplan_07",
		prio = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_crowbar_single"),
		budget_cost = 1
	}
	self.types.bex_car_pull = {
		name_id = "menu_pp_asset_bex_car_pull",
		desc_id = "menu_pp_asset_bex_car_pull_desc",
		category = "hired_help",
		icon = 103,
		total = 1,
		post_event = "gus_preplan_07",
		prio = 1,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_mex_keys"),
		budget_cost = 6
	}
	self.types.bex_drunk_mariachi = {
		name_id = "menu_pp_asset_bex_drunk_mariachi",
		desc_id = "menu_pp_asset_bex_drunk_mariachi_desc",
		category = "hired_help",
		icon = 101,
		total = 1,
		post_event = "gus_preplan_07",
		prio = 3,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_mex_keys"),
		budget_cost = 3
	}
	self.types.bex_garbage_truck = {
		name_id = "menu_pp_asset_bex_garbage_truck",
		desc_id = "menu_pp_asset_bex_garbage_truck_desc",
		category = "hired_help",
		icon = 102,
		total = 1,
		post_event = "gus_preplan_07",
		prio = 3,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_mex_keys"),
		budget_cost = 3
	}
	self.types.bex_zipline = {
		name_id = "menu_pp_asset_bex_zipline",
		desc_id = "menu_pp_asset_bex_zipline_desc",
		category = "hired_help",
		icon = 95,
		total = 1,
		post_event = "gus_preplan_07",
		prio = 3,
		cost = tweak_data:get_value("money_manager", "preplaning_asset_cost_mex_keys"),
		budget_cost = 3
	}
end

function PrePlanningTweakData:_create_locations(tweak_data)
	self.upgrade_locks = {
		"none",
		"additional_assets"
	}
	self.dlc_locks = {
		"none",
		"big_bank"
	}
	self.location_groups = {
		"a",
		"b",
		"c",
		"d",
		"e",
		"f"
	}
	self.locations = {
		big = {
			{
				texture = "guis/dlcs/big_bank/textures/pd2/pre_planning/big_lobby",
				x2 = 5750,
				rotation = 90,
				map_size = 1,
				map_x = -1.1,
				x1 = -250,
				name_id = "menu_pp_big_loc_a",
				y2 = 3000,
				y1 = -3000,
				map_y = -0 + 0.5,
				custom_points = {
					{
						text_id = "menu_pp_info_frontdoor",
						rotation = -90,
						y = 1025,
						to_upper = true,
						icon = 45,
						x = 1500,
						post_event = "pln_pp_bb1_a"
					},
					{
						text_id = "menu_pp_info_backoffices",
						rotation = -90,
						y = 480,
						to_upper = true,
						icon = 45,
						x = 800,
						post_event = "pln_pp_bb1_c"
					},
					{
						text_id = "menu_pp_info_garage",
						rotation = -90,
						y = 1690,
						to_upper = true,
						icon = 45,
						x = 1300,
						post_event = "pln_pp_bb1_l"
					},
					{
						text_id = "menu_pp_info_mainhall",
						rotation = -90,
						y = 1025,
						to_upper = true,
						icon = 45,
						x = 1000,
						post_event = "pln_pp_bb1_n"
					},
					{
						text_id = "menu_pp_info_entrypoint",
						rotation = -90,
						y = 350,
						to_upper = true,
						icon = 45,
						x = 1950,
						post_event = "pln_pp_bb1_o"
					},
					{
						text_id = "menu_pp_info_timelock",
						rotation = -90,
						y = 1024,
						to_upper = true,
						icon = 45,
						x = 90,
						post_event = "pln_pp_bb1_d"
					},
					{
						text_id = "menu_pp_info_securityroom",
						rotation = -90,
						y = 590,
						to_upper = true,
						icon = 45,
						x = 348,
						post_event = "pln_pp_bb1_i"
					},
					{
						text_id = "menu_pp_info_securityroom",
						rotation = -90,
						y = 1742,
						to_upper = true,
						icon = 45,
						x = 574,
						post_event = "pln_pp_bb1_i"
					}
				}
			},
			{
				texture = "guis/dlcs/big_bank/textures/pd2/pre_planning/big_level_2",
				x2 = 5750,
				rotation = 90,
				map_size = 1,
				map_x = 0,
				x1 = -250,
				map_y = 0.5,
				name_id = "menu_pp_big_loc_b",
				y2 = 3000,
				y1 = -3000,
				custom_points = {
					{
						text_id = "menu_pp_info_mgroffices",
						rotation = -90,
						y = 1700,
						to_upper = true,
						icon = 45,
						x = 190,
						post_event = "pln_pp_bb1_k"
					},
					{
						text_id = "menu_pp_info_backoffices",
						rotation = -90,
						y = 480,
						to_upper = true,
						icon = 45,
						x = 800,
						post_event = "pln_pp_bb1_c"
					},
					{
						text_id = "menu_pp_info_timelock",
						rotation = -90,
						y = 1024,
						to_upper = true,
						icon = 45,
						x = 90,
						post_event = "pln_pp_bb1_d"
					},
					{
						text_id = "menu_pp_info_ladder",
						rotation = -90,
						y = 1625,
						to_upper = true,
						icon = 45,
						x = 870,
						post_event = "pln_pp_bb1_b"
					},
					{
						text_id = "menu_pp_info_securityroom",
						rotation = -90,
						y = 1437,
						to_upper = true,
						icon = 45,
						x = 164,
						post_event = "pln_pp_bb1_i"
					}
				}
			},
			{
				texture = "guis/dlcs/big_bank/textures/pd2/pre_planning/big_roof",
				x2 = 5750,
				rotation = 90,
				map_size = 1,
				map_x = 1.1,
				x1 = -250,
				name_id = "menu_pp_big_loc_c",
				y2 = 3000,
				y1 = -3000,
				map_y = -0 + 0.5,
				custom_points = {
					{
						text_id = "menu_pp_info_ladder",
						rotation = -90,
						y = 1629,
						to_upper = true,
						icon = 45,
						x = 869,
						post_event = "pln_pp_bb1_b"
					},
					{
						text_id = "menu_pp_info_zipline",
						rotation = -90,
						y = 1164,
						to_upper = true,
						icon = 45,
						x = 1356,
						post_event = "pln_pp_bb1_m"
					},
					{
						text_id = "menu_pp_info_roof",
						rotation = -90,
						y = 1458,
						to_upper = true,
						icon = 45,
						x = 782,
						post_event = "pln_pp_bb1_h"
					}
				}
			},
			{
				texture = "guis/dlcs/big_bank/textures/pd2/pre_planning/big_level_vault_2",
				x2 = 229,
				rotation = 90,
				map_size = 1,
				x1 = -5771,
				map_y = -0.6000000000000001,
				name_id = "menu_pp_big_loc_d",
				y2 = 3000,
				y1 = -3000,
				map_x = -0,
				custom_points = {
					{
						text_id = "menu_pp_info_vaultsecurity1",
						rotation = -90,
						y = 1298,
						to_upper = true,
						icon = 45,
						x = 1152,
						post_event = "pln_pp_bb1_g"
					},
					{
						text_id = "menu_pp_info_vaultsecurity2",
						rotation = -90,
						y = 746,
						to_upper = true,
						icon = 45,
						x = 1152,
						post_event = "pln_pp_bb1_g"
					},
					{
						text_id = "menu_pp_info_vault",
						rotation = -90,
						y = 1365,
						to_upper = true,
						icon = 45,
						x = 465,
						post_event = "pln_pp_bb1_f"
					}
				}
			},
			{
				texture = "guis/dlcs/big_bank/textures/pd2/pre_planning/big_level_vault",
				x2 = 229,
				rotation = 90,
				map_size = 1,
				map_x = -1.1,
				x1 = -5771,
				map_y = -0.6000000000000001,
				name_id = "menu_pp_big_loc_e",
				y2 = 3000,
				y1 = -3000,
				custom_points = {
					{
						text_id = "menu_pp_info_moneycounting",
						rotation = -90,
						y = 1015,
						to_upper = true,
						icon = 45,
						x = 1154,
						post_event = "pln_pp_bb1_e"
					},
					{
						text_id = "menu_pp_info_vault",
						rotation = -90,
						y = 1365,
						to_upper = true,
						icon = 45,
						x = 465,
						post_event = "pln_pp_bb1_f"
					}
				}
			},
			mission_briefing_texture = "guis/textures/pd2/pre_planning/mission_briefing_big",
			total_budget = 10,
			default_plans = {
				escape_plan = "escape_helicopter_loud",
				vault_plan = "vault_big_drill"
			},
			start_location = {
				group = "a",
				zoom = 1.5,
				x = 1500,
				y = 1025
			}
		},
		mia_1 = {
			{
				texture = "guis/textures/pd2/pre_planning/hlm_01",
				x2 = 7476,
				rotation = 0,
				map_width = 2,
				map_x = -0.55,
				x1 = -5524,
				map_height = 1,
				map_y = 0,
				name_id = "menu_pp_mia_1_loc_a",
				y2 = 1142,
				y1 = -5358,
				custom_points = {}
			},
			{
				texture = "guis/textures/pd2/pre_planning/hlm_02",
				x2 = 7782,
				rotation = 0,
				map_width = 1,
				map_x = 1.05,
				x1 = -1018,
				map_height = 0.5,
				map_y = -0.25,
				name_id = "menu_pp_mia_1_loc_b",
				y2 = -272,
				y1 = -4672,
				custom_points = {}
			},
			{
				texture = "guis/textures/pd2/pre_planning/hlm_03",
				x2 = 7782,
				rotation = 0,
				map_width = 1,
				map_x = 1.05,
				x1 = -1018,
				map_height = 0.5,
				map_y = 0.25,
				name_id = "menu_pp_mia_1_loc_c",
				y2 = -272,
				y1 = -4672,
				custom_points = {}
			},
			grid_width_mul = 0.5,
			mission_briefing_texture = "guis/textures/pd2/pre_planning/mission_briefing_hlm1",
			grid_height_mul = 1.4,
			total_budget = 6,
			default_plans = {},
			start_location = {
				group = "a",
				zoom = 1,
				x = 1024,
				y = 512
			}
		},
		mia_2 = {
			{
				texture = "guis/textures/pd2/pre_planning/hlm2_01",
				x2 = 3850,
				rotation = 0,
				map_width = 1,
				map_x = 0,
				x1 = -3050,
				map_height = 1,
				map_y = 1,
				name_id = "menu_pp_mia_2_loc_a",
				y2 = 3625,
				y1 = -3275,
				custom_points = {
					{
						text_id = "menu_pp_info_the_box",
						rotation = 0,
						y = 840,
						to_upper = true,
						icon = 45,
						x = 290,
						post_event = "Play_pln_pp_hm2_01"
					},
					{
						text_id = "menu_pp_info_bombstrapped",
						rotation = 0,
						y = 507,
						to_upper = true,
						icon = 45,
						x = 423,
						post_event = "Play_pln_pp_hm2_04"
					}
				}
			},
			{
				texture = "guis/textures/pd2/pre_planning/hlm2_02",
				x2 = 3850,
				rotation = 0,
				map_width = 1,
				map_x = -1,
				x1 = -3050,
				map_height = 1,
				map_y = 0,
				name_id = "menu_pp_mia_2_loc_b",
				y2 = 3625,
				y1 = -3275,
				custom_points = {}
			},
			{
				texture = "guis/textures/pd2/pre_planning/hlm2_03",
				x2 = 3850,
				rotation = 0,
				map_width = 1,
				map_x = 0,
				x1 = -3050,
				map_height = 1,
				map_y = 0,
				name_id = "menu_pp_mia_2_loc_c",
				y2 = 3625,
				y1 = -3275,
				custom_points = {}
			},
			{
				texture = "guis/textures/pd2/pre_planning/hlm2_04",
				x2 = 3850,
				rotation = 0,
				map_width = 1,
				map_x = 1,
				x1 = -3050,
				map_height = 1,
				map_y = 0,
				name_id = "menu_pp_mia_2_loc_d",
				y2 = 3625,
				y1 = -3275,
				custom_points = {}
			},
			{
				texture = "guis/textures/pd2/pre_planning/hlm2_05",
				x2 = 3850,
				rotation = 0,
				map_width = 1,
				map_x = 0,
				x1 = -3050,
				map_height = 1,
				map_y = -1,
				name_id = "menu_pp_mia_2_loc_e",
				y2 = 3625,
				y1 = -3275,
				custom_points = {
					{
						text_id = "menu_pp_info_vault_comm",
						rotation = 0,
						y = 143,
						to_upper = true,
						icon = 45,
						x = 300,
						post_event = "Play_pln_pp_hm2_02"
					},
					{
						text_id = "menu_pp_info_cocaine_mountain",
						rotation = 0,
						y = 143,
						to_upper = true,
						icon = 45,
						x = 546,
						post_event = "Play_pln_pp_hm2_03"
					}
				}
			},
			mission_briefing_texture = "guis/textures/pd2/pre_planning/mission_briefing_hlm2",
			grid_width_mul = 0.5,
			grid_height_mul = 0.5,
			total_budget = 6,
			default_plans = {},
			start_location = {
				group = "a",
				zoom = 1.25,
				x = 290,
				y = 835
			}
		},
		framing_frame_1 = {
			{
				texture = "guis/textures/pd2/pre_planning/framing_frame_1_1",
				x2 = 2750,
				rotation = 90,
				map_size = 1,
				map_x = -0.6,
				x1 = -2750,
				map_y = 0,
				name_id = "menu_pp_framing_frame_1_loc_a",
				y2 = 2750,
				y1 = -2750,
				custom_points = {}
			},
			{
				texture = "guis/textures/pd2/pre_planning/framing_frame_1_2",
				x2 = 6300,
				rotation = 90,
				map_size = 1,
				map_x = 0.6,
				x1 = -2700,
				map_y = 0,
				name_id = "menu_pp_framing_frame_1_loc_b",
				y2 = 3700,
				y1 = -5300,
				custom_points = {}
			},
			mission_briefing_texture = "guis/textures/pd2/pre_planning/mission_briefing_framingframe1",
			total_budget = 8,
			default_plans = {},
			start_location = {
				group = "a",
				zoom = 1,
				x = 512,
				y = 512
			}
		}
	}
	self.locations.gallery = deep_clone(self.locations.framing_frame_1)
	self.locations.branchbank = {
		{
			texture = "guis/textures/pd2/pre_planning/branchbank_1",
			x2 = 500,
			rotation = 0,
			map_size = 1,
			map_x = -0.6,
			x1 = -3500,
			map_y = 0,
			name_id = "menu_pp_branchbank_loc_a",
			y2 = 3700,
			y1 = -300,
			custom_points = {}
		},
		{
			texture = "guis/textures/pd2/pre_planning/branchbank_2",
			x2 = 2500,
			rotation = 0,
			map_size = 1,
			map_x = 0.6,
			x1 = -5500,
			map_y = 0,
			name_id = "menu_pp_branchbank_loc_b",
			y2 = 4800,
			y1 = -3200,
			custom_points = {}
		},
		mission_briefing_texture = "guis/textures/pd2/pre_planning/mission_briefing_big",
		total_budget = 8,
		default_plans = {
			vault_plan = "branchbank_lance"
		},
		start_location = {
			group = "a",
			zoom = 1,
			x = 512,
			y = 512
		}
	}
	self.locations.firestarter_3 = {
		{
			texture = "guis/textures/pd2/pre_planning/branchbank_1",
			x2 = 500,
			rotation = 0,
			map_size = 1,
			map_x = -0.6,
			x1 = -3500,
			map_y = 0,
			name_id = "menu_pp_branchbank_loc_a",
			y2 = 3700,
			y1 = -300,
			custom_points = {}
		},
		{
			texture = "guis/textures/pd2/pre_planning/branchbank_2",
			x2 = 2500,
			rotation = 0,
			map_size = 1,
			map_x = 0.6,
			x1 = -5500,
			map_y = 0,
			name_id = "menu_pp_branchbank_loc_b",
			y2 = 4800,
			y1 = -3200,
			custom_points = {}
		},
		mission_briefing_texture = "guis/textures/pd2/pre_planning/mission_briefing_big",
		total_budget = 8,
		default_plans = {
			vault_plan = "branchbank_lance"
		},
		start_location = {
			group = "a",
			zoom = 1,
			x = 512,
			y = 512
		}
	}
	self.locations.framing_frame_3 = {
		{
			texture = "guis/textures/pd2/pre_planning/framing_frame_3_1",
			x2 = -1400,
			rotation = 0,
			map_size = 1,
			map_x = -1.1,
			x1 = -6600,
			map_y = 0,
			name_id = "menu_pp_framing_frame_3_loc_b",
			y2 = 5800,
			y1 = 600,
			custom_points = {}
		},
		{
			texture = "guis/textures/pd2/pre_planning/framing_frame_3_2",
			x2 = -1400,
			rotation = 0,
			map_size = 1,
			map_x = 0,
			x1 = -6600,
			map_y = 0,
			name_id = "menu_pp_framing_frame_3_loc_a",
			y2 = 5900,
			y1 = 700,
			custom_points = {}
		},
		{
			texture = "guis/textures/pd2/pre_planning/framing_frame_3_3",
			x2 = -1325,
			rotation = 0,
			map_size = 1,
			map_x = 1.1,
			x1 = -7325,
			map_y = 0,
			name_id = "menu_pp_framing_frame_3_loc_c",
			y2 = 6625,
			y1 = 625,
			custom_points = {}
		},
		grid_width_mul = 2.2,
		mission_briefing_texture = "guis/textures/pd2/pre_planning/mission_briefing_framingframe3",
		grid_height_mul = 1.5,
		min_zoom = 0.7,
		total_budget = 8,
		default_plans = {},
		start_location = {
			group = "a",
			zoom = 1,
			x = 512,
			y = 512
		}
	}
	self.locations.kosugi = {
		{
			texture = "guis/textures/pd2/pre_planning/shadow_raid_1",
			x2 = 6850,
			rotation = 0,
			map_size = 2,
			map_x = -0.5999999999999999,
			x1 = -5650,
			map_y = -0.5999999999999999,
			name_id = "menu_pp_shadow_raid_loc_a",
			y2 = 4650,
			y1 = -7850,
			custom_points = {}
		},
		{
			texture = "guis/textures/pd2/pre_planning/shadow_raid_2",
			x2 = 1550,
			rotation = 0,
			map_size = 1,
			map_x = 1.1,
			x1 = -3950,
			map_y = -1.1,
			name_id = "menu_pp_shadow_raid_loc_b",
			y2 = -650,
			y1 = -6150,
			custom_points = {}
		},
		{
			texture = "guis/textures/pd2/pre_planning/shadow_raid_3",
			x2 = 1550,
			rotation = 0,
			map_size = 1,
			map_x = 1.1,
			x1 = -3950,
			map_y = 0,
			name_id = "menu_pp_shadow_raid_loc_c",
			y2 = -650,
			y1 = -6150,
			custom_points = {}
		},
		{
			texture = "guis/textures/pd2/pre_planning/shadow_raid_4",
			x2 = 1550,
			rotation = 0,
			map_size = 1,
			map_x = 1.1,
			x1 = -3950,
			map_y = 1.1,
			name_id = "menu_pp_shadow_raid_loc_d",
			y2 = -650,
			y1 = -6150,
			custom_points = {}
		},
		mission_briefing_texture = "guis/textures/pd2/pre_planning/mission_briefing_shadowraid",
		min_zoom = 0.4,
		total_budget = 8,
		default_plans = {},
		start_location = {
			group = "a",
			zoom = 0.8,
			x = 2048,
			y = 1024
		}
	}
	self.locations.mus = {
		{
			texture = "guis/textures/pd2/pre_planning/mus_1",
			x2 = 10000,
			rotation = -90,
			map_width = 1,
			map_x = -1.05,
			x1 = -10000,
			map_height = 2,
			map_y = 0,
			name_id = "menu_pp_mus_loc_a",
			y2 = 5000,
			y1 = -5000,
			custom_points = {}
		},
		{
			texture = "guis/textures/pd2/pre_planning/mus_2",
			x2 = 10000,
			rotation = -90,
			map_width = 1,
			map_x = 0,
			x1 = -10000,
			map_height = 2,
			map_y = 0,
			name_id = "menu_pp_mus_loc_b",
			y2 = 5000,
			y1 = -5000,
			custom_points = {}
		},
		{
			texture = "guis/textures/pd2/pre_planning/mus_3",
			x2 = 10000,
			rotation = -90,
			map_width = 1,
			map_x = 1.05,
			x1 = -10000,
			map_height = 2,
			map_y = 0,
			name_id = "menu_pp_mus_loc_c",
			y2 = 5000,
			y1 = -5000,
			custom_points = {}
		},
		mission_briefing_texture = "guis/textures/pd2/pre_planning/mission_briefing_museum",
		total_budget = 10,
		default_plans = {},
		start_location = {
			group = "a",
			zoom = 1.5,
			x = 1024,
			y = 521
		}
	}
	self.locations.crojob2 = {
		{
			texture = "guis/dlcs/the_bomb/textures/pd2/pre_planning/crojob_stage_2_a",
			x2 = 10500,
			rotation = 0,
			map_size = 1,
			map_x = 0,
			x1 = -9500,
			map_y = 0,
			name_id = "menu_pp_crojob_stage_2_loc_a",
			y2 = 11500,
			y1 = -8500,
			custom_points = {
				{
					text_id = "menu_pp_info_crojob2_ship",
					rotation = 0,
					y = 1134,
					to_upper = true,
					icon = 45,
					x = 964,
					post_event = "Play_pln_cr2_14"
				},
				{
					text_id = "menu_pp_info_crojob2_loading_dock_3B",
					rotation = 0,
					y = 538,
					to_upper = true,
					icon = 45,
					x = 454,
					post_event = "Play_pln_cr2_105"
				},
				{
					text_id = "menu_pp_info_crojob2_dock_gate",
					rotation = 0,
					y = 770,
					to_upper = true,
					icon = 45,
					x = 964,
					post_event = "Play_pln_cr2_106"
				},
				{
					text_id = "menu_pp_info_crojob2_control_room_right",
					rotation = 0,
					y = 768,
					to_upper = true,
					icon = 45,
					x = 1134,
					post_event = "Play_pln_cr2_107"
				},
				{
					text_id = "menu_pp_info_crojob2_control_room_left",
					rotation = 0,
					y = 768,
					to_upper = true,
					icon = 45,
					x = 798,
					post_event = "Play_pln_cr2_108"
				},
				{
					text_id = "menu_pp_info_crojob2_fence_gate",
					rotation = 0,
					y = 702,
					to_upper = true,
					icon = 45,
					x = 82,
					post_event = "Play_pln_cr2_109"
				},
				{
					text_id = "menu_pp_info_crojob2_locker_room",
					rotation = 0,
					y = 1508,
					to_upper = true,
					icon = 45,
					x = 1524,
					post_event = "Play_pln_cr2_110"
				},
				{
					text_id = "menu_pp_info_crojob2_office",
					rotation = 0,
					y = 1336,
					to_upper = true,
					icon = 45,
					x = 1526,
					post_event = "Play_pln_cr2_111"
				},
				{
					text_id = "menu_pp_info_crojob2_storage_room",
					rotation = 0,
					y = 1122,
					to_upper = true,
					icon = 45,
					x = 348,
					post_event = "Play_pln_cr2_112"
				},
				{
					text_id = "menu_pp_info_crojob2_ship_control_room_left",
					rotation = 0,
					y = 1420,
					to_upper = true,
					icon = 45,
					x = 350,
					post_event = "Play_pln_cr2_113"
				},
				{
					text_id = "menu_pp_info_crojob2_ship_control_room_right",
					rotation = 0,
					y = 1118,
					to_upper = true,
					icon = 45,
					x = 1424,
					post_event = "Play_pln_cr2_114"
				}
			}
		},
		mission_briefing_texture = "guis/textures/pd2/pre_planning/mission_briefing_crojob_stealth",
		total_budget = 10,
		default_plans = {
			escape_plan = "crojob2_escape_van"
		},
		start_location = {
			group = "a",
			zoom = 1.5,
			x = 1024,
			y = 1024
		}
	}
	self.locations.crojob3 = {
		{
			texture = "guis/dlcs/the_bomb/textures/pd2/pre_planning/crojob_stage_3_a",
			x2 = 14950,
			rotation = 0,
			map_size = 1,
			map_x = 0,
			x1 = -50,
			map_y = -0.5,
			name_id = "menu_pp_crojob_stage_3_loc_a",
			y2 = 10775,
			y1 = -4225,
			custom_points = {
				{
					text_id = "menu_pp_info_crojob3_vault",
					rotation = 0,
					y = 550,
					to_upper = true,
					icon = 45,
					x = 512,
					post_event = "Play_pln_cr3_48"
				},
				{
					text_id = "menu_pp_info_crojob3_water_pump",
					rotation = 0,
					y = 584,
					to_upper = true,
					icon = 45,
					x = 846,
					post_event = "Play_pln_cr3_50"
				}
			}
		},
		{
			texture = "guis/dlcs/the_bomb/textures/pd2/pre_planning/crojob_stage_3_b",
			x2 = 13250,
			rotation = 0,
			map_size = 1,
			map_x = 0,
			x1 = -50,
			map_y = 0.5,
			name_id = "menu_pp_crojob_stage_3_loc_b",
			y2 = -4225,
			y1 = -19225,
			custom_points = {
				{
					text_id = "menu_pp_info_crojob3_thermite",
					rotation = 0,
					y = 566,
					to_upper = true,
					icon = 45,
					x = 533,
					post_event = "Play_pln_cr3_49"
				}
			}
		},
		mission_briefing_texture = "guis/textures/pd2/pre_planning/mission_briefing_crojob_loud",
		total_budget = 10,
		default_plans = {
			escape_plan = "crojob3_escape_boat"
		},
		start_location = {
			group = "a",
			zoom = 1,
			x = 512,
			y = 512
		}
	}
	self.locations.crojob3_night = {
		{
			texture = "guis/dlcs/the_bomb/textures/pd2/pre_planning/crojob_stage_3_a",
			x2 = 14950,
			rotation = 0,
			map_size = 1,
			map_x = 0,
			x1 = -50,
			map_y = -0.5,
			name_id = "menu_pp_crojob_stage_3_loc_a",
			y2 = 10775,
			y1 = -4225,
			custom_points = {
				{
					text_id = "menu_pp_info_crojob3_vault",
					rotation = 0,
					y = 550,
					to_upper = true,
					icon = 45,
					x = 512,
					post_event = "Play_pln_cr3_48"
				},
				{
					text_id = "menu_pp_info_crojob3_water_pump",
					rotation = 0,
					y = 584,
					to_upper = true,
					icon = 45,
					x = 846,
					post_event = "Play_pln_cr3_50"
				}
			}
		},
		{
			texture = "guis/dlcs/the_bomb/textures/pd2/pre_planning/crojob_stage_3_b",
			x2 = 13250,
			rotation = 0,
			map_size = 1,
			map_x = 0,
			x1 = -50,
			map_y = 0.5,
			name_id = "menu_pp_crojob_stage_3_loc_b",
			y2 = -4225,
			y1 = -19225,
			custom_points = {
				{
					text_id = "menu_pp_info_crojob3_thermite",
					rotation = 0,
					y = 566,
					to_upper = true,
					icon = 45,
					x = 533,
					post_event = "Play_pln_cr3_49"
				}
			}
		},
		mission_briefing_texture = "guis/textures/pd2/pre_planning/mission_briefing_crojob_loud",
		total_budget = 10,
		default_plans = {
			escape_plan = "crojob3_escape_boat"
		},
		start_location = {
			group = "a",
			zoom = 1,
			x = 512,
			y = 512
		}
	}
	self.locations.kenaz = {
		{
			texture = "guis/dlcs/kenaz/textures/pd2/pre_planning/kenaz_loc_a_df",
			map_width = 1,
			x2 = 4975,
			rotation = 0,
			map_x = -1.1,
			x1 = -6175,
			map_height = 2,
			map_y = 0,
			name_id = "menu_pp_kenaz_loc_a",
			y2 = 7850,
			y1 = -14450
		},
		{
			texture = "guis/dlcs/kenaz/textures/pd2/pre_planning/kenaz_loc_b_df",
			x2 = 5475,
			rotation = 0,
			map_width = 1,
			map_x = 0,
			x1 = -6175,
			map_height = 2,
			map_y = 0,
			name_id = "menu_pp_kenaz_loc_b",
			y2 = 8350,
			y1 = -14450,
			custom_points = {
				{
					text_id = "menu_pp_info_kenaz_reception",
					rotation = -90,
					y = 1181,
					to_upper = true,
					icon = 45,
					x = 544,
					post_event = "Play_pln_ca1_140"
				},
				{
					text_id = "menu_pp_info_kenaz_lobby",
					rotation = -90,
					y = 1223,
					to_upper = true,
					icon = 45,
					x = 546,
					post_event = "Play_pln_ca1_141"
				},
				{
					text_id = "menu_pp_info_kenaz_pool_area",
					rotation = -90,
					y = 1020,
					to_upper = true,
					icon = 45,
					x = 229,
					post_event = "Play_pln_ca1_142"
				},
				{
					text_id = "menu_pp_info_kenaz_outside_lounge",
					rotation = -90,
					y = 971,
					to_upper = true,
					icon = 45,
					x = 812,
					post_event = "Play_pln_ca1_143"
				},
				{
					text_id = "menu_pp_info_kenaz_gambling_hall",
					rotation = -90,
					y = 924,
					to_upper = true,
					icon = 45,
					x = 551,
					post_event = "Play_pln_ca1_144"
				},
				{
					text_id = "menu_pp_info_kenaz_employees_only",
					rotation = -90,
					y = 566,
					to_upper = true,
					icon = 45,
					x = 550,
					post_event = "Play_pln_ca1_146"
				},
				{
					text_id = "menu_pp_info_kenaz_security_center",
					rotation = -90,
					y = 625,
					to_upper = true,
					icon = 45,
					x = 546,
					post_event = "Play_pln_ca1_147"
				}
			}
		},
		{
			texture = "guis/dlcs/kenaz/textures/pd2/pre_planning/kenaz_loc_c_df",
			map_width = 0.5,
			x2 = 200,
			rotation = 0,
			map_x = 0.85,
			x1 = -200,
			map_height = 1,
			map_y = -0.5,
			name_id = "menu_pp_kenaz_loc_c",
			y2 = 400,
			y1 = -400
		},
		mission_briefing_texture = "guis/textures/pd2/pre_planning/mission_briefing_casino",
		total_budget = 15,
		default_plans = {
			entry_plan = "kenaz_silent_entry",
			escape_plan = "kenaz_limo_escape"
		},
		start_location = {
			group = "a",
			zoom = 1,
			x = 1024,
			y = 1024
		},
		start_location = {
			group = "b",
			zoom = 1,
			x = 512,
			y = 512
		},
		start_location = {
			group = "c",
			zoom = 1,
			x = 512,
			y = 512
		}
	}
	self.locations.pbr = {
		{
			texture = "guis/dlcs/berry/textures/pd2/pre_planning/base_01",
			x2 = -5000,
			rotation = 90,
			map_size = 1,
			map_x = -0.55,
			x1 = -15000,
			map_y = 0,
			name_id = "menu_pp_berry_bpr_loc_a",
			y2 = 2400,
			y1 = -7600,
			custom_points = {}
		},
		{
			texture = "guis/dlcs/berry/textures/pd2/pre_planning/base_02",
			x2 = -5100,
			rotation = 0,
			map_size = 1,
			map_x = 0.55,
			x1 = -15100,
			map_y = 0,
			name_id = "menu_pp_berry_bpr_loc_b",
			y2 = 2000,
			y1 = -8000,
			custom_points = {}
		},
		mission_briefing_texture = "guis/dlcs/berry/textures/pd2/pre_planning/mission_briefing_pbr",
		total_budget = 6,
		default_plans = {},
		start_location = {
			group = "a",
			zoom = 1,
			x = 1024,
			y = 1024
		}
	}
	self.locations.mex = {
		{
			texture = "guis/dlcs/mex/textures/pd2/pre_planning/mex_01",
			map_width = 1,
			x2 = 6750,
			map_x = -0.6,
			x1 = -2450,
			map_size = 1,
			map_height = 1,
			map_y = 1.1,
			name_id = "menu_pp_mex_loc_a",
			y2 = 6450,
			y1 = -2750,
			rotation = -0,
			custom_points = {
				{
					text_id = "menu_pp_info_mex_entry",
					rotation = 0,
					y = 1024,
					to_upper = true,
					icon = 45,
					x = 150
				},
				{
					text_id = "menu_pp_info_mex_shack_north",
					rotation = 0,
					y = 450,
					to_upper = true,
					icon = 45,
					x = 875
				},
				{
					text_id = "menu_pp_info_mex_shack_south",
					rotation = 0,
					y = 1700,
					to_upper = true,
					icon = 45,
					x = 975
				},
				{
					text_id = "menu_pp_info_mex_tunnel_entrance_north",
					rotation = 0,
					y = 370,
					to_upper = true,
					icon = 45,
					x = 1212
				},
				{
					text_id = "menu_pp_info_mex_tunnel_entrance_east",
					rotation = 0,
					y = 970,
					to_upper = true,
					icon = 45,
					x = 1700
				},
				{
					text_id = "menu_pp_info_mex_tunnel_entrance_south",
					rotation = 0,
					y = 1650,
					to_upper = true,
					icon = 45,
					x = 1750
				}
			}
		},
		{
			texture = "guis/dlcs/mex/textures/pd2/pre_planning/mex_02",
			map_width = 1,
			x2 = 6750,
			map_x = -0.6,
			x1 = -2450,
			map_size = 1,
			map_height = 1,
			map_y = 0,
			name_id = "menu_pp_mex_loc_b",
			y2 = 6450,
			y1 = -2750,
			rotation = -0,
			custom_points = {
				{
					text_id = "menu_pp_info_mex_briefing_room",
					rotation = 0,
					y = 990,
					to_upper = true,
					icon = 45,
					x = 1018
				},
				{
					text_id = "menu_pp_info_mex_secruity_room_a",
					rotation = 0,
					y = 915,
					to_upper = true,
					icon = 45,
					x = 860
				},
				{
					text_id = "menu_pp_info_mex_secruity_room_b",
					rotation = 0,
					y = 930,
					to_upper = true,
					icon = 45,
					x = 1290
				}
			}
		},
		{
			texture = "guis/dlcs/mex/textures/pd2/pre_planning/mex_03",
			map_width = 1,
			x2 = 8172,
			map_x = 0.6,
			x1 = -3822,
			map_size = 1,
			map_height = 1,
			map_y = 1.1,
			name_id = "menu_pp_mex_loc_c",
			y2 = -3603,
			y1 = -15597,
			rotation = -0,
			custom_points = {
				{
					text_id = "menu_pp_info_mex_tunnel_exit_north",
					rotation = 0,
					y = 240,
					to_upper = true,
					icon = 45,
					x = 1420
				},
				{
					text_id = "menu_pp_info_mex_tunnel_exit_west",
					rotation = 0,
					y = 1270,
					to_upper = true,
					icon = 45,
					x = 260
				},
				{
					text_id = "menu_pp_info_mex_tunnel_exit_south",
					rotation = 0,
					y = 1630,
					to_upper = true,
					icon = 45,
					x = 1820
				},
				{
					text_id = "menu_pp_info_mex_hangar_a",
					rotation = 0,
					y = 830,
					to_upper = true,
					icon = 45,
					x = 1630
				},
				{
					text_id = "menu_pp_info_mex_hangar_b",
					rotation = 0,
					y = 1200,
					to_upper = true,
					icon = 45,
					x = 1720
				},
				{
					text_id = "menu_pp_info_mex_storage_06",
					rotation = 0,
					y = 980,
					to_upper = true,
					icon = 45,
					x = 610
				},
				{
					text_id = "menu_pp_info_mex_storage_05",
					rotation = 0,
					y = 805,
					to_upper = true,
					icon = 45,
					x = 610
				},
				{
					text_id = "menu_pp_info_mex_storage_04",
					rotation = 0,
					y = 730,
					to_upper = true,
					icon = 45,
					x = 610
				},
				{
					text_id = "menu_pp_info_mex_storage_01",
					rotation = 0,
					y = 300,
					to_upper = true,
					icon = 45,
					x = 710
				},
				{
					text_id = "menu_pp_info_mex_storage_02",
					rotation = 0,
					y = 300,
					to_upper = true,
					icon = 45,
					x = 800
				},
				{
					text_id = "menu_pp_info_mex_storage_03",
					rotation = 0,
					y = 300,
					to_upper = true,
					icon = 45,
					x = 880
				},
				{
					text_id = "menu_pp_info_mex_storage_07",
					rotation = 0,
					y = 1720,
					to_upper = true,
					icon = 45,
					x = 590
				},
				{
					text_id = "menu_pp_info_mex_storage_08",
					rotation = 0,
					y = 1480,
					to_upper = true,
					icon = 45,
					x = 1210
				},
				{
					text_id = "menu_pp_info_mex_storage_09",
					rotation = 0,
					y = 1845,
					to_upper = true,
					icon = 45,
					x = 930
				}
			}
		},
		{
			texture = "guis/dlcs/mex/textures/pd2/pre_planning/mex_04",
			map_width = 1,
			x2 = 8172,
			map_x = 0.6,
			x1 = -3822,
			map_size = 1,
			map_height = 1,
			map_y = 0,
			name_id = "menu_pp_mex_loc_d",
			y2 = -3603,
			y1 = -15597,
			rotation = -0,
			custom_points = {
				{
					text_id = "menu_pp_info_mex_controlroom",
					rotation = 0,
					y = 700,
					to_upper = true,
					icon = 45,
					x = 580
				},
				{
					text_id = "menu_pp_info_mex_secruity_room_c",
					rotation = 0,
					y = 575,
					to_upper = true,
					icon = 45,
					x = 975
				},
				{
					text_id = "menu_pp_info_mex_secruity_room_d",
					rotation = 0,
					y = 840,
					to_upper = true,
					icon = 45,
					x = 550
				},
				{
					text_id = "menu_pp_info_mex_secruity_room_e",
					rotation = 0,
					y = 575,
					to_upper = true,
					icon = 45,
					x = 1070
				}
			}
		},
		{
			texture = "guis/dlcs/mex/textures/pd2/pre_planning/mex_05",
			map_width = 1,
			x2 = 8172,
			map_x = 0.6,
			x1 = -3822,
			map_size = 1,
			map_height = 1,
			map_y = -1.1,
			name_id = "menu_pp_mex_loc_e",
			y2 = -3603,
			y1 = -15597,
			rotation = -0,
			custom_points = {
				{
					text_id = "menu_pp_info_mex_roof_entrance_a",
					rotation = 0,
					y = 530,
					to_upper = true,
					icon = 45,
					x = 950
				},
				{
					text_id = "menu_pp_info_mex_roof_entrance_b",
					rotation = 0,
					y = 900,
					to_upper = true,
					icon = 45,
					x = 800
				}
			}
		},
		{
			texture = "guis/dlcs/mex/textures/pd2/pre_planning/mex_boarder_01",
			map_size = 1,
			skip_for_grid = true,
			map_y = -0.3,
			x2 = 10000,
			map_x = 0,
			x1 = -10000,
			map_height = 4,
			map_width = 0.12,
			name_id = "menu_pp_mex_loc_boarder",
			y2 = 5000,
			y1 = -5000,
			rotation = -0
		},
		grid_width_mul = 1,
		post_event_prefix = "loc",
		mission_briefing_texture = "guis/dlcs/mex/textures/pd2/pre_planning/mex_01",
		total_budget = 10,
		default_plans = {},
		start_location = {
			group = "a",
			zoom = 1.5,
			x = 1024,
			y = 1024
		},
		active_location_groups = {
			"a",
			"b"
		}
	}
	self.locations.bex = {
		{
			texture = "guis/dlcs/bex/textures/pd2/pre_planning/bex_01",
			x2 = 6000,
			rotation = 180,
			map_size = 1,
			map_x = -0.55,
			map_y = 0,
			name_id = "menu_pp_bex_bpr_loc_a",
			y2 = 5000,
			y1 = -7000,
			x1 = -0 - 6000,
			custom_points = {}
		},
		{
			texture = "guis/dlcs/bex/textures/pd2/pre_planning/bex_02",
			x2 = 6000,
			rotation = 180,
			map_size = 1,
			map_x = 0.25,
			map_y = 0,
			name_id = "menu_pp_bex_bpr_loc_b",
			y2 = 5000,
			y1 = -7000,
			x1 = -0 - 6000,
			custom_points = {}
		},
		{
			texture = "guis/dlcs/bex/textures/pd2/pre_planning/bex_03",
			x2 = 6000,
			rotation = 180,
			map_size = 1,
			map_x = 1.05,
			map_y = 0,
			name_id = "menu_pp_bex_bpr_loc_c",
			y2 = 5000,
			y1 = -7000,
			x1 = -0 - 6000,
			custom_points = {}
		},
		mission_briefing_texture = "guis/dlcs/bex/textures/pd2/pre_planning/bex_preview",
		post_event_prefix = "loc",
		total_budget = 10,
		default_plans = {},
		start_location = {
			group = "a",
			zoom = 1,
			x = 512,
			y = 512
		}
	}
end

function PrePlanningTweakData:get_level_data(level_id)
	return self.locations[level_id] or {}
end
