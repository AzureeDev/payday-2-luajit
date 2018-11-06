HeatUnitElement = HeatUnitElement or class(MissionElement)

function HeatUnitElement:init(unit)
	HeatUnitElement.super.init(self, unit)

	self._hed.points = 0
	self._hed.level = 0

	table.insert(self._save_values, "points")
	table.insert(self._save_values, "level")
end

function HeatUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local heat_points_params = {
		name = "Heat points:",
		floats = 0,
		name_proportions = 1,
		ctrlr_proportions = 2,
		tooltip = "Can increase or decrease the heat level",
		panel = panel,
		sizer = panel_sizer,
		value = self._hed.points
	}
	local heat_points = CoreEWS.number_controller(heat_points_params)

	heat_points:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "points",
		ctrlr = heat_points
	})
	heat_points:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "points",
		ctrlr = heat_points
	})

	local heat_level_params = {
		name_proportions = 1,
		name = "Heat level:",
		ctrlr_proportions = 2,
		tooltip = "Use this to set the heat level (if it isn't this or hihger allready)",
		min = 0,
		floats = 0,
		max = 10,
		panel = panel,
		sizer = panel_sizer,
		value = self._hed.level
	}
	local heat_level = CoreEWS.number_controller(heat_level_params)

	heat_level:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "level",
		ctrlr = heat_level
	})
	heat_level:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "level",
		ctrlr = heat_level
	})

	local help = {
		text = "If level is specified (level ~= 0) the result of this element will be to try increase the heat level (it will never lower it though). If the level == 0 then the heat points will be used to increase or decrese the heat.",
		panel = panel,
		sizer = panel_sizer
	}

	self:add_help_text(help)
end

HeatTriggerUnitElement = HeatTriggerUnitElement or class(MissionElement)

function HeatTriggerUnitElement:init(unit)
	HeatTriggerUnitElement.super.init(self, unit)

	self._hed.trigger_times = 1
	self._hed.stage = 0

	table.insert(self._save_values, "stage")
end

function HeatTriggerUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local heat_stage_params = {
		name_proportions = 1,
		name = "Heat stage:",
		ctrlr_proportions = 2,
		tooltip = "Set the heat stage to get a trigger from ",
		min = 0,
		floats = 0,
		max = 10,
		panel = panel,
		sizer = panel_sizer,
		value = self._hed.stage
	}
	local heat_stage = CoreEWS.number_controller(heat_stage_params)

	heat_stage:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "stage",
		ctrlr = heat_stage
	})
	heat_stage:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "stage",
		ctrlr = heat_stage
	})

	local help = {
		text = "Set which heat stage to get a trigger from.",
		panel = panel,
		sizer = panel_sizer
	}

	self:add_help_text(help)
end
