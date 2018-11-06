core:import("CoreMissionScriptElement")

ElementCharacterSequence = ElementCharacterSequence or class(CoreMissionScriptElement.MissionScriptElement)

function ElementCharacterSequence:init(...)
	ElementCharacterSequence.super.init(self, ...)
end

function ElementCharacterSequence:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local function f(unit)
		unit:damage():run_sequence_simple(self._values.sequence)

		if Network:is_server() and managers.network:session() then
			managers.network:session():send_to_peers_synched("sync_run_sequence_char", unit, self._values.sequence)
		end
	end

	if self._values.sequence == "" then
		debug_pause("[ElementCharacterSequence] Empty sequence name. Element ID:", self._id)

		return
	end

	if self._values.use_instigator then
		if alive(instigator) then
			if instigator:damage() then
				f(instigator)
			else
				debug_pause_unit(unit, "[ElementCharacterSequence] instigator without damage extension", unit, ". Element ID:", self._id)
			end
		end
	else
		for _, id in ipairs(self._values.elements) do
			local element = self:get_mission_element(id)

			element:execute_on_all_units(f)
		end
	end

	ElementCharacterSequence.super.on_executed(self, instigator)
end
