CoreToggleUnitElement = CoreToggleUnitElement or class(MissionElement)
CoreToggleUnitElement.SAVE_UNIT_POSITION = false
CoreToggleUnitElement.SAVE_UNIT_ROTATION = false
CoreToggleUnitElement.LINK_ELEMENTS = {
	"elements"
}
ToggleUnitElement = ToggleUnitElement or class(CoreToggleUnitElement)

function ToggleUnitElement:init(...)
	CoreToggleUnitElement.init(self, ...)
end

function CoreToggleUnitElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.toggle = "on"
	self._hed.set_trigger_times = -1
	self._hed.elements = {}

	table.insert(self._save_values, "toggle")
	table.insert(self._save_values, "elements")
	table.insert(self._save_values, "set_trigger_times")
end

function CoreToggleUnitElement:draw_links(t, dt, selected_unit, all_units)
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

function CoreToggleUnitElement:get_links_to_unit(...)
	CoreToggleUnitElement.super.get_links_to_unit(self, ...)
	self:_get_links_of_type_from_elements(self._hed.elements, "operator", ...)
end

function CoreToggleUnitElement:update_editing()
end

function CoreToggleUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit then
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.elements, id) then
			table.delete(self._hed.elements, id)
		else
			table.insert(self._hed.elements, id)
		end
	end
end

function CoreToggleUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

function CoreToggleUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local names = nil

	self:_build_add_remove_unit_from_list(panel, panel_sizer, self._hed.elements, names)
	self:_build_value_combobox(panel, panel_sizer, "toggle", {
		"on",
		"off",
		"toggle"
	}, "Select how you want to toggle an element")
	self:_build_value_number(panel, panel_sizer, "set_trigger_times", {
		floats = 0,
		min = -1
	}, "Sets the elements trigger times when toggle on (-1 means do not use)")
end
