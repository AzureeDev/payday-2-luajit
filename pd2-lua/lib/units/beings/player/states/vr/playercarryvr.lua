PlayerCarryVR = PlayerCarry or Application:error("PlayerCarryVR requires PlayerCarry!")
__enter = PlayerCarry.enter
__exit = PlayerCarry.exit
__check_use_item = PlayerCarry._check_use_item

function PlayerCarryVR:enter(state_data, enter_data)
	__enter(self, state_data, enter_data)

	self._should_set_hand_carry = true
	self._should_skip_hand = enter_data and enter_data.skip_hand_carry
end

function PlayerCarryVR:exit(...)
	self._unit:hand():set_carry(false)

	return __exit(self, ...)
end

local __update = PlayerCarry.update

function PlayerCarryVR:update(t, dt)
	if self._should_set_hand_carry then
		self._unit:hand():set_carry(true, self._should_skip_hand)

		self._should_set_hand_carry = nil
	end

	__update(self, t, dt)
end

function PlayerCarryVR:_check_use_item(t, input)
	local new_action = nil

	if not input.btn_throw_bag_press then
		return PlayerStandard._check_use_item(self, t, input)
	end

	local action_forbidden = self._use_item_expire_t or self:_changing_weapon() or self:_interacting() or self._ext_movement:has_carry_restriction() or self:_is_throwing_projectile() or self:_on_zipline() or self._unit:hand():check_hand_through_wall(self._unit:hand():get_active_hand_id("bag"))

	if not action_forbidden then
		managers.player:drop_carry()
		managers.player:player_unit():movement():current_state():set_throwing_projectile(self._unit:hand():get_active_hand_id("bag"))

		new_action = true
	end

	return new_action
end

function PlayerCarryVR:_can_run()
	if tweak_data.carry.types[self._tweak_data_name].can_run or managers.player:has_category_upgrade("carry", "movement_penalty_nullifier") then
		return true
	end

	return false
end

local __get_input = PlayerCarry._get_input

function PlayerCarryVR:_get_input(...)
	local input = __get_input(self, ...)

	if self._controller:enabled() then
		input.btn_throw_bag_press = self._unit:hand():get_active_hand("bag") and self._controller:get_input_pressed("use_item_vr")
	end

	return input
end
