core:import("CoreEngineAccess")
require("core/lib/managers/cutscene/CoreCutsceneKeys")

CoreCutsceneExporter = CoreCutsceneExporter or class()

function CoreCutsceneExporter:init()
	self.__clips = {}
	self.__cutscene_keys = {}

	assert(type(self.export_to_path) == "function" or type(self.export_to_compile_destination) == "function", "Subclasses of CoreCutsceneExporter must define either export_to_compile_destination() or export_to_path().")
end

function CoreCutsceneExporter:free_cached_animations()
	self.__final_animation_cache = nil
	self.__joined_animation_cache = nil
	self.__footage_animation_cache = nil
end

function CoreCutsceneExporter:add_clip(clip)
	table.insert_sorted(self.__clips, clip, function (a, b)
		return a:start_time() < b:start_time()
	end)
	self:_clear_cached_lists()
end

function CoreCutsceneExporter:add_key(cutscene_key)
	table.insert_sorted(self.__cutscene_keys, cutscene_key, function (a, b)
		return a:frame() < b:frame()
	end)
	self:_clear_cached_lists()
end

function CoreCutsceneExporter:add_animation_patch(unit_name, blend_set, animation_name)
	if unit_name and blend_set and animation_name then
		self.__animation_patches = self.__animation_patches or {}
		self.__animation_patches[unit_name] = self.__animation_patches[unit_name] or {}
		self.__animation_patches[unit_name][blend_set] = animation_name
	end
end

function CoreCutsceneExporter:frame_count()
	local last_clip_end_time = #self.__clips > 0 and self.__clips[#self.__clips]:end_time() or 0
	local last_key_time = #self.__cutscene_keys > 0 and self.__cutscene_keys[#self.__cutscene_keys]:frame() or 0

	return math.max(last_clip_end_time, last_key_time)
end

function CoreCutsceneExporter:contains_optimized_footage()
	return table.find_value(self.__clips, function (clip)
		return clip:metadata():footage()._cutscene:is_optimized()
	end) ~= nil
end

function CoreCutsceneExporter:contains_unoptimized_footage()
	return table.find_value(self.__clips, function (clip)
		return not clip:metadata():footage()._cutscene:is_optimized()
	end) ~= nil
end

function CoreCutsceneExporter:is_valid()
	return #self:problems() == 0
end

function CoreCutsceneExporter:problems()
	self.__problems = self.__problems or table.map_keys(self:_problem_map())

	return self.__problems
end

function CoreCutsceneExporter:_problem_map()
	local problem_map = {}

	local function add_problem(problem)
		problem_map[problem] = true
	end

	if #self.__cutscene_keys == 0 and self:frame_count() == 0 then
		add_problem("The project contains no data.")
	else
		local previous_clip = responder_map({
			end_time = 0,
			start_time = 0,
			metadata = responder_map({
				is_valid = true
			})
		})

		for _, clip in ipairs(self.__clips) do
			if clip:start_time() < previous_clip:end_time() then
				add_problem("One or more clips overlap.")
			elseif previous_clip:end_time() ~= clip:start_time() then
				add_problem("There are gaps between clips.")
			end

			if clip:metadata() == nil then
				add_problem("One or more clips is missing cutscene footage data.")
			elseif not clip:metadata():is_valid() then
				add_problem("One or more clips contain invalid cutscene footage data.")
			end

			previous_clip = clip
		end

		if table.empty(problem_map) and self:contains_optimized_footage() then
			if self:contains_unoptimized_footage() then
				add_problem("The scene features both optimized and un-optimized clips.")
			end

			if not table.empty(self.__animation_patches or {}) then
				add_problem("Cannot apply animation patches to optimized clips.")
			end
		end
	end

	for unit_name, patches in pairs(self.__animation_patches or {}) do
		if not table.contains(self:_all_controlled_unit_names(), unit_name) then
			add_problem("Animation patch table contains a non-existing actor.")
		end

		for _, animation in pairs(patches or {}) do
			if not DB:has("animation", animation) and not SystemFS:exists(animation) then
				add_problem("Animation patch table contains invalid animations.")
			end
		end
	end

	return problem_map
end

function CoreCutsceneExporter:_has_cameras()
	for unit_name, _ in pairs(self:_all_controlled_unit_types(true)) do
		if string.begins(unit_name, "camera") then
			return true
		end
	end

	return false
end

function CoreCutsceneExporter:_all_controlled_unit_types(include_cameras)
	if self.__all_controlled_unit_types == nil then
		self.__all_controlled_unit_types = {}

		for _, clip in ipairs(self.__clips) do
			for unit_name, unit_type in pairs(clip:metadata():footage()._cutscene:controlled_unit_types()) do
				self.__all_controlled_unit_types[unit_name] = unit_type
			end
		end
	end

	return include_cameras and self.__all_controlled_unit_types or table.remap(self.__all_controlled_unit_types, function (unit_name, unit_type)
		return unit_name, not string.begins(unit_name, "camera") and unit_type or nil
	end)
end

function CoreCutsceneExporter:_all_controlled_unit_names(include_cameras)
	return table.map_keys(self:_all_controlled_unit_types(include_cameras))
end

function CoreCutsceneExporter:_get_final_animation(unit_name)
	self.__final_animation_cache = self.__final_animation_cache or setmetatable({}, {
		__mode = "v"
	})
	local final_animation = self.__final_animation_cache[unit_name]

	if not alive(final_animation) then
		final_animation = self:_get_joined_animation(unit_name) or false
		local unit_type = self:_all_controlled_unit_types()[unit_name]

		if final_animation and unit_type ~= nil and unit_type ~= "locator" then
			local patches = self.__animation_patches and self.__animation_patches[unit_name] or {}
			local unit_animatable_set = self:_get_animatable_set_name_for_unit_type(unit_type)
			local original_bones = AnimationManager:animatable_set_bones(unit_animatable_set)
			local replaced_blend_sets = table.map_keys(patches)
			local kept_bones = table.inject(replaced_blend_sets, original_bones, function (result, blend_set)
				local blend_set_bones = AnimationManager:animatable_set_bones(unit_animatable_set, blend_set)

				return table.find_all_values(result, function (bone)
					return not table.contains(blend_set_bones, bone)
				end)
			end)
			final_animation = self:_process_animation("strip", final_animation, kept_bones)

			for blend_set, animation_name in pairs(patches) do
				local blend_set_bones = AnimationManager:animatable_set_bones(unit_animatable_set, blend_set)

				assert(#blend_set_bones > 0, string.format("Blend set \"%s\" in \"%s\" contains no bones.", blend_set, unit_animatable_set))

				local patch_animation = self:_process_animation("strip", AnimationCutter:load(animation_name), blend_set_bones)

				assert(#patch_animation:bones() > 0, string.format("Animation \"%s\" contains no animation for bones in blend set \"%s\".", animation_name, blend_set))

				if final_animation:length() < patch_animation:length() then
					patch_animation = self:_process_animation("cut", patch_animation, 0, final_animation:length())
				elseif patch_animation:length() < final_animation:length() then
					local pause = AnimationCutter:pause(final_animation:length() - patch_animation:length())
					patch_animation = self:_process_animation("join", patch_animation, pause)

					pause:free()
				end

				final_animation = self:_process_animation("merge", final_animation, patch_animation)
			end
		end

		self.__final_animation_cache[unit_name] = final_animation
	end

	return final_animation or nil
end

function CoreCutsceneExporter:_get_joined_animation(unit_name_or_func)
	self.__joined_animation_cache = self.__joined_animation_cache or setmetatable({}, {
		__mode = "v"
	})
	local unit_name_func = type(unit_name_or_func) ~= "function" and function ()
		return tostring(unit_name_or_func)
	end or unit_name_or_func
	local unit_name = unit_name_func()
	local joined_animation = self.__joined_animation_cache[unit_name]

	if not alive(joined_animation) then
		joined_animation = self:_join_animations(unit_name_func) or false

		if unit_name then
			self.__joined_animation_cache[unit_name] = joined_animation
		end
	end

	return joined_animation or nil
end

function CoreCutsceneExporter:_get_joined_camera_animation()
	return self:_get_joined_animation(function (clip)
		return clip and clip:metadata():camera()
	end)
end

function CoreCutsceneExporter:_get_footage_animation(cutscene, unit_name)
	self.__footage_animation_cache = self.__footage_animation_cache or setmetatable({}, {
		__mode = "v"
	})
	local key = cutscene:name() .. ":" .. unit_name
	local footage_animation = self.__footage_animation_cache[key]

	if not alive(footage_animation) then
		local footage_animation_name = cutscene:animation_for_unit(unit_name)
		footage_animation = footage_animation_name and AnimationCutter:load(footage_animation_name) or false

		if footage_animation then
			local unit_type = cutscene:controlled_unit_types()[unit_name]

			if unit_type ~= nil and unit_type ~= "locator" then
				local animatable_set_name = self:_get_animatable_set_name_for_unit_type(unit_type)
				footage_animation = self:_process_animation("strip", footage_animation, animatable_set_name)
			end
		end

		self.__footage_animation_cache[key] = footage_animation
	end

	return footage_animation or nil
end

function CoreCutsceneExporter:_get_animatable_set_name_for_unit_type(unit_type)
	local unit_data = CoreEngineAccess._editor_unit_data(unit_type:id())
	local model_filename = unit_data:model()
	local object_db_entry = self.__database:has("object", model_filename) and self.__database:lookup("object", model_filename)

	if not object_db_entry then
		error(string.format("Unit \"%s\" - Model XML \"%s\" not found.", unit_type, model_filename:t()))
	end

	local object_node = self.__database:load_node(object_db_entry)

	if object_node == nil then
		error(string.format("Unit \"%s\" - Model XML is invalid.", unit_type))
	end

	for child in object_node:children() do
		if child:name() == "animation_set" then
			local animation_set_name = child:parameter("name")
			local animation_set = AnimationManager:animation_set(animation_set_name)

			return animation_set:animatable_set_name()
		end
	end

	error(string.format("Unit \"%s\" - Model XML is missing animation_set name.", unit_type))
end

function CoreCutsceneExporter:_join_animations(unit_name_func)
	local joined_animation = nil

	for _, clip in ipairs(self.__clips) do
		local cutscene = clip:metadata():footage()._cutscene
		local unit_name = unit_name_func(clip)
		local footage_animation = self:_get_footage_animation(cutscene, unit_name)

		if joined_animation ~= nil and footage_animation ~= nil then
			local first_set = table.sorted_copy(joined_animation:bones())
			local second_set = table.sorted_copy(footage_animation:bones())

			if not table.empty(first_set) and not table.empty(second_set) and not table.equals(first_set, second_set) then
				cat_print("debug", "Unit \"" .. unit_name .. "\", first set:")

				for _, bone in ipairs(first_set) do
					cat_print("debug", bone)
				end

				cat_print("debug", "")
				cat_print("debug", "Unit \"" .. unit_name .. "\", second set:")

				for _, bone in ipairs(second_set) do
					cat_print("debug", bone)
				end

				error(string.format("Unit \"%s\" - Bones differ in footage \"%s\".", unit_name, cutscene:name()))
			end
		end

		local range_start = clip:start_time_in_source() / cutscene:frames_per_second()
		local range_end = clip:end_time_in_source() / cutscene:frames_per_second()
		local range_duration = clip:length() / cutscene:frames_per_second()
		local clip_animation = footage_animation and AnimationCutter:cut(footage_animation, range_start, range_end) or AnimationCutter:pause(range_duration)
		joined_animation = joined_animation and self:_process_animation("join", joined_animation, clip_animation) or clip_animation

		if joined_animation ~= clip_animation then
			clip_animation:free()
		end
	end

	return joined_animation
end

function CoreCutsceneExporter:_clear_cached_lists()
	self.__problems = nil
	self.__all_controlled_unit_types = nil

	self:free_cached_animations()
end

function CoreCutsceneExporter:_process_animation(animation_cutter_method_name, animation, ...)
	local result = AnimationCutter[animation_cutter_method_name](AnimationCutter, animation, ...)

	animation:free()

	return result
end

function CoreCutsceneExporter:_assert_is_valid()
	local problems = self:problems()

	if #problems ~= 0 then
		error("Cutscene project is invalid: ", string.join(" ", problems))
	end
end
