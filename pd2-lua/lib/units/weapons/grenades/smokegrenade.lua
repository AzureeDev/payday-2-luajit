SmokeGrenade = SmokeGrenade or class(GrenadeBase)

function SmokeGrenade:init(unit)
	self._init_timer = 1.5

	SmokeGrenade.super.init(self, unit)
end

function SmokeGrenade:update(unit, t, dt)
	SmokeGrenade.super.update(self, unit, t, dt)

	if self._smoke_timer then
		self._smoke_timer = self._smoke_timer - dt

		if self._smoke_timer <= 0 then
			self._smoke_timer = nil

			World:effect_manager():fade_kill(self._smoke_effect)
		end
	end
end

function SmokeGrenade:_detonate()
	local units = World:find_units("sphere", self._unit:position(), 400, self._slotmask)

	for _, unit in ipairs(units) do
		local col_ray = {
			ray = (unit:position() - self._unit:position()):normalized(),
			position = self._unit:position()
		}

		self:_give_smoke_damage(col_ray, unit, 10)
	end
end

function SmokeGrenade:_play_sound_and_effects()
	World:effect_manager():spawn({
		effect = Idstring("effects/particles/explosions/explosion_smoke_grenade"),
		position = self._unit:position(),
		normal = self._unit:rotation():y()
	})
	self._unit:sound_source():post_event("trip_mine_explode")

	local parent = self._unit:orientation_object()
	self._smoke_effect = World:effect_manager():spawn({
		effect = Idstring("effects/particles/explosions/smoke_grenade_smoke"),
		parent = parent
	})
	self._smoke_timer = 10
end

function SmokeGrenade:_give_smoke_damage(col_ray, unit, damage)
end

function SmokeGrenade:destroy()
	if self._smoke_effect then
		World:effect_manager():kill(self._smoke_effect)
	end

	SmokeGrenade.super.destroy(self)
end
