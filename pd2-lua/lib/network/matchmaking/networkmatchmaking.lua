NetworkMatchMaking = NetworkMatchMaking or class()
NetworkMatchMaking.OPEN_SLOTS = 4
NetworkMatchMaking._BUILD_SEARCH_INTEREST_KEY = "payday2_overkill_1"

function NetworkMatchMaking:init()
	cat_print("lobby", "matchmake = NetworkMatchMaking")

	self._callback_map = {}
	self._lobby_filters = {}
	self._distance_filter = -1
	self._difficulty_filter = 0
	self._lobby_return_count = 30
	self._try_re_enter_lobby = nil
	self._server_joinable = true
end

function NetworkMatchMaking:register_callback(event, callback)
	self._callback_map[event] = callback
end

function NetworkMatchMaking:_call_callback(name, ...)
	if self._callback_map[name] then
		return self._callback_map[name](...)
	else
		Application:error("Callback " .. name .. " not found.")
	end
end

function NetworkMatchMaking:_has_callback(name)
	if self._callback_map[name] then
		return true
	end

	return false
end

function NetworkMatchMaking:_split_attribute_number(attribute_number, splitter)
	if not splitter or splitter == 0 or type(splitter) ~= "number" then
		Application:error("NetworkMatchMaking:_split_attribute_number. splitter needs to be a non 0 number!", "attribute_number", attribute_number, "splitter", splitter)
		Application:stack_dump()

		return 1, 1
	end

	return attribute_number % splitter, math.floor(attribute_number / splitter)
end

function NetworkMatchMaking:destroy_game()
	self:leave_game()
end

function NetworkMatchMaking:_load_globals()
	if Global.empty and Global.empty.match then
		self.lobby_handler = Global.empty.match.lobby_handler
		self._lobby_attributes = Global.empty.match.lobby_attributes

		if self.lobby_handler then
			self.lobby_handler:setup_callbacks(NetworkMatchMaking._on_memberstatus_change, NetworkMatchMaking._on_data_update, NetworkMatchMaking._on_chat_message)
		end

		self._try_re_enter_lobby = Global.empty.match.try_re_enter_lobby
		self._server_rpc = Global.empty.match.server_rpc
		self._lobby_filters = Global.empty.match.lobby_filters or self._lobby_filters
		self._distance_filter = Global.empty.match.distance_filter or self._distance_filter
		self._difficulty_filter = Global.empty.match.difficulty_filter or self._difficulty_filter
		self._lobby_return_count = Global.empty.match.lobby_return_count or self._lobby_return_count
		Global.empty.match = nil
	end
end

function NetworkMatchMaking:_save_globals()
	if not Global.empty then
		Global.empty = {}
	end

	Global.empty.match = {
		lobby_handler = self.lobby_handler,
		lobby_attributes = self._lobby_attributes,
		try_re_enter_lobby = self._try_re_enter_lobby,
		server_rpc = self._server_rpc,
		lobby_filters = self._lobby_filters,
		distance_filter = self._distance_filter,
		difficulty_filter = self._difficulty_filter,
		lobby_return_count = self._lobby_return_count
	}
end

function NetworkMatchMaking:load_user_filters()
	Global.game_settings.search_friends_only = managers.user:get_setting("crimenet_filter_friends_only")
	Global.game_settings.search_appropriate_jobs = managers.user:get_setting("crimenet_filter_level_appopriate")
	Global.game_settings.search_mutated_lobbies = managers.user:get_setting("crimenet_filter_mutators")
	Global.game_settings.gamemode_filter = managers.user:get_setting("crimenet_gamemode_filter")
	Global.game_settings.crime_spree_max_lobby_diff = managers.user:get_setting("crime_spree_lobby_diff")
	local new_servers = managers.user:get_setting("crimenet_filter_new_servers_only")
	local in_lobby = managers.user:get_setting("crimenet_filter_in_lobby")
	local max_servers = managers.user:get_setting("crimenet_filter_max_servers")
	local distance = managers.user:get_setting("crimenet_filter_distance")
	local difficulty = managers.user:get_setting("crimenet_filter_difficulty")
	local job_id = managers.user:get_setting("crimenet_filter_contract")
	local kick = managers.user:get_setting("crimenet_filter_kick")
	local tactic = managers.user:get_setting("crimenet_filter_tactic")

	managers.network.matchmake:add_lobby_filter("state", in_lobby, "equal")
	managers.network.matchmake:set_lobby_return_count(max_servers)
	managers.network.matchmake:add_lobby_filter("num_players", new_servers, "equal")
	managers.network.matchmake:set_distance_filter(managers.user:get_setting("crimenet_filter_distance"))
	managers.network.matchmake:add_lobby_filter("difficulty", difficulty, "equal")
	managers.network.matchmake:add_lobby_filter("job_id", job_id, "equal")
	managers.network.matchmake:add_lobby_filter("kick_option", kick, "equal")
	managers.network.matchmake:add_lobby_filter("job_plan", tactic, "equal")
end

function NetworkMatchMaking:set_join_invite_pending(lobby_id)
	self._join_invite_pending = lobby_id
end

function NetworkMatchMaking:update()
	if self._try_re_enter_lobby then
		if self._try_re_enter_lobby == "lost" then
			Application:error("REQUESTING RE-OPEN LOBBY")
			self._server_rpc:re_open_lobby_request(true)

			self._try_re_enter_lobby = "asked"
		elseif self._try_re_enter_lobby == "asked" then
			-- Nothing
		elseif self._try_re_enter_lobby == "open" then
			self._try_re_enter_lobby = "joining"

			Application:error("RE-ENTERING LOBBY", self.lobby_handler:id())

			local function _join_lobby_result_f(result, handler)
				if result == "success" then
					Application:error("SUCCESS!")

					self.lobby_handler = handler

					self._server_rpc:re_open_lobby_request(false)

					self._try_re_enter_lobby = nil
				else
					Application:error("FAIL!")

					self._try_re_enter_lobby = "open"
				end
			end
		end
	end

	if self._join_invite_pending and not managers.network:session() then
		managers.network.matchmake:join_server_with_check(self._join_invite_pending, true)

		self._join_invite_pending = nil
	end
end

function NetworkMatchMaking:leave_game()
	self._server_rpc = nil

	if self.lobby_handler then
		self.lobby_handler:leave_lobby()
	end

	self.lobby_handler = nil
	self._server_joinable = true

	if self._try_re_enter_lobby then
		self._try_re_enter_lobby = nil
	end

	print("NetworkMatchMaking:leave_game()")
end

function NetworkMatchMaking:get_friends_lobbies()
	local lobbies = {}
	local num_updated_lobbies = 0

	local function is_key_valid(key)
		return key ~= "value_missing" and key ~= "value_pending"
	end

	local function empty()
	end

	local function f(updated_lobby)
		updated_lobby:setup_callback(empty)
		print("NetworkMatchMaking:get_friends_lobbies f")

		num_updated_lobbies = num_updated_lobbies + 1

		if num_updated_lobbies >= #lobbies then
			local info = {
				room_list = {},
				attribute_list = {}
			}

			for _, lobby in ipairs(lobbies) do
				if NetworkMatchMaking._BUILD_SEARCH_INTEREST_KEY then
					local ikey = lobby:key_value(NetworkMatchMaking._BUILD_SEARCH_INTEREST_KEY)

					if ikey ~= "value_missing" and ikey ~= "value_pending" then
						table.insert(info.room_list, {
							owner_id = lobby:key_value("owner_id"),
							owner_name = lobby:key_value("owner_name"),
							room_id = lobby:id()
						})

						local attributes_data = {
							numbers = self:_lobby_to_numbers(lobby),
							mutators = lobby:key_value("mutators")
						}
						local crime_spree_key = lobby:key_value("crime_spree")

						if is_key_valid(crime_spree_key) then
							attributes_data.crime_spree = crime_spree_key
						end

						table.insert(info.attribute_list, attributes_data)
					end
				end
			end

			self:_call_callback("search_lobby", info)
		end
	end

	if #lobbies == 0 then
		local info = {
			room_list = {},
			attribute_list = {}
		}

		self:_call_callback("search_lobby", info)
	else
		for _, lobby in ipairs(lobbies) do
			lobby:setup_callback(f)

			if lobby:key_value("state") == "value_pending" then
				print("NetworkMatchMaking:get_friends_lobbies value_pending")
				lobby:request_data()
			else
				f(lobby)
			end
		end
	end
end

function NetworkMatchMaking:search_friends_only()
	return self._search_friends_only
end

function NetworkMatchMaking:distance_filter()
	return self._distance_filter
end

function NetworkMatchMaking:set_distance_filter(filter)
	self._distance_filter = filter
end

function NetworkMatchMaking:get_lobby_return_count()
	return self._lobby_return_count
end

function NetworkMatchMaking:set_lobby_return_count(lobby_return_count)
	self._lobby_return_count = lobby_return_count
end

function NetworkMatchMaking:lobby_filters()
	return self._lobby_filters
end

function NetworkMatchMaking:set_lobby_filters(filters)
	self._lobby_filters = filters or {}
end

function NetworkMatchMaking:add_lobby_filter(key, value, comparision_type)
	self._lobby_filters[key] = {
		key = key,
		value = value,
		comparision_type = comparision_type
	}
end

function NetworkMatchMaking:get_lobby_filter(key)
	return self._lobby_filters[key] and self._lobby_filters[key].value or false
end

function NetworkMatchMaking:difficulty_filter()
	return self._difficulty_filter
end

function NetworkMatchMaking:set_difficulty_filter(filter)
	self._difficulty_filter = filter
end

function NetworkMatchMaking:search_lobby(friends_only)
	self._search_friends_only = friends_only

	if not self:_has_callback("search_lobby") then
		return
	end

	local function is_key_valid(key)
		return key ~= "value_missing" and key ~= "value_pending"
	end

	if friends_only then
		self:get_friends_lobbies()
	else
		local function refresh_lobby()
			if not self.browser then
				return
			end

			local lobbies = self.browser:lobbies()
			local info = {
				room_list = {},
				attribute_list = {}
			}

			if lobbies then
				for _, lobby in ipairs(lobbies) do
					if self._difficulty_filter == 0 or self._difficulty_filter == tonumber(lobby:key_value("difficulty")) then
						table.insert(info.room_list, {
							owner_id = lobby:key_value("owner_id"),
							owner_name = lobby:key_value("owner_name"),
							room_id = lobby:id(),
							owner_level = lobby:key_value("owner_level")
						})

						local attributes_data = {
							numbers = self:_lobby_to_numbers(lobby),
							mutators = lobby:key_value("mutators")
						}
						local crime_spree_key = lobby:key_value("crime_spree")

						if is_key_valid(crime_spree_key) then
							attributes_data.crime_spree = crime_spree_key
						end

						table.insert(info.attribute_list, attributes_data)
					end
				end
			end

			self:_call_callback("search_lobby", info)
		end

		self.browser = LobbyBrowser(refresh_lobby, function ()
		end)
		local interest_keys = {
			"owner_id",
			"owner_name",
			"level",
			"difficulty",
			"permission",
			"state",
			"num_players",
			"drop_in",
			"min_level",
			"kick_option",
			"job_class_min",
			"job_class_max"
		}

		if self._BUILD_SEARCH_INTEREST_KEY then
			table.insert(interest_keys, self._BUILD_SEARCH_INTEREST_KEY)
		end

		self.browser:set_interest_keys(interest_keys)
		self.browser:set_distance_filter(self._distance_filter)
		self.browser:set_lobby_filter("min_level", managers.experience:current_level(), "equalto_less_than")
		self.browser:set_lobby_filter(self._BUILD_SEARCH_INTEREST_KEY, "true", "equal")

		if Global.game_settings.search_appropriate_jobs then
			local min_ply_jc = managers.job:get_min_jc_for_player()
			local max_ply_jc = managers.job:get_max_jc_for_player()

			self.browser:set_lobby_filter("job_class_min", min_ply_jc, "equalto_or_greater_than")
			self.browser:set_lobby_filter("job_class_max", max_ply_jc, "equalto_less_than")
		end

		for key, data in pairs(self._lobby_filters) do
			if data.value and data.value ~= -1 then
				self.browser:set_lobby_filter(data.key, data.value, data.comparision_type)
			end
		end

		self.browser:set_max_lobby_return_count(self._lobby_return_count)

		if Global.game_settings.playing_lan then
			self.browser:refresh_lan()
		else
			self.browser:refresh()
		end
	end
end

function NetworkMatchMaking:search_lobby_done()
	managers.system_menu:close("find_server")

	self.browser = nil
end

function NetworkMatchMaking:game_owner_name()
	return managers.network.matchmake.lobby_handler:get_lobby_data("owner_name")
end

function NetworkMatchMaking:is_server_ok(friends_only, room, attributes_numbers, is_invite)
	local permission = tweak_data:index_to_permission(attributes_numbers[3])
	local level_index, job_index = self:_split_attribute_number(attributes_numbers[1], 1000)

	if not tweak_data.levels:get_level_name_from_index(level_index) then
		Application:error("No level data for index " .. level_index .. ". Payday1 data not compatible with Payday2.")

		return false
	end

	if (not NetworkManager.DROPIN_ENABLED or attributes_numbers[6] == 0) and attributes_numbers[4] ~= 1 then
		Application:debug("NetworkMatchMaking:is_server_ok() server rejected. DROPING NOT ENABLED")

		return false, 1
	end

	if managers.experience:current_level() < attributes_numbers[7] then
		Application:debug("NetworkMatchMaking:is_server_ok() server rejected. REPUTATION CAP")

		return false, 3
	end

	if not is_invite and permission == "private" then
		Application:debug("NetworkMatchMaking:is_server_ok() server rejected. PRIVATE GAME")

		return false, 2
	end

	if permission == "public" then
		return true
	end

	return true
end

function NetworkMatchMaking:join_server_with_check(room_id, is_invite)
	managers.menu:show_joining_lobby_dialog()
end

function NetworkMatchMaking._on_member_left(id, status)
	if not managers.network:session() then
		return
	end

	local peer = managers.network:session():peer_by_user_id(id)

	if not peer then
		return
	end

	if peer == managers.network:session():local_peer() and managers.network:session():is_server() then
		managers.network:session():on_peer_left(peer, peer_id)

		return
	elseif peer == managers.network:session():local_peer() and not managers.network:session():closing() then
		Application:error("OMG I LEFT THE LOBBY")

		managers.network.matchmake._try_re_enter_lobby = "lost"
	end

	managers.network:session():on_peer_left_lobby(peer)
end

function NetworkMatchMaking._on_memberstatus_change(memberstatus)
	print("[NetworkMatchMaking._on_memberstatus_change]", memberstatus)

	local user, status = unpack(string.split(memberstatus, ":"))

	if status == "lost_connection" or status == "left_become_owner" or status == "left" or status == "kicked" or status == "banned" or status == "invalid" then
		NetworkMatchMaking._on_member_left(user, status)
	end
end

function NetworkMatchMaking._on_data_update(...)
end

function NetworkMatchMaking._on_chat_message(user, message)
	print("[NetworkMatchMaking._on_chat_message]", user, message)
	NetworkMatchMaking._handle_chat_message(user, message)
end

function NetworkMatchMaking._handle_chat_message(user, message)
	local s = "" .. message

	managers.chat:receive_message_by_name(ChatManager.GLOBAL, user:name(), s)
end

function NetworkMatchMaking:join_server(room_id, skip_showing_dialog)
	if not skip_showing_dialog then
		managers.menu:show_joining_lobby_dialog()
	end

	local function f(result, handler)
		print("[NetworkMatchMaking:join_server:f]", result, handler)
		managers.system_menu:close("join_server")

		if result == "success" then
			print("Success!")

			self.lobby_handler = handler
			local _, host_id, owner = self.lobby_handler:get_server_details()

			print("[NetworkMatchMaking:join_server] server details", _, host_id)
			print("Gonna handshake now!")

			self._server_rpc = Network:handshake(host_id:tostring(), nil, "VOID")

			print("Handshook!")
			print("Server RPC:", self._server_rpc and self._server_rpc:ip_at_index(0))

			if not self._server_rpc then
				return
			end

			self.lobby_handler:setup_callbacks(NetworkMatchMaking._on_memberstatus_change, NetworkMatchMaking._on_data_update, NetworkMatchMaking._on_chat_message)
			managers.network:start_client()
			managers.menu:show_waiting_for_server_response({
				cancel_func = function ()
					managers.network:session():on_join_request_cancelled()
				end
			})

			local function joined_game(res, level_index, difficulty_index, state_index)
				managers.system_menu:close("waiting_for_server_response")
				print("[NetworkMatchMaking:join_server:joined_game]", res, level_index, difficulty_index, state_index)

				if res == "JOINED_LOBBY" then
					MenuCallbackHandler:crimenet_focus_changed(nil, false)
					managers.menu:on_enter_lobby()
				elseif res == "JOINED_GAME" then
					local level_id = tweak_data.levels:get_level_name_from_index(level_index)
					Global.game_settings.level_id = level_id

					managers.network:session():local_peer():set_in_lobby(false)
				elseif res == "KICKED" then
					managers.network.matchmake:leave_game()
					managers.network.voice_chat:destroy_voice()
					managers.network:queue_stop_network()
					managers.menu:show_peer_kicked_dialog()
				elseif res == "TIMED_OUT" then
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
				elseif res == "FAILED_CONNECT" then
					managers.network.matchmake:leave_game()
					managers.network.voice_chat:destroy_voice()
					managers.network:queue_stop_network()
					managers.menu:show_failed_joining_dialog()
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
				elseif res == "AUTH_FAILED" or res == "AUTH_HOST_FAILED" then
					managers.network.matchmake:leave_game()
					managers.network.voice_chat:destroy_voice()
					managers.network:queue_stop_network()

					Global.on_remove_peer_message = res == "AUTH_HOST_FAILED" and "dialog_authentication_host_fail" or "dialog_authentication_fail"

					managers.menu:show_peer_kicked_dialog()
				else
					Application:error("[NetworkMatchMaking:join_server] FAILED TO START MULTIPLAYER!", res)
				end
			end

			managers.network:join_game_at_host_rpc(self._server_rpc, joined_game)
		else
			managers.menu:show_failed_joining_dialog()
			self:search_lobby(self:search_friends_only())
		end
	end
end

function NetworkMatchMaking:send_join_invite(friend)
end

function NetworkMatchMaking:set_server_attributes(settings)
	self:set_attributes(settings)
end

function NetworkMatchMaking:create_lobby(settings)
	self._num_players = nil
	local dialog_data = {
		title = managers.localization:text("dialog_creating_lobby_title"),
		text = managers.localization:text("dialog_wait"),
		id = "create_lobby",
		no_buttons = true
	}

	managers.system_menu:show(dialog_data)

	local function f(result, handler)
		print("Create lobby callback!!", result, handler)

		if result == "success" then
			self.lobby_handler = handler

			self:set_attributes(settings)
			self.lobby_handler:publish_server_details()

			self._server_joinable = true

			self.lobby_handler:set_joinable(true)
			self.lobby_handler:setup_callbacks(NetworkMatchMaking._on_memberstatus_change, NetworkMatchMaking._on_data_update, NetworkMatchMaking._on_chat_message)
			managers.system_menu:close("create_lobby")
			managers.menu:created_lobby()
		else
			managers.system_menu:close("create_lobby")

			local title = managers.localization:text("dialog_error_title")
			local dialog_data = {
				title = title,
				text = managers.localization:text("dialog_err_failed_creating_lobby"),
				button_list = {
					{
						text = managers.localization:text("dialog_ok")
					}
				}
			}

			managers.system_menu:show(dialog_data)
		end
	end

	return true
end

function NetworkMatchMaking:set_num_players(num)
	print("NetworkMatchMaking:set_num_players", num)

	self._num_players = num

	if self._lobby_attributes then
		self._lobby_attributes.num_players = num

		self.lobby_handler:set_lobby_data(self._lobby_attributes)
	end
end

function NetworkMatchMaking:set_server_state(state)
	if self._lobby_attributes then
		local state_id = tweak_data:server_state_to_index(state)
		self._lobby_attributes.state = state_id

		if self.lobby_handler then
			self.lobby_handler:set_lobby_data(self._lobby_attributes)

			if not NetworkManager.DROPIN_ENABLED then
				self.lobby_handler:set_joinable(state == "in_lobby")
			end
		end
	end
end

function NetworkMatchMaking:set_server_joinable(state)
	print("[NetworkMatchMaking:set_server_joinable]", state)

	self._server_joinable = state

	if self.lobby_handler then
		self.lobby_handler:set_joinable(state)
	end
end

function NetworkMatchMaking:is_server_joinable()
	return self._server_joinable
end

function NetworkMatchMaking:server_state_name()
	return tweak_data:index_to_server_state(self._lobby_attributes.state)
end

function NetworkMatchMaking:set_attributes(settings)
	if not self.lobby_handler then
		return
	end

	local permissions = {
		"public",
		"friend",
		"private"
	}
	local level_index, job_index = self:_split_attribute_number(settings.numbers[1], 1000)
	local lobby_attributes = {
		owner_name = managers.network.account:username_id(),
		owner_id = managers.network.account:player_id(),
		level = level_index,
		difficulty = settings.numbers[2],
		permission = settings.numbers[3],
		state = settings.numbers[4] or self._lobby_attributes and self._lobby_attributes.state or 1,
		min_level = settings.numbers[7] or 0,
		num_players = self._num_players or 1,
		drop_in = settings.numbers[6] or 1,
		job_id = job_index or 0,
		kick_option = settings.numbers[8] or 0,
		job_class_min = settings.numbers[9] or 10,
		job_class_max = settings.numbers[9] or 10,
		job_plan = settings.numbers[10]
	}

	if self._BUILD_SEARCH_INTEREST_KEY then
		lobby_attributes[self._BUILD_SEARCH_INTEREST_KEY] = "true"
	end

	managers.mutators:apply_matchmake_attributes(lobby_attributes)
	managers.crime_spree:apply_matchmake_attributes(lobby_attributes)

	self._lobby_attributes = lobby_attributes

	self.lobby_handler:set_lobby_data(lobby_attributes)
	self.lobby_handler:set_lobby_type(permissions[settings.numbers[3]])
end

function NetworkMatchMaking:_lobby_to_numbers(lobby)
	return {
		tonumber(lobby:key_value("level")) + 1000 * tonumber(lobby:key_value("job_id")),
		tonumber(lobby:key_value("difficulty")),
		tonumber(lobby:key_value("permission")),
		tonumber(lobby:key_value("state")),
		tonumber(lobby:key_value("num_players")),
		tonumber(lobby:key_value("drop_in")),
		tonumber(lobby:key_value("min_level")),
		tonumber(lobby:key_value("kick_option")),
		tonumber(lobby:key_value("job_class")),
		tonumber(lobby:key_value("job_plan"))
	}
end

function NetworkMatchMaking:from_host_lobby_re_opened(status)
	print("[NetworkMatchMaking::from_host_lobby_re_opened]", self._try_re_enter_lobby, status)

	if self._try_re_enter_lobby == "asked" then
		if status then
			self._try_re_enter_lobby = "open"
		else
			self._try_re_enter_lobby = nil

			managers.network.matchmake:leave_game()
		end
	end
end
