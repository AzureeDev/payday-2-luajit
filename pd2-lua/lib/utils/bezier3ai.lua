local bezier3 = require("lib/utils/Bezier3")
local distance2 = require("lib/utils/Bezier3Point").distance2
local pi = math.pi
local atan2 = math.atan2
local abs = math.abs
local radians = math.rad
local curve_collinearity_epsilon = 1e-30
local curve_angle_tolerance_epsilon = 0.01
local curve_recursion_limit = 32
local recursive_bezier = nil

function bezier3.interpolate(write, x1, y1, x2, y2, x3, y3, x4, y4, m_approximation_scale, m_angle_tolerance, m_cusp_limit)
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
