core:module("CoreEws")
core:import("CoreClass")
core:import("CoreApp")

function verify_number(ctrlr, event)
	if EWS:name_to_key_code("K_BACK") == event:key_code() or EWS:name_to_key_code("K_RIGHT") == event:key_code() or EWS:name_to_key_code("K_LEFT") == event:key_code() or event:key_code() >= 48 and event:key_code() <= 57 or event:key_code() == 45 or event:key_code() == 46 or EWS:name_to_key_code("K_RETURN") == event:key_code() or EWS:name_to_key_code("K_TAB") == event:key_code() or EWS:name_to_key_code("K_DELETE") == event:key_code() or (event:key_code() == 22 or event:key_code() == 1 or event:key_code() == 3) and event:control_down() then
		if event:key_code() == 46 then
			local s = ctrlr:get_value() .. "."

			if not tonumber(s) then
				return
			end
		end

		event:skip()
	end
end

function image_path(file_name)
	file_name = file_name or ""
	local base_path = managers.database and managers.database:base_path() or Application:base_path() .. (CoreApp.arg_value("-assetslocation") or "../../") .. "assets\\"
	local path = base_path .. "lib\\utils\\dev\\ews\\images\\"

	if file_name ~= "" and EWS and not EWS:system_file_exists(path .. file_name) then
		path = base_path .. "core\\lib\\utils\\dev\\ews\\images\\"
	end

	return path .. file_name
end

EWSConfirmDialog = EWSConfirmDialog or CoreClass.class()

function EWSConfirmDialog:init(label, message)
	self._yes = false
	self._no = false
	self._cancel = false
	self._dialog = EWS:Dialog(nil, label, "", Vector3(525, 400, 0), Vector3(250, 110, 0), "DEFAULT_DIALOG_STYLE")
	local dialog_sizer = EWS:BoxSizer("HORIZONTAL")

	self._dialog:set_sizer(dialog_sizer)

	local panel = EWS:Panel(self._dialog, "", "")
	local panel_sizer = EWS:BoxSizer("VERTICAL")

	panel:set_sizer(panel_sizer)

	local msg = EWS:StaticText(panel, message, "", "ALIGN_CENTRE")

	panel_sizer:add(msg, 0, 20, "EXPAND,TOP,BOTTOM")

	local button_sizer = EWS:BoxSizer("HORIZONTAL")
	local yes_btn = EWS:Button(panel, "Yes", "", "BU_BOTTOM")

	button_sizer:add(yes_btn, 0, 2, "RIGHT,LEFT")
	yes_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "set_value"), "_yes")

	local no_btn = EWS:Button(panel, "No", "", "")

	button_sizer:add(no_btn, 0, 2, "RIGHT,LEFT")
	no_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "set_value"), "_no")

	local cancel_btn = EWS:Button(panel, "Cancel", "", "")

	button_sizer:add(cancel_btn, 0, 2, "RIGHT,LEFT")
	cancel_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "set_value"), "_cancel")
	panel_sizer:add(button_sizer, 1, 0, "EXPAND")
	dialog_sizer:add(panel_sizer, 1, 0, "EXPAND")
	panel:fit()
end

function EWSConfirmDialog:show_modal()
	self._dialog:show_modal()

	return true
end

function EWSConfirmDialog:set_value(value)
	self[value] = true

	self._dialog:end_modal()
end

function EWSConfirmDialog:yes()
	return self._yes
end

function EWSConfirmDialog:no()
	return self._no
end

function EWSConfirmDialog:cancel()
	return self._cancel
end

LocalizerTextCtrl = LocalizerTextCtrl or CoreClass.class()

function LocalizerTextCtrl:init(panel, sizer, text)
	self._text_ctrlr = EWS:TextCtrl(panel, Localizer:lookup(text), "", "TE_CENTRE,TE_READONLY")

	sizer:add(self._text_ctrlr, 1, 0, "EXPAND")
end

function LocalizerTextCtrl:get()
	return self._text_ctrlr
end

function LocalizerTextCtrl:get_value()
	return self._text_ctrlr:get_value()
end

function LocalizerTextCtrl:set_value(value)
	return self._text_ctrlr:set_value(Localizer:lookup(value))
end

EWSRadioBitmapButton = EWSRadioBitmapButton or CoreClass.class()

function EWSRadioBitmapButton:init(panel, bmp, id, style)
	self._on_bmp = bmp
	self._off_bmp = bmp
	self._button = EWS:BitmapButton(panel, bmp, "", "")
	self._value = true
end

function EWSRadioBitmapButton:button()
	return self._button
end

function EWSRadioBitmapButton:set_on_bmp(bmp)
	self._on_bmp = bmp
end

function EWSRadioBitmapButton:set_off_bmp(bmp)
	self._off_bmp = bmp
end

function EWSRadioBitmapButton:set_value(value)
	self._value = value

	if value then
		self._button:set_label_bitmap(self._on_bmp)
	else
		self._button:set_label_bitmap(self._off_bmp)
	end
end

function EWSRadioBitmapButton:value()
	return self._value
end

EwsTextDialog = EwsTextDialog or CoreClass.class()

function EwsTextDialog:init(name, init_text)
	init_text = init_text or "new"
	self._dialog = EWS:Dialog(nil, name, "", Vector3(525, 400, 0), Vector3(230, 150, 0), "CAPTION,CLOSE_BOX")

	self._dialog:set_background_colour("LIGHT GREY")

	local dialog_main_sizer = EWS:StaticBoxSizer(self._dialog, "VERTICAL")

	self._dialog:set_sizer(dialog_main_sizer)

	self._text = EWS:TextCtrl(self._dialog, init_text, "", "TE_CENTRE")

	dialog_main_sizer:add(self._text, 0, 0, "EXPAND")

	local button_sizer = EWS:BoxSizer("HORIZONTAL")
	local ok_btn = EWS:Button(self._dialog, "Ok", "", "BU_EXACTFIT,NO_BORDER")

	button_sizer:add(ok_btn, 0, 0, "EXPAND")
	ok_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "close"), {
		cancel = false,
		dialog = self._dialog
	})

	local cancel_btn = EWS:Button(self._dialog, "Cancel", "", "BU_EXACTFIT,NO_BORDER")

	button_sizer:add(cancel_btn, 0, 0, "EXPAND")
	cancel_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "close"), {
		cancel = true,
		dialog = self._dialog
	})
	dialog_main_sizer:add(button_sizer, 0, 0, "ALIGN_RIGHT")
end

function EwsTextDialog:close(data)
	data.dialog:end_modal()

	self._cancel_dialog = data.cancel
end

function EwsTextDialog:cancel_dialog()
	return self._cancel_dialog
end

function EwsTextDialog:dialog()
	return self._dialog
end

function EwsTextDialog:text()
	return self._text
end

function number_controller(params)
	params.value = params.value or 0
	params.name_proportions = params.name_proportions or 1
	params.ctrlr_proportions = params.ctrlr_proportions or 1
	params.sizer_proportions = params.sizer_proportions or 0
	params.floats = params.floats or 0
	params.ctrl_sizer = EWS:BoxSizer("HORIZONTAL")

	_ctrlr_tooltip(params)
	_name_ctrlr(params)
	_number_ctrlr(params)
	params.ctrl_sizer:add(params.number_ctrlr, params.ctrlr_proportions, 0, "EXPAND")
	params.sizer:add(params.ctrl_sizer, params.sizer_proportions, 0, "EXPAND")
	_connect_events(params)

	return params.number_ctrlr, params.name_ctrlr, params
end

function verify_entered_number(params)
	local value = tonumber(params.number_ctrlr:get_value()) or 0

	if params.min and value < params.min then
		value = params.min or value
	end

	if params.max and params.max < value then
		value = params.max or value
	end

	params.value = value
	local floats = params.floats or 0

	params.number_ctrlr:change_value(string.format("%." .. floats .. "f", value))
	params.number_ctrlr:set_selection(-1, -1)
end

function change_entered_number(params, value)
	local floats = params.floats or 0
	params.value = value

	params.number_ctrlr:change_value(string.format("%." .. floats .. "f", params.value))
end

function change_slider_and_number_value(params, value)
	params.value = value

	params.slider_ctrlr:set_value(value * params.slider_multiplier)
	change_entered_number(params, value)
end

function _connect_events(params)
	if not params.events then
		return
	end

	for _, data in ipairs(params.events) do
		params.number_ctrlr:connect(data.event, data.callback, params)
	end
end

function combobox(params)
	local name = params.name
	local panel = params.panel
	local sizer = params.sizer
	local default = params.default
	local options = params.options or {}
	local value = params.value or options[1]
	local name_proportions = params.name_proportions or 1
	local ctrlr_proportions = params.ctrlr_proportions or 2
	params.sizer_proportions = params.sizer_proportions or 0
	local tooltip = params.tooltip
	local styles = params.styles or "CB_DROPDOWN,CB_READONLY"
	local sorted = params.sorted
	local ctrl_sizer = EWS:BoxSizer("HORIZONTAL")
	local name_ctrlr = nil

	if name then
		name_ctrlr = EWS:StaticText(panel, name, 0, "")

		name_ctrlr:set_min_size(Vector3(0, -1, 0))
		ctrl_sizer:add(name_ctrlr, name_proportions, 0, "ALIGN_CENTER_VERTICAL")
	end

	if sorted then
		table.sort(options)
	end

	local ctrlr = EWS:ComboBox(panel, "", "", styles)

	if params.value then
		ctrlr:set_tool_tip(params.tooltip .. "\n" .. params.value)
	else
		ctrlr:set_tool_tip(tooltip)
	end

	ctrlr:freeze()

	if default then
		ctrlr:append(default)
	end

	for _, option in ipairs(options) do
		ctrlr:append(option)
	end

	ctrlr:set_value(value)
	ctrlr:thaw()

	params.name_ctrlr = name_ctrlr
	params.ctrlr = ctrlr

	ctrl_sizer:add(ctrlr, ctrlr_proportions, 0, "EXPAND")
	sizer:add(ctrl_sizer, params.sizer_proportions, 0, "EXPAND")
	params.ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(nil, _M, "_set_combobox_value"), params)
	_connect_events(params)

	return ctrlr, name_ctrlr, params
end

function _set_combobox_value(params)
	params.value = params.ctrlr:get_value()
	params.value = params.numbers and tonumber(params.value) or params.value

	if params.value_changed_cb then
		params:value_changed_cb()
	end

	if params.value then
		params.ctrlr:set_tool_tip(params.tooltip .. "\n" .. params.value)
	end
end

function update_combobox_options(params, options)
	params.ctrlr:freeze()
	params.ctrlr:clear()

	if params.sorted then
		table.sort(options)
	end

	if params.default then
		params.ctrlr:append(params.default)
	end

	for _, option in ipairs(options) do
		params.ctrlr:append(option)
	end

	params.options = options

	params.ctrlr:thaw()
end

function change_combobox_value(params, value)
	params.value = value
	params.value = params.numbers and tonumber(params.value) or params.value

	params.ctrlr:set_value(value)

	if params.value_changed_cb then
		params:value_changed_cb()
	end

	if params.value then
		params.ctrlr:set_tool_tip(params.tooltip .. "\n" .. params.value)
	end
end

function slider_and_number_controller(params)
	params.value = params.value or 0
	params.name_proportions = params.name_proportions or 1
	params.ctrlr_proportions = params.ctrlr_proportions or 1
	params.slider_ctrlr_proportions = params.slider_ctrlr_proportions or 2
	params.number_ctrlr_proportions = params.number_ctrlr_proportions or 1
	params.floats = params.floats or 0
	params.slider_multiplier = math.pow(10, params.floats)
	params.min = params.min or 0
	params.max = params.max or 10
	params.ctrl_sizer = EWS:BoxSizer("HORIZONTAL")

	_ctrlr_tooltip(params)
	_name_ctrlr(params)
	_number_ctrlr(params)
	_slider_ctrlr(params)
	params.number_ctrlr:connect("EVT_COMMAND_TEXT_ENTER", callback(nil, _M, "update_slider_from_number"), params)
	params.number_ctrlr:connect("EVT_KILL_FOCUS", callback(nil, _M, "update_slider_from_number"), params)
	params.slider_ctrlr:connect("EVT_SCROLL_CHANGED", callback(nil, _M, "update_number_from_slider"), params)
	params.slider_ctrlr:connect("EVT_SCROLL_THUMBTRACK", callback(nil, _M, "update_number_from_slider"), params)

	local ctrl_sizer2 = EWS:BoxSizer("HORIZONTAL")

	ctrl_sizer2:add(params.slider_ctrlr, params.slider_ctrlr_proportions, 0, "ALIGN_CENTER_VERTICAL")
	ctrl_sizer2:add(params.number_ctrlr, params.number_ctrlr_proportions, 0, "EXPAND")
	params.ctrl_sizer:add(ctrl_sizer2, params.ctrlr_proportions, 0, "EXPAND")
	params.sizer:add(params.ctrl_sizer, params.sizer_proportions or 0, 0, "EXPAND")

	return params
end

function _ctrlr_tooltip(params)
	local max = params.max
	local min = params.min

	if min and max then
		params.tooltip = (params.tooltip or "") .. " (Between " .. string.format("%." .. params.floats .. "f", min) .. " and " .. string.format("%." .. params.floats .. "f", max) .. ")"
	elseif min then
		params.tooltip = (params.tooltip or "") .. " (Above " .. string.format("%." .. params.floats .. "f", min) .. ")"
	elseif max then
		params.tooltip = (params.tooltip or "") .. " (Below " .. string.format("%." .. params.floats .. "f", max) .. ")"
	end
end

function _slider_ctrlr(params)
	params.slider_ctrlr = EWS:Slider(params.panel, params.value * params.slider_multiplier, params.min * params.slider_multiplier, params.max * params.slider_multiplier, "", "")

	params.slider_ctrlr:set_tool_tip(params.tooltip)
end

function _number_ctrlr(params)
	if CoreClass.type_name(params.value) ~= "number" then
		params.value = params.min or 0
	end

	params.number_ctrlr = EWS:TextCtrl(params.panel, string.format("%." .. params.floats .. "f", params.value), "", "TE_PROCESS_ENTER")

	params.number_ctrlr:set_tool_tip(params.tooltip)
	params.number_ctrlr:connect("EVT_CHAR", callback(nil, _G, "verify_number"), params.number_ctrlr)
	params.number_ctrlr:connect("EVT_COMMAND_TEXT_ENTER", callback(nil, _M, "verify_entered_number"), params)
	params.number_ctrlr:connect("EVT_KILL_FOCUS", callback(nil, _M, "verify_entered_number"), params)
end

function _name_ctrlr(params)
	if params.name then
		params.name_ctrlr = EWS:StaticText(params.panel, params.name, 0, "")

		params.ctrl_sizer:add(params.name_ctrlr, params.name_proportions, 0, "ALIGN_CENTER_VERTICAL")
	end
end

function verify_entered_number(params)
	local ctrlr = params.ctrlr or params.number_ctrlr
	local value = tonumber(ctrlr:get_value()) or 0

	if params.min and value < params.min then
		value = params.min or value
	end

	if params.max and params.max < value then
		value = params.max or value
	end

	params.value = value
	local floats = params.floats or 0

	ctrlr:change_value(string.format("%." .. floats .. "f", value))
	ctrlr:set_selection(-1, -1)
end

function update_slider_from_number(params)
	params.slider_ctrlr:set_value(params.value * params.slider_multiplier)
end

function update_number_from_slider(params)
	params.value = params.slider_ctrlr:get_value() / params.slider_multiplier

	change_entered_number(params, params.value)
end

function update_slider_and_number_controller_value(params, value)
	params.value = value

	change_entered_number(params, params.value)
	update_slider_from_number(params)
end

function change_slider_and_number_controller_range(params, min, max)
	params.slider_ctrlr:set_range(min * params.slider_multiplier, max * params.slider_multiplier)
end

function list_selector(params)
	params.title = params.title or ""
	params.options = params.options or {}
	params.value = params.value or {}
	params.height = params.height or 100
	params.ctrl_sizer = EWS:BoxSizer("VERTICAL")

	params.ctrl_sizer:add(EWS:StaticLine(params.panel, "", ""), 0, 4, "EXPAND,TOP,BOTTOM")
	_name_ctrlr(params)

	local toolbar_sizer = EWS:BoxSizer("HORIZONTAL")
	params.left_toolbar = EWS:ToolBar(params.panel, "", "TB_FLAT,TB_NODIVIDER")

	params.left_toolbar:add_tool("ADD_LIST", "Add from list", image_path("world_editor\\unit_by_name_list.png"), nil)
	params.left_toolbar:connect("ADD_LIST", "EVT_COMMAND_MENU_SELECTED", callback(nil, _G, "_list_selector_add_from_list"), params)
	params.left_toolbar:realize()
	toolbar_sizer:add(params.left_toolbar, 1, 1, "EXPAND,LEFT")

	params.right_toolbar = EWS:ToolBar(params.panel, "", "TB_FLAT,TB_NODIVIDER")

	params.right_toolbar:add_tool("REMOVE_LIST", "Remove from list", image_path("toolbar\\delete_16x16.png"), nil)
	params.right_toolbar:connect("REMOVE_LIST", "EVT_COMMAND_MENU_SELECTED", callback(nil, _G, "_list_selector_remove_from_list"), params)
	params.right_toolbar:realize()
	toolbar_sizer:add(params.right_toolbar, 1, 1, "EXPAND,LEFT")
	params.ctrl_sizer:add(toolbar_sizer, 0, 1, "EXPAND,LEFT")

	local lb_box = EWS:BoxSizer("HORIZONTAL")
	params.left_list_box = EWS:ListBox(params.panel, "", "LB_SORT,LB_EXTENDED")

	params.left_list_box:connect("", "EVT_COMMAND_LISTBOX_DOUBLECLICKED", callback(nil, _G, "_list_selector_on_left_box"), params)
	params.left_list_box:set_min_size(Vector3(10, params.height, 0))
	lb_box:add(params.left_list_box, 1, 4, "ALL,EXPAND")

	params.right_list_box = EWS:ListBox(params.panel, "", "LB_SORT,LB_EXTENDED")

	params.right_list_box:connect("", "EVT_COMMAND_LISTBOX_DOUBLECLICKED", callback(nil, _G, "_list_selector_on_right_box"), params)
	params.right_list_box:set_min_size(Vector3(10, params.height, 0))
	lb_box:add(params.right_list_box, 1, 4, "ALL,EXPAND")
	params.ctrl_sizer:add(lb_box, 1, 0, "EXPAND")
	params.sizer:add(params.ctrl_sizer, params.sizer_proportions or 0, 0, "EXPAND")

	for _, option in ipairs(params.options) do
		if table.contains(params.value, option) then
			params.right_list_box:append(option)
		else
			params.left_list_box:append(option)
		end
	end

	return params
end

function _list_selector_add_from_list(params)
	local dialog = _G.SelectNameModal:new("Add", _list_selector_get_left_box_value(params), {
		list_style = "LC_REPORT,LC_NO_HEADER,LC_SORT_ASCENDING"
	})

	if dialog:cancelled() then
		return
	end

	for i = 0, params.left_list_box:nr_items() - 1, 1 do
		params.left_list_box:deselect_index(i)

		for _, selected in ipairs(dialog:_selected_item_assets()) do
			if selected == params.left_list_box:get_string(i) then
				params.left_list_box:select_index(i)

				break
			end
		end
	end

	_list_selector_on_left_box(params)
end

function _list_selector_remove_from_list(params)
	local dialog = _G.SelectNameModal:new("Remove", _list_selector_get_value(params), {
		list_style = "LC_REPORT,LC_NO_HEADER,LC_SORT_ASCENDING"
	})

	if dialog:cancelled() then
		return
	end

	for i = 0, params.right_list_box:nr_items() - 1, 1 do
		params.right_list_box:deselect_index(i)

		for _, selected in ipairs(dialog:_selected_item_assets()) do
			if selected == params.right_list_box:get_string(i) then
				params.right_list_box:select_index(i)

				break
			end
		end
	end

	_list_selector_on_right_box(params)
end

function _list_selector_on_left_box(params)
	local selected_indices = params.left_list_box:selected_indices()

	for _, index in ipairs(selected_indices) do
		local selected = params.left_list_box:get_string(index)

		params.right_list_box:append(selected)
		params.left_list_box:deselect_index(index)
	end

	for i, index in ipairs(selected_indices) do
		params.left_list_box:remove(index - (i - 1))
	end

	_list_selector_updated_callback(params)
end

function _list_selector_on_right_box(params)
	local selected_indices = params.right_list_box:selected_indices()

	for _, index in ipairs(selected_indices) do
		local selected = params.right_list_box:get_string(index)

		params.left_list_box:append(selected)
		params.right_list_box:deselect_index(index)
	end

	for i, index in ipairs(selected_indices) do
		params.right_list_box:remove(index - (i - 1))
	end

	_list_selector_updated_callback(params)
end

function _list_selector_get_left_box_value(params)
	local value = {}

	for i = 0, params.left_list_box:nr_items() - 1, 1 do
		table.insert(value, params.left_list_box:get_string(i))
	end

	return value
end

function _list_selector_get_value(params)
	local value = {}

	for i = 0, params.right_list_box:nr_items() - 1, 1 do
		table.insert(value, params.right_list_box:get_string(i))
	end

	return value
end

function _list_selector_updated_callback(params)
	if params.updated_callback then
		params.updated_callback(_list_selector_get_value(params))
	end
end

function combobox_and_list(params)
	local horizontal_sizer = EWS:BoxSizer("HORIZONTAL")

	params.sizer:add(horizontal_sizer, 0, 1, "EXPAND,LEFT")

	params.sizer = horizontal_sizer
	params.sizer_proportions = params.sizer_proportions or 1
	params.tooltip = params.tooltip or "Select an option from the combobox"
	local ctrlr = combobox(params)
	local toolbar = EWS:ToolBar(params.panel, "", "TB_FLAT,TB_NODIVIDER")

	toolbar:add_tool("SELECT_NAME_LIST", "Select from list", image_path("world_editor\\unit_by_name_list.png"), nil)
	toolbar:connect("SELECT_NAME_LIST", "EVT_COMMAND_MENU_SELECTED", callback(nil, _G, "_on_gui_value_combobox_toolbar_select_dialog"), {
		combobox_params = params
	})
	toolbar:realize()
	horizontal_sizer:add(toolbar, 0, 1, "EXPAND,LEFT")

	params.toolbar = toolbar

	return ctrlr, params
end

function _on_gui_value_combobox_toolbar_select_dialog(params)
	local dialog = _G.SelectNameModal:new("Select name", params.combobox_params.options)

	if dialog:cancelled() then
		return
	end

	for _, name in ipairs(dialog:_selected_item_assets()) do
		change_combobox_value(params.combobox_params, name)
	end
end

function set_combobox_and_list_enabled(params, enabled)
	params.ctrlr:set_enabled(enabled)
	params.toolbar:set_enabled(enabled)
end

function get_notebook_current_page_index(notebook)
	local page = notebook:get_current_page()

	for i = 0, notebook:get_page_count() - 1, 1 do
		if page == notebook:get_page(i) then
			return i
		end
	end

	return nil
end
