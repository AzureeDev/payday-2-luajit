StopwatchUnitElement = StopwatchUnitElement or class(MissionElement)
StopwatchUnitElement.ELEMENT_NAME = "units/dev_tools/mission_elements/logic_stopwatch/logic_stopwatch"

function StopwatchUnitElement:init(unit)
	StopwatchUnitElement.super.init(self, unit)

	self._digital_gui_units = {}
	self._hed.timer = {
		0,
		0
	}
	self._hed.digital_gui_unit_ids = {}

	table.insert(self._save_values, "timer")
	table.insert(self._save_values, "digital_gui_unit_ids")
end

function StopwatchUnitElement:layer_finished()
	MissionElement.layer_finished(self)

	for _, id in pairs(self._hed.digital_gui_unit_ids) do
		local unit = managers.worlddefinition:get_unit_on_load(id, callback(self, self, "load_unit"))

		if unit then
			self._digital_gui_units[unit:unit_data().unit_id] = unit
		end
	end
end

function StopwatchUnitElement:load_unit(unit)
	if unit then
		self._digital_gui_units[unit:unit_data().unit_id] = unit
	end
end

function StopwatchUnitElement:update_selected()
	for _, id in pairs(self._hed.digital_gui_unit_ids) do
		if not alive(self._digital_gui_units[id]) then
			self:_remove_unit(managers.editor:unit_with_id(id))
		end
	end

	for id, unit in pairs(self._digital_gui_units) do
		if not alive(unit) then
			self:_remove_unit(managers.editor:unit_with_id(id))
		else
			local params = {
				g = 1,
				b = 0,
				r = 0,
				from_unit = self._unit,
				to_unit = unit
			}

			self:_draw_link(params)
			Application:draw(unit, 0, 1, 0)
		end
	end
end

function StopwatchUnitElement:update_unselected(t, dt, selected_unit, all_units)
	for _, id in pairs(self._hed.digital_gui_unit_ids) do
		if not alive(self._digital_gui_units[id]) then
			self:_remove_unit(managers.editor:unit_with_id(id))
		end
	end

	for id, unit in pairs(self._digital_gui_units) do
		if not alive(unit) then
			self:_remove_unit(managers.editor:unit_with_id(id))
		end
	end
end

function StopwatchUnitElement:draw_links_unselected(...)
	StopwatchUnitElement.super.draw_links_unselected(self, ...)

	for id, unit in pairs(self._digital_gui_units) do
		local params = {
			g = 0.5,
			b = 0,
			r = 0,
			from_unit = self._unit,
			to_unit = unit
		}

		self:_draw_link(params)
		Application:draw(unit, 0, 0.5, 0)
	end
end

function StopwatchUnitElement:update_editing()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "body editor",
		sample = true,
		mask = managers.slot:get_mask("all")
	})

	if ray and ray.unit and ray.unit:digital_gui() and ray.unit:digital_gui():is_timer() then
		Application:draw(ray.unit, 0, 1, 0)
	end
end

function StopwatchUnitElement:select_unit()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "body editor",
		sample = true,
		mask = managers.slot:get_mask("all")
	})

	if ray and ray.unit and ray.unit:digital_gui() and ray.unit:digital_gui():is_timer() then
		local unit = ray.unit

		if self._digital_gui_units[unit:unit_data().unit_id] then
			self:_remove_unit(unit)
		else
			self:_add_unit(unit)
		end
	end
end

function StopwatchUnitElement:_remove_unit(unit)
	self:remove_link_element("digital_gui_unit_ids", unit:unit_data().unit_id)
end

function StopwatchUnitElement:_add_unit(unit)
	self:add_link_element("digital_gui_unit_ids", unit:unit_data().unit_id)
end

function StopwatchUnitElement:on_added_link_element(element_name, unit_id)
	self._digital_gui_units[unit_id] = managers.editor:unit_with_id(unit_id)
end

function StopwatchUnitElement:on_removed_link_element(element_name, unit_id)
	self._digital_gui_units[unit_id] = nil
end

function StopwatchUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "select_unit"))
end

function StopwatchUnitElement:_add_unit_filter(unit)
	if self._digital_gui_units[unit:unit_data().unit_id] then
		return false
	end

	return unit:digital_gui() and unit:digital_gui():is_timer()
end

function StopwatchUnitElement:_remove_unit_filter(unit)
	return self._digital_gui_units[unit:unit_data().unit_id]
end

function StopwatchUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_add_remove_static_unit_from_list(panel, panel_sizer, {
		add_filter = callback(self, self, "_add_unit_filter"),
		add_result = callback(self, self, "_add_unit"),
		remove_filter = callback(self, self, "_remove_unit_filter"),
		remove_result = callback(self, self, "_remove_unit")
	})
	self:_add_help_text("Creates a stopwatch element. Continuously counts up once started until stopped or paused. Can be operated on using the logic_stopwatch_operator. Can be displayed on a digital gui.")
end

StopwatchOperatorUnitElement = StopwatchOperatorUnitElement or class(MissionElement)
StopwatchOperatorUnitElement.RANDOMS = {
	"time"
}
StopwatchOperatorUnitElement.LINK_ELEMENTS = {
	"elements"
}

function StopwatchOperatorUnitElement:init(unit)
	StopwatchOperatorUnitElement.super.init(self, unit)

	self._hed.operation = "none"
	self._hed.save_key = ""
	self._hed.condition = "always"
	self._hed.time = {
		0,
		0
	}
	self._hed.elements = {}

	table.insert(self._save_values, "operation")
	table.insert(self._save_values, "save_key")
	table.insert(self._save_values, "condition")
	table.insert(self._save_values, "time")
	table.insert(self._save_values, "elements")
end

function StopwatchOperatorUnitElement:draw_links(t, dt, selected_unit, all_units)
	StopwatchOperatorUnitElement.super.draw_links(self, t, dt, selected_unit)

	for _, id in ipairs(self._hed.elements) do
		local unit = all_units[id]

		if alive(unit) then
			local draw = not selected_unit or unit == selected_unit or self._unit == selected_unit

			if draw then
				self:_draw_link({
					g = 0.75,
					b = 0.25,
					r = 0.75,
					from_unit = self._unit,
					to_unit = unit
				})
			end
		else
			self:remove_link_element("elements", id)
		end
	end
end

function StopwatchOperatorUnitElement:get_links_to_unit(...)
	StopwatchOperatorUnitElement.super.get_links_to_unit(self, ...)
	self:_get_links_of_type_from_elements(self._hed.elements, "operator", ...)
end

function StopwatchOperatorUnitElement:update_editing()
end

function StopwatchOperatorUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit and ray.unit:name() == Idstring(StopwatchUnitElement.ELEMENT_NAME) then
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.elements, id) then
			table.delete(self._hed.elements, id)
			self:remove_link_element("elements", id)
		else
			table.insert(self._hed.elements, id)
			self:add_link_element("elements", id)
		end
	end
end

function StopwatchOperatorUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

function StopwatchOperatorUnitElement:set_element_data(data)
	StopwatchOperatorUnitElement.super.set_element_data(self, data)
	self._value_time:set_enabled(false)
	self._combo_save_condition:set_enabled(false)
	self._text_save_key:set_enabled(false)

	local value = self._combo_operation:get_value()

	if value == "none" then
		self._help_text:set_value(self._default_help_text)
	elseif value == "pause" then
		self._help_text:set_value(self._default_help_text .. "Pauses the stopwatch.")
	elseif value == "start" then
		self._help_text:set_value(self._default_help_text .. "Starts the stopwatch counting up.")
	elseif value == "add_time" then
		self._help_text:set_value(self._default_help_text .. "Adds the time (+random) to the stopwatch's running time.")
		self._value_time:set_enabled(true)
	elseif value == "subtract_time" then
		self._help_text:set_value(self._default_help_text .. "Subtracts the time (+random) from the stopwatch's running time.")
		self._value_time:set_enabled(true)
	elseif value == "reset" then
		self._help_text:set_value(self._default_help_text .. "Resets the stopwatch to 0 seconds.")
	elseif value == "set_time" then
		self._help_text:set_value(self._default_help_text .. "Sets the stopwatch's running time to time (+random).")
		self._value_time:set_enabled(true)
	elseif value == "save_time" then
		self._help_text:set_value(self._default_help_text .. "Saves the running time of the stopwatch to a mission value defined in 'Save/Load Key.'\nThe time will only be saved if it's operator is always or equal to/less than/greater than the saved value (if a saved value exists).")
		self._combo_save_condition:set_enabled(true)
		self._text_save_key:set_enabled(true)
	elseif value == "load_time" then
		self._help_text:set_value(self._default_help_text .. "Loads the stopwatch time from the mission value defined in 'Save/Load Key.' The time will not be changed if no time was loaded.")
		self._text_save_key:set_enabled(true)
	end
end

function StopwatchOperatorUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local names = {
		"logic_stopwatch/logic_stopwatch"
	}

	self:_build_add_remove_unit_from_list(panel, panel_sizer, self._hed.elements, names)

	self._combo_operation = self:_build_value_combobox(panel, panel_sizer, "operation", {
		"none",
		"pause",
		"start",
		"add_time",
		"subtract_time",
		"reset",
		"set_time",
		"save_time",
		"load_time"
	}, "Select an operation for the selected elements")
	self._value_time = self:_build_value_random_number(panel, panel_sizer, "time", {
		floats = 1,
		min = 0
	}, "Amount of time to add, subtract or set to the stopwatch. Used as the default time if can not load the stopwatch.")
	local key_sizer = EWS:BoxSizer("HORIZONTAL")

	panel_sizer:add(key_sizer, 0, 0, "EXPAND")

	local key_name = EWS:StaticText(panel, "Save/Load Key:", 0, "")

	key_sizer:add(key_name, 1, 0, "ALIGN_CENTER_VERTICAL")

	self._text_save_key = EWS:TextCtrl(panel, self._hed.save_key, "", "TE_PROCESS_ENTER")

	key_sizer:add(self._text_save_key, 2, 0, "ALIGN_CENTER_VERTICAL")
	self._text_save_key:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "save_key",
		ctrlr = self._text_save_key
	})
	self._text_save_key:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "save_key",
		ctrlr = self._text_save_key
	})

	self._combo_save_condition = self:_build_value_combobox(panel, panel_sizer, "condition", {
		"always",
		"equal",
		"less_than",
		"greater_than",
		"less_or_equal",
		"greater_or_equal"
	}, "Select a condition for which the stopwatch value will be saved if a value for the stopwatch is already saved. eg. save if less than the saved value.", "Save Condition")
	self._default_help_text = "This element can modify logic_stopwatch element. Select stopwatch to modify by inserting it.\n\n"
	self._help_text = self:_add_help_text(self._default_help_text)

	self:set_element_data({})
end

StopwatchTriggerUnitElement = StopwatchTriggerUnitElement or class(MissionElement)
StopwatchTriggerUnitElement.LINK_ELEMENTS = {
	"elements"
}

function StopwatchTriggerUnitElement:init(unit)
	StopwatchTriggerUnitElement.super.init(self, unit)

	self._hed.time = 0
	self._hed.elements = {}

	table.insert(self._save_values, "time")
	table.insert(self._save_values, "elements")
end

function StopwatchTriggerUnitElement:draw_links(t, dt, selected_unit, all_units)
	StopwatchTriggerUnitElement.super.draw_links(self, t, dt, selected_unit)

	for _, id in ipairs(self._hed.elements) do
		local unit = all_units[id]

		if alive(unit) then
			local draw = not selected_unit or unit == selected_unit or self._unit == selected_unit

			if draw then
				self:_draw_link({
					g = 0.85,
					b = 0.25,
					r = 0.85,
					from_unit = unit,
					to_unit = self._unit
				})
			end
		else
			self:remove_link_element("elements", id)
		end
	end
end

function StopwatchTriggerUnitElement:get_links_to_unit(...)
	StopwatchTriggerUnitElement.super.get_links_to_unit(self, ...)
	self:_get_links_of_type_from_elements(self._hed.elements, "trigger", ...)
end

function StopwatchTriggerUnitElement:update_editing()
end

function StopwatchTriggerUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit then
		if ray.unit:name() == Idstring(StopwatchUnitElement.ELEMENT_NAME) then
			local id = ray.unit:unit_data().unit_id

			if table.contains(self._hed.elements, id) then
				self:remove_link_element("elements", id)
			else
				self:add_link_element("elements", id)
			end
		else
			self:add_on_executed(ray.unit)
		end
	end
end

function StopwatchTriggerUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

function StopwatchTriggerUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local names = {
		"logic_stopwatch/logic_stopwatch"
	}

	self:_build_add_remove_unit_from_list(panel, panel_sizer, self._hed.elements, names)
	self:_build_value_number(panel, panel_sizer, "time", {
		floats = 1,
		min = 0
	}, "Specify at what time on the stopwatch this should trigger.")
	self:_add_help_text("This element is a trigger to logic_stopwatch element.")
end

StopwatchFilterUnitElement = StopwatchFilterUnitElement or class(MissionElement)
StopwatchFilterUnitElement.SAVE_UNIT_POSITION = false
StopwatchFilterUnitElement.SAVE_UNIT_ROTATION = false
StopwatchFilterUnitElement.LINK_ELEMENTS = {
	"elements"
}

function StopwatchFilterUnitElement:init(unit)
	StopwatchFilterUnitElement.super.init(self, unit)

	self._hed.needed_to_execute = "all"
	self._hed.value = 0
	self._hed.stopwatch_value_ids = {}
	self._hed.elements = {}
	self._hed.check_type = "equal"

	table.insert(self._save_values, "needed_to_execute")
	table.insert(self._save_values, "value")
	table.insert(self._save_values, "stopwatch_value_ids")
	table.insert(self._save_values, "elements")
	table.insert(self._save_values, "check_type")
end

function StopwatchFilterUnitElement:draw_links(t, dt, selected_unit, all_units)
	StopwatchFilterUnitElement.super.draw_links(self, t, dt, selected_unit)

	local function draw_link_element(element_name, id, r, g, b)
		local unit = all_units[id]

		if alive(unit) then
			local draw = not selected_unit or unit == selected_unit or self._unit == selected_unit

			if draw then
				self:_draw_link({
					from_unit = unit,
					to_unit = self._unit,
					r = r or 0.85,
					g = g or 0.85,
					b = b or 0.25
				})
			end
		else
			self:remove_link_element(element_name, id)
		end
	end

	for _, id in ipairs(self._hed.elements) do
		draw_link_element("elements", id)
	end

	for _, id in ipairs(self._hed.stopwatch_value_ids) do
		draw_link_element("stopwatch_value_ids", id, 0.01, 0.85, 0.85)
	end
end

function StopwatchFilterUnitElement:get_links_to_unit(...)
	StopwatchFilterUnitElement.super.get_links_to_unit(self, ...)
	self:_get_links_of_type_from_elements(self._hed.elements, "filter", ...)
end

function StopwatchFilterUnitElement:update_editing()
end

function StopwatchFilterUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit and ray.unit:name() == Idstring(StopwatchUnitElement.ELEMENT_NAME) then
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.elements, id) then
			self:remove_link_element("elements", id)
		else
			self:add_link_element("elements", id)
		end
	end
end

function StopwatchFilterUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

function StopwatchFilterUnitElement:_add_stopwatch_value_unit(params)
	local dialog = (params.single and SingleSelectUnitByNameModal or SelectUnitByNameModal):new("Add Stopwatch Unit", params.add_filter)

	for _, unit in ipairs(dialog:selected_units()) do
		local id = unit:unit_data().unit_id

		params.add_result(unit)
	end
end

function StopwatchFilterUnitElement:_add_unit(unit)
	if #self._hed.stopwatch_value_ids > 0 then
		self:_clear_connected_stopwatch_value()
	end

	self:add_link_element("stopwatch_value_ids", unit:unit_data().unit_id)
	self._value_ctrl:set_enabled(false)
	self._value_ctrl:set_value(string.format("Using stopwatch time from '%s' as value", unit:unit_data().name_id))
end

function StopwatchFilterUnitElement:_add_unit_filter(unit)
	return unit:name() == Idstring(StopwatchUnitElement.ELEMENT_NAME)
end

function StopwatchFilterUnitElement:_clear_connected_stopwatch_value(params)
	for idx, unit_id in ipairs(self._hed.stopwatch_value_ids) do
		self:remove_link_element("stopwatch_value_ids", unit_id)
	end

	self._value_ctrl:set_enabled(true)
	self._value_ctrl:set_value(self._hed.value)
end

function StopwatchFilterUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local names = {
		"logic_counter/logic_counter"
	}

	self:_build_add_remove_unit_from_list(panel, panel_sizer, self._hed.elements, names)
	self:_build_value_combobox(panel, panel_sizer, "needed_to_execute", {
		"all",
		"any"
	}, "Select how many elements are needed to execute")

	local horizontal_sizer = EWS:BoxSizer("HORIZONTAL")

	panel_sizer:add(horizontal_sizer, 0, 1, "EXPAND,LEFT")

	local number_params = {
		name = "Value:",
		name_proportions = 1,
		ctrlr_proportions = 2,
		sizer_proportions = 1,
		tooltip = "Specify value to trigger on.",
		panel = panel,
		sizer = horizontal_sizer,
		value = self._hed.value
	}
	local ctrlr = CoreEws.number_controller(number_params)

	ctrlr:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "value",
		ctrlr = ctrlr
	})
	ctrlr:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "value",
		ctrlr = ctrlr
	})

	self._value_ctrl = ctrlr

	if #self._hed.stopwatch_value_ids > 0 then
		local unit = managers.editor:unit_with_id(self._hed.stopwatch_value_ids[1])

		if unit then
			self._value_ctrl:set_enabled(false)
			self._value_ctrl:set_value(string.format("Using stopwatch time from '%s' as value", unit:unit_data().name_id))
		end
	end

	local toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	toolbar:add_tool("SELECT_NAME_LIST", "Select stopwatch unit to use as value", CoreEws.image_path("world_editor\\unit_by_name_list.png"), nil)
	toolbar:connect("SELECT_NAME_LIST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_add_stopwatch_value_unit"), {
		add_filter = callback(self, self, "_add_unit_filter"),
		add_result = callback(self, self, "_add_unit")
	})
	toolbar:add_tool("REMOVE_NAME_LIST", "Remove stopwatch unit being used as value", CoreEws.image_path("toolbar\\delete_16x16.png"), nil)
	toolbar:connect("REMOVE_NAME_LIST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_clear_connected_stopwatch_value"), {})
	toolbar:realize()
	horizontal_sizer:add(toolbar, 0, 1, "EXPAND,LEFT")
	self:_build_value_combobox(panel, panel_sizer, "check_type", {
		"equal",
		"less_than",
		"greater_than",
		"less_or_equal",
		"greater_or_equal"
	}, "Select which check operation to perform")
	self:_add_help_text("This element is a filter to logic_stopwatch element.")
end
