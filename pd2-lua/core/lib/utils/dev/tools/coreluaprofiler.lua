core:import("CoreLuaDump")

CoreLuaProfiler = CoreLuaProfiler or class()
core_lua_profiler_reload = true
local SETTINGS_PATH = "lib\\utils\\dev\\editor\\xml\\lua_profiler.xml"

function CoreLuaProfiler:init()
	self._settings_path = managers.database:base_path() .. SETTINGS_PATH

	self:create_main_frame()

	self._profilers = {}
	self._profiler_sorting = "DO_NOT_SORT"
	self._frames_since_profilers_reset = 1
	self._frames_sample_steps = 1
	self._g_table = {}

	self:find_methods(_G, self._g_table)
	self:on_goto_global()
	table.sort(self._g_table, callback(self, self, "sort_by_name"))

	for _, it in ipairs(self._g_table) do
		if not it._source then
			self._main_frame_table._table_list_ctrl:append_item(it._name)
		end
	end

	core_lua_profiler_reload = true

	self._main_frame_table._table_list_ctrl:autosize_column(0)
	self:check_news(true)
end

function CoreLuaProfiler:create_main_frame()
	self._main_frame = EWS:Frame("LUA Profiler", Vector3(-1, -1, 0), Vector3(1000, 800, 0), "FRAME_FLOAT_ON_PARENT,DEFAULT_FRAME_STYLE", Global.frame)

	function self._resource_sort_func(a, b)
		return a._name:s() < b._name:s()
	end

	local sort_by_name = self._resource_sort_func

	local function sort_by_mem_use(a, b)
		return b._used < a._used
	end

	local menu_bar = EWS:MenuBar()
	local file_menu = EWS:Menu("")

	file_menu:append_item("NEWS", "Get Latest News", "")
	file_menu:append_separator()
	file_menu:append_item("EXIT", "Exit", "")
	menu_bar:append(file_menu, "File")

	self._resources_menu = EWS:Menu("")

	self._resources_menu:append_item("COLLECT_RESOURCES", "Collect\tCtrl+C", "")
	self._resources_menu:append_separator()
	self._resources_menu:append_radio_item("SORT_NAME", "Sort By Name", "")
	self._resources_menu:append_radio_item("SORT_MEM_USE", "Sort By Mem Use", "")
	self._resources_menu:set_checked("SORT_NAME", true)
	menu_bar:append(self._resources_menu, "Resources")

	local lua_menu = EWS:Menu("")

	lua_menu:append_item("SAMPLE_RATE", "Set Sample Rate\tCtrl+S", "")
	lua_menu:append_item("GOTO_GLOBAL", "Goto Global\tCtrl+G", "")
	menu_bar:append(lua_menu, "LUA")
	self._main_frame:set_menu_bar(menu_bar)
	self._main_frame:connect("NEWS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_check_news"), "")
	self._main_frame:connect("EXIT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_close"), "")
	self._main_frame:connect("COLLECT_RESOURCES", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_update_resources"), "")
	self._main_frame:connect("SORT_NAME", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_set_resource_sort_func"), sort_by_name)
	self._main_frame:connect("SORT_MEM_USE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_set_resource_sort_func"), sort_by_mem_use)
	self._main_frame:connect("DO_DUMP", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_do_dump"), "")
	self._main_frame:connect("DUMP_OPEN", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_open_dump"), "")
	self._main_frame:connect("SAMPLE_RATE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_set_sample_rate"), "")
	self._main_frame:connect("GOTO_GLOBAL", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_goto_global"), "")
	self._main_frame:connect("", "EVT_CLOSE_WINDOW", callback(self, self, "on_close"), "")

	local main_box = EWS:BoxSizer("VERTICAL")
	self._main_notebook = EWS:Notebook(self._main_frame, "", "")

	self._main_notebook:connect("", "EVT_COMMAND_NOTEBOOK_PAGE_CHANGING", callback(self, self, "on_notebook_changing"), "")
	main_box:add(self._main_notebook, 1, 0, "EXPAND")

	self._main_frame_table = {
		_main_panel = EWS:Panel(self._main_notebook, "", ""),
		_main_panel_box = EWS:BoxSizer("VERTICAL")
	}
	local panel_box = EWS:BoxSizer("VERTICAL")
	local splitter_box = EWS:BoxSizer("HORIZONTAL")
	local function_box = EWS:BoxSizer("VERTICAL")
	self._main_frame_table._function_list_ctrl = EWS:ListCtrl(self._main_frame_table._main_panel, "Watch Data", "LC_REPORT")

	self._main_frame_table._function_list_ctrl:connect("", "EVT_COMMAND_LIST_ITEM_ACTIVATED", callback(self, self, "on_select_function"), "")
	function_box:add(self._main_frame_table._function_list_ctrl, 2, 0, "EXPAND")
	self._main_frame_table._function_list_ctrl:append_column("Name")
	self._main_frame_table._function_list_ctrl:append_column("Source")

	self._main_frame_table._table_list_ctrl = EWS:ListCtrl(self._main_frame_table._main_panel, "Watch Data", "LC_REPORT,LC_SINGLE_SEL")

	self._main_frame_table._table_list_ctrl:connect("", "EVT_COMMAND_LIST_ITEM_ACTIVATED", callback(self, self, "on_select_table"), "")
	function_box:add(self._main_frame_table._table_list_ctrl, 3, 0, "EXPAND")
	self._main_frame_table._table_list_ctrl:append_column("Name")
	splitter_box:add(function_box, 2, 0, "EXPAND")

	self._main_frame_table._profiler_list_ctrl = EWS:ListCtrl(self._main_frame_table._main_panel, "Watch Data", "LC_REPORT")

	self._main_frame_table._profiler_list_ctrl:connect("", "EVT_COMMAND_LIST_ITEM_ACTIVATED", callback(self, self, "on_select_profiler"), "")
	splitter_box:add(self._main_frame_table._profiler_list_ctrl, 3, 0, "EXPAND")
	self._main_frame_table._profiler_list_ctrl:append_column("Name")
	self._main_frame_table._profiler_list_ctrl:append_column("Source")
	self._main_frame_table._profiler_list_ctrl:append_column("Calls")
	self._main_frame_table._profiler_list_ctrl:append_column("Time/Call")
	self._main_frame_table._profiler_list_ctrl:append_column("Cost/Call")
	self._main_frame_table._profiler_list_ctrl:append_column("Time")
	self._main_frame_table._profiler_list_ctrl:append_column("Cost")
	panel_box:add(splitter_box, 1, 0, "EXPAND")

	self._main_frame_table._mem_usage_text = EWS:StaticText(self._main_frame_table._main_panel, "Lua mem usage: 0.0 Mb", "", "")

	panel_box:add(self._main_frame_table._mem_usage_text, 0, 0, "EXPAND")
	self._main_frame_table._main_panel:set_sizer(panel_box)
	self._main_frame_table._main_panel_box:add(self._main_frame_table._main_panel, 1, 0, "EXPAND")

	self._resources_frame_table = {
		_main_panel = EWS:Panel(self._main_notebook, "", ""),
		_main_panel_box = EWS:BoxSizer("VERTICAL")
	}
	self._resources_frame_table._tree_ctrl = EWS:TreeCtrl(self._resources_frame_table._main_panel, "", "TR_HAS_BUTTONS,TR_LINES_AT_ROOT,TR_DEFAULT_STYLE,SUNKEN_BORDER,TR_HIDE_ROOT")

	self._resources_frame_table._tree_ctrl:connect("", "EVT_COMMAND_TREE_SEL_CHANGED", callback(self, self, "on_tree_ctrl_change"), "")
	self._resources_frame_table._main_panel_box:add(self._resources_frame_table._tree_ctrl, 1, 0, "EXPAND")
	self._resources_frame_table._main_panel:set_sizer(self._resources_frame_table._main_panel_box)
	self._main_notebook:add_page(self._resources_frame_table._main_panel, "Resources", true)
	self._main_notebook:add_page(self._main_frame_table._main_panel, "LUA", false)

	self._main_notebook_page_selected = 0

	self._main_frame:set_sizer(main_box)
	self._main_frame:set_visible(true)

	self._set_sample_rate_dialog = CoreLuaProfilerSampleRateDialog:new(self._main_frame)
end

function CoreLuaProfiler:on_set_resource_sort_func(data, event)
	self._resources_menu:set_checked("SORT_NAME", false)
	self._resources_menu:set_checked("SORT_MEM_USE", false)
	self._resources_menu:set_checked(event:get_id(), true)

	self._resource_sort_func = data

	self:on_update_resources()
end

function CoreLuaProfiler:on_notebook_changing()
	self._flag_notebook_change = true
end

function CoreLuaProfiler:notebook_change()
	if self._flag_notebook_change then
		if self._main_notebook:get_current_page() == self._main_notebook:get_page(0) then
			self._main_notebook_page_selected = 0
		else
			self._main_notebook_page_selected = 1
		end

		self._flag_notebook_change = nil
	end
end

function CoreLuaProfiler:notebook_selected()
	return self._main_notebook_page_selected
end

function CoreLuaProfiler:on_check_news()
	self:check_news()
end

function CoreLuaProfiler:check_news(new_only)
	local news = nil

	if new_only then
		news = managers.news:get_news("lua_profiler", self._main_frame)
	else
		news = managers.news:get_old_news("lua_profiler", self._main_frame)
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

function CoreLuaProfiler:binary_to_string(str)
	local out_str = ""

	for number in string.gmatch(str, "[%d]+") do
		out_str = out_str .. string.char(tonumber(number))
	end

	return out_str
end

function CoreLuaProfiler:dump_tree_expand(node)
	self._dump_frame_table._tree_ctrl:expand(node._id)

	if node._parent then
		local p = self._dump_tree_id_table[node._parent]

		assert(p)
		self:dump_tree_expand(p)
	end
end

function CoreLuaProfiler:on_dump_search()
	local found = nil
	local str = self._dump_frame_table._search_text_ctrl:get_value()
	local len = #self._dump_tree_id_table
	local max = str ~= "" and len * 2 or len
	local prog = EWS:ProgressDialog(self._main_frame, "Search", "Searching...", max, "PD_AUTO_HIDE,PD_SMOOTH,PD_CAN_SKIP")

	self._dump_frame_table._tree_ctrl:freeze()

	for i, v in pairs(self._dump_tree_id_table) do
		self._dump_frame_table._tree_ctrl:collapse(v._id)
		self._dump_frame_table._tree_ctrl:set_item_bold(v._id, false)

		if prog:skip() then
			prog:update_bar(max)

			return
		else
			prog:update_bar(i)
		end
	end

	if str ~= "" then
		for i, v in pairs(self._dump_tree_id_table) do
			if string.find(v._name, str) then
				found = true

				self:dump_tree_expand(v)
				self._dump_frame_table._tree_ctrl:set_item_bold(v._id, true)
			else
				self._dump_frame_table._tree_ctrl:set_item_bold(v._id, false)
			end

			if prog:skip() then
				prog:update_bar(max)

				return
			else
				prog:update_bar(len + i)
			end
		end
	end

	self._dump_frame_table._tree_ctrl:thaw()
end

function CoreLuaProfiler:on_open_dump()
	local dialog = EWS:FileDialog(self._main_frame, "Open Lua Dump XML", managers.database:base_path(), "", "XML files (*.xml)|*.xml", "OPEN,FILE_MUST_EXIST")

	if dialog:show_modal() then
		local cmd = "copy /Y \"" .. dialog:get_path() .. "\" \"" .. managers.database:base_path() .. "core\\temp\\dump.xml\""

		os.execute(cmd)
		Application:update_filesystem_index("/core/temp/dump.xml")
		self:open_dump()
	end
end

function CoreLuaProfiler:open_dump()
	local node = SystemFS:parse_xml("/core/temp/dump.xml")

	assert(node)

	self._dump_tree_id_table = {}

	self._dump_frame_table._tree_ctrl:freeze()
	self._dump_frame_table._tree_ctrl:clear()

	local root_name = "lua_dump"
	local root_id = self._dump_frame_table._tree_ctrl:append_root(root_name)
	self._dump_tree_id_table[root_id] = {
		_id = root_id,
		_name = root_name
	}

	self:fill_dump_tree_ctrl(node, root_id)
	self._dump_frame_table._tree_ctrl:thaw()
	self._dump_frame_table._tree_ctrl:refresh()
end

function CoreLuaProfiler:on_do_dump()
	local str = EWS:get_text_from_user(self._main_frame, "Enter variable you want to dump.", "Dump", "_G", Vector3(-1, -1, -1), true)

	if str ~= "" then
		local var = loadstring("return " .. str)()

		if var then
			CoreLuaDump.core_lua_dump("/core/temp/dump.xml", var)
			self:open_dump()
		end
	end
end

function CoreLuaProfiler:fill_dump_tree_ctrl(node, id)
	for n in node:children() do
		local name = n:name()
		local sufix = n:parameter("name")

		if sufix ~= "" then
			name = name .. " - " .. self:binary_to_string(sufix)
		end

		local new_id = self._dump_frame_table._tree_ctrl:append(id, name)
		self._dump_tree_id_table[new_id] = {
			_id = new_id,
			_name = n:name(),
			_parent = id
		}

		for k, v in pairs(n:parameter_map()) do
			local new_k_id = self._dump_frame_table._tree_ctrl:append(new_id, k)
			self._dump_tree_id_table[new_k_id] = {
				_id = new_k_id,
				_name = k,
				_parent = new_id
			}
			local bin_str = self:binary_to_string(v)
			local new_v_id = self._dump_frame_table._tree_ctrl:append(new_k_id, self:binary_to_string(v))
			self._dump_tree_id_table[new_v_id] = {
				_id = new_v_id,
				_name = bin_str,
				_parent = new_k_id
			}
		end

		self:fill_dump_tree_ctrl(n, new_id)
	end
end

function CoreLuaProfiler:load_profilers()
	if SystemFS:exists(self._settings_path) then
		local prev_class_name = self._class_name
		local prev_class_table = self._class_table
		local file = SystemFS:open(self._settings_path, "r")
		local node = Node.from_xml(file:read())

		file:close()
		self:remove_all_profilers()
		self._main_frame_table._profiler_list_ctrl:delete_all_items()

		for class_node in node:children() do
			self._class_name = class_node:parameter("name")
			local c = rawget(_G, self._class_name)

			if c then
				self:find_methods(c, self._class_table)

				for func_node in class_node:children() do
					local f = c[func_node:parameter("name")]

					if f then
						self:add_profiler(func_node:parameter("name"))
					end
				end
			end
		end

		self._class_name = prev_class_name
		self._class_table = prev_class_table
	end
end

function CoreLuaProfiler:get_child(node, name, key, value)
	for n in node:children() do
		if n:name() == name and n:parameter(key) == value then
			return n
		end
	end
end

function CoreLuaProfiler:save_profilers()
	local node = Node("lua_profiler")

	for k, v in pairs(self._profilers) do
		local n = self:get_child(node, "class", "name", v._class_name)

		if not n then
			n = node:make_child("class")

			n:set_parameter("name", v._class_name)
		end

		n:make_child("function"):set_parameter("name", v._function_name)
	end

	local file = SystemFS:open(self._settings_path, "w")

	file:write(node:to_xml())
	file:close()
end

function CoreLuaProfiler:on_set_sample_rate()
	if self._set_sample_rate_dialog:show_modal() then
		self._frames_sample_steps = self._set_sample_rate_dialog:get_value()
	end
end

function CoreLuaProfiler:on_goto_global()
	self._class_table = {}

	self:find_methods(_G, self._class_table)

	self._class_name = "_G"

	self:update_list()
end

function CoreLuaProfiler:sort_by_name(a, b)
	return string.lower(a._name) < string.lower(b._name)
end

function CoreLuaProfiler:update_list()
	table.sort(self._class_table, callback(self, self, "sort_by_name"))
	self._main_frame_table._function_list_ctrl:delete_all_items()

	for _, it in ipairs(self._class_table) do
		if it._source then
			local i = self._main_frame_table._function_list_ctrl:append_item(it._name)

			self._main_frame_table._function_list_ctrl:set_item(i, 1, it._source)
		end
	end

	self._main_frame_table._function_list_ctrl:autosize_column(0)
	self._main_frame_table._function_list_ctrl:autosize_column(1)
end

function CoreLuaProfiler:find_table(name)
	for _, it in ipairs(self._g_table) do
		if not it._source and it._name == name then
			return it
		end
	end
end

function CoreLuaProfiler:find_function(name)
	for _, it in ipairs(self._class_table) do
		if it._source and it._name == name then
			return it
		end
	end
end

function CoreLuaProfiler:set_position(newpos)
	self._main_frame:set_position(newpos)
end

function CoreLuaProfiler:on_close()
	managers.toolhub:close("LUA Profiler")
end

function CoreLuaProfiler:on_select_profiler()
	local selected_idices = self._main_frame_table._profiler_list_ctrl:selected_items()
	local sources = {}

	table.sort(selected_idices, function (a, b)
		return b < a
	end)

	for _, selected_index in ipairs(selected_idices) do
		table.insert(sources, self._main_frame_table._profiler_list_ctrl:get_item(selected_index, 1))
		self._main_frame_table._profiler_list_ctrl:delete_item(selected_index)
	end

	for _, source in ipairs(sources) do
		if self._profilers[source] then
			local f = self._profilers[source]._old_func
			rawget(_G, self._profilers[source]._class_name)[self._profilers[source]._function_name] = f
			self._profilers[source] = nil

			Application:console_command("profiler remove " .. source)
		end
	end

	self:save_profilers()
end

function CoreLuaProfiler:remove_all_profilers()
	for k, v in pairs(self._profilers) do
		rawget(_G, v._class_name)[v._function_name] = v._old_func

		Application:console_command("profiler remove " .. k)
	end

	self._profilers = {}
end

function CoreLuaProfiler:add_profiler(name)
	local func_table = self:find_function(name)

	if not self._profilers[func_table._source] then
		self._profilers[func_table._source] = {
			_class_name = self._class_name,
			_function_name = func_table._name,
			_calls = 0,
			_time = 0
		}
		local f = rawget(_G, self._class_name)[func_table._name]
		self._profilers[func_table._source]._old_func = f

		rawget(_G, self._class_name)[func_table._name] = function (...)
			local profiler_id = Profiler:start(func_table._source)
			local ret_list = {
				f(...)
			}

			Profiler:stop(profiler_id)

			return unpack(ret_list)
		end

		local i = self._main_frame_table._profiler_list_ctrl:append_item(func_table._name)

		self._main_frame_table._profiler_list_ctrl:set_item(i, 1, func_table._source)
		self._main_frame_table._profiler_list_ctrl:autosize_column(0)
		Application:console_command("profiler add " .. func_table._source)
	end
end

function CoreLuaProfiler:on_select_function()
	for _, selected_index in ipairs(self._main_frame_table._function_list_ctrl:selected_items()) do
		self:add_profiler(self._main_frame_table._function_list_ctrl:get_item(selected_index, 0))
	end

	self:save_profilers()
end

function CoreLuaProfiler:on_select_table()
	local name = self._main_frame_table._table_list_ctrl:get_item(self._main_frame_table._table_list_ctrl:selected_item(), 0)
	self._class_table = {}
	self._class_name = name

	self:find_methods(self:find_table(name)._table, self._class_table)
	self:update_list()
end

function CoreLuaProfiler:destroy()
	if alive(self._main_frame) then
		self._main_frame:destroy()

		self._main_frame = nil
	end
end

function CoreLuaProfiler:close()
	self:remove_all_profilers()
	self._main_frame:destroy()
end

function CoreLuaProfiler:reset_profilers()
	if self._frames_sample_steps <= self._frames_since_profilers_reset then
		self._frames_since_profilers_reset = 1

		for k, v in pairs(self._profilers) do
			v._calls = 0
			v._time = 0
		end
	else
		self._frames_since_profilers_reset = self._frames_since_profilers_reset + 1
	end
end

function CoreLuaProfiler:update_profilers()
	for k, v in pairs(self._profilers) do
		v._calls = v._calls + Profiler:counter_calls(k)
		v._time = v._time + Profiler:counter_time(k)
	end
end

function CoreLuaProfiler:roundup(value)
	local f = math.floor(value)

	if value - f > 0 then
		return f + 1
	else
		return f
	end
end

function CoreLuaProfiler:update_profiler_list()
	for k, v in pairs(self._profilers) do
		local calls = v._calls / self._frames_sample_steps
		local t = v._time / self._frames_sample_steps
		local time = t / math.clamp(calls, 1, 1000000) * 1000
		local cost = t * 6000 / math.clamp(calls, 1, 1000000)
		local total_time = t * 1000
		local total_cost = t * 6000
		local i = 0

		while i < self._main_frame_table._profiler_list_ctrl:item_count() do
			if self._main_frame_table._profiler_list_ctrl:get_item(i, 1) == k then
				break
			end

			i = i + 1
		end

		self._main_frame_table._profiler_list_ctrl:set_item(i, 2, self:roundup(calls))
		self._main_frame_table._profiler_list_ctrl:set_item(i, 3, string.format("%.2f", time) .. " ms")
		self._main_frame_table._profiler_list_ctrl:set_item(i, 4, string.format("%.2f", cost) .. " %")
		self._main_frame_table._profiler_list_ctrl:set_item(i, 5, string.format("%.2f", total_time) .. " ms")
		self._main_frame_table._profiler_list_ctrl:set_item(i, 6, string.format("%.2f", total_cost) .. " %")
	end
end

function CoreLuaProfiler:update_mem()
	local memuse = collectgarbage("count") / 1024

	self._main_frame_table._mem_usage_text:set_value("Lua mem usage: " .. string.format("%.1f", memuse) .. " Mb")
end

function CoreLuaProfiler:update(t, dt)
	self:notebook_change()

	if self:notebook_selected() ~= 0 then
		if core_lua_profiler_reload then
			core_lua_profiler_reload = false

			self:load_profilers()
		end

		self:update_profilers()

		if self._frames_sample_steps > 1 or not self._last_update or t - self._last_update > 0.5 then
			self._last_update = t

			if self._frames_sample_steps <= self._frames_since_profilers_reset then
				self:update_profiler_list()
				self:update_mem()
			end
		end

		self:reset_profilers()
	end
end

function CoreLuaProfiler:find_methods(in_table, out_table)
	for k, v in pairs(in_table) do
		if type(v) == "function" then
			local info = debug.getinfo(v, "S")

			if info.what == "Lua" then
				local info_table = {
					_name = k,
					_table = v,
					_source = info.source .. ":" .. info.linedefined
				}

				table.insert(out_table, info_table)
			end
		elseif type(v) == "table" and v.type_name ~= k then
			local info_table = {
				_name = k,
				_table = v
			}

			table.insert(out_table, info_table)
		end
	end
end

function CoreLuaProfiler:on_tree_ctrl_change()
end

function CoreLuaProfiler:on_update_resources()
	self._resources_frame_table._tree_ctrl:freeze()
	self._resources_frame_table._tree_ctrl:clear()

	local root_id = self._resources_frame_table._tree_ctrl:append_root("World")
	local mem_report = {}
	local units = World:find_units_quick("all")

	for _, unit in ipairs(units) do
		if not mem_report[unit:name()] then
			mem_report[unit:name()] = {
				_num = 1,
				_unit = unit
			}
		else
			local prev = mem_report[unit:name()]
			prev._num = prev._num + 1
		end
	end

	self._unit_report = {}

	for k, v in pairs(mem_report) do
		table.insert(self._unit_report, {
			_name = k,
			_used = v._unit:geometry_memory_use(),
			_unit = v._unit,
			_extensions = v._unit:extensions(),
			_textures = v._unit:used_texture_names()
		})
	end

	table.sort(self._unit_report, self._resource_sort_func)

	for _, v in ipairs(self._unit_report) do
		self._unit_report._unit_id = self._resources_frame_table._tree_ctrl:append(root_id, v._name:s())

		self._resources_frame_table._tree_ctrl:set_item_bold(self._unit_report._unit_id, true)
		self._resources_frame_table._tree_ctrl:append(self._unit_report._unit_id, "Author: " .. tostring(v._unit:author()))
		self._resources_frame_table._tree_ctrl:append(self._unit_report._unit_id, "Enabled: " .. tostring(v._unit:enabled()))
		self._resources_frame_table._tree_ctrl:append(self._unit_report._unit_id, "Visible: " .. tostring(v._unit:visible()))
		self._resources_frame_table._tree_ctrl:append(self._unit_report._unit_id, "Slot: " .. tostring(v._unit:slot()))
		self._resources_frame_table._tree_ctrl:append(self._unit_report._unit_id, "Num Bodies: " .. tostring(v._unit:num_bodies()))
		self._resources_frame_table._tree_ctrl:append(self._unit_report._unit_id, "Diesel: " .. v._unit:diesel_filename())
		self._resources_frame_table._tree_ctrl:append(self._unit_report._unit_id, "Material Config: " .. v._unit:material_config():s())
		self._resources_frame_table._tree_ctrl:append(self._unit_report._unit_id, "Geometry Mem: " .. tostring(math.round(v._used / 1024)) .. "Kb")

		if #v._textures > 0 then
			self._unit_report._textures_id = self._resources_frame_table._tree_ctrl:append(self._unit_report._unit_id, "Used Textures")

			self._resources_frame_table._tree_ctrl:set_item_bold(self._unit_report._textures_id, true)

			for _, texture_name in ipairs(v._textures) do
				self._resources_frame_table._tree_ctrl:append(self._unit_report._textures_id, texture_name)
			end
		end

		if #v._extensions > 0 then
			self._unit_report._extensions_id = self._resources_frame_table._tree_ctrl:append(self._unit_report._unit_id, "Script Extensions")

			self._resources_frame_table._tree_ctrl:set_item_bold(self._unit_report._extensions_id, true)

			for _, extension_name in ipairs(v._extensions) do
				self._resources_frame_table._tree_ctrl:append(self._unit_report._extensions_id, extension_name)
			end
		end
	end

	self._resources_frame_table._tree_ctrl:thaw()
	self._resources_frame_table._tree_ctrl:refresh()
end

CoreLuaProfilerSampleRateDialog = CoreLuaProfilerSampleRateDialog or class()

function CoreLuaProfilerSampleRateDialog:init(p)
	self._dialog = EWS:Dialog(p, "Sample Rate", "", Vector3(-1, -1, 0), Vector3(200, 86, 0), "CAPTION,SYSTEM_MENU")
	local box = EWS:BoxSizer("VERTICAL")
	local text_box = EWS:BoxSizer("HORIZONTAL")
	self._key_text_ctrl = EWS:TextCtrl(self._dialog, "", "", "TE_PROCESS_ENTER")

	self._key_text_ctrl:connect("", "EVT_COMMAND_TEXT_ENTER", callback(self, self, "on_set_button"), "")
	text_box:add(self._key_text_ctrl, 1, 0, "EXPAND")
	box:add(text_box, 0, 4, "ALL,EXPAND")

	local button_box = EWS:BoxSizer("HORIZONTAL")
	self._set = EWS:Button(self._dialog, "Set", "", "")

	self._set:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_set_button"), "")
	button_box:add(self._set, 1, 4, "ALL,EXPAND")

	self._cancel = EWS:Button(self._dialog, "Cancel", "", "")

	self._cancel:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_cancel_button"), "")
	button_box:add(self._cancel, 1, 4, "ALL,EXPAND")
	box:add(button_box, 0, 0, "EXPAND")
	self._dialog:set_sizer(box)
end

function CoreLuaProfilerSampleRateDialog:show_modal()
	self._key_text_ctrl:set_value("1")

	self._key = nil
	self._done = false
	self._return_val = true

	self._dialog:show_modal()

	while not self._done do
	end

	return self._return_val
end

function CoreLuaProfilerSampleRateDialog:on_set_button()
	self._done = true
	self._key = self._key_text_ctrl:get_value()

	self._dialog:end_modal("")
end

function CoreLuaProfilerSampleRateDialog:on_cancel_button()
	self._done = true
	self._return_val = false

	self._dialog:end_modal("")
end

function CoreLuaProfilerSampleRateDialog:get_value()
	return math.max(1, tonumber(self._key))
end
