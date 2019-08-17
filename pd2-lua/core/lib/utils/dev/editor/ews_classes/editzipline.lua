core:import("CoreEditorUtils")
core:import("CoreEws")

EditZipLine = EditZipLine or class(EditUnitBase)

function EditZipLine:init(editor)
	local panel, sizer = (editor or managers.editor):add_unit_edit_page({
		name = "ZipLine",
		class = self
	})
	self._panel = panel
	local end_pos_sizer = EWS:BoxSizer("HORIZONTAL")

	sizer:add(end_pos_sizer, 0, 0, "EXPAND")
	end_pos_sizer:add(EWS:StaticText(panel, "End pos:", 0, ""), 1, 0, "ALIGN_CENTER_VERTICAL")

	self._end_pos_ctrl = EWS:StaticText(panel, "0,0,0", 0, "")

	end_pos_sizer:add(self._end_pos_ctrl, 2, 0, "ALIGN_CENTER_VERTICAL")

	local btn_toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	btn_toolbar:add_tool("USE_CAMERA_POS", "Use camera pos for position end", CoreEws.image_path("tree_checkbox_unchecked_16x16.png"), nil)
	btn_toolbar:connect("USE_CAMERA_POS", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_use_camera_pos"), nil)
	btn_toolbar:add_tool("USE_CAMERA_POS_LINE", "Use camera pos for line position end", CoreEws.image_path("tree_checkbox_undecided_16x16.png"), nil)
	btn_toolbar:connect("USE_CAMERA_POS_LINE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_use_camera_pos_for_line"), nil)
	btn_toolbar:realize()
	end_pos_sizer:add(btn_toolbar, 0, 1, "EXPAND,LEFT")

	self._speed_params = {
		value = 0,
		name = "Speed [cm/s]:",
		ctrlr_proportions = 1,
		name_proportions = 1,
		tooltip = "Sets the speed of the zipline in cm/s",
		min = 0,
		floats = 0,
		panel = panel,
		sizer = sizer,
		events = {
			{
				event = "EVT_COMMAND_TEXT_ENTER",
				callback = callback(self, self, "_update_speed")
			},
			{
				event = "EVT_KILL_FOCUS",
				callback = callback(self, self, "_update_speed")
			}
		}
	}

	CoreEws.number_controller(self._speed_params)

	self._slack_params = {
		value = 0,
		name = "Slack [cm]:",
		ctrlr_proportions = 1,
		name_proportions = 1,
		tooltip = "Value to define slack of the zipline in cm",
		min = 0,
		floats = 0,
		panel = panel,
		sizer = sizer,
		events = {
			{
				event = "EVT_COMMAND_TEXT_ENTER",
				callback = callback(self, self, "_update_slack")
			},
			{
				event = "EVT_KILL_FOCUS",
				callback = callback(self, self, "_update_slack")
			}
		}
	}

	CoreEws.number_controller(self._slack_params)

	self._type_params = {
		sorted = true,
		name = "Type:",
		name_proportions = 1,
		ctrlr_proportions = 1,
		tooltip = "Select a type from the combobox",
		panel = panel,
		sizer = sizer,
		options = ZipLine.TYPES
	}

	CoreEws.combobox(self._type_params)
	self._type_params.ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_change_type"), nil)

	self._ai_ignores_bag = EWS:CheckBox(panel, "AI ignores bag", "")

	self._ai_ignores_bag:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_ai_ignores_bag"), nil)
	sizer:add(self._ai_ignores_bag, 0, 1, "EXPAND")
	panel:layout()
	panel:set_enabled(false)
end

function EditZipLine:update(t, dt)
	for _, unit in ipairs(self._selected_units) do
		if unit:zipline() then
			unit:zipline():debug_draw(t, dt)
		end
	end
end

function EditZipLine:_use_camera_pos()
	for _, unit in ipairs(self._selected_units) do
		if unit:zipline() then
			unit:zipline():set_end_pos(managers.editor:camera_position())
		end
	end
end

function EditZipLine:_use_camera_pos_for_line()
	for _, unit in ipairs(self._selected_units) do
		if unit:zipline() then
			unit:zipline():set_end_pos_by_line(managers.editor:camera_position())
		end
	end
end

function EditZipLine:_update_speed(params)
	for _, unit in ipairs(self._selected_units) do
		if unit:zipline() then
			unit:zipline():set_speed(self._speed_params.value)
		end
	end
end

function EditZipLine:_update_slack(params)
	for _, unit in ipairs(self._selected_units) do
		if unit:zipline() then
			unit:zipline():set_slack(self._slack_params.value)
		end
	end
end

function EditZipLine:_change_type()
	for _, unit in ipairs(self._selected_units) do
		if alive(unit) and unit:zipline() then
			local type = self._type_params.ctrlr:get_value()

			unit:zipline():set_usage_type(type)
		end
	end
end

function EditZipLine:set_ai_ignores_bag()
	for _, unit in ipairs(self._selected_units) do
		if alive(unit) and unit:zipline() then
			unit:zipline():set_ai_ignores_bag(self._ai_ignores_bag:get_value())
		end
	end
end

function EditZipLine:is_editable(unit, units)
	if alive(unit) and unit:zipline() then
		self._reference_unit = unit
		self._selected_units = units
		self._no_event = true

		self._end_pos_ctrl:set_label(tostring(unit:zipline():end_pos()))
		CoreEws.change_entered_number(self._speed_params, unit:zipline():speed())
		CoreEws.change_entered_number(self._slack_params, unit:zipline():slack())
		CoreEws.change_combobox_value(self._type_params, unit:zipline():usage_type())
		self._ai_ignores_bag:set_value(unit:zipline():ai_ignores_bag())

		self._no_event = false

		return true
	end

	self._selected_units = {}

	return false
end
