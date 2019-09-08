core:import("CoreShapeManager")

CoreAreaTriggerUnitElement = CoreAreaTriggerUnitElement or class(MissionElement)
CoreAreaTriggerUnitElement.LINK_ELEMENTS = {
	"spawn_unit_elements"
}
AreaTriggerUnitElement = AreaTriggerUnitElement or class(CoreAreaTriggerUnitElement)

function AreaTriggerUnitElement:init(...)
	CoreAreaTriggerUnitElement.init(self, ...)
end

function CoreAreaTriggerUnitElement:init(unit)
	MissionElement.init(self, unit)

	self._timeline_color = Vector3(1, 1, 0)
	self._brush = Draw:brush()
	self._hed.trigger_times = 1
	self._hed.interval = 0.1
	self._hed.trigger_on = "on_enter"
	self._hed.instigator = managers.mission:default_area_instigator()
	self._hed.shape_type = "box"
	self._hed.width = 500
	self._hed.depth = 500
	self._hed.height = 500
	self._hed.radius = 250
	self._hed.spawn_unit_elements = {}
	self._hed.amount = "1"
	self._hed.instigator_name = ""
	self._hed.use_shape_element_ids = nil
	self._hed.use_disabled_shapes = false
	self._hed.rules_element_ids = nil
	self._hed.unit_ids = nil

	table.insert(self._save_values, "interval")
	table.insert(self._save_values, "trigger_on")
	table.insert(self._save_values, "instigator")
	table.insert(self._save_values, "shape_type")
	table.insert(self._save_values, "width")
	table.insert(self._save_values, "depth")
	table.insert(self._save_values, "height")
	table.insert(self._save_values, "radius")
	table.insert(self._save_values, "spawn_unit_elements")
	table.insert(self._save_values, "amount")
	table.insert(self._save_values, "instigator_name")
	table.insert(self._save_values, "use_shape_element_ids")
	table.insert(self._save_values, "use_disabled_shapes")
	table.insert(self._save_values, "rules_element_ids")
	table.insert(self._save_values, "unit_ids")
end

function CoreAreaTriggerUnitElement:draw_links(t, dt, selected_unit, all_units)
	MissionElement.draw_links(self, t, dt, selected_unit, all_units)

	for _, id in ipairs(self._hed.spawn_unit_elements) do
		local unit = all_units[id]

		if self:_should_draw_link(selected_unit, unit) then
			self:_draw_link({
				g = 0,
				b = 0,
				r = 0.75,
				from_unit = self._unit,
				to_unit = unit
			})
		end
	end

	if self._hed.unit_ids then
		for _, id in ipairs(self._hed.unit_ids) do
			local unit = managers.editor:layer("Statics"):created_units_pairs()[id]

			if alive(unit) then
				if self:_should_draw_link(selected_unit, unit) then
					self:_draw_link({
						g = 0.5,
						b = 0.75,
						r = 0,
						from_unit = unit,
						to_unit = self._unit
					})
					Application:draw(unit, 0, 0.5, 0.75)
				end
			else
				self:_remove_unit_id(id)
			end
		end
	end

	self:_check_removed_units(all_units)

	if self._hed.use_shape_element_ids then
		for _, id in ipairs(self._hed.use_shape_element_ids) do
			local unit = all_units[id]

			if self:_should_draw_link(selected_unit, unit) then
				local r, g, b = unit:mission_element():get_link_color()

				self:_draw_link({
					from_unit = unit,
					to_unit = self._unit,
					r = r,
					g = g,
					b = b
				})
			end
		end
	end

	if self._hed.rules_element_ids then
		for _, id in ipairs(self._hed.rules_element_ids) do
			local unit = all_units[id]

			if self:_should_draw_link(selected_unit, unit) then
				local r, g, b = unit:mission_element():get_link_color()

				self:_draw_link({
					from_unit = unit,
					to_unit = self._unit,
					r = r,
					g = g,
					b = b
				})
			end
		end
	end
end

function CoreAreaTriggerUnitElement:_check_removed_units(all_units)
	if self._hed.use_shape_element_ids then
		for _, id in ipairs(clone(self._hed.use_shape_element_ids)) do
			local unit = all_units[id]

			if not alive(unit) then
				table.delete(self._hed.use_shape_element_ids, id)
			end
		end
	end

	if self._hed.rules_element_ids then
		for _, id in ipairs(clone(self._hed.rules_element_ids)) do
			local unit = all_units[id]

			if not alive(unit) then
				table.delete(self._hed.rules_element_ids, id)
			end
		end
	end
end

function CoreAreaTriggerUnitElement:update_editing()
end

function CoreAreaTriggerUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit then
		if string.find(ray.unit:name():s(), "point_spawn_unit", 1, true) then
			local id = ray.unit:unit_data().unit_id

			if table.contains(self._hed.spawn_unit_elements, id) then
				table.delete(self._hed.spawn_unit_elements, id)
			else
				table.insert(self._hed.spawn_unit_elements, id)
			end
		end

		if ray.unit:name():s() == "core/units/mission_elements/trigger_area/trigger_area" or string.find(ray.unit:name():s(), "point_shape", 1, true) then
			self._hed.use_shape_element_ids = self._hed.use_shape_element_ids or {}
			local id = ray.unit:unit_data().unit_id

			if table.contains(self._hed.use_shape_element_ids, id) then
				table.delete(self._hed.use_shape_element_ids, id)
			else
				table.insert(self._hed.use_shape_element_ids, id)
			end

			self._hed.use_shape_element_ids = #self._hed.use_shape_element_ids > 0 and self._hed.use_shape_element_ids or nil

			self:_set_shape_type()
		end

		if string.find(ray.unit:name():s(), "data_instigator_rule", 1, true) then
			self._hed.rules_element_ids = self._hed.rules_element_ids or {}
			local id = ray.unit:unit_data().unit_id

			if table.contains(self._hed.rules_element_ids, id) then
				table.delete(self._hed.rules_element_ids, id)
			else
				table.insert(self._hed.rules_element_ids, id)
			end

			self._hed.rules_element_ids = #self._hed.rules_element_ids > 0 and self._hed.rules_element_ids or nil
		end

		return
	end

	local ray = managers.editor:unit_by_raycast({
		ray_type = "body editor",
		mask = 1
	})

	if ray and ray.unit then
		self._hed.unit_ids = self._hed.unit_ids or {}
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.unit_ids, id) then
			self:_remove_unit_id(id)
		else
			self:_add_unit_id(id)
		end
	end
end

function CoreAreaTriggerUnitElement:_add_unit_id(id)
	table.insert(self._hed.unit_ids, id)

	if self._instigator_ctrlr then
		self._instigator_ctrlr:set_enabled(not self._hed.unit_ids)
	end
end

function CoreAreaTriggerUnitElement:_remove_unit_id(id)
	table.delete(self._hed.unit_ids, id)

	self._hed.unit_ids = #self._hed.unit_ids > 0 and self._hed.unit_ids or nil

	if alive(self._instigator_ctrlr) then
		self._instigator_ctrlr:set_enabled(not self._hed.unit_ids)
	end
end

function CoreAreaTriggerUnitElement:update_selected(t, dt, selected_unit, all_units)
	if not self._hed.use_shape_element_ids then
		local shape = self:get_shape()

		if shape then
			shape:draw(t, dt, 1, 1, 1)
		end
	else
		self:_check_removed_units(all_units)

		for _, id in ipairs(self._hed.use_shape_element_ids) do
			local unit = all_units[id]
			local shape = unit:mission_element():get_shape()

			shape:draw(t, dt, 0.85, 0.85, 0.85)
		end
	end
end

function CoreAreaTriggerUnitElement:get_shape()
	if not self._shape then
		self:_create_shapes()
	end

	return self._hed.shape_type == "box" and self._shape or self._hed.shape_type == "cylinder" and self._cylinder_shape
end

function CoreAreaTriggerUnitElement:set_shape_property(params)
	self._shape:set_property(params.property, self._hed[params.value])
	self._cylinder_shape:set_property(params.property, self._hed[params.value])
end

function CoreAreaTriggerUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

function CoreAreaTriggerUnitElement:_set_shape_type()
	local is_box = self._hed.shape_type == "box"
	local is_cylinder = self._hed.shape_type == "cylinder"
	local uses_external = self._hed.use_shape_element_ids
	is_box = not uses_external and is_box
	is_cylinder = not uses_external and is_cylinder

	self._depth_params.number_ctrlr:set_enabled(is_box)
	self._width_params.number_ctrlr:set_enabled(is_box)
	self._height_params.number_ctrlr:set_enabled(is_box or is_cylinder)
	self._radius_params.number_ctrlr:set_enabled(is_cylinder)
	self._shape_type_params.ctrlr:set_enabled(not uses_external)
	self._use_disabled_shapes:set_enabled(uses_external)
	self._sliders.depth:set_enabled(is_box)
	self._sliders.width:set_enabled(is_box)
	self._sliders.height:set_enabled(is_box or is_cylinder)
	self._sliders.radius:set_enabled(is_cylinder)
end

function CoreAreaTriggerUnitElement:_create_shapes()
	self._shape = CoreShapeManager.ShapeBoxMiddle:new({
		width = self._hed.width,
		depth = self._hed.depth,
		height = self._hed.height
	})

	self._shape:set_unit(self._unit)

	self._cylinder_shape = CoreShapeManager.ShapeCylinderMiddle:new({
		radius = self._hed.radius,
		height = self._hed.height
	})

	self._cylinder_shape:set_unit(self._unit)
end

function CoreAreaTriggerUnitElement:_recreate_shapes()
	self._shape = nil
	self._cylinder_shape = nil

	self:_create_shapes()
end

function CoreAreaTriggerUnitElement:set_element_data(params, ...)
	CoreAreaTriggerUnitElement.super.set_element_data(self, params, ...)

	if params.value == "instigator" and self._hed.instigator == "criminals" then
		EWS:message_box(Global.frame_panel, "Criminals is deprecated, you should probably use local_criminals. Ask Martin or Ilija why.", "Instigator Warning", "ICON_WARNING", Vector3(-1, -1, 0))
	end

	if params.value == "shape_type" then
		self:_set_shape_type()
	end
end

function CoreAreaTriggerUnitElement:create_values_ctrlrs(panel, panel_sizer, disable)
	self:_build_value_number(panel, panel_sizer, "interval", {
		floats = 2,
		min = 0.01
	}, "Set the check interval for the area, in seconds.")

	if not disable or not disable.trigger_type then
		self:_build_value_combobox(panel, panel_sizer, "trigger_on", {
			"on_enter",
			"on_exit",
			"both",
			"on_empty",
			"while_inside"
		})
	end

	if not disable or not disable.instigator then
		local instigator, _ = self:_build_value_combobox(panel, panel_sizer, "instigator", managers.mission:area_instigator_categories(), "Select an instigator type for the area")
		self._instigator_ctrlr = instigator

		self._instigator_ctrlr:set_enabled(not self._hed.unit_ids)
	end

	if not disable or not disable.amount then
		self:_build_value_combobox(panel, panel_sizer, "amount", {
			"1",
			"2",
			"3",
			"4",
			"all"
		}, "Select how many are required to trigger area")
	end

	if not disable or not disable.instigator_name then
		self:_build_value_combobox(panel, panel_sizer, "instigator_name", {
			"trip_mine",
			"ecm_jammer",
			"ammo_bag",
			"doctor_bag",
			"bodybags_bag"
		}, "Select which units will trigger the area (equipment only)")
	end

	self._use_disabled_shapes = self:_build_value_checkbox(panel, panel_sizer, "use_disabled_shapes")
end

function CoreAreaTriggerUnitElement:_build_panel(panel, panel_sizer, disable_params)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:create_values_ctrlrs(panel, panel_sizer, disable_params)

	local _, shape_type_params = self:_build_value_combobox(panel, panel_sizer, "shape_type", {
		"box",
		"cylinder"
	}, "Select shape for area")
	self._shape_type_params = shape_type_params

	if not self._shape then
		self:_create_shapes()
	end

	local width, width_params = self:_build_value_number(panel, panel_sizer, "width", {
		floats = 0,
		min = 0
	}, "Set the width for the shape")

	width_params.name_ctrlr:set_label("Width[cm]:")

	self._width_params = width_params

	width:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_shape_property"), {
		value = "width",
		property = "width"
	})
	width:connect("EVT_KILL_FOCUS", callback(self, self, "set_shape_property"), {
		value = "width",
		property = "width"
	})

	local depth, depth_params = self:_build_value_number(panel, panel_sizer, "depth", {
		floats = 0,
		min = 0
	}, "Set the depth for the shape")

	depth_params.name_ctrlr:set_label("Depth[cm]:")

	self._depth_params = depth_params

	depth:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_shape_property"), {
		value = "depth",
		property = "depth"
	})
	depth:connect("EVT_KILL_FOCUS", callback(self, self, "set_shape_property"), {
		value = "depth",
		property = "depth"
	})

	local height, height_params = self:_build_value_number(panel, panel_sizer, "height", {
		floats = 0,
		min = 0
	}, "Set the height for the shape")

	height_params.name_ctrlr:set_label("Height[cm]:")

	self._height_params = height_params

	height:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_shape_property"), {
		value = "height",
		property = "height"
	})
	height:connect("EVT_KILL_FOCUS", callback(self, self, "set_shape_property"), {
		value = "height",
		property = "height"
	})

	local radius, radius_params = self:_build_value_number(panel, panel_sizer, "radius", {
		floats = 0,
		min = 0
	}, "Set the radius for the shape")

	radius_params.name_ctrlr:set_label("Radius[cm]:")

	self._radius_params = radius_params

	radius:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_shape_property"), {
		value = "radius",
		property = "radius"
	})
	radius:connect("EVT_KILL_FOCUS", callback(self, self, "set_shape_property"), {
		value = "radius",
		property = "radius"
	})
	self:scale_slider(panel, panel_sizer, width_params, "width", "Width scale:")
	self:scale_slider(panel, panel_sizer, depth_params, "depth", "Depth scale:")
	self:scale_slider(panel, panel_sizer, height_params, "height", "Height scale:")
	self:scale_slider(panel, panel_sizer, radius_params, "radius", "Radius scale:")
	self:_set_shape_type()
end

function CoreAreaTriggerUnitElement:scale_slider(panel, sizer, number_ctrlr_params, value, name)
	local slider_sizer = EWS:BoxSizer("HORIZONTAL")

	slider_sizer:add(EWS:StaticText(panel, name, "", "ALIGN_LEFT"), 1, 0, "ALIGN_CENTER_VERTICAL")

	local slider = EWS:Slider(panel, 100, 1, 200, "", "")

	slider_sizer:add(slider, 2, 0, "EXPAND")
	slider:connect("EVT_SCROLL_CHANGED", callback(self, self, "set_size"), {
		ctrlr = slider,
		number_ctrlr_params = number_ctrlr_params,
		value = value
	})
	slider:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "set_size"), {
		ctrlr = slider,
		number_ctrlr_params = number_ctrlr_params,
		value = value
	})
	slider:connect("EVT_SCROLL_CHANGED", callback(self, self, "size_release"), {
		ctrlr = slider,
		number_ctrlr_params = number_ctrlr_params,
		value = value
	})
	slider:connect("EVT_SCROLL_THUMBRELEASE", callback(self, self, "size_release"), {
		ctrlr = slider,
		number_ctrlr_params = number_ctrlr_params,
		value = value
	})
	sizer:add(slider_sizer, 0, 0, "EXPAND")

	self._sliders = self._sliders or {}
	self._sliders[value] = slider
end

function CoreAreaTriggerUnitElement:set_size(params)
	local value = self._hed[params.value] * params.ctrlr:get_value() / 100

	self._shape:set_property(params.value, value)
	self._cylinder_shape:set_property(params.value, value)
	CoreEWS.change_entered_number(params.number_ctrlr_params, value)
end

function CoreAreaTriggerUnitElement:size_release(params)
	self._hed[params.value] = params.number_ctrlr_params.value

	params.ctrlr:set_value(100)
end

function CoreAreaTriggerUnitElement:clone_data(...)
	CoreAreaTriggerUnitElement.super.clone_data(self, ...)
	self:_recreate_shapes()
end

CoreAreaOperatorUnitElement = CoreAreaOperatorUnitElement or class(MissionElement)
CoreAreaOperatorUnitElement.SAVE_UNIT_POSITION = false
CoreAreaOperatorUnitElement.SAVE_UNIT_ROTATION = false
CoreAreaOperatorUnitElement.LINK_ELEMENTS = {
	"elements"
}
AreaOperatorUnitElement = AreaOperatorUnitElement or class(CoreAreaOperatorUnitElement)

function AreaOperatorUnitElement:init(...)
	AreaOperatorUnitElement.super.init(self, ...)
end

function CoreAreaOperatorUnitElement:init(unit)
	CoreAreaOperatorUnitElement.super.init(self, unit)

	self._hed.elements = {}
	self._hed.interval = 0.1
	self._hed.trigger_on = "on_enter"
	self._hed.instigator = managers.mission:default_area_instigator()
	self._hed.amount = "1"
	self._hed.use_disabled_shapes = false
	self._hed.operation = "none"

	table.insert(self._save_values, "elements")
	table.insert(self._save_values, "interval")
	table.insert(self._save_values, "use_disabled_shapes")
	table.insert(self._save_values, "operation")

	self._apply_on_checkboxes = {
		"interval",
		"use_disabled_shapes"
	}

	for _, uses in ipairs(self._apply_on_checkboxes) do
		self._hed["apply_on_" .. uses] = false

		table.insert(self._save_values, "apply_on_" .. uses)
	end
end

function CoreAreaOperatorUnitElement:draw_links(t, dt, selected_unit, all_units)
	CoreAreaOperatorUnitElement.super.draw_links(self, t, dt, selected_unit)

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

function CoreAreaOperatorUnitElement:update_editing()
end

function CoreAreaOperatorUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit and ray.unit:name():s() == "core/units/mission_elements/trigger_area/trigger_area" then
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.elements, id) then
			table.delete(self._hed.elements, id)
		else
			table.insert(self._hed.elements, id)
		end
	end
end

function CoreAreaOperatorUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

function CoreAreaOperatorUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local exact_names = {
		"core/units/mission_elements/trigger_area/trigger_area"
	}

	self:_build_add_remove_unit_from_list(panel, panel_sizer, self._hed.elements, nil, exact_names)
	CoreAreaTriggerUnitElement.create_values_ctrlrs(self, panel, panel_sizer, {
		amount = true,
		instigator = true,
		trigger_type = true
	})
	panel_sizer:add(EWS:StaticLine(panel, "", "LI_HORIZONTAL"), 0, 5, "EXPAND,TOP,BOTTOM")
	self:_build_value_combobox(panel, panel_sizer, "operation", {
		"none",
		"clear_inside"
	}, "Select an operation for the selected elements")

	for _, uses in ipairs(self._apply_on_checkboxes) do
		local name = "apply_on_" .. uses

		self:_build_value_checkbox(panel, panel_sizer, name)
	end

	self:_add_help_text("This element can modify trigger_area element. Select areas to modify using insert and clicking on the elements.")
end

CoreAreaReportTriggerUnitElement = CoreAreaReportTriggerUnitElement or class(CoreAreaTriggerUnitElement)
CoreAreaReportTriggerUnitElement.ON_EXECUTED_ALTERNATIVES = {
	"enter",
	"leave",
	"empty",
	"while_inside",
	"on_death",
	"rule_failed",
	"reached_amount"
}
AreaReportTriggerUnitElement = AreaReportTriggerUnitElement or class(CoreAreaReportTriggerUnitElement)

function AreaReportTriggerUnitElement:init(...)
	AreaReportTriggerUnitElement.super.init(self, ...)

	self._hed.trigger_on = nil
end

function AreaReportTriggerUnitElement:_build_panel(panel, panel_sizer)
	AreaReportTriggerUnitElement.super._build_panel(self, panel, panel_sizer, {
		trigger_type = true
	})
end
