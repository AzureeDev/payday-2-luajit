SmallLootBase = SmallLootBase or class(UnitBase)

function SmallLootBase:init(unit)
	UnitBase.init(self, unit, false)

	self._unit = unit

	self:_setup()
end

function SmallLootBase:_setup()
end

function SmallLootBase:take(unit)
	if self._empty then
		return
	end

	unit:sound():play("money_grab")

	local small_loot_multiplier_upgrade_level = managers.player:upgrade_level("player", "small_loot_multiplier")
	local multiplier = managers.player:upgrade_value("player", "small_loot_multiplier", 1)

	managers.loot:show_small_loot_taken_hint(self.small_loot, multiplier)

	if Network:is_server() then
		self:taken(small_loot_multiplier_upgrade_level, managers.network:session() and managers.network:session():local_peer():id())
	else
		managers.network:session():send_to_host("sync_small_loot_taken", self._unit, small_loot_multiplier_upgrade_level)
	end
end

function SmallLootBase:taken(small_loot_multiplier_upgrade_level, peer_id)
	managers.loot:secure_small_loot(self.small_loot, small_loot_multiplier_upgrade_level, peer_id)
	self:_set_empty()
end

function SmallLootBase:_set_empty()
	self._empty = true

	if not self.skip_remove_unit then
		self._unit:set_slot(0)
	end
end

function SmallLootBase:destroy()
end
