require("lib/units/weapons/grenades/GrenadeBase")

ElectricGrenade = ElectricGrenade or class(GrenadeBase)
ElectricGrenade._PLAYER_TASE_RANGE = 200

function ElectricGrenade:_setup_from_tweak_data()
	local grenade_entry = self._tweak_projectile_entry or "wpn_gre_electric"
	local tweak_entry = tweak_data.projectiles[grenade_entry]
	self._init_timer = tweak_entry.init_timer or 2.5
	self._mass_look_up_modifier = tweak_entry.mass_look_up_modifier
	self._range = tweak_entry.range
	self._effect_name = tweak_entry.effect_name or "effects/particles/explosions/electric_grenade"
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

function ElectricGrenade:clbk_impact(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	if other_unit and other_unit:vehicle() and other_unit:vehicle():is_active() then
		return
	end

	self:_detonate(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
end

function ElectricGrenade:_on_collision(col_ray)
	if col_ray and col_ray.unit:vehicle() and col_ray.unit:vehicle():is_active() then
		return
	end

	self:_detonate()
end

function ElectricGrenade:_detonate(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	local pos = self._unit:position()
	local normal = math.UP
	local range = self._range
	local slot_mask = managers.slot:get_mask("explosion_targets")

	managers.explosion:play_sound_and_effects(pos, normal, range, self._custom_params)

	local hit_units, splinters = managers.explosion:detect_and_tase({
		player_damage = 0,
		tase_strength = "heavy",
		hit_pos = pos,
		range = range,
		collision_slotmask = slot_mask,
		curve_pow = self._curve_pow,
		damage = self._damage,
		ignore_unit = self._unit,
		alert_radius = self._alert_radius,
		user = self:thrower_unit() or self._unit,
		owner = self._unit,
		verify_callback = callback(self, self, "_can_tase_unit")
	})

	managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", GrenadeBase.EVENT_IDS.detonate)
	self:_tase_player()
	self._unit:set_slot(0)
end

function ElectricGrenade:_can_tase_unit(unit)
	local unit_name = nil

	if unit and unit:base() then
		unit_name = unit:base()._tweak_table
	end

	if alive(unit) and unit:brain() and unit:brain().is_hostage and unit:brain():is_hostage() then
		return false
	end

	if unit_name then
		return tweak_data:get_raw_value("character", unit_name, "damage", "hurt_severity", "tase") ~= false
	else
		return true
	end
end

function ElectricGrenade:_detonate_on_client()
	local pos = self._unit:position()
	local range = self._range

	managers.explosion:play_sound_and_effects(pos, math.UP, range, self._custom_params)
	self:_tase_player()
end

function ElectricGrenade:_tase_player()
	local player = managers.player:player_unit()

	if alive(player) and player == self:thrower_unit() and player:character_damage().on_self_tased then
		local detonate_pos = self._unit:position() + math.UP * 100
		local range = self._PLAYER_TASE_RANGE
		local affected, line_of_sight, travel_dis, linear_dis = QuickFlashGrenade._chk_dazzle_local_player(self, detonate_pos, range)

		if affected then
			player:character_damage():on_self_tased(0.2)
		end
	end
end

function ElectricGrenade:bullet_hit()
	if not Network:is_server() then
		return
	end

	self._timer = nil

	self:_detonate()
end
