CoreCutsceneUnitCallback = CoreCutsceneUnitCallback or class()

function CoreCutsceneUnitCallback:init(callback_name)
	self._callback_name = callback_name
	self._params = {}
end

function CoreCutsceneUnitCallback:add_parameter(param)
	self._params[param._name] = param
end

function CoreCutsceneUnitCallback:get_parameter_map()
	return self._params
end

CoreCutsceneInputParam = CoreCutsceneInputParam or class()

function CoreCutsceneInputParam:init(name, value_type, default_value, min_value, max_value, decimals)
	self._name = name
	self._value_type = value_type
	self._default_value = default_value
	self._min_value = min_value
	self._max_value = max_value
	self._decimals = decimals
end

function CoreCutsceneInputParam:float_to_string(number, decimals)
	if type(number) == "boolean" then
		return tostring(number)
	elseif decimals then
		return string.format("%." .. decimals .. "f", number or 0)
	else
		return string.format("%f", number or 0)
	end
end

function CoreCutsceneInputParam:validate(value)
	if self._value_type == "number" then
		value = self:float_to_string(self:validate_number(self._value_type, value, self._min_value, self._max_value, self._default_value, self._decimals), self._decimals)
	elseif self._value_type == "boolean" then
		value = self:validate_boolean(value)
	end

	return value
end

function CoreCutsceneInputParam:validate_number(number, min_value, max_value, default_value, decimals)
	if type(number) == "string" then
		local stripped_number = ""

		if string.sub(number, 1, 1) == "." then
			number = "0" .. number
		end

		for digit in string.gmatch(number, "(%d+%.?%d?)") do
			stripped_number = stripped_number .. digit
		end

		number = tonumber(stripped_number)
	end

	if number == nil then
		number = default_value
	end

	if self._decimals ~= nil then
		local round_helper = 10^self._decimals
		number = math.round(number * round_helper)
		number = number == 0 and 0 or number / round_helper
	end

	if min_value ~= nil and number < min_value then
		number = min_value
	elseif max_value ~= nil and max_value < number then
		number = max_value
	end

	return number
end

function CoreCutsceneInputParam:validate_boolean(boolean)
	if type(boolean) == "string" then
		return boolean == "true"
	else
		return boolean
	end
end
