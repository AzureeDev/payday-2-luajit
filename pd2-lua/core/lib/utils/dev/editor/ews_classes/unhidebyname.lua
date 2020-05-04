UnhideByName = UnhideByName or class(CoreEditorEwsDialog)

function UnhideByName:init(...)
	CoreEditorEwsDialog.init(self, nil, self.TITLE or "Unhide by name", "", Vector3(300, 150, 0), Vector3(350, 500, 0), "DEFAULT_DIALOG_STYLE,RESIZE_BORDER", ...)
	self:create_panel("VERTICAL")

	local horizontal_ctrlr_sizer = EWS:BoxSizer("HORIZONTAL")
	local list_sizer = EWS:BoxSizer("VERTICAL")

	list_sizer:add(EWS:StaticText(self._panel, "Filter", 0, ""), 0, 0, "ALIGN_CENTER_HORIZONTAL")

	self._filter = EWS:TextCtrl(self._panel, "", "", "TE_CENTRE")

	list_sizer:add(self._filter, 0, 0, "EXPAND")
	self._filter:connect("EVT_COMMAND_TEXT_UPDATED", callback(self, self, "update_filter"), nil)

	self._list = EWS:ListCtrl(self._panel, "", "LC_REPORT,LC_NO_HEADER,LC_SORT_ASCENDING")

	self._list:clear_all()
	self._list:append_column("Name")
	list_sizer:add(self._list, 1, 0, "EXPAND")
	horizontal_ctrlr_sizer:add(list_sizer, 3, 0, "EXPAND")

	local list_ctrlrs = EWS:BoxSizer("VERTICAL")
	self._layer_cbs = {}
	local layers_sizer = EWS:StaticBoxSizer(self._panel, "VERTICAL", "List Layers")
	local layers = managers.editor:layers()
	local names_layers = {}

	for name, layer in pairs(layers) do
		table.insert(names_layers, name)
	end

	table.sort(names_layers)

	for _, name in ipairs(names_layers) do
		local cb = EWS:CheckBox(self._panel, name, "")

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
	local all_btn = EWS:Button(self._panel, "All", "", "BU_EXACTFIT,NO_BORDER")

	layer_buttons_sizer:add(all_btn, 0, 2, "TOP,BOTTOM")
	all_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_all_layers"), "")
	all_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local none_btn = EWS:Button(self._panel, "None", "", "BU_EXACTFIT,NO_BORDER")

	layer_buttons_sizer:add(none_btn, 0, 2, "TOP,BOTTOM")
	none_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_none_layers"), "")
	none_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local invert_btn = EWS:Button(self._panel, "Invert", "", "BU_EXACTFIT,NO_BORDER")

	layer_buttons_sizer:add(invert_btn, 0, 2, "TOP,BOTTOM")
	invert_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_invert_layers"), "")
	invert_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	layers_sizer:add(layer_buttons_sizer, 0, 2, "TOP,BOTTOM")
	list_ctrlrs:add(layers_sizer, 0, 30, "EXPAND,TOP")

	local continents_sizer = EWS:StaticBoxSizer(self._panel, "VERTICAL", "Continents")
	self._continents_sizer = EWS:BoxSizer("VERTICAL")

	self:build_continent_cbs()
	continents_sizer:add(self._continents_sizer, 0, 2, "TOP,BOTTOM")
	list_ctrlrs:add(continents_sizer, 0, 5, "EXPAND,TOP")

	local continent_buttons_sizer = EWS:BoxSizer("HORIZONTAL")
	local continent_all_btn = EWS:Button(self._panel, "All", "", "BU_EXACTFIT,NO_BORDER")

	continent_buttons_sizer:add(continent_all_btn, 0, 2, "TOP,BOTTOM")
	continent_all_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_all_continents"), "")
	continent_all_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local continent_none_btn = EWS:Button(self._panel, "None", "", "BU_EXACTFIT,NO_BORDER")

	continent_buttons_sizer:add(continent_none_btn, 0, 2, "TOP,BOTTOM")
	continent_none_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_none_continents"), "")
	continent_none_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local continent_invert_btn = EWS:Button(self._panel, "Invert", "", "BU_EXACTFIT,NO_BORDER")

	continent_buttons_sizer:add(continent_invert_btn, 0, 2, "TOP,BOTTOM")
	continent_invert_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_invert_continents"), "")
	continent_invert_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	continents_sizer:add(continent_buttons_sizer, 0, 2, "TOP,BOTTOM")
	horizontal_ctrlr_sizer:add(list_ctrlrs, 2, 0, "EXPAND")
	self._panel_sizer:add(horizontal_ctrlr_sizer, 1, 0, "EXPAND")
	self._list:connect("EVT_COMMAND_LIST_ITEM_SELECTED", callback(self, self, "on_mark_unit"), nil)
	self._list:connect("EVT_COMMAND_LIST_ITEM_ACTIVATED", callback(self, self, "on_unhide"), nil)
	self._list:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local button_sizer = EWS:BoxSizer("HORIZONTAL")
	local unhide_btn = EWS:Button(self._panel, self.BTN_NAME or "Unhide", "", "BU_BOTTOM")

	button_sizer:add(unhide_btn, 0, 2, "RIGHT,LEFT")
	unhide_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_unhide"), "")
	unhide_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local cancel_btn = EWS:Button(self._panel, "Cancel", "", "")

	button_sizer:add(cancel_btn, 0, 2, "RIGHT,LEFT")
	cancel_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_cancel"), "")
	cancel_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	self._panel_sizer:add(button_sizer, 0, 0, "ALIGN_RIGHT")
	self._dialog_sizer:add(self._panel, 1, 0, "EXPAND")
	self:fill_unit_list()
	self._dialog:set_visible(true)
end

function UnhideByName:build_continent_cbs()
	self._continents_cbs = {}
	local continents = managers.editor:continents()
	self._continent_names = {}

	for name, continent in pairs(continents) do
		table.insert(self._continent_names, name)
	end

	table.sort(self._continent_names)

	for _, name in ipairs(self._continent_names) do
		local cb = EWS:CheckBox(self._panel, name, "")

		cb:set_value(true)

		self._continents_cbs[name] = cb

		cb:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "on_continent_cb"), {
			cb = cb,
			name = name
		})
		cb:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
		self._continents_sizer:add(cb, 0, 2, "EXPAND,TOP")
	end
end

function UnhideByName:on_continent_cb()
	self:fill_unit_list()
end

function UnhideByName:on_all_layers()
	for name, cb in pairs(self._layer_cbs) do
		cb:set_value(true)
	end

	self:fill_unit_list()
end

function UnhideByName:on_none_layers()
	for name, cb in pairs(self._layer_cbs) do
		cb:set_value(false)
	end

	self:fill_unit_list()
end

function UnhideByName:on_invert_layers()
	for name, cb in pairs(self._layer_cbs) do
		cb:set_value(not cb:get_value())
	end

	self:fill_unit_list()
end

function UnhideByName:on_all_continents()
	for name, cb in pairs(self._continents_cbs) do
		cb:set_value(true)
	end

	self:fill_unit_list()
end

function UnhideByName:on_none_continents()
	for name, cb in pairs(self._continents_cbs) do
		cb:set_value(false)
	end

	self:fill_unit_list()
end

function UnhideByName:on_invert_continents()
	for name, cb in pairs(self._continents_cbs) do
		cb:set_value(not cb:get_value())
	end

	self:fill_unit_list()
end

function UnhideByName:key_cancel(ctrlr, event)
	event:skip()

	if EWS:name_to_key_code("K_ESCAPE") == event:key_code() then
		self:on_cancel()
	end
end

function UnhideByName:on_layer_cb(data)
	self:fill_unit_list()
end

function UnhideByName:on_cancel()
	self._dialog:set_visible(false)
end

function UnhideByName:on_unhide()
	managers.editor:freeze_gui_lists()

	for _, unit in ipairs(self:_selected_item_units()) do
		if self.IS_HIDE_BY_NAME then
			managers.editor:set_unit_visible(unit, false)
		else
			managers.editor:set_unit_visible(unit, true)
		end
	end

	managers.editor:thaw_gui_lists()
end

function UnhideByName:on_delete()
	managers.editor:freeze_gui_lists()

	for _, unit in ipairs(self:_selected_item_units()) do
		managers.editor:delete_unit(unit)
	end

	managers.editor:thaw_gui_lists()
end

function UnhideByName:on_mark_unit()
end

function UnhideByName:_selected_item_units()
	local units = {}

	for _, i in ipairs(self._list:selected_items()) do
		local unit = self._units[self._list:get_item_data(i)]

		table.insert(units, unit)
	end

	return units
end

function UnhideByName:_selected_item_unit()
	local index = self._list:selected_item()

	if index ~= -1 then
		return self._units[self._list:get_item_data(index)]
	end
end

function UnhideByName:select_unit(unit)
	managers.editor:select_unit(unit)
end

function UnhideByName:hid_unit(unit)
	self:_append_unit_to_list(unit)
end

function UnhideByName:_append_unit_to_list(unit)
	local i = self._list:append_item(unit:unit_data().name_id)
	local j = #self._units + 1
	self._units[j] = unit

	self._list:set_item_data(i, j)
end

function UnhideByName:unhid_unit(unit)
	self:_remove_unit_from_list(unit)
end

function UnhideByName:_remove_unit_from_list(unit)
	for i = 0, self._list:item_count() - 1 do
		if self._units[self._list:get_item_data(i)] == unit then
			self._list:delete_item(i)

			return
		end
	end
end

function UnhideByName:unit_name_changed(unit)
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

function UnhideByName:update_filter()
	self:fill_unit_list()
end

function UnhideByName:fill_unit_list()
	self._list:freeze()
	self._list:delete_all_items()

	local layers = managers.editor:layers()
	local j = 1
	local filter = self._filter:get_value()
	self._units = {}
	local hidden = {}

	for _, unit in ipairs(managers.editor:hidden_units()) do
		hidden[unit:key()] = unit
	end

	for name, layer in pairs(layers) do
		if self._layer_cbs[name]:get_value() then
			for _, unit in ipairs(layer:created_units()) do
				if self:_continent_ok(unit) and (not self.IS_HIDE_BY_NAME and hidden[unit:key()] or self.IS_HIDE_BY_NAME and not hidden[unit:key()]) and string.find(unit:unit_data().name_id, filter, 1, true) then
					local i = self._list:append_item(unit:unit_data().name_id)
					self._units[j] = unit

					self._list:set_item_data(i, j)

					j = j + 1
				end
			end
		end
	end

	self._list:autosize_column(0)
	self._list:thaw()
end

function UnhideByName:_continent_ok(unit)
	local continent = unit:unit_data().continent

	if not continent then
		return true
	end

	return self._continents_cbs[continent:name()] and self._continents_cbs[continent:name()]:get_value()
end

function UnhideByName:reset()
	self:fill_unit_list()
end

function UnhideByName:freeze()
	self._list:freeze()
end

function UnhideByName:thaw()
	self._list:thaw()
end

function UnhideByName:recreate()
	for name, cb in pairs(self._continents_cbs) do
		self._continents_sizer:detach(cb)
		cb:destroy()
	end

	self:build_continent_cbs()
	self:fill_unit_list()
	self._panel:layout()
end

HideByName = HideByName or class(UnhideByName)
HideByName.TITLE = "Hide by Name"
HideByName.BTN_NAME = "Hide"
HideByName.IS_HIDE_BY_NAME = true

function HideByName:init(...)
	HideByName.super.init(self, ...)
end

function HideByName:hid_unit(unit)
	self:_remove_unit_from_list(unit)
end

function HideByName:unhid_unit(unit)
	self:_append_unit_to_list(unit)
end

function HideByName:spawned_unit(unit)
	self:_append_unit_to_list(unit)
end

function HideByName:deleted_unit(unit)
	self:_remove_unit_from_list(unit)
end
