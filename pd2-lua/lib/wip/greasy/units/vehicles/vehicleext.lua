require("lib/managers/BlackMarketManager")

VehicleExt = VehicleExt or class()
local mvec1 = Vector3()
local mvec2 = Vector3()

function VehicleExt:init(unit)
	self._unit = unit
	self._textures = {}
	self._parts = {}
	self._blueprint = {}
	self._cosmetics = {}
	self._assembled = false
	self._visible = true
end

function VehicleExt:set_factory_data(factory_id)
	self._factory_id = factory_id
end

function VehicleExt:assemble(skip_queue, clbk)
	if not self._factory_id then
		Application:error("[VehicleExt:assemble] Vehicle is missing factory id!")

		return
	end

	self:hide()

	self._parts, self._blueprint = managers.vehicle_factory:assemble_default(self._factory_id, self._unit, callback(self, self, "_assemble_completed", {
		cosmetics = false,
		clbk = clbk or function ()
		end
	}), skip_queue)

	self:_update_stats_values()
end

function VehicleExt:assemble_from_blueprint(blueprint, cosmetics, skip_queue, clbk)
	if not self._factory_id then
		Application:error("[VehicleExt:assemble_from_blueprint] Vehicle is missing factory id!")

		return
	end

	self:hide()

	self._parts, self._blueprint = managers.vehicle_factory:assemble_from_blueprint(self._factory_id, self._unit, blueprint, callback(self, self, "_assemble_completed", {
		clbk = clbk or function ()
		end,
		cosmetics = cosmetics
	}), skip_queue)

	self:_update_stats_values()
end

function VehicleExt:remove_part(part_id, clbk)
	if not self._factory_id then
		Application:error("[VehicleExt:remove_part] Vehicle is missing factory id!")

		return
	end

	self:hide()

	self._parts = managers.vehicle_factory:remove_part(self._unit, self._factory_id, part_id, self._parts, self._blueprint, callback(self, self, "_assemble_completed", {
		clbk = clbk or function ()
		end,
		cosmetics = self._cosmetics
	}))

	self:_update_stats_values()
end

function VehicleExt:remove_part_by_type(type, clbk)
	if not self._factory_id then
		Application:error("[VehicleExt:remove_part_by_type] Vehicle is missing factory id!")

		return
	end

	self:hide()

	self._parts = managers.vehicle_factory:remove_part_by_type(self._unit, self._factory_id, type, self._parts, self._blueprint, callback(self, self, "_assemble_completed", {
		clbk = clbk or function ()
		end,
		cosmetics = self._cosmetics
	}))

	self:_update_stats_values()
end

function VehicleExt:change_blueprint(blueprint, clbk)
	if not self._factory_id then
		Application:error("[VehicleExt:change_blueprint] Vehicle is missing factory id!")

		return
	end

	self._blueprint = blueprint

	self:hide()

	self._parts = managers.vehicle_factory:change_blueprint(self._unit, self._factory_id, self._parts, blueprint, callback(self, self, "_assemble_completed", {
		clbk = clbk or function ()
		end,
		cosmetics = self._cosmetics
	}))

	self:_update_stats_values()
end

function VehicleExt:change_blueprint_and_cosmetics(blueprint, cosmetics, clbk)
	if not self._factory_id then
		Application:error("[VehicleExt:change_blueprint_and_cosmetics] Vehicle is missing factory id!")

		return
	end

	self._blueprint = blueprint

	self:hide()

	self._parts = managers.vehicle_factory:change_blueprint(self._unit, self._factory_id, self._parts, blueprint, callback(self, self, "_assemble_completed", {
		clbk = clbk or function ()
		end,
		cosmetics = cosmetics
	}))

	self:_update_stats_values()
end

function VehicleExt:change_cosmetics(cosmetics, clbk)
	if not self._factory_id then
		Application:error("[VehicleExt:change_cosmetics] Vehicle is missing factory id!")

		return
	end

	self:apply_cosmetics(cosmetics, clbk)
end

function VehicleExt:_assemble_completed(params, parts, blueprint)
	local clbk = params.clbk
	local cosmetics = params.cosmetics
	self._assembled = true
	self._parts = parts
	self._blueprint = blueprint

	self:_set_visible(self._visible)
	self:apply_cosmetics(cosmetics, clbk)
	self:_update_stats_values()
end

function VehicleExt:show()
	self:_set_visible(true)
end

function VehicleExt:hide()
	self:_set_visible(false)
end

function VehicleExt:_set_visible(visible)
	self._visible = visible

	self._unit:set_visible(self._visible)

	if self._parts then
		for _, part in pairs(self._parts) do
			if alive(part.unit) then
				part.unit:set_visible(self._visible)
			end
		end
	end
end

function VehicleExt:_update_stats_values()
end

function VehicleExt:apply_cosmetics(cosmetics, async_clbk)
	if not self._assembled or not self._parts or table.size(self._parts) == 0 or not cosmetics then
		self:_chk_load_complete(async_clbk)

		return
	end

	self._cosmetics = cosmetics
	local texture_load_result_clbk = async_clbk and callback(self, self, "clbk_texture_loaded", async_clbk)

	if not self._materials then
		self._materials = {}

		for part_id, part in pairs(self._parts) do
			local materials = part.unit:get_objects_by_type(Idstring("material"))

			for _, m in ipairs(materials) do
				if m:variable_exists(Idstring("wear_tear_value")) then
					self._materials[part_id] = self._materials[part_id] or {}

					table.insert(self._materials[part_id], m)
				end
			end
		end
	end

	if table.size(self._materials) == 0 then
		self:_chk_load_complete(async_clbk)

		return
	end

	local pattern = self._cosmetics.pattern or {}
	local pattern_texture = Idstring("units/pd2_customize/vehicles_patterns/vehicles_pattern_test/vehicles_pattern_test_df")
	local pattern_gradient_texture = Idstring("units/pd2_customize/vehicles_pattern_gradients/vehicles_pattern_gradient_df")
	local pattern_tweak = mvec1

	mvector3.set_static(pattern_tweak, pattern.tiling or 10, pattern.rotation or 0, pattern.alpha or 1)

	local wear_and_tear = self._cosmetics.wear_and_tear or 1
	local old_pattern = self._textures.pattern

	if old_pattern and not old_pattern.ready and old_pattern.name ~= pattern_texture then
		TextureCache:unretrieve(old_pattern.name)
	end

	self._textures.pattern = {
		texture = false,
		ready = false,
		name = pattern_texture,
		material_texture = Idstring("diffuse_layer0_texture")
	}
	local old_pattern_gradient = self._textures.pattern_gradient

	if old_pattern_gradient and not old_pattern_gradient.ready and old_pattern_gradient.name ~= pattern_gradient_texture then
		TextureCache:unretrieve(old_pattern_gradient.name)
	end

	self._textures.pattern_gradient = {
		texture = false,
		ready = false,
		name = pattern_gradient_texture,
		material_texture = Idstring("diffuse_layer2_texture")
	}
	Global.a = self

	for part_id, materials in pairs(self._materials) do
		for _, material in ipairs(materials) do
			material:set_variable(Idstring("pattern_tweak"), pattern_tweak)
			material:set_variable(Idstring("wear_tear_value"), wear_and_tear)
			material:set_variable(Idstring("uv_scale"), Vector3(Global.x or 1, Global.y or 1, Global.z or 1))
			material:set_variable(Idstring("uv_offset_rot"), Vector3(Global.X or 0, Global.Y or 0, Global.Z or 0))
		end
	end

	self._requesting = async_clbk and true

	for tex_id, texture_data in pairs(self._textures) do
		if not texture_data.ready then
			if async_clbk then
				TextureCache:request(texture_data.name, "normal", texture_load_result_clbk, 90)
			else
				texture_data.ready = true

				for part_id, materials in pairs(self._materials) do
					for _, material in ipairs(materials) do
						Application:set_material_texture(material, texture_data.material_texture, texture_data.name, Idstring("normal"), 0)
					end
				end
			end
		end
	end

	self._requesting = nil

	self:_chk_load_complete(async_clbk)
end

function VehicleExt:clbk_texture_loaded(async_clbk, tex_name)
	if not alive(self._unit) then
		return
	end

	print("[VehicleExt:clbk_texture_loaded]", async_clbk, tex_name)

	for tex_id, texture_data in pairs(self._textures) do
		if not texture_data.ready and tex_name == texture_data.name then
			texture_data.ready = true

			for part_id, materials in pairs(self._materials) do
				for _, material in ipairs(materials) do
					Application:set_material_texture(material, texture_data.material_texture, tex_name, Idstring("normal"), 0)
				end
			end

			TextureCache:unretrieve(tex_name)
		end
	end

	self:_chk_load_complete(async_clbk)
end

function VehicleExt:_chk_load_complete(async_clbk)
	if self._requesting then
		return
	end

	for tex_id, texture_data in pairs(self._textures) do
		if not texture_data.ready then
			return
		end
	end

	self._materials = nil

	if async_clbk then
		async_clbk(true)
	end

	self:show()
end

function VehicleExt:destroy(unit)
	for tex_id, texture_data in pairs(self._textures) do
		if not texture_data.ready then
			TextureCache:unretrieve(texture_data.name)
		end
	end

	if self._parts then
		managers.vehicle_factory:disassemble(self._parts)
	end

	self._textures = {}
	self._parts = {}
	self._blueprint = {}
	self._cosmetics = {}
	self._assembled = false
end
