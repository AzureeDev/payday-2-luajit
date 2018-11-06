FFCEditorController = FFCEditorController or class()

function FFCEditorController:init(cam, controller)
	self._controller = controller
	self._camera = cam
	self._move_speed = 5000
	self._turn_speed = 150
	self._pitch = cam:rotation():pitch()
	self._yaw = cam:rotation():yaw()
	self._lock_pos = false
	self._cube_counter = 1
	self._creating_cube_map = false
	self._mul = 112
end

function FFCEditorController:update(time, rel_time)
	if self._camera then
		if self._creating_cube_map then
			self:create_cube_map()

			return
		end

		self:_draw_frustum_freeze(time, rel_time)

		local speed = self._move_speed * rel_time
		local turn_speed = self._turn_speed * 0.001
		local altitude = Vector3(0, 0, speed * (self._controller:button(Idstring("altitude_up")) - self._controller:button(Idstring("altitude_down"))))
		local mov_x = (self._controller:button(Idstring("go_right")) - self._controller:button(Idstring("go_left"))) * speed
		local mov_y = (self._controller:button(Idstring("forward")) - self._controller:button(Idstring("backward"))) * speed
		local move = self._camera:rotation():x() * mov_x + self._camera:rotation():y() * mov_y
		self._pitch = math.clamp(self._pitch + turn_speed * -self._controller:axis(Idstring("look")).y, -90, 90)
		self._yaw = self._yaw + turn_speed * -self._controller:axis(Idstring("look")).x

		if self._controller:has_axis(Idstring("look_gamepad")) then
			local x = self._controller:axis(Idstring("look_gamepad")).x
			local y = self._controller:axis(Idstring("look_gamepad")).y

			if math.abs(y) < 0.1 then
				y = 0
			end

			if math.abs(x) < 0.1 then
				x = 0
			end

			self._pitch = math.clamp(self._pitch + 10 * turn_speed * -y, -90, 90)
			self._yaw = self._yaw + 10 * turn_speed * -x
		end

		if self._controller:button(Idstring("plane_switch")) ~= 0 then
			move = Vector3(move.x, move.y, 0)
		end

		self._camera:set_position(self._camera:position() + move + altitude)
		self._camera:set_rotation(Rotation(self._yaw, self._pitch, 0))
	end
end

function FFCEditorController:update_locked(time, rel_time)
	self:_draw_frustum_freeze(time, rel_time)
end

function FFCEditorController:_draw_frustum_freeze(time, rel_time)
	if not self._frustum_frozen then
		return
	end

	local near = self._frozen_camera:near_range()
	local far = self._frozen_camera:far_range()
	local R = 1
	local G = 0
	local B = 1
	local n1 = self._frozen_camera:screen_to_world(Vector3(-1, -1, near))
	local n2 = self._frozen_camera:screen_to_world(Vector3(1, -1, near))
	local n3 = self._frozen_camera:screen_to_world(Vector3(1, 1, near))
	local n4 = self._frozen_camera:screen_to_world(Vector3(-1, 1, near))
	local f1 = self._frozen_camera:screen_to_world(Vector3(-1, -1, far))
	local f2 = self._frozen_camera:screen_to_world(Vector3(1, -1, far))
	local f3 = self._frozen_camera:screen_to_world(Vector3(1, 1, far))
	local f4 = self._frozen_camera:screen_to_world(Vector3(-1, 1, far))

	Application:draw_line(n1, n2, R, G, B)
	Application:draw_line(n2, n3, R, G, B)
	Application:draw_line(n3, n4, R, G, B)
	Application:draw_line(n4, n1, R, G, B)
	Application:draw_line(n1, f1, R, G, B)
	Application:draw_line(n2, f2, R, G, B)
	Application:draw_line(n3, f3, R, G, B)
	Application:draw_line(n4, f4, R, G, B)
	Application:draw_line(f1, f2, R, G, B)
	Application:draw_line(f2, f3, R, G, B)
	Application:draw_line(f3, f4, R, G, B)
	Application:draw_line(f4, f1, R, G, B)
end

function FFCEditorController:set_camera(cam)
	self._camera = cam
end

function FFCEditorController:set_camera_pos(pos)
	self._camera:set_position(pos)
end

function FFCEditorController:set_camera_rot(rot)
	self._yaw = rot:yaw()
	self._pitch = rot:pitch()

	self._camera:set_rotation(Rotation(self._yaw, self._pitch, rot:roll()))
end

function FFCEditorController:set_camera_roll(roll)
	local rot = Rotation(self._camera:rotation():y(), roll)

	self._camera:set_rotation(Rotation(self._camera:rotation():y(), rot:z()))
end

function FFCEditorController:set_controller(c)
	self._controller = c
end

function FFCEditorController:set_move_speed(speed)
	self._move_speed = speed
end

function FFCEditorController:set_turn_speed(t_speed)
	self._turn_speed = t_speed
end

function FFCEditorController:set_fov(fov)
	self._camera:set_fov(fov)
end

function FFCEditorController:get_camera_pos()
	return self._camera:position()
end

function FFCEditorController:get_camera_rot()
	return self._camera:rotation()
end

function FFCEditorController:get_move_speed()
	return self._move_speed
end

function FFCEditorController:get_turn_speed()
	return self._turn_speed
end

function FFCEditorController:frustum_freeze(camera)
	self._frustum_frozen = true
	local old_cam = camera
	local new_cam = World:create_camera()

	new_cam:set_fov(old_cam:fov())
	new_cam:set_position(old_cam:position())
	new_cam:set_rotation(old_cam:rotation())
	new_cam:set_far_range(old_cam:far_range())
	new_cam:set_near_range(old_cam:near_range())
	new_cam:set_aspect_ratio(old_cam:aspect_ratio())
	new_cam:set_width_multiplier(old_cam:width_multiplier())
	self:set_camera(new_cam)
	Application:set_frustum_freeze_camera(old_cam, new_cam)

	self._frozen_camera = old_cam
end

function FFCEditorController:frustum_unfreeze(camera)
	self._frustum_frozen = false
	local old_cam = camera

	old_cam:set_position(self._camera:position())
	old_cam:set_rotation(self._camera:rotation())
	Application:set_frustum_freeze_camera(old_cam, old_cam)
	self:set_camera(old_cam)

	self._frozen_camera = nil
end

function FFCEditorController:frustum_frozen()
	return self._frustum_frozen
end

function FFCEditorController:start_cube_map(params)
	self._params = params
	self._cubemap_name = params.name or ""
	self._simple_postfix = params.simple_postfix
	self._output_name = params.output_name
	self._output_name = self._output_name or "cubemap"

	if params.light then
		self._light = World:create_light("omni")

		self._light:set_position(params.light:position())
		self._light:set_near_range(params.light:near_range())
		self._light:set_far_range(params.light:far_range())
		self._light:set_color(Vector3(1, 1, 1))

		if self._params.spot then
			local rot = Rotation(self._params.unit:rotation():z(), Vector3(0, 0, 1))
			rot = Rotation(-rot:z(), rot:y())

			self._params.unit:set_rotation(rot)
		end
	end

	self._camera:set_fov(self._params.spot and self._params.light:spot_angle_end() or 90)

	self._cube_counter = 0
	self._wait_frames = 5
	self._creating_cube_map = true
	self._cube_map_done_func = params.done_callback
	self._names = {}

	table.insert(self._names, self._cubemap_name .. (self._simple_postfix and "6.tga" or "_6(zpos).tga"))
	table.insert(self._names, self._cubemap_name .. (self._simple_postfix and "1.tga" or "_1(xneg).tga"))
	table.insert(self._names, self._cubemap_name .. (self._simple_postfix and "4.tga" or "_4(ypos).tga"))
	table.insert(self._names, self._cubemap_name .. (self._simple_postfix and "2.tga" or "_2(xpos).tga"))
	table.insert(self._names, self._cubemap_name .. (self._simple_postfix and "3.tga" or "_3(yneg).tga"))
	table.insert(self._names, self._cubemap_name .. (self._simple_postfix and "5.tga" or "_5(zneg).tga"))

	self._name_ordered = {}

	table.insert(self._name_ordered, self._names[2])
	table.insert(self._name_ordered, self._names[4])
	table.insert(self._name_ordered, self._names[5])
	table.insert(self._name_ordered, self._names[3])
	table.insert(self._name_ordered, self._names[6])
	table.insert(self._name_ordered, self._names[1])
end

function FFCEditorController:creating_cube_map()
	return self._creating_cube_map
end

function FFCEditorController:create_cube_map()
	if self._wait_frames > 0 then
		self._wait_frames = self._wait_frames - 1

		return false
	end

	self._cube_counter = self._cube_counter + 1

	if self._params.spot then
		if self._cube_counter == 1 then
			self:_create_spot_projection()
		elseif self._cube_counter == 2 then
			self:_generate_spot_projection()
		else
			self:_cubemap_done()
		end

		return true
	end

	local x1, y1, x2, y2 = self:_get_screen_size()

	if self._cube_counter == 1 then
		self._camera:set_rotation(Rotation(Vector3(0, 0, 1), Vector3(0, -1, 0)))
	elseif self._cube_counter == 2 then
		self._camera:set_rotation(Rotation(Vector3(-1, 0, 0), Vector3(0, -1, 0)))
	elseif self._cube_counter == 3 then
		self._camera:set_rotation(Rotation(Vector3(0, 1, 0), Vector3(0, 0, -1)))
	elseif self._cube_counter == 4 then
		self._camera:set_rotation(Rotation(Vector3(1, 0, 0), Vector3(0, -1, 0)))
	elseif self._cube_counter == 5 then
		self._camera:set_rotation(Rotation(Vector3(0, -1, 0), Vector3(0, 0, 1)))
	elseif self._cube_counter == 6 then
		self._camera:set_rotation(Rotation(Vector3(0, 0, -1), Vector3(0, -1, 0)))
	elseif self._cube_counter == 7 then
		self:_generate_cubemap(self._params.light and "cubemap_light" or "cubemap_reflection")
		self:_cubemap_done()

		return true
	end

	local path = self._params.source_path or managers.database:root_path()

	Application:screenshot(path .. self._names[self._cube_counter], x1, y1, x2, y2)

	return false
end

function FFCEditorController:_cubemap_done()
	if alive(self._light) then
		World:delete_light(self._light)
	end

	self._creating_cube_map = nil

	if self._cube_map_done_func then
		self._cube_map_done_func()
	end
end

function FFCEditorController:_get_screen_size()
	local res = Application:screen_resolution()
	local diff = res.x - res.y
	local x1 = diff / 2
	local y1 = 0
	local x2 = res.x - diff / 2
	local y2 = res.y

	return x1, y1, x2, y2
end

function FFCEditorController:_create_spot_projection()
	local x1, y1, x2, y2 = self:_get_screen_size()

	self._camera:set_rotation(Rotation(-self._params.light:rotation():z(), Vector3(0, 0, 1)))

	local path = self._params.source_path or managers.database:root_path()

	Application:screenshot(path .. self._name_ordered[1], x1, y1, x2, y2)
end

function FFCEditorController:_generate_spot_projection()
	local execute = managers.database:root_path() .. "aux_assets/engine/tools/spotmapgen.bat "
	local path = self._params.source_path or managers.database:root_path()
	execute = execute .. path .. self._name_ordered[1] .. " "
	local output_path = (self._params.output_path or managers.database:root_path()) .. self._output_name .. ".dds "
	execute = execute .. output_path .. " "

	os.execute(execute)
	self:_add_meta_data((self._params.output_path or managers.database:root_path()) .. self._output_name .. ".dds", "diffuse_colormap_gradient_alpha_manual_mips")
end

function FFCEditorController:_generate_cubemap(file)
	local execute = managers.database:root_path() .. "aux_assets/engine/tools/" .. file .. ".bat "

	for i, _ in ipairs(self._names) do
		local path = self._params.source_path or managers.database:root_path()
		execute = execute .. path .. self._name_ordered[i] .. " "
	end

	local output_path = (self._params.output_path or managers.database:root_path()) .. self._output_name .. " "
	execute = execute .. output_path .. " "

	os.execute(execute)
	self:_add_meta_data((self._params.output_path or managers.database:root_path()) .. self._output_name .. ".dds", "diffuse_colormap_gradient_alpha_manual_mips")
end

function FFCEditorController:_add_meta_data(file, meta)
	local execute = managers.database:root_path() .. "aux_assets/engine/tools/diesel_dds_tagger.exe "
	execute = execute .. file .. " " .. meta

	os.execute(execute)
end

function FFCEditorController:update_orthographic(time, rel_time)
	local speed = self._move_speed * rel_time
	local mov_x = (self._controller:button(Idstring("go_right")) - self._controller:button(Idstring("go_left"))) * speed
	local mov_y = (self._controller:button(Idstring("forward")) - self._controller:button(Idstring("backward"))) * speed
	local move = Vector3(mov_x * 5, mov_y * 5, 0)

	self._camera:set_position(self._camera:position() + move)

	self._mul = self._mul + speed * (self._controller:button(Idstring("altitude_up")) - self._controller:button(Idstring("altitude_down"))) / 100

	self:set_orthographic_screen()
end

function FFCEditorController:set_orthographic_screen()
	local res = Application:screen_resolution()

	self._camera:set_orthographic_screen(-(res.x / 2) * self._mul, res.x / 2 * self._mul, -(res.y / 2) * self._mul, res.y / 2 * self._mul)
end

function FFCEditorController:toggle_orthographic(use)
	local camera = self._camera

	if use then
		self._camera_settings = {
			far_range = camera:far_range(),
			near_range = camera:near_range(),
			position = camera:position(),
			rotation = camera:rotation()
		}

		camera:set_projection_type(Idstring("orthographic"))
		self:set_orthographic_screen()
		camera:set_position(Vector3(0, 0, camera:position().z))
		camera:set_rotation(Rotation(math.DOWN, Vector3(0, 1, 0)))
		camera:set_far_range(75000)
	else
		camera:set_projection_type(Idstring("perspective"))
		camera:set_far_range(self._camera_settings.far_range)
		camera:set_near_range(self._camera_settings.near_range)
		camera:set_position(self._camera_settings.position)
		camera:set_rotation(self._camera_settings.rotation)
	end
end
