CopActionTurn = CopActionTurn or class()
local tmp_rot = Rotation()
local mrot_set_ypr = mrotation.set_yaw_pitch_roll

function CopActionTurn:init(action_desc, common_data)
	self._common_data = common_data
	self._ext_movement = common_data.ext_movement
	self._ext_anim = common_data.ext_anim
	self._ext_base = common_data.ext_base
	self._machine = common_data.machine
	self._action_desc = action_desc
	self._start_pos = mvector3.copy(common_data.pos)

	if not self._ext_anim.idle then
		local redir_res = self._ext_movement:play_redirect("idle")

		if not redir_res then
			debug_pause("[CopActionTurn:init] idle redirect failed in", self._machine:segment_state(Idstring("base")))

			return false
		end
	end

	self.update = self._upd_wait_full_blend

	self._ext_movement:enable_update()
	CopActionAct._create_blocks_table(self, action_desc.blocks)

	return true
end

function CopActionTurn:on_exit()
	self._common_data.unit:set_driving("script")
	self._ext_movement:set_root_blend(true)
	self._ext_movement:set_position(self._start_pos)

	local end_rot = self._common_data.rot

	mrot_set_ypr(tmp_rot, mrotation.yaw(end_rot), 0, 0)
	self._ext_movement:set_rotation(tmp_rot)
end

function CopActionTurn:update(t)
	if not self._ext_anim.turn and self._ext_anim.idle_full_blend then
		self._expired = true
	end

	self._ext_movement:set_m_rot(self._common_data.unit:rotation())
end

function CopActionTurn:_upd_wait_full_blend(t)
	if self._ext_anim.idle_full_blend then
		local angle = self._action_desc.angle
		local dir_str = angle > 0 and "l" or "r"
		local redir_name = "turn_" .. dir_str
		local redir_res = self._ext_movement:play_redirect(redir_name)

		if redir_res then
			local abs_angle = math.abs(angle)

			if abs_angle > 135 then
				self._machine:set_parameter(redir_res, "angle135", 1)
			elseif abs_angle > 90 then
				local lerp = (abs_angle - 90) / 45

				self._machine:set_parameter(redir_res, "angle135", lerp)
				self._machine:set_parameter(redir_res, "angle90", 1 - lerp)
			elseif abs_angle > 45 then
				local lerp = (abs_angle - 45) / 45

				self._machine:set_parameter(redir_res, "angle90", lerp)
				self._machine:set_parameter(redir_res, "angle45", 1 - lerp)
			else
				self._machine:set_parameter(redir_res, "angle45", 1)
			end

			local vis_state = self._ext_base:lod_stage() or 4

			if vis_state > 1 then
				self._machine:set_speed(redir_res, vis_state)
			end

			self._common_data.unit:set_driving("animation")
			self._ext_movement:set_root_blend(false)
			self._ext_base:chk_freeze_anims()

			self.update = nil

			self:update(t)
		else
			cat_print("george", "[CopActionTurn:update] ", redir_name, " redirect failed in", self._machine:segment_state(Idstring("base")))

			self._expired = true
		end
	end
end

function CopActionTurn:type()
	return "turn"
end

function CopActionTurn:expired()
	return self._expired
end

function CopActionTurn:need_upd()
	return true
end
