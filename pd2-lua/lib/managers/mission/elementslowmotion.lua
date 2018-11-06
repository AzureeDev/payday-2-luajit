core:import("CoreMissionScriptElement")

ElementSlowMotion = ElementSlowMotion or class(CoreMissionScriptElement.MissionScriptElement)

function ElementSlowMotion:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local eff_desc = tweak_data.timespeed.mission_effects[self._values.eff_name]

	if not eff_desc then
		debug_pause("[ElementSlowMotion] could not find effect", self._values.eff_name)

		return
	end

	local eff_id = "ElementSlowMotion_" .. tostring(self._id)

	managers.time_speed:play_effect(eff_id, eff_desc)
	ElementSlowMotion.super.on_executed(self, instigator)
end
