QuickCsGrenade = QuickCsGrenade or class(GrenadeBase)

function QuickCsGrenade:init(unit)
	self._unit = unit
	self._state = 0
	self._has_played_VO = false

	self:_setup_from_tweak_data()
end

function QuickCsGrenade:_setup_from_tweak_data()
	local grenade_entry = self._tweak_projectile_entry or "cs_grenade_quick"
	self._tweak_data = tweak_data.projectiles[grenade_entry]
	self._radius = self._tweak_data.radius or 300
	self._radius_blurzone_multiplier = self._tweak_data.radius_blurzone_multiplier or 1.3
	self._damage_tick_period = self._tweak_data.damage_tick_period or 0.25
	self._damage_per_tick = self._tweak_data.damage_per_tick or 0.75
end

function QuickCsGrenade:update(unit, t, dt)
	if self._remove_t and self._remove_t < t then
		self._unit:set_slot(0)
	end

	if self._state == 1 then
		self._timer = self._timer - dt

		if self._timer <= 0 then
			self._timer = self._timer + 0.5
			self._state = 2

			self:_play_sound_and_effects()
		end
	elseif self._state == 2 then
		self._timer = self._timer - dt

		if self._timer <= 0 then
			self._state = 3

			self:detonate()
		end
	elseif self._state == 3 and (not self._last_damage_tick or t > self._last_damage_tick + self._damage_tick_period) then
		self:_do_damage()

		self._last_damage_tick = t
	end
end

function QuickCsGrenade:activate(position, duration)
	self._state = 1
	self._timer = 0.5
	self._shoot_position = position
	self._duration = duration

	self:_play_sound_and_effects()
end

function QuickCsGrenade:detonate()
	self:_play_sound_and_effects()

	self._remove_t = TimerManager:game():time() + self._duration
end

function QuickCsGrenade:preemptive_kill()
	self._unit:sound_source():post_event("grenade_gas_stop")
	self._unit:set_slot(0)
end

function QuickCsGrenade:_do_damage()
	local player_unit = managers.player:player_unit()

	if player_unit and mvector3.distance_sq(self._unit:position(), player_unit:position()) < self._tweak_data.radius * self._tweak_data.radius then
		local attack_data = {
			damage = self._damage_per_tick,
			col_ray = {
				ray = math.UP
			}
		}

		player_unit:character_damage():damage_killzone(attack_data)

		if not self._has_played_VO then
			PlayerStandard.say_line(player_unit:sound(), "g42x_any")

			self._has_played_VO = true
		end
	end
end

function QuickCsGrenade:_play_sound_and_effects()
	if self._state == 1 then
		local sound_source = SoundDevice:create_source("grenade_fire_source")

		sound_source:set_position(self._shoot_position)
		sound_source:post_event("grenade_gas_npc_fire")
	elseif self._state == 2 then
		local bounce_point = Vector3()

		mvector3.lerp(bounce_point, self._shoot_position, self._unit:position(), 0.65)

		local sound_source = SoundDevice:create_source("grenade_bounce_source")

		sound_source:set_position(bounce_point)
		sound_source:post_event("grenade_gas_bounce")
	elseif self._state == 3 then
		World:effect_manager():spawn({
			effect = Idstring("effects/particles/explosions/explosion_smoke_grenade"),
			position = self._unit:position(),
			normal = self._unit:rotation():y()
		})
		self._unit:sound_source():post_event("grenade_gas_explode")

		local parent = self._unit:orientation_object()
		self._smoke_effect = World:effect_manager():spawn({
			effect = Idstring("effects/particles/explosions/cs_grenade_smoke"),
			parent = parent
		})
		local blurzone_radius = self._radius * self._radius_blurzone_multiplier

		managers.environment_controller:set_blurzone(self._unit:key(), 1, self._unit:position(), blurzone_radius, 0, true)
	end
end

function QuickCsGrenade:destroy()
	if self._smoke_effect then
		World:effect_manager():fade_kill(self._smoke_effect)
	end

	managers.environment_controller:set_blurzone(self._unit:key(), 0)
end
