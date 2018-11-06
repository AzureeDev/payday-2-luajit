NetworkVoiceChatSTEAM = NetworkVoiceChatSTEAM or class()

function NetworkVoiceChatSTEAM:init()
	self.handler = Steam:voip_handler()
	self._enabled = false
	self._users_talking = {}
end

function NetworkVoiceChatSTEAM:set_volume(volume)
	self.handler:set_out_volume(volume)
end

function NetworkVoiceChatSTEAM:open()
	self._push_to_talk = managers.user:get_setting("push_to_talk")

	if not self._enabled and managers.user:get_setting("voice_chat") then
		self.handler:open()

		self._enabled = true

		if not self._push_to_talk then
			self.handler:start_recording()
		end
	end
end

function NetworkVoiceChatSTEAM:destroy_voice(disconnected)
	if self._enabled then
		self.handler:stop_recording()
		self.handler:close()

		self._enabled = false
	end
end

function NetworkVoiceChatSTEAM:_load_globals()
	if Global.steam and Global.steam.voip then
		self.handler = Global.steam.voip.handler
		Global.steam.voip = nil
	end
end

function NetworkVoiceChatSTEAM:_save_globals()
	if not Global.steam then
		Global.steam = {}
	end

	Global.steam.voip = {
		handler = self.handler
	}
end

function NetworkVoiceChatSTEAM:enabled()
	return managers.user:get_setting("voice_chat")
end

function NetworkVoiceChatSTEAM:set_recording(enabled)
	if not self._push_to_talk then
		return
	end

	if enabled then
		self.handler:start_recording()
	else
		self.handler:stop_recording()
	end
end

function NetworkVoiceChatSTEAM:update()
	self.handler:update()

	local t = Application:time()
	local playing = self.handler:get_voice_receivers_playing()

	for id, pl in pairs(playing) do
		if not self._users_talking[id] then
			self._users_talking[id] = {
				time = 0
			}
		end

		if pl then
			self._users_talking[id].time = t
		end

		local active = t < self._users_talking[id].time + 0.15

		if active ~= self._users_talking[id].active then
			self._users_talking[id].active = active

			if managers.network:session() then
				local peer = managers.network:session():peer(id)

				if peer then
					managers.menu:set_slot_voice(peer, id, active)

					if managers.hud then
						local crim_data = managers.criminals:character_data_by_peer_id(id)

						if crim_data then
							local mugshot = crim_data.mugshot_id

							managers.hud:set_mugshot_voice(mugshot, active)
						end
					end
				end
			end
		end
	end
end

function NetworkVoiceChatSTEAM:on_member_added(peer, mute)
	if peer:rpc() then
		self.handler:add_receiver(peer:id(), peer:rpc(), mute)
	end
end

function NetworkVoiceChatSTEAM:on_member_removed(peer)
	self.handler:remove_receiver(peer:id())
end

function NetworkVoiceChatSTEAM:mute_player(peer, mute)
	self.handler:mute_voice_receiver(peer:id(), mute)
end

function NetworkVoiceChatSTEAM:is_muted(peer)
	return self.handler:is_voice_receiver_muted(peer:id())
end
