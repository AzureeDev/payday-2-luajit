CreateWorldSettingFile = CreateWorldSettingFile or class(CoreEditorEwsDialog)

function CreateWorldSettingFile:init(params)
	CoreEditorEwsDialog.init(self, nil, "World Setting", "", Vector3(300, 150, 0), Vector3(200, 400, 0), "DEFAULT_DIALOG_STYLE,RESIZE_BORDER,STAY_ON_TOP")
	self:create_panel("VERTICAL")
	self._dialog_sizer:add(self._panel, 1, 0, "EXPAND")

	local button_sizer = EWS:BoxSizer("HORIZONTAL")

	if params.path then
		local t = self:_parse_file(managers.database:entry_path(params.path))

		if not t then
			return
		end

		self._path = params.path

		self:_add_continent_cbs(t)

		local save_btn = EWS:Button(self._panel, "Save", "", "")

		button_sizer:add(save_btn, 0, 2, "RIGHT,LEFT")
		save_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_save"), "")
	else
		self._name = params.name
		self._dir = params.dir
		self._path = params.dir .. "/" .. params.name .. ".world_setting"

		self:_add_continent_cbs()

		local create_btn = EWS:Button(self._panel, "Create", "", "")

		button_sizer:add(create_btn, 0, 2, "RIGHT,LEFT")
		create_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_create"), "")
	end

	local cancel_btn = EWS:Button(self._panel, "Cancel", "", "")

	button_sizer:add(cancel_btn, 0, 2, "RIGHT,LEFT")
	cancel_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_cancel"), "")
	cancel_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	self._panel_sizer:add(button_sizer, 0, 0, "ALIGN_RIGHT")
	self._dialog:show_modal()
end

function CreateWorldSettingFile:_add_continent_cbs(params)
	self._cbs = {}
	local sizer = EWS:StaticBoxSizer(self._panel, "VERTICAL", "Exclude continents")

	for name, _ in pairs(params or managers.editor:continents()) do
		local cb = EWS:CheckBox(self._panel, name, "", "ALIGN_LEFT")

		sizer:add(cb, 0, 0, "EXPAND")
		cb:set_value(params and params[name] or false)

		self._cbs[name] = cb
	end

	self._panel_sizer:add(sizer, 1, 0, "EXPAND")
end

function CreateWorldSettingFile:on_create()
	local t = {}

	for name, cb in pairs(self._cbs) do
		t[name] = cb:get_value()
	end

	local settings = SystemFS:open(self._path, "w")

	settings:puts(ScriptSerializer:to_generic_xml(t))
	SystemFS:close(settings)
	self:end_modal()
	self:_compile(self._path)
end

function CreateWorldSettingFile:_compile(path)
	local t = {
		target_db_name = "all",
		send_idstrings = false,
		preprocessor_definitions = "preprocessor_definitions",
		verbose = false,
		platform = string.lower(SystemInfo:platform():s()),
		source_root = managers.database:root_path() .. "/assets",
		target_db_root = Application:base_path() .. "assets",
		source_files = {
			managers.database:entry_path_with_properties(path)
		}
	}

	Application:data_compile(t)
	DB:reload()
	managers.database:clear_all_cached_indices()
end

function CreateWorldSettingFile:on_save()
	self:on_create()
end

function CreateWorldSettingFile:_serialize_to_script(type, name)
	return PackageManager:editor_load_script_data(type:id(), name:id())
end

function CreateWorldSettingFile:_parse_file(path)
	if not DB:has("world_setting", path) then
		return
	end

	local settings = SystemFS:parse_xml(managers.database:entry_expanded_path("world_setting", path))

	if settings:name() == "settings" then
		local t = {}

		for continent in settings:children() do
			t[continent:parameter("name")] = toboolean(continent:parameter("exclude"))
		end

		return t
	else
		return self:_serialize_to_script("world_setting", path)
	end
end

function CreateWorldSettingFile:on_cancel()
	self:end_modal()
end
