core:module("CoreElementUnitSequenceTrigger")
core:import("CoreMissionScriptElement")
core:import("CoreCode")

ElementUnitSequenceTrigger = ElementUnitSequenceTrigger or class(CoreMissionScriptElement.MissionScriptElement)

function ElementUnitSequenceTrigger:init(...)
	ElementUnitSequenceTrigger.super.init(self, ...)

	if not self._values.sequence_list and self._values.sequence then
		self._values.sequence_list = {
			{
				unit_id = self._values.unit_id,
				sequence = self._values.sequence
			}
		}
	end
end

function ElementUnitSequenceTrigger:on_script_activated()
	if not Network:is_client() then
		self._mission_script:add_save_state_cb(self._id)

		for _, data in pairs(self._values.sequence_list) do
			managers.mission:add_runned_unit_sequence_trigger(data.unit_id, data.sequence, callback(self, self, "on_executed"))
		end
	end

	self._has_active_callback = true
end

function ElementUnitSequenceTrigger:send_to_host(instigator)
	if alive(instigator) then
		managers.network:session():send_to_host("to_server_mission_element_trigger", self._id, instigator)
	end
end

function ElementUnitSequenceTrigger:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementUnitSequenceTrigger.super.on_executed(self, instigator)
end

function ElementUnitSequenceTrigger:save(data)
	data.save_me = true
end

function ElementUnitSequenceTrigger:load(data)
	if not self._has_active_callback then
		self:on_script_activated()
	end
end
