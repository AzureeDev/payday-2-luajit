UnoPianoBase = UnoPianoBase or class(UnitBase)
UnoPianoBase.SEQUENCE_LENGTH = 9

function UnoPianoBase:init(unit)
	UnoPianoBase.super.init(self, unit, false)

	self._notes_played = {}
end

function UnoPianoBase:note_played(note)
	if self.SEQUENCE_LENGTH <= #self._notes_played then
		for i = 1, #self._notes_played - 1 do
			self._notes_played[i] = self._notes_played[i + 1]
		end
	end

	local new_index = math.min(#self._notes_played + 1, self.SEQUENCE_LENGTH)
	self._notes_played[new_index] = note

	if self:validate_sequence(self._notes_played) then
		self._unit:damage():run_sequence_simple("puzzle_done")
	end
end

function UnoPianoBase:validate_sequence(sequence)
	if #sequence ~= self.SEQUENCE_LENGTH then
		return false
	end

	local sequence_key = string.join(":", sequence):key()

	return sequence_key == tweak_data.safehouse.uno_notes
end
