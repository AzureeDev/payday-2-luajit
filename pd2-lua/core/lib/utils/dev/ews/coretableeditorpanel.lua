CoreTableEditorPanel = CoreTableEditorPanel or class()

function CoreTableEditorPanel:init(parent)
	self.__column_names = {}
	self.__panel = EWS:Panel(parent)
	local panel_sizer = EWS:BoxSizer("VERTICAL")

	self.__panel:set_sizer(panel_sizer)
	panel_sizer:add(self:_create_list_ctrl(self.__panel), 1, 5, "TOP,LEFT,RIGHT,EXPAND")
	panel_sizer:add(self:_create_buttons_panel(self.__panel), 0, 4, "ALL,EXPAND")
	panel_sizer:add(self:_create_fields_panel(self.__panel), 0, 0, "EXPAND")
end

function CoreTableEditorPanel:destroy()
	self.__panel:destroy()

	self.__panel = nil
end

function CoreTableEditorPanel:clear()
	self:freeze()
	self.__list_ctrl:delete_all_items()
	self:set_selected_item(nil)
	self:thaw()
end

function CoreTableEditorPanel:add_to_sizer(sizer, proportion, border, flags)
	sizer:add(self.__panel, proportion, border, flags)
end

function CoreTableEditorPanel:detach_from_sizer(sizer)
	sizer:detach(self.__panel)
end

function CoreTableEditorPanel:freeze()
	self.__frozen = true

	self.__panel:freeze()
end

function CoreTableEditorPanel:thaw()
	self.__frozen = nil

	self.__panel:thaw()

	if self.__needs_refresh then
		self.__needs_refresh = nil

		self:_refresh_fields_panel()
		self:_refresh_buttons_panel()
	end
end

function CoreTableEditorPanel:add_column(heading, format_style)
	table.insert(self.__column_names, heading)
	self.__list_ctrl:append_column(heading, format_style or "LIST_FORMAT_LEFT")
	self:_refresh_fields_panel()
end

function CoreTableEditorPanel:add_item(...)
	local values = {
		...
	}
	local item_index = self.__list_ctrl:append_item(tostring(values[1]))

	for i = 2, #values do
		self.__list_ctrl:set_item(item_index, i - 1, tostring(values[i]))
	end

	self:set_selected_item(item_index)

	return item_index
end

function CoreTableEditorPanel:remove_item(item_index)
	self.__list_ctrl:delete_item(item_index)
	self:set_selected_item(nil)
end

function CoreTableEditorPanel:item_value(item_index, column_name)
	return self:_string_to_value(self.__list_ctrl:get_item(item_index, self:_column_index(column_name)), column_name)
end

function CoreTableEditorPanel:set_item_value(item_index, column_name, value)
	self.__list_ctrl:set_item(item_index, self:_column_index(column_name), self:_value_to_string(value, column_name))
end

function CoreTableEditorPanel:selected_item()
	local item_index = self.__list_ctrl:selected_item()

	return item_index >= 0 and item_index or nil
end

function CoreTableEditorPanel:set_selected_item(item_index)
	self.__list_ctrl:set_item_selected(item_index or -1, true)
	self:_refresh_fields_panel()
	self:_refresh_buttons_panel()
end

function CoreTableEditorPanel:selected_item_value(column_name)
	local selected_item_index = self:selected_item()

	return selected_item_index and self:item_value(selected_item_index, column_name)
end

function CoreTableEditorPanel:set_selected_item_value(column_name, value)
	local selected_item_index = self:selected_item()

	if selected_item_index then
		self:set_item_value(selected_item_index, column_name, value)
	end
end

function CoreTableEditorPanel:_create_list_ctrl(parent)
	self.__list_ctrl = EWS:ListCtrl(parent, "", "LC_REPORT,LC_SINGLE_SEL")

	self.__list_ctrl:connect("EVT_COMMAND_LIST_ITEM_SELECTED", callback(self, self, "_on_selection_changed"), self.__list_ctrl)
	self.__list_ctrl:connect("EVT_COMMAND_LIST_ITEM_DESELECTED", callback(self, self, "_on_selection_changed"), self.__list_ctrl)

	return self.__list_ctrl
end

function CoreTableEditorPanel:_create_buttons_panel(parent)
	self.__buttons_panel = EWS:Panel(parent)
	local panel_sizer = EWS:BoxSizer("HORIZONTAL")

	self.__buttons_panel:set_sizer(panel_sizer)

	self.__add_button = EWS:Button(self.__buttons_panel, "Add")

	self.__add_button:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "_on_add_button_clicked"), self.__add_button)

	self.__remove_button = EWS:Button(self.__buttons_panel, "Remove")

	self.__remove_button:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "_on_remove_button_clicked"), self.__add_button)
	panel_sizer:add(self.__add_button, 1, 1, "RIGHT,EXPAND")
	panel_sizer:add(self.__remove_button, 1, 2, "LEFT,EXPAND")

	return self.__buttons_panel
end

function CoreTableEditorPanel:_create_fields_panel(parent)
	self.__fields_panel = EWS:Panel(parent)

	self:_refresh_fields_panel()

	return self.__fields_panel
end

function CoreTableEditorPanel:_refresh_buttons_panel()
	self.__remove_button:set_enabled(self:selected_item() ~= nil)
end

function CoreTableEditorPanel:_refresh_fields_panel()
	if self.__frozen then
		self.__needs_refresh = true
	else
		self.__fields_panel:freeze()
		self.__fields_panel:destroy_children()

		local new_sizer = self:_sizer_with_editable_fields(self.__fields_panel)

		if new_sizer then
			self.__fields_panel:set_sizer(new_sizer)
			self.__fields_panel:fit_inside()
		end

		self.__fields_panel:thaw()
	end
end

function CoreTableEditorPanel:_sizer_with_editable_fields(parent)
	local sizer = EWS:BoxSizer("VERTICAL")
	local first_control = nil

	for _, column_name in ipairs(self.__column_names) do
		local control = self:_create_labeled_text_field(column_name, parent, sizer)
		first_control = first_control or control
	end

	if first_control and self:selected_item() ~= nil then
		first_control:set_selection(-1, -1)
		first_control:set_focus()
	end

	return sizer
end

function CoreTableEditorPanel:_create_labeled_text_field(column_name, parent, sizer)
	local enabled = self:selected_item() ~= nil
	local label = EWS:StaticText(parent, string.pretty(column_name, true) .. ":")
	local control = EWS:TextCtrl(parent, self:selected_item_value(column_name))
	local callback_func = self:_make_control_edited_callback(control, column_name)

	label:set_enabled(enabled)
	control:set_enabled(enabled)
	control:set_min_size(control:get_min_size():with_x(0))
	control:connect("EVT_COMMAND_TEXT_UPDATED", callback_func)
	sizer:add(label, 0, 5, "TOP,LEFT,RIGHT")
	sizer:add(control, 0, 5, "ALL,EXPAND")

	return control
end

function CoreTableEditorPanel:_column_index(column_name)
	local column_index = column_name and table.get_vector_index(self.__column_names, column_name) or assert(nil, string.format("Column \"%s\" does not exist.", tostring(column_name)))

	return column_index - 1
end

function CoreTableEditorPanel:_string_to_value(str, column_name)
	return str or ""
end

function CoreTableEditorPanel:_value_to_string(value, column_name)
	return value == nil and "" or tostring(value)
end

function CoreTableEditorPanel:_make_control_edited_callback(control, column_name, value_method_name)
	return function ()
		self:_on_control_edited(control, column_name, value_method_name)
	end
end

function CoreTableEditorPanel:_top_level_window(window)
	window = window or self.__panel

	return (type_name(window) == "EWSFrame" or type_name(window) == "EWSDialog") and window or self:_top_level_window(assert(window:parent()))
end

function CoreTableEditorPanel:_on_selection_changed(sender)
	self:_refresh_fields_panel()
	self:_refresh_buttons_panel()
end

function CoreTableEditorPanel:_on_add_button_clicked(sender)
	self:add_item("<New Entry>")
end

function CoreTableEditorPanel:_on_remove_button_clicked(sender)
	self:remove_item(self:selected_item())
end

function CoreTableEditorPanel:_on_control_edited(control, column_name, value_method_name)
	value_method_name = value_method_name or "get_value"
	local value = control[value_method_name](control)

	self:set_selected_item_value(column_name, value)
end
