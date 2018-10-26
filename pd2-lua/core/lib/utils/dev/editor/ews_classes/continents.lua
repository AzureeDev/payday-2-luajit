ContinentPanel = ContinentPanel or class()

function ContinentPanel:init(parent)
	self:create_panel(parent, "VERTICAL")
	self:create_continent_panel(self._panel, "VERTICAL")

	self._continents_sizer = EWS:StaticBoxSizer(self._panel, "HORIZONTAL", "Continents")

	self._panel_sizer:add(self._continents_sizer, 1, 0, "EXPAND")
	self._continents_sizer:add(self:create_toolbar(), 0, 0, "EXPAND")
	self._continents_sizer:add(self._continent_panel, 1, 0, "EXPAND")
	self._panel_sizer:add(self:create_world_setting(), 0, 0, "EXPAND")

	self._continent_panels = {}
end

function ContinentPanel:create_toolbar()
	local toolbar_sizer = EWS:BoxSizer("VERTICAL")
	self._toolbar = EWS:ToolBar(self._panel, "", "TB_FLAT,TB_NODIVIDER,TB_VERTICAL")

	self._toolbar:add_tool("CREATE_CONTINENT", "Create a new continent", CoreEWS.image_path("world_editor\\new_continent_16x16.png"), "Create a new continent")
	self._toolbar:connect("CREATE_CONTINENT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "create_continent_dialog"), nil)
	self._toolbar:add_tool("DELETE_CONTINENT", "Delete the current continent", CoreEWS.image_path("toolbar\\delete_16x16.png"), "Delete the current continent")
	self._toolbar:connect("DELETE_CONTINENT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "delete_continent"), nil)
	toolbar_sizer:add(self._toolbar, 1, 0, "EXPAND")
	self._toolbar:realize()

	return toolbar_sizer
end

function ContinentPanel:create_world_setting()
	local sizer = EWS:BoxSizer("HORIZONTAL")
	self._world_setting_toolbar = EWS:ToolBar(self._panel, "", "TB_FLAT,TB_NODIVIDER")

	self._world_setting_toolbar:add_tool("CREATE_WORLD_SETTING", "Create a world setting file", CoreEWS.image_path("world_editor\\continent\\create_world_setting_16x16.png"), "Create a world setting file")
	self._world_setting_toolbar:connect("CREATE_WORLD_SETTING", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "create_world_setting_dialog"), nil)
	self._world_setting_toolbar:add_tool("OPEN_WORLD_SETTING", "Open a world setting file to edit", CoreEWS.image_path("toolbar\\open_16x16.png"), "Open a world setting file to edit")
	self._world_setting_toolbar:connect("OPEN_WORLD_SETTING", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "open_world_setting_dialog"), nil)
	sizer:add(self._world_setting_toolbar, 0, 0, "EXPAND")

	self._world_setting_path = EWS:StaticText(self._panel, "-", 0, "ALIGN_CENTRE")

	sizer:add(self._world_setting_path, 1, 0, "ALIGN_CENTER_VERTICAL")

	self._right_world_setting_toolbar = EWS:ToolBar(self._panel, "", "TB_FLAT,TB_NODIVIDER")

	self._right_world_setting_toolbar:add_tool("CLEAR_SIMULATION_WORLD_SETTING", "Removes the world setting file when simulating", CoreEWS.image_path("toolbar\\delete_16x16.png"), "Removes the world setting file when simulating")
	self._right_world_setting_toolbar:connect("CLEAR_SIMULATION_WORLD_SETTING", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "remove_simulation_world_setting_dialog"), nil)
	self._right_world_setting_toolbar:add_tool("SET_SIMULATION_WORLD_SETTING", "Set a world setting file to use when simulating", CoreEWS.image_path("toolbar\\open_16x16.png"), "Set a world setting file to use when simulating")
	self._right_world_setting_toolbar:connect("SET_SIMULATION_WORLD_SETTING", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "set_simulation_world_setting_dialog"), nil)
	sizer:add(self._right_world_setting_toolbar, 0, 10, "EXPAND,RIGHT")
	self._world_setting_toolbar:realize()
	self._right_world_setting_toolbar:realize()

	return sizer
end

function ContinentPanel:panel()
	return self._panel
end

function ContinentPanel:create_panel(parent, orientation)
	self._panel = EWS:Panel(parent, "", "TAB_TRAVERSAL,ALWAYS_SHOW_SB")
	self._panel_sizer = EWS:BoxSizer(orientation)

	self._panel:set_sizer(self._panel_sizer)
end

function ContinentPanel:create_continent_panel(parent, orientation)
	self._continent_panel = EWS:ScrolledWindow(parent, "", "VSCROLL,TAB_TRAVERSAL,SIMPLE_BORDER")

	self._continent_panel:set_scroll_rate(Vector3(0, 20, 0))
	self._continent_panel:set_virtual_size_hints(Vector3(0, 0, 0), Vector3(1, -1, -1))
	self._continent_panel:set_background_colour(255, 255, 255)
	self._continent_panel:refresh()

	self._continent_panel_sizer = EWS:BoxSizer(orientation)

	self._continent_panel:set_sizer(self._continent_panel_sizer)
end

function ContinentPanel:create_continent_dialog()
	local name = EWS:get_text_from_user(Global.frame_panel, "Enter name for new continent:", "Create new continent", "", Vector3(-1, -1, 0), true)

	if name and name ~= "" then
		if managers.editor:continent(name) then
			self:create_continent_dialog()
		else
			managers.editor:create_continent(name, {})
		end
	end
end

function ContinentPanel:add_continent(params)
	local panel = EWS:Panel(self._continent_panel, "", "TAB_TRAVERSAL")
	params.panel = panel
	local sizer = EWS:BoxSizer("HORIZONTAL")

	panel:set_sizer(sizer)
	panel:set_background_colour(255, 255, 255)

	params.toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	params.toolbar:add_tool("HIDE_ALL", "Hide all units in the continent", CoreEWS.image_path("world_editor\\continent\\hide_all_16x16.png"), "Hide all units in the continen")
	params.toolbar:connect("HIDE_ALL", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "hide_all"), params)
	params.toolbar:add_tool("UNHIDE_ALL", "Unhides all units in the continent", CoreEWS.image_path("world_editor\\continent\\unhide_all_16x16.png"), "Hide all units in the continen")
	params.toolbar:connect("UNHIDE_ALL", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "unhide_all"), params)
	params.toolbar:add_check_tool("LOCKED", "Toggle locked", CoreEWS.image_path("world_editor\\continent\\locked_16x16.png"), "Toggle locked")
	params.toolbar:set_tool_state("LOCKED", params.locked)
	params.toolbar:connect("LOCKED", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "toggle_locked"), params)
	params.toolbar:add_check_tool("ENABLED_IN_SIMULATION", "Toggles if this continent is enabled when simulating", CoreEWS.image_path("world_editor\\continent\\use_when_simulate_16x16.png"), "Toggles if this continent is enabled when simulating")
	params.toolbar:set_tool_state("ENABLED_IN_SIMULATION", params.enabled_in_simulation)
	params.toolbar:connect("ENABLED_IN_SIMULATION", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "toggle_enabled_in_simulation"), params)
	params.toolbar:add_check_tool("EDITOR_ONLY", "Toggles if this continent only is loaded in editor", CoreEWS.image_path("world_editor\\continent\\editor_only_16x16.png"), "Toggles if this continent only is loaded in editor")
	params.toolbar:set_tool_state("EDITOR_ONLY", params.editor_only)
	params.toolbar:connect("EDITOR_ONLY", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "toggle_editor_only"), params)
	params.toolbar:realize()
	self:_set_toolbar_colour(params)
	sizer:add(params.toolbar, 0, 1, "EXPAND,BOTTOM")

	params.toggle_button = EWS:ToggleButton(panel, params.continent:name(), "", "")

	params.toggle_button:connect("EVT_COMMAND_TOGGLEBUTTON_CLICKED", callback(self, self, "toggle_button_clicked"), params)
	sizer:add(params.toggle_button, 1, 0, "EXPAND")
	self._continent_panel_sizer:add(panel, 0, 1, "EXPAND,BOTTOM")
	self._continent_panel:refresh()
	self._continent_panel:fit_inside()
	table.insert(self._continent_panels, params)

	return panel
end

function ContinentPanel:toggle_visible(params)
end

function ContinentPanel:toggle_locked(params)
	params.continent:set_locked(params.toolbar:tool_state("LOCKED"))
	self:_set_toolbar_colour(params)
end

function ContinentPanel:_set_toolbar_colour(params)
	local locked = params.toolbar:tool_state("LOCKED")

	params.toolbar:set_background_colour(locked and 150 or 255, locked and 50 or 255, locked and 50 or 255)
	params.panel:refresh()
end

function ContinentPanel:hide_all(params)
	params.continent:set_visible(false)
end

function ContinentPanel:unhide_all(params)
	params.continent:set_visible(true)
end

function ContinentPanel:toggle_enabled_in_simulation(params)
	params.continent:set_value("enabled_in_simulation", params.toolbar:tool_state("ENABLED_IN_SIMULATION"))
end

function ContinentPanel:toggle_editor_only(params)
	params.continent:set_value("editor_only", params.toolbar:tool_state("EDITOR_ONLY"))
end

function ContinentPanel:toggle_button_clicked(params)
	managers.editor:set_continent(params.continent:name())
end

function ContinentPanel:update_continent_panel(continent)
	for _, params in ipairs(self._continent_panels) do
		if params.continent == continent then
			params.toolbar:set_tool_state("LOCKED", continent:value("locked"))
			params.toolbar:set_tool_state("ENABLED_IN_SIMULATION", continent:value("enabled_in_simulation"))
			params.toolbar:set_tool_state("EDITOR_ONLY", continent:value("editor_only"))

			break
		end
	end
end

function ContinentPanel:set_continent(continent)
	for _, params in ipairs(self._continent_panels) do
		params.toggle_button:set_value(params.continent == continent)
	end
end

function ContinentPanel:delete_continent()
	managers.editor:delete_continent()
end

function ContinentPanel:destroy_continent(continent)
	for _, params in ipairs(self._continent_panels) do
		if params.continent == continent then
			self:_destroy_continent(params)

			return
		end
	end
end

function ContinentPanel:_destroy_continent(params)
	if not table.contains(self._continent_panels, params) then
		return
	end

	table.delete(self._continent_panels, params)
	params.panel:destroy()
	self._continent_panel:fit_inside()
end

function ContinentPanel:destroy_all_continents()
	for _, params in ipairs(clone(self._continent_panels)) do
		self:_destroy_continent(params)
	end
end

function ContinentPanel:create_world_setting_dialog()
	if not managers.editor:lastfile() then
		local confirm = EWS:message_box(Global.frame_panel, "Can't create world setting when the level isn't saved.", "Continent", "OK,ICON_ERROR", Vector3(-1, -1, 0))

		return
	end

	local path, dir = managers.database:save_file_dialog(Global.frame, true, "World setting (*.world_setting)|*.world_setting", managers.editor:get_open_dir())

	if path and dir then
		CreateWorldSettingFile:new({
			name = managers.database:entry_name(path),
			dir = dir
		})
	end
end

function ContinentPanel:open_world_setting_dialog()
	local path, dir = managers.database:open_file_dialog(Global.frame, "World setting (*.world_setting)|*.world_setting", managers.editor:get_open_dir())

	if path and dir then
		CreateWorldSettingFile:new({path = path})
	end
end

function ContinentPanel:set_simulation_world_setting_dialog()
	local path, dir = managers.database:open_file_dialog(Global.frame, "World setting (*.world_setting)|*.world_setting", managers.editor:get_open_dir())

	if path and dir then
		managers.editor:set_simulation_world_setting_path(managers.database:entry_path(path))
	end
end

function ContinentPanel:remove_simulation_world_setting_dialog()
	managers.editor:set_simulation_world_setting_path(nil)
end

function ContinentPanel:set_world_setting_path(path)
	self._world_setting_path:set_value(path or "-")
	self._panel:layout()
end

