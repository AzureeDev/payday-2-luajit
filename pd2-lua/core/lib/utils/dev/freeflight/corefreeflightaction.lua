core:module("CoreFreeFlightAction")

FreeFlightAction = FreeFlightAction or class()

function FreeFlightAction:init(name, callback)
	self._name = assert(name)
	self._callback = assert(callback)
end

function FreeFlightAction:do_action()
	self._callback()
end

function FreeFlightAction:reset()
end

function FreeFlightAction:name()
	return self._name
end

FreeFlightActionToggle = FreeFlightActionToggle or class()

function FreeFlightActionToggle:init(name1, name2, callback1, callback2)
	self._name1 = assert(name1)
	self._name2 = assert(name2)
	self._callback1 = assert(callback1)
	self._callback2 = assert(callback2)
	self._toggle = 1
end

function FreeFlightActionToggle:do_action()
	if self._toggle == 1 then
		self._toggle = 2

		self._callback1()
	else
		self._toggle = 1

		self._callback2()
	end
end

function FreeFlightActionToggle:reset()
	if self._toggle == 2 then
		self:do_action()
	end
end

function FreeFlightActionToggle:name()
	if self._toggle == 1 then
		return self._name1
	else
		return self._name2
	end
end
