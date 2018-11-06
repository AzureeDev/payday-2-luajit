SimpleVehicle = SimpleVehicle or class()

function SimpleVehicle:init(unit)
	self._unit = unit

	print(self.ANIM_GROUP_NAME)

	self.ANIM_GROUP = Idstring(self.ANIM_GROUP_NAME or "drive")

	print(self.ANIM_GROUP_NAME)

	self._acc_time = 2
	self._deacc_time = 1
	self._max_time_speed = 0.01
	self._target_anim_time = 0
	self._current_time_speed = 0
	self._target_time_speed = self._current_time_speed
	self._current_anim_speed = 0
	self._target_anim_speed = self._current_anim_speed
end

function SimpleVehicle:update(unit, t, dt)
	if not self._started then
		return
	end

	if not self._state then
		return
	end

	if not self._stopped and self._anim_time_speed_params then
		if self._state == "start" then
			self._anim_time_speed_params.transition_time = math.min(1, self._anim_time_speed_params.transition_time + dt / self._anim_time_speed_params.transition_total_time)

			if self._anim_time_speed_params.transition_time == 1 then
				-- Nothing
			end

			self._anim_time_speed_params.current = math.lerp(self._anim_time_speed_params.start, self._anim_time_speed_params.target, self._anim_time_speed_params.transition_time)
			self._bezier_v = self._bezier_v + self._new_time_speed / (self._started_end_t - self._start_t) * dt
			local v = math.bezier({
				0,
				0,
				0.66,
				1
			}, self._bezier_v)
			local time = math.lerp(self._start_t, self._started_end_t, v)

			print("1 speed", time - self:anim_time())
			self:_set_anim_time(time)

			if self._started_end_t <= self._unit:anim_time(self.ANIM_GROUP) then
				self._state = "run"
				self._bezier_v = self._bezier_v - 1

				print("started")
				print("max speed reached", self._unit:anim_time(self.ANIM_GROUP))
			end
		elseif self._state == "run" then
			self._bezier_v = self._bezier_v + self._new_time_speed / (self._runned_end_t - self._started_end_t) * dt
			local v = math.bezier({
				0,
				0.33,
				0.66,
				1
			}, self._bezier_v)
			local time = math.lerp(self._started_end_t, self._runned_end_t, v)

			print("2 speed", time - self:anim_time())
			self:_set_anim_time(time)

			if self._runned_end_t <= self._unit:anim_time(self.ANIM_GROUP) then
				self._state = "stop"
				self._bezier_v = self._bezier_v - 1

				print("runned")
			end
		elseif self._state == "stop" then
			self._bezier_v = math.min(self._bezier_v + self._new_time_speed / (self._stopped_end_t - self._runned_end_t) * dt, 1)
			local v = math.bezier({
				0,
				0.3,
				1,
				1
			}, self._bezier_v)
			local time = math.lerp(self._runned_end_t, self._stopped_end_t, v)

			print("3 speed", time - self:anim_time())
			self:_set_anim_time(time)

			if self._stopped_end_t <= self._unit:anim_time(self.ANIM_GROUP) then
				self._state = nil

				print("stopped")
			end
		end
	end

	self:_check_reached_target_anim_time()
end

function SimpleVehicle:_check_reached_target_anim_time()
	if self._target_anim_time <= self._unit:anim_time(self.ANIM_GROUP) then
		-- Nothing
	end
end

function SimpleVehicle:anim_time()
	return self._unit:anim_time(self.ANIM_GROUP)
end

function SimpleVehicle:stop()
	self._runned_end_t = self._unit:anim_time(self.ANIM_GROUP)
	self._stopped_end_t = self._runned_end_t + 1
	self._state = "stop"
	self._bezier_v = 0
end

function SimpleVehicle:start()
	self:start_anim_from_to(self:anim_time(), 20)
end

function SimpleVehicle:start_anim_from_to(from, to, max_time_speed)
	self._max_time_speed = max_time_speed or self._max_time_speed
	self._state = "start"
	self._new_time_speed = 1
	self._start_t = from
	self._started_end_t = from + 3
	self._runned_end_t = to - 3
	self._stopped_end_t = to
	self._started = true
	self._stopping = false
	self._current_time_speed = 0
	self._bezier_v = 0

	self:anim_set_time(from)
	self:set_target_anim_time(to)
	self:set_target_time_speed(self._max_time_speed)

	local length = math.abs(to - from)

	print("length", length)
end

function SimpleVehicle:anim_set_time(anim_time)
	self._unit:anim_set_time(self.ANIM_GROUP, anim_time)
end

function SimpleVehicle:set_target_anim_time(anim_time)
	self._target_anim_time = anim_time
end

function SimpleVehicle:set_target_time_speed(time_speed)
	self._target_time_speed = time_speed
	self._acc = math.abs(time_speed - 0) / self._acc_time

	print("self._acc", self._acc)

	self._acc_t = math.sqrt(self._acc_time / (0.5 * self._acc))
	self._something = 0

	print("self._acc_t", self._acc_t)
	print("set_target_time_speed", self._anim_time_speed_params and self._anim_time_speed_params.current)

	self._anim_time_speed_params = self._anim_time_speed_params or {}
	self._anim_time_speed_params.target = time_speed
	self._anim_time_speed_params.start = self._anim_time_speed_params.current or 0
	self._anim_time_speed_params.transition_time = 0
	self._anim_time_speed_params.transition_total_time = self._acc_time

	print(inspect(self._anim_time_speed_params))
end

function SimpleVehicle:accelerate_to(anim_speed)
	self._target_anim_speed = anim_speed
	self._stopped = false
end

function SimpleVehicle:deaccelerate_to(anim_speed)
	self._target_anim_speed = anim_speed
	self._stopped = false
end

function SimpleVehicle:_anim_stop()
	print("SimpleVehicle:_anim_stop()")

	self._stopped = true
end

function SimpleVehicle:_set_anim_time(anim_time)
	self._unit:anim_set_time(self.ANIM_GROUP, anim_time)
end

function SimpleVehicle:_set_anim_speed(anim_speed)
end

function SimpleVehicle:save(data)
	local state = {}
	data.SimpleVehicle = state
end

function SimpleVehicle:load(data)
	local state = data.SimpleVehicle
end

function SimpleVehicle:destroy()
end
