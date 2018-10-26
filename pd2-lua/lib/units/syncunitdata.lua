SyncUnitData = SyncUnitData or class()

function SyncUnitData:init(unit)
	self._unit = unit
end

function SyncUnitData:save(data)
	local state = {lights = {}}

	for _, light in ipairs(self._unit:get_objects_by_type(Idstring("light"))) do
		local l = {
			name = light:name(),
			enabled = light:enable(),
			far_range = light:far_range(),
			near_range = light:near_range(),
			color = light:color(),
			spot_angle_start = light:spot_angle_start(),
			spot_angle_end = light:spot_angle_end(),
			multiplier_nr = light:multiplier(),
			specular_multiplier_nr = light:specular_multiplier(),
			falloff_exponent = light:falloff_exponent()
		}

		table.insert(state.lights, l)
	end

	state.projection_light = self._unit:unit_data().projection_light
	state.projection_textures = self._unit:unit_data().projection_textures
	data.SyncUnitData = state
end

function SyncUnitData:load(data)
	local state = data.SyncUnitData
	self._unit:unit_data().unit_id = self._unit:editor_id()

	managers.worlddefinition:setup_lights(self._unit, state)
	managers.worlddefinition:setup_projection_light(self._unit, state)
end

