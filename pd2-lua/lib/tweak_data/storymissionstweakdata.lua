StoryMissionsTweakData = StoryMissionsTweakData or class()
StoryMissionsTweakData.DEFAULT_COINS = 3

function StoryMissionsTweakData:init(tweak_data)
	self._tweak_data = tweak_data

	self:_init_missions(tweak_data)

	self._tweak_data = nil
end

function StoryMissionsTweakData:_create_objective(data)
	data = data or {}
	data.complete = false
	data.max_progress = data.progress_id and data.max_progress or 1
	data.progress = 0

	return data
end

function StoryMissionsTweakData:_progress(progress_id, max_progress, data)
	data = data or {}
	data.progress_id = progress_id
	data.max_progress = max_progress or 1

	return self:_create_objective(data)
end

function StoryMissionsTweakData:_level_progress(progress_id, ...)
	local tweak_data = self._tweak_data or tweak_data
	local data = self:_progress(progress_id, ...)
	local ach = tweak_data.achievement.complete_heist_achievements[progress_id]

	if not ach then
		Application:error("Can't find in complete_heist_achievement!", progress_id)

		return data
	end

	local had_levels = data.levels
	data.levels = data.levels or ach.job and {ach.job} or ach.jobs
	data.difficulty = ach.difficulty and ach.difficulty[1]

	print("difficulty", data.difficulty, ach.difficulty and ach.difficulty[1])

	if not data.levels then
		Application:error("Can't find jobs data from achievement", progress_id)

		return data
	end

	return data
end

function StoryMissionsTweakData:_default_reward()
	return {{
		"safehouse_coins",
		self.DEFAULT_COINS
	}}
end

function StoryMissionsTweakData:_default_pre_coins()
	return {
		{
			type_items = "cash",
			item_entry = "cash20"
		},
		{
			type_items = "xp",
			item_entry = "xp20"
		}
	}
end

function StoryMissionsTweakData:get_mission(id)
	for idx, mission in ipairs(self.missions) do
		if mission.id == id then
			return mission
		end
	end
end

function StoryMissionsTweakData:_mission(id, data)
	data = data or {}
	data.id = id
	data.name_id = id .. "_name"
	data.desc_id = id .. "_desc"
	data.objective_id = id .. "_obj"

	return data
end

local function level_check(id, ach_id)
	local d = tweak_data.achievement.level_achievements[ach_id or id]

	if d.level <= managers.experience:current_level() then
		managers.story:award(id)
	end
end

local function maybe_award(id, check, set)
	if check then
		managers.story:award(id, set == true and check or set or nil)
	end
end

function StoryMissionsTweakData._sm_1_check(mission_data)
	level_check("story_basics_lvl10")
end

function StoryMissionsTweakData._sm_first_safehouse_check()
	maybe_award("story_first_safehouse", managers.custom_safehouse:unlocked())
end

function StoryMissionsTweakData._sm_2_check()
	local slots = managers.player:equipment_slots()

	maybe_award("story_inv_deployable", slots and #slots > 0)
	maybe_award("story_inv_perkdeck", managers.skilltree:current_specialization_tier() > 0)
	maybe_award("story_inv_skillpoints", tweak_data.story.sm_2_skillpoints <= managers.skilltree:total_points_spent())
end

function StoryMissionsTweakData._sm_moving_up_check()
	level_check("story_chill_level")
end

function StoryMissionsTweakData._sm_13_check()
	level_check("story_half_lvl")
end

function StoryMissionsTweakData:_init_missions(tweak_data)
	self.sm_2_skillpoints = 5
	self.missions = {
		self:_mission("sm_1", {
			reward_id = "menu_sm_pre_coin_reward",
			voice_line = "Play_pln_stq_01",
			custom_check = "_sm_1_check",
			objectives = {
				{
					self:_level_progress("story_basics_stealth", 1, {
						name_id = "menu_sm_basics_stealth",
						basic = true
					}),
					self:_level_progress("story_basics_loud", 1, {
						name_id = "menu_sm_basics_loud",
						basic = true
					})
				},
				{self:_progress("story_basics_lvl10", 1, {name_id = "menu_sm_basics_lvl"})}
			},
			rewards = self:_default_pre_coins()
		}),
		self:_mission("sm_first_safehouse", {
			reward_id = "menu_sm_pre_coin_reward",
			voice_line = "Play_pln_stq_29",
			custom_check = "_sm_first_safehouse_check",
			hide_progress = true,
			objectives = {{self:_progress("story_first_safehouse", 1, {name_id = "menu_sm_first_safehouse"})}},
			rewards = self:_default_pre_coins()
		}),
		self:_mission("sm_2", {
			reward_id = "menu_sm_pre_coin_reward",
			voice_line = "Play_pln_stq_02",
			custom_check = "_sm_2_check",
			objectives = {{
				self:_progress("story_inv_deployable", 1, {name_id = "menu_sm_inv_deployable"}),
				self:_progress("story_inv_perkdeck", 1, {name_id = "menu_sm_inv_perkdeck"}),
				self:_progress("story_inv_skillpoints", 1, {name_id = "menu_sm_inv_skillpoints"})
			}},
			rewards = self:_default_pre_coins()
		}),
		self:_mission("sm_3", {
			reward_id = "menu_sm_pre_coin_reward",
			voice_line = "Play_pln_stq_03",
			objectives = {{
				self:_level_progress("story_jewelry_store", 1, {name_id = "menu_sm_jewelry_store"}),
				self:_level_progress("story_bank_heist", 1, {name_id = "menu_sm_bank_heist"})
			}},
			rewards = self:_default_pre_coins()
		}),
		self:_mission("sm_4", {
			reward_id = "menu_sm_4_reward",
			voice_line = "Play_pln_stq_04",
			objectives = {{self:_progress("story_shadow_raid_bags", 4, {
				name_id = "menu_sm_shadow_raid_bags",
				levels = {"kosugi"}
			})}},
			rewards = {
				{
					type_items = "cash",
					item_entry = "cash20"
				},
				{
					type_items = "xp",
					item_entry = "xp20"
				},
				{
					type_items = "weapon_mods",
					item_entry = "wpn_fps_upg_ns_ass_smg_small"
				}
			}
		}),
		self:_mission("sm_5", {
			reward_id = "menu_sm_pre_coin_reward",
			voice_line = "Play_pln_stq_05",
			objectives = {{
				self:_level_progress("story_go_bank", 1, {name_id = "menu_sm_go_bank"}),
				self:_level_progress("story_diamond_store", 1, {name_id = "menu_sm_diamond_store"})
			}},
			rewards = self:_default_pre_coins()
		}),
		self:_mission("sm_6", {
			reward_id = "menu_sm_pre_coin_reward",
			voice_line = "Play_pln_stq_06",
			objectives = {{
				self:_level_progress("story_transport_mult", 3, {
					name_id = "menu_sm_transport_mult",
					levels = {
						"arm_cro",
						"arm_hcm",
						"arm_fac",
						"arm_par",
						"arm_und"
					}
				}),
				self:_level_progress("story_train_heist", 1, {name_id = "menu_sm_train_heist"})
			}},
			rewards = self:_default_pre_coins()
		}),
		self:_mission("sm_moving_up", {
			reward_id = "menu_sm_moving_up_reward",
			voice_line = "Play_pln_stq_30",
			custom_check = "_sm_moving_up_check",
			hide_progress = true,
			objectives = {{self:_progress("story_chill_level", 1, {name_id = "menu_sm_chill_level"})}},
			rewards = {{
				"safehouse_coins",
				6
			}}
		}),
		self:_mission("sm_7", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_07",
			objectives = {{
				self:_level_progress("story_hard_mallcrasher", 1, {name_id = "menu_sm_hard_mallcrasher"}),
				self:_level_progress("story_hard_four_store", 1, {name_id = "menu_sm_hard_four_store"})
			}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_8", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_08",
			objectives = {{
				self:_level_progress("story_hard_white_xmas", 1, {name_id = "menu_sm_hard_white_xmas"}),
				self:_level_progress("story_hard_ukrainian_job", 1, {name_id = "menu_sm_hard_ukrainian_job"})
			}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_9", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_09",
			objectives = {{self:_level_progress("story_hard_meltdown", 1, {name_id = "menu_sm_hard_meltdown"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_10", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_10",
			objectives = {{self:_level_progress("story_hard_aftershock", 1, {name_id = "menu_sm_hard_aftershock"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_12", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_12",
			objectives = {{
				self:_level_progress("story_hard_stealing_xmas", 1, {name_id = "menu_sm_hard_stealing_xmas"}),
				self:_level_progress("story_hard_nightclub", 1, {name_id = "menu_sm_hard_nightclub"})
			}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_13", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_13",
			custom_check = "_sm_13_check",
			hide_progress = true,
			objectives = {{self:_progress("story_half_lvl", 1, {name_id = "menu_sm_half_lvl"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_14", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_14",
			objectives = {{self:_level_progress("story_very_hard_watchdog", 1, {name_id = "menu_sm_very_hard_watchdog"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_15", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_15",
			objectives = {{self:_level_progress("story_very_hard_firestarter", 1, {name_id = "menu_sm_very_hard_firestarter"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_16", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_16",
			objectives = {{self:_level_progress("story_very_hard_rats", 1, {name_id = "menu_sm_very_hard_rats"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_17", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_17",
			objectives = {{self:_level_progress("story_very_hard_big_oil", 1, {name_id = "menu_sm_very_hard_big_oil"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_18", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_18",
			objectives = {{self:_level_progress("story_very_hard_framing_frames", 1, {name_id = "menu_sm_very_hard_framing_frames"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_19", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_19",
			objectives = {{self:_level_progress("story_very_hard_election_day", 1, {name_id = "menu_sm_very_hard_election_day"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_20", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_20",
			objectives = {{self:_level_progress("story_very_hard_big_bank", 1, {name_id = "menu_sm_very_hard_big_bank"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_21", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_21",
			objectives = {{self:_level_progress("story_very_hard_hotline_miami", 1, {name_id = "menu_sm_very_hard_hotline_miami"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_22", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_22",
			objectives = {{self:_level_progress("story_very_hard_hoxton_breakout", 1, {name_id = "menu_sm_very_hard_hoxton_breakout"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_hoxton_revenge", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_23",
			objectives = {{self:_level_progress("story_very_hard_hoxton_revenge", 1, {name_id = "menu_sm_very_hard_hoxton_revenge"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_23", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_24",
			objectives = {{self:_level_progress("story_very_hard_diamond", 1, {name_id = "menu_sm_very_hard_diamond"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_24", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_25",
			objectives = {{self:_level_progress("story_very_hard_golden_grin", 1, {name_id = "menu_sm_very_hard_golden_grin"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_25", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_26",
			objectives = {
				{self:_level_progress("story_very_hard_bomb_dockyard", 1, {name_id = "menu_sm_very_hard_bomb_dockyard"})},
				{self:_level_progress("story_very_hard_bomb_forest", 1, {name_id = "menu_sm_very_hard_bomb_forest"})}
			},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_26", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_27",
			objectives = {{self:_level_progress("story_very_hard_scarface", 1, {name_id = "menu_sm_very_hard_scarface"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_27", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_28",
			hide_progress = true,
			objectives = {{self:_progress("story_crime_spree", 1, {
				name_id = "menu_sm_crime_spree",
				crimespree = true
			})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_28", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_31",
			objectives = {
				{self:_level_progress("story_very_hard_alesso", 1, {name_id = "menu_sm_very_hard_alesso"})},
				{self:_level_progress("story_very_hard_counterfeit", 1, {name_id = "menu_sm_very_hard_counterfeit"})}
			},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_29", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_32",
			objectives = {{self:_level_progress("story_very_hard_first_world_bank", 1, {name_id = "menu_sm_very_hard_first_world_bank"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_30", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_33",
			objectives = {{self:_level_progress("story_very_hard_murky_station", 1, {name_id = "menu_sm_very_hard_murky_station"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_31", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_34",
			objectives = {{self:_level_progress("story_very_hard_boiling_point", 1, {name_id = "menu_sm_very_hard_boiling_point"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_32", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_35",
			objectives = {
				{self:_level_progress("story_very_hard_goat_sim", 1, {name_id = "menu_sm_very_hard_goat_sim"})},
				{self:_level_progress("story_very_hard_santas_workshop", 1, {name_id = "menu_sm_very_hard_santas_workshop"})}
			},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_33", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_36",
			objectives = {{self:_level_progress("story_very_hard_car_shop", 1, {name_id = "menu_sm_very_hard_car_shop"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_34", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_37",
			objectives = {{self:_level_progress("story_very_hard_biker_heist", 1, {name_id = "menu_sm_very_hard_biker_heist"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_35", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_38",
			objectives = {{self:_level_progress("story_very_hard_panic_room", 1, {name_id = "menu_sm_very_hard_panic_room"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_36", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_39",
			objectives = {{self:_level_progress("story_very_hard_brooklyn_10_10", 1, {name_id = "menu_sm_very_hard_brooklyn_10_10"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_37", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_40",
			objectives = {{self:_level_progress("story_very_hard_yacht", 1, {name_id = "menu_sm_very_hard_yacht"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_38", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_41",
			objectives = {{self:_level_progress("story_very_hard_undercover", 1, {name_id = "menu_sm_very_hard_undercover"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_39", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_42",
			objectives = {{self:_level_progress("story_very_hard_slaughterhouse", 1, {name_id = "menu_sm_very_hard_slaughterhouse"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_40", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_43",
			objectives = {{self:_level_progress("story_very_hard_beneath_the_mountain", 1, {name_id = "menu_sm_very_hard_beneath_the_mountain"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_41", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_44",
			objectives = {{self:_level_progress("story_very_hard_birth_of_sky", 1, {name_id = "menu_sm_very_hard_birth_of_sky"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_42", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_45",
			objectives = {{self:_level_progress("story_very_hard_heat_street", 1, {name_id = "menu_sm_very_hard_heat_street"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_43", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_46",
			objectives = {{self:_level_progress("story_very_hard_green_bridge", 1, {name_id = "menu_sm_very_hard_green_bridge"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_44", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_47",
			objectives = {{self:_level_progress("story_very_hard_alaskan_deal", 1, {name_id = "menu_sm_very_hard_alaskan_deal"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_45", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_48",
			objectives = {{self:_level_progress("story_very_hard_diamond_heist", 1, {name_id = "menu_sm_very_hard_diamond_heist"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_46", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_pln_stq_49",
			objectives = {{self:_level_progress("story_very_hard_reservoir_dogs", 1, {name_id = "menu_sm_very_hard_reservoir_dogs"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_47", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_loc_stq_01",
			objectives = {{self:_level_progress("story_very_hard_brooklyn_bank", 1, {name_id = "menu_sm_very_hard_brooklyn_bank"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_48", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_loc_stq_02",
			objectives = {{self:_level_progress("story_very_hard_breakin_feds", 1, {name_id = "menu_sm_very_hard_breakin_feds"})}},
			rewards = self:_default_reward()
		}),
		self:_mission("sm_49", {
			reward_id = "menu_sm_default_reward",
			voice_line = "Play_loc_stq_03",
			objectives = {{self:_level_progress("story_very_hard_henrys_rock", 1, {name_id = "menu_sm_very_hard_henrys_rock"})}},
			rewards = self:_default_reward()
		})
	}
end

