local mvec3_dir = mvector3.direction
local tmp_rot1 = Rotation()
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
SentryGunMovement = SentryGunMovement or class()
SentryGunMovement.set_friendly_fire = PlayerMovement.set_friendly_fire
SentryGunMovement.friendly_fire = PlayerMovement.friendly_fire

function SentryGunMovement:init(unit)
	self._unit = unit
	self._head_obj = self._unit:get_object(Idstring("a_detect"))
	self._spin_obj = self._unit:get_object(Idstring(self._spin_obj_name))
	self._pitch_obj = self._unit:get_object(Idstring(self._pitch_obj_name))
	self._m_rot = unit:rotation()
	self._m_head_fwd = self._m_rot:y()
	self._unit_up = self._m_rot:z()
	self._unit_fwd = self._m_rot:y()
	self._m_head_pos = self._head_obj:position()
	self._vel = {
		pitch = 0,
		spin = 0
	}

	if managers.navigation:is_data_ready() then
		self._nav_tracker = managers.navigation:create_nav_tracker(self._unit:position())
		self._pos_reservation = {
			radius = 30,
			position = self._unit:position()
		}

		managers.navigation:add_pos_reservation(self._pos_reservation)
	else
		Application:error("[SentryGunBase:setup] Spawned Sentry gun unit with incomplete navigation data.")
	end

	self._sound_source = self._unit:sound_source()
	self._last_attention_t = 0
	self._warmup_t = 0
	self._rot_speed_mul = 1

	self:_set_state("inactive")
end

function SentryGunMovement:post_init()
	self._ext_network = self._unit:network()
	self._tweak = tweak_data.weapon[self._unit:base():get_name_id()]

	if self._tweak.VELOCITY_COMPENSATION then
		self._m_last_attention_pos = Vector3()
		self._m_last_attention_vel = Vector3()
	end

	self:set_team(managers.groupai:state():team_data(tweak_data.levels:get_default_team_ID("player")))
end

function SentryGunMovement:update(unit, t, dt)
	self._updator(t, dt)
end

function SentryGunMovement:_update_inactive(t, dt)
	self:_upd_hacking(t, dt)
end

function SentryGunMovement:_update_active(t, dt)
	self:_upd_hacking(t, dt)
	self:_upd_mutables()

	if self._warmup_t < t then
		self:_upd_movement(dt)
	end
end

function SentryGunMovement:_update_activating(t, dt)
	self:_upd_mutables()

	if not self._unit:anim_is_playing(self._activation_anim_group_name_ids) then
		if self._rearming then
			self:_set_state("rearming")
		else
			self:_set_state("active")
		end

		self._unit:weapon():update_laser()

		if managers.game_play_central:flashlights_on() and self._lights_on_sequence_name then
			self._unit:damage():run_sequence_simple(self._lights_on_sequence_name)
		end
	end
end

function SentryGunMovement:_update_inactivating(t, dt)
	self:_upd_mutables()

	if not self._unit:anim_is_playing(self._activation_anim_group_name_ids) then
		self:_set_state("inactive")
		self._unit:weapon():update_laser()
	end
end

function SentryGunMovement:_update_rearming(t, dt)
	if self._rearm_complete_t and self._rearm_complete_t < t then
		self:complete_rearming()
	end
end

function SentryGunMovement:complete_rearming()
	if Network:is_server() then
		self._unit:weapon():set_ammo(self._tweak.CLIP_SIZE)
	end

	if self._rearm_complete_snd_event then
		self._sound_source:post_event(self._rearm_complete_snd_event)

		self._rearm_event = nil
	end

	self:_set_state("active")
	self._unit:weapon():update_laser()
end

function SentryGunMovement:_update_repairing(t, dt)
	if self._repair_complete_t then
		local repair_complete_ratio = 1 - (self._repair_complete_t - t) / self._tweak.AUTO_REPAIR_DURATION

		self._unit:character_damage():update_shield_smoke_level(repair_complete_ratio, true)

		if self._repair_complete_t < t then
			self:complete_repairing()
		end
	end
end

function SentryGunMovement:complete_repairing()
	if self._repair_complete_seq then
		self._unit:damage():run_sequence_simple(self._repair_complete_seq)
	end

	self:_set_state("active")

	if Network:is_server() then
		self._unit:character_damage():repair_shield()
		self._unit:network():send("turret_complete_repairing")
	end
end

function SentryGunMovement:setup(rot_speed_multiplier)
	self._rot_speed_mul = rot_speed_multiplier

	self:_set_state("active")
end

function SentryGunMovement:on_activated()
	self._tweak = tweak_data.weapon[self._unit:base():get_name_id()]

	if self._tweak.VELOCITY_COMPENSATION and not self._m_last_attention_pos then
		self._m_last_attention_pos = Vector3()
		self._m_last_attention_vel = Vector3()
	end

	if self._unit:damage() and self._unit:damage():has_sequence("activate") and self._activation_anim_group_name then
		self._activation_anim_group_name_ids = Idstring(self._activation_anim_group_name)

		self._unit:damage():run_sequence_simple("activate")
		self:_set_state("activating")
	end
end

function SentryGunMovement:set_active(state)
	self._unit:set_extension_update_enabled(Idstring("movement"), state)

	if not state then
		if self._motor_sound then
			self._motor_sound:stop()

			self._motor_sound = false
		end

		if self._rearm_event then
			self._rearm_event:stop()

			self._rearm_event = false
		end
	end
end

function SentryGunMovement:set_idle(state)
	if not state then
		if self._unit:damage() and self._unit:damage():has_sequence("deactivate") and self._activation_anim_group_name then
			self._activation_anim_group_name_ids = Idstring(self._activation_anim_group_name)

			self._unit:damage():run_sequence_simple("deactivate")
			self:_set_state("inactivating")
		end
	elseif self._unit:damage() and self._unit:damage():has_sequence("activate") and self._activation_anim_group_name then
		self._activation_anim_group_name_ids = Idstring(self._activation_anim_group_name)

		self._unit:damage():run_sequence_simple("activate")
		self:_set_state("activating")
	end

	self._unit:weapon():update_laser()
end

function SentryGunMovement:nav_tracker()
	return self._nav_tracker
end

function SentryGunMovement:set_attention(attention)
	if not attention and not self._attention then
		return
	end

	if attention and self._attention then
		local different = nil

		for i, k in pairs(self._attention) do
			if attention[i] ~= k then
				different = true

				break
			end
		end

		if not different then
			for i, k in pairs(attention) do
				if self._attention[i] ~= k then
					different = true

					break
				end
			end
		end

		if not different then
			return
		end
	end

	CopMovement._remove_attention_destroy_listener(self, self._attention)

	if attention then
		if attention.unit then
			if attention.handler then
				if self._m_last_attention_pos then
					mvector3.set(self._m_last_attention_pos, attention.handler:get_attention_m_pos())
					mvector3.set_zero(self._m_last_attention_vel)

					self._last_attention_snapshot_t = TimerManager:game():time() - 0.1
				end

				local attention_unit = attention.handler:unit()

				if attention_unit:id() ~= -1 then
					self._ext_network:send("set_attention", attention_unit, attention.reaction)
				else
					self._ext_network:send("cop_set_attention_pos", mvector3.copy(attention.handler:get_attention_m_pos()))
				end
			else
				local attention_unit = attention.unit

				if self._m_last_attention_pos then
					attention_unit:character_damage():shoot_pos_mid(self._m_last_attention_pos)
					mvector3.set_zero(self._m_last_attention_vel)

					self._last_attention_snapshot_t = TimerManager:game():time() - 0.1
				end

				if attention_unit:id() ~= -1 then
					self._ext_network:send("set_attention", attention_unit, AIAttentionObject.REACT_IDLE)
				end
			end

			CopMovement._add_attention_destroy_listener(self, attention)
		else
			self._ext_network:send("cop_set_attention_pos", attention.pos)
		end
	elseif self._attention and self._unit:id() ~= -1 then
		self._ext_network:send("set_attention", nil, AIAttentionObject.REACT_IDLE)
	end

	self._attention = attention

	self:chk_play_alert(attention, self._attention)
end

function SentryGunMovement:synch_attention(attention)
	CopMovement._remove_attention_destroy_listener(self, self._attention)
	CopMovement._add_attention_destroy_listener(self, attention)

	if attention and attention.unit and not attention.destroy_listener_key then
		debug_pause_unit(attention.unit, "[SentryGunMovement:synch_attention] problematic attention unit", attention.unit)
		self:synch_attention(nil)

		return
	end

	if attention and attention.unit then
		if attention.handler then
			if self._m_last_attention_pos then
				mvector3.set(self._m_last_attention_pos, attention.handler:get_attention_m_pos())
				mvector3.set_zero(self._m_last_attention_vel)

				self._last_attention_snapshot_t = TimerManager:game():time() - 0.1
			end
		else
			local attention_unit = attention.unit

			if self._m_last_attention_pos then
				attention_unit:character_damage():shoot_pos_mid(self._m_last_attention_pos)
				mvector3.set_zero(self._m_last_attention_vel)

				self._last_attention_snapshot_t = TimerManager:game():time() - 0.1
			end
		end
	end

	self._attention = attention

	self:chk_play_alert(attention, self._attention)
end

function SentryGunMovement:chk_play_alert(attention, old_attention)
	if not attention and old_attention then
		self._last_attention_t = TimerManager:game():time()
	end

	if attention and not old_attention and TimerManager:game():time() - self._last_attention_t > 3 then
		self._sound_source:post_event(self._attention_acquired_snd_event)

		self._warmup_t = TimerManager:game():time() + 0.5
	end
end

function SentryGunMovement:attention()
	return self._attention
end

function SentryGunMovement:attention_unit_destroy_clbk(unit)
	if Network:is_server() then
		self:set_attention()
	else
		self:synch_attention()
	end
end

function SentryGunMovement:_upd_mutables()
	self._head_obj:m_position(self._m_head_pos)
	self._unit:m_rotation(self._m_rot)
	self._head_obj:m_rotation(tmp_rot1)
	mrotation.y(tmp_rot1, self._m_head_fwd)
	mrotation.y(self._m_rot, self._unit_fwd)
	mrotation.z(self._m_rot, self._unit_up)
end

function SentryGunMovement:m_head_pos()
	return self._m_head_pos
end

function SentryGunMovement:m_com()
	return self._m_head_pos
end

function SentryGunMovement:m_pos()
	return self._m_head_pos
end

function SentryGunMovement:m_detect_pos()
	return self._m_head_pos
end

function SentryGunMovement:m_stand_pos()
	return self._m_head_pos
end

function SentryGunMovement:m_head_fwd()
	return self._m_head_fwd
end

function SentryGunMovement:set_look_vec3(look_vec3)
	mvector3.set(self._m_head_fwd, look_vec3)

	local look_rel_polar = look_vec3:to_polar_with_reference(self._unit_fwd, self._unit_up)

	self._spin_obj:set_local_rotation(Rotation(look_rel_polar.spin, 0, 0))
	self._pitch_obj:set_local_rotation(Rotation(0, look_rel_polar.pitch, 0))
	self._unit:set_moving(true)
end

function SentryGunMovement:_upd_movement(dt)
	local target_dir = self:_get_target_dir(self._attention, dt)
	local unit_fwd_polar = self._unit_fwd:to_polar()
	local fwd_polar = self._m_head_fwd:to_polar_with_reference(self._unit_fwd, self._unit_up)
	local error_polar = target_dir:to_polar_with_reference(self._unit_fwd, self._unit_up)
	error_polar = Polar(1, math.clamp(error_polar.pitch, self._pitch_min, self._pitch_max), error_polar.spin)
	error_polar = error_polar - fwd_polar

	local function _ramp_value(value, err, vel, slowdown_at, max_vel, min_vel, acc)
		local sign_err = math.sign(err)
		local abs_err = math.abs(err)
		local wanted_vel = nil

		if abs_err < slowdown_at then
			wanted_vel = math.lerp(min_vel, max_vel, abs_err / slowdown_at) * sign_err
		else
			wanted_vel = max_vel * sign_err
		end

		local err_vel = wanted_vel - vel
		local sign_err_vel = math.sign(err_vel)
		local abs_err_vel = math.abs(err_vel)
		local abs_delta_vel = math.min(acc * dt, abs_err_vel)
		local delta_vel = abs_delta_vel * sign_err_vel
		local new_vel = vel + delta_vel
		local at_end = nil
		local correction = new_vel * dt

		if math.abs(err) <= math.abs(correction) and math.sign(correction) == math.sign(err) then
			new_vel = 0
			correction = err
			at_end = true
		end

		local new_val = value + correction

		return at_end, new_vel, new_val
	end

	local pitch_end, spin_end, new_vel, new_spin, new_pitch = nil
	spin_end, new_vel, new_spin = _ramp_value(fwd_polar.spin, error_polar.spin, self._vel.spin, self._tweak.SLOWDOWN_ANGLE_SPIN, self._tweak.MAX_VEL_SPIN * self._rot_speed_mul, self._tweak.MIN_VEL_SPIN, self._tweak.ACC_SPIN * self._rot_speed_mul)
	self._vel.spin = new_vel
	local new_vel_abs = math.abs(new_vel)
	local vel_ratio = math.clamp(1.5 * (new_vel_abs - self._tweak.MIN_VEL_SPIN) / (self._tweak.MAX_VEL_SPIN - self._tweak.MIN_VEL_SPIN), 0, 1)

	if vel_ratio > 0.5 then
		if not self._motor_sound then
			self._motor_sound = self._sound_source:post_event(self._spin_start_snd_event)
		end
	elseif vel_ratio == 0 and self._motor_sound then
		self._sound_source:post_event(self._spin_stop_snd_event)
		self._motor_sound:stop()

		self._motor_sound = false
	end

	pitch_end, new_vel, new_pitch = _ramp_value(fwd_polar.pitch, error_polar.pitch, self._vel.pitch, self._tweak.SLOWDOWN_ANGLE_PITCH, self._tweak.MAX_VEL_PITCH * self._rot_speed_mul, self._tweak.MIN_VEL_PITCH, self._tweak.ACC_PITCH * self._rot_speed_mul)
	self._vel.pitch = new_vel
	local new_fwd_polar = Polar(1, new_pitch, new_spin)
	local new_fwd_vec3 = new_fwd_polar:to_vector()

	mvector3.rotate_with(new_fwd_vec3, Rotation(math.UP, 90))
	mvector3.rotate_with(new_fwd_vec3, self._m_rot)
	self:set_look_vec3(new_fwd_vec3)

	if pitch_end and spin_end and self._switched_off then
		self:set_active(false)
	end
end

function SentryGunMovement:_upd_hacking(t, dt)
	if not self._tweak.ECM_HACKABLE then
		return
	end

	local is_hacking_active = nil

	if Network:is_server() then
		is_hacking_active = managers.groupai:state():is_ecm_jammer_active("camera")
	elseif self._team.id == "hacked_turret" then
		is_hacking_active = true
	end

	if self._is_hacked then
		if not is_hacking_active then
			self._is_hacked = nil

			if Network:is_server() then
				local original_team = self._original_team
				self._original_team = nil

				self:set_team(original_team)
			end

			if self._hacked_stop_snd_event then
				self._sound_source:post_event(self._hacked_stop_snd_event)
			end

			if Network:is_server() then
				self._unit:brain():on_hacked_end()
			end
		end
	elseif is_hacking_active then
		self._is_hacked = true

		if Network:is_server() then
			local original_team = self._team

			self:set_team(managers.groupai:state():team_data("hacked_turret"))

			self._original_team = original_team
		end

		if self._hacked_start_snd_event then
			self._sound_source:post_event(self._hacked_start_snd_event)
		end

		if Network:is_server() then
			self._unit:brain():on_hacked_start()
		end
	end
end

function SentryGunMovement:give_recoil()
	local recoil_tweak = self._tweak.recoil
	local th = recoil_tweak.horizontal
	local recoil_pitch = math.rand(th[1], th[2]) * math.random(th[3], th[4])
	local tv = recoil_tweak.vertical
	local recoil_spin = math.rand(tv[1], tv[2]) * math.random(tv[3], tv[4])
	local unit_fwd_polar = self._unit_fwd:to_polar()
	local fwd_polar = self._m_head_fwd:to_polar_with_reference(self._unit_fwd, self._unit_up)
	local recoil_polar = Polar(recoil_pitch, recoil_spin, 0)
	local new_pitch = fwd_polar.pitch + recoil_pitch
	local new_spin = fwd_polar.spin + recoil_spin
	local new_fwd_polar = Polar(1, new_pitch, new_spin)
	local new_fwd_vec3 = new_fwd_polar:to_vector()

	mvector3.rotate_with(new_fwd_vec3, Rotation(math.UP, 90))
	mvector3.rotate_with(new_fwd_vec3, self._m_rot)
	self:set_look_vec3(new_fwd_vec3)
end

function SentryGunMovement:_get_target_dir(attention, dt)
	if not attention then
		if self._switched_off then
			mvector3.set(tmp_vec2, self._unit_fwd)
			mvector3.rotate_with(tmp_vec2, self._switch_off_rot)

			return tmp_vec2
		else
			return self._unit_fwd
		end
	else
		local target_pos = tmp_vec1

		if attention.handler then
			if self._m_last_attention_pos then
				mvector3.set(target_pos, self._m_last_attention_vel)
				mvector3.multiply(target_pos, self._tweak.VELOCITY_COMPENSATION.SNAPSHOT_INTERVAL)
				mvector3.add(target_pos, self._m_last_attention_pos)
			else
				mvector3.set(target_pos, attention.handler:get_attention_m_pos())
			end
		elseif attention.unit then
			if self._m_last_attention_pos then
				mvector3.set(target_pos, self._m_last_attention_vel)
				mvector3.multiply(target_pos, self._tweak.VELOCITY_COMPENSATION.SNAPSHOT_INTERVAL)
				mvector3.add(target_pos, self._m_last_attention_pos)
				attention.unit:character_damage():shoot_pos_mid(self._m_last_attention_pos)
			else
				attention.unit:character_damage():shoot_pos_mid(target_pos)
			end
		else
			target_pos = attention.pos
		end

		if attention.unit and self._m_last_attention_pos and TimerManager:game():time() > self._last_attention_snapshot_t + self._tweak.VELOCITY_COMPENSATION.SNAPSHOT_INTERVAL then
			mvector3.set(self._m_last_attention_vel, self._m_last_attention_pos)

			if attention.handler then
				mvector3.set(self._m_last_attention_pos, attention.handler:get_attention_m_pos())
			else
				attention.unit:character_damage():shoot_pos_mid(self._m_last_attention_pos)
			end

			mvector3.subtract(self._m_last_attention_vel, self._m_last_attention_pos)
			mvector3.divide(self._m_last_attention_vel, self._last_attention_snapshot_t - TimerManager:game():time())

			self._last_attention_snapshot_t = TimerManager:game():time()
		end

		local target_vec = tmp_vec2

		mvec3_dir(target_vec, self._m_head_pos, target_pos)

		return target_vec
	end
end

function SentryGunMovement:tased()
	return false
end

function SentryGunMovement:on_death()
	self._unit:set_extension_update_enabled(Idstring("movement"), false)
	self._unit:weapon():set_laser_enabled(nil, nil)
end

function SentryGunMovement:synch_allow_fire(...)
	self._unit:brain():synch_allow_fire(..., true)
end

function SentryGunMovement:warming_up(t)
	return t < self._warmup_t
end

function SentryGunMovement:is_activating()
	return self._state == "activating"
end

function SentryGunMovement:is_inactivating()
	return self._state == "inactivating"
end

function SentryGunMovement:is_inactivated()
	return self._state == "inactive"
end

function SentryGunMovement:switch_off()
	self._switched_off = true
	self._switch_off_rot = Rotation(self._m_rot:x(), -35)
end

function SentryGunMovement:switch_on()
	self._switched_off = false

	self:set_active(true)
end

function SentryGunMovement:_set_state(state)
	self._state = state
	self._updator = callback(self, self, "_update_" .. state)
end

function SentryGunMovement:save(save_data)
	local my_save_data = {}
	save_data.movement = my_save_data

	if self._attention then
		if self._attention.pos then
			my_save_data.attention = self._attention
		elseif self._attention.unit:id() == -1 then
			local attention_pos = self._attention.handler and self._attention.handler:get_detection_m_pos() or self._attention.unit:movement() and self._attention.unit:movement():m_com() or self._unit:position()
			my_save_data.attention = {
				pos = attention_pos
			}
		else
			managers.enemy:add_delayed_clbk("clbk_sync_attention" .. tostring(self._unit:key()), callback(self, CopMovement, "clbk_sync_attention", self._attention), TimerManager:game():time() + 0.1)
		end
	end

	if self._rot_speed_mul ~= 1 then
		my_save_data.rot_speed_mul = self._rot_speed_mul
	end

	my_save_data.team = self._team.id
	my_save_data.state = self._state
end

function SentryGunMovement:load(save_data)
	if not save_data or not save_data.movement then
		return
	end

	local my_save_data = save_data.movement
	self._rot_speed_mul = my_save_data.rot_speed_mul or 1
	self._tweak = tweak_data.weapon[self._unit:base():get_name_id()]

	if self._tweak.VELOCITY_COMPENSATION and not self._m_last_attention_pos then
		self._m_last_attention_pos = Vector3()
		self._m_last_attention_vel = Vector3()
	end

	if my_save_data.attention then
		self._attention = my_save_data.attention
	end

	self._team = managers.groupai:state():team_data(my_save_data.team)

	managers.groupai:state():add_listener("SentryGunMovement_team_def_" .. tostring(self._unit:key()), {
		"team_def"
	}, callback(self, self, "clbk_team_def"))
	self:_set_state(my_save_data.state)
	self._unit:weapon():update_laser()
end

function SentryGunMovement:clbk_team_def()
	self._team = managers.groupai:state():team_data(self._team.id)

	managers.groupai:state():remove_listener("SentryGunMovement_team_def_" .. tostring(self._unit:key()))
end

function SentryGunMovement:set_team(team_data)
	if self._original_team then
		self._original_team = team_data

		return
	end

	self._team = team_data

	self._unit:weapon():on_team_set(team_data)
	self._unit:brain():on_team_set(team_data)

	if Network:is_server() and self._unit:id() ~= -1 then
		local team_index = tweak_data.levels:get_team_index(team_data.id)

		if team_index <= 256 then
			self._ext_network:send("sync_char_team", team_index)
		else
			debug_pause_unit(self._unit, "[SentryGunMovement:set_team] team limit reached!", team_data.id)
		end
	end

	self._unit:weapon():update_laser()

	local turret_units = managers.groupai:state():turrets()

	if turret_units and table.contains(turret_units, self._unit) then
		if self._unit:movement():team().foes[tweak_data.levels:get_default_team_ID("player")] then
			self._unit:contour():remove("mark_unit_friendly", false)
		else
			self._unit:contour():add("mark_unit_friendly", false)
		end
	end
end

function SentryGunMovement:team()
	return self._team
end

function SentryGunMovement:cool()
	return managers.groupai:state():whisper_mode()
end

function SentryGunMovement:not_cool_t()
	return not managers.groupai:state():whisper_mode() and managers.groupai:state():whisper_mode_change_t()
end

function SentryGunMovement:rearming()
	return self._state == "rearming"
end

function SentryGunMovement:rearm()
	self:_set_state("rearming")

	if Network:is_server() then
		self._rearm_complete_t = TimerManager:game():time() + self._tweak.AUTO_RELOAD_DURATION
	end

	self._vel.pitch = 0
	self._vel.spin = 0

	if self._rearm_snd_event then
		self._rearm_event = self._sound_source:post_event(self._rearm_snd_event)
	end

	self._unit:weapon():update_laser()
end

function SentryGunMovement:repairing()
	return self._state == "repairing"
end

function SentryGunMovement:repair()
	self:_set_state("repairing")

	if self._repair_start_seq then
		self._unit:damage():run_sequence_simple(self._repair_start_seq)
	end

	if Network:is_server() then
		self._repair_complete_t = TimerManager:game():time() + self._tweak.AUTO_REPAIR_DURATION

		self._unit:network():send("turret_repair")
	end
end

function SentryGunMovement:pre_destroy()
	if Network:is_server() then
		self:set_attention()
	else
		self:synch_attention()
	end

	if self._nav_tracker then
		managers.navigation:destroy_nav_tracker(self._nav_tracker)

		self._nav_tracker = nil
	end

	if self._pos_reservation then
		managers.navigation:unreserve_pos(self._pos_reservation)

		self._pos_reservation = nil
	end
end
