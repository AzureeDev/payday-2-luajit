core:import("CoreMissionScriptElement")

ElementAIForceAttention = ElementAIForceAttention or class(CoreMissionScriptElement.MissionScriptElement)

function ElementAIForceAttention:init(...)
	ElementAIForceAttention.super.init(self, ...)
end

function ElementAIForceAttention:_get_unit(unit_id)
	if Global.running_simulation then
		return managers.editor:unit_with_id(unit_id)
	else
		return managers.worlddefinition:get_unit(unit_id)
	end
end

function ElementAIForceAttention:on_executed(instigator)
	if not self._values.enabled or Network:is_client() then
		return
	end

	if self._values.is_spawn then
		local spawn_element = self:get_mission_element(self._values.att_unit_id)

		spawn_element:add_event_callback("spawn", function (unit)
			self:_register_force_attention_unit(unit)
		end)

		if spawn_element:units() then
			self:_register_force_attention_unit(spawn_element:units()[#spawn_element:units()])
		end
	else
		self:_register_force_attention_unit(self:_get_unit(self._values.att_unit_id))
	end

	for _, included_spawn_id in ipairs(self._values.included_units) do
		local spawn_element = self:get_mission_element(included_spawn_id)

		if not spawn_element then
			return
		end

		spawn_element:add_event_callback("spawn", function (unit)
			managers.groupai:state():add_affected_force_attention_unit(unit)
		end)

		for _, unit in pairs(spawn_element:units() or {}) do
			managers.groupai:state():add_affected_force_attention_unit(unit)
		end
	end

	for _, excluded_spawn_id in ipairs(self._values.excluded_units) do
		local spawn_element = self:get_mission_element(excluded_spawn_id)

		if not spawn_element then
			return
		end

		spawn_element:add_event_callback("spawn", function (unit)
			managers.groupai:state():add_excluded_force_attention_unit(unit)
		end)

		for _, unit in pairs(spawn_element:units() or {}) do
			managers.groupai:state():add_excluded_force_attention_unit(unit)
		end
	end

	ElementSpecialObjective.super.on_executed(self, instigator)
end

function ElementAIForceAttention:_register_force_attention_unit(unit)
	managers.groupai:state():set_force_attention({
		unit = unit,
		ignore_vis_blockers = self._values.ignore_vis_blockers,
		include_all_force_spawns = self._values.include_all_force_spawns
	})
end
