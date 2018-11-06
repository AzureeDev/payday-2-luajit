core:import("CoreMissionScriptElement")

ElementInteraction = ElementInteraction or class(CoreMissionScriptElement.MissionScriptElement)

function ElementInteraction:init(...)
	ElementInteraction.super.init(self, ...)

	if Network:is_server() then
		local host_only = self:value("host_only")

		if host_only then
			self._unit = CoreUnit.safe_spawn_unit("units/dev_tools/mission_elements/point_interaction/interaction_dummy_nosync", self._values.position, self._values.rotation)
		else
			self._unit = CoreUnit.safe_spawn_unit("units/dev_tools/mission_elements/point_interaction/interaction_dummy", self._values.position, self._values.rotation)
		end

		if self._unit then
			self._unit:interaction():set_host_only(host_only)
			self._unit:interaction():set_active(false)
			self._unit:interaction():set_mission_element(self)
			self._unit:interaction():set_tweak_data(self._values.tweak_data_id)

			if self._values.override_timer ~= -1 then
				self._unit:interaction():set_override_timer_value(self._values.override_timer)
			end
		end
	end
end

function ElementInteraction:on_script_activated()
	if alive(self._unit) and self._values.enabled then
		self._unit:interaction():set_active(self._values.enabled, true)
	end
end

function ElementInteraction:set_enabled(enabled)
	ElementInteraction.super.set_enabled(self, enabled)

	if alive(self._unit) then
		self._unit:interaction():set_active(enabled, true)
	end
end

function ElementInteraction:on_executed(instigator, ...)
	if not self._values.enabled then
		return
	end

	ElementInteraction.super.on_executed(self, instigator, ...)
end

function ElementInteraction:on_interacted(instigator)
	self:on_executed(instigator, "interacted")
end

function ElementInteraction:on_interact_start(instigator)
	self:on_executed(instigator, "start")
end

function ElementInteraction:on_interact_interupt(instigator)
	self:on_executed(instigator, "interupt")
end

function ElementInteraction:stop_simulation(...)
	ElementInteraction.super.stop_simulation(self, ...)

	if alive(self._unit) then
		World:delete_unit(self._unit)
	end
end
