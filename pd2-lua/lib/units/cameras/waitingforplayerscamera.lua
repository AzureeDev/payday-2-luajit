WaitingForPlayersCamera = WaitingForPlayersCamera or class()

function WaitingForPlayersCamera:init(unit)
	self._unit = unit
	self._camera = World:create_camera()

	self._camera:set_fov(57)
	self._camera:set_near_range(7.5)
	self._camera:set_far_range(200000)

	self._viewport = managers.viewport:new_vp(0, 0.25, 1, 0.5, "WaitingForPlayersCamera", CoreManagerBase.PRIO_WORLDCAMERA)
	self._director = self._viewport:director()
	self._shaker = self._director:shaker()
	self._camera_controller = self._director:make_camera(self._camera, Idstring("previs_camera"))

	self._viewport:set_camera(self._camera)
	self._director:set_camera(self._camera_controller)
	self._director:position_as(self._camera)
	self._camera_controller:set_both(self._unit:get_object(Idstring("a_camera")))
end

function WaitingForPlayersCamera:_setup_sound_listener()
	self._listener_id = managers.listener:add_listener("wait_camera", self._camera, self._camera, nil, false)

	managers.listener:add_set("wait_camera", {
		"wait_camera"
	})

	self._listener_activation_id = managers.listener:activate_set("main", "wait_camera")
	self._sound_check_object = managers.sound_environment:add_check_object({
		primary = true,
		active = true,
		object = self._unit:orientation_object()
	})
end

function WaitingForPlayersCamera:start(time)
	if _G.IS_VR then
		return
	end

	self._playing = true

	self._unit:anim_stop(Idstring("camera_animation"))
	self._unit:anim_set_time(Idstring("camera_animation"), time or 0)
	self._unit:anim_play(Idstring("camera_animation"), 1)
	self._viewport:set_active(true)
end

function WaitingForPlayersCamera:stop()
	self._viewport:set_active(false)
	self._unit:anim_stop(Idstring("camera_animation"))
	self._unit:anim_set_time(Idstring("camera_animation"), 0)

	self._playing = false
end

function WaitingForPlayersCamera:update(unit, t, dt)
	if self._playing then
		if self._wait_t then
			if self._wait_t < t then
				self._wait_t = nil

				self:stop()
			end
		elseif not self._unit:anim_is_playing(Idstring("camera_animation")) then
			self._wait_t = t + 4
		end
	end
end

function WaitingForPlayersCamera:destroy()
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
		managers.listener:remove_set("wait_camera")

		self._listener_id = nil
	end
end
