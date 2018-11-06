core:module("CoreLocalUser")
core:import("CorePortableLocalUserStorage")
core:import("CoreSessionGenericState")

User = User or class(CoreSessionGenericState.State)

function User:init(local_user_handler, input_input_provider, user_index, profile_settings_handler, profile_progress_handler)
	self._local_user_handler = local_user_handler
	self._input_input_provider = input_input_provider
	self._user_index = user_index
	self._storage = CorePortableLocalUserStorage.Storage:new(self, profile_settings_handler, profile_progress_handler, profile_data_loaded_callback)
	self._game_name = "Player #" .. tostring(self._user_index)
end

function User.default_data(data)
end

function User:save(data)
end

function User:transition()
	self._storage:transition()
end

function User:_player_slot_assigned(player_slot)
	assert(self._player_slot == nil, "This user already has an assigned player slot")

	self._player_slot = player_slot

	self._storage:request_load()
end

function User:_player_slot_lost(player_slot)
	assert(self._player_slot ~= nil, "This user can get a lost player slot, no slot was assigned to begin with")
	assert(self._player_slot == player_slot, "Player has lost a player slot that wasn't assigned")

	self._player_slot = nil
end

function User:profile_data_is_loaded()
	return self._storage:profile_data_is_loaded()
end

function User:enter_level(level_handler)
	self._local_user_handler:enter_level(level_handler)
end

function User:leave_level(level_handler)
	self._local_user_handler:leave_level(level_handler)
	self:release_player()
end

function User:gamer_name()
	return self._game_name
end

function User:is_stable_for_loading()
	return self._storage:is_stable_for_loading()
end

function User:assign_player(player)
	self._player = player

	self._local_user_handler:player_assigned(self)
end

function User:release_player()
	self._local_user_handler:player_removed()

	self._player = nil
	self._avatar = nil
end

function User:assigned_player()
	return self._player
end

function User:local_user_handler()
	return self._local_user_handler
end

function User:profile_settings()
	return self._storage:profile_settings()
end

function User:profile_progress()
	return self._storage:profile_progress()
end

function User:save_profile_settings()
	return self._storage:request_save()
end

function User:save_profile_progress()
	return self._storage:request_save()
end

function User:engine_input_input_input_provider()
	return self._input_input_provider
end

function User:update(t, dt)
	if not self._avatar and self._player and self._player:has_avatar() then
		local input_input_provider = self:engine_input_input_input_provider()
		local avatar = self._player:avatar()

		avatar:set_input(input_input_provider)

		self._avatar = avatar
	end

	self._local_user_handler:update(t, dt)
end
