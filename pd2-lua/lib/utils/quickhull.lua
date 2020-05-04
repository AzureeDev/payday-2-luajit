local TEST_DURATION = 5
Quickhull = Quickhull or class()
Quickhull._points = {}
Quickhull._final_points = {}

function Quickhull:init(points)
	self._points = points

	self:clear()
end

function Quickhull:clear()
	self._final_points = {}
end

function Quickhull:hull()
	return self._final_points
end

function Quickhull:compute()
	self:clear()

	local initial_line = self:get_initial_line(self._points)

	table.insert(self._final_points, initial_line[1])
	table.insert(self._final_points, initial_line[2])

	local above, below = self:divide_point_cloud(self._points, initial_line)

	self:process_hull(above, initial_line, true)
	self:process_hull(below, initial_line, false)
	self:sort()

	return self._final_points
end

function Quickhull:sort()
	local centre_point = Vector3()

	for _, point in pairs(self._final_points) do
		centre_point = centre_point + point
	end

	centre_point = centre_point / #self._final_points

	table.sort(self._final_points, function (a, b)
		if a.x - centre_point.x >= 0 and b.x - centre_point.x < 0 then
			return true
		elseif a.x - centre_point.x < 0 and b.x - centre_point.x >= 0 then
			return false
		elseif a.x - centre_point.x == 0 and b.x - centre_point.x == 0 then
			if a.y - centre_point.y >= 0 or b.y - centre_point.y >= 0 then
				return b.y < a.y
			else
				return a.y < b.y
			end
		end

		local det = (a.x - centre_point.x) * (b.y - centre_point.y) - (b.x - centre_point.x) * (a.y - centre_point.y)

		if det < 0 then
			return true
		elseif det > 0 then
			return false
		end

		local ax = a.x - centre_point.x
		local ay = a.y - centre_point.y
		local az = a.z - centre_point.z
		local alen = ax * ax + ay * ay + az * az
		local bx = b.x - centre_point.x
		local by = b.y - centre_point.y
		local bz = b.z - centre_point.z
		local blen = bx * bx + by * by + bz * bz

		return alen > blen
	end)
end

function Quickhull:get_initial_line(points)
	local line = {}

	for _, point in ipairs(points) do
		if not line[1] or point.x < line[1].x then
			line[1] = point
		end

		if not line[2] or line[2].x < point.x then
			line[2] = point
		end
	end

	return line
end

function Quickhull:divide_point_cloud(points, dividing_line)
	local above = {}
	local below = {}
	local r = nil

	for _, point in ipairs(points) do
		r = self:position_relative_to_line(dividing_line, point)

		if r > 0 then
			table.insert(above, point)
		else
			table.insert(below, point)
		end
	end

	return above, below
end

function Quickhull:process_hull(points, dividing_line, winding)
	if #points < 1 then
		return
	end

	local new_points = {}
	local point = self:get_furthest_point(points, dividing_line)

	table.delete(points, point)
	table.delete(points, dividing_line[1])
	table.delete(points, dividing_line[2])
	table.insert(self._final_points, point)

	local ap_line = {
		dividing_line[1],
		point
	}
	local ap_above, ap_below = self:divide_point_cloud(points, ap_line)
	local pb_line = {
		point,
		dividing_line[2]
	}
	local pb_above, pb_below = self:divide_point_cloud(points, pb_line)

	if winding then
		self:process_hull(ap_above, ap_line, winding)
		self:process_hull(pb_above, pb_line, winding)
	else
		self:process_hull(ap_below, ap_line, winding)
		self:process_hull(pb_below, pb_line, winding)
	end
end

function Quickhull:shrink(points)
	local i = 2

	repeat
		local line = {
			self._final_points[i - 1],
			self._final_points[i]
		}

		self:shrink_segment(points, line)

		i = i + 1
	until i >= #self._final_points - 1

	local line = {
		self._final_points[1],
		self._final_points[#self._final_points]
	}

	self:shrink_segment(points, line)
end

function Quickhull:shrink_segment(points, line)
	local shrink_factor = 2
	local length = (line[2] - line[1]):length()
	local dist_factor = length * shrink_factor
	local points = self:get_points_within_distance_to_line(points, line, 500)
	local added = 0

	for _, point in ipairs(points) do
		local ang1 = (line[2] - line[1]):angle(point - line[1])
		local ang2 = (line[2] - line[1]):angle(point - line[2])

		if ang1 < 30 and ang2 < 30 then
			table.insert(self._additional_points, point)
		end
	end
end

function Quickhull:position_relative_to_line(line, point)
	local min = line[1]
	local max = line[2]
	local res = (max.x - min.x) * (point.y - min.y) - (max.y - min.y) * (point.x - min.x)

	return math.sign(res)
end

function Quickhull:get_furthest_point(points, dividing_line)
	local max_dist, max_point = nil

	for _, point in pairs(points) do
		local dist = self:distance_to_line(point, dividing_line)

		if max_dist == nil or max_dist < dist then
			max_dist = dist
			max_point = point
		end
	end

	return max_point
end

function Quickhull:get_points_within_distance_to_line(points, dividing_line, distance)
	local ps = {}

	for _, point in pairs(points) do
		local dist = self:distance_to_line(point, dividing_line)

		if dist < distance then
			table.insert(ps, point)
		end
	end

	return ps
end

function Quickhull:distance_to_line(point, line)
	local dist = self:_distance_to_segment_sqr(point, line[1], line[2])

	return math.sqrt(dist)
end

function Quickhull:_distance_to_segment_sqr(point, a, b)
	local l = self:_dist(a, b)

	if l == 0 then
		return self:_dist(point, a)
	end

	local tx = (point.x - a.x) * (b.x - a.x)
	local ty = (point.y - a.y) * (b.y - a.y)
	local tz = (point.z - a.z) * (b.z - a.z)
	local t = (tx + ty + tz) / l
	t = math.clamp(t, 0, 1)
	local _x = a.x + t * (b.x - a.x)
	local _y = a.y + t * (b.y - a.y)
	local _z = a.z + t * (b.z - a.z)
	local r = self:_dist(point, Vector3(_x, _y, _z))

	return r
end

function Quickhull:_dist(a, b)
	return math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2) + math.pow(a.z - b.z, 2)
end

function Quickhull.test()
	local extent = 500
	local extent_z = 0
	local points = {}

	for i = 1, 64 do
		table.insert(points, Vector3(math.random(-extent, extent), math.random(-extent, extent), math.random(-extent_z, extent_z)))
	end

	local brush = Draw:brush(Color(1, 1, 1, 0), TEST_DURATION)

	for k, v in ipairs(points) do
		brush:sphere(v, 10, 2)
	end

	local hull = Quickhull:new(points)
	local final_points = hull:compute()
	local brush = Draw:brush(Color(1, 1, 0, 1), TEST_DURATION)

	for i = 1, #final_points - 1 do
		brush:line(final_points[i], final_points[i + 1], 8)
	end

	brush:line(final_points[1], final_points[#final_points], 8)
end
