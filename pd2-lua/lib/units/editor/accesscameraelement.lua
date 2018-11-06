AccessCameraUnitElement = AccessCameraUnitElement or class(MissionElement)

function AccessCameraUnitElement:init(unit)
	AccessCameraUnitElement.super.init(self, unit)

	self._camera_unit = nil

	self:_add_text_options()

	self._hed.text_id = "debug_none"
	self._hed.yaw_limit = 25
	self._hed.pitch_limit = 25
	self._hed.camera_u_id = nil

	table.insert(self._save_values, "text_id")
	table.insert(self._save_values, "yaw_limit")
	table.insert(self._save_values, "pitch_limit")
	table.insert(self._save_values, "camera_u_id")
end

function AccessCameraUnitElement:layer_finished()
	AccessCameraUnitElement.super.layer_finished(self)

	if self._hed.camera_u_id then
		local unit = managers.worlddefinition:get_unit_on_load(self._hed.camera_u_id, callback(self, self, "load_unit"))

		if unit then
			self._camera_unit = unit
		end
	end
end

function AccessCameraUnitElement:load_unit(unit)
	if unit then
		self._camera_unit = unit
	end
end

function AccessCameraUnitElement:update_selected(t, dt, selected_unit, all_units)
	Application:draw_cone(self._unit:position(), self._unit:position() + self._unit:rotation():y() * 75, 35, 1, 1, 1)

	if alive(self._camera_unit) then
		self:_draw_link({
			g = 0.75,
			b = 0,
			r = 0,
			from_unit = self._unit,
			to_unit = self._camera_unit
		})
		Application:draw(self._camera_unit, 0, 0.75, 0)
	elseif self._hed.camera_u_id then
		self._hed.camera_u_id = nil
	end
end

function AccessCameraUnitElement:update_unselected(t, dt, selected_unit, all_units)
	if alive(self._camera_unit) then
		-- Nothing
	elseif self._hed.camera_u_id then
		self._hed.camera_u_id = nil
	end
end

function AccessCameraUnitElement:update_editing()
end

function AccessCameraUnitElement:_add_text_options_from_file(path)
	local xml = SystemFS:parse_xml(Application:base_path() .. "../../assets/" .. path)

	if xml then
		for child in xml:children() do
			local s_id = child:parameter("id")

			if string.find(s_id, "cam_") then
				table.insert(self._text_options, s_id)
			end
		end
	end
end

function AccessCameraUnitElement:_add_text_options()
	self._text_options = {
		"debug_none"
	}

	self:_add_text_options_from_file("strings/hud.strings")
	self:_add_text_options_from_file("strings/wip.strings")
end

function AccessCameraUnitElement:_set_text()
	self._text:set_value(managers.localization:text(self._hed.text_id))
end

function AccessCameraUnitElement:add_camera_uid()
	local unit = SecurityCameraUnitElement._find_camera_raycast(self)

	if unit then
		if self._hed.camera_u_id and self._hed.camera_u_id == unit:unit_data().unit_id then
			self:_remove_camera_unit()
		else
			self:_add_camera_unit(unit)
		end
	end
end

function AccessCameraUnitElement:set_element_data(params, ...)
	AccessCameraUnitElement.super.set_element_data(self, params, ...)

	if params.value == "text_id" then
		self:_set_text()
	end
end

function AccessCameraUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_camera_uid"))
end

function AccessCameraUnitElement:_add_camera_filter(unit)
	local id = unit:unit_data().unit_id

	if self._hed.camera_u_id == id then
		return false
	end

	return unit:base() and unit:base().security_camera
end

function AccessCameraUnitElement:_remove_camera_filter(unit)
	return self._hed.camera_u_id == unit:unit_data().unit_id
end

function AccessCameraUnitElement:_add_camera_unit(unit)
	self._hed.camera_u_id = unit:unit_data().unit_id
	self._camera_unit = unit
end

function AccessCameraUnitElement:_remove_camera_unit()
	self._hed.camera_u_id = nil
	self._camera_unit = nil
end

function AccessCameraUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_add_remove_static_unit_from_list(panel, panel_sizer, {
		single = true,
		add_filter = callback(self, self, "_add_camera_filter"),
		add_result = callback(self, self, "_add_camera_unit"),
		remove_filter = callback(self, self, "_remove_camera_filter"),
		remove_result = callback(self, self, "_remove_camera_unit")
	})
	self:_build_value_combobox(panel, panel_sizer, "text_id", self._text_options, "Select a text id from the combobox")

	local text_sizer = EWS:BoxSizer("HORIZONTAL")

	text_sizer:add(EWS:StaticText(panel, "Text: ", "", ""), 1, 2, "ALIGN_CENTER_VERTICAL,RIGHT,EXPAND")

	self._text = EWS:StaticText(panel, managers.localization:text(self._hed.text_id), "", "")

	text_sizer:add(self._text, 2, 2, "RIGHT,TOP,EXPAND")
	panel_sizer:add(text_sizer, 0, 4, "EXPAND,BOTTOM")
	self:_build_value_number(panel, panel_sizer, "yaw_limit", {
		floats = 0,
		min = -1
	}, "Specify a yaw limit.")
	self:_build_value_number(panel, panel_sizer, "pitch_limit", {
		floats = 0,
		min = -1
	}, "Specify a pitch limit.")
end

AccessCameraOperatorUnitElement = AccessCameraOperatorUnitElement or class(MissionElement)
AccessCameraOperatorUnitElement.LINK_ELEMENTS = {
	"elements"
}

function AccessCameraOperatorUnitElement:init(unit)
	AccessCameraOperatorUnitElement.super.init(self, unit)

	self._hed.operation = "none"
	self._hed.elements = {}

	table.insert(self._save_values, "operation")
	table.insert(self._save_values, "elements")
end

function AccessCameraOperatorUnitElement:draw_links(t, dt, selected_unit, all_units)
	AccessCameraOperatorUnitElement.super.draw_links(self, t, dt, selected_unit)

	for _, id in ipairs(self._hed.elements) do
		local unit = all_units[id]
		local draw = not selected_unit or unit == selected_unit or self._unit == selected_unit

		if draw then
			self:_draw_link({
				g = 0.75,
				b = 0.25,
				r = 0.75,
				from_unit = self._unit,
				to_unit = unit
			})
		end
	end
end

function AccessCameraOperatorUnitElement:update_editing()
end

function AccessCameraOperatorUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit and (ray.unit:name() == Idstring("units/dev_tools/mission_elements/point_access_camera/point_access_camera") or ray.unit:name() == Idstring("units/dev_tools/mission_elements/ai_security_camera/ai_security_camera")) then
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.elements, id) then
			table.delete(self._hed.elements, id)
		else
			table.insert(self._hed.elements, id)
		end
	end
end

function AccessCameraOperatorUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

function AccessCameraOperatorUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local exact_names = {
		"units/dev_tools/mission_elements/point_access_camera/point_access_camera",
		"units/dev_tools/mission_elements/ai_security_camera/ai_security_camera"
	}

	self:_build_add_remove_unit_from_list(panel, panel_sizer, self._hed.elements, nil, exact_names)
	self:_build_value_combobox(panel, panel_sizer, "operation", {
		"none",
		"destroy"
	}, "Select an operation for the selected elements")
	self:_add_help_text("This element can modify point_access_camera element. Select elements to modify using insert and clicking on them.")
end

AccessCameraTriggerUnitElement = AccessCameraTriggerUnitElement or class(MissionElement)
AccessCameraTriggerUnitElement.LINK_ELEMENTS = {
	"elements"
}

function AccessCameraTriggerUnitElement:init(unit)
	AccessCameraTriggerUnitElement.super.init(self, unit)

	self._hed.trigger_type = "accessed"
	self._hed.elements = {}

	table.insert(self._save_values, "trigger_type")
	table.insert(self._save_values, "elements")
end

function AccessCameraTriggerUnitElement:draw_links(t, dt, selected_unit, all_units)
	AccessCameraTriggerUnitElement.super.draw_links(self, t, dt, selected_unit)

	for _, id in ipairs(self._hed.elements) do
		local unit = all_units[id]
		local draw = not selected_unit or unit == selected_unit or self._unit == selected_unit

		if draw then
			self:_draw_link({
				g = 0.85,
				b = 0.25,
				r = 0.85,
				from_unit = unit,
				to_unit = self._unit
			})
		end
	end
end

function AccessCameraTriggerUnitElement:update_editing()
end

function AccessCameraTriggerUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit and (ray.unit:name() == Idstring("units/dev_tools/mission_elements/point_access_camera/point_access_camera") or ray.unit:name() == Idstring("units/dev_tools/mission_elements/ai_security_camera/ai_security_camera")) then
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.elements, id) then
			table.delete(self._hed.elements, id)
		else
			table.insert(self._hed.elements, id)
		end
	end
end

function AccessCameraTriggerUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

function AccessCameraTriggerUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local exact_names = {
		"units/dev_tools/mission_elements/point_access_camera/point_access_camera",
		"units/dev_tools/mission_elements/ai_security_camera/ai_security_camera"
	}

	self:_build_add_remove_unit_from_list(panel, panel_sizer, self._hed.elements, nil, exact_names)
	self:_build_value_combobox(panel, panel_sizer, "trigger_type", {
		"accessed",
		"destroyed",
		"alarm"
	}, "Select a trigger type for the selected elements")
	self:_add_help_text("This element is a trigger to point_access_camera element.")
end
