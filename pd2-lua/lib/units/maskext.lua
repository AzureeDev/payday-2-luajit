require("lib/managers/BlackMarketManager")

MaskExt = MaskExt or class()
local mvec1 = Vector3()
local mvec2 = Vector3()

function MaskExt:init(unit)
	self._unit = unit
	self._textures = {}
end

function MaskExt:apply_blueprint(blueprint, async_clbk)
	if not blueprint then
		return
	end

	local texture_load_result_clbk = async_clbk and callback(self, self, "clbk_texture_loaded", async_clbk)

	if not self._materials then
		local materials = self._unit:get_objects_by_type(Idstring("material"))
		self._materials = {}

		for _, m in ipairs(materials) do
			if m:variable_exists(Idstring("tint_color_a")) then
				table.insert(self._materials, m)
			end
		end
	end

	local tint_color_a = mvec1
	local tint_color_b = mvec2
	local pattern_id = blueprint.pattern.id
	local material_id = blueprint.material.id
	local color_data = tweak_data.blackmarket.colors[blueprint.color.id]

	mvector3.set_static(tint_color_a, color_data.colors[1]:unpack())
	mvector3.set_static(tint_color_b, color_data.colors[2]:unpack())

	local old_pattern = self._textures.pattern and self._textures.pattern.name
	local pattern = Idstring(tweak_data.blackmarket.textures[pattern_id].texture)

	if old_pattern ~= pattern then
		self._textures.pattern = {
			texture = false,
			ready = false,
			name = pattern
		}
	end

	local old_reflection = self._textures.reflection and self._textures.reflection.name
	local reflection = Idstring(tweak_data.blackmarket.materials[material_id].texture)

	if old_reflection ~= reflection then
		self._textures.reflection = {
			texture = false,
			ready = false,
			name = reflection
		}
	end

	local material_amount = tweak_data.blackmarket.materials[material_id].material_amount or 1

	for _, material in ipairs(self._materials) do
		material:set_variable(Idstring("tint_color_a"), tint_color_a)
		material:set_variable(Idstring("tint_color_b"), tint_color_b)
		material:set_variable(Idstring("material_amount"), material_amount)
	end

	self._requesting = async_clbk and true

	for tex_id, texture_data in pairs(self._textures) do
		if not texture_data.ready then
			local new_texture = nil

			if async_clbk then
				TextureCache:request(texture_data.name, "normal", texture_load_result_clbk, 90)
			else
				texture_data.ready = true

				for _, material in ipairs(self._materials) do
					Application:set_material_texture(material, Idstring(tex_id == "pattern" and "material_texture" or "reflection_texture"), texture_data.name, Idstring("normal"), 0)
				end
			end
		end
	end

	self._requesting = nil

	if async_clbk then
		self:_chk_load_complete(async_clbk)
	end
end

function MaskExt:clbk_texture_loaded(async_clbk, tex_name)
	if not alive(self._unit) then
		return
	end

	for tex_id, texture_data in pairs(self._textures) do
		if not texture_data.ready and tex_name == texture_data.name then
			texture_data.ready = true

			for _, material in ipairs(self._materials) do
				Application:set_material_texture(material, Idstring(tex_id == "pattern" and "material_texture" or "reflection_texture"), tex_name, Idstring("normal"), 0)
			end

			TextureCache:unretrieve(tex_name)
		end
	end

	self:_chk_load_complete(async_clbk)
end

function MaskExt:_chk_load_complete(async_clbk)
	if self._requesting then
		return
	end

	for tex_id, texture_data in pairs(self._textures) do
		if not texture_data.ready then
			return
		end
	end

	self._materials = nil

	async_clbk()
end

function MaskExt:destroy(unit)
	for tex_id, texture_data in pairs(self._textures) do
		if not texture_data.ready then
			TextureCache:unretrieve(texture_data.name)
		end
	end

	self._textures = {}
end

