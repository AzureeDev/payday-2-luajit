SecurityCamera = SecurityCamera or class()
SecurityCamera.cameras = SecurityCamera.cameras or {}
SecurityCamera.active_tape_loop_unit = nil
SecurityCamera.is_security_camera = true
SecurityCamera._NET_EVENTS = {
	suspicion_4 = 6,
	start_tape_loop_2 = 10,
	suspicion_1 = 3,
	start_tape_loop_1 = 9,
	suspicion_2 = 4,
	request_start_tape_loop_1 = 11,
	request_start_tape_loop_2 = 12,
	alarm_start = 2,
	deactivate_tape_loop = 13,
	suspicion_5 = 7,
	suspicion_6 = 8,
	suspicion_3 = 5,
	sound_off = 1
}
local tmp_rot1 = Rotation()

function SecurityCamera:init(unit)
	self._unit = unit
	self._set_access_camera_enabled = true

	self:set_update_enabled(false)
	self:_set_driving_state(self.update_position)
	table.insert(SecurityCamera.cameras, self._unit)
end

function SecurityCamera:_update_tape_loop_restarting(unit, t, dt)
	if self._tape_loop_restarting_t then
		local v = math.round((math.sin(t * 500) + 1) / 2)

		if v == 0 and not self._tape_loop_active_contour then
			self._tape_loop_active_contour = true

			self._unit:contour():add("mark_unit_friendly")
		elseif v == 1 and self._tape_loop_active_contour then
			self._tape_loop_active_contour = false

			self._unit:contour():remove("mark_unit_friendly")
		end

		if self._tape_loop_restarting_t < t then
			self:_deactivate_tape_loop_restart()
		end
	end
end

function SecurityCamera:update(unit, t, dt)
	self:_update_tape_loop_restarting(unit, t, dt)

	if not Network:is_server() then
		return
	end

	if managers.groupai:state():is_ecm_jammer_active("camera") or self._tape_loop_expired_clbk_id or self._tape_loop_restarting_t then
		self:_destroy_all_detected_attention_object_data()
		self:_stop_all_sounds()
	else
		self:_upd_detection(t)
	end

	self:_upd_sound(unit, t)
end

function SecurityCamera:set_update_enabled(state)
	self._unit:set_extension_update_enabled(Idstring("base"), state)
end

function SecurityCamera:set_detection_enabled(state, settings, mission_element)
	if self._destroyed then
		return
	end

	self:set_update_enabled(state)

	self._mission_script_element = mission_element or self._mission_script_element

	if state then
		self._u_key = self._unit:key()
		self._last_detect_t = self._last_detect_t or TimerManager:game():time()
		self._detection_interval = 0.1
		self._SO_access_str = "security"
		self._SO_access = managers.navigation:convert_access_filter_to_number({
			self._SO_access_str
		})
		self._visibility_slotmask = managers.slot:get_mask("AI_visibility")

		if settings then
			self._cone_angle = settings.fov
			self._detection_delay = settings.detection_delay
			self._range = settings.detection_range
			self._suspicion_range = settings.suspicion_range
			self._team = managers.groupai:state():team_data(settings.team_id or tweak_data.levels:get_default_team_ID("combatant"))
		end

		self._detected_attention_objects = self._detected_attention_objects or {}
		self._look_obj = self._unit:get_object(Idstring("CameraLens"))
		self._yaw_obj = self._unit:get_object(Idstring("CameraYaw"))
		self._pitch_obj = self._unit:get_object(Idstring("CameraPitch"))
		self._pos = self._yaw_obj:position()
		self._look_fwd = nil
		self._tmp_vec1 = self._tmp_vec1 or Vector3()
		self._suspicion_lvl_sync = 0
	else
		self._last_detect_t = nil

		self:_destroy_all_detected_attention_object_data()

		self._brush = nil
		self._visibility_slotmask = nil
		self._detection_delay = nil
		self._look_obj = nil
		self._yaw_obj = nil
		self._pitch_obj = nil
		self._pos = nil
		self._look_fwd = nil
		self._tmp_vec1 = nil
		self._detected_attention_objects = nil
		self._suspicion_lvl_sync = nil
		self._team = nil

		if not self._destroying then
			self:_stop_all_sounds()
			self:_deactivate_tape_loop()
		end
	end

	if settings then
		self:apply_rotations(settings.yaw, settings.pitch)
	end

	managers.groupai:state():register_security_camera(self._unit, state)
end

function SecurityCamera:apply_rotations(yaw, pitch)
	local yaw_obj = self._yaw_obj or self._unit:get_object(Idstring("CameraYaw"))
	local pitch_obj = self._pitch_obj or self._unit:get_object(Idstring("CameraPitch"))
	local original_yaw_rot = yaw_obj:local_rotation()
	local new_yaw_rot = Rotation(180 + yaw, original_yaw_rot:pitch(), original_yaw_rot:roll())

	yaw_obj:set_local_rotation(new_yaw_rot)

	local original_pitch_rot = pitch_obj:local_rotation()
	local new_pitch_rot = Rotation(original_pitch_rot:yaw(), pitch, original_pitch_rot:roll())

	pitch_obj:set_local_rotation(new_pitch_rot)

	self._look_fwd = nil

	self._unit:set_moving()

	if Network:is_server() then
		local sync_yaw = 255 * (yaw + 180) / 360
		local sync_pitch = 255 * (pitch + 90) / 180

		managers.network:session():send_to_peers_synched("camera_yaw_pitch", self._unit, sync_yaw, sync_pitch)
	end

	self._yaw = yaw
	self._pitch = pitch
end

function SecurityCamera:_set_driving_state(state)
	if state and self._driving ~= "animation" then
		self._unit:set_driving("animation")

		self._driving = "animation"
	elseif not state and self._driving ~= "orientation_object" then
		self._unit:set_driving("orientation_object")

		self._driving = "orientation_object"
	end
end

function SecurityCamera:set_update_position(state)
	self.update_position = state

	self:_set_driving_state(state)
end

function SecurityCamera:_upd_detection(t)
	local dt = t - self._last_detect_t

	if self._detection_interval < dt then
		self._last_detect_t = t

		if self.update_position then
			self._yaw_obj:m_position(self._pos)

			if self._look_fwd then
				self._look_obj:m_rotation(tmp_rot1)
				mrotation.y(tmp_rot1, self._look_fwd)
			end
		end

		if managers.groupai:state()._draw_enabled then
			self._brush = self._brush or Draw:brush(Color(0.2, 1, 1, 1), self._detection_interval)

			self._look_obj:m_position(self._tmp_vec1)

			local cone_base = self._look_obj:rotation():y()

			mvector3.multiply(cone_base, self._range)
			mvector3.add(cone_base, self._tmp_vec1)

			local cone_base_rad = math.tan(self._cone_angle * 0.5) * self._range

			self._brush:cone(self._tmp_vec1, cone_base, cone_base_rad, 8)
		end

		if not self._look_fwd then
			self._look_obj:m_rotation(tmp_rot1)

			self._look_fwd = Vector3()

			mrotation.y(tmp_rot1, self._look_fwd)
		end

		self:_upd_acquire_new_attention_objects(t)
		self:_upd_detect_attention_objects(t)
		self:_upd_suspicion(t)
	end
end

function SecurityCamera:_upd_acquire_new_attention_objects(t)
	local all_attention_objects = managers.groupai:state():get_AI_attention_objects_by_filter(self._SO_access_str)
	local detected_obj = self._detected_attention_objects
	local my_key = self._u_key
	local my_pos = self._pos
	local my_fwd = self._look_fwd

	for u_key, attention_info in pairs(all_attention_objects) do
		if u_key ~= my_key and not detected_obj[u_key] then
			local settings = attention_info.handler:get_attention(self._SO_access, AIAttentionObject.REACT_SUSPICIOUS, nil, self._team)

			if settings then
				local attention_pos = attention_info.handler:get_detection_m_pos()

				if self:_detection_angle_and_dis_chk(my_pos, my_fwd, attention_info.handler, settings, attention_pos) then
					local vis_ray = self._unit:raycast("ray", my_pos, attention_pos, "slot_mask", self._visibility_slotmask, "ray_type", "ai_vision")

					if not vis_ray or vis_ray.unit:key() == u_key then
						local in_cone = true

						if self._cone_angle ~= nil then
							local dir = (attention_pos - my_pos):normalized()
							in_cone = my_fwd:angle(dir) <= self._cone_angle * 0.5
						end

						if in_cone then
							detected_obj[u_key] = self:_create_detected_attention_object_data(t, u_key, attention_info, settings)
						end
					end
				end
			end
		end
	end
end

function SecurityCamera:_upd_detect_attention_objects(t)
	local detected_obj = self._detected_attention_objects
	local my_key = self._u_key
	local my_pos = self._pos
	local my_fwd = self._look_fwd
	local det_delay = self._detection_delay

	for u_key, attention_info in pairs(detected_obj) do
		if t >= attention_info.next_verify_t then
			attention_info.next_verify_t = t + (attention_info.identified and attention_info.verified and attention_info.settings.verification_interval * 1.3 or attention_info.settings.verification_interval * 0.3)

			if not attention_info.identified then
				local noticable = nil
				local angle, dis_multiplier = self:_detection_angle_and_dis_chk(my_pos, my_fwd, attention_info.handler, attention_info.settings, attention_info.handler:get_detection_m_pos())

				if angle then
					local attention_pos = attention_info.handler:get_detection_m_pos()
					local vis_ray = self._unit:raycast("ray", my_pos, attention_pos, "slot_mask", self._visibility_slotmask, "ray_type", "ai_vision")

					if not vis_ray or vis_ray.unit:key() == u_key then
						noticable = true
					end
				end

				local delta_prog = nil
				local dt = t - attention_info.prev_notice_chk_t

				if noticable then
					if angle == -1 then
						delta_prog = 1
					else
						local min_delay = det_delay[1]
						local max_delay = det_delay[2]
						local angle_mul_mod = 0.15 * math.min(angle / self._cone_angle, 1)
						local dis_mul_mod = 0.85 * dis_multiplier
						local notice_delay_mul = attention_info.settings.notice_delay_mul or 1

						if attention_info.settings.detection and attention_info.settings.detection.delay_mul then
							notice_delay_mul = notice_delay_mul * attention_info.settings.detection.delay_mul
						end

						local notice_delay_modified = math.lerp(min_delay * notice_delay_mul, max_delay, dis_mul_mod + angle_mul_mod)
						delta_prog = notice_delay_modified > 0 and dt / notice_delay_modified or 1
					end
				else
					delta_prog = det_delay[2] > 0 and -dt / det_delay[2] or -1
				end

				attention_info.notice_progress = attention_info.notice_progress + delta_prog

				if attention_info.notice_progress > 1 then
					attention_info.notice_progress = nil
					attention_info.prev_notice_chk_t = nil
					attention_info.identified = true
					attention_info.release_t = t + attention_info.settings.release_delay
					attention_info.identified_t = t
					noticable = true

					if AIAttentionObject.REACT_SCARED <= attention_info.settings.reaction then
						managers.groupai:state():on_criminal_suspicion_progress(attention_info.unit, self._unit, true)
					end
				elseif attention_info.notice_progress < 0 then
					self:_destroy_detected_attention_object_data(attention_info)

					noticable = false
				else
					noticable = attention_info.notice_progress
					attention_info.prev_notice_chk_t = t

					if AIAttentionObject.REACT_SCARED <= attention_info.settings.reaction then
						managers.groupai:state():on_criminal_suspicion_progress(attention_info.unit, self._unit, noticable)
					end
				end

				if noticable ~= false and attention_info.settings.notice_clbk then
					attention_info.settings.notice_clbk(self._unit, noticable)
				end
			end

			if attention_info.identified then
				attention_info.nearly_visible = nil
				local verified, vis_ray = nil
				local attention_pos = attention_info.handler:get_detection_m_pos()
				local dis = mvector3.distance(my_pos, attention_info.m_pos)

				if dis < self._range * 1.2 then
					local detect_pos = nil

					if attention_info.is_husk_player and attention_info.unit:anim_data().crouch then
						detect_pos = self._tmp_vec1

						mvector3.set(detect_pos, attention_info.m_pos)
						mvector3.add(detect_pos, tweak_data.player.stances.default.crouched.head.translation)
					else
						detect_pos = attention_pos
					end

					local in_FOV = self:_detection_angle_chk(my_pos, my_fwd, detect_pos, 0.8)

					if in_FOV then
						vis_ray = self._unit:raycast("ray", my_pos, detect_pos, "slot_mask", self._visibility_slotmask, "ray_type", "ai_vision")

						if not vis_ray or vis_ray.unit:key() == u_key then
							verified = true
						end
					end

					attention_info.verified = verified
				end

				attention_info.dis = dis

				if verified then
					attention_info.release_t = nil
					attention_info.verified_t = t

					mvector3.set(attention_info.verified_pos, attention_pos)

					attention_info.last_verified_pos = mvector3.copy(attention_pos)
					attention_info.verified_dis = dis
				elseif attention_info.release_t and attention_info.release_t < t then
					self:_destroy_detected_attention_object_data(attention_info)
				else
					attention_info.release_t = attention_info.release_t or t + attention_info.settings.release_delay
				end
			end
		end
	end
end

function SecurityCamera:_detection_angle_and_dis_chk(my_pos, my_fwd, handler, settings, attention_pos)
	local dis = mvector3.direction(self._tmp_vec1, my_pos, attention_pos)
	local dis_multiplier, angle_multiplier = nil
	local max_dis = math.min(self._range, settings.max_range or self._range)

	if settings.detection and settings.detection.range_mul then
		max_dis = max_dis * settings.detection.range_mul
	end

	dis_multiplier = dis / max_dis

	if dis_multiplier < 1 then
		if settings.notice_requires_FOV then
			local angle = mvector3.angle(my_fwd, self._tmp_vec1)
			local angle_max = self._cone_angle * 0.5
			angle_multiplier = angle / angle_max

			if angle_multiplier < 1 then
				return angle, dis_multiplier
			end
		else
			return 0, dis_multiplier
		end
	end
end

function SecurityCamera:_detection_angle_chk(my_pos, my_fwd, attention_pos, strictness)
	mvector3.direction(self._tmp_vec1, my_pos, attention_pos)

	local angle = mvector3.angle(my_fwd, self._tmp_vec1)
	local angle_max = self._cone_angle * 0.5

	if angle_max > angle * strictness then
		return true
	end
end

function SecurityCamera:generate_cooldown(amount)
	local mission_script_element = self._mission_script_element

	self:set_detection_enabled(false)
	managers.statistics:camera_destroyed()

	if mission_script_element then
		mission_script_element:on_destroyed(self._unit)
	end

	if self._access_camera_mission_element then
		self._access_camera_mission_element:access_camera_operation_destroy()
	end

	self._destroyed = true
end

function SecurityCamera:set_access_camera_mission_element(access_camera_mission_element)
	self._access_camera_mission_element = access_camera_mission_element
end

function SecurityCamera:get_mark_check_position()
	local obj = self._unit:get_object(Idstring("CameraLens")) or self._unit:get_object(Idstring("g_lamp"))

	return obj:position()
end

function SecurityCamera:destroyed()
	return self._destroyed
end

function SecurityCamera:_create_detected_attention_object_data(t, u_key, attention_info, settings)
	attention_info.handler:add_listener("sec_cam_" .. tostring(self._u_key), callback(self, self, "on_detected_attention_obj_modified"))
	print("[SecurityCamera] _create_detected_attention_object_data ", t, u_key, attention_info.unit)
	print(inspect(attention_info))

	local att_unit = attention_info.unit
	local m_pos = attention_info.handler:get_ground_m_pos()
	local m_head_pos = attention_info.handler:get_detection_m_pos()
	local is_local_player, is_husk_player, is_deployable, is_person, is_very_dangerous, nav_tracker, char_tweak = nil

	if att_unit:base() then
		is_local_player = att_unit:base().is_local_player
		is_husk_player = att_unit:base().is_husk_player
		is_deployable = att_unit:base().sentry_gun
		is_person = att_unit:in_slot(managers.slot:get_mask("persons"))

		if att_unit:base()._tweak_table then
			char_tweak = tweak_data.character[att_unit:base()._tweak_table]
		end
	end

	local dis = mvector3.distance(self._pos, m_head_pos)
	local new_entry = {
		verified = false,
		verified_t = false,
		notice_progress = 0,
		settings = settings,
		unit = attention_info.unit,
		u_key = u_key,
		handler = attention_info.handler,
		next_verify_t = t + settings.verification_interval,
		prev_notice_chk_t = t,
		m_pos = m_pos,
		m_head_pos = m_head_pos,
		nav_tracker = attention_info.nav_tracker,
		is_local_player = is_local_player,
		is_husk_player = is_husk_player,
		is_human_player = is_local_player or is_husk_player,
		is_deployable = is_deployable,
		is_person = is_person,
		is_very_dangerous = is_very_dangerous,
		reaction = settings.reaction,
		criminal_record = managers.groupai:state():criminal_record(u_key),
		char_tweak = char_tweak,
		verified_pos = mvector3.copy(m_head_pos),
		verified_dis = dis,
		dis = dis
	}

	return new_entry
end

function SecurityCamera:on_detected_attention_obj_modified(modified_u_key)
	local attention_info = self._detected_attention_objects[modified_u_key]

	if not attention_info then
		return
	end

	local new_settings = attention_info.handler:get_attention(self._SO_access, AIAttentionObject.REACT_SUSPICIOUS, nil, self._team)
	local old_settings = attention_info.settings

	if new_settings == old_settings then
		return
	end

	local old_notice_clbk = not attention_info.identified and old_settings.notice_clbk

	if new_settings then
		local switch_from_suspicious = AIAttentionObject.REACT_SCARED <= new_settings.reaction and attention_info.reaction == AIAttentionObject.REACT_SUSPICIOUS
		attention_info.settings = new_settings

		if attention_info.uncover_progress then
			attention_info.uncover_progress = nil

			attention_info.unit:movement():on_suspicion(self._unit, false)
			managers.groupai:state():on_criminal_suspicion_progress(attention_info.unit, self._unit, nil)
		end

		if attention_info.identified then
			if switch_from_suspicious then
				attention_info.identified = false
				attention_info.notice_progress = attention_info.uncover_progress or 0
			end

			attention_info.verified = nil
			attention_info.next_verify_t = 0
			attention_info.prev_notice_chk_t = TimerManager:game():time()
		elseif switch_from_suspicious then
			attention_info.notice_progress = 0
			attention_info.prev_notice_chk_t = TimerManager:game():time()
		end

		attention_info.reaction = new_settings.reaction
	else
		self:_destroy_detected_attention_object_data(attention_info)
	end

	if old_notice_clbk and (not new_settings or not new_settings.notice_clbk) then
		old_notice_clbk(self._unit, false)
	end

	if AIAttentionObject.REACT_SCARED <= old_settings.reaction and (not new_settings or AIAttentionObject.REACT_SCARED > new_settings.reaction) then
		managers.groupai:state():on_criminal_suspicion_progress(attention_info.unit, self._unit, nil)
	end
end

function SecurityCamera:_destroy_detected_attention_object_data(attention_info)
	attention_info.handler:remove_listener("sec_cam_" .. tostring(self._u_key))

	if attention_info.settings.notice_clbk then
		attention_info.settings.notice_clbk(self._unit, false)
	end

	if attention_info.uncover_progress then
		attention_info.unit:movement():on_suspicion(self._unit, false)
	end

	managers.groupai:state():on_criminal_suspicion_progress(attention_info.unit, self._unit, false)

	self._detected_attention_objects[attention_info.u_key] = nil
end

function SecurityCamera:_destroy_all_detected_attention_object_data()
	if not self._detected_attention_objects then
		return
	end

	for u_key, attention_info in pairs(self._detected_attention_objects) do
		attention_info.handler:remove_listener("sec_cam_" .. tostring(self._u_key))

		if not attention_info.identified and attention_info.settings.notice_clbk then
			attention_info.settings.notice_clbk(self._unit, false)
		end

		if attention_info.uncover_progress then
			attention_info.unit:movement():on_suspicion(self._unit, false)
		end

		managers.groupai:state():on_criminal_suspicion_progress(attention_info.unit, self._unit, false)
	end

	self._detected_attention_objects = {}
end

function SecurityCamera:_upd_suspicion(t)
	local function _exit_func(attention_data)
		attention_data.unit:movement():on_uncovered(self._unit)
		self:_sound_the_alarm(attention_data.unit)
	end

	local max_suspicion = 0

	for u_key, attention_data in pairs(self._detected_attention_objects) do
		if attention_data.identified and attention_data.reaction == AIAttentionObject.REACT_SUSPICIOUS then
			if not attention_data.verified then
				if attention_data.uncover_progress then
					local dt = t - attention_data.last_suspicion_t
					attention_data.uncover_progress = attention_data.uncover_progress - dt

					if attention_data.uncover_progress <= 0 then
						attention_data.uncover_progress = nil
						attention_data.last_suspicion_t = nil

						attention_data.unit:movement():on_suspicion(self._unit, false)
						managers.groupai:state():on_criminal_suspicion_progress(attention_data.unit, self._unit, false)
					else
						max_suspicion = math.max(max_suspicion, attention_data.uncover_progress)

						attention_data.unit:movement():on_suspicion(self._unit, attention_data.uncover_progress)

						attention_data.last_suspicion_t = t
					end
				end
			else
				local dis = attention_data.dis
				local susp_settings = attention_data.unit:base():suspicion_settings()
				local suspicion_range = self._suspicion_range
				local uncover_range = 0
				local max_range = self._range

				if attention_data.settings.uncover_range and dis < math.min(max_range, uncover_range) * susp_settings.range_mul then
					attention_data.unit:movement():on_suspicion(self._unit, true)
					managers.groupai:state():on_criminal_suspicion_progress(attention_data.unit, self._unit, true)
					managers.groupai:state():criminal_spotted(attention_data.unit)

					max_suspicion = 1

					_exit_func(attention_data)
				elseif suspicion_range and dis < math.min(max_range, suspicion_range) * susp_settings.range_mul then
					if attention_data.last_suspicion_t then
						local dt = t - attention_data.last_suspicion_t
						local range_max = (suspicion_range - uncover_range) * susp_settings.range_mul
						local range_min = uncover_range
						local mul = 1 - (dis - range_min) / range_max
						local progress = dt * 0.5 * mul * susp_settings.buildup_mul
						attention_data.uncover_progress = (attention_data.uncover_progress or 0) + progress
						max_suspicion = math.max(max_suspicion, attention_data.uncover_progress)

						if attention_data.uncover_progress < 1 then
							attention_data.unit:movement():on_suspicion(self._unit, attention_data.uncover_progress)

							attention_data.last_suspicion_t = t
						else
							attention_data.unit:movement():on_suspicion(self._unit, true)
							managers.groupai:state():on_criminal_suspicion_progress(attention_data.unit, self._unit, true)
							managers.groupai:state():criminal_spotted(attention_data.unit)
							_exit_func(attention_data)
						end
					else
						attention_data.uncover_progress = 0

						managers.groupai:state():on_criminal_suspicion_progress(attention_data.unit, self._unit, 0)

						attention_data.last_suspicion_t = t
					end
				elseif attention_data.uncover_progress and attention_data.last_suspicion_t then
					local dt = t - attention_data.last_suspicion_t
					attention_data.uncover_progress = attention_data.uncover_progress - dt

					if attention_data.uncover_progress <= 0 then
						attention_data.uncover_progress = nil
						attention_data.last_suspicion_t = nil

						attention_data.unit:movement():on_suspicion(self._unit, false)
						managers.groupai:state():on_criminal_suspicion_progress(attention_data.unit, self._unit, false)
					else
						attention_data.last_suspicion_t = t
						max_suspicion = math.max(max_suspicion, attention_data.uncover_progress)

						attention_data.unit:movement():on_suspicion(self._unit, attention_data.uncover_progress)
					end
				end
			end
		end
	end

	self._suspicion = max_suspicion > 0 and max_suspicion
end

function SecurityCamera:_sound_the_alarm(detected_unit)
	if self._alarm_sound then
		return
	end

	if Network:is_server() then
		if self._mission_script_element then
			self._mission_script_element:on_alarm(self._unit)
		end

		self:_send_net_event(self._NET_EVENTS.alarm_start)

		self._call_police_clbk_id = "cam_call_cops" .. tostring(self._unit:key())

		managers.enemy:add_delayed_clbk(self._call_police_clbk_id, callback(self, self, "clbk_call_the_police"), Application:time() + 7)

		local reason_called = managers.groupai:state().analyse_giveaway("security_camera", detected_unit)
		self._reason_called = managers.groupai:state():fetch_highest_giveaway(self._reason_called, reason_called)

		self:_destroy_all_detected_attention_object_data()
		self:set_detection_enabled(false, nil, nil)
	end

	if self._suspicion_sound then
		self._suspicion_sound = nil

		self._unit:sound_source():post_event("camera_suspicious_signal_stop")
	end

	self._alarm_sound = self._unit:sound_source():post_event("camera_alarm_signal")
end

function SecurityCamera:_stop_all_sounds()
	if Network:is_server() and (self._alarm_sound or self._suspicion_sound) then
		self:_send_net_event(self._NET_EVENTS.sound_off)
	end

	if self._alarm_sound or self._suspicion_sound then
		self._alarm_sound = nil
		self._suspicion_sound = nil

		self._unit:sound_source():post_event("camera_silent")
	end

	self._suspicion_lvl_sync = 0
	self._suspicion_sound_lvl = 0
end

function SecurityCamera:_set_suspicion_sound(suspicion_level)
	if self._suspicion_sound_lvl == suspicion_level then
		return
	end

	if not self._suspicion_sound then
		self._suspicion_sound = self._unit:sound_source():post_event("camera_suspicious_signal")
		self._suspicion_sound_lvl = 0
	end

	local pitch = self._suspicion_sound_lvl <= suspicion_level and 1 or 0.6
	self._suspicion_sound_lvl = suspicion_level

	self._unit:sound_source():set_rtpc("camera_suspicion_level_pitch", pitch)
	self._unit:sound_source():set_rtpc("camera_suspicion_level", suspicion_level)

	if Network:is_server() then
		local suspicion_lvl_sync = math.clamp(math.ceil(suspicion_level * 6), 1, 6)

		if suspicion_lvl_sync ~= self._suspicion_lvl_sync then
			self._suspicion_lvl_sync = suspicion_lvl_sync
			local event_id = self._NET_EVENTS["suspicion_" .. tostring(suspicion_lvl_sync)]

			self:_send_net_event(event_id)
		end
	end
end

function SecurityCamera:_upd_sound(unit, t)
	if self._alarm_sound then
		return
	end

	local suspicion_level = self._suspicion

	for u_key, attention_info in pairs(self._detected_attention_objects) do
		if AIAttentionObject.REACT_SCARED <= attention_info.reaction then
			if attention_info.identified then
				self:_sound_the_alarm(attention_info.unit)

				return
			elseif not suspicion_level or suspicion_level < attention_info.notice_progress then
				suspicion_level = attention_info.notice_progress
			end
		end
	end

	if not suspicion_level then
		self:_set_suspicion_sound(0)
		self:_stop_all_sounds()

		return
	end

	self:_set_suspicion_sound(suspicion_level)
end

function SecurityCamera:sync_net_event(event_id)
	local net_events = self._NET_EVENTS

	if net_events.suspicion_1 <= event_id and event_id <= net_events.suspicion_6 then
		local suspicion_lvl = (event_id - net_events.suspicion_1 + 1) / 6

		self:_set_suspicion_sound(suspicion_lvl)
	elseif event_id == net_events.sound_off then
		self:_stop_all_sounds()
	elseif event_id == net_events.alarm_start then
		self:_sound_the_alarm()
	elseif event_id == net_events.start_tape_loop_1 then
		self:_start_tape_loop_by_upgrade_level(1)
	elseif event_id == net_events.start_tape_loop_2 then
		self:_start_tape_loop_by_upgrade_level(2)
	elseif event_id == net_events.request_start_tape_loop_1 then
		self:_request_start_tape_loop_by_upgrade_level(1)
	elseif event_id == net_events.request_start_tape_loop_2 then
		self:_request_start_tape_loop_by_upgrade_level(2)
	elseif event_id == net_events.deactivate_tape_loop then
		self:_deactivate_tape_loop()
	end
end

function SecurityCamera:_send_net_event(event_id)
	managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", event_id)
end

function SecurityCamera:clbk_call_the_police()
	managers.groupai:state():on_criminal_suspicion_progress(nil, self._unit, "called")

	self._call_police_clbk_id = nil

	managers.groupai:state():on_police_called(self._reason_called)
end

function SecurityCamera:start_tape_loop(tape_loop_t)
	if alive(SecurityCamera.active_tape_loop_unit) then
		return
	end

	local time_upgrade_level = managers.player:upgrade_level("player", "tape_loop_duration", 0)

	if Network:is_server() then
		self:_start_tape_loop_by_upgrade_level(time_upgrade_level)

		if time_upgrade_level == 1 then
			self:_send_net_event(self._NET_EVENTS.start_tape_loop_1)
		elseif time_upgrade_level == 2 then
			self:_send_net_event(self._NET_EVENTS.start_tape_loop_2)
		end
	elseif time_upgrade_level == 1 then
		self:_send_net_event(self._NET_EVENTS.request_start_tape_loop_1)
	elseif time_upgrade_level == 2 then
		self:_send_net_event(self._NET_EVENTS.request_start_tape_loop_2)
	end
end

function SecurityCamera:_request_start_tape_loop_by_upgrade_level(time_upgrade_level)
	if not Network:is_server() then
		return
	end

	if alive(SecurityCamera.active_tape_loop_unit) then
		return
	end

	self:_start_tape_loop_by_upgrade_level(time_upgrade_level)

	if time_upgrade_level == 1 then
		self:_send_net_event(self._NET_EVENTS.start_tape_loop_1)
	elseif time_upgrade_level == 2 then
		self:_send_net_event(self._NET_EVENTS.start_tape_loop_2)
	end
end

function SecurityCamera:_start_tape_loop_by_upgrade_level(time_upgrade_level)
	local tape_loop_t = managers.player:upgrade_value_by_level("player", "tape_loop_duration", time_upgrade_level)

	self:_start_tape_loop(tape_loop_t)
end

function SecurityCamera:_start_tape_loop(tape_loop_t)
	self:_deactivate_tape_loop_restart()

	self._tape_loop_end_t = Application:time() + tape_loop_t
	SecurityCamera.active_tape_loop_unit = self._unit

	self._unit:contour():add("mark_unit_friendly")

	if self._unit:interaction() then
		self._unit:interaction():set_active(false)
	end

	if self._camera_wrong_image_sound then
		self._camera_wrong_image_sound:stop()
	end

	self._camera_wrong_image_sound = self._unit:sound_source():post_event("camera_wrong_image")

	if self._tape_loop_expired_clbk_id then
		managers.enemy:remove_delayed_clbk(self._tape_loop_expired_clbk_id)

		self._tape_loop_expired_clbk_id = nil
	end

	self._tape_loop_expired_clbk_id = "tape_loop_expired" .. tostring(self._unit:key())

	managers.enemy:add_delayed_clbk(self._tape_loop_expired_clbk_id, callback(self, self, "_clbk_tape_loop_expired"), self._tape_loop_end_t)
end

function SecurityCamera:_clbk_tape_loop_expired(...)
	self._tape_loop_expired_clbk_id = nil
	self._tape_loop_end_t = nil

	self._unit:contour():remove("mark_unit_friendly")

	if self._unit:interaction() then
		self._unit:interaction():set_active(true)
	end

	if self._destroyed then
		return
	end

	self:_activate_tape_loop_restart(5)

	SecurityCamera.active_tape_loop_unit = nil
end

function SecurityCamera:_activate_tape_loop_restart(restart_t)
	if not managers.groupai:state():whisper_mode() then
		if self._camera_wrong_image_sound then
			self._camera_wrong_image_sound:stop()
		end

		return
	end

	self._unit:sound_source():post_event("camera_wrong_image_outro")

	self._tape_loop_restarting_t = Application:time() + restart_t

	if not Network:is_server() then
		self:set_update_enabled(true)
	end
end

function SecurityCamera:_deactivate_tape_loop()
	if Network:is_server() then
		self:_send_net_event(self._NET_EVENTS.deactivate_tape_loop)
	end

	if SecurityCamera.active_tape_loop_unit and SecurityCamera.active_tape_loop_unit == self._unit then
		SecurityCamera.active_tape_loop_unit = nil

		self._unit:contour():remove("mark_unit_friendly")
	end

	if self._tape_loop_expired_clbk_id then
		managers.enemy:remove_delayed_clbk(self._tape_loop_expired_clbk_id)

		self._tape_loop_end_t = nil
		self._tape_loop_expired_clbk_id = nil
	end

	if self._camera_wrong_image_sound then
		self._camera_wrong_image_sound:stop()

		self._camera_wrong_image_sound = nil
	end

	if self._tape_loop_restarting_t then
		self:_deactivate_tape_loop_restart()
	end

	if self._unit:interaction() then
		self._unit:interaction():set_active(false)
	end
end

function SecurityCamera:_deactivate_tape_loop_restart()
	if not self._tape_loop_restarting_t then
		return
	end

	self._unit:sound_source():post_event("camera_wrong_image_outro_end")

	self._tape_loop_restarting_t = nil

	if not Network:is_server() then
		self:set_update_enabled(false)
	end

	if self._tape_loop_active_contour then
		self._tape_loop_active_contour = nil

		self._unit:contour():remove("mark_unit_friendly")
	end
end

function SecurityCamera:can_apply_tape_loop()
	return not self._tape_loop_end_t or self._tape_loop_end_t < Application:time()
end

function SecurityCamera:on_camera_access_changed()
	local current_state = game_state_machine:current_state()

	if current_state and current_state.on_camera_access_changed then
		current_state:on_camera_access_changed(self._unit)
	end
end

function SecurityCamera:set_access_camera_enabled(enabled)
	self._set_access_camera_enabled = enabled

	self:on_camera_access_changed()
end

function SecurityCamera:access_enabled()
	return self._unit:enabled() and self._set_access_camera_enabled
end

function SecurityCamera:on_unit_set_enabled(enabled)
	if self._destroyed then
		return
	end

	if self._unit:interaction() then
		self._unit:interaction():set_active(enabled)
	end

	self:on_camera_access_changed()
end

function SecurityCamera:save(data)
	if self._alarm_sound then
		data.alarm = true
	elseif self._suspicion_sound then
		data.suspicion_lvl = self._suspicion_lvl_sync
	end

	data.destroyed = self._destroyed

	if self._yaw then
		data.yaw = self._yaw
		data.pitch = self._pitch
	end

	if self._tape_loop_end_t then
		data.tape_loop_t = self._tape_loop_end_t - Application:time()
	end

	if self._tape_loop_restarting_t then
		data.tape_loop_restarting_t = self._tape_loop_restarting_t - Application:time()
	end
end

function SecurityCamera:load(data)
	if data.alarm then
		self:_sound_the_alarm()
	elseif data.suspicion_lvl then
		self:_set_suspicion_sound(data.suspicion_lvl)
	end

	if data.yaw then
		self:apply_rotations(data.yaw, data.pitch)
	end

	self._destroyed = data.destroyed

	if data.tape_loop_t then
		self:_start_tape_loop(data.tape_loop_t)
	end

	if data.tape_loop_restarting_t then
		self:_activate_tape_loop_restart(data.tape_loop_restarting_t)
	end
end

function SecurityCamera:destroy(unit)
	table.delete(SecurityCamera.cameras, self._unit)

	self._destroying = true

	self:set_detection_enabled(false)

	if self._call_police_clbk_id then
		managers.enemy:remove_delayed_clbk(self._call_police_clbk_id)

		self._call_police_clbk_id = nil
	end

	if self._tape_loop_expired_clbk_id then
		managers.enemy:remove_delayed_clbk(self._tape_loop_expired_clbk_id)

		self._tape_loop_expired_clbk_id = nil
	end

	if SecurityCamera.active_tape_loop_unit and SecurityCamera.active_tape_loop_unit == self._unit then
		SecurityCamera.active_tape_loop_unit = nil
	end
end
