ElementVehicleTrigger = ElementVehicleTrigger or class(CoreMissionScriptElement.MissionScriptElement)

function ElementVehicleTrigger:init(...)
	ElementVehicleTrigger.super.init(self, ...)
end

function ElementVehicleTrigger:on_script_activated()
	if Network:is_server() then
		managers.vehicle:add_listener(self._id, {
			self._values.event
		}, callback(self, self, "on_executed"))
	end
end

function ElementVehicleTrigger:on_enter(instigator)
	self:on_executed(instigator)
end

function ElementVehicleTrigger:on_exit(instigator)
	self:on_executed(instigator)
end

function ElementVehicleTrigger:on_all_inside(instigator)
	self:on_executed(instigator)
end

function ElementVehicleTrigger:send_to_host(instigator)
	if instigator then
		managers.network:session():send_to_host("to_server_mission_element_trigger", self._id, nil)
	end
end

function ElementVehicleTrigger:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementVehicleTrigger.super.on_executed(self, self._unit or instigator)
end
