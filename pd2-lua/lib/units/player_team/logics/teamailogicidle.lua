require("lib/units/enemies/cop/logics/CopLogicIdle")
require("lib/units/enemies/cop/logics/CopLogicTravel")

local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local tmp_vec3 = Vector3()
TeamAILogicIdle = TeamAILogicIdle or class(TeamAILogicBase)

function TeamAILogicIdle.enter(data, new_logic_name, enter_params)
	TeamAILogicBase.enter(data, new_logic_name, enter_params)

	local my_data = {
		unit = data.unit,
		detection = data.char_tweak.detection.idle,
		enemy_detect_slotmask = managers.slot:get_mask("enemies")
	}
	local old_internal_data = data.internal_data

	if old_internal_data then
		if old_internal_data.best_cover then
			my_data.best_cover = old_internal_data.best_cover

			managers.navigation:reserve_cover(my_data.best_cover[1], data.pos_rsrv_id)
		end

		if old_internal_data.nearest_cover then
			my_data.nearest_cover = old_internal_data.nearest_cover

			managers.navigation:reserve_cover(my_data.nearest_cover[1], data.pos_rsrv_id)
		end

		my_data.attention_unit = old_internal_data.attention_unit
	end

	data.internal_data = my_data
	local key_str = tostring(data.key)
	my_data.detection_task_key = "TeamAILogicIdle._upd_enemy_detection" .. key_str

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, TeamAILogicIdle._upd_enemy_detection, data, data.t)

	if my_data.nearest_cover or my_data.best_cover then
		my_data.cover_update_task_key = "CopLogicIdle._update_cover" .. key_str

		CopLogicBase.add_delayed_clbk(my_data, my_data.cover_update_task_key, callback(CopLogicTravel, CopLogicTravel, "_update_cover", data), data.t + 1)
	end

	my_data.stare_path_search_id = "stare" .. key_str
	my_data.relocate_chk_t = 0

	CopLogicBase._reset_attention(data)

	if data.unit:movement():stance_name() == "cbt" then
		data.unit:movement():set_stance("hos")
	end

	data.unit:movement():set_allow_fire(false)

	local objective = data.objective
	local entry_action = enter_params and enter_params.action

	if objective then
		if objective.type == "revive" then
			if objective.action_start_clbk then
				objective.action_start_clbk(data.unit)
			end

			local success = nil
			local revive_unit = objective.follow_unit

			if revive_unit:interaction() then
				if revive_unit:interaction():active() and data.unit:brain():action_request(objective.action) then
					revive_unit:interaction():interact_start(data.unit)

					success = true
				end
			elseif revive_unit:character_damage():arrested() then
				if data.unit:brain():action_request(objective.action) then
					revive_unit:character_damage():pause_arrested_timer()

					success = true
				end
			elseif revive_unit:character_damage():need_revive() and data.unit:brain():action_request(objective.action) then
				revive_unit:character_damage():pause_downed_timer()

				success = true
			end

			if success then
				my_data.performing_act_objective = objective
				my_data.reviving = revive_unit
				my_data.acting = true
				my_data.revive_complete_clbk_id = "TeamAILogicIdle_revive" .. tostring(data.key)
				local revive_t = TimerManager:game():time() + (objective.action_duration or 0)

				CopLogicBase.add_delayed_clbk(my_data, my_data.revive_complete_clbk_id, callback(TeamAILogicIdle, TeamAILogicIdle, "clbk_revive_complete", data), revive_t)

				if not revive_unit:character_damage():arrested() then
					local suffix = "a"
					local downed_time = revive_unit:character_damage():down_time()

					if downed_time <= tweak_data.player.damage.DOWNED_TIME_MIN then
						suffix = "c"
					elseif downed_time <= tweak_data.player.damage.DOWNED_TIME / 2 + tweak_data.player.damage.DOWNED_TIME_DEC then
						suffix = "b"
					end

					data.unit:sound():say("s09" .. suffix, true)
				end
			else
				data.unit:brain():set_objective()

				return
			end
		elseif objective.type == "throw_bag" then
			data.unit:movement():throw_bag(objective.unit)

			data._ignore_first_travel_order = true

			data.unit:brain():set_objective()
		else
			if objective.action_duration then
				my_data.action_timeout_clbk_id = "TeamAILogicIdle_action_timeout" .. key_str
				local action_timeout_t = data.t + objective.action_duration

				CopLogicBase.add_delayed_clbk(my_data, my_data.action_timeout_clbk_id, callback(CopLogicIdle, CopLogicIdle, "clbk_action_timeout", data), action_timeout_t)
			end

			if objective.type == "act" then
				if data.unit:brain():action_request(objective.action) then
					my_data.acting = true
				end

				my_data.performing_act_objective = objective

				if objective.action_start_clbk then
					objective.action_start_clbk(data.unit)
				end
			end
		end

		if objective.scan then
			my_data.scan = true

			if not my_data.acting then
				my_data.wall_stare_task_key = "CopLogicIdle._chk_stare_into_wall" .. tostring(data.key)

				CopLogicBase.queue_task(my_data, my_data.wall_stare_task_key, CopLogicIdle._chk_stare_into_wall_1, data, data.t)
			end
		end
	end
end

function TeamAILogicIdle.exit(data, new_logic_name, enter_params)
	TeamAILogicBase.exit(data, new_logic_name, enter_params)

	local my_data = data.internal_data

	if my_data.delayed_clbks and my_data.delayed_clbks[my_data.revive_complete_clbk_id] then
		local revive_unit = my_data.reviving

		if alive(revive_unit) then
			if revive_unit:interaction() then
				revive_unit:interaction():interact_interupt(data.unit)
			elseif revive_unit:character_damage():arrested() then
				revive_unit:character_damage():unpause_arrested_timer()
			elseif revive_unit:character_damage():need_revive() then
				revive_unit:character_damage():unpause_downed_timer()
			end
		end

		my_data.performing_act_objective = nil
		local crouch_action = {
			variant = "crouch",
			body_part = 1,
			type = "act",
			blocks = {
				heavy_hurt = -1,
				hurt = -1,
				action = -1,
				aim = -1,
				walk = -1
			}
		}

		data.unit:movement():action_request(crouch_action)
	end

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

function TeamAILogicIdle.update(data)
	local my_data = data.internal_data

	CopLogicIdle._upd_pathing(data, my_data)
	CopLogicIdle._upd_scan(data, my_data)

	local objective = data.objective

	if objective then
		if not my_data.acting then
			if objective.type == "follow" then
				if TeamAILogicIdle._check_should_relocate(data, my_data, objective) and not data.unit:movement():chk_action_forbidden("walk") then
					objective.in_place = nil

					TeamAILogicBase._exit(data.unit, "travel")
				end
			elseif objective.type == "revive" then
				objective.in_place = nil

				TeamAILogicBase._exit(data.unit, "travel")
			end
		end
	elseif not data.path_fail_t or data.t - data.path_fail_t > 6 then
		managers.groupai:state():on_criminal_jobless(data.unit)
	end
end

function TeamAILogicIdle.on_detected_enemy_destroyed(data, enemy_unit)
end

function TeamAILogicIdle.on_cop_neutralized(data, cop_key)
end

function TeamAILogicIdle.damage_clbk(data, damage_info)
	local attacker_unit = damage_info.attacker_unit

	if attacker_unit and attacker_unit:in_slot(data.enemy_slotmask) then
		local my_data = data.internal_data
		local attacker_key = attacker_unit:key()
		local enemy_data = data.detected_attention_objects[attacker_key]
		local t = TimerManager:game():time()

		if enemy_data then
			enemy_data.verified_t = t
			enemy_data.verified = true

			mvector3.set(enemy_data.verified_pos, attacker_unit:movement():m_stand_pos())

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
			end
		else
			local attention_info = managers.groupai:state():get_AI_attention_objects_by_filter(data.SO_access_str)[attacker_key]

			if attention_info then
				local settings = attention_info.handler:get_attention(data.SO_access, nil, nil, data.team)

				if settings then
					enemy_data = CopLogicBase._create_detected_attention_object_data(data.t, data.unit, attacker_key, attention_info, settings)
					enemy_data.verified_t = t
					enemy_data.verified = true
					enemy_data.dmg_t = t
					enemy_data.alert_t = t
					enemy_data.notice_progress = nil
					enemy_data.prev_notice_chk_t = nil
					enemy_data.identified = true
					enemy_data.identified_t = t

					if enemy_data.settings.notice_clbk then
						enemy_data.settings.notice_clbk(data.unit, true)
					end

					data.detected_attention_objects[attacker_key] = enemy_data
				end
			end
		end
	end

	if (damage_info.result.type == "bleedout" or damage_info.result.type == "fatal" or damage_info.variant == "tase") and data.name ~= "disabled" then
		CopLogicBase._exit(data.unit, "disabled")
	end
end

function TeamAILogicIdle.on_objective_unit_damaged(data, unit, attacker_unit)
	if attacker_unit ~= nil then
		TeamAILogicIdle.on_alert(data, {
			"aggression",
			attacker_unit:movement():m_pos(),
			[5] = attacker_unit
		})
	end
end

function TeamAILogicIdle.on_alert(data, alert_data)
	local alert_type = alert_data[1]
	local alert_unit = alert_data[5]

	if alive(alert_unit) and alert_unit:in_slot(data.enemy_slotmask) then
		local att_obj_data, is_new = CopLogicBase.identify_attention_obj_instant(data, alert_unit:key())

		if att_obj_data and (alert_type == "bullet" or alert_type == "aggression" or alert_type == "explosion") then
			att_obj_data.alert_t = TimerManager:game():time()
		end
	end
end

function TeamAILogicIdle.on_long_dis_interacted(data, other_unit, secondary)
	if data.objective and data.objective.type == "revive" then
		return
	end

	local objective_type, objective_action, interrupt = nil

	if other_unit:base().is_local_player then
		if not secondary then
			if other_unit:character_damage():need_revive() then
				objective_type = "revive"
				objective_action = "revive"
			elseif other_unit:character_damage():arrested() then
				objective_type = "revive"
				objective_action = "untie"
			else
				objective_type = "follow"
			end
		else
			objective_type = "stop"
		end
	elseif not secondary then
		if other_unit:movement():need_revive() then
			objective_type = "revive"

			if other_unit:movement():current_state_name() == "arrested" then
				objective_action = "untie"
			else
				objective_action = "revive"
			end
		else
			objective_type = "follow"
		end
	else
		objective_type = "stop"
	end

	local objective = nil
	local should_stay = false

	if objective_type == "follow" then
		if data.unit:movement():carrying_bag() and not data.unit:movement()._should_stay then
			local throw_distance = tweak_data.ai_carry.throw_distance * data.unit:movement():carry_tweak().throw_distance_multiplier
			local dist = data.unit:position() - other_unit:position()
			local throw_bag = mvector3.dot(dist, dist) < throw_distance * throw_distance

			if throw_bag then
				if other_unit == managers.player:player_unit() then
					if other_unit:movement():current_state_name() == "carry" then
						throw_bag = false
					end
				elseif other_unit:movement():carry_id() ~= nil then
					throw_bag = false
				end
			end

			if throw_bag then
				objective = {
					type = "throw_bag",
					unit = other_unit
				}
			end
		end

		if not objective then
			objective = {
				scan = true,
				destroy_clbk_key = false,
				called = true,
				type = objective_type,
				follow_unit = other_unit
			}

			data.unit:sound():say("r01x_sin", true)
		end
	elseif objective_type == "stop" then
		objective = {
			scan = true,
			destroy_clbk_key = false,
			type = "follow",
			called = true,
			follow_unit = other_unit
		}
		should_stay = true
	else
		local followup_objective = {
			scan = true,
			type = "act",
			action = {
				variant = "crouch",
				body_part = 1,
				type = "act",
				blocks = {
					heavy_hurt = -1,
					hurt = -1,
					action = -1,
					aim = -1,
					walk = -1
				}
			}
		}
		objective = {
			type = "revive",
			called = true,
			scan = true,
			destroy_clbk_key = false,
			follow_unit = other_unit,
			nav_seg = other_unit:movement():nav_tracker():nav_segment(),
			action = {
				align_sync = true,
				type = "act",
				body_part = 1,
				variant = objective_action,
				blocks = {
					light_hurt = -1,
					hurt = -1,
					action = -1,
					heavy_hurt = -1,
					aim = -1,
					walk = -1
				}
			},
			action_duration = tweak_data.interaction[objective_action == "untie" and "free" or objective_action].timer,
			followup_objective = followup_objective
		}

		data.unit:sound():say("r02a_sin", true)
	end

	if data.unit:movement():carrying_bag() and objective.type == "revive" then
		data.unit:movement():throw_bag()
	end

	data.unit:movement():set_should_stay(should_stay)

	if objective then
		data.unit:brain():set_objective(objective)
	end
end

function TeamAILogicIdle.on_new_objective(data, old_objective)
	local new_objective = data.objective

	TeamAILogicBase.on_new_objective(data, old_objective)

	local my_data = data.internal_data

	if not my_data.exiting then
		if new_objective then
			if (new_objective.nav_seg or new_objective.follow_unit) and not new_objective.in_place then
				if data._ignore_first_travel_order then
					data._ignore_first_travel_order = nil
				else
					CopLogicBase._exit(data.unit, "travel")
				end
			else
				CopLogicBase._exit(data.unit, "idle")
			end
		else
			CopLogicBase._exit(data.unit, "idle")
		end
	else
		debug_pause("[TeamAILogicIdle.on_new_objective] Already exiting", data.name, data.unit, old_objective and inspect(old_objective), new_objective and inspect(new_objective))
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

function TeamAILogicIdle._upd_enemy_detection(data)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local max_reaction = nil

	if data.cool then
		max_reaction = AIAttentionObject.REACT_SURPRISED
	end

	local delay = CopLogicBase._upd_attention_obj_detection(data, nil, max_reaction)
	local new_attention, new_prio_slot, new_reaction = TeamAILogicIdle._get_priority_attention(data, data.detected_attention_objects, nil)

	if (not my_data._intimidate_t or my_data._intimidate_t + 2 < data.t) and not data.cool and not my_data._turning_to_intimidate and not my_data.acting and (not new_attention or AIAttentionObject.REACT_SCARED > new_reaction) then
		local can_turn = not data.unit:movement():chk_action_forbidden("turn")
		local civ = TeamAILogicIdle.find_civilian_to_intimidate(data.unit, can_turn and 180 or 90, 1200)

		if civ then
			my_data._intimidate_t = data.t
			new_attention, new_prio_slot, new_reaction = nil

			if can_turn and CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, data.m_pos, civ:movement():m_pos()) then
				my_data._turning_to_intimidate = true
				my_data._primary_intimidation_target = civ
			else
				TeamAILogicIdle.intimidate_civilians(data, data.unit, true, true)
			end
		end
	end

	TeamAILogicBase._set_attention_obj(data, new_attention, new_reaction)

	if new_reaction and AIAttentionObject.REACT_SCARED <= new_reaction then
		local objective = data.objective
		local wanted_state = nil
		local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, objective, nil, new_attention)

		if allow_trans then
			wanted_state = TeamAILogicBase._get_logic_state_from_reaction(data, new_reaction)
			local objective = data.objective

			if objective and objective.type == "revive" then
				local revive_unit = objective.follow_unit
				local timer = nil

				if revive_unit:base().is_local_player then
					timer = revive_unit:character_damage()._downed_timer
				elseif revive_unit:interaction().get_waypoint_time then
					timer = revive_unit:interaction():get_waypoint_time()
				end

				if timer and timer <= 10 then
					wanted_state = nil
				end
			end
		end

		if wanted_state and wanted_state ~= data.name then
			if obj_failed then
				data.objective_failed_clbk(data.unit, data.objective)
			end

			if my_data == data.internal_data then
				CopLogicBase._exit(data.unit, wanted_state)
			end

			return
		end
	end

	data.logic._upd_sneak_spotting(data, my_data)
	CopLogicBase.queue_task(my_data, my_data.detection_task_key, TeamAILogicIdle._upd_enemy_detection, data, data.t + delay)
end

function TeamAILogicIdle.find_civilian_to_intimidate(criminal, max_angle, max_dis)
	local best_civ = TeamAILogicIdle._find_intimidateable_civilians(criminal, false, max_angle, max_dis)

	return best_civ
end

function TeamAILogicIdle._find_intimidateable_civilians(criminal, use_default_shout_shape, max_angle, max_dis)
	local head_pos = criminal:movement():m_head_pos()
	local look_vec = criminal:movement():m_rot():y()
	local close_dis = 400
	local intimidateable_civilians = {}
	local best_civ = nil
	local best_civ_wgt = false
	local best_civ_angle = nil
	local highest_wgt = 1
	local my_tracker = criminal:movement():nav_tracker()
	local chk_vis_func = my_tracker.check_visibility

	for key, unit in pairs(managers.groupai:state():fleeing_civilians()) do
		if chk_vis_func(my_tracker, unit:movement():nav_tracker()) and tweak_data.character[unit:base()._tweak_table].intimidateable and not unit:base().unintimidateable and not unit:anim_data().unintimidateable and not unit:brain():is_tied() and not unit:unit_data().disable_shout then
			local u_head_pos = unit:movement():m_head_pos() + math.UP * 30
			local vec = u_head_pos - head_pos
			local dis = mvector3.normalize(vec)
			local angle = vec:angle(look_vec)

			if use_default_shout_shape then
				max_angle = math.max(8, math.lerp(90, 30, dis / 1200))
				max_dis = 1200
			end

			if dis < close_dis or dis < max_dis and angle < max_angle then
				local slotmask = managers.slot:get_mask("AI_visibility")
				local ray = World:raycast("ray", head_pos, u_head_pos, "slot_mask", slotmask, "ray_type", "ai_vision")

				if not ray then
					local inv_wgt = dis * dis * (1 - vec:dot(look_vec))

					table.insert(intimidateable_civilians, {
						unit = unit,
						key = key,
						inv_wgt = inv_wgt
					})

					if not best_civ_wgt or inv_wgt < best_civ_wgt then
						best_civ_wgt = inv_wgt
						best_civ = unit
						best_civ_angle = angle
					end

					if highest_wgt < inv_wgt then
						highest_wgt = inv_wgt
					end
				end
			end
		end
	end

	return best_civ, highest_wgt, intimidateable_civilians
end

function TeamAILogicIdle.intimidate_civilians(data, criminal, play_sound, play_action, primary_target)
	if alive(primary_target) and primary_target:unit_data().disable_shout then
		return false
	end

	if primary_target and (not alive(primary_target) or not managers.groupai:state():fleeing_civilians()[primary_target:key()]) then
		primary_target = nil
	end

	local best_civ, highest_wgt, intimidateable_civilians = TeamAILogicIdle._find_intimidateable_civilians(criminal, true)
	local plural = false

	if #intimidateable_civilians > 1 then
		plural = true
	elseif #intimidateable_civilians <= 0 then
		return false
	end

	local act_name, sound_name = nil
	local sound_suffix = plural and "plu" or "sin"

	if best_civ:anim_data().move then
		act_name = "gesture_stop"
		sound_name = "f02x_" .. sound_suffix
	else
		act_name = "arrest"
		sound_name = "f02x_" .. sound_suffix
	end

	if play_sound then
		criminal:sound():say(sound_name, true)
	end

	if play_action and not criminal:movement():chk_action_forbidden("action") then
		local new_action = {
			align_sync = true,
			body_part = 3,
			type = "act",
			variant = act_name
		}

		if criminal:brain():action_request(new_action) then
			data.internal_data.gesture_arrest = true
		end
	end

	local intimidated_primary_target = false

	for _, civ in ipairs(intimidateable_civilians) do
		local amount = civ.inv_wgt / highest_wgt

		if best_civ == civ.unit then
			amount = 1
		end

		if primary_target == civ.unit then
			intimidated_primary_target = true
			amount = 1
		end

		civ.unit:brain():on_intimidated(amount, criminal)
	end

	if not intimidated_primary_target and primary_target then
		primary_target:brain():on_intimidated(1, criminal)
	end

	if not managers.groupai:state():enemy_weapons_hot() then
		local alert = {
			"vo_intimidate",
			data.m_pos,
			800,
			data.SO_access,
			data.unit
		}

		managers.groupai:state():propagate_alert(alert)
	end

	if not primary_target and best_civ and best_civ:unit_data().disable_shout then
		return false
	end

	return primary_target or best_civ
end

function TeamAILogicIdle.action_complete_clbk(data, action)
	local my_data = data.internal_data
	local action_type = action:type()

	if action_type == "turn" then
		data.internal_data.turning = nil

		if my_data._turning_to_intimidate then
			my_data._turning_to_intimidate = nil

			TeamAILogicIdle.intimidate_civilians(data, data.unit, true, true, my_data._primary_intimidation_target)

			my_data._primary_intimidation_target = nil
		end
	elseif action_type == "act" then
		my_data.acting = nil

		if my_data.scan and not my_data.exiting and (not my_data.queued_tasks or not my_data.queued_tasks[my_data.wall_stare_task_key]) and not my_data.stare_path_pos then
			my_data.wall_stare_task_key = "CopLogicIdle._chk_stare_into_wall" .. tostring(data.key)

			CopLogicBase.queue_task(my_data, my_data.wall_stare_task_key, CopLogicIdle._chk_stare_into_wall_1, data, data.t)
		end

		if my_data.performing_act_objective then
			local old_objective = my_data.performing_act_objective
			my_data.performing_act_objective = nil

			if my_data.delayed_clbks and my_data.delayed_clbks[my_data.revive_complete_clbk_id] then
				CopLogicBase.cancel_delayed_clbk(my_data, my_data.revive_complete_clbk_id)

				my_data.revive_complete_clbk_id = nil
				local revive_unit = my_data.reviving

				if revive_unit:interaction() then
					if revive_unit:interaction():active() then
						revive_unit:interaction():interact_interupt(data.unit)
					end
				elseif revive_unit:character_damage():arrested() then
					revive_unit:character_damage():unpause_arrested_timer()
				elseif revive_unit:character_damage():need_revive() then
					revive_unit:character_damage():unpause_downed_timer()
				end

				my_data.reviving = nil

				data.objective_failed_clbk(data.unit, data.objective)
			elseif action:expired() then
				if not my_data.action_timeout_clbk_id then
					data.objective_complete_clbk(data.unit, old_objective)
				end
			else
				data.objective_failed_clbk(data.unit, old_objective)
			end
		end
	end
end

function TeamAILogicIdle.is_available_for_assignment(data, new_objective)
	if data.internal_data.exiting then
		return
	elseif data.path_fail_t and data.t < data.path_fail_t + 6 then
		return
	elseif data.objective then
		if data.internal_data.performing_act_objective and not data.unit:anim_data().act_idle then
			return
		end

		if new_objective and CopLogicBase.is_obstructed(data, new_objective, 0.2) then
			return
		end

		local old_objective_type = data.objective.type

		if not new_objective then
			-- Nothing
		elseif old_objective_type == "revive" then
			return
		elseif old_objective_type == "follow" and data.objective.called then
			return
		end
	end

	return true
end

function TeamAILogicIdle.clbk_heat(data)
	local inventory = data.unit:inventory()

	if inventory:is_selection_available(2) and inventory:equipped_selection() ~= 2 then
		inventory:equip_selection(2)
	end
end

function TeamAILogicIdle.clbk_revive_complete(ignore_this, data)
	local my_data = data.internal_data

	CopLogicBase.on_delayed_clbk(my_data, my_data.revive_complete_clbk_id)

	my_data.revive_complete_clbk_id = nil
	local revive_unit = my_data.reviving
	my_data.reviving = nil

	if alive(revive_unit) then
		data.objective_complete_clbk(data.unit, my_data.performing_act_objective)
		TeamAILogicIdle.actually_revive(data, revive_unit)
	else
		print("[TeamAILogicIdle.clbk_revive_complete] Revive unit dead.", revive_unit, data.unit)
		data.objective_failed_clbk(data.unit, data.performing_act_objective)
	end
end

function TeamAILogicIdle.clbk_action_timeout(ignore_this, data)
	local my_data = data.internal_data

	CopLogicBase.on_delayed_clbk(my_data, my_data.action_timeout_clbk_id)

	my_data.action_timeout_clbk_id = nil
	local old_objective = data.objective

	if my_data.performing_act_objective then
		my_data.performing_act_objective = nil
		my_data.acting = nil
	end

	if not old_objective then
		debug_pause_unit(data.unit, "[TeamAILogicIdle.clbk_action_timeout] missing objective")

		return
	end

	data.objective_complete_clbk(data.unit, old_objective)
end

function TeamAILogicIdle._check_should_relocate(data, my_data, objective)
	local follow_unit = objective.follow_unit
	local my_nav_seg_id = data.unit:movement():nav_tracker():nav_segment()
	local my_areas = managers.groupai:state():get_areas_from_nav_seg_id(my_nav_seg_id)
	local follow_unit_nav_seg_id = follow_unit:movement():nav_tracker():nav_segment()

	for _, area in ipairs(my_areas) do
		if area.nav_segs[follow_unit_nav_seg_id] then
			return
		end
	end

	local is_my_area_dangerous, is_follow_unit_area_dangerous = nil

	for _, area in ipairs(my_areas) do
		if area.nav_segs[follow_unit_nav_seg_id] then
			is_my_area_dangerous = true

			break
		end
	end

	local follow_unit_areas = managers.groupai:state():get_areas_from_nav_seg_id(follow_unit_nav_seg_id)

	for _, area in ipairs(follow_unit_areas) do
		if next(area.police.units) then
			is_follow_unit_area_dangerous = true

			break
		end
	end

	if is_my_area_dangerous and not is_follow_unit_area_dangerous then
		return true
	end

	local max_allowed_dis_xy = 500
	local max_allowed_dis_z = 250

	mvector3.set(tmp_vec1, follow_unit:movement():m_pos())
	mvector3.subtract(tmp_vec1, data.m_pos)

	local too_far = nil

	if max_allowed_dis_z < math.abs(mvector3.z(tmp_vec1)) then
		too_far = true
	else
		mvector3.set_z(tmp_vec1, 0)

		if max_allowed_dis_xy < mvector3.length(tmp_vec1) then
			too_far = true
		end
	end

	if too_far then
		return true
	end
end

function TeamAILogicIdle._ignore_shield(unit, attention)
	if managers.player:has_category_upgrade("team", "crew_ai_ap_ammo") then
		return false
	end

	if not TeamAILogicIdle._shield_check then
		TeamAILogicIdle._shield_check = managers.slot:get_mask("enemy_shield_check")
	end

	local head_pos = unit:movement():m_head_pos()
	local att_movement = attention and attention.unit and attention.unit.movement and attention.unit:movement() or nil
	local u_head_pos = att_movement and att_movement.m_head_pos and att_movement:m_head_pos() or nil

	if not u_head_pos then
		return false
	end

	local hit_shield = World:raycast("ray", head_pos, u_head_pos, "ignore_unit", {
		unit
	}, "slot_mask", TeamAILogicIdle._shield_check)

	return not not hit_shield
end

function TeamAILogicIdle._get_priority_attention(data, attention_objects, reaction_func)
	reaction_func = reaction_func or TeamAILogicBase._chk_reaction_to_attention_object
	local best_target, best_target_priority_slot, best_target_priority, best_target_reaction = nil

	for u_key, attention_data in pairs(attention_objects) do
		local att_unit = attention_data.unit
		local crim_record = attention_data.criminal_record

		if not attention_data.identified then
			-- Nothing
		elseif attention_data.pause_expire_t then
			if attention_data.pause_expire_t < data.t then
				attention_data.pause_expire_t = nil
			end
		elseif attention_data.stare_expire_t and attention_data.stare_expire_t < data.t then
			if attention_data.settings.pause then
				attention_data.stare_expire_t = nil
				attention_data.pause_expire_t = data.t + math.lerp(attention_data.settings.pause[1], attention_data.settings.pause[2], math.random())
			end
		else
			local distance = mvector3.distance(data.m_pos, attention_data.m_pos)
			local reaction = reaction_func(data, attention_data, not CopLogicAttack._can_move(data))
			local aimed_at = TeamAILogicIdle.chk_am_i_aimed_at(data, attention_data, attention_data.aimed_at and 0.95 or 0.985)
			attention_data.aimed_at = aimed_at
			local reaction_too_mild = nil

			if not reaction or best_target_reaction and reaction < best_target_reaction then
				reaction_too_mild = true
			elseif distance < 150 and reaction <= AIAttentionObject.REACT_SURPRISED then
				reaction_too_mild = true
			end

			if not reaction_too_mild then
				local alert_dt = attention_data.alert_t and data.t - attention_data.alert_t or 10000
				local dmg_dt = attention_data.dmg_t and data.t - attention_data.dmg_t or 10000
				local mark_dt = attention_data.mark_t and data.t - attention_data.mark_t or 10000
				local near_threshold = 800

				if data.attention_obj and data.attention_obj.u_key == u_key then
					alert_dt = alert_dt * 0.8
					dmg_dt = dmg_dt * 0.8
					mark_dt = mark_dt * 0.8
					distance = distance * 0.8
				end

				local visible = attention_data.verified
				local near = distance < near_threshold
				local has_alerted = alert_dt < 5
				local has_damaged = dmg_dt < 2
				local been_marked = mark_dt < 8
				local dangerous_special = attention_data.is_very_dangerous
				local is_shield = attention_data.is_shield
				local target_priority = distance
				local target_priority_slot = 0
				local is_shielded = TeamAILogicIdle._ignore_shield and TeamAILogicIdle._ignore_shield(data.unit, attention_data) or nil

				if visible then
					if (dangerous_special or been_marked) and distance < 1600 then
						target_priority_slot = 1
					elseif near and (has_alerted and has_damaged or been_marked or is_shield and not is_shielded) then
						target_priority_slot = 2
					elseif near and has_alerted then
						target_priority_slot = 3
					elseif has_alerted then
						target_priority_slot = 4
					else
						target_priority_slot = 5
					end

					if is_shielded then
						target_priority_slot = math.min(5, target_priority_slot + 1)
					end
				elseif has_alerted then
					target_priority_slot = 6
				else
					target_priority_slot = 7
				end

				if is_shielded then
					target_priority = target_priority * 10
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
						best_target_priority_slot = target_priority_slot
						best_target_priority = target_priority
						best_target_reaction = reaction
					end
				end
			end
		end
	end

	return best_target, best_target_priority_slot, best_target_reaction
end

function TeamAILogicIdle._upd_sneak_spotting(data, my_data)
	if false and managers.groupai:state():whisper_mode() and (not TeamAILogicAssault._mark_special_chk_t or TeamAILogicAssault._mark_special_chk_t + 0.75 < data.t) and (not TeamAILogicAssault._mark_special_t or TeamAILogicAssault._mark_special_t + 6 < data.t) and not data.unit:sound():speaking() then
		local nmy = TeamAILogicIdle.find_sneak_char_to_mark(data)
		TeamAILogicAssault._mark_special_chk_t = data.t

		if nmy then
			TeamAILogicAssault._mark_special_t = data.t

			TeamAILogicIdle.mark_sneak_char(data, data.unit, nmy, nil, nil)
		end
	end
end

function TeamAILogicIdle.find_sneak_char_to_mark(data)
	local best_nmy, best_nmy_wgt = nil

	for key, attention_info in pairs(data.detected_attention_objects) do
		if attention_info.identified and (attention_info.verified or attention_info.nearly_visible) and attention_info.is_person and attention_info.char_tweak and attention_info.char_tweak.silent_priority_shout and (not attention_info.char_tweak.priority_shout_max_dis or attention_info.dis < attention_info.char_tweak.priority_shout_max_dis) and (not best_nmy_wgt or attention_info.verified_dis < best_nmy_wgt) then
			best_nmy_wgt = attention_info.verified_dis
			best_nmy = attention_info.unit
		end
	end

	return best_nmy
end

function TeamAILogicIdle.mark_sneak_char(data, criminal, to_mark, play_sound, play_action)
	if play_sound then
		criminal:sound():say(to_mark:base():char_tweak().silent_priority_shout .. "x_any", true, false)
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
