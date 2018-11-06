core:module("CoreMenuStateInEditor")
core:import("CoreMenuStateInGame")

InEditor = InEditor or class(CoreMenuStateInGame.InGame)

function InEditor:init()
	self.menu_state:_set_stable_for_loading()
end

function InEditor:destroy()
	self.menu_state:_not_stable_for_loading()
end
