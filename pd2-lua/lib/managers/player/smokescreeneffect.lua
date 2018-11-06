SmokeScreenEffect = SmokeScreenEffect or class()

function SmokeScreenEffect:init(position, normal, time, has_dodge_bonus, grenade_unit)
	self._timer = time
	self._position = position
	self._radius = 400
	self._unit_list = {}
	self._dodge_bonus = has_dodge_bonus and managers.player:upgrade_value_by_level("player", "smoke_screen_ally_dodge_bonus", 1) or 0
	self._sound_source = SoundDevice:create_source("ExplosionManager")

	self._sound_source:set_position(position)
	self._sound_source:post_event("lung_explode")

	self._effect = World:effect_manager():spawn({
		effect = Idstring("effects/particles/explosions/smoke_screen"),
		position = position,
		normal = normal
	})
	self._variant = grenade_unit and grenade_unit:base() and grenade_unit:base()._projectile_entry
	self._mine = grenade_unit and grenade_unit:base():thrower_unit() == managers.player:player_unit()
end

function SmokeScreenEffect:variant()
	return self._variant
end

function SmokeScreenEffect:dodge_bonus()
	return self._dodge_bonus
end

function SmokeScreenEffect:position()
	return self._position
end

function SmokeScreenEffect:alive()
	return not not self._timer
end

function SmokeScreenEffect:is_in_smoke(unit)
	return self._unit_list[unit:key()], self._variant
end

function SmokeScreenEffect:mine()
	return self._mine
end

function SmokeScreenEffect:update(t, dt)
	if self._timer then
		self._timer = self._timer - dt

		if self._timer <= 2 then
			World:effect_manager():fade_kill(self._effect)

			if not self._sound_killed then
				self._sound_source:post_event("lung_loop_end")
				managers.enemy:add_delayed_clbk("SmokeScreenEffect", callback(ProjectileBase, ProjectileBase, "_dispose_of_sound", {
					sound_source = self._sound_source
				}), TimerManager:game():time() + 4)

				self._sound_killed = true
			end
		end

		if self._timer <= 0 then
			self._timer = nil
		end
	end

	self._unit_list = {}
	local nearby_units = World:find_units_quick("sphere", self._position, self._radius, managers.slot:get_mask("persons"))

	for _, unit in ipairs(nearby_units) do
		self._unit_list[unit:key()] = true
	end
end

function SmokeScreenEffect:destroy()
	if self._effect then
		World:effect_manager():kill(self._effect)
	end
end
