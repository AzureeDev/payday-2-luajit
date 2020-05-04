require("lib/utils/IKSolver")
require("lib/utils/ConstraintHelper")

local BONES = {
	shoulder = {
		Vector3(-15.5597, 0, 0),
		Vector3(15.5597, 0, 0)
	},
	arm = {
		Vector3(-23.3162, 0, 0),
		Vector3(23.3162, 0, 0)
	},
	fore_arm = {
		Vector3(-22.5532, 0, 0),
		Vector3(22.5532, 0, 0)
	},
	hand = {
		Vector3(-12.7789, 0, 0),
		Vector3(12.7789, 0, 0)
	}
}
local tmpvec1 = Vector3()
local tmpvec2 = Vector3()
local tmpvec3 = Vector3()
local tmpvec4 = Vector3()
local tmpvec5 = Vector3()
local tmpvec6 = Vector3()

local function bkw_resolve(points, target)
	local c = tmpvec4
	local v = tmpvec5

	mvector3.set(c, target)

	for i = #points, 2, -1 do
		local len = mvector3.distance(points[i], points[i - 1])

		mvector3.set(v, points[i - 1])
		mvector3.subtract(v, c)
		mvector3.normalize(v)
		mvector3.multiply(v, len)
		mvector3.set(points[i], c)
		mvector3.add(c, v)
	end

	mvector3.set(points[1], c)
end

local function fwd_resolve(points, target)
	local c = tmpvec4
	local v = tmpvec5

	mvector3.set(c, target)

	for i = 1, #points - 1 do
		local len = mvector3.distance(points[i], points[i + 1])

		mvector3.set(v, points[i + 1])
		mvector3.subtract(v, c)
		mvector3.normalize(v)
		mvector3.multiply(v, len)
		mvector3.set(points[i], c)
		mvector3.add(c, v)
	end

	mvector3.set(points[#points], c)
end

local function ik_resolve_elbow(points, target)
	local start = tmpvec1

	mvector3.set(start, points[1])

	local elbow = tmpvec2

	mvector3.set(elbow, points[2])

	local dir = tmpvec3

	for i = 1, 3 do
		bkw_resolve(points, target)
		mvector3.set(dir, points[2])
		mvector3.subtract(dir, elbow)
		mvector3.set_z(dir, 0)

		local len = mvector3.normalize(dir)

		mvector3.multiply(dir, math.min(len, 1.5))
		mvector3.add(dir, elbow)
		mvector3.set_z(dir, points[2].z)
		mvector3.set(points[2], dir)
		fwd_resolve(points, start)
	end
end

local tmpvec_rot = Vector3()

local function rot_from_shortest_arc(from, to)
	local a = tmpvec_rot
	local d = mvector3.dot(from, to)

	mvector3.cross(a, from, to)

	local s = math.sqrt((1 + d) * 2)

	if s > 1e-07 then
		local inv_s = 1 / s

		return Rotation(a.x * inv_s, a.y * inv_s, a.z * inv_s, s * 0.5)
	end

	return Rotation(1, 0, 0, 0)
end

NNetHelper = NNetHelper or {}
local VALUE_SCALE = 20

function NNetHelper.create_body_config(arm_length, head_to_shoulder, shoulder_width)
	return {
		arm_length = arm_length,
		inv_arm_length = 1 / arm_length,
		upper_arm_length = arm_length * 0.45,
		head_to_shoulder = head_to_shoulder,
		shoulder_width = shoulder_width,
		half_shoulder_width = shoulder_width * 0.5
	}
end

local DEFAULT_BODY_CONFIG = NNetHelper.create_body_config(70, 15, 44)

function NNetHelper.calculate_center(position, rotation, head_to_shoulder)
	local d = mvector3.dot(rotation:y(), math.UP)
	local center = tmpvec1

	mvector3.set_static(center, 0, 0, -head_to_shoulder - d * head_to_shoulder)
	mvector3.add(center, position)

	return mvector3.copy(center)
end

function NNetHelper.calculate_shoulder_positions(position, rotation, facing, rp, lp, head_to_shoulder, shoulder_width)
	local shoulder_rotation = Rotation:look_at(facing, math.UP)
	local y = rotation:y()

	mvector3.multiply(y, head_to_shoulder)

	local d = mvector3.dot(y, math.UP)
	local v = tmpvec3
	local rsp = tmpvec1
	local lsp = tmpvec2

	mvector3.set_static(rsp, shoulder_width, -10, -head_to_shoulder - d)
	mvector3.rotate_with(rsp, shoulder_rotation)
	mvector3.add(rsp, position)
	mvector3.set(v, rp)
	mvector3.subtract(v, rsp)
	mvector3.normalize(v)
	mvector3.add_scaled(rsp, v, 3)
	mvector3.set_static(lsp, -shoulder_width, -10, -head_to_shoulder - d)
	mvector3.rotate_with(lsp, shoulder_rotation)
	mvector3.add(lsp, position)
	mvector3.set(v, rp)
	mvector3.subtract(v, lsp)
	mvector3.normalize(v)
	mvector3.add_scaled(lsp, v, 3)

	return mvector3.copy(rsp), mvector3.copy(lsp)
end

function NNetHelper.sample_input(vr_controller, body_config)
	local rpos, rrot = vr_controller:pose(0)
	local lpos, lrot = vr_controller:pose(1)
	local hmdpos, hmdrot = VRManager:hmd_pose()
	local input = {
		right_controller = {
			rpos,
			rrot
		},
		left_controller = {
			lpos,
			lrot
		},
		hmd = {
			hmdpos,
			hmdrot
		},
		body_config = body_config or DEFAULT_BODY_CONFIG
	}

	return input
end

local CONTROLLER_ROT = Rotation(math.X, -50)
local CONTROLLER_OFFSET = Vector3(0, -2, -7)

function NNetHelper.preprocess_input_sample(input_sample)
	local rpos, rrot = unpack(input_sample.right_controller)
	local lpos, lrot = unpack(input_sample.left_controller)
	local hmdpos, hmdrot = unpack(input_sample.hmd)
	rpos = mvector3.copy(rpos)
	lpos = mvector3.copy(lpos)
	rrot = Rotation() * rrot
	lrot = Rotation() * lrot

	mrotation.multiply(rrot, CONTROLLER_ROT)
	mrotation.multiply(lrot, CONTROLLER_ROT)

	local offset = tmpvec1

	mvector3.set(offset, CONTROLLER_OFFSET)
	mvector3.rotate_with(offset, rrot)
	mvector3.add(rpos, offset)
	mvector3.set(offset, CONTROLLER_OFFSET)
	mvector3.rotate_with(offset, lrot)
	mvector3.add(lpos, offset)

	local input = {
		right_controller = {
			rpos,
			rrot
		},
		left_controller = {
			lpos,
			lrot
		},
		hmd = {
			hmdpos,
			hmdrot
		},
		body_config = input_sample.body_config
	}

	return input
end

function NNetHelper.transform_input_sample(input, prev_facing)
	local i = input
	local position = i.hmd[1]
	local rotation = Rotation(i.hmd[2]:yaw(), 0, 0)
	local facing_v = prev_facing
	local forward = Rotation:look_at(facing_v, math.UP)
	local forward_inv = forward:inverse()

	mrotation.multiply(rotation, forward_inv)

	local cfg = input.body_config
	local rs, ls = NNetHelper.calculate_shoulder_positions(position, rotation, facing_v, i.right_controller[1], i.left_controller[1], cfg.head_to_shoulder, cfg.half_shoulder_width)
	local rc = tmpvec1
	local lc = tmpvec2

	mvector3.set(rc, i.right_controller[1])
	mvector3.subtract(rc, rs)
	mvector3.rotate_with(rc, forward_inv)
	mvector3.multiply(rc, cfg.inv_arm_length)
	mvector3.set(lc, i.left_controller[1])
	mvector3.subtract(lc, ls)
	mvector3.rotate_with(lc, forward_inv)
	mvector3.multiply(lc, cfg.inv_arm_length)

	facing_v = rotation:y()

	mvector3.multiply(facing_v, 1 / VALUE_SCALE)

	local input_point = {
		facing_v.x,
		facing_v.y,
		rc.x,
		rc.y,
		rc.z,
		lc.x,
		lc.y,
		lc.z
	}

	for i, v in ipairs(input_point) do
		input_point[i] = math.clamp(v, -1, 1)
	end

	return input_point
end

local tmpvec1_itos = Vector3()

function NNetHelper.inv_transform_output_sample(input, output)
	local temp = {}

	for i = 1, #output do
		temp[i] = (output[i] * 2 - 1) * VALUE_SCALE
	end

	local rsp = Vector3(temp[1], temp[2], temp[3])
	local rep = Vector3(temp[4], temp[5], temp[6])
	local rev = Vector3(temp[7], temp[8], temp[9])

	mvector3.normalize(rsp)
	mvector3.normalize(rep)
	mvector3.normalize(rev)

	local rcp = mvector3.copy(input.right_controller[1])
	local rcr = Rotation() * input.right_controller[2]
	local lsp = Vector3(temp[10], temp[11], temp[12])
	local lep = Vector3(temp[13], temp[14], temp[15])
	local lev = Vector3(temp[16], temp[17], temp[18])

	mvector3.normalize(lsp)
	mvector3.normalize(lep)
	mvector3.normalize(lev)

	local lcp = mvector3.copy(input.left_controller[1])
	local lcr = Rotation() * input.left_controller[2]
	local facing = mvector3.copy(rsp)

	mvector3.subtract(facing, lsp)
	mvector3.set_z(facing, 0)
	mvector3.normalize(facing)
	mvector3.cross(facing, math.UP, facing)

	local rotation = Rotation(input.hmd[2]:yaw(), 0, 0)
	local rotation_inv = rotation:inverse()
	local cfg = input.body_config
	local center = NNetHelper.calculate_center(input.hmd[1], input.hmd[2], cfg.head_to_shoulder)
	local slen = 17.11567
	local ulen = 25.64782
	local flen = 22.5532
	local hlen = 12.7789
	local alen = ulen + flen + hlen
	local p = tmpvec1_itos

	mvector3.subtract(lcp, center)
	mvector3.rotate_with(lcp, rotation_inv)
	mvector3.set(p, lcp)
	mvector3.subtract_scaled(p, lsp, cfg.half_shoulder_width)

	local len = mvector3.normalize(p)
	len = math.min(len * cfg.inv_arm_length, 1)
	len = len * alen

	mvector3.multiply(p, len)
	mvector3.add_scaled(p, lsp, slen)
	mvector3.set(lcp, p)
	mvector3.multiply(lsp, slen)
	mvector3.multiply(lep, ulen)
	mvector3.add(lep, lsp)

	local hand = tmpvec1_itos

	mvector3.set(hand, lcp)
	mvector3.subtract(hand, lep)
	mvector3.normalize(hand)
	mvector3.multiply(hand, flen)
	mvector3.add(hand, lep)

	local points = {
		lsp,
		lep,
		hand
	}

	ik_resolve_elbow(points, lcp)

	lep = points[2]

	mvector3.subtract(rcp, center)
	mvector3.rotate_with(rcp, rotation_inv)
	mvector3.set(p, rcp)
	mvector3.subtract_scaled(p, rsp, cfg.half_shoulder_width)

	local len = mvector3.normalize(p)
	len = math.min(len * cfg.inv_arm_length, 1)
	len = len * alen

	mvector3.multiply(p, len)
	mvector3.add_scaled(p, rsp, slen)
	mvector3.set(rcp, p)
	mvector3.multiply(rsp, slen)
	mvector3.multiply(rep, ulen)
	mvector3.add(rep, rsp)
	mvector3.set(hand, rcp)
	mvector3.subtract(hand, rep)
	mvector3.normalize(hand)
	mvector3.multiply(hand, flen)
	mvector3.add(hand, rep)

	local points = {
		rsp,
		rep,
		hand
	}

	ik_resolve_elbow(points, rcp)

	rep = points[2]

	mrotation.invert(rotation)

	rcr = rotation * rcr
	lcr = rotation * lcr

	return {
		right_shoulder = rsp,
		right_elbow = {
			rep,
			rev
		},
		right_controller = {
			rcp,
			rcr
		},
		left_shoulder = lsp,
		left_elbow = {
			lep,
			lev
		},
		left_controller = {
			lcp,
			lcr
		},
		facing = facing,
		body_config = cfg
	}
end

NNetHelper.ENABLE_CONSTRAINTS = true
local tmprot1 = Rotation()
local tmprot2 = Rotation()
local tmprot3 = Rotation()

local function slerp_bezier(dst, src, target, reference, t)
	local p0 = src
	local p1 = reference
	local p2 = target
	local p3 = target
	local q0 = tmprot1
	local q1 = tmprot2
	local q2 = tmprot3

	mrotation.slerp(q0, p0, p1, t)
	mrotation.slerp(q1, p1, p2, t)
	mrotation.slerp(q2, p2, p3, t)
	mrotation.slerp(q0, q0, q1, t)
	mrotation.slerp(q1, q1, q2, t)
	mrotation.slerp(dst, q0, q1, t)
end

local function ellipse_clamp(v, xaxis, yaxis)
	local d = math.sqrt(xaxis * xaxis * v.y * v.y + yaxis * yaxis * v.x * v.x)

	if d > 0 then
		local s = xaxis * yaxis / d
		local p = Vector3(v.x * s, v.y * s, v.z)

		if v.x * v.x + v.y * v.y < p.x * p.x + p.y * p.y then
			return p
		end
	end

	return v
end

local CONSTRAINT_ANGLES_ARM = {
	math.tan(89),
	math.tan(89),
	math.tan(89),
	math.tan(89)
}
local CONSTRAINT_ANGLES_HAND = {
	math.tan(25),
	math.tan(25),
	math.tan(25),
	math.tan(25)
}

function apply_rotation_constraints(pose, index)
	pose.arm[index] = ConstraintHelper.constrain_rotation(pose.shoulder[index], pose.arm[index], CONSTRAINT_ANGLES_ARM)
	pose.arm[index] = ConstraintHelper.constrain_orientation(pose.shoulder[index], pose.arm[index], {
		-10,
		35
	})
	pose.fore_arm[index] = ConstraintHelper.constrain_orientation(pose.arm[index], pose.fore_arm[index], {
		-35,
		35
	})
	pose.arm[index] = ConstraintHelper.constrain_rotation(pose.shoulder[index], pose.arm[index], CONSTRAINT_ANGLES_ARM)
	pose.arm[index] = ConstraintHelper.constrain_orientation(pose.shoulder[index], pose.arm[index], {
		-10,
		35
	})
	pose.fore_arm[index] = ConstraintHelper.constrain_bend(pose.arm[index], pose.fore_arm[index], {
		20,
		100
	})
	pose.fore_arm[index] = ConstraintHelper.constrain_orientation(pose.arm[index], pose.fore_arm[index], {
		-35,
		35
	})
	pose.hand[index] = ConstraintHelper.constrain_rotation(pose.fore_arm[index], pose.hand[index], CONSTRAINT_ANGLES_HAND)
	local temp = ConstraintHelper.constrain_orientation(pose.fore_arm[index], pose.hand[index], {
		-45,
		90
	}) * Rotation()

	mrotation.rotation_difference(temp, temp, pose.hand[index])
	mrotation.slerp(pose.fore_arm[index], pose.arm[index], temp * pose.fore_arm[index], 0.8)
	mrotation.slerp(pose.arm[index], pose.arm[index], temp * pose.arm[index], 0.5)

	pose.arm[index] = ConstraintHelper.constrain_rotation(pose.shoulder[index], pose.arm[index], CONSTRAINT_ANGLES_ARM)
end

function apply_model_constraints(pose, index)
	local sp = tmpvec1
	local ap = tmpvec2
	local fp = tmpvec3

	mvector3.set(sp, BONES.shoulder[1])
	mvector3.rotate_with(sp, pose.shoulder[index])
	mvector3.set(ap, BONES.arm[1])
	mvector3.rotate_with(ap, pose.arm[index])
	mvector3.set(fp, BONES.fore_arm[1])
	mvector3.rotate_with(fp, pose.fore_arm[index])
	mvector3.add(ap, sp)
	mvector3.add(fp, ap)

	fp = ellipse_clamp(fp, 15, 15)
	local dir = ap

	mvector3.subtract(dir, fp)
	mvector3.normalize(dir)

	local new_rot = rot_from_shortest_arc(pose.fore_arm[index]:x(), dir)

	mrotation.multiply(new_rot, pose.fore_arm[index])

	local q = Rotation()

	mrotation.rotation_difference(q, pose.fore_arm[index], new_rot)

	pose.fore_arm[index] = new_rot

	mrotation.multiply(q, pose.hand[index])

	pose.hand[index] = q
end

function apply_constraints(pose, index)
	apply_rotation_constraints(pose, index)
	apply_model_constraints(pose, index)
end

local SHOULDER_BASE_ROTATION = Rotation(0, -5, 3)
local ARM_BASE_ROTATION = Rotation(0, -45, 0)

local function calculate_arm_pose(pose, index, shoulder, other_shoulder, elbow, hand, hand_rotation, prev_pose)
	hand_rotation = Rotation(-hand_rotation:y(), -hand_rotation:x(), -hand_rotation:z())
	local shoulder_forward = tmpvec1

	mvector3.set(shoulder_forward, shoulder)
	mvector3.subtract(shoulder_forward, other_shoulder)

	local facing = tmpvec2

	mvector3.set(facing, shoulder_forward)
	mvector3.set_z(facing, 0)
	mvector3.normalize(facing)
	mvector3.cross(facing, facing, math.UP)
	mvector3.normalize(shoulder_forward)
	mvector3.multiply(shoulder_forward, -1)

	local shoulder_up = tmpvec3

	mvector3.set(shoulder_up, math.UP)
	mvector3.multiply(shoulder_up, -1)
	mvector3.subtract_scaled(shoulder_up, shoulder_forward, mvector3.dot(shoulder_up, shoulder_forward))

	local shoulder_right = tmpvec4

	mvector3.cross(shoulder_right, shoulder_forward, shoulder_up)

	local shoulder_rotation = Rotation(shoulder_forward, shoulder_up, shoulder_right)
	shoulder_rotation = SHOULDER_BASE_ROTATION * shoulder_rotation
	local arm_forward = tmpvec1
	local v = tmpvec3

	mvector3.set(v, hand)
	mvector3.subtract(v, shoulder)
	mvector3.set_z(v, 0)
	mvector3.normalize(v)

	local t = 1 - math.clamp(1 - mvector3.dot(v, facing), 0, 1)
	local v1 = tmpvec3
	local v2 = tmpvec4

	mvector3.set(v1, shoulder)
	mvector3.subtract(v1, elbow[1])
	mvector3.normalize(v1)
	mvector3.set(v2, shoulder)
	mvector3.subtract_scaled(v2, elbow[1], 1.5)
	mvector3.subtract(v2, hand)
	mvector3.normalize(v2)
	mvector3.lerp(arm_forward, v1, v2, t)
	mvector3.normalize(arm_forward)

	local arm_up = tmpvec3

	mvector3.set(arm_up, elbow[2])
	mvector3.subtract_scaled(arm_up, arm_forward, mvector3.dot(elbow[2], arm_forward))
	mvector3.normalize(arm_up)

	local arm_right = tmpvec4

	mvector3.cross(arm_right, arm_forward, arm_up)

	local arm_rotation = Rotation(arm_forward, arm_up, arm_right)

	mrotation.multiply(arm_rotation, ARM_BASE_ROTATION)

	if NNetHelper.ENABLE_CONSTRAINTS then
		arm_rotation = ConstraintHelper.constrain_rotation(shoulder_rotation, arm_rotation, CONSTRAINT_ANGLES_ARM)
	end

	local lift_angle = mvector3.dot(arm_forward, math.UP) * -45
	lift_angle = math.max(lift_angle, 5)

	mrotation.multiply(shoulder_rotation, Rotation(lift_angle, 0, 0))

	local tmp1 = shoulder_rotation:x()

	mvector3.set_z(tmp1, 0)
	mvector3.normalize(tmp1)

	local tmp2 = tmpvec3

	mvector3.set(tmp2, arm_forward)
	mvector3.set_z(tmp2, 0)
	mvector3.normalize(tmp2)

	local q = rot_from_shortest_arc(tmp1, tmp2)

	mrotation.multiply(q, shoulder_rotation)
	mrotation.slerp(q, shoulder_rotation, q, math.abs(mvector3.dot(arm_forward, facing)))

	shoulder_rotation = ConstraintHelper.constrain_bend(shoulder_rotation, q, {
		-25,
		25
	})

	if NNetHelper.ENABLE_CONSTRAINTS then
		arm_rotation = ConstraintHelper.constrain_orientation(shoulder_rotation, arm_rotation, {
			-10,
			35
		})
	end

	q = rot_from_shortest_arc(arm_rotation:x(), hand_rotation:x())

	mrotation.multiply(q, arm_rotation)
	mrotation.slerp(arm_rotation, arm_rotation, q, 0.1)

	local fore_arm_forward = tmpvec3

	mvector3.set(fore_arm_forward, elbow[1])
	mvector3.subtract(fore_arm_forward, hand)
	mvector3.normalize(fore_arm_forward)

	local fore_arm_angle = math.clamp(math.acos(mvector3.dot(fore_arm_forward, arm_rotation:x())), 20, 100)
	local r = Rotation(0, 0, -fore_arm_angle)

	if mrotation.dot(arm_rotation, r) < 0 then
		local x, y, z, w = r:raw()
		r = Rotation(-x, -y, -z, -w)
	end

	local fore_arm_rotation = arm_rotation * r
	fore_arm_rotation = Rotation(fore_arm_rotation:x(), arm_rotation:y(), fore_arm_rotation:z())

	mrotation.normalize(fore_arm_rotation)

	local r = rot_from_shortest_arc(fore_arm_rotation:x(), hand_rotation:x())

	mrotation.multiply(r, fore_arm_rotation)
	mrotation.slerp(fore_arm_rotation, fore_arm_rotation, r, 0.05)

	if prev_pose and prev_pose.fore_arm[index + 2] then
		slerp_bezier(fore_arm_rotation, fore_arm_rotation, hand_rotation, prev_pose.fore_arm[index + 2], 0.2)
	else
		mrotation.slerp(fore_arm_rotation, fore_arm_rotation, hand_rotation, 0.2)
	end

	pose.fore_arm[index + 2] = fore_arm_rotation * Rotation()
	local proj = fore_arm_rotation:x()

	mvector3.multiply(proj, mvector3.dot(arm_rotation:z(), fore_arm_rotation:x()))
	mvector3.add_scaled(proj, fore_arm_rotation:z(), mvector3.dot(arm_rotation:z(), fore_arm_rotation:z()))
	mvector3.normalize(proj)

	local r = rot_from_shortest_arc(arm_rotation:z(), proj)

	if mrotation.dot(arm_rotation, r) < 0 then
		local x, y, z, w = r:raw()
		r = Rotation(-x, -y, -z, -w)
	end

	mrotation.multiply(r, arm_rotation)

	arm_rotation = r

	if prev_pose and prev_pose.arm[index + 2] then
		slerp_bezier(arm_rotation, arm_rotation, hand_rotation, prev_pose.arm[index + 2], 0.1)
	else
		mrotation.slerp(arm_rotation, arm_rotation, hand_rotation, 0.1)
	end

	pose.arm[index + 2] = arm_rotation * Rotation()

	mrotation.normalize(shoulder_rotation)
	mrotation.normalize(arm_rotation)
	mrotation.normalize(fore_arm_rotation)
	mrotation.normalize(hand_rotation)

	pose.shoulder[index] = shoulder_rotation
	pose.arm[index] = arm_rotation
	pose.fore_arm[index] = fore_arm_rotation
	pose.hand[index] = hand_rotation
end

local function apply_aim_constraint(index, target_pos, align_dir, pose, swap, prev_pose)
	local sp = tmpvec1
	local ap = tmpvec2
	local fp = tmpvec3
	local hp = tmpvec4
	local aim_point = tmpvec5

	mvector3.set(sp, BONES.shoulder[index])
	mvector3.rotate_with(sp, pose.shoulder[index])
	mvector3.set(ap, BONES.arm[index])
	mvector3.rotate_with(ap, pose.arm[index])
	mvector3.set(fp, BONES.fore_arm[index])
	mvector3.rotate_with(fp, pose.fore_arm[index])
	mvector3.set(hp, BONES.hand[index])
	mvector3.rotate_with(hp, pose.hand[index])
	mvector3.set(aim_point, align_dir)
	mvector3.rotate_with(aim_point, pose.hand[index])

	local hand_rotation = pose.hand[index]

	mvector3.add(ap, sp)
	mvector3.add(fp, ap)
	mvector3.add(hp, fp)
	mvector3.add(aim_point, hp)

	local dir = tmpvec6

	mvector3.set(dir, target_pos)
	mvector3.subtract(dir, aim_point)
	mvector3.normalize(dir)

	local q = rot_from_shortest_arc(hand_rotation:x(), dir)

	if mrotation.dot(hand_rotation, q) < 0 then
		local x, y, z, w = q:raw()
		q = Rotation(-x, -y, -z, -w)
	end

	pose.hand[index] = q * pose.hand[index]

	if prev_pose and prev_pose.fore_arm[index + 4] then
		slerp_bezier(pose.fore_arm[index], pose.fore_arm[index], q * pose.fore_arm[index], prev_pose.fore_arm[index + 4], 0.25)
		slerp_bezier(pose.arm[index], pose.arm[index], q * pose.arm[index], prev_pose.arm[index + 4], 0.05)
	end

	if NNetHelper.ENABLE_CONSTRAINTS then
		local temp = ConstraintHelper.constrain_bend(pose.arm[index], pose.fore_arm[index], {
			20,
			100
		})

		mrotation.rotation_difference(q, temp, pose.fore_arm[index])

		pose.arm[index] = q * pose.arm[index]
	end

	pose.fore_arm[index + 4] = pose.fore_arm[index] * Rotation()
	pose.arm[index + 4] = pose.arm[index] * Rotation()
end

function mirror_arm_pose(pose, index)
	local hand_rotation = pose.fore_arm[index]:inverse()

	mrotation.multiply(hand_rotation, pose.hand[index])

	local fore_arm_rotation = pose.arm[index]:inverse()

	mrotation.multiply(fore_arm_rotation, pose.fore_arm[index])

	local arm_rotation = pose.shoulder[index]:inverse()

	mrotation.multiply(arm_rotation, pose.arm[index])

	local shoulder_rotation = Rotation(0, 180, 0)

	mrotation.multiply(shoulder_rotation, pose.shoulder[index])

	pose.shoulder[index] = shoulder_rotation
	pose.arm[index] = shoulder_rotation * arm_rotation
	pose.fore_arm[index] = pose.arm[index] * fore_arm_rotation
	pose.hand[index] = pose.fore_arm[index] * hand_rotation
end

local tmpvec_pose_1 = Vector3()
local tmpvec_pose_2 = Vector3()
local tmpvec_pose_3 = Vector3()
local tmpvec_pose_4 = Vector3()
local tmpvec_pose_5 = Vector3()

function NNetHelper.build_pose(output, rot, target, prev_pose)
	local next_pose = {
		shoulder = {},
		arm = {},
		fore_arm = {},
		hand = {}
	}

	calculate_arm_pose(next_pose, 1, output.right_shoulder, output.left_shoulder, output.right_elbow, output.right_controller[1], output.right_controller[2], prev_pose)

	local left_shoulder = tmpvec_pose_1
	local right_shoulder = tmpvec_pose_2
	local left_elbow = tmpvec_pose_3
	local left_elbow_dir = tmpvec_pose_4
	local left_controller = tmpvec_pose_5

	mvector3.set_static(left_shoulder, -output.left_shoulder.x, output.left_shoulder.y, output.left_shoulder.z)
	mvector3.set_static(right_shoulder, -output.right_shoulder.x, output.right_shoulder.y, output.right_shoulder.z)
	mvector3.set_static(left_elbow, -output.left_elbow[1].x, output.left_elbow[1].y, output.left_elbow[1].z)
	mvector3.set_static(left_elbow_dir, -output.left_elbow[2].x, output.left_elbow[2].y, output.left_elbow[2].z)
	mvector3.set_static(left_controller, -output.left_controller[1].x, output.left_controller[1].y, output.left_controller[1].z)

	local left_controller_rot = Rotation(0, 180, 0)

	mrotation.multiply(left_controller_rot, output.left_controller[2])
	mrotation.multiply(left_controller_rot, Rotation(0, 180, 0))
	calculate_arm_pose(next_pose, 2, left_shoulder, right_shoulder, {
		left_elbow,
		left_elbow_dir
	}, left_controller, left_controller_rot, prev_pose)

	if NNetHelper.ENABLE_CONSTRAINTS then
		apply_constraints(next_pose, 1)
		apply_constraints(next_pose, 2)
	end

	if target and target[1] and target[2] then
		apply_aim_constraint(1, -target[1]:rotate_with(rot:inverse()), Vector3(-target[2].y, 0, -target[2].z), next_pose, target.swap, prev_pose)
	end

	if target and target[3] and target[4] then
		apply_aim_constraint(2, target[3]:rotate_with(Rotation(0, 180, 0) * rot:inverse()), Vector3(target[4].y, 0, target[4].z):rotate_with(Rotation(0, 180, 0)), next_pose, target.swap, prev_pose)
	end

	mirror_arm_pose(next_pose, 2)

	for i = 1, 2 do
		next_pose.shoulder[i] = rot * next_pose.shoulder[i]
		next_pose.arm[i] = rot * next_pose.arm[i]
		next_pose.fore_arm[i] = rot * next_pose.fore_arm[i]
		next_pose.hand[i] = rot * next_pose.hand[i]
	end

	return next_pose
end
