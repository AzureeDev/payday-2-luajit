core:module("CoreMissionLayer")
core:import("CoreStaticLayer")
core:import("CoreEditorSave")
core:import("CoreEditorUtils")
core:import("CoreTable")
core:import("CoreEws")
core:import("CoreClass")
core:import("CoreEditorCommand")

MissionLayer = MissionLayer or class(CoreStaticLayer.StaticLayer)

function MissionLayer:init(owner)
	local types = CoreEditorUtils.layer_type("mission") or {
		"mission_element"
	}

	MissionLayer.super.init(self, owner, "mission", types, "mission_elements")

	self._default_script_name = "default"
	self._editing_mission_element = false
	self._update_all = false
	self._simulate_with_current_script = false
	self._only_draw_selected_connections = true
	self._visualize_flow = false
	self._use_colored_links = true
	self._show_all_scripts = false
	self._name_brush = Draw:brush()

	self._name_brush:set_color(Color(1, 1, 1, 1))
	self._name_brush:set_font(Idstring("core/fonts/nice_editor_font"), 16)
	self._name_brush:set_render_template(Idstring("OverlayVertexColorTextured"))

	self._uses_continents = true
end

function MissionLayer:load(world_holder, offset)
	local data = world_holder:create_world("world", "mission_scripts", offset)
	self._scripts = data.scripts or self._scripts

	for name, values in pairs(self._scripts) do
		values.continent = values.continent or managers.editor:current_continent():name()
	end

	local world_units = MissionLayer.super.load(self, world_holder, offset)

	if world_units then
		for _, unit in ipairs(world_units) do
			unit:mission_element():layer_finished()

			unit:mission_element_data().script = unit:mission_element_data().script or self._default_script_name
		end
	end

	self:_populate_scripts_combobox()
	self:_set_scripts_combobox(self._default_script_name)
	self:_on_set_script()
end

function MissionLayer:save()
	for _, unit in ipairs(self._created_units) do
		local t = {
			entry = self._save_name,
			continent = unit:unit_data().continent and unit:unit_data().continent:name(),
			data = {
				unit_data = CoreEditorSave.save_data_table(unit),
				script = unit:mission_element_data().script,
				script_data = unit:mission_element():new_save_values()
			}
		}
		t.data.script_data.position = nil
		t.data.script_data.rotation = nil

		self:_add_project_unit_save_data(unit, t.data)
		unit:mission_element():add_to_mission_package()
		managers.editor:add_save_data(t)
	end

	for name, data in pairs(self._scripts) do
		local t = {
			entry = "mission_scripts",
			continent = data.continent,
			data = {
				[name] = data
			}
		}

		managers.editor:add_save_data(t)
	end
end

function MissionLayer:save_mission(params)
	local all_script_units = {}

	for _, unit in ipairs(self._created_units) do
		all_script_units[unit:mission_element_data().script] = all_script_units[unit:mission_element_data().script] or {}

		table.insert(all_script_units[unit:mission_element_data().script], unit)
	end

	local scripts = {}

	for script, _ in pairs(self._scripts) do
		local script_units = all_script_units[script] or {}

		if not params.name or params.name and self._scripts[script].continent == params.name then
			scripts[script] = {
				activate_on_parsed = self._scripts[script].activate_on_parsed
			}
			local elements = {}

			for _, unit in ipairs(script_units) do
				local t = {
					class = unit:mission_element_data().element_class,
					module = unit:mission_element_data().element_module,
					id = unit:unit_data().unit_id,
					editor_name = unit:unit_data().name_id,
					values = unit:mission_element():new_save_values()
				}

				table.insert(elements, t)
			end

			scripts[script].elements = elements
			scripts[script].instances = {}

			for _, instance in ipairs(managers.world_instance:instance_data()) do
				if instance.script == script then
					table.insert(scripts[script].instances, instance.name)
				end
			end
		end
	end

	return scripts
end

function MissionLayer:do_spawn_unit(...)
	if not self:current_script() then
		managers.editor:output_warning("You need to create a mission script first.")

		return
	end

	if self._scripts[self:current_script()].continent ~= managers.editor:current_continent():name() then
		managers.editor:output_warning("Can't create mission element because the current script doesn't belong to current continent.")

		return
	end

	return MissionLayer.super.do_spawn_unit(self, ...)
end

function MissionLayer:_on_unit_created(unit, ...)
	MissionLayer.super._on_unit_created(self, unit, ...)

	unit:mission_element_data().script = self:current_script()
end

function MissionLayer:condition()
	return MissionLayer.super.condition(self) or self._editing_mission_element
end

function MissionLayer:select_unit_ray_authorised(ray)
	return self:authorised_unit_type(ray.unit)
end

function MissionLayer:select_unit_authorised(unit)
	return unit and self:authorised_unit_type(ray.unit)
end

function MissionLayer:adding_to_mission()
	local vc = self._editor_data.virtual_controller

	return vc:down(Idstring("add_on_executed")) or vc:down(Idstring("add_trigger")) or vc:down(Idstring("remove_connection")) or vc:down(Idstring("select_action_with_unit"))
end

function MissionLayer:set_select_unit(unit, ...)
	if alive(unit) and unit:mission_element_data().script and unit:mission_element_data().script ~= self:current_script() then
		return
	end

	if not self:_add_on_executed(unit) then
		MissionLayer.super.set_select_unit(self, unit, ...)
	end

	if self._list_flow and self._list_flow:visible() then
		self._list_flow:on_unit_selected(self._selected_unit)
	end
end

function MissionLayer:_add_on_executed(unit)
	if not alive(unit) then
		if self:adding_to_mission() then
			return true
		end

		return false
	end

	if self._selected_unit and self:adding_to_mission() and unit ~= self._selected_unit then
		local vc = self._editor_data.virtual_controller

		if vc:down(Idstring("add_on_executed")) then
			self._selected_unit:mission_element():add_on_executed(unit)

			if self:shift() then
				for _, u in ipairs(self._selected_units) do
					if u ~= self._selected_unit and u ~= unit then
						u:mission_element():add_on_executed(unit)
					end
				end
			end

			return true
		end
	end

	return false
end

function MissionLayer:delete_selected_unit(btn, pressed)
	managers.editor:freeze_gui_lists()

	if self._selected_unit and not self:condition() then
		local to_delete = CoreTable.clone(self._selected_units)

		table.sort(to_delete, function (a, b)
			return b:unit_data().unit_id < a:unit_data().unit_id
		end)

		for _, unit in ipairs(to_delete) do
			unit:mission_element():delete_unit(self._created_units)
			unit:mission_element():clear()
		end

		for _, unit in ipairs(to_delete) do
			if table.contains(self._created_units, unit) then
				self:delete_unit(unit)
			else
				managers.editor:output_warning("" .. tostring(unit:unit_data().name_id) .. " belongs to " .. tostring(managers.editor:unit_in_layer_name(unit)) .. " and cannot be deleted from here.")
			end
		end
	end

	managers.editor:thaw_gui_lists()
end

function MissionLayer:delete_unit(del_unit, prevent_undo)
	if not self._editing_mission_element then
		MissionLayer.super.delete_unit(self, del_unit, prevent_undo)
	end

	if self._list_flow then
		self._list_flow:on_unit_selected(self._selected_unit)
	end
end

function MissionLayer:refresh_list_flow()
	if self._list_flow and self._list_flow:visible() then
		self._list_flow:on_unit_selected(self._selected_unit)
	end
end

function MissionLayer:clone_edited_values(unit, source)
	MissionLayer.super.clone_edited_values(self, unit, source)

	if unit:name():s() ~= source:name():s() then
		return
	end

	for name, value in pairs(source:mission_element_data()) do
		if CoreClass.type_name(value) == "table" then
			value = CoreTable.deep_clone(value)
		end

		unit:mission_element_data()[name] = value
	end

	unit:mission_element():clone_data(self:_units_as_pairs(self._created_units))
end

function MissionLayer:hide_all()
	for _, unit in ipairs(self._created_units) do
		if unit:mission_element_data().script == self:current_script() then
			managers.editor:set_unit_visible(unit, false)
		end
	end

	self:clear_selected_units()
	self:update_unit_settings()
end

function MissionLayer:set_enabled(enabled)
	self._layer_enabled = enabled

	for _, unit in ipairs(self._created_units) do
		if enabled then
			if unit:mission_element_data().script == self:current_script() then
				unit:mission_element():set_enabled()
				unit:set_enabled(true)
				unit:anim_play()
			end
		else
			unit:mission_element():set_disabled()
			unit:set_enabled(false)
		end
	end

	return true
end

function MissionLayer:widget_affect_object()
	local object = MissionLayer.super.widget_affect_object(self)

	if self._editing_mission_element and alive(self._selected_unit) then
		object = self._selected_unit:mission_element():widget_affect_object() or object
	end

	return object
end

function MissionLayer:use_widget_position(pos)
	if self._editing_mission_element and alive(self._selected_unit) and self._selected_unit:mission_element():use_widget_position(pos) then
		return
	end

	MissionLayer.super.use_widget_position(self, pos)
end

function MissionLayer:_units_as_pairs(units)
	local t = {}

	for _, unit in ipairs(units) do
		t[unit:unit_data().unit_id] = unit
	end

	return t
end

function MissionLayer:_on_reference_unit_unselected(unit)
	if alive(unit) and unit:mission_element().on_unselected ~= nil then
		unit:mission_element():on_unselected()
	end
end

function MissionLayer:update(time, rel_time)
	MissionLayer.super.update(self, time, rel_time)

	local update_selected_on_brush = Draw:brush()

	update_selected_on_brush:set_color(Color(0.25, 0, 0, 1))

	local unit_disabled = Draw:brush()

	unit_disabled:set_color(Color(0.15, 1, 0, 0))

	local all_units = self._created_units_pairs
	local current_continent_locked = managers.editor:continent(self._scripts[self:current_script()].continent):value("locked")
	local current_script = self:current_script()
	local cam_pos = managers.editor:camera():position()
	local cam_up = managers.editor:camera_rotation():z()
	local cam_right = managers.editor:camera_rotation():x()
	local lod_draw_distance = math.max(4000, 100000 - #self._created_units * 140)
	lod_draw_distance = lod_draw_distance * lod_draw_distance

	for _, unit in ipairs(self._created_units) do
		if unit:mission_element_data().script == current_script and not current_continent_locked or self._show_all_scripts then
			local distance = mvector3.distance_sq(unit:position(), cam_pos)
			unit:mission_element()._distance_to_camera = distance
			local update_selected_on = unit:mission_element():update_selected_on()

			if update_selected_on then
				update_selected_on_brush:unit(unit)
			end

			local update_selected = self._update_all or update_selected_on
			local selected_unit = unit == self._selected_unit

			if update_selected or selected_unit then
				unit:mission_element():update_selected(time, rel_time, self._only_draw_selected_connections and self._selected_unit, all_units)
			elseif self._override_lod_draw or self._only_draw_selected_connections and alive(self._selected_unit) or distance < lod_draw_distance then
				unit:mission_element():update_unselected(time, rel_time, self._only_draw_selected_connections and self._selected_unit, all_units)

				if not self._only_draw_selected_connections or not self._selected_unit then
					unit:mission_element():draw_links_unselected(time, rel_time, self._only_draw_selected_connections and self._selected_unit, all_units)
				end
			end

			if self._override_lod_draw or self._only_draw_selected_connections and alive(self._selected_unit) or distance < lod_draw_distance then
				unit:mission_element():draw_links(time, rel_time, self._only_draw_selected_connections and self._selected_unit, all_units)
			end

			if selected_unit then
				unit:mission_element():draw_links_selected(time, rel_time, self._only_draw_selected_connections and self._selected_unit)

				if self._editing_mission_element then
					if unit:mission_element().base_update_editing then
						unit:mission_element():base_update_editing(time, rel_time, self._current_pos)
					end

					if unit:mission_element().update_editing then
						unit:mission_element():update_editing(time, rel_time, self._current_pos)
					end
				end
			end

			if not unit:mission_element_data().enabled then
				unit_disabled:unit(unit)
			end

			if distance < 2250000 then
				local a = distance < 1000000 and 1 or (2250000 - distance) / 250000 / 5
				local color = selected_unit and Color(a, 0, 1, 0) or Color(a, 1, 1, 1)

				self._name_brush:set_color(color)

				local offset = nil

				if unit:mission_element()._icon_ws then
					offset = cam_up * unit:bounding_sphere_radius()
				else
					offset = Vector3(0, 0, unit:bounding_sphere_radius())
				end

				self._name_brush:center_text(unit:position() + offset, utf8.from_latin1(unit:unit_data().name_id), cam_right, -cam_up)
			end
		end
	end

	if self._only_draw_selected_connections then
		for _, su in ipairs(self._selected_units) do
			su:mission_element():draw_link_on_executed(t, dt)
		end
	end
end

function MissionLayer:_cloning_done()
	if alive(self._selected_unit) then
		self._selected_unit:mission_element():destroy_panel()
		self:update_unit_settings()
	end
end

function MissionLayer:update_unit_settings()
	MissionLayer.super.update_unit_settings(self)
	self:set_current_panel_visible(false)
	self._element_toolbar:set_enabled(self._selected_unit and true or false)
	self._element_toolbar:set_tool_state("EDIT_ELEMENT", self._editing_mission_element)
	self._element_toolbar:set_tool_enabled("EDIT_ELEMENT", false)
	self._element_toolbar:set_tool_enabled("TEST_ELEMENT", false)
	self._element_toolbar:set_tool_enabled("STOP_ELEMENT", false)
	self._element_toolbar:set_tool_state("UPDATE_SELECTED_ON", self._selected_unit and self._selected_unit:mission_element():update_selected_on() or false)
	self._element_toolbar:set_tool_enabled("UPDATE_SELECTED_ON", self._selected_unit and true or false)
	self._element_toolbar:set_tool_enabled("TIMELINE", self._selected_unit and true or false)

	if self._selected_unit then
		self._current_panel = self._selected_unit:mission_element():panel()

		self._selected_unit:mission_element():selected()
		self:set_current_panel_visible(true)

		if self._selected_unit:mission_element().test_element then
			self._element_toolbar:set_tool_enabled("TEST_ELEMENT", true)
		end

		if self._selected_unit:mission_element().stop_test_element then
			self._element_toolbar:set_tool_enabled("STOP_ELEMENT", true)
		end

		if self._selected_unit:mission_element():can_edit() then
			self._element_toolbar:set_tool_enabled("EDIT_ELEMENT", true)
		end
	end

	self:do_layout()
end

function MissionLayer:set_current_panel_visible(visible)
	if self._current_panel and (not self._current_panel:extension() or self._current_panel:extension() and self._current_panel:extension().alive) then
		self._current_panel:set_visible(visible)
	end
end

function MissionLayer:show_timeline()
	if self:ctrl() then
		return
	end

	if self._selected_unit then
		self._selected_unit:mission_element():on_timeline()
	end
end

function MissionLayer:test_element()
	self._selected_unit:mission_element():test_element()
end

function MissionLayer:stop_test_element()
	self._selected_unit:mission_element():stop_test_element()
end

function MissionLayer:toggle_update_selected_on()
	self._selected_unit:mission_element():set_update_selected_on(self._element_toolbar:tool_state("UPDATE_SELECTED_ON"))
end

function MissionLayer:_on_gui_mission_element_help()
	local short_name = self:_stripped_unit_name(self._selected_unit:name():s())

	EWS:launch_url("https://confluence.starbreeze.com/display/PD2/" .. short_name)
end

function MissionLayer:toolbar_toggle(data, event)
	CoreEditorUtils.toolbar_toggle(data, event)

	if data.value == "_editing_mission_element" then
		if self[data.value] then
			self._selected_unit:mission_element():begin_editing()
		else
			self._selected_unit:mission_element():end_editing()
		end
	end
end

function MissionLayer:toolbar_toggle_trg(data)
	if data.value == "_editing_mission_element" and (not alive(self._selected_unit) or not self._selected_unit:mission_element():can_edit()) then
		return
	end

	CoreEditorUtils.toolbar_toggle_trg(data)

	if data.value == "_editing_mission_element" then
		if self[data.value] then
			self._selected_unit:mission_element():begin_editing()
		else
			self._selected_unit:mission_element():end_editing()
		end

		self:clear_triggers()
		self:add_triggers()
	end
end

function MissionLayer:missionelement_panel()
	return self._missionelement_panel
end

function MissionLayer:missionelement_sizer()
	return self._missionelement_sizer
end

function MissionLayer:do_layout()
	self._missionelement_panel:layout()
	self._ews_panel:refresh()
end

function MissionLayer:build_panel(notebook)
	MissionLayer.super.build_panel(self, notebook, {
		units_noteboook_proportion = 0,
		units_notebook_min_size = Vector3(-1, 320, 0)
	})
	cat_print("editor", "MissionLayer:build_panel")
	self:_build_scripts()

	local btn_sizer = EWS:BoxSizer("HORIZONTAL")
	self._element_toolbar = EWS:ToolBar(self._ews_panel, "", "TB_FLAT,TB_NODIVIDER")

	self._element_toolbar:add_check_tool("EDIT_ELEMENT", "Edit Element [insert]", CoreEws.image_path("world_editor\\he_edit_element_16x16.png"), "Edit Element [insert]")
	self._element_toolbar:set_tool_state("EDIT_ELEMENT", self._editing_mission_element)
	self._element_toolbar:connect("EDIT_ELEMENT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "toolbar_toggle"), {
		value = "_editing_mission_element",
		toolbar = "_element_toolbar",
		class = self
	})

	self._ews_triggers.insert = callback(self, self, "toolbar_toggle_trg", {
		value = "_editing_mission_element",
		toolbar = "_element_toolbar",
		id = "EDIT_ELEMENT",
		class = self
	})

	self._element_toolbar:add_tool("TIMELINE", "Timeline", CoreEws.image_path("world_editor\\he_timeline_16x16.png"), "Timeline")
	self._element_toolbar:connect("TIMELINE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "show_timeline"), nil)
	self._element_toolbar:add_tool("TEST_ELEMENT", "Test element", CoreEws.image_path("world_editor\\he_test_element_16x16.png"), "Test Element")
	self._element_toolbar:connect("TEST_ELEMENT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "test_element"), nil)
	self._element_toolbar:add_tool("STOP_ELEMENT", "Stop element", CoreEws.image_path("world_editor\\he_stop_element_16x16.png"), "Stop Element")
	self._element_toolbar:connect("STOP_ELEMENT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "stop_test_element"), nil)
	self._element_toolbar:add_check_tool("UPDATE_SELECTED_ON", "Turns on/off update off drawing even if not selected", CoreEws.image_path("world_editor\\he_update_selected_on_16x16.png"), "Turns on/off update off drawing even if not selected")
	self._element_toolbar:connect("UPDATE_SELECTED_ON", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "toggle_update_selected_on"), nil)
	self._element_toolbar:add_separator()
	self._element_toolbar:add_tool("HELP", "Help", CoreEws.image_path("help_16x16.png"), nil)
	self._element_toolbar:connect("HELP", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_gui_mission_element_help"), nil)
	self._element_toolbar:realize()
	btn_sizer:add(self._element_toolbar, 1, 1, "EXPAND,BOTTOM")
	self._sizer:add(btn_sizer, 0, 0, "EXPAND")

	self._missionelement_panel = EWS:Panel(self._ews_panel, "", "TAB_TRAVERSAL")
	self._missionelement_sizer = EWS:BoxSizer("VERTICAL")

	self._missionelement_panel:set_sizer(self._missionelement_sizer)
	self._sizer:add(self._missionelement_panel, 1, 0, "EXPAND")

	return self._ews_panel
end

function MissionLayer:_build_scripts()
	local sizer = EWS:StaticBoxSizer(self._ews_panel, "HORIZONTAL", "Scripts")
	self._scripts_toolbar = EWS:ToolBar(self._ews_panel, "", "TB_FLAT,TB_NODIVIDER")

	self._scripts_toolbar:add_tool("CREATE_SCRIPT", "Create a new script", CoreEws.image_path("toolbar\\new_16x16.png"), "Create a new script")
	self._scripts_toolbar:connect("CREATE_SCRIPT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_create_script"), nil)
	self._scripts_toolbar:add_tool("DELETE_SCRIPT", "Delete current script", CoreEws.image_path("toolbar\\delete_16x16.png"), "Delete current script")
	self._scripts_toolbar:connect("DELETE_SCRIPT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_delete_script"), nil)
	self._scripts_toolbar:add_tool("RENAME_SCRIPT", "Rename current script", CoreEws.image_path("toolbar\\options_16x16.png"), "Rename current script")
	self._scripts_toolbar:connect("RENAME_SCRIPT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_rename_script"), nil)
	self._scripts_toolbar:add_separator()
	self._scripts_toolbar:add_check_tool("ACTIVATE_ON_PARSED", "Set if this mission should be activated on parsed", CoreEws.image_path("world_editor\\script_activate_on_parsed_16x16.png"), "Set if this mission should be activated on parsed")
	self._scripts_toolbar:set_tool_state("ACTIVATE_ON_PARSED", false)
	self._scripts_toolbar:connect("ACTIVATE_ON_PARSED", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_activate_on_parsed"), nil)
	self._scripts_toolbar:realize()
	sizer:add(self._scripts_toolbar, 0, 0, "EXPAND")

	self._scripts_combobox = EWS:ComboBox(self._ews_panel, "", "", "CB_DROPDOWN,CB_READONLY")

	self._scripts_combobox:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_on_set_script"), nil)
	sizer:add(self._scripts_combobox, 1, 0, "EXPAND")

	self._scripts_right_toolbar = EWS:ToolBar(self._ews_panel, "", "TB_FLAT,TB_NODIVIDER")

	self._scripts_right_toolbar:add_check_tool("SIMULATE_WITH_CURRENT_SCRIPT", "If used, run simulation will start the current script", CoreEws.image_path("world_editor\\script_simulate_with_current_16x16.png"), "If used, run simulation will start the current script")
	self._scripts_right_toolbar:set_tool_state("SIMULATE_WITH_CURRENT_SCRIPT", self._simulate_with_current_script)
	self._scripts_right_toolbar:connect("SIMULATE_WITH_CURRENT_SCRIPT", "EVT_COMMAND_MENU_SELECTED", callback(nil, CoreEditorUtils, "toolbar_toggle"), {
		value = "_simulate_with_current_script",
		toolbar = "_scripts_right_toolbar",
		class = self
	})
	self._scripts_right_toolbar:realize()
	sizer:add(self._scripts_right_toolbar, 0, 0, "EXPAND")
	self._sizer:add(sizer, 0, 0, "EXPAND")
end

function MissionLayer:add_btns_to_toolbar(...)
	MissionLayer.super.add_btns_to_toolbar(self, ...)
	self._btn_toolbar:add_separator()
	self._btn_toolbar:add_check_tool("DRAW_SELECTED_CONNECTIONS_ONLY", "Only draw selected connections", CoreEws.image_path("world_editor\\layer_hubs_only_draw_selected.png"), "Only draw selected connections")
	self._btn_toolbar:set_tool_state("DRAW_SELECTED_CONNECTIONS_ONLY", self._only_draw_selected_connections)
	self._btn_toolbar:connect("DRAW_SELECTED_CONNECTIONS_ONLY", "EVT_COMMAND_MENU_SELECTED", callback(nil, CoreEditorUtils, "toolbar_toggle"), {
		value = "_only_draw_selected_connections",
		toolbar = "_btn_toolbar",
		class = self
	})
	self._btn_toolbar:add_check_tool("UPDATE_SELECTED_ALL", "Draws all element as if they where selected", CoreEws.image_path("world_editor\\layer_hubs_update_selected_all.png"), "Draws all element as if they where selected")
	self._btn_toolbar:set_tool_state("UPDATE_SELECTED_ALL", self._update_all)
	self._btn_toolbar:connect("UPDATE_SELECTED_ALL", "EVT_COMMAND_MENU_SELECTED", callback(nil, CoreEditorUtils, "toolbar_toggle"), {
		value = "_update_all",
		toolbar = "_btn_toolbar",
		class = self
	})
	self._btn_toolbar:add_check_tool("PERSISTENT_DEBUG", "Turns on screen debug information on/off", CoreEws.image_path("world_editor\\mission_persistent_debug_16x16.png"), "Turns on screen debug information on/off")
	self._btn_toolbar:set_tool_state("PERSISTENT_DEBUG", managers.mission:persistent_debug_enabled())
	self._btn_toolbar:connect("PERSISTENT_DEBUG", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "toggle_persistent_debug"), {
		toolbar = "_btn_toolbar"
	})
	self._btn_toolbar:add_check_tool("VISUALIZE_FLOW", "Visualize flow", CoreEws.image_path("toolbar\\find_16x16.png"), "Visualize flow")
	self._btn_toolbar:set_tool_state("VISUALIZE_FLOW", self._visualize_flow)
	self._btn_toolbar:connect("VISUALIZE_FLOW", "EVT_COMMAND_MENU_SELECTED", callback(nil, CoreEditorUtils, "toolbar_toggle"), {
		value = "_visualize_flow",
		toolbar = "_btn_toolbar",
		class = self
	})
	self._btn_toolbar:add_check_tool("USE_COLORED_LINKS", "Use colored links", CoreEws.image_path("toolbar\\color_16x16.png"), "Use colored links")
	self._btn_toolbar:set_tool_state("USE_COLORED_LINKS", self._use_colored_links)
	self._btn_toolbar:connect("USE_COLORED_LINKS", "EVT_COMMAND_MENU_SELECTED", callback(nil, CoreEditorUtils, "toolbar_toggle"), {
		value = "_use_colored_links",
		toolbar = "_btn_toolbar",
		class = self
	})
	self._btn_toolbar:add_separator()
	self._btn_toolbar:add_tool("SHOW_LIST_FLOW", "Opens mission flow dialog", CoreEws.image_path("world_editor\\he_timeline_16x16.png"), "Opens mission flow dialog")
	self._btn_toolbar:connect("SHOW_LIST_FLOW", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_show_list_flow"), {})
end

function MissionLayer:toggle_persistent_debug(params)
	managers.mission:set_persistent_debug_enabled(self._btn_toolbar:tool_state("PERSISTENT_DEBUG"))
end

function MissionLayer:_show_list_flow()
	self._list_flow = self._list_flow or _G.MissionElementListFlow:new()

	if not self._list_flow:visible() then
		self._list_flow:set_visible(true)
	end

	self._list_flow:on_unit_selected(self._selected_unit)
end

function MissionLayer:_on_activate_on_parsed()
	self._scripts[self:current_script()].activate_on_parsed = self._scripts_toolbar:tool_state("ACTIVATE_ON_PARSED")
end

function MissionLayer:_on_create_script()
	local name = EWS:get_text_from_user(Global.frame_panel, "Enter name for new script:", "Create new script", "", Vector3(-1, -1, 0), true)

	if name and name ~= "" then
		if self._scripts[name] then
			self:_on_create_script()
		else
			self:_create_script(name)
		end
	end
end

function MissionLayer:_on_set_script()
	if not self:current_script() then
		return
	end

	if managers.editor:continent(self._scripts[self:current_script()].continent):value("locked") then
		return
	end

	self:clear_selected_units()
	self:set_show_all_scripts(self._show_all_scripts)
	self:_set_toolbar_settings()
end

function MissionLayer:_populate_scripts_combobox()
	self._scripts_combobox:clear()

	for name, _ in pairs(self._scripts) do
		self._scripts_combobox:append(name)
	end
end

function MissionLayer:_clear_scripts_combobox()
	self._scripts_combobox:clear()
end

function MissionLayer:_append_scripts_combobox(name)
	self._scripts_combobox:append(name)
end

function MissionLayer:_set_scripts_combobox(name)
	name = self._scripts[name] and name
	name = name or self:_get_script_combobox_name(true)
	name = name or self:_get_script_combobox_name()

	self._scripts_combobox:set_value(name)
end

function MissionLayer:_get_script_combobox_name(continent)
	for name, script in pairs(self._scripts) do
		if not continent or script.continent == managers.editor:current_continent():name() then
			return name
		end
	end
end

function MissionLayer:_set_toolbar_settings()
	local script = self._scripts[self:current_script()]

	self._scripts_toolbar:set_tool_state("ACTIVATE_ON_PARSED", script.activate_on_parsed)
end

function MissionLayer:current_script()
	if self._scripts_combobox:get_value() ~= "" then
		return self._scripts_combobox:get_value()
	else
		return nil
	end
end

function MissionLayer:scripts_by_continent(continent)
	local scripts = {}

	for name, script in pairs(self._scripts) do
		if script.continent == continent then
			table.insert(scripts, name)
		end
	end

	return scripts
end

function MissionLayer:_reset_scripts()
	self:_clear_scripts_combobox()

	self._scripts = {}

	self:_create_script(self._default_script_name, {
		activate_on_parsed = true
	})
end

function MissionLayer:_create_script(name, values)
	if not name then
		return
	end

	values = values or {}
	values.activate_on_parsed = values.activate_on_parsed or values.activate_on_parsed == nil and false
	values.continent = managers.editor:current_continent():name()
	self._scripts[name] = values

	self:_append_scripts_combobox(name)
	self:_set_scripts_combobox(name)
	self:_on_set_script()
end

function MissionLayer:set_script(name)
	self:_set_scripts_combobox(name)
	self:_on_set_script()
end

function MissionLayer:_on_delete_script()
	if not self:current_script() then
		return
	end

	local confirm = EWS:message_box(Global.frame_panel, "Delete script " .. self:current_script() .. "? All units(elements) in the script will be deleted.", "Mission", "YES_NO,ICON_QUESTION", Vector3(-1, -1, 0))

	if confirm == "NO" then
		return
	end

	self:_delete_script(self:current_script())
end

function MissionLayer:_delete_script(name)
	if self._scripts[name].continent ~= managers.editor:current_continent():name() then
		EWS:message_box(Global.frame_panel, "Can't delete script " .. name .. ", it does not belong to current continent.", "Mission", "CANCEL,ICON_ERROR", Vector3(-1, -1, 0))

		return
	end

	for _, unit in ipairs(CoreTable.clone(self._created_units)) do
		if unit:mission_element_data().script == name then
			self:delete_unit(unit)
		end
	end

	self._scripts[name] = nil

	self:_populate_scripts_combobox()
	self:_set_scripts_combobox()
	self:_on_set_script()
end

function MissionLayer:_on_rename_script()
	if not self:current_script() then
		return
	end

	local name = self:current_script()

	if self._scripts[name].continent ~= managers.editor:current_continent():name() then
		EWS:message_box(Global.frame_panel, "Can't rename script " .. name .. ", it does not belong to current continent.", "Mission", "CANCEL,ICON_ERROR", Vector3(-1, -1, 0))

		return
	end

	local new_name = EWS:get_text_from_user(Global.frame_panel, "Enter new name for script " .. name .. ":", "Rename script", "", Vector3(-1, -1, 0), true)

	if new_name and new_name ~= "" then
		if self._scripts[new_name] then
			self:_on_rename_script()
		else
			self:_rename_script(name, new_name)
		end
	end
end

function MissionLayer:_rename_script(name, new_name)
	for _, unit in ipairs(self._created_units) do
		if unit:mission_element_data().script == name then
			unit:mission_element_data().script = new_name
		end
	end

	local values = self._scripts[name]
	self._scripts[name] = nil
	self._scripts[new_name] = values

	self:_populate_scripts_combobox()
	self:_set_scripts_combobox(new_name)
	self:_on_set_script()
end

function MissionLayer:_set_script(name)
	if not self._scripts[name] then
		return
	end
end

function MissionLayer:_hide_all_scripts()
	for name, _ in pairs(self._scripts) do
		self:_hide_script(name)
	end
end

function MissionLayer:_show_all_mission_scripts()
	for name, _ in pairs(self._scripts) do
		self:_show_script(name)
	end
end

function MissionLayer:_hide_script(name)
	if not self._scripts[name] then
		return
	end

	for _, unit in ipairs(self._created_units) do
		if unit:mission_element_data().script == name then
			unit:set_enabled(false)
			unit:mission_element():set_disabled()
		end
	end
end

function MissionLayer:_show_script(name)
	if not self._scripts[name] then
		return
	end

	for _, unit in ipairs(self._created_units) do
		if unit:mission_element_data().script == name then
			unit:mission_element():set_enabled()
			unit:set_enabled(true)
			unit:anim_play()
		end
	end
end

function MissionLayer:script_names()
	local names = {}

	for name, _ in pairs(self._scripts) do
		table.insert(names, name)
	end

	return names
end

function MissionLayer:set_show_all_scripts(show_all_scripts)
	self._show_all_scripts = show_all_scripts

	if self._show_all_scripts then
		self:_show_all_mission_scripts()
	else
		self:_hide_all_scripts()
		self:_show_script(self:current_script())
	end
end

function MissionLayer:show_all_scripts(show_all_scripts)
	return self._show_all_scripts
end

function MissionLayer:set_iconsize(size)
	Global.iconsize = size

	for _, unit in ipairs(self._created_units) do
		unit:mission_element():set_iconsize(size)
	end
end

function MissionLayer:visualize_flow()
	return self._visualize_flow
end

function MissionLayer:use_colored_links()
	return self._use_colored_links
end

function MissionLayer:clear()
	for _, unit in ipairs(self._created_units) do
		unit:mission_element():clear()
	end

	self._editing_mission_element = false

	MissionLayer.super.clear(self)
	self:_reset_scripts()
	self:update_unit_settings()

	if self._list_flow then
		self._list_flow:on_unit_selected(nil)
	end
end

function MissionLayer:simulate_with_current_script()
	return self._simulate_with_current_script
end

function MissionLayer:get_unit_links(to_unit)
	local links = {
		executers = {},
		on_executed = {}
	}

	for _, unit in ipairs(self._created_units) do
		unit:mission_element():get_links_to_unit(to_unit, links, self._created_units_pairs)
	end

	return links
end

function MissionLayer:activate(...)
	MissionLayer.super.activate(self, ...)

	if self._list_flow then
		self._list_flow:set_visible(self._was_list_flow_visible)

		self._was_list_flow_visible = nil
	end
end

function MissionLayer:deactivate(...)
	MissionLayer.super.deactivate(self, ...)

	if self._list_flow then
		self._was_list_flow_visible = self._list_flow:visible()

		self._list_flow:set_visible(false)
	end
end

function MissionLayer:add_triggers()
	MissionLayer.super.add_triggers(self)

	local vc = self._editor_data.virtual_controller

	vc:add_trigger(Idstring("show_element_timeline"), callback(self, self, "show_timeline"))

	local vc = self._editor_data.virtual_controller

	if self._editing_mission_element and self._selected_unit then
		self._selected_unit:mission_element():base_add_triggers(vc)
		self._selected_unit:mission_element():add_triggers(vc)

		return
	end
end

function MissionLayer:break_links()
	managers.editor:freeze_gui_lists()

	if self._selected_unit and not self:condition() then
		local to_delete = CoreTable.clone(self._selected_units)

		table.sort(to_delete, function (a, b)
			return b:unit_data().unit_id < a:unit_data().unit_id
		end)

		for _, unit in ipairs(to_delete) do
			unit:mission_element():delete_unit(self._created_units)
			unit:mission_element():clear()
		end
	end

	managers.editor:thaw_gui_lists()
end
