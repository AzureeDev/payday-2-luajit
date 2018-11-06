SpawnCivilianGroupUnitElement = SpawnCivilianGroupUnitElement or class(MissionElement)
SpawnCivilianGroupUnitElement.LINK_ELEMENTS = {
	"elements"
}

function SpawnCivilianGroupUnitElement:init(unit)
	SpawnCivilianGroupUnitElement.super.init(self, unit)

	self._hed.random = false
	self._hed.ignore_disabled = true
	self._hed.amount = 1
	self._hed.elements = {}
	self._hed.team = "default"

	table.insert(self._save_values, "elements")
	table.insert(self._save_values, "random")
	table.insert(self._save_values, "ignore_disabled")
	table.insert(self._save_values, "amount")
	table.insert(self._save_values, "team")
end

function SpawnCivilianGroupUnitElement:draw_links(t, dt, selected_unit, all_units)
	SpawnCivilianGroupUnitElement.super.draw_links(self, t, dt, selected_unit, all_units)
end

function SpawnCivilianGroupUnitElement:update_editing()
end

function SpawnCivilianGroupUnitElement:update_selected(t, dt, selected_unit, all_units)
	for _, id in ipairs(self._hed.elements) do
		local unit = all_units[id]
		local draw = not selected_unit or unit == selected_unit or self._unit == selected_unit

		if draw then
			self:_draw_link({
				g = 0.75,
				b = 0,
				r = 0,
				from_unit = self._unit,
				to_unit = unit
			})
		end
	end
end

function SpawnCivilianGroupUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit and string.find(ray.unit:name():s(), "ai_spawn_civilian", 1, true) then
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.elements, id) then
			table.delete(self._hed.elements, id)
		else
			table.insert(self._hed.elements, id)
		end
	end
end

function SpawnCivilianGroupUnitElement:get_links_to_unit(...)
	SpawnCivilianGroupUnitElement.super.get_links_to_unit(self, ...)
	self:_get_links_of_type_from_elements(self._hed.elements, "spawn_point", ...)
end

function SpawnCivilianGroupUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

function SpawnCivilianGroupUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local names = {
		"ai_spawn_civilian"
	}

	self:_build_add_remove_unit_from_list(panel, panel_sizer, self._hed.elements, names)
	self:_build_value_checkbox(panel, panel_sizer, "random", "Select spawn points randomly")
	self:_build_value_checkbox(panel, panel_sizer, "ignore_disabled", "Select if disabled spawn points should be ignored or not")
	self:_build_value_number(panel, panel_sizer, "amount", {
		floats = 0,
		min = 0
	}, "Specify amount of civilians to spawn from group")
	self:_build_value_combobox(panel, panel_sizer, "team", table.list_add({
		"default"
	}, tweak_data.levels:get_team_names_indexed()), "Select the group's team (overrides character team).")
end
