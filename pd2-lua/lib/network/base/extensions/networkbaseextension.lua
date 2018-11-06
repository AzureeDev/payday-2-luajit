NetworkBaseExtension = NetworkBaseExtension or class()

function NetworkBaseExtension:init(unit)
	self._unit = unit
end

function NetworkBaseExtension:send(func, ...)
	if managers.network:session() then
		managers.network:session():send_to_peers_synched(func, self._unit, ...)
	end
end

function NetworkBaseExtension:send_to_host(func, ...)
	if managers.network:session() then
		managers.network:session():send_to_host(func, self._unit, ...)
	end
end

function NetworkBaseExtension:send_to_unit(params)
	if managers.network:session() then
		local peer = managers.network:session():peer_by_unit(self._unit)

		if peer then
			managers.network:session():send_to_peer(peer, unpack(params))
		end
	end
end

function NetworkBaseExtension:peer()
	if managers.network:session() then
		return managers.network:session():peer_by_unit(self._unit)
	end
end
