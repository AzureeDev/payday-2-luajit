core:import("CoreMissionScriptElement")

ElementInvulnerable = ElementInvulnerable or class(CoreMissionScriptElement.MissionScriptElement)

function ElementInvulnerable:init(...)
	ElementInvulnerable.super.init(self, ...)
end

function ElementInvulnerable:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	self:perform_invulnerable(instigator)
	ElementInvulnerable.super.on_executed(self, instigator)
end

function ElementInvulnerable:client_on_executed(instigator)
end

function ElementInvulnerable:perform_invulnerable(instigator)
	local units = {}

	if self:_check_unit(instigator) then
		table.insert(units, instigator)
	end

	for _, id in ipairs(self._values.elements) do
		local element = self:get_mission_element(id)

		for _, unit in ipairs(element:units()) do
			if self:_check_unit(unit) and not table.contains(units, unit) then
				table.insert(units, unit)
			end
		end
	end

	for _, unit in ipairs(units) do
		self:make_unit_invulnerable(unit)
	end
end

function ElementInvulnerable:_check_unit(unit)
	if alive(unit) and unit:character_damage() then
		local all_char_criminals = managers.groupai:state():all_char_criminals()

		for key, char_data in pairs(all_char_criminals) do
			if char_data.unit == unit then
				return false
			end
		end

		return unit:character_damage().set_invulnerable and unit:character_damage().set_immortal
	end

	return false
end

function ElementInvulnerable:make_unit_invulnerable(unit)
	unit:character_damage():set_invulnerable(self._values.invulnerable)
	unit:character_damage():set_immortal(self._values.immortal)
	unit:network():send("set_unit_invulnerable", self._values.invulnerable, self._values.immortal)
end
