core:module("CoreAimCameraNode")
core:import("CoreTransformCameraNode")
core:import("CoreClass")

local mvector3_add = mvector3.add
local mvector3_set = mvector3.set
local mvector3_copy = mvector3.copy
local mvector3_negate = mvector3.negate
local mvector3_rotate_with = mvector3.rotate_with
local mvector3_normalize = mvector3.normalize
local mrotation_set_zero = mrotation.set_zero
local mrotation_mul = mrotation.multiply
local mrotation_inv = mrotation.invert
AimCameraNode = AimCameraNode or CoreClass.class(CoreTransformCameraNode.TransformCameraNode)

function AimCameraNode:init(settings)
	AimCameraNode.super.init(self, settings)

	self._pitch_offset = settings.pitch_offset
end

function AimCameraNode.compile_settings(xml_node, settings)
	AimCameraNode.super.compile_settings(xml_node, settings)

	if xml_node:has_parameter("pitch_offset") then
		settings.pitch_offset = xml_node:parameter("pitch_offset") == "true"
	else
		settings.pitch_offset = false
	end
end

function AimCameraNode:set_eye_target_position(position)
	self._eye_target_position = position
end

function AimCameraNode:update(t, dt, in_data, out_data)
	local eye_target_position = self._eye_target_position

	if not eye_target_position then
		return
	end

	local parent_position = in_data:position()
	local parent_rotation = in_data:rotation()

	if self._pitch_offset then
		mvector3_set(self._local_position, self:_update_pitch_offset(parent_position, parent_rotation))
	end

	local direction = mvector3_copy(self._local_position)

	mvector3_rotate_with(direction, parent_rotation)
	mvector3_add(direction, parent_position)
	mvector3_negate(direction)
	mvector3_add(direction, eye_target_position)
	mvector3_normalize(direction)
	mrotation_set_zero(self._local_rotation)
	mrotation_mul(self._local_rotation, parent_rotation)
	mrotation_inv(self._local_rotation)
	mrotation_mul(self._local_rotation, Rotation(direction, math.UP))
	out_data:set_constraints(Rotation(), 10, 10)
	AimCameraNode.super.update(self, t, dt, in_data, out_data)
end

function AimCameraNode:_update_pitch_offset(parent_position, parent_rotation)
	local current_position = parent_position + self:local_position():rotate_with(parent_rotation)
	local current_position_to_eye_target = self._camera_data.eye_target_position - current_position

	if current_position_to_eye_target:length() > 0 then
		local polar = current_position_to_eye_target:to_polar_with_reference(parent_rotation:y(), parent_rotation:z())
		local pitch = polar.pitch
		local yaw = polar.spin

		if pitch < 0 and pitch > -90 then
			local normalized_pitch = math.abs(pitch) / 90
			local y_offset = -math.sign(pitch) * (math.sin(270 + normalized_pitch * 180) * 0.5 + 0.5) * 90
			local offset = Vector3(0, y_offset, 0)

			return offset:rotate_with(Rotation(math.UP, yaw))
		end
	end

	return self:local_position()
end
