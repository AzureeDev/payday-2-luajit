core:import("CoreMissionScriptElement")

ElementTeleportPlayer = ElementTeleportPlayer or class(CoreMissionScriptElement.MissionScriptElement)

function ElementTeleportPlayer:client_on_executed(...)
	self:on_executed(...)
end

function ElementTeleportPlayer:on_executed(instigator)
	ElementTeleportPlayer.super.on_executed(self, instigator)

	if not self._values.enabled then
		return
	end

	local player = instigator or managers.player:player_unit()

	if player ~= managers.player:player_unit() then
		return
	end

	if alive(player) then
		player:movement():trigger_teleport(self._values)

		if self._values.refill then
			player:character_damage():replenish()

			for id, weapon in pairs(player:inventory():available_selections() or {}) do
				if alive(weapon.unit) then
					weapon.unit:base():replenish()
					managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
				end
			end
		end
	end
end
