core:module("CoreCameraMixer")
core:import("CoreClass")

local mvector3_add = mvector3.add
local mvector3_sub = mvector3.subtract
local mvector3_mul = mvector3.multiply
local mvector3_set = mvector3.set
local mvector3_copy = mvector3.copy
local mrotation_mul = mrotation.multiply
local mrotation_slerp = mrotation.slerp
local mrotation_set_zero = mrotation.set_zero

local function safe_divide(a, b)
	if b == 0 then
		return 1
	end

	return a / b
end

CameraMixer = CameraMixer or CoreClass.class()

function CameraMixer:init(name)
	self._name = name
	self._cameras = {}
end

function CameraMixer:destroy()
	for index, camera in ipairs(self._cameras) do
		camera.camera:destroy()
	end

	self._cameras = {}
end

function CameraMixer:add_camera(camera, blend_time)
	table.insert(self._cameras, {
		time = 0,
		camera = camera,
		blend_time = blend_time
	})
end

function CameraMixer:stop()
	for index, camera in ipairs(self._cameras) do
		camera.camera:destroy()
	end

	self._cameras = {}
end

function CameraMixer:update(cud, cud_class, time, dt)
	for index, camera in ipairs(self._cameras) do
		local _camera = camera.camera
		local cam_data = cud_class:new(cud)

		for _, cam in ipairs(_camera._nodes) do
			local local_cam_data = cud_class:new()

			cam:update(time, dt, cam_data, local_cam_data)
			cam_data:transform_with(local_cam_data)
			mvector3_set(cam._position, cam_data._position)
			mrotation_set_zero(cam._rotation)
			mrotation_mul(cam._rotation, cam_data._rotation)
		end

		camera.cam_data = cam_data
	end

	local full_blend_index = 1

	for index, _camera in ipairs(self._cameras) do
		_camera.time = _camera.time + dt
		local factor = nil

		if index > 1 then
			factor = math.sin(math.clamp(safe_divide(_camera.time, _camera.blend_time), 0, 1) * 90)
		else
			factor = 1
		end

		cud:interpolate_to_target(_camera.cam_data, factor)

		if factor >= 1 then
			full_blend_index = index
		end
	end

	for i = 1, full_blend_index - 1 do
		self._cameras[1].camera:destroy()
		table.remove(self._cameras, 1)
	end

	for index, camera in ipairs(self._cameras) do
		assert(not camera.camera._destroyed)
	end
end

function CameraMixer:debug_render(t, dt)
	local pen = Draw:pen(Color(0.05, 0, 0, 1))

	for _, camera in ipairs(self._cameras) do
		local cam = camera.camera
		local parent_node = nil

		for _, node in ipairs(cam._nodes) do
			node:debug_render(t, dt)

			if parent_node then
				pen:line(parent_node._position, node._position)
			end

			parent_node = node
		end
	end
end

function CameraMixer:active_camera()
	local camera_count = #self._cameras

	if camera_count == 0 then
		return nil
	end

	return self._cameras[camera_count].camera
end

function CameraMixer:cameras()
	local cameras = {}

	for _, camera in ipairs(self._cameras) do
		table.insert(cameras, camera.camera)
	end

	return cameras
end
