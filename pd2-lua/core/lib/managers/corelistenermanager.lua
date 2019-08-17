core:module("CoreListenerManager")
core:import("CoreLinkedStackMap")

ListenerManager = ListenerManager or class()

function ListenerManager:init()
	self._set_map = {}
	self._category_map = {}
	self._listener_map = {}
	self._active_category_map = {}
	self._active_set_count_map = {}
	self._active_set_stack_map = {}
	self._activation_map = {}
	self._stack_activation_map = {}
	self._set_activation_map = {}
	self._last_activation_id = 0
	self._enabled = true

	self:add_stack("main")
end

function ListenerManager:active_listener_obj()
	for id, listener_data in pairs(self._listener_map) do
		if listener_data.active then
			return listener_data.distance_obj
		end
	end
end

function ListenerManager:get_closest_listener_position(position)
	Application:error("ListenerManager:get_closest_listener_position dont function in wwise yet")

	return

	local closest_position, closest_distance = nil

	self:callback_on_all_active_listeners(function (listener_id)
		local distance_obj = Sound:listener(listener_id)

		if alive(distance_obj) then
			local obj_position = distance_obj:position()
			local obj_distance = (obj_position - position):length()

			if not closest_distance or obj_distance < closest_distance then
				closest_position = obj_position
				closest_distance = obj_distance
			end
		end
	end)

	return closest_position, closest_distance
end

function ListenerManager:set_enabled(enabled)
	enabled = not not enabled

	if self._enabled ~= enabled then
		self:callback_on_all_active_listeners(function (listener_id)
			self._listener_map[listener_id].listener:activate(enabled)
		end)

		self._enabled = enabled
	end
end

function ListenerManager:callback_on_all_active_listeners(func)
	local done_set_map = {}
	local done_category_map = {}

	for stack_id, stack in pairs(self._active_set_stack_map) do
		local set_id = stack:top()

		if set_id and not done_set_map[set_id] then
			for category_id, category_map in pairs(self._set_map[set_id]) do
				if not done_category_map[category_id] then
					for listener_id, listener in pairs(category_map) do
						func(listener_id)
					end

					done_category_map[category_id] = true
				end
			end

			done_set_map[set_id] = true
		end
	end
end

function ListenerManager:has_stack(stack_id)
	return self._active_set_stack_map[stack_id] ~= nil
end

function ListenerManager:has_set(set_id)
	return self._set_map[set_id] ~= nil
end

function ListenerManager:has_category(category_id)
	return self._category_map[category_id] ~= nil
end

function ListenerManager:add_stack(stack_id)
	if not self._active_set_stack_map[stack_id] then
		self._active_set_stack_map[stack_id] = CoreLinkedStackMap.LinkedStackMap:new()
		self._stack_activation_map[stack_id] = {}
	else
		Application:stack_dump_error("Stack id \"" .. tostring(stack_id) .. "\" already exists.")
	end
end

function ListenerManager:remove_stack(stack_id)
	local active_set_stack = self._active_set_stack_map[stack_id]

	if active_set_stack then
		self._active_set_stack_map[stack_id] = nil

		for activation_id in pairs(self._stack_activation_map[stack_id]) do
			self:deactivate_set(activation_id)
		end

		self._stack_activation_map[stack_id] = nil
	else
		Application:stack_dump_error("Stack id \"" .. tostring(stack_id) .. "\" doesn't exists.")
	end
end

function ListenerManager:add_set(set_id, category_id_list)
	if not self._set_map[set_id] then
		self._set_map[set_id] = {}
		self._set_activation_map[set_id] = {}

		if category_id_list then
			for _, category_id in ipairs(category_id_list) do
				self:add_set_category(set_id, category_id)
			end
		end
	else
		Application:stack_dump_error("Unable to add an already set id \"" .. tostring(set_id) .. "\"")
	end
end

function ListenerManager:remove_set(set_id)
	local category_map = self._set_map[set_id]

	if category_map then
		for category_id in pairs(category_map) do
			self:remove_set_category(set_id, category_id)
		end

		for activation_id in pairs(self._set_activation_map[set_id]) do
			self:deactivate_set(activation_id)
		end

		self._set_map[set_id] = nil
		self._set_activation_map[set_id] = nil
	else
		Application:stack_dump_error("Unable to remove non-existing set id \"" .. tostring(set_id) .. "\"")
	end
end

function ListenerManager:add_set_category(set_id, category_id)
	local category_map = self._set_map[set_id]

	if category_map then
		local listener_map = self._category_map[category_id]

		if not listener_map then
			listener_map = {}
			self._category_map[category_id] = listener_map
			self._active_category_map[category_id] = false
		end

		category_map[category_id] = listener_map
	else
		Application:stack_dump_error("Unable to add a category id \"" .. tostring(category_id) .. "\" on non-existing set id \"" .. tostring(set_id) .. "\"")
	end
end

function ListenerManager:remove_set_category(set_id, category_id)
	local category_map = self._set_map[set_id]

	if category_map then
		if category_map[category_id] then
			category_map[category_id] = nil
		else
			Application:stack_dump_error("Unable to remove non-existing category id \"" .. tostring(category_id) .. "\" on set id \"" .. tostring(set_id) .. "\"")
		end
	else
		Application:stack_dump_error("Unable to remove a category id \"" .. tostring(category_id) .. "\" on non-existing set id \"" .. tostring(set_id) .. "\"")
	end
end

function ListenerManager:add_category(category_id)
	if not self._category_map[category_id] then
		self._category_map[category_id] = {}
		self._active_category_map[category_id] = false
	else
		Application:stack_dump_error("Unable to add already existing category id \"" .. tostring(category_id) .. "\"")
	end
end

function ListenerManager:remove_category(category_id)
	if self._category_map[category_id] then
		for set_id, category_map in pairs(self._set_map) do
			if category_map[category_id] then
				self:remove_set_category(set_id, category_id)
			end
		end

		self._category_map[category_id] = nil
		self._active_category_map[category_id] = nil
	else
		Application:stack_dump_error("Unable to remove non-existing category id \"" .. tostring(category_id) .. "\"")
	end
end

function ListenerManager:add_listener(category_id, distance_obj, orientation_obj, occlusion_obj, disabled)
	if not self._category_map[category_id] then
		self:add_category(category_id)
	end

	local listener_map = self._category_map[category_id]
	local listener = SoundDevice:create_listener(category_id)

	listener:link_position(distance_obj)

	if orientation_obj then
		listener:link_orientation(orientation_obj)
	end

	if occlusion_obj then
		listener:link_occlusion(occlusion_obj)
	end

	local listener_data = {
		listener = listener,
		category_id = category_id,
		enabled = not disabled,
		distance_obj = distance_obj,
		orientation_obj = orientation_obj,
		occlusion_obj = occlusion_obj
	}
	local key = listener:key()
	self._listener_map[key] = listener_data
	listener_map[key] = listener_data

	if not self._enabled or disabled or not self._active_category_map[category_id] then
		listener:activate(false)
	end

	return key
end

function ListenerManager:remove_listener(listener_id)
	local listener = self._listener_map[listener_id]

	if listener then
		local category_id = listener.category_id
		local listener_map = self._category_map[category_id]

		if listener_map then
			if listener_map[listener_id] then
				listener_map[listener_id].listener = nil
				listener_map[listener_id] = nil
				self._listener_map[listener_id] = nil
			else
				Application:stack_dump_error("Unable to remove non-existing listener id \"" .. tostring(listener_id) .. "\" in category id \"" .. tostring(category_id) .. "\".")
			end
		else
			Application:stack_dump_error("Unable to remove listener id \"" .. tostring(listener_id) .. "\" in non-existing category id \"" .. tostring(category_id) .. "\".")
		end
	else
		Application:stack_dump_error("Unable to remove non-existing listener id \"" .. tostring(listener_id) .. "\".")
	end
end

function ListenerManager:set_listener(listener_id, distance_obj, orientation_obj, occlusion_obj)
	local listener = self._listener_map[listener_id]

	if listener then
		local category_id = listener.category_id
		local listener_map = self._category_map[category_id]

		if listener_map then
			if listener_map[listener_id] then
				local listener = listener_map[listener_id].listener

				listener:link_position(distance_obj)

				if orientation_obj then
					listener:link_orientation(orientation_obj)
				end

				if occlusion_obj then
					listener:link_occlusion(occlusion_obj)
				end
			else
				Application:stack_dump_error("Unable to set non-existing listener id \"" .. tostring(listener_id) .. "\" in category id \"" .. tostring(category_id) .. "\".")
			end
		else
			Application:stack_dump_error("Unable to set listener id \"" .. tostring(listener_id) .. "\" in non-existing category id \"" .. tostring(category_id) .. "\".")
		end
	else
		Application:stack_dump_error("Unable to set non-existing listener id \"" .. tostring(listener_id) .. "\".")
	end
end

function ListenerManager:set_listener_enabled(listener_id, enabled)
	local data = self._listener_map[listener_id]

	if data then
		data.enabled = enabled

		if self._active_category_map[data.category_id] then
			data.listener:activate(self._enabled and enabled)
		end
	else
		Application:stack_dump_error("Unable to set non-existing listener id \"" .. tostring(listener_id) .. "\".")
	end
end

function ListenerManager:get_listener_enabled(listener_id)
	local listener = self._listener_map[listener_id]

	if listener then
		return listener.enabled
	else
		Application:stack_dump_error("Unable to get non-existing listener id \"" .. tostring(listener_id) .. "\".")

		return nil
	end
end

function ListenerManager:activate_set(stack_id, set_id)
	local active_set_stack = self._active_set_stack_map[stack_id]

	if active_set_stack then
		if self._set_map[set_id] then
			local active_set_id = active_set_stack:top()

			if active_set_id ~= set_id then
				if active_set_id and self._active_set_count_map[active_set_id] == 1 then
					self:_deactivate_set(active_set_id)
				end

				self:_activate_set(set_id)
			end

			local link_id = active_set_stack:add(set_id)
			local activation_id = self._last_activation_id + 1
			self._activation_map[activation_id] = {
				stack_id = stack_id,
				set_id = set_id,
				link_id = link_id
			}
			self._stack_activation_map[stack_id][activation_id] = true
			self._set_activation_map[set_id][activation_id] = true
			self._last_activation_id = activation_id

			return activation_id
		else
			Application:stack_dump_error("Unable to activate non-existing set id \"" .. tostring(set_id) .. "\" on stack id \"" .. stack_id .. "\".")
		end
	else
		Application:stack_dump_error("Unable to activate set id \"" .. tostring(set_id) .. "\" on non-existing stack id \"" .. stack_id .. "\".")
	end

	return -1
end

function ListenerManager:deactivate_set(activation_id)
	local activation = self._activation_map[activation_id]

	if activation then
		local stack_id = activation.stack_id
		local set_id = activation.set_id
		local active_set_stack = self._active_set_stack_map[stack_id]
		local top_set_id = active_set_stack:top()

		active_set_stack:remove(activation.link_id)

		local next_active_set_id = active_set_stack:top()

		if set_id == top_set_id and set_id ~= next_active_set_id then
			if next_active_set_id and not self._active_set_count_map[next_active_set_id] then
				self:_activate_set(next_active_set_id)
			end

			self:_deactivate_set(set_id)
		end

		self._activation_map[activation_id] = nil
		self._stack_activation_map[stack_id][activation_id] = nil
		self._set_activation_map[set_id][activation_id] = nil
	else
		Application:stack_dump_error("Unable to deactivate non-existing activation id \"" .. tostring(activation_id) .. "\".")
	end
end

function ListenerManager:_activate_set(set_id)
	local active_set_count = self._active_set_count_map[set_id]

	if not active_set_count then
		self:_set_listener_set_active(set_id, true)
	end

	active_set_count = active_set_count or 0
	self._active_set_count_map[set_id] = active_set_count + 1
end

function ListenerManager:_deactivate_set(set_id)
	local active_set_count = self._active_set_count_map[set_id]
	active_set_count = active_set_count - 1

	if active_set_count <= 0 then
		active_set_count = nil

		self:_set_listener_set_active(set_id, false)
	end

	self._active_set_count_map[set_id] = active_set_count
end

function ListenerManager:_set_listener_set_active(set_id, active)
	for category_id, listener_map in pairs(self._set_map[set_id]) do
		self._active_category_map[category_id] = active

		for _, data in pairs(listener_map) do
			data.listener:activate(self._enabled and data.enabled and active)

			data.active = active
		end
	end
end

function ListenerManager:debug_print()
	for stack_id, stack in pairs(self._active_set_stack_map) do
		cat_debug("debug", tostring(stack_id) .. ": " .. tostring(stack:to_string()))
	end
end
