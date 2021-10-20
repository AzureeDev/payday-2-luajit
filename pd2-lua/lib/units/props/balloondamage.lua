BalloonDamage = BalloonDamage or class(UnitDamage)

function BalloonDamage:damage_damage(attack_unit, ...)
	if attack_unit == managers.player:player_unit() then
		self._unit:base():on_balloon_server_damage(attack_unit)
	end

	return BalloonDamage.super.damage_damage(self, attack_unit, ...)
end
