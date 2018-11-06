core:import("CoreMissionScriptElement")

ElementDisableUnit = ElementDisableUnit or class(CoreMissionScriptElement.MissionScriptElement)

function ElementDisableUnit:init(...)
	ElementDisableUnit.super.init(self, ...)

	self._units = {}
end

function ElementDisableUnit:on_script_activated()
	local elementBroken = false

	for _, id in ipairs(self._values.unit_ids) do
		if Global.running_simulation then
			if not managers.editor:unit_with_id(id) then
				print("MISSING UNIT WITH ID:", id)

				elementBroken = true
			else
				table.insert(self._units, managers.editor:unit_with_id(id))
			end
		else
			local unit = managers.worlddefinition:get_unit_on_load(id, callback(self, self, "_load_unit"))

			if unit then
				table.insert(self._units, unit)
			end
		end
	end

	if elementBroken then
		for _, id in ipairs(self._values.unit_ids) do
			if managers.editor:unit_with_id(id) then
				print(inspect(managers.editor:unit_with_id(id)))
			end
		end
	end

	self._has_fetched_units = true

	self._mission_script:add_save_state_cb(self._id)
end

function ElementDisableUnit:_load_unit(unit)
	table.insert(self._units, unit)
end

function ElementDisableUnit:client_on_executed(...)
	self:on_executed(...)
end

function ElementDisableUnit:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	for _, unit in ipairs(self._units) do
		managers.game_play_central:mission_disable_unit(unit)
	end

	ElementDisableUnit.super.on_executed(self, instigator)
end

function ElementDisableUnit:save(data)
	data.save_me = true
	data.enabled = self._values.enabled
end

function ElementDisableUnit:load(data)
	if not self._has_fetched_units then
		self:on_script_activated()
	end

	self:set_enabled(data.enabled)
end
