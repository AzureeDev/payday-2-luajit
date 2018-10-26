ArmorSkinExt = ArmorSkinExt or class()
local material_defaults = {
	bump_normal_texture = {
		[2] = Idstring("units/payday2/characters/shared_textures/vest_small_nm"),
		[3] = Idstring("units/payday2/characters/shared_textures/vest_big_nm")
	},
	diffuse_layer1_texture = Idstring("units/payday2_cash/safes/default/base_gradient/base_default_df"),
	diffuse_layer2_texture = Idstring("units/payday2_cash/safes/default/pattern_gradient/gradient_default_df"),
	diffuse_layer0_texture = Idstring("units/payday2_cash/safes/default/pattern/pattern_default_df"),
	diffuse_layer3_texture = Idstring("units/payday2_cash/safes/default/sticker/sticker_default_df")
}
local material_textures = {
	pattern = "diffuse_layer0_texture",
	pattern_gradient = "diffuse_layer2_texture",
	normal_map = "bump_normal_texture",
	sticker = "diffuse_layer3_texture",
	base_gradient = "diffuse_layer1_texture"
}
local material_variables = {
	cubemap_pattern_control = "cubemap_pattern_control",
	pattern_pos = "pattern_pos",
	uv_scale = "uv_scale",
	uv_offset_rot = "uv_offset_rot",
	pattern_tweak = "pattern_tweak",
	wear_and_tear = (managers.blackmarket and managers.blackmarket:skin_editor() and managers.blackmarket:skin_editor():active() or Application:production_build()) and "wear_tear_value" or nil
}

function ArmorSkinExt:init(unit, update_enabled)
	self._unit = unit

	unit:set_extension_update_enabled(Idstring("armor_skin"), true)
	self:set_armor_id("level_1")
end

function ArmorSkinExt:update(unit, t, dt)
	if self._request_update then
		self:_apply_cosmetics()

		self._request_update = nil
	end
end

function ArmorSkinExt:set_armor_id(armor_id)
	local data = tweak_data.blackmarket.armors[armor_id]

	if data then
		self._level = data.upgrade_level
	else
		self._level = 1
	end
end

function ArmorSkinExt:armor_level()
	if self._level then
		return self._level
	else
		local armor = tweak_data.blackmarket.armors[managers.blackmarket:equipped_armor()]

		return armor and armor.upgrade_level or 1
	end
end

function ArmorSkinExt:set_cosmetics_data(cosmetics_id, request_update)
	if not cosmetics_id then
		self._cosmetics_id = nil
		self._cosmetics_quality = nil
		self._cosmetics_bonus = nil
		self._cosmetics_data = nil
		self._request_update = false

		return
	end

	self._cosmetics_id = cosmetics_id
	self._cosmetics_data = self._cosmetics_id and tweak_data.economy.armor_skins[self._cosmetics_id]
	self._cosmetics_quality = self._cosmetics_data and self._cosmetics_data.quality
	self._cosmetics_bonus = self._cosmetics_data and self._cosmetics_data.bonus
	self._request_update = request_update
end

function ArmorSkinExt:get_cosmetics_bonus()
	return self._cosmetics_bonus
end

function ArmorSkinExt:get_cosmetics_quality()
	return self._cosmetics_quality
end

function ArmorSkinExt:get_cosmetics_id()
	return self._cosmetics_id
end

function ArmorSkinExt:get_cosmetics_data()
	return self._cosmetics_data
end

function ArmorSkinExt:_apply_cosmetics(clbks)
	self:_update_materials()

	clbks = clbks or {}

	print("[ArmorSkinExt] _apply_cosmetics")

	local cosmetics_data = self:get_cosmetics_data()

	if not cosmetics_data or not self._materials or table.size(self._materials) == 0 then
		if clbks.done then
			clbks.done()
		end

		return
	end

	local texture_load_result_clbk = clbks.done and callback(self, self, "clbk_texture_loaded", clbks)
	local textures = {}
	local base_variable, base_texture, custom_variable, texture_key = nil
	local wear_tear_value = self._cosmetics_quality and tweak_data.economy.qualities[self._cosmetics_quality] and tweak_data.economy.qualities[self._cosmetics_quality].wear_tear_value or 1

	for _, material in pairs(self._materials) do
		material:set_variable(Idstring("wear_tear_value"), wear_tear_value)

		for key, variable in pairs(material_variables) do
			base_variable = cosmetics_data[key]

			if base_variable then
				material:set_variable(Idstring(variable), tweak_data.economy:get_armor_based_value(base_variable, self:armor_level()))
			end
		end

		for key, material_texture in pairs(material_textures) do
			base_texture = cosmetics_data[key]

			if base_texture then
				base_texture = tweak_data.economy:get_armor_based_value(base_texture, self:armor_level())
				texture_key = base_texture and base_texture:key()
				textures[texture_key] = textures[texture_key] or {
					applied = false,
					ready = false,
					name = base_texture
				}

				if type(textures[texture_key].name) == "string" then
					textures[texture_key].name = Idstring(textures[texture_key].name)
				end
			end
		end
	end

	if not self._textures then
		self._textures = {}
	end

	for key, old_texture in pairs(self._textures) do
		if not textures[key] and not old_texture.applied and old_texture.reqeusted then
			TextureCache:unretrieve(old_texture.name)
		end
	end

	self._textures = textures

	if clbks.textures_retrieved then
		clbks.textures_retrieved(self._textures)
	end

	self._requesting = clbks.done and true

	for tex_key, texture_data in pairs(self._textures) do
		if clbks.done then
			if not texture_data.ready then
				if DB:has(Idstring("texture"), texture_data.name) then
					TextureCache:request(texture_data.name, "normal", texture_load_result_clbk, 90)

					texture_data.reqeusted = true
				else
					Application:error("[ArmorSkinExt:_apply_cosmetics] Armour cosmetics tried to use no-existing texture!", "texture", texture_data.name)
				end
			end
		else
			texture_data.ready = true
		end
	end

	self._requesting = nil

	self:_chk_load_complete(clbks.done)
end

function ArmorSkinExt:clbk_texture_loaded(clbks, tex_name)
	if not alive(self._unit) then
		return
	end

	local texture_data = self._textures[tex_name:key()]

	if texture_data and not texture_data.ready then
		texture_data.ready = true

		if clbks.texture_loaded then
			clbks.texture_loaded(tex_name)
		end
	end

	self:_chk_load_complete(clbks.done or function ()
	end)
end

function ArmorSkinExt:_chk_load_complete(async_clbk)
	print("[ArmorSkinExt] _chk_load_complete")

	if self._requesting then
		print("[ArmorSkinExt] _chk_load_complete EARLY EXIT")

		return
	end

	for tex_id, texture_data in pairs(self._textures) do
		if not texture_data.ready then
			return
		end
	end

	self:_set_material_textures()

	if async_clbk then
		async_clbk()
	end
end

function ArmorSkinExt:_set_material_textures()
	print("[ArmorSkinExt] _set_material_textures")

	local cosmetics_data = self:get_cosmetics_data()

	if not cosmetics_data or not self._materials or table.size(self._materials) == 0 then
		print("[ArmorSkinExt] _set_material_textures EARLY EXIT")

		return
	end

	local armor_level = self:armor_level()
	local p_type, base_texture, new_texture = nil

	for _, material in pairs(self._materials) do
		for key, material_texture in pairs(material_textures) do
			base_texture = tweak_data.economy:get_armor_based_value(cosmetics_data[key], armor_level)
			new_texture = base_texture or tweak_data.economy:get_armor_based_value(material_defaults[material_texture], armor_level)

			if type(new_texture) == "string" then
				new_texture = Idstring(new_texture)
			end

			if new_texture then
				Application:set_material_texture(material, Idstring(material_texture), new_texture, Idstring("normal"))
			end
		end
	end

	for tex_id, texture_data in pairs(self._textures) do
		if not texture_data.applied then
			texture_data.applied = true

			if texture_data.requested then
				TextureCache:unretrieve(texture_data.name)
			end
		end
	end
end

function ArmorSkinExt:_get_cc_material_config()
	local ids_config_key = self._unit:material_config():key()

	for orig_config_key, cc_config in pairs(tweak_data.economy.armor_skins_configs) do
		if orig_config_key == ids_config_key then
			return cc_config
		end
	end
end

function ArmorSkinExt:_get_original_material_config()
	local ids_config_key = self._unit:material_config():key()

	for cc_config_key, orig_config in pairs(tweak_data.economy.armor_skins_configs_map) do
		if cc_config_key == ids_config_key then
			return orig_config
		end
	end
end

function ArmorSkinExt:set_character(character_name)
	local char_config = tweak_data.economy.character_cc_configs[character_name]

	if char_config then
		self._unit:set_material_config(char_config, true)
	end
end

function ArmorSkinExt:_update_materials()
	local use = self:use_cc()
	local use_cc_material_config = use and self._cosmetics_data and not self._cosmetics_data.ignore_cc and true or false
	local material_config_ids = Idstring("material_config")

	if use_cc_material_config then
		local new_material_config_ids = self:_get_cc_material_config()

		if new_material_config_ids then
			self._unit:set_material_config(new_material_config_ids, true)
		end

		self._materials = {}
		local materials = self._unit:get_objects_by_type(Idstring("material"))

		for _, m in ipairs(materials) do
			if m:variable_exists(Idstring("wear_tear_value")) then
				self._materials[m:key()] = m
			end
		end
	else
		local new_material_config_ids = self:_get_original_material_config()

		if new_material_config_ids and DB:has(material_config_ids, new_material_config_ids) then
			self._unit:set_material_config(new_material_config_ids, true)
		end
	end
end

function ArmorSkinExt:use_cc()
	return true
end

