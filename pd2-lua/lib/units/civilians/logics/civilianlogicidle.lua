local tmp_vec1 = Vector3()
CivilianLogicIdle = class(CivilianLogicBase)

function CivilianLogicIdle.enter(data, new_logic_name, enter_params)
	CopLogicBase.enter(data, new_logic_name, enter_params)

	local my_data = {
		unit = data.unit
	}
	data.internal_data = my_data

	if not data.char_tweak.detection then
		debug_pause_unit(data.unit, "missing detection tweak_data", data.unit)
	end

	local is_cool = data.unit:movement():cool()

	if is_cool then
		my_data.detection = data.char_tweak.detection.ntl
	else
		my_data.detection = data.char_tweak.detection.cbt
	end

	CopLogicBase._reset_attention(data)
	data.unit:brain():set_update_enabled_state(false)

	local key_str = tostring(data.key)
	local objective = data.objective

	if objective then
		if objective.action then
			local action = data.unit:brain():action_request(objective.action)

			if action and objective.action.type == "act" then
				my_data.acting = action

				if objective.action_start_clbk then
					objective.action_start_clbk(data.unit)

					if my_data ~= data.internal_data then
						return
					end
				end
			end
		end

		if objective.action_duration then
			my_data.action_timeout_clbk_id = "CivilianLogicIdle_action_timeout" .. key_str
			local action_timeout_t = data.t + objective.action_duration

			CopLogicBase.add_delayed_clbk(my_data, my_data.action_timeout_clbk_id, callback(CivilianLogicIdle, CivilianLogicIdle, "clbk_action_timeout", data), action_timeout_t)
		end
	end

	my_data.tmp_vec3 = Vector3()
	my_data.detection_task_key = "CivilianLogicIdle._upd_detection" .. key_str

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, CivilianLogicIdle._upd_detection, data, data.t + 1)

	if not data.been_outlined and data.char_tweak.outline_on_discover then
		my_data.outline_detection_task_key = "CivilianLogicIdle._upd_outline_detection" .. tostring(data.key)

		CopLogicBase.queue_task(my_data, my_data.outline_detection_task_key, CivilianLogicIdle._upd_outline_detection, data, data.t + 2)
	end

	if not data.unit:movement():cool() then
		my_data.registered_as_fleeing = true

		managers.groupai:state():register_fleeing_civilian(data.key, data.unit)
	end

	if objective and objective.stance then
		data.unit:movement():set_stance(objective.stance)
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
end

function CivilianLogicIdle.exit(data, new_logic_name, enter_params)
	CopLogicBase.exit(data, new_logic_name, enter_params)

	local my_data = data.internal_data

	if my_data.idle_attention and alive(my_data.idle_attention.unit) then
		CopLogicBase._reset_attention(data)
	end

	if my_data.enemy_weapons_hot_listen_id then
		managers.groupai:state():remove_listener(my_data.enemy_weapons_hot_listen_id)
	end

	CopLogicBase.cancel_delayed_clbks(my_data)
	CopLogicBase.cancel_queued_tasks(my_data)

	if my_data.registered_as_fleeing then
		managers.groupai:state():unregister_fleeing_civilian(data.key)
	end
end

function CivilianLogicIdle._upd_outline_detection(data)
	local my_data = data.internal_data

	if data.been_outlined or data.has_outline then
		return
	end

	local t = TimerManager:game():time()
	local visibility_slotmask = managers.slot:get_mask("AI_visibility")
	local seen = false
	local seeing_unit = nil
	local my_tracker = data.unit:movement():nav_tracker()
	local chk_vis_func = my_tracker.check_visibility

	for e_key, record in pairs(managers.groupai:state():all_criminals()) do
		if chk_vis_func(my_tracker, record.tracker) then
			local enemy_pos = record.m_det_pos
			local my_pos = data.unit:movement():m_head_pos()

			if mvector3.distance_sq(enemy_pos, my_pos) < 1440000 then
				local not_hit = World:raycast("ray", my_pos, enemy_pos, "slot_mask", visibility_slotmask, "ray_type", "ai_vision", "report")

				if not not_hit then
					seen = true
					seeing_unit = record.unit

					break
				end
			end
		end
	end

	if seen then
		CivilianLogicIdle._enable_outline(data)
	else
		CopLogicBase.queue_task(my_data, my_data.outline_detection_task_key, CivilianLogicIdle._upd_outline_detection, data, t + 0.33)
	end
end

function CivilianLogicIdle._enable_outline(data)
	local my_data = data.internal_data

	data.unit:contour():add("highlight_character")

	data.has_outline = true
	data.been_outlined = true
	my_data.outline_detection_task_key = nil
end

function CivilianLogicIdle.on_alert(data, alert_data)
	if data.is_tied and data.unit:anim_data().stand then
		if TimerManager:game():time() - data.internal_data.state_enter_t > 3 then
			data.unit:brain():on_hostage_move_interaction(nil, "stay")
		end

		return
	end

	local my_data = data.internal_data
	local my_dis, alert_delay = nil
	local my_listen_pos = data.unit:movement():m_head_pos()
	local alert_epicenter = alert_data[2]

	if CopLogicBase._chk_alert_obstructed(data.unit:movement():m_head_pos(), alert_data) then
		return
	end

	if CopLogicBase.is_alert_aggressive(alert_data[1]) and not data.unit:base().unintimidateable then
		if not data.unit:movement():cool() then
			local aggressor = alert_data[5]

			if aggressor and aggressor:base() then
				local is_intimidation = nil

				if aggressor:base().is_local_player then
					if managers.player:has_category_upgrade("player", "civ_calming_alerts") then
						is_intimidation = true
					end
				elseif aggressor:base().is_husk_player and aggressor:base():upgrade_value("player", "civ_calming_alerts") then
					is_intimidation = true
				end

				if is_intimidation then
					if not data.brain:interaction_voice() then
						data.unit:brain():on_intimidated(1, aggressor)
					end

					return
				end
			end
		end

		data.unit:movement():set_cool(false, managers.groupai:state().analyse_giveaway(data.unit:base()._tweak_table, alert_data[5], alert_data))
		data.unit:movement():set_stance(data.is_tied and "cbt" or "hos")
	end

	if alert_data[5] then
		local att_obj_data, is_new = CopLogicBase.identify_attention_obj_instant(data, alert_data[5]:key())
	end

	if my_data == data.internal_data and not data.char_tweak.ignores_aggression then
		my_dis = my_dis or alert_epicenter and mvector3.distance(my_listen_pos, alert_epicenter) or 3000
		alert_delay = math.lerp(1, 4, math.min(1, my_dis / 2000)) * math.random()

		if not my_data.delayed_alert_id then
			my_data.delayed_alert_id = "alert" .. tostring(data.key)

			CopLogicBase.add_delayed_clbk(my_data, my_data.delayed_alert_id, callback(CivilianLogicIdle, CivilianLogicIdle, "_delayed_alert_clbk", {
				data = data,
				alert_data = clone(alert_data)
			}), TimerManager:game():time() + alert_delay)
		end
	end
end

function CivilianLogicIdle._delayed_alert_clbk(ignore_this, params)
	local data = params.data
	local alert_data = params.alert_data
	local my_data = data.internal_data

	CopLogicBase.on_delayed_clbk(my_data, my_data.delayed_alert_id)

	my_data.delayed_alert_id = nil
	local alerting_unit = alert_data[5]
	alerting_unit = alive(alerting_unit) and alerting_unit

	if not CivilianLogicIdle.is_obstructed(data, alerting_unit) then
		my_data.delayed_alert_id = "alert" .. tostring(data.key)

		CopLogicBase.add_delayed_clbk(my_data, my_data.delayed_alert_id, callback(CivilianLogicIdle, CivilianLogicIdle, "_delayed_alert_clbk", {
			data = data,
			alert_data = clone(alert_data)
		}), TimerManager:game():time() + 1)

		return
	end

	alert_data[5] = alerting_unit
	data.call_police_delay_t = data.call_police_delay_t or TimerManager:game():time() + 20 + 10 * math.random()

	data.unit:brain():set_objective({
		is_default = true,
		type = "free",
		alert_data = alert_data
	})
end

function CivilianLogicIdle.on_intimidated(data, amount, aggressor_unit)
	data.unit:movement():set_cool(false, managers.groupai:state().analyse_giveaway(data.unit:base()._tweak_table, aggressor_unit))
	data.unit:movement():set_stance(data.is_tied and "cbt" or "hos")

	local att_obj_data, is_new = CopLogicBase.identify_attention_obj_instant(data, aggressor_unit:key())

	if not data.char_tweak.intimidateable or data.unit:base().unintimidateable or data.unit:anim_data().unintimidateable then
		return
	end

	if not CivilianLogicIdle.is_obstructed(data, aggressor_unit) then
		return
	end

	data.unit:brain():set_objective({
		type = "surrender",
		amount = amount,
		aggressor_unit = aggressor_unit
	})
end

function CivilianLogicIdle.damage_clbk(data, damage_info)
	data.unit:movement():set_cool(false, managers.groupai:state().analyse_giveaway(data.unit:base()._tweak_table, damage_info.attacker_unit))
	data.unit:movement():set_stance(data.is_tied and "cbt" or "hos")

	if not CivilianLogicIdle.is_obstructed(data, damage_info.attacker_unit) then
		return
	end

	data.unit:brain():set_objective({
		is_default = true,
		type = "free",
		dmg_info = damage_info
	})
end

function CivilianLogicIdle.on_new_objective(data, old_objective, params)
	local new_objective = data.objective

	CivilianLogicIdle.super.on_new_objective(data, old_objective)

	local my_data = data.internal_data

	if new_objective then
		if new_objective.type == "escort" then
			CopLogicBase._exit(data.unit, "escort")
		elseif CopLogicIdle._chk_objective_needs_travel(data, new_objective) then
			CopLogicBase._exit(data.unit, "travel")
		elseif new_objective.type == "act" then
			CopLogicBase._exit(data.unit, "idle")
		elseif data.is_tied then
			CopLogicBase._exit(data.unit, "surrender", params)
		elseif new_objective.type == "free" then
			if data.unit:movement():cool() or not new_objective.is_default then
				CopLogicBase._exit(data.unit, "idle")
			else
				CopLogicBase._exit(data.unit, "flee")
			end
		elseif new_objective.type == "surrender" then
			CopLogicBase._exit(data.unit, "surrender", params)
		end
	elseif data.unit:movement():cool() then
		CopLogicBase._exit(data.unit, "idle")
	elseif data.is_tied then
		CopLogicBase._exit(data.unit, "surrender", params)
	else
		CopLogicBase._exit(data.unit, "flee")
	end

	if new_objective and new_objective.stance then
		if new_objective.stance == "ntl" then
			data.unit:movement():set_cool(true)
		else
			data.unit:movement():set_cool(false)
		end

		data.unit:movement():set_stance(new_objective.stance)
	end

	if old_objective and old_objective.fail_clbk then
		old_objective.fail_clbk(data.unit)
	end
end

function CivilianLogicIdle.action_complete_clbk(data, action)
	local my_data = data.internal_data

	if action:type() == "turn" then
		my_data.turning = nil
	elseif action:type() == "act" and my_data.acting == action then
		my_data.acting = nil

		if action:expired() then
			if not my_data.action_timeout_clbk_id then
				data.objective_complete_clbk(data.unit, data.objective)
			end
		else
			data.objective_failed_clbk(data.unit, data.objective)
		end
	end
end

function CivilianLogicIdle._upd_detection(data)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local delay = CopLogicBase._upd_attention_obj_detection(data, nil, nil)
	local new_attention, new_reaction = CivilianLogicIdle._get_priority_attention(data, data.detected_attention_objects)

	CivilianLogicIdle._set_attention_obj(data, new_attention, new_reaction)

	if new_reaction and AIAttentionObject.REACT_SCARED <= new_reaction then
		local objective = data.objective
		local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, objective, nil, new_attention)

		if allow_trans then
			local alert = {
				"vo_cbt",
				new_attention.m_head_pos,
				[5] = new_attention.unit
			}

			CivilianLogicIdle.on_alert(data, alert)

			if my_data ~= data.internal_data then
				return
			end
		end
	elseif not data.char_tweak.ignores_attention_focus then
		CopLogicIdle._chk_focus_on_attention_object(data, my_data)
	end

	if not data.unit:movement():cool() and (not my_data.acting or not not data.unit:anim_data().act_idle) then
		local objective = data.objective

		if not objective or objective.interrupt_dis == -1 or objective.is_default then
			local alert = {
				"vo_cbt",
				data.m_pos
			}

			CivilianLogicIdle.on_alert(data, alert)

			if my_data ~= data.internal_data then
				return
			end
		end
	end

	if CopLogicIdle._chk_relocate(data) then
		return
	end

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, CivilianLogicIdle._upd_detection, data, data.t + delay)
end

function CivilianLogicIdle.is_available_for_assignment(data, objective)
	if objective and objective.forced then
		return true
	end

	local my_data = data.internal_data

	return (not my_data.acting or data.unit:anim_data().act_idle) and not my_data.exiting and not my_data.delayed_alert_id
end

function CivilianLogicIdle.anim_clbk(data, info_type)
	if info_type == "reset_attention" and data.internal_data.idle_attention then
		data.internal_data.idle_attention = nil

		CopLogicBase._reset_attention(data)
	end
end

function CivilianLogicIdle.clbk_action_timeout(ignore_this, data)
	local my_data = data.internal_data

	CopLogicBase.on_delayed_clbk(my_data, my_data.action_timeout_clbk_id)

	my_data.action_timeout_clbk_id = nil
	local old_objective = data.objective

	if not old_objective then
		debug_pause_unit(data.unit, "[CivilianLogicIdle.clbk_action_timeout] missing objective")

		return
	end

	if my_data.delayed_alert_id then
		managers.enemy:force_delayed_clbk(my_data.delayed_alert_id)
	end

	if data.objective == old_objective then
		data.objective_complete_clbk(data.unit, old_objective)
	end
end

function CivilianLogicIdle.is_obstructed(data, aggressor_unit)
	if data.unit:movement():chk_action_forbidden("walk") and not data.unit:anim_data().act_idle then
		return
	end

	local objective = data.objective

	if not objective or objective.is_default or (objective.in_place or not objective.nav_seg) and not objective.action and not objective.action_duration then
		return true
	end

	if objective.interrupt_dis == -1 then
		return true
	end

	if aggressor_unit and aggressor_unit:movement() and objective.interrupt_dis and mvector3.distance_sq(data.m_pos, aggressor_unit:movement():m_pos()) < objective.interrupt_dis * objective.interrupt_dis then
		return true
	end

	if objective.interrupt_health then
		local health_ratio = data.unit:character_damage():health_ratio()

		if health_ratio < 1 and health_ratio < objective.interrupt_health then
			return true
		end
	end
end

function CivilianLogicIdle._get_priority_attention(data, attention_objects)
	local best_target, best_target_priority, best_target_reaction = nil

	for u_key, attention_data in pairs(attention_objects) do
		local att_unit = attention_data.unit

		if not attention_data.identified then
			-- Nothing
		elseif attention_data.pause_expire_t then
			if attention_data.pause_expire_t < data.t and (not attention_data.settings.attract_chance or math.random() < attention_data.settings.attract_chance) then
				attention_data.pause_expire_t = nil
			end
		elseif attention_data.stare_expire_t and attention_data.stare_expire_t < data.t then
			if attention_data.settings.pause then
				attention_data.stare_expire_t = nil
			end
		else
			local distance = attention_data.dis
			local reaction = attention_data.settings.reaction
			local reaction_too_mild = nil

			if not reaction or best_target_reaction and reaction < best_target_reaction then
				reaction_too_mild = true
			elseif distance < 150 and reaction == AIAttentionObject.REACT_IDLE then
				reaction_too_mild = true
			end

			if not reaction_too_mild then
				if data.current_attention and data.current_attention.u_key == u_key then
					distance = distance * 0.8
				end

				local target_priority = distance

				if not best_target_priority or target_priority < best_target_priority then
					best_target = attention_data
					best_target_reaction = reaction
					best_target_priority = target_priority
				end
			end
		end
	end

	return best_target, best_target_reaction
end

function CivilianLogicIdle._set_attention_obj(data, new_att_obj, new_reaction)
	local old_att_obj = data.attention_obj
	data.attention_obj = new_att_obj

	if new_att_obj then
		new_reaction = new_reaction or new_att_obj.settings.reaction
		new_att_obj.reaction = new_reaction
		local is_same_obj = nil

		if old_att_obj and old_att_obj.u_key == new_att_obj.u_key then
			is_same_obj = true

			if new_att_obj.stare_expire_t and new_att_obj.stare_expire_t < data.t then
				if new_att_obj.settings.pause then
					new_att_obj.stare_expire_t = nil
				end
			elseif new_att_obj.pause_expire_t and new_att_obj.pause_expire_t < data.t then
				if not new_att_obj.settings.attract_chance or math.random() < new_att_obj.settings.attract_chance then
					new_att_obj.pause_expire_t = nil
				else
					debug_pause_unit(data.unit, "[CivilianLogicIdle._set_attention_obj] skipping attraction")
				end
			end
		end

		if not is_same_obj and new_att_obj.settings.duration then
			new_att_obj.pause_expire_t = nil
		end
	end
end
