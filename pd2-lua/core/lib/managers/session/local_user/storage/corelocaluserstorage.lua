core:module("CoreLocalUserStorage")
core:import("CoreRequester")
core:import("CoreFiniteStateMachine")
core:import("CoreLocalUserStorageStates")
core:import("CoreSessionGenericState")

Storage = Storage or class(CoreSessionGenericState.State)

function Storage:init(local_user, settings_handler, progress_handler, profile_data_loaded_callback)
	self._load = CoreRequester.Requester:new()
	self._state = CoreFiniteStateMachine.FiniteStateMachine:new(CoreLocalUserStorageStates.Init, "storage", self)
	self._local_user = local_user
	self._user_index = self._local_user._user_index
	self._settings_handler = settings_handler
	self._progress_handler = progress_handler
	self._profile_data_loaded_callback = profile_data_loaded_callback
end

function Storage:transition()
	self._state:transition()
end

function Storage:request_load()
	self._load:request()
end

function Storage:request_save()
end

function Storage:_common_save_params()
	return {
		preview = false,
		save_slots = {
			1
		},
		user_index = self._user_index
	}
end

function Storage:_start_load_task()
	local save_param = self:_common_save_params()
	local callback = nil
	self._load_task = NewSave:load(save_param, callback)

	self._load:task_started()
end

function Storage:_load_status()
	if not self._load_task:has_next() then
		return
	end

	local profile_data = self._load_task:next()

	if profile_data:status() == SaveData.OK then
		self:_profile_data_loaded(profile_data:information())
	end

	return profile_data:status()
end

function Storage:_close_load_task()
	self._load_task = nil

	self._load:task_completed()
end

function Storage:_fast_forward_profile_data(handler, profile_data, stored_version)
	local func = nil

	repeat
		local function_name = "convert_from_" .. tostring(stored_version) .. "_to_" .. tostring(stored_version + 1)
		func = handler[function_name]

		if func ~= nil then
			profile_data = func(handler, profile_data)
			stored_version = stored_version + 1
		end
	until func == nil

	return profile_data, stored_version
end

function Storage:_profile_data_loaded(profile_data)
	profile_data.settings, profile_data.settings.version = self:_fast_forward_profile_data(self._settings_handler, profile_data.settings.title_data, profile_data.settings.version)
	profile_data.progress, profile_data.progress.version = self:_fast_forward_profile_data(self._progress_handler, profile_data.progress.title_data, profile_data.progress.version)
	self._profile_data = profile_data

	self._local_user:local_user_handler():profile_data_loaded()
end

function Storage:profile_data_is_loaded()
	return self._profile_data ~= nil
end

function Storage:_create_profile_data()
	local profile_data = {
		settings = {}
	}
	profile_data.settings.title_data = {}
	profile_data.settings.version = 0
	profile_data.progress = {
		title_data = {},
		version = 0
	}

	self:_profile_data_loaded(profile_data)
end

function Storage:profile_settings()
	return self._profile_data.settings.title_data
end

function Storage:profile_progress()
	return self._profile_data.progress.title_data
end
