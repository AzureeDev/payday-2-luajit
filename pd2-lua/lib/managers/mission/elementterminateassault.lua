core:import("CoreMissionScriptElement")

ElementTerminateAssault = ElementTerminateAssault or class(CoreMissionScriptElement.MissionScriptElement)

function ElementTerminateAssault:on_executed(instigator)
	local state = managers.groupai:state()

	if state.terminate_assaults then
		state:terminate_assaults()
		managers.hud:hide_panels("assault_panel", "hostages_panel")
	end

	ElementTerminateAssault.super.on_executed(self, instigator)
end
