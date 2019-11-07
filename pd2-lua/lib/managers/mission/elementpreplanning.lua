core:import("CoreMissionScriptElement")

ElementPrePlanning = ElementPrePlanning or class(CoreMissionScriptElement.MissionScriptElement)

function ElementPrePlanning:init(...)
	ElementPrePlanning.super.init(self, ...)
end

function ElementPrePlanning:on_script_activated()
	self._mission_script:add_save_state_cb(self._id)

	if self._values.enabled then
		self._has_registered = true

		managers.preplanning:register_element(self)
	end
end

function ElementPrePlanning:set_enabled(enabled)
	ElementPrePlanning.super.set_enabled(self, enabled)

	if enabled and not self._has_registered then
		self._has_registered = true

		managers.preplanning:register_element(self)
	elseif not enabled and self._has_registered then
		self._has_registered = nil

		managers.preplanning:unregister_element(self)
	end
end

function ElementPrePlanning:on_executed(instigator, ...)
	if not self._values.enabled then
		return
	end

	ElementPrePlanning.super.on_executed(self, instigator, ...)
end

function ElementPrePlanning:save(data)
	data.enabled = self._values.enabled
end

function ElementPrePlanning:load(data)
	self:set_enabled(data.enabled)
end

ElementPrePlanningExecuteGroup = ElementPrePlanningExecuteGroup or class(CoreMissionScriptElement.MissionScriptElement)

function ElementPrePlanningExecuteGroup:init(...)
	ElementPrePlanningExecuteGroup.super.init(self, ...)
end

function ElementPrePlanningExecuteGroup:on_executed(instigator, ...)
	if not self._values.enabled then
		return
	end

	if managers.preplanning then
		managers.preplanning:activate_location_groups(self._values.location_groups)
	end

	ElementPrePlanningExecuteGroup.super.on_executed(self, instigator, ...)
end
