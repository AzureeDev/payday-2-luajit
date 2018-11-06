QuickSmokeGrenade = QuickSmokeGrenade or class()

function QuickSmokeGrenade:init(unit)
	self._unit = unit
	self._state = 0
end

function QuickSmokeGrenade:update(unit, t, dt)
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
	end
end

function QuickSmokeGrenade:activate(position, duration)
	self:_activate(1, 0.5, position, duration)
end

function QuickSmokeGrenade:activate_immediately(position, duration)
	self:_activate(3, 0, position, duration)

	self._remove_t = TimerManager:game():time() + self._duration
end

function QuickSmokeGrenade:_activate(state, timer, position, duration)
	self._state = state
	self._timer = timer
	self._shoot_position = position
	self._duration = duration

	self:_play_sound_and_effects()
end

function QuickSmokeGrenade:detonate()
	self:_play_sound_and_effects()

	self._remove_t = TimerManager:game():time() + self._duration
end

function QuickSmokeGrenade:preemptive_kill()
	self._unit:sound_source():post_event("grenade_gas_stop")
	self._unit:set_slot(0)
end

function QuickSmokeGrenade:_play_sound_and_effects()
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
			effect = Idstring("effects/particles/explosions/smoke_grenade_smoke"),
			parent = parent
		})
	end
end

function QuickSmokeGrenade:destroy()
	if self._smoke_effect then
		World:effect_manager():fade_kill(self._smoke_effect)
	end
end
