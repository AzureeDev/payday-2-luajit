DefaultNetworkHandler = DefaultNetworkHandler or class()

function DefaultNetworkHandler:init()
end

function DefaultNetworkHandler.lost_peer(peer_ip)
	cat_print("multiplayer_base", "Lost Peer (DefaultNetworkHandler)")

	if managers.network:session() then
		local peer = managers.network:session():peer_by_ip(peer_ip:ip_at_index(0))

		if peer then
			managers.network:session():on_peer_lost(peer, peer:id())
		end
	end
end

function DefaultNetworkHandler.lost_client(peer_ip)
	Application:error("[DefaultNetworkHandler] Lost client", peer_ip)

	if managers.network:session() then
		local peer = managers.network:session():peer_by_ip(peer_ip:ip_at_index(0))

		if peer then
			managers.network:session():on_peer_lost(peer, peer:id())
		end
	end
end

function DefaultNetworkHandler.lost_server(peer_ip)
	Application:error("[DefaultNetworkHandler] Lost server", peer_ip)

	if managers.network:session() then
		local peer = managers.network:session():peer_by_ip(peer_ip:ip_at_index(0))

		if peer then
			managers.network:session():on_peer_lost(peer, peer:id())
		end
	end
end
