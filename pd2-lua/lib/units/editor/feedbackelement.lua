FeedbackUnitElement = FeedbackUnitElement or class(MissionElement)
FeedbackUnitElement.USES_POINT_ORIENTATION = true

function FeedbackUnitElement:init(unit)
	FeedbackUnitElement.super.init(self, unit)

	self._hed.effect = "mission_triggered"
	self._hed.range = 0
	self._hed.use_camera_shake = true
	self._hed.use_rumble = true
	self._hed.camera_shake_effect = "mission_triggered"
	self._hed.camera_shake_amplitude = 1
	self._hed.camera_shake_frequency = 1
	self._hed.camera_shake_attack = 0.1
	self._hed.camera_shake_sustain = 0.3
	self._hed.camera_shake_decay = 2.1
	self._hed.rumble_peak = 1
	self._hed.rumble_attack = 0.1
	self._hed.rumble_sustain = 0.3
	self._hed.rumble_release = 2.1
	self._hed.above_camera_effect = "none"
	self._hed.above_camera_effect_distance = 0.5

	table.insert(self._save_values, "effect")
	table.insert(self._save_values, "range")
	table.insert(self._save_values, "use_camera_shake")
	table.insert(self._save_values, "use_rumble")
	table.insert(self._save_values, "camera_shake_effect")
	table.insert(self._save_values, "camera_shake_amplitude")
	table.insert(self._save_values, "camera_shake_frequency")
	table.insert(self._save_values, "camera_shake_attack")
	table.insert(self._save_values, "camera_shake_sustain")
	table.insert(self._save_values, "camera_shake_decay")
	table.insert(self._save_values, "rumble_peak")
	table.insert(self._save_values, "rumble_attack")
	table.insert(self._save_values, "rumble_sustain")
	table.insert(self._save_values, "rumble_release")
	table.insert(self._save_values, "above_camera_effect")
	table.insert(self._save_values, "above_camera_effect_distance")
end

function FeedbackUnitElement:update_selected(t, dt, selected_unit, all_units)
	if self._hed.orientation_elements then
		for _, id in ipairs(self._hed.orientation_elements) do
			local unit = all_units[id]

			self:_draw_ranges(unit:position())
		end
	else
		self:_draw_ranges(self._unit:position())
	end
end

function FeedbackUnitElement:_draw_ranges(pos)
	local brush = Draw:brush()

	brush:set_color(Color(0.15, 1, 1, 1))

	local pen = Draw:pen(Color(0.15, 0.5, 0.5, 0.5))

	brush:sphere(pos, self._hed.range, 4)
	pen:sphere(pos, self._hed.range)
	brush:set_color(Color(0.15, 0, 1, 0))
	pen:set(Color(0.15, 0, 1, 0))
	brush:sphere(pos, self._hed.range * self._hed.above_camera_effect_distance, 4)
	pen:sphere(pos, self._hed.range * self._hed.above_camera_effect_distance)
end

function FeedbackUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_number(panel, panel_sizer, "range", {
		floats = 0,
		min = -1
	}, "The range the effect should be felt. 0 means that it will be felt everywhere")

	local camera_shaker_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "Camera shake")

	panel_sizer:add(camera_shaker_sizer, 0, 0, "EXPAND")
	self:_build_value_checkbox(panel, camera_shaker_sizer, "use_camera_shake", "Use camera shake")
	self:_build_value_combobox(panel, camera_shaker_sizer, "camera_shake_effect", {
		"mission_triggered",
		"headbob",
		"player_land",
		"breathing"
	}, "Select a camera shake effect", "effect")
	self:_build_value_number(panel, camera_shaker_sizer, "camera_shake_amplitude", {
		floats = 2,
		min = -1
	}, "Amplitude basically decides the strenght of the shake", "amplitude")
	self:_build_value_number(panel, camera_shaker_sizer, "camera_shake_frequency", {
		floats = 2,
		min = -1
	}, "Changes the frequency of the shake", "frequency")
	self:_build_value_number(panel, camera_shaker_sizer, "camera_shake_attack", {
		floats = 2,
		min = -1
	}, "Time to reach maximum shake", "attack")
	self:_build_value_number(panel, camera_shaker_sizer, "camera_shake_sustain", {
		floats = 2,
		min = -1
	}, "Time to sustain maximum shake", "sustain")
	self:_build_value_number(panel, camera_shaker_sizer, "camera_shake_decay", {
		floats = 2,
		min = -1
	}, "Time to decay from maximum shake to zero", "decay")

	local rumble_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "Rumble")

	panel_sizer:add(rumble_sizer, 0, 0, "EXPAND")
	self:_build_value_checkbox(panel, rumble_sizer, "use_rumble", "Use rumble")
	self:_build_value_number(panel, rumble_sizer, "rumble_peak", {
		floats = 2,
		min = -1
	}, "A value to determine the strength of the rumble", "peak")
	self:_build_value_number(panel, rumble_sizer, "rumble_attack", {
		floats = 2,
		min = -1
	}, "Time to reach maximum rumble", "attack")
	self:_build_value_number(panel, rumble_sizer, "rumble_sustain", {
		floats = 2,
		min = -1
	}, "Time to sustain maximum rumble", "sustain")
	self:_build_value_number(panel, rumble_sizer, "rumble_release", {
		floats = 2,
		min = -1
	}, "Time to decay from maximum rumble to zero", "release")

	local above_camera_effect_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "Above camera effect")

	panel_sizer:add(above_camera_effect_sizer, 0, 0, "EXPAND")
	self:_build_value_combobox(panel, above_camera_effect_sizer, "above_camera_effect", table.list_add({
		"none"
	}, self:_effect_options()), "Select and above camera effect", "effect")
	self:_build_value_number(panel, above_camera_effect_sizer, "above_camera_effect_distance", {
		min = 0,
		floats = 2,
		max = 1
	}, "A filter value to use with the range. A value of 1 means that the effect will be played whenever inside the range, a lower value means you need to be closer to the position.", "distance filter")
end

function FeedbackUnitElement:_effect_options()
	local effect_options = {}

	for _, name in ipairs(managers.database:list_entries_of_type("effect")) do
		table.insert(effect_options, name)
	end

	return effect_options
end

function FeedbackUnitElement:add_to_mission_package()
	if self._hed.effect and self._hed.above_camera_effect ~= "none" then
		managers.editor:add_to_world_package({
			category = "effects",
			name = self._hed.above_camera_effect,
			continent = self._unit:unit_data().continent
		})
	end
end
