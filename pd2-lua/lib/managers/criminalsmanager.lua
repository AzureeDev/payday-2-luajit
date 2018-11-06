CriminalsManager = CriminalsManager or class()
CriminalsManager.MAX_NR_TEAM_AI = 3
CriminalsManager.MAX_NR_CRIMINALS = 4
CriminalsManager.EVENTS = {
	"on_criminal_added",
	"on_criminal_removed"
}

function CriminalsManager:init()
	self._listener_holder = EventListenerHolder:new()

	self:_create_characters()

	self._loadout_map = {}
	self._loadout_slots = {}

	for i = 1, CriminalsManager.MAX_NR_TEAM_AI, 1 do
		self._loadout_slots[i] = {}
	end
end

function CriminalsManager:_create_characters()
	self._characters = {}

	for _, character in ipairs(tweak_data.criminals.characters) do
		local static_data = deep_clone(character.static_data)
		local character_data = {
			peer_id = 0,
			taken = false,
			name = character.name,
			static_data = static_data,
			data = {}
		}

		table.insert(self._characters, character_data)
	end
end

function CriminalsManager:event_listener()
	self._listener_holder = self._listener_holder or EventListenerHolder:new()

	return self._listener_holder
end

function CriminalsManager:add_listener(key, events, clbk)
	self:event_listener():add(key, events, clbk)
end

function CriminalsManager:remove_listener(key)
	self:event_listener():remove(key)
end

function CriminalsManager.convert_old_to_new_character_workname(workname)
	local t = {
		spanish = "chains",
		russian = "dallas",
		german = "wolf",
		american = "hoxton"
	}

	return t[workname] or workname
end

function CriminalsManager.convert_new_to_old_character_workname(workname)
	local t = {
		hoxton = "american",
		wolf = "german",
		dallas = "russian",
		chains = "spanish"
	}

	return t[workname] or workname
end

function CriminalsManager.character_names()
	return tweak_data.criminals.character_names
end

function CriminalsManager.get_num_characters()
	return #tweak_data.criminals.character_names
end

function CriminalsManager.character_workname_by_peer_id(peer_id)
	return CriminalsManager.character_names()[peer_id]
end

function CriminalsManager:on_simulation_ended()
	for id, data in pairs(self._characters) do
		self:_remove(id)
	end

	self._listener_holder = EventListenerHolder:new()
end

function CriminalsManager:local_character_name()
	return self._local_character
end

function CriminalsManager:characters()
	return self._characters
end

function CriminalsManager:get_any_unit()
	for id, data in pairs(self._characters) do
		if data.taken and alive(data.unit) and data.unit:id() ~= -1 then
			return data.unit
		end
	end
end

function CriminalsManager:get_valid_player_spawn_pos_rot(peer_id)
	local server_unit = managers.network:session():local_peer():unit()

	if alive(server_unit) then
		return self:_get_unit_pos_rot(server_unit, true)
	end

	for u_key, u_data in pairs(managers.groupai:state():all_player_criminals()) do
		if u_data and alive(u_data.unit) then
			return self:_get_unit_pos_rot(u_data.unit, true)
		end
	end

	if self._last_valid_player_spawn_pos_rot then
		return self._last_valid_player_spawn_pos_rot
	end

	for u_key, u_data in pairs(managers.groupai:state():all_AI_criminals()) do
		if u_data and alive(u_data.unit) then
			return self:_get_unit_pos_rot(u_data.unit, false)
		end
	end

	return nil
end

function CriminalsManager:_get_unit_pos_rot(unit, check_zipline)
	if check_zipline then
		local zipline_unit = unit:movement():zipline_unit()

		if zipline_unit then
			unit = zipline_unit
		end
	end

	if unit:movement() then
		local state = unit:movement():current_state_name()

		if state == "jerry1" or state == "jerry2" then
			return nil
		end
	end

	if unit:in_slot(managers.slot:get_mask("players")) and not unit:base().is_husk_player then
		local rot = unit:camera():rotation()

		return {
			unit:position(),
			Rotation(rot:yaw())
		}
	else
		return {
			unit:position(),
			Rotation(unit:rotation():yaw())
		}
	end
end

function CriminalsManager:on_last_valid_player_spawn_point_updated(unit)
	self._last_valid_player_spawn_pos_rot = self:_get_unit_pos_rot(unit, true)
end

function CriminalsManager:_remove(id)
	local data = self._characters[id]

	if data.name == self._local_character then
		self._local_character = nil
	end

	if data.unit then
		managers.hud:remove_mugshot_by_character_name(data.name)

		if not data.ai and alive(data.unit) then
			self:on_last_valid_player_spawn_point_updated(data.unit)
		end
	else
		managers.hud:remove_teammate_panel_by_name_id(data.name)
	end

	if not data.ai then
		managers.trade:on_player_criminal_removed(data.name)
	end

	data.taken = false
	data.unit = nil
	data.peer_id = 0
	data.data = {}

	self:event_listener():call("on_criminal_removed", data)

	if Network:is_server() then
		call_on_next_update(callback(self, self, "_reassign_loadouts"), "CriminalsManager:_reassign_loadouts")
	end
end

function CriminalsManager:add_character(name, unit, peer_id, ai, ai_loadout)
	print("[CriminalsManager]:add_character", name, unit, peer_id, ai)

	for id, data in pairs(self._characters) do
		if data.name == name then
			if data.taken then
				Application:error("[CriminalsManager:set_character] Error: Trying to take a unit slot that has already been taken!")
				Application:stack_dump()
				Application:error("[CriminalsManager:set_character] -----")
				self:_remove(id)
			end

			data.taken = true
			data.unit = unit
			data.peer_id = peer_id
			data.data.ai = ai or false

			if ai_loadout then
				unit:base():set_loadout(ai_loadout)
			end

			data.data.mask_id = managers.blackmarket:get_real_mask_id(ai_loadout and ai_loadout.mask or data.static_data.ai_mask_id, nil, name)

			if Network:is_server() and ai_loadout then
				local crafted = managers.blackmarket:get_crafted_category_slot("masks", ai_loadout and ai_loadout.mask_slot)
				data.data.mask_blueprint = crafted and crafted.blueprint
			end

			data.data.mask_blueprint = data.data.mask_blueprint or ai_loadout and ai_loadout.mask_blueprint
			data.data.mask_obj = managers.blackmarket:mask_unit_name_by_mask_id(data.data.mask_id, nil, name)

			if not ai and unit then
				local mask_id = managers.network:session():peer(peer_id):mask_id()
				data.data.mask_obj = managers.blackmarket:mask_unit_name_by_mask_id(mask_id, peer_id)
				data.data.mask_id = managers.blackmarket:get_real_mask_id(mask_id, peer_id)
				data.data.mask_blueprint = managers.network:session():peer(peer_id):mask_blueprint()
			end

			managers.hud:remove_mugshot_by_character_name(name)

			if unit then
				data.data.mugshot_id = managers.hud:add_mugshot_by_unit(unit)

				if unit:base().is_local_player then
					self._local_character = name

					managers.hud:reset_player_hpbar()
				end

				unit:sound():set_voice(data.static_data.voice)

				break
			end

			data.data.mugshot_id = managers.hud:add_mugshot_without_unit(name, ai, peer_id, ai and managers.localization:text("menu_" .. name) or managers.network:session():peer(peer_id):name())

			break
		end
	end

	self:event_listener():call("on_criminal_added", name, unit, peer_id, ai)
	managers.sync:send_all_synced_units_to(peer_id)

	local sequence = self:active_player_sequence()

	if sequence and alive(unit) then
		local unit_damage = unit:damage() or unit:camera() and unit:camera():camera_unit():damage()

		if _G.IS_VR and unit:camera() then
			unit_damage = nil
		end

		if unit_damage then
			unit_damage:run_sequence_simple(sequence)
		end
	end
end

function CriminalsManager:set_active_player_sequence(sequence)
	if sequence and self._player_sequence ~= sequence then
		for _, char in ipairs(self:characters()) do
			if alive(char.unit) then
				local unit_damage = char.unit:damage() or char.unit:camera() and char.unit:camera():camera_unit():damage()

				if _G.IS_VR and char.unit:camera() then
					unit_damage = nil
				end

				if unit_damage then
					unit_damage:run_sequence_simple(sequence)
				end
			end
		end
	end

	self._player_sequence = sequence
end

function CriminalsManager:active_player_sequence()
	if self._player_sequence then
		return self._player_sequence
	end

	local current_level = managers.job and managers.job:current_level_id()

	if current_level then
		return tweak_data.levels[current_level] and tweak_data.levels[current_level].player_sequence
	end
end

function CriminalsManager:set_unit(name, unit, ai_loadout)
	print("[CriminalsManager]:set_unit", name, unit)
	Application:stack_dump()

	for id, data in pairs(self._characters) do
		if data.name == name then
			if not data.taken then
				Application:error("[CriminalsManager:set_character] Error: Trying to set a unit on a slot that has not been taken!")
				Application:stack_dump()

				return
			end

			data.unit = unit

			managers.hud:remove_mugshot_by_character_name(data.name)

			data.data.mugshot_id = managers.hud:add_mugshot_by_unit(unit)
			data.data.mask_id = managers.blackmarket:get_real_mask_id(ai_loadout and ai_loadout.mask or data.static_data.ai_mask_id, nil, name)

			if Network:is_server() and ai_loadout then
				local crafted = managers.blackmarket:get_crafted_category_slot("masks", ai_loadout and ai_loadout.mask_slot)
				data.data.mask_blueprint = crafted and crafted.blueprint
			end

			data.data.mask_blueprint = data.data.mask_blueprint or ai_loadout and ai_loadout.mask_blueprint
			data.data.mask_obj = managers.blackmarket:mask_unit_name_by_mask_id(data.data.mask_id, nil, name)

			if not data.data.ai then
				local peer = managers.network:session():peer(data.peer_id)
				local mask_id = peer:mask_id()
				data.data.mask_obj = managers.blackmarket:mask_unit_name_by_mask_id(mask_id, data.peer_id)
				data.data.mask_id = managers.blackmarket:get_real_mask_id(mask_id, data.peer_id)
				data.data.mask_blueprint = peer:mask_blueprint()

				if unit:armor_skin() then
					local outfit = managers.blackmarket:unpack_outfit_from_string(peer:profile().outfit_string)

					if outfit.armor_skin then
						unit:armor_skin():set_cosmetics_data(tweak_data.economy:get_armor_skin_id(outfit.armor_skin), true)
					end
				end
			end

			if unit:base().is_local_player then
				self._local_character = name

				managers.hud:reset_player_hpbar()
			end

			unit:sound():set_voice(data.static_data.voice)

			break
		end
	end

	if ai_loadout then
		local vis = unit:inventory()._mask_visibility

		unit:base():set_loadout(ai_loadout)
		unit:inventory():preload_mask()
		unit:inventory():set_mask_visibility(not vis)
		unit:inventory():set_mask_visibility(vis)

		if Network:is_server() then
			unit:movement():add_weapons()
		end
	end
end

function CriminalsManager:set_data(name)
	print("[CriminalsManager]:set_data", name)

	for id, data in pairs(self._characters) do
		if data.name == name then
			if not data.taken then
				return
			end

			if not data.data.ai then
				local mask_id = managers.network:session():peer(data.peer_id):mask_id()
				data.data.mask_obj = managers.blackmarket:mask_unit_name_by_mask_id(mask_id, data.peer_id)
				data.data.mask_id = managers.blackmarket:get_real_mask_id(mask_id, data.peer_id)
				data.data.mask_blueprint = managers.network:session():peer(data.peer_id):mask_blueprint()
			end

			break
		end
	end
end

function CriminalsManager:is_taken(name)
	for _, data in pairs(self._characters) do
		if name == data.name then
			return data.taken
		end
	end

	return false
end

function CriminalsManager:character_name_by_peer_id(peer_id)
	for _, data in pairs(self._characters) do
		if data.taken and peer_id == data.peer_id then
			return data.name
		end
	end
end

function CriminalsManager:character_color_id_by_peer_id(peer_id)
	local workname = self.character_workname_by_peer_id(peer_id)

	return self:character_color_id_by_name(workname)
end

function CriminalsManager:character_color_id_by_unit(unit)
	local search_key = unit:key()

	for id, data in pairs(self._characters) do
		if data.unit and data.taken and search_key == data.unit:key() then
			if data.data.ai then
				return #tweak_data.chat_colors
			end

			return data.peer_id
		end
	end
end

function CriminalsManager:character_color_id_by_name(name)
	for id, data in pairs(self._characters) do
		if name == data.name then
			return data.static_data.color_id
		end
	end
end

function CriminalsManager:character_data_by_name(name)
	for _, data in pairs(self._characters) do
		if data.taken and name == data.name then
			return data.data
		end
	end
end

function CriminalsManager:character_data_by_peer_id(peer_id)
	for _, data in pairs(self._characters) do
		if data.taken and peer_id == data.peer_id then
			return data.data
		end
	end
end

function CriminalsManager:character_data_by_unit(unit)
	local search_key = unit:key()

	for id, data in pairs(self._characters) do
		if data.unit and data.taken and search_key == data.unit:key() then
			return data.data
		end
	end
end

function CriminalsManager:character_static_data_by_name(name)
	for _, data in pairs(self._characters) do
		if name == data.name then
			return data.static_data
		end
	end
end

function CriminalsManager:character_unit_by_name(name)
	for _, data in pairs(self._characters) do
		if data.taken and name == data.name then
			return data.unit
		end
	end
end

function CriminalsManager:character_unit_by_peer_id(peer_id)
	for _, data in pairs(self._characters) do
		if data.taken and peer_id == data.peer_id then
			return data.unit
		end
	end
end

function CriminalsManager:character_taken_by_name(name)
	for _, data in pairs(self._characters) do
		if name == data.name then
			return data.taken
		end
	end
end

function CriminalsManager:character_peer_id_by_name(name)
	for _, data in pairs(self._characters) do
		if data.taken and name == data.name then
			return data.peer_id
		end
	end
end

function CriminalsManager:character_peer_id_by_unit(unit)
	if type_name(unit) ~= "Unit" then
		return nil
	end

	local search_key = unit:key()

	for id, data in pairs(self._characters) do
		if data.unit and data.taken and search_key == data.unit:key() then
			return data.peer_id
		end
	end
end

function CriminalsManager:get_free_character_name()
	local preferred = managers.blackmarket:preferred_henchmen()

	for _, name in ipairs(preferred) do
		local data = table.find_value(self._characters, function (val)
			return val.name == name
		end)

		print(inspect(data))

		if data and not data.taken then
			print("chosen", name)

			return name
		end
	end

	local available = {}

	for id, data in pairs(self._characters) do
		local taken = data.taken

		if not taken and not self:is_character_as_AI_level_blocked(data.name) then
			table.insert(available, data.name)
		end
	end

	if #available > 0 then
		return available[math.random(#available)]
	end
end

function CriminalsManager:get_num_player_criminals()
	local num = 0

	for id, data in pairs(self._characters) do
		if data.taken and not data.data.ai then
			num = num + 1
		end
	end

	return num
end

function CriminalsManager:on_peer_left(peer_id)
	for id, data in pairs(self._characters) do
		local char_dmg = alive(data.unit) and data.unit:character_damage()

		if char_dmg and char_dmg.get_paused_counter_name_by_peer then
			local counter_name = char_dmg:get_paused_counter_name_by_peer(peer_id)

			if counter_name then
				if counter_name == "downed" then
					char_dmg:unpause_downed_timer(peer_id)
				elseif counter_name == "arrested" then
					char_dmg:unpause_arrested_timer(peer_id)
				elseif counter_name == "bleed_out" then
					char_dmg:unpause_bleed_out(peer_id)
				else
					Application:stack_dump_error("Unknown counter name \"" .. tostring(counter_name) .. "\" by peer id " .. tostring(peer_id))
				end

				local interact_ext = data.unit:interaction()

				if interact_ext then
					interact_ext:set_waypoint_paused(false)
				end

				managers.network:session():send_to_peers_synched("interaction_set_waypoint_paused", data.unit, false)
			end
		end
	end
end

function CriminalsManager:remove_character_by_unit(unit)
	if type_name(unit) ~= "Unit" then
		return
	end

	local rem_u_key = unit:key()

	for id, data in pairs(self._characters) do
		if data.unit and data.taken and rem_u_key == data.unit:key() then
			self:_remove(id)

			return
		end
	end
end

function CriminalsManager:remove_character_by_peer_id(peer_id)
	for id, data in pairs(self._characters) do
		if data.taken and peer_id == data.peer_id then
			self:_remove(id)

			return
		end
	end
end

function CriminalsManager:remove_character_by_name(name)
	for id, data in pairs(self._characters) do
		if data.taken and name == data.name then
			self:_remove(id)

			return
		end
	end
end

function CriminalsManager:character_name_by_unit(unit)
	if type_name(unit) ~= "Unit" then
		return nil
	end

	local search_key = unit:key()

	for id, data in pairs(self._characters) do
		if data.unit and data.taken and search_key == data.unit:key() then
			return data.name
		end
	end
end

function CriminalsManager:character_name_by_panel_id(panel_id)
	for id, data in pairs(self._characters) do
		if data.taken and data.data.panel_id == panel_id then
			return data.name
		end
	end
end

function CriminalsManager:character_static_data_by_unit(unit)
	if type_name(unit) ~= "Unit" then
		return nil
	end

	local search_key = unit:key()

	for id, data in pairs(self._characters) do
		if data.unit and data.taken and search_key == data.unit:key() then
			return data.static_data
		end
	end
end

function CriminalsManager:nr_AI_criminals()
	local nr_AI_criminals = 0

	for i, char_data in pairs(self._characters) do
		if char_data.data.ai then
			nr_AI_criminals = nr_AI_criminals + 1
		end
	end

	return nr_AI_criminals
end

function CriminalsManager:nr_taken_criminals()
	local nr_taken_criminals = 0

	for i, char_data in pairs(self._characters) do
		if char_data.taken then
			nr_taken_criminals = nr_taken_criminals + 1
		end
	end

	return nr_taken_criminals
end

function CriminalsManager:is_character_as_AI_level_blocked(name)
	if not Global.game_settings.level_id then
		return false
	end

	local block_AIs = tweak_data.levels[Global.game_settings.level_id].block_AIs

	return block_AIs and block_AIs[name] or false
end

function CriminalsManager:get_team_ai_character(index)
	Global.team_ai = Global.team_ai or {}
	index = index or 1
	local char_name = nil

	if managers.job and managers.job:on_first_stage() and not managers.job:interupt_stage() or not Global.team_ai[index] then
		char_name = self:get_free_character_name()
		Global.team_ai[index] = char_name
	else
		char_name = Global.team_ai[index]

		while self:character_taken_by_name(char_name) do
			if Global.team_ai[index + 1] then
				Global.team_ai[index] = Global.team_ai[index + 1]
				Global.team_ai[index + 1] = nil
			else
				Global.team_ai[index] = self:get_free_character_name()
			end

			char_name = Global.team_ai[index]
		end
	end

	return char_name
end

function CriminalsManager:save_current_character_names()
	Global.team_ai = Global.team_ai or {}
	local index = 1

	for _, data in pairs(self._characters) do
		if data.ai or data.taken and alive(data.unit) and not data.unit:base().is_local_player then
			Global.team_ai[index] = data.name
			index = index + 1
		end
	end
end

function CriminalsManager:_reserve_loadout_for(char)
	print("[CriminalsManager]._reserve_loadout_for", char)

	local char_index = char

	if type(char) == "string" then
		for id, data in pairs(self._characters) do
			if data.name == char then
				char_index = id

				break
			end
		end
	end

	local my_char = self._characters[char_index]
	local slot = self._loadout_map[my_char.name]
	slot = slot and self._loadout_slots[slot]

	if slot and slot.char_index == char_index then
		self._loadout_slots[self._loadout_map[my_char.name]].char_index = nil
	end

	for i = 1, managers.criminals.MAX_NR_TEAM_AI, 1 do
		local data = self._loadout_slots[i]
		local char_data = data and self._characters[data.char_index]

		if not char_data or not char_data.data.ai or not char_data.taken or data.char_index == char_index then
			local slot = self._loadout_slots[i]
			slot.char_index = char_index
			self._loadout_map[self._characters[char_index].name] = i

			return managers.blackmarket:henchman_loadout(i, true)
		end
	end

	debug_pause("Failed to reserve loadout!")

	return managers.blackmarket:henchman_loadout(1, true)
end

function CriminalsManager:_reassign_loadouts()
	local current_taken = {}
	local remove_from_index = 1

	for i = 1, managers.criminals.MAX_NR_TEAM_AI, 1 do
		local data = self._loadout_slots[i]
		local char_data = data and self._characters[data.char_index]
		local taken_by_ai = char_data and char_data.data.ai and char_data.taken
		current_taken[i] = taken_by_ai and char_data or false

		if current_taken[i] then
			remove_from_index = remove_from_index + 1
		end
	end

	local to_reassign = {}

	for i = remove_from_index, managers.criminals.MAX_NR_TEAM_AI, 1 do
		local data = current_taken[i]

		if data and alive(data.unit) then
			table.insert(to_reassign, data)

			local index = self._loadout_map[data.name]

			if index then
				self._loadout_slots[index] = {}
			end

			self._loadout_map[data.name] = nil
		end
	end

	for k, v in pairs(to_reassign) do
		local loadout = self:_reserve_loadout_for(v.name)

		self:set_unit(v.name, v.unit, loadout)
		managers.network:session():send_to_peers_synched("set_unit", v.unit, v.name, managers.blackmarket:henchman_loadout_string_from_loadout(loadout), 0, 0, tweak_data.levels:get_default_team_ID("player"))
	end
end

function CriminalsManager:get_loadout_string_for(char_name)
	return managers.blackmarket:henchman_loadout_string(self:get_loadout_for(char_name))
end

function CriminalsManager:get_loadout_for(char_name)
	local index = self._loadout_map[char_name] or 1

	return managers.blackmarket:henchman_loadout(index, true)
end
