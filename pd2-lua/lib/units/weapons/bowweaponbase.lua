BowWeaponBase = BowWeaponBase or class(ProjectileWeaponBase)

function BowWeaponBase:init(unit)
	BowWeaponBase.super.init(self, unit)

	self._client_authoritative = true
	self._no_reload = false
	self._steelsight_speed = 0.5
end

function BowWeaponBase:trigger_pressed(...)
	self:_start_charging()
end

function BowWeaponBase:trigger_held(...)
	if not self._charging and not self._cancelled then
		self:_start_charging()
	end
end

function BowWeaponBase:_start_charging()
	self._cancelled = nil
	self._charging = true
	self._charge_start_t = managers.player:player_timer():time()

	self:play_tweak_data_sound("charge")
end

function BowWeaponBase:set_tased_shot(bool)
	self._is_tased_shot = bool
end

function BowWeaponBase:trigger_released(...)
	local fired = nil

	if self._charging and not self._cancelled and self:start_shooting_allowed() then
		fired = self:fire(...)

		if fired then
			self:play_tweak_data_sound(self:charge_fail() and "charge_release_fail" or "charge_release")

			local next_fire = (tweak_data.weapon[self._name_id].fire_mode_data and tweak_data.weapon[self._name_id].fire_mode_data.fire_rate or 0) / self:fire_rate_multiplier()
			self._next_fire_allowed = self._next_fire_allowed + next_fire
		end
	end

	self._charging = nil
	self._cancelled = nil

	return fired
end

function BowWeaponBase:add_damage_result(unit, is_dead, attacker, damage_percent)
	if not alive(attacker) or attacker ~= managers.player:player_unit() then
		return
	end

	managers.statistics:shot_fired({
		skip_bullet_count = true,
		hit = true,
		weapon_unit = self._unit
	})
end

function BowWeaponBase:_spawn_muzzle_effect()
end

function BowWeaponBase:charge_fail()
	return self:charge_multiplier() < 0.2
end

function BowWeaponBase:charge_multiplier()
	if self._is_tased_shot then
		return 1
	end

	local charge_multiplier = 1

	if self._charge_start_t then
		local delta_t = managers.player:player_timer():time() - self._charge_start_t
		charge_multiplier = math.min(delta_t / self:charge_max_t(), 1)
	end

	return charge_multiplier
end

function BowWeaponBase:projectile_speed_multiplier()
	return math.lerp(0.05, 1, self:charge_multiplier())
end

function BowWeaponBase:projectile_damage_multiplier()
	return math.lerp(0.1, 1, self:charge_multiplier())
end

function BowWeaponBase:projectile_charge_value()
	return self:charge_multiplier()
end

function BowWeaponBase:_adjust_throw_z(m_vec)
	local adjust_z = math.lerp(0, 0.05, 1 - math.abs(mvector3.z(m_vec)))

	mvector3.set_z(m_vec, mvector3.z(m_vec) + adjust_z)
end

function BowWeaponBase:fire_on_release()
	return true
end

function BowWeaponBase:can_refire_while_tased()
	return false
end

function BowWeaponBase:charging()
	return self._charging and not self._cancelled
end

function BowWeaponBase:interupt_charging()
	self._charging = nil
	self._cancelled = nil

	self:play_tweak_data_sound("charge_cancel")
end

function BowWeaponBase:manages_steelsight()
	return true
end

function BowWeaponBase:steelsight_pressed()
	if self._cancelled then
		return
	end

	if self._charging then
		self._cancelled = true

		self:play_tweak_data_sound("charge_cancel")
	end

	return {
		exit_steelsight = true
	}
end

function BowWeaponBase:wants_steelsight()
	return self._charging and not self._cancelled
end

function BowWeaponBase:enter_steelsight_speed_multiplier()
	return self._steelsight_speed * BowWeaponBase.super.enter_steelsight_speed_multiplier(self)
end

function BowWeaponBase:reload_speed_multiplier()
	local code_miss_multiplier = self:weapon_tweak_data().bow_reload_speed_multiplier or 1

	return code_miss_multiplier * BowWeaponBase.super.reload_speed_multiplier(self)
end

function BowWeaponBase:set_ammo_max(ammo_max)
	BowWeaponBase.super.set_ammo_max(self, ammo_max)

	if self._no_reload then
		self:set_ammo_max_per_clip(ammo_max)
	end
end

function BowWeaponBase:set_ammo_total(ammo_total)
	BowWeaponBase.super.set_ammo_total(self, ammo_total)

	if self._no_reload then
		self:set_ammo_remaining_in_clip(ammo_total)
	end
end

function BowWeaponBase:replenish()
	BowWeaponBase.super.replenish(self)

	if self._no_reload then
		self:set_ammo_remaining_in_clip(self:get_ammo_total())
	end
end

function BowWeaponBase:charge_max_t()
	return self:weapon_tweak_data().charge_data.max_t
end

CrossbowWeaponBase = CrossbowWeaponBase or class(ProjectileWeaponBase)

function CrossbowWeaponBase:init(unit)
	CrossbowWeaponBase.super.init(self, unit)

	self._client_authoritative = true
end

function CrossbowWeaponBase:should_reload_immediately()
	return true
end

function CrossbowWeaponBase:charge_fail()
	return false
end

function CrossbowWeaponBase:add_damage_result(unit, is_dead, attacker, damage_percent)
	if not alive(attacker) or attacker ~= managers.player:player_unit() then
		return
	end

	managers.statistics:shot_fired({
		skip_bullet_count = true,
		hit = true,
		weapon_unit = self._unit
	})
end
