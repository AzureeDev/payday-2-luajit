local tmp_vec1 = Vector3()
CopLogicPhalanxMinion = class(CopLogicBase)
CopLogicPhalanxMinion.on_alert = CopLogicIdle.on_alert
CopLogicPhalanxMinion.on_new_objective = CopLogicIdle.on_new_objective
CopLogicPhalanxMinion._upd_aim = CopLogicAttack._upd_aim
CopLogicPhalanxMinion.damage_clbk = CopLogicIdle.damage_clbk
CopLogicPhalanxMinion._chk_reaction_to_attention_object = CopLogicAttack._chk_reaction_to_attention_object
CopLogicPhalanxMinion.on_intimidated = CopLogicIdle.on_intimidated
CopLogicPhalanxMinion._surrender = CopLogicIdle._surrender
CopLogicPhalanxMinion.on_criminal_neutralized = CopLogicIdle.on_criminal_neutralized
CopLogicPhalanxMinion._chk_request_action_turn_to_look_pos = CopLogicIdle._chk_request_action_turn_to_look_pos
CopLogicPhalanxMinion._get_all_paths = CopLogicIdle._get_all_paths
CopLogicPhalanxMinion._set_verified_paths = CopLogicIdle._set_verified_paths
CopLogicPhalanxMinion._chk_turn_needed = CopLogicIdle._chk_turn_needed
CopLogicPhalanxMinion._turn_by_spin = CopLogicIdle._turn_by_spin
CopLogicPhalanxMinion._upd_stance_and_pose = CopLogicIdle._upd_stance_and_pose
CopLogicPhalanxMinion._perform_objective_action = CopLogicIdle._perform_objective_action
CopLogicPhalanxMinion._upd_stop_old_action = CopLogicIdle._upd_stop_old_action
CopLogicPhalanxMinion._chk_has_old_action = CopLogicIdle._chk_has_old_action
CopLogicPhalanxMinion._start_idle_action_from_act = CopLogicIdle._start_idle_action_from_act
CopLogicPhalanxMinion.allowed_transitional_actions = {
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

function CopLogicPhalanxMinion.enter(data, new_logic_name, enter_params)
	CopLogicBase.enter(data, new_logic_name, enter_params)

	local my_data = {
		unit = data.unit
	}
	local is_cool = data.unit:movement():cool()
	my_data.detection = data.char_tweak.detection.combat
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
	end

	data.internal_data = my_data
	local key_str = tostring(data.unit:key())
	my_data.detection_task_key = "CopLogicPhalanxMinion.update" .. key_str

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicPhalanxMinion.queued_update, data, data.t)

	local objective = data.objective
	objective.attitude = "engage"

	CopLogicPhalanxMinion._chk_has_old_action(data, my_data)

	if is_cool then
		data.unit:brain():set_attention_settings({
			peaceful = true
		})
	else
		data.unit:brain():set_attention_settings({
			cbt = true
		})
	end

	my_data.weapon_range = data.char_tweak.weapon[data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage].range

	CopLogicPhalanxMinion.calc_initial_phalanx_pos(data.m_pos, objective)
	data.unit:brain():set_update_enabled_state(false)
	CopLogicPhalanxMinion._perform_objective_action(data, my_data, objective)

	if my_data ~= data.internal_data then
		return
	end
end

function CopLogicPhalanxMinion.exit(data, new_logic_name, enter_params)
	CopLogicBase.exit(data, new_logic_name, enter_params)

	local my_data = data.internal_data

	data.unit:brain():cancel_all_pathing_searches()
	CopLogicBase.cancel_queued_tasks(my_data)
	CopLogicBase.cancel_delayed_clbks(my_data)
	data.brain:rem_pos_rsrv("path")
end

function CopLogicPhalanxMinion.queued_update(data)
	local my_data = data.internal_data
	local delay = data.logic._upd_enemy_detection(data)

	if data.internal_data ~= my_data then
		CopLogicBase._report_detections(data.detected_attention_objects)

		return
	end

	local objective = data.objective

	if my_data.has_old_action then
		CopLogicPhalanxMinion._upd_stop_old_action(data, my_data, objective)
		CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicPhalanxMinion.queued_update, data, data.t + delay, data.important and true)

		return
	end

	if data.team.id == "criminal1" and (not data.objective or data.objective.type == "free") and (not data.path_fail_t or data.t - data.path_fail_t > 6) then
		managers.groupai:state():on_criminal_jobless(data.unit)

		if my_data ~= data.internal_data then
			return
		end
	end

	CopLogicPhalanxMinion._perform_objective_action(data, my_data, objective)
	CopLogicPhalanxMinion._upd_stance_and_pose(data, my_data, objective)

	if data.internal_data ~= my_data then
		CopLogicBase._report_detections(data.detected_attention_objects)

		return
	end

	delay = data.important and 0 or delay or 0.3

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicPhalanxMinion.queued_update, data, data.t + delay, data.important and true)
end

function CopLogicPhalanxMinion.chk_should_turn(data, my_data)
	return not my_data.turning and not my_data.has_old_action and not data.unit:movement():chk_action_forbidden("walk") and not my_data.moving_to_cover and not my_data.walking_to_cover_shoot_pos and not my_data.surprised
end

function CopLogicPhalanxMinion.register_in_group_ai(unit)
	if not managers.groupai:state():is_unit_in_phalanx_minion_data(unit:key()) then
		managers.groupai:state():register_phalanx_minion(unit)
	end
end

function CopLogicPhalanxMinion.chk_should_breakup()
	local phalanx_minion_count = managers.groupai:state():get_phalanx_minion_count()
	local min_count_minions = tweak_data.group_ai.phalanx.minions.min_count

	if phalanx_minion_count > 0 and phalanx_minion_count <= min_count_minions then
		CopLogicPhalanxMinion.breakup()
	end
end

function CopLogicPhalanxMinion.chk_should_reposition()
	local phalanx_minion_count = managers.groupai:state():get_phalanx_minion_count()

	if phalanx_minion_count > 1 then
		CopLogicPhalanxMinion._reposition_phalanx(nil)
	end
end

function CopLogicPhalanxMinion.breakup(remote_call)
	local groupai = managers.groupai:state()
	local phalanx_minions = groupai:phalanx_minions()
	local phalanx_spawn_group = groupai:phalanx_spawn_group()

	if phalanx_spawn_group then
		local phalanx_center_pos = groupai._phalanx_center_pos
		local phalanx_center_nav_seg = managers.navigation:get_nav_seg_from_pos(phalanx_center_pos)
		local phalanx_area = groupai:get_area_from_nav_seg_id(phalanx_center_nav_seg)
		local grp_objective = {
			type = "hunt",
			area = phalanx_area,
			nav_seg = phalanx_center_nav_seg
		}

		groupai:_set_objective_to_enemy_group(phalanx_spawn_group, grp_objective)
	end

	for unit_key, unit in pairs(phalanx_minions) do
		if alive(unit) then
			local brain = unit:brain()

			if brain and brain:objective() then
				print("CopLogicPhalanxMinion.breakup current objective type: ", brain:objective().type)
				brain:set_objective(nil)
			end
		end

		groupai:unregister_phalanx_minion(unit_key)
	end

	groupai:phalanx_despawned()

	if not remote_call then
		CopLogicPhalanxVip.breakup(true)
	end
end

function CopLogicPhalanxMinion._upd_enemy_detection(data)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local delay = CopLogicBase._upd_attention_obj_detection(data, nil, nil)
	local new_attention, new_prio_slot, new_reaction = CopLogicIdle._get_priority_attention(data, data.detected_attention_objects)

	CopLogicBase._set_attention_obj(data, new_attention, new_reaction)
	data.logic._upd_aim(data, my_data)

	return delay
end

function CopLogicPhalanxMinion._upd_turn_outwards(data, my_data)
	if not CopLogicAttack.action_taken(data, my_data) then
		if data.objective.angle then
			local center_pos = managers.groupai:state()._phalanx_center_pos
			local turn_angle = CopLogicPhalanxMinion._chk_turn_needed(data, my_data, data.m_pos, 2 * data.m_pos - center_pos)

			if turn_angle then
				CopLogicPhalanxMinion._turn_by_spin(data, my_data, turn_angle)
			end
		else
			CopLogicPhalanxMinion._reposition_phalanx(nil)
		end
	end
end

function CopLogicPhalanxMinion.action_complete_clbk(data, action)
	local action_type = action:type()

	if action_type == "turn" then
		data.internal_data.turning = nil
	elseif action_type == "act" then
		local my_data = data.internal_data

		if my_data.action_started == action then
			if action:expired() then
				if not my_data.action_timeout_clbk_id then
					data.objective_complete_clbk(data.unit, data.objective)
				end
			elseif not my_data.action_expired then
				data.objective_failed_clbk(data.unit, data.objective)
			end
		end
	end
end

function CopLogicPhalanxMinion.is_available_for_assignment(data, objective)
	return false
end

function CopLogicPhalanxMinion._calc_phalanx_circle_radius(phalanx_minion_count)
	local distance = tweak_data.group_ai.phalanx.minions.distance
	local circumfence = distance * phalanx_minion_count
	local radius = circumfence / math.pi / 2

	return math.max(radius, distance)
end

function CopLogicPhalanxMinion._calc_pos_on_phalanx_circle(center_pos, angle, phalanx_minion_count)
	local radius = CopLogicPhalanxMinion._calc_phalanx_circle_radius(phalanx_minion_count)
	local result = center_pos + Vector3(radius):rotate_with(Rotation(angle))

	return result
end

function CopLogicPhalanxMinion._i_am_nth_neighbour(diffs_to_fixed_angle, my_diff, fixed_angle_free)
	if my_diff == 0 then
		return 0
	end

	local result = 0
	local negative = my_diff < 0

	for diff, unit in pairs(diffs_to_fixed_angle) do
		if negative then
			if diff <= 0 and my_diff < diff then
				result = result - 1
			end
		elseif diff >= 0 and diff < my_diff then
			result = result + 1
		end
	end

	if negative and fixed_angle_free then
		result = result - 1
	end

	return result
end

function CopLogicPhalanxMinion._get_diff_to_angle(fixed_angle, angle)
	local diff = angle - fixed_angle

	if math.abs(diff) > 180 then
		local neg = false

		if diff > 0 then
			neg = true
		end

		diff = 360 - math.abs(diff)

		if neg then
			diff = diff * -1
		end
	end

	return diff
end

function CopLogicPhalanxMinion._get_next_neighbour_angle(neighbour_num, phalanx_minion_count, fixed_angle)
	local angle_step = 360 / phalanx_minion_count
	local result = fixed_angle + neighbour_num * angle_step

	if result < 0 then
		result = result + 360
	else
		result = result % 360
	end

	return result
end

function CopLogicPhalanxMinion._get_random_angle()
	return math.random(360)
end

function CopLogicPhalanxMinion._reposition_phalanx(fixed_angle)
	local phalanx_minion_count = managers.groupai:state():get_phalanx_minion_count()
	local center_pos = managers.groupai:state()._phalanx_center_pos
	fixed_angle = fixed_angle or CopLogicPhalanxMinion._get_random_angle()
	fixed_angle = math.round(fixed_angle, 2)
	local phalanx_minions = managers.groupai:state():phalanx_minions()
	local diffs_to_fixed_angle = {}
	local fixed_angle_free = true

	for unit_key, unit in pairs(phalanx_minions) do
		if unit:brain():objective() then
			local added_phalanx = false

			if not unit:brain():objective().angle then
				added_phalanx = true
			end

			local angle = unit:brain():objective().angle or fixed_angle
			local diff = CopLogicPhalanxMinion._get_diff_to_angle(fixed_angle, angle)

			if diffs_to_fixed_angle[diff] then
				if added_phalanx then
					local temp_unit = diffs_to_fixed_angle[diff]
					local temp_diff = diff + 1
					diffs_to_fixed_angle[temp_diff] = temp_unit
				else
					diff = diff + 1
				end
			end

			if diff == 0 then
				fixed_angle_free = false
			end

			diffs_to_fixed_angle[diff] = unit
		end
	end

	for diff, unit in pairs(diffs_to_fixed_angle) do
		local neighbour_num = CopLogicPhalanxMinion._i_am_nth_neighbour(diffs_to_fixed_angle, diff, fixed_angle_free)
		local angle_to_move_to = CopLogicPhalanxMinion._get_next_neighbour_angle(neighbour_num, phalanx_minion_count, fixed_angle)

		if unit:brain() and unit:brain():objective() then
			local phalanx_objective = unit:brain():objective()
			phalanx_objective.type = "phalanx"
			phalanx_objective.angle = angle_to_move_to
			phalanx_objective.pos = CopLogicPhalanxMinion._calc_pos_on_phalanx_circle(center_pos, angle_to_move_to, phalanx_minion_count)
			phalanx_objective.in_place = nil

			unit:brain():set_objective(phalanx_objective)
		end
	end
end

function CopLogicPhalanxMinion.calc_initial_phalanx_pos(own_pos, objective)
	if not objective.angle then
		local center_pos = managers.groupai:state()._phalanx_center_pos
		local phalanx_current_minion_count = managers.groupai:state():get_phalanx_minion_count()
		local total_minion_amount = tweak_data.group_ai.phalanx.minions.amount
		local fixed_angle = own_pos:angle(center_pos)
		fixed_angle = (fixed_angle + 180) % 360
		local angle_to_move_to = CopLogicPhalanxMinion._get_next_neighbour_angle(phalanx_current_minion_count - 1, total_minion_amount, fixed_angle)
		objective.angle = angle_to_move_to
		objective.pos = CopLogicPhalanxMinion._calc_pos_on_phalanx_circle(center_pos, angle_to_move_to, total_minion_amount)
	end

	return objective.pos
end
