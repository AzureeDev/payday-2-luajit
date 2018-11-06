core:module("CoreMenuStateNone")
core:import("CoreMenuStatePreFrontEndOnce")
core:import("CoreMenuStateInEditor")

None = None or class()

function None:transition()
	local state = self.menu_state._game_state

	if not state:is_in_init() then
		if state:is_in_editor() then
			return CoreMenuStateInEditor.InEditor
		else
			return CoreMenuStatePreFrontEndOnce.PreFrontEndOnce
		end
	end
end
