CoreAreaHubElement = CoreAreaHubElement or class(HubElement)
AreaHubElement = AreaHubElement or class(CoreAreaHubElement)

function AreaHubElement:init(...)
	CoreAreaHubElement.init(self, ...)
end

function CoreAreaHubElement:init(unit)
	HubElement.init(self, unit)

	self._timeline_color = Vector3(1, 1, 0)
	self._shapes_types = {
		"box",
		"sphere",
		"plane"
	}
	self._shape_type = "box"
	self._grid_size = 1
	self._kb_move_grid_size = 25
	self._move_shape_rep = RepKey:new({
		"up",
		"down",
		"right",
		"left",
		"num 4",
		"num 6"
	})
	self._brush = Draw:brush()
	self._hed.area_interval = managers.area:default_interval()
	self._hed.area_type = "on_enter"
	self._hed.shapes = {}

	table.insert(self._save_values, "area_interval")
	table.insert(self._save_values, "area_type")
	table.insert(self._save_values, "shapes")
	table.insert(self._hed.action_types, "activate")
	table.insert(self._hed.action_types, "deactivate")
end

function CoreAreaHubElement:populate_shapes_list()
	self._shapes_list:clear()

	for name, shape in pairs(self._hed.shapes) do
		self._shapes_list:append(name)
	end
end

function CoreAreaHubElement:set_shape_type(types)
	self._shape_type = types:get_value()
end

function CoreAreaHubElement:selected_shape(shapes)
	local i = shapes:selected_index()

	if i > -1 then
		self._current_shape = shapes:get_string(i)

		self:set_shape_values()
	end
end

function CoreAreaHubElement:set_start_altitude()
	if self._current_shape then
		self._hed.shapes[self._current_shape].position = self._hed.shapes[self._current_shape].position:with_z(self._start_altitude:get_value())
	end

	self:set_shape_values()
end

function CoreAreaHubElement:set_altitude_text(data)
	if not self._current_shape then
		return
	end

	local value = tonumber(data.ctrl:get_value())

	if data.type == "start" then
		self._hed.shapes[self._current_shape].position = self._hed.shapes[self._current_shape].position:with_z(value)
	elseif data.type == "height" then
		self._hed.shapes[self._current_shape].height = value
	end

	self:set_shape_values()
end

function CoreAreaHubElement:set_altitude_spin(data)
	if not self._current_shape then
		return
	end

	if data.type == "start" then
		local z = self._hed.shapes[self._current_shape].position.z + data.step
		self._hed.shapes[self._current_shape].position = self._hed.shapes[self._current_shape].position:with_z(z)
	elseif data.type == "height" then
		self._hed.shapes[self._current_shape].height = self._hed.shapes[self._current_shape].height + data.step
	end

	self:set_shape_values()
end

function CoreAreaHubElement:set_height()
	if self._current_shape then
		self._hed.shapes[self._current_shape].height = self._height:get_value()
	end

	self:set_shape_values()
end

function CoreAreaHubElement:set_2d()
	if self._current_shape then
		self._hed.shapes[self._current_shape].position = self._hed.shapes[self._current_shape].position:with_z(0)
		self._hed.shapes[self._current_shape].height = 0
	end

	self:set_shape_values()
end

function CoreAreaHubElement:set_size()
	if self._current_shape then
		self._hed.shapes[self._current_shape].size_mul = math.pow(self._size:get_value() / 10, 2)
	end
end

function CoreAreaHubElement:size_release()
	local current_shape = self._hed.shapes[self._current_shape]

	if current_shape then
		if current_shape.type == "sphere" then
			current_shape.radious = current_shape.radious * current_shape.size_mul
		elseif current_shape.type == "box" then
			current_shape.width = current_shape.width * current_shape.size_mul
			current_shape.length = current_shape.length * current_shape.size_mul
		elseif current_shape.type == "plane" then
			current_shape.width = current_shape.width * current_shape.size_mul
		end

		current_shape.size_mul = 1

		self._size:set_value(10)
	end
end

function CoreAreaHubElement:set_shape_values()
	local current_shape = self._hed.shapes[self._current_shape]

	if current_shape then
		self._start_altitude:set_enabled(true)
		self._start_altitude:set_value(current_shape.position.z)
		self._start_altitude_text:set_enabled(true)
		self._start_altitude_text:change_value(current_shape.position.z)
		self._start_altitude_spin:set_enabled(true)
		self._height:set_enabled(true)
		self._height:set_value(current_shape.height)
		self._height_altitude_text:set_enabled(true)
		self._height_altitude_text:change_value(current_shape.height)
		self._height_altitude_spin:set_enabled(true)
		self._size:set_enabled(true)
		self._size:set_value(math.sqrt(current_shape.size_mul) * 10)
	else
		self._start_altitude:set_value(0)
		self._start_altitude:set_enabled(false)
		self._start_altitude_text:change_value(0)
		self._start_altitude_text:set_enabled(false)
		self._start_altitude_spin:set_enabled(false)
		self._height:set_value(0)
		self._height:set_enabled(false)
		self._height_altitude_text:change_value(0)
		self._height_altitude_text:set_enabled(false)
		self._height_altitude_spin:set_enabled(false)
		self._size:set_value(0)
		self._size:set_enabled(false)
	end
end

function CoreAreaHubElement:update_selected(time)
	for _, shape in pairs(self._hed.shapes) do
		self:draw(shape, 0, 0.5 + (1 + math.sin(time * 100)) * 0.5 * 0.5, 0)
	end

	if self._current_shape then
		self:draw(self._hed.shapes[self._current_shape], 0, 1, 1)
	end
end

function CoreAreaHubElement:draw(shape, r, g, b)
	local start_z = -20000
	local height = 40000
	local position = shape.position
	local rotation = shape.rotation

	if shape.height ~= 0 or position.z ~= 0 then
		height = shape.height
		start_z = 0
	end

	self._brush:set_color(Color(0.75, r, g, b))

	if shape.type == "sphere" then
		self._brush:cylinder(position + Vector3(0, 0, start_z), position + Vector3(0, 0, height + start_z), shape.radious * shape.size_mul)
		Application:draw_cylinder(position + Vector3(0, 0, start_z), position + Vector3(0, 0, height + start_z), shape.radious * shape.size_mul, r, g, b)
	elseif shape.type == "box" then
		local start = position + Vector3(0, 0, start_z)
		local center = (start + start + Vector3(shape.width * shape.size_mul, shape.length * shape.size_mul, height)) / 2

		self._brush:box(center, Vector3(shape.width * shape.size_mul / 2, 0, 0), Vector3(0, shape.length * shape.size_mul / 2, 0), Vector3(0, 0, height / 2))
		Application:draw_box(position + Vector3(0, 0, start_z), position + Vector3(shape.width * shape.size_mul, shape.length * shape.size_mul, height + start_z), r, g, b)
	elseif shape.type == "plane" then
		local start = position + Vector3(0, 0, start_z)
		local width = shape.width * shape.size_mul
		local pos1 = position + Vector3(0, 0, start_z)
		local pos2 = position + shape.rotation:x() * width + Vector3(0, 0, start_z)
		local pos3 = position + shape.rotation:x() * width + Vector3(0, 0, height + start_z)
		local pos4 = position + Vector3(0, 0, height + start_z)

		self._brush:quad(pos1, pos2, pos3, pos4)
		Application:draw_rotation(position, shape.rotation)
		Application:draw_line(pos1, pos2, r, g, b)
		Application:draw_line(pos2, pos3, r, g, b)
		Application:draw_line(pos3, pos4, r, g, b)
		Application:draw_line(pos4, pos1, r, g, b)

		local step = math.clamp(height / 20, 250, 10000)

		for i = start_z, height + start_z, step do
			local pos = position + Vector3(0, 0, i)

			Application:draw_line(pos, pos + shape.rotation:y() * 500, 0, 1, 0)
			Application:draw_line(pos + shape.rotation:x() * width, pos + shape.rotation:x() * width + shape.rotation:y() * 500, 0, 1, 0)
			Application:draw_line(pos + shape.rotation:x() * width / 2, pos + shape.rotation:x() * width / 2 + shape.rotation:y() * 500, 0, 1, 0)
			Application:draw_line(pos, pos + shape.rotation:y() * -500, 1, 0, 0)
			Application:draw_line(pos + shape.rotation:x() * width, pos + shape.rotation:x() * width + shape.rotation:y() * -500, 1, 0, 0)
			Application:draw_line(pos + shape.rotation:x() * width / 2, pos + shape.rotation:x() * width / 2 + shape.rotation:y() * -500, 1, 0, 0)
		end
	end
end

function CoreAreaHubElement:update_editing(t, dt)
	local p1 = managers.editor:get_cursor_look_point(0)
	local p2 = managers.editor:get_cursor_look_point(100)
	local current_shape = self._hed.shapes[self._current_shape]
	local t = p1.z / (p1.z - p2.z)
	self._current_pos = p1 + (p2 - p1) * t

	if self._grid_size > 0 then
		self._current_pos = self:round_position(self._current_pos)
	end

	if self._creating and self._current_shape then
		self._hed.shapes[self._current_shape] = self:set_shape_properties(self._shape_type, self._start_pos, self._current_pos)
	end

	if self._grab_shape then
		if self._move_all_shapes then
			for name, shape in pairs(self._hed.shapes) do
				shape.position = self._current_pos + shape.move_offset
			end
		elseif current_shape then
			current_shape.position = self._current_pos + current_shape.move_offset
		end
	end

	local kb = Input:keyboard()
	local mov_vec = nil

	if self._move_shape_rep:update(t, dt) then
		if kb:down("up") then
			mov_vec = Vector3(0, 1, 0)
		elseif kb:down("down") then
			mov_vec = Vector3(0, 1, 0) * -1
		elseif kb:down("right") then
			mov_vec = Vector3(1, 0, 0)
		elseif kb:down("left") then
			mov_vec = Vector3(1, 0, 0) * -1
		end

		if mov_vec then
			if shift() then
				for name, shape in pairs(self._hed.shapes) do
					shape.position = shape.position + mov_vec * self._kb_move_grid_size
				end
			elseif current_shape then
				current_shape.position = current_shape.position + mov_vec * self._kb_move_grid_size
			end
		end
	end

	if current_shape then
		local rot_axis = nil

		if kb:down("num 4") then
			rot_axis = Vector3(0, 0, 1)
		elseif kb:down("num 6") then
			rot_axis = Vector3(0, 0, -1)
		end

		if rot_axis then
			current_shape.rotation = Rotation(rot_axis, 100 * dt) * current_shape.rotation
		end
	end

	Application:draw_rotation(self._current_pos, self._unit:rotation())
end

function CoreAreaHubElement:load_data(data)
	if not data then
		return
	end

	self._hed.area_type = data._area_type or self._hed.area_type

	for _, shape in ipairs(data._shapes) do
		self._current_shape = self:new_shape_name()
		local properties = nil
		local s_pos = shape._generic._position

		if shape._type == "sphere" then
			local e_pos = shape._generic._position + Vector3(shape._radious, 0, shape._height)
			properties = self:set_shape_properties(shape._type, s_pos, e_pos)
		elseif shape._type == "box" then
			local e_pos = shape._generic._position + Vector3(shape._width, shape._length, shape._height)
			properties = self:set_shape_properties(shape._type, s_pos, e_pos)
		elseif shape._type == "plane" then
			local e_pos = shape._generic._position + shape._generic._rotation:x() * shape._width
			properties = self:set_shape_properties(shape._type, s_pos, e_pos)
			properties.height = shape._height
		end

		self._hed.shapes[self._current_shape] = properties
	end
end

function CoreAreaHubElement:round_position(p)
	return Vector3(math.round(p.x / self._grid_size) * self._grid_size, math.round(p.y / self._grid_size) * self._grid_size, 0)
end

function CoreAreaHubElement:create_shape()
	local p1 = managers.editor:get_cursor_look_point(0)
	local p2 = managers.editor:get_cursor_look_point(100)
	local t = p1.z / (p1.z - p2.z)
	self._start_pos = p1 + (p2 - p1) * t

	if self._grid_size > 0 then
		self._start_pos = self:round_position(self._start_pos)
	end

	self._current_shape = self:new_shape_name()
	local properties = self:set_shape_properties(self._shape_type, self._start_pos, self._start_pos)
	self._hed.shapes[self._current_shape] = properties

	self._shapes_list:append(self._current_shape)

	self._creating = true

	self:set_shape_values()
end

function CoreAreaHubElement:new_shape_name()
	for i = 1, 100 do
		local name = "shape" .. i

		if not self._hed.shapes[name] then
			return name
		end
	end
end

function CoreAreaHubElement:set_shape_properties(type, pos, end_pos)
	local t = {
		type = type,
		position = pos,
		rotation = Rotation(),
		size_mul = 1
	}
	t.height = end_pos.z - t.position.z

	if type == "sphere" then
		t.radious = (Vector3(t.position.x, t.position.y, 0) - Vector3(end_pos.x, end_pos.y, 0)):length()
	elseif type == "box" then
		t.length = end_pos.y - t.position.y
		t.width = end_pos.x - t.position.x
	elseif type == "plane" then
		local x = (end_pos - t.position):normalized()
		local z = Vector3(0, 0, 1)
		local y = z:cross(x)
		t.rotation = Rotation(x, y, z)
		t.width = (end_pos - t.position):length()
	end

	return t
end

function CoreAreaHubElement:delete()
	if self._current_shape then
		self._hed.shapes[self._current_shape] = nil
		self._current_shape = nil
	end

	self:populate_shapes_list()
	self:set_shape_values()
end

function CoreAreaHubElement:create_shape_release()
	self._creating = false
end

function CoreAreaHubElement:move_shape()
	self._grab_shape = true

	for name, shape in pairs(self._hed.shapes) do
		shape.move_offset = shape.position - self._current_pos
	end

	self._move_all_shapes = shift()
end

function CoreAreaHubElement:release_shape()
	self._grab_shape = false
	self._move_all_shapes = false

	for name, shape in pairs(self._hed.shapes) do
		shape.move_offset = nil
	end
end

function CoreAreaHubElement:add_triggers(vc)
	vc:add_trigger("lmb", callback(self, self, "create_shape"))
	vc:add_release_trigger("lmb", callback(self, self, "create_shape_release"))
	vc:add_trigger("emb", callback(self, self, "move_shape"))
	vc:add_release_trigger("emb", callback(self, self, "release_shape"))
	vc:add_trigger("destroy", callback(self, self, "delete"))
end

function CoreAreaHubElement:save_mission_trigger(file, tab)
	file:puts(tab .. "<trigger type=\"UnitInArea\" name=\"area" .. self._unit:unit_data().unit_id .. "\"/>")
end

function CoreAreaHubElement:set_interval(data)
	local value = tonumber(data.ctrlr:get_value())
	value = math.clamp(value, 0, 1000000)
	self._hed.area_interval = value

	data.ctrlr:change_value(string.format("%.2f", self._hed.area_interval))
end

function CoreAreaHubElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local interval_sizer = EWS:BoxSizer("HORIZONTAL")

	interval_sizer:add(EWS:StaticText(panel, "Check Interval:", 0, ""), 2, 0, "ALIGN_CENTER_VERTICAL")

	local interval_ctrlr = EWS:TextCtrl(self._panel, string.format("%.2f", self._hed.area_interval), "", "TE_PROCESS_ENTER")

	interval_ctrlr:set_tool_tip("Set the check interval in seconds (set to 0 for every frame).")
	interval_ctrlr:connect("EVT_CHAR", callback(nil, _G, "verify_number"), interval_ctrlr)
	interval_ctrlr:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_interval"), {
		ctrlr = interval_ctrlr
	})
	interval_ctrlr:connect("EVT_KILL_FOCUS", callback(self, self, "set_interval"), {
		ctrlr = interval_ctrlr
	})
	interval_sizer:add(interval_ctrlr, 3, 0, "EXPAND")
	panel_sizer:add(interval_sizer, 0, 0, "EXPAND")

	local types_sizer = EWS:BoxSizer("HORIZONTAL")

	types_sizer:add(EWS:StaticText(panel, "Types:", 0, ""), 2, 0, "ALIGN_CENTER_VERTICAL")

	local area_type = EWS:ComboBox(panel, "", "", "CB_DROPDOWN,CB_READONLY")

	for _, type in ipairs({
		"on_enter",
		"on_exit",
		"toggle"
	}) do
		area_type:append(type)
	end

	area_type:set_value(self._hed.area_type)
	types_sizer:add(area_type, 3, 0, "EXPAND")
	area_type:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "set_element_data"), {
		value = "area_type",
		ctrlr = area_type
	})
	panel_sizer:add(types_sizer, 0, 0, "EXPAND")

	local shape_names_sizer = EWS:BoxSizer("HORIZONTAL")

	shape_names_sizer:add(EWS:StaticText(panel, "Shape Types:", 0, ""), 2, 0, "ALIGN_CENTER_VERTICAL")

	local shape_names = EWS:ComboBox(panel, "", "", "CB_DROPDOWN,CB_READONLY")

	for _, type in ipairs(self._shapes_types) do
		shape_names:append(type)
	end

	shape_names:set_value(self._shape_type)
	shape_names_sizer:add(shape_names, 3, 0, "EXPAND")
	shape_names:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "set_shape_type"), shape_names)
	panel_sizer:add(shape_names_sizer, 0, 0, "EXPAND")

	local shapes_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "Shapes")
	self._shapes_list = EWS:ListBox(panel, "", "LB_SINGLE,LB_HSCROLL,LB_NEEDED_SB,LB_SORT")

	shapes_sizer:add(self._shapes_list, 0, 0, "EXPAND")
	self._shapes_list:connect("EVT_COMMAND_LISTBOX_SELECTED", callback(self, self, "selected_shape"), self._shapes_list)
	self:populate_shapes_list()

	local delete_shape = EWS:Button(panel, "Delete Shape", "", "BU_EXACTFIT,NO_BORDER")

	shapes_sizer:add(delete_shape, 0, 0, "ALIGN_RIGHT")
	delete_shape:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "delete"), nil)
	panel_sizer:add(shapes_sizer, 0, 0, "EXPAND")

	local altitude_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "Altitude")
	self._start_altitude = EWS:Slider(panel, 0, -20000, 20000, "", "")
	self._height = EWS:Slider(panel, 0, 0, 30000, "", "")
	self._start_altitude_text, self._start_altitude_spin = self:_altitude_ctrlr(panel, "Start Altitude:", 0, "start", altitude_sizer)

	altitude_sizer:add(self._start_altitude, 1, 10, "EXPAND")

	self._height_altitude_text, self._height_altitude_spin = self:_altitude_ctrlr(panel, "Height:", 0, "height", altitude_sizer)

	altitude_sizer:add(self._height, 1, 0, "EXPAND")
	self._start_altitude:connect("EVT_SCROLL_CHANGED", callback(self, self, "set_start_altitude"), nil)
	self._start_altitude:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "set_start_altitude"), nil)
	self._height:connect("EVT_SCROLL_CHANGED", callback(self, self, "set_height"), nil)
	self._height:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "set_height"), nil)

	local set_2d = EWS:Button(panel, "Set to 2D", "_set_2d", "BU_EXACTFIT,NO_BORDER")

	altitude_sizer:add(set_2d, 1, 0, "EXPAND")
	set_2d:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "set_2d"), nil)
	panel_sizer:add(altitude_sizer, 1, 0, "EXPAND")

	local size_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "Size")
	self._size = EWS:Slider(panel, 10, 1, 40, "", "")

	size_sizer:add(self._size, 1, 0, "EXPAND")
	self._size:connect("EVT_SCROLL_CHANGED", callback(self, self, "set_size"), nil)
	self._size:connect("EVT_SCROLL_CHANGED", callback(self, self, "size_release"), nil)
	self._size:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "set_size"), nil)
	self._size:connect("EVT_SCROLL_THUMBRELEASE", callback(self, self, "size_release"), nil)
	panel_sizer:add(size_sizer, 0, 0, "EXPAND")
	self:set_shape_values()
end

function CoreAreaHubElement:_altitude_ctrlr(panel, name, value, type, sizer)
	local ctrl_sizer = EWS:BoxSizer("HORIZONTAL")

	ctrl_sizer:add(EWS:StaticText(panel, name, "", "ALIGN_LEFT"), 1, 0, "ALIGN_CENTER_VERTICAL")

	local ctrl = EWS:TextCtrl(self._panel, value, "", "TE_PROCESS_ENTER")

	ctrl:connect("EVT_CHAR", callback(nil, _G, "verify_number"), ctrl)
	ctrl:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_altitude_text"), {
		ctrl = ctrl,
		type = type
	})
	ctrl:connect("EVT_KILL_FOCUS", callback(self, self, "set_altitude_text"), {
		ctrl = ctrl,
		type = type
	})
	ctrl_sizer:add(ctrl, 1, 0, "EXPAND")

	local spin = EWS:SpinButton(self._panel, "", "SP_VERTICAL")

	spin:set_min_size(Vector3(-1, 10, 0))
	spin:connect("EVT_SCROLL_LINEUP", callback(self, self, "set_altitude_spin"), {
		step = 1,
		ctrl = ctrl,
		type = type
	})
	spin:connect("EVT_SCROLL_LINEDOWN", callback(self, self, "set_altitude_spin"), {
		step = -1,
		ctrl = ctrl,
		type = type
	})
	ctrl_sizer:add(spin, 0, 0, "EXPAND")
	sizer:add(ctrl_sizer, 1, 10, "EXPAND,LEFT,RIGHT")

	return ctrl, spin
end

function CoreAreaHubElement:destroy()
end
