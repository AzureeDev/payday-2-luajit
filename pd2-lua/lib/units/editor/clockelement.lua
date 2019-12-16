ClockUnitElement = ClockUnitElement or class(MissionElement)
ClockUnitElement.SAVE_UNIT_POSITION = false
ClockUnitElement.SAVE_UNIT_ROTATION = false
ClockUnitElement.LINK_ELEMENTS = {
	"elements"
}
ClockUnitElement.HOUR_COLOR = Color(0.34901960784313724, 0.16470588235294117, 0.44313725490196076)
ClockUnitElement.MINUTE_COLOR = Color(0.47843137254901963, 0.6196078431372549, 0.20784313725490197)
ClockUnitElement.SECOND_COLOR = Color(0.6666666666666666, 0.592156862745098, 0.2235294117647059)

function ClockUnitElement:init(unit)
	ClockUnitElement.super.init(self, unit)

	self._hed.modify_on_activate = true
	self._hed.hour_elements = {}
	self._hed.minute_elements = {}
	self._hed.second_elements = {}

	table.insert(self._save_values, "modify_on_activate")
	table.insert(self._save_values, "hour_elements")
	table.insert(self._save_values, "minute_elements")
	table.insert(self._save_values, "second_elements")
end

function ClockUnitElement:draw_links(t, dt, selected_unit, all_units)
	ClockUnitElement.super.draw_links(self, t, dt, selected_unit)
	self:_draw_clock_elements(self._hed.hour_elements, self.HOUR_COLOR, selected_unit, all_units)
	self:_draw_clock_elements(self._hed.minute_elements, self.MINUTE_COLOR, selected_unit, all_units)
	self:_draw_clock_elements(self._hed.second_elements, self.SECOND_COLOR, selected_unit, all_units)
end

function ClockUnitElement:_draw_clock_elements(elements, color, selected_unit, all_units)
	for _, id in ipairs(elements) do
		local unit = all_units[id]

		if not alive(unit) then
			table.delete(elements, id)
		else
			local draw = not selected_unit or unit == selected_unit or self._unit == selected_unit

			if draw then
				self:_draw_link({
					from_unit = self._unit,
					to_unit = unit,
					r = color.r,
					g = color.g,
					b = color.b
				})
			end
		end
	end
end

function ClockUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit and ray.unit:name() == Idstring("core/units/mission_elements/logic_counter/logic_counter") then
		local id = ray.unit:unit_data().unit_id

		print(id)
	end
end

function ClockUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

function ClockUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local start_trigger_sizer = EWS:StaticBoxSizer(panel, "VERTICAL")

	panel_sizer:add(start_trigger_sizer, 0, 0, "EXPAND")
	self:_build_value_checkbox(panel, start_trigger_sizer, "modify_on_activate", "Should this element modify logic_counter elements on startup", "Modify Elements On Enabled")

	local clock_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "Clock Modify Elements")

	panel_sizer:add(clock_sizer, 0, 0, "EXPAND")
	self:_build_clock_elements_sizer(panel, clock_sizer, self._hed.hour_elements, "Hours")
	self:_build_clock_elements_sizer(panel, clock_sizer, self._hed.minute_elements, "Minutes")
	self:_build_clock_elements_sizer(panel, clock_sizer, self._hed.second_elements, "Seconds")
	self:_add_help_text("This element can modify logic_counter elements using set operation when time changes. Select counters to modify using insert and clicking on the elements.")
end

function ClockUnitElement:_build_clock_elements_sizer(panel, clock_sizer, elements, text)
	local element_sizer = EWS:BoxSizer("HORIZONTAL")

	clock_sizer:add(element_sizer, 1, 1, "EXPAND,LEFT")

	local name_sizer = EWS:BoxSizer("VERTICAL")
	local value_sizer = EWS:BoxSizer("VERTICAL")

	element_sizer:add(name_sizer, 1, 1, "EXPAND,LEFT")
	element_sizer:add(value_sizer, 1, 1, "EXPAND,LEFT")

	local name_text = EWS:StaticText(panel, text, 0, "")

	name_sizer:add(name_text, 1, 1, "ALIGN_CENTER_VERTICAL")

	local names = {
		"logic_counter/logic_counter"
	}

	self:_build_add_remove_unit_from_list(panel, value_sizer, elements, names)
end
