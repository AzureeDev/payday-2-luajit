local tmp_vec1 = Vector3()
CopLogicIdle = class(CopLogicBase)
CopLogicIdle.allowed_transitional_actions = {
	{
		"idle",
		"hurt",
		"dodge"
	},
	{
		"idle",
		"turn"
	},
	{
		"idle",
		"reload"
	},
	{
		"hurt",
		"stand",
		"crouch"
	}
}

function CopLogicIdle.enter(data, new_logic_name, enter_params)
	CopLogicBase.enter(data, new_logic_name, enter_params)

	local my_data = {
		unit = data.unit
	}
	local is_cool = data.unit:movement():cool()

	if is_cool then
		my_data.detection = data.char_tweak.detection.ntl
	else
		my_data.detection = data.char_tweak.detection.idle
	end

	local old_internal_data = data.internal_data

	if old_internal_data then
		my_data.turning = old_internal_data.turning

		if old_internal_data.firing then
			data.unit:movement():set_allow_fire(false)
		end

		if old_internal_data.shooting then
			data.unit:brain():action_request({
				body_part = 3,
				type = "idle"
			})
		end

		local lower_body_action = data.unit:movement()._active_actions[2]
		my_data.advancing = lower_body_action and lower_body_action:type() == "walk" and lower_body_action

		if old_internal_data.best_cover then
			my_data.best_cover = old_internal_data.best_cover

			managers.navigation:reserve_cover(my_data.best_cover[1], data.pos_rsrv_id)
		end

		if old_internal_data.nearest_cover then
			my_data.nearest_cover = old_internal_data.nearest_cover

			managers.navigation:reserve_cover(my_data.nearest_cover[1], data.pos_rsrv_id)
		end
	end

	data.internal_data = my_data
	local key_str = tostring(data.unit:key())
	my_data.detection_task_key = "CopLogicIdle.update" .. key_str

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicIdle.queued_update, data, data.t)

	if my_data.nearest_cover or my_data.best_cover then
		my_data.cover_update_task_key = "CopLogicIdle._update_cover" .. key_str

		CopLogicBase.add_delayed_clbk(my_data, my_data.cover_update_task_key, callback(CopLogicTravel, CopLogicTravel, "_update_cover", data), data.t + 1)
	end

	local objective = data.objective

	if objective then
		if (objective.nav_seg or objective.type == "follow") and not objective.in_place then
			debug_pause_unit(data.unit, "[CopLogicIdle.enter] wrong logic", data.unit)
		end

		my_data.scan = objective.scan
		my_data.rubberband_rotation = objective.rubberband_rotation and data.unit:movement():m_rot():y()
	else
		my_data.scan = true
	end

	if my_data.scan then
		my_data.stare_path_search_id = "stare" .. key_str
		my_data.wall_stare_task_key = "CopLogicIdle._chk_stare_into_wall" .. key_str
	end

	CopLogicIdle._chk_has_old_action(data, my_data)

	if my_data.scan and (not objective or not objective.action) then
		CopLogicBase.queue_task(my_data, my_data.wall_stare_task_key, CopLogicIdle._chk_stare_into_wall_1, data, data.t)
	end

	if is_cool then
		data.unit:brain():set_attention_settings({
			peaceful = true
		})
	else
		data.unit:brain():set_attention_settings({
			cbt = true
		})
	end

	local usage = data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage
	my_data.weapon_range = (data.char_tweak.weapon[usage] or {}).range

	data.unit:brain():set_update_enabled_state(false)
	CopLogicIdle._perform_objective_action(data, my_data, objective)

	if my_data ~= data.internal_data then
		return
	end
end

function CopLogicIdle.exit(data, new_logic_name, enter_params)
	CopLogicBase.exit(data, new_logic_name, enter_params)

	local my_data = data.internal_data

	data.unit:brain():cancel_all_pathing_searches()
	CopLogicBase.cancel_queued_tasks(my_data)
	CopLogicBase.cancel_delayed_clbks(my_data)

	if my_data.best_cover then
		managers.navigation:release_cover(my_data.best_cover[1])
	end

	if my_data.nearest_cover then
		managers.navigation:release_cover(my_data.nearest_cover[1])
	end

	data.brain:rem_pos_rsrv("path")
end

function CopLogicIdle.queued_update(data)
	local my_data = data.internal_data
	local delay = data.logic._upd_enemy_detection(data)

	if data.internal_data ~= my_data then
		CopLogicBase._report_detections(data.detected_attention_objects)

		return
	end

	local objective = data.objective

	if my_data.has_old_action then
		CopLogicIdle._upd_stop_old_action(data, my_data, objective)
		CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicIdle.queued_update, data, data.t + delay, data.important and true)

		return
	end

	if data.is_converted and (not data.objective or data.objective.type == "free") and (not data.path_fail_t or data.t - data.path_fail_t > 6) then
		managers.groupai:state():on_criminal_jobless(data.unit)

		if my_data ~= data.internal_data then
			return
		end
	end

	if CopLogicIdle._chk_exit_non_walkable_area(data) then
		return
	end

	if CopLogicIdle._chk_relocate(data) then
		return
	end

	CopLogicIdle._perform_objective_action(data, my_data, objective)
	CopLogicIdle._upd_stance_and_pose(data, my_data, objective)
	CopLogicIdle._upd_pathing(data, my_data)
	CopLogicIdle._upd_scan(data, my_data)

	if data.cool then
		CopLogicIdle.upd_suspicion_decay(data)
	end

	if data.internal_data ~= my_data then
		CopLogicBase._report_detections(data.detected_attention_objects)

		return
	end

	delay = data.important and 0 or delay or 0.3

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicIdle.queued_update, data, data.t + delay, data.important and true)
end

function CopLogicIdle._upd_enemy_detection(data)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local delay = CopLogicBase._upd_attention_obj_detection(data, nil, nil)
	local new_attention, new_prio_slot, new_reaction = CopLogicIdle._get_priority_attention(data, data.detected_attention_objects)

	CopLogicBase._set_attention_obj(data, new_attention, new_reaction)

	if new_reaction and AIAttentionObject.REACT_SUSPICIOUS < new_reaction then
		local objective = data.objective
		local wanted_state = nil
		local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, objective, nil, new_attention)

		if allow_trans then
			wanted_state = CopLogicBase._get_logic_state_from_reaction(data)
		end

		if wanted_state and wanted_state ~= data.name then
			if obj_failed then
				data.objective_failed_clbk(data.unit, data.objective)
			end

			if my_data == data.internal_data then
				CopLogicBase._exit(data.unit, wanted_state)
			end
		end
	end

	if my_data == data.internal_data then
		CopLogicBase._chk_call_the_police(data)

		if my_data ~= data.internal_data then
			return delay
		end
	end

	return delay
end

function CopLogicIdle._upd_pathing(data, my_data)
	if not data.pathing_results then
		return
	end

	local path = my_data.stare_path_search_id and data.pathing_results[my_data.stare_path_search_id]

	if path then
		data.pathing_results[my_data.stare_path_search_id] = nil

		if not next(data.pathing_results) then
			data.pathing_results = nil
		end

		if path ~= "failed" then
			my_data.stare_path = path

			CopLogicBase.queue_task(my_data, my_data.wall_stare_task_key, CopLogicIdle._chk_stare_into_wall_2, data, data.t)
		else
			print("[CopLogicIdle:_upd_pathing] stare path failed!", data.unit:key())

			local path_jobs = my_data.stare_path_pos

			table.remove(path_jobs)

			if #path_jobs ~= 0 then
				data.unit:brain():search_for_path(my_data.stare_path_search_id, path_jobs[#path_jobs])
			else
				my_data.stare_path_pos = nil
			end
		end
	end
end

function CopLogicIdle._upd_scan(data, my_data)
	if CopLogicIdle._chk_focus_on_attention_object(data, my_data) then
		return
	end

	if not data.logic.is_available_for_assignment(data) or data.unit:movement():chk_action_forbidden("walk") then
		return
	end

	if not my_data.stare_pos or not my_data.next_scan_t or data.t < my_data.next_scan_t then
		if not my_data.turning and my_data.fwd_offset then
			local return_spin = my_data.rubberband_rotation:to_polar_with_reference(data.unit:movement():m_rot():y(), math.UP).spin

			if math.abs(return_spin) < 15 then
				my_data.fwd_offset = nil
			end

			CopLogicIdle._turn_by_spin(data, my_data, return_spin)
		end

		return
	end

	local beanbag = my_data.scan_beanbag

	if not beanbag then
		beanbag = {}

		for i_pos, pos in ipairs(my_data.stare_pos) do
			table.insert(beanbag, pos)
		end

		my_data.scan_beanbag = beanbag
	end

	local nr_pos = #beanbag
	local scan_pos = nil
	local lucky_i_pos = math.random(nr_pos)
	scan_pos = beanbag[lucky_i_pos]

	if #beanbag == 1 then
		my_data.scan_beanbag = nil
	else
		beanbag[lucky_i_pos] = beanbag[#beanbag]

		table.remove(beanbag)
	end

	CopLogicBase._set_attention_on_pos(data, scan_pos)

	if CopLogicIdle._chk_request_action_turn_to_look_pos(data, my_data, data.m_pos, scan_pos) then
		if my_data.rubberband_rotation then
			my_data.fwd_offset = true
		end

		local upper_body_action = data.unit:movement()._active_actions[3]

		if not upper_body_action then
			local idle_action = {
				body_part = 3,
				type = "idle"
			}

			data.unit:movement():action_request(idle_action)
		end
	end

	my_data.next_scan_t = data.t + math.random(3, 10)
end

function CopLogicIdle.damage_clbk(data, damage_info)
	local enemy = damage_info.attacker_unit
	local enemy_data = nil

	if enemy and enemy:in_slot(data.enemy_slotmask) then
		local my_data = data.internal_data
		local enemy_key = enemy:key()
		enemy_data = data.detected_attention_objects[enemy_key]
		local t = TimerManager:game():time()

		if enemy_data then
			enemy_data.verified_t = t
			enemy_data.verified = true

			mvector3.set(enemy_data.verified_pos, enemy:movement():m_stand_pos())

			enemy_data.verified_dis = mvector3.distance(enemy_data.verified_pos, data.unit:movement():m_stand_pos())
			enemy_data.dmg_t = t
			enemy_data.alert_t = t
			enemy_data.notice_delay = nil

			if not enemy_data.identified then
				enemy_data.identified = true
				enemy_data.identified_t = t
				enemy_data.notice_progress = nil
				enemy_data.prev_notice_chk_t = nil

				if enemy_data.settings.notice_clbk then
					enemy_data.settings.notice_clbk(data.unit, true)
				end

				data.logic.on_attention_obj_identified(data, enemy_key, enemy_data)
			end
		else
			local attention_info = managers.groupai:state():get_AI_attention_objects_by_filter(data.SO_access_str)[enemy_key]

			if attention_info then
				local settings = attention_info.handler:get_attention(data.SO_access, nil, nil, data.team)

				if settings then
					enemy_data = CopLogicBase._create_detected_attention_object_data(data.t, data.unit, enemy_key, attention_info, settings)
					enemy_data.verified_t = t
					enemy_data.verified = true
					enemy_data.dmg_t = t
					enemy_data.alert_t = t
					enemy_data.identified = true
					enemy_data.identified_t = t
					enemy_data.notice_progress = nil
					enemy_data.prev_notice_chk_t = nil

					if enemy_data.settings.notice_clbk then
						enemy_data.settings.notice_clbk(data.unit, true)
					end

					data.detected_attention_objects[enemy_key] = enemy_data

					data.logic.on_attention_obj_identified(data, enemy_key, enemy_data)
				end
			end
		end
	end

	if enemy_data and enemy_data.criminal_record then
		managers.groupai:state():criminal_spotted(enemy)
		managers.groupai:state():report_aggression(enemy)
	end
end

function CopLogicIdle.on_alert(data, alert_data)
	local alert_type = alert_data[1]
	local alert_unit = alert_data[5]

	if CopLogicBase._chk_alert_obstructed(data.unit:movement():m_head_pos(), alert_data) then
		return
	end

	local was_cool = data.cool

	if CopLogicBase.is_alert_aggressive(alert_type) then
		data.unit:movement():set_cool(false, managers.groupai:state().analyse_giveaway(data.unit:base()._tweak_table, alert_data[5], alert_data))
	end

	if alert_unit and alive(alert_unit) and alert_unit:in_slot(data.enemy_slotmask) then
		local att_obj_data, is_new = CopLogicBase.identify_attention_obj_instant(data, alert_unit:key())

		if not att_obj_data then
			return
		end

		if alert_type == "bullet" or alert_type == "aggression" or alert_type == "explosion" then
			att_obj_data.alert_t = TimerManager:game():time()
		end

		local action_data = nil

		if is_new and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.stand) and AIAttentionObject.REACT_SURPRISED <= att_obj_data.reaction and data.unit:anim_data().idle and not data.unit:movement():chk_action_forbidden("walk") then
			action_data = {
				variant = "surprised",
				body_part = 1,
				type = "act"
			}

			data.unit:brain():action_request(action_data)
		end

		if not action_data and alert_type == "bullet" and data.logic.should_duck_on_alert(data, alert_data) then
			action_data = CopLogicAttack._chk_request_action_crouch(data)
		end

		if att_obj_data.criminal_record then
			managers.groupai:state():criminal_spotted(alert_unit)

			if alert_type == "bullet" or alert_type == "aggression" or alert_type == "explosion" then
				managers.groupai:state():report_aggression(alert_unit)
			end
		end
	elseif was_cool and (alert_type == "footstep" or alert_type == "bullet" or alert_type == "aggression" or alert_type == "explosion" or alert_type == "vo_cbt" or alert_type == "vo_intimidate" or alert_type == "vo_distress") then
		local attention_obj = alert_unit and alert_unit:brain() and alert_unit:brain()._logic_data.attention_obj

		if attention_obj then
			local att_obj_data, is_new = CopLogicBase.identify_attention_obj_instant(data, attention_obj.u_key)
		end
	end
end

function CopLogicIdle.on_new_objective(data, old_objective)
	local new_objective = data.objective

	CopLogicBase.on_new_objective(data, old_objective)

	local my_data = data.internal_data

	if new_objective then
		local objective_type = new_objective.type

		if CopLogicIdle._chk_objective_needs_travel(data, new_objective) then
			CopLogicBase._exit(data.unit, "travel")
		elseif objective_type == "guard" then
			CopLogicBase._exit(data.unit, "guard")
		elseif objective_type == "security" then
			CopLogicBase._exit(data.unit, "idle")
		elseif objective_type == "sniper" then
			CopLogicBase._exit(data.unit, "sniper")
		elseif objective_type == "phalanx" then
			CopLogicBase._exit(data.unit, "phalanx")
		elseif objective_type == "surrender" then
			CopLogicBase._exit(data.unit, "intimidated", new_objective.params)
		elseif objective_type == "free" and my_data.exiting then
			-- Nothing
		elseif new_objective.action or not data.attention_obj or AIAttentionObject.REACT_AIM > data.attention_obj.reaction then
			CopLogicBase._exit(data.unit, "idle")
		else
			CopLogicBase._exit(data.unit, "attack")
		end
	elseif not my_data.exiting then
		CopLogicBase._exit(data.unit, "idle")
	end

	if new_objective and new_objective.stance then
		if new_objective.stance == "ntl" then
			data.unit:movement():set_cool(true)
		else
			data.unit:movement():set_cool(false)
		end
	end

	if old_objective and old_objective.fail_clbk then
		old_objective.fail_clbk(data.unit)
	end
end

function CopLogicIdle._chk_reaction_to_attention_object(data, attention_data, stationary)
	local record = attention_data.criminal_record
	local can_arrest = CopLogicBase._can_arrest(data)

	if not record or not attention_data.is_person then
		if attention_data.settings.reaction == AIAttentionObject.REACT_ARREST and not can_arrest then
			return AIAttentionObject.REACT_AIM
		else
			return attention_data.settings.reaction
		end
	end

	local att_unit = attention_data.unit

	if attention_data.is_deployable or data.t < record.arrest_timeout then
		return math.min(attention_data.settings.reaction, AIAttentionObject.REACT_COMBAT)
	end

	local visible = attention_data.verified

	if record.status == "dead" then
		return math.min(attention_data.settings.reaction, AIAttentionObject.REACT_AIM)
	elseif record.status == "disabled" then
		if record.assault_t and record.assault_t - record.disabled_t > 0.6 then
			return math.min(attention_data.settings.reaction, AIAttentionObject.REACT_COMBAT)
		else
			return math.min(attention_data.settings.reaction, AIAttentionObject.REACT_AIM)
		end
	elseif record.being_arrested then
		return math.min(attention_data.settings.reaction, AIAttentionObject.REACT_AIM)
	elseif can_arrest and (not record.assault_t or att_unit:base():arrest_settings().aggression_timeout < data.t - record.assault_t) and record.arrest_timeout < data.t and not record.status then
		local under_threat = nil

		if attention_data.dis < 2000 then
			for u_key, other_crim_rec in pairs(managers.groupai:state():all_criminals()) do
				local other_crim_attention_info = data.detected_attention_objects[u_key]

				if other_crim_attention_info and (other_crim_attention_info.is_deployable or other_crim_attention_info.verified and other_crim_rec.assault_t and data.t - other_crim_rec.assault_t < other_crim_rec.unit:base():arrest_settings().aggression_timeout) then
					under_threat = true

					break
				end
			end
		end

		if under_threat then
			-- Nothing
		elseif attention_data.dis < 2000 and visible then
			return math.min(attention_data.settings.reaction, AIAttentionObject.REACT_ARREST)
		else
			return math.min(attention_data.settings.reaction, AIAttentionObject.REACT_AIM)
		end
	end

	return math.min(attention_data.settings.reaction, AIAttentionObject.REACT_COMBAT)
end

function CopLogicIdle.on_criminal_neutralized(data, criminal_key)
end

function CopLogicIdle.on_intimidated(data, amount, aggressor_unit)
	local surrender = false
	local my_data = data.internal_data
	data.t = TimerManager:game():time()

	if not aggressor_unit:movement():team().foes[data.unit:movement():team().id] then
		return
	end

	if managers.groupai:state():has_room_for_police_hostage() then
		local i_am_special = managers.groupai:state():is_enemy_special(data.unit)
		local required_skill = i_am_special and "intimidate_specials" or "intimidate_enemies"
		local aggressor_can_intimidate = nil
		local aggressor_intimidation_mul = 1

		if aggressor_unit:base().is_local_player then
			aggressor_can_intimidate = managers.player:has_category_upgrade("player", required_skill)
			aggressor_intimidation_mul = aggressor_intimidation_mul * managers.player:upgrade_value("player", "empowered_intimidation_mul", 1) * managers.player:upgrade_value("player", "intimidation_multiplier", 1)
		else
			aggressor_can_intimidate = aggressor_unit:base():upgrade_value("player", required_skill)
			aggressor_intimidation_mul = aggressor_intimidation_mul * (aggressor_unit:base():upgrade_value("player", "empowered_intimidation_mul") or 1) * (aggressor_unit:base():upgrade_value("player", "intimidation_multiplier") or 1)
		end

		if aggressor_can_intimidate then
			local hold_chance = CopLogicBase._evaluate_reason_to_surrender(data, my_data, aggressor_unit)

			if hold_chance then
				hold_chance = hold_chance^aggressor_intimidation_mul

				if hold_chance >= 1 then
					-- Nothing
				else
					local rand_nr = math.random()

					print("and the winner is: hold_chance", hold_chance, "rand_nr", rand_nr, "rand_nr > hold_chance", hold_chance < rand_nr)

					if hold_chance < rand_nr then
						surrender = true
					end
				end
			end
		end

		if surrender then
			CopLogicIdle._surrender(data, amount, aggressor_unit)
		else
			data.unit:brain():on_surrender_chance()
		end
	end

	CopLogicBase.identify_attention_obj_instant(data, aggressor_unit:key())
	managers.groupai:state():criminal_spotted(aggressor_unit)

	return surrender
end

function CopLogicIdle._surrender(data, amount, aggressor_unit)
	local params = {
		effect = amount,
		aggressor_unit = aggressor_unit
	}

	data.brain:set_objective({
		type = "surrender",
		params = params
	})
end

function CopLogicIdle._chk_stare_into_wall_1(data)
	local groupai_state = managers.groupai:state()
	local my_tracker = data.unit:movement():nav_tracker()
	local my_nav_seg = my_tracker:nav_segment()
	local my_area = groupai_state:get_area_from_nav_seg_id(my_nav_seg)
	local is_enemy = data.unit:in_slot(managers.slot:get_mask("enemies"))
	local found_areas = {
		[my_area] = true
	}
	local areas_to_search = {
		my_area
	}
	local dangerous_far_areas = {}

	while next(areas_to_search) do
		local test_area = table.remove(areas_to_search, 1)
		local expand = nil

		if is_enemy then
			if next(test_area.criminal.units) then
				if test_area == my_area then
					break
				end

				dangerous_far_areas[test_area] = true
			else
				expand = true
			end
		elseif next(test_area.police.units) then
			if test_area == my_area then
				break
			end

			dangerous_far_areas[test_area] = true
		else
			expand = true
		end

		if expand then
			for n_area_id, n_area in pairs(test_area.neighbours) do
				if not found_areas[n_area] then
					found_areas[n_area] = test_area

					table.insert(areas_to_search, n_area)
				end
			end
		end
	end

	local dangerous_near_areas = {}

	for area, _ in pairs(dangerous_far_areas) do
		local backwards_area = area

		while true do
			if found_areas[backwards_area] == my_area then
				dangerous_near_areas[backwards_area] = true

				break
			else
				backwards_area = found_areas[backwards_area]
			end
		end
	end

	local my_data = data.internal_data
	local walk_from_pos = data.m_pos
	local ray_from_pos = data.unit:movement():m_stand_pos()
	local ray_to_pos = Vector3()
	local nav_manager = managers.navigation
	local all_nav_segs = nav_manager._nav_segments
	local my_tracker = data.unit:movement():nav_tracker()
	local walk_params = {
		tracker_from = my_tracker
	}
	local slotmask = data.visibility_slotmask
	local mvec3_set = mvector3.set
	local mvec3_set_z = mvector3.set_z
	local stare_pos = {}
	local path_tasks = {}

	for area, _ in pairs(dangerous_near_areas) do
		local nav_seg_id = area.pos_nav_seg
		local nav_seg = all_nav_segs[area.pos_nav_seg]

		if not nav_seg.disabled then
			local seg_pos = nav_manager:find_random_position_in_segment(nav_seg_id)
			walk_params.pos_to = seg_pos
			local ray_hit = nav_manager:raycast(walk_params)

			if ray_hit then
				mvec3_set(ray_to_pos, seg_pos)
				mvec3_set_z(ray_to_pos, ray_to_pos.z + 160)

				ray_hit = World:raycast("ray", ray_from_pos, ray_to_pos, "slot_mask", slotmask)

				if ray_hit then
					table.insert(path_tasks, seg_pos)
				else
					table.insert(stare_pos, ray_to_pos)
				end
			end

			if not ray_hit then
				table.insert(stare_pos, seg_pos + math.UP * 160)
			end
		end
	end

	if #stare_pos > 0 then
		my_data.stare_pos = stare_pos
		my_data.next_scan_t = 0
	end

	if #path_tasks > 0 then
		my_data.stare_path_pos = path_tasks

		data.unit:brain():search_for_path(my_data.stare_path_search_id, path_tasks[#path_tasks])
	end
end

function CopLogicIdle._chk_valid_stare_path(data)
	local my_data = data.internal_data
	local stare_path = my_data.stare_path

	if not stare_path then
		return false
	end

	for i, nav_point in ipairs(stare_path) do
		if not nav_point.x and not alive(nav_point) then
			debug_pause_unit(data.unit, "dead nav_link", data.unit)

			return false
		end
	end

	return true
end

function CopLogicIdle._chk_stare_into_wall_2(data)
	local my_data = data.internal_data
	local slotmask = data.visibility_slotmask
	local path_jobs = my_data.stare_path_pos
	local stare_path = my_data.stare_path
	local f_nav_point_pos = CopLogicIdle._nav_point_pos

	if not CopLogicIdle._chk_valid_stare_path(data) then
		return
	end

	for i, nav_point in ipairs(stare_path) do
		stare_path[i] = f_nav_point_pos(nav_point)
	end

	local mvec3_dis = mvector3.distance
	local mvec3_lerp = mvector3.lerp
	local mvec3_cpy = mvector3.copy
	local mvec3_set = mvector3.set
	local mvec3_set_z = mvector3.set_z
	local dis_table = {}
	local total_dis = 0
	local nr_nodes = #stare_path
	local i_node = 1
	local this_pos = stare_path[1]

	repeat
		local next_pos = stare_path[i_node + 1]
		local dis = mvec3_dis(this_pos, next_pos)
		total_dis = total_dis + dis

		table.insert(dis_table, dis)

		this_pos = next_pos
		i_node = i_node + 1
	until i_node == nr_nodes

	local nr_loops = 5
	local dis_step = total_dis / (nr_loops + 1)
	local ray_from_pos = data.unit:movement():m_stand_pos()
	local ray_to_pos = Vector3()
	local furthest_good_pos = nil
	local dis_in_seg = 0
	local index = nr_nodes
	local i_loop = 0

	repeat
		dis_in_seg = dis_in_seg + dis_step
		local seg_dis = dis_table[index - 1]

		while seg_dis < dis_in_seg do
			index = index - 1
			dis_in_seg = dis_in_seg - seg_dis
			seg_dis = dis_table[index - 1]
		end

		mvec3_lerp(ray_to_pos, stare_path[index], stare_path[index - 1], dis_in_seg / seg_dis)
		mvec3_set_z(ray_to_pos, ray_to_pos.z + 160)

		local hit = World:raycast("ray", ray_from_pos, ray_to_pos, "slot_mask", slotmask, "ray_type", "ai_vision")

		if not hit then
			if not my_data.stare_pos then
				my_data.next_scan_t = 0
				my_data.stare_pos = {}
			end

			table.insert(my_data.stare_pos, ray_to_pos)

			break
		end

		i_loop = i_loop + 1
	until i_loop == nr_loops

	my_data.stare_path = nil

	table.remove(path_jobs)

	if #path_jobs > 0 then
		data.unit:brain():search_for_path(my_data.stare_path_search_id, path_jobs[#path_jobs])
	else
		my_data.stare_path_pos = nil

		CopLogicBase.queue_task(my_data, my_data.wall_stare_task_key, CopLogicIdle._chk_stare_into_wall_1, data, data.t + 2)
	end
end

function CopLogicIdle._chk_request_action_turn_to_look_pos(data, my_data, my_pos, look_pos)
	local turn_angle = CopLogicIdle._chk_turn_needed(data, my_data, my_pos, look_pos)

	if not turn_angle then
		return
	end

	local err_to_correct_abs = math.abs(turn_angle)
	local angle_str = nil

	if err_to_correct_abs < 5 then
		return
	end

	return CopLogicIdle._turn_by_spin(data, my_data, turn_angle)
end

function CopLogicIdle.on_area_safety(data, nav_seg, safe, event)
	if not safe and event.reason == "criminal" then
		local my_data = data.internal_data
		local u_criminal = event.record.unit
		local key_criminal = u_criminal:key()

		if not data.detected_attention_objects[key_criminal] then
			local attention_info = managers.groupai:state():get_AI_attention_objects_by_filter(data.SO_access_str)[key_criminal]

			if attention_info then
				local settings = attention_info.handler:get_attention(data.SO_access, nil, nil, data.team)

				if settings then
					data.detected_attention_objects[key_criminal] = CopLogicBase._create_detected_attention_object_data(data.t, data.unit, key_criminal, attention_info, settings)
				end
			end
		end
	end
end

function CopLogicIdle.action_complete_clbk(data, action)
	local action_type = action:type()

	if action_type == "turn" then
		data.internal_data.turning = nil

		if data.internal_data.fwd_offset then
			local return_spin = data.internal_data.rubberband_rotation:to_polar_with_reference(data.unit:movement():m_rot():y(), math.UP).spin

			if math.abs(return_spin) < 15 then
				data.internal_data.fwd_offset = nil
			end
		end
	elseif action_type == "act" then
		local my_data = data.internal_data

		if my_data.action_started == action then
			if my_data.scan and not my_data.exiting and (not my_data.queued_tasks or not my_data.queued_tasks[my_data.wall_stare_task_key]) and not my_data.stare_path_pos then
				CopLogicBase.queue_task(my_data, my_data.wall_stare_task_key, CopLogicIdle._chk_stare_into_wall_1, data, data.t)
			end

			if action:expired() then
				if not my_data.action_timeout_clbk_id then
					data.objective_complete_clbk(data.unit, data.objective)
				end
			elseif not my_data.action_expired then
				data.objective_failed_clbk(data.unit, data.objective)
			end
		end
	elseif action_type == "hurt" and data.important and action:expired() then
		CopLogicBase.chk_start_action_dodge(data, "hit")
	end
end

function CopLogicIdle.is_available_for_assignment(data, objective)
	if objective and objective.forced then
		return true
	end

	local my_data = data.internal_data

	if data.objective and data.objective.action then
		if my_data.action_started then
			if not data.unit:anim_data().act_idle then
				return
			end
		else
			return
		end
	end

	if my_data.exiting or data.path_fail_t and data.t < data.path_fail_t + 6 then
		return
	end

	return true
end

function CopLogicIdle.clbk_action_timeout(ignore_this, data)
	local my_data = data.internal_data

	CopLogicBase.on_delayed_clbk(my_data, my_data.action_timeout_clbk_id)

	my_data.action_timeout_clbk_id = nil

	if not data.objective then
		debug_pause_unit(data.unit, "[CopLogicIdle.clbk_action_timeout] missing objective")

		return
	end

	my_data.action_expired = true

	if data.unit:anim_data().act and data.unit:anim_data().needs_idle then
		CopLogicIdle._start_idle_action_from_act(data)
	end

	data.objective_complete_clbk(data.unit, data.objective)
end

function CopLogicIdle._nav_point_pos(nav_point)
	return nav_point.x and nav_point or nav_point:script_data().element:value("position")
end

function CopLogicIdle._chk_relocate(data)
	if data.objective and data.objective.type == "follow" then
		if data.is_converted then
			if TeamAILogicIdle._check_should_relocate(data, data.internal_data, data.objective) then
				data.objective.in_place = nil

				data.logic._exit(data.unit, "travel")

				return true
			end

			return
		end

		if data.is_tied and data.objective.lose_track_dis and data.objective.lose_track_dis * data.objective.lose_track_dis < mvector3.distance_sq(data.m_pos, data.objective.follow_unit:movement():m_pos()) then
			data.brain:set_objective(nil)

			return true
		end

		local relocate = nil
		local follow_unit = data.objective.follow_unit
		local advance_pos = follow_unit:brain() and follow_unit:brain():is_advancing()
		local follow_unit_pos = advance_pos or follow_unit:movement():m_pos()

		if data.objective.relocated_to and mvector3.equal(data.objective.relocated_to, follow_unit_pos) then
			return
		end

		if data.objective.distance and data.objective.distance < mvector3.distance(data.m_pos, follow_unit_pos) then
			relocate = true
		end

		if not relocate then
			local ray_params = {
				tracker_from = data.unit:movement():nav_tracker(),
				pos_to = follow_unit_pos
			}
			local ray_res = managers.navigation:raycast(ray_params)

			if ray_res then
				relocate = true
			end
		end

		if relocate then
			data.objective.in_place = nil
			data.objective.nav_seg = follow_unit:movement():nav_tracker():nav_segment()
			data.objective.relocated_to = mvector3.copy(follow_unit_pos)

			data.logic._exit(data.unit, "travel")

			return true
		end
	elseif data.objective and data.objective.type == "defend_area" then
		local area = data.objective.area

		if area and not next(area.criminal.units) then
			local found_areas = {
				[area] = true
			}
			local areas_to_search = {
				area
			}
			local target_area = nil

			while next(areas_to_search) do
				local current_area = table.remove(areas_to_search)

				if next(current_area.criminal.units) then
					target_area = current_area

					break
				end

				for _, n_area in pairs(current_area.neighbours) do
					if not found_areas[n_area] then
						found_areas[n_area] = true

						table.insert(areas_to_search, n_area)
					end
				end
			end

			if target_area then
				data.objective.in_place = nil
				data.objective.nav_seg = next(target_area.nav_segs)
				data.objective.path_data = {
					{
						data.objective.nav_seg
					}
				}

				data.logic._exit(data.unit, "travel")

				return true
			end
		end
	end
end

function CopLogicIdle._chk_exit_non_walkable_area(data)
	local my_data = data.internal_data

	if my_data.advancing or my_data.old_action_advancing or not CopLogicAttack._can_move(data) or data.unit:movement():chk_action_forbidden("walk") then
		return
	end

	local my_tracker = data.unit:movement():nav_tracker()

	if not my_tracker:obstructed() then
		return
	end

	if data.objective and data.objective.nav_seg then
		local nav_seg_id = my_tracker:nav_segment()

		if not managers.navigation._nav_segments[nav_seg_id].disabled then
			data.objective.in_place = nil

			data.logic.on_new_objective(data, data.objective)

			return true
		end
	end
end

function CopLogicIdle._get_all_paths(data)
	return {
		stare_path = data.internal_data.stare_path
	}
end

function CopLogicIdle._set_verified_paths(data, verified_paths)
	data.internal_data.stare_path = verified_paths.stare_path
end

function CopLogicIdle._chk_focus_on_attention_object(data, my_data)
	local current_attention = data.attention_obj

	if not current_attention then
		local set_attention = data.unit:movement():attention()

		if set_attention and set_attention.handler then
			CopLogicBase._reset_attention(data)
		end

		return
	end

	if my_data.turning then
		return
	end

	if (current_attention.reaction == AIAttentionObject.REACT_CURIOUS or current_attention.reaction == AIAttentionObject.REACT_SUSPICIOUS) and CopLogicIdle._upd_curious_reaction(data) then
		return true
	end

	if data.logic.is_available_for_assignment(data) and not data.unit:movement():chk_action_forbidden("walk") then
		local attention_pos = current_attention.handler:get_attention_m_pos(current_attention.settings)
		local turn_angle = CopLogicIdle._chk_turn_needed(data, my_data, data.m_pos, attention_pos)

		if turn_angle and current_attention.reaction < AIAttentionObject.REACT_CURIOUS then
			if turn_angle > 70 then
				return
			else
				turn_angle = nil
			end
		end

		if turn_angle then
			local err_to_correct_abs = math.abs(turn_angle)
			local angle_str = nil

			if err_to_correct_abs > 40 then
				if not CopLogicIdle._turn_by_spin(data, my_data, turn_angle) then
					return
				end

				if my_data.rubberband_rotation then
					my_data.fwd_offset = true
				end
			end
		end
	end

	local set_attention = data.unit:movement():attention()

	if not set_attention or set_attention.u_key ~= current_attention.u_key then
		CopLogicBase._set_attention(data, current_attention, nil)
	end

	return true
end

function CopLogicIdle._chk_turn_needed(data, my_data, my_pos, look_pos)
	local fwd = data.unit:movement():m_rot():y()
	local target_vec = look_pos - my_pos
	local error_polar = target_vec:to_polar_with_reference(fwd, math.UP)
	local error_spin = error_polar.spin
	local abs_err_spin = math.abs(error_spin)
	local tolerance = error_spin < 0 and 50 or 30
	local err_to_correct = error_spin - tolerance * math.sign(error_spin)

	if math.sign(err_to_correct) ~= math.sign(error_spin) then
		return
	end

	return err_to_correct
end

function CopLogicIdle._get_priority_attention(data, attention_objects, reaction_func)
	reaction_func = reaction_func or CopLogicIdle._chk_reaction_to_attention_object
	local best_target, best_target_priority_slot, best_target_priority, best_target_reaction = nil
	local forced_attention_data = managers.groupai:state():force_attention_data(data.unit)

	if forced_attention_data then
		if data.attention_obj and data.attention_obj.unit == forced_attention_data.unit then
			return data.attention_obj, 1, AIAttentionObject.REACT_SHOOT
		end

		local forced_attention_object = managers.groupai:state():get_AI_attention_object_by_unit(forced_attention_data.unit)

		if forced_attention_object then
			for u_key, attention_info in pairs(forced_attention_object) do
				if forced_attention_data.ignore_vis_blockers then
					local vis_ray = World:raycast("ray", data.unit:movement():m_head_pos(), attention_info.handler:get_detection_m_pos(), "slot_mask", data.visibility_slotmask, "ray_type", "ai_vision")

					if not vis_ray or vis_ray.unit:key() == u_key or not vis_ray.unit:visible() then
						best_target = CopLogicBase._create_detected_attention_object_data(data.t, data.unit, u_key, attention_info, attention_info.handler:get_attention(data.SO_access), true)
						best_target.verified = true
					end
				else
					best_target = CopLogicBase._create_detected_attention_object_data(data.t, data.unit, u_key, attention_info, attention_info.handler:get_attention(data.SO_access), true)
				end
			end
		else
			Application:error("[CopLogicIdle._get_priority_attention] No attention object available for unit", inspect(forced_attention_data))
		end

		if best_target then
			return best_target, 1, AIAttentionObject.REACT_SHOOT
		end
	end

	local near_threshold = data.internal_data.weapon_range.optimal
	local too_close_threshold = data.internal_data.weapon_range.close

	for u_key, attention_data in pairs(attention_objects) do
		local att_unit = attention_data.unit
		local crim_record = attention_data.criminal_record

		if not attention_data.identified then
			-- Nothing
		elseif attention_data.pause_expire_t then
			if attention_data.pause_expire_t < data.t then
				if not attention_data.settings.attract_chance or math.random() < attention_data.settings.attract_chance then
					attention_data.pause_expire_t = nil
				else
					debug_pause_unit(data.unit, "[ CopLogicIdle._get_priority_attention] skipping attraction")

					attention_data.pause_expire_t = data.t + math.lerp(attention_data.settings.pause[1], attention_data.settings.pause[2], math.random())
				end
			end
		elseif attention_data.stare_expire_t and attention_data.stare_expire_t < data.t then
			if attention_data.settings.pause then
				attention_data.stare_expire_t = nil
				attention_data.pause_expire_t = data.t + math.lerp(attention_data.settings.pause[1], attention_data.settings.pause[2], math.random())
			end
		else
			local distance = attention_data.dis
			local reaction = reaction_func(data, attention_data, not CopLogicAttack._can_move(data))

			if data.cool and AIAttentionObject.REACT_SCARED <= reaction then
				data.unit:movement():set_cool(false, managers.groupai:state().analyse_giveaway(data.unit:base()._tweak_table, att_unit))
			end

			local reaction_too_mild = nil

			if not reaction or best_target_reaction and reaction < best_target_reaction then
				reaction_too_mild = true
			elseif distance < 150 and reaction == AIAttentionObject.REACT_IDLE then
				reaction_too_mild = true
			end

			if not reaction_too_mild then
				local aimed_at = CopLogicIdle.chk_am_i_aimed_at(data, attention_data, attention_data.aimed_at and 0.95 or 0.985)
				attention_data.aimed_at = aimed_at
				local alert_dt = attention_data.alert_t and data.t - attention_data.alert_t or 10000
				local dmg_dt = attention_data.dmg_t and data.t - attention_data.dmg_t or 10000
				local status = crim_record and crim_record.status
				local nr_enemies = crim_record and crim_record.engaged_force
				local old_enemy = false

				if data.attention_obj and data.attention_obj.u_key == u_key and data.t - attention_data.acquire_t < 4 then
					old_enemy = true
				end

				local weight_mul = attention_data.settings.weight_mul

				if attention_data.is_local_player then
					if not att_unit:movement():current_state()._moving and att_unit:movement():current_state():ducking() then
						weight_mul = (weight_mul or 1) * managers.player:upgrade_value("player", "stand_still_crouch_camouflage_bonus", 1)
					end

					if managers.player:has_activate_temporary_upgrade("temporary", "chico_injector") and managers.player:upgrade_value("player", "chico_preferred_target", false) then
						weight_mul = (weight_mul or 1) * 1000
					end

					if _G.IS_VR and tweak_data.vr.long_range_damage_reduction_distance[1] < distance then
						local mul = math.clamp(distance / tweak_data.vr.long_range_damage_reduction_distance[2] / 2, 0, 1) + 1
						weight_mul = (weight_mul or 1) * mul
					end
				elseif att_unit:base() and att_unit:base().upgrade_value then
					if att_unit:movement() and not att_unit:movement()._move_data and att_unit:movement()._pose_code and att_unit:movement()._pose_code == 2 then
						weight_mul = (weight_mul or 1) * (att_unit:base():upgrade_value("player", "stand_still_crouch_camouflage_bonus") or 1)
					end

					if att_unit:base().has_activate_temporary_upgrade and att_unit:base():has_activate_temporary_upgrade("temporary", "chico_injector") and att_unit:base():upgrade_value("player", "chico_preferred_target") then
						weight_mul = (weight_mul or 1) * 1000
					end

					if att_unit:movement().is_vr and att_unit:movement():is_vr() and tweak_data.vr.long_range_damage_reduction_distance[1] < distance then
						local mul = math.clamp(distance / tweak_data.vr.long_range_damage_reduction_distance[2] / 2, 0, 1) + 1
						weight_mul = (weight_mul or 1) * mul
					end
				end

				if weight_mul and weight_mul ~= 1 then
					weight_mul = 1 / weight_mul
					alert_dt = alert_dt and alert_dt * weight_mul
					dmg_dt = dmg_dt and dmg_dt * weight_mul
					distance = distance * weight_mul
				end

				local assault_reaction = reaction == AIAttentionObject.REACT_SPECIAL_ATTACK
				local visible = attention_data.verified
				local near = distance < near_threshold
				local too_near = distance < too_close_threshold and math.abs(attention_data.m_pos.z - data.m_pos.z) < 250
				local free_status = status == nil
				local has_alerted = alert_dt < 3.5
				local has_damaged = dmg_dt < 5
				local reviving = nil

				if attention_data.is_local_player then
					local iparams = att_unit:movement():current_state()._interact_params

					if iparams and managers.criminals:character_name_by_unit(iparams.object) ~= nil then
						reviving = true
					end
				else
					reviving = att_unit:anim_data() and att_unit:anim_data().revive
				end

				local target_priority = distance
				local target_priority_slot = 0

				if visible and not reviving then
					if distance < 500 then
						target_priority_slot = 2
					elseif distance < 1500 then
						target_priority_slot = 4
					else
						target_priority_slot = 6
					end

					if has_damaged then
						target_priority_slot = target_priority_slot - 2
					elseif has_alerted then
						target_priority_slot = target_priority_slot - 1
					elseif free_status and assault_reaction then
						target_priority_slot = 5
					end

					if old_enemy then
						target_priority_slot = target_priority_slot - 3
					end

					target_priority_slot = math.clamp(target_priority_slot, 1, 10)
				elseif free_status then
					target_priority_slot = 7
				end

				if reaction < AIAttentionObject.REACT_COMBAT then
					target_priority_slot = 10 + target_priority_slot + math.max(0, AIAttentionObject.REACT_COMBAT - reaction)
				end

				if target_priority_slot ~= 0 then
					local best = false

					if not best_target then
						best = true
					elseif target_priority_slot < best_target_priority_slot then
						best = true
					elseif target_priority_slot == best_target_priority_slot and target_priority < best_target_priority then
						best = true
					end

					if best then
						best_target = attention_data
						best_target_reaction = reaction
						best_target_priority_slot = target_priority_slot
						best_target_priority = target_priority
					end
				end
			end
		end
	end

	return best_target, best_target_priority_slot, best_target_reaction
end

function CopLogicIdle._upd_curious_reaction(data)
	local my_data = data.internal_data
	local unit = data.unit
	local my_pos = data.unit:movement():m_head_pos()
	local turn_spin = 70
	local attention_obj = data.attention_obj
	local dis = attention_obj.dis
	local is_suspicious = data.cool and attention_obj.reaction == AIAttentionObject.REACT_SUSPICIOUS
	local set_attention = data.unit:movement():attention()

	if not set_attention or set_attention.u_key ~= attention_obj.u_key then
		CopLogicBase._set_attention(data, attention_obj)
	end

	local function _get_spin_to_att_obj()
		return (attention_obj.m_pos - data.m_pos):to_polar_with_reference(data.unit:movement():m_rot():y(), math.UP).spin
	end

	local turned_around = nil

	if (not attention_obj.settings.turn_around_range or dis < attention_obj.settings.turn_around_range) and (not data.objective or not data.objective.rot) then
		local suspect_spin = _get_spin_to_att_obj()

		if turn_spin < suspect_spin then
			CopLogicIdle._turn_by_spin(data, my_data, suspect_spin)

			if my_data.rubberband_rotation then
				my_data.fwd_offset = true
			end

			turned_around = true
		end
	end

	if is_suspicious then
		return CopLogicBase._upd_suspicion(data, my_data, attention_obj)
	end
end

function CopLogicIdle._turn_by_spin(data, my_data, spin)
	local new_action_data = {
		body_part = 2,
		type = "turn",
		angle = spin
	}
	my_data.turning = data.unit:brain():action_request(new_action_data)

	if my_data.turning then
		return true
	end
end

function CopLogicIdle._chk_objective_needs_travel(data, new_objective)
	if not new_objective.nav_seg and new_objective.type ~= "follow" then
		return
	end

	if new_objective.in_place then
		return
	end

	if new_objective.pos then
		return true
	end

	if new_objective.area and new_objective.area.nav_segs[data.unit:movement():nav_tracker():nav_segment()] then
		new_objective.in_place = true

		return
	end

	return true
end

function CopLogicIdle._upd_stance_and_pose(data, my_data, objective)
	if data.unit:movement():chk_action_forbidden("walk") then
		return
	end

	local obj_has_stance, obj_has_pose = nil

	if objective then
		if objective.stance and (not data.char_tweak.allowed_stances or data.char_tweak.allowed_stances[objective.stance]) then
			obj_has_stance = true
			local upper_body_action = data.unit:movement()._active_actions[3]

			if not upper_body_action or upper_body_action:type() ~= "shoot" then
				data.unit:movement():set_stance(objective.stance)
			end
		end

		if objective.pose and not data.is_suppressed and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses[objective.pose]) then
			obj_has_pose = true

			if objective.pose == "crouch" then
				CopLogicAttack._chk_request_action_crouch(data)
			elseif objective.pose == "stand" then
				CopLogicAttack._chk_request_action_stand(data)
			end
		end
	end

	if not obj_has_stance and data.char_tweak.allowed_stances and not data.char_tweak.allowed_stances[data.unit:anim_data().stance] then
		for stance_name, state in pairs(data.char_tweak.allowed_stances) do
			if state then
				data.unit:movement():set_stance(stance_name)

				break
			end
		end
	end

	if not obj_has_pose then
		if data.is_suppressed and not data.unit:anim_data().crouch and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) then
			CopLogicAttack._chk_request_action_crouch(data)
		elseif data.char_tweak.allowed_poses and not data.char_tweak.allowed_poses[data.unit:anim_data().pose] then
			for pose_name, state in pairs(data.char_tweak.allowed_poses) do
				if state then
					if pose_name == "crouch" then
						CopLogicAttack._chk_request_action_crouch(data)

						break
					end

					if pose_name == "stand" then
						CopLogicAttack._chk_request_action_stand(data)
					end

					break
				end
			end
		end
	end
end

function CopLogicIdle._perform_objective_action(data, my_data, objective)
	if objective and not my_data.action_started and (data.unit:anim_data().act_idle or not data.unit:movement():chk_action_forbidden("action")) then
		if objective.action then
			my_data.action_started = data.unit:brain():action_request(objective.action)
		else
			my_data.action_started = true
		end

		if my_data.action_started then
			if objective.action_duration or objective.action_timeout_t then
				my_data.action_timeout_clbk_id = "CopLogicIdle_action_timeout" .. tostring(data.key)
				local action_timeout_t = objective.action_timeout_t or data.t + objective.action_duration
				objective.action_timeout_t = action_timeout_t

				CopLogicBase.add_delayed_clbk(my_data, my_data.action_timeout_clbk_id, callback(CopLogicIdle, CopLogicIdle, "clbk_action_timeout", data), action_timeout_t)
			end

			if objective.action_start_clbk then
				objective.action_start_clbk(data.unit)
			end
		end
	end
end

function CopLogicIdle._upd_stop_old_action(data, my_data, objective)
	local can_stop_action = not my_data.action_started and objective and objective.action and not data.unit:anim_data().to_idle

	if objective and objective.type == "free" then
		can_stop_action = true
	end

	if not can_stop_action then
		return
	end

	if my_data.advancing then
		if not data.unit:movement():chk_action_forbidden("idle") then
			data.unit:brain():action_request({
				sync = true,
				body_part = 2,
				type = "idle"
			})
		end
	elseif not data.unit:movement():chk_action_forbidden("idle") and data.unit:anim_data().needs_idle then
		CopLogicIdle._start_idle_action_from_act(data)
	elseif data.unit:anim_data().act_idle then
		data.unit:brain():action_request({
			sync = true,
			body_part = 2,
			type = "idle"
		})
	end

	CopLogicIdle._chk_has_old_action(data, my_data)
end

function CopLogicIdle._chk_has_old_action(data, my_data)
	local anim_data = data.unit:anim_data()
	my_data.has_old_action = anim_data.to_idle or anim_data.act
	local lower_body_action = data.unit:movement()._active_actions[2]
	my_data.advancing = lower_body_action and lower_body_action:type() == "walk" and lower_body_action
end

function CopLogicIdle._start_idle_action_from_act(data)
	data.unit:brain():action_request({
		variant = "idle",
		body_part = 1,
		type = "act",
		blocks = {
			light_hurt = -1,
			hurt = -1,
			action = -1,
			expl_hurt = -1,
			heavy_hurt = -1,
			idle = -1,
			fire_hurt = -1,
			walk = -1
		}
	})
end
