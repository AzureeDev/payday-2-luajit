CubeMapCreator = CubeMapCreator or class()

function CubeMapCreator:init()
	self._camera = World:create_camera()
	self._vp = Application:create_world_viewport(0, 0, 1, 1)

	self._vp:set_camera(self._camera)
	self._camera:set_fov(90)
	self._camera:set_aspect_ratio(1)
	self._camera:set_near_range(20)
	self._camera:set_far_range(100000)

	self._creating_cube_map = false
end

function CubeMapCreator:destroy()
	if self._vp then
		Application:destroy_viewport(self._vp)

		self._vp = nil
	end
end

function CubeMapCreator:set_camera_rot(rot)
	local yaw = rot:yaw()
	local pitch = rot:pitch()

	self._camera:set_rotation(Rotation(yaw, pitch, 0))
end

function CubeMapCreator:render()
	if self._creating_cube_map then
		self._creating_cube_map = false

		self:create_cube_map()
	end
end

function CubeMapCreator:start_cube_map(pos)
	self._camera:set_position(pos)

	self._creating_cube_map = true
end

function CubeMapCreator:create_cube_map()
	local ypos = Application:create_texture("render_target", 512, 512)
	local xneg = Application:create_texture("render_target", 512, 512)
	local yneg = Application:create_texture("render_target", 512, 512)
	local xpos = Application:create_texture("render_target", 512, 512)
	local zpos = Application:create_texture("render_target", 512, 512)
	local zneg = Application:create_texture("render_target", 512, 512)

	self:set_camera_rot(Rotation(Vector3(0, 1, 0), Vector3(0, 0, 1)))
	Application:render("World", self._vp, ypos)
	self:set_camera_rot(Rotation(Vector3(-1, 0, 0), Vector3(0, 0, 1)))
	Application:render("World", self._vp, xneg)
	self:set_camera_rot(Rotation(Vector3(0, -1, 0), Vector3(0, 0, 1)))
	Application:render("World", self._vp, yneg)
	self:set_camera_rot(Rotation(Vector3(1, 0, 0), Vector3(0, 0, 1)))
	Application:render("World", self._vp, xpos)
	self:set_camera_rot(Rotation(Vector3(0, 0, 1), Vector3(1, 0, 0)))
	Application:render("World", self._vp, zpos)
	self:set_camera_rot(Rotation(Vector3(0, 0, -1), Vector3(1, 0, 0)))
	Application:render("World", self._vp, zneg)
end
