UnoPuzzleDoorBase = UnoPuzzleDoorBase or class(UnitBase)
UnoPuzzleDoorBase.RIDDLE_COUNT = 4

function UnoPuzzleDoorBase:init(unit)
	UnoPuzzleDoorBase.super.init(self, unit, true)

	self._outer = UnoPuzzleDoorRing:new(unit:get_object(Idstring("a_outer_ring")), 26)
	self._middle = UnoPuzzleDoorRing:new(unit:get_object(Idstring("a_middle_ring")), 26)
	self._inner = UnoPuzzleDoorRing:new(unit:get_object(Idstring("a_inner_ring")), 26)
	local riddle_ids = {}

	for i = 1, #tweak_data.safehouse.uno_door_riddles do
		riddle_ids[i] = i
	end

	table.shuffle(riddle_ids)

	for i = UnoPuzzleDoorBase.RIDDLE_COUNT + 1, #riddle_ids do
		riddle_ids[i] = nil
	end

	self._riddle_ids = riddle_ids
	self._rings_moving = false
	self._sound_source = self._unit:sound_source(Idstring("snd"))
end

function UnoPuzzleDoorBase:init_puzzle()
	Steam:sa_handler():set_stat("uno_puzzle_door_activated", 1)
	self:set_riddle(1)
end

function UnoPuzzleDoorBase:update(unit, t, dt)
	if not self._current_riddle then
		return
	end

	self._unit:set_moving()

	local rotating = false
	rotating = self._outer:update(t, dt) or rotating
	rotating = self._middle:update(t, dt) or rotating
	rotating = self._inner:update(t, dt) or rotating

	if rotating ~= self._rings_moving then
		local sound_event = rotating and "uno_door_puzzle_rotate_start" or "uno_door_puzzle_rotate_stop"

		self._sound_source:post_event(sound_event)

		self._rings_moving = rotating
	end
end

function UnoPuzzleDoorBase:save(data)
	data.puzzle_door_riddles = self._riddle_ids
end

function UnoPuzzleDoorBase:load(data)
	self._riddle_ids = data.puzzle_door_riddles
end

function UnoPuzzleDoorBase:set_riddle(current_riddle)
	if current_riddle == self._current_riddle then
		return
	end

	local riddle_id = self._riddle_ids[current_riddle]
	self._current_riddle = current_riddle
	self._solution = tweak_data.safehouse.uno_door_riddles[riddle_id]

	self._unit:damage():run_sequence_simple("set_riddle_seq_" .. current_riddle)
	self._unit:damage():run_sequence_simple("set_riddle_" .. riddle_id)
end

function UnoPuzzleDoorBase:submit_answer()
	local stops = {
		self._outer:current_stop(),
		self._middle:current_stop(),
		self._inner:current_stop()
	}
	local submitted_key = string.join(":", stops):key()
	local success = submitted_key == self._solution

	self._unit:damage():run_sequence_simple(success and "answer_success" or "answer_fail")

	if not success then
		self:set_riddle(1)

		return
	end

	local all_done = self._current_riddle == self.RIDDLE_COUNT

	if all_done then
		self._unit:damage():run_sequence_simple("all_riddles_solved")
	else
		self:set_riddle(self._current_riddle + 1)
	end
end

function UnoPuzzleDoorBase:revive_player()
	local player = managers.player:player_unit()

	if player and player:character_damage():need_revive() then
		player:character_damage():revive(true)
	end

	if Network:is_server() then
		for _, character in ipairs(managers.criminals:characters()) do
			if character.data.ai and alive(character.unit) then
				character.unit:character_damage():revive(nil, true)
			end
		end
	end
end

function UnoPuzzleDoorBase:turn_outer_cw()
	self._outer:turn_clockwise()
end

function UnoPuzzleDoorBase:turn_outer_ccw()
	self._outer:turn_counterclockwise()
end

function UnoPuzzleDoorBase:turn_middle_cw()
	self._middle:turn_clockwise()
end

function UnoPuzzleDoorBase:turn_middle_ccw()
	self._middle:turn_counterclockwise()
end

function UnoPuzzleDoorBase:turn_inner_cw()
	self._inner:turn_clockwise()
end

function UnoPuzzleDoorBase:turn_inner_ccw()
	self._inner:turn_counterclockwise()
end

UnoPuzzleDoorRing = UnoPuzzleDoorRing or class()
UnoPuzzleDoorRing.SPEED = 10
UnoPuzzleDoorRing.EPSILON = 0.0001

function UnoPuzzleDoorRing:init(ring_object, stops)
	self._object = ring_object
	self._stops = stops
	self._current_stop = 0
	self._target = Rotation()
end

function UnoPuzzleDoorRing:update(t, dt)
	local rotation = self._object:local_rotation()
	local diff = Rotation:rotation_difference(rotation, self._target)
	local max_rotation = dt * self.SPEED
	local angle = math.clamp(diff:roll(), -max_rotation, max_rotation)

	self._object:set_local_rotation(rotation * Rotation(Vector3(0, 1, 0), angle))

	return self.EPSILON < math.abs(angle)
end

function UnoPuzzleDoorRing:current_stop()
	return self._current_stop
end

function UnoPuzzleDoorRing:_target_stop(stop)
	local angle = 360 / self._stops * stop
	self._target = Rotation(Vector3(0, 1, 0), angle)
end

function UnoPuzzleDoorRing:turn_clockwise()
	self._current_stop = math.mod(self._current_stop + 1, self._stops)

	self:_target_stop(self._current_stop)
end

function UnoPuzzleDoorRing:turn_counterclockwise()
	self._current_stop = self._current_stop - 1

	if self._current_stop < 0 then
		self._current_stop = self._stops - 1
	end

	self:_target_stop(self._current_stop)
end
