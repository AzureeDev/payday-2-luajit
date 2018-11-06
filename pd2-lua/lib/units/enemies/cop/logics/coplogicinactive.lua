CopLogicInactive = class(CopLogicBase)

function CopLogicInactive.enter(data, new_logic_name, enter_params)
	CopLogicBase.enter(data, new_logic_name, enter_params)

	local old_internal_data = data.internal_data
	data.internal_data = {}
	local my_data = data.internal_data

	if data.has_outline then
		data.unit:contour():remove("highlight")

		data.has_outline = nil
	end

	if data.is_converted then
		data.unit:contour():remove("friendly", true)
	end

	local attention_obj = data.attention_obj

	CopLogicBase._set_attention_obj(data, nil, nil)
	CopLogicBase._destroy_all_detected_attention_object_data(data)
	CopLogicBase._reset_attention(data)

	for c_key, c_data in pairs(managers.groupai:state():all_char_criminals()) do
		if c_data.engaged[data.key] then
			debug_pause_unit(data.unit, "inactive AI engaging player", data.unit, c_data.unit, inspect(attention_obj), inspect(data.attention_obj))
		end
	end

	data.brain:rem_all_pos_rsrv()

	if data.objective and data.objective.type == "follow" and data.objective.destroy_clbk_key then
		data.objective.follow_unit:base():remove_destroy_listener(data.objective.destroy_clbk_key)

		data.objective.destroy_clbk_key = nil
	end

	data.unit:brain():set_update_enabled_state(false)

	if data.objective then
		my_data.removing_objective = true

		data.unit:brain():set_objective(nil)

		my_data.removing_objective = nil
	end

	data.logic._register_attention(data, my_data)
	data.logic._set_interaction(data, my_data)
end

function CopLogicInactive.exit(data, new_logic_name, enter_params)
	CopLogicBase.exit(data, new_logic_name, enter_params)
	data.unit:brain():set_update_enabled_state(true)

	local my_data = data.internal_data

	CopLogicBase.cancel_delayed_clbks(my_data)
end

function CopLogicInactive.is_available_for_assignment(data)
	return false
end

function CopLogicInactive.on_enemy_weapons_hot(data)
	local my_data = data.internal_data

	data.unit:brain():set_attention_settings({
		corpse_cbt = true
	})

	if data.unit:interaction():active() then
		data.unit:interaction():set_active(false, true, true)
	end
end

function CopLogicInactive._register_attention(data, my_data)
	if data.unit:character_damage():dead() then
		if managers.groupai:state():enemy_weapons_hot() then
			data.unit:brain():set_attention_settings({
				corpse_cbt = true
			})
		else
			data.unit:brain():set_attention_settings({
				corpse_sneak = true
			})
		end
	else
		data.unit:brain():set_attention_settings(nil)
	end
end

function CopLogicInactive._set_interaction(data, my_data)
	if data.unit:character_damage():dead() and managers.groupai:state():whisper_mode() then
		if data.unit:unit_data().has_alarm_pager then
			data.brain:begin_alarm_pager()
		else
			data.unit:interaction():set_tweak_data("corpse_dispose")
			data.unit:interaction():set_active(true, true, true)
		end
	end
end

function CopLogicInactive.on_new_objective(data, old_objective)
	if not data.internal_data.removing_objective then
		debug_pause_unit(data.unit, "[CopLogicInactive.on_new_objective]", data.unit, "new_objective", data.objective and inspect(data.objective), "old_objective", old_objective and inspect(old_objective))
	end

	CopLogicBase.on_new_objective(data, old_objective)

	if old_objective and old_objective.fail_clbk then
		old_objective.fail_clbk(data.unit)
	end
end
