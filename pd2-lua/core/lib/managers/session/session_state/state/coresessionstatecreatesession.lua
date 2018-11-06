core:module("CoreSessionStateCreateSession")
core:import("CoreSessionStateInSession")

CreateSession = CreateSession or class()

function CreateSession:init()
	local session_info = self.session_state._session_info
	local player_slots = self.session_state._player_slots
	self._session = self.session_state._session_creator:create_session(session_info, player_slots)
	self._session._session_handler = self.session_state._factory:create_session_handler()
	self._session._session_handler._core_session_control = self.session_state
	local local_users = self.session_state._local_user_manager:users()

	for _, local_user in pairs(local_users) do
		self._session:join_local_user(local_user)
	end
end

function CreateSession:transition()
	return CoreSessionStateInSession.InSession, self._session
end
