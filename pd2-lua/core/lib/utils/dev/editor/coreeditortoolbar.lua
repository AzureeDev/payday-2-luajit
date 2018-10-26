
function CoreEditor:build_toolbar()
	local icons_path = managers.database:base_path() .. "core\\lib\\utils\\dev\\editor\\icons\\"
	self._toolbar = EWS:ToolBar(Global.frame, "", "TB_FLAT,TB_NODIVIDER")

	Global.frame:set_tool_bar(self._toolbar)
	self._toolbar:add_tool("TB NEW WORLD", "New World (" .. self:ctrl_menu_binding("new") .. ")", CoreEWS.image_path("toolbar\\new_16x16.png"), "New World")
	self._toolbar:connect("TB NEW WORLD", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_new"), "")
	self._toolbar:add_tool("TB OPEN WORLD", "Open World (" .. self:ctrl_menu_binding("open") .. ")", CoreEWS.image_path("toolbar\\open_16x16.png"), "Open World")
	self._toolbar:connect("TB OPEN WORLD", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_open"), "")
	self._toolbar:add_tool("TB SAVE WORLD", "Save World (" .. self:ctrl_menu_binding("save") .. ")", CoreEWS.image_path("toolbar\\save_16x16.png"), "Save World")
	self._toolbar:connect("TB SAVE WORLD", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_save"), "")
	self._toolbar:add_separator()
	self._toolbar:add_tool("TB SELECT BY NAME", "Select by name (" .. self:ctrl_menu_binding("select_by_name") .. ")", icons_path .. "select_by_name.bmp", "Select by name")
	self._toolbar:connect("TB SELECT BY NAME", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_select_by_name"), "")
	self._toolbar:add_tool("TB PREVIEW UNITS", "Browse all availible units", icons_path .. "browse_units.bmp", "Browse all availible units")
	self._toolbar:connect("TB PREVIEW UNITS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_unit_tree_browser"), "")
	self._toolbar:add_tool("TB GLOBAL SELECT UNITS", "Global select unit (" .. self:ctrl_menu_binding("global_select_unit") .. ")", icons_path .. "global_select_unit.bmp", "Global select unit")
	self._toolbar:connect("TB GLOBAL SELECT UNITS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_global_select_unit"), "")
	self._toolbar:add_separator()
	self._toolbar:add_tool("TB_HIDE_BY_NAME", "Hide by name", CoreEWS.image_path("sequencer\\zoom_out_16x16.png"), "Opens the hide by name dialog")
	self._toolbar:connect("TB_HIDE_BY_NAME", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_hide_by_name"), "")
	self._toolbar:add_tool("TB_UNHIDE_BY_NAME", "Unhide by name", CoreEWS.image_path("sequencer\\zoom_in_16x16.png"), "Opens the unhide by name dialog")
	self._toolbar:connect("TB_UNHIDE_BY_NAME", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_unhide_by_name"), "")
	self._toolbar:add_separator()
	self._toolbar:add_tool("TB UNIT DEBUG LIST", "Unit debug list", icons_path .. "unit_list.bmp", "Unit debug list")
	self._toolbar:connect("TB UNIT DEBUG LIST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_unit_list"), "")
	self._toolbar:add_tool("TB_UNIT_DUPLICATE_ID_LIST", "Unit duplicate ID list", icons_path .. "unit_duplicate_id_list.bmp", "Unit duplicate ID list")
	self._toolbar:connect("TB_UNIT_DUPLICATE_ID_LIST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_unit_duplicate_id_list"), "")
	self._toolbar:add_separator()
	self._toolbar:add_tool("TB_SELECT_GROUP_BY_NAME", "Select group by name", icons_path .. "select_group_by_name.bmp", "Select group by name")
	self._toolbar:connect("TB_SELECT_GROUP_BY_NAME", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_select_group_by_name"), "")
	self._toolbar:add_separator()
	self._toolbar:add_radio_tool("TB WIDGET SELECT", "Select Unit (" .. self:ctrl_menu_binding("select") .. ")", icons_path .. "widget_select.bmp", "Select Unit")
	Global.frame:connect("TB WIDGET SELECT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "set_widget"), {
		rotate = false,
		select = true,
		move = false
	})
	self._toolbar:add_radio_tool("TB WIDGET MOVE", "Select and Move (" .. self:ctrl_menu_binding("move") .. ")", icons_path .. "widget_move.bmp", "Select and Move")
	Global.frame:connect("TB WIDGET MOVE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "set_widget"), {
		rotate = false,
		select = false,
		move = true
	})
	Global.frame:connect("TB WIDGET MOVE", "EVT_COMMAND_TOOL_RCLICKED", callback(self, self, "on_move_transform_type_in"), nil)
	self._toolbar:add_radio_tool("TB WIDGET ROTATE", "Select and Rotate (" .. self:ctrl_menu_binding("rotate") .. ")", icons_path .. "widget_rotation.bmp", "Select and Rotate")
	Global.frame:connect("TB WIDGET ROTATE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "set_widget"), {
		rotate = true,
		select = false,
		move = false
	})
	Global.frame:connect("TB WIDGET ROTATE", "EVT_COMMAND_TOOL_RCLICKED", callback(self, self, "on_rotate_transform_type_in"), nil)
	self:build_ref_coordinate_system()
	self._toolbar:add_check_tool("TB_SURFACE_MOVE", "Surface move (" .. self:ctrl_binding("surface_move_toggle") .. ")", CoreEWS.image_path("world_editor\\surface_move_16x16.png"), "Toggle surface move on and off")
	self._toolbar:set_tool_state("TB_SURFACE_MOVE", self._use_surface_move)
	self._toolbar:connect("TB_SURFACE_MOVE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "toolbar_toggle"), {
		value = "_use_surface_move",
		menu = "_edit_menu"
	})

	self._ews_triggers.surface_move_toggle = callback(self, self, "toolbar_toggle_trg", {
		id = "TB_SURFACE_MOVE",
		value = "_use_surface_move",
		menu = "_edit_menu"
	})

	self._toolbar:add_check_tool("TB_SNAPPOINTS", "Use Snappoints (" .. self:ctrl_binding("use_snappoints_toggle") .. ")", CoreEWS.image_path("world_editor\\snappoints_16x16.png"), "Toggle use of snappoints on and off")
	self._toolbar:set_tool_state("TB_SNAPPOINTS", self._use_snappoints)
	self._toolbar:connect("TB_SNAPPOINTS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "toolbar_toggle"), {
		value = "_use_snappoints",
		menu = "_edit_menu"
	})

	self._ews_triggers.use_snappoints_toggle = callback(self, self, "toolbar_toggle_trg", {
		id = "TB_SNAPPOINTS",
		value = "_use_snappoints",
		menu = "_edit_menu"
	})

	self._toolbar:add_separator()
	self._toolbar:add_check_tool("TB_USING_GROUPS", "Using groups (" .. self:ctrl_binding("using_group_toggle") .. ")", CoreEWS.image_path("world_editor\\using_groups_16x16.png"), "Toggle using groups on and off")
	self._toolbar:connect("TB_USING_GROUPS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "toolbar_toggle"), {value = "_using_groups"})

	self._ews_triggers.using_group_toggle = callback(self, self, "toolbar_toggle_trg", {
		value = "_using_groups",
		id = "TB_USING_GROUPS"
	})

	self._toolbar:add_separator()
	self:build_grid_sizes(icons_path)
	self._toolbar:add_check_tool("TB_LAYER_DRAW_GRID", "Draw grid", CoreEWS.image_path("world_editor\\toggle_draw_grid_16x16.png"), "Toggle draw grid on and off")
	self._toolbar:set_tool_state("TB_LAYER_DRAW_GRID", self._layer_draw_grid)
	self._toolbar:connect("TB_LAYER_DRAW_GRID", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "toolbar_toggle"), {
		value = "_layer_draw_grid",
		toolbar = "_toolbar"
	})
	self._toolbar:add_separator()
	self:build_snap_rotations()
	self._toolbar:add_radio_tool("TB_SNAPROTATE_X", "Snap rotate axis X", CoreEWS.image_path("world_editor\\snap_rotation_x_16x16.png"), "Snap rotate axis X")
	Global.frame:connect("TB_SNAPROTATE_X", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "set_snap_rotation_axis"), {axis = "x"})
	self._toolbar:add_radio_tool("TB_SNAPROTATE_Y", "Snap rotate axis Y", CoreEWS.image_path("world_editor\\snap_rotation_y_16x16.png"), "Snap rotate axis Y")
	Global.frame:connect("TB_SNAPROTATE_Y", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "set_snap_rotation_axis"), {axis = "y"})
	self._toolbar:add_radio_tool("TB_SNAPROTATE_Z", "Snap rotate axis Z", CoreEWS.image_path("world_editor\\snap_rotation_z_16x16.png"), "Snap rotate axis Z")
	Global.frame:connect("TB_SNAPROTATE_Z", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "set_snap_rotation_axis"), {axis = "z"})

	if self._snap_rotation_axis == "x" then
		self._toolbar:set_tool_state("TB_SNAPROTATE_X", true)
	elseif self._snap_rotation_axis == "y" then
		self._toolbar:set_tool_state("TB_SNAPROTATE_Y", true)
	else
		self._toolbar:set_tool_state("TB_SNAPROTATE_Z", true)
	end

	self._ews_triggers.change_snaprot_axis = callback(self, self, "change_snaprot_axis", {
		value = "_coordinate_system",
		t = "_coordinate_systems",
		combobox = self._ref_coordinate_system,
		menu = self._coordinate_menu
	})

	self:build_rotation_speed()
	self._toolbar:add_separator()
	self._toolbar:add_tool("TB_GENERATE_SELECTED_PROJECTION_LIGHT", "Generate selected projection light", CoreEWS.image_path("world_editor\\generate_one_projection_16x16.png"), "Generate selected projection light")
	self._toolbar:add_tool("TB_GENERATE_ALL_PROJECTION_LIGHT", "Generate all projection light", CoreEWS.image_path("world_editor\\generate_all_projection_16x16.png"), "Generate all projection light")
	self._toolbar:connect("TB_GENERATE_SELECTED_PROJECTION_LIGHT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "create_projection_light"), "selected")
	self._toolbar:connect("TB_GENERATE_ALL_PROJECTION_LIGHT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "create_projection_light"), "all")
	self._toolbar:add_separator()

	local s = "Burton Leon Reynolds, Jr.[2] (born February 11, 1936) is an Oscar-nominated and Emmy Award-winning American actor."

	self._toolbar:add_tool("TB_HELP", "Burt Reynolds guide to using the editor", icons_path .. "burt.bmp", s)
	self._toolbar:connect("TB_HELP", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_using_the_editor"), "")
	self._toolbar:realize()
end

function CoreEditor:set_widget(data, event)
	local id = event:get_id()

	self._edit_menu:set_checked(id, true)
	self._toolbar:set_tool_state(id, true)

	self._use_move_widget = data.move
	self._use_rotate_widget = data.rotate

	self._current_layer:release_widget()
	self._current_layer:use_move_widget(self._use_move_widget)
	self._current_layer:use_rotate_widget(self._use_rotate_widget)
end

function CoreEditor:set_snap_rotation_axis(data, event)
	local id = event:get_id()

	self._snap_rotations_axis_menu:set_checked(id, true)
	self._toolbar:set_tool_state(id, true)

	self._snap_rotation_axis = data.axis
end

function CoreEditor:change_snaprot_axis(data)
	if self._snap_rotation_axis == "x" then
		self._snap_rotation_axis = "y"

		self._snap_rotations_axis_menu:set_checked("TB_SNAPROTATE_Y", true)
		self._toolbar:set_tool_state("TB_SNAPROTATE_Y", true)
	elseif self._snap_rotation_axis == "y" then
		self._snap_rotation_axis = "z"

		self._snap_rotations_axis_menu:set_checked("TB_SNAPROTATE_Z", true)
		self._toolbar:set_tool_state("TB_SNAPROTATE_Z", true)
	elseif self._snap_rotation_axis == "z" then
		self._snap_rotation_axis = "x"

		self._snap_rotations_axis_menu:set_checked("TB_SNAPROTATE_X", true)
		self._toolbar:set_tool_state("TB_SNAPROTATE_X", true)
	end
end

function CoreEditor:on_move_transform_type_in()
	self._move_transform_type_in:set_visible(true)
end

function CoreEditor:on_rotate_transform_type_in()
	self._rotate_transform_type_in:set_visible(true)
end

function CoreEditor:on_camera_transform_type_in()
	self._camera_transform_type_in:set_visible(true)
end

function CoreEditor:build_ref_coordinate_system()
	self._ref_coordinate_system = EWS:ComboBox(self._toolbar, "", "", "CB_DROPDOWN,CB_READONLY")

	self._ref_coordinate_system:set_tool_tip("Reference Coordinate System (" .. self:ctrl_binding("toggle_coordinate_system") .. ")")

	for _, coor in ipairs(self._coordinate_systems) do
		self._ref_coordinate_system:append(coor)
		Global.frame:connect(coor, "EVT_COMMAND_MENU_SELECTED", callback(self, self, "set_combobox_value"), {
			value = "_coordinate_system",
			combobox = self._ref_coordinate_system,
			menu = self._coordinate_menu
		})
	end

	self._ref_coordinate_system:set_value(self._coordinate_system)
	self._ref_coordinate_system:set_size(Vector3(60, -1, 0))
	self._toolbar:add_control(self._ref_coordinate_system)
	self._ref_coordinate_system:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "change_combo_box"), {
		value = "_coordinate_system",
		combobox = self._ref_coordinate_system,
		menu = self._coordinate_menu
	})

	self._ews_triggers.toggle_coordinate_system = callback(self, self, "change_combo_box_trg", {
		value = "_coordinate_system",
		t = "_coordinate_systems",
		combobox = self._ref_coordinate_system,
		menu = self._coordinate_menu
	})
end

function CoreEditor:build_grid_sizes(icons_path)
	local tip = "Grid Sizes (" .. self:ctrl_binding("change_grid_size") .. ")"
	local grid_icon = EWS:BitmapButton(self._toolbar, CoreEWS.image_path("world_editor\\grid_sizes_10x16.png"), "", "NO_BORDER")

	grid_icon:set_tool_tip(tip)
	self._toolbar:add_control(grid_icon)

	local sizes = EWS:ComboBox(self._toolbar, "", "", "CB_DROPDOWN,CB_READONLY")

	for _, g in pairs(self._grid_sizes) do
		sizes:append(g)
		Global.frame:connect("TB_GRIDSIZE" .. g, "EVT_COMMAND_MENU_SELECTED", callback(self, self, "set_combobox_value"), {
			value = "_grid_size",
			combobox = sizes,
			menu = self._grid_sizes_menu,
			choice = g
		})
	end

	sizes:set_value(self._grid_size)
	sizes:set_tool_tip(tip)
	sizes:set_size(Vector3(55, -1, 0))
	self._toolbar:add_control(sizes)
	sizes:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "change_combo_box"), {
		prefix = "TB_GRIDSIZE",
		value = "_grid_size",
		combobox = sizes,
		menu = self._grid_sizes_menu
	})

	self._ews_triggers.change_grid_size = callback(self, self, "change_combo_box_trg", {
		prefix = "TB_GRIDSIZE",
		value = "_grid_size",
		t = "_grid_sizes",
		combobox = sizes,
		menu = self._grid_sizes_menu
	})
end

function CoreEditor:build_snap_rotations()
	local tip = "Snap Rotations (" .. self:ctrl_binding("change_snaprot") .. ")"
	local snap_icon = EWS:BitmapButton(self._toolbar, CoreEWS.image_path("world_editor\\snap_rotations_10x16.png"), "", "NO_BORDER")

	snap_icon:set_tool_tip(tip)
	self._toolbar:add_control(snap_icon)

	local rotations = EWS:ComboBox(self._toolbar, "", "", "CB_DROPDOWN,CB_READONLY")

	for _, r in pairs(self._snap_rotations) do
		rotations:append(r)
		Global.frame:connect("TB_SNAPROTATION" .. r, "EVT_COMMAND_MENU_SELECTED", callback(self, self, "set_combobox_value"), {
			value = "_snap_rotation",
			combobox = rotations,
			menu = self._snap_rotations_menu,
			choice = r
		})
	end

	rotations:set_value(self._snap_rotation)
	rotations:set_tool_tip(tip)
	rotations:set_size(Vector3(55, -1, 0))
	self._toolbar:add_control(rotations)
	rotations:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "change_combo_box"), {
		prefix = "TB_SNAPROTATION",
		value = "_snap_rotation",
		combobox = rotations,
		menu = self._snap_rotations_menu
	})

	self._ews_triggers.change_snaprot = callback(self, self, "change_combo_box_trg", {
		prefix = "TB_SNAPROTATION",
		value = "_snap_rotation",
		t = "_snap_rotations",
		combobox = rotations,
		menu = self._snap_rotations_menu
	})
end

function CoreEditor:build_rotation_speed()
	local tip = "Free rotation speed (+/-)"
	local speed_icon = EWS:BitmapButton(self._toolbar, CoreEWS.image_path("world_editor\\rotation_speed_10x16.png"), "", "NO_BORDER")

	speed_icon:set_tool_tip(tip)
	self._toolbar:add_control(speed_icon)

	local rot_speed = EWS:SpinCtrl(self._toolbar, self._rotation_speed, "", "")

	rot_speed:set_tool_tip(tip)
	rot_speed:set_size(Vector3(50, -1, 0))
	rot_speed:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "update_rot_speed"), rot_speed)
	rot_speed:connect("EVT_COMMAND_TEXT_UPDATED", callback(self, self, "update_rot_speed"), rot_speed)

	self._ews_triggers.increase_rotation_speed = callback(self, self, "update_rot_speed_trg", {
		value = 1,
		ctrlr = rot_speed
	})
	self._ews_triggers.decrease_rotation_speed = callback(self, self, "update_rot_speed_trg", {
		value = -1,
		ctrlr = rot_speed
	})

	self._toolbar:add_control(rot_speed)
end

function CoreEditor:update_rot_speed(rotation_speed)
	self._rotation_speed = rotation_speed:get_value()
end

function CoreEditor:update_rot_speed_trg(data)
	data.ctrlr:set_value(data.ctrlr:get_value() + data.value)

	self._rotation_speed = data.ctrlr:get_value()
end

function CoreEditor:change_combo_box(data)
	if tonumber(self[data.value]) then
		self[data.value] = tonumber(data.combobox:get_value())
	else
		self[data.value] = data.combobox:get_value()
	end

	if data.menu then
		local id = data.combobox:get_value()

		if data.prefix then
			id = data.prefix .. id
		end

		data.menu:set_checked(id, true)
	end
end

function CoreEditor:change_combo_box_trg(data)
	local next_i = nil

	for i = 1, #self[data.t], 1 do
		if self[data.value] == self[data.t][i] then
			next_i = ctrl() and (i == 1 and #self[data.t] or 1) or shift() and (i == 1 and #self[data.t] or i - 1) or i == #self[data.t] and 1 or i + 1
		end
	end

	data.combobox:set_value(self[data.t][next_i])
	self:change_combo_box(data)
end

function CoreEditor:set_combobox_value(data, event)
	if data.choice then
		data.combobox:set_value(data.choice)
	else
		data.combobox:set_value(event:get_id())
	end

	self:change_combo_box(data)
end

function CoreEditor:on_select_by_name()
	self:show_dialog("select_by_name", "SelectByName")
end

function CoreEditor:on_unit_tree_browser()
	self:show_dialog("unit_tree_browser", "UnitTreeBrowser")
end

function CoreEditor:on_global_select_unit()
	self:show_dialog("global_select_unit", "GlobalSelectUnit")
end

function CoreEditor:on_unit_list()
	if not self._unit_list then
		self._unit_list = UnitList:new()
	else
		self._unit_list:set_visible(true)
	end
end

function CoreEditor:on_unit_duplicate_id_list()
	if not self._duplicate_id_list then
		self._duplicate_id_list = UnitDuplicateIdList:new()
	else
		self._duplicate_id_list:set_visible(true)
	end
end

function CoreEditor:on_unhide_by_name()
	self:show_dialog("unhide_by_name", "UnhideByName")
end

function CoreEditor:on_hide_by_name()
	self:show_dialog("hide_by_name", "HideByName")
end

function CoreEditor:build_widgets_icons(panel, sizer, icons_path)
	local select = EWSRadioBitmapButton:new(panel, icons_path .. "widget_select_checked.bmp", "", "")

	select:set_off_bmp(icons_path .. "widget_select.bmp")
	select:set_value(true)
	select:button():set_tool_tip("Select Unit (1)")
	sizer:add(select:button(), 0, 5, "EXPAND,LEFT")

	local move = EWSRadioBitmapButton:new(panel, icons_path .. "widget_move_checked.bmp", "", "")

	move:set_off_bmp(icons_path .. "widget_move.bmp")
	move:set_value(false)
	move:button():set_tool_tip("Select and Move (2)")
	sizer:add(move:button(), 0, 5, "EXPAND,LEFT")

	local rotate = EWSRadioBitmapButton:new(panel, icons_path .. "widget_rotation_checked.bmp", "", "")

	rotate:set_off_bmp(icons_path .. "widget_rotation.bmp")
	rotate:set_value(false)
	rotate:button():set_tool_tip("Select and Rotate (3)")
	sizer:add(rotate:button(), 0, 5, "EXPAND,LEFT")
end

