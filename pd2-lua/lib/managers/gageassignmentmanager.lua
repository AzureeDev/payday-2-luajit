GageAssignmentManager = GageAssignmentManager or class()

function GageAssignmentManager:init()
	self:_setup()
	tweak_data:add_reload_callback(self, callback(self, self, "reloaded"))
end

function GageAssignmentManager:reloaded()
	self:_setup()
end

function GageAssignmentManager:_setup()
	self._tweak_data = tweak_data.gage_assignment

	if not Global.gage_assignment then
		Global.gage_assignment = {
			visited_gage_crimenet = false
		}

		self:_setup_assignments()
	end

	self._global = Global.gage_assignment
end

function GageAssignmentManager:_setup_assignments()
	local assignments = {
		active_assignments = {},
		completed_assignments = {}
	}
	Global.gage_assignment = assignments

	for assignment, data in pairs(self._tweak_data:get_assignments()) do
		assignments.active_assignments[assignment] = Application:digest_value(0, true)
		assignments.completed_assignments[assignment] = Application:digest_value(0, true)
	end
end

function GageAssignmentManager:reset()
	Global.gage_assignment = nil

	self:_setup()
end

function GageAssignmentManager:init_finalize()
	Application:debug("[GageAssignmentManager:init_finalize]")
	self:activate_assignments()
end

function GageAssignmentManager:get_latest_completed(assignment)
	return self._saved_completed_assignments and self._saved_completed_assignments[assignment] or 0
end

function GageAssignmentManager:get_latest_progress(assignment)
	return self._saved_progressed_assignments and self._saved_progressed_assignments[assignment] or 0
end

function GageAssignmentManager:get_latest_data()
	return self._saved_completed_assignments, self._saved_progressed_assignments
end

function GageAssignmentManager:get_assignment_progress(assignment)
	return self._global.active_assignments[assignment] and Application:digest_value(self._global.active_assignments[assignment], false) or 0
end

function GageAssignmentManager:get_assignment_data(assignment)
	local active_value = self._global.active_assignments[assignment]
	local completed_value = self._global.completed_assignments[assignment]
	local to_aquire = tweak_data.gage_assignment:get_value(assignment, "aquire")

	if not active_value or not completed_value or not to_aquire then
		return
	end

	return Application:digest_value(active_value, false), to_aquire, Application:digest_value(completed_value, false)
end

function GageAssignmentManager:activate_assignments()
	local is_host = Network:is_server() or Global.game_settings.single_player

	if not is_host then
		return self:_activate_assignments_client()
	end

	self._active_assignments = self._tweak_data:fetch_new_assignments(managers.job:current_level_id())
	self._spawned_units = self._queued_spawned_units or {}
	self._progressed_assignments = {}

	for _, assignment in pairs(self._active_assignments) do
		self._progressed_assignments[assignment] = 0
	end

	if self._queued_spawns then
		for i, data in ipairs(self._queued_spawns) do
			self:do_spawn(unpack(data))
		end

		self._queued_spawns = nil
	end

	self._queued_spawned_units = nil
end

function GageAssignmentManager:_activate_assignments_client()
	self._active_assignments = self._active_assignments or {}
	self._spawned_units = self._spawned_units or {}
	self._progressed_assignments = {}
end

function GageAssignmentManager:deactivate_assignments()
	local is_host = Network:is_server() or Global.game_settings.single_player

	if not is_host then
		return self:_deactivate_assignments_client()
	end

	for i, unit in ipairs(self._spawned_units or {}) do
		if alive(unit) then
			unit:set_slot(0)
		end
	end

	self._spawned_units = nil
	self._queued_spawns = nil
	self._queued_spawned_units = nil
	self._active_assignments = nil
	self._progressed_assignments = nil
end

function GageAssignmentManager:_deactivate_assignments_client()
	self._spawned_units = nil
	self._queued_spawns = nil
	self._queued_spawned_units = nil
	self._active_assignments = nil
	self._progressed_assignments = nil
end

function GageAssignmentManager:on_mission_completed()
	local total_pickup = 0
	local completed_assignments = {}

	if self._progressed_assignments then
		for assignment, value in pairs(self._progressed_assignments) do
			local dlc = tweak_data.gage_assignment:get_value(assignment, "dlc")

			if value > 0 and (not dlc or managers.dlc:is_dlc_unlocked(dlc)) then
				local collected = Application:digest_value(self._global.active_assignments[assignment], false) + value
				local to_aquire = self._tweak_data:get_value(assignment, "aquire") or 1

				if tweak_data.achievement.gage_assignments and tweak_data.achievement.gage_assignments[assignment] then
					managers.achievment:award_progress(tweak_data.achievement.gage_assignments[assignment], value)
				end

				while to_aquire <= collected do
					collected = collected - to_aquire

					self:_give_rewards(assignment)

					completed_assignments[assignment] = (completed_assignments[assignment] or 0) + 1
				end

				self._global.active_assignments[assignment] = Application:digest_value(collected, true)
			end

			total_pickup = total_pickup + value
		end
	end

	self._saved_completed_assignments = completed_assignments
	self._saved_progressed_assignments = self._progressed_assignments
	self._progressed_assignments = nil

	if table.size(completed_assignments) > 0 then
		self._global.dialog_params = self._global.dialog_params or {}
		self._global.dialog_params.assignments = self._global.dialog_params.assignments or {}

		for assignemnt, value in pairs(completed_assignments) do
			self._global.dialog_params.assignments[assignemnt] = (self._global.dialog_params.assignments[assignemnt] or 0) + value
		end

		self._global.dialog_params.date = Application:date("%Y-%m-%d")
		self._global.dialog_params.time = Application:date("%H:%M")
	end

	return total_pickup > 0
end

function GageAssignmentManager:debug_test_dialog_params(show_items)
	self._global.dialog_params = {
		assignments = {}
	}

	for assignemnt, data in pairs(self._tweak_data:get_assignments()) do
		self._global.dialog_params.assignments[assignemnt] = math.random(10) - 5

		if self._global.dialog_params.assignments[assignemnt] <= 0 then
			self._global.dialog_params.assignments[assignemnt] = nil
		end
	end

	self._global.dialog_params.date = Application:date("%Y-%m-%d")
	self._global.dialog_params.time = Application:date("%H:%M")

	self:dialog_show_completed_assignments(show_items)
end

function GageAssignmentManager:dialog_show_completed_assignments(show_items)
	if not self._global.dialog_params then
		return
	end

	local completed_assignment = self._global.dialog_params.assignments or {}
	local assignment_list = {}

	for assignment, _ in pairs(completed_assignment) do
		table.insert(assignment_list, assignment)
	end

	table.sort(assignment_list, function (x, y)
		return self._tweak_data:get_value(x, "aquire") < self._tweak_data:get_value(y, "aquire")
	end)

	local num, item = nil
	local completed = ""

	for i, assignment in ipairs(assignment_list) do
		num = tostring(completed_assignment[assignment])

		if not show_items then
			item = managers.localization:text(self._tweak_data:get_value(assignment, "name_id"))
			completed = completed .. managers.localization:text("dialog_item_list_macro", {
				num = num,
				item = item
			})
		else
			local rewards = self._tweak_data:get_value(assignment, "rewards")

			if rewards then
				completed = completed .. "\n"

				for index, reward in ipairs(rewards) do
					item = tweak_data:get_raw_value("blackmarket", reward[2], reward[3], "name_id")

					if item then
						local fits = ""

						if reward[2] == "weapon_mods" then
							fits = " ("
							local weapon_uses_part = managers.weapon_factory:get_weapons_uses_part(reward[3]) or {}

							if managers.localization:exists(item .. "_fits") then
								fits = fits .. managers.localization:text(item .. "_fits")
							elseif #weapon_uses_part == 1 then
								local weapon_id = managers.weapon_factory:get_weapon_id_by_factory_id(weapon_uses_part[1])
								fits = fits .. managers.weapon_factory:get_weapon_name_by_weapon_id(weapon_id)
							end

							fits = fits .. ")"
						end

						item = managers.localization:text(item) .. fits
						completed = completed .. managers.localization:text("dialog_item_list_macro", {
							num = num,
							item = item
						})

						if index < #rewards then
							completed = completed .. "\n"
						end
					end
				end
			end
		end

		if i < #assignment_list then
			completed = completed .. "\n"
		end
	end

	local params = {
		date = self._global.dialog_params.date,
		time = self._global.dialog_params.time,
		completed = completed
	}

	managers.menu:dialog_gage_assignment_completed(params)

	self._global.dialog_params = nil
end

function GageAssignmentManager:is_unit_an_assignment(unit)
	if self._spawned_units then
		for i, spawned_unit in ipairs(self._spawned_units) do
			if unit:key() == spawned_unit:key() then
				return true
			end
		end
	end

	if self._queued_spawned_units then
		for i, spawned_unit in ipairs(self._queued_spawned_units) do
			if unit:key() == spawned_unit:key() then
				return true
			end
		end
	end

	return false
end

function GageAssignmentManager:on_simulation_ended()
	self:deactivate_assignments()
end

function GageAssignmentManager:on_simulation_started()
	self:activate_assignments()
end

function GageAssignmentManager:queue_spawn(position, rotation)
	if self._active_assignments then
		self:do_spawn(position, rotation)
	else
		self._queued_spawns = self._queued_spawns or {}

		table.insert(self._queued_spawns, {
			position,
			rotation
		})
	end
end

function GageAssignmentManager:on_unit_spawned(unit)
	if not alive(unit) then
		return
	end

	local is_host = Network:is_server() or Global.game_settings.single_player

	if is_host then
		local max_units = self._tweak_data:get_num_assignment_units()
		local counted_units = 0
		counted_units = counted_units + (self._spawned_units and #self._spawned_units or 0)
		counted_units = counted_units + (self._queued_spawned_units and #self._queued_spawned_units or 0)

		if max_units <= counted_units then
			unit:set_slot(0)

			return false
		end
	end

	if self._spawned_units then
		table.insert(self._spawned_units, unit)
	else
		self._queued_spawned_units = self._queued_spawned_units or {}

		table.insert(self._queued_spawned_units, unit)
	end
end

function GageAssignmentManager:do_spawn(position, rotation)
	local is_host = Network:is_server() or Global.game_settings.single_player

	if not is_host then
		return nil
	end

	if not self._active_assignments then
		return nil
	end

	local weighted_assignments = {}
	local weight = 0
	local total_weight = 0

	for i, assignment in ipairs(self._active_assignments) do
		weight = self._tweak_data:get_value(assignment, "weight") or 1
		total_weight = total_weight + weight

		table.insert(weighted_assignments, weight)
	end

	local r = math.rand(total_weight)
	local assignment = nil

	for i, weight in ipairs(weighted_assignments) do
		r = r - weight

		if r <= 0 then
			assignment = self._active_assignments[i]

			break
		end
	end

	if assignment then
		local unit_name = self._tweak_data:get_value(assignment, "unit")
		local unit = unit_name and World:spawn_unit(unit_name, position, rotation) or nil

		return unit
	end

	return nil
end

function GageAssignmentManager:on_unit_interact(unit, assignment)
	if not alive(unit) then
		return false
	end

	local pass_spawned = false

	for i, spawned_unit in ipairs(self._spawned_units) do
		if spawned_unit:key() == unit:key() then
			pass_spawned = true

			break
		end
	end

	if not pass_spawned then
		return false
	end

	assignment = assignment or unit:base():assignment()

	if not self._active_assignments or not assignment then
		return false
	end

	if not self._progressed_assignments or not self._progressed_assignments[assignment] then
		return false
	end

	if not table.contains(self._active_assignments, assignment) then
		return false
	end

	if not self._global.active_assignments[assignment] then
		return false
	end

	if not managers.hud or not managers.hint then
		return false
	end

	local max_units = self._tweak_data:get_num_assignment_units()
	local counted_units = 0

	for assignment, count in pairs(self._progressed_assignments) do
		counted_units = counted_units + count
	end

	if max_units <= counted_units then
		return false
	end

	self._progressed_assignments[assignment] = self._progressed_assignments[assignment] + 1
end

function GageAssignmentManager:show_chat_message(peer_name)
	local max_units = self:count_all_units()
	local remaining = self:count_active_units()

	managers.chat:feed_system_message(ChatManager.GAME, managers.localization:text("menu_chat_gage_assignment_pickup", {
		name = peer_name,
		remaining = remaining - 1
	}))
end

function GageAssignmentManager:present_progress(assignment, peer_name)
	local max_units = self:count_all_units()
	local remaining = self:count_active_units()

	managers.hint:show_hint("hint_gage_assignment_progress", nil, nil, {
		assignment = managers.localization:text(self._tweak_data:get_value(assignment, "name_id")),
		peer_name = peer_name,
		remaining = remaining - 1
	})
end

function GageAssignmentManager:_present_progress(assignment, collected, to_aquire)
	managers.hint:show_hint(self._tweak_data:get_value(assignment, "progress_id"), nil, nil, {
		collected = collected,
		aquire = to_aquire
	})
end

function GageAssignmentManager:get_stinger_id()
	local job_tweak = tweak_data.narrative.jobs[managers.job:current_real_job_id()]

	if job_tweak and job_tweak.objective_stinger then
		return job_tweak.objective_stinger
	end

	return "stinger_objectivecomplete"
end

function GageAssignmentManager:_present_completed(assignment, collected, to_aquire)
	local title_id = self._tweak_data:get_value(assignment, "present_id")
	local title = managers.localization:text(title_id, {})
	local text_id = self._tweak_data:get_value(assignment, "complete_id")
	local text = managers.localization:text(text_id, {
		collected = collected,
		aquire = to_aquire
	})
	local icon = nil

	managers.hud:present_mid_text({
		time = 4,
		text = text,
		title = title,
		icon = icon,
		event = self:get_stinger_id()
	})
end

function GageAssignmentManager:_give_rewards(assignment)
	local completed = Application:digest_value(self._global.completed_assignments[assignment], false) + 1
	self._global.completed_assignments[assignment] = Application:digest_value(completed, true)
	local rewards = self._tweak_data:get_value(assignment, "rewards")

	if rewards then
		for i, reward in ipairs(rewards) do
			managers.blackmarket:add_to_inventory(unpack(reward))
		end
	end

	local award_gmod_6 = true

	for i, dvalue in pairs(self._global.completed_assignments) do
		if Application:digest_value(dvalue, false) < tweak_data.achievement.gonna_find_them_all then
			award_gmod_6 = false

			break
		end
	end

	if award_gmod_6 then
		managers.achievment:award("gmod_6")
	end
end

function GageAssignmentManager:count_all_units()
	local max_units = tweak_data.gage_assignment:get_num_assignment_units()

	return max_units
end

function GageAssignmentManager:count_active_units()
	if not self._spawned_units then
		return 0
	end

	local count = 0

	for i, unit in ipairs(self._spawned_units) do
		if alive(unit) then
			count = count + 1
		end
	end

	return count
end

function GageAssignmentManager:get_current_experience_multiplier()
	local max_units = self:count_all_units()
	local active_units = self:count_active_units()

	if max_units == 0 or not self._active_assignments then
		return 1
	end

	local ratio = 1 - active_units / max_units

	return self._tweak_data:get_experience_multiplier(ratio)
end

function GageAssignmentManager:visited_gage_crimenet()
	return self._global.visited_gage_crimenet
end

function GageAssignmentManager:visit_gage_crimenet()
	self._global.visited_gage_crimenet = true
end

function GageAssignmentManager:sync_save(data)
	data.GageAssignmentManager = {
		active = self._active_assignments,
		progressed = self._progressed_assignments
	}
end

function GageAssignmentManager:sync_load(data)
	if data.GageAssignmentManager then
		self._active_assignments = data.GageAssignmentManager.active
		self._progressed_assignments = data.GageAssignmentManager.progressed

		if self._progressed_assignments then
			local max_units = self._tweak_data:get_num_assignment_units()
			local counted_units = 0

			for assignment, count in pairs(self._progressed_assignments) do
				counted_units = counted_units + count

				if max_units < counted_units then
					local diff = counted_units - max_units
					self._progressed_assignments[assignment] = math.max(self._progressed_assignments[assignment] - diff, 0)

					Application:error("[GageAssignmentManager:sync_load] Max num units reached, capping pickup.", assignment)
				end
			end
		end
	end
end

function GageAssignmentManager:save(data)
	local save_data = {
		active_assignments = deep_clone(self._global.active_assignments),
		completed_assignments = deep_clone(self._global.completed_assignments),
		visited_gage_crimenet = self._global.visited_gage_crimenet or false,
		dialog_params = self._global.dialog_params
	}
	data.gage_assignment = save_data
end

function GageAssignmentManager:load(data, version)
	if data.gage_assignment then
		Global.gage_assignment = data.gage_assignment
		self._global = Global.gage_assignment
		Global.gage_assignment.active_assignments = Global.gage_assignment.active_assignments or {}
		Global.gage_assignment.completed_assignments = Global.gage_assignment.completed_assignments or {}
		local assignments_data = self._tweak_data:get_assignments()
		local deleted_assignments = {}

		for assignment, num in pairs(Global.gage_assignment.active_assignments) do
			if not assignments_data[assignment] then
				table.insert(deleted_assignments, assignment)
			end
		end

		for _, assignment in ipairs(deleted_assignments) do
			Application:error("[GageAssignmentManager:load] Removing non-existing assignment (active): " .. tostring(assignment))

			Global.gage_assignment.active_assignments[assignment] = nil
		end

		deleted_assignments = {}

		for assignment, num in pairs(Global.gage_assignment.completed_assignments) do
			if not assignments_data[assignment] then
				table.insert(deleted_assignments, assignment)
			end
		end

		for _, assignment in ipairs(deleted_assignments) do
			Application:error("[GageAssignmentManager:load] Removing non-existing assignment (completed): " .. tostring(assignment))

			Global.gage_assignment.completed_assignments[assignment] = nil
		end

		for assignment, data in pairs(assignments_data) do
			Global.gage_assignment.active_assignments[assignment] = Global.gage_assignment.active_assignments[assignment] or Application:digest_value(0, true)
			Global.gage_assignment.completed_assignments[assignment] = Global.gage_assignment.completed_assignments[assignment] or Application:digest_value(0, true)
		end
	end
end

function GageAssignmentManager:debug_show_units(persistance)
end
