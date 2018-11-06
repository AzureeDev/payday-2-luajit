core:module("CoreElementWorldCamera")
core:import("CoreMissionScriptElement")

ElementWorldCamera = ElementWorldCamera or class(CoreMissionScriptElement.MissionScriptElement)

function ElementWorldCamera:init(...)
	ElementWorldCamera.super.init(self, ...)
end

function ElementWorldCamera:client_on_executed(...)
	self:on_executed(...)
end

function ElementWorldCamera:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._values.worldcamera_sequence and self._values.worldcamera_sequence ~= "none" then
		managers.worldcamera:play_world_camera_sequence(self._values.worldcamera_sequence)
	elseif self._values.worldcamera ~= "none" then
		managers.worldcamera:play_world_camera(self._values.worldcamera)
	elseif Application:editor() then
		managers.editor:output_error("Can not play worldcamera or sequence \"none\"")
	end

	ElementWorldCamera.super.on_executed(self, instigator)
end

ElementWorldCameraTrigger = ElementWorldCameraTrigger or class(CoreMissionScriptElement.MissionScriptElement)

function ElementWorldCameraTrigger:init(...)
	ElementWorldCameraTrigger.super.init(self, ...)

	if self._values.worldcamera_trigger_sequence ~= "none" then
		if self._values.worldcamera_trigger_after_clip == "done" then
			self._sequence = managers.worldcamera:add_sequence_done_callback(self._values.worldcamera_trigger_sequence, callback(self, self, "on_executed"))
		else
			self._sequence = managers.worldcamera:add_sequence_camera_clip_callback(self._values.worldcamera_trigger_sequence, self._values.worldcamera_trigger_after_clip, callback(self, self, "on_executed"))
		end
	end
end

function ElementWorldCameraTrigger:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	instigator = managers.mission:default_instigator()

	ElementWorldCameraTrigger.super.on_executed(self, instigator)
end
