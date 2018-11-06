core:module("CoreSessionStateInSessionStarted")
core:import("CoreSessionStateQuitSession")
core:import("CoreSessionStateInSessionEnd")

InSessionStarted = InSessionStarted or class()

function InSessionStarted:init(session)
	assert(session)

	self._session = session

	self._session._session_handler:session_started()
end

function InSessionStarted:destroy()
end

function InSessionStarted:transition()
	if self.session_state._quit_session_requester:is_requested() then
		return CoreSessionStateQuitSession.Quit, self._session
	end

	if self._end_session then
		return CoreSessionStateInSessionEnd.InSessionEnd, self._session
	end
end

function InSessionStarted:end_session()
	self._end_session = true
end
