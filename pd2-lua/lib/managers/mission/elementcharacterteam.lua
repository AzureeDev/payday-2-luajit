core:import("CoreMissionScriptElement")

ElementCharacterTeam = ElementCharacterTeam or class(CoreMissionScriptElement.MissionScriptElement)

function ElementCharacterTeam:init(...)
	ElementCharacterTeam.super.init(self, ...)
	self:_finalize_values()
end

function ElementCharacterTeam:_finalize_values()
	local values = self._values

	if values.team == "" then
		values.team = nil
	end

	if values.use_instigator or not next(values.elements) then
		values.elements = nil
	end
end

function ElementCharacterTeam:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local function _set_unit_team_f(unit)
		managers.groupai:state():set_char_team(unit, self._values.team)
	end

	if self._values.use_instigator then
		if self._values.team and not instigator:character_damage():dead() then
			_set_unit_team_f(instigator)
		end
	elseif self._values.elements then
		for _, element_id in pairs(self._values.elements) do
			local element = managers.mission:get_element_by_id(element_id)

			if element:enabled() or self._values.ignore_disabled then
				local all_units = element:units()

				for _, unit in ipairs(all_units) do
					_set_unit_team_f(unit)
				end
			end
		end
	end

	ElementCharacterTeam.super.on_executed(self, instigator)
end
