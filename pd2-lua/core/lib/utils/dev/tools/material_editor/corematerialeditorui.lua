require("core/lib/utils/dev/tools/material_editor/CoreMaterialEditorDialogs")
require("core/lib/utils/dev/ews/tree_control/CoreManagedTreeControl")

CoreMaterialEditor = CoreMaterialEditor or class()

function CoreMaterialEditor:_create_main_frame()
	self._main_frame = EWS:Frame(self.FRAME_TITLE, Vector3(-1, -1, 0), Vector3(650, 1200, 0), "FRAME_FLOAT_ON_PARENT,DEFAULT_FRAME_STYLE", Global.frame)

	self._main_frame:set_icon(self.FRAME_ICON)

	self._main_frame_tool_bar = EWS:ToolBar(self._main_frame, "", "TB_FLAT,TB_NOALIGN")

	self._main_frame_tool_bar:add_tool("NEW", "New", self.NEW_ICON, "Creates a new material configuration.")
	self._main_frame_tool_bar:add_tool("OPEN", "Open", self.OPEN_ICON, "Opens a material configuration.")
	self._main_frame_tool_bar:add_tool("SAVE", "Save", self.SAVE_ICON, "Saves this material configuration.")
	self._main_frame_tool_bar:add_separator()
	self._main_frame_tool_bar:add_tool("RELOAD", "Reload Material Config", self.RELOAD_ICON, "Reloads this material config.")
	self._main_frame_tool_bar:add_check_tool("LOCK", "Toggles Material Config Lock", self.LOCK_ICON, "Toggles lock on this material config.")
	self._main_frame_tool_bar:set_tool_state("LOCK", false)
	self._main_frame_tool_bar:add_separator()
	self._main_frame_tool_bar:add_tool("PROBLEM_SOLVER", "Problem Solver", self.PROBLEM_SOLVER_ICON, "Do you need help?")
	self._main_frame_tool_bar:realize()
	self._main_frame:set_tool_bar(self._main_frame_tool_bar)

	self._main_frame_status_bar = EWS:StatusBar(self._main_frame, "", "")

	self._main_frame:set_status_bar(self._main_frame_status_bar)

	local menu_bar = EWS:MenuBar()
	local file_menu = EWS:Menu("")

	file_menu:append_item("NEW", "New\tCtrl+N", "")
	file_menu:append_item("OPEN", "Open\tCtrl+O", "")
	file_menu:append_separator()
	file_menu:append_item("SAVE", "Save\tCtrl+S", "")
	file_menu:append_item("SAVE_AS", "Save As", "")
	file_menu:append_separator()
	file_menu:append_item("SAVE_GLOBAL", "Save Global", "")
	file_menu:append_separator()
	file_menu:append_item("RELOAD", "Reload Material Config", "")
	file_menu:append_separator()
	file_menu:append_item("NEWS", "Get Latest News", "")
	file_menu:append_separator()
	file_menu:append_item("EXIT", "Exit", "")
	menu_bar:append(file_menu, "File")

	self._tools_menu = EWS:Menu("")

	self._tools_menu:append_item("REBUILD", "Rebuild", "")
	self._tools_menu:append_item("EDIT_GLOBAL", "Edit Global", "")
	self._tools_menu:append_item("REMOTE_COMPILER", "Remote Compiler", "")
	self._tools_menu:append_separator()
	self._tools_menu:append_check_item("FEEDBACK", "Real Time Feedback", "")
	self._tools_menu:set_checked("FEEDBACK", true)
	menu_bar:append(self._tools_menu, "Tools")

	self._help_menu = EWS:Menu("")

	self._help_menu:append_item("PROBLEM_SOLVER", "Problem Solver", "")
	menu_bar:append(self._help_menu, "Help")
	self._main_frame:set_menu_bar(menu_bar)
	self._main_frame:connect("NEW", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_new"), "")
	self._main_frame:connect("OPEN", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_open"), "")
	self._main_frame:connect("SAVE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_save"), "")
	self._main_frame:connect("SAVE_AS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_save_as"), "")
	self._main_frame:connect("SAVE_GLOBAL", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_save_global"), "")
	self._main_frame:connect("RELOAD", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_reload"), "")
	self._main_frame:connect("NEWS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_check_news"), "")
	self._main_frame:connect("EXIT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_close"), "")
	self._main_frame:connect("REBUILD", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_rebuild"), "")
	self._main_frame:connect("EDIT_GLOBAL", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_edit_global"), "")
	self._main_frame:connect("REMOTE_COMPILER", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_change_remote_server"), "")
	self._main_frame:connect("FEEDBACK", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_feedback"), "")
	self._main_frame:connect("LOCK", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_toggle_lock"), "")
	self._main_frame:connect("PROBLEM_SOLVER", "EVT_COMMAND_MENU_SELECTED", function ()
		EWS:launch_url("http://mondomonkey.com/MondoMonkeyWhiteB.jpg")
	end, "")
	self._main_frame:connect("", "EVT_CLOSE_WINDOW", callback(self, self, "_on_close"), "")

	self._main_scroll_window = EWS:ScrolledWindow(self._main_frame, "", "SUNKEN_BORDER")

	self._main_scroll_window:set_background_colour((EWS:get_system_colour("3DFACE") * 128):unpack())

	local main_frame_box = EWS:BoxSizer("VERTICAL")
	local main_scroll_window_box = EWS:BoxSizer("VERTICAL")
	local main_panel = EWS:Panel(self._main_scroll_window, "", "")
	local panel_box = EWS:BoxSizer("VERTICAL")
	self._material_collapse_box = CoreEWS:CollapseBox(main_panel, "VERTICAL", "Material", nil, true, "NO_BORDER")

	self._material_collapse_box:connect("", "EVT_COMMAND_BUTTON_CLICKED", self._layout_all, self)
	self._material_collapse_box:lower_panel():set_background_colour((EWS:get_system_colour("3DFACE") * 255):unpack())
	panel_box:add(self._material_collapse_box:panel(), 0, 4, "ALL,EXPAND")

	self._material_list_box = EWS:ListBox(self._material_collapse_box:lower_panel(), "", "LB_SORT")

	self._material_list_box:connect("", "EVT_COMMAND_LISTBOX_SELECTED", callback(self, self, "_on_material_selected"), "")
	self._material_list_box:connect("", "EVT_RIGHT_UP", callback(self, self, "_on_material_popup"), "")
	self._material_list_box:set_min_size(Vector3(0, 150, 0))
	self._material_collapse_box:box():add(self._material_list_box, 1, 4, "ALL,EXPAND")

	self._shader_collapse_box = CoreEWS:CollapseBox(main_panel, "VERTICAL", "Shader", nil, true, "NO_BORDER")

	self._shader_collapse_box:connect("", "EVT_COMMAND_BUTTON_CLICKED", self._layout_all, self)
	self._shader_collapse_box:lower_panel():set_background_colour((EWS:get_system_colour("3DFACE") * 255):unpack())
	panel_box:add(self._shader_collapse_box:panel(), 0, 4, "ALL,EXPAND")

	local box = EWS:BoxSizer("HORIZONTAL")
	local text = EWS:StaticText(self._shader_collapse_box:lower_panel(), "Compilable Shader: ", "", "")

	box:add(text, 0, 4, "ALL,EXPAND")

	self._compilable_shader_combo_box = EWS:ComboBox(self._shader_collapse_box:lower_panel(), "", "", "CB_READONLY,CB_SORT")

	self._compilable_shader_combo_box:connect("", "EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_on_shader_combobox_selected"), "")
	box:add(self._compilable_shader_combo_box, 1, 4, "ALL,EXPAND")
	self._shader_collapse_box:box():add(box, 0, 0, "EXPAND")

	local line = EWS:StaticLine(self._shader_collapse_box:lower_panel(), "", "")

	self._shader_collapse_box:box():add(line, 0, 4, "ALL,EXPAND")

	self._shader_option_panel = EWS:Panel(self._shader_collapse_box:lower_panel(), "", "")

	self._shader_collapse_box:box():add(self._shader_option_panel, 1, 0, "EXPAND")

	self._shader_option_box = EWS:BoxSizer("VERTICAL")

	self._shader_option_panel:set_sizer(self._shader_option_box)

	self._shader_option_tree = CoreManagedTreeControl:new(self._shader_option_panel, "TR_HAS_BUTTONS,TR_HIDE_ROOT,TR_LINES_AT_ROOT,TR_SINGLE,TR_HAS_CHECKBOX")
	self._section_image_id = self._shader_option_tree:get_image_list():add(CoreEWS.image_path("folder_16x16.png"))
	self._section_open_image_id = self._shader_option_tree:get_image_list():add(CoreEWS.image_path("folder_open_16x16.png"))

	self._shader_option_tree:set_min_size(Vector3(0, 175, 0))
	self._shader_option_tree:add_to_sizer(self._shader_option_box, 1, 4, "EXPAND,ALL")

	local cmpbox = EWS:BoxSizer("VERTICAL")
	box = EWS:BoxSizer("HORIZONTAL")
	self._remote_compile_checkbox = EWS:CheckBox(self._shader_collapse_box:lower_panel(), "Remote Compile", "", "")

	box:add(self._remote_compile_checkbox, 1, 4, "ALL")
	self._remote_compile_checkbox:set_enabled(self._remote_host)

	self._compile_button = EWS:Button(self._shader_collapse_box:lower_panel(), "Compile", "", "NO_BORDER")

	self._compile_button:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "_on_compile_btn"), "")
	box:add(self._compile_button, 0, 4, "ALL")
	cmpbox:add(box, 0, 0, "EXPAND")

	box = EWS:BoxSizer("HORIZONTAL")
	self._compile_info_text = EWS:StaticText(self._shader_collapse_box:lower_panel(), "", "", "")

	self._compile_info_text:set_font_weight("FONTWEIGHT_BOLD")
	box:add(self._compile_info_text, 1, 4, "ALL,EXPAND")
	cmpbox:add(box, 0, 0, "EXPAND")
	self._shader_collapse_box:box():add(cmpbox, 0, 0, "EXPAND")

	self._parameter_collapse_box = CoreEWS:CollapseBox(main_panel, "VERTICAL", "Parameter", nil, true, "NO_BORDER")

	self._parameter_collapse_box:connect("", "EVT_COMMAND_BUTTON_CLICKED", self._layout_all, self)
	self._parameter_collapse_box:lower_panel():set_background_colour((EWS:get_system_colour("3DFACE") * 255):unpack())
	panel_box:add(self._parameter_collapse_box:panel(), 0, 4, "ALL,EXPAND")

	box = EWS:BoxSizer("HORIZONTAL")
	text = EWS:StaticText(self._parameter_collapse_box:lower_panel(), "Parent: ", "", "")

	box:add(text, 0, 4, "ALL,EXPAND")

	self._parent_combo_box = EWS:ComboBox(self._parameter_collapse_box:lower_panel(), "", "", "CB_READONLY,CB_SORT")

	self._parent_combo_box:connect("", "EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_on_parent_combo_box_change"), "")
	box:add(self._parent_combo_box, 1, 4, "ALL,EXPAND")
	self._parameter_collapse_box:box():add(box, 0, 0, "EXPAND")

	line = EWS:StaticLine(self._parameter_collapse_box:lower_panel(), "", "")

	self._parameter_collapse_box:box():add(line, 0, 4, "ALL,EXPAND")

	self._output_collapse_box = CoreEWS:CollapseBox(main_panel, "VERTICAL", "Output", nil, false, "NO_BORDER")

	self._output_collapse_box:connect("", "EVT_COMMAND_BUTTON_CLICKED", self._layout_all, self)
	self._output_collapse_box:lower_panel():set_background_colour((EWS:get_system_colour("3DFACE") * 255):unpack())
	panel_box:add(self._output_collapse_box:panel(), 0, 4, "ALL,EXPAND")

	self._material_output_collapse_box = CoreEWS:CollapseBox(self._output_collapse_box:lower_panel(), "VERTICAL", "Material", nil, false, "NO_BORDER")

	self._material_output_collapse_box:connect("", "EVT_COMMAND_BUTTON_CLICKED", self._layout_output, self)
	self._material_output_collapse_box:lower_panel():set_background_colour((EWS:get_system_colour("3DFACE") * 255):unpack())
	self._output_collapse_box:box():add(self._material_output_collapse_box:panel(), 0, 4, "ALL,EXPAND")

	self._output_text_ctrl = CoreEWS:XMLTextCtrl(self._material_output_collapse_box:lower_panel(), nil, nil, nil, "TE_MULTILINE,TE_RICH2,TE_DONTWRAP,TE_READONLY")

	self._output_text_ctrl:text_ctrl():set_min_size(Vector3(0, 150, 0))
	self._material_output_collapse_box:box():add(self._output_text_ctrl:text_ctrl(), 1, 4, "ALL,EXPAND")

	self._global_output_collapse_box = CoreEWS:CollapseBox(self._output_collapse_box:lower_panel(), "VERTICAL", "Global", nil, false, "NO_BORDER")

	self._global_output_collapse_box:connect("", "EVT_COMMAND_BUTTON_CLICKED", self._layout_output, self)
	self._global_output_collapse_box:lower_panel():set_background_colour((EWS:get_system_colour("3DFACE") * 255):unpack())
	self._output_collapse_box:box():add(self._global_output_collapse_box:panel(), 0, 4, "ALL,EXPAND")

	self._global_text_ctrl = CoreEWS:XMLTextCtrl(self._global_output_collapse_box:lower_panel(), nil, nil, nil, "TE_MULTILINE,TE_RICH2,TE_DONTWRAP,TE_READONLY")

	self._global_text_ctrl:text_ctrl():set_min_size(Vector3(0, 150, 0))
	self._global_output_collapse_box:box():add(self._global_text_ctrl:text_ctrl(), 1, 4, "ALL,EXPAND")

	self._output_update_button = EWS:Button(self._output_collapse_box:lower_panel(), "Update", "", "NO_BORDER")

	self._output_update_button:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "_update_output"), "")
	self._output_collapse_box:box():add(self._output_update_button, 0, 4, "ALIGN_RIGHT,ALL")
	main_panel:set_sizer(panel_box)
	main_scroll_window_box:add(main_panel, 1, 4, "ALL,EXPAND")
	main_frame_box:add(self._main_scroll_window, 1, 0, "EXPAND")
	self._main_scroll_window:set_sizer(main_scroll_window_box)
	self._main_scroll_window:set_scroll_rate(Vector3(0, 20, 0))
	self._main_scroll_window:set_virtual_size_hints(Vector3(0, 0, 0), Vector3(1, -1, -1))
	self._main_scroll_window:set_virtual_size(Vector3(-1, -1, 0))
	self._main_scroll_window:enable_scrolling(false, true)
	self._main_frame:set_sizer(main_frame_box)
	self._main_frame:set_visible(true)
end

function CoreMaterialEditor:_build_shader_options()
	local shader_name = self._compilable_shader_combo_box:get_value()

	if self._shader_option_tree_name ~= shader_name then
		self:_freeze_frame()
		self._shader_option_tree:clear()

		self._shader_defines = {}
		self._shader_option_tree_name = shader_name
		local shader = self._compilable_shaders[shader_name]._node
		local root = self._shader_option_tree:root_node()
		local editor_node = self:_get_node(shader, "editor")

		self:_build_section(shader_name, shader, editor_node, root)
		self._shader_option_panel:layout()
		self:_unfreeze_frame()
	end
end

function CoreMaterialEditor:_set_shader_option_tooltip(node, item)
	local tooltip = node:parameter("tooltip") or ""

	self._shader_option_tree:set_tooltip(item, tooltip)
end

function CoreMaterialEditor:_build_section(shader_name, shader, node, tree)
	for child in node:children() do
		local project = child:parameter("project")

		if child:name() == "define" and (not project or project == Application:short_game_name()) then
			local name = child:parameter("name")
			local check_box = tree:append(child:parameter("ui_name"))
			local define_struct = {
				_checked = false,
				_define_node = child,
				_check_box = check_box
			}
			self._shader_defines[name] = define_struct

			self._shader_option_tree:connect("EVT_COMMAND_TREE_CHECKBOX_UPDATED", callback(self, self, "_on_shader_option_chaged"), define_struct)
			self:_set_shader_option_tooltip(child, check_box)
		elseif child:name() == "section" then
			local section_node = tree:append(child:parameter("name"))

			section_node:set_image(self._section_image_id, "NORMAL")
			section_node:set_image(self._section_open_image_id, "EXPANDED")
			self:_set_shader_option_tooltip(child, section_node)
			self:_build_section(shader_name, shader, child, section_node)
		end
	end
end

function CoreMaterialEditor:_create_parameter_panel()
	local progress_dialog = nil

	if self._material_config_node:num_children() > 1 and self._output_collapse_box:expanded() then
		-- Nothing
	end

	self:_freeze_output()
	self:_freeze_frame()

	if self._material_parameter_widgets then
		for k, v in pairs(self._material_parameter_widgets) do
			v:destroy()
		end
	end

	self._parent_combo_box:set_value(self._current_material_node and self._current_material_node:parameter("src") or "[NONE]")

	self._material_parameter_widgets = {}
	local len = #self._current_render_template:variables()

	for i, param in ipairs(self._current_render_template:variables()) do
		local node = nil

		if param.type == "texture" then
			node = self:_get_node(self._current_material_node, param.name:s())
		else
			node = self:_find_node(self._current_material_node, "variable", "name", param.name:s())
		end

		local widget_class = self._parameter_widgets[param.ui_type:s()]

		if not widget_class then
			out("[" .. self.TOOLHUB_NAME .. "] Could not find widget class for: " .. param.ui_type:s() .. " Using: " .. param.type)

			widget_class = self._parameter_widgets[param.type]

			assert(widget_class)
		end

		local widget = widget_class:new(self._parameter_collapse_box:lower_panel(), self, param, node)

		assert(not self._material_parameter_widgets[param.name:s()], string.format("A widget with name %s, already exist! (This might be a bug in the shader config file.)", param.name:s()))

		self._material_parameter_widgets[param.name:s()] = widget

		self._parameter_collapse_box:box():add(widget:panel(), 0, 4, "ALL,EXPAND")

		if progress_dialog then
			progress_dialog:update_bar(i / (len + 2) * 100)
		end
	end

	local widget = self._parameter_widgets.separator:new(self._parameter_collapse_box:lower_panel())
	self._material_parameter_widgets.separator = widget

	self._parameter_collapse_box:box():add(widget:panel(), 0, 4, "ALL,EXPAND")

	if progress_dialog then
		progress_dialog:update_bar((len + 1) / (len + 2) * 100)
	end

	widget = self._parameter_widgets.decal:new(self._parameter_collapse_box:lower_panel(), self)
	self._material_parameter_widgets.decal = widget

	self._parameter_collapse_box:box():add(widget:panel(), 0, 4, "ALL,EXPAND")
	self._parameter_collapse_box:lower_panel():layout()
	self._main_scroll_window:fit_inside()
	self:_unfreeze_frame()
	self:_unfreeze_output()

	if progress_dialog then
		progress_dialog:update_bar(100)
	end
end
