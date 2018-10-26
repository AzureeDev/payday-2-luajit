core:module("CoreToolHub")
core:import("CoreDebug")

ToolHub = ToolHub or class()

function ToolHub:init()
	self._main_frame = nil
	self._shed = {}
	self._init = {}
	self._tools = {}
	self._closelist = {}
	self._current = nil
	self._show = false
	self._f4 = false
	self._dbgmenu = nil
	self._statsmenu = nil
	self._cheatmenu = nil
	self._catprintmenu = nil
	self._startscreen = "primary"

	self:create()
end

function ToolHub:destroy()
	if alive(self._main_frame) then
		for _, tool in pairs(self._tools) do
			if tool.destroy then
				tool:destroy()
			end
		end

		self._main_frame:set_visible(false)
		self._main_frame:destroy_children()
		self._main_frame:destroy()
	end
end

function ToolHub:update(time, rel_time)
	local kb = Input:keyboard()

	if kb:released(Idstring("f4")) or self._f4 then
		self._f4 = false

		if not self._show then
			self:show()
		else
			self._main_frame:set_focus()
		end
	end

	for key, value in pairs(self._tools) do
		value:update(time, rel_time)
	end

	for key, value in pairs(self._closelist) do
		local tool = self._tools[key]

		if tool ~= nil then
			cat_print("debug", "ToolHub: Shutting down tool '" .. key .. "'.")
			self._tools[key]:close()

			tool = nil
			self._tools[key] = nil

			if Global.frame then
				Global.frame:set_focus()
			end
		end
	end

	self._closelist = {}
end

function ToolHub:end_update(time, delta_time)
	for key, value in pairs(self._tools) do
		if value.end_update then
			value:end_update(time, delta_time)
		end
	end
end

function ToolHub:paused_update(time, rel_time)
	self:update(time, rel_time)
end

function ToolHub:create()
	self._main_frame = EWS:Frame("Tool Hub", Vector3(-1, -1, 0), Vector3(800, 55, 0), "CAPTION,SYSTEM_MENU,MINIMIZE_BOX,CLOSE_BOX")

	self._main_frame:connect("", "EVT_CLOSE_WINDOW", callback(self, self, "on_close"), "")

	local main_box = EWS:BoxSizer("VERTICAL")
	self._main_panel = EWS:Panel(self._main_frame)

	main_box:add(self._main_panel, 1, 0, "EXPAND")
	self._main_frame:set_sizer(main_box)
	self._main_frame:set_visible(false)
	self._main_frame:set_position(self:getscreenpos(self._startscreen))
end

function ToolHub:get_tool_menu(frame)
	local sortkeys = {}

	for n in pairs(self._shed) do
		sortkeys[#sortkeys + 1] = n
	end

	table.sort(sortkeys)

	local tool_menu = EWS:Menu("")

	for key, value in pairs(sortkeys) do
		tool_menu:append_item(value, value, "")
		frame:connect(value, "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_opentool"), "")
	end

	return tool_menu
end

function ToolHub:buildmenu()
	local menu_bar = EWS:MenuBar()
	local file_menu = EWS:Menu("")
	local sortkeys = {}

	for n in pairs(self._shed) do
		sortkeys[#sortkeys + 1] = n
	end

	table.sort(sortkeys)

	for key, value in pairs(sortkeys) do
		file_menu:append_item(value, value, "")
		self._main_frame:connect(value, "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_opentool"), "")
	end

	file_menu:append_separator()
	file_menu:append_item("TB_CLOSE", "Close", "")
	menu_bar:append(file_menu, "File")

	self._dbgmenu = EWS:Menu("")

	self:menu_showcommands()
	menu_bar:append(self._dbgmenu, "Debug Draw")

	self._statsmenu = EWS:Menu("")

	self:menu_statsommands()
	menu_bar:append(self._statsmenu, "Stats")
	self._main_frame:set_menu_bar(menu_bar)
	self._main_frame:connect("TB_CLOSE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_close"), "")
	self._main_frame:set_menu_bar(menu_bar)
	self._main_frame:connect("TB_CLOSE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_close"), "")

	self._catprintmenu = EWS:Menu("")

	self._catprintmenu:append_item("TB_CATPRINT_SAVE", "Save", "")
	self._main_frame:connect("TB_CATPRINT_SAVE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_catprint_save"), "")
	self._catprintmenu:append_item("TB_CATPRINT_DRAWDEBUG", "DrawDebug", "")
	self._main_frame:connect("TB_CATPRINT_DRAWDEBUG", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_catprint_drawdebug"), "")
	self._catprintmenu:append_separator()

	local sorted_category_list = {}

	for key in pairs(Global.category_print) do
		table.insert(sorted_category_list, key)
	end

	table.sort(sorted_category_list)

	for _, key in ipairs(sorted_category_list) do
		self._catprintmenu:append_check_item(key, key, "")
		self._main_frame:connect(key, "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_catprint"), "")
		self._catprintmenu:set_checked(key, not not Global.category_print[key])
	end

	menu_bar:append(self._catprintmenu, "CatPrint")

	self._settingsmenu = EWS:Menu("")

	menu_bar:append(self._settingsmenu, "Settings")

	self._screenmenu = EWS:Menu("")

	self._screenmenu:append_item("TB_SETSCREEN-primary", "primary")
	self._screenmenu:append_item("TB_SETSCREEN-left", "left")
	self._screenmenu:append_item("TB_SETSCREEN-right", "right")
	self._settingsmenu:append_menu("TB_MESHDUMP", "Set Tool Screen", self._screenmenu, "Screen")
	self._main_frame:connect("TB_SETSCREEN-primary", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "set_screen"), "")
	self._main_frame:connect("TB_SETSCREEN-left", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "set_screen"), "")
	self._main_frame:connect("TB_SETSCREEN-right", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "set_screen"), "")

	local view_menu = EWS:Menu("")

	view_menu:append_item("LIGHTING", "Deferred Lighting", "Change visualization to Deferred Lighting")
	view_menu:append_item("ALBEDO", "Albedo", "Change visualization to Albedo")
	view_menu:append_item("NORMAL", "Normal", "Change visualization to Normal")
	view_menu:append_item("SPECULAR", "Specular", "Change visualization to Specular")
	view_menu:append_item("GLOSSINESS", "Glossiness", "Change visualization to Glossiness")
	menu_bar:append(view_menu, "View")
	self._main_frame:connect("LIGHTING", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "change_visualization"), "deferred_lighting")
	self._main_frame:connect("ALBEDO", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "change_visualization"), "albedo_visualization")
	self._main_frame:connect("NORMAL", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "change_visualization"), "normal_visualization")
	self._main_frame:connect("SPECULAR", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "change_visualization"), "specular_visualization")
	self._main_frame:connect("GLOSSINESS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "change_visualization"), "glossiness_visualization")

	if SystemInfo:platform() == Idstring("WIN32") then
		local resolution_menu = EWS:Menu("")

		for _, res in ipairs(RenderSettings.modes) do
			local str = res.x .. "x" .. res.y .. ":" .. res.z

			resolution_menu:append_item(str, str, "")
			self._main_frame:connect(str, "EVT_COMMAND_MENU_SELECTED", callback(self, self, "change_resolution"), res)
		end

		resolution_menu:append_separator()
		resolution_menu:append_item("4/3", "4/3", "")
		resolution_menu:append_item("16/9", "16/9", "")
		resolution_menu:append_item("16/10", "16/10", "")
		resolution_menu:append_item("w/h", "w/h", "")
		self._main_frame:connect("4/3", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "change_aspect_ratio"), 1.3333333333333333)
		self._main_frame:connect("16/9", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "change_aspect_ratio"), 1.7777777777777777)
		self._main_frame:connect("16/10", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "change_aspect_ratio"), 1.6)

		local res = RenderSettings.resolution

		self._main_frame:connect("w/h", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "change_aspect_ratio"), res.x / res.y)
		resolution_menu:append_separator()
		resolution_menu:append_item("TOGGLE_FULLSCREEN", "Toggle Fullscreen", "")
		self._main_frame:connect("TOGGLE_FULLSCREEN", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "toggle_fullscreen"), "")
		menu_bar:append(resolution_menu, "Resolution")
	end
end

function ToolHub:change_visualization(viz)
	for _, vp in ipairs(managers.viewport:viewports()) do
		vp:set_visualization_mode(viz)
	end
end

function ToolHub:toggle_fullscreen()
	managers.viewport:set_fullscreen(not RenderSettings.fullscreen)
end

function ToolHub:change_resolution(custom_data, event_object)
	managers.viewport:set_resolution(custom_data)
end

function ToolHub:change_aspect_ratio(custom_data, event_object)
	managers.viewport:set_aspect_ratio(custom_data)
end

function ToolHub:menu_showcommands()
	self:register_showcommand("show_gui", "show_gui")
	self:register_showcommand("show_gui_sprites", "show_gui_sprites")
	self:register_showcommand("show_gui_buttons", "show_gui_buttons")
	self:register_showcommand("show_objects", "show_objects")
	self:register_showcommand("show_panels", "show_panels")
	self:register_showcommand("show_workspaces", "show_workspaces")
	self:register_showcommand("show_collision_mover", "show_collision_mover")
	self:register_showcommand("show_ai_graphs", "show_ai_graphs")
	self:register_showcommand("show_static_ai_graphs", "show_static_ai_graphs")
	self:register_showcommand("show_collision_aabb", "show_collision_aabb")
	self:register_showcommand("show_collision_oobb", "show_collision_oobb")
	self:register_showcommand("show_collision_shape", "show_collision_shape")
	self:register_showcommand("show_camera", "show_camera")
	self:register_showcommand("show_water", "show_water")
	self:register_showcommand("show_unit_rotpos", "show_unit_rotpos")
	self:register_showcommand("show_world_listener", "show_world_listener")
	self:register_showcommand("show_ai_steering", "show_ai_steering")
	self:register_showcommand("show_point_detector", "show_point_detector")
	self:register_showcommand("show_sound", "show_sound")
	self:register_showcommand("show_lights", "show_lights")
	self:register_showcommand("show_links", "show_links")
	self:register_showcommand("show_bones", "show_bones")
	self:register_showcommand("show_find", "show_find")
	self:register_showcommand("show_mini_physics", "show_mini_physics")
	self:register_showcommand("show_occluders", "show_occluders")
	self:register_showcommand("show_bodies", "show_bodies")
	self:register_showcommand("verbose_animations", "verbose_animations")
	self:register_showcommand("show_ambient_cube_blend", "show_ambient_cube_blend")
	self:register_showcommand("show_moving", "show_moving")
	self:register_showcommand("show_camera_controller", "show_camera_controller")
	self:register_showcommand("show_raycast", "show_raycast")
	self:register_showcommand("show_effect_surface_volume", "show_effect_surface_volume")
	self:register_showcommand("show_tngeffects", "show_tngeffects")
	self:register_showcommand("print_tngeffects", "print_tngeffects")
	self:register_showcommand("show_phantoms", "show_phantoms")
	self:register_showcommand("show_shadow_projection", "show_shadow_projection")
end

function ToolHub:menu_statsommands()
	self:register_statscommands("atombatcher", "atombatcher")
	self:register_statscommands("cullingmanager", "cullingmanager")
	self:register_statscommands("d3d", "d3d")
	self:register_statscommands("d3d_locks", "d3d_locks")
	self:register_statscommands("d3d_mem", "d3d_mem")
	self:register_statscommands("deferred", "deferred")
	self:register_statscommands("gui", "gui")
	self:register_statscommands("main", "main")
	self:register_statscommands("massunit", "massunit")
	self:register_statscommands("mem", "mem")
	self:register_statscommands("network", "network")
	self:register_statscommands("physics", "physics")
	self:register_statscommands("profiler", "profiler")
	self:register_statscommands("shadowmapper", "shadowmapper")
	self:register_statscommands("sound", "sound")
	self:register_statscommands("sound_playing", "sound_playing")
	self:register_statscommands("stall", "stall")
	self:register_statscommands("unit_profiler", "unit_profiler")
end

function ToolHub:register_statscommands(commandname, text)
	self._statsmenu:append_check_item("TB_" .. commandname, text, "")
	self._main_frame:connect("TB_" .. commandname, "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_stats"), "")
end

function ToolHub:register_showcommand(commandname, text)
	self._dbgmenu:append_check_item("TB_" .. commandname, text, "")
	self._main_frame:connect("TB_" .. commandname, "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_gaaa"), "")
end

function ToolHub:hide()
	self._main_frame:set_visible(false)

	self._show = false
end

function ToolHub:show()
	self._main_frame:set_visible(true)

	self._show = true
end

function ToolHub:on_close()
	self:hide()
end

function ToolHub:add(name, tool_class, init_args)
	self._shed[name] = tool_class
	self._init[name] = init_args or {}
end

function ToolHub:open(name)
	local tool = self._tools[name]

	if not tool then
		tool = self:prepare(name)
		self._tools[name] = tool

		tool:set_position(self:getscreenpos(self._startscreen))
	end
end

function ToolHub:close(name)
	self._closelist[name] = true

	cat_print("debug", "ToolHub: Tool '" .. name .. "' added to close down list.")
end

function ToolHub:prepare(name)
	local tool_class = self._shed[name]

	if tool_class then
		local tool = tool_class:new(unpack(self._init[name]))

		return tool
	end

	return nil
end

function ToolHub:on_opentool(gaa, commandevent)
	cat_print("debug", "Should Open Toool: " .. commandevent:get_id())
	self:open(commandevent:get_id())
end

function ToolHub:on_stats(gaa, commandevent)
	local cmdname = string.sub(commandevent:get_id(), 4)

	Application:console_command("stats " .. cmdname)
	cat_print("debug", "stats " .. cmdname)
end

function ToolHub:on_gaaa(gaa, commandevent)
	local ischecked = self._dbgmenu:is_checked(commandevent:get_id())
	local cmdname = string.sub(commandevent:get_id(), 4)

	if ischecked == false then
		Application:console_command("set " .. cmdname .. " false")
	else
		Application:console_command("set " .. cmdname .. " true")
	end
end

function ToolHub:on_catprint(gaa, commandevent)
	cat_print("debug", "Should Toogle Catprint: " .. commandevent:get_id())

	local ischecked = self._catprintmenu:is_checked(commandevent:get_id())

	if ischecked == false then
		Global.category_print[commandevent:get_id()] = false
	else
		Global.category_print[commandevent:get_id()] = true
	end
end

function ToolHub:on_catprint_save(gaa, commandevent)
	cat_print("debug", "Should Save Catprint")
	CoreDebug.catprint_save()
end

function ToolHub:on_catprint_drawdebug(gaa, commandevent)
	if Global.render_debug == nil then
		return
	end

	Global.render_debug.draw_enabled = not Global.render_debug.draw_enabled

	cat_print("debug", "Toggle draw of debug info: " .. tostring(Global.render_debug.draw_enabled))
end

function ToolHub:set_screen(gaa, commandevent)
	cat_print("debug", "Should set_screen: " .. commandevent:get_id())

	if commandevent:get_id() == "TB_SETSCREEN-primary" then
		self._startscreen = "primary"
	end

	if commandevent:get_id() == "TB_SETSCREEN-left" then
		self._startscreen = "left"
	end

	if commandevent:get_id() == "TB_SETSCREEN-right" then
		self._startscreen = "right"
	end
end

function ToolHub:getscreenpos(screen)
	if screen == "primary" then
		return Vector3(100, 100, 0)
	end

	if screen == "left" then
		return Vector3(-1000, 100, 0)
	end

	if screen == "right" then
		return Vector3(1800, 100, 0)
	end
end

