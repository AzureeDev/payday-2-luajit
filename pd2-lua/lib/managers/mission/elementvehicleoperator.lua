ElementVehicleOperator = ElementVehicleOperator or class(CoreMissionScriptElement.MissionScriptElement)

function ElementVehicleOperator:init(...)
	ElementVehicleOperator.super.init(self, ...)
end

function ElementVehicleOperator:client_on_executed(...)
	self:on_executed(...)
end

function ElementVehicleOperator:_get_unit(unit_id)
	if Global.running_simulation then
		return managers.editor:unit_with_id(unit_id)
	else
		return managers.worlddefinition:get_unit(unit_id)
	end
end

function ElementVehicleOperator:_apply_opreator(unit)
	if unit then
		local extension = unit:npc_vehicle_driving() or unit:vehicle_driving()

		if extension then
			local call = extension[self._values.operation]

			if call then
				call(extension, tonumber(self._values.damage))
			else
				Application:error("Vehicle Operator applied to a unit that doesn't support the specified operation - opertion: ", self._values.operation)
			end
		else
			Application:error("Vehicle Operator applied to a unit that isn't a vehicle: ", inspect(unit))
		end
	else
		Application:warn("Vehicle Operator applied to a unit that doesn't exist - operator: ", inspect(self._unit))
	end
end

function ElementVehicleOperator:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._values.use_instigator then
		if instigator then
			self:_apply_opreator(instigator)
		end
	else
		for _, id in ipairs(self._values.elements) do
			local unit = self:_get_unit(id)

			self:_apply_opreator(unit)
		end
	end

	ElementVehicleOperator.super.on_executed(self, instigator)
end
