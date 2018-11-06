core:import("CoreMissionScriptElement")

ElementDangerZone = ElementDangerZone or class(CoreMissionScriptElement.MissionScriptElement)

function ElementDangerZone:init(...)
	ElementDangerZone.super.init(self, ...)
end

function ElementDangerZone:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if alive(instigator) then
		if instigator == managers.player:player_unit() then
			instigator:character_damage():set_danger_level(self._values.level)
		else
			local rpc_params = {
				"dangerzone_set_level",
				self._values.level
			}

			instigator:network():send_to_unit(rpc_params)
		end
	end

	ElementDangerZone.super.on_executed(self, self._unit or instigator)
end
