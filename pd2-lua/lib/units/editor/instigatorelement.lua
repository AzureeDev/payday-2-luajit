InstigatorUnitElement = InstigatorUnitElement or class(MissionElement)
InstigatorUnitElement.SAVE_UNIT_POSITION = false
InstigatorUnitElement.SAVE_UNIT_ROTATION = false

function InstigatorUnitElement:init(unit)
	InstigatorUnitElement.super.init(self, unit)
end

function InstigatorUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_add_help_text("This element is a storage for an instigator. It can be used, set, etc from logic_instigator_operator.")
end

InstigatorOperatorUnitElement = InstigatorOperatorUnitElement or class(MissionElement)
InstigatorOperatorUnitElement.SAVE_UNIT_POSITION = false
InstigatorOperatorUnitElement.SAVE_UNIT_ROTATION = false
InstigatorOperatorUnitElement.LINK_ELEMENTS = {
	"elements"
}

function InstigatorOperatorUnitElement:init(unit)
	InstigatorOperatorUnitElement.super.init(self, unit)

	self._hed.elements = {}
	self._hed.operation = "none"
	self._hed.keep_on_use = false

	table.insert(self._save_values, "elements")
	table.insert(self._save_values, "operation")
	table.insert(self._save_values, "keep_on_use")
end

function InstigatorOperatorUnitElement:draw_links(t, dt, selected_unit, all_units)
	InstigatorOperatorUnitElement.super.draw_links(self, t, dt, selected_unit)

	for _, id in ipairs(self._hed.elements) do
		local unit = all_units[id]
		local draw = not selected_unit or unit == selected_unit or self._unit == selected_unit

		if draw then
			self:_draw_link({
				g = 0.85,
				b = 0.25,
				r = 0.85,
				from_unit = self._unit,
				to_unit = unit
			})
		end
	end
end

function InstigatorOperatorUnitElement:get_links_to_unit(...)
	InstigatorOperatorUnitElement.super.get_links_to_unit(self, ...)
	self:_get_links_of_type_from_elements(self._hed.elements, "operator", ...)
end

function InstigatorOperatorUnitElement:update_editing()
end

function InstigatorOperatorUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit and ray.unit:name() == Idstring("units/dev_tools/mission_elements/logic_instigator/logic_instigator") then
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.elements, id) then
			table.delete(self._hed.elements, id)
		else
			table.insert(self._hed.elements, id)
		end
	end
end

function InstigatorOperatorUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

function InstigatorOperatorUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local exact_names = {
		"units/dev_tools/mission_elements/logic_instigator/logic_instigator"
	}

	self:_build_add_remove_unit_from_list(panel, panel_sizer, self._hed.elements, nil, exact_names)
	self:_build_value_combobox(panel, panel_sizer, "operation", {
		"none",
		"set",
		"clear",
		"add_first",
		"add_last",
		"use_first",
		"use_last",
		"use_random",
		"use_all"
	}, "Select an operation for the selected elements")
	self:_build_value_checkbox(panel, panel_sizer, "keep_on_use")
	self:_add_help_text("This element is an operator to logic_instigator element.")
end

InstigatorTriggerUnitElement = InstigatorTriggerUnitElement or class(MissionElement)
InstigatorTriggerUnitElement.SAVE_UNIT_POSITION = false
InstigatorTriggerUnitElement.SAVE_UNIT_ROTATION = false
InstigatorTriggerUnitElement.LINK_ELEMENTS = {
	"elements"
}

function InstigatorTriggerUnitElement:init(unit)
	InstigatorTriggerUnitElement.super.init(self, unit)

	self._hed.trigger_type = "set"
	self._hed.elements = {}

	table.insert(self._save_values, "trigger_type")
	table.insert(self._save_values, "elements")
end

function InstigatorTriggerUnitElement:draw_links(t, dt, selected_unit, all_units)
	InstigatorTriggerUnitElement.super.draw_links(self, t, dt, selected_unit)

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

function InstigatorTriggerUnitElement:get_links_to_unit(...)
	InstigatorTriggerUnitElement.super.get_links_to_unit(self, ...)
	self:_get_links_of_type_from_elements(self._hed.elements, "trigger", ...)
end

function InstigatorTriggerUnitElement:update_editing()
end

function InstigatorTriggerUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit and ray.unit:name() == Idstring("units/dev_tools/mission_elements/logic_instigator/logic_instigator") then
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.elements, id) then
			table.delete(self._hed.elements, id)
		else
			table.insert(self._hed.elements, id)
		end
	end
end

function InstigatorTriggerUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

function InstigatorTriggerUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local exact_names = {
		"units/dev_tools/mission_elements/logic_instigator/logic_instigator"
	}

	self:_build_add_remove_unit_from_list(panel, panel_sizer, self._hed.elements, nil, exact_names)
	self:_build_value_combobox(panel, panel_sizer, "trigger_type", {
		"death",
		"set",
		"changed",
		"cleared"
	}, "Select a trigger type for the selected elements")
	self:_add_help_text("This element is a trigger to logic_instigator element.")
end
