NetworkGroupLobby = NetworkGroupLobby or class()

function NetworkGroupLobby:init()
end

function NetworkGroupLobby:_server_timed_out(rpc)
end

function NetworkGroupLobby:is_invite_changing_control()
	return self._invite_changing_control
end
