require("core/lib/managers/cutscene/keys/CoreCutsceneKeyBase")

CoreZoomCameraCutsceneKey = CoreZoomCameraCutsceneKey or class(CoreCutsceneKeyBase)
CoreZoomCameraCutsceneKey.ELEMENT_NAME = "camera_zoom"
CoreZoomCameraCutsceneKey.NAME = "Camera Zoom"
CoreZoomCameraCutsceneKey.DEFAULT_CAMERA_FOV = 55
CoreZoomCameraCutsceneKey.INTERPOLATION_FUNCTIONS = {
	Linear = function (t, bias)
		return t
	end,
	["J curve"] = function (t, bias)
		local b = 2 * (1 - bias)
		local a = 1 - b

		return a * t^2 + b * t
	end,
	["S curve"] = function (t, bias)
		local a = 1 + bias * 2
		local b = a + 1

		return b * t^a - a * t^b
	end
}

CoreZoomCameraCutsceneKey:register_serialized_attribute("start_fov", CoreZoomCameraCutsceneKey.DEFAULT_CAMERA_FOV, tonumber)
CoreZoomCameraCutsceneKey:register_serialized_attribute("end_fov", CoreZoomCameraCutsceneKey.DEFAULT_CAMERA_FOV, tonumber)
CoreZoomCameraCutsceneKey:register_serialized_attribute("transition_time", 0, tonumber)
CoreZoomCameraCutsceneKey:register_serialized_attribute("interpolation", "Linear")
CoreZoomCameraCutsceneKey:register_serialized_attribute("interpolation_bias", 0.5, function (n)
	return (tonumber(n) or 0) / 100
end)

function CoreZoomCameraCutsceneKey:__tostring()
	return "Change camera zoom."
end

function CoreZoomCameraCutsceneKey:populate_from_editor(cutscene_editor)
	self.super.populate_from_editor(self, cutscene_editor)

	local camera_attributes = cutscene_editor:camera_attributes()

	self:set_start_fov(camera_attributes.fov)
	self:set_end_fov(camera_attributes.fov)
end

function CoreZoomCameraCutsceneKey:play(player, undo, fast_forward)
	if undo then
		local preceeding_key = self:preceeding_key()

		if preceeding_key then
			player:set_camera_attribute("fov", preceeding_key:end_fov())
		else
			player:set_camera_attribute("fov", CoreZoomCameraCutsceneKey.DEFAULT_CAMERA_FOV)
		end
	else
		player:set_camera_attribute("fov", self:start_fov())
	end
end

function CoreZoomCameraCutsceneKey:update(player, time)
	local transition_time = self:transition_time()

	if time <= transition_time + 0.03333333333333333 then
		local t = transition_time > 0 and math.min(time / transition_time, 1) or 1
		local alpha = self:_calc_interpolation(t)
		local fov = self:start_fov() + (self:end_fov() - self:start_fov()) * alpha

		player:set_camera_attribute("fov", fov)
	end
end

function CoreZoomCameraCutsceneKey:is_valid_start_fov(value)
	return value and value > 0 and value < 180
end

function CoreZoomCameraCutsceneKey:is_valid_transition_time(value)
	return value and value >= 0
end

function CoreZoomCameraCutsceneKey:is_valid_interpolation(value)
	return self.INTERPOLATION_FUNCTIONS[value] ~= nil
end

function CoreZoomCameraCutsceneKey:is_valid_interpolation_bias(value)
	return value and value >= 0 and value <= 1
end

CoreZoomCameraCutsceneKey.is_valid_end_fov = CoreZoomCameraCutsceneKey.is_valid_start_fov
CoreZoomCameraCutsceneKey.control_for_interpolation = CoreCutsceneKeyBase.standard_combo_box_control
CoreZoomCameraCutsceneKey.control_for_interpolation_bias = CoreCutsceneKeyBase.standard_percentage_slider_control
CoreZoomCameraCutsceneKey.refresh_control_for_interpolation = CoreCutsceneKeyBase:standard_combo_box_control_refresh("interpolation", table.map_keys(CoreZoomCameraCutsceneKey.INTERPOLATION_FUNCTIONS, function (a, b)
	return a == "Linear" or a < b
end))
CoreZoomCameraCutsceneKey.refresh_control_for_interpolation_bias = CoreCutsceneKeyBase:standard_percentage_slider_control_refresh("interpolation_bias")

function CoreZoomCameraCutsceneKey:_calc_interpolation(t)
	local interpolation_func = self.INTERPOLATION_FUNCTIONS[self:interpolation()]

	return interpolation_func(t, math.clamp(self:interpolation_bias(), 0, 1))
end
