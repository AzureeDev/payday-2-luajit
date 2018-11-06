local tmp_vec1 = Vector3()
CopLogicIntimidated = class(CopLogicBase)

function CopLogicIntimidated.enter(data, new_logic_name, enter_params)
	CopLogicBase.enter(data, new_logic_name, enter_params)
	data.unit:brain():cancel_all_pathing_searches()

	local old_internal_data = data.internal_data
	local my_data = {
		unit = data.unit
	}
	data.internal_data = my_data
	my_data.detection = data.char_tweak.detection.combat
	my_data.aggressor_unit = enter_params and enter_params.aggressor_unit

	if data.attention_obj then
		CopLogicBase._set_attention_obj(data, nil, nil)
	end

	if old_internal_data and old_internal_data.nearest_cover then
		my_data.nearest_cover = old_internal_data.nearest_cover

		managers.navigation:reserve_cover(my_data.nearest_cover[1], data.pos_rsrv_id)
	end

	my_data.surrender_break_t = data.char_tweak.surrender_break_time and data.t + math.random(data.char_tweak.surrender_break_time[1], data.char_tweak.surrender_break_time[2], math.random())

	if data.unit:anim_data().hands_tied then
		CopLogicIntimidated._do_tied(data, nil)
	else
		data.unit:brain():set_update_enabled_state(true)
	end

	data.unit:movement():set_allow_fire(false)

	if data.objective then
		data.objective_failed_clbk(data.unit, data.objective)
	end

	if managers.groupai:state():rescue_state() then
		CopLogicIntimidated._add_delayed_rescue_SO(data, my_data)
	end

	managers.groupai:state():add_to_surrendered(data.unit, callback(CopLogicIntimidated, CopLogicIntimidated, "queued_update", data))

	my_data.surrender_clbk_registered = true

	data.unit:sound():say("s01x", true)
	data.unit:movement():set_cool(false)

	if my_data ~= data.internal_data then
		return
	end

	data.unit:brain():set_attention_settings({
		corpse_sneak = true
	})
	managers.groupai:state():register_rescueable_hostage(data.unit, nil)

	my_data.is_hostage = true

	managers.groupai:state():on_hostage_state(true, data.key, true)
	managers.network:session():send_to_peers_synched("sync_unit_surrendered", data.unit, true)
end

function CopLogicIntimidated.exit(data, new_logic_name, enter_params)
	CopLogicBase.exit(data, new_logic_name, enter_params)

	local my_data = data.internal_data

	CopLogicIntimidated._unregister_rescue_SO(data, my_data)

	if new_logic_name ~= "inactive" then
		data.unit:base():set_slot(data.unit, 12)
	end

	if my_data.nearest_cover then
		managers.navigation:release_cover(my_data.nearest_cover[1])
	end

	if new_logic_name ~= "inactive" then
		data.unit:brain():set_update_enabled_state(true)
		data.unit:interaction():set_active(false, true, false)
	end

	if my_data.tied then
		managers.groupai:state():on_enemy_untied(data.unit:key())
	end

	managers.groupai:state():unregister_rescueable_hostage(data.key)
	CopLogicIntimidated._unregister_harassment_SO(data, my_data)

	if my_data.surrender_clbk_registered then
		managers.groupai:state():remove_from_surrendered(data.unit)
	end

	if my_data.is_hostage then
		managers.groupai:state():on_hostage_state(false, data.key, true)
	end

	managers.network:session():send_to_peers_synched("sync_unit_surrendered", data.unit, false)
end

function CopLogicIntimidated.death_clbk(data, damage_info)
	CopLogicIntimidated.super.death_clbk(data, damage_info)
end

function CopLogicIntimidated.queued_update(rubbish, data)
	local my_data = data.internal_data

	CopLogicIntimidated._update_enemy_detection(data, my_data)

	if my_data ~= data.internal_data then
		return
	end

	managers.groupai:state():add_to_surrendered(data.unit, callback(CopLogicIntimidated, CopLogicIntimidated, "queued_update", data))
end

function CopLogicIntimidated._update_enemy_detection(data, my_data)
	local robbers = managers.groupai:state():all_criminals()
	local my_tracker = data.unit:movement():nav_tracker()
	local chk_vis_func = my_tracker.check_visibility
	local fight = not my_data.tied

	if not my_data.surrender_break_t or data.t < my_data.surrender_break_t then
		for u_key, u_data in pairs(robbers) do
			if not u_data.is_deployable and chk_vis_func(my_tracker, u_data.tracker) then
				local crim_unit = u_data.unit
				local crim_pos = u_data.m_pos
				local dis = mvector3.direction(tmp_vec1, data.m_pos, crim_pos)

				if dis < tweak_data.player.long_dis_interaction.intimidate_range_enemies * tweak_data.upgrades.values.player.intimidate_range_mul[1] * 1.05 then
					local crim_fwd = crim_unit:movement():m_head_rot():y()

					mvector3.set_z(crim_fwd, 0)
					mvector3.normalize(crim_fwd)

					if mvector3.dot(crim_fwd, tmp_vec1) < -0.2 then
						local vis_ray = World:raycast("ray", data.unit:movement():m_head_pos(), u_data.m_det_pos, "slot_mask", data.visibility_slotmask, "ray_type", "ai_vision", "report")

						if not vis_ray then
							fight = nil

							break
						end
					end
				end
			end
		end
	end

	if fight then
		my_data.surrender_clbk_registered = nil

		data.brain:set_objective(nil)
		CopLogicBase._exit(data.unit, "idle")
	end
end

function CopLogicIntimidated.action_complete_clbk(data, action)
	local my_data = data.internal_data
	local action_type = action:type()

	if action_type == "act" then
		if my_data.being_harassed then
			my_data.being_harassed = nil

			CopLogicIntimidated._add_delayed_rescue_SO(data, my_data)
		elseif my_data.act_action then
			my_data.act_action = nil
		end
	end

	data.unit:brain():set_update_enabled_state(true)
end

function CopLogicIntimidated.update(data)
	if data.unit:anim_data().surrender then
		return
	end

	if not data.unit:movement():chk_action_forbidden("walk") then
		CopLogicIntimidated._start_action_hands_up(data)
		data.unit:brain():set_update_enabled_state(false)
	end
end

function CopLogicIntimidated.can_activate()
	return false
end

function CopLogicIntimidated.on_intimidated(data, amount, aggressor_unit)
	local my_data = data.internal_data

	if not my_data.tied then
		my_data.surrender_break_t = data.char_tweak.surrender_break_time and data.t + math.random(data.char_tweak.surrender_break_time[1], data.char_tweak.surrender_break_time[2], math.random())
		local anim_data = data.unit:anim_data()
		local anim, blocks = nil

		if anim_data.hands_up then
			anim = "hands_back"
			blocks = {
				heavy_hurt = -1,
				hurt = -1,
				action = -1,
				light_hurt = -1,
				walk = -1
			}
		elseif anim_data.hands_back then
			anim = "tied"
			blocks = {
				heavy_hurt = -1,
				hurt_sick = -1,
				action = -1,
				light_hurt = -1,
				hurt = -1,
				walk = -1
			}
		else
			if managers.groupai:state():whisper_mode() then
				anim = "tied_all_in_one"
			else
				anim = "hands_up"
			end

			blocks = {
				heavy_hurt = -1,
				hurt = -1,
				action = -1,
				light_hurt = -1,
				walk = -1
			}
		end

		local action_data = {
			clamp_to_graph = true,
			type = "act",
			body_part = 1,
			variant = anim,
			blocks = blocks
		}
		local act_action = data.unit:brain():action_request(action_data)

		if data.unit:anim_data().hands_tied then
			CopLogicIntimidated._do_tied(data, aggressor_unit)
		end
	end
end

function CopLogicIntimidated._register_harassment_SO(data, my_data)
	local objective_pos = data.unit:position() - data.unit:rotation():y() * 100
	local objective_rot = data.unit:rotation()
	local objective = {
		stance = "hos",
		interrupt_health = 0.85,
		type = "act",
		scan = true,
		interrupt_dis = 700,
		pos = objective_pos,
		rot = objective_rot,
		nav_seg = data.unit:movement():nav_tracker():nav_segment(),
		action_start_clbk = callback(CopLogicIntimidated, CopLogicIntimidated, "on_harassment_SO_action_start", data),
		fail_clbk = callback(CopLogicIntimidated, CopLogicIntimidated, "on_harassment_SO_failed", data),
		action = {
			variant = "kick_fwd",
			body_part = 1,
			type = "act",
			blocks = {
				action = -1,
				walk = -1
			}
		}
	}
	local so_descriptor = {
		interval = 10,
		search_dis_sq = 2250000,
		AI_group = "friendlies",
		base_chance = 1,
		chance_inc = 0,
		usage_amount = 1,
		objective = objective,
		search_pos = mvector3.copy(data.m_pos),
		admin_clbk = callback(CopLogicIntimidated, CopLogicIntimidated, "on_harassment_SO_administered", data)
	}
	local so_id = "harass" .. tostring(data.unit:key())
	my_data.harassment_SO_id = so_id

	managers.groupai:state():add_special_objective(so_id, so_descriptor)
end

function CopLogicIntimidated.on_harassment_SO_administered(ignore_this, data, receiver_unit)
	local my_data = data.internal_data
	my_data.harassment_SO_id = nil
end

function CopLogicIntimidated.on_harassment_SO_action_start(ignore_this, data, receiver_unit)
	local my_data = data.internal_data
	local action = {
		variant = "harassed_kicked_from_behind",
		body_part = 1,
		type = "act",
		blocks = {
			light_hurt = -1,
			hurt = -1,
			action = -1,
			heavy_hurt = -1,
			walk = -1
		}
	}
	my_data.being_harassed = data.unit:movement():action_request(action)

	managers.groupai:state():on_occasional_event("cop_harassment")
	CopLogicIntimidated._unregister_rescue_SO(data, my_data)
end

function CopLogicIntimidated.on_harassment_SO_failed(ignore_this, data, receiver_unit)
	local my_data = data.internal_data

	if my_data.being_harassed then
		local action_data = {
			variant = "tied",
			body_part = 1,
			type = "act",
			blocks = {
				light_hurt = -1,
				hurt = -1,
				heavy_hurt = -1,
				walk = -1
			}
		}

		data.unit:brain():action_request(action_data)

		my_data.being_harassed = nil
	end
end

function CopLogicIntimidated._unregister_harassment_SO(data, my_data)
	local my_data = data.internal_data

	if my_data.harassment_SO_id then
		managers.groupai:state():remove_special_objective(my_data.harassment_SO_id)

		my_data.harassment_SO_id = nil
	end
end

function CopLogicIntimidated._do_tied(data, aggressor_unit)
	local my_data = data.internal_data
	aggressor_unit = alive(aggressor_unit) and aggressor_unit

	if my_data.surrender_clbk_registered then
		managers.groupai:state():remove_from_surrendered(data.unit)

		my_data.surrender_clbk_registered = nil
	end

	my_data.tied = true

	data.unit:inventory():destroy_all_items()
	data.unit:brain():set_update_enabled_state(false)

	if my_data.update_task_key then
		managers.enemy:unqueue_task(my_data.update_task_key)

		my_data.update_task_key = nil
	end

	data.brain:rem_pos_rsrv("stand")
	managers.groupai:state():on_enemy_tied(data.unit:key())
	data.unit:base():set_slot(data.unit, 22)
	CopLogicIntimidated._chk_begin_alarm_pager(data)

	if not data.brain:is_pager_started() then
		data.unit:interaction():set_tweak_data("hostage_convert")
		data.unit:interaction():set_active(true, true, false)
	end

	if data.unit:unit_data().mission_element then
		data.unit:unit_data().mission_element:event("tied", data.unit)
	end

	if aggressor_unit then
		data.unit:character_damage():drop_pickup()
		data.unit:character_damage():set_pickup(nil)

		if aggressor_unit == managers.player:player_unit() then
			managers.statistics:tied({
				name = data.unit:base()._tweak_table
			})
		else
			aggressor_unit:network():send_to_unit({
				"statistics_tied",
				data.unit:base()._tweak_table
			})
		end
	end

	managers.groupai:state():on_criminal_suspicion_progress(nil, data.unit, nil)
end

function CopLogicIntimidated.on_enemy_weapons_hot(data)
	if data.internal_data.tied then
		data.unit:interaction():set_tweak_data("hostage_convert")
		data.unit:interaction():set_active(true, true, false)
	end
end

function CopLogicIntimidated.on_detected_enemy_destroyed(data, enemy_unit)
	CopLogicIdle.on_detected_enemy_destroyed(data, enemy_unit)
end

function CopLogicIntimidated.on_criminal_neutralized(data, criminal_key)
	CopLogicIdle.on_criminal_neutralized(data, criminal_key)
end

function CopLogicIntimidated.on_alert(data, alert_data)
	local alert_unit = alert_data[5]

	if alert_unit and alert_unit:in_slot(data.enemy_slotmask) then
		local att_obj_data, is_new = CopLogicBase.identify_attention_obj_instant(data, alert_unit:key())

		if not att_obj_data then
			return
		end

		local alert_type = alert_data[1]

		if alert_type == "bullet" or alert_type == "aggression" or alert_type == "explosion" then
			att_obj_data.alert_t = TimerManager:game():time()
		end

		if att_obj_data.criminal_record then
			managers.groupai:state():criminal_spotted(alert_unit)

			if alert_type == "bullet" or alert_type == "aggression" or alert_type == "explosion" then
				managers.groupai:state():report_aggression(alert_unit)
			end
		end
	end
end

function CopLogicIntimidated.is_available_for_assignment(data, objective)
	if objective and objective.forced then
		return true
	end

	return false
end

function CopLogicIntimidated._add_delayed_rescue_SO(data, my_data)
	if data.char_tweak.flee_type ~= "hide" then
		if data.unit:unit_data() and data.unit:unit_data().not_rescued then
			-- Nothing
		elseif my_data.delayed_clbks and my_data.delayed_clbks[my_data.delayed_rescue_SO_id] then
			managers.enemy:reschedule_delayed_clbk(my_data.delayed_rescue_SO_id, TimerManager:game():time() + 10)
		else
			if my_data.rescuer then
				local objective = my_data.rescuer:brain():objective()
				local rescuer = my_data.rescuer
				my_data.rescuer = nil

				managers.groupai:state():on_objective_failed(rescuer, objective)
			elseif my_data.rescue_SO_id then
				managers.groupai:state():remove_special_objective(my_data.rescue_SO_id)

				my_data.rescue_SO_id = nil
			end

			my_data.delayed_rescue_SO_id = "rescue" .. tostring(data.unit:key())

			CopLogicBase.add_delayed_clbk(my_data, my_data.delayed_rescue_SO_id, callback(CopLogicIntimidated, CopLogicIntimidated, "register_rescue_SO", data), TimerManager:game():time() + 10)
		end
	end
end

function CopLogicIntimidated.register_rescue_SO(ignore_this, data)
	local my_data = data.internal_data

	CopLogicBase.on_delayed_clbk(my_data, my_data.delayed_rescue_SO_id)

	my_data.delayed_rescue_SO_id = nil
	local my_tracker = data.unit:movement():nav_tracker()
	local objective_pos = my_tracker:field_position()
	local followup_objective = {
		scan = true,
		type = "act",
		stance = "hos",
		action = {
			variant = "idle",
			body_part = 1,
			type = "act",
			blocks = {
				action = -1,
				walk = -1
			}
		},
		action_duration = tweak_data.interaction.free.timer
	}
	local objective = {
		interrupt_health = 0.85,
		stance = "hos",
		type = "act",
		scan = true,
		destroy_clbk_key = false,
		interrupt_dis = 700,
		follow_unit = data.unit,
		pos = mvector3.copy(objective_pos),
		nav_seg = data.unit:movement():nav_tracker():nav_segment(),
		fail_clbk = callback(CopLogicIntimidated, CopLogicIntimidated, "on_rescue_SO_failed", data),
		complete_clbk = callback(CopLogicIntimidated, CopLogicIntimidated, "on_rescue_SO_completed", data),
		action = {
			variant = "untie",
			body_part = 1,
			type = "act",
			blocks = {
				action = -1,
				walk = -1
			}
		},
		action_duration = tweak_data.interaction.free.timer,
		followup_objective = followup_objective
	}
	local so_descriptor = {
		interval = 10,
		search_dis_sq = 1000000,
		AI_group = "enemies",
		base_chance = 1,
		chance_inc = 0,
		usage_amount = 1,
		objective = objective,
		search_pos = mvector3.copy(data.m_pos),
		admin_clbk = callback(CopLogicIntimidated, CopLogicIntimidated, "on_rescue_SO_administered", data),
		verification_clbk = callback(CopLogicIntimidated, CopLogicIntimidated, "rescue_SO_verification", data)
	}
	local so_id = "rescue" .. tostring(data.unit:key())
	my_data.rescue_SO_id = so_id

	managers.groupai:state():add_special_objective(so_id, so_descriptor)
end

function CopLogicIntimidated._unregister_rescue_SO(data, my_data)
	if my_data.rescuer then
		local rescuer = my_data.rescuer
		my_data.rescuer = nil

		managers.groupai:state():on_objective_failed(rescuer, rescuer:brain():objective())
	elseif my_data.rescue_SO_id then
		managers.groupai:state():remove_special_objective(my_data.rescue_SO_id)

		my_data.rescue_SO_id = nil
	elseif my_data.delayed_rescue_SO_id then
		CopLogicBase.chk_cancel_delayed_clbk(my_data, my_data.delayed_rescue_SO_id)
	end
end

function CopLogicIntimidated.on_rescue_SO_administered(ignore_this, data, receiver_unit)
	local my_data = data.internal_data
	my_data.rescuer = receiver_unit
	my_data.rescue_SO_id = nil
end

function CopLogicIntimidated.rescue_SO_verification(ignore_this, data, unit)
	return unit:base():char_tweak().rescue_hostages and not unit:movement():cool() and not data.team.foes[unit:movement():team().id]
end

function CopLogicIntimidated.on_rescue_SO_failed(ignore_this, data)
	local my_data = data.internal_data

	if my_data.rescuer then
		my_data.rescuer = nil
		my_data.delayed_rescue_SO_id = "rescue" .. tostring(data.unit:key())

		CopLogicBase.add_delayed_clbk(my_data, my_data.delayed_rescue_SO_id, callback(CopLogicIntimidated, CopLogicIntimidated, "register_rescue_SO", data), TimerManager:game():time() + 10)
	end
end

function CopLogicIntimidated.on_rescue_SO_completed(ignore_this, data, good_pig)
	if not data.unit:inventory():equipped_unit() then
		if data.unit:inventory():num_selections() <= 0 then
			local weap_name = data.unit:base():default_weapon_name()

			if weap_name then
				data.unit:inventory():add_unit_by_name(weap_name, true, true)
			end
		else
			data.unit:inventory():equip_selection(1, true)
		end
	end

	if data.unit:anim_data().hands_tied then
		local new_action = {
			variant = "stand",
			body_part = 1,
			type = "act"
		}

		data.unit:brain():action_request(new_action)
	end

	if data.objective and (data.objective.nav_seg or data.objective.type == "follow") then
		data.objective.in_place = true
	end

	CopLogicBase._exit(data.unit, "idle")
end

function CopLogicIntimidated.on_rescue_allowed_state(data, state)
	if state then
		if not data.unit:anim_data().move then
			CopLogicIntimidated._add_delayed_rescue_SO(data, data.internal_data)
		end
	else
		CopLogicIntimidated._unregister_rescue_SO(data, data.internal_data)
	end
end

function CopLogicIntimidated.anim_clbk(data, event_type)
	local my_data = data.internal_data

	if event_type == "harass_end" and my_data.being_harassed then
		my_data.being_harassed = nil

		CopLogicIntimidated._add_delayed_rescue_SO(data, data.internal_data)
	end
end

function CopLogicIntimidated._start_action_hands_up(data)
	local my_data = data.internal_data
	local anim_name = managers.groupai:state():whisper_mode() and "tied_all_in_one" or "hands_up"
	local action_data = {
		clamp_to_graph = true,
		type = "act",
		body_part = 1,
		variant = anim_name,
		blocks = {
			light_hurt = -1,
			hurt = -1,
			heavy_hurt = -1,
			walk = -1
		}
	}
	my_data.act_action = data.unit:brain():action_request(action_data)

	if my_data.act_action and data.unit:anim_data().hands_tied then
		CopLogicIntimidated._do_tied(data, my_data.aggressor_unit)
	end
end

function CopLogicIntimidated._chk_begin_alarm_pager(data)
	if managers.groupai:state():whisper_mode() and data.unit:unit_data().has_alarm_pager then
		data.brain:begin_alarm_pager()
	end
end
