FrameCallback = FrameCallback or class()

function FrameCallback:init()
	self._callbacks = {}
end

function FrameCallback:update()
	for i, obj in pairs(self._callbacks) do
		obj.current = obj.current + 1

		if obj.target % obj.current == 0 then
			obj.clbk()
		end
	end
end

function FrameCallback:add(key, clbk, target)
	self._callbacks = self._callbacks or {}

	if not self._callbacks[key] then
		self._callbacks[key] = {
			current = 0,
			clbk = clbk,
			target = target
		}
	end
end

function FrameCallback:remove(key)
	self._callbacks = self._callbacks or {}

	if self._callbacks[key] then
		self._callbacks[key].clbk = nil
		self._callbacks[key].target = nil
		self._callbacks[key].current = nil
		self._callbacks[key] = nil
	end
end

function FrameCallback:reset_counter(key)
	self._callbacks = self._callbacks or {}

	if self._callbacks[key] then
		self._callbacks[key].current = 0
	end
end
