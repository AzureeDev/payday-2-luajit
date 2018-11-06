HuskCopMovement = HuskCopMovement or class(CopMovement)

function HuskCopMovement:init(unit)
	CopMovement.init(self, unit)

	self._queued_actions = {}
	self._m_host_stop_pos = mvector3.copy(self._m_pos)
end

function HuskCopMovement:_upd_actions(t)
	CopMovement._upd_actions(self, t)
	self:_chk_start_queued_action()
end

function HuskCopMovement:action_request(action_desc)
	self:enable_update(false)

	local function _chk_would_interrupt(b_part)
		if self._active_actions[1] and self._active_actions[1]:type() == "idle" then
			return
		end

		return self._active_actions[b_part] or self._active_actions[1] or b_part == 1 and (self._active_actions[2] or self._active_actions[3])
	end

	if self:chk_action_forbidden(action_desc) or not action_desc.client_interrupt and (next(self._queued_actions) or _chk_would_interrupt(action_desc.body_part)) then
		self:_push_back_queued_action(action_desc)
	else
		local new_action_body_part = action_desc.body_part

		for body_part, active_action in ipairs(self._active_actions) do
			if active_action and active_action.get_husk_interrupt_desc and (body_part == 1 and new_action_body_part ~= 4 or new_action_body_part == 1 or body_part == new_action_body_part) then
				local old_action_desc = active_action:get_husk_interrupt_desc()

				self:_push_front_queued_action(old_action_desc)
			end
		end

		local new_action = HuskCopMovement.super.action_request(self, action_desc)

		self:_chk_start_queued_action()

		return new_action
	end
end

function HuskCopMovement:chk_action_forbidden(action_desc)
	local t = TimerManager:game():time()
	local block_type = action_desc.block_type or action_desc.type

	for i_action, action in ipairs(self._active_actions) do
		if action then
			if action.chk_block_client then
				if action:chk_block_client(action_desc, block_type, t) then
					return true
				end
			elseif action.chk_block and action:chk_block(block_type, t) then
				return true
			end
		end
	end
end
