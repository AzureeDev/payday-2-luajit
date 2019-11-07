local mvec1 = Vector3()
local mvec2 = Vector3()
local mvec3 = Vector3()

function NewRaycastWeaponBase:change_cosmetics(cosmetics, async_clbk)
	self:set_cosmetics_data(cosmetics)
	self:_apply_cosmetics(async_clbk or function ()
	end)
end

function NewRaycastWeaponBase:set_cosmetics_data(cosmetics)
	if not cosmetics then
		self._cosmetics_id = nil
		self._cosmetics_quality = nil
		self._cosmetics_bonus = nil
		self._cosmetics_data = nil

		return
	end

	self._cosmetics_id = cosmetics and cosmetics.id
	self._cosmetics_quality = cosmetics and cosmetics.quality
	self._cosmetics_bonus = cosmetics and cosmetics.bonus
	self._cosmetics_data = self._cosmetics_id and tweak_data.blackmarket.weapon_skins[self._cosmetics_id]
end

function NewRaycastWeaponBase:get_cosmetics_bonus()
	return self._cosmetics_bonus
end

function NewRaycastWeaponBase:get_cosmetics_quality()
	return self._cosmetics_quality
end

function NewRaycastWeaponBase:get_cosmetics_id()
	return self._cosmetics_id
end

function NewRaycastWeaponBase:get_cosmetics_data()
	return self._cosmetics_data
end

function NewRaycastWeaponBase:_material_config_name(part_id, unit_name, use_cc_material_config, force_third_person)
	force_third_person = force_third_person or _G.IS_VR

	if self:is_npc() or force_third_person then
		if use_cc_material_config and tweak_data.weapon.factory.parts[part_id].cc_thq_material_config then
			return tweak_data.weapon.factory.parts[part_id].cc_thq_material_config
		end

		if tweak_data.weapon.factory.parts[part_id].thq_material_config then
			return tweak_data.weapon.factory.parts[part_id].thq_material_config
		end

		local cc_string = use_cc_material_config and "_cc" or ""
		local thq_string = (self:use_thq() or force_third_person) and "_thq" or ""

		return Idstring(unit_name .. cc_string .. thq_string)
	end

	if use_cc_material_config and tweak_data.weapon.factory.parts[part_id].cc_material_config then
		return tweak_data.weapon.factory.parts[part_id].cc_material_config
	end

	return Idstring(unit_name .. "_cc")
end

function NewRaycastWeaponBase:_update_materials()
	if not self._parts then
		return
	end

	local use = not self:is_npc() or self:use_thq()
	local use_cc_material_config = use and self._cosmetics_data and true or false
	local is_thq = self:is_npc() and self:use_thq()
	is_thq = is_thq or not self:is_npc() and _G.IS_VR

	if is_thq or use_cc_material_config then
		if not self._materials then
			local material_config_ids = Idstring("material_config")

			for part_id, part in pairs(self._parts) do
				local part_data = managers.weapon_factory:get_part_data_by_part_id_from_weapon(part_id, self._factory_id, self._blueprint)

				if part_data then
					local new_material_config_ids = self:_material_config_name(part_id, part_data.unit, use_cc_material_config)

					if part.unit:material_config() ~= new_material_config_ids and DB:has(material_config_ids, new_material_config_ids) then
						part.unit:set_material_config(new_material_config_ids, true)
					end
				end
			end

			if use_cc_material_config then
				self._materials = {}
				self._materials_default = {}

				for part_id, part in pairs(self._parts) do
					local materials = part.unit:get_objects_by_type(Idstring("material"))

					for _, m in ipairs(materials) do
						if m:variable_exists(Idstring("wear_tear_value")) then
							self._materials[part_id] = self._materials[part_id] or {}
							self._materials[part_id][m:key()] = m
						end
					end
				end
			end
		end
	elseif self._materials then
		local material_config_ids = Idstring("material_config")

		for part_id, part in pairs(self._parts) do
			if tweak_data.weapon.factory.parts[part_id] then
				local new_material_config_ids = tweak_data.weapon.factory.parts[part_id].material_config or Idstring(self:is_npc() and tweak_data.weapon.factory.parts[part_id].third_unit or tweak_data.weapon.factory.parts[part_id].unit)

				if part.unit:material_config() ~= new_material_config_ids and DB:has(material_config_ids, new_material_config_ids) then
					part.unit:set_material_config(new_material_config_ids, true)
				end
			end
		end

		self._materials = nil
	end
end

local material_defaults = {
	diffuse_layer1_texture = Idstring("units/payday2_cash/safes/default/base_gradient/base_default_df"),
	diffuse_layer2_texture = Idstring("units/payday2_cash/safes/default/pattern_gradient/gradient_default_df"),
	diffuse_layer0_texture = Idstring("units/payday2_cash/safes/default/pattern/pattern_default_df"),
	diffuse_layer3_texture = Idstring("units/payday2_cash/safes/default/sticker/sticker_default_df")
}
local material_textures = {
	pattern = "diffuse_layer0_texture",
	sticker = "diffuse_layer3_texture",
	pattern_gradient = "diffuse_layer2_texture",
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

function NewRaycastWeaponBase:get_cosmetic_value(...)
	local cosmetic_value = self:get_cosmetics_data()

	for _, key in ipairs({
		...
	}) do
		cosmetic_value = cosmetic_value and cosmetic_value[key]
	end

	return cosmetic_value
end

function NewRaycastWeaponBase:_apply_cosmetics(async_clbk)
	material_variables.wear_and_tear = (managers.blackmarket and managers.blackmarket:skin_editor() and managers.blackmarket:skin_editor():active() or Application:production_build()) and "wear_tear_value" or nil

	self:_update_materials()

	local cosmetics_data = self:get_cosmetics_data()

	if not self._parts or not cosmetics_data or not self._materials or table.size(self._materials) == 0 then
		if async_clbk then
			async_clbk()
		end

		return
	end

	local texture_load_result_clbk = async_clbk and callback(self, self, "clbk_texture_loaded", async_clbk)
	local textures = {}
	local texture_key, p_type, value = nil
	local wear_tear_value = self._cosmetics_quality and tweak_data.economy.qualities[self._cosmetics_quality] and tweak_data.economy.qualities[self._cosmetics_quality].wear_tear_value or 1

	for part_id, materials in pairs(self._materials) do
		for _, material in pairs(materials) do
			material:set_variable(Idstring("wear_tear_value"), wear_tear_value)

			p_type = managers.weapon_factory:get_type_from_part_id(part_id)

			for key, variable in pairs(material_variables) do
				value = self:get_cosmetic_value("weapons", self._name_id, "parts", part_id, material:name():key(), key) or self:get_cosmetic_value("weapons", self._name_id, "types", p_type, key) or self:get_cosmetic_value("weapons", self._name_id, key) or self:get_cosmetic_value("parts", part_id, material:name():key(), key) or self:get_cosmetic_value("types", p_type, key) or self:get_cosmetic_value(key)

				if value then
					material:set_variable(Idstring(variable), value)
				end
			end

			for key, material_texture in pairs(material_textures) do
				value = self:get_cosmetic_value("weapons", self._name_id, "parts", part_id, material:name():key(), key) or self:get_cosmetic_value("weapons", self._name_id, "types", p_type, key) or self:get_cosmetic_value("weapons", self._name_id, key) or self:get_cosmetic_value("parts", part_id, material:name():key(), key) or self:get_cosmetic_value("types", p_type, key) or self:get_cosmetic_value(key)

				if value then
					if type_name(value) ~= "Idstring" then
						value = Idstring(value)
					end

					texture_key = value:key()
					textures[texture_key] = textures[texture_key] or {
						applied = false,
						ready = false,
						name = value
					}
				end
			end
		end
	end

	for key, old_texture in pairs(self._textures) do
		if not textures[key] and not old_texture.applied then
			TextureCache:unretrieve(old_texture.name)
		end
	end

	self._textures = textures
	self._requesting = async_clbk and true

	for tex_key, texture_data in pairs(self._textures) do
		if async_clbk then
			if not texture_data.ready then
				if DB:has(Idstring("texture"), texture_data.name) then
					TextureCache:request(texture_data.name, "normal", texture_load_result_clbk, 90)
				else
					Application:error("[NewRaycastWeaponBase:_apply_cosmetics] Weapon cosmetics tried to use no-existing texture!", "texture", texture_data.name)
				end
			end
		else
			texture_data.ready = true
		end
	end

	self._requesting = nil

	self:_chk_load_complete(async_clbk)
end

function NewRaycastWeaponBase:clbk_texture_loaded(async_clbk, tex_name)
	if not alive(self._unit) then
		return
	end

	local texture_data = self._textures[tex_name:key()]

	if texture_data and not texture_data.ready then
		texture_data.ready = true
	end

	self:_chk_load_complete(async_clbk)
end

function NewRaycastWeaponBase:_chk_load_complete(async_clbk)
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

function NewRaycastWeaponBase:_set_material_textures()
	local cosmetics_data = self:get_cosmetics_data()

	if not self._parts or not cosmetics_data or not self._materials or table.size(self._materials) == 0 then
		return
	end

	local p_type, value = nil

	for part_id, materials in pairs(self._materials) do
		p_type = managers.weapon_factory:get_type_from_part_id(part_id)

		for _, material in pairs(materials) do
			for key, material_texture in pairs(material_textures) do
				value = self:get_cosmetic_value("weapons", self._name_id, "parts", part_id, material:name():key(), key) or self:get_cosmetic_value("weapons", self._name_id, "types", p_type, key) or self:get_cosmetic_value("weapons", self._name_id, key) or self:get_cosmetic_value("parts", part_id, material:name():key(), key) or self:get_cosmetic_value("types", p_type, key) or self:get_cosmetic_value(key)

				if value then
					if type_name(value) ~= "Idstring" then
						value = Idstring(value)
					end

					Application:set_material_texture(material, Idstring(material_texture), value, Idstring("normal"))
				end
			end
		end
	end

	for tex_id, texture_data in pairs(self._textures) do
		if not texture_data.applied then
			texture_data.applied = true

			TextureCache:unretrieve(texture_data.name)
		end
	end
end

function NewRaycastWeaponBase:spawn_magazine_unit(pos, rot, hide_bullets)
	local mag_data = nil
	local mag_list = managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("magazine", self._factory_id, self._blueprint)
	local mag_id = mag_list and mag_list[1]

	if not mag_id then
		return
	end

	mag_data = managers.weapon_factory:get_part_data_by_part_id_from_weapon(mag_id, self._factory_id, self._blueprint)
	local part_data = self._parts[mag_id]

	if not mag_data or not part_data then
		return
	end

	pos = pos or Vector3()
	rot = rot or Rotation()
	local is_thq = managers.weapon_factory:use_thq_weapon_parts()
	local use_cc_material_config = is_thq and self:get_cosmetics_data() and true or false
	local material_config_ids = Idstring("material_config")
	local mag_unit = World:spawn_unit(part_data.name, pos, rot)
	local new_material_config_ids = self:_material_config_name(mag_id, mag_data.unit, use_cc_material_config, true)

	if mag_unit:material_config() ~= new_material_config_ids and DB:has(material_config_ids, new_material_config_ids) then
		mag_unit:set_material_config(new_material_config_ids, true)
	end

	if hide_bullets and part_data.bullet_objects then
		local prefix = part_data.bullet_objects.prefix

		for i = 1, part_data.bullet_objects.amount, 1 do
			local target_object = mag_unit:get_object(Idstring(prefix .. i))
			local ref_object = part_data.unit:get_object(Idstring(prefix .. i))

			if target_object then
				if ref_object then
					target_object:set_visibility(ref_object:visibility())
				else
					target_object:set_visibility(false)
				end
			end
		end
	end

	local materials = {}
	local unit_materials = mag_unit:get_objects_by_type(Idstring("material")) or {}

	for _, m in ipairs(unit_materials) do
		if m:variable_exists(Idstring("wear_tear_value")) then
			table.insert(materials, m)
		end
	end

	local textures = {}
	local texture_key, p_type, value = nil
	local cosmetics_quality = self._cosmetics_quality
	local wear_tear_value = cosmetics_quality and tweak_data.economy.qualities[cosmetics_quality] and tweak_data.economy.qualities[cosmetics_quality].wear_tear_value or 1

	for _, material in pairs(materials) do
		material:set_variable(Idstring("wear_tear_value"), wear_tear_value)

		p_type = managers.weapon_factory:get_type_from_part_id(mag_id)

		for key, variable in pairs(material_variables) do
			value = self:get_cosmetic_value("weapons", self._name_id, "parts", mag_id, material:name():key(), key) or self:get_cosmetic_value("weapons", self._name_id, "types", p_type, key) or self:get_cosmetic_value("weapons", self._name_id, key) or self:get_cosmetic_value("parts", mag_id, material:name():key(), key) or self:get_cosmetic_value("types", p_type, key) or self:get_cosmetic_value(key)

			if value then
				material:set_variable(Idstring(variable), value)
			end
		end

		for key, material_texture in pairs(material_textures) do
			value = self:get_cosmetic_value("weapons", self._name_id, "parts", mag_id, material:name():key(), key) or self:get_cosmetic_value("weapons", self._name_id, "types", p_type, key) or self:get_cosmetic_value("weapons", self._name_id, key) or self:get_cosmetic_value("parts", mag_id, material:name():key(), key) or self:get_cosmetic_value("types", p_type, key) or self:get_cosmetic_value(key)

			if value then
				if type_name(value) ~= "Idstring" then
					value = Idstring(value)
				end

				Application:set_material_texture(material, Idstring(material_texture), value, Idstring("normal"))
			end
		end
	end

	return mag_unit
end

NewRaycastWeaponBase.magazine_collisions = {
	small = {
		Idstring("units/payday2/weapons/box_collision/box_collision_small_pistol"),
		Idstring("rp_box_collision_small")
	},
	medium = {
		Idstring("units/payday2/weapons/box_collision/box_collision_medium_ar"),
		Idstring("rp_box_collision_medium")
	},
	large = {
		Idstring("units/payday2/weapons/box_collision/box_collision_large_metal"),
		Idstring("rp_box_collision_large")
	},
	pistol = {
		Idstring("units/payday2/weapons/box_collision/box_collision_small_pistol"),
		Idstring("rp_box_collision_small")
	},
	smg = {
		Idstring("units/payday2/weapons/box_collision/box_collision_small_smg"),
		Idstring("rp_box_collision_small")
	},
	rifle = {
		Idstring("units/payday2/weapons/box_collision/box_collision_medium_ar"),
		Idstring("rp_box_collision_medium")
	},
	large_plastic = {
		Idstring("units/payday2/weapons/box_collision/box_collision_large_plastic"),
		Idstring("rp_box_collision_large")
	},
	large_metal = {
		Idstring("units/payday2/weapons/box_collision/box_collision_large_metal"),
		Idstring("rp_box_collision_large")
	}
}
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local tmp_vec3 = Vector3()
local mvec3_set = mvector3.set
local mvec3_add = mvector3.add
local mvec3_sub = mvector3.subtract
local mvec3_mul = mvector3.multiply

function NewRaycastWeaponBase:drop_magazine_object()
	if not self._name_id then
		return
	end

	local name_id = self._name_id

	for original_name, name in pairs(tweak_data.animation.animation_redirects) do
		if name == name_id then
			name_id = original_name

			break
		end
	end

	local w_td_crew = tweak_data.weapon[name_id .. "_crew"]

	for part_id, part_data in pairs(self._parts) do
		local part = tweak_data.weapon.factory.parts[part_id]

		if part and part.type == "magazine" then
			local pos = part_data.unit:position()
			local rot = part_data.unit:rotation()
			local dropped_mag = self:spawn_magazine_unit(pos, rot, true)
			local mag_size = w_td_crew and w_td_crew.pull_magazine_during_reload or "medium"

			mvec3_set(tmp_vec1, dropped_mag:oobb():center())
			mvec3_sub(tmp_vec1, dropped_mag:position())
			mvec3_set(tmp_vec2, dropped_mag:position())
			mvec3_add(tmp_vec2, tmp_vec1)

			local dropped_col = World:spawn_unit(NewRaycastWeaponBase.magazine_collisions[mag_size][1], tmp_vec2, part_data.unit:rotation())

			dropped_col:link(NewRaycastWeaponBase.magazine_collisions[mag_size][2], dropped_mag)
			mvec3_set(tmp_vec3, -rot:z())
			mvec3_mul(tmp_vec3, 100)
			dropped_col:push(20, tmp_vec3)
			managers.enemy:add_magazine(dropped_mag, dropped_col)
		end
	end
end
