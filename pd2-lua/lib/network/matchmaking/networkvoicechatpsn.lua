NetworkVoiceChatPSN = NetworkVoiceChatPSN or class()

function NetworkVoiceChatPSN:init()
	self._started = false
	self._room_id = nil
	self._team = 1
	self._restart_session = nil
	self._peers = {}

	self:_load_globals()

	self._muted_players = {}

	PSNVoice:set_voice_ui_update_callback(callback(self, self, "voice_ui_update_callback"))
end

function NetworkVoiceChatPSN:check_status_information()
end

function NetworkVoiceChatPSN:open()
end

function NetworkVoiceChatPSN:voice_type()
	return "voice_psn"
end

function NetworkVoiceChatPSN:pause()
end

function NetworkVoiceChatPSN:resume()
end

function NetworkVoiceChatPSN:set_volume(volume)
	PSNVoice:set_volume(volume)
end

function NetworkVoiceChatPSN:init_voice()
	if self._started == false and not self._starting then
		self._starting = true

		PSNVoice:assign_callback(function (...)
			self:_callback(...)
		end)
		PSNVoice:init(4, 4, 50, 16000)

		self._started = true
	end
end

function NetworkVoiceChatPSN:destroy_voice(disconnected)
	if self._started == true then
		self._started = false

		if self._room_id and not disconnected then
			self:close_session()
		end

		PSNVoice:destroy()

		self._closing = nil
		self._room_id = nil
		self._restart_session = nil
		self._team = 1
	end
end

function NetworkVoiceChatPSN:num_peers()
	local l = PSNVoice:get_players_info()

	if l then
		local x = 0

		for k, v in pairs(l) do
			if v.joined == 1 then
				x = x + 1
			end
		end

		return x >= #l
	end

	return true
end

function NetworkVoiceChatPSN:open_session(roomid)
	self:update_settings()
	print("[VOICECHAT] NetworkVoiceChatPSN:open_session( ", roomid, " ) self._room_id: ", self._room_id, "self._restart_session: ", self._restart_session)

	if self._room_id and self._room_id == roomid then
		print("Voice: same_room")

		return
	end

	if self._restart_session and self._restart_session == roomid then
		print("Voice: restart")

		return
	end

	if self._closing or self._joining then
		print("Voice: closing|joining")

		self._restart_session = roomid

		return
	end

	if self._started == false then
		self._restart_session = roomid

		self:init_voice()
	end

	if self._room_id then
		print("Voice: restart room")

		return
	end

	self._room_id = roomid
	self._joining = true

	PSNVoice:start_session(roomid)
end

function NetworkVoiceChatPSN:close_session()
	print("[VOICECHAT] NetworkVoiceChatPSN:close_session() see following stack dump")

	if self._joining then
		self._close = true

		return
	end

	if self._room_id and not self._closing then
		self._closing = true

		if not PSNVoice:stop_session() then
			self._closing = nil
			self._room_id = nil
			self._delay_frame = TimerManager:wall():time() + 1
		end
	elseif not self._closing then
		self._restart_session = nil
		self._delay_frame = nil
	end
end

function NetworkVoiceChatPSN:open_channel_to(player_info, context)
	print("[VOICECHAT] NetworkVoiceChatPSN:open_channel_to")
end

function NetworkVoiceChatPSN:close_channel_to(player_info)
	print("[VOICECHAT] NetworkVoiceChatPSN:close_channel_to")
	PSNVoice:stop_sending_to(player_info._name)
end

function NetworkVoiceChatPSN:lost_peer(peer)
end

function NetworkVoiceChatPSN:close_all()
	print("[VOICECHAT] NetworkVoiceChatPSN:close_all() see following stack dump")

	if self._room_id then
		self:close_session()
	end

	self._room_id = nil
	self._closing = nil
end

function NetworkVoiceChatPSN:set_team(team)
	if self._room_id then
		PSN:change_team(self._room_id, PSN:get_local_userid(), team)
		PSNVoice:set_team_target(team)
	end

	self._team = team
end

function NetworkVoiceChatPSN:clear_team()
	if self._room_id and PSN:get_local_userid() then
		PSN:change_team(self._room_id, PSN:get_local_userid(), 1)
		PSNVoice:set_team_target(1)

		self._team = 1
	end
end

function NetworkVoiceChatPSN:set_drop_in(data)
	self._drop_in = data
end

function NetworkVoiceChatPSN:_load_globals()
	if Global.psn and Global.psn.voice then
		self._started = Global.psn.voice.started
	end

	if PSN:is_online() and Global.psn and Global.psn.voice then
		PSNVoice:assign_callback(function (...)
		end)

		self._room_id = Global.psn.voice.room
		self._team = Global.psn.voice.team

		if Global.psn.voice.drop_in then
			self:open_session(Global.psn.voice.drop_in.room_id)
		end

		if Global.psn.voice.restart then
			self._restart_session = restart
			self._delay_frame = TimerManager:wall():time() + 2
		else
			PSNVoice:assign_callback(function (...)
				self:_callback(...)
			end)

			if self._room_id then
				self:set_team(self._team)
			end
		end

		Global.psn.voice = nil
	end
end

function NetworkVoiceChatPSN:_save_globals(disable_voice)
	if disable_voice == nil then
		return
	end

	if not Global.psn then
		Global.psn = {}
	end

	local function f(...)
	end

	PSNVoice:assign_callback(f)

	Global.psn.voice = {
		started = self._started,
		drop_in = self._drop_in
	}

	if type(disable_voice) == "boolean" then
		if disable_voice == true then
			Global.psn.voice.room = self._room_id
			Global.psn.voice.team = self._team
		else
			Global.psn.voice.team = 1
		end
	else
		self:close_all()

		Global.psn.voice.restart = disable_voice
		Global.psn.voice.team = 1
	end
end

function NetworkVoiceChatPSN:enabled()
	return managers.user:get_setting("voice_chat")
end

function NetworkVoiceChatPSN:update_settings()
	self._push_to_talk = false
	self._enabled = managers.user:get_setting("voice_chat")

	if self._enabled then
		PSNVoice:start_recording()
		PSNVoice:set_enable(true)
	else
		PSNVoice:stop_recording()
		PSNVoice:set_enable(false)
	end

	if self._enabled and self._push_to_talk then
		PSNVoice:stop_recording()
	end
end

function NetworkVoiceChatPSN:set_recording(button_pushed_to_talk)
	self:update_settings()

	if not self._enabled then
		PSNVoice:stop_recording()

		return
	end

	if not self._push_to_talk then
		if self._enabled then
			PSNVoice:start_recording()
		else
			PSNVoice:stop_recording()
		end
	elseif button_pushed_to_talk then
		PSNVoice:start_recording()
	else
		PSNVoice:stop_recording()
	end
end

function NetworkVoiceChatPSN:_callback(info)
	if info and PSN:get_local_userid() then
		if info.load_succeeded ~= nil then
			self._starting = nil

			if info.load_succeeded then
				self._started = true
				self._delay_frame = TimerManager:wall():time() + 1
			end

			return
		end

		if info.join_succeeded ~= nil then
			self._joining = nil

			if info.join_succeeded == false then
				self._room_id = nil
			else
				self:set_team(self._team)
			end

			if self._restart_session then
				self._delay_frame = TimerManager:wall():time() + 1
			end

			if self._close then
				self._close = nil

				self:close_session()
			end
		end

		if info.leave_succeeded ~= nil then
			self._closing = nil
			self._room_id = nil

			if self._restart_session then
				self._delay_frame = TimerManager:wall():time() + 1
			end
		end

		if info.unload_succeeded ~= nil then
			local function f(...)
			end

			PSNVoice:assign_callback(f)
		end
	end
end

function NetworkVoiceChatPSN:update()
	if self._delay_frame and self._delay_frame < TimerManager:wall():time() then
		self._delay_frame = nil

		if self._restart_session then
			PSNVoice:assign_callback(function (...)
				self:_callback(...)
			end)

			local r = self._restart_session
			self._restart_session = nil

			self:open_session(r)
		end
	end
end

function NetworkVoiceChatPSN:voice_ui_update_callback(user_info)
end

function NetworkVoiceChatPSN:psn_session_destroyed(roomid)
	print("[VOICECHAT] NetworkVoiceChatPSN:psn_session_destroyed() see following stack dump")

	if self._room_id and self._room_id == roomid then
		self._room_id = nil
		self._closing = nil
	end
end

function NetworkVoiceChatPSN:_get_peer_user_id(peer)
	if not self._room_id then
		return
	end

	local members = PSN:get_info_session(self._room_id).memberlist
	local name = peer:name()

	for i, member in ipairs(members) do
		if tostring(member.user_id) == name then
			return member.user_id
		end
	end
end

function NetworkVoiceChatPSN:on_member_added(peer, mute)
	if peer:rpc() then
		PSNVoice:on_member_added(peer:name(), peer:rpc(), mute)
	end
end

function NetworkVoiceChatPSN:on_member_removed(peer)
	PSNVoice:on_member_removed(peer:name())
end

function NetworkVoiceChatPSN:mute_player(mute, peer)
	self._muted_players[peer:name()] = mute

	PSNVoice:mute_player(mute, peer:name())
end

function NetworkVoiceChatPSN:is_muted(peer)
	return self._muted_players[peer:name()] or false
end

function NetworkVoiceChatPSN:set_voicechat(enable)
	PSNVoice:set_enable(enable)
	print("set_voicechat( enable ) = ", enable)
end
