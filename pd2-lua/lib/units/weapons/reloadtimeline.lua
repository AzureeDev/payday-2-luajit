ReloadTimeline = ReloadTimeline or class()

function ReloadTimeline:init(timeline_tweak)
	self._timeline = deep_clone(timeline_tweak)
end

local function lerp_func(a, b, t)
	assert(type(a) == type(b), "Can't lerp different types!\n" .. type(a) .. " and " .. type(b))

	if type(a) == "number" then
		return math.lerp(a, b, t)
	elseif type(a) == "userdata" then
		assert(type_name(a) == type_name(b), "Can't lerp different types!")

		local tn = type_name(a)

		if tn == "Vector3" then
			local r = Vector3()

			mvector3.lerp(r, a, b, t)

			return r
		elseif tn == "Rotation" then
			local r = Rotation()

			mrotation.slerp(r, a, b, t)

			return r
		end
	end

	assert(false, "Invalid lerp")
end

function ReloadTimeline:get_key(key, time)
	time = math.clamp(time, 0, 1)
	local before = {
		time = 0,
		[key] = tweak_data.vr.reload_timelines.default_keys[key]
	}
	local after = {
		time = 1,
		[key] = before[key]
	}

	for _, data in ipairs(self._timeline) do
		if time <= data.time then
			if data[key] ~= nil then
				after = data

				break
			end
		elseif data[key] ~= nil then
			before = data
			after[key] = data[key]
		end
	end

	local res = before[key]
	local is_event = type(res) == "string" or type(res) == "boolean" or type(res) == "table"

	if is_event then
		before[key] = nil

		return res
	elseif before[key] ~= nil and after[key] ~= nil then
		return lerp_func(res, after[key], (time - before.time) / (after.time - before.time))
	end
end

function ReloadTimeline:get_data(time)
	local data = {}

	for _, key in ipairs({
		"pos",
		"rot",
		"visible",
		"sound",
		"anims",
		"drop_mag",
		"effect"
	}) do
		data[key] = self:get_key(key, time)
	end

	return data
end
