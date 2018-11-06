local mvec3_set = mvector3.set
local mvec3_sub = mvector3.subtract
local mvec3_dir = mvector3.direction
local mvec3_dot = mvector3.dot
local mvec3_dis = mvector3.distance
local t_rem = table.remove
local t_ins = table.insert
local m_min = math.min
local tmp_vec1 = Vector3()
EnemyManager = EnemyManager or class()
EnemyManager._MAX_NR_CORPSES = 8
EnemyManager.MAX_MAGAZINES = 30
EnemyManager._nr_i_lod = {
	{
		2,
		2
	},
	{
		5,
		2
	},
	{
		10,
		5
	}
}

function EnemyManager:init()
	self:_init_enemy_data()

	self._unit_clbk_key = "EnemyManager"
	self._corpse_disposal_upd_interval = 5
	self._shield_disposal_upd_interval = 15
	self._shield_disposal_lifetime = 60
	self._MAX_NR_SHIELDS = 8
	self._queue_buffer = 0
end

function EnemyManager:update(t, dt)
	self._t = t
	self._queued_task_executed = nil

	self:_update_gfx_lod()
	self:_update_queued_tasks(t, dt)
end

function EnemyManager:corpse_limit()
	local limit = managers.user:get_setting("corpse_limit") or self._MAX_NR_CORPSES
	limit = managers.mutators:modify_value("EnemyManager:corpse_limit", limit)

	return limit
end

function EnemyManager:shield_limit()
	return self._MAX_NR_SHIELDS
end

function EnemyManager:_update_gfx_lod()
	if self._gfx_lod_data.enabled and managers.navigation:is_data_ready() then
		local camera_rot = managers.viewport:get_current_camera_rotation()

		if camera_rot then
			local pl_tracker, cam_pos = nil
			local pl_fwd = camera_rot:y()
			local player = managers.player:player_unit()

			if player then
				pl_tracker = player:movement():nav_tracker()
				cam_pos = player:movement():m_head_pos()
			else
				pl_tracker = false
				cam_pos = managers.viewport:get_current_camera_position()
			end

			local entries = self._gfx_lod_data.entries
			local units = entries.units
			local states = entries.states
			local move_ext = entries.move_ext
			local trackers = entries.trackers
			local com = entries.com
			local chk_vis_func = pl_tracker and pl_tracker.check_visibility
			local unit_occluded = Unit.occluded
			local occ_skip_units = managers.occlusion._skip_occlusion
			local world_in_view_with_options = World.in_view_with_options

			for i, state in ipairs(states) do
				if not state and (occ_skip_units[units[i]:key()] or (not pl_tracker or chk_vis_func(pl_tracker, trackers[i])) and not unit_occluded(units[i])) and world_in_view_with_options(World, com[i], 0, 110, 18000) then
					states[i] = 1

					units[i]:base():set_visibility_state(1)
				end
			end

			if #states > 0 then
				local anim_lod = managers.user:get_setting("video_animation_lod")
				local nr_lod_1 = self._nr_i_lod[anim_lod][1]
				local nr_lod_2 = self._nr_i_lod[anim_lod][2]
				local nr_lod_total = nr_lod_1 + nr_lod_2
				local imp_i_list = self._gfx_lod_data.prio_i
				local imp_wgt_list = self._gfx_lod_data.prio_weights
				local nr_entries = #states
				local i = self._gfx_lod_data.next_chk_prio_i

				if nr_entries < i then
					i = 1
				end

				local start_i = i

				repeat
					if states[i] and alive(units[i]) then
						if not occ_skip_units[units[i]:key()] and (pl_tracker and not chk_vis_func(pl_tracker, trackers[i]) or unit_occluded(units[i])) then
							states[i] = false

							units[i]:base():set_visibility_state(false)
							self:_remove_i_from_lod_prio(i, anim_lod)

							self._gfx_lod_data.next_chk_prio_i = i + 1

							break
						elseif not world_in_view_with_options(World, com[i], 0, 120, 18000) then
							states[i] = false

							units[i]:base():set_visibility_state(false)
							self:_remove_i_from_lod_prio(i, anim_lod)

							self._gfx_lod_data.next_chk_prio_i = i + 1

							break
						else
							local my_wgt = mvec3_dir(tmp_vec1, cam_pos, com[i])
							local dot = mvec3_dot(tmp_vec1, pl_fwd)
							local previous_prio = nil

							for prio, i_entry in ipairs(imp_i_list) do
								if i == i_entry then
									previous_prio = prio

									break
								end
							end

							my_wgt = my_wgt * my_wgt * (1 - dot)
							local i_wgt = #imp_wgt_list

							while i_wgt > 0 do
								if previous_prio ~= i_wgt and imp_wgt_list[i_wgt] <= my_wgt then
									break
								end

								i_wgt = i_wgt - 1
							end

							if not previous_prio or i_wgt <= previous_prio then
								i_wgt = i_wgt + 1
							end

							if i_wgt ~= previous_prio then
								if previous_prio then
									t_rem(imp_i_list, previous_prio)
									t_rem(imp_wgt_list, previous_prio)

									if previous_prio <= nr_lod_1 and nr_lod_1 < i_wgt and nr_lod_1 <= #imp_i_list then
										local promote_i = imp_i_list[nr_lod_1]
										states[promote_i] = 1

										units[promote_i]:base():set_visibility_state(1)
									elseif nr_lod_1 < previous_prio and i_wgt <= nr_lod_1 then
										local denote_i = imp_i_list[nr_lod_1]
										states[denote_i] = 2

										units[denote_i]:base():set_visibility_state(2)
									end
								elseif i_wgt <= nr_lod_total and #imp_i_list == nr_lod_total then
									local kick_i = imp_i_list[nr_lod_total]
									states[kick_i] = 3

									units[kick_i]:base():set_visibility_state(3)
									t_rem(imp_wgt_list)
									t_rem(imp_i_list)
								end

								local lod_stage = nil

								if i_wgt <= nr_lod_total then
									t_ins(imp_wgt_list, i_wgt, my_wgt)
									t_ins(imp_i_list, i_wgt, i)

									if i_wgt <= nr_lod_1 then
										lod_stage = 1
									else
										lod_stage = 2
									end
								else
									lod_stage = 3

									self:_remove_i_from_lod_prio(i, anim_lod)
								end

								if states[i] ~= lod_stage then
									states[i] = lod_stage

									units[i]:base():set_visibility_state(lod_stage)
								end
							end

							self._gfx_lod_data.next_chk_prio_i = i + 1

							break
						end
					end

					if i == nr_entries then
						i = 1
					else
						i = i + 1
					end
				until i == start_i
			end
		end
	end
end

function EnemyManager:_remove_i_from_lod_prio(i, anim_lod)
	anim_lod = anim_lod or managers.user:get_setting("video_animation_lod")
	local nr_i_lod1 = self._nr_i_lod[anim_lod][1]

	for prio, i_entry in ipairs(self._gfx_lod_data.prio_i) do
		if i == i_entry then
			table.remove(self._gfx_lod_data.prio_i, prio)
			table.remove(self._gfx_lod_data.prio_weights, prio)

			if prio <= nr_i_lod1 and nr_i_lod1 < #self._gfx_lod_data.prio_i then
				local promoted_i_entry = self._gfx_lod_data.prio_i[prio]
				self._gfx_lod_data.entries.states[promoted_i_entry] = 1

				self._gfx_lod_data.entries.units[promoted_i_entry]:base():set_visibility_state(1)
			end

			return
		end
	end
end

function EnemyManager:_create_unit_gfx_lod_data(unit)
	local lod_entries = self._gfx_lod_data.entries

	table.insert(lod_entries.units, unit)
	table.insert(lod_entries.states, 1)
	table.insert(lod_entries.move_ext, unit:movement())
	table.insert(lod_entries.trackers, unit:movement():nav_tracker())
	table.insert(lod_entries.com, unit:movement():m_com())
end

function EnemyManager:_destroy_unit_gfx_lod_data(u_key)
	local lod_entries = self._gfx_lod_data.entries

	for i, unit in ipairs(lod_entries.units) do
		if u_key == unit:key() then
			if not lod_entries.states[i] then
				unit:base():set_visibility_state(1)
			end

			local nr_entries = #lod_entries.units

			self:_remove_i_from_lod_prio(i)

			for prio, i_entry in ipairs(self._gfx_lod_data.prio_i) do
				if i_entry == nr_entries then
					self._gfx_lod_data.prio_i[prio] = i

					break
				end
			end

			lod_entries.units[i] = lod_entries.units[nr_entries]

			table.remove(lod_entries.units)

			lod_entries.states[i] = lod_entries.states[nr_entries]

			table.remove(lod_entries.states)

			lod_entries.move_ext[i] = lod_entries.move_ext[nr_entries]

			table.remove(lod_entries.move_ext)

			lod_entries.trackers[i] = lod_entries.trackers[nr_entries]

			table.remove(lod_entries.trackers)

			lod_entries.com[i] = lod_entries.com[nr_entries]

			table.remove(lod_entries.com)

			break
		end
	end
end

function EnemyManager:set_gfx_lod_enabled(state)
	if state then
		self._gfx_lod_data.enabled = state
	elseif self._gfx_lod_data.enabled then
		self._gfx_lod_data.enabled = state
		local entries = self._gfx_lod_data.entries
		local units = entries.units
		local states = entries.states

		for i, state in ipairs(states) do
			states[i] = 1

			units[i]:base():set_visibility_state(1)
		end
	end
end

function EnemyManager:chk_any_unit_in_slotmask_visible(slotmask, cam_pos, cam_nav_tracker)
	if self._gfx_lod_data.enabled and managers.navigation:is_data_ready() then
		local camera_rot = managers.viewport:get_current_camera_rotation()
		local entries = self._gfx_lod_data.entries
		local units = entries.units
		local states = entries.states
		local trackers = entries.trackers
		local move_exts = entries.move_ext
		local com = entries.com
		local chk_vis_func = cam_nav_tracker and cam_nav_tracker.check_visibility
		local unit_occluded = Unit.occluded
		local occ_skip_units = managers.occlusion._skip_occlusion
		local vis_slotmask = managers.slot:get_mask("AI_visibility")

		for i, state in ipairs(states) do
			local unit = units[i]

			if unit:in_slot(slotmask) and (occ_skip_units[unit:key()] or (not cam_nav_tracker or chk_vis_func(cam_nav_tracker, trackers[i])) and not unit_occluded(unit)) then
				local distance = mvec3_dir(tmp_vec1, cam_pos, com[i])

				if distance < 300 then
					return true
				elseif distance < 2000 then
					local u_m_head_pos = move_exts[i]:m_head_pos()
					local ray = World:raycast("ray", cam_pos, u_m_head_pos, "slot_mask", vis_slotmask, "report")

					if not ray then
						return true
					else
						ray = World:raycast("ray", cam_pos, com[i], "slot_mask", vis_slotmask, "report")

						if not ray then
							return true
						end
					end
				end
			end
		end
	end
end

function EnemyManager:_init_enemy_data()
	local enemy_data = {}
	local unit_data = {}
	self._enemy_data = enemy_data
	enemy_data.unit_data = unit_data
	enemy_data.nr_units = 0
	enemy_data.nr_active_units = 0
	enemy_data.nr_inactive_units = 0
	enemy_data.inactive_units = {}
	enemy_data.max_nr_active_units = 20
	enemy_data.corpses = {}
	enemy_data.nr_corpses = 0
	enemy_data.shields = {}
	enemy_data.nr_shields = 0
	self._civilian_data = {
		unit_data = {}
	}
	self._queued_tasks = {}
	self._queued_task_executed = nil
	self._delayed_clbks = {}
	self._t = 0
	self._gfx_lod_data = {
		enabled = true,
		prio_i = {},
		prio_weights = {},
		next_chk_prio_i = 1,
		entries = {}
	}
	local lod_entries = self._gfx_lod_data.entries
	lod_entries.units = {}
	lod_entries.states = {}
	lod_entries.move_ext = {}
	lod_entries.trackers = {}
	lod_entries.com = {}
	self._corpse_disposal_enabled = 0
end

function EnemyManager:all_enemies()
	return self._enemy_data.unit_data
end

function EnemyManager:is_enemy(unit)
	return self._enemy_data.unit_data[unit:key()] and true or false
end

function EnemyManager:all_civilians()
	return self._civilian_data.unit_data
end

function EnemyManager:is_civilian(unit)
	return self._civilian_data.unit_data[unit:key()] and true or false
end

function EnemyManager:queue_task(id, task_clbk, data, execute_t, verification_clbk, asap)
	local task_data = {
		clbk = task_clbk,
		id = id,
		data = data,
		t = execute_t,
		v_cb = verification_clbk,
		asap = asap
	}

	table.insert(self._queued_tasks, task_data)

	if not execute_t and #self._queued_tasks <= 1 and not self._queued_task_executed then
		self:_execute_queued_task(1)
	end
end

function EnemyManager:unqueue_task(id)
	local tasks = self._queued_tasks
	local i = #tasks

	while i > 0 do
		if tasks[i].id == id then
			table.remove(tasks, i)

			return
		end

		i = i - 1
	end

	debug_pause("[EnemyManager:unqueue_task] task", id, "was not queued!!!")
end

function EnemyManager:unqueue_task_debug(id)
	if not id then
		Application:stack_dump()
	end

	local tasks = self._queued_tasks
	local i = #tasks
	local removed = nil

	while i > 0 do
		if tasks[i].id == id then
			if removed then
				debug_pause("DOUBLE TASK AT ", i, id)
			else
				table.remove(tasks, i)

				removed = true
			end
		end

		i = i - 1
	end

	if not removed then
		debug_pause("[EnemyManager:unqueue_task] task", id, "was not queued!!!")
	end
end

function EnemyManager:has_task(id)
	local tasks = self._queued_tasks
	local i = #tasks
	local count = 0

	while i > 0 do
		if tasks[i].id == id then
			count = count + 1
		end

		i = i - 1
	end

	return count > 0 and count
end

function EnemyManager:_execute_queued_task(i)
	local task = table.remove(self._queued_tasks, i)
	self._queued_task_executed = true

	if task.data and task.data.unit and not alive(task.data.unit) then
		print("[EnemyManager:_execute_queued_task] dead unit", inspect(task))
		Application:stack_dump()
	end

	if task.v_cb then
		task.v_cb(task.id)
	end

	task.clbk(task.data)
end

function EnemyManager:_update_queued_tasks(t, dt)
	local i_asap_task, asp_task_t = nil
	self._queue_buffer = self._queue_buffer + dt
	local tick_rate = tweak_data.group_ai.ai_tick_rate

	if tick_rate <= self._queue_buffer then
		for i_task, task_data in ipairs(self._queued_tasks) do
			if not task_data.t or task_data.t < t then
				self:_execute_queued_task(i_task)

				self._queue_buffer = self._queue_buffer - tick_rate

				if self._queue_buffer <= 0 then
					break
				end
			elseif task_data.asap and (not asp_task_t or task_data.t < asp_task_t) then
				i_asap_task = i_task
				asp_task_t = task_data.t
			end
		end
	end

	if #self._queued_tasks == 0 then
		self._queue_buffer = 0
	end

	if i_asap_task and not self._queued_task_executed then
		self:_execute_queued_task(i_asap_task)
	end

	local all_clbks = self._delayed_clbks

	if all_clbks[1] and all_clbks[1][2] < t then
		local clbk = table.remove(all_clbks, 1)[3]

		clbk()
	end
end

function EnemyManager:add_delayed_clbk(id, clbk, execute_t)
	if not clbk then
		debug_pause("[EnemyManager:add_delayed_clbk] Empty callback object!!!")
	end

	local clbk_data = {
		id,
		execute_t,
		clbk
	}
	local all_clbks = self._delayed_clbks
	local i = #all_clbks

	if i > 0 then
		while i > 0 and execute_t < all_clbks[i][2] do
			i = i - 1
		end
	end

	table.insert(all_clbks, i + 1, clbk_data)
end

function EnemyManager:is_clbk_registered(id)
	if self._delayed_clbks then
		for i, clbk_data in ipairs(self._delayed_clbks) do
			if clbk_data[1] == id then
				return true
			end
		end
	end

	return false
end

function EnemyManager:remove_delayed_clbk(id, no_pause)
	local all_clbks = self._delayed_clbks

	for i, clbk_data in ipairs(all_clbks) do
		if clbk_data[1] == id then
			table.remove(all_clbks, i)

			return
		end
	end

	if not no_pause then
		debug_pause("[EnemyManager:remove_delayed_clbk] id", id, "was not scheduled!!!")
	end
end

function EnemyManager:reschedule_delayed_clbk(id, execute_t)
	local all_clbks = self._delayed_clbks
	local clbk_data = nil

	for i, clbk_d in ipairs(all_clbks) do
		if clbk_d[1] == id then
			clbk_data = table.remove(all_clbks, i)

			break
		end
	end

	if clbk_data then
		clbk_data[2] = execute_t
		local i = #all_clbks

		if i > 0 then
			while i > 0 and execute_t < all_clbks[i][2] do
				i = i - 1
			end
		end

		table.insert(all_clbks, i + 1, clbk_data)

		return
	end

	debug_pause("[EnemyManager:reschedule_delayed_clbk] id", id, "was not scheduled!!!")
end

function EnemyManager:force_delayed_clbk(id)
	local all_clbks = self._delayed_clbks

	for i, clbk_data in ipairs(all_clbks) do
		if clbk_data[1] == id then
			local clbk = table.remove(all_clbks, 1)[3]

			clbk()

			return
		end
	end

	debug_pause("[EnemyManager:force_delayed_clbk] id", id, "was not scheduled!!!")
end

function EnemyManager:queued_tasks_by_callback()
	local t = TimerManager:game():time()
	local categorised_queued_tasks = {}
	local congestion = 0

	for i_task, task_data in ipairs(self._queued_tasks) do
		if categorised_queued_tasks[task_data.clbk] then
			categorised_queued_tasks[task_data.clbk].amount = categorised_queued_tasks[task_data.clbk].amount + 1
		else
			categorised_queued_tasks[task_data.clbk] = {
				amount = 1,
				key = task_data.id
			}
		end

		if not task_data.t or task_data.t < t then
			congestion = congestion + 1
		end
	end

	print("congestion", congestion)

	for clbk, data in pairs(categorised_queued_tasks) do
		print(data.key, data.amount)
	end
end

function EnemyManager:register_enemy(enemy)
	if self._destroyed then
		debug_pause("[EnemyManager:register_enemy] enemy manager is destroyed")
	end

	local char_tweak = tweak_data.character[enemy:base()._tweak_table]
	local u_data = {
		importance = 0,
		unit = enemy,
		m_pos = enemy:movement():m_pos(),
		tracker = enemy:movement():nav_tracker(),
		char_tweak = char_tweak,
		so_access = managers.navigation:convert_access_flag(char_tweak.access)
	}
	self._enemy_data.unit_data[enemy:key()] = u_data

	enemy:base():add_destroy_listener(self._unit_clbk_key, callback(self, self, "on_enemy_destroyed"))
	self:on_enemy_registered(enemy)
end

function EnemyManager:on_enemy_died(dead_unit, damage_info)
	if self._destroyed then
		debug_pause("[EnemyManager:on_enemy_died] enemy manager is destroyed", dead_unit)
	end

	local u_key = dead_unit:key()
	local enemy_data = self._enemy_data

	if not enemy_data.unit_data[u_key] then
		local u_data = {
			unit = dead_unit
		}
	end

	self:on_enemy_unregistered(dead_unit)

	enemy_data.unit_data[u_key] = nil

	managers.mission:call_global_event("enemy_killed")

	if enemy_data.nr_corpses >= 0 and self:is_corpse_disposal_enabled() and not self:has_task("EnemyManager._upd_corpse_disposal") then
		self:queue_task("EnemyManager._upd_corpse_disposal", EnemyManager._upd_corpse_disposal, self, self._t + self._corpse_disposal_upd_interval)
	end

	enemy_data.nr_corpses = enemy_data.nr_corpses + 1
	enemy_data.corpses[u_key] = u_data
	u_data.death_t = self._t

	self:_destroy_unit_gfx_lod_data(u_key)

	u_data.u_id = dead_unit:id()

	if self:is_corpse_disposal_enabled() then
		Network:detach_unit(dead_unit)
	end

	managers.hud:remove_waypoint("wp_hostage_trade" .. tostring(dead_unit:key()))
	managers.modifiers:run_func("OnEnemyDied", dead_unit, damage_info)
end

function EnemyManager:on_enemy_destroyed(enemy)
	local u_key = enemy:key()
	local enemy_data = self._enemy_data

	if enemy_data.unit_data[u_key] then
		self:on_enemy_unregistered(enemy)

		enemy_data.unit_data[u_key] = nil

		self:_destroy_unit_gfx_lod_data(u_key)
	elseif enemy_data.corpses[u_key] then
		enemy_data.nr_corpses = enemy_data.nr_corpses - 1
		enemy_data.corpses[u_key] = nil

		if enemy_data.nr_corpses == 0 and self:is_corpse_disposal_enabled() then
			self:unqueue_task("EnemyManager._upd_corpse_disposal")
		end
	end
end

function EnemyManager:on_enemy_registered(unit)
	self._enemy_data.nr_units = self._enemy_data.nr_units + 1

	self:_create_unit_gfx_lod_data(unit, true)
	managers.groupai:state():on_enemy_registered(unit)
end

function EnemyManager:on_enemy_unregistered(unit)
	self._enemy_data.nr_units = self._enemy_data.nr_units - 1

	managers.groupai:state():on_enemy_unregistered(unit)
end

function EnemyManager:register_shield(shield_unit)
	local enemy_data = self._enemy_data

	if enemy_data.nr_shields >= 0 and self:is_corpse_disposal_enabled() and not self:has_task("EnemyManager._upd_shield_disposal") then
		self:queue_task("EnemyManager._upd_shield_disposal", EnemyManager._upd_shield_disposal, self, self._t + self._shield_disposal_upd_interval)
	end

	enemy_data.nr_shields = enemy_data.nr_shields + 1
	enemy_data.shields[shield_unit:key()] = {
		unit = shield_unit,
		death_t = TimerManager:game():time()
	}
end

function EnemyManager:unregister_shield(shield_unit)
	local enemy_data = self._enemy_data
	local u_key = shield_unit:key()
	local u_data = enemy_data.shields[u_key]

	if u_data then
		enemy_data.shields[u_key] = nil
		enemy_data.nr_shields = enemy_data.nr_shields - 1

		if enemy_data.nr_shields == 0 then
			self:unqueue_task("EnemyManager._upd_shield_disposal")
		end
	end
end

function EnemyManager:register_civilian(unit)
	unit:base():add_destroy_listener(self._unit_clbk_key, callback(self, self, "on_civilian_destroyed"))
	self:_create_unit_gfx_lod_data(unit, true)

	local char_tweak = tweak_data.character[unit:base()._tweak_table]
	self._civilian_data.unit_data[unit:key()] = {
		is_civilian = true,
		unit = unit,
		m_pos = unit:movement():m_pos(),
		tracker = unit:movement():nav_tracker(),
		char_tweak = char_tweak,
		so_access = managers.navigation:convert_access_flag(char_tweak.access)
	}
end

function EnemyManager:on_civilian_died(dead_unit, damage_info)
	local u_key = dead_unit:key()

	managers.groupai:state():on_civilian_unregistered(dead_unit)

	if Network:is_server() and damage_info.attacker_unit and not dead_unit:base().enemy then
		managers.groupai:state():hostage_killed(damage_info.attacker_unit)
	end

	managers.mission:call_global_event("civilian_killed")

	local u_data = self._civilian_data.unit_data[u_key]
	local enemy_data = self._enemy_data

	if enemy_data.nr_corpses == 0 and self:is_corpse_disposal_enabled() then
		self:queue_task("EnemyManager._upd_corpse_disposal", EnemyManager._upd_corpse_disposal, self, self._t + self._corpse_disposal_upd_interval)
	end

	enemy_data.nr_corpses = enemy_data.nr_corpses + 1
	enemy_data.corpses[u_key] = u_data
	u_data.death_t = TimerManager:game():time()
	self._civilian_data.unit_data[u_key] = nil

	self:_destroy_unit_gfx_lod_data(u_key)

	u_data.u_id = dead_unit:id()

	if self:is_corpse_disposal_enabled() then
		Network:detach_unit(dead_unit)
	end

	managers.hud:remove_waypoint("wp_hostage_trade" .. tostring(dead_unit:key()))
end

function EnemyManager:on_civilian_destroyed(enemy)
	local u_key = enemy:key()
	local enemy_data = self._enemy_data

	if enemy_data.corpses[u_key] then
		enemy_data.nr_corpses = enemy_data.nr_corpses - 1
		enemy_data.corpses[u_key] = nil

		if enemy_data.nr_corpses == 0 and self:is_corpse_disposal_enabled() then
			self:unqueue_task("EnemyManager._upd_corpse_disposal")
		end
	else
		managers.groupai:state():on_civilian_unregistered(enemy)

		self._civilian_data.unit_data[u_key] = nil

		self:_destroy_unit_gfx_lod_data(u_key)
	end
end

function EnemyManager:on_criminal_registered(unit)
	self:_create_unit_gfx_lod_data(unit, false)
end

function EnemyManager:on_criminal_unregistered(u_key)
	self:_destroy_unit_gfx_lod_data(u_key)
end

function EnemyManager:_upd_corpse_disposal()
	local t = TimerManager:game():time()
	local enemy_data = self._enemy_data
	local nr_corpses = enemy_data.nr_corpses
	local disposals_needed = nr_corpses - self:corpse_limit()
	local corpses = enemy_data.corpses
	local nav_mngr = managers.navigation
	local player = managers.player:player_unit()
	local pl_tracker, cam_pos, cam_fwd = nil

	if player then
		pl_tracker = player:movement():nav_tracker()
		cam_pos = player:movement():m_head_pos()
		cam_fwd = player:camera():forward()
	elseif managers.viewport:get_current_camera() then
		cam_pos = managers.viewport:get_current_camera_position()
		cam_fwd = managers.viewport:get_current_camera_rotation():y()
	end

	local to_dispose = {}
	local nr_found = 0

	if pl_tracker then
		for u_key, u_data in pairs(corpses) do
			local u_tracker = u_data.tracker

			if u_tracker and not pl_tracker:check_visibility(u_tracker) then
				to_dispose[u_key] = true
				nr_found = nr_found + 1
			end
		end
	end

	if disposals_needed > #to_dispose then
		if cam_pos then
			for u_key, u_data in pairs(corpses) do
				local u_pos = u_data.m_pos

				if not to_dispose[u_key] and mvec3_dis(cam_pos, u_pos) > 300 and mvector3.dot(cam_fwd, u_pos - cam_pos) < 0 then
					to_dispose[u_key] = true
					nr_found = nr_found + 1

					if nr_found == disposals_needed then
						break
					end
				end
			end
		end

		if nr_found < disposals_needed then
			local oldest_u_key, oldest_t = nil

			for u_key, u_data in pairs(corpses) do
				if (not oldest_t or u_data.death_t < oldest_t) and not to_dispose[u_key] then
					oldest_u_key = u_key
					oldest_t = u_data.death_t
				end
			end

			if oldest_u_key then
				to_dispose[oldest_u_key] = true
				nr_found = nr_found + 1
			end
		end
	end

	for u_key, _ in pairs(to_dispose) do
		local u_data = corpses[u_key]

		if alive(u_data.unit) then
			u_data.unit:base():set_slot(u_data.unit, 0)
		end

		corpses[u_key] = nil
	end

	enemy_data.nr_corpses = nr_corpses - nr_found

	if nr_corpses > 0 then
		local delay = self:corpse_limit() < enemy_data.nr_corpses and 0 or self._corpse_disposal_upd_interval

		self:queue_task("EnemyManager._upd_corpse_disposal", EnemyManager._upd_corpse_disposal, self, t + delay)
	end
end

function EnemyManager:_upd_shield_disposal()
	local t = TimerManager:game():time()
	local enemy_data = self._enemy_data
	local nr_shields = enemy_data.nr_shields
	local disposals_needed = nr_shields - self:shield_limit()
	local shields = enemy_data.shields
	local player = managers.player:player_unit()
	local cam_pos, cam_fwd = nil

	if player then
		cam_pos = player:movement():m_head_pos()
		cam_fwd = player:camera():forward()
	elseif managers.viewport:get_current_camera() then
		cam_pos = managers.viewport:get_current_camera_position()
		cam_fwd = managers.viewport:get_current_camera_rotation():y()
	end

	local to_dispose = {}
	local nr_found = 0

	if disposals_needed > #to_dispose then
		if cam_pos then
			for u_key, u_data in pairs(shields) do
				local dispose = false

				if alive(u_data.unit) then
					local u_pos = u_data.unit:position()

					if not to_dispose[u_key] and mvec3_dis(cam_pos, u_pos) > 300 and mvector3.dot(cam_fwd, u_pos - cam_pos) < 0 and t > u_data.death_t + self._shield_disposal_lifetime then
						dispose = true
					end
				else
					dispose = true
				end

				if dispose then
					to_dispose[u_key] = true
					nr_found = nr_found + 1

					if nr_found == disposals_needed then
						break
					end
				end
			end
		end

		if nr_found < disposals_needed then
			local oldest_u_key, oldest_t = nil

			for u_key, u_data in pairs(shields) do
				if (not oldest_t or u_data.death_t < oldest_t) and not to_dispose[u_key] then
					oldest_u_key = u_key
					oldest_t = u_data.death_t
				end
			end

			if oldest_u_key then
				to_dispose[oldest_u_key] = true
				nr_found = nr_found + 1
			end
		end
	end

	for u_key, _ in pairs(to_dispose) do
		local u_data = shields[u_key]

		if alive(u_data.unit) then
			self:unregister_shield(u_data.unit)
			u_data.unit:set_slot(0)
		end

		shields[u_key] = nil
	end

	enemy_data.nr_shields = nr_shields - nr_found

	if enemy_data.nr_shields > 0 then
		local delay = self:corpse_limit() < enemy_data.nr_shields and 0 or self._shield_disposal_upd_interval

		self:queue_task("EnemyManager._upd_shield_disposal", EnemyManager._upd_shield_disposal, self, t + delay)
	end
end

function EnemyManager:set_corpse_disposal_enabled(state)
	local was_enabled = self._corpse_disposal_enabled > 0
	self._corpse_disposal_enabled = self._corpse_disposal_enabled + (state and 1 or 0)

	if was_enabled and self._corpse_disposal_enabled < 0 then
		self:unqueue_task("EnemyManager._upd_corpse_disposal")
		self:unqueue_task("EnemyManager._upd_shield_disposal")
	elseif not was_enabled and self._corpse_disposal_enabled > 0 and self._enemy_data.nr_corpses > 0 then
		self:queue_task("EnemyManager._upd_corpse_disposal", EnemyManager._upd_corpse_disposal, self, TimerManager:game():time() + self._corpse_disposal_upd_interval)
		self:queue_task("EnemyManager._upd_shield_disposal", EnemyManager._upd_shield_disposal, self, TimerManager:game():time() + self._shield_disposal_upd_interval)
	end
end

function EnemyManager:is_corpse_disposal_enabled()
	return self._corpse_disposal_enabled > 0 and true
end

function EnemyManager:on_simulation_ended()
end

function EnemyManager:on_simulation_started()
	self._destroyed = nil
end

function EnemyManager:get_my_hostages(id)
	local civilians = self:all_civilians()
	local all_hostages = managers.groupai:state():all_hostages()
	local all_enemies = self:all_enemies()
	local list = {}

	for _, h_key in ipairs(all_hostages) do
		local civ = civilians[h_key]
		local hostage = civ or all_enemies[h_key]

		if hostage and hostage.unit and hostage.unit:brain() and hostage.unit:brain()._logic_data and hostage.unit:brain()._logic_data.internal_data and id == hostage.unit:brain()._logic_data.internal_data.aggressor_id then
			table.insert(list, hostage)
		end
	end

	return list
end

function EnemyManager:dispose_all_corpses()
	self._destroyed = true

	for key, corpse_data in pairs(self._enemy_data.corpses) do
		if alive(corpse_data.unit) then
			World:delete_unit(corpse_data.unit)
		end
	end

	if next(self._enemy_data.corpses) then
		debug_pause("[EnemyManager:dispose_all_corpses] there are still corpses in enemy manager\n", inspect(self._enemy_data.corpses))
	end
end

function EnemyManager:save(data)
	local my_data = nil

	if not managers.groupai:state():enemy_weapons_hot() then
		my_data = my_data or {}

		for u_key, u_data in pairs(self._enemy_data.corpses) do
			if u_data.unit:id() < 0 then
				my_data.corpses = my_data.corpses or {}
				local corpse_data = {
					u_data.u_id,
					u_data.unit:movement():m_pos(),
					u_data.is_civilian and true or false,
					u_data.unit:interaction():active() and true or false,
					u_data.unit:interaction().tweak_data,
					u_data.unit:contour():is_flashing()
				}

				table.insert(my_data.corpses, corpse_data)
			end
		end
	end

	data.enemy_manager = my_data
end

function EnemyManager:load(data)
	local my_data = data.enemy_manager

	if not my_data then
		return
	end

	if my_data.corpses then
		local civ_spawn_state = Idstring("civilian_death_dummy")
		local ene_spawn_state = Idstring("enemy_death_dummy")
		local civ_corpse_u_name = Idstring("units/payday2/characters/civ_male_dummy_corpse/civ_male_dummy_corpse")
		local ene_corpse_u_name = Idstring("units/payday2/characters/ene_dummy_corpse/ene_dummy_corpse")

		for _, corpse_data in pairs(my_data.corpses) do
			local u_id = corpse_data[1]
			local spawn_pos = corpse_data[2]
			local is_civilian = corpse_data[3]
			local interaction_active = corpse_data[4]
			local interaction_tweak_data = corpse_data[5]
			local contour_flashing = corpse_data[6]
			local grnd_ray = World:raycast("ray", spawn_pos + Vector3(0, 0, 50), spawn_pos - Vector3(0, 0, 100), "slot_mask", managers.slot:get_mask("AI_graph_obstacle_check"), "ray_type", "walk")

			if grnd_ray then
				spawn_pos = grnd_ray.position or spawn_pos
			end

			local corpse = World:spawn_unit(is_civilian and civ_corpse_u_name or ene_corpse_u_name, spawn_pos, Rotation(math.random() * 360, 0, 0))

			if corpse then
				corpse:play_state(is_civilian and civ_spawn_state or ene_spawn_state)
				corpse:interaction():set_tweak_data(interaction_tweak_data)
				corpse:interaction():set_active(interaction_active)

				if contour_flashing then
					corpse:interaction():set_outline_flash_state(contour_flashing, nil)
				end

				local mover_blocker_body = corpse:body("mover_blocker")

				if mover_blocker_body then
					mover_blocker_body:set_enabled(false)
				end

				corpse:base():add_destroy_listener("EnemyManager_corpse_dummy" .. tostring(corpse:key()), callback(self, self, is_civilian and "on_civilian_destroyed" or "on_enemy_destroyed"))

				self._enemy_data.corpses[corpse:key()] = {
					death_t = 0,
					unit = corpse,
					u_id = u_id,
					m_pos = corpse:position()
				}
				self._enemy_data.nr_corpses = self._enemy_data.nr_corpses + 1
			end
		end
	end
end

function EnemyManager:get_corpse_unit_data_from_key(u_key)
	return self._enemy_data.corpses[u_key]
end

function EnemyManager:get_corpse_unit_data_from_id(u_id)
	for u_key, u_data in pairs(self._enemy_data.corpses) do
		if u_id == u_data.u_id then
			return u_data
		end
	end
end

function EnemyManager:remove_corpse_by_id(u_id)
	for u_key, u_data in pairs(self._enemy_data.corpses) do
		if u_id == u_data.u_id then
			u_data.unit:set_slot(0)

			break
		end
	end
end

function EnemyManager:get_nearby_medic(unit)
	if self:is_civilian(unit) then
		return nil
	end

	local enemies = World:find_units_quick(unit, "sphere", unit:position(), tweak_data.medic.radius, managers.slot:get_mask("enemies"))

	for _, enemy in ipairs(enemies) do
		if enemy:base():has_tag("medic") then
			return enemy
		end
	end

	return nil
end

function EnemyManager:add_magazine(magazine, collision)
	self._magazines = self._magazines or {}

	table.insert(self._magazines, {
		magazine,
		collision
	})

	if EnemyManager.MAX_MAGAZINES < #self._magazines then
		self:cleanup_magazines()
	end
end

function EnemyManager:cleanup_magazines()
	for i = 1, #self._magazines - EnemyManager.MAX_MAGAZINES, 1 do
		for _, unit in ipairs(self._magazines[1]) do
			if alive(unit) then
				unit:set_slot(0)
			end
		end

		table.remove(self._magazines, 1)
	end
end
