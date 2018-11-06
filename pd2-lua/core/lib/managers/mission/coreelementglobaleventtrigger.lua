core:module("CoreElementGlobalEventTrigger")
core:import("CoreMissionScriptElement")
core:import("CoreCode")

ElementGlobalEventTrigger = ElementGlobalEventTrigger or class(CoreMissionScriptElement.MissionScriptElement)

function ElementGlobalEventTrigger:init(...)
	ElementGlobalEventTrigger.super.init(self, ...)
end

function ElementGlobalEventTrigger:on_script_activated()
	managers.mission:add_global_event_listener(self._id, {
		self._values.global_event
	}, callback(self, self, Network:is_client() and "send_to_host" or "on_executed"))
end

function ElementGlobalEventTrigger:send_to_host(instigator)
	if instigator then
		managers.network:session():send_to_host("to_server_mission_element_trigger", self._id, instigator)
	end
end

function ElementGlobalEventTrigger:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementGlobalEventTrigger.super.on_executed(self, instigator)
end
