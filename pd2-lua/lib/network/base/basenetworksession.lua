BaseNetworkSession = BaseNetworkSession or class()
BaseNetworkSession.TIMEOUT_CHK_INTERVAL = 5

if SystemInfo:platform() == Idstring("X360") then
	BaseNetworkSession.CONNECTION_TIMEOUT = 15
elseif SystemInfo:platform() == Idstring("PS4") then
	BaseNetworkSession.CONNECTION_TIMEOUT = 10
elseif SystemInfo:platform() == Idstring("XB1") then
	BaseNetworkSession.CONNECTION_TIMEOUT = 10
else
	BaseNetworkSession.CONNECTION_TIMEOUT = 10
end

BaseNetworkSession.LOADING_CONNECTION_TIMEOUT = SystemInfo:platform() == Idstring("WIN32") and 20 or 20
BaseNetworkSession._LOAD_WAIT_TIME = 3
BaseNetworkSession._STEAM_P2P_SEND_INTERVAL = 1

function BaseNetworkSession:init()
	print("[BaseNetworkSession:init]")

	self._ids_WIN32 = Idstring("WIN32")
	self._peers = {}
	self._peers_all = {}
	self._server_peer = nil
	self._timeout_chk_t = 0
	self._kicked_list = {}
	self._connection_established_results = {}
	self._soft_remove_peers = false
	self._dropin_pause_info = {}
	self._old_players = {}
	self._spawn_point_beanbag = nil

	Network:set_client_send_callback(callback(self, self, "clbk_network_send"))

	self._dropin_complete_event_manager_id = EventManager:register_listener(Idstring("net_save_received"), callback(self, self, "on_peer_save_received"))
end

function BaseNetworkSession:create_local_peer(load_outfit)
	local my_name = managers.network.account:username_id()
	local my_user_id = SystemInfo:distribution() == Idstring("STEAM") and Steam:userid() or false
	self._local_peer = NetworkPeer:new(my_name, Network:self("TCP_IP"), 0, false, false, false, managers.blackmarket:get_preferred_character(), my_user_id)

	if load_outfit then
		self._local_peer:set_outfit_string(managers.blackmarket:outfit_string(), nil)
	end
end

function BaseNetworkSession:register_local_peer(id)
	self._local_peer:set_id(id)

	self._peers_all[id] = self._local_peer
end

function BaseNetworkSession:load(data)
	for peer_id, peer_data in pairs(data.peers) do
		self._peers[peer_id] = NetworkPeer:new()
		self._peers_all[peer_id] = self._peers[peer_id]

		self._peers[peer_id]:load(peer_data)
	end

	if data.server_peer then
		self._server_peer = self._peers[data.server_peer]
	end

	self._local_peer:load(data.local_peer)

	self._peers_all[self._local_peer:id()] = self._local_peer
	self.update = self.update_skip_one
	self._kicked_list = data.kicked_list
	self._connection_established_results = data.connection_established_results

	if data.dead_con_reports then
		self._dead_con_reports = {}

		for _, report in ipairs(data.dead_con_reports) do
			local report = {
				process_t = report.process_t,
				reporter = self._peers[report.reporter],
				reported = self._peers[report.reported]
			}

			table.insert(self._dead_con_reports, report)
		end
	end

	self._server_protocol = data.server_protocol
	self._notify_host_when_outfits_loaded = data.notify_host_when_outfits_loaded
	self._load_counter = data.load_counter

	if self:is_client() and self:server_peer() then
		Network:set_client(self:server_peer():rpc())

		local is_playing = BaseNetworkHandler._gamestate_filter.any_ingame_playing[game_state_machine:last_queued_state_name()]

		if is_playing then
			Application:set_pause(true)
		end
	end
end

function BaseNetworkSession:save(data)
	if self._server_peer then
		data.server_peer = self._server_peer:id()
	end

	local peers = {}
	data.peers = peers

	for peer_id, peer in pairs(self._peers) do
		local peer_data = {}
		peers[peer_id] = peer_data

		peer:save(peer_data)
	end

	data.local_peer = {}

	self._local_peer:save(data.local_peer)

	data.kicked_list = self._kicked_list
	data.connection_established_results = self._connection_established_results

	if self._dead_con_reports then
		data.dead_con_reports = {}

		for _, report in ipairs(self._dead_con_reports) do
			local save_report = {
				process_t = report.process_t,
				reporter = report.reporter:id(),
				reported = report.reported:id()
			}

			table.insert(data.dead_con_reports, save_report)
		end
	end

	if self._dropin_complete_event_manager_id then
		EventManager:unregister_listener(self._dropin_complete_event_manager_id)

		self._dropin_complete_event_manager_id = nil
	end

	self:_flush_soft_remove_peers()

	data.server_protocol = self._server_protocol
	data.notify_host_when_outfits_loaded = self._notify_host_when_outfits_loaded
	data.load_counter = self._load_counter
end

function BaseNetworkSession:server_peer()
	return self._server_peer
end

function BaseNetworkSession:peer(peer_id)
	return self._peers_all[peer_id]
end

function BaseNetworkSession:peers()
	return self._peers
end

function BaseNetworkSession:all_peers()
	return self._peers_all
end

function BaseNetworkSession:peer_by_ip(ip)
	for peer_id, peer in pairs(self._peers_all) do
		if peer:ip() == ip then
			return peer
		end
	end
end

function BaseNetworkSession:peer_by_name(name)
	for peer_id, peer in pairs(self._peers) do
		if peer:name() == name then
			return peer
		end
	end
end

function BaseNetworkSession:peer_by_user_id(user_id)
	for peer_id, peer in pairs(self._peers_all) do
		if peer:user_id() == user_id then
			return peer
		end
	end
end

function BaseNetworkSession:peer_by_unit(unit)
	local wanted_key = unit:key()

	for _, peer in pairs(self._peers_all) do
		local test_unit = peer:unit()

		if alive(test_unit) and test_unit:key() == wanted_key then
			return peer
		end
	end
end

function BaseNetworkSession:peer_by_unit_key(wanted_key)
	for _, peer in pairs(self._peers_all) do
		local test_unit = peer:unit()

		if alive(test_unit) and test_unit:key() == wanted_key then
			return peer
		end
	end
end

function BaseNetworkSession:amount_of_players()
	return table.size(self._peers_all)
end

function BaseNetworkSession:amount_of_alive_players()
	local count = 0

	for _, peer in pairs(self._peers_all) do
		if alive(peer:unit()) then
			count = count + 1
		end
	end

	return count
end

function BaseNetworkSession:local_peer()
	return self._local_peer
end

function BaseNetworkSession:is_kicked(peer_name)
	return self._kicked_list[peer_name]
end

function BaseNetworkSession:add_peer(name, rpc, in_lobby, loading, synched, id, character, user_id, xuid, xnaddr)
	print("[BaseNetworkSession:add_peer]", name, rpc, in_lobby, loading, synched, id, character, user_id, xuid, xnaddr)

	local peer = NetworkPeer:new(name, rpc, id, loading, synched, in_lobby, character, user_id)

	peer:set_xuid(xuid)

	if SystemInfo:platform() == Idstring("X360") or self:is_host() then
		peer:set_xnaddr(xnaddr)
	end

	if SystemInfo:distribution() == Idstring("STEAM") then
		Steam:set_played_with(peer:user_id())
	end

	self._peers[id] = peer
	self._peers_all[id] = peer

	managers.network:on_peer_added(peer, id)

	if synched then
		self:on_peer_sync_complete(peer, id)
	end

	if managers.platform then
		managers.platform:refresh_rich_presence()
	end

	if rpc then
		self:remove_connection_from_trash(rpc)
		self:remove_connection_from_soft_remove_peers(rpc)
	end

	managers.network:dispatch_event("session_peer_added", peer)

	return id, peer
end

function BaseNetworkSession:remove_peer(peer, peer_id, reason)
	print("[BaseNetworkSession:remove_peer]", inspect(peer), peer_id, reason)
	Application:stack_dump()
	peer:end_ticket_session()

	if peer_id == 1 then
		self._server_peer = nil
	end

	for i, achievement_data in pairs(tweak_data.achievement.check_equipment_memory_on_leave) do
		if achievement_data.memory then
			local pass = managers.challenge:check_equipped_team(achievement_data)

			if not pass then
				managers.job:set_memory(achievement_data.trophy_stat, not achievement_data.memory.value, achievement_data.memory.is_shortterm)
			end
		end
	end

	self._peers[peer_id] = nil
	self._peers_all[peer_id] = nil
	self._connection_established_results[peer:name()] = nil

	self:_on_peer_removed(peer, peer_id, reason)

	if managers.platform then
		managers.platform:refresh_rich_presence()
	end

	if peer:rpc() then
		self:_soft_remove_peer(peer)
	else
		peer:destroy()
	end
end

function BaseNetworkSession:_on_peer_removed(peer, peer_id, reason)
	if managers.player then
		managers.player:peer_dropped_out(peer)
	end

	if managers.menu_scene then
		managers.menu_scene:set_lobby_character_visible(peer_id, false)
	end

	local lobby_menu = managers.menu:get_menu("lobby_menu")

	if lobby_menu and lobby_menu.renderer:is_open() then
		lobby_menu.renderer:remove_player_slot_by_peer_id(peer, reason)
	end

	local kit_menu = managers.menu:get_menu("kit_menu")

	if kit_menu and kit_menu.renderer:is_open() then
		kit_menu.renderer:remove_player_slot_by_peer_id(peer, reason)
	end

	if managers.menu_component then
		managers.menu_component:on_peer_removed(peer, reason)
	end

	if managers.mutators then
		managers.mutators:on_peer_removed(peer, peer_id, reason)
	end

	if managers.chat then
		if reason == "left" then
			managers.chat:feed_system_message(ChatManager.GAME, managers.localization:text("menu_chat_peer_left", {
				name = peer:name()
			}))
		elseif reason == "kicked" then
			managers.chat:feed_system_message(ChatManager.GAME, managers.localization:text("menu_chat_peer_kicked", {
				name = peer:name()
			}))
		elseif reason == "auth_fail" then
			managers.chat:feed_system_message(ChatManager.GAME, managers.localization:text("menu_chat_peer_failed", {
				name = peer:name()
			}))
		else
			managers.chat:feed_system_message(ChatManager.GAME, managers.localization:text("menu_chat_peer_lost", {
				name = peer:name()
			}))
		end
	end

	managers.blackmarket:check_frog_1()
	print("Someone left", peer:name(), peer_id)

	local player_left = false
	local player_character = nil

	if managers.criminals then
		player_character = managers.criminals:character_name_by_peer_id(peer_id)

		if player_character then
			player_left = true

			print("Player left")
			managers.mission:call_global_event("on_peer_removed", peer_id)
		end
	end

	local member_unit = peer:unit()
	local member_downed = alive(member_unit) and member_unit:movement():downed()
	local member_health = 1
	local member_dead = managers.trade and managers.trade:is_peer_in_custody(peer_id)
	local hostages_killed = 0
	local respawn_penalty = 0

	if member_dead and player_character and managers.trade then
		hostages_killed = managers.trade:hostages_killed_by_name(player_character)
		respawn_penalty = managers.trade:respawn_delay_by_name(player_character)
	elseif alive(member_unit) then
		local criminal_record = managers.groupai:state():criminal_record(member_unit:key())

		if criminal_record then
			hostages_killed = criminal_record.hostages_killed
			respawn_penalty = criminal_record.respawn_penalty
		end
	end

	if player_left then
		local mugshot_id = managers.criminals:character_data_by_peer_id(peer_id).mugshot_id
		local mugshot_data = managers.hud:_get_mugshot_data(mugshot_id)
		member_health = mugshot_data and mugshot_data.health_amount or 1
	end

	local member_used_deployable = peer:used_deployable() or false
	local member_used_cable_ties = peer:used_cable_ties() or 0
	local member_used_body_bags = peer:used_body_bags()

	peer:unit_delete()

	local peer_ident = SystemInfo:platform() == Idstring("WIN32") and peer:user_id() or peer:name()

	if Network:is_server() then
		self:check_start_game_intro()
	end

	if Network:multiplayer() then
		if SystemInfo:platform() == Idstring("X360") or SystemInfo:platform() == Idstring("XB1") or SystemInfo:platform() == Idstring("PS4") then
			managers.network.matchmake:on_peer_removed(peer)
		end

		if Network:is_client() then
			if player_left then
				managers.criminals:on_peer_left(peer_id)
				managers.criminals:remove_character_by_peer_id(peer_id)
				managers.trade:replace_player_with_ai(player_character, player_character)
			end
		elseif Network:is_server() then
			managers.network.matchmake:set_num_players(self:amount_of_players())
			Network:remove_client(peer:rpc())

			if player_left then
				managers.achievment:set_script_data("cant_touch_fail", true)
				managers.criminals:on_peer_left(peer_id)
				managers.criminals:remove_character_by_peer_id(peer_id)

				local unit = managers.groupai:state():spawn_one_teamAI(true, player_character)
				self._old_players[peer_ident] = {
					t = Application:time(),
					member_downed = member_downed,
					health = member_health,
					used_deployable = member_used_deployable,
					used_cable_ties = member_used_cable_ties,
					used_body_bags = member_used_body_bags,
					member_dead = member_dead,
					hostages_killed = hostages_killed,
					respawn_penalty = respawn_penalty
				}
				local trade_entry = managers.trade:replace_player_with_ai(player_character, player_character)

				if unit then
					if trade_entry then
						unit:brain():set_active(false)
						unit:base():set_slot(unit, 0)
						unit:base():unregister()
					elseif member_downed then
						unit:character_damage():force_bleedout()
					end
				else
					managers.trade:remove_from_trade(player_character)
				end
			end

			local deployed_equipment = World:find_units_quick("all", 14, 25, 26)

			for _, equipment in ipairs(deployed_equipment) do
				if equipment:base() and equipment:base().server_information then
					local server_information = equipment:base():server_information()

					if server_information and server_information.owner_peer_id == peer_id then
						equipment:set_slot(0)
					end
				end
			end
		else
			print("Tried to remove client when neither server or client")
			Application:stack_dump()
		end
	end
end

function BaseNetworkSession:_soft_remove_peer(peer)
	self._soft_remove_peers = self._soft_remove_peers or {}
	self._soft_remove_peers[peer:rpc():ip_at_index(0)] = {
		peer = peer,
		expire_t = TimerManager:wall():time() + 1.5
	}
end

function BaseNetworkSession:on_peer_left_lobby(peer)
	if peer:id() == 1 and self:is_client() and self._cb_find_game then
		self:on_join_request_timed_out()
	end
end

function BaseNetworkSession:on_peer_left(peer, peer_id)
	cat_print("multiplayer_base", "[BaseNetworkSession:on_peer_left] Peer Left", peer_id, peer:name(), peer:ip())
	Application:stack_dump()
	self:remove_peer(peer, peer_id, "left")

	if peer_id == 1 and self:is_client() then
		if self._cb_find_game then
			self:on_join_request_timed_out()
		else
			if self:_local_peer_in_lobby() then
				managers.network.matchmake:leave_game()
			else
				managers.network.matchmake:destroy_game()
			end

			managers.network.voice_chat:destroy_voice()

			if game_state_machine:current_state().on_server_left then
				game_state_machine:current_state():on_server_left()
			end
		end
	end
end

function BaseNetworkSession:on_peer_lost(peer, peer_id)
	cat_print("multiplayer_base", "[BaseNetworkSession:on_peer_lost] Peer Lost", peer_id, peer:name(), peer:ip())
	Application:stack_dump()
	self:remove_peer(peer, peer_id, "lost")

	if peer_id == 1 and self:is_client() then
		if self._cb_find_game then
			self:on_join_request_timed_out()
		else
			if self:_local_peer_in_lobby() then
				managers.network.matchmake:leave_game()
			else
				managers.network.matchmake:destroy_game()
			end

			managers.network.voice_chat:destroy_voice()

			if managers.network:stopping() or self._closing then
				return
			end

			managers.system_menu:close("leave_lobby")

			if game_state_machine:current_state().on_server_left then
				Global.on_server_left_message = "dialog_connection_to_host_lost"

				game_state_machine:current_state():on_server_left()
			end
		end
	end

	if peer_id ~= 1 and self:is_client() and self._server_peer then
		self._server_peer:send("report_dead_connection", peer_id)
	end
end

function BaseNetworkSession:on_peer_kicked(peer, peer_id, message_id)
	if peer ~= self._local_peer then
		if message_id == 0 or message_id == 6 then
			local ident = self._ids_WIN32 == SystemInfo:platform() and peer:user_id() or peer:name()
			self._kicked_list[ident] = true
		end

		local reason = "kicked"

		if message_id == 1 then
			reason = "removed_dead"

			if peer:is_host() and game_state_machine:current_state().on_server_left then
				Global.on_server_left_message = "dialog_connection_to_host_lost"

				game_state_machine:current_state():on_server_left()
			end
		elseif message_id == 2 or message_id == 3 then
			reason = "auth_fail"
		end

		self:remove_peer(peer, peer_id, reason)
	else
		if message_id == 1 then
			Global.on_remove_peer_message = "dialog_remove_dead_peer"
		elseif message_id == 2 then
			Global.on_remove_peer_message = "dialog_authentication_fail"
		elseif message_id == 3 then
			Global.on_remove_peer_message = "dialog_authentication_host_fail"
		elseif message_id == 4 then
			Global.on_remove_peer_message = "dialog_cheated_host"
		elseif message_id == 6 then
			Global.on_remove_peer_message = "dialog_kick_banned"
		end

		print("IVE BEEN KICKED!")

		if self:_local_peer_in_lobby() then
			print("KICKED FROM LOBBY")
			managers.menu:on_leave_lobby()
			managers.menu:show_peer_kicked_dialog()
		else
			print("KICKED FROM INGAME")
			managers.network.matchmake:destroy_game()
			managers.network.voice_chat:destroy_voice()

			if game_state_machine:current_state().on_kicked then
				game_state_machine:current_state():on_kicked()
			end
		end
	end
end

function BaseNetworkSession:_local_peer_in_lobby()
	return self._local_peer:in_lobby() and game_state_machine:current_state_name() ~= "ingame_lobby_menu"
end

function BaseNetworkSession:update_skip_one()
	self.update = nil
	local wall_time = TimerManager:wall():time()
	self._timeout_chk_t = wall_time + self.TIMEOUT_CHK_INTERVAL
end

function BaseNetworkSession:update()
	local wall_time = TimerManager:wall():time()

	if self._timeout_chk_t < wall_time then
		for peer_id, peer in pairs(self._peers) do
			peer:chk_timeout(peer:loading() and self.LOADING_CONNECTION_TIMEOUT or self.CONNECTION_TIMEOUT)
		end

		self._timeout_chk_t = wall_time + self.TIMEOUT_CHK_INTERVAL
	end

	if self._closing and self:is_ready_to_close() then
		self._closing = false

		managers.network:queue_stop_network()
	end

	self:upd_trash_connections(wall_time)
	self:send_steam_p2p_msgs(wall_time)
end

function BaseNetworkSession:end_update()
end

function BaseNetworkSession:send_to_peers(...)
	for peer_id, peer in pairs(self._peers) do
		peer:send(...)
	end
end

function BaseNetworkSession:send_to_peers_ip_verified(...)
	for peer_id, peer in pairs(self._peers) do
		if peer:ip_verified() then
			peer:send(...)
		end
	end
end

function BaseNetworkSession:send_to_peers_except(id, ...)
	for peer_id, peer in pairs(self._peers) do
		if peer_id ~= id then
			peer:send(...)
		end
	end
end

function BaseNetworkSession:send_to_peers_synched(...)
	for peer_id, peer in pairs(self._peers) do
		peer:send_queued_sync(...)
	end
end

function BaseNetworkSession:send_to_peers_synched_except(id, ...)
	for peer_id, peer in pairs(self._peers) do
		if peer_id ~= id then
			peer:send_queued_sync(...)
		end
	end
end

function BaseNetworkSession:send_to_peers_loaded(...)
	for peer_id, peer in pairs(self._peers) do
		peer:send_after_load(...)
	end
end

function BaseNetworkSession:send_to_peers_loaded_except(id, ...)
	for peer_id, peer in pairs(self._peers) do
		if peer_id ~= id then
			peer:send_after_load(...)
		end
	end
end

function BaseNetworkSession:send_to_peer(peer, ...)
	peer:send(...)
end

function BaseNetworkSession:send_to_peer_synched(peer, ...)
	peer:send_queued_sync(...)
end

function BaseNetworkSession:has_recieved_ok_to_load_level()
	return self._recieved_ok_to_load_level
end

function BaseNetworkSession:_load_level(...)
	self._local_peer:set_loading(true)
	Network:set_multiplayer(true)
	setup:load_level(...)

	self._load_wait_timeout_t = TimerManager:wall():time() + self._LOAD_WAIT_TIME
end

function BaseNetworkSession:_load_lobby(...)
	managers.menu:on_leave_active_job()
	self._local_peer:set_loading(true)
	Network:set_multiplayer(true)
	setup:load_start_menu_lobby(...)

	self._load_wait_timeout_t = TimerManager:wall():time() + self._LOAD_WAIT_TIME
end

function BaseNetworkSession:debug_list_peers()
	for i, peer in pairs(self._peers) do
		cat_print("multiplayer_base", "Peer", i, peer:connection_info())
	end
end

function BaseNetworkSession:clbk_network_send(target_rpc, post_send)
	local target_ip = target_rpc:ip_at_index(0)

	if post_send then
		if self._soft_remove_peers and self._soft_remove_peers[target_ip] then
			local ok_to_delete = true
			local peer_remove_info = self._soft_remove_peers[target_ip]

			if not peer_remove_info.expire_t or TimerManager:game():time() < peer_remove_info.expire_t then
				local send_resume = Network:get_connection_send_status(target_rpc)

				if send_resume then
					for delivery_type, amount in pairs(send_resume) do
						if amount > 0 then
							ok_to_delete = false

							break
						end
					end
				end
			end

			if ok_to_delete then
				print("[BaseNetworkSession:clbk_network_send] soft-removed peer", peer_remove_info.peer:id(), target_ip)
				peer_remove_info.peer:destroy()

				self._soft_remove_peers[target_ip] = nil

				if not next(self._soft_remove_peers) then
					self._soft_remove_peers = false
				end
			end
		else
			local peer = nil

			if target_rpc:protocol_at_index(0) == "TCP_IP" then
				peer = self:peer_by_ip(target_ip)
			else
				peer = self:peer_by_user_id(target_ip)
			end

			if not peer then
				self:add_connection_to_trash(target_rpc)
			end
		end
	else
		local peer = self:peer_by_ip(target_ip)

		if peer then
			peer:on_send()
		end
	end
end

function BaseNetworkSession:is_ready_to_close()
	for peer_id, peer in pairs(self._peers) do
		if peer:has_queued_rpcs() then
			print("[BaseNetworkSession:is_ready_to_close] waiting queued rpcs", peer_id)
		end

		if peer:is_loading_outfit_assets() then
			return false
		end

		if not peer:rpc() then
			print("[BaseNetworkSession:is_ready_to_close] waiting rpc", peer_id)

			return false
		end
	end

	return true
end

function BaseNetworkSession:closing()
	return self._closing
end

function BaseNetworkSession:prepare_to_close(skip_destroy_matchmaking)
	print("[BaseNetworkSession:prepare_to_close]")

	self._closing = true

	if not skip_destroy_matchmaking then
		managers.network.matchmake:destroy_game()
	end

	Network:set_disconnected()
end

function BaseNetworkSession:set_peer_loading_state(peer, state, load_counter)
	print("[BaseNetworkSession:set_peer_loading_state]", peer:id(), state)

	if Global.load_start_menu_lobby then
		return
	end

	if not state and self._local_peer:loaded() then
		if peer:ip_verified() then
			self._local_peer:sync_lobby_data(peer)
			self._local_peer:sync_data(peer)
		end

		peer:flush_overwriteable_msgs()
	end
end

function BaseNetworkSession:upd_trash_connections(wall_t)
	if self._trash_connections then
		for ip, info in pairs(self._trash_connections) do
			if info.expire_t < wall_t then
				local reset = true

				for peer_id, peer in pairs(self._peers) do
					if peer:ip_verified() and peer:ip() == ip or peer:user_id() == ip then
						reset = false

						break
					end
				end

				if reset then
					print("[BaseNetworkSession:upd_trash_connections] resetting connection:", info.rpc:ip_at_index(0))
					Network:reset_connection(info.rpc)
				end

				self._trash_connections[ip] = nil
			end
		end

		if not next(self._trash_connections) then
			self._trash_connections = nil
		end
	end

	if self._soft_remove_peers then
		for peer_ip, info in pairs(self._soft_remove_peers) do
			if info.expire_t < wall_t then
				info.peer:destroy()

				self._soft_remove_peers[peer_ip] = nil

				break
			end
		end

		if not next(self._soft_remove_peers) then
			self._soft_remove_peers = nil
		end
	end
end

function BaseNetworkSession:add_connection_to_trash(rpc)
	local wanted_ip = rpc:ip_at_index(0)
	self._trash_connections = self._trash_connections or {}

	if not self._trash_connections[wanted_ip] then
		print("[BaseNetworkSession:add_connection_to_trash]", wanted_ip)

		self._trash_connections[wanted_ip] = {
			rpc = rpc,
			expire_t = TimerManager:wall():time() + self.CONNECTION_TIMEOUT
		}
	end
end

function BaseNetworkSession:remove_connection_from_trash(rpc)
	local wanted_ip = rpc:ip_at_index(0)

	if self._trash_connections then
		if self._trash_connections[wanted_ip] then
			print("[BaseNetworkSession:remove_connection_from_trash]", wanted_ip)
		end

		self._trash_connections[wanted_ip] = nil

		if not next(self._trash_connections) then
			self._trash_connections = nil
		end
	end
end

function BaseNetworkSession:remove_connection_from_soft_remove_peers(rpc)
	if self._soft_remove_peers and self._soft_remove_peers[rpc:ip_at_index(0)] then
		self._soft_remove_peers[rpc:ip_at_index(0)] = nil

		if not next(self._soft_remove_peers) then
			self._soft_remove_peers = nil
		end
	end
end

function BaseNetworkSession:chk_send_local_player_ready()
	local state = self._local_peer:waiting_for_player_ready()

	if self:is_host() then
		self:send_to_peers_loaded("set_member_ready", self._local_peer:id(), state and 1 or 0, 1, "")
	else
		self:send_to_host("set_member_ready", self._local_peer:id(), state and 1 or 0, 1, "")
	end
end

function BaseNetworkSession:destroy()
	for _, peer in pairs(self._peers) do
		peer:end_ticket_session()
		peer:destroy()
	end

	self._local_peer:destroy()

	if self._dropin_complete_event_manager_id then
		EventManager:unregister_listener(self._dropin_complete_event_manager_id)

		self._dropin_complete_event_manager_id = nil
	end
end

function BaseNetworkSession:_flush_soft_remove_peers()
	if self._soft_remove_peers then
		for ip, peer_remove_info in pairs(self._soft_remove_peers) do
			cat_print("multiplayer_base", "[BaseNetworkSession:destroy] soft-removed peer", peer_remove_info.peer:id(), ip)
			peer_remove_info.peer:destroy()
		end
	end

	self._soft_remove_peers = nil
end

function BaseNetworkSession:on_load_complete(simulation)
	print("[BaseNetworkSession:on_load_complete]")

	if not simulation then
		self._local_peer:set_loading(false)

		for peer_id, peer in pairs(self._peers) do
			if peer:ip_verified() then
				peer:send("set_loading_state", false, self._load_counter)
			end
		end
	end

	if not setup.IS_START_MENU then
		if SystemInfo:platform() == Idstring("PS3") then
			PSN:set_online_callback(callback(self, self, "ps3_disconnect"))
		elseif SystemInfo:platform() == Idstring("PS4") then
			PSN:set_online_callback(callback(self, self, "ps4_disconnect"))
		end
	end
end

function BaseNetworkSession:psn_disconnected()
	if Global.game_settings.single_player then
		return
	end

	if game_state_machine:current_state().on_disconnected then
		game_state_machine:current_state():on_disconnected()
	end

	managers.network.voice_chat:destroy_voice(true)
end

function BaseNetworkSession:steam_disconnected()
	if Global.game_settings.single_player then
		return
	end

	if game_state_machine:current_state().on_disconnected then
		game_state_machine:current_state():on_disconnected()
	end

	managers.network.voice_chat:destroy_voice(true)
end

function BaseNetworkSession:xbox_disconnected()
	if Global.game_settings.single_player then
		return
	end

	if game_state_machine:current_state().on_disconnected then
		game_state_machine:current_state():on_disconnected()
	end

	managers.network.voice_chat:destroy_voice(true)
end

function BaseNetworkSession:ps4_disconnect(connected)
	managers.network.matchmake:psn_disconnected()

	if not connected then
		managers.platform:event("disconnect")
	end
end

function BaseNetworkSession:ps3_disconnect(connected)
	print("BaseNetworkSession ps3_disconnect", connected)

	if Global.game_settings.single_player then
		return
	end

	if not connected and not PSN:is_online() then
		if game_state_machine:current_state().on_disconnected then
			game_state_machine:current_state():on_disconnected()
		end

		managers.network.voice_chat:destroy_voice(true)
	end
end

function BaseNetworkSession:on_steam_p2p_ping(sender_rpc)
	local user_id = sender_rpc:ip_at_index(0)
	local peer = self:peer_by_user_id(user_id)

	if not peer then
		print("[BaseNetworkSession:on_steam_p2p_ping] unknown peer", user_id)

		return
	end

	if self._server_protocol ~= "TCP_IP" then
		print("[BaseNetworkSession:on_steam_p2p_ping] wrong server protocol", self._server_protocol)

		return
	end

	local final_rpc = self:resolve_new_peer_rpc(peer)

	if not final_rpc then
		return
	end

	if peer:rpc() and final_rpc:ip_at_index(0) == peer:rpc():ip_at_index(0) and final_rpc:protocol_at_index(0) == peer:rpc():protocol_at_index(0) then
		local sender_ip = Network:get_ip_address_from_user_id(user_id)

		print("[BaseNetworkSession:on_steam_p2p_ping] already had IP", peer:rpc():ip_at_index(0), peer:rpc():protocol_at_index(0))

		return
	end

	peer:set_rpc(final_rpc)
	Network:add_co_client(final_rpc)
	self:remove_connection_from_trash(final_rpc)
	self:remove_connection_from_soft_remove_peers(final_rpc)
	self:chk_send_connection_established(nil, user_id)
end

function BaseNetworkSession:chk_send_connection_established(name, user_id, peer)
	if SystemInfo:platform() == Idstring("PS3") or SystemInfo:platform() == Idstring("PS4") then
		peer = self:peer_by_name(name)

		if not peer then
			print("[BaseNetworkSession:chk_send_connection_established] no peer yet", name)

			return
		end

		local connection_info = managers.network.matchmake:get_connection_info(name)

		if not connection_info then
			print("[BaseNetworkSession:chk_send_connection_established] no connection_info yet", name)

			return
		end

		if connection_info.dead then
			if peer:id() ~= 1 then
				print("[BaseNetworkSession:chk_send_connection_established] reporting dead connection", name)

				if self._server_peer then
					self._server_peer:send_after_load("report_dead_connection", peer:id())
				end
			end

			return
		end

		local rpc = Network:handshake(connection_info.external_ip, connection_info.port, "TCP_IP")

		peer:set_rpc(rpc)
		Network:add_co_client(rpc)
		self:remove_connection_from_trash(rpc)
		self:remove_connection_from_soft_remove_peers(rpc)
	elseif SystemInfo:platform() == Idstring("XB1") then
		local xnaddr = managers.network.matchmake:internal_address(peer:xuid())

		if not xnaddr then
			return
		end

		peer:set_xnaddr(xnaddr)

		local rpc = Network:handshake(xnaddr, managers.network.DEFAULT_PORT, "TCP_IP")

		peer:set_rpc(rpc)
		Network:add_co_client(rpc)

		local player_info = {
			name = peer:name(),
			player_id = peer:xuid(),
			external_address = peer:xnaddr()
		}

		managers.network.voice_chat:open_channel_to(player_info, "game")
		self:remove_connection_from_trash(rpc)
		self:remove_connection_from_soft_remove_peers(rpc)
	else
		peer = peer or self:peer_by_user_id(user_id)

		if not peer then
			print("[BaseNetworkSession:chk_send_connection_established] no peer yet", user_id)

			return
		end

		if not peer:rpc() then
			print("[BaseNetworkSession:chk_send_connection_established] no rpc yet", user_id)

			return
		end
	end

	print("[BaseNetworkSession:chk_send_connection_established] success", name or "", user_id or "", peer:id())

	if self._server_peer then
		self._server_peer:send("connection_established", peer:id())
	end
end

function BaseNetworkSession:send_steam_p2p_msgs(wall_t)
	if self._server_protocol ~= "TCP_IP" then
		return
	end

	if SystemInfo:platform() ~= self._ids_WIN32 then
		return
	end

	for peer_id, peer in pairs(self._peers) do
		if peer ~= self._server_peer and not peer:ip_verified() and (not peer:next_steam_p2p_send_t() or peer:next_steam_p2p_send_t() < wall_t) then
			peer:steam_rpc():steam_p2p_ping()
			peer:set_next_steam_p2p_send_t(wall_t + self._STEAM_P2P_SEND_INTERVAL)
		end
	end
end

function BaseNetworkSession:resolve_new_peer_rpc(new_peer, incomming_rpc)
	if SystemInfo:platform() ~= self._ids_WIN32 then
		return incomming_rpc
	end

	local new_peer_ip_address = Network:get_ip_address_from_user_id(new_peer:user_id())

	print("new_peer_ip_address", new_peer_ip_address)

	if new_peer_ip_address then
		local new_peer_ip_address_split = string.split(new_peer_ip_address, ":")
		local new_peer_ip = new_peer_ip_address_split[1]
		local new_peer_port = new_peer_ip_address_split[2]
		local connect_port = new_peer_port

		print("new_peer_ip", new_peer_ip, "new_peer_port", new_peer_port)

		if string.begins(new_peer_ip, "192.168.") then
			print("using internal port", NetworkManager.DEFAULT_PORT)

			connect_port = NetworkManager.DEFAULT_PORT
		end

		return Network:handshake(new_peer_ip, connect_port, "TCP_IP")
	else
		Application:error("[BaseNetworkSession:resolve_new_peer_rpc] could not resolve IP address!!!")

		return incomming_rpc
	end
end

function BaseNetworkSession:are_peers_done_streaming()
	for peer_id, peer in pairs(self._peers) do
		if peer:synched() and not peer:is_streaming_complete() then
			return
		end
	end

	return true
end

function BaseNetworkSession:peer_streaming_status()
	local status = 100
	local peer_name = nil

	for peer_id, peer in pairs(self._peers) do
		local peer_status = peer:streaming_status()

		if peer_status <= status then
			peer_name = peer:name()
			status = peer_status
		end
	end

	return peer_name, status
end

function BaseNetworkSession:are_all_peer_assets_loaded()
	if not self._local_peer:is_outfit_loaded() then
		return false
	end

	for peer_id, peer in pairs(self._peers) do
		if peer:waiting_for_player_ready() and not peer:is_outfit_loaded() then
			print("[BaseNetworkSession:are_all_peer_assets_loaded] still loading outfit", peer_id)

			return false
		end
	end

	return true
end

function BaseNetworkSession:_get_peer_outfit_versions_str()
	local outfit_versions_str = ""

	for peer_id = 1, tweak_data.max_players do
		local peer = nil

		if peer_id == self._local_peer:id() then
			peer = self._local_peer
		else
			peer = self._peers[peer_id]
		end

		if peer and peer:waiting_for_player_ready() then
			outfit_versions_str = outfit_versions_str .. tostring(peer_id) .. "-" .. peer:outfit_version() .. "."
		end
	end

	return outfit_versions_str
end

function BaseNetworkSession:on_peer_outfit_loaded(peer)
	print("[BaseNetworkSession:on_peer_outfit_loaded]", inspect(peer))
end

function BaseNetworkSession:set_packet_throttling_enabled(state)
	for peer_id, peer in pairs(self._peers) do
		peer:set_throttling_enabled(state)
	end
end

function BaseNetworkSession:load_counter()
	return self._load_counter
end

function BaseNetworkSession:check_send_outfit(peer)
	if managers.blackmarket:signature() then
		if peer then
			peer:send_queued_sync("sync_outfit", managers.blackmarket:outfit_string(), self:local_peer():outfit_version(), managers.blackmarket:signature())
		else
			self:send_to_peers_loaded("sync_outfit", managers.blackmarket:outfit_string(), self:local_peer():outfit_version(), managers.blackmarket:signature())
		end
	end
end

function BaseNetworkSession:on_network_stopped()
	for k = 1, tweak_data.max_players do
		self:on_drop_in_pause_request_received(k, nil, false)

		local peer = self:peer(k)

		if peer then
			peer:unit_delete()
		end
	end

	if self._local_peer then
		self:on_drop_in_pause_request_received(self._local_peer:id(), nil, false)
	end
end

function BaseNetworkSession:on_peer_entered_lobby(peer)
	peer:set_in_lobby(true)

	if peer:ip_verified() then
		self._local_peer:sync_lobby_data(peer)
	end

	managers.network:dispatch_event("session_peer_entered_lobby", peer)
end

function BaseNetworkSession:on_entered_lobby()
	local id = self._local_peer:id()

	self._local_peer:set_in_lobby(true)

	if id ~= 1 then
		self:on_peer_entered_lobby(self:peer(1))
	end

	self:send_to_peers_loaded("set_peer_entered_lobby")
	cat_print("multiplayer_base", "BaseNetworkSession:on_entered_lobby", self._local_peer, id)
end

function BaseNetworkSession:check_peer_preferred_character(preferred_character)
	local free_characters = clone(CriminalsManager.character_names())

	for _, peer in pairs(self._peers_all) do
		local character = peer:character()

		table.delete(free_characters, character)
	end

	local preferreds = string.split(preferred_character, " ")

	for _, preferred in ipairs(preferreds) do
		if table.contains(free_characters, preferred) then
			return preferred
		end
	end

	local character = free_characters[math.random(#free_characters)]

	print("Player will be", character, "instead of", preferred_character)

	return character
end

function BaseNetworkSession:_has_client(peer)
	for i = 0, Network:clients():num_peers() - 1 do
		if Network:clients():ip_at_index(i) == peer:ip() then
			return true
		end
	end

	return false
end

function BaseNetworkSession:on_peer_loading(peer, state)
	cat_print("multiplayer_base", "[BaseNetworkSession:on_peer_loading]", inspect(peer), state)

	if Network:is_server() and not state then
		if not self:_has_client(peer) then
			Network:remove_co_client(peer:rpc())
			Network:add_client(peer:rpc())
		end

		if not NetworkManager.DROPIN_ENABLED then
			peer:on_sync_start()
			peer:chk_enable_queue()
			Network:drop_in(peer:rpc())
		end
	end

	if state and peer == self._server_peer then
		cat_print("multiplayer_base", "  SERVER STARTED LOADING", peer, peer:id())

		if self._local_peer:in_lobby() then
			local lobby_menu = managers.menu:get_menu("lobby_menu")

			if lobby_menu and lobby_menu.renderer:is_open() then
				lobby_menu.renderer:set_server_state("loading")
			end

			if managers.menu_scene then
				managers.menu_scene:set_server_loading()
			end

			if managers.menu_component then
				managers.menu_component:set_server_info_state("loading")
			end
		end
	end
end

function BaseNetworkSession:spawn_member_by_id(peer_id, spawn_point_id, is_drop_in)
	local peer = self:peer(peer_id)

	if peer then
		local character = peer:character()

		peer:spawn_unit(spawn_point_id, is_drop_in, character ~= "random" and character)
	end
end

function BaseNetworkSession:spawn_players(is_drop_in)
	if not managers.network:has_spawn_points() then
		return
	end

	if not self._spawn_point_beanbag then
		self:_create_spawn_point_beanbag()
	end

	if Network:is_server() then
		if not self._local_peer then
			return
		end

		local id = self:_get_next_spawn_point_id()

		for _, peer in pairs(self._peers) do
			local character = peer:character()

			if character ~= "random" then
				peer:spawn_unit(self:_get_next_spawn_point_id(), is_drop_in, character)
			end
		end

		local local_character = self._local_peer:character()

		self._local_peer:spawn_unit(id, false, local_character ~= "random" and local_character)

		for _, peer in pairs(self._peers) do
			local character = peer:character()

			if character == "random" then
				peer:spawn_unit(self:_get_next_spawn_point_id(), is_drop_in)
			end
		end

		self:set_game_started(true)
	end

	managers.groupai:state():fill_criminal_team_with_AI(is_drop_in)
end

function BaseNetworkSession:_get_next_spawn_point_id()
	local id = self._spawn_point_beanbag[self._next_i_spawn_point]

	if self._next_i_spawn_point == #self._spawn_point_beanbag then
		self._next_i_spawn_point = 1
	else
		self._next_i_spawn_point = self._next_i_spawn_point + 1
	end

	return id
end

function BaseNetworkSession:_create_spawn_point_beanbag()
	local spawn_points = managers.network._spawn_points
	local spawn_point_ids = {}
	self._spawn_point_beanbag = {}

	for sp_id, sp_data in pairs(spawn_points) do
		table.insert(spawn_point_ids, sp_id)
	end

	while #spawn_point_ids > 0 do
		local i_id = math.random(#spawn_point_ids)
		local random_id = spawn_point_ids[i_id]

		table.insert(self._spawn_point_beanbag, random_id)

		spawn_point_ids[i_id] = spawn_point_ids[#spawn_point_ids]

		table.remove(spawn_point_ids)
	end

	self._next_i_spawn_point = 1
end

function BaseNetworkSession:get_next_spawn_point()
	local id = self:_get_next_spawn_point_id()

	return managers.network:spawn_point(id)
end

function BaseNetworkSession:on_peer_sync_complete(peer, peer_id)
	if not self._local_peer then
		return
	end

	if not peer:ip_verified() then
		return
	end

	if peer:ip_verified() then
		self._local_peer:sync_lobby_data(peer)
		self._local_peer:sync_data(peer)
	end

	self:_update_peer_ready_gui(peer)

	if Network:is_server() then
		self:check_start_game_intro()
	end

	managers.network:dispatch_event("session_peer_sync_complete", peer)
end

function BaseNetworkSession:on_streaming_progress_received(peer, progress)
	if not peer:synched() then
		return
	end

	if progress == 100 then
		self:_update_peer_ready_gui(peer)

		if Network:is_server() then
			self:chk_spawn_member_unit(peer, peer:id())
		end
	else
		local kit_menu = managers.menu:get_menu("kit_menu")

		if kit_menu and kit_menu.renderer:is_open() then
			kit_menu.renderer:set_dropin_progress(peer:id(), peer:streaming_status(), "load")
		end
	end
end

function BaseNetworkSession:on_dropin_progress_received(dropin_peer_id, progress_percentage)
	local peer = self:peer(dropin_peer_id)

	if peer:synched() then
		return
	end

	local old_drop_in_prog = peer:drop_in_progress()

	if not old_drop_in_prog or old_drop_in_prog < progress_percentage then
		peer:set_drop_in_progress(progress_percentage)

		if game_state_machine:last_queued_state_name() == "ingame_waiting_for_players" then
			managers.menu:get_menu("kit_menu").renderer:set_dropin_progress(dropin_peer_id, progress_percentage, "join")
		else
			managers.menu:update_person_joining(dropin_peer_id, progress_percentage)
		end
	end
end

function BaseNetworkSession:on_set_member_ready(peer_id, ready, state_changed, from_network)
	print("[BaseNetworkSession:on_set_member_ready]", peer_id, ready, state_changed)

	local peer = self:peer(peer_id)
	local kit_menu = managers.menu:get_menu("kit_menu")

	if kit_menu and kit_menu.renderer:is_open() then
		if ready then
			kit_menu.renderer:set_slot_ready(peer, peer_id)
		else
			kit_menu.renderer:set_slot_not_ready(peer, peer_id)
		end
	end
end

function BaseNetworkSession:check_start_game_intro(skip_streamer_check)
	if not self:chk_all_handshakes_complete() then
		return
	end

	for _, peer in pairs(self._peers_all) do
		if not peer:waiting_for_player_ready() then
			print("[BaseNetworkSession:check_start_game_intro]", peer:id(), "not ready")

			return
		end

		if not peer:synched() then
			print("[BaseNetworkSession:check_start_game_intro]", peer:id(), "not synched")

			return
		end
	end

	if not self:chk_send_ready_to_unpause() then
		return
	end

	if game_state_machine:current_state().start_game_intro then
		game_state_machine:current_state():start_game_intro()
	end
end

function BaseNetworkSession:_update_peer_ready_gui(peer)
	if not peer:synched() or not peer:is_streaming_complete() then
		return
	end

	local kit_menu = managers.menu:get_menu("kit_menu")

	if kit_menu and kit_menu.renderer:is_open() then
		if peer:waiting_for_player_ready() then
			kit_menu.renderer:set_slot_ready(peer, peer:id())
		else
			kit_menu.renderer:set_slot_not_ready(peer, peer:id())
		end
	end
end

function BaseNetworkSession:on_drop_in_pause_request_received(peer_id, nickname, state)
	print("[BaseNetworkSession:on_drop_in_pause_request_received]", peer_id, nickname, state)

	local status_changed = false
	local is_playing = BaseNetworkHandler._gamestate_filter.any_ingame_playing[game_state_machine:last_queued_state_name()]

	if state then
		if not self:closing() then
			status_changed = true
			self._dropin_pause_info[peer_id] = nickname

			if is_playing then
				managers.menu:show_person_joining(peer_id, nickname)
			end
		end
	elseif self._dropin_pause_info[peer_id] then
		status_changed = true

		if peer_id == self._local_peer:id() then
			self._dropin_pause_info[peer_id] = nil

			managers.menu:close_person_joining(peer_id)
		else
			self._dropin_pause_info[peer_id] = nil

			managers.menu:close_person_joining(peer_id)
		end
	end

	if status_changed then
		if state then
			if not self:closing() then
				if table.size(self._dropin_pause_info) == 1 then
					print("DROP-IN PAUSE")
					Application:set_pause(true)
					SoundDevice:set_rtpc("ingame_sound", 0)
				end

				if Network:is_client() then
					self:send_to_host("drop_in_pause_confirmation", peer_id)
				end
			end
		elseif not next(self._dropin_pause_info) then
			print("DROP-IN UNPAUSE")
			Application:set_pause(false)
			SoundDevice:set_rtpc("ingame_sound", 1)
		else
			print("MAINTAINING DROP-IN UNPAUSE. # dropping peers:", table.size(self._dropin_pause_info))
		end
	end
end

function BaseNetworkSession:on_statistics_recieved(peer_id, peer_kills, peer_specials_kills, peer_head_shots, accuracy, downs)
	local peer = self:peer(peer_id)

	peer:set_statistics(peer_kills, peer_specials_kills, peer_head_shots, accuracy, downs)

	for _, peer in pairs(self._peers_all) do
		if peer:has_statistics() then
			-- Nothing
		elseif peer:waiting_for_player_ready() and not peer:has_statistics() then
			return
		end
	end

	local total_kills = 0
	local total_specials_kills = 0
	local total_head_shots = 0
	local best_killer = {
		score = 0
	}
	local best_special_killer = {
		score = 0
	}
	local best_accuracy = {
		score = 0
	}
	local group_accuracy = 0
	local group_downs = 0
	local most_downs = {
		score = 0
	}

	for _, peer in pairs(self._peers_all) do
		if peer:has_statistics() then
			local stats = peer:statistics()
			total_kills = total_kills + stats.total_kills
			total_specials_kills = total_specials_kills + stats.total_specials_kills
			total_head_shots = total_head_shots + stats.total_head_shots
			group_accuracy = group_accuracy + stats.accuracy
			group_downs = group_downs + stats.downs

			if best_killer.score < stats.total_kills or not best_killer.peer_id then
				best_killer.score = stats.total_kills
				best_killer.peer_id = peer:id()
			end

			if best_special_killer.score < stats.total_specials_kills or not best_special_killer.peer_id then
				best_special_killer.score = stats.total_specials_kills
				best_special_killer.peer_id = peer:id()
			end

			if best_accuracy.score < stats.accuracy or not best_accuracy.peer_id then
				best_accuracy.score = stats.accuracy
				best_accuracy.peer_id = peer:id()
			end

			if most_downs.score < stats.downs or not most_downs.peer_id then
				most_downs.score = stats.downs
				most_downs.peer_id = peer:id()
			end
		end
	end

	group_accuracy = math.floor(group_accuracy / table.size(self._peers_all))

	print("result is", "total_kills", total_kills, "total_specials_kills", total_specials_kills, "total_head_shots", total_head_shots)
	print(inspect(best_killer))
	print(inspect(best_special_killer))
	print(inspect(best_accuracy.peer_id))

	if game_state_machine:current_state().on_statistics_result then
		game_state_machine:current_state():on_statistics_result(best_killer.peer_id, best_killer.score, best_special_killer.peer_id, best_special_killer.score, best_accuracy.peer_id, best_accuracy.score, most_downs.peer_id, most_downs.score, total_kills, total_specials_kills, total_head_shots, group_accuracy, group_downs)
	end

	self:send_to_peers("sync_statistics_result", best_killer.peer_id, best_killer.score, best_special_killer.peer_id, best_special_killer.score, best_accuracy.peer_id, best_accuracy.score, most_downs.peer_id, most_downs.score, total_kills, total_specials_kills, total_head_shots, group_accuracy, group_downs)
end
