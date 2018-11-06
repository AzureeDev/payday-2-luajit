core:module("CoreSessionManager")
core:import("CoreMenuState")
core:import("CoreGameState")
core:import("CoreDialogState")
core:import("CoreFreezeState")
core:import("CorePlayerSlots")
core:import("CoreLocalUserManager")
core:import("CoreSessionState")
core:import("CoreSessionDebug")
core:import("CoreDebug")

SessionManager = SessionManager or class()

function SessionManager:init(session_factory, input_manager)
	if not session_factory then
		return
	end

	assert(session_factory ~= nil, "SessionManager must have a valid session_factory to work")

	self._factory = session_factory
	local settings_handler = self._factory:create_profile_settings_handler()
	local progress_handler = self._factory:create_profile_progress_handler()
	self._local_user_manager = CoreLocalUserManager.Manager:new(self._factory, settings_handler, progress_handler, input_manager)
	self._player_slots = CorePlayerSlots.PlayerSlots:new(self._local_user_manager, self._factory)

	self._player_slots:add_player_slot()

	local game_state = CoreGameState.GameState:new(self._player_slots, self)
	local menu_handler = self._factory:create_menu_handler()
	local menu_state = CoreMenuState.MenuState:new(game_state, menu_handler, self._player_slots)
	local dialog_state = CoreDialogState.DialogState:new()
	local freeze_state = CoreFreezeState.FreezeState:new()
	self._session_state = CoreSessionState.SessionState:new(self._factory, self._player_slots, game_state)
	self._factory.session_establisher = self._session_state
	self._state_machines = {
		game_state,
		menu_state,
		dialog_state,
		freeze_state,
		self._player_slots,
		self._local_user_manager,
		self._session_state
	}
	self._state_machines_except_menu_and_game = {
		dialog_state,
		freeze_state,
		self._player_slots,
		self._local_user_manager,
		self._session_state
	}
	self._debug = CoreSessionDebug.SessionDebug:new(self._session_state)
end

function SessionManager:destroy()
end

function SessionManager:_main_systems_are_stable_for_loading()
	return self:_check_if_stable_for_loading(self._state_machines_except_menu_and_game)
end

function SessionManager:all_systems_are_stable_for_loading()
	return self:_check_if_stable_for_loading(self._state_machines)
end

function SessionManager:_check_if_stable_for_loading(collection)
	for _, state in pairs(collection) do
		if not state:is_stable_for_loading() then
			cat_print("debug", CoreDebug.full_class_name(state) .. " is not ready....")

			return false
		end
	end

	return true
end

function SessionManager:_update(t, dt)
	if not self._factory then
		return
	end

	self._local_user_manager:update(t, dt)

	self._debug_timer = (self._debug_timer or 0) + dt

	for _, state in pairs(self._state_machines) do
		if state.update then
			state:update(t, dt)
		end

		state:transition()
	end
end

function SessionManager:end_update(t, dt)
	if not self._factory then
		return
	end

	for _, state in pairs(self._state_machines) do
		if state.end_update then
			state:end_update(t, dt)
		end
	end
end

function SessionManager:update(t, dt)
	self:_update(t, dt)
end

function SessionManager:paused_update(t, dt)
	self:_update(t, dt)
end

function SessionManager:player_slots()
	return self._player_slots
end

function SessionManager:session()
	return self._session_state
end

function SessionManager:_debug_time()
	return self._debug_timer
end
