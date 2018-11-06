GageAssignmentBase = GageAssignmentBase or class(Pickup)

function GageAssignmentBase:init(unit)
	assert(managers.gage_assignment, "GageAssignmentManager not yet created!")
	GageAssignmentBase.super.init(self, unit)
	managers.gage_assignment:on_unit_spawned(unit)
end

function GageAssignmentBase:sync_pickup(peer)
	if not alive(self._unit) then
		return
	end

	if not managers.gage_assignment:is_unit_an_assignment(self._unit) then
		if Network:is_server() then
			self:consume()
		end

		return
	end

	self._picked_up = true

	managers.gage_assignment:on_unit_interact(self._unit, self._assignment)

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", peer and peer:id() or 1)
		self:show_pickup_msg(peer and peer:id() or 1)
		self:consume()
	end
end

function GageAssignmentBase:_pickup(unit)
	if self._picked_up then
		return
	end

	if not alive(unit) or not alive(self._unit) then
		return
	end

	if Network:is_server() then
		self:sync_pickup()
	else
		managers.network:session():send_to_host("sync_pickup", self._unit)
	end

	return true
end

function GageAssignmentBase:show_pickup_msg(peer_id)
	local peer = managers.network:session() and managers.network:session():peer(peer_id or 1)

	if peer then
		managers.gage_assignment:present_progress(self._assignment, peer:name())
	end
end

function GageAssignmentBase:sync_net_event(event_id)
	if Network:is_client() then
		local peer_id = event_id or 1

		self:sync_pickup()
		self:show_pickup_msg(peer_id)
	end
end

function GageAssignmentBase:assignment()
	return self._assignment
end

function GageAssignmentBase:delete_unit()
	if alive(self._unit) then
		self._unit:set_slot(0)
	end
end

function GageAssignmentBase:interact_blocked()
	return false
end
