TradeManager = TradeManager or class()
TradeManager.TRADE_DELAY = 5
TradeManager._STOCKHOLM_SYNDROME_DELAY = 15

function TradeManager:init()
	self._criminals_to_respawn = {}
	self._criminals_to_add = {}
	self._trade_counter_tick = 1
	self._num_trades = 0
	self._hostage_trade_index = 0
	self._pause_t = 0

	self:set_trade_countdown(true)

	self._trade_complete = true
end

function TradeManager:pause_trade(time)
	self._pause_t = time
end

function TradeManager:save(save_data)
	if not next(self._criminals_to_respawn) then
		local my_save_data = {}
		save_data.trade = my_save_data
		my_save_data.trade_countdown = self._trade_countdown or false

		return
	end

	local my_save_data = {}
	save_data.trade = my_save_data
	my_save_data.criminals = self._criminals_to_respawn
	my_save_data.trade_countdown = self._trade_countdown or false
	my_save_data.outfits = {}

	for _, crim in ipairs(self._criminals_to_respawn) do
		if crim.peer_id then
			my_save_data.outfits[crim.peer_id] = {
				outfit = managers.network:session():peer(crim.peer_id):profile("outfit_string"),
				version = managers.network:session():peer(crim.peer_id):outfit_version()
			}
		end
	end
end

function TradeManager:load(load_data)
	local my_load_data = load_data.trade

	if not my_load_data then
		return
	end

	if my_load_data.trade_countdown ~= nil then
		self:set_trade_countdown(my_load_data.trade_countdown)
	end

	if my_load_data.criminals then
		self._criminals_to_respawn = my_load_data.criminals
		self._criminals_to_add = {}

		for _, crim in ipairs(self._criminals_to_respawn) do
			if not crim.ai and not managers.network:session():peer(crim.peer_id) then
				if crim.peer_id then
					self._criminals_to_add[crim.peer_id] = crim
					local peer = managers.network:session():peer(crim.peer_id)
					local outfit = my_load_data.outfits[crim.peer_id]
					crim.outfit = outfit
				end
			else
				if crim.peer_id then
					local peer = managers.network:session():peer(crim.peer_id)
					local outfit = my_load_data.outfits[crim.peer_id]

					peer:set_outfit_string(outfit.outfit, outfit.version)
				end

				managers.criminals:add_character(crim.id, nil, crim.peer_id, crim.ai)
			end
		end
	end
end

function TradeManager:handshake_complete(peer_id)
	local crim = self._criminals_to_add[peer_id]

	if crim then
		local peer = managers.network:session():peer(peer_id)

		peer:set_outfit_string(crim.outfit)
		managers.criminals:add_character(crim.id, nil, crim.peer_id, crim.ai)

		self._criminals_to_add[peer_id] = nil
	end
end

function TradeManager:is_peer_in_custody(peer_id)
	for _, crim in ipairs(self._criminals_to_respawn) do
		if crim.peer_id == peer_id then
			return true
		end
	end
end

function TradeManager:get_criminal_by_peer(peer_id)
	for _, crim in ipairs(self._criminals_to_respawn) do
		if crim.peer_id == peer_id then
			return crim
		end
	end

	return nil
end

function TradeManager:is_criminal_in_custody(name)
	for _, crim in ipairs(self._criminals_to_respawn) do
		if crim.id == name then
			return true
		end
	end
end

function TradeManager:is_trading()
	return (self._trading_hostage or self._hostage_trade_clbk or self._speaker_snd_event) and #self._criminals_to_respawn > 0
end

function TradeManager:respawn_delay_by_name(character_name)
	for _, crim in ipairs(self._criminals_to_respawn) do
		if crim.id == character_name then
			return crim.respawn_penalty
		end
	end

	return 0
end

function TradeManager:hostages_killed_by_name(character_name)
	for _, crim in ipairs(self._criminals_to_respawn) do
		if crim.id == character_name then
			return crim.hostages_killed
		end
	end

	return 0
end

function TradeManager:update(t, dt)
	self._t = t

	if not managers.criminals or not managers.hud then
		return
	end

	local is_trade_allowed = self:is_trade_allowed()
	local is_auto_assault_ai_trade = self:update_auto_assault_ai_trade(dt, is_trade_allowed)

	if not self._hostage_remind_t or self._hostage_remind_t < t then
		if not self._trading_hostage and not self._hostage_trade_clbk and #self._criminals_to_respawn > 0 and managers.groupai:state():hostage_count() <= 0 and not next(managers.groupai:state():all_converted_enemies()) and managers.groupai:state():is_AI_enabled() and managers.groupai:state():bain_state() then
			local cable_tie_data = managers.player:has_special_equipment("cable_tie")

			if cable_tie_data and Application:digest_value(cable_tie_data.amount, false) > 0 then
				managers.dialog:queue_narrator_dialog("h01x", {})
			elseif self:get_criminal_to_trade(true) ~= nil then
				managers.dialog:queue_narrator_dialog("h22x", {})
			end
		end

		self._hostage_remind_t = t + math.random(60, 120)
	end

	self._trade_counter_tick = self._trade_counter_tick - dt

	if self._trade_counter_tick <= 0 then
		self._trade_counter_tick = self._trade_counter_tick + 1

		if self._hostage_to_trade and not alive(self._hostage_to_trade.unit) then
			self:cancel_trade()
		end

		for _, crim in ipairs(self._criminals_to_respawn) do
			local crim_data = managers.criminals:character_data_by_name(crim.id)
			local mugshot_id = crim_data and crim_data.mugshot_id
			local mugshot_data = mugshot_id and managers.hud:_get_mugshot_data(mugshot_id)

			if mugshot_data and not mugshot_data.state_name ~= "mugshot_in_custody" then
				managers.hud:set_mugshot_custody(mugshot_id)

				if crim.respawn_penalty > 0 then
					-- Nothing
				end
			end

			if crim.respawn_penalty > 0 then
				crim.respawn_penalty = (self._trade_countdown or managers.groupai:state():is_ai_trade_possible()) and crim.respawn_penalty - 1 or crim.respawn_penalty

				if crim.respawn_penalty <= 0 then
					crim.respawn_penalty = 0
				end
			end
		end
	end

	self._pause_t = math.max(0, self._pause_t - dt)

	if (self._trade_countdown or is_auto_assault_ai_trade) and is_trade_allowed and self._pause_t <= 0 and not managers.player:_is_all_in_custody() then
		print("so ")

		local trade = self:get_criminal_to_trade(true)
		local is_ai_trade_possible = managers.groupai:state():is_ai_trade_possible()

		if trade and Global.game_settings.single_player and not trade.ai and not is_ai_trade_possible then
			trade = nil
		end

		if trade then
			self:_increment_trade_index()

			if is_ai_trade_possible then
				self:clbk_begin_hostage_trade_dialog(1)
			else
				print("so far so good")

				local respawn_t = self._t + math.random(2, 5)
				self._hostage_trade_clbk = "TradeManager"

				managers.enemy:add_delayed_clbk(self._hostage_trade_clbk, callback(self, self, "clbk_begin_hostage_trade_dialog", 1), respawn_t)
			end
		end
	end
end

function TradeManager:start_stockholm_syndrome()
	self._stockholm_syndrome = true
end

function TradeManager:end_stockholm_syndrome()
	self._stockholm_syndrome = false
end

function TradeManager:is_trade_allowed()
	return Network:is_server() and not self._trading_hostage and not self._hostage_trade_clbk and #self._criminals_to_respawn > 0 and not managers.groupai:state():whisper_mode() and not self._speaker_snd_event and (managers.groupai:state():hostage_count() > 0 or next(managers.groupai:state():all_converted_enemies()))
end

function TradeManager:is_stockholm_syndrome_allowed()
	local trade_in_progress = self._stockholm_syndrome or not self._trade_complete
	local is_in_stealth = managers.groupai:state():whisper_mode()
	local no_hostages = managers.groupai:state():hostage_count() <= 0

	if Network:is_server() and not trade_in_progress and not is_in_stealth and #self._criminals_to_respawn > 0 and not no_hostages then
		return true, false, false, false
	end

	return false, trade_in_progress, is_in_stealth, no_hostages
end

function TradeManager:_increment_trade_index()
	if self._hostage_trade_index > 10000 then
		self._hostage_trade_index = 1
	else
		self._hostage_trade_index = self._hostage_trade_index + 1
	end
end

function TradeManager:num_in_trade_queue()
	return #self._criminals_to_respawn
end

function TradeManager:get_criminal_to_trade(wait_for_player)
	local ai_crim, has_player = nil

	for _, crim in ipairs(self._criminals_to_respawn) do
		has_player = has_player or not crim.ai

		if crim.respawn_penalty <= 0 then
			if not crim.ai then
				return crim
			else
				ai_crim = ai_crim or crim
			end
		end
	end

	return (not wait_for_player or not has_player) and ai_crim
end

function TradeManager:does_criminal_exist(peer_id)
	for _, crim in ipairs(self._criminals_to_respawn) do
		if crim.peer_id == peer_id then
			return true
		end
	end
end

function TradeManager:sync_set_trade_death(criminal_name, respawn_penalty, hostages_killed, from_local)
	if not from_local then
		local crim_data = managers.criminals:character_data_by_name(criminal_name)

		if not crim_data then
			return
		end

		if crim_data.ai then
			self:on_AI_criminal_death(criminal_name, respawn_penalty, hostages_killed)
		else
			self:on_player_criminal_death(criminal_name, respawn_penalty, hostages_killed)
		end
	end

	self:play_custody_voice(criminal_name)

	if managers.criminals:local_character_name() == criminal_name and not Network:is_server() and game_state_machine:current_state_name() == "ingame_waiting_for_respawn" then
		game_state_machine:current_state():trade_death(respawn_penalty, hostages_killed)
	end
end

function TradeManager:_announce_spawn(criminal_name)
	if not managers.groupai:state():bain_state() then
		return
	end

	local character_code = managers.criminals:character_static_data_by_name(criminal_name).ssuffix

	managers.dialog:queue_narrator_dialog("q02" .. character_code, {})
end

function TradeManager:sync_set_trade_spawn(criminal_name)
	local crim_data = managers.criminals:character_data_by_name(criminal_name)

	self:_announce_spawn(criminal_name)

	self._num_trades = self._num_trades + 1

	if crim_data then
		managers.hud:set_mugshot_normal(crim_data.mugshot_id)
	end

	for i, crim in ipairs(self._criminals_to_respawn) do
		if crim.id == criminal_name then
			table.remove(self._criminals_to_respawn, i)

			break
		end
	end
end

function TradeManager:sync_set_trade_replace(replace_ai, criminal_name1, criminal_name2, respawn_penalty)
	if replace_ai then
		self:replace_ai_with_player(criminal_name1, criminal_name2, respawn_penalty)
	else
		self:replace_player_with_ai(criminal_name1, criminal_name2, respawn_penalty)
	end
end

function TradeManager:play_custody_voice(criminal_name)
	if managers.criminals:local_character_name() == criminal_name then
		return
	end

	if #self._criminals_to_respawn == 3 then
		local criminal_left = nil

		for _, crim_data in pairs(managers.groupai:state():all_char_criminals()) do
			if not crim_data.unit:movement():downed() then
				criminal_left = managers.criminals:character_name_by_unit(crim_data.unit)

				break
			end
		end

		if managers.criminals:local_character_name() == criminal_left then
			managers.achievment:set_script_data("last_man_standing", true)

			if managers.groupai:state():bain_state() then
				local character_code = managers.criminals:character_static_data_by_name(criminal_left).ssuffix

				managers.dialog:queue_narrator_dialog("i20" .. character_code, {})
			end

			return
		end
	end

	if managers.groupai:state():bain_state() then
		local character_code = managers.criminals:character_static_data_by_name(criminal_name).ssuffix

		managers.dialog:queue_narrator_dialog("h11" .. character_code, {})
	end
end

function TradeManager:on_AI_criminal_death(criminal_name, respawn_penalty, hostages_killed, skip_netsend)
	print("[TradeManager:on_AI_criminal_death]", criminal_name, respawn_penalty, hostages_killed, skip_netsend)

	if not managers.hud then
		return
	end

	local crim_data = managers.criminals:character_data_by_name(criminal_name)

	if crim_data then
		managers.hud:set_mugshot_custody(crim_data.mugshot_id)
	end

	local crim = {
		ai = true,
		id = criminal_name,
		respawn_penalty = respawn_penalty,
		hostages_killed = hostages_killed
	}

	table.insert(self._criminals_to_respawn, crim)

	if Network:is_server() and not skip_netsend then
		managers.network:session():send_to_peers_synched("set_trade_death", criminal_name, respawn_penalty, hostages_killed)
		self:sync_set_trade_death(criminal_name, respawn_penalty, hostages_killed, true)
	end

	return crim
end

function TradeManager:on_player_criminal_death(criminal_name, respawn_penalty, hostages_killed, skip_netsend)
	for _, crim in ipairs(self._criminals_to_respawn) do
		if crim.id == criminal_name then
			debug_pause("[TradeManager:on_player_criminal_death] criminal already dead", criminal_name)

			return
		end
	end

	if tweak_data.player.damage.automatic_respawn_time then
		respawn_penalty = math.min(respawn_penalty, tweak_data.player.damage.automatic_respawn_time)
	end

	local crim_data = managers.criminals:character_data_by_name(criminal_name)

	if crim_data then
		if managers.hud then
			managers.hud:set_mugshot_custody(crim_data.mugshot_id)
		else
			debug_pause("[TradeManager:on_player_criminal_death] no hud manager! criminal_name:", criminal_name)
		end
	end

	local peer_id = managers.criminals:character_peer_id_by_name(criminal_name)
	local crim = {
		ai = false,
		id = criminal_name,
		respawn_penalty = respawn_penalty,
		hostages_killed = hostages_killed,
		peer_id = peer_id
	}
	local inserted = false

	for i, crim_to_respawn in ipairs(self._criminals_to_respawn) do
		if crim_to_respawn.ai or respawn_penalty < crim_to_respawn.respawn_penalty then
			table.insert(self._criminals_to_respawn, i, crim)

			inserted = true

			break
		end
	end

	if not inserted then
		table.insert(self._criminals_to_respawn, crim)
	end

	if Network:is_server() and not skip_netsend then
		managers.network:session():send_to_peers_synched("set_trade_death", criminal_name, respawn_penalty, hostages_killed)
		self:sync_set_trade_death(criminal_name, respawn_penalty, hostages_killed, true)
	end

	print("[TradeManager:on_player_criminal_death]", criminal_name, ". Respawn queue:")

	for i, crim_to_respawn in ipairs(self._criminals_to_respawn) do
		print(inspect(crim_to_respawn))
	end

	self:on_player_criminal_removed(criminal_name)

	return crim
end

function TradeManager:set_trade_countdown(enabled)
	self._trade_countdown = enabled

	if Network:is_server() and managers.network then
		managers.network:session():send_to_peers_synched("set_trade_countdown", enabled)
	end
end

function TradeManager:replace_ai_with_player(ai_criminal, player_criminal, new_respawn_penalty)
	local first_crim = self._criminals_to_respawn[1]

	if first_crim and first_crim.id == ai_criminal then
		self:cancel_trade()
	end

	local respawn_penalty, hostages_killed = nil

	for i, c in ipairs(self._criminals_to_respawn) do
		if c.id == ai_criminal then
			respawn_penalty = new_respawn_penalty or c.respawn_penalty
			hostages_killed = c.hostages_killed

			table.remove(self._criminals_to_respawn, i)

			break
		end
	end

	if respawn_penalty then
		if respawn_penalty <= 0 then
			respawn_penalty = 1
		end

		return self:on_player_criminal_death(player_criminal, respawn_penalty, hostages_killed, true)
	end
end

function TradeManager:replace_player_with_ai(player_criminal, ai_criminal, new_respawn_penalty)
	local first_crim = self._criminals_to_respawn[1]

	if first_crim and first_crim.id == player_criminal then
		self:cancel_trade()
	end

	local respawn_penalty, hostages_killed = nil

	for i, c in ipairs(self._criminals_to_respawn) do
		if c.id == player_criminal then
			respawn_penalty = new_respawn_penalty or c.respawn_penalty
			hostages_killed = c.hostages_killed

			print("replacing player in custody. respawn_penalty", respawn_penalty, ". hostages_killed", hostages_killed)
			table.remove(self._criminals_to_respawn, i)

			break
		end
	end

	if respawn_penalty then
		if respawn_penalty <= 0 then
			respawn_penalty = 1
		end

		print("managers.criminals:nr_AI_criminals()", managers.criminals:nr_AI_criminals())

		if managers.groupai:state():team_ai_enabled() and managers.groupai:state():is_AI_enabled() and managers.criminals:nr_AI_criminals() <= CriminalsManager.MAX_NR_TEAM_AI then
			return self:on_AI_criminal_death(ai_criminal, respawn_penalty, hostages_killed, true)
		end
	end
end

function TradeManager:on_player_criminal_removed(player_criminal)
	if not Network:is_server() then
		return
	end

	local peer_id = managers.criminals:character_peer_id_by_name(player_criminal)
	local is_players_alive = false

	for u_key, u_data in pairs(managers.groupai:state():all_player_criminals()) do
		local peer = managers.network:session():peer_by_unit(u_data.unit)

		if u_data.status ~= "dead" and peer and peer:id() ~= peer_id then
			is_players_alive = true
		end
	end

	if not is_players_alive then
		self:cancel_trade()
	end
end

function TradeManager:remove_from_trade(criminal)
	local first_crim = self._criminals_to_respawn[1]

	if first_crim and first_crim.id == criminal then
		self:cancel_trade()
	end

	for i, c in ipairs(self._criminals_to_respawn) do
		if c.id == criminal then
			table.remove(self._criminals_to_respawn, i)

			break
		end
	end
end

function TradeManager:_send_finish_trade(criminal, respawn_delay, hostages_killed)
	if criminal.ai == true then
		return
	end

	local peer_id = managers.criminals:character_peer_id_by_name(criminal.id)

	if peer_id == 1 then
		if game_state_machine:current_state_name() == "ingame_waiting_for_respawn" then
			game_state_machine:current_state():finish_trade()
		end
	else
		local peer = managers.network:session():peer(peer_id)

		if peer then
			peer:send_queued_sync("finish_trade")
		end
	end
end

function TradeManager:_send_begin_trade(criminal)
	if criminal.ai == true then
		return
	end

	local peer_id = managers.criminals:character_peer_id_by_name(criminal.id)

	if peer_id == 1 then
		if game_state_machine:current_state_name() == "ingame_waiting_for_respawn" then
			game_state_machine:current_state():begin_trade()
		end
	else
		local peer = managers.network:session():peer(peer_id)

		if peer then
			peer:send_queued_sync("begin_trade")
		end
	end
end

function TradeManager:_send_cancel_trade(criminal)
	if criminal.ai == true then
		return
	end

	local peer_id = managers.criminals:character_peer_id_by_name(criminal.id)

	if peer_id == managers.network:session():local_peer():id() then
		if game_state_machine:current_state_name() == "ingame_waiting_for_respawn" then
			game_state_machine:current_state():cancel_trade()
		end
	else
		local peer = managers.network:session():peer(peer_id)

		if peer then
			peer:send_queued_sync("cancel_trade")
		end
	end
end

function TradeManager:change_hostage()
	self:sync_hostage_trade_dialog(6)
	managers.network:session():send_to_peers_synched("hostage_trade_dialog", 6)
	self:cancel_trade()
end

function TradeManager:cancel_trade()
	if self._hostage_trade_clbk then
		managers.enemy:remove_delayed_clbk(self._hostage_trade_clbk)

		self._hostage_trade_clbk = nil
	end

	self:_increment_trade_index()

	self._trading_hostage = nil
	local criminal = self:get_criminal_to_trade(false)

	if criminal then
		self:_send_cancel_trade(criminal)
	end

	if self._hostage_to_trade then
		if alive(self._hostage_to_trade.unit) and not self._hostage_to_trade.unit:character_damage():dead() then
			self._hostage_to_trade.unit:brain():cancel_trade()
		end

		if self._hostage_to_trade.death_clbk_key then
			self._hostage_to_trade.unit:character_damage():remove_listener(self._hostage_to_trade.death_clbk_key)
		end

		if self._hostage_to_trade.destroyed_clbk_key then
			self._hostage_to_trade.unit:base():remove_destroy_listener(self._hostage_to_trade.destroyed_clbk_key)
		end

		self._hostage_to_trade = nil
	end

	managers.groupai:state():check_gameover_conditions()
end

function TradeManager:_get_megaphone_sound_source()
	local level_id = Global.level_data.level_id
	local pos = nil

	if not level_id then
		pos = Vector3(0, 0, 0)

		Application:error("[TradeManager:_get_megaphone_sound_source] This level has no megaphone position!")
	elseif not tweak_data.levels[level_id].megaphone_pos then
		pos = Vector3(0, 0, 0)
	else
		pos = tweak_data.levels[level_id].megaphone_pos
	end

	local sound_source = SoundDevice:create_source("megaphone")

	sound_source:set_position(pos)

	return sound_source
end

function TradeManager:sync_hostage_trade_dialog(i)
	if game_state_machine:current_state_name() == "ingame_waiting_for_respawn" or not managers.groupai:state():bain_state() then
		return
	end

	if i == 1 then
		self:_get_megaphone_sound_source():post_event("mga_t01a_con_plu")
	elseif i == 2 then
		managers.dialog:queue_narrator_dialog("h02a", {})
	elseif i == 3 then
		managers.dialog:queue_narrator_dialog("h02b", {})
	elseif i == 4 then
		managers.dialog:queue_narrator_dialog("h02c", {})
	elseif i == 5 then
		managers.dialog:queue_narrator_dialog("h02d", {})
	elseif i == 6 then
		managers.dialog:queue_narrator_dialog("h50x", {})
	elseif i == 7 then
		managers.dialog:queue_narrator_dialog("h02", {})
	end
end

function TradeManager:clbk_vo_end_begin_hostage_trade_dialog(data)
	if data.hostage_trade_index ~= self._hostage_trade_index then
		return
	end

	self._speaker_snd_event = nil

	self:clbk_begin_hostage_trade_dialog(data.i)
end

function TradeManager:clbk_begin_hostage_trade_dialog(i)
	self._hostage_trade_clbk = nil
	local respawn_criminal = self:get_criminal_to_trade(false)

	if not respawn_criminal then
		managers.groupai:state():check_gameover_conditions()

		return
	end

	local char_sync_index = i

	if i == 1 then
		self._megaphone_sound_source = self:_get_megaphone_sound_source()
		self._speaker_snd_event = self._megaphone_sound_source:post_event("mga_t01a_con_plu", callback(self, self, "clbk_vo_end_begin_hostage_trade_dialog", {
			i = 2,
			hostage_trade_index = self._hostage_trade_index
		}), nil, "end_of_event")

		if not self._speaker_snd_event then
			self:clbk_begin_hostage_trade_dialog(2)
			print("Megaphone fail")
		end
	else
		local ssuffix = managers.criminals:character_static_data_by_name(respawn_criminal.id).ssuffix

		if ssuffix == "a" then
			char_sync_index = 2
		elseif ssuffix == "b" then
			char_sync_index = 3
		elseif ssuffix == "c" then
			char_sync_index = 4
		elseif ssuffix == "d" then
			char_sync_index = 5
		else
			char_sync_index = 7
		end

		self:sync_hostage_trade_dialog(char_sync_index)

		local respawn_t = self._t + self.TRADE_DELAY
		self._hostage_trade_clbk = "TradeManager"

		managers.enemy:add_delayed_clbk(self._hostage_trade_clbk, callback(self, self, "clbk_begin_hostage_trade"), respawn_t)
	end

	managers.network:session():send_to_peers_synched("hostage_trade_dialog", char_sync_index)
end

function TradeManager:clbk_begin_hostage_trade()
	self._hostage_trade_clbk = nil

	self:_send_begin_trade(self._criminals_to_respawn[1])

	local possible_criminals, is_instant_trade = self:get_possible_criminals()
	local rescuing_criminal = possible_criminals[math.random(1, #possible_criminals)]
	rescuing_criminal = managers.groupai:state():all_criminals()[rescuing_criminal]
	local rescuing_criminal_pos = nil

	if rescuing_criminal then
		rescuing_criminal_pos = rescuing_criminal.unit:position()
	else
		managers.groupai:state():check_gameover_conditions()
		managers.enemy:add_delayed_clbk(self._hostage_trade_clbk, callback(self, self, "clbk_begin_hostage_trade"), self._t + 5)

		return
	end

	local rot = rescuing_criminal.unit:rotation()
	local best_hostage = self:get_best_hostage(rescuing_criminal_pos)

	self:begin_hostage_trade(rescuing_criminal_pos, rot, best_hostage, is_instant_trade)
end

function TradeManager:begin_hostage_trade(position, rotation, hostage, is_instant_trade, skip_free_criminal, skip_hint, skip_init)
	if hostage then
		local clbk_key = "TradeManager"
		self._trading_hostage = true
		self._hostage_to_trade = hostage

		hostage.unit:brain():set_logic("trade", {
			skip_hint = skip_hint or false
		})

		if not hostage.initialized then
			self._hostage_to_trade.death_clbk_key = clbk_key
			self._hostage_to_trade.destroyed_clbk_key = clbk_key

			hostage.unit:character_damage():add_listener(clbk_key, {
				"death"
			}, callback(self, self, "clbk_hostage_died"))
			hostage.unit:base():add_destroy_listener(clbk_key, callback(self, self, "clbk_hostage_destroyed"))

			hostage.initialized = true
		end

		if is_instant_trade then
			self._auto_assault_ai_trade_t = nil

			hostage.unit:brain():on_trade(position, rotation, not skip_free_criminal)

			self._trade_complete = false
		end
	else
		self:cancel_trade()
	end
end

function TradeManager:get_best_hostage(pos, use_existing)
	if use_existing and self._hostage_to_trade then
		return self._hostage_to_trade
	end

	local civilians = managers.enemy:all_civilians()
	local trade_dist = tweak_data.group_ai.optimal_trade_distance
	local optimal_trade_dist = math.random(trade_dist[1], trade_dist[2])
	optimal_trade_dist = optimal_trade_dist * optimal_trade_dist
	local best_hostage_d, best_hostage = nil
	local all_enemies = managers.enemy:all_enemies()
	local all_hostages = managers.groupai:state():all_hostages()

	for _, h_key in ipairs(all_hostages) do
		local civ = civilians[h_key]

		if civ and civ.unit:character_damage():pickup() then
			civ = nil
		end

		local hostage = civ or all_enemies[h_key]

		if hostage then
			local d = math.abs(mvector3.distance_sq(hostage.m_pos, pos) - optimal_trade_dist)

			if civ then
				d = d * 0.5
			end

			if not best_hostage_d or d < best_hostage_d then
				best_hostage_d = d
				best_hostage = hostage
			end
		end
	end

	if not best_hostage then
		for u_key, unit in pairs(managers.groupai:state():all_converted_enemies()) do
			best_hostage = all_enemies[u_key]
		end
	end

	if best_hostage then
		best_hostage.initialized = false
	end

	return best_hostage
end

function TradeManager:clbk_hostage_destroyed(hostage_unit)
	if not self._hostage_to_trade or not self._hostage_to_trade.destroyed_clbk_key then
		return
	end

	self._hostage_to_trade.destroyed_clbk_key = nil

	self:cancel_trade()
end

function TradeManager:clbk_hostage_died(hostage_unit, damage_info)
	if not self._hostage_to_trade or not self._hostage_to_trade.death_clbk_key then
		return
	end

	self._hostage_to_trade.death_clbk_key = nil

	self:cancel_trade()
end

function TradeManager:trade_in_progress()
	return self._trade_in_progress or false
end

function TradeManager:on_hostage_traded(pos, rotation)
	print("RC: Traded hostage!!")

	if self._criminal_respawn_clbk or self._trade_in_progress then
		return
	end

	self._hostage_to_trade = nil
	self._trade_in_progress = true
	local respawn_t = self._t + 2
	local clbk_id = "Respawn_criminal_on_trade"
	self._criminal_respawn_clbk = clbk_id

	managers.enemy:add_delayed_clbk(clbk_id, callback(self, self, "clbk_respawn_criminal", pos, rotation), respawn_t)
end

function TradeManager:clbk_respawn_criminal(pos, rotation)
	self._criminal_respawn_clbk = nil
	self._trading_hostage = nil
	local respawn_criminal = self:get_criminal_to_trade(false)

	if not respawn_criminal then
		self._trade_in_progress = false

		return
	end

	print("Found criminal to respawn ", respawn_criminal and inspect(respawn_criminal))
	self:criminal_respawn(pos, rotation, respawn_criminal)
end

function TradeManager:criminal_respawn(pos, rotation, respawn_criminal)
	local respawn_delay = respawn_criminal.respawn_penalty

	self:_send_finish_trade(respawn_criminal, respawn_delay, respawn_criminal.hostages_killed)

	self._num_trades = self._num_trades + 1

	managers.network:session():send_to_peers_synched("set_trade_spawn", respawn_criminal.id)
	self:_announce_spawn(respawn_criminal.id)

	local spawned_unit = nil

	if respawn_criminal.ai then
		print("RC: respawn AI", respawn_criminal.id)

		spawned_unit = managers.groupai:state():spawn_one_teamAI(false, respawn_criminal.id, pos, rotation)
	else
		print("RC: respawn human", respawn_criminal.id)

		local lone_survivor = managers.groupai:state():num_alive_players() == 0
		local sp_id = "clbk_respawn_criminal"
		local spawn_point = {
			position = pos,
			rotation = rotation
		}

		managers.network:register_spawn_point(sp_id, spawn_point)

		local peer_id = managers.criminals:character_peer_id_by_name(respawn_criminal.id)
		spawned_unit = managers.network:session():spawn_member_by_id(peer_id, sp_id, true)

		managers.network:unregister_spawn_point(sp_id)

		if lone_survivor then
			managers.network:session():send_to_peers("on_sole_criminal_respawned", peer_id)
			managers.player:on_sole_criminal_respawned(peer_id)
		end
	end

	managers.mission:call_global_event("player_release_ai")
	self:_remove_criminal_respawn(respawn_criminal)

	self._trade_in_progress = false
end

function TradeManager:sync_teammate_helped_hint(helped_unit, helping_unit, hint)
	if not alive(helped_unit) or not alive(helping_unit) then
		return
	end

	local local_unit = managers.criminals:character_unit_by_name(managers.criminals:local_character_name())
	local hint_id = "teammate"

	if local_unit == helped_unit then
		hint_id = "you_were"
	elseif local_unit == helping_unit then
		hint_id = "you"
	end

	if not hint or hint == 1 then
		hint_id = hint_id .. "_revived"
	elseif hint == 2 then
		hint_id = hint_id .. "_helpedup"
	elseif hint == 3 then
		hint_id = hint_id .. "_rescued"
	end

	if hint_id then
		managers.hint:show_hint(hint_id, nil, false, {
			TEAMMATE = helped_unit:base():nick_name(),
			HELPER = helping_unit:base():nick_name()
		})
	end
end

function TradeManager:_remove_criminal_respawn(respawn_criminal)
	for i, crim in ipairs(self._criminals_to_respawn) do
		if crim == respawn_criminal then
			print("Removing from list")
			table.remove(self._criminals_to_respawn, i)

			break
		end
	end
end

function TradeManager:trade_complete()
	self._trade_complete = true
	self._hostage_to_trade = nil
	self._trading_hostage = nil

	self:end_stockholm_syndrome()
end

function TradeManager:update_auto_assault_ai_trade(dt, is_trade_allowed)
	if self._auto_assault_ai_trade_t then
		self._auto_assault_ai_trade_t = self._auto_assault_ai_trade_t - dt
	end

	if not Network:is_server() then
		return false
	end

	if not is_trade_allowed or self._trade_countdown or not managers.groupai:state():is_ai_trade_possible() then
		if not self:is_trading() then
			self:_set_auto_assault_ai_trade(nil, 0)
		end

		return false
	end

	local min_crim = self:get_min_criminal_to_trade()

	if not min_crim then
		Application:error("AI trade possible even though no one to trade.\n", inspect(self._criminals_to_respawn))

		return false
	end

	if not self._auto_assault_ai_trade_t then
		self._auto_assault_ai_trade_t = tweak_data.player.damage.automatic_assault_ai_trade_time
	end

	local time = self._auto_assault_ai_trade_t + math.max(0, min_crim.respawn_penalty)
	time = math.min(time, tweak_data.player.damage.automatic_assault_ai_trade_time_max)

	self:_set_auto_assault_ai_trade(min_crim.id, time)

	return time <= self.TRADE_DELAY
end

function TradeManager:get_min_criminal_to_trade()
	local min_crim = nil

	for _, crim in ipairs(self._criminals_to_respawn) do
		if not crim.ai and (not min_crim or crim.respawn_penalty < min_crim.respawn_penalty) then
			min_crim = crim
		end
	end

	return min_crim
end

function TradeManager:_set_auto_assault_ai_trade(character_name, time)
	if self._auto_assault_ai_trade_criminal_name ~= character_name then
		self._auto_assault_ai_trade_criminal_name = character_name

		if managers.network and not Global.game_settings.single_player then
			managers.network:session():send_to_peers_synched("set_auto_assault_ai_trade", character_name, time)
		end
	end
end

function TradeManager:sync_set_auto_assault_ai_trade(character_name, time)
	self._auto_assault_ai_trade_criminal_name = character_name
	self._auto_assault_ai_trade_t = time
end

function TradeManager:get_auto_assault_ai_trade_time()
	if not self._trade_countdown and managers.criminals:local_character_name() == self._auto_assault_ai_trade_criminal_name and managers.groupai:state():is_ai_trade_possible() then
		return self._auto_assault_ai_trade_t
	else
		return nil
	end
end

function TradeManager:get_possible_criminals()
	local possible_criminals = {}

	for u_key, u_data in pairs(managers.groupai:state():all_player_criminals()) do
		if u_data.status ~= "dead" then
			table.insert(possible_criminals, u_key)
		end
	end

	local is_instant_trade = nil

	if #possible_criminals == 0 then
		is_instant_trade = true

		for u_key, u_data in pairs(managers.groupai:state():all_AI_criminals()) do
			if u_data.status ~= "dead" and u_data.status ~= "disabled" then
				table.insert(possible_criminals, u_key)
			end
		end
	end

	return possible_criminals, is_instant_trade
end

function TradeManager:get_guard_hostage_time()
	local min_crim = self:get_min_criminal_to_trade()
	local penalty = min_crim and min_crim.respawn_penalty or 0
	local guard_time = (self._auto_assault_ai_trade_t or 0) + penalty
	local automatic_respawn_time = tweak_data.player.damage.automatic_respawn_time

	if automatic_respawn_time then
		return math.min(automatic_respawn_time, guard_time)
	else
		return guard_time
	end
end
