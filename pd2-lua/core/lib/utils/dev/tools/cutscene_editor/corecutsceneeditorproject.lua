CoreCutsceneEditorProject = CoreCutsceneEditorProject or class()
CoreCutsceneEditorProject.VALID_EXPORT_TYPES = {
	"in_game_use",
	"footage_use"
}
CoreCutsceneEditorProject.DEFAULT_EXPORT_TYPE = "in_game_use"

function CoreCutsceneEditorProject:path()
	return self._path
end

function CoreCutsceneEditorProject:set_path(absolute_path)
	self._path = assert(absolute_path, "Must supply a valid path.")
	self._root_node = nil
end

function CoreCutsceneEditorProject:name()
	return self:path() and managers.database:entry_name(self:path()) or "untitled"
end

function CoreCutsceneEditorProject:export_type()
	local settings_node = self:child_node("settings") or responder(function ()
	end)
	local export_type_node = self:child_node("export_type", settings_node) or responder(nil)

	return export_type_node:parameter("value") or self.DEFAULT_EXPORT_TYPE
end

function CoreCutsceneEditorProject:save(audio_clips, film_clips, cutscene_keys, settings)
	assert(self:path(), "A valid path has not been assigned. Call the set_path() method prior to saving.")

	self._root_node = nil

	local function is_valid(member)
		return member ~= nil and member ~= ""
	end

	local project_node = Node("cutscene_project")
	local settings_node = project_node:make_child("settings")
	local export_type_node = settings_node:make_child("export_type")

	if type(settings.export_type) == "string" then
		assert(table.contains(self.VALID_EXPORT_TYPES, settings.export_type))
	end

	export_type_node:set_parameter("value", settings.export_type or self.DEFAULT_EXPORT_TYPE)

	local animation_patches_node = settings_node:make_child("animation_patches")

	for actor_name, patches in pairs(settings.animation_patches or {}) do
		for blend_set, animation in pairs(patches) do
			if is_valid(blend_set) and is_valid(animation) then
				local actor_node = self:child_node("actor", animation_patches_node, {
					name = tostring(actor_name)
				}) or animation_patches_node:make_child("actor")

				actor_node:set_parameter("name", tostring(actor_name))

				local override_node = actor_node:make_child("override")

				override_node:set_parameter("blend_set", tostring(blend_set))
				override_node:set_parameter("animation", tostring(animation))
			end
		end
	end

	local audio_track_node = project_node:make_child("audio_track")

	for _, clip in ipairs(audio_clips) do
		if is_valid(clip.sound) then
			local clip_node = audio_track_node:make_child("clip")

			clip_node:set_parameter("offset", tostring(clip.offset or 0))
			clip_node:set_parameter("sound", tostring(clip.sound))
		end
	end

	local key_track_node = project_node:make_child("key_track")

	for _, cutscene_key in ipairs(cutscene_keys) do
		cutscene_key:_save_under(key_track_node)
	end

	local film_tracks_node = project_node:make_child("film_tracks")
	local highest_film_track_index = table.inject(film_clips, 0, function (highest, clip)
		return math.max(highest, clip.track_index or 0)
	end)

	for track_index = 1, highest_film_track_index do
		local track_node = film_tracks_node:make_child("track")

		for _, clip in ipairs(table.find_all_values(film_clips, function (clip)
			return clip.track_index == track_index
		end)) do
			if is_valid(clip.cutscene) and is_valid(clip.camera) and clip.to - clip.from > 0 then
				local clip_node = track_node:make_child("clip")

				clip_node:set_parameter("offset", tostring(clip.offset or 0))
				clip_node:set_parameter("cutscene", tostring(clip.cutscene))
				clip_node:set_parameter("from", tostring(clip.from or 0))
				clip_node:set_parameter("to", tostring(clip.to or 0))
				clip_node:set_parameter("camera", tostring(clip.camera))
			end
		end
	end

	managers.database:save_node(project_node, self:path())
	managers.database:recompile()
end

function CoreCutsceneEditorProject:audio_clips()
	local clips = {}
	local audio_track_node = self:child_node("audio_track") or responder(function ()
	end)

	for clip_node in audio_track_node:children() do
		table.insert(clips, {
			offset = tonumber(clip_node:parameter("offset") or "0"),
			sound = clip_node:parameter("sound")
		})
	end

	return clips
end

function CoreCutsceneEditorProject:film_clips()
	local clips = {}
	local film_tracks_node = self:child_node("film_tracks") or responder(0)
	local index = 0
	local track_count = film_tracks_node:num_children()

	while index < track_count do
		local track_node = film_tracks_node:child(index)

		for clip_node in track_node:children() do
			table.insert(clips, {
				track_index = index + 1,
				offset = tonumber(clip_node:parameter("offset") or "0"),
				cutscene = clip_node:parameter("cutscene"),
				from = tonumber(clip_node:parameter("from") or "0"),
				to = tonumber(clip_node:parameter("to") or "0"),
				camera = clip_node:parameter("camera")
			})
		end

		index = index + 1
	end

	return clips
end

function CoreCutsceneEditorProject:cutscene_keys(key_collection)
	local cutscene_keys = {}
	local key_track_node = self:child_node("key_track") or responder(function ()
	end)

	for key_node in key_track_node:children() do
		local cutscene_key = CoreCutsceneKey:create(key_node:name(), key_collection)

		cutscene_key:load(key_node)
		table.insert(cutscene_keys, cutscene_key)
	end

	return cutscene_keys
end

function CoreCutsceneEditorProject:animation_patches()
	local patches = {}
	local settings_node = self:child_node("settings") or responder(function ()
	end)
	local animation_patches_node = self:child_node("animation_patches", settings_node) or responder(function ()
	end)

	for actor_node in animation_patches_node:children() do
		local unit_name = actor_node:parameter("name")

		for override_node in actor_node:children() do
			local blend_set = override_node:parameter("blend_set")
			local animation = override_node:parameter("animation")
			patches[unit_name] = patches[unit_name] or {}
			patches[unit_name][blend_set] = animation
		end
	end

	return patches
end

function CoreCutsceneEditorProject:root_node()
	if self._root_node == nil then
		self._root_node = managers.database:load_node(self:path())
	end

	return self._root_node
end

function CoreCutsceneEditorProject:child_node(child_name, parent_node, child_properties)
	parent_node = parent_node or self:root_node()

	for child_node in parent_node:children() do
		if child_node:name() == child_name and (child_properties == nil or table.true_for_all(child_properties, function (value, key)
			return child_node:parameter(key) == value
		end)) then
			return child_node
		end
	end
end
