core:module("CoreControllerWrapper")
core:import("CoreControllerWrapperSettings")
core:import("CoreAccessObjectBase")

ControllerWrapper = ControllerWrapper or class(CoreAccessObjectBase.AccessObjectBase)
ControllerWrapper.TYPE = "generic"

function ControllerWrapper:init(manager, id, name, controller_map, default_controller_id, setup, debug, skip_virtual_controller, custom_virtual_connect_func_map)
	ControllerWrapper.super.init(self, manager, name)

	self._id = id
	self._name = name
	self._controller_map = controller_map
	self._default_controller_id = default_controller_id
	self._setup = setup
	self._debug = debug

	if not skip_virtual_controller then
		self._virtual_controller = Input:create_virtual_controller("ctrl_" .. tostring(self._id))
	end

	self._custom_virtual_connect_func_map = custom_virtual_connect_func_map or {}

	for controller_id in pairs(controller_map) do
		self._custom_virtual_connect_func_map[controller_id] = self._custom_virtual_connect_func_map[controller_id] or {}
	end

	self._connection_map = {}
	self._trigger_map = {}
	self._release_trigger_map = {}
	self._current_lerp_axis_map = {}
	self._claimed = false
	self._enabled = false
	self._delay_map = {}
	self._delay_bool_map = {}
	self._multi_input_map = {}

	self:setup(self._setup)

	self._was_connected = self:connected()
	self._reset_cache_time = TimerManager:wall_running():time() - 1
	self._delay_trigger_queue = {}
	self._input_pressed_cache = {}
	self._input_bool_cache = {}
	self._input_float_cache = {}
	self._input_axis_cache = {}
	self._input_touch_bool_cache = {}
	self._input_touch_pressed_cache = {}
	self._input_touch_released_cache = {}

	self:reset_cache(false)

	self._destroy_callback_list = {}
	self._last_destroy_callback_id = 0
	self._connect_changed_callback_list = {}
	self._last_connect_changed_callback_id = 0
	self._rebind_callback_list = {}
	self._last_rebind_callback_id = 0
end

function ControllerWrapper:destroy()
	for id, func in pairs(self._destroy_callback_list) do
		func(self, id)
	end

	if alive(self._virtual_controller) then
		Input:destroy_virtual_controller(self._virtual_controller)

		self._virtual_controller = nil
	end
end

function ControllerWrapper:update(t, dt)
	self:reset_cache(true)
	self:update_delay_trigger_queue()
	self:check_connect_changed_status()

	if alive(self._virtual_controller) then
		self._virtual_controller:clear_axis_triggers()
	end
end

function ControllerWrapper:paused_update(t, dt)
	self:reset_cache(true)
	self:update_delay_trigger_queue()
	self:check_connect_changed_status()

	if alive(self._virtual_controller) then
		self._virtual_controller:clear_axis_triggers()
	end
end

function ControllerWrapper:reset_cache(check_time)
	local reset_cache_time = TimerManager:wall_running():time()

	if not check_time or self._reset_cache_time < reset_cache_time then
		self._input_any_cache = nil
		self._input_any_pressed_cache = nil
		self._input_any_released_cache = nil

		if next(self._input_pressed_cache) then
			self._input_pressed_cache = {}
		end

		if next(self._input_bool_cache) then
			self._input_bool_cache = {}
		end

		if next(self._input_float_cache) then
			self._input_float_cache = {}
		end

		if next(self._input_axis_cache) then
			self._input_axis_cache = {}
		end

		if next(self._input_touch_bool_cache) then
			self._input_touch_bool_cache = {}
		end

		if next(self._input_touch_pressed_cache) then
			self._input_touch_pressed_cache = {}
		end

		if next(self._input_touch_released_cache) then
			self._input_touch_released_cache = {}
		end

		self:update_multi_input()
		self:update_delay_input()

		self._reset_cache_time = reset_cache_time
	end
end

function ControllerWrapper:update_delay_trigger_queue()
	if self._enabled and self._virtual_controller then
		for connection_name, data in pairs(self._delay_trigger_queue) do
			if not self._virtual_controller:down(Idstring(connection_name)) then
				self._delay_trigger_queue[connection_name] = nil
			elseif self:get_input_bool(connection_name) then
				self._delay_trigger_queue[connection_name] = nil

				data.func(unpack(data.func_params))
			end
		end
	end
end

function ControllerWrapper:check_connect_changed_status()
	local connected = self:connected()

	if connected ~= self._was_connected then
		for callback_id, func in pairs(self._connect_changed_callback_list) do
			func(self, connected, callback_id)
		end

		self._was_connected = connected
	end
end

function ControllerWrapper:update_multi_input()
	if self._enabled and self._virtual_controller then
		for connection_name, single_connection_name_list in pairs(self._multi_input_map) do
			if self:get_connection_enabled(connection_name) then
				local bool = nil

				for _, single_connection_name in ipairs(single_connection_name_list) do
					bool = self._virtual_controller:down(Idstring(single_connection_name))

					if not bool then
						break
					end
				end

				if bool then
					self._input_bool_cache[connection_name] = bool
				else
					self._input_bool_cache[connection_name] = false
					self._input_pressed_cache[connection_name] = false
					self._input_float_cache[connection_name] = 0
					self._input_axis_cache[connection_name] = Vector3()
				end

				local touch = nil

				for _, single_connection_name in ipairs(single_connection_name_list) do
					touch = self._virtual_controller:touch(Idstring(single_connection_name))

					if not touch then
						break
					end
				end

				if touch then
					self._input_touch_bool_cache[connection_name] = touch
				else
					self._input_touch_bool_cache[connection_name] = false
					self._input_touch_pressed_cache[connection_name] = false
				end
			end
		end
	end
end

function ControllerWrapper:update_delay_input()
	if self._enabled and self._virtual_controller then
		local wall_time = TimerManager:wall():time()

		for connection_name, delay_data in pairs(self._delay_map) do
			if self:get_connection_enabled(connection_name) then
				local delay_time_map = delay_data.delay_time_map
				local connection = delay_data.connection
				local delay = connection:get_delay()

				if delay > 0 then
					if not self:get_input_bool(connection_name) then
						for delay_connection_name, delay_time in pairs(delay_time_map) do
							local down = self:get_input_bool(delay_connection_name)
							local allow = nil

							if down then
								if not delay_time then
									delay_time_map[delay_connection_name] = wall_time + delay
								elseif delay_time <= wall_time then
									allow = true
								end

								if not allow then
									self._input_bool_cache[delay_connection_name] = false
									self._input_pressed_cache[connection_name] = false
									self._input_float_cache[delay_connection_name] = 0
									self._input_axis_cache[delay_connection_name] = Vector3()
								end
							elseif delay_time then
								delay_time_map[delay_connection_name] = false
							end
						end
					else
						for delay_connection_name, delay_time in pairs(delay_time_map) do
							delay_time_map[delay_connection_name] = wall_time - delay
						end
					end
				end
			end
		end
	end
end

function ControllerWrapper:add_destroy_callback(func)
	self._last_destroy_callback_id = self._last_destroy_callback_id + 1
	self._destroy_callback_list[self._last_destroy_callback_id] = func

	return self._last_destroy_callback_id
end

function ControllerWrapper:remove_destroy_callback(id)
	self._destroy_callback_list[id] = nil
end

function ControllerWrapper:add_connect_changed_callback(func)
	self._last_connect_changed_callback_id = self._last_connect_changed_callback_id + 1
	self._connect_changed_callback_list[self._last_connect_changed_callback_id] = func

	return self._last_connect_changed_callback_id
end

function ControllerWrapper:remove_connect_changed_callback(id)
	self._connect_changed_callback_list[id] = nil
end

function ControllerWrapper:add_rebind_callback(func)
	self._last_rebind_callback_id = self._last_rebind_callback_id + 1
	self._rebind_callback_list[self._last_rebind_callback_id] = func

	return self._last_rebind_callback_id
end

function ControllerWrapper:remove_rebind_callback(id)
	self._rebind_callback_list[id] = nil
end

function ControllerWrapper:rebind_connections(setup, setup_map)
	self:clear_connections(false)
	self:clear_triggers(true)
	self:setup(setup or self._setup)

	if self._enabled then
		self:restore_triggers()
	end

	for id, func in pairs(self._rebind_callback_list) do
		func(self, id)
	end
end

function ControllerWrapper:setup(setup)
	if setup then
		self._setup = setup
		local connection_map = setup:get_connection_map()

		for _, connection_name in ipairs(setup:get_connection_list()) do
			local connection = connection_map[connection_name]
			local controller_id = connection:get_controller_id() or self._default_controller_id
			local controller = self._controller_map[controller_id]

			self:setup_connection(connection_name, connection, controller_id, controller)
		end
	end
end

function ControllerWrapper:setup_connection(connection_name, connection, controller_id, controller)
	if self._debug or not connection:get_debug() then
		local input_name_list = connection:get_input_name_list()

		for index, input_name in ipairs(input_name_list) do
			self:connect(controller_id, input_name, connection_name, connection, index ~= 1, #input_name_list > 0 and not connection:get_any_input())
		end

		local delay_data = nil
		local delay_connection_list = connection:get_delay_connection_list()

		for index, delay_connection_referer in ipairs(delay_connection_list) do
			local delay_connection_name = delay_connection_referer:get_name()
			local delay_connection = self._setup:get_connection(delay_connection_name)

			if delay_connection then
				local delay_input_name_list = delay_connection:get_input_name_list()
				local can_delay = nil

				for _, delay_input_name in ipairs(delay_input_name_list) do
					for _, input_name in ipairs(input_name_list) do
						if delay_input_name == input_name then
							if not delay_data then
								local delay_data = {
									delay_time_map = {},
									connection = connection
								}
							end

							delay_data.delay_time_map[delay_connection_name] = false
							self._delay_bool_map[delay_connection_name] = true
							can_delay = true

							break
						end
					end

					if can_delay then
						break
					end
				end
			else
				Application:error(self:to_string() .. " Unable to setup delay on non-existing connection \"" .. tostring(delay_connection_name) .. "\" in the \"" .. tostring(connection_name) .. "\" connection.")
			end
		end

		self._delay_map[connection_name] = delay_data

		if connection.IS_AXIS then
			self._current_lerp_axis_map[connection_name] = connection:get_init_lerp_axis() or self._virtual_controller and self._virtual_controller:axis(Idstring(connection_name)) or Vector3()
		end
	end
end

function ControllerWrapper:connect(controller_id, input_name, connection_name, connection, allow_multiple, is_multi)
	local controller = self._controller_map[controller_id or self._default_controller_id]

	if controller then
		if self._virtual_controller then
			if not allow_multiple and self._connection_map[connection_name] then
				Application:error(self:to_string() .. " Controller already has a \"" .. tostring(connection_name) .. "\" connection. Overwrites existing one.")
			end

			self:virtual_connect(controller_id, controller, input_name, connection_name, connection)

			self._connection_map[connection_name] = true

			if is_multi then
				local single_connection_name_list = self._multi_input_map[connection_name] or {}
				local single_connection_name = tostring(connection_name) .. "_for_single_input_" .. tostring(input_name)

				self:virtual_connect(controller_id, controller, input_name, single_connection_name, connection)
				table.insert(single_connection_name_list, single_connection_name)

				self._multi_input_map[connection_name] = single_connection_name_list
			end
		else
			Application:stack_dump_error("Tried to connect to a destroyed virtual controller.")
		end
	else
		error("Invalid controller wrapper. Tried to connect to non-existing controller id \"" .. tostring(controller_id) .. "\".")
	end
end

function ControllerWrapper:virtual_connect(controller_id, controller, input_name, connection_name, connection)
	local func = self._custom_virtual_connect_func_map[controller_id][input_name]

	if func then
		func(controller_id, controller, input_name, connection_name, connection)
	else
		self:virtual_connect2(controller_id, controller, input_name, connection_name, connection)
	end
end

function ControllerWrapper:virtual_connect2(controller_id, controller, input_name, connection_name, connection)
	local min_src, max_src, min_dest, max_dest = connection:get_range()
	local connect_src_type = connection:get_connect_src_type()
	local connect_dest_type = connection:get_connect_dest_type()

	if connection._btn_connections and input_name == "buttons" then
		local btn_data = {
			up = {
				1,
				0,
				1
			},
			down = {
				1,
				0,
				-1
			},
			left = {
				0,
				0,
				-1
			},
			right = {
				0,
				0,
				1
			},
			accelerate = {
				1,
				0,
				1
			},
			brake = {
				1,
				0,
				-1
			},
			turn_left = {
				0,
				0,
				-1
			},
			turn_right = {
				0,
				0,
				1
			}
		}

		if not self._virtual_controller:has_axis(Idstring(connection_name)) then
			self._virtual_controller:add_axis(Idstring(connection_name))
		end

		for btn, input in pairs(connection._btn_connections) do
			if controller:has_button(Idstring(input.name)) and input.type == "button" or controller:has_axis(Idstring(input.name)) and input.type == "axis" then
				if input.type == "axis" then
					self._virtual_controller:connect(controller, Idstring("axis"), Idstring(input.name), tonumber(input.dir), Idstring("range"), tonumber(input.range1), tonumber(input.range2), Idstring("axis"), Idstring(connection_name), btn_data[btn][1], Idstring("range"), btn_data[btn][2], btn_data[btn][3])
				else
					self._virtual_controller:connect(controller, Idstring("button"), Idstring(input.name), Idstring("axis"), Idstring(connection_name), btn_data[btn][1], Idstring("range"), btn_data[btn][2], btn_data[btn][3])
				end
			end
		end
	else
		if type(input_name) ~= "number" then
			input_name = Idstring(input_name)
		end

		if controller:has_button(input_name) or controller:has_axis(input_name) then
			self._virtual_controller:connect(controller, Idstring(connect_src_type), input_name, Idstring("range"), min_src, max_src, Idstring(connect_dest_type), Idstring(connection_name), Idstring("range"), min_dest, max_dest)
		elseif self._virtual_controller:has_button(input_name) or self._virtual_controller:has_axis(input_name) then
			self._virtual_controller:connect(self._virtual_controller, Idstring(connect_src_type), input_name, Idstring("range"), min_src, max_src, Idstring(connect_dest_type), Idstring(connection_name), Idstring("range"), min_dest, max_dest)
		else
			Application:error("Invalid input name \"" .. tostring(input_name) .. "\". Controller type: \"" .. tostring(controller_id) .. "\", Connection name: \"" .. tostring(connection_name) .. "\".")
		end
	end
end

function ControllerWrapper:connected(controller_id)
	if controller_id then
		return self._controller_map[controller_id]:connected()
	else
		for _, controller in pairs(self._controller_map) do
			if not controller:connected() then
				return false
			end
		end

		return true
	end
end

function ControllerWrapper:get_setup()
	return self._setup
end

function ControllerWrapper:get_connection_settings(connection_name)
	return self._setup:get_connection(connection_name)
end

function ControllerWrapper:get_default_controller_id()
	return self._default_controller_id
end

function ControllerWrapper:get_type()
	return self.TYPE
end

function ControllerWrapper:get_id()
	return self._id
end

function ControllerWrapper:get_name()
	return self._name
end

function ControllerWrapper:get_debug()
	return self._debug
end

function ControllerWrapper:get_connection_map()
	return self._connection_map
end

function ControllerWrapper:get_controller_map()
	return self._controller_map
end

function ControllerWrapper:get_controller(controller_id)
	return self._controller_map[controller_id or self._default_controller_id]
end

function ControllerWrapper:connection_exist(connection_name)
	return self._connection_map[connection_name] ~= nil
end

function ControllerWrapper:set_enabled(bool)
	if bool then
		self:enable()
	else
		self:disable()
	end
end

function ControllerWrapper:enable()
	self:set_active(true)
end

function ControllerWrapper:disable()
	self:set_active(false)
end

function ControllerWrapper:_really_activate()
	ControllerWrapper.super._really_activate(self)

	if not self._enabled then
		cat_print("controller_manager", "[ControllerManager] Enabled controller \"" .. tostring(self._name) .. "\".")

		if self._virtual_controller then
			self._virtual_controller:set_enabled(true)
		end

		self._enabled = true

		self:clear_triggers(true)
		self:restore_triggers()
		self:reset_cache(false)

		self._was_connected = self:connected()
	end
end

function ControllerWrapper:_really_deactivate()
	ControllerWrapper.super._really_deactivate(self)

	if self._enabled then
		cat_print("controller_manager", "[ControllerManager] Disabled controller \"" .. tostring(self._name) .. "\".")

		self._enabled = false

		self:clear_triggers(true)
		self:reset_cache(false)

		if self._virtual_controller then
			self._virtual_controller:set_enabled(false)
		end
	end
end

function ControllerWrapper:enabled()
	return self._enabled
end

function ControllerWrapper:is_claimed()
	return self._claimed
end

function ControllerWrapper:set_claimed(bool)
	self._claimed = bool
end

function ControllerWrapper:add_trigger(connection_name, func)
	local trigger = {}
	self._trigger_map[connection_name] = self._trigger_map[connection_name] or {}

	if self._trigger_map[connection_name][func] then
		Application:error(self:to_string() .. " Unable to register already existing trigger for function \"" .. tostring(func) .. "\" on connection \"" .. tostring(connection_name) .. "\".")

		return
	end

	trigger.original_func = func
	trigger.func = self:get_trigger_func(connection_name, func)

	if self._enabled and self._virtual_controller and self:get_connection_enabled(connection_name) then
		trigger.id = self._virtual_controller:add_trigger(Idstring(connection_name), trigger.func)
	end

	self._trigger_map[connection_name][func] = trigger
end

function ControllerWrapper:add_release_trigger(connection_name, func)
	local trigger = {}
	self._release_trigger_map[connection_name] = self._release_trigger_map[connection_name] or {}
	trigger.original_func = func
	trigger.func = self:get_release_trigger_func(connection_name, func)

	if self._virtual_controller and self:get_connection_enabled(connection_name) then
		trigger.id = self._virtual_controller:add_release_trigger(Idstring(connection_name), trigger.func)
	end

	self._release_trigger_map[connection_name][func] = trigger
end

function ControllerWrapper:get_trigger_func(connection_name, func)
	local wrapper = self

	if self._delay_bool_map[connection_name] or self._multi_input_map[connection_name] then
		return function (...)
			wrapper:reset_cache(true)

			if wrapper:get_input_bool(connection_name) then
				func(...)
			else
				wrapper:queue_delay_trigger(connection_name, func, ...)
			end
		end
	else
		return function (...)
			wrapper:reset_cache(true)
			func(...)
		end
	end
end

function ControllerWrapper:get_release_trigger_func(connection_name, func)
	local wrapper = self

	if self._delay_bool_map[connection_name] or self._multi_input_map[connection_name] then
		return function (...)
			wrapper:reset_cache(true)

			if wrapper:get_input_bool(connection_name) then
				func(...)
			end
		end
	else
		return function (...)
			wrapper:reset_cache(true)
			func(...)
		end
	end
end

function ControllerWrapper:queue_delay_trigger(connection_name, func, ...)
	self._delay_trigger_queue[connection_name] = {
		func = func,
		func_params = {...}
	}
end

function ControllerWrapper:has_trigger(connection_name, func)
	local trigger_sub_map = self._trigger_map[connection_name]

	return trigger_sub_map and trigger_sub_map[func]
end

function ControllerWrapper:has_release_trigger(connection_name, func)
	local release_trigger_sub_map = self._release_trigger_map[connection_name]

	return release_trigger_sub_map and release_trigger_sub_map[func]
end

function ControllerWrapper:remove_trigger(connection_name, func)
	local trigger_sub_map = self._trigger_map[connection_name]

	if trigger_sub_map then
		if func then
			local trigger = trigger_sub_map[func]

			if trigger then
				local queued_trigger = self._delay_trigger_queue[connection_name]

				if queued_trigger and trigger.original_func == queued_trigger.func then
					self._delay_trigger_queue[connection_name] = nil
				end

				if trigger.id then
					self._virtual_controller:remove_trigger(trigger.id)

					trigger.id = nil
				end
			else
				Application:error(self:to_string() .. " Unable to remove non-existing trigger for function \"" .. tostring(func) .. "\" on connection \"" .. tostring(connection_name) .. "\".")
			end

			trigger_sub_map[func] = nil

			if not next(trigger_sub_map) then
				trigger_sub_map = nil
			end
		else
			self._delay_trigger_queue[connection_name] = nil

			for _, trigger in pairs(trigger_sub_map) do
				self._virtual_controller:remove_trigger(trigger.id)

				trigger.id = nil
			end

			trigger_sub_map = nil
		end

		self._trigger_map[connection_name] = trigger_sub_map
	else
		Application:error(self:to_string() .. " Unable to remove trigger on non-existing connection \"" .. tostring(connection_name) .. "\".")
	end
end

function ControllerWrapper:remove_release_trigger(connection_name, func)
	local trigger_sub_map = self._release_trigger_map[connection_name]

	if trigger_sub_map then
		if func then
			trigger = trigger_sub_map[func]

			if trigger then
				if trigger.id then
					self._virtual_controller:remove_trigger(trigger.id)

					trigger.id = nil
				end
			else
				Application:error(self:to_string() .. " Unable to remove non-existing release trigger for function \"" .. tostring(func) .. "\" on connection \"" .. tostring(connection_name) .. "\".")
			end

			trigger_sub_map[func] = nil

			if not next(trigger_sub_map) then
				trigger_sub_map = nil
			end
		else
			for _, trigger in pairs(trigger_sub_map) do
				self._virtual_controller:remove_trigger(trigger.id)

				trigger.id = nil
			end

			trigger_sub_map = nil
		end

		self._release_trigger_map[connection_name] = trigger_sub_map
	else
		Application:error(self:to_string() .. " Unable to remove release trigger on non-existing connection \"" .. tostring(connection_name) .. "\".")
	end
end

function ControllerWrapper:clear_triggers(temporary)
	if self._virtual_controller then
		self._virtual_controller:clear_triggers()
	end

	self._delay_trigger_queue = {}

	if temporary then
		for _, trigger_sub_map in pairs(self._trigger_map) do
			for _, trigger in pairs(trigger_sub_map) do
				trigger.id = nil
			end
		end

		for _, release_trigger_sub_map in pairs(self._release_trigger_map) do
			for _, release_trigger in pairs(release_trigger_sub_map) do
				release_trigger.id = nil
			end
		end
	else
		self._trigger_map = {}
		self._release_trigger_map = {}
	end
end

function ControllerWrapper:restore_triggers()
	if self._virtual_controller then
		for connection_name, trigger_sub_map in pairs(self._trigger_map) do
			for _, trigger in pairs(trigger_sub_map) do
				if self:get_connection_enabled(connection_name) then
					trigger.id = self._virtual_controller:add_trigger(Idstring(connection_name), trigger.func)
				end
			end
		end

		for connection_name, trigger_sub_map in pairs(self._release_trigger_map) do
			for _, trigger in pairs(trigger_sub_map) do
				if self:get_connection_enabled(connection_name) then
					trigger.id = self._virtual_controller:add_release_trigger(Idstring(connection_name), trigger.func)
				end
			end
		end
	end
end

function ControllerWrapper:clear_connections(temporary)
	if self._virtual_controller then
		self._virtual_controller:clear_connections()
	end

	if not temporary then
		self._connection_map = {}
		self._delay_map = {}
		self._delay_bool_map = {}
		self._multi_input_map = {}
	end
end

function ControllerWrapper:get_any_input()
	if self._input_any_cache == nil then
		self._input_any_cache = self._enabled and self._virtual_controller and #self._virtual_controller:down_list() > 0
		self._input_any_cache = not not self._input_any_cache
	end

	return self._input_any_cache
end

function ControllerWrapper:get_any_input_pressed()
	if self._input_any_pressed_cache == nil then
		self._input_any_pressed_cache = self._enabled and self._virtual_controller and #self._virtual_controller:pressed_list() > 0
		self._input_any_pressed_cache = not not self._input_any_pressed_cache
	end

	return self._input_any_pressed_cache
end

function ControllerWrapper:get_any_input_released()
	if self._input_any_released_cache == nil then
		self._input_any_released_cache = self._enabled and self._virtual_controller and #self._virtual_controller:released_list() > 0
		self._input_any_released_cache = not not self._input_any_released_cache
	end

	return self._input_any_released_cache
end
local id_strings = {}

function ControllerWrapper:get_input_pressed(connection_name)
	local cache = self._input_pressed_cache[connection_name]

	if cache == nil then
		if self._connection_map[connection_name] then
			id_strings[connection_name] = id_strings[connection_name] or Idstring(connection_name)
			local ids = id_strings[connection_name]
			cache = self._enabled and self._virtual_controller and self:get_connection_enabled(connection_name) and self._virtual_controller:pressed(ids) or false
			cache = not not cache
		else
			self:print_invalid_connection_error(connection_name)

			cache = false
		end

		self._input_pressed_cache[connection_name] = cache
	end

	return cache
end

function ControllerWrapper:print_invalid_connection_error(connection_name)
	ControllerWrapper.INVALID_CONNECTION_ERROR = ControllerWrapper.INVALID_CONNECTION_ERROR or {}

	if not ControllerWrapper.INVALID_CONNECTION_ERROR[connection_name] then
		Application:stack_dump_error(self:to_string() .. " No controller input binded to connection \"" .. tostring(connection_name) .. "\".")

		ControllerWrapper.INVALID_CONNECTION_ERROR[connection_name] = true
	end
end

function ControllerWrapper:get_input_bool(connection_name)
	local cache = self._input_bool_cache[connection_name]

	if cache == nil then
		if self._connection_map[connection_name] then
			id_strings[connection_name] = id_strings[connection_name] or Idstring(connection_name)
			local ids = id_strings[connection_name]
			cache = self._enabled and self._virtual_controller and self:get_connection_enabled(connection_name) and self._virtual_controller:down(ids) or false
			cache = not not cache
		else
			self:print_invalid_connection_error(connection_name)

			cache = false
		end

		self._input_bool_cache[connection_name] = cache
	end

	return cache
end

function ControllerWrapper:get_input_touch_bool(connection_name)
	local cache = self._input_touch_bool_cache[connection_name]

	if cache == nil then
		if self._connection_map[connection_name] then
			id_strings[connection_name] = id_strings[connection_name] or Idstring(connection_name)
			local ids = id_strings[connection_name]
			cache = self._enabled and self._virtual_controller and self:get_connection_enabled(connection_name) and self._virtual_controller:touch(ids) or false
			cache = not not cache
		else
			self:print_invalid_connection_error(connection_name)

			cache = false
		end

		self._input_touch_bool_cache[connection_name] = cache
	end

	return cache
end

function ControllerWrapper:get_input_touch_pressed(connection_name)
	local cache = self._input_touch_pressed_cache[connection_name]

	if cache == nil then
		if self._connection_map[connection_name] then
			id_strings[connection_name] = id_strings[connection_name] or Idstring(connection_name)
			local ids = id_strings[connection_name]
			cache = self._enabled and self._virtual_controller and self:get_connection_enabled(connection_name) and self._virtual_controller:touch_pressed(ids) or false
			cache = not not cache
		else
			self:print_invalid_connection_error(connection_name)

			cache = false
		end

		self._input_touch_pressed_cache[connection_name] = cache
	end

	return cache
end

function ControllerWrapper:get_input_touch_released(connection_name)
	local cache = self._input_touch_released_cache[connection_name]

	if cache == nil then
		if self._connection_map[connection_name] then
			id_strings[connection_name] = id_strings[connection_name] or Idstring(connection_name)
			local ids = id_strings[connection_name]
			cache = self._enabled and self._virtual_controller and self:get_connection_enabled(connection_name) and self._virtual_controller:touch_released(ids) or false
			cache = not not cache
		else
			self:print_invalid_connection_error(connection_name)

			cache = false
		end

		self._input_touch_released_cache[connection_name] = cache
	end

	return cache
end

function ControllerWrapper:get_input_float(connection_name)
	local cache = self._input_float_cache[connection_name]

	if cache == nil then
		if self._connection_map[connection_name] then
			id_strings[connection_name] = id_strings[connection_name] or Idstring(connection_name)
			local ids = id_strings[connection_name]
			cache = self._enabled and self._virtual_controller and self:get_connection_enabled(connection_name) and self._virtual_controller:button(ids) or 0
		else
			self:print_invalid_connection_error(connection_name)

			cache = 0
		end

		self._input_float_cache[connection_name] = cache
	end

	return cache
end

function ControllerWrapper:get_input_axis_clbk(connection_name, func)
	if not self:enabled() then
		return
	end

	local id = id_strings[connection_name]

	if not id then
		id = Idstring(connection_name)
		id_strings[connection_name] = id
	end

	local connection = self._setup:get_connection(connection_name)

	local function f(axis_id, controller_name, axis)
		local unscaled_axis = mvector3.copy(axis)

		func(self:get_modified_axis(connection_name, connection, axis), self:get_unscaled_axis(connection_name, connection, unscaled_axis))
	end

	self._virtual_controller:add_axis_trigger(id, f)
end

function ControllerWrapper:get_input_axis(connection_name)
	local cache = self._input_axis_cache[connection_name]

	if cache == nil then
		if self._connection_map[connection_name] then
			id_strings[connection_name] = id_strings[connection_name] or Idstring(connection_name)
			local ids = id_strings[connection_name]
			cache = self._enabled and self._virtual_controller and self:get_connection_enabled(connection_name) and self._virtual_controller:axis(ids)

			if cache then
				local connection = self._setup:get_connection(connection_name)
				cache = self:get_modified_axis(connection_name, connection, cache)
			else
				cache = Vector3()
			end
		else
			self:print_invalid_connection_error(connection_name)

			cache = Vector3()
		end

		self._input_axis_cache[connection_name] = cache
	end

	return cache
end

function ControllerWrapper:get_unscaled_axis(connection_name, connection, axis)
	local inversion = connection.get_inversion and connection:get_inversion()

	if inversion then
		mvector3.set_static(axis, mvector3.x(axis) * inversion.x, mvector3.y(axis) * inversion.y, mvector3.z(axis) * inversion.z)
	end

	return axis
end

function ControllerWrapper:get_modified_axis(connection_name, connection, axis)
	local multiplier = connection.get_multiplier and connection:get_multiplier()

	if multiplier then
		mvector3.set_static(axis, mvector3.x(axis) * multiplier.x, mvector3.y(axis) * multiplier.y, mvector3.z(axis) * multiplier.z)
	end

	local inversion = connection.get_inversion and connection:get_inversion()

	if inversion then
		mvector3.set_static(axis, mvector3.x(axis) * inversion.x, mvector3.y(axis) * inversion.y, mvector3.z(axis) * inversion.z)
	end

	local x = self:rescale_x_axis(connection_name, connection, axis.x)
	local y = self:rescale_y_axis(connection_name, connection, axis.y)
	local z = self:rescale_z_axis(connection_name, connection, axis.z)

	mvector3.set_static(axis, x, y, z)

	return self:lerp_axis(connection_name, connection, axis)
end

function ControllerWrapper:lerp_axis(connection_name, connection, axis)
	local lerp = connection.get_lerp and connection:get_lerp()

	if lerp then
		local current_axis = self._current_lerp_axis_map[connection_name]

		mvector3.lerp(axis, current_axis, axis, lerp)

		self._current_lerp_axis_map[connection_name] = axis
	end

	return axis
end

function ControllerWrapper:rescale_x_axis(connection_name, connection, x)
	return self:rescale_axis_component(connection_name, connection, x)
end

function ControllerWrapper:rescale_y_axis(connection_name, connection, y)
	return self:rescale_axis_component(connection_name, connection, y)
end

function ControllerWrapper:rescale_z_axis(connection_name, connection, z)
	return self:rescale_axis_component(connection_name, connection, z)
end

function ControllerWrapper:rescale_axis_component(connection_name, connection, comp)
	return comp
end

function ControllerWrapper:set_connection_enabled(connection_name, enabled)
	local connection = self._connection_map[connection_name] and self._setup:get_connection(connection_name)

	if connection then
		if not connection:get_enabled() ~= not enabled then
			connection:set_enabled(enabled)

			local trigger_sub_map = self._trigger_map[connection_name]

			if trigger_sub_map then
				for _, trigger in pairs(trigger_sub_map) do
					if enabled then
						if not trigger.id then
							trigger.id = self._virtual_controller:add_trigger(Idstring(connection_name), trigger.func)
						end
					elseif trigger.id then
						self._virtual_controller:remove_trigger(trigger.id)

						trigger.id = nil
					end
				end
			end

			trigger_sub_map = self._release_trigger_map[connection_name]

			if trigger_sub_map then
				for _, trigger in pairs(trigger_sub_map) do
					if enabled then
						if not trigger.id then
							trigger.id = self._virtual_controller:add_release_trigger(Idstring(connection_name), trigger.func)
						end
					elseif trigger.id then
						self._virtual_controller:remove_trigger(trigger.id)

						trigger.id = nil
					end
				end
			end

			if not enabled then
				self._delay_trigger_queue[connection_name] = nil
			end

			local delay_data = self._delay_map[connection_name]

			if delay_data then
				for delay_connection_name in pairs(delay_data.delay_time_map) do
					local trigger_sub_map = self._trigger_map[delay_connection_name]

					if trigger_sub_map then
						for _, trigger in pairs(trigger_sub_map) do
							trigger.func = self:get_trigger_func(delay_connection_name, trigger.original_func)

							if trigger.id then
								self._virtual_controller:remove_trigger(trigger.id)

								trigger.id = self._virtual_controller:add_trigger(Idstring(delay_connection_name), trigger.func)
							end
						end
					end

					local release_trigger_sub_map = self._release_trigger_map[delay_connection_name]

					if release_trigger_sub_map then
						for _, release_trigger in pairs(release_trigger_sub_map) do
							release_trigger.func = self:get_trigger_func(delay_connection_name, release_trigger.original_func)

							if release_trigger.id then
								self._virtual_controller:remove_trigger(release_trigger.id)

								release_trigger.id = self._virtual_controller:add_release_trigger(Idstring(delay_connection_name), release_trigger.func)
							end
						end
					end
				end

				self:update_delay_trigger_queue()
			end
		end
	else
		Application:error(self:to_string() .. " Controller can't enable connection \"" .. tostring(connection_name) .. "\" because it doesn't exist.")
	end
end

function ControllerWrapper:get_connection_enabled(connection_name)
	local connection = self._connection_map[connection_name] and self._setup:get_connection(connection_name)
	local ret = connection and connection:get_enabled()

	return ret
end

function ControllerWrapper:to_string()
	return self:__tostring()
end

function ControllerWrapper:__tostring()
	return string.format("[Controller][Wrapper][ID: %s, Type: %s, Name: %s, Enabled: %s, Debug: %s]", tostring(self._id), tostring(self:get_type()), tostring(self._name or "N/A"), tostring(self._enabled and "Yes" or "No"), tostring(self._debug and "Yes" or "No"))
end

function ControllerWrapper.change_mode(controller, mode)
	return nil
end

