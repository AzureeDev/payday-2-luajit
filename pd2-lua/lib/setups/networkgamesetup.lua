require("lib/setups/GameSetup")
require("lib/network/base/NetworkManager")
require("lib/wip")

NetworkGameSetup = NetworkGameSetup or class(GameSetup)

function NetworkGameSetup:init_managers(managers)
	GameSetup.init_managers(self, managers)

	managers.network = NetworkManager:new()
end

function NetworkGameSetup:init_finalize()
	GameSetup.init_finalize(self)
	managers.network:init_finalize()
end

function NetworkGameSetup:update(t, dt)
	GameSetup.update(self, t, dt)
	managers.network:update(t, dt)
end

function NetworkGameSetup:paused_update(t, dt)
	GameSetup.paused_update(self, t, dt)
	managers.network:update(t, dt)
end

function NetworkGameSetup:end_update(t, dt)
	GameSetup.end_update(self, t, dt)
	managers.network:end_update()
end

function NetworkGameSetup:paused_end_update(t, dt)
	GameSetup.paused_end_update(self, t, dt)
	managers.network:end_update()
end

return NetworkGameSetup
