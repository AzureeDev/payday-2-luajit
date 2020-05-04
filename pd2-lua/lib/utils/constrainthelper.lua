ConstraintHelper = ConstraintHelper or {}
local tmpvec1 = Vector3()
local tmpvec2 = Vector3()
local tmpvec3 = Vector3()
local tmpvec4 = Vector3()

function ConstraintHelper.normalize_angle(angle)
	if angle < -180 then
		angle = angle + 360
	end

	if angle > 180 then
		angle = angle - 360
	end

	return angle
end

function ConstraintHelper.clamp_angle(angle, min, max)
	local n_min = ConstraintHelper.normalize_angle(min - angle)
	local n_max = ConstraintHelper.normalize_angle(max - angle)

	if n_min <= 0 and n_max >= 0 then
		return angle
	end

	if math.abs(n_min) < math.abs(n_max) then
		return min
	end

	return max
end

local function get_root(r, z0, z1, g)
	local n = r * z0
	local s0 = z1 - 1
	local s1 = g < 0 and 0 or Vector3(n, z1, 0):length() - 1
	local s = 0

	for i = 1, 10 do
		s = (s0 + s1) * 0.5

		if s == s0 or s == s1 then
			break
		end

		local ratio0 = n / (s + r)
		local ratio1 = z1 / (s + 1)
		g = ratio0 * ratio0 + ratio1 * ratio1 - 1

		if g > 0 then
			s0 = s
		elseif g < 0 then
			s1 = s
		else
			break
		end
	end

	return s
end

local function clamp_ellipsoid(px, py, ex, ey)
	local flip = nil
	local xs = math.sign(px)
	local ys = math.sign(py)
	px = math.abs(px)
	py = math.abs(py)

	if ex < ey then
		local t = ex
		ex = ey
		ey = t
		local t = px
		px = py
		py = t
		flip = true
	end

	if py > 0 then
		if px > 0 then
			local zx = px / ex
			local zy = py / ey
			local g = zx * zx + zy * zy - 1
			local r = ex / ey
			r = r * r
			local sbar = get_root(r, zx, zy, g)
			px = r * px / (sbar + r)
			py = py / (sbar + 1)
		else
			px = 0
			py = ey
		end
	else
		local n = ex * px
		local d = ex * ex - ey * ey

		if n < d then
			local s = n / d
			px = ex * s
			py = ey * math.sqrt(1 - s * s)
		else
			px = ex
			py = 0
		end
	end

	if flip then
		local t = px
		px = py
		py = t
	end

	return px * xs, py * ys
end

local function rot_from_shortest_arc(from, to)
	local a = Vector3()
	local d = mvector3.dot(from, to)

	mvector3.cross(a, from, to)

	local s = math.sqrt((1 + d) * 2)

	if s > 1e-07 then
		local inv_s = 1 / s

		return Rotation(a.x * inv_s, a.y * inv_s, a.z * inv_s, s / 2)
	end

	return Rotation(1, 0, 0, 0)
end

function ConstraintHelper.clamp_ellipsoid(x, y, a, b)
	local d = math.sqrt(a * a * y * y + b * b * x * x)
	local s = d > 0 and a * b / d or 0

	return x * s, y * s
end

function ConstraintHelper.clamp_ellipsoid_quadrant(x, y, height, angle)
	local q = x > 0 and (y > 0 and 1 or 4) or y > 0 and 2 or 3
	local xs, ys = nil

	if q == 1 then
		xs = angle[1]
		ys = angle[2]
	elseif q == 2 then
		xs = angle[3]
		ys = angle[2]
	elseif q == 3 then
		xs = angle[3]
		ys = angle[4]
	elseif q == 4 then
		xs = angle[1]
		ys = angle[4]
	end

	local a = xs * height
	local b = ys * height
	local d = math.sqrt(a * a * y * y + b * b * x * x)
	local s = d > 0 and a * b / d or 0

	return x * s, y * s
end

function ConstraintHelper.draw_rotational_constraint(brush, pos, radius, up, right, angles)
	local origin = pos
	local r = radius
	local xs = 1
	local ys = 1

	for i = 0, 360 do
		if i < 90 then
			xs = angles[1]
			ys = angles[2]
		elseif i < 180 then
			xs = angles[3]
			ys = angles[2]
		elseif i < 270 then
			xs = angles[3]
			ys = angles[4]
		else
			xs = angles[1]
			ys = angles[4]
		end

		local x1 = math.cos(i) * r * xs
		local y1 = math.sin(i) * r * ys
		local x2 = math.cos(i + 1) * r * xs
		local y2 = math.sin(i + 1) * r * ys

		brush:line(origin + right * x1 + up * y1, Vector3(0, 0.1, 0) + origin + right * x2 + up * y2)
	end
end

function ConstraintHelper.constrain_rotation(src, dst, angle)
	local forward = src:x()
	local target = dst:x()
	local target_dot_forward = mvector3.dot(target, forward)

	if target_dot_forward < 0 then
		local tx = dst:x()
		local dx = tmpvec1

		mvector3.set(dx, tx)
		mvector3.subtract_scaled(dx, forward, 2 * mvector3.dot(tx, forward))
		mvector3.normalize(dx)

		dst = rot_from_shortest_arc(tx, dx) * dst
		target = dst:x()
	end

	local height = math.abs(target_dot_forward)
	local right = src:y()
	local up = src:z()
	local x = mvector3.dot(target, right)
	local y = mvector3.dot(target, up)
	local px = x
	local py = y
	x, y = ConstraintHelper.clamp_ellipsoid_quadrant(x, y, height, angle)
	local target_rotation = nil

	if x * x + y * y < px * px + py * py then
		local v = forward

		mvector3.multiply(v, height)
		mvector3.add_scaled(v, right, x)
		mvector3.add_scaled(v, up, y)
		mvector3.normalize(v)

		local r = rot_from_shortest_arc(target, v)

		mrotation.multiply(r, dst)

		return r
	end

	return dst
end

function ConstraintHelper.constrain_orientation(src, dst, min_max_angle)
	local target_rotation = dst
	local forward = src:x()
	local target = target_rotation:x()
	local a = tmpvec1
	local d = mvector3.dot(target, forward)

	mvector3.cross(a, forward, target)

	local reference = Rotation(a.x, a.y, a.z, 1 + d)

	mrotation.normalize(reference)
	mrotation.multiply(reference, src)

	local dst_z = dst:z()
	local d = mvector3.dot(reference:z(), dst_z)
	local angle = math.acos(d)

	if mvector3.dot(reference:y(), dst_z) < 0 then
		angle = 360 - angle
	end

	local new_angle = ConstraintHelper.clamp_angle(angle, min_max_angle[1], min_max_angle[2])

	if new_angle ~= angle then
		new_angle = (angle - new_angle) * 0.5
		a = target

		mvector3.multiply(a, math.sin(new_angle))

		local r = Rotation(a.x, a.y, a.z, math.cos(new_angle))

		mrotation.multiply(r, target_rotation)

		target_rotation = r
	end

	return target_rotation
end

function ConstraintHelper.constrain_bend(src, dst, angles, align_src)
	local dst_x = dst:x()
	local src_x = src:x()
	local src_z = src:z()
	local sign = math.sign(mvector3.dot(src_z, dst_x))
	local angle = sign * math.acos(mvector3.dot(src_x, dst_x))

	if angle < angles[1] then
		if align_src then
			local r = rot_from_shortest_arc(src_x, dst_x)

			mrotation.multiply(r, src)
			mrotation.set_zero(src)
			mrotation.multiply(src, r)

			return dst
		end

		local v = math.cos(angles[1]) * src_x + math.sin(angles[1]) * src_z

		mvector3.normalize(v)

		local rot = rot_from_shortest_arc(dst_x, v)

		mrotation.multiply(rot, dst)

		return rot
	end

	if angles[2] < angle then
		local v = math.cos(angles[2]) * src_x + math.sin(angles[2]) * src_z

		mvector3.normalize(v)

		local rot = rot_from_shortest_arc(dst_x, v)

		mrotation.multiply(rot, dst)

		return rot
	end

	return dst
end
