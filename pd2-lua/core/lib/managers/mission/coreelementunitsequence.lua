core:module("CoreElementUnitSequence")
core:import("CoreMissionScriptElement")
core:import("CoreCode")
core:import("CoreUnit")

ElementUnitSequence = ElementUnitSequence or class(CoreMissionScriptElement.MissionScriptElement)

function ElementUnitSequence:init(...)
	ElementUnitSequence.super.init(self, ...)

	self._unit = CoreUnit.safe_spawn_unit("core/units/run_sequence_dummy/run_sequence_dummy", self._values.position)

	managers.worlddefinition:add_trigger_sequence(self._unit, self._values.trigger_list)
end

function ElementUnitSequence:on_script_activated()
	self._mission_script:add_save_state_cb(self._id)
end

function ElementUnitSequence:client_on_executed(...)
	self:on_executed(...)
end

function ElementUnitSequence:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local run_sequence = true

	if self._values.only_for_local_player then
		run_sequence = not managers.player:player_unit() or instigator == managers.player:player_unit()
	end

	if run_sequence then
		self._unit:damage():run_sequence_simple("run_sequence")
	end

	ElementUnitSequence.super.on_executed(self, instigator)
end

function ElementUnitSequence:save(data)
	data.enabled = self._values.enabled
end

function ElementUnitSequence:load(data)
	self:set_enabled(data.enabled)
end
