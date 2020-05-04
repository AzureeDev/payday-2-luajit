core:module("CoreWorldCameraLayer")
core:import("CoreLayer")
core:import("CoreEws")

WorldCameraLayer = WorldCameraLayer or class(CoreLayer.Layer)

function WorldCameraLayer:init(owner)
	WorldCameraLayer.super.init(self, owner, "world_camera")

	self._workspace = Overlay:newgui():create_screen_workspace(0, 0, 1, 1)
	self._gui = self._workspace:panel():gui(Idstring("core/guis/core_world_camera"))
	self._gui_visible = nil

	self:set_gui_visible(false)

	self._look_through_camera = false
	self._current_time = 0
	self._time_precision = 10000
end

function WorldCameraLayer:get_layer_name()
	return "WorldCamera"
end

function WorldCameraLayer:load(world_holder, offset)
	world_holder:create_world("world", self._save_name, offset)
	self:update_camera_list()
	self:update_sequence_list()
end

function WorldCameraLayer:save(save_params)
	local file_name = "world_cameras"
	local t = {
		single_data_block = true,
		entry = self._save_name,
		data = {
			file = file_name
		}
	}

	self:_add_project_save_data(t.data)
	managers.editor:add_save_data(t)

	local file = managers.editor:_open_file(save_params.dir .. "\\" .. file_name .. ".world_cameras")

	managers.worldcamera:save(file)
	SystemFS:close(file)
end

function WorldCameraLayer:toggle_show_framing_gui(layer_toolbar, event)
	local visible = layer_toolbar:tool_state(event:get_id())
	self._forced_show_framing_gui = visible

	self._workspace:panel():set_alpha(0.5)
	self:set_gui_visible(visible)
end

function WorldCameraLayer:set_gui_visible(visible, external_forced)
	if self._gui_visible ~= visible or self._forced_show_framing_gui then
		if visible and (self._forced_show_framing_gui or managers.worldcamera:use_gui() or external_forced) then
			self._workspace:show()
		else
			self._workspace:hide()
		end

		self._gui_visible = visible
	end
end

function WorldCameraLayer:update(t, dt)
	if not managers.worldcamera._current_world_camera and not self._look_through_camera and self._current_world_camera then
		self._current_world_camera:debug_draw_editor()

		if self._current_point then
			Application:draw_sphere(self._current_point.pos, 40, 0, 1, 0)
		end
	end

	if self._current_world_camera then
		local fov = self._current_world_camera:value_at_time(self._current_time, "fov")
		local roll = self._current_world_camera:value_at_time(self._current_time, "roll")
		local near_dof = self._current_world_camera:value_at_time(self._current_time, "near_dof")
		local far_dof = self._current_world_camera:value_at_time(self._current_time, "far_dof")
		local dof_padding = self._current_world_camera:dof_padding()
		local dof_clamp = self._current_world_camera:dof_clamp()

		if self._look_through_camera then
			local pos, t_pos = self._current_world_camera:positions_at_time(self._current_time)

			if pos and t_pos then
				local rot1 = Rotation((t_pos - pos):normalized(), roll)
				local rot = Rotation:look_at(pos, t_pos, rot1:z())

				managers.editor:set_camera(pos, rot)
			end

			managers.editor:set_camera_fov(fov)
			managers.worldcamera:update_dof_values(near_dof, far_dof, dof_padding, dof_clamp)
		end

		self._current_fov_text:set_value(string.format("%.0f", fov))
		self._current_roll_text:set_value(string.format("%.0f", roll))
		self._current_near_dof_text:set_value(string.format("%.0f", near_dof))
		self._current_far_dof_text:set_value(string.format("%.0f", far_dof))
	end
end

function WorldCameraLayer:build_panel(notebook)
	cat_print("editor", "WorldCameraLayer:build_panel")

	self._ews_panel = EWS:Panel(notebook, "", "TAB_TRAVERSAL")
	self._main_sizer = EWS:BoxSizer("HORIZONTAL")

	self._ews_panel:set_sizer(self._main_sizer)

	self._sizer = EWS:BoxSizer("VERTICAL")
	local layer_toolbar = EWS:ToolBar(self._ews_panel, "", "TB_FLAT,TB_NODIVIDER")

	layer_toolbar:add_check_tool("WC_FORCE_FRAMING_GUI", "Show framing gui", CoreEws.image_path("toolbar\\find_16x16.png"), "Look through camera")
	layer_toolbar:set_tool_state("WC_FORCE_FRAMING_GUI", self._look_through_camera)
	layer_toolbar:connect("WC_FORCE_FRAMING_GUI", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "toggle_show_framing_gui"), layer_toolbar)
	layer_toolbar:realize()
	self._sizer:add(layer_toolbar, 0, 0, "EXPAND")

	local cameras_sizer = EWS:StaticBoxSizer(self._ews_panel, "HORIZONTAL", "Cameras")
	local cam_toolbar = EWS:ToolBar(self._ews_panel, "", "TB_FLAT,TB_VERTICAL,TB_NODIVIDER")

	cam_toolbar:add_tool("WC_CREATE_NEW", "Create New", CoreEws.image_path("toolbar\\new_16x16.png"), "Create a new world camera")
	cam_toolbar:connect("WC_CREATE_NEW", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "create_new"), self._camera_list)
	cam_toolbar:add_tool("WC_DELETE", "Delete", CoreEws.image_path("toolbar\\delete_16x16.png"), "Delete selected world camera")
	cam_toolbar:connect("WC_DELETE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "delete_camera"), self._camera_list)
	cam_toolbar:add_tool("WC_TEST", "Test", CoreEws.image_path("sequencer\\play_from_start_16x16.png"), "Test selected world camera")
	cam_toolbar:connect("WC_TEST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "test_camera"), self._camera_list)
	cam_toolbar:add_tool("WC_STOP", "Stop", CoreEws.image_path("sequencer\\stop_16x16.png"), "Stop current test world camera")
	cam_toolbar:connect("WC_STOP", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "stop_camera"), self._camera_list)
	cam_toolbar:realize()
	cameras_sizer:add(cam_toolbar, 0, 0, "EXPAND")

	self._camera_list = EWS:ListBox(self._ews_panel, "", "LB_SINGLE,LB_HSCROLL,LB_NEEDED_SB,LB_SORT")

	cameras_sizer:add(self._camera_list, 1, 0, "EXPAND")
	self._sizer:add(cameras_sizer, 0, 0, "EXPAND")

	local edit_sizer = EWS:StaticBoxSizer(self._ews_panel, "VERTICAL", "Settings")
	local in_out_sizer = EWS:BoxSizer("HORIZONTAL")
	local in_sizer = EWS:StaticBoxSizer(self._ews_panel, "VERTICAL", "In")
	self._in_acc = EWS:ComboBox(self._ews_panel, "", "", "CB_DROPDOWN,CB_READONLY")

	for _, name in ipairs({
		"ease",
		"linear",
		"fast"
	}) do
		self._in_acc:append(name)
	end

	self._in_acc:set_value("linear")
	self._in_acc:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "change_acc"), "in")
	in_sizer:add(self._in_acc, 1, 0, "EXPAND")
	in_out_sizer:add(in_sizer, 1, 0, "EXPAND")

	local out_sizer = EWS:StaticBoxSizer(self._ews_panel, "VERTICAL", "Out")
	self._out_acc = EWS:ComboBox(self._ews_panel, "", "", "CB_DROPDOWN,CB_READONLY")

	for _, name in ipairs({
		"ease",
		"linear",
		"fast"
	}) do
		self._out_acc:append(name)
	end

	self._out_acc:set_value("linear")
	self._out_acc:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "change_acc"), "out")
	out_sizer:add(self._out_acc, 1, 0, "EXPAND")
	in_out_sizer:add(out_sizer, 1, 0, "EXPAND")
	edit_sizer:add(in_out_sizer, 0, 0, "EXPAND")

	self._duration_params = {
		value = 2.5,
		name = "Camera Duration [sec]:",
		ctrlr_proportions = 1,
		name_proportions = 1,
		tooltip = "Specifies the camera lenght in seconds",
		min = 0,
		floats = 2,
		panel = self._ews_panel,
		sizer = edit_sizer,
		events = {
			{
				event = "EVT_COMMAND_TEXT_ENTER",
				callback = callback(self, self, "set_duration")
			},
			{
				event = "EVT_KILL_FOCUS",
				callback = callback(self, self, "set_duration")
			}
		}
	}

	CoreEws.number_controller(self._duration_params)

	self._delay_params = {
		value = 0,
		name = "End Delay [sec]:",
		ctrlr_proportions = 1,
		name_proportions = 1,
		tooltip = "Specifies the delay time after camera has reached the end position, in seconds",
		min = 0,
		floats = 2,
		panel = self._ews_panel,
		sizer = edit_sizer,
		events = {
			{
				event = "EVT_COMMAND_TEXT_ENTER",
				callback = callback(self, self, "set_delay")
			},
			{
				event = "EVT_KILL_FOCUS",
				callback = callback(self, self, "set_delay")
			}
		}
	}

	CoreEws.number_controller(self._delay_params)

	self._dof_paddding_params = {
		name = "Dof Padding [cm]:",
		ctrlr_proportions = 1,
		name_proportions = 1,
		tooltip = "The fade distance from max dof to no dof",
		min = 0,
		floats = 0,
		panel = self._ews_panel,
		sizer = edit_sizer,
		value = managers.worldcamera:default_dof_padding(),
		events = {
			{
				event = "EVT_COMMAND_TEXT_ENTER",
				callback = callback(self, self, "set_dof_padding")
			},
			{
				event = "EVT_KILL_FOCUS",
				callback = callback(self, self, "set_dof_padding")
			}
		}
	}

	CoreEws.number_controller(self._dof_paddding_params)

	self._dof_clamp_params = {
		name_proportions = 1,
		name = "Dof Amount [0-1]:",
		ctrlr_proportions = 1,
		tooltip = "A value to specify how much dof it should have",
		min = 0,
		floats = 2,
		max = 1,
		panel = self._ews_panel,
		sizer = edit_sizer,
		value = managers.worldcamera:default_dof_clamp(),
		events = {
			{
				event = "EVT_COMMAND_TEXT_ENTER",
				callback = callback(self, self, "set_dof_clamp")
			},
			{
				event = "EVT_KILL_FOCUS",
				callback = callback(self, self, "set_dof_clamp")
			}
		}
	}

	CoreEws.number_controller(self._dof_clamp_params)
	self._sizer:add(edit_sizer, 0, 0, "EXPAND")

	local points_sizer = EWS:StaticBoxSizer(self._ews_panel, "HORIZONTAL", "Points")
	local point_toolbar = EWS:ToolBar(self._ews_panel, "", "TB_FLAT,TB_VERTICAL,TB_NODIVIDER")

	point_toolbar:add_tool("WC_ADD", "Add", CoreEws.image_path("toolbar\\new_16x16.png"), "Add point")
	point_toolbar:connect("WC_ADD", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "add_point"), nil)
	point_toolbar:add_tool("WC_MOVE", "Move", CoreEws.image_path("sequencer\\loop_16x16.png"), "Move point")
	point_toolbar:connect("WC_MOVE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "move_point"), nil)
	point_toolbar:add_tool("WC_DELETE_POINT", "Delete", CoreEws.image_path("toolbar\\delete_16x16.png"), "Delete point")
	point_toolbar:connect("WC_DELETE_POINT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "delete_point"), nil)
	point_toolbar:add_tool("WC_GOTO_POINT", "Goto", CoreEws.image_path("toolbar\\find_16x16.png"), "Goto point")
	point_toolbar:connect("WC_GOTO_POINT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "goto_point"), nil)
	point_toolbar:realize()
	points_sizer:add(point_toolbar, 0, 0, "EXPAND")

	self._point_list = EWS:ListBox(self._ews_panel, "", "LB_SINGLE,LB_HSCROLL,LB_NEEDED_SB,LB_SORT")

	self._point_list:connect("EVT_COMMAND_LISTBOX_SELECTED", callback(self, self, "select_point"), nil)
	points_sizer:add(self._point_list, 1, 0, "EXPAND")
	self._sizer:add(points_sizer, 0, 0, "EXPAND")

	local keys_sizer = EWS:StaticBoxSizer(self._ews_panel, "VERTICAL", "Keys")
	local time_sizer = EWS:BoxSizer("HORIZONTAL")

	time_sizer:add(EWS:StaticText(self._ews_panel, "Time: ", "", ""), 0, 2, "ALIGN_CENTER_VERTICAL,RIGHT")

	self._time_text = EWS:StaticText(self._ews_panel, "0", "", "")

	time_sizer:add(self._time_text, 0, 50, "ALIGN_CENTER_VERTICAL,RIGHT")
	time_sizer:add(EWS:StaticText(self._ews_panel, "Fov: ", "", ""), 0, 2, "ALIGN_CENTER_VERTICAL,RIGHT")

	self._current_fov_text = EWS:StaticText(self._ews_panel, managers.worldcamera:default_fov(), "", "")

	time_sizer:add(self._current_fov_text, 0, 50, "ALIGN_CENTER_VERTICAL,RIGHT")
	time_sizer:add(EWS:StaticText(self._ews_panel, "Roll: ", "", ""), 0, 2, "ALIGN_CENTER_VERTICAL,RIGHT")

	self._current_roll_text = EWS:StaticText(self._ews_panel, 0, "", "")

	time_sizer:add(self._current_roll_text, 0, 50, "ALIGN_CENTER_VERTICAL,RIGHT")
	keys_sizer:add(time_sizer, 0, 5, "EXPAND,BOTTOM")

	local dof_text_sizer = EWS:BoxSizer("HORIZONTAL")

	dof_text_sizer:add(EWS:StaticText(self._ews_panel, "Near Dof: ", "", ""), 0, 2, "ALIGN_CENTER_VERTICAL,RIGHT")

	self._current_near_dof_text = EWS:StaticText(self._ews_panel, managers.worldcamera:default_near_dof(), "", "")

	dof_text_sizer:add(self._current_near_dof_text, 0, 40, "ALIGN_CENTER_VERTICAL,RIGHT")
	dof_text_sizer:add(EWS:StaticText(self._ews_panel, "Far Dof: ", "", ""), 0, 2, "ALIGN_CENTER_VERTICAL,RIGHT")

	self._current_far_dof_text = EWS:StaticText(self._ews_panel, managers.worldcamera:default_near_dof(), "", "")

	dof_text_sizer:add(self._current_far_dof_text, 0, 40, "ALIGN_CENTER_VERTICAL,RIGHT")
	keys_sizer:add(dof_text_sizer, 0, 5, "EXPAND,BOTTOM")

	local time = EWS:Slider(self._ews_panel, self._current_time, 0, self._time_precision, "", "")

	keys_sizer:add(time, 0, 5, "ALIGN_RIGHT,EXPAND,BOTTOM")
	time:connect("EVT_SCROLL_CHANGED", callback(self, self, "set_time"), {
		slider = time,
		text = self._time_text
	})
	time:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "set_time"), {
		slider = time,
		text = self._time_text
	})

	self._keys_toolbar = EWS:ToolBar(self._ews_panel, "", "TB_FLAT,TB_HORIZONTAL,TB_NODIVIDER")

	self._keys_toolbar:add_check_tool("WC_LOOK_THROUGH_CAMERA", "Look through camera", CoreEws.image_path("toolbar\\find_16x16.png"), "Look through camera")
	self._keys_toolbar:set_tool_state("WC_LOOK_THROUGH_CAMERA", self._look_through_camera)
	self._keys_toolbar:connect("WC_LOOK_THROUGH_CAMERA", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "look_through_camera"), nil)
	self._keys_toolbar:add_tool("WC_ADD_KEY", "Add key", CoreEws.image_path("toolbar\\new_16x16.png"), "Add key")
	self._keys_toolbar:connect("WC_ADD_KEY", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "add_key"), nil)
	self._keys_toolbar:add_tool("WC_DELETE_KEY", "Delete key", CoreEws.image_path("toolbar\\delete_16x16.png"), "Delete key")
	self._keys_toolbar:connect("WC_DELETE_KEY", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "delete_key"), nil)
	self._keys_toolbar:add_tool("WC_PREVIOUS_KEY", "Previous key", CoreEws.image_path("world_editor\\wc_previous_key_16x16.png"), "Previous key")
	self._keys_toolbar:connect("WC_PREVIOUS_KEY", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "prev_key"), nil)
	self._keys_toolbar:add_tool("WC_NEXT_KEY", "Next key", CoreEws.image_path("world_editor\\wc_next_key_16x16.png"), "Next key")
	self._keys_toolbar:connect("WC_NEXT_KEY", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "next_key"), nil)
	self._keys_toolbar:realize()
	keys_sizer:add(self._keys_toolbar, 0, 0, "EXPAND")

	local select_key_sizer = EWS:BoxSizer("HORIZONTAL")

	select_key_sizer:add(EWS:StaticText(self._ews_panel, "Select Key: ", "", ""), 1, 2, "ALIGN_CENTER_VERTICAL,RIGHT")

	self._keys = EWS:ComboBox(self._ews_panel, "", "", "CB_DROPDOWN,CB_READONLY")

	self._keys:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "select_key"), nil)
	select_key_sizer:add(self._keys, 1, 5, "EXPAND,RIGHT")
	select_key_sizer:add(EWS:StaticText(self._ews_panel, "Key Time: ", "", ""), 1, 0, "ALIGN_CENTER_VERTICAL")

	local key_time = EWS:TextCtrl(self._ews_panel, "0", "", "TE_CENTRE,TE_PROCESS_ENTER")

	select_key_sizer:add(key_time, 1, 0, "ALIGN_RIGHT,EXPAND")
	key_time:connect("EVT_CHAR", callback(nil, _G, "verify_number"), key_time)
	key_time:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "on_key_time"), key_time)
	keys_sizer:add(select_key_sizer, 1, 0, "EXPAND")

	local key_fov_sizer = EWS:BoxSizer("HORIZONTAL")

	key_fov_sizer:add(EWS:StaticText(self._ews_panel, "Fov: ", "", ""), 1, 0, "ALIGN_CENTER_VERTICAL")

	local key_fov = EWS:Slider(self._ews_panel, managers.worldcamera:default_fov(), 1, managers.worldcamera:viewport():reference_fov(), "", "")

	key_fov_sizer:add(key_fov, 4, 0, "ALIGN_RIGHT,EXPAND")
	key_fov:connect("EVT_SCROLL_CHANGED", callback(self, self, "on_key_fov"), key_fov)
	key_fov:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "on_key_fov"), key_fov)

	local key_fov_text = EWS:StaticText(self._ews_panel, managers.worldcamera:default_fov(), "", "ALIGN_CENTRE")

	key_fov_sizer:add(key_fov_text, 0, 5, "ALIGN_CENTER_VERTICAL,RIGHT")
	keys_sizer:add(key_fov_sizer, 0, 0, "EXPAND")

	local key_near_dof_sizer = EWS:BoxSizer("HORIZONTAL")

	key_near_dof_sizer:add(EWS:StaticText(self._ews_panel, "Near Dof: ", "", ""), 1, 0, "ALIGN_CENTER_VERTICAL")

	local key_near_dof = EWS:TextCtrl(self._ews_panel, managers.worldcamera:default_near_dof(), "", "TE_CENTRE")

	key_near_dof_sizer:add(key_near_dof, 3, 0, "ALIGN_RIGHT,EXPAND")
	key_near_dof:connect("EVT_CHAR", callback(nil, _G, "verify_number"), key_near_dof)
	key_near_dof:connect("EVT_COMMAND_TEXT_UPDATED", callback(self, self, "on_key_near_dof"), key_near_dof)
	keys_sizer:add(key_near_dof_sizer, 0, 0, "EXPAND")

	local key_far_dof_sizer = EWS:BoxSizer("HORIZONTAL")

	key_far_dof_sizer:add(EWS:StaticText(self._ews_panel, "Far Dof: ", "", ""), 1, 0, "ALIGN_CENTER_VERTICAL")

	local key_far_dof = EWS:TextCtrl(self._ews_panel, managers.worldcamera:default_far_dof(), "", "TE_CENTRE")

	key_far_dof_sizer:add(key_far_dof, 3, 0, "ALIGN_RIGHT,EXPAND")
	key_far_dof:connect("EVT_CHAR", callback(nil, _G, "verify_number"), key_far_dof)
	key_far_dof:connect("EVT_COMMAND_TEXT_UPDATED", callback(self, self, "on_key_far_dof"), key_far_dof)
	keys_sizer:add(key_far_dof_sizer, 0, 0, "EXPAND")

	local roll_params = {
		name_proportions = 1,
		name = "Roll:",
		value = 0,
		tooltip = "An angle value specifying the roll",
		floats = 0,
		ctrlr_proportions = 3,
		panel = self._ews_panel,
		sizer = keys_sizer,
		events = {
			{
				event = "EVT_COMMAND_TEXT_ENTER",
				callback = callback(self, self, "on_set_roll")
			},
			{
				event = "EVT_KILL_FOCUS",
				callback = callback(self, self, "on_set_roll")
			}
		}
	}

	CoreEws.number_controller(roll_params)

	self._key_types = {
		time = key_time,
		fov = key_fov,
		fov_text = key_fov_text,
		near_dof = key_near_dof,
		far_dof = key_far_dof,
		roll = roll_params
	}

	self._keys_toolbar:set_enabled(false)
	self._keys:set_enabled(false)
	self:key_types_set_enabled(false)
	self._sizer:add(keys_sizer, 0, 0, "EXPAND")
	self:build_sequence()

	self._time = time

	self._camera_list:connect("EVT_COMMAND_LISTBOX_SELECTED", callback(self, self, "select_camera"), nil)
	self._main_sizer:add(self._sizer, 1, 0, "EXPAND")

	return self._ews_panel
end

function WorldCameraLayer:build_sequence()
	local sequences_sizer = EWS:StaticBoxSizer(self._ews_panel, "VERTICAL", "Sequences")
	local sequence_sizer = EWS:BoxSizer("HORIZONTAL")
	local sequence_toolbar = EWS:ToolBar(self._ews_panel, "", "TB_FLAT,TB_VERTICAL,TB_NODIVIDER")

	sequence_toolbar:add_tool("WC_NEW_SEQUENCE", "Create New", CoreEws.image_path("toolbar\\new_16x16.png"), "Create a new world camera sequence")
	sequence_toolbar:connect("WC_NEW_SEQUENCE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_create_new_sequence"), self._camera_list)
	sequence_toolbar:add_tool("WC_DELETE_SEQUENCE", "Delete", CoreEws.image_path("toolbar\\delete_16x16.png"), "Delete selected world camera sequence")
	sequence_toolbar:connect("WC_DELETE_SEQUENCE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_delete_sequence"), self._camera_list)
	sequence_toolbar:add_tool("WC_TEST_SEQUENCE", "Test", CoreEws.image_path("sequencer\\play_from_start_16x16.png"), "Test selected world camera sequence")
	sequence_toolbar:connect("WC_TEST_SEQUENCE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_test_sequence"), self._camera_list)
	sequence_toolbar:add_tool("WC_STOP_SEQUENCE", "Stop", CoreEws.image_path("sequencer\\stop_16x16.png"), "Stop current test world camera sequence")
	sequence_toolbar:connect("WC_STOP_SEQUENCE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_stop_sequence"), self._camera_list)
	sequence_toolbar:realize()
	sequence_sizer:add(sequence_toolbar, 0, 0, "EXPAND")

	self._sequence_list = EWS:ListBox(self._ews_panel, "", "LB_SINGLE,LB_HSCROLL,LB_NEEDED_SB,LB_SORT")

	sequence_sizer:add(self._sequence_list, 1, 0, "EXPAND")
	self._sequence_list:connect("EVT_COMMAND_LISTBOX_SELECTED", callback(self, self, "on_select_sequence"), nil)
	sequences_sizer:add(sequence_sizer, 0, 0, "EXPAND")

	local cameras_sizer = EWS:BoxSizer("VERTICAL")
	local camera_sequence_lists_sizer = EWS:BoxSizer("HORIZONTAL")
	self._availible_sequence_camera_list = EWS:ListBox(self._ews_panel, "", "LB_SINGLE,LB_HSCROLL,LB_NEEDED_SB,LB_SORT")

	camera_sequence_lists_sizer:add(self._availible_sequence_camera_list, 1, 0, "EXPAND")
	self._availible_sequence_camera_list:connect("EVT_COMMAND_LISTBOX_DOUBLECLICKED", callback(self, self, "on_add_camera_to_sequence"), nil)

	self._sequence_camera_list = EWS:ListBox(self._ews_panel, "", "LB_SINGLE,LB_HSCROLL,LB_NEEDED_SB")

	camera_sequence_lists_sizer:add(self._sequence_camera_list, 1, 0, "EXPAND")
	self._sequence_camera_list:connect("EVT_COMMAND_LISTBOX_SELECTED", callback(self, self, "on_select_sequence_camera"), nil)
	self._sequence_camera_list:connect("EVT_COMMAND_LISTBOX_DOUBLECLICKED", callback(self, self, "on_remove_camera_from_sequence"), nil)

	local spin = EWS:SpinButton(self._ews_panel, "", "SP_VERTICAL")

	camera_sequence_lists_sizer:add(spin, 0, 0, "EXPAND")
	spin:connect("EVT_SCROLL_LINEUP", callback(self, self, "on_move_camera_in_sequence"), -1)
	spin:connect("EVT_SCROLL_LINEDOWN", callback(self, self, "on_move_camera_in_sequence"), 1)
	cameras_sizer:add(camera_sequence_lists_sizer, 0, 0, "EXPAND")

	local camera_sequence_start_sizer = EWS:BoxSizer("HORIZONTAL")

	camera_sequence_start_sizer:add(EWS:StaticText(self._ews_panel, "Start: ", "", ""), 1, 0, "ALIGN_CENTER_VERTICAL")

	local sequence_camera_start = EWS:TextCtrl(self._ews_panel, 0, "", "TE_CENTRE,TE_PROCESS_ENTER")

	camera_sequence_start_sizer:add(sequence_camera_start, 3, 0, "ALIGN_RIGHT,EXPAND")
	sequence_camera_start:connect("EVT_CHAR", callback(nil, _G, "verify_number"), sequence_camera_start)
	sequence_camera_start:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "on_sequence_camera_start"), sequence_camera_start)
	sequence_camera_start:connect("EVT_KILL_FOCUS", callback(self, self, "on_sequence_camera_start"), sequence_camera_start)
	cameras_sizer:add(camera_sequence_start_sizer, 0, 0, "EXPAND")

	local camera_sequence_stop_sizer = EWS:BoxSizer("HORIZONTAL")

	camera_sequence_stop_sizer:add(EWS:StaticText(self._ews_panel, "Stop: ", "", ""), 1, 0, "ALIGN_CENTER_VERTICAL")

	local sequence_camera_stop = EWS:TextCtrl(self._ews_panel, 0, "", "TE_CENTRE,TE_PROCESS_ENTER")

	camera_sequence_stop_sizer:add(sequence_camera_stop, 3, 0, "ALIGN_RIGHT,EXPAND")
	sequence_camera_stop:connect("EVT_CHAR", callback(nil, _G, "verify_number"), sequence_camera_stop)
	sequence_camera_stop:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "on_sequence_camera_stop"), sequence_camera_stop)
	sequence_camera_stop:connect("EVT_KILL_FOCUS", callback(self, self, "on_sequence_camera_stop"), sequence_camera_stop)
	cameras_sizer:add(camera_sequence_stop_sizer, 0, 0, "EXPAND")

	self._camera_sequence_settings = {
		start = sequence_camera_start,
		stop = sequence_camera_stop
	}

	sequences_sizer:add(cameras_sizer, 0, 0, "EXPAND")
	self._sizer:add(sequences_sizer, 0, 0, "EXPAND")
end

function WorldCameraLayer:select_camera()
	local name = self:selected_camera()
	self._current_point = nil

	if name then
		self._current_world_camera = managers.worldcamera:world_camera(name)

		CoreEws.change_entered_number(self._duration_params, self._current_world_camera:duration())
		CoreEws.change_entered_number(self._delay_params, self._current_world_camera:delay())
		CoreEws.change_entered_number(self._dof_paddding_params, self._current_world_camera:dof_padding())
		CoreEws.change_entered_number(self._dof_clamp_params, self._current_world_camera:dof_clamp())
		self._point_list:clear()

		for i, pos in ipairs(self._current_world_camera:get_points()) do
			self._point_list:append(i)
		end

		self._in_acc:set_value(self._current_world_camera:in_acc_string())
		self._out_acc:set_value(self._current_world_camera:out_acc_string())
		self._keys_toolbar:set_enabled(true)
		self._keys:set_enabled(true)
		self:key_types_set_enabled(true)
		self:populate_keys()
	end
end

function WorldCameraLayer:create_new()
	local name = EWS:get_text_from_user(Global.frame_panel, "Enter name for the new camera:", "Create Camera", "new_camera", Vector3(-1, -1, 0), true)

	if name and name ~= "" then
		if managers.worldcamera:all_world_cameras()[name] then
			self:create_new()
		else
			managers.worldcamera:create_world_camera(name)
			self:update_camera_list()

			for i = 0, self._camera_list:nr_items() - 1 do
				if self._camera_list:get_string(i) == name then
					self._camera_list:select_index(i)
				end
			end

			self:select_camera()
		end
	end
end

function WorldCameraLayer:delete_camera()
	local name = self:selected_camera()

	if name then
		local confirm = EWS:message_box(Global.frame_panel, "Delete camera " .. name .. "?", "Worldcamera", "YES_NO,ICON_QUESTION", Vector3(-1, -1, 0))

		if confirm == "NO" then
			return
		end

		managers.worldcamera:remove_world_camera(name)
		self:update_camera_list()

		self._current_world_camera = nil
		self._current_point = nil

		self._point_list:clear()
		self._in_acc:set_value("linear")
		self._out_acc:set_value("linear")
		self._keys_toolbar:set_enabled(false)
		self._keys:set_enabled(false)
		self:key_types_set_enabled(false)
		managers.editor:set_camera_fov(managers.editor:default_camera_fov())
		managers.editor:set_camera_roll(0)
	end
end

function WorldCameraLayer:test_camera()
	local name = self:selected_camera()

	if name then
		managers.editor:sound_check_object_active(false)

		self._test_done_callback = managers.worldcamera:add_world_camera_done_callback(name, callback(self, self, "test_done"))

		managers.worldcamera:play_world_camera(name)
	end
end

function WorldCameraLayer:test_done()
	self:force_editor_state()
	managers.editor:sound_check_object_active(true)

	if self._look_through_camera then
		-- Nothing
	end
end

function WorldCameraLayer:stop_camera()
	managers.worldcamera:stop_world_camera()
	self:force_editor_state()
end

function WorldCameraLayer:select_point()
	local point = self:selected_point()
	local name = self:selected_camera()

	if point and name then
		self._current_point = managers.worldcamera:world_camera(name):get_point(point)
	end
end

function WorldCameraLayer:add_point()
	local name = self:selected_camera()

	if name then
		local cam = managers.editor._vp:camera()

		managers.worldcamera:world_camera(name):add_point(cam:position(), cam:rotation())
		self._point_list:clear()

		for i, point in ipairs(managers.worldcamera:world_camera(name):get_points()) do
			self._point_list:append(i)
		end
	end
end

function WorldCameraLayer:move_point()
	local point = self:selected_point()
	local name = self:selected_camera()

	if point and name then
		local cam = managers.editor._vp:camera()

		managers.worldcamera:world_camera(name):move_point(point, cam:position(), cam:rotation())
	end

	self:select_point()
end

function WorldCameraLayer:delete_point()
	local point = self:selected_point()
	local name = self:selected_camera()

	if point and name then
		managers.worldcamera:world_camera(name):delete_point(point)

		self._current_point = nil

		self._point_list:clear()

		for i, point in ipairs(managers.worldcamera:world_camera(name):get_points()) do
			self._point_list:append(i)
		end
	end
end

function WorldCameraLayer:goto_point()
	local point = self:selected_point()
	local name = self:selected_camera()

	if point and name then
		local p = managers.worldcamera:world_camera(name):get_point(point)
		local rot = Rotation(p.t_pos - p.pos, Vector3(0, 0, 1))

		managers.editor:set_camera(p.pos, rot)
	end
end

function WorldCameraLayer:change_acc(type)
	local name = self:selected_camera()

	if name then
		if type == "in" then
			managers.worldcamera:world_camera(name):set_in_acc(self._in_acc:get_value())
		elseif type == "out" then
			managers.worldcamera:world_camera(name):set_out_acc(self._out_acc:get_value())
		end
	end
end

function WorldCameraLayer:set_duration(params)
	local name = self:selected_camera()

	if name then
		managers.worldcamera:world_camera(name):set_duration(params.value)
	end
end

function WorldCameraLayer:set_delay(params)
	local name = self:selected_camera()

	if name then
		managers.worldcamera:world_camera(name):set_delay(params.value)
	end
end

function WorldCameraLayer:set_dof_padding(params)
	local name = self:selected_camera()

	if name then
		managers.worldcamera:world_camera(name):set_dof_padding(params.value)
	end
end

function WorldCameraLayer:set_dof_clamp(params)
	local name = self:selected_camera()

	if name then
		managers.worldcamera:world_camera(name):set_dof_clamp(params.value)
	end
end

function WorldCameraLayer:update_camera_list()
	self._camera_list:clear()
	self._availible_sequence_camera_list:clear()

	for name, _ in pairs(managers.worldcamera:all_world_cameras()) do
		self._camera_list:append(name)
		self._availible_sequence_camera_list:append(name)
	end
end

function WorldCameraLayer:selected_camera()
	local index = self._camera_list:selected_index()

	if index ~= -1 then
		return self._camera_list:get_string(index)
	end

	return nil
end

function WorldCameraLayer:selected_world_camera()
	local index = self._camera_list:selected_index()

	if index ~= -1 then
		return managers.worldcamera:world_camera(self._camera_list:get_string(index))
	end

	return nil
end

function WorldCameraLayer:selected_point()
	local index = self._point_list:selected_index()

	if index ~= -1 then
		return tonumber(self._point_list:get_string(index))
	end

	return nil
end

function WorldCameraLayer:look_through_camera(data, event)
	self._look_through_camera = self._keys_toolbar:tool_state(event:get_id())

	if not self._look_through_camera then
		managers.editor:set_camera_fov(managers.editor:default_camera_fov())
		managers.editor:set_camera_roll(0)
		managers.worldcamera:stop_dof()
	elseif self._current_world_camera then
		-- Nothing
	end
end

function WorldCameraLayer:set_time(data)
	self._current_time = data.slider:get_value() / self._time_precision
	local floats = math.log10(self._time_precision)

	data.text:set_value(string.format("%." .. floats .. "f", self._current_time))
end

function WorldCameraLayer:add_key()
	local camera = self:selected_world_camera()

	if camera then
		local index = camera:add_key(self._current_time)

		self:populate_keys(index)
	end
end

function WorldCameraLayer:delete_key()
	local camera = self:selected_world_camera()

	if camera then
		local index = tonumber(self._keys:get_value())

		if index == 1 then
			managers.editor:output_info("Won't delete key 1")

			return
		end

		camera:delete_key(tonumber(self._keys:get_value()))
	end

	self:populate_keys()
end

function WorldCameraLayer:select_key()
	self:set_key(tonumber(self._keys:get_value()))
end

function WorldCameraLayer:on_key_time()
	local camera = self:selected_world_camera()

	if camera then
		local old_index = tonumber(self._keys:get_value())
		local new_index = camera:move_key(old_index, tonumber(self._key_types.time:get_value()))

		self:populate_keys(new_index)
	end
end

function WorldCameraLayer:on_key_fov()
	local camera = self:selected_world_camera()

	if camera then
		local key = camera:key(tonumber(self._keys:get_value()))
		key.fov = self._key_types.fov:get_value()

		self._key_types.fov_text:set_value(self._key_types.fov:get_value())
	end
end

function WorldCameraLayer:on_key_near_dof()
	local camera = self:selected_world_camera()

	if camera then
		local key = camera:key(tonumber(self._keys:get_value()))
		local near_dof = self._key_types.near_dof:get_value()

		if near_dof == "" then
			near_dof = 0
		end

		key.near_dof = near_dof
	end
end

function WorldCameraLayer:on_key_far_dof()
	local camera = self:selected_world_camera()

	if camera then
		local key = camera:key(tonumber(self._keys:get_value()))
		local far_dof = self._key_types.far_dof:get_value()

		if far_dof == "" then
			far_dof = 0
		end

		key.far_dof = far_dof
	end
end

function WorldCameraLayer:on_set_roll()
	local camera = self:selected_world_camera()

	if camera then
		local key = camera:key(tonumber(self._keys:get_value()))
		local roll = self._key_types.roll.value
		key.roll = roll
	end
end

function WorldCameraLayer:set_near_dof()
	local camera = self:selected_world_camera()

	if camera then
		local ray = managers.editor:select_unit_by_raycast(managers.slot:get_mask("editor_all"), "body editor")

		if ray and ray.position then
			local dist = (ray.position - managers.editor:camera():position()):length()

			self._key_types.near_dof:set_value(math.round(dist))
		end
	end
end

function WorldCameraLayer:set_far_dof()
	local camera = self:selected_world_camera()

	if camera then
		local ray = managers.editor:select_unit_by_raycast(managers.slot:get_mask("editor_all"), "body editor")

		if ray and ray.position then
			local dist = (ray.position - managers.editor:camera():position()):length()

			self._key_types.far_dof:set_value(math.round(dist))
		end
	end
end

function WorldCameraLayer:populate_keys(index)
	self._keys:clear()

	local camera = self:selected_world_camera()

	if camera then
		for i, key in ipairs(camera:keys()) do
			self._keys:append(i)
		end
	end

	index = index or 1
	local key = camera:key(index)
	local time = key.time
	local fov = key.fov
	local near_dof = key.near_dof
	local far_dof = key.far_dof
	local roll = key.roll

	self._keys:set_value(index or 1)
	self:set_key_values(time, fov, near_dof, far_dof, roll)
end

function WorldCameraLayer:set_key(index)
	local camera = self:selected_world_camera()

	if camera then
		local key = camera:key(index)
		local time = key.time
		local fov = key.fov
		local near_dof = key.near_dof
		local far_dof = key.far_dof
		local roll = key.roll

		self._time:set_value(key.time * self._time_precision)
		self._keys:set_value(index)
		self:set_time({
			slider = self._time,
			text = self._time_text
		})
		self:set_key_values(time, fov, near_dof, far_dof, roll)
	end
end

function WorldCameraLayer:set_key_values(time, fov, near_dof, far_dof, roll)
	for _, ctrl in pairs(self._key_types) do
		(ctrl.number_ctrlr or ctrl):set_enabled(false)
	end

	if fov then
		self._key_types.fov:set_enabled(true)
		self._key_types.fov:set_value(fov)
		self._key_types.fov_text:set_enabled(true)
		self._key_types.fov_text:set_value(fov)
	end

	if near_dof then
		self._key_types.near_dof:set_enabled(true)
		self._key_types.near_dof:change_value(near_dof)
	end

	if far_dof then
		self._key_types.far_dof:set_enabled(true)
		self._key_types.far_dof:change_value(far_dof)
	end

	if roll then
		self._key_types.roll.number_ctrlr:set_enabled(true)
		CoreEws.change_entered_number(self._key_types.roll, roll)
	end

	if time then
		self._key_types.time:set_enabled(true)

		local floats = math.log10(self._time_precision)

		self._key_types.time:change_value(string.format("%." .. floats .. "f", time))
	end
end

function WorldCameraLayer:next_key()
	local camera = self:selected_world_camera()

	if camera then
		local index = camera:next_key(self._current_time)

		self:set_key(index)
	end
end

function WorldCameraLayer:prev_key()
	local camera = self:selected_world_camera()

	if camera then
		local index = camera:prev_key(self._current_time, true)

		self:set_key(index)
	end
end

function WorldCameraLayer:key_types_set_enabled(enabled)
	for _, ctrl in pairs(self._key_types) do
		local c = ctrl.number_ctrlr or ctrl

		c:set_enabled(enabled)
	end
end

function WorldCameraLayer:on_select_sequence()
	self:select_sequence()
end

function WorldCameraLayer:on_create_new_sequence()
	local name = EWS:get_text_from_user(Global.frame_panel, "Enter name for the new sequence:", "Create Sequence", "new_sequence", Vector3(-1, -1, 0), true)

	if name and name ~= "" then
		if managers.worldcamera:all_world_camera_sequences()[name] then
			self:on_create_new_sequence()
		else
			managers.worldcamera:create_world_camera_sequence(name)
			self:update_sequence_list()

			for i = 0, self._sequence_list:nr_items() - 1 do
				if self._sequence_list:get_string(i) == name then
					self._sequence_list:select_index(i)
				end
			end

			self:select_sequence()
		end
	end
end

function WorldCameraLayer:on_delete_sequence()
	local name = self:selected_sequence_name()

	if name then
		managers.worldcamera:remove_world_camera_sequence(name)
		self:update_sequence_list()
		self._sequence_camera_list:clear()
	end
end

function WorldCameraLayer:on_test_sequence()
	local name = self:selected_sequence_name()

	if name then
		managers.worldcamera:play_world_camera_sequence(name)
		managers.editor:sound_check_object_active(false)

		self._sequence_test_done_callback = managers.worldcamera:add_sequence_done_callback(name, callback(self, self, "sequence_test_done"))
	end
end

function WorldCameraLayer:sequence_test_done()
	self:force_editor_state()
	managers.editor:sound_check_object_active(true)
end

function WorldCameraLayer:on_stop_sequence()
	managers.worldcamera:stop_world_camera()
end

function WorldCameraLayer:on_add_camera_to_sequence()
	local name = self:selected_sequence_name()

	if not name then
		return
	end

	local index = self._availible_sequence_camera_list:selected_index()

	if index ~= -1 then
		local i = managers.worldcamera:add_camera_to_sequence(name, self._availible_sequence_camera_list:get_string(index))

		self:update_sequence_camera_list(i - 1)
		self:on_select_sequence_camera()
	end
end

function WorldCameraLayer:on_remove_camera_from_sequence()
	local name = self:selected_sequence_name()

	if not name then
		return
	end

	local index = self._sequence_camera_list:selected_index()

	if index ~= -1 then
		index = index + 1

		managers.worldcamera:remove_camera_from_sequence(name, index)
		self:update_sequence_camera_list()
	end
end

function WorldCameraLayer:on_move_camera_in_sequence(dir)
	local name = self:selected_sequence_name()

	if not name then
		return
	end

	local index = self._sequence_camera_list:selected_index()

	if index ~= -1 then
		index = index + 1
		local camera_sequence_table = managers.worldcamera:remove_camera_from_sequence(name, index)
		local new_index = math.clamp(index + dir, 1, self._sequence_camera_list:nr_items())

		managers.worldcamera:insert_camera_to_sequence(name, camera_sequence_table, new_index)
		self:update_sequence_camera_list()
		self._sequence_camera_list:select_index(new_index - 1)
	end
end

function WorldCameraLayer:on_select_sequence_camera()
	local sequence_camera = self:selected_sequence_camera()

	if sequence_camera then
		self._camera_sequence_settings.start:change_value(string.format("%.4f", sequence_camera.start))
		self._camera_sequence_settings.stop:change_value(string.format("%.4f", sequence_camera.stop))
	end
end

function WorldCameraLayer:on_sequence_camera_start()
	local value = tonumber(self._camera_sequence_settings.start:get_value())
	value = math.clamp(value, 0, 1)

	self._camera_sequence_settings.start:change_value(string.format("%.4f", value))

	local sequence_camera = self:selected_sequence_camera()

	if sequence_camera then
		sequence_camera.start = value
	end
end

function WorldCameraLayer:on_sequence_camera_stop()
	local value = tonumber(self._camera_sequence_settings.stop:get_value())
	value = math.clamp(value, 0, 1)

	self._camera_sequence_settings.stop:change_value(string.format("%.4f", value))

	local sequence_camera = self:selected_sequence_camera()

	if sequence_camera then
		sequence_camera.stop = value
	end
end

function WorldCameraLayer:update_sequence_list()
	self._sequence_list:clear()

	for name, _ in pairs(managers.worldcamera:all_world_camera_sequences()) do
		self._sequence_list:append(name)
	end
end

function WorldCameraLayer:select_sequence()
	local name = self:selected_sequence_name()

	if name then
		self:update_sequence_camera_list()
	end
end

function WorldCameraLayer:selected_sequence_name()
	local index = self._sequence_list:selected_index()

	if index ~= -1 then
		return self._sequence_list:get_string(index)
	end

	return nil
end

function WorldCameraLayer:selected_sequence()
	local index = self._sequence_list:selected_index()

	if index ~= -1 then
		return managers.worldcamera:world_camera_sequence(self._sequence_list:get_string(index))
	end

	return nil
end

function WorldCameraLayer:selected_sequence_camera_name()
	local index = self._sequence_camera_list:selected_index()

	if index ~= -1 then
		return self._sequence_camera_list:get_string(index)
	end

	return nil
end

function WorldCameraLayer:selected_sequence_camera()
	local index = self._sequence_camera_list:selected_index()

	if index ~= -1 then
		index = index + 1
		local sequence = self:selected_sequence()

		if sequence then
			return sequence[index]
		end
	end

	return nil
end

function WorldCameraLayer:update_sequence_camera_list(index)
	self._sequence_camera_list:clear()

	local sequence = self:selected_sequence()

	if not sequence then
		return
	end

	for _, camera in ipairs(sequence) do
		self._sequence_camera_list:append(camera.name)
	end

	if index then
		self._sequence_camera_list:select_index(index)
	end
end

function WorldCameraLayer:deselect()
end

function WorldCameraLayer:add_triggers()
	WorldCameraLayer.super.add_triggers(self)

	local vc = self._editor_data.virtual_controller

	vc:add_trigger(Idstring("rmb"), callback(self, self, "add_point"))
	vc:add_trigger(Idstring("emb"), callback(self, self, "move_point"))
	vc:add_trigger(Idstring("set_world_camera_far_dof"), callback(self, self, "set_far_dof"))
	vc:add_trigger(Idstring("set_world_camera_near_dof"), callback(self, self, "set_near_dof"))
end

function WorldCameraLayer:activate()
	managers.editor:layer("Mission"):hide_all()
	WorldCameraLayer.super.activate(self)
	self:set_gui_visible(true)
end

function WorldCameraLayer:deactivate()
	managers.editor:layer("Mission"):unhide_all()
	WorldCameraLayer.super.deactivate(self)
	self:set_gui_visible(false)
	managers.editor:set_camera_fov(managers.editor:default_camera_fov())
	managers.editor:set_camera_roll(0)
end

function WorldCameraLayer:clear()
	WorldCameraLayer.super.clear(self)

	self._current_world_camera = nil
	self._current_point = nil

	self._point_list:clear()
	self._in_acc:set_value("linear")
	self._out_acc:set_value("linear")
	self._keys_toolbar:set_enabled(false)
	self._keys:set_enabled(false)
	self:key_types_set_enabled(false)
	managers.worldcamera:clear()
	self:update_camera_list()
	self:update_sequence_list()
	self:update_sequence_camera_list()
	managers.editor:set_camera_fov(managers.editor:default_camera_fov())
	managers.editor:set_camera_roll(0)
end

function WorldCameraLayer:get_help(text)
	local t = "\t"
	local n = "\n"
	text = text .. "Create point:        Right mouse btn" .. n
	text = text .. "Move point:          Thumb mouse btn" .. n

	return text
end
