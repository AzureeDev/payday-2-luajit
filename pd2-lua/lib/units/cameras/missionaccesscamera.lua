MissionAccessCamera = MissionAccessCamera or class()

function MissionAccessCamera:init(unit)
	self._unit = unit
	self._camera = World:create_camera()
	self._default_fov = 75
	self._fov = self._default_fov

	self._camera:set_fov(self._default_fov)
	self._camera:set_near_range(15)
	self._camera:set_far_range(250000)

	local scale_x = 1
	local scale_y = 1

	if _G.IS_VR then
		local rt_resolution = managers.menu:player():render_target_resolution()
		local resolution = VRManager:target_resolution()
		scale_x = rt_resolution.x / resolution.x
		scale_y = rt_resolution.y / resolution.y
	end

	self._viewport = managers.viewport:new_vp(0, 0, scale_x, scale_y, "MissionAccessCamera", CoreManagerBase.PRIO_WORLDCAMERA)
	self._director = self._viewport:director()
	self._shaker = self._director:shaker()
	self._camera_controller = self._director:make_camera(self._camera, Idstring("previs_camera"))

	self._viewport:set_camera(self._camera)
	self._director:set_camera(self._camera_controller)
	self._director:position_as(self._camera)
	self._camera_controller:set_both(self._unit)

	if _G.IS_VR then
		self._camera:set_aspect_ratio(1.7777777777777777)
		self._camera:set_stereo(false)
		self._viewport:set_enable_adaptive_quality(false)
		managers.viewport:move_to_front(self._viewport)
	end
end

function MissionAccessCamera:_setup_sound_listener()
	self._listener_id = managers.listener:add_listener("access_camera", self._camera, self._camera, nil, false)

	managers.listener:add_set("access_camera", {
		"access_camera"
	})

	self._listener_activation_id = managers.listener:activate_set("main", "access_camera")
	self._sound_check_object = managers.sound_environment:add_check_object({
		primary = true,
		active = true,
		object = self._unit:orientation_object()
	})
end

function MissionAccessCamera:set_rotation(rotation)
	self._original_rotation = rotation

	self._unit:set_rotation(rotation)
end

function MissionAccessCamera:get_original_rotation()
	return self._original_rotation
end

function MissionAccessCamera:get_offset_rotation()
	return self._offset_rotation
end

function MissionAccessCamera:start(time)
	self._playing = true

	self._unit:anim_stop(Idstring("camera_animation"))

	self._fov = self._default_fov

	self._viewport:set_active(true)
end

function MissionAccessCamera:stop()
	self._viewport:set_active(false)
	self._unit:anim_stop(Idstring("camera_animation"))
	self._unit:anim_set_time(Idstring("camera_animation"), 0)

	self._playing = false
end

function MissionAccessCamera:set_destroyed(destroyed)
end

function MissionAccessCamera:modify_fov(fov)
	self._fov = math.clamp(self._fov + fov, 25, 75)

	self._camera:set_fov(self._fov)
end

function MissionAccessCamera:zoomed_value()
	return self._fov / self._default_fov
end

function MissionAccessCamera:set_offset_rotation(yaw, pitch, roll)
	self._offset_rotation = self._offset_rotation or Rotation()
	yaw = yaw + mrotation.yaw(self._original_rotation)
	pitch = pitch + mrotation.pitch(self._original_rotation)

	mrotation.set_yaw_pitch_roll(self._offset_rotation, yaw, pitch, roll)
	self._unit:set_rotation(self._offset_rotation)
end

function MissionAccessCamera:destroy()
	if self._viewport then
		self._viewport:destroy()

		self._viewport = nil
	end

	if alive(self._camera) then
		World:delete_camera(self._camera)

		self._camera = nil
	end

	if self._listener_id then
		managers.sound_environment:remove_check_object(self._sound_check_object)
		managers.listener:remove_listener(self._listener_id)
		managers.listener:remove_set("access_camera")

		self._listener_id = nil
	end
end
