core:import("CoreMissionScriptElement")

ElementEnemyPreferedAdd = ElementEnemyPreferedAdd or class(CoreMissionScriptElement.MissionScriptElement)

function ElementEnemyPreferedAdd:init(...)
	ElementEnemyPreferedAdd.super.init(self, ...)
end

function ElementEnemyPreferedAdd:on_script_activated()
	self._values.spawn_points = self._values.spawn_points or self._values.elements

	if not self._values.spawn_points and not self._values.spawn_groups then
		return
	end

	self._group_data = {}

	if self._values.spawn_points then
		self._group_data.spawn_points = {}

		for _, id in ipairs(self._values.spawn_points) do
			local element = self:get_mission_element(id)

			table.insert(self._group_data.spawn_points, element)
		end
	end

	if self._values.spawn_groups then
		self._group_data.spawn_groups = {}

		for _, id in ipairs(self._values.spawn_groups) do
			local element = self:get_mission_element(id)

			table.insert(self._group_data.spawn_groups, element)
		end
	end
end

function ElementEnemyPreferedAdd:add()
	if not self._group_data then
		return
	end

	if self._group_data.spawn_points then
		managers.groupai:state():add_preferred_spawn_points(self._id, self._group_data.spawn_points)
	end

	if self._group_data.spawn_groups then
		managers.groupai:state():add_preferred_spawn_groups(self._id, self._group_data.spawn_groups)
	end
end

function ElementEnemyPreferedAdd:remove()
	managers.groupai:state():remove_preferred_spawn_points(self._id)
end

function ElementEnemyPreferedAdd:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	self:add()
	ElementEnemyPreferedAdd.super.on_executed(self, instigator)
end

ElementEnemyPreferedRemove = ElementEnemyPreferedRemove or class(CoreMissionScriptElement.MissionScriptElement)

function ElementEnemyPreferedRemove:init(...)
	ElementEnemyPreferedRemove.super.init(self, ...)
end

function ElementEnemyPreferedRemove:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	for _, id in ipairs(self._values.elements) do
		local element = self:get_mission_element(id)

		if element then
			element:remove()
		end
	end

	ElementEnemyPreferedRemove.super.on_executed(self, instigator)
end
