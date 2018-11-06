SelectWorkView = SelectWorkView or class(CoreEditorEwsDialog)

function SelectWorkView:init(...)
	CoreEditorEwsDialog.init(self, nil, "Workviews", "", Vector3(300, 150, 0), Vector3(350, 500, 0), "DEFAULT_DIALOG_STYLE,RESIZE_BORDER,STAY_ON_TOP", ...)
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
	local continents_sizer = EWS:StaticBoxSizer(self._panel, "VERTICAL", "Continents")
	self._continents_sizer = EWS:BoxSizer("VERTICAL")

	self:build_cbs()
	continents_sizer:add(self._continents_sizer, 0, 2, "TOP,BOTTOM")
	list_ctrlrs:add(continents_sizer, 0, 30, "EXPAND,TOP")

	local layer_buttons_sizer = EWS:BoxSizer("HORIZONTAL")
	local all_btn = EWS:Button(self._panel, "All", "", "BU_EXACTFIT,NO_BORDER")

	layer_buttons_sizer:add(all_btn, 0, 2, "TOP,BOTTOM")
	all_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_all_continents"), "")
	all_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local none_btn = EWS:Button(self._panel, "None", "", "BU_EXACTFIT,NO_BORDER")

	layer_buttons_sizer:add(none_btn, 0, 2, "TOP,BOTTOM")
	none_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_none_continents"), "")
	none_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local invert_btn = EWS:Button(self._panel, "Invert", "", "BU_EXACTFIT,NO_BORDER")

	layer_buttons_sizer:add(invert_btn, 0, 2, "TOP,BOTTOM")
	invert_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_invert_continents"), "")
	invert_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	continents_sizer:add(layer_buttons_sizer, 0, 2, "TOP,BOTTOM")
	horizontal_ctrlr_sizer:add(list_ctrlrs, 2, 0, "EXPAND")
	self._panel_sizer:add(horizontal_ctrlr_sizer, 3, 0, "EXPAND")
	self._list:connect("EVT_COMMAND_LIST_ITEM_SELECTED", callback(self, self, "on_mark_view"), nil)
	self._list:connect("EVT_COMMAND_LIST_ITEM_ACTIVATED", callback(self, self, "on_select_view"), nil)
	self._list:connect("EVT_KEY_DOWN", callback(self, self, "key_delete"), "")
	self._list:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	self._info_ctrlr = EWS:TextCtrl(self._panel, "", "", "TE_PROCESS_ENTER,TE_MULTILINE,TE_WORDWRAP")

	self._info_ctrlr:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "on_set_info"), nil)
	self._info_ctrlr:connect("EVT_KILL_FOCUS", callback(self, self, "on_set_info"), nil)
	self._panel_sizer:add(self._info_ctrlr, 1, 0, "EXPAND")

	local button_sizer = EWS:BoxSizer("HORIZONTAL")
	local goto_btn = EWS:Button(self._panel, "Goto", "", "BU_BOTTOM")

	button_sizer:add(goto_btn, 0, 2, "RIGHT,LEFT")
	goto_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_goto"), "")
	goto_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local add_btn = EWS:Button(self._panel, "Add", "", "BU_BOTTOM")

	button_sizer:add(add_btn, 0, 2, "RIGHT,LEFT")
	add_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_add"), "")
	add_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local delete_btn = EWS:Button(self._panel, "Delete", "", "BU_BOTTOM")

	button_sizer:add(delete_btn, 0, 2, "RIGHT,LEFT")
	delete_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_delete"), "")
	delete_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local cancel_btn = EWS:Button(self._panel, "Cancel", "", "")

	button_sizer:add(cancel_btn, 0, 2, "RIGHT,LEFT")
	cancel_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_cancel"), "")
	cancel_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	self._panel_sizer:add(button_sizer, 0, 0, "ALIGN_RIGHT")
	self._dialog_sizer:add(self._panel, 1, 0, "EXPAND")
	self:fill_views_list()
	self._dialog:set_visible(true)
end

function SelectWorkView:build_cbs()
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

function SelectWorkView:key_delete(ctrlr, event)
	event:skip()

	if EWS:name_to_key_code("K_DELETE") == event:key_code() then
		self:on_delete()
	end
end

function SelectWorkView:key_cancel(ctrlr, event)
	event:skip()

	if EWS:name_to_key_code("K_ESCAPE") == event:key_code() then
		self:on_cancel()
	end
end

function SelectWorkView:on_continent_cb()
	self:fill_views_list()
end

function SelectWorkView:on_all_continents()
	for name, cb in pairs(self._continents_cbs) do
		cb:set_value(true)
	end

	self:fill_views_list()
end

function SelectWorkView:on_none_continents()
	for name, cb in pairs(self._continents_cbs) do
		cb:set_value(false)
	end

	self:fill_views_list()
end

function SelectWorkView:on_invert_continents()
	for name, cb in pairs(self._continents_cbs) do
		cb:set_value(not cb:get_value())
	end

	self:fill_views_list()
end

function SelectWorkView:on_delete()
	local index = self._list:selected_item()

	if index == -1 then
		return
	end

	local j = self._list:get_item_data_ref(index)
	local continent = self._views[j].continent
	local view_name = self._views[j].name

	managers.editor:delete_workview(continent, view_name)
	self:fill_views_list()
end

function SelectWorkView:on_set_info()
	local index = self._list:selected_item()

	if index == -1 then
		return
	end

	local j = self._list:get_item_data_ref(index)
	local view = self._views[j].view
	view.text = self._info_ctrlr:get_value()
end

function SelectWorkView:on_mark_view()
	local index = self._list:selected_item()
	local j = self._list:get_item_data_ref(index)
	local view = self._views[j].view

	self._info_ctrlr:change_value(view.text or "")
end

function SelectWorkView:on_select_view()
	self:on_goto()
end

function SelectWorkView:on_goto()
	local index = self._list:selected_item()

	if index == -1 then
		return
	end

	local j = self._list:get_item_data_ref(index)

	managers.editor:goto_workview(self._views[j].view)
end

function SelectWorkView:on_add()
	managers.editor:on_add_workview()
end

function SelectWorkView:update_filter()
	self:fill_views_list()
end

function SelectWorkView:workview_added()
	self:fill_views_list()
end

function SelectWorkView:fill_views_list()
	self._list:delete_all_items()

	local j = 1
	local filter = self._filter:get_value()
	self._views = {}

	self._list:freeze()

	local values = managers.editor:values()

	for _, c_name in ipairs(self._continent_names) do
		if self._continents_cbs[c_name]:get_value() then
			local c_values = values[c_name]

			if c_values and c_values.workviews then
				for v_name, view in pairs(c_values.workviews) do
					if string.find(v_name, filter, 1, true) then
						local i = self._list:append_item(v_name)
						self._views[j] = {
							view = view,
							continent = c_name,
							name = v_name
						}

						self._list:set_item_data(i, j)

						j = j + 1
					end
				end
			end
		end
	end

	self._list:thaw()
	self._list:autosize_column(0)
end

function SelectWorkView:reset()
	self:fill_views_list()
end

function SelectWorkView:freeze()
	self._list:freeze()
end

function SelectWorkView:thaw()
	self._list:thaw()
end

function SelectWorkView:recreate()
	for name, cb in pairs(self._continents_cbs) do
		self._continents_sizer:detach(cb)
		cb:destroy()
	end

	self._info_ctrlr:change_value("")
	self:build_cbs()
	self:fill_views_list()
	self._panel:layout()
end
