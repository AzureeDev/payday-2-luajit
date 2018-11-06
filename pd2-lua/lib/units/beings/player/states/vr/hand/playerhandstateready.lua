require("lib/units/beings/player/states/vr/hand/PlayerHandState")

PlayerHandStateReady = PlayerHandStateReady or class(PlayerHandState)

function PlayerHandStateReady:init(hsm, name, hand_unit, sequence)
	PlayerHandStateReady.super.init(self, name, hsm, hand_unit, sequence)
end

function PlayerHandStateReady:at_enter(prev_state, blocked)
	PlayerHandStateReady.super.at_enter(self, prev_state)
	self:hsm():enter_controller_state("empty")
	managers.hud:link_watch_prompt(self._hand_unit, self:hsm():hand_id())
	managers.hud:watch_prompt_panel():show()
	self:set_blocked(blocked)
end

function PlayerHandStateReady:set_blocked(blocked)
	self._hand_unit:damage():run_sequence_simple(blocked and "ready_warning" or self._sequence)

	self._blocked = blocked
end

function PlayerHandStateReady:at_exit(next_state)
	PlayerHandStateReady.super.at_exit(self, next_state)
	managers.hud:watch_prompt_panel():hide()
end

function PlayerHandStateReady:update(t, dt)
	local controller = managers.vr:hand_state_machine():controller()
	local interact_button = self:hsm():hand_id() == PlayerHand.LEFT and "interact_left" or "interact_right"

	if controller:get_input_pressed(interact_button) then
		local sequence = self._blocked and "grip_warning" or "grip_success"

		if self._hand_unit:damage():has_sequence(sequence) then
			self._hand_unit:damage():run_sequence_simple(sequence)
		end
	elseif controller:get_input_released(interact_button) then
		local sequence = self._blocked and "ready_warning" or self._sequence

		if self._hand_unit:damage():has_sequence(sequence) then
			self._hand_unit:damage():run_sequence_simple(sequence)
		end
	end
end
