HuskTeamAIInventory = HuskTeamAIInventory or class(HuskCopInventory)
HuskTeamAIInventory.preload_mask = TeamAIInventory.preload_mask
HuskTeamAIInventory.clbk_mask_unit_loaded = TeamAIInventory.clbk_mask_unit_loaded
HuskTeamAIInventory._reset_mask_visibility = TeamAIInventory._reset_mask_visibility
HuskTeamAIInventory._ensure_weapon_visibility = TeamAIInventory._ensure_weapon_visibility
HuskTeamAIInventory.set_visibility_state = TeamAIInventory.set_visibility_state

function HuskTeamAIInventory:add_unit_by_name(new_unit_name, equip)
	local new_unit = World:spawn_unit(new_unit_name, Vector3(), Rotation())
	local setup_data = {
		user_unit = self._unit,
		ignore_units = {
			self._unit,
			new_unit
		},
		expend_ammo = false,
		hit_slotmask = managers.slot:get_mask("bullet_impact_targets_no_AI"),
		hit_player = false,
		user_sound_variant = tweak_data.character[self._unit:base()._tweak_table].weapon_voice
	}

	new_unit:base():setup(setup_data)
	CopInventory.add_unit(self, new_unit, equip)
end

function HuskTeamAIInventory:pre_destroy()
	HuskTeamAIInventory.super.pre_destroy(self)
	TeamAIInventory._unload_mask(self)
end

function HuskTeamAIInventory:add_unit(new_unit, equip)
	HuskTeamAIInventory.super.add_unit(self, new_unit, equip)
	self:_ensure_weapon_visibility(new_unit)
end

function HuskTeamAIInventory:equip_selection(selection_index, instant)
	local res = HuskTeamAIInventory.super.equip_selection(self, selection_index, instant)

	self:_ensure_weapon_visibility()

	return res
end
