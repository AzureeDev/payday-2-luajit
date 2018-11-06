SetOutlineElement = SetOutlineElement or class(MissionElement)
SetOutlineElement.LINK_ELEMENTS = {
	"elements"
}

function SetOutlineElement:init(unit)
	SetOutlineElement.super.init(self, unit)

	self._hed.elements = {}
	self._hed.set_outline = true
	self._hed.use_instigator = false
	self._hed.clear_previous = false

	table.insert(self._save_values, "elements")
	table.insert(self._save_values, "set_outline")
	table.insert(self._save_values, "use_instigator")
	table.insert(self._save_values, "clear_previous")
end

function SetOutlineElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local names = {
		"ai_spawn_enemy",
		"ai_spawn_civilian"
	}

	self:_build_add_remove_unit_from_list(panel, panel_sizer, self._hed.elements, names)

	local set_outline = EWS:CheckBox(panel, "Enable outline", "")

	set_outline:set_value(self._hed.set_outline)
	set_outline:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "set_outline",
		ctrlr = set_outline
	})
	panel_sizer:add(set_outline, 0, 0, "EXPAND")
	self:_build_value_checkbox(panel, panel_sizer, "use_instigator", "Sets outline on the instigator")
	self:_build_value_checkbox(panel, panel_sizer, "clear_previous", "Clears any previously set outlines (fixes issue with escorts)")
end

function SetOutlineElement:draw_links(t, dt, selected_unit, all_units)
	MissionElement.draw_links(self, t, dt, selected_unit, all_units)
end

function SetOutlineElement:update_editing()
end

function SetOutlineElement:update_selected(t, dt, selected_unit, all_units)
	for _, id in ipairs(self._hed.elements) do
		local unit = all_units[id]
		local draw = not selected_unit or unit == selected_unit or self._unit == selected_unit

		if draw then
			self:_draw_link({
				g = 0.5,
				b = 1,
				r = 0.9,
				from_unit = self._unit,
				to_unit = unit
			})
		end
	end
end

function SetOutlineElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit and (string.find(ray.unit:name():s(), "ai_spawn_enemy", 1, true) or string.find(ray.unit:name():s(), "ai_spawn_civilian", 1, true)) then
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.elements, id) then
			table.delete(self._hed.elements, id)
		else
			table.insert(self._hed.elements, id)
		end
	end
end

function SetOutlineElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end
