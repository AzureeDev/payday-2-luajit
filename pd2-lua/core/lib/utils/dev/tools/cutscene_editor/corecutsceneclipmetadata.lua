CoreCutsceneClipMetadata = CoreCutsceneClipMetadata or class()

function CoreCutsceneClipMetadata:init(footage, camera)
	self._footage = footage
	self._camera = camera
end

function CoreCutsceneClipMetadata:is_valid()
	return self:camera_index() ~= nil
end

function CoreCutsceneClipMetadata:footage()
	return self._footage
end

function CoreCutsceneClipMetadata:camera()
	return self._camera
end

function CoreCutsceneClipMetadata:set_camera(camera)
	self._camera = camera
end

function CoreCutsceneClipMetadata:camera_index()
	return self:footage() and table.get_vector_index(self:footage():camera_names(), self:camera()) or nil
end

function CoreCutsceneClipMetadata:camera_icon_image()
	local icon_index = 0

	if self:footage() and self:camera() then
		icon_index = self:footage():camera_icon_index(self:camera())
	end

	return CoreEWS.image_path(string.format("sequencer\\clip_icon_camera_%02i.bmp", icon_index))
end

function CoreCutsceneClipMetadata:camera_watermark()
	if self:footage() and self:camera() then
		local name_without_prefix = string.match(self:camera(), "camera_(.+)")
		local as_number = tonumber(name_without_prefix)

		return as_number and tostring(as_number) or string.upper(name_without_prefix or "camera"), 12, "ALIGN_CENTER_HORIZONTAL,ALIGN_CENTER_VERTICAL", Vector3(0, -2)
	end

	return nil
end

function CoreCutsceneClipMetadata:prime_cast(cast)
	self:footage():prime_cast(cast)
end
