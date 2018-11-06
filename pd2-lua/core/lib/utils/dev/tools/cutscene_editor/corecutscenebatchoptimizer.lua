require("core/lib/utils/dev/tools/cutscene_editor/CoreCutsceneOptimizer")
require("core/lib/utils/dev/tools/cutscene_editor/CoreCutsceneEditorProject")
require("core/lib/utils/dev/tools/cutscene_editor/CoreCutsceneFootage")

CoreCutsceneBatchOptimizer = CoreCutsceneBatchOptimizer or class()

function CoreCutsceneBatchOptimizer:init()
	self.__prioritized_queue = {}
	self.__queue = {}
end

function CoreCutsceneBatchOptimizer:add_project(project_name, optimized_cutscene_name)
	local project = assert(self:_load_project(project_name), string.format("Cutscene Project \"%s\" not found in database.", project_name))
	local optimizer = self:_create_optimizer_for_project(project)

	if optimizer:is_valid() then
		local queue = project:export_type() == "footage_use" and self.__prioritized_queue or self.__queue

		table.insert(queue, {
			project_name = project_name,
			optimizer = optimizer,
			optimized_cutscene_name = optimized_cutscene_name
		})
	else
		cat_print("debug", string.format("Cutscene Project \"%s\" is invalid:", project_name))

		for _, problem in ipairs(optimizer:problems()) do
			cat_print("debug", "\t" .. problem)
		end
	end

	self.__max_queue_size = math.max(self.__max_queue_size or 0, self:queue_size())
end

function CoreCutsceneBatchOptimizer:next_project()
	local front = self.__prioritized_queue[1] or self.__queue[1]

	return front and front.project_name
end

function CoreCutsceneBatchOptimizer:consume_project()
	local front = table.remove(self.__prioritized_queue, 1) or table.remove(self.__queue, 1)

	if front then
		front.optimizer:export_to_database(front.optimized_cutscene_name)
		front.optimizer:free_cached_animations()
	end

	return self:queue_size()
end

function CoreCutsceneBatchOptimizer:queue_size()
	return #self.__queue + #self.__prioritized_queue
end

function CoreCutsceneBatchOptimizer:max_queue_size()
	return self.__max_queue_size or 0
end

function CoreCutsceneBatchOptimizer:_load_project(project_name)
	local database_entry = self.__database:has("cutscene_project", project_name) and self.__database:lookup("cutscene_project", project_name)

	if database_entry then
		local project = core_or_local("CutsceneEditorProject")

		project:set_database_entry(self.__database, database_entry)

		return project
	end

	return nil
end

function CoreCutsceneBatchOptimizer:_create_optimizer_for_project(project)
	local optimizer = core_or_local("CutsceneOptimizer")

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

function CoreCutsceneBatchOptimizer:_create_clip(clip_descriptor)
	local footage = assert(core_or_local("CutsceneFootage", managers.cutscene:get_cutscene(clip_descriptor.cutscene)), "Cutscene \"" .. clip_descriptor.cutscene .. "\" does not exist.")
	local clip = footage:create_clip(clip_descriptor.from, clip_descriptor.to, clip_descriptor.camera)

	clip:offset_by(clip_descriptor.offset - clip_descriptor.from)

	return clip
end
