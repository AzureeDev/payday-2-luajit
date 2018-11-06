core:module("CoreMenuStatePrepareLoadingFrontEnd")
core:import("CoreSessionResponse")
core:import("CoreMenuStatePreFrontEnd")
core:import("CoreMenuStateLoadingFrontEnd")

PrepareLoadingFrontEnd = PrepareLoadingFrontEnd or class()

function PrepareLoadingFrontEnd:init()
	self._response = CoreSessionResponse.Done:new()
	local menu_handler = self.menu_state._menu_handler

	menu_handler:prepare_loading_front_end(self._response)
end

function PrepareLoadingFrontEnd:destroy()
	self._response:destroy()
end

function PrepareLoadingFrontEnd:transition()
	if self._response:is_done() then
		return CoreMenuStateLoadingFrontEnd.LoadingFrontEnd
	end
end
