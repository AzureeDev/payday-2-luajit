core:module("CoreElementLogicChance")
core:import("CoreMissionScriptElement")

ElementLogicChance = ElementLogicChance or class(CoreMissionScriptElement.MissionScriptElement)

function ElementLogicChance:init(...)
	ElementLogicChance.super.init(self, ...)

	self._chance = self._values.chance
	self._triggers = {}
end

function ElementLogicChance:client_on_executed(...)
end

function ElementLogicChance:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local roll = math.random(100)

	if self._chance < roll then
		self:_trigger_outcome("fail")

		return
	end

	self:_trigger_outcome("success")
	ElementLogicChance.super.on_executed(self, instigator)
end

function ElementLogicChance:chance_operation_add_chance(chance)
	self._chance = self._chance + chance
end

function ElementLogicChance:chance_operation_subtract_chance(chance)
	self._chance = self._chance - chance
end

function ElementLogicChance:chance_operation_reset()
	self._chance = self._values.chance
end

function ElementLogicChance:chance_operation_set_chance(chance)
	self._chance = chance
end

function ElementLogicChance:add_trigger(id, outcome, callback)
	self._triggers[id] = {
		outcome = outcome,
		callback = callback
	}
end

function ElementLogicChance:remove_trigger(id)
	self._triggers[id] = nil
end

function ElementLogicChance:_trigger_outcome(outcome)
	for _, data in pairs(self._triggers) do
		if data.outcome == outcome then
			data.callback()
		end
	end
end

ElementLogicChanceOperator = ElementLogicChanceOperator or class(CoreMissionScriptElement.MissionScriptElement)

function ElementLogicChanceOperator:init(...)
	ElementLogicChanceOperator.super.init(self, ...)
end

function ElementLogicChanceOperator:client_on_executed(...)
end

function ElementLogicChanceOperator:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	for _, id in ipairs(self._values.elements) do
		local element = self:get_mission_element(id)

		if element then
			if self._values.operation == "add_chance" then
				element:chance_operation_add_chance(self._values.chance)
			elseif self._values.operation == "subtract_chance" then
				element:chance_operation_subtract_chance(self._values.chance)
			elseif self._values.operation == "reset" then
				element:chance_operation_reset()
			elseif self._values.operation == "set_chance" then
				element:chance_operation_set_chance(self._values.chance)
			end
		end
	end

	ElementLogicChanceOperator.super.on_executed(self, instigator)
end

ElementLogicChanceTrigger = ElementLogicChanceTrigger or class(CoreMissionScriptElement.MissionScriptElement)

function ElementLogicChanceTrigger:init(...)
	ElementLogicChanceTrigger.super.init(self, ...)
end

function ElementLogicChanceTrigger:on_script_activated()
	for _, id in ipairs(self._values.elements) do
		local element = self:get_mission_element(id)

		element:add_trigger(self._id, self._values.outcome, callback(self, self, "on_executed"))
	end
end

function ElementLogicChanceTrigger:client_on_executed(...)
end

function ElementLogicChanceTrigger:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementLogicChanceTrigger.super.on_executed(self, instigator)
end
