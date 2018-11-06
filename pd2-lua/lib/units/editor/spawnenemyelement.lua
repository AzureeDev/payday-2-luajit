core:import("CoreEditorUtils")

SpawnEnemyUnitElement = SpawnEnemyUnitElement or class(MissionElement)
SpawnEnemyUnitElement.USES_POINT_ORIENTATION = true
SpawnEnemyUnitElement.INSTANCE_VAR_NAMES = {
	{
		value = "enemy",
		type = "enemy"
	},
	{
		value = "spawn_action",
		type = "enemy_spawn_action"
	}
}

function SpawnEnemyUnitElement:init(unit)
	SpawnEnemyUnitElement.super.init(self, unit)

	self._enemies = {}
	self._hed.enemy = "units/payday2/characters/ene_swat_1/ene_swat_1"
	self._hed.force_pickup = "none"
	self._hed.spawn_action = "none"
	self._hed.participate_to_group_ai = true
	self._hed.interval = 5
	self._hed.amount = 0
	self._hed.accessibility = "any"
	self._hed.voice = 0
	self._hed.team = "default"

	table.insert(self._save_values, "enemy")
	table.insert(self._save_values, "force_pickup")
	table.insert(self._save_values, "team")
	table.insert(self._save_values, "spawn_action")
	table.insert(self._save_values, "participate_to_group_ai")
	table.insert(self._save_values, "interval")
	table.insert(self._save_values, "amount")
	table.insert(self._save_values, "accessibility")
	table.insert(self._save_values, "voice")
end

function SpawnEnemyUnitElement:post_init(...)
	SpawnEnemyUnitElement.super.post_init(self, ...)
	self:_load_pickup()
end

function SpawnEnemyUnitElement:test_element()
	if not managers.navigation:is_data_ready() then
		EWS:message_box(Global.frame_panel, "Can't test spawn unit without ready navigation data (AI-graph)", "Spawn", "OK,ICON_ERROR", Vector3(-1, -1, 0))

		return
	end

	if self._hed.enemy ~= "none" and managers.groupai:state():is_AI_enabled() then
		local unit = safe_spawn_unit(Idstring(self._hed.enemy), self._unit:position(), self._unit:rotation())

		if not unit then
			return
		end

		table.insert(self._enemies, unit)
		unit:brain():set_logic("inactive", nil)

		local team_id = self:_resolve_team(unit)

		managers.groupai:state():set_char_team(unit, team_id)

		local action_desc = ElementSpawnEnemyDummy._create_action_data(self:get_spawn_anim())

		unit:movement():action_request(action_desc)
		unit:movement():set_position(unit:position())
	end
end

function SpawnEnemyUnitElement:get_spawn_anim()
	return self._hed.spawn_action
end

function SpawnEnemyUnitElement:stop_test_element()
	for _, enemy in ipairs(self._enemies) do
		enemy:set_slot(0)
	end

	self._enemies = {}
end

function SpawnEnemyUnitElement:set_element_data(params, ...)
	SpawnEnemyUnitElement.super.set_element_data(self, params, ...)

	if params.value == "force_pickup" then
		self:_load_pickup()
	end
end

function SpawnEnemyUnitElement:_reload_unit_list_btn()
	self:stop_test_element()

	if self._hed.enemy ~= "none" then
		managers.editor:reload_units({
			Idstring(self._hed.enemy)
		}, true, true)
	end
end

function SpawnEnemyUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local enemy_sizer = EWS:BoxSizer("HORIZONTAL")

	panel_sizer:add(enemy_sizer, 0, 0, "EXPAND")
	self:_build_value_combobox(panel, enemy_sizer, "enemy", self._options, nil, nil, {
		horizontal_sizer_proportions = 1
	})

	local toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	toolbar:add_tool("ADD_UNIT_LIST", "Reload unit", CoreEws.image_path("toolbar\\refresh_16x16.png"), nil)
	toolbar:connect("ADD_UNIT_LIST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_reload_unit_list_btn"), nil)
	toolbar:realize()
	enemy_sizer:add(toolbar, 0, 0, "EXPAND,LEFT")

	local participate_to_group_ai = EWS:CheckBox(panel, "Participate to group ai", "")

	participate_to_group_ai:set_value(self._hed.participate_to_group_ai)
	participate_to_group_ai:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "participate_to_group_ai",
		ctrlr = participate_to_group_ai
	})
	panel_sizer:add(participate_to_group_ai, 0, 0, "EXPAND")

	local spawn_action_options = clone(CopActionAct._act_redirects.enemy_spawn)

	table.insert(spawn_action_options, "none")
	self:_build_value_combobox(panel, panel_sizer, "spawn_action", spawn_action_options)
	self:_build_value_number(panel, panel_sizer, "interval", {
		floats = 2,
		min = 0
	}, "Used to specify how often this spawn can be used. 0 means no interval")
	self:_build_value_number(panel, panel_sizer, "voice", {
		min = 0,
		floats = 0,
		max = 5
	}, "Voice variant. 1-5. 0 for random.")
	self:_build_value_combobox(panel, panel_sizer, "accessibility", ElementSpawnEnemyDummy.ACCESSIBILITIES, "Only units with this movement type will be spawned from this element.")

	local pickups = table.map_keys(tweak_data.pickups)

	table.insert(pickups, "none")
	table.insert(pickups, "no_pickup")
	self:_build_value_combobox(panel, panel_sizer, "force_pickup", pickups)
	self:_build_value_combobox(panel, panel_sizer, "team", table.list_add({
		"default"
	}, tweak_data.levels:get_team_names_indexed()), "Select the character's team.")
end

function SpawnEnemyUnitElement:_load_pickup()
	if self._hed.force_pickup ~= "none" and self._hed.force_pickup ~= "no_pickup" then
		local unit_name = tweak_data.pickups[self._hed.force_pickup].unit

		CoreUnit.editor_load_unit(unit_name)
	end
end

function SpawnEnemyUnitElement:add_to_mission_package()
	if self._hed.force_pickup ~= "none" and self._hed.force_pickup ~= "no_pickup" then
		local unit_name = tweak_data.pickups[self._hed.force_pickup].unit

		managers.editor:add_to_world_package({
			category = "units",
			name = unit_name:s(),
			continent = self._unit:unit_data().continent
		})

		local sequence_files = {}

		CoreEditorUtils.get_sequence_files_by_unit_name(unit_name, sequence_files)

		for _, file in ipairs(sequence_files) do
			managers.editor:add_to_world_package({
				init = true,
				category = "script_data",
				name = file:s() .. ".sequence_manager",
				continent = self._unit:unit_data().continent
			})
		end
	end
end

function SpawnEnemyUnitElement:_resolve_team(unit)
	if self._hed.team == "default" then
		return tweak_data.levels:get_default_team_ID(unit:base():char_tweak().access == "gangster" and "gangster" or "combatant")
	else
		return self._hed.team
	end
end

function SpawnEnemyUnitElement:destroy(...)
	SpawnEnemyUnitElement.super.destroy(self, ...)
	self:stop_test_element()
end
