SyncMaterials = SyncMaterials or class()

function SyncMaterials:init(unit)
	self._unit = unit
end

function SyncMaterials:save(data)
	data.materials = {}

	for _, name in pairs(self._materials) do
		local material = self._unit:material(Idstring(name))
		local serialized = {
			time = material:time(),
			playing_speed = material:is_playing() and material:playing_speed(),
			diffuse_color = material:diffuse_color(),
			diffuse_color_alpha = material:diffuse_color_alpha(),
			glossiness = material:glossiness(),
			render_template = material:render_template(),
			variables = {}
		}

		for _, variable in ipairs(material:variables()) do
			table.insert(serialized.variables, {
				name = variable.name,
				value = material:get_variable(variable.name)
			})
		end

		data.materials[name] = serialized
	end
end

function SyncMaterials:load(data)
	for name, serialized in pairs(data.materials) do
		local material = self._unit:material(Idstring(name))

		if material then
			material:set_time(serialized.time)
			material:set_diffuse_color(serialized.diffuse_color, serialized.diffuse_color_alpha)
			material:set_glossiness(serialized.glossiness)
			material:set_render_template(serialized.render_template)

			if serialized.playing_speed then
				material:play(serialized.playing_speed)
			end

			for _, variable in ipairs(serialized.variables) do
				material:set_variable(variable.name, variable.value)
			end
		end
	end
end
