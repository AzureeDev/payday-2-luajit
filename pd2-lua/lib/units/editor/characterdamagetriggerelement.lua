CharacterDamageTriggerUnitElement = CharacterDamageTriggerUnitElement or class(MissionElement)

function CharacterDamageTriggerUnitElement:init(unit)
	CharacterDamageTriggerUnitElement.super.init(self, unit)

	self._hed.elements = {}
	self._hed.damage_types = ""
	self._hed.percentage = false

	table.insert(self._save_values, "elements")
	table.insert(self._save_values, "damage_types")
	table.insert(self._save_values, "percentage")
end

function CharacterDamageTriggerUnitElement:draw_links(t, dt, selected_unit, all_units)
	MissionElement.draw_links(self, t, dt, selected_unit)

	for _, id in ipairs(self._hed.elements) do
		local unit = all_units[id]
		local draw = not selected_unit or unit == selected_unit or self._unit == selected_unit

		if draw then
			self:_draw_link({
				g = 0.85,
				b = 0,
				r = 0,
				from_unit = unit,
				to_unit = self._unit
			})
		end
	end
end

function CharacterDamageTriggerUnitElement:get_links_to_unit(...)
	CharacterDamageTriggerUnitElement.super.get_links_to_unit(self, ...)
	self:_get_links_of_type_from_elements(self._hed.elements, "trigger", ...)
end

function CharacterDamageTriggerUnitElement:update_editing()
end

function CharacterDamageTriggerUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit and self:_correct_unit(ray.unit:name():s()) then
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.elements, id) then
			table.delete(self._hed.elements, id)
		else
			table.insert(self._hed.elements, id)
		end
	end
end

function CharacterDamageTriggerUnitElement:_correct_unit(u_name)
	local names = {
		"ai_spawn_enemy",
		"ai_enemy_group",
		"ai_spawn_civilian",
		"ai_civilian_group",
		"point_spawn_player"
	}

	for _, name in ipairs(names) do
		if string.find(u_name, name, 1, true) then
			return true
		end
	end

	return false
end

function CharacterDamageTriggerUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

function CharacterDamageTriggerUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local dmg_sizer = EWS:BoxSizer("HORIZONTAL")

	dmg_sizer:add(EWS:StaticText(panel, "Damage Types Filter:", 0, ""), 1, 0, "ALIGN_CENTER_VERTICAL")

	local dmg_types = EWS:TextCtrl(panel, self._hed.damage_types, "", "TE_PROCESS_ENTER")

	dmg_types:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "damage_types",
		ctrlr = dmg_types
	})
	dmg_types:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "damage_types",
		ctrlr = dmg_types
	})
	dmg_sizer:add(dmg_types, 2, 0, "ALIGN_CENTER_VERTICAL")
	panel_sizer:add(dmg_sizer, 0, 0, "EXPAND")

	local percentage = EWS:CheckBox(panel, "Percentage", "")

	percentage:set_value(self._hed.percentage)
	percentage:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "percentage",
		ctrlr = percentage
	})
	panel_sizer:add(percentage, 0, 0, "EXPAND")
	self:add_help_text({
		text = "logic_counter_operator elements will use the reported <damage> as the amount to add/subtract/set.\nDamage types can be filtered by specifying specific damage types separated by spaces.",
		panel = panel,
		sizer = panel_sizer
	})
end
