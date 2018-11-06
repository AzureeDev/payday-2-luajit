HandState = HandState or class()

function HandState:init(level)
	self._level = level or 0
end

function HandState:level()
	return self._level
end

function HandState:connnection_names()
	local names = {}

	if not self._connections then
		return names
	end

	for name, _ in pairs(self._connections) do
		table.insert(names, name)
	end

	return names
end

function HandState:disabled(connection_name)
	return self._disabled_connections and table.contains(self._disabled_connections, connection_name)
end

function HandState:apply(hand, key_map)
	if not self._connections then
		return
	end

	local hand_name = hand == 1 and "r" or "l"
	local key_set = {}
	self._disabled_connections = {}

	for connection_name, connection_data in pairs(self._connections) do
		if connection_data.hand == hand or not connection_data.hand then
			local condition = not connection_data.condition or connection_data.condition and connection_data:condition(hand, key_map, connection_name)

			if condition then
				local inputs = connection_data.inputs

				if type(inputs) == "function" then
					inputs = inputs(hand, key_map)
				end

				if connection_data.exclusive or condition == "exclusive" then
					for key, connections in pairs(key_map) do
						table.remove_condition(connections, function (name)
							return name == connection_name
						end)
						table.insert(self._disabled_connections, connection_name)
					end
				end

				for _, input in ipairs(inputs) do
					local input_name = input .. hand_name

					if not key_set[input_name] then
						key_map[input .. hand_name] = {}
						key_set[input .. hand_name] = true
					end

					table.insert(key_map[input .. hand_name], connection_name)
				end
			else
				table.insert(self._disabled_connections, connection_name)
			end
		end
	end
end
