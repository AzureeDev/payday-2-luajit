SimpleCharacter = SimpleCharacter or class()
SimpleCharacter.SPEED = 150

function SimpleCharacter:init(unit)
	self._unit = unit
end

function SimpleCharacter:update(unit, t, dt)
	self:move(t, dt)
end

function SimpleCharacter:paused_update(unit, t, dt)
	self:move(t, dt)
end

function SimpleCharacter:move(t, dt)
	local move_vec = Vector3(0, 0, 0)
	local keyboard = Input:keyboard()
	local viewport = managers.viewport:first_active_viewport()

	if viewport == nil then
		return
	end

	local camera = viewport:camera()
	local cam_rot = camera:rotation()
	local rotation = Rotation(90, cam_rot:pitch(), cam_rot:roll())

	if self._unit:mover() then
		if keyboard:down(Idstring("t")) then
			move_vec = move_vec - rotation:z()
		end

		if keyboard:down(Idstring("g")) then
			move_vec = move_vec + rotation:z()
		end

		if keyboard:down(Idstring("f")) then
			move_vec = move_vec - rotation:x()
		end

		if keyboard:down(Idstring("h")) then
			move_vec = move_vec + rotation:x()
		end

		local length = move_vec:length()

		if length > 0.001 then
			move_vec = move_vec / length
		end

		move_vec = move_vec * self.SPEED * dt

		if keyboard:down(Idstring("c")) then
			self._unit:mover():jump()
		end

		if keyboard:down(Idstring("k")) then
			self._unit:mover():set_stiff(true)
		end

		if keyboard:down(Idstring("l")) then
			self._unit:mover():set_stiff(false)
		end
	end

	self._unit:move(move_vec)
end
