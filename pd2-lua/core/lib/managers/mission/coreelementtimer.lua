core:module("CoreElementTimer")
core:import("CoreMissionScriptElement")

ElementTimer = ElementTimer or class(CoreMissionScriptElement.MissionScriptElement)

function ElementTimer:init(...)
	ElementTimer.super.init(self, ...)

	self._digital_gui_units = {}
	self._triggers = {}
end

function ElementTimer:on_script_activated()
	self._timer = self:get_random_table_value_float(self:value("timer"))

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

function ElementTimer:_load_unit(unit)
	table.insert(self._digital_gui_units, unit)
	unit:digital_gui():timer_set(self._timer)
end

function ElementTimer:set_enabled(enabled)
	ElementTimer.super.set_enabled(self, enabled)
end

function ElementTimer:add_updator()
	if not Network:is_server() then
		return
	end

	if not self._updator then
		self._updator = true

		self._mission_script:add_updator(self._id, callback(self, self, "update_timer"))
	end
end

function ElementTimer:remove_updator()
	if self._updator then
		self._mission_script:remove_updator(self._id)

		self._updator = nil
	end
end

function ElementTimer:update_timer(t, dt)
	self._timer = self._timer - dt

	if self._timer <= 0 then
		self:remove_updator()
		self:on_executed()
	end

	for id, cb_data in pairs(self._triggers) do
		if self._timer <= cb_data.time and not cb_data.disabled then
			cb_data.callback()
			self:remove_trigger(id)
		end
	end
end

function ElementTimer:client_on_executed(...)
end

function ElementTimer:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementTimer.super.on_executed(self, instigator)
end

function ElementTimer:timer_operation_pause()
	self:remove_updator()
	self:_pause_digital_guis()
end

function ElementTimer:timer_operation_start()
	self:add_updator()
	self:_start_digital_guis_count_down()
end

function ElementTimer:timer_operation_add_time(time)
	self._timer = self._timer + time

	self:_update_digital_guis_timer()
end

function ElementTimer:timer_operation_subtract_time(time)
	self._timer = self._timer - time

	self:_update_digital_guis_timer()
end

function ElementTimer:timer_operation_reset()
	self._timer = self:get_random_table_value_float(self:value("timer"))

	self:_update_digital_guis_timer()
end

function ElementTimer:timer_operation_set_time(time)
	self._timer = time

	self:_update_digital_guis_timer()
end

function ElementTimer:_update_digital_guis_timer()
	for _, unit in ipairs(self._digital_gui_units) do
		if alive(unit) then
			unit:digital_gui():timer_set(self._timer, true)
		end
	end
end

function ElementTimer:_start_digital_guis_count_down()
	for _, unit in ipairs(self._digital_gui_units) do
		if alive(unit) then
			unit:digital_gui():timer_start_count_down(true)
		end
	end
end

function ElementTimer:_start_digital_guis_count_up()
	for _, unit in ipairs(self._digital_gui_units) do
		if alive(unit) then
			unit:digital_gui():timer_start_count_up(true)
		end
	end
end

function ElementTimer:_pause_digital_guis()
	for _, unit in ipairs(self._digital_gui_units) do
		if alive(unit) then
			unit:digital_gui():timer_pause(true)
		end
	end
end

function ElementTimer:add_trigger(id, time, callback, disabled)
	self._triggers[id] = {
		time = time,
		callback = callback,
		disabled = disabled
	}
end

function ElementTimer:remove_trigger(id)
	if not self._triggers[id].disabled then
		self._triggers[id] = nil
	end
end

function ElementTimer:enable_trigger(id)
	if self._triggers[id] then
		self._triggers[id].disabled = false
	end
end

ElementTimerOperator = ElementTimerOperator or class(CoreMissionScriptElement.MissionScriptElement)

function ElementTimerOperator:init(...)
	ElementTimerOperator.super.init(self, ...)
end

function ElementTimerOperator:client_on_executed(...)
end

function ElementTimerOperator:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local time = self:get_random_table_value_float(self:value("time"))

	for _, id in ipairs(self._values.elements) do
		local element = self:get_mission_element(id)

		if element then
			if self._values.operation == "pause" then
				element:timer_operation_pause()
			elseif self._values.operation == "start" then
				element:timer_operation_start()
			elseif self._values.operation == "add_time" then
				element:timer_operation_add_time(time)
			elseif self._values.operation == "subtract_time" then
				element:timer_operation_subtract_time(time)
			elseif self._values.operation == "reset" then
				element:timer_operation_reset(time)
			elseif self._values.operation == "set_time" then
				element:timer_operation_set_time(time)
			end
		end
	end

	ElementTimerOperator.super.on_executed(self, instigator)
end

ElementTimerTrigger = ElementTimerTrigger or class(CoreMissionScriptElement.MissionScriptElement)

function ElementTimerTrigger:init(...)
	ElementTimerTrigger.super.init(self, ...)
end

function ElementTimerTrigger:on_script_activated()
	self:activate_trigger()
end

function ElementTimerTrigger:client_on_executed(...)
end

function ElementTimerTrigger:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementTimerTrigger.super.on_executed(self, instigator)
end

function ElementTimerTrigger:activate_trigger()
	for _, id in ipairs(self._values.elements) do
		local element = self:get_mission_element(id)

		element:add_trigger(self._id, self._values.time, callback(self, self, "on_executed"), not self:enabled())
	end
end

function ElementTimerTrigger:operation_add()
	self:activate_trigger()
end

function ElementTimerTrigger:set_enabled(enabled)
	ElementTimerTrigger.super.set_enabled(self, enabled)

	for _, id in ipairs(self._values.elements) do
		local element = self:get_mission_element(id)

		element:enable_trigger(self._id)
	end
end
