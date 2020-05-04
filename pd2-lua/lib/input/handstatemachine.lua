HandStateMachine = HandStateMachine or class()

function HandStateMachine:init(states, default_l, default_r)
	self._states = states
	self._hands = {
		{
			default_l
		},
		{
			default_r
		}
	}
	self._modified_connection_list = {}

	for _, state in pairs(self._states) do
		local names = state:connnection_names()

		for _, name in ipairs(names) do
			self._modified_connection_list[name] = true
		end
	end

	self._possible_inputs = {}

	for _, state in pairs(self._states) do
		for connection, data in pairs(state._connections or {}) do
			self._possible_inputs[connection] = self._possible_inputs[connection] or {}

			for hand = 1, 2 do
				if not data.hand or data.hand == hand then
					local hand_suffix = hand == 1 and "r" or "l"
					local inputs = type(data.inputs) == "table" and data.inputs or {}

					for _, input in ipairs(inputs) do
						local full_input = input .. hand_suffix

						if not table.contains(self._possible_inputs[connection], full_input) then
							table.insert(self._possible_inputs[connection], full_input)
						end
					end
				end
			end
		end
	end

	self:_apply_bindings()
end

function HandStateMachine:enter_hand_state(hand, state_name)
	local other_hand = hand == 1 and 2 or 1
	local active_states = self._hands[hand]
	local new_state = self._states[state_name]

	if not new_state then
		Application:stack_dump_error("[HandStateMachine] Trying to enter undefined hand state " .. tostring(state_name))

		return
	end

	local level = new_state:level()

	for i, state in ipairs(active_states) do
		if state == new_state then
			return
		end

		if state:level() == level then
			table.remove(active_states, i)

			break
		end
	end

	table.insert_sorted(active_states, new_state, function (a, b)
		return a:level() < b:level()
	end)
	self:_apply_bindings()
end

function HandStateMachine:exit_hand_state(hand, state_name)
	local active_states = self._hands[hand]
	local target_state = self._states[state_name]

	if not target_state then
		Application:stack_dump_error("[HandStateMachine] Trying to leave undefined hand state " .. tostring(target_state))

		return
	end

	for i, state in ipairs(active_states) do
		if target_state == state then
			table.remove(active_states, i)
			self:_apply_bindings()

			return
		end
	end
end

function HandStateMachine:refresh()
	self:_apply_bindings()
end

function HandStateMachine:attach_controller(controller, main)
	self._controllers = self._controllers or {}

	for _, c in ipairs(self._controllers) do
		if c == controller then
			return
		end
	end

	table.insert(self._controllers, controller)

	if main then
		self._controller = controller
	end

	self:_apply_bindings()
end

function HandStateMachine:deattach_controller(controller)
	for i, c in ipairs(self._controllers) do
		if c == controller then
			table.remove(self._controllers, i)

			if self._controller == controller then
				self._controller = nil
			end

			return
		end
	end
end

function HandStateMachine:controller()
	return self._controller
end

function HandStateMachine:hand_from_connection(connection_name)
	for hand, active_states in ipairs(self._hands) do
		if active_states then
			for _, state in ipairs(active_states) do
				if state._connections then
					for name, connection in pairs(state._connections) do
						if name == connection_name and (not state:disabled(connection_name) and not connection.hand or connection.hand == hand) then
							return hand
						end
					end
				end
			end
		end
	end
end

function HandStateMachine:_apply_bindings()
	if not self._controllers or #self._controllers <= 0 then
		return
	end

	local key_map = {}

	for hand, active_states in ipairs(self._hands) do
		for _, state in ipairs(active_states) do
			state:apply(hand, key_map)
		end
	end

	local connection_map = {}

	for key_name, connection_list in pairs(key_map) do
		for _, connection_name in ipairs(connection_list) do
			connection_map[connection_name] = connection_map[connection_name] or {}

			table.insert(connection_map[connection_name], key_name)
		end
	end

	if HandStateMachine.DEBUG then
		print("[HandStateMachine] ----------------- Connection map ----------------- ")

		for connection_name, key_list in pairs(connection_map) do
			print(connection_name)

			for _, key_name in ipairs(key_list) do
				print("\t" .. key_name)
			end
		end
	end

	for _, controller in ipairs(self._controllers) do
		for connection_name, connection in pairs(controller:get_setup():get_connection_map()) do
			local new_connection = connection_map[connection_name]
			local modified_connection = self._modified_connection_list[connection_name]

			if new_connection or modified_connection then
				if new_connection then
					connection:set_input_name_list(new_connection)
					connection:set_enabled(true)
				elseif modified_connection then
					connection:set_input_name_list(self._possible_inputs[connection_name] or {})
					connection:set_enabled(false)
				end
			end
		end

		controller:rebind_connections()
	end
end
