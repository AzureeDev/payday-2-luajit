EventJobsTweakData = EventJobsTweakData or class()

function EventJobsTweakData:init(tweak_data)
	self.challenges = {}

	self:_init_pda8_challenges(tweak_data)

	self.collective_stats = {
		pda8_collective = {
			found = {},
			all = {
				"pda8_item_1",
				"pda8_item_2",
				"pda8_item_3",
				"pda8_item_4",
				"pda8_item_5",
				"pda8_item_6",
				"pda8_item_7",
				"pda8_item_8"
			}
		}
	}
	self.pda_base = 0
end

function EventJobsTweakData:_init_pda8_challenges(tweak_data)
	table.insert(self.challenges, {
		reward_id = "menu_pda8_1_reward",
		name_id = "menu_pda8_1",
		is_active_func = "is_event_active",
		desc_id = "menu_pda8_1_desc",
		show_progress = true,
		locked_id = "bm_menu_locked_pda8_1",
		id = "pda8_1",
		objectives = {
			self:_collective("pda8_collective", 2, {
				name_id = "menu_pda8_1_prog_obj",
				desc_id = "menu_pda8_1_prog_obj_desc"
			})
		},
		rewards = {
			{
				item_entry = "money",
				type_items = "upgrades"
			},
			{
				item_entry = "cash60",
				type_items = "offshore"
			}
		}
	})
	table.insert(self.challenges, {
		reward_id = "menu_pda8_2_reward",
		locked_id = "bm_menu_locked_pda8_2",
		id = "pda8_2",
		name_id = "menu_pda8_2",
		desc_id = "menu_pda8_2_desc",
		show_progress = true,
		objectives = {
			self:_collective("pda8_collective", 4, {
				name_id = "menu_pda8_2_prog_obj",
				desc_id = "menu_pda8_2_prog_obj_desc"
			}),
			self:_stage("pda8_stages", 1, {
				name_id = "menu_pda8_2_track_obj",
				desc_id = "",
				stages = {
					2,
					3,
					4,
					5
				}
			})
		},
		rewards = {
			{
				item_entry = "jesterstripe",
				type_items = "gloves"
			}
		}
	})
	table.insert(self.challenges, {
		reward_id = "menu_pda8_3_reward",
		locked_id = "bm_menu_locked_pda8_3",
		id = "pda8_3",
		name_id = "menu_pda8_3",
		desc_id = "menu_pda8_3_desc",
		show_progress = true,
		objectives = {
			self:_collective("pda8_collective", 6, {
				name_id = "menu_pda8_3_prog_obj",
				desc_id = "menu_pda8_3_prog_obj_desc"
			}),
			self:_stage("pda8_stages", 1, {
				name_id = "menu_pda8_3_track_obj",
				desc_id = "",
				stages = {
					3,
					4,
					5
				}
			})
		},
		rewards = {
			{
				item_entry = "baron",
				type_items = "player_styles"
			}
		}
	})
	table.insert(self.challenges, {
		reward_id = "menu_pda8_4_reward",
		locked_id = "bm_menu_locked_pda8_4",
		id = "pda8_4",
		name_id = "menu_pda8_4",
		desc_id = "menu_pda8_4_desc",
		show_progress = true,
		objectives = {
			tweak_data.safehouse:_progress("pda8_item_1", 1, {
				name_id = "menu_pda8_item_1",
				desc_id = "menu_pda8_item_1_desc"
			}),
			tweak_data.safehouse:_progress("pda8_item_2", 1, {
				name_id = "menu_pda8_item_2",
				desc_id = ""
			}),
			tweak_data.safehouse:_progress("pda8_item_3", 1, {
				name_id = "menu_pda8_item_3",
				desc_id = ""
			}),
			tweak_data.safehouse:_progress("pda8_item_4", 1, {
				name_id = "menu_pda8_item_4",
				desc_id = ""
			}),
			tweak_data.safehouse:_progress("pda8_item_5", 1, {
				name_id = "menu_pda8_item_5",
				desc_id = ""
			}),
			tweak_data.safehouse:_progress("pda8_item_6", 1, {
				name_id = "menu_pda8_item_6",
				desc_id = ""
			}),
			tweak_data.safehouse:_progress("pda8_item_7", 1, {
				name_id = "menu_pda8_item_7",
				desc_id = ""
			}),
			tweak_data.safehouse:_progress("pda8_item_8", 1, {
				name_id = "menu_pda8_item_8",
				desc_id = ""
			}),
			self:_stage("pda8_stages", 1, {
				name_id = "menu_pda8_4_track_obj",
				desc_id = "",
				stages = {
					4,
					5
				}
			})
		},
		rewards = {
			{
				type_items = "masks",
				item_entry = "eighthgrin",
				amount = 1
			}
		}
	})
end

function EventJobsTweakData:_collective(collective_id, max_progress, data)
	data.collective_id = collective_id
	local save_values = {
		"achievement_id",
		"progress_id",
		"collective_id",
		"completed",
		"progress"
	}

	if data.save_values then
		for idx, value in ipairs(data.save_values) do
			table.insert(save_values, value)
		end
	end

	local obj = {
		progress = 0,
		completed = false,
		displayed = true,
		achievement_id = data.achievement_id,
		name_id = data.name_id,
		desc_id = data.desc_id,
		collective_id = collective_id,
		max_progress = data.collective_id and max_progress or 1,
		verify = data.verify,
		save_values = save_values
	}

	return obj
end

function EventJobsTweakData:_stage(stage_id, max_progress, data)
	data.stage_id = stage_id
	local save_values = {
		"achievement_id",
		"progress_id",
		"track_id",
		"completed",
		"progress",
		"track_id",
		"stage_id"
	}

	if data.save_values then
		for idx, value in ipairs(data.save_values) do
			table.insert(save_values, value)
		end
	end

	local obj = {
		progress = 0,
		completed = false,
		displayed = true,
		achievement_id = data.achievement_id,
		name_id = data.name_id,
		desc_id = data.desc_id,
		stage_id = stage_id,
		stages = data.stages,
		max_progress = data.stage_id and max_progress or 1,
		verify = data.verify,
		save_values = save_values
	}

	return obj
end
