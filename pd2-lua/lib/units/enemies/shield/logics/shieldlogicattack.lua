ShieldLogicAttack = class(TankCopLogicAttack)

function ShieldLogicAttack.enter(data, new_logic_name, enter_params)
	local old_internal_data = data.internal_data
	local my_data = {
		unit = data.unit
	}
	data.internal_data = my_data
	my_data.detection = data.char_tweak.detection.combat
	my_data.tmp_vec1 = Vector3()

	if old_internal_data then
		my_data.turning = old_internal_data.turning
		my_data.firing = old_internal_data.firing
		my_data.shooting = old_internal_data.shooting
		my_data.attention_unit = old_internal_data.attention_unit
	end

	local key_str = tostring(data.key)

	CopLogicIdle._chk_has_old_action(data, my_data)

	my_data.attitude = data.objective and data.objective.attitude or "avoid"

	data.unit:brain():set_update_enabled_state(false)

	if not data.attack_sound_t or data.t - data.attack_sound_t > 40 then
		data.attack_sound_t = data.t

		data.unit:sound():play("shield_identification", nil, true)
	end

	data.unit:movement():set_cool(false)

	if my_data ~= data.internal_data then
		return
	end

	data.unit:brain():set_attention_settings({
		cbt = true
	})

	my_data.weapon_range = data.char_tweak.weapon[data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage].range
	my_data.update_queue_id = "ShieldLogicAttack.queued_update" .. key_str

	ShieldLogicAttack.queue_update(data, my_data)
end

function ShieldLogicAttack.exit(data, new_logic_name, enter_params)
	CopLogicBase.exit(data, new_logic_name, enter_params)

	local my_data = data.internal_data

	data.unit:brain():cancel_all_pathing_searches()
	CopLogicBase.cancel_queued_tasks(my_data)
	data.brain:rem_pos_rsrv("path")
	data.unit:brain():set_update_enabled_state(true)
end

function ShieldLogicAttack.queued_update(data)
	local t = TimerManager:game():time()
	data.t = t
	local unit = data.unit
	local my_data = data.internal_data

	ShieldLogicAttack._upd_enemy_detection(data)

	if my_data ~= data.internal_data then
		return
	end

	if my_data.has_old_action then
		CopLogicAttack._upd_stop_old_action(data, my_data)
		ShieldLogicAttack.queue_update(data, my_data)
		CopLogicBase._report_detections(data.detected_attention_objects)

		return
	end

	if not data.attention_obj or data.attention_obj.reaction < AIAttentionObject.REACT_AIM then
		ShieldLogicAttack.queue_update(data, my_data)

		return
	end

	local focus_enemy = data.attention_obj
	local action_taken = my_data.turning or data.unit:movement():chk_action_forbidden("walk") or my_data.walking_to_shoot_pos

	if not action_taken and unit:anim_data().stand then
		action_taken = CopLogicAttack._chk_request_action_crouch(data)
	end

	ShieldLogicAttack._process_pathing_results(data, my_data)

	local enemy_visible = focus_enemy.verified
	local engage = my_data.attitude == "engage"
	local action_taken = my_data.turning or data.unit:movement():chk_action_forbidden("walk") or my_data.walking_to_optimal_pos

	if not action_taken then
		if unit:anim_data().stand then
			action_taken = CopLogicAttack._chk_request_action_crouch(data)
		end

		if not action_taken then
			if my_data.pathing_to_optimal_pos then
				-- Nothing
			elseif my_data.optimal_path then
				ShieldLogicAttack._chk_request_action_walk_to_optimal_pos(data, my_data)
			elseif my_data.optimal_pos and focus_enemy.nav_tracker then
				local to_pos = my_data.optimal_pos
				my_data.optimal_pos = nil
				local ray_params = {
					trace = true,
					tracker_from = unit:movement():nav_tracker(),
					pos_to = to_pos
				}
				local ray_res = managers.navigation:raycast(ray_params)
				to_pos = ray_params.trace[1]

				if ray_res then
					local vec = data.m_pos - to_pos

					mvector3.normalize(vec)

					local fwd = unit:movement():m_fwd()
					local fwd_dot = fwd:dot(vec)

					if fwd_dot > 0 then
						local enemy_tracker = focus_enemy.nav_tracker

						if enemy_tracker:lost() then
							ray_params.tracker_from = nil
							ray_params.pos_from = enemy_tracker:field_position()
						else
							ray_params.tracker_from = enemy_tracker
						end

						ray_res = managers.navigation:raycast(ray_params)
						to_pos = ray_params.trace[1]
					end
				end

				local fwd_bump = nil
				to_pos, fwd_bump = ShieldLogicAttack.chk_wall_distance(data, my_data, to_pos)
				local do_move = mvector3.distance_sq(to_pos, data.m_pos) > 10000

				if not do_move then
					local to_pos_current, fwd_bump_current = ShieldLogicAttack.chk_wall_distance(data, my_data, data.m_pos)

					if fwd_bump_current then
						do_move = true
					end
				end

				if do_move then
					my_data.pathing_to_optimal_pos = true
					my_data.optimal_path_search_id = tostring(unit:key()) .. "optimal"
					local reservation = managers.navigation:reserve_pos(nil, nil, to_pos, callback(ShieldLogicAttack, ShieldLogicAttack, "_reserve_pos_step_clbk", {
						unit_pos = data.m_pos
					}), 70, data.pos_rsrv_id)

					if reservation then
						to_pos = reservation.position
					else
						reservation = {
							radius = 60,
							position = mvector3.copy(to_pos),
							filter = data.pos_rsrv_id
						}

						managers.navigation:add_pos_reservation(reservation)
					end

					data.brain:set_pos_rsrv("path", reservation)
					data.brain:search_for_path(my_data.optimal_path_search_id, to_pos)
				end
			end
		end
	end

	ShieldLogicAttack.queue_update(data, my_data)
	CopLogicBase._report_detections(data.detected_attention_objects)
end

function ShieldLogicAttack:_reserve_pos_step_clbk(data, test_pos)
	if not data.step_vector then
		data.step_vector = mvector3.copy(data.unit_pos)

		mvector3.subtract(data.step_vector, test_pos)

		data.distance = mvector3.normalize(data.step_vector)

		mvector3.set_length(data.step_vector, 25)

		data.num_steps = 0
	end

	local step_length = mvector3.length(data.step_vector)

	if data.distance < step_length or data.num_steps > 4 then
		return false
	end

	mvector3.add(test_pos, data.step_vector)

	data.distance = data.distance - step_length

	mvector3.set_length(data.step_vector, step_length * 2)

	data.num_steps = data.num_steps + 1

	return true
end

function ShieldLogicAttack._process_pathing_results(data, my_data)
	if data.pathing_results then
		local pathing_results = data.pathing_results
		data.pathing_results = nil
		local path = pathing_results[my_data.optimal_path_search_id]

		if path then
			if path ~= "failed" then
				my_data.optimal_path = path
			else
				print("[ShieldLogicAttack._process_pathing_results] optimal path failed")
			end

			my_data.pathing_to_optimal_pos = nil
			my_data.optimal_path_search_id = nil
		end
	end
end

function ShieldLogicAttack._chk_request_action_walk_to_optimal_pos(data, my_data, end_rot)
	if not data.unit:movement():chk_action_forbidden("walk") then
		local new_action_data = {
			type = "walk",
			body_part = 2,
			variant = "walk",
			nav_path = my_data.optimal_path,
			end_rot = end_rot
		}
		my_data.optimal_path = nil
		my_data.walking_to_optimal_pos = data.unit:brain():action_request(new_action_data)

		if my_data.walking_to_optimal_pos then
			data.brain:rem_pos_rsrv("path")

			if data.group and data.group.leader_key == data.key and data.char_tweak.chatter.follow_me and mvector3.distance(new_action_data.nav_path[#new_action_data.nav_path], data.m_pos) > 800 and not data.unit:sound():speaking(data.t) then
				managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "follow_me")
			end
		end
	end
end

function ShieldLogicAttack._cancel_optimal_attempt(data, my_data)
	if my_data.optimal_path then
		my_data.optimal_path = nil
	elseif my_data.walking_to_optimal_pos then
		local new_action = {
			body_part = 2,
			type = "idle"
		}

		data.unit:brain():action_request(new_action)
	elseif my_data.pathing_to_optimal_pos then
		if data.active_searches[my_data.optimal_path_search_id] then
			managers.navigation:cancel_pathing_search(my_data.optimal_path_search_id)

			data.active_searches[my_data.optimal_path_search_id] = nil
		elseif data.pathing_results then
			data.pathing_results[my_data.optimal_path_search_id] = nil
		end

		my_data.optimal_path_search_id = nil
		my_data.pathing_to_optimal_pos = nil

		data.unit:brain():cancel_all_pathing_searches()
	end
end

function ShieldLogicAttack.queue_update(data, my_data)
	CopLogicBase.queue_task(my_data, my_data.update_queue_id, ShieldLogicAttack.queued_update, data, data.t + (data.important and 0.5 or 1.5), data.important and true)
end

function ShieldLogicAttack._upd_enemy_detection(data)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local min_reaction = AIAttentionObject.REACT_AIM
	local delay = CopLogicBase._upd_attention_obj_detection(data, min_reaction, nil)
	local focus_enemy, focus_enemy_angle, focus_enemy_reaction = nil
	local detected_enemies = data.detected_attention_objects
	local enemies = {}
	local enemies_cpy = {}
	local passive_enemies = {}
	local threat_epicenter, threats = nil
	local nr_threats = 0
	local verified_chk_t = data.t - 8

	for key, enemy_data in pairs(detected_enemies) do
		if AIAttentionObject.REACT_COMBAT <= enemy_data.reaction and enemy_data.identified and enemy_data.verified_t and verified_chk_t < enemy_data.verified_t then
			enemies[key] = enemy_data
			enemies_cpy[key] = enemy_data
		end
	end

	for key, enemy_data in pairs(enemies) do
		threat_epicenter = threat_epicenter or Vector3()

		mvector3.add(threat_epicenter, enemy_data.m_pos)

		nr_threats = nr_threats + 1
		enemy_data.aimed_at = CopLogicIdle.chk_am_i_aimed_at(data, enemy_data, enemy_data.aimed_at and 0.95 or 0.985)
	end

	if threat_epicenter then
		mvector3.divide(threat_epicenter, nr_threats)

		local from_threat = mvector3.copy(threat_epicenter)

		mvector3.subtract(from_threat, data.m_pos)
		mvector3.normalize(from_threat)

		local furthest_pt_dist = 0
		local furthest_line = nil

		if not my_data.threat_epicenter or mvector3.distance(threat_epicenter, my_data.threat_epicenter) > 100 then
			my_data.threat_epicenter = mvector3.copy(threat_epicenter)

			for key1, enemy_data1 in pairs(enemies) do
				enemies_cpy[key1] = nil

				for key2, enemy_data2 in pairs(enemies_cpy) do
					if nr_threats == 2 then
						local AB = mvector3.copy(enemy_data1.m_pos)

						mvector3.subtract(AB, enemy_data2.m_pos)
						mvector3.normalize(AB)

						local PA = mvector3.copy(data.m_pos)

						mvector3.subtract(PA, enemy_data1.m_pos)
						mvector3.normalize(PA)

						local PB = mvector3.copy(data.m_pos)

						mvector3.subtract(PB, enemy_data2.m_pos)
						mvector3.normalize(PB)

						local dot1 = mvector3.dot(AB, PA)
						local dot2 = mvector3.dot(AB, PB)

						if dot1 < 0 and dot2 < 0 or dot1 > 0 and dot2 > 0 then
							break
						else
							furthest_line = {
								enemy_data1.m_pos,
								enemy_data2.m_pos
							}

							break
						end
					end

					local pt = math.line_intersection(enemy_data1.m_pos, enemy_data2.m_pos, threat_epicenter, data.m_pos)
					local to_pt = mvector3.copy(threat_epicenter)

					mvector3.subtract(to_pt, pt)
					mvector3.normalize(to_pt)

					if mvector3.dot(from_threat, to_pt) > 0 then
						local line = mvector3.copy(enemy_data2.m_pos)

						mvector3.subtract(line, enemy_data1.m_pos)

						local line_len = mvector3.normalize(line)
						local pt_line = mvector3.copy(pt)

						mvector3.subtract(pt_line, enemy_data1.m_pos)

						local dot = mvector3.dot(line, pt_line)

						if dot < line_len and dot > 0 then
							local dist = mvector3.distance(pt, threat_epicenter)

							if furthest_pt_dist < dist then
								furthest_pt_dist = dist
								furthest_line = {
									enemy_data1.m_pos,
									enemy_data2.m_pos
								}
							end
						end
					end
				end
			end
		end

		local optimal_direction = nil

		if furthest_line then
			local BA = mvector3.copy(furthest_line[2])

			mvector3.subtract(BA, furthest_line[1])

			local PA = mvector3.copy(furthest_line[1])

			mvector3.subtract(PA, data.m_pos)

			local out = nil

			if nr_threats == 2 then
				mvector3.normalize(BA)

				local len = mvector3.dot(BA, PA)
				local x = mvector3.copy(furthest_line[1])

				mvector3.multiply(BA, len)
				mvector3.subtract(x, BA)

				out = mvector3.copy(data.m_pos)

				mvector3.subtract(out, x)
			else
				local EA = mvector3.copy(threat_epicenter)

				mvector3.subtract(EA, furthest_line[1])

				local rot_axis = Vector3()

				mvector3.cross(rot_axis, BA, EA)
				mvector3.set_static(rot_axis, 0, 0, rot_axis.z)

				out = Vector3()

				mvector3.cross(out, BA, rot_axis)
			end

			mvector3.normalize(out)

			optimal_direction = mvector3.copy(out)

			mvector3.multiply(optimal_direction, -1)
			mvector3.multiply(out, mvector3.dot(out, PA) + 600)

			my_data.optimal_pos = mvector3.copy(data.m_pos)

			mvector3.add(my_data.optimal_pos, out)
		else
			optimal_direction = mvector3.copy(threat_epicenter)

			mvector3.subtract(optimal_direction, data.m_pos)
			mvector3.normalize(optimal_direction)

			local optimal_length = 0

			for _, enemy in pairs(enemies) do
				local enemy_dir = mvector3.copy(threat_epicenter)

				mvector3.subtract(enemy_dir, enemy.m_pos)

				local len = mvector3.dot(enemy_dir, optimal_direction)
				optimal_length = math.max(len, optimal_length)
			end

			local optimal_pos = mvector3.copy(optimal_direction)

			mvector3.multiply(optimal_pos, -(optimal_length + 600))
			mvector3.add(optimal_pos, threat_epicenter)

			my_data.optimal_pos = optimal_pos
		end

		for key, enemy_data in pairs(enemies) do
			local reaction = CopLogicSniper._chk_reaction_to_attention_object(data, enemy_data, true)

			if not focus_enemy_reaction or focus_enemy_reaction <= reaction then
				local enemy_dir = my_data.tmp_vec1

				mvector3.direction(enemy_dir, data.m_pos, enemy_data.m_pos)

				local angle = mvector3.dot(optimal_direction, enemy_dir)

				if data.attention_obj and key == data.attention_obj.u_key then
					angle = angle + 0.15
				end

				if not focus_enemy or enemy_data.verified and not focus_enemy.verified or (enemy_data.verified or not focus_enemy.verified) and focus_enemy_angle < angle then
					focus_enemy = enemy_data
					focus_enemy_angle = angle
					focus_enemy_reaction = reaction
				end
			end
		end

		CopLogicBase._set_attention_obj(data, focus_enemy, focus_enemy_reaction)
	else
		local new_attention, new_prio_slot, new_reaction = CopLogicIdle._get_priority_attention(data, data.detected_attention_objects, nil)
		local old_att_obj = data.attention_obj

		CopLogicBase._set_attention_obj(data, new_attention, new_reaction)

		if new_attention then
			if old_att_obj and old_att_obj.u_key ~= new_attention.u_key then
				CopLogicAttack._cancel_charge(data, my_data)

				if not data.unit:movement():chk_action_forbidden("walk") then
					ShieldLogicAttack._cancel_optimal_attempt(data, my_data)
				end
			end

			if AIAttentionObject.REACT_COMBAT <= new_reaction and new_attention.nav_tracker then
				my_data.optimal_pos = CopLogicAttack._find_flank_pos(data, my_data, new_attention.nav_tracker)
			end
		elseif old_att_obj and not data.unit:movement():chk_action_forbidden("walk") then
			ShieldLogicAttack._cancel_optimal_attempt(data, my_data)
		end
	end

	CopLogicAttack._chk_exit_attack_logic(data, data.attention_obj and data.attention_obj.reaction)

	if my_data ~= data.internal_data then
		return
	end

	ShieldLogicAttack._upd_aim(data, my_data)

	if my_data.optimal_pos and focus_enemy then
		mvector3.set_z(my_data.optimal_pos, focus_enemy.m_pos.z)
	end
end

function ShieldLogicAttack.action_complete_clbk(data, action)
	local my_data = data.internal_data
	local action_type = action:type()

	if action_type == "walk" then
		my_data.advancing = nil

		if my_data.walking_to_optimal_pos then
			my_data.walking_to_optimal_pos = nil
		end
	elseif action_type == "shoot" then
		my_data.shooting = nil
	elseif action_type == "turn" then
		my_data.turning = nil
	elseif action_type == "hurt" and action:expired() then
		ShieldLogicAttack._upd_aim(data, my_data)
	end
end

function ShieldLogicAttack.is_advancing(data)
	if data.internal_data.walking_to_optimal_pos and data.pos_rsrv.move_dest then
		return data.pos_rsrv.move_dest.position
	end
end

function ShieldLogicAttack._get_all_paths(data)
	return {
		optimal_path = data.internal_data.optimal_path
	}
end

function ShieldLogicAttack._set_verified_paths(data, verified_paths)
	data.internal_data.optimal_path = verified_paths.optimal_path
end

function ShieldLogicAttack.chk_wall_distance(data, my_data, pos, second_pass)
	if not data.char_tweak.wall_fwd_offset then
		return pos
	end

	local my_tracker = managers.navigation:create_nav_tracker(pos)
	local tracker_lost = my_tracker:lost()
	local my_fwd = data.unit:movement():m_fwd()
	local ray_params = {
		trace = true,
		tracker_from = not tracker_lost and my_tracker or nil,
		pos_from = tracker_lost and my_tracker:field_position() or nil,
		pos_to = pos + my_fwd * data.char_tweak.wall_fwd_offset
	}

	if not managers.navigation:raycast(ray_params) then
		managers.navigation:destroy_nav_tracker(my_tracker)

		return pos
	end

	local col_pos = ray_params.trace[1]
	local col_side = ray_params.trace[2]
	local correction_vec = ray_params.pos_to - col_pos

	mvector3.multiply(correction_vec, 1.05)

	local correction_vec_proj = nil

	if col_side == "x_pos" then
		correction_vec_proj = math.X * -mvector3.dot(correction_vec, math.X)
	elseif col_side == "x_neg" then
		correction_vec_proj = math.X * -mvector3.dot(correction_vec, math.X)
	elseif col_side == "y_pos" then
		correction_vec_proj = math.Y * -mvector3.dot(correction_vec, math.Y)
	elseif col_side == "y_neg" then
		correction_vec_proj = math.Y * -mvector3.dot(correction_vec, math.Y)
	end

	local walk_to_pos = pos + correction_vec_proj
	ray_params.pos_to = walk_to_pos

	if managers.navigation:raycast(ray_params) then
		walk_to_pos = ray_params.trace[1]
	end

	managers.navigation:destroy_nav_tracker(my_tracker)

	if second_pass then
		return walk_to_pos, true
	else
		local walk_to_pos2, bump2 = ShieldLogicAttack.chk_wall_distance(data, my_data, walk_to_pos, true)

		return bump2 and walk_to_pos2 or walk_to_pos, true
	end
end
