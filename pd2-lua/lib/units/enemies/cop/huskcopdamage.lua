HuskCopDamage = HuskCopDamage or class(CopDamage)

function HuskCopDamage:die(variant)
	CopDamage.MAD_3_ACHIEVEMENT(variant)
	self:_check_friend_4(variant)
	self._unit:base():set_slot(self._unit, 17)

	if self._unit:inventory() then
		self._unit:inventory():drop_shield()
	end

	variant = variant or "bullet"
	self._health = 0
	self._health_ratio = 0
	self._dead = true

	self:set_mover_collision_state(false)

	if self._unit:interaction() and self._unit:interaction().tweak_data == "hostage_convert" then
		self._unit:interaction():set_active(false)
	end

	if self._death_sequence then
		if self._unit:damage() and self._unit:damage():has_sequence(self._death_sequence) then
			self._unit:damage():run_sequence_simple(self._death_sequence)
		else
			debug_pause_unit(self._unit, "[HuskCopDamage:die] does not have death sequence", self._death_sequence, self._unit)
		end
	end

	if self._unit:base():char_tweak().die_sound_event then
		self._unit:sound():play(self._unit:base():char_tweak().die_sound_event, nil, nil)
	end

	self:_on_death()
end
