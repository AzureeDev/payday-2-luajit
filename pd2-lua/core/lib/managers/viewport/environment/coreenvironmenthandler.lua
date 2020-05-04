core:module("CoreEnvironmentHandler")
core:import("CoreClass")

local dummy_material = {
	set_variable = function ()
	end
}
EnvironmentHandler = EnvironmentHandler or CoreClass.class()
EnvironmentHandler.AREAS_PER_FRAME = 1

function EnvironmentHandler:init(env_manager, is_first_viewport)
	self._env_manager = env_manager
	self._is_first_viewport = is_first_viewport
	self._feeder_map = {}
	self._update_feeder_map = {}
	self._apply_prio_feeder_map = {}
	self._apply_feeder_map = {}
	self._post_processor_modifier_material_map = {}
	self._area_iterator = 1

	self:set_environment(self._env_manager:default_environment(), nil, nil, nil, nil)
end

function EnvironmentHandler:destroy()
	if self._feeder_map then
		for data_path_key, feeder in pairs(self._feeder_map) do
			feeder:destroy()
		end
	else
		Application:error("[EnvironmentManager] Destroy called too many times.")
	end

	self._env_manager = nil
	self._feeder_map = nil
	self._update_feeder_map = nil
	self._apply_prio_feeder_map = nil
	self._apply_feeder_map = nil
	self._post_processor_modifier_material_map = nil
end

function EnvironmentHandler:set_environment(path, blend_duration, blend_bezier_curve, filter_list, unfiltered_environment_path)
	if self._override_environment ~= path then
		self._path = path
	end

	if self._override_environment then
		path = self._override_environment
	end

	local env_data = self._env_manager:_get_data(path)
	local filtered_env_data = nil

	if filter_list then
		filtered_env_data = {}

		for _, data_path_key in ipairs(filter_list) do
			filtered_env_data[data_path_key] = env_data[data_path_key]
		end

		if unfiltered_environment_path then
			local unfiltered_env_data = self._env_manager:_get_data(unfiltered_environment_path)

			for data_path_key, value in pairs(unfiltered_env_data) do
				if filtered_env_data[data_path_key] == nil then
					filtered_env_data[data_path_key] = value
				end
			end
		end
	else
		filtered_env_data = env_data
	end

	if blend_duration and blend_duration > 0 then
		self._blend_time = 0
		self._blend_duration = blend_duration
		self._blend_bezier_curve = blend_bezier_curve
	else
		self._blend_duration = nil
		blend_duration = nil
	end

	for data_path_key, value in pairs(filtered_env_data) do
		local feeder = self._feeder_map[data_path_key]

		if not feeder then
			feeder = self._env_manager:_create_feeder(data_path_key, value)
			self._feeder_map[data_path_key] = feeder

			self:_add_apply_feeder(feeder)

			if feeder:get_modifier() then
				self._update_feeder_map[data_path_key] = feeder
			end
		else
			local modifier_func, is_modifier_override = feeder:get_modifier()
			local is_changed = modifier_func or not feeder:equals(value)

			if blend_duration or is_modifier_override then
				feeder:set_target(value)
			else
				feeder:set(value)
			end

			if not is_modifier_override then
				if is_changed then
					if blend_duration then
						self._update_feeder_map[data_path_key] = feeder
					else
						self:_add_apply_feeder(feeder)
					end
				else
					self._update_feeder_map[data_path_key] = nil
				end
			end
		end
	end
end

function EnvironmentHandler:get_path()
	return self._path
end

function EnvironmentHandler:create_modifier(data_path_key, is_override, func)
	local feeder = self._feeder_map[data_path_key]

	if not feeder then
		Application:stack_dump_error("[EnvironmentManager] Environment need to be set before creating a modifier or the requested modifier doesn't exist.")

		return nil
	else
		feeder:set_modifier(func, is_override)

		self._update_feeder_map[data_path_key] = feeder

		return data_path_key
	end
end

function EnvironmentHandler:destroy_modifier(data_path_key)
	local feeder = self._feeder_map[data_path_key]

	if not feeder then
		Application:stack_dump_error("[EnvironmentManager] Environment need to be set before destroying a modifier.")
	else
		feeder:set_modifier(nil, nil)

		self._update_feeder_map[data_path_key] = feeder

		self:_add_apply_feeder(feeder)
	end
end

function EnvironmentHandler:update_value(data_path_key)
	local feeder = self._feeder_map[data_path_key]

	if feeder then
		self._update_feeder_map[data_path_key] = feeder
	else
		Application:stack_dump_error("[EnvironmentManager] Invalid data path key.")
	end
end

function EnvironmentHandler:get_value(data_path_key)
	local feeder = self._feeder_map[data_path_key]

	if feeder then
		return feeder:get_current()
	else
		Application:stack_dump_error("[EnvironmentManager] Invalid data path key.")

		return nil
	end
end

function EnvironmentHandler:get_default_value(data_path_key)
	return self._env_manager:get_default_value(data_path_key)
end

function EnvironmentHandler:editor_set_value(data_path_key, value)
	local feeder = self._feeder_map[data_path_key]

	if not feeder and self._env_manager:has_data_path_key(data_path_key) then
		feeder = self._env_manager:_create_feeder(data_path_key, value)
		self._feeder_map[data_path_key] = feeder
	end

	if not feeder then
		return false
	elseif not feeder:equals(value) then
		feeder:set(value)
		self:_add_apply_feeder(feeder)
	end

	return true
end

function EnvironmentHandler:update(is_first_viewport, viewport, dt)
	local scale = nil

	if self._blend_duration then
		self._blend_time = self._blend_time + dt
		scale = self._blend_time / self._blend_duration

		if self._blend_bezier_curve then
			scale = math.bezier(self._blend_bezier_curve, math.clamp(scale, 0, 1))
		end

		scale = math.clamp(scale, 0, 1)

		if scale == 1 then
			self._blend_duration = nil
		end
	else
		scale = 1
	end

	self:set_first_viewport(is_first_viewport)

	local remove_update_list = nil

	for data_path_key, feeder in pairs(self._update_feeder_map) do
		local is_done, is_not_changed = feeder:update(self, scale)

		if is_done then
			remove_update_list = remove_update_list or {}

			table.insert(remove_update_list, data_path_key)
		end

		if not is_not_changed then
			self:_add_apply_feeder(feeder)
		end
	end

	if remove_update_list then
		for _, data_path_key in ipairs(remove_update_list) do
			self._update_feeder_map[data_path_key] = nil
		end
	end
end

function EnvironmentHandler:force_apply_feeders()
	self._post_processor_modifier_material_map = {}

	for _, feeder in pairs(self._feeder_map) do
		self:_add_apply_feeder(feeder)
	end
end

function EnvironmentHandler:apply(is_first_viewport, viewport, scene)
	self:set_first_viewport(is_first_viewport)

	if next(self._apply_prio_feeder_map) then
		for _, feeder in pairs(self._apply_prio_feeder_map) do
			if not feeder.IS_GLOBAL or is_first_viewport then
				feeder:apply(self, viewport, scene)
			end
		end

		self._apply_prio_feeder_map = {}
	end

	if next(self._apply_feeder_map) then
		for _, feeder in pairs(self._apply_feeder_map) do
			if not feeder.IS_GLOBAL or is_first_viewport then
				feeder:apply(self, viewport, scene)
			end
		end

		self._apply_feeder_map = {}
	end
end

function EnvironmentHandler:update_environment_area(check_pos, area_list)
	if self._current_area then
		local is_still_inside = self._current_area:still_inside(check_pos)
		local is_inside_new = self:_check_inside(check_pos, area_list, is_still_inside and self._current_area:prio() or nil)

		if not is_still_inside and not is_inside_new then
			self:_leave_current_area()
		end
	else
		self:_check_inside(check_pos, area_list, nil)
	end
end

function EnvironmentHandler:on_environment_area_removed(area)
	if area == self._current_area then
		self:_leave_current_area()
	end

	self._area_iterator = 1
end

function EnvironmentHandler:on_default_environment_changed(default_environment_path, blend_duration, blend_bezier_curve)
	if not self._current_area then
		self:set_environment(default_environment_path, blend_duration, blend_bezier_curve, nil, nil)
	end
end

function EnvironmentHandler:on_override_environment_changed(override_environment_path, blend_duration, blend_bezier_curve)
	self._override_environment = override_environment_path

	self:set_environment(self._override_environment or self._path, blend_duration, blend_bezier_curve, nil, nil)
end

function EnvironmentHandler:set_first_viewport(is_first_viewport)
	if self._is_first_viewport ~= is_first_viewport then
		self._is_first_viewport = is_first_viewport

		if is_first_viewport then
			for data_path_key, feeder in pairs(self._feeder_map) do
				local old_feeder = self._env_manager:_set_global_feeder(feeder)

				if not old_feeder or not feeder:equals(old_feeder:get_current()) then
					self:_add_apply_feeder(feeder)
				end
			end
		end
	end
end

function EnvironmentHandler:_check_inside(check_pos, area_list, min_prio)
	local area_count = #area_list

	if area_count > 0 then
		local areas_per_frame = self.AREAS_PER_FRAME
		local check_count = 0

		for i = 1, area_count do
			local area = area_list[self._area_iterator]
			self._area_iterator = math.mod(self._area_iterator, area_count) + 1

			if area:is_higher_prio(min_prio) then
				if area:is_inside(check_pos) then
					local id = area:id()

					if self._current_area_id ~= id then
						local environment = area:environment()
						local blend_duration = area:transition_time()
						local blend_bezier_curve = area:bezier_curve()
						local filter_list = area:filter_list()

						if area:permanent() then
							managers.viewport:set_default_environment(environment, blend_duration, blend_bezier_curve)

							if self._current_area then
								self:set_environment(environment, blend_duration, blend_bezier_curve, filter_list, self._env_manager:default_environment())
							end
						else
							self:set_environment(environment, blend_duration, blend_bezier_curve, filter_list, self._current_area ~= nil and self._env_manager:default_environment())
						end
					end

					self._current_area = area
					self._current_area_id = id
					self._area_iterator = 1

					return true
				end

				check_count = check_count + 1

				if areas_per_frame <= check_count then
					break
				end
			end
		end
	end

	return false
end

function EnvironmentHandler:_leave_current_area()
	self:set_environment(self._env_manager:default_environment(), self._current_area:transition_time(), self._current_area:bezier_curve(), nil, nil)

	self._current_area = nil
	self._current_area_id = nil
end

function EnvironmentHandler:_get_post_processor_modifier_material(viewport, scene, id, ids_processor_name, ids_effect_name, ids_modifier)
	local scene_map = self._post_processor_modifier_material_map[scene]
	local material = nil

	if not scene_map then
		scene_map = {}
		self._post_processor_modifier_material_map[scene] = scene_map
	else
		material = scene_map[id]
	end

	if not material then
		local post_processor = viewport:get_post_processor_effect(scene, ids_processor_name, ids_effect_name)

		if post_processor then
			local modifier = post_processor:modifier(ids_modifier)

			if modifier then
				material = modifier:material()
			else
				material = dummy_material

				Application:stack_dump_error("[EnvironmentManager] Invalid post processor. Scene: " .. tostring(scene) .. ", Processor: " .. tostring(ids_processor_name) .. ", Effect: " .. tostring(ids_effect_name) .. ", Modifier: " .. tostring(ids_modifier))
			end
		else
			material = dummy_material

			Application:stack_dump_error("[EnvironmentManager] Invalid post processor. Scene: " .. tostring(scene) .. ", Processor: " .. tostring(ids_processor_name) .. ", Effect: " .. tostring(ids_effect_name) .. ", Modifier: " .. tostring(ids_modifier))
		end

		scene_map[id] = material
	end

	return material
end

function EnvironmentHandler:_add_apply_feeder(feeder)
	if feeder.AFFECTED_LIST then
		self._apply_prio_feeder_map[feeder.APPLY_GROUP_ID] = feeder

		for _, affected_feeder in ipairs(feeder.AFFECTED_LIST) do
			self._apply_feeder_map[affected_feeder.APPLY_GROUP_ID] = self._feeder_map[affected_feeder.DATA_PATH_KEY]
		end
	else
		self._apply_feeder_map[feeder.APPLY_GROUP_ID] = feeder
	end
end
