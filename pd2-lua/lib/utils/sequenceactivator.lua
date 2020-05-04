SequenceActivator = SequenceActivator or class()

function SequenceActivator:init(unit)
	local count = #self._sequences

	for i = 1, count do
		unit:damage():run_sequence_simple(self._sequences[i])

		self._sequences[i] = nil
	end

	self._sequences = nil
end
