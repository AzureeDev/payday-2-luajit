core:import("CoreEngineAccess")

CoreEditorEwsDialog = CoreEditorEwsDialog or mixin(class(), BasicEventHandling)

function CoreEditorEwsDialog:init(parent, caption, id, position, size, style, settings)
	self._default_position = position
	self._default_size = size
	local pos = settings and settings.position or self._default_position
	local size = settings and settings.size or self._default_size
	self._dialog = EWS:Dialog(parent, caption, id, pos, size, style)

	self._dialog:set_icon(CoreEWS.image_path("world_editor_16x16.png"))

	self._dialog_sizer = EWS:BoxSizer("HORIZONTAL")

	self._dialog:set_sizer(self._dialog_sizer)
	self._dialog:connect("EVT_CLOSE_WINDOW", callback(self, self, "_evt_close_window"), nil)
end

function CoreEditorEwsDialog:_evt_close_window()
	self:on_cancel()
end

function CoreEditorEwsDialog:create_panel(orientation)
	self._panel = EWS:Panel(self._dialog, "", "TAB_TRAVERSAL")
	self._panel_sizer = EWS:BoxSizer(orientation)

	self._panel:set_sizer(self._panel_sizer)
end

function CoreEditorEwsDialog:update(t, dt)
end

function CoreEditorEwsDialog:dialog()
	return self._dialog
end

function CoreEditorEwsDialog:panel()
	return self._panel
end

function CoreEditorEwsDialog:set_visible(visible)
	self._dialog:set_visible(visible)
end

function CoreEditorEwsDialog:visible()
	return self._dialog:visible()
end

function CoreEditorEwsDialog:set_enabled(enabled)
	self._dialog:set_enabled(enabled)
end

function CoreEditorEwsDialog:enabled()
	return self._dialog:enabled()
end

function CoreEditorEwsDialog:show_modal()
	self._dialog:show_modal()
end

function CoreEditorEwsDialog:end_modal(code)
	self._dialog:end_modal(code)
end

function CoreEditorEwsDialog:size()
	return self._dialog:get_size()
end

function CoreEditorEwsDialog:set_size(size)
	self._dialog:set_size(size)
end

function CoreEditorEwsDialog:key_cancel(ctrlr, event)
	event:skip()

	if EWS:name_to_key_code("K_ESCAPE") == event:key_code() then
		self:on_cancel()
	end
end

function CoreEditorEwsDialog:on_cancel()
	self._dialog:set_visible(false)
end

function CoreEditorEwsDialog:position()
	return self._dialog:get_position()
end

function CoreEditorEwsDialog:set_position(pos)
	self._dialog:set_position(pos)
end

function CoreEditorEwsDialog:set_caption(caption)
	self._dialog:set_caption(caption)
end

function CoreEditorEwsDialog:reset()
end

function CoreEditorEwsDialog:recreate()
end

function CoreEditorEwsDialog:destroy()
	self._dialog:destroy()
end

UnitList = UnitList or class()

function UnitList:init()
	self._dialog = EWS:Dialog(nil, "Unit debug list", "", Vector3(100, 100, 0), Vector3(850, 600, 0), "DEFAULT_DIALOG_STYLE,RESIZE_BORDER")
	local dialog_sizer = EWS:BoxSizer("HORIZONTAL")

	self._dialog:set_sizer(dialog_sizer)

	local panel = EWS:Panel(self._dialog, "", "")
	self._panel = panel
	local panel_sizer = EWS:BoxSizer("VERTICAL")

	panel:set_sizer(panel_sizer)

	self._list = EWS:ListCtrl(panel, "", "LC_REPORT,LC_SORT_ASCENDING")

	self._list:clear_all()
	self._list:append_column("Name")
	self._list:append_column("Amount")
	self._list:append_column("Geometry Memory")
	self._list:append_column("Models")
	self._list:append_column("Bodies")
	self._list:append_column("Slot")
	self._list:append_column("Mass")
	self._list:append_column("Textures")
	self._list:append_column("Materials")
	self._list:append_column("Vertices/Triangles")
	self._list:append_column("Instanced")
	self._list:append_column("Author")
	self._list:append_column("Unit Filename")
	self._list:append_column("Object filename")
	self._list:append_column("Diesel Filename")
	self._list:append_column("Material Filename")
	self._list:append_column("Last Exported From")

	self._column_states = {}

	table.insert(self._column_states, {
		value = "name",
		state = "ascending"
	})
	table.insert(self._column_states, {
		value = "amount",
		state = "random"
	})
	table.insert(self._column_states, {
		value = "memory",
		state = "random"
	})
	table.insert(self._column_states, {
		value = "models",
		state = "random"
	})
	table.insert(self._column_states, {
		value = "nr_bodies",
		state = "random"
	})
	table.insert(self._column_states, {
		value = "slot",
		state = "random"
	})
	table.insert(self._column_states, {
		value = "mass",
		state = "random"
	})
	table.insert(self._column_states, {
		value = "nr_textures",
		state = "random"
	})
	table.insert(self._column_states, {
		value = "nr_materials",
		state = "random"
	})
	table.insert(self._column_states, {
		value = "vertices_per_tris",
		state = "random"
	})
	table.insert(self._column_states, {
		value = "instanced",
		state = "random"
	})
	table.insert(self._column_states, {
		value = "author",
		state = "random"
	})
	table.insert(self._column_states, {
		value = "unit_filename",
		state = "random"
	})
	table.insert(self._column_states, {
		value = "model_filename",
		state = "random"
	})
	table.insert(self._column_states, {
		value = "diesel_filename",
		state = "random"
	})
	table.insert(self._column_states, {
		value = "material_filename",
		state = "random"
	})
	table.insert(self._column_states, {
		value = "last_exported_from",
		state = "random"
	})
	panel_sizer:add(self._list, 2, 0, "EXPAND,TOP,BOTTOM")

	self._unit_list = EWS:ListCtrl(panel, "", "LC_REPORT,LC_SORT_ASCENDING")

	self._unit_list:clear_all()
	self._unit_list:append_column("Name ID")
	self._unit_list:append_column("Unit ID")
	self._list:connect("EVT_COMMAND_LIST_ITEM_SELECTED", callback(self, self, "on_select_unit_list"), nil)
	self._list:connect("EVT_COMMAND_LIST_ITEM_ACTIVATED", callback(self, self, "on_changed_layer"), nil)
	self._list:connect("EVT_COMMAND_LIST_COL_CLICK", callback(self, self, "column_click_list"), nil)
	self._list:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	self._unit_list:connect("EVT_COMMAND_LIST_ITEM_ACTIVATED", callback(self, self, "on_select_unit_list_unit"), nil)
	self._unit_list:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	self._unit_list:connect("EVT_KEY_DOWN", callback(self, self, "key_delete"), "")

	local bottom_sizer = EWS:BoxSizer("HORIZONTAL")

	bottom_sizer:add(self._unit_list, 7, 0, "EXPAND")

	local stats_sizer = EWS:BoxSizer("VERTICAL")
	local update_btn = EWS:Button(panel, "Update", "", "BU_BOTTOM")

	stats_sizer:add(update_btn, 0, 5, "EXPAND,LEFT,TOP")
	update_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "fill_unit_list"), "all")

	local update_btn = EWS:Button(panel, "Update Limited", "", "BU_BOTTOM")

	stats_sizer:add(update_btn, 0, 5, "EXPAND,LEFT,TOP")
	update_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "fill_unit_list"), "limited")

	local total_units_sizer = EWS:BoxSizer("HORIZONTAL")

	total_units_sizer:add(EWS:StaticText(panel, "Total units:", "", ""), 1, 0, "ALIGN_CENTER_VERTICAL")

	self._total_units = EWS:StaticText(panel, "0", "", "")

	total_units_sizer:add(self._total_units, 0, 0, "ALIGN_CENTER_VERTICAL")
	stats_sizer:add(total_units_sizer, 0, 5, "EXPAND,TOP,LEFT")

	local total_unique_units_sizer = EWS:BoxSizer("HORIZONTAL")

	total_unique_units_sizer:add(EWS:StaticText(panel, "Total unique units:", "", ""), 1, 0, "ALIGN_CENTER_VERTICAL")

	self._total_unique_units = EWS:StaticText(panel, "0", "", "")

	total_unique_units_sizer:add(self._total_unique_units, 0, 0, "ALIGN_CENTER_VERTICAL")
	stats_sizer:add(total_unique_units_sizer, 0, 5, "EXPAND,TOP,LEFT")

	local total_geometry_sizer = EWS:BoxSizer("HORIZONTAL")

	total_geometry_sizer:add(EWS:StaticText(panel, "Total geometry:", "", ""), 1, 0, "ALIGN_CENTER_VERTICAL")

	self._total_geometry = EWS:StaticText(panel, "0", "", "")

	total_geometry_sizer:add(self._total_geometry, 0, 0, "ALIGN_CENTER_VERTICAL")
	stats_sizer:add(total_geometry_sizer, 0, 5, "EXPAND,TOP,LEFT")
	bottom_sizer:add(stats_sizer, 2, 5, "EXPAND,RIGHT")
	panel_sizer:add(bottom_sizer, 1, 0, "EXPAND")

	local button_sizer = EWS:BoxSizer("HORIZONTAL")
	local delete_btn = EWS:Button(panel, "Delete", "", "BU_BOTTOM")

	button_sizer:add(delete_btn, 0, 2, "RIGHT,LEFT")
	delete_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_delete"), "")

	local cancel_btn = EWS:Button(panel, "Cancel", "", "")

	button_sizer:add(cancel_btn, 0, 2, "RIGHT,LEFT")
	cancel_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_cancel"), "")
	panel_sizer:add(button_sizer, 0, 0, "ALIGN_RIGHT")
	dialog_sizer:add(panel, 1, 0, "EXPAND")
	self:fill_unit_list("all")
	self._dialog:set_visible(true)
end

function UnitList:key_delete(ctrlr, event)
	event:skip()

	if EWS:name_to_key_code("K_DELETE") == event:key_code() then
		self:on_delete()
	end
end

function UnitList:key_cancel(ctrlr, event)
	event:skip()

	if EWS:name_to_key_code("K_ESCAPE") == event:key_code() then
		self:on_cancel()
	end
end

function UnitList:on_cancel()
	self._dialog:set_visible(false)
end

function UnitList:on_delete()
	managers.editor:freeze_gui_lists()

	for _, unit in ipairs(self:selected_item_units()) do
		managers.editor:delete_unit(unit)
	end

	managers.editor:thaw_gui_lists()
end

function UnitList:selected_item_units()
	local units = {}

	for _, i in ipairs(self._unit_list:selected_items()) do
		local unit = self._unit_list_units[self._unit_list:get_item_data(i)]

		table.insert(units, unit)
	end

	return units
end

function UnitList:column_click_list(data, event)
	local column = event:get_column() + 1
	local value = self._column_states[column].value
	local state = self._column_states[column].state

	for name, s in pairs(self._column_states) do
		s = "random"
	end

	if state == "random" then
		state = "ascending"
	elseif state == "ascending" then
		state = "descending"
	elseif state == "descending" then
		state = "ascending"
	end

	self._column_states[column].state = state
	local f = nil

	if state == "ascending" then
		function f(item1, item2)
			if item1[value] < item2[value] then
				return -1
			elseif item2[value] < item1[value] then
				return 1
			end

			return 0
		end
	else
		function f(item1, item2)
			if item2[value] < item1[value] then
				return -1
			elseif item1[value] < item2[value] then
				return 1
			end

			return 0
		end
	end

	self._list:sort(f)
end

function UnitList:on_changed_layer()
	local index = self._list:selected_item()

	if index ~= -1 then
		local unit_name = self._list:get_item(index, 0)
		local s = managers.editor:select_unit_name(unit_name)

		managers.editor:output(s)
	end
end

function UnitList:on_select_unit_list(ignore_unit)
	local list = self._list
	local unit_list = self._unit_list
	local index = list:selected_item()

	if index ~= -1 then
		local unit_name = list:get_item(index, 0)

		unit_list:delete_all_items()

		local units = World:find_units_quick("all")
		self._unit_list_units = {}
		local j = 1

		for _, unit in ipairs(units) do
			if unit:name():s() == unit_name and unit:unit_data() and (not ignore_unit or ignore_unit ~= unit) then
				local i = unit_list:append_item(unit:unit_data().name_id)

				unit_list:set_item(i, 1, unit:unit_data().unit_id)
				unit_list:set_item_data(i, j)

				self._unit_list_units[j] = unit
				j = j + 1
			end
		end

		if #self._unit_list_units == 0 then
			managers.editor:output_error("Unit " .. unit_name .. " is not placed by editor.")
		end

		for i = 0, unit_list:column_count() - 1 do
			unit_list:autosize_column(i)
		end
	else
		unit_list:delete_all_items()
	end
end

function UnitList:on_select_unit_list_unit()
	local list = self._list
	local unit_list = self._unit_list
	local index = unit_list:selected_item()
	local unit = self._unit_list_units[unit_list:get_item_data(index)]

	if not unit:unit_data().instance then
		managers.editor:select_unit(unit)
	end

	managers.editor:center_view_on_unit(unit)
end

function UnitList:reset()
	self:fill_unit_list("all")
	self._unit_list:delete_all_items()
end

function UnitList:deleted_unit(unit)
	self:freeze()

	local index = self._list:selected_item()

	for i = 0, self._list:item_count() - 1 do
		if self._list:get_item(i, 0) == unit:name():s() then
			local amount = self._list:get_item(i, 1) - 1

			self._list:set_item(i, 1, amount)

			if amount == 0 then
				self._list:delete_item(i)
			end

			if index ~= -1 and index == i then
				self:on_select_unit_list(unit)
			end

			self:thaw()

			return
		end
	end

	self:thaw()
end

function UnitList:spawned_unit(unit)
	self:freeze()

	local index = self._list:selected_item()

	for i = 0, self._list:item_count() - 1 do
		if self._list:get_item(i, 0) == unit:name():s() then
			local amount = self._list:get_item(i, 1) + 1

			self._list:set_item(i, 1, amount)

			if index ~= -1 and index == i then
				self:on_select_unit_list()
			end

			self:thaw()

			return
		end
	end

	local stats = managers.editor:get_unit_stat(unit)
	stats.amount = 1

	self:append_item(unit:name():s(), stats)
	self:_autosize_columns()
	self:thaw()
end

function UnitList:selected_unit(unit)
	for _, i in ipairs(self._list:selected_items()) do
		self._list:set_item_selected(i, false)
	end

	if not alive(unit) then
		return
	end

	for i = 0, self._list:item_count() - 1 do
		if self._list:get_item(i, 0) == unit:name():s() then
			self._list:set_item_selected(i, true)
			self._list:ensure_visible(i)

			for j = 0, self._unit_list:item_count() - 1 do
				if tonumber(self._unit_list:get_item(j, 1)) == unit:unit_data().unit_id then
					self._unit_list:set_item_selected(j, true)
					self._unit_list:ensure_visible(j)

					break
				end
			end

			return
		end
	end
end

function UnitList:unit_name_changed(unit)
	local index = self._list:selected_item()

	for i = 0, self._list:item_count() - 1 do
		if self._list:get_item(i, 0) == unit:name():s() then
			if index ~= -1 and index == i then
				self:on_select_unit_list()
			end

			return
		end
	end
end

function UnitList:fill_unit_list(type)
	self:freeze()

	local list = self._list

	list:delete_all_items()

	local data, total = nil

	if type == "limited" then
		data, total = managers.editor:get_unit_stats_from_layers()
	else
		data, total = managers.editor:get_unit_stats()
	end

	local unique = 0

	for name, t in pairs(data) do
		unique = unique + 1

		self:append_item(name, t)
	end

	self._total_units:set_value(total.amount)
	self._total_unique_units:set_value(unique)
	self._total_geometry:set_value(total.geometry_memory)
	self._panel:layout()
	self:_autosize_columns()
	self:thaw()
end

function UnitList:_autosize_columns()
	for i = 0, self._list:column_count() - 1 do
		self._list:autosize_column(i)
	end
end

function UnitList:append_item(name, t)
	local i = self._list:append_item(name)

	self._list:set_item(i, 1, t.amount)
	self._list:set_item(i, 2, t.memory)
	self._list:set_item(i, 3, t.models)
	self._list:set_item(i, 4, t.nr_bodies)
	self._list:set_item(i, 5, t.slot)
	self._list:set_item(i, 6, t.mass)
	self._list:set_item(i, 7, t.nr_textures)
	self._list:set_item(i, 8, t.nr_materials)
	self._list:set_item(i, 9, t.vertices_per_tris)
	self._list:set_item(i, 10, tostring(t.instanced))
	self._list:set_item(i, 11, utf8.to_lower(utf8.from_latin1(t.author)))
	self._list:set_item(i, 12, t.unit_filename)
	self._list:set_item(i, 13, t.model_filename)
	self._list:set_item(i, 14, t.diesel_filename)
	self._list:set_item(i, 15, t.material_filename)
	self._list:set_item(i, 16, utf8.to_lower(utf8.from_latin1(t.last_exported_from)))

	local new_t = clone(t)
	new_t.name = name
	new_t.instanced = tostring(new_t.instanced)

	self._list:set_item_data_ref(i, new_t)
end

function UnitList:set_visible(visible)
	self._dialog:set_visible(visible)
end

function UnitList:visible()
	self._dialog:visible()
end

function UnitList:freeze()
	self._list:freeze()
	self._unit_list:freeze()
end

function UnitList:thaw()
	self._unit_list:thaw()
	self._list:thaw()
end

UnitDuplicateIdList = UnitDuplicateIdList or class()

function UnitDuplicateIdList:init()
	self._dialog = EWS:Dialog(nil, "Unit duplicate ID list", "", Vector3(100, 100, 0), Vector3(850, 600, 0), "DEFAULT_DIALOG_STYLE,RESIZE_BORDER")
	local dialog_sizer = EWS:BoxSizer("HORIZONTAL")

	self._dialog:set_sizer(dialog_sizer)

	local panel = EWS:Panel(self._dialog, "", "")
	self._panel = panel
	local panel_sizer = EWS:BoxSizer("VERTICAL")

	panel:set_sizer(panel_sizer)

	self._list = EWS:ListCtrl(panel, "", "LC_REPORT,LC_SORT_ASCENDING")

	self._list:clear_all()
	self._list:append_column("ID")
	self._list:append_column("Duplicates")

	self._column_states = {}

	table.insert(self._column_states, {
		value = "id",
		state = "ascending"
	})
	table.insert(self._column_states, {
		value = "duplicates",
		state = "random"
	})
	panel_sizer:add(self._list, 2, 0, "EXPAND,TOP,BOTTOM")

	self._unit_list = EWS:ListCtrl(panel, "", "LC_REPORT,LC_SORT_ASCENDING")

	self._unit_list:clear_all()
	self._unit_list:connect("EVT_COMMAND_LIST_ITEM_ACTIVATED", callback(self, self, "on_select_unit_list_unit"), nil)
	self._unit_list:append_column("Name ID")
	self._list:connect("EVT_COMMAND_LIST_ITEM_SELECTED", callback(self, self, "on_select_unit_list"), nil)
	self._list:connect("EVT_COMMAND_LIST_COL_CLICK", callback(self, self, "column_click_list"), nil)
	self._list:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	self._unit_list:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local bottom_sizer = EWS:BoxSizer("HORIZONTAL")

	bottom_sizer:add(self._unit_list, 7, 0, "EXPAND")

	local stats_sizer = EWS:BoxSizer("VERTICAL")
	local update_btn = EWS:Button(panel, "Update", "", "BU_BOTTOM")

	stats_sizer:add(update_btn, 0, 5, "EXPAND,LEFT,TOP")
	update_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "fill_unit_list"), "all")
	bottom_sizer:add(stats_sizer, 2, 5, "EXPAND,RIGHT")
	panel_sizer:add(bottom_sizer, 1, 0, "EXPAND")

	local button_sizer = EWS:BoxSizer("HORIZONTAL")
	local cancel_btn = EWS:Button(panel, "Cancel", "", "")

	button_sizer:add(cancel_btn, 0, 2, "RIGHT,LEFT")
	cancel_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_cancel"), "")
	panel_sizer:add(button_sizer, 0, 0, "ALIGN_RIGHT")
	dialog_sizer:add(panel, 1, 0, "EXPAND")
	self:reset()
	self._dialog:set_visible(true)
end

function UnitDuplicateIdList:on_select_unit_list_unit()
	local list = self._list
	local unit_list = self._unit_list
	local index = unit_list:selected_item() + 1
	local unit = self._unit_list_units[index]

	if not unit:unit_data().instance then
		managers.editor:select_unit(unit)
	end

	managers.editor:center_view_on_unit(unit)
end

function UnitDuplicateIdList:key_cancel(ctrlr, event)
	event:skip()

	if EWS:name_to_key_code("K_ESCAPE") == event:key_code() then
		self:on_cancel()
	end
end

function UnitDuplicateIdList:on_cancel()
	self._dialog:set_visible(false)
end

function UnitDuplicateIdList:column_click_list(data, event)
	local column = event:get_column() + 1
	local value = self._column_states[column].value
	local state = self._column_states[column].state

	for name, s in pairs(self._column_states) do
		s = "random"
	end

	if state == "random" then
		state = "ascending"
	elseif state == "ascending" then
		state = "descending"
	elseif state == "descending" then
		state = "ascending"
	end

	self._column_states[column].state = state
	local f = nil

	if state == "ascending" then
		function f(item1, item2)
			if item1[value] < item2[value] then
				return -1
			elseif item2[value] < item1[value] then
				return 1
			end

			return 0
		end
	else
		function f(item1, item2)
			if item2[value] < item1[value] then
				return -1
			elseif item1[value] < item2[value] then
				return 1
			end

			return 0
		end
	end

	self._list:sort(f)
end

function UnitDuplicateIdList:on_select_unit_list(ignore_unit)
	local list = self._list
	local unit_list = self._unit_list
	local units = World:find_units_quick("all")
	local index = list:selected_item()

	unit_list:delete_all_items()

	if index ~= -1 then
		self._unit_list_units = {}
		local unit_id = list:get_item(index, 0)
		local j = 1

		for _, unit in pairs(units) do
			if unit:unit_data() and tostring(unit:unit_data().unit_id) == unit_id then
				local i = unit_list:append_item(unit:unit_data().name_id)
				self._unit_list_units[j] = unit
				j = j + 1
			end
		end
	end
end

function UnitDuplicateIdList:on_select_unit_id()
	local list = self._list
	local unit_list = self._unit_list
	local index = unit_list:selected_item()
	local unit = self._unit_list_units[unit_list:get_item_data(index)]

	if not unit:unit_data().instance then
		managers.editor:select_unit(unit)
	end

	managers.editor:center_view_on_unit(unit)
end

function UnitDuplicateIdList:reset()
	self._unit_list:delete_all_items()
	self:fill_unit_list("all")
end

function UnitDuplicateIdList:fill_unit_list(type)
	self:freeze()

	local list = self._list

	list:delete_all_items()

	local unit_list = self._unit_list
	local units = World:find_units_quick("all")
	local seen = {}

	for _, unit in pairs(units) do
		if unit:unit_data() then
			if not seen[unit:unit_data().unit_id] then
				local captured = false

				for id, v in pairs(seen) do
					for _, name in pairs(v) do
						if id == unit:unit_data().unit_id then
							captured = true
						end
					end
				end

				if unit:unit_data().unit_id ~= 0 and not captured then
					seen[unit:unit_data().unit_id] = {}
					seen[unit:unit_data().unit_id][#seen[unit:unit_data().unit_id] + 1] = unit:unit_data()
				end
			else
				seen[unit:unit_data().unit_id][#seen[unit:unit_data().unit_id] + 1] = unit:unit_data()
			end
		end
	end

	for k, v in pairs(seen) do
		if #v > 1 then
			self:append_item(k, #v)
		end
	end

	self._panel:layout()
	self:_autosize_columns()
	self:thaw()
end

function UnitDuplicateIdList:_autosize_columns()
	for i = 0, self._list:column_count() - 1 do
		self._list:autosize_column(i)
	end
end

function UnitDuplicateIdList:append_item(id, duplicates)
	local i = self._list:append_item(id)

	self._list:set_item(i, 1, duplicates)
end

function UnitDuplicateIdList:set_visible(visible)
	self._dialog:set_visible(visible)
end

function UnitDuplicateIdList:visible()
	self._dialog:visible()
end

function UnitDuplicateIdList:freeze()
	self._list:freeze()
	self._unit_list:freeze()
end

function UnitDuplicateIdList:thaw()
	self._unit_list:thaw()
	self._list:thaw()
end

UnitTreeBrowser = UnitTreeBrowser or class(CoreEditorEwsDialog)

function UnitTreeBrowser:init(...)
	CoreEditorEwsDialog.init(self, nil, "Browse avalible units", "", Vector3(200, 100, 0), Vector3(400, 900, 0), "DEFAULT_DIALOG_STYLE,RESIZE_BORDER", ...)
	self:create_panel("VERTICAL")

	self._unit_names = {}
	local horizontal_ctrlr_sizer = EWS:BoxSizer("HORIZONTAL")
	local vertical_tree_sizer = EWS:BoxSizer("VERTICAL")

	horizontal_ctrlr_sizer:add(vertical_tree_sizer, 1, 0, "EXPAND")

	local settings_sizer = EWS:BoxSizer("VERTICAL")

	settings_sizer:add(EWS:StaticText(self._panel, "Filter", 0, ""), 0, 0, "ALIGN_CENTER_HORIZONTAL")

	self._filter = EWS:TextCtrl(self._panel, "", "", "TE_CENTRE")

	settings_sizer:add(self._filter, 0, 0, "EXPAND")
	self._filter:connect("EVT_COMMAND_TEXT_UPDATED", callback(self, self, "update_tree"), nil)
	self._filter:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	vertical_tree_sizer:add(settings_sizer, 0, 0, "EXPAND")

	self._unit_tree = EWS:TreeCtrl(self._panel, "", "TR_ROW_LINES")

	self:create_image_list()
	vertical_tree_sizer:add(self._unit_tree, 1, 0, "EXPAND")
	self._panel_sizer:add(horizontal_ctrlr_sizer, 1, 0, "EXPAND")

	local button_sizer = EWS:BoxSizer("HORIZONTAL")
	local expand_all_btn = EWS:Button(self._panel, "Expand All", "", "")

	expand_all_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_expand_all"), "")
	expand_all_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	button_sizer:add(expand_all_btn, 0, 2, "RIGHT,LEFT")

	local collapse_all_btn = EWS:Button(self._panel, "Collapse All", "", "")

	collapse_all_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_collapse_all"), "")
	collapse_all_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	button_sizer:add(collapse_all_btn, 0, 2, "RIGHT,LEFT")

	local cancel_btn = EWS:Button(self._panel, "Close", "", "")

	button_sizer:add(cancel_btn, 0, 2, "RIGHT,LEFT")
	cancel_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_cancel"), "")
	cancel_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	self._panel_sizer:add(button_sizer, 0, 0, "ALIGN_RIGHT")
	self:update_tree()
	self._unit_tree:connect("EVT_COMMAND_TREE_SEL_CHANGED", callback(self, self, "on_select"), "")
	self._unit_tree:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	self._dialog_sizer:add(self._panel, 1, 0, "EXPAND")
	self:set_visible(true)
end

function UnitTreeBrowser:create_image_list()
	self._image_list = EWS:ImageList(16, 16)
	self._world_icon = self._image_list:add(CoreEWS.image_path("connection_16x16.png"))
	self._layer_icon = self._image_list:add(CoreEWS.image_path("folder_16x16.png"))
	self._layer_expand_icon = self._image_list:add(CoreEWS.image_path("folder_open_16x16.png"))
	self._category_icon = self._image_list:add(CoreEWS.image_path("folder_16x16.png"))
	self._category_expand_icon = self._image_list:add(CoreEWS.image_path("folder_open_16x16.png"))
	self._unit_icon = self._image_list:add(CoreEWS.image_path("world_editor\\unit_file_max_16x16.png"))
	self._no_preview_icon = self._image_list:add(CoreEWS.image_path("error_16x16.png"))

	self._unit_tree:set_image_list(self._image_list)
end

function UnitTreeBrowser:update_tree()
	self:_create_tree_data()
	self:_populate_tree()
end

function UnitTreeBrowser:_create_tree_data()
	self._tree_data = {
		total_units = 0,
		total_units_preview = 0,
		layers = {}
	}
	local layers = managers.editor:layers()
	local layer_names = self:sorted_map(layers)
	local filter = self._filter:get_value()

	for _, layer_name in ipairs(layer_names) do
		self._tree_data.layers[layer_name] = {
			total_layer_units = 0,
			total_layer_units_preview = 0,
			categories = {},
			path = {}
		}
		local c_map = layers[layer_name]:category_map()

		if c_map then
			local c_names = self:sorted_map(c_map)

			for _, c_name in ipairs(c_names) do
				self._tree_data.layers[layer_name].categories[c_name] = {
					total_units = 0,
					total_preview_units = 0,
					units = {}
				}
				local unit_names = self:sorted_map(c_map[c_name])

				for _, unit_name in ipairs(unit_names) do
					if string.find(unit_name, filter, 1, true) then
						local split = string.split(unit_name, "/")
						local path = self._tree_data.layers[layer_name].path

						for ip, pname in ipairs(split) do
							if ip == #split then
								path[pname .. ".unit"] = unit_name
							else
								path[pname] = path[pname] or {}
							end

							path = path[pname]
						end

						local preview = self:has_preview(managers.editor:get_real_name(unit_name))
						self._tree_data.layers[layer_name].categories[c_name].units[unit_name] = preview and true or false
						self._tree_data.total_units = self._tree_data.total_units + 1
						self._tree_data.total_units_preview = self._tree_data.total_units_preview + (preview and 1 or 0)
						self._tree_data.layers[layer_name].total_layer_units = self._tree_data.layers[layer_name].total_layer_units + 1
						self._tree_data.layers[layer_name].total_layer_units_preview = self._tree_data.layers[layer_name].total_layer_units_preview + (preview and 1 or 0)
						self._tree_data.layers[layer_name].categories[c_name].total_units = self._tree_data.layers[layer_name].categories[c_name].total_units + 1
						self._tree_data.layers[layer_name].categories[c_name].total_preview_units = self._tree_data.layers[layer_name].categories[c_name].total_preview_units + (preview and 1 or 0)
					end
				end
			end
		end
	end
end

function UnitTreeBrowser:_populate_unit_paths(path, id)
	local x_unit, y_unit = nil

	local function sort(x, y)
		x_unit = string.find(x, ".unit", nil, true) and true or false
		y_unit = string.find(y, ".unit", nil, true) and true or false

		if x_unit ~= y_unit then
			return y_unit
		end

		return x < y
	end

	local ip_keys = table.map_keys(path, sort)
	local size = 0

	for _, pname in ipairs(ip_keys) do
		local data = path[pname]
		size = size + (type(data) ~= "table" and 1 or 0)
	end

	local nsize = size

	for _, pname in ipairs(ip_keys) do
		local data = path[pname]
		local new_name = string.gsub(pname, "%.unit", "")
		local new_id = self._unit_tree:append(id, new_name)

		if type(data) == "table" then
			self._unit_tree:set_item_image(new_id, self._category_icon)
			self._unit_tree:set_item_image(new_id, self._category_expand_icon, "EXPANDED")

			nsize = self:_populate_unit_paths(data, new_id)
			size = size + nsize

			self._unit_tree:set_item_text(new_id, new_name .. " [" .. nsize .. "]")
		else
			self._unit_tree:set_item_image(new_id, self._unit_icon)

			self._unit_names[new_id] = data
		end
	end

	return size
end

function UnitTreeBrowser:_populate_tree()
	self._unit_tree:freeze()
	self._unit_tree:clear()

	self._unit_names = {}
	self._root = self._unit_tree:append_root("Units [" .. self._tree_data.total_units .. "]")

	self._unit_tree:set_item_bold(self._root, true)
	self._unit_tree:set_item_image(self._root, self._world_icon)

	local layer_names = self:sorted_map(self._tree_data.layers)
	local filter = self._filter:get_value()

	for _, layer_name in ipairs(layer_names) do
		local layer = self._tree_data.layers[layer_name]
		local preview = layer.total_layer_units_preview
		local total = layer.total_layer_units

		if filter == "" or total > 0 then
			local layer_id = self._unit_tree:append(self._root, layer_name .. " [" .. total .. "]")

			self._unit_tree:set_item_image(layer_id, self._layer_icon)
			self._unit_tree:set_item_image(layer_id, self._layer_expand_icon, "EXPANDED")
			self:_populate_unit_paths(self._tree_data.layers[layer_name].path, layer_id)
		end
	end

	self._unit_tree:expand(self._root)
	self._unit_tree:thaw()
end

function UnitTreeBrowser:sorted_map(map)
	local sorted = {}

	for index, _ in pairs(map) do
		table.insert(sorted, index)
	end

	table.sort(sorted)

	return sorted
end

function UnitTreeBrowser:on_select(a, event)
	local id = event:get_item()

	if self._unit_names[id] then
		local item_text = self._unit_names[id]
		local name = managers.editor:get_real_name(item_text)

		managers.editor:select_unit_name(name)
	end
end

function UnitTreeBrowser:has_preview(name)
	if DB:has("preview_texture", name) then
		return managers.database:entry_expanded_path("preview_texture", name)
	end

	return nil
end

function UnitTreeBrowser:on_expand_all()
	self._unit_tree:freeze()
	self:expand_children(self._unit_tree:get_children(self._root))
	self._unit_tree:thaw()
end

function UnitTreeBrowser:expand_children(children)
	for _, child in ipairs(children) do
		self:expand_children(self._unit_tree:get_children(child))
		self._unit_tree:expand(child)
	end
end

function UnitTreeBrowser:on_collapse_all()
	self._unit_tree:freeze()
	self:collapse_children(self._unit_tree:get_children(self._root))
	self._unit_tree:thaw()
end

function UnitTreeBrowser:collapse_children(children)
	for _, child in ipairs(children) do
		self:collapse_children(self._unit_tree:get_children(child))
		self._unit_tree:collapse(child)
	end
end

GlobalSelectUnit = GlobalSelectUnit or class(CoreEditorEwsDialog)

function GlobalSelectUnit:init(...)
	CoreEditorEwsDialog.init(self, nil, "Global select unit", "", Vector3(525, 160, 0), Vector3(560, 680, 0), "DEFAULT_DIALOG_STYLE,RESIZE_BORDER,MINIMIZE_BOX,MAXIMIZE_BOX", ...)
	self:create_panel("VERTICAL")

	self._only_list_used_units = false
	local horizontal_ctrlr_sizer = EWS:BoxSizer("HORIZONTAL")

	self._panel_sizer:add(horizontal_ctrlr_sizer, 1, 0, "EXPAND")

	local list_sizer = EWS:BoxSizer("VERTICAL")

	horizontal_ctrlr_sizer:add(list_sizer, 3, 0, "EXPAND")

	local layers_scrollable_window = EWS:ScrolledWindow(self._panel, "", "VSCROLL")

	layers_scrollable_window:set_scroll_rate(Vector3(0, 5, 0))
	layers_scrollable_window:set_virtual_size_hints(Vector3(0, 0, 0), Vector3(1, -1, -1))
	layers_scrollable_window:set_virtual_size(Vector3(200, 2000, 0))
	horizontal_ctrlr_sizer:add(layers_scrollable_window, 1, 0, "EXPAND")

	local layers_sizer = EWS:StaticBoxSizer(layers_scrollable_window, "VERTICAL", "Type filter")

	layers_scrollable_window:set_sizer(layers_sizer)

	self._all_names = self:_all_unit_names()
	self._names_as_ipairs = table.map_keys(self._all_names)
	self._short_name = EWS:CheckBox(self._panel, "Short name", "", "ALIGN_LEFT")

	self._short_name:set_value(true)
	list_sizer:add(self._short_name, 0, 5, "TOP,LEFT,EXPAND")
	list_sizer:add(EWS:StaticText(self._panel, "Filter", 0, ""), 0, 0, "ALIGN_CENTER_HORIZONTAL")

	self._filter = EWS:TextCtrl(self._panel, "", "", "TE_CENTRE")

	list_sizer:add(self._filter, 0, 0, "EXPAND")

	local cb = EWS:CheckBox(self._panel, "Only list used units", "", "ALIGN_LEFT")

	cb:set_value(self._only_list_used_units)
	cb:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "on_only_list_used_units"), {
		cb = cb
	})
	cb:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	list_sizer:add(cb, 0, 5, "TOP,BOTTOM,LEFT")

	self._units = EWS:ListCtrl(self._panel, "", "LC_REPORT,LC_NO_HEADER,LC_SORT_ASCENDING,LC_SINGLE_SEL")

	self._units:clear_all()
	self._units:append_column("Name")
	self._units:autosize_column(0)
	list_sizer:add(self._units, 1, 0, "EXPAND")
	self._units:connect("EVT_COMMAND_LIST_ITEM_SELECTED", callback(self, self, "on_select_unit_dialog"), self._units)
	self._units:connect("EVT_KEY_DOWN", callback(self, self, "key_down"), "")
	self._units:connect("EVT_KEY_UP", callback(self, self, "key_up"), "")
	self._units:connect("EVT_KILL_FOCUS", callback(self, self, "_on_units_focus_lost"), "")
	self._short_name:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "update_list"), nil)
	self._filter:connect("EVT_COMMAND_TEXT_UPDATED", callback(self, self, "update_list"), nil)
	self._filter:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	self._filter:connect("EVT_UPDATE_UI", callback(self, self, "update"), nil)

	self._layer_cbs = {}
	local layers = managers.editor:layers()
	local names_layers = {}

	for name, layer in pairs(layers) do
		for _, type in ipairs(layer:unit_types()) do
			if not table.contains(names_layers, type) then
				table.insert(names_layers, type)
			end
		end
	end

	table.sort(names_layers)

	for _, name in ipairs(names_layers) do
		local cb = EWS:CheckBox(layers_scrollable_window, name, "")

		cb:set_value(true)

		self._layer_cbs[name] = cb

		cb:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "on_layer_cb"), {
			cb = cb,
			name = name
		})
		cb:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
		layers_sizer:add(cb, 0, 2, "EXPAND,TOP")
	end

	local layer_buttons_sizer = EWS:BoxSizer("HORIZONTAL")
	local all_btn = EWS:Button(layers_scrollable_window, "All", "", "BU_EXACTFIT,NO_BORDER")

	layer_buttons_sizer:add(all_btn, 0, 2, "TOP,BOTTOM")
	all_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_all_layers"), "")
	all_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local none_btn = EWS:Button(layers_scrollable_window, "None", "", "BU_EXACTFIT,NO_BORDER")

	layer_buttons_sizer:add(none_btn, 0, 2, "TOP,BOTTOM")
	none_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_none_layers"), "")
	none_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local invert_btn = EWS:Button(layers_scrollable_window, "Invert", "", "BU_EXACTFIT,NO_BORDER")

	layer_buttons_sizer:add(invert_btn, 0, 2, "TOP,BOTTOM")
	invert_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_invert_layers"), "")
	invert_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	layers_sizer:add(layer_buttons_sizer, 0, 2, "TOP,BOTTOM")
	self:update_list()

	local btn_sizer = EWS:BoxSizer("HORIZONTAL")
	local reload_btn = EWS:Button(self._panel, "Reload", "", "")

	reload_btn:set_tool_tip("Should only be used by artist, level designers be aware.")
	reload_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_reload"), "")
	reload_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	btn_sizer:add(reload_btn, 0, 5, "RIGHT")

	local cancel_btn = EWS:Button(self._panel, "Close", "", "")

	cancel_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_cancel"), "")
	cancel_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	btn_sizer:add(cancel_btn, 0, 5, "RIGHT")
	self._panel_sizer:add(btn_sizer, 0, 0, "ALIGN_RIGHT")
	self._dialog_sizer:add(self._panel, 1, 0, "EXPAND")
	self:set_visible(true)
end

function GlobalSelectUnit:key_down(ctrlr, event)
	event:skip()

	if EWS:name_to_key_code("K_ESCAPE") == event:key_code() then
		Application:trace("GlobalSelectUnit:key_down(ctrlr, event): ESCAPE")
		self:on_cancel()
	elseif EWS:name_to_key_code("K_SPACE") == event:key_code() then
		self:_show_unit_preview()
	end
end

function GlobalSelectUnit:key_up(ctrlr, event)
	event:skip()

	if EWS:name_to_key_code("K_ESCAPE") == event:key_code() then
		Application:trace("GlobalSelectUnit:key_up(ctrlr, event): ESCAPE")
		self:on_cancel()
	elseif EWS:name_to_key_code("K_SPACE") == event:key_code() then
		self:_on_unit_preview_end()
	end
end

function GlobalSelectUnit:_show_unit_preview()
	if self:_is_unit_being_previewed() then
		self:_on_unit_preview_update()

		return
	end

	self:_on_unit_preview_start(self:_get_selected_unit())
end

function GlobalSelectUnit:_on_units_focus_lost(ctrlr, event)
	self:_on_unit_preview_end()
end

function GlobalSelectUnit:_on_unit_preview_start(unit_to_preview)
	if unit_to_preview == nil then
		return
	end

	self._preview_unit = unit_to_preview
	local previewed_unit_height = self:_calculate_bounding_sphere_radius(unit_to_preview)
	local desired_distance_to_camera = previewed_unit_height

	self:_setup_preview_camera(previewed_unit_height, desired_distance_to_camera)

	local position_in_front_camera = self._new_cam_pos + Application:last_camera_rotation():y() * desired_distance_to_camera

	unit_to_preview:set_position(position_in_front_camera + unit_to_preview:position() - unit_to_preview:oobb():center())

	self._rotation_point_for_preview = Vector3(unit_to_preview:oobb():center().x, unit_to_preview:oobb():center().y, unit_to_preview:oobb():center().z)
end

function GlobalSelectUnit:_on_unit_preview_update()
	local degrees_per_second = 45
	local time = Application:time()
	local dt = nil

	if self._last_preview_update_time == nil then
		dt = 0.01667
	else
		dt = time - self._last_preview_update_time
	end

	if dt >= 0.01667 then
		self:_rotate_around_point(self._preview_unit, self._rotation_point_for_preview, math.UP, dt, degrees_per_second)

		self._last_preview_update_time = time
	end
end

function GlobalSelectUnit:_on_unit_preview_end()
	if not self:_is_unit_being_previewed() then
		return
	end

	World:delete_unit(self._preview_unit)

	self._preview_unit = nil

	managers.viewport:get_current_camera():set_fov(self._old_fov)
	managers.viewport:get_current_camera():set_position(self._old_cam_pos)

	self._old_cam_pos = nil
	self._old_fov = nil
	self._rotation_point_for_preview = nil
	self._last_preview_update_time = nil
end

function GlobalSelectUnit:_is_unit_being_previewed()
	return self._preview_unit
end

function GlobalSelectUnit:_get_selected_unit()
	if self._units:selected_item() == -1 then
		return
	end

	local selected_item_index = self._units:selected_item()
	local name = managers.editor:get_real_name(self._units:get_item_data(selected_item_index))

	return CoreUnit.safe_spawn_unit(name, Application:last_camera_position() + Application:last_camera_rotation():y(), Rotation(0, 0, 0))
end

function GlobalSelectUnit:_setup_preview_camera(previewed_unit_height, desired_distance_to_camera)
	local one_km = 10000
	self._old_cam_pos = managers.viewport:get_current_camera():position()
	self._new_cam_pos = Application:last_camera_position() + math.UP * one_km
	self._old_fov = managers.viewport:get_current_camera():fov()
	local new_fov = math.deg(math.atan(previewed_unit_height / (2 * desired_distance_to_camera)))

	managers.viewport:get_current_camera():set_fov(new_fov)
	managers.viewport:get_current_camera():set_position(self._new_cam_pos)
end

function GlobalSelectUnit:_calculate_bounding_sphere_radius(unit)
	local oobb_diagonal_length = math.sqrt(unit:oobb():size().x * unit:oobb():size().x + unit:oobb():size().y * unit:oobb():size().y + unit:oobb():size().z * unit:oobb():size().z)

	return oobb_diagonal_length * 2
end

function GlobalSelectUnit:_rotate_around_point(unit, point_to_rotate_around, axis, dt, speed)
	unit:set_position(unit:position() - point_to_rotate_around * dt)
	unit:set_rotation(unit:rotation() * Rotation(axis, speed * dt))
	unit:set_position(unit:position() + point_to_rotate_around * dt)
end

function GlobalSelectUnit:_stripped_unit_name(name)
	local reverse = string.reverse(name)
	local i = string.find(reverse, "/")
	name = string.reverse(string.sub(reverse, 0, i - 1))

	return name
end

function GlobalSelectUnit:_all_unit_names()
	local names = {}
	local layers = managers.editor:layers()

	for name, layer in pairs(layers) do
		for unit_name, unit_resource in pairs(layer:get_unit_map()) do
			names[unit_name] = unit_resource:type():s()
		end
	end

	table.sort(names)

	return names
end

function GlobalSelectUnit:_current_unit_names()
	local layers = managers.editor:layers()
	local current_names = {}

	for name, layer in pairs(layers) do
		for _, unit in ipairs(layer:created_units()) do
			current_names[unit:name():s()] = (current_names[unit:name():s()] or 0) + 1
		end
	end

	local names = {}

	for name, type in pairs(self._all_names) do
		if current_names[managers.editor:get_real_name(name)] then
			names[name] = current_names[managers.editor:get_real_name(name)]
		end
	end

	self._current = names

	return names
end

function GlobalSelectUnit:on_only_list_used_units(data)
	self._only_list_used_units = data.cb:get_value()

	self:update_list()
end

function GlobalSelectUnit:on_reload()
	local i = self._units:selected_item()

	if i ~= -1 then
		local name = managers.editor:get_real_name(self._units:get_item_data(i))

		managers.editor:reload_units({
			Idstring(name)
		}, true)
	end
end

function GlobalSelectUnit:on_select_unit_dialog(units)
	local i = units:selected_item()

	if i ~= -1 then
		local name = managers.editor:get_real_name(units:get_item_data(i))

		managers.editor:output(managers.editor:select_unit_name(name))
	end
end

function GlobalSelectUnit:update_list(current)
	local filter = self._filter:get_value()
	local sub_filters = {}

	if string.len(string.gsub(filter, "%s", "")) > 0 then
		for sub_filter in filter:gmatch("%w+") do
			sub_filters[#sub_filters + 1] = sub_filter
		end
	end

	self._units:delete_all_items()

	self._units_to_append = {}

	if self._only_list_used_units then
		current = current or self:_current_unit_names()

		for name, _ in pairs(current) do
			local type = self._all_names[name]

			if self._layer_cbs[type]:get_value() then
				local stripped_name = self._short_name:get_value() and self:_stripped_unit_name(name) or name
				local isMatching = true

				for key, value in ipairs(sub_filters) do
					if not string.find(stripped_name, value) then
						isMatching = false
					end
				end

				if isMatching then
					table.insert(self._units_to_append, {
						stripped_name = stripped_name,
						name = name
					})
				end
			end
		end
	else
		for _, name in ipairs(self._names_as_ipairs) do
			local type = self._all_names[name]

			if self._layer_cbs[type]:get_value() then
				local stripped_name = self._short_name:get_value() and self:_stripped_unit_name(name) or name
				local isMatching = true

				for key, value in ipairs(sub_filters) do
					if not string.find(stripped_name, value) then
						isMatching = false
					end
				end

				if isMatching then
					table.insert(self._units_to_append, {
						stripped_name = stripped_name,
						name = name
					})
				end
			end
		end
	end

	table.sort(self._units_to_append, function (a, b)
		return a.stripped_name < b.stripped_name
	end)
end

function GlobalSelectUnit:update()
	if not self._units_to_append then
		return
	end

	local append_count = 100

	while append_count > 0 do
		if #self._units_to_append == 0 then
			break
		end

		append_count = append_count - 1
		local data = table.remove(self._units_to_append, 1)
		local i = self._units:append_item(data.stripped_name)

		self._units:set_item_data(i, data.name)
	end

	if #self._units_to_append == 0 then
		self._units_to_append = nil

		self._units:autosize_column(0)
	end
end

function GlobalSelectUnit:spawned_unit(unit)
	if self._only_list_used_units then
		for name, _ in pairs(self._current) do
			if unit:name():s() == managers.editor:get_real_name(name) then
				self._current[name] = self._current[name] + 1

				self:update_list(self._current)

				return
			end
		end

		for name, type in pairs(self._all_names) do
			if unit:name():s() == managers.editor:get_real_name(name) then
				self._current[name] = 1

				self:update_list(self._current)

				return
			end
		end
	end
end

function GlobalSelectUnit:deleted_unit(unit)
	if self._only_list_used_units then
		for name, _ in pairs(self._current) do
			if unit:name():s() == managers.editor:get_real_name(name) then
				self._current[name] = self._current[name] - 1

				if self._current[name] == 0 then
					self._current[name] = nil
				end

				self:update_list(self._current)

				return
			end
		end
	end
end

function GlobalSelectUnit:set_visible(...)
	CoreEditorEwsDialog.set_visible(self, ...)
	self._filter:set_focus()
	self._filter:set_selection(-1, -1)
end

function GlobalSelectUnit:reset()
	self:update_list()
end

function GlobalSelectUnit:on_all_layers()
	for name, cb in pairs(self._layer_cbs) do
		cb:set_value(true)
	end

	self:update_list()
end

function GlobalSelectUnit:on_none_layers()
	for name, cb in pairs(self._layer_cbs) do
		cb:set_value(false)
	end

	self:update_list()
end

function GlobalSelectUnit:on_invert_layers()
	for name, cb in pairs(self._layer_cbs) do
		cb:set_value(not cb:get_value())
	end

	self:update_list()
end

function GlobalSelectUnit:on_layer_cb(data)
	self:update_list()
end

ReplaceUnit = ReplaceUnit or class(CoreEditorEwsDialog)

function ReplaceUnit:init(name, types)
	CoreEditorEwsDialog.init(self, nil, name, "", Vector3(300, 150, 0), Vector3(900, 500, 0), "DEFAULT_DIALOG_STYLE,RESIZE_BORDER")
	self:create_panel("VERTICAL")

	local horizontal_units_sizer = EWS:BoxSizer("HORIZONTAL")

	self._panel_sizer:add(horizontal_units_sizer, 1, 0, "EXPAND")

	local notebook = EWS:Notebook(self._panel, "", "NB_TOP,NB_MULTILINE")

	horizontal_units_sizer:add(notebook, 1, 0, "EXPAND")

	self._all_unit_lists = {}
	local category_map = {}
	local unit_names = {}

	for _, t in pairs(types) do
		category_map[t] = {}

		for _, unit_name in ipairs(managers.database:list_units_of_type(t)) do
			table.insert(category_map[t], unit_name)
			table.insert(unit_names, unit_name)
		end
	end

	local panel = EWS:Panel(self._panel, "", "TAB_TRAVERSAL")

	horizontal_units_sizer:add(panel, 1, 0, "EXPAND")

	local units_sizer = EWS:BoxSizer("VERTICAL")

	panel:set_sizer(units_sizer)
	units_sizer:add(EWS:StaticText(panel, "Filter", 0, ""), 0, 0, "ALIGN_CENTER_HORIZONTAL")

	local unit_filter = EWS:TextCtrl(panel, "", "", "TE_CENTRE")

	units_sizer:add(unit_filter, 0, 0, "EXPAND")

	local units = EWS:ListBox(panel, "", "LB_SINGLE,LB_HSCROLL,LB_NEEDED_SB,LB_SORT")

	units:freeze()

	for _, name in pairs(unit_names) do
		units:append(name)
	end

	units_sizer:add(units, 1, 0, "EXPAND")
	units:connect("EVT_COMMAND_LISTBOX_SELECTED", callback(self, self, "replace_unit_name"), units)
	units:thaw()
	unit_filter:connect("EVT_COMMAND_TEXT_UPDATED", callback(self, self, "update_filter"), {
		filter = unit_filter,
		units = units,
		names = unit_names
	})
	table.insert(self._all_unit_lists, units)

	for c, names in pairs(category_map) do
		local panel = EWS:Panel(notebook, "", "TAB_TRAVERSAL")
		local units_sizer = EWS:BoxSizer("VERTICAL")

		panel:set_sizer(units_sizer)
		units_sizer:add(EWS:StaticText(panel, "Filter", 0, ""), 0, 0, "ALIGN_CENTER_HORIZONTAL")

		local unit_filter = EWS:TextCtrl(panel, "", "", "TE_CENTRE")

		units_sizer:add(unit_filter, 0, 0, "EXPAND")

		local units = EWS:ListBox(panel, "", "LB_SINGLE,LB_HSCROLL,LB_NEEDED_SB,LB_SORT")

		units:freeze()

		for _, name in ipairs(names) do
			units:append(name)
		end

		units_sizer:add(units, 1, 0, "EXPAND")
		units:connect("EVT_COMMAND_LISTBOX_SELECTED", callback(self, self, "replace_unit_name"), units)
		units:thaw()
		unit_filter:connect("EVT_COMMAND_TEXT_UPDATED", callback(self, self, "update_filter"), {
			filter = unit_filter,
			units = units,
			names = names
		})
		notebook:add_page(panel, managers.editor:category_name(c), true)
		table.insert(self._all_unit_lists, units)
	end

	local btn_sizer = EWS:BoxSizer("HORIZONTAL")
	local ok_btn = EWS:Button(self._panel, "OK", "_ok_dialog", "BU_EXACTFIT,NO_BORDER")

	ok_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "close_replace_unit"), {
		value = true
	})
	btn_sizer:add(ok_btn, 0, 5, "RIGHT")

	local none_btn = EWS:Button(self._panel, "None", "_none_dialog", "BU_EXACTFIT,NO_BORDER")

	none_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "close_replace_unit"), {
		value = false
	})
	btn_sizer:add(none_btn, 0, 5, "RIGHT")
	self._panel_sizer:add(btn_sizer, 0, 0, "ALIGN_RIGHT")
	self._dialog_sizer:add(self._panel, 1, 0, "EXPAND")
	self:show_modal()
end

function ReplaceUnit:replace_unit_name(units)
	for _, units_list in ipairs(self._all_unit_lists) do
		if units_list ~= units then
			local i = units_list:selected_index()

			if i > -1 then
				units_list:deselect_index(i)
			end
		end
	end

	local i = units:selected_index()

	if i > -1 then
		self._replace_unit_name = units:get_string(i)
	end
end

function ReplaceUnit:update_filter(data)
	local filter = data.filter:get_value()

	data.units:freeze()
	data.units:clear()

	for _, name in pairs(data.names) do
		if string.find(name, filter) then
			data.units:append(name)
		end
	end

	data.units:thaw()
end

function ReplaceUnit:close_replace_unit(data)
	self._made_replace_choice = data.value

	self:end_modal()
end

function ReplaceUnit:result()
	if self._made_replace_choice and self._replace_unit_name then
		return self._replace_unit_name
	end

	return false
end

LayerReplaceUnit = LayerReplaceUnit or class(CoreEditorEwsDialog)

function LayerReplaceUnit:init(layer)
	CoreEditorEwsDialog.init(self, nil, "Replace Units", "", Vector3(525, 200, 0), Vector3(270, 400, 0), "DEFAULT_DIALOG_STYLE,RESIZE_BORDER,STAY_ON_TOP")
	self:create_panel("VERTICAL")

	self._only_list_used_units = false
	self._layer = layer
	self._all_names = self:_all_unit_names(layer)

	self._panel_sizer:add(EWS:StaticText(self._panel, "Filter", 0, ""), 0, 0, "ALIGN_CENTER_HORIZONTAL")

	self._filter = EWS:TextCtrl(self._panel, "", "", "TE_CENTRE")

	self._panel_sizer:add(self._filter, 0, 0, "EXPAND")

	local cb = EWS:CheckBox(self._panel, "Only list used units", "", "ALIGN_RIGHT")

	cb:set_value(self._only_list_used_units)
	cb:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "on_only_list_used_units"), {
		cb = cb
	})
	cb:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	self._panel_sizer:add(cb, 0, 5, "TOP,BOTTOM,RIGHT")

	self._units = EWS:ListBox(self._panel, "", "LB_SINGLE,LB_HSCROLL,LB_NEEDED_SB,LB_SORT")

	self:update_list()
	self._panel_sizer:add(self._units, 1, 0, "EXPAND")
	self._units:connect("EVT_COMMAND_LISTBOX_DOUBLECLICKED", callback(self, self, "replace_unit"), {
		all = false,
		units = self._units
	})
	self._units:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	self._filter:connect("EVT_COMMAND_TEXT_UPDATED", callback(self, self, "update_list"), nil)
	self._filter:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local btn_sizer = EWS:BoxSizer("HORIZONTAL")
	local replace_btn = EWS:Button(self._panel, "Replace", "", "")

	replace_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "replace_unit"), {
		all = false,
		units = self._units
	})
	replace_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	btn_sizer:add(replace_btn, 0, 5, "EXPAND,RIGHT")

	local replace_all_btn = EWS:Button(self._panel, "Replace All", "", "")

	replace_all_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "replace_unit"), {
		all = true,
		units = self._units
	})
	replace_all_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	btn_sizer:add(replace_all_btn, 0, 5, "EXPAND,RIGHT")

	local cancel_btn = EWS:Button(self._panel, "Close", "", "")

	cancel_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_cancel"), "")
	cancel_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	btn_sizer:add(cancel_btn, 0, 5, "RIGHT")
	self._panel_sizer:add(btn_sizer, 0, 0, "ALIGN_RIGHT")
	self._dialog_sizer:add(self._panel, 1, 0, "EXPAND")
	self:set_visible(true)
end

function LayerReplaceUnit:_all_unit_names(layer)
	local names = {}

	for unit_name, _ in pairs(layer:get_unit_map()) do
		table.insert(names, unit_name)
	end

	table.sort(names)

	return names
end

function LayerReplaceUnit:replace_unit(data)
	if self._layer:selected_unit() and data then
		local units = data.units
		local i = units:selected_index()

		if i > -1 then
			local name = managers.editor:get_real_name(units:get_string(i))

			self._layer:replace_unit(name, data.all)
		end
	end
end

function LayerReplaceUnit:_current_unit_names()
	local current_names = {}

	for _, unit in ipairs(self._layer:created_units()) do
		current_names[unit:name():s()] = (current_names[unit:name():s()] or 0) + 1
	end

	local names = {}

	for _, name in ipairs(self._all_names) do
		if current_names[managers.editor:get_real_name(name)] then
			names[name] = current_names[managers.editor:get_real_name(name)]
		end
	end

	self._current = names

	return names
end

function LayerReplaceUnit:on_only_list_used_units(data)
	self._only_list_used_units = data.cb:get_value()

	self:update_list()
end

function LayerReplaceUnit:update_list(current)
	self._units:freeze()

	local filter = self._filter:get_value()

	self._units:clear()

	if self._only_list_used_units then
		current = current or self:_current_unit_names()

		for name, _ in pairs(current) do
			if string.find(name, filter) then
				self._units:append(name)
			end
		end
	else
		for _, name in ipairs(self._all_names) do
			if string.find(name, filter) then
				self._units:append(name)
			end
		end
	end

	self._units:thaw()
end

function LayerReplaceUnit:set_visible(visible)
	CoreEditorEwsDialog.set_visible(self, visible)
	self:update_list()
end

function LayerReplaceUnit:spawned_unit(unit)
	if self._only_list_used_units then
		for name, _ in pairs(self._current) do
			if unit:name():s() == managers.editor:get_real_name(name) then
				self._current[name] = self._current[name] + 1

				self:update_list(self._current)

				return
			end
		end

		for _, name in ipairs(self._all_names) do
			if unit:name():s() == managers.editor:get_real_name(name) then
				self._current[name] = 1

				self:update_list(self._current)

				return
			end
		end
	end
end

function LayerReplaceUnit:deleted_unit(unit)
	if self._only_list_used_units then
		for name, _ in pairs(self._current) do
			if unit:name():s() == managers.editor:get_real_name(name) then
				self._current[name] = self._current[name] - 1

				if self._current[name] == 0 then
					self._current[name] = nil
				end

				self:update_list(self._current)

				return
			end
		end
	end
end

function LayerReplaceUnit:reset()
	self:update_list()
end

MoveTransformTypeIn = MoveTransformTypeIn or class(CoreEditorEwsDialog)

function MoveTransformTypeIn:init()
	CoreEditorEwsDialog.init(self, nil, "Move transform type-in", "", Vector3(761, 67, 0), Vector3(264, 111, 0), "DEFAULT_DIALOG_STYLE,RESIZE_BORDER,STAY_ON_TOP")
	self:create_panel("HORIZONTAL")

	self._min = -100000000
	self._max = 100000000
	local world_sizer = EWS:StaticBoxSizer(self._panel, "VERTICAL", "Absolut:World")
	self._ax = self:_create_ctrl("X:", "x", 0, "absolut", world_sizer)
	self._ay = self:_create_ctrl("Y:", "y", 0, "absolut", world_sizer)
	self._az = self:_create_ctrl("Z:", "z", 0, "absolut", world_sizer)

	self._panel_sizer:add(world_sizer, 1, 0, "EXPAND")

	local offset_sizer = EWS:StaticBoxSizer(self._panel, "VERTICAL", "Offset")
	self._ox = self:_create_ctrl("X:", "x", 0, "offset", offset_sizer)
	self._oy = self:_create_ctrl("Y:", "y", 0, "offset", offset_sizer)
	self._oz = self:_create_ctrl("Z:", "z", 0, "offset", offset_sizer)

	self._panel_sizer:add(offset_sizer, 1, 0, "EXPAND")
	self._dialog_sizer:add(self._panel, 1, 0, "EXPAND")
	self._panel:set_enabled(false)
end

function MoveTransformTypeIn:_create_ctrl(name, coor, value, type, sizer)
	local ctrl_sizer = EWS:BoxSizer("HORIZONTAL")

	ctrl_sizer:add(EWS:StaticText(self._panel, name, "", "ALIGN_LEFT"), 0, 0, "EXPAND")

	local ctrl = EWS:TextCtrl(self._panel, value, "", "TE_PROCESS_ENTER")

	ctrl:set_tool_tip("Type in " .. type .. " " .. coor .. "-coordinate in meters")
	ctrl:set_min_size(Vector3(-1, 10, 0))
	ctrl:connect("EVT_CHAR", callback(nil, _G, "verify_number"), ctrl)

	if type == "offset" then
		ctrl:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "update_offset"), {
			ctrl = ctrl,
			coor = coor
		})
		ctrl:connect("EVT_KILL_FOCUS", callback(self, self, "update_offset"), {
			ctrl = ctrl,
			coor = coor
		})
	else
		ctrl:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "update_absolut"), {
			ctrl = ctrl,
			coor = coor
		})
		ctrl:connect("EVT_KILL_FOCUS", callback(self, self, "update_absolut"), {
			ctrl = ctrl,
			coor = coor
		})
	end

	ctrl_sizer:add(ctrl, 1, 0, "EXPAND")

	local spin = EWS:SpinButton(self._panel, "", "SP_VERTICAL")

	spin:set_min_size(Vector3(-1, 10, 0))

	local c = ctrl

	if type == "offset" then
		c = self["_a" .. coor]
	end

	spin:connect("EVT_SCROLL_LINEUP", callback(self, self, "update_spin"), {
		step = 0.1,
		ctrl = c,
		coor = coor
	})
	spin:connect("EVT_SCROLL_LINEDOWN", callback(self, self, "update_spin"), {
		step = -0.1,
		ctrl = c,
		coor = coor
	})
	ctrl_sizer:add(spin, 0, 0, "EXPAND")
	sizer:add(ctrl_sizer, 1, 10, "EXPAND,LEFT,RIGHT")

	return ctrl
end

function MoveTransformTypeIn:update_spin(data)
	if not tonumber(data.ctrl:get_value()) then
		data.ctrl:set_value(0)
	end

	data.ctrl:set_value(string.format("%.2f", data.ctrl:get_value() + data.step))
	self:update_absolut(data)
end

function MoveTransformTypeIn:update_absolut(data)
	local value = tonumber(data.ctrl:get_value()) or 0

	if self._min == value then
		return
	end

	value = value * 100

	if alive(self._unit) then
		local pos = self._unit:position()
		pos = pos["with_" .. data.coor](pos, value)

		data.ctrl:change_value(string.format("%.2f", value / 100))
		data.ctrl:set_selection(-1, -1)
		managers.editor:set_selected_units_position(pos)
	end
end

function MoveTransformTypeIn:update_offset(data, event)
	local value = tonumber(data.ctrl:get_value()) or 0

	if alive(self._unit) then
		local local_rot = managers.editor:is_coordinate_system("Local")
		local pos = self._unit:position()
		local rot = Rotation()

		if local_rot then
			rot = self._unit:rotation()
		end

		value = value * 100
		pos = pos + rot[data.coor](rot) * value

		managers.editor:set_selected_units_position(pos)
		data.ctrl:change_value(0)
		data.ctrl:set_selection(-1, -1)
	end
end

function MoveTransformTypeIn:set_unit(unit)
	self._unit = unit

	self._panel:set_enabled(alive(self._unit))
end

function MoveTransformTypeIn:update(t, dt)
	if alive(self._unit) then
		local pos = self._unit:position()

		if not self._ax:in_focus() then
			self._ax:change_value(string.format("%.2f", pos.x / 100))
		end

		if not self._ay:in_focus() then
			self._ay:change_value(string.format("%.2f", pos.y / 100))
		end

		if not self._az:in_focus() then
			self._az:change_value(string.format("%.2f", pos.z / 100))
		end
	end
end

RotateTransformTypeIn = RotateTransformTypeIn or class(CoreEditorEwsDialog)

function RotateTransformTypeIn:init()
	CoreEditorEwsDialog.init(self, nil, "Rotate transform type-in", "", Vector3(761, 180, 0), Vector3(264, 111, 0), "DEFAULT_DIALOG_STYLE,RESIZE_BORDER,STAY_ON_TOP")
	self:create_panel("HORIZONTAL")

	self._min = -100000000
	self._max = 100000000
	local world_sizer = EWS:StaticBoxSizer(self._panel, "VERTICAL", "Absolut:World")
	self._ax = self:_create_ctrl("X:", "x", 0, "absolut", world_sizer)
	self._ay = self:_create_ctrl("Y:", "y", 0, "absolut", world_sizer)
	self._az = self:_create_ctrl("Z:", "z", 0, "absolut", world_sizer)

	self._panel_sizer:add(world_sizer, 1, 0, "EXPAND")

	local offset_sizer = EWS:StaticBoxSizer(self._panel, "VERTICAL", "Offset")
	self._ox = self:_create_ctrl("X:", "x", 0, "offset", offset_sizer)
	self._oy = self:_create_ctrl("Y:", "y", 0, "offset", offset_sizer)
	self._oz = self:_create_ctrl("Z:", "z", 0, "offset", offset_sizer)

	self._panel_sizer:add(offset_sizer, 1, 0, "EXPAND")
	self._dialog_sizer:add(self._panel, 1, 0, "EXPAND")
	self._panel:set_enabled(false)
end

function RotateTransformTypeIn:_create_ctrl(name, coor, value, type, sizer)
	local ctrl_sizer = EWS:BoxSizer("HORIZONTAL")

	ctrl_sizer:add(EWS:StaticText(self._panel, name, "", "ALIGN_LEFT"), 0, 0, "EXPAND")

	local ctrl = EWS:TextCtrl(self._panel, value, "", "TE_PROCESS_ENTER")

	ctrl:set_tool_tip("Type in " .. type .. " " .. coor .. "-rotation in degrees")
	ctrl:set_min_size(Vector3(-1, 10, 0))
	ctrl:connect("EVT_CHAR", callback(nil, _G, "verify_number"), ctrl)

	if type == "offset" then
		ctrl:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "update_offset"), {
			ctrl = ctrl,
			coor = coor
		})
		ctrl:connect("EVT_KILL_FOCUS", callback(self, self, "update_offset"), {
			ctrl = ctrl,
			coor = coor
		})
	else
		ctrl:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "update_absolut"), {
			ctrl = ctrl,
			coor = coor
		})
		ctrl:connect("EVT_KILL_FOCUS", callback(self, self, "update_absolut"), {
			ctrl = ctrl,
			coor = coor
		})
	end

	ctrl_sizer:add(ctrl, 1, 0, "EXPAND")

	local spin = EWS:SpinButton(self._panel, "", "SP_VERTICAL")

	spin:set_min_size(Vector3(-1, 10, 0))

	local c = ctrl

	if type == "offset" then
		c = self["_a" .. coor]
	end

	spin:connect("EVT_SCROLL_LINEUP", callback(self, self, "update_spin"), {
		step = 0.1,
		ctrl = c,
		coor = coor
	})
	spin:connect("EVT_SCROLL_LINEDOWN", callback(self, self, "update_spin"), {
		step = -0.1,
		ctrl = c,
		coor = coor
	})
	ctrl_sizer:add(spin, 0, 0, "EXPAND")
	sizer:add(ctrl_sizer, 1, 10, "EXPAND,LEFT,RIGHT")

	return ctrl
end

function RotateTransformTypeIn:update_spin(data)
	if not tonumber(data.ctrl:get_value()) then
		data.ctrl:set_value(0)
	end

	data.ctrl:set_value(string.format("%.2f", data.ctrl:get_value() + data.step))
	self:update_absolut(data)
end

function RotateTransformTypeIn:update_absolut(data)
	local value = tonumber(data.ctrl:get_value()) or 0

	if self._min == value then
		return
	end

	if alive(self._unit) then
		local rot = self._unit:rotation()

		if data.coor == "x" then
			rot = Rotation(value, rot:pitch(), rot:roll())
		elseif data.coor == "y" then
			rot = Rotation(rot:yaw(), value, rot:roll())
		elseif data.coor == "z" then
			rot = Rotation(rot:yaw(), rot:pitch(), value)
		end

		data.ctrl:change_value(string.format("%.2f", value))
		data.ctrl:set_selection(-1, -1)
		managers.editor:set_selected_units_rotation(rot * self._unit:rotation():inverse())
	end
end

function RotateTransformTypeIn:update_offset(data, event)
	local value = tonumber(data.ctrl:get_value()) or 0

	if alive(self._unit) then
		local local_rot = managers.editor:is_coordinate_system("Local")
		local rot = Rotation()
		local rot_axis = rot[data.coor](rot)
		local u_rot = self._unit:rotation()

		if local_rot then
			rot_axis = u_rot[data.coor](u_rot)
		end

		rot = Rotation(rot_axis, value)

		managers.editor:set_selected_units_rotation(rot)
		data.ctrl:change_value(0)
		data.ctrl:set_selection(-1, -1)
	end
end

function RotateTransformTypeIn:set_unit(unit)
	self._unit = unit

	self._panel:set_enabled(alive(self._unit))
end

function RotateTransformTypeIn:update(t, dt)
	if alive(self._unit) then
		local rot = self._unit:rotation()

		if not self._ax:in_focus() then
			self._ax:change_value(string.format("%.2f", rot:yaw()))
		end

		if not self._ay:in_focus() then
			self._ay:change_value(string.format("%.2f", rot:pitch()))
		end

		if not self._az:in_focus() then
			self._az:change_value(string.format("%.2f", rot:roll()))
		end
	end
end

CameraTransformTypeIn = CameraTransformTypeIn or class(CoreEditorEwsDialog)

function CameraTransformTypeIn:init()
	CoreEditorEwsDialog.init(self, nil, "Camera transform type-in", "", Vector3(761, 180, 0), Vector3(264, 146, 0), "DEFAULT_DIALOG_STYLE,RESIZE_BORDER,STAY_ON_TOP")
	self:create_panel("VERTICAL")

	self._min = -100000000
	self._max = 100000000
	local pos_rot_sizer = EWS:BoxSizer("HORIZONTAL")
	local world_sizer = EWS:StaticBoxSizer(self._panel, "VERTICAL", "Absolut:World:Pos")
	self._ax = self:_create_ctrl("X:", "x", 0, "absolut", world_sizer)
	self._ay = self:_create_ctrl("Y:", "y", 0, "absolut", world_sizer)
	self._az = self:_create_ctrl("Z:", "z", 0, "absolut", world_sizer)

	pos_rot_sizer:add(world_sizer, 1, 0, "EXPAND")

	local offset_sizer = EWS:StaticBoxSizer(self._panel, "VERTICAL", "Absolut:World:Rot")
	self._ox = self:_create_ctrl("X:", "x", 0, "offset", offset_sizer)
	self._oy = self:_create_ctrl("Y:", "y", 0, "offset", offset_sizer)
	self._oz = self:_create_ctrl("Z:", "z", 0, "offset", offset_sizer)

	pos_rot_sizer:add(offset_sizer, 1, 0, "EXPAND")
	self._panel_sizer:add(pos_rot_sizer, 5, 0, "EXPAND")

	local settings_sizer = EWS:StaticBoxSizer(self._panel, "HORIZONTAL")

	self._panel_sizer:add(settings_sizer, 2, 0, "EXPAND")

	self._fov = self:_create_fov_ctrl(settings_sizer)
	self._far_range = self:_create_far_range_ctrl(settings_sizer)

	self._dialog_sizer:add(self._panel, 1, 0, "EXPAND")
	self._panel:set_enabled(true)
end

function CameraTransformTypeIn:_create_fov_ctrl(sizer)
	local ctrl_sizer = EWS:BoxSizer("HORIZONTAL")

	ctrl_sizer:add(EWS:StaticText(self._panel, "Fov:", "", "ALIGN_LEFT"), 0, 0, "ALIGN_CENTER_VERTICAL")

	local ctrl = EWS:TextCtrl(self._panel, 0, "", "TE_PROCESS_ENTER")

	ctrl:connect("EVT_CHAR", callback(nil, _G, "verify_number"), ctrl)
	ctrl:set_tool_tip("Type in fov")
	ctrl:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "update_fov"), nil)
	ctrl:connect("EVT_KILL_FOCUS", callback(self, self, "update_fov"), nil)
	ctrl_sizer:add(ctrl, 1, 0, "EXPAND")
	sizer:add(ctrl_sizer, 1, 10, "EXPAND,LEFT,RIGHT")

	return ctrl
end

function CameraTransformTypeIn:_create_far_range_ctrl(sizer)
	local ctrl_sizer = EWS:BoxSizer("HORIZONTAL")

	ctrl_sizer:add(EWS:StaticText(self._panel, "Far Range:", "", "ALIGN_LEFT"), 0, 0, "ALIGN_CENTER_VERTICAL")

	local ctrl = EWS:TextCtrl(self._panel, 0, "", "TE_PROCESS_ENTER")

	ctrl:connect("EVT_CHAR", callback(nil, _G, "verify_number"), ctrl)
	ctrl:set_tool_tip("Type in far range in meters")
	ctrl:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "update_far_range"), nil)
	ctrl:connect("EVT_KILL_FOCUS", callback(self, self, "update_far_range"), nil)
	ctrl_sizer:add(ctrl, 1, 0, "EXPAND")
	sizer:add(ctrl_sizer, 2, 10, "EXPAND,LEFT,RIGHT")

	return ctrl
end

function CameraTransformTypeIn:_create_ctrl(name, coor, value, type, sizer)
	local ctrl_sizer = EWS:BoxSizer("HORIZONTAL")

	ctrl_sizer:add(EWS:StaticText(self._panel, name, "", "ALIGN_LEFT"), 0, 0, "EXPAND")

	local ctrl = EWS:TextCtrl(self._panel, value, "", "TE_PROCESS_ENTER")

	ctrl:set_min_size(Vector3(-1, 10, 0))

	local spin = EWS:SpinButton(self._panel, "", "SP_VERTICAL")

	spin:set_min_size(Vector3(-1, 10, 0))
	ctrl:connect("EVT_CHAR", callback(nil, _G, "verify_number"), ctrl)

	if type == "offset" then
		ctrl:set_tool_tip("Type in absolut " .. coor .. "-rotation in degrees")
		ctrl:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "update_rotation"), {
			ctrl = ctrl,
			coor = coor
		})
		ctrl:connect("EVT_KILL_FOCUS", callback(self, self, "update_rotation"), {
			ctrl = ctrl,
			coor = coor
		})
		spin:connect("EVT_SCROLL_LINEUP", callback(self, self, "update_rotation_spin"), {
			step = 1,
			ctrl = ctrl,
			coor = coor
		})
		spin:connect("EVT_SCROLL_LINEDOWN", callback(self, self, "update_rotation_spin"), {
			step = -1,
			ctrl = ctrl,
			coor = coor
		})
	else
		ctrl:set_tool_tip("Type in absolut " .. coor .. "-coordinates in cm")
		ctrl:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "update_position"), {
			ctrl = ctrl,
			coor = coor
		})
		ctrl:connect("EVT_KILL_FOCUS", callback(self, self, "update_position"), {
			ctrl = ctrl,
			coor = coor
		})
		spin:connect("EVT_SCROLL_LINEUP", callback(self, self, "update_position_spin"), {
			step = 10,
			ctrl = ctrl,
			coor = coor
		})
		spin:connect("EVT_SCROLL_LINEDOWN", callback(self, self, "update_position_spin"), {
			step = -10,
			ctrl = ctrl,
			coor = coor
		})
	end

	ctrl_sizer:add(ctrl, 1, 0, "EXPAND")
	ctrl_sizer:add(spin, 0, 0, "EXPAND")
	sizer:add(ctrl_sizer, 1, 10, "EXPAND,LEFT,RIGHT")

	return ctrl
end

function CameraTransformTypeIn:update_position_spin(data)
	if not tonumber(data.ctrl:get_value()) then
		data.ctrl:set_value(0)
	end

	data.ctrl:set_value(string.format("%.0f", data.ctrl:get_value() + data.step))
	self:update_position(data)
end

function CameraTransformTypeIn:update_rotation_spin(data)
	if not tonumber(data.ctrl:get_value()) then
		data.ctrl:set_value(0)
	end

	data.ctrl:set_value(string.format("%.0f", data.ctrl:get_value() + data.step))
	self:update_rotation(data)
end

function CameraTransformTypeIn:update_position(data)
	local value = tonumber(data.ctrl:get_value()) or 0

	if self._min == value then
		return
	end

	local pos = managers.editor:camera_position()
	pos = pos["with_" .. data.coor](pos, value)

	data.ctrl:set_value(string.format("%.0f", value))
	data.ctrl:set_selection(-1, -1)
	managers.editor:set_camera(pos, managers.editor:camera_rotation())
end

function CameraTransformTypeIn:update_rotation(data)
	local value = tonumber(data.ctrl:get_value()) or 0

	if self._min == value then
		return
	end

	local rot = managers.editor:camera_rotation()

	if data.coor == "x" then
		rot = Rotation(value, rot:pitch(), rot:roll())
	elseif data.coor == "y" then
		rot = Rotation(rot:yaw(), value, rot:roll())
	elseif data.coor == "z" then
		rot = Rotation(rot:yaw(), rot:pitch(), value)
	end

	data.ctrl:set_value(string.format("%.0f", value))
	data.ctrl:set_selection(-1, -1)
	managers.editor:set_camera(managers.editor:camera_position(), rot)
end

function CameraTransformTypeIn:update_fov()
	local value = tonumber(self._fov:get_value()) or managers.editor:camera_fov()
	value = math.clamp(value, 1, 170)

	self._fov:set_value(string.format("%.0f", value))
	self._fov:set_selection(-1, -1)
	managers.editor:set_default_camera_fov(value)
end

function CameraTransformTypeIn:update_far_range()
	local value = tonumber(self._far_range:get_value()) or managers.editor:camera_far_range() / 100

	if value < 1 then
		value = 1
	end

	value = value * 100

	self._far_range:set_value(string.format("%.2f", value / 100))
	self._far_range:set_selection(-1, -1)
	managers.editor:set_camera_far_range(value)
end

function CameraTransformTypeIn:update(t, dt)
	local pos = managers.editor:camera_position()

	if not self._ax:in_focus() then
		self._ax:set_value(string.format("%.0f", pos.x))
	end

	if not self._ay:in_focus() then
		self._ay:set_value(string.format("%.0f", pos.y))
	end

	if not self._az:in_focus() then
		self._az:set_value(string.format("%.0f", pos.z))
	end

	local rot = managers.editor:camera_rotation()

	if not self._ox:in_focus() then
		self._ox:set_value(string.format("%.0f", rot:yaw()))
	end

	if not self._oy:in_focus() then
		self._oy:set_value(string.format("%.0f", rot:pitch()))
	end

	if not self._oz:in_focus() then
		self._oz:set_value(string.format("%.0f", rot:roll()))
	end

	if not self._fov:in_focus() then
		self._fov:change_value(string.format("%.0f", managers.editor:camera_fov()))
	end

	if not self._far_range:in_focus() then
		self._far_range:change_value(string.format("%.2f", managers.editor:camera_far_range() / 100))
	end
end

EditControllerBindings = EditControllerBindings or class(CoreEditorEwsDialog)

function EditControllerBindings:init(...)
	CoreEditorEwsDialog.init(self, nil, "Controller bindings", "", Vector3(300, 150, 0), Vector3(350, 500, 0), "DEFAULT_DIALOG_STYLE,RESIZE_BORDER,STAY_ON_TOP", ...)
	self:create_panel("VERTICAL")

	self._list = EWS:ListCtrl(self._panel, "", "LC_REPORT,LC_NO_HEADER")

	self._list:clear_all()
	self._list:append_column("Name")
	self._list:append_column("Key")
	self._panel_sizer:add(self._list, 1, 0, "EXPAND")
	self._list:append_item("Base:")
	self._list:append_item("")
	self:add_list(managers.editor:ctrl_bindings())
	self._list:append_item("")
	self._list:append_item("Layer:")
	self._list:append_item("")
	self:add_list(managers.editor:ctrl_layer_bindings())
	self._list:append_item("")
	self._list:append_item("Menu:")
	self._list:append_item("")
	self:add_list(managers.editor:ctrl_menu_bindings())

	for i = 0, self._list:column_count() - 1 do
		self._list:autosize_column(i)
	end

	self._list:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local button_sizer = EWS:BoxSizer("HORIZONTAL")
	local cancel_btn = EWS:Button(self._panel, "Cancel", "", "")

	button_sizer:add(cancel_btn, 0, 2, "RIGHT,LEFT")
	cancel_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_cancel"), "")
	cancel_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	self._panel_sizer:add(button_sizer, 0, 0, "ALIGN_RIGHT")
	self._dialog_sizer:add(self._panel, 1, 0, "EXPAND")
	self._dialog:set_visible(true)
end

function EditControllerBindings:add_list(list)
	local names = {}

	for name, _ in pairs(list) do
		table.insert(names, name)
	end

	table.sort(names)

	for _, name in ipairs(names) do
		local i = self._list:append_item(name)

		self._list:set_item(i, 1, list[name])
	end
end

MissionGraph = MissionGraph or class(CoreEditorEwsDialog)

function MissionGraph:init(...)
	CoreEditorEwsDialog.init(self, nil, "Mission Graph", "", Vector3(100, 100, 0), Vector3(800, 600, 0), "DEFAULT_DIALOG_STYLE,RESIZE_BORDER,,MINIMIZE_BOX,MAXIMIZE_BOX,STAY_ON_TOP", ...)
	self:create_panel("VERTICAL")

	self._graph = EWS:Graph()
	self._graph_view = EWS:GraphView(self._panel, "", self._graph)
	self._nodes = {}

	for _, unit in ipairs(managers.editor._layers.Mission:created_units()) do
		local node = EWS:Node(unit:unit_data().name_id, unit:position().x / 4, unit:position().y / 4 * -1)
		self._nodes[unit:unit_data().unit_id] = node

		self._graph:add_node(node)
	end

	for _, unit in ipairs(managers.editor._layers.Mission:created_units()) do
		local node = self._nodes[unit:unit_data().unit_id]

		for _, data in ipairs(unit:mission_element_data().on_executed) do
			local e_node = self._nodes[data.id]

			e_node:set_colour(0, 1, 0)
			node:set_target(node:free_slot(), e_node, "on_executed")
		end
	end

	self._graph_view:pan_to_selected(true)
	self._graph_view:refresh()
	self._panel_sizer:add(self._graph_view, 1, 0, "EXPAND")
	self._graph:notify_views()
	self._dialog_sizer:add(self._panel, 1, 0, "EXPAND")
	self._dialog:set_visible(true)
end

function MissionGraph:update(t, dt)
	self._graph_view:update_graph(dt)
	self._graph:notify_views()
end

WorldEditorNews = WorldEditorNews or class(CoreEditorEwsDialog)

function WorldEditorNews:init()
	CoreEditorEwsDialog.init(self, nil, "World editor news", "", Vector3(270, 130, 0), Vector3(560, 620, 0), "DEFAULT_DIALOG_STYLE,RESIZE_BORDER,STAY_ON_TOP")

	self._captions = {}

	table.insert(self._captions, "Great stuff man!")
	table.insert(self._captions, "Keep them coming")
	table.insert(self._captions, "I agree")
	table.insert(self._captions, "Acknowledged!")
	table.insert(self._captions, "Sweet!")
	table.insert(self._captions, "I understand what I have read")
	self:create_panel("VERTICAL")

	self._text = EWS:TextCtrl(self._panel, "", "", "TE_MULTILINE,TE_NOHIDESEL,TE_RICH2,TE_DONTWRAP,TE_READONLY")
	local file = SystemFS:open(managers.database:base_path() .. "core\\lib\\utils\\dev\\editor\\WorldEditorNews.txt", "r")
	local news = file:read("*a")

	self._text:set_value(news)
	self._panel_sizer:add(self._text, 1, 0, "EXPAND")
	self._text:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local button_sizer = EWS:BoxSizer("HORIZONTAL")
	self._cancel_btn = EWS:Button(self._panel, self._captions[math.random(#self._captions)], "", "")

	button_sizer:add(self._cancel_btn, 0, 2, "RIGHT,LEFT")
	self._cancel_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_cancel"), "")
	self._cancel_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	self._panel_sizer:add(button_sizer, 0, 0, "ALIGN_RIGHT")
	self._dialog_sizer:add(self._panel, 1, 0, "EXPAND")
	self._dialog:set_visible(true)
end

function WorldEditorNews:set_visible(visible)
	if visible then
		self._cancel_btn:set_caption(self._captions[math.random(#self._captions)])
		self._panel:layout()
	end

	CoreEditorEwsDialog.set_visible(self, visible)
end

function WorldEditorNews:version()
	return self._text:get_last_position()
end

UnitDuality = UnitDuality or class(CoreEditorEwsDialog)

function UnitDuality:create_panel(orientation)
	self._scrolled_window = EWS:ScrolledWindow(self._dialog, "", "VSCROLL")

	self._scrolled_window:set_scroll_rate(Vector3(0, 1, 0))
	self._scrolled_window:set_virtual_size_hints(Vector3(0, 0, 0), Vector3(1, -1, -1))

	self._scrolled_main_sizer = EWS:StaticBoxSizer(self._scrolled_window, "VERTICAL", "")

	self._scrolled_window:set_sizer(self._scrolled_main_sizer)
	self._dialog_sizer:add(self._scrolled_window, 1, 0, "EXPAND")

	self._panel = EWS:Panel(self._scrolled_window, "", "TAB_TRAVERSAL")
	self._panel_sizer = EWS:BoxSizer("HORIZONTAL")

	self._panel:set_sizer(self._panel_sizer)
end

function UnitDuality:init(collisions, pos)
	pos = pos or Vector3(120, 130, 0)

	CoreEditorEwsDialog.init(self, nil, "Unit Duality", "", pos, Vector3(760, 620, 0), "DEFAULT_DIALOG_STYLE,RESIZE_BORDER,STAY_ON_TOP")
	self:create_panel("VERTICAL")

	local complete_sizer = EWS:StaticBoxSizer(self._scrolled_window, "VERTICAL", "Collisions with both position and rotation")

	if #collisions.complete > 0 then
		for _, collision in ipairs(collisions.complete) do
			local col = self:build_collision(collision)

			if col then
				complete_sizer:add(col, 0, 0, "EXPAND")
			end
		end
	else
		complete_sizer:add(EWS:StaticText(self._scrolled_window, "No collisions found. Great!", 0, ""), 0, 5, "ALIGN_CENTER_HORIZONTAL,TOP,BOTTOM")
	end

	self._scrolled_main_sizer:add(complete_sizer, 0, 0, "EXPAND")

	local position_sizer = EWS:StaticBoxSizer(self._scrolled_window, "VERTICAL", "Collisions with only position")

	if #collisions.only_positions > 0 then
		for _, collision in ipairs(collisions.only_positions) do
			local col = self:build_collision(collision)

			if col then
				position_sizer:add(col, 0, 0, "EXPAND")
			end
		end
	else
		position_sizer:add(EWS:StaticText(self._scrolled_window, "No collisions found. Great!", 0, ""), 0, 5, "ALIGN_CENTER_HORIZONTAL,TOP,BOTTOM")
	end

	self._scrolled_main_sizer:add(position_sizer, 0, 0, "EXPAND")

	local button_sizer = EWS:BoxSizer("HORIZONTAL")
	self._check_btn = EWS:Button(self._scrolled_window, "Check Again", "", "")

	button_sizer:add(self._check_btn, 0, 2, "RIGHT,LEFT")
	self._check_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_check_again"), "")
	self._check_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	self._cancel_btn = EWS:Button(self._scrolled_window, "Close", "", "")

	button_sizer:add(self._cancel_btn, 0, 2, "RIGHT,LEFT")
	self._cancel_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_cancel"), "")
	self._cancel_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	self._scrolled_main_sizer:add(button_sizer, 0, 0, "ALIGN_RIGHT")
	self._dialog:set_visible(true)
end

function UnitDuality:build_collision(collision)
	local u1 = collision.u1
	local u2 = collision.u2
	local pos = collision.pos

	if not u1 or not u2 or not u1:unit_data() or not u2:unit_data() then
		return
	end

	local panel = EWS:Panel(self._scrolled_window, "", "TAB_TRAVERSAL")
	local sizer = EWS:BoxSizer("HORIZONTAL")

	panel:set_sizer(sizer)

	local text1 = EWS:TextCtrl(panel, u1:unit_data().name_id, "", "ALIGN_CENTER_HORIZONTAL,TE_READONLY")

	text1:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local del1 = EWS:Button(panel, "Del", "", "")

	del1:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "delete_unit"), {
		unit = u1,
		panel = panel,
		text = text1
	})
	del1:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local text2 = EWS:TextCtrl(panel, u2:unit_data().name_id, "", "ALIGN_CENTER_HORIZONTAL,TE_READONLY")

	text2:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local del2 = EWS:Button(panel, "Del", "", "")

	del2:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "delete_unit"), {
		unit = u2,
		panel = panel,
		text = text2
	})
	del2:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local text_pos = EWS:TextCtrl(panel, tostring(pos), "", "ALIGN_CENTER_HORIZONTAL,TE_READONLY")

	text_pos:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local goto = EWS:Button(panel, "Goto", "", "")

	goto:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "goto"), collision)
	goto:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	sizer:add(text1, 5, 0, "EXPAND")
	sizer:add(del1, 1, 5, "EXPAND,RIGHT")
	sizer:add(text2, 5, 0, "EXPAND")
	sizer:add(del2, 1, 5, "EXPAND,RIGHT")
	sizer:add(text_pos, 5, 0, "EXPAND")
	sizer:add(goto, 1, 0, "EXPAND")

	return panel
end

function UnitDuality:goto(collision)
	local u1 = collision.u1
	local u2 = collision.u2
	local pos = collision.pos

	if not alive(u1) then
		return
	end

	managers.editor:center_view_on_unit(u1)
end

function UnitDuality:delete_unit(data)
	if alive(data.unit) then
		managers.editor:delete_unit(data.unit)
	end

	data.text:set_value("DELETED")
	data.panel:set_enabled(false)
end

function UnitDuality:on_check_again()
	managers.editor:on_check_duality()
end

BrushLayerDebug = BrushLayerDebug or class(CoreEditorEwsDialog)

function BrushLayerDebug:init(...)
	CoreEditorEwsDialog.init(self, nil, "Brush layer debug", "", Vector3(300, 150, 0), Vector3(600, 400, 0), "DEFAULT_DIALOG_STYLE,RESIZE_BORDER", ...)
	self:create_panel("VERTICAL")

	self._column_states = {}

	table.insert(self._column_states, {
		value = "name",
		state = "ascending"
	})
	table.insert(self._column_states, {
		value = "amount",
		state = "random"
	})

	local toolbar_sizer = EWS:BoxSizer("VERTICAL")

	self._panel_sizer:add(toolbar_sizer, 0, 0, "EXPAND")

	local toolbar = EWS:ToolBar(self._panel, "", "TB_FLAT,TB_NODIVIDER")

	toolbar:add_tool("DELETE", "Delete", CoreEws.image_path("toolbar\\delete_16x16.png"), nil)
	toolbar:connect("DELETE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_gui_delete"), nil)
	toolbar:add_tool("HELP", "Help", CoreEws.image_path("help_16x16.png"), nil)
	toolbar:connect("HELP", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_gui_help"), nil)
	toolbar:realize()
	toolbar_sizer:add(toolbar, 0, 0, "EXPAND,LEFT")

	local selected_sizer = EWS:BoxSizer("VERTICAL")

	self._panel_sizer:add(selected_sizer, 1, 0, "EXPAND")

	self._unit_list = EWS:ListCtrl(self._panel, "", "LC_REPORT,LC_SORT_ASCENDING,NO_BORDER")

	self._unit_list:clear_all()
	self._unit_list:append_column("Name")
	self._unit_list:append_column("Amount")
	selected_sizer:add(self._unit_list, 1, 0, "EXPAND")
	self._unit_list:connect("EVT_COMMAND_LIST_ITEM_RIGHT_CLICK", callback(self, self, "_right_clicked"), self._unit_list)
	self._unit_list:connect("EVT_COMMAND_LIST_ITEM_ACTIVATED", callback(self, self, "_on_select_unit"), nil)
	self._unit_list:connect("EVT_COMMAND_LIST_COL_CLICK", callback(self, self, "column_click_list"), nil)
	self._unit_list:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local button_sizer = EWS:BoxSizer("HORIZONTAL")
	local close_btn = EWS:Button(self._panel, "Close", "", "")

	button_sizer:add(close_btn, 0, 2, "RIGHT,LEFT")
	close_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_cancel"), "")
	close_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	self._panel_sizer:add(button_sizer, 0, 0, "ALIGN_RIGHT")
	self._dialog_sizer:add(self._panel, 1, 0, "EXPAND")
	self._dialog:set_visible(true)
	self:fill_unit_list()
end

function BrushLayerDebug:_toolbar_toggle(params, event)
	self[params.value] = params.toolbar:tool_state(event:get_id())
end

function BrushLayerDebug:_on_gui_delete()
	local current_data = self:_current_data()

	print(inspect(current_data))
	print(current_data and current_data.name)

	if current_data then
		managers.editor:layer("Brush"):clear_units_by_name(current_data.name)
	end
end

function BrushLayerDebug:_on_gui_help()
	local text = "Since brush units are not always visible, this dialog shows actual amount of units in the level."
	text = text .. "\n\nSorting can be done by clicking the column namnes."
	text = text .. "\n\nDelete all units with a certain name by clicking the delete icon on toolbar."

	EWS:message_box(self._panel, text, "Help", "OK", Vector3())
end

function BrushLayerDebug:fill_unit_list()
	self:freeze()
	self._unit_list:delete_all_items()

	local brush_stats = managers.editor:layer("Brush"):get_brush_stats()

	for _, stats in ipairs(brush_stats) do
		local i = self._unit_list:append_item(stats.unit_name:s())

		self._unit_list:set_item(i, 1, "" .. stats.amount)
		self._unit_list:set_item_data(i, {
			name = stats.unit_name:s(),
			amount = stats.amount
		})
	end

	self:_autosize_columns(self._unit_list)
	self:thaw()
end

function BrushLayerDebug:_autosize_columns(list)
	for i = 0, list:column_count() - 1 do
		list:autosize_column(i)
	end
end

function BrushLayerDebug:key_cancel(ctrlr, event)
	event:skip()

	if EWS:name_to_key_code("K_ESCAPE") == event:key_code() then
		self:on_cancel()
	end
end

function BrushLayerDebug:_on_select_unit()
	local current_data = self:_current_data()

	if current_data and current_data.unit and self._use_look_at then
		managers.editor:look_towards_unit(current_data.unit)
	end
end

function BrushLayerDebug:column_click_list(...)
	self._list = self._unit_list

	UnitList.column_click_list(self, ...)
end

function BrushLayerDebug:_right_clicked(list)
	local item_data = self:_selected_list_data(list)
end

function BrushLayerDebug:_current_data()
	local index = self._unit_list:selected_item()

	if index == -1 then
		return
	end

	return self._unit_list:get_item_data_ref(index)
end

function BrushLayerDebug:_selected_list_data(list)
	local index = list:selected_item()

	if index == -1 then
		return
	end

	return list:get_item_data_ref(index)
end

function BrushLayerDebug:reset()
end

function BrushLayerDebug:freeze()
	self._unit_list:freeze()
end

function BrushLayerDebug:thaw()
	self._unit_list:thaw()
end
