local length_function = require("lib/utils/Bezier3Length")
local min = math.min
local max = math.max
local sqrt = math.sqrt

local function value(t, x1, x2, x3, x4)
	return (1 - t)^3 * x1 + 3 * (1 - t)^2 * t * x2 + 3 * (1 - t) * t^2 * x3 + t^3 * x4
end

local function coefficients(x1, x2, x3, x4)
	return x4 - x1 + 3 * (x2 - x3), 3 * x1 - 6 * x2 + 3 * x3, 3 * (x2 - x1), x1
end

local function value_for(t, a, b, c, d)
	return d + t * (c + t * (b + t * a))
end

local function derivative1_for(t, a, b, c)
	return c + t * (2 * b + 3 * a * t)
end

local function derivative1_roots(x1, x2, x3, x4)
	local base = -x1 * x3 + x1 * x4 + x2^2 - x2 * x3 - x2 * x4 + x3^2
	local denom = -x1 + 3 * x2 - 3 * x3 + x4

	if base > 0 and denom ~= 0 then
		local sq = sqrt(base)

		return (sq - x1 + 2 * x2 - x3) / denom, (-sq - x1 + 2 * x2 - x3) / denom
	else
		local denom = 2 * (x1 - 2 * x2 + x3)

		if denom ~= 0 then
			return (x1 - x2) / denom
		end
	end
end

local function minmax(x1, x2, x3, x4)
	local minx = min(x1, x4)
	local maxx = max(x1, x4)
	local t1, t2 = derivative1_roots(x1, x2, x3, x4)

	if t1 and t1 >= 0 and t1 <= 1 then
		local x = value(t1, x1, x2, x3, x4)
		minx = min(x, minx)
		maxx = max(x, maxx)
	end

	if t2 and t2 >= 0 and t2 <= 1 then
		local x = value(t2, x1, x2, x3, x4)
		minx = min(x, minx)
		maxx = max(x, maxx)
	end

	return minx, maxx
end

local function bounding_box(x1, y1, x2, y2, x3, y3, x4, y4)
	local minx, maxx = minmax(x1, x2, x3, x4)
	local miny, maxy = minmax(y1, y2, y3, y4)

	return minx, miny, maxx - minx, maxy - miny
end

local function to_bezier2(x1, y1, x2, y2, x3, y3, x4, y4)
	return -0.25 * x1 + 0.75 * x2 + 0.75 * x3 - 0.25 * x4, -0.25 * y1 + 0.75 * y2 + 0.75 * y3 - 0.25 * y4
end

local function point(t, x1, y1, x2, y2, x3, y3, x4, y4)
	return value(t, x1, x2, x3, x4), value(t, y1, y2, y3, y4)
end

local length = length_function(coefficients, derivative1_for)

local function split(t, x1, y1, x2, y2, x3, y3, x4, y4)
	local mt = 1 - t
	local x12 = x1 * mt + x2 * t
	local y12 = y1 * mt + y2 * t
	local x23 = x2 * mt + x3 * t
	local y23 = y2 * mt + y3 * t
	local x34 = x3 * mt + x4 * t
	local y34 = y3 * mt + y4 * t
	local x123 = x12 * mt + x23 * t
	local y123 = y12 * mt + y23 * t
	local x234 = x23 * mt + x34 * t
	local y234 = y23 * mt + y34 * t
	local x1234 = x123 * mt + x234 * t
	local y1234 = y123 * mt + y234 * t

	return x1, y1, x12, y12, x123, y123, x1234, y1234, x1234, y1234, x234, y234, x34, y34, x4, y4
end

local distance2 = require("lib/utils/Bezier3Point").distance2
local pi = math.pi
local atan2 = math.atan2
local abs = math.abs
local radians = math.rad
local curve_collinearity_epsilon = 1e-30
local curve_angle_tolerance_epsilon = 0.01
local curve_recursion_limit = 32
local recursive_bezier = nil

function interpolate(write, x1, y1, x2, y2, x3, y3, x4, y4, m_approximation_scale, m_angle_tolerance, m_cusp_limit)
	m_approximation_scale = m_approximation_scale or 1
	m_angle_tolerance = m_angle_tolerance and radians(m_angle_tolerance) or 0
	m_cusp_limit = m_cusp_limit and m_cusp_limit ~= 0 and pi - radians(m_cusp_limit) or 0
	local m_distance_tolerance2 = (1 / (2 * m_approximation_scale))^2

	recursive_bezier(write, x1, y1, x2, y2, x3, y3, x4, y4, 0, m_distance_tolerance2, m_angle_tolerance, m_cusp_limit)
	write("line", x4, y4)
end

function recursive_bezier(write, x1, y1, x2, y2, x3, y3, x4, y4, level, m_distance_tolerance2, m_angle_tolerance, m_cusp_limit)
	if curve_recursion_limit < level then
		return
	end

	local x12 = (x1 + x2) / 2
	local y12 = (y1 + y2) / 2
	local x23 = (x2 + x3) / 2
	local y23 = (y2 + y3) / 2
	local x34 = (x3 + x4) / 2
	local y34 = (y3 + y4) / 2
	local x123 = (x12 + x23) / 2
	local y123 = (y12 + y23) / 2
	local x234 = (x23 + x34) / 2
	local y234 = (y23 + y34) / 2
	local x1234 = (x123 + x234) / 2
	local y1234 = (y123 + y234) / 2
	local dx = x4 - x1
	local dy = y4 - y1
	local d2 = abs((x2 - x4) * dy - (y2 - y4) * dx)
	local d3 = abs((x3 - x4) * dy - (y3 - y4) * dx)
	local da1, da2, k = nil
	local case = (curve_collinearity_epsilon < d2 and 2 or 0) + (curve_collinearity_epsilon < d3 and 1 or 0)

	if case == 0 then
		k = dx^2 + dy^2

		if k == 0 then
			d2 = distance2(x1, y1, x2, y2)
			d3 = distance2(x4, y4, x3, y3)
		else
			k = 1 / k
			da1 = x2 - x1
			da2 = y2 - y1
			d2 = k * (da1 * dx + da2 * dy)
			da1 = x3 - x1
			da2 = y3 - y1
			d3 = k * (da1 * dx + da2 * dy)

			if d2 > 0 and d2 < 1 and d3 > 0 and d3 < 1 then
				return
			end

			if d2 <= 0 then
				d2 = distance2(x2, y2, x1, y1)
			elseif d2 >= 1 then
				d2 = distance2(x2, y2, x4, y4)
			else
				d2 = distance2(x2, y2, x1 + d2 * dx, y1 + d2 * dy)
			end

			if d3 <= 0 then
				d3 = distance2(x3, y3, x1, y1)
			elseif d3 >= 1 then
				d3 = distance2(x3, y3, x4, y4)
			else
				d3 = distance2(x3, y3, x1 + d3 * dx, y1 + d3 * dy)
			end
		end

		if d3 < d2 then
			if d2 < m_distance_tolerance2 then
				write("line", x2, y2)

				return
			end
		elseif d3 < m_distance_tolerance2 then
			write("line", x3, y3)

			return
		end
	elseif case == 1 then
		if d3^2 <= m_distance_tolerance2 * (dx^2 + dy^2) then
			if m_angle_tolerance < curve_angle_tolerance_epsilon then
				write("line", x23, y23)

				return
			end

			da1 = abs(atan2(y4 - y3, x4 - x3) - atan2(y3 - y2, x3 - x2))

			if pi <= da1 then
				da1 = 2 * pi - da1
			end

			if m_angle_tolerance > da1 then
				write("line", x2, y2)
				write("line", x3, y3)

				return
			end

			if m_cusp_limit ~= 0 and m_cusp_limit < da1 then
				write("line", x3, y3)

				return
			end
		end
	elseif case == 2 then
		if d2^2 <= m_distance_tolerance2 * (dx^2 + dy^2) then
			if m_angle_tolerance < curve_angle_tolerance_epsilon then
				write("line", x23, y23)

				return
			end

			da1 = abs(atan2(y3 - y2, x3 - x2) - atan2(y2 - y1, x2 - x1))

			if pi <= da1 then
				da1 = 2 * pi - da1
			end

			if m_angle_tolerance > da1 then
				write("line", x2, y2)
				write("line", x3, y3)

				return
			end

			if m_cusp_limit ~= 0 and m_cusp_limit < da1 then
				write("line", x2, y2)

				return
			end
		end
	elseif case == 3 and (d2 + d3)^2 <= m_distance_tolerance2 * (dx^2 + dy^2) then
		if m_angle_tolerance < curve_angle_tolerance_epsilon then
			write("line", x23, y23)

			return
		end

		k = atan2(y3 - y2, x3 - x2)
		da1 = abs(k - atan2(y2 - y1, x2 - x1))
		da2 = abs(atan2(y4 - y3, x4 - x3) - k)

		if pi <= da1 then
			da1 = 2 * pi - da1
		end

		if pi <= da2 then
			da2 = 2 * pi - da2
		end

		if m_angle_tolerance > da1 + da2 then
			write("line", x23, y23)

			return
		end

		if m_cusp_limit ~= 0 then
			if m_cusp_limit < da1 then
				write("line", x2, y2)

				return
			end

			if m_cusp_limit < da2 then
				write("line", x3, y3)

				return
			end
		end
	end

	recursive_bezier(write, x1, y1, x12, y12, x123, y123, x1234, y1234, level + 1, m_distance_tolerance2, m_angle_tolerance, m_cusp_limit)
	recursive_bezier(write, x1234, y1234, x234, y234, x34, y34, x4, y4, level + 1, m_distance_tolerance2, m_angle_tolerance, m_cusp_limit)
end

return {
	bounding_box = bounding_box,
	to_bezier2 = to_bezier2,
	interpolate = interpolate,
	point = point,
	length = length,
	split = split
}
