function CoreEditor:build_left_toolbar()
	local icons_path = managers.database:base_path() .. "core\\lib\\utils\\dev\\editor\\icons\\"
	local left_upper_panel = EWS:Panel(Global.frame_panel, "", "")
	local left_upper_panel_sizer = EWS:BoxSizer("VERTICAL")

	left_upper_panel:set_sizer(left_upper_panel_sizer)

	self._left_upper_toolbar = EWS:ToolBar(left_upper_panel, "", "TB_FLAT,TB_VERTICAL,TB_NODIVIDER")

	self._left_upper_toolbar:add_tool("TB_OPEN_WORLD_FOLDER", "Open world folder", CoreEWS.image_path("folder_open_16x16.png"), "Open world folder")
	self._left_upper_toolbar:connect("TB_OPEN_WORLD_FOLDER", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_open_world_folder"), nil)
	self._left_upper_toolbar:add_separator()
	self._left_upper_toolbar:add_check_tool("TB_PERFORMANCE_HUD", "Performance Hud", icons_path .. "prefhud.bmp", "Performance Hud")
	self._left_upper_toolbar:connect("TB_PERFORMANCE_HUD", "EVT_COMMAND_MENU_SELECTED", callback(managers.prefhud, managers.prefhud, "toggle"), managers.prefhud)
	self._left_upper_toolbar:add_check_tool("TB_DRAW_OCCLUDERS", "Draw Occluders", CoreEWS.image_path("world_editor\\draw_occluders_16x16.png"), "Toggle debug draw of occluder objects")
	self._left_upper_toolbar:set_tool_state("TB_DRAW_OCCLUDERS", self._draw_occluders)
	self._left_upper_toolbar:connect("TB_DRAW_OCCLUDERS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "toolbar_toggle"), {
		value = "_draw_occluders",
		toolbar = "_left_upper_toolbar",
		menu = "_debug_menu"
	})
	self._left_upper_toolbar:add_check_tool("TB_DRAW_HIDDEN_UNITS", "Draw Hidden Units", CoreEWS.image_path("world_editor\\draw_hidden_units_16x16.png"), "Toggle debug draw of hidden units")
	self._left_upper_toolbar:set_tool_state("TB_DRAW_HIDDEN_UNITS", self._draw_hidden_units)
	self._left_upper_toolbar:connect("TB_DRAW_HIDDEN_UNITS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "toolbar_toggle"), {
		value = "_draw_hidden_units",
		toolbar = "_left_upper_toolbar"
	})
	self._left_upper_toolbar:add_check_tool("TB_DRAW_BODIES", "Draw Bodies", CoreEWS.image_path("blob_16x16.png"), "Toggle debug draw of bodies")
	self._left_upper_toolbar:set_tool_state("TB_DRAW_BODIES", self._draw_bodies_on)
	self._left_upper_toolbar:connect("TB_DRAW_BODIES", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "toolbar_toggle"), {
		value = "_draw_bodies_on",
		toolbar = "_left_upper_toolbar"
	})
	self._left_upper_toolbar:add_check_tool("TB_FRUSTUM_FREEZE", "Frustum freeze/unfreeze", CoreEws.image_path("sequencer\\clip_icon_camera_00.png"), "Toggle frustum freeze on/off")
	self._left_upper_toolbar:set_tool_state("TB_FRUSTUM_FREEZE", false)
	self._left_upper_toolbar:connect("TB_FRUSTUM_FREEZE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_frustum_freeze_toggle"), nil)
	self._left_upper_toolbar:add_separator()
	self._left_upper_toolbar:add_tool("TB_MATERIAL_EDITOR", "Material Editor", CoreEWS.image_path("material_editor_16x16.png"), "Material Editor")
	self._left_upper_toolbar:connect("TB_MATERIAL_EDITOR", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_open_tool"), "Material Editor")
	self:_project_add_left_upper_toolbar_tool()
	self._left_upper_toolbar:add_separator()
	self._left_upper_toolbar:add_tool("TB_RELOAD_UNIT", "Reload Unit(s)", icons_path .. "reload_unit.bmp", "Reload Unit(s)")
	self._left_upper_toolbar:connect("TB_RELOAD_UNIT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_reload_unit"), "")
	self._left_upper_toolbar:add_tool("TB_RELOAD_UNIT_QUICK", "Reload Unit(s) Quick", icons_path .. "reload_unit_quick.bmp", "Reload Unit(s) Quick")
	self._left_upper_toolbar:connect("TB_RELOAD_UNIT_QUICK", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_reload_unit", true), "")
	self._left_upper_toolbar:add_tool("TB_CONNECT_SLAVE", "Connect Slave System", CoreEWS.image_path("connection_16x16.png"), "Connect Slave System")
	self._left_upper_toolbar:connect("TB_CONNECT_SLAVE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "connect_slave"), "")
	self._left_upper_toolbar:realize()
	left_upper_panel_sizer:add(self._left_upper_toolbar, 0, 0, "EXPAND")
	Global.left_toolbar_sizer:add(left_upper_panel, 0, 0, "EXPAND")
	Global.left_toolbar_sizer:add(EWS:Panel(Global.frame_panel, "", ""), 1, 0, "EXPAND")

	local left_panel = EWS:Panel(Global.frame_panel, "", "")
	local left_panel_sizer = EWS:BoxSizer("VERTICAL")

	left_panel:set_sizer(left_panel_sizer)

	self._left_toolbar = EWS:ToolBar(left_panel, "", "TB_FLAT,TB_VERTICAL,TB_NODIVIDER")

	self:add_edit_buttons()
	self._left_toolbar:add_tool("LTB_EDIT_UNIT", "Show edit unit dialog", CoreEWS.image_path("world_editor\\edit_settings_16x16.png"), "Help")
	self._left_toolbar:connect("LTB_EDIT_UNIT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "show_edit_unit"), nil)
	self._left_toolbar:add_separator()
	self._left_toolbar:add_tool("LTB_HELP", "Help", CoreEWS.image_path("help_16x16.png"), "Help")
	self._left_toolbar:connect("LTB_HELP", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_output_help"), nil)
	self._left_toolbar:add_tool("LTB_LIST_UNITS", "List units", CoreEWS.image_path("info_16x16.png"), "List units")
	self._left_toolbar:connect("LTB_LIST_UNITS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_list_units"), nil)
	self._left_toolbar:realize()
	left_panel_sizer:add(self._left_toolbar, 0, 0, "EXPAND")
	Global.left_toolbar_sizer:add(left_panel, 0, 0, "EXPAND")
end

function CoreEditor:_project_add_left_upper_toolbar_tool()
end

function CoreEditor:show_edit_unit()
	self:show_dialog("edit_unit", "EditUnitDialog")
end

function CoreEditor:on_open_tool(tool)
	managers.toolhub:open(tool)
end

function CoreEditor:on_output_help()
	local text = "\n"

	self:output(self._current_layer:get_help(text))
end

function CoreEditor:on_list_units()
	local units = World:find_units_quick("all")
	local amount = {}
	local total = 0

	for _, u in ipairs(units) do
		total = total + 1
		local name = u:name():s()

		if amount[name] then
			amount[name] = amount[name] + 1
		else
			amount[name] = 1
		end
	end

	self:output("", true)

	for name, amount in pairs(amount) do
		local len = string.len(name)
		local tabs = 6 - math.floor(len / 7)
		local tab = ""

		for j = 1, tabs do
			tab = tab .. "\t"
		end

		self:output(name .. tab .. amount, true)
	end

	self:output("", true)
	self:output("Total units: " .. total .. " Total Unique: " .. table.size(amount))
end

function CoreEditor:on_open_world_folder()
	if self._opendir then
		os.execute("explorer " .. self._opendir)
	end
end

function CoreEditor:_frustum_freeze_toggle(a, event)
	local state = self._left_upper_toolbar:tool_state(event:get_id())

	if state then
		self._camera_controller:frustum_freeze(self:camera())
	else
		self._camera_controller:frustum_unfreeze(self:camera())
	end
end

function CoreEditor:_interupt_frustum_freeze()
	if not self._camera_controller:frustum_frozen() then
		return
	end

	self._left_upper_toolbar:set_tool_state("TB_FRUSTUM_FREEZE", false)
	self._camera_controller:frustum_unfreeze(self:camera())
end
