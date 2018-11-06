core:module("CoreSessionStateInSession")
core:import("CoreSessionStateInSessionStarted")

InSessionStart = InSessionStart or class()

function InSessionStart:init(session)
	assert(session)

	self._session = session
end

function InSessionStart:destroy()
end

function InSessionStart:transition()
	return CoreSessionStateInSessionStarted.Started, self._session
end
