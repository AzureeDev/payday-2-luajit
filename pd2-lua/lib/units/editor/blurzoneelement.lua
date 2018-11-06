BlurZoneUnitElement = BlurZoneUnitElement or class(MissionElement)

function BlurZoneUnitElement:init(unit)
	BlurZoneUnitElement.super.init(self, unit)

	self._hed.mode = 0
	self._hed.radius = 200
	self._hed.height = 200

	table.insert(self._save_values, "mode")
	table.insert(self._save_values, "radius")
	table.insert(self._save_values, "height")
end

function BlurZoneUnitElement:update_selected(t, dt, selected_unit, all_units)
	local brush = Draw:brush()

	brush:set_color(Color(0.15, 1, 1, 1))

	local pen = Draw:pen(Color(0.15, 0.5, 0.5, 0.5))

	brush:cylinder(self._unit:position(), self._unit:position() + math.Z * self._hed.height, self._hed.radius)
	pen:cylinder(self._unit:position(), self._unit:position() + math.Z * self._hed.height, self._hed.radius)
	brush:half_sphere(self._unit:position(), self._hed.radius, math.Z, 2)
	pen:half_sphere(self._unit:position(), self._hed.radius, math.Z)
	brush:half_sphere(self._unit:position() + math.Z * self._hed.height, self._hed.radius, -math.Z, 2)
	pen:half_sphere(self._unit:position() + math.Z * self._hed.height, self._hed.radius, -math.Z)
end

function BlurZoneUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local mode_params = {
		name_proportions = 1,
		name = "Mode:",
		ctrlr_proportions = 2,
		tooltip = "Set the mode, 0 is disable, 2 is flash, 1 is normal",
		min = 0,
		floats = 0,
		max = 2,
		panel = panel,
		sizer = panel_sizer,
		value = self._hed.mode
	}
	local mode = CoreEWS.number_controller(mode_params)

	mode:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "mode",
		ctrlr = mode
	})
	mode:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "mode",
		ctrlr = mode
	})

	local radius_params = {
		name = "Radius:",
		ctrlr_proportions = 2,
		name_proportions = 1,
		tooltip = "Set the radius",
		min = 1,
		floats = 0,
		panel = panel,
		sizer = panel_sizer,
		value = self._hed.radius
	}
	local radius = CoreEWS.number_controller(radius_params)

	radius:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "radius",
		ctrlr = radius
	})
	radius:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "radius",
		ctrlr = radius
	})

	local height_params = {
		name = "Height:",
		ctrlr_proportions = 2,
		name_proportions = 1,
		tooltip = "Set the height",
		min = 0,
		floats = 0,
		panel = panel,
		sizer = panel_sizer,
		value = self._hed.height
	}
	local height = CoreEWS.number_controller(height_params)

	height:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "height",
		ctrlr = height
	})
	height:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "height",
		ctrlr = height
	})
end
