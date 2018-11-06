core:import("CoreMissionScriptElement")

ElementDropInPoint = ElementDropInPoint or class(CoreMissionScriptElement.MissionScriptElement)

function ElementDropInPoint:on_script_activated()
	ElementDropInPoint.super.on_script_activated(self)
	self:on_set_enabled()
end

function ElementDropInPoint:on_set_enabled()
	if self._values.enabled then
		managers.criminals:add_custom_drop_in_point(self:id(), self._values.position, self._values.rotation)
	else
		managers.criminals:remove_custom_drop_in_point(self:id())
	end
end

function ElementDropInPoint:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local peer = alive(instigator) and managers.network:session() and managers.network:session():peer_by_unit(instigator)

	if peer then
		managers.criminals:set_custom_drop_in_point_peer_id(self:id(), peer:id())
	end

	ElementDropInPoint.super.on_executed(self, instigator)
end
