AIRemoveUnitElement = AIRemoveUnitElement or class(MissionElement)
AIRemoveUnitElement.LINK_ELEMENTS = {
	"elements"
}

function AIRemoveUnitElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.elements = {}
	self._hed.use_instigator = false
	self._hed.true_death = false
	self._hed.force_ragdoll = false
	self._hed.backup_so = nil

	table.insert(self._save_values, "elements")
	table.insert(self._save_values, "use_instigator")
	table.insert(self._save_values, "true_death")
	table.insert(self._save_values, "force_ragdoll")
	table.insert(self._save_values, "backup_so")
end

function AIRemoveUnitElement:draw_links(t, dt, selected_unit, all_units)
	MissionElement.draw_links(self, t, dt, selected_unit, all_units)
end

function AIRemoveUnitElement:update_editing()
end

function AIRemoveUnitElement:update_selected(t, dt, selected_unit, all_units)
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

	if self._hed.backup_so then
		local unit = all_units[self._hed.backup_so]
		local draw = not selected_unit or unit == selected_unit or self._unit == selected_unit

		if draw then
			self:_draw_link({
				g = 0,
				b = 0.75,
				r = 0,
				from_unit = self._unit,
				to_unit = unit
			})
		end
	end
end

function AIRemoveUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit then
		if string.find(ray.unit:name():s(), "ai_spawn_enemy", 1, true) or string.find(ray.unit:name():s(), "ai_spawn_civilian", 1, true) then
			local id = ray.unit:unit_data().unit_id

			if table.contains(self._hed.elements, id) then
				table.delete(self._hed.elements, id)
			else
				table.insert(self._hed.elements, id)
			end
		elseif string.find(ray.unit:name():s(), "point_special_objective", 1, true) then
			local id = ray.unit:unit_data().unit_id

			if self._hed.backup_so == id then
				self._hed.backup_so = nil
			else
				self._hed.backup_so = id
			end
		end
	end
end

function AIRemoveUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

function AIRemoveUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local names = {
		"ai_spawn_enemy",
		"ai_spawn_civilian"
	}

	self:_build_add_remove_unit_from_list(panel, panel_sizer, self._hed.elements, names)

	local use_instigator = EWS:CheckBox(panel, "Remove instigator", "")

	use_instigator:set_value(self._hed.use_instigator)
	use_instigator:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "use_instigator",
		ctrlr = use_instigator
	})
	panel_sizer:add(use_instigator, 0, 0, "EXPAND")

	local true_death = EWS:CheckBox(panel, "True death", "")

	true_death:set_value(self._hed.true_death)
	true_death:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "true_death",
		ctrlr = true_death
	})
	panel_sizer:add(true_death, 0, 0, "EXPAND")

	local force_ragdoll = EWS:CheckBox(panel, "Force Ragdoll", "")

	force_ragdoll:set_value(self._hed.force_ragdoll)
	force_ragdoll:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "force_ragdoll",
		ctrlr = force_ragdoll
	})
	panel_sizer:add(force_ragdoll, 0, 0, "EXPAND")
end
