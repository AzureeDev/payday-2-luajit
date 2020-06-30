NetworkMatchMakingNX64 = NetworkMatchMakingNX64 or class()
NetworkMatchMakingNX64.OPEN_SLOTS = 4
NetworkMatchMakingNX64.MAX_SEARCH_RESULTS = 20

function NetworkMatchMakingNX64:init()
	cat_print("lobby", "matchmake = NetworkMatchMakingNX64")

	self._players = {}
	self._TRY_TIME_INC = 10
	self._NX64_TIMEOUT_INC = 20
	self._NX64_CHECK_INTERVAL = 10
	self._JOIN_SERVER_TRY_TIME_INC = self._NX64_TIMEOUT_INC + 30
	self._PERMITTED_SEARCH_FREQ = 12
	self._MAX_MAP_TIME = 300
	self._CONNECT_TIME_OUT = 120
	self._room_id = nil
	self._join_cb_room = nil
	self._server_rpc = nil
	self._is_server_var = false
	self._is_client_var = false
	self._difficulty_filter = 0
	self._private = false
	self._callback_map = {}
	self._hidden = false
	self._server_joinable = true
	self._connection_info = {}

	local function f(info)
		self:_error_cb(info)
	end

	NX64Online:set_matchmaking_callback("error", "NetworkMatchMakingNX64:init", f)
	self:_load_globals()

	self._cancelled = false
	self._peer_join_request_remove = {}

	local function js(...)
		self:cb_connection_established(...)
	end

	NX64Online:set_matchmaking_callback("connection_etablished", "NetworkMatchMakingNX64:init", js)

	self._network_untested = nil
	self._last_network_mode = nil

	local function g(data)
		print("[CNM] : network_good(", data.mode, ", ", data.init_id, ") - awaiting: ", self._network_awaiting_id)

		if data.init_id ~= self._network_awaiting_id then
			print("[CNM] : network_good for wrong init ignored")

			return
		end

		self._network_untested = nil
		self._last_network_mode = data.mode
		self._network_awaiting_id = -1
		self._connect_fail_time = nil

		managers.system_menu:close("connect_inet")
		managers.crimenet:enable_launch_features()
	end

	NX64Online:set_matchmaking_callback("network_good", "NetworkMatchMakingNX64:init", g)

	self._network_awaiting_id = -1
end

function NetworkMatchMakingNX64:_on_disconnect_detected()
	if managers.network:session() and managers.network:session():_local_peer_in_lobby() and not managers.network:session():closing() then
		managers.menu:nx64_disconnected()
	elseif managers.network:session() then
		managers.network:session():nx64_disconnected()
	elseif setup.IS_START_MENU then
		managers.menu:nx64_disconnect(false)
	end
end

function NetworkMatchMakingNX64:room_id()
	return self._room_id
end

function NetworkMatchMakingNX64:create_private_game(settings)
	self._cancelled = false
	self._private = true

	if Global.psn_invite_id then
		Global.psn_invite_id = Global.psn_invite_id + 1

		if Global.psn_invite_id > 990 then
			Global.psn_invite_id = 1
		end
	end

	self._last_settings = settings

	self:_create_server(true)
end

function NetworkMatchMakingNX64:cancel_find()
	self._cancelled = true
	self._is_server_var = false
	self._is_client_var = false
	self._players = {}
	self._server_rpc = nil
	self._try_list = nil
	self._try_index = nil
	self._trytime = nil

	self:destroy_game()

	self._room_id = nil

	if not self._join_cb_room then
		self:_call_callback("cancel_done")
	else
		self._cancel_time = TimerManager:wall():time() + 10
	end
end

function NetworkMatchMakingNX64:remove_ping_watch()
end

function NetworkMatchMakingNX64:leave_game()
	local sent = false

	self:remove_ping_watch()

	self._no_longer_in_session = nil

	if self:_is_client() then
		if self._server_rpc then
			sent = true
		end
	else
		for k, v in pairs(self._players) do
			if v.rpc then
				sent = true
			end
		end
	end

	if sent and managers.network:session() and not managers.network:session():closing() then
		if self._room_id then
			if not self._call_server_timed_out then
				self._leaving_timer = TimerManager:wall():time() + 10
			end

			if self:_is_client() then
				print("leave session HERE")
				NX64Online:leave_session(self._room_id)
			else
				print("destroy session HERE")
				NX64Online:destroy_session(self._room_id)
			end

			self._room_id = nil
			local dialog_data = {
				title = managers.localization:text("dialog_leaving_lobby_title"),
				text = managers.localization:text("dialog_wait"),
				id = "leaving_game",
				no_buttons = true
			}

			managers.system_menu:show(dialog_data)
		end

		self._leave_time = TimerManager:wall():time() + 2
	else
		self._leave_time = TimerManager:wall():time() + 0
	end
end

function NetworkMatchMakingNX64:register_callback(event, callback)
	self._callback_map[event] = callback
end

function NetworkMatchMakingNX64:join_game(id, private)
end

function NetworkMatchMakingNX64:start_game()
end

function NetworkMatchMakingNX64:end_game()
end

function NetworkMatchMakingNX64:destroy_game()
	if self._room_id then
		self._no_longer_in_session = nil

		if self:_is_client() then
			NX64Online:leave_session(self._room_id)
		else
			NX64Online:destroy_session(self._room_id)
		end

		self._room_id = nil
	else
		cat_print("multiplayer", "Dont got a room id!?")
	end
end

function NetworkMatchMakingNX64:is_game_owner()
	return self:_is_server() == true
end

function NetworkMatchMakingNX64:game_owner_name()
	return tostring(self._game_owner_name)
end

function NetworkMatchMakingNX64:is_full()
	if #self._players == self.OPEN_SLOTS - 1 then
		return true
	end

	return false
end

function NetworkMatchMakingNX64:get_mm_id(name)
	if name == managers.network.account:username() then
		return managers.network.account:player_id()
	else
		for k, v in pairs(self._players) do
			if v.name == name then
				return v.pnid
			end
		end
	end

	return nil
end

function NetworkMatchMakingNX64:user_in_lobby(id)
	if not self._room_id then
		return false
	end

	if not NX64Online:get_info_session(self._room_id) then
		return false
	end

	local memberlist = NX64Online:get_info_session(self._room_id).memberlist

	for _, member in ipairs(memberlist) do
		if member.user_id == id then
			return true
		end
	end

	return false
end

function NetworkMatchMakingNX64:reset_network_state()
	self._no_longer_in_session = nil
	Global.boot_invite = nil

	if self._joining_lobby then
		self:_joining_lobby_done()
	end

	if self._searching_lobbys then
		self:search_lobby_done()
	end

	if self._creating_lobby then
		self:_create_lobby_done()
	end

	if self._checking_server_attributes then
		self:check_server_attributes_done()
	end
end

function NetworkMatchMakingNX64:update(time)
	if self._connect_fail_time and self._connect_fail_time < TimerManager:wall():time() then
		self._network_untested = nil
		self._last_network_mode = "None"
		self._network_awaiting_id = -1

		managers.system_menu:close("connect_inet")

		if managers.menu:active_menu() then
			managers.menu:active_menu().logic:navigate_back(true)
		end

		managers.menu:show_no_connection_to_game_servers_dialog()

		self._connect_fail_time = nil
	end

	if self._callback_time and self._callback_time < TimerManager:wall():time() then
		self._callback_func()

		self._callback_time = nil
		self._callback_func = nil
	end

	if self._queue_end_game then
		self._queue_end_game = self._queue_end_game - 1

		if self._queue_end_game < 0 then
			print("EXITING FOR INVITE")

			self._queue_end_game = nil

			MenuCallbackHandler:_dialog_end_game_yes()
		end
	end

	if self._no_longer_in_session then
		if self._no_longer_in_session == 0 then
			if Network:is_client() and managers.network:session() and managers.network:session():server_peer() then
				if game_state_machine:current_state().on_server_left then
					Global.on_server_left_message = "dialog_connection_to_host_lost"

					game_state_machine:current_state():on_server_left()
				end
			elseif Network:is_server() and managers.network:session() and game_state_machine:current_state().on_disconnected then
				game_state_machine:current_state():on_disconnected()
			end

			self._no_longer_in_session = nil
		else
			self._no_longer_in_session = self._no_longer_in_session - 1
		end
	end

	local ct = TimerManager:wall():time()

	if self._trytime and self._trytime < ct then
		self._trytime = nil

		print("self._trytime run out!", inspect(self))

		local is_server = self._is_server_var
		self._is_server_var = false
		self._is_client_var = false

		managers.platform:set_presence("Signed_in")

		self._players = {}
		self._server_rpc = nil

		if self._room_id then
			if not is_server then
				print(" LEAVE SESSION BECAUSE OF TIME OUT", self._room_id)
				self:leave_game()
			end
		elseif not self._last_settings then
			self:_call_callback("cancel_done")
		end
	end

	if self._leave_time and self._leave_time < TimerManager:wall():time() then
		self._players = {}
		self._game_owner_id = nil
		self._game_owner_name = nil
		self._server_rpc = nil
		self._leave_time = nil
		self._is_client_var = false
		self._is_server_var = false

		if self._call_server_timed_out == true then
			self._call_server_timed_out = nil

			self:_call_callback("server_timedout")
		else
			print("left game callback")
			managers.system_menu:close("leaving_game")

			if self._invite_room_id then
				self:join_server_with_check(self._invite_room_id, true)
			end
		end
	end

	if self._leaving_timer and self._leaving_timer < TimerManager:wall():time() then
		print("self._leaving_timer left_game")
		managers.system_menu:close("leaving_game")

		self._room_id = nil
		self._leaving_timer = nil
	end

	if self._cancel_time and self._cancel_time < TimerManager:wall():time() then
		self._cancel_time = nil
		self._join_cb_room = nil

		self:_call_callback("cancel_done")
	end
end

function NetworkMatchMakingNX64:_load_globals()
	if Global.psn and Global.psn.match then
		self._game_owner_id = Global.psn.match._game_owner_id
		self._game_owner_name = Global.psn.match._game_owner_name
		self._room_id = Global.psn.match._room_id
		self._is_server_var = Global.psn.match._is_server
		self._is_client_var = Global.psn.match._is_client
		self._players = Global.psn.match._players
		self._server_rpc = Global.psn.match._server_ip and Network:handshake(Global.psn.match._server_ip, nil, "TCP_IP")
		self._attributes_numbers = Global.psn.match._attributes_numbers
		self._connection_info = Global.psn.match._connection_info
		self._hidden = Global.psn.match._hidden
		self._num_players = Global.psn.match._num_players
		Global.psn.match = nil

		if self._room_id then
			local info_session = NX64Online:get_info_session(self._room_id)

			if not info_session or #info_session.memberlist == 0 then
				self._no_longer_in_session = 1
			end
		end
	end
end

function NetworkMatchMakingNX64:_save_globals()
	if not Global.psn then
		Global.psn = {}
	end

	Global.psn.match = {
		_game_owner_id = self._game_owner_id,
		_game_owner_name = self._game_owner_name,
		_room_id = self._room_id,
		_is_server = self._is_server_var,
		_is_client = self._is_client_var,
		_players = self._players,
		_server_ip = self._server_rpc and self._server_rpc:ip_at_index(0),
		_attributes_numbers = self._attributes_numbers,
		_connection_info = self._connection_info,
		_hidden = self._hidden,
		_num_players = self._num_players
	}
end

function NetworkMatchMakingNX64:_call_callback(name, ...)
	if self._callback_map[name] then
		return self._callback_map[name](...)
	else
		Application:error("Callback " .. name .. " not found.")
	end
end

function NetworkMatchMakingNX64:_remove_peer_by_user_id(user_id)
	self._connection_info[user_id] = nil

	if not managers.network:session() then
		return
	end

	local user_name = tostring(user_id)

	for pid, peer in pairs(managers.network:session():peers()) do
		if peer:name() == user_name then
			print(" _remove_peer_by_user_id on_peer_left", peer:id(), pid)
			managers.network:session():on_peer_left(peer, pid)

			return
		end
	end

	if Network:is_server() then
		self._peer_join_request_remove[user_id] = true

		print("queue to remove if we get a request", user_id)
	end
end

function NetworkMatchMakingNX64:check_peer_join_request_remove(user_id)
	local has = self._peer_join_request_remove[user_id]
	self._peer_join_request_remove[user_id] = nil

	return has
end

function NetworkMatchMakingNX64:_is_server(set)
	if set == true or set == false then
		self._is_server_var = set
	else
		return self._is_server_var
	end
end

function NetworkMatchMakingNX64:_is_client(set)
	if set == true or set == false then
		self._is_client_var = set
	else
		return self._is_client_var
	end
end

function NetworkMatchMakingNX64:_game_version()
	return NX64Online:game_version()
end

function NetworkMatchMakingNX64:create_lobby(settings)
	print("NetworkMatchMakingNX64:create_group_lobby()", inspect(settings))

	self._server_joinable = true
	self._num_players = nil
	self._server_rpc = nil
	self._players = {}
	self._peer_join_request_remove = {}

	local function session_created(roomid)
		managers.network.matchmake:_created_lobby(roomid)
	end

	NX64Online:set_matchmaking_callback("session_created", "NetworkMatchMakingNX64:create_lobby", session_created)

	local numbers = settings and settings.numbers or {
		2,
		3,
		1,
		1,
		1,
		1,
		0,
		1
	}
	numbers[4] = 1
	numbers[5] = self:_game_version()
	numbers[8] = 1
	local table_description = {
		numbers = numbers
	}
	self._attributes_numbers = numbers
	local dialog_data = {
		title = managers.localization:text("dialog_creating_lobby_title"),
		text = managers.localization:text("dialog_wait"),
		id = "create_lobby",
		no_buttons = true
	}

	managers.system_menu:show(dialog_data)

	self._creating_lobby = true

	NX64Online:create_session(table_description, 0, self.OPEN_SLOTS, 0)
end

function NetworkMatchMakingNX64:_create_lobby_failed()
	self:_create_lobby_done()
end

function NetworkMatchMakingNX64:_create_lobby_done()
	self._creating_lobby = nil

	managers.system_menu:close("create_lobby")
end

function NetworkMatchMakingNX64:_created_lobby(room_id)
	self:_create_lobby_done()
	managers.menu:created_lobby()
	print("NetworkMatchMakingNX64:_created_lobby( room_id )", room_id)

	self._trytime = nil

	self:_is_server(true)
	self:_is_client(false)

	self._room_id = room_id

	managers.network.voice_chat:open_session(self._room_id)

	local playerinfo = {
		name = managers.network.account:username(),
		player_id = managers.network.account:player_id(),
		rpc = Network:self("TCP_IP")
	}

	self:_call_callback("found_game", self._room_id, true)
	self:_call_callback("player_joined", playerinfo)
end

function NetworkMatchMakingNX64:searching_friends_only()
	return self._friends_only
end

function NetworkMatchMakingNX64:difficulty_filter()
	return self._difficulty_filter
end

function NetworkMatchMakingNX64:set_difficulty_filter(filter)
	self._difficulty_filter = filter
end

function NetworkMatchMakingNX64:get_lobby_return_count()
end

function NetworkMatchMakingNX64:set_lobby_return_count(lobby_return_count)
end

function NetworkMatchMakingNX64:lobby_filters()
end

function NetworkMatchMakingNX64:set_lobby_filters(filters)
end

function NetworkMatchMakingNX64:add_lobby_filter(key, value, comparision_type)
end

function NetworkMatchMakingNX64:start_search_lobbys(friends_only)
	if self._network_untested then
		return
	end

	if self._joining_lobby then
		self:_call_callback("search_lobby", nil)

		return
	end

	if self._searching_lobbys then
		return
	end

	local t = TimerManager:wall():time()

	if self._permit_next_search ~= nil and t < self._permit_next_search then
		return
	end

	self._permit_next_search = t + self._PERMITTED_SEARCH_FREQ
	self._searching_lobbys = true
	self._lobbys_info_list = nil
	self._friends_only = friends_only

	local function f(info)
		print("--------------- search done")

		if self:is_inet_mode() then
			local t = TimerManager:wall():time()

			if self._map_expiration and self._map_expiration < t then
				print("[CNM] CrimeNet Online timeout")

				self._map_expiration = nil

				if managers.menu:active_menu() then
					managers.menu:active_menu().logic:navigate_back(true)
				end
			end
		end

		if self._friends_only then
			local friend_names = managers.network.friends:get_names_friends_list()
			local friends_rooms = {}

			for _, room in ipairs(info) do
				local is_friend = friend_names[tostring(room.owner_id)] and true or false

				if is_friend then
					table.insert(friends_rooms, room)
				end
			end

			self:_call_callback("search_lobby", friends_rooms)
		else
			self:_call_callback("search_lobby", info)
		end
	end

	NX64Online:set_matchmaking_callback("session_search", "NetworkMatchMakingNX64:start_search_lobbys", f)
	self:search_lobby()
end

function NetworkMatchMakingNX64:search_lobby(settings)
	if self._network_untested then
		return
	end

	NX64Online:search_session()
end

function NetworkMatchMakingNX64:_search_lobby_failed()
	self:search_lobby_done()
end

function NetworkMatchMakingNX64:search_lobby_done()
	self._searching_lobbys = nil

	managers.system_menu:close("find_server")
end

function NetworkMatchMakingNX64:set_num_players(num)
	self._num_players = num

	if self._attributes_numbers then
		self:_set_attributes()
	end
end

function NetworkMatchMakingNX64:_set_attributes(settings)
	if not self._room_id then
		return
	end

	self._attributes_numbers = settings and settings.numbers or self._attributes_numbers
	local numbers = self._attributes_numbers
	numbers[8] = self._num_players or 1
	local attributes = {
		numbers = numbers
	}

	NX64Online:set_session_attributes(self._room_id, attributes)
end

function NetworkMatchMakingNX64:set_server_attributes(settings)
	if not self._room_id then
		return
	end

	self._attributes_numbers[1] = settings.numbers[1]
	self._attributes_numbers[2] = settings.numbers[2]
	self._attributes_numbers[3] = settings.numbers[3]
	self._attributes_numbers[6] = settings.numbers[6]
	self._attributes_numbers[7] = settings.numbers[7]

	self:_set_attributes({
		numbers = self._attributes_numbers
	})
end

function NetworkMatchMakingNX64:set_server_state(state)
	if not self._room_id then
		return
	end

	local state_id = tweak_data:server_state_to_index(state)
	self._attributes_numbers[4] = state_id

	self:_set_attributes({
		numbers = self._attributes_numbers
	})
end

function NetworkMatchMakingNX64:server_state_name()
	return tweak_data:index_to_server_state(self._attributes_numbers[4])
end

function NetworkMatchMakingNX64:test_search()
	local function f(info)
		print(inspect(info))
		print(inspect(info.room_list[1]))
		print(inspect(info.room_list[1].owner_id))
		print(help(info.room_list[1].owner_id))
		print(inspect(info.room_list[1].room_id))
		print(help(info.room_list[1].room_id))
		print(inspect(NX64Online:get_info_session(info.room_list[1].room_id)))
	end

	NX64Online:set_matchmaking_callback("session_search", "NetworkMatchMakingNX64:test_search", f)
end

function NetworkMatchMakingNX64:nx_join_via_invitation_list(invitation, join_cb)
	if managers.dlc:is_installing() then
		managers.menu:show_game_is_installing()

		return false
	end

	if game_state_machine:current_state_name() ~= "menu_main" then
		if self._room_id == invitation.room_id then
			return false
		end

		Global.boot_invite = invitation
		Global.boot_invite.used = false
		Global.boot_invite.pending = true
		self._queue_end_game = 15

		return true
	end

	if setup:has_queued_exec() then
		Global.boot_invite.used = false
		Global.boot_invite.pending = true

		return false
	end

	managers.menu:open_sign_in_menu(function (success)
		if not success then
			join_cb(false)

			return
		end

		if not invitation.room_id or invitation.room_id:is_empty() then
			managers.menu:show_invite_wrong_room_message()
			join_cb(false)

			return
		end

		print("SELF ", self._room_id, " INVITE ", invitation.room_id)

		if self._room_id == invitation.room_id then
			join_cb(false)

			return
		end

		if invitation.version and invitation.version ~= self:_game_version() then
			managers.menu:show_invite_wrong_version_message()
			join_cb(false)

			return
		end

		join_cb(true)
		self:_join_invite_accepted(invitation.room_id)
	end)

	return 1
end

function NetworkMatchMakingNX64:join_boot_invite()
	print("[NetworkMatchMakingNX64:join_boot_invite]", inspect(Global.boot_invite))

	if not Global.boot_invite.pending then
		return
	end

	Global.boot_invite.used = true
	Global.boot_invite.pending = false

	if managers.dlc:is_installing() then
		managers.menu:show_game_is_installing()

		return
	end

	local message = Global.boot_invite

	if not message then
		print("[NetworkMatchMakingNX64:join_boot_invite] NX64Online:get_boot_invitation failed")

		return
	end

	print("[NetworkMatchMakingNX64:join_boot_invite] message: ", message)

	for i, k in pairs(message) do
		print(i, k)
	end

	print("JSELF ", self._room_id, " INVITE ", message.room_id)

	if self._room_id == message.room_id then
		print("[NetworkMatchMakingNX64:join_boot_invite] we are already joined")

		return
	end

	if message.version ~= self:_game_version() then
		print("[NetworkMatchMakingNX64:join_boot_invite] WRONG VERSION, INFORM USER")
		managers.menu:show_invite_wrong_version_message()

		return
	end

	Global.game_settings.single_player = false

	self:_join_invite_accepted(message.room_id)
end

function NetworkMatchMakingNX64:is_server_ok(friends_only, owner_id, attributes_numbers, skip_permission_check)
	local permission = attributes_numbers and tweak_data:index_to_permission(attributes_numbers[3]) or "public"

	if (attributes_numbers[6] <= 0 or not NetworkManager.DROPIN_ENABLED) and attributes_numbers[4] ~= 1 then
		print("[NetworkMatchMakingNX64:is_server_ok] Discard server due to drop in state")

		return false, 1
	end

	if managers.experience:current_level() < attributes_numbers[7] then
		print("[NetworkMatchMakingNX64:is_server_ok] Discard server due to reputation level limit")

		return false, 3
	end

	if skip_permission_check or permission == "public" then
		return true
	end

	if permission == "friends_only" then
		if not managers.network.friends:is_friend(owner_id) then
			print("[NetworkMatchMakingNX64:is_server_ok] Discard server cause friends only perimssion")
		end

		return managers.network.friends:is_friend(owner_id), 2
	end

	print("[NetworkMatchMakingNX64:is_server_ok] Discard server")

	return false, 2
end

function NetworkMatchMakingNX64:check_server_attributes_failed()
	self:check_server_attributes_done()
end

function NetworkMatchMakingNX64:check_server_attributes_done()
	self._checking_server_attributes = nil
	self._check_room_id = nil
end

function NetworkMatchMakingNX64:join_server_with_check(room_id, skip_permission_check)
	self._joining_lobby = true

	if not managers.system_menu:is_active_by_id("join_server") then
		managers.menu:show_joining_lobby_dialog()
	end

	self._check_room_id = room_id
	self._checking_server_attributes = true

	local function f(results)
		if self._check_room_id == nil then
			self:_joining_lobby_done()
		end

		local room_id = self._check_room_id

		self:check_server_attributes_done()

		local room_info = results[1]

		if room_info == nil then
			self:_joining_lobby_done()
			managers.menu:show_failed_joining_dialog()
			managers.network.matchmake:start_search_lobbys(self._friends_only)

			return
		end

		local owner_id = room_info.owner_id
		local server_ok, ok_error = self:is_server_ok(nil, owner_id, room_info.numbers, skip_permission_check)

		if server_ok then
			self:join_server(room_id)
		else
			self:_joining_lobby_done()

			if ok_error == 1 then
				managers.menu:show_game_started_dialog()
			elseif ok_error == 2 then
				managers.menu:show_game_permission_changed_dialog()
			elseif ok_error == 3 then
				managers.menu:show_too_low_level()
			elseif ok_error == 4 then
				managers.menu:show_does_not_own_heist()
			end

			managers.network.matchmake:start_search_lobbys(self._friends_only)
		end
	end

	local wanted_attributes = {
		numbers = {
			1,
			2,
			3,
			4,
			5,
			6,
			7,
			8
		}
	}

	print("XXX : get_session_attributes from : join_server_with_check")
	NX64Online:get_session_attributes({
		room_id
	}, f)
end

function NetworkMatchMakingNX64:map_active(v)
	if v then
		self._map_expiration = TimerManager:wall():time() + self._MAX_MAP_TIME
		self._last_search_results_seen = nil
	end
end

function NetworkMatchMakingNX64:join_server(room_id)
	self:_join_server(room_id)
end

function NetworkMatchMakingNX64:_join_server(room_id)
	self._connection_info = {}
	self._joining_lobby = true
	self._server_rpc = nil
	self._players = {}

	self:_is_server(false)
	self:_is_client(true)

	self._room_id = room_id

	if not managers.system_menu:is_active_by_id("join_server") then
		managers.menu:show_joining_lobby_dialog()
	end

	self._join_cb_room = self._room_id

	NX64Online:join_session(room_id)

	self._trytime = TimerManager:wall():time() + self._JOIN_SERVER_TRY_TIME_INC
end

function NetworkMatchMakingNX64:_joining_lobby_done_failed()
	self:_joining_lobby_done()
end

function NetworkMatchMakingNX64:_joining_lobby_done()
	managers.system_menu:close("join_server")

	self._joining_lobby = nil
end

function NetworkMatchMakingNX64:on_peer_added(peer)
	print("NetworkMatchMakingNX64:on_peer_added")
end

function NetworkMatchMakingNX64:on_peer_removed(peer)
	managers.network.voice_chat:close_channel_to(peer)
end

function NetworkMatchMakingNX64:cb_connection_established(info)
	if self._is_server_var then
		return
	end

	print("NetworkMatchMakingNX64:cb_connection_established")
	print(inspect(info))
	print("connection established to", info.user_id)

	self._connection_info[tostring(info.user_id)] = info

	if info.dead then
		if managers.network:session() then
			local peer = managers.network:session():peer_by_name(tostring(info.user_id))

			if peer then
				managers.network:session():on_peer_lost(peer, peer:id())
			end
		end

		if tostring(info.user_id) == managers.network.account:player_id() then
			self._room_id = nil
		end

		return
	end

	self._invite_room_id = nil

	if info.room_id == self._room_id and info.user_id == info.owner_id then
		self:_joining_lobby_done()

		self._room_id = info.room_id
		self._game_owner_id = info.owner_id
		self._game_owner_name = info.owner_name

		if info.external_ip and info.port then
			self._server_rpc = Network:handshake(info.external_ip, info.port, "TCP_IP")

			if not self._server_rpc then
				self._trytime = TimerManager:wall():time()

				return
			end
		else
			self._trytime = TimerManager:wall():time()

			return
		end

		self._trytime = nil

		managers.network:start_client()
		managers.network.voice_chat:open_session(self._room_id)
		managers.menu:show_waiting_for_server_response({
			cancel_func = function ()
				if managers.network:session() then
					managers.network:session():on_join_request_cancelled()
				end
			end
		})

		local function f(res, level_index, difficulty_index, state_index)
			managers.system_menu:close("waiting_for_server_response")

			if res == "JOINED_LOBBY" then
				MenuCallbackHandler:crimenet_focus_changed(nil, false)
				managers.menu:on_enter_lobby()
			elseif res == "JOINED_GAME" then
				managers.network.voice_chat:set_drop_in({
					room_id = self._room_id
				})

				local level_id = tweak_data.levels:get_level_name_from_index(level_index)
				Global.game_settings.level_id = level_id
			elseif res == "KICKED" then
				managers.network.matchmake:leave_game()
				managers.network.voice_chat:destroy_voice()
				managers.network:queue_stop_network()
				managers.menu:show_peer_kicked_dialog()
			elseif res == "TIMED_OUT" or res == "FAILED_CONNECT" or res == "AUTH_FAILED" or res == "AUTH_HOST_FAILED" then
				managers.network.matchmake:leave_game()
				managers.network.voice_chat:destroy_voice()
				managers.network:queue_stop_network()
				managers.menu:show_request_timed_out_dialog()
			elseif res == "GAME_STARTED" then
				managers.network.matchmake:leave_game()
				managers.network.voice_chat:destroy_voice()
				managers.network:queue_stop_network()
				managers.menu:show_game_started_dialog()
			elseif res == "DO_NOT_OWN_HEIST" then
				managers.network.matchmake:leave_game()
				managers.network.voice_chat:destroy_voice()
				managers.network:queue_stop_network()
				managers.menu:show_does_not_own_heist()
			elseif res == "CANCELLED" then
				managers.network.matchmake:leave_game()
				managers.network.voice_chat:destroy_voice()
				managers.network:queue_stop_network()
			elseif res == "GAME_FULL" then
				managers.network.matchmake:leave_game()
				managers.network.voice_chat:destroy_voice()
				managers.network:queue_stop_network()
				managers.menu:show_game_is_full()
			elseif res == "LOW_LEVEL" then
				managers.network.matchmake:leave_game()
				managers.network.voice_chat:destroy_voice()
				managers.network:queue_stop_network()
				managers.menu:show_too_low_level()
			elseif res == "WRONG_VERSION" then
				managers.network.matchmake:leave_game()
				managers.network.voice_chat:destroy_voice()
				managers.network:queue_stop_network()
				managers.menu:show_wrong_version_message()
			else
				Application:error("[NetworkMatchMakingNX64:connect_to_host_rpc] FAILED TO START MULTIPLAYER!")
			end
		end

		managers.network:join_game_at_host_rpc(self._server_rpc, f)
	elseif info and managers.network:session() then
		managers.network:session():on_NX64_connection_established(tostring(info.user_id), info.external_ip .. ":" .. info.port)
	end

	if self._join_cb_room and info.room_id == self._join_cb_room then
		if self._cancelled == true then
			self._cancel_time = nil

			self:_call_callback("cancel_done")
		end

		self._join_cb_room = nil
	end
end

function NetworkMatchMakingNX64:get_connection_info(npid_name)
	return self._connection_info[npid_name]
end

function NetworkMatchMakingNX64:_in_list(id)
	for k, v in pairs(self._players) do
		if tostring(v.pnid) == tostring(id) then
			return true
		end
	end

	return false
end

function NetworkMatchMakingNX64:_translate_settings(settings, value)
	if value == "game_mode" then
		local game_mode_in_settings = settings.game_mode

		if game_mode_in_settings == "coop" then
			return 1
		end

		Application:error("Not a supported game mode")
	end
end

function NetworkMatchMakingNX64:_error_cb(info)
	if not Global._ready_for_error_cb then
		return
	end

	if info then
		print(" _error_cb:", info.error_description, " init_id:", info.init_id, " task: ", info.task_name)
		managers.system_menu:close("join_server")
		managers.system_menu:close("crimenet_welcome")

		if self._network_untested then
			if info.init_id ~= self._network_awaiting_id then
				if info.init_id and self._network_awaiting_id < info.init_id then
					print("[CNM] WARNING newer init_id than the one we are waiting for seen")
				end

				return
			end

			managers.system_menu:close("connect_inet")

			if managers.menu:active_menu() then
				managers.menu:active_menu().logic:navigate_back(true)
			end

			self._connect_fail_time = nil

			return
		end

		managers.system_menu:close("nx_invitation_accept")
		managers.system_menu:close("nx_invitation_list")

		if self._checking_server_attributes then
			self:check_server_attributes_failed()
		end

		if self._searching_lobbys then
			self:_search_lobby_failed()
		end

		if self._creating_lobby then
			self:_create_lobby_failed()
		end

		if self._joining_lobby then
			self:_joining_lobby_done_failed()
		end

		local known_error = false

		if info.error_description == 6 or info.error_description == 32 then
			self:_on_disconnect_detected()

			known_error = true
		end

		if info.error_description == 78 then
			managers.menu:show_room_contains_blocked_player()

			known_error = true
		end

		if info.error_description == 75 then
			managers.menu:show_game_no_longer_exists()

			if self._check_room_id then
				managers.menu_component:remove_crimenet_gui_job(self._check_room_id)
				self:check_server_attributes_done()
			end

			known_error = true
		end

		if info.error_description == 57 then
			if self._check_room_id then
				managers.menu_component:remove_crimenet_gui_job(self._check_room_id)
				self:check_server_attributes_done()
			end

			known_error = true
		end

		if info.error_description == 76 or info.error_description == 83 then
			managers.menu:show_game_is_full()

			known_error = true
		end

		if info.error_description == 86 then
			known_error = true

			return
		end

		self._invite_room_id = nil
		self._room_id = nil
	end
end

function NetworkMatchMakingNX64:send_join_invite(friend, name)
	if not self._room_id then
		return
	end

	local dialog_data = {
		title = managers.localization:text("dialog_mp_send_invite_title"),
		text = managers.localization:text("dialog_mp_send_invite_message", {
			FRIEND = name
		})
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = function ()
			NX64Online:send_invite_message(friend)
		end
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = function ()
		end
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function NetworkMatchMakingNX64:_recived_join_invite(message)
	self._has_pending_invite = true

	print("_recived_join_invite")

	local dialog_data = {
		title = managers.localization:text("dialog_mp_groupinvite_title"),
		text = managers.localization:text("dialog_mp_groupinvite_message", {
			GROUP = tostring(message.sender)
		})
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = callback(self, self, "_join_invite_accepted", message.room_id)
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = function ()
			self._has_pending_invite = nil
		end
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function NetworkMatchMakingNX64:_join_invite_accepted(room_id)
	print("_join_invite_accepted", room_id)

	Global.game_settings.single_player = false
	self._has_pending_invite = nil
	self._invite_room_id = room_id

	if self._room_id then
		print("MUST LEAVE ROOM")
		MenuCallbackHandler:_dialog_leave_lobby_yes()

		return
	end

	managers.system_menu:force_close_all()
	self:join_server_with_check(room_id, true)
end

function NetworkMatchMakingNX64:_set_room_hidden(set)
	if set == self._hidden or not self._room_id then
		return
	end

	NX64Online:set_session_open(self._room_id, not set)

	self._hidden = set
end

function NetworkMatchMakingNX64:_server_timed_out(rpc)
end

function NetworkMatchMakingNX64:_client_timed_out(rpc)
	for k, v in pairs(self._players) do
		if v.rpc:ip_at_index(0) == rpc:ip_at_index(0) then
			return
		end
	end
end

function NetworkMatchMakingNX64:set_server_joinable(state)
	if self:_is_server() then
		self._server_joinable = state

		self:_set_room_hidden(not state)
	end
end

function NetworkMatchMakingNX64:is_server_joinable()
	return self._server_joinable
end

function NetworkMatchMakingNX64:set_inet_mode(retry, suppress_message)
	self._network_untested = true

	if not suppress_message and not managers.system_menu:is_active_by_id("connect_inet") then
		managers.menu:show_inet_connection_dialog_nx64()
	end

	self._network_awaiting_id = NX64Online:set_inet_mode(retry)

	if self._last_network_mode ~= "Inet" then
		self:reset_network_state()
	end

	Global._ready_for_error_cb = true

	if retry then
		self._connect_fail_time = TimerManager:wall():time() + self._CONNECT_TIME_OUT
	end
end

function NetworkMatchMakingNX64:is_inet_mode()
	return NX64Online:is_inet_mode()
end

function NetworkMatchMakingNX64:set_local_mode()
	self._network_untested = true

	if not managers.system_menu:is_active_by_id("connect_inet") then
		managers.menu:show_inet_connection_dialog_nx64()
	end

	self._network_awaiting_id = NX64Online:set_local_mode()

	if self._last_network_mode ~= "Local" then
		self:reset_network_state()
	end

	self._connect_fail_time = TimerManager:wall():time() + self._CONNECT_TIME_OUT
end

function NetworkMatchMakingNX64:is_local_mode()
	return NX64Online:is_local_mode()
end

function NetworkMatchMakingNX64:in_game()
	return self:_is_client() or self:_is_server()
end

function NetworkMatchMakingNX64:timed_callback(delay, func)
	self._callback_time = TimerManager:wall():time() + delay
	self._callback_func = func
end
