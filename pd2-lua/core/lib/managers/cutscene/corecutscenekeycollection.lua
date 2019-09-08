CoreCutsceneKeyCollection = CoreCutsceneKeyCollection or class()

function CoreCutsceneKeyCollection:keys(element_name)
	return self:keys_between(-1, math.huge, element_name)
end

function CoreCutsceneKeyCollection:keys_between(start_time, end_time, element_name)
	if start_time == end_time then
		return function ()
		end
	end

	local keys = self:_all_keys_sorted_by_time()

	if start_time < end_time then
		local index = 0
		local count = table.getn(keys)

		return function ()
			while index < count do
				index = index + 1
				local key = keys[index]

				if key and start_time < key:time() then
					if key:time() <= end_time then
						if element_name == nil or element_name == key.ELEMENT_NAME then
							return key
						end
					else
						break
					end
				end
			end
		end
	else
		local index = table.getn(keys) + 1

		return function ()
			while index > 1 do
				index = index - 1
				local key = keys[index]

				if key and key:time() <= start_time then
					if end_time < key:time() then
						if element_name == nil or element_name == key.ELEMENT_NAME then
							return key
						end
					else
						break
					end
				end
			end
		end
	end
end

function CoreCutsceneKeyCollection:keys_to_update(time, element_name)
	local keys = self:_all_keys_sorted_by_time()
	local index = 0
	local count = table.getn(keys)

	return function ()
		while index < count do
			index = index + 1
			local key = keys[index]

			if time < key:time() then
				break
			elseif (element_name == nil or element_name == key.ELEMENT_NAME) and type(key.update) == "function" then
				return key
			end
		end
	end
end

function CoreCutsceneKeyCollection:first_key(time, element_name, properties)
	for index, key in ipairs(self:_all_keys_sorted_by_time()) do
		if time <= key:time() and (element_name == nil or element_name == key.ELEMENT_NAME) and (properties == nil or table.true_for_all(properties, function (value, attribute_name)
			return key[attribute_name](key) == value
		end)) then
			return key, index
		end
	end
end

function CoreCutsceneKeyCollection:last_key_before(time, element_name, properties)
	local last_key = nil

	for _, key in ipairs(self:_all_keys_sorted_by_time()) do
		if time <= key:time() then
			break
		end

		if (element_name == nil or element_name == key.ELEMENT_NAME) and (properties == nil or table.true_for_all(properties, function (value, attribute_name)
			return key[attribute_name](key) == value
		end)) then
			last_key = key
		end
	end

	return last_key
end
