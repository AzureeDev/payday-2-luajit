require("lib/units/beings/player/states/vr/hand/PlayerHandState")

PlayerHandStateWeaponAssist = PlayerHandStateWeaponAssist or class(PlayerHandState)

function PlayerHandStateWeaponAssist:init(hsm, name, hand_unit, sequence)
	PlayerHandStateWeaponAssist.super.init(self, name, hsm, hand_unit, sequence)
end

function PlayerHandStateWeaponAssist:at_enter(prev_state)
	local weapon_unit = self:hsm():other_hand():current_state()._weapon_unit
	local weapon_tweak = alive(weapon_unit) and tweak_data.vr.weapon_assist.weapons[weapon_unit:base().name_id]
	local sequence = self._sequence
	local other_hand = self:hsm():other_hand():current_state()
	self._assist_position = other_hand:assist_position()

	if other_hand:assist_grip() then
		sequence = other_hand:assist_grip()
	end

	if self._hand_unit and sequence and self._hand_unit:damage():has_sequence(sequence) then
		self._hand_unit:damage():run_sequence_simple(sequence)
	end

	self:hsm():enter_controller_state("empty")

	managers.player:player_unit():movement():current_state()._start_intimidate = nil
end

function PlayerHandStateWeaponAssist:update(t, dt)
	local weapon_unit = self:hsm():other_hand():current_state()._weapon_unit

	if alive(weapon_unit) and self._assist_position then
		self._hand_unit:set_position(self:hsm():other_hand():position() + self._assist_position:rotate_with(weapon_unit:rotation()))
		self._hand_unit:set_moving(2)
	end
end
