core:import("CoreMissionScriptElement")

ElementAIRemove = ElementAIRemove or class(CoreMissionScriptElement.MissionScriptElement)

function ElementAIRemove:init(...)
	ElementAIRemove.super.init(self, ...)
end

function ElementAIRemove:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._values.use_instigator then
		if alive(instigator) then
			if self._values.force_ragdoll and instigator:movement() then
				if instigator:character_damage().damage_mission then
					local backup_so = self._values.backup_so and self:get_mission_element(self._values.backup_so)

					print("backup_so: ", self._values.backup_so, backup_so)
					instigator:character_damage():damage_mission({
						forced = true,
						damage = 1000,
						col_ray = {},
						backup_so = backup_so
					})
				end

				if instigator:movement()._active_actions and instigator:movement()._active_actions[1] and instigator:movement()._active_actions[1]:type() == "hurt" then
					instigator:movement()._active_actions[1]:force_ragdoll(true)
				end
			elseif self._values.true_death then
				if instigator:character_damage().damage_mission then
					local backup_so = self._values.backup_so and self:get_mission_element(self._values.backup_so)

					instigator:character_damage():damage_mission({
						forced = true,
						damage = 1000,
						col_ray = {},
						backup_so = backup_so
					})
				end
			else
				instigator:brain():set_active(false)
				instigator:base():set_slot(instigator, 0)
			end
		end
	else
		for _, id in ipairs(self._values.elements) do
			local element = self:get_mission_element(id)

			if self._values.true_death then
				element:kill_all_units()
			else
				element:unspawn_all_units()
			end
		end
	end

	ElementAIRemove.super.on_executed(self, instigator)
end
