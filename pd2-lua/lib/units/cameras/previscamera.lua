PrevisCamera = PrevisCamera or class()

function PrevisCamera:init(unit)
	self._unit = unit
	self._camera = World:create_camera()

	self._camera:set_fov(57)
	self._camera:set_near_range(7.5)
	self._camera:set_far_range(200000)

	self._viewport = managers.viewport:new_vp(0, 0, 1, 1, "previscamera", CoreManagerBase.PRIO_WORLDCAMERA)
	self._director = self._viewport:director()
	self._shaker = self._director:shaker()
	self._camera_controller = self._director:make_camera(self._camera, Idstring("previs_camera"))

	self._viewport:set_camera(self._camera)
	self._director:set_camera(self._camera_controller)
	self._director:position_as(self._camera)
	self._camera_controller:set_both(self._unit:get_object(Idstring("g_camera")) or self._unit:get_object(Idstring("g_camtest")))
end

function PrevisCamera:start()
	if game_state_machine:current_state_name() ~= "editor" then
		self._old_game_state_name = game_state_machine:current_state_name()
	end

	game_state_machine:change_state_by_name("world_camera")

	self._playing = true

	self._unit:anim_set_time(Idstring("camera_animation"), 0)
	self._unit:anim_play_to(Idstring("camera_animation"), self._unit:anim_length(Idstring("camera_animation")), 1)
	self._viewport:set_active(true)
end

function PrevisCamera:stop()
	self._viewport:set_active(false)
	self._unit:anim_stop(Idstring("camera_animation"))
	self._unit:anim_set_time(Idstring("camera_animation"), 0)

	if self._old_game_state_name then
		game_state_machine:change_state_by_name(self._old_game_state_name)

		self._old_game_state_name = nil
	end

	self._playing = false
end

function PrevisCamera:update(unit, t, dt)
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

function PrevisCamera:destroy()
	if self._viewport then
		self._viewport:destroy()

		self._viewport = nil
	end

	if alive(self._camera) then
		World:delete_camera(self._camera)

		self._camera = nil
	end
end
