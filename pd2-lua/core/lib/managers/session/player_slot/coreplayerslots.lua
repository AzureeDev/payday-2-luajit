core:module("CorePlayerSlots")
core:import("CorePlayerSlot")
core:import("CoreSessionGenericState")

PlayerSlots = PlayerSlots or class(CoreSessionGenericState.State)

function PlayerSlots:init(local_user_manager, factory)
	self._slots = {}
	self._local_user_manager = local_user_manager

	self:_set_stable_for_loading()

	self._factory = factory
end

function PlayerSlots:clear()
	self._slots = {}
end

function PlayerSlots:clear_session()
	for _, slot in pairs(self._slots) do
		slot:clear_session()
	end
end

function PlayerSlots:add_player_slot()
	local new_index = #self._slots + 1
	local new_slot = CorePlayerSlot.PlayerSlot:new(self, self._local_user_manager)
	self._slots[new_index] = new_slot

	return new_slot
end

function PlayerSlots:_remove_player_slot(player_slot)
	for index, slot in pairs(self._slots) do
		if slot == player_slot then
			self._slots[index] = nil

			return
		end
	end

	assert(false, "couldn't find that player slot")
end

function PlayerSlots:slots()
	return self._slots
end

function PlayerSlots:transition()
	for _, slot in pairs(self._slots) do
		slot:transition()
	end
end

function PlayerSlots:primary_slot()
	local primary_slot = self._slots[1]

	assert(primary_slot, "No primary slot defined")

	return primary_slot
end

function PlayerSlots:has_primary_local_user()
	local primary_slot = self._slots[1]

	return primary_slot ~= nil and primary_slot:has_assigned_user()
end

function PlayerSlots:primary_local_user()
	local primary_slot = self._slots[1]

	assert(primary_slot, "No primary slot defined")
	assert(primary_slot:has_assigned_user(), "No user assigned to primary slot")

	return primary_slot:assigned_user()
end

function PlayerSlots:create_players()
	for index, slot in pairs(self._slots) do
		if slot:has_assigned_user() then
			slot:create_player()
		end
	end
end

function PlayerSlots:remove_players()
	for index, slot in pairs(self._slots) do
		if slot:has_player() then
			slot:remove_player()
		end
	end
end

function PlayerSlots:enter_level_handler(level_handler)
	for index, slot in pairs(self._slots) do
		local player = slot:player()

		if player then
			player:enter_level(level_handler)
		end
	end
end

function PlayerSlots:leave_level_handler(level_handler)
	for index, slot in pairs(self._slots) do
		local player = slot:player()

		if player then
			player:leave_level(level_handler)
		end
	end
end
