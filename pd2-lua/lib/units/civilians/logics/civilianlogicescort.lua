CivilianLogicEscort = class(CivilianLogicBase)

function CivilianLogicEscort.enter(data, new_logic_name, enter_params)
	CopLogicBase.enter(data, new_logic_name, enter_params)
	data.unit:brain():cancel_all_pathing_searches()

	local old_internal_data = data.internal_data
	local my_data = {
		unit = data.unit
	}

	data.unit:brain():set_update_enabled_state(true)

	if data.char_tweak.escort_idle_talk then
		my_data._say_random_t = Application:time() + 45
	end

	CivilianLogicEscort._get_objective_path_data(data, my_data)

	data.internal_data = my_data

	data.unit:contour():add("highlight")
	data.unit:movement():set_cool(false, "escort")
	data.unit:movement():set_stance(data.is_tied and "cbt" or "hos")

	my_data.advance_path_search_id = "CivilianLogicEscort_detailed" .. tostring(data.key)
	my_data.coarse_path_search_id = "CivilianLogicEscort_coarse" .. tostring(data.key)

	if data.unit:anim_data().tied then
		local action_data = {
			clamp_to_graph = true,
			variant = "panic",
			body_part = 1,
			type = "act"
		}

		data.unit:brain():action_request(action_data)
	end

	if not data.been_outlined and data.char_tweak.outline_on_discover then
		my_data.outline_detection_task_key = "CivilianLogicIdle._upd_outline_detection" .. tostring(data.key)

		CopLogicBase.queue_task(my_data, my_data.outline_detection_task_key, CivilianLogicIdle._upd_outline_detection, data, data.t + 2)
	end

	local attention_settings = {
		"civ_enemy_cbt",
		"civ_civ_cbt"
	}

	data.unit:brain():set_attention_settings(attention_settings)
end

function CivilianLogicEscort.exit(data, new_logic_name, enter_params)
	CopLogicBase.exit(data, new_logic_name, enter_params)

	local my_data = data.internal_data

	data.unit:brain():cancel_all_pathing_searches()
	CopLogicBase.cancel_queued_tasks(my_data)
	data.unit:contour():remove("highlight")

	if new_logic_name ~= "inactive" then
		data.unit:brain():set_update_enabled_state(true)
	end
end

function CivilianLogicEscort.update(data)
	local my_data = data.internal_data
	local unit = data.unit
	local objective = data.objective
	local t = data.t

	if my_data._say_random_t and my_data._say_random_t < t then
		data.unit:sound():say("a02x_any", true)

		my_data._say_random_t = t + math.random(30, 60)
	end

	if my_data.has_old_action then
		CivilianLogicTravel._upd_stop_old_action(data, my_data)

		return
	end

	local scared_reason = CivilianLogicEscort.too_scared_to_move(data)

	if scared_reason and not data.unit:anim_data().panic then
		my_data.commanded_to_move = nil

		data.unit:movement():action_request({
			clamp_to_graph = true,
			variant = "panic",
			body_part = 1,
			type = "act"
		})
	end

	if my_data.processing_advance_path or my_data.processing_coarse_path then
		CivilianLogicEscort._upd_pathing(data, my_data)
	elseif not my_data.advancing then
		if my_data.getting_up then
			-- Nothing
		elseif my_data.advance_path then
			if my_data.commanded_to_move then
				if data.unit:anim_data().standing_hesitant then
					CivilianLogicEscort._begin_advance_action(data, my_data)
				else
					CivilianLogicEscort._begin_stand_hesitant_action(data, my_data)
				end
			end
		elseif objective then
			if my_data.coarse_path then
				local coarse_path = my_data.coarse_path
				local cur_index = my_data.coarse_path_index
				local total_nav_points = #coarse_path

				if cur_index == total_nav_points then
					objective.in_place = true

					data.objective_complete_clbk(unit, objective)

					return
				else
					local to_pos = coarse_path[cur_index + 1][2]
					my_data.processing_advance_path = true

					unit:brain():search_for_path(my_data.advance_path_search_id, to_pos)
				end
			elseif unit:brain():search_for_coarse_path(my_data.coarse_path_search_id, objective.nav_seg) then
				my_data.processing_coarse_path = true
			end
		else
			CopLogicBase._exit(data.unit, "idle")
		end
	end
end

function CivilianLogicEscort.on_intimidated(data, amount, aggressor_unit)
	local scared_reason = CivilianLogicEscort.too_scared_to_move(data)

	if scared_reason then
		data.unit:sound():say("a01x_any", true)
	else
		data.internal_data.commanded_to_move = true
	end
end

function CivilianLogicEscort.action_complete_clbk(data, action)
	local my_data = data.internal_data
	local action_type = action:type()

	if action_type == "walk" then
		my_data.advancing = nil

		if action:expired() then
			my_data.coarse_path_index = my_data.coarse_path_index + 1
		end
	elseif action_type == "act" and my_data.getting_up then
		my_data.getting_up = nil
	end
end

function CivilianLogicEscort._upd_pathing(data, my_data)
	if data.pathing_results then
		local pathing_results = data.pathing_results
		data.pathing_results = nil
		local path = pathing_results[my_data.advance_path_search_id]

		if path and my_data.processing_advance_path then
			my_data.processing_advance_path = nil

			if path ~= "failed" then
				my_data.advance_path = path
			else
				print("[CivilianLogicEscort:_upd_pathing] advance_path failed")
				managers.groupai:state():on_civilian_objective_failed(data.unit, data.objective)

				return
			end
		end

		path = pathing_results[my_data.coarse_path_search_id]

		if path and my_data.processing_coarse_path then
			my_data.processing_coarse_path = nil

			if path ~= "failed" then
				my_data.coarse_path = {
					path[1],
					path[#path]
				}
				my_data.coarse_path_index = 1
			else
				managers.groupai:state():on_civilian_objective_failed(data.unit, data.objective)

				return
			end
		end
	end
end

function CivilianLogicEscort.on_new_objective(data, old_objective)
	CivilianLogicIdle.on_new_objective(data, old_objective)
end

function CivilianLogicEscort.damage_clbk(data, damage_info)
end

function CivilianLogicEscort._get_objective_path_data(data, my_data)
	local objective = data.objective
	local path_data = objective.path_data
	local path_style = objective.path_style

	if path_data then
		if path_style == "precise" then
			local path = {
				mvector3.copy(data.m_pos)
			}

			for _, point in ipairs(path_data.points) do
				table.insert(path, point.position)
			end

			my_data.advance_path = path
			my_data.coarse_path_index = 1
			local start_seg = data.unit:movement():nav_tracker():nav_segment()
			local end_pos = mvector3.copy(path[#path])
			local end_seg = managers.navigation:get_nav_seg_from_pos(end_pos)
			my_data.coarse_path = {
				{
					start_seg
				},
				{
					end_seg,
					end_pos
				}
			}
		elseif path_style == "coarse" then
			local t_ins = table.insert
			my_data.coarse_path_index = 1
			local start_seg = data.unit:movement():nav_tracker():nav_segment()
			my_data.coarse_path = {
				{
					start_seg
				}
			}
			local coarse_path = my_data.coarse_path
			local points = path_data.points
			local i_point = 1

			while i_point <= #path_data.points do
				local next_pos = points[i_point].position
				local next_seg = managers.navigation:get_nav_seg_from_pos(next_pos)

				t_ins(coarse_path, {
					next_seg,
					mvector3.copy(next_pos)
				})

				i_point = i_point + 1
			end
		elseif path_style == "destination" then
			my_data.coarse_path_index = 1
			local start_seg = data.unit:movement():nav_tracker():nav_segment()
			local end_pos = mvector3.copy(path_data.points[#path_data.points].position)
			local end_seg = managers.navigation:get_nav_seg_from_pos(end_pos)
			my_data.coarse_path = {
				{
					start_seg
				},
				{
					end_seg,
					end_pos
				}
			}
		end
	end
end

function CivilianLogicEscort.too_scared_to_move(data)
	local my_data = data.internal_data
	local nobody_close = true
	local min_dis_sq = 1000000

	for c_key, c_data in pairs(managers.groupai:state():all_char_criminals()) do
		if mvector3.distance_sq(c_data.m_pos, data.m_pos) < min_dis_sq then
			nobody_close = nil

			break
		end
	end

	if nobody_close then
		return "abandoned"
	end

	local player_team_id = tweak_data.levels:get_default_team_ID("player")
	local nobody_close = true
	local min_dis_sq = data.char_tweak.escort_scared_dist
	min_dis_sq = min_dis_sq * min_dis_sq

	for c_key, c_data in pairs(managers.enemy:all_enemies()) do
		if not c_data.unit:anim_data().surrender and c_data.unit:brain()._current_logic_name ~= "trade" and not not c_data.unit:movement():team().foes[player_team_id] and mvector3.distance_sq(c_data.m_pos, data.m_pos) < min_dis_sq and math.abs(c_data.m_pos.z - data.m_pos.z) < 250 then
			nobody_close = nil

			break
		end
	end

	if not nobody_close then
		return "pigs"
	end
end

function CivilianLogicEscort._begin_advance_action(data, my_data)
	CopLogicAttack._correct_path_start_pos(data, my_data.advance_path)

	local objective = data.objective
	local haste = objective and objective.haste or "run"
	local new_action_data = {
		type = "walk",
		body_part = 2,
		nav_path = my_data.advance_path,
		variant = haste,
		end_rot = objective.rot
	}
	my_data.advancing = data.unit:brain():action_request(new_action_data)

	if my_data.advancing then
		data.brain:rem_pos_rsrv("path")

		my_data.advance_path = nil
	else
		debug_pause("[CivilianLogicEscort._begin_advance_action] failed to start")
	end
end

function CivilianLogicEscort._begin_stand_hesitant_action(data, my_data)
	local action = {
		clamp_to_graph = true,
		type = "act",
		body_part = 1,
		variant = "cm_so_escort_get_up_hesitant",
		blocks = {
			heavy_hurt = -1,
			hurt = -1,
			action = -1,
			walk = -1
		}
	}
	my_data.getting_up = data.unit:movement():action_request(action)
end

function CivilianLogicEscort._get_all_paths(data)
	return {
		advance_path = data.internal_data.advance_path
	}
end

function CivilianLogicEscort._set_verified_paths(data, verified_paths)
	data.internal_data.stare_path = verified_paths.stare_path
end
