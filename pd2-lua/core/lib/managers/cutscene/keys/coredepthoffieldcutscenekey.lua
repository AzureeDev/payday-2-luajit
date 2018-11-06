require("core/lib/managers/cutscene/keys/CoreCutsceneKeyBase")
require("core/lib/utils/dev/ews/CoreCameraDistancePicker")

CoreDepthOfFieldCutsceneKey = CoreDepthOfFieldCutsceneKey or class(CoreCutsceneKeyBase)
CoreDepthOfFieldCutsceneKey.ELEMENT_NAME = "camera_focus"
CoreDepthOfFieldCutsceneKey.NAME = "Camera Focus"
CoreDepthOfFieldCutsceneKey.DEFAULT_NEAR_DISTANCE = 15
CoreDepthOfFieldCutsceneKey.DEFAULT_FAR_DISTANCE = 10000

CoreDepthOfFieldCutsceneKey:register_serialized_attribute("near_distance", CoreDepthOfFieldCutsceneKey.DEFAULT_NEAR_DISTANCE, tonumber)
CoreDepthOfFieldCutsceneKey:register_serialized_attribute("far_distance", CoreDepthOfFieldCutsceneKey.DEFAULT_FAR_DISTANCE, tonumber)
CoreDepthOfFieldCutsceneKey:register_serialized_attribute("tracked_unit_name", "")
CoreDepthOfFieldCutsceneKey:register_serialized_attribute("tracked_object_name", "")
CoreDepthOfFieldCutsceneKey:register_control("divider1")
CoreDepthOfFieldCutsceneKey:register_serialized_attribute("transition_time", 0, tonumber)
CoreDepthOfFieldCutsceneKey:register_control("divider2")
CoreDepthOfFieldCutsceneKey:register_serialized_attribute("target_near_distance", CoreDepthOfFieldCutsceneKey.DEFAULT_NEAR_DISTANCE, tonumber)
CoreDepthOfFieldCutsceneKey:register_serialized_attribute("target_far_distance", CoreDepthOfFieldCutsceneKey.DEFAULT_FAR_DISTANCE, tonumber)
CoreDepthOfFieldCutsceneKey:register_serialized_attribute("target_tracked_unit_name", "")
CoreDepthOfFieldCutsceneKey:register_serialized_attribute("target_tracked_object_name", "")
CoreDepthOfFieldCutsceneKey:attribute_affects("tracked_unit_name", "near_distance")
CoreDepthOfFieldCutsceneKey:attribute_affects("tracked_unit_name", "far_distance")
CoreDepthOfFieldCutsceneKey:attribute_affects("tracked_unit_name", "tracked_object_name")
CoreDepthOfFieldCutsceneKey:attribute_affects("tracked_object_name", "near_distance")
CoreDepthOfFieldCutsceneKey:attribute_affects("tracked_object_name", "far_distance")
CoreDepthOfFieldCutsceneKey:attribute_affects("transition_time", "target_near_distance")
CoreDepthOfFieldCutsceneKey:attribute_affects("transition_time", "target_far_distance")
CoreDepthOfFieldCutsceneKey:attribute_affects("transition_time", "target_tracked_unit_name")
CoreDepthOfFieldCutsceneKey:attribute_affects("transition_time", "target_tracked_object_name")
CoreDepthOfFieldCutsceneKey:attribute_affects("target_tracked_unit_name", "target_near_distance")
CoreDepthOfFieldCutsceneKey:attribute_affects("target_tracked_unit_name", "target_far_distance")
CoreDepthOfFieldCutsceneKey:attribute_affects("target_tracked_unit_name", "target_tracked_object_name")
CoreDepthOfFieldCutsceneKey:attribute_affects("target_tracked_object_name", "target_near_distance")
CoreDepthOfFieldCutsceneKey:attribute_affects("target_tracked_object_name", "target_far_distance")

CoreDepthOfFieldCutsceneKey.control_for_tracked_unit_name = CoreCutsceneKeyBase.standard_combo_box_control
CoreDepthOfFieldCutsceneKey.control_for_tracked_object_name = CoreCutsceneKeyBase.standard_combo_box_control
CoreDepthOfFieldCutsceneKey.control_for_divider1 = CoreCutsceneKeyBase.standard_divider_control
CoreDepthOfFieldCutsceneKey.control_for_divider2 = CoreCutsceneKeyBase.standard_divider_control
CoreDepthOfFieldCutsceneKey.control_for_target_tracked_unit_name = CoreCutsceneKeyBase.standard_combo_box_control
CoreDepthOfFieldCutsceneKey.control_for_target_tracked_object_name = CoreCutsceneKeyBase.standard_combo_box_control

function CoreDepthOfFieldCutsceneKey:__tostring()
	return "Change camera focus."
end

function CoreDepthOfFieldCutsceneKey:populate_from_editor(cutscene_editor)
	self.super.populate_from_editor(self, cutscene_editor)

	local camera_attributes = cutscene_editor:camera_attributes()
	local near = camera_attributes.near_focus_distance_max or self.DEFAULT_NEAR_DISTANCE
	local far = camera_attributes.far_focus_distance_min or self.DEFAULT_FAR_DISTANCE

	self:set_near_distance(near)
	self:set_far_distance(far)
	self:set_target_near_distance(near)
	self:set_target_far_distance(far)
end

function CoreDepthOfFieldCutsceneKey:play(player, undo, fast_forward)
	if undo then
		local preceeding_key = self:preceeding_key()

		if preceeding_key then
			self:_set_camera_depth_of_field(player, preceeding_key:_final_target_near_distance(player), preceeding_key:_final_target_far_distance(player))
		else
			self:_set_camera_depth_of_field(player, self.DEFAULT_NEAR_DISTANCE, self.DEFAULT_FAR_DISTANCE)
		end
	elseif self:_is_editing_target_values() then
		self:_set_camera_depth_of_field(player, self:_final_target_near_distance(player), self:_final_target_far_distance(player))
	else
		self:_set_camera_depth_of_field(player, self:_final_near_distance(player), self:_final_far_distance(player))
	end
end

function CoreDepthOfFieldCutsceneKey:update(player, time)
	local transition_time = self:transition_time()
	local t = transition_time > 0 and math.min(time / transition_time, 1) or 1
	local alpha = nil

	if self:_is_editing_initial_values() then
		alpha = 0
	elseif self:_is_editing_target_values() then
		alpha = 1
	else
		alpha = self:_calc_interpolation(t)
	end

	local start_near = self:_final_near_distance(player)
	local end_near = transition_time == 0 and start_near or self:_final_target_near_distance(player)
	local near = start_near + (end_near - start_near) * alpha
	local start_far = self:_final_far_distance(player)
	local end_far = transition_time == 0 and start_far or self:_final_target_far_distance(player)
	local far = start_far + (end_far - start_far) * alpha

	self:_set_camera_depth_of_field(player, near, far)
end

function CoreDepthOfFieldCutsceneKey:update_gui(time, delta_time, player)
	local cutscene_camera_enabled = player and player:is_viewport_enabled()

	if self.__near_distance_control then
		self.__near_distance_control:update(time, delta_time)
		self.__near_distance_control:set_pick_button_enabled(cutscene_camera_enabled)
	end

	if self.__far_distance_control then
		self.__far_distance_control:update(time, delta_time)
		self.__far_distance_control:set_pick_button_enabled(cutscene_camera_enabled)
	end

	if self.__target_near_distance_control then
		self.__target_near_distance_control:update(time, delta_time)
		self.__target_near_distance_control:set_pick_button_enabled(cutscene_camera_enabled)
	end

	if self.__target_far_distance_control then
		self.__target_far_distance_control:update(time, delta_time)
		self.__target_far_distance_control:set_pick_button_enabled(cutscene_camera_enabled)
	end
end

function CoreDepthOfFieldCutsceneKey:is_valid_near_distance(value)
	return value == nil or value >= 0
end

function CoreDepthOfFieldCutsceneKey:is_valid_far_distance(value)
	return value == nil or value >= 0
end

function CoreDepthOfFieldCutsceneKey:is_valid_tracked_unit_name(value)
	return value == nil or value == "" or CoreCutsceneKeyBase.is_valid_unit_name(self, value)
end

function CoreDepthOfFieldCutsceneKey:is_valid_tracked_object_name(value)
	return value == nil or value == "" or table.contains(self:_unit_object_names(self:tracked_unit_name()), value) or false
end

function CoreDepthOfFieldCutsceneKey:is_valid_transition_time(value)
	return value and value >= 0
end

function CoreDepthOfFieldCutsceneKey:is_valid_target_near_distance(value)
	return value == nil or value >= 0
end

function CoreDepthOfFieldCutsceneKey:is_valid_target_far_distance(value)
	return value == nil or value >= 0
end

function CoreDepthOfFieldCutsceneKey:is_valid_target_tracked_unit_name(value)
	return value == nil or value == "" or CoreCutsceneKeyBase.is_valid_unit_name(self, value)
end

function CoreDepthOfFieldCutsceneKey:is_valid_target_tracked_object_name(value)
	return value == nil or value == "" or table.contains(self:_unit_object_names(self:target_tracked_unit_name()), value) or false
end

function CoreDepthOfFieldCutsceneKey:control_for_near_distance(parent_frame, callback_func)
	self.__near_distance_control = CoreCameraDistancePicker:new(parent_frame, self:near_distance())

	self.__near_distance_control:connect("EVT_COMMAND_TEXT_UPDATED", callback_func)

	return self.__near_distance_control
end

function CoreDepthOfFieldCutsceneKey:control_for_far_distance(parent_frame, callback_func)
	self.__far_distance_control = CoreCameraDistancePicker:new(parent_frame, self:far_distance())

	self.__far_distance_control:connect("EVT_COMMAND_TEXT_UPDATED", callback_func)

	return self.__far_distance_control
end

function CoreDepthOfFieldCutsceneKey:control_for_target_near_distance(parent_frame, callback_func)
	self.__target_near_distance_control = CoreCameraDistancePicker:new(parent_frame, self:target_near_distance())

	self.__target_near_distance_control:connect("EVT_COMMAND_TEXT_UPDATED", callback_func)

	return self.__target_near_distance_control
end

function CoreDepthOfFieldCutsceneKey:control_for_target_far_distance(parent_frame, callback_func)
	self.__target_far_distance_control = CoreCameraDistancePicker:new(parent_frame, self:target_far_distance())

	self.__target_far_distance_control:connect("EVT_COMMAND_TEXT_UPDATED", callback_func)

	return self.__target_far_distance_control
end

function CoreDepthOfFieldCutsceneKey:refresh_control_for_tracked_unit_name(control)
	self:refresh_control_for_unit_name(control, self:tracked_unit_name())
	control:append("")

	if self:tracked_unit_name() == "" then
		control:set_value("")
	end
end

function CoreDepthOfFieldCutsceneKey:refresh_control_for_tracked_object_name(control)
	self:refresh_control_for_object_name(control, self:tracked_unit_name(), self:tracked_object_name())
	control:append("")

	if self:tracked_object_name() == "" or not self:is_valid_tracked_object_name(self:tracked_object_name()) then
		self:set_tracked_object_name("")
		control:set_value("")
	end
end

function CoreDepthOfFieldCutsceneKey:refresh_control_for_target_tracked_unit_name(control)
	self:refresh_control_for_unit_name(control, self:target_tracked_unit_name())
	control:append("")

	if self:target_tracked_unit_name() == "" then
		control:set_value("")
	end

	control:set_enabled(self:transition_time() > 0)
end

function CoreDepthOfFieldCutsceneKey:refresh_control_for_target_tracked_object_name(control)
	self:refresh_control_for_object_name(control, self:target_tracked_unit_name(), self:target_tracked_object_name())
	control:append("")

	if self:target_tracked_object_name() == "" or not self:is_valid_target_tracked_object_name(self:target_tracked_object_name()) then
		self:set_target_tracked_object_name("")
		control:set_value("")
	end

	control:set_enabled(self:transition_time() > 0 and self:target_tracked_unit_name() ~= "")
end

function CoreDepthOfFieldCutsceneKey:refresh_control_for_near_distance(control)
	control:set_value(tostring(self:near_distance()))
	control:set_enabled(not self:is_valid_object_name(self:tracked_object_name(), self:tracked_unit_name()))
end

function CoreDepthOfFieldCutsceneKey:refresh_control_for_far_distance(control)
	control:set_value(tostring(self:far_distance()))
	control:set_enabled(not self:is_valid_object_name(self:tracked_object_name(), self:tracked_unit_name()))
end

function CoreDepthOfFieldCutsceneKey:refresh_control_for_target_near_distance(control)
	control:set_value(tostring(self:target_near_distance()))
	control:set_enabled(self:transition_time() > 0 and not self:is_valid_object_name(self:target_tracked_object_name(), self:target_tracked_unit_name()))
end

function CoreDepthOfFieldCutsceneKey:refresh_control_for_target_far_distance(control)
	control:set_value(tostring(self:target_far_distance()))
	control:set_enabled(self:transition_time() > 0 and not self:is_valid_object_name(self:target_tracked_object_name(), self:target_tracked_unit_name()))
end

function CoreDepthOfFieldCutsceneKey:_set_camera_depth_of_field(player, near, far)
	player:set_camera_depth_of_field(near, math.max(far, near))
end

function CoreDepthOfFieldCutsceneKey:_is_editing_initial_values()
	return Application:ews_enabled() and (self.__near_distance_control and self.__near_distance_control:has_focus() or self.__far_distance_control and self.__far_distance_control:has_focus())
end

function CoreDepthOfFieldCutsceneKey:_is_editing_target_values()
	return Application:ews_enabled() and (self.__target_near_distance_control and self.__target_near_distance_control:has_focus() or self.__target_far_distance_control and self.__target_far_distance_control:has_focus())
end

function CoreDepthOfFieldCutsceneKey:_final_near_distance(player)
	local distance = player:distance_from_camera(self:tracked_unit_name(), self:tracked_object_name())
	local hyperfocal_distance = self:_hyperfocal_distance()

	if distance and hyperfocal_distance then
		return distance < hyperfocal_distance and hyperfocal_distance * distance / (hyperfocal_distance + distance) or hyperfocal_distance / 2
	else
		return self:near_distance()
	end
end

function CoreDepthOfFieldCutsceneKey:_final_far_distance(player)
	local distance = player:distance_from_camera(self:tracked_unit_name(), self:tracked_object_name())
	local hyperfocal_distance = self:_hyperfocal_distance()

	if distance and hyperfocal_distance then
		return distance < hyperfocal_distance and hyperfocal_distance * distance / (hyperfocal_distance - distance) or distance
	else
		return self:far_distance()
	end
end

function CoreDepthOfFieldCutsceneKey:_final_target_near_distance(player)
	local distance = player:distance_from_camera(self:target_tracked_unit_name(), self:target_tracked_object_name())
	local hyperfocal_distance = self:_hyperfocal_distance()

	if distance and hyperfocal_distance then
		return distance < hyperfocal_distance and hyperfocal_distance * distance / (hyperfocal_distance + distance) or hyperfocal_distance / 2
	else
		return self:target_near_distance()
	end
end

function CoreDepthOfFieldCutsceneKey:_final_target_far_distance(player)
	local distance = player:distance_from_camera(self:target_tracked_unit_name(), self:target_tracked_object_name())
	local hyperfocal_distance = self:_hyperfocal_distance()

	if distance and hyperfocal_distance then
		return distance < hyperfocal_distance and hyperfocal_distance * distance / (hyperfocal_distance - distance) or distance
	else
		return self:target_far_distance()
	end
end

function CoreDepthOfFieldCutsceneKey:_hyperfocal_distance()
	return 1433
end

function CoreDepthOfFieldCutsceneKey:_calc_interpolation(t)
	return 3 * t^2 - 2 * t^3
end
