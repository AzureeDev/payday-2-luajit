PlayerMovementState = PlayerMovementState or class()

function PlayerMovementState:init(unit)
	self._unit = unit
end

function PlayerMovementState:enter(state_data, enter_data)
end

function PlayerMovementState:exit(state_data)
end

function PlayerMovementState:update(t, dt)
end

function PlayerMovementState:chk_action_forbidden(action_type)
	if self._current_action then
		local unblock_data = self._current_action["unblock_" .. action_type .. "_t"]

		if unblock_data and (unblock_data == -1 or managers.player:player_timer():time() < unblock_data) then
			return true
		end
	end
end

function PlayerMovementState:_reset_delay_action()
	self._delay_action = nil
end

function PlayerMovementState:_set_delay_action(action_data)
	if self._delay_action then
		self:_reset_delay_action()
	end

	self._delay_action = action_data
end

function PlayerMovementState:_reset_current_action()
	local previous_action = self._current_action

	if previous_action and self["_end_action_" .. previous_action.type] then
		self["_end_action_" .. previous_action.type](self, previous_action)

		if previous_action.root_blending_disabled then
			self._machine:set_root_blending(true)
		end
	end

	self._current_action = nil
end

function PlayerMovementState:_set_current_action(action_data)
	if self._current_action then
		self:_reset_current_action()
	end

	self._current_action = action_data
end

function PlayerMovementState:interaction_blocked()
	return false
end

function PlayerMovementState:save(data)
end

function PlayerMovementState:pre_destroy()
end

function PlayerMovementState:destroy()
end
