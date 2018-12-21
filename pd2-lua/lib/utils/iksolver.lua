IKSolver = IKSolver or {}

local function findD(a, b, c)
	return math.max(0, math.min(a, (c + (a * a - b * b) / c) * 0.5))
end

local function findE(a, d)
	return math.sqrt(a * a - d * d)
end

local function rot(m, src, dst)
	mvector3.set_static(dst, mvector3.dot(m[1], src), mvector3.dot(m[2], src), mvector3.dot(m[3], src))
end

local function defineM(p, d, inv, fwd)
	local x = inv[1]
	local y = inv[2]
	local z = inv[3]

	mvector3.set(x, p)
	mvector3.normalize(x)

	local dot = mvector3.dot(d, x)

	mvector3.set(y, x)
	mvector3.multiply(y, -dot)
	mvector3.add(y, d)
	mvector3.normalize(y)
	mvector3.cross(z, x, y)
	mvector3.set_static(fwd[1], x.x, y.x, z.x)
	mvector3.set_static(fwd[2], x.y, y.y, z.y)
	mvector3.set_static(fwd[3], x.z, y.z, z.z)
end

local minv = {
	Vector3(),
	Vector3(),
	Vector3()
}
local mfwd = {
	Vector3(),
	Vector3(),
	Vector3()
}

function IKSolver.solve(a, b, p, d, q)
	local r = Vector3()

	defineM(p, d, minv, mfwd)
	rot(minv, p, r)

	local r_len = mvector3.length(r)
	local _d = findD(a, b, r_len)
	local _e = findE(a, _d)
	local s = Vector3(_d, _e, 0)

	rot(mfwd, s, q)

	return _d > 0 and _d < a
end
