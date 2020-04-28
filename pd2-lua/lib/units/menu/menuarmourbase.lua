MenuArmourBase = MenuArmourBase or class(UnitBase)
local ids_unit = Idstring("unit")
local ids_material_config = Idstring("material_config")
local ids_NORMAL = Idstring("NORMAL")
MenuArmourBase.material_defaults = {
	bump_normal_texture = {
		[2] = Idstring("units/payday2/characters/shared_textures/vest_small_nm"),
		[3] = Idstring("units/payday2/characters/shared_textures/vest_big_nm")
	},
	diffuse_layer1_texture = Idstring("units/payday2_cash/safes/default/base_gradient/base_default_df"),
	diffuse_layer2_texture = Idstring("units/payday2_cash/safes/default/pattern_gradient/gradient_default_df"),
	diffuse_layer0_texture = Idstring("units/payday2_cash/safes/default/pattern/pattern_default_df"),
	diffuse_layer3_texture = Idstring("units/payday2_cash/safes/default/sticker/sticker_default_df")
}
MenuArmourBase.material_textures = {
	pattern = "diffuse_layer0_texture",
	pattern_gradient = "diffuse_layer2_texture",
	normal_map = "bump_normal_texture",
	sticker = "diffuse_layer3_texture",
	base_gradient = "diffuse_layer1_texture"
}
MenuArmourBase.material_variables = {
	cubemap_pattern_control = "cubemap_pattern_control",
	pattern_pos = "pattern_pos",
	uv_scale = "uv_scale",
	uv_offset_rot = "uv_offset_rot",
	pattern_tweak = "pattern_tweak",
	wear_and_tear = (managers.blackmarket and managers.blackmarket:skin_editor() and managers.blackmarket:skin_editor():active() or Application:production_build()) and "wear_tear_value" or nil
}

function MenuArmourBase:init(unit, update_enabled)
	MenuArmourBase.super.init(self, unit, false)
	self:set_armor_id("level_1")

	self._character_name = "dallas"
	self._visual_seed = CriminalsManager.get_new_visual_seed()
	self._cosmetics = {
		unit = {},
		material_config = {},
		texture = {},
		state = {}
	}
	self._clbk_listeners = {}
	self._clbks = {}
end

function MenuArmourBase:destroy()
	MenuArmourBase.super.destroy(self)
	self:_unload_cosmetic_assets(self._cosmetics)
	self:update_character_visuals(self._cosmetics)
end

function MenuArmourBase:armor_id()
	return self._armor_id
end

function MenuArmourBase:character_name()
	return self._character_name
end

function MenuArmourBase:mask_id()
	return self._mask_id
end

function MenuArmourBase:armor_skin_id()
	return self._armor_skin_id
end

function MenuArmourBase:player_style()
	return self._player_style
end

function MenuArmourBase:suit_variation()
	return self._suit_variation
end

function MenuArmourBase:set_armor_id(armor_id)
	self._armor_id = armor_id

	self:request_cosmetics_update()
end

function MenuArmourBase:set_character_name(name)
	self._character_name = name
	self._is_visuals_updated = false

	self:request_cosmetics_update()
end

function MenuArmourBase:set_mask_id(id)
	self._mask_id = id

	local function call_func()
		if not self._applying_cosmetics and not self._request_update then
			self:update_character_visuals(self._cosmetics)
		end
	end

	if is_next_update_funcs_busy() then
		call_func()
	else
		call_on_next_update(call_func)
	end
end

function MenuArmourBase:set_armor_skin_id(id)
	if not id or tweak_data.economy.armor_skins[id] then
		self._armor_skin_id = id

		self:request_cosmetics_update()
	end
end

function MenuArmourBase:set_cosmetics_data(armor_skin_id)
	self:set_armor_skin_id(armor_skin_id)
end

function MenuArmourBase:set_player_style(player_style, material_variation)
	self._suit_variation = material_variation
	self._player_style = player_style

	self:request_cosmetics_update()
end

function MenuArmourBase:request_cosmetics_update()
	if not self._request_update then
		self._request_update = true

		if is_next_update_funcs_busy() then
			self:_apply_cosmetics()
		else
			call_on_next_update(callback(self, self, "_apply_cosmetics"))
		end
	end
end

function MenuArmourBase:add_clbk_listener(clbk_name, func)
	self._clbk_listeners[clbk_name] = self._clbk_listeners[clbk_name] or {}

	table.insert(self._clbk_listeners[clbk_name], func)
end

function MenuArmourBase:execute_callbacks(clbk_name, ...)
	if self._clbks[clbk_name] then
		self._clbks[clbk_name](...)
	end

	if self._clbk_listeners[clbk_name] then
		for _, func in ipairs(self._clbk_listeners[clbk_name]) do
			func(...)
		end
	end
end

function MenuArmourBase:is_cosmetics_applied()
	return self._is_visuals_updated
end

function MenuArmourBase:update_character_visuals(cosmetics)
	cat_print("character_cosmetics", "[MenuArmourBase:update_character_visuals]")
	self:_print_cosmetics(cosmetics)

	local visual_state = cosmetics and cosmetics.state or {}
	local character_name = visual_state.character_name or self._character_name
	local character_visual_state = {
		is_local_peer = false,
		visual_seed = self._visual_seed,
		player_style = visual_state.player_style or "none",
		suit_variation = visual_state.suit_variation or "default",
		mask_id = visual_state.mask or self._mask_id,
		armor_id = visual_state.armor or "level_1",
		armor_skin = visual_state.armor_skin or "none"
	}

	CriminalsManager.set_character_visual_state(self._unit, character_name, character_visual_state)

	self._is_visuals_updated = true
end

function MenuArmourBase:_use_job()
	return false
end

function MenuArmourBase:get_player_style_check_job()
	if self:_use_job() then
		local player_style = "none"
		local current_level = managers.job and managers.job:current_level_id()

		if current_level then
			player_style = tweak_data.levels[current_level] and tweak_data.levels[current_level].player_style or "none"
		end

		local user_player_style = self._player_style or "none"

		if (not tweak_data.levels[current_level] or not tweak_data.levels[current_level].player_style_locked) and user_player_style ~= "none" then
			player_style = user_player_style
		end

		return player_style or "none"
	end

	return self._player_style or "none"
end

function MenuArmourBase:get_suit_variation_check_job()
	if self:_use_job() then
		return "default"
	end

	return self._suit_variation or "default"
end

function MenuArmourBase:_apply_cosmetics(clbks)
	if self._applying_cosmetics then
		call_on_next_update(callback(self, self, "_apply_cosmetics"))

		return
	end

	self._request_update = nil
	self._is_visuals_updated = false
	self._clbks = clbks or {}
	local units = {}
	local material_configs = {}
	local textures = {}
	local visual_state = {
		character_name = self._character_name,
		player_style = self:get_player_style_check_job(),
		suit_variation = self:get_suit_variation_check_job(),
		mask = self._mask_id,
		armor = self._armor_id,
		armor_skin = self:use_cc() and self._armor_skin_id
	}

	cat_print("character_cosmetics", "[MenuArmourBase:_apply_cosmetics]", inspect(visual_state))

	local new_cosmetics = {
		applied = false,
		loading = false,
		loaded = false,
		unit = units,
		material_config = material_configs,
		texture = textures,
		state = visual_state
	}
	local old_cosmetics = self._cosmetics

	if visual_state.armor_skin then
		local cosmetics_id = visual_state.armor_skin
		local cosmetics_data = cosmetics_id and tweak_data.economy.armor_skins[cosmetics_id]
		local armor_id = visual_state.armor
		local armor_level = 1

		if tweak_data.blackmarket.armors[armor_id] then
			armor_level = tweak_data.blackmarket.armors[armor_id].upgrade_level
		end

		local base_texture = nil

		for key, material_texture in pairs(MenuArmourBase.material_textures) do
			base_texture = cosmetics_data[key]

			if base_texture then
				base_texture = tweak_data.economy:get_armor_based_value(base_texture, armor_level)

				self:_add_asset(textures, base_texture)
			end
		end
	end

	local player_style_name = tweak_data.blackmarket:get_player_style_value(visual_state.player_style, visual_state.character_name, "third_unit")

	if player_style_name then
		self:_add_asset(units, player_style_name)
	end

	local material_variation_name = tweak_data.blackmarket:get_suit_variation_value(visual_state.player_style, visual_state.suit_variation, visual_state.character_name, "third_material")

	if material_variation_name then
		self:_add_asset(material_configs, material_variation_name)
	end

	if table.size(new_cosmetics.unit) > 0 or table.size(new_cosmetics.material_config) > 0 or table.size(new_cosmetics.texture) > 0 then
		self:execute_callbacks("assets_to_load", new_cosmetics)
	end

	self._applying_cosmetics = true
	self._cosmetics = new_cosmetics
	self._old_cosmetics = old_cosmetics

	self:_load_cosmetic_assets(self._cosmetics)

	if self._applying_cosmetics then
		-- Nothing
	end
end

function MenuArmourBase:_add_asset(assets, name)
	if name then
		local ids = name

		if type_name(ids) ~= "Idstring" then
			ids = Idstring(ids)
		end

		local key = ids:key()
		assets[key] = assets[key] or {
			loaded = false,
			name = ids
		}
	end
end

function MenuArmourBase:clbk_armor_unit_loaded(cosmetics, status, asset_type, asset_name)
	if not self._applying_cosmetics then
		return
	end

	if self._cosmetics ~= cosmetics then
		cat_print("character_cosmetics", "[MenuArmourBase:clbk_armor_unit_loaded] Received unit loaded callback from older cosmetics")
		self:_print_cosmetics(cosmetics)

		return
	end

	for asset_id, asset_data in pairs(cosmetics.unit) do
		if asset_data.name == asset_name then
			asset_data.loaded = true

			self:execute_callbacks("asset_loaded", "unit", asset_name)
		end
	end

	self:_chk_load_complete(cosmetics)
end

function MenuArmourBase:clbk_armor_material_config_loaded(cosmetics, status, asset_type, asset_name)
	if not self._applying_cosmetics then
		return
	end

	if self._cosmetics ~= cosmetics then
		cat_print("character_cosmetics", "[MenuArmourBase:clbk_armor_material_config_loaded] Received material_config loaded callback from older cosmetics")
		self:_print_cosmetics(cosmetics)

		return
	end

	for asset_id, asset_data in pairs(cosmetics.material_config) do
		if asset_data.name == asset_name then
			asset_data.loaded = true

			self:execute_callbacks("asset_loaded", "material_config", asset_name)
		end
	end

	self:_chk_load_complete(cosmetics)
end

function MenuArmourBase:clbk_armor_texture_loaded(cosmetics, tex_name)
	if not self._applying_cosmetics then
		return
	end

	if self._cosmetics ~= cosmetics then
		cat_print("character_cosmetics", "[MenuArmourBase:clbk_armor_texture_loaded] Received texture loaded callback from older cosmetics")
		self:_print_cosmetics(cosmetics)

		return
	end

	for asset_id, asset_data in pairs(cosmetics.texture) do
		if asset_data.name == tex_name then
			asset_data.loaded = true

			self:execute_callbacks("asset_loaded", "texture", tex_name)
		end
	end

	self:_chk_load_complete(cosmetics)
end

function MenuArmourBase:_chk_load_complete(cosmetics)
	if not self._applying_cosmetics or not self._all_load_requests_sent then
		return
	end

	if self._cosmetics ~= cosmetics then
		cat_print("character_cosmetics", "[MenuArmourBase:_chk_load_complete] Checking cosmetics loaded on older cosmetics")
		self:_print_cosmetics(cosmetics)

		return
	end

	for asset_id, asset_data in pairs(cosmetics.unit) do
		if not asset_data.loaded then
			return
		end
	end

	for asset_id, asset_data in pairs(cosmetics.material_config) do
		if not asset_data.loaded then
			return
		end
	end

	for asset_id, asset_data in pairs(cosmetics.texture) do
		if not asset_data.loaded then
			return
		end
	end

	local unit_damage = alive(self._unit) and self._unit:damage()

	if not unit_damage then
		self:_unload_cosmetic_assets(cosmetics)

		self._clbks = {}
		self._clbk_listeners = {}

		return
	end

	if self._unit:spawn_manager() then
		self._unit:spawn_manager().allow_client_spawn = true
	end

	cosmetics.loaded = true

	if self._old_cosmetics then
		self:_unload_cosmetic_assets(self._old_cosmetics)
	end

	self:update_character_visuals(cosmetics)

	if cosmetics.state.armor_skin then
		self._materials = {}
		local materials = self._unit:get_objects_by_type(Idstring("material"))

		for _, m in ipairs(materials) do
			if m:variable_exists(Idstring("wear_tear_value")) then
				self._materials[m:key()] = m
			end
		end

		local cosmetics_id = cosmetics.state.armor_skin
		local cosmetics_data = cosmetics_id and tweak_data.economy.armor_skins[cosmetics_id]
		local armor_id = cosmetics.state.armor
		local armor_level = 1

		if tweak_data.blackmarket.armors[armor_id] then
			armor_level = tweak_data.blackmarket.armors[armor_id].upgrade_level
		end

		local p_type, base_texture, new_texture, base_variable = nil

		for _, material in pairs(self._materials) do
			for key, material_texture in pairs(MenuArmourBase.material_textures) do
				base_texture = tweak_data.economy:get_armor_based_value(cosmetics_data[key], armor_level)
				new_texture = base_texture or tweak_data.economy:get_armor_based_value(MenuArmourBase.material_defaults[material_texture], armor_level)

				if type(new_texture) == "string" then
					new_texture = Idstring(new_texture)
				end

				for key, variable in pairs(MenuArmourBase.material_variables) do
					base_variable = cosmetics_data[key]

					if base_variable then
						material:set_variable(Idstring(variable), tweak_data.economy:get_armor_based_value(base_variable, armor_level))
					end
				end

				if new_texture and alive(material) then
					Application:set_material_texture(material, Idstring(material_texture), new_texture, ids_NORMAL)
				end
			end
		end
	end

	cosmetics.applied = true
	self._applying_cosmetics = false

	self:execute_callbacks("done")

	self._clbks = {}
	self._clbk_listeners = {}

	if managers.menu_scene then
		managers.menu_scene:_chk_character_visibility(self._unit)
	end
end

function MenuArmourBase:_load_cosmetic_assets(cosmetics)
	cat_print("character_cosmetics", "[MenuArmourBase:_load_cosmetic_assets]")
	self:_print_cosmetics(cosmetics)

	if cosmetics.applied then
		Application:error("[MenuArmourBase:_load_cosmetic_assets] Attempting to load cosmetics that are already being applied")

		return
	end

	if cosmetics.loaded then
		Application:error("[MenuArmourBase:_load_cosmetic_assets] Attempting to load cosmetics that are already loaded")

		return
	end

	if cosmetics.loading then
		Application:error("[MenuArmourBase:_load_cosmetic_assets] Attempting to load cosmetics that are loading")

		return
	end

	cosmetics.loading = true
	cosmetics.loaded = false
	cosmetics.applied = false
	local unit_load_result_clbk = callback(self, self, "clbk_armor_unit_loaded", cosmetics)
	local material_config_load_result_clbk = callback(self, self, "clbk_armor_material_config_loaded", cosmetics)
	local texture_load_result_clbk = callback(self, self, "clbk_armor_texture_loaded", cosmetics)
	self._all_load_requests_sent = false

	for asset_id, asset_data in pairs(cosmetics.unit) do
		managers.dyn_resource:load(ids_unit, asset_data.name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, unit_load_result_clbk)
	end

	for asset_id, asset_data in pairs(cosmetics.material_config) do
		managers.dyn_resource:load(ids_material_config, asset_data.name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, material_config_load_result_clbk)
	end

	for asset_id, asset_data in pairs(cosmetics.texture) do
		TextureCache:request(asset_data.name, ids_NORMAL, texture_load_result_clbk, 90)
	end

	self._all_load_requests_sent = true

	self:_chk_load_complete(cosmetics)
end

function MenuArmourBase:_unload_cosmetic_assets(cosmetics)
	cat_print("character_cosmetics", "[MenuArmourBase:_unload_cosmetic_assets]")
	self:_print_cosmetics(cosmetics)

	for asset_id, asset_data in pairs(cosmetics.unit) do
		managers.dyn_resource:unload(ids_unit, asset_data.name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)
	end

	for asset_id, asset_data in pairs(cosmetics.material_config) do
		managers.dyn_resource:unload(ids_material_config, asset_data.name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)
	end

	for asset_id, asset_data in pairs(cosmetics.texture) do
		TextureCache:unretrieve(asset_data.name)
	end

	local visual_state = {
		character = self._character_name,
		mask = self._mask_id,
		armor = self._armor_id
	}
	cosmetics.unit = {}
	cosmetics.material_config = {}
	cosmetics.texture = {}
	cosmetics.state = visual_state
	cosmetics.loading = false
	cosmetics.loaded = false
	cosmetics.applied = false
end

function MenuArmourBase:use_cc()
	local ignored_by_armor_skin = self._cosmetics_data and self._cosmetics_data.ignore_cc
	local no_armor_skin = not self._armor_skin_id or self._armor_skin_id == "none"

	return not ignored_by_armor_skin and not no_armor_skin
end

function MenuArmourBase:_print_cosmetics(cosmetics)
end
