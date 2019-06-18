BaseMutator = BaseMutator or class()
BaseMutator._type = "BaseMutator"
BaseMutator.name_id = ""
BaseMutator.desc_id = ""
BaseMutator.has_options = false
BaseMutator.categories = {}
BaseMutator.incompatiblities = {}
BaseMutator.incompatibility_tags = {}
BaseMutator.icon_coords = {
	1,
	1
}
BaseMutator.load_priority = 0
BaseMutator.reductions = {
	money = 0,
	exp = 0
}
BaseMutator.disables_achievements = true

function BaseMutator:init(mutator_manager)
	self._enabled = false
	self._values = {}

	self:register_values()

	local mutator_data = Global.mutators and Global.mutators.mutator_values and Global.mutators.mutator_values[self:id()]

	if mutator_data then
		for key, value in pairs(mutator_data.values) do
			self:set_value(key, value)
		end

		self._enabled = mutator_data.enabled
	end
end

function BaseMutator:register_values(mutator_manager)
end

function BaseMutator:setup(mutator_manager)
end

function BaseMutator:_ensure_global_values()
	Global.mutators.mutator_values[self:id()] = Global.mutators.mutator_values[self:id()] or {
		values = {},
		enabled = self._enabled
	}
end

function BaseMutator:id()
	return self._type
end

function BaseMutator:name()
	return managers.localization:text(self.name_id)
end

function BaseMutator:desc()
	return managers.localization:text(self.desc_id)
end

function BaseMutator:longdesc()
	if not self.longdesc_id then
		self.longdesc_id = string.gsub(self.desc_id, "_desc", "_longdesc")
	end

	return managers.localization:text(self.longdesc_id)
end

function BaseMutator:icon()
	local x = self.icon_coords[1]
	local y = self.icon_coords[2]
	local size = MutatorsManager._icon_size

	return MutatorsManager._atlas_file, {
		size * (x - 1),
		size * (y - 1),
		size,
		size
	}
end

function BaseMutator:is_compatible_with(mutator)
	for i, mutator_id in ipairs(self.incompatiblities) do
		if mutator:id() == mutator_id then
			return false
		end
	end

	for i, tag in ipairs(self.incompatibility_tags) do
		if table.contains(mutator.incompatibility_tags, tag) then
			return false
		end
	end

	return true
end

function BaseMutator:is_incompatible_with(mutator)
	return not self:is_compatible_with(mutator) or not mutator:is_compatible_with(self)
end

function BaseMutator:is_enabled()
	return self._enabled
end

function BaseMutator:set_enabled(enable)
	self._enabled = enable

	self:_ensure_global_values()

	Global.mutators.mutator_values[self:id()].enabled = enable
end

function BaseMutator:is_active()
	if managers.mutators then
		for i, active_mutator in ipairs(managers.mutators:active_mutators()) do
			if active_mutator.mutator and active_mutator.mutator:id() == self:id() then
				return true
			end
		end
	end

	return false
end

function BaseMutator:get_cash_reduction()
	return self.reductions.money
end

function BaseMutator:get_experience_reduction()
	return self.reductions.exp
end

function BaseMutator:update(t, dt)
end

function BaseMutator:_mutate_name(key)
	if Global.game_settings.single_player then
		return self:is_enabled() and self:value(key)
	elseif Network:is_server() then
		return self:is_enabled() and self:value(key)
	elseif Network:is_client() then
		return self:value(key)
	elseif managers.mutators:crimenet_lobby_data() then
		return self:value(key)
	else
		return self:is_enabled() and self:value(key)
	end
end

function BaseMutator:show_options()
	return self.has_options
end

function BaseMutator:setup_options_gui(node)
	local params = {
		name = "default_item",
		localize = false,
		text_id = "No options!",
		align = "right",
		disabled_color = tweak_data.screen_colors.important_1
	}
	local data_node = {}
	local new_item = node:create_item(data_node, params)

	node:add_item(new_item)

	return new_item
end

function BaseMutator:reset_to_default()
end

function BaseMutator:options_fill()
	return 0
end

function BaseMutator:_get_percentage_fill(min, max, current)
	return math.clamp(((current or 0) - min) / (max - min), 0, 1)
end

function BaseMutator:clear_values()
	for id, data in pairs(self._values) do
		data.current = data.default
	end
end

function BaseMutator:values()
	return self._values
end

function BaseMutator:register_value(key, default, network_key)
	if not network_key then
		network_key = key
		local splits = string.split(key, "[_]")

		if splits then
			network_key = ""

			for _, str in ipairs(splits) do
				network_key = network_key .. tostring(str[1])
			end
		end
	end

	self._values[key] = {
		current = default,
		default = default,
		network_key = network_key
	}
end

function BaseMutator:set_value(id, value)
	if not self._values[id] then
		Application:error(string.format("Can not set a value for a key that has not been registered! %s: %s", self:id(), id))

		return
	end

	self._values[id].current = value

	self:_ensure_global_values()

	Global.mutators.mutator_values[self:id()].values[id] = value
end

function BaseMutator:set_host_value(id, value)
	if not self._values[id] then
		Application:error(string.format("Can not set a value for a key that has not been registered! %s: %s", self:id(), id))

		return
	end

	self._values[id].host = value
end

function BaseMutator:value(id)
	if not self._values[id] then
		Application:error(string.format("Can not get a value for a key that has not been registered! %s: %s", self:id(), id))

		return nil
	end

	local value = self:_get_value(self._values, id)
	local ret_value = value.current

	if Network:is_client() then
		self:_apply_host_values(managers.mutators:get_mutators_from_lobby_data())

		ret_value = value.host == nil and value.client or value.host
	end

	if managers.mutators:crimenet_lobby_data() then
		self:_apply_host_values(managers.mutators:crimenet_lobby_data())

		ret_value = value.host == nil and value.client or value.host
	end

	if ret_value == nil then
		ret_value = value.default
	end

	return ret_value
end

function BaseMutator:_get_value(table, id, default)
	local value = table[id]

	if value == nil then
		value = default
	end

	return value
end

function BaseMutator:_apply_host_values(host_mutators)
	if host_mutators and host_mutators[self:id()] then
		for key, value in pairs(host_mutators[self:id()]) do
			self:set_host_value(key, value)
		end
	end
end

function BaseMutator:build_matchmaking_key()
	local matchmaking_key = string.format("%s ", self:id())

	if table.size(self:values()) > 0 then
		for key, data in pairs(self:values()) do
			local value = data.current

			if type(value) == "number" then
				matchmaking_key = matchmaking_key .. string.format("%s %.4f ", data.network_key, value)
			else
				matchmaking_key = matchmaking_key .. string.format("%s %s ", data.network_key, tostring(value))
			end
		end
	end

	return matchmaking_key
end

function BaseMutator:build_compressed_data(id)
	local matchmaking_key = string.format("%c", string.byte("a") + id)

	for key, data in pairs(self:values()) do
		local value = data.current
		matchmaking_key = type(value) == "number" and matchmaking_key .. string.format("%.2f ", value) or type(value) == "boolean" and matchmaking_key .. string.format("%d ", value and 1 or 0) or matchmaking_key .. string.format("%s ", tostring(value))
	end

	return matchmaking_key
end

function BaseMutator:uncompress_data(str_dat)
	local ret = {}

	for key, data in pairs(self:values()) do
		local default = data.default
		local idx = string.find(str_dat, " ", 1, true)

		if idx == nil then
			return nil, ""
		end

		local new_value = string.sub(str_dat, 1, idx)
		str_dat = string.sub(str_dat, idx + 1)

		if type(default) == "number" then
			local number = tonumber(new_value)

			if number == nil then
				ret[key] = default
			else
				ret[key] = number
			end
		elseif type(default) == "boolean" then
			ret[key] = tonumber(new_value) == 1
		else
			ret[key] = new_value
		end
	end

	return ret, str_dat
end

function BaseMutator:partial_uncompress_data(str_dat)
	local ret = string.format("%s ", self:id())

	for key, data in pairs(self:values()) do

		-- Decompilation error in this vicinity:
		--- BLOCK #0 14-23, warpins: 1 ---
		local default = data.default
		local idx = string.find(str_dat, " ", 1, true)

		if idx == nil then

			-- Decompilation error in this vicinity:
			--- BLOCK #1 24-26, warpins: 1 ---
			return nil, ""
			--- END OF BLOCK #1 ---



		end

		--- END OF BLOCK #0 ---

		FLOW; TARGET BLOCK #2



		-- Decompilation error in this vicinity:
		--- BLOCK #1 24-26, warpins: 1 ---
		return nil, ""

		--- END OF BLOCK #1 ---




		-- Decompilation error in this vicinity:
		--- BLOCK #2 27-43, warpins: 2 ---
		local new_value = string.sub(str_dat, 1, idx)
		str_dat = string.sub(str_dat, idx + 1)

		--- END OF BLOCK #2 ---

		if type(default)

		 == "number" then
		JUMP TO BLOCK #3
		else
		JUMP TO BLOCK #6
		end



		-- Decompilation error in this vicinity:
		--- BLOCK #3 100-101, warpins: 5 ---
		local number = tonumber(new_value)
		ret = number == nil and ret .. string.format("%s %.4f ", data.network_key, default) or ret .. string.format("%s %.4f ", data.network_key, number) or type(default) == "boolean" and ret .. string.format("%s %s ", data.network_key, tostring(tonumber(new_value) == 1)) or ret .. string.format("%s %s ", data.network_key, tostring(new_value))
		--- END OF BLOCK #3 ---



	end

	return ret, str_dat
end

function BaseMutator:get_data_from_attribute_string(string_table)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-4, warpins: 1 ---
	--- END OF BLOCK #0 ---

	if #string_table > 0 then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #3
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 5-8, warpins: 1 ---
	--- END OF BLOCK #1 ---

	if #string_table % 2 ~= 0 then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #3
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 9-23, warpins: 1 ---
	Application:error("Warning! Mismatched attribute string table, should have an even amount of elements!", self:id())
	print(inspect(string_table))

	return nil

	--- END OF BLOCK #2 ---

	FLOW; TARGET BLOCK #3



	-- Decompilation error in this vicinity:
	--- BLOCK #3 24-28, warpins: 3 ---
	local data = {}

	--- END OF BLOCK #3 ---

	FLOW; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #4 29-67, warpins: 0 ---
	for i = 1, #string_table, 2 do

		-- Decompilation error in this vicinity:
		--- BLOCK #0 29-38, warpins: 2 ---
		local key = string_table[i]
		local value = string.trim(string_table[i + 1])

		--- END OF BLOCK #0 ---

		FLOW; TARGET BLOCK #1



		-- Decompilation error in this vicinity:
		--- BLOCK #1 39-45, warpins: 0 ---
		for id, data in pairs(self._values) do

			-- Decompilation error in this vicinity:
			--- BLOCK #0 39-41, warpins: 1 ---
			--- END OF BLOCK #0 ---

			if key == data.network_key then
			JUMP TO BLOCK #1
			else
			JUMP TO BLOCK #3
			end



			-- Decompilation error in this vicinity:
			--- BLOCK #1 42-43, warpins: 1 ---
			key = id

			--- END OF BLOCK #1 ---

			FLOW; TARGET BLOCK #2



			-- Decompilation error in this vicinity:
			--- BLOCK #2 44-44, warpins: 1 ---
			break
			--- END OF BLOCK #2 ---

			FLOW; TARGET BLOCK #3



			-- Decompilation error in this vicinity:
			--- BLOCK #3 44-45, warpins: 2 ---
			--- END OF BLOCK #3 ---



		end

		--- END OF BLOCK #1 ---

		FLOW; TARGET BLOCK #2



		-- Decompilation error in this vicinity:
		--- BLOCK #2 46-47, warpins: 2 ---
		--- END OF BLOCK #2 ---

		if value ~= "true" then
		JUMP TO BLOCK #3
		else
		JUMP TO BLOCK #4
		end



		-- Decompilation error in this vicinity:
		--- BLOCK #3 48-49, warpins: 1 ---
		--- END OF BLOCK #3 ---

		if value == "false" then
		JUMP TO BLOCK #4
		else
		JUMP TO BLOCK #5
		end



		-- Decompilation error in this vicinity:
		--- BLOCK #4 50-55, warpins: 2 ---
		data[key] = toboolean(string_table[i + 1])
		--- END OF BLOCK #4 ---

		UNCONDITIONAL JUMP; TARGET BLOCK #8



		-- Decompilation error in this vicinity:
		--- BLOCK #5 56-61, warpins: 1 ---
		local number = tonumber(string_table[i + 1])
		--- END OF BLOCK #5 ---

		if number == nil then
		JUMP TO BLOCK #6
		else
		JUMP TO BLOCK #7
		end



		-- Decompilation error in this vicinity:
		--- BLOCK #6 62-65, warpins: 1 ---
		data[key] = string_table[i + 1]
		--- END OF BLOCK #6 ---

		UNCONDITIONAL JUMP; TARGET BLOCK #8



		-- Decompilation error in this vicinity:
		--- BLOCK #7 66-66, warpins: 1 ---
		data[key] = number
		--- END OF BLOCK #7 ---

		FLOW; TARGET BLOCK #8



		-- Decompilation error in this vicinity:
		--- BLOCK #8 67-67, warpins: 3 ---
		--- END OF BLOCK #8 ---



	end

	--- END OF BLOCK #4 ---

	FLOW; TARGET BLOCK #5



	-- Decompilation error in this vicinity:
	--- BLOCK #5 68-68, warpins: 1 ---
	return data
	--- END OF BLOCK #5 ---



end

function BaseMutator:modify_character_tweak_data(character_tweak)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-1, warpins: 1 ---
	return
	--- END OF BLOCK #0 ---



end

function BaseMutator:modify_tweak_data(id, value)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-1, warpins: 1 ---
	return
	--- END OF BLOCK #0 ---



end

function BaseMutator:modify_value(id, value)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-1, warpins: 1 ---
	return value
	--- END OF BLOCK #0 ---



end
