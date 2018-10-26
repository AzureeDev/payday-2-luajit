TankCopDamage = TankCopDamage or class(CopDamage)

function TankCopDamage:init(...)
	TankCopDamage.super.init(self, ...)

	self._is_halloween = self._unit:name() == Idstring("units/payday2/characters/ene_bulldozer_4/ene_bulldozer_4")
end

function TankCopDamage:damage_bullet(attack_data, ...)
	if self._is_halloween then
		attack_data.damage = math.min(attack_data.damage, 235)
	end

	return TankCopDamage.super.damage_bullet(self, attack_data, ...)
end

function TankCopDamage:seq_clbk_vizor_shatter()
	if not self._unit:character_damage():dead() then
		self._unit:sound():say("visor_lost")
		managers.modifiers:run_func("OnTankVisorShatter", self._unit)
	end
end

