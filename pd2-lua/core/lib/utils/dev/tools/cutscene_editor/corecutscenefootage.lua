require("core/lib/utils/dev/tools/cutscene_editor/CoreCutsceneClipMetadata")
require("core/lib/managers/cutscene/CoreCutsceneKeys")

local CAMERA_ICON_IMAGE_COUNT = 30
CoreCutsceneFootage = CoreCutsceneFootage or class()

function CoreCutsceneFootage:init(cutscene)
	self._cutscene = cutscene
end

function CoreCutsceneFootage:name()
	return self._cutscene:name()
end

function CoreCutsceneFootage:controlled_unit_types()
	return self._cutscene:controlled_unit_types()
end

function CoreCutsceneFootage:camera_names()
	return self._cutscene:camera_names()
end

function CoreCutsceneFootage:keys()
	return self._cutscene:_all_keys_sorted_by_time()
end

function CoreCutsceneFootage:add_clips_to_track(track, time)
	time = time or 0

	track:freeze()

	for start_frame, end_frame, camera in self:_camera_cuts() do
		track:add_clip(self:create_clip(start_frame, end_frame, camera))
	end

	track:thaw()
end

function CoreCutsceneFootage:add_cameras_to_list_ctrl(list_ctrl)
	list_ctrl:freeze()
	list_ctrl:delete_all_items()

	for _, camera_name in ipairs(self:camera_names()) do
		local item = list_ctrl:append_item(camera_name)
		local icon_index = self:camera_icon_index(camera_name, list_ctrl:image_count())

		list_ctrl:set_item_image(item, icon_index)
	end

	list_ctrl:thaw()
end

function CoreCutsceneFootage:create_clip(start_frame, end_frame, camera)
	local clip = EWS:SequencerCroppedClip()
	local metadata = core_or_local("CutsceneClipMetadata", self, camera)

	clip:set_metadata(metadata)
	clip:set_icon_bitmap(metadata:camera_icon_image())
	clip:set_watermark(metadata:camera_watermark())
	clip:set_range(start_frame, end_frame)
	clip:set_uncropped_range(0, self._cutscene:frame_count())
	clip:set_colour(self:colour():unpack())

	return clip
end

function CoreCutsceneFootage:frame_count()
	return self._cutscene:frame_count()
end

function CoreCutsceneFootage:colour()
	if self._colour == nil then
		local precision = 255
		local r = 26
		local g = 52
		local b = 78
		local name = self._cutscene:name()
		local len = string.len(name)

		for i = 1, len do
			local byte = string.byte(name, i)
			r = math.fmod(r * 33 + byte, precision + 1)
			g = math.fmod(g * 33 + byte, precision + 1)
			b = math.fmod(b * 33 + byte, precision + 1)
		end

		local black_value = 0.7
		local divisor = precision * 1 / (1 - black_value)
		self._colour = Color(black_value + r / divisor, black_value + g / divisor, black_value + b / divisor)
	end

	return self._colour
end

function CoreCutsceneFootage:camera_icon_index(camera_name, image_count)
	image_count = image_count or CAMERA_ICON_IMAGE_COUNT + 1
	local name_without_prefix = string.match(camera_name, "camera_(.+)")
	local icon_index = tonumber(name_without_prefix) or table.get_vector_index(self:camera_names(), camera_name) or 0

	if image_count <= icon_index then
		icon_index = 0
	end

	return icon_index
end

function CoreCutsceneFootage:_camera_cuts()
	local cuts = self:_camera_cut_list()
	local index = 0

	return function ()
		index = index + 1

		return unpack(cuts[index] or {})
	end
end

function CoreCutsceneFootage:_camera_cut_list()
	if self._camera_cut_cache == nil then
		self._camera_cut_cache = {}

		if self._cutscene:has_cameras() then
			local function add_camera_cut(start_frame, end_frame, camera)
				if start_frame < end_frame then
					table.insert(self._camera_cut_cache, {
						start_frame,
						end_frame,
						camera
					})
				end
			end

			local previous_key = responder_map({
				frame = 0,
				camera = self._cutscene:default_camera()
			})

			for key in self._cutscene:keys(CoreChangeCameraCutsceneKey.ELEMENT_NAME) do
				add_camera_cut(previous_key:frame(), key:frame(), previous_key:camera())

				previous_key = key
			end

			add_camera_cut(previous_key:frame(), self._cutscene:frame_count(), previous_key:camera())
		end
	end

	return self._camera_cut_cache
end

function CoreCutsceneFootage:prime_cast(cast)
	cast:prime(self._cutscene)
end
