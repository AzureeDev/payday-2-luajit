core:import("CoreEditorUtils")
core:import("CoreEws")

EditLadder = EditLadder or class(EditUnitBase)

function EditLadder:init(editor)
	local panel, sizer = (editor or managers.editor):add_unit_edit_page({
		name = "Ladder",
		class = self
	})
	self._panel = panel
	self._width_params = {
		value = 0,
		name = "Width [cm]:",
		ctrlr_proportions = 1,
		name_proportions = 1,
		tooltip = "Sets the width of the ladder in cm",
		min = 0,
		floats = 0,
		panel = panel,
		sizer = sizer,
		events = {
			{
				event = "EVT_COMMAND_TEXT_ENTER",
				callback = callback(self, self, "_update_width")
			},
			{
				event = "EVT_KILL_FOCUS",
				callback = callback(self, self, "_update_width")
			}
		}
	}

	CoreEws.number_controller(self._width_params)

	self._height_params = {
		value = 0,
		name = "Height [cm]:",
		ctrlr_proportions = 1,
		name_proportions = 1,
		tooltip = "Sets the height of the ladder in cm",
		min = 0,
		floats = 0,
		panel = panel,
		sizer = sizer,
		events = {
			{
				event = "EVT_COMMAND_TEXT_ENTER",
				callback = callback(self, self, "_update_height")
			},
			{
				event = "EVT_KILL_FOCUS",
				callback = callback(self, self, "_update_height")
			}
		}
	}

	CoreEws.number_controller(self._height_params)

	self._pc_disabled_ctrlr = EWS:CheckBox(panel, "Disabled in PC", "")

	self._pc_disabled_ctrlr:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_pc_disabled"), nil)
	sizer:add(self._pc_disabled_ctrlr, 0, 0, "EXPAND")

	self._vr_disabled_ctrlr = EWS:CheckBox(panel, "Disabled in VR", "")

	self._vr_disabled_ctrlr:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_vr_disabled"), nil)
	sizer:add(self._vr_disabled_ctrlr, 0, 0, "EXPAND")
	panel:layout()
	panel:set_enabled(false)
end

function EditLadder:update(t, dt)
	for _, unit in ipairs(self._selected_units) do
		if unit:ladder() then
			unit:ladder():debug_draw()
		end
	end
end

function EditLadder:_update_width(params)
	for _, unit in ipairs(self._selected_units) do
		if unit:ladder() then
			unit:ladder():set_width(self._width_params.value)
		end
	end
end

function EditLadder:_update_height(params)
	for _, unit in ipairs(self._selected_units) do
		if unit:ladder() then
			unit:ladder():set_height(self._height_params.value)
		end
	end
end

function EditLadder:set_pc_disabled()
	for _, unit in ipairs(self._selected_units) do
		if unit:ladder() then
			unit:ladder():set_pc_disabled(self._pc_disabled_ctrlr:get_value())
		end
	end
end

function EditLadder:set_vr_disabled()
	for _, unit in ipairs(self._selected_units) do
		if unit:ladder() then
			unit:ladder():set_vr_disabled(self._vr_disabled_ctrlr:get_value())
		end
	end
end

function EditLadder:is_editable(unit, units)
	if alive(unit) and unit:ladder() then
		self._reference_unit = unit
		self._selected_units = units
		self._no_event = true

		CoreEws.change_entered_number(self._width_params, unit:ladder():width())
		CoreEws.change_entered_number(self._height_params, unit:ladder():height())
		self._pc_disabled_ctrlr:set_value(unit:ladder():pc_disabled())
		self._vr_disabled_ctrlr:set_value(unit:ladder():vr_disabled())

		self._no_event = false

		return true
	end

	self._selected_units = {}

	return false
end
