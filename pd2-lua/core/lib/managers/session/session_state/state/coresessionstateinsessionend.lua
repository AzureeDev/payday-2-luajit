core:module("CoreSessionStateInSessionEnd")
core:import("CoreSessionStateInit")

InSessionEnd = InSessionEnd or class()

function InSessionEnd:init(session)
	assert(session)

	self._session = session

	self._session._session_handler:session_ended()
end

function InSessionEnd:destroy()
end

function InSessionEnd:transition()
	return CoreSessionStateInit
end
