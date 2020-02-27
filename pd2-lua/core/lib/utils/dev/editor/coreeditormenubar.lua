core:import("CoreEngineAccess")

function CoreEditor:build_menubar()
	local menu_bar = EWS:MenuBar()
	self._menu_bar = menu_bar
	local file_menu = EWS:Menu("")

	file_menu:append_item("NEW", "New\t" .. self:ctrl_menu_binding("new"), "Create new file")
	file_menu:append_item("OPEN", "Open...\t" .. self:ctrl_menu_binding("open"), "Open world file")
	file_menu:append_separator()
	file_menu:append_item("SAVE", "Save\t" .. self:ctrl_menu_binding("save"), "Save world file")
	file_menu:append_item("SAVE AS", "Save As...", "Save world file")
	file_menu:append_item("SAVE AS COPY", "Save As copy...", "Save copy of world file")
	file_menu:append_separator()

	self._rf_menu = EWS:Menu("")
	self._recent_files_callback = callback(self, self, "on_load_recent_file")

	for index, file in ipairs(self._recent_files) do
		self._rf_menu:append_item(file.path, index .. " " .. file.path, "")
		Global.frame:connect(file.path, "EVT_COMMAND_MENU_SELECTED", self._recent_files_callback, index)
	end

	file_menu:append_menu("RECENT FILES", "Recent Files", self._rf_menu, "Recent worked on files")
	file_menu:append_separator()
	file_menu:append_item("EXIT", "Exit", "Exit the application")
	menu_bar:append(file_menu, "File")
	Global.frame:set_menu_bar(menu_bar)
	Global.frame:connect("", "EVT_CLOSE_WINDOW", callback(self, self, "on_close"), "")
	Global.frame:connect("NEW", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_new"), "")
	Global.frame:connect("OPEN", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_open"), "")
	Global.frame:connect("SAVE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_save"), "")
	Global.frame:connect("SAVE AS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_saveas"), "")
	Global.frame:connect("SAVE AS COPY", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_saveascopy"), "")
	Global.frame:connect("EXIT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_close"), "")

	local layers_menu = EWS:Menu("")
	self._disable_layer_menu = EWS:Menu("")
	self._hide_layer_menu = EWS:Menu("")
	self._unhide_layer_menu = EWS:Menu("")

	layers_menu:append_item("ENABLE_ALL_LAYERS", "Enabled all layers", "Enabled all layers")
	Global.frame:connect("ENABLE_ALL_LAYERS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_enable_all_layers"), "")
	layers_menu:append_item("DISABLE_ALL_OTHER_LAYERS", "Disable layers", "Disable all layers but current one")
	Global.frame:connect("DISABLE_ALL_OTHER_LAYERS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_disable_layers"), "")
	layers_menu:append_menu("DISABLE_LAYERS", "Disable", self._disable_layer_menu, "Disable layers")
	layers_menu:append_separator()

	local page_count = self._notebook:get_page_count()

	for i = 0, page_count - 1, 1 do
		local text = self._notebook:get_page_text(i)

		self._disable_layer_menu:append_check_item("DISABLE_" .. text, text, "Disable layer " .. text)
		Global.frame:connect("DISABLE_" .. text, "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_disable_layer"), {
			name = text,
			id = "DISABLE_" .. text
		})
		self._hide_layer_menu:append_item("HIDE_" .. text, text, "Hide layer " .. text)
		Global.frame:connect("HIDE_" .. text, "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_hide_layer"), {
			name = text,
			id = "HIDE_" .. text
		})
		self._unhide_layer_menu:append_item("UNHIDE_" .. text, text, "Unhide layer " .. text)
		Global.frame:connect("UNHIDE_" .. text, "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_unhide_layer"), {
			name = text,
			id = "UNHIDE_" .. text
		})

		local c = "\tAlt+" .. i + 1

		if i + 1 >= 10 then
			c = "\tCtrl+Alt+" .. i - 9
		end

		layers_menu:append_item(text, text .. c, "Change To Layer")
		Global.frame:connect(text, "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_change_layer"), i)
	end

	menu_bar:append(layers_menu, "Layers")

	self._edit_menu = EWS:Menu("")

	self._edit_menu:append_radio_item("TB WIDGET SELECT", "Select\t" .. self:ctrl_menu_binding("select"), "Select Unit")
	self._edit_menu:append_radio_item("TB WIDGET MOVE", "Move\t" .. self:ctrl_menu_binding("move"), "Select and Move")
	self._edit_menu:append_radio_item("TB WIDGET ROTATE", "Rotate\t" .. self:ctrl_menu_binding("rotate"), "Select and Rotate")
	self._edit_menu:append_item("SHOW_MOVE_TRANFORM_TYPE_IN", "Move transform type-in\t" .. self:ctrl_menu_binding("move_transform_type_in"), "Opens the move transform type-in dialog")
	Global.frame:connect("SHOW_MOVE_TRANFORM_TYPE_IN", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_move_transform_type_in"), nil)
	self._edit_menu:append_item("SHOW_ROTATION_TRANFORM_TYPE_IN", "Rotate transform type-in\t" .. self:ctrl_menu_binding("rotate_transform_type_in"), "Opens the rotate transform type-in dialog")
	Global.frame:connect("SHOW_ROTATION_TRANFORM_TYPE_IN", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_rotate_transform_type_in"), nil)
	self._edit_menu:append_separator()
	self._edit_menu:append_item("SHOW_CAMERA_TRANFORM_TYPE_IN", "Camera transform type-in\t" .. self:ctrl_menu_binding("camera_transform_type_in"), "Opens the camera transform type-in dialog")
	Global.frame:connect("SHOW_CAMERA_TRANFORM_TYPE_IN", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_camera_transform_type_in"), nil)
	self._edit_menu:append_separator()

	self._coordinate_menu = EWS:Menu("")

	for _, coor in ipairs(self._coordinate_systems) do
		self._coordinate_menu:append_radio_item(coor, coor, coor)
	end

	self._coordinate_menu:set_checked(self._coordinate_system, true)
	self._edit_menu:append_menu("COORDINATE_MENU", "Reference Coordinate System\t(" .. self:ctrl_binding("toggle_coordinate_system") .. ")", self._coordinate_menu, "Reference Coordinate System")
	self._edit_menu:append_separator()
	self._edit_menu:append_check_item("TB_SURFACE_MOVE", "Surface Move\t(" .. self:ctrl_binding("surface_move_toggle") .. ")", "Toggle surface move on and off")
	self._edit_menu:set_checked("TB_SURFACE_MOVE", self._use_surface_move)
	Global.frame:connect("TB_SURFACE_MOVE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "menu_toolbar_toggle"), {
		value = "_use_surface_move",
		toolbar = "_toolbar",
		menu = "_edit_menu"
	})
	self._edit_menu:append_check_item("TB_SNAPPOINTS", "Use Snappoints\t(" .. self:ctrl_binding("use_snappoints_toggle") .. ")", "Toggle use of snappoints on and off")
	self._edit_menu:set_checked("TB_SNAPPOINTS", self._use_snappoints)
	Global.frame:connect("TB_SNAPPOINTS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "menu_toolbar_toggle"), {
		value = "_use_snappoints",
		toolbar = "_toolbar",
		menu = "_edit_menu"
	})
	self._edit_menu:append_separator()

	self._grid_sizes_menu = EWS:Menu("")

	for _, g in ipairs(self._grid_sizes) do
		self._grid_sizes_menu:append_radio_item("TB_GRIDSIZE" .. g, g, "Set gridsize to " .. g)
	end

	self._grid_sizes_menu:set_checked("TB_GRIDSIZE" .. self._grid_size, true)
	self._edit_menu:append_menu("GRID_SIZES_MENU", "Grid sizes\t(" .. self:ctrl_binding("change_grid_size") .. ")", self._grid_sizes_menu, "Grid Sizes")

	self._snap_rotations_menu = EWS:Menu("")

	for _, r in ipairs(self._snap_rotations) do
		self._snap_rotations_menu:append_radio_item("TB_SNAPROTATION" .. r, r, "Set snap rotation to " .. r)
	end

	self._snap_rotations_menu:set_checked("TB_SNAPROTATION" .. self._snap_rotation, true)
	self._edit_menu:append_menu("SNAP_ROTATION_MENU", "Snap Rotations\t(" .. self:ctrl_binding("change_snaprot") .. ")", self._snap_rotations_menu, "Snap Rotations")

	self._snap_rotations_axis_menu = EWS:Menu("")

	self._snap_rotations_axis_menu:append_radio_item("TB_SNAPROTATE_X", "X", "Snap rotate axis X")
	self._snap_rotations_axis_menu:append_radio_item("TB_SNAPROTATE_Y", "Y", "Snap rotate axis Y")
	self._snap_rotations_axis_menu:append_radio_item("TB_SNAPROTATE_Z", "Z", "Snap rotate axis Z")

	if self._snap_rotation_axis == "x" then
		self._snap_rotations_axis_menu:set_checked("TB_SNAPROTATE_X", true)
	elseif self._snap_rotation_axis == "y" then
		self._snap_rotations_axis_menu:set_checked("TB_SNAPROTATE_Y", true)
	else
		self._snap_rotations_axis_menu:set_checked("TB_SNAPROTATE_Z", true)
	end

	self._edit_menu:append_menu("SNAP_ROTATION_AIXS_MENU", "Snap Rotation Axis\t(" .. self:ctrl_binding("change_snaprot_axis") .. ")", self._snap_rotations_axis_menu, "Snap Rotation Axis")
	self._edit_menu:append_separator()
	self._edit_menu:append_item("BREAK_SELECTED_UNIT_LINKS", "Break Links", "Removes all on executed and insert links from the selected units")
	Global.frame:connect("BREAK_SELECTED_UNIT_LINKS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_break_unit_links"), nil)
	menu_bar:append(self._edit_menu, "Edit")

	self._group_menu = EWS:Menu("")

	self._group_menu:append_item("SELECT_GROUP_BY_NAME", "Select Group By Name", "Shows a list with all groups")
	self._group_menu:append_separator()
	self._group_menu:append_item("GROUP", "Group\t" .. self:ctrl_menu_binding("create_group"), "Create a group from the seleceted units")
	self._group_menu:append_item("UNGROUP", "Ungroup\t" .. self:ctrl_menu_binding("remove_group"), "Removes the selected group")
	self._group_menu:append_separator()
	self._group_menu:append_check_item("DEBUG_DRAW_GROUPS", "Draw Groups", "Draws units to show that they belong to a group")
	self._group_menu:set_checked("DEBUG_DRAW_GROUPS", self._debug_draw_groups)
	self._group_menu:append_separator()
	self._group_menu:append_item("SAVE_GROUP", "Save", "Saves a group to file")
	self._group_menu:append_item("LOAD_GROUP", "Load", "Loads a group from file")
	self._group_menu:append_item("SHOW_GROUP_PRESETS", "Group Presets", "Displays a list of group presets")
	self._group_menu:append_separator()
	self._group_menu:append_item("DUMP_GROUP", "Dump", "Dumps a group to mesh")
	Global.frame:connect("SELECT_GROUP_BY_NAME", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_select_group_by_name"), nil)
	Global.frame:connect("GROUP", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "group"), nil)
	Global.frame:connect("UNGROUP", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "ungroup"), nil)
	Global.frame:connect("DEBUG_DRAW_GROUPS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "menu_toolbar_toggle"), {
		value = "_debug_draw_groups",
		menu = "_group_menu"
	})
	Global.frame:connect("SAVE_GROUP", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "save_group"), nil)
	Global.frame:connect("LOAD_GROUP", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "load_group"), nil)
	Global.frame:connect("SHOW_GROUP_PRESETS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "show_group_presets"), nil)
	Global.frame:connect("DUMP_GROUP", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "dump_group"), nil)
	menu_bar:append(self._group_menu, "Group")

	self._mission_menu = EWS:Menu("")

	self._mission_menu:append_item("RUN MISSION SIMULATION", "Run Mission Simulation\t" .. self:ctrl_menu_binding("run_mission_simulation"), "Run Mission Simulation")
	self._mission_menu:append_item("RUN GAMEPLAY SIMULATION", "Run Gameplay Simulation\t" .. self:ctrl_menu_binding("run_gameplay_simulation"), "Run Gameplay Simulation")

	local difficulty_menu = EWS:Menu("")

	for _, difficulty in ipairs(self._mission_difficulties) do
		difficulty_menu:append_radio_item(difficulty[1], difficulty[2], "")
		Global.frame:connect(difficulty[1], "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_difficulty"), difficulty[1])
	end

	difficulty_menu:set_checked(self._mission_difficulty, true)
	self._mission_menu:append_menu("DIFFICULTY MENU", "Difficulty", difficulty_menu, "Difficulties")

	local players_menu = EWS:Menu("")

	for _, player in ipairs(self._mission_players) do
		players_menu:append_radio_item(player, player, "")
		Global.frame:connect(player, "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_players"), player)
	end

	players_menu:set_checked(self._mission_player, true)
	self._mission_menu:append_menu("PLAYERS MENU", "Players", players_menu, "Players")

	local platforms_menu = EWS:Menu("")

	for _, platform in ipairs(self._mission_platforms) do
		platforms_menu:append_radio_item(platform, platform, "")
		Global.frame:connect(platform, "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_platform"), platform)
	end

	platforms_menu:set_checked(self._mission_platform, true)
	self._mission_menu:append_menu("PLATFORMS MENU", "Platform", platforms_menu, "Platform")
	self._mission_menu:append_separator()
	self._mission_menu:append_check_item("MISSION_DEBUG_DRAW_AREAS", "Draw areas during simulation", "Will draw areas while running simulation")
	self._mission_menu:set_checked("MISSION_DEBUG_DRAW_AREAS", self._simulation_debug_areas)
	Global.frame:connect("MISSION_DEBUG_DRAW_AREAS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "menu_toolbar_toggle"), {
		value = "_simulation_debug_areas",
		menu = "_mission_menu"
	})
	self._mission_menu:append_separator()
	self._mission_menu:append_item("CONNECT_SLAVE", "Connect Slave System", "Full Client Sync")
	Global.frame:connect("RUN MISSION SIMULATION", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "run_simulation_callback"), true)
	Global.frame:connect("RUN GAMEPLAY SIMULATION", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "run_simulation_callback"), false)
	Global.frame:connect("CONNECT_SLAVE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "connect_slave"), nil)
	menu_bar:append(self._mission_menu, "Mission")

	local view_menu = EWS:Menu("")
	local info_menu = EWS:Menu("")

	info_menu:append_check_item("INFO OUTPUT", "Show output", "Toggle output")
	info_menu:set_checked("INFO OUTPUT", true)
	Global.frame:connect("INFO OUTPUT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "toggle_info"), {
		info_menu,
		"INFO OUTPUT"
	})
	info_menu:append_check_item("INFO UNIT", "Show unit info", "Toggle unit info")
	info_menu:set_checked("INFO UNIT", true)
	Global.frame:connect("INFO UNIT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "toggle_info"), {
		info_menu,
		"INFO UNIT"
	})
	view_menu:append_menu("INFO MENU", "Info", info_menu, "Info views")
	view_menu:append_item("SHOW_NEWS", "News...", "Show the news list")
	Global.frame:connect("SHOW_NEWS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "show_news"), nil)
	view_menu:append_separator()
	view_menu:append_item("LIGHTING", "Deferred Lighting", "Change visualization to Deferred Lighting")
	view_menu:append_item("ALBEDO", "Albedo", "Change visualization to Albedo")
	view_menu:append_item("NORMAL", "Normal", "Change visualization to Normal")
	view_menu:append_item("SPECULAR", "Specular", "Change visualization to Specular")
	view_menu:append_item("GLOSSINESS", "Glossiness", "Change visualization to Glossiness")
	view_menu:append_item("DEPTH", "Depth", "Change visualization to Depth")
	view_menu:append_separator()

	local post_processor_effects_menu = EWS:Menu("")
	self._post_processor_effects_menu = post_processor_effects_menu
	local post_effects = {
		{
			text = "None",
			id = "POSTFX_none",
			help = "No post effects"
		},
		{
			text = "Default",
			id = "POSTFX_default",
			help = "Default post effects"
		},
		{
			text = "Bloom",
			id = "POSTFX_bloom",
			help = "Bloom"
		},
		{
			text = "Anti aliasing",
			id = "POSTFX_aa",
			help = "Anti aliasing"
		},
		{
			text = "SSAO",
			id = "POSTFX_ssao",
			help = "SSAO"
		}
	}

	for _, pe in ipairs(post_effects) do
		post_processor_effects_menu:append_check_item(pe.id, pe.text, pe.help)
		Global.frame:connect(pe.id, "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_post_processor_effect"), pe)
	end

	view_menu:append_menu("POST_PROCESSOR_MENU", "Post processor effects", post_processor_effects_menu, "Post processor effects")
	view_menu:append_separator()
	view_menu:append_check_item("LOCK_1280_720", "Lock 1280x720", "Toggle lock resolution of application window to/from 1280x720")
	view_menu:set_checked("LOCK_1280_720", self._appwin_fixed_resolution and true or false)
	view_menu:append_separator()
	view_menu:append_check_item("ORTHOGRAPHIC", "Orthographic\t" .. self:ctrl_menu_binding("orthographic"), "Toggle Orthographic")
	view_menu:append_separator()
	view_menu:append_check_item("USE LIGHT", "Use Light\t" .. self:ctrl_menu_binding("use_light"), "Turn head light on / off")
	view_menu:append_check_item("SHOW CENTER", "Show Center\t" .. self:ctrl_menu_binding("show_center"), "Show Center on / off")
	view_menu:set_checked("SHOW CENTER", self._show_center)
	view_menu:append_check_item("SHOW CAMERA INFO", "Show Camera info\t" .. self:ctrl_menu_binding("show_camera_info"), "Show Camera info on / off")
	view_menu:set_checked("SHOW CAMERA INFO", self._show_camera_position)
	view_menu:append_check_item("SHOW_MARKER_BALL", "Show Marker", "Show Marker on / off")
	view_menu:set_checked("SHOW_MARKER_BALL", self._layer_draw_marker)
	menu_bar:append(view_menu, "View")
	Global.frame:connect("LIGHTING", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "change_visualization"), "deferred_lighting")
	Global.frame:connect("ALBEDO", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "change_visualization"), "albedo_visualization")
	Global.frame:connect("NORMAL", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "change_visualization"), "normal_visualization")
	Global.frame:connect("SPECULAR", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "change_visualization"), "specular_visualization")
	Global.frame:connect("GLOSSINESS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "change_visualization"), "glossiness_visualization")
	Global.frame:connect("DEPTH", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "change_visualization"), "depth_visualization")
	Global.frame:connect("LOCK_1280_720", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "toggle_lock_1280_720"), {
		view_menu,
		"LOCK_1280_720"
	})
	Global.frame:connect("ORTHOGRAPHIC", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "toggle_orthographic"), {
		view_menu,
		"ORTHOGRAPHIC"
	})
	Global.frame:connect("USE LIGHT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "toggle_light"), {
		view_menu,
		"USE LIGHT"
	})
	Global.frame:connect("SHOW CENTER", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "toggle_show_center"), {
		view_menu,
		"SHOW CENTER"
	})
	Global.frame:connect("SHOW CAMERA INFO", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "toggle_show_camera_info"), {
		view_menu,
		"SHOW CAMERA INFO"
	})
	Global.frame:connect("SHOW_MARKER_BALL", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "toggle_draw_marker_ball"), {
		view_menu,
		"SHOW_MARKER_BALL"
	})

	local hide_menu = EWS:Menu("")

	hide_menu:append_item("UNHIDE_BY_NAME", "Unhide by name", "Unhide units by name")
	hide_menu:append_item("UNHIDE_ALL", "Unhide all\t" .. self:ctrl_menu_binding("unhide_all"), "Unhide all units")
	hide_menu:append_item("HIDE_SELECTED", "Hide selected\t" .. self:ctrl_menu_binding("hide_selected"), "Hide selected units")
	hide_menu:append_item("HIDE_UNSELECTED", "Hide unselected", "Hide unselected units")
	Global.frame:connect("UNHIDE_BY_NAME", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_unhide_by_name"), nil)
	Global.frame:connect("UNHIDE_ALL", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_unhide_all"), nil)
	Global.frame:connect("HIDE_SELECTED", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_hide_selected"), nil)
	Global.frame:connect("HIDE_UNSELECTED", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_hide_unselected"), nil)
	hide_menu:append_separator()
	hide_menu:append_item("HIDE_CURRENT_LAYERS", "Hide current layer", "Hide current layer")
	hide_menu:append_item("HIDE_ALL_LAYERS", "Hide other layers", "Hide all layers but current")
	hide_menu:append_menu("HIDE_LAYERS", "Hide", self._hide_layer_menu, "Hide layers")
	hide_menu:append_menu("UNHIDE_HIDE_LAYERS", "Unhide", self._unhide_layer_menu, "Unhide layers")
	Global.frame:connect("HIDE_CURRENT_LAYERS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_hide_current_layer"), nil)
	Global.frame:connect("HIDE_ALL_LAYERS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_hide_all_layers"), nil)
	hide_menu:append_separator()
	hide_menu:append_item("HIDE HELPERS", "Hide Helpers\t" .. self:ctrl_menu_binding("hide_helpers"), "Hide Helpers")
	hide_menu:append_item("UNHIDE HELPERS", "Unhide Helpers\t" .. self:ctrl_menu_binding("unhide_helpers"), "Unhide Helpers")
	hide_menu:append_item("HIDE HELPERS EXCEPT LIGHTS", "Hide Helpers Except Lights\t" .. self:ctrl_menu_binding("hide_helpers_except_lights"), "Hide Helpers except lights")
	hide_menu:append_separator()
	hide_menu:append_check_item("RENDER_EFFECTS", "Render Effects", "Toggle rendering of effects on and off")
	hide_menu:set_checked("RENDER_EFFECTS", true)
	Global.frame:connect("HIDE HELPERS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_hide_helper_units"), {
		vis = false
	})
	Global.frame:connect("UNHIDE HELPERS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_hide_helper_units"), {
		vis = true
	})
	Global.frame:connect("HIDE HELPERS EXCEPT LIGHTS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_hide_helper_units"), {
		vis = false,
		skip_lights = true
	})
	Global.frame:connect("RENDER_EFFECTS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "toggle_render_effects"), {
		hide_menu,
		"RENDER_EFFECTS"
	})
	menu_bar:append(hide_menu, "Hide/Unhide")

	local advanced_menu = EWS:Menu("")

	advanced_menu:append_item("CONFIGURATION", "Configuration...\t" .. self:ctrl_menu_binding("configuration"), "Configuration")
	advanced_menu:append_item("CONTROLLER_BINDINGS", "Show controller bindings...", "Show controller bindings")
	advanced_menu:append_separator()
	advanced_menu:append_check_item("EXPERT MODE", "Expert Mode\t" .. self:ctrl_menu_binding("expert_mode"), "Toggle expert mode")
	advanced_menu:set_checked("EXPERT MODE", false)
	advanced_menu:append_separator()
	advanced_menu:append_item("SELECT UNIT", "Global select unit...\t" .. self:ctrl_menu_binding("global_select_unit"), "Global select unit")
	advanced_menu:append_item("SELECT BY NAME", "Select by name...\t" .. self:ctrl_menu_binding("select_by_name"), "Select by name")
	menu_bar:append(advanced_menu, "Advanced")
	Global.frame:connect("CONFIGURATION", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_configuration"), "")
	Global.frame:connect("CONTROLLER_BINDINGS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_controller_bindings"), "")
	Global.frame:connect("EXPERT MODE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_expert_mode"), {
		advanced_menu,
		"EXPERT MODE"
	})
	Global.frame:connect("SELECT UNIT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_global_select_unit"), "")
	Global.frame:connect("SELECT BY NAME", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_select_by_name"), "")

	local unit_menu = EWS:Menu("")

	unit_menu:append_item("EDIT_UNIT_DIALOG", "Edit Unit..\t" .. self:ctrl_menu_binding("toggle_edit_unit_dialog"), "Show/hide the Edit Unit dialog.")
	unit_menu:append_item("RELOAD UNIT", "Reload Unit", "Reload Unit")
	unit_menu:append_item("RELOAD UNIT QUICK", "Reload Unit Quick", "Reload Unit Quick")
	menu_bar:append(unit_menu, "Unit")
	Global.frame:connect("EDIT_UNIT_DIALOG", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "toggle_edit_unit_dialog"), "")
	Global.frame:connect("RELOAD UNIT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_reload_unit"), "")
	Global.frame:connect("RELOAD UNIT QUICK", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_reload_unit", true), "")

	self._profiler_menu = EWS:Menu("")

	self._profiler_menu:append_item("PROFILER_MAIN", "Main", "")
	self._profiler_menu:append_item("PROFILER_MEM", "Mem", "")
	self._profiler_menu:append_item("PROFILER_D3D", "D3d", "")
	self._profiler_menu:append_item("PROFILER_UNIT_PROFILER", "Unit Profiler", "")
	menu_bar:append(self._profiler_menu, "Profiler")
	Global.frame:connect("PROFILER_MAIN", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_profiler_main"), "")
	Global.frame:connect("PROFILER_MEM", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_profiler_mem"), "")
	Global.frame:connect("PROFILER_D3D", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_profiler_d3d"), "")
	Global.frame:connect("PROFILER_UNIT_PROFILER", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_profiler_unit_profiler"), "")

	self._debug_menu = EWS:Menu("")

	self._debug_menu:append_item("ADD_WORKVIEW", "Add workview", "Adds a workview based on camera position and rotation")
	self._debug_menu:append_item("SHOW_WORKVIEW", "Show workviews", "Shows the workviews dialog")
	self._debug_menu:append_separator()
	self._debug_menu:append_item("CHECK DUALITY", "Check Unit Duality", "Goes through all units and checks if any of the same share position and rotation")
	self._debug_menu:append_item("SHOW_UNIT_COUNT", "Unit Breakdown", "Get a breakdown of the number of units in the world")
	self._debug_menu:append_separator()
	self._debug_menu:append_item("TB_MAKE_SCREENSHOT", "Capture Screenshot\t" .. self:ctrl_menu_binding("capture_screenshot"), "Choose this to create a screenshot")
	self._debug_menu:append_check_item("TB_DRAW_OCCLUDERS", "Draw Occluders", "Toggle debug draw of occluder objects")
	Global.frame:connect("ADD_WORKVIEW", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_add_workview"), "")
	Global.frame:connect("SHOW_WORKVIEW", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_show_workview"), "")
	Global.frame:connect("CHECK DUALITY", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_check_duality"), "")
	Global.frame:connect("TB_MAKE_SCREENSHOT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_make_screenshot"), "")
	Global.frame:connect("TB_DRAW_OCCLUDERS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "menu_toolbar_toggle"), {
		value = "_draw_occluders",
		toolbar = "_left_upper_toolbar",
		menu = "_debug_menu"
	})
	Global.frame:connect("SHOW_UNIT_COUNT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_show_unit_breakdown"), "")
	menu_bar:append(self._debug_menu, "Debug")

	if managers and managers.toolhub then
		menu_bar:append(managers.toolhub:get_tool_menu(Global.frame), "Toolhub")
	end

	local window_menu = EWS:Menu("")

	window_menu:append_check_item("SHOW MARKERS", "Show Markers", "Toggle markers")
	window_menu:set_checked("SHOW MARKERS", self._show_markers)
	Global.frame:connect("SHOW MARKERS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "toggle_show_markers"), {
		window_menu,
		"SHOW MARKERS"
	})
	menu_bar:append(window_menu, "Window")

	local help_menu = EWS:Menu("")

	help_menu:append_item("USING THE EDITOR", "Using the editor", "Open using the editor")
	help_menu:append_item("VIDEO TUTORIALS", "Video Tutorials", "Open video tutorials folder in explorer")
	help_menu:append_separator()
	help_menu:append_item("ABOUT", "About...", "Hello and whatnot")
	menu_bar:append(help_menu, "Help")
	Global.frame:connect("USING THE EDITOR", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_using_the_editor"), "")
	Global.frame:connect("VIDEO TUTORIALS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_video_tutorials"), "")
	Global.frame:connect("ABOUT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_about"), "")
end

function CoreEditor:confirm_on_new()
	if Global.running_simulation then
		local confirm = EWS:message_box(Global.frame_panel, "Want to quit?", "Bringer of World", "YES_NO,CANCEL,ICON_QUESTION", Vector3(-1, -1, 0))

		if confirm == "CANCEL" or confirm == "NO" then
			return true
		elseif confirm == "YES" then
			return false
		end
	end

	if self._confirm_on_new then
		local confirm = EWS:message_box(Global.frame_panel, "Save Changes?", "Bringer of World", "YES_NO,CANCEL,ICON_QUESTION", Vector3(-1, -1, 0))

		if confirm == "CANCEL" then
			return true
		elseif confirm == "YES" then
			self:on_save()
		end

		self._confirm_on_new = false
	end
end

function CoreEditor:on_new()
	if self:confirm_on_new() then
		return
	end

	self._title = self._editor_name

	Global.frame:set_title(self._title)
	self:clear_all()

	self._lastfile = nil

	if self._unit_list then
		self._unit_list:reset()
	end
end

function CoreEditor:on_open()
	if self:confirm_on_new() then
		return
	end

	local opendlg_path, opendlg_dir = managers.database:open_file_dialog(Global.frame, "Worlds (*.world)|*.world", self._lastdir)

	if opendlg_path and opendlg_dir then
		local path = opendlg_path
		local dir = opendlg_dir

		if managers.database:is_valid_database_path(opendlg_path) then
			self:load_level(dir, path)
		else
			self:output_error("Cant open file from outside the project")
			self:on_open()
		end
	end
end

function CoreEditor:on_save()
	if Global.running_simulation then
		self:output_warning("Won't save during simulation.")

		return
	end

	if self._lastfile then
		self:do_save(self._lastfile, self._lastdir)

		local rules = {
			ignore = {
				dds = true
			}
		}

		self:copy_incremental(self:create_temp_saves("incremental"), self._lastdir, rules)
	else
		self:on_saveas()
	end
end

function CoreEditor:create_temp_saves(type)
	local a = string.gsub(managers.editor._lastdir, managers.database:base_path(), "")
	local dirs = {}

	for w in string.gmatch(a, "[%w_]+") do
		table.insert(dirs, w)
	end

	local d = self._editor_temp_path

	for _, dir in ipairs(dirs) do
		d = d .. "\\" .. dir

		if not SystemFS:exists(d) then
			SystemFS:make_dir(d)
		end
	end

	d = d .. "\\" .. type

	if not SystemFS:exists(d) then
		SystemFS:make_dir(d)
	end

	return d
end

function CoreEditor:on_saveas()
	if Global.running_simulation then
		self:output_warning("Won't save during simulation.")

		return
	end

	local savedlg_path, savedlg_dir = managers.database:save_file_dialog(Global.frame, true, "Worlds (*.world)|*.world", managers.database:base_path() .. self._lastdir)

	if savedlg_path and savedlg_dir then
		local save_continents = true

		self:do_save(savedlg_path, savedlg_dir, save_continents)
		self:save_editor_settings(savedlg_path, savedlg_dir)
	end
end

function CoreEditor:on_saveascopy()
	if Global.running_simulation then
		self:output_warning("Won't save during simulation.")

		return
	end

	local savedlg_path, savedlg_dir = managers.database:save_file_dialog(Global.frame, true, "Worlds (*.world)|*.world", managers.database:base_path() .. self._lastdir)

	if savedlg_path and savedlg_dir then
		local save_continents = true

		self:do_save(savedlg_path, savedlg_dir, save_continents)
	end
end

function CoreEditor:on_load_recent_file(index)
	if self:confirm_on_new() then
		return
	end

	self:load_level(self._recent_files[index].dir, self._recent_files[index].path)
end

function CoreEditor:on_close(custom_data, event_object)
	if self:confirm_on_new() then
		return
	end

	self:save_edit_setting_values()
	self:save_layout()
	CoreEngineAccess._quit()
end

function CoreEditor:on_enable_all_layers()
	for name, layer in pairs(self:layers()) do
		layer:set_enabled(true)
		self._disable_layer_menu:set_checked("DISABLE_" .. name, false)
	end
end

function CoreEditor:on_disable_layers()
	for name, layer in pairs(self:layers()) do
		if layer ~= self._current_layer then
			self._disable_layer_menu:set_checked("DISABLE_" .. name, true)
			self:on_disable_layer({
				name = name,
				id = "DISABLE_" .. name
			})
		end
	end
end

function CoreEditor:on_disable_layer(data)
	local accepted = self:layer(data.name):set_enabled(not self._disable_layer_menu:is_checked(data.id))

	if not accepted then
		self._disable_layer_menu:set_checked(data.id, false)
	end
end

function CoreEditor:on_hide_layer(data)
	self:layer(data.name):hide_all()
end

function CoreEditor:on_unhide_layer(data)
	self:layer(data.name):unhide_all()
end

function CoreEditor:on_change_layer(index)
	self._notebook:set_page(index)
end

function CoreEditor:on_break_unit_links()
	if self._current_layer == self:layer("Mission") then
		self:layer("Mission"):break_links()
	end
end

function CoreEditor:on_select_group_by_name()
	self:show_dialog("select_group_by_name", "SelectGroupByName")
end

function CoreEditor:group()
	if alive(self._current_layer:selected_unit()) then
		local name = self._groups:group_name()

		if name then
			local unit = self._current_layer:selected_unit()
			local units = clone(self._current_layer:selected_units())

			self:create_group(name, unit, units)
		end
	end
end

function CoreEditor:ungroup()
	if alive(self._current_layer:selected_unit()) then
		local groups = self._current_layer:selected_unit():unit_data().editor_groups

		if groups and #groups > 0 then
			local group = groups[#groups]

			self:remove_group(group:name())
		end
	end
end

function CoreEditor:save_group()
	if alive(self._current_layer:selected_unit()) then
		local groups = self._current_layer:selected_unit():unit_data().editor_groups

		if groups and #groups > 0 then
			local group = groups[#groups]

			group:save_to_file()
		end
	end
end

function CoreEditor:load_group()
	self._groups:load_group()
end

function CoreEditor:show_group_presets()
	if not SystemFS:exists(self._group_presets_path) then
		SystemFS:make_dir(self._group_presets_path)
	end

	local files = SystemFS:list(self._group_presets_path, "*.xml", false)

	GroupPresetsDialog:new(files, self._group_presets_path)
end

function CoreEditor:dump_group()
	if alive(self._current_layer:selected_unit()) then
		local groups = self._current_layer:selected_unit():unit_data().editor_groups

		if groups and #groups > 0 then
			local group = groups[#groups]

			managers.editor:dump_mesh(group:units(), group:name())
		end
	end
end

function CoreEditor:on_difficulty(difficulty)
	self._mission_difficulty = difficulty
end

function CoreEditor:on_players(player)
	self._mission_player = player
end

function CoreEditor:mission_player()
	return self._mission_player
end

function CoreEditor:on_platform(platform)
	self._mission_platform = platform
end

function CoreEditor:mission_platform()
	return self._mission_platform
end

function CoreEditor:toggle_info(data)
	if data[2] == "INFO OUTPUT" then
		self._outputctrl:set_visible(data[1]:is_checked(data[2]))
	elseif data[2] == "INFO UNIT" then
		self._unit_info:set_visible(data[1]:is_checked(data[2]))
	end

	self._info_frame:layout()
end

function CoreEditor:show_news()
	self._world_editor_news:set_visible(true)
end

function CoreEditor:change_visualization(viz)
	if viz ~= "deferred_lighting" then
		self:disable_all_post_effects(true)
	else
		self:update_post_effects()
	end

	for _, vp in ipairs(managers.viewport:viewports()) do
		vp:set_visualization_mode(viz)
	end
end

function CoreEditor:on_post_processor_effect(pe)
	if pe.id == "POSTFX_none" then
		self:disable_all_post_effects()
		self._post_processor_effects_menu:set_checked(pe.id, false)
	elseif pe.id == "POSTFX_default" then
		self:enable_all_post_effects()
		self._post_processor_effects_menu:set_checked(pe.id, false)
	else
		local effect = self._post_effects[pe.id]

		if effect then
			if self._post_processor_effects_menu:is_checked(pe.id) then
				effect:on()

				effect.enable = true
			else
				effect:off()

				effect.enable = false
			end
		end
	end
end

function CoreEditor:toggle_lock_1280_720(data)
	if data[1]:is_checked(data[2]) then
		self:_set_appwin_fixed_resolution(Vector3(1280, 720, 0))
	else
		self:_set_appwin_fixed_resolution(nil)
	end
end

function CoreEditor:toggle_orthographic(data)
	self._orthographic = data[1]:is_checked(data[2])

	self._camera_controller:toggle_orthographic(self._orthographic)
end

function CoreEditor:toggle_light(data)
	self._light:set_enable(data[1]:is_checked(data[2]))
end

function CoreEditor:toggle_show_center(data)
	self._show_center = data[1]:is_checked(data[2])
end

function CoreEditor:toggle_show_camera_info(data)
	self._show_camera_position = data[1]:is_checked(data[2])

	self:set_show_camera_info(self._show_camera_position)
end

function CoreEditor:toggle_draw_marker_ball(data)
	self._layer_draw_marker = data[1]:is_checked(data[2])
end

function CoreEditor:on_configuration()
	self._configuration:show_modal()
end

function CoreEditor:on_controller_bindings()
	self:show_dialog("edit_controller_bindings", "EditControllerBindings")
end

function CoreEditor:on_expert_mode(data)
	local expert = data[1]:is_checked(data[2])

	self._ews_editor_frame:set_visible(not expert)
	self._lower_panel:set_visible(not expert)
	Global.frame_panel:layout()
end

function CoreEditor:on_reload_unit(quick)
	local names = {}

	if self._current_layer then
		for _, unit in ipairs(self._current_layer:selected_units()) do
			if alive(unit) then
				local name = unit:name()

				if not table.contains(names, name) then
					table.insert(names, name)
				end
			end
		end
	end

	if quick == true then
		self:reload_units(names, quick)
	else
		local choice = EWS:message_box(Global.frame_panel, "Sure you want to reload all units?", "Confirm", "YES_NO,YES_DEFAULT,ICON_EXCLAMATION", Vector3(-1, -1, 0))

		if choice == "YES" then
			self:reload_units(names, quick)
		end
	end
end

function CoreEditor:on_profiler_main(custom_data, event_object)
	self._profiler_menu:set_checked("PROFILER_MAIN", not event_object:is_checked())
	Application:console_command("stats main")
end

function CoreEditor:on_profiler_mem(custom_data, event_object)
	self._profiler_menu:set_checked("PROFILER_MEM", not event_object:is_checked())
	Application:console_command("stats mem")
end

function CoreEditor:on_profiler_d3d(custom_data, event_object)
	self._profiler_menu:set_checked("PROFILER_D3D", not event_object:is_checked())
	Application:console_command("stats d3d")
end

function CoreEditor:on_profiler_unit_profiler(custom_data, event_object)
	self._profiler_menu:set_checked("PROFILER_UNIT_PROFILER", not event_object:is_checked())
	Application:console_command("stats unit_profiler")
end

function CoreEditor:on_add_workview()
	local name = EWS:get_text_from_user(Global.frame_panel, "Enter name for new work view:", "Add work view", "", Vector3(-1, -1, 0), true)

	if name and name ~= "" then
		local continent = self:current_continent_name()

		if self._values[continent].workviews[name] then
			self:on_add_workview()
		else
			self:add_workview(name)
		end
	end
end

function CoreEditor:on_show_workview()
	self:show_dialog("workview_by_name", "SelectWorkView")
end

function CoreEditor:on_check_duality()
	local units = {}
	local collisions = {
		only_positions = {},
		complete = {}
	}

	for _, unit in ipairs(World:find_units_quick("all")) do
		local pos = unit:position()
		pos = pos:with_x(math.floor(pos.x))
		pos = pos:with_y(math.floor(pos.y))
		pos = pos:with_z(math.floor(pos.z))
		local rot = unit:rotation()
		rot = Vector3(math.floor(rot:yaw()), math.floor(rot:pitch()), math.floor(rot:roll()))
		local unit_name = units[unit:name():s()]

		if unit_name then
			for _, data in ipairs(unit_name) do
				if data.pos == pos then
					if data.rot == rot then
						table.insert(collisions.complete, {
							u1 = data.unit,
							u2 = unit,
							pos = pos
						})
					else
						table.insert(collisions.only_positions, {
							u1 = data.unit,
							u2 = unit,
							pos = pos
						})
					end
				end
			end

			table.insert(unit_name, {
				unit = unit,
				pos = pos,
				rot = rot
			})
		else
			units[unit:name():s()] = {
				{
					unit = unit,
					pos = pos,
					rot = rot
				}
			}
		end
	end

	local pos = nil

	if self._unit_duality then
		pos = self._unit_duality:position()

		self._unit_duality:destroy()
	end

	self._unit_duality = UnitDuality:new(collisions, pos)
end

function CoreEditor:on_make_screenshot()
	local name = Application:date("%Y-%m-%d_%H.%M.%S") .. ".tga"

	Application:screenshot(name)
	self:output("Screenshot created: " .. name .. ".")
end

function CoreEditor:toggle_draw_occluders(data)
	self._draw_occluders = data[1]:is_checked(data[2])
end

function CoreEditor:on_show_unit_breakdown()
	self:show_dialog("unit_breakdown", "UnitBreakdownView")
end

local leveltools_ids = Idstring("leveltools")

function CoreEditor:on_hide_helper_units(data)
	local cache = {}

	for name, layer in pairs(self._layers) do
		for _, unit in ipairs(layer:created_units()) do
			local u_key = unit:name():s()

			if cache[u_key] then
				if not cache[u_key].skip then
					self:set_unit_visible(unit, cache[u_key].vis_state)
				end
			else
				local vis_state, affected = nil

				if unit:unit_data().only_visible_in_editor or unit:unit_data().only_exists_in_editor or unit:has_material_assigned(leveltools_ids) then
					vis_state = data.vis or data.skip_lights and CoreEditorUtils.has_editable_lights(unit)
					affected = true

					self:set_unit_visible(unit, vis_state)
				end

				cache[u_key] = {
					vis_state = vis_state,
					skip = not affected
				}
			end
		end
	end

	cache = nil
end

function CoreEditor:toggle_render_effects(data)
	World:effect_manager():set_rendering_enabled(data[1]:is_checked(data[2]))
end

function CoreEditor:toggle_show_markers(data)
	self._marker_panel:set_visible(data[1]:is_checked(data[2]))
	self._ews_editor_frame:layout()
end

function CoreEditor:on_using_the_editor()
	EWS:launch_url("https://confluence.starbreeze.com/display/PD2/Diesel+-+Tutorials+and+fundamentals")
end

function CoreEditor:on_video_tutorials()
	os.execute("explorer " .. "\\\\dallas\\Shared\\Starbreeze_Video_Tutorials" .. "\"")
end

function CoreEditor:on_about()
	EWS:MessageDialog(Global.frame_panel, self._editor_name .. [[


"And the Earth Was Without Form and Void.."

Copyright 2007-~ GRiN, Inc.

http://ganon/ or http://www.grin.se]], "About...", "OK,ICON_INFORMATION"):show_modal()
end
