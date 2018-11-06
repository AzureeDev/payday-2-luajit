NetworkVoiceChatDisabled = NetworkVoiceChatDisabled or class()

function NetworkVoiceChatDisabled:init(quiet)
	self._quiet = quiet or false

	if self._quiet then
		cat_print("lobby", "Voice is quiet.")
	else
		cat_print("lobby", "Voice is disabled.")
	end
end

function NetworkVoiceChatDisabled:check_status_information()
end

function NetworkVoiceChatDisabled:open()
end

function NetworkVoiceChatDisabled:set_volume(volume)
end

function NetworkVoiceChatDisabled:voice_type()
	if self._quiet == true then
		return "voice_quiet"
	else
		return "voice_disabled"
	end
end

function NetworkVoiceChatDisabled:set_drop_in(data)
end

function NetworkVoiceChatDisabled:pause()
end

function NetworkVoiceChatDisabled:resume()
end

function NetworkVoiceChatDisabled:init_voice()
end

function NetworkVoiceChatDisabled:destroy_voice()
end

function NetworkVoiceChatDisabled:num_peers()
	return true
end

function NetworkVoiceChatDisabled:open_session(roomid)
end

function NetworkVoiceChatDisabled:close_session()
end

function NetworkVoiceChatDisabled:open_channel_to(player_info, context)
end

function NetworkVoiceChatDisabled:close_channel_to(player_info)
end

function NetworkVoiceChatDisabled:lost_peer(peer)
end

function NetworkVoiceChatDisabled:close_all()
end

function NetworkVoiceChatDisabled:set_team(team)
end

function NetworkVoiceChatDisabled:peer_team(xuid, team, rpc)
end

function NetworkVoiceChatDisabled:_open_close_peers()
end

function NetworkVoiceChatDisabled:mute_player(mute, peer)
end

function NetworkVoiceChatDisabled:update()
end

function NetworkVoiceChatDisabled:_load_globals()
end

function NetworkVoiceChatDisabled:_save_globals(disable_voice)
end

function NetworkVoiceChatDisabled:_display_warning()
	if self._quiet == false and self:_have_displayed_warning() == true then
		managers.menu:show_err_no_chat_parental_control()
	end
end

function NetworkVoiceChatDisabled:_have_displayed_warning()
	if Global.psn_parental_voice and Global.psn_parental_voice == true then
		return false
	end

	Global.psn_parental_voice = true

	return true
end

function NetworkVoiceChatDisabled:clear_team()
end

function NetworkVoiceChatDisabled:psn_session_destroyed()
	if Global.psn and Global.psn.voice then
		Global.psn.voice.restart = nil
	end
end
