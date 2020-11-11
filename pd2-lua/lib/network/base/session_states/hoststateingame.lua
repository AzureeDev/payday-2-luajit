HostStateInGame = HostStateInGame or class(HostStateBase)
HostStateInGame.STATE_INDEX = 3

function HostStateInGame:enter(data, enter_params)
	print("[HostStateInGame:enter]", data, inspect(enter_params))

	self._new_peers = {}
end

function HostStateInGame:on_join_request_received(data, peer_name, client_preferred_character, dlcs, xuid, peer_level, peer_rank, peer_stinger_index, gameversion, join_attempt_identifier, auth_ticket, sender)
	print("[HostStateInGame:on_join_request_received]", data, peer_name, client_preferred_character, dlcs, xuid, peer_level, gameversion, join_attempt_identifier, sender:ip_at_index(0))

	local my_user_id = data.local_peer:user_id() or ""

	if SystemInfo:platform() == Idstring("WIN32") then
		peer_name = managers.network.account:username_by_id(sender:ip_at_index(0))
	end

	if self:_has_peer_left_PSN(peer_name) then
		print("this CLIENT has left us from PSN, ignore his request", peer_name)

		return
	elseif not self:_is_in_server_state() then
		self:_send_request_denied(sender, 0, my_user_id)

		return
	elseif not NetworkManager.DROPIN_ENABLED or not Global.game_settings.drop_in_allowed then
		self:_send_request_denied(sender, 3, my_user_id)

		return
	elseif managers.groupai and not managers.groupai:state():chk_allow_drop_in() then
		self:_send_request_denied(sender, 0, my_user_id)

		return
	elseif self:_is_banned(peer_name, sender) then
		self:_send_request_denied(sender, 9, my_user_id)

		return
	elseif peer_level < Global.game_settings.reputation_permission then
		self:_send_request_denied(sender, 6, my_user_id)

		return
	elseif gameversion ~= -1 and gameversion ~= managers.network.matchmake.GAMEVERSION then
		self:_send_request_denied(sender, 7, my_user_id)

		return
	elseif data.wants_to_load_level then
		self:_send_request_denied(sender, 0, my_user_id)

		return
	elseif not managers.network:session():local_peer() then
		self:_send_request_denied(sender, 0, my_user_id)

		return
	else
		local user = Steam:user(sender:ip_at_index(0))

		if not MenuCallbackHandler:is_modded_client() and not Global.game_settings.allow_modded_players and user and user:rich_presence("is_modded") == "1" then
			self:_send_request_denied(sender, 10, my_user_id)

			return
		end
	end

	local old_peer = data.session:chk_peer_already_in(sender)

	if old_peer then
		if join_attempt_identifier ~= old_peer:join_attempt_identifier() then
			data.session:remove_peer(old_peer, old_peer:id(), "lost")
			self:_send_request_denied(sender, 0, my_user_id)
		end

		return
	end

	if table.size(data.peers) >= tweak_data.max_players - 1 then
		print("server is full")
		self:_send_request_denied(sender, 5, my_user_id)

		return
	end

	local character = managers.network:session():check_peer_preferred_character(client_preferred_character)
	local xnaddr = ""

	if SystemInfo:platform() == Idstring("X360") or SystemInfo:platform() == Idstring("XB1") then
		xnaddr = managers.network.matchmake:external_address(sender)
	end

	local new_peer_id, new_peer = nil
	new_peer_id, new_peer = data.session:add_peer(peer_name, nil, false, false, false, nil, character, sender:ip_at_index(0), xuid, xnaddr)

	if not new_peer_id then
		print("there was no clean peer_id")
		self:_send_request_denied(sender, 0, my_user_id)

		return
	end

	new_peer:set_dlcs(dlcs)
	new_peer:set_xuid(xuid)
	new_peer:set_join_attempt_identifier(join_attempt_identifier)

	local new_peer_rpc = nil

	if managers.network:protocol_type() == "TCP_IP" then
		new_peer_rpc = managers.network:session():resolve_new_peer_rpc(new_peer, sender)
	else
		new_peer_rpc = sender
	end

	new_peer:set_rpc(new_peer_rpc)
	new_peer:set_ip_verified(true)
	Network:add_co_client(new_peer_rpc)

	if not new_peer:begin_ticket_session(auth_ticket) then
		data.session:remove_peer(new_peer, new_peer:id(), "auth_fail")
		self:_send_request_denied(sender, 8, my_user_id)

		return
	end

	local ticket = new_peer:create_ticket()
	local level_index = tweak_data.levels:get_index_from_level_id(Global.game_settings.level_id)
	local difficulty_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	local job_id_index = 0
	local job_stage = 0
	local alternative_job_stage = 0
	local interupt_job_stage_level_index = 0

	if managers.job:has_active_job() then
		job_id_index = tweak_data.narrative:get_index_from_job_id(managers.job:current_job_id())
		job_stage = managers.job:current_stage()
		alternative_job_stage = managers.job:alternative_stage() or 0
		local interupt_stage_level = managers.job:interupt_stage()
		interupt_job_stage_level_index = interupt_stage_level and tweak_data.levels:get_index_from_level_id(interupt_stage_level) or 0
	end

	local server_xuid = (SystemInfo:platform() == Idstring("X360") or SystemInfo:platform() == Idstring("XB1")) and managers.network.account:player_id() or ""
	local params = {
		1,
		new_peer_id,
		character,
		level_index,
		difficulty_index,
		Global.game_settings.one_down,
		self.STATE_INDEX,
		data.local_peer:character(),
		my_user_id,
		Global.game_settings.mission,
		job_id_index,
		job_stage,
		alternative_job_stage,
		interupt_job_stage_level_index,
		server_xuid,
		ticket
	}

	new_peer:send("join_request_reply", unpack(params))
	new_peer:send("set_loading_state", false, data.session:load_counter())

	if SystemInfo:platform() == Idstring("X360") or SystemInfo:platform() == Idstring("XB1") then
		new_peer:send("request_player_name_reply", managers.network:session():local_peer():name())
	end

	managers.vote:sync_server_kick_option(new_peer)
	data.session:send_ok_to_load_level()
	self:on_handshake_confirmation(data, new_peer, 1)
	new_peer:set_rank(peer_rank)
	new_peer:set_join_stinger_index(peer_stinger_index)

	self._new_peers[new_peer_id] = true
end

function HostStateInGame:on_peer_finished_loading(data, peer)
	self:_introduce_new_peer_to_old_peers(data, peer, false, peer:name(), peer:character(), "remove", peer:xuid(), peer:xnaddr())
	self:_introduce_old_peers_to_new_peer(data, peer)

	if data.game_started then
		peer:send("set_dropin")
	end

	if self._new_peers[peer:id()] then
		local join_stinger_index = peer:join_stinger_index()

		managers.menu:play_join_stinger_by_index(join_stinger_index)
		managers.network:session():send_to_peers_except(peer:id(), "peer_joined_sound", join_stinger_index)
		managers.crime_spree:on_peer_finished_loading(peer)
	end
end

function HostStateInGame:is_joinable(data)
	return not data.wants_to_load_level
end
