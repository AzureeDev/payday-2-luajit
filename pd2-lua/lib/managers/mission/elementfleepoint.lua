core:import("CoreMissionScriptElement")

ElementFleePoint = ElementFleePoint or class(CoreMissionScriptElement.MissionScriptElement)

function ElementFleePoint:init(...)
	ElementFleePoint.super.init(self, ...)
end

function ElementFleePoint:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	self:operation_add()
	ElementFleePoint.super.on_executed(self, instigator)
end

function ElementFleePoint:operation_add()
	if self._values.functionality == "loot_drop" then
		managers.groupai:state():add_enemy_loot_drop_point(self._id, self._values.position)
	else
		managers.groupai:state():add_flee_point(self._id, self._values.position)
	end
end

function ElementFleePoint:operation_remove()
	if self._values.functionality == "loot_drop" then
		managers.groupai:state():remove_enemy_loot_drop_point(self._id)
	else
		managers.groupai:state():remove_flee_point(self._id)
	end
end
