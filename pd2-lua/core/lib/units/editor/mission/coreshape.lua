core:import("CoreShapeManager")

CoreShapeUnitElement = CoreShapeUnitElement or class(MissionElement)
ShapeUnitElement = ShapeUnitElement or class(CoreShapeUnitElement)

function ShapeUnitElement:init(...)
	CoreShapeUnitElement.init(self, ...)
end

function CoreShapeUnitElement:init(unit)
	MissionElement.init(self, unit)

	self._timeline_color = Vector3(1, 1, 0)
	self._brush = Draw:brush()
	self._hed.trigger_times = 0
	self._hed.shape_type = "box"
	self._hed.width = 500
	self._hed.depth = 500
	self._hed.height = 500
	self._hed.radius = 250

	table.insert(self._save_values, "shape_type")
	table.insert(self._save_values, "width")
	table.insert(self._save_values, "depth")
	table.insert(self._save_values, "height")
	table.insert(self._save_values, "radius")
end

function CoreShapeUnitElement:update_selected(t, dt, selected_unit, all_units)
	local shape = self:get_shape()

	if shape then
		shape:draw(t, dt, 1, 1, 1)
	end
end

function CoreShapeUnitElement:get_shape()
	if not self._shape then
		self:_create_shapes()
	end

	return self._hed.shape_type == "box" and self._shape or self._hed.shape_type == "cylinder" and self._cylinder_shape
end

function CoreShapeUnitElement:set_shape_property(params)
	self._shape:set_property(params.property, self._hed[params.value])
	self._cylinder_shape:set_property(params.property, self._hed[params.value])
end

function CoreShapeUnitElement:_set_shape_type()
	local is_box = self._hed.shape_type == "box"
	local is_cylinder = self._hed.shape_type == "cylinder"

	self._depth_params.number_ctrlr:set_enabled(is_box)
	self._width_params.number_ctrlr:set_enabled(is_box)
	self._height_params.number_ctrlr:set_enabled(is_box or is_cylinder)
	self._radius_params.number_ctrlr:set_enabled(is_cylinder)
	self._sliders.depth:set_enabled(is_box)
	self._sliders.width:set_enabled(is_box)
	self._sliders.height:set_enabled(is_box or is_cylinder)
	self._sliders.radius:set_enabled(is_cylinder)
end

function CoreShapeUnitElement:_create_shapes()
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

function CoreShapeUnitElement:set_element_data(params, ...)
	CoreShapeUnitElement.super.set_element_data(self, params, ...)

	if params.value == "shape_type" then
		self:_set_shape_type()
	end
end

function CoreShapeUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
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

function CoreShapeUnitElement:scale_slider(panel, sizer, number_ctrlr_params, value, name)
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

function CoreShapeUnitElement:set_size(params)
	local value = self._hed[params.value] * params.ctrlr:get_value() / 100

	self._shape:set_property(params.value, value)
	self._cylinder_shape:set_property(params.value, value)
	CoreEWS.change_entered_number(params.number_ctrlr_params, value)
end

function CoreShapeUnitElement:size_release(params)
	self._hed[params.value] = params.number_ctrlr_params.value

	params.ctrlr:set_value(100)
end
