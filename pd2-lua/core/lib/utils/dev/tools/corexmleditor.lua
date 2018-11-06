CoreXMLEditor = CoreXMLEditor or class()

function CoreXMLEditor:init()
	self._active_database = ProjectDatabase
	self._current_prop = {}

	self:create_main_frame()
	self:check_news(true)
end

function CoreXMLEditor:on_check_news()
	self:check_news()
end

function CoreXMLEditor:check_news(new_only)
	local news = nil

	if new_only then
		news = managers.news:get_news("xml_editor", self._main_frame_table._main_frame)
	else
		news = managers.news:get_old_news("xml_editor", self._main_frame_table._main_frame)
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

		EWS:MessageDialog(self._main_frame_table._main_frame, str, "New Features!", "OK,ICON_INFORMATION"):show_modal()
	end
end

function CoreXMLEditor:check_open()
	if open_editor then
		local frame = EWS:Frame("", Vector3(0, 0, 0), Vector3(0, 0, 0), "")

		EWS:MessageDialog(frame, "Please close the " .. open_editor .. " before open this editor.", "Conflict", "OK,ICON_INFORMATION"):show_modal()
		frame:destroy()
		managers.toolhub:close("XML Editor")

		return true
	else
		open_editor = "XML Editor"
	end

	return false
end

function CoreXMLEditor:create_main_frame()
	self._main_frame_table = {
		_main_frame = EWS:Frame("XML Editor", Vector3(-1, -1, 0), Vector3(1000, 800, 0), "FRAME_FLOAT_ON_PARENT,DEFAULT_FRAME_STYLE", Global.frame)
	}

	self._main_frame_table._main_frame:set_icon(CoreEWS.image_path("xml_editor_16x16.png"))

	local menu_bar = EWS:MenuBar()
	local file_menu = EWS:Menu("")

	file_menu:append_item("NEW", "New\tCtrl+N", "")
	file_menu:append_item("OPEN", "Open\tCtrl+O", "")
	file_menu:append_item("SAVE", "Save\tCtrl+S", "")
	file_menu:append_item("SAVE_AS", "Save As", "")
	file_menu:append_separator()
	file_menu:append_item("NEWS", "Get Latest News", "")
	file_menu:append_separator()
	file_menu:append_item("EXIT", "Exit", "")
	menu_bar:append(file_menu, "File")

	self._db_menu = EWS:Menu("")

	self._db_menu:append_radio_item("DB_PROJECT", "Project", "")
	self._db_menu:append_radio_item("DB_CORE", "Core", "")
	self._db_menu:set_checked("DB_PROJECT", true)
	menu_bar:append(self._db_menu, "Database")
	self._main_frame_table._main_frame:set_menu_bar(menu_bar)
	self._main_frame_table._main_frame:connect("NEW", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_new"), "")
	self._main_frame_table._main_frame:connect("OPEN", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_open"), "")
	self._main_frame_table._main_frame:connect("SAVE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_save"), "")
	self._main_frame_table._main_frame:connect("SAVE_AS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_save_as"), "")
	self._main_frame_table._main_frame:connect("NEWS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_check_news"), "")
	self._main_frame_table._main_frame:connect("EXIT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_close"), "")
	self._main_frame_table._main_frame:connect("DB_PROJECT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_set_db"), ProjectDatabase)
	self._main_frame_table._main_frame:connect("DB_CORE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_set_db"), CoreDatabase)
	self._main_frame_table._main_frame:connect("", "EVT_CLOSE_WINDOW", callback(self, self, "on_close"), "")

	local main_box = EWS:BoxSizer("VERTICAL")
	self._main_frame_table._main_panel = EWS:Panel(self._main_frame_table._main_frame, "", "")
	local panel_box = EWS:BoxSizer("VERTICAL")
	self._main_frame_table._edit_text_ctrl = EWS:TextCtrl(self._main_frame_table._main_panel, "", "", "TE_MULTILINE")

	panel_box:add(self._main_frame_table._edit_text_ctrl, 1, 0, "EXPAND")
	self._main_frame_table._main_panel:set_sizer(panel_box)
	main_box:add(self._main_frame_table._main_panel, 1, 0, "EXPAND")
	self._main_frame_table._main_frame:set_sizer(main_box)
	self._main_frame_table._main_frame:set_visible(true)

	self._save_prev_dialog = EWS:MessageDialog(self._main_frame_table._main_frame, "Do you want to save your current work?", "Save", "YES_NO,ICON_QUESTION")
	self._compile_error_dialog = EWS:MessageDialog(self._main_frame_table._main_frame, "Could not compile XML!", "Error", "OK,ICON_ERROR")
	self._new_dialog = CoreXMLEditorNewDialog:new(self._main_frame_table._main_frame)
end

function CoreXMLEditor:on_set_db(data, event)
	self._db_menu:set_checked("DB_PROJECT", false)
	self._db_menu:set_checked("DB_CORE", false)
	self._db_menu:set_checked(event:get_id(), true)

	self._active_database = data

	self._main_frame_table._edit_text_ctrl:set_value("")

	self._current_node = nil
	self._current_entry = nil
	self._current_prop = {}
end

function CoreXMLEditor:on_new()
	if self._main_frame_table._edit_text_ctrl:get_value() ~= "" and self._save_prev_dialog:show_modal() == "ID_YES" then
		self:on_save()
	end

	self._main_frame_table._edit_text_ctrl:set_value("")

	self._current_node = nil
	self._current_entry = nil
	self._current_prop = {}

	self:update_title()
end

function CoreXMLEditor:on_open()
	self._browse = CoreDBDialog:new("", self, self.openfile, self._active_database)
end

function CoreXMLEditor:on_save()
	if not self._current_node or not self._current_entry then
		self:on_save_as()
	elseif self._current_node:try_read_xml(self._main_frame_table._edit_text_ctrl:get_value()) then
		local entry_type = self._current_entry:type()
		local entry_name = self._current_entry:name()
		self._current_node = Node("new_node")

		self._current_node:read_xml(self._main_frame_table._edit_text_ctrl:get_value())
		self._active_database:save_node(self._current_node, self._current_entry)
		self._active_database:save()

		self._current_entry = self._active_database:lookup(entry_type, entry_name, self._current_prop)
		self._current_node = self._active_database:load_node(self._current_entry)
	else
		self._compile_error_dialog:show_modal()
	end
end

function CoreXMLEditor:on_save_as()
	local test_node = Node("new_node")

	if test_node:try_read_xml(self._main_frame_table._edit_text_ctrl:get_value()) then
		if self._new_dialog:show_modal() then
			local entry_type, entry_name = self._new_dialog:get_value()
			local added_entry = self._active_database:lookup(entry_type, entry_name, self._current_prop)

			if not added_entry:valid() then
				added_entry = self._active_database:add(entry_type, entry_name, self._current_prop, "xml")
			end

			self._current_node = test_node
			self._current_entry = added_entry

			self._active_database:save_node(self._current_node, self._current_entry)
			self._active_database:save()

			self._current_entry = self._active_database:lookup(entry_type, entry_name, self._current_prop)
			self._current_node = self._active_database:load_node(self._current_entry)

			self:update_title()
		end
	else
		self._compile_error_dialog:show_modal()
	end
end

function CoreXMLEditor:openfile()
	local node = self._active_database:load_node(self._browse:get_value())

	if node then
		local xml_str = node:to_xml()

		if xml_str then
			if self._main_frame_table._edit_text_ctrl:get_value() ~= "" and self._save_prev_dialog:show_modal() == "ID_YES" then
				self:on_save()
			end

			self._current_node = node
			self._current_entry = self._browse:get_value()
			self._current_prop = self._current_entry:properties()

			self._main_frame_table._edit_text_ctrl:set_value(xml_str)
			self:update_title()

			self._browse = nil
		end
	end
end

function CoreXMLEditor:update_title()
	if self._current_entry and self._current_entry:valid() then
		self._main_frame_table._main_frame:set_title(self._current_entry:name() .. " - XML Editor")
	else
		self._main_frame_table._main_frame:set_title("XML Editor")
	end
end

function CoreXMLEditor:update(t, dt)
	if self._browse and self._browse:update(t, dt) then
		self._main_frame_table._main_frame:set_focus()

		self._browse = nil
	end
end

function CoreXMLEditor:set_position(newpos)
	if self._main_frame_table and self._main_frame_table._main_frame then
		self._main_frame_table._main_frame:set_position(newpos)
	end
end

function CoreXMLEditor:on_close()
	self:close()
	managers.toolhub:close("XML Editor")
end

function CoreXMLEditor:destroy()
	if self._main_frame_table and alive(self._main_frame_table._main_frame) then
		self._main_frame_table._main_frame:destroy()

		self._main_frame_table._main_frame = nil
	end

	if self._browse then
		self._browse:destroy()

		self._browse = nil
	end
end

function CoreXMLEditor:close()
	if self._main_frame_table and self._main_frame_table._main_frame then
		self._main_frame_table._main_frame:destroy()

		open_editor = nil
	end

	if self._browse then
		self._browse:destroy()

		self._browse = nil
	end
end

CoreXMLEditorNewDialog = CoreXMLEditorNewDialog or class()

function CoreXMLEditorNewDialog:init(p)
	self._dialog = EWS:Dialog(p, "Create New Entry", "", Vector3(-1, -1, 0), Vector3(200, 86, 0), "CAPTION,SYSTEM_MENU")
	local box = EWS:BoxSizer("VERTICAL")
	local text_box = EWS:BoxSizer("HORIZONTAL")
	self._type_text_ctrl = EWS:TextCtrl(self._dialog, "", "", "TE_PROCESS_ENTER")

	self._type_text_ctrl:connect("", "EVT_COMMAND_TEXT_ENTER", callback(self, self, "on_set_button"), "")
	text_box:add(self._type_text_ctrl, 1, 0, "EXPAND")

	self._name_text_ctrl = EWS:TextCtrl(self._dialog, "", "", "TE_PROCESS_ENTER")

	self._name_text_ctrl:connect("", "EVT_COMMAND_TEXT_ENTER", callback(self, self, "on_set_button"), "")
	text_box:add(self._name_text_ctrl, 1, 0, "EXPAND")
	box:add(text_box, 0, 4, "ALL,EXPAND")

	local button_box = EWS:BoxSizer("HORIZONTAL")
	self._set = EWS:Button(self._dialog, "Create", "", "")

	self._set:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_set_button"), "")
	button_box:add(self._set, 1, 4, "ALL,EXPAND")

	self._cancel = EWS:Button(self._dialog, "Cancel", "", "")

	self._cancel:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_cancel_button"), "")
	button_box:add(self._cancel, 1, 4, "ALL,EXPAND")
	box:add(button_box, 0, 0, "EXPAND")
	self._dialog:set_sizer(box)
end

function CoreXMLEditorNewDialog:show_modal()
	self._type_text_ctrl:set_value("[type]")
	self._name_text_ctrl:set_value("[name]")

	self._key = nil
	self._done = false
	self._return_val = true

	self._dialog:show_modal()

	while not self._done do
	end

	return self._return_val
end

function CoreXMLEditorNewDialog:on_set_button()
	self._done = true
	self._type = self._type_text_ctrl:get_value()
	self._name = self._name_text_ctrl:get_value()

	self._dialog:end_modal("")
end

function CoreXMLEditorNewDialog:on_cancel_button()
	self._done = true
	self._return_val = false

	self._dialog:end_modal("")
end

function CoreXMLEditorNewDialog:get_value()
	return self._type, self._name
end
