CopInventory = CopInventory or class(PlayerInventory)

function CopInventory:init(unit)
	CopInventory.super.init(self, unit)

	self._unit = unit
	self._available_selections = {}
	self._equipped_selection = nil
	self._latest_addition = nil
	self._selected_primary = nil
	self._use_data_alias = "npc"
	self._align_places = {
		right_hand = {
			on_body = true,
			obj3d_name = Idstring("a_weapon_right_front")
		},
		back = {
			on_body = true,
			obj3d_name = Idstring("Hips")
		}
	}
	self._listener_id = "CopInventory" .. tostring(unit:key())
end

function CopInventory:add_unit_by_name(new_unit_name, equip)
	local new_unit = World:spawn_unit(new_unit_name, Vector3(), Rotation())

	managers.mutators:modify_value("CopInventory:add_unit_by_name", self)
	self:_chk_spawn_shield(new_unit)

	local setup_data = {
		user_unit = self._unit,
		ignore_units = {
			self._unit,
			new_unit,
			self._shield_unit
		},
		expend_ammo = false,
		hit_slotmask = managers.slot:get_mask("bullet_impact_targets"),
		hit_player = true,
		user_sound_variant = tweak_data.character[self._unit:base()._tweak_table].weapon_voice,
		alert_AI = true,
		alert_filter = self._unit:brain():SO_access()
	}

	new_unit:base():setup(setup_data)

	if new_unit:base().AKIMBO then
		new_unit:base():create_second_gun(new_unit_name)
	end

	self:add_unit(new_unit, equip)
end

function CopInventory:_chk_spawn_shield(weapon_unit)
	if self._shield_unit_name and not alive(self._shield_unit) then
		local align_name = self._shield_align_name or Idstring("a_weapon_left_front")
		local align_obj = self._unit:get_object(align_name)
		self._shield_unit = World:spawn_unit(Idstring(self._shield_unit_name), align_obj:position(), align_obj:rotation())

		self._unit:link(align_name, self._shield_unit, self._shield_unit:orientation_object():name())
		self._shield_unit:set_enabled(false)
	end
end

function CopInventory:add_unit(new_unit, equip)
	CopInventory.super.add_unit(self, new_unit, equip)
	new_unit:set_enabled(true)
	new_unit:set_visible(true)
end

function CopInventory:get_sync_data(sync_data)
	MPPlayerInventory.get_sync_data(self, sync_data)
end

function CopInventory:get_weapon()
	local selection = self._available_selections[self._equipped_selection]
	local unit = selection and selection.unit

	return unit
end

function CopInventory:drop_weapon()
	local selection = self._available_selections[self._equipped_selection]
	local unit = selection and selection.unit

	if unit and unit:damage() then
		unit:unlink()
		unit:damage():run_sequence_simple("enable_body")
		self:_call_listeners("unequip")
		managers.game_play_central:weapon_dropped(unit)

		if unit:base() and unit:base()._second_gun then
			local second_gun = unit:base()._second_gun

			second_gun:unlink()

			if second_gun:damage() then
				second_gun:damage():run_sequence_simple("enable_body")
				managers.game_play_central:weapon_dropped(second_gun)
			end
		end
	end
end

function CopInventory:drop_shield()
	if alive(self._shield_unit) then
		self._shield_unit:unlink()

		if self._shield_unit:damage() then
			self._shield_unit:damage():run_sequence_simple("enable_body")
			managers.enemy:register_shield(self._shield_unit)
		end
	end
end

function CopInventory:anim_clbk_weapon_attached(unit, state)
	print("[CopInventory:anim_clbk_weapon_attached]", state)

	if location == true then
		print("linking")

		local weap_unit = self._equipped_selection.unit
		local weap_align_data = selection.use_data.equip
		local align_place = self._align_places[weap_align_data.align_place]
		local parent_unit = self._unit
		slot7 = parent_unit:link(align_place.obj3d_name, weap_unit, weap_unit:orientation_object():name())
	else
		print("unlinking")
		self._equipped_selection.unit:unlink()
	end
end

function CopInventory:destroy_all_items()
	CopInventory.super.destroy_all_items(self)

	if alive(self._shield_unit) then
		managers.enemy:unregister_shield(self._shield_unit)
		self._shield_unit:set_slot(0)

		self._shield_unit = nil
	end
end
