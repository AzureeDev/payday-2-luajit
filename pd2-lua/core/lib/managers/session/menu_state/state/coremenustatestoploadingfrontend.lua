core:module("CoreMenuStateStopLoadingFrontEnd")
core:import("CoreSessionResponse")
core:import("CoreMenuStatePreFrontEnd")
core:import("CoreMenuStateFrontEnd")

StopLoadingFrontEnd = StopLoadingFrontEnd or class()

function StopLoadingFrontEnd:init()
	local menu_handler = self.menu_state._menu_handler
	self._response = CoreSessionResponse.Done:new()

	menu_handler:stop_loading_front_end_environment(self._response)
end

function StopLoadingFrontEnd:destroy()
	self._response:destroy()
end

function StopLoadingFrontEnd:transition()
	if not self._response:is_done() then
		return
	end

	return CoreMenuStatePreFrontEnd.PreFrontEnd
end
