require("core/lib/utils/dev/tools/cutscene_editor/CoreCutsceneBatchOptimizer")
require("core/lib/utils/dev/tools/cutscene_editor/CoreCutsceneProjectMappingPanel")

CoreCutsceneBatchOptimizerDialog = CoreCutsceneBatchOptimizerDialog or class()
local JOB_LIST_FILE_SPEC = "Job List (*.boj)|*.boj"
local commands = CoreCommandRegistry:new()

commands:add({
	id = "NEW_JOB_LIST",
	label = "&New Job List",
	key = "Ctrl+N",
	help = "Clears the job list so you can start with a blank slate"
})
commands:add({
	id = "DEFAULT_JOB_LIST",
	label = "&Default Job List",
	key = "Ctrl+D",
	help = "Clears the job list and populates it with all cutscene projects in the database"
})
commands:add({
	id = "OPEN_JOB_LIST",
	label = "&Open Job List...",
	key = "Ctrl+O",
	help = "Opens an existing job list"
})
commands:add({
	id = "SAVE_JOB_LIST",
	label = "&Save Job List",
	key = "Ctrl+S",
	help = "Saves the current job list to disk"
})
commands:add({
	id = "SAVE_JOB_LIST_AS",
	label = "&Save Job List As...",
	help = "Saves the current job list to disk under a new name"
})
commands:add({
	id = "EXIT",
	label = "E&xit",
	help = "Closes this window"
})

function CoreCutsceneBatchOptimizerDialog:init(parent_window)
	self.__window = EWS:Frame("Batch Export to Game", Vector3(100, 500, 0), Vector3(400, 400, 0), "DEFAULT_DIALOG_STYLE,RESIZE_BORDER,FRAME_FLOAT_ON_PARENT", parent_window)

	self.__window:set_icon(CoreEWS.image_path("film_reel_16x16.png"))
	self.__window:set_min_size(Vector3(400, 321, 0))
	self.__window:set_background_colour((EWS:get_system_colour("3DFACE") * 255):unpack())
	self.__window:connect("EVT_CLOSE_WINDOW", callback(self, self, "_on_exit"))

	local function connect_command(command_id, callback_name, callback_data)
		callback_name = callback_name or "_on_" .. string.lower(command_id)
		callback_data = callback_data or ""

		self.__window:connect(commands:id(command_id), "EVT_COMMAND_MENU_SELECTED", callback(self, self, callback_name), callback_data)
	end

	connect_command("NEW_JOB_LIST")
	connect_command("DEFAULT_JOB_LIST")
	connect_command("OPEN_JOB_LIST")
	connect_command("SAVE_JOB_LIST")
	connect_command("SAVE_JOB_LIST_AS")
	connect_command("EXIT")

	local sizer = EWS:BoxSizer("VERTICAL")

	self.__window:set_sizer(sizer)

	local projects_sizer = EWS:StaticBoxSizer(self.__window, "VERTICAL", "Cutscene Projects to Export")
	self.__projects = core_or_local("CutsceneProjectMappingPanel", self.__window)

	self.__projects:add_to_sizer(projects_sizer, 1, 0, "EXPAND")
	sizer:add(projects_sizer, 1, 5, "ALL,EXPAND")

	local buttons_panel = self:_create_buttons_panel(self.__window)

	sizer:add(buttons_panel, 0, 4, "ALL,EXPAND")
	self.__window:set_menu_bar(self:_create_menu_bar())
	self.__window:set_status_bar(EWS:StatusBar(self.__window))
	self.__window:set_status_bar_pane(0)
	self.__window:set_visible(true)
end

function CoreCutsceneBatchOptimizerDialog:update(time, delta_time)
	if not self.__window then
		return true
	end

	if self.__progress_dialog then
		assert(self.__batch)

		local project_count = self.__batch:max_queue_size()
		local remaining_count = self.__batch:queue_size()
		local was_aborted = not self.__progress_dialog:update_bar(project_count - remaining_count, self:_progress_message(self.__batch:next_project()))

		if remaining_count == 0 then
			self:_destroy()
		else
			self.__batch:consume_project()
		end
	end

	return false
end

function CoreCutsceneBatchOptimizerDialog:_create_menu_bar()
	local file_menu = commands:wrap_menu(EWS:Menu(""))

	file_menu:append_command("NEW_JOB_LIST")
	file_menu:append_command("DEFAULT_JOB_LIST")
	file_menu:append_command("OPEN_JOB_LIST")
	file_menu:append_command("SAVE_JOB_LIST")
	file_menu:append_command("SAVE_JOB_LIST_AS")
	file_menu:append_separator()
	file_menu:append_command("EXIT")

	local menu_bar = EWS:MenuBar()

	menu_bar:append(file_menu:wrapped_object(), "&File")

	return menu_bar
end

function CoreCutsceneBatchOptimizerDialog:_create_buttons_panel(parent)
	local panel = EWS:Panel(parent)
	local sizer = EWS:BoxSizer("HORIZONTAL")

	panel:set_sizer(sizer)

	local export_button = EWS:Button(panel, "Export")

	export_button:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "_on_export_button_clicked"), export_button)

	local close_button = EWS:Button(panel, "Close")

	close_button:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "_on_exit"), close_button)
	sizer:add(export_button, 1, 1, "RIGHT,EXPAND")
	sizer:add(close_button, 1, 2, "LEFT,EXPAND")

	return panel
end

function CoreCutsceneBatchOptimizerDialog:_destroy()
	if alive(self.__progress_dialog) then
		self.__progress_dialog:destroy()
	end

	self.__progress_dialog = nil

	if self.__projects then
		self.__projects:destroy()
	end

	self.__projects = nil

	if alive(self.__window) then
		self.__window:destroy()
	end

	self.__window = nil
	self.__batch = nil
end

function CoreCutsceneBatchOptimizerDialog:_progress_message(project)
	return project == nil and "Done!" or string.format("Exporting %s", project)
end

function CoreCutsceneBatchOptimizerDialog:_open_job_list(input_path)
	local mappings = read_lua_representation_from_path(input_path)

	self.__projects:set_mappings(mappings)

	self.__current_job_list_path = input_path
end

function CoreCutsceneBatchOptimizerDialog:_save_job_list(output_path)
	local mappings = self.__projects:mappings()

	write_lua_representation_to_path(mappings, output_path)

	self.__current_job_list_path = output_path
end

function CoreCutsceneBatchOptimizerDialog:_default_mappings_for_all_projects()
	local project_names = managers.database:list_entries_of_type("cutscene_project")
	local mappings = table.remap(project_entries, function (_, name)
		return name, self:_default_optimized_cutscene_name(name)
	end)

	return mappings
end

function CoreCutsceneBatchOptimizerDialog:_default_optimized_cutscene_name(project_name)
	return "optimized_" .. string.gsub(string.gsub(project_name, "^story_", ""), "^optimized_", "")
end

function CoreCutsceneBatchOptimizerDialog:_request_input_file_from_user(message, wildcard)
	local dialog = EWS:FileDialog(self.__window, message, "", "", assert(wildcard, "Must supply a wildcard spec. Check wxWidgets docs."), "OPEN,FILE_MUST_EXIST")

	return dialog:show_modal() and dialog:get_path() or nil
end

function CoreCutsceneBatchOptimizerDialog:_request_output_file_from_user(message, wildcard, default_file)
	local dialog = EWS:FileDialog(self.__window, message, "", default_file or "", assert(wildcard, "Must supply a wildcard spec. Check wxWidgets docs."), "SAVE,OVERWRITE_PROMPT")

	return dialog:show_modal() and dialog:get_path() or nil
end

function CoreCutsceneBatchOptimizerDialog:_on_export_button_clicked(sender)
	local projects_to_export = self.__projects:mappings()

	if not table.empty(projects_to_export) then
		self.__batch = core_or_local("CutsceneBatchOptimizer")

		for project, output in pairs(projects_to_export) do
			self.__batch:add_project(project, output)
		end

		self.__progress_dialog = EWS:ProgressDialog(self.__window, "Exporting Projects...", "Preparing export", self.__batch:queue_size(), "PD_AUTO_HIDE,PD_APP_MODAL,PD_CAN_ABORT,PD_REMAINING_TIME")

		self.__progress_dialog:set_visible(true)
	end
end

function CoreCutsceneBatchOptimizerDialog:_on_new_job_list()
	local ok_to_proceed = self:_verify_user_intent("clearing")

	if ok_to_proceed then
		self.__projects:clear()

		self.__current_job_list_path = nil
	end

	return ok_to_proceed
end

function CoreCutsceneBatchOptimizerDialog:_on_default_job_list()
	local ok_to_proceed = self:_on_new_job_list()

	if ok_to_proceed then
		self.__projects:set_mappings(self:_default_mappings_for_all_projects())
	end
end

function CoreCutsceneBatchOptimizerDialog:_on_open_job_list()
	local ok_to_proceed = self:_verify_user_intent("opening")

	if ok_to_proceed then
		local input_path = self:_request_input_file_from_user("Open Job List", JOB_LIST_FILE_SPEC)

		if input_path then
			self:_open_job_list(input_path)
		end
	end
end

function CoreCutsceneBatchOptimizerDialog:_on_save_job_list()
	if self.__current_job_list_path then
		self:_save_job_list(self.__current_job_list_path)

		return true
	else
		return self:_on_save_job_list_as()
	end
end

function CoreCutsceneBatchOptimizerDialog:_on_save_job_list_as()
	local output_path = self:_request_output_file_from_user("Save Job List", JOB_LIST_FILE_SPEC, "untitled.boj")

	if output_path then
		self:_save_job_list(output_path)
	end

	return output_path ~= nil
end

function CoreCutsceneBatchOptimizerDialog:_on_exit()
	local ok_to_proceed = self:_verify_user_intent("closing")

	if ok_to_proceed then
		self:_destroy()
	end

	return ok_to_proceed
end

function CoreCutsceneBatchOptimizerDialog:_verify_user_intent(operation)
	if table.empty(self.__projects:mappings()) then
		return true
	end

	local choice = EWS:MessageDialog(self.__window, "Do you want to save the current job list before " .. operation .. "?", "Save Changes?", "YES_NO,CANCEL,YES_DEFAULT,ICON_EXCLAMATION"):show_modal()

	if choice == "ID_YES" then
		if not self:_on_save_job_list() then
			return false
		end
	elseif choice == "ID_CANCEL" then
		return false
	end

	return true
end
