CoreUnitReloader = CoreUnitReloader or class()

function CoreUnitReloader:init()
	self._unit_msg = {}
	self._no_skipping = true

	self:create_main_frame()
end

function CoreUnitReloader:destroy()
	if alive(self._unitreloader_frame) then
		self._unitreloader_frame:destroy()

		self._unitreloader_frame = nil
	end
end

function CoreUnitReloader:create_main_frame()
	self._unitreloader_frame = EWS:Frame("Unit Reloader", Vector3(100, 400, 0), Vector3(250, 350, 0), "FRAME_FLOAT_ON_PARENT,DEFAULT_FRAME_STYLE", Global.frame)
	local menu_bar = EWS:MenuBar()
	local file_menu = EWS:Menu("")

	file_menu:append_item("RELOAD", "Reload Units", "")
	file_menu:append_item("RELOAD_ALL", "Reload All Units", "")
	file_menu:append_separator()
	file_menu:append_item("RELOAD_LIST", "Reload List", "")
	file_menu:append_separator()
	file_menu:append_item("EXIT", "Exit", "")
	menu_bar:append(file_menu, "File")
	self._unitreloader_frame:set_menu_bar(menu_bar)
	self._unitreloader_frame:connect("RELOAD", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_reload"), "")
	self._unitreloader_frame:connect("RELOAD_ALL", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_reload_all"), "")
	self._unitreloader_frame:connect("RELOAD_LIST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_reload_list"), "")
	self._unitreloader_frame:connect("EXIT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_close"), "")
	self._unitreloader_frame:connect("", "EVT_CLOSE_WINDOW", callback(self, self, "on_close"), "")

	local main_box = EWS:BoxSizer("VERTICAL")

	main_box:add(EWS:BitmapButton(self._unitreloader_frame, "dock.bmp", "", ""), 0, 0, "EXPAND")

	self._main_box = {
		unit_combo_box = EWS:ComboBox(self._unitreloader_frame, "", "", "CB_SORT")
	}

	self._main_box.unit_combo_box:connect("", "EVT_COMMAND_TEXT_ENTER", callback(self, self, "on_reload"), "")
	main_box:add(self._main_box.unit_combo_box, 0, 0, "EXPAND")

	self._main_box.reload_btn = EWS:Button(self._unitreloader_frame, "Reload", "", "")

	self._main_box.reload_btn:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_reload"), "")
	main_box:add(self._main_box.reload_btn, 0, 0, "EXPAND")

	self._main_box.listbox = EWS:ListBox(self._unitreloader_frame, "", "")

	main_box:add(self._main_box.listbox, 1, 0, "EXPAND")

	self._warning_dialog = EWS:MessageDialog(self._unitreloader_frame, "This unit has a script extension. Continue anyway?", "Warning", "")
	self._warning_unit_test_dialog = EWS:MessageDialog(self._unitreloader_frame, "This will test spawn all units in the database. Continue?", "Warning", "")
	self._warning_reload_all_dialog = EWS:MessageDialog(self._unitreloader_frame, "This will reload all units. Continue?", "Warning", "")

	self._unitreloader_frame:set_sizer(main_box)
	self._unitreloader_frame:set_visible(true)
end

function CoreUnitReloader:set_position(newpos)
	self._unitreloader_frame:set_position(newpos)
end

function CoreUnitReloader:update(t, dt)
	if not self._initialized then
		self._initialized = true
		local units_in_world = World:find_units_quick("all")

		self._main_box.unit_combo_box:clear()

		for _, unit_in_world in ipairs(units_in_world) do
			self._main_box.unit_combo_box:append(unit_in_world:name())
			self._main_box.unit_combo_box:set_value(unit_in_world:name())
		end
	end
end

function CoreUnitReloader:close()
	self._unitreloader_frame:destroy()
end

function CoreUnitReloader:check_extensions()
	local units = World:find_units_quick("all")

	for _, unit in ipairs(units) do
		if unit:name() == self._main_box.unit_combo_box:get_value() then
			for _, extension in ipairs(unit:extensions()) do
				if extension ~= "unit_data" and extension ~= "damage" then
					return self._warning_dialog:show_modal() == "ID_OK"
				end
			end
		end
	end

	return true
end

function CoreUnitReloader:on_reload()
	if self:check_extensions(self._main_box.unit_combo_box:get_value()) then
		self:reload_units(self._main_box.unit_combo_box:get_value())
	end
end

function CoreUnitReloader:on_reload_all()
	if self._warning_reload_all_dialog:show_modal() == "ID_OK" then
		self._initialized = false
		local units_in_world = World:find_units_quick("all")

		self._main_box.unit_combo_box:clear()

		for _, unit_in_world in ipairs(units_in_world) do
			self:reload_units(unit_in_world:name())
		end
	end
end

function CoreUnitReloader:on_reload_list()
	self._initialized = false
end

function CoreUnitReloader:on_close()
	managers.toolhub:close("Unit Reloader")
end

function CoreUnitReloader:log(string)
	self._main_box.listbox:append(string)
	self._main_box.listbox:select_index(self._main_box.listbox:nr_items() - 1)
end

function CoreUnitReloader:reload_units(unit_name)
	local num_reloads = reload_units(unit_name)

	self:log(num_reloads .. " " .. unit_name .. " reloaded.")
end
