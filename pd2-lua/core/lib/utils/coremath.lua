if core then
	core:module("CoreMath")
	core:import("CoreClass")
end

nice = math.nice

function rgb_to_hsv(r, g, b)
	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local hue = 0

	if max == min then
		hue = 0
	elseif max == r and b <= g then
		hue = 60 * (g - b) / (max - min)
	elseif max == r and g < b then
		hue = 60 * (g - b) / (max - min) + 360
	elseif max == g then
		hue = 60 * (b - r) / (max - min) + 120
	elseif max == b then
		hue = 60 * (r - g) / (max - min) + 240
	end

	hue = math.fmod(hue, 360)
	local saturation = max == 0 and 0 or 1 - min / max
	local value = max

	return hue, saturation, value
end

function hsv_to_rgb(h, s, v)
	local c = math.floor(h / 60)
	local f = h / 60 - c
	local p = v * (1 - s)
	local q = v * (1 - f * s)
	local t = v * (1 - (1 - f) * s)
	local cases = {
		[0] = {
			v,
			t,
			p
		},
		{
			q,
			v,
			p
		},
		{
			p,
			v,
			t
		},
		{
			p,
			q,
			v
		},
		{
			t,
			p,
			v
		},
		{
			v,
			p,
			q
		}
	}

	return unpack(cases[math.fmod(c, 6)])
end

function string_to_value(type, value)
	if type == "number" then
		return tonumber(value)
	elseif type == "boolean" then
		return toboolean(value)
	elseif type == "Vector3" then
		return math.string_to_vector(value)
	elseif type == "Rotation" then
		return math.string_to_rotation(value)
	elseif type == "table" then
		return {}
	elseif type == "nil" then
		return nil
	end

	return value
end

function vector_to_string(v, f)
	if f then
		local x = string.format(f, v.x)
		local y = string.format(f, v.y)
		local z = string.format(f, v.z)

		return x .. " " .. y .. " " .. z
	end

	return v.x .. " " .. v.y .. " " .. v.z
end

function rotation_to_string(r, f)
	if f then
		local x = string.format(f, r:yaw())
		local y = string.format(f, r:pitch())
		local z = string.format(f, r:roll())

		return x .. " " .. y .. " " .. z
	end

	return r:yaw() .. " " .. r:pitch() .. " " .. r:roll()
end

function width_mul(aspect_ratio)
	return 0.75 * aspect_ratio
end

function wire_set_midpoint(unit, source, target, middle)
	local s_pos = unit:get_object(source):position()
	local e_pos = unit:get_object(target):position()
	local n = (e_pos - s_pos):normalized():cross(Vector3(0, 0, 1))
	local dir = (e_pos - s_pos):normalized():cross(n)
	local m_point = s_pos + (e_pos - s_pos) * 0.5

	unit:get_object(middle):set_position(m_point + dir * unit:wire_data().slack)

	local co = unit:get_object(Idstring("co_cable"))

	if co then
		co:set_rotation(Rotation:look_at((e_pos - s_pos):normalized(), math.UP))
	end
end

function probability(chance_table, result_table)
	local random = math.random(100)
	local total_chance = 0
	local choice = #chance_table

	for id, chance in ipairs(chance_table) do
		total_chance = total_chance + chance

		if random <= total_chance then
			choice = id

			break
		end
	end

	if result_table then
		return result_table[choice]
	end

	return choice
end

function get_fit_size(width, height, bounding_width, bounding_height)
	local bounding_aspect = bounding_width / bounding_height
	local aspect = width / height

	if bounding_aspect >= aspect then
		return bounding_width * aspect / bounding_aspect, bounding_height
	else
		return bounding_width, bounding_height * bounding_aspect / aspect
	end
end

function os.get_oldest_date(date1, date2)
	if date2.year < date1.year then
		return date1
	elseif date1.year < date2.year then
		return date2
	elseif date2.yday < date1.yday then
		return date1
	elseif date1.yday < date2.yday then
		return date2
	elseif date2.hour < date1.hour then
		return date1
	elseif date1.hour < date2.hour then
		return date2
	elseif date2.min < date1.min then
		return date1
	elseif date1.min < date2.min then
		return date2
	elseif date2.sec < date1.sec then
		return date1
	elseif date1.sec < date2.sec then
		return date2
	else
		return nil
	end
end

math.UP = Vector3(0, 0, 1)
math.DOWN = Vector3(0, 0, -1)
math.Z = math.UP
math.X = Vector3(1, 0, 0)
math.Y = Vector3(0, 1, 0)

function math.rand(a, b)
	if b then
		return math.random() * (b - a) + a
	else
		return math.random() * a
	end
end

function math.round(n, precision)
	precision = precision or 1

	return math.floor((n + precision / 2) / precision) * precision
end

function math.min_max(a, b)
	if a < b then
		return a, b
	else
		return b, a
	end
end

function math.vector_min_max(a, b)
	local min_x, max_x = math.min_max(a.x, b.x)
	local min_y, max_y = math.min_max(a.y, b.y)
	local min_z, max_z = math.min_max(a.z, b.z)
	local min_vector = Vector3(min_x, min_y, min_z)
	local max_vector = Vector3(max_x, max_y, max_z)

	return min_vector, max_vector
end

function math.vector_clamp(vector, min, max)
	if CoreClass.type_name(min) ~= "Vector3" then
		min = Vector3(min, min, min)
	end

	if CoreClass.type_name(max) ~= "Vector3" then
		max = Vector3(max, max, max)
	end

	return Vector3(math.clamp(vector.x, min.x, max.x), math.clamp(vector.y, min.y, max.y), math.clamp(vector.z, min.z, max.z))
end

function math.lerp(a, b, t)
	return a * (1 - t) + b * t
end

function math.string_to_rotation(v)
	local r = math.string_to_vector(v)

	return Rotation(r.x, r.y, r.z)
end

function math.vector_to_string(v)
	return tostring(v.x) .. " " .. tostring(v.y) .. " " .. tostring(v.z)
end

function math.spline(points, t)
	local mu = t * t
	local a0 = points[4] - points[3] - points[1] + points[2]
	local a1 = points[1] - points[2] - a0
	local a2 = points[3] - points[1]
	local a3 = points[2]

	return a0 * t * mu + a1 * mu + a2 * t + a3
end

function math.spline_len(points, n)
	local len = 0
	local old_p = points[1]

	for i = 1, n, 1 do
		local p = math.spline(points, i / n)
		len = len + (p - old_p):length()
		old_p = p
	end

	return len
end

function math.bezier(points, t)
	local p1 = points[1]
	local p2 = points[2]
	local p3 = points[3]
	local p4 = points[4]
	local t_squared = t * t
	local t_cubed = t_squared * t
	local a1 = p1 * (1 - t) * (1 - t) * (1 - t)
	local a2 = 3 * p2 * t * (1 - t) * (1 - t)
	local a3 = 3 * p3 * t_squared * (1 - t)
	local a4 = p4 * t_cubed

	return a1 + a2 + a3 + a4
end

function math.linear_bezier(points, t)
	local p1 = points[1]
	local p2 = points[2]

	return p1 * (1 - t) + p2 * t
end

function math.quadratic_bezier(points, t)
	local p1 = points[1]
	local p2 = points[2]
	local p3 = points[3]

	return p1 * (1 - t) * (1 - t) + p2 * 2 * t * (1 - t) + p3 * t * t
end

function math.bezier_len(points, n)
	local len = 0
	local old_p = points[1]

	for i = 1, n, 1 do
		local p = math.bezier(points, i / n)
		len = len + (p - old_p):length()
		old_p = p
	end

	return len
end

function math.point_on_line(l1, l2, p)
	local u = (p.x - l1.x) * (l2.x - l1.x) + (p.y - l1.y) * (l2.y - l1.y) + (p.z - l1.z) * (l2.z - l1.z)
	local u = math.clamp(u / math.pow((l2 - l1):length(), 2), 0, 1)
	local x = l1.x + u * (l2.x - l1.x)
	local y = l1.y + u * (l2.y - l1.y)
	local z = l1.z + u * (l2.z - l1.z)

	return Vector3(x, y, z)
end

function math.distance_to_line(l1, l2, p)
	local closest_point = math.point_on_line(l1, l2, p)

	return (closest_point - p):length(), closest_point
end

function math.limitangle(angle)
	local newangle = math.fmod(angle, 360)

	if newangle < 0 then
		newangle = newangle + 360
	end

	return newangle
end

function math.world_to_obj(obj, point)
	if obj == nil then
		return point
	end

	local vec = point - obj:position()

	return vec:rotate_with(obj:rotation():inverse())
end

function math.obj_to_world(obj, point)
	if obj == nil then
		return point
	end

	local vec = point:rotate_with(obj:rotation())

	return vec + obj:position()
end

function math.within(x, min, max)
	return min <= x and x <= max
end
