require("lib/units/enemies/cop/logics/CopLogicBase")
require("lib/units/enemies/cop/logics/CopLogicTravel")
require("lib/units/enemies/cop/logics/CopLogicAttack")

TeamAILogicTravel = class(TeamAILogicBase)
TeamAILogicTravel.damage_clbk = TeamAILogicIdle.damage_clbk
TeamAILogicTravel.on_cop_neutralized = TeamAILogicIdle.on_cop_neutralized
TeamAILogicTravel.on_objective_unit_damaged = TeamAILogicIdle.on_objective_unit_damaged
TeamAILogicTravel.on_alert = TeamAILogicIdle.on_alert
TeamAILogicTravel.on_long_dis_interacted = TeamAILogicIdle.on_long_dis_interacted
TeamAILogicTravel.on_new_objective = TeamAILogicIdle.on_new_objective
TeamAILogicTravel.clbk_heat = TeamAILogicIdle.clbk_heat
TeamAILogicTravel._upd_pathing = CopLogicTravel._upd_pathing
TeamAILogicTravel._get_exact_move_pos = CopLogicTravel._get_exact_move_pos
TeamAILogicTravel._determine_destination_occupation = CopLogicTravel._determine_destination_occupation
TeamAILogicTravel.chk_should_turn = CopLogicTravel.chk_should_turn
TeamAILogicTravel._get_all_paths = CopLogicTravel._get_all_paths
TeamAILogicTravel._set_verified_paths = CopLogicTravel._set_verified_paths
TeamAILogicTravel.get_pathing_prio = CopLogicTravel.get_pathing_prio
TeamAILogicTravel.action_complete_clbk = CopLogicTravel.action_complete_clbk
TeamAILogicTravel.on_intimidated = TeamAILogicIdle.on_intimidated

function TeamAILogicTravel.enter(data, new_logic_name, enter_params)
	CopLogicBase.enter(data, new_logic_name, enter_params)
	data.unit:brain():cancel_all_pathing_searches()

	local old_internal_data = data.internal_data
	local my_data = {
		unit = data.unit,
		detection = data.char_tweak.detection.recon
	}

	if old_internal_data then
		my_data.attention_unit = old_internal_data.attention_unit

		if old_internal_data.nearest_cover then
			my_data.nearest_cover = old_internal_data.nearest_cover

			managers.navigation:reserve_cover(my_data.nearest_cover[1], data.pos_rsrv_id)
		end

		if old_internal_data.best_cover then
			my_data.best_cover = old_internal_data.best_cover

			managers.navigation:reserve_cover(my_data.best_cover[1], data.pos_rsrv_id)
		end
	end

	data.internal_data = my_data
	local key_str = tostring(data.key)

	if not data.unit:movement():cool() then
		my_data.detection_task_key = "TeamAILogicTravel._upd_enemy_detection" .. key_str

		CopLogicBase.queue_task(my_data, my_data.detection_task_key, TeamAILogicTravel._upd_enemy_detection, data, data.t)
	end

	my_data.cover_update_task_key = "TeamAILogicTravel._update_cover" .. key_str

	if my_data.nearest_cover or my_data.best_cover then
		CopLogicBase.add_delayed_clbk(my_data, my_data.cover_update_task_key, callback(CopLogicTravel, CopLogicTravel, "_update_cover", data), data.t + 1)
	end

	my_data.advance_path_search_id = "TeamAILogicTravel_detailed" .. tostring(data.key)
	my_data.coarse_path_search_id = "TeamAILogicTravel_coarse" .. tostring(data.key)
	my_data.path_ahead = data.team.id == tweak_data.levels:get_default_team_ID("player")

	if data.objective then
		data.objective.called = false
		my_data.called = true

		if data.objective.follow_unit then
			my_data.cover_wait_t = {
				0,
				0
			}
		end

		if data.objective.path_style == "warp" then
			my_data.warp_pos = data.objective.pos
		end
	end

	data.unit:movement():set_allow_fire(false)

	local w_td = alive(data.unit) and data.unit:inventory():equipped_unit() and data.unit:inventory():equipped_unit():base():weapon_tweak_data()

	if w_td then
		local cw_td = data.char_tweak.weapon[w_td.usage]
		my_data.weapon_range = (cw_td or {}).range or 5000
	end

	if not data.unit:movement():chk_action_forbidden("walk") or data.unit:anim_data().act_idle then
		local new_action = {
			body_part = 2,
			type = "idle"
		}

		data.unit:brain():action_request(new_action)
	end
end

function TeamAILogicTravel.exit(data, new_logic_name, enter_params)
	TeamAILogicBase.exit(data, new_logic_name, enter_params)

	local my_data = data.internal_data

	data.unit:brain():cancel_all_pathing_searches()
	CopLogicBase.cancel_queued_tasks(my_data)
	CopLogicBase.cancel_delayed_clbks(my_data)

	if my_data.moving_to_cover then
		managers.navigation:release_cover(my_data.moving_to_cover[1])
	end

	if my_data.nearest_cover then
		managers.navigation:release_cover(my_data.nearest_cover[1])
	end

	if my_data.best_cover then
		managers.navigation:release_cover(my_data.best_cover[1])
	end

	data.brain:rem_pos_rsrv("path")
end

function TeamAILogicTravel.check_inspire(data, attention)
	if not attention then
		return
	end

	local range_sq = 810000
	local pos = data.unit:position()
	local target = attention.unit:position()
	local dist = mvector3.distance_sq(pos, target)

	if dist < range_sq then
		data.unit:brain():set_objective()
		data.unit:sound():say("f36x_any", true, false)

		local cooldown = managers.player:crew_ability_upgrade_value("crew_inspire", 360)

		managers.player:start_custom_cooldown("team", "crew_inspire", cooldown)
		TeamAILogicTravel.actually_revive(data, attention.unit, true)

		local skip_alert = managers.groupai:state():whisper_mode()

		if not skip_alert then
			local alert_rad = 500
			local new_alert = {
				"vo_cbt",
				data.unit:movement():m_head_pos(),
				alert_rad,
				data.SO_access,
				data.unit
			}

			managers.groupai:state():propagate_alert(new_alert)
		end
	end
end

function TeamAILogicTravel.update(data)
	if data.objective.type == "revive" and managers.player:is_custom_cooldown_not_active("team", "crew_inspire") then
		local attention = data.detected_attention_objects[data.objective.follow_unit:key()]

		TeamAILogicTravel.check_inspire(data, attention)
	end

	return CopLogicTravel.upd_advance(data)
end

function TeamAILogicTravel._upd_enemy_detection(data)
	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local max_reaction = nil

	if data.cool then
		max_reaction = AIAttentionObject.REACT_SURPRISED
	end

	local delay = CopLogicBase._upd_attention_obj_detection(data, AIAttentionObject.REACT_CURIOUS, max_reaction)
	local new_attention, new_prio_slot, new_reaction = TeamAILogicIdle._get_priority_attention(data, data.detected_attention_objects, nil)

	TeamAILogicBase._set_attention_obj(data, new_attention, new_reaction)

	if new_attention then
		local objective = data.objective
		local allow_trans, obj_failed = nil
		local dont_exit = false

		if data.unit:movement():chk_action_forbidden("walk") and not data.unit:anim_data().act_idle then
			dont_exit = true
		else
			allow_trans, obj_failed = CopLogicBase.is_obstructed(data, objective, nil, new_attention)
		end

		if obj_failed and not dont_exit then
			if objective.type == "follow" then
				debug_pause_unit(data.unit, "failing follow", allow_trans, obj_failed, inspect(objective))
			end

			data.objective_failed_clbk(data.unit, data.objective)

			return
		end
	end

	CopLogicAttack._upd_aim(data, my_data)

	if not my_data._intimidate_t or my_data._intimidate_t + 2 < data.t then
		local civ = TeamAILogicIdle.intimidate_civilians(data, data.unit, true, false)

		if civ then
			my_data._intimidate_t = data.t

			if not data.attention_obj then
				CopLogicBase._set_attention_on_unit(data, civ)

				local key = "RemoveAttentionOnUnit" .. tostring(data.key)

				CopLogicBase.queue_task(my_data, key, TeamAILogicTravel._remove_enemy_attention, {
					data = data,
					target_key = civ:key()
				}, data.t + 1.5)
			end
		end
	end

	TeamAILogicAssault._chk_request_combat_chatter(data, my_data)
	TeamAILogicIdle._upd_sneak_spotting(data, my_data)
	CopLogicBase.queue_task(my_data, my_data.detection_task_key, TeamAILogicTravel._upd_enemy_detection, data, data.t + delay)
end

function TeamAILogicTravel._remove_enemy_attention(param)
	local data = param.data

	if not data.attention_obj or data.attention_obj.u_key ~= param.target_key then
		return
	end

	CopLogicBase._reset_attention(data)
end

function TeamAILogicTravel.is_available_for_assignment(data, new_objective)
	if new_objective and new_objective.forced then
		return true
	elseif data.objective and data.objective.type == "act" then
		if (not new_objective or new_objective and new_objective.type == "free") and data.objective.interrupt_dis == -1 then
			return true
		end

		return
	else
		return TeamAILogicAssault.is_available_for_assignment(data, new_objective)
	end
end
