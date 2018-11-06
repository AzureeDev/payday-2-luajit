NetworkVoiceChatXBL = NetworkVoiceChatXBL or class()
NetworkVoiceChatXBL._NUM_PEERS = 4

function NetworkVoiceChatXBL:init()
	self.DEFAULT_TEAM = 1
	self._paused = true
	self._userid_callback_id = managers.user:add_user_state_changed_callback(callback(self, self, "user_id_update"))
end

function NetworkVoiceChatXBL:open_session()
	if self._paused == false then
		Application:throw_exception("Trying to re-initialize voice chat")
	end

	self._current_player_index = managers.user:get_platform_id()

	XboxVoice:start(NetworkVoiceChatXBL._NUM_PEERS)

	if self._current_player_index then
		cat_print("lobby", "Voice: Registring Talker", self._current_player_index)
		XboxVoice:register_talker(self._current_player_index)
	end

	self._team = self.DEFAULT_TEAM
	self._peers = {}

	self:_load_globals()

	self._has_headset = false
	self._can_communicate = true
	self._only_friends = false
	self._paused = false
	self._user_changed = true
	self._number_of_users = 1
	self._mute_callback_id = managers.platform:add_event_callback("mute_list_changed", callback(self, self, "mute_callback"))
	self._voice_callback_id = managers.platform:add_event_callback("voicechat_away", callback(self, self, "voicechat_away"))
	self._friendsadd_callback_id = managers.platform:add_event_callback("friend_added", callback(self, self, "friends_update"))
	self._friendsdel_callback_id = managers.platform:add_event_callback("friend_remove", callback(self, self, "friends_update"))
	self._signin_callback_id = managers.platform:add_event_callback("signin_changed", callback(self, self, "user_update"))
	self._profile_callback_id = managers.platform:add_event_callback("profile_setting_changed", callback(self, self, "user_update"))
end

function NetworkVoiceChatXBL:pause()
	cat_print("lobby", "NetworkVoiceChatXBL:pause")

	self._paused = true
end

function NetworkVoiceChatXBL:resume()
	cat_print("lobby", "NetworkVoiceChatXBL:resume")

	self._paused = false

	self:_update_all()
end

function NetworkVoiceChatXBL:open_channel_to(player_info, context)
	print("Opening Voice Channel to ", inspect(player_info))

	local player_index = managers.user:get_platform_id()

	if not player_index then
		Application:error("Player map not ready yet.")

		player_index = 0
	end

	local session = nil

	if context == "game" then
		session = managers.network.matchmake._session
	else
		Application:throw_exception("Context '" .. tostring(context) .. "' not a valid context.")
	end

	if session == nil then
		Application:throw_exception("Session retreived from context '" .. tostring(context) .. "' is nil")
	end

	local internal_address = managers.network:session():is_host() and tostring(player_info.external_address) or XboxLive:internal_address(session, player_info.player_id)
	player_info.voice_rpc = Network:handshake(internal_address, managers.network.DEFAULT_PORT, "TCP_IP")

	if player_info.voice_rpc then
		print("Voice: Created rpc")
	else
		Application:throw_exception("failed to create voice rpc from here to there")
	end

	local peer_info = {
		xuid = player_info.player_id,
		player_id = tostring(player_info.player_id),
		rpc = player_info.voice_rpc,
		team = self.DEFAULT_TEAM,
		listen = true,
		talk = true,
		name = player_info.name,
		why = "open",
		dead = false
	}
	self._peers[peer_info.player_id] = peer_info

	XboxVoice:register_talker(peer_info.xuid)
	XboxVoice:send_to(player_index, peer_info.xuid, peer_info.rpc)
end

function NetworkVoiceChatXBL:playerid_to_name(player_id)
	return self._peers[tostring(player_id)].name
end

function NetworkVoiceChatXBL:ip_to_name(ip)
	for k, v in pairs(self._peers) do
		if v.rpc and ip == tostring(v.rpc:ip_at_index(0)) then
			return v.name
		end
	end
end

function NetworkVoiceChatXBL:close_channel_to(player_info)
	cat_print("lobby", "Closing Voice Channel to ", tostring(player_info.name))

	local player_index = managers.user:get_platform_id()
	local peer_info = self._peers[tostring(player_info.player_id)]

	if peer_info then
		cat_print("lobby", "Voice: Stop talking to ", tostring(player_info.name))
		self:_close_peer(peer_info)

		self._peers[tostring(player_info.player_id)] = nil
	end
end

function NetworkVoiceChatXBL:lost_peer(peer)
	if self._peers == nil then
		return
	end

	local player_index = managers.user:get_platform_id()

	cat_print("lobby", "Voice: Lost peer ", tostring(peer))

	for k, v in pairs(self._peers) do
		if v.rpc and peer:ip_at_index(0) == v.rpc:ip_at_index(0) then
			cat_print("lobby", "\tVoice: Lost Connection to Name = ", v.name)
			self:_close_peer(v)
			self:_peer_flags(v)

			self._peers[k] = nil
		end
	end
end

function NetworkVoiceChatXBL:close_all()
	cat_print("lobby", "Voice: Close all channels ")

	self._paused = true

	XboxVoice:stop()
	cat_print("lobby", "Voice: Close all channels End ")

	self._peers = {}
	self._team = self.DEFAULT_TEAM
end

function NetworkVoiceChatXBL:set_team(team)
	cat_print("lobby", "Voice: set_team ", team)

	self._team = team

	for k, v in pairs(self._peers) do
		if v.rpc then
			v.rpc:voice_team(managers.network.account:player_id(), team)
		end
	end

	self:_update_all()
end

function NetworkVoiceChatXBL:peer_team(xuid, team, rpc)
	for k, v in pairs(self._peers) do
		if v.player_id == tostring(xuid) then
			v.team = team

			self:_update_all()

			return
		end
	end
end

function NetworkVoiceChatXBL:clear_team()
	cat_print("lobby", "Voice: clear_team, eveyone can now speak to each other ")

	self._team = self.DEFAULT_TEAM

	for k, v in pairs(self._peers) do
		v.team = self.DEFAULT_TEAM
	end

	self:_update_all()
end

function NetworkVoiceChatXBL:update(time)
	if self._paused == true then
		return
	end

	local player_index = managers.user:get_platform_id()

	if self._current_player_index ~= player_index then
		cat_print("lobby", "Voice: Talker Changing from ", self._current_player_index, " to ", player_index)

		if self._current_player_index then
			XboxVoice:unregister_talker(self._current_player_index)
		end

		XboxVoice:register_talker(player_index)

		self._current_player_index = player_index
	end

	if self._user_changed then
		cat_print("lobby", "Voice: Users (Login/Settings) has changed. Updating voice flags.")

		self._user_changed = false

		self:_update_numberofusers()
		self:_update_all()
	end
end

function NetworkVoiceChatXBL:_close_peer(peer)
	local player_index = managers.user:get_platform_id()

	XboxVoice:stop_sending_to(player_index, peer.xuid, peer.rpc)

	peer.dead = true
	peer.rpc = nil
end

function NetworkVoiceChatXBL:_peer_update(peer_info)
end

function NetworkVoiceChatXBL:_peer_flags(peer_info)
end

function NetworkVoiceChatXBL:_update_all()
	if self._paused == true then
		return
	end

	for k, v in pairs(self._peers) do
		self:_peer_flags(v)
		self:_peer_update(v)
	end
end

function NetworkVoiceChatXBL:_save_globals()
	cat_print("lobby", "Voice: NetworkVoiceChatXBL:_save_globals ")

	Global.xvoice = nil
	Global.xvoice = {
		peers = self._peers,
		team = self._team
	}

	self:pause()
end

function NetworkVoiceChatXBL:_load_globals()
	cat_print("lobby", "Voice: NetworkVoiceChatXBL:_load_globals ")

	if Global.xvoice == nil then
		return
	end

	self._team = Global.xvoice.team or self._team

	if Global.xvoice and Global.xvoice.peers then
		self._peers = Global.xvoice.peers
	end

	Global.xvoice = nil
end

function NetworkVoiceChatXBL:_update_numberofusers()
	self._number_of_users = 0
	local xuids = XboxLive:all_user_XUIDs()

	for _, xuid in pairs(xuids) do
		if XboxLive:signin_state(xuid) ~= "not_signed_in" then
			self._number_of_users = self._number_of_users + 1
		end
	end

	cat_print("lobby", "   Voice: Number of users = ", self._number_of_users)
end

function NetworkVoiceChatXBL:_get_privilege(userindex)
	local cancommunicate = true
	local friendsonly = false

	if XboxLive:signin_state(userindex) ~= "not_signed_in" then
		cancommunicate = XboxLive:check_privilege(userindex, "communications")
		friendsonly = XboxLive:check_privilege(userindex, "communications_friends_only")

		if cancommunicate then
			friendsonly = false
		elseif friendsonly then
			cancommunicate = true
		end
	end

	return cancommunicate, friendsonly
end

function NetworkVoiceChatXBL:_check_privilege()
	local cancommunicate = true
	local friendsonly = false
	local usercancommunicate, userfriendsonly = nil
	local xuids = XboxLive:all_user_XUIDs()

	for _, xuid in pairs(xuids) do
		usercancommunicate, userfriendsonly = self:_get_privilege(xuid)

		if usercancommunicate == false then
			cancommunicate = false
		end

		if userfriendsonly == true then
			friendsonly = true
		end
	end

	local flagsupdate = false

	cat_print("lobby", "   Voice: Can Communicate = ", cancommunicate)

	if cancommunicate ~= self._can_communicate then
		self._can_communicate = cancommunicate
		flagsupdate = true

		return
	end

	cat_print("lobby", "   Voice: Friends only = ", friendsonly)

	if friendsonly ~= self._only_friends then
		self._only_friends = friendsonly
		flagsupdate = true
	end

	return flagsupdate
end

function NetworkVoiceChatXBL:num_peers()
	return true
end

function NetworkVoiceChatXBL:destroy_voice(disconnected)
	self._paused = true

	XboxVoice:stop()
end

function NetworkVoiceChatXBL:set_volume(new_value)
	print("new_value", new_value)
end

function NetworkVoiceChatXBL:is_muted(xuid)
	local player_index = managers.user:get_platform_id()

	return XboxVoice:muted(xuid)
end

function NetworkVoiceChatXBL:set_muted(xuid, state)
	local player_index = managers.user:get_platform_id()

	XboxVoice:set_muted(xuid, state)
end

function NetworkVoiceChatXBL:user_id_update(id, changed_player_map)
end

function NetworkVoiceChatXBL:mute_callback()
	cat_print("lobby", "Voice: Mute list changed")
	print("Voice: Mute list changed")
	self:_update_all()
end

function NetworkVoiceChatXBL:voicechat_away(b)
	cat_print("lobby", "Voice: voicechat_away: ", tostring(b))
	print("Voice: voicechat_away: ", tostring(b))
end

function NetworkVoiceChatXBL:friends_update(id)
	cat_print("lobby", "Voice: Friends update: ")
	print("Voice: Friends update: ")
	self:_update_all()
end

function NetworkVoiceChatXBL:user_update()
	cat_print("lobby", "Voice: NetworkVoiceChatXBL:user_update")
	print("Voice: NetworkVoiceChatXBL:user_update")

	self._user_changed = true
end

function NetworkVoiceChatXBL:info()
	self:info_script()
	self:info_engine()
end

function NetworkVoiceChatXBL:info_script()
	cat_print("lobby", "Voice Script Info")
	cat_print("lobby", "\tActive Player:     ", self._current_player_index)
	cat_print("lobby", "\tHas Headset:     ", self._has_headset)
	cat_print("lobby", "\tCan Communicate: ", self._can_communicate)
	cat_print("lobby", "\tVoice Paused:    ", self._paused)
	cat_print("lobby", "\tOnly Friends:    ", self._only_friends)
	cat_print("lobby", "\tSelf Team:       ", self._team)

	for k, v in pairs(self._peers) do
		local info = "\t\t" .. v.name
		info = info .. " Team=" .. tostring(v.team)
		info = info .. ", Listen=" .. tostring(v.listen)
		info = info .. ", talk=" .. tostring(v.talk)
		info = info .. ", why=" .. tostring(v.why)

		cat_print("lobby", info)
	end
end

function NetworkVoiceChatXBL:info_engine()
	cat_print("lobby", "Voice Engine Info")
	cat_print("lobby", "   Registred Talkers")

	local talkers = XboxVoice:registered_talkers()

	for k, v in pairs(talkers) do
		local info = nil

		if type(v) == "number" then
			info = "      " .. tostring(v) .. " - Local Player"
		else
			info = "      " .. tostring(v) .. " - " .. self:playerid_to_name(v)
		end

		cat_print("lobby", info)
	end

	cat_print("lobby", "   Registred Sends")

	local sends = XboxVoice:active_sends()

	for k, v in pairs(sends) do
		local num_peers = v:num_peers()

		cat_print("lobby", "      " .. tostring(k) .. " - " .. tostring(num_peers))

		local PeerNumber = 0

		while num_peers > PeerNumber do
			local ip = v:ip_at_index(PeerNumber)

			cat_print("lobby", "         " .. tostring(ip) .. " - " .. self:ip_to_name(ip))

			PeerNumber = PeerNumber + 1
		end
	end
end
