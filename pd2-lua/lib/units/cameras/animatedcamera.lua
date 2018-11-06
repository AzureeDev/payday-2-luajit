AnimatedCamera = AnimatedCamera or class()

function AnimatedCamera:init(unit)
	self._unit = unit
end

function AnimatedCamera:update(unit, t, dt)
end

function AnimatedCamera:set_position(pos)
	self._unit:set_position(pos)
end

function AnimatedCamera:set_rotation(rot)
	self._unit:set_rotation(rot)
end

function AnimatedCamera:position(pos)
	return self._unit:position()
end

function AnimatedCamera:rotation(pos)
	return self._unit:rotation()
end

function AnimatedCamera:play_redirect(redirect_name)
	local result = self._unit:play_redirect(redirect_name)

	return result ~= "" and result
end

function AnimatedCamera:play_state(state_name)
	local result = self._unit:play_state(state_name)

	return result ~= "" and result
end

function AnimatedCamera:destroy()
end
