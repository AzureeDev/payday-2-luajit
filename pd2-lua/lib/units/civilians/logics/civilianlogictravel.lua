CivilianLogicTravel = class(CivilianLogicBase)
CivilianLogicTravel.on_alert = CivilianLogicIdle.on_alert
CivilianLogicTravel.on_new_objective = CivilianLogicIdle.on_new_objective
CivilianLogicTravel.action_complete_clbk = CopLogicTravel.action_complete_clbk
CivilianLogicTravel.is_available_for_assignment = CopLogicTravel.is_available_for_assignment

function CivilianLogicTravel.enter(data, new_logic_name, enter_params)
	CopLogicBase.enter(data, new_logic_name, enter_params)
	data.unit:brain():cancel_all_pathing_searches()

	local old_internal_data = data.internal_data
	local my_data = {
		unit = data.unit
	}
	data.internal_data = my_data
	local is_cool = data.unit:movement():cool()

	if is_cool then
		my_data.detection = data.char_tweak.detection.ntl
	else
		my_data.detection = data.char_tweak.detection.cbt
	end

	data.unit:brain():set_update_enabled_state(true)
	CivilianLogicEscort._get_objective_path_data(data, my_data)

	if data.is_tied then
		managers.groupai:state():on_hostage_state(true, data.key, nil, true)

		my_data.is_hostage = true
	end

	local key_str = tostring(data.key)

	if not data.been_outlined and data.char_tweak.outline_on_discover then
		my_data.outline_detection_task_key = "CivilianLogicIdle._upd_outline_detection" .. key_str

		CopLogicBase.queue_task(my_data, my_data.outline_detection_task_key, CivilianLogicIdle._upd_outline_detection, data, data.t + 2)
	end

	my_data.detection_task_key = "CivilianLogicTravel_upd_detection" .. key_str

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, CivilianLogicIdle._upd_detection, data, data.t + 1)

	my_data.advance_path_search_id = "CivilianLogicTravel_detailed" .. tostring(data.key)
	my_data.coarse_path_search_id = "CivilianLogicTravel_coarse" .. tostring(data.key)

	if not data.unit:movement():cool() then
		my_data.registered_as_fleeing = true

		managers.groupai:state():register_fleeing_civilian(data.key, data.unit)
	end

	if data.objective and data.objective.stance then
		data.unit:movement():set_stance(data.objective.stance)
	end

	CivilianLogicTravel._chk_has_old_action(data, my_data)

	local objective = data.objective
	local path_data = objective.path_data

	if objective.path_style == "warp" then
		my_data.warp_pos = objective.pos
	end

	local attention_settings = nil

	if is_cool then
		attention_settings = {
			"civ_all_peaceful"
		}
	else
		attention_settings = {
			"civ_enemy_cbt",
			"civ_civ_cbt",
			"civ_murderer_cbt"
		}
	end

	data.unit:brain():set_attention_settings(attention_settings)

	my_data.state_enter_t = TimerManager:game():time()
end

function CivilianLogicTravel.exit(data, new_logic_name, enter_params)
	CopLogicBase.exit(data, new_logic_name, enter_params)

	local my_data = data.internal_data

	data.unit:brain():cancel_all_pathing_searches()
	CopLogicBase.cancel_delayed_clbks(my_data)
	CopLogicBase.cancel_queued_tasks(my_data)

	if my_data.registered_as_fleeing then
		managers.groupai:state():unregister_fleeing_civilian(data.key)
	end

	if my_data.enemy_weapons_hot_listen_id then
		managers.groupai:state():remove_listener(my_data.enemy_weapons_hot_listen_id)
	end

	if my_data.is_hostage then
		managers.groupai:state():on_hostage_state(false, data.key, nil, true)

		my_data.is_hostage = nil
	end

	if new_logic_name ~= "inactive" then
		data.unit:brain():set_update_enabled_state(true)
	end
end

local tmp_vec1 = Vector3()

function CivilianLogicTravel._optimize_path(path)
	if #path <= 2 then
		return path
	end

	local function remove_duplicates(path)
		for i = #path, 2, -1 do
			if path[i] == path[i - 1] then
				table.remove(path, i - 1)
			end
		end
	end

	remove_duplicates(path)

	local opt_path = {
		path[1]
	}
	local i = 1
	local count = 1

	while i < #path do
		local pos = path[i]
		local next_index = i + 1

		for j = i + 1, #path do
			if not managers.navigation:raycast({
				pos_from = pos,
				pos_to = path[j]
			}) then
				next_index = j
			end
		end

		opt_path[count + 1] = path[next_index]
		count = count + 1
		i = next_index
	end

	remove_duplicates(opt_path)

	return opt_path
end

function CivilianLogicTravel.update(data)
	local my_data = data.internal_data
	local unit = data.unit
	local objective = data.objective
	local t = data.t

	if my_data.has_old_action then
		CivilianLogicTravel._upd_stop_old_action(data, my_data)
	elseif my_data.warp_pos then
		local action_desc = {
			body_part = 1,
			type = "warp",
			position = mvector3.copy(objective.pos),
			rotation = objective.rot
		}

		if unit:movement():action_request(action_desc) then
			CivilianLogicTravel._on_destination_reached(data)
		end
	elseif my_data.processing_advance_path or my_data.processing_coarse_path then
		CivilianLogicEscort._upd_pathing(data, my_data)
	elseif my_data.advancing then
		-- Nothing
	elseif my_data.advance_path then
		CopLogicAttack._correct_path_start_pos(data, my_data.advance_path)

		if my_data.is_hostage then
			my_data.advance_path = CivilianLogicTravel._optimize_path(my_data.advance_path)
		end

		local end_rot = nil

		if my_data.coarse_path_index == #my_data.coarse_path - 1 then
			end_rot = objective and objective.rot
		end

		local haste = objective and objective.haste or "walk"
		local new_action_data = {
			type = "walk",
			body_part = 2,
			nav_path = my_data.advance_path,
			variant = haste,
			end_rot = end_rot
		}
		my_data.starting_advance_action = true
		my_data.advancing = data.unit:brain():action_request(new_action_data)
		my_data.starting_advance_action = false

		if my_data.advancing then
			my_data.advance_path = nil

			data.brain:rem_pos_rsrv("path")
		end
	elseif objective then
		if my_data.coarse_path then
			local coarse_path = my_data.coarse_path
			local cur_index = my_data.coarse_path_index
			local total_nav_points = #coarse_path

			if cur_index >= total_nav_points then
				objective.in_place = true

				if objective.type ~= "escort" and objective.type ~= "act" and objective.type ~= "follow" and not objective.action_duration then
					data.objective_complete_clbk(unit, objective)
				else
					CivilianLogicTravel.on_new_objective(data)
				end

				return
			else
				data.brain:rem_pos_rsrv("path")

				local to_pos = nil

				if cur_index == total_nav_points - 1 then
					to_pos = CivilianLogicTravel._determine_exact_destination(data, objective)
				else
					to_pos = coarse_path[cur_index + 1][2]
				end

				my_data.processing_advance_path = true

				unit:brain():search_for_path(my_data.advance_path_search_id, to_pos)
			end
		else
			local nav_seg = nil

			if objective.follow_unit then
				nav_seg = objective.follow_unit:movement():nav_tracker():nav_segment()
			else
				nav_seg = objective.nav_seg
			end

			if unit:brain():search_for_coarse_path(my_data.coarse_path_search_id, nav_seg) then
				my_data.processing_coarse_path = true
			end
		end
	else
		CopLogicBase._exit(data.unit, "idle")
	end
end

function CivilianLogicTravel._on_destination_reached(data)
	local objective = data.objective
	objective.in_place = true

	if objective.type == "free" then
		if not objective.action_duration then
			data.objective_complete_clbk(data.unit, objective)

			return
		end
	elseif objective.type == "flee" then
		data.unit:brain():set_active(false)
		data.unit:base():set_slot(data.unit, 0)

		return
	elseif objective.type == "defend_area" then
		if objective.grp_objective and objective.grp_objective.type == "retire" then
			data.unit:brain():set_active(false)
			data.unit:base():set_slot(data.unit, 0)

			return
		else
			managers.groupai:state():on_defend_travel_end(data.unit, objective)
		end
	end

	data.logic.on_new_objective(data)
end

function CivilianLogicTravel.on_intimidated(data, amount, aggressor_unit)
	if not CivilianLogicIdle.is_obstructed(data, aggressor_unit) then
		return
	end

	local new_objective = {
		type = "surrender",
		amount = amount,
		aggressor_unit = aggressor_unit
	}
	local anim_data = data.unit:anim_data()

	if anim_data.run then
		new_objective.initial_act = "halt"
	end

	data.unit:sound():say("a02x_any", true)
	data.unit:brain():set_objective(new_objective)
end

function CivilianLogicTravel._determine_exact_destination(data, objective)
	if objective.pos then
		return objective.pos
	elseif objective.type == "follow" then
		local follow_pos, follow_nav_seg = nil
		local follow_unit_objective = objective.follow_unit:brain() and objective.follow_unit:brain():objective()
		follow_pos = objective.follow_unit:movement():nav_tracker():field_position()
		follow_nav_seg = objective.follow_unit:movement():nav_tracker():nav_segment()
		local distance = objective.distance and math.lerp(objective.distance * 0.5, objective.distance * 0.9, math.random()) or 700
		local to_pos = CopLogicTravel._get_pos_on_wall(follow_pos, distance)

		return to_pos
	else
		return CopLogicTravel._get_pos_on_wall(managers.navigation._nav_segments[objective.nav_seg].pos, 700)
	end
end

function CivilianLogicTravel._chk_has_old_action(data, my_data)
	local anim_data = data.unit:anim_data()
	my_data.has_old_action = anim_data.to_idle or anim_data.act and anim_data.needs_idle
end

function CivilianLogicTravel._upd_stop_old_action(data, my_data, objective)
	if not data.unit:anim_data().to_idle then
		if not data.unit:movement():chk_action_forbidden("idle") and data.unit:anim_data().act and data.unit:anim_data().needs_idle then
			CopLogicIdle._start_idle_action_from_act(data)
		end

		CivilianLogicTravel._chk_has_old_action(data, my_data)
	end
end

function CivilianLogicTravel.is_available_for_assignment(data, objective)
	if objective and objective.forced then
		return true
	end

	return not data.is_tied
end
