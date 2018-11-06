QuickFlashGrenade = QuickFlashGrenade or class()
QuickFlashGrenade.States = {
	{
		"_state_launched",
		1
	},
	{
		"_state_bounced"
	},
	{
		"_state_detonated",
		3
	},
	{
		"_state_destroy",
		0
	}
}
QuickFlashGrenade.Events = {
	DestroyedByPlayer = 1,
	[1.0] = "on_flashbang_destroyed"
}

function QuickFlashGrenade:init(unit)
	self._unit = unit
	self._state = 0
	self._armed = false

	for i, state in ipairs(QuickFlashGrenade.States) do
		if state[2] == nil then
			QuickFlashGrenade.States[i][2] = tweak_data.group_ai.flash_grenade.timer
		end
	end

	if Network:is_client() then
		self:activate(self._unit:position(), tweak_data.group_ai.flash_grenade_lifetime)
	end
end

function QuickFlashGrenade:update(unit, t, dt)
	if self._destroyed_t then
		self._destroyed_t = self._destroyed_t - dt

		if self._destroyed_t <= 0 then
			self:destroy_unit()
		end
	end

	if self._destroyed or not self._armed then
		return
	end

	if self._timer then
		self._timer = self._timer - dt

		if self._timer <= 0 then
			self._state = self._state + 1
			local state = QuickFlashGrenade.States[self._state]

			if state then
				self[state[1]](self)

				self._timer = state[2]
			else
				self._timer = nil
			end
		end
	end

	if self._state == 2 then
		if self._beep_t then
			self._beep_t = self._beep_t - dt

			if self._beep_t < 0 then
				self:_beep()
			end
		else
			self:_beep()
		end
	end

	if alive(self._light) then
		self._light_multiplier = math.clamp(self._light_multiplier - dt * tweak_data.group_ai.flash_grenade.beep_fade_speed, 0, 1)

		self._light:set_multiplier(self._light_multiplier)
		self._light:set_far_range(tweak_data.group_ai.flash_grenade.light_range * self._light_multiplier)
	end
end

function QuickFlashGrenade:_beep()
	self._unit:sound_source():post_event("pfn_beep")

	self._beep_t = self:_get_next_beep_time()
	self._light_multiplier = tweak_data.group_ai.flash_grenade.beep_multi
end

function QuickFlashGrenade:timer(new)
	if not self._timer then
		self._timer = 3
	end

	self._timer = new or self._timer

	return self._timer
end

function QuickFlashGrenade:_get_next_beep_time()
	local beep_speed = tweak_data.group_ai.flash_grenade.beep_speed

	return self:timer() / beep_speed[1] * beep_speed[2]
end

function QuickFlashGrenade:activate(position, duration)
	self:_activate(0, 0, position, duration)
end

function QuickFlashGrenade:activate_immediately(position, duration)
	self:_activate(2, 0, position, duration)
end

function QuickFlashGrenade:_activate(state, timer, position, duration)
	self._armed = true
	self._timer = timer
	self._shoot_position = position
	self._duration = duration
end

function QuickFlashGrenade:_state_launched()
	self._unit:damage():run_sequence_simple("insert")

	local sound_source = SoundDevice:create_source("grenade_fire_source")

	sound_source:set_position(self._shoot_position)
	sound_source:post_event("grenade_gas_npc_fire")
end

function QuickFlashGrenade:_state_bounced()
	self._unit:damage():run_sequence_simple("activate")

	local bounce_point = Vector3()

	mvector3.lerp(bounce_point, self._shoot_position, self._unit:position(), 0.65)

	local sound_source = SoundDevice:create_source("grenade_bounce_source")

	sound_source:set_position(bounce_point)
	sound_source:post_event("flashbang_bounce", callback(self, self, "sound_playback_complete_clbk"), sound_source, "end_of_event")

	local light = World:create_light("omni|specular")

	light:set_far_range(tweak_data.group_ai.flash_grenade.light_range)
	light:set_color(tweak_data.group_ai.flash_grenade.light_color)
	light:set_position(self._unit:position())
	light:set_specular_multiplier(tweak_data.group_ai.flash_grenade.light_specular)
	light:set_enable(true)
	light:set_multiplier(0)
	light:set_falloff_exponent(0.5)

	self._light = light
	self._light_multiplier = 0
end

function QuickFlashGrenade:_state_detonated()
	local detonate_pos = self._unit:position()

	self:make_flash(detonate_pos, tweak_data.group_ai.flash_grenade.range)
	managers.groupai:state():propagate_alert({
		"aggression",
		detonate_pos,
		10000,
		managers.groupai:state():get_unit_type_filter("civilians_enemies")
	})
	self._unit:damage():run_sequence_simple("detonate")
end

function QuickFlashGrenade:_state_destroy()
	self:destroy_unit()
end

function QuickFlashGrenade:make_flash(detonate_pos, range, ignore_units)
	local range = range or 1000
	local effect_params = {
		sound_event = "flashbang_explosion",
		effect = "effects/particles/explosions/explosion_flash_grenade",
		camera_shake_max_mul = 4,
		feedback_range = range * 2
	}

	managers.explosion:play_sound_and_effects(detonate_pos, math.UP, range, effect_params)

	ignore_units = ignore_units or {}

	table.insert(ignore_units, self._unit)

	local affected, line_of_sight, travel_dis, linear_dis = self:_chk_dazzle_local_player(detonate_pos, range, ignore_units)

	if affected then
		managers.environment_controller:set_flashbang(detonate_pos, line_of_sight, travel_dis, linear_dis, tweak_data.character.flashbang_multiplier)

		local sound_eff_mul = math.clamp(1 - (travel_dis or linear_dis) / range, 0.3, 1)

		managers.player:player_unit():character_damage():on_flashbanged(sound_eff_mul)
	end
end

function QuickFlashGrenade:_chk_dazzle_local_player(detonate_pos, range, ignore_units)
	local player = managers.player:player_unit()

	if not alive(player) then
		return
	end

	local detonate_pos = detonate_pos or self._unit:position() + math.UP * 150
	local m_pl_head_pos = player:movement():m_head_pos()
	local linear_dis = mvector3.distance(detonate_pos, m_pl_head_pos)

	if range < linear_dis then
		return
	end

	local slotmask = managers.slot:get_mask("bullet_impact_targets")

	local function _vis_ray_func(from, to, boolean)
		if ignore_units then
			return World:raycast("ray", from, to, "ignore_unit", ignore_units, "slot_mask", slotmask, boolean and "report" or nil)
		else
			return World:raycast("ray", from, to, "slot_mask", slotmask, boolean and "report" or nil)
		end
	end

	if not _vis_ray_func(m_pl_head_pos, detonate_pos, true) then
		return true, true, nil, linear_dis
	end

	local random_rotation = Rotation(360 * math.random(), 360 * math.random(), 360 * math.random())
	local raycast_dir = Vector3()
	local bounce_pos = Vector3()

	for _, axis in ipairs({
		"x",
		"y",
		"z"
	}) do
		for _, polarity in ipairs({
			1,
			-1
		}) do
			mvector3.set_zero(raycast_dir)
			mvector3["set_" .. axis](raycast_dir, polarity)
			mvector3.rotate_with(raycast_dir, random_rotation)
			mvector3.set(bounce_pos, raycast_dir)
			mvector3.multiply(bounce_pos, range)
			mvector3.add(bounce_pos, detonate_pos)

			local bounce_ray = _vis_ray_func(detonate_pos, bounce_pos)

			if bounce_ray then
				mvector3.set(bounce_pos, raycast_dir)
				mvector3.multiply(bounce_pos, -1 * math.min(bounce_ray.distance, 10))
				mvector3.add(bounce_pos, bounce_ray.position)

				local return_ray = _vis_ray_func(m_pl_head_pos, bounce_pos, true)

				if not return_ray then
					local travel_dis = bounce_ray.distance + mvector3.distance(m_pl_head_pos, bounce_pos)

					if range > travel_dis then
						return true, false, travel_dis, linear_dis
					end
				end
			end
		end
	end
end

function QuickFlashGrenade:sound_playback_complete_clbk(event_instance, sound_source, event_type, sound_source_again)
end

function QuickFlashGrenade:preemptive_kill()
	self:destroy_unit()
end

function QuickFlashGrenade:destroy_unit()
	self._unit:set_slot(0)
end

function QuickFlashGrenade:remove_light()
	if alive(self._light) then
		World:delete_light(self._light)

		self._light = nil
	end
end

function QuickFlashGrenade:destroy()
	self:remove_light()
end

function QuickFlashGrenade:on_flashbang_destroyed(prevent_network)
	if not prevent_network then
		managers.network:session():send_to_peers_synched("sync_flashbang_event", self._unit, QuickFlashGrenade.Events.DestroyedByPlayer)
	end

	self._unit:sound_source():post_event("pfn_beep_end")

	self._destroyed = true
	self._destroyed_t = 1

	self:remove_light()
end

function QuickFlashGrenade:on_network_event(event_id)
	local event = QuickFlashGrenade.Events[event_id]

	if event and self[event] then
		self[event](self, true)
	else
		Application:error("Received a network event id that is not mapped!")
	end
end
