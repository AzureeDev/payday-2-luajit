LookAtTriggerUnitElement = LookAtTriggerUnitElement or class(MissionElement)

function LookAtTriggerUnitElement:init(unit)
	LookAtTriggerUnitElement.super.init(self, unit)

	self._hed.trigger_times = 1
	self._hed.interval = 0.1
	self._hed.sensitivity = 0.9
	self._hed.distance = 0
	self._hed.in_front = false

	table.insert(self._save_values, "interval")
	table.insert(self._save_values, "sensitivity")
	table.insert(self._save_values, "distance")
	table.insert(self._save_values, "in_front")
end

function LookAtTriggerUnitElement:update_selected(t, dt)
	if self._hed.distance ~= 0 then
		local brush = Draw:brush()

		brush:set_color(Color(0.15, 1, 1, 1))

		local pen = Draw:pen(Color(0.15, 0.5, 0.5, 0.5))

		if not self._hed.in_front then
			brush:sphere(self._unit:position(), self._hed.distance, 4)
			pen:sphere(self._unit:position(), self._hed.distance)
		else
			brush:half_sphere(self._unit:position(), self._hed.distance, -self._unit:rotation():y(), 4)
			pen:half_sphere(self._unit:position(), self._hed.distance, -self._unit:rotation():y())
		end
	end
end

function LookAtTriggerUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_number(panel, panel_sizer, "interval", {
		floats = 2,
		min = 0.01
	}, "Set the check interval for the look at, in seconds")

	local sensitivity_params = {
		name = "Sensitivity:",
		ctrlr_proportions = 2,
		slider_ctrlr_proportions = 3,
		name_proportions = 1,
		number_ctrlr_proportions = 1,
		min = 0.5,
		floats = 3,
		max = 0.999,
		panel = panel,
		sizer = panel_sizer,
		value = self._hed.sensitivity
	}

	CoreEws.slider_and_number_controller(sensitivity_params)
	sensitivity_params.slider_ctrlr:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "set_element_data"), {
		value = "sensitivity",
		ctrlr = sensitivity_params.number_ctrlr
	})
	sensitivity_params.slider_ctrlr:connect("EVT_SCROLL_CHANGED", callback(self, self, "set_element_data"), {
		value = "sensitivity",
		ctrlr = sensitivity_params.number_ctrlr
	})
	sensitivity_params.number_ctrlr:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "sensitivity",
		ctrlr = sensitivity_params.number_ctrlr
	})
	sensitivity_params.number_ctrlr:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "sensitivity",
		ctrlr = sensitivity_params.number_ctrlr
	})
	self:_build_value_number(panel, panel_sizer, "distance", {
		floats = 2,
		min = 0
	}, "(Optional) Sets a distance to use with the check (in meters)")
	self:_build_value_checkbox(panel, panel_sizer, "in_front", "Only in front")
	self:_add_help_text("Interval defines how offen the check should be done. Sensitivity defines how precise the look angle must be. A sensitivity of 0.999 means that you need to look almost directly at it, 0.5 means that you will get the trigger somewhere at the edge of the screen (might be outside or inside). \n\nDistance(in meters) can be used as a filter to the trigger (0 means no distance filtering)")
end
