core:module("CoreSlotManager")

SlotManager = SlotManager or class()

function SlotManager:init()
	local unit_manager = World:unit_manager()

	unit_manager:set_slot_limited(0, 0)
	unit_manager:set_slot_infinite(1)
	unit_manager:set_slot_infinite(10)
	unit_manager:set_slot_infinite(11)
	unit_manager:set_slot_infinite(15)
	unit_manager:set_slot_infinite(19)
	unit_manager:set_slot_infinite(29)
	unit_manager:set_slot_infinite(35)

	self._masks = {
		statics = World:make_slot_mask(1, 15, 36),
		editor_all = World:make_slot_mask(1, 10, 11, 15, 19, 35, 36),
		mission_elements = World:make_slot_mask(10),
		surface_move = World:make_slot_mask(1, 11, 20, 21, 24, 35, 38),
		hub_elements = World:make_slot_mask(10),
		sound_layer = World:make_slot_mask(19),
		environment_layer = World:make_slot_mask(19),
		portal_layer = World:make_slot_mask(19),
		ai_layer = World:make_slot_mask(19),
		dynamics = World:make_slot_mask(11),
		statics_layer = World:make_slot_mask(1, 11, 15),
		dynamics_layer = World:make_slot_mask(11),
		dump_all = World:make_slot_mask(1),
		wires = World:make_slot_mask(35),
		brush_placeable = World:make_slot_mask(1),
		brushes = World:make_slot_mask(29)
	}
end

function SlotManager:get_mask(...)
	local mask = nil
	local arg_list = {
		...
	}

	for _, name in pairs(arg_list) do
		local next_mask = self._masks[name]

		if next_mask then
			if not mask then
				mask = next_mask
			else
				mask = mask + next_mask
			end
		else
			Application:error("Invalid slotmask \"" .. tostring(name) .. "\".")
		end
	end

	if #arg_list == 0 then
		Application:error("No parameters passed to get_mask function.")
	end

	return mask
end

function SlotManager:get_mask_name(slotmask)
	return table.get_key(self._masks, slotmask)
end

function SlotManager:get_mask_map()
	return self._masks
end
