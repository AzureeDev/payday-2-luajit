core:module("CoreSpringCameraNode")
core:import("CoreTransformCameraNode")
core:import("CoreClass")
core:import("CoreMath")

local mvector3_add = mvector3.add
local mvector3_sub = mvector3.subtract
local mvector3_mul = mvector3.multiply
local mvector3_neg = mvector3.negate
local mvector3_set_zero = mvector3.set_zero
local mvector3_set = mvector3.set
local mvector3_set_static = mvector3.set_static
local mvector3_copy = mvector3.copy
local mvector3_rotate_with = mvector3.rotate_with
SpringCameraNode = SpringCameraNode or CoreClass.class(CoreTransformCameraNode.TransformCameraNode)

function SpringCameraNode:init(settings)
	SpringCameraNode.super.init(self, settings)

	self._force = Vector3(0, 0, 0)
	self._spring = settings.spring
	self._max_displacement = settings.max_displacement
	self._damping = settings.damping
	self._force_scale = settings.force_scale
	self._force_applicant = settings.force_applicant:new()
	self._integrator_func = settings.integrator_func

	self:reset()
end

function SpringCameraNode.compile_settings(xml_node, settings)
	SpringCameraNode.super.compile_settings(xml_node, settings)

	if xml_node:has_parameter("spring") then
		settings.spring = math.string_to_vector(xml_node:parameter("spring"))
	end

	if xml_node:has_parameter("max_displacement") then
		settings.max_displacement = math.string_to_vector(xml_node:parameter("max_displacement"))
	end

	if xml_node:has_parameter("damping") then
		settings.damping = math.string_to_vector(xml_node:parameter("damping"))
	end

	if xml_node:has_parameter("force_scale") then
		settings.force_scale = math.string_to_vector(xml_node:parameter("force_scale"))
	end

	if xml_node:has_parameter("force") then
		local force = xml_node:parameter("force")

		if force == "acceleration" then
			settings.force_applicant = SpringCameraAcceleration
		elseif force == "velocity" then
			settings.force_applicant = SpringCameraVelocity
		elseif force == "position" then
			settings.force_applicant = SpringCameraPosition
		end
	else
		settings.force_applicant = SpringCameraPosition
	end

	if xml_node:has_parameter("integrator") then
		local integrator = xml_node:parameter("integrator")

		if integrator == "euler" then
			settings.integrator_func = SpringCameraNode.euler_integration
		elseif integrator == "rk2" then
			settings.integrator_func = SpringCameraNode.rk2_integration
		elseif integrator == "rk4" then
			settings.integrator_func = SpringCameraNode.rk4_integration
		end
	else
		settings.integrator_func = SpringCameraNode.rk2_integration
	end
end

function SpringCameraNode:acceleration(displacement, velocity, force)
	local spring = self._spring
	local damping = self._damping

	return Vector3(-(displacement.x * spring.x) - damping.x * velocity.x + force.x, -(displacement.y * spring.y) - damping.y * velocity.y + force.y, -(displacement.z * spring.z) - damping.z * velocity.z + force.z)
end

function SpringCameraNode:euler_integration(dt, force)
	local displacement = self._displacement
	local velocity = self._velocity
	local a1 = self:acceleration(displacement, velocity, force)
	self._displacement = velocity + a1 * dt
	self._velocity = self._displacement + velocity * dt + 0.5 * a1 * dt * dt
end

function SpringCameraNode:rk2_integration(dt, force)
	local xf = self._displacement
	local vf = self._velocity
	local x1 = mvector3.copy(xf)
	local v1 = mvector3.copy(vf)
	local x2 = mvector3.copy(v1)

	mvector3_mul(x2, 0.5 * dt)
	mvector3_add(x2, x1)

	local a = self:acceleration(x1, v1, force)
	local v2 = mvector3.copy(a)

	mvector3_mul(v2, 0.5 * dt)
	mvector3_add(v2, v1)
	mvector3_set(xf, v2)
	mvector3_mul(xf, dt)
	mvector3_add(xf, x1)
	mvector3_set(a, self:acceleration(x2, v2, force))
	mvector3_set(vf, a)
	mvector3_mul(vf, dt)
	mvector3_add(vf, v1)
end

function SpringCameraNode:rk4_integration(dt, force)
	local x1 = self._displacement
	local v1 = self._velocity
	local a1 = self:acceleration(x1, v1, force)
	local x2 = x1 + 0.5 * v1 * dt
	local v2 = v1 + 0.5 * a1 * dt
	local a2 = self:acceleration(x2, v2, force)
	local x3 = x1 + 0.5 * v2 * dt
	local v3 = v1 + 0.5 * a2 * dt
	local a3 = self:acceleration(x3, v3, force)
	local x4 = x1 + v3 * dt
	local v4 = v1 + a3 * dt
	local a4 = self:acceleration(x4, v4, force)
	local xf = x1 + dt / 6 * (v1 + 2 * v2 + 2 * v3 + v4)
	local vf = v1 + dt / 6 * (a1 + 2 * a2 + 2 * a3 + a4)
	self._displacement = xf
	self._velocity = vf
end

function SpringCameraNode:update(t, dt, in_data, out_data)
	local displacement = self._displacement
	local max_displacement = self._max_displacement
	local force = self._force
	local force_scale = self._force_scale

	self._force_applicant:force(t, dt, force, in_data._position, in_data._rotation)
	mvector3_set_static(force, force.x * force_scale.x, force.y * force_scale.y, force.z * force_scale.z)
	self:_integrator_func(dt, force)
	mvector3_set_static(displacement, math.clamp(displacement.x, -max_displacement.x, max_displacement.x), math.clamp(displacement.y, -max_displacement.y, max_displacement.y), math.clamp(displacement.z, -max_displacement.z, max_displacement.z))
	mvector3_set(self._local_position, displacement)
	SpringCameraNode.super.update(self, t, dt, in_data, out_data)
end

function SpringCameraNode:reset()
	self._velocity = Vector3(0, 0, 0)
	self._displacement = Vector3(0, 0, 0)

	if self._force_applicant then
		self._force_applicant:reset()
	end
end

function SpringCameraNode:debug_render(t, dt)
	SpringCameraNode.super.debug_render(self, t, dt)

	local start_brush = Draw:brush(Color(0.3, 1, 0, 0))
	local end_brush = Draw:brush(Color(0.3, 0, 1, 0))
	local line_pen = Draw:pen(Color(0.3, 0, 0, 1))
	local parent_position = nil

	start_brush:sphere(self:parent_camera():position(), 1)
	end_brush:sphere(self:position(), 1)
	line_pen:line(self:parent_camera():position(), self:position())

	local line_pen2 = Draw:pen(Color(0.3, 1, 0, 1))

	line_pen2:line(self:position(), self:position() + self._force:rotate_with(self:rotation()))
end

SpringCameraForce = SpringCameraForce or CoreClass.class()

function SpringCameraForce:init()
end

function SpringCameraForce:force(t, dt, force, parent_position, parent_rotation)
end

function SpringCameraForce:reset()
end

SpringCameraPosition = SpringCameraPosition or CoreClass.class(SpringCameraForce)

function SpringCameraPosition:init()
	self:reset()
end

function SpringCameraPosition:force(t, dt, force, parent_position, parent_rotation)
	if not self._reset then
		mvector3_set(force, parent_position)
		mvector3_sub(force, self._previous_parent_position)
		mvector3_rotate_with(force, parent_rotation:inverse())
		mvector3_neg(force)
	else
		mvector3_set_zero(force)

		self._reset = false
	end

	mvector3_set(self._previous_parent_position, parent_position)
end

function SpringCameraPosition:reset()
	self._reset = true
	self._previous_parent_position = Vector3(0, 0, 0)
end

SpringCameraVelocity = SpringCameraVelocity or CoreClass.class(SpringCameraForce)

function SpringCameraVelocity:init()
	self:reset()
end

function SpringCameraVelocity:force(t, dt, force, parent_position, parent_rotation)
	if not self._reset then
		mvector3_set(force, parent_position)
		mvector3_sub(force, self._previous_parent_position)
		mvector3_mul(force, 1 / dt)

		local velocity = mvector3_copy(force)

		mvector3_sub(force, self._velocity)
		mvector3_set(self._velocity, velocity)
		mvector3_rotate_with(force, parent_rotation:inverse())
		mvector3_neg(force)
	else
		mvector3_set_zero(force)
		mvector3_set_zero(self._velocity)

		self._reset = false
	end

	mvector3_set(self._previous_parent_position, parent_position)
end

function SpringCameraVelocity:reset()
	self._reset = true
	self._velocity = Vector3(0, 0, 0)
	self._previous_parent_position = Vector3(0, 0, 0)
end

SpringCameraAcceleration = SpringCameraAcceleration or CoreClass.class(SpringCameraForce)

function SpringCameraAcceleration:init()
	self:reset()
end

function SpringCameraAcceleration:force(t, dt, force, parent_position, parent_rotation)
	if not self._reset then
		mvector3_set(force, parent_position)
		mvector3_sub(force, self._previous_parent_position)
		mvector3_mul(force, 1 / dt)

		local velocity = mvector3_copy(force)

		mvector3_sub(force, self._velocity)
		mvector3_mul(force, 1 / dt)
		mvector3_set(self._velocity, velocity)
		mvector3_rotate_with(force, parent_rotation:inverse())
		mvector3_neg(force)
	else
		mvector3_set_zero(force)
		mvector3_set_zero(self._velocity)

		self._reset = false
	end

	mvector3_set(self._previous_parent_position, parent_position)
end

function SpringCameraAcceleration:reset()
	self._reset = true
	self._velocity = Vector3(0, 0, 0)
	self._previous_parent_position = Vector3(0, 0, 0)
end
