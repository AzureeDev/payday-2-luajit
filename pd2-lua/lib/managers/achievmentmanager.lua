AchievmentManager = AchievmentManager or class()
AchievmentManager.PATH = "gamedata/achievments"
AchievmentManager.FILE_EXTENSION = "achievment"
AchievmentManager.MAX_TRACKED = 4

require("lib/managers/achievement/CAC_CustomAchievements")
require("lib/utils/accelbyte/TelemetryConst")

function AchievmentManager:init()
	self.exp_awards = {
		b = 1500,
		a = 500,
		c = 5000,
		none = 0
	}
	self.script_data = {}

	if SystemInfo:platform() == Idstring("WIN32") then
		if SystemInfo:distribution() == Idstring("STEAM") then
			AchievmentManager.do_award = AchievmentManager.award_steam

			if not Global.achievment_manager then
				self:_parse_achievments("Steam")

				self.handler = Steam:sa_handler()

				self.handler:initialized_callback(AchievmentManager.fetch_achievments)
				self.handler:init()

				Global.achievment_manager = {
					handler = self.handler,
					achievments = self.achievments
				}
			else
				self.handler = Global.achievment_manager.handler
				self.achievments = Global.achievment_manager.achievments
			end
		else
			AchievmentManager.do_award = AchievmentManager.award_none

			self:_parse_achievments()

			if not Global.achievment_manager then
				Global.achievment_manager = {
					achievments = self.achievments
				}
			end

			self.achievments = Global.achievment_manager.achievments
		end
	elseif SystemInfo:platform() == Idstring("PS3") then
		if not Global.achievment_manager then
			Global.achievment_manager = {
				trophy_requests = {}
			}
		end

		self:_parse_achievments("PSN")

		AchievmentManager.do_award = AchievmentManager.award_psn
	elseif SystemInfo:platform() == Idstring("PS4") then
		if not Global.achievment_manager then
			self:_parse_achievments("PS4")

			Global.achievment_manager = {
				trophy_requests = {},
				achievments = self.achievments
			}
		else
			self.achievments = Global.achievment_manager.achievments
		end

		AchievmentManager.do_award = AchievmentManager.award_psn
	elseif SystemInfo:platform() == Idstring("X360") then
		self:_parse_achievments("X360")

		AchievmentManager.do_award = AchievmentManager.award_x360
	elseif SystemInfo:platform() == Idstring("XB1") then
		if not Global.achievment_manager then
			self:_parse_achievments("XB1")

			Global.achievment_manager = {
				achievments = self.achievments
			}
		else
			self.achievments = Global.achievment_manager.achievments
		end

		AchievmentManager.do_award = AchievmentManager.award_x360
	else
		Application:error("[AchievmentManager:init] Unsupported platform")
	end

	self._forced = Global.achievment_manager.forced or {}
	Global.achievment_manager.forced = self._forced
	self._recent_data = Global.achievment_manager.recent_time or {
		time = os.time() - 1
	}
	Global.achievment_manager.recent_time = self._recent_data
	self._with_progress = {}
	self._recent_progress = {}

	for id, data in pairs(self.achievments) do
		local v = tweak_data.achievement.visual[id]

		if v and v.progress then
			self._with_progress[id] = {
				info = data,
				visual = v,
				id = id
			}
		end
	end

	self._milestones = Global.achievment_manager.milestones
	self._current_milestone = Global.achievment_manager.current_milestone

	if not self._milestones then
		self._milestones = deep_clone(tweak_data.achievement.milestones)
		Global.achievment_manager.milestones = self._milestones
		self._current_milestone = self._milestones[1]
	end

	self._mission_end_achievements = {}
end

function AchievmentManager:save(data)
	local save = {
		forced = table.list_copy(self._forced),
		tracked = {}
	}

	for k, v in pairs(self.achievments) do
		if v.tracked then
			table.insert(save.tracked, k)
		end
	end

	save.awarded_milestones = {}

	for _, v in pairs(self._milestones) do
		if v.awarded then
			save.awarded_milestones[v.id] = v.awarded
		end
	end

	data.achievement = save
end

function AchievmentManager:load(data, version)
	if not data.achievement then
		return
	end

	if self._forced then
		local cur = table.list_copy(self._forced)

		for _, v in pairs(cur) do
			self:force_track(v, false)
		end
	end

	for k, v in pairs(data.achievement.forced or {}) do
		self:force_track(v, true)
	end

	for _, k in pairs(data.achievement.tracked or {}) do
		local v = self.achievments[k]

		if v then
			v.tracked = true
		end
	end

	for id, awarded in pairs(data.achievement.awarded_milestones or {}) do
		local m = self:get_milestone(id)

		if m then
			m.awarded = awarded
		end
	end

	self:_update_current_milestone()
end

function AchievmentManager:init_finalize()
	managers.savefile:add_load_sequence_done_callback_handler(callback(self, self, "_load_done"))
	self:init_cac_custom_achievements()
end

function AchievmentManager:fetch_trophies()
	if SystemInfo:platform() == Idstring("PS3") or SystemInfo:platform() == Idstring("PS4") then
		Trophies:get_unlockstate(AchievmentManager.unlockstate_result)
	end
end

function AchievmentManager.unlockstate_result(error_str, table)
	if table then
		for i, data in ipairs(table) do
			local psn_id = data.index
			local unlocked = data.unlocked

			if unlocked then
				for id, ach in pairs(managers.achievment.achievments) do
					if ach.id == psn_id then
						ach.awarded = true
					end
				end
			end
		end
	end

	managers.network.account:achievements_fetched()
end

function AchievmentManager.fetch_achievments(error_str)
	print("[AchievmentManager.fetch_achievments]", error_str)

	if error_str == "success" then
		for id, ach in pairs(managers.achievment.achievments) do
			if managers.achievment.handler:has_achievement(ach.id) then
				ach.awarded = true

				managers.achievment:track(id, false)

				ach.unlock_time = managers.achievment.handler:achievement_unlock_time(ach.id)
			end
		end
	end

	managers.network.account:achievements_fetched()
end

function AchievmentManager:_load_done()
	if SystemInfo:platform() == Idstring("XB1") then
		print("[AchievmentManager] _load_done()")

		self._is_fetching_achievments = XboxLive:achievements(0, 1000, true, callback(self, self, "_achievments_loaded"))
	end
end

function AchievmentManager:_achievments_loaded(achievment_list)
	print("[AchievmentManager] Achievment loaded: " .. tostring(achievment_list and #achievment_list))

	if not self._is_fetching_achievments then
		print("[AchievmentManager] Achievment loading aborted.")

		return
	end

	for _, achievment in ipairs(achievment_list) do
		if achievment.type == "achieved" then
			for _, achievment2 in pairs(managers.achievment.achievments) do
				if achievment.id == tostring(achievment2.id) then
					print("[AchievmentManager] Awarded by load: " .. tostring(achievment.id))

					achievment2.awarded = true

					break
				end
			end
		end
	end
end

function AchievmentManager:on_user_signout()
	if SystemInfo:platform() == Idstring("XB1") then
		print("[AchievmentManager] on_user_signout()")

		self._is_fetching_achievments = nil

		for id, ach in pairs(managers.achievment.achievments) do
			ach.awarded = false
		end
	end
end

function AchievmentManager:_parse_achievments(platform)
	local list = PackageManager:script_data(self.FILE_EXTENSION:id(), self.PATH:id())
	self.achievments = {}

	for _, ach in ipairs(list) do
		if ach._meta == "achievment" then
			for _, reward in ipairs(ach) do
				if reward._meta == "reward" and (Application:editor() or not platform or platform == reward.platform) then
					local data = {
						awarded = false,
						tracked = false,
						id = reward.id,
						name = ach.name,
						exp = self.exp_awards[ach.awards_exp],
						dlc_loot = reward.dlc_loot or false
					}
					self.achievments[ach.id] = data
				end
			end
		end
	end
end

function AchievmentManager:get_script_data(id)
	return self.script_data[id]
end

function AchievmentManager:set_script_data(id, data)
	self.script_data[id] = data
end

function AchievmentManager:exists(id)
	return self.achievments[id] ~= nil
end

function AchievmentManager:get_info(id)
	return self.achievments[id]
end

function AchievmentManager:total_amount()
	return table.size(self.achievments)
end

function AchievmentManager:total_unlocked()
	local i = 0

	for _, ach in pairs(self.achievments) do
		if ach.awarded then
			i = i + 1
		end
	end

	return i
end

function AchievmentManager:add_heist_success_award(id)
	self._mission_end_achievements[id] = {
		award = true
	}
end

function AchievmentManager:add_heist_success_award_progress(id)
	local new_progress = (managers.job:get_memory(id, true) or 0) + 1

	managers.job:set_memory(id, new_progress, true)

	self._mission_end_achievements[id] = {
		stat = true,
		progress = new_progress
	}
end

function AchievmentManager:clear_heist_success_awards()
	self._mission_end_achievements = {}
end

function AchievmentManager:heist_success_awards()
	return self._mission_end_achievements
end

function AchievmentManager:get_milestone(id)
	for _, d in ipairs(self._milestones) do
		if d.id == id then
			return d
		end
	end
end

function AchievmentManager:milestones()
	return self._milestones
end

function AchievmentManager:current_milestone()
	return self._current_milestone
end

function AchievmentManager:get_recent_milestones(dont_update_shown)
	local rtn = {}

	for _, d in ipairs(self._milestones) do
		if d.awarded == 0 then
			table.insert(rtn, d)

			if not dont_update_shown then
				d.awarded = true
			end
		end
	end

	return rtn
end

function AchievmentManager:_update_current_milestone()
	local current_count = self:total_unlocked()
	local check_drops = false
	self._current_milestone = nil

	for _, milestone in ipairs(self._milestones) do
		if current_count < milestone.at then
			self._current_milestone = milestone

			break
		end

		if not milestone.awarded then
			milestone.awarded = 0

			if milestone.coins then
				managers.custom_safehouse:add_coins_ingore_locked(milestone.coins, TelemetryConst.economy_origin.milestone_award .. milestone.id)
			end

			if milestone.has_drop then
				check_drops = true
			end

			if managers.hud then
				managers.hud:achievement_milestone_popup(milestone.id)
			end
		end
	end

	if check_drops then
		managers.dlc:on_achievement_award_loot()
	end
end

function AchievmentManager:award_data(t, name)
	return self:_award_achievement(t, name)
end

function AchievmentManager:award(id)
	if not self:exists(id) then
		Application:error("[AchievmentManager:award] Awarding non-existing achievement", "id", id)

		return
	end

	managers.challenge:on_achievement_awarded(id)
	managers.custom_safehouse:on_achievement_awarded(id)
	managers.generic_side_jobs:award(id)

	if managers.mutators:are_achievements_disabled() then
		return
	end

	local info = self:get_info(id)

	if info.awarded then
		return
	end

	if managers.hud and not info.showed_awarded then
		managers.hud:achievement_popup(id)

		info.showed_awarded = true
	end

	if id == "christmas_present" then
		managers.network.account._masks.santa = true
	elseif id == "golden_boy" then
		managers.network.account._masks.gold = true
	end

	self:do_award(id)
	managers.mission:call_global_event(Message.OnAchievement, id)
end

function AchievmentManager:award_enemy_kill_achievement(id)
	for achievement_id, achievement_data in pairs(tweak_data.achievement.enemy_kill_achievements) do
		if achievement_id == id then
			managers.achievment:_award_achievement(achievement_data, achievement_id)

			break
		end
	end
end

function AchievmentManager:update()
	local cur = nil
	self._progress_iter, cur = next(self._with_progress, self._with_progress[self._progress_iter] and self._progress_iter)
	local i = 1

	while true do
		if not cur then
			break
		end

		if cur.info.awarded then
			self._with_progress[cur.id] = nil
		end

		if cur.info.tracked then
			i = i + 1
			local new = cur.visual.progress.get()
			cur.last = cur.last or new

			if cur.last ~= new then
				local old_idx = table.index_of(self._recent_progress, cur.id)

				if old_idx then
					table.remove(self._recent_progress, old_idx)
				end

				table.insert(self._recent_progress, 1, cur.id)

				self._recent_progress[self.MAX_TRACKED] = nil
				cur.last = new
			end

			if i > 10 then
				break
			end
		end

		self._progress_iter, cur = next(self._with_progress, self._progress_iter)
	end
end

function AchievmentManager:force_track(id, state)
	local data = self:get_info(id)

	if not data then
		Application:error("Failed to find achievement '" .. id .. "' to track!")

		return false
	end

	if state and not data.awarded then
		if self.MAX_TRACKED <= #self._forced then
			return data.forced
		end

		if not table.contains(self._forced, id) then
			table.insert(self._forced, id)
		end

		data.forced = true
		data.tracked = true
	else
		table.delete(self._forced, id)

		data.forced = false
	end

	return data.forced
end

function AchievmentManager:get_force_tracked()
	return self._forced
end

function AchievmentManager:get_tracked_fill(max)
	max = max or self.MAX_TRACKED

	if #self._forced == max then
		return self._forced
	end

	local list = table.list_copy(self._forced)
	local added_ids = {}

	for _, id in pairs(self._recent_progress) do
		table.insert(list, id)

		added_ids[id] = true

		if #list == max then
			return list
		end
	end

	for id, info in pairs(self.achievments) do
		if info.tracked and not added_ids[id] then
			table.insert(list, id)

			if #list == max then
				return list
			end
		end
	end

	return list
end

function AchievmentManager:track(id, state)
	local data = self:get_info(id)

	if not data then
		Application:error("Failed to find achievement '" .. id .. "' to track!")

		return false
	end

	if state and not data.awarded then
		data.tracked = true
	else
		data.tracked = false

		self:force_track(id, false)
	end

	return data.tracked
end

function AchievmentManager:get_friends_with_achievement(id, callback)
	return self.handler:friends_with_achievement(id, callback)
end

function AchievmentManager:get_global_achieved_percent(id)
	return self.handler:achievement_achieved_percent(id)
end

function AchievmentManager:set_recent_time(time)
	time = time or os.time()
	self._recent_data = self._recent_data or {}
	self._recent_data.time = time >= 0 and time or os.time() + time
end

function AchievmentManager:get_recent_achievements(params)
	params = params or {}
	local recent = params.from or self._recent_data.time
	local rtn = {}

	for _, v in pairs(self.achievments) do
		if v.unlock_time and recent <= v.unlock_time then
			table.insert(rtn, v)
		end
	end

	if (params.keep_recent_time or params.from) and not params.set_time then
		return rtn
	end

	self._recent_data.time = params.set_time or os.time()

	return rtn
end

function AchievmentManager:_give_reward(id, skip_exp)
	print("[AchievmentManager:_give_reward] ", id)

	local data = self:get_info(id)
	data.awarded = true
	self._with_progress[id] = nil

	self:track(id, false)

	data.unlock_time = self.handler:achievement_unlock_time(id)

	if data.dlc_loot then
		managers.dlc:on_achievement_award_loot()
	end

	self:_update_current_milestone()
end

function AchievmentManager:award_progress(stat, value)
	if Application:editor() then
		return
	end

	managers.challenge:on_achievement_progressed(stat)
	managers.custom_safehouse:on_achievement_progressed(stat, value)
	managers.generic_side_jobs:award(stat)

	if managers.mutators:are_mutators_active() and game_state_machine:current_state_name() ~= "menu_main" then
		return
	end

	print("[AchievmentManager:award_progress]: ", stat .. " increased by " .. tostring(value or 1))

	if SystemInfo:platform() == Idstring("WIN32") then
		self.handler:achievement_store_callback(AchievmentManager.steam_unlock_result)
	end

	local unlocks = tweak_data.achievement.persistent_stat_unlocks[stat] or {}
	local old_value = managers.network.account:get_stat(stat)
	local unlock_check = table.filter_list(unlocks, function (v)
		local info = self:get_info(v.award)

		if info and info.awarded then
			return false
		end

		return old_value <= v.at
	end)
	local stats = {
		[stat] = {
			type = "int",
			value = value or 1
		}
	}

	managers.network.account:publish_statistics(stats, true)

	local new_value = managers.network.account:get_stat(stat)

	for _, d in pairs(unlock_check) do
		if d.at <= new_value then
			self:award(d.award)
		end
	end
end

function AchievmentManager:get_stat(stat)
	if SystemInfo:platform() == Idstring("WIN32") then
		return managers.network.account:get_stat(stat)
	end

	return false
end

function AchievmentManager:award_none(id)
	Application:debug("[AchievmentManager:award_none] Awarded achievment", id)
end

function AchievmentManager:award_steam(id)
	Application:debug("[AchievmentManager:award_steam] Awarded Steam achievment", id)
	self.handler:achievement_store_callback(AchievmentManager.steam_unlock_result)
	self.handler:set_achievement(self:get_info(id).id)
	self.handler:store_data()

	if tweak_data.achievement.inventory[id] then
		for category, category_data in pairs(tweak_data.achievement.inventory[id].rewards) do
			for id, entry in pairs(category_data) do
				managers.blackmarket:tradable_achievement(category, entry)
			end
		end
	end
end

function AchievmentManager:clear_steam(id)
	print("[AchievmentManager:clear_steam]", id)

	if not self.handler:initialized() then
		print("[AchievmentManager:clear_steam] Achievments are not initialized. Cannot clear achievment:", id)

		return
	end

	self.handler:clear_achievement(self:get_info(id).id)
	self.handler:store_data()
end

function AchievmentManager:clear_all_steam()
	print("[AchievmentManager:clear_all_steam]")

	if not self.handler:initialized() then
		print("[AchievmentManager:clear_steam] Achievments are not initialized. Cannot clear steam:")

		return
	end

	self.handler:clear_all_stats(true)
	self.handler:store_data()
end

function AchievmentManager.steam_unlock_result(achievment)
	print("[AchievmentManager:steam_unlock_result] Awarded Steam achievment", achievment)

	for id, ach in pairs(managers.achievment.achievments) do
		if ach.id == achievment then
			managers.achievment:_give_reward(id)

			return
		end
	end
end

function AchievmentManager:award_x360(id)
	print("[AchievmentManager:award_x360] Awarded X360 achievment", id)

	local function x360_unlock_result(result)
		print("result", result)
	end

	XboxLive:award_achievement(managers.user:get_platform_id(), self:get_info(id).id, x360_unlock_result)
end

function AchievmentManager:award_psn(id)
	print("[AchievmentManager:award] Awarded PSN achievment", id, self:get_info(id).id)

	if not self._trophies_installed then
		print("[AchievmentManager:award] Trophies are not installed. Cannot award trophy:", id)

		return
	end

	local request = Trophies:unlock_id(self:get_info(id).id, AchievmentManager.psn_unlock_result)
	Global.achievment_manager.trophy_requests[request] = id
end

function AchievmentManager.psn_unlock_result(request, error_str)
	print("[AchievmentManager:psn_unlock_result] Awarded PSN achievment", request, error_str)

	local id = Global.achievment_manager.trophy_requests[request]

	if error_str == "success" then
		Global.achievment_manager.trophy_requests[request] = nil

		managers.achievment:_give_reward(id)
	end
end

function AchievmentManager:chk_install_trophies()
	if Trophies:is_installed() then
		print("[AchievmentManager:chk_install_trophies] Already installed")

		self._trophies_installed = true

		Trophies:get_unlockstate(self.unlockstate_result)
		self:fetch_trophies()
	elseif managers.dlc:has_full_game() then
		print("[AchievmentManager:chk_install_trophies] Installing")
		Trophies:install(callback(self, self, "clbk_install_trophies"))
	end
end

function AchievmentManager:clbk_install_trophies(result)
	print("[AchievmentManager:clbk_install_trophies]", result)

	if result then
		self._trophies_installed = true

		self:fetch_trophies()
	end
end

function AchievmentManager:check_complete_heist_stats_achivements()
	local job = nil

	for achievement, achievement_data in pairs(tweak_data.achievement.complete_heist_stats_achievements) do
		local remaining_jobs = nil

		if achievement_data.contact == "all" then
			remaining_jobs = {}

			for _, list in pairs(tweak_data.achievement.job_list) do
				for _, job in pairs(list) do
					table.insert(remaining_jobs, job)
				end
			end
		else
			remaining_jobs = deep_clone(tweak_data.achievement.job_list[achievement_data.contact])
		end

		for id = #remaining_jobs, 1, -1 do
			job = remaining_jobs[id]

			if type(job) == "table" then
				for _, job_id in ipairs(job) do
					local break_outer = false

					for _, difficulty in ipairs(achievement_data.difficulty) do
						if managers.statistics:completed_job(job_id, difficulty, achievement_data.one_down) > 0 then
							table.remove(remaining_jobs, id)

							break_outer = true

							break
						end
					end

					if break_outer then
						break
					end
				end
			else
				for _, difficulty in ipairs(achievement_data.difficulty) do
					local completion_count = managers.statistics:completed_job(job, difficulty, achievement_data.one_down)

					if completion_count > 0 then
						table.remove(remaining_jobs, id)

						break
					end
				end
			end
		end

		if table.size(remaining_jobs) == 0 then
			self:_award_achievement(achievement_data)
		end
	end
end

function AchievmentManager:check_autounlock_achievements()
	if SystemInfo:platform() == Idstring("WIN32") then
		self:_check_autounlock_complete_heist()
		self:_check_autounlock_difficulties()
	end

	self:_check_autounlock_infamy()
end

function AchievmentManager:_check_autounlock_complete_heist()
	local condition_whitelist = {
		"award",
		"difficulty",
		"one_down",
		"job",
		"jobs"
	}

	local function eligible_for_autounlock(achievement_data)
		local has_award = achievement_data.award
		local has_difficulty = achievement_data.difficulty
		local has_job = achievement_data.job or achievement_data.jobs

		if not has_award or not has_difficulty or not has_job then
			return false
		end

		for key, _ in pairs(achievement_data) do
			if not table.contains(condition_whitelist, key) then
				return false
			end
		end

		return true
	end

	for achievement, achievement_data in pairs(tweak_data.achievement.complete_heist_achievements) do
		if eligible_for_autounlock(achievement_data) then
			if not achievement_data.jobs then
				local jobs = {
					achievement_data.job
				}
			end

			for i, job in pairs(jobs) do
				for _, difficulty in ipairs(achievement_data.difficulty) do
					local completion_count = managers.statistics:completed_job(job, difficulty, achievement_data.one_down)

					if completion_count > 0 then
						self:_award_achievement(achievement_data)

						break
					end
				end
			end
		end
	end
end

function AchievmentManager:_check_autounlock_difficulties()
	self:check_complete_heist_stats_achivements()
end

function AchievmentManager:_check_autounlock_infamy()
	managers.experience:_check_achievements()
end

function AchievmentManager:_award_achievement(t, name)
	if name then
		print("[AchievmentManager] awarding: ", name)
	end

	if t.stat then
		managers.achievment:award_progress(t.stat)
	elseif t.award then
		managers.achievment:award(t.award)
		managers.generic_side_jobs:award(t.award)
	elseif t.challenge_stat then
		managers.challenge:award_progress(t.challenge_stat)
	elseif t.challenge_award then
		managers.challenge:award(t.challenge_award)
	elseif t.trophy_stat then
		managers.custom_safehouse:award(t.trophy_stat)
	elseif t.story then
		managers.story:award(t.story)
	else
		return false
	end

	return true
end
