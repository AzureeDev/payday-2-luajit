core:import("CoreMissionScriptElement")

ElementPickup = ElementPickup or class(CoreMissionScriptElement.MissionScriptElement)

function ElementPickup:init(...)
	ElementPickup.super.init(self, ...)
end

function ElementPickup:client_on_executed(...)
end

function ElementPickup:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if alive(instigator) and instigator:character_damage() and not instigator:character_damage():dead() and instigator:character_damage().set_pickup then
		if self._values.pickup == "remove" then
			instigator:character_damage():set_pickup(nil)
		else
			instigator:character_damage():set_pickup(self._values.pickup)
		end
	else
		local reason = not alive(instigator) and "no instigator"
		reason = reason or not instigator:character_damage() and "no character damage extension (wrong type of unit)"
		reason = reason or instigator:character_damage():dead() and "instigator dead"
		reason = reason or not instigator:character_damage().set_pickup and "No set_pickup function"

		debug_pause("Skipped pickup operation on an instigator!", self:editor_name(), "Reason: " .. reason)
	end

	ElementPickup.super.on_executed(self, instigator)
end
