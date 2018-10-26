VanSkinExt = VanSkinExt or class()

function VanSkinExt:init(unit)
	self._unit = unit
	local skin_id = managers.blackmarket:equipped_van_skin()

	if Network:is_server() and skin_id then
		local van_data = tweak_data.van.skins[skin_id]

		if van_data.dlc and not managers.dlc:is_dlc_unlocked(van_data.dlc) then
			skin_id = tweak_data.van.default_skin_id
			van_data = tweak_data.van.skins[skin_id]
		end

		if unit:damage() and unit:damage():has_sequence(van_data.sequence_name) then
			unit:damage():run_sequence_simple(van_data.sequence_name)
		end
	end
end

