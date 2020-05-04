MissionElementListFlow = MissionElementListFlow or class(CoreEditorEwsDialog)

function MissionElementListFlow:init(...)
	CoreEditorEwsDialog.init(self, nil, "Mission List Flow", "", Vector3(300, 150, 0), Vector3(700, 400, 0), "DEFAULT_DIALOG_STYLE,RESIZE_BORDER", ...)
	self:create_panel("VERTICAL")

	self._use_look_at = false
	local toolbar_sizer = EWS:BoxSizer("VERTICAL")

	self._panel_sizer:add(toolbar_sizer, 0, 0, "EXPAND")
	self._panel:set_background_colour(255, 255, 255)

	local toolbar = EWS:ToolBar(self._panel, "", "TB_FLAT,TB_NODIVIDER")

	toolbar:add_tool("PREVIOUS", "Previous", CoreEws.image_path("world_editor\\wc_previous_key_16x16.png"), nil)
	toolbar:connect("PREVIOUS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_gui_previous"), nil)
	toolbar:add_tool("NEXT", "Next", CoreEws.image_path("world_editor\\wc_next_key_16x16.png"), nil)
	toolbar:connect("NEXT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_gui_next"), nil)
	toolbar:add_check_tool("LOOK_AT", "Look at selected", CoreEws.image_path("toolbar\\find_16x16.png"), "Look at selected")
	toolbar:set_tool_state("LOOK_AT", self._use_look_at)
	toolbar:connect("LOOK_AT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_toolbar_toggle"), {
		value = "_use_look_at",
		toolbar = toolbar
	})
	toolbar:add_tool("HELP", "Help", CoreEws.image_path("help_16x16.png"), nil)
	toolbar:connect("HELP", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_gui_help"), nil)
	toolbar:realize()
	toolbar_sizer:add(toolbar, 0, 0, "EXPAND,LEFT")

	local selected_sizer = EWS:BoxSizer("HORIZONTAL")

	self._panel_sizer:add(selected_sizer, 0, 0, "EXPAND")
	selected_sizer:add(EWS:BoxSizer("HORIZONTAL"), 1, 0, "EXPAND")

	self._selected_list = EWS:ListCtrl(self._panel, "", "LC_REPORT,LC_SORT_ASCENDING,NO_BORDER")

	self._selected_list:clear_all()
	self._selected_list:append_column("Name")
	self._selected_list:append_column("Id")
	selected_sizer:add(self._selected_list, 2, 0, "EXPAND")
	selected_sizer:add(EWS:BoxSizer("HORIZONTAL"), 1, 0, "EXPAND")
	self._selected_list:connect("EVT_COMMAND_LIST_ITEM_RIGHT_CLICK", callback(self, self, "_right_clicked"), self._selected_list)
	self._selected_list:connect("EVT_COMMAND_LIST_ITEM_ACTIVATED", callback(self, self, "_on_select_selected"), nil)
	self._selected_list:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local lists_sizer = EWS:BoxSizer("HORIZONTAL")
	self._executers_list = EWS:ListCtrl(self._panel, "", "LC_REPORT,LC_SORT_ASCENDING")

	self._executers_list:clear_all()
	self._executers_list:append_column("Name")
	self._executers_list:append_column("Id")
	self._executers_list:append_column("Type")
	self._executers_list:append_column("Delay")
	lists_sizer:add(self._executers_list, 1, 0, "EXPAND")

	self._on_executed_list = EWS:ListCtrl(self._panel, "", "LC_REPORT,LC_SORT_ASCENDING")

	self._on_executed_list:clear_all()
	self._on_executed_list:append_column("Name")
	self._on_executed_list:append_column("Id")
	self._on_executed_list:append_column("Type")
	self._on_executed_list:append_column("Delay")
	lists_sizer:add(self._on_executed_list, 1, 0, "EXPAND")
	self._panel_sizer:add(lists_sizer, 3, 0, "EXPAND")
	self._executers_list:connect("EVT_COMMAND_LIST_ITEM_SELECTED", callback(self, self, "_on_mark_executer"), nil)
	self._executers_list:connect("EVT_COMMAND_LIST_ITEM_ACTIVATED", callback(self, self, "_on_select_executer"), nil)
	self._executers_list:connect("EVT_COMMAND_LIST_ITEM_RIGHT_CLICK", callback(self, self, "_right_clicked"), self._executers_list)
	self._executers_list:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	self._on_executed_list:connect("EVT_COMMAND_LIST_ITEM_SELECTED", callback(self, self, "_on_mark_on_executed"), nil)
	self._on_executed_list:connect("EVT_COMMAND_LIST_ITEM_ACTIVATED", callback(self, self, "_on_select_on_executed"), nil)
	self._on_executed_list:connect("EVT_COMMAND_LIST_ITEM_RIGHT_CLICK", callback(self, self, "_right_clicked"), self._on_executed_list)
	self._on_executed_list:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local button_sizer = EWS:BoxSizer("HORIZONTAL")
	local close_btn = EWS:Button(self._panel, "Close", "", "")

	button_sizer:add(close_btn, 0, 2, "RIGHT,LEFT")
	close_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_cancel"), "")
	close_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	self._panel_sizer:add(button_sizer, 0, 0, "ALIGN_RIGHT")
	self._dialog_sizer:add(self._panel, 1, 0, "EXPAND")
	self._dialog:set_visible(true)

	self._unit_history = {}
	self._unit_history_index = 0
end

function MissionElementListFlow:_toolbar_toggle(params, event)
	self[params.value] = params.toolbar:tool_state(event:get_id())
end

function MissionElementListFlow:_on_gui_help()
	local text = "Mission flow show connections between different mission components.\n\nAt the top is the current selected mission element. The left list shows what is affecting it and the right what it affects."
	text = text .. "\n\nThe 'Type' column displays what type of connection it is. It can be on_executed, operator, trigger etc."
	text = text .. "\n\nDouble click left mouse button (in any list) will select that unit."
	text = text .. "\nSingle click right mouse button (in any list) will find that unit."

	EWS:message_box(self._panel, text, "Help", "OK", Vector3())
end

function MissionElementListFlow:on_unit_selected(unit)
	self:freeze()
	self._selected_list:delete_all_items()
	self._executers_list:delete_all_items()
	self._on_executed_list:delete_all_items()
	table.remove_condition(self._unit_history, function (unit)
		return not alive(unit)
	end)

	if unit then
		if not self._skip_history then
			if self._unit_history_index < #self._unit_history then
				table.crop(self._unit_history, self._unit_history_index)
			end

			if not self._unit_history[self._unit_history_index] or self._unit_history[self._unit_history_index] ~= unit then
				table.insert(self._unit_history, unit)

				self._unit_history_index = #self._unit_history
			end
		end

		self._skip_history = nil
		local unit_id = unit:unit_data().unit_id
		local i = self._selected_list:append_item(unit:unit_data().name_id)

		self._selected_list:set_item(i, 1, "" .. unit_id)
		self._selected_list:set_item_data(i, {
			unit = unit
		})
		self:_autosize_columns(self._selected_list)

		local links = managers.editor:layer("Mission"):get_unit_links(unit)

		for _, data in ipairs(links.on_executed) do
			local on_executed_unit = data.unit
			local i = self._on_executed_list:append_item(on_executed_unit:unit_data().name_id)

			self._on_executed_list:set_item(i, 1, "" .. on_executed_unit:unit_data().unit_id)
			self._on_executed_list:set_item(i, 2, "" .. (data.alternative and data.alternative or "N/A"))
			self._on_executed_list:set_item(i, 3, "" .. (data.delay and data.delay or "N/A"))
			self._on_executed_list:set_item_data(i, {
				unit = on_executed_unit
			})
		end

		for _, data in ipairs(links.executers) do
			local link_unit = data.unit
			local i = self._executers_list:append_item(link_unit:unit_data().name_id)

			self._executers_list:set_item(i, 1, "" .. link_unit:unit_data().unit_id)
			self._executers_list:set_item(i, 2, "" .. (data.alternative and data.alternative or "N/A"))
			self._executers_list:set_item(i, 3, "" .. (data.delay and data.delay or "N/A"))
			self._executers_list:set_item_data(i, {
				unit = link_unit
			})
		end
	end

	self:_autosize_columns(self._on_executed_list)
	self:_autosize_columns(self._executers_list)
	self:thaw()
end

function MissionElementListFlow:_autosize_columns(list)
	for i = 0, list:column_count() - 1 do
		list:autosize_column(i)
	end
end

function MissionElementListFlow:_on_gui_previous()
	if self._unit_history_index == 0 then
		return
	end

	self._skip_history = true
	self._unit_history_index = math.max(self._unit_history_index - 1, 1)

	managers.editor:select_units({
		self._unit_history[self._unit_history_index]
	})
end

function MissionElementListFlow:_on_gui_next()
	if self._unit_history_index > #self._unit_history then
		return
	end

	self._skip_history = true
	self._unit_history_index = math.min(self._unit_history_index + 1, #self._unit_history)

	managers.editor:select_units({
		self._unit_history[self._unit_history_index]
	})
end

function MissionElementListFlow:key_cancel(ctrlr, event)
	event:skip()

	if EWS:name_to_key_code("K_ESCAPE") == event:key_code() then
		self:on_cancel()
	end
end

function MissionElementListFlow:_on_select_selected()
	local current_data = self:_current_data()

	if current_data and current_data.unit and self._use_look_at then
		managers.editor:look_towards_unit(current_data.unit)
	end
end

function MissionElementListFlow:_right_clicked(list)
	local item_data = self:_selected_list_data(list)

	if item_data then
		managers.editor:center_view_on_unit(item_data.unit)
	end
end

function MissionElementListFlow:_on_mark_executer()
	local item_data = self:_selected_executer_data()
end

function MissionElementListFlow:_on_select_executer()
	local item_data = self:_selected_executer_data()

	if item_data and item_data.unit then
		if self._use_look_at then
			managers.editor:look_towards_unit(item_data.unit)
		end

		managers.editor:select_units({
			item_data.unit
		})
	end
end

function MissionElementListFlow:_on_mark_on_executed()
	local item_data = self:_selected_on_executed_data()
end

function MissionElementListFlow:_on_select_on_executed()
	local item_data = self:_selected_on_executed_data()

	if item_data and item_data.unit then
		if self._use_look_at then
			managers.editor:look_towards_unit(item_data.unit)
		end

		managers.editor:select_units({
			item_data.unit
		})
	end
end

function MissionElementListFlow:_current_data()
	local index = self._selected_list:selected_item()

	if index == -1 then
		-- Nothing
	end

	return self._selected_list:get_item_data_ref(0)
end

function MissionElementListFlow:_selected_list_data(list)
	local index = list:selected_item()

	if index == -1 then
		return
	end

	return list:get_item_data_ref(index)
end

function MissionElementListFlow:_selected_on_executed_data()
	local index = self._on_executed_list:selected_item()

	if index == -1 then
		return
	end

	return self._on_executed_list:get_item_data_ref(index)
end

function MissionElementListFlow:_selected_executer_data()
	local index = self._executers_list:selected_item()

	if index == -1 then
		return
	end

	return self._executers_list:get_item_data_ref(index)
end

function MissionElementListFlow:on_goto()
end

function MissionElementListFlow:reset()
end

function MissionElementListFlow:freeze()
	self._selected_list:freeze()
	self._executers_list:freeze()
	self._on_executed_list:freeze()
end

function MissionElementListFlow:thaw()
	self._selected_list:thaw()
	self._executers_list:thaw()
	self._on_executed_list:thaw()
end

function MissionElementListFlow:recreate()
	for name, cb in pairs(self._continents_cbs) do
		self._continents_sizer:detach(cb)
		cb:destroy()
	end

	self._panel:layout()
end
