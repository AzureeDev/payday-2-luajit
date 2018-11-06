TeamAILogicInactive = class(TeamAILogicBase)

function TeamAILogicInactive.enter(data, new_logic_name, enter_params)
	TeamAILogicBase.enter(data, new_logic_name, enter_params)
	data.brain:rem_all_pos_rsrv()
	CopLogicBase._set_attention_obj(data, nil, nil)
	CopLogicBase._destroy_all_detected_attention_object_data(data)
	CopLogicBase._reset_attention(data)

	data.internal_data = {}

	data.unit:brain():set_update_enabled_state(false)

	if data.objective then
		data.objective_failed_clbk(data.unit, data.objective, true)
		data.unit:brain():set_objective(nil)
	end
end

function TeamAILogicInactive.exit(data, new_logic_name, enter_params)
	TeamAILogicBase.exit(data, new_logic_name, enter_params)
	data.unit:brain():set_update_enabled_state(true)

	local my_data = data.internal_data

	TeamAILogicBase.cancel_delayed_clbks(my_data)
end

function TeamAILogicInactive.is_available_for_assignment(data)
	return false
end
