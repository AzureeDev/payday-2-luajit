CoreCounterResetUnitElement = CoreCounterResetUnitElement or class(MissionElement)
CoreCounterResetUnitElement.LINK_ELEMENTS = {
	"elements"
}
CounterResetUnitElement = CounterResetUnitElement or class(CoreCounterResetUnitElement)

function CounterResetUnitElement:init(...)
	CoreCounterResetUnitElement.init(self, ...)
end

function CoreCounterResetUnitElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.counter_target = 1
	self._hed.elements = {}

	table.insert(self._save_values, "counter_target")
	table.insert(self._save_values, "elements")
end

function CoreCounterResetUnitElement:draw_links(t, dt, selected_unit, all_units)
	MissionElement.draw_links(self, t, dt, selected_unit)

	for _, id in ipairs(self._hed.elements) do
		local unit = all_units[id]
		local draw = not selected_unit or unit == selected_unit or self._unit == selected_unit

		if draw then
			self:_draw_link({
				g = 0,
				b = 0,
				r = 0.75,
				from_unit = self._unit,
				to_unit = unit
			})
		end
	end
end

function CoreCounterResetUnitElement:update_editing()
end

function CoreCounterResetUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit and string.find(ray.unit:name():s(), "logic_counter/logic_counter", 1, true) then
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.elements, id) then
			table.delete(self._hed.elements, id)
		else
			table.insert(self._hed.elements, id)
		end
	end
end

function CoreCounterResetUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

function CoreCounterResetUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local names = {
		"logic_counter/logic_counter"
	}

	self:_build_add_remove_unit_from_list(panel, panel_sizer, self._hed.elements, names)

	local counter_target_params = {
		name = "Counter target:",
		ctrlr_proportions = 2,
		name_proportions = 1,
		tooltip = "Specifies what the selected counted should reset to",
		sorted = false,
		min = 0,
		floats = 0,
		panel = panel,
		sizer = panel_sizer,
		value = self._hed.counter_target
	}
	local counter_target = CoreEWS.number_controller(counter_target_params)

	counter_target:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "counter_target",
		ctrlr = counter_target
	})
	counter_target:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "counter_target",
		ctrlr = counter_target
	})
end
