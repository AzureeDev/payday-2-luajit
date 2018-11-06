core:import("CoreMissionScriptElement")

ElementExplosionDamage = ElementExplosionDamage or class(CoreMissionScriptElement.MissionScriptElement)

function ElementExplosionDamage:init(...)
	ElementExplosionDamage.super.init(self, ...)
end

function ElementExplosionDamage:client_on_executed(...)
	self:on_executed(...)
end

function ElementExplosionDamage:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local player = managers.player:player_unit()

	if player then
		player:character_damage():damage_explosion({
			position = self._values.position,
			range = self._values.range,
			damage = self._values.damage
		})
	end

	ElementExplosionDamage.super.on_executed(self, instigator)
end
