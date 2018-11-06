MissionFilterUnitElement = MissionFilterUnitElement or class(MissionElement)
MissionFilterUnitElement.SAVE_UNIT_POSITION = false
MissionFilterUnitElement.SAVE_UNIT_ROTATION = false

function MissionFilterUnitElement:init(unit)
	MissionFilterUnitElement.super.init(self, unit)

	self._hed[1] = true
	self._hed[2] = true
	self._hed[3] = true
	self._hed[4] = true
	self._hed[5] = true

	table.insert(self._save_values, 1)
	table.insert(self._save_values, 2)
	table.insert(self._save_values, 3)
	table.insert(self._save_values, 4)
	table.insert(self._save_values, 5)
end

function MissionFilterUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local var_1 = EWS:CheckBox(panel, "Mission filter 1", "")

	var_1:set_value(self._hed[1])
	var_1:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = 1,
		ctrlr = var_1
	})
	panel_sizer:add(var_1, 0, 0, "EXPAND")

	local var_2 = EWS:CheckBox(panel, "Mission filter 2", "")

	var_2:set_value(self._hed[2])
	var_2:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = 2,
		ctrlr = var_2
	})
	panel_sizer:add(var_2, 0, 0, "EXPAND")

	local var_3 = EWS:CheckBox(panel, "Mission filter 3", "")

	var_3:set_value(self._hed[3])
	var_3:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = 3,
		ctrlr = var_3
	})
	panel_sizer:add(var_3, 0, 0, "EXPAND")

	local var_4 = EWS:CheckBox(panel, "Mission filter 4", "")

	var_4:set_value(self._hed[4])
	var_4:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = 4,
		ctrlr = var_4
	})
	panel_sizer:add(var_4, 0, 0, "EXPAND")

	local var_5 = EWS:CheckBox(panel, "Mission filter 5", "")

	var_5:set_value(self._hed[5])
	var_5:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = 5,
		ctrlr = var_5
	})
	panel_sizer:add(var_5, 0, 0, "EXPAND")
end
