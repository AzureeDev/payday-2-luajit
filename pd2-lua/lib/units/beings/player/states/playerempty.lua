PlayerEmpty = PlayerEmpty or class(PlayerMovementState)

function PlayerEmpty:init(unit)
	PlayerMovementState.init(self, unit)
end

function PlayerEmpty:enter(state_data, enter_data)
	PlayerMovementState.enter(self, state_data)
end

function PlayerEmpty:exit(state_data)
	PlayerMovementState.exit(self, state_data)
end

function PlayerEmpty:update(t, dt)
	PlayerMovementState.update(self, t, dt)
end

function PlayerEmpty:destroy()
end
