core:import("CoreMissionScriptElement")

ElementAIArea = ElementAIArea or class(CoreMissionScriptElement.MissionScriptElement)

function ElementAIArea:on_executed(instigator)
	if not self._values.enabled or Network:is_client() or not managers.groupai:state():is_AI_enabled() or not self._values.nav_segs then
		return
	end

	if next(self._values.nav_segs) then
		managers.groupai:state():add_area(self._id, self._values.nav_segs, self._values.position)
	end

	self._values.nav_segs = nil
	self._values.position = nil
	self._values = clone(self._values)

	ElementAIArea.super.on_executed(self, instigator)
end
