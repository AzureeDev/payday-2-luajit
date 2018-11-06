CoreSky = CoreSky or class()

function CoreSky:init()
	self._params = {}
	self._name = "default"
end

function CoreSky:set_name(name)
	self._name = name
end

function CoreSky:set_value(key, value)
	self._params[key] = value
end

function CoreSky:value(key)
	return self._params[key]
end

function CoreSky:parse(xml_node)
	self._params = {}

	for child in xml_node:children() do
		local key = child:parameter("key")
		local value = child:parameter("value")

		if child:name() == "param" and key and key ~= "" and value and value ~= "" then
			if math.string_is_good_vector(value) then
				self._params[key] = math.string_to_vector(value)
			elseif tonumber(value) then
				self._params[key] = tonumber(value)
			elseif string.sub(value, 1, 1) == "#" then
				self._params[key] = self:database_lookup(string.sub(value, 2))
			else
				self._params[key] = tostring(value)
			end
		end
	end
end

function CoreSky:copy(from)
	for key, value in pairs(from._params) do
		if type(value) == "string" then
			self._params[key] = value
		elseif type(value) ~= "number" then
			self._params[key] = Vector3(value.x, value.y, value.z)
		else
			self._params[key] = value
		end
	end

	self._name = from._name
end

function CoreSky:interpolate(target, with, scale)
	local invscale = 1 - scale

	for key, value in pairs(with._params) do
		if not target._params[key] then
			return
		elseif type(value) ~= "string" then
			self._params[key] = target._params[key] * invscale + value * scale
		else
			self._params[key] = value
		end
	end

	self._name = with._name
end

function CoreSky:database_lookup(str)
	local i = string.find(str, "#")
	local db_key = string.sub(str, 1, i - 1)
	local value_key = string.sub(str, i + 1)

	assert(db_key == "LightIntensityDB")

	local value = LightIntensityDB:lookup(value_key)

	assert(value)

	return value
end
