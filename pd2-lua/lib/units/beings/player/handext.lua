HandExt = HandExt or class()

function HandExt:init(hand_unit)
	self._unit = hand_unit
end

function HandExt:set_other_hand_unit(other_unit)
	self._other_hand_unit = other_unit
	self._other_hand_base = other_unit:base()
end

function HandExt:set_hand_data(hand_data)
	self._hand_data = hand_data
end

function HandExt:other_hand_unit()
	return self._other_hand_unit
end

function HandExt:other_hand_base()
	return self._other_hand_base
end

function HandExt:position()
	return self._hand_data.position
end

function HandExt:finger_position()
	return self._hand_data.finger_position
end

function HandExt:rotation()
	return self._hand_data.rotation
end

function HandExt:raw_rotation()
	return self._hand_data.raw_rotation
end

function HandExt:name()
	return self._hand_data.hand
end

function HandExt:unit()
	return self._unit
end

function HandExt:post_event(event, sound_source)
	self._unit:sound_source(sound_source):post_event(event)
end

function HandExt:update_variables()
end
