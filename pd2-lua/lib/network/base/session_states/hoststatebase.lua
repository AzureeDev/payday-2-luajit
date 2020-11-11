HostStateBase = HostStateBase or class()

function HostStateBase:enter(data, enter_params)
end

function HostStateBase:exit(data, name, enter_params)
end

function HostStateBase:on_join_request_received(data, peer_name, client_preferred_character, dlcs, xuid, peer_level, peer_rank, peer_stinger_index, gameversion, join_attempt_identifier, auth_ticket, sender)
	print("[HostStateBase:on_join_request_received]", data, peer_name, client_preferred_character, dlcs, xuid, peer_level, peer_rank, peer_stinger_index, gameversion, join_attempt_identifier, sender:ip_at_index(0))

	local my_user_id = data.local_peer:user_id() or ""

	if not managers.network.matchmake:is_server_joinable() then
		self:_send_request_denied(sender, 3, my_user_id)

		return
	end

	self:_send_request_denied(sender, 0, my_user_id)
end

function HostStateBase:_send_request_denied(sender, reason, my_user_id)
	local xuid = (SystemInfo:platform() == Idstring("X360") or SystemInfo:platform() == Idstring("XB1")) and managers.network.account:player_id() or ""
	local params = {
		reason,
		0,
		"",
		1,
		1,
		false,
		0,
		"",
		my_user_id,
		"",
		0,
		0,
		0,
		0,
		xuid,
		0
	}

	sender:join_request_reply(unpack(params))
end

function HostStateBase:_has_peer_left_PSN(peer_name)
	if SystemInfo:platform() == Idstring("PS3") and managers.network.matchmake:check_peer_join_request_remove(peer_name) then
		print("this CLIENT has left us from PSN, ignore his request", peer_name)

		return
	end
end

function HostStateBase:_is_in_server_state()
	return managers.network:session() and Network:is_server()
end

function HostStateBase:_introduce_new_peer_to_old_peers(data, new_peer, loading, peer_name, character, mask_set, xuid, xnaddr)
	local new_peer_user_id = SystemInfo:platform() == Idstring("WIN32") and new_peer:user_id() or ""
	local new_peer_id = new_peer:id()

	for old_pid, old_peer in pairs(data.peers) do
		if old_pid ~= new_peer_id then
			if old_peer:handshakes()[new_peer_id] == nil then
				print("[HostStateBase:_introduce_new_peer_to_old_peers] introducing", new_peer_id, "to", old_pid)
				old_peer:send("peer_handshake", peer_name, new_peer_id, new_peer_user_id, new_peer:in_lobby(), loading, false, character, mask_set, xuid, xnaddr)
				old_peer:set_handshake_status(new_peer_id, "asked")
			else
				print("[HostStateBase:_introduce_new_peer_to_old_peers] peer already had handshake", new_peer_id, "to", old_pid)
			end
		end
	end
end

function HostStateBase:_introduce_old_peers_to_new_peer(data, new_peer)
	local new_peer_id = new_peer:id()

	for old_pid, old_peer in pairs(data.peers) do
		if old_pid ~= new_peer_id then
			if new_peer:handshakes()[old_pid] == nil then
				print("[HostStateBase:_introduce_old_peers_to_new_peer] introducing", old_pid, "to", new_peer_id)
				new_peer:send("peer_handshake", old_peer:connection_info())
				new_peer:set_handshake_status(old_pid, "asked")
			else
				print("[HostStateBase:_introduce_new_peer_to_old_peers] peer already had handshake", old_pid, "to", new_peer_id)
			end
		end
	end
end

function HostStateBase:_chk_mutual_connection_established(data, peer, introduced_peer_id)
	local introduced_peer = data.peers[introduced_peer_id]

	if introduced_peer:handshakes()[peer:id()] == true then
		cat_print("multiplayer_base", "[HostStateBase:_chk_mutual_connection_established] mutual connection", peer:id(), introduced_peer_id)
		introduced_peer:send("mutual_connection", peer:id())
		peer:send("mutual_connection", introduced_peer_id)

		return true
	end

	return false
end

function HostStateBase:on_handshake_confirmation(data, peer, introduced_peer_id)
	cat_print("multiplayer_base", "[HostStateBase:on_handshake_confirmation]", inspect(peer), peer:id(), introduced_peer_id)

	local has_mutual_connection = nil

	if introduced_peer_id ~= 1 then
		has_mutual_connection = self:_chk_mutual_connection_established(data, peer, introduced_peer_id)
	end

	if has_mutual_connection then
		data.session:chk_initiate_dropin_pause(peer)
		data.session:chk_initiate_dropin_pause(data.peers[introduced_peer_id])

		if data.game_started then
			for other_peer_id, other_peer in pairs(data.peers) do
				data.session:chk_spawn_member_unit(other_peer, other_peer_id)
			end
		end
	end

	data.session:check_start_game_intro()
end

function HostStateBase:_is_kicked(data, peer_name, peer_rpc)
	local ident = SystemInfo:platform() == Idstring("WIN32") and peer_rpc:ip_at_index(0) or peer_name

	if data.kicked_list[ident] then
		return true
	end
end

function HostStateBase:_is_banned(peer_name, peer_rpc)
	local ident = SystemInfo:platform() == Idstring("WIN32") and peer_rpc:ip_at_index(0) or peer_name

	Application:error("CHECKING USER:", ident)

	if managers.ban_list and managers.ban_list:banned(ident) then
		return true
	end
end

function HostStateBase:_chk_peer_owns_current_dlc(data, peer_dlcs)
	local requires_dlc = tweak_data.levels[Global.game_settings.level_id].dlc

	if requires_dlc then
		local i_dlcs = string.split(peer_dlcs, " ")

		for _, dlc in ipairs(i_dlcs) do
			if requires_dlc == dlc then
				return true
			end
		end
	end

	return false
end

function HostStateBase:on_peer_finished_loading(data, peer)
	print("[HostStateBase:on_peer_finished_loading]", inspect(peer))

	if not next(peer:handshakes()) then
		self:_introduce_new_peer_to_old_peers(data, peer, false, peer:name(), peer:character(), "remove", peer:xuid(), peer:xnaddr())
		self:_introduce_old_peers_to_new_peer(data, peer)
	end
end

function HostStateBase:on_load_level(data)
	data.wants_to_load_level = true
end

function HostStateBase:is_joinable(data)
	return false
end
