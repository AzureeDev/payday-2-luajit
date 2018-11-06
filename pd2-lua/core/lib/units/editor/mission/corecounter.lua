CoreCounterUnitElement = CoreCounterUnitElement or class(MissionElement)
CoreCounterUnitElement.SAVE_UNIT_POSITION = false
CoreCounterUnitElement.SAVE_UNIT_ROTATION = false
CoreCounterUnitElement.INSTANCE_VAR_NAMES = {
	{
		value = "counter_target",
		type = "number"
	}
}
CounterUnitElement = CounterUnitElement or class(CoreCounterUnitElement)

function CounterUnitElement:init(...)
	CoreCounterUnitElement.init(self, ...)
end

function CoreCounterUnitElement:init(unit)
	MissionElement.init(self, unit)

	self._digital_gui_units = {}
	self._hed.counter_target = 0
	self._hed.digital_gui_unit_ids = {}

	table.insert(self._save_values, "counter_target")
	table.insert(self._save_values, "digital_gui_unit_ids")
end

function CoreCounterUnitElement:layer_finished()
	MissionElement.layer_finished(self)

	for _, id in pairs(self._hed.digital_gui_unit_ids) do
		local unit = managers.worlddefinition:get_unit_on_load(id, callback(self, self, "load_unit"))

		if unit then
			self._digital_gui_units[unit:unit_data().unit_id] = unit
		end
	end
end

function CoreCounterUnitElement:load_unit(unit)
	if unit then
		self._digital_gui_units[unit:unit_data().unit_id] = unit
	end
end

function CoreCounterUnitElement:update_selected()
	for _, id in pairs(self._hed.digital_gui_unit_ids) do
		if not alive(self._digital_gui_units[id]) then
			table.delete(self._hed.digital_gui_unit_ids, id)

			self._digital_gui_units[id] = nil
		end
	end

	for id, unit in pairs(self._digital_gui_units) do
		if not alive(unit) then
			table.delete(self._hed.digital_gui_unit_ids, id)

			self._digital_gui_units[id] = nil
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

function CoreCounterUnitElement:update_unselected(t, dt, selected_unit, all_units)
	for _, id in pairs(self._hed.digital_gui_unit_ids) do
		if not alive(self._digital_gui_units[id]) then
			table.delete(self._hed.digital_gui_unit_ids, id)

			self._digital_gui_units[id] = nil
		end
	end

	for id, unit in pairs(self._digital_gui_units) do
		if not alive(unit) then
			table.delete(self._hed.digital_gui_unit_ids, id)

			self._digital_gui_units[id] = nil
		end
	end
end

function CoreCounterUnitElement:draw_links_unselected(...)
	CoreCounterUnitElement.super.draw_links_unselected(self, ...)

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

function CoreCounterUnitElement:update_editing()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "body editor",
		sample = true,
		mask = managers.slot:get_mask("all")
	})

	if ray and ray.unit and ray.unit:digital_gui() and ray.unit:digital_gui():is_number() then
		Application:draw(ray.unit, 0, 1, 0)
	end
end

function CoreCounterUnitElement:select_unit()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "body editor",
		sample = true,
		mask = managers.slot:get_mask("all")
	})

	if ray and ray.unit and ray.unit:digital_gui() and ray.unit:digital_gui():is_number() then
		local unit = ray.unit

		if self._digital_gui_units[unit:unit_data().unit_id] then
			self:_remove_unit(unit)
		else
			self:_add_unit(unit)
		end
	end
end

function CoreCounterUnitElement:_remove_unit(unit)
	self._digital_gui_units[unit:unit_data().unit_id] = nil

	table.delete(self._hed.digital_gui_unit_ids, unit:unit_data().unit_id)
end

function CoreCounterUnitElement:_add_unit(unit)
	self._digital_gui_units[unit:unit_data().unit_id] = unit

	table.insert(self._hed.digital_gui_unit_ids, unit:unit_data().unit_id)
end

function CoreCounterUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "select_unit"))
end

function CoreCounterUnitElement:_add_unit_filter(unit)
	if self._digital_gui_units[unit:unit_data().unit_id] then
		return false
	end

	return unit:digital_gui() and unit:digital_gui():is_number()
end

function CoreCounterUnitElement:_remove_unit_filter(unit)
	return self._digital_gui_units[unit:unit_data().unit_id]
end

function CoreCounterUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_add_remove_static_unit_from_list(panel, panel_sizer, {
		add_filter = callback(self, self, "_add_unit_filter"),
		add_result = callback(self, self, "_add_unit"),
		remove_filter = callback(self, self, "_remove_unit_filter"),
		remove_result = callback(self, self, "_remove_unit")
	})
	self:_build_value_number(panel, panel_sizer, "counter_target", {
		floats = 0,
		min = 0
	}, "Specifies how many times the counter should be executed before running its on executed")
	self:_add_help_text("Units with number gui extension can have their value updated from a counter.")
end

CoreCounterOperatorUnitElement = CoreCounterOperatorUnitElement or class(MissionElement)
CoreCounterOperatorUnitElement.SAVE_UNIT_POSITION = false
CoreCounterOperatorUnitElement.SAVE_UNIT_ROTATION = false
CoreCounterOperatorUnitElement.INSTANCE_VAR_NAMES = {
	{
		value = "amount",
		type = "number"
	}
}
CoreCounterOperatorUnitElement.LINK_ELEMENTS = {
	"elements"
}
CounterOperatorUnitElement = CounterOperatorUnitElement or class(CoreCounterOperatorUnitElement)

function CounterOperatorUnitElement:init(...)
	CounterOperatorUnitElement.super.init(self, ...)
end

function CoreCounterOperatorUnitElement:init(unit)
	CoreCounterOperatorUnitElement.super.init(self, unit)

	self._hed.operation = "none"
	self._hed.amount = 0
	self._hed.elements = {}

	table.insert(self._save_values, "operation")
	table.insert(self._save_values, "amount")
	table.insert(self._save_values, "elements")
end

function CoreCounterOperatorUnitElement:draw_links(t, dt, selected_unit, all_units)
	CoreCounterOperatorUnitElement.super.draw_links(self, t, dt, selected_unit)

	for _, id in ipairs(self._hed.elements) do
		local unit = all_units[id]
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
	end
end

function CoreCounterOperatorUnitElement:get_links_to_unit(...)
	CoreCounterOperatorUnitElement.super.get_links_to_unit(self, ...)
	self:_get_links_of_type_from_elements(self._hed.elements, "operator", ...)
end

function CoreCounterOperatorUnitElement:update_editing()
end

function CoreCounterOperatorUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit and ray.unit:name() == Idstring("core/units/mission_elements/logic_counter/logic_counter") then
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.elements, id) then
			table.delete(self._hed.elements, id)
		else
			table.insert(self._hed.elements, id)
		end
	end
end

function CoreCounterOperatorUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

function CoreCounterOperatorUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local names = {
		"logic_counter/logic_counter"
	}

	self:_build_add_remove_unit_from_list(panel, panel_sizer, self._hed.elements, names)
	self:_build_value_combobox(panel, panel_sizer, "operation", {
		"none",
		"add",
		"subtract",
		"reset",
		"set"
	}, "Select an operation for the selected elements")
	self:_build_value_number(panel, panel_sizer, "amount", {
		floats = 0,
		min = 0
	}, "Amount to add, subtract or set to the counters.")
	self:_add_help_text("This element can modify logic_counter element. Select counters to modify using insert and clicking on the elements.")
end

CoreCounterTriggerUnitElement = CoreCounterTriggerUnitElement or class(MissionElement)
CoreCounterTriggerUnitElement.SAVE_UNIT_POSITION = false
CoreCounterTriggerUnitElement.SAVE_UNIT_ROTATION = false
CoreCounterTriggerUnitElement.LINK_ELEMENTS = {
	"elements"
}
CounterTriggerUnitElement = CounterTriggerUnitElement or class(CoreCounterTriggerUnitElement)

function CounterTriggerUnitElement:init(...)
	CounterTriggerUnitElement.super.init(self, ...)
end

function CoreCounterTriggerUnitElement:init(unit)
	CoreCounterTriggerUnitElement.super.init(self, unit)

	self._hed.trigger_type = "value"
	self._hed.amount = 0
	self._hed.elements = {}

	table.insert(self._save_values, "trigger_type")
	table.insert(self._save_values, "amount")
	table.insert(self._save_values, "elements")
end

function CoreCounterTriggerUnitElement:draw_links(t, dt, selected_unit, all_units)
	CoreCounterTriggerUnitElement.super.draw_links(self, t, dt, selected_unit)

	for _, id in ipairs(self._hed.elements) do
		local unit = all_units[id]
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
	end
end

function CoreCounterTriggerUnitElement:get_links_to_unit(...)
	CoreCounterTriggerUnitElement.super.get_links_to_unit(self, ...)
	self:_get_links_of_type_from_elements(self._hed.elements, "trigger", ...)
end

function CoreCounterTriggerUnitElement:update_editing()
end

function CoreCounterTriggerUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit and ray.unit:name() == Idstring("core/units/mission_elements/logic_counter/logic_counter") then
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.elements, id) then
			table.delete(self._hed.elements, id)
		else
			table.insert(self._hed.elements, id)
		end
	end
end

function CoreCounterTriggerUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

function CoreCounterTriggerUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local names = {
		"logic_counter/logic_counter"
	}

	self:_build_add_remove_unit_from_list(panel, panel_sizer, self._hed.elements, names)
	self:_build_value_combobox(panel, panel_sizer, "trigger_type", {
		"none",
		"value",
		"add",
		"subtract",
		"reset",
		"set"
	}, "Select a trigger type for the selected elements")
	self:_build_value_number(panel, panel_sizer, "amount", {
		floats = 0
	}, "Specify value to trigger on.")
	self:_add_help_text("This element is a trigger to logic_counter element.")
end

CoreCounterFilterUnitElement = CoreCounterFilterUnitElement or class(MissionElement)
CoreCounterFilterUnitElement.SAVE_UNIT_POSITION = false
CoreCounterFilterUnitElement.SAVE_UNIT_ROTATION = false
CoreCounterFilterUnitElement.LINK_ELEMENTS = {
	"elements"
}
CounterFilterUnitElement = CounterFilterUnitElement or class(CoreCounterFilterUnitElement)

function CounterFilterUnitElement:init(...)
	CounterFilterUnitElement.super.init(self, ...)
end

function CoreCounterFilterUnitElement:init(unit)
	CoreCounterFilterUnitElement.super.init(self, unit)

	self._hed.needed_to_execute = "all"
	self._hed.value = 0
	self._hed.elements = {}
	self._hed.check_type = "equal"

	table.insert(self._save_values, "needed_to_execute")
	table.insert(self._save_values, "value")
	table.insert(self._save_values, "elements")
	table.insert(self._save_values, "check_type")
end

function CoreCounterFilterUnitElement:draw_links(t, dt, selected_unit, all_units)
	CoreCounterFilterUnitElement.super.draw_links(self, t, dt, selected_unit)

	for _, id in ipairs(self._hed.elements) do
		local unit = all_units[id]
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
	end
end

function CoreCounterFilterUnitElement:get_links_to_unit(...)
	CoreCounterFilterUnitElement.super.get_links_to_unit(self, ...)
	self:_get_links_of_type_from_elements(self._hed.elements, "filter", ...)
end

function CoreCounterFilterUnitElement:update_editing()
end

function CoreCounterFilterUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit and ray.unit:name() == Idstring("core/units/mission_elements/logic_counter/logic_counter") then
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.elements, id) then
			table.delete(self._hed.elements, id)
		else
			table.insert(self._hed.elements, id)
		end
	end
end

function CoreCounterFilterUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

function CoreCounterFilterUnitElement:_build_panel(panel, panel_sizer)
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
	self:_build_value_number(panel, panel_sizer, "value", {
		floats = 0
	}, "Specify value to trigger on.")
	self:_build_value_combobox(panel, panel_sizer, "check_type", {
		"equal",
		"less_than",
		"greater_than",
		"less_or_equal",
		"greater_or_equal",
		"counters_equal",
		"counters_not_equal"
	}, "Select which check operation to perform")
	self:_add_help_text("This element is a filter to logic_counter element.")
end
