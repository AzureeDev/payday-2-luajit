BlinkExt = BlinkExt or class()

function BlinkExt:init(unit)
	self._object_list = {}

	if self._objects then
		for _, object in ipairs(self._objects) do
			table.insert(self._object_list, unit:get_object(Idstring(object)))
		end
	end

	self._effect_list = {}

	if self._effects then
		for _, effect in ipairs(self._effects) do
			table.insert(self._effect_list, unit:effect_spawner(Idstring(effect)))
		end
	end

	if self._state then
		self:set_state(self._state, self._delay or 1)
	end
end

function BlinkExt:update(unit, t, dt)
	if self._delay_current and self._delay_current < t then
		if self._state == "cycle" then
			if self._current_object then
				self._object_list[self._current_object]:set_visibility(false)

				self._current_object = self._current_object == #self._object_list and 1 or self._current_object + 1

				self._object_list[self._current_object]:set_visibility(true)
			end

			if self._current_effect then
				self._effect_list[self._current_effect]:set_enabled(false)

				self._current_effect = self._current_effect == #self._effect_list and 1 or self._current_effect + 1

				self._effect_list[self._current_effect]:set_enabled(true)
			end
		elseif self._state == "rand_cycle" then
			if self._current_object then
				self._object_list[self._current_object]:set_visibility(false)

				self._current_object = math.random(#self._object_list)

				self._object_list[self._current_object]:set_visibility(true)
			end

			if self._current_effect then
				self._effect_list[self._current_effect]:set_enabled(false)

				self._current_effect = math.random(#self._effect_list)

				self._effect_list[self._current_effect]:set_enabled(true)
			end
		else
			for _, object in ipairs(self._object_list) do
				object:set_visibility(not object:visibility())
			end

			for _, effect in ipairs(self._effect_list) do
				effect:set_enabled(not effect:enabled())
			end
		end

		self._delay_current = TimerManager:game():time() + self._delay
	end
end

function BlinkExt:set_state(state, delay)
	self._state = state
	self._delay = delay

	if state == "twinkle" then
		local swap = true

		for _, object in ipairs(self._object_list) do
			object:set_visibility(swap)

			swap = not swap
		end

		swap = true

		for _, effect in ipairs(self._effect_list) do
			effect:set_enabled(swap)

			swap = not swap
		end

		self._delay_current = TimerManager:game():time() + delay
	elseif state == "cycle" then
		for _, object in ipairs(self._object_list) do
			object:set_visibility(false)
		end

		for _, effect in ipairs(self._effect_list) do
			effect:set_enabled(false)
		end

		if #self._object_list > 0 then
			self._current_object = 1

			self._object_list[1]:set_visibility(true)
		end

		if #self._effect_list > 0 then
			self._current_effect = 1

			self._effect_list[1]:set_enabled(true)
		end

		self._delay_current = TimerManager:game():time() + delay
	elseif state == "rand_cycle" then
		for _, object in ipairs(self._object_list) do
			object:set_visibility(false)
		end

		for _, effect in ipairs(self._effect_list) do
			effect:set_enabled(false)
		end

		if #self._object_list > 0 then
			self._current_object = math.random(#self._object_list)

			self._object_list[self._current_object]:set_visibility(true)
		end

		if #self._effect_list > 0 then
			self._current_effect = math.random(#self._effect_list)

			self._effect_list[self._current_effect]:set_enabled(true)
		end

		self._delay_current = TimerManager:game():time() + delay
	elseif state == "blink" then
		for _, object in ipairs(self._object_list) do
			object:set_visibility(true)
		end

		for _, effect in ipairs(self._effect_list) do
			effect:set_enabled(true)
		end

		self._delay_current = TimerManager:game():time() + delay
	elseif state == "disable" then
		for _, object in ipairs(self._object_list) do
			object:set_visibility(false)
		end

		for _, effect in ipairs(self._effect_list) do
			effect:set_enabled(false)
		end

		self._delay_current = nil
	elseif state == "enable" then
		for _, object in ipairs(self._object_list) do
			object:set_visibility(true)
		end

		for _, effect in ipairs(self._effect_list) do
			effect:set_enabled(true)
		end

		self._delay_current = nil
	end
end

function BlinkExt:save(data)
	data.BlinkExt = {
		state = self._state,
		delay = self._delay
	}
end

function BlinkExt:load(data)
	local state = data.BlinkExt
	self._state = data.BlinkExt.state
	self._delay = data.BlinkExt.delay

	self:set_state(self._state, self._delay)
end
