core:import("CoreMissionScriptElement")
core:import("CoreClass")

MissionScriptElement = MissionScriptElement or class(CoreMissionScriptElement.MissionScriptElement)

function MissionScriptElement:init(...)
	MissionScriptElement.super.init(self, ...)
end

function MissionScriptElement:client_on_executed()
end

function MissionScriptElement:on_executed(...)
	if Network:is_client() then
		return
	end

	MissionScriptElement.super.on_executed(self, ...)
end

function MissionScriptElement:_override_element_type_group(element, expected_id, group_table, variable_name, new_value)
	for i, data in pairs(group_table) do
		if (not expected_id or data._id == expected_id) and element._values then
			element._values[variable_name] = new_value
		end
	end
end

function MissionScriptElement:_override_group_element(element_id, element_type, variable_name, new_value)
	local element = self:get_mission_element(element_id)

	if element and element._mission_script and element._mission_script._element_groups then
		local groups = element._mission_script._element_groups

		if not element_type then
			for group_type, group_table in pairs(groups) do
				self:_override_element_type_group(element, element_id, group_table, variable_name, new_value)
			end
		elseif groups[element_type] then
			self:_override_element_type_group(element, element_id, groups[element_type], variable_name, new_value)
		end
	end
end

function MissionScriptElement:override_value_on_element_type(element_type, variable_name, new_value)
	for _, params in ipairs(self._values.on_executed) do
		self:_override_group_element(params.id, element_type, variable_name, new_value)
	end
end

function MissionScriptElement:override_value_on_element(element_ids, variable_name, new_value)
	if type(element_ids) ~= "table" then
		element_ids = {
			element_ids
		}
	end

	for _, params in ipairs(self._values.on_executed) do
		if table.contains(element_ids, params.id) then
			self:_override_group_element(params.id, nil, variable_name, new_value)
		end
	end
end

CoreClass.override_class(CoreMissionScriptElement.MissionScriptElement, MissionScriptElement)
