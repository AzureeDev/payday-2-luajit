GageAssignmentTweakData = GageAssignmentTweakData or class()

function GageAssignmentTweakData:init(tweak_data)
	self.MAX_ACTIVE_ASSIGNMENTS = true
	self.NUM_ASSIGNMENT_UNITS = {
		2,
		4,
		6,
		8,
		10,
		10,
		10
	}
	self.EXPERIENCE_MULTIPLIER = 0.05
	self.assignments = {
		green_mantis = {}
	}
	self.assignments.green_mantis.unit = Idstring("units/pd2_dlc_gage_jobs/pickups/gen_pku_gage_green/gen_pku_gage_green")
	self.assignments.green_mantis.name_id = "menu_gage_green_mantis"
	self.assignments.green_mantis.desc_id = "menu_gage_green_mantis_desc"
	self.assignments.green_mantis.reward_id = "menu_gage_green_mantis_reward"
	self.assignments.green_mantis.progress_id = "hint_hud_gage_green_mantis_progress"
	self.assignments.green_mantis.present_id = "hud_gage_green_mantis_title"
	self.assignments.green_mantis.complete_id = "hud_gage_green_mantis_complete"
	self.assignments.green_mantis.insignia = "guis/dlcs/gage_pack_jobs/textures/pd2/gage_popup_img_green"
	self.assignments.green_mantis.aquire = 5
	self.assignments.green_mantis.dlc = "gage_pack_jobs"
	self.assignments.green_mantis.rewards = {
		{
			"gage_pack_jobs",
			"weapon_mods",
			"wpn_fps_upg_ak_b_draco"
		},
		{
			"gage_pack_jobs",
			"weapon_mods",
			"wpn_fps_upg_o_eotech_xps"
		},
		{
			"gage_pack_jobs",
			"weapon_mods",
			"wpn_fps_upg_o_reflex"
		},
		{
			"gage_pack_jobs",
			"weapon_mods",
			"wpn_fps_upg_ass_ns_jprifles"
		},
		{
			"gage_pack_jobs",
			"weapon_mods",
			"wpn_fps_upg_ak_g_hgrip"
		}
	}
	self.assignments.yellow_bull = {
		unit = Idstring("units/pd2_dlc_gage_jobs/pickups/gen_pku_gage_yellow/gen_pku_gage_yellow"),
		name_id = "menu_gage_yellow_bull",
		desc_id = "menu_gage_yellow_bull_desc",
		reward_id = "menu_gage_yellow_bull_reward",
		progress_id = "hint_hud_gage_yellow_bull_progress",
		present_id = "hud_gage_yellow_bull_title",
		complete_id = "hud_gage_yellow_bull_complete",
		insignia = "guis/dlcs/gage_pack_jobs/textures/pd2/gage_popup_img_yellow",
		aquire = 10,
		dlc = "gage_pack_jobs",
		rewards = {
			{
				"gage_pack_jobs",
				"weapon_mods",
				"wpn_fps_upg_m4_s_crane"
			},
			{
				"gage_pack_jobs",
				"weapon_mods",
				"wpn_fps_upg_ns_pis_medium_slim"
			},
			{
				"gage_pack_jobs",
				"weapon_mods",
				"wpn_fps_upg_o_rx01"
			},
			{
				"gage_pack_jobs",
				"weapon_mods",
				"wpn_fps_upg_ass_ns_linear"
			},
			{
				"gage_pack_jobs",
				"weapon_mods",
				"wpn_fps_upg_ak_g_pgrip"
			}
		}
	}
	self.assignments.red_spider = {
		unit = Idstring("units/pd2_dlc_gage_jobs/pickups/gen_pku_gage_red/gen_pku_gage_red"),
		name_id = "menu_gage_red_spider",
		desc_id = "menu_gage_red_spider_desc",
		reward_id = "menu_gage_red_spider_reward",
		progress_id = "hint_hud_gage_red_spider_progress",
		present_id = "hud_gage_red_spider_title",
		complete_id = "hud_gage_red_spider_complete",
		insignia = "guis/dlcs/gage_pack_jobs/textures/pd2/gage_popup_img_red",
		aquire = 15,
		dlc = "gage_pack_jobs",
		rewards = {
			{
				"gage_pack_jobs",
				"weapon_mods",
				"wpn_fps_upg_ak_fg_tapco"
			},
			{
				"gage_pack_jobs",
				"weapon_mods",
				"wpn_fps_upg_fg_smr"
			},
			{
				"gage_pack_jobs",
				"weapon_mods",
				"wpn_fps_upg_fl_ass_laser"
			},
			{
				"gage_pack_jobs",
				"weapon_mods",
				"wpn_fps_upg_m4_s_mk46"
			},
			{
				"gage_pack_jobs",
				"weapon_mods",
				"wpn_fps_upg_ass_ns_surefire"
			},
			{
				"gage_pack_jobs",
				"weapon_mods",
				"wpn_fps_upg_ak_g_wgrip"
			}
		}
	}
	self.assignments.blue_eagle = {
		unit = Idstring("units/pd2_dlc_gage_jobs/pickups/gen_pku_gage_blue/gen_pku_gage_blue"),
		name_id = "menu_gage_blue_eagle",
		desc_id = "menu_gage_blue_eagle_desc",
		reward_id = "menu_gage_blue_eagle_reward",
		progress_id = "hint_hud_gage_blue_eagle_progress",
		present_id = "hud_gage_blue_eagle_title",
		complete_id = "hud_gage_blue_eagle_complete",
		insignia = "guis/dlcs/gage_pack_jobs/textures/pd2/gage_popup_img_blue",
		aquire = 20,
		dlc = "gage_pack_jobs",
		rewards = {
			{
				"gage_pack_jobs",
				"weapon_mods",
				"wpn_fps_pis_deagle_extra"
			},
			{
				"gage_pack_jobs",
				"weapon_mods",
				"wpn_fps_upg_ak_m_quad"
			},
			{
				"gage_pack_jobs",
				"weapon_mods",
				"wpn_fps_upg_fl_ass_peq15"
			},
			{
				"gage_pack_jobs",
				"weapon_mods",
				"wpn_fps_upg_o_rx30"
			},
			{
				"gage_pack_jobs",
				"weapon_mods",
				"wpn_fps_upg_pis_ns_flash"
			},
			{
				"gage_pack_jobs",
				"weapon_mods",
				"wpn_fps_upg_o_cs"
			}
		}
	}
	self.assignments.purple_snake = {
		unit = Idstring("units/pd2_dlc_gage_jobs/pickups/gen_pku_gage_purple/gen_pku_gage_purple"),
		name_id = "menu_gage_purple_snake",
		desc_id = "menu_gage_purple_snake_desc",
		reward_id = "menu_gage_purple_snake_reward",
		progress_id = "hint_hud_gage_purple_snake_progress",
		present_id = "hud_gage_purple_snake_title",
		complete_id = "hud_gage_purple_snake_complete",
		insignia = "guis/dlcs/gage_pack_jobs/textures/pd2/gage_popup_img_purple",
		aquire = 25,
		dlc = "gage_pack_jobs",
		rewards = {
			{
				"gage_pack_jobs",
				"weapon_mods",
				"wpn_fps_pis_rage_extra"
			},
			{
				"gage_pack_jobs",
				"weapon_mods",
				"wpn_fps_upg_fg_jp"
			},
			{
				"gage_pack_jobs",
				"weapon_mods",
				"wpn_fps_upg_fg_midwest"
			},
			{
				"gage_pack_jobs",
				"weapon_mods",
				"wpn_fps_upg_m4_m_quad"
			},
			{
				"gage_pack_jobs",
				"weapon_mods",
				"wpn_fps_upg_o_rmr"
			},
			{
				"gage_pack_jobs",
				"weapon_mods",
				"wpn_fps_upg_shot_ns_king"
			}
		}
	}
	local free_dlcs = tweak_data:free_dlc_list()

	for _, data in pairs(self.assignments) do
		if free_dlcs[data.dlc] then
			data.dlc = nil
		end

		for _, reward in ipairs(data.rewards) do
			if free_dlcs[reward[1]] then
				reward[1] = "normal"
			end
		end
	end
end

function GageAssignmentTweakData:get_experience_multiplier(ratio)
	return 1 + self.EXPERIENCE_MULTIPLIER * math.clamp(ratio or 0, 0, 1)
end

function GageAssignmentTweakData:exists(assignment)
	return self.assignments[assignment] and true or false
end

function GageAssignmentTweakData:get_value(assignment, value)
	return self.assignments[assignment] and self.assignments[assignment][value] or false
end

function GageAssignmentTweakData:get_max_aquire()
	local max_aquire = 0

	for i, assignment in pairs(self.assignments) do
		max_aquire = math.max(max_aquire, assignment.aquire or 1)
	end

	return max_aquire
end

function GageAssignmentTweakData:fetch_new_assignments(level_id)
	local max_assignments = self.MAX_ACTIVE_ASSIGNMENTS
	local assignments = {}
	level_id = tostring(level_id)

	for assignment, data in pairs(self:get_assignments()) do
		local pass_level = not data.levels or table.contains(data.levels, level_id)
		local pass_all_tests = pass_level

		if pass_all_tests then
			table.insert(assignments, assignment)
		end
	end

	if max_assignments and max_assignments ~= true then
		local num_to_remove = #assignments - max_assignments

		for i = 1, num_to_remove do
			table.remove(assignments, math.random(#assignments))
		end
	end

	return assignments
end

function GageAssignmentTweakData:get_assignments()
	return self.assignments
end

function GageAssignmentTweakData:get_num_assignment_units()
	if not self.NUM_ASSIGNMENT_UNITS then
		return 1
	end

	local num_assignment_units = self.NUM_ASSIGNMENT_UNITS
	local difficulty = managers.job:current_difficulty_stars() + 1

	if difficulty < 1 or difficulty > #self.NUM_ASSIGNMENT_UNITS then
		debug_pause("GageAssignmentTweakData:get_num_assignment_units() difficulty out of bound", difficulty, inspect(self.NUM_ASSIGNMENT_UNITS))

		difficulty = math.clamp(difficulty, 1, #self.NUM_ASSIGNMENT_UNITS)
	end

	local level_id = managers.job:current_level_id()
	local job_id = managers.job:current_job_id()
	local level_data = tweak_data.levels[level_id]
	local job_data = tweak_data.narrative.jobs[job_id]

	if level_data and level_data.NUM_ASSIGNMENT_UNITS then
		num_assignment_units = level_data.NUM_ASSIGNMENT_UNITS
	elseif job_data and job_data.NUM_ASSIGNMENT_UNITS then
		num_assignment_units = job_data.NUM_ASSIGNMENT_UNITS
	end

	return num_assignment_units[difficulty] or 1
end
