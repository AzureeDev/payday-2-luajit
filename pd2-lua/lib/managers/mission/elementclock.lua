core:import("CoreMissionScriptElement")

ElementClock = ElementClock or class(CoreMissionScriptElement.MissionScriptElement)

function ElementClock:init(...)
	ElementClock.super.init(self, ...)
end

function ElementClock:on_script_activated()
	ElementClock.super.on_script_activated(self)
	self:reset_clock()
end

function ElementClock:set_enabled(enabled)
	ElementClock.super.set_enabled(self, enabled)
	self:reset_clock()
end

function ElementClock:stop_simulation(...)
	ElementClock.super.stop_simulation(...)
	self:remove_updator()
end

function ElementClock:add_updator()
	if not self._updator then
		self._updator = true

		self._mission_script:add_updator(self._id, callback(self, self, "update_clock"))

		if self._values.modify_on_activate then
			self:tick_clock(self._values.hour_elements, self._hour)
			self:tick_clock(self._values.minute_elements, self._minute)
			self:tick_clock(self._values.second_elements, self._second)
		end
	end
end

function ElementClock:remove_updator()
	if self._updator then
		self._mission_script:remove_updator(self._id)

		self._updator = nil
	end
end

function ElementClock:client_on_executed(...)
	self:on_executed(...)
end

function ElementClock:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementClock.super.on_executed(self, instigator)
end

function ElementClock:reset_clock()
	if self._values.enabled then
		self._hour = self:get_hour()
		self._minute = self:get_minute()
		self._second = self:get_second()

		self:add_updator()
	else
		self:remove_updator()
	end
end

function ElementClock:get_hour()
	return tonumber(os.date("%H"))
end

function ElementClock:get_minute()
	return tonumber(os.date("%M"))
end

function ElementClock:get_second()
	return tonumber(os.date("%S"))
end

function ElementClock:update_clock(t, dt)
	local hour = self:get_hour()
	local minute = self:get_minute()
	local second = self:get_second()

	if self._hour ~= hour then
		self._hour = hour

		self:tick_clock(self._values.hour_elements, self._hour)
	end

	if self._minute ~= minute then
		self._minute = minute

		self:tick_clock(self._values.minute_elements, self._minute)
	end

	if self._second ~= second then
		self._second = second

		self:tick_clock(self._values.second_elements, self._second)
	end
end

function ElementClock:tick_clock(elements, value)
	for _, id in ipairs(elements) do
		local element = self:get_mission_element(id)

		if element then
			element:counter_operation_set(value)
		end
	end
end
