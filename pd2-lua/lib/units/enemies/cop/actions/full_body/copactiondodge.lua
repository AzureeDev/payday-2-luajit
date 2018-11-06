CopActionDodge = CopActionDodge or class()
CopActionDodge._apply_freefall = CopActionWalk._apply_freefall
CopActionDodge._VARIATIONS = {
	"side_step",
	"dive",
	"roll",
	"wheel"
}
CopActionDodge._SIDES = {
	"fwd",
	"bwd",
	"l",
	"r"
}

function CopActionDodge:init(action_desc, common_data)
	self._common_data = common_data
	self._ext_base = common_data.ext_base
	self._ext_movement = common_data.ext_movement
	self._ext_anim = common_data.ext_anim
	self._body_part = action_desc.body_part
	self._unit = common_data.unit
	self._timeout = action_desc.timeout
	self._machine = common_data.machine
	self._ids_base = Idstring("base")
	local redir_name = "dodge"
	local redir_res = self._ext_movement:play_redirect(redir_name)

	if redir_res then
		self._descriptor = action_desc
		self._last_vel_z = 0

		self:_determine_rotation_transition()
		self._ext_movement:set_root_blend(false)
		self._machine:set_parameter(redir_res, action_desc.variation, 1)

		if action_desc.speed then
			self._machine:set_speed(redir_res, action_desc.speed)
		end

		self._machine:set_parameter(redir_res, action_desc.side, 1)

		if Network:is_server() then
			local accuracy = math.clamp(math.floor((action_desc.shoot_accuracy or 1) * 10) / 10, 0, 10)

			common_data.ext_network:send("action_dodge_start", self._body_part, CopActionDodge._get_variation_index(action_desc.variation), CopActionDodge._get_side_index(action_desc.side), Rotation(action_desc.direction, math.UP):yaw(), action_desc.speed or 1, accuracy)
		end

		self._ext_movement:enable_update()

		return true
	else
		debug_pause_unit(self._unit, "[CopActionDodge:init] redirect", redir_name, "failed in", self._machine:segment_state(Idstring("base")), common_data.unit)

		return
	end
end

function CopActionDodge:on_exit()
	if Network:is_client() then
		self._ext_movement:set_m_host_stop_pos(self._ext_movement:m_pos())
	elseif not self._expired then
		self._common_data.ext_network:send("action_dodge_end")
	end
end

function CopActionDodge:update(t)
	if self._ext_anim.dodge then
		local dt = TimerManager:game():delta_time()
		self._last_pos = CopActionHurt._get_pos_clamped_to_graph(self)

		CopActionWalk._set_new_pos(self, dt)

		local new_rot = nil

		if self._rot_transition then
			local anim_rel_t = self._machine:segment_relative_time(self._ids_base)
			local rot_prog = anim_rel_t / self._rot_transition.end_anim_t

			if rot_prog > 1 then
				new_rot = self._rot_transition.end_rot
				self._rot_transition = nil
			else
				new_rot = self._rot_transition.start_rot:slerp(self._rot_transition.end_rot, rot_prog)
			end
		else
			new_rot = self._unit:get_animation_delta_rotation()
			new_rot = self._common_data.rot * new_rot

			mrotation.set_yaw_pitch_roll(new_rot, new_rot:yaw(), 0, 0)
		end

		self._ext_movement:set_rotation(new_rot)
	else
		self._expired = true
	end
end

function CopActionDodge:type()
	return "dodge"
end

function CopActionDodge:expired()
	return self._expired
end

function CopActionDodge:need_upd()
	return true
end

function CopActionDodge:chk_block(action_type, t)
	if action_type == "death" or action_type == "bleedout" or action_type == "fatal" then
		return false
	end

	return true
end

function CopActionDodge:timeout()
	return self._timeout
end

function CopActionDodge._get_variation_index(var_name)
	for index, test_var_name in ipairs(CopActionDodge._VARIATIONS) do
		if var_name == test_var_name then
			return index
		end
	end
end

function CopActionDodge.get_variation_name(var_index)
	return CopActionDodge._VARIATIONS[var_index]
end

function CopActionDodge._get_side_index(side_name)
	for index, test_side_name in ipairs(CopActionDodge._SIDES) do
		if side_name == test_side_name then
			return index
		end
	end
end

function CopActionDodge.get_side_name(side_index)
	return CopActionDodge._SIDES[side_index]
end

function CopActionDodge:_determine_rotation_transition()
	local wanted_side = self._descriptor.side
	local end_rot = Rotation(self._descriptor.direction, math.UP)

	if wanted_side == "bwd" then
		mrotation.set_yaw_pitch_roll(end_rot, mrotation.yaw(end_rot) + 180, 0, 0)
	elseif wanted_side == "l" then
		mrotation.set_yaw_pitch_roll(end_rot, mrotation.yaw(end_rot) - 90, 0, 0)
	elseif wanted_side == "r" then
		mrotation.set_yaw_pitch_roll(end_rot, mrotation.yaw(end_rot) + 90, 0, 0)
	end

	self._rot_transition = {
		end_anim_t = 0.3,
		end_rot = end_rot,
		start_rot = self._unit:rotation()
	}
end

function CopActionDodge:accuracy_multiplier()
	return self._descriptor.shoot_accuracy or 1
end
