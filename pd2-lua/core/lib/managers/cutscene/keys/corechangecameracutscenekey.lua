require("core/lib/managers/cutscene/keys/CoreCutsceneKeyBase")

CoreChangeCameraCutsceneKey = CoreChangeCameraCutsceneKey or class(CoreCutsceneKeyBase)
CoreChangeCameraCutsceneKey.ELEMENT_NAME = "change_camera"
CoreChangeCameraCutsceneKey.NAME = "Camera Change"

CoreChangeCameraCutsceneKey:register_serialized_attribute("camera", nil)

function CoreChangeCameraCutsceneKey:__tostring()
	return "Change camera to \"" .. self:camera() .. "\"."
end

function CoreChangeCameraCutsceneKey:load(key_node, loading_class)
	self.super.load(self, key_node, loading_class)

	if self.__camera == nil then
		self.__camera = key_node:parameter("ref_obj_name") or "camera"
	end
end

function CoreChangeCameraCutsceneKey:evaluate(player, fast_forward)
	player:set_camera(self:camera())
end

function CoreChangeCameraCutsceneKey:is_valid_camera(camera)
	return self.super.is_valid_unit_name(self, camera) and string.begins(camera, "camera")
end
