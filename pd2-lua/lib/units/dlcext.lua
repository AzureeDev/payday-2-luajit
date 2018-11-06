DLCExt = DLCExt or class()

function DLCExt:init(unit)
	self._unit = unit

	if Network:is_server() and self._sequence_dlc then
		local free_dlcs = tweak_data:free_dlc_list()
		local unlocked = free_dlcs[self._sequence_dlc] or managers.dlc:is_dlc_unlocked(self._sequence_dlc)

		if unlocked and unit:damage() and unit:damage():has_sequence(self._sequence_name) then
			unit:damage():run_sequence_simple(self._sequence_name)
		end
	end
end
