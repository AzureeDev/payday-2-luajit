SecurityCameraUnitElement = SecurityCameraUnitElement or class(MissionElement)
SecurityCameraUnitElement.SAVE_UNIT_POSITION = false
SecurityCameraUnitElement.SAVE_UNIT_ROTATION = false
SecurityCameraUnitElement._object_original_rotations = {}

function SecurityCameraUnitElement:init(unit)
	SecurityCameraUnitElement.super.init(self, unit)

	self._hed.yaw = 0
	self._hed.pitch = -30
	self._hed.fov = 60
	self._hed.detection_range = 15
	self._hed.suspicion_range = 7
	self._hed.detection_delay_min = 2
	self._hed.detection_delay_max = 3

	table.insert(self._save_values, "camera_u_id")
	table.insert(self._save_values, "ai_enabled")
	table.insert(self._save_values, "apply_settings")
end

function SecurityCameraUnitElement:post_init(...)
	SecurityCameraUnitElement.super.post_init(self, ...)

	if self._hed.apply_settings then
		table.insert(self._save_values, "yaw")
		table.insert(self._save_values, "pitch")
		table.insert(self._save_values, "fov")
		table.insert(self._save_values, "detection_range")
		table.insert(self._save_values, "suspicion_range")
		table.insert(self._save_values, "detection_delay_min")
		table.insert(self._save_values, "detection_delay_max")
	end
end

function SecurityCameraUnitElement:_add_camera_filter(unit)
	local id = unit:unit_data().unit_id

	if self._hed.camera_u_id == id then
		return false
	end

	return unit:base() and unit:base().security_camera
end

function SecurityCameraUnitElement:_remove_camera_filter(unit)
	return self._hed.camera_u_id == unit:unit_data().unit_id
end

function SecurityCameraUnitElement:_remove_camera_unit()
	self:_set_camera_unit(nil)
end

function SecurityCameraUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_add_remove_static_unit_from_list(panel, panel_sizer, {
		single = true,
		add_filter = callback(self, self, "_add_camera_filter"),
		add_result = callback(self, self, "_set_camera_unit"),
		remove_filter = callback(self, self, "_remove_camera_filter"),
		remove_result = callback(self, self, "_remove_camera_unit")
	})

	local ai_enabled = EWS:CheckBox(panel, "AI Enabled", "")

	ai_enabled:set_value(self._hed.ai_enabled)
	ai_enabled:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "ai_enabled",
		ctrlr = ai_enabled
	})
	panel_sizer:add(ai_enabled, 0, 0, "EXPAND")

	local apply_settings = EWS:CheckBox(panel, "Apply Settings", "")

	apply_settings:set_value(self._hed.apply_settings)
	apply_settings:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "apply_settings",
		ctrlr = apply_settings
	})
	panel_sizer:add(apply_settings, 0, 0, "EXPAND")

	local yaw_params = {
		name_proportions = 1,
		name = "Yaw:",
		ctrlr_proportions = 2,
		tooltip = "Specify camera yaw (degrees).",
		sorted = false,
		min = -180,
		floats = 0,
		max = 180,
		panel = panel,
		sizer = panel_sizer,
		value = self._hed.yaw
	}
	local yaw = CoreEWS.number_controller(yaw_params)

	yaw:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "yaw",
		ctrlr = yaw
	})
	yaw:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "yaw",
		ctrlr = yaw
	})

	local pitch_params = {
		name_proportions = 1,
		name = "Pitch:",
		ctrlr_proportions = 2,
		tooltip = "Specify camera pitch (degrees).",
		sorted = false,
		min = -90,
		floats = 0,
		max = 90,
		panel = panel,
		sizer = panel_sizer,
		value = self._hed.pitch
	}
	local pitch = CoreEWS.number_controller(pitch_params)

	pitch:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "pitch",
		ctrlr = pitch
	})
	pitch:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "pitch",
		ctrlr = pitch
	})

	local fov_params = {
		name_proportions = 1,
		name = "FOV:",
		ctrlr_proportions = 2,
		tooltip = "Specify camera FOV (degrees).",
		sorted = false,
		min = 0,
		floats = 0,
		max = 180,
		panel = panel,
		sizer = panel_sizer,
		value = self._hed.fov
	}
	local fov = CoreEWS.number_controller(fov_params)

	fov:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "fov",
		ctrlr = fov
	})
	fov:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "fov",
		ctrlr = fov
	})

	local detection_range_params = {
		name = "Detection range:",
		ctrlr_proportions = 2,
		name_proportions = 1,
		tooltip = "Specify camera detection_range (meters).",
		sorted = false,
		min = 0,
		floats = 0,
		panel = panel,
		sizer = panel_sizer,
		value = self._hed.detection_range
	}
	local detection_range = CoreEWS.number_controller(detection_range_params)

	detection_range:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "detection_range",
		ctrlr = detection_range
	})
	detection_range:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "detection_range",
		ctrlr = detection_range
	})

	local suspicion_range_params = {
		name = "Suspicion range:",
		ctrlr_proportions = 2,
		name_proportions = 1,
		tooltip = "Specify camera suspicion_range.",
		sorted = false,
		min = 0,
		floats = 0,
		panel = panel,
		sizer = panel_sizer,
		value = self._hed.suspicion_range
	}
	local suspicion_range = CoreEWS.number_controller(suspicion_range_params)

	suspicion_range:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "suspicion_range",
		ctrlr = suspicion_range
	})
	suspicion_range:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "suspicion_range",
		ctrlr = suspicion_range
	})

	local detection_delay_min_params = {
		name = "Detection delay min:",
		ctrlr_proportions = 2,
		name_proportions = 1,
		tooltip = "Detection delay at zero distance.",
		sorted = false,
		min = 0,
		floats = 0,
		panel = panel,
		sizer = panel_sizer,
		value = self._hed.detection_delay_min
	}
	local detection_delay_min = CoreEWS.number_controller(detection_delay_min_params)

	detection_delay_min:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "detection_delay_min",
		ctrlr = detection_delay_min
	})
	detection_delay_min:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "detection_delay_min",
		ctrlr = detection_delay_min
	})

	local detection_delay_max_params = {
		name = "Detection delay max:",
		ctrlr_proportions = 2,
		name_proportions = 1,
		tooltip = "Detection delay at max distance.",
		sorted = false,
		min = 0,
		floats = 0,
		panel = panel,
		sizer = panel_sizer,
		value = self._hed.detection_delay_max
	}
	local detection_delay_max = CoreEWS.number_controller(detection_delay_max_params)

	detection_delay_max:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "detection_delay_max",
		ctrlr = detection_delay_max
	})
	detection_delay_max:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "detection_delay_max",
		ctrlr = detection_delay_max
	})
end

function SecurityCameraUnitElement:update_editing()
	self:_find_camera_raycast()
	self:_raycast()
end

function SecurityCameraUnitElement:_find_camera_raycast()
	local from = managers.editor:get_cursor_look_point(0)
	local to = managers.editor:get_cursor_look_point(100000)
	local ray = World:raycast("ray", from, to, "slot_mask", 1)

	if not ray then
		return
	end

	if ray.unit:id() == -1 then
		return
	end

	if not ray.unit:base() or not ray.unit:base().security_camera then
		return
	end

	Application:draw(ray.unit, 0, 1, 0)

	return ray.unit
end

function SecurityCameraUnitElement:_raycast()
	local from = managers.editor:get_cursor_look_point(0)
	local to = managers.editor:get_cursor_look_point(100000)
	local ray = World:raycast(from, to, nil, 10)

	if ray and ray.position then
		Application:draw_sphere(ray.position, 10, 1, 1, 1)

		return ray.position
	end

	return nil
end

function SecurityCameraUnitElement:_lmb()
	local unit = self:_find_camera_raycast()

	if unit then
		if self._camera_u_data and self._camera_u_data.unit == unit then
			self:_set_camera_unit(nil)
		else
			self:_set_camera_unit(unit)
		end
	end
end

function SecurityCameraUnitElement:update_selected(t, dt, selected_unit, all_units)
	self:_chk_units_alive()

	if selected_unit and (not self._camera_u_data or self._camera_u_data.unit ~= selected_unit) and self._unit ~= selected_unit then
		return
	end

	if self._camera_u_data then
		self:_draw_link({
			g = 0.75,
			b = 0,
			r = 0,
			from_unit = self._unit,
			to_unit = self._camera_u_data.unit
		})
	end
end

function SecurityCameraUnitElement:update_unselected(t, dt, selected_unit, all_units)
	self:_chk_units_alive()
end

function SecurityCameraUnitElement:_chk_units_alive()
	if self._camera_u_data and not alive(self._camera_u_data.unit) then
		self:_set_camera_unit(nil)
	end
end

function SecurityCameraUnitElement:draw_links(t, dt, selected_unit, all_units)
	SecurityCameraUnitElement.super.draw_links(self, t, dt, selected_unit)
	self:_chk_units_alive()

	if selected_unit and (not self._camera_u_data or self._camera_u_data.unit ~= selected_unit) and self._unit ~= selected_unit then
		return
	end

	if self._camera_u_data then
		self:_draw_link({
			g = 0.75,
			b = 0,
			r = 0,
			from_unit = self._unit,
			to_unit = self._camera_u_data.unit
		})
	end
end

function SecurityCameraUnitElement:layer_finished()
	SecurityCameraUnitElement.super.layer_finished(self)

	if self._hed.camera_u_id then
		local unit = managers.worlddefinition:get_unit_on_load(self._hed.camera_u_id, callback(self, self, "load_camera_unit"))

		if alive(unit) and unit:base() and unit:base().security_camera then
			self:_set_camera_unit(unit)
		else
			self:_set_camera_unit(nil)
		end
	end
end

function SecurityCameraUnitElement:load_camera_unit(unit)
	self:_set_camera_unit(unit)
end

function SecurityCameraUnitElement:selected()
	AIAttentionElement.super.selected(self)
	self:_chk_units_alive()

	if self._camera_u_data then
		self:_align_camera_unit()
	end
end

function SecurityCameraUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "_lmb"))
end

function SecurityCameraUnitElement:_set_camera_unit(unit)
	if self._camera_u_data and self._camera_u_data.unit == unit or not self._camera_u_data and not unit then
		return
	end

	if self._camera_u_data then
		self._camera_u_data.unit:get_object(Idstring("CameraYaw")):set_local_rotation(self._camera_u_data.original_rot_yaw)
		self._camera_u_data.unit:get_object(Idstring("CameraPitch")):set_local_rotation(self._camera_u_data.original_rot_pitch)
		self._camera_u_data.unit:set_moving()
	end

	if unit then
		local orig_rot = self._object_original_rotations[unit:name():key()]

		if not orig_rot then
			local obj_yaw = unit:get_object(Idstring("CameraYaw"))
			local obj_pitch = unit:get_object(Idstring("CameraPitch"))
			local original_rot_yaw = obj_yaw:local_rotation()
			local original_rot_pitch = obj_pitch:local_rotation()
			self._object_original_rotations[unit:name():key()] = {
				yaw = original_rot_yaw,
				pitch = original_rot_pitch
			}
			orig_rot = self._object_original_rotations[unit:name():key()]
		end

		self._camera_u_data = {
			unit = unit,
			original_rot_yaw = orig_rot.yaw,
			original_rot_pitch = orig_rot.pitch
		}
		self._hed.camera_u_id = unit:unit_data().unit_id

		self:_align_camera_unit()
	else
		self._camera_u_data = nil
		self._hed.camera_u_id = nil
	end
end

function SecurityCameraUnitElement:set_element_data(...)
	local had_settings = self._hed.apply_settings

	SecurityCameraUnitElement.super.set_element_data(self, ...)
	self:_chk_units_alive()

	if self._camera_u_data then
		self:_align_camera_unit()
	end

	if had_settings and not self._hed.apply_settings then
		table.delete(self._save_values, "yaw")
		table.delete(self._save_values, "pitch")
		table.delete(self._save_values, "fov")
		table.delete(self._save_values, "detection_range")
		table.delete(self._save_values, "suspicion_range")
		table.delete(self._save_values, "detection_delay_min")
		table.delete(self._save_values, "detection_delay_max")
		print("removing settings", inspect(self._save_values))
	elseif not had_settings and self._hed.apply_settings then
		table.insert(self._save_values, "yaw")
		table.insert(self._save_values, "pitch")
		table.insert(self._save_values, "fov")
		table.insert(self._save_values, "detection_range")
		table.insert(self._save_values, "suspicion_range")
		table.insert(self._save_values, "detection_delay_min")
		table.insert(self._save_values, "detection_delay_max")
		print("adding settings", inspect(self._save_values))
	end
end

function SecurityCameraUnitElement:_align_camera_unit()
	if self._hed.apply_settings then
		local unit = self._camera_u_data.unit
		local obj_yaw = unit:get_object(Idstring("CameraYaw"))
		local obj_pitch = unit:get_object(Idstring("CameraPitch"))
		local new_yaw_rot = Rotation(180 + self._hed.yaw, self._camera_u_data.original_rot_yaw:pitch(), self._camera_u_data.original_rot_yaw:roll())

		obj_yaw:set_local_rotation(new_yaw_rot)

		local new_pitch_rot = Rotation(self._camera_u_data.original_rot_pitch:yaw(), self._hed.pitch, self._camera_u_data.original_rot_pitch:roll())

		obj_pitch:set_local_rotation(new_pitch_rot)
	else
		self._camera_u_data.unit:get_object(Idstring("CameraYaw")):set_local_rotation(self._camera_u_data.original_rot_yaw)
		self._camera_u_data.unit:get_object(Idstring("CameraPitch")):set_local_rotation(self._camera_u_data.original_rot_pitch)
	end

	self._camera_u_data.unit:set_moving()
end

