require("core/lib/compilers/CoreCutsceneExporter")
require("core/lib/managers/cutscene/CoreCutscene")

CoreCutsceneOptimizer = CoreCutsceneOptimizer or class(CoreCutsceneExporter)
CoreCutsceneOptimizer.ANIMATION_BLOB_PART_DURATION = 5

function CoreCutsceneOptimizer:init()
	self.super.init(self)

	self.__compression_enabled = {
		ps3 = true,
		win32 = true,
		x360 = true
	}
end

function CoreCutsceneOptimizer:export_to_compile_destination(dest, optimized_cutscene_path)
	self:_assert_is_valid()

	local cutscene_name = managers.database:entry_name(optimized_cutscene_path)
	local part_path_pattern = string.gsub(string.gsub(optimized_cutscene_path, cutscene_name .. ".", cutscene_name .. "_%03i."), "%.cutscene$", ".animation_blob")
	local merged_animation = self:_create_merged_animation()
	local new_animation_blobs = merged_animation and self:_write_animation_blobs(merged_animation, dest, part_path_pattern) or {}

	self:_write_cutscene_xml(optimized_cutscene_path, new_animation_blobs)
	self:_write_cutscene_unit_xml(string.gsub(optimized_cutscene_path, "%.cutscene$", ".unit"))
	managers.database:recompile()
end

function CoreCutsceneOptimizer:compression_enabled(platform)
	assert(self.__compression_enabled[platform] ~= nil, "Unsupported platform \"" .. tostring(platform) .. "\"")

	return self.__compression_enabled[platform]
end

function CoreCutsceneOptimizer:set_compression_enabled(platform, should_compress)
	assert(self.__compression_enabled[platform] ~= nil, "Unsupported platform \"" .. tostring(platform) .. "\"")
	assert(type(should_compress) == "boolean", "Expected boolean")

	self.__compression_enabled[platform] = should_compress
end

function CoreCutsceneOptimizer:_write_cutscene_xml(path, animation_blobs)
	local cutscene_node = Node("cutscene")

	cutscene_node:set_parameter("unit", managers.database:entry_path(path))
	cutscene_node:set_parameter("frames", tostring(self:frame_count()))

	if not table.empty(animation_blobs) then
		local animation_blobs_node = cutscene_node:make_child("animation_blobs")

		for _, animation_blob in ipairs(animation_blobs) do
			local part_node = animation_blobs_node:make_child("part")

			part_node:set_parameter("animation_blob", animation_blob)
		end
	end

	if not table.empty(self:_all_controlled_unit_names(true)) then
		local controlled_units_node = cutscene_node:make_child("controlled_units")

		local function add_controlled_unit(unit_type, unit_name)
			local unit_node = controlled_units_node:make_child("unit")

			unit_node:set_parameter("type", unit_type)
			unit_node:set_parameter("name", unit_name)

			local unit_is_patched = self.__animation_patches and self.__animation_patches[unit_name]

			if unit_is_patched then
				unit_node:set_parameter("blend_set", "patched")
			end
		end

		if self:_has_cameras() then
			add_controlled_unit("locator", "camera")
		end

		for _, unit_name in ipairs(self:_all_controlled_unit_names()) do
			local unit_type = self:_all_controlled_unit_types()[unit_name]

			add_controlled_unit(unit_type, unit_name)
		end
	end

	local keys_node = cutscene_node:make_child("keys")

	if self:_has_cameras() then
		CoreCutsceneKey:create(CoreChangeCameraCutsceneKey.ELEMENT_NAME):_save_under(keys_node)
	end

	for _, cutscene_key in ipairs(self.__cutscene_keys) do
		cutscene_key:_save_under(keys_node)
	end

	self:_add_unit_visibility_keys(keys_node)
	self:_add_discontinuity_keys(keys_node)
	managers.database:save_node(cutscene_node, path)
end

function CoreCutsceneOptimizer:_add_unit_visibility_keys(keys_node)
	local unit_names = self:_all_controlled_unit_names()
	local was_visible = {}

	for _, unit_name in ipairs(unit_names) do
		was_visible[unit_name] = true
	end

	for _, clip in ipairs(self.__clips) do
		local cutscene = clip:metadata():footage()._cutscene

		for _, unit_name in ipairs(unit_names) do
			local existing_visibility_key = table.find_value(self.__cutscene_keys, function (key)
				return key:frame() == clip:start_time() and key.ELEMENT_NAME == CoreUnitVisibleCutsceneKey.ELEMENT_NAME and key:unit_name() == unit_name
			end)

			if existing_visibility_key then
				was_visible[unit_name] = existing_visibility_key:visible()
			else
				local visible = cutscene:animation_for_unit(unit_name) ~= nil

				if visible ~= was_visible[unit_name] then
					local visibility_key = CoreCutsceneKey:create(CoreUnitVisibleCutsceneKey.ELEMENT_NAME)

					function visibility_key.is_valid_unit_name()
						return true
					end

					visibility_key:set_frame(clip:start_time())
					visibility_key:set_unit_name(unit_name)
					visibility_key:set_visible(visible)
					visibility_key:_save_under(keys_node)

					was_visible[unit_name] = visible
				end
			end
		end
	end
end

function CoreCutsceneOptimizer:_add_discontinuity_keys(keys_node)
	local previous_clip = nil

	for _, clip in ipairs(self.__clips) do
		if previous_clip == nil or clip:metadata():footage() ~= previous_clip:metadata():footage() or clip:start_time_in_source() ~= previous_clip:end_time_in_source() then
			local existing_discontinuity_key = table.find_value(self.__cutscene_keys, function (key)
				return key:frame() == clip:start_time() and key.ELEMENT_NAME == CoreDiscontinuityCutsceneKey.ELEMENT_NAME
			end)

			if existing_discontinuity_key == nil then
				local discontinuity_key = CoreCutsceneKey:create(CoreDiscontinuityCutsceneKey.ELEMENT_NAME)

				discontinuity_key:set_frame(clip:start_time())
				discontinuity_key:_save_under(keys_node)
			end
		end

		previous_clip = clip
	end
end

function CoreCutsceneOptimizer:_write_cutscene_unit_xml(path)
	local unit_node = Node("unit")

	unit_node:set_parameter("type", "cutscene")
	unit_node:set_parameter("slot", 20)

	local model_node = unit_node:make_child("model")

	model_node:set_parameter("file", "locator")

	local function add_extension_node(name, class)
		local extension_node = unit_node:make_child("extension")

		extension_node:set_parameter("name", name)
		extension_node:set_parameter("class", class)
	end

	add_extension_node("unit_data", "ScriptUnitData")
	add_extension_node("cutscene_data", "CutsceneData")
	managers.database:save_node(unit_node, path)
end

function CoreCutsceneOptimizer:_create_merged_animation()
	local unit_animation_map = {}

	for _, unit_name in ipairs(self:_all_controlled_unit_names()) do
		unit_animation_map[unit_name] = self:_get_final_animation(unit_name)
	end

	if self:_has_cameras() then
		unit_animation_map.camera = self:_get_joined_camera_animation()
	end

	local merged_animation = nil

	for unit_name, animation in pairs(unit_animation_map) do
		local prefixed_animation = AnimationCutter:add_prefix(animation, unit_name)
		merged_animation = merged_animation and self:_process_animation("merge", merged_animation, prefixed_animation) or prefixed_animation

		if merged_animation ~= prefixed_animation then
			prefixed_animation:free()
		end
	end

	return merged_animation
end

function CoreCutsceneOptimizer:_write_animation_blobs(full_animation, dest, part_path_pattern)
	local animation_blob_names = {}
	local default_settings = {
		rotation_tolerance = 0.0025,
		position_tolerance = 0.1,
		pack_rotations = false,
		pack_positions = false
	}
	local per_bone_settings = {}
	local duration = full_animation:length()
	local start_time = 0
	local index = 0

	while start_time <= duration do
		local end_time = math.min(start_time + self.ANIMATION_BLOB_PART_DURATION, duration)
		local part = AnimationCutter:cut(full_animation, start_time, end_time)
		local compressed_part = AnimationCutter:compress(part, default_settings, per_bone_settings)
		local part_path = string.format(part_path_pattern, index)

		self:_write_animation_part(dest, part_path, part, compressed_part)
		table.insert(animation_blob_names, managers.database:entry_path(part_path))
		compressed_part:free()
		part:free()

		start_time = start_time + self.ANIMATION_BLOB_PART_DURATION
		index = index + 1
	end

	return animation_blob_names
end

function CoreCutsceneOptimizer:_write_animation_part(dest, path, animation, compressed_animation)
	local platforms_to_export = {}
	local base_path = path

	for platform, _ in pairs(self.__compression_enabled) do
		if string.find(base_path, "%." .. platform .. "%.") then
			table.insert(platforms_to_export, platform)

			base_path = string.gsub(base_path, "%." .. platform .. "%.", ".")
		end
	end

	if #platforms_to_export == 0 then
		platforms_to_export = table.map_keys(self.__compression_enabled)
	end

	for _, platform in ipairs(platforms_to_export) do
		local use_compressed = self.__compression_enabled[platform]
		local save_func = platform == "win32" and AnimationCutter.save or AnimationCutter.save_cross_compiled

		save_func(AnimationCutter, use_compressed and compressed_animation or animation, path)
	end
end

function CoreCutsceneOptimizer:_problem_map()
	local problem_map = self.super._problem_map(self)

	local function add_problem(problem)
		problem_map[problem] = true
	end

	if self:contains_optimized_footage() then
		add_problem("Projects with optimized clips are not currently supported.")
	end

	return problem_map
end
