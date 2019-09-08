local mvec3_dir = mvector3.direction
local mvec3_dist_sq = mvector3.distance_sq
local mvec3_dot = mvector3.dot
local mvec3_cross = mvector3.cross
local mvec3_sub = mvector3.subtract
local mvec3_add = mvector3.add
local mvec3_mul = mvector3.multiply
local math_max = math.max
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
SentryGunBrain = SentryGunBrain or class()
SentryGunBrain._create_attention_setting_from_descriptor = PlayerMovement._create_attention_setting_from_descriptor
SentryGunBrain.attention_target_offset_hor = 75
SentryGunBrain.attention_target_offset_ver = 75

function SentryGunBrain:init(unit)
	self._unit = unit
	self._active = false

	self._unit:set_extension_update_enabled(Idstring("brain"), false)

	self._tweak_data = tweak_data.weapon.sentry_gun
	self._visibility_slotmask = managers.slot:get_mask("AI_visibility_sentry_gun")
	self._shield_check = managers.slot:get_mask("enemy_shield_check")
	self._detected_attention_objects = {}
	self._next_detection_upd_t = 0
	self._firing = false
	self._SO_access_str = "teamAI1"
	self._SO_access = managers.navigation:convert_access_flag(self._SO_access_str)

	unit:event_listener():add("Brain_on_switch_fire_mode_event", {
		"on_switch_fire_mode"
	}, callback(self, self, "_on_switch_fire_mode_event"))
end

function SentryGunBrain:_on_switch_fire_mode_event(ap_bullets)
	self._ap_bullets = ap_bullets
end

function SentryGunBrain:post_init()
	self._ext_movement = self._unit:movement()
end

function SentryGunBrain:update(unit, t, dt)
	if Network:is_server() then
		self:_upd_detection(t)
		self:_select_focus_attention(t)
		self:_upd_flash_grenade(t)
		self:_upd_go_idle(t)
	end

	self:_upd_fire(t)
end

function SentryGunBrain:setup(shaprness_mul)
	self._shaprness_mul = shaprness_mul

	if Network:is_server() then
		self:_setup_attention_handler()
	end
end

function SentryGunBrain:on_activated(tweak_table_id)
	self._tweak_data = tweak_data.weapon[tweak_table_id]

	self:_update_SO_access()
end

function SentryGunBrain:_update_SO_access()
	local team_data = self._unit:movement():team()

	if team_data.foes[tweak_data.levels:get_default_team_ID("player")] then
		if team_data.foes[tweak_data.levels:get_default_team_ID("combatant")] then
			self._SO_access_str = "gangster"
		else
			self._SO_access_str = "swat"
		end
	elseif team_data.foes[tweak_data.levels:get_default_team_ID("combatant")] then
		self._SO_access_str = "teamAI1"
	else
		self._SO_access_str = "civ_male"
	end

	self._SO_access = managers.navigation:convert_access_flag(self._SO_access_str)
end

function SentryGunBrain:is_active()
	return self._active
end

function SentryGunBrain:set_active(state)
	state = state and true or false

	if self._active == state then
		return
	end

	self._unit:set_extension_update_enabled(Idstring("brain"), state)

	self._active = state

	if not state and self._firing then
		self._unit:weapon():stop_autofire()

		self._firing = false
	end

	if not state and Network:is_server() and self._attention_handler then
		PlayerMovement.set_attention_settings(self, nil)
	end
end

function SentryGunBrain:_upd_detection(t)
	if self._ext_movement:is_activating() or self._ext_movement:is_inactivating() then
		return
	end

	if t < self._next_detection_upd_t then
		return
	end

	local delay = 1
	local my_SO_access_str = self._SO_access_str
	local my_SO_access = self._SO_access
	local my_tracker = self._unit:movement():nav_tracker()
	local chk_vis_func = my_tracker.check_visibility
	local detected_objects = self._detected_attention_objects
	local my_key = self._unit:key()
	local my_team = self._ext_movement:team()
	local my_pos = self._ext_movement:m_head_pos()
	local my_tracker = self._ext_movement:nav_tracker()
	local chk_vis_func = my_tracker.check_visibility
	local max_detection_range = self._tweak_data.DETECTION_RANGE
	local all_attention_objects = managers.groupai:state():get_AI_attention_objects_by_filter(my_SO_access_str, my_team)

	local function _distance_chk(handler, settings, attention_pos)
		attention_pos = attention_pos or handler:get_detection_m_pos()
		local dis_sq = mvec3_dist_sq(my_pos, attention_pos)
		local max_dis = math.min(max_detection_range, settings.max_range or max_detection_range)

		if settings.detection and settings.detection.range_mul then
			max_dis = max_dis * settings.detection.range_mul
		end

		if dis_sq < max_dis * max_dis then
			return math.sqrt(dis_sq)
		end
	end

	local ignore_units = {
		self._unit
	}

	local function _nearly_visible_chk(attention_info, detect_pos)
		local near_pos = tmp_vec1

		if attention_info.verified_dis < 2000 and math.abs(detect_pos.z - my_pos.z) < 300 then
			mvector3.set(near_pos, detect_pos)
			mvector3.set_z(near_pos, near_pos.z + 100)

			local near_vis_ray = World:raycast("ray", my_pos, near_pos, "ignore_unit", ignore_units, "slot_mask", self._visibility_slotmask, "ray_type", "ai_vision", "report")

			if near_vis_ray then
				local side_vec = tmp_vec1

				mvector3.set(side_vec, detect_pos)
				mvec3_sub(side_vec, my_pos)
				mvec3_cross(side_vec, side_vec, math.UP)
				mvector3.set_length(side_vec, 150)
				mvector3.set(near_pos, detect_pos)
				mvec3_add(near_pos, side_vec)

				local near_vis_ray = World:raycast("ray", my_pos, near_pos, "ignore_unit", ignore_units, "slot_mask", self._visibility_slotmask, "ray_type", "ai_vision", "report")

				if near_vis_ray then
					mvec3_mul(side_vec, -2)
					mvec3_add(near_pos, side_vec)

					near_vis_ray = World:raycast("ray", my_pos, near_pos, "ignore_unit", ignore_units, "slot_mask", self._visibility_slotmask, "ray_type", "ai_vision", "report")
				end
			end

			if not near_vis_ray then
				attention_info.nearly_visible = true
				attention_info.last_verified_pos = mvector3.copy(near_pos)
			end
		end
	end

	for u_key, attention_info in pairs(all_attention_objects) do
		if u_key ~= my_key and not detected_objects[u_key] and (not attention_info.nav_tracker or chk_vis_func(my_tracker, attention_info.nav_tracker)) then
			local settings = attention_info.handler:get_attention(my_SO_access, AIAttentionObject.REACT_SUSPICIOUS, nil, my_team)

			if settings then
				local attention_pos = attention_info.handler:get_detection_m_pos()

				if _distance_chk(attention_info.handler, settings, attention_pos) then
					ignore_units[2] = attention_info.unit or nil
					local vis_ray = World:raycast("ray", my_pos, attention_pos, "ignore_unit", ignore_units, "slot_mask", self._visibility_slotmask, "ray_type", "ai_vision")

					if not vis_ray or vis_ray.unit:key() == u_key then
						detected_objects[u_key] = CopLogicBase._create_detected_attention_object_data(t, self._unit, u_key, attention_info, settings)
					end
				end
			end
		end
	end

	local update_delay = 2

	for u_key, attention_info in pairs(detected_objects) do
		if t < attention_info.next_verify_t then
			update_delay = math.min(attention_info.next_verify_t - t, update_delay)
		else
			ignore_units[2] = attention_info.unit or nil
			attention_info.next_verify_t = t + (attention_info.identified and attention_info.verified and attention_info.settings.verification_interval or attention_info.settings.notice_interval or attention_info.settings.verification_interval)
			update_delay = math.min(update_delay, attention_info.settings.verification_interval)

			if not attention_info.identified then
				local health_ratio = self:_attention_health_ratio(attention_info)
				local objective = self:_attention_objective(attention_info)
				local noticable = nil
				local distance = _distance_chk(attention_info.handler, attention_info.settings, nil)
				local skip = objective == "surrender" or health_ratio <= 0

				if distance then
					local attention_pos = attention_info.handler:get_detection_m_pos()
					local vis_ray = World:raycast("ray", my_pos, attention_pos, "ignore_unit", ignore_units, "slot_mask", self._visibility_slotmask, "ray_type", "ai_vision", "report")

					if not vis_ray then
						noticable = true
					end
				end

				local delta_prog = nil
				local dt = t - attention_info.prev_notice_chk_t

				if noticable and not skip then
					local min_delay = self._tweak_data.DETECTION_DELAY[1][2]
					local max_delay = self._tweak_data.DETECTION_DELAY[2][2]
					local dis_ratio = (distance - self._tweak_data.DETECTION_DELAY[1][1]) / (self._tweak_data.DETECTION_DELAY[2][1] - self._tweak_data.DETECTION_DELAY[1][1])
					local dis_mul_mod = math.lerp(min_delay, max_delay, dis_ratio)
					local notice_delay_mul = attention_info.settings.notice_delay_mul or 1

					if attention_info.settings.detection and attention_info.settings.detection.delay_mul then
						notice_delay_mul = notice_delay_mul * attention_info.settings.detection.delay_mul
					end

					local notice_delay_modified = math.lerp(min_delay * notice_delay_mul, max_delay, dis_mul_mod)
					delta_prog = notice_delay_modified > 0 and dt / notice_delay_modified or 1
				else
					delta_prog = dt * -0.125
				end

				attention_info.notice_progress = attention_info.notice_progress + delta_prog

				if attention_info.notice_progress > 1 and not skip then
					attention_info.notice_progress = nil
					attention_info.prev_notice_chk_t = nil
					attention_info.identified = true
					attention_info.release_t = t + attention_info.settings.release_delay
					attention_info.identified_t = t
					noticable = true
				elseif attention_info.notice_progress < 0 or skip then
					self:_destroy_detected_attention_object_data(attention_info)

					noticable = false
				else
					noticable = attention_info.notice_progress
					attention_info.prev_notice_chk_t = t
				end

				if noticable ~= false and attention_info.settings.notice_clbk then
					attention_info.settings.notice_clbk(self._unit, noticable)
				end
			end

			if attention_info.identified then
				update_delay = math.min(update_delay, attention_info.settings.verification_interval)
				attention_info.nearly_visible = nil
				local verified, vis_ray = nil
				local attention_pos = attention_info.handler:get_detection_m_pos()
				local dis = mvector3.distance(my_pos, attention_info.m_head_pos)

				if dis < max_detection_range * 1.2 and (not attention_info.settings.max_range or dis < attention_info.settings.max_range * (attention_info.settings.detection and attention_info.settings.detection.range_mul or 1) * 1.2) then
					local detect_pos = nil

					if attention_info.is_husk_player and attention_info.unit:anim_data().crouch then
						detect_pos = tmp_vec1

						mvector3.set(detect_pos, attention_info.m_pos)
						mvec3_add(detect_pos, tweak_data.player.stances.default.crouched.head.translation)
					else
						detect_pos = attention_pos
					end

					vis_ray = World:raycast("ray", my_pos, detect_pos, "ignore_unit", ignore_units, "slot_mask", self._visibility_slotmask, "ray_type", "ai_vision")

					if not vis_ray then
						verified = true
					end

					attention_info.verified = verified
				end

				attention_info.dis = dis
				attention_info.vis_ray = vis_ray and vis_ray.dis or nil
				local is_downed = false

				if attention_info.unit:movement() and attention_info.unit:movement().downed then
					is_downed = attention_info.unit:movement():downed()
				end

				local is_ignored_target = self:_attention_health_ratio(attention_info) <= 0 or self:_attention_objective(attention_info) == "surrender" or is_downed

				if is_ignored_target then
					self:_destroy_detected_attention_object_data(attention_info)
				elseif verified and dis < self._tweak_data.FIRE_RANGE then
					attention_info.release_t = nil
					attention_info.verified_t = t

					mvector3.set(attention_info.verified_pos, attention_pos)

					attention_info.last_verified_pos = mvector3.copy(attention_pos)
					attention_info.verified_dis = dis
				elseif attention_info.has_team and my_team.foes[attention_info.unit:movement():team().id] then
					if attention_info.criminal_record and AIAttentionObject.REACT_COMBAT <= attention_info.settings.reaction then
						if dis > 1000 and mvector3.distance(attention_pos, attention_info.last_verified_pos or attention_info.criminal_record.pos) > 700 or max_detection_range < dis then
							self:_destroy_detected_attention_object_data(attention_info)
						else
							update_delay = math.min(0.2, update_delay)
							attention_info.verified_pos = mvector3.copy(attention_info.criminal_record.pos)
							attention_info.verified_dis = dis

							if vis_ray then
								_nearly_visible_chk(attention_info, attention_pos)
							end
						end
					elseif attention_info.release_t and attention_info.release_t < t then
						self:_destroy_detected_attention_object_data(attention_info)
					else
						attention_info.release_t = attention_info.release_t or t + attention_info.settings.release_delay
					end
				elseif attention_info.release_t and attention_info.release_t < t then
					self:_destroy_detected_attention_object_data(attention_info)
				else
					attention_info.release_t = attention_info.release_t or t + attention_info.settings.release_delay
				end
			end
		end
	end

	self._next_detection_upd_t = t + update_delay
end

function SentryGunBrain:_select_focus_attention(t)
	local current_focus = self._attention_obj
	local current_pos = self._ext_movement:m_head_pos()
	local current_fwd = nil

	if current_focus then
		current_fwd = tmp_vec2

		mvec3_dir(current_fwd, self._ext_movement:m_head_pos(), current_focus.m_head_pos)
	else
		current_fwd = self._ext_movement:m_head_fwd()
	end

	local max_dis = self._tweak_data.DETECTION_RANGE

	local function _get_weight(attention_info)
		if not attention_info.identified then
			return
		end

		local total_weight = 1

		if attention_info.health_ratio and attention_info.unit:character_damage():health_ratio() <= 0 then
			return 0
		elseif attention_info.verified_t and t - attention_info.verified_t < 3 then
			local max_duration = 3
			local elapsed_t = t - attention_info.verified_t
			total_weight = total_weight * math.lerp(1, 0.6, elapsed_t / max_duration)
		else
			return 0
		end

		if attention_info.settings.weight_mul then
			total_weight = total_weight * attention_info.settings.weight_mul
		end

		local dis = mvec3_dir(tmp_vec1, current_pos, attention_info.m_head_pos)
		local dis_weight = math_max(0, (max_dis - dis) / max_dis)
		total_weight = total_weight * dis_weight
		local dot_weight = 1 + mvec3_dot(tmp_vec1, current_fwd)
		dot_weight = dot_weight * dot_weight * dot_weight
		total_weight = total_weight * dot_weight

		if self:_ignore_shield({
			self._unit
		}, current_pos, attention_info) then
			total_weight = total_weight * 0.01
		end

		return total_weight
	end

	local best_focus_attention, best_focus_weight = nil
	local best_focus_reaction = 0

	for u_key, attention_info in pairs(self._detected_attention_objects) do
		local weight = _get_weight(attention_info)

		if weight and (best_focus_reaction < attention_info.reaction or best_focus_reaction == attention_info.reaction and (not best_focus_weight or best_focus_weight < weight)) then
			best_focus_weight = weight
			best_focus_attention = attention_info
			best_focus_reaction = attention_info.reaction
		end
	end

	if current_focus ~= best_focus_attention then
		if best_focus_attention then
			local attention_data = {
				unit = best_focus_attention.unit,
				u_key = best_focus_attention.u_key,
				handler = best_focus_attention.handler,
				reaction = best_focus_attention.reaction
			}

			self._ext_movement:set_attention(attention_data)
		else
			self._ext_movement:set_attention()
		end

		self._attention_obj = best_focus_attention
	end
end

function SentryGunBrain:_destroy_detected_attention_object_data(attention_info)
	attention_info.handler:remove_listener("detect_" .. tostring(self._unit:key()))

	if attention_info.settings.notice_clbk then
		attention_info.settings.notice_clbk(self._unit, false)
	end

	if AIAttentionObject.REACT_SUSPICIOUS <= attention_info.settings.reaction then
		managers.groupai:state():on_criminal_suspicion_progress(attention_info.unit, self._unit, nil)
	end

	if attention_info.uncover_progress then
		attention_info.unit:movement():on_suspicion(self._unit, false)
	end

	self._detected_attention_objects[attention_info.u_key] = nil
end

function SentryGunBrain:_upd_fire(t)
	if self._ext_movement:is_activating() or self._ext_movement:is_inactivating() or self._idle then
		if self._firing then
			self:stop_autofire()
		end

		return
	end

	local attention = self._ext_movement:attention()

	if self._unit:weapon():out_of_ammo() then
		if self._unit:weapon():can_auto_reload() then
			if self._firing then
				self:stop_autofire()
			end

			if not self._ext_movement:rearming() then
				self._ext_movement:rearm()
			end
		elseif not self._unit:base():waiting_for_refill() then
			self:switch_off()
		end
	elseif self._ext_movement:rearming() then
		self._ext_movement:complete_rearming()
	elseif attention and attention.reaction and AIAttentionObject.REACT_SHOOT <= attention.reaction and not self._ext_movement:warming_up(t) and not self:_ignore_shield({
		self._unit
	}, self._ext_movement:m_head_pos(), self._attention_obj) then
		local expend_ammo = Network:is_server()
		local damage_player = attention.unit:base() and attention.unit:base().is_local_player
		local my_pos = self._ext_movement:m_head_pos()
		local target_pos = self:get_target_base_pos(attention)

		if not target_pos then
			self:stop_autofire()

			return
		end

		if not self:is_target_on_sight(my_pos, target_pos) then
			self:stop_autofire()

			return
		end

		if self._firing then
			self._unit:weapon():trigger_held(false, expend_ammo, damage_player, attention.unit)
		else
			mvec3_dir(tmp_vec1, my_pos, target_pos)

			local max_dot = self._tweak_data.KEEP_FIRE_ANGLE
			max_dot = math.min(0.99, 1 - (1 - max_dot) * (self._shaprness_mul or 1))

			if max_dot < mvec3_dot(tmp_vec1, self._ext_movement:m_head_fwd()) then
				self._unit:weapon():start_autofire()
				self._unit:weapon():trigger_held(false, expend_ammo, damage_player, attention.unit)

				self._firing = true
			end
		end
	elseif self._firing then
		self:stop_autofire()
	end
end

function SentryGunBrain:stop_autofire()
	self._unit:weapon():stop_autofire()

	self._firing = false
end

function SentryGunBrain:get_target_base_pos(attention)
	local target_base_pos = attention.pos

	if not target_base_pos and attention.unit:movement() then
		target_base_pos = attention.unit:movement():m_com()
	end

	target_base_pos = target_base_pos or attention.handler:get_detection_m_pos()

	return target_base_pos
end

function SentryGunBrain:is_target_on_sight(my_pos, target_base_pos)
	if not target_base_pos then
		return false
	end

	local fire_range_sq = self._tweak_data.FIRE_RANGE * self._tweak_data.FIRE_RANGE

	if fire_range_sq < mvec3_dist_sq(my_pos, target_base_pos) then
		return false
	end

	local target_pos_same_height = mvector3.copy(target_base_pos)

	mvector3.set_z(target_pos_same_height, mvector3.z(my_pos))

	local dir_to_target = mvector3.copy(my_pos)

	mvec3_sub(dir_to_target, target_pos_same_height)
	mvector3.normalize(dir_to_target)

	local right_offset = Vector3()

	mvec3_cross(right_offset, dir_to_target, math.UP)

	local left_offset = mvector3.copy(right_offset)

	mvec3_mul(right_offset, self.attention_target_offset_hor)
	mvec3_mul(left_offset, -self.attention_target_offset_hor)
	mvector3.set_z(right_offset, mvector3.z(right_offset) + self.attention_target_offset_ver)
	mvector3.set_z(left_offset, mvector3.z(left_offset) + self.attention_target_offset_ver)

	local ignore_units = {
		self._unit
	}
	local offsets = {
		Vector3(0, 0, 0),
		right_offset,
		left_offset
	}

	for i, offset in ipairs(offsets) do
		local target_pos = mvector3.copy(target_base_pos)

		mvec3_add(target_pos, offset)

		local vis_ray = World:raycast("ray", my_pos, target_pos, "ignore_unit", ignore_units, "slot_mask", self._visibility_slotmask, "ray_type", "ai_vision")

		if not vis_ray then
			return true
		end
	end

	return false
end

function SentryGunBrain:_upd_flash_grenade(t)
	if not self._tweak_data.FLASH_GRENADE then
		return
	end

	if self._ext_movement:repairing() then
		return
	end

	if self._next_flash_grenade_chk_t and t < self._next_flash_grenade_chk_t then
		return
	end

	local grenade_tweak = self._tweak_data.FLASH_GRENADE
	local check_t = self._next_flash_grenade_chk_t or t
	self._next_flash_grenade_chk_t = check_t + math.lerp(grenade_tweak.check_interval[1], grenade_tweak.check_interval[2], math.random())

	if grenade_tweak.chance < math.random() then
		return
	end

	local max_range = grenade_tweak.range
	local m_pos = self._ext_movement:m_head_pos()
	local ray_to = mvector3.copy(m_pos)

	mvector3.set_z(ray_to, ray_to.z - 500)

	local ground_ray = World:raycast("ray", m_pos, ray_to, "slot_mask", managers.slot:get_mask("statics"))

	if ground_ray then
		self._grenade_m_pos = mvector3.copy(ground_ray.hit_position)

		mvector3.set_z(self._grenade_m_pos, self._grenade_m_pos.z + 3)

		for u_key, attention_info in pairs(self._detected_attention_objects) do
			if attention_info.identified and attention_info.last_verified_pos and mvec3_dist_sq(self._grenade_m_pos, attention_info.last_verified_pos) < max_range * max_range then
				managers.groupai:state():detonate_cs_grenade(self._grenade_m_pos, m_pos, grenade_tweak.effect_duration)

				self._next_flash_grenade_chk_t = check_t + math.lerp(grenade_tweak.quiet_time[1], grenade_tweak.quiet_time[2], math.random())

				break
			end
		end
	end
end

function SentryGunBrain:_upd_go_idle(t)
	if not Network:is_server() or not self._tweak_data.CAN_GO_IDLE then
		return
	end

	local attention_obj = self._attention_obj

	if managers.groupai:state():is_detection_persistent() then
		self._has_seen_assault_mode = true
	end

	if self._tweak_data.AUTO_REPAIR and self._unit:character_damage():needs_repair() then
		if not self._idle and not self._ext_movement:is_inactivating() then
			if not self._auto_repair_counter then
				self._auto_repair_counter = 0
			end

			if self._auto_repair_counter < self._tweak_data.AUTO_REPAIR_MAX_COUNT then
				self._auto_repair_counter = self._auto_repair_counter + 1

				self:set_idle(true)
			end
		end

		if self._idle and self._ext_movement:is_inactivated() and not self._ext_movement:repairing() then
			self._ext_movement:repair()
		end
	end

	if not self._ext_movement:is_inactivating() and not self._ext_movement:repairing() then
		if attention_obj and AIAttentionObject.REACT_AIM < attention_obj.reaction and not self._ext_movement:repairing() then
			self._decide_go_idle_t = nil

			if self._idle then
				self:set_idle(false)
			end
		elseif not self._idle and not self._ext_movement:rearming() and (not self._has_seen_assault_mode or self._has_seen_assault_mode and not managers.groupai:state():is_detection_persistent()) then
			if not self._decide_go_idle_t then
				self._decide_go_idle_t = t + self._tweak_data.IDLE_WAIT_TIME
			elseif self._decide_go_idle_t < t then
				self:set_idle(true)
			end
		end
	end
end

function SentryGunBrain:on_detected_attention_obj_modified(modified_u_key)
	local attention_info = self._detected_attention_objects[modified_u_key]

	if not attention_info then
		return
	end

	local new_settings = attention_info.handler:get_attention(self._SO_access, nil, nil, self._unit:movement():team())
	local old_settings = attention_info.settings

	if new_settings == old_settings then
		return
	end

	local old_notice_clbk = not attention_info.identified and old_settings.notice_clbk

	if new_settings and AIAttentionObject.REACT_SUSPICIOUS <= new_settings.reaction then
		attention_info.settings = new_settings
		attention_info.stare_expire_t = nil
		attention_info.pause_expire_t = nil
	else
		self:_destroy_detected_attention_object_data(attention_info)

		if self._attention_obj and self._attention_obj.u_key == modified_u_key then
			self._ext_movement:set_attention()
		end
	end

	if old_notice_clbk and (not new_settings or not new_settings.notice_clbk) then
		old_notice_clbk(self._unit, false)
	end
end

function SentryGunBrain:on_damage_received(attacker_unit)
	if not Network:is_server() or not attacker_unit then
		return
	end

	local u_key = attacker_unit:key()
	local attention_info = self._detected_attention_objects[u_key]

	if not attention_info then
		return
	end

	attention_info.dmg_t = TimerManager:game():time()
end

function SentryGunBrain:on_team_set(team_data)
	if self._attention_handler then
		self._attention_handler:set_team(team_data)
	end

	local all_att_objects = {}

	for u_key, att_info in pairs(self._detected_attention_objects) do
		table.insert(all_att_objects, u_key)
	end

	for _, u_key in ipairs(all_att_objects) do
		self:on_detected_attention_obj_modified(u_key)
	end

	self:_update_SO_access()
end

function SentryGunBrain:set_idle(state)
	self._idle = state

	self._ext_movement:set_idle(not state)

	if Network:is_server() then
		self._unit:network():send("turret_idle_state", state)
	end
end

function SentryGunBrain:get_repair_counter()
	return self._auto_repair_counter
end

function SentryGunBrain:switch_off()
	local is_server = Network:is_server()

	if is_server then
		self._ext_movement:set_attention()
	end

	self:set_active(false)
	self._ext_movement:switch_off()
	self._unit:set_slot(26)

	if managers.groupai:state():all_criminals()[self._unit:key()] then
		managers.groupai:state():on_criminal_neutralized(self._unit)
	end

	if Network:is_server() then
		PlayerMovement.set_attention_settings(self, nil)
	end

	self._unit:base():unregister()

	self._attention_obj = nil
end

function SentryGunBrain:switch_on()
	if self._active or self._unit:character_damage():dead() then
		return
	end

	if self._unit:damage():has_sequence("laser_activate") then
		self._unit:damage():run_sequence_simple("laser_activate")
	end

	local is_server = Network:is_server()

	if is_server then
		-- Nothing
	end

	self:set_active(true)
	self._ext_movement:switch_on()
	self._unit:set_slot(25)
	self._unit:base():register()

	if managers.groupai:state():all_criminals()[self._unit:key()] then
		managers.groupai:state():on_criminal_recovered(self._unit)
	end

	if is_server then
		PlayerMovement.set_attention_settings(self, {
			"sentry_gun_enemy_cbt"
		})
	end
end

function SentryGunBrain:_setup_attention_handler()
	self._attention_handler = CharacterAttentionObject:new(self._unit)

	self._attention_handler:set_team(self._ext_movement:team())
	PlayerMovement.set_attention_settings(self, {
		"sentry_gun_enemy_cbt"
	})
end

function SentryGunBrain:attention_handler()
	return self._attention_handler
end

function SentryGunBrain:SO_access()
	return self._SO_access
end

function SentryGunBrain:on_hacked_start()
	PlayerMovement.set_attention_settings(self, {
		"sentry_gun_enemy_cbt_hacked"
	})
end

function SentryGunBrain:on_hacked_end()
	PlayerMovement.set_attention_settings(self, {
		"sentry_gun_enemy_cbt"
	})
end

function SentryGunBrain:_attention_health_ratio(attention)
	if attention and attention.health_ratio then
		return attention.unit:character_damage():health_ratio()
	end

	return 1
end

function SentryGunBrain:_attention_objective(attention)
	if attention and attention.objective then
		return attention.unit:brain():objective()
	end

	return "unknown"
end

local up_offs = math.UP * 50

function SentryGunBrain:_ignore_shield(ignore_units, my_pos, attention)
	if self._ap_bullets then
		return false
	end

	if attention and attention.unit then
		local hit_shield = World:raycast("ray", my_pos, attention.unit:position() + up_offs, "ignore_unit", ignore_units, "slot_mask", self._shield_check)

		if hit_shield then
			return true
		end
	end

	return false
end

function SentryGunBrain:save(save_data)
	local my_save_data = {}
	save_data.brain = my_save_data
	my_save_data.shaprness_mul = self._shaprness_mul
	my_save_data.SO_access_str = self._SO_access_str
	my_save_data.idle = self._idle
end

function SentryGunBrain:load(save_data)
	if not save_data or not save_data.brain then
		return
	end

	local my_save_data = save_data.brain
	self._shaprness_mul = save_data.brain.shaprness_mul or 1
	self._SO_access_str = my_save_data.SO_access_str
	self._SO_access = managers.navigation:convert_access_flag(self._SO_access_str)
	self._tweak_data = tweak_data.weapon[self._unit:base():get_name_id()]

	self:set_idle(my_save_data.idle)
end

function SentryGunBrain:pre_destroy()
	for key, attention_info in pairs(self._detected_attention_objects) do
		self:_destroy_detected_attention_object_data(attention_info)
	end

	self:set_active(false)

	if Network:is_server() and self._attention_handler then
		PlayerMovement.set_attention_settings(self, nil)
	end
end

function SentryGunBrain:on_intimidated(amount, aggressor_unit)
end

function SentryGunBrain:is_hostile()
	return not self._idle
end
