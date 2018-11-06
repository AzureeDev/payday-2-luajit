core:module("CoreStack")

Stack = Stack or class()

function Stack:init()
	self:clear()
end

function Stack:push(value)
	self._last = self._last + 1
	self._table[self._last] = value
end

function Stack:pop()
	if self:is_empty() then
		error("Stack is empty")
	end

	local value = self._table[self._last]
	self._table[self._last] = nil
	self._last = self._last - 1

	return value
end

function Stack:top()
	if self:is_empty() then
		error("Stack is empty")
	end

	return self._table[self._last]
end

function Stack:is_empty()
	return self._last == 0
end

function Stack:size()
	return self._last
end

function Stack:clear()
	self._last = 0
	self._table = {}
end

function Stack:stack_table()
	return self._table
end
