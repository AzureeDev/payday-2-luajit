SelectNameModal = SelectNameModal or class(CoreEditorEwsDialog)

function SelectNameModal:init(name, assets_list, settings, ...)
	Global.world_editor = Global.world_editor or {}
	Global.world_editor.filter = Global.world_editor.filter or ""
	self._dialog_name = self._dialog_name or name or "Assets"
	self._cancelled = true
	self._assets_list = assets_list

	CoreEditorEwsDialog.init(self, nil, self._dialog_name, "", Vector3(300, 150, 0), Vector3(350, 500, 0), "DEFAULT_DIALOG_STYLE,RESIZE_BORDER,STAY_ON_TOP", ...)
	self:create_panel("VERTICAL")

	local panel = self._panel
	local panel_sizer = self._panel_sizer

	panel:set_sizer(panel_sizer)

	local horizontal_ctrlr_sizer = EWS:BoxSizer("HORIZONTAL")
	local list_sizer = EWS:BoxSizer("VERTICAL")

	list_sizer:add(EWS:StaticText(panel, "Filter", 0, ""), 0, 0, "ALIGN_CENTER_HORIZONTAL")

	self._filter = EWS:TextCtrl(panel, Global.world_editor.filter, "", "TE_CENTRE")

	list_sizer:add(self._filter, 0, 0, "EXPAND")
	self._filter:connect("EVT_COMMAND_TEXT_UPDATED", callback(self, self, "update_filter"), nil)

	local list_style = settings and settings.list_style or "LC_SINGLE_SEL,LC_REPORT,LC_NO_HEADER,LC_SORT_ASCENDING"
	self._list = EWS:ListCtrl(panel, "", list_style)

	self._list:clear_all()
	self._list:append_column("Name")
	list_sizer:add(self._list, 1, 0, "EXPAND")
	horizontal_ctrlr_sizer:add(list_sizer, 3, 0, "EXPAND")
	panel_sizer:add(horizontal_ctrlr_sizer, 1, 0, "EXPAND")
	self._list:connect("EVT_COMMAND_LIST_ITEM_SELECTED", callback(self, self, "_on_mark_assett"), nil)
	self._list:connect("EVT_COMMAND_LIST_ITEM_ACTIVATED", callback(self, self, "_on_select_asset"), nil)
	self._list:connect("EVT_CHAR", callback(self, self, "key_delete"), "")
	self._list:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local button_sizer = EWS:BoxSizer("HORIZONTAL")

	self:_build_buttons(panel, button_sizer)
	panel_sizer:add(button_sizer, 0, 0, "ALIGN_RIGHT")
	self._dialog_sizer:add(self._panel, 1, 0, "EXPAND")
	self:fill_asset_list()
	self._dialog:set_visible(true)
	self:show_modal()
end

function SelectNameModal:_on_mark_assett()
end

function SelectNameModal:_on_select_asset()
end

function SelectNameModal:_build_buttons(panel, sizer)
	local select_btn = EWS:Button(panel, "Select", "", "BU_BOTTOM")

	sizer:add(select_btn, 0, 2, "RIGHT,LEFT")
	select_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "_on_select_asset"), "")
	select_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")

	local cancel_btn = EWS:Button(panel, "Cancel", "", "")

	sizer:add(cancel_btn, 0, 2, "RIGHT,LEFT")
	cancel_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_cancel"), "")
	cancel_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
end

function SelectNameModal:_on_select_asset()
	self._cancelled = false

	self._dialog:end_modal("hello")
end

function SelectNameModal:on_cancel()
	self._dialog:end_modal("hello")
end

function SelectNameModal:selected_assets()
	return self:_selected_item_assets()
end

function SelectNameModal:update_filter()
	Global.world_editor.filter = self._filter:get_value()

	self:fill_asset_list()
end

function SelectNameModal:cancelled()
	return self._cancelled
end

function SelectNameModal:fill_asset_list()
	self._list:delete_all_items()

	local filter = self._filter:get_value()
	filter = utf8.to_lower(utf8.from_latin1(filter))
	local j = 1
	self._assets = {}

	self._list:freeze()

	for _, asset in pairs(self._assets_list) do
		local l_asset = utf8.to_lower(utf8.from_latin1(asset))

		if string.find(l_asset, filter, 1, true) then
			local i = self._list:append_item(asset)
			self._assets[j] = asset

			self._list:set_item_data(i, j)

			j = j + 1
		end
	end

	self._list:thaw()
	self._list:autosize_column(0)
end

function SelectNameModal:key_delete(ctrlr, event)
	event:skip()

	if EWS:name_to_key_code("K_DELETE") == event:key_code() then
		self:_on_delete()
	end
end

function SelectNameModal:key_cancel(ctrlr, event)
	event:skip()

	if EWS:name_to_key_code("K_ESCAPE") == event:key_code() then
		self:on_cancel()
	end
end

function SelectNameModal:_on_delete()
end

function SelectNameModal:_selected_item_assets()
	local assets = {}

	for _, i in ipairs(self._list:selected_items()) do
		local asset = self._list:get_item(i, 0)

		table.insert(assets, asset)
	end

	return assets
end
