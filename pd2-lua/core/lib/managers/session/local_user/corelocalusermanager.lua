core:module("CoreLocalUserManager")
core:import("CoreLocalUser")
core:import("CoreSessionGenericState")

Manager = Manager or class(CoreSessionGenericState.State)

function Manager:init(factory, profile_settings_handler, profile_progress_handler, input_manager)
	self._factory = factory
	self._controller_to_user = {}
	self._profile_settings_handler = profile_settings_handler
	self._profile_progress_handler = profile_progress_handler
	self._profile_data_loaded_callback = profile_data_loaded_callback
	self._input_manager = input_manager
end

function Manager:has_local_user_with_input_provider_id(controller)
	return self._controller_to_user[controller:key()] ~= nil
end

function Manager:debug_bind_primary_input_provider_id(player_slot)
	local count = Input:num_real_controllers()
	local best_controller = nil

	for i = 0, count do
		local controller = Input:controller(i)

		if controller:connected() then
			local c_type = controller:type()

			if c_type == "xbox_controller" then
				best_controller = controller

				break
			elseif best_controller == nil then
				best_controller = controller
			end
		end
	end

	return self:bind_local_user(player_slot, best_controller)
end

function Manager:bind_local_user(slot, input_provider_id)
	local input_provider = self._input_manager:_create_input_provider_for_controller(input_provider_id)
	local local_user = self._controller_to_user[input_provider_id:key()]

	if not local_user then
		local user_index = nil

		if input_provider_id.user_index then
			user_index = input_provider_id:user_index()
		end

		local_user = self:_create_local_user(input_provider, user_index)
		self._controller_to_user[input_provider_id:key()] = local_user
	end

	slot:assign_local_user(local_user)

	return local_user
end

function Manager:_create_local_user(input_provider, user_index)
	local local_user_handler = self._factory:create_local_user_handler()
	local created_user = CoreLocalUser.User:new(local_user_handler, input_provider, user_index, self._profile_settings_handler, self._profile_progress_handler, self._profile_data_loaded_callback)
	local_user_handler._core_local_user = created_user

	return created_user
end

function Manager:transition()
	for _, user in pairs(self._controller_to_user) do
		user:transition()
	end
end

function Manager:is_stable_for_loading()
	for _, user in pairs(self._controller_to_user) do
		if not user:is_stable_for_loading() then
			return false
		end
	end

	return true
end

function Manager:users()
	return self._controller_to_user
end

function Manager:update(t, dt)
	for _, user in pairs(self._controller_to_user) do
		user:update(t, dt)
	end
end

function Manager:enter_level_handler(level_handler)
	for _, user in pairs(self._controller_to_user) do
		user:enter_level(level_handler)
	end
end

function Manager:leave_level_handler(level_handler)
	for _, user in pairs(self._controller_to_user) do
		user:leave_level(level_handler)
	end
end
