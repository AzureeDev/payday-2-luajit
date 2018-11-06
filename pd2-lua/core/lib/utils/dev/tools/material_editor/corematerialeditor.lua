require("core/lib/utils/dev/tools/material_editor/CoreMaterialEditorUI")
require("core/lib/utils/dev/tools/material_editor/CoreMaterialEditorPopups")
require("core/lib/utils/dev/tools/material_editor/CoreMaterialEditorUtils")
require("core/lib/utils/dev/tools/material_editor/CoreMaterialEditorRemote")
require("core/lib/utils/dev/tools/material_editor/CoreSmartNode")

CoreMaterialEditor = CoreMaterialEditor or class()
CoreMaterialEditor.NEWS_STREAM = "material_editor"
CoreMaterialEditor.TOOLHUB_NAME = "Material Editor"
CoreMaterialEditor.FRAME_TITLE = CoreMaterialEditor.TOOLHUB_NAME
CoreMaterialEditor.MATERIAL_CONFIG_VERSION_TAG = "3"
CoreMaterialEditor.MATERIAL_VERSION_TAG = "2"
CoreMaterialEditor.PROJECT_GLOBAL_GONFIG_NAME = "settings\\materials.material_config"
CoreMaterialEditor.CORE_GLOBAL_GONFIG_NAME = "core\\settings\\materials.material_config"
CoreMaterialEditor.TEMP_PATH = "core\\temp\\"
CoreMaterialEditor.SHADER_PATH = "shaders\\"
CoreMaterialEditor.DEFAULT_TEXTURE = "core/textures/default_texture_df"
CoreMaterialEditor.DEFAULT_COMPILABLE_SHADER = "generic"
CoreMaterialEditor.SETTINGS_FILE = "settings\\material_editor.material_editor"
CoreMaterialEditor.FRAME_ICON = CoreEWS.image_path("material_editor_16x16.png")
CoreMaterialEditor.NEW_ICON = CoreEWS.image_path("toolbar/new_16x16.png")
CoreMaterialEditor.OPEN_ICON = CoreEWS.image_path("toolbar/open_16x16.png")
CoreMaterialEditor.SAVE_ICON = CoreEWS.image_path("toolbar/save_16x16.png")
CoreMaterialEditor.RELOAD_ICON = CoreEWS.image_path("toolbar/refresh_16x16.png")
CoreMaterialEditor.LOCK_ICON = CoreEWS.image_path("lock_16x16.png")
CoreMaterialEditor.PROBLEM_SOLVER_ICON = CoreEWS.image_path("help_16x16.png")
CoreMaterialEditor.RENDER_TEMPLATE_PATH = "settings/render_templates"
CoreMaterialEditor.SHADER_LIB_PATH = "settings/shader_libs"

function CoreMaterialEditor:init()
	self:_read_config()

	self._parameter_widgets = {
		scalar = require("core/lib/utils/dev/tools/material_editor/parameter_widgets/CoreMaterialEditorScalar"),
		vector3 = require("core/lib/utils/dev/tools/material_editor/parameter_widgets/CoreMaterialEditorVector3"),
		color3 = require("core/lib/utils/dev/tools/material_editor/parameter_widgets/CoreMaterialEditorColor3"),
		vector2 = require("core/lib/utils/dev/tools/material_editor/parameter_widgets/CoreMaterialEditorVector2"),
		texture = require("core/lib/utils/dev/tools/material_editor/parameter_widgets/CoreMaterialEditorTexture"),
		intensity = require("core/lib/utils/dev/tools/material_editor/parameter_widgets/CoreMaterialEditorDBValue"),
		decal = require("core/lib/utils/dev/tools/material_editor/parameter_widgets/CoreMaterialEditorDecal"),
		separator = require("core/lib/utils/dev/tools/material_editor/parameter_widgets/CoreMaterialEditorSeparator")
	}

	self:_load_shader_sources()
	self:_create_main_frame()
	self:_load_shader_dropdown()
	self:_build_shader_options()
	CoreEWS.check_news(self._main_frame, CoreMaterialEditor.NEWS_STREAM, true)

	self._compile_warning_dialog = CoreMaterialEditorCompileWarningDialog:new(self._main_frame)
	self._start_dialog = CoreMaterialEditorStartDialog:new(self._main_frame, self)

	self._start_dialog:show_modal()

	self._material_lock = false
end

function CoreMaterialEditor:update(t, dt)
	if self._start_dialog:running() then
		self._start_dialog:update(t, dt)
	end

	if self._material_parameter_widgets then
		for k, v in pairs(self._material_parameter_widgets) do
			v:update(t, dt)
		end
	end

	self:_find_selected_unit()

	if not self._disable_live_feedback then
		self:_live_update()
	end
end

function CoreMaterialEditor:set_position(pos)
	if alive(self._main_frame) then
		self._main_frame:set_position(pos)
	end
end

function CoreMaterialEditor:destroy()
	self:close()
end

function CoreMaterialEditor:version_check(path, node, show_popup)
	if node:parameter("version") ~= self.MATERIAL_CONFIG_VERSION_TAG then
		if show_popup then
			EWS:MessageDialog(self._main_frame, "This material config is not of the expected version!", "Open Material Config", "OK,ICON_ERROR"):show_modal()
		end

		return false
	end

	if path == managers.database:base_path() .. self.PROJECT_GLOBAL_GONFIG_NAME or path == managers.database:base_path() .. self.CORE_GLOBAL_GONFIG_NAME then
		if show_popup then
			EWS:MessageDialog(self._main_frame, "This is the global material file! You can't open it like this.", "Open Material Config", "OK,ICON_ERROR"):show_modal()
		end

		return false
	end

	return true
end

function CoreMaterialEditor:close()
	self:_write_config()

	if alive(self._main_frame) then
		self._main_frame:destroy()

		self._main_frame = nil
	end
end

function CoreMaterialEditor:_on_change_remote_server()
	local host = EWS:get_text_from_user(self._main_frame, "Host:", "Remote Compiler", self._remote_host or "", Vector3(-1, -1, -1), true)
	self._remote_host = host ~= "" and host or self._remote_host

	self._remote_compile_checkbox:set_enabled(self._remote_host)
end

function CoreMaterialEditor:_on_close()
	self:_save_current()

	if not self._disable_live_feedback and self._material_config_path then
		Application:reload_material_config(managers.database:entry_path(self._material_config_path):id())
	end

	managers.toolhub:close(self.TOOLHUB_NAME)
end

function CoreMaterialEditor:_on_check_news()
	CoreEWS.check_news(self._main_frame, self.NEWS_STREAM)
end

function CoreMaterialEditor:_on_new()
	self:_save_current()

	local path = managers.database:save_file_dialog(self._main_frame, true, "Material Configurations (*.material_config)|*.material_config")

	if path then
		self:_create_new_material_config(path)

		if self:_load_node(path) then
			self:_update_interface_after_material_list_change()
			self:_reset_diff()
		end
	end
end

function CoreMaterialEditor:_on_open()
	local current_path = nil

	if self._material_config_path then
		current_path = string.match(self._material_config_path, ".*\\")
	end

	self:_save_current()

	local node, path = managers.database:load_node_dialog(self._main_frame, "Material Configurations (*.material_config)|*.material_config", current_path)

	if path and not self:_load_node(path) then
		EWS:MessageDialog(self._main_frame, "The material config file could not be opened.", "Error", "OK,ICON_ERROR"):show_modal()
	end
end

function CoreMaterialEditor:_on_save()
	self:_save_to_disk(self._material_config_path)
	EWS:message_box(self._main_frame, "All data in this material config was saved to disk!", "Save", "OK,ICON_INFORMATION", Vector3(-1, -1, -1))
end

function CoreMaterialEditor:_on_save_as()
	local current_path = nil

	if self._material_config_path then
		current_path = string.match(self._material_config_path, ".*\\")
	end

	local path = managers.database:save_file_dialog(self._main_frame, false, "Material Configurations (*.material_config)|*.material_config", current_path)

	if path then
		if managers.database:has(path) and EWS:MessageDialog(self._main_frame, "A material config with that name already exists. Do you want to replace it?", "Duplicated!", "YES_NO,ICON_ERROR"):show_modal() == "ID_NO" then
			return
		end

		self:_save_to_disk(path)
		EWS:message_box(self._main_frame, "All data in this material config was saved to disk!", "Save", "OK,ICON_INFORMATION", Vector3(-1, -1, -1))
		self:_load_node(path)
	end
end

function CoreMaterialEditor:_on_save_global()
	local global = self._global_material_config_node:to_real_node()

	self:_save_global_to_disk(true)
	EWS:message_box(self._main_frame, "All data in the global material config was saved to disk!", "Save", "OK,ICON_INFORMATION", Vector3(-1, -1, -1))
end

function CoreMaterialEditor:_on_reload()
	if self._material_config_path then
		Application:reload_material_config(Idstring(managers.database:entry_path(self._material_config_path)))
	end
end

function CoreMaterialEditor:_on_toggle_lock()
	if self._material_lock == true then
		self._material_lock = false

		self:_find_selected_unit()
	else
		self._material_lock = true
	end
end

function CoreMaterialEditor:_on_rebuild()
	if EWS:MessageDialog(self._main_frame, "Do a complete rebuild?", "Rebuild", "YES_NO,ICON_QUESTION"):show_modal() == "ID_NO" then
		return
	end

	if EWS:message_box(self._main_frame, "All unsaved data in this material config will be saved before compiling!", "Compile", "OK,CANCEL,ICON_INFORMATION", Vector3(-1, -1, -1)) == "OK" then
		local make_params, temp_params = self:_create_make_file(true)

		if self:_run_compiler() then
			self:_insert_libs_in_database(temp_params, make_params)
			self:_load_shaders(true)
		end
	end
end

function CoreMaterialEditor:_on_edit_global()
	if EWS:message_box(self._main_frame, "All unsaved data in this material config will be lost unless you save it first. Saved data now?", "Edit Global", "YES_NO,ICON_QUESTION", Vector3(-1, -1, -1)) == "ID_YES" then
		self:_save_current()
	end

	CoreMaterialEditorGlobalDialog:new(self._main_frame, self)

	self._material_config_path = nil
	self._material_config_node = nil

	self:_update_interface_after_material_list_change()
	self._start_dialog:show_modal()
end

function CoreMaterialEditor:_on_feedback()
	self._disable_live_feedback = not self._disable_live_feedback
end

function CoreMaterialEditor:_on_parent_combo_box_change()
	local parent = self._parent_combo_box:get_value()

	if parent ~= "[NONE]" then
		self._current_material_node:set_parameter("src", parent)
	else
		self._current_material_node:clear_parameter("src")
	end

	self:_create_parameter_panel()
end

function CoreMaterialEditor:_on_compile_btn()
	if self._remote_compile_checkbox:get_value() then
		if EWS:message_box(self._main_frame, "Do you want to send this shader config to the remote compiler?", "Remote Compile", "YES_NO", Vector3(-1, -1, -1)) == "YES" then
			self:_remot_compile()
			EWS:message_box(self._main_frame, "The request has been sent to the server. It might take up to a minute before it is commited in to the project repository.", "Remote Compile", "OK", Vector3(-1, -1, -1))
		end
	elseif EWS:message_box(self._main_frame, "All unsaved data in this material config will be saved before compiling!", "Compile", "OK,CANCEL,ICON_INFORMATION", Vector3(-1, -1, -1)) == "OK" then
		local make_params, temp_params = self:_create_make_file()

		if self:_run_compiler() then
			self:_insert_libs_in_database(temp_params, make_params)
			self:_load_shaders()
		end
	end
end

function CoreMaterialEditor:_on_material_selected(data, event)
	local selected = event:get_string()
	local mat = self._material_nodes[selected]
	local ver = mat:parameter("version")

	if ver ~= self.MATERIAL_VERSION_TAG and not self:_version_error(mat) then
		return
	end

	self._current_material_node = mat

	self._shader_collapse_box:lower_panel():set_enabled(true)
	self:_load_shader_options()
	self:_find_render_template()
end

function CoreMaterialEditor:_on_add_material(default_name)
	local name = EWS:get_text_from_user(self._main_frame, "Material name: ", "Add Material", default_name, Vector3(-1, -1, 0), true)

	if name ~= "" then
		if self:_find_node(self._material_config_node, "material", "name", name) then
			EWS:MessageDialog(self._main_frame, "A material with that name already exists!", "Add Material", "OK,ICON_ERROR"):show_modal()
			self:_on_add_material(name)
		else
			local mat = self._material_config_node:make_child("material")

			mat:set_parameter("name", name)
			mat:set_parameter("render_template", self._compilable_shader_combo_box:get_value())
			mat:set_parameter("version", self.MATERIAL_VERSION_TAG)
			self:_update_interface_after_material_list_change(name)
			self:_update_output()
		end
	end
end

function CoreMaterialEditor:_on_copy_material()
	self._material_clipboard = self._current_material_node:to_xml()
end

function CoreMaterialEditor:_on_paste_as_material()
	local node = Node.from_xml(self._material_clipboard)
	local name = EWS:get_text_from_user(self._main_frame, "Material name: ", "Paste As", node:parameter("name"), Vector3(-1, -1, 0), true)

	if name ~= "" then
		local mat = self:_find_node(self._material_config_node, "material", "name", name)

		if mat then
			if EWS:MessageDialog(self._main_frame, "A material with that name already exists! Overwrite?", "Paste As", "YES_NO,ICON_QUESTION"):show_modal() ~= "ID_YES" then
				return
			end

			self._material_config_node:remove_child_at(self._material_config_node:index_of_child(mat))
		end

		self._material_config_node:add_child(CoreSmartNode:new(node)):set_parameter("name", name)
		self:_update_interface_after_material_list_change(name)
		self:_update_output()
	end
end

function CoreMaterialEditor:_on_rename_material(default_name)
	local name = EWS:get_text_from_user(self._main_frame, "Material name: ", "Rename Material", default_name, Vector3(-1, -1, 0), true)

	if name ~= "" then
		if self:_find_node(self._material_config_node, "material", "name", name) then
			EWS:MessageDialog(self._main_frame, "A material with that name already exists!", "Rename Material", "OK,ICON_ERROR"):show_modal()
			self:_on_rename_material(name)
		else
			self._current_material_node:set_parameter("name", name)
			self:_update_interface_after_material_list_change()
			self:_update_output()
		end
	end
end

function CoreMaterialEditor:_on_remove_material()
	if EWS:MessageDialog(self._main_frame, "Do you want to remove the selected material?", "Remove Material", "YES_NO,ICON_QUESTION"):show_modal() == "ID_YES" then
		self._material_config_node:remove_child_at(self._material_config_node:index_of_child(self._current_material_node))
		self:_update_interface_after_material_list_change()
		self:_update_output()
	end
end

function CoreMaterialEditor:_on_shader_combobox_selected()
	self._current_material_node:set_parameter("render_template", self._compilable_shader_combo_box:get_value())
	self:_load_shader_options()
	self:_find_render_template()
end

function CoreMaterialEditor:_on_shader_option_chaged(define_struct, data)
	if define_struct._check_box:id() == data._id then
		define_struct._checked = data._state == 1
		local ok, msg = self:_is_options_valid_by_law()

		if not ok then
			self._compile_info_text:set_value(msg)
			self._main_frame_status_bar:set_status_text(msg)
			self._parameter_collapse_box:lower_panel():set_enabled(false)
			self._compile_button:set_enabled(false)
		else
			self._compile_info_text:set_value(msg)
			self._main_frame_status_bar:set_status_text(msg)
			self:_find_render_template()
		end
	end
end

function CoreMaterialEditor:_load_shaders(load_only)
	local render_templates_node = DB:has("render_templates", self.RENDER_TEMPLATE_PATH) and DB:load_node("render_templates", self.RENDER_TEMPLATE_PATH)

	if render_templates_node then
		for child in render_templates_node:children() do
			if child:name() == "render_template_database" and child:has_parameter("name") then
				cat_print("debug", "render_templates", child:parameter("name"))
				Application:reload_render_template_database(Idstring(child:parameter("name")))
			end
		end
	end

	local shader_libs_node = DB:has("shader_libs", self.SHADER_LIB_PATH) and DB:load_node("shader_libs", self.SHADER_LIB_PATH)

	if shader_libs_node then
		for child in shader_libs_node:children() do
			if child:name() == "shaders" and child:has_parameter("name") then
				cat_print("debug", "shader_config", child:parameter("name"))
				Application:reload_shader_lib(Idstring(child:parameter("name")))
			end
		end
	end

	if not load_only then
		self:_find_render_template()
	end
end

function CoreMaterialEditor:_save_current()
	if self._material_config_path and self._material_config_node and self:_data_diff() and EWS:message_box(self._main_frame, "Do you want to save the current settings?", "Open", "YES_NO,ICON_QUESTION", Vector3(-1, -1, -1)) == "YES" then
		self:_save_to_disk(self._material_config_path)
		EWS:MessageDialog(self._main_frame, "'" .. managers.database:entry_name(self._material_config_path) .. "' saved.", "Save Complete", "OK,ICON_INFORMATION"):show_modal()
	end
end

function CoreMaterialEditor:_save_to_disk(path)
	local node = self._material_config_node:to_real_node()
	local valid, str = self:_check_valid_xml_on_save(node)

	if not valid then
		EWS:message_box(self._main_frame, "You have customized one or more texture channel(s) in the material but you have not specified any texture(s).\n\n" .. str .. "\nDefaulting to " .. self.DEFAULT_TEXTURE .. ".", "Writing To Disk", "OK,ICON_WARNING", Vector3(-1, -1, -1))
		self:_set_channels_default_texture(node)
	end

	managers.database:save_node(node, path)

	local global_file = self:_save_global_to_disk(false)

	Application:data_compile({
		target_db_name = "all",
		send_idstrings = false,
		preprocessor_definitions = "preprocessor_definitions",
		verbose = false,
		platform = string.lower(SystemInfo:platform():s()),
		source_root = managers.database:base_path(),
		target_db_root = Application:base_path() .. "assets",
		source_files = {
			managers.database:entry_relative_path(path),
			managers.database:entry_relative_path(global_file)
		}
	})
	DB:reload()
	managers.database:clear_all_cached_indices()
	self:_update_output()

	if not self._disable_live_feedback then
		Application:reload_material_config(Idstring(managers.database:entry_path(path)))
	end

	self._text_in_node = node:to_xml()
end

function CoreMaterialEditor:_save_global_to_disk(recompile)
	local global = self._global_material_config_node:to_real_node()
	local global_file = self._global_material_config_path

	managers.database:save_node(global, global_file)

	if recompile then
		Application:data_compile({
			target_db_name = "all",
			send_idstrings = false,
			preprocessor_definitions = "preprocessor_definitions",
			verbose = false,
			platform = string.lower(SystemInfo:platform():s()),
			source_root = managers.database:base_path(),
			target_db_root = Application:base_path() .. "assets",
			source_files = {
				managers.database:entry_relative_path(global_file)
			}
		})
		DB:reload()
		managers.database:clear_all_cached_indices()
	end

	self._text_in_global_node = self._global_material_config_node:to_xml()

	return global_file
end

function CoreMaterialEditor:_data_diff()
	return self._text_in_node ~= self._material_config_node:to_xml() or self._text_in_global_node ~= self._global_material_config_node:to_xml()
end

function CoreMaterialEditor:_reset_diff()
	self._text_in_node = ""
end

function CoreMaterialEditor:_ok_by_law(node)
	local rule = node:parameter("rule")

	if rule and rule ~= "" then
		local code = ""

		for k, v in pairs(self._shader_defines) do
			code = code .. "local " .. k .. " = " .. tostring(v._checked) .. "; "
		end

		code = code .. "return " .. rule

		return assert(loadstring(code))()
	end

	return true
end

function CoreMaterialEditor:_is_options_valid_by_law()
	for k, v in pairs(self._shader_defines) do
		if v._checked and not self:_ok_by_law(v._define_node) then
			return false, v._define_node:parameter("rule_msg") or "This setup is not valid!"
		end
	end

	return true, ""
end

function CoreMaterialEditor:_load_shader_options()
	local rt_name = self._current_material_node:parameter("render_template")
	local v = RenderTemplateDatabase:render_template_name_to_defines(rt_name)

	self._compilable_shader_combo_box:set_value(v.shader)
	self:_build_shader_options()
	self:_set_shader_options(v.defines)
end

function CoreMaterialEditor:_find_render_template()
	local t = {}

	for k, v in pairs(self._shader_defines) do
		if v._checked then
			table.insert(t, v._define_node:parameter("name"))
		end
	end

	self._current_render_template_name = RenderTemplateDatabase:render_template_name_from_defines(self._compilable_shader_combo_box:get_value(), t)
	self._current_render_template = RenderTemplateDatabase:render_template(self._current_render_template_name:id())
	local msg = ""

	if not self._current_render_template then
		msg = "No valid render template found!"
		self._current_render_template_name = nil

		self._compile_button:set_enabled(true)
		self._parameter_collapse_box:lower_panel():set_enabled(false)
	else
		self._compile_button:set_enabled(true)
		self._parameter_collapse_box:lower_panel():set_enabled(true)
		self._current_material_node:set_parameter("render_template", self._current_render_template_name)
		self:_load_parent_dropdown()
		self:_create_parameter_panel()
	end

	self._compile_info_text:set_value(msg)
	self._main_frame_status_bar:set_status_text(msg)
	self:_clean_parameters()
	self:_update_output()
end

function CoreMaterialEditor:_clean_parameters()
	if self._current_render_template then
		local remove_list = {}
		local variables = self._current_render_template:variables()

		for param in self._current_material_node:children() do
			local found = nil

			for _, var in ipairs(variables) do
				if param:parameter("type") ~= "texture" and param:parameter("name") == var.name:s() or param:name() == var.name:s() then
					found = true

					break
				end
			end

			if not found then
				table.insert(remove_list, param)
			end
		end

		for _, param in ipairs(remove_list) do
			self._current_material_node:remove_child_at(self._current_material_node:index_of_child(param))
		end
	end
end

function CoreMaterialEditor:_update_interface_after_material_list_change(listbox_select_material)
	self:_freeze_frame()
	self:_load_material_list(listbox_select_material)
	self:_unfreeze_frame()

	self._current_material_node = nil

	self._shader_collapse_box:lower_panel():set_enabled(false)
	self._parameter_collapse_box:lower_panel():set_enabled(false)
end

function CoreMaterialEditor:_create_new_material_config(path)
	local node = Node("materials")

	node:set_parameter("version", self.MATERIAL_CONFIG_VERSION_TAG)
	self:_load_node(path, node)
	self:_save_to_disk(path)
end

function CoreMaterialEditor:_load_node(path, node)
	local prev_node = self._material_config_node
	local prev_entry = self._material_config_path
	local new_node = node or managers.database:load_node(path)
	self._material_config_path = path
	self._material_config_node = CoreSmartNode:new(new_node)

	if not self:version_check(self._material_config_path, self._material_config_node, true) then
		self._material_config_path = prev_entry
		self._material_config_node = prev_node

		return false
	end

	self._global_material_config_path = managers.database:base_path() .. self._global_material_config_name
	self._global_material_config_node = CoreSmartNode:new(managers.database:load_node(self._global_material_config_path))
	self._text_in_global_node = self._global_material_config_node:to_xml()

	self._main_frame:set_title(managers.database:entry_name(path) .. " - " .. self.FRAME_TITLE)

	self._text_in_node = self._material_config_node:to_xml()

	self:_update_interface_after_material_list_change()
	self:_update_output()

	return true
end

function CoreMaterialEditor:_update_output()
	if not self._lock_output and self._material_config_node and self._output_collapse_box:expanded() then
		self._output_text_ctrl:set_value(self._material_config_node:to_xml())
		self._global_text_ctrl:set_value(self._global_material_config_node:to_xml())
	end
end

function CoreMaterialEditor:_layout_all()
	self._main_scroll_window:fit_inside()
end

function CoreMaterialEditor:_layout_output()
	self._output_collapse_box:panel():layout()
	self:_layout_all()
end

function CoreMaterialEditor:_set_shader_options(options)
	for k, v in pairs(self._shader_defines) do
		v._check_box:set_state(0)

		v._checked = false

		for _, option in pairs(options) do
			if k == option then
				v._check_box:set_state(1)

				v._checked = true
			end
		end
	end
end

function CoreMaterialEditor:_load_material_list(listbox_select_material)
	self._material_nodes = {}

	self._material_list_box:clear()

	if self._material_config_node then
		for material in self._material_config_node:children() do
			if material:name() == "material" then
				local name = material:parameter("name")
				self._material_nodes[name] = material
				local index = self._material_list_box:append(name)

				if listbox_select_material == name then
					-- Nothing
				end
			end
		end
	end
end

function CoreMaterialEditor:_check_loaded_shader_sources(t, s)
	for i, source in ipairs(t) do
		if source._entry == s then
			return i
		end
	end
end

function CoreMaterialEditor:_load_shader_sources()
	self._shader_sources = {}

	self:_load_shader_sources_from_db(self._shader_sources)
	self:_load_shader_sources_from_db(self._shader_sources)
end

function CoreMaterialEditor:_load_shader_sources_from_db(t)
	local sources = managers.database:list_entries_of_type("shader_source")

	for _, source in ipairs(sources) do
		local node = DB:load_node("shader_source", source)

		if node:name() == "shader_library" then
			local loaded = self:_check_loaded_shader_sources(t, source)

			if loaded then
				table.remove(t, loaded)
			end

			table.insert(t, {
				_entry = source,
				_node = node
			})
		end
	end
end

function CoreMaterialEditor:_load_shader_dropdown()
	self:_freeze_frame()

	self._compilable_shaders = {}

	self._compilable_shader_combo_box:clear()

	for _, source in ipairs(self._shader_sources) do
		local compilable_shaders = self:_get_node(source._node, "compilable_shaders")

		if compilable_shaders then
			local shaders = self:_get_all_nodes(compilable_shaders, "shader")

			for _, shader in ipairs(shaders) do
				local editor_node = self:_get_node(shader, "editor")

				if editor_node then
					local name = shader:parameter("name")
					self._compilable_shaders[name] = {
						_entry = source._entry,
						_node = shader
					}

					self._compilable_shader_combo_box:append(name)
				end
			end
		end
	end

	self._compilable_shader_combo_box:set_value(self.DEFAULT_COMPILABLE_SHADER)
	self:_unfreeze_frame()
end

function CoreMaterialEditor:_load_parent_dropdown()
	self:_freeze_frame()
	self._parent_combo_box:clear()
	self._parent_combo_box:append("[NONE]")

	self._parent_materials = {}

	if self._global_material_config_node then
		for material in self._global_material_config_node:children() do
			local name = material:parameter("name")
			self._parent_materials[name] = material

			self._parent_combo_box:append(name)
		end
	end

	self._parent_combo_box:set_value("[NONE]")
	self:_unfreeze_frame()
end
