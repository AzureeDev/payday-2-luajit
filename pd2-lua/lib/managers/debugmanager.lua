core:module("DebugManager")
core:import("CoreDebugManager")
core:import("CoreClass")

local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_sub = mvector3.subtract
local mvec3_norm = mvector3.normalize
local mvec3_dir = mvector3.direction
local mvec3_set_l = mvector3.set_length
local mvec3_add = mvector3.add
local mvec3_dot = mvector3.dot
local mvec3_cross = mvector3.cross
local mvec3_rot = mvector3.rotate_with
local mvec3_rand_orth = mvector3.random_orthogonal
local mvec3_lerp = mvector3.lerp
local mrot_axis_angle = mrotation.set_axis_angle
DebugManager = DebugManager or class(CoreDebugManager.DebugManager)

function DebugManager:qa_debug(username)
	self:set_qa_debug_enabled(username, true)
end

function DebugManager:get_qa_debug_enabled()
	return self._qa_debug_enabled
end

function DebugManager:set_qa_debug_enabled(username, enabled)
	enabled = not not enabled
	local cat_print_list = {
		"qa"
	}

	for _, cat in ipairs(cat_print_list) do
		Global.category_print[cat] = enabled
	end

	self._qa_debug_enabled = enabled
end

CoreClass.override_class(CoreDebugManager.DebugManager, DebugManager)

function DebugManager:test_vector(x, y, z)
	local enemy_vec = Vector3()
	local temp_rot1 = Vector3()
	local pos = Vector3(75, 0, 0)

	mvec3_set(enemy_vec, pos)
	mvec3_sub(enemy_vec, Vector3(100, 0, 0))
	print(enemy_vec)

	local error_vec = Vector3()

	mvec3_cross(error_vec, enemy_vec, math.UP)
	print(error_vec)
	mrot_axis_angle(temp_rot1, enemy_vec, math.random(360))
	print(temp_rot1)
	mvec3_rot(error_vec, temp_rot1)
	print(error_vec)

	local error_vec_len = 31 + 20 * math.random() + 40 * math.random() * 1

	print(error_vec_len)
	mvec3_set_l(error_vec, error_vec_len)
	print(error_vec)
	mvec3_add(error_vec, pos)
	print(error_vec)
end
