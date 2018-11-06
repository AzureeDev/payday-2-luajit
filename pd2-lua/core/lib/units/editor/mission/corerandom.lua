CoreRandomUnitElement = CoreRandomUnitElement or class(MissionElement)
CoreRandomUnitElement.SAVE_UNIT_POSITION = false
CoreRandomUnitElement.SAVE_UNIT_ROTATION = false
RandomUnitElement = RandomUnitElement or class(CoreRandomUnitElement)

function RandomUnitElement:init(...)
	CoreRandomUnitElement.init(self, ...)
end

function CoreRandomUnitElement:init(unit)
	CoreRandomUnitElement.super.init(self, unit)

	self._hed.amount = 1
	self._hed.amount_random = 0
	self._hed.ignore_disabled = true
	self._hed.counter_id = nil

	table.insert(self._save_values, "amount")
	table.insert(self._save_values, "amount_random")
	table.insert(self._save_values, "ignore_disabled")
	table.insert(self._save_values, "counter_id")
end

function CoreRandomUnitElement:update_editing()
end

function CoreRandomUnitElement:draw_links(t, dt, selected_unit, all_units)
	CoreRandomUnitElement.super.draw_links(self, t, dt, selected_unit)

	if self._hed.counter_id then
		local unit = all_units[self._hed.counter_id]
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

function CoreRandomUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit and ray.unit:name() == Idstring("core/units/mission_elements/logic_counter/logic_counter") then
		local id = ray.unit:unit_data().unit_id

		if self._hed.counter_id == id then
			self._hed.counter_id = nil
		else
			self._hed.counter_id = id
		end
	end
end

function CoreRandomUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

function CoreRandomUnitElement:remove_links(unit)
	if self._hed.counter_id and self._hed.counter_id == unit:unit_data().unit_id then
		self._hed.counter_id = nil
	end
end

function CoreRandomUnitElement:_add_counter_filter(unit)
	return unit:name() == Idstring("core/units/mission_elements/logic_counter/logic_counter")
end

function CoreRandomUnitElement:_set_counter_id(unit)
	self._hed.counter_id = unit:unit_data().unit_id
end

function CoreRandomUnitElement:_remove_counter_filter(unit)
	return self._hed.counter_id == unit:unit_data().unit_id
end

function CoreRandomUnitElement:_remove_counter_id(unit)
	self._hed.counter_id = nil
end

function CoreRandomUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_add_remove_static_unit_from_list(panel, panel_sizer, {
		single = true,
		add_filter = callback(self, self, "_add_counter_filter"),
		add_result = callback(self, self, "_set_counter_id"),
		remove_filter = callback(self, self, "_remove_counter_filter"),
		remove_result = callback(self, self, "_remove_counter_id")
	})
	self:_build_value_number(panel, panel_sizer, "amount", {
		floats = 0,
		min = 1
	}, "Specifies the amount of elements to be executed")
	self:_build_value_number(panel, panel_sizer, "amount_random", {
		floats = 0,
		min = 0
	}, "Add a random amount to amount")
	self:_build_value_checkbox(panel, panel_sizer, "ignore_disabled")
	self:_add_help_text("Use 'Amount' only to specify an exact amount of elements to execute. Use 'Amount Random' to add a random amount to 'Amount' ('Amount' + random('Amount Random').")
end
