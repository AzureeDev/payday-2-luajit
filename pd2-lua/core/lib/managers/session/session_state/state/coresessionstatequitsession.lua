core:module("CoreSessionStateQuitSession")
core:import("CoreSessionStateInit")

QuitSession = QuitSession or class()

function QuitSession:init(session)
	self._session = session

	self.session_state._quit_session_requester:task_started()
	self.session_state:player_slots():clear_session()
	self.session_state._game_state:request_front_end()
	self._session:delete_session()
end

function QuitSession:destroy()
	self.session_state._quit_session_requester:task_completed()

	self.session_state._session = nil
end

function QuitSession:transition()
	return CoreSessionStateInit.Init, self._session
end
