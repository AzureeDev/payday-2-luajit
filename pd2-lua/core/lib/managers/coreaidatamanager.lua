core:module("CoreAiDataManager")
core:import("CoreTable")

AiDataManager = AiDataManager or class()

function AiDataManager:init()
	self:_setup()
end

function AiDataManager:_setup()
	self._data = {
		patrol_paths = {}
	}
end

function AiDataManager:add_patrol_path(name)
	if self._data.patrol_paths[name] then
		Application:error("Patrol path with name " .. name .. " already exists!")

		return false
	end

	self._data.patrol_paths[name] = {
		points = {}
	}

	return true
end

function AiDataManager:remove_patrol_path(name)
	if not self._data.patrol_paths[name] then
		Application:error("Patrol path with name " .. name .. " doesn't exist!")

		return false
	end

	self._data.patrol_paths[name] = nil

	return true
end

function AiDataManager:add_patrol_point(name, unit)
	if not self._data.patrol_paths[name] then
		Application:error("Patrol path with name " .. name .. " doesn't exist!")

		return
	end

	local t = {
		position = unit:position(),
		rotation = unit:rotation(),
		unit = unit,
		unit_id = unit:unit_data().unit_id
	}

	table.insert(self._data.patrol_paths[name].points, t)
end

function AiDataManager:delete_point_by_unit(unit)
	for name, path in pairs(self._data.patrol_paths) do
		for i, point in ipairs(path.points) do
			if point.unit == unit then
				table.remove(path.points, i)

				return
			end
		end
	end
end

function AiDataManager:patrol_path_by_unit(unit)
	for name, path in pairs(self._data.patrol_paths) do
		for i, point in ipairs(path.points) do
			if point.unit == unit then
				return name, path
			end
		end
	end
end

function AiDataManager:patrol_point_index_by_unit(unit)
	for name, path in pairs(self._data.patrol_paths) do
		for i, point in ipairs(path.points) do
			if point.unit == unit then
				return i, point
			end
		end
	end
end

function AiDataManager:patrol_path(name)
	return self._data.patrol_paths[name]
end

function AiDataManager:all_patrol_paths()
	return self._data.patrol_paths
end

function AiDataManager:patrol_path_names()
	local t = {}

	for name, path in pairs(self._data.patrol_paths) do
		table.insert(t, name)
	end

	table.sort(t)

	return t
end

function AiDataManager:destination_path(position, rotation)
	return {
		points = {
			{
				position = position,
				rotation = rotation
			}
		}
	}
end

function AiDataManager:clear()
	self:_setup()
end

function AiDataManager:save_data()
	local t = CoreTable.deep_clone(self._data)

	for name, path in pairs(t.patrol_paths) do
		for i, point in ipairs(path.points) do
			point.position = point.unit:position()
			point.rotation = point.unit:rotation()
			point.unit = nil
		end
	end

	return t
end

function AiDataManager:load_data(data)
	if not data then
		return
	end

	self._data = data
end

function AiDataManager:load_units(units)
	for _, unit in ipairs(units) do
		for name, path in pairs(self._data.patrol_paths) do
			for i, point in ipairs(path.points) do
				if point.unit_id == unit:unit_data().unit_id then
					point.unit = unit
				end
			end
		end
	end
end
