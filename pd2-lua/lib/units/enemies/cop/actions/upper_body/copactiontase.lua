CopActionTase = CopActionTase or class()
local temp_vec1 = Vector3()
local temp_vec2 = Vector3()

function CopActionTase:init(action_desc, common_data)
	self._common_data = common_data
	self._unit = common_data.unit
	self._ext_movement = common_data.ext_movement
	self._ext_anim = common_data.ext_anim
	self._ext_brain = common_data.ext_brain
	self._ext_inventory = common_data.ext_inventory
	self._body_part = action_desc.body_part
	self._machine = common_data.machine
	self._modifier_name = Idstring("action_upper_body")
	self._modifier = self._machine:get_modifier(self._modifier_name)
	local attention = common_data.attention

	if (not attention or not attention.unit) and Network:is_server() then
		debug_pause("[CopActionTase:init] no attention", inspect(action_desc))

		return
	end

	local weapon_unit = self._ext_inventory:equipped_unit()

	self:on_attention(attention)

	if Network:is_server() then
		self._ext_movement:set_stance_by_code(3)
	end

	CopActionAct._create_blocks_table(self, action_desc.block_desc)

	return true
end

function CopActionTase:expired()
	return self._expired
end

function CopActionTase:on_attention(attention)
	if self._expired then
		self._attention = attention
	elseif Network:is_server() then
		if self._attention then
			if self._discharging then
				self._tasing_local_unit:movement():on_tase_ended()

				self._discharging = nil
			end

			if self._tasing_local_unit and self._tasing_player then
				self._attention.unit:movement():on_targetted_for_attack(false, self._unit)
			end

			self._tasing_player = nil
			self._tasing_local_unit = nil
			self._expired = true
			self.update = self._upd_empty
			self._attention = attention

			return
		end
	else
		if self._client_attention_set or not attention or not attention.unit then
			if self._discharging then
				self._tasing_local_unit:movement():on_tase_ended()

				self._discharging = nil
			end

			if self._tasing_local_unit and self._tasing_player then
				self._tasing_local_unit:movement():on_targetted_for_attack(false, self._unit)
			end

			self._tasing_player = nil
			self._tasing_local_unit = nil
			self._attention = attention
			self.update = self._upd_empty

			return
		end

		self._client_attention_set = true
	end

	local attention_unit = attention.unit
	self.update = nil
	local weapon_unit = self._ext_inventory:equipped_unit()
	local weap_tweak = weapon_unit:base():weapon_tweak_data()
	local weapon_usage_tweak = self._common_data.char_tweak.weapon[weap_tweak.usage]
	self._weap_tweak = weap_tweak
	self._w_usage_tweak = weapon_usage_tweak
	self._falloff = weapon_usage_tweak.FALLOFF
	self._turn_allowed = Network:is_client()
	self._attention = attention
	local t = TimerManager:game():time()
	local target_pos = attention.handler and attention.handler:get_attention_m_pos() or attention_unit:movement():m_head_pos()
	local shoot_from_pos = self._ext_movement:m_head_pos()
	local target_vec = target_pos - shoot_from_pos

	self._modifier:set_target_y(target_vec)

	local aim_delay = weapon_usage_tweak.aim_delay_tase or weapon_usage_tweak.aim_delay
	local lerp_dis = math.min(1, target_vec:length() / self._falloff[#self._falloff].r)
	local shoot_delay = math.lerp(aim_delay[1], aim_delay[2], lerp_dis)
	self._mod_enable_t = t + shoot_delay
	self._tasing_local_unit = nil
	self._tasing_player = nil

	if Network:is_server() then
		self._common_data.ext_network:send("action_tase_event", 1)

		if not attention_unit:base().is_husk_player then
			self._shoot_t = TimerManager:game():time() + shoot_delay
			self._tasing_local_unit = attention_unit
			self._line_of_fire_slotmask = managers.slot:get_mask("bullet_impact_targets_no_criminals")
			self._tasing_player = attention_unit:base().is_local_player
		end
	elseif attention_unit:base().is_local_player then
		self._shoot_t = TimerManager:game():time() + shoot_delay
		self._tasing_local_unit = attention_unit
		self._line_of_fire_slotmask = managers.slot:get_mask("bullet_impact_targets")
		self._tasing_player = true
	end

	if self._tasing_local_unit and self._tasing_player then
		self._tasing_local_unit:movement():on_targetted_for_attack(true, self._unit)
	end
end

function CopActionTase:save(save_data)
	save_data.type = "tase"
	save_data.body_part = self._body_part
end

function CopActionTase:on_exit()
	if self._tase_effect then
		World:effect_manager():fade_kill(self._tase_effect)
	end

	if self._discharging then
		self._tasing_local_unit:movement():on_tase_ended()
	end

	if Network:is_server() then
		self._ext_movement:set_stance_by_code(2)
	end

	if self._modifier_on then
		self._machine:allow_modifier(self._modifier_name)
	end

	if Network:is_server() then
		self._unit:network():send("action_tase_event", 2)

		if self._expired then
			self._ext_movement:action_request({
				body_part = 3,
				type = "idle"
			})
		end
	end

	if self._tasered_sound then
		self._tasered_sound:stop()
		self._unit:sound():play("tasered_3rd_stop", nil)
	end

	if self._tasing_local_unit and self._tasing_player then
		self._attention.unit:movement():on_targetted_for_attack(false, self._unit)
	end

	if self._malfunction_clbk_id then
		managers.enemy:remove_delayed_clbk(self._malfunction_clbk_id)

		self._malfunction_clbk_id = nil
	end
end

function CopActionTase:on_destroy()
	if self._tase_effect then
		World:effect_manager():fade_kill(self._tase_effect)
	end

	if self._malfunction_clbk_id then
		managers.enemy:remove_delayed_clbk(self._malfunction_clbk_id)

		self._malfunction_clbk_id = nil
	end
end

function CopActionTase:update(t)
	if self._expired then
		return
	end

	local shoot_from_pos = self._ext_movement:m_head_pos()
	local target_dis = nil
	local target_vec = temp_vec1
	local target_pos = temp_vec2

	self._attention.unit:character_damage():shoot_pos_mid(target_pos)

	target_dis = mvector3.direction(target_vec, shoot_from_pos, target_pos)
	local target_vec_flat = target_vec:with_z(0)

	mvector3.normalize(target_vec_flat)

	local fwd_dot = mvector3.dot(self._common_data.fwd, target_vec_flat)

	if fwd_dot > 0.7 then
		if not self._modifier_on then
			self._modifier_on = true

			self._machine:force_modifier(self._modifier_name)

			self._mod_enable_t = t + 0.5
		end

		self._modifier:set_target_y(target_vec)
	else
		if self._modifier_on then
			self._modifier_on = nil

			self._machine:allow_modifier(self._modifier_name)
		end

		if self._turn_allowed and not self._ext_anim.walk and not self._ext_anim.turn and not self._ext_movement:chk_action_forbidden("walk") then
			local spin = target_vec:to_polar_with_reference(self._common_data.fwd, math.UP).spin
			local abs_spin = math.abs(spin)

			if abs_spin > 27 then
				local new_action_data = {
					type = "turn",
					body_part = 2,
					angle = spin
				}

				self._ext_movement:action_request(new_action_data)
			end
		end

		target_vec = nil
	end

	if not self._ext_anim.reload then
		if self._ext_anim.equip then
			-- Nothing
		elseif self._discharging then
			local vis_ray = self._unit:raycast("ray", shoot_from_pos, target_pos, "slot_mask", self._line_of_fire_slotmask, "sphere_cast_radius", self._w_usage_tweak.tase_sphere_cast_radius, "ignore_unit", self._tasing_local_unit, "report")

			if not self._tasing_local_unit:movement():tased() or vis_ray then
				if Network:is_server() then
					self._expired = true
				else
					self._tasing_local_unit:movement():on_tase_ended()
					self._attention.unit:movement():on_targetted_for_attack(false, self._unit)

					self._discharging = nil
					self._tasing_player = nil
					self._tasing_local_unit = nil
					self.update = self._upd_empty
				end
			end
		elseif self._shoot_t and target_vec and self._common_data.allow_fire and self._shoot_t < t and self._mod_enable_t < t then
			if self._tase_effect then
				World:effect_manager():fade_kill(self._tase_effect)
			end

			self._tase_effect = World:effect_manager():spawn({
				force_synch = true,
				effect = Idstring("effects/payday2/particles/character/taser_thread"),
				parent = self._ext_inventory:equipped_unit():get_object(Idstring("fire"))
			})

			if self._tasing_local_unit and mvector3.distance(shoot_from_pos, target_pos) < self._w_usage_tweak.tase_distance then
				local record = managers.groupai:state():criminal_record(self._tasing_local_unit:key())

				if not record or record.status or self._tasing_local_unit:movement():chk_action_forbidden("hurt") or self._tasing_local_unit:movement():zipline_unit() then
					if Network:is_server() then
						self._expired = true
					end
				else
					local vis_ray = self._unit:raycast("ray", shoot_from_pos, target_pos, "slot_mask", self._line_of_fire_slotmask, "sphere_cast_radius", self._w_usage_tweak.tase_sphere_cast_radius, "ignore_unit", self._tasing_local_unit, "report")

					if not vis_ray then
						self._common_data.ext_network:send("action_tase_event", 3)

						local attack_data = {
							attacker_unit = self._unit
						}

						self._attention.unit:character_damage():damage_tase(attack_data)
						CopDamage._notify_listeners("on_criminal_tased", self._unit, self._attention.unit)

						self._discharging = true

						if not self._tasing_local_unit:base().is_local_player then
							self._tasered_sound = self._unit:sound():play("tasered_3rd", nil)
						end

						local redir_res = self._ext_movement:play_redirect("recoil")

						if redir_res then
							self._machine:set_parameter(redir_res, "hvy", 0)
						end

						self._shoot_t = nil
					end
				end
			elseif not self._tasing_local_unit then
				self._tasered_sound = self._unit:sound():play("tasered_3rd", nil)
				local redir_res = self._ext_movement:play_redirect("recoil")

				if redir_res then
					self._machine:set_parameter(redir_res, "hvy", 0)
				end

				self._shoot_t = nil
			end
		end
	end
end

function CopActionTase:type()
	return "tase"
end

function CopActionTase:fire_taser()
	self._shoot_t = 0
end

function CopActionTase:chk_block(action_type, t)
	return CopActionAct.chk_block(self, action_type, t)
end

function CopActionTase:_upd_empty(t)
end

function CopActionTase:need_upd()
	return true
end

function CopActionTase:get_husk_interrupt_desc()
	local action_desc = {
		block_type = "action",
		body_part = 3,
		type = "tase"
	}

	return action_desc
end

function CopActionTase:clbk_malfunction()
	self._malfunction_clbk_id = nil

	if self._expired then
		return
	end

	World:effect_manager():spawn({
		effect = Idstring("effects/payday2/particles/character/taser_stop"),
		position = self._ext_movement:m_head_pos(),
		normal = math.UP
	})

	local action_data = {
		damage = 0,
		variant = "melee",
		damage_effect = self._unit:character_damage()._HEALTH_INIT * 10,
		attacker_unit = managers.player:player_unit() or self._unit,
		attack_dir = -self._common_data.fwd,
		col_ray = {
			position = mvector3.copy(self._ext_movement:m_head_pos()),
			body = self._unit:body("body")
		}
	}

	self._unit:character_damage():damage_melee(action_data)
end
