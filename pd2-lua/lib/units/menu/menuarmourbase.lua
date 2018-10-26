MenuArmourBase = MenuArmourBase or class(UnitBase)
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

function MenuArmourBase:init(unit, update_enabled)
	MenuArmourBase.super.init(self, unit, true)
	self:set_armor_id("level_1")

	self._character_name = "dallas"
end

function MenuArmourBase:update(unit, t, dt)
	if self._request_update then
		self:_apply_cosmetics()

		self._request_update = nil
	end
end

function MenuArmourBase:set_armor_id(armor_id)
	local data = tweak_data.blackmarket.armors[armor_id]

	if data then
		self._level = data.upgrade_level
	else
		self._level = 1
	end
end

function MenuArmourBase:armor_level()
	if self._level then
		return self._level
	else
		local armor = tweak_data.blackmarket.armors[managers.blackmarket:equipped_armor()]

		return armor and armor.upgrade_level or 1
	end
end

function MenuArmourBase:character_name()
	return self._character_name
end

function MenuArmourBase:mask_id()
	return self._mask_id
end

function MenuArmourBase:set_character_name(name)
	self._character_name = name
	self._special_material = self:_pick_special_material()

	self:request_cosmetics_update()
end

function MenuArmourBase:set_mask_id(id)
	self._mask_id = id

	self:request_cosmetics_update()
end

function MenuArmourBase:set_armor_skin_id(id)
	if not id then
		self._cosmetics_id = nil
		self._cosmetics_quality = nil
		self._cosmetics_bonus = nil
		self._cosmetics_data = nil
		self._request_update = false

		return
	end

	self._cosmetics_id = id
	self._cosmetics_data = self._cosmetics_id and tweak_data.economy.armor_skins[self._cosmetics_id]
	self._cosmetics_quality = self._cosmetics_data and self._cosmetics_data.quality
	self._cosmetics_bonus = self._cosmetics_data and self._cosmetics_data.bonus

	self:request_cosmetics_update()
end

function MenuArmourBase:set_cosmetics_data(armor_skin_id)
	self:set_armor_skin_id(armor_skin_id)
end

function MenuArmourBase:request_cosmetics_update()
	self._request_update = true
end

function MenuArmourBase:get_cosmetics_bonus()
	return self._cosmetics_bonus
end

function MenuArmourBase:get_cosmetics_quality()
	return self._cosmetics_quality
end

function MenuArmourBase:get_cosmetics_id()
	return self._cosmetics_id
end

function MenuArmourBase:get_cosmetics_data()
	return self._cosmetics_data
end

function MenuArmourBase:_apply_cosmetics(clbks)
	local sequence = managers.blackmarket:character_sequence_by_character_name(self._character_name)

	self._unit:damage():run_sequence_simple(sequence)
	self:_check_character_mask_sequence(self._unit, self._mask_id, self._character_name)
	self:_update_materials()

	clbks = clbks or {}
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

				if texture_key then
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
					Application:error("[MenuArmourBase:_apply_cosmetics] Armour cosmetics tried to use no-existing texture!", "texture", texture_data.name)
				end
			end
		else
			texture_data.ready = true
		end
	end

	self._requesting = nil

	self:_chk_load_complete(clbks.done)
end

function MenuArmourBase:_check_character_mask_sequence(character_unit, mask_id, character_name)
	if tweak_data.blackmarket.masks[mask_id].skip_mask_on_sequence then
		local mask_off_sequence = managers.blackmarket:character_mask_off_sequence_by_character_name(character_name)

		if mask_off_sequence and character_unit:damage():has_sequence(mask_off_sequence) then
			character_unit:damage():run_sequence_simple(mask_off_sequence)
		end
	else
		local mask_on_sequence = managers.blackmarket:character_mask_on_sequence_by_character_name(character_name)

		if mask_on_sequence and character_unit:damage():has_sequence(mask_on_sequence) then
			character_unit:damage():run_sequence_simple(mask_on_sequence)
		end
	end
end

function MenuArmourBase:clbk_texture_loaded(clbks, tex_name)
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

function MenuArmourBase:_chk_load_complete(async_clbk)
	if self._requesting then
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

function MenuArmourBase:_set_material_textures()
	local cosmetics_data = self:get_cosmetics_data()

	if not cosmetics_data or not self._materials or table.size(self._materials) == 0 then
		return
	end

	if not alive(self._unit) then
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

			if new_texture and alive(material) then
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

function MenuArmourBase:_pick_special_material()
	local character_id = managers.blackmarket:get_character_id_by_character_name(self:character_name())
	local special_materials = tweak_data.blackmarket.characters[character_id].special_materials

	if not special_materials then
		return nil
	end

	local special_material = nil

	for sequence, chance in pairs(special_materials) do
		if type(chance) == "number" then
			local rand = math.rand(chance)

			if rand <= 1 then
				special_material = sequence

				break
			end
		end
	end

	special_material = special_material or table.random(special_materials)
	local special_material_ids = Idstring(special_material)

	if not DB:has(Idstring("material_config"), special_material_ids) then
		print("[MenuArmourBase:_pick_special_material] Missing material config", special_material)

		special_material = nil
	end

	return special_material
end

function MenuArmourBase:_get_cc_material_config()
	if self._special_material then
		return Idstring(self._special_material .. "_cc")
	end

	local character_name = CriminalsManager.convert_new_to_old_character_workname(self._character_name)

	return tweak_data.economy.character_cc_configs[character_name]
end

function MenuArmourBase:_get_original_material_config()
	if self._special_material then
		return Idstring(self._special_material)
	end

	local cc_config_key = self:_get_cc_material_config():key()

	return tweak_data.economy.armor_skins_configs_map[cc_config_key]
end

function MenuArmourBase:_update_materials()
	local material_config_ids = Idstring("material_config")
	self._materials = {}

	if self:use_cc() then
		self._unit:set_material_config(self:_get_cc_material_config(), true)

		local materials = self._unit:get_objects_by_type(Idstring("material"))

		for _, m in ipairs(materials) do
			if m:variable_exists(Idstring("wear_tear_value")) then
				self._materials[m:key()] = m
			end
		end
	else
		self._unit:set_material_config(self:_get_original_material_config(), true)
	end
end

function MenuArmourBase:use_cc()
	local ignored_by_armor_skin = self._cosmetics_data and self._cosmetics_data.ignore_cc
	local no_armor_skin = not self._cosmetics_id or self._cosmetics_id == "none"

	return not ignored_by_armor_skin and not no_armor_skin
end

