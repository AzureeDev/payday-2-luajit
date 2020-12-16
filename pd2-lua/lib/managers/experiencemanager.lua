ExperienceManager = ExperienceManager or class()
ExperienceManager.LEVEL_CAP = Application:digest_value(100, true)

function ExperienceManager:init()
	self:_setup()
end

function ExperienceManager:_setup()
	self._total_levels = #tweak_data.experience_manager.levels

	if not Global.experience_manager then
		Global.experience_manager = {
			total = Application:digest_value(0, true),
			level = Application:digest_value(0, true)
		}
	end

	self._global = Global.experience_manager

	if not self._global.next_level_data then
		self:_set_next_level_data(1)
	end

	self._cash_tousand_separator = managers.localization:text("cash_tousand_separator")
	self._cash_sign = managers.localization:text("cash_sign")

	self:present()
end

function ExperienceManager:_set_next_level_data(level)
	if self._total_levels < level then
		print("Reached the level cap")

		if self._experience_progress_data then
			table.insert(self._experience_progress_data, {
				level = self._total_levels,
				current = tweak_data:get_value("experience_manager", "levels", self._total_levels, "points"),
				total = tweak_data:get_value("experience_manager", "levels", self._total_levels, "points")
			})
		end

		return
	end

	local level_data = tweak_data.experience_manager.levels[level]
	self._global.next_level_data = {}

	self:_set_next_level_data_points(level_data.points)
	self:_set_next_level_data_current_points(0)

	if self._experience_progress_data then
		table.insert(self._experience_progress_data, {
			current = 0,
			level = level,
			total = tweak_data:get_value("experience_manager", "levels", level, "points")
		})
	end
end

function ExperienceManager:next_level_data_points()
	return self._global.next_level_data and Application:digest_value(self._global.next_level_data.points, false) or 0
end

function ExperienceManager:_set_next_level_data_points(value)
	self._global.next_level_data.points = value
end

function ExperienceManager:next_level_data_current_points()
	return self._global.next_level_data and Application:digest_value(self._global.next_level_data.current_points, false) or 0
end

function ExperienceManager:_set_next_level_data_current_points(value)
	self._global.next_level_data.current_points = Application:digest_value(value, true)
end

function ExperienceManager:next_level_data()
	return {
		points = self:next_level_data_points(),
		current_points = self:next_level_data_current_points()
	}
end

function ExperienceManager:perform_action_interact(name)
end

function ExperienceManager:perform_action(action)
	if managers.platform:presence() ~= "Playing" and managers.platform:presence() ~= "Mission_end" then
		return
	end

	if not tweak_data.experience_manager.actions[action] then
		Application:error("Unknown action \"" .. tostring(action) .. " in experience manager.")

		return
	end

	local size = tweak_data.experience_manager.actions[action]
	local points = tweak_data.experience_manager.values[size]

	if not points then
		Application:error("Unknown size \"" .. tostring(size) .. " in experience manager.")

		return
	end

	managers.statistics:recieved_experience({
		action = action,
		size = size
	})
	self:add_points(points, true)
end

function ExperienceManager:debug_add_points(points, present_xp)
	self:add_points(points, present_xp, true)
end

function ExperienceManager:give_experience(xp, force_or_debug)
	self._experience_progress_data = {
		gained = xp,
		start_t = {}
	}
	self._experience_progress_data.start_t.level = self:current_level()
	self._experience_progress_data.start_t.current = self._global.next_level_data and self:next_level_data_current_points() or 0
	self._experience_progress_data.start_t.total = self._global.next_level_data and self:next_level_data_points() or 1
	self._experience_progress_data.start_t.xp = self:xp_gained()

	table.insert(self._experience_progress_data, {
		level = self:current_level() + 1,
		current = self:next_level_data_current_points(),
		total = self:next_level_data_points()
	})

	local level_cap_xp_leftover = self:add_points(xp, true, force_or_debug or false)

	if level_cap_xp_leftover then
		self._experience_progress_data.gained = self._experience_progress_data.gained - level_cap_xp_leftover
	end

	self._experience_progress_data.end_t = {
		level = self:current_level(),
		current = self._global.next_level_data and self:next_level_data_current_points() or 0,
		total = self._global.next_level_data and self:next_level_data_points() or 1,
		xp = self:xp_gained()
	}

	table.remove(self._experience_progress_data, #self._experience_progress_data)

	local return_data = deep_clone(self._experience_progress_data)
	self._experience_progress_data = nil

	managers.skilltree:give_specialization_points(xp)
	managers.custom_safehouse:give_upgrade_points(xp)

	return return_data
end

function ExperienceManager:mission_xp()
	local total_xp = self._global.mission_xp_total and Application:digest_value(self._global.mission_xp_total, false) or 0
	local current_xp = self._global.mission_xp_current and Application:digest_value(self._global.mission_xp_current, false) or 0

	return total_xp + current_xp
end

function ExperienceManager:mission_xp_process(stage_success, stage_final)
	if not stage_success then
		self._global.mission_xp_current = nil

		return
	end

	self._global.mission_xp_total = nil
	self._global.mission_xp_current = nil
end

function ExperienceManager:mission_xp_award(amount)
	if amount > 0 then
		local current_xp = self._global.mission_xp_current and Application:digest_value(self._global.mission_xp_current, false) or 0
		self._global.mission_xp_current = Application:digest_value(current_xp + amount, true)
	end
end

function ExperienceManager:mission_xp_clear()
	self._global.mission_xp_total = nil
	self._global.mission_xp_current = nil
end

function ExperienceManager:on_loot_drop_xp(value_id, force)
	local amount = tweak_data:get_value("experience_manager", "loot_drop_value", value_id) or 0

	if force then
		self:give_experience(amount, force)
	else
		self:add_points(amount, false)
	end
end

function ExperienceManager:add_points(points, present_xp, debug)
	if not debug and managers.platform:presence() ~= "Playing" and managers.platform:presence() ~= "Mission_end" then
		return
	end

	if points <= 0 then
		return
	end

	if not managers.dlc:has_full_game() and self:current_level() >= 10 then
		self:_set_total(self:total() + points)
		self:_set_next_level_data_current_points(0)
		self:present()
		managers.statistics:aquired_money(points)

		return points
	end

	if self:level_cap() <= self:current_level() then
		self:_set_total(self:total() + points)
		managers.statistics:aquired_money(points)

		return points
	end

	if present_xp then
		self:_present_xp(points)
	end

	local points_left = self:next_level_data_points() - self:next_level_data_current_points()

	if points < points_left then
		self:_set_total(self:total() + points)
		self:_set_xp_gained(self:total())
		self:_set_next_level_data_current_points(self:next_level_data_current_points() + points)
		self:present()
		managers.statistics:aquired_money(points)

		return
	end

	self:_set_total(self:total() + points_left)
	self:_set_xp_gained(self:total())
	self:_set_next_level_data_current_points(self:next_level_data_current_points() + points_left)
	self:present()
	self:_level_up()
	managers.statistics:aquired_money(points_left)

	return self:add_points(points - points_left, present_xp, debug)
end

function ExperienceManager:_level_up()
	self:_set_current_level(self:current_level() + 1)
	self:_set_next_level_data(self:current_level() + 1)

	local player = managers.player:player_unit()

	if alive(player) and tweak_data:difficulty_to_index(Global.game_settings.difficulty) < 4 then
		player:base():replenish()
	end

	self:_check_achievements()

	if managers.network:session() then
		managers.network:session():send_to_peers_synched("sync_level_up", self:current_level())
	end

	managers.upgrades:level_up()
	managers.skilltree:level_up()
	managers.mission:call_global_event(Message.OnLevelUp)
end

function ExperienceManager:_check_achievements()
	local level = self:current_level()

	for _, d in pairs(tweak_data.achievement.level_achievements) do
		if d.level and d.level <= level then
			managers.achievment:award_data(d)
		end
	end

	if self._global.rank then
		for i = 1, Application:digest_value(self._global.rank, false) do
			if tweak_data.achievement.infamous[i] then
				managers.achievment:award(tweak_data.achievement.infamous[i])
			end
		end
	end
end

function ExperienceManager:present()
end

function ExperienceManager:_present_xp(amount)
	local event = "money_collect_small"

	if amount > 999 then
		event = "money_collect_large"
	elseif amount > 101 then
		event = "money_collect_medium"
	end
end

function ExperienceManager:current_level()
	return self._global.level and Application:digest_value(self._global.level, false) or 0
end

function ExperienceManager:current_rank()
	return self._global.rank and Application:digest_value(self._global.rank, false) or 0
end

function ExperienceManager:_set_current_level(value)
	value = math.max(value, 0)
	self._global.level = Application:digest_value(value, true)

	self:update_progress()
end

function ExperienceManager:set_current_rank(value)
	local max_rank = tweak_data.infamy.ranks

	if value <= max_rank then
		managers.infamy:aquire_point()

		self._global.rank = Application:digest_value(value, true)

		self:_check_achievements()
		self:update_progress()
	end
end

function ExperienceManager:rank_string(rank, use_roman_numerals)
	if use_roman_numerals == nil then
		use_roman_numerals = managers.user:get_setting("infamy_roman_rank")
	end

	if not use_roman_numerals then
		return tostring(rank)
	end

	local numbers = {
		1,
		4,
		5,
		9,
		10,
		40,
		50,
		90,
		100,
		400,
		500,
		900,
		1000
	}
	local chars = {
		"I",
		"IV",
		"V",
		"IX",
		"X",
		"XL",
		"L",
		"XC",
		"C",
		"CD",
		"D",
		"CM",
		"M"
	}
	local roman = ""
	local index = #chars

	while rank > 0 do
		local div = rank / numbers[index]
		rank = rank % numbers[index]

		for i = 1, div do
			roman = roman .. chars[index]
		end

		index = index - 1
	end

	return roman
end

function ExperienceManager:rank_icon(rank)
	if rank and rank > 0 then
		local index = math.floor((rank - 1) / tweak_data.infamy.icon_rank_step) + 1

		return (tweak_data.infamy.infamy_icons[index] or tweak_data.infamy.infamy_icons[1]).hud_icon
	end
end

function ExperienceManager:rank_icon_color(rank)
	if rank and rank > 0 then
		local index = math.floor((rank - 1) / tweak_data.infamy.icon_rank_step) + 1

		return (tweak_data.infamy.infamy_icons[index] or tweak_data.infamy.infamy_icons[1]).color
	end
end

function ExperienceManager:gui_string(level, rank, offset)
	offset = offset or 0
	local rank_string = rank > 0 and "[" .. self:rank_string(rank) .. "]" or ""
	local gui_string = tostring(level) .. rank_string
	local rank_color_range = {
		start = utf8.len(gui_string) - utf8.len(rank_string) + offset,
		stop = utf8.len(gui_string) + offset,
		color = tweak_data.screen_colors.infamy_color
	}

	return gui_string, {
		rank_color_range
	}
end

function ExperienceManager:rank_icon_data(rank)
	return tweak_data.hud_icons:get_icon_or(self:rank_icon(rank), "guis/textures/pd2/infamous_symbol", {
		32,
		4,
		16,
		16
	})
end

function ExperienceManager:level_to_stars()
	local plvl = managers.experience:current_level()
	local player_stars = math.clamp(math.ceil((plvl + 1) / 10), 1, 10)

	return player_stars
end

function ExperienceManager:xp_gained()
	return self._global.xp_gained and Application:digest_value(self._global.xp_gained, false) or 0
end

function ExperienceManager:_set_xp_gained(value)
	self._global.xp_gained = Application:digest_value(value, true)
end

function ExperienceManager:total()
	return Application:digest_value(self._global.total, false)
end

function ExperienceManager:_set_total(value)
	self._global.total = Application:digest_value(value, true)
end

function ExperienceManager:cash_string(cash, cash_sign)
	local sign = ""

	if cash < 0 then
		sign = "-"
	end

	local total = tostring(math.round(math.abs(cash)))
	local reverse = string.reverse(total)
	local s = ""

	for i = 1, string.len(reverse) do
		s = s .. string.sub(reverse, i, i) .. (math.mod(i, 3) == 0 and i ~= string.len(reverse) and self._cash_tousand_separator or "")
	end

	local final_cash_sign = type(cash_sign) == "string" and (cash_sign or self._cash_sign) or self._cash_sign

	return sign .. final_cash_sign .. string.reverse(s)
end

function ExperienceManager:experience_string(xp)
	local total = tostring(math.round(math.abs(xp)))
	local reverse = string.reverse(total)
	local s = ""

	for i = 1, string.len(reverse) do
		s = s .. string.sub(reverse, i, i) .. (math.mod(i, 3) == 0 and i ~= string.len(reverse) and self._cash_tousand_separator or "")
	end

	return string.reverse(s)
end

function ExperienceManager:total_cash_string()
	return self:cash_string(self:total()) .. (self:total() > 0 and self._cash_tousand_separator .. "000" or "")
end

function ExperienceManager:actions()
	local t = {}

	for action, _ in pairs(tweak_data.experience_manager.actions) do
		table.insert(t, action)
	end

	table.sort(t)

	return t
end

function ExperienceManager:get_job_xp_by_stars(stars)
	local amount = tweak_data:get_value("experience_manager", "job_completion", stars)

	return amount or 0
end

function ExperienceManager:get_stage_xp_by_stars(stars)
	local amount = tweak_data:get_value("experience_manager", "stage_completion", stars)

	return amount or 0
end

function ExperienceManager:get_contract_difficulty_multiplier(stars)
	local multiplier = tweak_data:get_value("experience_manager", "difficulty_multiplier", stars)

	return multiplier or 0
end

function ExperienceManager:get_current_stage_xp_by_stars(stars, diff_stars)
	local amount = self:get_stage_xp_by_stars(stars) + self:get_stage_xp_by_stars(stars) * self:get_contract_difficulty_multiplier(diff_stars)

	return amount or 0
end

function ExperienceManager:get_current_job_xp_by_stars(stars, diff_stars)
	local amount = self:get_job_xp_by_stars(stars) + self:get_job_xp_by_stars(stars) * self:get_contract_difficulty_multiplier(diff_stars)

	return amount or 0
end

function ExperienceManager:get_current_job_day_multiplier()
	if not managers.job:has_active_job() then
		return 1
	end

	local current_job_day = managers.job:current_stage()
	local is_current_job_professional = managers.job:is_current_job_professional()

	return is_current_job_professional and tweak_data:get_value("experience_manager", "pro_day_multiplier", current_job_day) or tweak_data:get_value("experience_manager", "day_multiplier", current_job_day)
end

function ExperienceManager:get_levels_gained_from_xp(xp)
	local next_level_data = self:next_level_data()
	local xp_needed_to_level = math.max(1, next_level_data.points - next_level_data.current_points)
	local level_gained = math.min(xp / xp_needed_to_level, 1)
	xp = math.max(xp - xp_needed_to_level, 0)
	local plvl = managers.experience:current_level() + 1
	local level_data = nil

	while xp > 0 and plvl < self._total_levels do
		plvl = plvl + 1
		xp_needed_to_level = tweak_data:get_value("experience_manager", "levels", plvl, "points")
		level_gained = level_gained + math.min(xp / xp_needed_to_level, 1)
		xp = math.max(xp - xp_needed_to_level, 0)
	end

	return level_gained
end

function ExperienceManager:get_on_completion_xp()
	local has_active_job = managers.job:has_active_job()
	local job_and_difficulty_stars = has_active_job and managers.job:current_job_and_difficulty_stars() or 1
	local job_stars = has_active_job and managers.job:current_job_stars() or 1
	local difficulty_stars = has_active_job and managers.job:current_difficulty_stars() or 0
	local on_last_stage = managers.job:on_last_stage()
	local amount = self:get_current_stage_xp_by_stars(job_stars, difficulty_stars)

	if on_last_stage then
		amount = amount + self:get_current_job_xp_by_stars(job_stars, difficulty_stars)
	end

	return amount
end

function ExperienceManager:get_contract_xp_by_stars(job_id, job_stars, risk_stars, professional, job_days, extra_params)
	local debug_player_level = extra_params and extra_params.debug_player_level
	local ignore_heat = extra_params and extra_params.ignore_heat
	local mission_xp = extra_params and extra_params.mission_xp
	local debug_print = extra_params and extra_params.debug_print
	local job_and_difficulty_stars = job_stars + risk_stars
	local job_stars = job_stars
	local difficulty_stars = risk_stars
	local player_stars = debug_player_level and math.max(math.ceil(debug_player_level / 10), 1) or managers.experience:level_to_stars()
	local job_tweak_chains = tweak_data.narrative:job_chain(job_id)
	local params = {
		job_id = job_id,
		job_stars = job_stars,
		difficulty_stars = difficulty_stars,
		current_stage = job_days,
		professional = professional,
		success = true,
		num_winners = 1,
		on_last_stage = true,
		player_stars = player_stars,
		personal_win = true,
		ignore_heat = ignore_heat,
		mission_xp = mission_xp
	}
	local total_base_xp = 0
	local total_risk_xp = 0
	local total_heat_base_xp = 0
	local total_heat_risk_xp = 0
	local total_ghost_base_xp = 0
	local total_ghost_risk_xp = 0
	local total_skill_base_xp = 0
	local total_skill_risk_xp = 0
	local total_infamy_base_xp = 0
	local total_infamy_risk_xp = 0
	local total_extra_base_xp = 0
	local total_extra_risk_xp = 0
	local total_xp = 0

	local function make_fine_number(v)
		return math.round(v)
	end

	local risk_ratio, base_exp, risk_exp, skill_base, skill_risk, heat_base, heat_risk, ghost_base, ghost_risk, infamy_base, infamy_risk, extra_base, extra_risk = nil

	for i = 1, job_days do
		params.current_stage = i
		params.on_last_stage = i == job_days
		params.level_id = job_tweak_chains and job_tweak_chains[i] and job_tweak_chains[i].level_id
		local total_xp, dissection_table = self:get_xp_by_params(params)

		if debug_print then
			print("Total XP", total_xp, inspect(dissection_table))
		end

		base_exp = dissection_table.base
		risk_exp = dissection_table.bonus_risk
		total_base_xp = total_base_xp + base_exp
		total_risk_xp = total_risk_xp + risk_exp
		risk_ratio = risk_exp / math.max(base_exp + risk_exp, 1)
		heat_risk = make_fine_number(dissection_table.heat_xp * risk_ratio)
		heat_base = dissection_table.heat_xp - heat_risk
		ghost_risk = make_fine_number(dissection_table.bonus_ghost * risk_ratio)
		ghost_base = dissection_table.bonus_ghost - ghost_risk
		skill_risk = make_fine_number(dissection_table.bonus_skill * risk_ratio)
		skill_base = dissection_table.bonus_skill - skill_risk
		infamy_risk = make_fine_number(dissection_table.bonus_infamy * risk_ratio)
		infamy_base = dissection_table.bonus_infamy - infamy_risk
		extra_risk = make_fine_number(dissection_table.bonus_extra * risk_ratio)
		extra_base = dissection_table.bonus_extra - extra_risk
		total_heat_base_xp = total_heat_base_xp + heat_base
		total_heat_risk_xp = total_heat_risk_xp + heat_risk
		total_ghost_base_xp = total_ghost_base_xp + ghost_base
		total_ghost_risk_xp = total_ghost_risk_xp + ghost_risk
		total_skill_base_xp = total_skill_base_xp + skill_base
		total_skill_risk_xp = total_skill_risk_xp + skill_risk
		total_infamy_base_xp = total_infamy_base_xp + infamy_base
		total_infamy_risk_xp = total_infamy_risk_xp + infamy_risk
		total_extra_base_xp = total_extra_base_xp + extra_base
		total_extra_risk_xp = total_extra_risk_xp + extra_risk
		total_base_xp = total_base_xp + skill_base + infamy_base + extra_base
		total_risk_xp = total_risk_xp + skill_risk + infamy_risk + extra_risk
	end

	local dissected_xp = {
		total_base_xp,
		total_risk_xp,
		total_heat_base_xp,
		total_heat_risk_xp,
		total_ghost_base_xp,
		total_ghost_risk_xp
	}

	for i, xp in ipairs(dissected_xp) do
		total_xp = total_xp + xp
	end

	return total_xp, dissected_xp
end

function ExperienceManager:get_xp_by_params(params)
	local job_id = params.job_id
	local job_stars = params.job_stars or 0
	local difficulty_stars = params.difficulty_stars or params.risk_stars or 0
	local job_and_difficulty_stars = job_stars + difficulty_stars
	local job_data = tweak_data.narrative:job_data(job_id)
	local job_mul = job_data and job_data.experience_mul and job_data.experience_mul[difficulty_stars + 1] or 1
	local success = params.success
	local num_winners = params.num_winners or 1
	local on_last_stage = params.on_last_stage
	local personal_win = params.personal_win
	local player_stars = params.player_stars or managers.experience:level_to_stars() or 0
	local level_id = params.level_id or false
	local ignore_heat = params.ignore_heat
	local current_job_stage = params.current_stage or 1
	local days_multiplier = params.professional and tweak_data:get_value("experience_manager", "pro_day_multiplier", current_job_stage) or tweak_data:get_value("experience_manager", "day_multiplier", current_job_stage)
	local pro_job_multiplier = params.professional and tweak_data:get_value("experience_manager", "pro_job_multiplier") or 1
	local ghost_multiplier = 1 + (managers.job:get_ghost_bonus() or 0)
	local total_stars = math.min(job_stars, player_stars)
	local total_difficulty_stars = difficulty_stars
	local xp_multiplier = managers.experience:get_contract_difficulty_multiplier(total_difficulty_stars)
	local contract_xp = 0
	local total_xp = 0
	local stage_xp_dissect = 0
	local job_xp_dissect = 0
	local level_limit_dissect = 0
	local risk_dissect = 0
	local failed_level_dissect = 0
	local personal_win_dissect = 0
	local alive_crew_dissect = 0
	local skill_dissect = 0
	local base_xp = 0
	local days_dissect = 0
	local job_heat_dissect = 0
	local base_heat_dissect = 0
	local risk_heat_dissect = 0
	local ghost_dissect = 0
	local ghost_base_dissect = 0
	local ghost_risk_dissect = 0
	local infamy_dissect = 0
	local extra_bonus_dissect = 0
	local gage_assignment_dissect = 0
	local mission_xp_dissect = 0
	local pro_job_xp_dissect = 0
	local bonus_xp = 0
	local bonus_mutators_dissect = 0

	if success and on_last_stage then
		job_xp_dissect = managers.experience:get_job_xp_by_stars(total_stars) * job_mul
		level_limit_dissect = level_limit_dissect + managers.experience:get_job_xp_by_stars(job_stars) * job_mul
	end

	local static_stage_experience = level_id and tweak_data.levels[level_id].static_experience
	static_stage_experience = static_stage_experience and static_stage_experience[difficulty_stars + 1]
	stage_xp_dissect = static_stage_experience or managers.experience:get_stage_xp_by_stars(total_stars)
	level_limit_dissect = level_limit_dissect + (static_stage_experience or managers.experience:get_stage_xp_by_stars(job_stars))

	if success then
		mission_xp_dissect = params.mission_xp or self:mission_xp()
	end

	base_xp = job_xp_dissect + stage_xp_dissect + mission_xp_dissect
	pro_job_xp_dissect = math.round(base_xp * pro_job_multiplier - base_xp)
	base_xp = base_xp + pro_job_xp_dissect
	days_dissect = math.round(base_xp * days_multiplier - base_xp)
	local is_level_limited = player_stars < job_stars

	if is_level_limited then
		local diff_in_stars = job_stars - player_stars
		local tweak_multiplier = tweak_data:get_value("experience_manager", "level_limit", "pc_difference_multipliers", diff_in_stars) or 0
		local old_base_xp = base_xp
		base_xp = math.round(base_xp * tweak_multiplier)
		level_limit_dissect = base_xp - old_base_xp
	end

	contract_xp = base_xp
	risk_dissect = math.round(contract_xp * xp_multiplier)
	contract_xp = contract_xp + risk_dissect

	if not success then
		local multiplier = tweak_data:get_value("experience_manager", "stage_failed_multiplier") or 1
		failed_level_dissect = math.round(contract_xp * multiplier - contract_xp)
		contract_xp = contract_xp + failed_level_dissect
	elseif not personal_win then
		local multiplier = tweak_data:get_value("experience_manager", "in_custody_multiplier") or 1
		personal_win_dissect = math.round(contract_xp * multiplier - contract_xp)
		contract_xp = contract_xp + personal_win_dissect
	end

	total_xp = contract_xp
	local total_contract_xp = total_xp
	bonus_xp = managers.player:get_skill_exp_multiplier(managers.groupai and managers.groupai:state():whisper_mode())
	skill_dissect = math.round(total_contract_xp * bonus_xp - total_contract_xp)
	total_xp = total_xp + skill_dissect
	bonus_xp = managers.player:get_infamy_exp_multiplier()
	infamy_dissect = math.round(total_contract_xp * bonus_xp - total_contract_xp)
	total_xp = total_xp + infamy_dissect

	if success then
		local num_players_bonus = num_winners and tweak_data:get_value("experience_manager", "alive_humans_multiplier", num_winners) or 1
		alive_crew_dissect = math.round(total_contract_xp * num_players_bonus - total_contract_xp)
		total_xp = total_xp + alive_crew_dissect
	end

	bonus_xp = managers.gage_assignment:get_current_experience_multiplier()
	gage_assignment_dissect = math.round(total_contract_xp * bonus_xp - total_contract_xp)
	total_xp = total_xp + gage_assignment_dissect
	ghost_dissect = math.round(total_xp * ghost_multiplier - total_xp)
	total_xp = total_xp + ghost_dissect
	local heat_xp_mul = ignore_heat and 1 or math.max(managers.job:get_job_heat_multipliers(job_id), 0)
	job_heat_dissect = math.round(total_xp * heat_xp_mul - total_xp)
	total_xp = total_xp + job_heat_dissect
	bonus_xp = managers.player:get_limited_exp_multiplier(job_id, level_id)
	extra_bonus_dissect = math.round(total_xp * bonus_xp - total_xp)
	total_xp = total_xp + extra_bonus_dissect
	local bonus_mutators_dissect = total_xp * managers.mutators:get_experience_reduction() * -1
	total_xp = total_xp + bonus_mutators_dissect
	local dissection_table = {
		bonus_risk = math.round(risk_dissect),
		bonus_num_players = math.round(alive_crew_dissect),
		bonus_failed = math.round(failed_level_dissect),
		bonus_low_level = math.round(level_limit_dissect),
		bonus_skill = math.round(skill_dissect),
		bonus_days = math.round(days_dissect),
		bonus_pro_job = math.round(pro_job_xp_dissect),
		bonus_infamy = math.round(infamy_dissect),
		bonus_extra = math.round(extra_bonus_dissect),
		in_custody = math.round(personal_win_dissect),
		heat_xp = math.round(job_heat_dissect),
		bonus_ghost = math.round(ghost_dissect),
		bonus_gage_assignment = math.round(gage_assignment_dissect),
		bonus_mission_xp = math.round(mission_xp_dissect),
		bonus_mutators = math.round(bonus_mutators_dissect),
		stage_xp = math.round(stage_xp_dissect),
		job_xp = math.round(job_xp_dissect),
		base = math.round(base_xp),
		total = math.round(total_xp),
		last_stage = on_last_stage
	}

	if Application:production_build() then
		local rounding_error = dissection_table.total - (dissection_table.stage_xp + dissection_table.job_xp + dissection_table.bonus_risk + dissection_table.bonus_num_players + dissection_table.bonus_failed + dissection_table.bonus_skill + dissection_table.bonus_days + dissection_table.heat_xp + dissection_table.bonus_infamy + dissection_table.bonus_ghost + dissection_table.bonus_gage_assignment + dissection_table.bonus_mission_xp + dissection_table.bonus_low_level)
		dissection_table.rounding_error = rounding_error
	else
		dissection_table.rounding_error = 0
	end

	return math.round(total_xp), dissection_table
end

function ExperienceManager:get_xp_dissected(success, num_winners, personal_win)
	local has_active_job = managers.job:has_active_job()
	local job_and_difficulty_stars = has_active_job and managers.job:current_job_and_difficulty_stars() or 1
	local job_id = has_active_job and managers.job:current_job_id()
	local job_stars = has_active_job and managers.job:current_job_stars() or 1
	local difficulty_stars = has_active_job and managers.job:current_difficulty_stars() or 0
	local current_stage = has_active_job and managers.job:current_stage() or 1
	local is_professional = has_active_job and managers.job:is_current_job_professional() or false
	local current_level_id = has_active_job and managers.job:current_level_id() or false
	local personal_win = personal_win or false
	local on_last_stage = has_active_job and managers.job:on_last_stage()

	return self:get_xp_by_params({
		job_id = job_id,
		job_stars = job_stars,
		difficulty_stars = difficulty_stars,
		current_stage = current_stage,
		professional = is_professional,
		success = success,
		num_winners = num_winners,
		on_last_stage = on_last_stage,
		level_id = current_level_id,
		personal_win = personal_win
	})
end

function ExperienceManager:level_cap()
	return Application:digest_value(self.LEVEL_CAP, false)
end

function ExperienceManager:reached_level_cap()
	return self:level_cap() <= self:current_level()
end

function ExperienceManager:save(data)
	local state = {
		total = self._global.total,
		xp_gained = self._global.xp_gained,
		next_level_data = self._global.next_level_data,
		level = self._global.level,
		rank = self._global.rank
	}
	data.ExperienceManager = state
end

function ExperienceManager:load(data)
	local state = data.ExperienceManager

	if state then
		self._global.total = state.total
		self._global.xp_gained = state.xp_gained or state.total
		self._global.next_level_data = state.next_level_data
		self._global.level = state.level or Application:digest_value(0, true)
		self._global.rank = state.rank or Application:digest_value(0, true)

		self:_set_current_level(math.min(self:current_level(), self:level_cap()))

		for level = 0, self:current_level() do
			managers.upgrades:aquire_from_level_tree(level, true)
		end

		if not self._global.next_level_data or not tweak_data.experience_manager.levels[self:current_level() + 1] or self:next_level_data_points() ~= tweak_data:get_value("experience_manager", "levels", self:current_level() + 1, "points") then
			self:_set_next_level_data(self:current_level() + 1)
		end
	end

	managers.network.account:experience_loaded()
	self:_check_achievements()
end

function ExperienceManager:reset()
	managers.upgrades:reset()
	managers.player:reset()

	Global.experience_manager = nil

	self:_setup()
	self:update_progress()

	for level = 0, self:current_level() do
		managers.upgrades:aquire_from_level_tree(level, true)
	end
end

function ExperienceManager:update_progress()
	if self:current_rank() > 0 then
		managers.platform:set_progress(1)
	else
		managers.platform:set_progress(math.clamp(self:current_level() / self:level_cap(), 0, 1))
	end
end

function ExperienceManager:chk_ask_use_backup(savegame_data, backup_savegame_data)
	local savegame_exp_total, backup_savegame_exp_total, savegame_rank, backup_savegame_rank = nil
	local state = savegame_data.ExperienceManager

	if state then
		savegame_exp_total = state.total
		savegame_rank = state.rank
	end

	state = backup_savegame_data.ExperienceManager

	if state then
		backup_savegame_exp_total = state.total
		backup_savegame_rank = state.rank
	end

	local rank = savegame_rank and Application:digest_value(savegame_rank, false) or 0
	local backup_rank = backup_savegame_rank and Application:digest_value(backup_savegame_rank, false) or 0

	if rank < backup_rank then
		return true
	elseif backup_rank < rank then
		return false
	end

	if savegame_exp_total and backup_savegame_exp_total and Application:digest_value(savegame_exp_total, false) < Application:digest_value(backup_savegame_exp_total, false) then
		return true
	end
end
