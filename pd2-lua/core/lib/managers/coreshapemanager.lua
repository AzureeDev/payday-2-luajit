core:module("CoreShapeManager")
core:import("CoreXml")
core:import("CoreMath")

ShapeManager = ShapeManager or class()

function ShapeManager:init()
	self._shapes = {}
	self._shape_types = {
		box = ShapeBox,
		sphere = ShapeSphere,
		cylinder = ShapeCylinder,
		box_middle = ShapeBoxMiddle
	}
end

function ShapeManager:update(t, dt)
	for _, shape in ipairs(self._shapes) do
		shape:draw(t, dt, 0.8, 0.8)
	end
end

function ShapeManager:add_shape(type, params)
	params.type = type
	local shape = self._shape_types[type]:new(params)

	table.insert(self._shapes, shape)

	return shape
end

function ShapeManager:shape_type(type)
	return self._shape_types[type]
end

function ShapeManager:remove_shape(shape)
	shape:destroy()
	table.delete(self._shapes, shape)
end

function ShapeManager:clear_shapes()
	for _, shape in ipairs(clone(self._shapes)) do
		self:remove_shape(shape)
	end
end

function ShapeManager:save()
end

function ShapeManager:parse(shape)
	local t = {
		type = shape:parameter("type"),
		position = math.string_to_vector(shape:parameter("position")),
		rotation = math.string_to_rotation(shape:parameter("rotation"))
	}

	for properties in shape:children() do
		for value in properties:children() do
			t[value:parameter("name")] = CoreMath.string_to_value(value:parameter("type"), value:parameter("value"))
		end
	end

	return t
end

local mvec1 = Vector3()
local mvec2 = Vector3()
local mvec3 = Vector3()
local mposition = Vector3()
Shape = Shape or class()

function Shape:init(params)
	self._name = params.name or ""
	self._type = params.type or "none"
	self._position = params.position or Vector3()
	self._rotation = params.rotation or Rotation()
	self._properties = {}

	if Application:editor() then
		self._properties_ctrls = {}
		self._min_value = 10
		self._max_value = 10000000
	end
end

function Shape:build_dialog()
	if not Application:editor() then
		return
	end

	self._dialog = EWS:Dialog(nil, "Shape properties", "", Vector3(200, 100, 0), Vector3(750, 600, 0), "DEFAULT_DIALOG_STYLE,RESIZE_BORDER,STAY_ON_TOP")
	self._dialog_sizer = EWS:BoxSizer("VERTICAL")

	self._dialog:set_sizer(self._dialog_sizer)
	self:build_properties_ctrls()
end

function Shape:build_properties_ctrls()
end

function Shape:name()
	return self._unit and self._unit:unit_data().name_id or self._name
end

function Shape:unit()
	return self._unit
end

function Shape:set_unit(unit)
	self._unit = unit
end

function Shape:position()
	return self._unit and self._unit:position() or self._position
end

function Shape:set_position(position)
	self._position = position
end

function Shape:rotation()
	return self._unit and self._unit:rotation() or self._rotation
end

function Shape:set_rotation(rotation)
	self._rotation = rotation
end

function Shape:properties()
	return self._properties
end

function Shape:property(property)
	return self._properties[property]
end

function Shape:set_property(property, value)
	if not self._properties[property] then
		return
	end

	value = math.clamp(value, self._min_value, self._max_value)
	self._properties[property] = value

	if self._properties_ctrls and self._properties_ctrls[property] then
		for _, ctrl in ipairs(self._properties_ctrls[property]) do
			ctrl:set_value(string.format("%.2f", value / 100))
		end
	end
end

function Shape:set_property_string(property, value)
	self._properties[property] = value
end

function Shape:scale()
end

function Shape:set_dialog_visible(visible)
	if not self._dialog then
		self:build_dialog()
	end

	self._dialog:set_visible(visible)
end

function Shape:panel(panel, sizer)
	if not self._panel and panel and sizer then
		self:create_panel(panel, sizer)
	end

	return self._panel
end

function Shape:create_panel(parent, sizer)
	self._panel = EWS:Panel(parent, "", "TAB_TRAVERSAL")

	self._panel:set_extension({
		alive = true
	})

	self._panel_sizer = EWS:BoxSizer("VERTICAL")

	self._panel:set_sizer(self._panel_sizer)
	sizer:add(self._panel, 0, 0, "EXPAND")
end

function Shape:_create_size_ctrl(name, property, value, parent, sizer)
	local ctrl_sizer = EWS:BoxSizer("HORIZONTAL")

	ctrl_sizer:add(EWS:StaticText(parent, name, "", "ALIGN_LEFT"), 2, 0, "EXPAND")

	local ctrl = EWS:TextCtrl(parent, string.format("%.2f", value / 100), "", "TE_PROCESS_ENTER")

	ctrl:set_min_size(Vector3(-1, 10, 0))

	local spin = EWS:SpinButton(parent, "", "SP_VERTICAL")

	spin:set_min_size(Vector3(-1, 10, 0))

	local slider = EWS:Slider(parent, 100, 1, 200, "", "")

	ctrl:connect("EVT_CHAR", callback(nil, _G, "verify_number"), ctrl)
	ctrl:set_tool_tip("Type in property " .. name)
	ctrl:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "update_size"), {
		ctrl = ctrl,
		property = property
	})
	ctrl:connect("EVT_KILL_FOCUS", callback(self, self, "update_size"), {
		ctrl = ctrl,
		property = property
	})
	spin:connect("EVT_SCROLL_LINEUP", callback(self, self, "update_size_spin"), {
		step = 0.1,
		ctrl = ctrl,
		property = property
	})
	spin:connect("EVT_SCROLL_LINEDOWN", callback(self, self, "update_size_spin"), {
		step = -0.1,
		ctrl = ctrl,
		property = property
	})

	local params = {
		ctrl = ctrl,
		slider = slider,
		property = property
	}

	slider:connect("EVT_SCROLL_CHANGED", callback(self, self, "update_slider_size"), params)
	slider:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "update_slider_size"), params)
	slider:connect("EVT_SCROLL_CHANGED", callback(self, self, "update_slider_release"), params)
	slider:connect("EVT_SCROLL_THUMBRELEASE", callback(self, self, "update_slider_release"), params)
	ctrl_sizer:add(ctrl, 2, 0, "EXPAND")
	ctrl_sizer:add(spin, 0, 0, "EXPAND")
	ctrl_sizer:add(slider, 2, 0, "EXPAND")

	self._properties_ctrls[property] = self._properties_ctrls[property] or {}

	table.insert(self._properties_ctrls[property], ctrl)
	sizer:add(ctrl_sizer, 1, 0, "EXPAND")

	return ctrl
end

function Shape:connect_event(name, event, callback, params)
	local ctrls = self._properties_ctrls[name] or {}

	for _, ctrl in ipairs(ctrls) do
		ctrl:connect(event, callback, params)
	end
end

function Shape:update_size(data)
	local value = data.ctrl:get_value()

	self:set_property(data.property, value * 100)
	data.ctrl:set_selection(-1, -1)
end

function Shape:update_size_spin(data)
	local value = data.ctrl:get_value() + data.step

	self:set_property(data.property, value * 100)
end

function Shape:update_slider_size(data)
	data.start_value = data.start_value or data.ctrl:get_value()
	local value = data.start_value

	self:set_property(data.property, value * data.slider:get_value() / 100 * 100)
end

function Shape:update_slider_release(data)
	local value = data.start_value

	self:set_property(data.property, value * data.slider:get_value() / 100 * 100)

	data.start_value = nil

	data.slider:set_value(100)
end

function Shape:draw(t, dt, r, g, b)
end

function Shape:is_inside(pos)
end

function Shape:is_outside(pos)
end

function Shape:save(t)
	local t = t or ""
	local s = t
	local pos = CoreMath.vector_to_string(self:position(), "%.4f")
	local rot = CoreMath.rotation_to_string(self:rotation(), "%.4f")
	s = s .. "<shape type=\"" .. self._type .. "\" position=\"" .. pos .. "\" rotation=\"" .. rot .. "\">\n"
	s = s .. CoreXml.save_value_string(self, "_properties", t .. "\t") .. "\n"
	s = s .. t .. "</shape>"

	return s
end

function Shape:save_level_data()
	local t = {
		type = self._type,
		position = self:position(),
		rotation = self:rotation()
	}

	for name, value in pairs(self._properties) do
		t[name] = value
	end

	return t
end

function Shape:destroy()
	if self._panel then
		self._panel:extension().alive = false

		self._panel:destroy()
	end

	if self._dialog then
		self._dialog:destroy()
	end
end

ShapeBox = ShapeBox or class(Shape)

function ShapeBox:init(params)
	Shape.init(self, params)

	self._properties.width = params.width or 1000
	self._properties.depth = params.depth or 1000
	self._properties.height = params.height or 1000
end

function ShapeBox:create_panel(parent, sizer)
	Shape.create_panel(self, parent, sizer)

	local width = self:_create_size_ctrl("Width [m]", "width", self._properties.width, self._panel, self._panel_sizer)
	local depth = self:_create_size_ctrl("Depth [m]", "depth", self._properties.depth, self._panel, self._panel_sizer)
	local height = self:_create_size_ctrl("Height [m]", "height", self._properties.height, self._panel, self._panel_sizer)

	self._panel:set_min_size(Vector3(-1, 70, 0))

	return width, depth, height
end

function ShapeBox:build_properties_ctrls()
	if not Application:editor() then
		return
	end

	self:_create_size_ctrl("Width [m]", "width", self._properties.width, self._dialog, self._dialog_sizer)
	self:_create_size_ctrl("Depth [m]", "depth", self._properties.depth, self._dialog, self._dialog_sizer)
	self:_create_size_ctrl("Height [m]", "height", self._properties.height, self._dialog, self._dialog_sizer)
	self._dialog:set_size(Vector3(190, 90, 0))
end

function ShapeBox:size()
	return Vector3(self._properties.width, self._properties.depth, self._properties.height)
end

function ShapeBox:width()
	return self._properties.width
end

function ShapeBox:set_width(width)
	self:set_property("width", width)
end

function ShapeBox:depth()
	return self._properties.depth
end

function ShapeBox:set_depth(depth)
	self:set_property("depth", depth)
end

function ShapeBox:height()
	return self._properties.height
end

function ShapeBox:set_height(height)
	self:set_property("height", height)
end

function ShapeBox:still_inside(pos)
	return self:is_inside(pos)
end

function ShapeBox:is_inside(pos)
	mvector3.set(mvec1, pos)
	mvector3.subtract(mvec1, self:position())

	local rot = self:rotation()

	mrotation.x(rot, mvec2)

	local inside = mvector3.dot(mvec2, mvec1)

	if inside > 0 and inside < self._properties.width then
		mrotation.y(rot, mvec2)

		inside = mvector3.dot(mvec2, mvec1)

		if inside > 0 and inside < self._properties.depth then
			mrotation.z(rot, mvec2)

			inside = mvector3.dot(mvec2, mvec1)

			if inside > 0 and inside < self._properties.height then
				return true
			end
		end
	end

	return false
end

function ShapeBox:draw(t, dt, r, g, b)
	local brush = Draw:brush()

	brush:set_color(Color(0.5, r, g, b))

	local pos = self:position()
	local rot = self:rotation()
	pos = pos + rot:x() * self._properties.width / 2 + rot:y() * self._properties.depth / 2 + rot:z() * self._properties.height / 2

	brush:box(pos, rot:x() * self._properties.width / 2, rot:y() * self._properties.depth / 2, rot:z() * self._properties.height / 2)
	self:draw_outline(t, dt, r, g, b)
end

function ShapeBox:draw_outline(t, dt, r, g, b)
	local rot = self:rotation()

	Application:draw_box_rotation(self:position(), rot, self._properties.width, self._properties.depth, self._properties.height, r, g, b)
end

ShapeBoxMiddle = ShapeBoxMiddle or class(ShapeBox)

function ShapeBoxMiddle:init(params)
	ShapeBox.init(self, params)
end

function ShapeBoxMiddle:is_inside(pos)
	local rot = self:rotation()
	local x = mvec1
	local y = mvec2
	local z = mvec3

	mrotation.x(rot, x)
	mvector3.multiply(x, self._properties.width / 2)
	mrotation.y(rot, y)
	mvector3.multiply(y, self._properties.depth / 2)
	mrotation.z(rot, z)
	mvector3.multiply(z, self._properties.height / 2)

	local position = mposition

	mvector3.set(position, self:position())
	mvector3.subtract(position, x)
	mvector3.subtract(position, y)
	mvector3.subtract(position, z)

	local pos_dir = position

	mvector3.multiply(pos_dir, -1)
	mvector3.add(pos_dir, pos)
	mrotation.x(rot, x)

	local inside = mvector3.dot(x, pos_dir)

	if inside > 0 and inside < self._properties.width then
		mrotation.y(rot, y)

		inside = mvector3.dot(y, pos_dir)

		if inside > 0 and inside < self._properties.depth then
			mrotation.z(rot, z)

			inside = mvector3.dot(z, pos_dir)

			if inside > 0 and inside < self._properties.height then
				return true
			end
		end
	end

	return false
end

function ShapeBoxMiddle:draw(t, dt, r, g, b, a)
	local brush = Draw:brush()

	brush:set_color(Color(a or 0.5, r, g, b))

	local pos = self:position()
	local rot = self:rotation()

	brush:box(pos, rot:x() * self._properties.width / 2, rot:y() * self._properties.depth / 2, rot:z() * self._properties.height / 2)

	local c1 = self:position() - rot:x() * self._properties.width / 2 - rot:y() * self._properties.depth / 2 - rot:z() * self._properties.height / 2

	Application:draw_box_rotation(c1, rot, self._properties.width, self._properties.depth, self._properties.height, r, g, b)
end

ShapeBoxMiddleBottom = ShapeBoxMiddleBottom or class(ShapeBox)

function ShapeBoxMiddleBottom:init(params)
	ShapeBox.init(self, params)
end

function ShapeBoxMiddleBottom:is_inside(pos)
	local rot = self:rotation()
	local x = rot:x() * self._properties.width / 2
	local y = rot:y() * self._properties.depth / 2
	local position = self:position() - x - y
	local pos_dir = pos - position
	local inside = rot:x():dot(pos_dir)

	if inside > 0 and inside < self._properties.width then
		inside = rot:y():dot(pos_dir)

		if inside > 0 and inside < self._properties.depth then
			inside = rot:z():dot(pos_dir)

			if inside > 0 and inside < self._properties.height then
				return true
			end
		end
	end

	return false
end

function ShapeBoxMiddleBottom:draw(t, dt, r, g, b)
	local brush = Draw:brush()

	brush:set_color(Color(0.5, r, g, b))

	local pos = self:position()
	local rot = self:rotation()
	pos = pos + rot:z() * self._properties.height / 2

	brush:box(pos, rot:x() * self._properties.width / 2, rot:y() * self._properties.depth / 2, rot:z() * self._properties.height / 2)

	local c1 = self:position() - rot:x() * self._properties.width / 2 - rot:y() * self._properties.depth / 2

	Application:draw_box_rotation(c1, rot, self._properties.width, self._properties.depth, self._properties.height, r, g, b)
end

ShapeSphere = ShapeSphere or class(Shape)

function ShapeSphere:init(params)
	Shape.init(self, params)

	self._properties.radius = params.radius or 1000
end

function ShapeSphere:build_properties_ctrls()
	if not Application:editor() then
		return
	end

	self:_create_size_ctrl("Radius [m]", "radius", self._properties.radius, self._dialog_sizer)
	self._dialog:set_size(Vector3(190, 50, 0))
end

function ShapeSphere:radius()
	return self._properties.radius
end

function ShapeSphere:set_radius(radius)
	self:set_property("radius", radius)
end

function ShapeSphere:is_inside(pos)
	return (pos - self:position()):length() < self._properties.radius
end

function ShapeSphere:draw(t, dt, r, g, b)
	local brush = Draw:brush()

	brush:set_color(Color(0.5, r, g, b))
	brush:sphere(self:position(), self._properties.radius, 4)
	Application:draw_sphere(self:position(), self._properties.radius, r, g, b)
end

ShapeCylinder = ShapeCylinder or class(Shape)

function ShapeCylinder:init(params)
	Shape.init(self, params)

	self._properties.radius = params.radius or 1000
	self._properties.height = params.height or 1000
end

function ShapeCylinder:build_properties_ctrls()
	if not Application:editor() then
		return
	end

	self:_create_size_ctrl("Radius [m]", "radius", self._properties.radius, self._dialog, self._dialog_sizer)
	self:_create_size_ctrl("Height [m]", "height", self._properties.height, self._dialog, self._dialog_sizer)
	self._dialog:set_size(Vector3(190, 70, 0))
end

function ShapeCylinder:radius()
	return self._properties.radius
end

function ShapeCylinder:set_radius(radius)
	self:set_property("radius", radius)
end

function ShapeCylinder:height()
	return self._properties.height
end

function ShapeCylinder:set_height(height)
	self:set_property("height", height)
end

function ShapeCylinder:draw(t, dt, r, g, b)
	local brush = Draw:brush()

	brush:set_color(Color(0.5, r, g, b))

	local pos = self:position()
	local rot = self:rotation()

	brush:cylinder(pos, pos + rot:z() * self._properties.height, self._properties.radius, 100)
	Application:draw_cylinder(pos, pos + rot:z() * self._properties.height, self._properties.radius, r, g, b)
end

function ShapeCylinder:is_inside(pos)
	local pos_dir = pos - self:position()
	local rot = self:rotation()
	local inside = rot:z():dot(pos_dir)

	if inside > 0 and inside < self._properties.height then
		local pos_a = self:position()
		local pos_b = pos_a + rot:z() * self._properties.height

		if math.distance_to_segment(pos, pos_a, pos_b) <= self._properties.radius then
			return true
		end
	end

	return false
end

ShapeCylinderMiddle = ShapeCylinderMiddle or class(ShapeCylinder)

function ShapeCylinderMiddle:init(params)
	ShapeCylinderMiddle.super.init(self, params)
end

function ShapeCylinderMiddle:is_inside(pos)
	local rot = self:rotation()
	local z = mvec3

	mrotation.z(rot, z)
	mvector3.multiply(z, self._properties.height / 2)

	local position = mposition

	mvector3.set(position, self:position())
	mvector3.subtract(position, z)

	local pos_dir = mvec1

	mvector3.set(pos_dir, position)
	mvector3.multiply(pos_dir, -1)
	mvector3.add(pos_dir, pos)
	mrotation.z(rot, z)

	local inside = mvector3.dot(z, pos_dir)

	if inside > 0 and inside < self._properties.height then
		local to = mvec1

		mvector3.set(to, z)
		mvector3.multiply(to, self._properties.height)
		mvector3.add(to, position)

		if math.distance_to_segment(pos, position, to) <= self._properties.radius then
			return true
		end
	end

	return false
end

function ShapeCylinderMiddle:draw(t, dt, r, g, b)
	local brush = Draw:brush()

	brush:set_color(Color(0.5, r, g, b))

	local pos = self:position()
	local rot = self:rotation()
	local from = pos - rot:z() * self._properties.height / 2
	local to = pos + rot:z() * self._properties.height / 2

	brush:cylinder(from, to, self._properties.radius, 100)
	Application:draw_cylinder(from, to, self._properties.radius, r, g, b)
end
