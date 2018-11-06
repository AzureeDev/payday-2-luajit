SelectUnitByNameModal = SelectUnitByNameModal or class(UnitByName)

function SelectUnitByNameModal:init(name, unit_filter_function, ...)
	UnitByName.init(self, name, unit_filter_function, ...)
	self:show_modal()
end

function SelectUnitByNameModal:_build_buttons(panel, sizer)
	local select_btn = EWS:Button(panel, "Select", "", "BU_BOTTOM")

	sizer:add(select_btn, 0, 2, "RIGHT,LEFT")
	select_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "_on_select_unit"), "")
	select_btn:connect("EVT_KEY_DOWN", callback(self, self, "key_cancel"), "")
	UnitByName._build_buttons(self, panel, sizer)
end

function SelectUnitByNameModal:_on_select_unit()
	self:end_modal()
end

function SelectUnitByNameModal:on_cancel()
	self._cancelled = true

	self:end_modal()
end

function SelectUnitByNameModal:end_modal()
	self._dialog:end_modal("hello")
end

function SelectUnitByNameModal:cancelled()
	return self._cancelled
end

function SelectUnitByNameModal:selected_units()
	return self:_selected_item_units()
end

SingleSelectUnitByNameModal = SingleSelectUnitByNameModal or class(SelectUnitByNameModal)
SingleSelectUnitByNameModal.STYLE = "LC_REPORT,LC_NO_HEADER,LC_SORT_ASCENDING,LC_SINGLE_SEL"
