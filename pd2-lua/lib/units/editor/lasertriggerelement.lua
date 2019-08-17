LaserTriggerUnitElement = LaserTriggerUnitElement or class(MissionElement)
LaserTriggerUnitElement.SAVE_UNIT_POSITION = false
LaserTriggerUnitElement.SAVE_UNIT_ROTATION = false
LaserTriggerUnitElement.ON_EXECUTED_ALTERNATIVES = {
	"enter",
	"leave",
	"empty",
	"while_inside"
}
LaserTriggerUnitElement.USES_INSTIGATOR_RULES = true
LaserTriggerUnitElement.CLOSE_DISTANCE = 25
LaserTriggerUnitElement.COLORS = {
	red = {
		1,
		0,
		0
	},
	green = {
		0,
		1,
		0
	},
	blue = {
		0,
		0,
		1
	}
}

function LaserTriggerUnitElement:init(unit)
	LaserTriggerUnitElement.super.init(self, unit)

	self._dummy_unit_name = Idstring("units/payday2/props/gen_prop_lazer_blaster_dome/gen_prop_lazer_blaster_dome")
	self._hed.trigger_times = 1
	self._hed.interval = 0.1
	self._hed.instigator = managers.mission:default_area_instigator()
	self._hed.color = "red"
	self._hed.visual_only = false
	self._hed.skip_dummies = false
	self._hed.cycle_interval = 0
	self._hed.cycle_random = false
	self._hed.cycle_active_amount = 1
	self._hed.cycle_type = "flow"
	self._hed.flicker_remove = nil
	self._hed.points = {}
	self._hed.connections = {}

	table.insert(self._save_values, "interval")
	table.insert(self._save_values, "instigator")
	table.insert(self._save_values, "color")
	table.insert(self._save_values, "visual_only")
	table.insert(self._save_values, "skip_dummies")
	table.insert(self._save_values, "cycle_interval")
	table.insert(self._save_values, "cycle_random")
	table.insert(self._save_values, "cycle_active_amount")
	table.insert(self._save_values, "cycle_type")
	table.insert(self._save_values, "flicker_remove")
	table.insert(self._save_values, "points")
	table.insert(self._save_values, "connections")
end

function LaserTriggerUnitElement:update_editing(...)
	local ray = self:_raycast()

	if self._moving_point and ray then
		local moving_point = self._hed.points[self._moving_point]
		moving_point.pos = ray.position
		moving_point.rot = Rotation(ray.normal, math.UP)
	end
end

function LaserTriggerUnitElement:begin_editing(...)
	self._dummy_unit = World:spawn_unit(self._dummy_unit_name, Vector3(), Rotation())
end

function LaserTriggerUnitElement:end_editing(...)
	LaserTriggerUnitElement.super.end_editing(self, ...)
	World:delete_unit(self._dummy_unit)
	self:_break_creating_connection()
	self:_break_moving_point()
end

function LaserTriggerUnitElement:update_selected(t, dt, selected_unit, all_units)
	LaserTriggerUnitElement.super.update_selected(self, t, dt, selected_unit, all_units)
	self:_draw_selected()
end

function LaserTriggerUnitElement:_draw_selected()
	for _, point in pairs(self._hed.points) do
		self:_draw_point(point.pos, point.rot, 0, 0.5, 0)
	end

	for i, connection in ipairs(self._hed.connections) do
		local s_p = self._hed.points[connection.from]
		local e_p = self._hed.points[connection.to]
		local r, g, b = unpack(self.COLORS[self._hed.color])

		if self._selected_connection and self._selected_connection == i then
			Application:draw_line(s_p.pos, e_p.pos, 1, 1, 1)
		else
			Application:draw_line(s_p.pos, e_p.pos, r, g, b)
		end
	end
end

function LaserTriggerUnitElement:_raycast()
	local from = managers.editor:get_cursor_look_point(0)
	local to = managers.editor:get_cursor_look_point(100000)
	local ray = World:raycast(from, to, nil, managers.slot:get_mask("all"))

	if ray and ray.position then
		local index, point = self:_get_close_point(self._hed.points, ray.position)
		local r, g, b = unpack(self.COLORS[self._hed.color])

		if point then
			if self._creating_connection then
				local creating_point = self._hed.points[self._creating_connection]

				Application:draw_line(creating_point.pos, point.pos, r * 0.6, g * 0.6, b * 0.6)
				self:_draw_point(point.pos, point.rot, 0, 1, 0)
			else
				self:_draw_point(point.pos, point.rot, 1, 0, 0)
			end
		else
			if self._creating_connection then
				local creating_point = self._hed.points[self._creating_connection]

				Application:draw_line(creating_point.pos, ray.position, r * 0.6, g * 0.6, b * 0.6)
			end

			self:_draw_point(ray.position, Rotation(ray.normal, math.UP))
		end

		self._dummy_unit:set_position(ray.position)
		self._dummy_unit:set_rotation(Rotation(ray.normal, math.UP))

		return ray
	end

	return nil
end

function LaserTriggerUnitElement:_get_close_point(points, pos)
	for i, point in pairs(points) do
		if (point.pos - pos):length() < self.CLOSE_DISTANCE then
			return i, point
		end
	end

	return nil, nil
end

function LaserTriggerUnitElement:_draw_point(pos, rot, r, g, b)
	r = r or 1
	g = g or 1
	b = b or 1
	local len = 25
	local scale = 0.05

	Application:draw_sphere(pos, 5, r, g, b)
	Application:draw_arrow(pos, pos + rot:x() * len, 1, 0, 0, scale)
	Application:draw_arrow(pos, pos + rot:y() * len, 0, 1, 0, scale)
	Application:draw_arrow(pos, pos + rot:z() * len, 0, 0, 1, scale)
end

function LaserTriggerUnitElement:_remove_any_close_point(pos)
	local index, point = self:_get_close_point(self._hed.points, pos)

	if index then
		self:_check_remove_index(index)

		self._hed.points[index] = nil

		return true
	end

	return false
end

function LaserTriggerUnitElement:_break_creating_connection()
	if alive(self._dummy_unit) then
		self._dummy_unit:set_enabled(true)
	end

	self._creating_connection = nil
end

function LaserTriggerUnitElement:_break_moving_point()
	self._moving_point = nil
	self._moving_point_undo = nil
end

function LaserTriggerUnitElement:_rmb()
	if self._moving_point then
		self._hed.points[self._moving_point] = self._moving_point_undo

		self:_break_moving_point()

		return
	end

	if self._creating_connection then
		self:_break_creating_connection()

		return
	end

	print("LaserTriggerUnitElement:_rmb()")

	local ray = self:_raycast()

	if not ray then
		return
	end

	local pos = ray.position
	local rot = Rotation(ray.normal, math.UP)

	if self:_remove_any_close_point(pos) then
		return
	end

	table.insert(self._hed.points, {
		pos = pos,
		rot = rot
	})
end

function LaserTriggerUnitElement:_lmb()
	print("LaserTriggerUnitElement:_lmb()")

	if self._moving_point then
		return
	end

	local ray = self:_raycast()

	if not ray then
		return
	end

	local pos = ray.position
	local rot = Rotation(ray.normal, math.UP)
	local index, point = self:_get_close_point(self._hed.points, pos)

	print("index", index)

	if not point then
		print("break starting connection")
		self:_break_creating_connection()

		return
	end

	if self._creating_connection then
		if self._creating_connection == index then
			print("break (same) starting connection")
		else
			print("finish starting connection")

			if not self:_check_remove_connection(self._creating_connection, index) then
				table.insert(self._hed.connections, {
					from = self._creating_connection,
					to = index
				})
				self:_fill_connections_box()
			end
		end

		self:_break_creating_connection()
	else
		print("start creating connection")
		self._dummy_unit:set_enabled(false)

		self._creating_connection = index
	end
end

function LaserTriggerUnitElement:_emb()
	if self._creating_connection then
		return
	end

	print("LaserTriggerUnitElement:_emb()")

	local ray = self:_raycast()

	if not ray then
		return
	end

	local pos = ray.position
	local rot = Rotation(ray.normal, math.UP)
	local index, point = self:_get_close_point(self._hed.points, pos)

	print("index", index)

	if not point then
		return
	end

	self._moving_point_undo = clone(point)
	self._moving_point = index
end

function LaserTriggerUnitElement:_release_emb()
	print("LaserTriggerUnitElement:_release_emb()")

	if self._moving_point then
		self:_break_moving_point()
	end
end

function LaserTriggerUnitElement:_check_remove_index(index)
	for i, connection in ipairs(clone(self._hed.connections)) do
		if connection.from == index or connection.to == index then
			if self._selected_connection and self._selected_connection == i then
				self._selected_connection = nil
			end

			table.remove(self._hed.connections, i)
			self:_fill_connections_box()
			self:_check_remove_index(index)

			return
		end
	end
end

function LaserTriggerUnitElement:_check_remove_connection(i1, i2)
	for i, connection in ipairs(clone(self._hed.connections)) do
		if connection.from == i1 and connection.to == i2 or connection.from == i2 and connection.to == i1 then
			table.remove(self._hed.connections, i)
			self:_fill_connections_box()

			if self._selected_connection and self._selected_connection == i then
				self._selected_connection = nil
			end

			return true
		end
	end

	return false
end

function LaserTriggerUnitElement:add_triggers(vc)
	LaserTriggerUnitElement.super.add_triggers(self, vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "_lmb"))
	vc:add_trigger(Idstring("rmb"), callback(self, self, "_rmb"))
	vc:add_trigger(Idstring("emb"), callback(self, self, "_emb"))
	vc:add_release_trigger(Idstring("emb"), callback(self, self, "_release_emb"))
end

function LaserTriggerUnitElement:_on_clicked_connections_box()
	print("LaserTriggerUnitElement:_on_clicked_connections_box()")

	local selected_index = self._connections_box:selected_index()

	if not selected_index then
		self._selected_connection = nil

		return
	end

	print(self._connections_box:get_string(selected_index))

	self._selected_connection = tonumber(self._connections_box:get_string(selected_index))
end

function LaserTriggerUnitElement:_fill_connections_box()
	self._connections_box:clear()

	for i, connection in ipairs(self._hed.connections) do
		self._connections_box:append(i)
	end
end

function LaserTriggerUnitElement:_move_connection_up()
	print("LaserTriggerUnitElement:_move_connection_up()")

	if not self._selected_connection or self._selected_connection == 1 then
		return
	end

	local selected_index = self._connections_box:selected_index()

	table.insert(self._hed.connections, self._selected_connection - 1, table.remove(self._hed.connections, self._selected_connection))
	self:_fill_connections_box()
	self._connections_box:select_index(selected_index - 1)
	self:_on_clicked_connections_box()
end

function LaserTriggerUnitElement:_move_connection_down()
	print("LaserTriggerUnitElement:_move_connection_down()")

	if not self._selected_connection or self._selected_connection == #self._hed.connections then
		return
	end

	local selected_index = self._connections_box:selected_index()

	table.insert(self._hed.connections, self._selected_connection + 1, table.remove(self._hed.connections, self._selected_connection))
	self:_fill_connections_box()
	self._connections_box:select_index(selected_index + 1)
	self:_on_clicked_connections_box()
end

function LaserTriggerUnitElement:set_element_data(params, ...)
	LaserTriggerUnitElement.super.set_element_data(self, params, ...)

	if params.value == "instigator" and self._hed.instigator == "criminals" then
		EWS:message_box(Global.frame_panel, "Criminals is deprecated, you should probably use local_criminals. Ask Martin or Ilija why.", "Instigator Warning", "ICON_WARNING", Vector3(-1, -1, 0))
	end
end

function LaserTriggerUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_number(panel, panel_sizer, "interval", {
		floats = 2,
		min = 0.01
	}, "Set the check interval for the laser, in seconds", "Check interval:")
	self:_build_value_combobox(panel, panel_sizer, "instigator", managers.mission:area_instigator_categories(), "Select an instigator type")
	self:_build_value_combobox(panel, panel_sizer, "color", {
		"red",
		"green",
		"blue"
	}, "Select a color")
	self:_build_value_checkbox(panel, panel_sizer, "visual_only")
	self:_build_value_checkbox(panel, panel_sizer, "skip_dummies")
	self:_build_value_checkbox(panel, panel_sizer, "flicker_remove", "Will flicker the lasers when removed")
	self:_build_value_number(panel, panel_sizer, "cycle_interval", {
		floats = 2,
		min = 0
	}, "Set the check cycle interval for the laser, in seconds (0 == disabled)")
	self:_build_value_number(panel, panel_sizer, "cycle_active_amount", {
		floats = 0,
		min = 1
	}, "Defines how many are active during cycle")
	self:_build_value_combobox(panel, panel_sizer, "cycle_type", {
		"flow",
		"pop"
	}, "Select a cycle type")
	self:_build_value_checkbox(panel, panel_sizer, "cycle_random")

	local connections_sizer = EWS:BoxSizer("HORIZONTAL")

	panel_sizer:add(connections_sizer, 0, 1, "LEFT,EXPAND")

	local toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER,TB_VERTICAL")

	toolbar:add_tool("MOVE_UP", "Move up", CoreEws.image_path("world_editor\\unit_by_name_list.png"), nil)
	toolbar:connect("MOVE_UP", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_move_connection_up"), nil)
	toolbar:add_tool("MOVE_DOWN", "Move down", CoreEws.image_path("toolbar\\delete_16x16.png"), nil)
	toolbar:connect("MOVE_DOWN", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_move_connection_down"), nil)
	toolbar:realize()
	connections_sizer:add(toolbar, 0, 1, "EXPAND,LEFT,ALIGN_RIGHT")

	local connections_box = EWS:ListBox(panel, "", "")

	connections_box:connect("", "EVT_COMMAND_LISTBOX_SELECTED", callback(self, self, "_on_clicked_connections_box"), nil)
	connections_box:set_min_size(Vector3(50, 140, 0))
	connections_sizer:add(connections_box, 0, 4, "TOP,EXPAND,ALIGN_RIGHT")

	self._connections_box = connections_box

	self:_fill_connections_box()
end

function LaserTriggerUnitElement:add_to_mission_package()
	local unit_name = self._dummy_unit_name

	managers.editor:add_to_world_package({
		category = "units",
		name = unit_name:s(),
		continent = self._unit:unit_data().continent
	})

	local sequence_files = {}

	CoreEditorUtils.get_sequence_files_by_unit_name(unit_name, sequence_files)

	for _, file in ipairs(sequence_files) do
		managers.editor:add_to_world_package({
			init = true,
			category = "script_data",
			name = file:s() .. ".sequence_manager",
			continent = self._unit:unit_data().continent
		})
	end
end
