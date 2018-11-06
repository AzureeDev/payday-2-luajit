core:module("CoreSmoketestCommonSuite")
core:import("CoreClass")
core:import("CoreSmoketestSuite")

Substep = Substep or CoreClass.class()

function Substep:init(suite, step_arguments)
	self._suite = suite
	self._step_arguments = step_arguments

	self:start()
end

function Substep:has_failed()
	return self._fail == true
end

function Substep:is_done()
	return self._done
end

function Substep:_set_done()
	self._done = true
	self._fail = false
end

function Substep:_set_fail()
	self._fail = true
end

function Substep:start()
	assert(false, "Not implemented")
end

function Substep:update(t, dt)
end

CallAndDoneSubstep = CallAndDoneSubstep or CoreClass.class(Substep)

function CallAndDoneSubstep.step_arguments(callback)
	local step_arguments = {
		callback = callback
	}

	return step_arguments
end

function CallAndDoneSubstep:start()
	self._step_arguments.callback()
	self:_set_done()
end

WaitEventSubstep = WaitEventSubstep or CoreClass.class(Substep)

function WaitEventSubstep.step_arguments(event_id)
	local step_arguments = {
		event_id = event_id
	}

	return step_arguments
end

function WaitEventSubstep:start()
	self._event_listener = EventManager:register_listener(self._step_arguments.event_id, function ()
		self:_set_done()
	end, nil)
end

function WaitEventSubstep:destroy()
	EventManager:unregister_listener(self._event_listener)
end

CallAndWaitEventSubstep = CallAndWaitEventSubstep or CoreClass.class(Substep)

function CallAndWaitEventSubstep.step_arguments(callback, event_id)
	local step_arguments = {
		callback = callback,
		event_id = event_id
	}

	return step_arguments
end

function CallAndWaitEventSubstep:start()
	self._event_listener = EventManager:register_listener(self._step_arguments.event_id, function ()
		self:_set_done()
	end, nil)

	self._step_arguments.callback()
end

function CallAndWaitEventSubstep:destroy()
	EventManager:unregister_listener(self._event_listener)
end

DelaySubstep = DelaySubstep or CoreClass.class(Substep)

function DelaySubstep.step_arguments(seconds)
	local step_arguments = {
		seconds = seconds
	}

	return step_arguments
end

function DelaySubstep:start()
	self._seconds_left = self._step_arguments.seconds
end

function DelaySubstep:update(t, dt)
	self._seconds_left = self._seconds_left - dt

	if self._seconds_left <= 0 then
		self:_set_done()
	end
end

CommonSuite = CommonSuite or CoreClass.class(CoreSmoketestSuite.Suite)

function CommonSuite:init()
	self._step_list = {}
end

function CommonSuite:add_step(name, class, params)
	local step_entry = {
		name = name,
		class = class,
		params = params
	}

	table.insert(self._step_list, step_entry)
end

function CommonSuite:start(session_state, reporter, suite_arguments)
	self._suite_arguments = suite_arguments
	self._session_state = session_state
	self._reporter = reporter
	self._is_done = false
	self._current_step_id = 0

	self:next_step()
end

function CommonSuite:is_done()
	return self._is_done
end

function CommonSuite:update(t, dt)
	if self._current_step then
		self._current_step:update(t, dt)

		if self._current_step:is_done() then
			if self._current_step:has_failed() then
				self._reporter:fail_substep(self._step_list[self._current_step_id].name)
			else
				self._reporter:end_substep(self._step_list[self._current_step_id].name)
			end

			if not self:next_step() then
				self._is_done = true
			end
		end
	end
end

function CommonSuite:next_step()
	if self._current_step then
		if self._current_step.destroy then
			self._current_step:destroy()
		end

		self._current_step = nil
	end

	self._current_step_id = self._current_step_id + 1

	if self._current_step_id <= #self._step_list then
		local step_entry = self._step_list[self._current_step_id]

		self._reporter:begin_substep(step_entry.name)

		self._current_step = step_entry.class:new(self, step_entry.params)

		return true
	else
		return false
	end
end

function CommonSuite:get_argument(name)
	assert(self._suite_arguments[name], "Suite argument '" .. name .. "' was not defined")

	return self._suite_arguments[name]
end
