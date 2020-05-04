SafehouseVaultMoneyStacks = SafehouseVaultMoneyStacks or class(UnitBase)
SafehouseVaultMoneyStacks.CHUNKS = 5
SafehouseVaultMoneyStacks.MONEY_STEPS = {
	100000,
	1000000,
	5000000,
	10000000,
	20000000,
	5000000,
	10000000,
	25000000,
	50000000,
	75000000,
	25000000,
	75000000,
	150000000,
	250000000,
	300000000
}

function SafehouseVaultMoneyStacks:init(unit)
	UnitBase.init(self, unit, false)

	self._unit = unit
	self._active_tier = 1

	if managers.sync then
		managers.sync:add_managed_unit(self._unit:id(), self)
	end

	self:_setup()
end

function SafehouseVaultMoneyStacks:_setup()
	self._tiers = {}
	local cash_index = (self.tier - 1) * self.CHUNKS

	for i = 1, self.CHUNKS do
		local body = self._unit:body("body_money_chunk_" .. tostring(i))

		if body then
			local objects = {}
			local obj = self._unit:get_object(Idstring("g_money_chunk_" .. tostring(i)))

			if obj then
				table.insert(objects, obj)
			end

			table.insert(self._tiers, {
				body = body,
				objects = objects,
				cash = self.MONEY_STEPS[cash_index + i]
			})
		end
	end

	local total = managers.money:total()
	local target_tier = nil

	for i = #self._tiers, 1, -1 do
		local data = self._tiers[i]

		if data.cash < total then
			target_tier = i

			break
		end
	end

	self:set_active_tier(target_tier)
end

function SafehouseVaultMoneyStacks:set_active_tier(target_tier)
	self._active_tier = target_tier

	for i = #self._tiers, 1, -1 do
		self:_set_tier_enabled(self._tiers[i], target_tier == i)
	end

	self:perform_sync()
end

function SafehouseVaultMoneyStacks:_set_tier_enabled(tier_data, enable)
	tier_data.body:set_enabled(enable)

	for i, obj in ipairs(tier_data.objects) do
		obj:set_visibility(enable)
	end
end

function SafehouseVaultMoneyStacks:perform_sync()
	if managers.sync and Network:is_server() then
		managers.sync:add_synced_vault_cash(self._unit:id(), self._active_tier)
	end
end
