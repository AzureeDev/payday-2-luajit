ActionSpooc = ActionSpooc or class()
ActionSpooc._walk_anim_velocities = CopActionWalk._walk_anim_velocities
ActionSpooc._walk_anim_lengths = CopActionWalk._walk_anim_lengths
ActionSpooc._matching_walk_anims = CopActionWalk._matching_walk_anims
ActionSpooc._walk_side_rot = CopActionWalk._walk_side_rot
ActionSpooc._anim_movement = CopActionWalk._anim_movement
ActionSpooc._get_max_walk_speed = CopActionWalk._get_max_walk_speed
ActionSpooc._get_current_max_walk_speed = CopActionWalk._get_current_max_walk_speed
ActionSpooc._global_incremental_action_ID = 1
ActionSpooc._apply_freefall = CopActionWalk._apply_freefall
ActionSpooc._tmp_vec1 = Vector3()
ActionSpooc._tmp_vec2 = Vector3()

function ActionSpooc:init(action_desc, common_data)
	self._common_data = common_data
	self._ext_movement = common_data.ext_movement
	self._ext_anim = common_data.ext_anim
	self._ext_base = common_data.ext_base
	self._ext_network = common_data.ext_network
	self._stance = common_data.stance
	self._machine = common_data.machine
	self._unit = common_data.unit

	if not self._ext_anim.pose then
		print("[ActionSpooc:init] no pose in anim", self._machine:segment_state(Idstring("base")), common_data.unit)
		common_data.ext_movement:play_redirect("idle")

		if not self._ext_anim.pose then
			debug_pause()

			return
		end
	end

	self._action_desc = action_desc
	self._nav_path = action_desc.nav_path or {
		mvector3.copy(common_data.pos)
	}

	self._ext_movement:enable_update()

	self._host_stop_pos_inserted = action_desc.host_stop_pos_inserted
	self._stop_pos = action_desc.stop_pos
	self._nav_index = action_desc.path_index or 1
	self._stroke_t = tonumber(action_desc.stroke_t)
	self._beating_end_t = self._stroke_t and self._stroke_t + math.lerp(self._common_data.char_tweak.spooc_attack_beating_time[1], self._common_data.char_tweak.spooc_attack_beating_time[2], math.random())
	self._strike_nav_index = action_desc.strike_nav_index
	self._haste = "run"
	self._nr_expected_nav_points = action_desc.nr_expected_nav_points
	self._last_vel_z = 0
	self._was_interrupted = action_desc.interrupted
	local is_server = Network:is_server()

	if is_server then
		self._action_id = ActionSpooc._global_incremental_action_ID

		if ActionSpooc._global_incremental_action_ID == 256 then
			ActionSpooc._global_incremental_action_ID = 1
		else
			ActionSpooc._global_incremental_action_ID = ActionSpooc._global_incremental_action_ID + 1
		end
	else
		self._action_id = action_desc.action_id
	end

	local is_local = nil

	if self._was_interrupted then
		is_local = action_desc.is_local

		if is_local then
			local attention = self._ext_movement:attention()
			self._target_unit = attention and attention.unit
		end
	else
		local attention = self._ext_movement:attention()

		if not attention then
			return
		end

		self._target_unit = attention and attention.unit
		is_local = alive(self._target_unit) and (self._target_unit:base().is_local_player or is_server and not self._target_unit:base().is_husk_player)
	end

	if not is_server then
		local host_stop_pos = self._ext_movement:m_host_stop_pos()

		if host_stop_pos ~= common_data.pos then
			table.insert(self._nav_path, 2, mvector3.copy(host_stop_pos))

			self._host_stop_pos_inserted = (self._host_stop_pos_inserted or 0) + 1
		end
	end

	self._is_local = is_local

	if is_local and self._target_unit and self._target_unit:base().is_local_player then
		self._target_unit:movement():on_targetted_for_attack(false, self._common_data.unit)
	end

	if is_server then
		self._ext_network:send("action_spooc_start", self._target_unit:movement():m_pos(), action_desc.flying_strike, self._action_id)
	end

	self._walk_velocity = self:_get_max_walk_speed()
	self._cur_vel = 0
	self._last_pos = mvector3.copy(common_data.pos)

	CopActionAct._create_blocks_table(self, action_desc.blocks)

	if self._was_interrupted then
		self._last_sent_pos = action_desc.last_sent_pos

		if self._nav_path[self._nav_index + 1] then
			self:_start_sprint()
		else
			self:_wait()
		end
	elseif is_local then
		if not is_server and self:_chk_target_invalid() then
			if not action_desc.flying_strike then
				self._last_sent_pos = mvector3.copy(common_data.pos)
			end

			self:_wait()
		elseif action_desc.flying_strike then
			if is_server or ActionSpooc.chk_can_start_flying_strike(self._unit, self._target_unit) then
				self:_set_updator("_upd_flying_strike_first_frame")
			else
				self._ext_network:send_to_host("action_spooc_stop", self._ext_movement:m_pos(), 1, self._action_id)
				self:_wait()
			end
		else
			if action_desc.target_u_pos then
				table.insert(self._nav_path, action_desc.target_u_pos)
			end

			self._chase_tracker = self._target_unit:movement():nav_tracker()
			local chase_pos = self._chase_tracker:field_position()

			table.insert(self._nav_path, chase_pos)

			self._last_sent_pos = mvector3.copy(common_data.pos)

			self:_start_sprint()
		end
	else
		self:_wait()
	end

	self._unit:sound():play(self:get_sound_event("detect"))
	self._unit:damage():run_sequence_simple("turn_on_spook_lights")

	local r = LevelsTweakData.LevelType.Russia
	local ai_type = tweak_data.levels:get_ai_group_type()
	self._taunt_during_assault = "cloaker_taunt_during_assault"
	self._taunt_after_assault = "cloaker_taunt_after_assault"

	if ai_type == r then
		self._taunt_during_assault = "rcloaker_taunt_during_assault"
		self._taunt_after_assault = "rcloaker_taunt_after_assault"
	end

	local spooc_sound_events = self._common_data.char_tweak.spooc_sound_events or {}
	self._taunt_during_assault = spooc_sound_events.taunt_during_assault or self._taunt_during_assault
	self._taunt_after_assault = spooc_sound_events.taunt_after_assault or self._taunt_after_assault

	return true
end

function ActionSpooc:on_exit()
	if self._unit:character_damage():dead() then
		self._unit:sound():play(self:get_sound_event("detect_stop"))
	else
		self._unit:sound():play(self._unit:base():char_tweak().spawn_sound_event)

		if self._is_local and self._taunt_at_beating_played and not self._unit:sound():speaking(TimerManager:game():time()) then
			self._unit:sound():say(self._taunt_after_assault, true, true)
		end
	end

	self._unit:damage():run_sequence_simple("kill_spook_lights")

	if self._root_blend_disabled then
		self._ext_movement:set_root_blend(true)
	end

	if self._expired and self._common_data.ext_anim.move then
		self:_stop_walk()
	end

	self._ext_movement:drop_held_items()

	if Network:is_server() then
		local stop_nav_index = math.min(256, self._nav_index - (self._host_stop_pos_inserted or 0))

		self._ext_network:send("action_spooc_stop", mvector3.copy(self._ext_movement:m_pos()), stop_nav_index, self._action_id)
	else
		self._ext_movement:set_m_host_stop_pos(self._ext_movement:m_pos())
	end

	if alive(self._target_unit) and self._target_unit:base().is_local_player then
		self._target_unit:movement():on_targetted_for_attack(false, self._common_data.unit)
	end
end

function ActionSpooc:_chk_can_strike()
	if self._stroke_t then
		return
	end

	local my_pos = self._common_data.pos
	local target_pos = self._tmp_vec1

	self._chase_tracker:m_position(target_pos)

	local function _dis_chk(pos)
		mvector3.subtract(pos, my_pos)

		local dif_z = math.abs(mvector3.z(pos))

		mvector3.set_z(pos, 0)

		return mvector3.length_sq(pos) < 52900 and dif_z < 75
	end

	if not _dis_chk(target_pos) then
		return
	end

	mvector3.set(target_pos, self._nav_path[#self._nav_path])

	if _dis_chk(target_pos) then
		return true
	end
end

function ActionSpooc:_chk_target_invalid()
	if not self._target_unit then
		return true
	end

	if self._target_unit:base().is_local_player and not self._target_unit:movement():is_SPOOC_attack_allowed() then
		return true
	end

	if self._target_unit:movement():zipline_unit() then
		return true
	end

	local record = managers.groupai:state():criminal_record(self._target_unit:key())

	if not record or record.status then
		return true
	end
end

function ActionSpooc:_start_sprint()
	CopActionWalk._chk_start_anim(self, self._nav_path[self._nav_index + 1])

	if self._start_run then
		self:_set_updator("_upd_start_anim_first_frame")
	else
		self:_set_updator("_upd_sprint")
		self._common_data.unit:base():chk_freeze_anims()
	end
end

function ActionSpooc:_strike()
	self._strike_now = nil

	self:_set_updator("_upd_strike_first_frame")
end

function ActionSpooc:_wait()
	self._end_of_path = true

	self:_set_updator("_upd_wait")

	if self._ext_anim.move then
		self:_stop_walk()
	end
end

function ActionSpooc:_upd_strike_first_frame(t)
	if self._is_local and self:_chk_target_invalid() then
		if Network:is_server() then
			self:_expire()
		else
			self:_wait()
		end

		return
	end

	local redir_result = self._ext_movement:play_redirect("spooc_strike")

	if redir_result then
		self._ext_movement:spawn_wanted_items()
	elseif self._is_local then
		if Network:is_server() then
			self:_expire()
		else
			self._ext_network:send_to_host("action_spooc_stop", self._ext_movement:m_pos(), 1, self._action_id)
			self:_wait()
		end

		return
	end

	if self._is_local then
		mvector3.set(self._last_sent_pos, self._common_data.pos)
		self._ext_network:send("action_spooc_strike", mvector3.copy(self._common_data.pos), self._action_id)

		self._nav_path[self._nav_index + 1] = mvector3.copy(self._common_data.pos)

		if self._target_unit:base().is_local_player then
			local enemy_vec = mvector3.copy(self._common_data.pos)

			mvector3.subtract(enemy_vec, self._target_unit:movement():m_pos())
			mvector3.set_z(enemy_vec, 0)
			mvector3.normalize(enemy_vec)
			self._target_unit:camera():camera_unit():base():clbk_aim_assist({
				ray = enemy_vec
			})
		end
	end

	self._last_vel_z = 0

	self:_set_updator("_upd_striking")
	self._common_data.unit:base():chk_freeze_anims()
end

function ActionSpooc:_upd_chase_path()
	self._chase_tracker = self._chase_tracker or self._target_unit:movement():nav_tracker()
	local ray_params = {
		allow_entry = true,
		trace = true,
		tracker_from = self._common_data.nav_tracker,
		tracker_to = self._chase_tracker
	}
	local chase_pos = nil
	local chasing_lost = self._chase_tracker:lost()

	if chasing_lost then
		chase_pos = self._chase_tracker:field_position()
		ray_params.pos_to = chase_pos
	else
		chase_pos = self._chase_tracker:position()
	end

	local simplified = nil

	if self._nav_index < #self._nav_path - 1 then
		local walk_ray = managers.navigation:raycast(ray_params)

		if not walk_ray then
			simplified = true

			for i = self._nav_index + 2, #self._nav_path, 1 do
				table.remove(self._nav_path)
			end
		end
	end

	local walk_ray = nil

	if not simplified then
		ray_params.tracker_from = nil
		ray_params.pos_from = self._nav_path[math.max(1, #self._nav_path - 1)]
		walk_ray = managers.navigation:raycast(ray_params)
	end

	if walk_ray then
		table.insert(self._nav_path, mvector3.copy(chase_pos))
	else
		mvector3.set(self._nav_path[#self._nav_path], ray_params.trace[1])
	end
end

function ActionSpooc:_upd_sprint(t)
	if self._is_local and not self._was_interrupted then
		if self:_chk_target_invalid() then
			if Network:is_server() then
				self:_expire()
			else
				self:_wait()
			end

			return
		end

		self:_upd_chase_path()

		if self:_chk_can_strike() then
			self:_strike()

			return
		end
	end

	local dt = TimerManager:game():delta_time()

	if self._end_of_path then
		if self._stop_pos or Network:is_server() and self._stroke_t then
			self:_expire()
		else
			self:_wait()
		end
	else
		self:_nav_chk(t, dt)
	end

	local move_dir = self._last_pos - self._common_data.pos

	mvector3.set_z(move_dir, 0)

	if self._cur_vel < 0.1 then
		move_dir = nil
	end

	self._move_dir = move_dir
	local anim_data = self._ext_anim
	local face_fwd, face_right = nil

	if self._move_dir then
		local attention = self._attention

		if attention then
			if attention.unit then
				face_fwd = attention.unit:movement():m_pos() - self._common_data.pos
			else
				face_fwd = attention.pos - self._common_data.pos
			end
		else
			face_fwd = self._move_dir
		end

		local move_dir_norm = self._move_dir:normalized()

		mvector3.set_z(face_fwd, 0)
		mvector3.normalize(face_fwd)

		face_right = face_fwd:cross(math.UP)

		mvector3.normalize(face_right)

		local right_dot = mvector3.dot(move_dir_norm, face_right)
		local fwd_dot = mvector3.dot(move_dir_norm, face_fwd)
		local wanted_walk_dir = nil

		if math.abs(right_dot) < math.abs(fwd_dot) then
			if (anim_data.move_l and right_dot < 0 or anim_data.move_r and right_dot > 0) and math.abs(fwd_dot) < 0.73 then
				wanted_walk_dir = anim_data.move_side
			elseif fwd_dot > 0 then
				wanted_walk_dir = "fwd"
			else
				wanted_walk_dir = "bwd"
			end
		elseif (anim_data.move_fwd and fwd_dot > 0 or anim_data.move_bwd and fwd_dot < 0) and math.abs(right_dot) < 0.73 then
			wanted_walk_dir = anim_data.move_side
		elseif right_dot > 0 then
			wanted_walk_dir = "r"
		else
			wanted_walk_dir = "l"
		end

		local wanted_u_fwd = self._move_dir:rotate_with(self._walk_side_rot[wanted_walk_dir])
		local rot_new = self._common_data.rot:slerp(Rotation(wanted_u_fwd, math.UP), math.min(1, dt * 5))

		self._ext_movement:set_rotation(rot_new)

		local pose = self._stance.values[4] > 0 and "wounded" or self._ext_anim.pose or "stand"
		local real_velocity = self._cur_vel
		local variant = nil

		if self._ext_anim.sprint then
			if real_velocity > 480 and self._ext_anim.pose == "stand" then
				variant = "sprint"
			elseif real_velocity > 250 then
				variant = "run"
			else
				variant = "walk"
			end
		elseif self._ext_anim.run then
			if real_velocity > 530 and self._walk_anim_velocities[pose][self._stance.name].sprint and self._ext_anim.pose == "stand" then
				variant = "sprint"
			elseif real_velocity > 250 then
				variant = "run"
			else
				variant = "walk"
			end
		elseif real_velocity > 530 and self._walk_anim_velocities[pose][self._stance.name].sprint and self._ext_anim.pose == "stand" then
			variant = "sprint"
		elseif real_velocity > 300 then
			variant = "run"
		else
			variant = "walk"
		end

		self:_adjust_move_anim(wanted_walk_dir, variant)

		local pose = self._ext_anim.pose
		local anim_walk_speed = self._walk_anim_velocities[pose][self._common_data.stance.name][variant][wanted_walk_dir]
		local wanted_walk_anim_speed = real_velocity / anim_walk_speed

		self:_adjust_walk_anim_speed(dt, wanted_walk_anim_speed)
	end

	self:_set_new_pos(dt)

	if self._strike_now then
		self:_strike()
	end
end

function ActionSpooc:_upd_start_anim_first_frame(t)
	local pose = self._ext_anim.pose
	local speed_mul = self._walk_velocity.fwd / self._walk_anim_velocities[pose][self._common_data.stance.name].run.fwd

	self:_start_move_anim(self._start_run_turn and self._start_run_turn[3] or self._start_run_straight, "run", speed_mul, self._start_run_turn)
	self:_set_updator("_upd_start_anim")
	self._common_data.unit:base():chk_freeze_anims()
end

function ActionSpooc:_upd_start_anim(t)
	if self._is_local and not self._was_interrupted then
		if self:_chk_target_invalid() then
			if Network:is_server() then
				self:_expire()
			else
				self:_wait()
			end

			return
		end

		self:_upd_chase_path()

		if self:_chk_can_strike() then
			self:_strike()

			return
		end
	end

	if not self._ext_anim.run_start then
		self._start_run = nil
		self._start_run_turn = nil
		self._start_run_straight = nil
		self._last_pos = mvector3.copy(self._common_data.pos)

		self:_set_updator("_upd_sprint")
		self:update(t)

		return
	end

	local dt = TimerManager:game():delta_time()

	if self._start_run_turn then
		local seg_rel_t = self._machine:segment_relative_time(Idstring("base"))

		if seg_rel_t > 0.1 then
			local delta_pos = self._common_data.unit:get_animation_delta_position()

			mvector3.multiply(delta_pos, 2)

			if seg_rel_t > 0.6 then
				if self._correct_vel_from then
					local lerp = (math.clamp(seg_rel_t, 0, 0.9) - 0.6) / 0.3
					self._cur_vel = math.lerp(self._correct_vel_from, self._walk_velocity.fwd, lerp)
				else
					self._correct_vel_from = self._cur_vel
				end

				mvector3.set_length(delta_pos, self._cur_vel * dt)
			else
				self._cur_vel = delta_pos:length() / dt
			end

			local new_pos = self._common_data.pos + delta_pos
			local ray_params = {
				allow_entry = true,
				trace = true,
				tracker_from = self._common_data.nav_tracker,
				pos_to = new_pos
			}
			local collision_pos = managers.navigation:raycast(ray_params)

			if collision_pos then
				new_pos = ray_params.trace[1]
			end

			self._last_pos = new_pos
			local seg_rel_t_clamp = math.clamp((seg_rel_t - 0.1) / 0.77, 0, 1)
			local prg_angle = self._start_run_turn[2] * seg_rel_t_clamp
			local new_yaw = self._start_run_turn[1] + prg_angle
			local rot_new = Rotation(new_yaw, 0, 0)

			self._ext_movement:set_rotation(rot_new)
		end
	else
		if self._end_of_path then
			self._start_run = nil

			if self._stop_pos or Network:is_server() and self._stroke_t then
				self:_expire()
			else
				self:_wait()
			end

			return
		else
			self:_nav_chk(t, dt)
		end

		if not self._end_of_path then
			local move_dir = self._nav_path[self._nav_index + 1] - self._common_data.pos
			local wanted_u_fwd = move_dir:rotate_with(self._walk_side_rot[self._start_run_straight])
			local rot_new = self._common_data.rot:slerp(Rotation(wanted_u_fwd, math.UP), math.min(1, dt * 5))

			mrotation.set_yaw_pitch_roll(rot_new, rot_new:yaw(), 0, 0)
			self._ext_movement:set_rotation(rot_new)
		end
	end

	self:_set_new_pos(dt)

	if self._strike_now then
		self:_strike()

		self._start_run = nil
		self._start_run_turn = nil
		self._start_run_straight = nil

		return
	end
end

function ActionSpooc:_set_new_pos(dt)
	CopActionWalk._set_new_pos(self, dt)
end

function ActionSpooc:type()
	return "spooc"
end

function ActionSpooc:get_husk_interrupt_desc()
	local old_action_desc = {
		block_type = "walk",
		interrupted = true,
		type = "spooc",
		body_part = 1,
		stop_pos = self._stop_pos,
		path_index = self._nav_index,
		nav_path = self._nav_path,
		strike_nav_index = self._strike_nav_index,
		stroke_t = self._stroke_t or self._is_local and true,
		host_stop_pos_inserted = self._host_stop_pos_inserted,
		nr_expected_nav_points = self._nr_expected_nav_points,
		flying_strike = self._action_desc.flying_strike,
		is_local = self._is_local,
		action_id = self._action_id,
		last_sent_pos = self._last_sent_pos
	}

	if self._blocks then
		local blocks = {}

		for i, k in pairs(self._blocks) do
			blocks[i] = -1
		end

		old_action_desc.blocks = blocks
	end

	return old_action_desc
end

function ActionSpooc:expired()
	return self._expired
end

function ActionSpooc:_expire()
	self._expired = true
end

function ActionSpooc:save(save_data)
	save_data.type = "spooc"
	save_data.body_part = 1
	save_data.block_type = "walk"
	save_data.interrupted = true
	save_data.stop_pos = self._stop_pos
	save_data.path_index = self._nav_index
	save_data.strike_nav_index = self._strike_nav_index
	save_data.blocks = {
		act = -1,
		idle = -1,
		turn = -1,
		walk = -1
	}
	save_data.action_id = self._action_id
	local t_ins = table.insert
	local sync_path = {}
	local nav_path = self._nav_path

	for i = 1, self._nav_index + 1, 1 do
		local nav_point = nav_path[i]

		t_ins(sync_path, nav_point)
	end

	save_data.nav_path = sync_path
end

function ActionSpooc:_nav_chk(t, dt)
	local path = self._nav_path
	local old_nav_index = self._nav_index
	local vel = self:_get_current_max_walk_speed(self._ext_anim.move_side or "fwd")
	local walk_dis = vel * dt
	local cur_pos = self._common_data.pos
	local new_pos, complete, new_nav_index = nil

	mvector3.set(path[old_nav_index], cur_pos)

	new_pos, new_nav_index, complete = CopActionWalk._walk_spline(path, cur_pos, old_nav_index, walk_dis)

	if not self._stroke_t and self._strike_nav_index and (self._strike_nav_index <= new_nav_index or complete and self._strike_nav_index == new_nav_index + 1) then
		new_nav_index = self._strike_nav_index - 1
		new_pos = mvector3.copy(path[self._strike_nav_index])
		self._strike_now = true
	end

	if complete then
		self._end_of_path = true
	end

	self._nav_index = new_nav_index
	local wanted_vel = nil

	if self._turn_vel then
		local dis = mvector3.distance(path[old_nav_index + 1]:with_z(cur_pos.z), cur_pos)

		if dis < 70 then
			wanted_vel = math.lerp(self._turn_vel, vel, dis / 70)
		end
	end

	wanted_vel = wanted_vel or vel

	if self._start_run then
		local delta_pos = self._common_data.unit:get_animation_delta_position()
		walk_dis = 2 * delta_pos:length()
		self._cur_vel = walk_dis / dt
	else
		local c_vel = self._cur_vel

		if c_vel ~= wanted_vel then
			local adj = vel * 2 * dt
			c_vel = math.step(c_vel, wanted_vel, adj)
			self._cur_vel = c_vel
		end

		walk_dis = c_vel * dt
	end

	if old_nav_index ~= new_nav_index then
		if self._is_local and not self._was_interrupted then
			self:_send_nav_point(mvector3.copy(path[old_nav_index]))
		end

		local future_pos = path[new_nav_index + 2]
		local next_pos = path[new_nav_index + 1]
		local back_pos = path[new_nav_index]
		local cur_vec = next_pos - back_pos

		mvector3.set_z(cur_vec, 0)

		if future_pos then
			mvector3.normalize(cur_vec)

			local next_vec = future_pos - next_pos

			mvector3.set_z(next_vec, 0)
			mvector3.normalize(next_vec)

			local turn_dot = mvector3.dot(cur_vec, next_vec)
			local dot_lerp = math.max(0, turn_dot)
			local turn_vel = math.lerp(math.min(vel, math.max(100, vel * 0.3)), vel, dot_lerp)
			self._turn_vel = turn_vel
		end
	elseif self._is_local and not self._was_interrupted and mvector3.distance(self._last_sent_pos, cur_pos) > 200 then
		self._nav_index = self._nav_index + 1

		table.insert(self._nav_path, self._nav_index, mvector3.copy(cur_pos))
		self:_send_nav_point(cur_pos)
	end

	self._last_pos = mvector3.copy(new_pos)
end

function ActionSpooc:_adjust_walk_anim_speed(dt, target_speed)
	local state = self._machine:segment_state(Idstring("base"))

	self._machine:set_speed(state, target_speed)
end

function ActionSpooc:_adjust_move_anim(...)
	return CopActionWalk._adjust_move_anim(self, ...)
end

function ActionSpooc:_start_move_anim(...)
	return CopActionWalk._start_move_anim(self, ...)
end

function ActionSpooc:_stop_walk()
	return CopActionWalk._stop_walk(self)
end

function ActionSpooc:_upd_wait(t)
	if self._ext_anim.move then
		self:_stop_walk()
	end

	if self._is_local and not self._was_interrupted and not self._action_desc.flying_strike and not self:_chk_target_invalid() then
		self:_upd_chase_path()

		if self._end_of_path and self._nav_index < #self._nav_path then
			self._end_of_path = nil

			self:_start_sprint()
		end
	end
end

function ActionSpooc:_upd_striking(t)
	local target_unit = alive(self._strike_unit) and self._strike_unit or alive(self._target_unit) and self._target_unit
	local my_pos = CopActionHurt._get_pos_clamped_to_graph(self, false)

	if target_unit then
		local my_fwd = self._common_data.fwd
		local target_pos = target_unit:movement():m_pos()
		local target_vec = ActionSpooc._tmp_vec1

		mvector3.direction(target_vec, my_pos, target_pos)

		if mvector3.dot(my_fwd, target_vec) < 0.98 then
			local my_fwd_polar = my_fwd:to_polar_with_reference(target_vec, math.UP)
			local spin_adj = math.step(0, -my_fwd_polar.spin, (self._ext_anim.spooc_enter and 180 or 110) * TimerManager:game():delta_time())

			mvector3.set(target_vec, my_fwd)
			mvector3.rotate_with(target_vec, Rotation(spin_adj, 0, 0))
			self._ext_movement:set_rotation(Rotation(target_vec, math.UP))
		end
	end

	self._ext_movement:upd_ground_ray(my_pos, true)

	local gnd_z = self._common_data.gnd_ray.position.z

	if gnd_z < my_pos.z then
		self._last_vel_z = self._apply_freefall(my_pos, self._last_vel_z, gnd_z, TimerManager:game():delta_time())
	else
		if my_pos.z < gnd_z then
			mvector3.set_z(my_pos, gnd_z)
		end

		self._last_vel_z = 0
	end

	self._ext_movement:set_position(my_pos)

	if self._ext_anim.spooc_enter then
		return
	end

	if self._is_local and not self._was_interrupted and (not target_unit or not target_unit:character_damage():is_downed()) then
		if Network:is_server() then
			self:_expire()
		else
			self._ext_network:send_to_host("action_spooc_stop", self._ext_movement:m_pos(), 1, self._action_id)
			self:_wait()
		end

		return
	end

	if not self._taunt_at_beating_played then
		self._taunt_at_beating_played = true

		self._unit:sound():say(self._taunt_during_assault, nil, true)
	end
end

function ActionSpooc:sync_stop(pos, stop_nav_index)
	if self._action_desc.flying_strike then
		self:_expire()
	else
		if self._host_stop_pos_inserted then
			stop_nav_index = stop_nav_index + self._host_stop_pos_inserted
		end

		local nav_path = self._nav_path

		while stop_nav_index < #nav_path do
			table.remove(nav_path)
		end

		self._stop_pos = pos

		if #nav_path < stop_nav_index - 1 then
			self._nr_expected_nav_points = stop_nav_index - #nav_path + 1
		else
			table.insert(nav_path, pos)
		end

		self._nav_index = math.min(self._nav_index, #nav_path - 1)

		if self._end_of_path and not self._nr_expected_nav_points then
			self._end_of_path = nil

			self:_start_sprint()
		end
	end
end

function ActionSpooc:sync_append_nav_point(nav_point)
	if self._stop_pos and not self._nr_expected_nav_points then
		return
	end

	table.insert(self._nav_path, nav_point)

	if self._action_desc.flying_strike then
		self:_set_updator("_upd_flying_strike_first_frame")
	elseif self._end_of_path then
		self._end_of_path = nil
		local nav_index = math.min(#self._nav_path - 1, self._nav_index + 1)
		self._nav_index = nav_index
		self._cur_vel = 0

		if self._nr_expected_nav_points then
			if self._nr_expected_nav_points == 1 then
				self._nr_expected_nav_points = nil

				table.insert(self._nav_path, self._stop_pos)
			else
				self._nr_expected_nav_points = self._nr_expected_nav_points - 1
			end
		end

		self:_start_sprint()
	end
end

function ActionSpooc:sync_strike(pos)
	if self._stop_pos and not self._nr_expected_nav_points then
		return
	end

	table.insert(self._nav_path, pos)

	self._strike_nav_index = #self._nav_path

	if self._nr_expected_nav_points then
		if self._nr_expected_nav_points == 1 then
			self._nr_expected_nav_points = nil

			table.insert(self._nav_path, self._stop_pos)
		else
			self._nr_expected_nav_points = self._nr_expected_nav_points - 1
		end
	end

	if self._end_of_path then
		self._end_of_path = nil
		self._cur_vel = 0

		self:_start_sprint()
	end
end

function ActionSpooc:chk_block(action_type, t)
	return CopActionAct.chk_block(self, action_type, t)
end

function ActionSpooc:chk_block_client(action_desc, action_type, t)
	if CopActionAct.chk_block(self, action_type, t) and (not action_desc or action_desc.body_part ~= 3) then
		return true
	end
end

function ActionSpooc:need_upd()
	return true
end

function ActionSpooc:_send_nav_point(nav_point)
	self._ext_network:send("action_spooc_nav_point", nav_point, self._action_id)

	if self._last_sent_pos then
		mvector3.set(self._last_sent_pos, nav_point)
	end
end

function ActionSpooc:_set_updator(name)
	self.update = self[name]
end

function ActionSpooc:on_attention(attention)
	if self._target_unit and attention and attention.unit and attention.unit:key() == self._target_unit:key() then
		return
	end

	if alive(self._target_unit) and self._target_unit:base().is_local_player then
		self._target_unit:movement():on_targetted_for_attack(false, self._common_data.unit)
	end

	self._target_unit = nil
end

function ActionSpooc:complete()
	return self._beating_end_t and self._beating_end_t < TimerManager:game():time() and self._last_vel_z >= 0
end

function ActionSpooc:action_id()
	return self._action_id
end

function ActionSpooc:anim_act_clbk(anim_act)
	if anim_act == "strike" then
		local sound_string = "clk_punch_3rd_person_3p"

		if self._stroke_t then
			if self._strike_unit then
				self._unit:sound():say(sound_string, true, true)
			end

			return
		end

		self._stroke_t = TimerManager:game():time()

		self._unit:sound():play(self:get_sound_event("detect_stop"))

		if not self._is_local then
			self._unit:sound():say(sound_string, true, true)

			self._beating_end_t = self._stroke_t + 1

			if Global.game_settings.difficulty == "sm_wish" then
				MutatorCloakerEffect.effect_smoke(nil, self._unit)
			end

			managers.mutators:_run_func("OnPlayerCloakerKicked", self._unit)
			managers.modifiers:run_func("OnPlayerCloakerKicked", self._unit)

			return
		end

		if self:_chk_target_invalid() then
			if Network:is_server() then
				self:_expire()
			else
				self:_wait()
			end

			return
		end

		local target_vec = self._tmp_vec1

		mvector3.set(target_vec, self._target_unit:movement():m_com())
		mvector3.subtract(target_vec, self._common_data.pos)

		local target_dis_z = math.abs(mvector3.z(target_vec))

		if target_dis_z > 200 then
			if not self:is_flying_strike() then
				if Network:is_server() then
					self:_expire()
				else
					self:_wait()
				end
			end

			return
		end

		mvector3.set_z(target_vec, 0)

		if self:is_flying_strike() then
			local angle = mvector3.angle(target_vec, self._common_data.fwd)
			local max_dis = math.lerp(170, 70, math.clamp(angle, 0, 90) / 90)
			local target_dis_xy = mvector3.normalize(target_vec)

			if max_dis < target_dis_xy then
				if not self:is_flying_strike() then
					if Network:is_server() then
						self:_expire()
					else
						self:_wait()
					end
				end

				return
			end
		end

		self._strike_unit = self._target_unit
		local spooc_res = self._strike_unit:movement():on_SPOOCed(self._unit, self:is_flying_strike() and "flying_strike" or "sprint_attack")

		if Global.game_settings.difficulty == "sm_wish" then
			MutatorCloakerEffect.effect_smoke(nil, self._unit)
		end

		managers.mutators:_run_func("OnPlayerCloakerKicked", self._unit)
		managers.modifiers:run_func("OnPlayerCloakerKicked", self._unit)

		if spooc_res == "countered" then
			if not Network:is_server() then
				self._ext_network:send_to_host("action_spooc_stop", self._ext_movement:m_pos(), 1, self._action_id)
			end

			self._blocks = {}
			local action_data = {
				damage_effect = 1,
				damage = 0,
				variant = "counter_spooc",
				attacker_unit = self._strike_unit,
				col_ray = {
					body = self._unit:body("body"),
					position = self._common_data.pos + math.UP * 100
				},
				attack_dir = -1 * target_vec:normalized(),
				name_id = managers.blackmarket:equipped_melee_weapon()
			}

			self._unit:character_damage():damage_melee(action_data)

			return
		elseif not self:is_flying_strike() then
			if spooc_res and self._strike_unit:character_damage():is_downed() then
				self._beating_end_t = self._stroke_t + math.lerp(self._common_data.char_tweak.spooc_attack_beating_time[1], self._common_data.char_tweak.spooc_attack_beating_time[2], math.random())
			elseif not Network:is_server() then
				self._ext_network:send_to_host("action_spooc_stop", self._ext_movement:m_pos(), 1, self._action_id)
			end

			return
		end

		self._unit:sound():say(sound_string, true, true)

		if self._strike_unit:base().is_local_player then
			self:_play_strike_camera_shake()
			mvector3.negate(target_vec)

			local dot_fwd = mvector3.dot(target_vec, self._common_data.fwd)
			local dot_r = mvector3.dot(target_vec, self._common_data.right)

			if math.abs(dot_r) < math.abs(dot_fwd) then
				if dot_fwd > 0 then
					managers.environment_controller:hit_feedback_front()
				else
					managers.environment_controller:hit_feedback_back()
				end
			elseif dot_r > 0 then
				managers.environment_controller:hit_feedback_right()
			else
				managers.environment_controller:hit_feedback_left()
			end
		end

		if not self:is_flying_strike() then
			mvector3.set(self._last_sent_pos, self._common_data.pos)
			self._ext_network:send("action_spooc_strike", mvector3.copy(self._common_data.pos), self._action_id)

			self._nav_path[self._nav_index + 1] = mvector3.copy(self._common_data.pos)
		end
	end
end

function ActionSpooc.chk_can_start_spooc_sprint(unit, target_unit)
	local enemy_tracker = target_unit:movement():nav_tracker()
	local ray_params = {
		allow_entry = true,
		trace = true,
		tracker_from = unit:movement():nav_tracker(),
		tracker_to = enemy_tracker
	}

	if enemy_tracker:lost() then
		ray_params.pos_to = enemy_tracker:field_position()
	end

	local col_ray = managers.navigation:raycast(ray_params)

	if col_ray then
		return
	end

	local z_diff_abs = math.abs(ray_params.trace[1].z - target_unit:movement():m_pos().z)

	if z_diff_abs > 200 then
		return
	end

	local ray_from = ActionSpooc._tmp_vec1
	local ray_to = ActionSpooc._tmp_vec2

	mvector3.set(ray_from, math.UP)
	mvector3.set_z(ray_from, 120)

	local ray_to = ActionSpooc._tmp_vec2

	mvector3.set(ray_to, ray_from)
	mvector3.add(ray_from, unit:movement():m_pos())
	mvector3.add(ray_to, target_unit:movement():m_pos())

	local ray = World:raycast("ray", ray_from, ray_to, "slot_mask", managers.slot:get_mask("AI_graph_obstacle_check"), "ray_type", "walk")

	if ray then
		return
	end

	return true
end

function ActionSpooc.chk_can_start_flying_strike(unit, target_unit)
	local target_pos = target_unit:movement():m_pos()
	local my_pos = unit:movement():m_pos()
	local target_vec = ActionSpooc._tmp_vec1

	mvector3.set(target_vec, target_pos)
	mvector3.subtract(target_vec, my_pos)

	local target_dis = mvector3.length(target_vec)

	if target_dis > 600 then
		return
	end

	mvector3.set_z(target_vec, 0)
	mvector3.normalize(target_vec)

	local my_fwd = unit:movement():m_fwd()
	local dot = mvector3.dot(target_vec, my_fwd)

	if dot < 0.6 then
		return
	end

	local ray_from = ActionSpooc._tmp_vec1

	mvector3.set(ray_from, my_pos)
	mvector3.set_z(ray_from, mvector3.z(ray_from) + 160)

	local ray_to = ActionSpooc._tmp_vec2

	mvector3.set(ray_to, target_pos)
	mvector3.set_z(ray_to, mvector3.z(ray_to) + 160)
	mvector3.lerp(ray_to, ray_from, ray_to, 0.5)
	mvector3.set_z(ray_to, mvector3.z(ray_to) + 50)

	local sphere_radius = 25
	local ray = World:raycast("ray", ray_from, ray_to, "sphere_cast_radius", sphere_radius, "bundle", 5, "slot_mask", managers.slot:get_mask("AI_graph_obstacle_check"), "ray_type", "walk")

	if ray then
		return
	end

	mvector3.set(ray_from, target_pos)
	mvector3.set_z(ray_from, mvector3.z(ray_from) + 160)

	local ray = World:raycast("ray", ray_from, ray_to, "sphere_cast_radius", sphere_radius, "bundle", 5, "slot_mask", managers.slot:get_mask("AI_graph_obstacle_check"), "ray_type", "walk")

	if ray then
		return
	end

	return true
end

function ActionSpooc:_upd_flying_strike_first_frame(t)
	local target_pos = nil

	if self._is_local then
		target_pos = self._target_unit:movement():m_pos()

		self:_send_nav_point(target_pos)
	else
		target_pos = self._nav_path[#self._nav_path]
	end

	local my_pos = self._unit:movement():m_pos()
	local target_vec = self._tmp_vec1

	mvector3.set(target_vec, target_pos)
	mvector3.subtract(target_vec, my_pos)

	local target_dis = mvector3.length(target_vec)
	local redir_result = self._ext_movement:play_redirect("spooc_flying_strike")

	if not redir_result then
		debug_pause_unit(self._unit, "[ActionSpooc:_chk_start_flying_strike] failed redirect spooc_flying_strike in ", self._machine:segment_state(Idstring("base")), self._unit)

		return
	end

	self._ext_movement:spawn_wanted_items()

	local anim_travel_dis_xy = 470
	self._flying_strike_data = {
		start_pos = mvector3.copy(my_pos),
		start_rot = self._unit:rotation(),
		target_pos = mvector3.copy(target_pos),
		target_rot = Rotation(target_vec:with_z(0), math.UP),
		start_t = TimerManager:game():time(),
		travel_dis_scaling_xy = target_dis / anim_travel_dis_xy
	}
	local speed_mul = math.lerp(3, 1, math.min(1, self._flying_strike_data.travel_dis_scaling_xy))

	self._machine:set_speed(redir_result, speed_mul)

	if alive(self._target_unit) and self._target_unit:base().is_local_player then
		local enemy_vec = mvector3.copy(self._common_data.pos)

		mvector3.subtract(enemy_vec, self._target_unit:movement():m_pos())
		mvector3.set_z(enemy_vec, 0)
		mvector3.normalize(enemy_vec)
		self._target_unit:camera():camera_unit():base():clbk_aim_assist({
			ray = enemy_vec
		})
	end

	self:_set_updator("_upd_flying_strike")
end

function ActionSpooc:_upd_flying_strike(t)
	if self._ext_anim.act then
		local strike_data = self._flying_strike_data
		local seg_rel_t = self._machine:segment_relative_time(Idstring("base"))
		local rot_correction_period = 0.07

		if seg_rel_t < rot_correction_period then
			local prog_lerp = (rot_correction_period - seg_rel_t) / rot_correction_period

			self._ext_movement:set_rotation(strike_data.start_rot:slerp(strike_data.target_rot, prog_lerp))
		elseif not strike_data.is_rot_aligned then
			self._ext_movement:set_rotation(strike_data.target_rot)
		end

		local delta_pos = self._common_data.unit:get_animation_delta_position()
		local delta_z = mvector3.z(delta_pos)

		mvector3.set_static(delta_pos, mvector3.x(delta_pos) * strike_data.travel_dis_scaling_xy, mvector3.y(delta_pos) * strike_data.travel_dis_scaling_xy, delta_z)

		local new_pos = delta_pos

		mvector3.add(new_pos, self._common_data.pos)

		if self._stroke_t then
			if self._common_data.nav_tracker:lost() then
				local safe_pos = self._common_data.nav_tracker:field_position()

				mvector3.set_z(safe_pos, mvector3.z(self._common_data.pos))

				local dis_before = mvector3.distance_sq(safe_pos, self._common_data.pos)
				local dis_now = mvector3.distance_sq(self._common_data.pos, new_pos)

				if dis_before < dis_now then
					mvector3.set_static(new_pos, mvector3.x(self._common_data.pos), mvector3.y(self._common_data.pos), mvector3.z(new_pos))
				end
			else
				local ray_params = {
					tracker_from = self._common_data.nav_tracker,
					pos_to = new_pos
				}

				if managers.navigation:raycast(ray_params) then
					mvector3.set_static(new_pos, mvector3.x(self._common_data.pos), mvector3.y(self._common_data.pos), mvector3.z(new_pos))
				end
			end
		end

		self._ext_movement:set_position(new_pos)
	else
		local my_pos = self._tmp_vec1

		mvector3.set(my_pos, self._common_data.pos)
		self._ext_movement:upd_ground_ray(my_pos, true)

		local gnd_z = self._common_data.gnd_ray.position.z

		if gnd_z < my_pos.z then
			self._last_vel_z = self._apply_freefall(my_pos, self._last_vel_z, gnd_z, TimerManager:game():delta_time())
		else
			if my_pos.z < gnd_z then
				mvector3.set_z(my_pos, gnd_z)
			end

			self._last_vel_z = 0
			self._beating_end_t = 0

			if Network:is_server() then
				self:_expire()
			else
				self:_wait()
			end
		end

		self._ext_movement:set_position(my_pos)
	end
end

function ActionSpooc:_play_strike_camera_shake()
	local vars = {
		"melee_hit",
		"melee_hit_var2"
	}

	self._strike_unit:camera():play_shaker(vars[math.random(#vars)], 1)
end

function ActionSpooc:has_striken()
	return self._stroke_t and true or false
end

function ActionSpooc:is_flying_strike()
	return self._action_desc.flying_strike
end

function ActionSpooc:_use_christmas_sounds()
	local tweak = tweak_data.narrative.jobs[managers.job:current_real_job_id()]

	return tweak and tweak.is_christmas_heist
end

function ActionSpooc:get_sound_event(sound)
	local sound_events = self._unit:base():char_tweak().spooc_sound_events
	local event = sound_events[sound]

	if self:_use_christmas_sounds() then
		local christmas_events = {
			detect_stop = "cloaker_detect_christmas_stop",
			detect = "cloaker_detect_christmas_mono"
		}
		event = christmas_events[sound] or event
	end

	return event
end
