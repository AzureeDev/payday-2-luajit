core:module("CoreLevelSettingsLayer")
core:import("CoreLayer")
core:import("CoreEws")

LevelSettingsLayer = LevelSettingsLayer or class(CoreLayer.Layer)

function LevelSettingsLayer:init(owner)
	LevelSettingsLayer.super.init(self, owner, "level_settings")

	self._settings = {}
	self._settings_ctrlrs = {}
end

function LevelSettingsLayer:get_layer_name()
	return "Level Settings"
end

function LevelSettingsLayer:get_setting(setting)
	return self._settings[setting]
end

function LevelSettingsLayer:get_mission_filter()
	local t = {}

	for i = 1, 5 do
		if self:get_setting("mission_filter_" .. i) then
			table.insert(t, i)
		end
	end

	return t
end

function LevelSettingsLayer:load(world_holder, offset)
	self._settings = world_holder:create_world("world", self._save_name, offset)

	for id, setting in pairs(self._settings_ctrlrs) do
		if setting.type == "combobox" then
			CoreEws.change_combobox_value(setting.params, self._settings[id])
		end
	end
end

function LevelSettingsLayer:save(save_params)
	local t = {
		single_data_block = true,
		entry = self._save_name,
		data = {
			settings = self._settings
		}
	}

	self:_add_project_save_data(t.data)
	managers.editor:add_save_data(t)
end

function LevelSettingsLayer:update(t, dt)
end

function LevelSettingsLayer:build_panel(notebook)
	cat_print("editor", "LevelSettingsLayer:build_panel")

	self._ews_panel = EWS:Panel(notebook, "", "TAB_TRAVERSAL")
	self._main_sizer = EWS:BoxSizer("HORIZONTAL")

	self._ews_panel:set_sizer(self._main_sizer)

	self._sizer = EWS:BoxSizer("VERTICAL")

	self:_add_chunk_name(self._ews_panel, self._sizer)
	self:_add_simulation_level_id(self._sizer)
	self:_add_simulation_mission_filter(self._sizer)
	self._main_sizer:add(self._sizer, 1, 0, "EXPAND")

	return self._ews_panel
end

function LevelSettingsLayer:_add_simulation_level_id(sizer)
	local id = "simulation_level_id"
	local params = {
		default = "none",
		name = "Simulation level id:",
		value = "none",
		ctrlr_proportions = 2,
		name_proportions = 1,
		tooltip = "Select a level id to use when simulating the level.",
		sorted = true,
		panel = self._ews_panel,
		sizer = sizer,
		options = rawget(_G, "tweak_data").levels:get_level_index()
	}
	local ctrlr = CoreEws.combobox(params)

	ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_set_data"), {
		ctrlr = ctrlr,
		value = id
	})

	self._settings_ctrlrs[id] = {
		default = "none",
		type = "combobox",
		params = params,
		ctrlr = ctrlr
	}
end

function LevelSettingsLayer:_add_simulation_mission_filter(sizer)
	for i = 1, 5 do
		local id = "mission_filter_" .. i
		local ctrlr = EWS:CheckBox(self._ews_panel, "Mission filter " .. i, "")

		ctrlr:set_value(false)
		ctrlr:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "_set_data"), {
			ctrlr = ctrlr,
			value = id
		})
		sizer:add(ctrlr, 0, 0, "EXPAND")

		self._settings_ctrlrs[id] = {
			default = false,
			type = "checkbox",
			ctrlr = ctrlr
		}
	end
end

function LevelSettingsLayer:_add_chunk_name(panel, sizer)
	local id = "chunk_name"
	local horizontal_sizer = EWS:BoxSizer("HORIZONTAL")

	sizer:add(horizontal_sizer, 0, 1, "EXPAND,LEFT")

	local options = {
		"default",
		"init"
	}
	local combobox_params = {
		name = "Chunk Name",
		sizer_proportions = 1,
		name_proportions = 1,
		tooltip = "Select an option from the combobox",
		sorted = false,
		ctrlr_proportions = 2,
		panel = panel,
		sizer = horizontal_sizer,
		options = options,
		value = self._settings.chunk_name or options[1]
	}
	local ctrlr = CoreEws.combobox(combobox_params)

	ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_set_data"), {
		ctrlr = ctrlr,
		value = id
	})

	self._settings_ctrlrs[id] = {
		type = "combobox",
		params = combobox_params,
		ctrlr = ctrlr,
		default = options[1]
	}
end

function LevelSettingsLayer:_set_data(data)
	self._settings[data.value] = data.ctrlr:get_value()
	self._settings[data.value] = tonumber(self._settings[data.value]) or self._settings[data.value]
end

function LevelSettingsLayer:add_triggers()
	LevelSettingsLayer.super.add_triggers(self)

	local vc = self._editor_data.virtual_controller
end

function LevelSettingsLayer:activate()
	LevelSettingsLayer.super.activate(self)
end

function LevelSettingsLayer:deactivate()
	LevelSettingsLayer.super.deactivate(self)
end

function LevelSettingsLayer:clear()
	LevelSettingsLayer.super.clear(self)

	for id, setting in pairs(self._settings_ctrlrs) do
		if setting.type == "combobox" then
			CoreEws.change_combobox_value(setting.params, setting.default)
		elseif setting.type == "checkbox" then
			setting.ctrlr:set_value(setting.default)
		end
	end

	self._settings = {}
end
