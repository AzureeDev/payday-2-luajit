local tmp_vec1 = Vector3()
ECMJammerBase = ECMJammerBase or class(UnitBase)
ECMJammerBase._NET_EVENTS = {
	feedback_start = 3,
	feedback_flash = 6,
	battery_empty = 2,
	feedback_stop = 4,
	feedback_restart = 7,
	jammer_active = 5,
	battery_low = 1
}
ECMJammerBase.battery_life_multiplier = {
	1,
	1.25,
	1.5
}

function ECMJammerBase.spawn(pos, rot, battery_life_upgrade_lvl, owner, peer_id)
	battery_life_upgrade_lvl = math.clamp(battery_life_upgrade_lvl, 1, #ECMJammerBase.battery_life_multiplier)
	local unit = World:spawn_unit(Idstring("units/payday2/equipment/gen_equipment_jammer/gen_equipment_jammer"), pos, rot)

	managers.network:session():send_to_peers_synched("sync_equipment_setup", unit, battery_life_upgrade_lvl, peer_id or 0)
	unit:base():setup(battery_life_upgrade_lvl, owner)

	return unit
end

function ECMJammerBase:set_server_information(peer_id)
	self._server_information = {owner_peer_id = peer_id}

	managers.network:session():peer(peer_id):set_used_deployable(true)
end

function ECMJammerBase:server_information()
	return self._server_information
end

function ECMJammerBase:init(unit)
	UnitBase.init(self, unit, true)

	self._unit = unit
	self._position = self._unit:position()
	self._rotation = self._unit:rotation()
	self._g_glow_jammer_green = self._unit:get_object(Idstring("g_glow_func1_green"))
	self._g_glow_jammer_red = self._unit:get_object(Idstring("g_glow_func1_red"))
	self._g_glow_feedback_green = self._unit:get_object(Idstring("g_glow_func2_green"))
	self._g_glow_feedback_red = self._unit:get_object(Idstring("g_glow_func2_red"))
	self._max_battery_life = tweak_data.upgrades.ecm_jammer_base_battery_life
	self._battery_life = self._max_battery_life
	self._low_battery_life = tweak_data.upgrades.ecm_jammer_base_low_battery_life
	self._feedback_active = false
	self._jammer_active = false

	if Network:is_client() then
		self._validate_clbk_id = "ecm_jammer_validate" .. tostring(unit:key())

		managers.enemy:add_delayed_clbk(self._validate_clbk_id, callback(self, self, "_clbk_validate"), Application:time() + 60)
	end
end

function ECMJammerBase:_clbk_validate()
	self._validate_clbk_id = nil

	if not self._was_dropin then
		local peer = managers.network:session():server_peer()

		peer:mark_cheater(VoteManager.REASON.many_assets)
	end
end

function ECMJammerBase:sync_setup(upgrade_lvl, peer_id)
	if self._validate_clbk_id then
		managers.enemy:remove_delayed_clbk(self._validate_clbk_id)

		self._validate_clbk_id = nil
	end

	self._max_battery_life = tweak_data.upgrades.ecm_jammer_base_battery_life * self.battery_life_multiplier[upgrade_lvl]
	self._battery_life = self._max_battery_life

	managers.player:verify_equipment(peer_id, "ecm_jammer")
end

function ECMJammerBase:get_name_id()
	return "ecm_jammer"
end

function ECMJammerBase:set_owner(owner)
	self._owner = owner

	if owner then
		local peer = managers.network:session():peer_by_unit(owner)

		if peer then
			self._owner_id = peer:id()
		end
	end

	self:contour_interaction()
end

function ECMJammerBase:owner()
	if not alive(self._owner) then
		local peer = managers.network:session():peer(self._owner_id)

		if peer then
			self._owner = peer:unit()
		end
	end

	return self._owner
end

function ECMJammerBase:battery_life()
	return self._battery_life or 0
end

function ECMJammerBase:sync_net_event(event_id)
	local net_events = self._NET_EVENTS

	if event_id == net_events.battery_low then
		self:_set_battery_low()
	elseif event_id == net_events.battery_empty then
		self:_set_battery_empty()
	elseif event_id == net_events.feedback_start then
		self:_set_feedback_active(true)
	elseif event_id == net_events.feedback_stop then
		self:_set_feedback_active(false)
	elseif event_id == net_events.jammer_active then
		self:set_active(true)
	elseif event_id == net_events.feedback_flash then
		self._unit:contour():flash("deployable_active", 0.15)
	elseif event_id == net_events.feedback_restart then
		self._unit:sound_source():post_event("ecm_jammer_ready")
	end
end

function ECMJammerBase:_send_net_event(event_id)
	managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", event_id)
end

function ECMJammerBase:_send_net_event_to_host(event_id)
	managers.network:session():send_to_host("sync_unit_event_id_16", self._unit, "base", event_id)
end

function ECMJammerBase:setup(battery_life_upgrade_lvl, owner)
	self._slotmask = managers.slot:get_mask("trip_mine_targets")
	self._max_battery_life = tweak_data.upgrades.ecm_jammer_base_battery_life * self.battery_life_multiplier[battery_life_upgrade_lvl]
	self._battery_life = self._max_battery_life
	self._owner = owner

	if owner then
		local peer = managers.network:session():peer_by_unit(owner)

		if peer then
			self._owner_id = peer:id()
		end
	end
end

function ECMJammerBase:link_attachment(body, relative_pos, relative_rot)
	if relative_pos then
		body:unit():link(body:root_object():name(), self._unit, self._unit:orientation_object():name())
		self._unit:set_local_position(relative_pos)
		self._unit:set_local_rotation(relative_rot)
	else
		body:unit():link(body:root_object():name(), self._unit)
	end

	self._attached_body = body
end

function ECMJammerBase:set_active(active)
	active = active and true

	if self._jammer_active == active then
		return
	end

	if Network:is_server() then
		if active then
			self._alert_filter = self:owner():movement():SO_access()
			local jam_cameras, jam_pagers = nil

			if self._owner_id == 1 then
				jam_cameras = managers.player:has_category_upgrade("ecm_jammer", "affects_cameras")
				jam_pagers = managers.player:has_category_upgrade("ecm_jammer", "affects_pagers")

				self:contour_interaction()
			else
				jam_cameras = self:owner():base():upgrade_value("ecm_jammer", "affects_cameras")
				jam_pagers = self:owner():base():upgrade_value("ecm_jammer", "affects_pagers")
			end

			managers.groupai:state():register_ecm_jammer(self._unit, {
				call = true,
				camera = jam_cameras,
				pager = jam_pagers
			})
			self:_send_net_event(self._NET_EVENTS.jammer_active)
		else
			managers.groupai:state():register_ecm_jammer(self._unit, false)
		end
	end

	if active then
		if not self._jam_sound_event then
			self._jam_sound_event = self._unit:sound_source():post_event("ecm_jammer_jam_signal")
		end

		self._unit:contour():add("deployable_active")
	else
		if self._jam_sound_event then
			self._jam_sound_event:stop()

			self._jam_sound_event = nil

			self._unit:sound_source():post_event("ecm_jammer_jam_signal_stop")
		end

		if self._unit:contour() then
			self._unit:contour():remove("deployable_active")
		end
	end

	self._jammer_active = active
end

function ECMJammerBase:active()
	return self._jammer_active
end

function ECMJammerBase:update(unit, t, dt)
	if self._battery_life > 0 then
		self._battery_life = self._battery_life - dt

		self:check_battery()
	end

	if Network:is_server() and not self._feedback_active and self._chk_feedback_retrigger_t then
		self._chk_feedback_retrigger_t = self._chk_feedback_retrigger_t - dt

		if self._chk_feedback_retrigger_t <= 0 then
			if math.random() < (tweak_data.upgrades.ecm_feedback_retrigger_chance or 0) then
				self:_send_net_event(self._NET_EVENTS.feedback_restart)
				self._unit:sound_source():post_event("ecm_jammer_ready")
				self._unit:interaction():set_active(true, true)

				self._chk_feedback_retrigger_t = nil
			else
				self._chk_feedback_retrigger_t = tweak_data.upgrades.ecm_feedback_retrigger_interval or 60
			end
		end
	end

	self:_check_body()
end

function ECMJammerBase:check_battery()
	if self._battery_life <= 0 then
		self:set_battery_empty()
	elseif self._battery_life <= self._low_battery_life then
		self:set_battery_low()
	end
end

function ECMJammerBase:set_battery_empty()
	if self._battery_empty then
		return
	end

	self._battery_life = 0

	self:_set_battery_empty()
end

function ECMJammerBase:_set_battery_empty()
	self._battery_empty = true

	self._g_glow_jammer_green:set_visibility(false)
	self._g_glow_jammer_red:set_visibility(false)
	self:set_active(false)

	if Network:is_server() then
		self:_send_net_event(self._NET_EVENTS.battery_empty)
	end
end

function ECMJammerBase:set_battery_low()
	if self._battery_low then
		return
	end

	self._battery_life = self._low_battery_life

	self:_set_battery_low()
end

function ECMJammerBase:_set_battery_low()
	self._battery_low = true

	self._g_glow_jammer_red:set_visibility(true)

	if not self._unit:contour():is_flashing() then
		self._unit:contour():flash("deployable_active", 0.15)
	end

	if Network:is_server() then
		self:_send_net_event(self._NET_EVENTS.battery_low)
	end
end

function ECMJammerBase:sync_set_battery_life(battery_life)
	self._battery_life = battery_life

	self:check_battery()
end

function ECMJammerBase:_check_body()
	if not alive(self._attached_body) or not self._attached_body:enabled() then
		self:_force_remove()
	end
end

function ECMJammerBase:feedback_active()
	return self._feedback_active
end

function ECMJammerBase:set_feedback_active()
	if not managers.network:session() then
		return
	end

	if Network:is_client() then
		self:_send_net_event_to_host(self._NET_EVENTS.feedback_start)
	else
		self:_set_feedback_active(true)
	end
end

function ECMJammerBase:_set_feedback_active(state)
	state = state and true

	if state == self._feedback_active then
		return
	end

	if Network:is_server() then
		if state then
			self._unit:interaction():set_active(false, true)

			local t = TimerManager:game():time()
			self._feedback_clbk_id = "ecm_feedback" .. tostring(self._unit:key())
			self._feedback_interval = tweak_data.upgrades.ecm_feedback_interval or 1.5
			self._feedback_range = tweak_data.upgrades.ecm_jammer_base_range
			local duration_mul = 1

			if self._owner_id == 1 then
				duration_mul = duration_mul * managers.player:upgrade_value("ecm_jammer", "feedback_duration_boost", 1)
				duration_mul = duration_mul * managers.player:upgrade_value("ecm_jammer", "feedback_duration_boost_2", 1)
			else
				duration_mul = duration_mul * (self:owner():base():upgrade_value("ecm_jammer", "feedback_duration_boost") or 1)
				duration_mul = duration_mul * (self:owner():base():upgrade_value("ecm_jammer", "feedback_duration_boost_2") or 1)
			end

			self._feedback_duration = math.lerp(tweak_data.upgrades.ecm_feedback_min_duration or 15, tweak_data.upgrades.ecm_feedback_max_duration or 20, math.random()) * duration_mul
			self._feedback_expire_t = t + self._feedback_duration
			local first_impact_t = t + math.lerp(0.1, 1, math.random())

			managers.enemy:add_delayed_clbk(self._feedback_clbk_id, callback(self, self, "clbk_feedback"), first_impact_t)
			self:_send_net_event(self._NET_EVENTS.feedback_start)
		else
			if self._feedback_clbk_id then
				managers.enemy:remove_delayed_clbk(self._feedback_clbk_id)

				self._feedback_clbk_id = nil
			end

			self:_send_net_event(self._NET_EVENTS.feedback_stop)

			if alive(self._owner) then
				local retrigger = false
				retrigger = self._owner_id == 1 and managers.player:has_category_upgrade("ecm_jammer", "can_retrigger") or self:owner():base():upgrade_value("ecm_jammer", "can_retrigger")

				if retrigger then
					self._chk_feedback_retrigger_t = tweak_data.upgrades.ecm_feedback_retrigger_interval or 60
				end
			end
		end
	end

	if state then
		print("PUKE!")
		self._g_glow_feedback_green:set_visibility(true)
		self._g_glow_feedback_red:set_visibility(false)

		if not self._puke_sound_event then
			self._puke_sound_event = self._unit:sound_source():post_event("ecm_jammer_puke_signal")
		end

		self._unit:contour():remove("deployable_interactable")
		self._unit:contour():add("deployable_active")
	else
		self._g_glow_feedback_green:set_visibility(false)
		self._g_glow_feedback_red:set_visibility(false)

		if self._puke_sound_event then
			self._puke_sound_event:stop()

			self._puke_sound_event = nil

			self._unit:sound_source():post_event("ecm_jammer_puke_signal_stop")
		end

		if self._unit:contour() then
			self._unit:contour():remove("deployable_active")
		end
	end

	self._feedback_active = state
end

function ECMJammerBase:sync_set_feedback_active()
	self:_set_feedback_active()
end

function ECMJammerBase:clbk_feedback()
	local t = TimerManager:game():time()
	self._feedback_clbk_id = "ecm_feedback" .. tostring(self._unit:key())

	if not managers.groupai:state():enemy_weapons_hot() then
		managers.groupai:state():propagate_alert({
			"vo_cbt",
			self._position,
			10000,
			self._alert_filter,
			self._unit
		})
	end

	print("PUKING!!!!!")
	self._detect_and_give_dmg(self._position + self._unit:rotation():y() * 15, self._unit, self:owner(), self._feedback_range)

	if self._feedback_expire_t < t then
		self._feedback_clbk_id = nil

		self:_set_feedback_active(false)
	else
		if self._feedback_expire_t - t < self._feedback_duration * 0.1 then
			self._g_glow_feedback_red:set_visibility(true)
			self._g_glow_feedback_green:set_visibility(false)

			if not self._unit:contour():is_flashing() then
				self._unit:contour():flash("deployable_active", 0.15)

				if Network:is_server() then
					self:_send_net_event(self._NET_EVENTS.feedback_flash)
				end
			end
		end

		managers.enemy:add_delayed_clbk(self._feedback_clbk_id, callback(self, self, "clbk_feedback"), t + self._feedback_interval + math.random() * 0.3)
	end
end

function ECMJammerBase:contour_selected()
	self._unit:contour():add("deployable_selected")
end

function ECMJammerBase:contour_unselected()
	self._unit:contour():remove("deployable_selected")
end

function ECMJammerBase:contour_interaction()
	if managers.player:has_category_upgrade("ecm_jammer", "can_activate_feedback") and managers.network:session() and self._unit:contour() and self._owner_id == managers.network:session():local_peer():id() then
		self._unit:contour():add("deployable_interactable")
	end
end

function ECMJammerBase._detect_and_give_dmg(hit_pos, device_unit, user_unit, range)
	local mvec3_dis_sq = mvector3.distance_sq
	local slotmask = managers.slot:get_mask("bullet_impact_targets")
	local splinters = {mvector3.copy(hit_pos)}
	local dirs = {
		Vector3(range, 0, 0),
		Vector3(-range, 0, 0),
		Vector3(0, range, 0),
		Vector3(0, -range, 0),
		Vector3(0, 0, range),
		Vector3(0, 0, -range)
	}
	local pos = tmp_vec1

	for _, dir in ipairs(dirs) do
		mvector3.set(pos, dir)
		mvector3.add(pos, hit_pos)

		local splinter_ray = World:raycast("ray", hit_pos, pos, "slot_mask", slotmask)
		pos = (splinter_ray and splinter_ray.position or pos) - dir:normalized() * math.min(splinter_ray and splinter_ray.distance or 0, 10)
		local near_splinter = false

		for _, s_pos in ipairs(splinters) do
			if mvector3.distance_sq(pos, s_pos) < 300 then
				near_splinter = true

				break
			end
		end

		if not near_splinter then
			table.insert(splinters, mvector3.copy(pos))
		end
	end

	local range_sq = range * range
	local half_range_sq = range * 0.5
	half_range_sq = half_range_sq * half_range_sq

	local function _chk_apply_dmg_to_char(u_data)
		if not u_data.char_tweak.ecm_vulnerability then
			return
		end

		if u_data.unit.brain and u_data.unit:brain().is_hostage and u_data.unit:brain():is_hostage() then
			return
		end

		if u_data.unit:anim_data() and u_data.unit:anim_data().act then
			return
		end

		if u_data.char_tweak.ecm_vulnerability <= math.random() then
			return
		end

		local head_pos = u_data.unit:movement():m_head_pos()
		local dis_sq = mvec3_dis_sq(head_pos, hit_pos)

		if range_sq < dis_sq then
			return
		end

		for i_splinter, s_pos in ipairs(splinters) do
			local ray_hit = World:raycast("ray", s_pos, head_pos, "slot_mask", slotmask, "ignore_unit", u_data.unit, "report")

			if not ray_hit and (i_splinter == 1 or dis_sq < half_range_sq) then
				local attack_data = {
					damage = 0,
					variant = "stun",
					attacker_unit = alive(user_unit) and user_unit or nil,
					weapon_unit = device_unit,
					col_ray = {
						position = mvector3.copy(head_pos),
						ray = (head_pos - s_pos):normalized()
					}
				}

				u_data.unit:character_damage():damage_explosion(attack_data)

				break
			end
		end
	end

	for u_key, u_data in pairs(managers.enemy:all_enemies()) do
		_chk_apply_dmg_to_char(u_data)
	end

	for u_key, u_data in pairs(managers.enemy:all_civilians()) do
		_chk_apply_dmg_to_char(u_data)
	end
end

function ECMJammerBase:_force_remove()
	self._unit:set_slot(0)
end

function ECMJammerBase:save(data)
	local state = {
		jammer_active = self._jammer_active or nil,
		feedback_active = self._feedback_active or nil,
		low_battery = self._battery_low or nil,
		owner_id = self._owner_id
	}
	data.ECMJammerBase = state
end

function ECMJammerBase:load(data)
	local state = data.ECMJammerBase
	self._owner_id = state.owner_id

	if state.jammer_active then
		self:set_active(true)

		if state.low_battery then
			self:_set_battery_low()
		end
	else
		self:_set_battery_empty()
	end

	if state.feedback_active then
		self:_set_feedback_active(true)
	end

	self._was_dropin = true
end

function ECMJammerBase:destroy()
	if self._validate_clbk_id then
		managers.enemy:remove_delayed_clbk(self._validate_clbk_id)

		self._validate_clbk_id = nil
	end

	self:set_active(false)
	self:_set_feedback_active(false)
end

