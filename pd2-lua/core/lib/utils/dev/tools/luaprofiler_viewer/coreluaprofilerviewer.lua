core:module("CoreLuaProfilerViewer")
core:import("CoreLuaProfilerTreeBox")
core:import("CoreLuaProfilerGridBox")
core:import("CoreClass")
core:import("CoreEvent")
core:import("CoreDebug")
core:import("CoreKeywordArguments")

TOOLHUB_NAME = "Lua Profiler II"
local PERCENT = 0
local SECONDS = 1
local CUSTOM = 2
local DEFAULT_FORMAT = PERCENT
local DEFAULT_INFOKEY = "total_time"
LuaProfilerViewer = LuaProfilerViewer or CoreClass.class()

function LuaProfilerViewer:init()
	self._lpd = EWS:LuaProfilerDataStore()

	self:_create_main_frame()
end

function LuaProfilerViewer:_create_main_frame()
	self._frame = EWS:Frame(TOOLHUB_NAME, Vector3(100, 400, 0), Vector3(1500, 800, 0), "FRAME_FLOAT_ON_PARENT,DEFAULT_FRAME_STYLE", Global.frame)
	local frame_sizer = EWS:BoxSizer("VERTICAL")
	local splitter1 = EWS:SplitterWindow(self._frame, "", "")

	self:_create_menu(self._frame)

	self._treeview = CoreLuaProfilerTreeBox.LuaProfilerTreeBox:new({
		parent = splitter1
	})
	self._gridview = CoreLuaProfilerGridBox.LuaProfilerGridBox:new({
		parent = splitter1
	})

	self._treeview:set_gridview({
		gridview = self._gridview
	})
	self._gridview:set_treeview({
		treeview = self._treeview
	})

	self._displayformat = DEFAULT_FORMAT
	self._capturecounter = 0
	self._on_percent_cb = CoreEvent.callback(self, self, "_on_percent")
	self._on_seconds_cb = CoreEvent.callback(self, self, "_on_seconds")
	self._on_custom_cb = CoreEvent.callback(self, self, "_on_custom")
	self._on_acc_calls_cb = CoreEvent.callback(self, self, "_on_acc_calls")
	self._on_no_acc_calls_cb = CoreEvent.callback(self, self, "_on_no_acc_calls")

	splitter1:split_vertically(self._treeview.panel, self._gridview.panel, "")
	splitter1:set_minimum_pane_size(50)
	splitter1:set_sash_gravity(1)
	splitter1:set_sash_position(500, true)
	frame_sizer:add(splitter1, 1, 0, "EXPAND")
	self._frame:set_sizer(frame_sizer)
	self._frame:set_visible(true)
	self:_redraw_menu()
end

function LuaProfilerViewer:_create_menu()
	local file_menu = EWS:Menu("")

	file_menu:append_item("OPEN", "Open\tCtrl+O", "")
	file_menu:append_item("EXIT", "Exit", "")

	local view_menu = EWS:Menu("")
	self._view_menu = view_menu
	self._view_menu_filled = false
	self._view_menu_connects = {}
	local capt_menu = EWS:Menu("")

	capt_menu:append_item("CAPTURE", "Capture Frame\tCtrl+F", "")

	local menu_bar = EWS:MenuBar()

	menu_bar:append(file_menu, "File")
	menu_bar:append(view_menu, "View")
	menu_bar:append(capt_menu, "Capture")
	self._frame:set_menu_bar(menu_bar)
	self._frame:connect("OPEN", "EVT_COMMAND_MENU_SELECTED", CoreEvent.callback(self, self, "_on_open"), "")
	self._frame:connect("EXIT", "EVT_COMMAND_MENU_SELECTED", CoreEvent.callback(self, self, "_on_close"), "")
	self._frame:connect("", "EVT_CLOSE_WINDOW", CoreEvent.callback(self, self, "_on_close"), "")
	self._frame:connect("CAPTURE", "EVT_COMMAND_MENU_SELECTED", CoreEvent.callback(self, self, "_on_capture"), "")
end

function LuaProfilerViewer:_redraw_menu()
	local lpd = self._lpd
	self._displayformat = PERCENT

	if self._view_menu_filled then
		self._frame:disconnect("PERCENT", "EVT_COMMAND_MENU_SELECTED", self._on_percent_cb)
		self._frame:disconnect("SECONDS", "EVT_COMMAND_MENU_SELECTED", self._on_seconds_cb)
		self._frame:disconnect("ACC", "EVT_COMMAND_MENU_SELECTED", self._on_acc_calls_cb)
		self._frame:disconnect("NO_ACC", "EVT_COMMAND_MENU_SELECTED", self._on_no_acc_calls_cb)

		for _, diffpeak in ipairs(self._view_menu_connects) do
			self._frame:disconnect(diffpeak, "EVT_COMMAND_MENU_SELECTED", self._on_custom_cb)
		end

		self._view_menu_filled = false
		self._view_menu_connects = {}

		self._view_menu:clear()
	end

	self._view_menu:append_separator()
	self._view_menu:append_radio_item("PERCENT", "Time in %\tCtrl+P", "")
	self._frame:connect("PERCENT", "EVT_COMMAND_MENU_SELECTED", self._on_percent_cb, "")
	self._view_menu:append_radio_item("SECONDS", "Time in ms\tCtrl+M", "")
	self._frame:connect("SECONDS", "EVT_COMMAND_MENU_SELECTED", self._on_seconds_cb, "")

	for i = 0, lpd:numheaders() - 1 do
		local name = string.capitalize(lpd:headername(i))
		local diffpeak = string.format("%s:-1", i)

		self._view_menu:append_radio_item(diffpeak, "Diff " .. name, "")
		self._frame:connect(diffpeak, "EVT_COMMAND_MENU_SELECTED", self._on_custom_cb, diffpeak)
		table.insert(self._view_menu_connects, diffpeak)

		local diffpeak = string.format("-1:%s", i)

		self._view_menu:append_radio_item(diffpeak, "Peak " .. name, "")
		self._frame:connect(diffpeak, "EVT_COMMAND_MENU_SELECTED", self._on_custom_cb, diffpeak)
		table.insert(self._view_menu_connects, diffpeak)
	end

	self._view_menu:append_separator()
	self._view_menu:append_radio_item("ACC", "Acc. and sort Calls", "")
	self._frame:connect("ACC", "EVT_COMMAND_MENU_SELECTED", self._on_acc_calls_cb, "")
	self._view_menu:append_radio_item("NO_ACC", "Keep Call order", "")
	self._frame:connect("NO_ACC", "EVT_COMMAND_MENU_SELECTED", self._on_no_acc_calls_cb, "")

	self._view_menu_filled = true
end

function LuaProfilerViewer:close()
	if self._frame then
		self._frame:destroy()
	end

	self._treeview:destroy()
	self._gridview:destroy()

	self._treeview = nil
	self._gridview = nil
	self._lpd = nil
end

function LuaProfilerViewer:set_position(newpos)
	if self._frame then
		self._frame:set_position(newpos)
	end
end

function LuaProfilerViewer:update(t, dt)
	if self._capturecounter == 4 then
		Application:console_command("luaprofiler dump")
	end

	if self._capturecounter == 1 then
		self:_on_open()
	end

	if self._capturecounter > 0 then
		self._capturecounter = self._capturecounter - 1
	end
end

function LuaProfilerViewer:_on_close()
	managers.toolhub:close(TOOLHUB_NAME)
end

function LuaProfilerViewer:_on_open()
	local filedialog = EWS:FileDialog(self._frame, "Open 'luaprofiler dump_stat' File", managers.database:base_path(), "", "*.pf", "")

	filedialog:show_modal()

	local name = filedialog:get_filename()
	local path = filedialog:get_directory()
	local filepath = string.format("%s\\%s", path, name)

	if name ~= "" then
		local lpd = EWS:LuaProfilerDataStore()
		local cause = lpd:parsefile(filepath)

		if cause == "" then
			self._lpd = lpd

			self:_redraw_menu()
			self._lpd:buildstructure(true)
			self._treeview:set_profilerdata({
				lpd = self._lpd,
				displayformat = self._displayformat
			})
			self._gridview:set_profilerdata({
				lpd = self._lpd,
				displayformat = self._displayformat
			})
		else
			EWS:MessageDialog(self._frame, cause, "Loading Error", ""):show_modal()
		end
	end
end

function LuaProfilerViewer:_on_percent()
	self._displayformat = PERCENT

	if self._lpd then
		local calltree_modified = self._lpd:set_cn_key(-1, -1)

		if calltree_modified then
			self._treeview:set_profilerdata({
				lpd = self._lpd,
				displayformat = self._displayformat
			})
			self._gridview:set_displayformat({
				displayformat = self._displayformat
			})
		else
			self._treeview:set_displayformat({
				displayformat = self._displayformat
			})
			self._gridview:set_displayformat({
				displayformat = self._displayformat
			})
		end
	end
end

function LuaProfilerViewer:_on_seconds()
	self._displayformat = SECONDS

	if self._lpd then
		local calltree_modified = self._lpd:set_cn_key(-1, -1)

		if calltree_modified then
			self._treeview:set_profilerdata({
				lpd = self._lpd,
				displayformat = self._displayformat
			})
			self._gridview:set_displayformat({
				displayformat = self._displayformat
			})
		else
			self._treeview:set_displayformat({
				displayformat = self._displayformat
			})
			self._gridview:set_displayformat({
				displayformat = self._displayformat
			})
		end
	end
end

function LuaProfilerViewer:_on_custom(diffpeak)
	self._displayformat = CUSTOM
	local diff = tonumber(string.split(diffpeak, ":")[1])
	local peak = tonumber(string.split(diffpeak, ":")[2])

	if self._lpd then
		local calltree_modified = self._lpd:set_cn_key(diff, peak)

		if calltree_modified then
			self._treeview:set_profilerdata({
				lpd = self._lpd,
				displayformat = self._displayformat
			})
		else
			self._treeview:set_displayformat({
				displayformat = self._displayformat
			})
		end
	end
end

function LuaProfilerViewer:_on_acc_calls()
	if self._lpd then
		self._lpd:buildstructure(true)
		self._treeview:set_profilerdata({
			lpd = self._lpd,
			displayformat = self._displayformat
		})
		self._gridview:set_profilerdata({
			lpd = self._lpd,
			displayformat = self._displayformat
		})
	end
end

function LuaProfilerViewer:_on_no_acc_calls()
	if self._lpd then
		self._lpd:buildstructure(false)
		self._treeview:set_profilerdata({
			lpd = self._lpd,
			displayformat = self._displayformat
		})
		self._gridview:set_profilerdata({
			lpd = self._lpd,
			displayformat = self._displayformat
		})
	end
end

function LuaProfilerViewer:_on_capture()
	self._capturecounter = 6
end
