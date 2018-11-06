TeamAIInventory = TeamAIInventory or class(CopInventory)
TeamAIInventory.add_unit_by_factory_name = HuskPlayerInventory.add_unit_by_factory_name
TeamAIInventory.add_unit_by_factory_blueprint = HuskPlayerInventory.add_unit_by_factory_blueprint

function TeamAIInventory:preload_mask()
	local character_name = managers.criminals:character_name_by_unit(self._unit)
	local mask_unit_name = managers.criminals:character_data_by_name(character_name).mask_obj
	mask_unit_name = mask_unit_name[Global.level_data.level_id] or mask_unit_name.default or mask_unit_name
	self._mask_unit_name = mask_unit_name

	managers.dyn_resource:load(Idstring("unit"), Idstring(mask_unit_name), managers.dyn_resource.DYN_RESOURCES_PACKAGE, callback(self, self, "clbk_mask_unit_loaded"))
end

function TeamAIInventory:clbk_mask_unit_loaded(status, asset_type, asset_name)
	self._mask_unit_loaded = status

	self:_reset_mask_visibility()
end

function TeamAIInventory:is_mask_unit_loaded()
	return self._mask_unit_loaded
end

function TeamAIInventory:add_unit_by_name(new_unit_name, equip)
	local new_unit = World:spawn_unit(new_unit_name, Vector3(), Rotation())
	local setup_data = {
		user_unit = self._unit,
		ignore_units = {
			self._unit,
			new_unit
		},
		expend_ammo = false,
		hit_slotmask = managers.slot:get_mask("bullet_impact_targets"),
		user_sound_variant = tweak_data.character[self._unit:base()._tweak_table].weapon_voice,
		alert_AI = true,
		alert_filter = self._unit:brain():SO_access()
	}

	new_unit:base():setup(setup_data)
	self:add_unit(new_unit, equip)
	new_unit:set_enabled(false)
end

function TeamAIInventory:add_unit(new_unit, equip)
	TeamAIInventory.super.add_unit(self, new_unit, equip)

	if new_unit:base().set_user_is_team_ai then
		print("Set as team ai")
		new_unit:base():set_user_is_team_ai(true)
	end

	new_unit:set_enabled(false)
	new_unit:base():set_visibility_state(false)
end

function TeamAIInventory:_ensure_weapon_visibility(override_weapon, override)
	local show_gun = override or not self._unit:movement():cool()
	local weapon = override_weapon or self:equipped_unit()

	weapon:set_enabled(show_gun)
	weapon:set_visible(show_gun)

	local base = weapon:base()

	if base and base.set_visibility_state then
		local our_stage = show_gun and self._unit:base()._lod_stage or show_gun

		base:set_visibility_state(show_gun)
	end
end

function TeamAIInventory:equip_selection(selection_index, instant)
	local res = TeamAIInventory.super.equip_selection(self, selection_index, instant)

	self:_ensure_weapon_visibility()

	return res
end

function TeamAIInventory:synch_equipped_weapon(weap_index, blueprint_string, cosmetics_string)
	local weapon_name = self._get_weapon_name_from_sync_index(weap_index)

	if type(weapon_name) == "string" then
		self:add_unit_by_factory_name(weapon_name, true, true, blueprint_string, cosmetics_string or self:cosmetics_string_from_peer(peer, weapon_name))

		return
	end

	self:add_unit_by_name(weapon_name, true, true)
end

function TeamAIInventory:_unload_mask()
	if self._mask_unit_name then
		managers.dyn_resource:unload(Idstring("unit"), Idstring(self._mask_unit_name), DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)

		self._mask_unit_name = nil
	end
end

function TeamAIInventory:_reset_mask_visibility()
	self:set_mask_visibility(self._mask_visibility and true or false)
end

function TeamAIInventory:pre_destroy(unit)
	TeamAIInventory.super.pre_destroy(self, unit)
	self:_unload_mask()
end

function TeamAIInventory:set_visibility_state(state)
	if state and self._unit:movement():cool() then
		return
	end

	TeamAIInventory.super.set_visibility_state(self, state)
end
