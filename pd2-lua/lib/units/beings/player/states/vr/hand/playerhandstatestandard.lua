require("lib/units/beings/player/states/vr/hand/PlayerHandState")

PlayerHandStateStandard = PlayerHandStateStandard or class(PlayerHandState)

function PlayerHandStateStandard:init(hsm, name, hand_unit, sequence)
	PlayerHandStateStandard.super.init(self, name, hsm, hand_unit, sequence)
end

function PlayerHandStateStandard:at_enter(prev_state)
	PlayerHandStateStandard.super.at_enter(self, prev_state)
	self:hsm():enter_controller_state("empty")

	self._check_first = true
end

function PlayerHandStateStandard:update(t, dt)
	local controller = managers.vr:hand_state_machine():controller()
	local interact_button = self:hsm():hand_id() == PlayerHand.LEFT and "interact_left" or "interact_right"

	if controller:get_input_pressed(interact_button) or self._check_first and controller:get_input_bool(interact_button) then
		self._check_first = nil
		local sequence = "grip"

		if self._hand_unit:damage():has_sequence(sequence) then
			self._hand_unit:damage():run_sequence_simple(sequence)
		end
	elseif controller:get_input_released(interact_button) then
		local sequence = self._sequence

		if self._hand_unit:damage():has_sequence(sequence) then
			self._hand_unit:damage():run_sequence_simple(sequence)
		end
	end
end
