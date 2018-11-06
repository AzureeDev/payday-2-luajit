SpawnEnemyGroupUnitElement = SpawnEnemyGroupUnitElement or class(MissionElement)
SpawnEnemyGroupUnitElement.SAVE_UNIT_POSITION = false
SpawnEnemyGroupUnitElement.SAVE_UNIT_ROTATION = false
SpawnEnemyGroupUnitElement.RANDOMS = {
	"amount"
}
SpawnEnemyGroupUnitElement.LINK_ELEMENTS = {
	"elements"
}

function SpawnEnemyGroupUnitElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.spawn_type = "ordered"
	self._hed.ignore_disabled = true
	self._hed.amount = {
		0,
		0
	}
	self._hed.elements = {}
	self._hed.interval = 0
	self._hed.team = "default"

	table.insert(self._save_values, "elements")
	table.insert(self._save_values, "spawn_type")
	table.insert(self._save_values, "ignore_disabled")
	table.insert(self._save_values, "amount")
	table.insert(self._save_values, "preferred_spawn_groups")
	table.insert(self._save_values, "interval")
	table.insert(self._save_values, "team")
end

function SpawnEnemyGroupUnitElement:post_init(...)
	SpawnEnemyGroupUnitElement.super.post_init(self, ...)

	if self._hed.preferred_spawn_groups then
		local i = 1

		while i <= #self._hed.preferred_spawn_groups do
			if not tweak_data.group_ai.enemy_spawn_groups[self._hed.preferred_spawn_groups[i]] then
				table.remove(self._hed.preferred_spawn_groups, i)
			else
				i = i + 1
			end
		end

		if not next(self._hed.preferred_spawn_groups) then
			self._hed.preferred_spawn_groups = nil
		end
	end

	if self._hed.random ~= nil then
		self._hed.spawn_type = self._hed.random and "random" or "ordered"
		self._hed.random = nil
	end
end

function SpawnEnemyGroupUnitElement:draw_links(t, dt, selected_unit, all_units)
	MissionElement.draw_links(self, t, dt, selected_unit, all_units)
end

function SpawnEnemyGroupUnitElement:update_editing()
end

function SpawnEnemyGroupUnitElement:update_selected(t, dt, selected_unit, all_units)
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

function SpawnEnemyGroupUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit and string.find(ray.unit:name():s(), "ai_spawn_enemy", 1, true) then
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.elements, id) then
			table.delete(self._hed.elements, id)
		else
			table.insert(self._hed.elements, id)
		end
	end
end

function SpawnEnemyGroupUnitElement:get_links_to_unit(...)
	SpawnEnemyGroupUnitElement.super.get_links_to_unit(self, ...)
	self:_get_links_of_type_from_elements(self._hed.elements, "spawn_point", ...)
end

function SpawnEnemyGroupUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

function SpawnEnemyGroupUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local names = {
		"ai_spawn_enemy"
	}

	self:_build_add_remove_unit_from_list(panel, panel_sizer, self._hed.elements, names)
	self:_build_value_combobox(panel, panel_sizer, "spawn_type", table.list_add({
		"ordered"
	}, {
		"random",
		"group",
		"group_guaranteed"
	}), "Specify how the enemy will be spawned.")
	self:_build_value_checkbox(panel, panel_sizer, "ignore_disabled", "Select if disabled spawn points should be ignored or not")
	self:_build_value_random_number(panel, panel_sizer, "amount", {
		floats = 0,
		min = 0
	}, "Specify amount of enemies to spawn from group")
	self:_build_value_number(panel, panel_sizer, "interval", {
		floats = 0,
		min = 0
	}, "Used to specify how often this spawn can be used. 0 means no interval")
	self:_build_value_combobox(panel, panel_sizer, "team", table.list_add({
		"default"
	}, tweak_data.levels:get_team_names_indexed()), "Select the group's team (overrides character team).")

	local opt_sizer = panel_sizer
	local filter_sizer = EWS:BoxSizer("HORIZONTAL")
	local opt1_sizer = EWS:BoxSizer("VERTICAL")
	local opt2_sizer = EWS:BoxSizer("VERTICAL")
	local opt3_sizer = EWS:BoxSizer("VERTICAL")
	self._spawn_groups = {}

	for cat_name, team in pairs(tweak_data.group_ai.enemy_spawn_groups) do
		table.insert(self._spawn_groups, cat_name)
	end

	for i, o in ipairs(self._spawn_groups) do
		local check = EWS:CheckBox(panel, o, "")

		if self._hed.preferred_spawn_groups and table.contains(self._hed.preferred_spawn_groups, o) then
			check:set_value(true)
		else
			check:set_value(false)
		end

		check:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
			ctrlr = check,
			value = o
		})

		if i <= math.round(#self._spawn_groups / 3) then
			opt1_sizer:add(check, 0, 0, "EXPAND")
		elseif i <= math.round(#self._spawn_groups / 3) * 2 then
			opt2_sizer:add(check, 0, 0, "EXPAND")
		else
			opt3_sizer:add(check, 0, 0, "EXPAND")
		end
	end

	filter_sizer:add(opt1_sizer, 1, 0, "EXPAND")
	filter_sizer:add(opt2_sizer, 1, 0, "EXPAND")
	filter_sizer:add(opt3_sizer, 1, 0, "EXPAND")
	opt_sizer:add(filter_sizer, 1, 0, "EXPAND")
end

function SpawnEnemyGroupUnitElement:set_element_data(data)
	SpecialObjectiveUnitElement.super.set_element_data(self, data)

	if table.contains(self._spawn_groups, data.value) then
		self:on_preferred_spawn_groups_checkbox_changed(data)
		self:check_apply_func_to_all_elements("on_preferred_spawn_groups_checkbox_changed", data)
	end
end

function SpawnEnemyGroupUnitElement:on_preferred_spawn_groups_checkbox_changed(params)
	local value = params.ctrlr:get_value()

	if value then
		self._hed.preferred_spawn_groups = self._hed.preferred_spawn_groups or {}

		if table.contains(self._hed.preferred_spawn_groups, params.value) then
			return
		end

		table.insert(self._hed.preferred_spawn_groups, params.value)
	elseif self._hed.preferred_spawn_groups then
		table.delete(self._hed.preferred_spawn_groups, params.value)

		if not next(self._hed.preferred_spawn_groups) then
			self._hed.preferred_spawn_groups = nil
		end
	end
end
