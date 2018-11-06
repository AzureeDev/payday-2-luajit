PlayerActionManager = PlayerActionManager or class()

function PlayerActionManager:init()
	self._actions = {}
	self._buffer = {}
end

function PlayerActionManager:update(t, dt)
	self:_add()

	for key, value in pairs(self._actions) do
		if value and value:update(t, dt) then
			if value.on_exit then
				value:on_exit()
			end

			self._actions[key] = nil
		end
	end
end

function PlayerActionManager:add_action(name, action)
	if not self._buffer[name] and not self._actions[name] then
		self._buffer[name] = action
	end
end

function PlayerActionManager:_add()
	for key, value in pairs(self._buffer) do
		if value.on_enter then
			value:on_enter()
		end

		self._actions[key] = value
		self._buffer[key] = nil
	end

	self._buffer = nil
	self._buffer = {}
end

function PlayerActionManager:is_running(name)
	return self._actions[name]
end
