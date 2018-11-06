require("lib/units/enemies/cop/logics/CopLogicAttack")

TeamAILogicAssault = class(CopLogicAttack)
TeamAILogicAssault._COVER_CHK_INTERVAL = 2
TeamAILogicAssault.on_cop_neutralized = TeamAILogicIdle.on_cop_neutralized
TeamAILogicAssault.on_objective_unit_damaged = TeamAILogicIdle.on_objective_unit_damaged
TeamAILogicAssault.on_alert = TeamAILogicIdle.on_alert
TeamAILogicAssault.on_intimidated = TeamAILogicIdle.on_intimidated
TeamAILogicAssault.on_long_dis_interacted = TeamAILogicIdle.on_long_dis_interacted
TeamAILogicAssault.on_new_objective = TeamAILogicIdle.on_new_objective
TeamAILogicAssault.on_objective_unit_destroyed = TeamAILogicBase.on_objective_unit_destroyed
TeamAILogicAssault.is_available_for_assignment = TeamAILogicIdle.is_available_for_assignment
TeamAILogicAssault.clbk_heat = TeamAILogicIdle.clbk_heat

function TeamAILogicAssault.enter(data, new_logic_name, enter_params)
	TeamAILogicBase.enter(data, new_logic_name, enter_params)
	data.unit:brain():cancel_all_pathing_searches()

	local old_internal_data = data.internal_data
	local my_data = {
		unit = data.unit
	}
	data.internal_data = my_data
	my_data.detection = data.char_tweak.detection.combat
	my_data.cover_chk_t = data.t + TeamAILogicAssault._COVER_CHK_INTERVAL
	my_data.weapon_range = data.char_tweak.weapon[data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage].range

	if old_internal_data then
		my_data.attention_unit = old_internal_data.attention_unit

		CopLogicAttack._set_best_cover(data, my_data, old_internal_data.best_cover)
		CopLogicAttack._set_nearest_cover(my_data, old_internal_data.nearest_cover)
	end

	local key_str = tostring(data.key)
	my_data.detection_task_key = "TeamAILogicAssault._upd_enemy_detection" .. key_str

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, TeamAILogicAssault._upd_enemy_detection, data, data.t)

	if data.objective then
		my_data.attitude = data.objective.attitude
	end

	data.unit:movement():set_cool(false)
	data.unit:movement():set_stance("hos")

	my_data.weapon_range = data.char_tweak.weapon[data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage].range
	my_data.cover_test_step = 3
end

function TeamAILogicAssault.exit(data, new_logic_name, enter_params)
	TeamAILogicBase.exit(data, new_logic_name, enter_params)

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

function TeamAILogicAssault.update(data)
	local my_data = data.internal_data
	local t = data.t
	local unit = data.unit
	local focus_enemy = data.attention_obj
	local in_cover = my_data.in_cover
	local best_cover = my_data.best_cover

	CopLogicAttack._process_pathing_results(data, my_data)

	local focus_enemy = data.attention_obj

	if not focus_enemy or focus_enemy.reaction < AIAttentionObject.REACT_AIM then
		TeamAILogicAssault._upd_enemy_detection(data, true)

		if my_data ~= data.internal_data or not data.attention_obj or data.attention_obj.reaction <= AIAttentionObject.REACT_SCARED then
			return
		end

		focus_enemy = data.attention_obj
	end

	local enemy_visible = focus_enemy.verified
	local action_taken = my_data.turning or data.unit:movement():chk_action_forbidden("walk") or my_data.moving_to_cover or my_data.walking_to_cover_shoot_pos or my_data._turning_to_intimidate
	my_data.want_to_take_cover = CopLogicAttack._chk_wants_to_take_cover(data, my_data)
	local want_to_take_cover = my_data.want_to_take_cover
	action_taken = action_taken or CopLogicAttack._upd_pose(data, my_data)
	local move_to_cover = nil

	if action_taken then
		-- Nothing
	elseif want_to_take_cover then
		move_to_cover = true
	end

	if not my_data.processing_cover_path and not my_data.cover_path and not my_data.charge_path_search_id and not action_taken and best_cover and (not in_cover or best_cover[1] ~= in_cover[1]) then
		CopLogicAttack._cancel_cover_pathing(data, my_data)

		local search_id = tostring(unit:key()) .. "cover"

		if data.unit:brain():search_for_path_to_cover(search_id, best_cover[1], best_cover[5]) then
			my_data.cover_path_search_id = search_id
			my_data.processing_cover_path = best_cover
		end
	end

	if not action_taken and move_to_cover and my_data.cover_path then
		action_taken = CopLogicAttack._chk_request_action_walk_to_cover(data, my_data)
	end

	if not data.objective and (not data.path_fail_t or data.t - data.path_fail_t > 6) then
		managers.groupai:state():on_criminal_jobless(unit)

		if my_data ~= data.internal_data then
			return
		end
	end

	if my_data.cover_chk_t < data.t then
		CopLogicAttack._update_cover(data)

		my_data.cover_chk_t = data.t + TeamAILogicAssault._COVER_CHK_INTERVAL
	end
end

function TeamAILogicAssault._upd_enemy_detection(data, is_synchronous)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local max_reaction = nil

	if data.cool then
		max_reaction = AIAttentionObject.REACT_SURPRISED
	end

	local delay = CopLogicBase._upd_attention_obj_detection(data, nil, max_reaction)
	local new_attention, new_prio_slot, new_reaction = TeamAILogicIdle._get_priority_attention(data, data.detected_attention_objects, nil)
	local old_att_obj = data.attention_obj

	TeamAILogicBase._set_attention_obj(data, new_attention, new_reaction)
	TeamAILogicAssault._chk_exit_attack_logic(data, new_reaction)

	if my_data ~= data.internal_data then
		return
	end

	if data.objective and data.objective.type == "follow" and TeamAILogicIdle._check_should_relocate(data, my_data, data.objective) and not data.unit:movement():chk_action_forbidden("walk") then
		data.objective.in_place = nil

		if new_prio_slot and new_prio_slot > 3 then
			data.objective.called = true
		end

		TeamAILogicBase._exit(data.unit, "travel")

		return
	end

	CopLogicAttack._upd_aim(data, my_data)

	if not my_data._intimidate_t or my_data._intimidate_t + 2 < data.t and not my_data._turning_to_intimidate and data.unit:character_damage():health_ratio() > 0.5 then
		local can_turn = not data.unit:movement():chk_action_forbidden("turn") and new_prio_slot > 3
		local is_assault = managers.groupai:state():get_assault_mode()
		local civ = TeamAILogicIdle.find_civilian_to_intimidate(data.unit, can_turn and 180 or 60, is_assault and 800 or 1200)

		if civ and (not is_assault or civ:anim_data().run or civ:anim_data().stand) then
			my_data._intimidate_t = data.t

			if can_turn and CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, data.unit:movement():m_pos(), civ:movement():m_pos()) then
				my_data._turning_to_intimidate = true
				my_data._primary_intimidation_target = civ
			else
				TeamAILogicIdle.intimidate_civilians(data, data.unit, true, false)
			end
		end
	end

	if (not TeamAILogicAssault._mark_special_chk_t or TeamAILogicAssault._mark_special_chk_t + 0.75 < data.t) and (not TeamAILogicAssault._mark_special_t or TeamAILogicAssault._mark_special_t + 6 < data.t) and not my_data.acting and not data.unit:sound():speaking() then
		local nmy = TeamAILogicAssault.find_enemy_to_mark(data.detected_attention_objects)
		TeamAILogicAssault._mark_special_chk_t = data.t

		if nmy then
			TeamAILogicAssault._mark_special_t = data.t

			TeamAILogicAssault.mark_enemy(data, data.unit, nmy, true, true)
		end
	end

	TeamAILogicAssault._chk_request_combat_chatter(data, my_data)

	if not is_synchronous then
		CopLogicBase.queue_task(my_data, my_data.detection_task_key, TeamAILogicAssault._upd_enemy_detection, data, data.t + delay)
	end
end

function TeamAILogicAssault.find_enemy_to_mark(enemies)
	local best_nmy, best_nmy_wgt = nil

	for key, attention_info in pairs(enemies) do
		if attention_info.identified and (attention_info.verified or attention_info.nearly_visible) and attention_info.is_person and attention_info.char_tweak and attention_info.char_tweak.priority_shout and AIAttentionObject.REACT_COMBAT <= attention_info.reaction and (not attention_info.char_tweak.priority_shout_max_dis or attention_info.dis < attention_info.char_tweak.priority_shout_max_dis) and (not best_nmy_wgt or attention_info.verified_dis < best_nmy_wgt) then
			best_nmy_wgt = attention_info.verified_dis
			best_nmy = attention_info.unit
		end
	end

	return best_nmy
end

function TeamAILogicAssault.mark_enemy(data, criminal, to_mark, play_sound, play_action)
	if play_sound then
		local callout = not criminal:brain()._last_mark_shout or tweak_data.sound.criminal_sound.ai_callout_cooldown < TimerManager:game():time() - criminal:brain()._last_mark_shout

		if callout then
			criminal:sound():say(to_mark:base():char_tweak().priority_shout .. "x_any", true)

			criminal:brain()._last_mark_shout = TimerManager:game():time()
		end
	end

	if play_action and not criminal:movement():chk_action_forbidden("action") then
		local new_action = {
			variant = "arrest",
			align_sync = true,
			body_part = 3,
			type = "act"
		}

		if criminal:brain():action_request(new_action) then
			data.internal_data.gesture_arrest = true
		end
	end

	to_mark:contour():add("mark_enemy", true)
end

function TeamAILogicAssault.action_complete_clbk(data, action)
	local my_data = data.internal_data
	local action_type = action:type()

	if action_type == "walk" then
		my_data.advancing = nil

		if my_data.surprised then
			my_data.surprised = false
		elseif my_data.moving_to_cover then
			if action:expired() then
				my_data.in_cover = my_data.moving_to_cover
				my_data.cover_enter_t = data.t
				my_data.cover_sideways_chk = nil
			end

			my_data.moving_to_cover = nil
		elseif my_data.walking_to_cover_shoot_pos then
			my_data.walking_to_cover_shoot_pos = nil
		end
	elseif action_type == "shoot" then
		my_data.shooting = nil
	elseif action_type == "turn" then
		my_data.turning = nil

		if my_data._turning_to_intimidate then
			my_data._turning_to_intimidate = nil

			TeamAILogicIdle.intimidate_civilians(data, data.unit, true, true, my_data._primary_intimidation_target)

			my_data._primary_intimidation_target = nil
		end
	elseif action_type == "hurt" then
		if action:expired() then
			CopLogicAttack._upd_aim(data, my_data)
		end
	elseif action_type == "dodge" then
		CopLogicAttack._upd_aim(data, my_data)
	end
end

function TeamAILogicAssault.damage_clbk(data, damage_info)
	TeamAILogicIdle.damage_clbk(data, damage_info)
end

function TeamAILogicAssault.death_clbk(data, damage_info)
end

function TeamAILogicAssault.on_detected_enemy_destroyed(data, enemy_unit)
	TeamAILogicIdle.on_cop_neutralized(data, enemy_unit:key())
end

function TeamAILogicAssault._chk_request_combat_chatter(data, my_data)
	local focus_enemy = data.attention_obj

	if focus_enemy and focus_enemy.verified and focus_enemy.is_person and AIAttentionObject.REACT_COMBAT <= focus_enemy.reaction and (my_data.firing or data.unit:character_damage():health_ratio() < 1) and not data.unit:movement():chk_action_forbidden("walk") and not data.unit:sound():speaking() then
		managers.groupai:state():chk_say_teamAI_combat_chatter(data.unit)
	end
end

function TeamAILogicAssault._chk_exit_attack_logic(data, new_reaction)
	local wanted_state = TeamAILogicBase._get_logic_state_from_reaction(data, new_reaction)

	if wanted_state ~= data.name then
		local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, data.objective, nil, nil)

		if allow_trans or wanted_state == "idle" then
			if obj_failed then
				data.objective_failed_clbk(data.unit, data.objective)
			else
				TeamAILogicBase._exit(data.unit, wanted_state)
			end
		end
	end
end
