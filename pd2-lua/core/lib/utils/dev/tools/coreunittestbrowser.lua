CoreUnitTestBrowser = CoreUnitTestBrowser or class()

function CoreUnitTestBrowser:init()
	self._unit_msg = {}
	self._ignore_list = {}
	self._report_xml = File:parse_xml("/unit_test_results.xml")

	if self._report_xml then
		self:error_frame()
		self:init_tree_view()
	end
end

function CoreUnitTestBrowser:error_frame()
	self._error_frame = EWS:Frame("Unit Test Browser", Vector3(100, 400, 0), Vector3(500, 500, 0), "FRAME_FLOAT_ON_PARENT,DEFAULT_FRAME_STYLE", Global.frame)
	local menu_bar = EWS:MenuBar()
	local file_menu = EWS:Menu("")

	file_menu:append_item("EMAILS", "Send E-Mails", "")
	file_menu:append_item("EMAILS_TO", "Send E-Mails To", "")
	file_menu:append_separator()
	file_menu:append_item("EXIT", "Exit", "")
	menu_bar:append(file_menu, "File")

	local ignore_menu = EWS:Menu("")

	ignore_menu:append_item("IGNORE_ALL", "All", "")
	ignore_menu:append_item("IGNORE_NONE", "None", "")
	menu_bar:append(ignore_menu, "Ignore")

	local search_menu = EWS:Menu("")

	search_menu:append_item("FINDUNIT", "Find Unit", "")
	menu_bar:append(search_menu, "Search")
	self._error_frame:set_menu_bar(menu_bar)
	self._error_frame:connect("EMAILS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_send_emails"), "")
	self._error_frame:connect("EMAILS_TO", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_send_emails_to"), "")
	self._error_frame:connect("EXIT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_close"), "")
	self._error_frame:connect("IGNORE_ALL", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_ignore_all"), "")
	self._error_frame:connect("IGNORE_NONE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_ignore_none"), "")
	self._error_frame:connect("FINDUNIT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_find_unit"), "")
	self._error_frame:connect("", "EVT_CLOSE_WINDOW", callback(self, self, "on_close"), "")

	local error_box = EWS:BoxSizer("VERTICAL")
	self._error_box = {
		tree_ctrl = EWS:TreeCtrl(self._error_frame, "", "")
	}

	self._error_box.tree_ctrl:connect("", "EVT_COMMAND_TREE_SEL_CHANGED", callback(self, self, "on_tree_ctrl_change"), "")
	self._error_box.tree_ctrl:connect("", "EVT_RIGHT_UP", callback(self, self, "on_popup"), "")
	error_box:add(self._error_box.tree_ctrl, 2, 0, "EXPAND")

	self._error_box.text_ctrl = EWS:TextCtrl(self._error_frame, "", "", "TE_MULTILINE")

	error_box:add(self._error_box.text_ctrl, 1, 0, "EXPAND")

	self._warning_mail_dialog = EWS:MessageDialog(self._error_frame, "This will send a e-mail to all non-ignored authors. Do not proceed unless you are authorized. Proceed?", "WARNING", "")
	self._warning_mail_admin_dialog = EWS:MessageDialog(self._error_frame, "This will send a e-mail to viktor@grin.se, andreas.jonsson@grin.se and perj@grin.se. Do not proceed unless you are authorized. Proceed?", "WARNING", "")
	self._receiver_dialog = CoreUnitTestBrowserInputDialog:new(self)

	self._error_frame:set_sizer(error_box)
	self._error_frame:set_visible(true)
end

function CoreUnitTestBrowser:search_frame()
	self._search_frame = EWS:Frame("Search Unit", Vector3(100, 400, 0), Vector3(250, 350, 0), "")

	self._search_frame:connect("", "EVT_CLOSE_WINDOW", callback(self, self, "on_close_search"), "")

	local search_box = EWS:BoxSizer("VERTICAL")
	local top_search_box = EWS:BoxSizer("HORIZONTAL")
	self._search_box = {
		type_combobox = EWS:ComboBox(self._search_frame, "", "", "CB_READONLY")
	}

	self._search_box.type_combobox:connect("", "EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "on_search"), "")
	self._search_box.type_combobox:append("Search By Author")
	self._search_box.type_combobox:append("Search By Name")
	self._search_box.type_combobox:append("Search By Diesel Path")
	self._search_box.type_combobox:set_value("Search By Author")
	search_box:add(self._search_box.type_combobox, 0, 0, "EXPAND")

	self._search_box.search_text_ctrl = EWS:TextCtrl(self._search_frame, "", "", "")

	self._search_box.search_text_ctrl:connect("", "EVT_COMMAND_TEXT_UPDATED", callback(self, self, "on_search"), "")
	top_search_box:add(self._search_box.search_text_ctrl, 1, 0, "EXPAND")
	search_box:add(top_search_box, 0, 0, "EXPAND")

	self._search_box.list_box = EWS:ListBox(self._search_frame, "", "")

	self._search_box.list_box:connect("", "EVT_COMMAND_LISTBOX_SELECTED", callback(self, self, "on_listbox_selected"), "")
	self._search_box.list_box:connect("", "EVT_RIGHT_UP", callback(self, self, "on_popup"), "")
	search_box:add(self._search_box.list_box, 1, 0, "EXPAND")
	self._search_frame:set_sizer(search_box)
	self._search_frame:set_visible(true)
end

function CoreUnitTestBrowser:set_position(newpos)
	self._error_frame:set_position(newpos)
end

function CoreUnitTestBrowser:update(t, dt)
end

function CoreUnitTestBrowser:on_popup()
	local selected_item = self._error_box.tree_ctrl:selected_item()

	if selected_item > -1 then
		local found = false

		for _, id in ipairs(self._error_box.tree_ctrl:get_children(self._failed_id)) do
			if id == selected_item then
				for _, ignore_id in ipairs(self._ignore_list) do
					if ignore_id == selected_item then
						self:include_popup()

						found = true

						break
					end
				end

				if not found then
					self:ignore_popup()
				end

				break
			end
		end

		if not found then
			for _, id in ipairs(self._error_box.tree_ctrl:get_children(self._critical_id)) do
				if id == selected_item then
					for _, ignore_id in ipairs(self._ignore_list) do
						if ignore_id == selected_item then
							self:include_popup(true)

							found = true

							break
						end
					end

					if not found then
						self:ignore_popup(true)
					end

					break
				end
			end
		end
	end
end

function CoreUnitTestBrowser:ignore_popup(critical)
	local popup = EWS:Menu("")

	popup:append_item("IGNORE", "Ignore", "")
	popup:connect("IGNORE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_ignore"), critical)
	self._error_frame:popup_menu(popup, Vector3(-1, -1, 0))
end

function CoreUnitTestBrowser:include_popup(critical)
	local popup = EWS:Menu("")

	popup:append_item("INCLUDE", "Include", "")
	popup:connect("INCLUDE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_include"), critical)
	self._error_frame:popup_menu(popup, Vector3(-1, -1, 0))
end

function CoreUnitTestBrowser:on_ignore(custom_data, event)
	local id = self._error_box.tree_ctrl:selected_item()

	if custom_data then
		self._error_box.tree_ctrl:set_item_text_colour(id, Vector3(1, 1, 1))
		self._error_box.tree_ctrl:set_item_background_colour(id, Vector3(1, 0, 0))
	else
		self._error_box.tree_ctrl:set_item_text_colour(id, Vector3(1, 1, 1))
		self._error_box.tree_ctrl:set_item_background_colour(id, Vector3(0.5, 0, 0))
	end

	table.insert(self._ignore_list, id)
end

function CoreUnitTestBrowser:on_include(custom_data, event)
	local id = self._error_box.tree_ctrl:selected_item()

	if custom_data then
		self._error_box.tree_ctrl:set_item_text_colour(id, Vector3(1, 0, 0))
		self._error_box.tree_ctrl:set_item_background_colour(id, Vector3(1, 1, 1))
	else
		self._error_box.tree_ctrl:set_item_text_colour(id, Vector3(0.5, 0, 0))
		self._error_box.tree_ctrl:set_item_background_colour(id, Vector3(1, 1, 1))
	end

	table.delete(self._ignore_list, id)
end

function CoreUnitTestBrowser:on_ignore_all()
	for _, id in ipairs(self._error_box.tree_ctrl:get_children(self._failed_id)) do
		local found = false

		for _, ignore_id in ipairs(self._ignore_list) do
			if ignore_id == id then
				found = true

				break
			end
		end

		if not found then
			self._error_box.tree_ctrl:set_item_text_colour(id, Vector3(1, 1, 1))
			self._error_box.tree_ctrl:set_item_background_colour(id, Vector3(0.5, 0, 0))
			table.insert(self._ignore_list, id)
		end
	end

	for _, id in ipairs(self._error_box.tree_ctrl:get_children(self._critical_id)) do
		local found = false

		for _, ignore_id in ipairs(self._ignore_list) do
			if ignore_id == id then
				found = true

				break
			end
		end

		if not found then
			self._error_box.tree_ctrl:set_item_text_colour(id, Vector3(1, 1, 1))
			self._error_box.tree_ctrl:set_item_background_colour(id, Vector3(1, 0, 0))
			table.insert(self._ignore_list, id)
		end
	end
end

function CoreUnitTestBrowser:on_ignore_none()
	while #self._ignore_list > 0 do
		for _, ignore_id in ipairs(self._ignore_list) do
			local found = false

			for _, id in ipairs(self._error_box.tree_ctrl:get_children(self._failed_id)) do
				if ignore_id == id then
					self._error_box.tree_ctrl:set_item_text_colour(id, Vector3(0.5, 0, 0))
					self._error_box.tree_ctrl:set_item_background_colour(id, Vector3(1, 1, 1))

					found = true

					break
				end
			end

			if not found then
				for _, id in ipairs(self._error_box.tree_ctrl:get_children(self._critical_id)) do
					if ignore_id == id then
						self._error_box.tree_ctrl:set_item_text_colour(id, Vector3(1, 0, 0))
						self._error_box.tree_ctrl:set_item_background_colour(id, Vector3(1, 1, 1))

						found = true

						break
					end
				end
			end

			if found then
				table.delete(self._ignore_list, ignore_id)
			end
		end
	end
end

function CoreUnitTestBrowser:destroy()
	if alive(self._error_frame) then
		self._error_frame:destroy()

		self._error_frame = nil
	end

	if alive(self._search_frame) then
		self._search_frame:destroy()

		self._search_frame = nil
	end
end

function CoreUnitTestBrowser:close()
	self._error_frame:destroy()
	self:close_search()
end

function CoreUnitTestBrowser:close_search()
	if self._search_frame then
		self._search_frame:destroy()

		self._search_frame = nil
	end
end

function CoreUnitTestBrowser:on_find_unit()
	self:search_frame()
end

function CoreUnitTestBrowser:on_close()
	if self._autorun then
		self:close()
	else
		managers.toolhub:close("Unit Test Browser")
	end
end

function CoreUnitTestBrowser:on_close_search()
	self:close_search()
end

function CoreUnitTestBrowser:on_search()
	self._search_box.list_box:clear()

	local search_str = self._search_box.search_text_ctrl:get_value()

	if search_str ~= "" then
		for key, value in pairs(self._unit_msg) do
			if value.author and value.diesel and value.id then
				local str = value.author

				if self._search_box.type_combobox:get_value() == "Search By Name" then
					str = key
				elseif self._search_box.type_combobox:get_value() == "Search By Diesel Path" then
					str = value.diesel
				end

				if string.len(search_str) <= string.len(str) and (value.note == "failed" or value.note == "critical") then
					str = string.sub(str, 1, string.len(search_str))

					if search_str == str then
						self._search_box.list_box:append(key)
					end
				end
			end
		end
	end
end

function CoreUnitTestBrowser:on_listbox_selected()
	local unit_msg = self._unit_msg[self._search_box.list_box:get_string(self._search_box.list_box:selected_index())]

	if unit_msg and unit_msg.id then
		self._error_box.tree_ctrl:expand(self._root_id)
		self._error_box.tree_ctrl:collapse(self._passed_id)
		self._error_box.tree_ctrl:expand(self._failed_id)
		self._error_box.tree_ctrl:expand(self._critical_id)
		self._error_box.tree_ctrl:select_item(unit_msg.id, true)
	end
end

function CoreUnitTestBrowser:on_send_emails()
	if self._warning_mail_dialog:show_modal() == "ID_OK" then
		local call = "ruby unit_test_report"

		for unit_node in self._report_xml:children() do
			local found = false
			local found_failed = true

			for _, ignore_id in ipairs(self._ignore_list) do
				if unit_node:parameter("name") == self._error_box.tree_ctrl:get_item_text(ignore_id) then
					found = true

					break
				end
			end

			for _, id in ipairs(self._error_box.tree_ctrl:get_children(self._passed_id)) do
				if self._error_box.tree_ctrl:get_item_text(id) == unit_node:parameter("name") then
					found_failed = false

					break
				end
			end

			if not found and found_failed then
				call = call .. " -u" .. unit_node:parameter("name")
			end
		end

		Application:system(call, false)
	end
end

function CoreUnitTestBrowser:on_send_emails_to()
	if self._receiver_dialog:show_modal() then
		local receiver_name = self._receiver_dialog:get_value()
		local call = "ruby unit_test_report"

		for unit_node in self._report_xml:children() do
			local found = false
			local found_failed = true

			for _, ignore_id in ipairs(self._ignore_list) do
				if unit_node:parameter("name") == self._error_box.tree_ctrl:get_item_text(ignore_id) then
					found = true

					break
				end
			end

			for _, id in ipairs(self._error_box.tree_ctrl:get_children(self._passed_id)) do
				if self._error_box.tree_ctrl:get_item_text(id) == unit_node:parameter("name") then
					found_failed = false

					break
				end
			end

			if not found and found_failed then
				call = call .. " -to" .. receiver_name .. " -u" .. unit_node:parameter("name")
			end
		end

		Application:system(call, false)
	end
end

function CoreUnitTestBrowser:on_tree_ctrl_change()
	local id = self._error_box.tree_ctrl:selected_item()

	if id > -1 then
		local text = self._error_box.tree_ctrl:get_item_text(id)

		if text then
			local str = self._unit_msg[text]

			if str then
				self._error_box.text_ctrl:set_value(str.msg)
			else
				self._error_box.text_ctrl:set_value("")
			end
		end
	end
end

function CoreUnitTestBrowser:init_tree_view()
	self._error_box.tree_ctrl:clear()

	local num_units = 0
	local num_passed = 0
	local num_failed = 0
	local num_critical = 0
	self._root_id = self._error_box.tree_ctrl:append_root("Units")
	self._passed_id = self._error_box.tree_ctrl:append(self._root_id, "Passed")
	self._failed_id = self._error_box.tree_ctrl:append(self._root_id, "Failed")
	self._critical_id = self._error_box.tree_ctrl:append(self._root_id, "Critical")

	self._error_box.tree_ctrl:expand(self._root_id)

	for unit_node in self._report_xml:children() do
		if unit_node:name() == "unit" then
			num_units = num_units + 1
			local found_error = false
			local found_critical = false
			self._unit_msg[unit_node:parameter("name")] = {}
			self._unit_msg[unit_node:parameter("name")].msg = ""
			self._unit_msg[unit_node:parameter("name")].author = unit_node:parameter("author")
			self._unit_msg[unit_node:parameter("name")].diesel = unit_node:parameter("diesel")

			for info_node in unit_node:children() do
				if info_node:data() ~= "" then
					if info_node:name() == "crash_output" then
						found_critical = true
					else
						found_error = true
					end

					self._unit_msg[unit_node:parameter("name")].msg = self._unit_msg[unit_node:parameter("name")].msg .. "---------------------- " .. unit_node:parameter("author") .. " - " .. unit_node:parameter("name") .. " - " .. info_node:name() .. " ----------------------\n" .. info_node:data() .. "\n"
				end
			end

			if found_critical then
				num_critical = num_critical + 1
				self._unit_msg[unit_node:parameter("name")].note = "critical"
				self._unit_msg[unit_node:parameter("name")].id = self._error_box.tree_ctrl:append(self._critical_id, unit_node:parameter("name"))

				self._error_box.tree_ctrl:set_item_text_colour(self._unit_msg[unit_node:parameter("name")].id, Vector3(1, 0, 0))
			elseif found_error then
				num_failed = num_failed + 1
				self._unit_msg[unit_node:parameter("name")].note = "failed"
				self._unit_msg[unit_node:parameter("name")].id = self._error_box.tree_ctrl:append(self._failed_id, unit_node:parameter("name"))

				self._error_box.tree_ctrl:set_item_text_colour(self._unit_msg[unit_node:parameter("name")].id, Vector3(0.5, 0, 0))
			else
				num_passed = num_passed + 1
				self._unit_msg[unit_node:parameter("name")].note = "passed"
				self._unit_msg[unit_node:parameter("name")].msg = "Unit is OK and exported by: " .. unit_node:parameter("author")
				self._unit_msg[unit_node:parameter("name")].id = self._error_box.tree_ctrl:append(self._passed_id, unit_node:parameter("name"))

				self._error_box.tree_ctrl:set_item_text_colour(self._unit_msg[unit_node:parameter("name")].id, Vector3(0, 0.5, 0))
			end
		end
	end

	self._unit_msg.Units = {
		msg = tostring(num_units) .. " units tested."
	}
	self._unit_msg.Passed = {
		msg = tostring(num_passed) .. " / " .. tostring(num_units) .. " units passed the test."
	}
	self._unit_msg.Failed = {
		msg = tostring(num_failed) .. " / " .. tostring(num_units) .. " units failed the test."
	}
	self._unit_msg.Critical = {
		msg = tostring(num_critical) .. " / " .. tostring(num_units) .. " units is in a critical condition."
	}
end

CoreUnitTestBrowserInputDialog = CoreUnitTestBrowserInputDialog or class()

function CoreUnitTestBrowserInputDialog:init(p)
	self._dialog = EWS:Dialog(p, "Receiver", "", Vector3(0, 0, 0), Vector3(300, 86, 0), "CAPTION,SYSTEM_MENU")
	local box = EWS:BoxSizer("VERTICAL")
	local text_box = EWS:BoxSizer("HORIZONTAL")
	self._key_text_ctrl = EWS:TextCtrl(self._dialog, "", "", "TE_PROCESS_ENTER")

	self._key_text_ctrl:connect("", "EVT_COMMAND_TEXT_ENTER", callback(self, self, "on_send_button"), "")
	text_box:add(self._key_text_ctrl, 1, 0, "EXPAND")
	box:add(text_box, 0, 4, "ALL,EXPAND")

	local button_box = EWS:BoxSizer("HORIZONTAL")
	self._create = EWS:Button(self._dialog, "Send", "", "")

	self._create:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_send_button"), "")
	button_box:add(self._create, 1, 4, "ALL,EXPAND")

	self._cancel = EWS:Button(self._dialog, "Cancel", "", "")

	self._cancel:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_cancel_button"), "")
	button_box:add(self._cancel, 1, 4, "ALL,EXPAND")
	box:add(button_box, 0, 0, "EXPAND")
	self._dialog:set_sizer(box)
end

function CoreUnitTestBrowserInputDialog:show_modal()
	self._key_text_ctrl:set_value("")

	self._key = nil
	self._done = false
	self._return_val = true

	self._dialog:show_modal()

	while not self._done do
	end

	return self._return_val
end

function CoreUnitTestBrowserInputDialog:on_send_button()
	self._done = true
	self._key = self._key_text_ctrl:get_value()

	self._dialog:end_modal("")
end

function CoreUnitTestBrowserInputDialog:on_cancel_button()
	self._done = true
	self._return_val = false

	self._dialog:end_modal("")
end

function CoreUnitTestBrowserInputDialog:get_value()
	return self._key
end
