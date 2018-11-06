HuskMedicDamage = HuskMedicDamage or class(HuskCopDamage)

function HuskMedicDamage:init(...)
	HuskMedicDamage.super.init(self, ...)

	self._heal_cooldown_t = 0
	self._debug_brush = Draw:brush(Color(0.5, 0.5, 0, 1))
end

function HuskMedicDamage:update(...)
	MedicDamage.update(self, ...)
end

function HuskMedicDamage:heal_unit(...)
	return MedicDamage.heal_unit(self, ...)
end
