CoreDBDialog = CoreDBDialog or class()

function CoreDBDialog:init(type_to_pick, cb_self, cb, db)
	self._browser_data = {
		type_to_pick = type_to_pick,
		cb = cb,
		cb_self = cb_self
	}
	self._window = CoreDatabaseBrowser:new(self._browser_data, db)
end

function CoreDBDialog:update(t, dt)
	if self._window then
		self._window:update(t, dt)
	end

	if self._browser_data.destroy == "OK" then
		self._window = nil

		if self._browser_data.cb then
			self._browser_data.cb(self._browser_data.cb_self)
		end

		return "OK"
	elseif self._browser_data.destroy then
		self._window = nil

		return "CANCEL"
	end
end

function CoreDBDialog:get_value()
	return self._browser_data.entry
end

function CoreDBDialog:destroy()
	if self._window then
		self._window:close()
	end
end

CoreDatabaseBrowser = CoreDatabaseBrowser or class()
CoreDatabaseBrowser.LC_BUGFIX = true

function CoreDatabaseBrowser:init(browser_data, db)
	min_exe_version("1.0.0.7607", "CoreDatabaseBrowser")

	self._active_database = db or ProjectDatabase
	self._browser_data = browser_data

	self:create_main_frame()
	self:on_reload()

	if Application:vista_userfolder_enabled() then
		EWS:MessageDialog(self._main_frame, "You cannot commit or edit files when the vista user folder is enabled. Run the database browser from the editor instead.", "Error", "OK,ICON_ERROR"):show_modal()
		managers.toolhub:close("Database Browser")
	end

	self._dirty_flag = true

	self:check_news(true)
end

function CoreDatabaseBrowser:check_open()
	if open_editor and not self._browser_data then
		local frame = EWS:Frame("", Vector3(0, 0, 0), Vector3(0, 0, 0), "")

		EWS:MessageDialog(frame, "Please close the " .. open_editor .. " before open this editor.", "Conflict", "OK,ICON_INFORMATION"):show_modal()
		frame:destroy()
		managers.toolhub:close("Unit Editor")

		return true
	else
		open_editor = "Unit Editor"
	end

	return false
end

function CoreDatabaseBrowser:create_main_frame()
	local style = "FRAME_FLOAT_ON_PARENT,DEFAULT_FRAME_STYLE"

	if self._browser_data then
		style = "FRAME_FLOAT_ON_PARENT,FRAME_TOOL_WINDOW,CAPTION"
	end

	self._main_frame = EWS:Frame("Database Browser", Vector3(100, 400, 0), Vector3(500, 500, 0), style, Global.frame)

	self._main_frame:set_icon(CoreEWS.image_path("database_browser_16x16.png"))

	local menu_bar = EWS:MenuBar()
	local file_menu = EWS:Menu("")

	file_menu:append_item("MOVE", "Move\tCtrl+M", "")
	file_menu:append_item("RELOAD", "Reload\tCtrl+L", "")
	file_menu:append_item("REMOVE", "Remove\tCtrl+R", "")
	file_menu:append_item("RENAME", "Rename\tCtrl+N", "")
	file_menu:append_item("IMPORT", "Import XML", "")
	file_menu:append_item("VIEW_METADATA", "View Metadata", "")
	file_menu:append_item("METADATA", "Set Metadata", "")
	file_menu:append_separator()
	file_menu:append_item("NEWS", "Get Latest News", "")
	file_menu:append_separator()
	file_menu:append_item("EXIT", "Exit", "")
	menu_bar:append(file_menu, "File")

	if not self._browser_data then
		self._db_menu = EWS:Menu("")

		self._db_menu:append_radio_item("DB_PROJECT", "Project", "")
		self._db_menu:append_radio_item("DB_CORE", "Core", "")
		self._db_menu:set_checked("DB_PROJECT", true)
		menu_bar:append(self._db_menu, "Database")
	end

	self._op_menu = EWS:Menu("")

	self._op_menu:append_check_item("OP_AUTO_CONVERT_TEXTURES", "Auto Convert Textures", "")
	self._op_menu:set_checked("OP_AUTO_CONVERT_TEXTURES", true)
	menu_bar:append(self._op_menu, "Options")
	self._main_frame:set_menu_bar(menu_bar)
	self._main_frame:connect("MOVE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_move"), "")
	self._main_frame:connect("RELOAD", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_reload"), "")
	self._main_frame:connect("REMOVE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_remove"), "")
	self._main_frame:connect("RENAME", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_rename"), "")
	self._main_frame:connect("IMPORT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_import_xml"), "")
	self._main_frame:connect("METADATA", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_set_metadata"), "")
	self._main_frame:connect("VIEW_METADATA", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_view_metadata"), "")
	self._main_frame:connect("NEWS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_check_news"), "")
	self._main_frame:connect("EXIT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_close"), "")
	self._main_frame:connect("DB_PROJECT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_set_db"), ProjectDatabase)
	self._main_frame:connect("DB_CORE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_set_db"), CoreDatabase)
	self._main_frame:connect("", "EVT_CLOSE_WINDOW", callback(self, self, "on_close"), "")

	local main_box = EWS:BoxSizer("VERTICAL")
	self._main_notebook = EWS:Notebook(self._main_frame, "", "")

	self._main_notebook:connect("", "EVT_COMMAND_NOTEBOOK_PAGE_CHANGING", callback(self, self, "on_notebook_changing"), "")
	main_box:add(self._main_notebook, 2, 0, "EXPAND")

	self._search_box = {
		panel = EWS:Panel(self._main_notebook, "", ""),
		panel_box = EWS:BoxSizer("VERTICAL")
	}
	local top_search_box = EWS:BoxSizer("HORIZONTAL")
	self._search_box.type_combobox = EWS:ComboBox(self._search_box.panel, "", "", "CB_READONLY,CB_SORT")

	self._search_box.type_combobox:connect("", "EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "on_read_database"), "")
	self:append_all_types(self._search_box.type_combobox)
	self._search_box.type_combobox:append("[all]")
	top_search_box:add(self._search_box.type_combobox, 1, 0, "EXPAND")

	self._search_box.search_text_ctrl = EWS:TextCtrl(self._search_box.panel, "", "", "TE_CENTRE")

	self._search_box.search_text_ctrl:connect("", "EVT_COMMAND_TEXT_UPDATED", callback(self, self, "on_search"), "")
	top_search_box:add(self._search_box.search_text_ctrl, 2, 0, "EXPAND")
	self._search_box.panel_box:add(top_search_box, 0, 0, "EXPAND")

	self._search_box.list_box = EWS:ListBox(self._search_box.panel, "", "LB_SORT,LB_EXTENDED")

	self._search_box.list_box:connect("", "EVT_COMMAND_LISTBOX_SELECTED", callback(self, self, "on_select"), "")

	if self._browser_data then
		self._search_box.list_box:connect("", "EVT_COMMAND_LISTBOX_DOUBLECLICKED", callback(self, self, "on_close"), "OK")
	end

	self._search_box.panel_box:add(self._search_box.list_box, 2, 0, "EXPAND")
	self._search_box.panel:set_sizer(self._search_box.panel_box)
	self._main_notebook:add_page(self._search_box.panel, "Search View", true)

	self._tree_box = {
		panel = EWS:Panel(self._main_notebook, "", ""),
		panel_box = EWS:BoxSizer("VERTICAL")
	}
	local top_search_box = EWS:BoxSizer("HORIZONTAL")
	self._tree_box.type_combobox = EWS:ComboBox(self._tree_box.panel, "", "", "CB_READONLY,CB_SORT")

	self._tree_box.type_combobox:connect("", "EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "on_read_database"), "")
	self:append_all_types(self._tree_box.type_combobox)
	self._tree_box.type_combobox:append("[all]")
	top_search_box:add(self._tree_box.type_combobox, 1, 0, "EXPAND")

	self._tree_box.search_text_ctrl = EWS:TextCtrl(self._tree_box.panel, "", "", "TE_CENTRE")

	self._tree_box.search_text_ctrl:connect("", "EVT_COMMAND_TEXT_UPDATED", callback(self, self, "on_search"), "")
	top_search_box:add(self._tree_box.search_text_ctrl, 2, 0, "EXPAND")
	self._tree_box.panel_box:add(top_search_box, 0, 0, "EXPAND")

	self._tree_box.tree_ctrl = EWS:TreeCtrl(self._tree_box.panel, "", "TR_MULTIPLE,TR_HAS_BUTTONS")

	self._tree_box.tree_ctrl:connect("", "EVT_COMMAND_TREE_SEL_CHANGED", callback(self, self, "on_tree_ctrl_change"), "")

	if self._browser_data then
		self._tree_box.tree_ctrl:connect("", "EVT_COMMAND_TREE_ITEM_ACTIVATED", callback(self, self, "on_close"), "OK")
	end

	self._tree_box.panel_box:add(self._tree_box.tree_ctrl, 2, 0, "EXPAND")
	self._tree_box.panel:set_sizer(self._tree_box.panel_box)
	self._main_notebook:add_page(self._tree_box.panel, "Tree View", false)

	self._local_box = {
		panel = EWS:Panel(self._main_notebook, "", ""),
		panel_box = EWS:BoxSizer("VERTICAL")
	}
	local top_local_box = EWS:BoxSizer("HORIZONTAL")
	self._local_box.type_combobox = EWS:ComboBox(self._local_box.panel, "", "", "CB_READONLY,CB_SORT")

	self._local_box.type_combobox:connect("", "EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "on_read_database"), "")
	self:append_all_types(self._local_box.type_combobox)
	self._local_box.type_combobox:append("[all]")
	self._local_box.type_combobox:set_value("[all]")
	top_local_box:add(self._local_box.type_combobox, 1, 0, "EXPAND")

	self._local_box.search_text_ctrl = EWS:TextCtrl(self._local_box.panel, "", "", "TE_CENTRE")

	self._local_box.search_text_ctrl:connect("", "EVT_COMMAND_TEXT_UPDATED", callback(self, self, "on_search_local_changes"), "")
	top_local_box:add(self._local_box.search_text_ctrl, 2, 0, "EXPAND")
	self._local_box.panel_box:add(top_local_box, 0, 0, "EXPAND")

	self._local_box.list_box = EWS:ListBox(self._local_box.panel, "", "LB_SORT,LB_EXTENDED")

	self._local_box.list_box:connect("", "EVT_COMMAND_LISTBOX_SELECTED", callback(self, self, "on_select"), "")
	self:append_local_changes()
	self._local_box.panel_box:add(self._local_box.list_box, 2, 0, "EXPAND")

	local bottom_local_box = EWS:BoxSizer("HORIZONTAL")
	self._local_box.commit_btn = EWS:Button(self._local_box.panel, "Commit", "", "")

	self._local_box.commit_btn:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_commit_btn"), "")
	bottom_local_box:add(self._local_box.commit_btn, 1, 0, "EXPAND")

	self._local_box.revert_btn = EWS:Button(self._local_box.panel, "Revert", "", "")

	self._local_box.revert_btn:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_revert_btn"), "")
	bottom_local_box:add(self._local_box.revert_btn, 1, 0, "EXPAND")
	self._local_box.panel_box:add(bottom_local_box, 0, 0, "EXPAND")
	self._local_box.panel:set_sizer(self._local_box.panel_box)

	if not self._browser_data then
		self._main_notebook:add_page(self._local_box.panel, "Local Changes", false)
	else
		self._local_box.panel:set_visible(false)
	end

	self._preview_panel = EWS:Panel(self._main_frame, "", "")
	local text_box = EWS:BoxSizer("VERTICAL")
	local msg = EWS:StaticText(self._preview_panel, "No preview!", "", "ALIGN_CENTER_VERTICAL")

	text_box:add(msg, 1, 4, "EXPAND,ALL")
	self._preview_panel:set_sizer(text_box)
	main_box:add(self._preview_panel, 1, 0, "EXPAND")

	self._preview_text_ctrl = CoreEWS:XMLTextCtrl(self._main_frame, nil, nil, nil, "TE_MULTILINE,TE_RICH2,TE_DONTWRAP,TE_READONLY")

	self._preview_text_ctrl:text_ctrl():set_visible(false)
	main_box:add(self._preview_text_ctrl:text_ctrl(), 1, 0, "EXPAND")

	self._preview_image = EWS:BitmapButton(self._main_frame, CoreEWS.image_path("magnifying_glass_32x32.png"), "", "")

	self._preview_image:set_visible(false)
	main_box:add(self._preview_image, 1, 0, "EXPAND")

	if self._browser_data then
		local button_box = EWS:BoxSizer("HORIZONTAL")
		self._ok_btn = EWS:Button(self._main_frame, "OK", "", "")

		self._ok_btn:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_close"), "OK")
		button_box:add(self._ok_btn, 1, 0, "EXPAND")

		self._cancel_btn = EWS:Button(self._main_frame, "Cancel", "", "")

		self._cancel_btn:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_close"), "")
		button_box:add(self._cancel_btn, 1, 0, "EXPAND")
		main_box:add(button_box, 0, 0, "EXPAND")
	end

	self._open_xml_file_dialog = EWS:FileDialog(self._main_frame, "Import XML", Application:base_path(), "", "XML files (*.xml)|*.xml", "OPEN,FILE_MUST_EXIST")
	self._remove_dialog = EWS:MessageDialog(self._main_frame, "This will delete the selected entry(s). Proceed?", "Remove", "YES_NO,ICON_QUESTION")
	self._invalid_path_dialog = EWS:MessageDialog(self._main_frame, "The path you have chosen is invalid!", "Error", "OK,ICON_ERROR")
	self._revert_dialog = EWS:MessageDialog(self._main_frame, "Do you want to revert the selected entry(s)?", "Revert", "YES_NO,ICON_QUESTION")
	self._commit_dialog = EWS:MessageDialog(self._main_frame, "Do you want to commit the selected entry(s)?", "Commit", "YES_NO,ICON_QUESTION")
	self._not_available_dialog = EWS:MessageDialog(self._main_frame, "This option is not available in this mode.", "Unavailable", "OK,ICON_INFORMATION")
	self._dirty_database_dialog = EWS:MessageDialog(self._main_frame, "The database is dirty and it needs to be reloaded.", "Database", "OK,ICON_INFORMATION")
	self._rename_error_dialog = EWS:MessageDialog(self._main_frame, "Duplicated entry!", "Error", "OK,ICON_ERROR")
	self._commit_error_dialog = EWS:MessageDialog(self._main_frame, "Could not commit the selected entry(s)!", "Error", "OK,ICON_ERROR")
	self._no_nodes_dialog = EWS:MessageDialog(self._main_frame, "You need to have at least one node in your XML file.", "Error", "OK,ICON_ERROR")
	self._move_dialog = CoreDatabaseBrowserMoveDialog:new(self, self._main_frame)
	self._import_dialog = CoreDatabaseBrowserImportDialog:new(self, self._main_frame)
	self._metadata_dialog = CoreDatabaseBrowserMetadataDialog:new(self._main_frame)
	self._comment_dialog = CoreDatabaseBrowserInputDialog:new(self._main_frame)
	self._rename_dialog = CoreDatabaseBrowserRenameDialog:new(self._main_frame)

	self._main_frame:set_sizer(main_box)
	self._main_frame:set_visible(true)
end

function CoreDatabaseBrowser:on_set_db(data, event)
	self._db_menu:set_checked("DB_PROJECT", false)
	self._db_menu:set_checked("DB_CORE", false)
	self._db_menu:set_checked(event:get_id(), true)

	self._active_database = data

	self:on_read_database()
end

function CoreDatabaseBrowser:on_check_news()
	self:check_news()
end

function CoreDatabaseBrowser:check_news(new_only)
	local news = nil

	if new_only then
		news = managers.news:get_news("database_browser", self._main_frame)
	else
		news = managers.news:get_old_news("database_browser", self._main_frame)
	end

	if news then
		local str = nil

		for _, n in ipairs(news) do
			if not str then
				str = n
			else
				str = str .. "\n" .. n
			end
		end

		EWS:MessageDialog(self._main_frame, str, "New Features!", "OK,ICON_INFORMATION"):show_modal()
	end
end

function CoreDatabaseBrowser:on_dirty_entrys()
	if self._dirty_flag then
		cat_print("debug", "The database is dirty and it needs to be reloaded. RELOADING!")
	end

	self:on_reload()

	self._dirty_flag = true
end

function CoreDatabaseBrowser:on_search_local_changes()
	self:append_local_changes()
end

function CoreDatabaseBrowser:filter_local_changes(entry)
	return string.find(entry:name(), self._local_box.search_text_ctrl:get_value()) ~= nil
end

function CoreDatabaseBrowser:append_local_changes()
	local db_changes = self._active_database:local_changes()
	local change_table = {}
	self._local_changes = {}

	self._local_box.list_box:clear()

	for _, change in ipairs(db_changes) do
		if (self._local_box.type_combobox:get_value() == "[all]" or self._local_box.type_combobox:get_value() == change.entry:type()) and self:filter_local_changes(change.entry) then
			local describe = self:create_unique_name(change.entry)

			if not change_table[describe] then
				change_table[describe] = {}
			end

			if not change_table[describe].str then
				change_table[describe].str = change.change
			else
				change_table[describe].str = change_table[describe].str .. " : " .. change.change
			end

			change_table[describe].entry = change.entry

			if change.change == "REMOVE" then
				change_table[describe].change = "REMOVE"
			elseif (not change_table[describe].change or change.change == "SET_METADATA") and (change.change == "ADD" or change.change == "MODIFY") then
				change_table[describe].change = "ADD_OR_MODIFY"
			elseif not change_table[describe].change and change.change == "SET_METADATA" then
				change_table[describe].change = "SET_METADATA"
			end
		end
	end

	for describe, struct in pairs(change_table) do
		local str = describe .. " - " .. struct.str
		self._local_changes[str] = struct

		self._local_box.list_box:append(str)
	end
end

function CoreDatabaseBrowser:format_comment(str)
	local comment = ""

	for word in string.gmatch(str, "[%w%s_]+") do
		comment = comment .. word
	end

	return comment
end

function CoreDatabaseBrowser:is_entry_raw(entry)
	return entry:property("platform") == "raw" or entry:property("platform") == "ps3raw" or entry:property("platform") == "x360raw"
end

function CoreDatabaseBrowser:on_commit_btn()
	local conversion_dialog = self._op_menu:is_checked("OP_AUTO_CONVERT_TEXTURES") and EWS:MessageDialog(self._main_frame, "The Image Exporter Tool will try to convert this texture(s) for all other platforms.", "Conversion", "OK,ICON_INFORMATION") or nil

	if #self._local_box.list_box:selected_indices() > 0 and self._commit_dialog:show_modal() == "ID_YES" and self._comment_dialog:show_modal() then
		local comment = self:format_comment(self._comment_dialog:get_value())
		local commit_table = {}
		local progress = EWS:ProgressDialog(self._main_frame, "Commit", "", 100, "PD_AUTO_HIDE,PD_SMOOTH")

		for _, id in ipairs(self._local_box.list_box:selected_indices()) do
			commit_table[tostring(id)] = self._local_box.list_box:get_string(id)

			progress:update_bar(10)
		end

		local new_entrys = {}
		local i = 1

		for id_str, entry in pairs(commit_table) do
			if not self._local_changes[entry] then
				cat_print("debug", "############# commit_table #############")

				for id_str, entry in pairs(commit_table) do
					cat_print("debug", id_str, entry)
				end

				cat_print("debug", "############# self._local_changes #############")

				for k, v in pairs(self._local_changes) do
					cat_print("debug", k, v)
				end

				cat_print("debug", "############# self._local_box.list_box:selected_indices() #############")

				for _, id in ipairs(self._local_box.list_box:selected_indices()) do
					cat_print("debug", id, self._local_box.list_box:get_string(id))
				end

				cat_print("debug", "############# new_entrys #############")

				for k, v in ipairs(new_entrys) do
					cat_print("debug", k, v)
				end

				cat_print("debug", "############# failing entry #############")
				cat_print("debug", entry)
				cat_print("debug", "LC_BUGFIX: ", self.LC_BUGFIX)
				cat_print("debug", "failing entry index: ", i)
				error("REPORT THIS BUG TO: andreas.jonsson@grin.se (Send the entire log!)")
			end

			if self._local_changes[entry].change == "ADD_OR_MODIFY" and self._local_changes[entry].entry:type() == "texture" and (self:is_entry_raw(self._local_changes[entry].entry) or self._local_changes[entry].entry:property("platform") == "") then
				conversion_dialog = conversion_dialog and nil

				progress:update_bar(30, "Converting 3DC...")

				if not self.LC_BUGFIX then
					self:append_local_changes()
				end

				local x360_entry = self:convert_to_x360(self._local_changes[entry].entry)

				if x360_entry and x360_entry:valid() then
					table.insert(new_entrys, x360_entry)
				end

				progress:update_bar(50, "Converting GTF...")

				if not self.LC_BUGFIX then
					self:append_local_changes()
				end

				local ps3_entry = self:convert_to_ps3(self._local_changes[entry].entry)

				if ps3_entry and ps3_entry:valid() then
					table.insert(new_entrys, ps3_entry)
				end

				if not self.LC_BUGFIX then
					self:append_local_changes()
				end
			end

			i = i + 1
		end

		for _, entry in pairs(commit_table) do
			progress:update_bar(70, "Sending data...")
			table.insert(new_entrys, self._local_changes[entry].entry)
		end

		self._dirty_flag = false
		local commit_ret = nil

		while not commit_ret do
			commit_ret = self._active_database:commit_changes("[CoreDatabaseBrowser] " .. comment, new_entrys)

			if commit_ret == "LOCKED" then
				if EWS:message_box(self._main_frame, "The index is locked by another user... Do you want to retry?", "Retry", "YES_NO,ICON_QUESTION", Vector3(-1, -1, -1)) == "YES" then
					commit_ret = nil
				end
			elseif commit_ret == "FATAL" then
				EWS:message_box(self._main_frame, "A fatal error during commit occurred. (This could be caused by a connection problem.) Contact technical support!", "Fatal Error", "OK,ICON_ERROR", Vector3(-1, -1, -1))
			end
		end

		if commit_ret ~= "SUCCESS" then
			progress:update_bar(100)
			self._commit_error_dialog:show_modal()
		else
			progress:update_bar(100)
			EWS:MessageDialog(self._main_frame, "Success! You now need to close down the application and update your project.", "Success", "OK,ICON_INFORMATION"):show_modal()
		end

		self._active_database:load()
		self:on_read_database()
		self:append_local_changes()
	end
end

function CoreDatabaseBrowser:on_revert_btn()
	if #self._local_box.list_box:selected_indices() > 0 and self._revert_dialog:show_modal() == "ID_YES" then
		local flag = nil
		local revert_table = {}
		local progress = EWS:ProgressDialog(self._main_frame, "Revert", "Reverting data...", 100, "PD_AUTO_HIDE,PD_SMOOTH")

		progress:update_bar(0)

		for _, id in ipairs(self._local_box.list_box:selected_indices()) do
			revert_table[tostring(id)] = self._local_box.list_box:get_string(id)
		end

		progress:update_bar(50)

		for id_str, entry in pairs(revert_table) do
			self._dirty_flag = false

			if not self._active_database:revert_changes(self._local_changes[entry].entry) then
				self:append_local_changes()

				flag = true

				break
			end

			self:append_local_changes()
		end

		if flag then
			EWS:MessageDialog(self._main_frame, "Could not revert the selected entry(s)!", "Error", "OK,ICON_ERROR"):show_modal()
		end

		self._active_database:load()
		self:on_read_database()
		progress:update_bar(100)
	end
end

function CoreDatabaseBrowser:on_update_btn()
	self._active_database:load()
	self:append_local_changes()
	self:on_read_database()
end

function CoreDatabaseBrowser:on_import_xml()
	if not self._browser_data and self._open_xml_file_dialog:show_modal() then
		local dialog_path = self._open_xml_file_dialog:get_path()
		local path = dialog_path:sub(Application:base_path():len() + 1, dialog_path:len())
		local xml_root = File:parse_xml(path)

		if xml_root and xml_root:num_children() == 0 then
			self._no_nodes_dialog:show_modal()

			return
		end

		local node = nil

		if xml_root and self._import_dialog:show_modal() then
			node = Node(xml_root:name())

			self:create_node(node, xml_root)

			local entry_type, entry_name = self._import_dialog:get_value()

			if self._active_database:has(entry_type, entry_name) then
				self._active_database:remove(entry_type, entry_name, {})

				self._dirty_flag = false

				self._active_database:save()
				self._active_database:load()
			end

			self._active_database:save_node(node, self._active_database:add(entry_type, entry_name, {}, "xml"))

			self._dirty_flag = false

			self._active_database:save()
			self._active_database:load()
			self:on_read_database()
		end
	else
		self._not_available_dialog:show_modal()
	end
end

function CoreDatabaseBrowser:create_node(node, parent)
	for key, value in pairs(parent:parameter_map()) do
		node:set_parameter(key, value)
	end

	for child in parent:children() do
		self:create_node(node:make_child(child:name()), child)
	end
end

function CoreDatabaseBrowser:on_read_database()
	self._entrys = {}

	local function apply_type_filter(type_combobox, dest_type_combobox)
		local t = type_combobox:get_value()
		local entries = t == "[all]" and self._active_database:all(false) or self._active_database:all(false, t)

		dest_type_combobox:set_value(t)

		return entries, t
	end

	local data_table, database_type = nil
	local current_page = self._main_notebook:get_current_page()

	if current_page == self._main_notebook:get_page(0) then
		data_table, database_type = apply_type_filter(self._search_box.type_combobox, self._tree_box.type_combobox)
	elseif current_page == self._main_notebook:get_page(1) then
		data_table, database_type = apply_type_filter(self._tree_box.type_combobox, self._search_box.type_combobox)
	end

	for _, entry in ipairs(data_table or {}) do
		if not self._browser_data or entry:num_properties() == 0 or database_type ~= "texture" then
			self._entrys[self:create_unique_name(entry)] = entry
		end
	end

	self:on_search()
end

function CoreDatabaseBrowser:create_unique_name(entry)
	local str = entry:type() .. " - " .. entry:name()

	for key, value in pairs(entry:properties()) do
		str = str .. " : " .. value
	end

	return str
end

function CoreDatabaseBrowser:get_meta_data(selected_type, selected)
	local str = ""
	local entry = self._entrys[selected]

	if entry then
		for i = 1, entry:num_metadatas() do
			local meta_key = entry:metadata_key(i - 1)
			local meta_value = entry:metadata_value(i - 1)
			str = str .. meta_key .. "->" .. meta_value .. "\n"
		end
	end

	return str
end

function CoreDatabaseBrowser:on_view_metadata()
	local str = nil

	if self._main_notebook:get_current_page() == self._main_notebook:get_page(0) then
		if #self._search_box.list_box:selected_indices() > 0 then
			for i = 1, #self._search_box.list_box:selected_indices() do
				local selected = self._search_box.list_box:get_string(self._search_box.list_box:selected_indices()[i])
				local entry = self._active_database:lookup(self._entrys[selected]:type(), self._entrys[selected]:name(), self._entrys[selected]:properties())

				for k, v in pairs(entry:metadatas()) do
					str = (str or "") .. k .. "->" .. v .. "\n"
				end
			end
		end
	else
		local ids = self._tree_box.tree_ctrl:selected_items()

		if #ids > 0 then
			for i = 1, #ids do
				local selected = self._tree_box.tree_ctrl:get_item_text(ids[i])
				local entry = self._active_database:lookup(self._entrys[selected]:type(), self._entrys[selected]:name(), self._entrys[selected]:properties())

				for k, v in pairs(entry:metadatas()) do
					str = (str or "") .. k .. "->" .. v .. "\n"
				end
			end
		end
	end

	EWS:MessageDialog(self._main_frame, str or "No metadata!", "Metadata", "OK,ICON_INFORMATION"):show_modal()
end

function CoreDatabaseBrowser:on_set_metadata()
	if self._main_notebook:get_current_page() == self._main_notebook:get_page(0) then
		if #self._search_box.list_box:selected_indices() > 0 and self._metadata_dialog:show_modal() then
			for i = 1, #self._search_box.list_box:selected_indices() do
				local selected = self._search_box.list_box:get_string(self._search_box.list_box:selected_indices()[i])
				local key, value = self._metadata_dialog:get_value()
				local entry = self._active_database:lookup(self._entrys[selected]:type(), self._entrys[selected]:name(), self._entrys[selected]:properties())

				if value == "" then
					self._active_database:clear_metadata(entry, key)

					self._dirty_flag = false

					self._active_database:save()
				else
					self._active_database:set_metadata(entry, key, value)

					self._dirty_flag = false

					self._active_database:save()
				end
			end
		end
	else
		local ids = self._tree_box.tree_ctrl:selected_items()

		if #ids > 0 and self._metadata_dialog:show_modal() then
			for i = 1, #ids do
				local selected = self._tree_box.tree_ctrl:get_item_text(ids[i])
				local key, value = self._metadata_dialog:get_value()
				local entry = self._active_database:lookup(self._entrys[selected]:type(), self._entrys[selected]:name(), self._entrys[selected]:properties())

				if value == "" then
					self._active_database:clear_metadata(entry, key)

					self._dirty_flag = false

					self._active_database:save()
				else
					self._active_database:set_metadata(entry, key, value)

					self._dirty_flag = false

					self._active_database:save()
				end
			end
		end
	end

	self._active_database:load()
	self:on_read_database()
end

function CoreDatabaseBrowser:append_all_types(gui)
	if self._browser_data and self._browser_data.type_to_pick ~= "" then
		gui:append(self._browser_data.type_to_pick)
		gui:set_value(self._browser_data.type_to_pick)
	else
		local data_table = self._active_database:all(false)
		local name_table = {}

		for _, entry in ipairs(data_table) do
			if not name_table[entry:type()] then
				name_table[entry:type()] = entry

				gui:append(entry:type())
				gui:set_value(entry:type())
			end
		end

		name_table = nil
	end
end

function CoreDatabaseBrowser:set_position(newpos)
	if self._main_frame then
		self._main_frame:set_position(newpos)
	end
end

function CoreDatabaseBrowser:on_close(custom_data, event_object)
	if self._browser_data then
		self:close()

		self._browser_data.destroy = custom_data
	else
		managers.toolhub:close("Database Browser")
	end
end

function CoreDatabaseBrowser:destroy()
	if alive(self._main_frame) then
		self._main_frame:destroy()

		self._main_frame = nil
	end
end

function CoreDatabaseBrowser:close()
	if self._main_frame then
		self._main_frame:destroy()

		if not self._browser_data then
			open_editor = nil
		end
	end
end

function CoreDatabaseBrowser:update(t, dt)
	if self._search_flag then
		self:on_read_database()
		self:on_search()

		self._search_flag = nil
	end
end

function CoreDatabaseBrowser:on_reload()
	self:on_read_database()
end

function CoreDatabaseBrowser:on_notebook_changing()
	self._search_flag = true
end

function CoreDatabaseBrowser:on_select()
	if #self._search_box.list_box:selected_indices() == 1 then
		local selected = self._search_box.list_box:get_string(self._search_box.list_box:selected_indices()[1])

		self:update_preview(self._entrys[selected])

		if self._browser_data then
			self._browser_data.entry = self._entrys[selected]
		end
	end
end

function CoreDatabaseBrowser:on_tree_ctrl_change()
	if #self._tree_box.tree_ctrl:selected_items() > 0 then
		local ids = self._tree_box.tree_ctrl:selected_items()

		if #ids == 1 then
			local selected = self._tree_box.tree_ctrl:get_item_text(ids[1])

			self:update_preview(self._entrys[selected])

			if self._browser_data then
				self._browser_data.entry = self._entrys[selected]
			end
		end
	end
end

function CoreDatabaseBrowser:get_node(node, name)
	for n in node:children() do
		if n:name() == name then
			return n
		end
	end
end

function CoreDatabaseBrowser:find_node(node, name, key, value)
	for n in node:children() do
		if n:parameter(key) == value and (not name or n:name() == name) then
			return n
		end
	end
end

function CoreDatabaseBrowser:update_preview(entry)
	local function valid_node(node)
		return node and node:to_xml() ~= "</>\n"
	end

	local function preview_model_xml(self, node, valid_node)
		if valid_node(node) then
			local diesel_node = self:get_node(node, "diesel")

			if diesel_node and diesel_node:parameter("file") then
				local preview = self._active_database:lookup("preview_texture", diesel_node:parameter("file"))

				if preview:valid() then
					self._preview_image:set_label_bitmap(Application:base_path() .. self._active_database:root() .. "/" .. preview:path())
					self._preview_image:set_visible(true)

					return true
				end
			end
		end
	end

	self._main_frame:freeze()
	self._preview_panel:set_visible(false)
	self._preview_text_ctrl:text_ctrl():set_visible(false)
	self._preview_image:set_visible(false)

	if entry then
		local node = self._active_database:load_node(entry)

		if entry:type() == "unit" then
			local flag = nil

			if valid_node(node) then
				local model_node = self:get_node(node, "model")

				if model_node and model_node:parameter("file") then
					local model_xml_entry = self._active_database:lookup("object", model_node:parameter("file"))

					if model_xml_entry:valid() then
						local model_xml_node = self._active_database:load_node(model_xml_entry)
						flag = preview_model_xml(self, model_xml_node, valid_node)
					end
				end
			end

			if not flag then
				self._preview_panel:set_visible(true)
			end
		elseif entry:type() == "object" then
			if not preview_model_xml(self, node, valid_node) then
				self._preview_panel:set_visible(true)
			end
		elseif entry:type() == "model" then
			local preview = self._active_database:lookup("preview_texture", entry:name())

			if preview:valid() then
				self._preview_image:set_label_bitmap(Application:base_path() .. self._active_database:root() .. "/" .. preview:path())
				self._preview_image:set_visible(true)
			else
				self._preview_panel:set_visible(true)
			end
		elseif valid_node(node) then
			self._preview_text_ctrl:set_value(node:to_xml())
			self._preview_text_ctrl:text_ctrl():set_visible(true)
		else
			self._preview_panel:set_visible(true)
		end
	else
		self._preview_panel:set_visible(true)
	end

	self._main_frame:layout()
	self._main_frame:thaw()
	self._main_frame:refresh()
end

function CoreDatabaseBrowser:reset_preview()
	self._main_frame:freeze()
	self._preview_panel:set_visible(true)
	self._preview_text_ctrl:text_ctrl():set_visible(false)
	self._preview_image:set_visible(false)
	self._main_frame:layout()
	self._main_frame:thaw()
	self._main_frame:refresh()
end

function CoreDatabaseBrowser:hide_preview()
	self._main_frame:freeze()
	self._preview_panel:set_visible(false)
	self._preview_text_ctrl:text_ctrl():set_visible(false)
	self._preview_image:set_visible(false)
	self._main_frame:layout()
	self._main_frame:thaw()
	self._main_frame:refresh()
end

function CoreDatabaseBrowser:on_move()
	if self._main_notebook:get_current_page() ~= self._main_notebook:get_page(0) and self._move_dialog:show_modal() then
		local path = self._move_dialog:get_value()

		if self:check_path(path) then
			self:move_entry(path)
			self:on_search()
			self:get_tree_id(path, true)

			self._dirty_flag = false

			self._active_database:save()
		else
			self._invalid_path_dialog:show_modal()
		end
	end
end

function CoreDatabaseBrowser:check_path(path)
	if path ~= "" and (string.sub(path, 1, 1) ~= "/" or string.sub(path, string.len(path), string.len(path)) == "/") then
		return false
	end

	return true
end

function CoreDatabaseBrowser:move_entry(path)
	if #self._tree_box.tree_ctrl:selected_items() > 0 then
		local ids = self:filter_folders(self._tree_box.tree_ctrl:selected_items())

		for _, id in ipairs(ids) do
			local selected = self._tree_box.tree_ctrl:get_item_text(id)
			local entry = self._entrys[selected]

			if path == "" and entry:has_metadata("db_browser_folder") then
				self._active_database:clear_metadata(entry, "db_browser_folder")
			else
				self._active_database:set_metadata(entry, "db_browser_folder", path)
			end
		end
	end
end

function CoreDatabaseBrowser:filter_folders(ids)
	local out_table = {}

	for _, id in ipairs(ids) do
		if id ~= self._folder_table.id and not self:is_folder(self._folder_table, id) then
			table.insert(out_table, id)
		end
	end

	return out_table
end

function CoreDatabaseBrowser:is_folder(folder_table, id)
	for _, child in pairs(folder_table.children) do
		if child.id == id then
			return true
		elseif self:is_folder(child, id) then
			return true
		end
	end

	return false
end

function CoreDatabaseBrowser:build_tree(path)
	local parent = self._folder_table

	for folder_name in string.gmatch(path, "[%w_]+") do
		if not parent.children[folder_name] then
			local new_folder_table = {
				id = self._tree_box.tree_ctrl:append(parent.id, folder_name),
				children = {}
			}

			self._tree_box.tree_ctrl:set_item_bold(new_folder_table.id, true)

			parent.children[folder_name] = new_folder_table
			parent = new_folder_table
		else
			parent = parent.children[folder_name]
		end
	end
end

function CoreDatabaseBrowser:get_tree_id(path, expand)
	local parent = self._folder_table

	for folder_name in string.gmatch(path, "[%w_]+") do
		if expand then
			self._tree_box.tree_ctrl:expand(parent.id)
		end

		parent = parent.children[folder_name]
	end

	self._tree_box.tree_ctrl:expand(parent.id)

	return parent.id
end

function CoreDatabaseBrowser:on_search()
	if self._main_notebook:get_current_page() == self._main_notebook:get_page(0) then
		self._search_box.list_box:freeze()
		self._search_box.list_box:clear()
		self:reset_preview()

		local search_str = self._search_box.search_text_ctrl:get_value()
		local type_filter = self._search_box.type_combobox:get_value()

		if type_filter ~= "[all]" or #search_str > 2 then
			for key, value in pairs(self._entrys) do
				if string.find(key, search_str) then
					self._search_box.list_box:append(key)
				end
			end
		end

		self._search_box.list_box:thaw()
		self._search_box.list_box:refresh()
		self._search_box.search_text_ctrl:set_focus()
	elseif self._main_notebook:get_current_page() == self._main_notebook:get_page(1) then
		self._tree_box.tree_ctrl:freeze()
		self._tree_box.tree_ctrl:clear()
		self:reset_preview()

		self._folder_table = {
			id = self._tree_box.tree_ctrl:append_root("root"),
			children = {}
		}

		self._tree_box.tree_ctrl:set_item_bold(self._folder_table.id, true)

		local search_str = self._tree_box.search_text_ctrl:get_value()
		local type_filter = self._tree_box.type_combobox:get_value()

		if type_filter ~= "[all]" or #search_str > 2 then
			for key, value in pairs(self._entrys) do
				if string.find(key, search_str) then
					local folder = value:metadata("db_browser_folder")

					if folder ~= "" then
						self:build_tree(folder)

						local expand = search_str ~= ""
						local folder_id = self:get_tree_id(folder, expand)

						self._tree_box.tree_ctrl:append(folder_id, key)

						if expand then
							self._tree_box.tree_ctrl:expand(folder_id)
						end
					else
						self._tree_box.tree_ctrl:append(self._folder_table.id, key)
					end
				end
			end
		end

		self._tree_box.tree_ctrl:expand(self._folder_table.id)
		self._tree_box.tree_ctrl:thaw()
		self._tree_box.tree_ctrl:refresh()
		self._tree_box.search_text_ctrl:set_focus()
	elseif self._main_notebook:get_current_page() == self._main_notebook:get_page(2) then
		self:append_local_changes()
		self:hide_preview()
	end
end

function CoreDatabaseBrowser:on_remove()
	if not self._browser_data then
		if self._main_notebook:get_current_page() == self._main_notebook:get_page(0) then
			local ids = self._search_box.list_box:selected_indices()

			if #ids > 0 and self._remove_dialog:show_modal() == "ID_YES" then
				for _, id in ipairs(ids) do
					local selected = self._search_box.list_box:get_string(id)

					self._active_database:remove(self._entrys[selected]:type(), self._entrys[selected]:name(), self._entrys[selected]:properties())

					self._entrys[selected] = nil
					self._dirty_flag = false

					self._active_database:save()
				end

				self:on_search()
			end
		elseif self._main_notebook:get_current_page() == self._main_notebook:get_page(1) then
			if #self._tree_box.tree_ctrl:selected_items() > 0 and self._remove_dialog:show_modal() == "ID_YES" then
				local ids = self:filter_folders(self._tree_box.tree_ctrl:selected_items())

				for _, id in ipairs(ids) do
					local selected = self._tree_box.tree_ctrl:get_item_text(id)

					self._active_database:remove(self._entrys[selected]:type(), self._entrys[selected]:name(), self._entrys[selected]:properties())

					self._entrys[selected] = nil
					self._dirty_flag = false

					self._active_database:save()
				end

				self:on_search()
			end
		elseif self._main_notebook:get_current_page() == self._main_notebook:get_page(2) then
			self:on_revert_btn()
		end
	else
		self._not_available_dialog:show_modal()
	end
end

function CoreDatabaseBrowser:on_special_rename(new_entry, old_name)
	if new_entry:type() == "unit" then
		local node = self._active_database:load_node(new_entry)

		assert(node)
		node:set_parameter("name", new_entry:name())
		self._active_database:save_node(node, new_entry)
	elseif new_entry:type() == "model" then
		local preview = self._active_database:lookup("preview_texture", old_name)

		if preview:valid() then
			self._active_database:rename(preview, "preview_texture", new_entry:name(), preview:properties())
		end
	end
end

function CoreDatabaseBrowser:_rename_and_transfer_metadata(entry, new_name)
	local old_name = entry:name()
	local old_ref = self._active_database:lookup(entry:type(), old_name, entry:properties())
	local metadatas = old_ref and old_ref:metadatas() or {}

	for k, _ in pairs(metadatas) do
		self._active_database:clear_metadata(old_ref, k)
	end

	local new_ref = self._active_database:rename(old_ref, old_ref:type(), new_name, old_ref:properties())

	for k, v in pairs(metadatas) do
		self._active_database:set_metadata(new_ref, k, v)
	end

	return new_ref
end

function CoreDatabaseBrowser:on_rename()
	if not self._browser_data then
		if self._main_notebook:get_current_page() == self._main_notebook:get_page(0) then
			local ids = self._search_box.list_box:selected_indices()

			if #ids > 0 then
				self._rename_dialog:set_value(self._entrys[self._search_box.list_box:get_string(ids[1])]:name())

				if self._rename_dialog:show_modal() then
					for _, id in ipairs(ids) do
						local selected = self._search_box.list_box:get_string(id)

						if not self._active_database:has(self._entrys[selected]:type(), self._rename_dialog:get_value(), self._entrys[selected]:properties()) then
							local old_name = self._entrys[selected]:name()
							local new_ref = self:_rename_and_transfer_metadata(self._entrys[selected], self._rename_dialog:get_value())
							self._entrys[selected] = nil
							self._entrys[new_ref:type() .. " - " .. new_ref:name()] = new_ref
							self._dirty_flag = false

							self:on_special_rename(new_ref, old_name)
							self._active_database:save()
							self._active_database:load()
						else
							self._rename_error_dialog:show_modal()
						end
					end

					self:on_read_database()
				end
			end
		elseif self._main_notebook:get_current_page() == self._main_notebook:get_page(1) and #self._tree_box.tree_ctrl:selected_items() > 0 then
			local id = self:filter_folders(self._tree_box.tree_ctrl:selected_items())[1]
			local selected = self._tree_box.tree_ctrl:get_item_text(id)

			self._rename_dialog:set_value(self._entrys[self._tree_box.tree_ctrl:get_item_text(id)]:name())

			if self._rename_dialog:show_modal() then
				if not self._active_database:has(self._entrys[selected]:type(), self._rename_dialog:get_value(), self._entrys[selected]:properties()) then
					local selected = self._tree_box.tree_ctrl:get_item_text(id)
					local old_name = self._entrys[selected]:name()
					local new_ref = self:_rename_and_transfer_metadata(self._entrys[selected], self._rename_dialog:get_value())
					self._entrys[selected] = nil
					self._entrys[new_ref:type() .. " - " .. self._rename_dialog:get_value()] = new_ref
					self._dirty_flag = false

					self:on_special_rename(new_ref, old_name)
					self._active_database:save()
					self._active_database:load()
				else
					self._rename_error_dialog:show_modal()
				end

				self:on_read_database()
			end
		end
	else
		self._not_available_dialog:show_modal()
	end
end

function CoreDatabaseBrowser:unpack_prop(in_table, target)
	local str = " "

	for key, value in pairs(in_table) do
		str = str .. "-" .. target .. " " .. key .. "=" .. value .. " "
	end

	return str
end

function CoreDatabaseBrowser:convert_to_x360(entry)
	if self._op_menu:is_checked("OP_AUTO_CONVERT_TEXTURES") then
		local prop = entry:properties()
		prop.platform = "x360raw"
		local raw_texture = self._active_database:lookup("texture", entry:name(), prop)

		if not raw_texture:valid() or raw_texture:property("platform") ~= "x360raw" then
			prop.platform = "raw"
			raw_texture = self._active_database:lookup("texture", entry:name(), prop)

			if not raw_texture:valid() or raw_texture:property("platform") ~= "raw" then
				cat_print("debug", "[CoreDatabaseBrowser] Could not find any raw texture for " .. entry:name() .. " during x360 conversion.")

				return
			end
		end

		prop.platform = "x360"
		local str = "imageexportertool -d \"" .. Application:base_path() .. "db\" -sn " .. raw_texture:name() .. self:unpack_prop(raw_texture:properties(), "sp") .. "-qpf A8L8"

		if Application:system(str, true, true) == 0 then
			str = "imageexportertool -d \"" .. Application:base_path() .. "db\" -sn " .. raw_texture:name() .. self:unpack_prop(raw_texture:properties(), "sp") .. "-dn " .. raw_texture:name() .. self:unpack_prop(prop, "dp") .. "-p 3DC -f dds"

			cat_print("debug", "[CoreDatabaseBrowser] " .. str)
			Application:system(str, true, true)
			self._active_database:load()

			return self._active_database:lookup("texture", raw_texture:name(), prop)
		end

		self._active_database:load()
	end
end

function CoreDatabaseBrowser:convert_to_ps3(entry)
	if self._op_menu:is_checked("OP_AUTO_CONVERT_TEXTURES") then
		local prop = entry:properties()
		prop.platform = "ps3raw"
		local raw_texture = self._active_database:lookup("texture", entry:name(), prop)

		if not raw_texture:valid() or raw_texture:property("platform") ~= "ps3raw" then
			prop.platform = "raw"
			raw_texture = self._active_database:lookup("texture", entry:name(), prop)

			if not raw_texture:valid() or raw_texture:property("platform") ~= "raw" then
				cat_print("debug", "[CoreDatabaseBrowser] Could not find any raw texture for " .. entry:name() .. " during ps3 conversion.")

				return
			end
		end

		prop.platform = "ps3"
		local str = "imageexportertool -d \"" .. Application:base_path() .. "db\" -sn " .. raw_texture:name() .. self:unpack_prop(raw_texture:properties(), "sp") .. "-qpf A8L8"

		if Application:system(str, true, true) == 0 then
			str = "imageexportertool -d \"" .. Application:base_path() .. "db\" -sn " .. raw_texture:name() .. self:unpack_prop(raw_texture:properties(), "sp") .. "-dn " .. raw_texture:name() .. self:unpack_prop(prop, "dp") .. "-f gtf -p DXT5_NM"
		else
			str = "imageexportertool -d \"" .. Application:base_path() .. "db\" -sn " .. raw_texture:name() .. self:unpack_prop(raw_texture:properties(), "sp") .. "-dn " .. raw_texture:name() .. self:unpack_prop(prop, "dp") .. "-f gtf"
		end

		cat_print("debug", "[CoreDatabaseBrowser] " .. str)
		Application:system(str, true, true)
		self._active_database:load()

		return self._active_database:lookup("texture", raw_texture:name(), prop)
	end
end

CoreDatabaseBrowserMoveDialog = CoreDatabaseBrowserMoveDialog or class()

function CoreDatabaseBrowserMoveDialog:init(editor, p)
	self._dialog = EWS:Dialog(p, "Move", "", Vector3(-1, -1, 0), Vector3(300, 75, 0), "CAPTION,SYSTEM_MENU,STAY_ON_TOP")
	local box = EWS:BoxSizer("VERTICAL")
	self._text_ctrl = EWS:TextCtrl(self._dialog, "", "", "TE_PROCESS_ENTER")

	self._text_ctrl:connect("", "EVT_COMMAND_TEXT_ENTER", callback(self, self, "on_move_button"), "")
	box:add(self._text_ctrl, 0, 0, "EXPAND")

	local button_box = EWS:BoxSizer("HORIZONTAL")
	self._move = EWS:Button(self._dialog, "Move", "", "")

	self._move:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_move_button"), "")
	button_box:add(self._move, 1, 0, "EXPAND")

	self._cancel = EWS:Button(self._dialog, "Cancel", "", "")

	self._cancel:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_cancel_button"), "")
	button_box:add(self._cancel, 1, 0, "EXPAND")
	box:add(button_box, 0, 0, "EXPAND")
	self._dialog:set_sizer(box)
	self._text_ctrl:set_focus()
end

function CoreDatabaseBrowserMoveDialog:show_modal()
	self._text_ctrl:set_value("")

	self._resault = nil
	self._done = false
	self._return_val = true

	self._dialog:show_modal()

	while not self._done do
	end

	return self._return_val
end

function CoreDatabaseBrowserMoveDialog:on_move_button()
	self._done = true
	self._resault = self._text_ctrl:get_value()

	self._dialog:end_modal("")
end

function CoreDatabaseBrowserMoveDialog:on_cancel_button()
	self._done = true
	self._return_val = false

	self._dialog:end_modal("")
end

function CoreDatabaseBrowserMoveDialog:get_value()
	return self._resault
end

CoreDatabaseBrowserImportDialog = CoreDatabaseBrowserImportDialog or class()

function CoreDatabaseBrowserImportDialog:init(editor, p)
	self._dialog = EWS:Dialog(p, "New Entry", "", Vector3(-1, -1, 0), Vector3(300, 86, 0), "CAPTION,SYSTEM_MENU,STAY_ON_TOP")
	local box = EWS:BoxSizer("VERTICAL")
	local text_box = EWS:BoxSizer("HORIZONTAL")
	self._type_combobox = EWS:ComboBox(self._dialog, "", "", "")

	self._type_combobox:connect("", "EVT_COMMAND_TEXT_ENTER", callback(self, self, "on_import_button"), "")
	editor:append_all_types(self._type_combobox)
	text_box:add(self._type_combobox, 1, 0, "EXPAND")

	self._name_text_ctrl = EWS:TextCtrl(self._dialog, "", "", "TE_PROCESS_ENTER")

	self._name_text_ctrl:connect("", "EVT_COMMAND_TEXT_ENTER", callback(self, self, "on_import_button"), "")
	text_box:add(self._name_text_ctrl, 1, 0, "EXPAND")
	box:add(text_box, 0, 4, "ALL,EXPAND")

	local button_box = EWS:BoxSizer("HORIZONTAL")
	self._move = EWS:Button(self._dialog, "Import", "", "")

	self._move:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_import_button"), "")
	button_box:add(self._move, 1, 4, "ALL,EXPAND")

	self._cancel = EWS:Button(self._dialog, "Cancel", "", "")

	self._cancel:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_cancel_button"), "")
	button_box:add(self._cancel, 1, 4, "ALL,EXPAND")
	box:add(button_box, 0, 0, "EXPAND")
	self._dialog:set_sizer(box)
end

function CoreDatabaseBrowserImportDialog:show_modal()
	self._type_combobox:set_value("")
	self._name_text_ctrl:set_value("")

	self._type = nil
	self._name = nil
	self._done = false
	self._return_val = true

	self._dialog:show_modal()

	while not self._done do
	end

	return self._return_val
end

function CoreDatabaseBrowserImportDialog:on_import_button()
	self._done = true
	self._type = self._type_combobox:get_value()
	self._name = self._name_text_ctrl:get_value()

	self._dialog:end_modal("")
end

function CoreDatabaseBrowserImportDialog:on_cancel_button()
	self._done = true
	self._return_val = false

	self._dialog:end_modal("")
end

function CoreDatabaseBrowserImportDialog:get_value()
	return self._type, self._name
end

CoreDatabaseBrowserMetadataDialog = CoreDatabaseBrowserMetadataDialog or class()

function CoreDatabaseBrowserMetadataDialog:init(p)
	self._dialog = EWS:Dialog(p, "Set Metadata", "", Vector3(-1, -1, 0), Vector3(300, 86, 0), "CAPTION,SYSTEM_MENU,STAY_ON_TOP")
	local box = EWS:BoxSizer("VERTICAL")
	local text_box = EWS:BoxSizer("HORIZONTAL")
	self._key_text_ctrl = EWS:TextCtrl(self._dialog, "", "", "TE_PROCESS_ENTER")

	self._key_text_ctrl:connect("", "EVT_COMMAND_TEXT_ENTER", callback(self, self, "on_set_button"), "")
	text_box:add(self._key_text_ctrl, 1, 0, "EXPAND")

	self._value_text_ctrl = EWS:TextCtrl(self._dialog, "", "", "TE_PROCESS_ENTER")

	self._value_text_ctrl:connect("", "EVT_COMMAND_TEXT_ENTER", callback(self, self, "on_set_button"), "")
	text_box:add(self._value_text_ctrl, 1, 0, "EXPAND")
	box:add(text_box, 0, 4, "ALL,EXPAND")

	local button_box = EWS:BoxSizer("HORIZONTAL")
	self._move = EWS:Button(self._dialog, "Set", "", "")

	self._move:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_set_button"), "")
	button_box:add(self._move, 1, 4, "ALL,EXPAND")

	self._cancel = EWS:Button(self._dialog, "Cancel", "", "")

	self._cancel:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_cancel_button"), "")
	button_box:add(self._cancel, 1, 4, "ALL,EXPAND")
	box:add(button_box, 0, 0, "EXPAND")
	self._dialog:set_sizer(box)
	self._key_text_ctrl:set_focus()
end

function CoreDatabaseBrowserMetadataDialog:show_modal()
	self._key_text_ctrl:set_value("")
	self._value_text_ctrl:set_value("")

	self._key = nil
	self._value = nil
	self._done = false
	self._return_val = true

	self._dialog:show_modal()

	while not self._done do
	end

	return self._return_val
end

function CoreDatabaseBrowserMetadataDialog:on_set_button()
	self._done = true
	self._key = self._key_text_ctrl:get_value()
	self._value = self._value_text_ctrl:get_value()

	self._dialog:end_modal("")
end

function CoreDatabaseBrowserMetadataDialog:on_cancel_button()
	self._done = true
	self._return_val = false

	self._dialog:end_modal("")
end

function CoreDatabaseBrowserMetadataDialog:get_value()
	return self._key, self._value
end

CoreDatabaseBrowserInputDialog = CoreDatabaseBrowserInputDialog or class()

function CoreDatabaseBrowserInputDialog:init(p)
	self._dialog = EWS:Dialog(p, "Comment", "", Vector3(-1, -1, 0), Vector3(300, 86, 0), "CAPTION,SYSTEM_MENU,STAY_ON_TOP")
	local box = EWS:BoxSizer("VERTICAL")
	local text_box = EWS:BoxSizer("HORIZONTAL")
	self._key_text_ctrl = EWS:TextCtrl(self._dialog, "", "", "TE_PROCESS_ENTER")

	self._key_text_ctrl:connect("", "EVT_COMMAND_TEXT_ENTER", callback(self, self, "on_ok_button"), "")
	text_box:add(self._key_text_ctrl, 1, 0, "EXPAND")
	box:add(text_box, 0, 4, "ALL,EXPAND")

	local button_box = EWS:BoxSizer("HORIZONTAL")
	self._ok = EWS:Button(self._dialog, "OK", "", "")

	self._ok:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_ok_button"), "")
	button_box:add(self._ok, 1, 4, "ALL,EXPAND")

	self._cancel = EWS:Button(self._dialog, "Cancel", "", "")

	self._cancel:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_cancel_button"), "")
	button_box:add(self._cancel, 1, 4, "ALL,EXPAND")
	box:add(button_box, 0, 0, "EXPAND")
	self._dialog:set_sizer(box)
	self._key_text_ctrl:set_focus()
end

function CoreDatabaseBrowserInputDialog:show_modal()
	self._key_text_ctrl:set_value("")

	self._key = nil
	self._done = false
	self._return_val = true

	self._dialog:show_modal()

	while not self._done do
	end

	return self._return_val
end

function CoreDatabaseBrowserInputDialog:on_ok_button()
	self._done = true
	self._key = self._key_text_ctrl:get_value()

	self._dialog:end_modal("")
end

function CoreDatabaseBrowserInputDialog:on_cancel_button()
	self._done = true
	self._return_val = false

	self._dialog:end_modal("")
end

function CoreDatabaseBrowserInputDialog:get_value()
	return self._key
end

CoreDatabaseBrowserRenameDialog = CoreDatabaseBrowserRenameDialog or class()

function CoreDatabaseBrowserRenameDialog:init(p)
	self._dialog = EWS:Dialog(p, "Rename", "", Vector3(-1, -1, 0), Vector3(300, 86, 0), "CAPTION,SYSTEM_MENU,STAY_ON_TOP")
	local box = EWS:BoxSizer("VERTICAL")
	local text_box = EWS:BoxSizer("HORIZONTAL")
	self._key_text_ctrl = EWS:TextCtrl(self._dialog, "", "", "TE_PROCESS_ENTER")

	self._key_text_ctrl:connect("", "EVT_COMMAND_TEXT_ENTER", callback(self, self, "on_ok_button"), "")
	text_box:add(self._key_text_ctrl, 1, 0, "EXPAND")
	box:add(text_box, 0, 4, "ALL,EXPAND")

	local button_box = EWS:BoxSizer("HORIZONTAL")
	self._ok = EWS:Button(self._dialog, "Rename", "", "")

	self._ok:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_ok_button"), "")
	button_box:add(self._ok, 1, 4, "ALL,EXPAND")

	self._cancel = EWS:Button(self._dialog, "Cancel", "", "")

	self._cancel:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_cancel_button"), "")
	button_box:add(self._cancel, 1, 4, "ALL,EXPAND")
	box:add(button_box, 0, 0, "EXPAND")
	self._dialog:set_sizer(box)
	self._key_text_ctrl:set_focus()
end

function CoreDatabaseBrowserRenameDialog:show_modal()
	self._key = nil
	self._done = false
	self._return_val = true

	self._dialog:show_modal()

	while not self._done do
	end

	return self._return_val
end

function CoreDatabaseBrowserRenameDialog:on_ok_button()
	self._done = true
	self._key = self._key_text_ctrl:get_value()

	self._dialog:end_modal("")
end

function CoreDatabaseBrowserRenameDialog:on_cancel_button()
	self._done = true
	self._return_val = false

	self._dialog:end_modal("")
end

function CoreDatabaseBrowserRenameDialog:get_value()
	return self._key
end

function CoreDatabaseBrowserRenameDialog:set_value(str)
	self._key_text_ctrl:set_value(str)
end
