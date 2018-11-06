core:import("CoreSetup")
core:import("CoreGameStateMachine")
core:import("CoreInternalGameState")
core:import("CoreSlaveUpdators")

slave_state_machine = slave_state_machine or nil
SetupSlaveSetup = SetupSlaveSetup or class(CoreSetup.CoreSetup)
SetupSlaveSetup.SLAVE_ARG_NAME = "-slave"
SetupSlaveSetup.SLAVE_LSP_ARG_NAME = "-slavelsport"

function SetupSlaveSetup:init_game()
	self._viewport = managers.viewport:new_vp(0, 0, 1, 1, "slave")
	self._camera = World:create_camera()

	self._camera:set_near_range(10)
	self._camera:set_far_range(100000)
	self._camera:set_fov(75)
	self._viewport:set_camera(self._camera)
	self._viewport:set_active(true)

	local port = CoreApp.arg_value(self.SLAVE_ARG_NAME)

	if port then
		port = string.lower(port)
		port = port ~= "default" and tonumber(port) or CoreSlaveUpdators.DEFAULT_NETWORK_PORT
	end

	local lsport = CoreApp.arg_value(self.SLAVE_LSP_ARG_NAME)

	if lsport then
		lsport = string.lower(lsport)
		lsport = lsport ~= "default" and tonumber(lsport) or CoreSlaveUpdators.DEFAULT_NETWORK_LSPORT
	end

	assert(managers.slave:start(self._viewport, port, lsport))

	slave_state_machine = CoreGameStateMachine.GameStateMachine:new(CoreInternalGameState.GameState:new("empty"))

	return slave_state_machine
end

function SetupSlaveSetup:update(t, dt)
	slave_state_machine:update(t, dt)
end

function SetupSlaveSetup:paused_update(t, dt)
	slave_state_machine:update(t, dt)
end

slave_setup = slave_setup or SetupSlaveSetup:new()

slave_setup:make_entrypoint()
