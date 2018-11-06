core:module("CoreMenuStateAttract")
core:import("CoreMenuStateStart")
core:import("CoreSessionResponse")

Attract = Attract or class()

function Attract:init()
	local menu_handler = self.pre_front_end.menu_state._menu_handler
	self._response = CoreSessionResponse.Done:new()

	menu_handler:attract(self._response)
end

function Attract:destroy()
	self._response:destroy()
end

function Attract:transition()
	if self._response:is_done() or Input:any_input() then
		return CoreMenuStateStart.Start
	end
end
