core:import("CoreMissionScriptElement")

ElementLootBag = ElementLootBag or class(CoreMissionScriptElement.MissionScriptElement)

function ElementLootBag:init(...)
	ElementLootBag.super.init(self, ...)

	self._triggers = {}
end

function ElementLootBag:client_on_executed(...)
end

function ElementLootBag:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local unit = nil
	local pos, rot = self:get_orientation()

	if self._values.carry_id ~= "none" then
		local dir = self._values.push_multiplier and self._values.spawn_dir * self._values.push_multiplier or Vector3(0, 0, 0)
		unit = managers.player:server_drop_carry(self._values.carry_id, 1, true, false, 1, pos, rot, dir, 0, nil, nil)
	elseif self._values.from_respawn then
		local loot = managers.loot:get_respawn()

		if loot then
			local dir = self._values.push_multiplier and self._values.spawn_dir * self._values.push_multiplier or Vector3(0, 0, 0)
			unit = managers.player:server_drop_carry(loot.carry_id, loot.multiplier, true, false, 1, pos, rot, dir, 0, nil, nil)
		else
			print("NO MORE LOOT TO RESPAWN")
		end
	else
		local loot = managers.loot:get_distribute()

		if loot then
			local dir = self._values.push_multiplier and self._values.spawn_dir * self._values.push_multiplier or Vector3(0, 0, 0)
			unit = managers.player:server_drop_carry(loot.carry_id, loot.multiplier, true, false, 1, pos, rot, dir, 0, nil, nil)
		else
			print("NO MORE LOOT TO DISTRIBUTE")
		end
	end

	if alive(unit) then
		self:_check_triggers("spawn", unit)
		unit:carry_data():set_mission_element(self)
	end

	ElementLootBag.super.on_executed(self, instigator)
end

function ElementLootBag:add_trigger(id, type, callback)
	self._triggers[type] = self._triggers[type] or {}
	self._triggers[type][id] = {
		callback = callback
	}
end

function ElementLootBag:_check_triggers(type, instigator)
	if not self._triggers[type] then
		return
	end

	for id, cb_data in pairs(self._triggers[type]) do
		cb_data.callback(instigator)
	end
end

function ElementLootBag:trigger(type, instigator)
	self:_check_triggers(type, instigator)
end

ElementLootBagTrigger = ElementLootBagTrigger or class(CoreMissionScriptElement.MissionScriptElement)

function ElementLootBagTrigger:init(...)
	ElementLootBagTrigger.super.init(self, ...)
end

function ElementLootBagTrigger:on_script_activated()
	for _, id in ipairs(self._values.elements) do
		local element = self:get_mission_element(id)

		element:add_trigger(self._id, self._values.trigger_type, callback(self, self, "on_executed"))
	end
end

function ElementLootBagTrigger:client_on_executed(...)
end

function ElementLootBagTrigger:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementLootBagTrigger.super.on_executed(self, instigator)
end
