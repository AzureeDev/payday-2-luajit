PromoUnlockManager = PromoUnlockManager or class()
PromoUnlockManager.save_version = 1

function PromoUnlockManager:init()
	self._items = {}

	for cat_id, category in pairs(tweak_data.promo_unlocks.promos) do
		for item_id, data in pairs(category) do
			self._items[item_id] = clone(data)
			self._items[item_id].category = cat_id
		end
	end
end

function PromoUnlockManager:check_unlocks()
end

function PromoUnlockManager:_check_achievement(achievement_id)
	for item_id, item in pairs(self._items) do
		if item.achievement == achievement_id then
			item.unlocked = true

			print("[PromoUnlockManager] Unlocked promo item: ", item_id)
		end
	end
end

function PromoUnlockManager:_get_item(id)
	for item_id, item in pairs(self._items) do
		if item_id == id then
			return item
		end
	end

	return nil
end

function PromoUnlockManager:_unlock_item(id)
	local item = self:_get_item(id)

	if item then
		item.unlocked = true

		print("[PromoUnlockManager] Unlocked promo item: ", id)
	end
end

function PromoUnlockManager:has_unlocked(item_id)
	return self._items[item_id] and self._items[item_id].unlocked
end

function PromoUnlockManager:get_data_for_weapon(weapon_id)
	for item_id, item in pairs(self._items) do
		if item.weapon_id and item.weapon_id == weapon_id then
			return item
		end
	end

	return nil
end

function PromoUnlockManager:save(cache)
	local data = {
		version = self.save_version,
		items = {}
	}

	for item_id, item in pairs(self._items) do
		data.items[item_id] = item.unlocked or false
	end

	cache.promo_unlocks = data
end

function PromoUnlockManager:load(cache, version)
	local data = cache.promo_unlocks

	if data and data.version == self.save_version then
		for saved_item_id, unlocked in pairs(data.items) do
			if unlocked then
				self:_unlock_item(saved_item_id)
			end
		end
	end
end
