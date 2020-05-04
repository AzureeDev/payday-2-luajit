core:import("CoreManagerBase")

CoreWorldCameraManager = CoreWorldCameraManager or class()

function CoreWorldCameraManager:init()
	self._camera = World:create_camera()

	self:set_default_fov(75)
	self:set_fov(self._default_fov)
	self:set_default_dof(150, 10000)

	self._current_near_dof = self._default_near_dof
	self._current_far_dof = self._default_far_dof
	self._default_dof_padding = 100
	self._current_dof_padding = self._default_dof_padding
	self._default_dof_clamp = 1
	self._current_dof_clamp = self._default_dof_clamp

	self:set_dof(self._default_near_dof, self._default_far_dof)
	self._camera:set_near_range(7.5)
	self._camera:set_far_range(200000)

	self._viewport = managers.viewport:new_vp(0, 0, 1, 1, "worldcamera", CoreManagerBase.PRIO_WORLDCAMERA)
	self._director = self._viewport:director()
	self._shaker = self._director:shaker()
	self._camera_controller = self._director:make_camera(self._camera, Idstring("world_camera"))

	self._viewport:set_camera(self._camera)
	self._director:set_camera(self._camera_controller)
	self._director:position_as(self._camera)
	self:_create_listener()

	self._use_gui = false
	self._workspace = Overlay:newgui():create_screen_workspace(0, 0, 1, 1)
	self._gui = self._workspace:panel():gui(Idstring("core/guis/core_world_camera"))
	self._gui_visible = nil

	self:_set_gui_visible(false)
	self:_clear_callback_lists()
	self:_set_dof_effect()
	self:clear()
end

function CoreWorldCameraManager:use_gui()
	return self._use_gui
end

function CoreWorldCameraManager:_create_listener()
	self._listener_id = managers.listener:add_listener("world_camera", self._camera)
	self._listener_activation_id = nil

	managers.listener:add_set("world_camera", {
		"world_camera"
	})
end

function CoreWorldCameraManager:set_default_fov(default_fov)
	self._default_fov = default_fov
end

function CoreWorldCameraManager:default_fov()
	return self._default_fov
end

function CoreWorldCameraManager:set_fov(fov)
	self._camera:set_fov(fov)
end

function CoreWorldCameraManager:set_default_dof(near_dof, far_dof)
	self._default_near_dof = near_dof
	self._default_far_dof = far_dof
end

function CoreWorldCameraManager:default_near_dof()
	return self._default_near_dof
end

function CoreWorldCameraManager:default_far_dof()
	return self._default_far_dof
end

function CoreWorldCameraManager:set_dof(dof)
end

function CoreWorldCameraManager:default_dof_padding()
	return self._default_dof_padding
end

function CoreWorldCameraManager:default_dof_clamp()
	return self._default_dof_clamp
end

function CoreWorldCameraManager:_set_dof_effect()
	self._dof = {
		update_callback = "update_world_camera",
		near_min = self:default_near_dof(),
		near_max = self:default_near_dof(),
		far_min = self:default_far_dof(),
		far_max = self:default_far_dof(),
		clamp = 1,
		prio = 1,
		name = "world_camera",
		fade_in = 0,
		fade_out = 0
	}
end

function CoreWorldCameraManager:destroy()
	self:_destroy_listener()

	if self._viewport then
		self._viewport:destroy()

		self._viewport = nil
	end

	if alive(self._workspace) then
		Overlay:newgui():destroy_workspace(self._workspace)

		self._workspace = nil
	end

	if alive(self._camera) then
		World:delete_camera(self._camera)

		self._camera = nil
	end
end

function CoreWorldCameraManager:_destroy_listener()
	if self._listener_id then
		managers.listener:remove_listener(self._listener_id)
		managers.listener:remove_set("world_camera")

		self._listener_id = nil
	end
end

function CoreWorldCameraManager:stop_simulation()
	self:_clear_callback_lists()
	self:stop_world_camera()
end

function CoreWorldCameraManager:_clear_callback_lists()
	self._last_world_camera_done_callback_id = {}
	self._world_camera_done_callback_list = {}
	self._last_sequence_done_callback_id = {}
	self._sequence_done_callback_list = {}
	self._last_sequence_camera_clip_callback_id = {}
	self._sequence_camera_clip_callback_list = {}
end

function CoreWorldCameraManager:clear()
	self._world_cameras = {}
	self._world_camera_sequences = {}
	self._current_world_camera = nil
end

function CoreWorldCameraManager:current_world_camera()
	return self._current_world_camera
end

function CoreWorldCameraManager:save(file)
	local worldcameras = {}

	for name, world_camera in pairs(self._world_cameras) do
		worldcameras[name] = world_camera:save_data_table()
	end

	local camera_data = {
		worldcameras = worldcameras,
		sequences = self._world_camera_sequences
	}

	file:puts(ScriptSerializer:to_generic_xml(camera_data))
end

function CoreWorldCameraManager:load(param)
	if not self:_old_load(param) then
		if not param.worldcameras then
			Application:error("Can't load world cameras, it is in new format but probably loaded from old level")

			return
		end

		for name, camera_data in pairs(param.worldcameras) do
			self._world_cameras[name] = (rawget(_G, "WorldCamera") or rawget(_G, "CoreWorldCamera")):new(name)

			self._world_cameras[name]:load(camera_data)
		end

		self._world_camera_sequences = param.sequences
	end
end

function CoreWorldCameraManager:_old_load(path)
	if type_name(path) ~= "string" then
		return false
	end

	local path = managers.database:entry_expanded_path("world_cameras", path)
	local node = SystemFS:parse_xml(path)

	if node:name() ~= "world_cameras" then
		return false
	end

	for child in node:children() do
		if child:name() == "world_camera" then
			local world_camera_name = child:parameter("name")
			self._world_cameras[world_camera_name] = (rawget(_G, "WorldCamera") or rawget(_G, "CoreWorldCamera")):new(world_camera_name)

			self._world_cameras[world_camera_name]:old_load(child)
		else
			local name, value = parse_value_node(child)
			self[name] = value
		end
	end

	return true
end

function CoreWorldCameraManager:update(t, dt)
	if self._current_world_camera then
		self._current_world_camera:update(t, dt)
	end
end

function CoreWorldCameraManager:_set_gui_visible(visible)
	if self._gui_visible ~= visible then
		if visible and self._use_gui then
			self._workspace:show()
		else
			self._workspace:hide()
		end

		self._gui_visible = visible
	end
end

function CoreWorldCameraManager:add_world_camera_done_callback(world_camera_name, func)
	self._last_world_camera_done_callback_id[world_camera_name] = self._last_world_camera_done_callback_id[world_camera_name] or 0
	self._last_world_camera_done_callback_id[world_camera_name] = self._last_world_camera_done_callback_id[world_camera_name] + 1
	self._world_camera_done_callback_list[world_camera_name] = self._world_camera_done_callback_list[world_camera_name] or {}
	self._world_camera_done_callback_list[world_camera_name][self._last_world_camera_done_callback_id[world_camera_name]] = func

	return self._last_world_camera_done_callback_id[world_camera_name]
end

function CoreWorldCameraManager:remove_world_camera_done_callback(world_camera_name, id)
	self._world_camera_done_callback_list[world_camera_name][id] = nil
end

function CoreWorldCameraManager:add_sequence_done_callback(sequence_name, func)
	self._last_sequence_done_callback_id[sequence_name] = self._last_sequence_done_callback_id[sequence_name] or 0
	self._last_sequence_done_callback_id[sequence_name] = self._last_sequence_done_callback_id[sequence_name] + 1
	self._sequence_done_callback_list[sequence_name] = self._sequence_done_callback_list[sequence_name] or {}
	self._sequence_done_callback_list[sequence_name][self._last_sequence_done_callback_id[sequence_name]] = func

	return self._last_sequence_done_callback_id[sequence_name]
end

function CoreWorldCameraManager:remove_sequence_done_callback(sequence_name, id)
	self._sequence_done_callback_list[sequence_name][id] = nil
end

function CoreWorldCameraManager:add_sequence_camera_clip_callback(sequence_name, clip, func)
	self._last_sequence_camera_clip_callback_id[sequence_name] = self._last_sequence_camera_clip_callback_id[sequence_name] or 0
	self._last_sequence_camera_clip_callback_id[sequence_name] = self._last_sequence_camera_clip_callback_id[sequence_name] + 1
	self._sequence_camera_clip_callback_list[sequence_name] = self._sequence_camera_clip_callback_list[sequence_name] or {}
	self._sequence_camera_clip_callback_list[sequence_name][clip] = self._sequence_camera_clip_callback_list[sequence_name][clip] or {}
	self._sequence_camera_clip_callback_list[sequence_name][clip][self._last_sequence_camera_clip_callback_id[sequence_name]] = func

	return self._last_sequence_camera_clip_callback_id[sequence_name]
end

function CoreWorldCameraManager:remove_sequence_camera_clip_callback(sequence_name, clip, id)
	self._sequence_camera_clip_callback_list[sequence_name][clip][id] = nil
end

function CoreWorldCameraManager:create_world_camera(world_camera_name)
	self._world_cameras[world_camera_name] = (rawget(_G, "WorldCamera") or rawget(_G, "CoreWorldCamera")):new(world_camera_name)

	return self._world_cameras[world_camera_name]
end

function CoreWorldCameraManager:remove_world_camera(world_camera_name)
	self._world_cameras[world_camera_name] = nil
end

function CoreWorldCameraManager:all_world_cameras()
	return self._world_cameras
end

function CoreWorldCameraManager:world_camera(world_camera)
	return self._world_cameras[world_camera]
end

function CoreWorldCameraManager:play_world_camera(world_camera_name)
	local s = {
		self:_camera_sequence_table(world_camera_name)
	}

	self:play_world_camera_sequence(nil, s)
end

function CoreWorldCameraManager:new_play_world_camera(world_camera_sequence)
	local world_camera = self._world_cameras[world_camera_sequence.name]

	if world_camera then
		if self._current_world_camera then
			self._current_world_camera:stop()
		end

		self._current_world_camera = world_camera
		local ok, msg = self._current_world_camera:play(world_camera_sequence)

		if not ok then
			if Application:editor() then
				managers.editor:output_error(msg)
			end

			self:stop_world_camera()

			return
		end
	else
		Application:error("WorldCamera named", world_camera_sequence.name, "did not exist.")
	end
end

function CoreWorldCameraManager:stop_world_camera()
	if not self._current_world_camera then
		return
	end

	local stop_camera = self._current_world_camera

	stop_camera:stop()

	if self._current_sequence then
		if self._sequence_camera_clip_callback_list[self._current_sequence_name] and self._sequence_camera_clip_callback_list[self._current_sequence_name][self._sequence_index] then
			for id, func in pairs(self._sequence_camera_clip_callback_list[self._current_sequence_name][self._sequence_index]) do
				self:remove_sequence_camera_clip_callback(self._current_sequence_name, self._sequence_index, id)
				func(self._current_sequence_name, self._sequence_index, id)
			end
		end

		if self._sequence_index < #self._current_sequence then
			self._sequence_index = self._sequence_index + 1

			self:new_play_world_camera(self._current_sequence[self._sequence_index])
		else
			self._current_world_camera = nil

			self:_sequence_done()
		end
	end

	if self._world_camera_done_callback_list[stop_camera:name()] then
		for id, func in pairs(self._world_camera_done_callback_list[stop_camera:name()]) do
			self:remove_world_camera_done_callback(stop_camera:name(), id)
			func(stop_camera, id)
		end
	end
end

function CoreWorldCameraManager:create_world_camera_sequence(name)
	self._world_camera_sequences[name] = {}

	return self._world_camera_sequences[name]
end

function CoreWorldCameraManager:remove_world_camera_sequence(name)
	self._world_camera_sequences[name] = nil
end

function CoreWorldCameraManager:all_world_camera_sequences()
	return self._world_camera_sequences
end

function CoreWorldCameraManager:world_camera_sequence(name)
	return self._world_camera_sequences[name]
end

function CoreWorldCameraManager:add_camera_to_sequence(name, c_name)
	local sequence = self._world_camera_sequences[name]

	if not sequence then
		Application:error("World camera sequence named", name, "did not exist.")

		return
	end

	table.insert(sequence, self:_camera_sequence_table(c_name))

	return #sequence
end

function CoreWorldCameraManager:insert_camera_to_sequence(name, camera_sequence_table, index)
	local sequence = self._world_camera_sequences[name]

	if not sequence then
		Application:error("World camera sequence named", name, "did not exist.")

		return
	end

	table.insert(sequence, index, camera_sequence_table)

	return #sequence
end

function CoreWorldCameraManager:remove_camera_from_sequence(name, index)
	local sequence = self._world_camera_sequences[name]
	local camera_sequence_table = sequence[index]

	table.remove(sequence, index)

	return camera_sequence_table
end

function CoreWorldCameraManager:_camera_sequence_table(name)
	local t = {
		name = name,
		start = 0,
		stop = 1
	}

	return t
end

function CoreWorldCameraManager:_break_sequence()
	if self._current_sequence then
		self:_sequence_done()
	end
end

function CoreWorldCameraManager:_sequence_done()
	self:_set_listener_enabled(false)
	self:_reset_old_viewports()
	self:stop_dof()
	self:_set_gui_visible(false)
	managers.sound_environment:set_check_object_active(self._sound_environment_check_object, false)

	local done_sequence = self._current_sequence
	local done_sequence_name = self._current_sequence_name
	self._current_sequence = nil
	self._current_sequence_name = nil

	if self._sequence_done_callback_list[done_sequence_name] then
		for id, func in pairs(self._sequence_done_callback_list[done_sequence_name]) do
			self:remove_sequence_done_callback(done_sequence_name, id)
			func(done_sequence, id)
		end
	end

	if self._old_game_state_name then
		game_state_machine:change_state_by_name(self._old_game_state_name)

		self._old_game_state_name = nil
	end
end

function CoreWorldCameraManager:play_world_camera_sequence(name, sequence)
	if game_state_machine:current_state_name() ~= "editor" then
		self._old_game_state_name = game_state_machine:current_state_name()
	end

	game_state_machine:change_state_by_name("world_camera")
	self:_break_sequence()

	local sequence = self._world_camera_sequences[name] or sequence

	if not sequence then
		Application:error("World camera sequence named", name, "did not exist.")

		return
	end

	if #sequence == 0 then
		Application:error("World camera sequence named", name, "did not have any cameras.")

		return
	end

	self._current_sequence = sequence
	self._current_sequence_name = name

	if not self._sound_environment_check_object then
		self._sound_environment_check_object = managers.sound_environment:add_check_object({
			primary = true,
			active = false,
			object = self._camera
		})
	end

	managers.sound_environment:set_check_object_active(self._sound_environment_check_object, true)
	self:_use_vp()
	self:_set_gui_visible(true)
	self:_set_listener_enabled(true)

	self._sequence_index = 1

	self:new_play_world_camera(self._current_sequence[self._sequence_index])
end

function CoreWorldCameraManager:_use_vp()
	self:viewport():set_active(true)
end

function CoreWorldCameraManager:_reset_old_viewports()
	self:viewport():set_active(false)
end

function CoreWorldCameraManager:_set_listener_enabled(enabled)
	if enabled then
		if not self._listener_activation_id then
			self._listener_activation_id = managers.listener:activate_set("main", "world_camera")
		end
	elseif self._listener_activation_id then
		managers.listener:deactivate_set(self._listener_activation_id)

		self._listener_activation_id = nil
	end
end

function CoreWorldCameraManager:start_dof()
	if not self._using_dof then
		self._using_dof = true
		self._dof_effect_id = managers.DOF:play(self._dof)
	end
end

function CoreWorldCameraManager:stop_dof()
	managers.DOF:stop(self._dof_effect_id)

	self._dof_effect_id = nil
	self._using_dof = false
end

function CoreWorldCameraManager:using_dof()
	return self._using_dof
end

function CoreWorldCameraManager:update_dof_values(near_dof, far_dof, dof_padding, dof_clamp)
	self._current_near_dof = near_dof
	self._current_far_dof = far_dof
	self._current_dof_padding = dof_padding
	self._current_dof_clamp = dof_clamp

	managers.DOF:set_effect_parameters(self._dof_effect_id, {
		near_min = near_dof,
		near_max = near_dof - dof_padding,
		far_min = far_dof,
		far_max = far_dof + dof_padding
	}, dof_clamp)
end

function CoreWorldCameraManager:viewport()
	return self._viewport
end

function CoreWorldCameraManager:director()
	return self._director
end

function CoreWorldCameraManager:workspace()
	return self._workspace
end

function CoreWorldCameraManager:camera()
	return self._camera
end

function CoreWorldCameraManager:camera_controller()
	return self._camera_controller
end

CoreWorldCamera = CoreWorldCamera or class()

function CoreWorldCamera:init(world_camera_name)
	self._world_camera_name = world_camera_name
	self._points = {}
	self._positions = {}
	self._target_positions = {}
	self._duration = 2.5
	self._delay = 0
	self._playing = false
	self._target_offset = 1000
	self._in_accelerations = {}
	self._out_accelerations = {}
	self._in_accelerations.linear = 0.33
	self._out_accelerations.linear = 0.66
	self._in_accelerations.ease = 0
	self._out_accelerations.ease = 1
	self._in_accelerations.fast = 0.5
	self._out_accelerations.fast = 0.5
	self._in_acc = self._in_accelerations.linear
	self._out_acc = self._out_accelerations.linear
	self._old_viewport = nil
	self._keys = {}
	local time = 0
	local fov = managers.worldcamera:default_fov()
	local near_dof = managers.worldcamera:default_near_dof()
	local far_dof = managers.worldcamera:default_far_dof()

	table.insert(self._keys, {
		roll = 0,
		time = time,
		fov = fov,
		near_dof = near_dof,
		far_dof = far_dof
	})

	self._dof_padding = managers.worldcamera:default_dof_padding()
	self._dof_clamp = managers.worldcamera:default_dof_clamp()
	self._curve_type = "bezier"
end

function CoreWorldCamera:save_data_table()
	local t = {
		name = self._world_camera_name,
		duration = self._duration,
		delay = self._delay,
		in_acc = self._in_acc,
		out_acc = self._out_acc,
		positions = self._positions,
		target_positions = self._target_positions,
		keys = self._keys,
		dof_padding = self._dof_padding,
		dof_clamp = self._dof_clamp,
		curve_type = self._curve_type,
		spline_metadata = self._spline_metadata
	}

	return t
end

function CoreWorldCamera:load(values)
	self._duration = values.duration
	self._delay = values.delay
	self._in_acc = values.in_acc
	self._out_acc = values.out_acc
	self._positions = values.positions
	self._target_positions = values.target_positions
	self._keys = values.keys
	self._dof_padding = values.dof_padding
	self._dof_clamp = values.dof_clamp
	self._curve_type = values.curve_type
	self._spline_metadata = values.spline_metadata

	self:_check_loaded_data()
end

function CoreWorldCamera:_check_loaded_data()
	for _, key in pairs(self._keys) do
		key.roll = key.roll or 0
	end
end

function CoreWorldCamera:old_load(node)
	self._duration = tonumber(node:parameter("duration"))
	self._delay = tonumber(node:parameter("delay"))

	if node:has_parameter("in_acc") then
		self._in_acc = tonumber(node:parameter("in_acc"))
	end

	if node:has_parameter("out_acc") then
		self._out_acc = tonumber(node:parameter("out_acc"))
	end

	for child in node:children() do
		if child:name() == "point" then
			local index = tonumber(child:parameter("index"))

			for value in child:children() do
				if value:name() == "pos" then
					self._positions[index] = math.string_to_vector(value:parameter("value"))
				elseif value:name() == "t_pos" then
					self._target_positions[index] = math.string_to_vector(value:parameter("value"))
				end
			end
		elseif child:name() == "value" then
			local name, value = parse_value_node(child)
			self[name] = value
		end
	end
end

function CoreWorldCamera:duration()
	return self._duration
end

function CoreWorldCamera:set_duration(duration)
	self._duration = duration
end

function CoreWorldCamera:duration()
	return self._duration
end

function CoreWorldCamera:set_delay(delay)
	self._delay = delay
end

function CoreWorldCamera:delay()
	return self._delay
end

function CoreWorldCamera:set_dof_padding(dof_padding)
	self._dof_padding = dof_padding
end

function CoreWorldCamera:dof_padding()
	return self._dof_padding
end

function CoreWorldCamera:set_dof_clamp(dof_clamp)
	self._dof_clamp = dof_clamp
end

function CoreWorldCamera:dof_clamp()
	return self._dof_clamp
end

function CoreWorldCamera:name()
	return self._world_camera_name
end

function CoreWorldCamera:in_acc()
	return self._in_acc
end

function CoreWorldCamera:out_acc()
	return self._out_acc
end

function CoreWorldCamera:set_sine_segment_position(new_pos, segment_index, segments, ctrl_points)
	local old_pos = segments[segment_index]
	local offset = new_pos - old_pos

	if ctrl_points.p1 then
		ctrl_points.p1 = ctrl_points.p1 + offset
		segments[segment_index] = new_pos

		if ctrl_points.p2 then
			mvector3.set(offset, new_pos)
			mvector3.subtract(offset, ctrl_points.p1)
			mvector3.set_length(offset, mvector3.distance(old_pos, ctrl_points.p2))
			mvector3.add(offset, new_pos)

			ctrl_points.p2 = offset
		end
	elseif ctrl_points.p2 then
		ctrl_points.p2 = ctrl_points.p2 + offset
		segments[segment_index] = new_pos
	end
end

function CoreWorldCamera:set_control_point_length(len_p1, len_p2, segment_index)
	local positions = self._positions
	local temp_vector = nil

	if len_p1 and segment_index > 1 then
		temp_vector = self._spline_metadata.ctrl_points[segment_index].p1 - positions[segment_index]

		mvector3.set_length(temp_vector, len_p1)

		self._spline_metadata.ctrl_points[segment_index].p1 = positions[segment_index] + temp_vector
	end

	if len_p2 and segment_index < #positions then
		if temp_vector then
			mvector3.set(temp_vector, self._spline_metadata.ctrl_points[segment_index].p2)
			mvector3.subtract(temp_vector, positions[segment_index])
		else
			temp_vector = self._spline_metadata.ctrl_points[segment_index].p2 - positions[segment_index]
		end

		mvector3.set_length(temp_vector, len_p2)
		mvector3.add(temp_vector, positions[segment_index])

		self._spline_metadata.ctrl_points[segment_index].p2 = temp_vector
	end
end

function CoreWorldCamera:rotate_control_points(p2_p1_vec, segment_index)
	local positions = self._positions
	local temp_vector = nil

	if segment_index > 1 then
		local p1_len = mvector3.distance(self._spline_metadata.ctrl_points[segment_index].p1, positions[segment_index])
		temp_vector = -p2_p1_vec

		mvector3.set_length(temp_vector, p1_len)

		self._spline_metadata.ctrl_points[segment_index].p1 = positions[segment_index] + temp_vector
	end

	if segment_index < #positions then
		local p2_len = mvector3.distance(self._spline_metadata.ctrl_points[segment_index].p2, positions[segment_index])

		if temp_vector then
			mvector3.negate(temp_vector)
		else
			temp_vector = mvector3.copy(p2_p1_vec)
		end

		mvector3.set_length(temp_vector, p2_len)

		self._spline_metadata.ctrl_points[segment_index].p2 = positions[segment_index] + temp_vector
	end
end

function CoreWorldCamera:set_curve_type_bezier()
	self._curve_type = "bezier"
	self._spline_metadata = nil

	while #self._positions > 4 do
		table.remove(self._positions)
		table.remove(self._target_positions)
	end

	self._editor_random_access_data = nil
end

function CoreWorldCamera:set_curve_type_sine()
	self._curve_type = "sine"

	if #self._positions > 2 then
		self:extract_spline_metadata()
	end

	self._editor_random_access_data = nil
end

function CoreWorldCamera:in_acc_string()
	for name, value in pairs(self._in_accelerations) do
		if value == self._in_acc then
			return name
		end
	end
end

function CoreWorldCamera:out_acc_string()
	for name, value in pairs(self._out_accelerations) do
		if value == self._out_acc then
			return name
		end
	end
end

function CoreWorldCamera:set_in_acc(in_acc)
	self._in_acc = self._in_accelerations[in_acc]
end

function CoreWorldCamera:set_out_acc(out_acc)
	self._out_acc = self._out_accelerations[out_acc]
end

function CoreWorldCamera:positions_at_time_bezier(time)
	local acc = math.bezier({
		0,
		self._in_acc,
		self._out_acc,
		1
	}, time)
	local b_type = self._bezier or self:bezier_function()

	if b_type then
		local pos = b_type(self._positions, acc)
		local t_pos = b_type(self._target_positions, acc)

		return pos, t_pos
	end

	return self._positions[1], self._target_positions[1]
end

function CoreWorldCamera:update(t, dt)
	if self._timer < self._stop_timer then
		self._timer = self._timer + dt / self._duration
		local pos, t_pos = self:play_to_time(self._timer)

		self:update_camera(pos, t_pos)
		self:set_current_fov(self:value_at_time(self._timer, "fov"))

		local near_dof = self:value_at_time(self._timer, "near_dof")
		local far_dof = self:value_at_time(self._timer, "far_dof")

		self:update_dof_values(near_dof, far_dof, self._dof_padding, self._dof_clamp)

		local rot = Rotation((t_pos - pos):normalized(), self:value_at_time(self._timer, "roll"))

		managers.worldcamera:camera_controller():set_default_up(rot:z())
	elseif self._delay > 0 and self._delay_timer < 1 then
		self._delay_timer = self._delay_timer + dt / self._delay
	else
		managers.worldcamera:stop_world_camera()
	end
end

function CoreWorldCamera:positions_at_time(s_t)
	if self._curve_type == "sine" then
		if not self._editor_random_access_data then
			local metadata = self._spline_metadata
			local subsegment_positions, subsegment_distances = self:extract_editor_random_access_data(self._positions, metadata.ctrl_points, metadata.nr_subseg_per_seg)
			local tar_subsegment_positions, tar_subsegment_distances = self:extract_editor_random_access_data(self._target_positions, metadata.tar_ctrl_points, metadata.nr_subseg_per_seg)
			self._editor_random_access_data = {
				subsegment_positions = subsegment_positions,
				subsegment_distances = subsegment_distances,
				tar_subsegment_positions = tar_subsegment_positions,
				tar_subsegment_distances = tar_subsegment_distances
			}
		end

		return self:positions_at_time_sine(s_t)
	else
		return self:positions_at_time_bezier(s_t)
	end
end

function CoreWorldCamera:play_to_time(s_t)
	if self._curve_type == "sine" then
		local smooth_time = math.bezier({
			0,
			self._in_acc,
			self._out_acc,
			1
		}, math.clamp(self._timer, 0, 1))

		return self:play_to_time_sine(smooth_time)
	else
		return self:positions_at_time_bezier(self._timer)
	end
end

function CoreWorldCamera:positions_at_time_sine(spline_t)
	local result_pos, result_look_pos = nil
	local positions = self._positions
	local tar_positions = self._target_positions

	if #positions > 2 then
		local rand_acc_data = self._editor_random_access_data
		local metadata = self._spline_metadata
		local wanted_dis_in_spline = math.clamp(spline_t * metadata.spline_length, 0, metadata.spline_length)
		local segment_lengths = metadata.segment_lengths

		for seg_i, seg_dis in ipairs(segment_lengths) do
			if wanted_dis_in_spline <= seg_dis or seg_i == #segment_lengths then
				local wanted_dis_in_segment = wanted_dis_in_spline - (segment_lengths[seg_i - 1] or 0)
				local subseg_positions = rand_acc_data.subsegment_positions[seg_i]
				local subseg_distances = rand_acc_data.subsegment_distances[seg_i]

				for subseg_i, subseg_dis in ipairs(subseg_distances) do
					if wanted_dis_in_segment <= subseg_dis or subseg_i == #subseg_distances then
						local wanted_dis_in_subseg = wanted_dis_in_segment - (subseg_distances[subseg_i - 1] or 0)
						local subseg_pos = subseg_positions[subseg_i]
						local prev_subseg_pos = subseg_positions[subseg_i - 1] or positions[seg_i]
						local subseg_len = mvector3.distance(subseg_pos, prev_subseg_pos)
						local percent_in_subseg = math.clamp(wanted_dis_in_subseg / subseg_len, 0, 1)
						result_pos = math.lerp(prev_subseg_pos, subseg_pos, percent_in_subseg)
						local percent_in_seg = wanted_dis_in_segment / (seg_dis - (segment_lengths[seg_i - 1] or 0))
						local tar_segment_lengths = metadata.tar_segment_lengths
						local tar_seg_len = tar_segment_lengths[seg_i] - (tar_segment_lengths[seg_i - 1] or 0)
						local wanted_dis_in_tar_seg = tar_seg_len * percent_in_seg
						local tar_subseg_positions = rand_acc_data.tar_subsegment_positions[seg_i]
						local tar_subseg_distances = rand_acc_data.tar_subsegment_distances[seg_i]

						for tar_subseg_i, tar_subseg_dis in ipairs(tar_subseg_distances) do
							if wanted_dis_in_tar_seg <= tar_subseg_dis or tar_subseg_i == #tar_subseg_distances then
								local wanted_dis_in_tar_subseg = wanted_dis_in_tar_seg - (tar_subseg_distances[tar_subseg_i - 1] or 0)
								local tar_subseg_pos = tar_subseg_positions[tar_subseg_i]
								local prev_tar_subseg_pos = tar_subseg_positions[tar_subseg_i - 1] or tar_positions[seg_i]
								local tar_subseg_len = mvector3.distance(tar_subseg_pos, prev_tar_subseg_pos)
								local percent_in_tar_subseg = math.clamp(wanted_dis_in_tar_subseg / tar_subseg_len, 0, 1)
								result_look_pos = result_pos + math.lerp(prev_tar_subseg_pos, tar_subseg_pos, percent_in_tar_subseg)

								break
							end
						end

						return result_pos, result_look_pos
					end
				end
			end
		end
	elseif #positions > 1 then
		result_pos = math.lerp(positions[1], positions[2], spline_t)
		result_look_pos = math.lerp(tar_positions[1], tar_positions[2], spline_t)
		result_look_pos = result_pos + result_look_pos
	else
		result_pos = positions[1]
		result_look_pos = result_pos + tar_positions[1]
	end

	return result_pos, result_look_pos
end

function CoreWorldCamera:play_to_time_sine(s_t)
	local result_pos, result_look_pos = nil

	if #self._positions > 2 then
		local segments = self._positions
		local metadata = self._spline_metadata
		local runtime_data = self._spline_runtime_data.pos
		local wanted_dis = math.clamp(s_t * metadata.spline_length, 0, metadata.spline_length)
		local adv_seg = nil

		while runtime_data.seg_i == 0 or runtime_data.seg_dis < wanted_dis do
			runtime_data.seg_i = runtime_data.seg_i + 1
			runtime_data.seg_dis = metadata.segment_lengths[runtime_data.seg_i]
			adv_seg = true
		end

		if adv_seg then
			runtime_data.seg_len = metadata.segment_lengths[runtime_data.seg_i] - (metadata.segment_lengths[runtime_data.seg_i - 1] or 0)
			runtime_data.subseg_i = 0
			runtime_data.subseg_dis = 0
			runtime_data.subseg_len = nil
			runtime_data.subseg_pos = nil
			runtime_data.subseg_prev_pos = segments[runtime_data.seg_i]
		end

		local wanted_dis_in_seg = wanted_dis - (metadata.segment_lengths[runtime_data.seg_i - 1] or 0)
		local seg_pos = segments[runtime_data.seg_i]
		local next_seg_pos = segments[runtime_data.seg_i + 1]
		local seg_p1 = metadata.ctrl_points[runtime_data.seg_i + 1].p1
		local seg_p2 = metadata.ctrl_points[runtime_data.seg_i].p2

		while (not runtime_data.subseg_pos or runtime_data.subseg_dis < wanted_dis_in_seg) and runtime_data.subseg_i < metadata.nr_subseg_per_seg do
			runtime_data.subseg_i = runtime_data.subseg_i + 1
			local new_subseg_pos = self:position_at_time_on_segment(runtime_data.subseg_i / metadata.nr_subseg_per_seg, seg_pos, next_seg_pos, seg_p1, seg_p2)
			runtime_data.subseg_len = mvector3.distance(runtime_data.subseg_pos or runtime_data.subseg_prev_pos, new_subseg_pos)
			runtime_data.subseg_dis = runtime_data.subseg_dis + runtime_data.subseg_len
			runtime_data.subseg_prev_pos = runtime_data.subseg_pos or runtime_data.subseg_prev_pos
			runtime_data.subseg_pos = new_subseg_pos
		end

		local percentage_in_subseg = 1 - (runtime_data.subseg_dis - wanted_dis_in_seg) / runtime_data.subseg_len
		result_pos = math.lerp(runtime_data.subseg_prev_pos, runtime_data.subseg_pos, percentage_in_subseg)
		local percentage_in_seg = wanted_dis_in_seg / runtime_data.seg_len
		result_look_pos = result_pos + 500 * self:cam_look_vec_on_segment(percentage_in_seg, runtime_data.seg_i)
	elseif #self._positions > 1 then
		result_pos = math.lerp(self._positions[1], self._positions[2], s_t)
		result_look_pos = math.lerp(self._target_positions[1], self._target_positions[2], s_t)
		result_look_pos = result_pos + result_look_pos
	else
		result_pos = self._positions[1]
		result_look_pos = result_pos + self._target_positions[1]
	end

	return result_pos, result_look_pos
end

function CoreWorldCamera:cam_look_vec_on_segment(perc_in_seg, seg_i)
	local segments = self._target_positions
	local metadata = self._spline_metadata
	local runtime_data = self._spline_runtime_data.dir

	if runtime_data.seg_i ~= seg_i then
		runtime_data.seg_i = seg_i
		runtime_data.subseg_dis = 0
		runtime_data.subseg_i = 0
		runtime_data.subseg_pos = nil
		runtime_data.subseg_prev_pos = segments[runtime_data.seg_i]
	end

	local wanted_dis_in_seg = perc_in_seg * (metadata.tar_segment_lengths[seg_i] - (metadata.tar_segment_lengths[seg_i - 1] or 0))
	local seg_pos = segments[seg_i]
	local next_seg_pos = segments[seg_i + 1]
	local seg_p1 = metadata.tar_ctrl_points[seg_i + 1].p1
	local seg_p2 = metadata.tar_ctrl_points[seg_i].p2

	while (not runtime_data.subseg_pos or runtime_data.subseg_dis < wanted_dis_in_seg) and runtime_data.subseg_i < metadata.nr_subseg_per_seg do
		runtime_data.subseg_i = runtime_data.subseg_i + 1
		local new_subseg_pos = self:position_at_time_on_segment(runtime_data.subseg_i / metadata.nr_subseg_per_seg, seg_pos, next_seg_pos, seg_p1, seg_p2)
		runtime_data.subseg_len = mvector3.distance(runtime_data.subseg_pos or runtime_data.subseg_prev_pos, new_subseg_pos)
		runtime_data.subseg_dis = runtime_data.subseg_dis + runtime_data.subseg_len
		runtime_data.subseg_prev_pos = runtime_data.subseg_pos or runtime_data.subseg_prev_pos
		runtime_data.subseg_pos = new_subseg_pos
	end

	local percentage_in_subseg = 1 - (runtime_data.subseg_dis - wanted_dis_in_seg) / runtime_data.subseg_len
	local wanted_pos = math.lerp(runtime_data.subseg_prev_pos, runtime_data.subseg_pos, percentage_in_subseg)

	return wanted_pos
end

function CoreWorldCamera:position_at_time_on_segment(seg_t, pos_start, pos_end, p1, p2)
	local ext_pos1 = math.lerp(pos_start, p2, seg_t)
	local ext_pos2 = math.lerp(p1, pos_end, seg_t)
	local xpo = (math.sin((seg_t * 2 - 1) * 90) + 1) * 0.5

	return math.lerp(ext_pos1, ext_pos2, xpo)
end

function CoreWorldCamera:extract_spline_control_points(position_table, curviness, start_index, end_index)
	local control_points = {}
	start_index = start_index or 1
	end_index = math.min(end_index or #position_table, #position_table)

	if end_index > 2 then
		local i = math.clamp(start_index, 2, end_index)

		while i <= end_index do
			local segment_control_points = self:extract_control_points_at_index(position_table, control_points, i, curviness)
			control_points[i] = segment_control_points
			i = i + 1
		end
	end

	if start_index == 1 then
		local segment_control_points = self:extract_control_points_at_index(position_table, control_points, 1, curviness)
		control_points[1] = segment_control_points
	end

	return control_points
end

function CoreWorldCamera:extract_control_points_at_index(position_table, control_points, index, curviness)
	local pos = position_table[index]
	local segment_control_points = {}
	local tan_seg = nil

	if index == #position_table then
		local last_seg = pos - position_table[#position_table - 1]
		local last_vec = (control_points[#position_table - 1].p2 or position_table[1]) - position_table[#position_table - 1]
		local last_angle = last_vec:angle(last_seg)
		local last_rot = last_seg:cross(last_vec)
		last_rot = Rotation(last_rot, 180 - 2 * last_angle)
		local w_vec = pos + last_vec:rotate_with(last_rot)
		segment_control_points.p1 = w_vec
	elseif index == 1 then
		local first_vec = control_points[2].p1 - position_table[2]
		local first_seg = position_table[2] - position_table[1]
		local first_angle = first_vec:angle(first_seg)
		local first_rot = first_seg:cross(first_vec)
		first_rot = Rotation(first_rot, 180 - 2 * first_angle)
		local w_vec = position_table[1] + first_vec:rotate_with(first_rot)
		segment_control_points.p2 = w_vec
	else
		tan_seg = position_table[index + 1] - position_table[index - 1]

		mvector3.set_length(tan_seg, mvector3.distance(pos, position_table[index - 1]) * curviness)

		segment_control_points.p1 = pos - tan_seg

		mvector3.set_length(tan_seg, mvector3.distance(pos, position_table[index + 1]) * curviness)

		segment_control_points.p2 = pos + tan_seg
	end

	return segment_control_points
end

function CoreWorldCamera:extract_spline_metadata()
	local nr_subseg_per_seg = 30
	local control_points = self:extract_spline_control_points(self._positions, 0.5)
	local segment_lengths, spline_length = self:extract_segment_dis_markers(self._positions, control_points, nr_subseg_per_seg)
	local tar_control_points = self:extract_spline_control_points(self._target_positions, 0.5)
	local tar_segment_lengths, tar_spline_length = self:extract_segment_dis_markers(self._target_positions, tar_control_points, nr_subseg_per_seg)
	self._spline_metadata = {
		ctrl_points = control_points,
		segment_lengths = segment_lengths,
		spline_length = spline_length,
		tar_ctrl_points = tar_control_points,
		tar_segment_lengths = tar_segment_lengths,
		tar_spline_length = tar_spline_length,
		nr_subseg_per_seg = nr_subseg_per_seg
	}
end

function CoreWorldCamera:extract_segment_dis_markers(segment_table, control_points, nr_subsegments)
	local segment_lengths = {}
	local spline_length = 0

	for index, pos in ipairs(segment_table) do
		if index == #segment_table then
			break
		end

		local next_seg_pos = segment_table[index + 1]
		local seg_p1 = control_points[index + 1].p1
		local seg_p2 = control_points[index].p2
		local seg_len = 0
		local subsegment_index = 1
		local prev_subseg_pos = pos

		while subsegment_index <= nr_subsegments do
			local spline_t = math.min(1, subsegment_index / nr_subsegments)
			local subseg_pos = self:position_at_time_on_segment(spline_t, pos, next_seg_pos, seg_p1, seg_p2)
			local subseg_len = mvector3.distance(prev_subseg_pos, subseg_pos)
			seg_len = seg_len + subseg_len
			prev_subseg_pos = subseg_pos
			subsegment_index = subsegment_index + 1
		end

		spline_length = spline_length + seg_len

		table.insert(segment_lengths, spline_length)
	end

	return segment_lengths, spline_length
end

function CoreWorldCamera:extract_editor_random_access_data(segment_table, control_points, nr_subsegments)
	local subsegment_lengths = {}
	local subsegment_positions = {}

	for index, pos in ipairs(segment_table) do
		if index == #segment_table then
			break
		end

		local seg_subsegment_lengths = {}
		local seg_subsegment_positions = {}
		local next_seg_pos = segment_table[index + 1]
		local seg_p1 = control_points[index + 1].p1
		local seg_p2 = control_points[index].p2
		local seg_len = 0
		local subsegment_index = 1
		local prev_subseg_pos = pos

		while subsegment_index <= nr_subsegments do
			local spline_t = math.min(1, subsegment_index / nr_subsegments)
			local subseg_pos = self:position_at_time_on_segment(spline_t, pos, next_seg_pos, seg_p1, seg_p2)
			local subseg_len = mvector3.distance(prev_subseg_pos, subseg_pos)
			seg_len = seg_len + subseg_len

			table.insert(seg_subsegment_lengths, seg_len)
			table.insert(seg_subsegment_positions, subseg_pos)

			prev_subseg_pos = subseg_pos
			subsegment_index = subsegment_index + 1
		end

		table.insert(subsegment_lengths, seg_subsegment_lengths)
		table.insert(subsegment_positions, seg_subsegment_positions)
	end

	return subsegment_positions, subsegment_lengths
end

function CoreWorldCamera:debug_draw_editor()
	local positions = self._positions
	local target_positions = self._target_positions
	local nr_segments = #positions

	if nr_segments > 0 then
		if nr_segments > 2 then
			if self._curve_type == "sine" then
				local metadata = self._spline_metadata
				local prev_subseg_pos = positions[1]

				for seg_i, seg_pos in ipairs(positions) do
					if seg_i == #positions then
						break
					end

					local seg_p1 = metadata.ctrl_points[seg_i + 1].p1
					local seg_p2 = metadata.ctrl_points[seg_i].p2
					local subsegment_index = 1
					local next_seg_pos = positions[seg_i + 1]

					while subsegment_index <= metadata.nr_subseg_per_seg do
						local spline_t = math.min(1, subsegment_index / metadata.nr_subseg_per_seg)
						local subseg_pos = self:position_at_time_on_segment(spline_t, seg_pos, next_seg_pos, seg_p1, seg_p2)

						Application:draw_line(subseg_pos, prev_subseg_pos, 1, 1, 1)

						prev_subseg_pos = subseg_pos
						subsegment_index = subsegment_index + 1
					end
				end
			else
				local step = 0.02
				local previous_pos = nil

				for i = step, 1, step do
					local acc = math.bezier({
						0,
						self:in_acc(),
						self:out_acc(),
						1
					}, i)
					local cam_pos, cam_look_pos = self:positions_at_time_bezier(acc)

					if previous_pos then
						Application:draw_line(cam_pos, previous_pos, 1, 1, 1)
					end

					previous_pos = cam_pos
					local look_dir = cam_look_pos - cam_pos

					mvector3.set_length(look_dir, 100)
					mvector3.add(look_dir, cam_pos)
					Application:draw_line(cam_pos, look_dir, 1, 1, 0)
				end
			end
		end

		for i, pos in ipairs(positions) do
			if i ~= nr_segments then
				Application:draw_line(pos, positions[i + 1], 0.75, 0.75, 0.75)
			end

			Application:draw_sphere(pos, 20, 1, 1, 1)

			local t_pos = target_positions[i]

			Application:draw_line(pos, pos + (t_pos - pos):normalized() * 500, 1, 1, 0)
		end
	end
end

function CoreWorldCamera:update_dof_values(...)
	managers.worldcamera:update_dof_values(...)
end

function CoreWorldCamera:set_current_fov(fov)
	managers.worldcamera:set_fov(fov)
end

function CoreWorldCamera:play(sequence_data)
	if #self._positions == 0 then
		return false, "Camera " .. self._world_camera_name .. " didn't have any points."
	end

	if self._duration == 0 then
		return false, "Camera " .. self._world_camera_name .. " has duration 0, must be higher."
	end

	self._timer = sequence_data.start or 0
	self._stop_timer = sequence_data.stop or 1
	self._delay_timer = 0
	self._index = 1
	self._target_point = nil
	self._playing = true

	if not self._curve_type or self._curve_type == "bezier" then
		self:set_curve_type_bezier()

		self._bezier = self:bezier_function()
	end

	local runtime_data_pos = {
		seg_dis = 0,
		seg_len = 0,
		seg_i = 0,
		subseg_i = 0,
		subseg_prev_pos = self._positions[1]
	}
	local runtime_data_look_dir = {
		seg_i = 0,
		subseg_i = 0,
		subseg_prev_pos = self._target_positions[1]
	}
	self._spline_runtime_data = {
		pos = runtime_data_pos,
		dir = runtime_data_look_dir
	}

	self:update_camera(self._positions[1], self._target_positions[1])
	self:set_current_fov(self:value_at_time(self._timer, "fov"))

	return true
end

function CoreWorldCamera:stop()
	self._playing = false
	self._bezier = nil
	self._spline_runtime_data = nil
end

function CoreWorldCamera:bezier_function()
	if #self._positions == 2 then
		return math.linear_bezier
	elseif #self._positions == 3 then
		return math.quadratic_bezier
	elseif #self._positions == 4 then
		return math.bezier
	end

	return nil
end

function CoreWorldCamera:update_camera(pos, t_pos)
	managers.worldcamera:camera_controller():set_camera(pos)
	managers.worldcamera:camera_controller():set_target(t_pos)
end

function CoreWorldCamera:add_point(pos, rot)
	if self._curve_type == "sine" then
		table.insert(self._positions, pos)
		table.insert(self._target_positions, rot:y())

		if #self._positions == 3 then
			self:extract_spline_metadata()
		elseif #self._positions > 3 then
			local new_control_points = self:extract_spline_control_points(self._positions, 0.5, #self._positions - 1, #self._positions)
			self._spline_metadata.ctrl_points[#self._positions - 1] = new_control_points[#self._positions - 1]
			self._spline_metadata.ctrl_points[#self._positions] = new_control_points[#self._positions]
			local segment_lengths, spline_length = self:extract_segment_dis_markers(self._positions, self._spline_metadata.ctrl_points, self._spline_metadata.nr_subseg_per_seg)
			self._spline_metadata.segment_lengths = segment_lengths
			self._spline_metadata.spline_length = spline_length
			new_control_points = self:extract_spline_control_points(self._target_positions, 0.5, #self._target_positions - 1, #self._target_positions)
			self._spline_metadata.tar_ctrl_points[#self._target_positions - 1] = new_control_points[#self._target_positions - 1]
			self._spline_metadata.tar_ctrl_points[#self._target_positions] = new_control_points[#self._target_positions]
			segment_lengths, spline_length = self:extract_segment_dis_markers(self._target_positions, self._spline_metadata.tar_ctrl_points, self._spline_metadata.nr_subseg_per_seg)
			self._spline_metadata.tar_segment_lengths = segment_lengths
			self._spline_metadata.tar_spline_length = spline_length
		end

		self:delete_editor_random_access_data()
	elseif #self._positions < 4 then
		table.insert(self._positions, pos)
		table.insert(self._target_positions, pos + rot:y() * self._target_offset)
	end
end

function CoreWorldCamera:get_points()
	return self._positions
end

function CoreWorldCamera:get_point(point)
	return {
		pos = self._positions[point],
		t_pos = self._target_positions[point]
	}
end

function CoreWorldCamera:delete_point(point)
	table.remove(self._positions, point)
	table.remove(self._target_positions, point)

	if self._curve_type == "sine" then
		if #self._positions < 3 then
			self:delete_spline_metadata()
		else
			table.remove(self._spline_metadata.ctrl_points, point)
			table.remove(self._spline_metadata.tar_ctrl_points, point)

			self._spline_metadata.ctrl_points[1].p1 = nil
			self._spline_metadata.ctrl_points[#self._positions].p2 = nil
			self._spline_metadata.tar_ctrl_points[1].p1 = nil
			self._spline_metadata.tar_ctrl_points[#self._target_positions].p2 = nil
			local segment_lengths, spline_length = self:extract_segment_dis_markers(self._positions, self._spline_metadata.ctrl_points, self._spline_metadata.nr_subseg_per_seg)
			self._spline_metadata.segment_lengths = segment_lengths
			self._spline_metadata.spline_length = spline_length
			segment_lengths, spline_length = self:extract_segment_dis_markers(self._target_positions, self._spline_metadata.tar_ctrl_points, self._spline_metadata.nr_subseg_per_seg)
			self._spline_metadata.tar_segment_lengths = segment_lengths
			self._spline_metadata.tar_spline_length = spline_length
		end

		self:delete_editor_random_access_data()
	end
end

function CoreWorldCamera:delete_spline_metadata()
	self._spline_metadata = nil
end

function CoreWorldCamera:delete_editor_random_access_data()
	self._editor_random_access_data = nil
end

function CoreWorldCamera:reset_control_points(segment_index)
	if self._curve_type == "sine" and #self._positions > 2 then
		local control_points = self:extract_control_points_at_index(self._positions, self._spline_metadata.ctrl_points, segment_index, 0.5)
		self._spline_metadata.ctrl_points[segment_index] = control_points
		local segment_lengths, spline_length = self:extract_segment_dis_markers(self._positions, self._spline_metadata.ctrl_points, self._spline_metadata.nr_subseg_per_seg)
		self._spline_metadata.spline_length = spline_length
		self._spline_metadata.segment_lengths = segment_lengths

		self:delete_editor_random_access_data()
	end
end

function CoreWorldCamera:move_point(point, pos, rot)
	if self._curve_type == "sine" then
		if pos then
			if #self._positions > 2 then
				self:set_sine_segment_position(pos, point, self._positions, self._spline_metadata.ctrl_points[point])

				local segment_lengths, spline_length = self:extract_segment_dis_markers(self._positions, self._spline_metadata.ctrl_points, self._spline_metadata.nr_subseg_per_seg)
				self._spline_metadata.spline_length = spline_length
				self._spline_metadata.segment_lengths = segment_lengths
			else
				self._positions[point] = pos
			end
		end

		if rot then
			if #self._positions > 2 then
				self:set_sine_segment_position(rot:y(), point, self._target_positions, self._spline_metadata.tar_ctrl_points[point])

				local new_control_points = self:extract_spline_control_points(self._target_positions, 0.5, point - 1, point + 1)

				for k, v in pairs(new_control_points) do
					self._spline_metadata.tar_ctrl_points[k] = v
				end

				local segment_lengths, spline_length = self:extract_segment_dis_markers(self._target_positions, self._spline_metadata.tar_ctrl_points, self._spline_metadata.nr_subseg_per_seg)
				self._spline_metadata.tar_spline_length = spline_length
				self._spline_metadata.tar_segment_lengths = segment_lengths
			else
				self._target_positions[point] = rot:y()
			end
		end

		self:delete_editor_random_access_data()
	else
		if pos then
			self._positions[point] = pos
		end

		if rot then
			local t_pos = rot:y() * self._target_offset + self._positions[point]
			self._target_positions[point] = t_pos
		end
	end
end

function CoreWorldCamera:positions()
	return self._positions
end

function CoreWorldCamera:target_positions()
	return self._target_positions
end

function CoreWorldCamera:insert_point(index, position, rotation)
end

function CoreWorldCamera:keys()
	return self._keys
end

function CoreWorldCamera:key(i)
	return self._keys[i]
end

function CoreWorldCamera:next_key(time)
	local index = 1

	for i, key in ipairs(self._keys) do
		if key.time <= time then
			index = i + 1
		end
	end

	if index > #self._keys then
		index = #self._keys
	end

	return index
end

function CoreWorldCamera:prev_key(time, step)
	local index = 1

	for i, key in ipairs(self._keys) do
		if step then
			if key.time < time then
				index = i
			end
		elseif key.time <= time then
			index = i
		end
	end

	return index
end

function CoreWorldCamera:add_key(time)
	local index = 1
	local fov, near_dof, far_dof, roll = nil
	fov = math.round(self:value_at_time(time, "fov"))
	near_dof = math.round(self:value_at_time(time, "near_dof"))
	far_dof = math.round(self:value_at_time(time, "far_dof"))
	roll = math.round(self:value_at_time(time, "roll"))
	local key = {
		time = time,
		fov = fov,
		near_dof = near_dof,
		far_dof = far_dof,
		roll = roll
	}

	for i, key in ipairs(self._keys) do
		if key.time < time then
			index = i + 1
		else
			break
		end
	end

	table.insert(self._keys, index, key)

	return index, key
end

function CoreWorldCamera:delete_key(index)
	table.remove(self._keys, index)
end

function CoreWorldCamera:move_key(index, time)
	if #self._keys == 1 then
		self._keys[1].time = time

		return 1
	else
		local old_key = clone(self._keys[index])

		self:delete_key(index)

		local index, key = self:add_key(time)
		key.fov = old_key.fov
		key.near_dof = old_key.near_dof
		key.far_dof = old_key.far_dof
		key.roll = old_key.roll

		return index
	end
end

function CoreWorldCamera:value_at_time(time, value)
	local prev_key = self:prev_value_key(time, value)
	local next_key = self:next_value_key(time, value)
	local mul = 1

	if next_key.time - prev_key.time ~= 0 then
		mul = (time - prev_key.time) / (next_key.time - prev_key.time)
	end

	local v = (next_key[value] - prev_key[value]) * mul + prev_key[value]

	return v
end

function CoreWorldCamera:prev_value_key(time, value)
	local index = self:prev_key(time)
	local key = self._keys[index]

	if key[value] then
		return key
	else
		return self:prev_value_key(key.time, value)
	end
end

function CoreWorldCamera:next_value_key(time, value)
	local index = self:next_key(time)
	local key = self._keys[index]

	if key[value] then
		return key
	else
		return self:next_value_key(key.time, value)
	end
end

function CoreWorldCamera:print_points()
	for i = 1, 4 do
		cat_print("debug", i, self._positions[i], self._target_positions[i])
	end
end

function CoreWorldCamera:playing()
	return self._playing
end
