core:module("CoreSessionStateJoinSession")
core:import("CoreSessionStateInSession")

JoinSession = JoinSession or class()

function JoinSession:init(session_id)
	self.session_state._join_session_requester:task_started()

	self._session = self.session_state._session_creator:join_session(session_id)
	self._session._session_handler = self.session_state._factory:create_session_handler()
	self._session._session_handler._core_session_control = self.session_state
end

function JoinSession:destroy()
	self.session_state._join_session_requester:task_completed()
end

function JoinSession:transition()
	return CoreSessionStateInSession.InSession, self._session
end
