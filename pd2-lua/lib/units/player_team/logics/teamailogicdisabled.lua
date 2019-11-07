require("lib/units/enemies/cop/logics/CopLogicAttack")

TeamAILogicDisabled = class(TeamAILogicAssault)
TeamAILogicDisabled.on_long_dis_interacted = TeamAILogicIdle.on_long_dis_interacted

function TeamAILogicDisabled.enter(data, new_logic_name, enter_params)
	TeamAILogicBase.enter(data, new_logic_name, enter_params)
	data.unit:brain():cancel_all_pathing_searches()

	local old_internal_data = data.internal_data
	local my_data = {
		unit = data.unit
	}
	data.internal_data = my_data
	my_data.detection = data.char_tweak.detection.combat
	my_data.enemy_detect_slotmask = managers.slot:get_mask("enemies")

	if old_internal_data then
		CopLogicAttack._set_best_cover(data, my_data, old_internal_data.best_cover)
		CopLogicAttack._set_nearest_cover(my_data, old_internal_data.nearest_cover)

		my_data.attention_unit = old_internal_data.attention_unit
	end

	local key_str = tostring(data.key)
	my_data.detection_task_key = "TeamAILogicDisabled._upd_enemy_detection" .. key_str

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, TeamAILogicDisabled._upd_enemy_detection, data, data.t)

	my_data.stay_cool = nil

	if data.unit:character_damage():need_revive() then
		TeamAILogicDisabled._register_revive_SO(data, my_data, "revive")
	end

	data.unit:brain():set_update_enabled_state(false)

	if not data.unit:character_damage():bleed_out() then
		my_data.invulnerable = true

		data.unit:character_damage():set_invulnerable(true)
	end

	if data.objective then
		data.objective_failed_clbk(data.unit, data.objective, true)
		data.unit:brain():set_objective(nil)
	end
end

function TeamAILogicDisabled.exit(data, new_logic_name, enter_params)
	TeamAILogicBase.exit(data, new_logic_name, enter_params)

	local my_data = data.internal_data
	my_data.exiting = true

	TeamAILogicDisabled._unregister_revive_SO(my_data)

	if my_data.invulnerable then
		data.unit:character_damage():set_invulnerable(false)
	end

	CopLogicBase.cancel_queued_tasks(my_data)

	if my_data.best_cover then
		managers.navigation:release_cover(my_data.best_cover[1])
	end

	if my_data.nearest_cover then
		managers.navigation:release_cover(my_data.nearest_cover[1])
	end

	if new_logic_name ~= "inactive" then
		data.unit:brain():set_update_enabled_state(true)
	end
end

function TeamAILogicDisabled._upd_enemy_detection(data)
	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local delay = CopLogicBase._upd_attention_obj_detection(data, AIAttentionObject.REACT_SURPRISED, nil)
	local new_attention, new_prio_slot, new_reaction = TeamAILogicIdle._get_priority_attention(data, data.detected_attention_objects, nil, data.cool)

	TeamAILogicBase._set_attention_obj(data, new_attention, new_reaction)
	TeamAILogicDisabled._upd_aim(data, my_data)
	CopLogicBase.queue_task(my_data, my_data.detection_task_key, TeamAILogicDisabled._upd_enemy_detection, data, data.t + delay)
end

function TeamAILogicDisabled.on_intimidated(data, amount, aggressor_unit)
end

function TeamAILogicDisabled._consider_surrender(data, my_data)
	my_data.stay_cool_chk_t = TimerManager:game():time()
	local my_health_ratio = data.unit:character_damage():health_ratio()

	if my_health_ratio < 0.1 then
		return
	end

	local my_health = my_health_ratio * data.unit:character_damage()._HEALTH_BLEEDOUT_INIT
	local total_scare = 0

	for e_key, e_data in pairs(data.detected_attention_objects) do
		if e_data.verified and e_data.unit:in_slot(data.enemy_slotmask) then
			local scare = tweak_data.character[e_data.unit:base()._tweak_table].HEALTH_INIT / my_health
			scare = scare * (1 - math.clamp(e_data.verified_dis - 300, 0, 2500) / 2500)
			total_scare = total_scare + scare
		end
	end

	for c_key, c_data in pairs(managers.groupai:state():all_player_criminals()) do
		if not c_data.status then
			local support = tweak_data.player.damage.HEALTH_INIT / my_health
			local dis = mvector3.distance(c_data.m_pos, data.m_pos)

			if dis < 700 then
				total_scare = 0

				break
			end

			support = 3 * support * (1 - math.clamp(dis - 300, 0, 2500) / 2500)
			total_scare = total_scare - support
		end
	end

	if total_scare > 1 then
		my_data.stay_cool = true

		if my_data.firing then
			data.unit:movement():set_allow_fire(false)

			my_data.firing = nil
		end
	else
		my_data.stay_cool = false
	end
end

function TeamAILogicDisabled._upd_aim(data, my_data)
	local shoot, aim = nil
	local focus_enemy = data.attention_obj

	if my_data.stay_cool then
		-- Nothing
	elseif focus_enemy then
		if focus_enemy.verified then
			if focus_enemy.verified_dis < 2000 or my_data.alert_t and data.t - my_data.alert_t < 7 then
				shoot = true
			end
		elseif focus_enemy.verified_t and data.t - focus_enemy.verified_t < 10 then
			aim = true

			if my_data.shooting and data.t - focus_enemy.verified_t < 3 then
				shoot = true
			end
		elseif focus_enemy.verified_dis < 600 and my_data.walking_to_cover_shoot_pos then
			aim = true
		end
	end

	if aim or shoot then
		if focus_enemy.verified then
			if my_data.attention_unit ~= focus_enemy.u_key then
				CopLogicBase._set_attention(data, focus_enemy)

				my_data.attention_unit = focus_enemy.u_key
			end
		elseif my_data.attention_unit ~= focus_enemy.verified_pos then
			CopLogicBase._set_attention_on_pos(data, mvector3.copy(focus_enemy.verified_pos))

			my_data.attention_unit = mvector3.copy(focus_enemy.verified_pos)
		end
	else
		if my_data.shooting then
			local new_action = nil

			if data.unit:anim_data().reload then
				new_action = {
					body_part = 3,
					type = "reload"
				}
			else
				new_action = {
					body_part = 3,
					type = "idle"
				}
			end

			data.unit:brain():action_request(new_action)
		end

		if my_data.attention_unit then
			CopLogicBase._reset_attention(data)

			my_data.attention_unit = nil
		end
	end

	if shoot then
		if not my_data.firing then
			data.unit:movement():set_allow_fire(true)

			my_data.firing = true
		end
	elseif my_data.firing then
		data.unit:movement():set_allow_fire(false)

		my_data.firing = nil
	end
end

function TeamAILogicDisabled.on_recovered(data, reviving_unit)
	local my_data = data.internal_data

	if reviving_unit and my_data.rescuer and my_data.rescuer:key() == reviving_unit:key() then
		my_data.rescuer = nil
	else
		TeamAILogicDisabled._unregister_revive_SO(my_data)
	end

	local objective = data.objective

	if objective and objective.forced and objective.path_style == "warp" then
		CopLogicBase._exit(data.unit, "travel")
	else
		CopLogicBase._exit(data.unit, "assault")
	end
end

function TeamAILogicDisabled._register_revive_SO(data, my_data, rescue_type)
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
	local objective = {
		type = "revive",
		called = true,
		scan = true,
		destroy_clbk_key = false,
		follow_unit = data.unit,
		nav_seg = data.unit:movement():nav_tracker():nav_segment(),
		fail_clbk = callback(TeamAILogicDisabled, TeamAILogicDisabled, "on_revive_SO_failed", data),
		action = {
			align_sync = true,
			type = "act",
			body_part = 1,
			variant = rescue_type,
			blocks = {
				light_hurt = -1,
				hurt = -1,
				action = -1,
				heavy_hurt = -1,
				aim = -1,
				walk = -1
			}
		},
		action_duration = tweak_data.interaction[data.name == "surrender" and "free" or "revive"].timer,
		followup_objective = followup_objective
	}
	local so_descriptor = {
		interval = 6,
		search_dis_sq = 1000000,
		AI_group = "friendlies",
		base_chance = 1,
		chance_inc = 0,
		usage_amount = 1,
		objective = objective,
		search_pos = mvector3.copy(data.m_pos),
		admin_clbk = callback(TeamAILogicDisabled, TeamAILogicDisabled, "on_revive_SO_administered", data)
	}
	local so_id = "TeamAIrevive" .. tostring(data.key)
	my_data.SO_id = so_id

	managers.groupai:state():add_special_objective(so_id, so_descriptor)

	my_data.deathguard_SO_id = PlayerBleedOut._register_deathguard_SO(data.unit)
end

function TeamAILogicDisabled._unregister_revive_SO(my_data)
	if my_data.deathguard_SO_id then
		PlayerBleedOut._unregister_deathguard_SO(my_data.deathguard_SO_id)

		my_data.deathguard_SO_id = nil
	end

	if my_data.rescuer then
		local rescuer = my_data.rescuer
		my_data.rescuer = nil

		if rescuer:brain():objective() then
			managers.groupai:state():on_criminal_objective_failed(rescuer, rescuer:brain():objective())
		end
	elseif my_data.SO_id then
		managers.groupai:state():remove_special_objective(my_data.SO_id)

		my_data.SO_id = nil
	end
end

function TeamAILogicDisabled.is_available_for_assignment(data, new_objective)
	return false
end

function TeamAILogicDisabled.damage_clbk(data, damage_info)
	local my_data = data.internal_data

	if data.unit:character_damage():need_revive() and not my_data.SO_id and not my_data.rescuer then
		TeamAILogicDisabled._register_revive_SO(data, my_data, "revive")
	end

	if damage_info.result.type == "fatal" then
		CopLogicBase.cancel_queued_tasks(my_data)

		if not my_data.invulnerable then
			my_data.invulnerable = true

			data.unit:character_damage():set_invulnerable(true)
		end
	end

	TeamAILogicIdle.damage_clbk(data, damage_info)
end

function TeamAILogicDisabled.on_revive_SO_administered(ignore_this, data, receiver_unit)
	local my_data = data.internal_data
	my_data.rescuer = receiver_unit
	my_data.SO_id = nil
end

function TeamAILogicDisabled.on_revive_SO_failed(ignore_this, data)
	local my_data = data.internal_data

	if my_data.rescuer and (data.unit:character_damage():need_revive() or data.unit:character_damage():arrested()) and not my_data.exiting then
		my_data.rescuer = nil

		TeamAILogicDisabled._register_revive_SO(data, my_data, "revive")
	end
end

function TeamAILogicDisabled.on_new_objective(data, old_objective)
	TeamAILogicBase.on_new_objective(data, old_objective)

	if old_objective and old_objective.fail_clbk then
		old_objective.fail_clbk(data.unit)
	end
end
