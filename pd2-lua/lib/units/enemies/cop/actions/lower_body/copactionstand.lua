CopActionStand = CopActionStand or class()

function CopActionStand:init(action_desc, common_data)
	self._ext_movement = common_data.ext_movement

	if common_data.active_actions[2] and common_data.active_actions[2]._nav_link then
		debug_pause_unit(common_data.unit, "interrupted nav_link!", common_data.unit, inspect(action_desc), common_data.machine:segment_state(Idstring("base")), inspect(common_data.ext_movement._active_actions[2]))

		return
	end

	local enter_t = nil
	local ext_anim = common_data.ext_anim
	self._ext_anim = ext_anim

	if ext_anim.move then
		local ids_base = Idstring("base")
		local seg_rel_t = common_data.machine:segment_relative_time(ids_base)
		local walk_anim_length = nil

		if ext_anim.run_start_turn then
			local move_side = ext_anim.move_side
			walk_anim_length = common_data.ext_movement._actions.walk._walk_anim_lengths.stand[common_data.stance.name].run_start_turn[move_side]
		elseif ext_anim.run_start then
			local move_side = ext_anim.move_side
			walk_anim_length = common_data.ext_movement._actions.walk._walk_anim_lengths.stand[common_data.stance.name].run_start[move_side]
		elseif ext_anim.run_stop then
			local move_side = ext_anim.move_side

			if not common_data.ext_movement._actions.walk._walk_anim_lengths.stand[common_data.stance.name].run_stop then
				debug_pause_unit(common_data.unit, "[CopActionStand:init]", common_data.unit, "stance", common_data.stance.name, "anim_length", common_data.ext_movement._actions.walk._walk_anim_lengths.stand[common_data.stance.name])

				return
			end

			walk_anim_length = common_data.ext_movement._actions.walk._walk_anim_lengths.stand[common_data.stance.name].run_stop[move_side]
		else
			local pose = "stand"
			local speed = ext_anim.run and "run" or "walk"
			local side = ext_anim.move_side
			local walk_anim_lengths = common_data.ext_movement._actions.walk._walk_anim_lengths
			local walk_pose_tbl = walk_anim_lengths and walk_anim_lengths[pose][common_data.stance.name]
			local walk_speed_tbl = walk_pose_tbl and walk_pose_tbl[speed]
			walk_anim_length = walk_speed_tbl and walk_speed_tbl[side] or 29
		end

		enter_t = seg_rel_t * walk_anim_length
	end

	local redir_result = common_data.ext_movement:play_redirect("stand", enter_t)

	if redir_result then
		if Network:is_server() then
			common_data.ext_network:send("set_pose", 1)
		end

		self._ext_movement:enable_update()

		return true
	else
		cat_print("george", "[CopActionStand:init] failed in", common_data.machine:segment_state(Idstring("base")), common_data.unit)
	end
end

function CopActionStand:update(t)
	if self._ext_anim.base_need_upd then
		self._ext_movement:upd_m_head_pos()
	else
		self._expired = true
	end
end

function CopActionStand:expired()
	return self._expired
end

function CopActionStand:type()
	return "stand"
end
