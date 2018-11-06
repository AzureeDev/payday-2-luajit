TangoTweakData = TangoTweakData or class()

function TangoTweakData:init(tweak_data)
	self.arbiter_data = {
		weapon_id = "arbiter",
		factory_id = "wpn_fps_gre_arbiter"
	}
	self.challenges = {}

	table.insert(self.challenges, {
		name_id = "menu_tango_1",
		reward_type = "tango",
		id = "tango_1",
		desc_id = "menu_tango_1_desc",
		show_progress = true,
		objectives = {
			tweak_data.safehouse:_progress("tango_1_key_1", 1, {
				name_id = "menu_tango_key_1",
				desc_id = "menu_tango_1_key_1_desc"
			}),
			tweak_data.safehouse:_progress("tango_1_key_2", 1, {
				name_id = "menu_tango_key_2",
				desc_id = "menu_tango_1_key_2_desc"
			}),
			tweak_data.safehouse:_progress("tango_1_case", 1, {
				name_id = "menu_tango_case",
				desc_id = "menu_tango_1_case_desc"
			})
		},
		rewards = {
			{
				item_entry = "tng_bandana",
				type_items = "masks"
			},
			{
				item_entry = "army_deep_green",
				type_items = "materials"
			},
			{
				item_entry = "facepaint",
				type_items = "textures"
			},
			{
				tango_weapon_part = true
			}
		}
	})
	table.insert(self.challenges, {
		name_id = "menu_tango_2",
		reward_type = "tango",
		id = "tango_2",
		desc_id = "menu_tango_2_desc",
		show_progress = true,
		objectives = {
			tweak_data.safehouse:_progress("tango_2_key_1", 1, {
				name_id = "menu_tango_key_1",
				desc_id = "menu_tango_2_key_1_desc"
			}),
			tweak_data.safehouse:_progress("tango_2_key_2", 1, {
				name_id = "menu_tango_key_2",
				desc_id = "menu_tango_2_key_2_desc"
			}),
			tweak_data.safehouse:_progress("tango_2_case", 1, {
				name_id = "menu_tango_case",
				desc_id = "menu_tango_2_case_desc"
			})
		},
		rewards = {
			{
				item_entry = "tng_cloaker",
				type_items = "masks"
			},
			{
				item_entry = "ranger_black",
				type_items = "materials"
			},
			{
				item_entry = "sight",
				type_items = "textures"
			},
			{
				tango_weapon_part = true
			}
		}
	})
	table.insert(self.challenges, {
		name_id = "menu_tango_3",
		reward_type = "tango",
		id = "tango_3",
		desc_id = "menu_tango_3_desc",
		show_progress = true,
		objectives = {
			tweak_data.safehouse:_progress("tango_3_key_1", 1, {
				name_id = "menu_tango_key_1",
				desc_id = "menu_tango_3_key_1_desc"
			}),
			tweak_data.safehouse:_progress("tango_3_key_2", 1, {
				name_id = "menu_tango_key_2",
				desc_id = "menu_tango_3_key_2_desc"
			}),
			tweak_data.safehouse:_progress("tango_3_case", 1, {
				name_id = "menu_tango_case",
				desc_id = "menu_tango_3_case_desc"
			})
		},
		rewards = {
			{
				item_entry = "tng_zeal_swat_mask",
				type_items = "masks"
			},
			{
				item_entry = "digital_camo",
				type_items = "materials"
			},
			{
				item_entry = "bullets",
				type_items = "textures"
			},
			{
				tango_weapon_part = true
			}
		}
	})
	table.insert(self.challenges, {
		name_id = "menu_tango_4",
		reward_type = "tango",
		id = "tango_4",
		desc_id = "menu_tango_4_desc",
		show_progress = true,
		objectives = {
			tweak_data.safehouse:_progress("tango_4_key_1", 1, {
				name_id = "menu_tango_key_1",
				desc_id = "menu_tango_4_key_1_desc"
			}),
			tweak_data.safehouse:_progress("tango_4_key_2", 1, {
				name_id = "menu_tango_key_2",
				desc_id = "menu_tango_4_key_2_desc"
			}),
			tweak_data.safehouse:_progress("tango_4_case", 1, {
				name_id = "menu_tango_case",
				desc_id = "menu_tango_4_case_desc"
			})
		},
		rewards = {
			{
				item_entry = "tng_cap",
				type_items = "masks"
			},
			{
				item_entry = "midnight_camo",
				type_items = "materials"
			},
			{
				item_entry = "stripes",
				type_items = "textures"
			},
			{
				tango_weapon_part = true
			}
		}
	})
end
