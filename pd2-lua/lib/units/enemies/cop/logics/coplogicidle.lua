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
	my_data.weapon_range = data.char_tweak.weapon[usage] or {}.range

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
			slot6, slot7 = CopLogicBase.identify_attention_obj_instant(data, attention_obj.u_key)
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

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-40, warpins: 1 ---
	local groupai_state = managers.groupai:state()
	local my_tracker = data.unit:movement():nav_tracker()
	local my_nav_seg = my_tracker:nav_segment()
	local my_area = groupai_state:get_area_from_nav_seg_id(my_nav_seg)
	local is_enemy = data.unit:in_slot(managers.slot:get_mask("enemies"))
	local found_areas = {}
	found_areas[my_area] = true
	local areas_to_search = {}
	areas_to_search[1] = my_area
	local dangerous_far_areas = {}
	--- END OF BLOCK #0 ---

	FLOW; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #2 41-41, warpins: 1 ---
	--- END OF BLOCK #2 ---

	FLOW; TARGET BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #3 42-49, warpins: 1 ---
	local test_area = table.remove(areas_to_search, 1)
	local expand = nil

	if is_enemy then

		-- Decompilation error in this vicinity:
		--- BLOCK #4 50-55, warpins: 1 ---
		if next(test_area.criminal.units) then

			-- Decompilation error in this vicinity:
			--- BLOCK #5 56-57, warpins: 1 ---
			if test_area == my_area then

				-- Decompilation error in this vicinity:
				--- BLOCK #6 58-58, warpins: 1 ---
				break
				--- END OF BLOCK #6 ---



			end

			--- END OF BLOCK #5 ---

			FLOW; TARGET BLOCK #7



			-- Decompilation error in this vicinity:
			--- BLOCK #7 59-61, warpins: 1 ---
			dangerous_far_areas[test_area] = true
			--- END OF BLOCK #7 ---



		else

			-- Decompilation error in this vicinity:
			--- BLOCK #8 62-63, warpins: 1 ---
			expand = true
			--- END OF BLOCK #8 ---



		end
		--- END OF BLOCK #4 ---



	else

		-- Decompilation error in this vicinity:
		--- BLOCK #9 64-69, warpins: 1 ---
		if next(test_area.police.units) then

			-- Decompilation error in this vicinity:
			--- BLOCK #10 70-71, warpins: 1 ---
			if test_area == my_area then

				-- Decompilation error in this vicinity:
				--- BLOCK #11 72-72, warpins: 1 ---
				break
				--- END OF BLOCK #11 ---



			end

			--- END OF BLOCK #10 ---

			FLOW; TARGET BLOCK #12



			-- Decompilation error in this vicinity:
			--- BLOCK #12 73-75, warpins: 1 ---
			dangerous_far_areas[test_area] = true
			--- END OF BLOCK #12 ---



		else

			-- Decompilation error in this vicinity:
			--- BLOCK #13 76-76, warpins: 1 ---
			expand = true
			--- END OF BLOCK #13 ---



		end
		--- END OF BLOCK #9 ---



	end

	--- END OF BLOCK #3 ---

	FLOW; TARGET BLOCK #14



	-- Decompilation error in this vicinity:
	--- BLOCK #4 50-55, warpins: 1 ---
	if next(test_area.criminal.units) then

		-- Decompilation error in this vicinity:
		--- BLOCK #5 56-57, warpins: 1 ---
		if test_area == my_area then

			-- Decompilation error in this vicinity:
			--- BLOCK #6 58-58, warpins: 1 ---
			break
			--- END OF BLOCK #6 ---



		end

		--- END OF BLOCK #5 ---

		FLOW; TARGET BLOCK #7



		-- Decompilation error in this vicinity:
		--- BLOCK #7 59-61, warpins: 1 ---
		dangerous_far_areas[test_area] = true
		--- END OF BLOCK #7 ---



	else

		-- Decompilation error in this vicinity:
		--- BLOCK #8 62-63, warpins: 1 ---
		expand = true
		--- END OF BLOCK #8 ---



	end

	--- END OF BLOCK #4 ---




	-- Decompilation error in this vicinity:
	--- BLOCK #5 56-57, warpins: 1 ---
	if test_area == my_area then

		-- Decompilation error in this vicinity:
		--- BLOCK #6 58-58, warpins: 1 ---
		break
		--- END OF BLOCK #6 ---



	end

	--- END OF BLOCK #5 ---

	FLOW; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #6 58-58, warpins: 1 ---
	break

	--- END OF BLOCK #6 ---




	-- Decompilation error in this vicinity:
	--- BLOCK #7 59-61, warpins: 1 ---
	dangerous_far_areas[test_area] = true
	--- END OF BLOCK #7 ---




	-- Decompilation error in this vicinity:
	--- BLOCK #8 62-63, warpins: 1 ---
	expand = true

	--- END OF BLOCK #8 ---




	-- Decompilation error in this vicinity:
	--- BLOCK #9 64-69, warpins: 1 ---
	if next(test_area.police.units) then

		-- Decompilation error in this vicinity:
		--- BLOCK #10 70-71, warpins: 1 ---
		if test_area == my_area then

			-- Decompilation error in this vicinity:
			--- BLOCK #11 72-72, warpins: 1 ---
			break
			--- END OF BLOCK #11 ---



		end

		--- END OF BLOCK #10 ---

		FLOW; TARGET BLOCK #12



		-- Decompilation error in this vicinity:
		--- BLOCK #12 73-75, warpins: 1 ---
		dangerous_far_areas[test_area] = true
		--- END OF BLOCK #12 ---



	else

		-- Decompilation error in this vicinity:
		--- BLOCK #13 76-76, warpins: 1 ---
		expand = true
		--- END OF BLOCK #13 ---



	end

	--- END OF BLOCK #9 ---




	-- Decompilation error in this vicinity:
	--- BLOCK #10 70-71, warpins: 1 ---
	if test_area == my_area then

		-- Decompilation error in this vicinity:
		--- BLOCK #11 72-72, warpins: 1 ---
		break
		--- END OF BLOCK #11 ---



	end

	--- END OF BLOCK #10 ---

	FLOW; TARGET BLOCK #12



	-- Decompilation error in this vicinity:
	--- BLOCK #11 72-72, warpins: 1 ---
	break

	--- END OF BLOCK #11 ---




	-- Decompilation error in this vicinity:
	--- BLOCK #12 73-75, warpins: 1 ---
	dangerous_far_areas[test_area] = true
	--- END OF BLOCK #12 ---




	-- Decompilation error in this vicinity:
	--- BLOCK #13 76-76, warpins: 1 ---
	expand = true

	--- END OF BLOCK #13 ---




	-- Decompilation error in this vicinity:
	--- BLOCK #14 77-78, warpins: 4 ---
	--- END OF BLOCK #14 ---

	FLOW; TARGET BLOCK #15



	-- Decompilation error in this vicinity:
	--- BLOCK #15 79-82, warpins: 1 ---
	--- END OF BLOCK #15 ---

	FLOW; TARGET BLOCK #16



	-- Decompilation error in this vicinity:
	--- BLOCK #16 83-85, warpins: 1 ---
	if not found_areas[n_area] then

		-- Decompilation error in this vicinity:
		--- BLOCK #17 86-91, warpins: 1 ---
		found_areas[n_area] = test_area

		table.insert(areas_to_search, n_area)
		--- END OF BLOCK #17 ---



	end

	--- END OF BLOCK #16 ---

	FLOW; TARGET BLOCK #18



	-- Decompilation error in this vicinity:
	--- BLOCK #17 86-91, warpins: 1 ---
	found_areas[n_area] = test_area

	table.insert(areas_to_search, n_area)

	--- END OF BLOCK #17 ---




	-- Decompilation error in this vicinity:
	--- BLOCK #18 92-93, warpins: 3 ---
	--- END OF BLOCK #18 ---

	FLOW; TARGET BLOCK #19



	-- Decompilation error in this vicinity:
	--- BLOCK #19 94-94, warpins: 1 ---
	--- END OF BLOCK #19 ---

	FLOW; TARGET BLOCK #20



	-- Decompilation error in this vicinity:
	--- BLOCK #20 95-99, warpins: 3 ---
	local dangerous_near_areas = {}
	--- END OF BLOCK #20 ---

	FLOW; TARGET BLOCK #22



	-- Decompilation error in this vicinity:
	--- BLOCK #21 100-100, warpins: 1 ---
	local backwards_area = area
	--- END OF BLOCK #21 ---

	FLOW; TARGET BLOCK #22



	-- Decompilation error in this vicinity:
	--- BLOCK #22 101-101, warpins: 3 ---
	--- END OF BLOCK #22 ---

	FLOW; TARGET BLOCK #23



	-- Decompilation error in this vicinity:
	--- BLOCK #23 102-104, warpins: 1 ---
	--- END OF BLOCK #23 ---

	FLOW; TARGET BLOCK #24



	-- Decompilation error in this vicinity:
	--- BLOCK #24 105-107, warpins: 1 ---
	dangerous_near_areas[backwards_area] = true
	--- END OF BLOCK #24 ---

	FLOW; TARGET BLOCK #25



	-- Decompilation error in this vicinity:
	--- BLOCK #25 108-108, warpins: 0 ---
	--- END OF BLOCK #25 ---

	FLOW; TARGET BLOCK #26



	-- Decompilation error in this vicinity:
	--- BLOCK #26 109-110, warpins: 1 ---
	backwards_area = found_areas[backwards_area]
	--- END OF BLOCK #26 ---

	FLOW; TARGET BLOCK #27



	-- Decompilation error in this vicinity:
	--- BLOCK #27 111-112, warpins: 2 ---
	--- END OF BLOCK #27 ---




	-- Decompilation error in this vicinity:
	--- BLOCK #28 113-146, warpins: 1 ---
	local my_data = data.internal_data
	local walk_from_pos = data.m_pos
	local ray_from_pos = data.unit:movement():m_stand_pos()
	local ray_to_pos = Vector3()
	local nav_manager = managers.navigation
	local all_nav_segs = nav_manager._nav_segments
	local my_tracker = data.unit:movement():nav_tracker()
	local walk_params = {}
	walk_params.tracker_from = my_tracker
	local slotmask = data.visibility_slotmask
	local mvec3_set = mvector3.set
	local mvec3_set_z = mvector3.set_z
	local stare_pos = {}
	local path_tasks = {}
	--- END OF BLOCK #28 ---

	FLOW; TARGET BLOCK #29



	-- Decompilation error in this vicinity:
	--- BLOCK #29 147-152, warpins: 1 ---
	local nav_seg_id = area.pos_nav_seg
	local nav_seg = all_nav_segs[area.pos_nav_seg]
	--- END OF BLOCK #29 ---

	slot30 = if not nav_seg.disabled then
	JUMP TO BLOCK #30
	else
	JUMP TO BLOCK #36
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #30 153-163, warpins: 1 ---
	local seg_pos = nav_manager:find_random_position_in_segment(nav_seg_id)
	walk_params.pos_to = seg_pos
	local ray_hit = nav_manager:raycast(walk_params)

	--- END OF BLOCK #30 ---

	slot31 = if ray_hit then
	JUMP TO BLOCK #31
	else
	JUMP TO BLOCK #34
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #31 164-184, warpins: 1 ---
	mvec3_set(ray_to_pos, seg_pos)
	mvec3_set_z(ray_to_pos, ray_to_pos.z + 160)

	ray_hit = World:raycast("ray", ray_from_pos, ray_to_pos, "slot_mask", slotmask)

	--- END OF BLOCK #31 ---

	slot31 = if ray_hit then
	JUMP TO BLOCK #32
	else
	JUMP TO BLOCK #33
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #32 185-190, warpins: 1 ---
	table.insert(path_tasks, seg_pos)
	--- END OF BLOCK #32 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #34



	-- Decompilation error in this vicinity:
	--- BLOCK #33 191-195, warpins: 1 ---
	table.insert(stare_pos, ray_to_pos)
	--- END OF BLOCK #33 ---

	FLOW; TARGET BLOCK #34



	-- Decompilation error in this vicinity:
	--- BLOCK #34 196-197, warpins: 3 ---
	--- END OF BLOCK #34 ---

	slot31 = if not ray_hit then
	JUMP TO BLOCK #35
	else
	JUMP TO BLOCK #36
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #35 198-205, warpins: 1 ---
	table.insert(stare_pos, seg_pos + math.UP * 160)

	--- END OF BLOCK #35 ---

	FLOW; TARGET BLOCK #36



	-- Decompilation error in this vicinity:
	--- BLOCK #36 206-207, warpins: 4 ---
	--- END OF BLOCK #36 ---




	-- Decompilation error in this vicinity:
	--- BLOCK #37 208-211, warpins: 1 ---
	--- END OF BLOCK #37 ---

	if #stare_pos > 0 then
	JUMP TO BLOCK #38
	else
	JUMP TO BLOCK #39
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #38 212-214, warpins: 1 ---
	my_data.stare_pos = stare_pos
	my_data.next_scan_t = 0
	--- END OF BLOCK #38 ---

	FLOW; TARGET BLOCK #39



	-- Decompilation error in this vicinity:
	--- BLOCK #39 215-218, warpins: 2 ---
	--- END OF BLOCK #39 ---

	if #path_tasks > 0 then
	JUMP TO BLOCK #40
	else
	JUMP TO BLOCK #41
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #40 219-229, warpins: 1 ---
	my_data.stare_path_pos = path_tasks

	data.unit:brain():search_for_path(my_data.stare_path_search_id, path_tasks[#path_tasks])

	--- END OF BLOCK #40 ---

	FLOW; TARGET BLOCK #41



	-- Decompilation error in this vicinity:
	--- BLOCK #41 230-230, warpins: 2 ---
	return
	--- END OF BLOCK #41 ---



end

function CopLogicIdle._chk_stare_into_wall_2(data)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-8, warpins: 1 ---
	local my_data = data.internal_data
	local slotmask = data.visibility_slotmask
	local path_jobs = my_data.stare_path_pos
	local stare_path = my_data.stare_path
	local f_nav_point_pos = CopLogicIdle._nav_point_pos

	--- END OF BLOCK #0 ---

	slot4 = if not stare_path then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #2
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 9-9, warpins: 1 ---
	return

	--- END OF BLOCK #1 ---

	FLOW; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #2 10-13, warpins: 2 ---
	--- END OF BLOCK #2 ---

	for i, nav_point in ipairs(stare_path)


	LOOP BLOCK #3
	GO OUT TO BLOCK #5



	-- Decompilation error in this vicinity:
	--- BLOCK #3 14-17, warpins: 1 ---
	stare_path[i] = f_nav_point_pos(nav_point)
	--- END OF BLOCK #3 ---

	FLOW; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #4 18-19, warpins: 2 ---
	--- END OF BLOCK #4 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #5 20-34, warpins: 1 ---
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
	--- END OF BLOCK #5 ---

	FLOW; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #6 35-35, warpins: 2 ---
	--- END OF BLOCK #6 ---

	FLOW; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #7 36-51, warpins: 1 ---
	local next_pos = stare_path[i_node + 1]
	local dis = mvec3_dis(this_pos, next_pos)
	total_dis = total_dis + dis

	table.insert(dis_table, dis)

	this_pos = next_pos
	i_node = i_node + 1
	--- END OF BLOCK #7 ---

	if i_node == nr_nodes then
	JUMP TO BLOCK #8
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #8 52-67, warpins: 1 ---
	local nr_loops = 5
	local dis_step = total_dis / (nr_loops + 1)
	local ray_from_pos = data.unit:movement():m_stand_pos()
	local ray_to_pos = Vector3()
	local furthest_good_pos = nil
	local dis_in_seg = 0
	local index = nr_nodes
	local i_loop = 0
	--- END OF BLOCK #8 ---

	FLOW; TARGET BLOCK #9



	-- Decompilation error in this vicinity:
	--- BLOCK #9 68-68, warpins: 2 ---
	--- END OF BLOCK #9 ---

	FLOW; TARGET BLOCK #10



	-- Decompilation error in this vicinity:
	--- BLOCK #10 69-71, warpins: 1 ---
	dis_in_seg = dis_in_seg + dis_step
	local seg_dis = dis_table[index - 1]
	--- END OF BLOCK #10 ---

	FLOW; TARGET BLOCK #11



	-- Decompilation error in this vicinity:
	--- BLOCK #11 72-73, warpins: 2 ---
	--- END OF BLOCK #11 ---

	if seg_dis < dis_in_seg then
	JUMP TO BLOCK #12
	else
	JUMP TO BLOCK #14
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #12 74-74, warpins: 1 ---
	--- END OF BLOCK #12 ---

	FLOW; TARGET BLOCK #13



	-- Decompilation error in this vicinity:
	--- BLOCK #13 75-79, warpins: 1 ---
	index = index - 1
	dis_in_seg = dis_in_seg - seg_dis
	seg_dis = dis_table[index - 1]

	--- END OF BLOCK #13 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #11



	-- Decompilation error in this vicinity:
	--- BLOCK #14 80-104, warpins: 1 ---
	mvec3_lerp(ray_to_pos, stare_path[index], stare_path[index - 1], dis_in_seg / seg_dis)
	mvec3_set_z(ray_to_pos, ray_to_pos.z + 160)

	local hit = World:raycast("ray", ray_from_pos, ray_to_pos, "slot_mask", slotmask, "ray_type", "ai_vision")
	--- END OF BLOCK #14 ---

	slot25 = if not hit then
	JUMP TO BLOCK #15
	else
	JUMP TO BLOCK #18
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #15 105-107, warpins: 1 ---
	--- END OF BLOCK #15 ---

	slot26 = if not my_data.stare_pos then
	JUMP TO BLOCK #16
	else
	JUMP TO BLOCK #17
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #16 108-111, warpins: 1 ---
	my_data.next_scan_t = 0
	my_data.stare_pos = {}

	--- END OF BLOCK #16 ---

	FLOW; TARGET BLOCK #17



	-- Decompilation error in this vicinity:
	--- BLOCK #17 112-117, warpins: 2 ---
	table.insert(my_data.stare_pos, ray_to_pos)

	--- END OF BLOCK #17 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #19



	-- Decompilation error in this vicinity:
	--- BLOCK #18 118-120, warpins: 1 ---
	i_loop = i_loop + 1
	--- END OF BLOCK #18 ---

	if i_loop == nr_loops then
	JUMP TO BLOCK #19
	else
	JUMP TO BLOCK #9
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #19 121-130, warpins: 2 ---
	my_data.stare_path = nil

	table.remove(path_jobs)
	--- END OF BLOCK #19 ---

	if #path_jobs > 0 then
	JUMP TO BLOCK #20
	else
	JUMP TO BLOCK #21
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #20 131-141, warpins: 1 ---
	data.unit:brain():search_for_path(my_data.stare_path_search_id, path_jobs[#path_jobs])

	--- END OF BLOCK #20 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #22



	-- Decompilation error in this vicinity:
	--- BLOCK #21 142-153, warpins: 1 ---
	my_data.stare_path_pos = nil

	CopLogicBase.queue_task(my_data, my_data.wall_stare_task_key, CopLogicIdle._chk_stare_into_wall_1, data, data.t + 2)

	--- END OF BLOCK #21 ---

	FLOW; TARGET BLOCK #22



	-- Decompilation error in this vicinity:
	--- BLOCK #22 154-154, warpins: 2 ---
	return
	--- END OF BLOCK #22 ---



end

function CopLogicIdle._chk_request_action_turn_to_look_pos(data, my_data, my_pos, look_pos)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-9, warpins: 1 ---
	local turn_angle = CopLogicIdle._chk_turn_needed(data, my_data, my_pos, look_pos)

	--- END OF BLOCK #0 ---

	slot4 = if not turn_angle then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #2
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 10-10, warpins: 1 ---
	return

	--- END OF BLOCK #1 ---

	FLOW; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #2 11-18, warpins: 2 ---
	local err_to_correct_abs = math.abs(turn_angle)
	local angle_str = nil

	--- END OF BLOCK #2 ---

	if err_to_correct_abs < 5 then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 19-19, warpins: 1 ---
	return
	--- END OF BLOCK #3 ---

	FLOW; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #4 20-25, warpins: 2 ---
	return CopLogicIdle._turn_by_spin(data, my_data, turn_angle)
	--- END OF BLOCK #4 ---



end

function CopLogicIdle.on_area_safety(data, nav_seg, safe, event)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-2, warpins: 1 ---
	--- END OF BLOCK #0 ---

	slot2 = if not safe then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 3-5, warpins: 1 ---
	--- END OF BLOCK #1 ---

	if event.reason == "criminal" then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 6-15, warpins: 1 ---
	local my_data = data.internal_data
	local u_criminal = event.record.unit
	local key_criminal = u_criminal:key()
	--- END OF BLOCK #2 ---

	slot7 = if not data.detected_attention_objects[key_criminal] then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 16-27, warpins: 1 ---
	local attention_info = managers.groupai:state():get_AI_attention_objects_by_filter(data.SO_access_str)[key_criminal]
	--- END OF BLOCK #3 ---

	slot7 = if attention_info then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 28-36, warpins: 1 ---
	local settings = attention_info.handler:get_attention(data.SO_access, nil, nil, data.team)
	--- END OF BLOCK #4 ---

	slot8 = if settings then
	JUMP TO BLOCK #5
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #5 37-46, warpins: 1 ---
	data.detected_attention_objects[key_criminal] = CopLogicBase._create_detected_attention_object_data(data.t, data.unit, key_criminal, attention_info, settings)

	--- END OF BLOCK #5 ---

	FLOW; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #6 47-47, warpins: 6 ---
	return
	--- END OF BLOCK #6 ---



end

function CopLogicIdle.action_complete_clbk(data, action)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-5, warpins: 1 ---
	local action_type = action:type()
	--- END OF BLOCK #0 ---

	if action_type == "turn" then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 6-12, warpins: 1 ---
	data.internal_data.turning = nil
	--- END OF BLOCK #1 ---

	slot3 = if data.internal_data.fwd_offset then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #21
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 13-37, warpins: 1 ---
	local return_spin = data.internal_data.rubberband_rotation:to_polar_with_reference(data.unit:movement():m_rot():y(), math.UP).spin

	--- END OF BLOCK #2 ---

	if math.abs(return_spin)

	 < 15 then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #21
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 38-41, warpins: 1 ---
	data.internal_data.fwd_offset = nil
	--- END OF BLOCK #3 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #21



	-- Decompilation error in this vicinity:
	--- BLOCK #4 42-43, warpins: 1 ---
	--- END OF BLOCK #4 ---

	if action_type == "act" then
	JUMP TO BLOCK #5
	else
	JUMP TO BLOCK #17
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #5 44-47, warpins: 1 ---
	local my_data = data.internal_data

	--- END OF BLOCK #5 ---

	if my_data.action_started == action then
	JUMP TO BLOCK #6
	else
	JUMP TO BLOCK #21
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #6 48-50, warpins: 1 ---
	--- END OF BLOCK #6 ---

	slot4 = if my_data.scan then
	JUMP TO BLOCK #7
	else
	JUMP TO BLOCK #12
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #7 51-53, warpins: 1 ---
	--- END OF BLOCK #7 ---

	slot4 = if not my_data.exiting then
	JUMP TO BLOCK #8
	else
	JUMP TO BLOCK #12
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #8 54-56, warpins: 1 ---
	--- END OF BLOCK #8 ---

	slot4 = if my_data.queued_tasks then
	JUMP TO BLOCK #9
	else
	JUMP TO BLOCK #10
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #9 57-61, warpins: 1 ---
	--- END OF BLOCK #9 ---

	slot4 = if not my_data.queued_tasks[my_data.wall_stare_task_key] then
	JUMP TO BLOCK #10
	else
	JUMP TO BLOCK #12
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #10 62-64, warpins: 2 ---
	--- END OF BLOCK #10 ---

	slot4 = if not my_data.stare_path_pos then
	JUMP TO BLOCK #11
	else
	JUMP TO BLOCK #12
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #11 65-73, warpins: 1 ---
	CopLogicBase.queue_task(my_data, my_data.wall_stare_task_key, CopLogicIdle._chk_stare_into_wall_1, data, data.t)
	--- END OF BLOCK #11 ---

	FLOW; TARGET BLOCK #12



	-- Decompilation error in this vicinity:
	--- BLOCK #12 74-78, warpins: 5 ---
	--- END OF BLOCK #12 ---

	slot4 = if action:expired()
	 then
	JUMP TO BLOCK #13
	else
	JUMP TO BLOCK #15
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #13 79-81, warpins: 1 ---
	--- END OF BLOCK #13 ---

	slot4 = if not my_data.action_timeout_clbk_id then
	JUMP TO BLOCK #14
	else
	JUMP TO BLOCK #21
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #14 82-86, warpins: 1 ---
	data.objective_complete_clbk(data.unit, data.objective)
	--- END OF BLOCK #14 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #21



	-- Decompilation error in this vicinity:
	--- BLOCK #15 87-89, warpins: 1 ---
	--- END OF BLOCK #15 ---

	slot4 = if not my_data.action_expired then
	JUMP TO BLOCK #16
	else
	JUMP TO BLOCK #21
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #16 90-94, warpins: 1 ---
	data.objective_failed_clbk(data.unit, data.objective)
	--- END OF BLOCK #16 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #21



	-- Decompilation error in this vicinity:
	--- BLOCK #17 95-96, warpins: 1 ---
	--- END OF BLOCK #17 ---

	if action_type == "hurt" then
	JUMP TO BLOCK #18
	else
	JUMP TO BLOCK #21
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #18 97-99, warpins: 1 ---
	--- END OF BLOCK #18 ---

	slot3 = if data.important then
	JUMP TO BLOCK #19
	else
	JUMP TO BLOCK #21
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #19 100-104, warpins: 1 ---
	--- END OF BLOCK #19 ---

	slot3 = if action:expired()
	 then
	JUMP TO BLOCK #20
	else
	JUMP TO BLOCK #21
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #20 105-109, warpins: 1 ---
	CopLogicBase.chk_start_action_dodge(data, "hit")

	--- END OF BLOCK #20 ---

	FLOW; TARGET BLOCK #21



	-- Decompilation error in this vicinity:
	--- BLOCK #21 110-110, warpins: 12 ---
	return
	--- END OF BLOCK #21 ---



end

function CopLogicIdle.is_available_for_assignment(data, objective)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-2, warpins: 1 ---
	--- END OF BLOCK #0 ---

	slot1 = if objective then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #3
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 3-5, warpins: 1 ---
	--- END OF BLOCK #1 ---

	slot2 = if objective.forced then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #3
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 6-7, warpins: 1 ---
	return true

	--- END OF BLOCK #2 ---

	FLOW; TARGET BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #3 8-11, warpins: 3 ---
	local my_data = data.internal_data

	--- END OF BLOCK #3 ---

	slot3 = if data.objective then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #9
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 12-15, warpins: 1 ---
	--- END OF BLOCK #4 ---

	slot3 = if data.objective.action then
	JUMP TO BLOCK #5
	else
	JUMP TO BLOCK #9
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #5 16-18, warpins: 1 ---
	--- END OF BLOCK #5 ---

	slot3 = if my_data.action_started then
	JUMP TO BLOCK #6
	else
	JUMP TO BLOCK #8
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #6 19-25, warpins: 1 ---
	--- END OF BLOCK #6 ---

	slot3 = if not data.unit:anim_data()

	.act_idle then
	JUMP TO BLOCK #7
	else
	JUMP TO BLOCK #9
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #7 26-27, warpins: 1 ---
	return
	--- END OF BLOCK #7 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #9



	-- Decompilation error in this vicinity:
	--- BLOCK #8 28-28, warpins: 1 ---
	return
	--- END OF BLOCK #8 ---

	FLOW; TARGET BLOCK #9



	-- Decompilation error in this vicinity:
	--- BLOCK #9 29-31, warpins: 5 ---
	--- END OF BLOCK #9 ---

	slot3 = if not my_data.exiting then
	JUMP TO BLOCK #10
	else
	JUMP TO BLOCK #12
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #10 32-34, warpins: 1 ---
	--- END OF BLOCK #10 ---

	slot3 = if data.path_fail_t then
	JUMP TO BLOCK #11
	else
	JUMP TO BLOCK #13
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #11 35-39, warpins: 1 ---
	--- END OF BLOCK #11 ---

	if data.t < data.path_fail_t + 6 then
	JUMP TO BLOCK #12
	else
	JUMP TO BLOCK #13
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #12 40-40, warpins: 2 ---
	return
	--- END OF BLOCK #12 ---

	FLOW; TARGET BLOCK #13



	-- Decompilation error in this vicinity:
	--- BLOCK #13 41-42, warpins: 3 ---
	return true
	--- END OF BLOCK #13 ---



end

function CopLogicIdle.clbk_action_timeout(ignore_this, data)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-11, warpins: 1 ---
	local my_data = data.internal_data

	CopLogicBase.on_delayed_clbk(my_data, my_data.action_timeout_clbk_id)

	my_data.action_timeout_clbk_id = nil

	--- END OF BLOCK #0 ---

	slot3 = if not data.objective then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #2
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 12-16, warpins: 1 ---
	debug_pause_unit(data.unit, "[CopLogicIdle.clbk_action_timeout] missing objective")

	return

	--- END OF BLOCK #1 ---

	FLOW; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #2 17-25, warpins: 2 ---
	my_data.action_expired = true

	--- END OF BLOCK #2 ---

	slot3 = if data.unit:anim_data()
	.act then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #5
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 26-32, warpins: 1 ---
	--- END OF BLOCK #3 ---

	slot3 = if data.unit:anim_data()
	.needs_idle then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #5
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 33-36, warpins: 1 ---
	CopLogicIdle._start_idle_action_from_act(data)
	--- END OF BLOCK #4 ---

	FLOW; TARGET BLOCK #5



	-- Decompilation error in this vicinity:
	--- BLOCK #5 37-41, warpins: 3 ---
	data.objective_complete_clbk(data.unit, data.objective)

	return
	--- END OF BLOCK #5 ---



end

function CopLogicIdle._nav_point_pos(nav_point)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-3, warpins: 1 ---
	--- END OF BLOCK #0 ---

	slot1 = if nav_point.x then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #2
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 4-5, warpins: 1 ---
	--- END OF BLOCK #1 ---

	slot1 = if not nav_point then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #3
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 6-13, warpins: 2 ---
	slot1 = nav_point:script_data().element:value("position")

	--- END OF BLOCK #2 ---

	FLOW; TARGET BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #3 14-14, warpins: 2 ---
	return slot1
	--- END OF BLOCK #3 ---



end

function CopLogicIdle._chk_relocate(data)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-3, warpins: 1 ---
	--- END OF BLOCK #0 ---

	slot1 = if data.objective then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #25
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 4-7, warpins: 1 ---
	--- END OF BLOCK #1 ---

	if data.objective.type == "follow" then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #25
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 8-10, warpins: 1 ---
	--- END OF BLOCK #2 ---

	slot1 = if data.is_converted then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 11-18, warpins: 1 ---
	--- END OF BLOCK #3 ---

	slot1 = if TeamAILogicIdle._check_should_relocate(data, data.internal_data, data.objective)

	 then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #5
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 19-28, warpins: 1 ---
	data.objective.in_place = nil

	data.logic._exit(data.unit, "travel")

	return true
	--- END OF BLOCK #4 ---

	FLOW; TARGET BLOCK #5



	-- Decompilation error in this vicinity:
	--- BLOCK #5 29-29, warpins: 2 ---
	return

	--- END OF BLOCK #5 ---

	FLOW; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #6 30-32, warpins: 2 ---
	--- END OF BLOCK #6 ---

	slot1 = if data.is_tied then
	JUMP TO BLOCK #7
	else
	JUMP TO BLOCK #10
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #7 33-36, warpins: 1 ---
	--- END OF BLOCK #7 ---

	slot1 = if data.objective.lose_track_dis then
	JUMP TO BLOCK #8
	else
	JUMP TO BLOCK #10
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #8 37-55, warpins: 1 ---
	--- END OF BLOCK #8 ---

	if data.objective.lose_track_dis * data.objective.lose_track_dis < mvector3.distance_sq(data.m_pos, data.objective.follow_unit:movement():m_pos())
	 then
	JUMP TO BLOCK #9
	else
	JUMP TO BLOCK #10
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #9 56-62, warpins: 1 ---
	data.brain:set_objective(nil)

	return true

	--- END OF BLOCK #9 ---

	FLOW; TARGET BLOCK #10



	-- Decompilation error in this vicinity:
	--- BLOCK #10 63-70, warpins: 4 ---
	local relocate = nil
	local follow_unit = data.objective.follow_unit

	--- END OF BLOCK #10 ---

	slot3 = if follow_unit:brain()

	 then
	JUMP TO BLOCK #11
	else
	JUMP TO BLOCK #12
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #11 71-76, warpins: 1 ---
	local advance_pos = follow_unit:brain():is_advancing()
	--- END OF BLOCK #11 ---

	FLOW; TARGET BLOCK #12



	-- Decompilation error in this vicinity:
	--- BLOCK #12 77-78, warpins: 2 ---
	--- END OF BLOCK #12 ---

	slot4 = if not advance_pos then
	JUMP TO BLOCK #13
	else
	JUMP TO BLOCK #14
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #13 79-84, warpins: 1 ---
	local follow_unit_pos = follow_unit:movement():m_pos()

	--- END OF BLOCK #13 ---

	FLOW; TARGET BLOCK #14



	-- Decompilation error in this vicinity:
	--- BLOCK #14 85-88, warpins: 2 ---
	--- END OF BLOCK #14 ---

	slot5 = if data.objective.relocated_to then
	JUMP TO BLOCK #15
	else
	JUMP TO BLOCK #17
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #15 89-96, warpins: 1 ---
	--- END OF BLOCK #15 ---

	slot5 = if mvector3.equal(data.objective.relocated_to, follow_unit_pos)

	 then
	JUMP TO BLOCK #16
	else
	JUMP TO BLOCK #17
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #16 97-97, warpins: 1 ---
	return

	--- END OF BLOCK #16 ---

	FLOW; TARGET BLOCK #17



	-- Decompilation error in this vicinity:
	--- BLOCK #17 98-101, warpins: 3 ---
	--- END OF BLOCK #17 ---

	slot5 = if data.objective.distance then
	JUMP TO BLOCK #18
	else
	JUMP TO BLOCK #20
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #18 102-110, warpins: 1 ---
	--- END OF BLOCK #18 ---

	if data.objective.distance < mvector3.distance(data.m_pos, follow_unit_pos)

	 then
	JUMP TO BLOCK #19
	else
	JUMP TO BLOCK #20
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #19 111-111, warpins: 1 ---
	relocate = true
	--- END OF BLOCK #19 ---

	FLOW; TARGET BLOCK #20



	-- Decompilation error in this vicinity:
	--- BLOCK #20 112-113, warpins: 3 ---
	--- END OF BLOCK #20 ---

	slot1 = if not relocate then
	JUMP TO BLOCK #21
	else
	JUMP TO BLOCK #23
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #21 114-131, warpins: 1 ---
	local ray_params = {}
	ray_params.tracker_from = data.unit:movement():nav_tracker()
	ray_params.pos_to = follow_unit_pos
	local ray_res = managers.navigation:raycast(ray_params)
	--- END OF BLOCK #21 ---

	slot6 = if ray_res then
	JUMP TO BLOCK #22
	else
	JUMP TO BLOCK #23
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #22 132-132, warpins: 1 ---
	relocate = true
	--- END OF BLOCK #22 ---

	FLOW; TARGET BLOCK #23



	-- Decompilation error in this vicinity:
	--- BLOCK #23 133-134, warpins: 3 ---
	--- END OF BLOCK #23 ---

	slot1 = if relocate then
	JUMP TO BLOCK #24
	else
	JUMP TO BLOCK #41
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #24 135-162, warpins: 1 ---
	data.objective.in_place = nil
	data.objective.nav_seg = follow_unit:movement():nav_tracker():nav_segment()
	data.objective.relocated_to = mvector3.copy(follow_unit_pos)

	data.logic._exit(data.unit, "travel")

	return true

	--- END OF BLOCK #24 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #41



	-- Decompilation error in this vicinity:
	--- BLOCK #25 163-165, warpins: 2 ---
	--- END OF BLOCK #25 ---

	slot1 = if data.objective then
	JUMP TO BLOCK #26
	else
	JUMP TO BLOCK #41
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #26 166-169, warpins: 1 ---
	--- END OF BLOCK #26 ---

	if data.objective.type == "defend_area" then
	JUMP TO BLOCK #27
	else
	JUMP TO BLOCK #41
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #27 170-173, warpins: 1 ---
	local area = data.objective.area

	--- END OF BLOCK #27 ---

	slot1 = if area then
	JUMP TO BLOCK #28
	else
	JUMP TO BLOCK #41
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #28 174-179, warpins: 1 ---
	--- END OF BLOCK #28 ---

	slot2 = if not next(area.criminal.units)

	 then
	JUMP TO BLOCK #29
	else
	JUMP TO BLOCK #41
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #29 180-185, warpins: 1 ---
	local found_areas = {}
	found_areas[area] = true
	local areas_to_search = {}
	areas_to_search[1] = area
	local target_area = nil

	--- END OF BLOCK #29 ---

	FLOW; TARGET BLOCK #30



	-- Decompilation error in this vicinity:
	--- BLOCK #30 186-190, warpins: 2 ---
	--- END OF BLOCK #30 ---

	slot5 = if next(areas_to_search)

	 then
	JUMP TO BLOCK #31
	else
	JUMP TO BLOCK #39
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #31 191-191, warpins: 1 ---
	--- END OF BLOCK #31 ---

	FLOW; TARGET BLOCK #32



	-- Decompilation error in this vicinity:
	--- BLOCK #32 192-201, warpins: 1 ---
	local current_area = table.remove(areas_to_search)

	--- END OF BLOCK #32 ---

	slot6 = if next(current_area.criminal.units)

	 then
	JUMP TO BLOCK #33
	else
	JUMP TO BLOCK #34
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #33 202-203, warpins: 1 ---
	target_area = current_area

	--- END OF BLOCK #33 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #39



	-- Decompilation error in this vicinity:
	--- BLOCK #34 204-207, warpins: 1 ---
	--- END OF BLOCK #34 ---

	for _, n_area in pairs(current_area.neighbours)


	LOOP BLOCK #35
	GO OUT TO BLOCK #38



	-- Decompilation error in this vicinity:
	--- BLOCK #35 208-210, warpins: 1 ---
	--- END OF BLOCK #35 ---

	slot11 = if not found_areas[n_area] then
	JUMP TO BLOCK #36
	else
	JUMP TO BLOCK #37
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #36 211-217, warpins: 1 ---
	found_areas[n_area] = true

	table.insert(areas_to_search, n_area)

	--- END OF BLOCK #36 ---

	FLOW; TARGET BLOCK #37



	-- Decompilation error in this vicinity:
	--- BLOCK #37 218-219, warpins: 3 ---
	--- END OF BLOCK #37 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #34



	-- Decompilation error in this vicinity:
	--- BLOCK #38 220-220, warpins: 1 ---
	--- END OF BLOCK #38 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #30



	-- Decompilation error in this vicinity:
	--- BLOCK #39 221-222, warpins: 2 ---
	--- END OF BLOCK #39 ---

	slot4 = if target_area then
	JUMP TO BLOCK #40
	else
	JUMP TO BLOCK #41
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #40 223-245, warpins: 1 ---
	data.objective.in_place = nil
	data.objective.nav_seg = next(target_area.nav_segs)
	data.objective.path_data = {
		{
			data.objective.nav_seg
		}
	}

	data.logic._exit(data.unit, "travel")

	return true
	--- END OF BLOCK #40 ---

	FLOW; TARGET BLOCK #41



	-- Decompilation error in this vicinity:
	--- BLOCK #41 246-246, warpins: 8 ---
	return
	--- END OF BLOCK #41 ---



end

function CopLogicIdle._chk_exit_non_walkable_area(data)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-4, warpins: 1 ---
	local my_data = data.internal_data

	--- END OF BLOCK #0 ---

	slot2 = if not my_data.advancing then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 5-7, warpins: 1 ---
	--- END OF BLOCK #1 ---

	slot2 = if not my_data.old_action_advancing then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 8-13, warpins: 1 ---
	--- END OF BLOCK #2 ---

	slot2 = if CopLogicAttack._can_move(data)
	 then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 14-23, warpins: 1 ---
	--- END OF BLOCK #3 ---

	slot2 = if data.unit:movement():chk_action_forbidden("walk")

	 then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #5
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 24-24, warpins: 4 ---
	return

	--- END OF BLOCK #4 ---

	FLOW; TARGET BLOCK #5



	-- Decompilation error in this vicinity:
	--- BLOCK #5 25-36, warpins: 2 ---
	local my_tracker = data.unit:movement():nav_tracker()

	--- END OF BLOCK #5 ---

	slot3 = if not my_tracker:obstructed()

	 then
	JUMP TO BLOCK #6
	else
	JUMP TO BLOCK #7
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #6 37-37, warpins: 1 ---
	return

	--- END OF BLOCK #6 ---

	FLOW; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #7 38-40, warpins: 2 ---
	--- END OF BLOCK #7 ---

	slot3 = if data.objective then
	JUMP TO BLOCK #8
	else
	JUMP TO BLOCK #11
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #8 41-44, warpins: 1 ---
	--- END OF BLOCK #8 ---

	slot3 = if data.objective.nav_seg then
	JUMP TO BLOCK #9
	else
	JUMP TO BLOCK #11
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #9 45-54, warpins: 1 ---
	local nav_seg_id = my_tracker:nav_segment()
	--- END OF BLOCK #9 ---

	slot4 = if not managers.navigation._nav_segments[nav_seg_id].disabled then
	JUMP TO BLOCK #10
	else
	JUMP TO BLOCK #11
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #10 55-64, warpins: 1 ---
	data.objective.in_place = nil

	data.logic.on_new_objective(data, data.objective)

	return true
	--- END OF BLOCK #10 ---

	FLOW; TARGET BLOCK #11



	-- Decompilation error in this vicinity:
	--- BLOCK #11 65-65, warpins: 4 ---
	return
	--- END OF BLOCK #11 ---



end

function CopLogicIdle._get_all_paths(data)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-5, warpins: 1 ---
	return {
		stare_path = data.internal_data.stare_path
	}
	--- END OF BLOCK #0 ---



end

function CopLogicIdle._set_verified_paths(data, verified_paths)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-4, warpins: 1 ---
	data.internal_data.stare_path = verified_paths.stare_path

	return
	--- END OF BLOCK #0 ---



end

function CopLogicIdle._chk_focus_on_attention_object(data, my_data)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-3, warpins: 1 ---
	local current_attention = data.attention_obj
	--- END OF BLOCK #0 ---

	slot2 = if not current_attention then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #5
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 4-12, warpins: 1 ---
	local set_attention = data.unit:movement():attention()

	--- END OF BLOCK #1 ---

	slot3 = if set_attention then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 13-15, warpins: 1 ---
	--- END OF BLOCK #2 ---

	slot4 = if set_attention.handler then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 16-19, warpins: 1 ---
	CopLogicBase._reset_attention(data)

	--- END OF BLOCK #3 ---

	FLOW; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #4 20-20, warpins: 3 ---
	return
	--- END OF BLOCK #4 ---

	FLOW; TARGET BLOCK #5



	-- Decompilation error in this vicinity:
	--- BLOCK #5 21-23, warpins: 2 ---
	--- END OF BLOCK #5 ---

	slot3 = if my_data.turning then
	JUMP TO BLOCK #6
	else
	JUMP TO BLOCK #7
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #6 24-24, warpins: 1 ---
	return

	--- END OF BLOCK #6 ---

	FLOW; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #7 25-29, warpins: 2 ---
	--- END OF BLOCK #7 ---

	if current_attention.reaction ~= AIAttentionObject.REACT_CURIOUS then
	JUMP TO BLOCK #8
	else
	JUMP TO BLOCK #9
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #8 30-34, warpins: 1 ---
	--- END OF BLOCK #8 ---

	if current_attention.reaction == AIAttentionObject.REACT_SUSPICIOUS then
	JUMP TO BLOCK #9
	else
	JUMP TO BLOCK #11
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #9 35-40, warpins: 2 ---
	--- END OF BLOCK #9 ---

	slot3 = if CopLogicIdle._upd_curious_reaction(data)

	 then
	JUMP TO BLOCK #10
	else
	JUMP TO BLOCK #11
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #10 41-42, warpins: 1 ---
	return true

	--- END OF BLOCK #10 ---

	FLOW; TARGET BLOCK #11



	-- Decompilation error in this vicinity:
	--- BLOCK #11 43-48, warpins: 3 ---
	--- END OF BLOCK #11 ---

	slot3 = if data.logic.is_available_for_assignment(data)
	 then
	JUMP TO BLOCK #12
	else
	JUMP TO BLOCK #24
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #12 49-58, warpins: 1 ---
	--- END OF BLOCK #12 ---

	slot3 = if not data.unit:movement():chk_action_forbidden("walk")

	 then
	JUMP TO BLOCK #13
	else
	JUMP TO BLOCK #24
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #13 59-72, warpins: 1 ---
	local attention_pos = current_attention.handler:get_attention_m_pos(current_attention.settings)
	local turn_angle = CopLogicIdle._chk_turn_needed(data, my_data, data.m_pos, attention_pos)

	--- END OF BLOCK #13 ---

	slot4 = if turn_angle then
	JUMP TO BLOCK #14
	else
	JUMP TO BLOCK #18
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #14 73-77, warpins: 1 ---
	--- END OF BLOCK #14 ---

	if current_attention.reaction < AIAttentionObject.REACT_CURIOUS then
	JUMP TO BLOCK #15
	else
	JUMP TO BLOCK #18
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #15 78-80, warpins: 1 ---
	--- END OF BLOCK #15 ---

	if turn_angle > 70 then
	JUMP TO BLOCK #16
	else
	JUMP TO BLOCK #17
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #16 81-82, warpins: 1 ---
	return

	--- END OF BLOCK #16 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #18



	-- Decompilation error in this vicinity:
	--- BLOCK #17 83-83, warpins: 1 ---
	turn_angle = nil
	--- END OF BLOCK #17 ---

	FLOW; TARGET BLOCK #18



	-- Decompilation error in this vicinity:
	--- BLOCK #18 84-85, warpins: 4 ---
	--- END OF BLOCK #18 ---

	slot4 = if turn_angle then
	JUMP TO BLOCK #19
	else
	JUMP TO BLOCK #24
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #19 86-93, warpins: 1 ---
	local err_to_correct_abs = math.abs(turn_angle)
	local angle_str = nil

	--- END OF BLOCK #19 ---

	if err_to_correct_abs > 40 then
	JUMP TO BLOCK #20
	else
	JUMP TO BLOCK #24
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #20 94-101, warpins: 1 ---
	--- END OF BLOCK #20 ---

	slot7 = if not CopLogicIdle._turn_by_spin(data, my_data, turn_angle)

	 then
	JUMP TO BLOCK #21
	else
	JUMP TO BLOCK #22
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #21 102-102, warpins: 1 ---
	return

	--- END OF BLOCK #21 ---

	FLOW; TARGET BLOCK #22



	-- Decompilation error in this vicinity:
	--- BLOCK #22 103-105, warpins: 2 ---
	--- END OF BLOCK #22 ---

	slot7 = if my_data.rubberband_rotation then
	JUMP TO BLOCK #23
	else
	JUMP TO BLOCK #24
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #23 106-107, warpins: 1 ---
	my_data.fwd_offset = true
	--- END OF BLOCK #23 ---

	FLOW; TARGET BLOCK #24



	-- Decompilation error in this vicinity:
	--- BLOCK #24 108-116, warpins: 6 ---
	local set_attention = data.unit:movement():attention()

	--- END OF BLOCK #24 ---

	slot3 = if set_attention then
	JUMP TO BLOCK #25
	else
	JUMP TO BLOCK #26
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #25 117-120, warpins: 1 ---
	--- END OF BLOCK #25 ---

	if set_attention.u_key ~= current_attention.u_key then
	JUMP TO BLOCK #26
	else
	JUMP TO BLOCK #27
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #26 121-126, warpins: 2 ---
	CopLogicBase._set_attention(data, current_attention, nil)

	--- END OF BLOCK #26 ---

	FLOW; TARGET BLOCK #27



	-- Decompilation error in this vicinity:
	--- BLOCK #27 127-128, warpins: 2 ---
	return true
	--- END OF BLOCK #27 ---



end

function CopLogicIdle._chk_turn_needed(data, my_data, my_pos, look_pos)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-25, warpins: 1 ---
	local fwd = data.unit:movement():m_rot():y()
	local target_vec = look_pos - my_pos
	local error_polar = target_vec:to_polar_with_reference(fwd, math.UP)
	local error_spin = error_polar.spin
	local abs_err_spin = math.abs(error_spin)
	--- END OF BLOCK #0 ---

	if error_spin < 0 then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #2
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 26-27, warpins: 1 ---
	slot9 = 50
	--- END OF BLOCK #1 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #2 28-28, warpins: 1 ---
	local tolerance = 30
	--- END OF BLOCK #2 ---

	FLOW; TARGET BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #3 29-44, warpins: 2 ---
	local err_to_correct = error_spin - tolerance * math.sign(error_spin)

	--- END OF BLOCK #3 ---

	if math.sign(err_to_correct)
	 ~= math.sign(error_spin)

	 then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #5
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 45-45, warpins: 1 ---
	return
	--- END OF BLOCK #4 ---

	FLOW; TARGET BLOCK #5



	-- Decompilation error in this vicinity:
	--- BLOCK #5 46-46, warpins: 2 ---
	return err_to_correct
	--- END OF BLOCK #5 ---



end

function CopLogicIdle._get_priority_attention(data, attention_objects, reaction_func)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-2, warpins: 1 ---
	--- END OF BLOCK #0 ---

	slot2 = if not reaction_func then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #2
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 3-4, warpins: 1 ---
	reaction_func = CopLogicIdle._chk_reaction_to_attention_object
	--- END OF BLOCK #1 ---

	FLOW; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #2 5-16, warpins: 2 ---
	local best_target, best_target_priority_slot, best_target_priority, best_target_reaction = nil
	local forced_attention_data = managers.groupai:state():force_attention_data(data.unit)

	--- END OF BLOCK #2 ---

	slot7 = if forced_attention_data then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #19
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 17-19, warpins: 1 ---
	--- END OF BLOCK #3 ---

	slot8 = if data.attention_obj then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 20-24, warpins: 1 ---
	--- END OF BLOCK #4 ---

	if data.attention_obj.unit == forced_attention_data.unit then
	JUMP TO BLOCK #5
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #5 25-29, warpins: 1 ---
	return data.attention_obj, 1, AIAttentionObject.REACT_SHOOT

	--- END OF BLOCK #5 ---

	FLOW; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #6 30-40, warpins: 3 ---
	local forced_attention_object = managers.groupai:state():get_AI_attention_object_by_unit(forced_attention_data.unit)

	--- END OF BLOCK #6 ---

	slot8 = if forced_attention_object then
	JUMP TO BLOCK #7
	else
	JUMP TO BLOCK #16
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #7 41-44, warpins: 1 ---
	--- END OF BLOCK #7 ---

	for u_key, attention_info in pairs(forced_attention_object)


	LOOP BLOCK #8
	GO OUT TO BLOCK #15



	-- Decompilation error in this vicinity:
	--- BLOCK #8 45-47, warpins: 1 ---
	--- END OF BLOCK #8 ---

	slot14 = if forced_attention_data.ignore_vis_blockers then
	JUMP TO BLOCK #9
	else
	JUMP TO BLOCK #13
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #9 48-69, warpins: 1 ---
	local vis_ray = World:raycast("ray", data.unit:movement():m_head_pos(), attention_info.handler:get_detection_m_pos(), "slot_mask", data.visibility_slotmask, "ray_type", "ai_vision")

	--- END OF BLOCK #9 ---

	slot14 = if vis_ray then
	JUMP TO BLOCK #10
	else
	JUMP TO BLOCK #12
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #10 70-75, warpins: 1 ---
	--- END OF BLOCK #10 ---

	if vis_ray.unit:key()
	 ~= u_key then
	JUMP TO BLOCK #11
	else
	JUMP TO BLOCK #12
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #11 76-81, warpins: 1 ---
	--- END OF BLOCK #11 ---

	slot15 = if not vis_ray.unit:visible()

	 then
	JUMP TO BLOCK #12
	else
	JUMP TO BLOCK #14
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #12 82-98, warpins: 3 ---
	best_target = CopLogicBase._create_detected_attention_object_data(data.t, data.unit, u_key, attention_info, attention_info.handler:get_attention(data.SO_access), true)
	best_target.verified = true
	--- END OF BLOCK #12 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #14



	-- Decompilation error in this vicinity:
	--- BLOCK #13 99-112, warpins: 1 ---
	best_target = CopLogicBase._create_detected_attention_object_data(data.t, data.unit, u_key, attention_info, attention_info.handler:get_attention(data.SO_access), true)

	--- END OF BLOCK #13 ---

	FLOW; TARGET BLOCK #14



	-- Decompilation error in this vicinity:
	--- BLOCK #14 113-114, warpins: 4 ---
	--- END OF BLOCK #14 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #15 115-115, warpins: 1 ---
	--- END OF BLOCK #15 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #17



	-- Decompilation error in this vicinity:
	--- BLOCK #16 116-123, warpins: 1 ---
	Application:error("[CopLogicIdle._get_priority_attention] No attention object available for unit", inspect(forced_attention_data))

	--- END OF BLOCK #16 ---

	FLOW; TARGET BLOCK #17



	-- Decompilation error in this vicinity:
	--- BLOCK #17 124-125, warpins: 2 ---
	--- END OF BLOCK #17 ---

	slot3 = if best_target then
	JUMP TO BLOCK #18
	else
	JUMP TO BLOCK #19
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #18 126-130, warpins: 1 ---
	return best_target, 1, AIAttentionObject.REACT_SHOOT

	--- END OF BLOCK #18 ---

	FLOW; TARGET BLOCK #19



	-- Decompilation error in this vicinity:
	--- BLOCK #19 131-140, warpins: 3 ---
	local near_threshold = data.internal_data.weapon_range.optimal
	local too_close_threshold = data.internal_data.weapon_range.close

	--- END OF BLOCK #19 ---

	for u_key, attention_data in pairs(attention_objects)


	LOOP BLOCK #20
	GO OUT TO BLOCK #163



	-- Decompilation error in this vicinity:
	--- BLOCK #20 141-145, warpins: 1 ---
	local att_unit = attention_data.unit
	local crim_record = attention_data.criminal_record

	--- END OF BLOCK #20 ---

	slot17 = if not attention_data.identified then
	JUMP TO BLOCK #21
	else
	JUMP TO BLOCK #22
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #21 146-146, warpins: 1 ---
	--- END OF BLOCK #21 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #162



	-- Decompilation error in this vicinity:
	--- BLOCK #22 147-149, warpins: 1 ---
	--- END OF BLOCK #22 ---

	slot17 = if attention_data.pause_expire_t then
	JUMP TO BLOCK #23
	else
	JUMP TO BLOCK #28
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #23 150-153, warpins: 1 ---
	--- END OF BLOCK #23 ---

	if attention_data.pause_expire_t < data.t then
	JUMP TO BLOCK #24
	else
	JUMP TO BLOCK #162
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #24 154-157, warpins: 1 ---
	--- END OF BLOCK #24 ---

	slot17 = if attention_data.settings.attract_chance then
	JUMP TO BLOCK #25
	else
	JUMP TO BLOCK #26
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #25 158-164, warpins: 1 ---
	--- END OF BLOCK #25 ---

	if math.random()

	 < attention_data.settings.attract_chance then
	JUMP TO BLOCK #26
	else
	JUMP TO BLOCK #27
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #26 165-167, warpins: 2 ---
	attention_data.pause_expire_t = nil

	--- END OF BLOCK #26 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #162



	-- Decompilation error in this vicinity:
	--- BLOCK #27 168-187, warpins: 1 ---
	debug_pause_unit(data.unit, "[ CopLogicIdle._get_priority_attention] skipping attraction")

	attention_data.pause_expire_t = data.t + math.lerp(attention_data.settings.pause[1], attention_data.settings.pause[2], math.random())
	--- END OF BLOCK #27 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #162



	-- Decompilation error in this vicinity:
	--- BLOCK #28 188-190, warpins: 1 ---
	--- END OF BLOCK #28 ---

	slot17 = if attention_data.stare_expire_t then
	JUMP TO BLOCK #29
	else
	JUMP TO BLOCK #32
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #29 191-194, warpins: 1 ---
	--- END OF BLOCK #29 ---

	if attention_data.stare_expire_t < data.t then
	JUMP TO BLOCK #30
	else
	JUMP TO BLOCK #32
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #30 195-198, warpins: 1 ---
	--- END OF BLOCK #30 ---

	slot17 = if attention_data.settings.pause then
	JUMP TO BLOCK #31
	else
	JUMP TO BLOCK #162
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #31 199-216, warpins: 1 ---
	attention_data.stare_expire_t = nil
	attention_data.pause_expire_t = data.t + math.lerp(attention_data.settings.pause[1], attention_data.settings.pause[2], math.random())
	--- END OF BLOCK #31 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #162



	-- Decompilation error in this vicinity:
	--- BLOCK #32 217-229, warpins: 2 ---
	local distance = attention_data.dis
	local reaction = reaction_func(data, attention_data, not CopLogicAttack._can_move(data))

	--- END OF BLOCK #32 ---

	slot19 = if data.cool then
	JUMP TO BLOCK #33
	else
	JUMP TO BLOCK #35
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #33 230-233, warpins: 1 ---
	--- END OF BLOCK #33 ---

	if AIAttentionObject.REACT_SCARED <= reaction then
	JUMP TO BLOCK #34
	else
	JUMP TO BLOCK #35
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #34 234-254, warpins: 1 ---
	data.unit:movement():set_cool(false, managers.groupai:state().analyse_giveaway(data.unit:base()._tweak_table, att_unit))

	--- END OF BLOCK #34 ---

	FLOW; TARGET BLOCK #35



	-- Decompilation error in this vicinity:
	--- BLOCK #35 255-257, warpins: 3 ---
	local reaction_too_mild = nil
	--- END OF BLOCK #35 ---

	slot18 = if reaction then
	JUMP TO BLOCK #36
	else
	JUMP TO BLOCK #38
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #36 258-259, warpins: 1 ---
	--- END OF BLOCK #36 ---

	slot6 = if best_target_reaction then
	JUMP TO BLOCK #37
	else
	JUMP TO BLOCK #39
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #37 260-261, warpins: 1 ---
	--- END OF BLOCK #37 ---

	if reaction < best_target_reaction then
	JUMP TO BLOCK #38
	else
	JUMP TO BLOCK #39
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #38 262-263, warpins: 2 ---
	reaction_too_mild = true
	--- END OF BLOCK #38 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #42



	-- Decompilation error in this vicinity:
	--- BLOCK #39 264-266, warpins: 2 ---
	--- END OF BLOCK #39 ---

	if distance < 150 then
	JUMP TO BLOCK #40
	else
	JUMP TO BLOCK #42
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #40 267-270, warpins: 1 ---
	--- END OF BLOCK #40 ---

	if reaction == AIAttentionObject.REACT_IDLE then
	JUMP TO BLOCK #41
	else
	JUMP TO BLOCK #42
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #41 271-271, warpins: 1 ---
	reaction_too_mild = true
	--- END OF BLOCK #41 ---

	FLOW; TARGET BLOCK #42



	-- Decompilation error in this vicinity:
	--- BLOCK #42 272-273, warpins: 4 ---
	--- END OF BLOCK #42 ---

	slot19 = if not reaction_too_mild then
	JUMP TO BLOCK #43
	else
	JUMP TO BLOCK #162
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #43 274-280, warpins: 1 ---
	slot20 = CopLogicIdle.chk_am_i_aimed_at
	slot21 = data
	slot22 = attention_data
	--- END OF BLOCK #43 ---

	slot23 = if attention_data.aimed_at then
	JUMP TO BLOCK #44
	else
	JUMP TO BLOCK #45
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #44 281-282, warpins: 1 ---
	slot23 = 0.95
	--- END OF BLOCK #44 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #46



	-- Decompilation error in this vicinity:
	--- BLOCK #45 283-283, warpins: 1 ---
	slot23 = 0.985
	--- END OF BLOCK #45 ---

	FLOW; TARGET BLOCK #46



	-- Decompilation error in this vicinity:
	--- BLOCK #46 284-288, warpins: 2 ---
	local aimed_at = slot20(slot21, slot22, slot23)
	attention_data.aimed_at = aimed_at
	--- END OF BLOCK #46 ---

	slot21 = if attention_data.alert_t then
	JUMP TO BLOCK #47
	else
	JUMP TO BLOCK #48
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #47 289-293, warpins: 1 ---
	--- END OF BLOCK #47 ---

	slot21 = if not (data.t - attention_data.alert_t) then
	JUMP TO BLOCK #48
	else
	JUMP TO BLOCK #49
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #48 294-294, warpins: 2 ---
	local alert_dt = 10000
	--- END OF BLOCK #48 ---

	FLOW; TARGET BLOCK #49



	-- Decompilation error in this vicinity:
	--- BLOCK #49 295-297, warpins: 2 ---
	--- END OF BLOCK #49 ---

	slot22 = if attention_data.dmg_t then
	JUMP TO BLOCK #50
	else
	JUMP TO BLOCK #51
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #50 298-302, warpins: 1 ---
	--- END OF BLOCK #50 ---

	slot22 = if not (data.t - attention_data.dmg_t) then
	JUMP TO BLOCK #51
	else
	JUMP TO BLOCK #52
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #51 303-303, warpins: 2 ---
	local dmg_dt = 10000
	--- END OF BLOCK #51 ---

	FLOW; TARGET BLOCK #52



	-- Decompilation error in this vicinity:
	--- BLOCK #52 304-305, warpins: 2 ---
	--- END OF BLOCK #52 ---

	slot23 = if crim_record then
	JUMP TO BLOCK #53
	else
	JUMP TO BLOCK #54
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #53 306-306, warpins: 1 ---
	local status = crim_record.status
	--- END OF BLOCK #53 ---

	FLOW; TARGET BLOCK #54



	-- Decompilation error in this vicinity:
	--- BLOCK #54 307-308, warpins: 2 ---
	--- END OF BLOCK #54 ---

	slot24 = if crim_record then
	JUMP TO BLOCK #55
	else
	JUMP TO BLOCK #56
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #55 309-309, warpins: 1 ---
	local nr_enemies = crim_record.engaged_force
	--- END OF BLOCK #55 ---

	FLOW; TARGET BLOCK #56



	-- Decompilation error in this vicinity:
	--- BLOCK #56 310-313, warpins: 2 ---
	local old_enemy = false
	--- END OF BLOCK #56 ---

	slot26 = if data.attention_obj then
	JUMP TO BLOCK #57
	else
	JUMP TO BLOCK #60
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #57 314-317, warpins: 1 ---
	--- END OF BLOCK #57 ---

	if data.attention_obj.u_key == u_key then
	JUMP TO BLOCK #58
	else
	JUMP TO BLOCK #60
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #58 318-323, warpins: 1 ---
	--- END OF BLOCK #58 ---

	if data.t - attention_data.acquire_t < 4 then
	JUMP TO BLOCK #59
	else
	JUMP TO BLOCK #60
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #59 324-324, warpins: 1 ---
	old_enemy = true
	--- END OF BLOCK #59 ---

	FLOW; TARGET BLOCK #60



	-- Decompilation error in this vicinity:
	--- BLOCK #60 325-329, warpins: 4 ---
	local weight_mul = attention_data.settings.weight_mul

	--- END OF BLOCK #60 ---

	slot27 = if attention_data.is_local_player then
	JUMP TO BLOCK #61
	else
	JUMP TO BLOCK #76
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #61 330-338, warpins: 1 ---
	--- END OF BLOCK #61 ---

	slot27 = if not att_unit:movement():current_state()
	._moving then
	JUMP TO BLOCK #62
	else
	JUMP TO BLOCK #66
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #62 339-349, warpins: 1 ---
	--- END OF BLOCK #62 ---

	slot27 = if att_unit:movement():current_state():ducking()

	 then
	JUMP TO BLOCK #63
	else
	JUMP TO BLOCK #66
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #63 350-351, warpins: 1 ---
	--- END OF BLOCK #63 ---

	slot27 = if not weight_mul then
	JUMP TO BLOCK #64
	else
	JUMP TO BLOCK #65
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #64 352-352, warpins: 1 ---
	slot27 = 1
	--- END OF BLOCK #64 ---

	FLOW; TARGET BLOCK #65



	-- Decompilation error in this vicinity:
	--- BLOCK #65 353-361, warpins: 2 ---
	weight_mul = slot27 * managers.player:upgrade_value("player", "stand_still_crouch_camouflage_bonus", 1)

	--- END OF BLOCK #65 ---

	FLOW; TARGET BLOCK #66



	-- Decompilation error in this vicinity:
	--- BLOCK #66 362-370, warpins: 3 ---
	--- END OF BLOCK #66 ---

	slot27 = if managers.player:has_activate_temporary_upgrade("temporary", "chico_injector")
	 then
	JUMP TO BLOCK #67
	else
	JUMP TO BLOCK #71
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #67 371-380, warpins: 1 ---
	--- END OF BLOCK #67 ---

	slot27 = if managers.player:upgrade_value("player", "chico_preferred_target", false)

	 then
	JUMP TO BLOCK #68
	else
	JUMP TO BLOCK #71
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #68 381-382, warpins: 1 ---
	--- END OF BLOCK #68 ---

	slot27 = if not weight_mul then
	JUMP TO BLOCK #69
	else
	JUMP TO BLOCK #70
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #69 383-383, warpins: 1 ---
	slot27 = 1
	--- END OF BLOCK #69 ---

	FLOW; TARGET BLOCK #70



	-- Decompilation error in this vicinity:
	--- BLOCK #70 384-384, warpins: 2 ---
	weight_mul = slot27 * 1000
	--- END OF BLOCK #70 ---

	FLOW; TARGET BLOCK #71



	-- Decompilation error in this vicinity:
	--- BLOCK #71 385-388, warpins: 3 ---
	--- END OF BLOCK #71 ---

	slot27 = if _G.IS_VR then
	JUMP TO BLOCK #72
	else
	JUMP TO BLOCK #99
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #72 389-394, warpins: 1 ---
	--- END OF BLOCK #72 ---

	if tweak_data.vr.long_range_damage_reduction_distance[1] < distance then
	JUMP TO BLOCK #73
	else
	JUMP TO BLOCK #99
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #73 395-408, warpins: 1 ---
	local mul = math.clamp(distance / tweak_data.vr.long_range_damage_reduction_distance[2] / 2, 0, 1) + 1
	--- END OF BLOCK #73 ---

	slot28 = if not weight_mul then
	JUMP TO BLOCK #74
	else
	JUMP TO BLOCK #75
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #74 409-409, warpins: 1 ---
	slot28 = 1
	--- END OF BLOCK #74 ---

	FLOW; TARGET BLOCK #75



	-- Decompilation error in this vicinity:
	--- BLOCK #75 410-411, warpins: 2 ---
	weight_mul = slot28 * mul

	--- END OF BLOCK #75 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #99



	-- Decompilation error in this vicinity:
	--- BLOCK #76 412-416, warpins: 1 ---
	--- END OF BLOCK #76 ---

	slot27 = if att_unit:base()
	 then
	JUMP TO BLOCK #77
	else
	JUMP TO BLOCK #99
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #77 417-422, warpins: 1 ---
	--- END OF BLOCK #77 ---

	slot27 = if att_unit:base()
	.upgrade_value then
	JUMP TO BLOCK #78
	else
	JUMP TO BLOCK #99
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #78 423-427, warpins: 1 ---
	--- END OF BLOCK #78 ---

	slot27 = if att_unit:movement()
	 then
	JUMP TO BLOCK #79
	else
	JUMP TO BLOCK #87
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #79 428-433, warpins: 1 ---
	--- END OF BLOCK #79 ---

	slot27 = if not att_unit:movement()
	._move_data then
	JUMP TO BLOCK #80
	else
	JUMP TO BLOCK #87
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #80 434-439, warpins: 1 ---
	--- END OF BLOCK #80 ---

	slot27 = if att_unit:movement()
	._pose_code then
	JUMP TO BLOCK #81
	else
	JUMP TO BLOCK #87
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #81 440-445, warpins: 1 ---
	--- END OF BLOCK #81 ---

	if att_unit:movement()

	._pose_code == 2 then
	JUMP TO BLOCK #82
	else
	JUMP TO BLOCK #87
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #82 446-447, warpins: 1 ---
	--- END OF BLOCK #82 ---

	slot27 = if not weight_mul then
	JUMP TO BLOCK #83
	else
	JUMP TO BLOCK #84
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #83 448-448, warpins: 1 ---
	slot27 = 1

	--- END OF BLOCK #83 ---

	FLOW; TARGET BLOCK #84



	-- Decompilation error in this vicinity:
	--- BLOCK #84 449-458, warpins: 2 ---
	--- END OF BLOCK #84 ---

	slot28 = if not att_unit:base():upgrade_value("player", "stand_still_crouch_camouflage_bonus")

	 then
	JUMP TO BLOCK #85
	else
	JUMP TO BLOCK #86
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #85 459-459, warpins: 1 ---
	slot28 = 1
	--- END OF BLOCK #85 ---

	FLOW; TARGET BLOCK #86



	-- Decompilation error in this vicinity:
	--- BLOCK #86 460-460, warpins: 2 ---
	weight_mul = slot27 * slot28

	--- END OF BLOCK #86 ---

	FLOW; TARGET BLOCK #87



	-- Decompilation error in this vicinity:
	--- BLOCK #87 461-466, warpins: 5 ---
	--- END OF BLOCK #87 ---

	slot27 = if att_unit:base()
	.has_activate_temporary_upgrade then
	JUMP TO BLOCK #88
	else
	JUMP TO BLOCK #93
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #88 467-476, warpins: 1 ---
	--- END OF BLOCK #88 ---

	slot27 = if att_unit:base():has_activate_temporary_upgrade("temporary", "chico_injector")
	 then
	JUMP TO BLOCK #89
	else
	JUMP TO BLOCK #93
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #89 477-486, warpins: 1 ---
	--- END OF BLOCK #89 ---

	slot27 = if att_unit:base():upgrade_value("player", "chico_preferred_target")

	 then
	JUMP TO BLOCK #90
	else
	JUMP TO BLOCK #93
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #90 487-488, warpins: 1 ---
	--- END OF BLOCK #90 ---

	slot27 = if not weight_mul then
	JUMP TO BLOCK #91
	else
	JUMP TO BLOCK #92
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #91 489-489, warpins: 1 ---
	slot27 = 1
	--- END OF BLOCK #91 ---

	FLOW; TARGET BLOCK #92



	-- Decompilation error in this vicinity:
	--- BLOCK #92 490-490, warpins: 2 ---
	weight_mul = slot27 * 1000

	--- END OF BLOCK #92 ---

	FLOW; TARGET BLOCK #93



	-- Decompilation error in this vicinity:
	--- BLOCK #93 491-496, warpins: 4 ---
	--- END OF BLOCK #93 ---

	slot27 = if att_unit:movement()
	.is_vr then
	JUMP TO BLOCK #94
	else
	JUMP TO BLOCK #99
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #94 497-504, warpins: 1 ---
	--- END OF BLOCK #94 ---

	slot27 = if att_unit:movement():is_vr()

	 then
	JUMP TO BLOCK #95
	else
	JUMP TO BLOCK #99
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #95 505-510, warpins: 1 ---
	--- END OF BLOCK #95 ---

	if tweak_data.vr.long_range_damage_reduction_distance[1] < distance then
	JUMP TO BLOCK #96
	else
	JUMP TO BLOCK #99
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #96 511-524, warpins: 1 ---
	local mul = math.clamp(distance / tweak_data.vr.long_range_damage_reduction_distance[2] / 2, 0, 1) + 1
	--- END OF BLOCK #96 ---

	slot28 = if not weight_mul then
	JUMP TO BLOCK #97
	else
	JUMP TO BLOCK #98
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #97 525-525, warpins: 1 ---
	slot28 = 1
	--- END OF BLOCK #97 ---

	FLOW; TARGET BLOCK #98



	-- Decompilation error in this vicinity:
	--- BLOCK #98 526-526, warpins: 2 ---
	weight_mul = slot28 * mul
	--- END OF BLOCK #98 ---

	FLOW; TARGET BLOCK #99



	-- Decompilation error in this vicinity:
	--- BLOCK #99 527-528, warpins: 9 ---
	--- END OF BLOCK #99 ---

	slot26 = if weight_mul then
	JUMP TO BLOCK #100
	else
	JUMP TO BLOCK #106
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #100 529-530, warpins: 1 ---
	--- END OF BLOCK #100 ---

	if weight_mul ~= 1 then
	JUMP TO BLOCK #101
	else
	JUMP TO BLOCK #106
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #101 531-533, warpins: 1 ---
	weight_mul = 1 / weight_mul
	--- END OF BLOCK #101 ---

	slot21 = if alert_dt then
	JUMP TO BLOCK #102
	else
	JUMP TO BLOCK #103
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #102 534-534, warpins: 1 ---
	alert_dt = alert_dt * weight_mul
	--- END OF BLOCK #102 ---

	FLOW; TARGET BLOCK #103



	-- Decompilation error in this vicinity:
	--- BLOCK #103 535-536, warpins: 2 ---
	--- END OF BLOCK #103 ---

	slot22 = if dmg_dt then
	JUMP TO BLOCK #104
	else
	JUMP TO BLOCK #105
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #104 537-537, warpins: 1 ---
	dmg_dt = dmg_dt * weight_mul
	--- END OF BLOCK #104 ---

	FLOW; TARGET BLOCK #105



	-- Decompilation error in this vicinity:
	--- BLOCK #105 538-538, warpins: 2 ---
	distance = distance * weight_mul
	--- END OF BLOCK #105 ---

	FLOW; TARGET BLOCK #106



	-- Decompilation error in this vicinity:
	--- BLOCK #106 539-542, warpins: 3 ---
	--- END OF BLOCK #106 ---

	if reaction ~= AIAttentionObject.REACT_SPECIAL_ATTACK then
	JUMP TO BLOCK #107
	else
	JUMP TO BLOCK #108
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #107 543-544, warpins: 1 ---
	slot27 = false
	--- END OF BLOCK #107 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #109



	-- Decompilation error in this vicinity:
	--- BLOCK #108 545-545, warpins: 1 ---
	local assault_reaction = true
	--- END OF BLOCK #108 ---

	FLOW; TARGET BLOCK #109



	-- Decompilation error in this vicinity:
	--- BLOCK #109 546-548, warpins: 2 ---
	local visible = attention_data.verified
	--- END OF BLOCK #109 ---

	if distance >= near_threshold then
	JUMP TO BLOCK #110
	else
	JUMP TO BLOCK #111
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #110 549-550, warpins: 1 ---
	slot29 = false
	--- END OF BLOCK #110 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #112



	-- Decompilation error in this vicinity:
	--- BLOCK #111 551-551, warpins: 1 ---
	local near = true

	--- END OF BLOCK #111 ---

	FLOW; TARGET BLOCK #112



	-- Decompilation error in this vicinity:
	--- BLOCK #112 552-553, warpins: 2 ---
	--- END OF BLOCK #112 ---

	if distance < too_close_threshold then
	JUMP TO BLOCK #113
	else
	JUMP TO BLOCK #114
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #113 554-564, warpins: 1 ---
	--- END OF BLOCK #113 ---

	if math.abs(attention_data.m_pos.z - data.m_pos.z)

	 >= 250 then
	JUMP TO BLOCK #114
	else
	JUMP TO BLOCK #115
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #114 565-566, warpins: 2 ---
	slot30 = false
	--- END OF BLOCK #114 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #116



	-- Decompilation error in this vicinity:
	--- BLOCK #115 567-567, warpins: 1 ---
	local too_near = true
	--- END OF BLOCK #115 ---

	FLOW; TARGET BLOCK #116



	-- Decompilation error in this vicinity:
	--- BLOCK #116 568-569, warpins: 2 ---
	--- END OF BLOCK #116 ---

	if status ~= nil then
	JUMP TO BLOCK #117
	else
	JUMP TO BLOCK #118
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #117 570-571, warpins: 1 ---
	slot31 = false
	--- END OF BLOCK #117 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #119



	-- Decompilation error in this vicinity:
	--- BLOCK #118 572-572, warpins: 1 ---
	local free_status = true
	--- END OF BLOCK #118 ---

	FLOW; TARGET BLOCK #119



	-- Decompilation error in this vicinity:
	--- BLOCK #119 573-575, warpins: 2 ---
	--- END OF BLOCK #119 ---

	if alert_dt >= 3.5 then
	JUMP TO BLOCK #120
	else
	JUMP TO BLOCK #121
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #120 576-577, warpins: 1 ---
	slot32 = false
	--- END OF BLOCK #120 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #122



	-- Decompilation error in this vicinity:
	--- BLOCK #121 578-578, warpins: 1 ---
	local has_alerted = true
	--- END OF BLOCK #121 ---

	FLOW; TARGET BLOCK #122



	-- Decompilation error in this vicinity:
	--- BLOCK #122 579-581, warpins: 2 ---
	--- END OF BLOCK #122 ---

	if dmg_dt >= 5 then
	JUMP TO BLOCK #123
	else
	JUMP TO BLOCK #124
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #123 582-583, warpins: 1 ---
	slot33 = false
	--- END OF BLOCK #123 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #125



	-- Decompilation error in this vicinity:
	--- BLOCK #124 584-584, warpins: 1 ---
	local has_damaged = true
	--- END OF BLOCK #124 ---

	FLOW; TARGET BLOCK #125



	-- Decompilation error in this vicinity:
	--- BLOCK #125 585-588, warpins: 2 ---
	local reviving = nil
	--- END OF BLOCK #125 ---

	slot35 = if attention_data.is_local_player then
	JUMP TO BLOCK #126
	else
	JUMP TO BLOCK #129
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #126 589-597, warpins: 1 ---
	local iparams = att_unit:movement():current_state()._interact_params

	--- END OF BLOCK #126 ---

	slot35 = if iparams then
	JUMP TO BLOCK #127
	else
	JUMP TO BLOCK #131
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #127 598-605, warpins: 1 ---
	--- END OF BLOCK #127 ---

	if managers.criminals:character_name_by_unit(iparams.object)

	 ~= nil then
	JUMP TO BLOCK #128
	else
	JUMP TO BLOCK #131
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #128 606-607, warpins: 1 ---
	reviving = true

	--- END OF BLOCK #128 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #131



	-- Decompilation error in this vicinity:
	--- BLOCK #129 608-612, warpins: 1 ---
	--- END OF BLOCK #129 ---

	slot34 = if att_unit:anim_data()

	 then
	JUMP TO BLOCK #130
	else
	JUMP TO BLOCK #131
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #130 613-616, warpins: 1 ---
	reviving = att_unit:anim_data().revive
	--- END OF BLOCK #130 ---

	FLOW; TARGET BLOCK #131



	-- Decompilation error in this vicinity:
	--- BLOCK #131 617-620, warpins: 5 ---
	local target_priority = distance
	local target_priority_slot = 0
	--- END OF BLOCK #131 ---

	slot28 = if visible then
	JUMP TO BLOCK #132
	else
	JUMP TO BLOCK #148
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #132 621-622, warpins: 1 ---
	--- END OF BLOCK #132 ---

	slot34 = if not reviving then
	JUMP TO BLOCK #133
	else
	JUMP TO BLOCK #148
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #133 623-625, warpins: 1 ---
	--- END OF BLOCK #133 ---

	if distance < 500 then
	JUMP TO BLOCK #134
	else
	JUMP TO BLOCK #135
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #134 626-627, warpins: 1 ---
	target_priority_slot = 2
	--- END OF BLOCK #134 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #138



	-- Decompilation error in this vicinity:
	--- BLOCK #135 628-630, warpins: 1 ---
	--- END OF BLOCK #135 ---

	if distance < 1500 then
	JUMP TO BLOCK #136
	else
	JUMP TO BLOCK #137
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #136 631-632, warpins: 1 ---
	target_priority_slot = 4
	--- END OF BLOCK #136 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #138



	-- Decompilation error in this vicinity:
	--- BLOCK #137 633-633, warpins: 1 ---
	target_priority_slot = 6
	--- END OF BLOCK #137 ---

	FLOW; TARGET BLOCK #138



	-- Decompilation error in this vicinity:
	--- BLOCK #138 634-635, warpins: 3 ---
	--- END OF BLOCK #138 ---

	slot33 = if has_damaged then
	JUMP TO BLOCK #139
	else
	JUMP TO BLOCK #140
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #139 636-637, warpins: 1 ---
	target_priority_slot = target_priority_slot - 2
	--- END OF BLOCK #139 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #145



	-- Decompilation error in this vicinity:
	--- BLOCK #140 638-639, warpins: 1 ---
	--- END OF BLOCK #140 ---

	slot32 = if has_alerted then
	JUMP TO BLOCK #141
	else
	JUMP TO BLOCK #142
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #141 640-641, warpins: 1 ---
	target_priority_slot = target_priority_slot - 1
	--- END OF BLOCK #141 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #145



	-- Decompilation error in this vicinity:
	--- BLOCK #142 642-643, warpins: 1 ---
	--- END OF BLOCK #142 ---

	slot31 = if free_status then
	JUMP TO BLOCK #143
	else
	JUMP TO BLOCK #145
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #143 644-645, warpins: 1 ---
	--- END OF BLOCK #143 ---

	slot27 = if assault_reaction then
	JUMP TO BLOCK #144
	else
	JUMP TO BLOCK #145
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #144 646-646, warpins: 1 ---
	target_priority_slot = 5
	--- END OF BLOCK #144 ---

	FLOW; TARGET BLOCK #145



	-- Decompilation error in this vicinity:
	--- BLOCK #145 647-648, warpins: 5 ---
	--- END OF BLOCK #145 ---

	slot25 = if old_enemy then
	JUMP TO BLOCK #146
	else
	JUMP TO BLOCK #147
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #146 649-649, warpins: 1 ---
	target_priority_slot = target_priority_slot - 3
	--- END OF BLOCK #146 ---

	FLOW; TARGET BLOCK #147



	-- Decompilation error in this vicinity:
	--- BLOCK #147 650-657, warpins: 2 ---
	target_priority_slot = math.clamp(target_priority_slot, 1, 10)
	--- END OF BLOCK #147 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #150



	-- Decompilation error in this vicinity:
	--- BLOCK #148 658-659, warpins: 2 ---
	--- END OF BLOCK #148 ---

	slot31 = if free_status then
	JUMP TO BLOCK #149
	else
	JUMP TO BLOCK #150
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #149 660-660, warpins: 1 ---
	target_priority_slot = 7
	--- END OF BLOCK #149 ---

	FLOW; TARGET BLOCK #150



	-- Decompilation error in this vicinity:
	--- BLOCK #150 661-664, warpins: 3 ---
	--- END OF BLOCK #150 ---

	if reaction < AIAttentionObject.REACT_COMBAT then
	JUMP TO BLOCK #151
	else
	JUMP TO BLOCK #152
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #151 665-673, warpins: 1 ---
	target_priority_slot = 10 + target_priority_slot + math.max(0, AIAttentionObject.REACT_COMBAT - reaction)
	--- END OF BLOCK #151 ---

	FLOW; TARGET BLOCK #152



	-- Decompilation error in this vicinity:
	--- BLOCK #152 674-675, warpins: 2 ---
	--- END OF BLOCK #152 ---

	if target_priority_slot ~= 0 then
	JUMP TO BLOCK #153
	else
	JUMP TO BLOCK #162
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #153 676-678, warpins: 1 ---
	local best = false
	--- END OF BLOCK #153 ---

	slot3 = if not best_target then
	JUMP TO BLOCK #154
	else
	JUMP TO BLOCK #155
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #154 679-680, warpins: 1 ---
	best = true
	--- END OF BLOCK #154 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #160



	-- Decompilation error in this vicinity:
	--- BLOCK #155 681-682, warpins: 1 ---
	--- END OF BLOCK #155 ---

	if target_priority_slot < best_target_priority_slot then
	JUMP TO BLOCK #156
	else
	JUMP TO BLOCK #157
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #156 683-684, warpins: 1 ---
	best = true
	--- END OF BLOCK #156 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #160



	-- Decompilation error in this vicinity:
	--- BLOCK #157 685-686, warpins: 1 ---
	--- END OF BLOCK #157 ---

	if target_priority_slot == best_target_priority_slot then
	JUMP TO BLOCK #158
	else
	JUMP TO BLOCK #160
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #158 687-688, warpins: 1 ---
	--- END OF BLOCK #158 ---

	if target_priority < best_target_priority then
	JUMP TO BLOCK #159
	else
	JUMP TO BLOCK #160
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #159 689-689, warpins: 1 ---
	best = true
	--- END OF BLOCK #159 ---

	FLOW; TARGET BLOCK #160



	-- Decompilation error in this vicinity:
	--- BLOCK #160 690-691, warpins: 5 ---
	--- END OF BLOCK #160 ---

	slot37 = if best then
	JUMP TO BLOCK #161
	else
	JUMP TO BLOCK #162
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #161 692-695, warpins: 1 ---
	best_target = attention_data
	best_target_reaction = reaction
	best_target_priority_slot = target_priority_slot
	best_target_priority = target_priority

	--- END OF BLOCK #161 ---

	FLOW; TARGET BLOCK #162



	-- Decompilation error in this vicinity:
	--- BLOCK #162 696-697, warpins: 11 ---
	--- END OF BLOCK #162 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #19



	-- Decompilation error in this vicinity:
	--- BLOCK #163 698-701, warpins: 1 ---
	return best_target, best_target_priority_slot, best_target_reaction
	--- END OF BLOCK #163 ---



end

function CopLogicIdle._upd_curious_reaction(data)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-15, warpins: 1 ---
	local my_data = data.internal_data
	local unit = data.unit
	local my_pos = data.unit:movement():m_head_pos()
	local turn_spin = 70
	local attention_obj = data.attention_obj
	local dis = attention_obj.dis
	--- END OF BLOCK #0 ---

	slot7 = if data.cool then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 16-20, warpins: 1 ---
	--- END OF BLOCK #1 ---

	if attention_obj.reaction ~= AIAttentionObject.REACT_SUSPICIOUS then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #3
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 21-22, warpins: 1 ---
	slot7 = false
	--- END OF BLOCK #2 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #3 23-23, warpins: 1 ---
	local is_suspicious = true
	--- END OF BLOCK #3 ---

	FLOW; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #4 24-32, warpins: 3 ---
	local set_attention = data.unit:movement():attention()

	--- END OF BLOCK #4 ---

	slot8 = if set_attention then
	JUMP TO BLOCK #5
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #5 33-36, warpins: 1 ---
	--- END OF BLOCK #5 ---

	if set_attention.u_key ~= attention_obj.u_key then
	JUMP TO BLOCK #6
	else
	JUMP TO BLOCK #7
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #6 37-41, warpins: 2 ---
	CopLogicBase._set_attention(data, attention_obj)

	--- END OF BLOCK #6 ---

	FLOW; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #7 42-47, warpins: 2 ---
	local function _get_spin_to_att_obj()

		-- Decompilation error in this vicinity:
		--- BLOCK #0 1-23, warpins: 1 ---
		return attention_obj.m_pos - data.m_pos:to_polar_with_reference(data.unit:movement():m_rot():y(), math.UP).spin
		--- END OF BLOCK #0 ---



	end

	local turned_around = nil
	--- END OF BLOCK #7 ---

	slot11 = if attention_obj.settings.turn_around_range then
	JUMP TO BLOCK #8
	else
	JUMP TO BLOCK #9
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #8 48-51, warpins: 1 ---
	--- END OF BLOCK #8 ---

	if dis < attention_obj.settings.turn_around_range then
	JUMP TO BLOCK #9
	else
	JUMP TO BLOCK #15
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #9 52-54, warpins: 2 ---
	--- END OF BLOCK #9 ---

	slot11 = if data.objective then
	JUMP TO BLOCK #10
	else
	JUMP TO BLOCK #11
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #10 55-58, warpins: 1 ---
	--- END OF BLOCK #10 ---

	slot11 = if not data.objective.rot then
	JUMP TO BLOCK #11
	else
	JUMP TO BLOCK #15
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #11 59-62, warpins: 2 ---
	local suspect_spin = _get_spin_to_att_obj()

	--- END OF BLOCK #11 ---

	if turn_spin < suspect_spin then
	JUMP TO BLOCK #12
	else
	JUMP TO BLOCK #15
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #12 63-71, warpins: 1 ---
	CopLogicIdle._turn_by_spin(data, my_data, suspect_spin)

	--- END OF BLOCK #12 ---

	slot12 = if my_data.rubberband_rotation then
	JUMP TO BLOCK #13
	else
	JUMP TO BLOCK #14
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #13 72-73, warpins: 1 ---
	my_data.fwd_offset = true
	--- END OF BLOCK #13 ---

	FLOW; TARGET BLOCK #14



	-- Decompilation error in this vicinity:
	--- BLOCK #14 74-74, warpins: 2 ---
	turned_around = true

	--- END OF BLOCK #14 ---

	FLOW; TARGET BLOCK #15



	-- Decompilation error in this vicinity:
	--- BLOCK #15 75-76, warpins: 4 ---
	--- END OF BLOCK #15 ---

	slot7 = if is_suspicious then
	JUMP TO BLOCK #16
	else
	JUMP TO BLOCK #17
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #16 77-83, warpins: 1 ---
	return CopLogicBase._upd_suspicion(data, my_data, attention_obj)
	--- END OF BLOCK #16 ---

	FLOW; TARGET BLOCK #17



	-- Decompilation error in this vicinity:
	--- BLOCK #17 84-85, warpins: 2 ---
	return
	--- END OF BLOCK #17 ---



end

function CopLogicIdle._turn_by_spin(data, my_data, spin)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-14, warpins: 1 ---
	local new_action_data = {
		body_part = 2,
		type = "turn"
	}
	new_action_data.angle = spin
	my_data.turning = data.unit:brain():action_request(new_action_data)

	--- END OF BLOCK #0 ---

	slot4 = if my_data.turning then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #2
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 15-16, warpins: 1 ---
	return true
	--- END OF BLOCK #1 ---

	FLOW; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #2 17-17, warpins: 2 ---
	return
	--- END OF BLOCK #2 ---



end

function CopLogicIdle._chk_objective_needs_travel(data, new_objective)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-3, warpins: 1 ---
	--- END OF BLOCK #0 ---

	slot2 = if not new_objective.nav_seg then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #3
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 4-6, warpins: 1 ---
	--- END OF BLOCK #1 ---

	if new_objective.type ~= "follow" then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #3
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 7-7, warpins: 1 ---
	return
	--- END OF BLOCK #2 ---

	FLOW; TARGET BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #3 8-10, warpins: 3 ---
	--- END OF BLOCK #3 ---

	slot2 = if new_objective.in_place then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #5
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 11-11, warpins: 1 ---
	return
	--- END OF BLOCK #4 ---

	FLOW; TARGET BLOCK #5



	-- Decompilation error in this vicinity:
	--- BLOCK #5 12-14, warpins: 2 ---
	--- END OF BLOCK #5 ---

	slot2 = if new_objective.pos then
	JUMP TO BLOCK #6
	else
	JUMP TO BLOCK #7
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #6 15-16, warpins: 1 ---
	return true

	--- END OF BLOCK #6 ---

	FLOW; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #7 17-19, warpins: 2 ---
	--- END OF BLOCK #7 ---

	slot2 = if new_objective.area then
	JUMP TO BLOCK #8
	else
	JUMP TO BLOCK #10
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #8 20-34, warpins: 1 ---
	--- END OF BLOCK #8 ---

	slot2 = if new_objective.area.nav_segs[data.unit:movement():nav_tracker():nav_segment()

	] then
	JUMP TO BLOCK #9
	else
	JUMP TO BLOCK #10
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #9 35-37, warpins: 1 ---
	new_objective.in_place = true

	return
	--- END OF BLOCK #9 ---

	FLOW; TARGET BLOCK #10



	-- Decompilation error in this vicinity:
	--- BLOCK #10 38-39, warpins: 3 ---
	return true
	--- END OF BLOCK #10 ---



end

function CopLogicIdle._upd_stance_and_pose(data, my_data, objective)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-10, warpins: 1 ---
	--- END OF BLOCK #0 ---

	slot3 = if data.unit:movement():chk_action_forbidden("walk")

	 then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #2
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 11-11, warpins: 1 ---
	return

	--- END OF BLOCK #1 ---

	FLOW; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #2 12-14, warpins: 2 ---
	local obj_has_stance, obj_has_pose = nil
	--- END OF BLOCK #2 ---

	slot2 = if objective then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #17
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 15-17, warpins: 1 ---
	--- END OF BLOCK #3 ---

	slot5 = if objective.stance then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #9
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 18-21, warpins: 1 ---
	--- END OF BLOCK #4 ---

	slot5 = if data.char_tweak.allowed_stances then
	JUMP TO BLOCK #5
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #5 22-27, warpins: 1 ---
	--- END OF BLOCK #5 ---

	slot5 = if data.char_tweak.allowed_stances[objective.stance] then
	JUMP TO BLOCK #6
	else
	JUMP TO BLOCK #9
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #6 28-36, warpins: 2 ---
	obj_has_stance = true
	local upper_body_action = data.unit:movement()._active_actions[3]

	--- END OF BLOCK #6 ---

	slot5 = if upper_body_action then
	JUMP TO BLOCK #7
	else
	JUMP TO BLOCK #8
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #7 37-41, warpins: 1 ---
	--- END OF BLOCK #7 ---

	if upper_body_action:type()
	 ~= "shoot" then
	JUMP TO BLOCK #8
	else
	JUMP TO BLOCK #9
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #8 42-49, warpins: 2 ---
	data.unit:movement():set_stance(objective.stance)

	--- END OF BLOCK #8 ---

	FLOW; TARGET BLOCK #9



	-- Decompilation error in this vicinity:
	--- BLOCK #9 50-52, warpins: 4 ---
	--- END OF BLOCK #9 ---

	slot5 = if objective.pose then
	JUMP TO BLOCK #10
	else
	JUMP TO BLOCK #17
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #10 53-55, warpins: 1 ---
	--- END OF BLOCK #10 ---

	slot5 = if not data.is_suppressed then
	JUMP TO BLOCK #11
	else
	JUMP TO BLOCK #17
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #11 56-59, warpins: 1 ---
	--- END OF BLOCK #11 ---

	slot5 = if data.char_tweak.allowed_poses then
	JUMP TO BLOCK #12
	else
	JUMP TO BLOCK #13
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #12 60-65, warpins: 1 ---
	--- END OF BLOCK #12 ---

	slot5 = if data.char_tweak.allowed_poses[objective.pose] then
	JUMP TO BLOCK #13
	else
	JUMP TO BLOCK #17
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #13 66-69, warpins: 2 ---
	obj_has_pose = true

	--- END OF BLOCK #13 ---

	if objective.pose == "crouch" then
	JUMP TO BLOCK #14
	else
	JUMP TO BLOCK #15
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #14 70-74, warpins: 1 ---
	CopLogicAttack._chk_request_action_crouch(data)
	--- END OF BLOCK #14 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #17



	-- Decompilation error in this vicinity:
	--- BLOCK #15 75-77, warpins: 1 ---
	--- END OF BLOCK #15 ---

	if objective.pose == "stand" then
	JUMP TO BLOCK #16
	else
	JUMP TO BLOCK #17
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #16 78-81, warpins: 1 ---
	CopLogicAttack._chk_request_action_stand(data)
	--- END OF BLOCK #16 ---

	FLOW; TARGET BLOCK #17



	-- Decompilation error in this vicinity:
	--- BLOCK #17 82-83, warpins: 7 ---
	--- END OF BLOCK #17 ---

	slot3 = if not obj_has_stance then
	JUMP TO BLOCK #18
	else
	JUMP TO BLOCK #24
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #18 84-87, warpins: 1 ---
	--- END OF BLOCK #18 ---

	slot5 = if data.char_tweak.allowed_stances then
	JUMP TO BLOCK #19
	else
	JUMP TO BLOCK #24
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #19 88-97, warpins: 1 ---
	--- END OF BLOCK #19 ---

	slot5 = if not data.char_tweak.allowed_stances[data.unit:anim_data()
	.stance] then
	JUMP TO BLOCK #20
	else
	JUMP TO BLOCK #24
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #20 98-102, warpins: 1 ---
	--- END OF BLOCK #20 ---

	for stance_name, state in pairs(data.char_tweak.allowed_stances)

	LOOP BLOCK #21
	GO OUT TO BLOCK #24



	-- Decompilation error in this vicinity:
	--- BLOCK #21 103-104, warpins: 1 ---
	--- END OF BLOCK #21 ---

	slot9 = if state then
	JUMP TO BLOCK #22
	else
	JUMP TO BLOCK #23
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #22 105-113, warpins: 1 ---
	data.unit:movement():set_stance(stance_name)
	--- END OF BLOCK #22 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #24



	-- Decompilation error in this vicinity:
	--- BLOCK #23 114-115, warpins: 2 ---
	--- END OF BLOCK #23 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #20



	-- Decompilation error in this vicinity:
	--- BLOCK #24 116-117, warpins: 5 ---
	--- END OF BLOCK #24 ---

	slot4 = if not obj_has_pose then
	JUMP TO BLOCK #25
	else
	JUMP TO BLOCK #39
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #25 118-120, warpins: 1 ---
	--- END OF BLOCK #25 ---

	slot5 = if data.is_suppressed then
	JUMP TO BLOCK #26
	else
	JUMP TO BLOCK #30
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #26 121-127, warpins: 1 ---
	--- END OF BLOCK #26 ---

	slot5 = if not data.unit:anim_data()
	.crouch then
	JUMP TO BLOCK #27
	else
	JUMP TO BLOCK #30
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #27 128-131, warpins: 1 ---
	--- END OF BLOCK #27 ---

	slot5 = if data.char_tweak.allowed_poses then
	JUMP TO BLOCK #28
	else
	JUMP TO BLOCK #29
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #28 132-136, warpins: 1 ---
	--- END OF BLOCK #28 ---

	slot5 = if data.char_tweak.allowed_poses.crouch then
	JUMP TO BLOCK #29
	else
	JUMP TO BLOCK #30
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #29 137-141, warpins: 2 ---
	CopLogicAttack._chk_request_action_crouch(data)
	--- END OF BLOCK #29 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #39



	-- Decompilation error in this vicinity:
	--- BLOCK #30 142-145, warpins: 3 ---
	--- END OF BLOCK #30 ---

	slot5 = if data.char_tweak.allowed_poses then
	JUMP TO BLOCK #31
	else
	JUMP TO BLOCK #39
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #31 146-155, warpins: 1 ---
	--- END OF BLOCK #31 ---

	slot5 = if not data.char_tweak.allowed_poses[data.unit:anim_data()
	.pose] then
	JUMP TO BLOCK #32
	else
	JUMP TO BLOCK #39
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #32 156-160, warpins: 1 ---
	--- END OF BLOCK #32 ---

	for pose_name, state in pairs(data.char_tweak.allowed_poses)

	LOOP BLOCK #33
	GO OUT TO BLOCK #39



	-- Decompilation error in this vicinity:
	--- BLOCK #33 161-162, warpins: 1 ---
	--- END OF BLOCK #33 ---

	slot9 = if state then
	JUMP TO BLOCK #34
	else
	JUMP TO BLOCK #38
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #34 163-164, warpins: 1 ---
	--- END OF BLOCK #34 ---

	if pose_name == "crouch" then
	JUMP TO BLOCK #35
	else
	JUMP TO BLOCK #36
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #35 165-169, warpins: 1 ---
	CopLogicAttack._chk_request_action_crouch(data)
	--- END OF BLOCK #35 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #39



	-- Decompilation error in this vicinity:
	--- BLOCK #36 170-171, warpins: 1 ---
	--- END OF BLOCK #36 ---

	if pose_name == "stand" then
	JUMP TO BLOCK #37
	else
	JUMP TO BLOCK #39
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #37 172-176, warpins: 1 ---
	CopLogicAttack._chk_request_action_stand(data)

	--- END OF BLOCK #37 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #39



	-- Decompilation error in this vicinity:
	--- BLOCK #38 177-178, warpins: 2 ---
	--- END OF BLOCK #38 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #32



	-- Decompilation error in this vicinity:
	--- BLOCK #39 179-179, warpins: 8 ---
	return
	--- END OF BLOCK #39 ---



end

function CopLogicIdle._perform_objective_action(data, my_data, objective)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-2, warpins: 1 ---
	--- END OF BLOCK #0 ---

	slot2 = if objective then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #15
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 3-5, warpins: 1 ---
	--- END OF BLOCK #1 ---

	slot3 = if not my_data.action_started then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #15
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 6-12, warpins: 1 ---
	--- END OF BLOCK #2 ---

	slot3 = if not data.unit:anim_data()
	.act_idle then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 13-22, warpins: 1 ---
	--- END OF BLOCK #3 ---

	slot3 = if not data.unit:movement():chk_action_forbidden("action")

	 then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #15
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 23-25, warpins: 2 ---
	--- END OF BLOCK #4 ---

	slot3 = if objective.action then
	JUMP TO BLOCK #5
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #5 26-35, warpins: 1 ---
	my_data.action_started = data.unit:brain():action_request(objective.action)
	--- END OF BLOCK #5 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #6 36-37, warpins: 1 ---
	my_data.action_started = true
	--- END OF BLOCK #6 ---

	FLOW; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #7 38-40, warpins: 2 ---
	--- END OF BLOCK #7 ---

	slot3 = if my_data.action_started then
	JUMP TO BLOCK #8
	else
	JUMP TO BLOCK #15
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #8 41-43, warpins: 1 ---
	--- END OF BLOCK #8 ---

	slot3 = if not objective.action_duration then
	JUMP TO BLOCK #9
	else
	JUMP TO BLOCK #10
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #9 44-46, warpins: 1 ---
	--- END OF BLOCK #9 ---

	slot3 = if objective.action_timeout_t then
	JUMP TO BLOCK #10
	else
	JUMP TO BLOCK #13
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #10 47-55, warpins: 2 ---
	my_data.action_timeout_clbk_id = "CopLogicIdle_action_timeout" .. tostring(data.key)
	--- END OF BLOCK #10 ---

	slot3 = if not objective.action_timeout_t then
	JUMP TO BLOCK #11
	else
	JUMP TO BLOCK #12
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #11 56-58, warpins: 1 ---
	local action_timeout_t = data.t + objective.action_duration
	--- END OF BLOCK #11 ---

	FLOW; TARGET BLOCK #12



	-- Decompilation error in this vicinity:
	--- BLOCK #12 59-71, warpins: 2 ---
	objective.action_timeout_t = action_timeout_t

	CopLogicBase.add_delayed_clbk(my_data, my_data.action_timeout_clbk_id, callback(CopLogicIdle, CopLogicIdle, "clbk_action_timeout", data), action_timeout_t)
	--- END OF BLOCK #12 ---

	FLOW; TARGET BLOCK #13



	-- Decompilation error in this vicinity:
	--- BLOCK #13 72-74, warpins: 2 ---
	--- END OF BLOCK #13 ---

	slot3 = if objective.action_start_clbk then
	JUMP TO BLOCK #14
	else
	JUMP TO BLOCK #15
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #14 75-77, warpins: 1 ---
	objective.action_start_clbk(data.unit)

	--- END OF BLOCK #14 ---

	FLOW; TARGET BLOCK #15



	-- Decompilation error in this vicinity:
	--- BLOCK #15 78-78, warpins: 6 ---
	return
	--- END OF BLOCK #15 ---



end

function CopLogicIdle._upd_stop_old_action(data, my_data, objective)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-3, warpins: 1 ---
	--- END OF BLOCK #0 ---

	slot3 = if not my_data.action_started then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 4-5, warpins: 1 ---
	--- END OF BLOCK #1 ---

	slot3 = if objective then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 6-8, warpins: 1 ---
	--- END OF BLOCK #2 ---

	slot3 = if objective.action then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 9-15, warpins: 1 ---
	slot3 = not data.unit:anim_data().to_idle
	--- END OF BLOCK #3 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #4 16-17, warpins: 1 ---
	slot3 = false
	--- END OF BLOCK #4 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #5 18-18, warpins: 0 ---
	local can_stop_action = true
	--- END OF BLOCK #5 ---

	FLOW; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #6 19-20, warpins: 5 ---
	--- END OF BLOCK #6 ---

	slot2 = if objective then
	JUMP TO BLOCK #7
	else
	JUMP TO BLOCK #9
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #7 21-23, warpins: 1 ---
	--- END OF BLOCK #7 ---

	if objective.type == "free" then
	JUMP TO BLOCK #8
	else
	JUMP TO BLOCK #9
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #8 24-24, warpins: 1 ---
	can_stop_action = true

	--- END OF BLOCK #8 ---

	FLOW; TARGET BLOCK #9



	-- Decompilation error in this vicinity:
	--- BLOCK #9 25-26, warpins: 3 ---
	--- END OF BLOCK #9 ---

	slot3 = if not can_stop_action then
	JUMP TO BLOCK #10
	else
	JUMP TO BLOCK #11
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #10 27-27, warpins: 1 ---
	return

	--- END OF BLOCK #10 ---

	FLOW; TARGET BLOCK #11



	-- Decompilation error in this vicinity:
	--- BLOCK #11 28-30, warpins: 2 ---
	--- END OF BLOCK #11 ---

	slot4 = if my_data.advancing then
	JUMP TO BLOCK #12
	else
	JUMP TO BLOCK #14
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #12 31-40, warpins: 1 ---
	--- END OF BLOCK #12 ---

	slot4 = if not data.unit:movement():chk_action_forbidden("idle")
	 then
	JUMP TO BLOCK #13
	else
	JUMP TO BLOCK #19
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #13 41-49, warpins: 1 ---
	data.unit:brain():action_request({
		sync = true,
		body_part = 2,
		type = "idle"
	})
	--- END OF BLOCK #13 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #19



	-- Decompilation error in this vicinity:
	--- BLOCK #14 50-59, warpins: 1 ---
	--- END OF BLOCK #14 ---

	slot4 = if not data.unit:movement():chk_action_forbidden("idle")
	 then
	JUMP TO BLOCK #15
	else
	JUMP TO BLOCK #17
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #15 60-66, warpins: 1 ---
	--- END OF BLOCK #15 ---

	slot4 = if data.unit:anim_data()
	.needs_idle then
	JUMP TO BLOCK #16
	else
	JUMP TO BLOCK #17
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #16 67-71, warpins: 1 ---
	CopLogicIdle._start_idle_action_from_act(data)
	--- END OF BLOCK #16 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #19



	-- Decompilation error in this vicinity:
	--- BLOCK #17 72-78, warpins: 2 ---
	--- END OF BLOCK #17 ---

	slot4 = if data.unit:anim_data()
	.act_idle then
	JUMP TO BLOCK #18
	else
	JUMP TO BLOCK #19
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #18 79-86, warpins: 1 ---
	data.unit:brain():action_request({
		sync = true,
		body_part = 2,
		type = "idle"
	})
	--- END OF BLOCK #18 ---

	FLOW; TARGET BLOCK #19



	-- Decompilation error in this vicinity:
	--- BLOCK #19 87-92, warpins: 5 ---
	CopLogicIdle._chk_has_old_action(data, my_data)

	return
	--- END OF BLOCK #19 ---



end

function CopLogicIdle._chk_has_old_action(data, my_data)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-7, warpins: 1 ---
	local anim_data = data.unit:anim_data()
	--- END OF BLOCK #0 ---

	slot3 = if not anim_data.to_idle then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #2
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 8-8, warpins: 1 ---
	slot3 = anim_data.act
	--- END OF BLOCK #1 ---

	FLOW; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #2 9-17, warpins: 2 ---
	my_data.has_old_action = slot3
	local lower_body_action = data.unit:movement()._active_actions[2]

	--- END OF BLOCK #2 ---

	slot4 = if lower_body_action then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #7
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 18-22, warpins: 1 ---
	--- END OF BLOCK #3 ---

	if lower_body_action:type()

	 == "walk" then
	JUMP TO BLOCK #4
	else
	JUMP TO BLOCK #5
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #4 23-24, warpins: 1 ---
	slot4 = lower_body_action
	--- END OF BLOCK #4 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #5 25-26, warpins: 1 ---
	slot4 = false
	--- END OF BLOCK #5 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #6 27-27, warpins: 0 ---
	slot4 = true
	--- END OF BLOCK #6 ---

	FLOW; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #7 28-29, warpins: 4 ---
	my_data.advancing = slot4

	return
	--- END OF BLOCK #7 ---



end

function CopLogicIdle._start_idle_action_from_act(data)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-11, warpins: 1 ---
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

	return
	--- END OF BLOCK #0 ---



end
