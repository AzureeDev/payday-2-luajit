PlayerInventory = PlayerInventory or class()
PlayerInventory._all_event_types = {
	"add",
	"equip",
	"unequip"
}
PlayerInventory._NET_EVENTS = {
	feedback_start = 3,
	jammer_start = 1,
	jammer_stop = 2,
	feedback_stop = 4
}

function PlayerInventory:init(unit)
	self._unit = unit
	self._available_selections = {}
	self._equipped_selection = nil
	self._latest_addition = nil
	self._selected_primary = nil
	self._use_data_alias = "player"
	self._align_places = {
		right_hand = {
			on_body = false,
			obj3d_name = Idstring("a_weapon_right")
		},
		left_hand = {
			on_body = false,
			obj3d_name = Idstring("a_weapon_left")
		}
	}
	self._listener_id = "PlayerInventory" .. tostring(unit:key())
	self._listener_holder = EventListenerHolder:new()
	self._mask_unit = nil
	self._melee_weapon_unit = nil
	self._melee_weapon_unit_name = nil
end

function PlayerInventory:pre_destroy(unit)
	if self._weapon_add_clbk then
		if managers.enemy:is_clbk_registered(self._weapon_add_clbk) then
			managers.enemy:remove_delayed_clbk(self._weapon_add_clbk)
		else
			Application:error("[PlayerInventory] Attempted to remove a callback that wasn't registred! " .. tostring(self._weapon_add_clbk))
		end

		self._weapon_add_clbk = nil
	end

	self:destroy_all_items()
	self:stop_jammer_effect()
	self:stop_feedback_effect()
end

function PlayerInventory:destroy_all_items()
	for i_sel, selection_data in pairs(self._available_selections) do
		if selection_data.unit and selection_data.unit:base() then
			selection_data.unit:base():remove_destroy_listener(self._listener_id)
			selection_data.unit:base():set_slot(selection_data.unit, 0)
		else
			debug_pause_unit(self._unit, "[PlayerInventory:destroy_all_items] broken inventory unit", selection_data.unit, selection_data.unit:base())
		end
	end

	self._equipped_selection = nil
	self._available_selections = {}

	if alive(self._mask_unit) then
		for _, linked_unit in ipairs(self._mask_unit:children()) do
			linked_unit:unlink()
			World:delete_unit(linked_unit)
		end

		World:delete_unit(self._mask_unit)

		self._mask_unit = nil
	end

	if self._melee_weapon_unit_name then
		managers.dyn_resource:unload(Idstring("unit"), self._melee_weapon_unit_name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)

		self._melee_weapon_unit_name = nil
	end
end

function PlayerInventory:equipped_selection()
	return self._equipped_selection
end

function PlayerInventory:equipped_unit()
	return self._equipped_selection and self._available_selections[self._equipped_selection].unit
end

function PlayerInventory:unit_by_selection(selection)
	return self._available_selections[selection] and self._available_selections[selection].unit
end

function PlayerInventory:is_selection_available(selection_index)
	return self._available_selections[selection_index] and true or false
end

function PlayerInventory:add_unit(new_unit, is_equip, equip_is_instant)
	local new_selection = {}
	local use_data = new_unit:base():get_use_data(self._use_data_alias)
	new_selection.use_data = use_data
	new_selection.unit = new_unit

	new_unit:base():add_destroy_listener(self._listener_id, callback(self, self, "clbk_weapon_unit_destroyed"))

	local selection_index = use_data.selection_index

	if self._available_selections[selection_index] then
		local old_weapon_unit = self._available_selections[selection_index].unit
		is_equip = is_equip or old_weapon_unit == self:equipped_unit()

		old_weapon_unit:base():remove_destroy_listener(self._listener_id)
		old_weapon_unit:base():set_slot(old_weapon_unit, 0)
		World:delete_unit(old_weapon_unit)

		if self._equipped_selection == selection_index then
			self._equipped_selection = nil
		end
	end

	self._available_selections[selection_index] = new_selection
	self._latest_addition = selection_index
	self._selected_primary = self._selected_primary or selection_index

	self:_call_listeners("add")

	if is_equip then
		self:equip_latest_addition(equip_is_instant)
	else
		self:_place_selection(selection_index, is_equip)
	end
end

function PlayerInventory:clbk_weapon_unit_destroyed(weap_unit)
	local weapon_key = weap_unit:key()

	for i_sel, sel_data in pairs(self._available_selections) do
		if sel_data.unit:key() == weapon_key then
			if i_sel == self._equipped_selection then
				self:_call_listeners("unequip")
			end

			self:remove_selection(i_sel, true)

			break
		end
	end
end

function PlayerInventory:get_latest_addition_hud_data()
	local unit = self._available_selections[self._latest_addition].unit
	local _, _, amount = unit:base():ammo_info()

	return {
		is_equip = self._latest_addition == self._selected_primary,
		amount = amount,
		inventory_index = self._latest_addition,
		unit = unit
	}
end

function PlayerInventory:add_unit_by_name(new_unit_name, equip, instant)
	for _, selection in pairs(self._available_selections) do
		if selection.unit:name() == new_unit_name then
			return
		end
	end

	local new_unit = World:spawn_unit(new_unit_name, Vector3(), Rotation())
	local setup_data = {
		user_unit = self._unit,
		ignore_units = {
			self._unit,
			new_unit
		},
		expend_ammo = true,
		autoaim = true,
		alert_AI = true,
		alert_filter = self._unit:movement():SO_access()
	}

	new_unit:base():setup(setup_data)
	self:add_unit(new_unit, equip, instant)
end

function PlayerInventory:add_unit_by_factory_name(factory_name, equip, instant, blueprint, cosmetics, texture_switches)
	local factory_weapon = tweak_data.weapon.factory[factory_name]
	local ids_unit_name = Idstring(factory_weapon.unit)

	if not managers.dyn_resource:is_resource_ready(Idstring("unit"), ids_unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE) then
		managers.dyn_resource:load(Idstring("unit"), ids_unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE, nil)
	end

	local new_unit = World:spawn_unit(ids_unit_name, Vector3(), Rotation())

	new_unit:base():set_factory_data(factory_name)
	new_unit:base():set_cosmetics_data(cosmetics)
	new_unit:base():set_texture_switches(texture_switches)

	if blueprint then
		new_unit:base():assemble_from_blueprint(factory_name, blueprint)
	else
		new_unit:base():assemble(factory_name)
	end

	local setup_data = {
		user_unit = self._unit,
		ignore_units = {
			self._unit,
			new_unit
		},
		expend_ammo = true,
		autoaim = true,
		alert_AI = true,
		alert_filter = self._unit:movement():SO_access(),
		timer = managers.player:player_timer()
	}

	if blueprint then
		setup_data.panic_suppression_skill = not managers.weapon_factory:has_perk("silencer", factory_name, blueprint) and managers.player:has_category_upgrade("player", "panic_suppression") or false
	end

	new_unit:base():setup(setup_data)
	self:add_unit(new_unit, equip, instant)

	if new_unit:base().AKIMBO then
		new_unit:base():create_second_gun()
	end
end

function PlayerInventory:remove_selection(selection_index, instant)
	selection_index = selection_index or self._equipped_selection
	local weap_unit = self._available_selections[selection_index].unit

	if alive(weap_unit) then
		weap_unit:base():remove_destroy_listener(self._listener_id)
	end

	self._available_selections[selection_index] = nil

	if self._equipped_selection == selection_index then
		self._equipped_selection = nil
	end

	if selection_index == self._selected_primary then
		self._selected_primary = self:_select_new_primary()
	end
end

function PlayerInventory:equip_latest_addition(instant)
	return self:equip_selection(self._latest_addition, instant)
end

function PlayerInventory:equip_selected_primary(instant)
	return self:equip_selection(self._selected_primary, instant)
end

function PlayerInventory:get_next_selection()
	local i = self._selected_primary

	for i = self._selected_primary, self._selected_primary + 9, 1 do
		local selection = 1 + math.mod(i, 10)

		if self._available_selections[selection] then
			return self._available_selections[selection], selection
		end
	end

	return nil
end

function PlayerInventory:equip_next(instant)
	local got, selection = self:get_next_selection()

	if got then
		return self:equip_selection(selection, instant)
	end

	return false
end

function PlayerInventory:get_previous_selection()
	local i = self._selected_primary

	for i = self._selected_primary, self._selected_primary - 9, -1 do
		local selection = 1 + math.mod(8 + i, 10)

		if self._available_selections[selection] then
			return self._available_selections[selection], selection
		end
	end

	return nil
end

function PlayerInventory:equip_previous(instant)
	local got, selection = self:get_previous_selection()

	if got then
		return self:equip_selection(selection, instant)
	end

	return false
end

function PlayerInventory:get_selected(selection_index)
	return selection_index and selection_index ~= self._equipped_selection and self._available_selections[selection_index]
end

function PlayerInventory:equip_selection(selection_index, instant)
	if selection_index and selection_index ~= self._equipped_selection and self._available_selections[selection_index] then
		if self._equipped_selection then
			self:unequip_selection(nil, instant)
		end

		self._equipped_selection = selection_index

		self:_place_selection(selection_index, true)

		self._selected_primary = selection_index

		self:_send_equipped_weapon()
		self:_call_listeners("equip")

		if self._unit:unit_data().mugshot_id then
			local hud_icon_id = self:equipped_unit():base():weapon_tweak_data().hud_icon

			managers.hud:set_mugshot_weapon(self._unit:unit_data().mugshot_id, hud_icon_id, self:equipped_unit():base():weapon_tweak_data().use_data.selection_index)
		end

		self:equipped_unit():base():set_flashlight_enabled(true)
		self:equipped_unit():base():set_scope_enabled(true)

		return true
	end

	return false
end

function PlayerInventory:_send_equipped_weapon()
	local eq_weap_name = self:equipped_unit():base()._factory_id or self:equipped_unit():name()
	local index = self._get_weapon_sync_index(eq_weap_name)

	if not index then
		debug_pause("[PlayerInventory:_send_equipped_weapon] cannot sync weapon", eq_weap_name, self._unit)

		return
	end

	local blueprint_string = self:equipped_unit():base()._blueprint and self:equipped_unit():base().blueprint_to_string and self:equipped_unit():base():blueprint_to_string() or ""
	local cosmetics_string = ""
	local cosmetics_id = self:equipped_unit():base().get_cosmetics_id and self:equipped_unit():base():get_cosmetics_id() or nil

	if cosmetics_id then
		local cosmetics_quality = self:equipped_unit():base().get_cosmetics_quality and self:equipped_unit():base():get_cosmetics_quality() or nil
		local cosmetics_bonus = self:equipped_unit():base().get_cosmetics_bonus and self:equipped_unit():base():get_cosmetics_bonus() or nil
		local entry = tostring(cosmetics_id)
		local quality = tostring(tweak_data.economy:get_index_from_entry("qualities", cosmetics_quality) or 1)
		local bonus = cosmetics_bonus and "1" or "0"
		cosmetics_string = entry .. "-" .. quality .. "-" .. bonus
	else
		cosmetics_string = "nil-1-0"
	end

	self._unit:network():send("set_equipped_weapon", index, blueprint_string, cosmetics_string)
end

function PlayerInventory:unequip_selection(selection_index, instant)
	if not selection_index or selection_index == self._equipped_selection then
		self:_call_listeners("unequip")
		self:equipped_unit():base():set_flashlight_enabled(false)
		self:equipped_unit():base():set_scope_enabled(false)

		selection_index = selection_index or self._equipped_selection

		self:_place_selection(selection_index, false)

		self._equipped_selection = nil
	end
end

function PlayerInventory:is_equipped(index)
	return index == self._equipped_selection
end

function PlayerInventory:available_selections()
	return self._available_selections
end

function PlayerInventory:num_selections()
	return table.size(self._available_selections)
end

function PlayerInventory:_align_place(equip, unit, align_place)
	if equip and self._primary_hand ~= nil then
		return self._primary_hand == 0 and self._align_places.right_hand or self._align_places.left_hand, unit:base().AKIMBO and self._primary_hand == 0 and self._align_places.left_hand or self._align_places.right_hand
	end

	return self._align_places[align_place]
end

function PlayerInventory:_place_selection(selection_index, is_equip)
	local selection = self._available_selections[selection_index]
	local unit = selection.unit
	local weap_align_data = selection.use_data[is_equip and "equip" or "unequip"]
	local align_place = self:_align_place(is_equip, unit, weap_align_data.align_place)

	if align_place then
		if is_equip then
			unit:set_enabled(true)
			unit:base():on_enabled()
		end

		local res = self:_link_weapon(unit, align_place)
	else
		unit:unlink()
		unit:base():set_visibility_state(false)
		unit:set_enabled(false)
		unit:base():on_disabled()

		if unit:base().gadget_on and self._unit:movement().set_cbt_permanent then
			self._unit:movement():set_cbt_permanent(false)
		end
	end
end

function PlayerInventory:_link_weapon(unit, align_place)
	if _G.IS_VR then
		local is_player = managers.player:player_unit() == self._unit

		if is_player then
			return
		end
	end

	local parent_unit = align_place.on_body and self._unit or self._unit:camera()._camera_unit
	local res = parent_unit:link(align_place.obj3d_name, unit, unit:orientation_object():name())

	return res
end

function PlayerInventory:_select_new_primary()
	for index, use_data in pairs(self._available_selections) do
		return index
	end
end

function PlayerInventory:add_listener(key, events, clbk)
	events = events or self._all_event_types

	self._listener_holder:add(key, events, clbk)
end

function PlayerInventory:remove_listener(key)
	self._listener_holder:remove(key)
end

function PlayerInventory:_call_listeners(event)
	self._listener_holder:call(event, self._unit, event)
end

function PlayerInventory:on_death_exit()
	for i, selection in pairs(self._available_selections) do
		selection.unit:unlink()
	end

	self:_stop_feedback_effect()
	self:_stop_jammer_effect()
end

function PlayerInventory._chk_create_w_factory_indexes()
	if PlayerInventory._weapon_factory_indexed then
		return
	end

	local weapon_factory_indexed = {}
	PlayerInventory._weapon_factory_indexed = weapon_factory_indexed

	for id, data in pairs(tweak_data.weapon.factory) do
		if id ~= "parts" and data.unit then
			table.insert(weapon_factory_indexed, id)
		end
	end

	table.sort(weapon_factory_indexed, function (a, b)
		return a < b
	end)
end

function PlayerInventory._get_weapon_sync_index(wanted_weap_name)
	if type_name(wanted_weap_name) == "Idstring" then
		for i, test_weap_name in ipairs(tweak_data.character.weap_unit_names) do
			if test_weap_name == wanted_weap_name then
				return i
			end
		end
	end

	PlayerInventory._chk_create_w_factory_indexes()

	local start_index = #tweak_data.character.weap_unit_names

	for i, factory_id in ipairs(PlayerInventory._weapon_factory_indexed) do
		if wanted_weap_name == factory_id then
			return start_index + i
		end
	end
end

function PlayerInventory._get_weapon_name_from_sync_index(w_index)
	if w_index <= #tweak_data.character.weap_unit_names then
		return tweak_data.character.weap_unit_names[w_index]
	end

	w_index = w_index - #tweak_data.character.weap_unit_names

	PlayerInventory._chk_create_w_factory_indexes()

	return PlayerInventory._weapon_factory_indexed[w_index]
end

function PlayerInventory:hide_equipped_unit()
	local unit = self._equipped_selection and self._available_selections[self._equipped_selection].unit

	if unit and unit:base():enabled() then
		self._was_gadget_on = unit:base().is_gadget_on and unit:base()._gadget_on or false

		unit:set_visible(false)
		unit:base():on_disabled()
	end
end

function PlayerInventory:show_equipped_unit()
	if self._equipped_selection and self._available_selections[self._equipped_selection].unit then
		self._available_selections[self._equipped_selection].unit:set_visible(true)
		self._available_selections[self._equipped_selection].unit:base():on_enabled()

		if self._was_gadget_on then
			self._available_selections[self._equipped_selection].unit:base():set_gadget_on(self._was_gadget_on)

			self._was_gadget_on = nil
		end
	end
end

function PlayerInventory:save(data)
	if self._equipped_selection then
		local eq_weap_name = self:equipped_unit():base()._factory_id or self:equipped_unit():name()
		local index = self._get_weapon_sync_index(eq_weap_name)
		data.equipped_weapon_index = index
		data.mask_visibility = self._mask_visibility
		data.blueprint_string = self:equipped_unit():base().blueprint_to_string and self:equipped_unit():base():blueprint_to_string() or nil
		data.gadget_on = self:equipped_unit():base().gadget_on and self:equipped_unit():base()._gadget_on
		local gadget = self:equipped_unit():base().get_active_gadget and self:equipped_unit():base():get_active_gadget()

		if gadget and gadget.color then
			data.gadget_color = gadget:color()
		end

		local cosmetics_string = ""
		local cosmetics_id = self:equipped_unit():base().get_cosmetics_id and self:equipped_unit():base():get_cosmetics_id() or nil

		if cosmetics_id then
			local cosmetics_quality = self:equipped_unit():base().get_cosmetics_quality and self:equipped_unit():base():get_cosmetics_quality() or nil
			local cosmetics_bonus = self:equipped_unit():base().get_cosmetics_bonus and self:equipped_unit():base():get_cosmetics_bonus() or nil
			local entry = tostring(cosmetics_id)
			local quality = tostring(tweak_data.economy:get_index_from_entry("qualities", cosmetics_quality) or 1)
			local bonus = cosmetics_bonus and "1" or "0"
			cosmetics_string = entry .. "-" .. quality .. "-" .. bonus
		else
			cosmetics_string = "nil-1-0"
		end

		data.cosmetics_string = cosmetics_string
	end

	local function to_time_left(t)
		return t and t - TimerManager:game():time()
	end

	local function copy_some(t, ...)
		if not t then
			return
		end

		local rtn = {}

		for _, k in ipairs({
			...
		}) do
			if k[1] then
				local key, func = unpack(k)
				rtn[key] = func(t[key])
			else
				rtn[k] = t[k]
			end
		end

		return rtn
	end

	data._jammer_data = copy_some(self._jammer_data, {
		"t",
		to_time_left
	}, "effect", "interval", "range")
end

function PlayerInventory:cosmetics_string_from_peer(peer, weapon_name)
	if peer then
		local outfit = peer:blackmarket_outfit()
		local cosmetics = outfit.primary.factory_id .. "_npc" == weapon_name and outfit.primary.cosmetics or outfit.secondary.factory_id .. "_npc" == weapon_name and outfit.secondary.cosmetics

		if cosmetics then
			local quality = tostring(tweak_data.economy:get_index_from_entry("qualities", cosmetics.quality) or 1)

			return cosmetics.id .. "-" .. quality .. "-" .. (cosmetics.bonus and "1" or "0")
		else
			return "nil-1-0"
		end
	end
end

function PlayerInventory:load(data)
	if data.equipped_weapon_index then
		self._weapon_add_clbk = "playerinventory_load" .. tostring(self._unit:key())
		local delayed_data = {
			equipped_weapon_index = data.equipped_weapon_index,
			blueprint_string = data.blueprint_string,
			cosmetics_string = data.cosmetics_string,
			gadget_on = data.gadget_on,
			gadget_color = data.gadget_color
		}

		managers.enemy:add_delayed_clbk(self._weapon_add_clbk, callback(self, self, "_clbk_weapon_add", delayed_data), Application:time() + 1)
	end

	self._mask_visibility = data.mask_visibility and true or false

	if data._jammer_data and data._jammer_data.effect == "feedback" then
		self:start_feedback_effect(data._jammer_data.t + TimerManager:game():time(), data._jammer_data.interval, data._jammer_data.range)
	end

	if data._jammer_data and data._jammer_data.effect == "jamming" then
		self:start_jammer_effect(data._jammer_data.t + TimerManager:game():time())
	end
end

function PlayerInventory:_clbk_weapon_add(data)
	self._weapon_add_clbk = nil

	if not alive(self._unit) then
		return
	end

	local eq_weap_name = self._get_weapon_name_from_sync_index(data.equipped_weapon_index)

	if type(eq_weap_name) == "string" then
		if not managers.network:session() then
			return
		end

		self:add_unit_by_factory_name(eq_weap_name, true, true, data.blueprint_string, self:cosmetics_string_from_peer(managers.network:session():peer_by_unit(self._unit), eq_weap_name) or data.cosmetics_string)
		self:synch_weapon_gadget_state(data.gadget_on)

		if data.gadget_color then
			self:sync_weapon_gadget_color(data.gadget_color)
		end
	else
		self._unit:inventory():add_unit_by_name(eq_weap_name, true, true)
	end

	self:on_weapon_add()

	if self._unit:unit_data().mugshot_id then
		local icon = self:equipped_unit():base():weapon_tweak_data().hud_icon

		managers.hud:set_mugshot_weapon(self._unit:unit_data().mugshot_id, icon, self:equipped_unit():base():weapon_tweak_data().use_data.selection_index)
	end
end

function PlayerInventory:on_weapon_add()
end

function PlayerInventory:mask_visibility()
	return self._mask_visibility or false
end

function PlayerInventory:set_mask_visibility(state)
	self._mask_visibility = state

	if self._unit == managers.player:player_unit() then
		return
	end

	local character_name = managers.criminals:character_name_by_unit(self._unit)

	if not character_name then
		return
	end

	self._mask_visibility = state

	if alive(self._mask_unit) then
		if not state then
			for _, linked_unit in ipairs(self._mask_unit:children()) do
				linked_unit:unlink()
				World:delete_unit(linked_unit)
			end

			self._mask_unit:unlink()

			local name = self._mask_unit:name()

			World:delete_unit(self._mask_unit)
		end

		return
	end

	if not state then
		return
	end

	local mask_unit_name = managers.criminals:character_data_by_name(character_name).mask_obj

	if not managers.dyn_resource:is_resource_ready(Idstring("unit"), mask_unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE) then
		return
	end

	mask_unit_name = mask_unit_name[Global.level_data.level_id] or mask_unit_name.default or mask_unit_name
	local mask_align = self._unit:get_object(Idstring("Head"))
	local mask_unit = World:spawn_unit(Idstring(mask_unit_name), mask_align:position(), mask_align:rotation())

	mask_unit:base():apply_blueprint(managers.criminals:character_data_by_name(character_name).mask_blueprint)
	self._unit:link(mask_align:name(), mask_unit)

	self._mask_unit = mask_unit
	local mask_id = managers.criminals:character_data_by_name(character_name).mask_id
	local peer = managers.network:session():peer_by_unit(self._unit)
	local mask_data = {
		mask_id = mask_id,
		mask_unit = mask_unit,
		mask_align = mask_align,
		peer_id = peer and peer:id(),
		character_name = character_name
	}

	self:update_mask_offset(mask_data)

	if not mask_id or not tweak_data.blackmarket.masks[mask_id].type then
		local backside = World:spawn_unit(Idstring("units/payday2/masks/msk_backside/msk_backside"), mask_align:position(), mask_align:rotation())

		self._mask_unit:link(self._mask_unit:orientation_object():name(), backside, backside:orientation_object():name())
	end

	if not mask_id or not tweak_data.blackmarket.masks[mask_id].skip_mask_on_sequence then
		local mask_on_sequence = managers.blackmarket:character_mask_on_sequence_by_character_name(character_name)

		if mask_on_sequence then
			self._unit:damage():run_sequence_simple(mask_on_sequence)
		end
	end
end

function PlayerInventory:update_mask_offset(mask_data)
	local char = nil

	if mask_data.peer_id then
		char = managers.blackmarket:get_real_character(nil, mask_data.peer_id)
	else
		char = managers.blackmarket:get_real_character(mask_data.character_name, nil)
	end

	local mask_tweak = tweak_data.blackmarket.masks[mask_data.mask_id]

	if mask_tweak and mask_tweak.offsets and mask_tweak.offsets[char] then
		local char_tweak = mask_tweak.offsets[char]

		self:set_mask_offset(mask_data.mask_unit, mask_data.mask_align, char_tweak[1] or Vector3(0, 0, 0), char_tweak[2] or Rotation(0, 0, 0))
		self:set_mask_offset(mask_data.mask_unit, mask_data.mask_align, char_tweak[1] or Vector3(0, 0, 0), char_tweak[2] or Rotation(0, 0, 0))
	else
		self:set_mask_offset(mask_data.mask_unit, mask_data.mask_align, Vector3(0, 0, 0), Rotation(0, 0, 0))
	end
end

function PlayerInventory:set_mask_offset(mask_unit, mask_align, position, rotation)
	if not alive(mask_unit) then
		return
	end

	if rotation then
		mask_unit:set_rotation(mask_align:rotation() * rotation)
	end

	if position then
		mask_unit:set_position(mask_align:position() + mask_unit:rotation():x() * position.x + mask_unit:rotation():z() * position.z + mask_unit:rotation():y() * position.y)
	end
end

function PlayerInventory:set_melee_weapon(melee_weapon_id, is_npc)
	self._melee_weapon_data = managers.blackmarket:get_melee_weapon_data(melee_weapon_id)

	if is_npc then
		if self._melee_weapon_data.third_unit then
			self._melee_weapon_unit_name = Idstring(self._melee_weapon_data.third_unit)
		end
	elseif self._melee_weapon_data.unit then
		self._melee_weapon_unit_name = Idstring(self._melee_weapon_data.unit)
	end

	if self._melee_weapon_unit_name then
		managers.dyn_resource:load(Idstring("unit"), self._melee_weapon_unit_name, "packages/dyn_resources", false)
	end
end

function PlayerInventory:set_melee_weapon_by_peer(peer)
end

function PlayerInventory:set_ammo(ammo)
	for id, weapon in pairs(self._available_selections) do
		weapon.unit:base():set_ammo(ammo)
		managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
	end
end

function PlayerInventory:need_ammo()
	for _, weapon in pairs(self._available_selections) do
		if not weapon.unit:base():ammo_full() then
			return true
		end
	end

	return false
end

function PlayerInventory:all_out_of_ammo()
	for _, weapon in pairs(self._available_selections) do
		if not weapon.unit:base():out_of_ammo() then
			return false
		end
	end

	return true
end

function PlayerInventory:anim_cbk_spawn_character_mask(unit)
	self:set_mask_visibility(true)
end

function PlayerInventory:anim_clbk_equip_exit(unit)
	self:set_mask_visibility(true)
end

function PlayerInventory:set_visibility_state(state)
	for i, sel_data in pairs(self._available_selections) do
		local enabled = sel_data.unit:enabled()

		sel_data.unit:base():set_visibility_state(enabled and state)
	end

	if alive(self._shield_unit) then
		self._shield_unit:set_visible(state)
	end
end

function PlayerInventory:set_weapon_enabled(state)
	if self._equipped_selection then
		self:equipped_unit():set_enabled(state)
	end

	if alive(self._shield_unit) then
		self._shield_unit:set_enabled(state)
	end
end

function PlayerInventory:sync_net_event(event_id, peer)
	local net_events = self._NET_EVENTS

	if event_id == net_events.jammer_start then
		self:_start_jammer_effect()
	elseif event_id == net_events.jammer_stop then
		self:_stop_jammer_effect()
	elseif event_id == net_events.feedback_start then
		if Network:is_server() then
			self:start_feedback_effect()
		else
			self:_start_feedback_effect()
		end
	elseif event_id == net_events.feedback_stop then
		self:_stop_feedback_effect()
	end
end

function PlayerInventory:get_jammer_time()
	return self._unit:base():upgrade_value("player", "pocket_ecm_jammer_base").duration
end

function PlayerInventory:_send_net_event(event_id)
	managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "inventory", event_id)
end

function PlayerInventory:_send_net_event_to_host(event_id)
	managers.network:session():send_to_host("sync_unit_event_id_16", self._unit, "inventory", event_id)
end

function PlayerInventory:is_jammer_active()
	return self._jammer_data and self._jammer_data.effect
end

function PlayerInventory:start_jammer_effect(...)
	self:_start_jammer_effect(...)
	self:_send_net_event(self._NET_EVENTS.jammer_start)
end

function PlayerInventory:_start_jammer_effect(end_time)
	end_time = end_time or self:get_jammer_time() + TimerManager:game():time()
	self._jammer_data = {
		effect = "jamming",
		t = end_time,
		sound = self._unit:sound_source():post_event("ecm_jammer_jam_signal"),
		stop_jamming_callback_key = "jammer" .. tostring(self._unit:key())
	}

	managers.groupai:state():register_ecm_jammer(self._unit, {
		pager = true,
		call = true,
		camera = true
	})
	managers.enemy:add_delayed_clbk(self._jammer_data.stop_jamming_callback_key, callback(self, self, "stop_jammer_effect"), self._jammer_data.t)

	local is_player = managers.player:player_unit() == self._unit
	local dodge = is_player and self._unit:base():upgrade_value("temporary", "pocket_ecm_kill_dodge")

	if dodge then
		self._jammer_data.dodge_kills = dodge[3]
		self._jammer_data.dodge_listener_key = "jamming_dodge" .. tostring(self._unit:key())

		managers.player:register_message(Message.OnEnemyKilled, self._jammer_data.dodge_listener_key, callback(self, self, "_jamming_kill_dodge"))
	end
end

function PlayerInventory:stop_jammer_effect()
	self:_stop_jammer_effect()

	if managers.network:session() then
		self:_send_net_event(self._NET_EVENTS.jammer_stop)
	end
end

function PlayerInventory:_stop_jammer_effect()
	if not self._jammer_data or self._jammer_data.effect ~= "jamming" then
		return
	end

	local _ = self._jammer_data.sound and self._jammer_data.sound:stop()
	self._jammer_data.effect = nil

	self._unit:sound_source():post_event("ecm_jammer_jam_signal_stop")
	managers.groupai:state():register_ecm_jammer(self._unit, false)
	managers.enemy:remove_delayed_clbk(self._jammer_data.stop_jamming_callback_key, true)

	if self._jammer_data.dodge_listener_key then
		managers.player:unregister_message(Message.OnEnemyKilled, self._jammer_data.dodge_listener_key, true)
	end
end

function PlayerInventory:start_feedback_effect(...)
	if Network:is_server() then
		self:_start_feedback_effect(...)
		self:_send_net_event(self._NET_EVENTS.feedback_start)
	else
		self:_send_net_event_to_host(self._NET_EVENTS.feedback_start)
	end
end

function PlayerInventory:_start_feedback_effect(end_time, interval, range)
	end_time = end_time or self:get_jammer_time() + TimerManager:game():time()
	self._jammer_data = {
		effect = "feedback",
		t = end_time,
		interval = interval or 1.5,
		range = range or 2500,
		sound = self._unit:sound_source():post_event("ecm_jammer_puke_signal")
	}
	local is_player = managers.player:player_unit() == self._unit
	local dodge = is_player and self._unit:base():upgrade_value("temporary", "pocket_ecm_kill_dodge")
	local heal = is_player and self._unit:base():upgrade_value("player", "pocket_ecm_heal_on_kill") or self._unit:base():upgrade_value("team", "pocket_ecm_heal_on_kill")

	if heal then
		self._jammer_data.heal = heal
		self._jammer_data.heal_listener_key = "feedback_heal" .. tostring(self._unit:key())

		managers.player:register_message(Message.OnEnemyKilled, self._jammer_data.heal_listener_key, callback(self, self, "_feedback_heal_on_kill"))
	end

	if dodge then
		self._jammer_data.dodge_kills = dodge[3]
		self._jammer_data.dodge_listener_key = "jamming_dodge" .. tostring(self._unit:key())

		managers.player:register_message(Message.OnEnemyKilled, self._jammer_data.dodge_listener_key, callback(self, self, "_jamming_kill_dodge"))
	end

	if Network:is_server() then
		self._jammer_data.feedback_callback_key = "feedback" .. tostring(self._unit:key())

		managers.enemy:add_delayed_clbk(self._jammer_data.feedback_callback_key, callback(self, self, "_do_feedback"), TimerManager:game():time() + self._jammer_data.interval)
	end
end

function PlayerInventory:stop_feedback_effect()
	self:_stop_feedback_effect()

	if Network:is_server() and managers.network:session() then
		self:_send_net_event(self._NET_EVENTS.feedback_stop)
	end
end

function PlayerInventory:_stop_feedback_effect()
	if not self._jammer_data or self._jammer_data.effect ~= "feedback" then
		return
	end

	local _ = self._jammer_data.sound and self._jammer_data.sound:stop()
	self._jammer_data.effect = nil

	self._unit:sound_source():post_event("ecm_jammer_puke_signal_stop")

	if self._jammer_data.heal_listener_key then
		managers.player:unregister_message(Message.OnEnemyKilled, self._jammer_data.heal_listener_key, true)
	end

	if self._jammer_data.dodge_listener_key then
		managers.player:unregister_message(Message.OnEnemyKilled, self._jammer_data.dodge_listener_key, true)
	end

	if Network:is_server() then
		managers.enemy:remove_delayed_clbk(self._jammer_data.feedback_callback_key, true)
	end
end

function PlayerInventory:_feedback_heal_on_kill()
	local unit = managers.player:player_unit()
	local is_downed = game_state_machine:verify_game_state(GameStateFilters.downed)
	local swan_song_active = managers.player:has_activate_temporary_upgrade("temporary", "berserker_damage_multiplier")

	if is_downed or swan_song_active then
		return
	end

	if alive(self._unit) and unit and self._jammer_data then
		unit:character_damage():change_health(self._jammer_data.heal)
	end
end

function PlayerInventory:_jamming_kill_dodge()
	local unit = managers.player:player_unit()
	local data = self._jammer_data

	if not alive(self._unit) or not unit or not data then
		return
	end

	if data.dodge_kills then
		data.dodge_kills = data.dodge_kills - 1

		if data.dodge_kills == 0 then
			managers.player:activate_temporary_upgrade("temporary", "pocket_ecm_kill_dodge")
			managers.player:unregister_message(Message.OnEnemyKilled, self._jammer_data.dodge_listener_key, true)
		end
	end
end

function PlayerInventory:_do_feedback()
	local t = TimerManager:game():time()

	if not alive(self._unit) or not self._jammer_data or t > self._jammer_data.t - 0.1 then
		self:stop_feedback_effect()

		return
	end

	ECMJammerBase._detect_and_give_dmg(self._unit:position(), nil, self._unit, 2500)

	if self._jammer_data.t - 0.1 < t + self._jammer_data.interval then
		managers.enemy:add_delayed_clbk(self._jammer_data.feedback_callback_key, t + self._feedback_interval)
	else
		managers.enemy:add_delayed_clbk(self._jammer_data.feedback_callback_key, callback(self, self, "stop_feedback_effect"), self._jammer_data.t)
	end
end
