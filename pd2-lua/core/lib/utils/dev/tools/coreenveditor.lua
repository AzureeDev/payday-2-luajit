core:import("CoreClass")
core:import("CoreEvent")
core:import("CoreEws")
core:import("CoreColorPickerPanel")
require("core/lib/utils/dev/tools/CoreEnvEditorTabs")
require("core/lib/utils/dev/tools/CoreEnvEditorDialogs")
require("core/lib/utils/dev/tools/CoreEnvEditorFormulas")
require("core/lib/utils/dev/tools/CoreEnvEditorShadowTab")
require("core/lib/utils/dev/tools/CoreEnvEditorEffectsTab")

CoreEnvEditor = CoreEnvEditor or class()
CoreEnvEditor.TEMPLATE_IDENTIFIER = "template"
CoreEnvEditor.MIX_MUL = 200
CoreEnvEditor.REMOVE_DEPRECATED_DURING_LOAD = true

function CoreEnvEditor:init(env_file_name)
	managers.editor:enable_all_post_effects()

	self._env_path = assert(managers.viewport:first_active_viewport():get_environment_path()) or "core/environments/default"
	self._env_name = self._env_path

	self:read_mode()
	self:create_main_frame()

	self._value_is_changed = true
	self._undo_index = 0
	self._undo = {}
	self._template_environment_names = {}
	self._template_effects = {}
	self._template_underlays = {}
	self._template_skies = {}
	self._mixer_widgets = {}
	self._updators = {}
	self._tabs = {}
	self._posteffect = {}
	self._underlayeffect = {}
	self._sky = {}
	self._environment_effects = {}
	self._reported_data_path_map = {}

	if self._simple_mode then
		self:read_templates()
	end

	self:create_tab("Global illumination")
	self:create_tab("Skydome")
	self:create_tab("Global textures")

	if self._simple_mode then
		self:create_simple_interface()
	else
		self:create_interface()
	end

	self:build_tab("Global illumination")
	self:build_tab("Skydome")
	self:build_tab("Global textures")

	self._skies_to_remove = {}
	self._posteffects_to_remove = {}
	self._underlays_to_remove = {}
	self._environments_to_remove = {}

	self:init_shadow_tab()
	self:init_effects_tab()

	self._debug_draw = Global.render_debug.draw_enabled
	Global.render_debug.draw_enabled = true
	self._prev_environment = self._env_path

	self:database_load_env(self._env_path)
	managers.viewport:first_active_viewport():set_environment_editor_callback(callback(self, self, "feed"))
	self:check_news(true)
end

function CoreEnvEditor:read_mode()
end

function CoreEnvEditor:read_templates()
	for _, name in ipairs(managers.database:list_entries_of_type("environment")) do
		if string.find(name, self.TEMPLATE_IDENTIFIER) then
			table.insert(self._template_environment_names, name)
		end
	end

	table.sort(self._template_environment_names)

	for _, env_name in ipairs(self._template_environment_names) do
		self._template_effects[env_name] = DB:load_node("environment_effect", env_name)
		self._template_underlays[env_name] = DB:load_node("environment_underlay", env_name)
		self._template_skies[env_name] = DB:load_node("environment_sky", env_name)
	end
end

function CoreEnvEditor:on_check_news()
	self:check_news()
end

function CoreEnvEditor:reg_mixer(widget)
	table.insert(self._mixer_widgets, widget)
end

function CoreEnvEditor:update_mix(env1, env2, blend)
	for _, widget in ipairs(self._mixer_widgets) do
		widget:update_mix(env1, env2, blend)
	end
end

function CoreEnvEditor:check_news(new_only)
	local news = nil

	if new_only then
		news = managers.news:get_news("env_editor", self._main_frame)
	else
		news = managers.news:get_old_news("env_editor", self._main_frame)
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

function CoreEnvEditor:feed(handler, viewport, scene)
	for postprocessor_name, post_processor in pairs(self._posteffect.post_processors) do
		if postprocessor_name == "shadow_processor" then
			local shadow_param_map = {}

			self:shadow_feed_params(shadow_param_map)

			for kpar, vpar in pairs(shadow_param_map) do
				self:set_data_path("post_effect/" .. postprocessor_name .. "/shadow_rendering/shadow_modifier/" .. kpar, handler, vpar)
			end
		else
			for effect_name, effect in pairs(post_processor.effects) do
				for modifier_name, modifier in pairs(effect.modifiers) do
					for param_name, param in pairs(modifier.params) do
						self:set_data_path("post_effect/" .. postprocessor_name .. "/" .. effect_name .. "/" .. modifier_name .. "/" .. param_name, handler, param:get_value())
					end
				end
			end
		end
	end

	for kmat, vmat in pairs(self._underlayeffect.materials) do
		for kpar, vpar in pairs(vmat.params) do
			self:set_data_path("underlay_effect/" .. kmat .. "/" .. kpar, handler, vpar:get_value())
		end
	end

	for kpar, vpar in pairs(self._sky.params) do
		self:set_data_path("others/" .. kpar, handler, vpar:get_value())
	end
end

function CoreEnvEditor:set_data_path(data_path, handler, value)
	local data_path_key = Idstring(data_path):key()

	if not self._reported_data_path_map[data_path_key] and not handler:editor_set_value(data_path_key, value) then
		self._reported_data_path_map[data_path_key] = true

		Application:error("Data path is not supported: " .. data_path)
	end
end

function CoreEnvEditor:create_main_frame()
	self._main_frame = EWS:Frame("", Vector3(250, 0, 0), Vector3(450, 800, 0), "FRAME_FLOAT_ON_PARENT,DEFAULT_FRAME_STYLE", Global.frame)

	self:set_title()

	local main_box = EWS:BoxSizer("HORIZONTAL")
	local menu_bar = EWS:MenuBar()
	local file_menu = EWS:Menu("")

	file_menu:append_item("ENVOPEN", "Open...\tCtrl+O", "")
	file_menu:append_item("ENVSAVE", "Save \tCtrl+S", "")
	file_menu:append_item("ENVSAVEAS", "Save As.. \tCtrl+Alt+S", "")
	file_menu:append_separator()
	file_menu:append_item("ENCODE_PARAMETERS", "Encode Parameters", "")
	file_menu:append_separator()
	file_menu:append_item("NEWS", "Get Latest News", "")
	file_menu:append_separator()
	file_menu:append_item("EXIT", "Exit", "")
	menu_bar:append(file_menu, "File")

	local edit_menu = EWS:Menu("")

	edit_menu:append_item("UNDO", "Undo\tCtrl+Z", "")
	edit_menu:append_item("REDO", "Redo\tCtrl+Y", "")
	menu_bar:append(edit_menu, "Edit")
	self._main_frame:set_menu_bar(menu_bar)
	self._main_frame:connect("ENVOPEN", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_open_file"), "")
	self._main_frame:connect("ENVSAVE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_save_file"), "")
	self._main_frame:connect("ENVSAVEAS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_save_file_as"), "")
	self._main_frame:connect("ENCODE_PARAMETERS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_encode_parameters"), "")
	self._main_frame:connect("NEWS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_check_news"), "")
	self._main_frame:connect("EXIT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_close"), "")
	self._main_frame:connect("UNDO", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_undo"), "")
	self._main_frame:connect("REDO", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "on_redo"), "")
	self._main_frame:connect("", "EVT_CLOSE_WINDOW", callback(self, self, "on_close"), "")

	self._main_notebook = EWS:Notebook(self._main_frame, "", "")

	main_box:add(self._main_notebook, 1, 0, "EXPAND")

	self._connect_dialog = ConnectDialog:new(self._main_frame)
	self._encode_parameters_dialog = EWS:MessageDialog(self._main_frame, "This will encode all parameters to disk. Proceed?", "Encode Parameters", "YES_NO,ICON_QUESTION")

	self._main_frame:set_sizer(main_box)
	self._main_frame:set_visible(true)
end

function CoreEnvEditor:add_post_processors_param(pro, effect, mod, param, gui)
	if not self._posteffect.post_processors then
		self._posteffect.post_processors = {}
	end

	if not self._posteffect.post_processors[pro] then
		self._posteffect.post_processors[pro] = {}
	end

	if not self._posteffect.post_processors[pro].effects then
		self._posteffect.post_processors[pro].effects = {}
	end

	if not self._posteffect.post_processors[pro].effects[effect] then
		self._posteffect.post_processors[pro].effects[effect] = {}
	end

	if not self._posteffect.post_processors[pro].effects[effect].modifiers then
		self._posteffect.post_processors[pro].effects[effect].modifiers = {}
	end

	if not self._posteffect.post_processors[pro].effects[effect].modifiers[mod] then
		self._posteffect.post_processors[pro].effects[effect].modifiers[mod] = {}
	end

	if not self._posteffect.post_processors[pro].effects[effect].modifiers[mod].params then
		self._posteffect.post_processors[pro].effects[effect].modifiers[mod].params = {}
	end

	self._posteffect.post_processors[pro].effects[effect].modifiers[mod].params[param] = gui
	local processor = managers.viewport:first_active_viewport():vp():get_post_processor_effect("World", Idstring(pro))

	if processor then
		local key = Idstring("post_effect/" .. pro .. "/" .. effect .. "/" .. mod .. "/" .. param):key()
		local value = managers.viewport:first_active_viewport():get_environment_default_value(key)

		if value then
			gui:set_value(value)
		else
			local modifier = processor:modifier(Idstring(mod))

			if modifier and modifier:material():variable_exists(Idstring(param)) then
				local value = modifier:material():get_variable(Idstring(param))

				if value then
					gui:set_value(value)
				end
			end
		end
	end

	return gui
end

function CoreEnvEditor:add_underlay_param(mat, param, gui)
	if not self._underlayeffect.materials then
		self._underlayeffect.materials = {}
	end

	if not self._underlayeffect.materials[mat] then
		self._underlayeffect.materials[mat] = {}
	end

	if not self._underlayeffect.materials[mat].params then
		self._underlayeffect.materials[mat].params = {}
	end

	self._underlayeffect.materials[mat].params[param] = gui
	local material = Underlay:material(Idstring(mat))

	if material and material:variable_exists(Idstring(param)) then
		local value = material:get_variable(Idstring(param))

		if value then
			gui:set_value(value)
		end
	end

	return gui
end

function CoreEnvEditor:add_sky_param(param, gui)
	if not self._sky.params then
		self._sky.params = {}
	end

	self._sky.params[param] = gui

	return gui
end

function CoreEnvEditor:retrive_posteffect_param(node, pro, mod, param)
	for post_processor in node:children() do
		if post_processor:parameter("name") == pro then
			for modifier in post_processor:children() do
				if modifier:parameter("name") == mod then
					for parameter in modifier:children() do
						if parameter:parameter("key") == param then
							local p = parameter:parameter("value")

							if math.string_is_good_vector(p) then
								return math.string_to_vector(p)
							elseif tonumber(p) then
								return tonumber(p)
							else
								return p
							end
						end
					end
				end
			end
		end
	end
end

function CoreEnvEditor:retrive_underlay_param(node, mat, param)
	for material in node:children() do
		if material:parameter("name") == mat then
			for parameter in material:children() do
				if parameter:parameter("key") == param then
					local p = parameter:parameter("value")

					if math.string_is_good_vector(p) then
						return math.string_to_vector(p)
					elseif tonumber(p) then
						return tonumber(p)
					else
						return p
					end
				end
			end
		end
	end
end

function CoreEnvEditor:retrive_sky_param(node, param)
	for parameter in node:children() do
		if parameter:parameter("key") == param then
			local p = parameter:parameter("value")

			if math.string_is_good_vector(p) then
				return math.string_to_vector(p)
			elseif tonumber(p) then
				return tonumber(p)
			else
				return p
			end
		end
	end
end

function CoreEnvEditor:flipp(...)
	local v = {
		...
	}

	if #v > 1 then
		local a = v[#v]
		v[#v] = v[1]
		v[1] = a

		return unpack(v)
	else
		return ...
	end
end

function CoreEnvEditor:add_gui_element(gui, tab, ...)
	local list = {
		...
	}

	self:add_box(gui, self._tabs[tab], list, 1)
end

function CoreEnvEditor:create_tab(tab)
	if not self._tabs[tab] then
		self._tabs[tab] = {
			child = {},
			panel = EWS:Panel(self._main_notebook, "", ""),
			panel_box = EWS:BoxSizer("VERTICAL")
		}

		self._tabs[tab].panel:freeze()

		self._tabs[tab].scrolled_window = EWS:ScrolledWindow(self._tabs[tab].panel, "", "VSCROLL")

		self._tabs[tab].scrolled_window:set_scroll_rate(Vector3(0, 1, 0))
		self._tabs[tab].scrolled_window:set_virtual_size_hints(Vector3(0, 0, 0), Vector3(1, -1, -1))
		self._tabs[tab].scrolled_window:set_virtual_size(Vector3(200, 2000, 0))

		self._tabs[tab].box = EWS:BoxSizer("VERTICAL")
	end
end

function CoreEnvEditor:build_tab(tab)
	if self._tabs[tab] then
		self._tabs[tab].scrolled_window:set_sizer(self._tabs[tab].box)
		self._tabs[tab].panel_box:add(self._tabs[tab].scrolled_window, 1, 0, "EXPAND")
		self._tabs[tab].panel:set_sizer(self._tabs[tab].panel_box)
		self._main_notebook:add_page(self._tabs[tab].panel, tab, false)
		self._tabs[tab].panel:thaw()
		self._tabs[tab].panel:refresh()
	end
end

function CoreEnvEditor:get_tab(tab)
	if self._tabs[tab] then
		return self._tabs[tab].scrolled_window
	end
end

function CoreEnvEditor:add_box(gui, parent, list, index)
	local this = parent.child[list[index]]

	if not this then
		this = {
			child = {},
			box = EWS:StaticBoxSizer(parent.scrolled_window, "VERTICAL", list[index]),
			scrolled_window = parent.scrolled_window
		}

		parent.box:add(this.box, 0, 2, "ALL,EXPAND")

		parent.child[list[index]] = this
	end

	index = index + 1

	if list[index] then
		self:add_box(gui, this, list, index)
	else
		this.box:add(gui._box, 0, 2, "ALL,EXPAND")
	end
end

function CoreEnvEditor:set_title()
	self._main_frame:set_title(self._env_name .. " - Environment Editor")
end

function CoreEnvEditor:value_is_changed()
	self._value_is_changed = true
end

function CoreEnvEditor:add_updator(upd)
	table.insert(self._updators, upd)
end

function CoreEnvEditor:get_child(node, name)
	for child in node:children() do
		if child:name() == name then
			return child
		end
	end

	Application:error("Can't find child!")
end

function CoreEnvEditor:on_encode_parameters()
	local current_env = self._env_path

	if self._encode_parameters_dialog:show_modal() == "ID_YES" and managers and managers.environment then
		for _, env in ipairs(managers.database:list_entries_of_type("environment")) do
			self:database_load_env(env)
			self:write_to_disk(managers.database:entry_expanded_path("environment", self._env_path))
			self:set_title()
		end
	end

	self:database_load_env(current_env)
end

function CoreEnvEditor:write_to_disk(path, new_name)
	local file = SystemFS:open(path, "w")

	if file then
		file:print("<environment>\n")
		file:print("\t<metadata>\n")
		file:print("\t</metadata>\n")
		file:print("\t<data>\n")
		self:write_sky_orientation(file)
		self:write_sky(file)
		self:write_posteffect(file)
		self:write_underlayeffect(file)
		self:write_environment_effects(file)
		file:print("\t</data>\n")
		file:print("</environment>\n")
		file:close()
	end

	managers.viewport:editor_reload_environment(managers.database:entry_path(path))
end

function CoreEnvEditor:write_sky_orientation(file)
	file:print("\t\t<sky_orientation>\n")
	file:print("\t\t\t<param key=\"rotation\" value=\"0\" />\n")
	file:print("\t\t</sky_orientation>\n")
end

function CoreEnvEditor:write_posteffect(file)
	file:print("\t\t<post_effect>\n")

	for post_processor_name, post_processor in pairs(self._posteffect.post_processors) do
		if next(post_processor.effects) then
			file:print("\t\t\t<" .. post_processor_name .. ">\n")

			if post_processor_name == "shadow_processor" then
				self:write_shadow_params(file)
			else
				for effect_name, effect in pairs(post_processor.effects) do
					if next(effect.modifiers) then
						file:print("\t\t\t\t<" .. effect_name .. ">\n")

						for modifier_name, mod in pairs(effect.modifiers) do
							if next(mod.params) then
								file:print("\t\t\t\t\t<" .. modifier_name .. ">\n")

								for param_name, param in pairs(mod.params) do
									local v = param:get_value()

									if getmetatable(v) == _G.Vector3 then
										v = "" .. param:get_value().x .. " " .. param:get_value().y .. " " .. param:get_value().z
									else
										v = tostring(param:get_value())
									end

									file:print("\t\t\t\t\t\t<param key=\"" .. param_name .. "\" value=\"" .. v .. "\"/>\n")
								end

								file:print("\t\t\t\t\t</" .. modifier_name .. ">\n")
							end
						end

						file:print("\t\t\t\t</" .. effect_name .. ">\n")
					end
				end
			end

			file:print("\t\t\t</" .. post_processor_name .. ">\n")
		end
	end

	file:print("\t\t</post_effect>\n")
end

function CoreEnvEditor:write_environment_effects(file)
	file:print("\t\t<environment_effects>\n")

	local effects = ""

	for i, effect in ipairs(self._environment_effects) do
		if i > 1 then
			effects = effects .. ";"
		end

		effects = effects .. effect
	end

	file:print("\t\t\t<param key=\"effects\" value=\"" .. effects .. "\"/>\n")
	file:print("\t\t</environment_effects>\n")
end

function CoreEnvEditor:write_shadow_params(file)
	local params = self:shadow_feed_params({})

	file:print("\t\t\t\t<shadow_rendering>\n")
	file:print("\t\t\t\t\t<shadow_modifier>\n")

	for param_name, param in pairs(params) do
		local v = param

		if getmetatable(v) == _G.Vector3 then
			v = "" .. param.x .. " " .. param.y .. " " .. param.z
		else
			v = tostring(param)
		end

		file:print("\t\t\t\t\t\t<param key=\"" .. param_name .. "\" value=\"" .. v .. "\"/>\n")
	end

	file:print("\t\t\t\t\t</shadow_modifier>\n")
	file:print("\t\t\t\t</shadow_rendering>\n")
end

function CoreEnvEditor:write_underlayeffect(file)
	file:print("\t\t<underlay_effect>\n")

	for underlay_name, material in pairs(self._underlayeffect.materials) do
		if next(material.params) then
			file:print("\t\t\t<" .. underlay_name .. ">\n")

			for param_name, param in pairs(material.params) do
				local v = param:get_value()

				if getmetatable(v) == _G.Vector3 then
					v = "" .. param:get_value().x .. " " .. param:get_value().y .. " " .. param:get_value().z
				else
					v = tostring(param:get_value())
				end

				file:print("\t\t\t\t<param key=\"" .. param_name .. "\" value=\"" .. v .. "\"/>\n")
			end

			file:print("\t\t\t</" .. underlay_name .. ">\n")
		end
	end

	file:print("\t\t</underlay_effect>\n")
end

function CoreEnvEditor:write_sky(file)
	file:print("\t\t<others>\n")

	for param_name, param in pairs(self._sky.params) do
		local v = param:get_value()

		if getmetatable(v) == _G.Vector3 then
			v = "" .. param:get_value().x .. " " .. param:get_value().y .. " " .. param:get_value().z
		else
			v = tostring(param:get_value())
		end

		file:print("\t\t\t<param key=\"" .. param_name .. "\" value=\"" .. v .. "\"/>\n")
	end

	file:print("\t\t</others>\n")
end

function CoreEnvEditor:on_close()
	local close_dialog = EWS:MessageDialog(self._main_frame, "Do you want to save environment changes?", "Save Changes?", "YES_NO")

	if close_dialog:show_modal() == "ID_YES" then
		self:on_save_file()
	end

	managers.toolhub:close("Environment Editor")
end

function CoreEnvEditor:database_load_posteffect(post_effect_node)
	for post_processor in post_effect_node:children() do
		local post_pro = self._posteffect.post_processors[post_processor:name()]

		if not post_pro then
			self._posteffect.post_processors[post_processor:name()] = {}
			post_pro = self._posteffect.post_processors[post_processor:name()]
			post_pro.effects = {}
		end

		for effect in post_processor:children() do
			local eff = post_pro.effects[effect:name()]

			if not eff then
				post_pro.effects[effect:name()] = {}
				eff = post_pro.effects[effect:name()]
				eff.modifiers = {}
			end

			for modifier in effect:children() do
				local mod = eff.modifiers[modifier:name()]

				if not mod then
					eff.modifiers[modifier:name()] = {}
					mod = eff.modifiers[modifier:name()]
					mod.params = {}
				end

				for param in modifier:children() do
					if param:name() == "param" and param:parameter("key") and param:parameter("key") ~= "" and param:parameter("value") and param:parameter("value") ~= "" then
						local k = param:parameter("key")
						local l = string.len(k)
						local parameter = mod.params[k]
						local remove_param = false

						if not parameter then
							local data_path = "post_effect/" .. post_processor:name() .. "/" .. effect:name() .. "/" .. modifier:name() .. "/" .. k
							remove_param = not managers.viewport:has_data_path_key(Idstring(data_path):key())

							if not remove_param then
								Application:error("Editor doesn't handle value but should: " .. data_path)

								mod.params[k] = DummyWidget:new()
								parameter = mod.params[k]
							elseif managers.viewport:is_deprecated_data_path(data_path) then
								Application:error("Deprecated value will be removed next time you save: " .. data_path)
							else
								Application:stack_dump_error("Invalid value: " .. data_path)
							end
						end

						if not remove_param then
							local value = param:parameter("value")

							if math.string_is_good_vector(value) then
								parameter:set_value(math.string_to_vector(value))
							elseif tonumber(value) then
								parameter:set_value(tonumber(value))
							else
								parameter:set_value(tostring(value))
							end
						end
					end
				end
			end
		end
	end

	self:set_title()
end

function CoreEnvEditor:database_load_underlay(underlay_effect_node)
	if underlay_effect_node:name() == "underlay_effect" then
		for material in underlay_effect_node:children() do
			local mat = self._underlayeffect.materials[material:name()]

			if not mat then
				self._underlayeffect.materials[material:name()] = {}
				mat = self._underlayeffect.materials[material:name()]
				mat.params = {}
			end

			for param in material:children() do
				if param:name() == "param" and param:parameter("key") and param:parameter("key") ~= "" and param:parameter("value") and param:parameter("value") ~= "" then
					local k = param:parameter("key")
					local l = string.len(k)
					local parameter = mat.params[k]
					local remove_param = false

					if not parameter then
						local data_path = "underlay_effect/" .. material:name() .. "/" .. k
						remove_param = not managers.viewport:has_data_path_key(Idstring(data_path):key())

						if not remove_param then
							Application:error("Editor doesn't handle value but should: " .. data_path)

							mat.params[k] = DummyWidget:new()
							parameter = mat.params[k]
						elseif managers.viewport:is_deprecated_data_path(data_path) then
							Application:error("Deprecated value will be removed next time you save: " .. data_path)
						else
							Application:stack_dump_error("Invalid value: " .. data_path)
						end
					end

					if not remove_param then
						local value = param:parameter("value")

						if math.string_is_good_vector(value) then
							parameter:set_value(math.string_to_vector(value))
						elseif tonumber(value) then
							parameter:set_value(tonumber(value))
						else
							parameter:set_value(tostring(value))
						end
					end
				end
			end
		end
	else
		cat_print("debug", "[CoreEnvEditor] Failed to load underlay in: " .. self._env_path)
	end

	self:set_title()
end

function CoreEnvEditor:database_load_environment_effects(effect_node)
	for param in effect_node:children() do
		if param:name() == "param" and param:parameter("key") and param:parameter("key") ~= "" and param:parameter("value") and param:parameter("value") ~= "" and param:parameter("key") == "effects" then
			self._environment_effects = string.split(param:parameter("value"), ";")

			table.sort(self._environment_effects)
		end
	end

	self:set_title()
end

function CoreEnvEditor:database_load_sky(sky_node)
	if sky_node:name() == "others" then
		for param in sky_node:children() do
			if param:name() == "param" and param:parameter("key") and param:parameter("key") ~= "" and param:parameter("value") and param:parameter("value") ~= "" then
				local k = param:parameter("key")
				local l = string.len(k)
				local parameter = self._sky.params[k]
				local remove_param = false

				if not self._sky.params[k] then
					local data_path = "others/" .. k
					remove_param = not managers.viewport:has_data_path_key(Idstring(data_path):key())

					if not remove_param then
						Application:error("Editor doesn't handle value but should: " .. data_path)

						self._sky.params[k] = DummyWidget:new()
					elseif managers.viewport:is_deprecated_data_path(data_path) then
						Application:error("Deprecated value will be removed next time you save: " .. data_path)
					else
						Application:stack_dump_error("Invalid value: " .. data_path)
					end
				end

				if not remove_param then
					local value = param:parameter("value")

					if math.string_is_good_vector(value) then
						self._sky.params[param:parameter("key")]:set_value(math.string_to_vector(value))
					elseif tonumber(value) then
						self._sky.params[param:parameter("key")]:set_value(tonumber(value))
					else
						self._sky.params[param:parameter("key")]:set_value(value)
					end
				end
			end
		end
	else
		cat_print("debug", "[CoreEnvEditor] Failed to load sky in: " .. self._env_path)
	end

	self:set_title()
end

function CoreEnvEditor:database_load_env(env_path)
	local full_path = managers.database:entry_expanded_path("environment", env_path)
	local env = managers.database:has(full_path) and managers.database:load_node(full_path)

	if env then
		self._env_path = env_path
		self._env_name = managers.database:entry_name(env_path)

		if env:name() == "environment" then
			for param in env:child(1):children() do
				if param:name() == "others" then
					self:database_load_sky(param)
				elseif param:name() == "post_effect" then
					self:database_load_posteffect(param)
				elseif param:name() == "underlay_effect" then
					self:database_load_underlay(param)
				elseif param:name() == "environment_effects" then
					self:database_load_environment_effects(param)
				end
			end
		end
	end

	self:parse_shadow_data()
	self:set_effect_data(self._environment_effects)
	self:set_title()

	return env
end

function CoreEnvEditor:on_open_file()
	local path = managers.database:open_file_dialog(self._main_frame, "Environments (*.environment)|*.environment")

	if path then
		self:database_load_env(managers.database:entry_path(path))
	end
end

function CoreEnvEditor:on_save_file()
	self:write_to_disk(managers.database:base_path() .. string.gsub(self._env_path, "/", "\\") .. ".environment")
end

function CoreEnvEditor:on_save_file_as()
	local path = managers.database:save_file_dialog(self._main_frame, false, "Environments (*.environment)|*.environment")

	if path then
		self:write_to_disk(path, managers.database:entry_name(path))
		self:database_load_env(managers.database:entry_name(path))
	end
end

function CoreEnvEditor:on_manager_flush()
	if managers and managers.environment then
		managers.environment:flush()
	end
end

function CoreEnvEditor:destroy()
	if alive(self._main_frame) then
		self._main_frame:destroy()

		self._main_frame = nil
	end
end

function CoreEnvEditor:close()
	self._main_frame:destroy()

	Global.render_debug.draw_enabled = self._debug_draw

	if self._database_frame then
		self._database_frame:destroy()

		self._database_frame = nil
	end

	if self._environment_frame then
		self._environment_frame:destroy()

		self._environment_frame = nil
	end

	managers.viewport:first_active_viewport():set_environment_editor_callback(nil)
	managers.viewport:first_active_viewport():set_environment(managers.viewport:first_active_viewport():get_environment_path())
end

function CoreEnvEditor:set_position(newpos)
	self._main_frame:set_position(newpos)
end

function CoreEnvEditor:update(t, dt)
	self:sync()

	for _, upd in ipairs(self._updators) do
		upd:update(t, dt)
	end

	if EWS:get_key_state("K_SHIFT") then
		if self._update_pick_element and self._update_pick_element_type == "color" then
			local pixel = EWS:get_screen_pixel(EWS:get_screen_mouse_pos())
			local color = Vector3(pixel.x / 255, pixel.y / 255, pixel.z / 255)

			self._update_pick_element:set_value(color)
		elseif self._update_pick_element and self._update_pick_element_type == "depth" then
			self._update_pick_element:set_value(self:pick_depth())
		elseif self._update_pick_element and self._update_pick_element_type == "depth_x" then
			local old_val = self._update_pick_element:get_value()

			self._update_pick_element:set_value(Vector3(self:pick_depth(), old_val.y, old_val.z))
		elseif self._update_pick_element and self._update_pick_element_type == "depth_y" then
			local old_val = self._update_pick_element:get_value()

			self._update_pick_element:set_value(Vector3(old_val.x, self:pick_depth(), old_val.z))
		elseif self._update_pick_element and self._update_pick_element_type == "height" then
			self._update_pick_element:set_value(self:pick_height())
		elseif self._update_pick_element and self._update_pick_element_type == "height_x" then
			local old_val = self._update_pick_element:get_value()

			self._update_pick_element:set_value(Vector3(self:pick_height(), old_val.y, old_val.z))
		elseif self._update_pick_element and self._update_pick_element_type == "height_y" then
			local old_val = self._update_pick_element:get_value()

			self._update_pick_element:set_value(Vector3(old_val.x, self:pick_height(), old_val.z))
		end
	end

	if self._update_pick_element and self._update_pick_element_type ~= "color" then
		self:draw_cursor()
	end
end

function CoreEnvEditor:step()
	local undo = self._undo[self._undo_index]

	if undo._sky and self._sky then
		for key, value in pairs(undo._sky.params) do
			self._sky.params[key]:set_value(value)
		end
	end

	if undo._underlay and self._underlayeffect then
		for material, material_value in pairs(undo._underlay.materials) do
			for key, value in pairs(material_value.params) do
				self._underlayeffect.materials[material].params[key]:set_value(value)
			end
		end
	end

	if undo._posteffect and self._posteffect then
		for post_processor, post_processor_value in pairs(undo._posteffect.post_processors) do
			for modifier, modifier_value in pairs(post_processor_value.modifiers) do
				for key, value in pairs(modifier_value.params) do
					self._posteffect.post_processors[post_processor].modifiers[modifier].params[key]:set_value(value)
				end
			end
		end
	end
end

function CoreEnvEditor:on_undo()
	if self._undo_index > 1 then
		self._undo_index = self._undo_index - 1

		self:step()

		self._value_is_changed = false
	end
end

function CoreEnvEditor:on_redo()
	if self._undo_index <= self._max_undo_index then
		self._undo_index = self._undo_index + 1

		self:step()

		self._value_is_changed = false
	end
end

function CoreEnvEditor:get_cursor_look_point(camera, dist)
	local mouse_local = Vector3(0, 0, 0)
	local cursor_pos = Vector3(mouse_local.x / self._screen_borders.x * 2 - 1, mouse_local.y / self._screen_borders.y * 2 - 1, dist)

	return camera:screen_to_world(cursor_pos)
end

function CoreEnvEditor:draw_cursor()
	if managers.viewport and managers.viewport.get_current_camera then
		local camera = managers.viewport:get_current_camera()

		if alive(camera) then
			local pos = self:get_cursor_look_point(camera, 100)

			Application:draw_sphere(pos, 1, 1, 0, 0)
		end
	end
end

function CoreEnvEditor:pick_depth()
	if managers.viewport and managers.viewport.get_current_camera then
		local camera = managers.viewport:get_current_camera()

		if alive(camera) then
			local from = self:get_cursor_look_point(camera, 0)
			local to = self:get_cursor_look_point(camera, 1000000)
			local ray = World:raycast("ray", from, to)

			if ray then
				local pos = ray.position

				return math.clamp(camera:world_to_screen(pos).z, 0, camera:far_range())
			end
		end
	end

	return 0
end

function CoreEnvEditor:pick_height()
	if managers.viewport and managers.viewport.get_current_camera then
		local camera = managers.viewport:get_current_camera()

		if alive(camera) then
			local from = self:get_cursor_look_point(camera, 0)
			local to = self:get_cursor_look_point(camera, 1000000)
			local ray = World:raycast("ray", from, to)

			if ray then
				return ray.position.z
			end
		end
	end

	return 0
end

function CoreEnvEditor:sync()
	local undo_struct = {}

	if self._value_is_changed then
		self._max_undo_index = self._undo_index
		self._undo_index = self._undo_index + 1
		self._undo[self._undo_index] = undo_struct
		self._value_is_changed = false
	end
end

function CoreEnvEditor:value_database_lookup(str)
	local i = string.find(str, "#")
	local db_key = string.sub(str, 1, i - 1)
	local value_key = string.sub(str, i + 1)

	assert(db_key == "LightIntensityDB")

	local value = LightIntensityDB:lookup(value_key)

	assert(value)

	return value
end
