local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_sub = mvector3.subtract
local mvec3_dir = mvector3.direction
local mvec3_dot = mvector3.dot
local mvec3_dis = mvector3.distance
local mvec3_dis_sq = mvector3.distance_sq
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
CopLogicBase = class()
CopLogicBase._AGGRESSIVE_ALERT_TYPES = {
	vo_distress = true,
	aggression = true,
	bullet = true,
	vo_intimidate = true,
	explosion = true,
	footstep = true,
	vo_cbt = true
}
CopLogicBase._DANGEROUS_ALERT_TYPES = {
	explosion = true,
	bullet = true,
	aggression = true
}

function CopLogicBase.enter(data, new_logic_name, enter_params)
end

function CopLogicBase.exit(data, new_logic_name, enter_params)
	if data.internal_data then
		data.internal_data.exiting = true
	end
end

function CopLogicBase.action_data(data)
	return data.action_data
end

function CopLogicBase.can_activate(data)
	return true
end

function CopLogicBase.on_intimidated(data, amount, aggressor_unit)
end

function CopLogicBase.on_tied(data, aggressor_unit)
end

function CopLogicBase.on_criminal_neutralized(data, criminal_key)
end

function CopLogicBase._set_attention_on_unit(data, attention_unit)
	local attention_data = {
		unit = attention_unit
	}

	data.unit:movement():set_attention(attention_data)
end

function CopLogicBase._set_attention(data, attention_info, reaction)
	local attention_data = {
		unit = attention_info.unit,
		u_key = attention_info.u_key,
		handler = attention_info.handler,
		reaction = reaction or attention_info.reaction
	}

	data.unit:movement():set_attention(attention_data)
end

function CopLogicBase._set_attention_on_pos(data, pos)
	local attention_data = {
		pos = pos
	}

	data.unit:movement():set_attention(attention_data)
end

function CopLogicBase._reset_attention(data)
	data.unit:movement():set_attention()
end

function CopLogicBase.is_available_for_assignment(data)
	return true
end

function CopLogicBase.action_complete_clbk(data, action)
end

function CopLogicBase.damage_clbk(data, result, attack_unit)
end

function CopLogicBase.death_clbk(data, damage_info)
end

function CopLogicBase.on_alert(data, alert_data)
end

function CopLogicBase.on_area_safety(data, nav_seg, safe)
end

function CopLogicBase.draw_reserved_positions(data)
	local my_pos = data.m_pos
	local my_data = data.internal_data
	local rsrv_pos = data.pos_rsrv

	if rsrv_pos.path then
		Application:draw_cylinder(rsrv_pos.path.pos, my_pos, 6, 0, 0.3, 0.3)
	end

	if rsrv_pos.move_dest then
		Application:draw_cylinder(rsrv_pos.move_dest.pos, my_pos, 6, 0.3, 0.3, 0)
	end

	if rsrv_pos.stand then
		Application:draw_cylinder(rsrv_pos.stand.pos, my_pos, 6, 0.3, 0, 0.3)
	end

	if my_data.best_cover then
		local cover_pos = my_data.best_cover[1][5].pos

		Application:draw_cylinder(cover_pos, my_pos, 2, 0.2, 0.3, 0.6)
		Application:draw_sphere(cover_pos, 10, 0.2, 0.3, 0.6)
	end

	if my_data.nearest_cover then
		local cover_pos = my_data.nearest_cover[1][5].pos

		Application:draw_cylinder(cover_pos, my_pos, 2, 0.2, 0.6, 0.3)
		Application:draw_sphere(cover_pos, 8, 0.2, 0.6, 0.3)
	end

	if my_data.moving_to_cover then
		local cover_pos = my_data.moving_to_cover[1][5].pos

		Application:draw_cylinder(cover_pos, my_pos, 2, 0.3, 0.6, 0.2)
		Application:draw_sphere(cover_pos, 8, 0.3, 0.6, 0.2)
	end
end

function CopLogicBase.draw_reserved_covers(data)
	local my_pos = data.m_pos
	local my_data = data.internal_data

	if my_data.best_cover then
		local cover_pos = my_data.best_cover[1][5].pos

		Application:draw_cylinder(cover_pos, my_pos, 2, 0.2, 0.3, 0.6)
		Application:draw_sphere(cover_pos, 10, 0.2, 0.3, 0.6)
	end

	if my_data.nearest_cover then
		local cover_pos = my_data.nearest_cover[1][5].pos

		Application:draw_cylinder(cover_pos, my_pos, 2, 0.2, 0.6, 0.3)
		Application:draw_sphere(cover_pos, 8, 0.2, 0.6, 0.3)
	end

	if my_data.moving_to_cover then
		local cover_pos = my_data.moving_to_cover[1][5].pos

		Application:draw_cylinder(cover_pos, my_pos, 2, 0.3, 0.6, 0.2)
		Application:draw_sphere(cover_pos, 8, 0.3, 0.6, 0.2)
	end
end

function CopLogicBase._exit(unit, state_name, params)
	unit:brain():set_logic(state_name, params)
end

function CopLogicBase.on_detected_enemy_destroyed(data, enemy_unit)
end

function CopLogicBase._can_move(data)
	return true
end

function CopLogicBase._report_detections(enemies)
	local group = managers.groupai:state()

	for key, data in pairs(enemies) do
		if data.verified and data.criminal_record then
			group:criminal_spotted(data.unit)
		end
	end
end

function CopLogicBase.on_importance(data)
end

function CopLogicBase.queue_task(internal_data, id, func, data, exec_t, asap)
	if internal_data.unit and internal_data ~= internal_data.unit:brain()._logic_data.internal_data then
		debug_pause("[CopLogicBase.queue_task] Task queued from the wrong logic", internal_data.unit, id, func, data, exec_t, asap)
	end

	local qd_tasks = internal_data.queued_tasks

	if qd_tasks then
		if qd_tasks[id] then
			debug_pause("[CopLogicBase.queue_task] Task queued twice", internal_data.unit, id, func, data, exec_t, asap)
		end

		qd_tasks[id] = true
	else
		internal_data.queued_tasks = {
			[id] = true
		}
	end

	managers.enemy:queue_task(id, func, data, exec_t, callback(CopLogicBase, CopLogicBase, "on_queued_task", internal_data), asap)
end

function CopLogicBase.cancel_queued_tasks(internal_data)
	local qd_tasks = internal_data.queued_tasks

	if qd_tasks then
		local e_manager = managers.enemy

		for id, _ in pairs(qd_tasks) do
			e_manager:unqueue_task(id)
		end

		internal_data.queued_tasks = nil
	end
end

function CopLogicBase.unqueue_task(internal_data, id)
	managers.enemy:unqueue_task(id)

	internal_data.queued_tasks[id] = nil

	if not next(internal_data.queued_tasks) then
		internal_data.queued_tasks = nil
	end
end

function CopLogicBase.chk_unqueue_task(internal_data, id)
	if internal_data.queued_tasks and internal_data.queued_tasks[id] then
		managers.enemy:unqueue_task(id)

		internal_data.queued_tasks[id] = nil

		if not next(internal_data.queued_tasks) then
			internal_data.queued_tasks = nil
		end
	end
end

function CopLogicBase.on_queued_task(ignore_this, internal_data, id)
	if not internal_data.queued_tasks or not internal_data.queued_tasks[id] then
		debug_pause("[CopLogicBase.on_queued_task] the task is not queued", internal_data.unit, id)

		return
	end

	internal_data.queued_tasks[id] = nil

	if not next(internal_data.queued_tasks) then
		internal_data.queued_tasks = nil
	end
end

function CopLogicBase.add_delayed_clbk(internal_data, id, clbk, exec_t)
	if internal_data.unit and internal_data ~= internal_data.unit:brain()._logic_data.internal_data then
		debug_pause("[CopLogicBase.add_delayed_clbk] Clbk added from the wrong logic", internal_data.unit, id, clbk, exec_t)
	end

	local clbks = internal_data.delayed_clbks

	if clbks then
		if clbks[id] then
			debug_pause("[CopLogicBase.queue_task] Callback added twice", internal_data.unit, id, clbk, exec_t)
		end

		clbks[id] = true
	else
		internal_data.delayed_clbks = {
			[id] = true
		}
	end

	managers.enemy:add_delayed_clbk(id, clbk, exec_t)
end

function CopLogicBase.cancel_delayed_clbks(internal_data)
	local clbks = internal_data.delayed_clbks

	if clbks then
		local e_manager = managers.enemy

		for id, _ in pairs(clbks) do
			e_manager:remove_delayed_clbk(id)
		end

		internal_data.delayed_clbks = nil
	end
end

function CopLogicBase.cancel_delayed_clbk(internal_data, id)
	if not internal_data.delayed_clbks or not internal_data.delayed_clbks[id] then
		debug_pause("[CopLogicBase.cancel_delayed_clbk] Tried to cancel inexistent clbk", internal_data.unit, id, internal_data.delayed_clbks and inspect(internal_data.delayed_clbks))

		return
	end

	managers.enemy:remove_delayed_clbk(id)

	internal_data.delayed_clbks[id] = nil

	if not next(internal_data.delayed_clbks) then
		internal_data.delayed_clbks = nil
	end
end

function CopLogicBase.chk_cancel_delayed_clbk(internal_data, id)
	if internal_data.delayed_clbks and internal_data.delayed_clbks[id] then
		managers.enemy:remove_delayed_clbk(id)

		internal_data.delayed_clbks[id] = nil

		if not next(internal_data.delayed_clbks) then
			internal_data.delayed_clbks = nil
		end
	end
end

function CopLogicBase.on_delayed_clbk(internal_data, id)
	if not internal_data.delayed_clbks or not internal_data.delayed_clbks[id] then
		debug_pause("[CopLogicBase.on_delayed_clbk] Callback not added", internal_data.unit, id, internal_data.delayed_clbks and inspect(internal_data.delayed_clbks))

		return
	end

	internal_data.delayed_clbks[id] = nil

	if not next(internal_data.delayed_clbks) then
		internal_data.delayed_clbks = nil
	end
end

function CopLogicBase.on_objective_unit_damaged(data, unit, attacker_unit)
end

function CopLogicBase.on_objective_unit_destroyed(data, unit)
	if not alive(data.unit) then
		debug_pause("dead unit did not remove destroy listener", data.debug_name, inspect(data.objective), data.name)

		return
	end

	data.objective.destroy_clbk_key = nil
	data.objective.death_clbk_key = nil

	data.objective_failed_clbk(data.unit, data.objective)
end

function CopLogicBase.on_new_objective(data, old_objective)
	if old_objective and old_objective.follow_unit then
		if old_objective.destroy_clbk_key then
			old_objective.follow_unit:base():remove_destroy_listener(old_objective.destroy_clbk_key)

			old_objective.destroy_clbk_key = nil
		end

		if old_objective.death_clbk_key then
			old_objective.follow_unit:character_damage():remove_listener(old_objective.death_clbk_key)

			old_objective.death_clbk_key = nil
		end
	end

	local new_objective = data.objective

	if new_objective and new_objective.follow_unit and not new_objective.destroy_clbk_key then
		local ext_brain = data.unit:brain()
		local destroy_clbk_key = "objective_" .. new_objective.type .. tostring(data.unit:key())
		new_objective.destroy_clbk_key = destroy_clbk_key

		new_objective.follow_unit:base():add_destroy_listener(destroy_clbk_key, callback(ext_brain, ext_brain, "on_objective_unit_destroyed"))

		if new_objective.follow_unit:character_damage() then
			new_objective.death_clbk_key = destroy_clbk_key

			new_objective.follow_unit:character_damage():add_listener(destroy_clbk_key, {
				"death",
				"hurt"
			}, callback(ext_brain, ext_brain, "on_objective_unit_damaged"))
		end
	end
end

function CopLogicBase.is_advancing(data)
end

function CopLogicBase.anim_clbk(...)
end

function CopLogicBase._upd_attention_obj_detection(data, min_reaction, max_reaction)
	local t = data.t
	local detected_obj = data.detected_attention_objects
	local my_data = data.internal_data
	local my_key = data.key
	local my_pos = data.unit:movement():m_head_pos()
	local my_access = data.SO_access
	local all_attention_objects = managers.groupai:state():get_AI_attention_objects_by_filter(data.SO_access_str, data.team)
	local my_head_fwd = nil
	local my_tracker = data.unit:movement():nav_tracker()
	local chk_vis_func = my_tracker.check_visibility
	local is_detection_persistent = managers.groupai:state():is_detection_persistent()
	local delay = 2
	local player_importance_wgt = data.unit:in_slot(managers.slot:get_mask("enemies")) and {}

	local function _angle_chk(attention_pos, dis, strictness)
		mvector3.direction(tmp_vec1, my_pos, attention_pos)

		my_head_fwd = my_head_fwd or data.unit:movement():m_head_rot():z()
		local angle = mvector3.angle(my_head_fwd, tmp_vec1)
		local angle_max = math.lerp(180, my_data.detection.angle_max, math.clamp((dis - 150) / 700, 0, 1))

		if angle_max > angle * strictness then
			return true
		end
	end

	local function _angle_and_dis_chk(handler, settings, attention_pos)
		attention_pos = attention_pos or handler:get_detection_m_pos()
		local dis = mvector3.direction(tmp_vec1, my_pos, attention_pos)
		local dis_multiplier, angle_multiplier = nil
		local max_dis = math.min(my_data.detection.dis_max, settings.max_range or my_data.detection.dis_max)

		if settings.detection and settings.detection.range_mul then
			max_dis = max_dis * settings.detection.range_mul
		end

		dis_multiplier = dis / max_dis

		if settings.uncover_range and my_data.detection.use_uncover_range and dis < settings.uncover_range then
			return -1, 0
		end

		if dis_multiplier < 1 then
			if settings.notice_requires_FOV then
				my_head_fwd = my_head_fwd or data.unit:movement():m_head_rot():z()
				local angle = mvector3.angle(my_head_fwd, tmp_vec1)

				if angle < 55 and not my_data.detection.use_uncover_range and settings.uncover_range and dis < settings.uncover_range then
					return -1, 0
				end

				local angle_max = math.lerp(180, my_data.detection.angle_max, math.clamp((dis - 150) / 700, 0, 1))
				angle_multiplier = angle / angle_max

				if angle_multiplier < 1 then
					return angle, dis_multiplier
				end
			else
				return 0, dis_multiplier
			end
		end
	end

	local function _nearly_visible_chk(attention_info, detect_pos)
		local near_pos = tmp_vec1

		if attention_info.verified_dis < 2000 and math.abs(detect_pos.z - my_pos.z) < 300 then
			mvec3_set(near_pos, detect_pos)
			mvec3_set_z(near_pos, near_pos.z + 100)

			local near_vis_ray = World:raycast("ray", my_pos, near_pos, "slot_mask", data.visibility_slotmask, "ray_type", "ai_vision", "report")

			if near_vis_ray then
				local side_vec = tmp_vec1

				mvec3_set(side_vec, detect_pos)
				mvec3_sub(side_vec, my_pos)
				mvector3.cross(side_vec, side_vec, math.UP)
				mvector3.set_length(side_vec, 150)
				mvector3.set(near_pos, detect_pos)
				mvector3.add(near_pos, side_vec)

				local near_vis_ray = World:raycast("ray", my_pos, near_pos, "slot_mask", data.visibility_slotmask, "ray_type", "ai_vision", "report")

				if near_vis_ray then
					mvector3.multiply(side_vec, -2)
					mvector3.add(near_pos, side_vec)

					near_vis_ray = World:raycast("ray", my_pos, near_pos, "slot_mask", data.visibility_slotmask, "ray_type", "ai_vision", "report")
				end
			end

			if not near_vis_ray then
				attention_info.nearly_visible = true
				attention_info.last_verified_pos = mvector3.copy(near_pos)
			end
		end
	end

	local function _chk_record_acquired_attention_importance_wgt(attention_info)
		if not player_importance_wgt or not attention_info.is_human_player then
			return
		end

		local weight = mvector3.direction(tmp_vec1, attention_info.m_head_pos, my_pos)
		local e_fwd = nil

		if attention_info.is_husk_player then
			e_fwd = attention_info.unit:movement():detect_look_dir()
		else
			e_fwd = attention_info.unit:movement():m_head_rot():y()
		end

		local dot = mvector3.dot(e_fwd, tmp_vec1)
		weight = weight * weight * (1 - dot)

		table.insert(player_importance_wgt, attention_info.u_key)
		table.insert(player_importance_wgt, weight)
	end

	local function _chk_record_attention_obj_importance_wgt(u_key, attention_info)
		if not player_importance_wgt then
			return
		end

		local is_human_player, is_local_player, is_husk_player = nil

		if attention_info.unit:base() then
			is_local_player = attention_info.unit:base().is_local_player
			is_husk_player = not is_local_player and attention_info.unit:base().is_husk_player
			is_human_player = is_local_player or is_husk_player
		end

		if not is_human_player then
			return
		end

		local weight = mvector3.direction(tmp_vec1, attention_info.handler:get_detection_m_pos(), my_pos)
		local e_fwd = nil

		if is_husk_player then
			e_fwd = attention_info.unit:movement():detect_look_dir()
		else
			e_fwd = attention_info.unit:movement():m_head_rot():y()
		end

		local dot = mvector3.dot(e_fwd, tmp_vec1)
		weight = weight * weight * (1 - dot)

		table.insert(player_importance_wgt, u_key)
		table.insert(player_importance_wgt, weight)
	end

	for u_key, attention_info in pairs(all_attention_objects) do
		if u_key ~= my_key and not detected_obj[u_key] and (not attention_info.nav_tracker or chk_vis_func(my_tracker, attention_info.nav_tracker)) then
			local settings = attention_info.handler:get_attention(my_access, min_reaction, max_reaction, data.team)

			if settings then
				local acquired = nil
				local attention_pos = attention_info.handler:get_detection_m_pos()

				if _angle_and_dis_chk(attention_info.handler, settings, attention_pos) then
					local vis_ray = World:raycast("ray", my_pos, attention_pos, "slot_mask", data.visibility_slotmask, "ray_type", "ai_vision")

					if not vis_ray or vis_ray.unit:key() == u_key then
						acquired = true
						detected_obj[u_key] = CopLogicBase._create_detected_attention_object_data(data.t, data.unit, u_key, attention_info, settings)
					end
				end

				if not acquired then
					_chk_record_attention_obj_importance_wgt(u_key, attention_info)
				end
			end
		end
	end

	for u_key, attention_info in pairs(detected_obj) do
		if t < attention_info.next_verify_t then
			if AIAttentionObject.REACT_SUSPICIOUS <= attention_info.reaction then
				delay = math.min(attention_info.next_verify_t - t, delay)
			end
		else
			attention_info.next_verify_t = t + (attention_info.identified and attention_info.verified and attention_info.settings.verification_interval or attention_info.settings.notice_interval or attention_info.settings.verification_interval)
			delay = math.min(delay, attention_info.settings.verification_interval)

			if not attention_info.identified then
				local noticable = nil
				local angle, dis_multiplier = _angle_and_dis_chk(attention_info.handler, attention_info.settings)

				if angle then
					local attention_pos = attention_info.handler:get_detection_m_pos()
					local vis_ray = World:raycast("ray", my_pos, attention_pos, "slot_mask", data.visibility_slotmask, "ray_type", "ai_vision")

					if not vis_ray or vis_ray.unit:key() == u_key then
						noticable = true
					end
				end

				local delta_prog = nil
				local dt = t - attention_info.prev_notice_chk_t

				if noticable then
					if angle == -1 then
						delta_prog = 1
					else
						local min_delay = my_data.detection.delay[1]
						local max_delay = my_data.detection.delay[2]
						local angle_mul_mod = 0.25 * math.min(angle / my_data.detection.angle_max, 1)
						local dis_mul_mod = 0.75 * dis_multiplier
						local notice_delay_mul = attention_info.settings.notice_delay_mul or 1

						if attention_info.settings.detection and attention_info.settings.detection.delay_mul then
							notice_delay_mul = notice_delay_mul * attention_info.settings.detection.delay_mul
						end

						local notice_delay_modified = math.lerp(min_delay * notice_delay_mul, max_delay, dis_mul_mod + angle_mul_mod)
						delta_prog = notice_delay_modified > 0 and dt / notice_delay_modified or 1
					end
				else
					delta_prog = dt * -0.125
				end

				attention_info.notice_progress = attention_info.notice_progress + delta_prog

				if attention_info.notice_progress > 1 then
					attention_info.notice_progress = nil
					attention_info.prev_notice_chk_t = nil
					attention_info.identified = true
					attention_info.release_t = t + attention_info.settings.release_delay
					attention_info.identified_t = t
					noticable = true

					data.logic.on_attention_obj_identified(data, u_key, attention_info)
				elseif attention_info.notice_progress < 0 then
					CopLogicBase._destroy_detected_attention_object_data(data, attention_info)

					noticable = false
				else
					noticable = attention_info.notice_progress
					attention_info.prev_notice_chk_t = t

					if data.cool and AIAttentionObject.REACT_SCARED <= attention_info.settings.reaction then
						managers.groupai:state():on_criminal_suspicion_progress(attention_info.unit, data.unit, noticable)
					end
				end

				if noticable ~= false and attention_info.settings.notice_clbk then
					attention_info.settings.notice_clbk(data.unit, noticable)
				end
			end

			if attention_info.identified then
				delay = math.min(delay, attention_info.settings.verification_interval)
				attention_info.nearly_visible = nil
				local verified, vis_ray = nil
				local attention_pos = attention_info.handler:get_detection_m_pos()
				local dis = mvector3.distance(data.m_pos, attention_info.m_pos)

				if dis < my_data.detection.dis_max * 1.2 and (not attention_info.settings.max_range or dis < attention_info.settings.max_range * (attention_info.settings.detection and attention_info.settings.detection.range_mul or 1) * 1.2) then
					local detect_pos = nil

					if attention_info.is_husk_player and attention_info.unit:anim_data().crouch then
						detect_pos = tmp_vec1

						mvector3.set(detect_pos, attention_info.m_pos)
						mvector3.add(detect_pos, tweak_data.player.stances.default.crouched.head.translation)
					else
						detect_pos = attention_pos
					end

					local in_FOV = not attention_info.settings.notice_requires_FOV or data.enemy_slotmask and attention_info.unit:in_slot(data.enemy_slotmask) or _angle_chk(attention_pos, dis, 0.8)

					if in_FOV then
						vis_ray = World:raycast("ray", my_pos, detect_pos, "slot_mask", data.visibility_slotmask, "ray_type", "ai_vision")

						if not vis_ray or vis_ray.unit:key() == u_key then
							verified = true
						end
					end

					attention_info.verified = verified
				end

				attention_info.dis = dis
				attention_info.vis_ray = vis_ray and vis_ray.dis or nil
				local is_ignored = false

				if attention_info.unit:movement() and attention_info.unit:movement().is_cuffed then
					is_ignored = attention_info.unit:movement():is_cuffed()
				end

				if is_ignored then
					CopLogicBase._destroy_detected_attention_object_data(data, attention_info)
				elseif verified then
					attention_info.release_t = nil
					attention_info.verified_t = t

					mvector3.set(attention_info.verified_pos, attention_pos)

					attention_info.last_verified_pos = mvector3.copy(attention_pos)
					attention_info.verified_dis = dis
				elseif data.enemy_slotmask and attention_info.unit:in_slot(data.enemy_slotmask) then
					if attention_info.criminal_record and AIAttentionObject.REACT_COMBAT <= attention_info.settings.reaction then
						if not is_detection_persistent and mvector3.distance(attention_pos, attention_info.criminal_record.pos) > 700 then
							CopLogicBase._destroy_detected_attention_object_data(data, attention_info)
						else
							delay = math.min(0.2, delay)
							attention_info.verified_pos = mvector3.copy(attention_info.criminal_record.pos)
							attention_info.verified_dis = dis

							if vis_ray and data.logic._chk_nearly_visible_chk_needed(data, attention_info, u_key) then
								_nearly_visible_chk(attention_info, attention_pos)
							end
						end
					elseif attention_info.release_t and attention_info.release_t < t then
						CopLogicBase._destroy_detected_attention_object_data(data, attention_info)
					else
						attention_info.release_t = attention_info.release_t or t + attention_info.settings.release_delay
					end
				elseif attention_info.release_t and attention_info.release_t < t then
					CopLogicBase._destroy_detected_attention_object_data(data, attention_info)
				else
					attention_info.release_t = attention_info.release_t or t + attention_info.settings.release_delay
				end
			end
		end

		_chk_record_acquired_attention_importance_wgt(attention_info)
	end

	if player_importance_wgt then
		managers.groupai:state():set_importance_weight(data.key, player_importance_wgt)
	end

	return delay
end

function CopLogicBase._create_detected_attention_object_data(time, my_unit, u_key, attention_info, settings, forced)
	local ext_brain = my_unit:brain()

	attention_info.handler:add_listener("detect_" .. tostring(my_unit:key()), callback(ext_brain, ext_brain, "on_detected_attention_obj_modified"))

	local att_unit = attention_info.unit
	local m_pos = attention_info.handler:get_ground_m_pos()
	local m_head_pos = attention_info.handler:get_detection_m_pos()
	local is_local_player, is_husk_player, is_deployable, is_person, is_very_dangerous, nav_tracker, char_tweak, m_rot, is_shield = nil
	local is_alive = true

	if att_unit:base() then
		is_local_player = att_unit:base().is_local_player
		is_husk_player = att_unit:base().is_husk_player
		is_deployable = att_unit:base().sentry_gun
		is_person = att_unit:in_slot(managers.slot:get_mask("persons"))

		if att_unit:base().char_tweak then
			char_tweak = att_unit:base():char_tweak()
		end

		is_very_dangerous = att_unit:base()._tweak_table == "taser" or att_unit:base()._tweak_table == "spooc"
		is_shield = att_unit:base()._tweak_table == "shield" or att_unit:base()._tweak_table == "phalanx_minion"
	end

	if att_unit:movement() and att_unit:movement().m_rot then
		m_rot = att_unit:movement():m_rot()
	end

	if att_unit:character_damage() and att_unit:character_damage().dead then
		is_alive = not att_unit:character_damage():dead()
	end

	local dis = mvector3.distance(my_unit:movement():m_head_pos(), m_head_pos)
	local new_entry = {
		verified = false,
		verified_t = false,
		notice_progress = 0,
		settings = settings,
		unit = attention_info.unit,
		u_key = u_key,
		handler = attention_info.handler,
		next_verify_t = time + (settings.notice_interval or settings.verification_interval),
		prev_notice_chk_t = time,
		m_rot = m_rot,
		m_pos = m_pos,
		m_head_pos = m_head_pos,
		nav_tracker = attention_info.nav_tracker,
		is_local_player = is_local_player,
		is_husk_player = is_husk_player,
		is_human_player = is_local_player or is_husk_player,
		is_deployable = is_deployable,
		is_person = is_person,
		is_very_dangerous = is_very_dangerous,
		is_shield = is_shield,
		is_alive = is_alive,
		reaction = settings.reaction,
		criminal_record = managers.groupai:state():criminal_record(u_key),
		char_tweak = char_tweak,
		verified_pos = mvector3.copy(m_head_pos),
		verified_dis = dis,
		dis = dis,
		has_team = att_unit:movement() and att_unit:movement().team,
		health_ratio = att_unit:character_damage() and att_unit:character_damage().health_ratio,
		objective = att_unit:brain() and att_unit:brain().objective,
		forced = forced
	}

	return new_entry
end

function CopLogicBase._destroy_detected_attention_object_data(data, attention_info)
	attention_info.handler:remove_listener("detect_" .. tostring(data.key))

	if attention_info.settings.notice_clbk then
		attention_info.settings.notice_clbk(data.unit, false)
	end

	if AIAttentionObject.REACT_SUSPICIOUS <= attention_info.settings.reaction then
		managers.groupai:state():on_criminal_suspicion_progress(attention_info.unit, data.unit, nil)
	end

	if attention_info.uncover_progress then
		attention_info.unit:movement():on_suspicion(data.unit, false)
	end

	data.detected_attention_objects[attention_info.u_key] = nil
end

function CopLogicBase._destroy_all_detected_attention_object_data(data)
	for u_key, attention_info in pairs(data.detected_attention_objects) do
		attention_info.handler:remove_listener("detect_" .. tostring(data.key))

		if not attention_info.identified and attention_info.settings.notice_clbk then
			attention_info.settings.notice_clbk(data.unit, false)
		end

		if AIAttentionObject.REACT_SUSPICIOUS <= attention_info.settings.reaction then
			managers.groupai:state():on_criminal_suspicion_progress(attention_info.unit, data.unit, nil)
		end

		if attention_info.uncover_progress then
			attention_info.unit:movement():on_suspicion(data.unit, false)
		end
	end

	data.detected_attention_objects = {}
end

function CopLogicBase.on_detected_attention_obj_modified(data, modified_u_key)
	if data.logic.on_detected_attention_obj_modified_internal then
		data.logic.on_detected_attention_obj_modified_internal(data, modified_u_key)
	end

	local attention_info = data.detected_attention_objects[modified_u_key]

	if not attention_info then
		return
	end

	local new_settings = attention_info.handler:get_attention(data.SO_access, nil, nil, data.team)
	local old_settings = attention_info.settings

	if new_settings == old_settings then
		return
	end

	local old_notice_clbk = not attention_info.identified and old_settings.notice_clbk

	if new_settings then
		local switch_from_suspicious = AIAttentionObject.REACT_SCARED <= new_settings.reaction and attention_info.reaction <= AIAttentionObject.REACT_SUSPICIOUS
		attention_info.settings = new_settings
		attention_info.stare_expire_t = nil
		attention_info.pause_expire_t = nil

		if attention_info.uncover_progress then
			attention_info.uncover_progress = nil

			attention_info.unit:movement():on_suspicion(data.unit, false)
			managers.groupai:state():on_criminal_suspicion_progress(attention_info.unit, data.unit, nil)
		end

		if attention_info.identified then
			if switch_from_suspicious then
				attention_info.identified = false
				attention_info.notice_progress = attention_info.uncover_progress or 0
				attention_info.verified = nil
				attention_info.next_verify_t = 0
				attention_info.prev_notice_chk_t = TimerManager:game():time()
			end
		elseif switch_from_suspicious then
			attention_info.next_verify_t = 0
			attention_info.notice_progress = 0
			attention_info.prev_notice_chk_t = TimerManager:game():time()
		end

		attention_info.reaction = math.min(new_settings.reaction, attention_info.reaction)
	else
		CopLogicBase._destroy_detected_attention_object_data(data, attention_info)

		local my_data = data.internal_data

		if data.attention_obj and data.attention_obj.u_key == modified_u_key then
			CopLogicBase._set_attention_obj(data, nil, nil)

			if my_data and (my_data.firing or my_data.firing_on_client) then
				data.unit:movement():set_allow_fire(false)

				my_data.firing = nil
				my_data.firing_on_client = nil
			end
		end

		if my_data.arrest_targets then
			my_data.arrest_targets[modified_u_key] = nil
		end
	end

	if old_notice_clbk and (not new_settings or not new_settings.notice_clbk) then
		old_notice_clbk(data.unit, false)
	end

	if AIAttentionObject.REACT_SCARED <= old_settings.reaction and (not new_settings or AIAttentionObject.REACT_SCARED > new_settings.reaction) then
		managers.groupai:state():on_criminal_suspicion_progress(attention_info.unit, data.unit, nil)
	end
end

function CopLogicBase._set_attention_obj(data, new_att_obj, new_reaction)
	local old_att_obj = data.attention_obj
	data.attention_obj = new_att_obj

	if new_att_obj then
		new_reaction = new_reaction or new_att_obj.settings.reaction
		new_att_obj.reaction = new_reaction
		local new_crim_rec = new_att_obj.criminal_record
		local is_same_obj, contact_chatter_time_ok = nil

		if old_att_obj then
			if old_att_obj.u_key == new_att_obj.u_key then
				is_same_obj = true
				contact_chatter_time_ok = new_crim_rec and data.t - new_crim_rec.det_t > 2

				if new_att_obj.stare_expire_t and new_att_obj.stare_expire_t < data.t then
					if new_att_obj.settings.pause then
						new_att_obj.stare_expire_t = nil
						new_att_obj.pause_expire_t = data.t + math.lerp(new_att_obj.settings.pause[1], new_att_obj.settings.pause[2], math.random())
					end
				elseif new_att_obj.pause_expire_t and new_att_obj.pause_expire_t < data.t then
					if not new_att_obj.settings.attract_chance or math.random() < new_att_obj.settings.attract_chance then
						new_att_obj.pause_expire_t = nil
						new_att_obj.stare_expire_t = data.t + math.lerp(new_att_obj.settings.duration[1], new_att_obj.settings.duration[2], math.random())
					else
						debug_pause_unit(data.unit, "skipping attraction")

						new_att_obj.pause_expire_t = data.t + math.lerp(new_att_obj.settings.pause[1], new_att_obj.settings.pause[2], math.random())
					end
				end
			else
				if old_att_obj.criminal_record then
					managers.groupai:state():on_enemy_disengaging(data.unit, old_att_obj.u_key)
				end

				if new_crim_rec then
					managers.groupai:state():on_enemy_engaging(data.unit, new_att_obj.u_key)
				end

				contact_chatter_time_ok = new_crim_rec and data.t - new_crim_rec.det_t > 15
			end
		else
			if new_crim_rec then
				managers.groupai:state():on_enemy_engaging(data.unit, new_att_obj.u_key)
			end

			contact_chatter_time_ok = new_crim_rec and data.t - new_crim_rec.det_t > 15
		end

		if not is_same_obj then
			if new_att_obj.settings.duration then
				new_att_obj.stare_expire_t = data.t + math.lerp(new_att_obj.settings.duration[1], new_att_obj.settings.duration[2], math.random())
				new_att_obj.pause_expire_t = nil
			end

			new_att_obj.acquire_t = data.t
		end

		if AIAttentionObject.REACT_SHOOT <= new_reaction and new_att_obj.verified and contact_chatter_time_ok and (data.unit:anim_data().idle or data.unit:anim_data().move) and new_att_obj.is_person and data.char_tweak.chatter.contact then
			data.unit:sound():say("c01", true)
		end
	elseif old_att_obj and old_att_obj.criminal_record then
		managers.groupai:state():on_enemy_disengaging(data.unit, old_att_obj.u_key)
	end
end

function CopLogicBase._am_i_important_to_player(record, my_key)
	if record.important_enemies then
		for i, test_e_key in ipairs(record.important_enemies) do
			if test_e_key == my_key then
				return true
			end
		end
	end
end

function CopLogicBase.should_duck_on_alert(data, alert_data)
	if not data.important or data.char_tweak.allowed_poses and not data.char_tweak.allowed_poses.crouch or alert_data[1] == "voice" or data.unit:anim_data().crouch or data.unit:movement():chk_action_forbidden("walk") then
		return
	end

	local lower_body_action = data.unit:movement()._active_actions[2]

	if lower_body_action and lower_body_action:type() == "walk" and not data.char_tweak.crouch_move then
		return
	end
end

function CopLogicBase._chk_nearly_visible_chk_needed(data, attention_info, u_key)
	return not attention_info.criminal_record or attention_info.is_human_player and CopLogicBase._am_i_important_to_player(attention_info.criminal_record, data.key)
end

function CopLogicBase.is_obstructed(data, objective, strictness, attention)
	local my_data = data.internal_data
	attention = attention or data.attention_obj

	if not objective or objective.is_default or (objective.in_place or not objective.nav_seg) and not objective.action then
		return true, false
	end

	if objective.interrupt_suppression and data.is_suppressed then
		return true, true
	end

	strictness = strictness or 0

	if objective.interrupt_health then
		local health_ratio = data.unit:character_damage():health_ratio()
		local too_much_damage = health_ratio < 1 and health_ratio * (1 - strictness) < objective.interrupt_health
		local is_dead = data.unit:character_damage():dead()

		if too_much_damage or is_dead then
			return true, true
		end
	end

	if objective.interrupt_dis then
		if attention and (AIAttentionObject.REACT_COMBAT <= attention.reaction or data.cool and AIAttentionObject.REACT_SURPRISED <= attention.reaction) then
			if objective.interrupt_dis == -1 then
				return true, true
			elseif math.abs(attention.m_pos.z - data.m_pos.z) < 250 then
				local enemy_dis = attention.dis * (1 - strictness)

				if not attention.verified then
					enemy_dis = 2 * attention.dis * (1 - strictness)
				end

				if attention.is_very_dangerous then
					enemy_dis = enemy_dis * 0.25
				end

				if enemy_dis < objective.interrupt_dis then
					return true, true
				end
			end

			if objective.pos and math.abs(attention.m_pos.z - objective.pos.z) < 250 then
				local enemy_dis = mvector3.distance(objective.pos, attention.m_pos) * (1 - strictness)

				if enemy_dis < objective.interrupt_dis then
					return true, true
				end
			end
		elseif objective.interrupt_dis == -1 and not data.unit:movement():cool() then
			return true, true
		end
	end

	return false, false
end

function CopLogicBase._upd_suspicion(data, my_data, attention_obj)
	local function _exit_func()
		attention_obj.unit:movement():on_uncovered(data.unit)

		local reaction, state_name = nil

		if attention_obj.dis < 2000 and attention_obj.verified and not data.char_tweak.no_arrest and not attention_obj.forced then
			reaction = AIAttentionObject.REACT_ARREST
			state_name = "arrest"
		else
			reaction = AIAttentionObject.REACT_COMBAT
			state_name = "attack"
		end

		attention_obj.reaction = reaction
		local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, data.objective, nil, attention_obj)

		if allow_trans then
			if obj_failed then
				data.objective_failed_clbk(data.unit, data.objective)

				if my_data ~= data.internal_data then
					return true
				end
			end

			CopLogicBase._exit(data.unit, state_name)

			return true
		end
	end

	local dis = attention_obj.dis
	local susp_settings = attention_obj.unit:base():suspicion_settings()

	if attention_obj.settings.uncover_range and dis < math.min(attention_obj.settings.max_range, attention_obj.settings.uncover_range) * susp_settings.range_mul then
		attention_obj.unit:movement():on_suspicion(data.unit, true)
		managers.groupai:state():criminal_spotted(attention_obj.unit)

		return _exit_func()
	elseif attention_obj.verified and attention_obj.settings.suspicion_range and dis < math.min(attention_obj.settings.max_range, attention_obj.settings.suspicion_range) * susp_settings.range_mul then
		if attention_obj.last_suspicion_t then
			local dt = data.t - attention_obj.last_suspicion_t
			local range_max = (attention_obj.settings.suspicion_range - (attention_obj.settings.uncover_range or 0)) * susp_settings.range_mul
			local range_min = (attention_obj.settings.uncover_range or 0) * susp_settings.range_mul
			local mul = 1 - (dis - range_min) / range_max
			local progress = dt * mul * susp_settings.buildup_mul / attention_obj.settings.suspicion_duration
			attention_obj.uncover_progress = (attention_obj.uncover_progress or 0) + progress

			if attention_obj.uncover_progress < 1 then
				attention_obj.unit:movement():on_suspicion(data.unit, attention_obj.uncover_progress)
				managers.groupai:state():on_criminal_suspicion_progress(attention_obj.unit, data.unit, attention_obj.uncover_progress)
			else
				attention_obj.unit:movement():on_suspicion(data.unit, true)
				managers.groupai:state():criminal_spotted(attention_obj.unit)

				return _exit_func()
			end
		else
			attention_obj.uncover_progress = 0
		end

		attention_obj.last_suspicion_t = data.t
	elseif attention_obj.uncover_progress then
		if attention_obj.last_suspicion_t then
			local dt = data.t - attention_obj.last_suspicion_t
			attention_obj.uncover_progress = attention_obj.uncover_progress - dt

			if attention_obj.uncover_progress <= 0 then
				attention_obj.uncover_progress = nil
				attention_obj.last_suspicion_t = nil

				attention_obj.unit:movement():on_suspicion(data.unit, false)
			else
				attention_obj.unit:movement():on_suspicion(data.unit, attention_obj.uncover_progress)
			end
		else
			attention_obj.last_suspicion_t = data.t
		end
	end
end

function CopLogicBase.upd_suspicion_decay(data)
	local my_data = data.internal_data

	for u_key, u_data in pairs(data.detected_attention_objects) do
		if u_data.uncover_progress and u_data.last_suspicion_t ~= data.t then
			local dt = data.t - u_data.last_suspicion_t
			u_data.uncover_progress = u_data.uncover_progress - dt

			if u_data.uncover_progress <= 0 then
				u_data.uncover_progress = nil
				u_data.last_suspicion_t = nil

				u_data.unit:movement():on_suspicion(data.unit, false)
			else
				u_data.unit:movement():on_suspicion(data.unit, u_data.uncover_progress)

				u_data.last_suspicion_t = data.t
			end
		end
	end
end

function CopLogicBase._get_logic_state_from_reaction(data, reaction)
	if reaction == nil and data.attention_obj then
		reaction = data.attention_obj.reaction
	end

	local police_is_being_called = managers.groupai:state():chk_enemy_calling_in_area(managers.groupai:state():get_area_from_nav_seg_id(data.unit:movement():nav_tracker():nav_segment()), data.key)

	if not reaction or reaction <= AIAttentionObject.REACT_SCARED then
		if data.char_tweak.calls_in and not police_is_being_called and not managers.groupai:state():is_police_called() and not data.unit:movement():cool() and not data.is_converted then
			return "arrest"
		elseif data.unit:movement():cool() then
			-- Nothing
		else
			return "idle"
		end
	elseif reaction == AIAttentionObject.REACT_ARREST and not data.is_converted then
		return "arrest"
	elseif (data.char_tweak.calls_in or not data.char_tweak.no_arrest) and not police_is_being_called and not managers.groupai:state():is_police_called() and not data.unit:movement():cool() and not data.is_converted and (not data.attention_obj or not data.attention_obj.verified or data.attention_obj.dis >= 1500) and not data.attention_obj.forced then
		return "arrest"
	else
		return "attack"
	end
end

function CopLogicBase._chk_call_the_police(data)
	if not CopLogicBase._can_arrest(data) then
		return
	end

	local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, data.objective, nil, nil)

	if allow_trans and data.logic.is_available_for_assignment(data) and not data.is_converted and not data.unit:movement():cool() and not managers.groupai:state():is_police_called() and (not data.attention_obj or not data.attention_obj.verified_t or data.t - data.attention_obj.verified_t > 6 or data.attention_obj.reaction <= AIAttentionObject.REACT_ARREST) then
		if obj_failed then
			data.objective_failed_clbk(data.unit, data.objective)
		end

		if (not data.objective or data.objective.is_default) and not managers.groupai:state():chk_enemy_calling_in_area(managers.groupai:state():get_area_from_nav_seg_id(data.unit:movement():nav_tracker():nav_segment()), data.key) then
			CopLogicBase._exit(data.unit, "arrest")
		end
	end
end

function CopLogicBase.identify_attention_obj_instant(data, att_u_key)
	local att_obj_data = data.detected_attention_objects[att_u_key]
	local is_new = not att_obj_data

	if att_obj_data then
		mvector3.set(att_obj_data.verified_pos, att_obj_data.handler:get_detection_m_pos())

		att_obj_data.verified_dis = mvector3.distance(att_obj_data.verified_pos, data.unit:movement():m_stand_pos())

		if not att_obj_data.identified then
			att_obj_data.identified = true
			att_obj_data.identified_t = data.t
			att_obj_data.notice_progress = nil
			att_obj_data.prev_notice_chk_t = nil

			if att_obj_data.settings.notice_clbk then
				att_obj_data.settings.notice_clbk(data.unit, true)
			end

			data.logic.on_attention_obj_identified(data, att_u_key, att_obj_data)
		elseif att_obj_data.uncover_progress then
			att_obj_data.uncover_progress = nil

			att_obj_data.unit:movement():on_suspicion(data.unit, false)
		end
	else
		local attention_info = managers.groupai:state():get_AI_attention_objects_by_filter(data.SO_access_str)[att_u_key]

		if attention_info then
			local settings = attention_info.handler:get_attention(data.SO_access, nil, nil, data.team)

			if settings then
				att_obj_data = CopLogicBase._create_detected_attention_object_data(data.t, data.unit, att_u_key, attention_info, settings)
				att_obj_data.identified = true
				att_obj_data.identified_t = data.t
				att_obj_data.notice_progress = nil
				att_obj_data.prev_notice_chk_t = nil

				if att_obj_data.settings.notice_clbk then
					att_obj_data.settings.notice_clbk(data.unit, true)
				end

				data.detected_attention_objects[att_u_key] = att_obj_data

				data.logic.on_attention_obj_identified(data, att_u_key, att_obj_data)
			end
		end
	end

	return att_obj_data, is_new
end

function CopLogicBase.is_alert_aggressive(alert_type)
	return CopLogicBase._AGGRESSIVE_ALERT_TYPES[alert_type]
end

function CopLogicBase.is_alert_dangerous(alert_type)
	return CopLogicBase._DANGEROUS_ALERT_TYPES[alert_type]
end

function CopLogicBase._evaluate_reason_to_surrender(data, my_data, aggressor_unit)
	local surrender_tweak = data.char_tweak.surrender

	if not surrender_tweak then
		return
	end

	if surrender_tweak.base_chance >= 1 then
		return 0
	end

	local t = data.t

	if data.surrender_window and data.surrender_window.window_expire_t < t then
		data.unit:brain():on_surrender_chance()

		return
	end

	local hold_chance = 1
	local surrender_chk = {
		health = function (health_surrender)
			local health_ratio = data.unit:character_damage():health_ratio()

			if health_ratio < 1 then
				local min_setting, max_setting = nil

				for k, v in pairs(health_surrender) do
					if not min_setting or k < min_setting.k then
						min_setting = {
							k = k,
							v = v
						}
					end

					if not max_setting or max_setting.k < k then
						max_setting = {
							k = k,
							v = v
						}
					end
				end

				if health_ratio < max_setting.k then
					hold_chance = hold_chance * (1 - math.lerp(min_setting.v, max_setting.v, math.max(0, health_ratio - min_setting.k) / (max_setting.k - min_setting.k)))
				end
			end
		end,
		aggressor_dis = function (agg_dis_surrender)
			local agg_dis = mvec3_dis(data.m_pos, aggressor_unit:movement():m_pos())
			local min_setting, max_setting = nil

			for k, v in pairs(agg_dis_surrender) do
				if not min_setting or k < min_setting.k then
					min_setting = {
						k = k,
						v = v
					}
				end

				if not max_setting or max_setting.k < k then
					max_setting = {
						k = k,
						v = v
					}
				end
			end

			if agg_dis < max_setting.k then
				hold_chance = hold_chance * (1 - math.lerp(min_setting.v, max_setting.v, math.max(0, agg_dis - min_setting.k) / (max_setting.k - min_setting.k)))
			end
		end,
		weapon_down = function (weap_down_surrender)
			local anim_data = data.unit:anim_data()

			if anim_data.reload then
				hold_chance = hold_chance * (1 - weap_down_surrender)
			elseif anim_data.hurt then
				hold_chance = hold_chance * (1 - weap_down_surrender)
			elseif data.unit:movement():stance_name() == "ntl" then
				hold_chance = hold_chance * (1 - weap_down_surrender)
			end

			local ammo_max, ammo = data.unit:inventory():equipped_unit():base():ammo_info()

			if ammo == 0 then
				hold_chance = hold_chance * (1 - weap_down_surrender)
			end
		end,
		flanked = function (flanked_surrender)
			local dis = mvec3_dir(tmp_vec1, data.m_pos, aggressor_unit:movement():m_pos())

			if dis > 250 then
				local fwd = data.unit:movement():m_rot():y()
				local fwd_dot = mvec3_dot(fwd, tmp_vec1)

				if fwd_dot < -0.5 then
					hold_chance = hold_chance * (1 - flanked_surrender)
				end
			end
		end,
		unaware_of_aggressor = function (unaware_of_aggressor_surrender)
			local att_info = data.detected_attention_objects[aggressor_unit:key()]

			if not att_info or not att_info.identified or t - att_info.identified_t < 1 then
				hold_chance = hold_chance * (1 - unaware_of_aggressor_surrender)
			end
		end,
		enemy_weap_cold = function (enemy_weap_cold_surrender)
			if not managers.groupai:state():enemy_weapons_hot() then
				hold_chance = hold_chance * (1 - enemy_weap_cold_surrender)
			end
		end,
		isolated = function (isolated_surrender)
			if data.group and data.group.has_spawned and data.group.initial_size > 1 then
				local has_support = nil
				local max_dis_sq = 722500

				for u_key, u_data in pairs(data.group.units) do
					if u_key ~= data.key and mvec3_dis_sq(data.m_pos, u_data.m_pos) < max_dis_sq then
						has_support = true

						break
					end

					if not has_support then
						hold_chance = hold_chance * (1 - isolated_surrender)
					end
				end
			end
		end,
		pants_down = function (pants_down_surrender)
			local not_cool_t = data.unit:movement():not_cool_t()

			if (not not_cool_t or t - not_cool_t < 1.5) and not managers.groupai:state():enemy_weapons_hot() then
				hold_chance = hold_chance * (1 - pants_down_surrender)
			end
		end
	}

	for reason, reason_data in pairs(surrender_tweak.reasons) do
		surrender_chk[reason](reason_data)
	end

	if hold_chance >= 1 - (surrender_tweak.significant_chance or 0) then
		return 1
	end

	for factor, factor_data in pairs(surrender_tweak.factors) do
		surrender_chk[factor](factor_data)
	end

	if data.surrender_window then
		hold_chance = hold_chance * (1 - data.surrender_window.chance_mul)
	end

	if surrender_tweak.violence_timeout then
		local violence_t = data.unit:character_damage():last_suppression_t()

		if violence_t then
			local violence_dt = t - violence_t

			if violence_dt < surrender_tweak.violence_timeout then
				hold_chance = hold_chance + (1 - hold_chance) * (1 - violence_dt / surrender_tweak.violence_timeout)
			end
		end
	end

	return hold_chance < 1 and hold_chance
end

function CopLogicBase._can_arrest(data)
	return not data.char_tweak.no_arrest and (not data.objective or not data.objective.no_arrest)
end

function CopLogicBase.on_attention_obj_identified(data, attention_u_key, attention_info)
	if data.group then
		for u_key, u_data in pairs(data.group.units) do
			if u_key ~= data.key then
				if alive(u_data.unit) then
					u_data.unit:brain():clbk_group_member_attention_identified(data.unit, attention_u_key)
				else
					Application:error("[CopLogicBase.on_attention_obj_identified] destroyed group member", data.unit, inspect(data.group), inspect(u_data), u_key)
				end
			end
		end
	end
end

function CopLogicBase.on_suppressed_state(data)
	if data.is_suppressed and data.objective then
		local allow_trans, interrupt = CopLogicBase.is_obstructed(data, data.objective, nil, nil)

		if interrupt then
			data.objective_failed_clbk(data.unit, data.objective)
		end
	end
end

function CopLogicBase.chk_start_action_dodge(data, reason)
	if not data.char_tweak.dodge or not data.char_tweak.dodge.occasions[reason] then
		return
	end

	if data.dodge_timeout_t and data.t < data.dodge_timeout_t or data.dodge_chk_timeout_t and data.t < data.dodge_chk_timeout_t or data.unit:movement():chk_action_forbidden("walk") then
		return
	end

	local dodge_tweak = data.char_tweak.dodge.occasions[reason]
	data.dodge_chk_timeout_t = TimerManager:game():time() + math.lerp(dodge_tweak.check_timeout[1], dodge_tweak.check_timeout[2], math.random())

	if dodge_tweak.chance == 0 or dodge_tweak.chance < math.random() then
		return
	end

	local rand_nr = math.random()
	local total_chance = 0
	local variation, variation_data = nil

	for test_variation, test_variation_data in pairs(dodge_tweak.variations) do
		total_chance = total_chance + test_variation_data.chance

		if test_variation_data.chance > 0 and rand_nr <= total_chance then
			variation = test_variation
			variation_data = test_variation_data

			break
		end
	end

	local dodge_dir = Vector3()
	local face_attention = nil

	if data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction then
		mvec3_set(dodge_dir, data.attention_obj.m_pos)
		mvec3_sub(dodge_dir, data.m_pos)
		mvector3.set_z(dodge_dir, 0)
		mvector3.normalize(dodge_dir)

		if mvector3.dot(data.unit:movement():m_fwd(), dodge_dir) < 0 then
			return
		end

		mvector3.cross(dodge_dir, dodge_dir, math.UP)

		face_attention = true
	else
		mvector3.random_orthogonal(dodge_dir, math.UP)
	end

	local dodge_dir_reversed = false

	if math.random() < 0.5 then
		mvector3.negate(dodge_dir)

		dodge_dir_reversed = not dodge_dir_reversed
	end

	local prefered_space = 130
	local min_space = 90
	local ray_to_pos = tmp_vec1

	mvec3_set(ray_to_pos, dodge_dir)
	mvector3.multiply(ray_to_pos, 130)
	mvector3.add(ray_to_pos, data.m_pos)

	local ray_params = {
		trace = true,
		tracker_from = data.unit:movement():nav_tracker(),
		pos_to = ray_to_pos
	}
	local ray_hit1 = managers.navigation:raycast(ray_params)
	local dis = nil

	if ray_hit1 then
		local hit_vec = tmp_vec2

		mvec3_set(hit_vec, ray_params.trace[1])
		mvec3_sub(hit_vec, data.m_pos)
		mvec3_set_z(hit_vec, 0)

		dis = mvector3.length(hit_vec)

		mvec3_set(ray_to_pos, dodge_dir)
		mvector3.multiply(ray_to_pos, -130)
		mvector3.add(ray_to_pos, data.m_pos)

		ray_params.pos_to = ray_to_pos
		local ray_hit2 = managers.navigation:raycast(ray_params)

		if ray_hit2 then
			mvec3_set(hit_vec, ray_params.trace[1])
			mvec3_sub(hit_vec, data.m_pos)
			mvec3_set_z(hit_vec, 0)

			local prev_dis = dis
			dis = mvector3.length(hit_vec)

			if prev_dis < dis and min_space < dis then
				mvector3.negate(dodge_dir)

				dodge_dir_reversed = not dodge_dir_reversed
			end
		else
			mvector3.negate(dodge_dir)

			dis = nil
			dodge_dir_reversed = not dodge_dir_reversed
		end
	end

	if ray_hit1 and dis and dis < min_space then
		return
	end

	local dodge_side = nil

	if face_attention then
		if dodge_dir_reversed then
			dodge_side = "l"
		else
			dodge_side = "r"
		end
	else
		local fwd_dot = mvec3_dot(dodge_dir, data.unit:movement():m_fwd())
		local my_right = tmp_vec1

		mrotation.x(data.unit:movement():m_rot(), my_right)

		local right_dot = mvec3_dot(dodge_dir, my_right)

		if math.abs(fwd_dot) > 0.7071067690849 then
			if fwd_dot > 0 then
				dodge_side = "fwd"
			else
				dodge_side = "bwd"
			end
		elseif right_dot > 0 then
			dodge_side = "r"
		else
			dodge_side = "l"
		end
	end

	local body_part = 1
	local shoot_chance = variation_data.shoot_chance

	if shoot_chance and shoot_chance > 0 and math.random() < shoot_chance then
		body_part = 2
	end

	local action_data = {
		type = "dodge",
		body_part = body_part,
		variation = variation,
		side = dodge_side,
		direction = dodge_dir,
		timeout = variation_data.timeout,
		speed = data.char_tweak.dodge.speed,
		shoot_accuracy = variation_data.shoot_accuracy,
		blocks = {
			act = -1,
			tase = -1,
			bleedout = -1,
			dodge = -1,
			walk = -1,
			action = body_part == 1 and -1 or nil,
			aim = body_part == 1 and -1 or nil
		}
	}

	if variation ~= "side_step" then
		action_data.blocks.hurt = -1
		action_data.blocks.heavy_hurt = -1
	end

	local action = data.unit:movement():action_request(action_data)

	if action then
		local my_data = data.internal_data

		CopLogicAttack._cancel_cover_pathing(data, my_data)
		CopLogicAttack._cancel_charge(data, my_data)
		CopLogicAttack._cancel_expected_pos_path(data, my_data)
		CopLogicAttack._cancel_walking_to_cover(data, my_data, true)
	end

	return action
end

function CopLogicBase.chk_am_i_aimed_at(data, attention_obj, max_dot)
	if not attention_obj.is_person then
		return
	end

	if attention_obj.dis < 700 and max_dot > 0.3 then
		max_dot = math.lerp(0.3, max_dot, (attention_obj.dis - 50) / 650)
	end

	local enemy_look_dir = tmp_vec1

	mrotation.y(attention_obj.unit:movement():m_head_rot(), enemy_look_dir)

	local enemy_vec = tmp_vec2

	mvec3_dir(enemy_vec, attention_obj.m_head_pos, data.unit:movement():m_com())

	return max_dot < mvec3_dot(enemy_vec, enemy_look_dir)
end

function CopLogicBase._chk_alert_obstructed(my_listen_pos, alert_data)
	if alert_data[3] then
		local alert_epicenter = nil

		if alert_data[1] == "bullet" then
			alert_epicenter = tmp_vec1

			mvector3.step(alert_epicenter, alert_data[2], alert_data[6], 50)
		else
			alert_epicenter = alert_data[2]
		end

		local ray = World:raycast("ray", my_listen_pos, alert_epicenter, "slot_mask", managers.slot:get_mask("AI_visibility"), "ray_type", "ai_vision", "report")

		if ray then
			if alert_data[1] == "footstep" then
				return true
			end

			local my_dis_sq = mvector3.distance(my_listen_pos, alert_epicenter)
			local dampening = alert_data[1] == "bullet" and 0.5 or 0.25
			local effective_dis_sq = alert_data[3] * dampening
			effective_dis_sq = effective_dis_sq * effective_dis_sq

			if my_dis_sq > effective_dis_sq then
				return true
			end
		end
	end
end
