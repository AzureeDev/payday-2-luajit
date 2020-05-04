CoreExtendedMultiChoiceDialog = CoreExtendedMultiChoiceDialog or class()

if Application:ews_enabled() then
	local ews = getmetatable(rawget(_G, "EWS"))

	assert(ews)
	rawset(ews, "ExtendedMultiChoiceDialog", function (ews, ...)
		return core_or_local("CoreExtendedMultiChoiceDialog", ...)
	end)
end

function CoreExtendedMultiChoiceDialog:init(parent, caption, message, pos, size, style, objects)
	self._objects = objects or {}
	self._dialog = EWS:Dialog(parent, caption or "", "", pos or Vector3(-1, -1, 0), size or Vector3(450, 500, 0), style or "CAPTION,SYSTEM_MENU,STAY_ON_TOP")
	local box = EWS:BoxSizer("VERTICAL")
	local lb_box = EWS:BoxSizer("HORIZONTAL")

	if message and message ~= "" then
		local message_text = EWS:StaticText(self._dialog, message, "", "")

		box:add(message_text, 0, 12, "EXPAND,ALL")

		local line = EWS:StaticLine(self._dialog, "", "")

		box:add(line, 0, 10, "EXPAND,BOTTOM")
	end

	self._left_list_box = EWS:ListBox(self._dialog, "", "", "LB_SORT")

	self._left_list_box:connect("", "EVT_COMMAND_LISTBOX_DOUBLECLICKED", callback(self, self, "on_left_box"), "")
	lb_box:add(self._left_list_box, 1, 4, "ALL,EXPAND")

	self._right_list_box = EWS:ListBox(self._dialog, "", "", "LB_SORT")

	self._right_list_box:connect("", "EVT_COMMAND_LISTBOX_DOUBLECLICKED", callback(self, self, "on_right_box"), "")
	lb_box:add(self._right_list_box, 1, 4, "ALL,EXPAND")
	box:add(lb_box, 1, 0, "EXPAND")

	local line = EWS:StaticLine(self._dialog, "", "")

	box:add(line, 0, 10, "EXPAND,TOP")

	local button_box = EWS:BoxSizer("HORIZONTAL")
	self._ok_btn = EWS:Button(self._dialog, "OK", "", "")

	self._ok_btn:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_ok_button"), "")
	button_box:add(self._ok_btn, 1, 10, "ALL,EXPAND")

	self._cancel_btn = EWS:Button(self._dialog, "Cancel", "", "")

	self._cancel_btn:connect("", "EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_cancel_button"), "")
	button_box:add(self._cancel_btn, 1, 10, "ALL,EXPAND")
	box:add(button_box, 0, 0, "EXPAND")
	self._dialog:set_sizer(box)
end

function CoreExtendedMultiChoiceDialog:show_modal()
	self._value_map = {}

	self._left_list_box:clear()
	self._right_list_box:clear()

	for _, object in ipairs(self._objects) do
		self._left_list_box:append(object)
	end

	return self._dialog:show_modal()
end

function CoreExtendedMultiChoiceDialog:on_ok_button()
	for i = 0, self._right_list_box:nr_items() - 1 do
		table.insert(self._value_map, self._right_list_box:get_string(i))
	end

	self._dialog:end_modal("ID_OK")
end

function CoreExtendedMultiChoiceDialog:on_cancel_button()
	self._dialog:end_modal("ID_CANCEL")
end

function CoreExtendedMultiChoiceDialog:on_left_box()
	local index = self._left_list_box:selected_index()

	if index > -1 then
		local selected = self._left_list_box:get_string(index)

		self._right_list_box:append(selected)
		self._left_list_box:remove(index)
	end
end

function CoreExtendedMultiChoiceDialog:on_right_box()
	local index = self._right_list_box:selected_index()

	if index > -1 then
		local selected = self._right_list_box:get_string(index)

		self._left_list_box:append(selected)
		self._right_list_box:remove(index)
	end
end

function CoreExtendedMultiChoiceDialog:get_value()
	return self._value_map
end
