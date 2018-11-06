CopActionIdle = CopActionIdle or class()
local mvec3_dir = mvector3.direction
local mvec3_rot = mvector3.rotate_with
local mvec3_dot = mvector3.dot
local mrot_set_lookat = mrotation.set_look_at
local mrot_slerp = mrotation.slerp
local mrot_y = mrotation.y
local tmp_rot = Rotation()
local idstr_look_upper_body = Idstring("look_upper_body")
local idstr_look_head = Idstring("look_head")
local idstr_head = Idstring("Head")

function CopActionIdle:init(action_desc, common_data)
	if action_desc.non_persistent then
		return
	end

	self._common_data = common_data
	self._unit = common_data.unit
	self._ext_movement = common_data.ext_movement
	self._ext_anim = common_data.ext_anim
	self._body_part = action_desc.body_part
	self._machine = common_data.machine

	if Network:is_client() then
		self._turn_allowed = true
		self._start_fwd = common_data.rot:y()
	end

	local res = nil

	if self._body_part == 3 then
		if self._ext_anim.upper_body_active and not self._ext_anim.upper_body_empty then
			res = self._ext_movement:play_redirect("up_idle")
		end
	elseif action_desc.anim then
		local state_name = self._machine:index_to_state_name(action_desc.anim)
		local redir_res = self._ext_movement:play_state_idstr(state_name)

		if not redir_res then
			print("[CopActionIdle:init] state", state_name, "failed in", self._machine:segment_state(Idstring("base")), common_data.unit)
		end
	elseif not self._ext_anim.idle then
		if self._common_data.stance.code == 1 then
			res = self._ext_movement:play_redirect("exit")
		else
			res = self._ext_movement:play_redirect("idle")
		end

		self._ext_movement:enable_update()
	end

	if res == false then
		debug_pause_unit(self._unit, "[CopActionIdle:init] idle failed in", self._machine:segment_state(Idstring("base")), self._machine:segment_state(Idstring("upper_body")), self._unit)

		return
	end

	self._modifier_name = self._unit:anim_data().ik_type == "head" and idstr_look_head or idstr_look_upper_body
	self._modifier = self._machine:get_modifier(self._modifier_name)

	self:on_attention(common_data.attention)

	if (self._body_part == 1 or self._body_part == 2) and Network:is_server() then
		local stand_rsrv = self._unit:brain():get_pos_rsrv("stand")

		if not stand_rsrv or mvector3.distance_sq(stand_rsrv.position, common_data.pos) > 400 then
			self._unit:brain():add_pos_rsrv("stand", {
				radius = 30,
				position = mvector3.copy(common_data.pos)
			})
		end
	end

	if action_desc.sync then
		self._common_data.ext_network:send("action_idle_start", self._body_part)
	end

	CopActionAct._create_blocks_table(self, action_desc.blocks)
	self:_init_ik()

	return true
end

function CopActionIdle:_init_ik()
	if managers.job:current_level_id() == "chill" then
		self._look_vec = mvector3.copy(self._common_data.fwd)
		self._ik_update = callback(self, self, "_ik_update_func")
		self._m_head_pos = self._ext_movement:m_head_pos()
		local player_unit = managers.player:player_unit()
		self._ik_data = player_unit
	end
end

function CopActionIdle:_ik_update_func(t)
	CopActionAct._ik_update_func(self, t)
end

function CopActionIdle:_update_ik_type()
	local new_ik_type = self._ext_anim.ik_type

	if self._ik_type ~= new_ik_type then
		if self._modifier_on then
			self._machine:forbid_modifier(self._modifier_name)

			self._modifier_on = nil
		end

		if new_ik_type == "head" then
			self._ik_type = new_ik_type
			self._modifier_name = Idstring("look_head")
			self._modifier = self._machine:get_modifier(self._modifier_name)
		elseif new_ik_type == "upper_body" then
			self._ik_type = new_ik_type
			self._modifier_name = Idstring("look_upper_body")
			self._modifier = self._machine:get_modifier(self._modifier_name)
		else
			self._ik_type = nil
		end
	end
end

function CopActionIdle:on_exit()
	if self._modifier_on then
		self._modifier_on = nil

		self._machine:forbid_modifier(self._modifier_name)
	end

	if self._modifier:blend() > 0 and self._look_vec then
		mvector3.set(self._common_data.look_vec, self._look_vec)
	end
end

function CopActionIdle:update(t)
	if self._ik_update then
		self._ik_update(t)
	end

	if self._attention then
		local ik_enable = true
		local look_from_pos = self._ext_movement:m_head_pos()
		local target_vec = self._look_vec

		if self._attention.handler then
			mvec3_dir(target_vec, look_from_pos, self._attention.handler:get_detection_m_pos())
		elseif self._attention.unit then
			mvec3_dir(target_vec, look_from_pos, self._attention.unit:movement():m_head_pos())
		else
			mvec3_dir(target_vec, look_from_pos, self._attention.pos)
		end

		if self._look_trans then
			local look_trans = self._look_trans
			local prog = (t - look_trans.start_t) / look_trans.duration

			if prog > 1 then
				self._look_trans = nil
			else
				local prog_smooth = math.bezier({
					0,
					0,
					1,
					1
				}, prog)

				mrot_set_lookat(tmp_rot, target_vec, math.UP)
				mrot_slerp(tmp_rot, look_trans.start_rot, tmp_rot, prog_smooth)
				mrot_y(tmp_rot, target_vec)

				if mvec3_dot(target_vec, self._common_data.fwd) < 0.2 then
					ik_enable = false
				end
			end
		elseif mvec3_dot(target_vec, self._common_data.fwd) < 0.2 then
			ik_enable = false
		end

		if ik_enable then
			if not self._modifier_on then
				self._modifier_on = true

				self._machine:force_modifier(self._modifier_name)
			end

			if self._turn_allowed then
				local active_actions = self._common_data.active_actions
				local queued_actions = self._common_data.queued_actions

				if not active_actions[1] and not active_actions[2] and (not queued_actions or not queued_actions[1] and not queued_actions[2]) and not self._ext_movement:chk_action_forbidden("walk") then
					local spin = target_vec:to_polar_with_reference(self._common_data.fwd, math.UP).spin

					if math.abs(spin) > 70 then
						self._rot_offset = -spin
						local new_action_data = {
							body_part = 2,
							type = "turn",
							angle = spin
						}

						self._ext_movement:action_request(new_action_data)
					end
				end
			end
		elseif self._modifier_on then
			self._modifier_on = false

			self._machine:forbid_modifier(self._modifier_name)
		end

		self._modifier:set_target_z(target_vec)
	elseif self._rot_offset then
		local new_action_data = {
			body_part = 2,
			type = "turn",
			angle = self._start_fwd:to_polar_with_reference(self._common_data.fwd, math.UP).spin
		}

		self._ext_movement:action_request(new_action_data)

		self._rot_offset = nil
	end

	if self._ext_anim.base_need_upd then
		self._ext_movement:upd_m_head_pos()
	end
end

function CopActionIdle:type()
	return "idle"
end

function CopActionIdle:on_attention(attention)
	if self._body_part ~= 1 and self._body_part ~= 3 then
		return
	end

	if attention then
		self._m_attention_head_pos = attention and (attention.handler and attention.handler:get_attention_m_pos() or attention.unit and attention.unit:movement():m_head_pos())
		local shoot_from_pos = self._ext_movement:m_head_pos()
		local target_vec = Vector3()

		if attention then
			if attention.handler then
				mvec3_dir(target_vec, shoot_from_pos, attention.handler:get_detection_m_pos())
			elseif attention.unit then
				mvec3_dir(target_vec, shoot_from_pos, attention.unit:movement():m_head_pos())
			else
				mvec3_dir(target_vec, shoot_from_pos, attention.pos)
			end
		end

		local start_vec = nil

		if self._modifier:blend() > 0 then
			start_vec = self._look_vec or self._common_data.look_vec
		else
			start_vec = self._unit:get_object(idstr_head):rotation():z()
		end

		local duration = math.lerp(0.35, 1, target_vec:angle(start_vec) / 180)
		local start_rot = Rotation()

		mrot_set_lookat(start_rot, start_vec, math.UP)

		self._look_trans = {
			start_t = TimerManager:game():time(),
			duration = duration,
			start_rot = start_rot
		}

		self._ext_movement:enable_update()

		self._look_vec = mvector3.copy(start_vec)
	else
		self._modifier_on = nil

		self._machine:forbid_modifier(self._modifier_name)

		if self._modifier:blend() > 0 and self._look_vec then
			mvector3.set(self._common_data.look_vec, self._look_vec)
		end
	end

	self._attention = attention

	self._ext_movement:enable_update()
end

function CopActionIdle:need_upd()
	return self._attention and (self._attention.unit or self._look_trans) and true or false
end

function CopActionIdle:save(save_data)
	if self._body_part == 1 then
		save_data.is_save = true
		save_data.type = "idle"
		save_data.body_part = 1
		local state_name = self._machine:segment_state(Idstring("base"))
		local state_index = self._machine:state_name_to_index(state_name)
		save_data.anim = state_index
	end
end
