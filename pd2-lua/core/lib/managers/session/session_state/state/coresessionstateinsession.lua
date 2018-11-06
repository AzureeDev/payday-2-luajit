core:module("CoreSessionStateInSession")
core:import("CoreSessionStateQuitSession")

InSession = InSession or class()

function InSession:init(session)
	assert(session)

	self._session = session

	self._session._session_handler:joined_session()
	self.session_state._game_state:request_game()
	self.session_state:player_slots():create_players()
end

function InSession:destroy()
	self.session_state:player_slots():remove_players()
end

function InSession:transition()
	if self._start_session then
		return CoreSessionStateInSessionStart, self._session
	end

	if self.session_state._quit_session_requester:is_requested() then
		return CoreSessionStateQuitSession.QuitSession, self._session
	end
end

function InSession:start_session()
	self._start_session = true
end
