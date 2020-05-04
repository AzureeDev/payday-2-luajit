UnitByName = UnitByName or class(CoreEditorEwsDialog)

function UnitByName:init(name, unit_filter_function, ...)
	self._dialog_name = self._dialog_name or name or "UnitByName"
	self._unit_filter_function = unit_filter_function

	CoreEditorEwsDialog.init(self, nil, self._dialog_name, "", Vector3(300, 150, 0), Vector3(350, 500, 0), "DEFAULT_DIALOG_STYLE,RESIZE_BORDER", ...)
	self:create_panel("VERTICAL")

	local panel = self._panel
	local panel_sizer = self._panel_sizer

	panel:set_sizer(panel_sizer)

	local horizontal_ctrlr_sizer = EWS:BoxSizer("HORIZONTAL")
	local list_sizer = EWS:BoxSizer("VERTICAL")

	list_sizer:add(EWS:StaticText(panel, "Filter", 0, ""), 0, 0, "ALIGN_CENTER_HORIZONTAL")

	self._filter = EWS:TextCtrl(panel, "", "", "TE_CENTRE")

	list_sizer:add(self._filter, 0, 0, "EXPAND")
	self._filter:connect("EVT_COMMAND_TEXT_UPDATED", callback(self, self, "update_filter"), nil)
	self._filter:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	self._filter:connect("EVT_UPDATE_UI", callback(self, self, "update"), nil)

	self._list = EWS:ListCtrl(panel, "", self.STYLE or "LC_REPORT,LC_NO_HEADER,LC_SORT_ASCENDING")

	self._list:clear_all()
	self._list:append_column("Name")
	self._list:autosize_column(0)
	list_sizer:add(self._list, 1, 0, "EXPAND")
	horizontal_ctrlr_sizer:add(list_sizer, 3, 0, "EXPAND")

	local list_ctrlrs = EWS:BoxSizer("VERTICAL")
	local filter_type_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "Filter By Type")

	list_ctrlrs:add(filter_type_sizer, 0, 0, "EXPAND")

	self._filter_buttons = {}

	local function add_filter_button(id, name)
		self._filter_buttons[id] = EWS:RadioButton(panel, name, "filter_type", "")

		filter_type_sizer:add(self._filter_buttons[id], 0, 0, "")
	end

	add_filter_button("by_name_id", "Name ID")
	add_filter_button("by_unit_name", "Unit name")
	add_filter_button("by_unit_id", "Unit ID")
	self._filter_buttons.by_name_id:set_value(true)
	panel:connect("filter_type", "EVT_COMMAND_RADIOBUTTON_SELECTED", callback(self, self, "_on_set_filter"), nil)

	self._layer_cbs = {}
	local layers_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "List Layers")
	local layers = managers.editor:layers()
	local names_layers = {}

	for name, layer in pairs(layers) do
		table.insert(names_layers, name)
	end

	table.sort(names_layers)

	for _, name in ipairs(names_layers) do
		local cb = EWS:CheckBox(panel, name, "")

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
	local all_btn = EWS:Button(panel, "All", "", "BU_EXACTFIT,NO_BORDER")

	layer_buttons_sizer:add(all_btn, 0, 2, "TOP,BOTTOM")
	all_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_all_layers"), "")
	all_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local none_btn = EWS:Button(panel, "None", "", "BU_EXACTFIT,NO_BORDER")

	layer_buttons_sizer:add(none_btn, 0, 2, "TOP,BOTTOM")
	none_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_none_layers"), "")
	none_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local invert_btn = EWS:Button(panel, "Invert", "", "BU_EXACTFIT,NO_BORDER")

	layer_buttons_sizer:add(invert_btn, 0, 2, "TOP,BOTTOM")
	invert_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_invert_layers"), "")
	invert_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	layers_sizer:add(layer_buttons_sizer, 0, 2, "TOP,BOTTOM")
	list_ctrlrs:add(layers_sizer, 0, 2, "EXPAND,TOP")
	horizontal_ctrlr_sizer:add(list_ctrlrs, 2, 5, "EXPAND,LEFT")
	panel_sizer:add(horizontal_ctrlr_sizer, 1, 0, "EXPAND")
	self._list:connect("EVT_COMMAND_LIST_ITEM_SELECTED", callback(self, self, "_on_mark_unit"), nil)
	self._list:connect("EVT_COMMAND_LIST_ITEM_ACTIVATED", callback(self, self, "_on_select_unit"), nil)
	self._list:connect("EVT_CHAR", callback(self, self, "key_delete"), "")
	self._list:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	self._list:set_min_size(Vector3(-1, 405, 0))

	local button_sizer = EWS:BoxSizer("HORIZONTAL")

	self:_build_buttons(panel, button_sizer)
	panel_sizer:add(button_sizer, 0, 0, "ALIGN_RIGHT")
	self._dialog_sizer:add(self._panel, 1, 0, "EXPAND")
	self:fill_unit_list()
	self._dialog:fit(self._panel)
	self._dialog:set_visible(true)
end

function UnitByName:_build_buttons(panel, sizer)
	local cancel_btn = EWS:Button(panel, "Cancel", "", "")

	sizer:add(cancel_btn, 0, 2, "RIGHT,LEFT")
	cancel_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_cancel"), "")
	cancel_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
end

function UnitByName:_on_set_filter()
	self:fill_unit_list()
end

function UnitByName:_get_filter_type()
	for name, ctrlr in pairs(self._filter_buttons) do
		if ctrlr:get_value() then
			return name
		end
	end
end

function UnitByName:on_all_layers()
	for name, cb in pairs(self._layer_cbs) do
		cb:set_value(true)
	end

	self:fill_unit_list()
end

function UnitByName:on_none_layers()
	for name, cb in pairs(self._layer_cbs) do
		cb:set_value(false)
	end

	self:fill_unit_list()
end

function UnitByName:on_invert_layers()
	for name, cb in pairs(self._layer_cbs) do
		cb:set_value(not cb:get_value())
	end

	self:fill_unit_list()
end

function UnitByName:key_delete(ctrlr, event)
	event:skip()

	if EWS:name_to_key_code("K_DELETE") == event:key_code() then
		self:_on_delete()
	end
end

function UnitByName:key_cancel(ctrlr, event)
	event:skip()

	if EWS:name_to_key_code("K_ESCAPE") == event:key_code() then
		self:on_cancel()
	end
end

function UnitByName:on_layer_cb(data)
	self:fill_unit_list()
end

function UnitByName:on_cancel()
	self._dialog:set_visible(false)
end

function UnitByName:_on_delete()
end

function UnitByName:_on_mark_unit()
end

function UnitByName:_on_select_unit()
end

function UnitByName:_selected_item_units()
	if self._cancelled then
		return {}
	end

	local units = {}

	for _, i in ipairs(self._list:selected_items()) do
		local unit = self._units[self._list:get_item_data(i)]

		if not self:_continent_locked(unit) then
			table.insert(units, unit)
		end
	end

	return units
end

function UnitByName:_selected_item_unit()
	local index = self._list:selected_item()

	if index ~= -1 then
		return self._units[self._list:get_item_data(index)]
	end
end

function UnitByName:deleted_unit(unit)
	for i = 0, self._list:item_count() - 1 do
		if self._units[self._list:get_item_data(i)] == unit then
			self._list:delete_item(i)

			return
		end
	end
end

function UnitByName:spawned_unit(unit)
	local i = self._list:append_item(unit:unit_data().name_id)
	local j = #self._units + 1
	self._units[j] = unit

	self._list:set_item_data(i, j)
end

function UnitByName:selected_unit(unit)
	for _, i in ipairs(self._list:selected_items()) do
		self._list:set_item_selected(i, false)
	end

	for i = 0, self._list:item_count() - 1 do
		if self._units[self._list:get_item_data(i)] == unit then
			self._list:set_item_selected(i, true)
			self._list:ensure_visible(i)

			return
		end
	end
end

function UnitByName:selected_units(units)
	if self._blocked then
		return
	end

	self._list:freeze()

	for _, i in ipairs(self._list:selected_items()) do
		self._list:set_item_selected(i, false)
	end

	local ukeys = {}

	for _, unit in ipairs(units) do
		ukeys[unit:key()] = unit
	end

	local ensure_visible_key = #units > 0 and units[#units]:key()

	for i = 0, self._list:item_count() - 1 do
		local ukey = self._units[self._list:get_item_data(i)]:key()

		if ukeys[ukey] then
			self._list:set_item_selected(i, true)

			if ukey == ensure_visible_key then
				self._list:ensure_visible(i)
			end
		end
	end

	self._list:thaw()
end

function UnitByName:unit_name_changed(unit)
	for i = 0, self._list:item_count() - 1 do
		if self._units[self._list:get_item_data(i)] == unit then
			self._list:set_item(i, 0, unit:unit_data().name_id)

			local sort = false

			if i - 1 >= 0 then
				local over = self._units[self._list:get_item_data(i - 1)]:unit_data().name_id
				sort = sort or unit:unit_data().name_id < over
			end

			if i + 1 < self._list:item_count() then
				local under = self._units[self._list:get_item_data(i + 1)]:unit_data().name_id
				sort = sort or under < unit:unit_data().name_id
			end

			if sort then
				self:fill_unit_list()

				for i = 0, self._list:item_count() - 1 do
					if self._units[self._list:get_item_data(i)] == unit then
						self._list:set_item_selected(i, true)
						self._list:ensure_visible(i)

						break
					end
				end
			end

			break
		end
	end
end

function UnitByName:update()
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
		local i = self._list:append_item(data.name)

		self._list:set_item_data(i, data.id)
		self._list:set_item_text_colour(i, data.colour)
	end

	if #self._units_to_append == 0 then
		self._units_to_append = nil

		self._list:autosize_column(0)
	end
end

function UnitByName:update_filter()
	self:fill_unit_list()
end

function UnitByName:fill_unit_list()
	self._list:delete_all_items()

	local layers = managers.editor:layers()
	local j = 1
	local filter = self._filter:get_value()
	filter = utf8.to_lower(utf8.from_latin1(filter))
	self._units = {}
	self._units_to_append = {}

	for name, layer in pairs(layers) do
		if self._layer_cbs[name]:get_value() then
			for _, unit in ipairs(layer:created_units()) do
				if string.find(utf8.to_lower(utf8.from_latin1(self:_get_filter_string(unit))), filter, 1, true) and self:_unit_condition(unit) then
					self._units[j] = unit
					local colour = self:_continent_locked(unit) and Vector3(0.75, 0.75, 0.75) or Vector3(0, 0, 0)

					table.insert(self._units_to_append, {
						name = unit:unit_data().name_id,
						id = j,
						colour = colour
					})

					j = j + 1
				end
			end
		end
	end

	table.sort(self._units_to_append, function (a, b)
		return a.name < b.name
	end)
end

function UnitByName:_get_filter_string(unit)
	local filter = self:_get_filter_type()

	if filter == "by_unit_id" then
		return unit:unit_data().unit_id
	end

	if filter == "by_unit_name" then
		return unit:name():s()
	end

	if filter == "by_name_id" then
		return unit:unit_data().name_id
	end
end

function UnitByName:_continent_locked(unit)
	local continent = unit:unit_data().continent

	if not continent then
		return false
	end

	return unit:unit_data().continent:value("locked")
end

function UnitByName:_unit_condition(unit)
	if self._unit_filter_function then
		return self._unit_filter_function(unit)
	end

	return not unit:unit_data().instance
end

function UnitByName:reset()
	self:fill_unit_list()
end

function UnitByName:freeze()
	self._list:freeze()
end

function UnitByName:thaw()
	self._list:thaw()
end
