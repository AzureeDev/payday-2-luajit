CharacterTeamElement = CharacterTeamElement or class(MissionElement)
CharacterTeamElement.SAVE_UNIT_POSITION = false
CharacterTeamElement.SAVE_UNIT_ROTATION = false
CharacterTeamElement.LINK_ELEMENTS = {
	"elements"
}

function CharacterTeamElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.elements = {}
	self._hed.ignore_disabled = nil
	self._hed.team = ""
	self._hed.use_instigator = nil

	table.insert(self._save_values, "elements")
	table.insert(self._save_values, "ignore_disabled")
	table.insert(self._save_values, "team")
	table.insert(self._save_values, "use_instigator")
end

function CharacterTeamElement:draw_links(t, dt, selected_unit, all_units)
	MissionElement.draw_links(self, t, dt, selected_unit, all_units)
end

function CharacterTeamElement:update_editing()
end

function CharacterTeamElement:update_selected(t, dt, selected_unit, all_units)
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

function CharacterTeamElement:add_element()
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

function CharacterTeamElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

function CharacterTeamElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local names = {
		"ai_spawn_enemy",
		"ai_spawn_civilian"
	}

	self:_build_add_remove_unit_from_list(panel, panel_sizer, self._hed.elements, names)

	local use_instigator = EWS:CheckBox(panel, "Use instigator", "")

	use_instigator:set_value(self._hed.use_instigator)
	use_instigator:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "use_instigator",
		ctrlr = use_instigator
	})
	panel_sizer:add(use_instigator, 0, 0, "EXPAND")

	local ignore_disabled = EWS:CheckBox(panel, "Ignore disabled", "")

	ignore_disabled:set_tool_tip("Select if disabled spawn points should be ignored or not")
	ignore_disabled:set_value(self._hed.ignore_disabled)
	ignore_disabled:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "ignore_disabled",
		ctrlr = ignore_disabled
	})
	panel_sizer:add(ignore_disabled, 0, 0, "EXPAND")

	local team_params = {
		default = "",
		name = "Team:",
		ctrlr_proportions = 2,
		name_proportions = 1,
		tooltip = "Select wanted team for the character.",
		sorted = true,
		panel = panel,
		sizer = panel_sizer,
		options = tweak_data.levels:get_team_names_indexed(),
		value = self._hed.team
	}
	local team_combo_box = CoreEWS.combobox(team_params)

	team_combo_box:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "set_element_data"), {
		value = "team",
		ctrlr = team_combo_box
	})
	team_combo_box:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "team",
		ctrlr = team_combo_box
	})
end
