SpecialEquipmentPickup = SpecialEquipmentPickup or class(Pickup)

function SpecialEquipmentPickup:init(unit)
	SpecialEquipmentPickup.super.init(self, unit)
	managers.occlusion:remove_occlusion(unit)
end

function SpecialEquipmentPickup:_pickup(unit)
	local equipment = unit:equipment()

	if not unit:character_damage():dead() and equipment and managers.player:can_pickup_equipment(self._special) then
		managers.player:add_special({
			name = self._special,
			amount = self._amount
		})

		if Network:is_client() then
			managers.network:session():send_to_host("sync_pickup", self._unit)
		end

		if self._global_event then
			managers.mission:call_global_event(self._global_event, unit)
		end

		unit:sound():play("pickup_ammo", nil, true)
		self:consume()

		return true
	end

	return false
end

function SpecialEquipmentPickup:destroy(...)
	managers.occlusion:add_occlusion(self._unit)
	SpecialEquipmentPickup.super.destroy(self, ...)
end
