core:module("CoreSoundLayer")
core:import("CoreStaticLayer")
core:import("CoreEws")
require("core/lib/units/data/CoreEditorSoundData")

SoundLayer = SoundLayer or class(CoreStaticLayer.StaticLayer)

function SoundLayer:init(owner)
	SoundLayer.super.init(self, owner, "sounds", {
		"sound"
	}, "sound_layer")

	self._muted = false
	self._environment_unit = "core/units/sound_environment/sound_environment"
	self._emitter_unit = "core/units/sound_emitter/sound_emitter"
	self._area_emitter_unit = "core/units/sound_area_emitter/sound_area_emitter"
	self._ignore_global_select = true
	self._position_as_slot_mask = self._position_as_slot_mask + managers.slot:get_mask("statics")
end

function SoundLayer:load(world_holder, offset)
	local sound = world_holder:create_world("world", self._save_name, offset)

	CoreEws.change_combobox_value(self._default_ambience, managers.sound_environment:default_ambience())
	CoreEws.change_combobox_value(self._default_environment, managers.sound_environment:default_environment())
	self._ambience_enabled:set_value(managers.sound_environment:ambience_enabled())
	CoreEws.change_combobox_value(self._default_occasional, managers.sound_environment:default_occasional())

	for _, area in ipairs(managers.sound_environment:areas()) do
		local unit = SoundLayer.super.do_spawn_unit(self, self._environment_unit, area:position(), area:rotation())

		if area:name() then
			self:set_name_id(unit, area:name())
		end

		unit:sound_data().environment_area = area

		unit:sound_data().environment_area:set_unit(unit)
	end

	for _, emitter in ipairs(managers.sound_environment:emitters()) do
		local unit = SoundLayer.super.do_spawn_unit(self, self._emitter_unit, emitter:position(), emitter:rotation())

		if emitter:name() then
			self:set_name_id(unit, emitter:name())
		end

		unit:sound_data().emitter = emitter

		unit:sound_data().emitter:set_unit(unit)
	end

	for _, emitter in ipairs(managers.sound_environment:area_emitters()) do
		local unit = SoundLayer.super.do_spawn_unit(self, self._area_emitter_unit, emitter:position(), emitter:rotation())

		if emitter:name() and emitter:name() ~= "" then
			self:set_name_id(unit, emitter:name())
		end

		unit:sound_data().emitter = emitter

		unit:sound_data().emitter:set_unit(unit)
	end

	self:set_select_unit(nil)
end

function SoundLayer:save(save_params)
	local file_name = "world_sounds"
	local t = {
		single_data_block = true,
		entry = self._save_name,
		data = {
			file = file_name
		}
	}

	managers.editor:add_save_data(t)

	local sound_environments = {}
	local sound_emitters = {}
	local sound_area_emitters = {}

	for _, unit in ipairs(self._created_units) do
		if unit:name() == Idstring(self._environment_unit) then
			local area = unit:sound_data().environment_area
			local shape_table = area:save_level_data()
			shape_table.environment = area:environment()
			shape_table.ambience_event = area:ambience_event()
			shape_table.occasional_event = area:occasional_event()
			shape_table.use_environment = area:use_environment()
			shape_table.use_ambience = area:use_ambience()
			shape_table.use_occasional = area:use_occasional()
			shape_table.name = area:name()

			table.insert(sound_environments, shape_table)
			managers.editor:add_to_sound_package({
				category = "soundbanks",
				name = managers.sound_environment:ambience_soundbank(area:ambience_event())
			})
		end

		if unit:name() == Idstring(self._emitter_unit) then
			local emitter = unit:sound_data().emitter

			table.insert(sound_emitters, {
				emitter_event = emitter:emitter_event(),
				position = emitter:position(),
				rotation = emitter:rotation(),
				name = emitter:name()
			})
			managers.editor:add_to_sound_package({
				category = "soundbanks",
				name = managers.sound_environment:emitter_soundbank(emitter:emitter_event())
			})
		end

		if unit:name() == Idstring(self._area_emitter_unit) then
			local area_emitter = unit:sound_data().emitter
			local shape_table = area_emitter:save_level_data()
			shape_table.name = area_emitter:name()

			table.insert(sound_area_emitters, shape_table)
			managers.editor:add_to_sound_package({
				category = "soundbanks",
				name = managers.sound_environment:emitter_soundbank(unit:sound_data().emitter:emitter_event())
			})
		end
	end

	local default_ambience = managers.sound_environment:default_ambience()
	local default_occasional = managers.sound_environment:default_occasional()
	local ambience_enabled = managers.sound_environment:ambience_enabled()
	local sound_data = {
		default_environment = managers.sound_environment:default_environment(),
		default_ambience = default_ambience,
		ambience_enabled = ambience_enabled,
		default_occasional = default_occasional,
		sound_environments = sound_environments,
		sound_emitters = sound_emitters,
		sound_area_emitters = sound_area_emitters
	}

	if ambience_enabled then
		managers.editor:add_to_sound_package({
			category = "soundbanks",
			name = managers.sound_environment:ambience_soundbank(default_ambience)
		})
		managers.editor:add_to_sound_package({
			category = "soundbanks",
			name = managers.sound_environment:occasional_soundbank(default_occasional)
		})
	end

	self:_add_project_save_data(sound_data)

	local path = save_params.dir .. "\\" .. file_name .. ".world_sounds"
	local file = managers.editor:_open_file(path)

	file:puts(ScriptSerializer:to_generic_xml(sound_data))
	SystemFS:close(file)
end

function SoundLayer:hide()
end

function SoundLayer:disable()
end

function SoundLayer:update(t, dt)
	SoundLayer.super.update(self, t, dt)

	for _, unit in ipairs(self._created_units) do
		if unit:name() == Idstring(self._emitter_unit) then
			local r = 0.6
			local g = 0.6
			local b = 0

			if table.contains(self._selected_units, unit) then
				b = 0.4
				g = 1
				r = 1
			end

			unit:sound_data().emitter:draw(t, dt, r, g, b)
		end

		if unit:name() == Idstring(self._environment_unit) then
			Application:draw(unit, 1, 1, 1)

			local r = 0
			local g = 0
			local b = 0.8

			if table.contains(self._selected_units, unit) then
				b = 1
				g = 0.4
				r = 0.4
			end

			unit:sound_data().environment_area:draw(t, dt, r, g, b)
		end

		if unit:name() == Idstring(self._area_emitter_unit) then
			Application:draw(unit, 1, 1, 1)

			local r = 0
			local g = 0
			local b = 0.8

			if table.contains(self._selected_units, unit) then
				b = 1
				g = 0.4
				r = 0.4
			end

			unit:sound_data().emitter:draw(t, dt, r, g, b)
		end
	end
end

function SoundLayer:build_panel(notebook)
	SoundLayer.super.build_panel(self, notebook)

	self._sound_panel = EWS:Panel(self._ews_panel, "", "TAB_TRAVERSAL")
	self._sound_sizer = EWS:BoxSizer("VERTICAL")

	self._sound_panel:set_sizer(self._sound_sizer)

	local cb_sizer = EWS:BoxSizer("HORIZONTAL")
	local show_sound = EWS:CheckBox(self._sound_panel, "Show Sound", "", "ALIGN_LEFT")

	show_sound:set_value(false)
	show_sound:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "toggle_show_sound"), show_sound)
	cb_sizer:add(show_sound, 1, 0, "EXPAND")

	local sound_always_on = EWS:CheckBox(self._sound_panel, "Sound Always On", "", "ALIGN_LEFT")

	sound_always_on:set_value(managers.editor:listener_always_enabled())
	sound_always_on:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "toggle_sound_always_on"), sound_always_on)
	cb_sizer:add(sound_always_on, 1, 0, "EXPAND")
	self._sound_sizer:add(cb_sizer, 0, 5, "ALIGN_LEFT,TOP,BOTTOM")

	local soundbank_sizer = EWS:StaticBoxSizer(self._sound_panel, "VERTICAL", "Defaults")

	self:_build_defaults(soundbank_sizer)
	self._sound_sizer:add(soundbank_sizer, 0, 0, "EXPAND")

	local h_sound_emitter_sizer = EWS:BoxSizer("HORIZONTAL")
	self._sound_emitter_sizer = EWS:StaticBoxSizer(self._sound_panel, "VERTICAL", "Sound Emitter")
	local default_emitter_path = managers.sound_environment:game_default_emitter_path()
	local emitter_paths = managers.sound_environment:emitter_paths()
	local ctrlr, combobox_params = CoreEws.combobox_and_list({
		name = "Categories",
		panel = self._sound_panel,
		sizer = self._sound_emitter_sizer,
		options = #emitter_paths > 0 and emitter_paths or {
			"- No emitter paths in project -"
		},
		value = #emitter_paths > 0 and default_emitter_path or "- No emitter paths in project -",
		value_changed_cb = function (params)
			self:select_emitter_path(params.value)
		end
	})
	self._emitter_path_combobox = combobox_params
	local ctrlr, combobox_params = CoreEws.combobox_and_list({
		sorted = true,
		name = "Events",
		panel = self._sound_panel,
		sizer = self._sound_emitter_sizer,
		options = default_emitter_path and managers.sound_environment:emitter_events(default_emitter_path) or {
			"- Talk to your sound designer -"
		},
		value = default_emitter_path and managers.sound_environment:emitter_events(default_emitter_path)[1] or "- Talk to your sound designer -",
		value_changed_cb = function (params)
			self:select_emitter_event(params.value)
		end
	})
	self._emitter_events_combobox = combobox_params

	h_sound_emitter_sizer:add(self._sound_emitter_sizer, 1, 0, "EXPAND")

	local restart_emitters = EWS:BitmapButton(self._sound_panel, CoreEws.image_path("toolbar\\refresh_16x16.png"), "", "NO_BORDER")

	restart_emitters:set_tool_tip("Restarts all emitters.")
	restart_emitters:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_restart_emitters"), nil)
	h_sound_emitter_sizer:add(restart_emitters, 0, 0, "EXPAND")
	self._sound_sizer:add(h_sound_emitter_sizer, 0, 0, "EXPAND")
	self:_build_environment()
	self._sizer:add(self._sound_panel, 2, 0, "EXPAND")

	return self._ews_panel
end

function SoundLayer:_build_defaults(sizer)
	self._default_environment = {
		sizer_proportions = 1,
		name = "Environment:",
		ctrlr_proportions = 3,
		name_proportions = 1,
		tooltip = "Select default environment from the combobox",
		sorted = true,
		panel = self._sound_panel,
		sizer = sizer,
		options = managers.sound_environment:environments(),
		value = managers.sound_environment:game_default_environment()
	}
	local environments = CoreEws.combobox(self._default_environment)

	environments:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "select_default_sound_environment"), nil)

	local no_ambiences_availible = #managers.sound_environment:ambience_events() == 0
	local error_text = "- No ambience soundbanks in project -"
	self._default_ambience = {
		sizer_proportions = 1,
		name = "Ambience:",
		ctrlr_proportions = 3,
		name_proportions = 1,
		tooltip = "Select default ambience from the combobox",
		sorted = true,
		panel = self._sound_panel,
		sizer = sizer,
		options = no_ambiences_availible and {
			error_text
		} or managers.sound_environment:ambience_events(),
		value = no_ambiences_availible and error_text or managers.sound_environment:game_default_ambience()
	}
	local ambiences = CoreEws.combobox(self._default_ambience)

	ambiences:set_enabled(not no_ambiences_availible)
	ambiences:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "select_default_ambience"), nil)

	local no_occasionals_availible = #managers.sound_environment:occasional_events() == 0
	local error_text = "- No occasional soundbanks in project -"
	self._default_occasional = {
		sizer_proportions = 1,
		name = "Occasional:",
		ctrlr_proportions = 3,
		name_proportions = 1,
		tooltip = "Select default occasional from the combobox",
		sorted = true,
		panel = self._sound_panel,
		sizer = sizer,
		options = no_occasionals_availible and {
			error_text
		} or managers.sound_environment:occasional_events(),
		value = no_occasionals_availible and error_text or managers.sound_environment:game_default_occasional()
	}
	local occasionals = CoreEws.combobox(self._default_occasional)

	occasionals:set_enabled(not no_occasionals_availible)
	occasionals:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "select_default_occasional"), nil)

	self._ambience_enabled = EWS:CheckBox(self._sound_panel, "Ambience Enabled", "")

	self._ambience_enabled:set_value(managers.sound_environment:ambience_enabled())
	sizer:add(self._ambience_enabled, 0, 5, "ALIGN_RIGHT,TOP")
	self._ambience_enabled:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_ambience_enabled"), self._ambience_enabled)
	self._ambience_enabled:set_enabled(not no_ambiences_availible)
end

function SoundLayer:_build_environment()
	local sound_environment_sizer = EWS:StaticBoxSizer(self._sound_panel, "VERTICAL", "Sound Environment")
	self._priority_params = {
		name_proportions = 1,
		name = "Priority:",
		ctrlr_proportions = 2,
		value = 9,
		tooltip = "DISABLED",
		min = 1,
		floats = 0,
		max = 9,
		panel = self._sound_panel,
		sizer = sound_environment_sizer
	}
	local priority = CoreEws.number_controller(self._priority_params)

	priority:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_environment_priority"), nil)
	priority:connect("EVT_KILL_FOCUS", callback(self, self, "set_environment_priority"), nil)

	local environment_sizer = EWS:BoxSizer("HORIZONTAL")
	self._effect_params = {
		sizer_proportions = 1,
		name = "Effect:",
		ctrlr_proportions = 2,
		name_proportions = 1,
		tooltip = "Select an environment effect from the combobox",
		sorted = true,
		panel = self._sound_panel,
		sizer = environment_sizer,
		options = managers.sound_environment:environments(),
		value = managers.sound_environment:game_default_environment()
	}
	local effects = CoreEws.combobox(self._effect_params)

	effects:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "select_sound_environment"), nil)

	self._use_environment = EWS:CheckBox(self._sound_panel, "", "", "ALIGN_LEFT")

	self._use_environment:set_value(true)
	self._use_environment:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "toggle_use_environment"), nil)
	environment_sizer:add(self._use_environment, 0, 0, "EXPAND")
	sound_environment_sizer:add(environment_sizer, 1, 0, "EXPAND")

	local ambience_sizer = EWS:BoxSizer("HORIZONTAL")
	self._ambience_params = {
		sizer_proportions = 1,
		name = "Ambience:",
		ctrlr_proportions = 2,
		name_proportions = 1,
		tooltip = "Select an ambience from the combobox",
		sorted = true,
		panel = self._sound_panel,
		sizer = ambience_sizer,
		options = managers.sound_environment:ambience_events(),
		value = managers.sound_environment:game_default_ambience()
	}
	local ambiences = CoreEws.combobox(self._ambience_params)

	ambiences:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "select_environment_ambience"), nil)

	self._use_ambience = EWS:CheckBox(self._sound_panel, "", "", "ALIGN_LEFT")

	self._use_ambience:set_value(true)
	self._use_ambience:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "toggle_use_ambience"), nil)
	ambience_sizer:add(self._use_ambience, 0, 0, "EXPAND")
	sound_environment_sizer:add(ambience_sizer, 1, 0, "EXPAND")

	local occasional_sizer = EWS:BoxSizer("HORIZONTAL")
	self._occasional_params = {
		sizer_proportions = 1,
		name = "Occasional:",
		ctrlr_proportions = 2,
		name_proportions = 1,
		tooltip = "Select an occasional from the combobox",
		sorted = true,
		panel = self._sound_panel,
		sizer = occasional_sizer,
		options = managers.sound_environment:occasional_events(),
		value = managers.sound_environment:game_default_occasional()
	}
	local occasionals = CoreEws.combobox(self._occasional_params)

	occasionals:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "select_environment_occasional"), nil)

	self._use_occasional = EWS:CheckBox(self._sound_panel, "", "", "ALIGN_LEFT")

	self._use_occasional:set_value(true)
	self._use_occasional:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "toggle_use_occasional"), nil)
	occasional_sizer:add(self._use_occasional, 0, 0, "EXPAND")
	sound_environment_sizer:add(occasional_sizer, 1, 0, "EXPAND")

	self._sound_environment_sizer = sound_environment_sizer

	self._sound_sizer:add(sound_environment_sizer, 0, 0, "EXPAND")
end

function SoundLayer:toggle_show_sound(show_sound)
	Application:console_command("set show_sound " .. tostring(show_sound:get_value()))
end

function SoundLayer:toggle_sound_always_on(sound_always_on)
	managers.editor:set_listener_always_enabled(sound_always_on:get_value())
end

function SoundLayer:select_default_ambience()
	managers.sound_environment:set_default_ambience(self._default_ambience.value)
end

function SoundLayer:select_default_occasional()
	managers.sound_environment:set_default_occasional(self._default_occasional.value)
end

function SoundLayer:set_ambience_enabled(ambience_enabled)
	managers.sound_environment:set_ambience_enabled(ambience_enabled:get_value())
end

function SoundLayer:select_default_sound_environment(environments)
	managers.sound_environment:set_default_environment(self._default_environment.value)
end

function SoundLayer:select_emitter_path(path)
	local emitter = self._selected_unit:sound_data().emitter

	emitter:set_emitter_path(path)
	self:set_sound_emitter_events(path)
	CoreEws.change_combobox_value(self._emitter_events_combobox, emitter:emitter_event())
end

function SoundLayer:set_sound_emitter_events(path)
	CoreEws.update_combobox_options(self._emitter_events_combobox, managers.sound_environment:emitter_events(path))
end

function SoundLayer:select_emitter_event(value)
	local emitter = self._selected_unit:sound_data().emitter

	emitter:set_emitter_event(value)
end

function SoundLayer:set_environment_priority()
	local area = self._selected_unit:sound_data().environment_area
end

function SoundLayer:select_sound_environment()
	local area = self._selected_unit:sound_data().environment_area

	area:set_environment(self._effect_params.value)
end

function SoundLayer:toggle_use_environment()
	local area = self._selected_unit:sound_data().environment_area

	area:set_use_environment(self._use_environment:get_value())
end

function SoundLayer:select_environment_ambience()
	local area = self._selected_unit:sound_data().environment_area

	area:set_environment_ambience(self._ambience_params.value)
end

function SoundLayer:toggle_use_ambience()
	local area = self._selected_unit:sound_data().environment_area

	area:set_use_ambience(self._use_ambience:get_value())
end

function SoundLayer:select_environment_occasional()
	local area = self._selected_unit:sound_data().environment_area

	area:set_environment_occasional(self._occasional_params.value)
end

function SoundLayer:toggle_use_occasional()
	local area = self._selected_unit:sound_data().environment_area

	area:set_use_occasional(self._use_occasional:get_value())
end

function SoundLayer:on_restart_emitters()
	for _, unit in ipairs(self._created_units) do
		if unit:name() == Idstring(self._emitter_unit) or unit:name() == Idstring(self._area_emitter_unit) then
			unit:sound_data().emitter:restart()
		end
	end
end

function SoundLayer:clear()
	managers.sound_environment:set_to_default()
	CoreEws.change_combobox_value(self._default_environment, managers.sound_environment:game_default_environment())
	CoreEws.change_combobox_value(self._default_ambience, managers.sound_environment:game_default_ambience())
	CoreEws.change_combobox_value(self._default_occasional, managers.sound_environment:game_default_occasional())
	self._ambience_enabled:set_value(managers.sound_environment:ambience_enabled())

	for _, unit in ipairs(self._created_units) do
		if unit:name() == Idstring(self._environment_unit) then
			managers.sound_environment:remove_area(unit:sound_data().environment_area)
		end

		if unit:name() == Idstring(self._emitter_unit) then
			managers.sound_environment:remove_emitter(unit:sound_data().emitter)
		end

		if unit:name() == Idstring(self._area_emitter_unit) then
			managers.sound_environment:remove_area_emitter(unit:sound_data().emitter)
		end
	end

	SoundLayer.super.clear(self)
	self:set_sound_environment_parameters()
end

function SoundLayer:do_spawn_unit(...)
	local unit = SoundLayer.super.do_spawn_unit(self, ...)

	if alive(unit) then
		if unit:name() == Idstring(self._emitter_unit) then
			if not unit:sound_data().emitter then
				unit:sound_data().emitter = managers.sound_environment:add_emitter({})

				unit:sound_data().emitter:set_unit(unit)
			end

			self:set_sound_emitter_parameters()
		elseif unit:name() == Idstring(self._area_emitter_unit) then
			if not unit:sound_data().emitter then
				unit:sound_data().emitter = managers.sound_environment:add_area_emitter({})

				unit:sound_data().emitter:set_unit(unit)

				self._current_shape_panel = unit:sound_data().emitter:panel(self._sound_panel, self._sound_emitter_sizer)

				self._sound_panel:layout()
			end

			self:set_sound_emitter_parameters()
		elseif unit:name() == Idstring(self._environment_unit) then
			if not unit:sound_data().environment_area then
				unit:sound_data().environment_area = managers.sound_environment:add_area({})

				unit:sound_data().environment_area:set_unit(unit)

				self._current_shape_panel = unit:sound_data().environment_area:panel(self._sound_panel, self._sound_environment_sizer)

				self._sound_panel:layout()
			end

			self:set_sound_environment_parameters()
		end
	end

	return unit
end

function SoundLayer:select_unit_ray_authorised(ray)
	local unit = ray and ray.unit

	if unit then
		return unit:name() == Idstring(self._emitter_unit) or unit:name() == Idstring(self._environment_unit) or unit:name() == Idstring(self._area_emitter_unit)
	end
end

function SoundLayer:clone_edited_values(unit, source)
	SoundLayer.super.clone_edited_values(self, unit, source)

	if unit:name() == Idstring(self._environment_unit) then
		local area = unit:sound_data().environment_area
		local source_area = source:sound_data().environment_area

		area:set_environment(source_area:environment())
		area:set_environment_ambience(source_area:ambience_event())
		area:set_width(source_area:width())
		area:set_depth(source_area:depth())
		area:set_height(source_area:height())
	end

	if unit:name() == Idstring(self._emitter_unit) or unit:name() == Idstring(self._area_emitter_unit) then
		local emitter = unit:sound_data().emitter
		local source_emitter = source:sound_data().emitter

		emitter:set_emitter_event(source_emitter:emitter_event())
	end
end

function SoundLayer:delete_unit(unit)
	if unit:name() == Idstring(self._environment_unit) then
		managers.sound_environment:remove_area(unit:sound_data().environment_area)

		if unit:sound_data().environment_area:panel() then
			if self._current_shape_panel == unit:sound_data().environment_area:panel() then
				self._current_shape_panel = nil
			end

			unit:sound_data().environment_area:panel():destroy()
			self._sound_panel:layout()
		end
	end

	if unit:name() == Idstring(self._emitter_unit) then
		managers.sound_environment:remove_emitter(unit:sound_data().emitter)
	end

	if unit:name() == Idstring(self._area_emitter_unit) then
		managers.sound_environment:remove_area_emitter(unit:sound_data().emitter)
	end

	SoundLayer.super.delete_unit(self, unit)
end

function SoundLayer:update_unit_settings()
	SoundLayer.super.update_unit_settings(self)

	if self._current_shape_panel then
		self._current_shape_panel:set_visible(false)
	end

	self:set_sound_emitter_parameters()
	self:set_sound_environment_parameters()
end

function SoundLayer:set_sound_environment_parameters()
	self._priority_params.number_ctrlr:set_enabled(false)
	self._effect_params.ctrlr:set_enabled(false)
	self._ambience_params.ctrlr:set_enabled(false)
	self._occasional_params.ctrlr:set_enabled(false)
	self._use_environment:set_enabled(false)
	self._use_ambience:set_enabled(false)
	self._use_occasional:set_enabled(false)

	if alive(self._selected_unit) and self._selected_unit:name() == Idstring(self._environment_unit) then
		local area = self._selected_unit:sound_data().environment_area

		if area then
			self._current_shape_panel = area:panel(self._sound_panel, self._sound_environment_sizer)

			self._current_shape_panel:set_visible(true)
			self._priority_params.number_ctrlr:set_enabled(false)
			self._effect_params.ctrlr:set_enabled(true)
			self._ambience_params.ctrlr:set_enabled(true)
			self._occasional_params.ctrlr:set_enabled(true)
			self._use_environment:set_enabled(true)
			self._use_ambience:set_enabled(true)
			self._use_occasional:set_enabled(true)
			CoreEws.change_combobox_value(self._effect_params, area:environment())
			CoreEws.change_combobox_value(self._ambience_params, area:ambience_event())
			CoreEws.change_combobox_value(self._occasional_params, area:occasional_event())
			self._use_environment:set_value(area:use_environment())
			self._use_ambience:set_value(area:use_ambience())
			self._use_occasional:set_value(area:use_occasional())
		end
	end

	self._sound_panel:layout()
end

function SoundLayer:set_sound_emitter_parameters()
	self._emitter_path_combobox.ctrlr:set_enabled(false)
	self._emitter_path_combobox.toolbar:set_enabled(false)
	self._emitter_events_combobox.ctrlr:set_enabled(false)
	self._emitter_events_combobox.toolbar:set_enabled(false)

	if alive(self._selected_unit) and (self._selected_unit:name() == Idstring(self._emitter_unit) or self._selected_unit:name() == Idstring(self._area_emitter_unit)) then
		local emitter = self._selected_unit:sound_data().emitter

		if emitter then
			self._emitter_path_combobox.ctrlr:set_enabled(true)
			self._emitter_path_combobox.toolbar:set_enabled(true)
			CoreEws.change_combobox_value(self._emitter_path_combobox, emitter:emitter_path())
			self._emitter_events_combobox.ctrlr:set_enabled(true)
			self._emitter_events_combobox.toolbar:set_enabled(true)
			CoreEws.change_combobox_value(self._emitter_events_combobox, emitter:emitter_event())
		end

		if self._selected_unit:name() == Idstring(self._area_emitter_unit) then
			local area = self._selected_unit:sound_data().emitter

			if area then
				self._current_shape_panel = area:panel(self._sound_panel, self._sound_emitter_sizer)

				self._current_shape_panel:set_visible(true)
			end
		end
	end
end

function SoundLayer:activate()
	SoundLayer.super.activate(self)
	managers.editor:set_listener_enabled(true)
	managers.editor:set_wanted_mute(false)
end

function SoundLayer:deactivate(params)
	managers.editor:set_listener_enabled(false)
	SoundLayer.super.deactivate(self)

	if not params or not params.simulation then
		managers.editor:set_wanted_mute(true)
	end
end

function SoundLayer:add_triggers()
	SoundLayer.super.add_triggers(self)
end

function SoundLayer:get_layer_name()
	return "Sound"
end

function SoundLayer:set_unit_name(units)
	SoundLayer.super.set_unit_name(self, units)

	if (self._unit_name == self._emitter_unit or self._unit_name == self._area_emitter_unit) and #managers.sound_environment:emitter_paths() == 0 then
		managers.editor:output("No emitter soundbanks in project. Talk to your sound designer.")
		units:set_item_selected(units:selected_item(), false)

		self._unit_name = ""
	end
end
