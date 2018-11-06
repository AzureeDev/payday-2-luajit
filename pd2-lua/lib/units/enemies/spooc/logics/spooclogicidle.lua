SpoocLogicIdle = class(CopLogicIdle)

function SpoocLogicIdle._upd_enemy_detection(data)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local delay = CopLogicBase._upd_attention_obj_detection(data, nil, nil)
	local new_attention, new_prio_slot, new_reaction = CopLogicIdle._get_priority_attention(data, data.detected_attention_objects)

	CopLogicBase._set_attention_obj(data, new_attention, new_reaction)

	if new_reaction and AIAttentionObject.REACT_SUSPICIOUS < new_reaction then
		local objective = data.objective
		local wanted_state = nil
		local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, objective, nil, new_attention)

		if allow_trans then
			wanted_state = CopLogicBase._get_logic_state_from_reaction(data)
		end

		if wanted_state and wanted_state ~= data.name then
			if obj_failed then
				data.objective_failed_clbk(data.unit, data.objective)
			end

			if my_data == data.internal_data then
				CopLogicBase._exit(data.unit, wanted_state)
			end
		end
	end

	if my_data ~= data.internal_data then
		return delay
	end

	CopLogicBase._chk_call_the_police(data)

	if my_data ~= data.internal_data then
		return delay
	end

	SpoocLogicIdle._chk_exit_hiding(data)

	if my_data ~= data.internal_data then
		return delay
	end

	return delay
end

function SpoocLogicIdle.damage_clbk(data, damage_info)
	local res = SpoocLogicIdle.super.damage_clbk(data, damage_info)

	if data.unit:anim_data().hide then
		SpoocLogicIdle._exit_hiding(data)
	end

	return res
end

function SpoocLogicIdle._exit_hiding(data)
	data.unit:set_objective({
		type = "act",
		action = {
			variant = "idle",
			body_part = 1,
			type = "act",
			blocks = {
				heavy_hurt = -1,
				idle = -1,
				action = -1,
				turn = -1,
				light_hurt = -1,
				walk = -1,
				fire_hurt = -1,
				hurt = -1,
				expl_hurt = -1
			}
		}
	})
end

function SpoocLogicIdle._chk_exit_hiding(data)
	if data.attention_obj and AIAttentionObject.REACT_SHOOT <= data.attention_obj.reaction and data.unit:anim_data().hide_loop then
		if data.attention_obj.dis < 1500 and data.attention_obj.verified then
			SpoocLogicIdle._exit_hiding(data)
		elseif data.attention_obj.dis < 700 then
			local my_nav_seg_id = data.unit:movement():nav_tracker():nav_segment()
			local enemy_areas = managers.groupai:state():get_areas_from_nav_seg_id(data.attention_obj.nav_tracker:nav_segment())

			for _, area in ipairs(enemy_areas) do
				if area.nav_segs[my_nav_seg_id] then
					SpoocLogicIdle._exit_hiding(data)

					break
				end
			end
		end
	end
end
