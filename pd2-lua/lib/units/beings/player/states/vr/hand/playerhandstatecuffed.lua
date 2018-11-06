require("lib/units/beings/player/states/vr/hand/PlayerHandState")

PlayerHandStateCuffed = PlayerHandStateCuffed or class(PlayerHandState)

function PlayerHandStateCuffed:init(hsm, name, hand_unit, sequence)
	PlayerHandStateCuffed.super.init(self, name, hsm, hand_unit, sequence)
end

function PlayerHandStateCuffed:at_enter(prev_state)
	PlayerHandStateCuffed.super.at_enter(self, prev_state)
	self:hsm():enter_controller_state("empty")

	self._cuff_unit = World:spawn_unit(Idstring("units/equipment/handcuffs_first_person/handcuffs_first_person"), self._hand_unit:position(), self._hand_unit:rotation())

	self._hand_unit:link(Idstring("g_glove"), self._cuff_unit, self._cuff_unit:orientation_object():name())
	self._cuff_unit:set_local_rotation(Rotation(0, 90, 180))
	self._cuff_unit:set_local_position(Vector3(self:hsm():hand_id() == PlayerHand.RIGHT and 1 or -1, -9, 0))
end

function PlayerHandStateCuffed:at_exit(next_state)
	PlayerHandStateCuffed.super.at_exit(self, next_state)
	self._cuff_unit:unlink()
	self._cuff_unit:set_slot(0)
end
