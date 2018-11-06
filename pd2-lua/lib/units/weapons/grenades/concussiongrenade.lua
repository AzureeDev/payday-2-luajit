ConcussionGrenade = ConcussionGrenade or class(GrenadeBase)
ConcussionGrenade._PLAYER_FLASH_RANGE = 500

function ConcussionGrenade:_setup_from_tweak_data()
	local grenade_entry = self._tweak_projectile_entry or "concussion"
	local tweak_entry = tweak_data.projectiles[grenade_entry]
	self._init_timer = tweak_entry.init_timer or 2.5
	self._mass_look_up_modifier = tweak_entry.mass_look_up_modifier
	self._range = tweak_entry.range
	self._effect_name = tweak_entry.effect_name or "effects/particles/explosions/explosion_flash_grenade"
	self._curve_pow = tweak_entry.curve_pow or 3
	self._damage = tweak_entry.damage
	self._player_damage = tweak_entry.player_damage
	self._alert_radius = tweak_entry.alert_radius
	local sound_event = tweak_entry.sound_event or "grenade_explode"
	self._custom_params = {
		camera_shake_max_mul = 4,
		effect = self._effect_name,
		sound_event = sound_event,
		feedback_range = self._range * 2
	}
end

function ConcussionGrenade:clbk_impact(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	if other_unit and other_unit:vehicle() and other_unit:vehicle():is_active() then
		return
	end

	self:_detonate(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
end

function ConcussionGrenade:_on_collision(col_ray)
	if col_ray and col_ray.unit:vehicle() and col_ray.unit:vehicle():is_active() then
		return
	end

	self:_detonate()
end

function ConcussionGrenade:_detonate(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	local pos = self._unit:position()
	local normal = math.UP
	local range = self._range
	local slot_mask = managers.slot:get_mask("explosion_targets")

	managers.explosion:play_sound_and_effects(pos, normal, range, self._custom_params)

	local hit_units, splinters = managers.explosion:detect_and_stun({
		player_damage = 0,
		hit_pos = pos,
		range = range,
		collision_slotmask = slot_mask,
		curve_pow = self._curve_pow,
		damage = self._damage,
		ignore_unit = self._unit,
		alert_radius = self._alert_radius,
		user = self._unit,
		verify_callback = callback(self, self, "_can_stun_unit")
	})

	managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", GrenadeBase.EVENT_IDS.detonate)
	self:_flash_player()
	self._unit:set_slot(0)
end

function ConcussionGrenade:_can_stun_unit(unit)
	local can_stun = false
	local unit_name = nil

	if unit and unit:base() then
		unit_name = unit:base()._tweak_table
	end

	if unit_name then
		return not tweak_data.character[unit_name] or {}.immune_to_concussion
	else
		return true
	end
end

function ConcussionGrenade:_detonate_on_client()
	local pos = self._unit:position()
	local range = self._range

	managers.explosion:explode_on_client(pos, math.UP, nil, self._damage, range, self._curve_pow, self._custom_params)
	self:_flash_player()
end

function ConcussionGrenade:_flash_player()
	local detonate_pos = self._unit:position() + math.UP * 100
	local range = self._PLAYER_FLASH_RANGE
	local affected, line_of_sight, travel_dis, linear_dis = QuickFlashGrenade._chk_dazzle_local_player(self, detonate_pos, range)

	if affected then
		managers.environment_controller:set_concussion_grenade(detonate_pos, line_of_sight, travel_dis, linear_dis, tweak_data.character.concussion_multiplier)

		local sound_eff_mul = math.clamp(1 - (travel_dis or linear_dis) / range, 0.3, 1)

		managers.player:player_unit():character_damage():on_concussion(sound_eff_mul)
	end
end

function ConcussionGrenade:bullet_hit()
	if not Network:is_server() then
		return
	end

	self._timer = nil

	self:_detonate()
end
