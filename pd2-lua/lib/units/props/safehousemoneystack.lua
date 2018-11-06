SafehouseMoneyStack = SafehouseMoneyStack or class(UnitBase)
SafehouseMoneyStack.SMALL_MAX_SUM = 1000000
SafehouseMoneyStack.STEPS = 743
SafehouseMoneyStack.SMALL_STEPS = 85
SafehouseMoneyStack.MAX_SUM = SafehouseMoneyStack.SMALL_MAX_SUM * (SafehouseMoneyStack.STEPS + 1) + SafehouseMoneyStack.SMALL_MAX_SUM - 20

function SafehouseMoneyStack:init(unit)
	UnitBase.init(self, unit, false)

	self._unit = unit

	self:_setup()
end

function SafehouseMoneyStack:_setup()
	self._small_sequences = {}

	for i = 1, SafehouseMoneyStack.SMALL_STEPS, 1 do
		local post_fix = (i < 10 and "0" or "") .. i

		table.insert(self._small_sequences, "var_small_money_grow_" .. post_fix)
	end

	self._sequences = {}
	self._big_steps = {}

	for i = 1, SafehouseMoneyStack.STEPS, 1 do
		local post_fix = (i < 10 and "0" or "") .. i

		table.insert(self._sequences, "var_money_grow_" .. post_fix)
		table.insert(self._big_steps, {
			object = self._unit:get_object(Idstring("g_money_wrapped_" .. i)),
			body = self._unit:body("body_money_stack_" .. i)
		})
	end

	local money = managers.money:total()

	self:_run_sequences(money)
end

function SafehouseMoneyStack:_run_sequences(money)
	print("money", money)

	local small_sum = math.mod(money, SafehouseMoneyStack.SMALL_MAX_SUM)
	local where = math.min(small_sum / SafehouseMoneyStack.SMALL_MAX_SUM, 1)
	local sequence_index = math.ceil(where * #self._small_sequences)

	print("where small", where, sequence_index)

	local sequence = sequence_index == 0 and "var_small_money_grow_00" or self._small_sequences[math.clamp(sequence_index, 1, #self._small_sequences)]

	self._unit:damage():run_sequence_simple(sequence)

	money = money - small_sum
	local where = math.min(money / SafehouseMoneyStack.MAX_SUM, 1)
	local step_index = math.ceil(where * #self._big_steps)

	print("where large", where, step_index)

	for i = 1, step_index, 1 do
		self._big_steps[i].object:set_visibility(true)
		self._big_steps[i].body:set_enabled(true)
	end
end

function SafehouseMoneyStack:debug_test()
	self:_hide()

	self._test_money = 0

	self._unit:set_extension_update_enabled(Idstring("base"), true)
end

function SafehouseMoneyStack:_hide()
	for _, data in ipairs(self._big_steps) do
		data.object:set_visibility(false)
		data.body:set_enabled(false)
	end
end

function SafehouseMoneyStack:update()
	if self._test_money then
		self:_run_sequences(self._test_money)

		self._test_money = self._test_money + 500000

		if SafehouseMoneyStack.MAX_SUM <= self._test_money then
			self._test_money = nil
		end
	end
end

function SafehouseMoneyStack:destroy()
end
