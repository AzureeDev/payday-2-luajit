MoneyWrapBase = MoneyWrapBase or class(UnitBase)
MoneyWrapBase.taken_wraps = MoneyWrapBase.taken_wraps or 0

function MoneyWrapBase:init(unit)
	UnitBase.init(self, unit, false)

	self._unit = unit

	self:_setup()
end

function MoneyWrapBase:_setup()
	self._MONEY_MAX = self.max_amount or 1000000
	self._money_amount = self._MONEY_MAX
	self._sequence_stage = 10
end

function MoneyWrapBase:take_money(unit)
	if self._empty then
		return
	end

	if self.give_exp then
		unit:sound():play("money_grab")
		managers.network:session():send_to_peers_synched("sync_money_wrap_money_taken", self._unit)

		self._money_amount = 0
		MoneyWrapBase.taken_wraps = MoneyWrapBase.taken_wraps + 1
	else
		local taken = self:_take_money(unit)

		if taken > 0 then
			unit:sound():play("money_grab")
			managers.network:session():send_to_peers_synched("sync_money_wrap_money_taken", self._unit)
		end

		managers.money:perform_action_money_wrap(taken)
	end

	if self._money_amount <= 0 then
		self:_set_empty()
	end

	self:_update_sequences()
end

function MoneyWrapBase:sync_money_taken()
	if self.give_exp then
		self._money_amount = 0
	else
		local amount = self.money_action and tweak_data:get_value("money_manager", "actions", self.money_action) or self._MONEY_MAX / 2

		managers.money:perform_action_money_wrap(amount)

		self._money_amount = math.max(self._money_amount - amount, 0)
	end

	if self._money_amount <= 0 then
		self:_set_empty()
	end

	self:_update_sequences()
end

function MoneyWrapBase:_take_money(unit)
	local took = self.money_action and tweak_data:get_value("money_manager", "actions", self.money_action) or self._MONEY_MAX / 2
	self._money_amount = math.max(self._money_amount - took, 0)

	if self._money_amount <= 0 then
		self:_set_empty()
	end

	return took
end

function MoneyWrapBase:_update_sequences()
	local stage = math.round(self._money_amount / self._MONEY_MAX * 9) + 1

	if stage < self._sequence_stage then
		self._sequence_stage = stage

		self._unit:damage():run_sequence_simple("money_wrap_" .. self._sequence_stage)
	end
end

function MoneyWrapBase:_set_empty()
	self._empty = true

	if not self.skip_remove_unit then
		self._unit:set_slot(0)
	end
end

function MoneyWrapBase:update(unit, t, dt)
end

function MoneyWrapBase:save(data)
	MoneyWrapBase.super.save(self, data)

	local state = {money_amount = self._money_amount}
	data.MoneyWrapBase = state
end

function MoneyWrapBase:load(data)
	MoneyWrapBase.super.load(self, data)

	local state = data.MoneyWrapBase
	self._money_amount = state.money_amount
end

function MoneyWrapBase:destroy()
end

