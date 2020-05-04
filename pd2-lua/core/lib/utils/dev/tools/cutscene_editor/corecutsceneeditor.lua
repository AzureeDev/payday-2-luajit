require("core/lib/utils/dev/ews/sequencer/CoreCutsceneSequencerPanel")
require("core/lib/utils/dev/tools/cutscene_editor/CoreCutsceneSettingsDialog")
require("core/lib/utils/dev/tools/cutscene_editor/CoreCutsceneFrameExporterDialog")
require("core/lib/utils/dev/tools/cutscene_editor/CoreCutsceneBatchOptimizerDialog")
require("core/lib/utils/dev/tools/cutscene_editor/CoreCutsceneFootage")
require("core/lib/utils/dev/tools/cutscene_editor/CoreCutsceneEditorProject")
require("core/lib/utils/dev/tools/cutscene_editor/CoreCutsceneOptimizer")
require("core/lib/utils/dev/tools/cutscene_editor/CoreCutsceneMayaExporter")
require("core/lib/utils/dev/tools/cutscene_editor/CoreCutsceneFrameExporter")
require("core/lib/managers/cutscene/CoreCutsceneKeys")
require("core/lib/managers/cutscene/CoreCutsceneKeyCollection")
require("core/lib/managers/cutscene/CoreCutsceneCast")

CoreCutsceneEditor = CoreCutsceneEditor or class()

mixin(CoreCutsceneEditor, CoreCutsceneKeyCollection)

CoreCutsceneEditor.EDITOR_TITLE = "Cutscene Editor"
CoreCutsceneEditor.DEFAULT_CAMERA_FAR_RANGE = 50000

function CoreCutsceneEditor:_all_keys_sorted_by_time()
	local cutscene_keys = table.collect(self._sequencer:key_track():clips(), function (sequencer_key)
		return sequencer_key:metadata()
	end)

	table.sort(cutscene_keys, function (a, b)
		return a:frame() < b:frame()
	end)

	return cutscene_keys
end

local commands = CoreCommandRegistry:new()

commands:add({
	id = "NEW_PROJECT",
	label = "&New Project",
	key = "Ctrl+N",
	help = "Closes the currently open cutscene project so you can start with a blank slate"
})
commands:add({
	id = "OPEN_PROJECT",
	label = "&Open Project...",
	key = "Ctrl+O",
	help = "Opens an existing cutscene project from the database"
})
commands:add({
	id = "SAVE_PROJECT",
	label = "&Save Project",
	key = "Ctrl+S",
	help = "Saves the current project to the database"
})
commands:add({
	id = "SAVE_PROJECT_AS",
	label = "Save Project &As...",
	help = "Saves the current project to the database under a new name"
})
commands:add({
	id = "SHOW_PROJECT_SETTINGS",
	label = "&Project Settings...",
	help = "Displays the Project Settings dialog"
})
commands:add({
	id = "EXPORT_TO_GAME",
	label = "&Export Cutscene to Game...",
	help = "Exports an optimized version of the cutscene that can be used within the game"
})
commands:add({
	id = "EXPORT_TO_MAYA",
	label = "Export Cutscene to &Maya...",
	help = "Exports edited animations for all actors, cameras and locators as a Maya scene"
})
commands:add({
	id = "EXPORT_PLAYBLAST",
	label = "Export &Playblast...",
	help = "Exports a low-quality render of each frame in the cutscene as an image file for use as a reference"
})
commands:add({
	id = "SHOW_BATCH_OPTIMIZER",
	label = "&Batch Export to Game...",
	help = "Displays the Batch Export dialog"
})
commands:add({
	id = "EXIT",
	label = "E&xit",
	help = "Closes the " .. CoreCutsceneEditor.EDITOR_TITLE .. " window"
})
commands:add({
	id = "CUT",
	label = "Cut",
	key = "Ctrl+X",
	help = "Place selected clips on the clipboard. When pasted, the clips will be moved"
})
commands:add({
	id = "COPY",
	label = "Copy",
	key = "Ctrl+C",
	help = "Place selected clips on the clipboard. When pasted, the clips will be duplicated"
})
commands:add({
	id = "PASTE",
	label = "Paste",
	key = "Ctrl+V",
	help = "Paste clipboard contents into the current film track at the playhead position"
})
commands:add({
	id = "DELETE",
	label = "Delete",
	key = "Del",
	help = "Removes selected clips from the sequencer timeline"
})
commands:add({
	id = "SELECT_ALL",
	label = "Select &All",
	key = "Ctrl+A",
	help = "Select all clips and all keys in the sequencer timeline"
})
commands:add({
	id = "SELECT_ALL_ON_CURRENT_TRACK",
	label = "Select All on Current &Track",
	key = "Ctrl+Shift+A",
	help = "Select all clips on the current film track"
})
commands:add({
	id = "DESELECT",
	label = "&Deselect",
	key = "Ctrl+D",
	help = "Deselect all clips and all keys in the sequencer timeline"
})
commands:add({
	id = "CLEANUP_ZOOM_KEYS",
	label = "Cleanup &Zoom Keys",
	help = "Remove all Camera Zoom keys that have no effect from the script track"
})
commands:add({
	id = "CUTSCENE_CAMERA_TOGGLE",
	label = "Use &Cutscene Camera",
	help = "Check to view the scene though the directed cutscene camera"
})
commands:add({
	id = "WIDESCREEN_TOGGLE",
	label = "&Widescreen Aspect Ratio",
	key = "Ctrl+R",
	help = "Check to use 16:9 letterbox format for the directed cutscene camera"
})
commands:add({
	id = "CAST_FINDER_TOGGLE",
	label = "Cast &Finder",
	help = "Visualize cast member positions using debug lines"
})
commands:add({
	id = "CAMERAS_TOGGLE",
	label = "&Cameras",
	help = "Visualize cameras using debug lines"
})
commands:add({
	id = "FOCUS_PLANE_TOGGLE",
	label = "&Focus Planes",
	key = "Ctrl+F",
	help = "Visualize depth of field effects with focus planes"
})
commands:add({
	id = "HIERARCHIES_TOGGLE",
	label = "&Hierarchies",
	help = "Visualize bone hierarchies using debug lines"
})
commands:add({
	id = "PLAY_EVERY_FRAME_TOGGLE",
	label = "Play &Every Frame",
	help = "Check to advance the playhead by exactly one frame instead of the elapsed time since the last update during playback"
})
commands:add({
	id = "INSERT_CLIPS_FROM_SELECTED_FOOTAGE",
	label = "Clips from &Selected Footage",
	help = "Inserts clips from the selected footage track at the current playhead position"
})
commands:add({
	id = "INSERT_AUDIO_FILE",
	label = "&Audio File...",
	help = "Browse for an audio file to insert into the voice-over track at the current playhead position"
})
commands:add({
	image = "sequencer\\loop_16x16.png",
	key = "Ctrl+L",
	help = "Toggle playback looping",
	id = "LOOP_TOGGLE",
	label = "&Loop Playback"
})
commands:add({
	image = "sequencer\\play_16x16.png",
	key = "Ctrl+Space",
	help = "Start or pause playback from the current playhead position",
	id = "PLAY_TOGGLE",
	label = "&Play / Pause"
})
commands:add({
	image = "sequencer\\play_from_start_16x16.png",
	key = "Ctrl+Shift+Space",
	help = "Start playback from the start of the selected region or cutscene",
	id = "PLAY_FROM_START",
	label = "Play from Start"
})
commands:add({
	image = "sequencer\\play_16x16.png",
	key = "Ctrl+Space",
	help = "Start playback from the current playhead position",
	id = "PLAY",
	label = "Play"
})
commands:add({
	image = "sequencer\\pause_16x16.png",
	key = "Ctrl+Space",
	help = "Pause playback at the current playhead position",
	id = "PAUSE",
	label = "Pause"
})
commands:add({
	image = "sequencer\\stop_16x16.png",
	key = "Escape",
	help = "Stop playback and return to the start of the selected region or cutscene",
	id = "STOP",
	label = "&Stop"
})
commands:add({
	image = "sequencer\\go_to_start_16x16.png",
	key = "Ctrl+Up",
	help = "Go to the start of the selection or cutscene",
	id = "GO_TO_START",
	label = "Go to &Start"
})
commands:add({
	image = "sequencer\\go_to_end_16x16.png",
	key = "Ctrl+Down",
	help = "Go to the end of the selection or cutscene",
	id = "GO_TO_END",
	label = "Go to &End"
})
commands:add({
	id = "GO_TO_NEXT_FRAME",
	label = "Go to &Next Frame",
	key = "Ctrl+Right",
	help = "Go to the previous frame"
})
commands:add({
	id = "GO_TO_PREVIOUS_FRAME",
	label = "Go to &Previous Frame",
	key = "Ctrl+Left",
	help = "Go to the next frame"
})
commands:add({
	image = "sequencer\\zoom_in_16x16.png",
	key = "Ctrl++",
	help = "Increase sequencer track zoom level",
	id = "ZOOM_IN",
	label = "Zoom &In"
})
commands:add({
	image = "sequencer\\zoom_out_16x16.png",
	key = "Ctrl+-",
	help = "Decrease sequencer track zoom level",
	id = "ZOOM_OUT",
	label = "Zoom &Out"
})

local cutscene_key_insertion_commands = {}
local skipped_key_types = {
	change_camera = true
}

for _, key_type in ipairs(CoreCutsceneKey:types()) do
	if not skipped_key_types[key_type.ELEMENT_NAME] then
		local key = "INSERT_" .. string.gsub(string.upper(key_type.NAME), " ", "_") .. "_KEY"

		commands:add({
			id = key,
			label = key_type.NAME .. " Key",
			help = "Inserts a " .. string.lower(key_type.NAME) .. " key at the current playhead position"
		})

		cutscene_key_insertion_commands[key] = key_type
	end
end

function CoreCutsceneEditor:init()
	self._cast = core_or_local("CutsceneCast")

	self:_create_viewport()
	self:_create_window():set_visible(true)

	self._project_settings_dialog = core_or_local("CutsceneSettingsDialog", self._window)
end

function CoreCutsceneEditor:_create_viewport()
	assert(self._viewport == nil)
	assert(self._camera == nil)
	assert(self._camera_controller == nil)

	self._viewport = managers.viewport:new_vp(0, 0, 1, 1)
	self._camera = World:create_camera()

	self._camera:set_fov(CoreZoomCameraCutsceneKey.DEFAULT_CAMERA_FOV)
	self._camera:set_near_range(7.5)
	self._camera:set_far_range(self.DEFAULT_CAMERA_FAR_RANGE)
	self._camera:set_width_multiplier(1)
	self._viewport:set_camera(self._camera)

	self._camera_controller = self._viewport:director():make_camera(self._camera, "cutscene_camera")

	self._camera_controller:set_timer(TimerManager:game_animation())
	self._viewport:director():set_camera(self._camera_controller)
end

function CoreCutsceneEditor:camera_attributes()
	if self._player then
		return self._player:camera_attributes()
	else
		local attributes = {
			aspect_ratio = self._camera:aspect_ratio(),
			fov = self._camera:fov(),
			near_range = self._camera:near_range(),
			far_range = self._camera:far_range()
		}

		return attributes
	end
end

function CoreCutsceneEditor:_create_window()
	self._window = EWS:Frame(CoreCutsceneEditor.EDITOR_TITLE, Vector3(100, 500, 0), Vector3(800, 800, 0), "DEFAULT_FRAME_STYLE,FRAME_FLOAT_ON_PARENT", Global.frame)

	self._window:connect("", "EVT_CLOSE_WINDOW", callback(self, self, "_on_exit"), "")
	self._window:connect("", "EVT_ACTIVATE", callback(self, self, "_on_activate"), "")
	self._window:set_icon(CoreEWS.image_path("film_reel_16x16.png"))
	self._window:set_min_size(Vector3(400, 321, 0))

	local function connect_command(command_id, callback_name, callback_data)
		callback_name = callback_name or "_on_" .. string.lower(command_id)
		callback_data = callback_data or ""

		self._window:connect(commands:id(command_id), "EVT_COMMAND_MENU_SELECTED", callback(self, self, callback_name), callback_data)
	end

	connect_command("NEW_PROJECT")
	connect_command("OPEN_PROJECT")
	connect_command("SAVE_PROJECT")
	connect_command("SAVE_PROJECT_AS")
	connect_command("SHOW_PROJECT_SETTINGS")
	connect_command("EXPORT_TO_GAME")
	connect_command("EXPORT_TO_MAYA")
	connect_command("EXPORT_PLAYBLAST")
	connect_command("SHOW_BATCH_OPTIMIZER")
	connect_command("EXIT")
	connect_command("CUT")
	connect_command("COPY")
	connect_command("PASTE")
	connect_command("DELETE")
	connect_command("SELECT_ALL")
	connect_command("SELECT_ALL_ON_CURRENT_TRACK")
	connect_command("DESELECT")
	connect_command("CLEANUP_ZOOM_KEYS")
	connect_command("CUTSCENE_CAMERA_TOGGLE")
	connect_command("WIDESCREEN_TOGGLE")
	connect_command("PLAY_EVERY_FRAME_TOGGLE")
	connect_command("INSERT_CLIPS_FROM_SELECTED_FOOTAGE")
	connect_command("ZOOM_IN")
	connect_command("ZOOM_OUT")
	connect_command("PLAY")
	connect_command("PLAY_TOGGLE")
	connect_command("PLAY_FROM_START")
	connect_command("PAUSE")
	connect_command("STOP")
	connect_command("GO_TO_START")
	connect_command("GO_TO_END")
	connect_command("GO_TO_PREVIOUS_FRAME")
	connect_command("GO_TO_NEXT_FRAME")

	for command, key_type in pairs(cutscene_key_insertion_commands) do
		connect_command(command, "_on_insert_cutscene_key", key_type.ELEMENT_NAME)
	end

	local main_box = EWS:BoxSizer("VERTICAL")

	self._window:set_sizer(main_box)
	self._window:set_menu_bar(self:_create_menu_bar())
	self._window:set_tool_bar(self:_create_tool_bar(self._window))
	self._window:set_status_bar(EWS:StatusBar(self._window))
	self._window:set_status_bar_pane(0)

	local tool_bar_divider_line = EWS:StaticLine(self._window)

	main_box:add(tool_bar_divider_line, 0, 0, "EXPAND")

	local main_area_top_bottom_splitter = EWS:SplitterWindow(self._window)
	self._top_area_splitter = EWS:SplitterWindow(main_area_top_bottom_splitter)
	local bottom_area_left_right_splitter = EWS:SplitterWindow(main_area_top_bottom_splitter)
	local bottom_left_area_top_bottom_splitter = EWS:SplitterWindow(bottom_area_left_right_splitter)

	self:_create_sequencer(self._top_area_splitter)
	self:_create_attribute_panel(self._top_area_splitter)

	local selected_footage_track = self:_create_selected_footage_track(bottom_left_area_top_bottom_splitter)
	local camera_list = self:_create_camera_list(bottom_area_left_right_splitter)
	local footage_list = self:_create_footage_list(bottom_left_area_top_bottom_splitter)

	main_area_top_bottom_splitter:set_minimum_pane_size(143)
	main_area_top_bottom_splitter:set_sash_gravity(1)
	self._top_area_splitter:set_minimum_pane_size(160)
	self._top_area_splitter:set_sash_gravity(1)
	bottom_area_left_right_splitter:set_minimum_pane_size(160)
	bottom_area_left_right_splitter:set_sash_gravity(1)
	bottom_left_area_top_bottom_splitter:connect("EVT_COMMAND_SPLITTER_SASH_POS_CHANGING", function (_, event)
		event:veto()
	end, "")
	main_area_top_bottom_splitter:split_horizontally(self._top_area_splitter, bottom_area_left_right_splitter, 400)
	self._top_area_splitter:split_vertically(self._sequencer_panel, self._attribute_panel, self._window:get_size().x - 190)
	bottom_area_left_right_splitter:split_vertically(bottom_left_area_top_bottom_splitter, camera_list, self._window:get_size().x - 190)
	bottom_left_area_top_bottom_splitter:split_horizontally(selected_footage_track, footage_list, 73)
	main_box:add(main_area_top_bottom_splitter, 1, 0, "EXPAND")
	self:_refresh_attribute_panel()

	return self._window
end

function CoreCutsceneEditor:_create_menu_bar()
	local file_menu = commands:wrap_menu(EWS:Menu(""))

	file_menu:append_command("NEW_PROJECT")
	file_menu:append_command("OPEN_PROJECT")
	file_menu:append_command("SAVE_PROJECT")
	file_menu:append_command("SAVE_PROJECT_AS")
	file_menu:append_separator()
	file_menu:append_command("SHOW_PROJECT_SETTINGS")
	file_menu:append_separator()
	file_menu:append_command("EXPORT_TO_GAME")
	file_menu:append_command("EXPORT_TO_MAYA")
	file_menu:append_command("EXPORT_PLAYBLAST")
	file_menu:append_separator()
	file_menu:append_command("SHOW_BATCH_OPTIMIZER")
	file_menu:append_separator()
	file_menu:append_command("EXIT")

	self._edit_menu = commands:wrap_menu(EWS:Menu(""))

	self._edit_menu:append_command("CUT")
	self._edit_menu:set_enabled("CUT", false)
	self._edit_menu:append_command("COPY")
	self._edit_menu:set_enabled("COPY", false)
	self._edit_menu:append_command("PASTE")
	self._edit_menu:set_enabled("PASTE", false)
	self._edit_menu:append_command("DELETE")
	self._edit_menu:append_separator()
	self._edit_menu:append_command("SELECT_ALL")
	self._edit_menu:append_command("SELECT_ALL_ON_CURRENT_TRACK")
	self._edit_menu:append_command("DESELECT")
	self._edit_menu:append_separator()
	self._edit_menu:append_command("CLEANUP_ZOOM_KEYS")

	self._view_menu = commands:wrap_menu(EWS:Menu(""))

	self._view_menu:append_check_command("CUTSCENE_CAMERA_TOGGLE")
	self._view_menu:append_check_command("WIDESCREEN_TOGGLE")
	self._view_menu:set_checked("WIDESCREEN_TOGGLE", true)
	self._view_menu:append_separator()
	self._view_menu:append_command("ZOOM_IN")
	self._view_menu:append_command("ZOOM_OUT")
	self._view_menu:append_separator()
	self._view_menu:append_check_command("CAST_FINDER_TOGGLE")
	self._view_menu:append_check_command("CAMERAS_TOGGLE")
	self._view_menu:append_check_command("FOCUS_PLANE_TOGGLE")
	self._view_menu:append_check_command("HIERARCHIES_TOGGLE")

	self._transport_menu = commands:wrap_menu(EWS:Menu(""))

	self._transport_menu:append_command("PLAY_TOGGLE")
	self._transport_menu:append_command("PLAY_FROM_START")
	self._transport_menu:append_command("STOP")
	self._transport_menu:append_separator()
	self._transport_menu:append_check_command("LOOP_TOGGLE")
	self._transport_menu:set_enabled("LOOP_TOGGLE", false)
	self._transport_menu:append_check_command("PLAY_EVERY_FRAME_TOGGLE")
	self._transport_menu:append_separator()
	self._transport_menu:append_command("GO_TO_START")
	self._transport_menu:append_command("GO_TO_END")
	self._transport_menu:append_command("GO_TO_NEXT_FRAME")
	self._transport_menu:append_command("GO_TO_PREVIOUS_FRAME")

	self._insert_menu = commands:wrap_menu(EWS:Menu(""))

	self._insert_menu:append_command("INSERT_CLIPS_FROM_SELECTED_FOOTAGE")
	self._insert_menu:set_enabled("INSERT_CLIPS_FROM_SELECTED_FOOTAGE", false)
	self._insert_menu:append_command("INSERT_AUDIO_FILE")
	self._insert_menu:set_enabled("INSERT_AUDIO_FILE", false)
	self._insert_menu:append_separator()

	for label, command in table.sorted_map_iterator(table.remap(cutscene_key_insertion_commands, function (command, key_type)
		return key_type.NAME, command
	end)) do
		self._insert_menu:append_command(command)
	end

	local menu_bar = EWS:MenuBar()

	menu_bar:append(file_menu:wrapped_object(), "&File")
	menu_bar:append(self._edit_menu:wrapped_object(), "&Edit")
	menu_bar:append(self._view_menu:wrapped_object(), "&View")
	menu_bar:append(self._transport_menu:wrapped_object(), "&Transport")
	menu_bar:append(self._insert_menu:wrapped_object(), "&Insert")

	return menu_bar
end

function CoreCutsceneEditor:_create_tool_bar(parent_frame)
	local tool_bar = commands:wrap_tool_bar(EWS:ToolBar(parent_frame, "", "TB_HORIZONTAL,TB_FLAT,TB_NOALIGN"))

	local function add_labelled_field(label, field_text)
		local label = EWS:StaticText(tool_bar:wrapped_object(), label)

		label:set_font_size(6)
		label:set_size(label:get_size():with_y(30):with_x(label:get_size().x + 3))
		tool_bar:add_control(label)

		local field = EWS:StaticText(tool_bar:wrapped_object(), field_text)

		field:set_font_size(12)
		tool_bar:add_control(field)

		return field
	end

	tool_bar:add_separator()
	tool_bar:add_command("PLAY_FROM_START")
	tool_bar:add_command("PLAY")
	tool_bar:add_command("PAUSE")
	tool_bar:add_command("STOP")
	tool_bar:add_separator()
	tool_bar:add_command("GO_TO_START")
	tool_bar:add_command("GO_TO_END")
	tool_bar:add_separator()
	tool_bar:add_command("ZOOM_IN")
	tool_bar:add_command("ZOOM_OUT")
	tool_bar:add_separator()

	self._frame_label = add_labelled_field("FRAME", self:_frame_string_for_frame(0))

	tool_bar:add_separator()

	self._time_code_label = add_labelled_field("TIME", self:_time_code_string_for_frame(0))

	tool_bar:add_separator()
	tool_bar:realize()

	return tool_bar:wrapped_object()
end

function CoreCutsceneEditor:_frame_string_for_frame(frame)
	return string.format("%05i", frame)
end

function CoreCutsceneEditor:_time_code_string_for_frame(frame)
	local function consume_frames(frames_per_unit)
		local whole_units = math.floor(frame / frames_per_unit)
		frame = frame - whole_units * frames_per_unit

		return whole_units
	end

	local hour = consume_frames(3600 * self:frames_per_second())
	local minute = consume_frames(60 * self:frames_per_second())
	local second = consume_frames(self:frames_per_second())

	return string.format("%02i:%02i:%02i:%02i", hour, minute, second, frame)
end

function CoreCutsceneEditor:_create_sequencer(parent_frame)
	self._sequencer_panel = EWS:Panel(parent_frame)
	local panel_sizer = EWS:BoxSizer("VERTICAL")

	self._sequencer_panel:set_background_colour((EWS:get_system_colour("3DSHADOW") * 255):unpack())
	self._sequencer_panel:set_sizer(panel_sizer)

	self._sequencer = CoreCutsceneSequencerPanel:new(self._sequencer_panel)

	self._sequencer:connect("EVT_TRACK_MOUSEWHEEL", callback(self, self, "_on_sequencer_track_mousewheel"), self._sequencer)
	self._sequencer:connect("EVT_SELECTION_CHANGED", callback(self, self, "_on_sequencer_selection_changed"), self._sequencer)
	self._sequencer:connect("EVT_REMOVE_ITEM", callback(self, self, "_on_sequencer_remove_item"), self._sequencer)
	self._sequencer:connect("EVT_DRAG_ITEM", callback(self, self, "_on_sequencer_drag_item"), self._sequencer)
	self._sequencer:connect("EVT_EVALUATE_FRAME_AT_PLAYHEAD", callback(self, self, "_on_sequencer_evaluate_frame_at_playhead"), self._sequencer)
	panel_sizer:add(self._sequencer:panel(), 1, 1, "LEFT,RIGHT,BOTTOM,EXPAND")
end

function CoreCutsceneEditor:_create_attribute_panel(parent_frame)
	self._attribute_panel = EWS:Panel(parent_frame)
	local panel_sizer = EWS:BoxSizer("VERTICAL")

	self._attribute_panel:set_background_colour((EWS:get_system_colour("3DSHADOW") * 255):unpack())
	self._attribute_panel:set_sizer(panel_sizer)

	self._attribute_panel_area = EWS:ScrolledWindow(self._attribute_panel, "", "")

	self._attribute_panel_area:set_background_colour((EWS:get_system_colour("3DFACE") * 255):unpack())
	self:_refresh_attribute_panel()
	panel_sizer:add(self._attribute_panel_area, 1, 1, "LEFT,BOTTOM,EXPAND")
end

function CoreCutsceneEditor:_refresh_attribute_panel()
	self._attribute_panel_area:freeze()
	self._attribute_panel_area:destroy_children()

	local new_sizer = self:_sizer_with_editable_attributes_for_current_context(self._attribute_panel_area)

	if new_sizer then
		if not self._top_area_splitter:is_split() then
			self._top_area_splitter:split_vertically(self._sequencer_panel, self._attribute_panel, self._window:get_size().x - 190)
		end

		self._attribute_panel_area:set_sizer(new_sizer)
		self._attribute_panel_area:fit_inside()
		self._attribute_panel_area:set_scrollbars(Vector3(8, 8, 1), Vector3(1, 1, 1), Vector3(0, 0, 0), false)
	elseif self._top_area_splitter:is_split() then
		self._top_area_splitter:unsplit(self._attribute_panel)
	end

	self._attribute_panel_area:thaw()
end

function CoreCutsceneEditor:_refresh_selected_footage_track()
	local selected_footage = self:_selected_footage()

	self:_display_footage_in_selected_footage_track(selected_footage)

	local selected_clips = self._sequencer:selected_film_clips()
	local clip = #selected_clips == 1 and selected_clips[1] or nil

	if clip and clip.start_time_in_source and clip.end_time_in_source and clip:start_time_in_source() < clip:end_time_in_source() then
		self._selected_footage_track_region:set_range(clip:start_time_in_source(), clip:end_time_in_source())
		self._selected_footage_track_region:set_visible(true)
	else
		self._selected_footage_track_region:set_visible(false)
	end

	local camera_index = clip and clip:metadata().camera_index and clip:metadata():camera_index() or nil

	if camera_index then
		self._camera_list_ctrl:set_item_selected(camera_index - 1, true)
	else
		for _, item in ipairs(self._camera_list_ctrl:selected_items()) do
			self._camera_list_ctrl:set_item_selected(item, false)
		end
	end
end

function CoreCutsceneEditor:_selected_footage()
	local selected_clips = self._sequencer:selected_film_clips()

	if not table.empty(selected_clips) then
		local selected_clip_footages = table.list_union(table.collect(selected_clips, function (clip)
			return clip:metadata() and clip:metadata().footage and clip:metadata():footage() or nil
		end))

		return #selected_clip_footages == 1 and selected_clip_footages[1] or nil
	else
		local selected_item_index = self._footage_list_ctrl:selected_item()

		return selected_item_index >= 0 and self._footage_list_ctrl:get_item_data(selected_item_index)
	end
end

function CoreCutsceneEditor:_display_footage_in_selected_footage_track(footage)
	if footage ~= self._selected_footage_track_displayed_footage then
		self._selected_footage_track:remove_all_clips()
		self._camera_list_ctrl:delete_all_items()

		if footage and footage.add_clips_to_track and footage.add_cameras_to_list_ctrl then
			footage:add_clips_to_track(self._selected_footage_track)
			footage:add_cameras_to_list_ctrl(self._camera_list_ctrl)
		end

		self._selected_footage_track_displayed_footage = footage
	end
end

function CoreCutsceneEditor:_sizer_with_editable_attributes_for_current_context(parent_frame)
	local selected_keys = self._sequencer:selected_keys()
	local displayed_item = (#selected_keys == 1 and selected_keys[1] or responder(nil)):metadata()

	if displayed_item and displayed_item.populate_sizer_with_editable_attributes then
		local sizer = EWS:BoxSizer("VERTICAL")
		local headline = EWS:StaticText(parent_frame, displayed_item:type_name())

		headline:set_font_size(10)
		sizer:add(headline, 0, 5, "ALL,EXPAND")

		local line = EWS:StaticLine(parent_frame)

		sizer:add(line, 0, 0, "EXPAND")
		displayed_item:populate_sizer_with_editable_attributes(sizer, parent_frame)

		return sizer
	end
end

function CoreCutsceneEditor:_create_selected_footage_track(parent_frame)
	local panel = EWS:Panel(parent_frame)
	local panel_sizer = EWS:BoxSizer("VERTICAL")

	panel:set_background_colour((EWS:get_system_colour("3DSHADOW") * 255):unpack())
	panel:set_sizer(panel_sizer)

	self._selected_footage_track_scrolled_area = EWS:ScrolledWindow(panel, "", "HSCROLL,NO_BORDER,ALWAYS_SHOW_SB")
	local scrolled_area_sizer = EWS:BoxSizer("VERTICAL")
	self._selected_footage_track = EWS:SequencerTrack(self._selected_footage_track_scrolled_area)
	self._selected_footage_track_region = self._selected_footage_track:add_ornament(EWS:SequencerRangeOrnament())

	self._selected_footage_track_region:set_visible(false)
	self._selected_footage_track_region:set_colour(EWS:get_system_colour("HIGHLIGHT"):unpack())
	self._selected_footage_track_region:set_fill_style("FDIAGONAL_HATCH")
	panel_sizer:add(self._selected_footage_track_scrolled_area, 1, 1, "ALL,EXPAND")
	self._selected_footage_track_scrolled_area:set_sizer(scrolled_area_sizer)
	self._selected_footage_track_scrolled_area:set_scrollbars(Vector3(1, 1, 1), Vector3(1, 1, 1), Vector3(0, 0, 0), false)
	self._selected_footage_track:set_units(100, 500)
	self._selected_footage_track:set_background_colour(self._sequencer:_track_background_colour(false):unpack())
	self._selected_footage_track:set_icon_bitmap(CoreEWS.image_path("sequencer\\track_icon_selected.bmp"), 11)
	self._selected_footage_track:connect("EVT_LEFT_UP", callback(self, self, "_on_selected_footage_track_mouse_left_up"), self._selected_footage_track)
	self._selected_footage_track:connect("EVT_MOUSEWHEEL", callback(self, self, "_on_track_mousewheel"), self._selected_footage_track)
	scrolled_area_sizer:add(self._selected_footage_track, 0, 0, "EXPAND")

	return panel
end

function CoreCutsceneEditor:_create_footage_list(parent_frame)
	self._footage_list_ctrl = EWS:ListCtrl(parent_frame, "", "LC_LIST")
	local image_list = EWS:ImageList(16, 16)
	self._reel_icon = image_list:add(CoreEWS.image_path("film_reel_16x16.png"))
	self._optimized_reel_icon = image_list:add(CoreEWS.image_path("film_reel_bw_16x16.png"))

	self._footage_list_ctrl:set_image_list(image_list)
	self:_refresh_footage_list()
	self._footage_list_ctrl:connect("EVT_COMMAND_LIST_ITEM_SELECTED", callback(self, self, "_on_footage_selection_changed"), self._footage_list_ctrl)
	self._footage_list_ctrl:connect("EVT_COMMAND_LIST_ITEM_DESELECTED", callback(self, self, "_on_footage_selection_changed"), self._footage_list_ctrl)

	return self._footage_list_ctrl
end

function CoreCutsceneEditor:_refresh_footage_list()
	self._footage_list_ctrl:freeze()
	self._footage_list_ctrl:clear_all()

	local cutscene_names = managers.cutscene:get_cutscene_names()
	local optimized_cutscene_names = table.find_all_values(cutscene_names, function (name)
		return managers.cutscene:get_cutscene(name):is_optimized()
	end)
	local unoptimized_cutscene_names = table.find_all_values(cutscene_names, function (name)
		return not managers.cutscene:get_cutscene(name):is_optimized()
	end)

	table.sort(unoptimized_cutscene_names)
	table.sort(optimized_cutscene_names)

	local function add_cutscene_footage(name, icon_id)
		local cutscene = managers.cutscene:get_cutscene(name)

		if cutscene:is_valid() then
			local item = self._footage_list_ctrl:append_item(name)

			self._footage_list_ctrl:set_item_image(item, icon_id)
			self._footage_list_ctrl:set_item_data(item, core_or_local("CutsceneFootage", cutscene))
		end
	end

	for _, name in ipairs(optimized_cutscene_names) do
		add_cutscene_footage(name, self._optimized_reel_icon)
	end

	for _, name in ipairs(unoptimized_cutscene_names) do
		add_cutscene_footage(name, self._reel_icon)
	end

	self._footage_list_ctrl:thaw()
end

function CoreCutsceneEditor:_evaluated_track()
	return self._sequencer:active_film_track()
end

function CoreCutsceneEditor:_evaluate_current_frame()
	local frame = self:playhead_position()

	self._frame_label:set_label(self:_frame_string_for_frame(frame))
	self._time_code_label:set_label(self:_time_code_string_for_frame(frame))

	if self:_evaluated_track() then
		local clip = self:_evaluated_track():clip_at_time(frame)

		self:_evaluate_clip_at_frame(clip, frame)
	end

	self:_evaluate_editor_cutscene_keys_for_frame(frame)
end

function CoreCutsceneEditor:_evaluate_editor_cutscene_keys_for_frame(frame)
	local time = frame / self:frames_per_second()
	self._last_evaluated_time = self._last_evaluated_time or 0

	if self._last_evaluated_time == 0 and time > 0 then
		self._last_evaluated_time = -1
	end

	for key in self:keys_between(self._last_evaluated_time, time) do
		local is_valid = key:is_valid()
		local can_evaluate = key:can_evaluate_with_player(self._player)

		if not is_valid then
			cat_print("debug", key:type_name() .. " Key is invalid. Skipped.")
		elseif not can_evaluate then
			cat_print("debug", key:type_name() .. " Key could not evaluate. Skipped. (Is there a clip below it?)")
		else
			key:play(self._player, time <= self._last_evaluated_time, false)
		end
	end

	for key in self:keys_to_update(time) do
		if key:is_valid() and key:can_evaluate_with_player(self._player) then
			key:update(self._player, time - key:time())
		end
	end

	self._last_evaluated_time = time
end

function CoreCutsceneEditor:_evaluate_clip_at_frame(clip, frame)
	if clip then
		local cutscene_metadata = clip:metadata()

		if cutscene_metadata then
			local frame_offset_in_clip = frame - clip:start_time() + clip:start_time_in_source()

			self:_evaluate_cutscene_frame(cutscene_metadata:footage()._cutscene, cutscene_metadata:camera(), frame_offset_in_clip)
		end
	end
end

function CoreCutsceneEditor:_create_cutscene_player(cutscene)
	local player = core_or_local("CutscenePlayer", cutscene, self._viewport, self._cast)

	player:set_key_handler(self)
	player:prime()

	for cutscene_key in self:keys() do
		cutscene_key:prime(player)
	end

	player:set_viewport_enabled(self._view_menu:is_checked(commands:id("CUTSCENE_CAMERA_TOGGLE")))
	player:set_widescreen(self._view_menu:is_checked(commands:id("WIDESCREEN_TOGGLE")))

	return player
end

function CoreCutsceneEditor:_evaluate_cutscene_frame(cutscene, camera, frame)
	if self._player == nil then
		self._player = self:_create_cutscene_player(cutscene)
	elseif self._player:cutscene_name() ~= cutscene:name() then
		self._player:destroy()

		self._player = self:_create_cutscene_player(cutscene)
	end

	self._player:set_camera(camera)
	self._player:seek(frame / cutscene:frames_per_second())
end

function CoreCutsceneEditor:_create_camera_list(parent_frame)
	self._camera_list_ctrl = EWS:ListCtrl(parent_frame, "", "LC_LIST")

	self._camera_list_ctrl:set_image_list(self:_camera_icons_image_list())

	return self._camera_list_ctrl
end

function CoreCutsceneEditor:_camera_icons_image_list()
	if self.__camera_icons_image_list == nil then
		self.__camera_icons_image_list = EWS:ImageList(16, 16)
		local camera_icon_base_path = CoreEWS.image_path("sequencer\\clip_icon_camera_")

		for i = 0, 30 do
			self.__camera_icons_image_list:add(camera_icon_base_path .. string.format("%02i", i) .. ".png")
		end
	end

	return self.__camera_icons_image_list
end

function CoreCutsceneEditor:_camera_icon_index(icon_index)
	if icon_index < 0 or self:_camera_icons_image_list():image_count() <= icon_index then
		return 0
	else
		return icon_index
	end
end

function CoreCutsceneEditor:cutscene_camera_enabled()
	return self._view_menu:is_checked(commands:id("CUTSCENE_CAMERA_TOGGLE"))
end

function CoreCutsceneEditor:set_cutscene_camera_enabled(enabled)
	self._view_menu:set_checked(commands:id("CUTSCENE_CAMERA_TOGGLE"), enabled)
	self:_on_cutscene_camera_toggle()
end

function CoreCutsceneEditor:widescreen_enabled()
	return self._view_menu:is_checked(commands:id("WIDESCREEN_TOGGLE"))
end

function CoreCutsceneEditor:set_widescreen_enabled(enabled)
	self._view_menu:set_checked(commands:id("WIDESCREEN_TOGGLE"), enabled)
	self:_on_widescreen_toggle()
end

function CoreCutsceneEditor:load_project(project)
	self:_set_current_project(project)
	self:revert_to_saved()
end

function CoreCutsceneEditor:save_project()
	if self._current_project then
		local settings = {
			export_type = self._project_settings_dialog:export_type(),
			animation_patches = self._project_settings_dialog:unit_animation_patches()
		}

		self._current_project:save(self:_serialized_audio_clips(), self:_serialized_film_clips(), self:_serialized_cutscene_keys(), settings)
	end
end

function CoreCutsceneEditor:_serialized_audio_clips()
	local clips = {}

	for _, clip in ipairs(self._sequencer:audio_track():clips()) do
		local serialized_data = {
			offset = clip:start_time(),
			sound = clip:metadata()
		}

		assert(type(serialized_data.sound) == "string", "Audio clip metadata is expected to be the sound: \"bank/cue\".")
		table.insert(clips, serialized_data)
	end

	table.sort(clips, function (a, b)
		return a.offset < b.offset
	end)

	return clips
end

function CoreCutsceneEditor:_serialized_film_clips()
	local clips = {}

	for index, track in ipairs(self._sequencer:film_tracks()) do
		for _, clip in ipairs(track:clips()) do
			if clip:metadata() then
				local serialized_data = {
					track_index = index,
					offset = clip:start_time(),
					cutscene = clip:metadata():footage():name(),
					from = clip:start_time_in_source(),
					to = clip:end_time_in_source(),
					camera = clip:metadata():camera()
				}

				table.insert(clips, serialized_data)
			end
		end
	end

	table.sort(clips, function (a, b)
		return a.offset < b.offset
	end)

	return clips
end

function CoreCutsceneEditor:_serialized_cutscene_keys()
	return table.collect(self._sequencer:key_track():clips(), function (sequencer_key)
		return sequencer_key:metadata()
	end)
end

function CoreCutsceneEditor:_all_controlled_unit_types(include_cameras)
	local unit_types = {}

	for _, clip in ipairs(self._sequencer:film_clips()) do
		for unit_name, unit_type in pairs(clip:metadata():footage()._cutscene:controlled_unit_types()) do
			if include_cameras or not string.begins(unit_name, "camera") then
				unit_types[unit_name] = unit_type
			end
		end
	end

	return unit_types
end

function CoreCutsceneEditor:_set_current_project(project)
	self._current_project = project
	local title = self._current_project and string.format("%s - %s", self:project_name(), CoreCutsceneEditor.EDITOR_TITLE) or CoreCutsceneEditor.EDITOR_TITLE

	self._window:set_title(title)
end

function CoreCutsceneEditor:project_name()
	return self._current_project and self._current_project:name() or "untitled"
end

function CoreCutsceneEditor:revert_to_saved()
	self._sequencer:freeze()
	self._sequencer:remove_all_items()

	if self._current_project then
		for _, clip in ipairs(self._current_project:audio_clips()) do
			self._sequencer:add_audio_clip(clip.offset, clip.sound)
		end

		local unique_cutscene_ids = {}

		for _, clip in ipairs(self._current_project:film_clips()) do
			self._sequencer:add_film_clip(clip.track_index, clip.offset, clip.cutscene, clip.from, clip.to, clip.camera)

			unique_cutscene_ids[clip.cutscene] = true
		end

		for _, cutscene_name in ipairs(managers.cutscene:get_cutscene_names()) do
			local cutscene = managers.cutscene:get_cutscene(cutscene_name)

			if cutscene then
				self._cast:prime(cutscene)
			end
		end

		for _, key in ipairs(self._current_project:cutscene_keys(self)) do
			self:_monkey_patch_cutscene_key(key)
			self._sequencer:add_cutscene_key(key)
		end

		self._project_settings_dialog:populate_from_project(self._current_project)
	end

	self._sequencer:thaw()
	self:_evaluate_current_frame()
end

function CoreCutsceneEditor:frames_per_second()
	return 30
end

function CoreCutsceneEditor:playhead_position()
	return self._sequencer:playhead_position()
end

function CoreCutsceneEditor:set_playhead_position(time)
	self._sequencer:set_playhead_position(time)
end

function CoreCutsceneEditor:zoom_around(time, offset_in_window, delta)
	local new_pixels_per_division = self._sequencer:pixels_per_division() + delta

	if new_pixels_per_division >= 25 and new_pixels_per_division < 12000 then
		self._sequencer:zoom_around(time, offset_in_window, delta)
		self._selected_footage_track_scrolled_area:freeze()
		self._selected_footage_track:set_units_from_ruler(self._sequencer:ruler())

		local scroll_offset = self._selected_footage_track:units_to_pixels(time) - offset_in_window

		self._selected_footage_track_scrolled_area:scroll(Vector3(scroll_offset / self._selected_footage_track_scrolled_area:scroll_pixels_per_unit().x, -1, 0))
		self._selected_footage_track_scrolled_area:thaw()
	end
end

function CoreCutsceneEditor:zoom_around_playhead(multiplier)
	multiplier = multiplier or 1
	local time = self:playhead_position()
	local offset_in_window = self._sequencer:panel():get_size().x / 2
	local delta = self._sequencer:ruler():pixels_per_major_division() / self._sequencer:ruler():subdivision_count()

	self:zoom_around(time, offset_in_window, delta * multiplier)
end

function CoreCutsceneEditor:set_position(newpos)
	self._window:set_position(newpos)
end

function CoreCutsceneEditor:enqueue_update_action(callback_func)
	self._enqueued_update_actions = self._enqueued_update_actions or {}

	table.insert(self._enqueued_update_actions, 1, callback_func)
end

function CoreCutsceneEditor:_process_enqueued_update_actions()
	if self._enqueued_update_actions then
		local func = table.remove(self._enqueued_update_actions)

		if func == nil then
			self._enqueued_update_actions = nil
		else
			func()
		end
	end
end

function CoreCutsceneEditor:refresh_player()
	if self._player then
		self._player:refresh()
	end
end

function CoreCutsceneEditor:update(time, delta_time)
	if self._modal_window then
		if self._modal_window:update(time, delta_time) then
			self._modal_window = nil

			self._window:set_enabled(true)
			self._window:set_focus()
		end
	else
		self:_process_debug_key_commands(time, delta_time)
		self:_process_enqueued_update_actions()
		self._sequencer:update()

		if self._playing then
			self._frame_time = self._frame_time or 0
			self._frame_time = self._frame_time + TimerManager:game_animation():delta_time()

			if self._frame_time > 1 / self:frames_per_second() then
				local frames_to_advance = math.floor(self._frame_time * self:frames_per_second())

				self:set_playhead_position(self:playhead_position() + (self._play_every_frame and 1 or frames_to_advance))

				self._frame_time = self._frame_time - frames_to_advance / self:frames_per_second()
			end
		else
			self._frame_time = nil
		end

		local playhead_time = self:playhead_position() / self:frames_per_second()

		for key in self:keys_to_update(playhead_time) do
			if key:is_valid() and key:can_evaluate_with_player(self._player) then
				key:update(self._player, playhead_time - key:time())
			end
		end

		self:refresh_player()

		if managers.viewport and managers.DOF and (not self._viewport or not self._viewport:active()) then
			local current_camera = managers.viewport:first_active_viewport():camera()
			local far_range = current_camera and current_camera:far_range() or self.DEFAULT_CAMERA_FAR_RANGE

			managers.DOF:feed_dof(0, 0, far_range, far_range)
		end
	end
end

function CoreCutsceneEditor:end_update(time, delta_time)
	if self._modal_window then
		if self._modal_window.end_update then
			self._modal_window:end_update(time, delta_time)
		end
	else
		if self._view_menu:is_checked(commands:id("CAST_FINDER_TOGGLE")) and (self._player == nil or not self._player:is_viewport_enabled()) then
			self:_draw_cast_finder()
		end

		if self._view_menu:is_checked(commands:id("CAMERAS_TOGGLE")) then
			self:_draw_cameras()
		end

		if self._view_menu:is_checked(commands:id("FOCUS_PLANE_TOGGLE")) then
			self:_draw_focus_planes()
		end

		if self._view_menu:is_checked(commands:id("HIERARCHIES_TOGGLE")) then
			self:_draw_hierarchies()
		end

		local selected_items = self._sequencer:selected_keys()
		local selected_item = (#selected_items == 1 and selected_items[1] or responder(nil)):metadata()

		if selected_item and selected_item.update_gui then
			selected_item:update_gui(time, delta_time, self._player)
		end
	end
end

function CoreCutsceneEditor:close()
	for cutscene_key in self:keys() do
		cutscene_key:unload(self._player)
	end

	if self._player then
		self._player:destroy()

		self._player = nil
	end

	if alive(self._viewport) then
		self._viewport:director():release_camera()
		self._viewport:destroy()
	end

	self._viewport = nil

	if alive(self._camera) then
		World:delete_camera(self._camera)
	end

	self._camera = nil

	if self._project_settings_dialog then
		self._project_settings_dialog:destroy()

		self._project_settings_dialog = nil
	end

	self._cast:unload()
	self._window:destroy()
end

function CoreCutsceneEditor:_process_debug_key_commands(time, delta_time)
	if EWS:get_key_state("K_SHIFT") and EWS:get_key_state("K_CONTROL") then
		local delta = 0

		if EWS:get_key_state("K_NUMPAD_SUBTRACT") then
			delta = -0.0016666666666666668
		elseif EWS:get_key_state("K_NUMPAD_ADD") then
			delta = 0.0016666666666666668
		end

		self._player_seek_offset = (self._player_seek_offset or 0) + delta
	elseif self._player_seek_offset then
		self._player_seek_offset = false
	end

	if self._player and self._player_seek_offset ~= nil and self:_evaluated_track() then
		local frame = self:playhead_position()
		local clip = self:_evaluated_track():clip_at_time(frame)
		local frame_offset_in_clip = frame - clip:start_time() + clip:start_time_in_source()

		self._player:seek(frame_offset_in_clip / 30 + (self._player_seek_offset or 0))
	end

	if self._player_seek_offset == false then
		self._player_seek_offset = nil
	end
end

function CoreCutsceneEditor:_on_exit()
	local choice = EWS:MessageDialog(self._window, "Do you want to save the current project before closing?", "Save Changes?", "YES_NO,CANCEL,YES_DEFAULT,ICON_EXCLAMATION"):show_modal()

	if choice == "ID_YES" then
		if not self:_on_save_project() then
			return false
		end
	elseif choice == "ID_CANCEL" then
		return false
	end

	managers.toolhub:close(CoreCutsceneEditor.EDITOR_TITLE)

	return true
end

function CoreCutsceneEditor:_on_activate(data, event)
	if event:get_active() then
		if managers.subtitle then
			managers.subtitle:set_enabled(true)
			managers.subtitle:set_visible(true)
		end

		if managers.editor then
			managers.editor:change_layer_notebook("Cutscene")
		end
	end

	event:skip()
end

function CoreCutsceneEditor:_on_new_project()
	if self:_on_exit() then
		managers.toolhub:open(CoreCutsceneEditor.EDITOR_TITLE)
	end
end

function CoreCutsceneEditor:_on_open_project()
	local path = managers.database:open_file_dialog(self._window, "Cutscene Project (*.cutscene_project)|*.cutscene_project")

	if path then
		local project = core_or_local("CutsceneEditorProject")

		project:set_path(path)
		self:load_project(project)
	end
end

function CoreCutsceneEditor:_on_save_project()
	if self._current_project then
		self:save_project()

		return true
	else
		return self:_on_save_project_as()
	end
end

function CoreCutsceneEditor:_on_save_project_as()
	local path = managers.database:save_file_dialog(self._window, "Cutscene Project (*.cutscene_project)|*.cutscene_project")

	if path then
		local project = core_or_local("CutsceneEditorProject")

		project:set_path(path)
		self:_set_current_project(project)
		self:save_project()
	end

	return path ~= nil
end

function CoreCutsceneEditor:_on_show_project_settings()
	self._project_settings_dialog:set_unit_types(self:_all_controlled_unit_types(false))
	self._project_settings_dialog:show()
end

function CoreCutsceneEditor:_on_export_to_game()
	local optimized_cutscene_name = self:_request_asset_name_from_user("cutscene", "optimized_" .. self:project_name())

	if optimized_cutscene_name == nil then
		return
	end

	local optimizer = core_or_local("CutsceneOptimizer")

	optimizer:set_compression_enabled("win32", self._project_settings_dialog:export_type() == "in_game_use")

	for _, clip in ipairs(self:_evaluated_track():clips()) do
		optimizer:add_clip(clip)
	end

	for key in self:keys() do
		optimizer:add_key(key)
	end

	for unit_name, patches in pairs(self._project_settings_dialog:unit_animation_patches()) do
		for animatable_set, animation in pairs(patches or {}) do
			optimizer:add_animation_patch(unit_name, animatable_set, animation)
		end
	end

	if optimizer:is_valid() then
		if self._player then
			self._player:destroy()

			self._player = nil
		end

		optimizer:export_to_database(optimized_cutscene_name)
		self:_refresh_footage_list()
	else
		local message = string.join("\n    ", table.list_add({
			"Unable to export optimized cutscene to the game."
		}, optimizer:problems()))

		EWS:MessageDialog(self._window, message, "Export Failed", "OK,ICON_ERROR"):show_modal()
	end
end

function CoreCutsceneEditor:_on_export_to_maya()
	local clips_on_active_track = self:_evaluated_track() and self:_evaluated_track():clips() or {}
	local start_frame = 0
	local end_frame = table.inject(clips_on_active_track, 0, function (final_frame, clip)
		return math.max(final_frame, clip:end_time())
	end)

	if end_frame - start_frame == 0 then
		EWS:MessageDialog(self._window, "The active film track does not contain any clips.", "Nothing to Export", "OK,ICON_EXCLAMATION"):show_modal()

		return
	end

	local output_path = self:_request_output_maya_ascii_file_from_user()

	if output_path == nil then
		return
	end

	local exporter = core_or_local("CutsceneMayaExporter", self._window, self, start_frame, end_frame, output_path)

	for _, clip in ipairs(clips_on_active_track) do
		local cutscene = clip.metadata and clip:metadata() and clip:metadata().footage and clip:metadata():footage()._cutscene

		for unit_name, unit in pairs(self._cast:_actor_units_in_cutscene(cutscene)) do
			exporter:add_unit(unit_name, unit)
		end
	end

	exporter:begin()

	self._modal_window = exporter
end

function CoreCutsceneEditor:_on_export_playblast()
	local clips_on_active_track = self:_evaluated_track() and self:_evaluated_track():clips() or {}
	local start_frame = 0
	local end_frame = table.inject(clips_on_active_track, 0, function (final_frame, clip)
		return math.max(final_frame, clip:end_time())
	end)

	if end_frame - start_frame == 0 then
		EWS:MessageDialog(self._window, "The active film track does not contain any clips.", "Nothing to Export", "OK,ICON_EXCLAMATION"):show_modal()

		return
	end

	self._window:set_enabled(false)

	self._modal_window = core_or_local("CutsceneFrameExporterDialog", self, self._export_playblast, self._window, self:project_name(), start_frame, end_frame)
end

function CoreCutsceneEditor:_export_playblast(start_frame, end_frame, folder_name)
	local exporter = core_or_local("CutsceneFrameExporter", self._window, self, start_frame, end_frame, folder_name)

	exporter:begin()

	self._modal_window = exporter
end

function CoreCutsceneEditor:_on_show_batch_optimizer()
	self._window:set_enabled(false)

	self._modal_window = core_or_local("CutsceneBatchOptimizerDialog", self._window, ProjectDatabase)
end

function CoreCutsceneEditor:_request_asset_name_from_user(asset_db_type, default_name, duplicate_name_check_func)
	local asset_type = string.pretty(asset_db_type)
	local asset_type_capitalized = string.capitalize(asset_type)
	local asset_name = EWS:get_text_from_user(self._window, "Enter a name for the " .. asset_type .. ":", asset_type_capitalized .. " Name", default_name, Vector3(-1, -1, 0), true)

	if asset_name == "" then
		asset_name = nil
	end

	if asset_name then
		if string.len(asset_name) <= 3 then
			EWS:MessageDialog(self._window, "The " .. asset_type .. " name is too short.", "Invalid " .. asset_type_capitalized .. " Name", "OK,ICON_EXCLAMATION"):show_modal()

			return self:_request_asset_name_from_user(asset_db_type, default_name, duplicate_name_check_func)
		elseif string.match(asset_name, "[a-z_0-9]+") ~= asset_name then
			EWS:MessageDialog(self._window, "The " .. asset_type .. " name may only contain lower-case letters, numbers and underscores.", "Invalid " .. asset_type_capitalized .. " Name", "OK,ICON_EXCLAMATION"):show_modal()

			return self:_request_asset_name_from_user(asset_db_type, default_name, duplicate_name_check_func)
		else
			duplicate_name_check_func = duplicate_name_check_func or function (name)
				return ProjectDatabase:has(asset_db_type, name)
			end

			if duplicate_name_check_func(asset_name) and EWS:MessageDialog(self._window, "A " .. asset_type .. " with that name already exists. Do you want to replace it?", "Replace Existing?", "YES_NO,NO_DEFAULT,ICON_EXCLAMATION"):show_modal() == "ID_NO" then
				return self:_request_asset_name_from_user(asset_db_type, default_name, duplicate_name_check_func)
			end
		end
	end

	return asset_name
end

function CoreCutsceneEditor:_request_output_maya_ascii_file_from_user()
	return self:_request_output_file_from_user("Export Cutscene to Maya", "mayaAscii (*.ma)|*.ma", nil, self:project_name() .. ".ma")
end

function CoreCutsceneEditor:_request_output_file_from_user(message, wildcard, default_dir, default_file)
	local dialog = EWS:FileDialog(self._window, message, default_dir or "", default_file or "", assert(wildcard, "Must supply a wildcard spec. Check wxWidgets docs."), "SAVE,OVERWRITE_PROMPT")

	return dialog:show_modal() and dialog:get_path() or nil
end

function CoreCutsceneEditor:_project_db_type()
	local project_class = get_core_or_local("CutsceneEditorProject")

	return project_class and project_class.ELEMENT_NAME or "cutscene_project"
end

function CoreCutsceneEditor:_get_clip_bounds(clips)
	if #clips > 0 then
		local earliest_time = math.huge
		local latest_time = -math.huge

		for _, clip in ipairs(clips) do
			earliest_time = math.min(earliest_time, clip:start_time())
			latest_time = math.max(latest_time, clip:end_time())
		end

		return earliest_time, latest_time
	end

	return nil, nil
end

function CoreCutsceneEditor:mark_items_on_clipboard_as_cut(style_as_cut)
	self._sequencer:freeze()

	self._clipboard_cut_items = style_as_cut and {} or nil

	for _, item in ipairs(self._clipboard or {}) do
		item:set_fill_style(style_as_cut and "CROSSDIAG_HATCH" or "SOLID")

		if style_as_cut then
			table.insert(self._clipboard_cut_items, item)
		end
	end

	self._sequencer:thaw()
end

function CoreCutsceneEditor:_on_cut()
	self._sequencer:freeze()
	self:mark_items_on_clipboard_as_cut(false)

	self._clipboard = self._sequencer:selected_items()

	self._edit_menu:set_enabled(commands:id("PASTE"), true)
	self:mark_items_on_clipboard_as_cut(true)
	self._sequencer:thaw()
end

function CoreCutsceneEditor:_on_copy()
	self:mark_items_on_clipboard_as_cut(false)

	self._clipboard = self._sequencer:selected_items()

	self._edit_menu:set_enabled(commands:id("PASTE"), true)
end

function CoreCutsceneEditor:_on_paste()
	local earliest_item_time = table.inject(self._clipboard or {}, math.huge, function (earliest_time, item)
		return math.min(earliest_time, item:start_time())
	end)
	local offset = self:playhead_position() - earliest_item_time
	local destination_track = self._sequencer:active_film_track()

	if destination_track then
		self._sequencer:deselect_all_items()

		for _, item in ipairs(self._clipboard or {}) do
			local new_clip = destination_track:add_clip(item, offset)

			new_clip:set_selected(true)
			new_clip:set_fill_style("SOLID")
		end

		self._sequencer:remove_items(self._clipboard_cut_items or {})
		self:_refresh_attribute_panel()
	end
end

function CoreCutsceneEditor:_on_select_all()
	self._sequencer:select_all_clips()
end

function CoreCutsceneEditor:_on_select_all_on_current_track()
	self._sequencer:deselect_all_items()
	self._sequencer:active_film_track():select_all_clips()
end

function CoreCutsceneEditor:_on_deselect()
	self._sequencer:deselect_all_items()
end

function CoreCutsceneEditor:_on_delete()
	self._sequencer:remove_items(self._sequencer:selected_items())
	self:_on_sequencer_selection_changed(self._sequencer)
	self:_refresh_attribute_panel()
end

function CoreCutsceneEditor:_on_cleanup_zoom_keys()
	local _, last_film_clip_end_time = self:_get_clip_bounds(self._sequencer:film_clips())
	local items_to_remove = {}

	for _, clip in ipairs(self._sequencer:key_track():clips()) do
		local cutscene_key = clip:metadata()

		if cutscene_key.ELEMENT_NAME == CoreZoomCameraCutsceneKey.ELEMENT_NAME then
			if last_film_clip_end_time <= clip:start_time() then
				table.insert(items_to_remove, clip)
			else
				local preceeding_cutscene_key = cutscene_key:preceeding_key()

				if preceeding_cutscene_key and cutscene_key:end_fov() == preceeding_cutscene_key:end_fov() and (cutscene_key:start_fov() == preceeding_cutscene_key:end_fov() or cutscene_key:transition_time() == 0) then
					table.insert(items_to_remove, clip)
				end
			end
		end
	end

	if #items_to_remove > 0 then
		self._sequencer:remove_items(items_to_remove)
	end
end

function CoreCutsceneEditor:_on_play()
	self._playing = true
end

function CoreCutsceneEditor:_on_play_from_start()
	self:_on_stop()
	self:_on_play()
end

function CoreCutsceneEditor:_on_pause()
	self._playing = false
end

function CoreCutsceneEditor:_on_stop()
	self:_on_pause()

	local clips_on_active_track = self._sequencer:active_film_track() and self._sequencer:active_film_track():clips() or {}
	local start_time = self:_get_clip_bounds(clips_on_active_track) or 0

	self:set_playhead_position(start_time)
end

function CoreCutsceneEditor:_on_play_toggle()
	if self._playing then
		self:_on_pause()
	else
		self:_on_play()
	end
end

function CoreCutsceneEditor:_on_zoom_in()
	self:zoom_around_playhead()
end

function CoreCutsceneEditor:_on_zoom_out()
	self:zoom_around_playhead(-1)
end

function CoreCutsceneEditor:_on_go_to_start()
	local clips_on_active_track = self._sequencer:active_film_track() and self._sequencer:active_film_track():clips() or {}
	local start_time = self:_get_clip_bounds(self._sequencer:selected_items()) or self:_get_clip_bounds(clips_on_active_track) or 0

	self:set_playhead_position(start_time)
end

function CoreCutsceneEditor:_on_go_to_end()
	local items = self._sequencer:selected_items()

	if #items == 0 then
		items = self._sequencer:active_film_track() and self._sequencer:active_film_track():clips() or {}
	end

	local start_time, end_time = self:_get_clip_bounds(items)

	if end_time then
		self:set_playhead_position(end_time)
	end
end

function CoreCutsceneEditor:_on_go_to_previous_frame()
	self:set_playhead_position(self:playhead_position() - 1)
end

function CoreCutsceneEditor:_on_go_to_next_frame()
	self:set_playhead_position(self:playhead_position() + 1)
end

function CoreCutsceneEditor:_on_sequencer_selection_changed(sequencer)
	self:_refresh_selected_footage_track()
	self:_refresh_attribute_panel()

	local all_selected_clips_are_on_the_active_film_track = #sequencer:selected_items() == #sequencer:active_film_track():selected_clips()

	self._edit_menu:set_enabled("CUT", all_selected_clips_are_on_the_active_film_track)
	self._edit_menu:set_enabled("COPY", all_selected_clips_are_on_the_active_film_track)
end

function CoreCutsceneEditor:_on_sequencer_remove_item(sender, removed_item)
	local metadata = removed_item.metadata and removed_item:metadata()

	if metadata and metadata.unload then
		metadata:unload(self._player)
	end
end

function CoreCutsceneEditor:_on_sequencer_drag_item(sender, dragged_item, drag_mode)
	self:_refresh_selected_footage_track()

	if string.ends(drag_mode, "EDGE") then
		self:_evaluate_clip_at_frame(dragged_item, drag_mode == "LEFT_EDGE" and dragged_item:start_time() or dragged_item:end_time() - 1)
	else
		self:_evaluate_current_frame()
	end
end

function CoreCutsceneEditor:_on_sequencer_evaluate_frame_at_playhead(sender, event)
	self:_evaluate_current_frame()
end

function CoreCutsceneEditor:_on_selected_footage_track_mouse_left_up(sender, event)
	if not event:control_down() then
		sender:deselect_all_clips()
	end

	local clip_below_cursor = sender:clip_at_event(event)

	if clip_below_cursor then
		clip_below_cursor:set_selected(not clip_below_cursor:selected())
	end
end

function CoreCutsceneEditor:_on_sequencer_track_mousewheel(sender, event, track)
	self:_on_track_mousewheel(track, event)
end

function CoreCutsceneEditor:_on_track_mousewheel(sender, event)
	self:zoom_around_playhead(event:get_wheel_rotation() < 0 and -1 or 1)
end

function CoreCutsceneEditor:_on_footage_selection_changed(sender, event)
	self._selected_footage_track:remove_all_clips()

	local selected_item_index = sender:selected_item()
	local footage = selected_item_index >= 0 and sender:get_item_data(selected_item_index) or nil

	if footage then
		footage:add_clips_to_track(self._selected_footage_track)
		footage:add_cameras_to_list_ctrl(self._camera_list_ctrl)
	else
		self._camera_list_ctrl:delete_all_items()
		self._selected_footage_track_region:set_visible(false)
	end

	self._insert_menu:set_enabled(commands:id("INSERT_CLIPS_FROM_SELECTED_FOOTAGE"), footage ~= nil)
end

function CoreCutsceneEditor:_on_cutscene_camera_toggle()
	self:_evaluate_current_frame()

	if self._player then
		local enabled = self._view_menu:is_checked(commands:id("CUTSCENE_CAMERA_TOGGLE"))

		if enabled then
			self._player:set_viewport_enabled(true)
		else
			local vp = managers.viewport and managers.viewport:first_active_viewport()
			local current_camera = vp and vp:camera()

			if current_camera and managers.editor then
				managers.editor:set_camera(current_camera:position(), current_camera:rotation())
			end

			self._player:set_viewport_enabled(false)
		end
	end
end

function CoreCutsceneEditor:_on_widescreen_toggle()
	if self._player then
		self._player:set_widescreen(self._view_menu:is_checked(commands:id("WIDESCREEN_TOGGLE")))
	end
end

function CoreCutsceneEditor:_on_play_every_frame_toggle()
	self._play_every_frame = self._transport_menu:is_checked(commands:id("PLAY_EVERY_FRAME_TOGGLE"))
end

function CoreCutsceneEditor:_on_insert_clips_from_selected_footage(sender, event)
	local clips_to_add = self._selected_footage_track:selected_clips()

	if #clips_to_add == 0 then
		clips_to_add = self._selected_footage_track:clips()
	end

	local destination_track = self._sequencer:active_film_track()

	if destination_track and #clips_to_add ~= 0 then
		self._sequencer:deselect_all_items()

		local cutscene_metadata = clips_to_add[1]:metadata()
		local cutscene = cutscene_metadata:footage()._cutscene

		cutscene_metadata:prime_cast(self._cast)

		local earliest_clip_time = table.inject(clips_to_add, math.huge, function (earliest_time_yet, clip)
			return math.min(earliest_time_yet, clip:start_time())
		end)
		local offset = self:playhead_position() - earliest_clip_time
		local cutscene_keys = table.find_all_values(cutscene:_all_keys_sorted_by_time(), function (key)
			return key.ELEMENT_NAME ~= CoreChangeCameraCutsceneKey.ELEMENT_NAME
		end)

		for _, clip in ipairs(clips_to_add) do
			destination_track:add_clip(clip, offset):set_selected(true)

			for _, template_key in ipairs(cutscene_keys) do
				if clip:start_time_in_source() <= template_key:frame() and template_key:frame() < clip:end_time_in_source() then
					local cutscene_key = template_key:clone()

					cutscene_key:set_frame(template_key:frame() + offset)
					self:_monkey_patch_cutscene_key(cutscene_key)
					self._sequencer:set_item_selected(self._sequencer:add_cutscene_key(cutscene_key), true)
				end
			end
		end

		self:_on_sequencer_selection_changed(self._sequencer)
		self:_on_go_to_end()
	else
		local selected_item_index = self._footage_list_ctrl:selected_item()

		if selected_item_index > 0 then
			local selected_footage = self._footage_list_ctrl:get_item_data(selected_item_index)
			local cutscene_keys = table.find_all_values(selected_footage:keys(), function (key)
				return key.ELEMENT_NAME ~= CoreChangeCameraCutsceneKey.ELEMENT_NAME
			end)

			if not table.empty(cutscene_keys) then
				self._sequencer:deselect_all_items()
			end

			for _, template_key in ipairs(cutscene_keys) do
				local cutscene_key = template_key:clone()

				cutscene_key:set_frame(template_key:frame() + self:playhead_position())
				self:_monkey_patch_cutscene_key(cutscene_key)
				self._sequencer:set_item_selected(self._sequencer:add_cutscene_key(cutscene_key), true)
			end

			if not table.empty(cutscene_keys) then
				self:_on_sequencer_selection_changed(self._sequencer)
				self:_on_go_to_end()
			end
		end
	end
end

function CoreCutsceneEditor:_on_insert_cutscene_key(element_name)
	local cutscene_key = CoreCutsceneKey:create(element_name, self)

	cutscene_key:populate_from_editor(self)
	self:_monkey_patch_cutscene_key(cutscene_key)
	self._sequencer:deselect_all_items()
	self._sequencer:set_item_selected(self._sequencer:add_cutscene_key(cutscene_key), true)
end

function CoreCutsceneEditor:_monkey_patch_cutscene_key(cutscene_key)
	cutscene_key:set_key_collection(self)
	cutscene_key:set_cast(self._cast)

	cutscene_key.is_in_cutscene_editor = true
end

function CoreCutsceneEditor:_draw_focus_planes()
	if self._player and managers.DOF then
		self._player._viewport:update()

		local camera = self._player:_camera()

		local function draw_focus_plane(value, color)
			local point = camera:screen_to_world(Vector3(0, 0, value))
			local brush = Draw:brush()

			brush:set_color(Color(color))
			brush:set_blend_mode("add")
			brush:disc(point, self._player:is_viewport_enabled() and 10000 or 100, camera:rotation():y())
		end

		local camera_cylinder = Draw:pen()

		camera_cylinder:set(Color("808080"))
		camera_cylinder:cylinder(camera:position(), camera:screen_to_world(Vector3(0, 0, camera:far_range())), 100, 20, 0)

		local camera_brush = Draw:brush()

		camera_brush:set_color(Color("003300"))
		camera_brush:set_blend_mode("add")
		camera_brush:disc(camera:position(), 100, camera:rotation():y())

		local dof_attributes = self._player:depth_of_field_attributes()

		if dof_attributes then
			draw_focus_plane(dof_attributes.near_focus_distance_min, "330000")
			draw_focus_plane(dof_attributes.near_focus_distance_max, "333333")
			draw_focus_plane(dof_attributes.far_focus_distance_min, "333333")
			draw_focus_plane(dof_attributes.far_focus_distance_max, "330000")
		end
	end
end

function CoreCutsceneEditor:_draw_cast_finder()
	if self._player == nil then
		return
	end

	self:_draw_compass()

	for _, unit_name in ipairs(self._cast:unit_names()) do
		local unit = self._cast:unit(unit_name)

		if unit:name() == "locator" then
			if not string.begins(unit_name, "camera") then
				local object = unit:get_object("locator")

				if object then
					self:_draw_locator_object(object)
					self:_draw_label(unit_name, object:position() - Vector3(0, 0, 10))
					self:_draw_tracking_line(object, unit_name)
				end
			end
		else
			for _, child in ipairs(unit:orientation_object():children()) do
				self:_draw_label(unit_name, child:position())
				self:_draw_tracking_line(child, unit_name)

				break
			end
		end
	end
end

function CoreCutsceneEditor:_draw_compass()
	local vp = managers.viewport and managers.viewport:first_active_viewport()
	local camera = vp and vp:camera()
	local camera_rotation = camera and camera:rotation()
	local compass_position = camera_rotation and camera:position() - camera_rotation:z() * 5 + camera_rotation:y() * camera:near_range()

	if compass_position then
		self:_pen():set(Color.black)
		self:_pen():circle(compass_position, 1)

		local brush = Draw:brush()

		brush:set_color(Color(0.3, 0.3, 0.3))
		brush:set_blend_mode("add")
		brush:disc(compass_position, 1)
		self:_pen():set(Color.red)
		self:_pen():line(compass_position, compass_position + Vector3(1, 0, 0))
		self:_pen():set(Color(0.3, 0, 0))
		self:_pen():line(compass_position, compass_position - Vector3(1, 0, 0))
		self:_pen():set(Color.green)
		self:_pen():line(compass_position, compass_position + Vector3(0, 1, 0))
		self:_pen():set(Color(0, 0.3, 0))
		self:_pen():line(compass_position, compass_position - Vector3(0, 1, 0))
		self:_pen():set(Color.blue)
		self:_pen():line(compass_position, compass_position + Vector3(0, 0, 1))
		self:_pen():set(Color(0, 0, 0.3))
		self:_pen():line(compass_position, compass_position - Vector3(0, 0, 1))
	end
end

function CoreCutsceneEditor:_draw_locator_object(object)
	local position = object:position()
	local rotation = object:rotation()

	self:_pen():set(Color.white)
	self:_pen():rotation(position, rotation, 10)
	self:_pen():sphere(position, 1, 10, 1)
end

function CoreCutsceneEditor:_draw_tracking_line(object, label)
	local vp = managers.viewport and managers.viewport:first_active_viewport()
	local camera = managers.viewport and vp:camera()
	local camera_rotation = camera and camera:rotation()
	local camera_position = camera_rotation and camera:position() - camera_rotation:z() * 5 + camera_rotation:y() * camera:near_range()
	local object_position = object and object:position()

	if camera_position and object_position then
		local line = object_position - camera_position
		local line_normal = line:normalized()

		self:_pen():set(Color.black)
		self:_pen():line(camera_position, object_position)

		if label then
			self:_tiny_text_brush():text(camera_position + line_normal + camera_rotation:z() * 1.2, label, line_normal, -camera_rotation:z())
		end
	end
end

function CoreCutsceneEditor:_draw_cameras()
	if self._player == nil then
		return
	end

	local active_camera_object = self._player:_camera_object()

	for _, unit_name in ipairs(self._cast:unit_names()) do
		if string.begins(unit_name, "camera") then
			local object = self._cast:unit(unit_name):get_object("locator")

			if object and object ~= active_camera_object then
				self:_draw_camera_object(object)
				self:_draw_label(unit_name, object:position() - Vector3(0, 0, 30))
			end
		end
	end

	if active_camera_object then
		self:_draw_camera_object(active_camera_object, Color(0, 0.5, 0.5))
		self:_draw_label(self._player._camera_name, active_camera_object:position() - Vector3(0, 0, 30))

		if self._player._cutscene:is_optimized() then
			self:_draw_camera_object(self._player._future_camera_locator:get_object("locator"), Color(0.3, 0, 0.5, 0.5))
		end
	end
end

function CoreCutsceneEditor:_draw_camera_object(object, color)
	local position = object:position()
	local rotation = object:rotation()
	local scale = 10
	local x = rotation:x() * scale
	local y = rotation:y() * scale
	local z = rotation:z() * scale
	local center = position + z * 3
	local brush = Draw:brush()

	brush:set_color(color or Color(0.5, 0.5, 0.5))
	brush:box(center, x, y, z * 1.5)
	brush:pyramid(center, position + x + y, position + x * -1 + y, position + x * -1 + y * -1, position + x + y * -1)
	self:_pen():rotation(position, rotation, 10)
end

function CoreCutsceneEditor:_draw_hierarchies()
	if self._player == nil then
		return
	end

	for _, unit_name in ipairs(self._cast:unit_names()) do
		local unit = self._cast:unit(unit_name)

		if unit:name() ~= "locator" then
			self:_draw_unit_hierarchy(unit, unit_name, false)
		end
	end
end

function CoreCutsceneEditor:_draw_unit_hierarchy(unit, unit_name, draw_root_point)
	unit_name = unit_name or unit:name()
	local root_point = unit:orientation_object()

	if draw_root_point then
		local label_z = self:_draw_object_hierarchy(root_point) + 30

		self:_draw_label(unit_name, root_point:position():with_z(label_z))
	else
		for _, child in ipairs(root_point:children()) do
			local label_z = self:_draw_object_hierarchy(child) + 30

			self:_draw_label(unit_name, child:position():with_z(label_z))
		end
	end
end

function CoreCutsceneEditor:_draw_object_hierarchy(object, parent, max_z)
	self:_draw_joint(parent, object)

	max_z = math.max(max_z or -math.huge, object.position and object:position().z or -math.huge)

	if object.children then
		for _, child in ipairs(object:children()) do
			if object.position then
				max_z = math.max(max_z, self:_draw_object_hierarchy(child, object, max_z))
			end
		end
	end

	return max_z
end

function CoreCutsceneEditor:_draw_label(text, position)
	self:_text_brush():center_text(position, utf8.from_latin1(text))
end

function CoreCutsceneEditor:_draw_joint(start_object, end_object, radius)
	radius = radius or 1
	local end_position = end_object and end_object.position and end_object:position()

	if end_position then
		local start_position = start_object and start_object.position and start_object:position()

		if start_position then
			self:_pen():set(Color(0.5, 0.5, 0.5))

			local joint_normal = (end_position - start_position):normalized()

			self:_pen():cone(end_position - joint_normal * radius, start_position + joint_normal * radius, radius, 4, 4)
		else
			self:_pen():set(Color.white)
		end

		if end_object.rotation then
			local end_rotation = end_object:rotation()

			self:_pen():rotation(end_position, end_rotation, start_position and radius or radius * 10)

			if end_object.name then
				self:_tiny_text_brush():text(end_position + Vector3(0, 0, 0.7), end_object:name())
			end
		end

		self:_pen():sphere(end_position, radius, 10, 1)
	end
end

function CoreCutsceneEditor:_pen()
	if self._debug_pen == nil then
		self._debug_pen = Draw:pen()

		self._debug_pen:set(Color(0.5, 0.5, 0.5))
		self._debug_pen:set("no_z")
	end

	return self._debug_pen
end

function CoreCutsceneEditor:_text_brush()
	if self._debug_text_brush == nil then
		self._debug_text_brush = Draw:brush()

		self._debug_text_brush:set(Color(0.5, 0.5, 0.5))
		self._debug_text_brush:set_font("core/fonts/system_font", 30)
	end

	return self._debug_text_brush
end

function CoreCutsceneEditor:_tiny_text_brush()
	if self._debug_tiny_text_brush == nil then
		self._debug_tiny_text_brush = Draw:brush()

		self._debug_tiny_text_brush:set(Color(0.5, 0.5, 0.5))
		self._debug_tiny_text_brush:set_font("core/fonts/system_font", 1)
	end

	return self._debug_tiny_text_brush
end

function CoreCutsceneEditor:prime_cutscene_key(player, key, cast)
end

function CoreCutsceneEditor:evaluate_cutscene_key(player, key, time, last_evaluated_time)
end

function CoreCutsceneEditor:revert_cutscene_key(player, key, time, last_evaluated_time)
end

function CoreCutsceneEditor:update_cutscene_key(player, key, time, last_evaluated_time)
end

function CoreCutsceneEditor:skip_cutscene_key(player)
end

function CoreCutsceneEditor:time_in_relation_to_cutscene_key(key)
	return self:playhead_position() / self:frames_per_second() - key:time()
end

function CoreCutsceneEditor:_debug_get_cast_member(unit_name)
	return self._cast:unit(unit_name)
end

function CoreCutsceneEditor:_debug_dump_cast()
	cat_print("debug", "Cast:")

	for _, unit_name in ipairs(self._cast:unit_names()) do
		local unit = self:_debug_get_cast_member(unit_name)

		cat_print("debug", unit_name .. " (" .. unit:name() .. ")")
	end
end

function CoreCutsceneEditor:_debug_dump_cast_member(unit_name)
	local unit = self:_debug_get_cast_member(unit_name)

	if unit then
		cat_print("debug", unit_name .. " (" .. unit:name() .. "):")
		self:_debug_dump_hierarchy(unit:orientation_object())
	else
		cat_print("debug", "Unit \"" .. unit_name .. "\" not in cast.")
	end
end

function CoreCutsceneEditor:_debug_dump_hierarchy(object, indent)
	indent = indent or 0
	local object_type = type_name(object)

	cat_print("debug", string.rep("  ", indent) .. object:name() .. " : " .. object_type)

	for _, child in ipairs(object.children and object:children() or {}) do
		self:_debug_dump_hierarchy(child, indent + 1)
	end
end
