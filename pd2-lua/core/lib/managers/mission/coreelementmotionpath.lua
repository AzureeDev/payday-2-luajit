core:module("CoreElementMotionPath")
core:import("CoreMissionScriptElement")

ElementMotionPathOperator = ElementMotionPathOperator or class(CoreMissionScriptElement.MissionScriptElement)

function ElementMotionPathOperator:init(...)
	ElementMotionPathOperator.super.init(self, ...)
end

function ElementMotionPathOperator:client_on_executed(...)
	self:on_executed(...)
end

function ElementMotionPathOperator:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._values.operation == "activate_bridge" then
		managers.motion_path:motion_operation_activate_bridge(self._values.elements)
	elseif self._values.operation == "deactivate_bridge" then
		managers.motion_path:motion_operation_deactivate_bridge(self._values.elements)
	else
		for _, id in ipairs(self._values.elements) do
			local element = self:get_mission_element(id)

			if element then
				if self._values.operation == "goto_marker" then
					element:motion_operation_goto_marker(element:id(), self._values.marker_ids[self._values.marker])
				elseif self._values.operation == "teleport" then
					element:motion_operation_teleport_to_marker(element:id(), self._values.marker_ids[self._values.marker])
				elseif self._values.operation == "move" then
					element:motion_operation_set_motion_state("move")
				elseif self._values.operation == "wait" then
					element:motion_operation_set_motion_state("wait")
				elseif self._values.operation == "rotate" then
					element:motion_operation_set_rotation(self._id)
				end
			end
		end
	end

	ElementMotionPathOperator.super.on_executed(self, instigator)
end

ElementMotionPathTrigger = ElementMotionPathTrigger or class(CoreMissionScriptElement.MissionScriptElement)

function ElementMotionPathTrigger:init(...)
	ElementMotionPathTrigger.super.init(self, ...)
end

function ElementMotionPathTrigger:on_script_activated()
	for _, id in ipairs(self._values.elements) do
		local element = self:get_mission_element(id)

		element:add_trigger(self._id, self._values.outcome, callback(self, self, "on_executed"))
	end
end

function ElementMotionPathTrigger:client_on_executed(...)
end

function ElementMotionPathTrigger:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementMotionPathTrigger.super.on_executed(self, instigator)
end
