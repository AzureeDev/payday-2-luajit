CoreSpawnUnitUnitElement = CoreSpawnUnitUnitElement or class(MissionElement)
SpawnUnitUnitElement = SpawnUnitUnitElement or class(CoreSpawnUnitUnitElement)

function SpawnUnitUnitElement:init(...)
	CoreSpawnUnitUnitElement.init(self, ...)
end

function CoreSpawnUnitUnitElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.unit_name = "none"
	self._hed.unit_spawn_velocity = 0
	self._hed.unit_spawn_mass = 0
	self._hed.unit_spawn_dir = Vector3(0, 0, 1)

	table.insert(self._save_values, "unit_name")
	table.insert(self._save_values, "unit_spawn_velocity")
	table.insert(self._save_values, "unit_spawn_mass")
	table.insert(self._save_values, "unit_spawn_dir")

	self._test_units = {}
end

function CoreSpawnUnitUnitElement:test_element()
	if self._hed.unit_name ~= "none" then
		local unit = safe_spawn_unit(self._hed.unit_name, self._unit:position(), self._unit:rotation())

		table.insert(self._test_units, unit)
		unit:push(self._hed.unit_spawn_mass, self._hed.unit_spawn_dir * self._hed.unit_spawn_velocity)
	end
end

function CoreSpawnUnitUnitElement:stop_test_element()
	for _, unit in ipairs(self._test_units) do
		if alive(unit) then
			World:delete_unit(unit)
		end
	end

	self._test_units = {}
end

function CoreSpawnUnitUnitElement:update_selected(time, rel_time)
	Application:draw_arrow(self._unit:position(), self._unit:position() + self._hed.unit_spawn_dir * 400, 0.75, 0.75, 0.75)
end

function CoreSpawnUnitUnitElement:update_editing(time, rel_time)
	local kb = Input:keyboard()
	local speed = 60 * rel_time

	if kb:down(Idstring("left")) then
		self._hed.unit_spawn_dir = self._hed.unit_spawn_dir:rotate_with(Rotation(speed, 0, 0))
	end

	if kb:down(Idstring("right")) then
		self._hed.unit_spawn_dir = self._hed.unit_spawn_dir:rotate_with(Rotation(-speed, 0, 0))
	end

	if kb:down(Idstring("up")) then
		self._hed.unit_spawn_dir = self._hed.unit_spawn_dir:rotate_with(Rotation(0, 0, speed))
	end

	if kb:down(Idstring("down")) then
		self._hed.unit_spawn_dir = self._hed.unit_spawn_dir:rotate_with(Rotation(0, 0, -speed))
	end

	local from = self._unit:position()
	local to = from + self._hed.unit_spawn_dir * 100000
	local ray = managers.editor:unit_by_raycast({
		from = from,
		to = to,
		mask = managers.slot:get_mask("statics_layer")
	})

	if ray and ray.unit then
		Application:draw_sphere(ray.position, 25, 1, 0, 0)
	end
end

function CoreSpawnUnitUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local unit_options = {
		"none"
	}

	for name, _ in pairs(managers.editor:layers().Dynamics:get_unit_map()) do
		table.insert(unit_options, managers.editor:get_real_name(name))
	end

	self:_build_value_combobox(panel, panel_sizer, "unit_name", unit_options, "Select a unit from the combobox")
	self:_build_value_number(panel, panel_sizer, "unit_spawn_velocity", {
		floats = 0,
		min = 0
	}, "Use this to add a velocity to a physic push on the spawned unit(will need mass as well)", "Velocity")
	self:_build_value_number(panel, panel_sizer, "unit_spawn_mass", {
		floats = 0,
		min = 0
	}, "Use this to add a mass to a physic push on the spawned unit(will need velocity as well)", "Mass")
	self:_add_help_text([[
Select a unit to be spawned in the unit combobox.

Add velocity and mass if you want to give the spawned unit a push as if it was hit by an object of mass mass, traveling at a velocity of velocity relative to the unit (both values are required to give the push)

Body slam (80 kg, 10 m/s)
Fist punch (8 kg, 10 m/s)
Bullet hit (10 g, 900 m/s)]])
end

function CoreSpawnUnitUnitElement:add_to_mission_package()
	managers.editor:add_to_world_package({
		category = "units",
		name = self._hed.unit_name,
		continent = self._unit:unit_data().continent
	})
end
