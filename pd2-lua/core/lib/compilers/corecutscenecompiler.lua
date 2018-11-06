require("core/lib/compilers/CoreCompilerSystem")
require("core/lib/compilers/CoreCutsceneOptimizer")
require("core/lib/utils/dev/tools/cutscene_editor/CoreCutsceneEditorProject")
require("core/lib/utils/dev/tools/cutscene_editor/CoreCutsceneFootage")

CoreCutsceneCompiler = CoreCutsceneCompiler or class()

function CoreCutsceneCompiler:compile(file, dest, force_recompile)
	if file.type ~= "cutscene" then
		return false
	end

	if not force_recompile and dest:up_to_date(file.path, "cutscene", file.name, file.properties) then
		dest:skip_update("cutscene", file.name, file.properties)

		return true
	end

	cat_print("spam", "Compiling " .. file.path)

	local project = assert(self:_load_project(file.path), string.format("Failed to load cutscene \"%s\".", file.path))
	local optimizer = self:_create_optimizer_for_project(project)

	if optimizer:is_valid() then
		front.optimizer:export_to_compile_destination(dest, file.name)
		front.optimizer:free_cached_animations()
	else
		local error_msg = string.format("Cutscene \"%s\" is invalid:", file.path)

		for _, problem in ipairs(optimizer:problems()) do
			error_msg = error_msg .. "\t" .. problem
		end

		Application:error(error_msg)
	end

	return true
end

function CoreCutsceneCompiler:_load_project(path)
	if managers.database:has(path) then
		local project = CoreCutsceneEditorProject:new()

		project:set_path(path)

		return project
	end

	return nil
end

function CoreCutsceneCompiler:_create_optimizer_for_project(project)
	local optimizer = CoreCutsceneOptimizer:new()

	optimizer:set_compression_enabled("win32", project:export_type() == "in_game_use")

	local exported_clip_descriptors = table.find_all_values(project:film_clips(), function (clip)
		return clip.track_index == 1
	end)

	for _, clip_descriptor in ipairs(exported_clip_descriptors) do
		local clip = self:_create_clip(clip_descriptor)

		optimizer:add_clip(clip)
	end

	for _, key in ipairs(project:cutscene_keys()) do
		optimizer:add_key(key)
	end

	for unit_name, patches in pairs(project:animation_patches()) do
		for blend_set, animation in pairs(patches or {}) do
			optimizer:add_animation_patch(unit_name, blend_set, animation)
		end
	end

	return optimizer
end

function CoreCutsceneCompiler:_create_clip(clip_descriptor)
	local cutscene = managers.cutscene:get_cutscene(clip_descriptor.cutscene)
	local footage = assert(CoreCutsceneFootage:new(cutscene), "Cutscene \"" .. clip_descriptor.cutscene .. "\" does not exist.")
	local clip = footage:create_clip(clip_descriptor.from, clip_descriptor.to, clip_descriptor.camera)

	clip:offset_by(clip_descriptor.offset - clip_descriptor.from)

	return clip
end
