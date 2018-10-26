FragGrenade = FragGrenade or class(GrenadeBase)

function FragGrenade:_setup_from_tweak_data()
	local grenade_entry = self._tweak_projectile_entry or "frag"
	local tweak_entry = tweak_data.projectiles[grenade_entry]
	self._init_timer = tweak_entry.init_timer or 2.5
	self._mass_look_up_modifier = tweak_entry.mass_look_up_modifier
	self._range = tweak_entry.range
	self._effect_name = tweak_entry.effect_name or "effects/payday2/particles/explosions/grenade_explosion"
	self._curve_pow = tweak_entry.curve_pow or 3
	self._damage = tweak_entry.damage
	self._player_damage = tweak_entry.player_damage
	self._alert_radius = tweak_entry.alert_radius
	local sound_event = tweak_entry.sound_event or "grenade_explode"
	self._custom_params = {
		camera_shake_max_mul = 4,
		sound_muffle_effect = true,
		effect = self._effect_name,
		sound_event = sound_event,
		feedback_range = self._range * 2
	}

	return tweak_entry
end

function FragGrenade:update(unit, t, dt)
	FragGrenade.super.update(self, unit, t, dt)
end

function FragGrenade:clbk_impact(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	local reflect = other_unit and other_unit:vehicle() and other_unit:vehicle():is_active()
	reflect = managers.modifiers:modify_value("FragGrenade:ShouldReflect", reflect, other_unit, self._unit)

	if reflect then
		return
	end

	self:_detonate(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
end

function FragGrenade:_on_collision(col_ray)
	local reflect = col_ray and col_ray.unit:vehicle() and col_ray.unit:vehicle():is_active()
	reflect = managers.modifiers:modify_value("FragGrenade:ShouldReflect", reflect, col_ray and col_ray.unit, self._unit)

	if reflect then
		return
	end

	self:_detonate()
end

function FragGrenade:_detonate(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	local pos = self._unit:position()
	local normal = math.UP
	local range = self._range
	local slot_mask = managers.slot:get_mask("explosion_targets")

	managers.explosion:give_local_player_dmg(pos, range, self._player_damage)
	managers.explosion:play_sound_and_effects(pos, normal, range, self._custom_params)

	local hit_units, splinters = managers.explosion:detect_and_give_dmg({
		player_damage = 0,
		hit_pos = pos,
		range = range,
		collision_slotmask = slot_mask,
		curve_pow = self._curve_pow,
		damage = self._damage,
		ignore_unit = self._unit,
		alert_radius = self._alert_radius,
		user = self:thrower_unit() or self._unit,
		owner = self._unit
	})

	managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", GrenadeBase.EVENT_IDS.detonate)
	self._unit:set_slot(0)
end

function FragGrenade:_detonate_on_client()
	local pos = self._unit:position()
	local range = self._range

	managers.explosion:give_local_player_dmg(pos, range, self._player_damage)
	managers.explosion:explode_on_client(pos, math.UP, nil, self._damage, range, self._curve_pow, self._custom_params)
end

function FragGrenade:bullet_hit()
	if not Network:is_server() then
		return
	end

	print("FragGrenade:bullet_hit()")

	self._timer = nil

	self:_detonate()
end

