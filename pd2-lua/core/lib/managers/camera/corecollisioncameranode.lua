core:module("CoreCollisionCameraNode")
core:import("CoreTransformCameraNode")
core:import("CoreClass")
core:import("CoreMath")

CollisionCameraNode = CollisionCameraNode or CoreClass.class(CoreTransformCameraNode.TransformCameraNode)

function CollisionCameraNode:init(settings)
	CollisionCameraNode.super.init(self, settings)

	self._pop_controller = SmootherPopController()
	self._update = CollisionCameraNode._update_smoother
	self._ignore_unit = settings.ignore_unit

	self._pop_controller:set_parameter("smooth_radius", settings.smooth_radius)
	self._pop_controller:set_parameter("near_radius", settings.near_radius)
	self._pop_controller:set_parameter("precision", settings.precision)

	self._camera_distance = 10000
	self._camera_max_velocity = settings.max_velocity
	self._safe_position_var = settings.safe_position_var
end

function CollisionCameraNode:set_unit(unit)
	self._unit = unit

	if self._ignore_unit then
		self._pop_controller:set_parameter("ignore_units", {
			unit
		})
	end
end

function CollisionCameraNode:set_safe_position(position)
	self._safe_position = position
end

function CollisionCameraNode.compile_settings(xml_node, settings)
	CollisionCameraNode.super.compile_settings(xml_node, settings)

	if xml_node:has_parameter("ignore_unit") then
		settings.ignore_unit = xml_node:parameter("ignore_unit") == "true"
	else
		settings.ignore_unit = true
	end

	if xml_node:has_parameter("smooth_radius") then
		settings.smooth_radius = tonumber(xml_node:parameter("smooth_radius"))
	else
		settings.smooth_radius = 30
	end

	if xml_node:has_parameter("near_radius") then
		settings.near_radius = tonumber(xml_node:parameter("near_radius"))
	else
		settings.near_radius = 5
	end

	if xml_node:has_parameter("precision") then
		settings.precision = tonumber(xml_node:parameter("precision"))
	else
		settings.precision = 0.005
	end

	if xml_node:has_parameter("max_velocity") then
		settings.max_velocity = tonumber(xml_node:parameter("max_velocity"))
	else
		settings.max_velocity = 300
	end
end

function CollisionCameraNode:update(t, dt, in_data, out_data)
	self:_update(t, dt, in_data, out_data)
	CollisionCameraNode.super.update(self, t, dt, in_data, out_data)
end

function CollisionCameraNode:_update_smoother(t, dt, in_data, out_data)
	local position = in_data._position
	local rotation = in_data._rotation
	local safe_position = self._safe_position
	local new_position = self._pop_controller:wanted_position(safe_position, position)
	self._local_position = (new_position - position):rotate_with(rotation:inverse())
end

function CollisionCameraNode:_update_fast_smooth(t, dt, in_data, out_data)
	local position = in_data._position
	local rotation = in_data._rotation
	local safe_position = self._safe_position
	safe_position = safe_position or position
	local camera_direction = position - safe_position
	local camera_distance = camera_direction:length()

	if camera_distance > 0 then
		camera_direction = camera_direction * 1 / camera_distance
		local fraction = self._pop_controller:wanted_position(safe_position, position)
		local collision_distance = fraction * camera_distance
		local new_distance = nil

		if collision_distance < self._camera_distance then
			new_distance = collision_distance
		else
			local diff = math.clamp(collision_distance - self._camera_distance, 0, self._camera_max_velocity * dt)
			new_distance = self._camera_distance + diff
		end

		local new_position = safe_position + (position - safe_position):normalized() * new_distance
		self._camera_distance = new_distance
		self._local_position = (new_position - position):rotate_with(rotation:inverse())
	else
		self._local_position = Vector3(0, 0, 0)
	end
end

function CollisionCameraNode:debug_render(t, dt)
	local safe_position = self._camera_data[self._safe_position_var]
	local brush = Draw:brush(Color(0.3, 1, 1, 1))

	brush:sphere(safe_position, 1)

	local brush2 = Draw:brush(Color(0.3, 1, 0, 0))

	brush2:sphere(self._position, 1)
end
