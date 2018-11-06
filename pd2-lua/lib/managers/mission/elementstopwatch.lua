core:import("CoreMissionScriptElement")

ElementStopwatch = ElementStopwatch or class(CoreMissionScriptElement.MissionScriptElement)

function ElementStopwatch:init(...)
	ElementStopwatch.super.init(self, ...)

	self._digital_gui_units = {}
	self._triggers = {}
end

function ElementStopwatch:on_script_activated()
	self._timer = 0

	if not Network:is_server() then
		return
	end

	if self._values.digital_gui_unit_ids then
		for _, id in ipairs(self._values.digital_gui_unit_ids) do
			if Global.running_simulation then
				local unit = managers.editor:unit_with_id(id)

				table.insert(self._digital_gui_units, unit)
				unit:digital_gui():timer_set(self._timer)
			else
				local unit = managers.worlddefinition:get_unit_on_load(id, callback(self, self, "_load_unit"))

				if unit then
					table.insert(self._digital_gui_units, unit)
					unit:digital_gui():timer_set(self._timer)
				end
			end
		end
	end
end

function ElementStopwatch:_load_unit(unit)
	table.insert(self._digital_gui_units, unit)
	unit:digital_gui():timer_set(self._timer)
end

function ElementStopwatch:set_enabled(enabled)
	ElementStopwatch.super.set_enabled(self, enabled)
end

function ElementStopwatch:add_updator()
	if not Network:is_server() then
		return
	end

	if not self._updator then
		self._updator = true

		self._mission_script:add_updator(self._id, callback(self, self, "update_timer"))
	end
end

function ElementStopwatch:remove_updator()
	if self._updator then
		self._mission_script:remove_updator(self._id)

		self._updator = nil
	end
end

function ElementStopwatch:update_timer(t, dt)
	self._timer = self._timer + dt

	for id, cb_data in pairs(self._triggers) do
		if cb_data.time <= self._timer and not cb_data.disabled then
			cb_data.callback()
			self:remove_trigger(id)
		end
	end
end

function ElementStopwatch:client_on_executed(...)
end

function ElementStopwatch:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementStopwatch.super.on_executed(self, instigator)
end

function ElementStopwatch:get_time()
	return self._timer
end

function ElementStopwatch:stopwatch_operation_pause()
	self:remove_updator()
	self:_pause_digital_guis()
end

function ElementStopwatch:stopwatch_operation_start()
	self:_update_digital_guis_timer()
	self:add_updator()
	self:_start_digital_guis_count_up()
end

function ElementStopwatch:stopwatch_operation_add_time(time)
	self._timer = self._timer + time

	self:_update_digital_guis_timer()
end

function ElementStopwatch:stopwatch_operation_subtract_time(time)
	self._timer = self._timer - time

	self:_update_digital_guis_timer()
end

function ElementStopwatch:stopwatch_operation_reset()
	self._timer = 0

	self:_update_digital_guis_timer()
end

function ElementStopwatch:stopwatch_operation_set_time(time)
	self._timer = time

	self:_update_digital_guis_timer()
end

function ElementStopwatch:_update_digital_guis_timer()
	for _, unit in ipairs(self._digital_gui_units) do
		if alive(unit) then
			unit:digital_gui():timer_set(self._timer, true)
		end
	end
end

function ElementStopwatch:_start_digital_guis_count_up()
	for _, unit in ipairs(self._digital_gui_units) do
		if alive(unit) then
			unit:digital_gui():timer_start_count_up(true)
		end
	end
end

function ElementStopwatch:_pause_digital_guis()
	for _, unit in ipairs(self._digital_gui_units) do
		if alive(unit) then
			unit:digital_gui():timer_pause(true)
		end
	end
end

function ElementStopwatch:add_trigger(id, time, callback, disabled)
	self._triggers[id] = {
		time = time,
		callback = callback,
		disabled = disabled
	}
end

function ElementStopwatch:remove_trigger(id)
	if not self._triggers[id].disabled then
		self._triggers[id] = nil
	end
end

function ElementStopwatch:enable_trigger(id)
	if self._triggers[id] then
		self._triggers[id].disabled = false
	end
end

ElementStopwatchOperator = ElementStopwatchOperator or class(CoreMissionScriptElement.MissionScriptElement)

function ElementStopwatchOperator:init(...)
	ElementStopwatchOperator.super.init(self, ...)
end

function ElementStopwatchOperator:client_on_executed(...)
end

function ElementStopwatchOperator:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local time = self:get_random_table_value_float(self:value("time"))

	for _, id in ipairs(self._values.elements) do
		local element = self:get_mission_element(id)

		if element then
			if self._values.operation == "pause" then
				element:stopwatch_operation_pause()
			elseif self._values.operation == "start" then
				element:stopwatch_operation_start()
			elseif self._values.operation == "add_time" then
				element:stopwatch_operation_add_time(time)
			elseif self._values.operation == "subtract_time" then
				element:stopwatch_operation_subtract_time(time)
			elseif self._values.operation == "reset" then
				element:stopwatch_operation_reset()
			elseif self._values.operation == "set_time" then
				element:stopwatch_operation_set_time(time)
			elseif self._values.operation == "save_time" then
				local time = element:get_time() or 0
				local saved_time = managers.mission:get_saved_job_value(self:value("save_key"))

				print("[stopwatch] saving stopwatch time", self:value("save_key"), time, saved_time, self:_save_value_ok(time, saved_time))

				if self:_save_value_ok(time, saved_time) then
					Global.mission_manager.saved_job_values[self:value("save_key")] = time
				end
			elseif self._values.operation == "load_time" then
				print("[stopwatch] loading stopwatch time", self:value("save_key"), Global.mission_manager.saved_job_values[self:value("save_key")])

				local saved_time = Global.mission_manager.saved_job_values[self:value("save_key")]

				if saved_time ~= nil then
					if type(saved_time) ~= "number" then
						saved_time = tonumber(saved_time)
					end

					if saved_time ~= nil then
						element:stopwatch_operation_set_time(saved_time)
					end
				end
			end
		end
	end

	ElementStopwatchOperator.super.on_executed(self, instigator)
end

function ElementStopwatchOperator:_save_value_ok(new_time, saved_time)
	local condition = self:value("condition")

	if condition == "always" or saved_time == nil then
		return true
	elseif condition == "equal" then
		return new_time == saved_time
	elseif condition == "less_than" then
		return new_time < saved_time
	elseif condition == "greater_than" then
		return saved_time < new_time
	elseif condition == "less_or_equal" then
		return new_time <= saved_time
	elseif condition == "greater_or_equal" then
		return saved_time <= new_time
	end

	return false
end

ElementStopwatchTrigger = ElementStopwatchTrigger or class(CoreMissionScriptElement.MissionScriptElement)

function ElementStopwatchTrigger:init(...)
	ElementStopwatchTrigger.super.init(self, ...)
end

function ElementStopwatchTrigger:on_script_activated()
	self:activate_trigger()
end

function ElementStopwatchTrigger:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementStopwatchTrigger.super.on_executed(self, instigator)
end

function ElementStopwatchTrigger:client_on_executed(...)
end

function ElementStopwatchTrigger:activate_trigger()
	for _, id in ipairs(self._values.elements) do
		local element = self:get_mission_element(id)

		if element then
			element:add_trigger(self._id, self._values.time, callback(self, self, "on_executed"), not self:enabled())
		end
	end
end

function ElementStopwatchTrigger:operation_add()
end

function ElementStopwatchTrigger:set_enabled(enabled)
	for _, id in ipairs(self._values.elements) do
		local element = self:get_mission_element(id)

		if element then
			element:enable_trigger(self._id)
		end
	end

	ElementStopwatchTrigger.super.set_enabled(self, enabled)
end

ElementStopwatchFilter = ElementStopwatchFilter or class(CoreMissionScriptElement.MissionScriptElement)

function ElementStopwatchFilter:init(...)
	ElementStopwatchFilter.super.init(self, ...)
end

function ElementStopwatchFilter:on_script_activated()
end

function ElementStopwatchFilter:client_on_executed(...)
end

function ElementStopwatchFilter:on_executed(instigator)
	if self._values.enabled and self:_values_ok() then
		ElementStopwatchFilter.super.on_executed(self, instigator)
	end
end

function ElementStopwatchFilter:_values_ok()
	if self._values.needed_to_execute == "all" then
		return self:_all_elements_ok()
	end

	if self._values.needed_to_execute == "any" then
		return self:_any_elements_ok()
	end
end

function ElementStopwatchFilter:_all_elements_ok()
	for _, id in ipairs(self._values.elements) do
		if not self:_check_time(self:get_mission_element(id), self:_get_time()) then
			return false
		end
	end

	return true
end

function ElementStopwatchFilter:_any_elements_ok()
	for _, id in ipairs(self._values.elements) do
		if self:_check_time(self:get_mission_element(id), self:_get_time()) then
			return true
		end
	end

	return false
end

function ElementStopwatchFilter:_get_time()
	local time = self._values.value

	if self._values.stopwatch_value_ids and #self._values.stopwatch_value_ids > 0 then
		local element = self:get_mission_element(self._values.stopwatch_value_ids[1])

		if element then
			time = element:get_time()
		end
	end

	return time
end

function ElementStopwatchFilter:_check_time(element, value)
	if not self._values.check_type or self._values.check_type == "equal" then
		return element:get_time() == value
	elseif self._values.check_type == "less_or_equal" then
		return element:get_time() <= value
	elseif self._values.check_type == "greater_or_equal" then
		return value <= element:get_time()
	elseif self._values.check_type == "less_than" then
		return element:get_time() < value
	elseif self._values.check_type == "greater_than" then
		return value < element:get_time()
	end

	return false
end
