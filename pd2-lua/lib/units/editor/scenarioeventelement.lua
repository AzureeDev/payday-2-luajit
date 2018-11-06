ScenarioEventUnitElement = ScenarioEventUnitElement or class(MissionElement)

function ScenarioEventUnitElement:init(unit)
	ScenarioEventUnitElement.super.init(self, unit)

	self._hed.amount = 1
	self._hed.task = managers.groupai:state():task_names()[1]
	self._hed.base_chance = 1
	self._hed.chance_inc = 0

	table.insert(self._save_values, "amount")
	table.insert(self._save_values, "task")
	table.insert(self._save_values, "base_chance")
	table.insert(self._save_values, "chance_inc")
end

function ScenarioEventUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local amount_params = {
		name_proportions = 1,
		name = "Amount:",
		ctrlr_proportions = 2,
		tooltip = "Should be set to the amount of enemies that will be created from this event",
		min = 1,
		floats = 0,
		max = 25,
		panel = panel,
		sizer = panel_sizer,
		value = self._hed.amount
	}
	local amount = CoreEWS.number_controller(amount_params)

	amount:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "amount",
		ctrlr = amount
	})
	amount:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "amount",
		ctrlr = amount
	})

	local task_params = {
		name = "Task:",
		name_proportions = 1,
		tooltip = "Select a task from the combobox",
		sorted = true,
		ctrlr_proportions = 2,
		panel = panel,
		sizer = panel_sizer,
		options = managers.groupai:state():task_names(),
		value = self._hed.task
	}
	local task = CoreEWS.combobox(task_params)

	task:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "set_element_data"), {
		value = "task",
		ctrlr = task
	})

	local base_chance_params = {
		name_proportions = 1,
		name = "Base chance:",
		ctrlr_proportions = 2,
		tooltip = "Used to specify chance to happen (1==absolutely!)",
		min = 0,
		floats = 2,
		max = 1,
		panel = panel,
		sizer = panel_sizer,
		value = self._hed.base_chance
	}
	local base_chance = CoreEWS.number_controller(base_chance_params)

	base_chance:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "base_chance",
		ctrlr = base_chance
	})
	base_chance:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "base_chance",
		ctrlr = base_chance
	})

	local chance_inc_params = {
		name_proportions = 1,
		name = "Chance incremental:",
		ctrlr_proportions = 2,
		tooltip = "Used to specify an incremental chance to happen",
		min = 0,
		floats = 2,
		max = 1,
		panel = panel,
		sizer = panel_sizer,
		value = self._hed.chance_inc
	}
	local chance_inc = CoreEWS.number_controller(chance_inc_params)

	chance_inc:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "chance_inc",
		ctrlr = chance_inc
	})
	chance_inc:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "chance_inc",
		ctrlr = chance_inc
	})
end
