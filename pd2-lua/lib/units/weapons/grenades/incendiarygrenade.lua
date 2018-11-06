IncendiaryGrenade = IncendiaryGrenade or class(GrenadeBase)

function IncendiaryGrenade:init(unit)
	IncendiaryGrenade.super.super.init(self, unit)

	self._detonated = false
end

function IncendiaryGrenade:clbk_impact(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity)
	self:_detonate(normal)
end

function IncendiaryGrenade:_detonate(normal)
	if self._detonated == false then
		self._detonated = true

		self:_spawn_environment_fire(normal)
		managers.network:session():send_to_peers_synched("sync_detonate_incendiary_grenade", self._unit, "base", GrenadeBase.EVENT_IDS.detonate, normal)
	end
end

function IncendiaryGrenade:sync_detonate_incendiary_grenade(event_id, normal)
	if event_id == GrenadeBase.EVENT_IDS.detonate then
		self:_detonate_on_client(normal)
	end
end

function IncendiaryGrenade:_detonate_on_client(normal)
	if self._detonated == false then
		self._detonated = true

		self:_spawn_environment_fire(normal)
	end
end

function IncendiaryGrenade:_spawn_environment_fire(normal)
	local position = self._unit:position()
	local rotation = self._unit:rotation()
	local data = tweak_data.env_effect:incendiary_fire()
	local tweak = tweak_data.projectiles[self._tweak_projectile_entry] or {}
	data.burn_duration = tweak.burn_duration or data.burn_duration or 10
	data.sound_event_impact_duration = tweak.sound_event_impact_duration or data.sound_event_impact_duration or 1

	EnvironmentFire.spawn(position, rotation, data, normal, self._thrower_unit, 0, 1)
	self._unit:set_visible(false)

	self.burn_stop_time = TimerManager:game():time() + data.fire_dot_data.dot_length + 1
end

function IncendiaryGrenade:bullet_hit()
	if not Network:is_server() then
		return
	end

	self:_detonate()
end

function IncendiaryGrenade:add_damage_result(unit, is_dead, damage_percent)
	if not alive(self._thrower_unit) or self._thrower_unit ~= managers.player:player_unit() then
		return
	end

	local unit_type = unit:base()._tweak_table
	local is_civlian = unit:character_damage().is_civilian(unit_type)
	local is_gangster = unit:character_damage().is_gangster(unit_type)
	local is_cop = unit:character_damage().is_cop(unit_type)

	if is_civlian then
		return
	end

	if is_dead then
		self:_check_achievements(unit, is_dead, damage_percent, 1, 1)
	end
end

function IncendiaryGrenade:update(unit, t, dt)
	GrenadeBase.update(self, unit, t, dt)

	local is_burn_finish = self.burn_stop_time and self.burn_stop_time < t

	if is_burn_finish then
		local LOG = "[Lua_CriticalHit]"

		print(LOG, "BURN FINISH")
		self._unit:set_slot(0)
	end
end
