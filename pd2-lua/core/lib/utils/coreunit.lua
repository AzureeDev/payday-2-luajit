core:module("CoreUnit")
core:import("CoreEngineAccess")
core:import("CoreCode")

function table.get_ray_ignore_args(...)
	local arg_list = {}

	for _, unit in pairs({
		...
	}) do
		if CoreCode.alive(unit) then
			table.insert(arg_list, "ignore_unit")
			table.insert(arg_list, unit)
		end
	end

	return unpack(arg_list)
end

function get_distance_to_body(body, pos)
	local root_obj = body:root_object()
	local min_dist = root_obj:distance_to_bounding_volume(pos)
	local child_obj_list = root_obj:children()

	for _, child_obj in ipairs(child_obj_list) do
		local dist = child_obj:distance_to_bounding_volume(pos)

		if dist < min_dist then
			min_dist = dist
		end
	end

	return min_dist
end

function reload_units(unit_name)
	local units = World:find_units_quick("all")
	local num_reloads = 0

	PackageManager:reload(Idstring("unit"), unit_name:id())
	managers.sequence:reload(unit_name, true)

	if units then
		local reloaded_units = {}

		for i, unit in ipairs(units) do
			if unit:name():id() == unit_name:id() then
				if not reloaded_units[unit_name] then
					Application:reload_material_config(unit:material_config():id())
				end

				local pos = unit:position()
				local rot = unit:rotation()

				unit:set_slot(0)
				World:spawn_unit(unit_name:id(), pos, rot)

				reloaded_units[unit_name] = true
				num_reloads = num_reloads + 1
			end
		end
	end

	return num_reloads
end

function set_unit_and_children_visible(unit, visible, filter_func)
	if filter_func == nil or filter_func(unit) then
		unit:set_visible(visible)
	end

	for _, child in ipairs(unit:children()) do
		set_unit_and_children_visible(child, visible, filter_func)
	end
end

function editor_load_unit(unit_name)
	if Application:editor() then
		local type_ids = Idstring("unit")
		local name_ids = unit_name:id()

		if not DB:has(type_ids, name_ids) then
			Application:error("Unit not found in DB", name_ids)
			Application:stack_dump("error")

			return
		end

		CoreEngineAccess._editor_load(type_ids, name_ids)

		return true
	else
		return true
	end
end

function safe_spawn_unit(unit_name, ...)
	if editor_load_unit(unit_name) then
		return World:spawn_unit(unit_name:id(), ...)
	end
end

function safe_spawn_unit_without_extensions(unit_name, ...)
	editor_load_unit(unit_name)

	return World:spawn_unit_without_extensions(unit_name:id(), ...)
end
